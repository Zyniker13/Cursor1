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
