# Search policy for the headless act clear.
# Every placement goes through Night Stamp's can_play / place_stamp, and every
# score is a real resolve_turn on a clone. Nothing writes progress or patience.
extends RefCounted

const Rules = preload("res://rules/rules.gd")

const WIDTH := 5
const DEPTH := 4

const CARD_POWER := {
	"wax_seal": 90,
	"heavy_chop": 84,
	"final_notice": 82,
	"visa_dot": 74,
	"duty": 72,
	"surcharge": 70,
	"ledger_line": 64,
	"column_tally": 62,
	"cross_check": 60,
	"pair_stamp": 58,
	"corner_notch": 56,
	"queue_push": 52,
	"waiver": 50,
	"entry_mark": 44,
	"ripple": 36,
	"night_fee": 34,
	"exemption": 30,
	"hold": 28,
	"echo": 12,
	"reply": 12,
}


static func choose(state) -> Dictionary:
	if state.phase == "draft":
		return {"type": "draft", "index": _best_draft(state)}
	if state.phase == "relic":
		return {"type": "relic", "id": Rules.RELIC_DEEP_WELL}
	if state.phase != "play":
		return {"type": "end"}
	var best_action = {"type": "end"}
	var best_score = _score(state)
	var plays = _ranked_plays(state)
	var limit = mini(WIDTH, plays.size())
	for i in limit:
		var play = plays[i]
		var sim = Rules.clone(state)
		if not Rules.place_stamp(sim, int(play["hand_index"]), int(play["row"]), int(play["col"])):
			continue
		var score = _search(sim, DEPTH - 1)
		if score > best_score:
			best_score = score
			best_action = {
				"type": "play",
				"hand_index": int(play["hand_index"]),
				"row": int(play["row"]),
				"col": int(play["col"]),
			}
			if best_score >= 100000:
				break
	return best_action


static func _search(state, depth: int) -> int:
	var best = _score(state)
	if best >= 100000 or depth <= 0 or state.ink <= 0:
		return best
	var plays = _ranked_plays(state)
	var limit = mini(WIDTH, plays.size())
	for i in limit:
		var play = plays[i]
		var sim = Rules.clone(state)
		if not Rules.place_stamp(sim, int(play["hand_index"]), int(play["row"]), int(play["col"])):
			continue
		var score = _search(sim, depth - 1)
		if score > best:
			best = score
			if best >= 100000:
				break
	return best


static func _score(state) -> int:
	var sim = Rules.clone(state)
	var result = Rules.resolve_turn(sim, true)
	var gained = int(result["progress_gained"])
	var score = gained * 100
	if result["won"]:
		return score + 100000
	if result["lost"]:
		return score - 100000
	score -= int(result["patience_loss"]) * 35
	score += int(sim.patience) * 8
	return score


static func _best_draft(state) -> int:
	var best_index = 0
	var best_power = -1
	for i in state.draft_options.size():
		var power = int(CARD_POWER.get(String(state.draft_options[i]), 0))
		if power > best_power:
			best_power = power
			best_index = i
	return best_index


static func _ranked_plays(state) -> Array:
	var plays: Array = []
	if state.ink <= 0:
		return plays
	for hand_index in state.hand.size():
		var card_id = Rules.card_id_of(state, int(state.hand[hand_index]))
		if card_id == "" or int(Rules.CARDS[card_id]["cost"]) > state.ink:
			continue
		for row in 3:
			for col in 3:
				if state.form[row][col] != null:
					continue
				plays.append({
					"hand_index": hand_index,
					"row": row,
					"col": col,
					"card_id": card_id,
					"guess": _cheap(state, card_id, row, col),
				})
	_sort_plays(plays)
	return plays


static func _sort_plays(plays: Array) -> void:
	for i in range(plays.size()):
		for j in range(i + 1, plays.size()):
			if _play_before(plays[j], plays[i]):
				var tmp = plays[i]
				plays[i] = plays[j]
				plays[j] = tmp


static func _play_before(a: Dictionary, b: Dictionary) -> bool:
	if int(a["guess"]) != int(b["guess"]):
		return int(a["guess"]) > int(b["guess"])
	if int(a["hand_index"]) != int(b["hand_index"]):
		return int(a["hand_index"]) < int(b["hand_index"])
	if int(a["row"]) != int(b["row"]):
		return int(a["row"]) < int(b["row"])
	return int(a["col"]) < int(b["col"])


