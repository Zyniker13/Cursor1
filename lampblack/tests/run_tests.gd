extends SceneTree

## Headless rules tests. Exit 0 when every check passes, 1 otherwise.
## godot --headless --path lampblack -s res://tests/run_tests.gd

const Rules = preload("res://rules/rules.gd")
const Puzzles = preload("res://puzzles/puzzles.gd")
const SessionScript = preload("res://game/session.gd")

var _failed := 0
var _passed := 0


func _init() -> void:
	_run()
	quit(_failed)


func _run() -> void:
	_check_wings()
	for index in Puzzles.count():
		_check_puzzle(index)
	_check_toggles_required(1)
	_check_toggles_required(3)
	_check_puzzle_one_needs_no_snuff()
	_check_watched_step_is_loss()
	_check_undo_restores_exact_state(2)
	_check_undo_restores_exact_state(7)
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "West Wing":
			_check_undo_restores_exact_state(index)
	_check_alert_step()
	_check_west_lit_step_still_loses()
	_check_unwatched_lit_floor_is_refused()
	_check_lower_seal_tie()
	_check_second_wick_relights()
	_check_lit_door_starts_lit()
	_check_second_call_uses_both_lamps()
	_check_west_snuffs_are_required()
	_check_puzzle_select_shows_both_wings()
	print("%d passed, %d failed" % [_passed, _failed])


func _check_wings() -> void:
	var wings: Array = Puzzles.wings()
	_check(Puzzles.count() == 14, "both wings together are 14 puzzles")
	_check(wings.size() == 2, "puzzle select lists two wings")
	_check(
		wings.size() == 2 and str(wings[0]["name"]) == "East Wing" and int(wings[0]["count"]) == 8 and int(wings[0]["first"]) == 0,
		"the east wing still has 8 puzzles"
	)
	_check(
		wings.size() == 2 and str(wings[1]["name"]) == "West Wing" and int(wings[1]["count"]) == 6 and int(wings[1]["first"]) == 8,
		"the west wing has 6 puzzles"
	)


func _index_of(title: String) -> int:
	for i in Puzzles.count():
		if str(Puzzles.get_puzzle(i)["title"]) == title:
			return i
	return -1


func _check(ok: bool, message: String) -> void:
	if ok:
		_passed += 1
		print("PASS ", message)
	else:
		_failed += 1
		print("FAIL ", message)


func _check_puzzle(index: int) -> void:
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var label := "puzzle %d %s" % [puzzle["number"], puzzle["title"]]
	var state := Puzzles.initial_state(index)
	_check(not Rules.is_win(state), label + " does not start on the exit")
	var won := false
	var clean := true
	for action in puzzle["solution"]:
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] == Rules.Result.LOSS or out["result"] == Rules.Result.ILLEGAL:
			clean = false
			_check(false, "%s solution hit %s (%s) on %s" % [label, out["result"], out["reason"], action])
			break
		state = out["state"]
		if Rules.is_player_watched(state):
			clean = false
			_check(false, label + " solution stands on a watched tile")
			break
		if out["result"] == Rules.Result.WIN:
			won = true
			break
	if clean:
		_check(won, label + " solution wins without standing on a watched tile")


func _check_toggles_required(index: int) -> void:
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var won := false
	for action in puzzle["solution"]:
		var out: Dictionary = Rules.apply(state, action, false)
		if out["result"] == Rules.Result.ILLEGAL:
			continue
		if out["result"] == Rules.Result.LOSS:
			break
		state = out["state"]
		if out["result"] == Rules.Result.WIN:
			won = true
			break
	_check(not won, "puzzle %d fails if lamp toggles are disallowed" % puzzle["number"])


func _check_puzzle_one_needs_no_snuff() -> void:
	var puzzle: Dictionary = Puzzles.get_puzzle(0)
	var snuffs := 0
	for action in puzzle["solution"]:
		if action["type"] == "toggle":
			snuffs += 1
	_check(snuffs == 0, "puzzle 1 is solved without snuffing")


func _check_watched_step_is_loss() -> void:
	# The player starts on a dark tile and steps east onto lit floor inside
	# the guard's diamond. That step is a loss, not a refused move.
	var state := Rules.build(
		PackedStringArray(["######", "#S..X#", "######"]),
		[{"x": 3, "y": 1, "facing": "w", "radius": 1, "lit": true}],
		[{"x": 4, "y": 1, "vision": 3, "rail": [Vector2i(4, 1)]}]
	)
	_check(not Rules.is_player_watched(state), "watched-step fixture does not start watched")
	var out: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var landed: Dictionary = out["state"]["player"]
	_check(
		out["result"] == Rules.Result.LOSS and out["reason"] == "watched" and landed["x"] == 2 and landed["y"] == 1,
		"stepping onto a watched tile is a loss"
	)


