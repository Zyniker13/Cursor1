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
	_test_dry_season(errors)
	_test_cart(errors)
	_test_ship(errors)
	_test_market(errors)
	_test_yard(errors)
	_test_bunk(errors)
	_test_loft(errors)
	_test_gate(errors)
	_test_wage(errors)
	_test_relief(errors)
	_test_watch(errors)
	_test_lamp(errors)
	_test_bell(errors)
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
	for plan_name in ["winning", "all_rake", "dry_pans", "continued", "late_pans", "no_crib", "carted", "late_crib", "dry_crib", "no_ship", "shipped", "late_ship", "dry_ship", "no_stall", "sold", "late_sold", "dry_sold", "no_yard", "banked", "late_banked", "dry_banked", "no_bunk", "hired", "late_hired", "dry_hired", "no_loft", "lofted", "late_lofted", "dry_lofted", "no_gate", "gated", "late_gated", "dry_gated", "no_wage", "paid", "late_paid", "dry_paid", "no_relief", "posted", "late_posted", "dry_posted", "no_watch", "stood", "late_stood", "dry_stood", "watch_only", "no_lamp", "lit", "late_lit", "dry_lit", "lamp_only", "no_bell", "rung", "late_rung", "dry_rung", "bell_only"]:
		var before := errors.size()
		var first = _run_plan(plans, plan_name, errors)
		var second = _run_plan(plans, plan_name, errors)
		if first == null or second == null:
			if errors.size() == before:
				_fail(errors, "%s determinism run did not start" % plan_name)
			return
		var a := int(first.get_stored_salt())
		var b := int(second.get_stored_salt())
		print("determinism %s stored %d and %d coins %d banked %d hired %d left %d lofted %d gated %d paid %d posted %d stood %d lit %d" % [plan_name, a, b, int(first.get_coins()), int(first.get_banked()), int(first.get_hired()), int(first.get_yard_left()), int(first.get_lofted()), int(first.get_gated()), int(first.get_paid()), int(first.get_posted()), int(first.get_stood()), int(first.get_lit())])
		if a != b:
			_fail(errors, "%s runs stored %d and %d" % [plan_name, a, b])
		if int(first.get_wet_haul()) != int(second.get_wet_haul()):
			_fail(errors, "%s wet hauls differed" % plan_name)
		if int(first.get_carted()) != int(second.get_carted()):
			_fail(errors, "%s cart totals differed" % plan_name)
		if int(first.get_shipped()) != int(second.get_shipped()):
			_fail(errors, "%s ship totals differed" % plan_name)
		if int(first.get_coins()) != int(second.get_coins()):
			_fail(errors, "%s coin totals differed" % plan_name)
		if int(first.get_banked()) != int(second.get_banked()):
			_fail(errors, "%s banked totals differed" % plan_name)
		if int(first.get_hired()) != int(second.get_hired()) or int(first.get_yard_left()) != int(second.get_yard_left()):
			_fail(errors, "%s hire runs differed (%d left %d, and %d left %d)" % [
				plan_name, first.get_hired(), first.get_yard_left(), second.get_hired(), second.get_yard_left(),
			])
		if int(first.get_lofted()) != int(second.get_lofted()):
			_fail(errors, "%s loft runs differed (%d and %d)" % [plan_name, first.get_lofted(), second.get_lofted()])
		if int(first.get_gated()) != int(second.get_gated()) or int(first.get_loft_left()) != int(second.get_loft_left()):
			_fail(errors, "%s gate runs differed (%d left %d, and %d left %d)" % [
				plan_name, first.get_gated(), first.get_loft_left(), second.get_gated(), second.get_loft_left(),
			])
		if int(first.get_paid()) != int(second.get_paid()) or int(first.get_gate_left()) != int(second.get_gate_left()):
			_fail(errors, "%s wage runs differed (%d unpaid %d, and %d unpaid %d)" % [
				plan_name, first.get_paid(), first.get_gate_left(), second.get_paid(), second.get_gate_left(),
			])
		if int(first.get_posted()) != int(second.get_posted()) or int(first.get_wage_left()) != int(second.get_wage_left()):
			_fail(errors, "%s relief runs differed (%d unposted %d, and %d unposted %d)" % [
				plan_name, first.get_posted(), first.get_wage_left(), second.get_posted(), second.get_wage_left(),
			])
		if int(first.get_stood()) != int(second.get_stood()) or int(first.get_relief_left()) != int(second.get_relief_left()):
			_fail(errors, "%s watch runs differed (%d unstood %d, and %d unstood %d)" % [
				plan_name, first.get_stood(), first.get_relief_left(), second.get_stood(), second.get_relief_left(),
			])
		if int(first.get_lit()) != int(second.get_lit()) or int(first.get_watch_left()) != int(second.get_watch_left()):
			_fail(errors, "%s lamp runs differed (%d unlit %d, and %d unlit %d)" % [
				plan_name, first.get_lit(), first.get_watch_left(), second.get_lit(), second.get_watch_left(),
			])
		if int(first.get_rung()) != int(second.get_rung()) or int(first.get_lamp_left()) != int(second.get_lamp_left()):
			_fail(errors, "%s bell runs differed (%d unrung %d, and %d unrung %d)" % [
				plan_name, first.get_rung(), first.get_lamp_left(), second.get_rung(), second.get_lamp_left(),
			])
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
	if not node.has_method("_ready"):
		_fail(errors, "main scene script did not attach")
		node.free()
		return
	# Ready the interface without a displayed frame. add_child during this
	# main-loop startup defers _ready, so call it once here.
	node._ready()
	node._on_key(KEY_RIGHT)
	node._on_key(KEY_1)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(9, 5)) != Sim.RAKE:
		_fail(errors, "keyboard cursor did not paint rake")
	node._on_key(KEY_5)
	if not String(node.mode_label.text).contains("Pan"):
		_fail(errors, "pan mark was not named")
	node._on_key(KEY_LEFT)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(8, 5)) != Sim.PAN:
		_fail(errors, "keyboard cursor did not paint a pan")
	node._on_key(KEY_6)
	if not String(node.mode_label.text).contains("Crib"):
		_fail(errors, "crib mark was not named")
	node._on_key(KEY_DOWN)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(8, 6)) != Sim.CRIB:
		_fail(errors, "keyboard cursor did not paint a crib")
	node._on_key(KEY_7)
	if not String(node.mode_label.text).contains("Ship"):
		_fail(errors, "ship mark was not named")
	node._on_key(KEY_LEFT)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(7, 6)) != Sim.SHIP:
		_fail(errors, "keyboard cursor did not paint a ship")
	node._on_key(KEY_8)
	if not String(node.mode_label.text).contains("Stall"):
		_fail(errors, "stall mark was not named")
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(7, 5)) != Sim.STALL:
		_fail(errors, "keyboard cursor did not paint a stall")
	node._on_key(KEY_9)
	if not String(node.mode_label.text).contains("Yard"):
		_fail(errors, "yard mark was not named")
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(7, 4)) != Sim.YARD:
		_fail(errors, "keyboard cursor did not paint a yard")
	node._on_key(KEY_0)
	if not String(node.mode_label.text).contains("Bunk"):
		_fail(errors, "bunk mark was not named")
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(7, 3)) != Sim.BUNK:
		_fail(errors, "keyboard cursor did not paint a bunk")
	node._on_key(KEY_B)
	if not String(node.mode_label.text).contains("Loft"):
		_fail(errors, "loft mark was not named")
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(7, 2)) != Sim.LOFT:
		_fail(errors, "keyboard cursor did not paint a loft")
	node._on_key(KEY_C)
	if not String(node.mode_label.text).contains("Gate"):
		_fail(errors, "gate mark was not named")
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(7, 1)) != Sim.GATE:
		_fail(errors, "keyboard cursor did not paint a gate")
	node._on_key(KEY_E)
	if not String(node.mode_label.text).contains("Wage"):
		_fail(errors, "wage mark was not named")
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(7, 0)) != Sim.WAGE:
		_fail(errors, "keyboard cursor did not paint a wage")
	node._on_key(KEY_F)
	if not String(node.mode_label.text).contains("Relief"):
		_fail(errors, "relief mark was not named")
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(7, -1)) != Sim.RELIEF:
		_fail(errors, "keyboard cursor did not paint a relief")
	node._on_key(KEY_G)
	if not String(node.mode_label.text).contains("Watch"):
		_fail(errors, "watch mark was not named")
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(7, -2)) != Sim.WATCH:
		_fail(errors, "keyboard cursor did not paint a watch")
	node._on_key(KEY_H)
	if not String(node.mode_label.text).contains("Lamp"):
		_fail(errors, "lamp mark was not named")
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(7, -3)) != Sim.LAMP:
		_fail(errors, "keyboard cursor did not paint a lamp")
	node._on_key(KEY_I)
	if not String(node.mode_label.text).contains("Bell"):
		_fail(errors, "bell mark was not named")
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(7, -4)) != Sim.BELL:
		_fail(errors, "keyboard cursor did not paint a bell")
	var season = node.find_child("SeasonNote", true, false)
	if season == null or not String(season.text).to_lower().contains("pan"):
		_fail(errors, "season note does not mention pans")
	if not String(node.rain_label.text).contains("Rain"):
		_fail(errors, "rain countdown lost the rain label")
	node._paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.TRAIL)
	if int(node.sim.get_paint(Sim.ANTHILL.x, Sim.ANTHILL.y)) != Sim.EMPTY:
		_fail(errors, "the anthill accepted a mark")
	var spun := 0
	while int(node.sim.get_beat()) != Sim.CART and not node.sim.is_over() and spun < int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + 2:
		node.sim.tick()
		spun += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.CART or node.sim.is_over():
		_fail(errors, "the scene did not open the cart beat")
	elif not String(node.rain_label.text).to_lower().contains("cart"):
		_fail(errors, "cart countdown was not named: %s" % node.rain_label.text)
	elif not String(node.season_label.text).to_lower().contains("crib"):
		_fail(errors, "cart note does not mention the crib: %s" % node.season_label.text)
	var rules = node.find_child("RulesNote", true, false)
	if rules == null or not String(rules.text).to_lower().contains("crib"):
		_fail(errors, "rules text does not mention the crib")
	if rules == null or not String(rules.text).to_lower().contains("ship"):
		_fail(errors, "rules text does not mention the ship")
	if rules == null or not String(rules.text).to_lower().contains("stall"):
		_fail(errors, "rules text does not mention the stall")
	if rules == null or not String(rules.text).to_lower().contains("yard"):
		_fail(errors, "rules text does not mention the yard")
	if rules == null or not String(rules.text).to_lower().contains("bunk"):
		_fail(errors, "rules text does not mention the bunk")
	if rules == null or not String(rules.text).to_lower().contains("loft"):
		_fail(errors, "rules text does not mention the loft")
	if rules == null or not String(rules.text).to_lower().contains("gate"):
		_fail(errors, "rules text does not mention the gate")
	if rules == null or not String(rules.text).to_lower().contains("wage"):
		_fail(errors, "rules text does not mention the wage")
	if rules == null or not String(rules.text).contains("four"):
		_fail(errors, "rules text does not name the four-coin wage")
	if rules == null or not String(rules.text).to_lower().contains("relief"):
		_fail(errors, "rules text does not mention the relief")
	if rules == null or not String(rules.text).contains("six"):
		_fail(errors, "rules text does not name the relief cap of six")
	if rules == null or not String(rules.text).to_lower().contains("watch"):
		_fail(errors, "rules text does not mention the watch")
	if rules == null or not String(rules.text).to_lower().contains("stand"):
		_fail(errors, "rules text does not name the watch")
	if rules == null or not String(rules.text).to_lower().contains("lamp"):
		_fail(errors, "rules text does not mention the lamp")
	if rules == null or not String(rules.text).to_lower().contains("three"):
		_fail(errors, "rules text does not name the lamp cap of three")
	if rules == null or not String(rules.text).to_lower().contains("bell"):
		_fail(errors, "rules text does not mention the bell")
	if rules == null or not String(rules.text).to_lower().contains("two"):
		_fail(errors, "rules text does not name the bell cap of two")
	var hint = node.find_child("HintLine", true, false)
	if hint == null or not String(hint.text).to_lower().contains("watch"):
		_fail(errors, "hint line does not name the watch")
	if hint == null or not String(hint.text).to_lower().contains("lamp"):
		_fail(errors, "hint line does not name the lamp")
	if hint == null or not String(hint.text).to_lower().contains("bell"):
		_fail(errors, "hint line does not name the bell")
	var spun_ship := 0
	while int(node.sim.get_beat()) != Sim.SHIPPING and not node.sim.is_over() and spun_ship < int(Sim.CART_TICK) + 2:
		node.sim.tick()
		spun_ship += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.SHIPPING or node.sim.is_over():
		_fail(errors, "the scene did not open the ship beat")
	elif not String(node.rain_label.text).to_lower().contains("ship"):
		_fail(errors, "ship countdown was not named: %s" % node.rain_label.text)
	elif not String(node.season_label.text).to_lower().contains("ship"):
		_fail(errors, "ship note does not mention the ship: %s" % node.season_label.text)
	var spun_market := 0
	while int(node.sim.get_beat()) != Sim.MARKET and not node.sim.is_over() and spun_market < int(Sim.SHIP_TICK) + 2:
		node.sim.tick()
		spun_market += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.MARKET or node.sim.is_over():
		_fail(errors, "the scene did not open the market beat")
	elif not String(node.rain_label.text).to_lower().contains("sell"):
		_fail(errors, "market countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.MARKET_TICK):
		_fail(errors, "market countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.MARKET_TICK])
	elif not String(node.season_label.text).to_lower().contains("stall"):
		_fail(errors, "market note does not mention the stall: %s" % node.season_label.text)
	var spun_yard := 0
	while int(node.sim.get_beat()) != Sim.YARDING and not node.sim.is_over() and spun_yard < int(Sim.MARKET_TICK) + 2:
		node.sim.tick()
		spun_yard += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.YARDING or node.sim.is_over():
		_fail(errors, "the scene did not open the yard beat")
	elif not String(node.rain_label.text).to_lower().contains("yard"):
		_fail(errors, "yard countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.YARD_TICK):
		_fail(errors, "yard countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.YARD_TICK])
	elif not String(node.season_label.text).to_lower().contains("yard"):
		_fail(errors, "yard note does not mention the yard: %s" % node.season_label.text)
	var spun_bunk := 0
	while int(node.sim.get_beat()) != Sim.BUNKING and not node.sim.is_over() and spun_bunk < int(Sim.YARD_TICK) + 2:
		node.sim.tick()
		spun_bunk += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.BUNKING or node.sim.is_over():
		_fail(errors, "the scene did not open the bunk beat")
	elif not String(node.rain_label.text).to_lower().contains("bunk"):
		_fail(errors, "bunk countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.BUNK_TICK):
		_fail(errors, "bunk countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.BUNK_TICK])
	elif not String(node.season_label.text).to_lower().contains("bunk"):
		_fail(errors, "bunk note does not mention the bunk: %s" % node.season_label.text)
	var spun_loft := 0
	while int(node.sim.get_beat()) != Sim.LOFTING and not node.sim.is_over() and spun_loft < int(Sim.BUNK_TICK) + 2:
		node.sim.tick()
		spun_loft += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.LOFTING or node.sim.is_over():
		_fail(errors, "the scene did not open the loft beat")
	elif not String(node.rain_label.text).to_lower().contains("loft"):
		_fail(errors, "loft countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.LOFT_TICK):
		_fail(errors, "loft countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.LOFT_TICK])
	elif not String(node.season_label.text).to_lower().contains("loft"):
		_fail(errors, "loft note does not mention the loft: %s" % node.season_label.text)
	var spun_gate := 0
	while int(node.sim.get_beat()) != Sim.GATING and not node.sim.is_over() and spun_gate < int(Sim.LOFT_TICK) + 2:
		node.sim.tick()
		spun_gate += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.GATING or node.sim.is_over():
		_fail(errors, "the scene did not open the gate beat")
	elif not String(node.rain_label.text).to_lower().contains("gate"):
		_fail(errors, "gate countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.GATE_TICK):
		_fail(errors, "gate countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.GATE_TICK])
	elif not String(node.season_label.text).to_lower().contains("gate"):
		_fail(errors, "gate note does not mention the gate: %s" % node.season_label.text)
	var spun_wage := 0
	while int(node.sim.get_beat()) != Sim.WAGING and not node.sim.is_over() and spun_wage < int(Sim.GATE_TICK) + 2:
		node.sim.tick()
		spun_wage += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.WAGING or node.sim.is_over():
		_fail(errors, "the scene did not open the wage beat")
	elif not String(node.rain_label.text).to_lower().contains("wage"):
		_fail(errors, "wage countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.WAGE_TICK):
		_fail(errors, "wage countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.WAGE_TICK])
	elif not String(node.season_label.text).to_lower().contains("wage"):
		_fail(errors, "wage note does not mention the wage: %s" % node.season_label.text)
	var spun_relief := 0
	while int(node.sim.get_beat()) != Sim.RELIEVING and not node.sim.is_over() and spun_relief < int(Sim.WAGE_TICK) + 2:
		node.sim.tick()
		spun_relief += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.RELIEVING or node.sim.is_over():
		_fail(errors, "the scene did not open the relief beat")
	elif not String(node.rain_label.text).to_lower().contains("relief"):
		_fail(errors, "relief countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.RELIEF_TICK):
		_fail(errors, "relief countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.RELIEF_TICK])
	elif not String(node.season_label.text).to_lower().contains("relief"):
		_fail(errors, "relief note does not mention the relief: %s" % node.season_label.text)
	var spun_watch := 0
	while int(node.sim.get_beat()) != Sim.WATCHING and not node.sim.is_over() and spun_watch < int(Sim.RELIEF_TICK) + 2:
		node.sim.tick()
		spun_watch += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.WATCHING or node.sim.is_over():
		_fail(errors, "the scene did not open the watch beat")
	elif not String(node.rain_label.text).to_lower().contains("watch"):
		_fail(errors, "watch countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.WATCH_TICK):
		_fail(errors, "watch countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.WATCH_TICK])
	elif not String(node.season_label.text).to_lower().contains("watch"):
		_fail(errors, "watch note does not mention the watch: %s" % node.season_label.text)
	var spun_lamp := 0
	while int(node.sim.get_beat()) != Sim.LAMPING and not node.sim.is_over() and spun_lamp < int(Sim.WATCH_TICK) + 2:
		node.sim.tick()
		spun_lamp += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.LAMPING or node.sim.is_over():
		_fail(errors, "the scene did not open the lamp beat")
	elif not String(node.rain_label.text).to_lower().contains("lamp"):
		_fail(errors, "lamp countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.LAMP_TICK):
		_fail(errors, "lamp countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.LAMP_TICK])
	elif not String(node.season_label.text).to_lower().contains("lamp"):
		_fail(errors, "lamp note does not mention the lamp: %s" % node.season_label.text)
	var spun_bell := 0
	while int(node.sim.get_beat()) != Sim.BELLING and not node.sim.is_over() and spun_bell < int(Sim.LAMP_TICK) + 2:
		node.sim.tick()
		spun_bell += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.BELLING or node.sim.is_over():
		_fail(errors, "the scene did not open the bell beat")
	elif not String(node.rain_label.text).to_lower().contains("bell"):
		_fail(errors, "bell countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.BELL_TICK):
		_fail(errors, "bell countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.BELL_TICK])
	elif not String(node.season_label.text).to_lower().contains("bell"):
		_fail(errors, "bell note does not mention the bell: %s" % node.season_label.text)
	node._on_key(KEY_R)
	if int(node.sim.get_paint(9, 5)) != Sim.EMPTY or int(node.sim.get_paint(8, 5)) != Sim.EMPTY or int(node.sim.get_paint(8, 6)) != Sim.EMPTY or int(node.sim.get_paint(7, 6)) != Sim.EMPTY or int(node.sim.get_paint(7, 5)) != Sim.EMPTY or int(node.sim.get_paint(7, 4)) != Sim.EMPTY or int(node.sim.get_paint(7, 3)) != Sim.EMPTY or int(node.sim.get_paint(7, 2)) != Sim.EMPTY or int(node.sim.get_paint(7, 1)) != Sim.EMPTY or int(node.sim.get_paint(7, 0)) != Sim.EMPTY or int(node.sim.get_paint(7, -1)) != Sim.EMPTY or int(node.sim.get_paint(7, -2)) != Sim.EMPTY or int(node.sim.get_paint(7, -3)) != Sim.EMPTY or int(node.sim.get_paint(7, -4)) != Sim.EMPTY:
		_fail(errors, "restart scenario did not clear the marks")
	if int(node.sim.get_season()) != Sim.WET or int(node.sim.get_wet_haul()) != 0 or int(node.sim.get_beat()) != Sim.WET or int(node.sim.get_carted()) != 0 or int(node.sim.get_shipped()) != 0 or int(node.sim.get_coins()) != 0 or int(node.sim.get_banked()) != 0 or int(node.sim.get_hired()) != 0 or int(node.sim.get_lofted()) != 0 or int(node.sim.get_gated()) != 0 or int(node.sim.get_paid()) != 0 or int(node.sim.get_posted()) != 0 or int(node.sim.get_stood()) != 0 or int(node.sim.get_lit()) != 0 or int(node.sim.get_rung()) != 0:
		_fail(errors, "restart scenario did not return to the wet season")
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


func _test_dry_season(errors: Array) -> void:
	if int(Sim.DRY_TICK) >= int(Sim.RAIN_TICK) or int(Sim.DRY_TICK) < 50:
		_fail(errors, "dry season length %s is not a short continuation after the wet season" % Sim.DRY_TICK)
	var fresh = Sim.new()
	if int(fresh.get_season()) != Sim.WET or int(fresh.get_wet_haul()) != 0:
		_fail(errors, "a new scenario did not start in the wet season")
	if not fresh.paint_cell(4, 5, Sim.PAN) or int(fresh.get_paint(4, 5)) != Sim.PAN:
		_fail(errors, "a flat rejected the pan mark")
	if fresh.paint_cell(Sim.COAST_X, 5, Sim.PAN):
		_fail(errors, "the brine accepted a pan")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	# dry_pans has no rakes. It meets the quota only because pans crystallize
	# in the dry season, and its wet haul stays 0 only because pans do nothing
	# while the brine is still in. Drop either half of the rule and this fails.
	var dry = _run_plan(plans, "dry_pans", errors)
	if dry == null:
		return
	var dry_stored := int(dry.get_stored_salt())
	var dry_wet := int(dry.get_wet_haul())
	print("dry_pans wet=%d stored=%d summary=%s" % [dry_wet, dry_stored, dry.get_summary()])
	if dry_wet != 0:
		_fail(errors, "dry_pans hauled %d before the dry season; pans must stay idle while the brine is in" % dry_wet)
	if dry_stored < Sim.QUOTA:
		_fail(errors, "dry_pans stored %d, quota is %d. The dry season did not crystallize a haul." % [dry_stored, Sim.QUOTA])
	if not dry.is_over() or int(dry.get_season()) != Sim.DRY:
		_fail(errors, "dry_pans did not finish in the dry season")
	if String(dry.get_summary()).to_lower().contains("quota missed"):
		_fail(errors, "dry_pans summary says the quota was missed: %s" % dry.get_summary())
	if not String(dry.get_summary()).contains("dry season held"):
		_fail(errors, "dry_pans summary does not name the dry season: %s" % dry.get_summary())
	_assert_pop(dry, errors, "dry_pans")
	# The shore line still fills the quota. Pans beside it must add another
	# full quota after the brine pulls back, without changing the wet haul.
	var won = _run_plan(plans, "winning", errors)
	var continued = _run_plan(plans, "continued", errors)
	if won == null or continued == null:
		return
	print("continued wet=%d stored=%d winning_wet=%d" % [
		continued.get_wet_haul(), continued.get_stored_salt(), won.get_wet_haul(),
	])
	if int(continued.get_wet_haul()) != int(won.get_wet_haul()):
		_fail(errors, "continued plan changed the wet haul (%d vs %d)" % [
			continued.get_wet_haul(), won.get_wet_haul(),
		])
	var continued_dry := int(continued.get_stored_salt()) - int(continued.get_wet_haul())
	if continued_dry < Sim.QUOTA:
		_fail(errors, "continued dry season held %d, quota is %d" % [continued_dry, Sim.QUOTA])
	_assert_pop(continued, errors, "continued plan")
	# Painted after the first rain, same geometry as dry_pans, so the haul matches.
	var late = _run_plan(plans, "late_pans", errors)
	if late == null:
		return
	print("late_pans wet=%d stored=%d" % [late.get_wet_haul(), late.get_stored_salt()])
	if int(late.get_wet_haul()) != 0:
		_fail(errors, "late_pans hauled salt before any pan was painted")
	if int(late.get_stored_salt()) < Sim.QUOTA:
		_fail(errors, "late_pans stored %d after painting in the dry season" % late.get_stored_salt())
	if int(late.get_stored_salt()) != dry_stored:
		_fail(errors, "painting pans at the dry season (%d) did not match painting them early (%d)" % [
			late.get_stored_salt(), dry_stored,
		])
	_assert_pop(late, errors, "late_pans")
	# Winning shore has no pans. Salt must stay at the first-rain haul, and
	# the flats must stay empty through the dry season. Extra salt here means
	# shore rakes kept working after the brine pulled back.
	var idle = _prepare_plan(plans, "winning", errors)
	if idle == null:
		return
	var guard := 0
	while int(idle.get_season()) == Sim.WET and not idle.is_over() and guard < int(Sim.RAIN_TICK) + 2:
		idle.tick()
		guard += 1
	if int(idle.get_season()) != Sim.DRY or idle.is_over():
		_fail(errors, "the first rain did not open a dry season")
		return
	if int(idle.get_ticks_until_rain()) != int(Sim.DRY_TICK):
		_fail(errors, "dry countdown started at %d, expected %d" % [idle.get_ticks_until_rain(), Sim.DRY_TICK])
	var haul := int(idle.get_wet_haul())
	if haul < Sim.QUOTA or int(idle.get_stored_salt()) != haul:
		_fail(errors, "first rain banked %d and stored %d" % [haul, idle.get_stored_salt()])
	if int(idle.get_loose_salt()) != 0 or int(idle.get_stacked_salt()) != 0:
		_fail(errors, "first rain left loose %d stacked %d on the flats" % [
			idle.get_loose_salt(), idle.get_stacked_salt(),
		])
	for _step in 40:
		idle.tick()
	if int(idle.get_loose_salt()) != 0 or int(idle.get_stacked_salt()) != 0 or int(idle.get_stored_salt()) != haul:
		_fail(errors, "shore rakes kept working in the dry season (loose %d stacked %d stored %d haul %d)" % [
			idle.get_loose_salt(), idle.get_stacked_salt(), idle.get_stored_salt(), haul,
		])
	idle.run_until_rain()
	if int(idle.get_stored_salt()) != haul:
		_fail(errors, "winning plan stored %d after the dry season, haul was %d" % [idle.get_stored_salt(), haul])
	if int(won.get_stored_salt()) != haul:
		_fail(errors, "winning plan gained salt after the first rain")
	if idle.paint_cell(4, 5, Sim.PAN):
		_fail(errors, "the flats still accepted paint after the second rain")
	print("rakes idle after haul %d" % haul)


func _test_cart(errors: Array) -> void:
	if int(Sim.CART_TICK) <= 0 or int(Sim.CART_TICK) >= int(Sim.RAIN_TICK):
		_fail(errors, "cart beat length %s is not a short beat after the dry season" % Sim.CART_TICK)
	var fresh = Sim.new()
	if fresh.paint_cell(14, 4, Sim.CRIB) == false or int(fresh.get_paint(14, 4)) != Sim.CRIB:
		_fail(errors, "a flat rejected the crib mark")
	if fresh.paint_cell(Sim.COAST_X, 4, Sim.CRIB):
		_fail(errors, "the brine accepted a crib")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.CRIB):
		_fail(errors, "the anthill accepted a crib")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var won = _run_plan(plans, "winning", errors)
	var dry = _run_plan(plans, "dry_pans", errors)
	var ignored = _run_plan(plans, "no_crib", errors)
	var moved = _run_plan(plans, "carted", errors)
	var late = _run_plan(plans, "late_crib", errors)
	var dry_moved = _run_plan(plans, "dry_crib", errors)
	if won == null or dry == null or ignored == null or moved == null or late == null or dry_moved == null:
		return
	# The shore and the dry pans still finish on the numbers they had before
	# the cart beat. Neither plan paints a crib, so the bank does not move.
	if int(won.get_stored_salt()) != 2997 or int(won.get_wet_haul()) != 2997 or int(won.get_carted()) != 0:
		_fail(errors, "winning shore changed (stored %d wet %d carted %d)" % [
			won.get_stored_salt(), won.get_wet_haul(), won.get_carted(),
		])
	if String(won.get_summary()) != "The rains passed. Covered salt held: 2997 (quota 12). First rain hauled 2997; dry season held 0.":
		_fail(errors, "winning summary changed: %s" % won.get_summary())
	if int(dry.get_stored_salt()) != 1032 or int(dry.get_wet_haul()) != 0 or int(dry.get_carted()) != 0:
		_fail(errors, "dry_pans changed (stored %d wet %d carted %d)" % [
			dry.get_stored_salt(), dry.get_wet_haul(), dry.get_carted(),
		])
	if String(dry.get_summary()) != "The rains passed. Covered salt held: 1032 (quota 12). First rain hauled 0; dry season held 1032.":
		_fail(errors, "dry_pans summary changed: %s" % dry.get_summary())
	if int(dry.get_season()) != Sim.DRY or int(won.get_season()) != Sim.DRY:
		_fail(errors, "a plan with no crib finished outside the dry season")
	if int(ignored.get_stored_salt()) != int(won.get_stored_salt()) or int(ignored.get_wet_haul()) != int(won.get_wet_haul()):
		_fail(errors, "no_crib changed the shore haul")
	if String(ignored.get_summary()) != String(won.get_summary()) or int(ignored.get_carted()) != 0:
		_fail(errors, "no_crib changed the shore result (carted %d)" % ignored.get_carted())
	# This plan ignores the crib. The cart check must fail, or the beat is
	# moving salt that was never given a crib.
	var ignored_check: Array = []
	_expect_cart(ignored, ignored_check)
	if ignored_check.is_empty():
		_fail(errors, "no_crib ignored the cart beat and should have failed the cart check")
	else:
		print("no_crib failed the cart check: %s" % ignored_check[0])
	var moved_check: Array = []
	_expect_cart(moved, moved_check)
	for message in moved_check:
		_fail(errors, "carted plan: %s" % message)
	if int(moved.get_wet_haul()) != int(won.get_wet_haul()) or int(moved.get_stored_salt()) != int(won.get_stored_salt()):
		_fail(errors, "crib changed the shore haul (wet %d stored %d, winning %d/%d)" % [
			moved.get_wet_haul(), moved.get_stored_salt(), won.get_wet_haul(), won.get_stored_salt(),
		])
	if int(moved.get_carted()) != int(won.get_stored_salt()):
		_fail(errors, "carted %d of the bank %d" % [moved.get_carted(), won.get_stored_salt()])
	var crib_salt: Dictionary = moved.get_cell_salt(14, 4)
	if int(crib_salt.get("crib", 0)) != int(moved.get_carted()):
		_fail(errors, "crib cell holds %s, carted %d" % [crib_salt.get("crib", 0), moved.get_carted()])
	var moved_summary := String(moved.get_summary())
	if not moved_summary.to_lower().contains("crib"):
		_fail(errors, "cart summary does not name the crib: %s" % moved_summary)
	if moved_summary.to_lower().contains("quota missed"):
		_fail(errors, "carted plan missed the quota: %s" % moved_summary)
	if int(late.get_carted()) != int(moved.get_carted()) or int(late.get_wet_haul()) != int(moved.get_wet_haul()) or int(late.get_stored_salt()) != int(moved.get_stored_salt()):
		_fail(errors, "painting the crib at the cart beat (carted %d wet %d) did not match painting it early (carted %d wet %d)" % [
			late.get_carted(), late.get_wet_haul(), moved.get_carted(), moved.get_wet_haul(),
		])
	if int(dry_moved.get_wet_haul()) != 0 or int(dry_moved.get_stored_salt()) != int(dry.get_stored_salt()):
		_fail(errors, "dry crib changed the dry haul (wet %d stored %d, dry_pans stored %d)" % [
			dry_moved.get_wet_haul(), dry_moved.get_stored_salt(), dry.get_stored_salt(),
		])
	if int(dry_moved.get_carted()) != int(dry.get_stored_salt()) or int(dry_moved.get_bank_left()) != 0:
		_fail(errors, "dry crib carted %d of %d, bank left %d" % [
			dry_moved.get_carted(), dry.get_stored_salt(), dry_moved.get_bank_left(),
		])
	var cover_left := 0
	for pair in plans["dry_crib"]["cover"]:
		var salt: Dictionary = dry_moved.get_cell_salt(int(pair[0]), int(pair[1]))
		cover_left += int(salt.get("covered", 0)) + int(salt.get("stacked", 0))
	if cover_left != 0:
		_fail(errors, "dry crib left %d salt on the covers" % cover_left)
	if not String(dry_moved.get_summary()).to_lower().contains("crib"):
		_fail(errors, "dry crib summary does not name the crib: %s" % dry_moved.get_summary())
	_assert_pop(moved, errors, "carted plan")
	_assert_pop(dry_moved, errors, "dry_crib")
	_assert_pop(ignored, errors, "no_crib")
	# The beat opens after the dry season, with the bank still unmoved, and
	# a shore with no crib gains nothing during it.
	var opening = _prepare_plan(plans, "winning", errors)
	if opening == null:
		return
	var guard := 0
	var limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + 2
	while int(opening.get_beat()) != Sim.CART and not opening.is_over() and guard < limit:
		opening.tick()
		guard += 1
	if int(opening.get_beat()) != Sim.CART or opening.is_over() or int(opening.get_season()) != Sim.DRY:
		_fail(errors, "the second rain did not open a cart beat in the dry season")
		return
	if int(opening.get_ticks_until_rain()) != int(Sim.CART_TICK):
		_fail(errors, "cart countdown started at %d, expected %d" % [opening.get_ticks_until_rain(), Sim.CART_TICK])
	var bank := int(opening.get_stored_salt())
	if int(opening.get_carted()) != 0 or int(opening.get_bank_left()) != bank:
		_fail(errors, "cart opened with carted %d and bank %d, stored %d" % [
			opening.get_carted(), opening.get_bank_left(), bank,
		])
	for _step in int(Sim.CART_TICK):
		opening.tick()
	if int(opening.get_carted()) != 0 or int(opening.get_stored_salt()) != bank or int(opening.get_loose_salt()) != 0:
		_fail(errors, "shore with no crib moved salt during the cart (carted %d stored %d loose %d)" % [
			opening.get_carted(), opening.get_stored_salt(), opening.get_loose_salt(),
		])
	print("cart moved %d; no crib left the bank" % moved.get_carted())


func _test_ship(errors: Array) -> void:
	if int(Sim.SHIP_TICK) <= 0 or int(Sim.SHIP_TICK) >= int(Sim.RAIN_TICK):
		_fail(errors, "ship beat length %s is not a short beat after the cart" % Sim.SHIP_TICK)
	var fresh = Sim.new()
	if fresh.paint_cell(14, 3, Sim.SHIP) == false or int(fresh.get_paint(14, 3)) != Sim.SHIP:
		_fail(errors, "a flat rejected the ship mark")
	if fresh.paint_cell(Sim.COAST_X, 3, Sim.SHIP):
		_fail(errors, "the brine accepted a ship")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.SHIP):
		_fail(errors, "the anthill accepted a ship")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var won = _run_plan(plans, "winning", errors)
	var dry = _run_plan(plans, "dry_pans", errors)
	var parked = _run_plan(plans, "carted", errors)
	var ignored = _run_plan(plans, "no_ship", errors)
	var loaded = _run_plan(plans, "shipped", errors)
	var late = _run_plan(plans, "late_ship", errors)
	var dry_loaded = _run_plan(plans, "dry_ship", errors)
	if won == null or dry == null or parked == null or ignored == null or loaded == null or late == null or dry_loaded == null:
		return
	# Winning shore, dry pans, and the cart still report the same numbers.
	if int(won.get_wet_haul()) != 2997 or int(won.get_stored_salt()) != 2997 or int(won.get_carted()) != 0 or int(won.get_shipped()) != 0:
		_fail(errors, "winning shore changed (wet %d stored %d carted %d shipped %d)" % [
			won.get_wet_haul(), won.get_stored_salt(), won.get_carted(), won.get_shipped(),
		])
	if int(won.get_stored_salt()) - int(won.get_wet_haul()) != 0:
		_fail(errors, "winning dry haul changed")
	if int(dry.get_wet_haul()) != 0 or int(dry.get_stored_salt()) != 1032 or int(dry.get_carted()) != 0 or int(dry.get_shipped()) != 0:
		_fail(errors, "dry_pans changed (wet %d stored %d carted %d shipped %d)" % [
			dry.get_wet_haul(), dry.get_stored_salt(), dry.get_carted(), dry.get_shipped(),
		])
	if int(dry.get_stored_salt()) - int(dry.get_wet_haul()) != 1032:
		_fail(errors, "dry_pans dry haul changed")
	if int(parked.get_wet_haul()) != 2997 or int(parked.get_stored_salt()) != 2997 or int(parked.get_carted()) != 2997 or int(parked.get_shipped()) != 0:
		_fail(errors, "carted plan changed (wet %d stored %d carted %d shipped %d)" % [
			parked.get_wet_haul(), parked.get_stored_salt(), parked.get_carted(), parked.get_shipped(),
		])
	if int(parked.get_stored_salt()) - int(parked.get_wet_haul()) != 0:
		_fail(errors, "carted plan dry haul changed")
	var parked_crib: Dictionary = parked.get_cell_salt(14, 4)
	if int(parked_crib.get("crib", 0)) != 2997:
		_fail(errors, "carted crib holds %s" % parked_crib.get("crib", 0))
	if int(ignored.get_wet_haul()) != int(parked.get_wet_haul()) or int(ignored.get_stored_salt()) != int(parked.get_stored_salt()) or int(ignored.get_carted()) != int(parked.get_carted()) or int(ignored.get_shipped()) != 0:
		_fail(errors, "no_ship changed the cart result (wet %d stored %d carted %d shipped %d)" % [
			ignored.get_wet_haul(), ignored.get_stored_salt(), ignored.get_carted(), ignored.get_shipped(),
		])
	if String(ignored.get_summary()) != String(parked.get_summary()):
		_fail(errors, "no_ship summary changed: %s" % ignored.get_summary())
	if String(ignored.get_summary()).to_lower().contains("ship"):
		_fail(errors, "no_ship summary names a ship: %s" % ignored.get_summary())
	# This plan filled the crib and painted no ship. The ship check must fail.
	var ignored_check: Array = []
	_expect_ship(ignored, ignored_check)
	if ignored_check.is_empty():
		_fail(errors, "no_ship filled the crib and ignored the ship beat, so the ship check should have failed")
	else:
		print("no_ship failed the ship check: %s" % ignored_check[0])
	var ship_cell = plans["shipped"]["ship"][0]
	var crib_cell = plans["shipped"]["crib"][0]
	if int(ship_cell[0]) != int(crib_cell[0]) or int(ship_cell[1]) != int(crib_cell[1]) - 1:
		_fail(errors, "shipped plan's ship is not one cell north of the crib")
	var loaded_check: Array = []
	_expect_ship(loaded, loaded_check)
	for message in loaded_check:
		_fail(errors, "shipped plan: %s" % message)
	if int(loaded.get_wet_haul()) != 2997 or int(loaded.get_stored_salt()) != 2997 or int(loaded.get_carted()) != 2997:
		_fail(errors, "ship changed the carted shore (wet %d stored %d carted %d)" % [
			loaded.get_wet_haul(), loaded.get_stored_salt(), loaded.get_carted(),
		])
	if int(loaded.get_stored_salt()) - int(loaded.get_wet_haul()) != 0:
		_fail(errors, "shipped plan dry haul changed")
	if int(loaded.get_shipped()) != 2997 or int(loaded.get_crib_salt()) != 0:
		_fail(errors, "shipped %d with %d left in the crib" % [loaded.get_shipped(), loaded.get_crib_salt()])
	var ship_salt: Dictionary = loaded.get_cell_salt(int(ship_cell[0]), int(ship_cell[1]))
	if int(ship_salt.get("ship", 0)) != int(loaded.get_shipped()):
		_fail(errors, "ship cell holds %s, shipped %d" % [ship_salt.get("ship", 0), loaded.get_shipped()])
	var loaded_crib: Dictionary = loaded.get_cell_salt(int(crib_cell[0]), int(crib_cell[1]))
	if int(loaded_crib.get("crib", 0)) != 0:
		_fail(errors, "ship left %s in the crib" % loaded_crib.get("crib", 0))
	var loaded_summary := String(loaded.get_summary())
	if not loaded_summary.to_lower().contains("ship"):
		_fail(errors, "ship summary does not name the ship: %s" % loaded_summary)
	if loaded_summary.to_lower().contains("quota missed"):
		_fail(errors, "shipped plan missed the quota: %s" % loaded_summary)
	if int(late.get_shipped()) != int(loaded.get_shipped()) or int(late.get_wet_haul()) != int(loaded.get_wet_haul()) or int(late.get_carted()) != int(loaded.get_carted()) or int(late.get_stored_salt()) != int(loaded.get_stored_salt()):
		_fail(errors, "painting the ship at the ship beat (shipped %d wet %d carted %d) did not match painting it early (shipped %d wet %d carted %d)" % [
			late.get_shipped(), late.get_wet_haul(), late.get_carted(), loaded.get_shipped(), loaded.get_wet_haul(), loaded.get_carted(),
		])
	if int(dry_loaded.get_wet_haul()) != 0 or int(dry_loaded.get_stored_salt()) != 1032 or int(dry_loaded.get_carted()) != 1032:
		_fail(errors, "dry ship changed the dry cart (wet %d stored %d carted %d)" % [
			dry_loaded.get_wet_haul(), dry_loaded.get_stored_salt(), dry_loaded.get_carted(),
		])
	if int(dry_loaded.get_shipped()) != 1032 or int(dry_loaded.get_crib_salt()) != 0:
		_fail(errors, "dry ship shipped %d, crib left %d" % [dry_loaded.get_shipped(), dry_loaded.get_crib_salt()])
	var dry_cover_left := 0
	for pair in plans["dry_ship"]["cover"]:
		var salt: Dictionary = dry_loaded.get_cell_salt(int(pair[0]), int(pair[1]))
		dry_cover_left += int(salt.get("covered", 0)) + int(salt.get("stacked", 0))
	if dry_cover_left != 0:
		_fail(errors, "dry ship left %d salt on the covers" % dry_cover_left)
	if not String(dry_loaded.get_summary()).to_lower().contains("ship"):
		_fail(errors, "dry ship summary does not name the ship: %s" % dry_loaded.get_summary())
	_assert_pop(loaded, errors, "shipped plan")
	_assert_pop(late, errors, "late_ship")
	_assert_pop(dry_loaded, errors, "dry_ship")
	_assert_pop(ignored, errors, "no_ship")
	# The beat opens after the cart with the crib still full. No ship, no movement.
	var opening = _prepare_plan(plans, "no_ship", errors)
	if opening == null:
		return
	var guard := 0
	var limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + 2
	while int(opening.get_beat()) != Sim.SHIPPING and not opening.is_over() and guard < limit:
		opening.tick()
		guard += 1
	if int(opening.get_beat()) != Sim.SHIPPING or opening.is_over() or int(opening.get_season()) != Sim.DRY:
		_fail(errors, "the cart beat did not open a ship beat in the dry season")
		return
	if int(opening.get_ticks_until_rain()) != int(Sim.SHIP_TICK):
		_fail(errors, "ship countdown started at %d, expected %d" % [opening.get_ticks_until_rain(), Sim.SHIP_TICK])
	var crib_held := int(opening.get_crib_salt())
	if int(opening.get_shipped()) != 0 or crib_held != int(opening.get_carted()) or crib_held != 2997:
		_fail(errors, "ship opened with shipped %d crib %d carted %d" % [
			opening.get_shipped(), crib_held, opening.get_carted(),
		])
	for _step in int(Sim.SHIP_TICK):
		opening.tick()
	if int(opening.get_shipped()) != 0 or int(opening.get_crib_salt()) != crib_held or int(opening.get_carted()) != crib_held or int(opening.get_stored_salt()) != 2997:
		_fail(errors, "crib with no ship moved salt during the ship beat (shipped %d crib %d carted %d stored %d)" % [
			opening.get_shipped(), opening.get_crib_salt(), opening.get_carted(), opening.get_stored_salt(),
		])
	if int(opening.get_beat()) != Sim.MARKET or opening.is_over():
		_fail(errors, "the ship beat did not open a market beat")
	elif int(opening.get_ticks_until_rain()) != int(Sim.MARKET_TICK):
		_fail(errors, "market countdown started at %d after the ship, expected %d" % [opening.get_ticks_until_rain(), Sim.MARKET_TICK])
	print("ship loaded %d; winning wet %d carted %d; dry stored %d; carted %d" % [
		loaded.get_shipped(), won.get_wet_haul(), parked.get_carted(), dry.get_stored_salt(), parked.get_carted(),
	])


func _test_market(errors: Array) -> void:
	if int(Sim.MARKET_TICK) != 100 or int(Sim.MARKET_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "market beat length %s is not 100 ticks (10 seconds)" % Sim.MARKET_TICK)
	var fresh = Sim.new()
	if fresh.paint_cell(14, 2, Sim.STALL) == false or int(fresh.get_paint(14, 2)) != Sim.STALL:
		_fail(errors, "a flat rejected the stall mark")
	if fresh.paint_cell(Sim.COAST_X, 2, Sim.STALL):
		_fail(errors, "the brine accepted a stall")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.STALL):
		_fail(errors, "the anthill accepted a stall")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var won = _run_plan(plans, "winning", errors)
	var dry = _run_plan(plans, "dry_pans", errors)
	var parked = _run_plan(plans, "carted", errors)
	var loaded = _run_plan(plans, "shipped", errors)
	var ignored = _run_plan(plans, "no_stall", errors)
	var sold = _run_plan(plans, "sold", errors)
	var late = _run_plan(plans, "late_sold", errors)
	var dry_sold = _run_plan(plans, "dry_sold", errors)
	if won == null or dry == null or parked == null or loaded == null or ignored == null or sold == null or late == null or dry_sold == null:
		return
	# The shore, the dry pans, the cart, and the ship still report the same numbers.
	if int(won.get_wet_haul()) != 2997 or int(won.get_stored_salt()) != 2997 or int(won.get_carted()) != 0 or int(won.get_shipped()) != 0 or int(won.get_coins()) != 0:
		_fail(errors, "winning shore changed (wet %d stored %d carted %d shipped %d coins %d)" % [
			won.get_wet_haul(), won.get_stored_salt(), won.get_carted(), won.get_shipped(), won.get_coins(),
		])
	if int(won.get_stored_salt()) - int(won.get_wet_haul()) != 0:
		_fail(errors, "winning dry haul changed")
	if int(dry.get_wet_haul()) != 0 or int(dry.get_stored_salt()) != 1032 or int(dry.get_carted()) != 0 or int(dry.get_shipped()) != 0 or int(dry.get_coins()) != 0:
		_fail(errors, "dry_pans changed (wet %d stored %d carted %d shipped %d coins %d)" % [
			dry.get_wet_haul(), dry.get_stored_salt(), dry.get_carted(), dry.get_shipped(), dry.get_coins(),
		])
	if int(dry.get_stored_salt()) - int(dry.get_wet_haul()) != 1032:
		_fail(errors, "dry_pans dry haul changed")
	if int(parked.get_wet_haul()) != 2997 or int(parked.get_stored_salt()) != 2997 or int(parked.get_carted()) != 2997 or int(parked.get_shipped()) != 0 or int(parked.get_coins()) != 0:
		_fail(errors, "carted plan changed (wet %d stored %d carted %d shipped %d coins %d)" % [
			parked.get_wet_haul(), parked.get_stored_salt(), parked.get_carted(), parked.get_shipped(), parked.get_coins(),
		])
	if int(parked.get_stored_salt()) - int(parked.get_wet_haul()) != 0:
		_fail(errors, "carted plan dry haul changed")
	if int(loaded.get_wet_haul()) != 2997 or int(loaded.get_stored_salt()) != 2997 or int(loaded.get_carted()) != 2997 or int(loaded.get_shipped()) != 2997 or int(loaded.get_coins()) != 0 or int(loaded.get_ship_salt()) != 2997:
		_fail(errors, "shipped plan changed (wet %d stored %d carted %d shipped %d ship %d coins %d)" % [
			loaded.get_wet_haul(), loaded.get_stored_salt(), loaded.get_carted(), loaded.get_shipped(), loaded.get_ship_salt(), loaded.get_coins(),
		])
	if int(loaded.get_stored_salt()) - int(loaded.get_wet_haul()) != 0:
		_fail(errors, "shipped plan dry haul changed")
	if int(ignored.get_wet_haul()) != 2997 or int(ignored.get_stored_salt()) != 2997 or int(ignored.get_carted()) != 2997 or int(ignored.get_shipped()) != 2997 or int(ignored.get_coins()) != 0 or int(ignored.get_ship_salt()) != 2997:
		_fail(errors, "no_stall changed the shipment (wet %d stored %d carted %d shipped %d ship %d coins %d)" % [
			ignored.get_wet_haul(), ignored.get_stored_salt(), ignored.get_carted(), ignored.get_shipped(), ignored.get_ship_salt(), ignored.get_coins(),
		])
	if String(ignored.get_summary()) != String(loaded.get_summary()):
		_fail(errors, "no_stall summary changed: %s" % ignored.get_summary())
	if String(ignored.get_summary()).to_lower().contains("coin") or String(ignored.get_summary()).to_lower().contains("stall"):
		_fail(errors, "no_stall summary names a sale: %s" % ignored.get_summary())
	var ignored_ship: Dictionary = ignored.get_cell_salt(14, 3)
	if int(ignored_ship.get("ship", 0)) != 2997:
		_fail(errors, "no_stall left %s on the ship" % ignored_ship.get("ship", 0))
	# This plan shipped the salt and painted no stall. The market check must fail.
	var ignored_check: Array = []
	_expect_market(ignored, ignored_check)
	if ignored_check.is_empty():
		_fail(errors, "no_stall shipped the salt and ignored the market, so the market check should have failed")
	else:
		print("no_stall failed the market check: %s" % ignored_check[0])
	var stall_cell = plans["sold"]["stall"][0]
	var ship_cell = plans["sold"]["ship"][0]
	if int(stall_cell[0]) != int(ship_cell[0]) or int(stall_cell[1]) != int(ship_cell[1]) - 1:
		_fail(errors, "sold plan's stall is not one cell north of the ship")
	var sold_check: Array = []
	_expect_market(sold, sold_check)
	for message in sold_check:
		_fail(errors, "sold plan: %s" % message)
	if int(sold.get_wet_haul()) != 2997 or int(sold.get_stored_salt()) != 2997 or int(sold.get_carted()) != 2997 or int(sold.get_shipped()) != 2997:
		_fail(errors, "stall changed the shipped shore (wet %d stored %d carted %d shipped %d)" % [
			sold.get_wet_haul(), sold.get_stored_salt(), sold.get_carted(), sold.get_shipped(),
		])
	if int(sold.get_stored_salt()) - int(sold.get_wet_haul()) != 0:
		_fail(errors, "sold plan dry haul changed")
	if int(sold.get_coins()) != 2997 or int(sold.get_ship_salt()) != 0:
		_fail(errors, "sold %d coin with %d left on the ship" % [sold.get_coins(), sold.get_ship_salt()])
	var stall_salt: Dictionary = sold.get_cell_salt(int(stall_cell[0]), int(stall_cell[1]))
	if int(stall_salt.get("stall", 0)) != 2997 or int(stall_salt.get("stall", 0)) != int(sold.get_coins()):
		_fail(errors, "stall cell holds %s, coins %d" % [stall_salt.get("stall", 0), sold.get_coins()])
	var sold_ship: Dictionary = sold.get_cell_salt(int(ship_cell[0]), int(ship_cell[1]))
	if int(sold_ship.get("ship", 0)) != 0:
		_fail(errors, "stall left %s on the ship" % sold_ship.get("ship", 0))
	var sold_summary := String(sold.get_summary())
	if not sold_summary.to_lower().contains("coin"):
		_fail(errors, "sold summary does not name the coins: %s" % sold_summary)
	if sold_summary.to_lower().contains("quota missed"):
		_fail(errors, "sold plan missed the quota: %s" % sold_summary)
	if int(late.get_coins()) != 2997 or int(late.get_shipped()) != int(sold.get_shipped()) or int(late.get_wet_haul()) != int(sold.get_wet_haul()) or int(late.get_carted()) != int(sold.get_carted()) or int(late.get_ship_salt()) != 0:
		_fail(errors, "painting the stall at the market beat (coins %d shipped %d wet %d) did not match painting it early (coins %d shipped %d wet %d)" % [
			late.get_coins(), late.get_shipped(), late.get_wet_haul(), sold.get_coins(), sold.get_shipped(), sold.get_wet_haul(),
		])
	if int(dry_sold.get_wet_haul()) != 0 or int(dry_sold.get_stored_salt()) != 1032 or int(dry_sold.get_carted()) != 1032 or int(dry_sold.get_shipped()) != 1032:
		_fail(errors, "dry stall changed the dry ship (wet %d stored %d carted %d shipped %d)" % [
			dry_sold.get_wet_haul(), dry_sold.get_stored_salt(), dry_sold.get_carted(), dry_sold.get_shipped(),
		])
	if int(dry_sold.get_stored_salt()) - int(dry_sold.get_wet_haul()) != 1032:
		_fail(errors, "dry stall dry haul changed")
	if int(dry_sold.get_coins()) != 1032 or int(dry_sold.get_ship_salt()) != 0:
		_fail(errors, "dry stall coined %d, ship left %d" % [dry_sold.get_coins(), dry_sold.get_ship_salt()])
	var dry_stall_cell = plans["dry_sold"]["stall"][0]
	var dry_stall_salt: Dictionary = dry_sold.get_cell_salt(int(dry_stall_cell[0]), int(dry_stall_cell[1]))
	if int(dry_stall_salt.get("stall", 0)) != 1032:
		_fail(errors, "dry stall cell holds %s" % dry_stall_salt.get("stall", 0))
	if not String(dry_sold.get_summary()).to_lower().contains("coin"):
		_fail(errors, "dry stall summary does not name the coins: %s" % dry_sold.get_summary())
	_assert_pop(sold, errors, "sold plan")
	_assert_pop(late, errors, "late_sold")
	_assert_pop(dry_sold, errors, "dry_sold")
	_assert_pop(ignored, errors, "no_stall")
	# The beat opens after the ship with the cargo still aboard. No stall, no sale.
	var opening = _prepare_plan(plans, "no_stall", errors)
	if opening == null:
		return
	var guard := 0
	var limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + 2
	while int(opening.get_beat()) != Sim.MARKET and not opening.is_over() and guard < limit:
		opening.tick()
		guard += 1
	if int(opening.get_beat()) != Sim.MARKET or opening.is_over() or int(opening.get_season()) != Sim.DRY:
		_fail(errors, "the ship beat did not open a market beat in the dry season")
		return
	if int(opening.get_ticks_until_rain()) != int(Sim.MARKET_TICK):
		_fail(errors, "market countdown started at %d, expected %d" % [opening.get_ticks_until_rain(), Sim.MARKET_TICK])
	var aboard := int(opening.get_ship_salt())
	if int(opening.get_coins()) != 0 or aboard != 2997 or int(opening.get_shipped()) != aboard:
		_fail(errors, "market opened with coins %d ship %d shipped %d" % [
			opening.get_coins(), aboard, opening.get_shipped(),
		])
	for _step in int(Sim.MARKET_TICK):
		opening.tick()
	if int(opening.get_coins()) != 0 or int(opening.get_ship_salt()) != aboard or int(opening.get_shipped()) != aboard or int(opening.get_stored_salt()) != 2997:
		_fail(errors, "ship with no stall sold salt during the market (coins %d ship %d shipped %d stored %d)" % [
			opening.get_coins(), opening.get_ship_salt(), opening.get_shipped(), opening.get_stored_salt(),
		])
	if int(opening.get_beat()) != Sim.YARDING or opening.is_over():
		_fail(errors, "the market beat did not open a yard beat")
	elif int(opening.get_ticks_until_rain()) != int(Sim.YARD_TICK):
		_fail(errors, "yard countdown started at %d after the market, expected %d" % [opening.get_ticks_until_rain(), Sim.YARD_TICK])
	print("sold %d coin; dry sold %d coin; no stall left %d on the ship" % [
		sold.get_coins(), dry_sold.get_coins(), ignored.get_ship_salt(),
	])
func _test_yard(errors: Array) -> void:
	if int(Sim.YARD_TICK) != 100 or int(Sim.YARD_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "yard beat length %s is not 100 ticks (10 seconds)" % Sim.YARD_TICK)
	var fresh = Sim.new()
	if fresh.paint_cell(14, 1, Sim.YARD) == false or int(fresh.get_paint(14, 1)) != Sim.YARD:
		_fail(errors, "a flat rejected the yard mark")
	if fresh.paint_cell(Sim.COAST_X, 1, Sim.YARD):
		_fail(errors, "the brine accepted a yard")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.YARD):
		_fail(errors, "the anthill accepted a yard")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var won = _run_plan(plans, "winning", errors)
	var dry = _run_plan(plans, "dry_pans", errors)
	var parked = _run_plan(plans, "carted", errors)
	var loaded = _run_plan(plans, "shipped", errors)
	var sold = _run_plan(plans, "sold", errors)
	var ignored = _run_plan(plans, "no_yard", errors)
	var banked = _run_plan(plans, "banked", errors)
	var late = _run_plan(plans, "late_banked", errors)
	var dry_banked = _run_plan(plans, "dry_banked", errors)
	if won == null or dry == null or parked == null or loaded == null or sold == null or ignored == null or banked == null or late == null or dry_banked == null:
		return
	# Earlier beats still report the same wet, dry, cart, ship, and earned-coin numbers.
	if int(won.get_wet_haul()) != 2997 or int(won.get_stored_salt()) != 2997 or int(won.get_carted()) != 0 or int(won.get_shipped()) != 0 or int(won.get_coins()) != 0 or int(won.get_banked()) != 0:
		_fail(errors, "winning shore changed (wet %d stored %d carted %d shipped %d coins %d banked %d)" % [
			won.get_wet_haul(), won.get_stored_salt(), won.get_carted(), won.get_shipped(), won.get_coins(), won.get_banked(),
		])
	if int(won.get_stored_salt()) - int(won.get_wet_haul()) != 0:
		_fail(errors, "winning dry haul changed")
	if int(dry.get_wet_haul()) != 0 or int(dry.get_stored_salt()) != 1032 or int(dry.get_carted()) != 0 or int(dry.get_shipped()) != 0 or int(dry.get_coins()) != 0 or int(dry.get_banked()) != 0:
		_fail(errors, "dry_pans changed (wet %d stored %d carted %d shipped %d coins %d banked %d)" % [
			dry.get_wet_haul(), dry.get_stored_salt(), dry.get_carted(), dry.get_shipped(), dry.get_coins(), dry.get_banked(),
		])
	if int(dry.get_stored_salt()) - int(dry.get_wet_haul()) != 1032:
		_fail(errors, "dry_pans dry haul changed")
	if int(parked.get_wet_haul()) != 2997 or int(parked.get_stored_salt()) != 2997 or int(parked.get_carted()) != 2997 or int(parked.get_shipped()) != 0 or int(parked.get_coins()) != 0 or int(parked.get_banked()) != 0:
		_fail(errors, "carted plan changed (wet %d stored %d carted %d shipped %d coins %d banked %d)" % [
			parked.get_wet_haul(), parked.get_stored_salt(), parked.get_carted(), parked.get_shipped(), parked.get_coins(), parked.get_banked(),
		])
	if int(parked.get_stored_salt()) - int(parked.get_wet_haul()) != 0:
		_fail(errors, "carted plan dry haul changed")
	if int(loaded.get_wet_haul()) != 2997 or int(loaded.get_stored_salt()) != 2997 or int(loaded.get_carted()) != 2997 or int(loaded.get_shipped()) != 2997 or int(loaded.get_coins()) != 0 or int(loaded.get_banked()) != 0:
		_fail(errors, "shipped plan changed (wet %d stored %d carted %d shipped %d coins %d banked %d)" % [
			loaded.get_wet_haul(), loaded.get_stored_salt(), loaded.get_carted(), loaded.get_shipped(), loaded.get_coins(), loaded.get_banked(),
		])
	if int(loaded.get_stored_salt()) - int(loaded.get_wet_haul()) != 0:
		_fail(errors, "shipped plan dry haul changed")
	if int(sold.get_wet_haul()) != 2997 or int(sold.get_stored_salt()) != 2997 or int(sold.get_carted()) != 2997 or int(sold.get_shipped()) != 2997 or int(sold.get_coins()) != 2997 or int(sold.get_banked()) != 0 or int(sold.get_purse()) != 2997:
		_fail(errors, "sold plan changed (wet %d stored %d carted %d shipped %d coins %d purse %d banked %d)" % [
			sold.get_wet_haul(), sold.get_stored_salt(), sold.get_carted(), sold.get_shipped(), sold.get_coins(), sold.get_purse(), sold.get_banked(),
		])
	if int(sold.get_stored_salt()) - int(sold.get_wet_haul()) != 0:
		_fail(errors, "sold plan dry haul changed")
	if int(ignored.get_wet_haul()) != 2997 or int(ignored.get_stored_salt()) != 2997 or int(ignored.get_carted()) != 2997 or int(ignored.get_shipped()) != 2997 or int(ignored.get_coins()) != 2997 or int(ignored.get_banked()) != 0 or int(ignored.get_purse()) != 2997:
		_fail(errors, "no_yard changed the purse (wet %d stored %d carted %d shipped %d coins %d purse %d banked %d)" % [
			ignored.get_wet_haul(), ignored.get_stored_salt(), ignored.get_carted(), ignored.get_shipped(), ignored.get_coins(), ignored.get_purse(), ignored.get_banked(),
		])
	if int(ignored.get_stored_salt()) - int(ignored.get_wet_haul()) != 0:
		_fail(errors, "no_yard dry haul changed")
	if String(ignored.get_summary()) != String(sold.get_summary()):
		_fail(errors, "no_yard summary changed: %s" % ignored.get_summary())
	if not String(ignored.get_summary()).contains("Coins 2997"):
		_fail(errors, "no_yard summary dropped the earned coins: %s" % ignored.get_summary())
	if String(ignored.get_summary()).to_lower().contains("yard"):
		_fail(errors, "no_yard summary names a yard: %s" % ignored.get_summary())
	var ignored_stall: Dictionary = ignored.get_cell_salt(14, 2)
	if int(ignored_stall.get("stall", 0)) != 2997:
		_fail(errors, "no_yard left %s at the stall" % ignored_stall.get("stall", 0))
	# This plan earned the coins and painted no yard. The yard check must fail.
	var ignored_check: Array = []
	_expect_yard(ignored, ignored_check)
	if ignored_check.is_empty():
		_fail(errors, "no_yard earned the coins and ignored the yard, so the yard check should have failed")
	else:
		print("no_yard failed the yard check: %s" % ignored_check[0])
	var yard_cell = plans["banked"]["yard"][0]
	var stall_cell = plans["banked"]["stall"][0]
	if int(yard_cell[0]) != int(stall_cell[0]) or int(yard_cell[1]) != int(stall_cell[1]) - 1:
		_fail(errors, "banked plan's yard is not one cell north of the stall")
	var banked_check: Array = []
	_expect_yard(banked, banked_check)
	for message in banked_check:
		_fail(errors, "banked plan: %s" % message)
	if int(banked.get_wet_haul()) != 2997 or int(banked.get_stored_salt()) != 2997 or int(banked.get_carted()) != 2997 or int(banked.get_shipped()) != 2997 or int(banked.get_coins()) != 2997:
		_fail(errors, "yard changed the sold shore (wet %d stored %d carted %d shipped %d coins %d)" % [
			banked.get_wet_haul(), banked.get_stored_salt(), banked.get_carted(), banked.get_shipped(), banked.get_coins(),
		])
	if int(banked.get_stored_salt()) - int(banked.get_wet_haul()) != 0:
		_fail(errors, "banked plan dry haul changed")
	if int(banked.get_banked()) != 2997 or int(banked.get_purse()) != 0:
		_fail(errors, "banked %d with %d left in the purse" % [banked.get_banked(), banked.get_purse()])
	var yard_salt: Dictionary = banked.get_cell_salt(int(yard_cell[0]), int(yard_cell[1]))
	if int(yard_salt.get("yard", 0)) != 2997 or int(yard_salt.get("yard", 0)) != int(banked.get_banked()):
		_fail(errors, "yard cell holds %s, banked %d" % [yard_salt.get("yard", 0), banked.get_banked()])
	var banked_stall: Dictionary = banked.get_cell_salt(int(stall_cell[0]), int(stall_cell[1]))
	if int(banked_stall.get("stall", 0)) != 0:
		_fail(errors, "yard left %s at the stall" % banked_stall.get("stall", 0))
	var banked_summary := String(banked.get_summary())
	if not banked_summary.to_lower().contains("yard") or not banked_summary.contains("Banked 2997"):
		_fail(errors, "banked summary does not name the yard: %s" % banked_summary)
	if not banked_summary.contains("Coins 2997"):
		_fail(errors, "banked summary dropped the earned coins: %s" % banked_summary)
	if banked_summary.to_lower().contains("quota missed"):
		_fail(errors, "banked plan missed the quota: %s" % banked_summary)
	if int(late.get_banked()) != 2997 or int(late.get_coins()) != int(banked.get_coins()) or int(late.get_shipped()) != int(banked.get_shipped()) or int(late.get_wet_haul()) != int(banked.get_wet_haul()) or int(late.get_purse()) != 0:
		_fail(errors, "painting the yard at the yard beat (banked %d coins %d shipped %d wet %d) did not match painting it early (banked %d coins %d shipped %d wet %d)" % [
			late.get_banked(), late.get_coins(), late.get_shipped(), late.get_wet_haul(), banked.get_banked(), banked.get_coins(), banked.get_shipped(), banked.get_wet_haul(),
		])
	if int(dry_banked.get_wet_haul()) != 0 or int(dry_banked.get_stored_salt()) != 1032 or int(dry_banked.get_carted()) != 1032 or int(dry_banked.get_shipped()) != 1032 or int(dry_banked.get_coins()) != 1032:
		_fail(errors, "dry yard changed the dry sale (wet %d stored %d carted %d shipped %d coins %d)" % [
			dry_banked.get_wet_haul(), dry_banked.get_stored_salt(), dry_banked.get_carted(), dry_banked.get_shipped(), dry_banked.get_coins(),
		])
	if int(dry_banked.get_stored_salt()) - int(dry_banked.get_wet_haul()) != 1032:
		_fail(errors, "dry yard dry haul changed")
	if int(dry_banked.get_banked()) != 1032 or int(dry_banked.get_purse()) != 0:
		_fail(errors, "dry yard banked %d, purse left %d" % [dry_banked.get_banked(), dry_banked.get_purse()])
	var dry_yard_cell = plans["dry_banked"]["yard"][0]
	var dry_yard_salt: Dictionary = dry_banked.get_cell_salt(int(dry_yard_cell[0]), int(dry_yard_cell[1]))
	if int(dry_yard_salt.get("yard", 0)) != 1032:
		_fail(errors, "dry yard cell holds %s" % dry_yard_salt.get("yard", 0))
	if not String(dry_banked.get_summary()).contains("Banked 1032"):
		_fail(errors, "dry yard summary does not name the banked coins: %s" % dry_banked.get_summary())
	if not String(dry_banked.get_summary()).contains("Coins 1032"):
		_fail(errors, "dry yard summary dropped the earned coins: %s" % dry_banked.get_summary())
	_assert_pop(banked, errors, "banked plan")
	_assert_pop(late, errors, "late_banked")
	_assert_pop(dry_banked, errors, "dry_banked")
	_assert_pop(ignored, errors, "no_yard")
	# The beat opens after the market with the purse still at the stall. No yard, no banking.
	var opening = _prepare_plan(plans, "no_yard", errors)
	if opening == null:
		return
	var guard := 0
	var limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + 2
	while int(opening.get_beat()) != Sim.YARDING and not opening.is_over() and guard < limit:
		opening.tick()
		guard += 1
	if int(opening.get_beat()) != Sim.YARDING or opening.is_over() or int(opening.get_season()) != Sim.DRY:
		_fail(errors, "the market beat did not open a yard beat in the dry season")
		return
	if int(opening.get_ticks_until_rain()) != int(Sim.YARD_TICK):
		_fail(errors, "yard countdown started at %d, expected %d" % [opening.get_ticks_until_rain(), Sim.YARD_TICK])
	var purse := int(opening.get_purse())
	if int(opening.get_banked()) != 0 or purse != 2997 or int(opening.get_coins()) != purse:
		_fail(errors, "yard opened with banked %d purse %d coins %d" % [
			opening.get_banked(), purse, opening.get_coins(),
		])
	for _step in int(Sim.YARD_TICK):
		opening.tick()
	if int(opening.get_banked()) != 0 or int(opening.get_purse()) != purse or int(opening.get_coins()) != purse or int(opening.get_shipped()) != 2997 or int(opening.get_stored_salt()) != 2997:
		_fail(errors, "purse with no yard was banked (banked %d purse %d coins %d shipped %d stored %d)" % [
			opening.get_banked(), opening.get_purse(), opening.get_coins(), opening.get_shipped(), opening.get_stored_salt(),
		])
	if int(opening.get_beat()) != Sim.BUNKING or opening.is_over():
		_fail(errors, "the yard beat did not open a bunk beat")
	elif int(opening.get_ticks_until_rain()) != int(Sim.BUNK_TICK):
		_fail(errors, "bunk countdown started at %d after the yard, expected %d" % [opening.get_ticks_until_rain(), Sim.BUNK_TICK])
	print("banked %d; dry banked %d; no yard left coins %d" % [
		banked.get_banked(), dry_banked.get_banked(), ignored.get_coins(),
	])


func _test_bunk(errors: Array) -> void:
	if int(Sim.BUNK_TICK) != 100 or int(Sim.BUNK_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "bunk beat length %s is not 100 ticks (10 seconds)" % Sim.BUNK_TICK)
	if int(Sim.HIRE_COST) != 100:
		_fail(errors, "a hire costs %s, expected 100 coins" % Sim.HIRE_COST)
	var fresh = Sim.new()
	if fresh.paint_cell(14, 0, Sim.BUNK) == false or int(fresh.get_paint(14, 0)) != Sim.BUNK:
		_fail(errors, "a flat rejected the bunk mark")
	if fresh.paint_cell(Sim.COAST_X, 0, Sim.BUNK):
		_fail(errors, "the brine accepted a bunk")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.BUNK):
		_fail(errors, "the anthill accepted a bunk")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var won = _run_plan(plans, "winning", errors)
	var dry = _run_plan(plans, "dry_pans", errors)
	var parked = _run_plan(plans, "carted", errors)
	var loaded = _run_plan(plans, "shipped", errors)
	var sold = _run_plan(plans, "sold", errors)
	var banked = _run_plan(plans, "banked", errors)
	var ignored = _run_plan(plans, "no_bunk", errors)
	var hired = _run_plan(plans, "hired", errors)
	var hired_again = _run_plan(plans, "hired", errors)
	var late = _run_plan(plans, "late_hired", errors)
	var dry_hired = _run_plan(plans, "dry_hired", errors)
	if won == null or dry == null or parked == null or loaded == null or sold == null or banked == null or ignored == null or hired == null or hired_again == null or late == null or dry_hired == null:
		return
	# Earlier beats keep the numbers they had before the bunk existed.
	if int(won.get_wet_haul()) != 2997 or int(won.get_stored_salt()) != 2997 or int(won.get_carted()) != 0 or int(won.get_shipped()) != 0 or int(won.get_coins()) != 0 or int(won.get_hired()) != 0:
		_fail(errors, "winning shore changed (wet %d stored %d carted %d shipped %d coins %d hired %d)" % [
			won.get_wet_haul(), won.get_stored_salt(), won.get_carted(), won.get_shipped(), won.get_coins(), won.get_hired(),
		])
	if int(won.get_stored_salt()) - int(won.get_wet_haul()) != 0:
		_fail(errors, "winning dry haul changed")
	if int(dry.get_wet_haul()) != 0 or int(dry.get_stored_salt()) != 1032 or int(dry.get_carted()) != 0 or int(dry.get_shipped()) != 0 or int(dry.get_coins()) != 0 or int(dry.get_hired()) != 0:
		_fail(errors, "dry_pans changed (wet %d stored %d carted %d shipped %d coins %d hired %d)" % [
			dry.get_wet_haul(), dry.get_stored_salt(), dry.get_carted(), dry.get_shipped(), dry.get_coins(), dry.get_hired(),
		])
	if int(dry.get_stored_salt()) - int(dry.get_wet_haul()) != 1032:
		_fail(errors, "dry_pans dry haul changed")
	if int(parked.get_wet_haul()) != 2997 or int(parked.get_stored_salt()) != 2997 or int(parked.get_carted()) != 2997 or int(parked.get_shipped()) != 0 or int(parked.get_coins()) != 0 or int(parked.get_hired()) != 0:
		_fail(errors, "carted plan changed (wet %d stored %d carted %d shipped %d coins %d hired %d)" % [
			parked.get_wet_haul(), parked.get_stored_salt(), parked.get_carted(), parked.get_shipped(), parked.get_coins(), parked.get_hired(),
		])
	if int(loaded.get_wet_haul()) != 2997 or int(loaded.get_stored_salt()) != 2997 or int(loaded.get_carted()) != 2997 or int(loaded.get_shipped()) != 2997 or int(loaded.get_coins()) != 0 or int(loaded.get_hired()) != 0:
		_fail(errors, "shipped plan changed (wet %d stored %d carted %d shipped %d coins %d hired %d)" % [
			loaded.get_wet_haul(), loaded.get_stored_salt(), loaded.get_carted(), loaded.get_shipped(), loaded.get_coins(), loaded.get_hired(),
		])
	if int(sold.get_wet_haul()) != 2997 or int(sold.get_stored_salt()) != 2997 or int(sold.get_carted()) != 2997 or int(sold.get_shipped()) != 2997 or int(sold.get_coins()) != 2997 or int(sold.get_hired()) != 0 or int(sold.get_banked()) != 0:
		_fail(errors, "sold plan changed (wet %d stored %d carted %d shipped %d coins %d banked %d hired %d)" % [
			sold.get_wet_haul(), sold.get_stored_salt(), sold.get_carted(), sold.get_shipped(), sold.get_coins(), sold.get_banked(), sold.get_hired(),
		])
	if int(banked.get_wet_haul()) != 2997 or int(banked.get_stored_salt()) != 2997 or int(banked.get_carted()) != 2997 or int(banked.get_shipped()) != 2997 or int(banked.get_coins()) != 2997 or int(banked.get_banked()) != 2997 or int(banked.get_hired()) != 0 or int(banked.get_yard_left()) != 2997:
		_fail(errors, "banked plan with no bunk changed (wet %d stored %d carted %d shipped %d coins %d banked %d hired %d left %d)" % [
			banked.get_wet_haul(), banked.get_stored_salt(), banked.get_carted(), banked.get_shipped(), banked.get_coins(), banked.get_banked(), banked.get_hired(), banked.get_yard_left(),
		])
	if int(ignored.get_wet_haul()) != 2997 or int(ignored.get_stored_salt()) != 2997 or int(ignored.get_carted()) != 2997 or int(ignored.get_shipped()) != 2997 or int(ignored.get_coins()) != 2997 or int(ignored.get_banked()) != 2997 or int(ignored.get_hired()) != 0 or int(ignored.get_yard_left()) != 2997:
		_fail(errors, "no_bunk changed the purse (wet %d stored %d carted %d shipped %d coins %d banked %d hired %d left %d)" % [
			ignored.get_wet_haul(), ignored.get_stored_salt(), ignored.get_carted(), ignored.get_shipped(), ignored.get_coins(), ignored.get_banked(), ignored.get_hired(), ignored.get_yard_left(),
		])
	if String(ignored.get_summary()) != String(banked.get_summary()):
		_fail(errors, "no_bunk summary changed: %s" % ignored.get_summary())
	if not String(ignored.get_summary()).contains("Coins 2997") or not String(ignored.get_summary()).contains("Banked 2997"):
		_fail(errors, "no_bunk summary dropped the earned coins: %s" % ignored.get_summary())
	if String(ignored.get_summary()).contains("Hired"):
		_fail(errors, "no_bunk summary names a hire: %s" % ignored.get_summary())
	var ignored_yard = plans["no_bunk"]["yard"][0]
	var ignored_salt: Dictionary = ignored.get_cell_salt(int(ignored_yard[0]), int(ignored_yard[1]))
	if int(ignored_salt.get("yard", 0)) != 2997:
		_fail(errors, "no_bunk left %s in the yard" % ignored_salt.get("yard", 0))
	# This plan banked the coins and painted no bunk. The bunk check must fail.
	var ignored_check: Array = []
	_expect_bunk(ignored, ignored_check)
	if ignored_check.is_empty():
		_fail(errors, "no_bunk banked the coins and ignored the bunk, so the bunk check should have failed")
	else:
		print("no_bunk failed the bunk check: %s" % ignored_check[0])
	var bunk_cell = plans["hired"]["bunk"][0]
	var yard_cell = plans["hired"]["yard"][0]
	if int(bunk_cell[0]) != int(yard_cell[0]) or int(bunk_cell[1]) != int(yard_cell[1]) - 1:
		_fail(errors, "hired plan's bunk is not one cell north of the yard")
	var hired_check: Array = []
	_expect_bunk(hired, hired_check)
	for message in hired_check:
		_fail(errors, "hired plan: %s" % message)
	if int(hired.get_wet_haul()) != 2997 or int(hired.get_stored_salt()) != 2997 or int(hired.get_carted()) != 2997 or int(hired.get_shipped()) != 2997 or int(hired.get_coins()) != 2997 or int(hired.get_banked()) != 2997:
		_fail(errors, "bunk changed the banked shore (wet %d stored %d carted %d shipped %d coins %d banked %d)" % [
			hired.get_wet_haul(), hired.get_stored_salt(), hired.get_carted(), hired.get_shipped(), hired.get_coins(), hired.get_banked(),
		])
	if int(hired.get_stored_salt()) - int(hired.get_wet_haul()) != 0:
		_fail(errors, "hired plan dry haul changed")
	if int(hired.get_hired()) != 29 or int(hired.get_yard_left()) != 97:
		_fail(errors, "hired %d and left %d, expected 29 and 97" % [hired.get_hired(), hired.get_yard_left()])
	var bunk_salt: Dictionary = hired.get_cell_salt(int(bunk_cell[0]), int(bunk_cell[1]))
	if int(bunk_salt.get("bunk", 0)) != 29 or int(bunk_salt.get("bunk", 0)) != int(hired.get_hired()):
		_fail(errors, "bunk cell holds %s hires, hired %d" % [bunk_salt.get("bunk", 0), hired.get_hired()])
	var hired_yard: Dictionary = hired.get_cell_salt(int(yard_cell[0]), int(yard_cell[1]))
	if int(hired_yard.get("yard", 0)) != 97:
		_fail(errors, "bunk left %s in the yard" % hired_yard.get("yard", 0))
	var hired_summary := String(hired.get_summary())
	if not hired_summary.contains("Hired 29") or not hired_summary.contains("Left 97"):
		_fail(errors, "hired summary does not name the hires: %s" % hired_summary)
	if not hired_summary.contains("Coins 2997") or not hired_summary.contains("Banked 2997"):
		_fail(errors, "hired summary dropped the earned coins: %s" % hired_summary)
	if hired_summary.to_lower().contains("quota missed"):
		_fail(errors, "hired plan missed the quota: %s" % hired_summary)
	if int(hired_again.get_hired()) != int(hired.get_hired()) or int(hired_again.get_yard_left()) != int(hired.get_yard_left()) or int(hired_again.get_coins()) != int(hired.get_coins()):
		_fail(errors, "repeated hired paint hired %d left %d, then %d left %d" % [
			hired.get_hired(), hired.get_yard_left(), hired_again.get_hired(), hired_again.get_yard_left(),
		])
	if int(late.get_hired()) != 29 or int(late.get_yard_left()) != 97 or int(late.get_coins()) != int(hired.get_coins()) or int(late.get_shipped()) != int(hired.get_shipped()) or int(late.get_wet_haul()) != int(hired.get_wet_haul()) or int(late.get_banked()) != int(hired.get_banked()):
		_fail(errors, "painting the bunk at the bunk beat (hired %d left %d coins %d shipped %d wet %d) did not match painting it early (hired %d left %d coins %d shipped %d wet %d)" % [
			late.get_hired(), late.get_yard_left(), late.get_coins(), late.get_shipped(), late.get_wet_haul(), hired.get_hired(), hired.get_yard_left(), hired.get_coins(), hired.get_shipped(), hired.get_wet_haul(),
		])
	if int(dry_hired.get_wet_haul()) != 0 or int(dry_hired.get_stored_salt()) != 1032 or int(dry_hired.get_carted()) != 1032 or int(dry_hired.get_shipped()) != 1032 or int(dry_hired.get_coins()) != 1032 or int(dry_hired.get_banked()) != 1032:
		_fail(errors, "dry bunk changed the dry purse (wet %d stored %d carted %d shipped %d coins %d banked %d)" % [
			dry_hired.get_wet_haul(), dry_hired.get_stored_salt(), dry_hired.get_carted(), dry_hired.get_shipped(), dry_hired.get_coins(), dry_hired.get_banked(),
		])
	if int(dry_hired.get_stored_salt()) - int(dry_hired.get_wet_haul()) != 1032:
		_fail(errors, "dry bunk dry haul changed")
	if int(dry_hired.get_hired()) != 10 or int(dry_hired.get_yard_left()) != 32:
		_fail(errors, "dry bunk hired %d and left %d, expected 10 and 32" % [dry_hired.get_hired(), dry_hired.get_yard_left()])
	var dry_bunk_cell = plans["dry_hired"]["bunk"][0]
	var dry_yard_cell = plans["dry_hired"]["yard"][0]
	var dry_bunk_salt: Dictionary = dry_hired.get_cell_salt(int(dry_bunk_cell[0]), int(dry_bunk_cell[1]))
	var dry_yard_salt: Dictionary = dry_hired.get_cell_salt(int(dry_yard_cell[0]), int(dry_yard_cell[1]))
	if int(dry_bunk_salt.get("bunk", 0)) != 10 or int(dry_yard_salt.get("yard", 0)) != 32:
		_fail(errors, "dry bunk cell holds %s and yard holds %s" % [dry_bunk_salt.get("bunk", 0), dry_yard_salt.get("yard", 0)])
	if not String(dry_hired.get_summary()).contains("Hired 10") or not String(dry_hired.get_summary()).contains("Left 32"):
		_fail(errors, "dry bunk summary does not name the hires: %s" % dry_hired.get_summary())
	if not String(dry_hired.get_summary()).contains("Coins 1032"):
		_fail(errors, "dry bunk summary dropped the earned coins: %s" % dry_hired.get_summary())
	_assert_pop(hired, errors, "hired plan")
	_assert_pop(hired_again, errors, "hired plan again")
	_assert_pop(late, errors, "late_hired")
	_assert_pop(dry_hired, errors, "dry_hired")
	_assert_pop(ignored, errors, "no_bunk")
	# The beat opens after the yard with the purse still in the yard. No bunk, no hire.
	var opening = _prepare_plan(plans, "no_bunk", errors)
	if opening == null:
		return
	var guard := 0
	var limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + 2
	while int(opening.get_beat()) != Sim.BUNKING and not opening.is_over() and guard < limit:
		opening.tick()
		guard += 1
	if int(opening.get_beat()) != Sim.BUNKING or opening.is_over() or int(opening.get_season()) != Sim.DRY:
		_fail(errors, "the yard beat did not open a bunk beat in the dry season")
		return
	if int(opening.get_ticks_until_rain()) != int(Sim.BUNK_TICK):
		_fail(errors, "bunk countdown started at %d, expected %d" % [opening.get_ticks_until_rain(), Sim.BUNK_TICK])
	var left := int(opening.get_yard_left())
	if int(opening.get_hired()) != 0 or left != 2997 or int(opening.get_banked()) != left or int(opening.get_coins()) != left:
		_fail(errors, "bunk opened with hired %d yard %d banked %d coins %d" % [
			opening.get_hired(), left, opening.get_banked(), opening.get_coins(),
		])
	for _step in int(Sim.BUNK_TICK):
		opening.tick()
	if int(opening.get_hired()) != 0 or int(opening.get_yard_left()) != left or int(opening.get_banked()) != left or int(opening.get_coins()) != left or int(opening.get_shipped()) != 2997 or int(opening.get_stored_salt()) != 2997:
		_fail(errors, "purse with no bunk was hired (hired %d yard %d banked %d coins %d shipped %d stored %d)" % [
			opening.get_hired(), opening.get_yard_left(), opening.get_banked(), opening.get_coins(), opening.get_shipped(), opening.get_stored_salt(),
		])
	if int(opening.get_beat()) != Sim.LOFTING or opening.is_over():
		_fail(errors, "the bunk beat did not open a loft beat")
	elif int(opening.get_ticks_until_rain()) != int(Sim.LOFT_TICK):
		_fail(errors, "loft countdown started at %d after the bunk, expected %d" % [opening.get_ticks_until_rain(), Sim.LOFT_TICK])
	print("hired %d left %d; dry hired %d left %d; no bunk left %d" % [
		hired.get_hired(), hired.get_yard_left(), dry_hired.get_hired(), dry_hired.get_yard_left(), ignored.get_yard_left(),
	])


func _expect_bunk(sim, errors: Array) -> void:
	if sim == null:
		_fail(errors, "bunk plan did not run")
		return
	if not sim.is_over():
		_fail(errors, "bunk plan did not finish")
	if int(sim.get_hired()) <= 0:
		_fail(errors, "hired %d" % int(sim.get_hired()))
	var banked := int(sim.get_banked())
	var hired_count := int(sim.get_hired())
	var left := int(sim.get_yard_left())
	if hired_count * int(Sim.HIRE_COST) + left != banked:
		_fail(errors, "hired %d and left %d, which is not the banked %d" % [hired_count, left, banked])
	if left != banked % int(Sim.HIRE_COST):
		_fail(errors, "yard remainder %d is not the banked %d modulo %d" % [left, banked, Sim.HIRE_COST])
	if hired_count != int(banked / int(Sim.HIRE_COST)):
		_fail(errors, "hired %d of the %d the purse divides into" % [hired_count, int(banked / int(Sim.HIRE_COST))])


func _test_loft(errors: Array) -> void:
	if int(Sim.LOFT_TICK) != 100 or int(Sim.LOFT_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "loft beat length %s is not 100 ticks (10 seconds)" % Sim.LOFT_TICK)
	var fresh = Sim.new()
	if fresh.paint_cell(14, -1, Sim.LOFT) == false or int(fresh.get_paint(14, -1)) != Sim.LOFT:
		_fail(errors, "a flat rejected the loft mark")
	if fresh.paint_cell(Sim.COAST_X, -1, Sim.LOFT):
		_fail(errors, "the brine accepted a loft")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.LOFT):
		_fail(errors, "the anthill accepted a loft")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var won = _run_plan(plans, "winning", errors)
	var dry = _run_plan(plans, "dry_pans", errors)
	var parked = _run_plan(plans, "carted", errors)
	var loaded = _run_plan(plans, "shipped", errors)
	var sold = _run_plan(plans, "sold", errors)
	var banked = _run_plan(plans, "banked", errors)
	var hired = _run_plan(plans, "hired", errors)
	var dry_hired = _run_plan(plans, "dry_hired", errors)
	var ignored = _run_plan(plans, "no_loft", errors)
	var moved = _run_plan(plans, "lofted", errors)
	var moved_again = _run_plan(plans, "lofted", errors)
	var late = _run_plan(plans, "late_lofted", errors)
	var dry_moved = _run_plan(plans, "dry_lofted", errors)
	if won == null or dry == null or parked == null or loaded == null or sold == null or banked == null or hired == null or dry_hired == null or ignored == null or moved == null or moved_again == null or late == null or dry_moved == null:
		return
	# Earlier beats keep the numbers they had before the loft existed.
	if int(won.get_wet_haul()) != 2997 or int(won.get_stored_salt()) != 2997 or int(won.get_carted()) != 0 or int(won.get_shipped()) != 0 or int(won.get_coins()) != 0 or int(won.get_hired()) != 0 or int(won.get_lofted()) != 0:
		_fail(errors, "winning shore changed (wet %d stored %d carted %d shipped %d coins %d hired %d lofted %d)" % [
			won.get_wet_haul(), won.get_stored_salt(), won.get_carted(), won.get_shipped(), won.get_coins(), won.get_hired(), won.get_lofted(),
		])
	if int(dry.get_wet_haul()) != 0 or int(dry.get_stored_salt()) != 1032 or int(dry.get_carted()) != 0 or int(dry.get_shipped()) != 0 or int(dry.get_coins()) != 0 or int(dry.get_hired()) != 0 or int(dry.get_lofted()) != 0:
		_fail(errors, "dry_pans changed (wet %d stored %d carted %d shipped %d coins %d hired %d lofted %d)" % [
			dry.get_wet_haul(), dry.get_stored_salt(), dry.get_carted(), dry.get_shipped(), dry.get_coins(), dry.get_hired(), dry.get_lofted(),
		])
	if int(parked.get_wet_haul()) != 2997 or int(parked.get_stored_salt()) != 2997 or int(parked.get_carted()) != 2997 or int(parked.get_shipped()) != 0 or int(parked.get_coins()) != 0 or int(parked.get_hired()) != 0 or int(parked.get_lofted()) != 0:
		_fail(errors, "carted plan changed (wet %d stored %d carted %d shipped %d coins %d hired %d lofted %d)" % [
			parked.get_wet_haul(), parked.get_stored_salt(), parked.get_carted(), parked.get_shipped(), parked.get_coins(), parked.get_hired(), parked.get_lofted(),
		])
	if int(loaded.get_wet_haul()) != 2997 or int(loaded.get_stored_salt()) != 2997 or int(loaded.get_carted()) != 2997 or int(loaded.get_shipped()) != 2997 or int(loaded.get_coins()) != 0 or int(loaded.get_hired()) != 0 or int(loaded.get_lofted()) != 0:
		_fail(errors, "shipped plan changed (wet %d stored %d carted %d shipped %d coins %d hired %d lofted %d)" % [
			loaded.get_wet_haul(), loaded.get_stored_salt(), loaded.get_carted(), loaded.get_shipped(), loaded.get_coins(), loaded.get_hired(), loaded.get_lofted(),
		])
	if int(sold.get_wet_haul()) != 2997 or int(sold.get_stored_salt()) != 2997 or int(sold.get_carted()) != 2997 or int(sold.get_shipped()) != 2997 or int(sold.get_coins()) != 2997 or int(sold.get_hired()) != 0 or int(sold.get_lofted()) != 0:
		_fail(errors, "sold plan changed (wet %d stored %d carted %d shipped %d coins %d hired %d lofted %d)" % [
			sold.get_wet_haul(), sold.get_stored_salt(), sold.get_carted(), sold.get_shipped(), sold.get_coins(), sold.get_hired(), sold.get_lofted(),
		])
	if int(banked.get_wet_haul()) != 2997 or int(banked.get_stored_salt()) != 2997 or int(banked.get_carted()) != 2997 or int(banked.get_shipped()) != 2997 or int(banked.get_coins()) != 2997 or int(banked.get_banked()) != 2997 or int(banked.get_hired()) != 0 or int(banked.get_yard_left()) != 2997 or int(banked.get_lofted()) != 0:
		_fail(errors, "banked plan changed (wet %d stored %d carted %d shipped %d coins %d banked %d hired %d left %d lofted %d)" % [
			banked.get_wet_haul(), banked.get_stored_salt(), banked.get_carted(), banked.get_shipped(), banked.get_coins(), banked.get_banked(), banked.get_hired(), banked.get_yard_left(), banked.get_lofted(),
		])
	if int(hired.get_wet_haul()) != 2997 or int(hired.get_stored_salt()) != 2997 or int(hired.get_carted()) != 2997 or int(hired.get_shipped()) != 2997 or int(hired.get_coins()) != 2997 or int(hired.get_hired()) != 29 or int(hired.get_yard_left()) != 97 or int(hired.get_lofted()) != 0 or int(hired.get_bunk_left()) != 29:
		_fail(errors, "hired plan with no loft changed (wet %d stored %d carted %d shipped %d coins %d hired %d left %d lofted %d bunk %d)" % [
			hired.get_wet_haul(), hired.get_stored_salt(), hired.get_carted(), hired.get_shipped(), hired.get_coins(), hired.get_hired(), hired.get_yard_left(), hired.get_lofted(), hired.get_bunk_left(),
		])
	if int(dry_hired.get_wet_haul()) != 0 or int(dry_hired.get_stored_salt()) != 1032 or int(dry_hired.get_carted()) != 1032 or int(dry_hired.get_shipped()) != 1032 or int(dry_hired.get_coins()) != 1032 or int(dry_hired.get_hired()) != 10 or int(dry_hired.get_yard_left()) != 32 or int(dry_hired.get_lofted()) != 0:
		_fail(errors, "dry hired plan changed (wet %d stored %d carted %d shipped %d coins %d hired %d left %d lofted %d)" % [
			dry_hired.get_wet_haul(), dry_hired.get_stored_salt(), dry_hired.get_carted(), dry_hired.get_shipped(), dry_hired.get_coins(), dry_hired.get_hired(), dry_hired.get_yard_left(), dry_hired.get_lofted(),
		])
	if int(ignored.get_hired()) != 29 or int(ignored.get_yard_left()) != 97 or int(ignored.get_lofted()) != 0 or int(ignored.get_bunk_left()) != 29 or int(ignored.get_coins()) != 2997 or int(ignored.get_wet_haul()) != 2997 or int(ignored.get_shipped()) != 2997:
		_fail(errors, "no_loft changed the crew (wet %d shipped %d coins %d hired %d left %d lofted %d bunk %d)" % [
			ignored.get_wet_haul(), ignored.get_shipped(), ignored.get_coins(), ignored.get_hired(), ignored.get_yard_left(), ignored.get_lofted(), ignored.get_bunk_left(),
		])
	if String(ignored.get_summary()) != String(hired.get_summary()):
		_fail(errors, "no_loft summary changed: %s" % ignored.get_summary())
	if String(ignored.get_summary()).to_lower().contains("loft"):
		_fail(errors, "no_loft summary names a loft: %s" % ignored.get_summary())
	var ignored_bunk = plans["no_loft"]["bunk"][0]
	var ignored_salt: Dictionary = ignored.get_cell_salt(int(ignored_bunk[0]), int(ignored_bunk[1]))
	if int(ignored_salt.get("bunk", 0)) != 29:
		_fail(errors, "no_loft left %s hires at the bunk" % ignored_salt.get("bunk", 0))
	# This plan hired the crew and painted no loft. The loft check must fail.
	var ignored_check: Array = []
	_expect_loft(ignored, ignored_check)
	if ignored_check.is_empty():
		_fail(errors, "no_loft hired the crew and ignored the loft, so the loft check should have failed")
	else:
		print("no_loft failed the loft check: %s" % ignored_check[0])
	var loft_cell = plans["lofted"]["loft"][0]
	var bunk_cell = plans["lofted"]["bunk"][0]
	var yard_cell = plans["lofted"]["yard"][0]
	if int(loft_cell[0]) != int(bunk_cell[0]) or int(loft_cell[1]) != int(bunk_cell[1]) - 1:
		_fail(errors, "lofted plan's loft is not one cell north of the bunk")
	if int(bunk_cell[0]) != int(yard_cell[0]) or int(bunk_cell[1]) != int(yard_cell[1]) - 1:
		_fail(errors, "lofted plan's bunk is not one cell north of the yard")
	var moved_check: Array = []
	_expect_loft(moved, moved_check)
	for message in moved_check:
		_fail(errors, "lofted plan: %s" % message)
	if int(moved.get_wet_haul()) != 2997 or int(moved.get_stored_salt()) != 2997 or int(moved.get_carted()) != 2997 or int(moved.get_shipped()) != 2997 or int(moved.get_coins()) != 2997 or int(moved.get_banked()) != 2997 or int(moved.get_hired()) != 29 or int(moved.get_yard_left()) != 97:
		_fail(errors, "loft changed the hired shore (wet %d stored %d carted %d shipped %d coins %d banked %d hired %d left %d)" % [
			moved.get_wet_haul(), moved.get_stored_salt(), moved.get_carted(), moved.get_shipped(), moved.get_coins(), moved.get_banked(), moved.get_hired(), moved.get_yard_left(),
		])
	if int(moved.get_stored_salt()) - int(moved.get_wet_haul()) != 0:
		_fail(errors, "lofted plan dry haul changed")
	if int(moved.get_lofted()) != 29 or int(moved.get_bunk_left()) != 0:
		_fail(errors, "lofted %d and left %d at the bunk, expected 29 and 0" % [moved.get_lofted(), moved.get_bunk_left()])
	var loft_salt: Dictionary = moved.get_cell_salt(int(loft_cell[0]), int(loft_cell[1]))
	var bunk_salt: Dictionary = moved.get_cell_salt(int(bunk_cell[0]), int(bunk_cell[1]))
	var yard_salt: Dictionary = moved.get_cell_salt(int(yard_cell[0]), int(yard_cell[1]))
	if int(loft_salt.get("loft", 0)) != 29 or int(bunk_salt.get("bunk", 0)) != 0 or int(yard_salt.get("yard", 0)) != 97:
		_fail(errors, "loft cell holds %s, bunk holds %s, yard holds %s" % [loft_salt.get("loft", 0), bunk_salt.get("bunk", 0), yard_salt.get("yard", 0)])
	var moved_summary := String(moved.get_summary())
	if not moved_summary.contains("Lofted 29") or not moved_summary.contains("Hired 29") or not moved_summary.contains("Left 97"):
		_fail(errors, "lofted summary does not name the crew: %s" % moved_summary)
	if not moved_summary.contains("Coins 2997") or not moved_summary.contains("Banked 2997"):
		_fail(errors, "lofted summary dropped the earned coins: %s" % moved_summary)
	if moved_summary.to_lower().contains("quota missed"):
		_fail(errors, "lofted plan missed the quota: %s" % moved_summary)
	if int(moved_again.get_lofted()) != int(moved.get_lofted()) or int(moved_again.get_hired()) != int(moved.get_hired()) or int(moved_again.get_yard_left()) != int(moved.get_yard_left()):
		_fail(errors, "repeated loft paint lofted %d hired %d, then %d hired %d" % [
			moved.get_lofted(), moved.get_hired(), moved_again.get_lofted(), moved_again.get_hired(),
		])
	if int(late.get_lofted()) != 29 or int(late.get_hired()) != 29 or int(late.get_yard_left()) != 97 or int(late.get_coins()) != int(moved.get_coins()) or int(late.get_shipped()) != int(moved.get_shipped()) or int(late.get_wet_haul()) != int(moved.get_wet_haul()):
		_fail(errors, "painting the loft at the loft beat (lofted %d hired %d left %d coins %d shipped %d wet %d) did not match painting it early (lofted %d hired %d left %d coins %d shipped %d wet %d)" % [
			late.get_lofted(), late.get_hired(), late.get_yard_left(), late.get_coins(), late.get_shipped(), late.get_wet_haul(), moved.get_lofted(), moved.get_hired(), moved.get_yard_left(), moved.get_coins(), moved.get_shipped(), moved.get_wet_haul(),
		])
	if int(dry_moved.get_wet_haul()) != 0 or int(dry_moved.get_stored_salt()) != 1032 or int(dry_moved.get_carted()) != 1032 or int(dry_moved.get_shipped()) != 1032 or int(dry_moved.get_coins()) != 1032 or int(dry_moved.get_hired()) != 10 or int(dry_moved.get_yard_left()) != 32 or int(dry_moved.get_lofted()) != 10 or int(dry_moved.get_bunk_left()) != 0:
		_fail(errors, "dry loft changed the dry crew (wet %d stored %d carted %d shipped %d coins %d hired %d left %d lofted %d bunk %d)" % [
			dry_moved.get_wet_haul(), dry_moved.get_stored_salt(), dry_moved.get_carted(), dry_moved.get_shipped(), dry_moved.get_coins(), dry_moved.get_hired(), dry_moved.get_yard_left(), dry_moved.get_lofted(), dry_moved.get_bunk_left(),
		])
	var dry_loft_cell = plans["dry_lofted"]["loft"][0]
	var dry_bunk_cell = plans["dry_lofted"]["bunk"][0]
	var dry_yard_cell = plans["dry_lofted"]["yard"][0]
	var dry_loft_salt: Dictionary = dry_moved.get_cell_salt(int(dry_loft_cell[0]), int(dry_loft_cell[1]))
	var dry_bunk_salt: Dictionary = dry_moved.get_cell_salt(int(dry_bunk_cell[0]), int(dry_bunk_cell[1]))
	var dry_yard_salt: Dictionary = dry_moved.get_cell_salt(int(dry_yard_cell[0]), int(dry_yard_cell[1]))
	if int(dry_loft_salt.get("loft", 0)) != 10 or int(dry_bunk_salt.get("bunk", 0)) != 0 or int(dry_yard_salt.get("yard", 0)) != 32:
		_fail(errors, "dry loft cell holds %s, bunk holds %s, yard holds %s" % [dry_loft_salt.get("loft", 0), dry_bunk_salt.get("bunk", 0), dry_yard_salt.get("yard", 0)])
	if not String(dry_moved.get_summary()).contains("Lofted 10") or not String(dry_moved.get_summary()).contains("Hired 10") or not String(dry_moved.get_summary()).contains("Left 32"):
		_fail(errors, "dry loft summary does not name the crew: %s" % dry_moved.get_summary())
	_assert_pop(moved, errors, "lofted plan")
	_assert_pop(moved_again, errors, "lofted plan again")
	_assert_pop(late, errors, "late_lofted")
	_assert_pop(dry_moved, errors, "dry_lofted")
	_assert_pop(ignored, errors, "no_loft")
	# The beat opens after the bunk with the hires still at the bunk. No loft, no move.
	var opening = _prepare_plan(plans, "no_loft", errors)
	if opening == null:
		return
	var guard := 0
	var limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + 2
	while int(opening.get_beat()) != Sim.LOFTING and not opening.is_over() and guard < limit:
		opening.tick()
		guard += 1
	if int(opening.get_beat()) != Sim.LOFTING or opening.is_over() or int(opening.get_season()) != Sim.DRY:
		_fail(errors, "the bunk beat did not open a loft beat in the dry season")
		return
	if int(opening.get_ticks_until_rain()) != int(Sim.LOFT_TICK):
		_fail(errors, "loft countdown started at %d, expected %d" % [opening.get_ticks_until_rain(), Sim.LOFT_TICK])
	if int(opening.get_lofted()) != 0 or int(opening.get_bunk_left()) != 29 or int(opening.get_hired()) != 29 or int(opening.get_yard_left()) != 97:
		_fail(errors, "loft opened with lofted %d bunk %d hired %d yard %d" % [
			opening.get_lofted(), opening.get_bunk_left(), opening.get_hired(), opening.get_yard_left(),
		])
	for _step in int(Sim.LOFT_TICK):
		opening.tick()
	if int(opening.get_lofted()) != 0 or int(opening.get_bunk_left()) != 29 or int(opening.get_hired()) != 29 or int(opening.get_yard_left()) != 97 or int(opening.get_coins()) != 2997 or int(opening.get_stored_salt()) != 2997:
		_fail(errors, "crew with no loft was moved (lofted %d bunk %d hired %d yard %d coins %d stored %d)" % [
			opening.get_lofted(), opening.get_bunk_left(), opening.get_hired(), opening.get_yard_left(), opening.get_coins(), opening.get_stored_salt(),
		])
	if int(opening.get_beat()) != Sim.GATING or opening.is_over():
		_fail(errors, "the loft beat did not open a gate beat")
	elif int(opening.get_ticks_until_rain()) != int(Sim.GATE_TICK):
		_fail(errors, "gate countdown started at %d after the loft, expected %d" % [opening.get_ticks_until_rain(), Sim.GATE_TICK])
	print("lofted %d left yard %d; dry lofted %d left yard %d; no loft left bunk %d" % [
		moved.get_lofted(), moved.get_yard_left(), dry_moved.get_lofted(), dry_moved.get_yard_left(), ignored.get_bunk_left(),
	])


func _expect_loft(sim, errors: Array) -> void:
	if sim == null:
		_fail(errors, "loft plan did not run")
		return
	if not sim.is_over():
		_fail(errors, "loft plan did not finish")
	if int(sim.get_lofted()) <= 0:
		_fail(errors, "lofted %d" % int(sim.get_lofted()))
	if int(sim.get_bunk_left()) != 0:
		_fail(errors, "bunk still holds %d after the loft" % int(sim.get_bunk_left()))
	if int(sim.get_lofted()) != int(sim.get_hired()):
		_fail(errors, "lofted %d of the hired %d" % [int(sim.get_lofted()), int(sim.get_hired())])


func _test_gate(errors: Array) -> void:
	if int(Sim.GATE_TICK) != 100 or int(Sim.GATE_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "gate beat length %s is not 100 ticks (10 seconds)" % Sim.GATE_TICK)
	if int(Sim.GATE_CAP) != 10:
		_fail(errors, "gate cap is %s, expected 10" % Sim.GATE_CAP)
	var fresh = Sim.new()
	if fresh.paint_cell(14, -2, Sim.GATE) == false or int(fresh.get_paint(14, -2)) != Sim.GATE:
		_fail(errors, "a flat rejected the gate mark")
	if fresh.paint_cell(14, -8, Sim.GATE):
		_fail(errors, "the row north of the bell accepted a mark")
	if fresh.paint_cell(Sim.COAST_X, -2, Sim.GATE):
		_fail(errors, "the brine accepted a gate")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.GATE):
		_fail(errors, "the anthill accepted a gate")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var won = _run_plan(plans, "winning", errors)
	var dry = _run_plan(plans, "dry_pans", errors)
	var parked = _run_plan(plans, "carted", errors)
	var loaded = _run_plan(plans, "shipped", errors)
	var sold = _run_plan(plans, "sold", errors)
	var banked = _run_plan(plans, "banked", errors)
	var hired = _run_plan(plans, "hired", errors)
	var lofted = _run_plan(plans, "lofted", errors)
	var dry_lofted = _run_plan(plans, "dry_lofted", errors)
	var ignored = _run_plan(plans, "no_gate", errors)
	var passed = _run_plan(plans, "gated", errors)
	var passed_again = _run_plan(plans, "gated", errors)
	var late = _run_plan(plans, "late_gated", errors)
	var dry_passed = _run_plan(plans, "dry_gated", errors)
	if won == null or dry == null or parked == null or loaded == null or sold == null or banked == null or hired == null or lofted == null or dry_lofted == null or ignored == null or passed == null or passed_again == null or late == null or dry_passed == null:
		return
	# Earlier beats keep the numbers they had before the gate existed.
	if int(won.get_wet_haul()) != 2997 or int(won.get_stored_salt()) != 2997 or int(won.get_carted()) != 0 or int(won.get_shipped()) != 0 or int(won.get_coins()) != 0 or int(won.get_hired()) != 0 or int(won.get_lofted()) != 0 or int(won.get_gated()) != 0:
		_fail(errors, "winning shore changed (wet %d stored %d carted %d shipped %d coins %d hired %d lofted %d gated %d)" % [
			won.get_wet_haul(), won.get_stored_salt(), won.get_carted(), won.get_shipped(), won.get_coins(), won.get_hired(), won.get_lofted(), won.get_gated(),
		])
	if int(dry.get_wet_haul()) != 0 or int(dry.get_stored_salt()) != 1032 or int(dry.get_carted()) != 0 or int(dry.get_shipped()) != 0 or int(dry.get_coins()) != 0 or int(dry.get_hired()) != 0 or int(dry.get_lofted()) != 0 or int(dry.get_gated()) != 0:
		_fail(errors, "dry_pans changed (wet %d stored %d carted %d shipped %d coins %d hired %d lofted %d gated %d)" % [
			dry.get_wet_haul(), dry.get_stored_salt(), dry.get_carted(), dry.get_shipped(), dry.get_coins(), dry.get_hired(), dry.get_lofted(), dry.get_gated(),
		])
	if int(parked.get_wet_haul()) != 2997 or int(parked.get_stored_salt()) != 2997 or int(parked.get_carted()) != 2997 or int(parked.get_shipped()) != 0 or int(parked.get_coins()) != 0 or int(parked.get_hired()) != 0 or int(parked.get_gated()) != 0:
		_fail(errors, "carted plan changed (wet %d stored %d carted %d shipped %d coins %d hired %d gated %d)" % [
			parked.get_wet_haul(), parked.get_stored_salt(), parked.get_carted(), parked.get_shipped(), parked.get_coins(), parked.get_hired(), parked.get_gated(),
		])
	if int(loaded.get_wet_haul()) != 2997 or int(loaded.get_stored_salt()) != 2997 or int(loaded.get_carted()) != 2997 or int(loaded.get_shipped()) != 2997 or int(loaded.get_coins()) != 0 or int(loaded.get_hired()) != 0 or int(loaded.get_gated()) != 0:
		_fail(errors, "shipped plan changed (wet %d stored %d carted %d shipped %d coins %d hired %d gated %d)" % [
			loaded.get_wet_haul(), loaded.get_stored_salt(), loaded.get_carted(), loaded.get_shipped(), loaded.get_coins(), loaded.get_hired(), loaded.get_gated(),
		])
	if int(sold.get_wet_haul()) != 2997 or int(sold.get_stored_salt()) != 2997 or int(sold.get_carted()) != 2997 or int(sold.get_shipped()) != 2997 or int(sold.get_coins()) != 2997 or int(sold.get_hired()) != 0 or int(sold.get_gated()) != 0:
		_fail(errors, "sold plan changed (wet %d stored %d carted %d shipped %d coins %d hired %d gated %d)" % [
			sold.get_wet_haul(), sold.get_stored_salt(), sold.get_carted(), sold.get_shipped(), sold.get_coins(), sold.get_hired(), sold.get_gated(),
		])
	if int(banked.get_wet_haul()) != 2997 or int(banked.get_stored_salt()) != 2997 or int(banked.get_carted()) != 2997 or int(banked.get_shipped()) != 2997 or int(banked.get_coins()) != 2997 or int(banked.get_banked()) != 2997 or int(banked.get_hired()) != 0 or int(banked.get_yard_left()) != 2997 or int(banked.get_gated()) != 0:
		_fail(errors, "banked plan changed (wet %d stored %d carted %d shipped %d coins %d banked %d hired %d left %d gated %d)" % [
			banked.get_wet_haul(), banked.get_stored_salt(), banked.get_carted(), banked.get_shipped(), banked.get_coins(), banked.get_banked(), banked.get_hired(), banked.get_yard_left(), banked.get_gated(),
		])
	if int(hired.get_wet_haul()) != 2997 or int(hired.get_stored_salt()) != 2997 or int(hired.get_carted()) != 2997 or int(hired.get_shipped()) != 2997 or int(hired.get_coins()) != 2997 or int(hired.get_hired()) != 29 or int(hired.get_yard_left()) != 97 or int(hired.get_lofted()) != 0 or int(hired.get_gated()) != 0:
		_fail(errors, "hired plan changed (wet %d stored %d carted %d shipped %d coins %d hired %d left %d lofted %d gated %d)" % [
			hired.get_wet_haul(), hired.get_stored_salt(), hired.get_carted(), hired.get_shipped(), hired.get_coins(), hired.get_hired(), hired.get_yard_left(), hired.get_lofted(), hired.get_gated(),
		])
	if int(lofted.get_wet_haul()) != 2997 or int(lofted.get_stored_salt()) != 2997 or int(lofted.get_carted()) != 2997 or int(lofted.get_shipped()) != 2997 or int(lofted.get_coins()) != 2997 or int(lofted.get_hired()) != 29 or int(lofted.get_yard_left()) != 97 or int(lofted.get_lofted()) != 29 or int(lofted.get_bunk_left()) != 0 or int(lofted.get_gated()) != 0 or int(lofted.get_loft_left()) != 29:
		_fail(errors, "lofted plan changed (wet %d stored %d carted %d shipped %d coins %d hired %d left %d lofted %d bunk %d gated %d loft %d)" % [
			lofted.get_wet_haul(), lofted.get_stored_salt(), lofted.get_carted(), lofted.get_shipped(), lofted.get_coins(), lofted.get_hired(), lofted.get_yard_left(), lofted.get_lofted(), lofted.get_bunk_left(), lofted.get_gated(), lofted.get_loft_left(),
		])
	if int(dry_lofted.get_wet_haul()) != 0 or int(dry_lofted.get_stored_salt()) != 1032 or int(dry_lofted.get_carted()) != 1032 or int(dry_lofted.get_shipped()) != 1032 or int(dry_lofted.get_coins()) != 1032 or int(dry_lofted.get_hired()) != 10 or int(dry_lofted.get_yard_left()) != 32 or int(dry_lofted.get_lofted()) != 10 or int(dry_lofted.get_gated()) != 0 or int(dry_lofted.get_loft_left()) != 10:
		_fail(errors, "dry lofted plan changed (wet %d stored %d carted %d shipped %d coins %d hired %d left %d lofted %d gated %d loft %d)" % [
			dry_lofted.get_wet_haul(), dry_lofted.get_stored_salt(), dry_lofted.get_carted(), dry_lofted.get_shipped(), dry_lofted.get_coins(), dry_lofted.get_hired(), dry_lofted.get_yard_left(), dry_lofted.get_lofted(), dry_lofted.get_gated(), dry_lofted.get_loft_left(),
		])
	if int(ignored.get_gated()) != 0 or int(ignored.get_loft_left()) != 29 or int(ignored.get_lofted()) != 29 or int(ignored.get_hired()) != 29 or int(ignored.get_yard_left()) != 97 or int(ignored.get_bunk_left()) != 0 or int(ignored.get_coins()) != 2997 or int(ignored.get_wet_haul()) != 2997 or int(ignored.get_stored_salt()) != 2997 or int(ignored.get_carted()) != 2997 or int(ignored.get_shipped()) != 2997:
		_fail(errors, "no_gate changed the crew (wet %d stored %d carted %d shipped %d coins %d hired %d left %d lofted %d loft %d gated %d bunk %d)" % [
			ignored.get_wet_haul(), ignored.get_stored_salt(), ignored.get_carted(), ignored.get_shipped(), ignored.get_coins(), ignored.get_hired(), ignored.get_yard_left(), ignored.get_lofted(), ignored.get_loft_left(), ignored.get_gated(), ignored.get_bunk_left(),
		])
	if String(ignored.get_summary()) != String(lofted.get_summary()):
		_fail(errors, "no_gate summary changed: %s" % ignored.get_summary())
	if String(ignored.get_summary()).to_lower().contains("gate"):
		_fail(errors, "no_gate summary names a gate: %s" % ignored.get_summary())
	var ignored_loft = plans["no_gate"]["loft"][0]
	var ignored_salt: Dictionary = ignored.get_cell_salt(int(ignored_loft[0]), int(ignored_loft[1]))
	if int(ignored_salt.get("loft", 0)) != 29 or int(ignored_salt.get("gate", 0)) != 0:
		_fail(errors, "no_gate left %s in the loft and %s at a gate" % [ignored_salt.get("loft", 0), ignored_salt.get("gate", 0)])
	var ignored_check: Array = []
	_expect_gate(ignored, ignored_check)
	if ignored_check.is_empty():
		_fail(errors, "no_gate lofted the crew and ignored the gate, so the gate check should have failed")
	else:
		print("no_gate failed the gate check: %s" % ignored_check[0])
	var gate_cell = plans["gated"]["gate"][0]
	var loft_cell = plans["gated"]["loft"][0]
	var bunk_cell = plans["gated"]["bunk"][0]
	var yard_cell = plans["gated"]["yard"][0]
	if int(gate_cell[0]) != int(loft_cell[0]) or int(gate_cell[1]) != int(loft_cell[1]) - 1:
		_fail(errors, "gated plan's gate is not one cell north of the loft")
	if int(loft_cell[0]) != int(bunk_cell[0]) or int(loft_cell[1]) != int(bunk_cell[1]) - 1:
		_fail(errors, "gated plan's loft is not one cell north of the bunk")
	var passed_check: Array = []
	_expect_gate(passed, passed_check)
	for message in passed_check:
		_fail(errors, "gated plan: %s" % message)
	if int(passed.get_wet_haul()) != 2997 or int(passed.get_stored_salt()) != 2997 or int(passed.get_carted()) != 2997 or int(passed.get_shipped()) != 2997 or int(passed.get_coins()) != 2997 or int(passed.get_banked()) != 2997 or int(passed.get_hired()) != 29 or int(passed.get_yard_left()) != 97 or int(passed.get_lofted()) != 29 or int(passed.get_bunk_left()) != 0:
		_fail(errors, "gate changed the lofted shore (wet %d stored %d carted %d shipped %d coins %d banked %d hired %d left %d lofted %d bunk %d)" % [
			passed.get_wet_haul(), passed.get_stored_salt(), passed.get_carted(), passed.get_shipped(), passed.get_coins(), passed.get_banked(), passed.get_hired(), passed.get_yard_left(), passed.get_lofted(), passed.get_bunk_left(),
		])
	if int(passed.get_stored_salt()) - int(passed.get_wet_haul()) != 0:
		_fail(errors, "gated plan dry haul changed")
	if int(passed.get_gated()) != 10 or int(passed.get_loft_left()) != 19:
		_fail(errors, "gated %d and left %d in the loft, expected 10 and 19" % [passed.get_gated(), passed.get_loft_left()])
	var gate_salt: Dictionary = passed.get_cell_salt(int(gate_cell[0]), int(gate_cell[1]))
	var loft_salt: Dictionary = passed.get_cell_salt(int(loft_cell[0]), int(loft_cell[1]))
	var bunk_salt: Dictionary = passed.get_cell_salt(int(bunk_cell[0]), int(bunk_cell[1]))
	var yard_salt: Dictionary = passed.get_cell_salt(int(yard_cell[0]), int(yard_cell[1]))
	if int(gate_salt.get("gate", 0)) != 10 or int(loft_salt.get("loft", 0)) != 19 or int(bunk_salt.get("bunk", 0)) != 0 or int(yard_salt.get("yard", 0)) != 97:
		_fail(errors, "gate cell holds %s, loft holds %s, bunk holds %s, yard holds %s" % [gate_salt.get("gate", 0), loft_salt.get("loft", 0), bunk_salt.get("bunk", 0), yard_salt.get("yard", 0)])
	var passed_summary := String(passed.get_summary())
	if not passed_summary.contains("Gated 10") or not passed_summary.contains("Left 19 in the loft") or not passed_summary.contains("Lofted 29") or not passed_summary.contains("Hired 29") or not passed_summary.contains("Left 97"):
		_fail(errors, "gated summary does not name the gate: %s" % passed_summary)
	if not passed_summary.contains("Coins 2997") or not passed_summary.contains("Banked 2997"):
		_fail(errors, "gated summary dropped the earned coins: %s" % passed_summary)
	if passed_summary.to_lower().contains("quota missed"):
		_fail(errors, "gated plan missed the quota: %s" % passed_summary)
	if int(passed_again.get_gated()) != int(passed.get_gated()) or int(passed_again.get_loft_left()) != int(passed.get_loft_left()) or int(passed_again.get_hired()) != int(passed.get_hired()) or int(passed_again.get_yard_left()) != int(passed.get_yard_left()):
		_fail(errors, "repeated gate paint let %d through and left %d, then %d and %d" % [
			passed.get_gated(), passed.get_loft_left(), passed_again.get_gated(), passed_again.get_loft_left(),
		])
	if int(late.get_gated()) != 10 or int(late.get_loft_left()) != 19 or int(late.get_lofted()) != 29 or int(late.get_hired()) != 29 or int(late.get_yard_left()) != 97 or int(late.get_coins()) != int(passed.get_coins()) or int(late.get_shipped()) != int(passed.get_shipped()) or int(late.get_wet_haul()) != int(passed.get_wet_haul()):
		_fail(errors, "painting the gate at the gate beat (gated %d loft %d hired %d left %d coins %d shipped %d wet %d) did not match painting it early (gated %d loft %d hired %d left %d coins %d shipped %d wet %d)" % [
			late.get_gated(), late.get_loft_left(), late.get_hired(), late.get_yard_left(), late.get_coins(), late.get_shipped(), late.get_wet_haul(), passed.get_gated(), passed.get_loft_left(), passed.get_hired(), passed.get_yard_left(), passed.get_coins(), passed.get_shipped(), passed.get_wet_haul(),
		])
	if int(dry_passed.get_wet_haul()) != 0 or int(dry_passed.get_stored_salt()) != 1032 or int(dry_passed.get_carted()) != 1032 or int(dry_passed.get_shipped()) != 1032 or int(dry_passed.get_coins()) != 1032 or int(dry_passed.get_hired()) != 10 or int(dry_passed.get_yard_left()) != 32 or int(dry_passed.get_lofted()) != 10 or int(dry_passed.get_gated()) != 10 or int(dry_passed.get_loft_left()) != 0 or int(dry_passed.get_bunk_left()) != 0:
		_fail(errors, "dry gate changed the dry crew (wet %d stored %d carted %d shipped %d coins %d hired %d left %d lofted %d gated %d loft %d bunk %d)" % [
			dry_passed.get_wet_haul(), dry_passed.get_stored_salt(), dry_passed.get_carted(), dry_passed.get_shipped(), dry_passed.get_coins(), dry_passed.get_hired(), dry_passed.get_yard_left(), dry_passed.get_lofted(), dry_passed.get_gated(), dry_passed.get_loft_left(), dry_passed.get_bunk_left(),
		])
	var dry_gate_cell = plans["dry_gated"]["gate"][0]
	var dry_loft_cell = plans["dry_gated"]["loft"][0]
	var dry_yard_cell = plans["dry_gated"]["yard"][0]
	var dry_gate_salt: Dictionary = dry_passed.get_cell_salt(int(dry_gate_cell[0]), int(dry_gate_cell[1]))
	var dry_loft_salt: Dictionary = dry_passed.get_cell_salt(int(dry_loft_cell[0]), int(dry_loft_cell[1]))
	var dry_yard_salt: Dictionary = dry_passed.get_cell_salt(int(dry_yard_cell[0]), int(dry_yard_cell[1]))
	if int(dry_gate_salt.get("gate", 0)) != 10 or int(dry_loft_salt.get("loft", 0)) != 0 or int(dry_yard_salt.get("yard", 0)) != 32:
		_fail(errors, "dry gate cell holds %s, loft holds %s, yard holds %s" % [dry_gate_salt.get("gate", 0), dry_loft_salt.get("loft", 0), dry_yard_salt.get("yard", 0)])
	if not String(dry_passed.get_summary()).contains("Gated 10") or not String(dry_passed.get_summary()).contains("Left 0 in the loft") or not String(dry_passed.get_summary()).contains("Lofted 10") or not String(dry_passed.get_summary()).contains("Hired 10") or not String(dry_passed.get_summary()).contains("Left 32"):
		_fail(errors, "dry gate summary does not name the gate: %s" % dry_passed.get_summary())
	_assert_pop(passed, errors, "gated plan")
	_assert_pop(passed_again, errors, "gated plan again")
	_assert_pop(late, errors, "late_gated")
	_assert_pop(dry_passed, errors, "dry_gated")
	_assert_pop(ignored, errors, "no_gate")
	# The cap stops the gate while the countdown still has ticks left.
	var watch = _prepare_plan(plans, "gated", errors)
	if watch == null:
		return
	var watch_guard := 0
	var watch_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + 2
	while int(watch.get_beat()) != Sim.GATING and not watch.is_over() and watch_guard < watch_limit:
		watch.tick()
		watch_guard += 1
	if int(watch.get_beat()) != Sim.GATING or watch.is_over():
		_fail(errors, "the loft beat did not open a gate beat for the cap check")
		return
	var saw_cap := false
	var cap_guard := 0
	while not watch.is_over() and cap_guard < int(Sim.GATE_TICK) + 2:
		watch.tick()
		cap_guard += 1
		if int(watch.get_gated()) == int(Sim.GATE_CAP) and int(watch.get_ticks_until_rain()) > 0 and int(watch.get_loft_left()) == 19:
			saw_cap = true
			var ticks_left := int(watch.get_ticks_until_rain())
			watch.tick()
			if int(watch.get_gated()) != int(Sim.GATE_CAP) or int(watch.get_loft_left()) != 19:
				_fail(errors, "the gate kept moving after the cap (gated %d loft %d)" % [watch.get_gated(), watch.get_loft_left()])
			elif not watch.is_over() and int(watch.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the gate beat did not spend a tick after the cap")
			break
	if not saw_cap:
		_fail(errors, "the gate did not stop at %d while ticks remained (gated %d loft %d ticks %d)" % [
			Sim.GATE_CAP, watch.get_gated(), watch.get_loft_left(), watch.get_ticks_until_rain(),
		])
	# The beat opens after the loft with the crew still in the loft. No gate, nobody passes.
	var opening = _prepare_plan(plans, "no_gate", errors)
	if opening == null:
		return
	var guard := 0
	var limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + 2
	while int(opening.get_beat()) != Sim.GATING and not opening.is_over() and guard < limit:
		opening.tick()
		guard += 1
	if int(opening.get_beat()) != Sim.GATING or opening.is_over() or int(opening.get_season()) != Sim.DRY:
		_fail(errors, "the loft beat did not open a gate beat in the dry season")
		return
	if int(opening.get_ticks_until_rain()) != int(Sim.GATE_TICK):
		_fail(errors, "gate countdown started at %d, expected %d" % [opening.get_ticks_until_rain(), Sim.GATE_TICK])
	if int(opening.get_gated()) != 0 or int(opening.get_loft_left()) != 29 or int(opening.get_lofted()) != 29 or int(opening.get_hired()) != 29 or int(opening.get_yard_left()) != 97:
		_fail(errors, "gate opened with gated %d loft %d lofted %d hired %d yard %d" % [
			opening.get_gated(), opening.get_loft_left(), opening.get_lofted(), opening.get_hired(), opening.get_yard_left(),
		])
	for _step in int(Sim.GATE_TICK):
		opening.tick()
	if int(opening.get_gated()) != 0 or int(opening.get_loft_left()) != 29 or int(opening.get_lofted()) != 29 or int(opening.get_hired()) != 29 or int(opening.get_yard_left()) != 97 or int(opening.get_coins()) != 2997 or int(opening.get_stored_salt()) != 2997:
		_fail(errors, "crew with no gate was moved (gated %d loft %d lofted %d hired %d yard %d coins %d stored %d)" % [
			opening.get_gated(), opening.get_loft_left(), opening.get_lofted(), opening.get_hired(), opening.get_yard_left(), opening.get_coins(), opening.get_stored_salt(),
		])
	if int(opening.get_beat()) != Sim.WAGING or opening.is_over():
		_fail(errors, "the gate beat did not open a wage beat")
	elif int(opening.get_ticks_until_rain()) != int(Sim.WAGE_TICK):
		_fail(errors, "wage countdown started at %d after the gate, expected %d" % [opening.get_ticks_until_rain(), Sim.WAGE_TICK])
	print("gated %d left loft %d; dry gated %d left loft %d; no gate left loft %d" % [
		passed.get_gated(), passed.get_loft_left(), dry_passed.get_gated(), dry_passed.get_loft_left(), ignored.get_loft_left(),
	])


func _expect_gate(sim, errors: Array) -> void:
	if sim == null:
		_fail(errors, "gate plan did not run")
		return
	if not sim.is_over():
		_fail(errors, "gate plan did not finish")
	if int(sim.get_gated()) <= 0:
		_fail(errors, "let %d through the gate" % int(sim.get_gated()))
		return
	var allowed := mini(int(sim.get_lofted()), int(Sim.GATE_CAP))
	if int(sim.get_gated()) != allowed:
		_fail(errors, "let %d through, cap allows %d of the lofted %d" % [int(sim.get_gated()), allowed, int(sim.get_lofted())])
	if int(sim.get_loft_left()) != int(sim.get_lofted()) - int(sim.get_gated()):
		_fail(errors, "loft still holds %d after letting %d of %d through" % [int(sim.get_loft_left()), int(sim.get_gated()), int(sim.get_lofted())])
	if int(sim.get_gated()) > int(Sim.GATE_CAP):
		_fail(errors, "gate let %d through, cap is %d" % [int(sim.get_gated()), Sim.GATE_CAP])


func _test_wage(errors: Array) -> void:
	if int(Sim.WAGE_TICK) != 100 or int(Sim.WAGE_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "wage beat length %s is not 100 ticks (10 seconds)" % Sim.WAGE_TICK)
	if int(Sim.WAGE_COST) != 4:
		_fail(errors, "wage price is %s coins, expected 4" % Sim.WAGE_COST)
	var fresh = Sim.new()
	if fresh.paint_cell(14, -3, Sim.WAGE) == false or int(fresh.get_paint(14, -3)) != Sim.WAGE:
		_fail(errors, "the cell north of the gate rejected the wage mark")
	if fresh.paint_cell(14, -8, Sim.WAGE):
		_fail(errors, "the row north of the bell accepted a mark")
	if fresh.paint_cell(Sim.COAST_X, -3, Sim.WAGE):
		_fail(errors, "the brine accepted a wage")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.WAGE):
		_fail(errors, "the anthill accepted a wage")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var won = _run_plan(plans, "winning", errors)
	var dry = _run_plan(plans, "dry_pans", errors)
	var parked = _run_plan(plans, "carted", errors)
	var loaded = _run_plan(plans, "shipped", errors)
	var sold = _run_plan(plans, "sold", errors)
	var banked = _run_plan(plans, "banked", errors)
	var hired = _run_plan(plans, "hired", errors)
	var lofted = _run_plan(plans, "lofted", errors)
	var passed = _run_plan(plans, "gated", errors)
	var dry_passed = _run_plan(plans, "dry_gated", errors)
	var ignored = _run_plan(plans, "no_wage", errors)
	var paid = _run_plan(plans, "paid", errors)
	var paid_again = _run_plan(plans, "paid", errors)
	var late = _run_plan(plans, "late_paid", errors)
	var dry_paid = _run_plan(plans, "dry_paid", errors)
	if won == null or dry == null or parked == null or loaded == null or sold == null or banked == null or hired == null or lofted == null or passed == null or dry_passed == null or ignored == null or paid == null or paid_again == null or late == null or dry_paid == null:
		return
	# Earlier plans keep the numbers they had before the wage existed. A plan
	# that does not paint the wage also keeps its yard remainder.
	if int(won.get_wet_haul()) != 2997 or int(won.get_stored_salt()) != 2997 or int(won.get_carted()) != 0 or int(won.get_shipped()) != 0 or int(won.get_coins()) != 0 or int(won.get_hired()) != 0 or int(won.get_lofted()) != 0 or int(won.get_gated()) != 0 or int(won.get_paid()) != 0 or int(won.get_yard_left()) != 0:
		_fail(errors, "winning shore changed (wet %d stored %d carted %d shipped %d coins %d hired %d lofted %d gated %d paid %d yard %d)" % [
			won.get_wet_haul(), won.get_stored_salt(), won.get_carted(), won.get_shipped(), won.get_coins(), won.get_hired(), won.get_lofted(), won.get_gated(), won.get_paid(), won.get_yard_left(),
		])
	if int(dry.get_wet_haul()) != 0 or int(dry.get_stored_salt()) != 1032 or int(dry.get_carted()) != 0 or int(dry.get_shipped()) != 0 or int(dry.get_coins()) != 0 or int(dry.get_hired()) != 0 or int(dry.get_paid()) != 0 or int(dry.get_yard_left()) != 0:
		_fail(errors, "dry_pans changed (wet %d stored %d carted %d shipped %d coins %d hired %d paid %d yard %d)" % [
			dry.get_wet_haul(), dry.get_stored_salt(), dry.get_carted(), dry.get_shipped(), dry.get_coins(), dry.get_hired(), dry.get_paid(), dry.get_yard_left(),
		])
	if int(parked.get_wet_haul()) != 2997 or int(parked.get_stored_salt()) != 2997 or int(parked.get_carted()) != 2997 or int(parked.get_shipped()) != 0 or int(parked.get_coins()) != 0 or int(parked.get_hired()) != 0 or int(parked.get_paid()) != 0:
		_fail(errors, "carted plan changed (wet %d stored %d carted %d shipped %d coins %d hired %d paid %d)" % [
			parked.get_wet_haul(), parked.get_stored_salt(), parked.get_carted(), parked.get_shipped(), parked.get_coins(), parked.get_hired(), parked.get_paid(),
		])
	if int(loaded.get_wet_haul()) != 2997 or int(loaded.get_stored_salt()) != 2997 or int(loaded.get_carted()) != 2997 or int(loaded.get_shipped()) != 2997 or int(loaded.get_coins()) != 0 or int(loaded.get_paid()) != 0:
		_fail(errors, "shipped plan changed (wet %d stored %d carted %d shipped %d coins %d paid %d)" % [
			loaded.get_wet_haul(), loaded.get_stored_salt(), loaded.get_carted(), loaded.get_shipped(), loaded.get_coins(), loaded.get_paid(),
		])
	if int(sold.get_wet_haul()) != 2997 or int(sold.get_stored_salt()) != 2997 or int(sold.get_carted()) != 2997 or int(sold.get_shipped()) != 2997 or int(sold.get_coins()) != 2997 or int(sold.get_paid()) != 0:
		_fail(errors, "sold plan changed (wet %d stored %d carted %d shipped %d coins %d paid %d)" % [
			sold.get_wet_haul(), sold.get_stored_salt(), sold.get_carted(), sold.get_shipped(), sold.get_coins(), sold.get_paid(),
		])
	if int(banked.get_wet_haul()) != 2997 or int(banked.get_stored_salt()) != 2997 or int(banked.get_coins()) != 2997 or int(banked.get_banked()) != 2997 or int(banked.get_yard_left()) != 2997 or int(banked.get_paid()) != 0:
		_fail(errors, "banked plan changed (wet %d stored %d coins %d banked %d left %d paid %d)" % [
			banked.get_wet_haul(), banked.get_stored_salt(), banked.get_coins(), banked.get_banked(), banked.get_yard_left(), banked.get_paid(),
		])
	if int(hired.get_hired()) != 29 or int(hired.get_yard_left()) != 97 or int(hired.get_coins()) != 2997 or int(hired.get_paid()) != 0 or int(hired.get_stored_salt()) != 2997:
		_fail(errors, "hired plan changed (stored %d coins %d hired %d left %d paid %d)" % [
			hired.get_stored_salt(), hired.get_coins(), hired.get_hired(), hired.get_yard_left(), hired.get_paid(),
		])
	if int(lofted.get_lofted()) != 29 or int(lofted.get_hired()) != 29 or int(lofted.get_yard_left()) != 97 or int(lofted.get_paid()) != 0 or int(lofted.get_coins()) != 2997:
		_fail(errors, "lofted plan changed (coins %d hired %d left %d lofted %d paid %d)" % [
			lofted.get_coins(), lofted.get_hired(), lofted.get_yard_left(), lofted.get_lofted(), lofted.get_paid(),
		])
	if int(passed.get_gated()) != 10 or int(passed.get_loft_left()) != 19 or int(passed.get_hired()) != 29 or int(passed.get_yard_left()) != 97 or int(passed.get_paid()) != 0 or int(passed.get_coins()) != 2997 or int(passed.get_stored_salt()) != 2997 or int(passed.get_carted()) != 2997 or int(passed.get_shipped()) != 2997:
		_fail(errors, "gated plan changed (stored %d carted %d shipped %d coins %d hired %d left %d gated %d loft %d paid %d)" % [
			passed.get_stored_salt(), passed.get_carted(), passed.get_shipped(), passed.get_coins(), passed.get_hired(), passed.get_yard_left(), passed.get_gated(), passed.get_loft_left(), passed.get_paid(),
		])
	if int(dry_passed.get_wet_haul()) != 0 or int(dry_passed.get_stored_salt()) != 1032 or int(dry_passed.get_coins()) != 1032 or int(dry_passed.get_hired()) != 10 or int(dry_passed.get_yard_left()) != 32 or int(dry_passed.get_gated()) != 10 or int(dry_passed.get_loft_left()) != 0 or int(dry_passed.get_paid()) != 0:
		_fail(errors, "dry gate changed (wet %d stored %d coins %d hired %d left %d gated %d loft %d paid %d)" % [
			dry_passed.get_wet_haul(), dry_passed.get_stored_salt(), dry_passed.get_coins(), dry_passed.get_hired(), dry_passed.get_yard_left(), dry_passed.get_gated(), dry_passed.get_loft_left(), dry_passed.get_paid(),
		])
	if int(ignored.get_paid()) != 0 or int(ignored.get_gate_left()) != 10 or int(ignored.get_gated()) != 10 or int(ignored.get_loft_left()) != 19 or int(ignored.get_yard_left()) != 97 or int(ignored.get_hired()) != 29 or int(ignored.get_coins()) != 2997 or int(ignored.get_stored_salt()) != 2997 or int(ignored.get_carted()) != 2997 or int(ignored.get_shipped()) != 2997:
		_fail(errors, "no_wage paid someone (stored %d carted %d shipped %d coins %d hired %d left %d gated %d unpaid %d loft %d paid %d)" % [
			ignored.get_stored_salt(), ignored.get_carted(), ignored.get_shipped(), ignored.get_coins(), ignored.get_hired(), ignored.get_yard_left(), ignored.get_gated(), ignored.get_gate_left(), ignored.get_loft_left(), ignored.get_paid(),
		])
	if String(ignored.get_summary()) != String(passed.get_summary()):
		_fail(errors, "no_wage summary changed: %s" % ignored.get_summary())
	if String(ignored.get_summary()).to_lower().contains("paid") or String(ignored.get_summary()).to_lower().contains("wage"):
		_fail(errors, "no_wage summary names a wage: %s" % ignored.get_summary())
	var ignored_gate = plans["no_wage"]["gate"][0]
	var ignored_salt: Dictionary = ignored.get_cell_salt(int(ignored_gate[0]), int(ignored_gate[1]))
	if int(ignored_salt.get("gate", 0)) != 10 or int(ignored_salt.get("wage", 0)) != 0:
		_fail(errors, "no_wage left %s at the gate and %s at a wage" % [ignored_salt.get("gate", 0), ignored_salt.get("wage", 0)])
	var wage_cell = plans["paid"]["wage"][0]
	var gate_cell = plans["paid"]["gate"][0]
	var loft_cell = plans["paid"]["loft"][0]
	var yard_cell = plans["paid"]["yard"][0]
	if int(wage_cell[0]) != int(gate_cell[0]) or int(wage_cell[1]) != int(gate_cell[1]) - 1:
		_fail(errors, "paid plan's wage is not one cell north of the gate")
	if int(gate_cell[0]) != int(loft_cell[0]) or int(gate_cell[1]) != int(loft_cell[1]) - 1:
		_fail(errors, "paid plan's gate is not one cell north of the loft")
	if int(paid.get_wet_haul()) != 2997 or int(paid.get_stored_salt()) != 2997 or int(paid.get_carted()) != 2997 or int(paid.get_shipped()) != 2997 or int(paid.get_coins()) != 2997 or int(paid.get_banked()) != 2997 or int(paid.get_hired()) != 29 or int(paid.get_lofted()) != 29 or int(paid.get_gated()) != 10 or int(paid.get_loft_left()) != 19:
		_fail(errors, "wage changed the gated shore (wet %d stored %d carted %d shipped %d coins %d banked %d hired %d lofted %d gated %d loft %d)" % [
			paid.get_wet_haul(), paid.get_stored_salt(), paid.get_carted(), paid.get_shipped(), paid.get_coins(), paid.get_banked(), paid.get_hired(), paid.get_lofted(), paid.get_gated(), paid.get_loft_left(),
		])
	if int(paid.get_paid()) != 10 or int(paid.get_gate_left()) != 0 or int(paid.get_yard_left()) != 57:
		_fail(errors, "paid %d, left %d unpaid, yard %d; expected 10, 0, 57" % [paid.get_paid(), paid.get_gate_left(), paid.get_yard_left()])
	if int(paid.get_paid()) * int(Sim.WAGE_COST) + int(paid.get_yard_left()) != 97:
		_fail(errors, "wage price did not take 4 coins a hire (paid %d left %d)" % [paid.get_paid(), paid.get_yard_left()])
	var wage_salt: Dictionary = paid.get_cell_salt(int(wage_cell[0]), int(wage_cell[1]))
	var gate_salt: Dictionary = paid.get_cell_salt(int(gate_cell[0]), int(gate_cell[1]))
	var loft_salt: Dictionary = paid.get_cell_salt(int(loft_cell[0]), int(loft_cell[1]))
	var yard_salt: Dictionary = paid.get_cell_salt(int(yard_cell[0]), int(yard_cell[1]))
	if int(wage_salt.get("wage", 0)) != 10 or int(gate_salt.get("gate", 0)) != 0 or int(loft_salt.get("loft", 0)) != 19 or int(yard_salt.get("yard", 0)) != 57:
		_fail(errors, "wage cell holds %s, gate holds %s, loft holds %s, yard holds %s" % [wage_salt.get("wage", 0), gate_salt.get("gate", 0), loft_salt.get("loft", 0), yard_salt.get("yard", 0)])
	var paid_summary := String(paid.get_summary())
	if not paid_summary.contains("Paid 10") or not paid_summary.contains("Left 0 unpaid") or not paid_summary.contains("Left 57") or not paid_summary.contains("Gated 10") or not paid_summary.contains("Left 19 in the loft"):
		_fail(errors, "paid summary does not name the wage: %s" % paid_summary)
	if not paid_summary.contains("Coins 2997") or not paid_summary.contains("Hired 29"):
		_fail(errors, "paid summary dropped the earlier totals: %s" % paid_summary)
	if int(paid_again.get_paid()) != int(paid.get_paid()) or int(paid_again.get_gate_left()) != int(paid.get_gate_left()) or int(paid_again.get_yard_left()) != int(paid.get_yard_left()):
		_fail(errors, "repeated wage paint paid %d and left yard %d, then paid %d and left yard %d" % [
			paid.get_paid(), paid.get_yard_left(), paid_again.get_paid(), paid_again.get_yard_left(),
		])
	if int(late.get_paid()) != 10 or int(late.get_gate_left()) != 0 or int(late.get_yard_left()) != 57 or int(late.get_gated()) != 10 or int(late.get_loft_left()) != 19 or int(late.get_hired()) != 29 or int(late.get_coins()) != int(paid.get_coins()) or int(late.get_stored_salt()) != int(paid.get_stored_salt()):
		_fail(errors, "painting the wage at the wage beat (paid %d unpaid %d yard %d gated %d loft %d hired %d coins %d stored %d) did not match painting it early (paid %d unpaid %d yard %d gated %d loft %d hired %d coins %d stored %d)" % [
			late.get_paid(), late.get_gate_left(), late.get_yard_left(), late.get_gated(), late.get_loft_left(), late.get_hired(), late.get_coins(), late.get_stored_salt(), paid.get_paid(), paid.get_gate_left(), paid.get_yard_left(), paid.get_gated(), paid.get_loft_left(), paid.get_hired(), paid.get_coins(), paid.get_stored_salt(),
		])
	if int(dry_paid.get_wet_haul()) != 0 or int(dry_paid.get_stored_salt()) != 1032 or int(dry_paid.get_carted()) != 1032 or int(dry_paid.get_shipped()) != 1032 or int(dry_paid.get_coins()) != 1032 or int(dry_paid.get_hired()) != 10 or int(dry_paid.get_lofted()) != 10 or int(dry_paid.get_gated()) != 10 or int(dry_paid.get_loft_left()) != 0 or int(dry_paid.get_paid()) != 8 or int(dry_paid.get_gate_left()) != 2 or int(dry_paid.get_yard_left()) != 0:
		_fail(errors, "dry wage changed the short crew (wet %d stored %d carted %d shipped %d coins %d hired %d lofted %d gated %d loft %d paid %d unpaid %d yard %d)" % [
			dry_paid.get_wet_haul(), dry_paid.get_stored_salt(), dry_paid.get_carted(), dry_paid.get_shipped(), dry_paid.get_coins(), dry_paid.get_hired(), dry_paid.get_lofted(), dry_paid.get_gated(), dry_paid.get_loft_left(), dry_paid.get_paid(), dry_paid.get_gate_left(), dry_paid.get_yard_left(),
		])
	if int(dry_paid.get_paid()) * int(Sim.WAGE_COST) + int(dry_paid.get_yard_left()) != 32:
		_fail(errors, "dry wage did not take 4 coins a hire (paid %d left %d)" % [dry_paid.get_paid(), dry_paid.get_yard_left()])
	var dry_wage_cell = plans["dry_paid"]["wage"][0]
	var dry_gate_cell = plans["dry_paid"]["gate"][0]
	var dry_yard_cell = plans["dry_paid"]["yard"][0]
	var dry_wage_salt: Dictionary = dry_paid.get_cell_salt(int(dry_wage_cell[0]), int(dry_wage_cell[1]))
	var dry_gate_salt: Dictionary = dry_paid.get_cell_salt(int(dry_gate_cell[0]), int(dry_gate_cell[1]))
	var dry_yard_salt: Dictionary = dry_paid.get_cell_salt(int(dry_yard_cell[0]), int(dry_yard_cell[1]))
	if int(dry_wage_salt.get("wage", 0)) != 8 or int(dry_gate_salt.get("gate", 0)) != 2 or int(dry_yard_salt.get("yard", 0)) != 0:
		_fail(errors, "dry wage cell holds %s, gate holds %s, yard holds %s" % [dry_wage_salt.get("wage", 0), dry_gate_salt.get("gate", 0), dry_yard_salt.get("yard", 0)])
	if not String(dry_paid.get_summary()).contains("Paid 8") or not String(dry_paid.get_summary()).contains("Left 2 unpaid") or not String(dry_paid.get_summary()).contains("Left 0 in the yard"):
		_fail(errors, "dry wage summary does not name the shortfall: %s" % dry_paid.get_summary())
	_assert_pop(paid, errors, "paid plan")
	_assert_pop(paid_again, errors, "paid plan again")
	_assert_pop(late, errors, "late_paid")
	_assert_pop(dry_paid, errors, "dry_paid")
	_assert_pop(ignored, errors, "no_wage")
	# Coins left in the yard cannot buy another hire. Later work does nothing,
	# and the 19 hires still in the loft stay there.
	var shore = _prepare_plan(plans, "paid", errors)
	if shore == null:
		return
	var shore_guard := 0
	var shore_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + 2
	while int(shore.get_beat()) != Sim.WAGING and not shore.is_over() and shore_guard < shore_limit:
		shore.tick()
		shore_guard += 1
	if int(shore.get_beat()) != Sim.WAGING or shore.is_over():
		_fail(errors, "the gate beat did not open a wage beat for the pay check")
		return
	var saw_paid := false
	var pay_guard := 0
	while not shore.is_over() and pay_guard < int(Sim.WAGE_TICK) + 2:
		shore.tick()
		pay_guard += 1
		if int(shore.get_paid()) == 10 and int(shore.get_gate_left()) == 0 and int(shore.get_loft_left()) == 19 and int(shore.get_yard_left()) == 57 and int(shore.get_ticks_until_rain()) > 0:
			saw_paid = true
			var ticks_left := int(shore.get_ticks_until_rain())
			shore.tick()
			if int(shore.get_paid()) != 10 or int(shore.get_gate_left()) != 0 or int(shore.get_loft_left()) != 19 or int(shore.get_yard_left()) != 57:
				_fail(errors, "the wage kept paying after the crew who passed was paid (paid %d unpaid %d loft %d yard %d)" % [shore.get_paid(), shore.get_gate_left(), shore.get_loft_left(), shore.get_yard_left()])
			elif not shore.is_over() and int(shore.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the wage beat did not spend a tick after the last payment")
			break
	if not saw_paid:
		_fail(errors, "the wage did not pay 10 and stop while ticks remained (paid %d unpaid %d loft %d yard %d ticks %d)" % [
			shore.get_paid(), shore.get_gate_left(), shore.get_loft_left(), shore.get_yard_left(), shore.get_ticks_until_rain(),
		])
	# Dry pans hold 32 coins, which pays 8 hires and leaves 2 unpaid. The
	# leftover is under 4, so it stays and later work does nothing.
	var short = _prepare_plan(plans, "dry_paid", errors)
	if short == null:
		return
	var short_guard := 0
	while int(short.get_beat()) != Sim.WAGING and not short.is_over() and short_guard < shore_limit:
		short.tick()
		short_guard += 1
	if int(short.get_beat()) != Sim.WAGING or short.is_over():
		_fail(errors, "the gate beat did not open a wage beat for the shortfall")
		return
	var saw_short := false
	var short_steps := 0
	while not short.is_over() and short_steps < int(Sim.WAGE_TICK) + 2:
		short.tick()
		short_steps += 1
		if int(short.get_paid()) == 8 and int(short.get_gate_left()) == 2 and int(short.get_yard_left()) == 0 and int(short.get_yard_left()) < int(Sim.WAGE_COST) and int(short.get_ticks_until_rain()) > 0:
			saw_short = true
			var short_ticks := int(short.get_ticks_until_rain())
			short.tick()
			if int(short.get_paid()) != 8 or int(short.get_gate_left()) != 2 or int(short.get_yard_left()) != 0:
				_fail(errors, "the wage spent a short yard (paid %d unpaid %d yard %d)" % [short.get_paid(), short.get_gate_left(), short.get_yard_left()])
			elif not short.is_over() and int(short.get_ticks_until_rain()) >= short_ticks:
				_fail(errors, "the wage beat did not spend a tick after the shortfall")
			break
	if not saw_short:
		_fail(errors, "dry wage did not stop under 4 coins (paid %d unpaid %d yard %d ticks %d)" % [
			short.get_paid(), short.get_gate_left(), short.get_yard_left(), short.get_ticks_until_rain(),
		])
	print("paid %d left yard %d; dry paid %d left unpaid %d yard %d; no wage left unpaid %d yard %d" % [
		paid.get_paid(), paid.get_yard_left(), dry_paid.get_paid(), dry_paid.get_gate_left(), dry_paid.get_yard_left(), ignored.get_gate_left(), ignored.get_yard_left(),
	])


func _test_relief(errors: Array) -> void:
	if int(Sim.RELIEF_TICK) != 100 or int(Sim.RELIEF_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "relief beat length %s is not 100 ticks (10 seconds)" % Sim.RELIEF_TICK)
	if int(Sim.RELIEF_CAP) != 6:
		_fail(errors, "relief cap is %s, expected 6" % Sim.RELIEF_CAP)
	var fresh = Sim.new()
	if fresh.paint_cell(14, -4, Sim.RELIEF) == false or int(fresh.get_paint(14, -4)) != Sim.RELIEF:
		_fail(errors, "the cell north of the wage rejected the relief mark")
	if fresh.paint_cell(14, -8, Sim.RELIEF):
		_fail(errors, "the row north of the bell accepted a mark")
	if fresh.paint_cell(Sim.COAST_X, -4, Sim.RELIEF):
		_fail(errors, "the brine accepted a relief")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.RELIEF):
		_fail(errors, "the anthill accepted a relief")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var won = _run_plan(plans, "winning", errors)
	var dry = _run_plan(plans, "dry_pans", errors)
	var parked = _run_plan(plans, "carted", errors)
	var loaded = _run_plan(plans, "shipped", errors)
	var sold = _run_plan(plans, "sold", errors)
	var hired = _run_plan(plans, "hired", errors)
	var lofted = _run_plan(plans, "lofted", errors)
	var passed = _run_plan(plans, "gated", errors)
	var paid = _run_plan(plans, "paid", errors)
	var dry_paid = _run_plan(plans, "dry_paid", errors)
	var ignored = _run_plan(plans, "no_relief", errors)
	var posted = _run_plan(plans, "posted", errors)
	var posted_again = _run_plan(plans, "posted", errors)
	var late = _run_plan(plans, "late_posted", errors)
	var dry_posted = _run_plan(plans, "dry_posted", errors)
	if won == null or dry == null or parked == null or loaded == null or sold == null or hired == null or lofted == null or passed == null or paid == null or dry_paid == null or ignored == null or posted == null or posted_again == null or late == null or dry_posted == null:
		return
	# Earlier plans keep the numbers they had before the relief existed.
	# A plan that does not paint the relief also posts nobody.
	if int(won.get_wet_haul()) != 2997 or int(won.get_stored_salt()) != 2997 or int(won.get_carted()) != 0 or int(won.get_shipped()) != 0 or int(won.get_coins()) != 0 or int(won.get_hired()) != 0 or int(won.get_posted()) != 0:
		_fail(errors, "winning shore changed (wet %d stored %d carted %d shipped %d coins %d hired %d posted %d)" % [
			won.get_wet_haul(), won.get_stored_salt(), won.get_carted(), won.get_shipped(), won.get_coins(), won.get_hired(), won.get_posted(),
		])
	if int(dry.get_wet_haul()) != 0 or int(dry.get_stored_salt()) != 1032 or int(dry.get_carted()) != 0 or int(dry.get_shipped()) != 0 or int(dry.get_coins()) != 0 or int(dry.get_hired()) != 0 or int(dry.get_posted()) != 0:
		_fail(errors, "dry_pans changed (wet %d stored %d carted %d shipped %d coins %d hired %d posted %d)" % [
			dry.get_wet_haul(), dry.get_stored_salt(), dry.get_carted(), dry.get_shipped(), dry.get_coins(), dry.get_hired(), dry.get_posted(),
		])
	if int(parked.get_wet_haul()) != 2997 or int(parked.get_stored_salt()) != 2997 or int(parked.get_carted()) != 2997 or int(parked.get_shipped()) != 0 or int(parked.get_coins()) != 0 or int(parked.get_posted()) != 0:
		_fail(errors, "carted plan changed (wet %d stored %d carted %d shipped %d coins %d posted %d)" % [
			parked.get_wet_haul(), parked.get_stored_salt(), parked.get_carted(), parked.get_shipped(), parked.get_coins(), parked.get_posted(),
		])
	if int(loaded.get_wet_haul()) != 2997 or int(loaded.get_stored_salt()) != 2997 or int(loaded.get_carted()) != 2997 or int(loaded.get_shipped()) != 2997 or int(loaded.get_coins()) != 0 or int(loaded.get_posted()) != 0:
		_fail(errors, "shipped plan changed (wet %d stored %d carted %d shipped %d coins %d posted %d)" % [
			loaded.get_wet_haul(), loaded.get_stored_salt(), loaded.get_carted(), loaded.get_shipped(), loaded.get_coins(), loaded.get_posted(),
		])
	if int(sold.get_wet_haul()) != 2997 or int(sold.get_stored_salt()) != 2997 or int(sold.get_carted()) != 2997 or int(sold.get_shipped()) != 2997 or int(sold.get_coins()) != 2997 or int(sold.get_posted()) != 0:
		_fail(errors, "sold plan changed (wet %d stored %d carted %d shipped %d coins %d posted %d)" % [
			sold.get_wet_haul(), sold.get_stored_salt(), sold.get_carted(), sold.get_shipped(), sold.get_coins(), sold.get_posted(),
		])
	if int(hired.get_hired()) != 29 or int(hired.get_yard_left()) != 97 or int(hired.get_coins()) != 2997 or int(hired.get_lofted()) != 0 or int(hired.get_posted()) != 0:
		_fail(errors, "hired plan changed (coins %d hired %d left %d lofted %d posted %d)" % [
			hired.get_coins(), hired.get_hired(), hired.get_yard_left(), hired.get_lofted(), hired.get_posted(),
		])
	if int(lofted.get_lofted()) != 29 or int(lofted.get_hired()) != 29 or int(lofted.get_yard_left()) != 97 or int(lofted.get_posted()) != 0 or int(lofted.get_coins()) != 2997:
		_fail(errors, "lofted plan changed (coins %d hired %d left %d lofted %d posted %d)" % [
			lofted.get_coins(), lofted.get_hired(), lofted.get_yard_left(), lofted.get_lofted(), lofted.get_posted(),
		])
	if int(passed.get_gated()) != 10 or int(passed.get_loft_left()) != 19 or int(passed.get_hired()) != 29 or int(passed.get_yard_left()) != 97 or int(passed.get_paid()) != 0 or int(passed.get_posted()) != 0 or int(passed.get_coins()) != 2997:
		_fail(errors, "gated plan changed (coins %d hired %d left %d gated %d loft %d paid %d posted %d)" % [
			passed.get_coins(), passed.get_hired(), passed.get_yard_left(), passed.get_gated(), passed.get_loft_left(), passed.get_paid(), passed.get_posted(),
		])
	if int(paid.get_paid()) != 10 or int(paid.get_gate_left()) != 0 or int(paid.get_yard_left()) != 57 or int(paid.get_loft_left()) != 19 or int(paid.get_hired()) != 29 or int(paid.get_posted()) != 0 or int(paid.get_wage_left()) != 10 or int(paid.get_coins()) != 2997 or int(paid.get_stored_salt()) != 2997 or int(paid.get_carted()) != 2997 or int(paid.get_shipped()) != 2997:
		_fail(errors, "paid plan changed (stored %d carted %d shipped %d coins %d hired %d yard %d paid %d unpaid %d loft %d posted %d wage %d)" % [
			paid.get_stored_salt(), paid.get_carted(), paid.get_shipped(), paid.get_coins(), paid.get_hired(), paid.get_yard_left(), paid.get_paid(), paid.get_gate_left(), paid.get_loft_left(), paid.get_posted(), paid.get_wage_left(),
		])
	if int(dry_paid.get_wet_haul()) != 0 or int(dry_paid.get_stored_salt()) != 1032 or int(dry_paid.get_coins()) != 1032 or int(dry_paid.get_hired()) != 10 or int(dry_paid.get_paid()) != 8 or int(dry_paid.get_gate_left()) != 2 or int(dry_paid.get_yard_left()) != 0 or int(dry_paid.get_posted()) != 0 or int(dry_paid.get_loft_left()) != 0:
		_fail(errors, "dry wage changed (wet %d stored %d coins %d hired %d paid %d unpaid %d yard %d loft %d posted %d)" % [
			dry_paid.get_wet_haul(), dry_paid.get_stored_salt(), dry_paid.get_coins(), dry_paid.get_hired(), dry_paid.get_paid(), dry_paid.get_gate_left(), dry_paid.get_yard_left(), dry_paid.get_loft_left(), dry_paid.get_posted(),
		])
	# Paid, no relief: the 10 who were paid stay unposted, and the 19 in the loft stay unpaid.
	var ignored_unpaid := int(ignored.get_hired()) - int(ignored.get_paid())
	if int(ignored.get_posted()) != 0 or int(ignored.get_wage_left()) != 10 or int(ignored.get_paid()) != 10 or ignored_unpaid != 19 or int(ignored.get_loft_left()) != 19 or int(ignored.get_gate_left()) != 0 or int(ignored.get_yard_left()) != 57 or int(ignored.get_hired()) != 29 or int(ignored.get_coins()) != 2997 or int(ignored.get_stored_salt()) != 2997 or int(ignored.get_carted()) != 2997 or int(ignored.get_shipped()) != 2997:
		_fail(errors, "no_relief posted someone (stored %d carted %d shipped %d coins %d hired %d yard %d paid %d wage %d posted %d unpaid %d loft %d gate %d)" % [
			ignored.get_stored_salt(), ignored.get_carted(), ignored.get_shipped(), ignored.get_coins(), ignored.get_hired(), ignored.get_yard_left(), ignored.get_paid(), ignored.get_wage_left(), ignored.get_posted(), ignored_unpaid, ignored.get_loft_left(), ignored.get_gate_left(),
		])
	if String(ignored.get_summary()) != String(paid.get_summary()):
		_fail(errors, "no_relief summary changed: %s" % ignored.get_summary())
	if String(ignored.get_summary()).to_lower().contains("post") or String(ignored.get_summary()).to_lower().contains("relief"):
		_fail(errors, "no_relief summary names a relief: %s" % ignored.get_summary())
	var ignored_wage = plans["no_relief"]["wage"][0]
	var ignored_salt: Dictionary = ignored.get_cell_salt(int(ignored_wage[0]), int(ignored_wage[1]))
	if int(ignored_salt.get("wage", 0)) != 10 or int(ignored_salt.get("relief", 0)) != 0:
		_fail(errors, "no_relief left %s at the wage and %s at a relief" % [ignored_salt.get("wage", 0), ignored_salt.get("relief", 0)])
	var relief_cell = plans["posted"]["relief"][0]
	var wage_cell = plans["posted"]["wage"][0]
	var gate_cell = plans["posted"]["gate"][0]
	var loft_cell = plans["posted"]["loft"][0]
	var yard_cell = plans["posted"]["yard"][0]
	if int(relief_cell[0]) != int(wage_cell[0]) or int(relief_cell[1]) != int(wage_cell[1]) - 1:
		_fail(errors, "posted plan's relief is not one cell north of the wage")
	if int(wage_cell[0]) != int(gate_cell[0]) or int(wage_cell[1]) != int(gate_cell[1]) - 1:
		_fail(errors, "posted plan's wage is not one cell north of the gate")
	if int(posted.get_wet_haul()) != 2997 or int(posted.get_stored_salt()) != 2997 or int(posted.get_carted()) != 2997 or int(posted.get_shipped()) != 2997 or int(posted.get_coins()) != 2997 or int(posted.get_hired()) != 29 or int(posted.get_yard_left()) != 57 or int(posted.get_paid()) != 10 or int(posted.get_gated()) != 10 or int(posted.get_lofted()) != 29:
		_fail(errors, "relief changed the paid shore (wet %d stored %d carted %d shipped %d coins %d hired %d yard %d paid %d gated %d lofted %d)" % [
			posted.get_wet_haul(), posted.get_stored_salt(), posted.get_carted(), posted.get_shipped(), posted.get_coins(), posted.get_hired(), posted.get_yard_left(), posted.get_paid(), posted.get_gated(), posted.get_lofted(),
		])
	var posted_unpaid := int(posted.get_hired()) - int(posted.get_paid())
	if int(posted.get_posted()) != 6 or int(posted.get_wage_left()) != 4 or posted_unpaid != 19 or int(posted.get_loft_left()) != 19 or int(posted.get_gate_left()) != 0:
		_fail(errors, "posted %d, left %d paid unposted, unpaid %d, loft %d, gate %d; expected 6, 4, 19, 19, 0" % [
			posted.get_posted(), posted.get_wage_left(), posted_unpaid, posted.get_loft_left(), posted.get_gate_left(),
		])
	if int(posted.get_posted()) > int(Sim.RELIEF_CAP):
		_fail(errors, "relief posted %d, over the cap of %d" % [posted.get_posted(), Sim.RELIEF_CAP])
	var relief_salt: Dictionary = posted.get_cell_salt(int(relief_cell[0]), int(relief_cell[1]))
	var wage_salt: Dictionary = posted.get_cell_salt(int(wage_cell[0]), int(wage_cell[1]))
	var gate_salt: Dictionary = posted.get_cell_salt(int(gate_cell[0]), int(gate_cell[1]))
	var loft_salt: Dictionary = posted.get_cell_salt(int(loft_cell[0]), int(loft_cell[1]))
	var yard_salt: Dictionary = posted.get_cell_salt(int(yard_cell[0]), int(yard_cell[1]))
	if int(relief_salt.get("relief", 0)) != 6 or int(wage_salt.get("wage", 0)) != 4 or int(gate_salt.get("gate", 0)) != 0 or int(loft_salt.get("loft", 0)) != 19 or int(yard_salt.get("yard", 0)) != 57:
		_fail(errors, "relief cell holds %s, wage holds %s, gate holds %s, loft holds %s, yard holds %s" % [
			relief_salt.get("relief", 0), wage_salt.get("wage", 0), gate_salt.get("gate", 0), loft_salt.get("loft", 0), yard_salt.get("yard", 0),
		])
	var posted_summary := String(posted.get_summary())
	if not posted_summary.contains("Posted 6") or not posted_summary.contains("Left 4 at the wage") or not posted_summary.contains("Paid 10") or not posted_summary.contains("Left 19 in the loft") or not posted_summary.contains("Left 57"):
		_fail(errors, "posted summary does not name the relief: %s" % posted_summary)
	if not posted_summary.contains("Coins 2997") or not posted_summary.contains("Hired 29"):
		_fail(errors, "posted summary dropped the earlier totals: %s" % posted_summary)
	if int(posted_again.get_posted()) != int(posted.get_posted()) or int(posted_again.get_wage_left()) != int(posted.get_wage_left()) or int(posted_again.get_yard_left()) != int(posted.get_yard_left()):
		_fail(errors, "repeated relief paint posted %d and left wage %d, then posted %d and left wage %d" % [
			posted.get_posted(), posted.get_wage_left(), posted_again.get_posted(), posted_again.get_wage_left(),
		])
	if int(late.get_posted()) != 6 or int(late.get_wage_left()) != 4 or int(late.get_paid()) != 10 or int(late.get_loft_left()) != 19 or int(late.get_yard_left()) != 57 or int(late.get_hired()) != 29 or int(late.get_coins()) != int(posted.get_coins()) or int(late.get_stored_salt()) != int(posted.get_stored_salt()):
		_fail(errors, "painting the relief at the relief beat (posted %d wage %d paid %d loft %d yard %d hired %d coins %d stored %d) did not match painting it early (posted %d wage %d paid %d loft %d yard %d hired %d coins %d stored %d)" % [
			late.get_posted(), late.get_wage_left(), late.get_paid(), late.get_loft_left(), late.get_yard_left(), late.get_hired(), late.get_coins(), late.get_stored_salt(), posted.get_posted(), posted.get_wage_left(), posted.get_paid(), posted.get_loft_left(), posted.get_yard_left(), posted.get_hired(), posted.get_coins(), posted.get_stored_salt(),
		])
	var dry_unpaid := int(dry_posted.get_hired()) - int(dry_posted.get_paid())
	if int(dry_posted.get_wet_haul()) != 0 or int(dry_posted.get_stored_salt()) != 1032 or int(dry_posted.get_carted()) != 1032 or int(dry_posted.get_shipped()) != 1032 or int(dry_posted.get_coins()) != 1032 or int(dry_posted.get_hired()) != 10 or int(dry_posted.get_paid()) != 8 or int(dry_posted.get_posted()) != 6 or int(dry_posted.get_wage_left()) != 2 or dry_unpaid != 2 or int(dry_posted.get_gate_left()) != 2 or int(dry_posted.get_loft_left()) != 0 or int(dry_posted.get_yard_left()) != 0:
		_fail(errors, "dry relief changed the short crew (wet %d stored %d carted %d shipped %d coins %d hired %d paid %d posted %d wage %d unpaid %d gate %d loft %d yard %d)" % [
			dry_posted.get_wet_haul(), dry_posted.get_stored_salt(), dry_posted.get_carted(), dry_posted.get_shipped(), dry_posted.get_coins(), dry_posted.get_hired(), dry_posted.get_paid(), dry_posted.get_posted(), dry_posted.get_wage_left(), dry_unpaid, dry_posted.get_gate_left(), dry_posted.get_loft_left(), dry_posted.get_yard_left(),
		])
	var dry_relief_cell = plans["dry_posted"]["relief"][0]
	var dry_wage_cell = plans["dry_posted"]["wage"][0]
	var dry_gate_cell = plans["dry_posted"]["gate"][0]
	var dry_relief_salt: Dictionary = dry_posted.get_cell_salt(int(dry_relief_cell[0]), int(dry_relief_cell[1]))
	var dry_wage_salt: Dictionary = dry_posted.get_cell_salt(int(dry_wage_cell[0]), int(dry_wage_cell[1]))
	var dry_gate_salt: Dictionary = dry_posted.get_cell_salt(int(dry_gate_cell[0]), int(dry_gate_cell[1]))
	if int(dry_relief_salt.get("relief", 0)) != 6 or int(dry_wage_salt.get("wage", 0)) != 2 or int(dry_gate_salt.get("gate", 0)) != 2:
		_fail(errors, "dry relief cell holds %s, wage holds %s, gate holds %s" % [
			dry_relief_salt.get("relief", 0), dry_wage_salt.get("wage", 0), dry_gate_salt.get("gate", 0),
		])
	if not String(dry_posted.get_summary()).contains("Posted 6") or not String(dry_posted.get_summary()).contains("Left 2 at the wage") or not String(dry_posted.get_summary()).contains("Paid 8") or not String(dry_posted.get_summary()).contains("Left 2 unpaid") or not String(dry_posted.get_summary()).contains("Left 0 in the yard"):
		_fail(errors, "dry relief summary does not name the cap: %s" % dry_posted.get_summary())
	_assert_pop(posted, errors, "posted plan")
	_assert_pop(posted_again, errors, "posted plan again")
	_assert_pop(late, errors, "late_posted")
	_assert_pop(dry_posted, errors, "dry_posted")
	_assert_pop(ignored, errors, "no_relief")
	# The cap stops the relief while ticks remain. Paid hires past 6 stay on
	# the wage. Hires still in the loft are not posted.
	var shore = _prepare_plan(plans, "posted", errors)
	if shore == null:
		return
	var shore_guard := 0
	var shore_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + 2
	while int(shore.get_beat()) != Sim.RELIEVING and not shore.is_over() and shore_guard < shore_limit:
		shore.tick()
		shore_guard += 1
	if int(shore.get_beat()) != Sim.RELIEVING or shore.is_over():
		_fail(errors, "the wage beat did not open a relief beat for the cap check")
		return
	if int(shore.get_ticks_until_rain()) != int(Sim.RELIEF_TICK):
		_fail(errors, "relief countdown started at %d, expected %d" % [shore.get_ticks_until_rain(), Sim.RELIEF_TICK])
	var saw_cap := false
	var post_guard := 0
	while not shore.is_over() and post_guard < int(Sim.RELIEF_TICK) + 2:
		shore.tick()
		post_guard += 1
		if int(shore.get_posted()) == int(Sim.RELIEF_CAP) and int(shore.get_wage_left()) == 4 and int(shore.get_paid()) == 10 and int(shore.get_loft_left()) == 19 and int(shore.get_gate_left()) == 0 and int(shore.get_yard_left()) == 57 and int(shore.get_ticks_until_rain()) > 0:
			saw_cap = true
			var ticks_left := int(shore.get_ticks_until_rain())
			shore.tick()
			if int(shore.get_posted()) != int(Sim.RELIEF_CAP) or int(shore.get_wage_left()) != 4 or int(shore.get_loft_left()) != 19 or int(shore.get_gate_left()) != 0 or int(shore.get_yard_left()) != 57 or int(shore.get_paid()) != 10:
				_fail(errors, "the relief kept posting after the cap (posted %d wage %d loft %d gate %d yard %d paid %d)" % [
					shore.get_posted(), shore.get_wage_left(), shore.get_loft_left(), shore.get_gate_left(), shore.get_yard_left(), shore.get_paid(),
				])
			elif not shore.is_over() and int(shore.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the relief beat did not spend a tick after the cap")
			break
	if not saw_cap:
		_fail(errors, "the relief did not stop at %d while ticks remained (posted %d wage %d loft %d gate %d yard %d ticks %d)" % [
			Sim.RELIEF_CAP, shore.get_posted(), shore.get_wage_left(), shore.get_loft_left(), shore.get_gate_left(), shore.get_yard_left(), shore.get_ticks_until_rain(),
		])
	# Dry pans pay 8 and the cap still posts only 6. The 2 who passed and were
	# not paid stay on the gate, and the yard stays empty.
	var short = _prepare_plan(plans, "dry_posted", errors)
	if short == null:
		return
	var short_guard := 0
	while int(short.get_beat()) != Sim.RELIEVING and not short.is_over() and short_guard < shore_limit:
		short.tick()
		short_guard += 1
	if int(short.get_beat()) != Sim.RELIEVING or short.is_over():
		_fail(errors, "the wage beat did not open a relief beat for the dry cap")
		return
	var saw_short := false
	var short_steps := 0
	while not short.is_over() and short_steps < int(Sim.RELIEF_TICK) + 2:
		short.tick()
		short_steps += 1
		if int(short.get_posted()) == int(Sim.RELIEF_CAP) and int(short.get_wage_left()) == 2 and int(short.get_gate_left()) == 2 and int(short.get_paid()) == 8 and int(short.get_yard_left()) == 0 and int(short.get_loft_left()) == 0 and int(short.get_ticks_until_rain()) > 0:
			saw_short = true
			var short_ticks := int(short.get_ticks_until_rain())
			short.tick()
			if int(short.get_posted()) != 6 or int(short.get_wage_left()) != 2 or int(short.get_gate_left()) != 2 or int(short.get_yard_left()) != 0 or int(short.get_paid()) != 8:
				_fail(errors, "the relief posted an unpaid hire or passed the cap (posted %d wage %d gate %d yard %d paid %d)" % [
					short.get_posted(), short.get_wage_left(), short.get_gate_left(), short.get_yard_left(), short.get_paid(),
				])
			elif not short.is_over() and int(short.get_ticks_until_rain()) >= short_ticks:
				_fail(errors, "the relief beat did not spend a tick after the dry cap")
			break
	if not saw_short:
		_fail(errors, "dry relief did not stop at 6 with unpaid hires left (posted %d wage %d gate %d yard %d paid %d ticks %d)" % [
			short.get_posted(), short.get_wage_left(), short.get_gate_left(), short.get_yard_left(), short.get_paid(), short.get_ticks_until_rain(),
		])
	print("posted %d left wage %d unpaid %d; dry posted %d left wage %d unpaid %d; no relief posted %d left wage %d" % [
		posted.get_posted(), posted.get_wage_left(), posted_unpaid, dry_posted.get_posted(), dry_posted.get_wage_left(), dry_unpaid, ignored.get_posted(), ignored.get_wage_left(),
	])


func _test_watch(errors: Array) -> void:
	if int(Sim.WATCH_TICK) != 100 or int(Sim.WATCH_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "watch beat length %s is not 100 ticks (10 seconds)" % Sim.WATCH_TICK)
	if int(Sim.WATCH_CAP) != 4:
		_fail(errors, "watch cap is %s, expected 4" % Sim.WATCH_CAP)
	var fresh = Sim.new()
	if fresh.paint_cell(14, -5, Sim.WATCH) == false or int(fresh.get_paint(14, -5)) != Sim.WATCH:
		_fail(errors, "the cell north of the relief rejected the watch mark")
	if fresh.paint_cell(14, -8, Sim.WATCH):
		_fail(errors, "the row north of the bell accepted a mark")
	if fresh.paint_cell(Sim.COAST_X, -5, Sim.WATCH):
		_fail(errors, "the brine accepted a watch")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.WATCH):
		_fail(errors, "the anthill accepted a watch")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var won = _run_plan(plans, "winning", errors)
	var dry = _run_plan(plans, "dry_pans", errors)
	var parked = _run_plan(plans, "carted", errors)
	var loaded = _run_plan(plans, "shipped", errors)
	var sold = _run_plan(plans, "sold", errors)
	var hired = _run_plan(plans, "hired", errors)
	var lofted = _run_plan(plans, "lofted", errors)
	var passed = _run_plan(plans, "gated", errors)
	var paid = _run_plan(plans, "paid", errors)
	var dry_paid = _run_plan(plans, "dry_paid", errors)
	var posted = _run_plan(plans, "posted", errors)
	var dry_posted = _run_plan(plans, "dry_posted", errors)
	var ignored = _run_plan(plans, "no_watch", errors)
	var bare = _run_plan(plans, "watch_only", errors)
	var stood = _run_plan(plans, "stood", errors)
	var stood_again = _run_plan(plans, "stood", errors)
	var late = _run_plan(plans, "late_stood", errors)
	var dry_stood = _run_plan(plans, "dry_stood", errors)
	if won == null or dry == null or parked == null or loaded == null or sold == null or hired == null or lofted == null or passed == null or paid == null or dry_paid == null or posted == null or dry_posted == null or ignored == null or bare == null or stood == null or stood_again == null or late == null or dry_stood == null:
		return
	# Earlier plans keep the numbers they had before the watch existed.
	# A plan that does not paint the watch also stands nobody.
	if int(won.get_wet_haul()) != 2997 or int(won.get_stored_salt()) != 2997 or int(won.get_carted()) != 0 or int(won.get_shipped()) != 0 or int(won.get_coins()) != 0 or int(won.get_hired()) != 0 or int(won.get_posted()) != 0 or int(won.get_stood()) != 0:
		_fail(errors, "winning shore changed (wet %d stored %d carted %d shipped %d coins %d hired %d posted %d stood %d)" % [
			won.get_wet_haul(), won.get_stored_salt(), won.get_carted(), won.get_shipped(), won.get_coins(), won.get_hired(), won.get_posted(), won.get_stood(),
		])
	if int(dry.get_wet_haul()) != 0 or int(dry.get_stored_salt()) != 1032 or int(dry.get_carted()) != 0 or int(dry.get_shipped()) != 0 or int(dry.get_coins()) != 0 or int(dry.get_hired()) != 0 or int(dry.get_posted()) != 0 or int(dry.get_stood()) != 0:
		_fail(errors, "dry_pans changed (wet %d stored %d carted %d shipped %d coins %d hired %d posted %d stood %d)" % [
			dry.get_wet_haul(), dry.get_stored_salt(), dry.get_carted(), dry.get_shipped(), dry.get_coins(), dry.get_hired(), dry.get_posted(), dry.get_stood(),
		])
	if int(parked.get_wet_haul()) != 2997 or int(parked.get_stored_salt()) != 2997 or int(parked.get_carted()) != 2997 or int(parked.get_shipped()) != 0 or int(parked.get_coins()) != 0 or int(parked.get_posted()) != 0 or int(parked.get_stood()) != 0:
		_fail(errors, "carted plan changed (wet %d stored %d carted %d shipped %d coins %d posted %d stood %d)" % [
			parked.get_wet_haul(), parked.get_stored_salt(), parked.get_carted(), parked.get_shipped(), parked.get_coins(), parked.get_posted(), parked.get_stood(),
		])
	if int(loaded.get_wet_haul()) != 2997 or int(loaded.get_stored_salt()) != 2997 or int(loaded.get_carted()) != 2997 or int(loaded.get_shipped()) != 2997 or int(loaded.get_coins()) != 0 or int(loaded.get_posted()) != 0 or int(loaded.get_stood()) != 0:
		_fail(errors, "shipped plan changed (wet %d stored %d carted %d shipped %d coins %d posted %d stood %d)" % [
			loaded.get_wet_haul(), loaded.get_stored_salt(), loaded.get_carted(), loaded.get_shipped(), loaded.get_coins(), loaded.get_posted(), loaded.get_stood(),
		])
	if int(sold.get_wet_haul()) != 2997 or int(sold.get_stored_salt()) != 2997 or int(sold.get_carted()) != 2997 or int(sold.get_shipped()) != 2997 or int(sold.get_coins()) != 2997 or int(sold.get_posted()) != 0 or int(sold.get_stood()) != 0:
		_fail(errors, "sold plan changed (wet %d stored %d carted %d shipped %d coins %d posted %d stood %d)" % [
			sold.get_wet_haul(), sold.get_stored_salt(), sold.get_carted(), sold.get_shipped(), sold.get_coins(), sold.get_posted(), sold.get_stood(),
		])
	if int(hired.get_hired()) != 29 or int(hired.get_yard_left()) != 97 or int(hired.get_coins()) != 2997 or int(hired.get_stood()) != 0 or int(hired.get_posted()) != 0:
		_fail(errors, "hired plan changed (coins %d hired %d left %d posted %d stood %d)" % [
			hired.get_coins(), hired.get_hired(), hired.get_yard_left(), hired.get_posted(), hired.get_stood(),
		])
	if int(lofted.get_lofted()) != 29 or int(lofted.get_hired()) != 29 or int(lofted.get_yard_left()) != 97 or int(lofted.get_stood()) != 0 or int(lofted.get_coins()) != 2997:
		_fail(errors, "lofted plan changed (coins %d hired %d left %d lofted %d stood %d)" % [
			lofted.get_coins(), lofted.get_hired(), lofted.get_yard_left(), lofted.get_lofted(), lofted.get_stood(),
		])
	if int(passed.get_gated()) != 10 or int(passed.get_loft_left()) != 19 or int(passed.get_hired()) != 29 or int(passed.get_yard_left()) != 97 or int(passed.get_paid()) != 0 or int(passed.get_posted()) != 0 or int(passed.get_stood()) != 0 or int(passed.get_coins()) != 2997:
		_fail(errors, "gated plan changed (coins %d hired %d left %d gated %d loft %d paid %d posted %d stood %d)" % [
			passed.get_coins(), passed.get_hired(), passed.get_yard_left(), passed.get_gated(), passed.get_loft_left(), passed.get_paid(), passed.get_posted(), passed.get_stood(),
		])
	if int(paid.get_paid()) != 10 or int(paid.get_gate_left()) != 0 or int(paid.get_yard_left()) != 57 or int(paid.get_loft_left()) != 19 or int(paid.get_hired()) != 29 or int(paid.get_posted()) != 0 or int(paid.get_stood()) != 0 or int(paid.get_coins()) != 2997 or int(paid.get_stored_salt()) != 2997:
		_fail(errors, "paid plan changed (stored %d coins %d hired %d yard %d paid %d loft %d posted %d stood %d)" % [
			paid.get_stored_salt(), paid.get_coins(), paid.get_hired(), paid.get_yard_left(), paid.get_paid(), paid.get_loft_left(), paid.get_posted(), paid.get_stood(),
		])
	if int(dry_paid.get_wet_haul()) != 0 or int(dry_paid.get_stored_salt()) != 1032 or int(dry_paid.get_coins()) != 1032 or int(dry_paid.get_hired()) != 10 or int(dry_paid.get_paid()) != 8 or int(dry_paid.get_gate_left()) != 2 or int(dry_paid.get_yard_left()) != 0 or int(dry_paid.get_posted()) != 0 or int(dry_paid.get_stood()) != 0:
		_fail(errors, "dry wage changed (wet %d stored %d coins %d hired %d paid %d unpaid %d yard %d posted %d stood %d)" % [
			dry_paid.get_wet_haul(), dry_paid.get_stored_salt(), dry_paid.get_coins(), dry_paid.get_hired(), dry_paid.get_paid(), dry_paid.get_gate_left(), dry_paid.get_yard_left(), dry_paid.get_posted(), dry_paid.get_stood(),
		])
	if int(posted.get_posted()) != 6 or int(posted.get_wage_left()) != 4 or int(posted.get_paid()) != 10 or int(posted.get_loft_left()) != 19 or int(posted.get_yard_left()) != 57 or int(posted.get_hired()) != 29 or int(posted.get_coins()) != 2997 or int(posted.get_stored_salt()) != 2997 or int(posted.get_carted()) != 2997 or int(posted.get_shipped()) != 2997 or int(posted.get_stood()) != 0 or int(posted.get_relief_left()) != 6:
		_fail(errors, "posted plan changed (stored %d carted %d shipped %d coins %d hired %d yard %d paid %d posted %d wage %d loft %d stood %d relief %d)" % [
			posted.get_stored_salt(), posted.get_carted(), posted.get_shipped(), posted.get_coins(), posted.get_hired(), posted.get_yard_left(), posted.get_paid(), posted.get_posted(), posted.get_wage_left(), posted.get_loft_left(), posted.get_stood(), posted.get_relief_left(),
		])
	if int(dry_posted.get_wet_haul()) != 0 or int(dry_posted.get_posted()) != 6 or int(dry_posted.get_wage_left()) != 2 or int(dry_posted.get_gate_left()) != 2 or int(dry_posted.get_yard_left()) != 0 or int(dry_posted.get_paid()) != 8 or int(dry_posted.get_stood()) != 0 or int(dry_posted.get_relief_left()) != 6:
		_fail(errors, "dry relief changed (wet %d paid %d posted %d wage %d gate %d yard %d stood %d relief %d)" % [
			dry_posted.get_wet_haul(), dry_posted.get_paid(), dry_posted.get_posted(), dry_posted.get_wage_left(), dry_posted.get_gate_left(), dry_posted.get_yard_left(), dry_posted.get_stood(), dry_posted.get_relief_left(),
		])
	# Posted, no watch: the 6 who were posted stay on the relief. The 4 paid
	# but not posted stay on the wage. The 19 in the loft stay unpaid.
	var ignored_unpaid := int(ignored.get_hired()) - int(ignored.get_paid())
	if int(ignored.get_stood()) != 0 or int(ignored.get_relief_left()) != 6 or int(ignored.get_posted()) != 6 or int(ignored.get_wage_left()) != 4 or ignored_unpaid != 19 or int(ignored.get_loft_left()) != 19 or int(ignored.get_gate_left()) != 0 or int(ignored.get_yard_left()) != 57 or int(ignored.get_hired()) != 29 or int(ignored.get_paid()) != 10 or int(ignored.get_coins()) != 2997 or int(ignored.get_stored_salt()) != 2997 or int(ignored.get_carted()) != 2997 or int(ignored.get_shipped()) != 2997:
		_fail(errors, "no_watch stood someone (stored %d carted %d shipped %d coins %d hired %d yard %d paid %d posted %d relief %d stood %d unpaid %d loft %d wage %d)" % [
			ignored.get_stored_salt(), ignored.get_carted(), ignored.get_shipped(), ignored.get_coins(), ignored.get_hired(), ignored.get_yard_left(), ignored.get_paid(), ignored.get_posted(), ignored.get_relief_left(), ignored.get_stood(), ignored_unpaid, ignored.get_loft_left(), ignored.get_wage_left(),
		])
	if String(ignored.get_summary()) != String(posted.get_summary()):
		_fail(errors, "no_watch summary changed: %s" % ignored.get_summary())
	if String(ignored.get_summary()).to_lower().contains("stood") or String(ignored.get_summary()).to_lower().contains("watch"):
		_fail(errors, "no_watch summary names a watch: %s" % ignored.get_summary())
	var ignored_relief = plans["no_watch"]["relief"][0]
	var ignored_salt: Dictionary = ignored.get_cell_salt(int(ignored_relief[0]), int(ignored_relief[1]))
	if int(ignored_salt.get("relief", 0)) != 6 or int(ignored_salt.get("watch", 0)) != 0:
		_fail(errors, "no_watch left %s at the relief and %s at a watch" % [ignored_salt.get("relief", 0), ignored_salt.get("watch", 0)])
	# A watch with nobody posted stands nobody. Paid hires stay on the wage.
	var bare_unpaid := int(bare.get_hired()) - int(bare.get_paid())
	if int(bare.get_stood()) != 0 or int(bare.get_posted()) != 0 or int(bare.get_relief_left()) != 0 or int(bare.get_paid()) != 10 or int(bare.get_wage_left()) != 10 or bare_unpaid != 19 or int(bare.get_loft_left()) != 19 or int(bare.get_gate_left()) != 0 or int(bare.get_yard_left()) != 57 or int(bare.get_hired()) != 29 or int(bare.get_coins()) != 2997 or int(bare.get_stored_salt()) != 2997 or int(bare.get_carted()) != 2997 or int(bare.get_shipped()) != 2997:
		_fail(errors, "watch without a relief stood someone (stored %d carted %d shipped %d coins %d hired %d yard %d paid %d wage %d posted %d stood %d unpaid %d loft %d)" % [
			bare.get_stored_salt(), bare.get_carted(), bare.get_shipped(), bare.get_coins(), bare.get_hired(), bare.get_yard_left(), bare.get_paid(), bare.get_wage_left(), bare.get_posted(), bare.get_stood(), bare_unpaid, bare.get_loft_left(),
		])
	if String(bare.get_summary()) != String(paid.get_summary()):
		_fail(errors, "watch without a relief changed the summary: %s" % bare.get_summary())
	if String(bare.get_summary()).to_lower().contains("stood") or String(bare.get_summary()).to_lower().contains("watch") or String(bare.get_summary()).to_lower().contains("relief"):
		_fail(errors, "watch without a relief names a watch: %s" % bare.get_summary())
	var bare_watch = plans["watch_only"]["watch"][0]
	var bare_wage = plans["watch_only"]["wage"][0]
	var bare_watch_salt: Dictionary = bare.get_cell_salt(int(bare_watch[0]), int(bare_watch[1]))
	var bare_wage_salt: Dictionary = bare.get_cell_salt(int(bare_wage[0]), int(bare_wage[1]))
	if int(bare_watch_salt.get("watch", 0)) != 0 or int(bare_wage_salt.get("wage", 0)) != 10 or int(bare_watch_salt.get("relief", 0)) != 0:
		_fail(errors, "watch without a relief holds %s, wage holds %s" % [bare_watch_salt.get("watch", 0), bare_wage_salt.get("wage", 0)])
	var watch_cell = plans["stood"]["watch"][0]
	var relief_cell = plans["stood"]["relief"][0]
	var wage_cell = plans["stood"]["wage"][0]
	var gate_cell = plans["stood"]["gate"][0]
	var loft_cell = plans["stood"]["loft"][0]
	var yard_cell = plans["stood"]["yard"][0]
	if int(watch_cell[0]) != int(relief_cell[0]) or int(watch_cell[1]) != int(relief_cell[1]) - 1:
		_fail(errors, "stood plan's watch is not one cell north of the relief")
	if int(relief_cell[0]) != int(wage_cell[0]) or int(relief_cell[1]) != int(wage_cell[1]) - 1:
		_fail(errors, "stood plan's relief is not one cell north of the wage")
	if int(stood.get_wet_haul()) != 2997 or int(stood.get_stored_salt()) != 2997 or int(stood.get_carted()) != 2997 or int(stood.get_shipped()) != 2997 or int(stood.get_coins()) != 2997 or int(stood.get_hired()) != 29 or int(stood.get_yard_left()) != 57 or int(stood.get_paid()) != 10 or int(stood.get_posted()) != 6 or int(stood.get_gated()) != 10 or int(stood.get_lofted()) != 29:
		_fail(errors, "watch changed the posted shore (wet %d stored %d carted %d shipped %d coins %d hired %d yard %d paid %d posted %d gated %d lofted %d)" % [
			stood.get_wet_haul(), stood.get_stored_salt(), stood.get_carted(), stood.get_shipped(), stood.get_coins(), stood.get_hired(), stood.get_yard_left(), stood.get_paid(), stood.get_posted(), stood.get_gated(), stood.get_lofted(),
		])
	var stood_unpaid := int(stood.get_hired()) - int(stood.get_paid())
	var stood_unposted := int(stood.get_paid()) - int(stood.get_posted())
	if int(stood.get_stood()) != 4 or int(stood.get_relief_left()) != 2 or stood_unposted != 4 or stood_unpaid != 19 or int(stood.get_wage_left()) != 4 or int(stood.get_loft_left()) != 19 or int(stood.get_gate_left()) != 0 or int(stood.get_yard_left()) != 57 or int(stood.get_posted()) != 6:
		_fail(errors, "stood %d, left %d posted unstood, paid unposted %d, unpaid %d, wage %d, loft %d, gate %d, yard %d, posted %d; expected 4, 2, 4, 19, 4, 19, 0, 57, 6" % [
			stood.get_stood(), stood.get_relief_left(), stood_unposted, stood_unpaid, stood.get_wage_left(), stood.get_loft_left(), stood.get_gate_left(), stood.get_yard_left(), stood.get_posted(),
		])
	if int(stood.get_stood()) > int(Sim.WATCH_CAP):
		_fail(errors, "watch stood %d, over the cap of %d" % [stood.get_stood(), Sim.WATCH_CAP])
	var watch_salt: Dictionary = stood.get_cell_salt(int(watch_cell[0]), int(watch_cell[1]))
	var relief_salt: Dictionary = stood.get_cell_salt(int(relief_cell[0]), int(relief_cell[1]))
	var wage_salt: Dictionary = stood.get_cell_salt(int(wage_cell[0]), int(wage_cell[1]))
	var gate_salt: Dictionary = stood.get_cell_salt(int(gate_cell[0]), int(gate_cell[1]))
	var loft_salt: Dictionary = stood.get_cell_salt(int(loft_cell[0]), int(loft_cell[1]))
	var yard_salt: Dictionary = stood.get_cell_salt(int(yard_cell[0]), int(yard_cell[1]))
	if int(watch_salt.get("watch", 0)) != 4 or int(relief_salt.get("relief", 0)) != 2 or int(wage_salt.get("wage", 0)) != 4 or int(gate_salt.get("gate", 0)) != 0 or int(loft_salt.get("loft", 0)) != 19 or int(yard_salt.get("yard", 0)) != 57:
		_fail(errors, "watch cell holds %s, relief holds %s, wage holds %s, gate holds %s, loft holds %s, yard holds %s" % [
			watch_salt.get("watch", 0), relief_salt.get("relief", 0), wage_salt.get("wage", 0), gate_salt.get("gate", 0), loft_salt.get("loft", 0), yard_salt.get("yard", 0),
		])
	var stood_summary := String(stood.get_summary())
	if not stood_summary.contains("Stood 4 on the watch") or not stood_summary.contains("Left 2 at the relief") or not stood_summary.contains("Posted 6") or not stood_summary.contains("Left 4 at the wage") or not stood_summary.contains("Paid 10") or not stood_summary.contains("Left 19 in the loft") or not stood_summary.contains("Left 57"):
		_fail(errors, "stood summary does not name the watch: %s" % stood_summary)
	if not stood_summary.contains("Coins 2997") or not stood_summary.contains("Hired 29"):
		_fail(errors, "stood summary dropped the earlier totals: %s" % stood_summary)
	if int(stood_again.get_stood()) != int(stood.get_stood()) or int(stood_again.get_relief_left()) != int(stood.get_relief_left()) or int(stood_again.get_posted()) != int(stood.get_posted()) or int(stood_again.get_yard_left()) != int(stood.get_yard_left()) or int(stood_again.get_stored_salt()) != int(stood.get_stored_salt()):
		_fail(errors, "repeated watch paint stood %d and left relief %d, then stood %d and left relief %d" % [
			stood.get_stood(), stood.get_relief_left(), stood_again.get_stood(), stood_again.get_relief_left(),
		])
	if int(late.get_stood()) != 4 or int(late.get_relief_left()) != 2 or int(late.get_posted()) != 6 or int(late.get_wage_left()) != 4 or int(late.get_paid()) != 10 or int(late.get_loft_left()) != 19 or int(late.get_yard_left()) != 57 or int(late.get_hired()) != 29 or int(late.get_coins()) != int(stood.get_coins()) or int(late.get_stored_salt()) != int(stood.get_stored_salt()) or int(late.get_carted()) != int(stood.get_carted()) or int(late.get_shipped()) != int(stood.get_shipped()):
		_fail(errors, "painting the watch at the watch beat (stood %d relief %d posted %d wage %d paid %d loft %d yard %d hired %d coins %d stored %d) did not match painting it early (stood %d relief %d posted %d wage %d paid %d loft %d yard %d hired %d coins %d stored %d)" % [
			late.get_stood(), late.get_relief_left(), late.get_posted(), late.get_wage_left(), late.get_paid(), late.get_loft_left(), late.get_yard_left(), late.get_hired(), late.get_coins(), late.get_stored_salt(), stood.get_stood(), stood.get_relief_left(), stood.get_posted(), stood.get_wage_left(), stood.get_paid(), stood.get_loft_left(), stood.get_yard_left(), stood.get_hired(), stood.get_coins(), stood.get_stored_salt(),
		])
	var dry_unpaid := int(dry_stood.get_hired()) - int(dry_stood.get_paid())
	var dry_unposted := int(dry_stood.get_paid()) - int(dry_stood.get_posted())
	if int(dry_stood.get_wet_haul()) != 0 or int(dry_stood.get_stored_salt()) != 1032 or int(dry_stood.get_carted()) != 1032 or int(dry_stood.get_shipped()) != 1032 or int(dry_stood.get_coins()) != 1032 or int(dry_stood.get_hired()) != 10 or int(dry_stood.get_paid()) != 8 or int(dry_stood.get_posted()) != 6 or int(dry_stood.get_stood()) != 4 or int(dry_stood.get_relief_left()) != 2 or dry_unposted != 2 or dry_unpaid != 2 or int(dry_stood.get_wage_left()) != 2 or int(dry_stood.get_gate_left()) != 2 or int(dry_stood.get_loft_left()) != 0 or int(dry_stood.get_yard_left()) != 0:
		_fail(errors, "dry watch changed the short crew (wet %d stored %d carted %d shipped %d coins %d hired %d paid %d posted %d stood %d relief %d unposted %d unpaid %d wage %d gate %d loft %d yard %d)" % [
			dry_stood.get_wet_haul(), dry_stood.get_stored_salt(), dry_stood.get_carted(), dry_stood.get_shipped(), dry_stood.get_coins(), dry_stood.get_hired(), dry_stood.get_paid(), dry_stood.get_posted(), dry_stood.get_stood(), dry_stood.get_relief_left(), dry_unposted, dry_unpaid, dry_stood.get_wage_left(), dry_stood.get_gate_left(), dry_stood.get_loft_left(), dry_stood.get_yard_left(),
		])
	var dry_watch_cell = plans["dry_stood"]["watch"][0]
	var dry_relief_cell = plans["dry_stood"]["relief"][0]
	var dry_wage_cell = plans["dry_stood"]["wage"][0]
	var dry_gate_cell = plans["dry_stood"]["gate"][0]
	var dry_watch_salt: Dictionary = dry_stood.get_cell_salt(int(dry_watch_cell[0]), int(dry_watch_cell[1]))
	var dry_relief_salt: Dictionary = dry_stood.get_cell_salt(int(dry_relief_cell[0]), int(dry_relief_cell[1]))
	var dry_wage_salt: Dictionary = dry_stood.get_cell_salt(int(dry_wage_cell[0]), int(dry_wage_cell[1]))
	var dry_gate_salt: Dictionary = dry_stood.get_cell_salt(int(dry_gate_cell[0]), int(dry_gate_cell[1]))
	if int(dry_watch_salt.get("watch", 0)) != 4 or int(dry_relief_salt.get("relief", 0)) != 2 or int(dry_wage_salt.get("wage", 0)) != 2 or int(dry_gate_salt.get("gate", 0)) != 2:
		_fail(errors, "dry watch cell holds %s, relief holds %s, wage holds %s, gate holds %s" % [
			dry_watch_salt.get("watch", 0), dry_relief_salt.get("relief", 0), dry_wage_salt.get("wage", 0), dry_gate_salt.get("gate", 0),
		])
	if not String(dry_stood.get_summary()).contains("Stood 4 on the watch") or not String(dry_stood.get_summary()).contains("Left 2 at the relief") or not String(dry_stood.get_summary()).contains("Posted 6") or not String(dry_stood.get_summary()).contains("Left 2 at the wage") or not String(dry_stood.get_summary()).contains("Paid 8") or not String(dry_stood.get_summary()).contains("Left 2 unpaid") or not String(dry_stood.get_summary()).contains("Left 0 in the yard"):
		_fail(errors, "dry watch summary does not name the cap: %s" % dry_stood.get_summary())
	_assert_pop(stood, errors, "stood plan")
	_assert_pop(stood_again, errors, "stood plan again")
	_assert_pop(late, errors, "late_stood")
	_assert_pop(dry_stood, errors, "dry_stood")
	_assert_pop(ignored, errors, "no_watch")
	_assert_pop(bare, errors, "watch_only")
	# The cap stops the watch while ticks remain and posted hires remain.
	# Hires still in the loft, and hires who were paid but not posted, stay put.
	var shore = _prepare_plan(plans, "stood", errors)
	if shore == null:
		return
	var shore_guard := 0
	var shore_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + 2
	while int(shore.get_beat()) != Sim.WATCHING and not shore.is_over() and shore_guard < shore_limit:
		shore.tick()
		shore_guard += 1
	if int(shore.get_beat()) != Sim.WATCHING or shore.is_over():
		_fail(errors, "the relief beat did not open a watch beat for the cap check")
		return
	if int(shore.get_ticks_until_rain()) != int(Sim.WATCH_TICK):
		_fail(errors, "watch countdown started at %d, expected %d" % [shore.get_ticks_until_rain(), Sim.WATCH_TICK])
	if int(shore.get_stood()) != 0 or int(shore.get_posted()) != 6 or int(shore.get_relief_left()) != 6 or int(shore.get_yard_left()) != 57:
		_fail(errors, "watch opened early (stood %d posted %d relief %d yard %d)" % [
			shore.get_stood(), shore.get_posted(), shore.get_relief_left(), shore.get_yard_left(),
		])
	var saw_cap := false
	var stand_guard := 0
	while not shore.is_over() and stand_guard < int(Sim.WATCH_TICK) + 2:
		shore.tick()
		stand_guard += 1
		if int(shore.get_stood()) == int(Sim.WATCH_CAP) and int(shore.get_relief_left()) == 2 and int(shore.get_posted()) == 6 and int(shore.get_wage_left()) == 4 and int(shore.get_paid()) == 10 and int(shore.get_loft_left()) == 19 and int(shore.get_gate_left()) == 0 and int(shore.get_yard_left()) == 57 and int(shore.get_ticks_until_rain()) > 0:
			saw_cap = true
			var ticks_left := int(shore.get_ticks_until_rain())
			shore.tick()
			if int(shore.get_stood()) != int(Sim.WATCH_CAP) or int(shore.get_relief_left()) != 2 or int(shore.get_posted()) != 6 or int(shore.get_wage_left()) != 4 or int(shore.get_loft_left()) != 19 or int(shore.get_gate_left()) != 0 or int(shore.get_yard_left()) != 57 or int(shore.get_paid()) != 10 or int(shore.get_stored_salt()) != 2997 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29:
				_fail(errors, "the watch kept standing after the cap (stood %d relief %d posted %d wage %d loft %d gate %d yard %d paid %d)" % [
					shore.get_stood(), shore.get_relief_left(), shore.get_posted(), shore.get_wage_left(), shore.get_loft_left(), shore.get_gate_left(), shore.get_yard_left(), shore.get_paid(),
				])
			elif not shore.is_over() and int(shore.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the watch beat did not spend a tick after the cap")
			break
	if not saw_cap:
		_fail(errors, "the watch did not stop at %d while ticks remained (stood %d relief %d posted %d wage %d loft %d yard %d ticks %d)" % [
			Sim.WATCH_CAP, shore.get_stood(), shore.get_relief_left(), shore.get_posted(), shore.get_wage_left(), shore.get_loft_left(), shore.get_yard_left(), shore.get_ticks_until_rain(),
		])
	# Dry pans post 6 and the cap still stands only 4. The 2 who were paid and
	# not posted stay on the wage. The 2 who passed and were not paid stay on
	# the gate. The yard stays empty.
	var short = _prepare_plan(plans, "dry_stood", errors)
	if short == null:
		return
	var short_guard := 0
	while int(short.get_beat()) != Sim.WATCHING and not short.is_over() and short_guard < shore_limit:
		short.tick()
		short_guard += 1
	if int(short.get_beat()) != Sim.WATCHING or short.is_over():
		_fail(errors, "the relief beat did not open a watch beat for the dry cap")
		return
	var saw_short := false
	var short_steps := 0
	while not short.is_over() and short_steps < int(Sim.WATCH_TICK) + 2:
		short.tick()
		short_steps += 1
		if int(short.get_stood()) == int(Sim.WATCH_CAP) and int(short.get_relief_left()) == 2 and int(short.get_posted()) == 6 and int(short.get_wage_left()) == 2 and int(short.get_gate_left()) == 2 and int(short.get_paid()) == 8 and int(short.get_yard_left()) == 0 and int(short.get_loft_left()) == 0 and int(short.get_ticks_until_rain()) > 0:
			saw_short = true
			var short_ticks := int(short.get_ticks_until_rain())
			short.tick()
			if int(short.get_stood()) != 4 or int(short.get_relief_left()) != 2 or int(short.get_wage_left()) != 2 or int(short.get_gate_left()) != 2 or int(short.get_yard_left()) != 0 or int(short.get_posted()) != 6 or int(short.get_paid()) != 8:
				_fail(errors, "the watch stood an unposted hire or passed the cap (stood %d relief %d wage %d gate %d yard %d posted %d paid %d)" % [
					short.get_stood(), short.get_relief_left(), short.get_wage_left(), short.get_gate_left(), short.get_yard_left(), short.get_posted(), short.get_paid(),
				])
			elif not short.is_over() and int(short.get_ticks_until_rain()) >= short_ticks:
				_fail(errors, "the watch beat did not spend a tick after the dry cap")
			break
	if not saw_short:
		_fail(errors, "dry watch did not stop at 4 with unposted hires left (stood %d relief %d wage %d gate %d yard %d posted %d paid %d ticks %d)" % [
			short.get_stood(), short.get_relief_left(), short.get_wage_left(), short.get_gate_left(), short.get_yard_left(), short.get_posted(), short.get_paid(), short.get_ticks_until_rain(),
		])
	print("stood %d left relief %d unposted %d unpaid %d; dry stood %d left relief %d unposted %d unpaid %d; no watch stood %d left relief %d; watch without relief stood %d" % [
		stood.get_stood(), stood.get_relief_left(), stood_unposted, stood_unpaid, dry_stood.get_stood(), dry_stood.get_relief_left(), dry_unposted, dry_unpaid, ignored.get_stood(), ignored.get_relief_left(), bare.get_stood(),
	])


func _test_lamp(errors: Array) -> void:
	if int(Sim.LAMP_TICK) != 100 or int(Sim.LAMP_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "lamp beat length %s is not 100 ticks (10 seconds)" % Sim.LAMP_TICK)
	if int(Sim.LAMP_CAP) != 3:
		_fail(errors, "lamp cap is %s, expected 3" % Sim.LAMP_CAP)
	var fresh = Sim.new()
	if fresh.paint_cell(14, -6, Sim.LAMP) == false or int(fresh.get_paint(14, -6)) != Sim.LAMP:
		_fail(errors, "the cell north of the watch rejected the lamp mark")
	if fresh.paint_cell(14, -8, Sim.LAMP):
		_fail(errors, "the row north of the bell accepted a mark")
	if fresh.paint_cell(Sim.COAST_X, -6, Sim.LAMP):
		_fail(errors, "the brine accepted a lamp")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.LAMP):
		_fail(errors, "the anthill accepted a lamp")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var won = _run_plan(plans, "winning", errors)
	var dry = _run_plan(plans, "dry_pans", errors)
	var parked = _run_plan(plans, "carted", errors)
	var loaded = _run_plan(plans, "shipped", errors)
	var sold = _run_plan(plans, "sold", errors)
	var hired = _run_plan(plans, "hired", errors)
	var lofted = _run_plan(plans, "lofted", errors)
	var passed = _run_plan(plans, "gated", errors)
	var paid = _run_plan(plans, "paid", errors)
	var dry_paid = _run_plan(plans, "dry_paid", errors)
	var posted = _run_plan(plans, "posted", errors)
	var dry_posted = _run_plan(plans, "dry_posted", errors)
	var stood = _run_plan(plans, "stood", errors)
	var dry_stood = _run_plan(plans, "dry_stood", errors)
	var ignored = _run_plan(plans, "no_lamp", errors)
	var bare = _run_plan(plans, "lamp_only", errors)
	var lit = _run_plan(plans, "lit", errors)
	var lit_again = _run_plan(plans, "lit", errors)
	var late = _run_plan(plans, "late_lit", errors)
	var dry_lit = _run_plan(plans, "dry_lit", errors)
	if won == null or dry == null or parked == null or loaded == null or sold == null or hired == null or lofted == null or passed == null or paid == null or dry_paid == null or posted == null or dry_posted == null or stood == null or dry_stood == null or ignored == null or bare == null or lit == null or lit_again == null or late == null or dry_lit == null:
		return
	# Earlier plans keep the numbers they had before the lamp existed.
	# A plan that does not paint the lamp also lights nobody.
	if int(won.get_wet_haul()) != 2997 or int(won.get_stored_salt()) != 2997 or int(won.get_carted()) != 0 or int(won.get_shipped()) != 0 or int(won.get_coins()) != 0 or int(won.get_hired()) != 0 or int(won.get_posted()) != 0 or int(won.get_stood()) != 0 or int(won.get_lit()) != 0:
		_fail(errors, "winning shore changed (wet %d stored %d carted %d shipped %d coins %d hired %d posted %d stood %d lit %d)" % [
			won.get_wet_haul(), won.get_stored_salt(), won.get_carted(), won.get_shipped(), won.get_coins(), won.get_hired(), won.get_posted(), won.get_stood(), won.get_lit(),
		])
	if int(dry.get_wet_haul()) != 0 or int(dry.get_stored_salt()) != 1032 or int(dry.get_carted()) != 0 or int(dry.get_shipped()) != 0 or int(dry.get_coins()) != 0 or int(dry.get_hired()) != 0 or int(dry.get_posted()) != 0 or int(dry.get_stood()) != 0 or int(dry.get_lit()) != 0:
		_fail(errors, "dry_pans changed (wet %d stored %d carted %d shipped %d coins %d hired %d posted %d stood %d lit %d)" % [
			dry.get_wet_haul(), dry.get_stored_salt(), dry.get_carted(), dry.get_shipped(), dry.get_coins(), dry.get_hired(), dry.get_posted(), dry.get_stood(), dry.get_lit(),
		])
	if int(parked.get_wet_haul()) != 2997 or int(parked.get_stored_salt()) != 2997 or int(parked.get_carted()) != 2997 or int(parked.get_shipped()) != 0 or int(parked.get_coins()) != 0 or int(parked.get_posted()) != 0 or int(parked.get_stood()) != 0 or int(parked.get_lit()) != 0:
		_fail(errors, "carted plan changed (wet %d stored %d carted %d shipped %d coins %d posted %d stood %d lit %d)" % [
			parked.get_wet_haul(), parked.get_stored_salt(), parked.get_carted(), parked.get_shipped(), parked.get_coins(), parked.get_posted(), parked.get_stood(), parked.get_lit(),
		])
	if int(loaded.get_wet_haul()) != 2997 or int(loaded.get_stored_salt()) != 2997 or int(loaded.get_carted()) != 2997 or int(loaded.get_shipped()) != 2997 or int(loaded.get_coins()) != 0 or int(loaded.get_posted()) != 0 or int(loaded.get_stood()) != 0 or int(loaded.get_lit()) != 0:
		_fail(errors, "shipped plan changed (wet %d stored %d carted %d shipped %d coins %d posted %d stood %d lit %d)" % [
			loaded.get_wet_haul(), loaded.get_stored_salt(), loaded.get_carted(), loaded.get_shipped(), loaded.get_coins(), loaded.get_posted(), loaded.get_stood(), loaded.get_lit(),
		])
	if int(sold.get_wet_haul()) != 2997 or int(sold.get_stored_salt()) != 2997 or int(sold.get_carted()) != 2997 or int(sold.get_shipped()) != 2997 or int(sold.get_coins()) != 2997 or int(sold.get_posted()) != 0 or int(sold.get_stood()) != 0 or int(sold.get_lit()) != 0:
		_fail(errors, "sold plan changed (wet %d stored %d carted %d shipped %d coins %d posted %d stood %d lit %d)" % [
			sold.get_wet_haul(), sold.get_stored_salt(), sold.get_carted(), sold.get_shipped(), sold.get_coins(), sold.get_posted(), sold.get_stood(), sold.get_lit(),
		])
	if int(hired.get_hired()) != 29 or int(hired.get_yard_left()) != 97 or int(hired.get_coins()) != 2997 or int(hired.get_stood()) != 0 or int(hired.get_lit()) != 0 or int(hired.get_posted()) != 0:
		_fail(errors, "hired plan changed (coins %d hired %d left %d posted %d stood %d lit %d)" % [
			hired.get_coins(), hired.get_hired(), hired.get_yard_left(), hired.get_posted(), hired.get_stood(), hired.get_lit(),
		])
	if int(lofted.get_lofted()) != 29 or int(lofted.get_hired()) != 29 or int(lofted.get_yard_left()) != 97 or int(lofted.get_lit()) != 0 or int(lofted.get_coins()) != 2997:
		_fail(errors, "lofted plan changed (coins %d hired %d left %d lofted %d lit %d)" % [
			lofted.get_coins(), lofted.get_hired(), lofted.get_yard_left(), lofted.get_lofted(), lofted.get_lit(),
		])
	if int(passed.get_gated()) != 10 or int(passed.get_loft_left()) != 19 or int(passed.get_hired()) != 29 or int(passed.get_yard_left()) != 97 or int(passed.get_paid()) != 0 or int(passed.get_posted()) != 0 or int(passed.get_stood()) != 0 or int(passed.get_lit()) != 0 or int(passed.get_coins()) != 2997:
		_fail(errors, "gated plan changed (coins %d hired %d left %d gated %d loft %d paid %d posted %d stood %d lit %d)" % [
			passed.get_coins(), passed.get_hired(), passed.get_yard_left(), passed.get_gated(), passed.get_loft_left(), passed.get_paid(), passed.get_posted(), passed.get_stood(), passed.get_lit(),
		])
	if int(paid.get_paid()) != 10 or int(paid.get_gate_left()) != 0 or int(paid.get_yard_left()) != 57 or int(paid.get_loft_left()) != 19 or int(paid.get_hired()) != 29 or int(paid.get_posted()) != 0 or int(paid.get_stood()) != 0 or int(paid.get_lit()) != 0 or int(paid.get_coins()) != 2997 or int(paid.get_stored_salt()) != 2997:
		_fail(errors, "paid plan changed (stored %d coins %d hired %d yard %d paid %d loft %d posted %d stood %d lit %d)" % [
			paid.get_stored_salt(), paid.get_coins(), paid.get_hired(), paid.get_yard_left(), paid.get_paid(), paid.get_loft_left(), paid.get_posted(), paid.get_stood(), paid.get_lit(),
		])
	if int(dry_paid.get_wet_haul()) != 0 or int(dry_paid.get_stored_salt()) != 1032 or int(dry_paid.get_coins()) != 1032 or int(dry_paid.get_hired()) != 10 or int(dry_paid.get_paid()) != 8 or int(dry_paid.get_gate_left()) != 2 or int(dry_paid.get_yard_left()) != 0 or int(dry_paid.get_posted()) != 0 or int(dry_paid.get_stood()) != 0 or int(dry_paid.get_lit()) != 0:
		_fail(errors, "dry wage changed (wet %d stored %d coins %d hired %d paid %d unpaid %d yard %d posted %d stood %d lit %d)" % [
			dry_paid.get_wet_haul(), dry_paid.get_stored_salt(), dry_paid.get_coins(), dry_paid.get_hired(), dry_paid.get_paid(), dry_paid.get_gate_left(), dry_paid.get_yard_left(), dry_paid.get_posted(), dry_paid.get_stood(), dry_paid.get_lit(),
		])
	if int(posted.get_posted()) != 6 or int(posted.get_wage_left()) != 4 or int(posted.get_paid()) != 10 or int(posted.get_loft_left()) != 19 or int(posted.get_yard_left()) != 57 or int(posted.get_hired()) != 29 or int(posted.get_coins()) != 2997 or int(posted.get_stored_salt()) != 2997 or int(posted.get_carted()) != 2997 or int(posted.get_shipped()) != 2997 or int(posted.get_stood()) != 0 or int(posted.get_lit()) != 0 or int(posted.get_relief_left()) != 6:
		_fail(errors, "posted plan changed (stored %d carted %d shipped %d coins %d hired %d yard %d paid %d posted %d wage %d loft %d stood %d lit %d relief %d)" % [
			posted.get_stored_salt(), posted.get_carted(), posted.get_shipped(), posted.get_coins(), posted.get_hired(), posted.get_yard_left(), posted.get_paid(), posted.get_posted(), posted.get_wage_left(), posted.get_loft_left(), posted.get_stood(), posted.get_lit(), posted.get_relief_left(),
		])
	if int(dry_posted.get_wet_haul()) != 0 or int(dry_posted.get_posted()) != 6 or int(dry_posted.get_wage_left()) != 2 or int(dry_posted.get_gate_left()) != 2 or int(dry_posted.get_yard_left()) != 0 or int(dry_posted.get_paid()) != 8 or int(dry_posted.get_stood()) != 0 or int(dry_posted.get_lit()) != 0 or int(dry_posted.get_relief_left()) != 6:
		_fail(errors, "dry relief changed (wet %d paid %d posted %d wage %d gate %d yard %d stood %d lit %d relief %d)" % [
			dry_posted.get_wet_haul(), dry_posted.get_paid(), dry_posted.get_posted(), dry_posted.get_wage_left(), dry_posted.get_gate_left(), dry_posted.get_yard_left(), dry_posted.get_stood(), dry_posted.get_lit(), dry_posted.get_relief_left(),
		])
	if int(stood.get_stood()) != 4 or int(stood.get_relief_left()) != 2 or int(stood.get_posted()) != 6 or int(stood.get_wage_left()) != 4 or int(stood.get_loft_left()) != 19 or int(stood.get_yard_left()) != 57 or int(stood.get_hired()) != 29 or int(stood.get_paid()) != 10 or int(stood.get_lit()) != 0 or int(stood.get_watch_left()) != 4 or int(stood.get_coins()) != 2997 or int(stood.get_stored_salt()) != 2997 or int(stood.get_carted()) != 2997 or int(stood.get_shipped()) != 2997:
		_fail(errors, "stood plan changed (stored %d carted %d shipped %d coins %d hired %d yard %d paid %d posted %d stood %d lit %d watch %d relief %d wage %d loft %d)" % [
			stood.get_stored_salt(), stood.get_carted(), stood.get_shipped(), stood.get_coins(), stood.get_hired(), stood.get_yard_left(), stood.get_paid(), stood.get_posted(), stood.get_stood(), stood.get_lit(), stood.get_watch_left(), stood.get_relief_left(), stood.get_wage_left(), stood.get_loft_left(),
		])
	if int(dry_stood.get_wet_haul()) != 0 or int(dry_stood.get_stood()) != 4 or int(dry_stood.get_posted()) != 6 or int(dry_stood.get_relief_left()) != 2 or int(dry_stood.get_wage_left()) != 2 or int(dry_stood.get_gate_left()) != 2 or int(dry_stood.get_yard_left()) != 0 or int(dry_stood.get_lit()) != 0 or int(dry_stood.get_watch_left()) != 4 or int(dry_stood.get_paid()) != 8:
		_fail(errors, "dry watch changed (wet %d paid %d posted %d stood %d lit %d watch %d relief %d wage %d gate %d yard %d)" % [
			dry_stood.get_wet_haul(), dry_stood.get_paid(), dry_stood.get_posted(), dry_stood.get_stood(), dry_stood.get_lit(), dry_stood.get_watch_left(), dry_stood.get_relief_left(), dry_stood.get_wage_left(), dry_stood.get_gate_left(), dry_stood.get_yard_left(),
		])
	# Stood, no lamp: the 4 who were stood stay on the watch. The 2 posted
	# but not stood stay on the relief. The 4 paid but not posted stay on the
	# wage. The 19 in the loft stay unpaid.
	var ignored_unpaid := int(ignored.get_hired()) - int(ignored.get_paid())
	var ignored_unposted := int(ignored.get_paid()) - int(ignored.get_posted())
	if int(ignored.get_lit()) != 0 or int(ignored.get_watch_left()) != 4 or int(ignored.get_stood()) != 4 or int(ignored.get_relief_left()) != 2 or int(ignored.get_posted()) != 6 or ignored_unposted != 4 or int(ignored.get_wage_left()) != 4 or ignored_unpaid != 19 or int(ignored.get_loft_left()) != 19 or int(ignored.get_gate_left()) != 0 or int(ignored.get_yard_left()) != 57 or int(ignored.get_hired()) != 29 or int(ignored.get_paid()) != 10 or int(ignored.get_coins()) != 2997 or int(ignored.get_stored_salt()) != 2997 or int(ignored.get_carted()) != 2997 or int(ignored.get_shipped()) != 2997:
		_fail(errors, "no_lamp lit someone (stored %d carted %d shipped %d coins %d hired %d yard %d paid %d posted %d stood %d watch %d lit %d unpaid %d unposted %d loft %d wage %d)" % [
			ignored.get_stored_salt(), ignored.get_carted(), ignored.get_shipped(), ignored.get_coins(), ignored.get_hired(), ignored.get_yard_left(), ignored.get_paid(), ignored.get_posted(), ignored.get_stood(), ignored.get_watch_left(), ignored.get_lit(), ignored_unpaid, ignored_unposted, ignored.get_loft_left(), ignored.get_wage_left(),
		])
	if String(ignored.get_summary()) != String(stood.get_summary()):
		_fail(errors, "no_lamp summary changed: %s" % ignored.get_summary())
	if String(ignored.get_summary()).to_lower().contains("lit") or String(ignored.get_summary()).to_lower().contains("lamp"):
		_fail(errors, "no_lamp summary names a lamp: %s" % ignored.get_summary())
	var ignored_watch = plans["no_lamp"]["watch"][0]
	var ignored_salt: Dictionary = ignored.get_cell_salt(int(ignored_watch[0]), int(ignored_watch[1]))
	if int(ignored_salt.get("watch", 0)) != 4 or int(ignored_salt.get("lamp", 0)) != 0:
		_fail(errors, "no_lamp left %s at the watch and %s at a lamp" % [ignored_salt.get("watch", 0), ignored_salt.get("lamp", 0)])
	# A lamp with nobody stood lights nobody. Posted hires stay on the relief.
	var bare_unpaid := int(bare.get_hired()) - int(bare.get_paid())
	var bare_unstood := int(bare.get_posted()) - int(bare.get_stood())
	if int(bare.get_lit()) != 0 or int(bare.get_stood()) != 0 or int(bare.get_watch_left()) != 0 or int(bare.get_posted()) != 6 or int(bare.get_relief_left()) != 6 or bare_unstood != 6 or int(bare.get_paid()) != 10 or int(bare.get_wage_left()) != 4 or bare_unpaid != 19 or int(bare.get_loft_left()) != 19 or int(bare.get_gate_left()) != 0 or int(bare.get_yard_left()) != 57 or int(bare.get_hired()) != 29 or int(bare.get_coins()) != 2997 or int(bare.get_stored_salt()) != 2997 or int(bare.get_carted()) != 2997 or int(bare.get_shipped()) != 2997:
		_fail(errors, "lamp without a watch lit someone (stored %d carted %d shipped %d coins %d hired %d yard %d paid %d wage %d posted %d relief %d stood %d lit %d unpaid %d loft %d)" % [
			bare.get_stored_salt(), bare.get_carted(), bare.get_shipped(), bare.get_coins(), bare.get_hired(), bare.get_yard_left(), bare.get_paid(), bare.get_wage_left(), bare.get_posted(), bare.get_relief_left(), bare.get_stood(), bare.get_lit(), bare_unpaid, bare.get_loft_left(),
		])
	if String(bare.get_summary()) != String(posted.get_summary()):
		_fail(errors, "lamp without a watch changed the summary: %s" % bare.get_summary())
	if String(bare.get_summary()).to_lower().contains("lit") or String(bare.get_summary()).to_lower().contains("lamp") or String(bare.get_summary()).to_lower().contains("stood") or String(bare.get_summary()).to_lower().contains("watch"):
		_fail(errors, "lamp without a watch names a lamp: %s" % bare.get_summary())
	var bare_lamp = plans["lamp_only"]["lamp"][0]
	var bare_relief = plans["lamp_only"]["relief"][0]
	var bare_lamp_salt: Dictionary = bare.get_cell_salt(int(bare_lamp[0]), int(bare_lamp[1]))
	var bare_relief_salt: Dictionary = bare.get_cell_salt(int(bare_relief[0]), int(bare_relief[1]))
	if int(bare_lamp_salt.get("lamp", 0)) != 0 or int(bare_relief_salt.get("relief", 0)) != 6 or int(bare_lamp_salt.get("watch", 0)) != 0:
		_fail(errors, "lamp without a watch holds %s, relief holds %s" % [bare_lamp_salt.get("lamp", 0), bare_relief_salt.get("relief", 0)])
	var lamp_cell = plans["lit"]["lamp"][0]
	var watch_cell = plans["lit"]["watch"][0]
	var relief_cell = plans["lit"]["relief"][0]
	var wage_cell = plans["lit"]["wage"][0]
	var gate_cell = plans["lit"]["gate"][0]
	var loft_cell = plans["lit"]["loft"][0]
	var yard_cell = plans["lit"]["yard"][0]
	if int(lamp_cell[0]) != int(watch_cell[0]) or int(lamp_cell[1]) != int(watch_cell[1]) - 1:
		_fail(errors, "lit plan's lamp is not one cell north of the watch")
	if int(watch_cell[0]) != 14 or int(watch_cell[1]) != -5 or int(lamp_cell[0]) != 14 or int(lamp_cell[1]) != -6:
		_fail(errors, "lit plan's lamp is not at 14,-6 north of the watch at 14,-5")
	if int(watch_cell[0]) != int(relief_cell[0]) or int(watch_cell[1]) != int(relief_cell[1]) - 1:
		_fail(errors, "lit plan's watch is not one cell north of the relief")
	if int(lit.get_wet_haul()) != 2997 or int(lit.get_stored_salt()) != 2997 or int(lit.get_carted()) != 2997 or int(lit.get_shipped()) != 2997 or int(lit.get_coins()) != 2997 or int(lit.get_hired()) != 29 or int(lit.get_yard_left()) != 57 or int(lit.get_paid()) != 10 or int(lit.get_posted()) != 6 or int(lit.get_stood()) != 4 or int(lit.get_gated()) != 10 or int(lit.get_lofted()) != 29:
		_fail(errors, "lamp changed the stood shore (wet %d stored %d carted %d shipped %d coins %d hired %d yard %d paid %d posted %d stood %d gated %d lofted %d)" % [
			lit.get_wet_haul(), lit.get_stored_salt(), lit.get_carted(), lit.get_shipped(), lit.get_coins(), lit.get_hired(), lit.get_yard_left(), lit.get_paid(), lit.get_posted(), lit.get_stood(), lit.get_gated(), lit.get_lofted(),
		])
	var lit_unpaid := int(lit.get_hired()) - int(lit.get_paid())
	var lit_unposted := int(lit.get_paid()) - int(lit.get_posted())
	var lit_unstood := int(lit.get_posted()) - int(lit.get_stood())
	if int(lit.get_lit()) != 3 or int(lit.get_watch_left()) != 1 or lit_unstood != 2 or lit_unposted != 4 or lit_unpaid != 19 or int(lit.get_relief_left()) != 2 or int(lit.get_wage_left()) != 4 or int(lit.get_loft_left()) != 19 or int(lit.get_gate_left()) != 0 or int(lit.get_yard_left()) != 57 or int(lit.get_stood()) != 4 or int(lit.get_posted()) != 6:
		_fail(errors, "lit %d, left %d stood unlit, posted unstood %d, paid unposted %d, unpaid %d, watch %d, relief %d, wage %d, loft %d, gate %d, yard %d, stood %d, posted %d; expected 3, 1, 2, 4, 19, 1, 2, 4, 19, 0, 57, 4, 6" % [
			lit.get_lit(), lit.get_watch_left(), lit_unstood, lit_unposted, lit_unpaid, lit.get_watch_left(), lit.get_relief_left(), lit.get_wage_left(), lit.get_loft_left(), lit.get_gate_left(), lit.get_yard_left(), lit.get_stood(), lit.get_posted(),
		])
	if int(lit.get_lit()) > int(Sim.LAMP_CAP):
		_fail(errors, "lamp lit %d, over the cap of %d" % [lit.get_lit(), Sim.LAMP_CAP])
	var lamp_salt: Dictionary = lit.get_cell_salt(int(lamp_cell[0]), int(lamp_cell[1]))
	var watch_salt: Dictionary = lit.get_cell_salt(int(watch_cell[0]), int(watch_cell[1]))
	var relief_salt: Dictionary = lit.get_cell_salt(int(relief_cell[0]), int(relief_cell[1]))
	var wage_salt: Dictionary = lit.get_cell_salt(int(wage_cell[0]), int(wage_cell[1]))
	var gate_salt: Dictionary = lit.get_cell_salt(int(gate_cell[0]), int(gate_cell[1]))
	var loft_salt: Dictionary = lit.get_cell_salt(int(loft_cell[0]), int(loft_cell[1]))
	var yard_salt: Dictionary = lit.get_cell_salt(int(yard_cell[0]), int(yard_cell[1]))
	if int(lamp_salt.get("lamp", 0)) != 3 or int(watch_salt.get("watch", 0)) != 1 or int(relief_salt.get("relief", 0)) != 2 or int(wage_salt.get("wage", 0)) != 4 or int(gate_salt.get("gate", 0)) != 0 or int(loft_salt.get("loft", 0)) != 19 or int(yard_salt.get("yard", 0)) != 57:
		_fail(errors, "lamp cell holds %s, watch holds %s, relief holds %s, wage holds %s, gate holds %s, loft holds %s, yard holds %s" % [
			lamp_salt.get("lamp", 0), watch_salt.get("watch", 0), relief_salt.get("relief", 0), wage_salt.get("wage", 0), gate_salt.get("gate", 0), loft_salt.get("loft", 0), yard_salt.get("yard", 0),
		])
	var lit_summary := String(lit.get_summary())
	if not lit_summary.contains("Lit 3 on the lamp") or not lit_summary.contains("Left 1 at the watch") or not lit_summary.contains("Stood 4 on the watch") or not lit_summary.contains("Left 2 at the relief") or not lit_summary.contains("Posted 6") or not lit_summary.contains("Left 4 at the wage") or not lit_summary.contains("Paid 10") or not lit_summary.contains("Left 19 in the loft") or not lit_summary.contains("Left 57"):
		_fail(errors, "lit summary does not name the lamp: %s" % lit_summary)
	if not lit_summary.contains("Coins 2997") or not lit_summary.contains("Hired 29"):
		_fail(errors, "lit summary dropped the earlier totals: %s" % lit_summary)
	if int(lit_again.get_lit()) != int(lit.get_lit()) or int(lit_again.get_watch_left()) != int(lit.get_watch_left()) or int(lit_again.get_stood()) != int(lit.get_stood()) or int(lit_again.get_posted()) != int(lit.get_posted()) or int(lit_again.get_yard_left()) != int(lit.get_yard_left()) or int(lit_again.get_stored_salt()) != int(lit.get_stored_salt()):
		_fail(errors, "repeated lamp paint lit %d and left watch %d, then lit %d and left watch %d" % [
			lit.get_lit(), lit.get_watch_left(), lit_again.get_lit(), lit_again.get_watch_left(),
		])
	if int(late.get_lit()) != 3 or int(late.get_watch_left()) != 1 or int(late.get_stood()) != 4 or int(late.get_posted()) != 6 or int(late.get_relief_left()) != 2 or int(late.get_wage_left()) != 4 or int(late.get_paid()) != 10 or int(late.get_loft_left()) != 19 or int(late.get_yard_left()) != 57 or int(late.get_hired()) != 29 or int(late.get_coins()) != int(lit.get_coins()) or int(late.get_stored_salt()) != int(lit.get_stored_salt()) or int(late.get_carted()) != int(lit.get_carted()) or int(late.get_shipped()) != int(lit.get_shipped()):
		_fail(errors, "painting the lamp at the lamp beat (lit %d watch %d stood %d posted %d relief %d wage %d paid %d loft %d yard %d hired %d coins %d stored %d) did not match painting it early (lit %d watch %d stood %d posted %d relief %d wage %d paid %d loft %d yard %d hired %d coins %d stored %d)" % [
			late.get_lit(), late.get_watch_left(), late.get_stood(), late.get_posted(), late.get_relief_left(), late.get_wage_left(), late.get_paid(), late.get_loft_left(), late.get_yard_left(), late.get_hired(), late.get_coins(), late.get_stored_salt(), lit.get_lit(), lit.get_watch_left(), lit.get_stood(), lit.get_posted(), lit.get_relief_left(), lit.get_wage_left(), lit.get_paid(), lit.get_loft_left(), lit.get_yard_left(), lit.get_hired(), lit.get_coins(), lit.get_stored_salt(),
		])
	var dry_unpaid := int(dry_lit.get_hired()) - int(dry_lit.get_paid())
	var dry_unposted := int(dry_lit.get_paid()) - int(dry_lit.get_posted())
	var dry_unstood := int(dry_lit.get_posted()) - int(dry_lit.get_stood())
	if int(dry_lit.get_wet_haul()) != 0 or int(dry_lit.get_stored_salt()) != 1032 or int(dry_lit.get_carted()) != 1032 or int(dry_lit.get_shipped()) != 1032 or int(dry_lit.get_coins()) != 1032 or int(dry_lit.get_hired()) != 10 or int(dry_lit.get_paid()) != 8 or int(dry_lit.get_posted()) != 6 or int(dry_lit.get_stood()) != 4 or int(dry_lit.get_lit()) != 3 or int(dry_lit.get_watch_left()) != 1 or dry_unstood != 2 or dry_unposted != 2 or dry_unpaid != 2 or int(dry_lit.get_relief_left()) != 2 or int(dry_lit.get_wage_left()) != 2 or int(dry_lit.get_gate_left()) != 2 or int(dry_lit.get_loft_left()) != 0 or int(dry_lit.get_yard_left()) != 0:
		_fail(errors, "dry lamp changed the short crew (wet %d stored %d carted %d shipped %d coins %d hired %d paid %d posted %d stood %d lit %d watch %d unstood %d unposted %d unpaid %d relief %d wage %d gate %d loft %d yard %d)" % [
			dry_lit.get_wet_haul(), dry_lit.get_stored_salt(), dry_lit.get_carted(), dry_lit.get_shipped(), dry_lit.get_coins(), dry_lit.get_hired(), dry_lit.get_paid(), dry_lit.get_posted(), dry_lit.get_stood(), dry_lit.get_lit(), dry_lit.get_watch_left(), dry_unstood, dry_unposted, dry_unpaid, dry_lit.get_relief_left(), dry_lit.get_wage_left(), dry_lit.get_gate_left(), dry_lit.get_loft_left(), dry_lit.get_yard_left(),
		])
	var dry_lamp_cell = plans["dry_lit"]["lamp"][0]
	var dry_watch_cell = plans["dry_lit"]["watch"][0]
	var dry_relief_cell = plans["dry_lit"]["relief"][0]
	var dry_wage_cell = plans["dry_lit"]["wage"][0]
	var dry_gate_cell = plans["dry_lit"]["gate"][0]
	var dry_lamp_salt: Dictionary = dry_lit.get_cell_salt(int(dry_lamp_cell[0]), int(dry_lamp_cell[1]))
	var dry_watch_salt: Dictionary = dry_lit.get_cell_salt(int(dry_watch_cell[0]), int(dry_watch_cell[1]))
	var dry_relief_salt: Dictionary = dry_lit.get_cell_salt(int(dry_relief_cell[0]), int(dry_relief_cell[1]))
	var dry_wage_salt: Dictionary = dry_lit.get_cell_salt(int(dry_wage_cell[0]), int(dry_wage_cell[1]))
	var dry_gate_salt: Dictionary = dry_lit.get_cell_salt(int(dry_gate_cell[0]), int(dry_gate_cell[1]))
	if int(dry_lamp_salt.get("lamp", 0)) != 3 or int(dry_watch_salt.get("watch", 0)) != 1 or int(dry_relief_salt.get("relief", 0)) != 2 or int(dry_wage_salt.get("wage", 0)) != 2 or int(dry_gate_salt.get("gate", 0)) != 2:
		_fail(errors, "dry lamp cell holds %s, watch holds %s, relief holds %s, wage holds %s, gate holds %s" % [
			dry_lamp_salt.get("lamp", 0), dry_watch_salt.get("watch", 0), dry_relief_salt.get("relief", 0), dry_wage_salt.get("wage", 0), dry_gate_salt.get("gate", 0),
		])
	if not String(dry_lit.get_summary()).contains("Lit 3 on the lamp") or not String(dry_lit.get_summary()).contains("Left 1 at the watch") or not String(dry_lit.get_summary()).contains("Stood 4 on the watch") or not String(dry_lit.get_summary()).contains("Left 2 at the relief") or not String(dry_lit.get_summary()).contains("Posted 6") or not String(dry_lit.get_summary()).contains("Left 2 at the wage") or not String(dry_lit.get_summary()).contains("Paid 8") or not String(dry_lit.get_summary()).contains("Left 2 unpaid") or not String(dry_lit.get_summary()).contains("Left 0 in the yard"):
		_fail(errors, "dry lamp summary does not name the cap: %s" % dry_lit.get_summary())
	_assert_pop(lit, errors, "lit plan")
	_assert_pop(lit_again, errors, "lit plan again")
	_assert_pop(late, errors, "late_lit")
	_assert_pop(dry_lit, errors, "dry_lit")
	_assert_pop(ignored, errors, "no_lamp")
	_assert_pop(bare, errors, "lamp_only")
	# The cap stops the lamp while ticks remain and stood hires remain.
	# Hires still in the loft, hires who passed and were not paid, hires who
	# were paid but not posted, and hires who were posted but not stood, stay put.
	var shore = _prepare_plan(plans, "lit", errors)
	if shore == null:
		return
	var shore_guard := 0
	var shore_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + 2
	while int(shore.get_beat()) != Sim.LAMPING and not shore.is_over() and shore_guard < shore_limit:
		shore.tick()
		shore_guard += 1
	if int(shore.get_beat()) != Sim.LAMPING or shore.is_over():
		_fail(errors, "the watch beat did not open a lamp beat for the cap check")
		return
	if int(shore.get_ticks_until_rain()) != int(Sim.LAMP_TICK):
		_fail(errors, "lamp countdown started at %d, expected %d" % [shore.get_ticks_until_rain(), Sim.LAMP_TICK])
	if int(shore.get_lit()) != 0 or int(shore.get_stood()) != 4 or int(shore.get_watch_left()) != 4 or int(shore.get_posted()) != 6 or int(shore.get_yard_left()) != 57:
		_fail(errors, "lamp opened early (lit %d stood %d watch %d posted %d yard %d)" % [
			shore.get_lit(), shore.get_stood(), shore.get_watch_left(), shore.get_posted(), shore.get_yard_left(),
		])
	var saw_cap := false
	var light_guard := 0
	while not shore.is_over() and light_guard < int(Sim.LAMP_TICK) + 2:
		shore.tick()
		light_guard += 1
		if int(shore.get_lit()) == int(Sim.LAMP_CAP) and int(shore.get_watch_left()) == 1 and int(shore.get_stood()) == 4 and int(shore.get_relief_left()) == 2 and int(shore.get_posted()) == 6 and int(shore.get_wage_left()) == 4 and int(shore.get_paid()) == 10 and int(shore.get_loft_left()) == 19 and int(shore.get_gate_left()) == 0 and int(shore.get_yard_left()) == 57 and int(shore.get_ticks_until_rain()) > 0:
			saw_cap = true
			var ticks_left := int(shore.get_ticks_until_rain())
			shore.tick()
			if int(shore.get_lit()) != int(Sim.LAMP_CAP) or int(shore.get_watch_left()) != 1 or int(shore.get_stood()) != 4 or int(shore.get_relief_left()) != 2 or int(shore.get_posted()) != 6 or int(shore.get_wage_left()) != 4 or int(shore.get_loft_left()) != 19 or int(shore.get_gate_left()) != 0 or int(shore.get_yard_left()) != 57 or int(shore.get_paid()) != 10 or int(shore.get_stored_salt()) != 2997 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29:
				_fail(errors, "the lamp kept lighting after the cap (lit %d watch %d stood %d relief %d posted %d wage %d loft %d gate %d yard %d paid %d)" % [
					shore.get_lit(), shore.get_watch_left(), shore.get_stood(), shore.get_relief_left(), shore.get_posted(), shore.get_wage_left(), shore.get_loft_left(), shore.get_gate_left(), shore.get_yard_left(), shore.get_paid(),
				])
			elif not shore.is_over() and int(shore.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the lamp beat did not spend a tick after the cap")
			break
	if not saw_cap:
		_fail(errors, "the lamp did not stop at %d while ticks remained (lit %d watch %d stood %d relief %d posted %d wage %d loft %d yard %d ticks %d)" % [
			Sim.LAMP_CAP, shore.get_lit(), shore.get_watch_left(), shore.get_stood(), shore.get_relief_left(), shore.get_posted(), shore.get_wage_left(), shore.get_loft_left(), shore.get_yard_left(), shore.get_ticks_until_rain(),
		])
	# Dry pans stand 4 and the cap still lights only 3. The 1 who was stood
	# and not lit stays on the watch. The 2 who were posted and not stood stay
	# on the relief. The 2 who were paid and not posted stay on the wage. The
	# 2 who passed and were not paid stay on the gate. The yard stays empty.
	var short = _prepare_plan(plans, "dry_lit", errors)
	if short == null:
		return
	var short_guard := 0
	while int(short.get_beat()) != Sim.LAMPING and not short.is_over() and short_guard < shore_limit:
		short.tick()
		short_guard += 1
	if int(short.get_beat()) != Sim.LAMPING or short.is_over():
		_fail(errors, "the watch beat did not open a lamp beat for the dry cap")
		return
	var saw_short := false
	var short_steps := 0
	while not short.is_over() and short_steps < int(Sim.LAMP_TICK) + 2:
		short.tick()
		short_steps += 1
		if int(short.get_lit()) == int(Sim.LAMP_CAP) and int(short.get_watch_left()) == 1 and int(short.get_stood()) == 4 and int(short.get_relief_left()) == 2 and int(short.get_posted()) == 6 and int(short.get_wage_left()) == 2 and int(short.get_gate_left()) == 2 and int(short.get_paid()) == 8 and int(short.get_yard_left()) == 0 and int(short.get_loft_left()) == 0 and int(short.get_ticks_until_rain()) > 0:
			saw_short = true
			var short_ticks := int(short.get_ticks_until_rain())
			short.tick()
			if int(short.get_lit()) != 3 or int(short.get_watch_left()) != 1 or int(short.get_relief_left()) != 2 or int(short.get_wage_left()) != 2 or int(short.get_gate_left()) != 2 or int(short.get_yard_left()) != 0 or int(short.get_stood()) != 4 or int(short.get_posted()) != 6 or int(short.get_paid()) != 8:
				_fail(errors, "the lamp lit an unstood hire or passed the cap (lit %d watch %d relief %d wage %d gate %d yard %d stood %d posted %d paid %d)" % [
					short.get_lit(), short.get_watch_left(), short.get_relief_left(), short.get_wage_left(), short.get_gate_left(), short.get_yard_left(), short.get_stood(), short.get_posted(), short.get_paid(),
				])
			elif not short.is_over() and int(short.get_ticks_until_rain()) >= short_ticks:
				_fail(errors, "the lamp beat did not spend a tick after the dry cap")
			break
	if not saw_short:
		_fail(errors, "dry lamp did not stop at 3 with unstood hires left (lit %d watch %d relief %d wage %d gate %d yard %d stood %d posted %d paid %d ticks %d)" % [
			short.get_lit(), short.get_watch_left(), short.get_relief_left(), short.get_wage_left(), short.get_gate_left(), short.get_yard_left(), short.get_stood(), short.get_posted(), short.get_paid(), short.get_ticks_until_rain(),
		])
	print("lit %d left watch %d unstood %d unposted %d unpaid %d; dry lit %d left watch %d unstood %d unposted %d unpaid %d; no lamp lit %d left watch %d; lamp without watch lit %d" % [
		lit.get_lit(), lit.get_watch_left(), lit_unstood, lit_unposted, lit_unpaid, dry_lit.get_lit(), dry_lit.get_watch_left(), dry_unstood, dry_unposted, dry_unpaid, ignored.get_lit(), ignored.get_watch_left(), bare.get_lit(),
	])


func _assert_chain(sim, errors: Array, label: String, wet: int, stored: int, carted: int, shipped: int, coins: int, hired: int, yard: int, paid: int, posted: int, stood: int, lit: int, rung: int) -> void:
	if sim == null:
		_fail(errors, "%s did not run" % label)
		return
	if int(sim.get_wet_haul()) != wet or int(sim.get_stored_salt()) != stored or int(sim.get_carted()) != carted or int(sim.get_shipped()) != shipped or int(sim.get_coins()) != coins or int(sim.get_hired()) != hired or int(sim.get_yard_left()) != yard or int(sim.get_paid()) != paid or int(sim.get_posted()) != posted or int(sim.get_stood()) != stood or int(sim.get_lit()) != lit or int(sim.get_rung()) != rung:
		_fail(errors, "%s changed (wet %d stored %d carted %d shipped %d coins %d hired %d yard %d paid %d posted %d stood %d lit %d rung %d)" % [label, sim.get_wet_haul(), sim.get_stored_salt(), sim.get_carted(), sim.get_shipped(), sim.get_coins(), sim.get_hired(), sim.get_yard_left(), sim.get_paid(), sim.get_posted(), sim.get_stood(), sim.get_lit(), sim.get_rung()])


func _test_bell(errors: Array) -> void:
	if int(Sim.BELL_TICK) != 100 or int(Sim.BELL_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "bell beat length %s is not 100 ticks (10 seconds)" % Sim.BELL_TICK)
	if int(Sim.BELL_CAP) != 2:
		_fail(errors, "bell cap is %s, expected 2" % Sim.BELL_CAP)
	var fresh = Sim.new()
	if fresh.paint_cell(14, -7, Sim.BELL) == false or int(fresh.get_paint(14, -7)) != Sim.BELL:
		_fail(errors, "the cell north of the lamp rejected the bell mark")
	if fresh.paint_cell(14, -8, Sim.BELL):
		_fail(errors, "the row north of the bell accepted a mark")
	if fresh.paint_cell(Sim.COAST_X, -7, Sim.BELL):
		_fail(errors, "the brine accepted a bell")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.BELL):
		_fail(errors, "the anthill accepted a bell")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var won = _run_plan(plans, "winning", errors)
	var dry = _run_plan(plans, "dry_pans", errors)
	var parked = _run_plan(plans, "carted", errors)
	var loaded = _run_plan(plans, "shipped", errors)
	var sold = _run_plan(plans, "sold", errors)
	var hired = _run_plan(plans, "hired", errors)
	var lofted = _run_plan(plans, "lofted", errors)
	var passed = _run_plan(plans, "gated", errors)
	var paid = _run_plan(plans, "paid", errors)
	var dry_paid = _run_plan(plans, "dry_paid", errors)
	var posted = _run_plan(plans, "posted", errors)
	var dry_posted = _run_plan(plans, "dry_posted", errors)
	var stood = _run_plan(plans, "stood", errors)
	var dry_stood = _run_plan(plans, "dry_stood", errors)
	var lit = _run_plan(plans, "lit", errors)
	var dry_lit = _run_plan(plans, "dry_lit", errors)
	var ignored = _run_plan(plans, "no_bell", errors)
	var bare = _run_plan(plans, "bell_only", errors)
	var rung = _run_plan(plans, "rung", errors)
	var rung_again = _run_plan(plans, "rung", errors)
	var late = _run_plan(plans, "late_rung", errors)
	var dry_rung = _run_plan(plans, "dry_rung", errors)
	if won == null or dry == null or parked == null or loaded == null or sold == null or hired == null or lofted == null or passed == null or paid == null or dry_paid == null or posted == null or dry_posted == null or stood == null or dry_stood == null or lit == null or dry_lit == null or ignored == null or bare == null or rung == null or rung_again == null or late == null or dry_rung == null:
		return
	# Earlier plans keep the numbers they had before the bell existed.
	_assert_chain(won, errors, "winning shore", 2997, 2997, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	_assert_chain(dry, errors, "dry pans", 0, 1032, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	_assert_chain(parked, errors, "carted plan", 2997, 2997, 2997, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	_assert_chain(loaded, errors, "shipped plan", 2997, 2997, 2997, 2997, 0, 0, 0, 0, 0, 0, 0, 0)
	_assert_chain(sold, errors, "sold plan", 2997, 2997, 2997, 2997, 2997, 0, 0, 0, 0, 0, 0, 0)
	_assert_chain(hired, errors, "hired plan", 2997, 2997, 2997, 2997, 2997, 29, 97, 0, 0, 0, 0, 0)
	_assert_chain(lofted, errors, "lofted plan", 2997, 2997, 2997, 2997, 2997, 29, 97, 0, 0, 0, 0, 0)
	_assert_chain(passed, errors, "gated plan", 2997, 2997, 2997, 2997, 2997, 29, 97, 0, 0, 0, 0, 0)
	_assert_chain(paid, errors, "paid plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 0, 0, 0, 0)
	_assert_chain(dry_paid, errors, "dry wage", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 0, 0, 0, 0)
	_assert_chain(posted, errors, "posted plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 0, 0, 0)
	_assert_chain(dry_posted, errors, "dry relief", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 0, 0, 0)
	_assert_chain(stood, errors, "stood plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 0, 0)
	_assert_chain(dry_stood, errors, "dry watch", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 0, 0)
	_assert_chain(lit, errors, "lit plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 0)
	_assert_chain(dry_lit, errors, "dry lamp", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 0)
	# Lit, no bell: the 3 who were lit stay on the lamp. The 1 stood but not
	# lit stays on the watch. The 2 posted but not stood stay on the relief.
	# The 4 paid but not posted stay on the wage. The 19 in the loft stay unpaid.
	var ignored_unpaid := int(ignored.get_hired()) - int(ignored.get_paid())
	var ignored_unposted := int(ignored.get_paid()) - int(ignored.get_posted())
	var ignored_unstood := int(ignored.get_posted()) - int(ignored.get_stood())
	if int(ignored.get_rung()) != 0 or int(ignored.get_lamp_left()) != 3 or int(ignored.get_lit()) != 3 or int(ignored.get_watch_left()) != 1 or ignored_unstood != 2 or ignored_unposted != 4 or ignored_unpaid != 19 or int(ignored.get_relief_left()) != 2 or int(ignored.get_wage_left()) != 4 or int(ignored.get_loft_left()) != 19 or int(ignored.get_gate_left()) != 0 or int(ignored.get_yard_left()) != 57 or int(ignored.get_stood()) != 4 or int(ignored.get_posted()) != 6 or int(ignored.get_paid()) != 10 or int(ignored.get_hired()) != 29 or int(ignored.get_coins()) != 2997 or int(ignored.get_stored_salt()) != 2997 or int(ignored.get_carted()) != 2997 or int(ignored.get_shipped()) != 2997:
		_fail(errors, "no_bell rang someone (stored %d carted %d shipped %d coins %d hired %d yard %d paid %d posted %d stood %d lit %d lamp %d rung %d unpaid %d unposted %d unstood %d loft %d wage %d)" % [ignored.get_stored_salt(), ignored.get_carted(), ignored.get_shipped(), ignored.get_coins(), ignored.get_hired(), ignored.get_yard_left(), ignored.get_paid(), ignored.get_posted(), ignored.get_stood(), ignored.get_lit(), ignored.get_lamp_left(), ignored.get_rung(), ignored_unpaid, ignored_unposted, ignored_unstood, ignored.get_loft_left(), ignored.get_wage_left()])
	if String(ignored.get_summary()) != String(lit.get_summary()):
		_fail(errors, "no_bell summary changed: %s" % ignored.get_summary())
	if String(ignored.get_summary()).to_lower().contains("rung") or String(ignored.get_summary()).to_lower().contains("bell"):
		_fail(errors, "no_bell summary names a bell: %s" % ignored.get_summary())
	var ignored_lamp = plans["no_bell"]["lamp"][0]
	var ignored_salt: Dictionary = ignored.get_cell_salt(int(ignored_lamp[0]), int(ignored_lamp[1]))
	var ignored_north: Dictionary = ignored.get_cell_salt(int(ignored_lamp[0]), int(ignored_lamp[1]) - 1)
	if int(ignored_salt.get("lamp", 0)) != 3 or int(ignored_north.get("bell", 0)) != 0 or int(ignored_salt.get("bell", 0)) != 0:
		_fail(errors, "no_bell left %s at the lamp and %s at a bell" % [ignored_salt.get("lamp", 0), ignored_north.get("bell", 0)])
	# A bell with nobody lit rings nobody. Stood hires stay on the watch.
	var bare_unpaid := int(bare.get_hired()) - int(bare.get_paid())
	var bare_unstood := int(bare.get_posted()) - int(bare.get_stood())
	if int(bare.get_rung()) != 0 or int(bare.get_lit()) != 0 or int(bare.get_lamp_left()) != 0 or int(bare.get_stood()) != 4 or int(bare.get_watch_left()) != 4 or int(bare.get_posted()) != 6 or int(bare.get_relief_left()) != 2 or bare_unstood != 2 or int(bare.get_paid()) != 10 or int(bare.get_wage_left()) != 4 or bare_unpaid != 19 or int(bare.get_loft_left()) != 19 or int(bare.get_gate_left()) != 0 or int(bare.get_yard_left()) != 57 or int(bare.get_hired()) != 29 or int(bare.get_coins()) != 2997 or int(bare.get_stored_salt()) != 2997 or int(bare.get_carted()) != 2997 or int(bare.get_shipped()) != 2997:
		_fail(errors, "bell without a lamp rang someone (stored %d carted %d shipped %d coins %d hired %d yard %d paid %d wage %d posted %d relief %d stood %d watch %d lit %d rung %d unpaid %d loft %d)" % [bare.get_stored_salt(), bare.get_carted(), bare.get_shipped(), bare.get_coins(), bare.get_hired(), bare.get_yard_left(), bare.get_paid(), bare.get_wage_left(), bare.get_posted(), bare.get_relief_left(), bare.get_stood(), bare.get_watch_left(), bare.get_lit(), bare.get_rung(), bare_unpaid, bare.get_loft_left()])
	if String(bare.get_summary()) != String(stood.get_summary()):
		_fail(errors, "bell without a lamp changed the summary: %s" % bare.get_summary())
	if String(bare.get_summary()).to_lower().contains("rung") or String(bare.get_summary()).to_lower().contains("bell") or String(bare.get_summary()).to_lower().contains("lit") or String(bare.get_summary()).to_lower().contains("lamp"):
		_fail(errors, "bell without a lamp names a bell: %s" % bare.get_summary())
	var bare_bell = plans["bell_only"]["bell"][0]
	var bare_watch = plans["bell_only"]["watch"][0]
	var bare_bell_salt: Dictionary = bare.get_cell_salt(int(bare_bell[0]), int(bare_bell[1]))
	var bare_watch_salt: Dictionary = bare.get_cell_salt(int(bare_watch[0]), int(bare_watch[1]))
	if int(bare_bell_salt.get("bell", 0)) != 0 or int(bare_watch_salt.get("watch", 0)) != 4 or int(bare_bell_salt.get("lamp", 0)) != 0:
		_fail(errors, "bell without a lamp holds %s, watch holds %s" % [bare_bell_salt.get("bell", 0), bare_watch_salt.get("watch", 0)])
	var bell_cell = plans["rung"]["bell"][0]
	var lamp_cell = plans["rung"]["lamp"][0]
	var watch_cell = plans["rung"]["watch"][0]
	var relief_cell = plans["rung"]["relief"][0]
	var wage_cell = plans["rung"]["wage"][0]
	var gate_cell = plans["rung"]["gate"][0]
	var loft_cell = plans["rung"]["loft"][0]
	var yard_cell = plans["rung"]["yard"][0]
	if int(bell_cell[0]) != int(lamp_cell[0]) or int(bell_cell[1]) != int(lamp_cell[1]) - 1:
		_fail(errors, "rung plan's bell is not one cell north of the lamp")
	if int(lamp_cell[0]) != 14 or int(lamp_cell[1]) != -6 or int(bell_cell[0]) != 14 or int(bell_cell[1]) != -7:
		_fail(errors, "rung plan's bell is not at 14,-7 north of the lamp at 14,-6")
	if int(lamp_cell[0]) != int(watch_cell[0]) or int(lamp_cell[1]) != int(watch_cell[1]) - 1:
		_fail(errors, "rung plan's lamp is not one cell north of the watch")
	_assert_chain(rung, errors, "rung plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2)
	var rung_unpaid := int(rung.get_hired()) - int(rung.get_paid())
	var rung_unposted := int(rung.get_paid()) - int(rung.get_posted())
	var rung_unstood := int(rung.get_posted()) - int(rung.get_stood())
	var rung_unlit := int(rung.get_stood()) - int(rung.get_lit())
	if int(rung.get_rung()) != 2 or int(rung.get_lamp_left()) != 1 or rung_unlit != 1 or rung_unstood != 2 or rung_unposted != 4 or rung_unpaid != 19 or int(rung.get_watch_left()) != 1 or int(rung.get_relief_left()) != 2 or int(rung.get_wage_left()) != 4 or int(rung.get_loft_left()) != 19 or int(rung.get_gate_left()) != 0 or int(rung.get_yard_left()) != 57 or int(rung.get_lit()) != 3 or int(rung.get_stood()) != 4 or int(rung.get_posted()) != 6:
		_fail(errors, "rung %d, left %d lit unrung, stood unlit %d, posted unstood %d, paid unposted %d, unpaid %d, lamp %d, watch %d, relief %d, wage %d, loft %d, gate %d, yard %d, lit %d, stood %d, posted %d; expected 2, 1, 1, 2, 4, 19, 1, 1, 2, 4, 19, 0, 57, 3, 4, 6" % [rung.get_rung(), rung.get_lamp_left(), rung_unlit, rung_unstood, rung_unposted, rung_unpaid, rung.get_lamp_left(), rung.get_watch_left(), rung.get_relief_left(), rung.get_wage_left(), rung.get_loft_left(), rung.get_gate_left(), rung.get_yard_left(), rung.get_lit(), rung.get_stood(), rung.get_posted()])
	if int(rung.get_rung()) > int(Sim.BELL_CAP):
		_fail(errors, "bell rang %d, over the cap of %d" % [rung.get_rung(), Sim.BELL_CAP])
	var bell_salt: Dictionary = rung.get_cell_salt(int(bell_cell[0]), int(bell_cell[1]))
	var lamp_salt: Dictionary = rung.get_cell_salt(int(lamp_cell[0]), int(lamp_cell[1]))
	var watch_salt: Dictionary = rung.get_cell_salt(int(watch_cell[0]), int(watch_cell[1]))
	var relief_salt: Dictionary = rung.get_cell_salt(int(relief_cell[0]), int(relief_cell[1]))
	var wage_salt: Dictionary = rung.get_cell_salt(int(wage_cell[0]), int(wage_cell[1]))
	var gate_salt: Dictionary = rung.get_cell_salt(int(gate_cell[0]), int(gate_cell[1]))
	var loft_salt: Dictionary = rung.get_cell_salt(int(loft_cell[0]), int(loft_cell[1]))
	var yard_salt: Dictionary = rung.get_cell_salt(int(yard_cell[0]), int(yard_cell[1]))
	if int(bell_salt.get("bell", 0)) != 2 or int(lamp_salt.get("lamp", 0)) != 1 or int(watch_salt.get("watch", 0)) != 1 or int(relief_salt.get("relief", 0)) != 2 or int(wage_salt.get("wage", 0)) != 4 or int(gate_salt.get("gate", 0)) != 0 or int(loft_salt.get("loft", 0)) != 19 or int(yard_salt.get("yard", 0)) != 57:
		_fail(errors, "bell cell holds %s, lamp holds %s, watch holds %s, relief holds %s, wage holds %s, gate holds %s, loft holds %s, yard holds %s" % [bell_salt.get("bell", 0), lamp_salt.get("lamp", 0), watch_salt.get("watch", 0), relief_salt.get("relief", 0), wage_salt.get("wage", 0), gate_salt.get("gate", 0), loft_salt.get("loft", 0), yard_salt.get("yard", 0)])
	var rung_summary := String(rung.get_summary())
	if not rung_summary.contains("Rung 2 on the bell") or not rung_summary.contains("Left 1 at the lamp") or not rung_summary.contains("Lit 3 on the lamp") or not rung_summary.contains("Left 1 at the watch") or not rung_summary.contains("Stood 4 on the watch") or not rung_summary.contains("Left 2 at the relief") or not rung_summary.contains("Posted 6") or not rung_summary.contains("Left 4 at the wage") or not rung_summary.contains("Paid 10") or not rung_summary.contains("Left 19 in the loft") or not rung_summary.contains("Left 57"):
		_fail(errors, "rung summary does not name the bell: %s" % rung_summary)
	if not rung_summary.contains("Coins 2997") or not rung_summary.contains("Hired 29"):
		_fail(errors, "rung summary dropped the earlier totals: %s" % rung_summary)
	if int(rung_again.get_rung()) != int(rung.get_rung()) or int(rung_again.get_lamp_left()) != int(rung.get_lamp_left()) or int(rung_again.get_lit()) != int(rung.get_lit()) or int(rung_again.get_stood()) != int(rung.get_stood()) or int(rung_again.get_posted()) != int(rung.get_posted()) or int(rung_again.get_yard_left()) != int(rung.get_yard_left()) or int(rung_again.get_stored_salt()) != int(rung.get_stored_salt()) or String(rung_again.get_summary()) != String(rung.get_summary()):
		_fail(errors, "repeated bell paint rang %d and left lamp %d, then rang %d and left lamp %d" % [rung.get_rung(), rung.get_lamp_left(), rung_again.get_rung(), rung_again.get_lamp_left()])
	if int(late.get_rung()) != 2 or int(late.get_lamp_left()) != 1 or int(late.get_lit()) != 3 or int(late.get_stood()) != 4 or int(late.get_posted()) != 6 or int(late.get_watch_left()) != 1 or int(late.get_relief_left()) != 2 or int(late.get_wage_left()) != 4 or int(late.get_paid()) != 10 or int(late.get_loft_left()) != 19 or int(late.get_yard_left()) != 57 or int(late.get_hired()) != 29 or int(late.get_coins()) != int(rung.get_coins()) or int(late.get_stored_salt()) != int(rung.get_stored_salt()) or int(late.get_carted()) != int(rung.get_carted()) or int(late.get_shipped()) != int(rung.get_shipped()):
		_fail(errors, "painting the bell at the bell beat (rung %d lamp %d lit %d stood %d posted %d watch %d relief %d wage %d paid %d loft %d yard %d hired %d coins %d stored %d) did not match painting it early (rung %d lamp %d lit %d stood %d posted %d watch %d relief %d wage %d paid %d loft %d yard %d hired %d coins %d stored %d)" % [late.get_rung(), late.get_lamp_left(), late.get_lit(), late.get_stood(), late.get_posted(), late.get_watch_left(), late.get_relief_left(), late.get_wage_left(), late.get_paid(), late.get_loft_left(), late.get_yard_left(), late.get_hired(), late.get_coins(), late.get_stored_salt(), rung.get_rung(), rung.get_lamp_left(), rung.get_lit(), rung.get_stood(), rung.get_posted(), rung.get_watch_left(), rung.get_relief_left(), rung.get_wage_left(), rung.get_paid(), rung.get_loft_left(), rung.get_yard_left(), rung.get_hired(), rung.get_coins(), rung.get_stored_salt()])
	_assert_chain(dry_rung, errors, "dry bell", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 2)
	var dry_unpaid := int(dry_rung.get_hired()) - int(dry_rung.get_paid())
	var dry_unposted := int(dry_rung.get_paid()) - int(dry_rung.get_posted())
	var dry_unstood := int(dry_rung.get_posted()) - int(dry_rung.get_stood())
	var dry_unlit := int(dry_rung.get_stood()) - int(dry_rung.get_lit())
	if int(dry_rung.get_rung()) != 2 or int(dry_rung.get_lamp_left()) != 1 or dry_unlit != 1 or dry_unstood != 2 or dry_unposted != 2 or dry_unpaid != 2 or int(dry_rung.get_watch_left()) != 1 or int(dry_rung.get_relief_left()) != 2 or int(dry_rung.get_wage_left()) != 2 or int(dry_rung.get_gate_left()) != 2 or int(dry_rung.get_loft_left()) != 0 or int(dry_rung.get_yard_left()) != 0 or int(dry_rung.get_lit()) != 3 or int(dry_rung.get_stood()) != 4 or int(dry_rung.get_posted()) != 6:
		_fail(errors, "dry bell changed the short crew (wet %d stored %d carted %d shipped %d coins %d hired %d paid %d posted %d stood %d lit %d rung %d lamp %d unlit %d unstood %d unposted %d unpaid %d watch %d relief %d wage %d gate %d loft %d yard %d)" % [dry_rung.get_wet_haul(), dry_rung.get_stored_salt(), dry_rung.get_carted(), dry_rung.get_shipped(), dry_rung.get_coins(), dry_rung.get_hired(), dry_rung.get_paid(), dry_rung.get_posted(), dry_rung.get_stood(), dry_rung.get_lit(), dry_rung.get_rung(), dry_rung.get_lamp_left(), dry_unlit, dry_unstood, dry_unposted, dry_unpaid, dry_rung.get_watch_left(), dry_rung.get_relief_left(), dry_rung.get_wage_left(), dry_rung.get_gate_left(), dry_rung.get_loft_left(), dry_rung.get_yard_left()])
	var dry_bell_cell = plans["dry_rung"]["bell"][0]
	var dry_lamp_cell = plans["dry_rung"]["lamp"][0]
	var dry_watch_cell = plans["dry_rung"]["watch"][0]
	var dry_relief_cell = plans["dry_rung"]["relief"][0]
	var dry_wage_cell = plans["dry_rung"]["wage"][0]
	var dry_gate_cell = plans["dry_rung"]["gate"][0]
	var dry_bell_salt: Dictionary = dry_rung.get_cell_salt(int(dry_bell_cell[0]), int(dry_bell_cell[1]))
	var dry_lamp_salt: Dictionary = dry_rung.get_cell_salt(int(dry_lamp_cell[0]), int(dry_lamp_cell[1]))
	var dry_watch_salt: Dictionary = dry_rung.get_cell_salt(int(dry_watch_cell[0]), int(dry_watch_cell[1]))
	var dry_relief_salt: Dictionary = dry_rung.get_cell_salt(int(dry_relief_cell[0]), int(dry_relief_cell[1]))
	var dry_wage_salt: Dictionary = dry_rung.get_cell_salt(int(dry_wage_cell[0]), int(dry_wage_cell[1]))
	var dry_gate_salt: Dictionary = dry_rung.get_cell_salt(int(dry_gate_cell[0]), int(dry_gate_cell[1]))
	if int(dry_bell_salt.get("bell", 0)) != 2 or int(dry_lamp_salt.get("lamp", 0)) != 1 or int(dry_watch_salt.get("watch", 0)) != 1 or int(dry_relief_salt.get("relief", 0)) != 2 or int(dry_wage_salt.get("wage", 0)) != 2 or int(dry_gate_salt.get("gate", 0)) != 2:
		_fail(errors, "dry bell cell holds %s, lamp holds %s, watch holds %s, relief holds %s, wage holds %s, gate holds %s" % [dry_bell_salt.get("bell", 0), dry_lamp_salt.get("lamp", 0), dry_watch_salt.get("watch", 0), dry_relief_salt.get("relief", 0), dry_wage_salt.get("wage", 0), dry_gate_salt.get("gate", 0)])
	if not String(dry_rung.get_summary()).contains("Rung 2 on the bell") or not String(dry_rung.get_summary()).contains("Left 1 at the lamp") or not String(dry_rung.get_summary()).contains("Lit 3 on the lamp") or not String(dry_rung.get_summary()).contains("Left 1 at the watch") or not String(dry_rung.get_summary()).contains("Stood 4 on the watch") or not String(dry_rung.get_summary()).contains("Left 2 at the relief") or not String(dry_rung.get_summary()).contains("Posted 6") or not String(dry_rung.get_summary()).contains("Left 2 at the wage") or not String(dry_rung.get_summary()).contains("Paid 8") or not String(dry_rung.get_summary()).contains("Left 2 unpaid") or not String(dry_rung.get_summary()).contains("Left 0 in the yard"):
		_fail(errors, "dry bell summary does not name the cap: %s" % dry_rung.get_summary())
	_assert_pop(rung, errors, "rung plan")
	_assert_pop(rung_again, errors, "rung plan again")
	_assert_pop(late, errors, "late_rung")
	_assert_pop(dry_rung, errors, "dry_rung")
	_assert_pop(ignored, errors, "no_bell")
	_assert_pop(bare, errors, "bell_only")
	# The cap stops the bell while ticks remain and lit hires remain.
	# Hires still in the loft, hires who passed and were not paid, hires who
	# were paid but not posted, hires who were posted but not stood, and hires
	# who were stood but not lit, stay put.
	var shore = _prepare_plan(plans, "rung", errors)
	if shore == null:
		return
	var shore_guard := 0
	var shore_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + 2
	while int(shore.get_beat()) != Sim.BELLING and not shore.is_over() and shore_guard < shore_limit:
		shore.tick()
		shore_guard += 1
	if int(shore.get_beat()) != Sim.BELLING or shore.is_over():
		_fail(errors, "the lamp beat did not open a bell beat for the cap check")
		return
	if int(shore.get_ticks_until_rain()) != int(Sim.BELL_TICK):
		_fail(errors, "bell countdown started at %d, expected %d" % [shore.get_ticks_until_rain(), Sim.BELL_TICK])
	if int(shore.get_rung()) != 0 or int(shore.get_lit()) != 3 or int(shore.get_lamp_left()) != 3 or int(shore.get_stood()) != 4 or int(shore.get_watch_left()) != 1 or int(shore.get_posted()) != 6 or int(shore.get_yard_left()) != 57:
		_fail(errors, "bell opened early (rung %d lit %d lamp %d stood %d watch %d posted %d yard %d)" % [shore.get_rung(), shore.get_lit(), shore.get_lamp_left(), shore.get_stood(), shore.get_watch_left(), shore.get_posted(), shore.get_yard_left()])
	var saw_cap := false
	var ring_guard := 0
	while not shore.is_over() and ring_guard < int(Sim.BELL_TICK) + 2:
		shore.tick()
		ring_guard += 1
		if int(shore.get_rung()) == int(Sim.BELL_CAP) and int(shore.get_lamp_left()) == 1 and int(shore.get_lit()) == 3 and int(shore.get_watch_left()) == 1 and int(shore.get_stood()) == 4 and int(shore.get_relief_left()) == 2 and int(shore.get_posted()) == 6 and int(shore.get_wage_left()) == 4 and int(shore.get_paid()) == 10 and int(shore.get_loft_left()) == 19 and int(shore.get_gate_left()) == 0 and int(shore.get_yard_left()) == 57 and int(shore.get_ticks_until_rain()) > 0:
			saw_cap = true
			var ticks_left := int(shore.get_ticks_until_rain())
			shore.tick()
			if int(shore.get_rung()) != int(Sim.BELL_CAP) or int(shore.get_lamp_left()) != 1 or int(shore.get_lit()) != 3 or int(shore.get_watch_left()) != 1 or int(shore.get_stood()) != 4 or int(shore.get_relief_left()) != 2 or int(shore.get_posted()) != 6 or int(shore.get_wage_left()) != 4 or int(shore.get_loft_left()) != 19 or int(shore.get_gate_left()) != 0 or int(shore.get_yard_left()) != 57 or int(shore.get_paid()) != 10 or int(shore.get_stored_salt()) != 2997 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29:
				_fail(errors, "the bell kept ringing after the cap (rung %d lamp %d lit %d watch %d stood %d relief %d posted %d wage %d loft %d gate %d yard %d paid %d)" % [shore.get_rung(), shore.get_lamp_left(), shore.get_lit(), shore.get_watch_left(), shore.get_stood(), shore.get_relief_left(), shore.get_posted(), shore.get_wage_left(), shore.get_loft_left(), shore.get_gate_left(), shore.get_yard_left(), shore.get_paid()])
			elif not shore.is_over() and int(shore.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the bell beat did not spend a tick after the cap")
			break
	if not saw_cap:
		_fail(errors, "the bell did not stop at %d while ticks remained (rung %d lamp %d lit %d watch %d stood %d relief %d posted %d wage %d loft %d yard %d ticks %d)" % [Sim.BELL_CAP, shore.get_rung(), shore.get_lamp_left(), shore.get_lit(), shore.get_watch_left(), shore.get_stood(), shore.get_relief_left(), shore.get_posted(), shore.get_wage_left(), shore.get_loft_left(), shore.get_yard_left(), shore.get_ticks_until_rain()])
	# Dry pans light 3 and the cap still rings only 2. The 1 who was lit and
	# not rung stays on the lamp. The 1 who was stood and not lit stays on the
	# watch. The 2 who were posted and not stood stay on the relief. The 2 who
	# were paid and not posted stay on the wage. The 2 who passed and were not
	# paid stay on the gate. The yard stays empty.
	var short = _prepare_plan(plans, "dry_rung", errors)
	if short == null:
		return
	var short_guard := 0
	while int(short.get_beat()) != Sim.BELLING and not short.is_over() and short_guard < shore_limit:
		short.tick()
		short_guard += 1
	if int(short.get_beat()) != Sim.BELLING or short.is_over():
		_fail(errors, "the lamp beat did not open a bell beat for the dry cap")
		return
	var saw_short := false
	var short_steps := 0
	while not short.is_over() and short_steps < int(Sim.BELL_TICK) + 2:
		short.tick()
		short_steps += 1
		if int(short.get_rung()) == int(Sim.BELL_CAP) and int(short.get_lamp_left()) == 1 and int(short.get_lit()) == 3 and int(short.get_watch_left()) == 1 and int(short.get_stood()) == 4 and int(short.get_relief_left()) == 2 and int(short.get_posted()) == 6 and int(short.get_wage_left()) == 2 and int(short.get_gate_left()) == 2 and int(short.get_paid()) == 8 and int(short.get_yard_left()) == 0 and int(short.get_loft_left()) == 0 and int(short.get_ticks_until_rain()) > 0:
			saw_short = true
			var short_ticks := int(short.get_ticks_until_rain())
			short.tick()
			if int(short.get_rung()) != 2 or int(short.get_lamp_left()) != 1 or int(short.get_watch_left()) != 1 or int(short.get_relief_left()) != 2 or int(short.get_wage_left()) != 2 or int(short.get_gate_left()) != 2 or int(short.get_yard_left()) != 0 or int(short.get_lit()) != 3 or int(short.get_stood()) != 4 or int(short.get_posted()) != 6 or int(short.get_paid()) != 8:
				_fail(errors, "the bell rang an unlit hire or passed the cap (rung %d lamp %d watch %d relief %d wage %d gate %d yard %d lit %d stood %d posted %d paid %d)" % [short.get_rung(), short.get_lamp_left(), short.get_watch_left(), short.get_relief_left(), short.get_wage_left(), short.get_gate_left(), short.get_yard_left(), short.get_lit(), short.get_stood(), short.get_posted(), short.get_paid()])
			elif not short.is_over() and int(short.get_ticks_until_rain()) >= short_ticks:
				_fail(errors, "the bell beat did not spend a tick after the dry cap")
			break
	if not saw_short:
		_fail(errors, "dry bell did not stop at 2 with unlit hires left (rung %d lamp %d watch %d relief %d wage %d gate %d yard %d lit %d stood %d posted %d paid %d ticks %d)" % [short.get_rung(), short.get_lamp_left(), short.get_watch_left(), short.get_relief_left(), short.get_wage_left(), short.get_gate_left(), short.get_yard_left(), short.get_lit(), short.get_stood(), short.get_posted(), short.get_paid(), short.get_ticks_until_rain()])
	print("rung %d left lamp %d unlit %d unstood %d unposted %d unpaid %d; dry rung %d left lamp %d unlit %d unstood %d unposted %d unpaid %d; no bell rang %d left lamp %d; bell without lamp rang %d" % [rung.get_rung(), rung.get_lamp_left(), rung_unlit, rung_unstood, rung_unposted, rung_unpaid, dry_rung.get_rung(), dry_rung.get_lamp_left(), dry_unlit, dry_unstood, dry_unposted, dry_unpaid, ignored.get_rung(), ignored.get_lamp_left(), bare.get_rung()])
func _expect_yard(sim, errors: Array) -> void:
	if sim == null:
		_fail(errors, "yard plan did not run")
		return
	if not sim.is_over():
		_fail(errors, "yard plan did not finish")
	if int(sim.get_banked()) < Sim.QUOTA:
		_fail(errors, "banked %d, quota is %d" % [int(sim.get_banked()), Sim.QUOTA])
	if int(sim.get_purse()) != 0:
		_fail(errors, "purse still holds %d after the yard" % int(sim.get_purse()))
	if int(sim.get_banked()) != int(sim.get_coins()):
		_fail(errors, "banked %d of the earned %d" % [int(sim.get_banked()), int(sim.get_coins())])


func _expect_cart(sim, errors: Array) -> void:
	if sim == null:
		_fail(errors, "cart plan did not run")
		return
	if not sim.is_over():
		_fail(errors, "cart plan did not finish")
	if int(sim.get_carted()) < Sim.QUOTA:
		_fail(errors, "carted %d, quota is %d" % [int(sim.get_carted()), Sim.QUOTA])
	if int(sim.get_bank_left()) != 0:
		_fail(errors, "bank left %d after the cart" % int(sim.get_bank_left()))


func _expect_ship(sim, errors: Array) -> void:
	if sim == null:
		_fail(errors, "ship plan did not run")
		return
	if not sim.is_over():
		_fail(errors, "ship plan did not finish")
	if int(sim.get_shipped()) < Sim.QUOTA:
		_fail(errors, "shipped %d, quota is %d" % [int(sim.get_shipped()), Sim.QUOTA])
	if int(sim.get_crib_salt()) != 0:
		_fail(errors, "crib still holds %d after the ship beat" % int(sim.get_crib_salt()))
	if int(sim.get_shipped()) != int(sim.get_carted()):
		_fail(errors, "shipped %d of the carted %d" % [int(sim.get_shipped()), int(sim.get_carted())])
func _expect_market(sim, errors: Array) -> void:
	if sim == null:
		_fail(errors, "market plan did not run")
		return
	if not sim.is_over():
		_fail(errors, "market plan did not finish")
	if int(sim.get_coins()) < Sim.QUOTA:
		_fail(errors, "coined %d, quota is %d" % [int(sim.get_coins()), Sim.QUOTA])
	if int(sim.get_ship_salt()) != 0:
		_fail(errors, "ship still holds %d after the market" % int(sim.get_ship_salt()))
	if int(sim.get_coins()) != int(sim.get_shipped()):
		_fail(errors, "coined %d of the shipped %d" % [int(sim.get_coins()), int(sim.get_shipped())])
func _prepare_plan(plans: Dictionary, plan_name: String, errors: Array):
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
	_apply_marks(sim, plan, errors)
	if errors.size() > before:
		return null
	return sim


func _run_plan(plans: Dictionary, plan_name: String, errors: Array):
	var sim = _prepare_plan(plans, plan_name, errors)
	if sim == null:
		return null
	var plan: Dictionary = plans[plan_name]
	if plan.has("after_first_rain"):
		var guard := 0
		var limit := int(Sim.RAIN_TICK) + 2
		while int(sim.get_season()) == Sim.WET and not sim.is_over() and guard < limit:
			sim.tick()
			guard += 1
		if int(sim.get_season()) != Sim.DRY or sim.is_over():
			_fail(errors, "%s did not open a dry season after the first rain" % plan_name)
			return null
		var late_before := errors.size()
		_apply_marks(sim, plan["after_first_rain"], errors)
		if errors.size() > late_before:
			return null
	if plan.has("after_second_rain"):
		var cart_guard := 0
		var cart_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + 2
		while int(sim.get_beat()) != Sim.CART and not sim.is_over() and cart_guard < cart_limit:
			sim.tick()
			cart_guard += 1
		if int(sim.get_beat()) != Sim.CART or sim.is_over():
			_fail(errors, "%s did not open the cart beat after the second rain" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.CART_TICK):
			_fail(errors, "%s cart countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.CART_TICK,
			])
			return null
		var cart_before := errors.size()
		_apply_marks(sim, plan["after_second_rain"], errors)
		if errors.size() > cart_before:
			return null
	if plan.has("after_cart"):
		var ship_guard := 0
		var ship_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + 2
		while int(sim.get_beat()) != Sim.SHIPPING and not sim.is_over() and ship_guard < ship_limit:
			sim.tick()
			ship_guard += 1
		if int(sim.get_beat()) != Sim.SHIPPING or sim.is_over():
			_fail(errors, "%s did not open the ship beat after the cart" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.SHIP_TICK):
			_fail(errors, "%s ship countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.SHIP_TICK,
			])
			return null
		var ship_before := errors.size()
		_apply_marks(sim, plan["after_cart"], errors)
		if errors.size() > ship_before:
			return null
	if plan.has("after_ship"):
		var market_guard := 0
		var market_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + 2
		while int(sim.get_beat()) != Sim.MARKET and not sim.is_over() and market_guard < market_limit:
			sim.tick()
			market_guard += 1
		if int(sim.get_beat()) != Sim.MARKET or sim.is_over():
			_fail(errors, "%s did not open the market beat after the ship" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.MARKET_TICK):
			_fail(errors, "%s market countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.MARKET_TICK,
			])
			return null
		var market_before := errors.size()
		_apply_marks(sim, plan["after_ship"], errors)
		if errors.size() > market_before:
			return null
	if plan.has("after_market"):
		var yard_guard := 0
		var yard_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + 2
		while int(sim.get_beat()) != Sim.YARDING and not sim.is_over() and yard_guard < yard_limit:
			sim.tick()
			yard_guard += 1
		if int(sim.get_beat()) != Sim.YARDING or sim.is_over():
			_fail(errors, "%s did not open the yard beat after the market" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.YARD_TICK):
			_fail(errors, "%s yard countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.YARD_TICK,
			])
			return null
		var yard_before := errors.size()
		_apply_marks(sim, plan["after_market"], errors)
		if errors.size() > yard_before:
			return null
	if plan.has("after_yard"):
		var bunk_guard := 0
		var bunk_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + 2
		while int(sim.get_beat()) != Sim.BUNKING and not sim.is_over() and bunk_guard < bunk_limit:
			sim.tick()
			bunk_guard += 1
		if int(sim.get_beat()) != Sim.BUNKING or sim.is_over():
			_fail(errors, "%s did not open the bunk beat after the yard" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.BUNK_TICK):
			_fail(errors, "%s bunk countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.BUNK_TICK,
			])
			return null
		var bunk_before := errors.size()
		_apply_marks(sim, plan["after_yard"], errors)
		if errors.size() > bunk_before:
			return null
	if plan.has("after_bunk"):
		var loft_guard := 0
		var loft_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + 2
		while int(sim.get_beat()) != Sim.LOFTING and not sim.is_over() and loft_guard < loft_limit:
			sim.tick()
			loft_guard += 1
		if int(sim.get_beat()) != Sim.LOFTING or sim.is_over():
			_fail(errors, "%s did not open the loft beat after the bunk" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.LOFT_TICK):
			_fail(errors, "%s loft countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.LOFT_TICK,
			])
			return null
		var loft_before := errors.size()
		_apply_marks(sim, plan["after_bunk"], errors)
		if errors.size() > loft_before:
			return null
	if plan.has("after_loft"):
		var gate_guard := 0
		var gate_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + 2
		while int(sim.get_beat()) != Sim.GATING and not sim.is_over() and gate_guard < gate_limit:
			sim.tick()
			gate_guard += 1
		if int(sim.get_beat()) != Sim.GATING or sim.is_over():
			_fail(errors, "%s did not open the gate beat after the loft" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.GATE_TICK):
			_fail(errors, "%s gate countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.GATE_TICK,
			])
			return null
		var gate_before := errors.size()
		_apply_marks(sim, plan["after_loft"], errors)
		if errors.size() > gate_before:
			return null
	if plan.has("after_gate"):
		var wage_guard := 0
		var wage_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + 2
		while int(sim.get_beat()) != Sim.WAGING and not sim.is_over() and wage_guard < wage_limit:
			sim.tick()
			wage_guard += 1
		if int(sim.get_beat()) != Sim.WAGING or sim.is_over():
			_fail(errors, "%s did not open the wage beat after the gate" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.WAGE_TICK):
			_fail(errors, "%s wage countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.WAGE_TICK,
			])
			return null
		var wage_before := errors.size()
		_apply_marks(sim, plan["after_gate"], errors)
		if errors.size() > wage_before:
			return null
	if plan.has("after_wage"):
		var relief_guard := 0
		var relief_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + 2
		while int(sim.get_beat()) != Sim.RELIEVING and not sim.is_over() and relief_guard < relief_limit:
			sim.tick()
			relief_guard += 1
		if int(sim.get_beat()) != Sim.RELIEVING or sim.is_over():
			_fail(errors, "%s did not open the relief beat after the wage" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.RELIEF_TICK):
			_fail(errors, "%s relief countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.RELIEF_TICK,
			])
			return null
		var relief_before := errors.size()
		_apply_marks(sim, plan["after_wage"], errors)
		if errors.size() > relief_before:
			return null
	if plan.has("after_relief"):
		var watch_guard := 0
		var watch_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + 2
		while int(sim.get_beat()) != Sim.WATCHING and not sim.is_over() and watch_guard < watch_limit:
			sim.tick()
			watch_guard += 1
		if int(sim.get_beat()) != Sim.WATCHING or sim.is_over():
			_fail(errors, "%s did not open the watch beat after the relief" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.WATCH_TICK):
			_fail(errors, "%s watch countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.WATCH_TICK,
			])
			return null
		var watch_before := errors.size()
		_apply_marks(sim, plan["after_relief"], errors)
		if errors.size() > watch_before:
			return null
	if plan.has("after_watch"):
		var lamp_guard := 0
		var lamp_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + 2
		while int(sim.get_beat()) != Sim.LAMPING and not sim.is_over() and lamp_guard < lamp_limit:
			sim.tick()
			lamp_guard += 1
		if int(sim.get_beat()) != Sim.LAMPING or sim.is_over():
			_fail(errors, "%s did not open the lamp beat after the watch" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.LAMP_TICK):
			_fail(errors, "%s lamp countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.LAMP_TICK,
			])
			return null
		var lamp_before := errors.size()
		_apply_marks(sim, plan["after_watch"], errors)
		if errors.size() > lamp_before:
			return null
	if plan.has("after_lamp"):
		var bell_guard := 0
		var bell_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + 2
		while int(sim.get_beat()) != Sim.BELLING and not sim.is_over() and bell_guard < bell_limit:
			sim.tick()
			bell_guard += 1
		if int(sim.get_beat()) != Sim.BELLING or sim.is_over():
			_fail(errors, "%s did not open the bell beat after the lamp" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.BELL_TICK):
			_fail(errors, "%s bell countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.BELL_TICK,
			])
			return null
		var bell_before := errors.size()
		_apply_marks(sim, plan["after_lamp"], errors)
		if errors.size() > bell_before:
			return null
	sim.run_until_rain()
	return sim


func _apply_marks(sim, plan: Dictionary, errors: Array) -> void:
	if plan.has("rake"):
		_apply_cells(sim, plan["rake"], Sim.RAKE, errors)
	if plan.has("stack"):
		_apply_cells(sim, plan["stack"], Sim.STACK, errors)
	if plan.has("cover"):
		_apply_cells(sim, plan["cover"], Sim.COVER, errors)
	if plan.has("trail"):
		_apply_cells(sim, plan["trail"], Sim.TRAIL, errors)
	if plan.has("pan"):
		_apply_cells(sim, plan["pan"], Sim.PAN, errors)
	if plan.has("crib"):
		_apply_cells(sim, plan["crib"], Sim.CRIB, errors)
	if plan.has("ship"):
		_apply_cells(sim, plan["ship"], Sim.SHIP, errors)
	if plan.has("stall"):
		_apply_cells(sim, plan["stall"], Sim.STALL, errors)
	if plan.has("yard"):
		_apply_cells(sim, plan["yard"], Sim.YARD, errors)
	if plan.has("bunk"):
		_apply_cells(sim, plan["bunk"], Sim.BUNK, errors)
	if plan.has("loft"):
		_apply_cells(sim, plan["loft"], Sim.LOFT, errors)
	if plan.has("gate"):
		_apply_cells(sim, plan["gate"], Sim.GATE, errors)
	if plan.has("wage"):
		_apply_cells(sim, plan["wage"], Sim.WAGE, errors)
	if plan.has("relief"):
		_apply_cells(sim, plan["relief"], Sim.RELIEF, errors)
	if plan.has("watch"):
		_apply_cells(sim, plan["watch"], Sim.WATCH, errors)
	if plan.has("lamp"):
		_apply_cells(sim, plan["lamp"], Sim.LAMP, errors)
	if plan.has("bell"):
		_apply_cells(sim, plan["bell"], Sim.BELL, errors)
	if plan.has("rake_rect"):
		_apply_rect(sim, plan["rake_rect"], Sim.RAKE, errors)


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
