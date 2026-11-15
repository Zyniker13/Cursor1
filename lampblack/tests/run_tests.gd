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
		if wing == "West Wing" or wing == "North Wing" or wing == "South Wing" or wing == "Attic Wing" or wing == "Cellar Wing" or wing == "Gallery Wing":
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
	_check_attic_rooms()
	_check_attic_snuffs_are_required()
	_check_cellar_rooms()
	_check_cellar_snuffs_are_required()
	_check_gallery_rooms()
	_check_gallery_snuffs_are_required()
	_check_puzzle_select_shows_both_wings()
	print("%d passed, %d failed" % [_passed, _failed])


func _check_wings() -> void:
	var wings: Array = Puzzles.wings()
	_check(Puzzles.count() == 44, "seven wings together are 44 puzzles")
	_check(wings.size() == 7, "puzzle select lists seven wings")
	_check(
		wings.size() == 7 and str(wings[0]["name"]) == "East Wing" and int(wings[0]["count"]) == 8 and int(wings[0]["first"]) == 0,
		"the east wing still has 8 puzzles"
	)
	_check(
		wings.size() == 7 and str(wings[1]["name"]) == "West Wing" and int(wings[1]["count"]) == 6 and int(wings[1]["first"]) == 8,
		"the west wing has 6 puzzles"
	)
	_check(
		wings.size() == 7 and str(wings[2]["name"]) == "North Wing" and int(wings[2]["count"]) == 6 and int(wings[2]["first"]) == 14,
		"the north wing has 6 puzzles"
	)
	_check(
		wings.size() == 7 and str(wings[3]["name"]) == "South Wing" and int(wings[3]["count"]) == 6 and int(wings[3]["first"]) == 20,
		"the south wing has 6 puzzles"
	)
	_check(
		wings.size() == 7 and str(wings[4]["name"]) == "Attic Wing" and int(wings[4]["count"]) == 6 and int(wings[4]["first"]) == 26,
		"the attic has 6 puzzles"
	)
	_check(
		wings.size() == 7 and str(wings[5]["name"]) == "Cellar Wing" and int(wings[5]["count"]) == 6 and int(wings[5]["first"]) == 32,
		"the cellar has 6 puzzles"
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
	var attic_titles: PackedStringArray = PackedStringArray([
		"The Unlit Watch",
		"The Blind Wall",
		"The Barred Gap",
		"The North Step",
		"The Dark Eye",
		"The Early Threshold",
	])
	var attic_ok := true
	var attic_rules: PackedStringArray = PackedStringArray([
		"a guard watches only lit tiles",
		"walls block vision",
		"a called guard cannot cross a gap",
		"north, then east, then south, then west",
		"a guard standing in the dark can still look into an adjacent lit tile",
		"reaching the exit wins before the guards move",
	])
	for i in attic_titles.size():
		var attic_room: Dictionary = Puzzles.get_puzzle(26 + i)
		var lesson := str(attic_room["lesson"])
		if str(attic_room["title"]) != attic_titles[i] or str(attic_room["wing"]) != "Attic Wing" or int(attic_room["wing_number"]) != i + 1 or int(attic_room["number"]) != 27 + i:
			attic_ok = false
		if not lesson.begins_with("This room is about the rule that ") or not lesson.contains(attic_rules[i]):
			attic_ok = false
	_check(attic_ok, "the attic is numbered 27 through 32 and each banner names its rule")
	var cellar_titles: PackedStringArray = PackedStringArray([
		"The Open Corner",
		"The Brick Shade",
		"The Quiet Wick",
		"The Earlier Keeper",
		"The Dim Lane",
		"The Still Post",
	])
	var cellar_ok := true
	var cellar_rules: PackedStringArray = PackedStringArray([
		"a lit lamp fills a Manhattan diamond",
		"walls block light",
		"lighting a lamp does not call a guard",
		"a distance tie calls the lower number",
		"dark tiles block vision",
		"a called guard holds on the lamp and does not resume his rail",
	])
	for i in cellar_titles.size():
		var cellar_room: Dictionary = Puzzles.get_puzzle(32 + i)
		var cellar_lesson := str(cellar_room["lesson"])
		if str(cellar_room["title"]) != cellar_titles[i] or str(cellar_room["wing"]) != "Cellar Wing" or int(cellar_room["wing_number"]) != i + 1 or int(cellar_room["number"]) != 33 + i:
			cellar_ok = false
		if not cellar_lesson.begins_with("This room is about the rule that ") or not cellar_lesson.contains(cellar_rules[i]):
			cellar_ok = false
	_check(cellar_ok, "the cellar is numbered 33 through 38 and each banner names its rule")
	_check(
		wings.size() == 7 and str(wings[6]["name"]) == "Gallery Wing" and int(wings[6]["count"]) == 6 and int(wings[6]["first"]) == 38,
		"the gallery has 6 puzzles"
	)
	var gallery_titles: PackedStringArray = PackedStringArray([
		"The Rear Shade",
		"The Late Call",
		"The Closed Hall",
		"The Lit Crossing",
		"The Keeper's Square",
		"The Outer Ring",
	])
	var gallery_ok := true
	var gallery_rules: PackedStringArray = PackedStringArray([
		"the tile directly behind the lamp stays dark",
		"snuffing calls the nearest guard toward that lamp on the next turn",
		"lit floor that no guard is watching is refused",
		"a gap may be entered only while it is lit",
		"sharing a tile with a guard is a loss",
		"each guard watches a Manhattan diamond of their vision radius",
	])
	for i in gallery_titles.size():
		var gallery_room: Dictionary = Puzzles.get_puzzle(38 + i)
		var gallery_lesson := str(gallery_room["lesson"])
		if str(gallery_room["title"]) != gallery_titles[i] or str(gallery_room["wing"]) != "Gallery Wing" or int(gallery_room["wing_number"]) != i + 1 or int(gallery_room["number"]) != 39 + i:
			gallery_ok = false
		if not gallery_lesson.begins_with("This room is about the rule that ") or not gallery_lesson.contains(gallery_rules[i]):
			gallery_ok = false
	_check(gallery_ok, "the gallery is numbered 39 through 44 and each banner names its rule")


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
	var attic := false
	var cellar := false
	var gallery := false
	var wing_y := {}
	var legend_y := -1.0
	var hint := ""
	var puzzle_buttons := 0
	var stack: Array = [main]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is Label:
			var label := node as Label
			if label.text == "East Wing" or label.text == "West Wing" or label.text == "North Wing" or label.text == "South Wing" or label.text == "Attic Wing" or label.text == "Cellar Wing" or label.text == "Gallery Wing":
				wing_y[label.text] = label.get_parent().position.y
			if label.text == "East Wing":
				east = true
			elif label.text == "West Wing":
				west = true
			elif label.text == "North Wing":
				north = true
			elif label.text == "South Wing":
				south = true
			elif label.text == "Attic Wing":
				attic = true
			elif label.text == "Cellar Wing":
				cellar = true
			elif label.text == "Gallery Wing":
				gallery = true
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
	_check(east and west and north and south and attic and cellar and gallery, "puzzle select shows all seven wings")
	_check(
		wing_y.has("East Wing") and wing_y.has("West Wing") and wing_y.has("North Wing") and wing_y.has("South Wing") and wing_y.has("Attic Wing") and wing_y.has("Cellar Wing") and wing_y.has("Gallery Wing") and float(wing_y["East Wing"]) < float(wing_y["West Wing"]) and float(wing_y["West Wing"]) < float(wing_y["North Wing"]) and float(wing_y["North Wing"]) < float(wing_y["South Wing"]) and float(wing_y["South Wing"]) < float(wing_y["Attic Wing"]) and float(wing_y["Attic Wing"]) < float(wing_y["Cellar Wing"]) and float(wing_y["Cellar Wing"]) < float(wing_y["Gallery Wing"]),
		"the seven wings are listed in order"
	)
	_check(legend_y >= float(wing_y["Cellar Wing"]) + 32.0, "the cellar row sits above the legend")
	_check(legend_y >= float(wing_y["Gallery Wing"]) + 32.0, "the gallery row sits above the legend")
	_check(hint.contains("Alt+1–6 south"), "the control hint names the south binding")
	_check(hint.contains("F1–F6 attic"), "the control hint names the attic binding")
	_check(hint.contains("F7–F12 cellar"), "the control hint names the cellar binding")
	_check(hint.contains("Keypad 1–6 gallery"), "the control hint names the gallery binding")
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
	var attic_key := InputEventKey.new()
	attic_key.physical_keycode = KEY_F1
	attic_key.keycode = KEY_F1
	var attic_last := InputEventKey.new()
	attic_last.physical_keycode = KEY_F6
	attic_last.keycode = KEY_F6
	var attic_physical := InputEventKey.new()
	attic_physical.physical_keycode = KEY_F3
	attic_physical.keycode = KEY_NONE
	var attic_code := InputEventKey.new()
	attic_code.keycode = KEY_F4
	attic_code.physical_keycode = KEY_NONE
	var attic_seven := InputEventKey.new()
	attic_seven.physical_keycode = KEY_F7
	attic_seven.keycode = KEY_F7
	var attic_alt := InputEventKey.new()
	attic_alt.physical_keycode = KEY_F1
	attic_alt.keycode = KEY_F1
	attic_alt.alt_pressed = true
	_check(main._puzzle_index_for_key(attic_key) == 26, "F1 selects the first attic room")
	_check(main._puzzle_index_for_key(attic_last) == 31, "F6 selects the last attic room")
	_check(main._puzzle_index_for_key(attic_physical) == 28, "the physical F3 key selects the third attic room")
	_check(main._puzzle_index_for_key(attic_code) == 29, "the F4 keycode selects the fourth attic room")
	_check(main._puzzle_index_for_key(attic_seven) == 32, "F7 selects the first cellar room")
	_check(main._puzzle_index_for_key(attic_alt) == 26, "F1 still selects the attic when alt is held")
	var cellar_last := InputEventKey.new()
	cellar_last.physical_keycode = KEY_F12
	cellar_last.keycode = KEY_F12
	var cellar_physical := InputEventKey.new()
	cellar_physical.physical_keycode = KEY_F8
	cellar_physical.keycode = KEY_NONE
	var cellar_code := InputEventKey.new()
	cellar_code.keycode = KEY_F10
	cellar_code.physical_keycode = KEY_NONE
	var cellar_past := InputEventKey.new()
	cellar_past.physical_keycode = KEY_F13
	cellar_past.keycode = KEY_F13
	var cellar_shift := InputEventKey.new()
	cellar_shift.physical_keycode = KEY_F7
	cellar_shift.keycode = KEY_F7
	cellar_shift.shift_pressed = true
	var cellar_ctrl := InputEventKey.new()
	cellar_ctrl.physical_keycode = KEY_F7
	cellar_ctrl.keycode = KEY_F7
	cellar_ctrl.ctrl_pressed = true
	var cellar_alt := InputEventKey.new()
	cellar_alt.physical_keycode = KEY_F7
	cellar_alt.keycode = KEY_F7
	cellar_alt.alt_pressed = true
	_check(main._puzzle_index_for_key(cellar_last) == 37, "F12 selects the last cellar room")
	_check(main._puzzle_index_for_key(cellar_physical) == 33, "the physical F8 key selects the second cellar room")
	_check(main._puzzle_index_for_key(cellar_code) == 35, "the F10 keycode selects the fourth cellar room")
	_check(main._puzzle_index_for_key(cellar_past) == -1, "F13 does not select a cellar room")
	_check(main._puzzle_index_for_key(cellar_shift) == 32, "shift does not take F7 off the cellar")
	_check(main._puzzle_index_for_key(cellar_ctrl) == 32, "ctrl does not take F7 off the cellar")
	_check(main._puzzle_index_for_key(cellar_alt) == 32, "alt does not take F7 off the cellar")
	var gallery_key := InputEventKey.new()
	gallery_key.physical_keycode = KEY_KP_1
	gallery_key.keycode = KEY_KP_1
	var gallery_last := InputEventKey.new()
	gallery_last.physical_keycode = KEY_KP_6
	gallery_last.keycode = KEY_KP_6
	var gallery_physical := InputEventKey.new()
	gallery_physical.physical_keycode = KEY_KP_3
	gallery_physical.keycode = KEY_NONE
	var gallery_code := InputEventKey.new()
	gallery_code.keycode = KEY_KP_4
	gallery_code.physical_keycode = KEY_NONE
	var gallery_shift := InputEventKey.new()
	gallery_shift.physical_keycode = KEY_KP_1
	gallery_shift.keycode = KEY_KP_1
	gallery_shift.shift_pressed = true
	var gallery_ctrl := InputEventKey.new()
	gallery_ctrl.physical_keycode = KEY_KP_2
	gallery_ctrl.keycode = KEY_KP_2
	gallery_ctrl.ctrl_pressed = true
	var gallery_alt := InputEventKey.new()
	gallery_alt.physical_keycode = KEY_KP_5
	gallery_alt.keycode = KEY_KP_5
	gallery_alt.alt_pressed = true
	var row_one := InputEventKey.new()
	row_one.physical_keycode = KEY_1
	row_one.keycode = KEY_1
	var keypad_seven := InputEventKey.new()
	keypad_seven.physical_keycode = KEY_KP_7
	keypad_seven.keycode = KEY_KP_7
	var keypad_zero := InputEventKey.new()
	keypad_zero.physical_keycode = KEY_KP_0
	keypad_zero.keycode = KEY_KP_0
	_check(main._puzzle_index_for_key(gallery_key) == 38, "keypad 1 selects the first gallery room")
	_check(main._puzzle_index_for_key(gallery_last) == 43, "keypad 6 selects the last gallery room")
	_check(main._puzzle_index_for_key(gallery_physical) == 40, "the physical keypad 3 selects the third gallery room")
	_check(main._puzzle_index_for_key(gallery_code) == 41, "the keypad 4 keycode selects the fourth gallery room")
	_check(main._puzzle_index_for_key(gallery_shift) == 38, "shift does not take keypad 1 off the gallery")
	_check(main._puzzle_index_for_key(gallery_ctrl) == 39, "ctrl does not take keypad 2 off the gallery")
	_check(main._puzzle_index_for_key(gallery_alt) == 42, "alt does not take keypad 5 off the gallery")
	_check(main._puzzle_index_for_key(row_one) == 0, "number-row 1 still selects the first east room")
	_check(main._puzzle_index_for_key(gallery_key) != main._puzzle_index_for_key(row_one), "keypad 1 is distinct from number-row 1")
	_check(main._puzzle_index_for_key(keypad_seven) == -1, "keypad 7 does not select an east room")
	_check(main._puzzle_index_for_key(keypad_zero) == -1, "keypad 0 does not select a room")
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


func _check_attic_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Attic Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_attic_rooms() -> void:
	_check_room_identity()
	_check_attic_watched_steps()
	_check_unlit_watch()
	_check_blind_wall()
	_check_barred_gap()
	_check_north_step()
	_check_dark_eye()
	_check_early_threshold()


func _check_room_identity() -> void:
	var layouts := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		var layout := "|".join(puzzle["rows"])
		var title := str(puzzle["title"])
		if str(puzzle["wing"]) == "Attic Wing":
			if layouts.has(layout):
				layout_ok = false
			if titles.has(title):
				title_ok = false
		if not layouts.has(layout):
			layouts[layout] = title
		if not titles.has(title):
			titles[title] = true
	_check(layout_ok, "each attic room has its own layout")
	_check(title_ok, "each attic room has its own name")


func _check_attic_watched_steps() -> void:
	var cases := [
		["The Unlit Watch", "R R R D", 4, 2],
		["The Blind Wall", "R", 2, 1],
		["The Barred Gap", "R R T0 W W R R W R", 6, 1],
		["The North Step", "D D D D R R R", 4, 5],
		["The Dark Eye", "R R R", 4, 1],
		["The Early Threshold", "D", 3, 2],
	]
	for entry in cases:
		_expect_watched_loss(str(entry[0]), str(entry[1]), int(entry[2]), int(entry[3]))


func _expect_watched_loss(title: String, spec: String, x: int, y: int) -> void:
	var state := Puzzles.initial_state(_index_of(title))
	var actions: Array = Puzzles.parse_solution(spec)
	for i in actions.size():
		var action: Dictionary = actions[i]
		if i == actions.size() - 1:
			var dest := Vector2i(x, y)
			var lit: Dictionary = Rules.light_map(state)
			_check(lit.has(dest) and Rules.watched_tiles(state, lit).has(dest), title + " steps onto a lit tile a guard is watching")
			var out: Dictionary = Rules.apply(state, action)
			var landed: Dictionary = out["state"]["player"]
			_check(
				out["result"] == Rules.Result.LOSS and out["reason"] == "watched" and landed["x"] == x and landed["y"] == y,
				title + " watched lit step loses"
			)
			return
		var step: Dictionary = Rules.apply(state, action)
		if step["result"] != Rules.Result.OK:
			_check(false, title + " loss approach failed")
			return
		state = step["state"]


func _check_unlit_watch() -> void:
	var index := _index_of("The Unlit Watch")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 0, "the unlit watch is solved without snuffing")
	var state := Puzzles.initial_state(index)
	var hall := Vector2i(4, 1)
	var guard: Dictionary = state["guards"][0]
	var dist := absi(hall.x - int(guard["x"])) + absi(hall.y - int(guard["y"]))
	var lit: Dictionary = Rules.light_map(state)
	_check(dist <= int(guard["vision"]) and not lit.has(hall) and not Rules.watched_tiles(state, lit).has(hall), "the dark hall is inside his reach and unwatched")
	var visited := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(state["player"]["x"]) + int(action["dx"]), int(state["player"]["y"]) + int(action["dy"]))
			if dest == hall:
				visited = true
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "unlit watch solution failed while crossing the hall")
			return
		state = out["state"]
	_check(visited, "the unlit watch solution walks the dark hall inside his reach")


