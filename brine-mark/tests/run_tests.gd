extends SceneTree

# Headless checks for the Salt Coast slice.
# Exit 0 when every check passes, 1 otherwise.
#   godot --headless --path . -s res://tests/run_tests.gd

const Sim = preload("res://scripts/sim.gd")


func _initialize() -> void:
	var errors: Array = []
	print("Brine Mark tests")
	_test_quota(errors)
	_test_all_rake(errors)
	_test_determinism(errors)
	_test_population(errors)
	_test_no_select_ant(errors)
	_test_scene_boots(errors)
	if errors.is_empty():
		print("ALL TESTS PASSED")
		quit(0)
	else:
		for message in errors:
			print("FAIL: %s" % message)
		print("%d TEST(S) FAILED" % errors.size())
		quit(1)


func _test_quota(errors: Array) -> void:
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var before := errors.size()
	var sim = _run_plan(plans, "winning", errors)
	if sim == null:
		if errors.size() == before:
			_fail(errors, "winning plan did not run")
		return
	var stored := int(sim.get_stored_salt())
	print("win stored=%d loose=%d stacked=%d pop=%d max_pop=%d summary=%s" % [
		stored,
		sim.get_loose_salt(),
		sim.get_stacked_salt(),
		sim.get_population(),
		sim.get_max_population(),
		sim.get_summary(),
	])
	if not sim.is_over():
		_fail(errors, "winning plan did not reach the rain")
	if stored < Sim.QUOTA:
		_fail(errors, "winning plan stored %d, quota is %d. %s" % [stored, Sim.QUOTA, _debug(sim)])
	var summary := String(sim.get_summary()).to_lower()
	if summary.contains("quota missed"):
		_fail(errors, "winning plan summary says the quota was missed: %s" % sim.get_summary())
	_assert_pop(sim, errors, "winning plan")


func _test_all_rake(errors: Array) -> void:
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var before := errors.size()
	var sim = _run_plan(plans, "all_rake", errors)
	if sim == null:
		if errors.size() == before:
			_fail(errors, "all-rake plan did not run")
		return
	var stored := int(sim.get_stored_salt())
	var summary := String(sim.get_summary())
	print("rake stored=%d destroyed=%d summary=%s" % [stored, sim.get_uncovered_destroyed(), summary])
	if stored >= Sim.QUOTA:
		_fail(errors, "all-rake plan should miss the quota, stored %d" % stored)
	if not summary.to_lower().contains("uncovered salt"):
		_fail(errors, "all-rake summary should name uncovered salt, got: %s" % summary)
	for y in Sim.GRID_H:
		for x in Sim.GRID_W:
			var paint := int(sim.get_paint(x, y))
			if paint != Sim.EMPTY and paint != Sim.RAKE:
				_fail(errors, "all-rake plan left a non-rake mark at %d,%d" % [x, y])
				return
	_assert_pop(sim, errors, "all-rake plan")


func _test_determinism(errors: Array) -> void:
	var plans := _plans(errors)
	if plans.is_empty():
		return
	for plan_name in ["winning", "all_rake"]:
		var before := errors.size()
		var first = _run_plan(plans, plan_name, errors)
		var second = _run_plan(plans, plan_name, errors)
		if first == null or second == null:
			if errors.size() == before:
				_fail(errors, "%s determinism run did not start" % plan_name)
			return
		var a := int(first.get_stored_salt())
		var b := int(second.get_stored_salt())
		print("determinism %s stored %d and %d" % [plan_name, a, b])
		if a != b:
			_fail(errors, "%s runs stored %d and %d" % [plan_name, a, b])
		if String(first.get_summary()) != String(second.get_summary()):
			_fail(errors, "%s summaries differed" % plan_name)
		_assert_pop(first, errors, plan_name + " run A")
		_assert_pop(second, errors, plan_name + " run B")


func _test_population(errors: Array) -> void:
	if int(Sim.POP_CAP) != 40:
		_fail(errors, "slice population cap is %s, expected 40" % Sim.POP_CAP)
	# The spawn schedule would pass 40 if the cap were ignored.
	var attempts := 0
	for tick_index in range(1, int(Sim.RAIN_TICK)):
		if tick_index % int(Sim.SPAWN_EVERY) == 0:
			attempts += 1
	var uncapped := int(Sim.INITIAL_POP) + attempts
	if uncapped <= 40:
		_fail(errors, "spawn schedule never reaches the cap (uncapped %d)" % uncapped)
	else:
		print("population schedule would be %d without the cap" % uncapped)


func _test_no_select_ant(errors: Array) -> void:
	var sim = Sim.new()
	var api: PackedStringArray = sim.rules_api()
	for name in api:
		var lowered := String(name).to_lower()
		if lowered.contains("select"):
			_fail(errors, "rules API exposes a selection method: %s" % name)
		if not sim.has_method(name):
			_fail(errors, "rules API lists missing method %s" % name)
	var pattern := RegEx.new()
	pattern.compile("(?i)func\\s+select[_a-z0-9]*ant|func\\s+select[_a-z0-9]*unit|func\\s+selectant")
	for path in ["res://scripts/sim.gd", "res://scripts/main.gd"]:
		var source := FileAccess.get_file_as_string(path)
		if source.is_empty():
			_fail(errors, "script source unavailable for the rules API scan: %s" % path)
			continue
		var found := pattern.search(source)
		if found != null:
			_fail(errors, "found a select-ant function: %s" % found.get_string())
	for method in sim.get_method_list():
		var method_name := String(method["name"]).to_lower()
		if method_name.contains("select") and method_name.contains("ant"):
			_fail(errors, "sim method selects an ant: %s" % method["name"])
	print("rules API has no select-ant function")