func _check_undo_restores_exact_state(index: int) -> void:
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var session = SessionScript.new()
	session.reset(puzzle["rows"], puzzle["lamps"], puzzle["guards"])
	var snaps: Array = [Rules.signature(session.state)]
	for action in puzzle["solution"]:
		var out: Dictionary = session.act(action)
		if out["result"] == Rules.Result.ILLEGAL or out["result"] == Rules.Result.LOSS:
			_check(false, "puzzle %d undo setup could not play the solution" % puzzle["number"])
			return
		snaps.append(Rules.signature(session.state))
	var ok := true
	for i in range(snaps.size() - 1, 0, -1):
		if not session.undo():
			ok = false
			break
		if Rules.signature(session.state) != snaps[i - 1]:
			ok = false
			break
	_check(ok, "puzzle %d undo restores each prior state" % puzzle["number"])
	var stuck := Rules.signature(session.state)
	_check(not session.undo() and Rules.signature(session.state) == stuck, "puzzle %d undo stops at the start" % puzzle["number"])


func _check_alert_step() -> void:
	# Puzzle 3. After the snuff, the called guard has not moved yet.
	# His next step is the tile east of where he started: (2, 1).
	var puzzle: Dictionary = Puzzles.get_puzzle(2)
	var state := Puzzles.initial_state(2)
	var saw := false
	for action in puzzle["solution"]:
		if action["type"] != "toggle":
			var before: Dictionary = Rules.apply(state, action)
			if before["result"] != Rules.Result.OK:
				_check(false, "puzzle 3 approach failed before the snuff")
				return
			state = before["state"]
			continue
		var guard_before: Dictionary = state["guards"][0]
		var out: Dictionary = Rules.apply(state, action)
		var guard_after: Dictionary = out["state"]["guards"][0]
		saw = true
		_check(out["result"] == Rules.Result.OK, "puzzle 3 snuff resolves")
		_check(out["called"] == 0, "puzzle 3 snuff calls guard 0")
		_check(out["step"] == Vector2i(2, 1), "after the snuff the called guard will step to (2, 1)")
		_check(
			guard_after["x"] == guard_before["x"] and guard_after["y"] == guard_before["y"],
			"the called guard has not taken that step yet"
		)
		_check(Rules.planned_step(out["state"], 0) == Vector2i(2, 1), "the alert arrow agrees with (2, 1)")
		_check(guard_after["alert"] and guard_after["ax"] == 7 and guard_after["ay"] == 1, "the call targets the snuffed lamp")
		break
	_check(saw, "puzzle 3 solution contains a snuff")


func _check_west_lit_step_still_loses() -> void:
	# The Broken Sightline. Three steps east along the dark row, then one more
	# step onto the lit tile the guard is watching. That step is a loss.
	var index := _index_of("The Broken Sightline")
	var state := Puzzles.initial_state(index)
	var approach := ["R", "R", "R"]
	var clean := true
	for token in approach:
		var step: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
		if step["result"] != Rules.Result.OK:
			clean = false
			_check(false, "sightline approach failed before the lit step (%s)" % token)
			return
		state = step["state"]
	_check(clean, "sightline approach stays on dark floor")
	var player: Dictionary = state["player"]
	var dest := Vector2i(int(player["x"]) + 1, int(player["y"]))
	_check(Rules.light_map(state).has(dest), "the sightline step lands on lamplight")
	_check(Rules.watched_tiles(state).has(dest), "a guard is watching that lit tile")
	var out: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var landed: Dictionary = out["state"]["player"]
	_check(
		out["result"] == Rules.Result.LOSS and out["reason"] == "watched" and landed["x"] == dest.x and landed["y"] == dest.y,
		"a watched lit step still loses"
	)


func _check_unwatched_lit_floor_is_refused() -> void:
	# The Second Wick. North of the lamp is dark. The floor directly in front
	# of its side is lit, and the cellar guard cannot see it. The step is refused.
	var index := _index_of("The Second Wick")
	var state := Puzzles.initial_state(index)
	var moves := [
		{"type": "move", "dx": 1, "dy": 0},
		{"type": "move", "dx": 1, "dy": 0},
		{"type": "move", "dx": 1, "dy": 0},
		{"type": "move", "dx": 1, "dy": 0},
		{"type": "move", "dx": 0, "dy": 1},
	]
	for action in moves:
		var step: Dictionary = Rules.apply(state, action)
		if step["result"] != Rules.Result.OK:
			_check(false, "wick approach failed before the lit floor")
			return
		state = step["state"]
	var before: Dictionary = state["player"]
	var out: Dictionary = Rules.apply(state, {"type": "move", "dx": 0, "dy": 1})
	var after: Dictionary = out["state"]["player"]
	_check(
		out["result"] == Rules.Result.ILLEGAL and out["reason"] == "lit" and after["x"] == before["x"] and after["y"] == before["y"],
		"unwatched lit floor is still refused"
	)