func _check_blind_wall() -> void:
	var index := _index_of("The Blind Wall")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var gap := Vector2i(6, 3)
	var wall := Vector2i(4, 3)
	var guard: Dictionary = state["guards"][0]
	var dist := absi(gap.x - int(guard["x"])) + absi(gap.y - int(guard["y"]))
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	_check(Rules.tile_at(state, wall.x, wall.y) == Rules.Tile.WALL, "a wall stands between the keeper and the gap")
	_check(dist <= int(guard["vision"]) and lit.has(gap) and not watch.has(gap), "the blind gap is lit, in reach, and unseen")
	var open: Dictionary = state.duplicate(true)
	open["tiles"][wall.y * open["w"] + wall.x] = Rules.Tile.FLOOR
	var open_lit: Dictionary = Rules.light_map(open)
	_check(Rules.watched_tiles(open, open_lit).has(gap), "opening that wall lets him watch the gap")
	var used := {}
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			used[int(action["lamp"])] = true
	_check(used.has(0) and not used.has(1), "the blind wall snuffs the near lamp and leaves the gap lamp")
	var crossed := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(state["player"]["x"]) + int(action["dx"]), int(state["player"]["y"]) + int(action["dy"]))
			if dest == gap:
				var lights: Dictionary = Rules.light_map(state)
				_check(
					not bool(state["lamps"][0]["lit"]) and bool(state["lamps"][1]["lit"]) and lights.has(gap) and not Rules.watched_tiles(state, lights).has(gap),
					"the gap is lit and unwatched when you cross"
				)
				crossed = true
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] == Rules.Result.LOSS or out["result"] == Rules.Result.ILLEGAL:
			_check(false, "blind wall solution failed during the gap check")
			return
		state = out["state"]
		if out["result"] == Rules.Result.WIN:
			break
	_check(crossed, "the blind wall solution crosses the gap")


