extends SceneTree

const Rules := preload("res://scripts/census_rules.gd")

var _phase := 0
var _failed := 0
var _passed := 0


func _init() -> void:
	call_deferred("_boot")


func _initialize() -> void:
	_boot()


func _boot() -> void:
	if _phase == 0:
		_phase = 1
		if _run() != 0:
			_print_summary()
			quit(1)
			return
		# The floor-select screen is built in _ready, which waits until the
		# tree is up. Running it now, inside _initialize, would see a null town.
		call_deferred("_boot")
		return
	if _phase != 1:
		return
	if not root.is_node_ready():
		call_deferred("_boot")
		return
	_phase = 2
	_check("a finished cistern census returns to the floor select", _cistern_return())
	_check("a finished cloister census returns to the floor select", _cloister_return())
	_check("a finished crypt census returns to the floor select", _crypt_return())
	_check("a finished ossuary census returns to the floor select", _ossuary_return())
	_check("a finished reliquary census returns to the floor select", _reliquary_return())
	_check("a finished undercroft census returns to the floor select", _undercroft_return())
	_check("a finished well house census returns to the floor select", _wellhouse_return())
	_check("a finished scriptorium census returns to the floor select", _scriptorium_return())
	_check("a finished binding census returns to the floor select", _binding_return())
	_check("a finished chart room census returns to the floor select", _chartroom_return())
	_check("a finished bell loft census returns to the floor select", _bellloft_return())
	_print_summary()
	quit(0 if _failed == 0 else 1)


func _print_summary() -> void:
	print("----")
	if _failed > 0:
		print("FAILED %d  passed %d" % [_failed, _passed])
	else:
		print("ALL PASSED %d" % _passed)


func _run() -> int:
	_check("exit reachable", _exit_reachable())
	_check("oil covers shortest path plus 4", _oil_margin())
	_check("scripted path reaches the lift without a hit", _scripted_path())
	_check("incomplete map pays less than the full accurate map", _incomplete_pays_less())
	_check("a false hazard mark does not raise payout", _false_hazard())
	_check("stepping into a telegraphed hit is detected", _step_into_hit())
	_check("a hit costs 3 oil and only oil at 0 ends the descent", _hit_costs_oil())
	_check("east square is a closed loop of corridors", _loop())
	_check("large flask covers a safe survey of every payable tile", _survey())
	_check("purse starts unable to buy the larger flask", _outfitter())
	_check("turns, marks, and wall bumps do not drink oil", _free_actions())
	_check("the lift extracts even on the last oil", _last_oil_extract())
	_check("town instruction is a single line", _town_line())
	_check("main scene builds the town and the descent", _scene_builds())
	_check("cistern layout, ring, and oil", _cistern_layout())
	_check("cistern census accepts the true sheet and rejects a wrong one", _cistern_census())
	_check("cloister layout, walk, and oil", _cloister_layout())
	_check("cloister census accepts the true sheet and rejects a wrong one", _cloister_census())
	_check("crypt layout, ring, and oil", _crypt_layout())
	_check("crypt census accepts the true sheet and rejects a wrong one", _crypt_census())
	_check("ossuary layout, ring, and oil", _ossuary_layout())
	_check("ossuary census accepts the true sheet and rejects a wrong one", _ossuary_census())
	_check("reliquary layout, ring, and oil", _reliquary_layout())
	_check("reliquary census accepts the true sheet and rejects a wrong one", _reliquary_census())
	_check("undercroft layout, ring, and oil", _undercroft_layout())
	_check("undercroft census accepts the true sheet and rejects a wrong one", _undercroft_census())
	_check("well house layout, ring, and oil", _wellhouse_layout())
	_check("well house census accepts the true sheet and rejects a wrong one", _wellhouse_census())
	_check("scriptorium layout, ring, and oil", _scriptorium_layout())
	_check("scriptorium census accepts the true sheet and rejects a wrong one", _scriptorium_census())
	_check("binding layout, ring, and oil", _binding_layout())
	_check("binding census accepts the true sheet and rejects a wrong one", _binding_census())
	_check("chart room layout, ring, and oil", _chartroom_layout())
	_check("chart room census accepts the true sheet and rejects a wrong one", _chartroom_census())
	_check("bell loft layout, ring, and oil", _bellloft_layout())
	_check("bell loft census accepts the true sheet and rejects a wrong one", _bellloft_census())
	if _failed > 0:
		return 1
	return 0


func _check(name: String, err: String) -> void:
	if err == "":
		_passed += 1
		print("PASS ", name)
	else:
		_failed += 1
		print("FAIL ", name, ": ", err)


func _exit_reachable() -> String:
	var cells: Array = Rules.shortest_path_cells()
	if cells.is_empty():
		return "no path from the start to the lift"
	if cells[0] != Rules.start_pos():
		return "path does not start on the start tile"
	if cells[cells.size() - 1] != Rules.lift_pos():
		return "path does not end on the lift"
	var enemy: Vector2i = Rules.enemy_pos()
	for i in cells.size():
		var cell: Vector2i = cells[i]
		if cell == enemy:
			return "shortest path steps on the warden"
		if not Rules.is_walkable(cell):
			return "shortest path leaves walkable tiles at %s" % cell
		if i > 0:
			var delta: Vector2i = cell - cells[i - 1]
			if abs(delta.x) + abs(delta.y) != 1:
				return "shortest path jumps at %s" % cell
	return ""


func _oil_margin() -> String:
	var steps := Rules.shortest_path_steps()
	if steps < 1:
		return "shortest path is missing"
	var margin := Rules.SMALL_FLASK_OIL - steps
	if margin < 4:
		return "start oil %d is only %d above the %d-step path" % [Rules.SMALL_FLASK_OIL, margin, steps]
	print("  shortest %d  start oil %d  margin %d" % [steps, Rules.SMALL_FLASK_OIL, margin])
	return ""


func _scripted_path() -> String:
	var actions: Array = Rules.scripted_safe_actions()
	if actions.is_empty():
		return "no safe scripted path"
	var state = Rules.new_run(Rules.SMALL_FLASK_OIL)
	for i in actions.size():
		var result: Dictionary = Rules.step(state, actions[i])
		if bool(result.hit):
			return "hit on action %d at %s" % [i, state.pos]
		if state.end_reason != Rules.EndReason.NONE and i != actions.size() - 1:
			return "ended early at action %d reason %d" % [i, state.end_reason]
		if actions[i] != Vector2i.ZERO and not bool(result.moved):
			return "scripted step %d did not move" % i
	if state.end_reason != Rules.EndReason.EXTRACTED:
		return "not extracted (reason %d, pos %s)" % [state.end_reason, state.pos]
	if state.pos != Rules.lift_pos():
		return "finished off the lift"
	if state.oil != Rules.SMALL_FLASK_OIL - actions.size():
		return "oil %d after %d actions, expected %d" % [state.oil, actions.size(), Rules.SMALL_FLASK_OIL - actions.size()]
	var full: int = Rules.payout(Rules.accurate_sheet()).total
	var carried: int = Rules.payout(state.marks).total
	if carried <= 0:
		return "scripted extract paid nothing"
	if carried >= full:
		return "scripted sheet paid %d, which is not less than the full %d" % [carried, full]
	if carried < Rules.LARGE_FLASK_COST:
		return "scripted payout %d cannot afford the %d-coin flask" % [carried, Rules.LARGE_FLASK_COST]
	print("  safe actions %d  carried payout %d  full payout %d" % [actions.size(), carried, full])
	return ""


func _incomplete_pays_less() -> String:
	var full_marks: Dictionary = Rules.accurate_sheet()
	var full: Dictionary = Rules.payout(full_marks)
	if int(full.loop) != 1:
		return "full sheet did not complete the east square"
	var missing_corridor: Dictionary = full_marks.duplicate()
	var corridor: Vector2i = Rules.corridor_cells()[0]
	missing_corridor.erase(corridor)
	var without_corridor: Dictionary = Rules.payout(missing_corridor)
	if int(without_corridor.total) >= int(full.total):
		return "dropping corridor %s did not lower pay (%d vs %d)" % [corridor, without_corridor.total, full.total]
	var missing_hazard: Dictionary = full_marks.duplicate()
	var hazard: Vector2i = Rules.hazard_cells()[0]
	missing_hazard.erase(hazard)
	var without_hazard: Dictionary = Rules.payout(missing_hazard)
	if int(without_hazard.total) >= int(full.total):
		return "dropping hazard %s did not lower pay (%d vs %d)" % [hazard, without_hazard.total, full.total]
	if int(full.total) != Rules.corridor_cells().size() * Rules.CORRIDOR_VALUE + Rules.hazard_cells().size() * Rules.HAZARD_VALUE + Rules.LOOP_VALUE:
		return "full total %d does not match the documented formula" % full.total
	print("  full %d  without one corridor %d  without one hazard %d" % [full.total, without_corridor.total, without_hazard.total])
	return ""


func _false_hazard() -> String:
	var full_marks: Dictionary = Rules.accurate_sheet()
	var before: Dictionary = Rules.payout(full_marks)
	var on_wall: Dictionary = full_marks.duplicate()
	on_wall[Vector2i(0, 0)] = Rules.Mark.HAZARD
	var after_wall: Dictionary = Rules.payout(on_wall)
	if int(after_wall.total) > int(before.total):
		return "hazard ink on a wall raised the total"
	if int(after_wall.hazard_pay) != int(before.hazard_pay) or int(after_wall.total) != int(before.total):
		return "hazard ink on a wall changed the payout"
	var bare: int = Rules.payout({}).total
	var corridor: Vector2i = Rules.corridor_cells()[0]
	var lied := {}
	lied[corridor] = Rules.Mark.HAZARD
	if int(Rules.payout(lied).total) > bare:
		return "a hazard mark on a corridor raised an empty sheet"
	var replaced: Dictionary = full_marks.duplicate()
	replaced[corridor] = Rules.Mark.HAZARD
	if int(Rules.payout(replaced).total) > int(before.total):
		return "replacing a true corridor with a hazard mark raised the payout"
	return ""


func _step_into_hit() -> String:
	var opening = Rules.new_run(Rules.SMALL_FLASK_OIL)
	var quiet: Dictionary = Rules.step(opening, Vector2i(1, 0))
	if bool(quiet.hit):
		return "the opening step was treated as a hit"
	var tele: Vector2i = Rules.telegraph_tile(0)
	var approach: Vector2i = Rules.walkable_approach(tele)
	if approach.x < 0:
		return "the opening swing has no walkable approach"
	var state = Rules.new_run(Rules.SMALL_FLASK_OIL)
	state.pos = approach
	var before: int = state.oil
	var dir: Vector2i = tele - approach
	var result: Dictionary = Rules.step(state, dir)
	if not bool(result.hit):
		return "step() did not flag the telegraphed tile"
	if state.pos != tele:
		return "player did not enter the telegraphed tile"
	var expected: int = before - Rules.MOVE_OIL - Rules.HIT_OIL
	if state.oil != expected:
		return "oil is %d, expected %d" % [state.oil, expected]
	if state.end_reason != Rules.EndReason.NONE:
		return "a hit ended the descent while oil remained"
	var facing_state = Rules.new_run(Rules.SMALL_FLASK_OIL)
	facing_state.pos = approach
	facing_state.facing = Rules.facing_from_vector(dir)
	var forward: Dictionary = Rules.act(facing_state, Rules.Action.FORWARD)
	if not bool(forward.hit):
		return "stepping forward into the swing was not detected"
	return ""


func _hit_costs_oil() -> String:
	var tele: Vector2i = Rules.telegraph_tile(0)
	var approach: Vector2i = Rules.walkable_approach(tele)
	var dir: Vector2i = tele - approach
	var survivor = Rules.new_run(Rules.SMALL_FLASK_OIL)
	survivor.pos = approach
	survivor.oil = Rules.MOVE_OIL + Rules.HIT_OIL + 1
	var lived: Dictionary = Rules.step(survivor, dir)
	if not bool(lived.hit):
		return "surviving swing was not detected"
	if survivor.end_reason != Rules.EndReason.NONE or survivor.oil != 1:
		return "swing should leave 1 oil and keep the descent going (oil %d reason %d)" % [survivor.oil, survivor.end_reason]
	var doomed = Rules.new_run(Rules.SMALL_FLASK_OIL)
	doomed.pos = approach
	doomed.oil = Rules.MOVE_OIL + Rules.HIT_OIL
	var died: Dictionary = Rules.step(doomed, dir)
	if not bool(died.hit):
		return "fatal swing was not detected"
	if doomed.oil != 0 or doomed.end_reason != Rules.EndReason.LAMP_OUT:
		return "oil at 0 should end the descent (oil %d reason %d)" % [doomed.oil, doomed.end_reason]
	var campaign = Rules.new_campaign()
	var bill: Dictionary = Rules.settle(campaign, doomed)
	if int(bill.total) != 0 or campaign.purse != 0:
		return "a lamp-out return paid the sheet"
	return ""


func _loop() -> String:
	var cells: Array = Rules.loop_cells()
	if cells.size() < 4:
		return "loop has %d tiles" % cells.size()
	var have := {}
	for cell in cells:
		if have.has(cell):
			return "duplicate loop tile %s" % cell
		have[cell] = true
		if not Rules.is_corridor_cell(cell):
			return "loop tile %s is not a corridor" % cell
	for cell in cells:
		var degree := 0
		for dir in Rules.cardinals():
			if have.has(cell + dir):
				degree += 1
		if degree != 2:
			return "loop tile %s has %d corridor neighbors in the loop" % [cell, degree]
	var swings: Array = Rules.swing_tiles()
	if swings.size() != 2 or swings[0] == swings[1]:
		return "the warden should telegraph two distinct tiles"
	for swing in swings:
		if not Rules.is_walkable(swing):
			return "swing tile %s is not walkable" % swing
	if Rules.is_walkable(Rules.enemy_pos()):
		return "the warden's own tile is walkable"
	return ""


func _survey() -> String:
	var cover := Rules.safe_survey_steps()
	if cover < 0:
		return "no safe route visits every payable tile and still reaches the lift"
	if Rules.LARGE_FLASK_OIL < cover:
		return "large flask %d is shorter than the safe survey %d" % [Rules.LARGE_FLASK_OIL, cover]
	print("  safe survey %d  large flask %d" % [cover, Rules.LARGE_FLASK_OIL])
	return ""


func _outfitter() -> String:
	var campaign = Rules.new_campaign()
	if campaign.purse != 0 or campaign.flask_oil != Rules.SMALL_FLASK_OIL or campaign.upgraded:
		return "a new census is not the small flask and an empty purse"
	if Rules.can_buy(campaign):
		return "the opening purse can already buy the flask"
	var actions: Array = Rules.scripted_safe_actions()
	var state = Rules.new_run(campaign.flask_oil)
	for dir in actions:
		Rules.step(state, dir)
	if state.end_reason != Rules.EndReason.EXTRACTED:
		return "the teaching extract did not reach the lift"
	var bill: Dictionary = Rules.settle(campaign, state)
	if campaign.purse != int(bill.total):
		return "purse did not receive the payout"
	if not Rules.can_buy(campaign):
		return "purse %d still cannot buy the %d-coin flask" % [campaign.purse, Rules.LARGE_FLASK_COST]
	var before: int = campaign.purse
	if not Rules.buy_flask(campaign):
		return "buy failed"
	if not campaign.upgraded or campaign.flask_oil != Rules.LARGE_FLASK_OIL:
		return "flask did not upgrade"
	if campaign.purse != before - Rules.LARGE_FLASK_COST:
		return "purse was not charged %d" % Rules.LARGE_FLASK_COST
	if Rules.buy_flask(campaign):
		return "the flask can be bought twice"
	Rules.settle(campaign, state)
	if campaign.purse != before - Rules.LARGE_FLASK_COST:
		return "turning the same sheet in twice paid again"
	var restarted = Rules.new_campaign()
	if restarted.purse != 0 or restarted.upgraded or restarted.flask_oil != Rules.SMALL_FLASK_OIL:
		return "restart did not restore the opening purse and small flask"
	return ""


func _free_actions() -> String:
	var state = Rules.new_run(Rules.SMALL_FLASK_OIL)
	var oil: int = state.oil
	var swing: int = state.telegraph_index
	var facing: int = state.facing
	Rules.act(state, Rules.Action.TURN_LEFT)
	Rules.act(state, Rules.Action.TURN_RIGHT)
	Rules.act(state, Rules.Action.MARK)
	if state.oil != oil or state.telegraph_index != swing:
		return "a turn or a mark drank oil or advanced the swing"
	if state.facing != facing:
		return "a left turn and a right turn did not restore facing"
	state.facing = Rules.facing_from_vector(Vector2i(0, -1))
	var bumped: Dictionary = Rules.act(state, Rules.Action.FORWARD)
	if bool(bumped.moved) or state.oil != oil or state.telegraph_index != swing:
		return "bumping a wall moved, drank oil, or advanced the swing"
	var wall: Vector2i = state.pos + Vector2i(0, -1)
	if int(state.marks.get(wall, Rules.Mark.NONE)) != Rules.Mark.WALL:
		return "bumping a blank wall did not ink it"
	var waited: Dictionary = Rules.step(state, Vector2i.ZERO)
	if bool(waited.hit) or state.pos != Rules.start_pos() or state.oil != oil - Rules.MOVE_OIL:
		return "waiting on the safe start tile mis-resolved"
	if state.telegraph_index == swing:
		return "waiting did not advance the swing"
	return ""


func _last_oil_extract() -> String:
	var lift: Vector2i = Rules.lift_pos()
	var approach: Vector2i = Rules.walkable_approach(lift)
	if approach.x < 0:
		return "lift has no approach"
	var state = Rules.new_run(1)
	state.pos = approach
	state.oil = 1
	var result: Dictionary = Rules.step(state, lift - approach)
	if not bool(result.extracted) or state.end_reason != Rules.EndReason.EXTRACTED:
		return "stepping onto the lift with 1 oil did not extract"
	if state.oil != 0:
		return "extract did not spend the last oil"
	var campaign = Rules.new_campaign()
	var bill: Dictionary = Rules.settle(campaign, state)
	if int(bill.total) <= 0 or campaign.purse != int(bill.total):
		return "the lift sheet paid nothing"
	return ""


func _scene_builds() -> String:
	if load("res://scenes/main.tscn") == null:
		return "main scene did not load"
	if load("res://scripts/game.gd") == null:
		return "game.gd did not load"
	var town = load("res://scripts/town_view.gd").new()
	var descent = load("res://scripts/descent_view.gd").new()
	if town == null or descent == null:
		return "town or descent script did not load"
	town._ready()
	descent._ready()
	if town.purse_label == null or town.buy_button == null or town.receipt_label == null:
		return "town UI was not built"
	if descent.return_button == null:
		return "descent UI was not built"
	var campaign = Rules.new_campaign()
	town.show_campaign(campaign)
	if town.purse_label.text.find("0") < 0:
		return "opening purse was not shown"
	if town.buy_button.disabled != true:
		return "the opening flask was offered for sale"
	town.free()
	descent.free()
	return ""


func _town_line() -> String:
	if Rules.TOWN_LINE.find("\n") != -1:
		return "the town instruction contains a newline"
	if Rules.TOWN_LINE.length() < 40:
		return "the town instruction is missing"
	return ""

func _cistern_layout() -> String:
	if Rules.CORRIDOR_VALUE != 3 or Rules.HAZARD_VALUE != 8 or Rules.LOOP_VALUE != 15:
		return "payout rates changed"
	if Rules.MOVE_OIL != 1 or Rules.HIT_OIL != 3:
		return "oil costs changed"
	if Rules.SMALL_FLASK_OIL != 24 or Rules.LARGE_FLASK_OIL != 120 or Rules.LARGE_FLASK_COST != 40:
		return "flask sizes changed"
	var listed: Array = Rules.floors()
	if listed.size() != 12:
		return "expected the cellar, the cistern, the cloister, the crypt, the ossuary, the reliquary, the undercroft, the well house, the scriptorium, the binding, the chart room, and the bell loft, found %d" % listed.size()
	if str(listed[0].id) != "cellar" or str(listed[1].id) != "cistern" or str(listed[2].id) != "cloister" or str(listed[3].id) != "crypt" or str(listed[4].id) != "ossuary" or str(listed[5].id) != "reliquary" or str(listed[6].id) != "undercroft" or str(listed[7].id) != "wellhouse" or str(listed[8].id) != "scriptorium" or str(listed[9].id) != "binding" or str(listed[10].id) != "chartroom" or str(listed[11].id) != "bellloft":
		return "floor order is not cellar, cistern, cloister, crypt, ossuary, reliquary, undercroft, well house, scriptorium, binding, chart room, then bell loft"
	if Rules.default_floor().id != "cellar":
		return "the default floor is no longer the cellar"
	var floor = Rules.floor_named("cistern")
	if floor == null:
		return "cistern floor is missing"
	if floor.record != Rules.CISTERN_RECORD:
		return "cistern record drifted from its constant"
	if Rules.CISTERN_RECORD != "Record every corridor, the three seep cracks, and the cistern ring around the pit.":
		return "the cistern no longer asks for the seeps and the ring"
	var expected := PackedStringArray([
		"###############",
		"#S............#",
		"#.###########.#",
		"#.#.........#.#",
		"#.#.***.....#.#",
		"#.#.***.....#.#",
		"#.#.***.....#.#",
		"#.#.........#.#",
		"#............L#",
		"#..E..H..H.H..#",
		"###############",
	])
	if floor.rows.size() != expected.size():
		return "cistern height %d" % floor.rows.size()
	for i in expected.size():
		if str(floor.rows[i]) != str(expected[i]):
			return "cistern row %d is %s" % [i, floor.rows[i]]
	if Rules.width(floor) != 15 or Rules.height(floor) != 11:
		return "cistern size %dx%d" % [Rules.width(floor), Rules.height(floor)]
	if Rules.start_pos(floor) != Vector2i(1, 1):
		return "start %s" % Rules.start_pos(floor)
	if Rules.lift_pos(floor) != Vector2i(13, 8):
		return "lift %s" % Rules.lift_pos(floor)
	if Rules.enemy_pos(floor) != Vector2i(3, 9):
		return "warden %s" % Rules.enemy_pos(floor)
	var hazards: Array = Rules.hazard_cells(floor)
	var expect_h: Array = [Vector2i(6, 9), Vector2i(9, 9), Vector2i(11, 9)]
	if hazards.size() != expect_h.size():
		return "hazard count %d" % hazards.size()
	for i in hazards.size():
		if hazards[i] != expect_h[i]:
			return "hazard %d is %s" % [i, hazards[i]]
	if Rules.corridor_cells(floor).size() != 83:
		return "corridors %d" % Rules.corridor_cells(floor).size()
	if Rules.glyph_at(Vector2i(5, 5), floor) != "*" or Rules.glyph_at(Vector2i(4, 4), floor) != "*":
		return "the pit is not marked on the map"
	if Rules.tile_at(Vector2i(5, 5), floor) != Rules.Tile.WALL or Rules.is_walkable(Vector2i(5, 5), floor):
		return "the pit is not solid wall"
	var ring_err := _cistern_ring(floor)
	if ring_err != "":
		return ring_err
	var swings: Array = Rules.swing_tiles(floor)
	if swings.size() != 2 or swings[0] == swings[1]:
		return "the warden should telegraph two distinct tiles"
	for swing in swings:
		if not Rules.is_walkable(swing, floor):
			return "swing tile %s is not walkable" % swing
	if Rules.is_walkable(Rules.enemy_pos(floor), floor):
		return "the warden's own tile is walkable"
	var steps := Rules.shortest_path_steps(floor)
	if steps != 19:
		return "shortest cistern path is %d, expected 19" % steps
	if Rules.SMALL_FLASK_OIL - steps < 4:
		return "small flask margin slipped to %d" % (Rules.SMALL_FLASK_OIL - steps)
	var actions: Array = Rules.scripted_safe_actions(floor)
	if actions.is_empty():
		return "no safe exit from the cistern"
	var state = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	for i in actions.size():
		var result: Dictionary = Rules.step(state, actions[i])
		if bool(result.hit):
			return "hit on cistern exit action %d at %s" % [i, state.pos]
		if state.end_reason != Rules.EndReason.NONE and i != actions.size() - 1:
			return "cistern exit ended early at action %d" % i
		if actions[i] != Vector2i.ZERO and not bool(result.moved):
			return "cistern exit step %d did not move" % i
	if state.end_reason != Rules.EndReason.EXTRACTED or state.pos != Rules.lift_pos(floor):
		return "cistern exit was not an extract at the lift"
	if state.oil != Rules.SMALL_FLASK_OIL - actions.size():
		return "cistern exit oil %d after %d actions" % [state.oil, actions.size()]
	var full: int = int(Rules.payout(Rules.accurate_sheet(floor), floor).total)
	var carried: int = int(Rules.payout(state.marks, floor).total)
	if carried <= 0 or carried >= full:
		return "exit sheet paid %d against full %d" % [carried, full]
	if Rules.census_accepted(state.marks, floor):
		return "the exit path was accepted as a finished census"
	var cover := Rules.safe_survey_steps(floor)
	if cover != 106:
		return "safe survey is %d, expected 106" % cover
	if cover > Rules.LARGE_FLASK_OIL or cover <= Rules.SMALL_FLASK_OIL:
		return "survey oil %d does not sit between the flasks" % cover
	print("  cistern shortest %d  survey %d  exit pay %d  full %d" % [steps, cover, carried, full])
	return ""


func _cistern_ring(floor) -> String:
	var cells: Array = Rules.loop_cells(floor)
	if cells.size() != 16:
		return "ring size %d" % cells.size()
	var have := {}
	for cell in cells:
		if have.has(cell):
			return "duplicate ring tile %s" % cell
		have[cell] = true
		if not Rules.is_corridor_cell(cell, floor):
			return "ring tile %s is not a corridor" % cell
	for cell in cells:
		var degree := 0
		for dir in Rules.cardinals():
			if have.has(cell + dir):
				degree += 1
		if degree != 2:
			return "ring tile %s has %d neighbors in the ring" % [cell, degree]
	if not have.has(Vector2i(5, 3)) or have.has(Vector2i(5, 4)):
		return "the ring does not rim the pit"
	var pits := 0
	for y in Rules.height(floor):
		for x in Rules.width(floor):
			var p := Vector2i(x, y)
			if Rules.glyph_at(p, floor) != "*":
				continue
			pits += 1
			for dir in Rules.cardinals():
				var n: Vector2i = p + dir
				if Rules.is_corridor_cell(n, floor) and not have.has(n):
					return "corridor %s touches the pit and is outside the ring" % n
	if pits != 9:
		return "pit size %d" % pits
	if str(floor.loop_name) != "Cistern ring":
		return "ring name is %s" % floor.loop_name
	return ""


func _cistern_census() -> String:
	var floor = Rules.floor_named("cistern")
	var cellar = Rules.floor_named("cellar")
	var truth: Dictionary = Rules.accurate_sheet(floor)
	if not Rules.census_accepted(truth, floor):
		return "the true cistern census was rejected"
	var bill: Dictionary = Rules.payout(truth, floor)
	if int(bill.corridors) != 83 or int(bill.hazards) != 3 or int(bill.loop) != 1:
		return "true counts %s/%s loop %s" % [bill.corridors, bill.hazards, bill.loop]
	if int(bill.corridor_pay) != 83 * Rules.CORRIDOR_VALUE:
		return "corridor pay drifted"
	if int(bill.hazard_pay) != 3 * Rules.HAZARD_VALUE:
		return "hazard pay drifted"
	if int(bill.loop_pay) != Rules.LOOP_VALUE:
		return "ring pay drifted"
	if int(bill.total) != 288:
		return "true total %s" % bill.total
	if Rules.format_bill(bill).find("Cistern ring") < 0:
		return "the receipt did not name the cistern ring"
	if Rules.census_accepted({}, floor):
		return "an empty sheet was accepted"
	if int(Rules.payout({}, floor).total) != 0:
		return "an empty sheet paid out"
	var missing_corridor: Dictionary = truth.duplicate()
	missing_corridor.erase(Rules.start_pos(floor))
	if Rules.census_accepted(missing_corridor, floor):
		return "a sheet missing the start corridor was accepted"
	var missing_bill: Dictionary = Rules.payout(missing_corridor, floor)
	if int(missing_bill.total) >= 288 or int(missing_bill.loop) != 1:
		return "dropping a corridor outside the ring changed the census the wrong way"
	var seep: Vector2i = Rules.hazard_cells(floor)[0]
	var missing_seep: Dictionary = truth.duplicate()
	missing_seep.erase(seep)
	if Rules.census_accepted(missing_seep, floor):
		return "a sheet missing a seep was accepted"
	if int(Rules.payout(missing_seep, floor).total) >= 288:
		return "dropping a seep did not lower pay"
	var broken_ring: Dictionary = truth.duplicate()
	var rim: Vector2i = Rules.loop_cells(floor)[0]
	broken_ring[rim] = Rules.Mark.WALL
	if Rules.census_accepted(broken_ring, floor):
		return "a broken ring was accepted"
	var broken_bill: Dictionary = Rules.payout(broken_ring, floor)
	if int(broken_bill.loop) != 0 or int(broken_bill.total) >= 288:
		return "a broken ring still paid as a finished sheet"
	var swapped: Dictionary = truth.duplicate()
	swapped[seep] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(swapped, floor):
		return "a seep marked as a corridor was accepted"
	if int(Rules.payout(swapped, floor).hazard_pay) >= int(bill.hazard_pay):
		return "mislabeling a seep did not lower hazard pay"
	if int(Rules.payout(swapped, floor).total) > 288:
		return "mislabeling a seep raised the payout"
	var false_wall: Dictionary = truth.duplicate()
	false_wall[Vector2i(0, 0)] = Rules.Mark.HAZARD
	if Rules.census_accepted(false_wall, floor):
		return "a hazard mark on a wall was accepted"
	if int(Rules.payout(false_wall, floor).total) != 288 or int(Rules.payout(false_wall, floor).hazard_pay) != int(bill.hazard_pay):
		return "a hazard mark on a wall changed the payout"
	var pit_wall: Dictionary = truth.duplicate()
	pit_wall[Vector2i(4, 4)] = Rules.Mark.WALL
	if not Rules.census_accepted(pit_wall, floor):
		return "inking the pit as a wall rejected a true census"
	pit_wall[Vector2i(4, 4)] = Rules.Mark.HAZARD
	if Rules.census_accepted(pit_wall, floor):
		return "calling the pit a hazard was accepted"
	var warden_mark: Dictionary = truth.duplicate()
	warden_mark[Rules.enemy_pos(floor)] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(warden_mark, floor):
		return "the warden tile was accepted as a corridor"
	if int(Rules.payout(warden_mark, floor).total) != 288:
		return "marking the warden changed the payout"
	var only_ring := {}
	for cell in Rules.loop_cells(floor):
		only_ring[cell] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(only_ring, floor):
		return "the ring alone was accepted as the census"
	var ring_bill: Dictionary = Rules.payout(only_ring, floor)
	if int(ring_bill.loop) != 1 or int(ring_bill.hazards) != 0 or int(ring_bill.total) >= 288:
		return "the ring bonus did not stay inside the shared payout rule"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cellar):
		return "the cistern sheet was accepted as the cellar"
	if Rules.census_accepted(Rules.accurate_sheet(cellar), floor):
		return "the cellar sheet was accepted as the cistern"
	if not Rules.census_accepted(Rules.accurate_sheet(cellar), cellar):
		return "the cellar's true census was rejected"
	var broken_cellar: Dictionary = Rules.accurate_sheet(cellar).duplicate()
	broken_cellar.erase(Rules.corridor_cells(cellar)[0])
	if Rules.census_accepted(broken_cellar, cellar):
		return "an incomplete cellar census was accepted"
	var cellar_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cellar), cellar)
	if int(cellar_bill.total) != 211 or str(cellar_bill.loop_name) != "East square":
		return "the cellar payout changed"
	if Rules.format_bill(cellar_bill).find("East square") < 0:
		return "the cellar receipt dropped the east square"
	var hazard: Vector2i = Rules.hazard_cells(floor)[0]
	var approach: Vector2i = Rules.walkable_approach(hazard, floor)
	if approach.x < 0:
		return "seep has no approach"
	var walker = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	walker.pos = approach
	walker.oil = 10
	var before: int = walker.oil
	var stepped: Dictionary = Rules.step(walker, hazard - approach)
	if bool(stepped.hit):
		return "opening seep step was a swing"
	if walker.oil != before - Rules.MOVE_OIL:
		return "seep burned extra oil"
	if int(walker.marks.get(hazard, Rules.Mark.NONE)) != Rules.Mark.HAZARD:
		return "seep was not inked as a hazard"
	return ""


