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
		var wing := str(puzzle["wing"])
		if wing == "West Wing" or wing == "North Wing" or wing == "South Wing":
			_check_undo_restores_exact_state(index)
	_check_alert_step()
	_check_west_lit_step_still_loses()
	_check_unwatched_lit_floor_is_refused()
	_check_lower_seal_tie()
	_check_second_wick_relights()
	_check_lit_door_starts_lit()
	_check_second_call_uses_both_lamps()
	_check_west_snuffs_are_required()
	_check_cut_beam()
	_check_cold_wick()
	_check_nearer_keeper()
	_check_far_watch()
	_check_closing_door_race()
	_check_north_snuffs_are_required()
	_check_dark_half()
	_check_passing_watch()
	_check_owed_step()
	_check_fading_watch()
	_check_covered_flame()
	_check_far_answer()
	_check_south_snuffs_are_required()
	_check_puzzle_select_shows_both_wings()
	print("%d passed, %d failed" % [_passed, _failed])


func _check_wings() -> void:
	var wings: Array = Puzzles.wings()
	_check(Puzzles.count() == 26, "four wings together are 26 puzzles")
	_check(wings.size() == 4, "puzzle select lists four wings")
	_check(
		wings.size() == 4 and str(wings[0]["name"]) == "East Wing" and int(wings[0]["count"]) == 8 and int(wings[0]["first"]) == 0,
		"the east wing still has 8 puzzles"
	)
	_check(
		wings.size() == 4 and str(wings[1]["name"]) == "West Wing" and int(wings[1]["count"]) == 6 and int(wings[1]["first"]) == 8,
		"the west wing has 6 puzzles"
	)
	_check(
		wings.size() == 4 and str(wings[2]["name"]) == "North Wing" and int(wings[2]["count"]) == 6 and int(wings[2]["first"]) == 14,
		"the north wing has 6 puzzles"
	)
	_check(
		wings.size() == 4 and str(wings[3]["name"]) == "South Wing" and int(wings[3]["count"]) == 6 and int(wings[3]["first"]) == 20,
		"the south wing has 6 puzzles"
	)
	var south_titles: PackedStringArray = PackedStringArray([
		"The Dark Half",
		"The Passing Watch",
		"The Owed Step",
		"The Fading Watch",
		"The Covered Flame",
		"The Far Answer",
	])
	var south_ok := true
	for i in south_titles.size():
		var room: Dictionary = Puzzles.get_puzzle(20 + i)
		if str(room["title"]) != south_titles[i] or str(room["wing"]) != "South Wing" or int(room["wing_number"]) != i + 1 or int(room["number"]) != 21 + i:
			south_ok = false
	_check(south_ok, "the south wing is numbered 21 through 26")


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
	var north := false
	var south := false
	var wing_y := {}
	var legend_y := -1.0
	var hint := ""
	var puzzle_buttons := 0
	var stack: Array = [main]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is Label:
			var label := node as Label
			if label.text == "East Wing" or label.text == "West Wing" or label.text == "North Wing" or label.text == "South Wing":
				wing_y[label.text] = label.get_parent().position.y
			if label.text == "East Wing":
				east = true
			elif label.text == "West Wing":
				west = true
			elif label.text == "North Wing":
				north = true
			elif label.text == "South Wing":
				south = true
			elif label.text.begins_with("Gold diamond"):
				legend_y = label.position.y
			elif label.text.begins_with("Arrows move"):
				hint = label.text
		elif node is Button:
			var caption := (node as Button).text
			if caption.is_valid_int():
				puzzle_buttons += 1
		for child in node.get_children():
			stack.append(child)
	_check(east and west and north and south, "puzzle select shows all four wings")
	_check(
		wing_y.has("East Wing") and wing_y.has("West Wing") and wing_y.has("North Wing") and wing_y.has("South Wing") and float(wing_y["East Wing"]) < float(wing_y["West Wing"]) and float(wing_y["West Wing"]) < float(wing_y["North Wing"]) and float(wing_y["North Wing"]) < float(wing_y["South Wing"]),
		"the four wings are listed in order"
	)
	_check(legend_y >= float(wing_y["South Wing"]) + 32.0, "the south wing row sits above the legend")
	_check(hint.contains("Alt+1–6 south"), "the control hint names the south binding")
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
	var north_key := InputEventKey.new()
	north_key.physical_keycode = KEY_1
	north_key.keycode = KEY_1
	north_key.ctrl_pressed = true
	var north_last := InputEventKey.new()
	north_last.physical_keycode = KEY_6
	north_last.keycode = KEY_6
	north_last.ctrl_pressed = true
	_check(main._puzzle_index_for_key(east_key) == 2, "key 3 selects the third east room")
	_check(main._puzzle_index_for_key(west_key) == 8, "shift+1 selects the first west room")
	_check(main._puzzle_index_for_key(last_key) == 13, "shift+6 selects the last west room")
	_check(main._puzzle_index_for_key(bare_shift) == 9, "the @ key selects the second west room")
	var south_key := InputEventKey.new()
	south_key.physical_keycode = KEY_1
	south_key.keycode = KEY_1
	south_key.alt_pressed = true
	var south_last := InputEventKey.new()
	south_last.physical_keycode = KEY_6
	south_last.keycode = KEY_6
	south_last.alt_pressed = true
	var east_eight := InputEventKey.new()
	east_eight.physical_keycode = KEY_8
	east_eight.keycode = KEY_8
	var alt_seven := InputEventKey.new()
	alt_seven.physical_keycode = KEY_7
	alt_seven.keycode = KEY_7
	alt_seven.alt_pressed = true
	var alt_shift := InputEventKey.new()
	alt_shift.physical_keycode = KEY_1
	alt_shift.keycode = KEY_1
	alt_shift.alt_pressed = true
	alt_shift.shift_pressed = true
	_check(main._puzzle_index_for_key(north_key) == 14, "ctrl+1 selects the first north room")
	_check(main._puzzle_index_for_key(north_last) == 19, "ctrl+6 selects the last north room")
	_check(main._puzzle_index_for_key(south_key) == 20, "alt+1 selects the first south room")
	_check(main._puzzle_index_for_key(south_last) == 25, "alt+6 selects the last south room")
	_check(main._puzzle_index_for_key(east_eight) == 7, "key 8 still selects the last east room")
	_check(main._puzzle_index_for_key(alt_seven) == -1, "alt+7 does not select an east room")
	_check(main._puzzle_index_for_key(alt_shift) == -1, "alt does not take a west room")
	main.free()