func _check_barred_gap() -> void:
	var index := _index_of("The Barred Gap")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var saw := false
	for action in puzzle["solution"]:
		if str(action["type"]) != "toggle":
			var before: Dictionary = Rules.apply(state, action)
			if before["result"] != Rules.Result.OK:
				_check(false, "barred gap approach failed")
				return
			state = before["state"]
			continue
		var out: Dictionary = Rules.apply(state, action)
		saw = true
		var gap := Vector2i(6, 1)
		var around: Array = Rules.planned_path(out["state"], 0)
		var opened: Dictionary = out["state"].duplicate(true)
		opened["tiles"][gap.y * opened["w"] + gap.x] = Rules.Tile.FLOOR
		var through: Array = Rules.planned_path(opened, 0)
		_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "snuffing the hall lamp calls the keeper")
		_check(out["step"] == Vector2i(10, 3), "his next step starts the long way around")
		_check(not _path_has(around, gap) and _path_has(through, gap), "the gap is on the short road and off the road he can walk")
		_check(through.size() < around.size(), "the floor road around the gap is longer")
		break
	_check(saw, "the barred gap solution snuffs the hall lamp")
	var used := {}
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			used[int(action["lamp"])] = true
	_check(used.has(0) and not used.has(1), "the barred gap leaves the gap lamp burning")