func _cistern_return() -> String:
	var game_script = load("res://scripts/game.gd")
	var select_script = load("res://scripts/floor_select_view.gd")
	if game_script == null or select_script == null:
		return "game or floor select did not load"
	var game = game_script.new()
	root.add_child(game)
	if game.town == null or game.floor_select == null or game.descent == null:
		game.free()
		return "the game did not build its screens"
	if game.town.floors_button == null or game.town.floors_button.text != "Floor select":
		game.free()
		return "town has no floor select"
	if game.floor_select.record_for("cistern") != Rules.CISTERN_RECORD:
		game.free()
		return "floor select does not ask for the cistern census"
	if game.floor_select.record_for("cellar") != Rules.CELLAR_RECORD:
		game.free()
		return "floor select dropped the cellar census"
	if game.floor_select.back_button.text != "Back to town":
		game.free()
		return "floor select has no return to town"
	game._on_descend_floor("cistern")
	if game.descent.state == null or game.descent.state.floor.id != "cistern":
		game.free()
		return "descend did not open the cistern"
	var state = game.descent.state
	var lift: Vector2i = Rules.lift_pos(state.floor)
	var approach: Vector2i = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var left: Dictionary = Rules.step(state, lift - approach)
	if not bool(left.extracted):
		game.free()
		return "short cistern sheet did not leave on the lift"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to town":
		game.free()
		return "a short sheet offered the floor select"
	game._on_return(state)
	if not game.town.visible or game.floor_select.visible or game.descent.visible:
		game.free()
		return "a short census did not return to town"
	if bool(game.campaign.completed.get("cistern", false)):
		game.free()
		return "a short census was accepted"
	if game.town.outcome_label.text.find("not finished") < 0:
		game.free()
		return "the clerk treated a short sheet as finished"
	game._on_floors()
	if not game.floor_select.visible or game.town.visible:
		game.free()
		return "floor select did not open from town"
	game._on_descend_floor("cistern")
	state = game.descent.state
	state.marks = Rules.accurate_sheet(state.floor)
	lift = Rules.lift_pos(state.floor)
	approach = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var done: Dictionary = Rules.step(state, lift - approach)
	if not bool(done.extracted) or not Rules.census_accepted(state.marks, state.floor):
		game.free()
		return "the finished sheet did not extract as an accepted census"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to floor select":
		game.free()
		return "a finished census did not offer the floor select"
	game._on_return(state)
	if not game.floor_select.visible or game.town.visible or game.descent.visible:
		game.free()
		return "a finished census did not return to the floor select"
	if not bool(game.campaign.completed.get("cistern", false)):
		game.free()
		return "the finished census was not recorded"
	if bool(game.campaign.completed.get("cellar", false)):
		game.free()
		return "the cellar was marked complete"
	if game.floor_select.status_for("cistern") != "Census complete":
		game.free()
		return "floor select did not show the cistern census complete"
	if game.floor_select.status_for("cellar") != "Census open":
		game.free()
		return "the cellar card was closed"
	if game.floor_select.notice_label.text.find("complete") < 0:
		game.free()
		return "arrival did not say the census is complete"
	if game.campaign.purse < 288 or game.campaign.last_outcome != "complete":
		game.free()
		return "the finished census was not paid"
	game._show_town()
	if not game.town.visible or game.floor_select.visible:
		game.free()
		return "Back to town did not leave the floor select"
	if game.town.outcome_label.text.find("complete") < 0:
		game.free()
		return "town clerk did not keep the finished census"
	game.free()
	return ""


func _cloister_layout() -> String:
	if Rules.CORRIDOR_VALUE != 3 or Rules.HAZARD_VALUE != 8 or Rules.LOOP_VALUE != 15:
		return "payout rates changed"
	if Rules.MOVE_OIL != 1 or Rules.HIT_OIL != 3:
		return "oil costs changed"
	if Rules.SMALL_FLASK_OIL != 24 or Rules.LARGE_FLASK_OIL != 120 or Rules.LARGE_FLASK_COST != 40:
		return "flask sizes changed"
	var floor = Rules.floor_named("cloister")
	if floor == null:
		return "cloister floor is missing"
	if floor.record != Rules.CLOISTER_RECORD:
		return "cloister record drifted from its constant"
	if Rules.CLOISTER_RECORD != "Record every corridor, the four cinder cracks, and the cloister walk around the garth.":
		return "the cloister no longer asks for the cinders and the walk"
	var expected := PackedStringArray([
		"################",
		"#S.............#",
		"#.############.#",
		"#.#.......####.#",
		"#.#.+++++.####.#",
		"#.#.+++++.####.#",
		"#.#.......####.#",
		"#..E..........L#",
		"#.H.H.H.H......#",
		"################",
	])
	if floor.rows.size() != expected.size():
		return "cloister height %d" % floor.rows.size()
	for i in expected.size():
		if str(floor.rows[i]) != str(expected[i]):
			return "cloister row %d is %s" % [i, floor.rows[i]]
	if Rules.width(floor) != 16 or Rules.height(floor) != 10:
		return "cloister size %dx%d" % [Rules.width(floor), Rules.height(floor)]
	if Rules.start_pos(floor) != Vector2i(1, 1):
		return "start %s" % Rules.start_pos(floor)
	if Rules.lift_pos(floor) != Vector2i(14, 7):
		return "lift %s" % Rules.lift_pos(floor)
	if Rules.enemy_pos(floor) != Vector2i(3, 7):
		return "warden %s" % Rules.enemy_pos(floor)
	var hazards: Array = Rules.hazard_cells(floor)
	var expect_h: Array = [Vector2i(2, 8), Vector2i(4, 8), Vector2i(6, 8), Vector2i(8, 8)]
	if hazards.size() != expect_h.size():
		return "hazard count %d" % hazards.size()
	for i in hazards.size():
		if hazards[i] != expect_h[i]:
			return "hazard %d is %s" % [i, hazards[i]]
	if Rules.corridor_cells(floor).size() != 65:
		return "corridors %d" % Rules.corridor_cells(floor).size()
	if Rules.glyph_at(Vector2i(6, 4), floor) != "+" or Rules.glyph_at(Vector2i(4, 5), floor) != "+":
		return "the garth is not marked on the map"
	if Rules.tile_at(Vector2i(6, 4), floor) != Rules.Tile.WALL or Rules.is_walkable(Vector2i(6, 4), floor):
		return "the garth is not solid wall"
	var walk_err := _cloister_walk(floor)
	if walk_err != "":
		return walk_err
	var swings: Array = Rules.swing_tiles(floor)
	if swings.size() != 2 or swings[0] == swings[1]:
		return "the warden should telegraph two distinct tiles"
	for swing in swings:
		if not Rules.is_walkable(swing, floor):
			return "swing tile %s is not walkable" % swing
	if Rules.is_walkable(Rules.enemy_pos(floor), floor):
		return "the warden's own tile is walkable"
	var steps := Rules.shortest_path_steps(floor)
	if steps != 19:
		return "shortest cloister path is %d, expected 19" % steps
	if Rules.SMALL_FLASK_OIL - steps < 4:
		return "small flask margin slipped to %d" % (Rules.SMALL_FLASK_OIL - steps)
	var actions: Array = Rules.scripted_safe_actions(floor)
	if actions.is_empty():
		return "no safe exit from the cloister"
	var state = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	for i in actions.size():
		var result: Dictionary = Rules.step(state, actions[i])
		if bool(result.hit):
			return "hit on cloister exit action %d at %s" % [i, state.pos]
		if state.end_reason != Rules.EndReason.NONE and i != actions.size() - 1:
			return "cloister exit ended early at action %d" % i
		if actions[i] != Vector2i.ZERO and not bool(result.moved):
			return "cloister exit step %d did not move" % i
	if state.end_reason != Rules.EndReason.EXTRACTED or state.pos != Rules.lift_pos(floor):
		return "cloister exit was not an extract at the lift"
	if state.oil != Rules.SMALL_FLASK_OIL - actions.size():
		return "cloister exit oil %d after %d actions" % [state.oil, actions.size()]
	var full: int = int(Rules.payout(Rules.accurate_sheet(floor), floor).total)
	var carried: int = int(Rules.payout(state.marks, floor).total)
	if carried <= 0 or carried >= full:
		return "exit sheet paid %d against full %d" % [carried, full]
	if Rules.census_accepted(state.marks, floor):
		return "the exit path was accepted as a finished census"
	var cover := Rules.safe_survey_steps(floor)
	if cover != 88:
		return "safe survey is %d, expected 88" % cover
	if cover > Rules.LARGE_FLASK_OIL or cover <= Rules.SMALL_FLASK_OIL:
		return "survey oil %d does not sit between the flasks" % cover
	print("  cloister shortest %d  survey %d  exit pay %d  full %d" % [steps, cover, carried, full])
	return ""


func _cloister_walk(floor) -> String:
	var cells: Array = Rules.loop_cells(floor)
	if cells.size() != 18:
		return "walk size %d" % cells.size()
	var have := {}
	for cell in cells:
		if have.has(cell):
			return "duplicate walk tile %s" % cell
		have[cell] = true
		if not Rules.is_corridor_cell(cell, floor):
			return "walk tile %s is not a corridor" % cell
	for cell in cells:
		var degree := 0
		for dir in Rules.cardinals():
			if have.has(cell + dir):
				degree += 1
		if degree != 2:
			return "walk tile %s has %d neighbors in the walk" % [cell, degree]
	if not have.has(Vector2i(6, 3)) or have.has(Vector2i(6, 4)):
		return "the walk does not rim the garth"
	var garth := 0
	for y in Rules.height(floor):
		for x in Rules.width(floor):
			var p := Vector2i(x, y)
			if Rules.glyph_at(p, floor) != "+":
				continue
			garth += 1
			for dir in Rules.cardinals():
				var n: Vector2i = p + dir
				if Rules.is_corridor_cell(n, floor) and not have.has(n):
					return "corridor %s touches the garth and is outside the walk" % n
	if garth != 10:
		return "garth size %d" % garth
	if str(floor.loop_name) != "Cloister walk":
		return "walk name is %s" % floor.loop_name
	return ""


func _cloister_census() -> String:
	var floor = Rules.floor_named("cloister")
	var cellar = Rules.floor_named("cellar")
	var cistern = Rules.floor_named("cistern")
	var truth: Dictionary = Rules.accurate_sheet(floor)
	if not Rules.census_accepted(truth, floor):
		return "the true cloister census was rejected"
	var bill: Dictionary = Rules.payout(truth, floor)
	if int(bill.corridors) != 65 or int(bill.hazards) != 4 or int(bill.loop) != 1:
		return "true counts %s/%s loop %s" % [bill.corridors, bill.hazards, bill.loop]
	if int(bill.corridor_pay) != 65 * Rules.CORRIDOR_VALUE:
		return "corridor pay drifted"
	if int(bill.hazard_pay) != 4 * Rules.HAZARD_VALUE:
		return "hazard pay drifted"
	if int(bill.loop_pay) != Rules.LOOP_VALUE:
		return "walk pay drifted"
	if int(bill.total) != 242:
		return "true total %s" % bill.total
	if Rules.format_bill(bill).find("Cloister walk") < 0:
		return "the receipt did not name the cloister walk"
	if Rules.census_accepted({}, floor):
		return "an empty sheet was accepted"
	if int(Rules.payout({}, floor).total) != 0:
		return "an empty sheet paid out"
	var missing_corridor: Dictionary = truth.duplicate()
	missing_corridor.erase(Rules.start_pos(floor))
	if Rules.census_accepted(missing_corridor, floor):
		return "a sheet missing the start corridor was accepted"
	var missing_bill: Dictionary = Rules.payout(missing_corridor, floor)
	if int(missing_bill.total) >= 242 or int(missing_bill.loop) != 1:
		return "dropping a corridor outside the walk changed the census the wrong way"
	var cinder: Vector2i = Rules.hazard_cells(floor)[0]
	var missing_cinder: Dictionary = truth.duplicate()
	missing_cinder.erase(cinder)
	if Rules.census_accepted(missing_cinder, floor):
		return "a sheet missing a cinder was accepted"
	if int(Rules.payout(missing_cinder, floor).total) >= 242:
		return "dropping a cinder did not lower pay"
	var broken_walk: Dictionary = truth.duplicate()
	var rim: Vector2i = Rules.loop_cells(floor)[0]
	broken_walk[rim] = Rules.Mark.WALL
	if Rules.census_accepted(broken_walk, floor):
		return "a broken walk was accepted"
	var broken_bill: Dictionary = Rules.payout(broken_walk, floor)
	if int(broken_bill.loop) != 0 or int(broken_bill.total) >= 242:
		return "a broken walk still paid as a finished sheet"
	var swapped: Dictionary = truth.duplicate()
	swapped[cinder] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(swapped, floor):
		return "a cinder marked as a corridor was accepted"
	if int(Rules.payout(swapped, floor).hazard_pay) >= int(bill.hazard_pay):
		return "mislabeling a cinder did not lower hazard pay"
	if int(Rules.payout(swapped, floor).total) > 242:
		return "mislabeling a cinder raised the payout"
	var corridor: Vector2i = Rules.lift_pos(floor)
	var swapped_corridor: Dictionary = truth.duplicate()
	swapped_corridor[corridor] = Rules.Mark.HAZARD
	if Rules.census_accepted(swapped_corridor, floor):
		return "the lift marked as a hazard was accepted"
	if int(Rules.payout(swapped_corridor, floor).total) > 242:
		return "marking the lift as a hazard raised the payout"
	var false_wall: Dictionary = truth.duplicate()
	false_wall[Vector2i(0, 0)] = Rules.Mark.HAZARD
	if Rules.census_accepted(false_wall, floor):
		return "a hazard mark on a wall was accepted"
	if int(Rules.payout(false_wall, floor).total) != 242 or int(Rules.payout(false_wall, floor).hazard_pay) != int(bill.hazard_pay):
		return "a hazard mark on a wall changed the payout"
	var garth_wall: Dictionary = truth.duplicate()
	garth_wall[Vector2i(4, 4)] = Rules.Mark.WALL
	if not Rules.census_accepted(garth_wall, floor):
		return "inking the garth as a wall rejected a true census"
	garth_wall[Vector2i(4, 4)] = Rules.Mark.HAZARD
	if Rules.census_accepted(garth_wall, floor):
		return "calling the garth a hazard was accepted"
	var warden_mark: Dictionary = truth.duplicate()
	warden_mark[Rules.enemy_pos(floor)] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(warden_mark, floor):
		return "the warden tile was accepted as a corridor"
	if int(Rules.payout(warden_mark, floor).total) != 242:
		return "marking the warden changed the payout"
	var only_walk := {}
	for cell in Rules.loop_cells(floor):
		only_walk[cell] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(only_walk, floor):
		return "the walk alone was accepted as the census"
	var walk_bill: Dictionary = Rules.payout(only_walk, floor)
	if int(walk_bill.loop) != 1 or int(walk_bill.hazards) != 0 or int(walk_bill.total) >= 242:
		return "the walk bonus did not stay inside the shared payout rule"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cellar):
		return "the cloister sheet was accepted as the cellar"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cistern):
		return "the cloister sheet was accepted as the cistern"
	if Rules.census_accepted(Rules.accurate_sheet(cellar), floor):
		return "the cellar sheet was accepted as the cloister"
	if Rules.census_accepted(Rules.accurate_sheet(cistern), floor):
		return "the cistern sheet was accepted as the cloister"
	if not Rules.census_accepted(Rules.accurate_sheet(cellar), cellar):
		return "the cellar's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(cistern), cistern):
		return "the cistern's true census was rejected"
	var cellar_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cellar), cellar)
	if int(cellar_bill.total) != 211 or str(cellar_bill.loop_name) != "East square":
		return "the cellar payout changed"
	var cistern_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cistern), cistern)
	if int(cistern_bill.total) != 288 or str(cistern_bill.loop_name) != "Cistern ring":
		return "the cistern payout changed"
	var approach: Vector2i = Rules.walkable_approach(cinder, floor)
	if approach.x < 0:
		return "cinder has no approach"
	var walker = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	walker.pos = approach
	walker.oil = 10
	var before: int = walker.oil
	var stepped: Dictionary = Rules.step(walker, cinder - approach)
	if bool(stepped.hit):
		return "opening cinder step was a swing"
	if walker.oil != before - Rules.MOVE_OIL:
		return "cinder burned extra oil"
	if int(walker.marks.get(cinder, Rules.Mark.NONE)) != Rules.Mark.HAZARD:
		return "cinder was not inked as a hazard"
	return ""


func _cloister_return() -> String:
	var game_script = load("res://scripts/game.gd")
	var select_script = load("res://scripts/floor_select_view.gd")
	if game_script == null or select_script == null:
		return "game or floor select did not load"
	var game = game_script.new()
	root.add_child(game)
	if game.town == null or game.floor_select == null or game.descent == null:
		game.free()
		return "the game did not build its screens"
	if game.floor_select.record_for("cloister") != Rules.CLOISTER_RECORD:
		game.free()
		return "floor select does not offer the cloister census"
	if game.floor_select.record_for("cellar") != Rules.CELLAR_RECORD:
		game.free()
		return "floor select dropped the cellar census"
	if game.floor_select.record_for("cistern") != Rules.CISTERN_RECORD:
		game.free()
		return "floor select dropped the cistern census"
	if game.floor_select.status_for("cloister") != "Census open":
		game.free()
		return "the cloister card did not open"
	game._on_descend_floor("cloister")
	if game.descent.state == null or game.descent.state.floor.id != "cloister":
		game.free()
		return "descend did not open the cloister"
	var state = game.descent.state
	var lift: Vector2i = Rules.lift_pos(state.floor)
	var approach: Vector2i = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var left: Dictionary = Rules.step(state, lift - approach)
	if not bool(left.extracted):
		game.free()
		return "short cloister sheet did not leave on the lift"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to town":
		game.free()
		return "a short sheet offered the floor select"
	game._on_return(state)
	if not game.town.visible or game.floor_select.visible or game.descent.visible:
		game.free()
		return "a short census did not return to town"
	if bool(game.campaign.completed.get("cloister", false)):
		game.free()
		return "a short census was accepted"
	if game.town.outcome_label.text.find("not finished") < 0:
		game.free()
		return "the clerk treated a short sheet as finished"
	game._on_floors()
	if not game.floor_select.visible or game.town.visible:
		game.free()
		return "floor select did not open from town"
	game._on_descend_floor("cloister")
	state = game.descent.state
	state.marks = Rules.accurate_sheet(state.floor)
	lift = Rules.lift_pos(state.floor)
	approach = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var done: Dictionary = Rules.step(state, lift - approach)
	if not bool(done.extracted) or not Rules.census_accepted(state.marks, state.floor):
		game.free()
		return "the finished sheet did not extract as an accepted census"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to floor select":
		game.free()
		return "a finished census did not offer the floor select"
	game._on_return(state)
	if not game.floor_select.visible or game.town.visible or game.descent.visible:
		game.free()
		return "a finished census did not return to the floor select"
	if not bool(game.campaign.completed.get("cloister", false)):
		game.free()
		return "the finished census was not recorded"
	if bool(game.campaign.completed.get("cellar", false)) or bool(game.campaign.completed.get("cistern", false)):
		game.free()
		return "another floor was marked complete"
	if game.floor_select.status_for("cloister") != "Census complete":
		game.free()
		return "floor select did not show the cloister census complete"
	if game.floor_select.status_for("cellar") != "Census open" or game.floor_select.status_for("cistern") != "Census open":
		game.free()
		return "another floor card was closed"
	if game.floor_select.notice_label.text.find("complete") < 0:
		game.free()
		return "arrival did not say the census is complete"
	if game.campaign.purse < 242 or game.campaign.last_outcome != "complete":
		game.free()
		return "the finished census was not paid"
	game._show_town()
	if not game.town.visible or game.floor_select.visible:
		game.free()
		return "Back to town did not leave the floor select"
	if game.town.outcome_label.text.find("complete") < 0:
		game.free()
		return "town clerk did not keep the finished census"
	game.free()
	return ""


func _crypt_layout() -> String:
	if Rules.CORRIDOR_VALUE != 3 or Rules.HAZARD_VALUE != 8 or Rules.LOOP_VALUE != 15:
		return "payout rates changed"
	if Rules.MOVE_OIL != 1 or Rules.HIT_OIL != 3:
		return "oil costs changed"
	if Rules.SMALL_FLASK_OIL != 24 or Rules.LARGE_FLASK_OIL != 120 or Rules.LARGE_FLASK_COST != 40:
		return "flask sizes changed"
	var floor = Rules.floor_named("crypt")
	if floor == null:
		return "crypt floor is missing"
	if floor.record != Rules.CRYPT_RECORD:
		return "crypt record drifted from its constant"
	if Rules.CRYPT_RECORD != "Record every corridor, the five ash cracks, and the crypt ring around the tomb.":
		return "the crypt no longer asks for the ash and the ring"
	var expected := PackedStringArray([
		"###############",
		"#S............#",
		"#.............#",
		"#.#.====..#...#",
		"#.#.====..#...#",
		"#.#.====..#...#",
		"#.#.====..#...#",
		"#.............#",
		"#............L#",
		"#H.H.H..E..H.H#",
		"###############",
	])
	if floor.rows.size() != expected.size():
		return "crypt height %d" % floor.rows.size()
	for i in expected.size():
		if str(floor.rows[i]) != str(expected[i]):
			return "crypt row %d is %s" % [i, floor.rows[i]]
	if Rules.width(floor) != 15 or Rules.height(floor) != 11:
		return "crypt size %dx%d" % [Rules.width(floor), Rules.height(floor)]
	if Rules.start_pos(floor) != Vector2i(1, 1):
		return "start %s" % Rules.start_pos(floor)
	if Rules.lift_pos(floor) != Vector2i(13, 8):
		return "lift %s" % Rules.lift_pos(floor)
	if Rules.enemy_pos(floor) != Vector2i(8, 9):
		return "warden %s" % Rules.enemy_pos(floor)
	var hazards: Array = Rules.hazard_cells(floor)
	var expect_h: Array = [Vector2i(1, 9), Vector2i(3, 9), Vector2i(5, 9), Vector2i(11, 9), Vector2i(13, 9)]
	if hazards.size() != expect_h.size():
		return "hazard count %d" % hazards.size()
	for i in hazards.size():
		if hazards[i] != expect_h[i]:
			return "hazard %d is %s" % [i, hazards[i]]
	if Rules.corridor_cells(floor).size() != 87:
		return "corridors %d" % Rules.corridor_cells(floor).size()
	if Rules.glyph_at(Vector2i(5, 4), floor) != "=" or Rules.glyph_at(Vector2i(4, 6), floor) != "=":
		return "the tomb is not marked on the map"
	if Rules.tile_at(Vector2i(5, 4), floor) != Rules.Tile.WALL or Rules.is_walkable(Vector2i(5, 4), floor):
		return "the tomb is not solid wall"
	var ring_err := _crypt_ring(floor)
	if ring_err != "":
		return ring_err
	var swings: Array = Rules.swing_tiles(floor)
	if swings.size() != 2 or swings[0] == swings[1]:
		return "the warden should telegraph two distinct tiles"
	for swing in swings:
		if not Rules.is_walkable(swing, floor):
			return "swing tile %s is not walkable" % swing
	if Rules.is_walkable(Rules.enemy_pos(floor), floor):
		return "the warden's own tile is walkable"
	var steps := Rules.shortest_path_steps(floor)
	if steps != 19:
		return "shortest crypt path is %d, expected 19" % steps
	if Rules.SMALL_FLASK_OIL - steps < 4:
		return "small flask margin slipped to %d" % (Rules.SMALL_FLASK_OIL - steps)
	var actions: Array = Rules.scripted_safe_actions(floor)
	if actions.is_empty():
		return "no safe exit from the crypt"
	var state = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	for i in actions.size():
		var result: Dictionary = Rules.step(state, actions[i])
		if bool(result.hit):
			return "hit on crypt exit action %d at %s" % [i, state.pos]
		if state.end_reason != Rules.EndReason.NONE and i != actions.size() - 1:
			return "crypt exit ended early at action %d" % i
		if actions[i] != Vector2i.ZERO and not bool(result.moved):
			return "crypt exit step %d did not move" % i
	if state.end_reason != Rules.EndReason.EXTRACTED or state.pos != Rules.lift_pos(floor):
		return "crypt exit was not an extract at the lift"
	if state.oil != Rules.SMALL_FLASK_OIL - actions.size():
		return "crypt exit oil %d after %d actions" % [state.oil, actions.size()]
	var full: int = int(Rules.payout(Rules.accurate_sheet(floor), floor).total)
	var carried: int = int(Rules.payout(state.marks, floor).total)
	if carried <= 0 or carried >= full:
		return "exit sheet paid %d against full %d" % [carried, full]
	if Rules.census_accepted(state.marks, floor):
		return "the exit path was accepted as a finished census"
	var cover := Rules.safe_survey_steps(floor)
	if cover != 112:
		return "safe survey is %d, expected 112" % cover
	if cover > Rules.LARGE_FLASK_OIL or cover <= Rules.SMALL_FLASK_OIL:
		return "survey oil %d does not sit between the flasks" % cover
	print("  crypt shortest %d  survey %d  exit pay %d  full %d" % [steps, cover, carried, full])
	return ""


func _crypt_ring(floor) -> String:
	var cells: Array = Rules.loop_cells(floor)
	if cells.size() != 20:
		return "ring size %d" % cells.size()
	var have := {}
	for cell in cells:
		if have.has(cell):
			return "duplicate ring tile %s" % cell
		have[cell] = true
		if not Rules.is_corridor_cell(cell, floor):
			return "ring tile %s is not a corridor" % cell
	for cell in cells:
		var degree := 0
		for dir in Rules.cardinals():
			if have.has(cell + dir):
				degree += 1
		if degree != 2:
			return "ring tile %s has %d neighbors in the ring" % [cell, degree]
	if not have.has(Vector2i(6, 2)) or have.has(Vector2i(6, 3)):
		return "the ring does not rim the tomb"
	var tombs := 0
	for y in Rules.height(floor):
		for x in Rules.width(floor):
			var p := Vector2i(x, y)
			if Rules.glyph_at(p, floor) != "=":
				continue
			tombs += 1
			for dir in Rules.cardinals():
				var n: Vector2i = p + dir
				if Rules.is_corridor_cell(n, floor) and not have.has(n):
					return "corridor %s touches the tomb and is outside the ring" % n
	if tombs != 16:
		return "tomb size %d" % tombs
	if str(floor.loop_name) != "Crypt ring":
		return "ring name is %s" % floor.loop_name
	return ""


func _crypt_census() -> String:
	var floor = Rules.floor_named("crypt")
	var cellar = Rules.floor_named("cellar")
	var cistern = Rules.floor_named("cistern")
	var cloister = Rules.floor_named("cloister")
	var truth: Dictionary = Rules.accurate_sheet(floor)
	if not Rules.census_accepted(truth, floor):
		return "the true crypt census was rejected"
	var bill: Dictionary = Rules.payout(truth, floor)
	if int(bill.corridors) != 87 or int(bill.hazards) != 5 or int(bill.loop) != 1:
		return "true counts %s/%s loop %s" % [bill.corridors, bill.hazards, bill.loop]
	if int(bill.corridor_pay) != 87 * Rules.CORRIDOR_VALUE:
		return "corridor pay drifted"
	if int(bill.hazard_pay) != 5 * Rules.HAZARD_VALUE:
		return "hazard pay drifted"
	if int(bill.loop_pay) != Rules.LOOP_VALUE:
		return "ring pay drifted"
	if int(bill.total) != 316:
		return "true total %s" % bill.total
	if Rules.format_bill(bill).find("Crypt ring") < 0:
		return "the receipt did not name the crypt ring"
	if Rules.census_accepted({}, floor):
		return "an empty sheet was accepted"
	if int(Rules.payout({}, floor).total) != 0:
		return "an empty sheet paid out"
	var missing_corridor: Dictionary = truth.duplicate()
	missing_corridor.erase(Rules.start_pos(floor))
	if Rules.census_accepted(missing_corridor, floor):
		return "a sheet missing the start corridor was accepted"
	var missing_bill: Dictionary = Rules.payout(missing_corridor, floor)
	if int(missing_bill.total) >= 316 or int(missing_bill.loop) != 1:
		return "dropping a corridor outside the ring changed the census the wrong way"
	var ash: Vector2i = Rules.hazard_cells(floor)[0]
	var missing_ash: Dictionary = truth.duplicate()
	missing_ash.erase(ash)
	if Rules.census_accepted(missing_ash, floor):
		return "a sheet missing an ash crack was accepted"
	if int(Rules.payout(missing_ash, floor).total) >= 316:
		return "dropping an ash crack did not lower pay"
	var broken_ring: Dictionary = truth.duplicate()
	var rim: Vector2i = Rules.loop_cells(floor)[0]
	broken_ring[rim] = Rules.Mark.WALL
	if Rules.census_accepted(broken_ring, floor):
		return "a broken ring was accepted"
	var broken_bill: Dictionary = Rules.payout(broken_ring, floor)
	if int(broken_bill.loop) != 0 or int(broken_bill.total) >= 316:
		return "a broken ring still paid as a finished sheet"
	var swapped: Dictionary = truth.duplicate()
	swapped[ash] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(swapped, floor):
		return "an ash crack marked as a corridor was accepted"
	if int(Rules.payout(swapped, floor).hazard_pay) >= int(bill.hazard_pay):
		return "mislabeling an ash crack did not lower hazard pay"
	if int(Rules.payout(swapped, floor).total) > 316:
		return "mislabeling an ash crack raised the payout"
	var corridor: Vector2i = Rules.lift_pos(floor)
	var swapped_corridor: Dictionary = truth.duplicate()
	swapped_corridor[corridor] = Rules.Mark.HAZARD
	if Rules.census_accepted(swapped_corridor, floor):
		return "the lift marked as a hazard was accepted"
	if int(Rules.payout(swapped_corridor, floor).total) > 316:
		return "marking the lift as a hazard raised the payout"
	var false_wall: Dictionary = truth.duplicate()
	false_wall[Vector2i(0, 0)] = Rules.Mark.HAZARD
	if Rules.census_accepted(false_wall, floor):
		return "a hazard mark on a wall was accepted"
	if int(Rules.payout(false_wall, floor).total) != 316 or int(Rules.payout(false_wall, floor).hazard_pay) != int(bill.hazard_pay):
		return "a hazard mark on a wall changed the payout"
	var tomb_wall: Dictionary = truth.duplicate()
	tomb_wall[Vector2i(4, 3)] = Rules.Mark.WALL
	if not Rules.census_accepted(tomb_wall, floor):
		return "inking the tomb as a wall rejected a true census"
	tomb_wall[Vector2i(4, 3)] = Rules.Mark.HAZARD
	if Rules.census_accepted(tomb_wall, floor):
		return "calling the tomb a hazard was accepted"
	var warden_mark: Dictionary = truth.duplicate()
	warden_mark[Rules.enemy_pos(floor)] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(warden_mark, floor):
		return "the warden tile was accepted as a corridor"
	if int(Rules.payout(warden_mark, floor).total) != 316:
		return "marking the warden changed the payout"
	var only_ring := {}
	for cell in Rules.loop_cells(floor):
		only_ring[cell] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(only_ring, floor):
		return "the ring alone was accepted as the census"
	var ring_bill: Dictionary = Rules.payout(only_ring, floor)
	if int(ring_bill.loop) != 1 or int(ring_bill.hazards) != 0 or int(ring_bill.total) >= 316:
		return "the ring bonus did not stay inside the shared payout rule"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cellar):
		return "the crypt sheet was accepted as the cellar"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cistern):
		return "the crypt sheet was accepted as the cistern"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cloister):
		return "the crypt sheet was accepted as the cloister"
	if Rules.census_accepted(Rules.accurate_sheet(cellar), floor):
		return "the cellar sheet was accepted as the crypt"
	if Rules.census_accepted(Rules.accurate_sheet(cistern), floor):
		return "the cistern sheet was accepted as the crypt"
	if Rules.census_accepted(Rules.accurate_sheet(cloister), floor):
		return "the cloister sheet was accepted as the crypt"
	if not Rules.census_accepted(Rules.accurate_sheet(cellar), cellar):
		return "the cellar's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(cistern), cistern):
		return "the cistern's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(cloister), cloister):
		return "the cloister's true census was rejected"
	var cellar_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cellar), cellar)
	if int(cellar_bill.total) != 211 or str(cellar_bill.loop_name) != "East square":
		return "the cellar payout changed"
	var cistern_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cistern), cistern)
	if int(cistern_bill.total) != 288 or str(cistern_bill.loop_name) != "Cistern ring":
		return "the cistern payout changed"
	var cloister_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cloister), cloister)
	if int(cloister_bill.total) != 242 or str(cloister_bill.loop_name) != "Cloister walk":
		return "the cloister payout changed"
	var approach: Vector2i = Rules.walkable_approach(ash, floor)
	if approach.x < 0:
		return "ash crack has no approach"
	var walker = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	walker.pos = approach
	walker.oil = 10
	var before: int = walker.oil
	var stepped: Dictionary = Rules.step(walker, ash - approach)
	if bool(stepped.hit):
		return "opening ash step was a swing"
	if walker.oil != before - Rules.MOVE_OIL:
		return "ash burned extra oil"
	if int(walker.marks.get(ash, Rules.Mark.NONE)) != Rules.Mark.HAZARD:
		return "ash was not inked as a hazard"
	return ""


