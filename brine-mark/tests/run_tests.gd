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
	for plan_name in ["winning", "all_rake", "dry_pans", "continued", "late_pans", "no_crib", "carted", "late_crib", "dry_crib", "no_ship", "shipped", "late_ship", "dry_ship", "no_stall", "sold", "late_sold", "dry_sold", "no_yard", "banked", "late_banked", "dry_banked", "no_bunk", "hired", "late_hired", "dry_hired", "no_loft", "lofted", "late_lofted", "dry_lofted"]:
		var before := errors.size()
		var first = _run_plan(plans, plan_name, errors)
		var second = _run_plan(plans, plan_name, errors)
		if first == null or second == null:
			if errors.size() == before:
				_fail(errors, "%s determinism run did not start" % plan_name)
			return
		var a := int(first.get_stored_salt())
		var b := int(second.get_stored_salt())
		print("determinism %s stored %d and %d coins %d banked %d hired %d left %d lofted %d" % [plan_name, a, b, int(first.get_coins()), int(first.get_banked()), int(first.get_hired()), int(first.get_yard_left()), int(first.get_lofted())])
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
	node._on_key(KEY_R)
	if int(node.sim.get_paint(9, 5)) != Sim.EMPTY or int(node.sim.get_paint(8, 5)) != Sim.EMPTY or int(node.sim.get_paint(8, 6)) != Sim.EMPTY or int(node.sim.get_paint(7, 6)) != Sim.EMPTY or int(node.sim.get_paint(7, 5)) != Sim.EMPTY or int(node.sim.get_paint(7, 4)) != Sim.EMPTY or int(node.sim.get_paint(7, 3)) != Sim.EMPTY or int(node.sim.get_paint(7, 2)) != Sim.EMPTY:
		_fail(errors, "restart scenario did not clear the marks")
	if int(node.sim.get_season()) != Sim.WET or int(node.sim.get_wet_haul()) != 0 or int(node.sim.get_beat()) != Sim.WET or int(node.sim.get_carted()) != 0 or int(node.sim.get_shipped()) != 0 or int(node.sim.get_coins()) != 0 or int(node.sim.get_banked()) != 0 or int(node.sim.get_hired()) != 0 or int(node.sim.get_lofted()) != 0:
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
	if not opening.is_over():
		_fail(errors, "loft beat did not end")
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
