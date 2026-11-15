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
	for plan_name in ["winning", "all_rake", "dry_pans", "continued", "late_pans", "no_crib", "carted", "late_crib", "dry_crib", "no_ship", "shipped", "late_ship", "dry_ship"]:
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
		if int(first.get_wet_haul()) != int(second.get_wet_haul()):
			_fail(errors, "%s wet hauls differed" % plan_name)
		if int(first.get_carted()) != int(second.get_carted()):
			_fail(errors, "%s cart totals differed" % plan_name)
		if int(first.get_shipped()) != int(second.get_shipped()):
			_fail(errors, "%s ship totals differed" % plan_name)
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
	node._on_key(KEY_R)
	if int(node.sim.get_paint(9, 5)) != Sim.EMPTY or int(node.sim.get_paint(8, 5)) != Sim.EMPTY or int(node.sim.get_paint(8, 6)) != Sim.EMPTY or int(node.sim.get_paint(7, 6)) != Sim.EMPTY:
		_fail(errors, "restart scenario did not clear the marks")
	if int(node.sim.get_season()) != Sim.WET or int(node.sim.get_wet_haul()) != 0 or int(node.sim.get_beat()) != Sim.WET or int(node.sim.get_carted()) != 0 or int(node.sim.get_shipped()) != 0:
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
	if not opening.is_over():
		_fail(errors, "ship beat did not end")
	print("ship loaded %d; winning wet %d carted %d; dry stored %d; carted %d" % [
		loaded.get_shipped(), won.get_wet_haul(), parked.get_carted(), dry.get_stored_salt(), parked.get_carted(),
	])
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