static func _cheap(state, card_id: String, row: int, col: int) -> int:
	var guess = 1
	match card_id:
		"duty":
			guess = 4 if row == 2 else 2
			if state.relic_id == Rules.RELIC_IRON_PAD:
				guess += 1
		"surcharge":
			guess = 2
			if row > 0 and state.form[row - 1][col] != null:
				guess += 3
		"entry_mark", "ripple":
			guess = 2
		"visa_dot":
			guess = 3
		"wax_seal":
			guess = 6
		"heavy_chop":
			guess = 6 if row == 2 else 3
		"final_notice":
			guess = 3
			if row > 0 and row == 2 and state.form[row - 1][col] != null:
				guess += 3
		"queue_push":
			guess = 4 if row == 0 else 2
		"night_fee":
			guess = 1 + int(state.ink_spent)
		"ledger_line", "column_tally", "corner_notch", "pair_stamp", "cross_check", "waiver":
			guess = 2
		_:
			guess = 1
	var rule = String(Rules.traveler(state)["rule"])
	if rule == "refuse_top" and row == 0 and card_id != "exemption":
		guess -= 8
	if rule == "refuse_col1" and col == 0 and card_id != "exemption":
		guess -= 8
	if card_id == "exemption" and row == int(Rules.traveler(state)["exemption_row"]):
		guess += 4
	if rule == "yield_col2" and col == 1:
		guess += 3
	if rule == "yield_full_middle" and row == 1:
		guess += 3
	if rule == "double_patience_if_bottom_empty" and row == 2:
		guess += 3
	if rule == "double_patience_if_col3_empty" and col == 2:
		guess += 3
	if rule == "ignore_corners" and _is_corner(row, col) and card_id != "exemption":
		guess -= 8
	if rule == "refuse_middle" and row == 1 and card_id != "exemption":
		guess -= 8
	if rule == "yield_both_margins" and (col == 0 or col == 2):
		guess += 3
	if rule == "double_patience_if_center_empty" and row == 1 and col == 1:
		guess += 4
	if rule == "ignore_covered" and row > 0 and state.form[row - 1][col] != null and card_id != "exemption":
		guess -= 8
	if rule == "refuse_bottom" and row == 2 and card_id != "exemption":
		guess -= 8
	if rule == "yield_exact_two":
		var filled = 0
		for filled_row in 3:
			for filled_col in 3:
				if state.form[filled_row][filled_col] != null:
					filled += 1
		if filled == 1:
			guess += 3
		elif filled >= 2:
			guess -= 5
	if rule == "no_drop_if_every_row":
		var row_open = true
		for existing_col in 3:
			if state.form[row][existing_col] != null:
				row_open = false
		if row_open:
			guess += 3
	if rule == "double_last":
		guess += row * 2 + col
	if rule == "refuse_col2" and col == 1 and card_id != "exemption" and card_id != "hold":
		guess -= 8
	if rule == "yield_every_column":
		var column_open = true
		for existing_row in 3:
			if state.form[existing_row][col] != null:
				column_open = false
		if column_open:
			guess += 3
	if rule == "double_patience_if_col1_empty" and col == 0:
		guess += 3
	if rule == "ignore_adjacent" and card_id != "exemption":
		var touching = 0
		for delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var beside_row = row + delta.x
			var beside_col = col + delta.y
			if beside_row < 0 or beside_col < 0 or beside_row > 2 or beside_col > 2:
				continue
			if state.form[beside_row][beside_col] != null:
				touching += 1
		if touching > 0:
			guess -= 8
	if rule == "refuse_center" and row == 1 and col == 1 and card_id != "exemption" and card_id != "hold":
		guess -= 8
	if rule == "yield_diagonal":
		var corner = false
		for delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var corner_row = row + delta.x
			var corner_col = col + delta.y
			if corner_row < 0 or corner_col < 0 or corner_row > 2 or corner_col > 2:
				continue
			if state.form[corner_row][corner_col] != null:
				corner = true
		if corner:
			guess += 4
	if rule == "drop_per_empty_row":
		var toll_open = true
		for toll_col in 3:
			if state.form[row][toll_col] != null:
				toll_open = false
		if toll_open:
			guess += 3
	if rule == "ignore_shared_row" and card_id != "exemption":
		var shared = false
		for shared_col in 3:
			if state.form[row][shared_col] != null:
				shared = true
		if shared:
			guess -= 8
	if rule == "refuse_col3" and col == 2 and card_id != "exemption" and card_id != "hold":
		guess -= 8
	if rule == "yield_side":
		var beside = false
		for delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var beside_row = row + delta.x
			var beside_col = col + delta.y
			if beside_row < 0 or beside_col < 0 or beside_row > 2 or beside_col > 2:
				continue
			if state.form[beside_row][beside_col] != null:
				beside = true
		if beside:
			guess += 4
	if rule == "drop_per_empty_column":
		var column_open = true
		for existing_row in 3:
			if state.form[existing_row][col] != null:
				column_open = false
		if column_open:
			guess += 3
	if rule == "double_first":
		var earlier = false
		for earlier_row in range(0, row + 1):
			var end_col = 2
			if earlier_row == row:
				end_col = col - 1
			for earlier_col in range(0, end_col + 1):
				if state.form[earlier_row][earlier_col] != null:
					earlier = true
		if not earlier:
			guess += (2 - row) * 2 + (2 - col)
	if rule == "drop_if_shared_number":
		if _form_has_number(state, _stamp_number(state, card_id, row, col)):
			guess -= 2
	if rule == "yield_frame" and not (row == 1 and col == 1):
		guess += 3
	if rule == "zero_first":
		var head = true
		for head_row in range(0, row + 1):
			var head_end = 2
			if head_row == row:
				head_end = col - 1
			for head_col in range(0, head_end + 1):
				if state.form[head_row][head_col] != null:
					head = false
		if head and not (card_id == "exemption" and row == 0):
			guess = 2 - int(CARD_POWER.get(card_id, 40))
		elif not head:
			guess += 3
	if rule == "double_patience_if_center_filled" and row == 1 and col == 1:
		guess -= 12
	if rule == "yield_corner" and _is_corner(row, col):
		guess += 3
	if rule == "zero_last":
		var later_filled = false
		for later_row in range(row, 3):
			var start_col = 0
			if later_row == row:
				start_col = col + 1
			for later_col in range(start_col, 3):
				if state.form[later_row][later_col] != null:
					later_filled = true
		if later_filled:
			guess += 6
		else:
			guess -= 10
			if card_id == "exemption" and row == 2:
				guess += 12
	if rule == "double_center" and row == 1 and col == 1:
		guess += 4
	if rule == "refuse_stacked_col1" and col == 0 and card_id != "exemption" and card_id != "hold":
		var stacked = false
		for stacked_row in 3:
			if state.form[stacked_row][0] != null:
				stacked = true
		if stacked:
			guess -= 8
	if rule == "drop_if_queue_gap" and _placement_opens_gap(state, row, col):
		guess -= 6
	if rule == "refuse_stacked_bottom" and row == 2 and card_id != "exemption":
		var bottom_stacked = false
		for bottom_col in 3:
			if state.form[2][bottom_col] != null:
				bottom_stacked = true
		if bottom_stacked:
			guess -= 12
	if rule == "double_first_if_followed":
		var followed_earlier = false
		for followed_row in range(0, row + 1):
			var followed_end = 2
			if followed_row == row:
				followed_end = col - 1
			for followed_col in range(0, followed_end + 1):
				if state.form[followed_row][followed_col] != null:
					followed_earlier = true
		if not followed_earlier:
			guess += 5
	if rule == "zero_shared_later":
		var barred_number = _stamp_number(state, card_id, row, col)
		var barred_earlier = false
		for barred_row in range(0, row + 1):
			var barred_end = 2
			if barred_row == row:
				barred_end = col - 1
			for barred_col in range(0, barred_end + 1):
				var barred_stamp = state.form[barred_row][barred_col]
				if barred_stamp == null:
					continue
				if _stamp_number(state, String(barred_stamp["card_id"]), barred_row, barred_col) == barred_number:
					barred_earlier = true
		if barred_earlier:
			guess -= 20
		else:
			guess += 3
	if rule == "yield_empty":
		var occupied = 0
		for occupied_row in 3:
			for occupied_col in 3:
				if state.form[occupied_row][occupied_col] != null:
					occupied += 1
		guess += 8 - occupied
	if rule == "zero_side_later" and card_id != "exemption":
		var side = false
		for delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var side_row = row + delta.x
			var side_col = col + delta.y
			if side_row < 0 or side_col < 0 or side_row > 2 or side_col > 2:
				continue
			if state.form[side_row][side_col] != null:
				side = true
		if side:
			guess -= 10
	if rule == "double_patience_if_last_col3":
		var tail_row = -1
		var tail_col = -1
		for scan_row in range(2, -1, -1):
			for scan_col in range(2, -1, -1):
				if state.form[scan_row][scan_col] != null:
					tail_row = scan_row
					tail_col = scan_col
					break
			if tail_row >= 0:
				break
		var becomes_tail = tail_row < 0 or row > tail_row or (row == tail_row and col > tail_col)
		if becomes_tail and col == 2:
			guess -= 12
		elif becomes_tail and tail_col == 2:
			guess += 6
	if rule == "double_frame_if_center":
		if row == 1 and col == 1:
			guess += 4
		elif state.form[1][1] != null:
			guess += 4
	if rule == "yield_queue_gap" and _placement_opens_gap(state, row, col):
		guess += 4
	if rule == "zero_corner_later":
		var corner_spared = card_id == "exemption" and row == int(Rules.traveler(state)["exemption_row"])
		if not corner_spared:
			var exempt_row = int(Rules.traveler(state)["exemption_row"])
			for scan_col in 3:
				var scan_stamp = state.form[exempt_row][scan_col]
				if scan_stamp != null and String(scan_stamp["card_id"]) == "exemption":
					corner_spared = true
		if not corner_spared:
			var cornered = false
			for delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var corner_row = row + delta.x
				var corner_col = col + delta.y
				if corner_row < 0 or corner_col < 0 or corner_row > 2 or corner_col > 2:
					continue
				if state.form[corner_row][corner_col] == null:
					continue
				if corner_row < row or (corner_row == row and corner_col < col):
					cornered = true
			if cornered:
				guess -= 12
	if rule == "double_patience_if_first_col1":
		var head_row = -1
		var head_col = -1
		for scan_row in 3:
			for scan_col in 3:
				if state.form[scan_row][scan_col] != null:
					head_row = scan_row
					head_col = scan_col
					break
			if head_row >= 0:
				break
		var becomes_head = head_row < 0 or row < head_row or (row == head_row and col < head_col)
		if becomes_head and col == 0:
			guess -= 12
		elif becomes_head and head_col == 0:
			guess += 6
	if rule == "double_full_row":
		var row_filled = 0
		for scan_col in 3:
			if state.form[row][scan_col] != null:
				row_filled += 1
		if row_filled == 2:
			guess += 10
		elif row_filled == 1:
			guess += 4
	if rule == "yield_row_wings" and (col == 0 or col == 2):
		var other_wing = 2 if col == 0 else 0
		if state.form[row][other_wing] != null:
			guess += 6
		else:
			guess += 2
	if rule == "drop_if_exact_three":
		var toll_filled = 0
		for toll_row in 3:
			for toll_col in 3:
				if state.form[toll_row][toll_col] != null:
					toll_filled += 1
		if toll_filled == 2:
			guess -= 6
		elif toll_filled == 3:
			guess += 4
	if rule == "double_lowest_earliest":
		var low_number = _stamp_number(state, card_id, row, col)
		var low_count = 1
		var earlier_lower = false
		var later_lower = false
		for low_row in range(0, row + 1):
			var low_end = 2
			if low_row == row:
				low_end = col - 1
			for low_col in range(0, low_end + 1):
				var low_stamp = state.form[low_row][low_col]
				if low_stamp == null:
					continue
				low_count += 1
				if _stamp_number(state, String(low_stamp["card_id"]), low_row, low_col) <= low_number:
					earlier_lower = true
		for low_row in range(row, 3):
			var low_start = 0
			if low_row == row:
				low_start = col + 1
			for low_col in range(low_start, 3):
				var low_stamp = state.form[low_row][low_col]
				if low_stamp == null:
					continue
				low_count += 1
				if _stamp_number(state, String(low_stamp["card_id"]), low_row, low_col) < low_number:
					later_lower = true
		if low_count >= 2 and not earlier_lower and not later_lower:
			guess += low_number
	if rule == "double_after_gap":
		if row == 0 and col == 0:
			guess += 2
		else:
			var before_row = row
			var before_col = col - 1
			if before_col < 0:
				before_row = row - 1
				before_col = 2
			if state.form[before_row][before_col] == null:
				var earlier_filled = false
				for scan_row in range(0, before_row + 1):
					var scan_end = 2
					if scan_row == before_row:
						scan_end = before_col - 1
					for scan_col in range(0, scan_end + 1):
						if state.form[scan_row][scan_col] != null:
							earlier_filled = true
				if earlier_filled:
					guess += _stamp_number(state, card_id, row, col)
	if rule == "double_highest_earliest":
		var high_number = _stamp_number(state, card_id, row, col)
		var high_count = 1
		var earlier_higher = false
		var later_higher = false
		for high_row in range(0, row + 1):
			var high_end = 2
			if high_row == row:
				high_end = col - 1
			for high_col in range(0, high_end + 1):
				var high_stamp = state.form[high_row][high_col]
				if high_stamp == null:
					continue
				high_count += 1
				if _stamp_number(state, String(high_stamp["card_id"]), high_row, high_col) >= high_number:
					earlier_higher = true
		for high_row in range(row, 3):
			var high_start = 0
			if high_row == row:
				high_start = col + 1
			for high_col in range(high_start, 3):
				var high_stamp = state.form[high_row][high_col]
				if high_stamp == null:
					continue
				high_count += 1
				if _stamp_number(state, String(high_stamp["card_id"]), high_row, high_col) > high_number:
					later_higher = true
		if high_count >= 2 and not earlier_higher and not later_higher:
			guess += high_number
	if rule == "drop_if_exact_four":
		var four_filled = 0
		for four_row in 3:
			for four_col in 3:
				if state.form[four_row][four_col] != null:
					four_filled += 1
		if four_filled == 3:
			guess -= 6
		elif four_filled == 4:
			guess += 4
	if rule == "double_before_gap":
		if row == 2 and col == 2:
			guess -= 1
		else:
			var after_row = row
			var after_col = col + 1
			if after_col > 2:
				after_row = row + 1
				after_col = 0
			if state.form[after_row][after_col] == null:
				var later_filled = false
				for scan_row in range(after_row, 3):
					var scan_start = 0
					if scan_row == after_row:
						scan_start = after_col + 1
					for scan_col in range(scan_start, 3):
						if state.form[scan_row][scan_col] != null:
							later_filled = true
				if later_filled:
					guess += _stamp_number(state, card_id, row, col)
	if rule == "yield_column_pair":
		if row == 0 or row == 2:
			var other_end = 2 if row == 0 else 0
			if state.form[other_end][col] != null and state.form[1][col] == null:
				guess += 6
			elif state.form[1][col] == null:
				guess += 2
		elif row == 1 and (state.form[0][col] != null or state.form[2][col] != null):
			guess -= 4
	if rule == "yield_open_wing":
		if col == 0 or col == 2:
			var other_wing = 2 if col == 0 else 0
			if state.form[row][other_wing] != null and state.form[row][1] == null:
				guess += 6
			elif state.form[row][1] != null:
				guess -= 2
			else:
				guess += 2
		elif state.form[row][0] != null and state.form[row][2] != null:
			guess -= 6
		elif state.form[row][0] != null or state.form[row][2] != null:
			guess -= 2
	if rule == "drop_if_exact_five":
		var five_filled = 0
		for five_row in 3:
			for five_col in 3:
				if state.form[five_row][five_col] != null:
					five_filled += 1
		if five_filled == 4:
			guess -= 6
		elif five_filled == 5:
			guess += 4
	if rule == "double_highest_latest":
		var late_number = _stamp_number(state, card_id, row, col)
		var late_count = 1
		var strictly_higher = false
		var later_tied = false
		for late_row in range(0, row + 1):
			var late_end = 2
			if late_row == row:
				late_end = col - 1
			for late_col in range(0, late_end + 1):
				var late_stamp = state.form[late_row][late_col]
				if late_stamp == null:
					continue
				late_count += 1
				if _stamp_number(state, String(late_stamp["card_id"]), late_row, late_col) > late_number:
					strictly_higher = true
		for late_row in range(row, 3):
			var late_start = 0
			if late_row == row:
				late_start = col + 1
			for late_col in range(late_start, 3):
				var late_stamp = state.form[late_row][late_col]
				if late_stamp == null:
					continue
				late_count += 1
				if _stamp_number(state, String(late_stamp["card_id"]), late_row, late_col) >= late_number:
					later_tied = true
		if late_count >= 2 and not strictly_higher and not later_tied:
			guess += late_number
	if rule == "yield_diagonal_pair":
		var partner_row = -1
		var partner_col = -1
		if row == 0 and col == 0:
			partner_row = 2
			partner_col = 2
		elif row == 2 and col == 2:
			partner_row = 0
			partner_col = 0
		elif row == 0 and col == 2:
			partner_row = 2
			partner_col = 0
		elif row == 2 and col == 0:
			partner_row = 0
			partner_col = 2
		if partner_row >= 0:
			if state.form[1][1] == null and state.form[partner_row][partner_col] != null:
				guess += 6
			elif state.form[1][1] == null:
				guess += 2
		elif row == 1 and col == 1:
			var main_pair = state.form[0][0] != null and state.form[2][2] != null
			var anti_pair = state.form[0][2] != null and state.form[2][0] != null
			if main_pair or anti_pair:
				guess -= 6
			else:
				guess -= 2
	if rule == "yield_end_match":
		var first_number = -1
		var last_number = -1
		var filled = 0
		var match_head_row = -1
		var match_head_col = -1
		var match_tail_row = -1
		var match_tail_col = -1
		for scan_row in 3:
			for scan_col in 3:
				var scan_stamp = state.form[scan_row][scan_col]
				if scan_stamp == null:
					continue
				var scan_number = _stamp_number(state, String(scan_stamp["card_id"]), scan_row, scan_col)
				if filled == 0:
					first_number = scan_number
					match_head_row = scan_row
					match_head_col = scan_col
				last_number = scan_number
				match_tail_row = scan_row
				match_tail_col = scan_col
				filled += 1
		if filled >= 1:
			var mine = _stamp_number(state, card_id, row, col)
			var becomes_match_head = row < match_head_row or (row == match_head_row and col < match_head_col)
			var becomes_match_tail = row > match_tail_row or (row == match_tail_row and col > match_tail_col)
			var new_first = mine if becomes_match_head else first_number
			var new_last = mine if becomes_match_tail else last_number
			if new_first == new_last:
				guess += 4 + filled
			elif filled >= 2 and first_number == last_number:
				guess -= 6
	if rule == "double_shared_later":
		var shared_number = _stamp_number(state, card_id, row, col)
		var earlier_match = false
		for slip_row in range(0, row + 1):
			var slip_end = 2
			if slip_row == row:
				slip_end = col - 1
			for slip_col in range(0, slip_end + 1):
				var slip_stamp = state.form[slip_row][slip_col]
				if slip_stamp == null:
					continue
				if _stamp_number(state, String(slip_stamp["card_id"]), slip_row, slip_col) == shared_number:
					earlier_match = true
		if earlier_match:
			guess += shared_number
		guess += row
	if rule == "ignore_isolated":
		var neighbors = 0
		for delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var next_row = row + delta.x
			var next_col = col + delta.y
			if next_row < 0 or next_col < 0 or next_row > 2 or next_col > 2:
				continue
			if state.form[next_row][next_col] != null:
				neighbors += 1
		guess += neighbors * 3
		if neighbors == 0:
			guess -= 1
	if card_id == "hold" and col == int(Rules.traveler(state)["lane"]) and state.patience <= 2:
		guess += 6
	return guess