func _check_cut_beam() -> void:
	var index := _index_of("The Cut Beam")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 0, "the cut beam is solved without snuffing")
	var state := Puzzles.initial_state(index)
	var lamp: Dictionary = state["lamps"][0]
	var found := false
	for y in state["h"]:
		for x in state["w"]:
			if Rules.tile_at(state, x, y) == Rules.Tile.EXIT:
				found = true
				var dx: int = int(x) - int(lamp["x"])
				var dy: int = int(y) - int(lamp["y"])
				_check(
					absi(dx) + absi(dy) <= int(lamp["radius"]) and dx * int(lamp["fx"]) + dy * int(lamp["fy"]) >= 0,
					"the cut door sits inside the lamp's diamond"
				)
				_check(not Rules.light_map(state).has(Vector2i(x, y)), "the wall keeps that door dark")
	_check(found, "the cut beam has a door")
	var refused: Dictionary = Rules.apply(state, {"type": "move", "dx": 0, "dy": 1})
	var stayed: Dictionary = refused["state"]["player"]
	_check(
		refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "lit" and stayed["x"] == int(state["player"]["x"]) and stayed["y"] == int(state["player"]["y"]),
		"unwatched lit floor in the cut hall is refused"
	)
	var right: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	_check(right["result"] == Rules.Result.OK, "the north gallery of the cut beam is dark")
	var lost: Dictionary = Rules.apply(right["state"], {"type": "move", "dx": 0, "dy": 1})
	var landed: Dictionary = lost["state"]["player"]
	_check(
		lost["result"] == Rules.Result.LOSS and lost["reason"] == "watched" and landed["x"] == 2 and landed["y"] == 2,
		"a watched lit step in the north wing still loses"
	)