func _crypt_return() -> String:
	var game_script = load("res://scripts/game.gd")
	var select_script = load("res://scripts/floor_select_view.gd")
	if game_script == null or select_script == null:
		return "game or floor select did not load"
	var game = game_script.new()
	root.add_child(game)
	if game.town == null or game.floor_select == null or game.descent == null:
		game.free()
		return "the game did not build its screens"
	if game.floor_select.record_for("crypt") != Rules.CRYPT_RECORD:
		game.free()
		return "floor select does not offer the crypt census"
	if game.floor_select.record_for("cellar") != Rules.CELLAR_RECORD:
		game.free()
		return "floor select dropped the cellar census"
	if game.floor_select.record_for("cistern") != Rules.CISTERN_RECORD:
		game.free()
		return "floor select dropped the cistern census"
	if game.floor_select.record_for("cloister") != Rules.CLOISTER_RECORD:
		game.free()
		return "floor select dropped the cloister census"
	if game.floor_select.status_for("crypt") != "Census open":
		game.free()
		return "the crypt card did not open"
	game._on_descend_floor("crypt")
	if game.descent.state == null or game.descent.state.floor.id != "crypt":
		game.free()
		return "descend did not open the crypt"
	var state = game.descent.state
	var lift: Vector2i = Rules.lift_pos(state.floor)
	var approach: Vector2i = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var left: Dictionary = Rules.step(state, lift - approach)
	if not bool(left.extracted):
		game.free()
		return "short crypt sheet did not leave on the lift"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to town":
		game.free()
		return "a short sheet offered the floor select"
	game._on_return(state)
	if not game.town.visible or game.floor_select.visible or game.descent.visible:
		game.free()
		return "a short census did not return to town"
	if bool(game.campaign.completed.get("crypt", false)):
		game.free()
		return "a short census was accepted"
	if game.town.outcome_label.text.find("not finished") < 0:
		game.free()
		return "the clerk treated a short sheet as finished"
	game._on_floors()
	if not game.floor_select.visible or game.town.visible:
		game.free()
		return "floor select did not open from town"
	game._on_descend_floor("crypt")
	state = game.descent.state
	state.marks = Rules.accurate_sheet(state.floor)
	lift = Rules.lift_pos(state.floor)
	approach = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var done: Dictionary = Rules.step(state, lift - approach)
	if not bool(done.extracted) or not Rules.census_accepted(state.marks, state.floor):
		game.free()
		return "the finished sheet did not extract as an accepted census"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to floor select":
		game.free()
		return "a finished census did not offer the floor select"
	game._on_return(state)
	if not game.floor_select.visible or game.town.visible or game.descent.visible:
		game.free()
		return "a finished census did not return to the floor select"
	if not bool(game.campaign.completed.get("crypt", false)):
		game.free()
		return "the finished census was not recorded"
	if bool(game.campaign.completed.get("cellar", false)) or bool(game.campaign.completed.get("cistern", false)) or bool(game.campaign.completed.get("cloister", false)):
		game.free()
		return "another floor was marked complete"
	if game.floor_select.status_for("crypt") != "Census complete":
		game.free()
		return "floor select did not show the crypt census complete"
	if game.floor_select.status_for("cellar") != "Census open" or game.floor_select.status_for("cistern") != "Census open" or game.floor_select.status_for("cloister") != "Census open":
		game.free()
		return "another floor card was closed"
	if game.floor_select.notice_label.text.find("complete") < 0:
		game.free()
		return "arrival did not say the census is complete"
	if game.campaign.purse < 316 or game.campaign.last_outcome != "complete":
		game.free()
		return "the finished census was not paid"
	game._show_town()
	if not game.town.visible or game.floor_select.visible:
		game.free()
		return "Back to town did not leave the floor select"
	if game.town.outcome_label.text.find("complete") < 0:
		game.free()
		return "town clerk did not keep the finished census"
	game.free()
	return ""


func _ossuary_layout() -> String:
	if Rules.CORRIDOR_VALUE != 3 or Rules.HAZARD_VALUE != 8 or Rules.LOOP_VALUE != 15:
		return "payout rates changed"
	if Rules.MOVE_OIL != 1 or Rules.HIT_OIL != 3:
		return "oil costs changed"
	if Rules.SMALL_FLASK_OIL != 24 or Rules.LARGE_FLASK_OIL != 120 or Rules.LARGE_FLASK_COST != 40:
		return "flask sizes changed"
	var floor = Rules.floor_named("ossuary")
	if floor == null:
		return "ossuary floor is missing"
	if floor.record != Rules.OSSUARY_RECORD:
		return "ossuary record drifted from its constant"
	if Rules.OSSUARY_RECORD != "Record every corridor, the six chalk cracks, and the ossuary ring around the stack.":
		return "the ossuary no longer asks for the chalk and the ring"
	var expected := PackedStringArray([
		"#################",
		"#S..............#",
		"###........####.#",
		"###.xxxxxx.####.#",
		"###.xxxxxx.####.#",
		"###.xxxxxx.####.#",
		"###........####L#",
		"###........####.#",
		"#H.H.H..E..H.H.H#",
		"#################",
	])
	if floor.rows.size() != expected.size():
		return "ossuary height %d" % floor.rows.size()
	for i in expected.size():
		if str(floor.rows[i]) != str(expected[i]):
			return "ossuary row %d is %s" % [i, floor.rows[i]]
	if Rules.width(floor) != 17 or Rules.height(floor) != 10:
		return "ossuary size %dx%d" % [Rules.width(floor), Rules.height(floor)]
	if Rules.start_pos(floor) != Vector2i(1, 1):
		return "start %s" % Rules.start_pos(floor)
	if Rules.lift_pos(floor) != Vector2i(15, 6):
		return "lift %s" % Rules.lift_pos(floor)
	if Rules.enemy_pos(floor) != Vector2i(8, 8):
		return "warden %s" % Rules.enemy_pos(floor)
	var hazards: Array = Rules.hazard_cells(floor)
	var expect_h: Array = [Vector2i(1, 8), Vector2i(3, 8), Vector2i(5, 8), Vector2i(11, 8), Vector2i(13, 8), Vector2i(15, 8)]
	if hazards.size() != expect_h.size():
		return "hazard count %d" % hazards.size()
	for i in hazards.size():
		if hazards[i] != expect_h[i]:
			return "hazard %d is %s" % [i, hazards[i]]
	if Rules.corridor_cells(floor).size() != 59:
		return "corridors %d" % Rules.corridor_cells(floor).size()
	if Rules.glyph_at(Vector2i(6, 4), floor) != "x" or Rules.glyph_at(Vector2i(4, 3), floor) != "x":
		return "the stack is not marked on the map"
	if Rules.tile_at(Vector2i(6, 4), floor) != Rules.Tile.WALL or Rules.is_walkable(Vector2i(6, 4), floor):
		return "the stack is not solid wall"
	var ring_err := _ossuary_ring(floor)
	if ring_err != "":
		return ring_err
	var swings: Array = Rules.swing_tiles(floor)
	if swings.size() != 2 or swings[0] == swings[1]:
		return "the warden should telegraph two distinct tiles"
	for swing in swings:
		if not Rules.is_walkable(swing, floor):
			return "swing tile %s is not walkable" % swing
	if Rules.is_walkable(Rules.enemy_pos(floor), floor):
		return "the warden's own tile is walkable"
	var steps := Rules.shortest_path_steps(floor)
	if steps != 19:
		return "shortest ossuary path is %d, expected 19" % steps
	if Rules.SMALL_FLASK_OIL - steps < 4:
		return "small flask margin slipped to %d" % (Rules.SMALL_FLASK_OIL - steps)
	var actions: Array = Rules.scripted_safe_actions(floor)
	if actions.is_empty():
		return "no safe exit from the ossuary"
	var state = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	for i in actions.size():
		var result: Dictionary = Rules.step(state, actions[i])
		if bool(result.hit):
			return "hit on ossuary exit action %d at %s" % [i, state.pos]
		if state.end_reason != Rules.EndReason.NONE and i != actions.size() - 1:
			return "ossuary exit ended early at action %d" % i
		if actions[i] != Vector2i.ZERO and not bool(result.moved):
			return "ossuary exit step %d did not move" % i
	if state.end_reason != Rules.EndReason.EXTRACTED or state.pos != Rules.lift_pos(floor):
		return "ossuary exit was not an extract at the lift"
	if state.oil != Rules.SMALL_FLASK_OIL - actions.size():
		return "ossuary exit oil %d after %d actions" % [state.oil, actions.size()]
	var full: int = int(Rules.payout(Rules.accurate_sheet(floor), floor).total)
	var carried: int = int(Rules.payout(state.marks, floor).total)
	if carried <= 0 or carried >= full:
		return "exit sheet paid %d against full %d" % [carried, full]
	if Rules.census_accepted(state.marks, floor):
		return "the exit path was accepted as a finished census"
	var cover := Rules.safe_survey_steps(floor)
	if cover != 82:
		return "safe survey is %d, expected 82" % cover
	if cover > Rules.LARGE_FLASK_OIL or cover <= Rules.SMALL_FLASK_OIL:
		return "survey oil %d does not sit between the flasks" % cover
	print("  ossuary shortest %d  survey %d  exit pay %d  full %d" % [steps, cover, carried, full])
	return ""


func _ossuary_ring(floor) -> String:
	var cells: Array = Rules.loop_cells(floor)
	if cells.size() != 22:
		return "ring size %d" % cells.size()
	var have := {}
	for cell in cells:
		if have.has(cell):
			return "duplicate ring tile %s" % cell
		have[cell] = true
		if not Rules.is_corridor_cell(cell, floor):
			return "ring tile %s is not a corridor" % cell
	for cell in cells:
		var degree := 0
		for dir in Rules.cardinals():
			if have.has(cell + dir):
				degree += 1
		if degree != 2:
			return "ring tile %s has %d neighbors in the ring" % [cell, degree]
	if not have.has(Vector2i(6, 2)) or have.has(Vector2i(6, 3)):
		return "the ring does not rim the stack"
	var stacks := 0
	for y in Rules.height(floor):
		for x in Rules.width(floor):
			var p := Vector2i(x, y)
			if Rules.glyph_at(p, floor) != "x":
				continue
			stacks += 1
			for dir in Rules.cardinals():
				var n: Vector2i = p + dir
				if Rules.is_corridor_cell(n, floor) and not have.has(n):
					return "corridor %s touches the stack and is outside the ring" % n
	if stacks != 18:
		return "stack size %d" % stacks
	if str(floor.loop_name) != "Ossuary ring":
		return "ring name is %s" % floor.loop_name
	return ""


func _ossuary_census() -> String:
	var floor = Rules.floor_named("ossuary")
	var cellar = Rules.floor_named("cellar")
	var cistern = Rules.floor_named("cistern")
	var cloister = Rules.floor_named("cloister")
	var crypt = Rules.floor_named("crypt")
	var truth: Dictionary = Rules.accurate_sheet(floor)
	if not Rules.census_accepted(truth, floor):
		return "the true ossuary census was rejected"
	var bill: Dictionary = Rules.payout(truth, floor)
	if int(bill.corridors) != 59 or int(bill.hazards) != 6 or int(bill.loop) != 1:
		return "true counts %s/%s loop %s" % [bill.corridors, bill.hazards, bill.loop]
	if int(bill.corridor_pay) != 59 * Rules.CORRIDOR_VALUE:
		return "corridor pay drifted"
	if int(bill.hazard_pay) != 6 * Rules.HAZARD_VALUE:
		return "hazard pay drifted"
	if int(bill.loop_pay) != Rules.LOOP_VALUE:
		return "ring pay drifted"
	if int(bill.total) != 240:
		return "true total %s" % bill.total
	if Rules.format_bill(bill).find("Ossuary ring") < 0:
		return "the receipt did not name the ossuary ring"
	if Rules.census_accepted({}, floor):
		return "an empty sheet was accepted"
	if int(Rules.payout({}, floor).total) != 0:
		return "an empty sheet paid out"
	var missing_corridor: Dictionary = truth.duplicate()
	missing_corridor.erase(Rules.start_pos(floor))
	if Rules.census_accepted(missing_corridor, floor):
		return "a sheet missing the start corridor was accepted"
	var missing_bill: Dictionary = Rules.payout(missing_corridor, floor)
	if int(missing_bill.total) >= 240 or int(missing_bill.loop) != 1:
		return "dropping a corridor outside the ring changed the census the wrong way"
	var chalk: Vector2i = Rules.hazard_cells(floor)[0]
	var missing_chalk: Dictionary = truth.duplicate()
	missing_chalk.erase(chalk)
	if Rules.census_accepted(missing_chalk, floor):
		return "a sheet missing a chalk crack was accepted"
	if int(Rules.payout(missing_chalk, floor).total) >= 240:
		return "dropping a chalk crack did not lower pay"
	var broken_ring: Dictionary = truth.duplicate()
	var rim: Vector2i = Rules.loop_cells(floor)[0]
	broken_ring[rim] = Rules.Mark.WALL
	if Rules.census_accepted(broken_ring, floor):
		return "a broken ring was accepted"
	var broken_bill: Dictionary = Rules.payout(broken_ring, floor)
	if int(broken_bill.loop) != 0 or int(broken_bill.total) >= 240:
		return "a broken ring still paid as a finished sheet"
	var swapped: Dictionary = truth.duplicate()
	swapped[chalk] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(swapped, floor):
		return "a chalk crack marked as a corridor was accepted"
	if int(Rules.payout(swapped, floor).hazard_pay) >= int(bill.hazard_pay):
		return "mislabeling a chalk crack did not lower hazard pay"
	if int(Rules.payout(swapped, floor).total) > 240:
		return "mislabeling a chalk crack raised the payout"
	var corridor: Vector2i = Rules.lift_pos(floor)
	var swapped_corridor: Dictionary = truth.duplicate()
	swapped_corridor[corridor] = Rules.Mark.HAZARD
	if Rules.census_accepted(swapped_corridor, floor):
		return "the lift marked as a hazard was accepted"
	if int(Rules.payout(swapped_corridor, floor).total) > 240:
		return "marking the lift as a hazard raised the payout"
	var false_wall: Dictionary = truth.duplicate()
	false_wall[Vector2i(0, 0)] = Rules.Mark.HAZARD
	if Rules.census_accepted(false_wall, floor):
		return "a hazard mark on a wall was accepted"
	if int(Rules.payout(false_wall, floor).total) != 240 or int(Rules.payout(false_wall, floor).hazard_pay) != int(bill.hazard_pay):
		return "a hazard mark on a wall changed the payout"
	var stack_wall: Dictionary = truth.duplicate()
	stack_wall[Vector2i(4, 3)] = Rules.Mark.WALL
	if not Rules.census_accepted(stack_wall, floor):
		return "inking the stack as a wall rejected a true census"
	stack_wall[Vector2i(4, 3)] = Rules.Mark.HAZARD
	if Rules.census_accepted(stack_wall, floor):
		return "calling the stack a hazard was accepted"
	var warden_mark: Dictionary = truth.duplicate()
	warden_mark[Rules.enemy_pos(floor)] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(warden_mark, floor):
		return "the warden tile was accepted as a corridor"
	if int(Rules.payout(warden_mark, floor).total) != 240:
		return "marking the warden changed the payout"
	var only_ring := {}
	for cell in Rules.loop_cells(floor):
		only_ring[cell] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(only_ring, floor):
		return "the ring alone was accepted as the census"
	var ring_bill: Dictionary = Rules.payout(only_ring, floor)
	if int(ring_bill.loop) != 1 or int(ring_bill.hazards) != 0 or int(ring_bill.total) >= 240:
		return "the ring bonus did not stay inside the shared payout rule"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cellar):
		return "the ossuary sheet was accepted as the cellar"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cistern):
		return "the ossuary sheet was accepted as the cistern"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cloister):
		return "the ossuary sheet was accepted as the cloister"
	if Rules.census_accepted(Rules.accurate_sheet(floor), crypt):
		return "the ossuary sheet was accepted as the crypt"
	if Rules.census_accepted(Rules.accurate_sheet(cellar), floor):
		return "the cellar sheet was accepted as the ossuary"
	if Rules.census_accepted(Rules.accurate_sheet(cistern), floor):
		return "the cistern sheet was accepted as the ossuary"
	if Rules.census_accepted(Rules.accurate_sheet(cloister), floor):
		return "the cloister sheet was accepted as the ossuary"
	if Rules.census_accepted(Rules.accurate_sheet(crypt), floor):
		return "the crypt sheet was accepted as the ossuary"
	if not Rules.census_accepted(Rules.accurate_sheet(cellar), cellar):
		return "the cellar's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(cistern), cistern):
		return "the cistern's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(cloister), cloister):
		return "the cloister's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(crypt), crypt):
		return "the crypt's true census was rejected"
	var cellar_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cellar), cellar)
	if int(cellar_bill.total) != 211 or str(cellar_bill.loop_name) != "East square":
		return "the cellar payout changed"
	var cistern_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cistern), cistern)
	if int(cistern_bill.total) != 288 or str(cistern_bill.loop_name) != "Cistern ring":
		return "the cistern payout changed"
	var cloister_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cloister), cloister)
	if int(cloister_bill.total) != 242 or str(cloister_bill.loop_name) != "Cloister walk":
		return "the cloister payout changed"
	var crypt_bill: Dictionary = Rules.payout(Rules.accurate_sheet(crypt), crypt)
	if int(crypt_bill.total) != 316 or str(crypt_bill.loop_name) != "Crypt ring":
		return "the crypt payout changed"
	var approach: Vector2i = Rules.walkable_approach(chalk, floor)
	if approach.x < 0:
		return "chalk crack has no approach"
	var walker = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	walker.pos = approach
	walker.oil = 10
	var before: int = walker.oil
	var stepped: Dictionary = Rules.step(walker, chalk - approach)
	if bool(stepped.hit):
		return "opening chalk step was a swing"
	if walker.oil != before - Rules.MOVE_OIL:
		return "chalk burned extra oil"
	if int(walker.marks.get(chalk, Rules.Mark.NONE)) != Rules.Mark.HAZARD:
		return "chalk was not inked as a hazard"
	return ""


func _ossuary_return() -> String:
	var game_script = load("res://scripts/game.gd")
	var select_script = load("res://scripts/floor_select_view.gd")
	if game_script == null or select_script == null:
		return "game or floor select did not load"
	var game = game_script.new()
	root.add_child(game)
	if game.town == null or game.floor_select == null or game.descent == null:
		game.free()
		return "the game did not build its screens"
	if game.floor_select.record_for("ossuary") != Rules.OSSUARY_RECORD:
		game.free()
		return "floor select does not offer the ossuary census"
	if game.floor_select.record_for("cellar") != Rules.CELLAR_RECORD:
		game.free()
		return "floor select dropped the cellar census"
	if game.floor_select.record_for("cistern") != Rules.CISTERN_RECORD:
		game.free()
		return "floor select dropped the cistern census"
	if game.floor_select.record_for("cloister") != Rules.CLOISTER_RECORD:
		game.free()
		return "floor select dropped the cloister census"
	if game.floor_select.record_for("crypt") != Rules.CRYPT_RECORD:
		game.free()
		return "floor select dropped the crypt census"
	if game.floor_select.status_for("ossuary") != "Census open":
		game.free()
		return "the ossuary card did not open"
	game._on_descend_floor("ossuary")
	if game.descent.state == null or game.descent.state.floor.id != "ossuary":
		game.free()
		return "descend did not open the ossuary"
	var state = game.descent.state
	var lift: Vector2i = Rules.lift_pos(state.floor)
	var approach: Vector2i = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var left: Dictionary = Rules.step(state, lift - approach)
	if not bool(left.extracted):
		game.free()
		return "short ossuary sheet did not leave on the lift"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to town":
		game.free()
		return "a short sheet offered the floor select"
	game._on_return(state)
	if not game.town.visible or game.floor_select.visible or game.descent.visible:
		game.free()
		return "a short census did not return to town"
	if bool(game.campaign.completed.get("ossuary", false)):
		game.free()
		return "a short census was accepted"
	if game.town.outcome_label.text.find("not finished") < 0:
		game.free()
		return "the clerk treated a short sheet as finished"
	game._on_floors()
	if not game.floor_select.visible or game.town.visible:
		game.free()
		return "floor select did not open from town"
	game._on_descend_floor("ossuary")
	state = game.descent.state
	state.marks = Rules.accurate_sheet(state.floor)
	lift = Rules.lift_pos(state.floor)
	approach = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var done: Dictionary = Rules.step(state, lift - approach)
	if not bool(done.extracted) or not Rules.census_accepted(state.marks, state.floor):
		game.free()
		return "the finished sheet did not extract as an accepted census"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to floor select":
		game.free()
		return "a finished census did not offer the floor select"
	game._on_return(state)
	if not game.floor_select.visible or game.town.visible or game.descent.visible:
		game.free()
		return "a finished census did not return to the floor select"
	if not bool(game.campaign.completed.get("ossuary", false)):
		game.free()
		return "the finished census was not recorded"
	if bool(game.campaign.completed.get("cellar", false)) or bool(game.campaign.completed.get("cistern", false)) or bool(game.campaign.completed.get("cloister", false)) or bool(game.campaign.completed.get("crypt", false)):
		game.free()
		return "another floor was marked complete"
	if game.floor_select.status_for("ossuary") != "Census complete":
		game.free()
		return "floor select did not show the ossuary census complete"
	if game.floor_select.status_for("cellar") != "Census open" or game.floor_select.status_for("cistern") != "Census open" or game.floor_select.status_for("cloister") != "Census open" or game.floor_select.status_for("crypt") != "Census open":
		game.free()
		return "another floor card was closed"
	if game.floor_select.notice_label.text.find("complete") < 0:
		game.free()
		return "arrival did not say the census is complete"
	if game.campaign.purse < 240 or game.campaign.last_outcome != "complete":
		game.free()
		return "the finished census was not paid"
	game._show_town()
	if not game.town.visible or game.floor_select.visible:
		game.free()
		return "Back to town did not leave the floor select"
	if game.town.outcome_label.text.find("complete") < 0:
		game.free()
		return "town clerk did not keep the finished census"
	game.free()
	return ""


func _reliquary_layout() -> String:
	if Rules.CORRIDOR_VALUE != 3 or Rules.HAZARD_VALUE != 8 or Rules.LOOP_VALUE != 15:
		return "payout rates changed"
	if Rules.MOVE_OIL != 1 or Rules.HIT_OIL != 3:
		return "oil costs changed"
	if Rules.SMALL_FLASK_OIL != 24 or Rules.LARGE_FLASK_OIL != 120 or Rules.LARGE_FLASK_COST != 40:
		return "flask sizes changed"
	var floor = Rules.floor_named("reliquary")
	if floor == null:
		return "reliquary floor is missing"
	if floor.record != Rules.RELIQUARY_RECORD:
		return "reliquary record drifted from its constant"
	if Rules.RELIQUARY_RECORD != "Record every corridor, the seven nail cracks, and the reliquary ring around the case.":
		return "the reliquary no longer asks for the nails and the ring"
	var expected := PackedStringArray([
		"################",
		"#S##############",
		"#..............#",
		"##.#.RRR.#####.#",
		"##...RRR.###H..#",
		"##H#.RRR.###...#",
		"##.#.RRR.###H..#",
		"##.#.RRR.#####L#",
		"##H......#######",
		"##.......#######",
		"##.H..E.H..H..##",
		"################",
	])
	if floor.rows.size() != expected.size():
		return "reliquary height %d" % floor.rows.size()
	for i in expected.size():
		if str(floor.rows[i]) != str(expected[i]):
			return "reliquary row %d is %s" % [i, floor.rows[i]]
	if Rules.width(floor) != 16 or Rules.height(floor) != 12:
		return "reliquary size %dx%d" % [Rules.width(floor), Rules.height(floor)]
	if Rules.start_pos(floor) != Vector2i(1, 1):
		return "start %s" % Rules.start_pos(floor)
	if Rules.lift_pos(floor) != Vector2i(14, 7):
		return "lift %s" % Rules.lift_pos(floor)
	if Rules.enemy_pos(floor) != Vector2i(6, 10):
		return "warden %s" % Rules.enemy_pos(floor)
	var hazards: Array = Rules.hazard_cells(floor)
	var expect_h: Array = [Vector2i(12, 4), Vector2i(2, 5), Vector2i(12, 6), Vector2i(2, 8), Vector2i(3, 10), Vector2i(8, 10), Vector2i(11, 10)]
	if hazards.size() != expect_h.size():
		return "hazard count %d" % hazards.size()
	for i in hazards.size():
		if hazards[i] != expect_h[i]:
			return "hazard %d is %s" % [i, hazards[i]]
	if Rules.corridor_cells(floor).size() != 60:
		return "corridors %d" % Rules.corridor_cells(floor).size()
	if Rules.glyph_at(Vector2i(6, 4), floor) != "R" or Rules.glyph_at(Vector2i(5, 3), floor) != "R":
		return "the case is not marked on the map"
	if Rules.tile_at(Vector2i(6, 4), floor) != Rules.Tile.WALL or Rules.is_walkable(Vector2i(6, 4), floor):
		return "the case is not solid wall"
	var ring_err := _reliquary_ring(floor)
	if ring_err != "":
		return ring_err
	var swings: Array = Rules.swing_tiles(floor)
	if swings.size() != 2 or swings[0] == swings[1]:
		return "the warden should telegraph two distinct tiles"
	for swing in swings:
		if not Rules.is_walkable(swing, floor):
			return "swing tile %s is not walkable" % swing
	if Rules.is_walkable(Rules.enemy_pos(floor), floor):
		return "the warden's own tile is walkable"
	var steps := Rules.shortest_path_steps(floor)
	if steps != 19:
		return "shortest reliquary path is %d, expected 19" % steps
	if Rules.SMALL_FLASK_OIL - steps < 4:
		return "small flask margin slipped to %d" % (Rules.SMALL_FLASK_OIL - steps)
	var actions: Array = Rules.scripted_safe_actions(floor)
	if actions.is_empty():
		return "no safe exit from the reliquary"
	var state = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	for i in actions.size():
		var result: Dictionary = Rules.step(state, actions[i])
		if bool(result.hit):
			return "hit on reliquary exit action %d at %s" % [i, state.pos]
		if state.end_reason != Rules.EndReason.NONE and i != actions.size() - 1:
			return "reliquary exit ended early at action %d" % i
		if actions[i] != Vector2i.ZERO and not bool(result.moved):
			return "reliquary exit step %d did not move" % i
	if state.end_reason != Rules.EndReason.EXTRACTED or state.pos != Rules.lift_pos(floor):
		return "reliquary exit was not an extract at the lift"
	if state.oil != Rules.SMALL_FLASK_OIL - actions.size():
		return "reliquary exit oil %d after %d actions" % [state.oil, actions.size()]
	var full: int = int(Rules.payout(Rules.accurate_sheet(floor), floor).total)
	var carried: int = int(Rules.payout(state.marks, floor).total)
	if carried <= 0 or carried >= full:
		return "exit sheet paid %d against full %d" % [carried, full]
	if Rules.census_accepted(state.marks, floor):
		return "the exit path was accepted as a finished census"
	var cover := Rules.safe_survey_steps(floor)
	if cover != 114:
		return "safe survey is %d, expected 114" % cover
	if cover > Rules.LARGE_FLASK_OIL or cover <= Rules.SMALL_FLASK_OIL:
		return "survey oil %d does not sit between the flasks" % cover
	print("  reliquary shortest %d  survey %d  exit pay %d  full %d" % [steps, cover, carried, full])
	return ""


func _reliquary_ring(floor) -> String:
	var cells: Array = Rules.loop_cells(floor)
	if cells.size() != 20:
		return "ring size %d" % cells.size()
	var have := {}
	for cell in cells:
		if have.has(cell):
			return "duplicate ring tile %s" % cell
		have[cell] = true
		if not Rules.is_corridor_cell(cell, floor):
			return "ring tile %s is not a corridor" % cell
	for cell in cells:
		var degree := 0
		for dir in Rules.cardinals():
			if have.has(cell + dir):
				degree += 1
		if degree != 2:
			return "ring tile %s has %d neighbors in the ring" % [cell, degree]
	if not have.has(Vector2i(6, 2)) or have.has(Vector2i(6, 3)):
		return "the ring does not rim the case"
	var cases := 0
	for y in Rules.height(floor):
		for x in Rules.width(floor):
			var p := Vector2i(x, y)
			if Rules.glyph_at(p, floor) != "R":
				continue
			cases += 1
			for dir in Rules.cardinals():
				var n: Vector2i = p + dir
				if Rules.is_corridor_cell(n, floor) and not have.has(n):
					return "corridor %s touches the case and is outside the ring" % n
	if cases != 15:
		return "case size %d" % cases
	if str(floor.loop_name) != "Reliquary ring":
		return "ring name is %s" % floor.loop_name
	return ""


