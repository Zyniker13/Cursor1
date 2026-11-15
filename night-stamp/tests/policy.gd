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