func _check_north_step() -> void:
	var index := _index_of("The North Step")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 0, "dy": 1})
	if approach["result"] != Rules.Result.OK:
		_check(false, "north step approach failed")
		return
	state = approach["state"]
	var lamp: Dictionary = state["lamps"][0]
	var guard_before: Dictionary = state["guards"][0]
	var north := Vector2i(int(guard_before["x"]), int(guard_before["y"]) - 1)
	var west := Vector2i(int(guard_before["x"]) - 1, int(guard_before["y"]))
	var north_dist := absi(north.x - int(lamp["x"])) + absi(north.y - int(lamp["y"]))
	var west_dist := absi(west.x - int(lamp["x"])) + absi(west.y - int(lamp["y"]))
	var out: Dictionary = Rules.apply(state, {"type": "toggle", "lamp": 0})
	var guard_after: Dictionary = out["state"]["guards"][0]
	_check(north_dist == west_dist and Rules.tile_at(state, west.x, west.y) == Rules.Tile.FLOOR, "north and west are equal roads to the lamp")
	_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0 and out["step"] == north, "the tie breaks north")
	_check(out["step"] != west, "the tie does not break west")
	_check(int(guard_after["x"]) == int(guard_before["x"]) and int(guard_after["y"]) == int(guard_before["y"]), "he has not taken the north step yet")
	var used := {}
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			used[int(action["lamp"])] = true
	_check(used.has(0) and not used.has(1), "the north step snuffs the northwest lamp and leaves the south lamp")


func _check_dark_eye() -> void:
	var state := Puzzles.initial_state(_index_of("The Dark Eye"))
	var guard: Dictionary = state["guards"][0]
	var origin := Vector2i(int(guard["x"]), int(guard["y"]))
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	_check(not lit.has(origin) and not watch.has(origin), "the dark eye stands on a dark square that is not watched")
	var adjacent := false
	for dir in [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]:
		var cell: Vector2i = origin + dir
		if lit.has(cell) and watch.has(cell):
			adjacent = true
	_check(adjacent, "he still watches an adjacent lit tile")


func _check_early_threshold() -> void:
	var index := _index_of("The Early Threshold")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 0, "the early threshold is solved without snuffing")
	var state := Puzzles.initial_state(index)
	var exit_cell := Vector2i(5, 1)
	var first: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	if first["result"] != Rules.Result.OK:
		_check(false, "early threshold approach failed")
		return
	state = first["state"]
	var guard: Dictionary = state["guards"][0]
	_check(int(guard["x"]) == 5 and int(guard["y"]) == 2 and Rules.planned_step(state, 0) == exit_cell, "his next step is the door")
	var won: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var still: Dictionary = won["state"]["guards"][0]
	_check(won["result"] == Rules.Result.WIN and int(still["x"]) == 5 and int(still["y"]) == 2, "the door wins before he steps onto it")
	var late := Puzzles.initial_state(index)
	late = Rules.apply(late, {"type": "wait"})["state"]
	late = Rules.apply(late, {"type": "move", "dx": 1, "dy": 0})["state"]
	var bumped: Dictionary = Rules.apply(late, {"type": "move", "dx": 1, "dy": 0})
	_check(bumped["result"] == Rules.Result.LOSS and bumped["reason"] == "guard", "waiting lets him take the door")