func _reliquary_census() -> String:
	var floor = Rules.floor_named("reliquary")
	var cellar = Rules.floor_named("cellar")
	var cistern = Rules.floor_named("cistern")
	var cloister = Rules.floor_named("cloister")
	var crypt = Rules.floor_named("crypt")
	var ossuary = Rules.floor_named("ossuary")
	var truth: Dictionary = Rules.accurate_sheet(floor)
	if not Rules.census_accepted(truth, floor):
		return "the true reliquary census was rejected"
	var bill: Dictionary = Rules.payout(truth, floor)
	if int(bill.corridors) != 60 or int(bill.hazards) != 7 or int(bill.loop) != 1:
		return "true counts %s/%s loop %s" % [bill.corridors, bill.hazards, bill.loop]
	if int(bill.corridor_pay) != 60 * Rules.CORRIDOR_VALUE:
		return "corridor pay drifted"
	if int(bill.hazard_pay) != 7 * Rules.HAZARD_VALUE:
		return "hazard pay drifted"
	if int(bill.loop_pay) != Rules.LOOP_VALUE:
		return "ring pay drifted"
	if int(bill.total) != 251:
		return "true total %s" % bill.total
	if Rules.format_bill(bill).find("Reliquary ring") < 0:
		return "the receipt did not name the reliquary ring"
	if Rules.census_accepted({}, floor):
		return "an empty sheet was accepted"
	if int(Rules.payout({}, floor).total) != 0:
		return "an empty sheet paid out"
	var missing_corridor: Dictionary = truth.duplicate()
	missing_corridor.erase(Rules.start_pos(floor))
	if Rules.census_accepted(missing_corridor, floor):
		return "a sheet missing the start corridor was accepted"
	var missing_bill: Dictionary = Rules.payout(missing_corridor, floor)
	if int(missing_bill.total) >= 251 or int(missing_bill.loop) != 1:
		return "dropping a corridor outside the ring changed the census the wrong way"
	var nail: Vector2i = Rules.hazard_cells(floor)[0]
	var missing_nail: Dictionary = truth.duplicate()
	missing_nail.erase(nail)
	if Rules.census_accepted(missing_nail, floor):
		return "a sheet missing a nail crack was accepted"
	if int(Rules.payout(missing_nail, floor).total) >= 251:
		return "dropping a nail crack did not lower pay"
	var broken_ring: Dictionary = truth.duplicate()
	var rim: Vector2i = Rules.loop_cells(floor)[0]
	broken_ring[rim] = Rules.Mark.WALL
	if Rules.census_accepted(broken_ring, floor):
		return "a broken ring was accepted"
	var broken_bill: Dictionary = Rules.payout(broken_ring, floor)
	if int(broken_bill.loop) != 0 or int(broken_bill.total) >= 251:
		return "a broken ring still paid as a finished sheet"
	var swapped: Dictionary = truth.duplicate()
	swapped[nail] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(swapped, floor):
		return "a nail crack marked as a corridor was accepted"
	if int(Rules.payout(swapped, floor).hazard_pay) >= int(bill.hazard_pay):
		return "mislabeling a nail crack did not lower hazard pay"
	if int(Rules.payout(swapped, floor).total) > 251:
		return "mislabeling a nail crack raised the payout"
	var corridor: Vector2i = Rules.lift_pos(floor)
	var swapped_corridor: Dictionary = truth.duplicate()
	swapped_corridor[corridor] = Rules.Mark.HAZARD
	if Rules.census_accepted(swapped_corridor, floor):
		return "the lift marked as a hazard was accepted"
	if int(Rules.payout(swapped_corridor, floor).total) > 251:
		return "marking the lift as a hazard raised the payout"
	var false_wall: Dictionary = truth.duplicate()
	false_wall[Vector2i(0, 0)] = Rules.Mark.HAZARD
	if Rules.census_accepted(false_wall, floor):
		return "a hazard mark on a wall was accepted"
	if int(Rules.payout(false_wall, floor).total) != 251 or int(Rules.payout(false_wall, floor).hazard_pay) != int(bill.hazard_pay):
		return "a hazard mark on a wall changed the payout"
	var case_wall: Dictionary = truth.duplicate()
	case_wall[Vector2i(5, 3)] = Rules.Mark.WALL
	if not Rules.census_accepted(case_wall, floor):
		return "inking the case as a wall rejected a true census"
	case_wall[Vector2i(5, 3)] = Rules.Mark.HAZARD
	if Rules.census_accepted(case_wall, floor):
		return "calling the case a hazard was accepted"
	var warden_mark: Dictionary = truth.duplicate()
	warden_mark[Rules.enemy_pos(floor)] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(warden_mark, floor):
		return "the warden tile was accepted as a corridor"
	if int(Rules.payout(warden_mark, floor).total) != 251:
		return "marking the warden changed the payout"
	var only_ring := {}
	for cell in Rules.loop_cells(floor):
		only_ring[cell] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(only_ring, floor):
		return "the ring alone was accepted as the census"
	var ring_bill: Dictionary = Rules.payout(only_ring, floor)
	if int(ring_bill.loop) != 1 or int(ring_bill.hazards) != 0 or int(ring_bill.total) >= 251:
		return "the ring bonus did not stay inside the shared payout rule"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cellar):
		return "the reliquary sheet was accepted as the cellar"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cistern):
		return "the reliquary sheet was accepted as the cistern"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cloister):
		return "the reliquary sheet was accepted as the cloister"
	if Rules.census_accepted(Rules.accurate_sheet(floor), crypt):
		return "the reliquary sheet was accepted as the crypt"
	if Rules.census_accepted(Rules.accurate_sheet(floor), ossuary):
		return "the reliquary sheet was accepted as the ossuary"
	if Rules.census_accepted(Rules.accurate_sheet(cellar), floor):
		return "the cellar sheet was accepted as the reliquary"
	if Rules.census_accepted(Rules.accurate_sheet(cistern), floor):
		return "the cistern sheet was accepted as the reliquary"
	if Rules.census_accepted(Rules.accurate_sheet(cloister), floor):
		return "the cloister sheet was accepted as the reliquary"
	if Rules.census_accepted(Rules.accurate_sheet(crypt), floor):
		return "the crypt sheet was accepted as the reliquary"
	if Rules.census_accepted(Rules.accurate_sheet(ossuary), floor):
		return "the ossuary sheet was accepted as the reliquary"
	if not Rules.census_accepted(Rules.accurate_sheet(cellar), cellar):
		return "the cellar's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(cistern), cistern):
		return "the cistern's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(cloister), cloister):
		return "the cloister's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(crypt), crypt):
		return "the crypt's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(ossuary), ossuary):
		return "the ossuary's true census was rejected"
	var cellar_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cellar), cellar)
	if int(cellar_bill.total) != 211 or str(cellar_bill.loop_name) != "East square":
		return "the cellar payout changed"
	var cistern_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cistern), cistern)
	if int(cistern_bill.total) != 288 or str(cistern_bill.loop_name) != "Cistern ring":
		return "the cistern payout changed"
	var cloister_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cloister), cloister)
	if int(cloister_bill.total) != 242 or str(cloister_bill.loop_name) != "Cloister walk":
		return "the cloister payout changed"
	var crypt_bill: Dictionary = Rules.payout(Rules.accurate_sheet(crypt), crypt)
	if int(crypt_bill.total) != 316 or str(crypt_bill.loop_name) != "Crypt ring":
		return "the crypt payout changed"
	var ossuary_bill: Dictionary = Rules.payout(Rules.accurate_sheet(ossuary), ossuary)
	if int(ossuary_bill.total) != 240 or str(ossuary_bill.loop_name) != "Ossuary ring":
		return "the ossuary payout changed"
	var approach: Vector2i = Rules.walkable_approach(nail, floor)
	if approach.x < 0:
		return "nail crack has no approach"
	var walker = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	walker.pos = approach
	walker.oil = 10
	var before: int = walker.oil
	var stepped: Dictionary = Rules.step(walker, nail - approach)
	if bool(stepped.hit):
		return "opening nail step was a swing"
	if walker.oil != before - Rules.MOVE_OIL:
		return "nail burned extra oil"
	if int(walker.marks.get(nail, Rules.Mark.NONE)) != Rules.Mark.HAZARD:
		return "nail was not inked as a hazard"
	return ""


func _reliquary_return() -> String:
	var game_script = load("res://scripts/game.gd")
	var select_script = load("res://scripts/floor_select_view.gd")
	if game_script == null or select_script == null:
		return "game or floor select did not load"
	var game = game_script.new()
	root.add_child(game)
	if game.town == null or game.floor_select == null or game.descent == null:
		game.free()
		return "the game did not build its screens"
	if game.floor_select.record_for("reliquary") != Rules.RELIQUARY_RECORD:
		game.free()
		return "floor select does not offer the reliquary census"
	if game.floor_select.record_for("cellar") != Rules.CELLAR_RECORD:
		game.free()
		return "floor select dropped the cellar census"
	if game.floor_select.record_for("cistern") != Rules.CISTERN_RECORD:
		game.free()
		return "floor select dropped the cistern census"
	if game.floor_select.record_for("cloister") != Rules.CLOISTER_RECORD:
		game.free()
		return "floor select dropped the cloister census"
	if game.floor_select.record_for("crypt") != Rules.CRYPT_RECORD:
		game.free()
		return "floor select dropped the crypt census"
	if game.floor_select.record_for("ossuary") != Rules.OSSUARY_RECORD:
		game.free()
		return "floor select dropped the ossuary census"
	if game.floor_select.status_for("reliquary") != "Census open":
		game.free()
		return "the reliquary card did not open"
	game._on_descend_floor("reliquary")
	if game.descent.state == null or game.descent.state.floor.id != "reliquary":
		game.free()
		return "descend did not open the reliquary"
	var state = game.descent.state
	var lift: Vector2i = Rules.lift_pos(state.floor)
	var approach: Vector2i = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var left: Dictionary = Rules.step(state, lift - approach)
	if not bool(left.extracted):
		game.free()
		return "short reliquary sheet did not leave on the lift"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to town":
		game.free()
		return "a short sheet offered the floor select"
	game._on_return(state)
	if not game.town.visible or game.floor_select.visible or game.descent.visible:
		game.free()
		return "a short census did not return to town"
	if bool(game.campaign.completed.get("reliquary", false)):
		game.free()
		return "a short census was accepted"
	if game.town.outcome_label.text.find("not finished") < 0:
		game.free()
		return "the clerk treated a short sheet as finished"
	game._on_floors()
	if not game.floor_select.visible or game.town.visible:
		game.free()
		return "floor select did not open from town"
	game._on_descend_floor("reliquary")
	state = game.descent.state
	state.marks = Rules.accurate_sheet(state.floor)
	lift = Rules.lift_pos(state.floor)
	approach = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var done: Dictionary = Rules.step(state, lift - approach)
	if not bool(done.extracted) or not Rules.census_accepted(state.marks, state.floor):
		game.free()
		return "the finished sheet did not extract as an accepted census"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to floor select":
		game.free()
		return "a finished census did not offer the floor select"
	game._on_return(state)
	if not game.floor_select.visible or game.town.visible or game.descent.visible:
		game.free()
		return "a finished census did not return to the floor select"
	if not bool(game.campaign.completed.get("reliquary", false)):
		game.free()
		return "the finished census was not recorded"
	if bool(game.campaign.completed.get("cellar", false)) or bool(game.campaign.completed.get("cistern", false)) or bool(game.campaign.completed.get("cloister", false)) or bool(game.campaign.completed.get("crypt", false)) or bool(game.campaign.completed.get("ossuary", false)):
		game.free()
		return "another floor was marked complete"
	if game.floor_select.status_for("reliquary") != "Census complete":
		game.free()
		return "floor select did not show the reliquary census complete"
	if game.floor_select.status_for("cellar") != "Census open" or game.floor_select.status_for("cistern") != "Census open" or game.floor_select.status_for("cloister") != "Census open" or game.floor_select.status_for("crypt") != "Census open" or game.floor_select.status_for("ossuary") != "Census open":
		game.free()
		return "another floor card was closed"
	if game.floor_select.notice_label.text.find("complete") < 0:
		game.free()
		return "arrival did not say the census is complete"
	if game.campaign.purse < 251 or game.campaign.last_outcome != "complete":
		game.free()
		return "the finished census was not paid"
	game._show_town()
	if not game.town.visible or game.floor_select.visible:
		game.free()
		return "Back to town did not leave the floor select"
	if game.town.outcome_label.text.find("complete") < 0:
		game.free()
		return "town clerk did not keep the finished census"
	game.free()
	return ""


func _undercroft_layout() -> String:
	if Rules.CORRIDOR_VALUE != 3 or Rules.HAZARD_VALUE != 8 or Rules.LOOP_VALUE != 15:
		return "payout rates changed"
	if Rules.MOVE_OIL != 1 or Rules.HIT_OIL != 3:
		return "oil costs changed"
	if Rules.SMALL_FLASK_OIL != 24 or Rules.LARGE_FLASK_OIL != 120 or Rules.LARGE_FLASK_COST != 40:
		return "flask sizes changed"
	var floor = Rules.floor_named("undercroft")
	if floor == null:
		return "undercroft floor is missing"
	if floor.record != Rules.UNDERCROFT_RECORD:
		return "undercroft record drifted from its constant"
	if Rules.UNDERCROFT_RECORD != "Record every corridor, the eight salt cracks, and the undercroft ring around the trough.":
		return "the undercroft no longer asks for the salt and the ring"
	var expected := PackedStringArray([
		"###############",
		"#S............#",
		"#####.....###.#",
		"#####.BBB.###H#",
		"#.H.#.BBB.###.#",
		"#H....BBB.###H#",
		"#.H.#.BBB.###.#",
		"#####.BBB.###H#",
		"#####.BBB....L#",
		"#####.BBB.#####",
		"#####.....#####",
		"#####H.E.H#####",
		"###############",
	])
	if floor.rows.size() != expected.size():
		return "undercroft height %d" % floor.rows.size()
	for i in expected.size():
		if str(floor.rows[i]) != str(expected[i]):
			return "undercroft row %d is %s" % [i, floor.rows[i]]
	if Rules.width(floor) != 15 or Rules.height(floor) != 13:
		return "undercroft size %dx%d" % [Rules.width(floor), Rules.height(floor)]
	if Rules.start_pos(floor) != Vector2i(1, 1):
		return "start %s" % Rules.start_pos(floor)
	if Rules.lift_pos(floor) != Vector2i(13, 8):
		return "lift %s" % Rules.lift_pos(floor)
	if Rules.enemy_pos(floor) != Vector2i(7, 11):
		return "warden %s" % Rules.enemy_pos(floor)
	var hazards: Array = Rules.hazard_cells(floor)
	var expect_h: Array = [Vector2i(13, 3), Vector2i(2, 4), Vector2i(1, 5), Vector2i(13, 5), Vector2i(2, 6), Vector2i(13, 7), Vector2i(5, 11), Vector2i(9, 11)]
	if hazards.size() != expect_h.size():
		return "hazard count %d" % hazards.size()
	for i in hazards.size():
		if hazards[i] != expect_h[i]:
			return "hazard %d is %s" % [i, hazards[i]]
	if Rules.corridor_cells(floor).size() != 53:
		return "corridors %d" % Rules.corridor_cells(floor).size()
	if Rules.glyph_at(Vector2i(7, 5), floor) != "B" or Rules.glyph_at(Vector2i(6, 3), floor) != "B":
		return "the trough is not marked on the map"
	if Rules.tile_at(Vector2i(7, 5), floor) != Rules.Tile.WALL or Rules.is_walkable(Vector2i(7, 5), floor):
		return "the trough is not solid wall"
	var ring_err := _undercroft_ring(floor)
	if ring_err != "":
		return ring_err
	var swings: Array = Rules.swing_tiles(floor)
	if swings.size() != 2 or swings[0] == swings[1]:
		return "the warden should telegraph two distinct tiles"
	for swing in swings:
		if not Rules.is_walkable(swing, floor):
			return "swing tile %s is not walkable" % swing
	if Rules.is_walkable(Rules.enemy_pos(floor), floor):
		return "the warden's own tile is walkable"
	var steps := Rules.shortest_path_steps(floor)
	if steps != 19:
		return "shortest undercroft path is %d, expected 19" % steps
	if Rules.SMALL_FLASK_OIL - steps < 4:
		return "small flask margin slipped to %d" % (Rules.SMALL_FLASK_OIL - steps)
	var actions: Array = Rules.scripted_safe_actions(floor)
	if actions.is_empty():
		return "no safe exit from the undercroft"
	var state = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	for i in actions.size():
		var result: Dictionary = Rules.step(state, actions[i])
		if bool(result.hit):
			return "hit on undercroft exit action %d at %s" % [i, state.pos]
		if state.end_reason != Rules.EndReason.NONE and i != actions.size() - 1:
			return "undercroft exit ended early at action %d" % i
		if actions[i] != Vector2i.ZERO and not bool(result.moved):
			return "undercroft exit step %d did not move" % i
	if state.end_reason != Rules.EndReason.EXTRACTED or state.pos != Rules.lift_pos(floor):
		return "undercroft exit was not an extract at the lift"
	if state.oil != Rules.SMALL_FLASK_OIL - actions.size():
		return "undercroft exit oil %d after %d actions" % [state.oil, actions.size()]
	var full: int = int(Rules.payout(Rules.accurate_sheet(floor), floor).total)
	var carried: int = int(Rules.payout(state.marks, floor).total)
	if carried <= 0 or carried >= full:
		return "exit sheet paid %d against full %d" % [carried, full]
	if Rules.census_accepted(state.marks, floor):
		return "the exit path was accepted as a finished census"
	var cover := Rules.safe_survey_steps(floor)
	if cover != 95:
		return "safe survey is %d, expected 95" % cover
	if cover > Rules.LARGE_FLASK_OIL or cover <= Rules.SMALL_FLASK_OIL:
		return "survey oil %d does not sit between the flasks" % cover
	print("  undercroft shortest %d  survey %d  exit pay %d  full %d" % [steps, cover, carried, full])
	return ""


func _undercroft_ring(floor) -> String:
	var cells: Array = Rules.loop_cells(floor)
	if cells.size() != 24:
		return "ring size %d" % cells.size()
	var have := {}
	for cell in cells:
		if have.has(cell):
			return "duplicate ring tile %s" % cell
		have[cell] = true
		if not Rules.is_corridor_cell(cell, floor):
			return "ring tile %s is not a corridor" % cell
	for cell in cells:
		var degree := 0
		for dir in Rules.cardinals():
			if have.has(cell + dir):
				degree += 1
		if degree != 2:
			return "ring tile %s has %d neighbors in the ring" % [cell, degree]
	if not have.has(Vector2i(7, 2)) or have.has(Vector2i(7, 3)):
		return "the ring does not rim the trough"
	var troughs := 0
	for y in Rules.height(floor):
		for x in Rules.width(floor):
			var p := Vector2i(x, y)
			if Rules.glyph_at(p, floor) != "B":
				continue
			troughs += 1
			for dir in Rules.cardinals():
				var n: Vector2i = p + dir
				if Rules.is_corridor_cell(n, floor) and not have.has(n):
					return "corridor %s touches the trough and is outside the ring" % n
	if troughs != 21:
		return "trough size %d" % troughs
	if str(floor.loop_name) != "Undercroft ring":
		return "ring name is %s" % floor.loop_name
	return ""


func _undercroft_census() -> String:
	var floor = Rules.floor_named("undercroft")
	var cellar = Rules.floor_named("cellar")
	var cistern = Rules.floor_named("cistern")
	var cloister = Rules.floor_named("cloister")
	var crypt = Rules.floor_named("crypt")
	var ossuary = Rules.floor_named("ossuary")
	var reliquary = Rules.floor_named("reliquary")
	var truth: Dictionary = Rules.accurate_sheet(floor)
	if not Rules.census_accepted(truth, floor):
		return "the true undercroft census was rejected"
	var bill: Dictionary = Rules.payout(truth, floor)
	if int(bill.corridors) != 53 or int(bill.hazards) != 8 or int(bill.loop) != 1:
		return "true counts %s/%s loop %s" % [bill.corridors, bill.hazards, bill.loop]
	if int(bill.corridor_pay) != 53 * Rules.CORRIDOR_VALUE:
		return "corridor pay drifted"
	if int(bill.hazard_pay) != 8 * Rules.HAZARD_VALUE:
		return "hazard pay drifted"
	if int(bill.loop_pay) != Rules.LOOP_VALUE:
		return "ring pay drifted"
	if int(bill.total) != 238:
		return "true total %s" % bill.total
	if Rules.format_bill(bill).find("Undercroft ring") < 0:
		return "the receipt did not name the undercroft ring"
	if Rules.census_accepted({}, floor):
		return "an empty sheet was accepted"
	if int(Rules.payout({}, floor).total) != 0:
		return "an empty sheet paid out"
	var missing_corridor: Dictionary = truth.duplicate()
	missing_corridor.erase(Rules.start_pos(floor))
	if Rules.census_accepted(missing_corridor, floor):
		return "a sheet missing the start corridor was accepted"
	var missing_bill: Dictionary = Rules.payout(missing_corridor, floor)
	if int(missing_bill.total) >= 238 or int(missing_bill.loop) != 1:
		return "dropping a corridor outside the ring changed the census the wrong way"
	var salt: Vector2i = Rules.hazard_cells(floor)[0]
	var missing_salt: Dictionary = truth.duplicate()
	missing_salt.erase(salt)
	if Rules.census_accepted(missing_salt, floor):
		return "a sheet missing a salt crack was accepted"
	if int(Rules.payout(missing_salt, floor).total) >= 238:
		return "dropping a salt crack did not lower pay"
	var broken_ring: Dictionary = truth.duplicate()
	var rim: Vector2i = Rules.loop_cells(floor)[0]
	broken_ring[rim] = Rules.Mark.WALL
	if Rules.census_accepted(broken_ring, floor):
		return "a broken ring was accepted"
	var broken_bill: Dictionary = Rules.payout(broken_ring, floor)
	if int(broken_bill.loop) != 0 or int(broken_bill.total) >= 238:
		return "a broken ring still paid as a finished sheet"
	var swapped: Dictionary = truth.duplicate()
	swapped[salt] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(swapped, floor):
		return "a salt crack marked as a corridor was accepted"
	if int(Rules.payout(swapped, floor).hazard_pay) >= int(bill.hazard_pay):
		return "mislabeling a salt crack did not lower hazard pay"
	if int(Rules.payout(swapped, floor).total) > 238:
		return "mislabeling a salt crack raised the payout"
	var corridor: Vector2i = Rules.lift_pos(floor)
	var swapped_corridor: Dictionary = truth.duplicate()
	swapped_corridor[corridor] = Rules.Mark.HAZARD
	if Rules.census_accepted(swapped_corridor, floor):
		return "the lift marked as a hazard was accepted"
	if int(Rules.payout(swapped_corridor, floor).total) > 238:
		return "marking the lift as a hazard raised the payout"
	var false_wall: Dictionary = truth.duplicate()
	false_wall[Vector2i(0, 0)] = Rules.Mark.HAZARD
	if Rules.census_accepted(false_wall, floor):
		return "a hazard mark on a wall was accepted"
	if int(Rules.payout(false_wall, floor).total) != 238 or int(Rules.payout(false_wall, floor).hazard_pay) != int(bill.hazard_pay):
		return "a hazard mark on a wall changed the payout"
	var trough_wall: Dictionary = truth.duplicate()
	trough_wall[Vector2i(6, 3)] = Rules.Mark.WALL
	if not Rules.census_accepted(trough_wall, floor):
		return "inking the trough as a wall rejected a true census"
	trough_wall[Vector2i(6, 3)] = Rules.Mark.HAZARD
	if Rules.census_accepted(trough_wall, floor):
		return "calling the trough a hazard was accepted"
	var warden_mark: Dictionary = truth.duplicate()
	warden_mark[Rules.enemy_pos(floor)] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(warden_mark, floor):
		return "the warden tile was accepted as a corridor"
	if int(Rules.payout(warden_mark, floor).total) != 238:
		return "marking the warden changed the payout"
	var only_ring := {}
	for cell in Rules.loop_cells(floor):
		only_ring[cell] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(only_ring, floor):
		return "the ring alone was accepted as the census"
	var ring_bill: Dictionary = Rules.payout(only_ring, floor)
	if int(ring_bill.loop) != 1 or int(ring_bill.hazards) != 0 or int(ring_bill.total) >= 238:
		return "the ring bonus did not stay inside the shared payout rule"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cellar):
		return "the undercroft sheet was accepted as the cellar"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cistern):
		return "the undercroft sheet was accepted as the cistern"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cloister):
		return "the undercroft sheet was accepted as the cloister"
	if Rules.census_accepted(Rules.accurate_sheet(floor), crypt):
		return "the undercroft sheet was accepted as the crypt"
	if Rules.census_accepted(Rules.accurate_sheet(floor), ossuary):
		return "the undercroft sheet was accepted as the ossuary"
	if Rules.census_accepted(Rules.accurate_sheet(floor), reliquary):
		return "the undercroft sheet was accepted as the reliquary"
	if Rules.census_accepted(Rules.accurate_sheet(cellar), floor):
		return "the cellar sheet was accepted as the undercroft"
	if Rules.census_accepted(Rules.accurate_sheet(cistern), floor):
		return "the cistern sheet was accepted as the undercroft"
	if Rules.census_accepted(Rules.accurate_sheet(cloister), floor):
		return "the cloister sheet was accepted as the undercroft"
	if Rules.census_accepted(Rules.accurate_sheet(crypt), floor):
		return "the crypt sheet was accepted as the undercroft"
	if Rules.census_accepted(Rules.accurate_sheet(ossuary), floor):
		return "the ossuary sheet was accepted as the undercroft"
	if Rules.census_accepted(Rules.accurate_sheet(reliquary), floor):
		return "the reliquary sheet was accepted as the undercroft"
	if not Rules.census_accepted(Rules.accurate_sheet(cellar), cellar):
		return "the cellar's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(cistern), cistern):
		return "the cistern's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(cloister), cloister):
		return "the cloister's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(crypt), crypt):
		return "the crypt's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(ossuary), ossuary):
		return "the ossuary's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(reliquary), reliquary):
		return "the reliquary's true census was rejected"
	var cellar_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cellar), cellar)
	if int(cellar_bill.total) != 211 or str(cellar_bill.loop_name) != "East square":
		return "the cellar payout changed"
	var cistern_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cistern), cistern)
	if int(cistern_bill.total) != 288 or str(cistern_bill.loop_name) != "Cistern ring":
		return "the cistern payout changed"
	var cloister_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cloister), cloister)
	if int(cloister_bill.total) != 242 or str(cloister_bill.loop_name) != "Cloister walk":
		return "the cloister payout changed"
	var crypt_bill: Dictionary = Rules.payout(Rules.accurate_sheet(crypt), crypt)
	if int(crypt_bill.total) != 316 or str(crypt_bill.loop_name) != "Crypt ring":
		return "the crypt payout changed"
	var ossuary_bill: Dictionary = Rules.payout(Rules.accurate_sheet(ossuary), ossuary)
	if int(ossuary_bill.total) != 240 or str(ossuary_bill.loop_name) != "Ossuary ring":
		return "the ossuary payout changed"
	var reliquary_bill: Dictionary = Rules.payout(Rules.accurate_sheet(reliquary), reliquary)
	if int(reliquary_bill.total) != 251 or str(reliquary_bill.loop_name) != "Reliquary ring":
		return "the reliquary payout changed"
	var approach: Vector2i = Rules.walkable_approach(salt, floor)
	if approach.x < 0:
		return "salt crack has no approach"
	var walker = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	walker.pos = approach
	walker.oil = 10
	var before: int = walker.oil
	var stepped: Dictionary = Rules.step(walker, salt - approach)
	if bool(stepped.hit):
		return "opening salt step was a swing"
	if walker.oil != before - Rules.MOVE_OIL:
		return "salt burned extra oil"
	if int(walker.marks.get(salt, Rules.Mark.NONE)) != Rules.Mark.HAZARD:
		return "salt was not inked as a hazard"
	return ""


func _undercroft_return() -> String:
	var game_script = load("res://scripts/game.gd")
	var select_script = load("res://scripts/floor_select_view.gd")
	if game_script == null or select_script == null:
		return "game or floor select did not load"
	var game = game_script.new()
	root.add_child(game)
	if game.town == null or game.floor_select == null or game.descent == null:
		game.free()
		return "the game did not build its screens"
	if game.floor_select.record_for("undercroft") != Rules.UNDERCROFT_RECORD:
		game.free()
		return "floor select does not offer the undercroft census"
	if game.floor_select.record_for("cellar") != Rules.CELLAR_RECORD:
		game.free()
		return "floor select dropped the cellar census"
	if game.floor_select.record_for("cistern") != Rules.CISTERN_RECORD:
		game.free()
		return "floor select dropped the cistern census"
	if game.floor_select.record_for("cloister") != Rules.CLOISTER_RECORD:
		game.free()
		return "floor select dropped the cloister census"
	if game.floor_select.record_for("crypt") != Rules.CRYPT_RECORD:
		game.free()
		return "floor select dropped the crypt census"
	if game.floor_select.record_for("ossuary") != Rules.OSSUARY_RECORD:
		game.free()
		return "floor select dropped the ossuary census"
	if game.floor_select.record_for("reliquary") != Rules.RELIQUARY_RECORD:
		game.free()
		return "floor select dropped the reliquary census"
	if game.floor_select.status_for("undercroft") != "Census open":
		game.free()
		return "the undercroft card did not open"
	game._on_descend_floor("undercroft")
	if game.descent.state == null or game.descent.state.floor.id != "undercroft":
		game.free()
		return "descend did not open the undercroft"
	var state = game.descent.state
	var lift: Vector2i = Rules.lift_pos(state.floor)
	var approach: Vector2i = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var left: Dictionary = Rules.step(state, lift - approach)
	if not bool(left.extracted):
		game.free()
		return "short undercroft sheet did not leave on the lift"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to town":
		game.free()
		return "a short sheet offered the floor select"
	game._on_return(state)
	if not game.town.visible or game.floor_select.visible or game.descent.visible:
		game.free()
		return "a short census did not return to town"
	if bool(game.campaign.completed.get("undercroft", false)):
		game.free()
		return "a short census was accepted"
	if game.town.outcome_label.text.find("not finished") < 0:
		game.free()
		return "the clerk treated a short sheet as finished"
	game._on_floors()
	if not game.floor_select.visible or game.town.visible:
		game.free()
		return "floor select did not open from town"
	game._on_descend_floor("undercroft")
	state = game.descent.state
	state.marks = Rules.accurate_sheet(state.floor)
	lift = Rules.lift_pos(state.floor)
	approach = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var done: Dictionary = Rules.step(state, lift - approach)
	if not bool(done.extracted) or not Rules.census_accepted(state.marks, state.floor):
		game.free()
		return "the finished sheet did not extract as an accepted census"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to floor select":
		game.free()
		return "a finished census did not offer the floor select"
	game._on_return(state)
	if not game.floor_select.visible or game.town.visible or game.descent.visible:
		game.free()
		return "a finished census did not return to the floor select"
	if not bool(game.campaign.completed.get("undercroft", false)):
		game.free()
		return "the finished census was not recorded"
	if bool(game.campaign.completed.get("cellar", false)) or bool(game.campaign.completed.get("cistern", false)) or bool(game.campaign.completed.get("cloister", false)) or bool(game.campaign.completed.get("crypt", false)) or bool(game.campaign.completed.get("ossuary", false)) or bool(game.campaign.completed.get("reliquary", false)):
		game.free()
		return "another floor was marked complete"
	if game.floor_select.status_for("undercroft") != "Census complete":
		game.free()
		return "floor select did not show the undercroft census complete"
	if game.floor_select.status_for("cellar") != "Census open" or game.floor_select.status_for("cistern") != "Census open" or game.floor_select.status_for("cloister") != "Census open" or game.floor_select.status_for("crypt") != "Census open" or game.floor_select.status_for("ossuary") != "Census open" or game.floor_select.status_for("reliquary") != "Census open":
		game.free()
		return "another floor card was closed"
	if game.floor_select.notice_label.text.find("complete") < 0:
		game.free()
		return "arrival did not say the census is complete"
	if game.campaign.purse < 238 or game.campaign.last_outcome != "complete":
		game.free()
		return "the finished census was not paid"
	game._show_town()
	if not game.town.visible or game.floor_select.visible:
		game.free()
		return "Back to town did not leave the floor select"
	if game.town.outcome_label.text.find("complete") < 0:
		game.free()
		return "town clerk did not keep the finished census"
	game.free()
	return ""