func _check_cold_wick() -> void:
	var index := _index_of("The Cold Wick")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	_check(not bool(state["lamps"][0]["lit"]), "the cold wick starts unlit")
	var toggles := 0
	var saw := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
			var out: Dictionary = Rules.apply(state, action)
			saw = true
			_check(out["result"] == Rules.Result.OK and int(out["called"]) == -1, "lighting the cold wick calls no one")
			_check(bool(out["state"]["lamps"][0]["lit"]), "the cold wick is lit after that toggle")
			_check(not bool(out["state"]["guards"][0]["alert"]), "the cold wick's keeper is not alerted")
			state = out["state"]
			continue
		var step: Dictionary = Rules.apply(state, action)
		if step["result"] != Rules.Result.OK and step["result"] != Rules.Result.WIN:
			_check(false, "cold wick solution broke before the check finished")
			return
		state = step["state"]
	_check(saw and toggles == 1, "the cold wick solution lights its lamp once")
	state = Puzzles.initial_state(index)
	for _i in 4:
		var step: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
		if step["result"] != Rules.Result.OK:
			_check(false, "cold wick front approach failed")
			return
		state = step["state"]
	var burned: Dictionary = Rules.apply(state, {"type": "toggle", "lamp": 0})
	_check(
		burned["result"] == Rules.Result.LOSS and burned["reason"] == "watched",
		"lighting the cold wick from the front is a watched loss"
	)


func _check_nearer_keeper() -> void:
	var index := _index_of("The Nearer Keeper")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var saw := false
	for action in puzzle["solution"]:
		if str(action["type"]) != "toggle":
			var before: Dictionary = Rules.apply(state, action)
			if before["result"] != Rules.Result.OK:
				_check(false, "nearer keeper approach failed")
				return
			state = before["state"]
			continue
		var lp: Dictionary = state["lamps"][int(action["lamp"])]
		var dist0 := absi(int(state["guards"][0]["x"]) - int(lp["x"])) + absi(int(state["guards"][0]["y"]) - int(lp["y"]))
		var dist1 := absi(int(state["guards"][1]["x"]) - int(lp["x"])) + absi(int(state["guards"][1]["y"]) - int(lp["y"]))
		var out: Dictionary = Rules.apply(state, action)
		saw = true
		_check(dist0 < dist1, "the nearer keeper is strictly closer to the lamp")
		_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "the snuff calls the nearer keeper")
		_check(not bool(out["state"]["guards"][1]["alert"]), "the farther keeper is not called")
		break
	_check(saw, "the nearer keeper solution snuffs the lamp")


func _check_far_watch() -> void:
	var index := _index_of("The Far Watch")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var gap := Vector2i(-1, -1)
	for y in state["h"]:
		for x in state["w"]:
			if Rules.tile_at(state, x, y) == Rules.Tile.GAP:
				gap = Vector2i(x, y)
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(gap) and Rules.watched_tiles(state, lit).has(gap), "the far watch's gap starts lit and watched")
	var toggled := {}
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggled[int(action["lamp"])] = true
	_check(toggled.has(0) and not toggled.has(1), "the far watch snuffs the west wick and leaves the gap lamp")
	state = Puzzles.initial_state(index)
	var crossed := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(state["player"]["x"]) + int(action["dx"]), int(state["player"]["y"]) + int(action["dy"]))
			if dest == gap:
				var lights: Dictionary = Rules.light_map(state)
				_check(
					bool(state["lamps"][1]["lit"]) and lights.has(gap) and not Rules.watched_tiles(state, lights).has(gap),
					"the gap is lit and unwatched when you cross"
				)
				crossed = true
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] == Rules.Result.LOSS or out["result"] == Rules.Result.ILLEGAL:
			_check(false, "far watch solution failed during the gap check")
			return
		state = out["state"]
		if out["result"] == Rules.Result.WIN:
			break
	_check(crossed, "the far watch solution crosses the gap")