static func _is_corner(row: int, col: int) -> bool:
	return (row == 0 or row == 2) and (col == 0 or col == 2)


static func _stamp_number(state, card_id: String, row: int, col: int) -> int:
	match card_id:
		"duty":
			var duty_amount = 4 if row == 2 else 2
			if state.relic_id == Rules.RELIC_IRON_PAD:
				duty_amount += 1
			return duty_amount
		"exemption", "hold", "echo", "reply":
			return 1
		"surcharge":
			var surcharge_amount = 2
			if row > 0 and state.form[row - 1][col] != null:
				surcharge_amount += 3
			return surcharge_amount
		"entry_mark", "ripple":
			return 2
		"visa_dot":
			return 3
		"wax_seal":
			return 6
		"heavy_chop":
			return 6 if row == 2 else 3
		"queue_push":
			return 4 if row == 0 else 2
		"night_fee":
			return 1 + int(state.ink_spent)
		"final_notice":
			var notice = 3
			if row == 2 and state.form[row - 1][col] != null:
				notice += 3
			return notice
		_:
			return 2


static func _placement_opens_gap(state, row: int, col: int) -> bool:
	var first = -1
	var last = -1
	var count = 0
	var index = 0
	for scan_row in 3:
		for scan_col in 3:
			if state.form[scan_row][scan_col] != null or (scan_row == row and scan_col == col):
				if first < 0:
					first = index
				last = index
				count += 1
			index += 1
	if count < 2:
		return false
	return last - first + 1 > count


static func _form_has_number(state, number: int) -> bool:
	for row in 3:
		for col in 3:
			var stamp = state.form[row][col]
			if stamp == null:
				continue
			if _stamp_number(state, String(stamp["card_id"]), row, col) == number:
				return true
	return false