func _check_lower_seal_tie() -> void:
	var index := _index_of("The Lower Seal")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var saw := false
	for action in puzzle["solution"]:
		if action["type"] != "toggle":
			var before: Dictionary = Rules.apply(state, action)
			if before["result"] != Rules.Result.OK:
				_check(false, "lower seal approach failed")
				return
			state = before["state"]
			continue
		var lamp: Dictionary = state["lamps"][int(action["lamp"])]
		var dist0 := absi(int(state["guards"][0]["x"]) - int(lamp["x"])) + absi(int(state["guards"][0]["y"]) - int(lamp["y"]))
		var dist1 := absi(int(state["guards"][1]["x"]) - int(lamp["x"])) + absi(int(state["guards"][1]["y"]) - int(lamp["y"]))
		var out: Dictionary = Rules.apply(state, action)
		saw = true
		_check(dist0 == dist1, "both keepers stand the same distance from the lamp")
		_check(out["result"] == Rules.Result.OK and out["called"] == 0, "the tie calls the lower keeper")
		_check(int(out["state"]["guards"][1]["x"]) == int(state["guards"][1]["x"]) and int(out["state"]["guards"][1]["y"]) == int(state["guards"][1]["y"]) and not out["state"]["guards"][1]["alert"], "the east keeper is not called")
		break
	_check(saw, "the lower seal solution snuffs the lamp")


func _check_second_wick_relights() -> void:
	var index := _index_of("The Second Wick")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var toggles := 0
	for action in puzzle["solution"]:
		if action["type"] == "toggle" and int(action["lamp"]) == 0:
			toggles += 1
	_check(toggles == 2, "the second wick snuffs and relights the same lamp")


func _check_lit_door_starts_lit() -> void:
	var index := _index_of("The Lit Door")
	var state := Puzzles.initial_state(index)
	var lit: Dictionary = Rules.light_map(state)
	var found := false
	for y in state["h"]:
		for x in state["w"]:
			if Rules.tile_at(state, x, y) == Rules.Tile.EXIT:
				found = true
				_check(lit.has(Vector2i(x, y)), "the lit door's exit starts inside a lamp")
	_check(found, "the lit door has an exit")


func _check_second_call_uses_both_lamps() -> void:
	var index := _index_of("The Second Call")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var seen := {}
	for action in puzzle["solution"]:
		if action["type"] == "toggle":
			seen[int(action["lamp"])] = true
	_check(seen.has(0) and seen.has(1), "the second call snuffs both lamps")


func _check_west_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "West Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_puzzle_select_shows_both_wings() -> void:
	var packed: PackedScene = load("res://game/main.tscn")
	var main = packed.instantiate()
	# _ready is deferred until the idle frame, so build the select rows directly.
	main._build_hud()
	var east := false
	var west := false
	var puzzle_buttons := 0
	var stack: Array = [main]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is Label:
			var label := node as Label
			if label.text == "East Wing":
				east = true
			elif label.text == "West Wing":
				west = true
		elif node is Button:
			var caption := (node as Button).text
			if caption.is_valid_int():
				puzzle_buttons += 1
		for child in node.get_children():
			stack.append(child)
	_check(east and west, "puzzle select shows both wings")
	_check(puzzle_buttons == Puzzles.count(), "puzzle select has a button for every room")
	var east_key := InputEventKey.new()
	east_key.physical_keycode = KEY_3
	east_key.keycode = KEY_3
	var west_key := InputEventKey.new()
	west_key.physical_keycode = KEY_1
	west_key.keycode = KEY_EXCLAM
	west_key.shift_pressed = true
	var last_key := InputEventKey.new()
	last_key.physical_keycode = KEY_6
	last_key.keycode = KEY_ASCIICIRCUM
	last_key.shift_pressed = true
	var bare_shift := InputEventKey.new()
	bare_shift.keycode = KEY_AT
	bare_shift.physical_keycode = KEY_NONE
	_check(main._puzzle_index_for_key(east_key) == 2, "key 3 selects the third east room")
	_check(main._puzzle_index_for_key(west_key) == 8, "shift+1 selects the first west room")
	_check(main._puzzle_index_for_key(last_key) == 13, "shift+6 selects the last west room")
	_check(main._puzzle_index_for_key(bare_shift) == 9, "the @ key selects the second west room")
	main.free()