func _check_closing_door_race() -> void:
	var index := _index_of("The Closing Door")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var lit: Dictionary = Rules.light_map(state)
	var exit_cell := Vector2i(-1, -1)
	for y in state["h"]:
		for x in state["w"]:
			if Rules.tile_at(state, x, y) == Rules.Tile.EXIT:
				exit_cell = Vector2i(x, y)
	_check(
		lit.has(exit_cell) and Rules.watched_tiles(state, lit).has(exit_cell),
		"the closing door starts lit and watched"
	)
	var saw := false
	for action in puzzle["solution"]:
		if str(action["type"]) != "toggle":
			var before: Dictionary = Rules.apply(state, action)
			if before["result"] != Rules.Result.OK:
				_check(false, "closing door approach failed")
				return
			state = before["state"]
			continue
		var out: Dictionary = Rules.apply(state, action)
		saw = true
		var guard_before: Dictionary = state["guards"][0]
		var guard_after: Dictionary = out["state"]["guards"][0]
		_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "snuffing the door lamp calls the keeper")
		_check(out["step"] == exit_cell, "his next step is the door")
		_check(
			int(guard_after["x"]) == int(guard_before["x"]) and int(guard_after["y"]) == int(guard_before["y"]),
			"he has not stepped onto the door yet"
		)
		var waited: Dictionary = Rules.apply(out["state"], {"type": "wait"})
		var held: Dictionary = waited["state"]["guards"][0]
		_check(
			waited["result"] == Rules.Result.OK and bool(held["holding"]) and int(held["x"]) == exit_cell.x and int(held["y"]) == exit_cell.y,
			"waiting lets him hold the door"
		)
		var player: Dictionary = waited["state"]["player"]
		var bumped: Dictionary = Rules.apply(waited["state"], {"type": "move", "dx": exit_cell.x - int(player["x"]), "dy": exit_cell.y - int(player["y"])})
		_check(bumped["result"] == Rules.Result.LOSS and bumped["reason"] == "guard", "the held door is his tile")
		break
	_check(saw, "the closing door solution snuffs the lamp")


func _check_north_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "North Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_dark_half() -> void:
	var index := _index_of("The Dark Half")
	var state := Puzzles.initial_state(index)
	var lamp: Dictionary = state["lamps"][0]
	var south := Vector2i(2, 4)
	var reach := absi(south.x - int(lamp["x"])) + absi(south.y - int(lamp["y"]))
	_check(reach <= int(lamp["radius"]) and Rules.tile_at(state, south.x, south.y) == Rules.Tile.FLOOR, "the south gallery sits inside the diamond")
	_check(not Rules.light_map(state).has(south), "the south side of the diamond stays dark")
	var exit_lit := false
	var found := false
	var lit: Dictionary = Rules.light_map(state)
	for y in state["h"]:
		for x in state["w"]:
			if Rules.tile_at(state, x, y) == Rules.Tile.EXIT:
				found = true
				exit_lit = lit.has(Vector2i(x, y))
	_check(found and exit_lit, "the dark half's door starts inside the lamp")
	var refused: Dictionary = Rules.apply(state, {"type": "move", "dx": 0, "dy": -1})
	var stayed: Dictionary = refused["state"]["player"]
	_check(
		refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "lit" and stayed["x"] == int(state["player"]["x"]) and stayed["y"] == int(state["player"]["y"]),
		"unwatched lit floor in the south wing is refused"
	)
	for _i in 4:
		var step: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
		if step["result"] != Rules.Result.OK:
			_check(false, "dark half approach failed before the lamp")
			return
		state = step["state"]
	var lost: Dictionary = Rules.apply(state, {"type": "move", "dx": 0, "dy": -1})
	var landed: Dictionary = lost["state"]["player"]
	_check(
		lost["result"] == Rules.Result.LOSS and lost["reason"] == "watched" and landed["x"] == 5 and landed["y"] == 3,
		"a watched lit step in the south wing still loses"
	)


func _check_passing_watch() -> void:
	var index := _index_of("The Passing Watch")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var waits := 0
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "wait":
			waits += 1
		elif str(action["type"]) == "toggle":
			toggles += 1
	_check(waits == 1 and toggles == 0, "the passing watch waits once and does not snuff")
	var state := Puzzles.initial_state(index)
	var gap := Vector2i(4, 1)
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(gap) and not Rules.watched_tiles(state, lit).has(gap), "the gap starts lit while he is on the far end")
	for _i in 2:
		var step: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
		if step["result"] != Rules.Result.OK:
			_check(false, "passing watch approach failed")
			return
		state = step["state"]
	lit = Rules.light_map(state)
	_check(lit.has(gap) and Rules.watched_tiles(state, lit).has(gap), "the near end puts the gap in his eyes")
	var rushed: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var landed: Dictionary = rushed["state"]["player"]
	_check(
		rushed["result"] == Rules.Result.LOSS and rushed["reason"] == "watched" and landed["x"] == gap.x and landed["y"] == gap.y,
		"stepping onto the watched gap still loses"
	)