func _wellhouse_layout() -> String:
	if Rules.CORRIDOR_VALUE != 3 or Rules.HAZARD_VALUE != 8 or Rules.LOOP_VALUE != 15:
		return "payout rates changed"
	if Rules.MOVE_OIL != 1 or Rules.HIT_OIL != 3:
		return "oil costs changed"
	if Rules.SMALL_FLASK_OIL != 24 or Rules.LARGE_FLASK_OIL != 120 or Rules.LARGE_FLASK_COST != 40:
		return "flask sizes changed"
	var floor = Rules.floor_named("wellhouse")
	if floor == null:
		return "well house floor is missing"
	if floor.record != Rules.WELL_RECORD:
		return "well house record drifted from its constant"
	if Rules.WELL_RECORD != "Record every corridor, the nine well cracks, and the well ring around the shaft.":
		return "the well house no longer asks for the well cracks and the ring"
	var expected := PackedStringArray([
		"#################",
		"#S..............#",
		"####.......####.#",
		"####.WWWWW.H###.#",
		"###H.WWWWW.####.#",
		"####.WWWWW.H###.#",
		"###H.WWWWW.####L#",
		"####.WWWWW.H#####",
		"###H.WWWWW.######",
		"####.......H#####",
		"######HEH########",
		"#################",
	])
	if floor.rows.size() != expected.size():
		return "well house height %d" % floor.rows.size()
	for i in expected.size():
		if str(floor.rows[i]) != str(expected[i]):
			return "well house row %d is %s" % [i, floor.rows[i]]
	if Rules.width(floor) != 17 or Rules.height(floor) != 12:
		return "well house size %dx%d" % [Rules.width(floor), Rules.height(floor)]
	if Rules.start_pos(floor) != Vector2i(1, 1):
		return "start %s" % Rules.start_pos(floor)
	if Rules.lift_pos(floor) != Vector2i(15, 6):
		return "lift %s" % Rules.lift_pos(floor)
	if Rules.enemy_pos(floor) != Vector2i(7, 10):
		return "warden %s" % Rules.enemy_pos(floor)
	var hazards: Array = Rules.hazard_cells(floor)
	var expect_h: Array = [Vector2i(11, 3), Vector2i(3, 4), Vector2i(11, 5), Vector2i(3, 6), Vector2i(11, 7), Vector2i(3, 8), Vector2i(11, 9), Vector2i(6, 10), Vector2i(8, 10)]
	if hazards.size() != expect_h.size():
		return "hazard count %d" % hazards.size()
	for i in hazards.size():
		if hazards[i] != expect_h[i]:
			return "hazard %d is %s" % [i, hazards[i]]
	if Rules.corridor_cells(floor).size() != 46:
		return "corridors %d" % Rules.corridor_cells(floor).size()
	if Rules.glyph_at(Vector2i(7, 5), floor) != "W" or Rules.glyph_at(Vector2i(5, 3), floor) != "W":
		return "the shaft is not marked on the map"
	if Rules.tile_at(Vector2i(7, 5), floor) != Rules.Tile.WALL or Rules.is_walkable(Vector2i(7, 5), floor):
		return "the shaft is not solid wall"
	var ring_err := _wellhouse_ring(floor)
	if ring_err != "":
		return ring_err
	var swings: Array = Rules.swing_tiles(floor)
	if swings.size() != 2 or swings[0] == swings[1]:
		return "the warden should telegraph two distinct tiles"
	for swing in swings:
		if not Rules.is_walkable(swing, floor):
			return "swing tile %s is not walkable" % swing
	if Rules.is_walkable(Rules.enemy_pos(floor), floor):
		return "the warden's own tile is walkable"
	var steps := Rules.shortest_path_steps(floor)
	if steps != 19:
		return "shortest well house path is %d, expected 19" % steps
	if Rules.SMALL_FLASK_OIL - steps < 4:
		return "small flask margin slipped to %d" % (Rules.SMALL_FLASK_OIL - steps)
	var actions: Array = Rules.scripted_safe_actions(floor)
	if actions.is_empty():
		return "no safe exit from the well house"
	var state = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	for i in actions.size():
		var result: Dictionary = Rules.step(state, actions[i])
		if bool(result.hit):
			return "hit on well house exit action %d at %s" % [i, state.pos]
		if state.end_reason != Rules.EndReason.NONE and i != actions.size() - 1:
			return "well house exit ended early at action %d" % i
		if actions[i] != Vector2i.ZERO and not bool(result.moved):
			return "well house exit step %d did not move" % i
	if state.end_reason != Rules.EndReason.EXTRACTED or state.pos != Rules.lift_pos(floor):
		return "well house exit was not an extract at the lift"
	if state.oil != Rules.SMALL_FLASK_OIL - actions.size():
		return "well house exit oil %d after %d actions" % [state.oil, actions.size()]
	var full: int = int(Rules.payout(Rules.accurate_sheet(floor), floor).total)
	var carried: int = int(Rules.payout(state.marks, floor).total)
	if carried <= 0 or carried >= full:
		return "exit sheet paid %d against full %d" % [carried, full]
	if Rules.census_accepted(state.marks, floor):
		return "the exit path was accepted as a finished census"
	var cover := Rules.safe_survey_steps(floor)
	if cover != 110:
		return "safe survey is %d, expected 110" % cover
	if cover > Rules.LARGE_FLASK_OIL or cover <= Rules.SMALL_FLASK_OIL:
		return "survey oil %d does not sit between the flasks" % cover
	print("  well house shortest %d  survey %d  exit pay %d  full %d" % [steps, cover, carried, full])
	return ""


func _wellhouse_ring(floor) -> String:
	var cells: Array = Rules.loop_cells(floor)
	if cells.size() != 26:
		return "ring size %d" % cells.size()
	var have := {}
	for cell in cells:
		if have.has(cell):
			return "duplicate ring tile %s" % cell
		have[cell] = true
		if not Rules.is_corridor_cell(cell, floor):
			return "ring tile %s is not a corridor" % cell
	for cell in cells:
		var degree := 0
		for dir in Rules.cardinals():
			if have.has(cell + dir):
				degree += 1
		if degree != 2:
			return "ring tile %s has %d neighbors in the ring" % [cell, degree]
	if not have.has(Vector2i(7, 2)) or have.has(Vector2i(7, 3)):
		return "the ring does not rim the shaft"
	var shafts := 0
	for y in Rules.height(floor):
		for x in Rules.width(floor):
			var p := Vector2i(x, y)
			if Rules.glyph_at(p, floor) != "W":
				continue
			shafts += 1
			for dir in Rules.cardinals():
				var n: Vector2i = p + dir
				if Rules.is_corridor_cell(n, floor) and not have.has(n):
					return "corridor %s touches the shaft and is outside the ring" % n
	if shafts != 30:
		return "shaft size %d" % shafts
	if str(floor.loop_name) != "Well ring":
		return "ring name is %s" % floor.loop_name
	return ""


func _wellhouse_census() -> String:
	var floor = Rules.floor_named("wellhouse")
	var cellar = Rules.floor_named("cellar")
	var cistern = Rules.floor_named("cistern")
	var cloister = Rules.floor_named("cloister")
	var crypt = Rules.floor_named("crypt")
	var ossuary = Rules.floor_named("ossuary")
	var reliquary = Rules.floor_named("reliquary")
	var undercroft = Rules.floor_named("undercroft")
	var truth: Dictionary = Rules.accurate_sheet(floor)
	if not Rules.census_accepted(truth, floor):
		return "the true well house census was rejected"
	var bill: Dictionary = Rules.payout(truth, floor)
	if int(bill.corridors) != 46 or int(bill.hazards) != 9 or int(bill.loop) != 1:
		return "true counts %s/%s loop %s" % [bill.corridors, bill.hazards, bill.loop]
	if int(bill.corridor_pay) != 46 * Rules.CORRIDOR_VALUE:
		return "corridor pay drifted"
	if int(bill.hazard_pay) != 9 * Rules.HAZARD_VALUE:
		return "hazard pay drifted"
	if int(bill.loop_pay) != Rules.LOOP_VALUE:
		return "ring pay drifted"
	if int(bill.total) != 225:
		return "true total %s" % bill.total
	if Rules.format_bill(bill).find("Well ring") < 0:
		return "the receipt did not name the well ring"
	if Rules.census_accepted({}, floor):
		return "an empty sheet was accepted"
	if int(Rules.payout({}, floor).total) != 0:
		return "an empty sheet paid out"
	var missing_corridor: Dictionary = truth.duplicate()
	missing_corridor.erase(Rules.start_pos(floor))
	if Rules.census_accepted(missing_corridor, floor):
		return "a sheet missing the start corridor was accepted"
	var missing_bill: Dictionary = Rules.payout(missing_corridor, floor)
	if int(missing_bill.total) >= 225 or int(missing_bill.loop) != 1:
		return "dropping a corridor outside the ring changed the census the wrong way"
	var crack: Vector2i = Rules.hazard_cells(floor)[0]
	var missing_crack: Dictionary = truth.duplicate()
	missing_crack.erase(crack)
	if Rules.census_accepted(missing_crack, floor):
		return "a sheet missing a well crack was accepted"
	if int(Rules.payout(missing_crack, floor).total) >= 225:
		return "dropping a well crack did not lower pay"
	var broken_ring: Dictionary = truth.duplicate()
	var rim: Vector2i = Rules.loop_cells(floor)[0]
	broken_ring[rim] = Rules.Mark.WALL
	if Rules.census_accepted(broken_ring, floor):
		return "a broken ring was accepted"
	var broken_bill: Dictionary = Rules.payout(broken_ring, floor)
	if int(broken_bill.loop) != 0 or int(broken_bill.total) >= 225:
		return "a broken ring still paid as a finished sheet"
	var swapped: Dictionary = truth.duplicate()
	swapped[crack] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(swapped, floor):
		return "a well crack marked as a corridor was accepted"
	if int(Rules.payout(swapped, floor).hazard_pay) >= int(bill.hazard_pay):
		return "mislabeling a well crack did not lower hazard pay"
	if int(Rules.payout(swapped, floor).total) > 225:
		return "mislabeling a well crack raised the payout"
	var corridor: Vector2i = Rules.lift_pos(floor)
	var swapped_corridor: Dictionary = truth.duplicate()
	swapped_corridor[corridor] = Rules.Mark.HAZARD
	if Rules.census_accepted(swapped_corridor, floor):
		return "the lift marked as a hazard was accepted"
	if int(Rules.payout(swapped_corridor, floor).total) > 225:
		return "marking the lift as a hazard raised the payout"
	var false_wall: Dictionary = truth.duplicate()
	false_wall[Vector2i(0, 0)] = Rules.Mark.HAZARD
	if Rules.census_accepted(false_wall, floor):
		return "a hazard mark on a wall was accepted"
	if int(Rules.payout(false_wall, floor).total) != 225 or int(Rules.payout(false_wall, floor).hazard_pay) != int(bill.hazard_pay):
		return "a hazard mark on a wall changed the payout"
	var shaft_wall: Dictionary = truth.duplicate()
	shaft_wall[Vector2i(5, 3)] = Rules.Mark.WALL
	if not Rules.census_accepted(shaft_wall, floor):
		return "inking the shaft as a wall rejected a true census"
	shaft_wall[Vector2i(5, 3)] = Rules.Mark.HAZARD
	if Rules.census_accepted(shaft_wall, floor):
		return "calling the shaft a hazard was accepted"
	var warden_mark: Dictionary = truth.duplicate()
	warden_mark[Rules.enemy_pos(floor)] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(warden_mark, floor):
		return "the warden tile was accepted as a corridor"
	if int(Rules.payout(warden_mark, floor).total) != 225:
		return "marking the warden changed the payout"
	var only_ring := {}
	for cell in Rules.loop_cells(floor):
		only_ring[cell] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(only_ring, floor):
		return "the ring alone was accepted as the census"
	var ring_bill: Dictionary = Rules.payout(only_ring, floor)
	if int(ring_bill.loop) != 1 or int(ring_bill.hazards) != 0 or int(ring_bill.total) >= 225:
		return "the ring bonus did not stay inside the shared payout rule"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cellar):
		return "the well house sheet was accepted as the cellar"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cistern):
		return "the well house sheet was accepted as the cistern"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cloister):
		return "the well house sheet was accepted as the cloister"
	if Rules.census_accepted(Rules.accurate_sheet(floor), crypt):
		return "the well house sheet was accepted as the crypt"
	if Rules.census_accepted(Rules.accurate_sheet(floor), ossuary):
		return "the well house sheet was accepted as the ossuary"
	if Rules.census_accepted(Rules.accurate_sheet(floor), reliquary):
		return "the well house sheet was accepted as the reliquary"
	if Rules.census_accepted(Rules.accurate_sheet(floor), undercroft):
		return "the well house sheet was accepted as the undercroft"
	if Rules.census_accepted(Rules.accurate_sheet(cellar), floor):
		return "the cellar sheet was accepted as the well house"
	if Rules.census_accepted(Rules.accurate_sheet(cistern), floor):
		return "the cistern sheet was accepted as the well house"
	if Rules.census_accepted(Rules.accurate_sheet(cloister), floor):
		return "the cloister sheet was accepted as the well house"
	if Rules.census_accepted(Rules.accurate_sheet(crypt), floor):
		return "the crypt sheet was accepted as the well house"
	if Rules.census_accepted(Rules.accurate_sheet(ossuary), floor):
		return "the ossuary sheet was accepted as the well house"
	if Rules.census_accepted(Rules.accurate_sheet(reliquary), floor):
		return "the reliquary sheet was accepted as the well house"
	if Rules.census_accepted(Rules.accurate_sheet(undercroft), floor):
		return "the undercroft sheet was accepted as the well house"
	if not Rules.census_accepted(Rules.accurate_sheet(cellar), cellar):
		return "the cellar's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(cistern), cistern):
		return "the cistern's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(cloister), cloister):
		return "the cloister's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(crypt), crypt):
		return "the crypt's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(ossuary), ossuary):
		return "the ossuary's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(reliquary), reliquary):
		return "the reliquary's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(undercroft), undercroft):
		return "the undercroft's true census was rejected"
	var cellar_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cellar), cellar)
	if int(cellar_bill.total) != 211 or str(cellar_bill.loop_name) != "East square":
		return "the cellar payout changed"
	var cistern_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cistern), cistern)
	if int(cistern_bill.total) != 288 or str(cistern_bill.loop_name) != "Cistern ring":
		return "the cistern payout changed"
	var cloister_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cloister), cloister)
	if int(cloister_bill.total) != 242 or str(cloister_bill.loop_name) != "Cloister walk":
		return "the cloister payout changed"
	var crypt_bill: Dictionary = Rules.payout(Rules.accurate_sheet(crypt), crypt)
	if int(crypt_bill.total) != 316 or str(crypt_bill.loop_name) != "Crypt ring":
		return "the crypt payout changed"
	var ossuary_bill: Dictionary = Rules.payout(Rules.accurate_sheet(ossuary), ossuary)
	if int(ossuary_bill.total) != 240 or str(ossuary_bill.loop_name) != "Ossuary ring":
		return "the ossuary payout changed"
	var reliquary_bill: Dictionary = Rules.payout(Rules.accurate_sheet(reliquary), reliquary)
	if int(reliquary_bill.total) != 251 or str(reliquary_bill.loop_name) != "Reliquary ring":
		return "the reliquary payout changed"
	var undercroft_bill: Dictionary = Rules.payout(Rules.accurate_sheet(undercroft), undercroft)
	if int(undercroft_bill.total) != 238 or str(undercroft_bill.loop_name) != "Undercroft ring":
		return "the undercroft payout changed"
	var approach: Vector2i = Rules.walkable_approach(crack, floor)
	if approach.x < 0:
		return "well crack has no approach"
	var walker = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	walker.pos = approach
	walker.oil = 10
	var before: int = walker.oil
	var stepped: Dictionary = Rules.step(walker, crack - approach)
	if bool(stepped.hit):
		return "opening well step was a swing"
	if walker.oil != before - Rules.MOVE_OIL:
		return "a well crack burned extra oil"
	if int(walker.marks.get(crack, Rules.Mark.NONE)) != Rules.Mark.HAZARD:
		return "a well crack was not inked as a hazard"
	return ""


func _wellhouse_return() -> String:
	var game_script = load("res://scripts/game.gd")
	var select_script = load("res://scripts/floor_select_view.gd")
	if game_script == null or select_script == null:
		return "game or floor select did not load"
	var game = game_script.new()
	root.add_child(game)
	if game.town == null or game.floor_select == null or game.descent == null:
		game.free()
		return "the game did not build its screens"
	if game.floor_select.record_for("wellhouse") != Rules.WELL_RECORD:
		game.free()
		return "floor select does not offer the well house census"
	if game.floor_select.record_for("cellar") != Rules.CELLAR_RECORD:
		game.free()
		return "floor select dropped the cellar census"
	if game.floor_select.record_for("cistern") != Rules.CISTERN_RECORD:
		game.free()
		return "floor select dropped the cistern census"
	if game.floor_select.record_for("cloister") != Rules.CLOISTER_RECORD:
		game.free()
		return "floor select dropped the cloister census"
	if game.floor_select.record_for("crypt") != Rules.CRYPT_RECORD:
		game.free()
		return "floor select dropped the crypt census"
	if game.floor_select.record_for("ossuary") != Rules.OSSUARY_RECORD:
		game.free()
		return "floor select dropped the ossuary census"
	if game.floor_select.record_for("reliquary") != Rules.RELIQUARY_RECORD:
		game.free()
		return "floor select dropped the reliquary census"
	if game.floor_select.record_for("undercroft") != Rules.UNDERCROFT_RECORD:
		game.free()
		return "floor select dropped the undercroft census"
	if game.floor_select.status_for("wellhouse") != "Census open":
		game.free()
		return "the well house card did not open"
	game._on_descend_floor("wellhouse")
	if game.descent.state == null or game.descent.state.floor.id != "wellhouse":
		game.free()
		return "descend did not open the well house"
	var state = game.descent.state
	var lift: Vector2i = Rules.lift_pos(state.floor)
	var approach: Vector2i = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var left: Dictionary = Rules.step(state, lift - approach)
	if not bool(left.extracted):
		game.free()
		return "short well house sheet did not leave on the lift"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to town":
		game.free()
		return "a short sheet offered the floor select"
	game._on_return(state)
	if not game.town.visible or game.floor_select.visible or game.descent.visible:
		game.free()
		return "a short census did not return to town"
	if bool(game.campaign.completed.get("wellhouse", false)):
		game.free()
		return "a short census was accepted"
	if game.town.outcome_label.text.find("not finished") < 0:
		game.free()
		return "the clerk treated a short sheet as finished"
	game._on_floors()
	if not game.floor_select.visible or game.town.visible:
		game.free()
		return "floor select did not open from town"
	game._on_descend_floor("wellhouse")
	state = game.descent.state
	state.marks = Rules.accurate_sheet(state.floor)
	lift = Rules.lift_pos(state.floor)
	approach = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var done: Dictionary = Rules.step(state, lift - approach)
	if not bool(done.extracted) or not Rules.census_accepted(state.marks, state.floor):
		game.free()
		return "the finished sheet did not extract as an accepted census"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to floor select":
		game.free()
		return "a finished census did not offer the floor select"
	game._on_return(state)
	if not game.floor_select.visible or game.town.visible or game.descent.visible:
		game.free()
		return "a finished census did not return to the floor select"
	if not bool(game.campaign.completed.get("wellhouse", false)):
		game.free()
		return "the finished census was not recorded"
	if bool(game.campaign.completed.get("cellar", false)) or bool(game.campaign.completed.get("cistern", false)) or bool(game.campaign.completed.get("cloister", false)) or bool(game.campaign.completed.get("crypt", false)) or bool(game.campaign.completed.get("ossuary", false)) or bool(game.campaign.completed.get("reliquary", false)) or bool(game.campaign.completed.get("undercroft", false)):
		game.free()
		return "another floor was marked complete"
	if game.floor_select.status_for("wellhouse") != "Census complete":
		game.free()
		return "floor select did not show the well house census complete"
	if game.floor_select.status_for("cellar") != "Census open" or game.floor_select.status_for("cistern") != "Census open" or game.floor_select.status_for("cloister") != "Census open" or game.floor_select.status_for("crypt") != "Census open" or game.floor_select.status_for("ossuary") != "Census open" or game.floor_select.status_for("reliquary") != "Census open" or game.floor_select.status_for("undercroft") != "Census open":
		game.free()
		return "another floor card was closed"
	if game.floor_select.notice_label.text.find("complete") < 0:
		game.free()
		return "arrival did not say the census is complete"
	if game.campaign.purse < 225 or game.campaign.last_outcome != "complete":
		game.free()
		return "the finished census was not paid"
	game._show_town()
	if not game.town.visible or game.floor_select.visible:
		game.free()
		return "Back to town did not leave the floor select"
	if game.town.outcome_label.text.find("complete") < 0:
		game.free()
		return "town clerk did not keep the finished census"
	game.free()
	return ""


func _scriptorium_layout() -> String:
	if Rules.CORRIDOR_VALUE != 3 or Rules.HAZARD_VALUE != 8 or Rules.LOOP_VALUE != 15:
		return "payout rates changed"
	if Rules.MOVE_OIL != 1 or Rules.HIT_OIL != 3:
		return "oil costs changed"
	if Rules.SMALL_FLASK_OIL != 24 or Rules.LARGE_FLASK_OIL != 120 or Rules.LARGE_FLASK_COST != 40:
		return "flask sizes changed"
	var floor = Rules.floor_named("scriptorium")
	if floor == null:
		return "scriptorium floor is missing"
	if floor.record != Rules.SCRIPTORIUM_RECORD:
		return "scriptorium record drifted from its constant"
	if Rules.SCRIPTORIUM_RECORD != "Record every corridor, the ten ink cracks, and the scriptorium ring around the desk.":
		return "the scriptorium no longer asks for the ink cracks and the ring"
	var expected := PackedStringArray([
		"##################",
		"#S....############",
		"#####......#######",
		"##..H.DDDD.H######",
		"#...#.DDDD.#######",
		"##..H.DDDD......L#",
		"##..H.DDDD.#######",
		"##..#.DD...#######",
		"##..H.DD.H########",
		"##..#.DD.#########",
		"##..H.DD.H########",
		"#####....#########",
		"#####HEH##########",
		"##################",
	])
	if floor.rows.size() != expected.size():
		return "scriptorium height %d" % floor.rows.size()
	for i in expected.size():
		if str(floor.rows[i]) != str(expected[i]):
			return "scriptorium row %d is %s" % [i, floor.rows[i]]
	if Rules.width(floor) != 18 or Rules.height(floor) != 14:
		return "scriptorium size %dx%d" % [Rules.width(floor), Rules.height(floor)]
	if Rules.start_pos(floor) != Vector2i(1, 1):
		return "start %s" % Rules.start_pos(floor)
	if Rules.lift_pos(floor) != Vector2i(16, 5):
		return "lift %s" % Rules.lift_pos(floor)
	if Rules.enemy_pos(floor) != Vector2i(6, 12):
		return "warden %s" % Rules.enemy_pos(floor)
	var hazards: Array = Rules.hazard_cells(floor)
	var expect_h: Array = [Vector2i(4, 3), Vector2i(11, 3), Vector2i(4, 5), Vector2i(4, 6), Vector2i(4, 8), Vector2i(9, 8), Vector2i(4, 10), Vector2i(9, 10), Vector2i(5, 12), Vector2i(7, 12)]
	if hazards.size() != expect_h.size():
		return "hazard count %d" % hazards.size()
	for i in hazards.size():
		if hazards[i] != expect_h[i]:
			return "hazard %d is %s" % [i, hazards[i]]
	if Rules.corridor_cells(floor).size() != 56:
		return "corridors %d" % Rules.corridor_cells(floor).size()
	if Rules.glyph_at(Vector2i(7, 4), floor) != "D" or Rules.glyph_at(Vector2i(6, 9), floor) != "D":
		return "the desk is not marked on the map"
	if Rules.tile_at(Vector2i(7, 4), floor) != Rules.Tile.WALL or Rules.is_walkable(Vector2i(7, 4), floor):
		return "the desk is not solid wall"
	if Rules.glyph_at(Vector2i(9, 6), floor) != "D" or Rules.glyph_at(Vector2i(8, 8), floor) == "D":
		return "the desk is not the L around the notch"
	var ring_err := _scriptorium_ring(floor)
	if ring_err != "":
		return ring_err
	var well = Rules.floor_named("wellhouse")
	var undercroft = Rules.floor_named("undercroft")
	var reliquary = Rules.floor_named("reliquary")
	if floor.rows == well.rows or floor.rows == undercroft.rows or floor.rows == reliquary.rows:
		return "the scriptorium copies an earlier floor"
	var swings: Array = Rules.swing_tiles(floor)
	if swings.size() != 2 or swings[0] == swings[1]:
		return "the warden should telegraph two distinct tiles"
	for swing in swings:
		if not Rules.is_walkable(swing, floor):
			return "swing tile %s is not walkable" % swing
	if Rules.is_walkable(Rules.enemy_pos(floor), floor):
		return "the warden's own tile is walkable"
	var steps := Rules.shortest_path_steps(floor)
	if steps != 19:
		return "shortest scriptorium path is %d, expected 19" % steps
	if Rules.SMALL_FLASK_OIL - steps < 4:
		return "small flask margin slipped to %d" % (Rules.SMALL_FLASK_OIL - steps)
	var actions: Array = Rules.scripted_safe_actions(floor)
	if actions.is_empty():
		return "no safe exit from the scriptorium"
	var state = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	for i in actions.size():
		var result: Dictionary = Rules.step(state, actions[i])
		if bool(result.hit):
			return "hit on scriptorium exit action %d at %s" % [i, state.pos]
		if state.end_reason != Rules.EndReason.NONE and i != actions.size() - 1:
			return "scriptorium exit ended early at action %d" % i
		if actions[i] != Vector2i.ZERO and not bool(result.moved):
			return "scriptorium exit step %d did not move" % i
	if state.end_reason != Rules.EndReason.EXTRACTED or state.pos != Rules.lift_pos(floor):
		return "scriptorium exit was not an extract at the lift"
	if state.oil != Rules.SMALL_FLASK_OIL - actions.size():
		return "scriptorium exit oil %d after %d actions" % [state.oil, actions.size()]
	var full: int = int(Rules.payout(Rules.accurate_sheet(floor), floor).total)
	var carried: int = int(Rules.payout(state.marks, floor).total)
	if carried <= 0 or carried >= full:
		return "exit sheet paid %d against full %d" % [carried, full]
	if Rules.census_accepted(state.marks, floor):
		return "the exit path was accepted as a finished census"
	var cover := Rules.safe_survey_steps(floor)
	if cover != 108:
		return "safe survey is %d, expected 108" % cover
	if cover > Rules.LARGE_FLASK_OIL or cover <= Rules.SMALL_FLASK_OIL:
		return "survey oil %d does not sit between the flasks" % cover
	print("  scriptorium shortest %d  survey %d  exit pay %d  full %d" % [steps, cover, carried, full])
	return ""


func _scriptorium_ring(floor) -> String:
	var cells: Array = Rules.loop_cells(floor)
	if cells.size() != 28:
		return "ring size %d" % cells.size()
	var have := {}
	for cell in cells:
		if have.has(cell):
			return "duplicate ring tile %s" % cell
		have[cell] = true
		if not Rules.is_corridor_cell(cell, floor):
			return "ring tile %s is not a corridor" % cell
	for cell in cells:
		var degree := 0
		for dir in Rules.cardinals():
			if have.has(cell + dir):
				degree += 1
		if degree != 2:
			return "ring tile %s has %d neighbors in the ring" % [cell, degree]
	if not have.has(Vector2i(7, 2)) or have.has(Vector2i(7, 3)):
		return "the ring does not rim the desk"
	if not have.has(Vector2i(9, 7)) or have.has(Vector2i(9, 6)):
		return "the ring does not turn the inner corner of the desk"
	var desks := 0
	for y in Rules.height(floor):
		for x in Rules.width(floor):
			var p := Vector2i(x, y)
			if Rules.glyph_at(p, floor) != "D":
				continue
			desks += 1
			for dir in Rules.cardinals():
				var n: Vector2i = p + dir
				if Rules.is_corridor_cell(n, floor) and not have.has(n):
					return "corridor %s touches the desk and is outside the ring" % n
	if desks != 24:
		return "desk size %d" % desks
	if str(floor.loop_name) != "Scriptorium ring":
		return "ring name is %s" % floor.loop_name
	return ""