func _check_cellar_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Cellar Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_cellar_rooms() -> void:
	_check_cellar_identity()
	_check_cellar_watched_steps()
	_check_open_corner()
	_check_brick_shade()
	_check_quiet_wick()
	_check_earlier_keeper()
	_check_dim_lane()
	_check_still_post()


func _check_cellar_identity() -> void:
	var layouts := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		var layout := "|".join(puzzle["rows"])
		var title := str(puzzle["title"])
		if str(puzzle["wing"]) == "Cellar Wing":
			if layouts.has(layout):
				layout_ok = false
			if titles.has(title):
				title_ok = false
		if not layouts.has(layout):
			layouts[layout] = title
		if not titles.has(title):
			titles[title] = true
	_check(layout_ok, "each cellar room has its own layout")
	_check(title_ok, "each cellar room has its own name")


func _check_cellar_watched_steps() -> void:
	var cases := [
		["The Open Corner", "D D D R R R U", 4, 3],
		["The Brick Shade", "R R", 3, 1],
		["The Quiet Wick", "R R R R D T0 R U", 6, 3],
		["The Earlier Keeper", "D D D R R R R R", 6, 4],
		["The Dim Lane", "R R R D", 4, 3],
		["The Still Post", "R R R R R R R R D", 9, 2],
	]
	for entry in cases:
		_expect_watched_loss(str(entry[0]), str(entry[1]), int(entry[2]), int(entry[3]))


func _check_open_corner() -> void:
	var index := _index_of("The Open Corner")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 0, "the open corner is solved without snuffing")
	var state := Puzzles.initial_state(index)
	var lamp: Dictionary = state["lamps"][0]
	var exit_cell := _find_tile(state, Rules.Tile.EXIT)
	var dx := exit_cell.x - int(lamp["x"])
	var dy := exit_cell.y - int(lamp["y"])
	var lit: Dictionary = Rules.light_map(state)
	_check(not Rules.in_diamond(lamp, exit_cell.x, exit_cell.y), "the open corner's door is outside the diamond")
	_check(maxi(absi(dx), absi(dy)) <= int(lamp["radius"]), "that door is inside the square of the same radius")
	_check(not lit.has(exit_cell), "the diagonal door stays dark")
	var beside := Vector2i(int(lamp["x"]), int(lamp["y"]) + 1)
	_check(lit.has(beside) and Rules.watched_tiles(state, lit).has(beside), "the orthogonal square south of the lamp is lit and watched")


func _check_brick_shade() -> void:
	var index := _index_of("The Brick Shade")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 0, "the brick shade is solved without snuffing")
	var state := Puzzles.initial_state(index)
	var lamp: Dictionary = state["lamps"][0]
	var exit_cell := _find_tile(state, Rules.Tile.EXIT)
	var dx := exit_cell.x - int(lamp["x"])
	var dy := exit_cell.y - int(lamp["y"])
	_check(
		absi(dx) + absi(dy) <= int(lamp["radius"]) and dx * int(lamp["fx"]) + dy * int(lamp["fy"]) >= 0,
		"the shaded door sits inside the lamp's diamond"
	)
	_check(not Rules.light_map(state).has(exit_cell), "the wall keeps that door dark")
	var wall := Vector2i(int(lamp["x"]) + 1, int(lamp["y"]))
	_check(Rules.tile_at(state, wall.x, wall.y) == Rules.Tile.WALL, "a wall stands between the wick and the door")
	var opened: Dictionary = state.duplicate(true)
	opened["tiles"][wall.y * opened["w"] + wall.x] = Rules.Tile.FLOOR
	_check(Rules.light_map(opened).has(exit_cell), "opening that wall lets the diamond reach the door")


func _check_quiet_wick() -> void:
	var index := _index_of("The Quiet Wick")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	_check(not bool(state["lamps"][0]["lit"]), "the quiet wick starts unlit")
	var gap := _find_tile(state, Rules.Tile.GAP)
	_check(not Rules.light_map(state).has(gap), "the quiet wick's gap starts dark")
	var toggles := 0
	var saw := false
	var crossed := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
			var out: Dictionary = Rules.apply(state, action)
			saw = true
			_check(out["result"] == Rules.Result.OK and int(out["called"]) == -1, "lighting the quiet wick calls no one")
			_check(bool(out["state"]["lamps"][0]["lit"]), "the quiet wick is lit after that toggle")
			_check(not bool(out["state"]["guards"][0]["alert"]), "the quiet wick's keeper is not alerted")
			_check(Rules.light_map(out["state"]).has(gap), "lighting the quiet wick opens the gap")
			state = out["state"]
			continue
		if str(action["type"]) == "move":
			var dest := Vector2i(int(state["player"]["x"]) + int(action["dx"]), int(state["player"]["y"]) + int(action["dy"]))
			if dest == gap:
				var lights: Dictionary = Rules.light_map(state)
				_check(
					bool(state["lamps"][0]["lit"]) and lights.has(gap) and not Rules.watched_tiles(state, lights).has(gap),
					"the quiet wick's gap is lit and unwatched when you cross"
				)
				crossed = true
		var step: Dictionary = Rules.apply(state, action)
		if step["result"] != Rules.Result.OK and step["result"] != Rules.Result.WIN:
			_check(false, "quiet wick solution broke before the check finished")
			return
		state = step["state"]
	_check(saw and toggles == 1, "the quiet wick solution lights its lamp once")
	_check(crossed, "the quiet wick solution crosses the gap")