func _check_owed_step() -> void:
	var index := _index_of("The Owed Step")
	var state := Puzzles.initial_state(index)
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	if approach["result"] != Rules.Result.OK:
		_check(false, "owed step approach failed")
		return
	state = approach["state"]
	var before: Dictionary = state["guards"][0]
	var snuff: Dictionary = Rules.apply(state, {"type": "toggle", "lamp": 0})
	var after: Dictionary = snuff["state"]["guards"][0]
	var player: Dictionary = snuff["state"]["player"]
	_check(snuff["result"] == Rules.Result.OK and int(snuff["called"]) == 0, "the owed step snuff calls the keeper")
	_check(
		int(after["x"]) == 3 and int(after["y"]) == 3 and int(before["y"]) == 4,
		"on the snuff turn his owed step falls short"
	)
	_check(
		snuff["step"] == Vector2i(int(player["x"]), int(player["y"])),
		"the arrow then points at the tile you are standing on"
	)
	var stayed: Dictionary = Rules.apply(snuff["state"], {"type": "wait"})
	var caught: Dictionary = stayed["state"]["guards"][0]
	_check(
		stayed["result"] == Rules.Result.LOSS and stayed["reason"] == "guard" and int(caught["x"]) == 3 and int(caught["y"]) == 2,
		"waiting after the snuff lets the arrow land on you"
	)
	var late := Puzzles.initial_state(index)
	late = Rules.apply(late, {"type": "wait"})["state"]
	late = Rules.apply(late, {"type": "move", "dx": 1, "dy": 0})["state"]
	var late_snuff: Dictionary = Rules.apply(late, {"type": "toggle", "lamp": 0})
	_check(
		late_snuff["result"] == Rules.Result.LOSS and late_snuff["reason"] == "guard",
		"waiting first makes the owed step land on you"
	)


func _check_fading_watch() -> void:
	var index := _index_of("The Fading Watch")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 1, "the fading watch snuffs its lamp once")
	var state := Puzzles.initial_state(index)
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	var exit_cell := Vector2i(-1, -1)
	for y in state["h"]:
		for x in state["w"]:
			if Rules.tile_at(state, x, y) == Rules.Tile.EXIT:
				exit_cell = Vector2i(x, y)
	_check(lit.has(exit_cell) and not watch.has(exit_cell), "the fading door is lit and unwatched")
	_check(lit.has(Vector2i(4, 1)) and watch.has(Vector2i(4, 1)), "the lamp square is lit and watched")
	for _i in 2:
		var step: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
		if step["result"] != Rules.Result.OK:
			_check(false, "fading watch approach failed")
			return
		state = step["state"]
	var lost: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var landed: Dictionary = lost["state"]["player"]
	_check(
		lost["result"] == Rules.Result.LOSS and lost["reason"] == "watched" and landed["x"] == 4 and landed["y"] == 1,
		"stepping onto the watched lamp square still loses"
	)