func _scriptorium_census() -> String:
	var floor = Rules.floor_named("scriptorium")
	var cellar = Rules.floor_named("cellar")
	var cistern = Rules.floor_named("cistern")
	var cloister = Rules.floor_named("cloister")
	var crypt = Rules.floor_named("crypt")
	var ossuary = Rules.floor_named("ossuary")
	var reliquary = Rules.floor_named("reliquary")
	var undercroft = Rules.floor_named("undercroft")
	var wellhouse = Rules.floor_named("wellhouse")
	var truth: Dictionary = Rules.accurate_sheet(floor)
	if not Rules.census_accepted(truth, floor):
		return "the true scriptorium census was rejected"
	var bill: Dictionary = Rules.payout(truth, floor)
	if int(bill.corridors) != 56 or int(bill.hazards) != 10 or int(bill.loop) != 1:
		return "true counts %s/%s loop %s" % [bill.corridors, bill.hazards, bill.loop]
	if int(bill.corridor_pay) != 56 * Rules.CORRIDOR_VALUE:
		return "corridor pay drifted"
	if int(bill.hazard_pay) != 10 * Rules.HAZARD_VALUE:
		return "hazard pay drifted"
	if int(bill.loop_pay) != Rules.LOOP_VALUE:
		return "ring pay drifted"
	if int(bill.total) != 263:
		return "true total %s" % bill.total
	if Rules.format_bill(bill).find("Scriptorium ring") < 0:
		return "the receipt did not name the scriptorium ring"
	if Rules.census_accepted({}, floor):
		return "an empty sheet was accepted"
	if int(Rules.payout({}, floor).total) != 0:
		return "an empty sheet paid out"
	var missing_corridor: Dictionary = truth.duplicate()
	missing_corridor.erase(Rules.start_pos(floor))
	if Rules.census_accepted(missing_corridor, floor):
		return "a sheet missing the start corridor was accepted"
	var missing_bill: Dictionary = Rules.payout(missing_corridor, floor)
	if int(missing_bill.total) >= 263 or int(missing_bill.loop) != 1:
		return "dropping a corridor outside the ring changed the census the wrong way"
	var crack: Vector2i = Rules.hazard_cells(floor)[0]
	var missing_crack: Dictionary = truth.duplicate()
	missing_crack.erase(crack)
	if Rules.census_accepted(missing_crack, floor):
		return "a sheet missing an ink crack was accepted"
	if int(Rules.payout(missing_crack, floor).total) >= 263:
		return "dropping an ink crack did not lower pay"
	var broken_ring: Dictionary = truth.duplicate()
	var rim: Vector2i = Rules.loop_cells(floor)[0]
	broken_ring[rim] = Rules.Mark.WALL
	if Rules.census_accepted(broken_ring, floor):
		return "a broken ring was accepted"
	var broken_bill: Dictionary = Rules.payout(broken_ring, floor)
	if int(broken_bill.loop) != 0 or int(broken_bill.total) >= 263:
		return "a broken ring still paid as a finished sheet"
	var swapped: Dictionary = truth.duplicate()
	swapped[crack] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(swapped, floor):
		return "an ink crack marked as a corridor was accepted"
	if int(Rules.payout(swapped, floor).hazard_pay) >= int(bill.hazard_pay):
		return "mislabeling an ink crack did not lower hazard pay"
	if int(Rules.payout(swapped, floor).total) > 263:
		return "mislabeling an ink crack raised the payout"
	var corridor: Vector2i = Rules.lift_pos(floor)
	var swapped_corridor: Dictionary = truth.duplicate()
	swapped_corridor[corridor] = Rules.Mark.HAZARD
	if Rules.census_accepted(swapped_corridor, floor):
		return "the lift marked as a hazard was accepted"
	if int(Rules.payout(swapped_corridor, floor).total) > 263:
		return "marking the lift as a hazard raised the payout"
	var false_wall: Dictionary = truth.duplicate()
	false_wall[Vector2i(0, 0)] = Rules.Mark.HAZARD
	if Rules.census_accepted(false_wall, floor):
		return "a hazard mark on a wall was accepted"
	if int(Rules.payout(false_wall, floor).total) != 263 or int(Rules.payout(false_wall, floor).hazard_pay) != int(bill.hazard_pay):
		return "a hazard mark on a wall changed the payout"
	var desk_wall: Dictionary = truth.duplicate()
	desk_wall[Vector2i(6, 3)] = Rules.Mark.WALL
	if not Rules.census_accepted(desk_wall, floor):
		return "inking the desk as a wall rejected a true census"
	desk_wall[Vector2i(6, 3)] = Rules.Mark.HAZARD
	if Rules.census_accepted(desk_wall, floor):
		return "calling the desk a hazard was accepted"
	var warden_mark: Dictionary = truth.duplicate()
	warden_mark[Rules.enemy_pos(floor)] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(warden_mark, floor):
		return "the warden tile was accepted as a corridor"
	if int(Rules.payout(warden_mark, floor).total) != 263:
		return "marking the warden changed the payout"
	var only_ring := {}
	for cell in Rules.loop_cells(floor):
		only_ring[cell] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(only_ring, floor):
		return "the ring alone was accepted as the census"
	var ring_bill: Dictionary = Rules.payout(only_ring, floor)
	if int(ring_bill.loop) != 1 or int(ring_bill.hazards) != 0 or int(ring_bill.total) >= 263:
		return "the ring bonus did not stay inside the shared payout rule"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cellar):
		return "the scriptorium sheet was accepted as the cellar"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cistern):
		return "the scriptorium sheet was accepted as the cistern"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cloister):
		return "the scriptorium sheet was accepted as the cloister"
	if Rules.census_accepted(Rules.accurate_sheet(floor), crypt):
		return "the scriptorium sheet was accepted as the crypt"
	if Rules.census_accepted(Rules.accurate_sheet(floor), ossuary):
		return "the scriptorium sheet was accepted as the ossuary"
	if Rules.census_accepted(Rules.accurate_sheet(floor), reliquary):
		return "the scriptorium sheet was accepted as the reliquary"
	if Rules.census_accepted(Rules.accurate_sheet(floor), undercroft):
		return "the scriptorium sheet was accepted as the undercroft"
	if Rules.census_accepted(Rules.accurate_sheet(floor), wellhouse):
		return "the scriptorium sheet was accepted as the well house"
	if Rules.census_accepted(Rules.accurate_sheet(cellar), floor):
		return "the cellar sheet was accepted as the scriptorium"
	if Rules.census_accepted(Rules.accurate_sheet(cistern), floor):
		return "the cistern sheet was accepted as the scriptorium"
	if Rules.census_accepted(Rules.accurate_sheet(cloister), floor):
		return "the cloister sheet was accepted as the scriptorium"
	if Rules.census_accepted(Rules.accurate_sheet(crypt), floor):
		return "the crypt sheet was accepted as the scriptorium"
	if Rules.census_accepted(Rules.accurate_sheet(ossuary), floor):
		return "the ossuary sheet was accepted as the scriptorium"
	if Rules.census_accepted(Rules.accurate_sheet(reliquary), floor):
		return "the reliquary sheet was accepted as the scriptorium"
	if Rules.census_accepted(Rules.accurate_sheet(undercroft), floor):
		return "the undercroft sheet was accepted as the scriptorium"
	if Rules.census_accepted(Rules.accurate_sheet(wellhouse), floor):
		return "the well house sheet was accepted as the scriptorium"
	if not Rules.census_accepted(Rules.accurate_sheet(cellar), cellar):
		return "the cellar's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(cistern), cistern):
		return "the cistern's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(cloister), cloister):
		return "the cloister's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(crypt), crypt):
		return "the crypt's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(ossuary), ossuary):
		return "the ossuary's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(reliquary), reliquary):
		return "the reliquary's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(undercroft), undercroft):
		return "the undercroft's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(wellhouse), wellhouse):
		return "the well house's true census was rejected"
	var cellar_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cellar), cellar)
	if int(cellar_bill.total) != 211 or str(cellar_bill.loop_name) != "East square":
		return "the cellar payout changed"
	var cistern_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cistern), cistern)
	if int(cistern_bill.total) != 288 or str(cistern_bill.loop_name) != "Cistern ring":
		return "the cistern payout changed"
	var cloister_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cloister), cloister)
	if int(cloister_bill.total) != 242 or str(cloister_bill.loop_name) != "Cloister walk":
		return "the cloister payout changed"
	var crypt_bill: Dictionary = Rules.payout(Rules.accurate_sheet(crypt), crypt)
	if int(crypt_bill.total) != 316 or str(crypt_bill.loop_name) != "Crypt ring":
		return "the crypt payout changed"
	var ossuary_bill: Dictionary = Rules.payout(Rules.accurate_sheet(ossuary), ossuary)
	if int(ossuary_bill.total) != 240 or str(ossuary_bill.loop_name) != "Ossuary ring":
		return "the ossuary payout changed"
	var reliquary_bill: Dictionary = Rules.payout(Rules.accurate_sheet(reliquary), reliquary)
	if int(reliquary_bill.total) != 251 or str(reliquary_bill.loop_name) != "Reliquary ring":
		return "the reliquary payout changed"
	var undercroft_bill: Dictionary = Rules.payout(Rules.accurate_sheet(undercroft), undercroft)
	if int(undercroft_bill.total) != 238 or str(undercroft_bill.loop_name) != "Undercroft ring":
		return "the undercroft payout changed"
	var well_bill: Dictionary = Rules.payout(Rules.accurate_sheet(wellhouse), wellhouse)
	if int(well_bill.total) != 225 or str(well_bill.loop_name) != "Well ring":
		return "the well house payout changed"
	var approach: Vector2i = Rules.walkable_approach(crack, floor)
	if approach.x < 0:
		return "ink crack has no approach"
	var walker = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	walker.pos = approach
	walker.oil = 10
	var before: int = walker.oil
	var stepped: Dictionary = Rules.step(walker, crack - approach)
	if bool(stepped.hit):
		return "opening ink step was a swing"
	if walker.oil != before - Rules.MOVE_OIL:
		return "an ink crack burned extra oil"
	if int(walker.marks.get(crack, Rules.Mark.NONE)) != Rules.Mark.HAZARD:
		return "an ink crack was not inked as a hazard"
	return ""


func _scriptorium_return() -> String:
	var game_script = load("res://scripts/game.gd")
	var select_script = load("res://scripts/floor_select_view.gd")
	if game_script == null or select_script == null:
		return "game or floor select did not load"
	var game = game_script.new()
	root.add_child(game)
	if game.town == null or game.floor_select == null or game.descent == null:
		game.free()
		return "the game did not build its screens"
	if game.floor_select.record_for("scriptorium") != Rules.SCRIPTORIUM_RECORD:
		game.free()
		return "floor select does not offer the scriptorium census"
	if game.floor_select.record_for("cellar") != Rules.CELLAR_RECORD:
		game.free()
		return "floor select dropped the cellar census"
	if game.floor_select.record_for("cistern") != Rules.CISTERN_RECORD:
		game.free()
		return "floor select dropped the cistern census"
	if game.floor_select.record_for("cloister") != Rules.CLOISTER_RECORD:
		game.free()
		return "floor select dropped the cloister census"
	if game.floor_select.record_for("crypt") != Rules.CRYPT_RECORD:
		game.free()
		return "floor select dropped the crypt census"
	if game.floor_select.record_for("ossuary") != Rules.OSSUARY_RECORD:
		game.free()
		return "floor select dropped the ossuary census"
	if game.floor_select.record_for("reliquary") != Rules.RELIQUARY_RECORD:
		game.free()
		return "floor select dropped the reliquary census"
	if game.floor_select.record_for("undercroft") != Rules.UNDERCROFT_RECORD:
		game.free()
		return "floor select dropped the undercroft census"
	if game.floor_select.record_for("wellhouse") != Rules.WELL_RECORD:
		game.free()
		return "floor select dropped the well house census"
	if game.floor_select.status_for("scriptorium") != "Census open":
		game.free()
		return "the scriptorium card did not open"
	game._on_descend_floor("scriptorium")
	if game.descent.state == null or game.descent.state.floor.id != "scriptorium":
		game.free()
		return "descend did not open the scriptorium"
	var state = game.descent.state
	var lift: Vector2i = Rules.lift_pos(state.floor)
	var approach: Vector2i = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var left: Dictionary = Rules.step(state, lift - approach)
	if not bool(left.extracted):
		game.free()
		return "short scriptorium sheet did not leave on the lift"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to town":
		game.free()
		return "a short sheet offered the floor select"
	game._on_return(state)
	if not game.town.visible or game.floor_select.visible or game.descent.visible:
		game.free()
		return "a short census did not return to town"
	if bool(game.campaign.completed.get("scriptorium", false)):
		game.free()
		return "a short census was accepted"
	if game.town.outcome_label.text.find("not finished") < 0:
		game.free()
		return "the clerk treated a short sheet as finished"
	game._on_floors()
	if not game.floor_select.visible or game.town.visible:
		game.free()
		return "floor select did not open from town"
	game._on_descend_floor("scriptorium")
	state = game.descent.state
	state.marks = Rules.accurate_sheet(state.floor)
	lift = Rules.lift_pos(state.floor)
	approach = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var done: Dictionary = Rules.step(state, lift - approach)
	if not bool(done.extracted) or not Rules.census_accepted(state.marks, state.floor):
		game.free()
		return "the finished sheet did not extract as an accepted census"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to floor select":
		game.free()
		return "a finished census did not offer the floor select"
	game._on_return(state)
	if not game.floor_select.visible or game.town.visible or game.descent.visible:
		game.free()
		return "a finished census did not return to the floor select"
	if not bool(game.campaign.completed.get("scriptorium", false)):
		game.free()
		return "the finished census was not recorded"
	if bool(game.campaign.completed.get("cellar", false)) or bool(game.campaign.completed.get("cistern", false)) or bool(game.campaign.completed.get("cloister", false)) or bool(game.campaign.completed.get("crypt", false)) or bool(game.campaign.completed.get("ossuary", false)) or bool(game.campaign.completed.get("reliquary", false)) or bool(game.campaign.completed.get("undercroft", false)) or bool(game.campaign.completed.get("wellhouse", false)):
		game.free()
		return "another floor was marked complete"
	if game.floor_select.status_for("scriptorium") != "Census complete":
		game.free()
		return "floor select did not show the scriptorium census complete"
	if game.floor_select.status_for("cellar") != "Census open" or game.floor_select.status_for("cistern") != "Census open" or game.floor_select.status_for("cloister") != "Census open" or game.floor_select.status_for("crypt") != "Census open" or game.floor_select.status_for("ossuary") != "Census open" or game.floor_select.status_for("reliquary") != "Census open" or game.floor_select.status_for("undercroft") != "Census open" or game.floor_select.status_for("wellhouse") != "Census open":
		game.free()
		return "another floor card was closed"
	if game.floor_select.notice_label.text.find("complete") < 0:
		game.free()
		return "arrival did not say the census is complete"
	if game.campaign.purse < 263 or game.campaign.last_outcome != "complete":
		game.free()
		return "the finished census was not paid"
	game._show_town()
	if not game.town.visible or game.floor_select.visible:
		game.free()
		return "Back to town did not leave the floor select"
	if game.town.outcome_label.text.find("complete") < 0:
		game.free()
		return "town clerk did not keep the finished census"
	game.free()
	return ""


func _binding_layout() -> String:
	if Rules.CORRIDOR_VALUE != 3 or Rules.HAZARD_VALUE != 8 or Rules.LOOP_VALUE != 15:
		return "payout rates changed"
	if Rules.MOVE_OIL != 1 or Rules.HIT_OIL != 3:
		return "oil costs changed"
	if Rules.SMALL_FLASK_OIL != 24 or Rules.LARGE_FLASK_OIL != 120 or Rules.LARGE_FLASK_COST != 40:
		return "flask sizes changed"
	var floor = Rules.floor_named("binding")
	if floor == null:
		return "binding floor is missing"
	if floor.record != Rules.BINDING_RECORD:
		return "binding record drifted from its constant"
	if Rules.BINDING_RECORD != "Record every corridor, the eleven glue cracks, and the binding ring around the press.":
		return "the binding no longer asks for the glue cracks and the ring"
	var expected := PackedStringArray([
		"################",
		"#S.............#",
		"#.#......#####.#",
		"#.#..PPP.#####.#",
		"#.#..PPP.#####.#",
		"#....PPP.#####.#",
		"#.#..PPP.#####.#",
		"#.#..PPP.#####L#",
		"#.#......#####.#",
		"#.#..H..H..###.#",
		"#..E..H..H..#..#",
		"#H.H.H.H.H.H.H##",
		"################",
	])
	if floor.rows.size() != expected.size():
		return "binding height %d" % floor.rows.size()
	for i in expected.size():
		if str(floor.rows[i]) != str(expected[i]):
			return "binding row %d is %s" % [i, floor.rows[i]]
	if Rules.width(floor) != 16 or Rules.height(floor) != 13:
		return "binding size %dx%d" % [Rules.width(floor), Rules.height(floor)]
	if Rules.start_pos(floor) != Vector2i(1, 1):
		return "start %s" % Rules.start_pos(floor)
	if Rules.lift_pos(floor) != Vector2i(14, 7):
		return "lift %s" % Rules.lift_pos(floor)
	if Rules.enemy_pos(floor) != Vector2i(3, 10):
		return "warden %s" % Rules.enemy_pos(floor)
	if Rules.enemy_pos(floor) == Vector2i(6, 12):
		return "the warden reuses the scriptorium cell"
	if Rules.is_corridor_cell(Rules.enemy_pos(floor), floor):
		return "the warden tile counts as a corridor"
	var hazards: Array = Rules.hazard_cells(floor)
	var expect_h: Array = [Vector2i(5, 9), Vector2i(8, 9), Vector2i(6, 10), Vector2i(9, 10), Vector2i(1, 11), Vector2i(3, 11), Vector2i(5, 11), Vector2i(7, 11), Vector2i(9, 11), Vector2i(11, 11), Vector2i(13, 11)]
	if hazards.size() != 11:
		return "hazard count %d" % hazards.size()
	for i in hazards.size():
		if hazards[i] != expect_h[i]:
			return "hazard %d is %s" % [i, hazards[i]]
	if Rules.corridor_cells(floor).size() != 80:
		return "corridors %d" % Rules.corridor_cells(floor).size()
	var presses := 0
	for y in range(3, 8):
		for x in range(5, 8):
			if Rules.glyph_at(Vector2i(x, y), floor) != "P":
				return "press cell %s is not iron" % Vector2i(x, y)
			presses += 1
	if presses != 15:
		return "press size %d" % presses
	if Rules.glyph_at(Vector2i(6, 5), floor) != "P" or Rules.glyph_at(Vector2i(5, 3), floor) != "P" or Rules.glyph_at(Vector2i(7, 7), floor) != "P":
		return "the press is not marked on the map"
	if Rules.tile_at(Vector2i(6, 5), floor) != Rules.Tile.WALL or Rules.is_walkable(Vector2i(6, 5), floor):
		return "the press is not solid wall"
	if Rules.glyph_at(Vector2i(4, 5), floor) == "P" or Rules.glyph_at(Vector2i(8, 5), floor) == "P" or Rules.glyph_at(Vector2i(6, 8), floor) == "P":
		return "the press is not a solid 3x5 rectangle"
	var ring_err := _binding_ring(floor)
	if ring_err != "":
		return ring_err
	var scriptorium = Rules.floor_named("scriptorium")
	var well = Rules.floor_named("wellhouse")
	var undercroft = Rules.floor_named("undercroft")
	if floor.rows == scriptorium.rows or floor.rows == well.rows or floor.rows == undercroft.rows:
		return "the binding copies an earlier floor"
	if Rules.loop_cells(floor).size() == Rules.loop_cells(scriptorium).size() and Rules.enemy_pos(floor) == Rules.enemy_pos(scriptorium):
		return "the binding reuses the scriptorium ring and warden"
	var swings: Array = Rules.swing_tiles(floor)
	if swings.size() != 2 or swings[0] == swings[1]:
		return "the warden should telegraph two distinct tiles"
	for swing in swings:
		if not Rules.is_walkable(swing, floor):
			return "swing tile %s is not walkable" % swing
	if Rules.is_walkable(Rules.enemy_pos(floor), floor):
		return "the warden's own tile is walkable"
	var steps := Rules.shortest_path_steps(floor)
	if steps != 19:
		return "shortest binding path is %d, expected 19" % steps
	if Rules.SMALL_FLASK_OIL - steps != 5:
		return "small flask margin is %d, expected 5" % (Rules.SMALL_FLASK_OIL - steps)
	var actions: Array = Rules.scripted_safe_actions(floor)
	if actions.is_empty():
		return "no safe exit from the binding"
	var state = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	for i in actions.size():
		var result: Dictionary = Rules.step(state, actions[i])
		if bool(result.hit):
			return "hit on binding exit action %d at %s" % [i, state.pos]
		if state.end_reason != Rules.EndReason.NONE and i != actions.size() - 1:
			return "binding exit ended early at action %d" % i
		if actions[i] != Vector2i.ZERO and not bool(result.moved):
			return "binding exit step %d did not move" % i
	if state.end_reason != Rules.EndReason.EXTRACTED or state.pos != Rules.lift_pos(floor):
		return "binding exit was not an extract at the lift"
	if state.oil != Rules.SMALL_FLASK_OIL - actions.size():
		return "binding exit oil %d after %d actions" % [state.oil, actions.size()]
	var full: int = int(Rules.payout(Rules.accurate_sheet(floor), floor).total)
	var carried: int = int(Rules.payout(state.marks, floor).total)
	if carried <= 0 or carried >= full:
		return "exit sheet paid %d against full %d" % [carried, full]
	if Rules.census_accepted(state.marks, floor):
		return "the exit path was accepted as a finished census"
	var cover := Rules.safe_survey_steps(floor)
	if cover != 114:
		return "safe survey is %d, expected 114" % cover
	if cover < 100 or cover > 116:
		return "survey oil %d is outside 100 to 116" % cover
	if cover > Rules.LARGE_FLASK_OIL or cover <= Rules.SMALL_FLASK_OIL:
		return "survey oil %d does not sit between the flasks" % cover
	var expected_pay := Rules.corridor_cells(floor).size() * Rules.CORRIDOR_VALUE + 11 * Rules.HAZARD_VALUE + Rules.LOOP_VALUE
	if full != expected_pay or full != 343:
		return "full pay %d does not match 3 x corridors + 8 x 11 + 15" % full
	print("  binding shortest %d  survey %d  exit pay %d  full %d" % [steps, cover, carried, full])
	return ""


func _binding_ring(floor) -> String:
	var cells: Array = Rules.loop_cells(floor)
	if cells.size() != 20:
		return "ring size %d" % cells.size()
	var have := {}
	for cell in cells:
		if have.has(cell):
			return "duplicate ring tile %s" % cell
		have[cell] = true
		if not Rules.is_corridor_cell(cell, floor):
			return "ring tile %s is not a corridor" % cell
	for cell in cells:
		var degree := 0
		for dir in Rules.cardinals():
			if have.has(cell + dir):
				degree += 1
		if degree != 2:
			return "ring tile %s has %d neighbors in the ring" % [cell, degree]
	if not have.has(Vector2i(6, 2)) or have.has(Vector2i(6, 3)):
		return "the ring does not rim the press"
	if have.has(Vector2i(6, 12)) or have.has(Vector2i(6, 5)):
		return "the ring is not the rectangle around the press"
	var expect: Array = []
	for x in range(4, 9):
		expect.append(Vector2i(x, 2))
	for y in range(3, 8):
		expect.append(Vector2i(4, y))
		expect.append(Vector2i(8, y))
	for x in range(4, 9):
		expect.append(Vector2i(x, 8))
	if cells.size() != expect.size():
		return "ring listing size %d" % cells.size()
	for cell in expect:
		if not have.has(cell):
			return "ring is missing %s" % cell
	var presses := 0
	for y in Rules.height(floor):
		for x in Rules.width(floor):
			var p := Vector2i(x, y)
			if Rules.glyph_at(p, floor) != "P":
				continue
			presses += 1
			for dir in Rules.cardinals():
				var n: Vector2i = p + dir
				if Rules.is_corridor_cell(n, floor) and not have.has(n):
					return "corridor %s touches the press and is outside the ring" % n
	if presses != 15:
		return "press size %d" % presses
	if str(floor.loop_name) != "Binding ring":
		return "ring name is %s" % floor.loop_name
	return ""


func _binding_census() -> String:
	var floor = Rules.floor_named("binding")
	var cellar = Rules.floor_named("cellar")
	var cistern = Rules.floor_named("cistern")
	var cloister = Rules.floor_named("cloister")
	var crypt = Rules.floor_named("crypt")
	var ossuary = Rules.floor_named("ossuary")
	var reliquary = Rules.floor_named("reliquary")
	var undercroft = Rules.floor_named("undercroft")
	var wellhouse = Rules.floor_named("wellhouse")
	var scriptorium = Rules.floor_named("scriptorium")
	var truth: Dictionary = Rules.accurate_sheet(floor)
	if not Rules.census_accepted(truth, floor):
		return "the true binding census was rejected"
	var bill: Dictionary = Rules.payout(truth, floor)
	if int(bill.corridors) != 80 or int(bill.hazards) != 11 or int(bill.loop) != 1:
		return "true counts %s/%s loop %s" % [bill.corridors, bill.hazards, bill.loop]
	if int(bill.corridor_pay) != 80 * Rules.CORRIDOR_VALUE:
		return "corridor pay drifted"
	if int(bill.hazard_pay) != 11 * Rules.HAZARD_VALUE:
		return "hazard pay drifted"
	if int(bill.loop_pay) != Rules.LOOP_VALUE:
		return "ring pay drifted"
	var arithmetic := 80 * 3 + 11 * 8 + 15
	if int(bill.total) != arithmetic or int(bill.total) != 343:
		return "true total %s, expected %s" % [bill.total, arithmetic]
	if Rules.format_bill(bill).find("Binding ring") < 0:
		return "the receipt did not name the binding ring"
	if Rules.census_accepted({}, floor):
		return "an empty sheet was accepted"
	if int(Rules.payout({}, floor).total) != 0:
		return "an empty sheet paid out"
	var missing_corridor: Dictionary = truth.duplicate()
	missing_corridor.erase(Rules.start_pos(floor))
	if Rules.census_accepted(missing_corridor, floor):
		return "a sheet missing the start corridor was accepted"
	var missing_bill: Dictionary = Rules.payout(missing_corridor, floor)
	if int(missing_bill.total) >= 343 or int(missing_bill.loop) != 1:
		return "dropping a corridor outside the ring changed the census the wrong way"
	var crack: Vector2i = Rules.hazard_cells(floor)[0]
	var missing_crack: Dictionary = truth.duplicate()
	missing_crack.erase(crack)
	if Rules.census_accepted(missing_crack, floor):
		return "a sheet missing a glue crack was accepted"
	if int(Rules.payout(missing_crack, floor).total) >= 343:
		return "dropping a glue crack did not lower pay"
	var broken_ring: Dictionary = truth.duplicate()
	var rim: Vector2i = Rules.loop_cells(floor)[0]
	broken_ring[rim] = Rules.Mark.WALL
	if Rules.census_accepted(broken_ring, floor):
		return "a broken ring was accepted"
	var broken_bill: Dictionary = Rules.payout(broken_ring, floor)
	if int(broken_bill.loop) != 0 or int(broken_bill.total) >= 343:
		return "a broken ring still paid as a finished sheet"
	var swapped: Dictionary = truth.duplicate()
	swapped[crack] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(swapped, floor):
		return "a glue crack marked as a corridor was accepted"
	if int(Rules.payout(swapped, floor).hazard_pay) >= int(bill.hazard_pay):
		return "mislabeling a glue crack did not lower hazard pay"
	if int(Rules.payout(swapped, floor).total) > 343:
		return "mislabeling a glue crack raised the payout"
	var corridor: Vector2i = Rules.lift_pos(floor)
	var swapped_corridor: Dictionary = truth.duplicate()
	swapped_corridor[corridor] = Rules.Mark.HAZARD
	if Rules.census_accepted(swapped_corridor, floor):
		return "the lift marked as a hazard was accepted"
	if int(Rules.payout(swapped_corridor, floor).total) > 343:
		return "marking the lift as a hazard raised the payout"
	var false_wall: Dictionary = truth.duplicate()
	false_wall[Vector2i(0, 0)] = Rules.Mark.HAZARD
	if Rules.census_accepted(false_wall, floor):
		return "a hazard mark on a wall was accepted"
	if int(Rules.payout(false_wall, floor).total) != 343 or int(Rules.payout(false_wall, floor).hazard_pay) != int(bill.hazard_pay):
		return "a hazard mark on a wall changed the payout"
	var press_wall: Dictionary = truth.duplicate()
	press_wall[Vector2i(5, 3)] = Rules.Mark.WALL
	if not Rules.census_accepted(press_wall, floor):
		return "inking the press as a wall rejected a true census"
	press_wall[Vector2i(5, 3)] = Rules.Mark.HAZARD
	if Rules.census_accepted(press_wall, floor):
		return "calling the press a hazard was accepted"
	var warden_mark: Dictionary = truth.duplicate()
	warden_mark[Rules.enemy_pos(floor)] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(warden_mark, floor):
		return "the warden tile was accepted as a corridor"
	if int(Rules.payout(warden_mark, floor).total) != 343:
		return "marking the warden changed the payout"
	var only_ring := {}
	for cell in Rules.loop_cells(floor):
		only_ring[cell] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(only_ring, floor):
		return "the ring alone was accepted as the census"
	var ring_bill: Dictionary = Rules.payout(only_ring, floor)
	if int(ring_bill.loop) != 1 or int(ring_bill.hazards) != 0 or int(ring_bill.total) >= 343:
		return "the ring bonus did not stay inside the shared payout rule"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cellar):
		return "the binding sheet was accepted as the cellar"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cistern):
		return "the binding sheet was accepted as the cistern"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cloister):
		return "the binding sheet was accepted as the cloister"
	if Rules.census_accepted(Rules.accurate_sheet(floor), crypt):
		return "the binding sheet was accepted as the crypt"
	if Rules.census_accepted(Rules.accurate_sheet(floor), ossuary):
		return "the binding sheet was accepted as the ossuary"
	if Rules.census_accepted(Rules.accurate_sheet(floor), reliquary):
		return "the binding sheet was accepted as the reliquary"
	if Rules.census_accepted(Rules.accurate_sheet(floor), undercroft):
		return "the binding sheet was accepted as the undercroft"
	if Rules.census_accepted(Rules.accurate_sheet(floor), wellhouse):
		return "the binding sheet was accepted as the well house"
	if Rules.census_accepted(Rules.accurate_sheet(floor), scriptorium):
		return "the binding sheet was accepted as the scriptorium"
	if Rules.census_accepted(Rules.accurate_sheet(cellar), floor):
		return "the cellar sheet was accepted as the binding"
	if Rules.census_accepted(Rules.accurate_sheet(cistern), floor):
		return "the cistern sheet was accepted as the binding"
	if Rules.census_accepted(Rules.accurate_sheet(cloister), floor):
		return "the cloister sheet was accepted as the binding"
	if Rules.census_accepted(Rules.accurate_sheet(crypt), floor):
		return "the crypt sheet was accepted as the binding"
	if Rules.census_accepted(Rules.accurate_sheet(ossuary), floor):
		return "the ossuary sheet was accepted as the binding"
	if Rules.census_accepted(Rules.accurate_sheet(reliquary), floor):
		return "the reliquary sheet was accepted as the binding"
	if Rules.census_accepted(Rules.accurate_sheet(undercroft), floor):
		return "the undercroft sheet was accepted as the binding"
	if Rules.census_accepted(Rules.accurate_sheet(wellhouse), floor):
		return "the well house sheet was accepted as the binding"
	if Rules.census_accepted(Rules.accurate_sheet(scriptorium), floor):
		return "the scriptorium sheet was accepted as the binding"
	if not Rules.census_accepted(Rules.accurate_sheet(cellar), cellar):
		return "the cellar's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(cistern), cistern):
		return "the cistern's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(cloister), cloister):
		return "the cloister's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(crypt), crypt):
		return "the crypt's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(ossuary), ossuary):
		return "the ossuary's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(reliquary), reliquary):
		return "the reliquary's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(undercroft), undercroft):
		return "the undercroft's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(wellhouse), wellhouse):
		return "the well house's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(scriptorium), scriptorium):
		return "the scriptorium's true census was rejected"
	var cellar_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cellar), cellar)
	if int(cellar_bill.total) != 211 or str(cellar_bill.loop_name) != "East square":
		return "the cellar payout changed"
	var cistern_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cistern), cistern)
	if int(cistern_bill.total) != 288 or str(cistern_bill.loop_name) != "Cistern ring":
		return "the cistern payout changed"
	var cloister_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cloister), cloister)
	if int(cloister_bill.total) != 242 or str(cloister_bill.loop_name) != "Cloister walk":
		return "the cloister payout changed"
	var crypt_bill: Dictionary = Rules.payout(Rules.accurate_sheet(crypt), crypt)
	if int(crypt_bill.total) != 316 or str(crypt_bill.loop_name) != "Crypt ring":
		return "the crypt payout changed"
	var ossuary_bill: Dictionary = Rules.payout(Rules.accurate_sheet(ossuary), ossuary)
	if int(ossuary_bill.total) != 240 or str(ossuary_bill.loop_name) != "Ossuary ring":
		return "the ossuary payout changed"
	var reliquary_bill: Dictionary = Rules.payout(Rules.accurate_sheet(reliquary), reliquary)
	if int(reliquary_bill.total) != 251 or str(reliquary_bill.loop_name) != "Reliquary ring":
		return "the reliquary payout changed"
	var undercroft_bill: Dictionary = Rules.payout(Rules.accurate_sheet(undercroft), undercroft)
	if int(undercroft_bill.total) != 238 or str(undercroft_bill.loop_name) != "Undercroft ring":
		return "the undercroft payout changed"
	var well_bill: Dictionary = Rules.payout(Rules.accurate_sheet(wellhouse), wellhouse)
	if int(well_bill.total) != 225 or str(well_bill.loop_name) != "Well ring":
		return "the well house payout changed"
	var scriptorium_bill: Dictionary = Rules.payout(Rules.accurate_sheet(scriptorium), scriptorium)
	if int(scriptorium_bill.total) != 263 or str(scriptorium_bill.loop_name) != "Scriptorium ring":
		return "the scriptorium payout changed"
	var approach: Vector2i = Rules.walkable_approach(crack, floor)
	if approach.x < 0:
		return "glue crack has no approach"
	var walker = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	walker.pos = approach
	walker.oil = 10
	var before: int = walker.oil
	var stepped: Dictionary = Rules.step(walker, crack - approach)
	if bool(stepped.hit):
		return "opening glue step was a swing"
	if walker.oil != before - Rules.MOVE_OIL:
		return "a glue crack burned extra oil"
	if int(walker.marks.get(crack, Rules.Mark.NONE)) != Rules.Mark.HAZARD:
		return "a glue crack was not inked as a hazard"
	return ""