func _check_earlier_keeper() -> void:
	var index := _index_of("The Earlier Keeper")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var east_x := int(state["guards"][1]["x"])
	var east_y := int(state["guards"][1]["y"])
	var saw := false
	for action in puzzle["solution"]:
		if str(action["type"]) != "toggle":
			var before: Dictionary = Rules.apply(state, action)
			if before["result"] != Rules.Result.OK and before["result"] != Rules.Result.WIN:
				_check(false, "earlier keeper approach failed")
				return
			state = before["state"]
			if before["result"] == Rules.Result.WIN:
				break
			continue
		var lp: Dictionary = state["lamps"][int(action["lamp"])]
		var dist0 := absi(int(state["guards"][0]["x"]) - int(lp["x"])) + absi(int(state["guards"][0]["y"]) - int(lp["y"]))
		var dist1 := absi(int(state["guards"][1]["x"]) - int(lp["x"])) + absi(int(state["guards"][1]["y"]) - int(lp["y"]))
		var out: Dictionary = Rules.apply(state, action)
		saw = true
		_check(dist0 == dist1, "both cellar keepers stand the same distance from the lamp")
		_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "the tie calls the lower keeper")
		_check(
			int(out["state"]["guards"][1]["x"]) == east_x and int(out["state"]["guards"][1]["y"]) == east_y and not bool(out["state"]["guards"][1]["alert"]),
			"the east keeper is not called"
		)
		state = out["state"]
	_check(saw, "the earlier keeper solution snuffs the lamp")
	var end: Dictionary = state["guards"][1]
	_check(int(end["x"]) == east_x and int(end["y"]) == east_y and not bool(end["alert"]), "the east keeper never moves")


func _check_dim_lane() -> void:
	var index := _index_of("The Dim Lane")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 0, "the dim lane is solved without snuffing")
	var state := Puzzles.initial_state(index)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var between := Vector2i(4, 2)
	var guard: Dictionary = state["guards"][0]
	var dist := absi(gap.x - int(guard["x"])) + absi(gap.y - int(guard["y"]))
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	_check(dist <= int(guard["vision"]) and lit.has(gap) and not watch.has(gap), "the dim gap is lit, in reach, and unseen")
	_check(not lit.has(between) and Rules.tile_at(state, between.x, between.y) == Rules.Tile.FLOOR, "a dark floor tile stands between the keeper and the gap")
	var opened: Dictionary = state.duplicate(true)
	var lamps: Array = opened["lamps"]
	lamps.append({
		"id": lamps.size(),
		"x": between.x,
		"y": between.y,
		"facing": "e",
		"fx": 1,
		"fy": 0,
		"radius": 0,
		"lit": true,
	})
	var open_lit: Dictionary = Rules.light_map(opened)
	_check(open_lit.has(between) and Rules.watched_tiles(opened, open_lit).has(gap), "lighting the dark square lets him watch the gap")
	var crossed := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(state["player"]["x"]) + int(action["dx"]), int(state["player"]["y"]) + int(action["dy"]))
			if dest == gap:
				var lights: Dictionary = Rules.light_map(state)
				_check(lights.has(gap) and not Rules.watched_tiles(state, lights).has(gap), "the dim gap is lit and unwatched when you cross")
				crossed = true
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] == Rules.Result.LOSS or out["result"] == Rules.Result.ILLEGAL:
			_check(false, "dim lane solution failed during the gap check")
			return
		state = out["state"]
		if out["result"] == Rules.Result.WIN:
			break
	_check(crossed, "the dim lane solution crosses the gap")


func _check_still_post() -> void:
	var index := _index_of("The Still Post")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(gap) and Rules.watched_tiles(state, lit).has(gap), "the still post's gap starts lit and watched")
	var other := Rules.clone(state)
	other["guards"][0]["x"] = 8
	other["guards"][0]["y"] = 4
	var other_lit: Dictionary = Rules.light_map(other)
	_check(Rules.watched_tiles(other, other_lit).has(gap), "the far end of his walk still watches the gap")
	var used := {}
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			used[int(action["lamp"])] = true
	_check(used.has(0) and not used.has(1), "the still post snuffs the west wick and leaves the gap lamp")
	var held := false
	var crossed := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(state["player"]["x"]) + int(action["dx"]), int(state["player"]["y"]) + int(action["dy"]))
			if dest == gap:
				var lights: Dictionary = Rules.light_map(state)
				var keeper: Dictionary = state["guards"][0]
				_check(
					not bool(state["lamps"][0]["lit"]) and bool(state["lamps"][1]["lit"]) and lights.has(gap) and not Rules.watched_tiles(state, lights).has(gap),
					"the gap is still lit and unwatched when you cross"
				)
				_check(bool(keeper["holding"]) and int(keeper["x"]) == 2 and int(keeper["y"]) == 4, "he is holding on the west wick when you cross")
				crossed = true
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] == Rules.Result.LOSS or out["result"] == Rules.Result.ILLEGAL:
			_check(false, "still post solution failed during the hold check")
			return
		state = out["state"]
		var guard: Dictionary = state["guards"][0]
		if bool(guard["holding"]):
			held = true
		if out["result"] == Rules.Result.WIN:
			break
	_check(held and crossed, "the still post solution waits until he holds, then crosses")
	var parked := Puzzles.initial_state(index)
	for token in ["D", "D", "D", "T0", "W", "W", "W", "W", "W", "W", "W"]:
		var action := {"type": "wait"}
		if token == "D":
			action = {"type": "move", "dx": 0, "dy": 1}
		elif token == "T0":
			action = {"type": "toggle", "lamp": 0}
		var step: Dictionary = Rules.apply(parked, action)
		if step["result"] != Rules.Result.OK:
			_check(false, "still post hold setup failed")
			return
		parked = step["state"]
	var keeper: Dictionary = parked["guards"][0]
	_check(bool(keeper["holding"]) and int(keeper["x"]) == 2 and int(keeper["y"]) == 4, "he holds on the snuffed wick")
	var stayed := true
	for _i in 4:
		var waited: Dictionary = Rules.apply(parked, {"type": "wait"})
		if waited["result"] != Rules.Result.OK:
			stayed = false
			break
		parked = waited["state"]
		var still: Dictionary = parked["guards"][0]
		if not bool(still["holding"]) or int(still["x"]) != 2 or int(still["y"]) != 4:
			stayed = false
	_check(stayed, "waiting does not send him back to the rail")
	var released: Dictionary = parked.duplicate(true)
	released["guards"][0]["holding"] = false
	var resumed: Vector2i = Rules.planned_step(released, 0)
	_check(resumed != Vector2i(2, 4), "without the hold he would resume the rail")


