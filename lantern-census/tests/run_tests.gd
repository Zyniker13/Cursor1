extends SceneTree

const Rules := preload("res://scripts/census_rules.gd")

var _done := false
var _failed := 0
var _passed := 0


func _init() -> void:
	call_deferred("_boot")


func _initialize() -> void:
	_boot()


func _boot() -> void:
	if _done:
		return
	_done = true
	var code := _run()
	quit(code)


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
	print("----")
	if _failed > 0:
		print("FAILED %d  passed %d" % [_failed, _passed])
		return 1
	print("ALL PASSED %d" % _passed)
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