func _binding_return() -> String:
	var game_script = load("res://scripts/game.gd")
	var select_script = load("res://scripts/floor_select_view.gd")
	if game_script == null or select_script == null:
		return "game or floor select did not load"
	var game = game_script.new()
	root.add_child(game)
	if game.town == null or game.floor_select == null or game.descent == null:
		game.free()
		return "the game did not build its screens"
	if game.floor_select.record_for("binding") != Rules.BINDING_RECORD:
		game.free()
		return "floor select does not offer the binding census"
	if game.floor_select.record_for("cellar") != Rules.CELLAR_RECORD:
		game.free()
		return "floor select dropped the cellar census"
	if game.floor_select.record_for("cistern") != Rules.CISTERN_RECORD:
		game.free()
		return "floor select dropped the cistern census"
	if game.floor_select.record_for("cloister") != Rules.CLOISTER_RECORD:
		game.free()
		return "floor select dropped the cloister census"
	if game.floor_select.record_for("crypt") != Rules.CRYPT_RECORD:
		game.free()
		return "floor select dropped the crypt census"
	if game.floor_select.record_for("ossuary") != Rules.OSSUARY_RECORD:
		game.free()
		return "floor select dropped the ossuary census"
	if game.floor_select.record_for("reliquary") != Rules.RELIQUARY_RECORD:
		game.free()
		return "floor select dropped the reliquary census"
	if game.floor_select.record_for("undercroft") != Rules.UNDERCROFT_RECORD:
		game.free()
		return "floor select dropped the undercroft census"
	if game.floor_select.record_for("wellhouse") != Rules.WELL_RECORD:
		game.free()
		return "floor select dropped the well house census"
	if game.floor_select.record_for("scriptorium") != Rules.SCRIPTORIUM_RECORD:
		game.free()
		return "floor select dropped the scriptorium census"
	if game.floor_select.status_for("binding") != "Census open":
		game.free()
		return "the binding card did not open"
	game._on_descend_floor("binding")
	if game.descent.state == null or game.descent.state.floor.id != "binding":
		game.free()
		return "descend did not open the binding"
	var state = game.descent.state
	var lift: Vector2i = Rules.lift_pos(state.floor)
	var approach: Vector2i = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var left: Dictionary = Rules.step(state, lift - approach)
	if not bool(left.extracted):
		game.free()
		return "short binding sheet did not leave on the lift"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to town":
		game.free()
		return "a short sheet offered the floor select"
	game._on_return(state)
	if not game.town.visible or game.floor_select.visible or game.descent.visible:
		game.free()
		return "a short census did not return to town"
	if bool(game.campaign.completed.get("binding", false)):
		game.free()
		return "a short census was accepted"
	if game.town.outcome_label.text.find("not finished") < 0:
		game.free()
		return "the clerk treated a short sheet as finished"
	game._on_floors()
	if not game.floor_select.visible or game.town.visible:
		game.free()
		return "floor select did not open from town"
	game._on_descend_floor("binding")
	state = game.descent.state
	state.marks = Rules.accurate_sheet(state.floor)
	lift = Rules.lift_pos(state.floor)
	approach = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var done: Dictionary = Rules.step(state, lift - approach)
	if not bool(done.extracted) or not Rules.census_accepted(state.marks, state.floor):
		game.free()
		return "the finished sheet did not extract as an accepted census"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to floor select":
		game.free()
		return "a finished census did not offer the floor select"
	game._on_return(state)
	if not game.floor_select.visible or game.town.visible or game.descent.visible:
		game.free()
		return "a finished census did not return to the floor select"
	if not bool(game.campaign.completed.get("binding", false)):
		game.free()
		return "the finished census was not recorded"
	if bool(game.campaign.completed.get("cellar", false)) or bool(game.campaign.completed.get("cistern", false)) or bool(game.campaign.completed.get("cloister", false)) or bool(game.campaign.completed.get("crypt", false)) or bool(game.campaign.completed.get("ossuary", false)) or bool(game.campaign.completed.get("reliquary", false)) or bool(game.campaign.completed.get("undercroft", false)) or bool(game.campaign.completed.get("wellhouse", false)) or bool(game.campaign.completed.get("scriptorium", false)):
		game.free()
		return "another floor was marked complete"
	if game.floor_select.status_for("binding") != "Census complete":
		game.free()
		return "floor select did not show the binding census complete"
	if game.floor_select.status_for("cellar") != "Census open" or game.floor_select.status_for("cistern") != "Census open" or game.floor_select.status_for("cloister") != "Census open" or game.floor_select.status_for("crypt") != "Census open" or game.floor_select.status_for("ossuary") != "Census open" or game.floor_select.status_for("reliquary") != "Census open" or game.floor_select.status_for("undercroft") != "Census open" or game.floor_select.status_for("wellhouse") != "Census open" or game.floor_select.status_for("scriptorium") != "Census open":
		game.free()
		return "another floor card was closed"
	if game.floor_select.notice_label.text.find("complete") < 0:
		game.free()
		return "arrival did not say the census is complete"
	if game.campaign.purse < 343 or game.campaign.last_outcome != "complete":
		game.free()
		return "the finished census was not paid"
	game._show_town()
	if not game.town.visible or game.floor_select.visible:
		game.free()
		return "Back to town did not leave the floor select"
	if game.town.outcome_label.text.find("complete") < 0:
		game.free()
		return "town clerk did not keep the finished census"
	game.free()
	return ""


func _chartroom_layout() -> String:
	if Rules.CORRIDOR_VALUE != 3 or Rules.HAZARD_VALUE != 8 or Rules.LOOP_VALUE != 15:
		return "payout rates changed"
	if Rules.MOVE_OIL != 1 or Rules.HIT_OIL != 3:
		return "oil costs changed"
	if Rules.SMALL_FLASK_OIL != 24 or Rules.LARGE_FLASK_OIL != 120 or Rules.LARGE_FLASK_COST != 40:
		return "flask sizes changed"
	var floor = Rules.floor_named("chartroom")
	if floor == null:
		return "chart room floor is missing"
	if floor.record != Rules.CHART_RECORD:
		return "chart room record drifted from its constant"
	if Rules.CHART_RECORD != "Record every corridor, the twelve chart cracks, and the chart room ring around the table.":
		return "the chart room no longer asks for the chart cracks and the ring"
	var expected := PackedStringArray([
		"#################",
		"#S..............#",
		"#.######.TT.##..#",
		"#H######.TT.##H.#",
		"#.######.TT.##..#",
		"#H######.TT.##..#",
		"#.######.TT.##HL#",
		"#H######.TT.##..#",
		"#.######.TT.##H.#",
		"#H.......TT.....#",
		"#..HEH.H....H.H.#",
	])
	if floor.rows.size() != expected.size():
		return "chart room height %d" % floor.rows.size()
	for i in expected.size():
		if str(floor.rows[i]) != str(expected[i]):
			return "chart room row %d is %s" % [i, floor.rows[i]]
	if Rules.width(floor) != 17 or Rules.height(floor) != 11:
		return "chart room size %dx%d" % [Rules.width(floor), Rules.height(floor)]
	if Rules.start_pos(floor) != Vector2i(1, 1):
		return "start %s" % Rules.start_pos(floor)
	if Rules.lift_pos(floor) != Vector2i(15, 6):
		return "lift %s" % Rules.lift_pos(floor)
	if Rules.enemy_pos(floor) != Vector2i(4, 10):
		return "warden %s" % Rules.enemy_pos(floor)
	if Rules.enemy_pos(floor) == Vector2i(3, 10) or Rules.enemy_pos(floor) == Vector2i(6, 12):
		return "the warden reuses the binding or scriptorium cell"
	if Rules.is_corridor_cell(Rules.enemy_pos(floor), floor):
		return "the warden tile counts as a corridor"
	var hazards: Array = Rules.hazard_cells(floor)
	var expect_h: Array = [Vector2i(1, 3), Vector2i(14, 3), Vector2i(1, 5), Vector2i(14, 6), Vector2i(1, 7), Vector2i(14, 8), Vector2i(1, 9), Vector2i(3, 10), Vector2i(5, 10), Vector2i(7, 10), Vector2i(12, 10), Vector2i(14, 10)]
	if hazards.size() != 12:
		return "hazard count %d" % hazards.size()
	for i in hazards.size():
		if hazards[i] != expect_h[i]:
			return "hazard %d is %s" % [i, hazards[i]]
	if Rules.corridor_cells(floor).size() != 65:
		return "corridors %d" % Rules.corridor_cells(floor).size()
	var tables := 0
	for y in range(2, 10):
		for x in range(9, 11):
			if Rules.glyph_at(Vector2i(x, y), floor) != "T":
				return "table cell %s is not chart paper" % Vector2i(x, y)
			tables += 1
			if Rules.tile_at(Vector2i(x, y), floor) != Rules.Tile.WALL or Rules.is_walkable(Vector2i(x, y), floor):
				return "the table is not solid wall"
	if tables != 16:
		return "table size %d" % tables
	for y in Rules.height(floor):
		for x in Rules.width(floor):
			if Rules.glyph_at(Vector2i(x, y), floor) == "T" and (x < 9 or x > 10 or y < 2 or y > 9):
				return "table spills outside the 2x8 bar at %s" % Vector2i(x, y)
	if Rules.glyph_at(Vector2i(8, 5), floor) == "T" or Rules.glyph_at(Vector2i(11, 5), floor) == "T" or Rules.glyph_at(Vector2i(9, 1), floor) == "T" or Rules.glyph_at(Vector2i(9, 10), floor) == "T":
		return "the table is not a solid 2x8 bar"
	var ring_err := _chartroom_ring(floor)
	if ring_err != "":
		return ring_err
	var binding = Rules.floor_named("binding")
	var scriptorium = Rules.floor_named("scriptorium")
	if floor.rows == binding.rows or floor.rows == scriptorium.rows:
		return "the chart room copies an earlier floor"
	if Rules.enemy_pos(floor) == Rules.enemy_pos(binding) or Rules.enemy_pos(floor) == Rules.enemy_pos(scriptorium):
		return "the chart room reuses an earlier warden cell"
	if Rules.loop_cells(floor).size() == Rules.loop_cells(binding).size() or Rules.loop_cells(floor).size() == Rules.loop_cells(scriptorium).size():
		return "the chart room reuses an earlier ring length"
	for y in range(2, 10):
		if not Rules.is_walkable(Vector2i(1, y), floor):
			return "the west aisle is closed at %s" % Vector2i(1, y)
	var landing := 0
	for x in range(1, 16):
		var south := Vector2i(x, 10)
		if Rules.is_walkable(south, floor) or south == Rules.enemy_pos(floor):
			landing += 1
	if landing < 8:
		return "the south landing is not open floor"
	var swings: Array = Rules.swing_tiles(floor)
	if swings.size() != 2 or swings[0] == swings[1]:
		return "the warden should telegraph two distinct tiles"
	for swing in swings:
		if not Rules.is_walkable(swing, floor):
			return "swing tile %s is not walkable" % swing
	if Rules.is_walkable(Rules.enemy_pos(floor), floor):
		return "the warden's own tile is walkable"
	var steps := Rules.shortest_path_steps(floor)
	if steps != 19:
		return "shortest chart room path is %d, expected 19" % steps
	if Rules.SMALL_FLASK_OIL - steps != 5:
		return "small flask margin is %d, expected 5" % (Rules.SMALL_FLASK_OIL - steps)
	var actions: Array = Rules.scripted_safe_actions(floor)
	if actions.is_empty():
		return "no safe exit from the chart room"
	var state = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	for i in actions.size():
		var result: Dictionary = Rules.step(state, actions[i])
		if bool(result.hit):
			return "hit on chart room exit action %d at %s" % [i, state.pos]
		if state.end_reason != Rules.EndReason.NONE and i != actions.size() - 1:
			return "chart room exit ended early at action %d" % i
		if actions[i] != Vector2i.ZERO and not bool(result.moved):
			return "chart room exit step %d did not move" % i
	if state.end_reason != Rules.EndReason.EXTRACTED or state.pos != Rules.lift_pos(floor):
		return "chart room exit was not an extract at the lift"
	if state.oil != Rules.SMALL_FLASK_OIL - actions.size():
		return "chart room exit oil %d after %d actions" % [state.oil, actions.size()]
	var full: int = int(Rules.payout(Rules.accurate_sheet(floor), floor).total)
	var carried: int = int(Rules.payout(state.marks, floor).total)
	if carried <= 0 or carried >= full:
		return "exit sheet paid %d against full %d" % [carried, full]
	if Rules.census_accepted(state.marks, floor):
		return "the exit path was accepted as a finished census"
	var cover := Rules.safe_survey_steps(floor)
	if cover != 114:
		return "safe survey is %d, expected 114" % cover
	if cover < 100 or cover > 116:
		return "survey oil %d is outside 100 to 116" % cover
	if cover > Rules.LARGE_FLASK_OIL or cover <= Rules.SMALL_FLASK_OIL:
		return "survey oil %d does not sit between the flasks" % cover
	var expected_pay := Rules.corridor_cells(floor).size() * Rules.CORRIDOR_VALUE + 12 * Rules.HAZARD_VALUE + Rules.LOOP_VALUE
	if full != expected_pay or full != 306:
		return "full pay %d does not match 3 x corridors + 8 x 12 + 15" % full
	print("  chart room shortest %d  survey %d  exit pay %d  full %d" % [steps, cover, carried, full])
	return ""


func _chartroom_ring(floor) -> String:
	var cells: Array = Rules.loop_cells(floor)
	if cells.size() != 24:
		return "ring size %d" % cells.size()
	var have := {}
	for cell in cells:
		if have.has(cell):
			return "duplicate ring tile %s" % cell
		have[cell] = true
		if not Rules.is_corridor_cell(cell, floor):
			return "ring tile %s is not a corridor" % cell
	for cell in cells:
		var degree := 0
		for dir in Rules.cardinals():
			if have.has(cell + dir):
				degree += 1
		if degree != 2:
			return "ring tile %s has %d neighbors in the ring" % [cell, degree]
	if not have.has(Vector2i(9, 1)) or have.has(Vector2i(9, 2)):
		return "the ring does not rim the table"
	if have.has(Vector2i(9, 5)) or have.has(Vector2i(6, 5)):
		return "the ring is not the rectangle around the table"
	var expect: Array = []
	for x in range(8, 12):
		expect.append(Vector2i(x, 1))
	for y in range(2, 10):
		expect.append(Vector2i(8, y))
		expect.append(Vector2i(11, y))
	for x in range(8, 12):
		expect.append(Vector2i(x, 10))
	if cells.size() != expect.size():
		return "ring listing size %d" % cells.size()
	for cell in expect:
		if not have.has(cell):
			return "ring is missing %s" % cell
	var tables := 0
	for y in Rules.height(floor):
		for x in Rules.width(floor):
			var p := Vector2i(x, y)
			if Rules.glyph_at(p, floor) != "T":
				continue
			tables += 1
			for dir in Rules.cardinals():
				var n: Vector2i = p + dir
				if Rules.is_corridor_cell(n, floor) and not have.has(n):
					return "corridor %s touches the table and is outside the ring" % n
	if tables != 16:
		return "table size %d" % tables
	if str(floor.loop_name) != "Chart room ring":
		return "ring name is %s" % floor.loop_name
	return ""


func _chartroom_census() -> String:
	var floor = Rules.floor_named("chartroom")
	var cellar = Rules.floor_named("cellar")
	var cistern = Rules.floor_named("cistern")
	var cloister = Rules.floor_named("cloister")
	var crypt = Rules.floor_named("crypt")
	var ossuary = Rules.floor_named("ossuary")
	var reliquary = Rules.floor_named("reliquary")
	var undercroft = Rules.floor_named("undercroft")
	var wellhouse = Rules.floor_named("wellhouse")
	var scriptorium = Rules.floor_named("scriptorium")
	var binding = Rules.floor_named("binding")
	var truth: Dictionary = Rules.accurate_sheet(floor)
	if not Rules.census_accepted(truth, floor):
		return "the true chart room census was rejected"
	var bill: Dictionary = Rules.payout(truth, floor)
	if int(bill.corridors) != 65 or int(bill.hazards) != 12 or int(bill.loop) != 1:
		return "true counts %s/%s loop %s" % [bill.corridors, bill.hazards, bill.loop]
	if int(bill.corridor_pay) != 65 * Rules.CORRIDOR_VALUE:
		return "corridor pay drifted"
	if int(bill.hazard_pay) != 12 * Rules.HAZARD_VALUE:
		return "hazard pay drifted"
	if int(bill.loop_pay) != Rules.LOOP_VALUE:
		return "ring pay drifted"
	var arithmetic := 65 * 3 + 12 * 8 + 15
	if int(bill.total) != arithmetic or int(bill.total) != 306:
		return "true total %s, expected %s" % [bill.total, arithmetic]
	if Rules.format_bill(bill).find("Chart room ring") < 0:
		return "the receipt did not name the chart room ring"
	if Rules.census_accepted({}, floor):
		return "an empty sheet was accepted"
	if int(Rules.payout({}, floor).total) != 0:
		return "an empty sheet paid out"
	var missing_corridor: Dictionary = truth.duplicate()
	missing_corridor.erase(Rules.start_pos(floor))
	if Rules.census_accepted(missing_corridor, floor):
		return "a sheet missing the start corridor was accepted"
	var missing_bill: Dictionary = Rules.payout(missing_corridor, floor)
	if int(missing_bill.total) >= 306 or int(missing_bill.loop) != 1:
		return "dropping a corridor outside the ring changed the census the wrong way"
	var crack: Vector2i = Rules.hazard_cells(floor)[0]
	var missing_crack: Dictionary = truth.duplicate()
	missing_crack.erase(crack)
	if Rules.census_accepted(missing_crack, floor):
		return "a sheet missing a chart crack was accepted"
	if int(Rules.payout(missing_crack, floor).total) >= 306:
		return "dropping a chart crack did not lower pay"
	var broken_ring: Dictionary = truth.duplicate()
	var rim: Vector2i = Rules.loop_cells(floor)[0]
	broken_ring[rim] = Rules.Mark.WALL
	if Rules.census_accepted(broken_ring, floor):
		return "a broken ring was accepted"
	var broken_bill: Dictionary = Rules.payout(broken_ring, floor)
	if int(broken_bill.loop) != 0 or int(broken_bill.total) >= 306:
		return "a broken ring still paid as a finished sheet"
	var swapped: Dictionary = truth.duplicate()
	swapped[crack] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(swapped, floor):
		return "a chart crack marked as a corridor was accepted"
	if int(Rules.payout(swapped, floor).hazard_pay) >= int(bill.hazard_pay):
		return "mislabeling a chart crack did not lower hazard pay"
	if int(Rules.payout(swapped, floor).total) > 306:
		return "mislabeling a chart crack raised the payout"
	var corridor: Vector2i = Rules.lift_pos(floor)
	var swapped_corridor: Dictionary = truth.duplicate()
	swapped_corridor[corridor] = Rules.Mark.HAZARD
	if Rules.census_accepted(swapped_corridor, floor):
		return "the lift marked as a hazard was accepted"
	if int(Rules.payout(swapped_corridor, floor).total) > 306:
		return "marking the lift as a hazard raised the payout"
	var false_wall: Dictionary = truth.duplicate()
	false_wall[Vector2i(0, 0)] = Rules.Mark.HAZARD
	if Rules.census_accepted(false_wall, floor):
		return "a hazard mark on a wall was accepted"
	if int(Rules.payout(false_wall, floor).total) != 306 or int(Rules.payout(false_wall, floor).hazard_pay) != int(bill.hazard_pay):
		return "a hazard mark on a wall changed the payout"
	var table_wall: Dictionary = truth.duplicate()
	table_wall[Vector2i(9, 2)] = Rules.Mark.WALL
	if not Rules.census_accepted(table_wall, floor):
		return "inking the table as a wall rejected a true census"
	table_wall[Vector2i(9, 2)] = Rules.Mark.HAZARD
	if Rules.census_accepted(table_wall, floor):
		return "calling the table a hazard was accepted"
	var warden_mark: Dictionary = truth.duplicate()
	warden_mark[Rules.enemy_pos(floor)] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(warden_mark, floor):
		return "the warden tile was accepted as a corridor"
	if int(Rules.payout(warden_mark, floor).total) != 306:
		return "marking the warden changed the payout"
	var only_ring := {}
	for cell in Rules.loop_cells(floor):
		only_ring[cell] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(only_ring, floor):
		return "the ring alone was accepted as the census"
	var ring_bill: Dictionary = Rules.payout(only_ring, floor)
	if int(ring_bill.loop) != 1 or int(ring_bill.hazards) != 0 or int(ring_bill.total) >= 306:
		return "the ring bonus did not stay inside the shared payout rule"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cellar):
		return "the chart room sheet was accepted as the cellar"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cistern):
		return "the chart room sheet was accepted as the cistern"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cloister):
		return "the chart room sheet was accepted as the cloister"
	if Rules.census_accepted(Rules.accurate_sheet(floor), crypt):
		return "the chart room sheet was accepted as the crypt"
	if Rules.census_accepted(Rules.accurate_sheet(floor), ossuary):
		return "the chart room sheet was accepted as the ossuary"
	if Rules.census_accepted(Rules.accurate_sheet(floor), reliquary):
		return "the chart room sheet was accepted as the reliquary"
	if Rules.census_accepted(Rules.accurate_sheet(floor), undercroft):
		return "the chart room sheet was accepted as the undercroft"
	if Rules.census_accepted(Rules.accurate_sheet(floor), wellhouse):
		return "the chart room sheet was accepted as the well house"
	if Rules.census_accepted(Rules.accurate_sheet(floor), scriptorium):
		return "the chart room sheet was accepted as the scriptorium"
	if Rules.census_accepted(Rules.accurate_sheet(floor), binding):
		return "the chart room sheet was accepted as the binding"
	if Rules.census_accepted(Rules.accurate_sheet(cellar), floor):
		return "the cellar sheet was accepted as the chart room"
	if Rules.census_accepted(Rules.accurate_sheet(cistern), floor):
		return "the cistern sheet was accepted as the chart room"
	if Rules.census_accepted(Rules.accurate_sheet(cloister), floor):
		return "the cloister sheet was accepted as the chart room"
	if Rules.census_accepted(Rules.accurate_sheet(crypt), floor):
		return "the crypt sheet was accepted as the chart room"
	if Rules.census_accepted(Rules.accurate_sheet(ossuary), floor):
		return "the ossuary sheet was accepted as the chart room"
	if Rules.census_accepted(Rules.accurate_sheet(reliquary), floor):
		return "the reliquary sheet was accepted as the chart room"
	if Rules.census_accepted(Rules.accurate_sheet(undercroft), floor):
		return "the undercroft sheet was accepted as the chart room"
	if Rules.census_accepted(Rules.accurate_sheet(wellhouse), floor):
		return "the well house sheet was accepted as the chart room"
	if Rules.census_accepted(Rules.accurate_sheet(scriptorium), floor):
		return "the scriptorium sheet was accepted as the chart room"
	if Rules.census_accepted(Rules.accurate_sheet(binding), floor):
		return "the binding sheet was accepted as the chart room"
	if not Rules.census_accepted(Rules.accurate_sheet(cellar), cellar):
		return "the cellar's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(cistern), cistern):
		return "the cistern's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(cloister), cloister):
		return "the cloister's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(crypt), crypt):
		return "the crypt's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(ossuary), ossuary):
		return "the ossuary's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(reliquary), reliquary):
		return "the reliquary's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(undercroft), undercroft):
		return "the undercroft's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(wellhouse), wellhouse):
		return "the well house's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(scriptorium), scriptorium):
		return "the scriptorium's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(binding), binding):
		return "the binding's true census was rejected"
	var cellar_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cellar), cellar)
	if int(cellar_bill.total) != 211 or str(cellar_bill.loop_name) != "East square":
		return "the cellar payout changed"
	var cistern_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cistern), cistern)
	if int(cistern_bill.total) != 288 or str(cistern_bill.loop_name) != "Cistern ring":
		return "the cistern payout changed"
	var cloister_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cloister), cloister)
	if int(cloister_bill.total) != 242 or str(cloister_bill.loop_name) != "Cloister walk":
		return "the cloister payout changed"
	var crypt_bill: Dictionary = Rules.payout(Rules.accurate_sheet(crypt), crypt)
	if int(crypt_bill.total) != 316 or str(crypt_bill.loop_name) != "Crypt ring":
		return "the crypt payout changed"
	var ossuary_bill: Dictionary = Rules.payout(Rules.accurate_sheet(ossuary), ossuary)
	if int(ossuary_bill.total) != 240 or str(ossuary_bill.loop_name) != "Ossuary ring":
		return "the ossuary payout changed"
	var reliquary_bill: Dictionary = Rules.payout(Rules.accurate_sheet(reliquary), reliquary)
	if int(reliquary_bill.total) != 251 or str(reliquary_bill.loop_name) != "Reliquary ring":
		return "the reliquary payout changed"
	var undercroft_bill: Dictionary = Rules.payout(Rules.accurate_sheet(undercroft), undercroft)
	if int(undercroft_bill.total) != 238 or str(undercroft_bill.loop_name) != "Undercroft ring":
		return "the undercroft payout changed"
	var well_bill: Dictionary = Rules.payout(Rules.accurate_sheet(wellhouse), wellhouse)
	if int(well_bill.total) != 225 or str(well_bill.loop_name) != "Well ring":
		return "the well house payout changed"
	var scriptorium_bill: Dictionary = Rules.payout(Rules.accurate_sheet(scriptorium), scriptorium)
	if int(scriptorium_bill.total) != 263 or str(scriptorium_bill.loop_name) != "Scriptorium ring":
		return "the scriptorium payout changed"
	var binding_bill: Dictionary = Rules.payout(Rules.accurate_sheet(binding), binding)
	if int(binding_bill.total) != 343 or str(binding_bill.loop_name) != "Binding ring":
		return "the binding payout changed"
	var approach: Vector2i = Rules.walkable_approach(crack, floor)
	if approach.x < 0:
		return "chart crack has no approach"
	var walker = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	walker.pos = approach
	walker.oil = 10
	var before: int = walker.oil
	var stepped: Dictionary = Rules.step(walker, crack - approach)
	if bool(stepped.hit):
		return "opening chart step was a swing"
	if walker.oil != before - Rules.MOVE_OIL:
		return "a chart crack burned extra oil"
	if int(walker.marks.get(crack, Rules.Mark.NONE)) != Rules.Mark.HAZARD:
		return "a chart crack was not inked as a hazard"
	return ""


func _chartroom_return() -> String:
	var game_script = load("res://scripts/game.gd")
	var select_script = load("res://scripts/floor_select_view.gd")
	if game_script == null or select_script == null:
		return "game or floor select did not load"
	var game = game_script.new()
	root.add_child(game)
	if game.town == null or game.floor_select == null or game.descent == null:
		game.free()
		return "the game did not build its screens"
	if game.floor_select.record_for("chartroom") != Rules.CHART_RECORD:
		game.free()
		return "floor select does not offer the chart room census"
	if game.floor_select.record_for("cellar") != Rules.CELLAR_RECORD:
		game.free()
		return "floor select dropped the cellar census"
	if game.floor_select.record_for("cistern") != Rules.CISTERN_RECORD:
		game.free()
		return "floor select dropped the cistern census"
	if game.floor_select.record_for("cloister") != Rules.CLOISTER_RECORD:
		game.free()
		return "floor select dropped the cloister census"
	if game.floor_select.record_for("crypt") != Rules.CRYPT_RECORD:
		game.free()
		return "floor select dropped the crypt census"
	if game.floor_select.record_for("ossuary") != Rules.OSSUARY_RECORD:
		game.free()
		return "floor select dropped the ossuary census"
	if game.floor_select.record_for("reliquary") != Rules.RELIQUARY_RECORD:
		game.free()
		return "floor select dropped the reliquary census"
	if game.floor_select.record_for("undercroft") != Rules.UNDERCROFT_RECORD:
		game.free()
		return "floor select dropped the undercroft census"
	if game.floor_select.record_for("wellhouse") != Rules.WELL_RECORD:
		game.free()
		return "floor select dropped the well house census"
	if game.floor_select.record_for("scriptorium") != Rules.SCRIPTORIUM_RECORD:
		game.free()
		return "floor select dropped the scriptorium census"
	if game.floor_select.record_for("binding") != Rules.BINDING_RECORD:
		game.free()
		return "floor select dropped the binding census"
	if game.floor_select.status_for("chartroom") != "Census open":
		game.free()
		return "the chart room card did not open"
	game._on_descend_floor("chartroom")
	if game.descent.state == null or game.descent.state.floor.id != "chartroom":
		game.free()
		return "descend did not open the chart room"
	var state = game.descent.state
	var lift: Vector2i = Rules.lift_pos(state.floor)
	var approach: Vector2i = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var left: Dictionary = Rules.step(state, lift - approach)
	if not bool(left.extracted):
		game.free()
		return "short chart room sheet did not leave on the lift"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to town":
		game.free()
		return "a short sheet offered the floor select"
	game._on_return(state)
	if not game.town.visible or game.floor_select.visible or game.descent.visible:
		game.free()
		return "a short census did not return to town"
	if bool(game.campaign.completed.get("chartroom", false)):
		game.free()
		return "a short census was accepted"
	if game.town.outcome_label.text.find("not finished") < 0:
		game.free()
		return "the clerk treated a short sheet as finished"
	game._on_floors()
	if not game.floor_select.visible or game.town.visible:
		game.free()
		return "floor select did not open from town"
	game._on_descend_floor("chartroom")
	state = game.descent.state
	state.marks = Rules.accurate_sheet(state.floor)
	lift = Rules.lift_pos(state.floor)
	approach = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var done: Dictionary = Rules.step(state, lift - approach)
	if not bool(done.extracted) or not Rules.census_accepted(state.marks, state.floor):
		game.free()
		return "the finished sheet did not extract as an accepted census"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to floor select":
		game.free()
		return "a finished census did not offer the floor select"
	game._on_return(state)
	if not game.floor_select.visible or game.town.visible or game.descent.visible:
		game.free()
		return "a finished census did not return to the floor select"
	if not bool(game.campaign.completed.get("chartroom", false)):
		game.free()
		return "the finished census was not recorded"
	if bool(game.campaign.completed.get("cellar", false)) or bool(game.campaign.completed.get("cistern", false)) or bool(game.campaign.completed.get("cloister", false)) or bool(game.campaign.completed.get("crypt", false)) or bool(game.campaign.completed.get("ossuary", false)) or bool(game.campaign.completed.get("reliquary", false)) or bool(game.campaign.completed.get("undercroft", false)) or bool(game.campaign.completed.get("wellhouse", false)) or bool(game.campaign.completed.get("scriptorium", false)) or bool(game.campaign.completed.get("binding", false)):
		game.free()
		return "another floor was marked complete"
	if game.floor_select.status_for("chartroom") != "Census complete":
		game.free()
		return "floor select did not show the chart room census complete"
	if game.floor_select.status_for("cellar") != "Census open" or game.floor_select.status_for("cistern") != "Census open" or game.floor_select.status_for("cloister") != "Census open" or game.floor_select.status_for("crypt") != "Census open" or game.floor_select.status_for("ossuary") != "Census open" or game.floor_select.status_for("reliquary") != "Census open" or game.floor_select.status_for("undercroft") != "Census open" or game.floor_select.status_for("wellhouse") != "Census open" or game.floor_select.status_for("scriptorium") != "Census open" or game.floor_select.status_for("binding") != "Census open":
		game.free()
		return "another floor card was closed"
	if game.floor_select.notice_label.text.find("complete") < 0:
		game.free()
		return "arrival did not say the census is complete"
	if game.campaign.purse < 306 or game.campaign.last_outcome != "complete":
		game.free()
		return "the finished census was not paid"
	game._show_town()
	if not game.town.visible or game.floor_select.visible:
		game.free()
		return "Back to town did not leave the floor select"
	if game.town.outcome_label.text.find("complete") < 0:
		game.free()
		return "town clerk did not keep the finished census"
	game.free()
	return ""