func _check_gallery_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Gallery Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_gallery_rooms() -> void:
	_check_gallery_identity()
	_check_gallery_watched_steps()
	_check_rear_shade()
	_check_late_call()
	_check_closed_hall()
	_check_lit_crossing()
	_check_keepers_square()
	_check_outer_ring()


func _check_gallery_identity() -> void:
	var layouts := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		var layout := "|".join(puzzle["rows"])
		var title := str(puzzle["title"])
		if str(puzzle["wing"]) == "Gallery Wing":
			if layouts.has(layout):
				layout_ok = false
			if titles.has(title):
				title_ok = false
		if not layouts.has(layout):
			layouts[layout] = title
		if not titles.has(title):
			titles[title] = true
	_check(layout_ok, "each gallery room has its own layout")
	_check(title_ok, "each gallery room has its own name")


func _check_gallery_watched_steps() -> void:
	var cases := [
		["The Rear Shade", "D D D R R R R", 5, 4],
		["The Late Call", "D D R R R R R R", 7, 3],
		["The Closed Hall", "R D D D R R R R", 6, 4],
		["The Lit Crossing", "D D D R R R R R R", 7, 4],
		["The Keeper's Square", "D R R R", 4, 2],
		["The Outer Ring", "D R R R R", 5, 2],
	]
	for entry in cases:
		_expect_watched_loss(str(entry[0]), str(entry[1]), int(entry[2]), int(entry[3]))


func _check_rear_shade() -> void:
	var index := _index_of("The Rear Shade")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var lamp: Dictionary = state["lamps"][0]
	var behind := Vector2i(int(lamp["x"]) - int(lamp["fx"]), int(lamp["y"]) - int(lamp["fy"]))
	var ahead := Vector2i(int(lamp["x"]) + int(lamp["fx"]), int(lamp["y"]) + int(lamp["fy"]))
	var side := Vector2i(int(lamp["x"]), int(lamp["y"]) + 1)
	var lit: Dictionary = Rules.light_map(state)
	_check(not Rules.in_diamond(lamp, behind.x, behind.y) and not lit.has(behind), "the square directly behind the flame stays dark")
	_check(lit.has(ahead) and lit.has(side), "the hall in front of the flame and the square beside it are lit")
	var stood := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			var player: Dictionary = state["player"]
			stood = int(player["x"]) == behind.x and int(player["y"]) == behind.y
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "rear shade solution failed")
			return
		state = out["state"]
	_check(stood, "the rear shade is snuffed from the dark square behind the flame")


func _check_late_call() -> void:
	var index := _index_of("The Late Call")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var exit_cell := _find_tile(state, Rules.Tile.EXIT)
	var lit0: Dictionary = Rules.light_map(state)
	_check(lit0.has(exit_cell) and Rules.watched_tiles(state, lit0).has(exit_cell), "the late call's door starts lit and watched")
	var saw := false
	for action in puzzle["solution"]:
		if str(action["type"]) != "toggle":
			var before: Dictionary = Rules.apply(state, action)
			if before["result"] != Rules.Result.OK:
				_check(false, "late call approach failed")
				return
			state = before["state"]
			continue
		var lamp: Dictionary = state["lamps"][int(action["lamp"])]
		var dist0 := absi(int(state["guards"][0]["x"]) - int(lamp["x"])) + absi(int(state["guards"][0]["y"]) - int(lamp["y"]))
		var dist1 := absi(int(state["guards"][1]["x"]) - int(lamp["x"])) + absi(int(state["guards"][1]["y"]) - int(lamp["y"]))
		var player: Dictionary = state["player"]
		var guard_before: Dictionary = state["guards"][0]
		var out: Dictionary = Rules.apply(state, action)
		saw = true
		var guard_after: Dictionary = out["state"]["guards"][0]
		_check(dist0 < dist1, "the late call's nearer keeper is strictly closer")
		_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "the snuff calls the nearer keeper")
		_check(out["step"] == Vector2i(int(player["x"]), int(player["y"])), "his next step is the square you are standing on")
		_check(
			int(guard_after["x"]) == int(guard_before["x"]) and int(guard_after["y"]) == int(guard_before["y"]),
			"he has not taken that step yet"
		)
		_check(not bool(out["state"]["guards"][1]["alert"]), "the farther keeper is not called")
		var waited: Dictionary = Rules.apply(out["state"], {"type": "wait"})
		_check(waited["result"] == Rules.Result.LOSS and waited["reason"] == "guard", "waiting lets the called keeper step onto you")
		break
	_check(saw, "the late call solution snuffs the lamp")


func _check_closed_hall() -> void:
	var index := _index_of("The Closed Hall")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var exit_cell := _find_tile(state, Rules.Tile.EXIT)
	_check(Rules.light_map(state).has(exit_cell), "the closed hall's door starts lit")
	var first: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	_check(first["result"] == Rules.Result.OK, "the square behind the hall lamp is dark")
	state = first["state"]
	var player: Dictionary = state["player"]
	var dest := Vector2i(int(player["x"]) + 1, int(player["y"]))
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(dest) and not Rules.watched_tiles(state, lit).has(dest), "the hall is lit and unwatched")
	var refused: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stayed: Dictionary = refused["state"]["player"]
	_check(
		refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "lit" and int(stayed["x"]) == int(player["x"]) and int(stayed["y"]) == int(player["y"]),
		"unwatched lit floor in the gallery is refused"
	)
	var used := {}
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			used[int(action["lamp"])] = true
	_check(used.has(0) and not used.has(1), "the closed hall snuffs the hall lamp and leaves the lower wick")