func _check_covered_flame() -> void:
	var index := _index_of("The Covered Flame")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	_check(Rules.light_map(state).has(Vector2i(5, 1)) and Rules.tile_at(state, 5, 1) == Rules.Tile.FLOOR, "the hall lamp covers the tile behind the door lamp")
	var exit_lit := false
	for y in state["h"]:
		for x in state["w"]:
			if Rules.tile_at(state, x, y) == Rules.Tile.EXIT:
				exit_lit = Rules.light_map(state).has(Vector2i(x, y))
	_check(exit_lit, "the covered flame's door starts lit")
	var order: Array = []
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			order.append(int(action["lamp"]))
	_check(order.size() == 2 and int(order[0]) == 0 and int(order[1]) == 1, "the covered flame snuffs the hall lamp, then the door lamp")
	var saw_first := false
	var saw_second := false
	for action in puzzle["solution"]:
		if str(action["type"]) != "toggle":
			var step: Dictionary = Rules.apply(state, action)
			if step["result"] != Rules.Result.OK:
				_check(false, "covered flame approach failed")
				return
			state = step["state"]
			continue
		var guard_before: Dictionary = state["guards"][0]
		var out: Dictionary = Rules.apply(state, action)
		if not saw_first:
			saw_first = true
			var guard_after: Dictionary = out["state"]["guards"][0]
			_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "snuffing the hall lamp calls the keeper")
			_check(out["step"] == Vector2i(3, 2), "his next step is up toward the hall lamp")
			_check(
				int(guard_after["x"]) == int(guard_before["x"]) and int(guard_after["y"]) == int(guard_before["y"]),
				"he has not taken that step yet"
			)
			state = out["state"]
			continue
		saw_second = true
		var again: Dictionary = out["state"]["guards"][0]
		_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "snuffing the door lamp calls him again")
		_check(bool(guard_before["holding"]) and not bool(again["holding"]) and bool(again["alert"]), "the second snuff lifts the hold")
		_check(int(again["ax"]) == 6 and int(again["ay"]) == 1, "the second call targets the door lamp")
		_check(not bool(out["state"]["lamps"][1]["lit"]), "the door lamp is out")
		_check(
			int(again["x"]) == int(guard_before["x"]) and int(again["y"]) == int(guard_before["y"]),
			"he does not step on the second snuff turn"
		)
		break
	_check(saw_first and saw_second, "the covered flame solution snuffs both lamps")


func _check_far_answer() -> void:
	var index := _index_of("The Far Answer")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var hall: Dictionary = state["lamps"][0]
	var gap_lamp: Dictionary = state["lamps"][1]
	var far: Dictionary = state["guards"][0]
	var near: Dictionary = state["guards"][1]
	var hall_far := absi(int(far["x"]) - int(hall["x"])) + absi(int(far["y"]) - int(hall["y"]))
	var hall_near := absi(int(near["x"]) - int(hall["x"])) + absi(int(near["y"]) - int(hall["y"]))
	var gap_far := absi(int(far["x"]) - int(gap_lamp["x"])) + absi(int(far["y"]) - int(gap_lamp["y"]))
	var gap_near := absi(int(near["x"]) - int(gap_lamp["x"])) + absi(int(near["y"]) - int(gap_lamp["y"]))
	_check(hall_far < hall_near, "the far keeper is closer to the hall lamp")
	_check(gap_near < gap_far, "the door keeper is closer to the gap lamp")
	var used := {}
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			used[int(action["lamp"])] = true
	_check(used.has(0) and not used.has(1), "the far answer snuffs the hall lamp and leaves the gap lamp")
	var gap := Vector2i(8, 1)
	var crossed := false
	var saw := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(state["player"]["x"]) + int(action["dx"]), int(state["player"]["y"]) + int(action["dy"]))
			if dest == gap:
				var lights: Dictionary = Rules.light_map(state)
				_check(
					bool(state["lamps"][1]["lit"]) and not bool(state["lamps"][0]["lit"]) and lights.has(gap) and not Rules.watched_tiles(state, lights).has(gap),
					"the gap is still lit and unwatched when you cross"
				)
				crossed = true
		if str(action["type"]) == "toggle":
			var out: Dictionary = Rules.apply(state, action)
			saw = true
			_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "the hall snuff calls the far keeper")
			_check(not bool(out["state"]["guards"][1]["alert"]), "the door keeper is not called")
			state = out["state"]
			continue
		var step: Dictionary = Rules.apply(state, action)
		if step["result"] == Rules.Result.LOSS or step["result"] == Rules.Result.ILLEGAL:
			_check(false, "far answer solution failed during the call check")
			return
		state = step["state"]
		if step["result"] == Rules.Result.WIN:
			break
	_check(saw and crossed, "the far answer solution snuffs the hall and crosses the gap")
	state = Puzzles.initial_state(index)
	for _i in 2:
		var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
		if approach["result"] != Rules.Result.OK:
			_check(false, "far answer lit-step approach failed")
			return
		state = approach["state"]
	var lost: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var landed: Dictionary = lost["state"]["player"]
	_check(
		lost["result"] == Rules.Result.LOSS and lost["reason"] == "watched" and landed["x"] == 4 and landed["y"] == 1,
		"a watched lit step beside the far answer still loses"
	)


func _check_south_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "South Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)