func _ring_key(floor) -> String:
	var parts: PackedStringArray = []
	for cell in Rules.loop_cells(floor):
		var p: Vector2i = cell
		parts.append("%d,%d" % [p.x, p.y])
	parts.sort()
	return "|".join(parts)


func _bellloft_layout() -> String:
	if Rules.CORRIDOR_VALUE != 3 or Rules.HAZARD_VALUE != 8 or Rules.LOOP_VALUE != 15:
		return "payout rates changed"
	if Rules.MOVE_OIL != 1 or Rules.HIT_OIL != 3:
		return "oil costs changed"
	if Rules.SMALL_FLASK_OIL != 24 or Rules.LARGE_FLASK_OIL != 120 or Rules.LARGE_FLASK_COST != 40:
		return "flask sizes changed"
	var floor = Rules.floor_named("bellloft")
	if floor == null:
		return "bell loft floor is missing"
	if floor.record != Rules.BELL_RECORD:
		return "bell loft record drifted from its constant"
	if Rules.BELL_RECORD != "Record every corridor, the thirteen bell cracks, and the bell loft ring around the bell.":
		return "the bell loft no longer asks for the bell cracks and the ring"
	var expected := PackedStringArray([
		"###############",
		"#S............#",
		"#.###########.#",
		"#H###......##.#",
		"#.###.YYYY.##.#",
		"#H###.YYYY.##.#",
		"#.###.YYYY.##.#",
		"#H###.YYYY.##.#",
		"#.###........L#",
		"#H###........H#",
		"#.###.......H.#",
		"#H.H.H.HEH.H.H#",
		"#.#############",
		"###############",
	])
	if floor.rows.size() != expected.size():
		return "bell loft height %d" % floor.rows.size()
	for i in expected.size():
		if str(floor.rows[i]) != str(expected[i]):
			return "bell loft row %d is %s" % [i, floor.rows[i]]
	if Rules.width(floor) != 15 or Rules.height(floor) != 14:
		return "bell loft size %dx%d" % [Rules.width(floor), Rules.height(floor)]
	if Rules.start_pos(floor) != Vector2i(1, 1):
		return "start %s" % Rules.start_pos(floor)
	if Rules.lift_pos(floor) != Vector2i(13, 8):
		return "lift %s" % Rules.lift_pos(floor)
	if Rules.enemy_pos(floor) != Vector2i(8, 11):
		return "warden %s" % Rules.enemy_pos(floor)
	if Rules.enemy_pos(floor) == Vector2i(4, 10) or Rules.enemy_pos(floor) == Vector2i(3, 10) or Rules.enemy_pos(floor) == Vector2i(6, 12):
		return "the warden reuses the chart room, binding, or scriptorium cell"
	if Rules.is_corridor_cell(Rules.enemy_pos(floor), floor):
		return "the warden tile counts as a corridor"
	if Rules.accurate_sheet(floor).has(Rules.enemy_pos(floor)):
		return "the true sheet inks the warden"
	var hazards: Array = Rules.hazard_cells(floor)
	var expect_h: Array = [Vector2i(1, 3), Vector2i(1, 5), Vector2i(1, 7), Vector2i(1, 9), Vector2i(13, 9), Vector2i(12, 10), Vector2i(1, 11), Vector2i(3, 11), Vector2i(5, 11), Vector2i(7, 11), Vector2i(9, 11), Vector2i(11, 11), Vector2i(13, 11)]
	if hazards.size() != 13:
		return "hazard count %d" % hazards.size()
	for i in hazards.size():
		if hazards[i] != expect_h[i]:
			return "hazard %d is %s" % [i, hazards[i]]
	if Rules.corridor_cells(floor).size() != 69:
		return "corridors %d" % Rules.corridor_cells(floor).size()
	var bells := 0
	for y in range(4, 8):
		for x in range(6, 10):
			if Rules.glyph_at(Vector2i(x, y), floor) != "Y":
				return "bell cell %s is not bronze" % Vector2i(x, y)
			bells += 1
			if Rules.tile_at(Vector2i(x, y), floor) != Rules.Tile.WALL or Rules.is_walkable(Vector2i(x, y), floor):
				return "the bell is not solid wall"
	if bells != 16:
		return "bell size %d" % bells
	for y in Rules.height(floor):
		for x in Rules.width(floor):
			if Rules.glyph_at(Vector2i(x, y), floor) == "Y" and (x < 6 or x > 9 or y < 4 or y > 7):
				return "bell spills outside the 4x4 square at %s" % Vector2i(x, y)
	if Rules.glyph_at(Vector2i(7, 5), floor) != "Y" or Rules.glyph_at(Vector2i(6, 4), floor) != "Y" or Rules.glyph_at(Vector2i(9, 7), floor) != "Y":
		return "the bell is not a solid 4x4 square"
	if Rules.glyph_at(Vector2i(5, 5), floor) == "Y" or Rules.glyph_at(Vector2i(10, 5), floor) == "Y" or Rules.glyph_at(Vector2i(7, 3), floor) == "Y" or Rules.glyph_at(Vector2i(7, 8), floor) == "Y":
		return "the bell is a bar, a block, or an L"
	if Rules.glyph_at(Vector2i(2, 4), floor) != "#" or Rules.glyph_at(Vector2i(11, 5), floor) != "#":
		return "the piers are not ordinary walls"
	if Rules.tile_at(Vector2i(2, 4), floor) != Rules.Tile.WALL:
		return "a pier is not wall for the sheet"
	var ring_err := _bellloft_ring(floor)
	if ring_err != "":
		return ring_err
	var chartroom = Rules.floor_named("chartroom")
	var binding = Rules.floor_named("binding")
	var scriptorium = Rules.floor_named("scriptorium")
	if floor.rows == chartroom.rows or floor.rows == binding.rows or floor.rows == scriptorium.rows:
		return "the bell loft copies an earlier floor"
	if Rules.width(floor) == Rules.width(chartroom) and Rules.height(floor) == Rules.height(chartroom):
		return "the bell loft reuses the chart room grid"
	if Rules.width(floor) == Rules.width(binding) and Rules.height(floor) == Rules.height(binding):
		return "the bell loft reuses the binding grid"
	if Rules.width(floor) == Rules.width(scriptorium) and Rules.height(floor) == Rules.height(scriptorium):
		return "the bell loft reuses the scriptorium grid"
	if Rules.enemy_pos(floor) == Rules.enemy_pos(chartroom) or Rules.enemy_pos(floor) == Rules.enemy_pos(binding) or Rules.enemy_pos(floor) == Rules.enemy_pos(scriptorium):
		return "the bell loft reuses an earlier warden cell"
	if _ring_key(floor) == _ring_key(chartroom) or _ring_key(floor) == _ring_key(binding) or _ring_key(floor) == _ring_key(scriptorium):
		return "the bell loft reuses an earlier ring"
	for y in range(1, 13):
		if not Rules.is_walkable(Vector2i(1, y), floor):
			return "the west aisle is closed at %s" % Vector2i(1, y)
	var landing := 0
	for x in range(1, 14):
		if Rules.is_walkable(Vector2i(x, 1), floor):
			landing += 1
	if landing != 13:
		return "the north landing is not open floor"
	var swings: Array = Rules.swing_tiles(floor)
	if swings.size() != 2 or swings[0] == swings[1]:
		return "the warden should telegraph two distinct tiles"
	for swing in swings:
		if not Rules.is_walkable(swing, floor):
			return "swing tile %s is not walkable" % swing
	if Rules.is_walkable(Rules.enemy_pos(floor), floor):
		return "the warden's own tile is walkable"
	var bumper = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	bumper.pos = Vector2i(5, 4)
	var before_oil: int = bumper.oil
	var tap: Dictionary = Rules.step(bumper, Vector2i(1, 0))
	if bool(tap.moved) or bumper.oil != before_oil:
		return "bumping the bell spent oil or moved"
	if int(bumper.marks.get(Vector2i(6, 4), Rules.Mark.NONE)) != Rules.Mark.WALL:
		return "bumping the bell did not ink a wall"
	if str(tap.message).find("bell") < 0:
		return "bumping the bell did not name it"
	var steps := Rules.shortest_path_steps(floor)
	if steps != 19:
		return "shortest bell loft path is %d, expected 19" % steps
	if Rules.SMALL_FLASK_OIL - steps != 5:
		return "small flask margin is %d, expected 5" % (Rules.SMALL_FLASK_OIL - steps)
	var actions: Array = Rules.scripted_safe_actions(floor)
	if actions.is_empty():
		return "no safe exit from the bell loft"
	var state = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	for i in actions.size():
		var result: Dictionary = Rules.step(state, actions[i])
		if bool(result.hit):
			return "hit on bell loft exit action %d at %s" % [i, state.pos]
		if state.end_reason != Rules.EndReason.NONE and i != actions.size() - 1:
			return "bell loft exit ended early at action %d" % i
		if actions[i] != Vector2i.ZERO and not bool(result.moved):
			return "bell loft exit step %d did not move" % i
	if state.end_reason != Rules.EndReason.EXTRACTED or state.pos != Rules.lift_pos(floor):
		return "bell loft exit was not an extract at the lift"
	if state.oil != Rules.SMALL_FLASK_OIL - actions.size():
		return "bell loft exit oil %d after %d actions" % [state.oil, actions.size()]
	var full: int = int(Rules.payout(Rules.accurate_sheet(floor), floor).total)
	var carried: int = int(Rules.payout(state.marks, floor).total)
	if carried <= 0 or carried >= full:
		return "exit sheet paid %d against full %d" % [carried, full]
	if Rules.census_accepted(state.marks, floor):
		return "the exit path was accepted as a finished census"
	var cover := Rules.safe_survey_steps(floor)
	if cover != 108:
		return "safe survey is %d, expected 108" % cover
	if cover < 100 or cover > 116:
		return "survey oil %d is outside 100 to 116" % cover
	if cover > Rules.LARGE_FLASK_OIL or cover <= Rules.SMALL_FLASK_OIL:
		return "survey oil %d does not sit between the flasks" % cover
	var expected_pay := Rules.corridor_cells(floor).size() * Rules.CORRIDOR_VALUE + 13 * Rules.HAZARD_VALUE + Rules.LOOP_VALUE
	var arithmetic := 69 * 3 + 13 * 8 + 15
	if full != expected_pay or full != arithmetic or full != 326:
		return "full pay %d does not match 3 x corridors + 8 x 13 + 15" % full
	print("  bell loft shortest %d  survey %d  exit pay %d  full %d" % [steps, cover, carried, full])
	return ""


func _bellloft_ring(floor) -> String:
	var cells: Array = Rules.loop_cells(floor)
	if cells.size() != 20:
		return "ring size %d" % cells.size()
	var have := {}
	for cell in cells:
		if have.has(cell):
			return "duplicate ring tile %s" % cell
		have[cell] = true
		if not Rules.is_corridor_cell(cell, floor):
			return "ring tile %s is not a corridor" % cell
	for cell in cells:
		var degree := 0
		for dir in Rules.cardinals():
			if have.has(cell + dir):
				degree += 1
		if degree != 2:
			return "ring tile %s has %d neighbors in the ring" % [cell, degree]
	if not have.has(Vector2i(7, 3)) or have.has(Vector2i(7, 4)):
		return "the ring does not rim the bell"
	if have.has(Vector2i(7, 5)) or have.has(Vector2i(4, 5)):
		return "the ring is not the rectangle around the bell"
	var expect: Array = []
	for x in range(5, 11):
		expect.append(Vector2i(x, 3))
	for y in range(4, 8):
		expect.append(Vector2i(5, y))
		expect.append(Vector2i(10, y))
	for x in range(5, 11):
		expect.append(Vector2i(x, 8))
	if cells.size() != expect.size():
		return "ring listing size %d" % cells.size()
	for cell in expect:
		if not have.has(cell):
			return "ring is missing %s" % cell
	var bells := 0
	for y in Rules.height(floor):
		for x in Rules.width(floor):
			var p := Vector2i(x, y)
			if Rules.glyph_at(p, floor) != "Y":
				continue
			bells += 1
			for dir in Rules.cardinals():
				var n: Vector2i = p + dir
				if Rules.is_corridor_cell(n, floor) and not have.has(n):
					return "corridor %s touches the bell and is outside the ring" % n
	if bells != 16:
		return "bell size %d" % bells
	if str(floor.loop_name) != "Bell loft ring":
		return "ring name is %s" % floor.loop_name
	return ""


func _bellloft_census() -> String:
	var floor = Rules.floor_named("bellloft")
	var cellar = Rules.floor_named("cellar")
	var cistern = Rules.floor_named("cistern")
	var cloister = Rules.floor_named("cloister")
	var crypt = Rules.floor_named("crypt")
	var ossuary = Rules.floor_named("ossuary")
	var reliquary = Rules.floor_named("reliquary")
	var undercroft = Rules.floor_named("undercroft")
	var wellhouse = Rules.floor_named("wellhouse")
	var scriptorium = Rules.floor_named("scriptorium")
	var binding = Rules.floor_named("binding")
	var chartroom = Rules.floor_named("chartroom")
	var truth: Dictionary = Rules.accurate_sheet(floor)
	if not Rules.census_accepted(truth, floor):
		return "the true bell loft census was rejected"
	var bill: Dictionary = Rules.payout(truth, floor)
	if int(bill.corridors) != 69 or int(bill.hazards) != 13 or int(bill.loop) != 1:
		return "true counts %s/%s loop %s" % [bill.corridors, bill.hazards, bill.loop]
	if int(bill.corridor_pay) != 69 * Rules.CORRIDOR_VALUE:
		return "corridor pay drifted"
	if int(bill.hazard_pay) != 13 * Rules.HAZARD_VALUE:
		return "hazard pay drifted"
	if int(bill.loop_pay) != Rules.LOOP_VALUE:
		return "ring pay drifted"
	var arithmetic := 69 * 3 + 13 * 8 + 15
	if int(bill.total) != arithmetic or int(bill.total) != 326:
		return "true total %s, expected %s" % [bill.total, arithmetic]
	if Rules.format_bill(bill).find("Bell loft ring") < 0:
		return "the receipt did not name the bell loft ring"
	if Rules.census_accepted({}, floor):
		return "an empty sheet was accepted"
	if int(Rules.payout({}, floor).total) != 0:
		return "an empty sheet paid out"
	var missing_corridor: Dictionary = truth.duplicate()
	missing_corridor.erase(Rules.start_pos(floor))
	if Rules.census_accepted(missing_corridor, floor):
		return "a sheet missing the start corridor was accepted"
	var missing_bill: Dictionary = Rules.payout(missing_corridor, floor)
	if int(missing_bill.total) >= 326 or int(missing_bill.loop) != 1:
		return "dropping a corridor outside the ring changed the census the wrong way"
	var crack: Vector2i = Rules.hazard_cells(floor)[0]
	var missing_crack: Dictionary = truth.duplicate()
	missing_crack.erase(crack)
	if Rules.census_accepted(missing_crack, floor):
		return "a sheet missing a bell crack was accepted"
	if int(Rules.payout(missing_crack, floor).total) >= 326:
		return "dropping a bell crack did not lower pay"
	var broken_ring: Dictionary = truth.duplicate()
	var rim: Vector2i = Rules.loop_cells(floor)[0]
	broken_ring[rim] = Rules.Mark.WALL
	if Rules.census_accepted(broken_ring, floor):
		return "a broken ring was accepted"
	var broken_bill: Dictionary = Rules.payout(broken_ring, floor)
	if int(broken_bill.loop) != 0 or int(broken_bill.total) >= 326:
		return "a broken ring still paid as a finished sheet"
	var swapped: Dictionary = truth.duplicate()
	swapped[crack] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(swapped, floor):
		return "a bell crack marked as a corridor was accepted"
	if int(Rules.payout(swapped, floor).hazard_pay) >= int(bill.hazard_pay):
		return "mislabeling a bell crack did not lower hazard pay"
	if int(Rules.payout(swapped, floor).total) > 326:
		return "mislabeling a bell crack raised the payout"
	var corridor: Vector2i = Rules.lift_pos(floor)
	var swapped_corridor: Dictionary = truth.duplicate()
	swapped_corridor[corridor] = Rules.Mark.HAZARD
	if Rules.census_accepted(swapped_corridor, floor):
		return "the lift marked as a hazard was accepted"
	if int(Rules.payout(swapped_corridor, floor).total) > 326:
		return "marking the lift as a hazard raised the payout"
	var false_wall: Dictionary = truth.duplicate()
	false_wall[Vector2i(0, 0)] = Rules.Mark.HAZARD
	if Rules.census_accepted(false_wall, floor):
		return "a hazard mark on a wall was accepted"
	if int(Rules.payout(false_wall, floor).total) != 326 or int(Rules.payout(false_wall, floor).hazard_pay) != int(bill.hazard_pay):
		return "a hazard mark on a wall changed the payout"
	var bell_wall: Dictionary = truth.duplicate()
	bell_wall[Vector2i(6, 4)] = Rules.Mark.WALL
	if not Rules.census_accepted(bell_wall, floor):
		return "inking the bell as a wall rejected a true census"
	bell_wall[Vector2i(6, 4)] = Rules.Mark.HAZARD
	if Rules.census_accepted(bell_wall, floor):
		return "calling the bell a hazard was accepted"
	var warden_mark: Dictionary = truth.duplicate()
	warden_mark[Rules.enemy_pos(floor)] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(warden_mark, floor):
		return "the warden tile was accepted as a corridor"
	if int(Rules.payout(warden_mark, floor).total) != 326:
		return "marking the warden changed the payout"
	var only_ring := {}
	for cell in Rules.loop_cells(floor):
		only_ring[cell] = Rules.Mark.CORRIDOR
	if Rules.census_accepted(only_ring, floor):
		return "the ring alone was accepted as the census"
	var ring_bill: Dictionary = Rules.payout(only_ring, floor)
	if int(ring_bill.loop) != 1 or int(ring_bill.hazards) != 0 or int(ring_bill.total) >= 326:
		return "the ring bonus did not stay inside the shared payout rule"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cellar):
		return "the bell loft sheet was accepted as the cellar"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cistern):
		return "the bell loft sheet was accepted as the cistern"
	if Rules.census_accepted(Rules.accurate_sheet(floor), cloister):
		return "the bell loft sheet was accepted as the cloister"
	if Rules.census_accepted(Rules.accurate_sheet(floor), crypt):
		return "the bell loft sheet was accepted as the crypt"
	if Rules.census_accepted(Rules.accurate_sheet(floor), ossuary):
		return "the bell loft sheet was accepted as the ossuary"
	if Rules.census_accepted(Rules.accurate_sheet(floor), reliquary):
		return "the bell loft sheet was accepted as the reliquary"
	if Rules.census_accepted(Rules.accurate_sheet(floor), undercroft):
		return "the bell loft sheet was accepted as the undercroft"
	if Rules.census_accepted(Rules.accurate_sheet(floor), wellhouse):
		return "the bell loft sheet was accepted as the well house"
	if Rules.census_accepted(Rules.accurate_sheet(floor), scriptorium):
		return "the bell loft sheet was accepted as the scriptorium"
	if Rules.census_accepted(Rules.accurate_sheet(floor), binding):
		return "the bell loft sheet was accepted as the binding"
	if Rules.census_accepted(Rules.accurate_sheet(floor), chartroom):
		return "the bell loft sheet was accepted as the chart room"
	if Rules.census_accepted(Rules.accurate_sheet(cellar), floor):
		return "the cellar sheet was accepted as the bell loft"
	if Rules.census_accepted(Rules.accurate_sheet(cistern), floor):
		return "the cistern sheet was accepted as the bell loft"
	if Rules.census_accepted(Rules.accurate_sheet(cloister), floor):
		return "the cloister sheet was accepted as the bell loft"
	if Rules.census_accepted(Rules.accurate_sheet(crypt), floor):
		return "the crypt sheet was accepted as the bell loft"
	if Rules.census_accepted(Rules.accurate_sheet(ossuary), floor):
		return "the ossuary sheet was accepted as the bell loft"
	if Rules.census_accepted(Rules.accurate_sheet(reliquary), floor):
		return "the reliquary sheet was accepted as the bell loft"
	if Rules.census_accepted(Rules.accurate_sheet(undercroft), floor):
		return "the undercroft sheet was accepted as the bell loft"
	if Rules.census_accepted(Rules.accurate_sheet(wellhouse), floor):
		return "the well house sheet was accepted as the bell loft"
	if Rules.census_accepted(Rules.accurate_sheet(scriptorium), floor):
		return "the scriptorium sheet was accepted as the bell loft"
	if Rules.census_accepted(Rules.accurate_sheet(binding), floor):
		return "the binding sheet was accepted as the bell loft"
	if Rules.census_accepted(Rules.accurate_sheet(chartroom), floor):
		return "the chart room sheet was accepted as the bell loft"
	if not Rules.census_accepted(Rules.accurate_sheet(cellar), cellar):
		return "the cellar's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(cistern), cistern):
		return "the cistern's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(cloister), cloister):
		return "the cloister's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(crypt), crypt):
		return "the crypt's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(ossuary), ossuary):
		return "the ossuary's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(reliquary), reliquary):
		return "the reliquary's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(undercroft), undercroft):
		return "the undercroft's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(wellhouse), wellhouse):
		return "the well house's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(scriptorium), scriptorium):
		return "the scriptorium's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(binding), binding):
		return "the binding's true census was rejected"
	if not Rules.census_accepted(Rules.accurate_sheet(chartroom), chartroom):
		return "the chart room's true census was rejected"
	var cellar_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cellar), cellar)
	if int(cellar_bill.total) != 211 or str(cellar_bill.loop_name) != "East square":
		return "the cellar payout changed"
	var cistern_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cistern), cistern)
	if int(cistern_bill.total) != 288 or str(cistern_bill.loop_name) != "Cistern ring":
		return "the cistern payout changed"
	var cloister_bill: Dictionary = Rules.payout(Rules.accurate_sheet(cloister), cloister)
	if int(cloister_bill.total) != 242 or str(cloister_bill.loop_name) != "Cloister walk":
		return "the cloister payout changed"
	var crypt_bill: Dictionary = Rules.payout(Rules.accurate_sheet(crypt), crypt)
	if int(crypt_bill.total) != 316 or str(crypt_bill.loop_name) != "Crypt ring":
		return "the crypt payout changed"
	var ossuary_bill: Dictionary = Rules.payout(Rules.accurate_sheet(ossuary), ossuary)
	if int(ossuary_bill.total) != 240 or str(ossuary_bill.loop_name) != "Ossuary ring":
		return "the ossuary payout changed"
	var reliquary_bill: Dictionary = Rules.payout(Rules.accurate_sheet(reliquary), reliquary)
	if int(reliquary_bill.total) != 251 or str(reliquary_bill.loop_name) != "Reliquary ring":
		return "the reliquary payout changed"
	var undercroft_bill: Dictionary = Rules.payout(Rules.accurate_sheet(undercroft), undercroft)
	if int(undercroft_bill.total) != 238 or str(undercroft_bill.loop_name) != "Undercroft ring":
		return "the undercroft payout changed"
	var well_bill: Dictionary = Rules.payout(Rules.accurate_sheet(wellhouse), wellhouse)
	if int(well_bill.total) != 225 or str(well_bill.loop_name) != "Well ring":
		return "the well house payout changed"
	var scriptorium_bill: Dictionary = Rules.payout(Rules.accurate_sheet(scriptorium), scriptorium)
	if int(scriptorium_bill.total) != 263 or str(scriptorium_bill.loop_name) != "Scriptorium ring":
		return "the scriptorium payout changed"
	var binding_bill: Dictionary = Rules.payout(Rules.accurate_sheet(binding), binding)
	if int(binding_bill.total) != 343 or str(binding_bill.loop_name) != "Binding ring":
		return "the binding payout changed"
	var chart_bill: Dictionary = Rules.payout(Rules.accurate_sheet(chartroom), chartroom)
	if int(chart_bill.total) != 306 or str(chart_bill.loop_name) != "Chart room ring":
		return "the chart room payout changed"
	var approach: Vector2i = Rules.walkable_approach(crack, floor)
	if approach.x < 0:
		return "bell crack has no approach"
	var walker = Rules.new_run(Rules.SMALL_FLASK_OIL, floor)
	walker.pos = approach
	walker.oil = 10
	var before: int = walker.oil
	var stepped: Dictionary = Rules.step(walker, crack - approach)
	if bool(stepped.hit):
		return "opening bell step was a swing"
	if walker.oil != before - Rules.MOVE_OIL:
		return "a bell crack burned extra oil"
	if int(walker.marks.get(crack, Rules.Mark.NONE)) != Rules.Mark.HAZARD:
		return "a bell crack was not inked as a hazard"
	return ""


func _bellloft_return() -> String:
	var game_script = load("res://scripts/game.gd")
	var select_script = load("res://scripts/floor_select_view.gd")
	if game_script == null or select_script == null:
		return "game or floor select did not load"
	var game = game_script.new()
	root.add_child(game)
	if game.town == null or game.floor_select == null or game.descent == null:
		game.free()
		return "the game did not build its screens"
	if game.floor_select.record_for("bellloft") != Rules.BELL_RECORD:
		game.free()
		return "floor select does not offer the bell loft census"
	if game.floor_select.record_for("cellar") != Rules.CELLAR_RECORD:
		game.free()
		return "floor select dropped the cellar census"
	if game.floor_select.record_for("cistern") != Rules.CISTERN_RECORD:
		game.free()
		return "floor select dropped the cistern census"
	if game.floor_select.record_for("cloister") != Rules.CLOISTER_RECORD:
		game.free()
		return "floor select dropped the cloister census"
	if game.floor_select.record_for("crypt") != Rules.CRYPT_RECORD:
		game.free()
		return "floor select dropped the crypt census"
	if game.floor_select.record_for("ossuary") != Rules.OSSUARY_RECORD:
		game.free()
		return "floor select dropped the ossuary census"
	if game.floor_select.record_for("reliquary") != Rules.RELIQUARY_RECORD:
		game.free()
		return "floor select dropped the reliquary census"
	if game.floor_select.record_for("undercroft") != Rules.UNDERCROFT_RECORD:
		game.free()
		return "floor select dropped the undercroft census"
	if game.floor_select.record_for("wellhouse") != Rules.WELL_RECORD:
		game.free()
		return "floor select dropped the well house census"
	if game.floor_select.record_for("scriptorium") != Rules.SCRIPTORIUM_RECORD:
		game.free()
		return "floor select dropped the scriptorium census"
	if game.floor_select.record_for("binding") != Rules.BINDING_RECORD:
		game.free()
		return "floor select dropped the binding census"
	if game.floor_select.record_for("chartroom") != Rules.CHART_RECORD:
		game.free()
		return "floor select dropped the chart room census"
	if game.floor_select.status_for("bellloft") != "Census open":
		game.free()
		return "the bell loft card did not open"
	game._on_descend_floor("bellloft")
	if game.descent.state == null or game.descent.state.floor.id != "bellloft":
		game.free()
		return "descend did not open the bell loft"
	var state = game.descent.state
	var lift: Vector2i = Rules.lift_pos(state.floor)
	var approach: Vector2i = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var left: Dictionary = Rules.step(state, lift - approach)
	if not bool(left.extracted):
		game.free()
		return "short bell loft sheet did not leave on the lift"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to town":
		game.free()
		return "a short sheet offered the floor select"
	game._on_return(state)
	if not game.town.visible or game.floor_select.visible or game.descent.visible:
		game.free()
		return "a short census did not return to town"
	if bool(game.campaign.completed.get("bellloft", false)):
		game.free()
		return "a short census was accepted"
	if game.town.outcome_label.text.find("not finished") < 0:
		game.free()
		return "the clerk treated a short sheet as finished"
	game._on_floors()
	if not game.floor_select.visible or game.town.visible:
		game.free()
		return "floor select did not open from town"
	game._on_descend_floor("bellloft")
	state = game.descent.state
	state.marks = Rules.accurate_sheet(state.floor)
	lift = Rules.lift_pos(state.floor)
	approach = Rules.walkable_approach(lift, state.floor)
	state.pos = approach
	state.oil = 5
	var done: Dictionary = Rules.step(state, lift - approach)
	if not bool(done.extracted) or not Rules.census_accepted(state.marks, state.floor):
		game.free()
		return "the finished sheet did not extract as an accepted census"
	game.descent._open_return()
	if game.descent.return_button.text != "Return to floor select":
		game.free()
		return "a finished census did not offer the floor select"
	game._on_return(state)
	if not game.floor_select.visible or game.town.visible or game.descent.visible:
		game.free()
		return "a finished census did not return to the floor select"
	if not bool(game.campaign.completed.get("bellloft", false)):
		game.free()
		return "the finished census was not recorded"
	if bool(game.campaign.completed.get("cellar", false)) or bool(game.campaign.completed.get("cistern", false)) or bool(game.campaign.completed.get("cloister", false)) or bool(game.campaign.completed.get("crypt", false)) or bool(game.campaign.completed.get("ossuary", false)) or bool(game.campaign.completed.get("reliquary", false)) or bool(game.campaign.completed.get("undercroft", false)) or bool(game.campaign.completed.get("wellhouse", false)) or bool(game.campaign.completed.get("scriptorium", false)) or bool(game.campaign.completed.get("binding", false)) or bool(game.campaign.completed.get("chartroom", false)):
		game.free()
		return "another floor was marked complete"
	if game.floor_select.status_for("bellloft") != "Census complete":
		game.free()
		return "floor select did not show the bell loft census complete"
	if game.floor_select.status_for("cellar") != "Census open" or game.floor_select.status_for("cistern") != "Census open" or game.floor_select.status_for("cloister") != "Census open" or game.floor_select.status_for("crypt") != "Census open" or game.floor_select.status_for("ossuary") != "Census open" or game.floor_select.status_for("reliquary") != "Census open" or game.floor_select.status_for("undercroft") != "Census open" or game.floor_select.status_for("wellhouse") != "Census open" or game.floor_select.status_for("scriptorium") != "Census open" or game.floor_select.status_for("binding") != "Census open" or game.floor_select.status_for("chartroom") != "Census open":
		game.free()
		return "another floor card was closed"
	if game.floor_select.notice_label.text.find("complete") < 0:
		game.free()
		return "arrival did not say the census is complete"
	if game.campaign.purse < 326 or game.campaign.last_outcome != "complete":
		game.free()
		return "the finished census was not paid"
	game._show_town()
	if not game.town.visible or game.floor_select.visible:
		game.free()
		return "Back to town did not leave the floor select"
	if game.town.outcome_label.text.find("complete") < 0:
		game.free()
		return "town clerk did not keep the finished census"
	game.free()
	return ""