func _check_lit_crossing() -> void:
	var index := _index_of("The Lit Crossing")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var gap := _find_tile(state, Rules.Tile.GAP)
	_check(not bool(state["lamps"][0]["lit"]) and not Rules.light_map(state).has(gap), "the lit crossing's gap starts dark")
	var blocked := Puzzles.initial_state(index)
	for token in ["R", "R", "R", "R", "D"]:
		var step: Dictionary = Rules.apply(blocked, {"type": "move", "dx": 1 if token == "R" else 0, "dy": 1 if token == "D" else 0})
		if step["result"] != Rules.Result.OK:
			_check(false, "lit crossing gap approach failed")
			return
		blocked = step["state"]
	var dark: Dictionary = Rules.apply(blocked, {"type": "move", "dx": 1, "dy": 0})
	var stayed: Dictionary = dark["state"]["player"]
	var before: Dictionary = blocked["player"]
	_check(
		dark["result"] == Rules.Result.ILLEGAL and dark["reason"] == "darkgap" and int(stayed["x"]) == int(before["x"]) and int(stayed["y"]) == int(before["y"]),
		"a dark gap is still refused"
	)
	var toggles := 0
	var saw := false
	var crossed := false
	state = Puzzles.initial_state(index)
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
			var out: Dictionary = Rules.apply(state, action)
			saw = true
			_check(out["result"] == Rules.Result.OK and int(out["called"]) == -1, "lighting the crossing wick calls no one")
			_check(bool(out["state"]["lamps"][0]["lit"]) and Rules.light_map(out["state"]).has(gap), "lighting the crossing wick opens the gap")
			state = out["state"]
			continue
		if str(action["type"]) == "move":
			var dest := Vector2i(int(state["player"]["x"]) + int(action["dx"]), int(state["player"]["y"]) + int(action["dy"]))
			if dest == gap:
				var lights: Dictionary = Rules.light_map(state)
				_check(
					bool(state["lamps"][0]["lit"]) and bool(state["lamps"][1]["lit"]) and lights.has(gap) and not Rules.watched_tiles(state, lights).has(gap),
					"the gap is lit and unwatched when you cross"
				)
				crossed = true
		var step: Dictionary = Rules.apply(state, action)
		if step["result"] != Rules.Result.OK and step["result"] != Rules.Result.WIN:
			_check(false, "lit crossing solution broke before the check finished")
			return
		state = step["state"]
	_check(saw and toggles == 1, "the lit crossing solution lights its gap lamp once")
	_check(crossed, "the lit crossing solution crosses the gap")


func _check_keepers_square() -> void:
	var index := _index_of("The Keeper's Square")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 0, "the keeper's square is solved without snuffing")
	var state := Puzzles.initial_state(index)
	var guard: Dictionary = state["guards"][0]
	var tile := Vector2i(int(guard["x"]), int(guard["y"]))
	var lit: Dictionary = Rules.light_map(state)
	_check(not lit.has(tile) and not Rules.watched_tiles(state, lit).has(tile), "the keeper stands on a dark square that is not watched")
	for _i in 2:
		var step: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
		if step["result"] != Rules.Result.OK:
			_check(false, "keeper square approach failed")
			return
		state = step["state"]
	var lost: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var landed: Dictionary = lost["state"]["player"]
	_check(
		lost["result"] == Rules.Result.LOSS and lost["reason"] == "guard" and int(landed["x"]) == tile.x and int(landed["y"]) == tile.y,
		"stepping onto the keeper is a loss"
	)
	state = Puzzles.initial_state(index)
	for action in puzzle["solution"]:
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "keeper square solution failed")
			return
		state = out["state"]
	var end: Dictionary = state["guards"][0]
	_check(int(end["x"]) == tile.x and int(end["y"]) == tile.y and not bool(end["alert"]), "the keeper never leaves his square")


func _check_outer_ring() -> void:
	var index := _index_of("The Outer Ring")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var guard: Dictionary = state["guards"][0]
	var lamp: Dictionary = state["lamps"][0]
	var inner := Vector2i(5, 2)
	var outer := Vector2i(6, 2)
	var exit_cell := _find_tile(state, Rules.Tile.EXIT)
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	var inner_dist := absi(inner.x - int(guard["x"])) + absi(inner.y - int(guard["y"]))
	var outer_dist := absi(outer.x - int(guard["x"])) + absi(outer.y - int(guard["y"]))
	var exit_dist := absi(exit_cell.x - int(guard["x"])) + absi(exit_cell.y - int(guard["y"]))
	_check(int(guard["vision"]) == 1, "the outer ring keeper sees one square")
	_check(inner_dist <= int(guard["vision"]) and lit.has(inner) and watch.has(inner), "the inner square is inside his vision and watched")
	_check(outer_dist == int(guard["vision"]) + 1 and lit.has(outer) and not watch.has(outer), "the next square is lit and outside his vision")
	_check(
		exit_dist > int(guard["vision"]) and lit.has(exit_cell) and not watch.has(exit_cell) and Rules.in_diamond(lamp, exit_cell.x, exit_cell.y),
		"the door is lit, inside the lamp, and outside his vision"
	)
	var side := Rules.clone(state)
	side["player"]["x"] = 8
	side["player"]["y"] = 2
	var refused: Dictionary = Rules.apply(side, {"type": "move", "dx": -1, "dy": 0})
	var stayed: Dictionary = refused["state"]["player"]
	_check(
		refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "lit" and int(stayed["x"]) == 8 and int(stayed["y"]) == 2,
		"the lit door outside his vision is refused"
	)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 1, "the outer ring solution snuffs its lamp once")


func _find_tile(state: Dictionary, kind: int) -> Vector2i:
	for y in state["h"]:
		for x in state["w"]:
			if Rules.tile_at(state, x, y) == kind:
				return Vector2i(x, y)
	return Vector2i(-1, -1)


func _path_has(path: Array, cell: Vector2i) -> bool:
	for point in path:
		var tile: Vector2i = point
		if tile == cell:
			return true
	return false