func _test_scene_boots(errors: Array) -> void:
	var packed = load("res://scenes/main.tscn")
	if packed == null:
		_fail(errors, "main scene failed to load")
		return
	var node = packed.instantiate()
	if node == null:
		_fail(errors, "main scene failed to instantiate")
		return
	# Ready the interface without a displayed frame. add_child during this
	# main-loop startup defers _ready, so call it once here.
	node._ready()
	node._on_key(KEY_RIGHT)
	node._on_key(KEY_1)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(9, 5)) != Sim.RAKE:
		_fail(errors, "keyboard cursor did not paint rake")
	node._paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.TRAIL)
	if int(node.sim.get_paint(Sim.ANTHILL.x, Sim.ANTHILL.y)) != Sim.EMPTY:
		_fail(errors, "the anthill accepted a mark")
	node._on_key(KEY_R)
	if int(node.sim.get_paint(9, 5)) != Sim.EMPTY:
		_fail(errors, "restart scenario did not clear the marks")
	if int(node.sim.get_population()) > Sim.POP_CAP:
		_fail(errors, "restart left the population over the cap")
	var countdown = node.find_child("RainCountdown", true, false)
	if countdown == null or not String(countdown.text).contains("Rain"):
		_fail(errors, "rain countdown is missing from the scene")
	var restart = node.find_child("RestartScenario", true, false)
	if restart == null or String(restart.text) != "Restart scenario":
		_fail(errors, "restart scenario control is missing from the scene")
	node.free()
	print("main scene instantiated")


func _plans(errors: Array) -> Dictionary:
	var file := FileAccess.open("res://tests/plans.json", FileAccess.READ)
	if file == null:
		_fail(errors, "could not open plans.json")
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		_fail(errors, "plans.json is not an object")
		return {}
	return parsed


func _run_plan(plans: Dictionary, plan_name: String, errors: Array):
	if not plans.has(plan_name):
		_fail(errors, "missing plan %s" % plan_name)
		return null
	var anthill: Array = plans["anthill"]
	if int(anthill[0]) != Sim.ANTHILL.x or int(anthill[1]) != Sim.ANTHILL.y:
		_fail(errors, "plan anthill does not match the scenario anthill")
		return null
	var sim = Sim.new()
	var before := errors.size()
	var plan: Dictionary = plans[plan_name]
	if plan.has("rake"):
		_apply_cells(sim, plan["rake"], Sim.RAKE, errors)
	if plan.has("stack"):
		_apply_cells(sim, plan["stack"], Sim.STACK, errors)
	if plan.has("cover"):
		_apply_cells(sim, plan["cover"], Sim.COVER, errors)
	if plan.has("trail"):
		_apply_cells(sim, plan["trail"], Sim.TRAIL, errors)
	if plan.has("rake_rect"):
		_apply_rect(sim, plan["rake_rect"], Sim.RAKE, errors)
	if errors.size() > before:
		return null
	sim.run_until_rain()
	return sim


func _apply_cells(sim, cells: Array, mode: int, errors: Array) -> void:
	for pair in cells:
		var x := int(pair[0])
		var y := int(pair[1])
		if not sim.paint_cell(x, y, mode):
			_fail(errors, "paint rejected %d,%d mode %d" % [x, y, mode])


func _apply_rect(sim, rect: Array, mode: int, errors: Array) -> void:
	var x0 := int(rect[0])
	var y0 := int(rect[1])
	var x1 := int(rect[2])
	var y1 := int(rect[3])
	for y in range(y0, y1 + 1):
		for x in range(x0, x1 + 1):
			if not sim.paint_cell(x, y, mode):
				_fail(errors, "paint rejected %d,%d mode %d" % [x, y, mode])


func _assert_pop(sim, errors: Array, label: String) -> void:
	if int(sim.get_population()) > 40 or int(sim.get_max_population()) > 40:
		_fail(errors, "%s population exceeded 40 (now %d, max %d)" % [
			label, sim.get_population(), sim.get_max_population(),
		])
	if int(sim.get_max_population()) != 40:
		_fail(errors, "%s population max was %d, expected the cap of 40" % [label, sim.get_max_population()])
	if int(sim.get_pop_cap_violations()) > 0:
		_fail(errors, "%s recorded a population-cap violation" % label)


func _debug(sim) -> String:
	var tally := {}
	for ant in sim.get_ant_draw_positions():
		var key := "%d@%d,%d" % [int(ant["job"]), int(ant["x"]), int(ant["y"])]
		tally[key] = int(tally.get(key, 0)) + 1
	return "ants=%s" % str(tally)


func _fail(errors: Array, message: String) -> void:
	errors.append(message)
