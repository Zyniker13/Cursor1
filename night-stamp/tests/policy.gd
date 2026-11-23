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
	if rule == "double_lowest_latest":
		var low_number = _stamp_number(state, card_id, row, col)
		var low_count = 1
		var strictly_lower = false
		var later_tied = false
		for low_row in range(0, row + 1):
			var low_end = 2
			if low_row == row:
				low_end = col - 1
			for low_col in range(0, low_end + 1):
				var low_stamp = state.form[low_row][low_col]
				if low_stamp == null:
					continue
				low_count += 1
				if _stamp_number(state, String(low_stamp["card_id"]), low_row, low_col) < low_number:
					strictly_lower = true
		for low_row in range(row, 3):
			var low_start = 0
			if low_row == row:
				low_start = col + 1
			for low_col in range(low_start, 3):
				var low_stamp = state.form[low_row][low_col]
				if low_stamp == null:
					continue
				low_count += 1
				if _stamp_number(state, String(low_stamp["card_id"]), low_row, low_col) <= low_number:
					later_tied = true
		if low_count >= 2 and not strictly_lower and not later_tied:
			guess += low_number
	if rule == "drop_if_exact_six":
		var six_filled = 0
		for six_row in 3:
			for six_col in 3:
				if state.form[six_row][six_col] != null:
					six_filled += 1
		if six_filled == 5:
			guess -= 6
		elif six_filled == 6:
			guess += 4
	if rule == "double_full_column":
		var column_filled = 0
		for scan_row in 3:
			if state.form[scan_row][col] != null:
				column_filled += 1
		if column_filled == 2:
			guess += 10
		elif column_filled == 1:
			guess += 4
	if rule == "double_side_later":
		var sided = false
		for delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var side_row = row + delta.x
			var side_col = col + delta.y
			if side_row < 0 or side_col < 0 or side_row > 2 or side_col > 2:
				continue
			if state.form[side_row][side_col] == null:
				continue
			if side_row < row or (side_row == row and side_col < col):
				sided = true
		if sided:
			guess += _stamp_number(state, card_id, row, col)
	if rule == "drop_if_exact_seven":
		var seven_filled = 0
		for seven_row in 3:
			for seven_col in 3:
				if state.form[seven_row][seven_col] != null:
					seven_filled += 1
		if seven_filled == 6:
			guess -= 6
		elif seven_filled == 7:
			guess += 4
	if rule == "double_lone_column":
		var lone_filled = 0
		for lone_row in 3:
			if state.form[lone_row][col] != null:
				lone_filled += 1
		if lone_filled == 0:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
	if rule == "yield_side_pay":
		var side_pay = 0
		for delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var pay_row = row + delta.x
			var pay_col = col + delta.y
			if pay_row < 0 or pay_col < 0 or pay_row > 2 or pay_col > 2:
				continue
			if state.form[pay_row][pay_col] != null:
				side_pay += 1
		if side_pay > 0:
			guess += 3
	if rule == "double_next_filled":
		var filled_next_row = row
		var filled_next_col = col + 1
		if filled_next_col > 2:
			filled_next_row = row + 1
			filled_next_col = 0
		if filled_next_row <= 2 and state.form[filled_next_row][filled_next_col] != null:
			guess += _stamp_number(state, card_id, row, col)
		var filled_prev_row = row
		var filled_prev_col = col - 1
		if filled_prev_col < 0:
			filled_prev_row = row - 1
			filled_prev_col = 2
		if filled_prev_row >= 0 and state.form[filled_prev_row][filled_prev_col] != null:
			guess += 2
	if rule == "drop_if_exact_eight":
		var eight_filled = 0
		for eight_row in 3:
			for eight_col in 3:
				if state.form[eight_row][eight_col] != null:
					eight_filled += 1
		if eight_filled == 7:
			guess -= 6
		elif eight_filled == 8:
			guess += 4
	if rule == "double_prior_filled":
		var prior_row = row
		var prior_col = col - 1
		if prior_col < 0:
			prior_row = row - 1
			prior_col = 2
		if prior_row >= 0 and state.form[prior_row][prior_col] != null:
			guess += _stamp_number(state, card_id, row, col)
		var prior_next_row = row
		var prior_next_col = col + 1
		if prior_next_col > 2:
			prior_next_row = row + 1
			prior_next_col = 0
		if prior_next_row <= 2 and state.form[prior_next_row][prior_next_col] != null:
			guess += 4
	if rule == "yield_corner_pay":
		var corner_pay = 0
		for delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var corner_row = row + delta.x
			var corner_col = col + delta.y
			if corner_row < 0 or corner_col < 0 or corner_row > 2 or corner_col > 2:
				continue
			if state.form[corner_row][corner_col] != null:
				corner_pay += 1
		if corner_pay > 0:
			guess += 8
	if rule == "double_short_row":
		var short_filled = 0
		for short_col in 3:
			if state.form[row][short_col] != null:
				short_filled += 1
		if short_filled == 1:
			guess += _stamp_number(state, card_id, row, col) + 4
		elif short_filled == 2:
			guess -= 8
	if rule == "drop_if_exact_nine":
		var nine_filled = 0
		for nine_row in 3:
			for nine_col in 3:
				if state.form[nine_row][nine_col] != null:
					nine_filled += 1
		if nine_filled == 8:
			guess -= 6
		elif nine_filled == 9:
			guess += 4
	if rule == "double_lone_row":
		var lone_row_filled = 0
		for lone_col in 3:
			if state.form[row][lone_col] != null:
				lone_row_filled += 1
		if lone_row_filled == 0:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
	if rule == "double_short_column":
		var short_col_filled = 0
		for short_row in 3:
			if state.form[short_row][col] != null:
				short_col_filled += 1
		if short_col_filled == 1:
			guess += _stamp_number(state, card_id, row, col) + 4
		elif short_col_filled == 2:
			guess -= 8
	if rule == "double_corner_later":
		var cornered_later = false
		for delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var corner_row = row + delta.x
			var corner_col = col + delta.y
			if corner_row < 0 or corner_col < 0 or corner_row > 2 or corner_col > 2:
				continue
			if state.form[corner_row][corner_col] == null:
				continue
			if corner_row < row or (corner_row == row and corner_col < col):
				cornered_later = true
		if cornered_later:
			guess += _stamp_number(state, card_id, row, col)
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
	if rule == "drop_if_odd_count":
		var odd_filled = 0
		for odd_row in 3:
			for odd_col in 3:
				if state.form[odd_row][odd_col] != null:
					odd_filled += 1
		if odd_filled % 2 == 0:
			guess -= 2
		else:
			guess += 2
	if rule == "double_next_empty":
		var blank_next_row = row
		var blank_next_col = col + 1
		if blank_next_col > 2:
			blank_next_row = row + 1
			blank_next_col = 0
		if blank_next_row > 2:
			guess -= 6
		elif state.form[blank_next_row][blank_next_col] == null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var blank_prev_row = row
		var blank_prev_col = col - 1
		if blank_prev_col < 0:
			blank_prev_row = row - 1
			blank_prev_col = 2
		if blank_prev_row >= 0 and state.form[blank_prev_row][blank_prev_col] != null:
			var blank_prev = state.form[blank_prev_row][blank_prev_col]
			guess -= _stamp_number(state, String(blank_prev["card_id"]), blank_prev_row, blank_prev_col)
	if rule == "double_corner_cell":
		if (row == 0 or row == 2) and (col == 0 or col == 2):
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 3
	if rule == "yield_middle_pay":
		if row == 1:
			guess += 6
		else:
			guess -= 1
	if rule == "drop_if_even_count":
		var even_filled = 0
		for even_row in 3:
			for even_col in 3:
				if state.form[even_row][even_col] != null:
					even_filled += 1
		if even_filled % 2 == 0:
			guess += 2
		else:
			guess -= 2
	if rule == "double_prior_empty":
		var blank_prior_row = row
		var blank_prior_col = col - 1
		if blank_prior_col < 0:
			blank_prior_row = row - 1
			blank_prior_col = 2
		if blank_prior_row < 0:
			guess -= 6
		elif state.form[blank_prior_row][blank_prior_col] == null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var blank_next_row = row
		var blank_next_col = col + 1
		if blank_next_col > 2:
			blank_next_row = row + 1
			blank_next_col = 0
		if blank_next_row <= 2 and state.form[blank_next_row][blank_next_col] != null:
			var blank_next = state.form[blank_next_row][blank_next_col]
			guess -= _stamp_number(state, String(blank_next["card_id"]), blank_next_row, blank_next_col)
	if rule == "double_edge_middle":
		var edge_middle = (row == 1 and col != 1) or (col == 1 and row != 1)
		if edge_middle:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 3
	if rule == "yield_top_pay":
		if row == 0:
			guess += 6
		else:
			guess -= 1
	if rule == "drop_if_square_count":
		var square_filled = 0
		for square_row in 3:
			for square_col in 3:
				if state.form[square_row][square_col] != null:
					square_filled += 1
		var square_next = square_filled + 1
		if square_next == 1 or square_next == 4 or square_next == 9:
			guess -= 2
		elif square_filled == 0 or square_filled == 1 or square_filled == 4 or square_filled == 9:
			guess += 2
	if rule == "double_end_blank":
		var end_prev_row = row
		var end_prev_col = col - 1
		if end_prev_col < 0:
			end_prev_row = row - 1
			end_prev_col = 2
		var end_next_row = row
		var end_next_col = col + 1
		if end_next_col > 2:
			end_next_row = row + 1
			end_next_col = 0
		var end_prev_filled = end_prev_row >= 0 and state.form[end_prev_row][end_prev_col] != null
		var end_next_filled = end_next_row <= 2 and state.form[end_next_row][end_next_col] != null
		if not end_prev_filled and not end_next_filled:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		if end_prev_filled:
			var spoil_prev_row = end_prev_row
			var spoil_prev_col = end_prev_col - 1
			if spoil_prev_col < 0:
				spoil_prev_row = end_prev_row - 1
				spoil_prev_col = 2
			var spoil_prev_filled = spoil_prev_row >= 0 and state.form[spoil_prev_row][spoil_prev_col] != null
			if not spoil_prev_filled:
				var spoiled_prev = state.form[end_prev_row][end_prev_col]
				guess -= _stamp_number(state, String(spoiled_prev["card_id"]), end_prev_row, end_prev_col)
		if end_next_filled:
			var spoil_next_row = end_next_row
			var spoil_next_col = end_next_col + 1
			if spoil_next_col > 2:
				spoil_next_row = end_next_row + 1
				spoil_next_col = 0
			var spoil_next_filled = spoil_next_row <= 2 and state.form[spoil_next_row][spoil_next_col] != null
			if not spoil_next_filled:
				var spoiled_next = state.form[end_next_row][end_next_col]
				guess -= _stamp_number(state, String(spoiled_next["card_id"]), end_next_row, end_next_col)
	if rule == "yield_frame_pay":
		if (row == 0 or row == 2) and (col == 0 or col == 2):
			guess += 6
		else:
			guess -= 1
	if rule == "yield_lane_pay":
		if col == 1:
			guess += 6
		else:
			guess -= 1
	if rule == "drop_if_triad_count":
		var triad_filled = 0
		for triad_row in 3:
			for triad_col in 3:
				if state.form[triad_row][triad_col] != null:
					triad_filled += 1
		var triad_next = triad_filled + 1
		if triad_next % 3 == 0:
			guess -= 2
		elif triad_filled % 3 == 0:
			guess += 2
	if rule == "double_skip_blank":
		var skip_back_row = row
		var skip_back_col = col - 2
		if skip_back_col < 0:
			skip_back_row = row - 1
			skip_back_col += 3
		if skip_back_row < 0:
			guess -= 4
		elif state.form[skip_back_row][skip_back_col] == null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var skip_ahead_row = row
		var skip_ahead_col = col + 2
		if skip_ahead_col > 2:
			skip_ahead_row = row + 1
			skip_ahead_col -= 3
		if skip_ahead_row <= 2 and state.form[skip_ahead_row][skip_ahead_col] != null:
			var skip_spoiled = state.form[skip_ahead_row][skip_ahead_col]
			guess -= _stamp_number(state, String(skip_spoiled["card_id"]), skip_ahead_row, skip_ahead_col)
	if rule == "yield_wing_pay":
		if row == 1 and col != 1:
			guess += 6
		else:
			guess -= 1
	if rule == "yield_gutter_pay":
		if col == 0:
			guess += 6
		else:
			guess -= 1
	if rule == "drop_if_high_count":
		var high_filled = 0
		for high_row in 3:
			for high_col in 3:
				if state.form[high_row][high_col] != null:
					high_filled += 1
		var high_next = high_filled + 1
		if high_next >= 7:
			guess -= 6
		elif high_filled >= 7:
			guess += 4
	if rule == "double_skip_fill":
		var fill_back_row = row
		var fill_back_col = col - 2
		if fill_back_col < 0:
			fill_back_row = row - 1
			fill_back_col += 3
		if fill_back_row < 0:
			guess -= 4
		elif state.form[fill_back_row][fill_back_col] != null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var fill_ahead_row = row
		var fill_ahead_col = col + 2
		if fill_ahead_col > 2:
			fill_ahead_row = row + 1
			fill_ahead_col -= 3
		if fill_ahead_row <= 2 and state.form[fill_ahead_row][fill_ahead_col] != null:
			var fill_helped = state.form[fill_ahead_row][fill_ahead_col]
			guess += _stamp_number(state, String(fill_helped["card_id"]), fill_ahead_row, fill_ahead_col)
	if rule == "yield_post_pay":
		if col == 2:
			guess += 6
		else:
			guess -= 1
	if rule == "yield_seam_pay":
		var seam_pay = 0
		for delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var seam_row = row + delta.x
			var seam_col = col + delta.y
			if seam_row < 0 or seam_col < 0 or seam_row > 2 or seam_col > 2:
				continue
			if state.form[seam_row][seam_col] != null:
				seam_pay += 1
		if seam_pay > 0:
			guess += 4
		else:
			guess -= 1
	if rule == "drop_if_low_count":
		var low_filled = 0
		for low_row in 3:
			for low_col in 3:
				if state.form[low_row][low_col] != null:
					low_filled += 1
		var low_next = low_filled + 1
		if low_next <= 2:
			guess -= 4
		elif low_filled <= 2:
			guess += 5
	if rule == "double_skip_gap":
		var gap_ahead_row = row
		var gap_ahead_col = col + 2
		if gap_ahead_col > 2:
			gap_ahead_row = row + 1
			gap_ahead_col -= 3
		if gap_ahead_row > 2:
			guess -= 4
		elif state.form[gap_ahead_row][gap_ahead_col] == null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var gap_back_row = row
		var gap_back_col = col - 2
		if gap_back_col < 0:
			gap_back_row = row - 1
			gap_back_col += 3
		if gap_back_row >= 0 and state.form[gap_back_row][gap_back_col] != null:
			var gap_spoiled = state.form[gap_back_row][gap_back_col]
			guess -= _stamp_number(state, String(gap_spoiled["card_id"]), gap_back_row, gap_back_col)
	if rule == "yield_crown_pay":
		if row == 0 and col == 1:
			guess += 6
		else:
			guess -= 1
	if rule == "drop_if_cube_count":
		var cube_filled = 0
		for cube_row in 3:
			for cube_col in 3:
				if state.form[cube_row][cube_col] != null:
					cube_filled += 1
		var cube_next = cube_filled + 1
		if cube_next == 1 or cube_next == 8:
			guess -= 4
		elif cube_filled == 1 or cube_filled == 8:
			guess += 5
	if rule == "drop_if_short_count":
		var short_filled = 0
		for short_row in 3:
			for short_col in 3:
				if state.form[short_row][short_col] != null:
					short_filled += 1
		var short_next = short_filled + 1
		if short_next == 1 or short_next == 2:
			guess -= 4
		elif short_filled == 1 or short_filled == 2:
			guess += 5
	if rule == "double_far_blank":
		var far_ahead_row = row
		var far_ahead_col = col + 3
		if far_ahead_col > 2:
			far_ahead_row = row + 1
			far_ahead_col -= 3
		if far_ahead_row > 2:
			guess -= 4
		elif state.form[far_ahead_row][far_ahead_col] == null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var far_back_row = row
		var far_back_col = col - 3
		if far_back_col < 0:
			far_back_row = row - 1
			far_back_col += 3
		if far_back_row >= 0 and state.form[far_back_row][far_back_col] != null:
			var far_spoiled = state.form[far_back_row][far_back_col]
			guess -= _stamp_number(state, String(far_spoiled["card_id"]), far_back_row, far_back_col)
	if rule == "yield_heart_pay":
		if row == 1 and col == 1:
			guess += 6
		else:
			guess -= 1
	if rule == "yield_void_pay":
		var void_neighbors = 0
		for delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var void_row = row + delta.x
			var void_col = col + delta.y
			if void_row < 0 or void_col < 0 or void_row > 2 or void_col > 2:
				continue
			if state.form[void_row][void_col] == null:
				continue
			void_neighbors += 1
			var neighbor_sides = 0
			for neighbor_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var neighbor_row = void_row + neighbor_delta.x
				var neighbor_col = void_col + neighbor_delta.y
				if neighbor_row < 0 or neighbor_col < 0 or neighbor_row > 2 or neighbor_col > 2:
					continue
				if neighbor_row == row and neighbor_col == col:
					continue
				if state.form[neighbor_row][neighbor_col] != null:
					neighbor_sides += 1
			if neighbor_sides == 0:
				guess -= 2
		if void_neighbors == 0:
			guess += 4
		else:
			guess -= 1
	if rule == "drop_if_composite_count":
		var composite_filled = 0
		for composite_row in 3:
			for composite_col in 3:
				if state.form[composite_row][composite_col] != null:
					composite_filled += 1
		var composite_next = composite_filled + 1
		if composite_next == 4 or composite_next == 6 or composite_next == 8 or composite_next == 9:
			guess -= 4
		elif composite_filled == 4 or composite_filled == 6 or composite_filled == 8 or composite_filled == 9:
			guess += 5
	if rule == "double_far_fill":
		var fill_ahead_row = row
		var fill_ahead_col = col + 3
		if fill_ahead_col > 2:
			fill_ahead_row = row + 1
			fill_ahead_col -= 3
		if fill_ahead_row > 2:
			guess -= 4
		elif state.form[fill_ahead_row][fill_ahead_col] != null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var fill_back_row = row
		var fill_back_col = col - 3
		if fill_back_col < 0:
			fill_back_row = row - 1
			fill_back_col += 3
		if fill_back_row >= 0 and state.form[fill_back_row][fill_back_col] != null:
			var fill_helped = state.form[fill_back_row][fill_back_col]
			guess += _stamp_number(state, String(fill_helped["card_id"]), fill_back_row, fill_back_col)
	if rule == "yield_open_pay":
		var open_touches = 0
		for open_delta in [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]:
			var open_row = row + open_delta.x
			var open_col = col + open_delta.y
			if open_row < 0 or open_col < 0 or open_row > 2 or open_col > 2:
				continue
			if state.form[open_row][open_col] == null:
				continue
			open_touches += 1
			var neighbor_touches = 0
			for neighbor_delta in [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]:
				var neighbor_row = open_row + neighbor_delta.x
				var neighbor_col = open_col + neighbor_delta.y
				if neighbor_row < 0 or neighbor_col < 0 or neighbor_row > 2 or neighbor_col > 2:
					continue
				if neighbor_row == row and neighbor_col == col:
					continue
				if state.form[neighbor_row][neighbor_col] != null:
					neighbor_touches += 1
			if neighbor_touches == 0:
				guess -= 2
		if open_touches == 0:
			guess += 4
		else:
			guess -= 1
	if rule == "double_long_blank":
		var long_ahead_row = row
		var long_ahead_col = col + 4
		while long_ahead_col > 2:
			long_ahead_row += 1
			long_ahead_col -= 3
		if long_ahead_row > 2:
			guess -= 4
		elif state.form[long_ahead_row][long_ahead_col] == null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var long_back_row = row
		var long_back_col = col - 4
		while long_back_col < 0:
			long_back_row -= 1
			long_back_col += 3
		if long_back_row >= 0 and state.form[long_back_row][long_back_col] != null:
			var long_spoiled = state.form[long_back_row][long_back_col]
			guess -= _stamp_number(state, String(long_spoiled["card_id"]), long_back_row, long_back_col)
	if rule == "drop_if_power_count":
		var power_filled = 0
		for power_row in 3:
			for power_col in 3:
				if state.form[power_row][power_col] != null:
					power_filled += 1
		var power_next = power_filled + 1
		if power_next == 1 or power_next == 2 or power_next == 4 or power_next == 8:
			guess -= 4
		elif power_filled == 1 or power_filled == 2 or power_filled == 4 or power_filled == 8:
			guess += 5
	if rule == "double_farther_blank":
		var farther_ahead_row = row
		var farther_ahead_col = col + 5
		while farther_ahead_col > 2:
			farther_ahead_row += 1
			farther_ahead_col -= 3
		if farther_ahead_row > 2:
			guess -= 4
		elif state.form[farther_ahead_row][farther_ahead_col] == null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var farther_back_row = row
		var farther_back_col = col - 5
		while farther_back_col < 0:
			farther_back_row -= 1
			farther_back_col += 3
		if farther_back_row >= 0 and state.form[farther_back_row][farther_back_col] != null:
			var farther_spoiled = state.form[farther_back_row][farther_back_col]
			guess -= _stamp_number(state, String(farther_spoiled["card_id"]), farther_back_row, farther_back_col)
	if rule == "yield_rim_pay":
		var rim = (row == 1 and col != 1) or (col == 1 and row != 1)
		if rim:
			guess += 6
		else:
			guess -= 1
	if rule == "double_long_fill":
		var fill_ahead_row = row
		var fill_ahead_col = col + 4
		while fill_ahead_col > 2:
			fill_ahead_row += 1
			fill_ahead_col -= 3
		if fill_ahead_row > 2:
			guess -= 4
		elif state.form[fill_ahead_row][fill_ahead_col] != null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var fill_back_row = row
		var fill_back_col = col - 4
		while fill_back_col < 0:
			fill_back_row -= 1
			fill_back_col += 3
		if fill_back_row >= 0 and state.form[fill_back_row][fill_back_col] != null:
			var fill_helped = state.form[fill_back_row][fill_back_col]
			guess += _stamp_number(state, String(fill_helped["card_id"]), fill_back_row, fill_back_col)
	if rule == "drop_if_mid_count":
		var mid_filled = 0
		for mid_row in 3:
			for mid_col in 3:
				if state.form[mid_row][mid_col] != null:
					mid_filled += 1
		var mid_next = mid_filled + 1
		if mid_next == 3 or mid_next == 4 or mid_next == 5 or mid_next == 6:
			guess -= 4
		elif mid_filled == 3 or mid_filled == 4 or mid_filled == 5 or mid_filled == 6:
			guess += 5
	if rule == "double_farther_fill":
		var farther_ahead_row = row
		var farther_ahead_col = col + 5
		while farther_ahead_col > 2:
			farther_ahead_row += 1
			farther_ahead_col -= 3
		if farther_ahead_row > 2:
			guess -= 4
		elif state.form[farther_ahead_row][farther_ahead_col] != null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var farther_back_row = row
		var farther_back_col = col - 5
		while farther_back_col < 0:
			farther_back_row -= 1
			farther_back_col += 3
		if farther_back_row >= 0 and state.form[farther_back_row][farther_back_col] != null:
			var farther_helped = state.form[farther_back_row][farther_back_col]
			guess += _stamp_number(state, String(farther_helped["card_id"]), farther_back_row, farther_back_col)
	if rule == "yield_mitre_pay":
		var mitre_corners = 0
		var mitre_sides = 0
		for mitre_delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var mitre_row = row + mitre_delta.x
			var mitre_col = col + mitre_delta.y
			if mitre_row < 0 or mitre_col < 0 or mitre_row > 2 or mitre_col > 2:
				continue
			if state.form[mitre_row][mitre_col] != null:
				mitre_corners += 1
		for mitre_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var mitre_row = row + mitre_delta.x
			var mitre_col = col + mitre_delta.y
			if mitre_row < 0 or mitre_col < 0 or mitre_row > 2 or mitre_col > 2:
				continue
			if state.form[mitre_row][mitre_col] != null:
				mitre_sides += 1
		if mitre_corners > 0 and mitre_sides == 0:
			guess += 4
		else:
			guess -= 1
		for mitre_delta in [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]:
			var near_row = row + mitre_delta.x
			var near_col = col + mitre_delta.y
			if near_row < 0 or near_col < 0 or near_row > 2 or near_col > 2:
				continue
			if state.form[near_row][near_col] == null:
				continue
			var was_corner = 0
			var was_side = 0
			var now_corner = 0
			var now_side = 0
			for corner_delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var look_row = near_row + corner_delta.x
				var look_col = near_col + corner_delta.y
				if look_row < 0 or look_col < 0 or look_row > 2 or look_col > 2:
					continue
				if state.form[look_row][look_col] != null or (look_row == row and look_col == col):
					now_corner += 1
					if not (look_row == row and look_col == col):
						was_corner += 1
			for side_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var look_row = near_row + side_delta.x
				var look_col = near_col + side_delta.y
				if look_row < 0 or look_col < 0 or look_row > 2 or look_col > 2:
					continue
				if state.form[look_row][look_col] != null or (look_row == row and look_col == col):
					now_side += 1
					if not (look_row == row and look_col == col):
						was_side += 1
			var was_mitre = was_corner > 0 and was_side == 0
			var now_mitre = now_corner > 0 and now_side == 0
			if was_mitre and not now_mitre:
				guess -= 2
			elif now_mitre and not was_mitre:
				guess += 2
	if rule == "double_long_back":
		var back_row = row
		var back_col = col - 4
		while back_col < 0:
			back_row -= 1
			back_col += 3
		if back_row < 0:
			guess -= 4
		elif state.form[back_row][back_col] != null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var ahead_row = row
		var ahead_col = col + 4
		while ahead_col > 2:
			ahead_row += 1
			ahead_col -= 3
		if ahead_row <= 2 and state.form[ahead_row][ahead_col] != null:
			var back_helped = state.form[ahead_row][ahead_col]
			guess += _stamp_number(state, String(back_helped["card_id"]), ahead_row, ahead_col)
	if rule == "drop_if_outer_count":
		var outer_filled = 0
		for outer_row in 3:
			for outer_col in 3:
				if state.form[outer_row][outer_col] != null:
					outer_filled += 1
		var outer_next = outer_filled + 1
		if outer_next == 9:
			guess -= 4
		elif outer_filled == 0:
			guess += 5
	if rule == "double_near_blank":
		var near_back_row = row
		var near_back_col = col - 3
		while near_back_col < 0:
			near_back_row -= 1
			near_back_col += 3
		if near_back_row < 0:
			guess -= 4
		elif state.form[near_back_row][near_back_col] == null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var near_ahead_row = row
		var near_ahead_col = col + 3
		while near_ahead_col > 2:
			near_ahead_row += 1
			near_ahead_col -= 3
		if near_ahead_row <= 2 and state.form[near_ahead_row][near_ahead_col] != null:
			var near_spoiled = state.form[near_ahead_row][near_ahead_col]
			guess -= _stamp_number(state, String(near_spoiled["card_id"]), near_ahead_row, near_ahead_col)
	if rule == "yield_brace_pay":
		var brace_sides = 0
		var brace_corners = 0
		for brace_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var brace_row = row + brace_delta.x
			var brace_col = col + brace_delta.y
			if brace_row < 0 or brace_col < 0 or brace_row > 2 or brace_col > 2:
				continue
			if state.form[brace_row][brace_col] != null:
				brace_sides += 1
		for brace_delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var brace_row = row + brace_delta.x
			var brace_col = col + brace_delta.y
			if brace_row < 0 or brace_col < 0 or brace_row > 2 or brace_col > 2:
				continue
			if state.form[brace_row][brace_col] != null:
				brace_corners += 1
		if brace_sides > 0 and brace_corners > 0:
			guess += 4
		else:
			guess -= 1
		for brace_delta in [Vector2i(-1, -1), Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, -1), Vector2i(0, 1), Vector2i(1, -1), Vector2i(1, 0), Vector2i(1, 1)]:
			var near_row = row + brace_delta.x
			var near_col = col + brace_delta.y
			if near_row < 0 or near_col < 0 or near_row > 2 or near_col > 2:
				continue
			if state.form[near_row][near_col] == null:
				continue
			var was_corner = 0
			var was_side = 0
			var now_corner = 0
			var now_side = 0
			for corner_delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var look_row = near_row + corner_delta.x
				var look_col = near_col + corner_delta.y
				if look_row < 0 or look_col < 0 or look_row > 2 or look_col > 2:
					continue
				if state.form[look_row][look_col] != null or (look_row == row and look_col == col):
					now_corner += 1
					if not (look_row == row and look_col == col):
						was_corner += 1
			for side_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var look_row = near_row + side_delta.x
				var look_col = near_col + side_delta.y
				if look_row < 0 or look_col < 0 or look_row > 2 or look_col > 2:
					continue
				if state.form[look_row][look_col] != null or (look_row == row and look_col == col):
					now_side += 1
					if not (look_row == row and look_col == col):
						was_side += 1
			var was_brace = was_side > 0 and was_corner > 0
			var now_brace = now_side > 0 and now_corner > 0
			if now_brace and not was_brace:
				guess += 2
	if rule == "double_farther_back":
		var farther_back_row = row
		var farther_back_col = col - 5
		while farther_back_col < 0:
			farther_back_row -= 1
			farther_back_col += 3
		if farther_back_row < 0:
			guess -= 4
		elif state.form[farther_back_row][farther_back_col] != null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var farther_ahead_row = row
		var farther_ahead_col = col + 5
		while farther_ahead_col > 2:
			farther_ahead_row += 1
			farther_ahead_col -= 3
		if farther_ahead_row <= 2 and state.form[farther_ahead_row][farther_ahead_col] != null:
			var farther_helped = state.form[farther_ahead_row][farther_ahead_col]
			guess += _stamp_number(state, String(farther_helped["card_id"]), farther_ahead_row, farther_ahead_col)
	if rule == "drop_if_span_count":
		var span_filled = 0
		for span_row in 3:
			for span_col in 3:
				if state.form[span_row][span_col] != null:
					span_filled += 1
		var span_next = span_filled + 1
		if span_next == 5 or span_next == 6:
			guess -= 4
		elif span_filled == 5 or span_filled == 6:
			guess += 5
	if rule == "double_near_fill":
		var near_back_row = row
		var near_back_col = col - 3
		while near_back_col < 0:
			near_back_row -= 1
			near_back_col += 3
		if near_back_row < 0:
			guess -= 4
		elif state.form[near_back_row][near_back_col] != null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var near_ahead_row = row
		var near_ahead_col = col + 3
		while near_ahead_col > 2:
			near_ahead_row += 1
			near_ahead_col -= 3
		if near_ahead_row <= 2 and state.form[near_ahead_row][near_ahead_col] != null:
			var near_helped = state.form[near_ahead_row][near_ahead_col]
			guess += _stamp_number(state, String(near_helped["card_id"]), near_ahead_row, near_ahead_col)
	if rule == "yield_twin_pay":
		var twin_sides = 0
		for twin_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var twin_row = row + twin_delta.x
			var twin_col = col + twin_delta.y
			if twin_row < 0 or twin_col < 0 or twin_row > 2 or twin_col > 2:
				continue
			if state.form[twin_row][twin_col] != null:
				twin_sides += 1
		if twin_sides >= 2:
			guess += 4
		elif twin_sides == 1:
			guess += 1
		else:
			guess -= 1
		for twin_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var near_row = row + twin_delta.x
			var near_col = col + twin_delta.y
			if near_row < 0 or near_col < 0 or near_row > 2 or near_col > 2:
				continue
			if state.form[near_row][near_col] == null:
				continue
			var neighbor_sides = 0
			for neighbor_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var neighbor_row = near_row + neighbor_delta.x
				var neighbor_col = near_col + neighbor_delta.y
				if neighbor_row < 0 or neighbor_col < 0 or neighbor_row > 2 or neighbor_col > 2:
					continue
				if neighbor_row == row and neighbor_col == col:
					continue
				if state.form[neighbor_row][neighbor_col] != null:
					neighbor_sides += 1
			if neighbor_sides == 1:
				guess += 2
	if rule == "double_farther_gap":
		var gap_back_row = row
		var gap_back_col = col - 5
		while gap_back_col < 0:
			gap_back_row -= 1
			gap_back_col += 3
		if gap_back_row < 0:
			guess -= 4
		elif state.form[gap_back_row][gap_back_col] == null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var gap_ahead_row = row
		var gap_ahead_col = col + 5
		while gap_ahead_col > 2:
			gap_ahead_row += 1
			gap_ahead_col -= 3
		if gap_ahead_row <= 2 and state.form[gap_ahead_row][gap_ahead_col] != null:
			var gap_spoiled = state.form[gap_ahead_row][gap_ahead_col]
			guess -= _stamp_number(state, String(gap_spoiled["card_id"]), gap_ahead_row, gap_ahead_col)
	if rule == "drop_if_band_count":
		var band_filled = 0
		for band_row in 3:
			for band_col in 3:
				if state.form[band_row][band_col] != null:
					band_filled += 1
		var band_next = band_filled + 1
		if band_next == 4 or band_next == 5:
			guess -= 4
		elif band_filled == 4 or band_filled == 5:
			guess += 5
	if rule == "double_step_fill":
		var step_ahead_row = row
		var step_ahead_col = col + 2
		if step_ahead_col > 2:
			step_ahead_row += 1
			step_ahead_col -= 3
		if step_ahead_row > 2:
			guess -= 4
		elif state.form[step_ahead_row][step_ahead_col] != null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var step_back_row = row
		var step_back_col = col - 2
		if step_back_col < 0:
			step_back_row -= 1
			step_back_col += 3
		if step_back_row >= 0 and state.form[step_back_row][step_back_col] != null:
			var step_helped = state.form[step_back_row][step_back_col]
			guess += _stamp_number(state, String(step_helped["card_id"]), step_back_row, step_back_col)
	if rule == "yield_trio_pay":
		var trio_sides = 0
		for trio_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var trio_row = row + trio_delta.x
			var trio_col = col + trio_delta.y
			if trio_row < 0 or trio_col < 0 or trio_row > 2 or trio_col > 2:
				continue
			if state.form[trio_row][trio_col] != null:
				trio_sides += 1
		if trio_sides == 3:
			guess += 4
		else:
			guess -= 1
		for trio_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var near_row = row + trio_delta.x
			var near_col = col + trio_delta.y
			if near_row < 0 or near_col < 0 or near_row > 2 or near_col > 2:
				continue
			if state.form[near_row][near_col] == null:
				continue
			var neighbor_sides = 0
			for neighbor_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var neighbor_row = near_row + neighbor_delta.x
				var neighbor_col = near_col + neighbor_delta.y
				if neighbor_row < 0 or neighbor_col < 0 or neighbor_row > 2 or neighbor_col > 2:
					continue
				if neighbor_row == row and neighbor_col == col:
					continue
				if state.form[neighbor_row][neighbor_col] != null:
					neighbor_sides += 1
			if neighbor_sides == 2:
				guess += 2
	if rule == "double_long_gap":
		var long_back_row = row
		var long_back_col = col - 4
		while long_back_col < 0:
			long_back_row -= 1
			long_back_col += 3
		if long_back_row < 0:
			guess -= 4
		elif state.form[long_back_row][long_back_col] == null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var long_ahead_row = row
		var long_ahead_col = col + 4
		while long_ahead_col > 2:
			long_ahead_row += 1
			long_ahead_col -= 3
		if long_ahead_row <= 2 and state.form[long_ahead_row][long_ahead_col] != null:
			var long_spoiled = state.form[long_ahead_row][long_ahead_col]
			guess -= _stamp_number(state, String(long_spoiled["card_id"]), long_ahead_row, long_ahead_col)
	if rule == "drop_if_crest_count":
		var crest_filled = 0
		for crest_row in 3:
			for crest_col in 3:
				if state.form[crest_row][crest_col] != null:
					crest_filled += 1
		var crest_next = crest_filled + 1
		if crest_next == 6 or crest_next == 7:
			guess -= 4
		elif crest_filled == 6 or crest_filled == 7:
			guess += 5
	if rule == "double_leap_fill":
		var leap_ahead_row = row
		var leap_ahead_col = col + 6
		while leap_ahead_col > 2:
			leap_ahead_row += 1
			leap_ahead_col -= 3
		if leap_ahead_row > 2:
			guess -= 4
		elif state.form[leap_ahead_row][leap_ahead_col] != null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var leap_back_row = row
		var leap_back_col = col - 6
		while leap_back_col < 0:
			leap_back_row -= 1
			leap_back_col += 3
		if leap_back_row >= 0 and state.form[leap_back_row][leap_back_col] != null:
			var leap_helped = state.form[leap_back_row][leap_back_col]
			guess += _stamp_number(state, String(leap_helped["card_id"]), leap_back_row, leap_back_col)
	if rule == "yield_quad_pay":
		var quad_sides = 0
		for quad_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var quad_row = row + quad_delta.x
			var quad_col = col + quad_delta.y
			if quad_row < 0 or quad_col < 0 or quad_row > 2 or quad_col > 2:
				continue
			if state.form[quad_row][quad_col] != null:
				quad_sides += 1
		if quad_sides == 4:
			guess += 4
		else:
			guess -= 1
		for quad_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var near_row = row + quad_delta.x
			var near_col = col + quad_delta.y
			if near_row < 0 or near_col < 0 or near_row > 2 or near_col > 2:
				continue
			if state.form[near_row][near_col] == null:
				continue
			var neighbor_sides = 0
			for neighbor_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var neighbor_row = near_row + neighbor_delta.x
				var neighbor_col = near_col + neighbor_delta.y
				if neighbor_row < 0 or neighbor_col < 0 or neighbor_row > 2 or neighbor_col > 2:
					continue
				if neighbor_row == row and neighbor_col == col:
					continue
				if state.form[neighbor_row][neighbor_col] != null:
					neighbor_sides += 1
			if neighbor_sides == 3:
				guess += 2
	if rule == "double_deep_gap":
		var deep_back_row = row
		var deep_back_col = col - 6
		while deep_back_col < 0:
			deep_back_row -= 1
			deep_back_col += 3
		if deep_back_row < 0:
			guess -= 4
		elif state.form[deep_back_row][deep_back_col] == null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var deep_ahead_row = row
		var deep_ahead_col = col + 6
		while deep_ahead_col > 2:
			deep_ahead_row += 1
			deep_ahead_col -= 3
		if deep_ahead_row <= 2 and state.form[deep_ahead_row][deep_ahead_col] != null:
			var deep_spoiled = state.form[deep_ahead_row][deep_ahead_col]
			guess -= _stamp_number(state, String(deep_spoiled["card_id"]), deep_ahead_row, deep_ahead_col)
	if rule == "drop_if_peak_count":
		var peak_filled = 0
		for peak_row in 3:
			for peak_col in 3:
				if state.form[peak_row][peak_col] != null:
					peak_filled += 1
		var peak_next = peak_filled + 1
		if peak_next == 8 or peak_next == 9:
			guess -= 4
		elif peak_filled == 8 or peak_filled == 9:
			guess += 5
	if rule == "double_pitch_fill":
		var pitch_ahead_row = row
		var pitch_ahead_col = col + 7
		while pitch_ahead_col > 2:
			pitch_ahead_row += 1
			pitch_ahead_col -= 3
		if pitch_ahead_row > 2:
			guess -= 4
		elif state.form[pitch_ahead_row][pitch_ahead_col] != null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var pitch_back_row = row
		var pitch_back_col = col - 7
		while pitch_back_col < 0:
			pitch_back_row -= 1
			pitch_back_col += 3
		if pitch_back_row >= 0 and state.form[pitch_back_row][pitch_back_col] != null:
			var pitch_helped = state.form[pitch_back_row][pitch_back_col]
			guess += _stamp_number(state, String(pitch_helped["card_id"]), pitch_back_row, pitch_back_col)
	if rule == "yield_single_pay":
		var single_sides = 0
		for single_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var single_row = row + single_delta.x
			var single_col = col + single_delta.y
			if single_row < 0 or single_col < 0 or single_row > 2 or single_col > 2:
				continue
			if state.form[single_row][single_col] != null:
				single_sides += 1
		if single_sides == 1:
			guess += 4
		else:
			guess -= 1
		for single_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var near_row = row + single_delta.x
			var near_col = col + single_delta.y
			if near_row < 0 or near_col < 0 or near_row > 2 or near_col > 2:
				continue
			if state.form[near_row][near_col] == null:
				continue
			var neighbor_sides = 0
			for neighbor_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var neighbor_row = near_row + neighbor_delta.x
				var neighbor_col = near_col + neighbor_delta.y
				if neighbor_row < 0 or neighbor_col < 0 or neighbor_row > 2 or neighbor_col > 2:
					continue
				if neighbor_row == row and neighbor_col == col:
					continue
				if state.form[neighbor_row][neighbor_col] != null:
					neighbor_sides += 1
			if neighbor_sides == 0:
				guess += 2
			elif neighbor_sides >= 1:
				guess -= 2
	if rule == "double_pitch_gap":
		var gap_back_row = row
		var gap_back_col = col - 7
		while gap_back_col < 0:
			gap_back_row -= 1
			gap_back_col += 3
		if gap_back_row < 0:
			guess -= 4
		elif state.form[gap_back_row][gap_back_col] == null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var gap_ahead_row = row
		var gap_ahead_col = col + 7
		while gap_ahead_col > 2:
			gap_ahead_row += 1
			gap_ahead_col -= 3
		if gap_ahead_row <= 2 and state.form[gap_ahead_row][gap_ahead_col] != null:
			var gap_spoiled = state.form[gap_ahead_row][gap_ahead_col]
			guess -= _stamp_number(state, String(gap_spoiled["card_id"]), gap_ahead_row, gap_ahead_col)
	if rule == "drop_if_sill_count":
		var sill_filled = 0
		for sill_row in 3:
			for sill_col in 3:
				if state.form[sill_row][sill_col] != null:
					sill_filled += 1
		var sill_next = sill_filled + 1
		if sill_next == 0 or sill_next == 1:
			guess -= 4
		elif sill_filled == 0 or sill_filled == 1:
			guess += 5
	if rule == "double_reach_fill":
		var reach_ahead_row = row
		var reach_ahead_col = col + 8
		while reach_ahead_col > 2:
			reach_ahead_row += 1
			reach_ahead_col -= 3
		if reach_ahead_row > 2:
			guess -= 4
		elif state.form[reach_ahead_row][reach_ahead_col] != null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var reach_back_row = row
		var reach_back_col = col - 8
		while reach_back_col < 0:
			reach_back_row -= 1
			reach_back_col += 3
		if reach_back_row >= 0 and state.form[reach_back_row][reach_back_col] != null:
			var reach_helped = state.form[reach_back_row][reach_back_col]
			guess += _stamp_number(state, String(reach_helped["card_id"]), reach_back_row, reach_back_col)
	if rule == "yield_pair_pay":
		var pair_sides = 0
		for pair_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var pair_row = row + pair_delta.x
			var pair_col = col + pair_delta.y
			if pair_row < 0 or pair_col < 0 or pair_row > 2 or pair_col > 2:
				continue
			if state.form[pair_row][pair_col] != null:
				pair_sides += 1
		if pair_sides == 2:
			guess += 4
		else:
			guess -= 1
		for pair_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var near_row = row + pair_delta.x
			var near_col = col + pair_delta.y
			if near_row < 0 or near_col < 0 or near_row > 2 or near_col > 2:
				continue
			if state.form[near_row][near_col] == null:
				continue
			var neighbor_sides = 0
			for neighbor_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var neighbor_row = near_row + neighbor_delta.x
				var neighbor_col = near_col + neighbor_delta.y
				if neighbor_row < 0 or neighbor_col < 0 or neighbor_row > 2 or neighbor_col > 2:
					continue
				if neighbor_row == row and neighbor_col == col:
					continue
				if state.form[neighbor_row][neighbor_col] != null:
					neighbor_sides += 1
			if neighbor_sides == 1:
				guess += 2
			elif neighbor_sides == 2:
				guess -= 2
	if rule == "double_reach_gap":
		var reach_gap_back_row = row
		var reach_gap_back_col = col - 8
		while reach_gap_back_col < 0:
			reach_gap_back_row -= 1
			reach_gap_back_col += 3
		if reach_gap_back_row < 0:
			guess -= 4
		elif state.form[reach_gap_back_row][reach_gap_back_col] == null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var reach_gap_ahead_row = row
		var reach_gap_ahead_col = col + 8
		while reach_gap_ahead_col > 2:
			reach_gap_ahead_row += 1
			reach_gap_ahead_col -= 3
		if reach_gap_ahead_row <= 2 and state.form[reach_gap_ahead_row][reach_gap_ahead_col] != null:
			var reach_spoiled = state.form[reach_gap_ahead_row][reach_gap_ahead_col]
			guess -= _stamp_number(state, String(reach_spoiled["card_id"]), reach_gap_ahead_row, reach_gap_ahead_col)
	if rule == "drop_if_ridge_count":
		var ridge_filled = 0
		for ridge_row in 3:
			for ridge_col in 3:
				if state.form[ridge_row][ridge_col] != null:
					ridge_filled += 1
		var ridge_next = ridge_filled + 1
		if ridge_next == 2 or ridge_next == 3:
			guess -= 4
		elif ridge_filled == 2 or ridge_filled == 3:
			guess += 5
	if rule == "double_leap_blank":
		var leap_blank_ahead_row = row
		var leap_blank_ahead_col = col + 6
		while leap_blank_ahead_col > 2:
			leap_blank_ahead_row += 1
			leap_blank_ahead_col -= 3
		if leap_blank_ahead_row > 2:
			guess -= 4
		elif state.form[leap_blank_ahead_row][leap_blank_ahead_col] == null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var leap_blank_back_row = row
		var leap_blank_back_col = col - 6
		while leap_blank_back_col < 0:
			leap_blank_back_row -= 1
			leap_blank_back_col += 3
		if leap_blank_back_row >= 0 and state.form[leap_blank_back_row][leap_blank_back_col] != null:
			var leap_spoiled = state.form[leap_blank_back_row][leap_blank_back_col]
			guess -= _stamp_number(state, String(leap_spoiled["card_id"]), leap_blank_back_row, leap_blank_back_col)
	if rule == "yield_slant_pay":
		var slant_corners = 0
		for slant_delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var slant_row = row + slant_delta.x
			var slant_col = col + slant_delta.y
			if slant_row < 0 or slant_col < 0 or slant_row > 2 or slant_col > 2:
				continue
			if state.form[slant_row][slant_col] != null:
				slant_corners += 1
		if slant_corners == 1:
			guess += 4
		else:
			guess -= 1
		for slant_delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var slant_near_row = row + slant_delta.x
			var slant_near_col = col + slant_delta.y
			if slant_near_row < 0 or slant_near_col < 0 or slant_near_row > 2 or slant_near_col > 2:
				continue
			if state.form[slant_near_row][slant_near_col] == null:
				continue
			var other_corners = 0
			for other_delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var other_row = slant_near_row + other_delta.x
				var other_col = slant_near_col + other_delta.y
				if other_row < 0 or other_col < 0 or other_row > 2 or other_col > 2:
					continue
				if other_row == row and other_col == col:
					continue
				if state.form[other_row][other_col] != null:
					other_corners += 1
			if other_corners == 0:
				guess += 2
			elif other_corners == 1:
				guess -= 2
	if rule == "double_deep_back":
		var deep_back_row = row
		var deep_back_col = col - 6
		while deep_back_col < 0:
			deep_back_row -= 1
			deep_back_col += 3
		if deep_back_row < 0:
			guess -= 4
		elif state.form[deep_back_row][deep_back_col] != null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var deep_ahead_row = row
		var deep_ahead_col = col + 6
		while deep_ahead_col > 2:
			deep_ahead_row += 1
			deep_ahead_col -= 3
		if deep_ahead_row <= 2 and state.form[deep_ahead_row][deep_ahead_col] != null:
			var deep_helped = state.form[deep_ahead_row][deep_ahead_col]
			guess += _stamp_number(state, String(deep_helped["card_id"]), deep_ahead_row, deep_ahead_col)
	if rule == "drop_if_ledge_count":
		var ledge_filled = 0
		for ledge_row in 3:
			for ledge_col in 3:
				if state.form[ledge_row][ledge_col] != null:
					ledge_filled += 1
		var ledge_next = ledge_filled + 1
		if ledge_next == 3 or ledge_next == 4:
			guess -= 4
		elif ledge_filled == 3 or ledge_filled == 4:
			guess += 5
	if rule == "double_pitch_blank":
		var pitch_blank_ahead_row = row
		var pitch_blank_ahead_col = col + 7
		while pitch_blank_ahead_col > 2:
			pitch_blank_ahead_row += 1
			pitch_blank_ahead_col -= 3
		if pitch_blank_ahead_row > 2:
			guess -= 4
		elif state.form[pitch_blank_ahead_row][pitch_blank_ahead_col] == null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var pitch_blank_back_row = row
		var pitch_blank_back_col = col - 7
		while pitch_blank_back_col < 0:
			pitch_blank_back_row -= 1
			pitch_blank_back_col += 3
		if pitch_blank_back_row >= 0 and state.form[pitch_blank_back_row][pitch_blank_back_col] != null:
			var pitch_spoiled = state.form[pitch_blank_back_row][pitch_blank_back_col]
			guess -= _stamp_number(state, String(pitch_spoiled["card_id"]), pitch_blank_back_row, pitch_blank_back_col)
	if rule == "yield_wedge_pay":
		var wedge_corners = 0
		for wedge_delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var wedge_row = row + wedge_delta.x
			var wedge_col = col + wedge_delta.y
			if wedge_row < 0 or wedge_col < 0 or wedge_row > 2 or wedge_col > 2:
				continue
			if state.form[wedge_row][wedge_col] != null:
				wedge_corners += 1
		if wedge_corners == 2:
			guess += 4
		else:
			guess -= 1
		for wedge_delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var wedge_near_row = row + wedge_delta.x
			var wedge_near_col = col + wedge_delta.y
			if wedge_near_row < 0 or wedge_near_col < 0 or wedge_near_row > 2 or wedge_near_col > 2:
				continue
			if state.form[wedge_near_row][wedge_near_col] == null:
				continue
			var wedge_other = 0
			for wedge_other_delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var wedge_other_row = wedge_near_row + wedge_other_delta.x
				var wedge_other_col = wedge_near_col + wedge_other_delta.y
				if wedge_other_row < 0 or wedge_other_col < 0 or wedge_other_row > 2 or wedge_other_col > 2:
					continue
				if wedge_other_row == row and wedge_other_col == col:
					continue
				if state.form[wedge_other_row][wedge_other_col] != null:
					wedge_other += 1
			if wedge_other == 1:
				guess += 2
			elif wedge_other == 2:
				guess -= 2
	if rule == "double_pitch_back":
		var pitch_back_row = row
		var pitch_back_col = col - 7
		while pitch_back_col < 0:
			pitch_back_row -= 1
			pitch_back_col += 3
		if pitch_back_row < 0:
			guess -= 4
		elif state.form[pitch_back_row][pitch_back_col] != null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var pitch_ahead_row = row
		var pitch_ahead_col = col + 7
		while pitch_ahead_col > 2:
			pitch_ahead_row += 1
			pitch_ahead_col -= 3
		if pitch_ahead_row <= 2 and state.form[pitch_ahead_row][pitch_ahead_col] != null:
			var pitch_helped = state.form[pitch_ahead_row][pitch_ahead_col]
			guess += _stamp_number(state, String(pitch_helped["card_id"]), pitch_ahead_row, pitch_ahead_col)
	if rule == "drop_if_brow_count":
		var brow_filled = 0
		for brow_row in 3:
			for brow_col in 3:
				if state.form[brow_row][brow_col] != null:
					brow_filled += 1
		var brow_next = brow_filled + 1
		if brow_next == 7 or brow_next == 8:
			guess -= 4
		elif brow_filled == 7 or brow_filled == 8:
			guess += 5
	if rule == "double_reach_blank":
		var reach_blank_ahead_row = row
		var reach_blank_ahead_col = col + 8
		while reach_blank_ahead_col > 2:
			reach_blank_ahead_row += 1
			reach_blank_ahead_col -= 3
		if reach_blank_ahead_row > 2:
			guess -= 4
		elif state.form[reach_blank_ahead_row][reach_blank_ahead_col] == null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var reach_blank_back_row = row
		var reach_blank_back_col = col - 8
		while reach_blank_back_col < 0:
			reach_blank_back_row -= 1
			reach_blank_back_col += 3
		if reach_blank_back_row >= 0 and state.form[reach_blank_back_row][reach_blank_back_col] != null:
			var reach_spoiled = state.form[reach_blank_back_row][reach_blank_back_col]
			guess -= _stamp_number(state, String(reach_spoiled["card_id"]), reach_blank_back_row, reach_blank_back_col)
	if rule == "yield_apex_pay":
		var apex_corners = 0
		for apex_delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var apex_row = row + apex_delta.x
			var apex_col = col + apex_delta.y
			if apex_row < 0 or apex_col < 0 or apex_row > 2 or apex_col > 2:
				continue
			if state.form[apex_row][apex_col] != null:
				apex_corners += 1
		if apex_corners == 3:
			guess += 4
		else:
			guess -= 1
		for apex_delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var apex_near_row = row + apex_delta.x
			var apex_near_col = col + apex_delta.y
			if apex_near_row < 0 or apex_near_col < 0 or apex_near_row > 2 or apex_near_col > 2:
				continue
			if state.form[apex_near_row][apex_near_col] == null:
				continue
			var apex_other = 0
			for apex_other_delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var apex_other_row = apex_near_row + apex_other_delta.x
				var apex_other_col = apex_near_col + apex_other_delta.y
				if apex_other_row < 0 or apex_other_col < 0 or apex_other_row > 2 or apex_other_col > 2:
					continue
				if apex_other_row == row and apex_other_col == col:
					continue
				if state.form[apex_other_row][apex_other_col] != null:
					apex_other += 1
			if apex_other == 2:
				guess += 2
			elif apex_other == 3:
				guess -= 2
	if rule == "double_reach_back":
		var reach_back_row = row
		var reach_back_col = col - 8
		while reach_back_col < 0:
			reach_back_row -= 1
			reach_back_col += 3
		if reach_back_row < 0:
			guess -= 4
		elif state.form[reach_back_row][reach_back_col] != null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var reach_ahead_row = row
		var reach_ahead_col = col + 8
		while reach_ahead_col > 2:
			reach_ahead_row += 1
			reach_ahead_col -= 3
		if reach_ahead_row <= 2 and state.form[reach_ahead_row][reach_ahead_col] != null:
			var reach_helped = state.form[reach_ahead_row][reach_ahead_col]
			guess += _stamp_number(state, String(reach_helped["card_id"]), reach_ahead_row, reach_ahead_col)
	if rule == "drop_if_cleft_count":
		var cleft_filled = 0
		for cleft_row in 3:
			for cleft_col in 3:
				if state.form[cleft_row][cleft_col] != null:
					cleft_filled += 1
		var cleft_next = cleft_filled + 1
		if cleft_next == 0 or cleft_next == 2:
			guess -= 4
		elif cleft_filled == 0 or cleft_filled == 2:
			guess += 5
	if rule == "double_pace_blank":
		var pace_blank_ahead_row = row
		var pace_blank_ahead_col = col + 1
		while pace_blank_ahead_col > 2:
			pace_blank_ahead_row += 1
			pace_blank_ahead_col -= 3
		if pace_blank_ahead_row > 2:
			guess -= 4
		elif state.form[pace_blank_ahead_row][pace_blank_ahead_col] == null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var pace_spoiled_row = row
		var pace_spoiled_col = col - 1
		while pace_spoiled_col < 0:
			pace_spoiled_row -= 1
			pace_spoiled_col += 3
		if pace_spoiled_row >= 0 and state.form[pace_spoiled_row][pace_spoiled_col] != null:
			var pace_spoiled = state.form[pace_spoiled_row][pace_spoiled_col]
			guess -= _stamp_number(state, String(pace_spoiled["card_id"]), pace_spoiled_row, pace_spoiled_col)
	if rule == "yield_vault_pay":
		var vault_corners = 0
		for vault_delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var vault_row = row + vault_delta.x
			var vault_col = col + vault_delta.y
			if vault_row < 0 or vault_col < 0 or vault_row > 2 or vault_col > 2:
				continue
			if state.form[vault_row][vault_col] != null:
				vault_corners += 1
		if vault_corners == 4:
			guess += 4
		else:
			guess -= 1
		for vault_delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var vault_near_row = row + vault_delta.x
			var vault_near_col = col + vault_delta.y
			if vault_near_row < 0 or vault_near_col < 0 or vault_near_row > 2 or vault_near_col > 2:
				continue
			if state.form[vault_near_row][vault_near_col] == null:
				continue
			var vault_other = 0
			for vault_other_delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var vault_other_row = vault_near_row + vault_other_delta.x
				var vault_other_col = vault_near_col + vault_other_delta.y
				if vault_other_row < 0 or vault_other_col < 0 or vault_other_row > 2 or vault_other_col > 2:
					continue
				if vault_other_row == row and vault_other_col == col:
					continue
				if state.form[vault_other_row][vault_other_col] != null:
					vault_other += 1
			if vault_other == 3:
				guess += 2
			elif vault_other == 4:
				guess -= 2
	if rule == "double_pace_back":
		var pace_back_row = row
		var pace_back_col = col - 1
		while pace_back_col < 0:
			pace_back_row -= 1
			pace_back_col += 3
		if pace_back_row < 0:
			guess -= 4
		elif state.form[pace_back_row][pace_back_col] != null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var pace_ahead_row = row
		var pace_ahead_col = col + 1
		while pace_ahead_col > 2:
			pace_ahead_row += 1
			pace_ahead_col -= 3
		if pace_ahead_row <= 2 and state.form[pace_ahead_row][pace_ahead_col] != null:
			var pace_helped = state.form[pace_ahead_row][pace_ahead_col]
			guess += _stamp_number(state, String(pace_helped["card_id"]), pace_ahead_row, pace_ahead_col)
	if rule == "drop_if_notch_count":
		var notch_filled = 0
		for notch_row in 3:
			for notch_col in 3:
				if state.form[notch_row][notch_col] != null:
					notch_filled += 1
		var notch_next = notch_filled + 1
		if notch_next == 1 or notch_next == 3:
			guess -= 4
		elif notch_filled == 1 or notch_filled == 3:
			guess += 5
	if rule == "double_pace_fill":
		var pace_fill_ahead_row = row
		var pace_fill_ahead_col = col + 1
		while pace_fill_ahead_col > 2:
			pace_fill_ahead_row += 1
			pace_fill_ahead_col -= 3
		if pace_fill_ahead_row > 2:
			guess -= 4
		elif state.form[pace_fill_ahead_row][pace_fill_ahead_col] != null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var pace_helped_row = row
		var pace_helped_col = col - 1
		while pace_helped_col < 0:
			pace_helped_row -= 1
			pace_helped_col += 3
		if pace_helped_row >= 0 and state.form[pace_helped_row][pace_helped_col] != null:
			var pace_helped = state.form[pace_helped_row][pace_helped_col]
			guess += _stamp_number(state, String(pace_helped["card_id"]), pace_helped_row, pace_helped_col)
	if rule == "yield_bare_pay":
		var bare_corners = 0
		for bare_delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var bare_row = row + bare_delta.x
			var bare_col = col + bare_delta.y
			if bare_row < 0 or bare_col < 0 or bare_row > 2 or bare_col > 2:
				continue
			if state.form[bare_row][bare_col] != null:
				bare_corners += 1
		if bare_corners == 0:
			guess += 4
		else:
			guess -= 1
		for bare_delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var bare_near_row = row + bare_delta.x
			var bare_near_col = col + bare_delta.y
			if bare_near_row < 0 or bare_near_col < 0 or bare_near_row > 2 or bare_near_col > 2:
				continue
			if state.form[bare_near_row][bare_near_col] == null:
				continue
			var bare_other = 0
			for bare_other_delta in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var bare_other_row = bare_near_row + bare_other_delta.x
				var bare_other_col = bare_near_col + bare_other_delta.y
				if bare_other_row < 0 or bare_other_col < 0 or bare_other_row > 2 or bare_other_col > 2:
					continue
				if bare_other_row == row and bare_other_col == col:
					continue
				if state.form[bare_other_row][bare_other_col] != null:
					bare_other += 1
			if bare_other == 0:
				guess -= 2
	if rule == "double_pace_gap":
		var pace_gap_row = row
		var pace_gap_col = col - 1
		while pace_gap_col < 0:
			pace_gap_row -= 1
			pace_gap_col += 3
		if pace_gap_row < 0:
			guess -= 4
		elif state.form[pace_gap_row][pace_gap_col] == null:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var pace_spoiled_row = row
		var pace_spoiled_col = col + 1
		while pace_spoiled_col > 2:
			pace_spoiled_row += 1
			pace_spoiled_col -= 3
		if pace_spoiled_row <= 2 and state.form[pace_spoiled_row][pace_spoiled_col] != null:
			var pace_spoiled = state.form[pace_spoiled_row][pace_spoiled_col]
			guess -= _stamp_number(state, String(pace_spoiled["card_id"]), pace_spoiled_row, pace_spoiled_col)
	if rule == "drop_if_rift_count":
		var rift_filled = 0
		for rift_row in 3:
			for rift_col in 3:
				if state.form[rift_row][rift_col] != null:
					rift_filled += 1
		var rift_next = rift_filled + 1
		if rift_next == 2 or rift_next == 4:
			guess -= 4
		elif rift_filled == 2 or rift_filled == 4:
			guess += 5
	if rule == "double_twin_blank":
		var twin_before_row = row
		var twin_before_col = col - 1
		while twin_before_col < 0:
			twin_before_row -= 1
			twin_before_col += 3
		var twin_after_row = row
		var twin_after_col = col + 1
		while twin_after_col > 2:
			twin_after_row += 1
			twin_after_col -= 3
		var twin_before_empty = twin_before_row >= 0 and state.form[twin_before_row][twin_before_col] == null
		var twin_after_empty = twin_after_row <= 2 and state.form[twin_after_row][twin_after_col] == null
		if twin_before_empty and twin_after_empty:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		if twin_before_row >= 0 and state.form[twin_before_row][twin_before_col] != null:
			var twin_earlier = state.form[twin_before_row][twin_before_col]
			var twin_earlier_before_row = twin_before_row
			var twin_earlier_before_col = twin_before_col - 1
			while twin_earlier_before_col < 0:
				twin_earlier_before_row -= 1
				twin_earlier_before_col += 3
			if twin_earlier_before_row >= 0 and state.form[twin_earlier_before_row][twin_earlier_before_col] == null:
				guess -= _stamp_number(state, String(twin_earlier["card_id"]), twin_before_row, twin_before_col)
		if twin_after_row <= 2 and state.form[twin_after_row][twin_after_col] != null:
			var twin_later = state.form[twin_after_row][twin_after_col]
			var twin_later_after_row = twin_after_row
			var twin_later_after_col = twin_after_col + 1
			while twin_later_after_col > 2:
				twin_later_after_row += 1
				twin_later_after_col -= 3
			if twin_later_after_row <= 2 and state.form[twin_later_after_row][twin_later_after_col] == null:
				guess -= _stamp_number(state, String(twin_later["card_id"]), twin_after_row, twin_after_col)
	if rule == "yield_flank_pay":
		var flank_sides = 0
		for flank_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var flank_row = row + flank_delta.x
			var flank_col = col + flank_delta.y
			if flank_row < 0 or flank_col < 0 or flank_row > 2 or flank_col > 2:
				continue
			if state.form[flank_row][flank_col] != null:
				flank_sides += 1
		if flank_sides == 1:
			guess += 4
		else:
			guess -= 1
		for flank_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var flank_near_row = row + flank_delta.x
			var flank_near_col = col + flank_delta.y
			if flank_near_row < 0 or flank_near_col < 0 or flank_near_row > 2 or flank_near_col > 2:
				continue
			if state.form[flank_near_row][flank_near_col] == null:
				continue
			var flank_other = 0
			for flank_other_delta in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var flank_other_row = flank_near_row + flank_other_delta.x
				var flank_other_col = flank_near_col + flank_other_delta.y
				if flank_other_row < 0 or flank_other_col < 0 or flank_other_row > 2 or flank_other_col > 2:
					continue
				if flank_other_row == row and flank_other_col == col:
					continue
				if state.form[flank_other_row][flank_other_col] != null:
					flank_other += 1
			if flank_other == 0:
				guess += 2
			elif flank_other == 1:
				guess -= 2
	if rule == "double_twin_fill":
		var fill_before_row = row
		var fill_before_col = col - 1
		while fill_before_col < 0:
			fill_before_row -= 1
			fill_before_col += 3
		var fill_after_row = row
		var fill_after_col = col + 1
		while fill_after_col > 2:
			fill_after_row += 1
			fill_after_col -= 3
		var fill_before_filled = fill_before_row >= 0 and state.form[fill_before_row][fill_before_col] != null
		var fill_after_filled = fill_after_row <= 2 and state.form[fill_after_row][fill_after_col] != null
		if fill_before_filled and fill_after_filled:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		if fill_before_filled:
			var fill_earlier = state.form[fill_before_row][fill_before_col]
			var fill_earlier_before_row = fill_before_row
			var fill_earlier_before_col = fill_before_col - 1
			while fill_earlier_before_col < 0:
				fill_earlier_before_row -= 1
				fill_earlier_before_col += 3
			if fill_earlier_before_row >= 0 and state.form[fill_earlier_before_row][fill_earlier_before_col] != null:
				guess += _stamp_number(state, String(fill_earlier["card_id"]), fill_before_row, fill_before_col)
		if fill_after_filled:
			var fill_later = state.form[fill_after_row][fill_after_col]
			var fill_later_after_row = fill_after_row
			var fill_later_after_col = fill_after_col + 1
			while fill_later_after_col > 2:
				fill_later_after_row += 1
				fill_later_after_col -= 3
			if fill_later_after_row <= 2 and state.form[fill_later_after_row][fill_later_after_col] != null:
				guess += _stamp_number(state, String(fill_later["card_id"]), fill_after_row, fill_after_col)
	if rule == "drop_if_split_count":
		var split_filled = 0
		for split_row in 3:
			for split_col in 3:
				if state.form[split_row][split_col] != null:
					split_filled += 1
		var split_next = split_filled + 1
		if split_next == 3 or split_next == 5:
			guess -= 4
		elif split_filled == 3 or split_filled == 5:
			guess += 5
	if rule == "double_skew_blank":
		var skew_before_row = row
		var skew_before_col = col - 1
		while skew_before_col < 0:
			skew_before_row -= 1
			skew_before_col += 3
		var skew_after_row = row
		var skew_after_col = col + 1
		while skew_after_col > 2:
			skew_after_row += 1
			skew_after_col -= 3
		var skew_before_filled = skew_before_row >= 0 and state.form[skew_before_row][skew_before_col] != null
		var skew_after_empty = skew_after_row <= 2 and state.form[skew_after_row][skew_after_col] == null
		if skew_before_filled and skew_after_empty:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		if skew_before_row >= 0 and state.form[skew_before_row][skew_before_col] != null:
			var skew_earlier = state.form[skew_before_row][skew_before_col]
			var skew_earlier_before_row = skew_before_row
			var skew_earlier_before_col = skew_before_col - 1
			while skew_earlier_before_col < 0:
				skew_earlier_before_row -= 1
				skew_earlier_before_col += 3
			if skew_earlier_before_row >= 0 and state.form[skew_earlier_before_row][skew_earlier_before_col] != null:
				guess -= _stamp_number(state, String(skew_earlier["card_id"]), skew_before_row, skew_before_col)
		if skew_after_row <= 2 and state.form[skew_after_row][skew_after_col] != null:
			var skew_later = state.form[skew_after_row][skew_after_col]
			var skew_later_after_row = skew_after_row
			var skew_later_after_col = skew_after_col + 1
			while skew_later_after_col > 2:
				skew_later_after_row += 1
				skew_later_after_col -= 3
			if skew_later_after_row <= 2 and state.form[skew_later_after_row][skew_later_after_col] == null:
				guess += _stamp_number(state, String(skew_later["card_id"]), skew_after_row, skew_after_col)
	if rule == "yield_hinge_pay":
		var hinge_sides = 0
		var hinge_corners = 0
		for hinge_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var hinge_row = row + hinge_side.x
			var hinge_col = col + hinge_side.y
			if hinge_row < 0 or hinge_col < 0 or hinge_row > 2 or hinge_col > 2:
				continue
			if state.form[hinge_row][hinge_col] != null:
				hinge_sides += 1
		for hinge_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var hinge_corner_row = row + hinge_corner.x
			var hinge_corner_col = col + hinge_corner.y
			if hinge_corner_row < 0 or hinge_corner_col < 0 or hinge_corner_row > 2 or hinge_corner_col > 2:
				continue
			if state.form[hinge_corner_row][hinge_corner_col] != null:
				hinge_corners += 1
		if hinge_sides == 1 and hinge_corners == 1:
			guess += 4
		else:
			guess -= 1
		for hinge_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var hinge_near_row = row + hinge_side.x
			var hinge_near_col = col + hinge_side.y
			if hinge_near_row < 0 or hinge_near_col < 0 or hinge_near_row > 2 or hinge_near_col > 2:
				continue
			if state.form[hinge_near_row][hinge_near_col] == null:
				continue
			var hinge_other_sides = 0
			var hinge_other_corners = 0
			for hinge_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var hinge_other_row = hinge_near_row + hinge_other.x
				var hinge_other_col = hinge_near_col + hinge_other.y
				if hinge_other_row < 0 or hinge_other_col < 0 or hinge_other_row > 2 or hinge_other_col > 2:
					continue
				if hinge_other_row == row and hinge_other_col == col:
					continue
				if state.form[hinge_other_row][hinge_other_col] != null:
					hinge_other_sides += 1
			for hinge_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var hinge_other_row = hinge_near_row + hinge_other.x
				var hinge_other_col = hinge_near_col + hinge_other.y
				if hinge_other_row < 0 or hinge_other_col < 0 or hinge_other_row > 2 or hinge_other_col > 2:
					continue
				if state.form[hinge_other_row][hinge_other_col] != null:
					hinge_other_corners += 1
			if hinge_other_sides == 0 and hinge_other_corners == 1:
				guess += 2
			elif hinge_other_sides == 1 and hinge_other_corners == 1:
				guess -= 2
		for hinge_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var hinge_near_row = row + hinge_corner.x
			var hinge_near_col = col + hinge_corner.y
			if hinge_near_row < 0 or hinge_near_col < 0 or hinge_near_row > 2 or hinge_near_col > 2:
				continue
			if state.form[hinge_near_row][hinge_near_col] == null:
				continue
			var hinge_other_sides = 0
			var hinge_other_corners = 0
			for hinge_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var hinge_other_row = hinge_near_row + hinge_other.x
				var hinge_other_col = hinge_near_col + hinge_other.y
				if hinge_other_row < 0 or hinge_other_col < 0 or hinge_other_row > 2 or hinge_other_col > 2:
					continue
				if state.form[hinge_other_row][hinge_other_col] != null:
					hinge_other_sides += 1
			for hinge_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var hinge_other_row = hinge_near_row + hinge_other.x
				var hinge_other_col = hinge_near_col + hinge_other.y
				if hinge_other_row < 0 or hinge_other_col < 0 or hinge_other_row > 2 or hinge_other_col > 2:
					continue
				if hinge_other_row == row and hinge_other_col == col:
					continue
				if state.form[hinge_other_row][hinge_other_col] != null:
					hinge_other_corners += 1
			if hinge_other_corners == 0 and hinge_other_sides == 1:
				guess += 2
			elif hinge_other_corners == 1 and hinge_other_sides == 1:
				guess -= 2
	if rule == "double_skew_fill":
		var fill_before_row = row
		var fill_before_col = col - 1
		while fill_before_col < 0:
			fill_before_row -= 1
			fill_before_col += 3
		var fill_after_row = row
		var fill_after_col = col + 1
		while fill_after_col > 2:
			fill_after_row += 1
			fill_after_col -= 3
		var fill_before_empty = fill_before_row >= 0 and state.form[fill_before_row][fill_before_col] == null
		var fill_after_filled = fill_after_row <= 2 and state.form[fill_after_row][fill_after_col] != null
		if fill_before_empty and fill_after_filled:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		if fill_before_row >= 0 and state.form[fill_before_row][fill_before_col] != null:
			var fill_earlier = state.form[fill_before_row][fill_before_col]
			var fill_earlier_before_row = fill_before_row
			var fill_earlier_before_col = fill_before_col - 1
			while fill_earlier_before_col < 0:
				fill_earlier_before_row -= 1
				fill_earlier_before_col += 3
			if fill_earlier_before_row >= 0 and state.form[fill_earlier_before_row][fill_earlier_before_col] == null:
				guess += _stamp_number(state, String(fill_earlier["card_id"]), fill_before_row, fill_before_col)
		if fill_after_filled:
			var fill_later = state.form[fill_after_row][fill_after_col]
			guess -= _stamp_number(state, String(fill_later["card_id"]), fill_after_row, fill_after_col)
	if rule == "drop_if_stride_count":
		var stride_filled = 0
		for stride_row in 3:
			for stride_col in 3:
				if state.form[stride_row][stride_col] != null:
					stride_filled += 1
		var stride_next = stride_filled + 1
		if stride_next == 4 or stride_next == 6:
			guess -= 4
		elif stride_filled == 4 or stride_filled == 6:
			guess += 5
	if rule == "double_stride_blank":
		var blank_before_row = row
		var blank_before_col = col - 2
		if blank_before_col < 0:
			blank_before_row -= 1
			blank_before_col += 3
		var blank_after_row = row
		var blank_after_col = col + 2
		if blank_after_col > 2:
			blank_after_row += 1
			blank_after_col -= 3
		var blank_before_filled = blank_before_row >= 0 and state.form[blank_before_row][blank_before_col] != null
		var blank_after_empty = blank_after_row <= 2 and state.form[blank_after_row][blank_after_col] == null
		if blank_before_filled and blank_after_empty:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		if blank_before_filled:
			var blank_earlier = state.form[blank_before_row][blank_before_col]
			var blank_earlier_before_row = blank_before_row
			var blank_earlier_before_col = blank_before_col - 2
			if blank_earlier_before_col < 0:
				blank_earlier_before_row -= 1
				blank_earlier_before_col += 3
			if blank_earlier_before_row >= 0 and state.form[blank_earlier_before_row][blank_earlier_before_col] != null:
				guess -= _stamp_number(state, String(blank_earlier["card_id"]), blank_before_row, blank_before_col)
		if blank_after_row <= 2 and state.form[blank_after_row][blank_after_col] != null:
			var blank_later = state.form[blank_after_row][blank_after_col]
			var blank_later_after_row = blank_after_row
			var blank_later_after_col = blank_after_col + 2
			if blank_later_after_col > 2:
				blank_later_after_row += 1
				blank_later_after_col -= 3
			if blank_later_after_row <= 2 and state.form[blank_later_after_row][blank_later_after_col] == null:
				guess += _stamp_number(state, String(blank_later["card_id"]), blank_after_row, blank_after_col)
	if rule == "yield_bevel_pay":
		var bevel_sides = 0
		var bevel_corners = 0
		for bevel_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var bevel_side_row = row + bevel_side.x
			var bevel_side_col = col + bevel_side.y
			if bevel_side_row < 0 or bevel_side_col < 0 or bevel_side_row > 2 or bevel_side_col > 2:
				continue
			if state.form[bevel_side_row][bevel_side_col] != null:
				bevel_sides += 1
		for bevel_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var bevel_corner_row = row + bevel_corner.x
			var bevel_corner_col = col + bevel_corner.y
			if bevel_corner_row < 0 or bevel_corner_col < 0 or bevel_corner_row > 2 or bevel_corner_col > 2:
				continue
			if state.form[bevel_corner_row][bevel_corner_col] != null:
				bevel_corners += 1
		if bevel_sides == 1 and bevel_corners == 2:
			guess += 4
		else:
			guess -= 1
		for bevel_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var bevel_near_row = row + bevel_side.x
			var bevel_near_col = col + bevel_side.y
			if bevel_near_row < 0 or bevel_near_col < 0 or bevel_near_row > 2 or bevel_near_col > 2:
				continue
			if state.form[bevel_near_row][bevel_near_col] == null:
				continue
			var bevel_other_sides = 0
			var bevel_other_corners = 0
			for bevel_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var bevel_other_row = bevel_near_row + bevel_other.x
				var bevel_other_col = bevel_near_col + bevel_other.y
				if bevel_other_row < 0 or bevel_other_col < 0 or bevel_other_row > 2 or bevel_other_col > 2:
					continue
				if bevel_other_row == row and bevel_other_col == col:
					continue
				if state.form[bevel_other_row][bevel_other_col] != null:
					bevel_other_sides += 1
			for bevel_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var bevel_other_row = bevel_near_row + bevel_other.x
				var bevel_other_col = bevel_near_col + bevel_other.y
				if bevel_other_row < 0 or bevel_other_col < 0 or bevel_other_row > 2 or bevel_other_col > 2:
					continue
				if state.form[bevel_other_row][bevel_other_col] != null:
					bevel_other_corners += 1
			if bevel_other_sides == 0 and bevel_other_corners == 2:
				guess += 2
			elif bevel_other_sides == 1 and bevel_other_corners == 2:
				guess -= 2
		for bevel_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var bevel_diag_row = row + bevel_corner.x
			var bevel_diag_col = col + bevel_corner.y
			if bevel_diag_row < 0 or bevel_diag_col < 0 or bevel_diag_row > 2 or bevel_diag_col > 2:
				continue
			if state.form[bevel_diag_row][bevel_diag_col] == null:
				continue
			var bevel_diag_sides = 0
			var bevel_diag_corners = 0
			for bevel_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var bevel_other_row = bevel_diag_row + bevel_other.x
				var bevel_other_col = bevel_diag_col + bevel_other.y
				if bevel_other_row < 0 or bevel_other_col < 0 or bevel_other_row > 2 or bevel_other_col > 2:
					continue
				if state.form[bevel_other_row][bevel_other_col] != null:
					bevel_diag_sides += 1
			for bevel_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var bevel_other_row = bevel_diag_row + bevel_other.x
				var bevel_other_col = bevel_diag_col + bevel_other.y
				if bevel_other_row < 0 or bevel_other_col < 0 or bevel_other_row > 2 or bevel_other_col > 2:
					continue
				if bevel_other_row == row and bevel_other_col == col:
					continue
				if state.form[bevel_other_row][bevel_other_col] != null:
					bevel_diag_corners += 1
			if bevel_diag_corners == 1 and bevel_diag_sides == 1:
				guess += 2
			elif bevel_diag_corners == 2 and bevel_diag_sides == 1:
				guess -= 2
	if rule == "double_stride_fill":
		var fill_before_row = row
		var fill_before_col = col - 2
		if fill_before_col < 0:
			fill_before_row -= 1
			fill_before_col += 3
		var fill_after_row = row
		var fill_after_col = col + 2
		if fill_after_col > 2:
			fill_after_row += 1
			fill_after_col -= 3
		var fill_before_empty = fill_before_row >= 0 and state.form[fill_before_row][fill_before_col] == null
		var fill_after_filled = fill_after_row <= 2 and state.form[fill_after_row][fill_after_col] != null
		if fill_before_empty and fill_after_filled:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		if fill_before_row >= 0 and state.form[fill_before_row][fill_before_col] != null:
			var fill_earlier = state.form[fill_before_row][fill_before_col]
			var fill_earlier_before_row = fill_before_row
			var fill_earlier_before_col = fill_before_col - 2
			if fill_earlier_before_col < 0:
				fill_earlier_before_row -= 1
				fill_earlier_before_col += 3
			if fill_earlier_before_row >= 0 and state.form[fill_earlier_before_row][fill_earlier_before_col] == null:
				guess += _stamp_number(state, String(fill_earlier["card_id"]), fill_before_row, fill_before_col)
		if fill_after_filled:
			var fill_later = state.form[fill_after_row][fill_after_col]
			guess -= _stamp_number(state, String(fill_later["card_id"]), fill_after_row, fill_after_col)
	if rule == "drop_if_helm_count":
		var helm_filled = 0
		for helm_row in 3:
			for helm_col in 3:
				if state.form[helm_row][helm_col] != null:
					helm_filled += 1
		var helm_next = helm_filled + 1
		if helm_next == 5 or helm_next == 7:
			guess -= 4
		elif helm_filled == 5 or helm_filled == 7:
			guess += 5
	if rule == "double_helm_blank":
		var helm_before_filled = row > 0 and state.form[row - 1][col] != null
		var helm_after_empty = row < 2 and state.form[row + 1][col] == null
		if helm_before_filled and helm_after_empty:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		if helm_before_filled:
			var helm_earlier = state.form[row - 1][col]
			if row - 1 > 0 and state.form[row - 2][col] != null:
				guess -= _stamp_number(state, String(helm_earlier["card_id"]), row - 1, col)
		if row < 2 and state.form[row + 1][col] != null:
			var helm_later = state.form[row + 1][col]
			if row + 1 < 2 and state.form[row + 2][col] == null:
				guess += _stamp_number(state, String(helm_later["card_id"]), row + 1, col)
	if rule == "yield_chevron_pay":
		var chevron_sides = 0
		var chevron_corners = 0
		for chevron_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var chevron_side_row = row + chevron_side.x
			var chevron_side_col = col + chevron_side.y
			if chevron_side_row < 0 or chevron_side_col < 0 or chevron_side_row > 2 or chevron_side_col > 2:
				continue
			if state.form[chevron_side_row][chevron_side_col] != null:
				chevron_sides += 1
		for chevron_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var chevron_corner_row = row + chevron_corner.x
			var chevron_corner_col = col + chevron_corner.y
			if chevron_corner_row < 0 or chevron_corner_col < 0 or chevron_corner_row > 2 or chevron_corner_col > 2:
				continue
			if state.form[chevron_corner_row][chevron_corner_col] != null:
				chevron_corners += 1
		if chevron_sides == 0 and chevron_corners == 2:
			guess += 4
		else:
			guess -= 1
		for chevron_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var chevron_near_row = row + chevron_side.x
			var chevron_near_col = col + chevron_side.y
			if chevron_near_row < 0 or chevron_near_col < 0 or chevron_near_row > 2 or chevron_near_col > 2:
				continue
			if state.form[chevron_near_row][chevron_near_col] == null:
				continue
			var chevron_other_sides = 0
			var chevron_other_corners = 0
			for chevron_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var chevron_other_row = chevron_near_row + chevron_other.x
				var chevron_other_col = chevron_near_col + chevron_other.y
				if chevron_other_row < 0 or chevron_other_col < 0 or chevron_other_row > 2 or chevron_other_col > 2:
					continue
				if chevron_other_row == row and chevron_other_col == col:
					continue
				if state.form[chevron_other_row][chevron_other_col] != null:
					chevron_other_sides += 1
			for chevron_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var chevron_other_row = chevron_near_row + chevron_other.x
				var chevron_other_col = chevron_near_col + chevron_other.y
				if chevron_other_row < 0 or chevron_other_col < 0 or chevron_other_row > 2 or chevron_other_col > 2:
					continue
				if state.form[chevron_other_row][chevron_other_col] != null:
					chevron_other_corners += 1
			if chevron_other_sides == 0 and chevron_other_corners == 2:
				guess -= 2
		for chevron_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var chevron_diag_row = row + chevron_corner.x
			var chevron_diag_col = col + chevron_corner.y
			if chevron_diag_row < 0 or chevron_diag_col < 0 or chevron_diag_row > 2 or chevron_diag_col > 2:
				continue
			if state.form[chevron_diag_row][chevron_diag_col] == null:
				continue
			var chevron_diag_sides = 0
			var chevron_diag_corners = 0
			for chevron_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var chevron_other_row = chevron_diag_row + chevron_other.x
				var chevron_other_col = chevron_diag_col + chevron_other.y
				if chevron_other_row < 0 or chevron_other_col < 0 or chevron_other_row > 2 or chevron_other_col > 2:
					continue
				if state.form[chevron_other_row][chevron_other_col] != null:
					chevron_diag_sides += 1
			for chevron_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var chevron_other_row = chevron_diag_row + chevron_other.x
				var chevron_other_col = chevron_diag_col + chevron_other.y
				if chevron_other_row < 0 or chevron_other_col < 0 or chevron_other_row > 2 or chevron_other_col > 2:
					continue
				if chevron_other_row == row and chevron_other_col == col:
					continue
				if state.form[chevron_other_row][chevron_other_col] != null:
					chevron_diag_corners += 1
			if chevron_diag_corners == 1 and chevron_diag_sides == 0:
				guess += 2
			elif chevron_diag_corners == 2 and chevron_diag_sides == 0:
				guess -= 2
	if rule == "double_helm_fill":
		var helm_fill_before_empty = row > 0 and state.form[row - 1][col] == null
		var helm_fill_after_filled = row < 2 and state.form[row + 1][col] != null
		if helm_fill_before_empty and helm_fill_after_filled:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		if row > 0 and state.form[row - 1][col] != null:
			var helm_fill_earlier = state.form[row - 1][col]
			if row - 1 > 0 and state.form[row - 2][col] == null:
				guess += _stamp_number(state, String(helm_fill_earlier["card_id"]), row - 1, col)
		if helm_fill_after_filled:
			var helm_fill_later = state.form[row + 1][col]
			if row + 1 < 2 and state.form[row + 2][col] != null:
				guess -= _stamp_number(state, String(helm_fill_later["card_id"]), row + 1, col)
	if rule == "drop_if_gauge_count":
		var gauge_filled = 0
		for gauge_row in 3:
			for gauge_col in 3:
				if state.form[gauge_row][gauge_col] != null:
					gauge_filled += 1
		var gauge_next = gauge_filled + 1
		if gauge_next == 6 or gauge_next == 8:
			guess -= 4
		elif gauge_filled == 6 or gauge_filled == 8:
			guess += 5
	if rule == "double_bias_blank":
		var bias_before_row = row
		var bias_before_col = col - 4
		while bias_before_col < 0:
			bias_before_row -= 1
			bias_before_col += 3
		var bias_after_row = row
		var bias_after_col = col + 4
		while bias_after_col > 2:
			bias_after_row += 1
			bias_after_col -= 3
		var bias_before_filled = bias_before_row >= 0 and state.form[bias_before_row][bias_before_col] != null
		var bias_after_empty = bias_after_row <= 2 and state.form[bias_after_row][bias_after_col] == null
		if bias_before_filled and bias_after_empty:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		if bias_before_filled:
			var bias_earlier = state.form[bias_before_row][bias_before_col]
			var bias_earlier_before_row = bias_before_row
			var bias_earlier_before_col = bias_before_col - 4
			while bias_earlier_before_col < 0:
				bias_earlier_before_row -= 1
				bias_earlier_before_col += 3
			if bias_earlier_before_row >= 0 and state.form[bias_earlier_before_row][bias_earlier_before_col] != null:
				guess -= _stamp_number(state, String(bias_earlier["card_id"]), bias_before_row, bias_before_col)
		if bias_after_row <= 2 and state.form[bias_after_row][bias_after_col] != null:
			var bias_later = state.form[bias_after_row][bias_after_col]
			var bias_later_after_row = bias_after_row
			var bias_later_after_col = bias_after_col + 4
			while bias_later_after_col > 2:
				bias_later_after_row += 1
				bias_later_after_col -= 3
			if bias_later_after_row <= 2 and state.form[bias_later_after_row][bias_later_after_col] == null:
				guess += _stamp_number(state, String(bias_later["card_id"]), bias_after_row, bias_after_col)
	if rule == "yield_trine_pay":
		var trine_sides = 0
		var trine_corners = 0
		for trine_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var trine_side_row = row + trine_side.x
			var trine_side_col = col + trine_side.y
			if trine_side_row < 0 or trine_side_col < 0 or trine_side_row > 2 or trine_side_col > 2:
				continue
			if state.form[trine_side_row][trine_side_col] != null:
				trine_sides += 1
		for trine_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var trine_corner_row = row + trine_corner.x
			var trine_corner_col = col + trine_corner.y
			if trine_corner_row < 0 or trine_corner_col < 0 or trine_corner_row > 2 or trine_corner_col > 2:
				continue
			if state.form[trine_corner_row][trine_corner_col] != null:
				trine_corners += 1
		if trine_sides == 0 and trine_corners == 3:
			guess += 4
		else:
			guess -= 1
		for trine_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var trine_near_row = row + trine_side.x
			var trine_near_col = col + trine_side.y
			if trine_near_row < 0 or trine_near_col < 0 or trine_near_row > 2 or trine_near_col > 2:
				continue
			if state.form[trine_near_row][trine_near_col] == null:
				continue
			var trine_other_sides = 0
			var trine_other_corners = 0
			for trine_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var trine_other_row = trine_near_row + trine_other.x
				var trine_other_col = trine_near_col + trine_other.y
				if trine_other_row < 0 or trine_other_col < 0 or trine_other_row > 2 or trine_other_col > 2:
					continue
				if trine_other_row == row and trine_other_col == col:
					continue
				if state.form[trine_other_row][trine_other_col] != null:
					trine_other_sides += 1
			for trine_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var trine_other_row = trine_near_row + trine_other.x
				var trine_other_col = trine_near_col + trine_other.y
				if trine_other_row < 0 or trine_other_col < 0 or trine_other_row > 2 or trine_other_col > 2:
					continue
				if state.form[trine_other_row][trine_other_col] != null:
					trine_other_corners += 1
			if trine_other_sides == 0 and trine_other_corners == 3:
				guess -= 2
		for trine_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var trine_diag_row = row + trine_corner.x
			var trine_diag_col = col + trine_corner.y
			if trine_diag_row < 0 or trine_diag_col < 0 or trine_diag_row > 2 or trine_diag_col > 2:
				continue
			if state.form[trine_diag_row][trine_diag_col] == null:
				continue
			var trine_diag_sides = 0
			var trine_diag_corners = 0
			for trine_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var trine_other_row = trine_diag_row + trine_other.x
				var trine_other_col = trine_diag_col + trine_other.y
				if trine_other_row < 0 or trine_other_col < 0 or trine_other_row > 2 or trine_other_col > 2:
					continue
				if state.form[trine_other_row][trine_other_col] != null:
					trine_diag_sides += 1
			for trine_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var trine_other_row = trine_diag_row + trine_other.x
				var trine_other_col = trine_diag_col + trine_other.y
				if trine_other_row < 0 or trine_other_col < 0 or trine_other_row > 2 or trine_other_col > 2:
					continue
				if trine_other_row == row and trine_other_col == col:
					continue
				if state.form[trine_other_row][trine_other_col] != null:
					trine_diag_corners += 1
			if trine_diag_corners == 2 and trine_diag_sides == 0:
				guess += 2
			elif trine_diag_corners == 3 and trine_diag_sides == 0:
				guess -= 2
	if rule == "double_bias_fill":
		var bias_fill_before_row = row
		var bias_fill_before_col = col - 4
		while bias_fill_before_col < 0:
			bias_fill_before_row -= 1
			bias_fill_before_col += 3
		var bias_fill_after_row = row
		var bias_fill_after_col = col + 4
		while bias_fill_after_col > 2:
			bias_fill_after_row += 1
			bias_fill_after_col -= 3
		var bias_fill_before_empty = bias_fill_before_row >= 0 and state.form[bias_fill_before_row][bias_fill_before_col] == null
		var bias_fill_after_filled = bias_fill_after_row <= 2 and state.form[bias_fill_after_row][bias_fill_after_col] != null
		if bias_fill_before_empty and bias_fill_after_filled:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		if bias_fill_before_row >= 0 and state.form[bias_fill_before_row][bias_fill_before_col] != null:
			var bias_fill_earlier = state.form[bias_fill_before_row][bias_fill_before_col]
			var bias_fill_earlier_before_row = bias_fill_before_row
			var bias_fill_earlier_before_col = bias_fill_before_col - 4
			while bias_fill_earlier_before_col < 0:
				bias_fill_earlier_before_row -= 1
				bias_fill_earlier_before_col += 3
			if bias_fill_earlier_before_row >= 0 and state.form[bias_fill_earlier_before_row][bias_fill_earlier_before_col] == null:
				guess += _stamp_number(state, String(bias_fill_earlier["card_id"]), bias_fill_before_row, bias_fill_before_col)
		if bias_fill_after_filled:
			var bias_fill_later = state.form[bias_fill_after_row][bias_fill_after_col]
			var bias_fill_later_after_row = bias_fill_after_row
			var bias_fill_later_after_col = bias_fill_after_col + 4
			while bias_fill_later_after_col > 2:
				bias_fill_later_after_row += 1
				bias_fill_later_after_col -= 3
			if bias_fill_later_after_row <= 2 and state.form[bias_fill_later_after_row][bias_fill_later_after_col] != null:
				guess -= _stamp_number(state, String(bias_fill_later["card_id"]), bias_fill_after_row, bias_fill_after_col)
	if rule == "drop_if_latch_count":
		var latch_filled = 0
		for latch_row in 3:
			for latch_col in 3:
				if state.form[latch_row][latch_col] != null:
					latch_filled += 1
		var latch_next = latch_filled + 1
		if latch_next == 7 or latch_next == 9:
			guess -= 4
		elif latch_filled == 7 or latch_filled == 9:
			guess += 5
	if rule == "double_full_fill":
		var full_before_row = row
		var full_before_col = col - 4
		while full_before_col < 0:
			full_before_row -= 1
			full_before_col += 3
		var full_after_row = row
		var full_after_col = col + 4
		while full_after_col > 2:
			full_after_row += 1
			full_after_col -= 3
		var full_before_filled = full_before_row >= 0 and state.form[full_before_row][full_before_col] != null
		var full_after_filled = full_after_row <= 2 and state.form[full_after_row][full_after_col] != null
		if full_before_filled and full_after_filled:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		if full_before_filled:
			var full_earlier = state.form[full_before_row][full_before_col]
			var full_earlier_before_row = full_before_row
			var full_earlier_before_col = full_before_col - 4
			while full_earlier_before_col < 0:
				full_earlier_before_row -= 1
				full_earlier_before_col += 3
			if full_earlier_before_row >= 0 and state.form[full_earlier_before_row][full_earlier_before_col] != null:
				guess += _stamp_number(state, String(full_earlier["card_id"]), full_before_row, full_before_col)
		if full_after_filled:
			var full_later = state.form[full_after_row][full_after_col]
			var full_later_after_row = full_after_row
			var full_later_after_col = full_after_col + 4
			while full_later_after_col > 2:
				full_later_after_row += 1
				full_later_after_col -= 3
			if full_later_after_row <= 2 and state.form[full_later_after_row][full_later_after_col] != null:
				guess += _stamp_number(state, String(full_later["card_id"]), full_after_row, full_after_col)
	if rule == "yield_clasp_pay":
		var clasp_sides = 0
		var clasp_corners = 0
		for clasp_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var clasp_side_row = row + clasp_side.x
			var clasp_side_col = col + clasp_side.y
			if clasp_side_row < 0 or clasp_side_col < 0 or clasp_side_row > 2 or clasp_side_col > 2:
				continue
			if state.form[clasp_side_row][clasp_side_col] != null:
				clasp_sides += 1
		for clasp_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var clasp_corner_row = row + clasp_corner.x
			var clasp_corner_col = col + clasp_corner.y
			if clasp_corner_row < 0 or clasp_corner_col < 0 or clasp_corner_row > 2 or clasp_corner_col > 2:
				continue
			if state.form[clasp_corner_row][clasp_corner_col] != null:
				clasp_corners += 1
		if clasp_sides == 1 and clasp_corners == 3:
			guess += 4
		else:
			guess -= 1
		for clasp_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var clasp_near_row = row + clasp_side.x
			var clasp_near_col = col + clasp_side.y
			if clasp_near_row < 0 or clasp_near_col < 0 or clasp_near_row > 2 or clasp_near_col > 2:
				continue
			if state.form[clasp_near_row][clasp_near_col] == null:
				continue
			var clasp_other_sides = 0
			var clasp_other_corners = 0
			for clasp_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var clasp_other_row = clasp_near_row + clasp_other.x
				var clasp_other_col = clasp_near_col + clasp_other.y
				if clasp_other_row < 0 or clasp_other_col < 0 or clasp_other_row > 2 or clasp_other_col > 2:
					continue
				if clasp_other_row == row and clasp_other_col == col:
					continue
				if state.form[clasp_other_row][clasp_other_col] != null:
					clasp_other_sides += 1
			for clasp_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var clasp_other_row = clasp_near_row + clasp_other.x
				var clasp_other_col = clasp_near_col + clasp_other.y
				if clasp_other_row < 0 or clasp_other_col < 0 or clasp_other_row > 2 or clasp_other_col > 2:
					continue
				if state.form[clasp_other_row][clasp_other_col] != null:
					clasp_other_corners += 1
			if clasp_other_sides == 0 and clasp_other_corners == 3:
				guess += 2
			elif clasp_other_sides == 1 and clasp_other_corners == 3:
				guess -= 2
		for clasp_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var clasp_diag_row = row + clasp_corner.x
			var clasp_diag_col = col + clasp_corner.y
			if clasp_diag_row < 0 or clasp_diag_col < 0 or clasp_diag_row > 2 or clasp_diag_col > 2:
				continue
			if state.form[clasp_diag_row][clasp_diag_col] == null:
				continue
			var clasp_diag_sides = 0
			var clasp_diag_corners = 0
			for clasp_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var clasp_other_row = clasp_diag_row + clasp_other.x
				var clasp_other_col = clasp_diag_col + clasp_other.y
				if clasp_other_row < 0 or clasp_other_col < 0 or clasp_other_row > 2 or clasp_other_col > 2:
					continue
				if state.form[clasp_other_row][clasp_other_col] != null:
					clasp_diag_sides += 1
			for clasp_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var clasp_other_row = clasp_diag_row + clasp_other.x
				var clasp_other_col = clasp_diag_col + clasp_other.y
				if clasp_other_row < 0 or clasp_other_col < 0 or clasp_other_row > 2 or clasp_other_col > 2:
					continue
				if clasp_other_row == row and clasp_other_col == col:
					continue
				if state.form[clasp_other_row][clasp_other_col] != null:
					clasp_diag_corners += 1
			if clasp_diag_corners == 2 and clasp_diag_sides == 1:
				guess += 2
			elif clasp_diag_corners == 3 and clasp_diag_sides == 1:
				guess -= 2
	if rule == "double_full_blank":
		var blank_before_row = row
		var blank_before_col = col - 4
		while blank_before_col < 0:
			blank_before_row -= 1
			blank_before_col += 3
		var blank_after_row = row
		var blank_after_col = col + 4
		while blank_after_col > 2:
			blank_after_row += 1
			blank_after_col -= 3
		var blank_before_empty = blank_before_row >= 0 and state.form[blank_before_row][blank_before_col] == null
		var blank_after_empty = blank_after_row <= 2 and state.form[blank_after_row][blank_after_col] == null
		if blank_before_empty and blank_after_empty:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		if blank_before_row >= 0 and state.form[blank_before_row][blank_before_col] != null:
			var blank_earlier = state.form[blank_before_row][blank_before_col]
			var blank_earlier_before_row = blank_before_row
			var blank_earlier_before_col = blank_before_col - 4
			while blank_earlier_before_col < 0:
				blank_earlier_before_row -= 1
				blank_earlier_before_col += 3
			if blank_earlier_before_row >= 0 and state.form[blank_earlier_before_row][blank_earlier_before_col] == null:
				guess -= _stamp_number(state, String(blank_earlier["card_id"]), blank_before_row, blank_before_col)
		if blank_after_row <= 2 and state.form[blank_after_row][blank_after_col] != null:
			var blank_later = state.form[blank_after_row][blank_after_col]
			var blank_later_after_row = blank_after_row
			var blank_later_after_col = blank_after_col + 4
			while blank_later_after_col > 2:
				blank_later_after_row += 1
				blank_later_after_col -= 3
			if blank_later_after_row <= 2 and state.form[blank_later_after_row][blank_later_after_col] == null:
				guess -= _stamp_number(state, String(blank_later["card_id"]), blank_after_row, blank_after_col)
	if rule == "drop_if_fork_count":
		var fork_filled = 0
		for fork_row in 3:
			for fork_col in 3:
				if state.form[fork_row][fork_col] != null:
					fork_filled += 1
		var fork_next = fork_filled + 1
		if fork_next == 0 or fork_next == 3:
			guess -= 4
		elif fork_filled == 0 or fork_filled == 3:
			guess += 5
	if rule == "double_yoke_fill":
		var yoke_before_row = row
		var yoke_before_col = col - 3
		while yoke_before_col < 0:
			yoke_before_row -= 1
			yoke_before_col += 3
		var yoke_after_row = row
		var yoke_after_col = col + 3
		while yoke_after_col > 2:
			yoke_after_row += 1
			yoke_after_col -= 3
		var yoke_before_filled = yoke_before_row >= 0 and state.form[yoke_before_row][yoke_before_col] != null
		var yoke_after_filled = yoke_after_row <= 2 and state.form[yoke_after_row][yoke_after_col] != null
		if yoke_before_filled and yoke_after_filled:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		if yoke_before_filled:
			var yoke_earlier = state.form[yoke_before_row][yoke_before_col]
			var yoke_earlier_before_row = yoke_before_row
			var yoke_earlier_before_col = yoke_before_col - 3
			while yoke_earlier_before_col < 0:
				yoke_earlier_before_row -= 1
				yoke_earlier_before_col += 3
			if yoke_earlier_before_row >= 0 and state.form[yoke_earlier_before_row][yoke_earlier_before_col] != null:
				guess += _stamp_number(state, String(yoke_earlier["card_id"]), yoke_before_row, yoke_before_col)
		if yoke_after_filled:
			var yoke_later = state.form[yoke_after_row][yoke_after_col]
			var yoke_later_after_row = yoke_after_row
			var yoke_later_after_col = yoke_after_col + 3
			while yoke_later_after_col > 2:
				yoke_later_after_row += 1
				yoke_later_after_col -= 3
			if yoke_later_after_row <= 2 and state.form[yoke_later_after_row][yoke_later_after_col] != null:
				guess += _stamp_number(state, String(yoke_later["card_id"]), yoke_after_row, yoke_after_col)
	if rule == "yield_hasp_pay":
		var hasp_sides = 0
		var hasp_corners = 0
		for hasp_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var hasp_side_row = row + hasp_side.x
			var hasp_side_col = col + hasp_side.y
			if hasp_side_row < 0 or hasp_side_col < 0 or hasp_side_row > 2 or hasp_side_col > 2:
				continue
			if state.form[hasp_side_row][hasp_side_col] != null:
				hasp_sides += 1
		for hasp_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var hasp_corner_row = row + hasp_corner.x
			var hasp_corner_col = col + hasp_corner.y
			if hasp_corner_row < 0 or hasp_corner_col < 0 or hasp_corner_row > 2 or hasp_corner_col > 2:
				continue
			if state.form[hasp_corner_row][hasp_corner_col] != null:
				hasp_corners += 1
		if hasp_sides == 2 and hasp_corners == 3:
			guess += 4
		else:
			guess -= 1
		for hasp_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var hasp_near_row = row + hasp_side.x
			var hasp_near_col = col + hasp_side.y
			if hasp_near_row < 0 or hasp_near_col < 0 or hasp_near_row > 2 or hasp_near_col > 2:
				continue
			if state.form[hasp_near_row][hasp_near_col] == null:
				continue
			var hasp_other_sides = 0
			var hasp_other_corners = 0
			for hasp_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var hasp_other_row = hasp_near_row + hasp_other.x
				var hasp_other_col = hasp_near_col + hasp_other.y
				if hasp_other_row < 0 or hasp_other_col < 0 or hasp_other_row > 2 or hasp_other_col > 2:
					continue
				if hasp_other_row == row and hasp_other_col == col:
					continue
				if state.form[hasp_other_row][hasp_other_col] != null:
					hasp_other_sides += 1
			for hasp_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var hasp_other_row = hasp_near_row + hasp_other.x
				var hasp_other_col = hasp_near_col + hasp_other.y
				if hasp_other_row < 0 or hasp_other_col < 0 or hasp_other_row > 2 or hasp_other_col > 2:
					continue
				if state.form[hasp_other_row][hasp_other_col] != null:
					hasp_other_corners += 1
			if hasp_other_sides == 1 and hasp_other_corners == 3:
				guess += 2
			elif hasp_other_sides == 2 and hasp_other_corners == 3:
				guess -= 2
		for hasp_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var hasp_diag_row = row + hasp_corner.x
			var hasp_diag_col = col + hasp_corner.y
			if hasp_diag_row < 0 or hasp_diag_col < 0 or hasp_diag_row > 2 or hasp_diag_col > 2:
				continue
			if state.form[hasp_diag_row][hasp_diag_col] == null:
				continue
			var hasp_diag_sides = 0
			var hasp_diag_corners = 0
			for hasp_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var hasp_other_row = hasp_diag_row + hasp_other.x
				var hasp_other_col = hasp_diag_col + hasp_other.y
				if hasp_other_row < 0 or hasp_other_col < 0 or hasp_other_row > 2 or hasp_other_col > 2:
					continue
				if state.form[hasp_other_row][hasp_other_col] != null:
					hasp_diag_sides += 1
			for hasp_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var hasp_other_row = hasp_diag_row + hasp_other.x
				var hasp_other_col = hasp_diag_col + hasp_other.y
				if hasp_other_row < 0 or hasp_other_col < 0 or hasp_other_row > 2 or hasp_other_col > 2:
					continue
				if hasp_other_row == row and hasp_other_col == col:
					continue
				if state.form[hasp_other_row][hasp_other_col] != null:
					hasp_diag_corners += 1
			if hasp_diag_corners == 2 and hasp_diag_sides == 2:
				guess += 2
			elif hasp_diag_corners == 3 and hasp_diag_sides == 2:
				guess -= 2
	if rule == "double_yoke_blank":
		var yokeb_before_row = row
		var yokeb_before_col = col - 3
		while yokeb_before_col < 0:
			yokeb_before_row -= 1
			yokeb_before_col += 3
		var yokeb_after_row = row
		var yokeb_after_col = col + 3
		while yokeb_after_col > 2:
			yokeb_after_row += 1
			yokeb_after_col -= 3
		var yokeb_before_empty = yokeb_before_row >= 0 and state.form[yokeb_before_row][yokeb_before_col] == null
		var yokeb_after_empty = yokeb_after_row <= 2 and state.form[yokeb_after_row][yokeb_after_col] == null
		if yokeb_before_empty and yokeb_after_empty:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		if yokeb_before_row >= 0 and state.form[yokeb_before_row][yokeb_before_col] != null:
			var yokeb_earlier = state.form[yokeb_before_row][yokeb_before_col]
			var yokeb_earlier_before_row = yokeb_before_row
			var yokeb_earlier_before_col = yokeb_before_col - 3
			while yokeb_earlier_before_col < 0:
				yokeb_earlier_before_row -= 1
				yokeb_earlier_before_col += 3
			if yokeb_earlier_before_row >= 0 and state.form[yokeb_earlier_before_row][yokeb_earlier_before_col] == null:
				guess -= _stamp_number(state, String(yokeb_earlier["card_id"]), yokeb_before_row, yokeb_before_col)
		if yokeb_after_row <= 2 and state.form[yokeb_after_row][yokeb_after_col] != null:
			var yokeb_later = state.form[yokeb_after_row][yokeb_after_col]
			var yokeb_later_after_row = yokeb_after_row
			var yokeb_later_after_col = yokeb_after_col + 3
			while yokeb_later_after_col > 2:
				yokeb_later_after_row += 1
				yokeb_later_after_col -= 3
			if yokeb_later_after_row <= 2 and state.form[yokeb_later_after_row][yokeb_later_after_col] == null:
				guess -= _stamp_number(state, String(yokeb_later["card_id"]), yokeb_after_row, yokeb_after_col)
	if rule == "drop_if_dent_count":
		var dent_filled = 0
		for dent_row in 3:
			for dent_col in 3:
				if state.form[dent_row][dent_col] != null:
					dent_filled += 1
		var dent_next = dent_filled + 1
		if dent_next == 1 or dent_next == 4:
			guess -= 4
		elif dent_filled == 1 or dent_filled == 4:
			guess += 5
	if rule == "double_peg_fill":
		var peg_before_row = row
		var peg_before_col = col - 2
		while peg_before_col < 0:
			peg_before_row -= 1
			peg_before_col += 3
		var peg_after_row = row
		var peg_after_col = col + 2
		while peg_after_col > 2:
			peg_after_row += 1
			peg_after_col -= 3
		var peg_before_filled = peg_before_row >= 0 and state.form[peg_before_row][peg_before_col] != null
		var peg_after_filled = peg_after_row <= 2 and state.form[peg_after_row][peg_after_col] != null
		if peg_before_filled and peg_after_filled:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		if peg_before_filled:
			var peg_earlier = state.form[peg_before_row][peg_before_col]
			var peg_earlier_before_row = peg_before_row
			var peg_earlier_before_col = peg_before_col - 2
			while peg_earlier_before_col < 0:
				peg_earlier_before_row -= 1
				peg_earlier_before_col += 3
			if peg_earlier_before_row >= 0 and state.form[peg_earlier_before_row][peg_earlier_before_col] != null:
				guess += _stamp_number(state, String(peg_earlier["card_id"]), peg_before_row, peg_before_col)
		if peg_after_filled:
			var peg_later = state.form[peg_after_row][peg_after_col]
			var peg_later_after_row = peg_after_row
			var peg_later_after_col = peg_after_col + 2
			while peg_later_after_col > 2:
				peg_later_after_row += 1
				peg_later_after_col -= 3
			if peg_later_after_row <= 2 and state.form[peg_later_after_row][peg_later_after_col] != null:
				guess += _stamp_number(state, String(peg_later["card_id"]), peg_after_row, peg_after_col)
	if rule == "yield_bolt_pay":
		var bolt_sides = 0
		var bolt_corners = 0
		for bolt_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var bolt_side_row = row + bolt_side.x
			var bolt_side_col = col + bolt_side.y
			if bolt_side_row < 0 or bolt_side_col < 0 or bolt_side_row > 2 or bolt_side_col > 2:
				continue
			if state.form[bolt_side_row][bolt_side_col] != null:
				bolt_sides += 1
		for bolt_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var bolt_corner_row = row + bolt_corner.x
			var bolt_corner_col = col + bolt_corner.y
			if bolt_corner_row < 0 or bolt_corner_col < 0 or bolt_corner_row > 2 or bolt_corner_col > 2:
				continue
			if state.form[bolt_corner_row][bolt_corner_col] != null:
				bolt_corners += 1
		if bolt_sides == 3 and bolt_corners == 3:
			guess += 4
		else:
			guess -= 1
		for bolt_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var bolt_near_row = row + bolt_side.x
			var bolt_near_col = col + bolt_side.y
			if bolt_near_row < 0 or bolt_near_col < 0 or bolt_near_row > 2 or bolt_near_col > 2:
				continue
			if state.form[bolt_near_row][bolt_near_col] == null:
				continue
			var bolt_other_sides = 0
			var bolt_other_corners = 0
			for bolt_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var bolt_other_row = bolt_near_row + bolt_other.x
				var bolt_other_col = bolt_near_col + bolt_other.y
				if bolt_other_row < 0 or bolt_other_col < 0 or bolt_other_row > 2 or bolt_other_col > 2:
					continue
				if bolt_other_row == row and bolt_other_col == col:
					continue
				if state.form[bolt_other_row][bolt_other_col] != null:
					bolt_other_sides += 1
			for bolt_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var bolt_other_row = bolt_near_row + bolt_other.x
				var bolt_other_col = bolt_near_col + bolt_other.y
				if bolt_other_row < 0 or bolt_other_col < 0 or bolt_other_row > 2 or bolt_other_col > 2:
					continue
				if state.form[bolt_other_row][bolt_other_col] != null:
					bolt_other_corners += 1
			if bolt_other_sides == 2 and bolt_other_corners == 3:
				guess += 2
			elif bolt_other_sides == 3 and bolt_other_corners == 3:
				guess -= 2
		for bolt_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var bolt_diag_row = row + bolt_corner.x
			var bolt_diag_col = col + bolt_corner.y
			if bolt_diag_row < 0 or bolt_diag_col < 0 or bolt_diag_row > 2 or bolt_diag_col > 2:
				continue
			if state.form[bolt_diag_row][bolt_diag_col] == null:
				continue
			var bolt_diag_sides = 0
			var bolt_diag_corners = 0
			for bolt_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var bolt_other_row = bolt_diag_row + bolt_other.x
				var bolt_other_col = bolt_diag_col + bolt_other.y
				if bolt_other_row < 0 or bolt_other_col < 0 or bolt_other_row > 2 or bolt_other_col > 2:
					continue
				if state.form[bolt_other_row][bolt_other_col] != null:
					bolt_diag_sides += 1
			for bolt_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var bolt_other_row = bolt_diag_row + bolt_other.x
				var bolt_other_col = bolt_diag_col + bolt_other.y
				if bolt_other_row < 0 or bolt_other_col < 0 or bolt_other_row > 2 or bolt_other_col > 2:
					continue
				if bolt_other_row == row and bolt_other_col == col:
					continue
				if state.form[bolt_other_row][bolt_other_col] != null:
					bolt_diag_corners += 1
			if bolt_diag_corners == 2 and bolt_diag_sides == 3:
				guess += 2
			elif bolt_diag_corners == 3 and bolt_diag_sides == 3:
				guess -= 2
	if rule == "double_peg_blank":
		var pegb_before_row = row
		var pegb_before_col = col - 2
		while pegb_before_col < 0:
			pegb_before_row -= 1
			pegb_before_col += 3
		var pegb_after_row = row
		var pegb_after_col = col + 2
		while pegb_after_col > 2:
			pegb_after_row += 1
			pegb_after_col -= 3
		var pegb_before_empty = pegb_before_row >= 0 and state.form[pegb_before_row][pegb_before_col] == null
		var pegb_after_empty = pegb_after_row <= 2 and state.form[pegb_after_row][pegb_after_col] == null
		if pegb_before_empty and pegb_after_empty:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		if pegb_before_row >= 0 and state.form[pegb_before_row][pegb_before_col] != null:
			var pegb_earlier = state.form[pegb_before_row][pegb_before_col]
			var pegb_earlier_before_row = pegb_before_row
			var pegb_earlier_before_col = pegb_before_col - 2
			while pegb_earlier_before_col < 0:
				pegb_earlier_before_row -= 1
				pegb_earlier_before_col += 3
			if pegb_earlier_before_row >= 0 and state.form[pegb_earlier_before_row][pegb_earlier_before_col] == null:
				guess -= _stamp_number(state, String(pegb_earlier["card_id"]), pegb_before_row, pegb_before_col)
		if pegb_after_row <= 2 and state.form[pegb_after_row][pegb_after_col] != null:
			var pegb_later = state.form[pegb_after_row][pegb_after_col]
			var pegb_later_after_row = pegb_after_row
			var pegb_later_after_col = pegb_after_col + 2
			while pegb_later_after_col > 2:
				pegb_later_after_row += 1
				pegb_later_after_col -= 3
			if pegb_later_after_row <= 2 and state.form[pegb_later_after_row][pegb_later_after_col] == null:
				guess -= _stamp_number(state, String(pegb_later["card_id"]), pegb_after_row, pegb_after_col)
	if rule == "drop_if_gash_count":
		var gash_filled = 0
		for gash_row in 3:
			for gash_col in 3:
				if state.form[gash_row][gash_col] != null:
					gash_filled += 1
		var gash_next = gash_filled + 1
		if gash_next == 2 or gash_next == 5:
			guess -= 4
		elif gash_filled == 2 or gash_filled == 5:
			guess += 5
	if rule == "double_hitch_fill":
		var hitch_before_row = row
		var hitch_before_col = col - 2
		while hitch_before_col < 0:
			hitch_before_row -= 1
			hitch_before_col += 3
		var hitch_after_row = row
		var hitch_after_col = col + 1
		while hitch_after_col > 2:
			hitch_after_row += 1
			hitch_after_col -= 3
		var hitch_before_filled = hitch_before_row >= 0 and state.form[hitch_before_row][hitch_before_col] != null
		var hitch_after_filled = hitch_after_row <= 2 and state.form[hitch_after_row][hitch_after_col] != null
		if hitch_before_filled and hitch_after_filled:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var hitch_prior_row = row
		var hitch_prior_col = col - 1
		while hitch_prior_col < 0:
			hitch_prior_row -= 1
			hitch_prior_col += 3
		if hitch_prior_row >= 0 and state.form[hitch_prior_row][hitch_prior_col] != null:
			var hitch_prior = state.form[hitch_prior_row][hitch_prior_col]
			var hitch_prior_before_row = hitch_prior_row
			var hitch_prior_before_col = hitch_prior_col - 2
			while hitch_prior_before_col < 0:
				hitch_prior_before_row -= 1
				hitch_prior_before_col += 3
			if hitch_prior_before_row >= 0 and state.form[hitch_prior_before_row][hitch_prior_before_col] != null:
				guess += _stamp_number(state, String(hitch_prior["card_id"]), hitch_prior_row, hitch_prior_col)
		var hitch_later_row = row
		var hitch_later_col = col + 2
		while hitch_later_col > 2:
			hitch_later_row += 1
			hitch_later_col -= 3
		if hitch_later_row <= 2 and state.form[hitch_later_row][hitch_later_col] != null:
			var hitch_later = state.form[hitch_later_row][hitch_later_col]
			var hitch_later_after_row = hitch_later_row
			var hitch_later_after_col = hitch_later_col + 1
			while hitch_later_after_col > 2:
				hitch_later_after_row += 1
				hitch_later_after_col -= 3
			if hitch_later_after_row <= 2 and state.form[hitch_later_after_row][hitch_later_after_col] != null:
				guess += _stamp_number(state, String(hitch_later["card_id"]), hitch_later_row, hitch_later_col)
	if rule == "yield_pin_pay":
		var pin_sides = 0
		var pin_corners = 0
		for pin_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var pin_side_row = row + pin_side.x
			var pin_side_col = col + pin_side.y
			if pin_side_row < 0 or pin_side_col < 0 or pin_side_row > 2 or pin_side_col > 2:
				continue
			if state.form[pin_side_row][pin_side_col] != null:
				pin_sides += 1
		for pin_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var pin_corner_row = row + pin_corner.x
			var pin_corner_col = col + pin_corner.y
			if pin_corner_row < 0 or pin_corner_col < 0 or pin_corner_row > 2 or pin_corner_col > 2:
				continue
			if state.form[pin_corner_row][pin_corner_col] != null:
				pin_corners += 1
		if pin_sides == 4 and pin_corners == 3:
			guess += 4
		else:
			guess -= 1
		for pin_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var pin_near_row = row + pin_side.x
			var pin_near_col = col + pin_side.y
			if pin_near_row < 0 or pin_near_col < 0 or pin_near_row > 2 or pin_near_col > 2:
				continue
			if state.form[pin_near_row][pin_near_col] == null:
				continue
			var pin_other_sides = 0
			var pin_other_corners = 0
			for pin_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var pin_other_row = pin_near_row + pin_other.x
				var pin_other_col = pin_near_col + pin_other.y
				if pin_other_row < 0 or pin_other_col < 0 or pin_other_row > 2 or pin_other_col > 2:
					continue
				if pin_other_row == row and pin_other_col == col:
					continue
				if state.form[pin_other_row][pin_other_col] != null:
					pin_other_sides += 1
			for pin_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var pin_other_row = pin_near_row + pin_other.x
				var pin_other_col = pin_near_col + pin_other.y
				if pin_other_row < 0 or pin_other_col < 0 or pin_other_row > 2 or pin_other_col > 2:
					continue
				if state.form[pin_other_row][pin_other_col] != null:
					pin_other_corners += 1
			if pin_other_sides == 3 and pin_other_corners == 3:
				guess += 2
			elif pin_other_sides == 4 and pin_other_corners == 3:
				guess -= 2
		for pin_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var pin_diag_row = row + pin_corner.x
			var pin_diag_col = col + pin_corner.y
			if pin_diag_row < 0 or pin_diag_col < 0 or pin_diag_row > 2 or pin_diag_col > 2:
				continue
			if state.form[pin_diag_row][pin_diag_col] == null:
				continue
			var pin_diag_sides = 0
			var pin_diag_corners = 0
			for pin_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var pin_other_row = pin_diag_row + pin_other.x
				var pin_other_col = pin_diag_col + pin_other.y
				if pin_other_row < 0 or pin_other_col < 0 or pin_other_row > 2 or pin_other_col > 2:
					continue
				if state.form[pin_other_row][pin_other_col] != null:
					pin_diag_sides += 1
			for pin_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var pin_other_row = pin_diag_row + pin_other.x
				var pin_other_col = pin_diag_col + pin_other.y
				if pin_other_row < 0 or pin_other_col < 0 or pin_other_row > 2 or pin_other_col > 2:
					continue
				if pin_other_row == row and pin_other_col == col:
					continue
				if state.form[pin_other_row][pin_other_col] != null:
					pin_diag_corners += 1
			if pin_diag_corners == 2 and pin_diag_sides == 4:
				guess += 2
			elif pin_diag_corners == 3 and pin_diag_sides == 4:
				guess -= 2
	if rule == "double_hitch_blank":
		var hitchb_before_row = row
		var hitchb_before_col = col - 2
		while hitchb_before_col < 0:
			hitchb_before_row -= 1
			hitchb_before_col += 3
		var hitchb_after_row = row
		var hitchb_after_col = col + 1
		while hitchb_after_col > 2:
			hitchb_after_row += 1
			hitchb_after_col -= 3
		var hitchb_before_empty = hitchb_before_row >= 0 and state.form[hitchb_before_row][hitchb_before_col] == null
		var hitchb_after_empty = hitchb_after_row <= 2 and state.form[hitchb_after_row][hitchb_after_col] == null
		if hitchb_before_empty and hitchb_after_empty:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var hitchb_prior_row = row
		var hitchb_prior_col = col - 1
		while hitchb_prior_col < 0:
			hitchb_prior_row -= 1
			hitchb_prior_col += 3
		if hitchb_prior_row >= 0 and state.form[hitchb_prior_row][hitchb_prior_col] != null:
			var hitchb_prior = state.form[hitchb_prior_row][hitchb_prior_col]
			var hitchb_prior_before_row = hitchb_prior_row
			var hitchb_prior_before_col = hitchb_prior_col - 2
			while hitchb_prior_before_col < 0:
				hitchb_prior_before_row -= 1
				hitchb_prior_before_col += 3
			if hitchb_prior_before_row >= 0 and state.form[hitchb_prior_before_row][hitchb_prior_before_col] == null:
				guess -= _stamp_number(state, String(hitchb_prior["card_id"]), hitchb_prior_row, hitchb_prior_col)
		var hitchb_later_row = row
		var hitchb_later_col = col + 2
		while hitchb_later_col > 2:
			hitchb_later_row += 1
			hitchb_later_col -= 3
		if hitchb_later_row <= 2 and state.form[hitchb_later_row][hitchb_later_col] != null:
			var hitchb_later = state.form[hitchb_later_row][hitchb_later_col]
			var hitchb_later_after_row = hitchb_later_row
			var hitchb_later_after_col = hitchb_later_col + 1
			while hitchb_later_after_col > 2:
				hitchb_later_after_row += 1
				hitchb_later_after_col -= 3
			if hitchb_later_after_row <= 2 and state.form[hitchb_later_after_row][hitchb_later_after_col] == null:
				guess -= _stamp_number(state, String(hitchb_later["card_id"]), hitchb_later_row, hitchb_later_col)
	if rule == "drop_if_gouge_count":
		var gouge_filled = 0
		for gouge_row in 3:
			for gouge_col in 3:
				if state.form[gouge_row][gouge_col] != null:
					gouge_filled += 1
		var gouge_next = gouge_filled + 1
		if gouge_next == 3 or gouge_next == 6:
			guess -= 4
		elif gouge_filled == 3 or gouge_filled == 6:
			guess += 5
	if rule == "double_bight_fill":
		var bight_before_row = row
		var bight_before_col = col - 3
		while bight_before_col < 0:
			bight_before_row -= 1
			bight_before_col += 3
		var bight_after_row = row
		var bight_after_col = col + 1
		while bight_after_col > 2:
			bight_after_row += 1
			bight_after_col -= 3
		var bight_before_filled = bight_before_row >= 0 and state.form[bight_before_row][bight_before_col] != null
		var bight_after_filled = bight_after_row <= 2 and state.form[bight_after_row][bight_after_col] != null
		if bight_before_filled and bight_after_filled:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var bight_prior_row = row
		var bight_prior_col = col - 1
		while bight_prior_col < 0:
			bight_prior_row -= 1
			bight_prior_col += 3
		if bight_prior_row >= 0 and state.form[bight_prior_row][bight_prior_col] != null:
			var bight_prior = state.form[bight_prior_row][bight_prior_col]
			var bight_prior_before_row = bight_prior_row
			var bight_prior_before_col = bight_prior_col - 3
			while bight_prior_before_col < 0:
				bight_prior_before_row -= 1
				bight_prior_before_col += 3
			if bight_prior_before_row >= 0 and state.form[bight_prior_before_row][bight_prior_before_col] != null:
				guess += _stamp_number(state, String(bight_prior["card_id"]), bight_prior_row, bight_prior_col)
		var bight_later_row = row
		var bight_later_col = col + 3
		while bight_later_col > 2:
			bight_later_row += 1
			bight_later_col -= 3
		if bight_later_row <= 2 and state.form[bight_later_row][bight_later_col] != null:
			var bight_later = state.form[bight_later_row][bight_later_col]
			var bight_later_after_row = bight_later_row
			var bight_later_after_col = bight_later_col + 1
			while bight_later_after_col > 2:
				bight_later_after_row += 1
				bight_later_after_col -= 3
			if bight_later_after_row <= 2 and state.form[bight_later_after_row][bight_later_after_col] != null:
				guess += _stamp_number(state, String(bight_later["card_id"]), bight_later_row, bight_later_col)
	if rule == "yield_brad_pay":
		var brad_sides = 0
		var brad_corners = 0
		for brad_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var brad_side_row = row + brad_side.x
			var brad_side_col = col + brad_side.y
			if brad_side_row < 0 or brad_side_col < 0 or brad_side_row > 2 or brad_side_col > 2:
				continue
			if state.form[brad_side_row][brad_side_col] != null:
				brad_sides += 1
		for brad_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var brad_corner_row = row + brad_corner.x
			var brad_corner_col = col + brad_corner.y
			if brad_corner_row < 0 or brad_corner_col < 0 or brad_corner_row > 2 or brad_corner_col > 2:
				continue
			if state.form[brad_corner_row][brad_corner_col] != null:
				brad_corners += 1
		if brad_sides == 1 and brad_corners == 4:
			guess += 4
		else:
			guess -= 1
		for brad_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var brad_near_row = row + brad_side.x
			var brad_near_col = col + brad_side.y
			if brad_near_row < 0 or brad_near_col < 0 or brad_near_row > 2 or brad_near_col > 2:
				continue
			if state.form[brad_near_row][brad_near_col] == null:
				continue
			var brad_other_sides = 0
			var brad_other_corners = 0
			for brad_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var brad_other_row = brad_near_row + brad_other.x
				var brad_other_col = brad_near_col + brad_other.y
				if brad_other_row < 0 or brad_other_col < 0 or brad_other_row > 2 or brad_other_col > 2:
					continue
				if brad_other_row == row and brad_other_col == col:
					continue
				if state.form[brad_other_row][brad_other_col] != null:
					brad_other_sides += 1
			for brad_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var brad_other_row = brad_near_row + brad_other.x
				var brad_other_col = brad_near_col + brad_other.y
				if brad_other_row < 0 or brad_other_col < 0 or brad_other_row > 2 or brad_other_col > 2:
					continue
				if state.form[brad_other_row][brad_other_col] != null:
					brad_other_corners += 1
			if brad_other_sides == 0 and brad_other_corners == 4:
				guess += 2
			elif brad_other_sides == 1 and brad_other_corners == 4:
				guess -= 2
		for brad_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var brad_diag_row = row + brad_corner.x
			var brad_diag_col = col + brad_corner.y
			if brad_diag_row < 0 or brad_diag_col < 0 or brad_diag_row > 2 or brad_diag_col > 2:
				continue
			if state.form[brad_diag_row][brad_diag_col] == null:
				continue
			var brad_diag_sides = 0
			var brad_diag_corners = 0
			for brad_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var brad_other_row = brad_diag_row + brad_other.x
				var brad_other_col = brad_diag_col + brad_other.y
				if brad_other_row < 0 or brad_other_col < 0 or brad_other_row > 2 or brad_other_col > 2:
					continue
				if state.form[brad_other_row][brad_other_col] != null:
					brad_diag_sides += 1
			for brad_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var brad_other_row = brad_diag_row + brad_other.x
				var brad_other_col = brad_diag_col + brad_other.y
				if brad_other_row < 0 or brad_other_col < 0 or brad_other_row > 2 or brad_other_col > 2:
					continue
				if brad_other_row == row and brad_other_col == col:
					continue
				if state.form[brad_other_row][brad_other_col] != null:
					brad_diag_corners += 1
			if brad_diag_corners == 3 and brad_diag_sides == 1:
				guess += 2
			elif brad_diag_corners == 4 and brad_diag_sides == 1:
				guess -= 2
	if rule == "double_bight_blank":
		var bightb_before_row = row
		var bightb_before_col = col - 3
		while bightb_before_col < 0:
			bightb_before_row -= 1
			bightb_before_col += 3
		var bightb_after_row = row
		var bightb_after_col = col + 1
		while bightb_after_col > 2:
			bightb_after_row += 1
			bightb_after_col -= 3
		var bightb_before_empty = bightb_before_row >= 0 and state.form[bightb_before_row][bightb_before_col] == null
		var bightb_after_empty = bightb_after_row <= 2 and state.form[bightb_after_row][bightb_after_col] == null
		if bightb_before_empty and bightb_after_empty:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var bightb_prior_row = row
		var bightb_prior_col = col - 1
		while bightb_prior_col < 0:
			bightb_prior_row -= 1
			bightb_prior_col += 3
		if bightb_prior_row >= 0 and state.form[bightb_prior_row][bightb_prior_col] != null:
			var bightb_prior = state.form[bightb_prior_row][bightb_prior_col]
			var bightb_prior_before_row = bightb_prior_row
			var bightb_prior_before_col = bightb_prior_col - 3
			while bightb_prior_before_col < 0:
				bightb_prior_before_row -= 1
				bightb_prior_before_col += 3
			if bightb_prior_before_row >= 0 and state.form[bightb_prior_before_row][bightb_prior_before_col] == null:
				guess -= _stamp_number(state, String(bightb_prior["card_id"]), bightb_prior_row, bightb_prior_col)
		var bightb_later_row = row
		var bightb_later_col = col + 3
		while bightb_later_col > 2:
			bightb_later_row += 1
			bightb_later_col -= 3
		if bightb_later_row <= 2 and state.form[bightb_later_row][bightb_later_col] != null:
			var bightb_later = state.form[bightb_later_row][bightb_later_col]
			var bightb_later_after_row = bightb_later_row
			var bightb_later_after_col = bightb_later_col + 1
			while bightb_later_after_col > 2:
				bightb_later_after_row += 1
				bightb_later_after_col -= 3
			if bightb_later_after_row <= 2 and state.form[bightb_later_after_row][bightb_later_after_col] == null:
				guess -= _stamp_number(state, String(bightb_later["card_id"]), bightb_later_row, bightb_later_col)
	if rule == "drop_if_kerf_count":
		var kerf_filled = 0
		for kerf_row in 3:
			for kerf_col in 3:
				if state.form[kerf_row][kerf_col] != null:
					kerf_filled += 1
		var kerf_next = kerf_filled + 1
		if kerf_next == 4 or kerf_next == 7:
			guess -= 4
		elif kerf_filled == 4 or kerf_filled == 7:
			guess += 5
	if rule == "double_crook_fill":
		var crook_before_row = row
		var crook_before_col = col - 4
		while crook_before_col < 0:
			crook_before_row -= 1
			crook_before_col += 3
		var crook_after_row = row
		var crook_after_col = col + 1
		while crook_after_col > 2:
			crook_after_row += 1
			crook_after_col -= 3
		var crook_before_filled = crook_before_row >= 0 and state.form[crook_before_row][crook_before_col] != null
		var crook_after_filled = crook_after_row <= 2 and state.form[crook_after_row][crook_after_col] != null
		if crook_before_filled and crook_after_filled:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var crook_prior_row = row
		var crook_prior_col = col - 1
		while crook_prior_col < 0:
			crook_prior_row -= 1
			crook_prior_col += 3
		if crook_prior_row >= 0 and state.form[crook_prior_row][crook_prior_col] != null:
			var crook_prior = state.form[crook_prior_row][crook_prior_col]
			var crook_prior_before_row = crook_prior_row
			var crook_prior_before_col = crook_prior_col - 4
			while crook_prior_before_col < 0:
				crook_prior_before_row -= 1
				crook_prior_before_col += 3
			if crook_prior_before_row >= 0 and state.form[crook_prior_before_row][crook_prior_before_col] != null:
				guess += _stamp_number(state, String(crook_prior["card_id"]), crook_prior_row, crook_prior_col)
		var crook_later_row = row
		var crook_later_col = col + 4
		while crook_later_col > 2:
			crook_later_row += 1
			crook_later_col -= 3
		if crook_later_row <= 2 and state.form[crook_later_row][crook_later_col] != null:
			var crook_later = state.form[crook_later_row][crook_later_col]
			var crook_later_after_row = crook_later_row
			var crook_later_after_col = crook_later_col + 1
			while crook_later_after_col > 2:
				crook_later_after_row += 1
				crook_later_after_col -= 3
			if crook_later_after_row <= 2 and state.form[crook_later_after_row][crook_later_after_col] != null:
				guess += _stamp_number(state, String(crook_later["card_id"]), crook_later_row, crook_later_col)
	if rule == "yield_rivet_pay":
		var rivet_sides = 0
		var rivet_corners = 0
		for rivet_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var rivet_side_row = row + rivet_side.x
			var rivet_side_col = col + rivet_side.y
			if rivet_side_row < 0 or rivet_side_col < 0 or rivet_side_row > 2 or rivet_side_col > 2:
				continue
			if state.form[rivet_side_row][rivet_side_col] != null:
				rivet_sides += 1
		for rivet_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var rivet_corner_row = row + rivet_corner.x
			var rivet_corner_col = col + rivet_corner.y
			if rivet_corner_row < 0 or rivet_corner_col < 0 or rivet_corner_row > 2 or rivet_corner_col > 2:
				continue
			if state.form[rivet_corner_row][rivet_corner_col] != null:
				rivet_corners += 1
		if rivet_sides == 2 and rivet_corners == 4:
			guess += 4
		else:
			guess -= 1
		for rivet_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var rivet_near_row = row + rivet_side.x
			var rivet_near_col = col + rivet_side.y
			if rivet_near_row < 0 or rivet_near_col < 0 or rivet_near_row > 2 or rivet_near_col > 2:
				continue
			if state.form[rivet_near_row][rivet_near_col] == null:
				continue
			var rivet_other_sides = 0
			var rivet_other_corners = 0
			for rivet_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var rivet_other_row = rivet_near_row + rivet_other.x
				var rivet_other_col = rivet_near_col + rivet_other.y
				if rivet_other_row < 0 or rivet_other_col < 0 or rivet_other_row > 2 or rivet_other_col > 2:
					continue
				if rivet_other_row == row and rivet_other_col == col:
					continue
				if state.form[rivet_other_row][rivet_other_col] != null:
					rivet_other_sides += 1
			for rivet_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var rivet_other_row = rivet_near_row + rivet_other.x
				var rivet_other_col = rivet_near_col + rivet_other.y
				if rivet_other_row < 0 or rivet_other_col < 0 or rivet_other_row > 2 or rivet_other_col > 2:
					continue
				if state.form[rivet_other_row][rivet_other_col] != null:
					rivet_other_corners += 1
			if rivet_other_sides == 1 and rivet_other_corners == 4:
				guess += 2
			elif rivet_other_sides == 2 and rivet_other_corners == 4:
				guess -= 2
		for rivet_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var rivet_diag_row = row + rivet_corner.x
			var rivet_diag_col = col + rivet_corner.y
			if rivet_diag_row < 0 or rivet_diag_col < 0 or rivet_diag_row > 2 or rivet_diag_col > 2:
				continue
			if state.form[rivet_diag_row][rivet_diag_col] == null:
				continue
			var rivet_diag_sides = 0
			var rivet_diag_corners = 0
			for rivet_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var rivet_other_row = rivet_diag_row + rivet_other.x
				var rivet_other_col = rivet_diag_col + rivet_other.y
				if rivet_other_row < 0 or rivet_other_col < 0 or rivet_other_row > 2 or rivet_other_col > 2:
					continue
				if state.form[rivet_other_row][rivet_other_col] != null:
					rivet_diag_sides += 1
			for rivet_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var rivet_other_row = rivet_diag_row + rivet_other.x
				var rivet_other_col = rivet_diag_col + rivet_other.y
				if rivet_other_row < 0 or rivet_other_col < 0 or rivet_other_row > 2 or rivet_other_col > 2:
					continue
				if rivet_other_row == row and rivet_other_col == col:
					continue
				if state.form[rivet_other_row][rivet_other_col] != null:
					rivet_diag_corners += 1
			if rivet_diag_corners == 3 and rivet_diag_sides == 2:
				guess += 2
			elif rivet_diag_corners == 4 and rivet_diag_sides == 2:
				guess -= 2
	if rule == "double_crook_blank":
		var crookb_before_row = row
		var crookb_before_col = col - 4
		while crookb_before_col < 0:
			crookb_before_row -= 1
			crookb_before_col += 3
		var crookb_after_row = row
		var crookb_after_col = col + 1
		while crookb_after_col > 2:
			crookb_after_row += 1
			crookb_after_col -= 3
		var crookb_before_empty = crookb_before_row >= 0 and state.form[crookb_before_row][crookb_before_col] == null
		var crookb_after_empty = crookb_after_row <= 2 and state.form[crookb_after_row][crookb_after_col] == null
		if crookb_before_empty and crookb_after_empty:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var crookb_prior_row = row
		var crookb_prior_col = col - 1
		while crookb_prior_col < 0:
			crookb_prior_row -= 1
			crookb_prior_col += 3
		if crookb_prior_row >= 0 and state.form[crookb_prior_row][crookb_prior_col] != null:
			var crookb_prior = state.form[crookb_prior_row][crookb_prior_col]
			var crookb_prior_before_row = crookb_prior_row
			var crookb_prior_before_col = crookb_prior_col - 4
			while crookb_prior_before_col < 0:
				crookb_prior_before_row -= 1
				crookb_prior_before_col += 3
			if crookb_prior_before_row >= 0 and state.form[crookb_prior_before_row][crookb_prior_before_col] == null:
				guess -= _stamp_number(state, String(crookb_prior["card_id"]), crookb_prior_row, crookb_prior_col)
		var crookb_later_row = row
		var crookb_later_col = col + 4
		while crookb_later_col > 2:
			crookb_later_row += 1
			crookb_later_col -= 3
		if crookb_later_row <= 2 and state.form[crookb_later_row][crookb_later_col] != null:
			var crookb_later = state.form[crookb_later_row][crookb_later_col]
			var crookb_later_after_row = crookb_later_row
			var crookb_later_after_col = crookb_later_col + 1
			while crookb_later_after_col > 2:
				crookb_later_after_row += 1
				crookb_later_after_col -= 3
			if crookb_later_after_row <= 2 and state.form[crookb_later_after_row][crookb_later_after_col] == null:
				guess -= _stamp_number(state, String(crookb_later["card_id"]), crookb_later_row, crookb_later_col)
	if rule == "drop_if_ream_count":
		var ream_filled = 0
		for ream_row in 3:
			for ream_col in 3:
				if state.form[ream_row][ream_col] != null:
					ream_filled += 1
		var ream_next = ream_filled + 1
		if ream_next == 5 or ream_next == 8:
			guess -= 4
		elif ream_filled == 5 or ream_filled == 8:
			guess += 5
	if rule == "double_bend_fill":
		var bend_before_row = row
		var bend_before_col = col - 5
		while bend_before_col < 0:
			bend_before_row -= 1
			bend_before_col += 3
		var bend_after_row = row
		var bend_after_col = col + 1
		while bend_after_col > 2:
			bend_after_row += 1
			bend_after_col -= 3
		var bend_before_filled = bend_before_row >= 0 and state.form[bend_before_row][bend_before_col] != null
		var bend_after_filled = bend_after_row <= 2 and state.form[bend_after_row][bend_after_col] != null
		if bend_before_filled and bend_after_filled:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var bend_prior_row = row
		var bend_prior_col = col - 1
		while bend_prior_col < 0:
			bend_prior_row -= 1
			bend_prior_col += 3
		if bend_prior_row >= 0 and state.form[bend_prior_row][bend_prior_col] != null:
			var bend_prior = state.form[bend_prior_row][bend_prior_col]
			var bend_prior_before_row = bend_prior_row
			var bend_prior_before_col = bend_prior_col - 5
			while bend_prior_before_col < 0:
				bend_prior_before_row -= 1
				bend_prior_before_col += 3
			if bend_prior_before_row >= 0 and state.form[bend_prior_before_row][bend_prior_before_col] != null:
				guess += _stamp_number(state, String(bend_prior["card_id"]), bend_prior_row, bend_prior_col)
		var bend_later_row = row
		var bend_later_col = col + 5
		while bend_later_col > 2:
			bend_later_row += 1
			bend_later_col -= 3
		if bend_later_row <= 2 and state.form[bend_later_row][bend_later_col] != null:
			var bend_later = state.form[bend_later_row][bend_later_col]
			var bend_later_after_row = bend_later_row
			var bend_later_after_col = bend_later_col + 1
			while bend_later_after_col > 2:
				bend_later_after_row += 1
				bend_later_after_col -= 3
			if bend_later_after_row <= 2 and state.form[bend_later_after_row][bend_later_after_col] != null:
				guess += _stamp_number(state, String(bend_later["card_id"]), bend_later_row, bend_later_col)
	if rule == "yield_clinch_pay":
		var clinch_sides = 0
		var clinch_corners = 0
		for clinch_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var clinch_side_row = row + clinch_side.x
			var clinch_side_col = col + clinch_side.y
			if clinch_side_row < 0 or clinch_side_col < 0 or clinch_side_row > 2 or clinch_side_col > 2:
				continue
			if state.form[clinch_side_row][clinch_side_col] != null:
				clinch_sides += 1
		for clinch_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var clinch_corner_row = row + clinch_corner.x
			var clinch_corner_col = col + clinch_corner.y
			if clinch_corner_row < 0 or clinch_corner_col < 0 or clinch_corner_row > 2 or clinch_corner_col > 2:
				continue
			if state.form[clinch_corner_row][clinch_corner_col] != null:
				clinch_corners += 1
		if clinch_sides == 3 and clinch_corners == 4:
			guess += 4
		else:
			guess -= 1
		for clinch_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var clinch_near_row = row + clinch_side.x
			var clinch_near_col = col + clinch_side.y
			if clinch_near_row < 0 or clinch_near_col < 0 or clinch_near_row > 2 or clinch_near_col > 2:
				continue
			if state.form[clinch_near_row][clinch_near_col] == null:
				continue
			var clinch_other_sides = 0
			var clinch_other_corners = 0
			for clinch_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var clinch_other_row = clinch_near_row + clinch_other.x
				var clinch_other_col = clinch_near_col + clinch_other.y
				if clinch_other_row < 0 or clinch_other_col < 0 or clinch_other_row > 2 or clinch_other_col > 2:
					continue
				if clinch_other_row == row and clinch_other_col == col:
					continue
				if state.form[clinch_other_row][clinch_other_col] != null:
					clinch_other_sides += 1
			for clinch_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var clinch_other_row = clinch_near_row + clinch_other.x
				var clinch_other_col = clinch_near_col + clinch_other.y
				if clinch_other_row < 0 or clinch_other_col < 0 or clinch_other_row > 2 or clinch_other_col > 2:
					continue
				if state.form[clinch_other_row][clinch_other_col] != null:
					clinch_other_corners += 1
			if clinch_other_sides == 2 and clinch_other_corners == 4:
				guess += 2
			elif clinch_other_sides == 3 and clinch_other_corners == 4:
				guess -= 2
		for clinch_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var clinch_diag_row = row + clinch_corner.x
			var clinch_diag_col = col + clinch_corner.y
			if clinch_diag_row < 0 or clinch_diag_col < 0 or clinch_diag_row > 2 or clinch_diag_col > 2:
				continue
			if state.form[clinch_diag_row][clinch_diag_col] == null:
				continue
			var clinch_diag_sides = 0
			var clinch_diag_corners = 0
			for clinch_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var clinch_other_row = clinch_diag_row + clinch_other.x
				var clinch_other_col = clinch_diag_col + clinch_other.y
				if clinch_other_row < 0 or clinch_other_col < 0 or clinch_other_row > 2 or clinch_other_col > 2:
					continue
				if state.form[clinch_other_row][clinch_other_col] != null:
					clinch_diag_sides += 1
			for clinch_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var clinch_other_row = clinch_diag_row + clinch_other.x
				var clinch_other_col = clinch_diag_col + clinch_other.y
				if clinch_other_row < 0 or clinch_other_col < 0 or clinch_other_row > 2 or clinch_other_col > 2:
					continue
				if clinch_other_row == row and clinch_other_col == col:
					continue
				if state.form[clinch_other_row][clinch_other_col] != null:
					clinch_diag_corners += 1
			if clinch_diag_corners == 3 and clinch_diag_sides == 3:
				guess += 2
			elif clinch_diag_corners == 4 and clinch_diag_sides == 3:
				guess -= 2
	if rule == "double_bend_blank":
		var bendb_before_row = row
		var bendb_before_col = col - 5
		while bendb_before_col < 0:
			bendb_before_row -= 1
			bendb_before_col += 3
		var bendb_after_row = row
		var bendb_after_col = col + 1
		while bendb_after_col > 2:
			bendb_after_row += 1
			bendb_after_col -= 3
		var bendb_before_empty = bendb_before_row >= 0 and state.form[bendb_before_row][bendb_before_col] == null
		var bendb_after_empty = bendb_after_row <= 2 and state.form[bendb_after_row][bendb_after_col] == null
		if bendb_before_empty and bendb_after_empty:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var bendb_prior_row = row
		var bendb_prior_col = col - 1
		while bendb_prior_col < 0:
			bendb_prior_row -= 1
			bendb_prior_col += 3
		if bendb_prior_row >= 0 and state.form[bendb_prior_row][bendb_prior_col] != null:
			var bendb_prior = state.form[bendb_prior_row][bendb_prior_col]
			var bendb_prior_before_row = bendb_prior_row
			var bendb_prior_before_col = bendb_prior_col - 5
			while bendb_prior_before_col < 0:
				bendb_prior_before_row -= 1
				bendb_prior_before_col += 3
			if bendb_prior_before_row >= 0 and state.form[bendb_prior_before_row][bendb_prior_before_col] == null:
				guess -= _stamp_number(state, String(bendb_prior["card_id"]), bendb_prior_row, bendb_prior_col)
		var bendb_later_row = row
		var bendb_later_col = col + 5
		while bendb_later_col > 2:
			bendb_later_row += 1
			bendb_later_col -= 3
		if bendb_later_row <= 2 and state.form[bendb_later_row][bendb_later_col] != null:
			var bendb_later = state.form[bendb_later_row][bendb_later_col]
			var bendb_later_after_row = bendb_later_row
			var bendb_later_after_col = bendb_later_col + 1
			while bendb_later_after_col > 2:
				bendb_later_after_row += 1
				bendb_later_after_col -= 3
			if bendb_later_after_row <= 2 and state.form[bendb_later_after_row][bendb_later_after_col] == null:
				guess -= _stamp_number(state, String(bendb_later["card_id"]), bendb_later_row, bendb_later_col)
	if rule == "drop_if_burr_count":
		var burr_filled = 0
		for burr_row in 3:
			for burr_col in 3:
				if state.form[burr_row][burr_col] != null:
					burr_filled += 1
		var burr_next = burr_filled + 1
		if burr_next == 6 or burr_next == 9:
			guess -= 4
		elif burr_filled == 6 or burr_filled == 9:
			guess += 5
	if rule == "double_kink_fill":
		var kink_before_row = row
		var kink_before_col = col - 6
		while kink_before_col < 0:
			kink_before_row -= 1
			kink_before_col += 3
		var kink_after_row = row
		var kink_after_col = col + 1
		while kink_after_col > 2:
			kink_after_row += 1
			kink_after_col -= 3
		var kink_before_filled = kink_before_row >= 0 and state.form[kink_before_row][kink_before_col] != null
		var kink_after_filled = kink_after_row <= 2 and state.form[kink_after_row][kink_after_col] != null
		if kink_before_filled and kink_after_filled:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var kink_prior_row = row
		var kink_prior_col = col - 1
		while kink_prior_col < 0:
			kink_prior_row -= 1
			kink_prior_col += 3
		if kink_prior_row >= 0 and state.form[kink_prior_row][kink_prior_col] != null:
			var kink_prior = state.form[kink_prior_row][kink_prior_col]
			var kink_prior_before_row = kink_prior_row
			var kink_prior_before_col = kink_prior_col - 6
			while kink_prior_before_col < 0:
				kink_prior_before_row -= 1
				kink_prior_before_col += 3
			if kink_prior_before_row >= 0 and state.form[kink_prior_before_row][kink_prior_before_col] != null:
				guess += _stamp_number(state, String(kink_prior["card_id"]), kink_prior_row, kink_prior_col)
		var kink_later_row = row
		var kink_later_col = col + 6
		while kink_later_col > 2:
			kink_later_row += 1
			kink_later_col -= 3
		if kink_later_row <= 2 and state.form[kink_later_row][kink_later_col] != null:
			var kink_later = state.form[kink_later_row][kink_later_col]
			var kink_later_after_row = kink_later_row
			var kink_later_after_col = kink_later_col + 1
			while kink_later_after_col > 2:
				kink_later_after_row += 1
				kink_later_after_col -= 3
			if kink_later_after_row <= 2 and state.form[kink_later_after_row][kink_later_after_col] != null:
				guess += _stamp_number(state, String(kink_later["card_id"]), kink_later_row, kink_later_col)
	if rule == "yield_clench_pay":
		var clench_sides = 0
		var clench_corners = 0
		for clench_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var clench_side_row = row + clench_side.x
			var clench_side_col = col + clench_side.y
			if clench_side_row < 0 or clench_side_col < 0 or clench_side_row > 2 or clench_side_col > 2:
				continue
			if state.form[clench_side_row][clench_side_col] != null:
				clench_sides += 1
		for clench_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var clench_corner_row = row + clench_corner.x
			var clench_corner_col = col + clench_corner.y
			if clench_corner_row < 0 or clench_corner_col < 0 or clench_corner_row > 2 or clench_corner_col > 2:
				continue
			if state.form[clench_corner_row][clench_corner_col] != null:
				clench_corners += 1
		if clench_sides == 4 and clench_corners == 4:
			guess += 4
		else:
			guess -= 1
		for clench_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var clench_near_row = row + clench_side.x
			var clench_near_col = col + clench_side.y
			if clench_near_row < 0 or clench_near_col < 0 or clench_near_row > 2 or clench_near_col > 2:
				continue
			if state.form[clench_near_row][clench_near_col] == null:
				continue
			var clench_other_sides = 0
			var clench_other_corners = 0
			for clench_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var clench_other_row = clench_near_row + clench_other.x
				var clench_other_col = clench_near_col + clench_other.y
				if clench_other_row < 0 or clench_other_col < 0 or clench_other_row > 2 or clench_other_col > 2:
					continue
				if clench_other_row == row and clench_other_col == col:
					continue
				if state.form[clench_other_row][clench_other_col] != null:
					clench_other_sides += 1
			for clench_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var clench_other_row = clench_near_row + clench_other.x
				var clench_other_col = clench_near_col + clench_other.y
				if clench_other_row < 0 or clench_other_col < 0 or clench_other_row > 2 or clench_other_col > 2:
					continue
				if state.form[clench_other_row][clench_other_col] != null:
					clench_other_corners += 1
			if clench_other_sides == 3 and clench_other_corners == 4:
				guess += 2
			elif clench_other_sides == 4 and clench_other_corners == 4:
				guess -= 2
		for clench_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var clench_diag_row = row + clench_corner.x
			var clench_diag_col = col + clench_corner.y
			if clench_diag_row < 0 or clench_diag_col < 0 or clench_diag_row > 2 or clench_diag_col > 2:
				continue
			if state.form[clench_diag_row][clench_diag_col] == null:
				continue
			var clench_diag_sides = 0
			var clench_diag_corners = 0
			for clench_other in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
				var clench_other_row = clench_diag_row + clench_other.x
				var clench_other_col = clench_diag_col + clench_other.y
				if clench_other_row < 0 or clench_other_col < 0 or clench_other_row > 2 or clench_other_col > 2:
					continue
				if state.form[clench_other_row][clench_other_col] != null:
					clench_diag_sides += 1
			for clench_other in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
				var clench_other_row = clench_diag_row + clench_other.x
				var clench_other_col = clench_diag_col + clench_other.y
				if clench_other_row < 0 or clench_other_col < 0 or clench_other_row > 2 or clench_other_col > 2:
					continue
				if clench_other_row == row and clench_other_col == col:
					continue
				if state.form[clench_other_row][clench_other_col] != null:
					clench_diag_corners += 1
			if clench_diag_corners == 3 and clench_diag_sides == 4:
				guess += 2
			elif clench_diag_corners == 4 and clench_diag_sides == 4:
				guess -= 2
	if rule == "double_kink_blank":
		var kinkb_before_row = row
		var kinkb_before_col = col - 6
		while kinkb_before_col < 0:
			kinkb_before_row -= 1
			kinkb_before_col += 3
		var kinkb_after_row = row
		var kinkb_after_col = col + 1
		while kinkb_after_col > 2:
			kinkb_after_row += 1
			kinkb_after_col -= 3
		var kinkb_before_empty = kinkb_before_row >= 0 and state.form[kinkb_before_row][kinkb_before_col] == null
		var kinkb_after_empty = kinkb_after_row <= 2 and state.form[kinkb_after_row][kinkb_after_col] == null
		if kinkb_before_empty and kinkb_after_empty:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var kinkb_prior_row = row
		var kinkb_prior_col = col - 1
		while kinkb_prior_col < 0:
			kinkb_prior_row -= 1
			kinkb_prior_col += 3
		if kinkb_prior_row >= 0 and state.form[kinkb_prior_row][kinkb_prior_col] != null:
			var kinkb_prior = state.form[kinkb_prior_row][kinkb_prior_col]
			var kinkb_prior_before_row = kinkb_prior_row
			var kinkb_prior_before_col = kinkb_prior_col - 6
			while kinkb_prior_before_col < 0:
				kinkb_prior_before_row -= 1
				kinkb_prior_before_col += 3
			if kinkb_prior_before_row >= 0 and state.form[kinkb_prior_before_row][kinkb_prior_before_col] == null:
				guess -= _stamp_number(state, String(kinkb_prior["card_id"]), kinkb_prior_row, kinkb_prior_col)
		var kinkb_later_row = row
		var kinkb_later_col = col + 6
		while kinkb_later_col > 2:
			kinkb_later_row += 1
			kinkb_later_col -= 3
		if kinkb_later_row <= 2 and state.form[kinkb_later_row][kinkb_later_col] != null:
			var kinkb_later = state.form[kinkb_later_row][kinkb_later_col]
			var kinkb_later_after_row = kinkb_later_row
			var kinkb_later_after_col = kinkb_later_col + 1
			while kinkb_later_after_col > 2:
				kinkb_later_after_row += 1
				kinkb_later_after_col -= 3
			if kinkb_later_after_row <= 2 and state.form[kinkb_later_after_row][kinkb_later_after_col] == null:
				guess -= _stamp_number(state, String(kinkb_later["card_id"]), kinkb_later_row, kinkb_later_col)
	if rule == "drop_if_chamfer_count":
		var chamfer_filled = 0
		for chamfer_row in 3:
			for chamfer_col in 3:
				if state.form[chamfer_row][chamfer_col] != null:
					chamfer_filled += 1
		var chamfer_next = chamfer_filled + 1
		if chamfer_next == 7 or chamfer_next == 10:
			guess -= 4
		elif chamfer_filled == 7 or chamfer_filled == 10:
			guess += 5
	if rule == "double_nick_fill":
		var nick_before_row = row
		var nick_before_col = col - 7
		while nick_before_col < 0:
			nick_before_row -= 1
			nick_before_col += 3
		var nick_after_row = row
		var nick_after_col = col + 1
		while nick_after_col > 2:
			nick_after_row += 1
			nick_after_col -= 3
		var nick_before_filled = nick_before_row >= 0 and state.form[nick_before_row][nick_before_col] != null
		var nick_after_filled = nick_after_row <= 2 and state.form[nick_after_row][nick_after_col] != null
		if nick_before_filled and nick_after_filled:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var nick_prior_row = row
		var nick_prior_col = col - 1
		while nick_prior_col < 0:
			nick_prior_row -= 1
			nick_prior_col += 3
		if nick_prior_row >= 0 and state.form[nick_prior_row][nick_prior_col] != null:
			var nick_prior = state.form[nick_prior_row][nick_prior_col]
			var nick_prior_before_row = nick_prior_row
			var nick_prior_before_col = nick_prior_col - 7
			while nick_prior_before_col < 0:
				nick_prior_before_row -= 1
				nick_prior_before_col += 3
			if nick_prior_before_row >= 0 and state.form[nick_prior_before_row][nick_prior_before_col] != null:
				guess += _stamp_number(state, String(nick_prior["card_id"]), nick_prior_row, nick_prior_col)
		var nick_later_row = row
		var nick_later_col = col + 7
		while nick_later_col > 2:
			nick_later_row += 1
			nick_later_col -= 3
		if nick_later_row <= 2 and state.form[nick_later_row][nick_later_col] != null:
			var nick_later = state.form[nick_later_row][nick_later_col]
			var nick_later_after_row = nick_later_row
			var nick_later_after_col = nick_later_col + 1
			while nick_later_after_col > 2:
				nick_later_after_row += 1
				nick_later_after_col -= 3
			if nick_later_after_row <= 2 and state.form[nick_later_after_row][nick_later_after_col] != null:
				guess += _stamp_number(state, String(nick_later["card_id"]), nick_later_row, nick_later_col)
	if rule == "yield_stake_pay":
		var stake_sides = 0
		var stake_corners = 0
		for stake_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var stake_side_row = row + stake_side.x
			var stake_side_col = col + stake_side.y
			if stake_side_row < 0 or stake_side_col < 0 or stake_side_row > 2 or stake_side_col > 2:
				continue
			if state.form[stake_side_row][stake_side_col] != null:
				stake_sides += 1
		for stake_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var stake_corner_row = row + stake_corner.x
			var stake_corner_col = col + stake_corner.y
			if stake_corner_row < 0 or stake_corner_col < 0 or stake_corner_row > 2 or stake_corner_col > 2:
				continue
			if state.form[stake_corner_row][stake_corner_col] != null:
				stake_corners += 1
		if stake_sides == 5 and stake_corners == 4:
			guess += 4
		else:
			guess -= 1
	if rule == "double_nick_blank":
		var nickb_before_row = row
		var nickb_before_col = col - 7
		while nickb_before_col < 0:
			nickb_before_row -= 1
			nickb_before_col += 3
		var nickb_after_row = row
		var nickb_after_col = col + 1
		while nickb_after_col > 2:
			nickb_after_row += 1
			nickb_after_col -= 3
		var nickb_before_empty = nickb_before_row >= 0 and state.form[nickb_before_row][nickb_before_col] == null
		var nickb_after_empty = nickb_after_row <= 2 and state.form[nickb_after_row][nickb_after_col] == null
		if nickb_before_empty and nickb_after_empty:
			guess += _stamp_number(state, card_id, row, col)
		else:
			guess -= 4
		var nickb_prior_row = row
		var nickb_prior_col = col - 1
		while nickb_prior_col < 0:
			nickb_prior_row -= 1
			nickb_prior_col += 3
		if nickb_prior_row >= 0 and state.form[nickb_prior_row][nickb_prior_col] != null:
			var nickb_prior = state.form[nickb_prior_row][nickb_prior_col]
			var nickb_prior_before_row = nickb_prior_row
			var nickb_prior_before_col = nickb_prior_col - 7
			while nickb_prior_before_col < 0:
				nickb_prior_before_row -= 1
				nickb_prior_before_col += 3
			if nickb_prior_before_row >= 0 and state.form[nickb_prior_before_row][nickb_prior_before_col] == null:
				guess -= _stamp_number(state, String(nickb_prior["card_id"]), nickb_prior_row, nickb_prior_col)
		var nickb_later_row = row
		var nickb_later_col = col + 7
		while nickb_later_col > 2:
			nickb_later_row += 1
			nickb_later_col -= 3
		if nickb_later_row <= 2 and state.form[nickb_later_row][nickb_later_col] != null:
			var nickb_later = state.form[nickb_later_row][nickb_later_col]
			var nickb_later_after_row = nickb_later_row
			var nickb_later_after_col = nickb_later_col + 1
			while nickb_later_after_col > 2:
				nickb_later_after_row += 1
				nickb_later_after_col -= 3
			if nickb_later_after_row <= 2 and state.form[nickb_later_after_row][nickb_later_after_col] == null:
				guess -= _stamp_number(state, String(nickb_later["card_id"]), nickb_later_row, nickb_later_col)
	if rule == "drop_if_broach_count":
		var broach_filled = 0
		for broach_row in 3:
			for broach_col in 3:
				if state.form[broach_row][broach_col] != null:
					broach_filled += 1
		var broach_next = broach_filled + 1
		if broach_next == 8 or broach_next == 11:
			guess -= 4
		elif broach_filled == 8 or broach_filled == 11:
			guess += 5
	if rule == "double_jog_fill":
		var jog_before_row = row
		var jog_before_col = col - 8
		while jog_before_col < 0:
			jog_before_row -= 1
			jog_before_col += 3
		var jog_after_row = row
		var jog_after_col = col + 1
		while jog_after_col > 2:
			jog_after_row += 1
			jog_after_col -= 3
		var jog_before_filled = jog_before_row >= 0 and state.form[jog_before_row][jog_before_col] != null
		var jog_after_filled = jog_after_row <= 2 and state.form[jog_after_row][jog_after_col] != null
		if jog_before_filled and jog_after_filled:
			guess += _stamp_number(state, card_id, row, col)
	if rule == "yield_peen_pay":
		var peen_sides = 0
		var peen_corners = 0
		for peen_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var peen_side_row = row + peen_side.x
			var peen_side_col = col + peen_side.y
			if peen_side_row < 0 or peen_side_col < 0 or peen_side_row > 2 or peen_side_col > 2:
				continue
			if state.form[peen_side_row][peen_side_col] != null:
				peen_sides += 1
		for peen_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var peen_corner_row = row + peen_corner.x
			var peen_corner_col = col + peen_corner.y
			if peen_corner_row < 0 or peen_corner_col < 0 or peen_corner_row > 2 or peen_corner_col > 2:
				continue
			if state.form[peen_corner_row][peen_corner_col] != null:
				peen_corners += 1
		if peen_sides == 6 and peen_corners == 4:
			guess += 4
		else:
			guess -= 1
	if rule == "double_jog_blank":
		var jogb_before_row = row
		var jogb_before_col = col - 8
		while jogb_before_col < 0:
			jogb_before_row -= 1
			jogb_before_col += 3
		var jogb_after_row = row
		var jogb_after_col = col + 1
		while jogb_after_col > 2:
			jogb_after_row += 1
			jogb_after_col -= 3
		var jogb_before_empty = jogb_before_row >= 0 and state.form[jogb_before_row][jogb_before_col] == null
		var jogb_after_empty = jogb_after_row <= 2 and state.form[jogb_after_row][jogb_after_col] == null
		if jogb_before_empty and jogb_after_empty:
			guess += _stamp_number(state, card_id, row, col)
	if rule == "drop_if_awl_count":
		var awl_filled = 0
		for awl_row in 3:
			for awl_col in 3:
				if state.form[awl_row][awl_col] != null:
					awl_filled += 1
		var awl_next = awl_filled + 1
		if awl_next == 13 or awl_next == 16:
			guess -= 4
		elif awl_filled == 13 or awl_filled == 16:
			guess += 5
	if rule == "double_groove_fill":
		var groove_before_row = row
		var groove_before_col = col - 13
		while groove_before_col < 0:
			groove_before_row -= 1
			groove_before_col += 3
		var groove_after_row = row
		var groove_after_col = col + 1
		while groove_after_col > 2:
			groove_after_row += 1
			groove_after_col -= 3
		var groove_before_filled = groove_before_row >= 0 and state.form[groove_before_row][groove_before_col] != null
		var groove_after_filled = groove_after_row <= 2 and state.form[groove_after_row][groove_after_col] != null
		if groove_before_filled and groove_after_filled:
			guess += _stamp_number(state, card_id, row, col)
	if rule == "yield_sprig_pay":
		var sprig_sides = 0
		var sprig_corners = 0
		for sprig_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var sprig_side_row = row + sprig_side.x
			var sprig_side_col = col + sprig_side.y
			if sprig_side_row < 0 or sprig_side_col < 0 or sprig_side_row > 2 or sprig_side_col > 2:
				continue
			if state.form[sprig_side_row][sprig_side_col] != null:
				sprig_sides += 1
		for sprig_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var sprig_corner_row = row + sprig_corner.x
			var sprig_corner_col = col + sprig_corner.y
			if sprig_corner_row < 0 or sprig_corner_col < 0 or sprig_corner_row > 2 or sprig_corner_col > 2:
				continue
			if state.form[sprig_corner_row][sprig_corner_col] != null:
				sprig_corners += 1
		if sprig_sides == 11 and sprig_corners == 4:
			guess += 4
		else:
			guess -= 1
	if rule == "double_groove_blank":
		var grooveb_before_row = row
		var grooveb_before_col = col - 13
		while grooveb_before_col < 0:
			grooveb_before_row -= 1
			grooveb_before_col += 3
		var grooveb_after_row = row
		var grooveb_after_col = col + 1
		while grooveb_after_col > 2:
			grooveb_after_row += 1
			grooveb_after_col -= 3
		var grooveb_before_empty = grooveb_before_row >= 0 and state.form[grooveb_before_row][grooveb_before_col] == null
		var grooveb_after_empty = grooveb_after_row <= 2 and state.form[grooveb_after_row][grooveb_after_col] == null
		if grooveb_before_empty and grooveb_after_empty:
			guess += _stamp_number(state, card_id, row, col)
	if rule == "drop_if_gimlet_count":
		var gimlet_filled = 0
		for gimlet_row in 3:
			for gimlet_col in 3:
				if state.form[gimlet_row][gimlet_col] != null:
					gimlet_filled += 1
		var gimlet_next = gimlet_filled + 1
		if gimlet_next == 12 or gimlet_next == 15:
			guess -= 4
		elif gimlet_filled == 12 or gimlet_filled == 15:
			guess += 5
	if rule == "double_flute_fill":
		var flute_before_row = row
		var flute_before_col = col - 12
		while flute_before_col < 0:
			flute_before_row -= 1
			flute_before_col += 3
		var flute_after_row = row
		var flute_after_col = col + 1
		while flute_after_col > 2:
			flute_after_row += 1
			flute_after_col -= 3
		var flute_before_filled = flute_before_row >= 0 and state.form[flute_before_row][flute_before_col] != null
		var flute_after_filled = flute_after_row <= 2 and state.form[flute_after_row][flute_after_col] != null
		if flute_before_filled and flute_after_filled:
			guess += _stamp_number(state, card_id, row, col)
	if rule == "yield_tack_pay":
		var tack_sides = 0
		var tack_corners = 0
		for tack_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var tack_side_row = row + tack_side.x
			var tack_side_col = col + tack_side.y
			if tack_side_row < 0 or tack_side_col < 0 or tack_side_row > 2 or tack_side_col > 2:
				continue
			if state.form[tack_side_row][tack_side_col] != null:
				tack_sides += 1
		for tack_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var tack_corner_row = row + tack_corner.x
			var tack_corner_col = col + tack_corner.y
			if tack_corner_row < 0 or tack_corner_col < 0 or tack_corner_row > 2 or tack_corner_col > 2:
				continue
			if state.form[tack_corner_row][tack_corner_col] != null:
				tack_corners += 1
		if tack_sides == 10 and tack_corners == 4:
			guess += 4
		else:
			guess -= 1
	if rule == "double_flute_blank":
		var fluteb_before_row = row
		var fluteb_before_col = col - 12
		while fluteb_before_col < 0:
			fluteb_before_row -= 1
			fluteb_before_col += 3
		var fluteb_after_row = row
		var fluteb_after_col = col + 1
		while fluteb_after_col > 2:
			fluteb_after_row += 1
			fluteb_after_col -= 3
		var fluteb_before_empty = fluteb_before_row >= 0 and state.form[fluteb_before_row][fluteb_before_col] == null
		var fluteb_after_empty = fluteb_after_row <= 2 and state.form[fluteb_after_row][fluteb_after_col] == null
		if fluteb_before_empty and fluteb_after_empty:
			guess += _stamp_number(state, card_id, row, col)
	if rule == "drop_if_auger_count":
		var auger_filled = 0
		for auger_row in 3:
			for auger_col in 3:
				if state.form[auger_row][auger_col] != null:
					auger_filled += 1
		var auger_next = auger_filled + 1
		if auger_next == 11 or auger_next == 14:
			guess -= 4
		elif auger_filled == 11 or auger_filled == 14:
			guess += 5
	if rule == "double_wave_fill":
		var wave_before_row = row
		var wave_before_col = col - 11
		while wave_before_col < 0:
			wave_before_row -= 1
			wave_before_col += 3
		var wave_after_row = row
		var wave_after_col = col + 1
		while wave_after_col > 2:
			wave_after_row += 1
			wave_after_col -= 3
		var wave_before_filled = wave_before_row >= 0 and state.form[wave_before_row][wave_before_col] != null
		var wave_after_filled = wave_after_row <= 2 and state.form[wave_after_row][wave_after_col] != null
		if wave_before_filled and wave_after_filled:
			guess += _stamp_number(state, card_id, row, col)
	if rule == "yield_nail_pay":
		var nail_sides = 0
		var nail_corners = 0
		for nail_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var nail_side_row = row + nail_side.x
			var nail_side_col = col + nail_side.y
			if nail_side_row < 0 or nail_side_col < 0 or nail_side_row > 2 or nail_side_col > 2:
				continue
			if state.form[nail_side_row][nail_side_col] != null:
				nail_sides += 1
		for nail_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var nail_corner_row = row + nail_corner.x
			var nail_corner_col = col + nail_corner.y
			if nail_corner_row < 0 or nail_corner_col < 0 or nail_corner_row > 2 or nail_corner_col > 2:
				continue
			if state.form[nail_corner_row][nail_corner_col] != null:
				nail_corners += 1
		if nail_sides == 9 and nail_corners == 4:
			guess += 4
		else:
			guess -= 1
	if rule == "double_wave_blank":
		var waveb_before_row = row
		var waveb_before_col = col - 11
		while waveb_before_col < 0:
			waveb_before_row -= 1
			waveb_before_col += 3
		var waveb_after_row = row
		var waveb_after_col = col + 1
		while waveb_after_col > 2:
			waveb_after_row += 1
			waveb_after_col -= 3
		var waveb_before_empty = waveb_before_row >= 0 and state.form[waveb_before_row][waveb_before_col] == null
		var waveb_after_empty = waveb_after_row <= 2 and state.form[waveb_after_row][waveb_after_col] == null
		if waveb_before_empty and waveb_after_empty:
			guess += _stamp_number(state, card_id, row, col)
	if rule == "drop_if_countersink_count":
		var countersink_filled = 0
		for countersink_row in 3:
			for countersink_col in 3:
				if state.form[countersink_row][countersink_col] != null:
					countersink_filled += 1
		var countersink_next = countersink_filled + 1
		if countersink_next == 10 or countersink_next == 13:
			guess -= 4
		elif countersink_filled == 10 or countersink_filled == 13:
			guess += 5
	if rule == "double_crimp_fill":
		var crimp_before_row = row
		var crimp_before_col = col - 10
		while crimp_before_col < 0:
			crimp_before_row -= 1
			crimp_before_col += 3
		var crimp_after_row = row
		var crimp_after_col = col + 1
		while crimp_after_col > 2:
			crimp_after_row += 1
			crimp_after_col -= 3
		var crimp_before_filled = crimp_before_row >= 0 and state.form[crimp_before_row][crimp_before_col] != null
		var crimp_after_filled = crimp_after_row <= 2 and state.form[crimp_after_row][crimp_after_col] != null
		if crimp_before_filled and crimp_after_filled:
			guess += _stamp_number(state, card_id, row, col)
	if rule == "yield_cotter_pay":
		var cotter_sides = 0
		var cotter_corners = 0
		for cotter_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var cotter_side_row = row + cotter_side.x
			var cotter_side_col = col + cotter_side.y
			if cotter_side_row < 0 or cotter_side_col < 0 or cotter_side_row > 2 or cotter_side_col > 2:
				continue
			if state.form[cotter_side_row][cotter_side_col] != null:
				cotter_sides += 1
		for cotter_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var cotter_corner_row = row + cotter_corner.x
			var cotter_corner_col = col + cotter_corner.y
			if cotter_corner_row < 0 or cotter_corner_col < 0 or cotter_corner_row > 2 or cotter_corner_col > 2:
				continue
			if state.form[cotter_corner_row][cotter_corner_col] != null:
				cotter_corners += 1
		if cotter_sides == 8 and cotter_corners == 4:
			guess += 4
		else:
			guess -= 1
	if rule == "double_crimp_blank":
		var crimpb_before_row = row
		var crimpb_before_col = col - 10
		while crimpb_before_col < 0:
			crimpb_before_row -= 1
			crimpb_before_col += 3
		var crimpb_after_row = row
		var crimpb_after_col = col + 1
		while crimpb_after_col > 2:
			crimpb_after_row += 1
			crimpb_after_col -= 3
		var crimpb_before_empty = crimpb_before_row >= 0 and state.form[crimpb_before_row][crimpb_before_col] == null
		var crimpb_after_empty = crimpb_after_row <= 2 and state.form[crimpb_after_row][crimpb_after_col] == null
		if crimpb_before_empty and crimpb_after_empty:
			guess += _stamp_number(state, card_id, row, col)
	if rule == "drop_if_drift_count":
		var drift_filled = 0
		for drift_row in 3:
			for drift_col in 3:
				if state.form[drift_row][drift_col] != null:
					drift_filled += 1
		var drift_next = drift_filled + 1
		if drift_next == 9 or drift_next == 12:
			guess -= 4
		elif drift_filled == 9 or drift_filled == 12:
			guess += 5
	if rule == "double_hook_fill":
		var hook_before_row = row
		var hook_before_col = col - 9
		while hook_before_col < 0:
			hook_before_row -= 1
			hook_before_col += 3
		var hook_after_row = row
		var hook_after_col = col + 1
		while hook_after_col > 2:
			hook_after_row += 1
			hook_after_col -= 3
		var hook_before_filled = hook_before_row >= 0 and state.form[hook_before_row][hook_before_col] != null
		var hook_after_filled = hook_after_row <= 2 and state.form[hook_after_row][hook_after_col] != null
		if hook_before_filled and hook_after_filled:
			guess += _stamp_number(state, card_id, row, col)
	if rule == "yield_set_pay":
		var set_sides = 0
		var set_corners = 0
		for set_side in [Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, -1), Vector2i(0, 1)]:
			var set_side_row = row + set_side.x
			var set_side_col = col + set_side.y
			if set_side_row < 0 or set_side_col < 0 or set_side_row > 2 or set_side_col > 2:
				continue
			if state.form[set_side_row][set_side_col] != null:
				set_sides += 1
		for set_corner in [Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1), Vector2i(1, 1)]:
			var set_corner_row = row + set_corner.x
			var set_corner_col = col + set_corner.y
			if set_corner_row < 0 or set_corner_col < 0 or set_corner_row > 2 or set_corner_col > 2:
				continue
			if state.form[set_corner_row][set_corner_col] != null:
				set_corners += 1
		if set_sides == 7 and set_corners == 4:
			guess += 4
		else:
			guess -= 1
	if rule == "double_hook_blank":
		var hookb_before_row = row
		var hookb_before_col = col - 9
		while hookb_before_col < 0:
			hookb_before_row -= 1
			hookb_before_col += 3
		var hookb_after_row = row
		var hookb_after_col = col + 1
		while hookb_after_col > 2:
			hookb_after_row += 1
			hookb_after_col -= 3
		var hookb_before_empty = hookb_before_row >= 0 and state.form[hookb_before_row][hookb_before_col] == null
		var hookb_after_empty = hookb_after_row <= 2 and state.form[hookb_after_row][hookb_after_col] == null
		if hookb_before_empty and hookb_after_empty:
			guess += _stamp_number(state, card_id, row, col)
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
