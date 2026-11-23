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
	_test_horn(errors)
	_test_flag(errors)
	_test_banner(errors)
	_test_pennant(errors)
	_test_standard(errors)
	_test_jack(errors)
	_test_ensign(errors)
	_test_burgee(errors)
	_test_cornet(errors)
	_test_guidon(errors)
	_test_fanion(errors)
	_test_pennon(errors)
	_test_gonfalon(errors)
	_test_oriflamme(errors)
	_test_vexillum(errors)
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
	for plan_name in ["winning", "all_rake", "dry_pans", "continued", "late_pans", "no_crib", "carted", "late_crib", "dry_crib", "no_ship", "shipped", "late_ship", "dry_ship", "no_stall", "sold", "late_sold", "dry_sold", "no_yard", "banked", "late_banked", "dry_banked", "no_bunk", "hired", "late_hired", "dry_hired", "no_loft", "lofted", "late_lofted", "dry_lofted", "no_gate", "gated", "late_gated", "dry_gated", "no_wage", "paid", "late_paid", "dry_paid", "no_relief", "posted", "late_posted", "dry_posted", "no_watch", "stood", "late_stood", "dry_stood", "watch_only", "no_lamp", "lit", "late_lit", "dry_lit", "lamp_only", "no_bell", "rung", "late_rung", "dry_rung", "bell_only", "no_horn", "sounded", "late_sounded", "dry_sounded", "horn_only", "no_flag", "raised", "late_raised", "dry_raised", "flag_only", "no_banner", "hoisted", "late_hoisted", "dry_hoisted", "banner_only", "no_pennant", "flown", "late_flown", "dry_flown", "pennant_only", "no_standard", "carried", "late_carried", "dry_carried", "standard_only", "no_jack", "shown", "late_shown", "dry_shown", "jack_only", "no_ensign", "broken", "late_broken", "dry_broken", "ensign_only", "no_burgee", "struck", "late_struck", "dry_struck", "burgee_only", "no_cornet", "dipped", "late_dipped", "dry_dipped", "cornet_only", "no_guidon", "saluted", "late_saluted", "dry_saluted", "guidon_only", "no_fanion", "presented", "late_presented", "dry_presented", "fanion_only", "furled", "late_furled", "dry_furled", "pennon_only", "gonfalon", "late_gonfalon", "dry_gonfalon", "gonfalon_only", "oriflamme", "late_oriflamme", "dry_oriflamme", "oriflamme_only", "vexillum", "late_vexillum", "dry_vexillum", "vexillum_only"]:
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
		if int(first.get_sounded()) != int(second.get_sounded()) or int(first.get_bell_left()) != int(second.get_bell_left()):
			_fail(errors, "%s horn runs differed (%d unsounded %d, and %d unsounded %d)" % [
				plan_name, first.get_sounded(), first.get_bell_left(), second.get_sounded(), second.get_bell_left(),
			])
		if int(first.get_raised()) != int(second.get_raised()) or int(first.get_horn_left()) != int(second.get_horn_left()):
			_fail(errors, "%s flag runs differed (%d unraised %d, and %d unraised %d)" % [
				plan_name, first.get_raised(), first.get_horn_left(), second.get_raised(), second.get_horn_left(),
			])
		if int(first.get_hoisted()) != int(second.get_hoisted()) or int(first.get_flag_left()) != int(second.get_flag_left()):
			_fail(errors, "%s banner runs differed (%d unhoisted %d, and %d unhoisted %d)" % [
				plan_name, first.get_hoisted(), first.get_flag_left(), second.get_hoisted(), second.get_flag_left(),
			])
		if int(first.get_flown()) != int(second.get_flown()) or int(first.get_banner_left()) != int(second.get_banner_left()):
			_fail(errors, "%s pennant runs differed (%d unflown %d, and %d unflown %d)" % [
				plan_name, first.get_flown(), first.get_banner_left(), second.get_flown(), second.get_banner_left(),
			])
		if int(first.get_carried()) != int(second.get_carried()) or int(first.get_pennant_left()) != int(second.get_pennant_left()):
			_fail(errors, "%s standard runs differed (%d uncarried %d, and %d uncarried %d)" % [
				plan_name, first.get_carried(), first.get_pennant_left(), second.get_carried(), second.get_pennant_left(),
			])
		if int(first.get_shown()) != int(second.get_shown()) or int(first.get_standard_left()) != int(second.get_standard_left()):
			_fail(errors, "%s jack runs differed (%d unshown %d, and %d unshown %d)" % [
				plan_name, first.get_shown(), first.get_standard_left(), second.get_shown(), second.get_standard_left(),
			])
		if int(first.get_broken()) != int(second.get_broken()) or int(first.get_jack_left()) != int(second.get_jack_left()):
			_fail(errors, "%s ensign runs differed (%d unbroken %d, and %d unbroken %d)" % [
				plan_name, first.get_broken(), first.get_jack_left(), second.get_broken(), second.get_jack_left(),
			])
		if int(first.get_struck()) != int(second.get_struck()) or int(first.get_ensign_left()) != int(second.get_ensign_left()):
			_fail(errors, "%s burgee runs differed (%d unstruck %d, and %d unstruck %d)" % [
				plan_name, first.get_struck(), first.get_ensign_left(), second.get_struck(), second.get_ensign_left(),
			])
		if int(first.get_dipped()) != int(second.get_dipped()) or int(first.get_burgee_left()) != int(second.get_burgee_left()):
			_fail(errors, "%s cornet runs differed (%d undipped %d, and %d undipped %d)" % [
				plan_name, first.get_dipped(), first.get_burgee_left(), second.get_dipped(), second.get_burgee_left(),
			])
		if int(first.get_saluted()) != int(second.get_saluted()) or int(first.get_cornet_left()) != int(second.get_cornet_left()):
			_fail(errors, "%s guidon runs differed (%d unsaluted %d, and %d unsaluted %d)" % [
				plan_name, first.get_saluted(), first.get_cornet_left(), second.get_saluted(), second.get_cornet_left(),
			])
		if int(first.get_presented()) != int(second.get_presented()) or int(first.get_guidon_left()) != int(second.get_guidon_left()):
			_fail(errors, "%s fanion runs differed (%d unpresented %d, and %d unpresented %d)" % [
				plan_name, first.get_presented(), first.get_guidon_left(), second.get_presented(), second.get_guidon_left(),
			])
		if int(first.get_furled()) != int(second.get_furled()) or int(first.get_fanion_left()) != int(second.get_fanion_left()):
			_fail(errors, "%s pennon runs differed (%d unfurled %d, and %d unfurled %d)" % [
				plan_name, first.get_furled(), first.get_fanion_left(), second.get_furled(), second.get_fanion_left(),
			])
		if int(first.get_gonfalon_dipped()) != int(second.get_gonfalon_dipped()) or int(first.get_pennon_left()) != int(second.get_pennon_left()):
			_fail(errors, "%s gonfalon runs differed (%d undipped %d, and %d undipped %d)" % [
				plan_name, first.get_gonfalon_dipped(), first.get_pennon_left(), second.get_gonfalon_dipped(), second.get_pennon_left(),
			])
		if int(first.get_oriflamme_lowered()) != int(second.get_oriflamme_lowered()) or int(first.get_gonfalon_left()) != int(second.get_gonfalon_left()):
			_fail(errors, "%s oriflamme runs differed (%d unlowered %d, and %d unlowered %d)" % [
				plan_name, first.get_oriflamme_lowered(), first.get_gonfalon_left(), second.get_oriflamme_lowered(), second.get_gonfalon_left(),
			])
		if int(first.get_vexillum_housed()) != int(second.get_vexillum_housed()) or int(first.get_oriflamme_left()) != int(second.get_oriflamme_left()):
			_fail(errors, "%s vexillum runs differed (%d unhoused %d, and %d unhoused %d)" % [
				plan_name, first.get_vexillum_housed(), first.get_oriflamme_left(), second.get_vexillum_housed(), second.get_oriflamme_left(),
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
	node._on_key(KEY_J)
	if not String(node.mode_label.text).contains("Horn"):
		_fail(errors, "horn mark was not named")
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(7, -5)) != Sim.HORN:
		_fail(errors, "keyboard cursor did not paint a horn")
	node._on_key(KEY_K)
	if not String(node.mode_label.text).contains("Flag"):
		_fail(errors, "flag mark was not named")
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(7, -6)) != Sim.FLAG:
		_fail(errors, "keyboard cursor did not paint a flag")
	node._on_key(KEY_L)
	if not String(node.mode_label.text).contains("Banner"):
		_fail(errors, "banner mark was not named")
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(7, -7)) != Sim.BANNER:
		_fail(errors, "keyboard cursor did not paint a banner")
	node._on_key(KEY_M)
	if not String(node.mode_label.text).contains("Pennant"):
		_fail(errors, "pennant mark was not named")
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(7, -8)) == Sim.PENNANT:
		_fail(errors, "pennant painted off its cell")
	for _step in 7:
		node._on_key(KEY_RIGHT)
	for _step in 3:
		node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -11)) != Sim.PENNANT:
		_fail(errors, "keyboard cursor did not paint a pennant at 14,-11")
	node._on_key(KEY_L)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -11)) != Sim.PENNANT:
		_fail(errors, "the pennant cell accepted a banner")
	node._on_key(KEY_N)
	if not String(node.mode_label.text).contains("Standard"):
		_fail(errors, "standard mark was not named")
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -12)) != Sim.STANDARD:
		_fail(errors, "keyboard cursor did not paint a standard at 14,-12")
	node._on_key(KEY_M)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -12)) != Sim.STANDARD:
		_fail(errors, "the standard cell accepted a pennant")
	node._on_key(KEY_O)
	if not String(node.mode_label.text).contains("Jack"):
		_fail(errors, "jack mark was not named")
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -13)) != Sim.JACK:
		_fail(errors, "keyboard cursor did not paint a jack at 14,-13")
	node._on_key(KEY_N)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -13)) != Sim.JACK:
		_fail(errors, "the jack cell accepted a standard")
	node._on_key(KEY_DOWN)
	node._on_key(KEY_O)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -12)) != Sim.STANDARD:
		_fail(errors, "the standard cell accepted a jack")
	node._on_key(KEY_P)
	if not String(node.mode_label.text).contains("Ensign"):
		_fail(errors, "ensign mark was not named")
	var ensign_button: Button = null
	var jack_button: Button = null
	for entry in node.mode_buttons:
		if int(entry["mode"]) == Sim.ENSIGN:
			ensign_button = entry["button"]
		elif int(entry["mode"]) == Sim.JACK:
			jack_button = entry["button"]
	if ensign_button == null or jack_button == null:
		_fail(errors, "ensign button is missing beside the jack")
	elif not String(ensign_button.text).contains("Ensign") or not String(jack_button.text).contains("Jack"):
		_fail(errors, "ensign button is not labeled beside the jack")
	elif ensign_button.get_parent() != jack_button.get_parent() or ensign_button.get_index() != jack_button.get_index() + 1:
		_fail(errors, "ensign button does not sit beside the jack")
	else:
		var ensign_style := ensign_button.get_theme_stylebox("normal") as StyleBoxFlat
		if ensign_style == null or ensign_style.get_border_width(SIDE_LEFT) != 3 or ensign_style.border_color != Color("f0c14a"):
			_fail(errors, "selected ensign has no gold outline")
	node._on_key(KEY_UP)
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -14)) != Sim.ENSIGN:
		_fail(errors, "keyboard cursor did not paint an ensign at 14,-14")
	node._on_key(KEY_O)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -14)) != Sim.ENSIGN:
		_fail(errors, "the ensign cell accepted a jack")
	node._on_key(KEY_DOWN)
	node._on_key(KEY_P)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -13)) != Sim.JACK:
		_fail(errors, "the jack cell accepted an ensign")
	node._on_key(KEY_Q)
	if not String(node.mode_label.text).contains("Burgee"):
		_fail(errors, "burgee mark was not named")
	var burgee_button: Button = null
	ensign_button = null
	for entry in node.mode_buttons:
		if int(entry["mode"]) == Sim.BURGEE:
			burgee_button = entry["button"]
		elif int(entry["mode"]) == Sim.ENSIGN:
			ensign_button = entry["button"]
	if burgee_button == null or ensign_button == null:
		_fail(errors, "burgee button is missing beside the ensign")
	elif not String(burgee_button.text).contains("Burgee") or not String(ensign_button.text).contains("Ensign"):
		_fail(errors, "burgee button is not labeled beside the ensign")
	elif burgee_button.get_parent() != ensign_button.get_parent() or burgee_button.get_index() != ensign_button.get_index() + 1:
		_fail(errors, "burgee button does not sit beside the ensign")
	else:
		var burgee_style := burgee_button.get_theme_stylebox("normal") as StyleBoxFlat
		if burgee_style == null or burgee_style.get_border_width(SIDE_LEFT) != 3 or burgee_style.border_color != Color("f0c14a"):
			_fail(errors, "selected burgee has no gold outline")
	node._on_key(KEY_UP)
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -15)) != Sim.BURGEE:
		_fail(errors, "keyboard cursor did not paint a burgee at 14,-15")
	node._on_key(KEY_P)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -15)) != Sim.BURGEE:
		_fail(errors, "the burgee cell accepted an ensign")
	node._on_key(KEY_DOWN)
	node._on_key(KEY_Q)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -14)) != Sim.ENSIGN:
		_fail(errors, "the ensign cell accepted a burgee")
	node._on_key(KEY_T)
	if not String(node.mode_label.text).contains("Cornet"):
		_fail(errors, "cornet mark was not named")
	var cornet_button: Button = null
	burgee_button = null
	for entry in node.mode_buttons:
		if int(entry["mode"]) == Sim.CORNET:
			cornet_button = entry["button"]
		elif int(entry["mode"]) == Sim.BURGEE:
			burgee_button = entry["button"]
	if cornet_button == null or burgee_button == null:
		_fail(errors, "cornet button is missing beside the burgee")
	elif not String(cornet_button.text).contains("Cornet") or not String(burgee_button.text).contains("Burgee"):
		_fail(errors, "cornet button is not labeled beside the burgee")
	elif cornet_button.get_parent() != burgee_button.get_parent() or cornet_button.get_index() != burgee_button.get_index() + 1:
		_fail(errors, "cornet button does not sit beside the burgee")
	else:
		var cornet_style := cornet_button.get_theme_stylebox("normal") as StyleBoxFlat
		if cornet_style == null or cornet_style.get_border_width(SIDE_LEFT) != 3 or cornet_style.border_color != Color("f0c14a"):
			_fail(errors, "selected cornet has no gold outline")
	node._on_key(KEY_UP)
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -16)) != Sim.CORNET:
		_fail(errors, "keyboard cursor did not paint a cornet at 14,-16")
	node._on_key(KEY_Q)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -16)) != Sim.CORNET:
		_fail(errors, "the cornet cell accepted a burgee")
	node._on_key(KEY_DOWN)
	node._on_key(KEY_T)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -15)) != Sim.BURGEE:
		_fail(errors, "the burgee cell accepted a cornet")
	node._on_key(KEY_U)
	if not String(node.mode_label.text).contains("Guidon"):
		_fail(errors, "guidon mark was not named")
	var guidon_button: Button = null
	cornet_button = null
	for entry in node.mode_buttons:
		if int(entry["mode"]) == Sim.GUIDON:
			guidon_button = entry["button"]
		elif int(entry["mode"]) == Sim.CORNET:
			cornet_button = entry["button"]
	if guidon_button == null or cornet_button == null:
		_fail(errors, "guidon button is missing beside the cornet")
	elif not String(guidon_button.text).contains("Guidon") or not String(cornet_button.text).contains("Cornet"):
		_fail(errors, "guidon button is not labeled beside the cornet")
	elif guidon_button.get_parent() != cornet_button.get_parent() or guidon_button.get_index() != cornet_button.get_index() + 1:
		_fail(errors, "guidon button does not sit beside the cornet")
	else:
		var guidon_style := guidon_button.get_theme_stylebox("normal") as StyleBoxFlat
		if guidon_style == null or guidon_style.get_border_width(SIDE_LEFT) != 3 or guidon_style.border_color != Color("f0c14a"):
			_fail(errors, "selected guidon has no gold outline")
	node._on_key(KEY_UP)
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -17)) != Sim.GUIDON:
		_fail(errors, "keyboard cursor did not paint a guidon at 14,-17")
	node._on_key(KEY_T)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -17)) != Sim.GUIDON:
		_fail(errors, "the guidon cell accepted a cornet")
	node._on_key(KEY_DOWN)
	node._on_key(KEY_U)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -16)) != Sim.CORNET:
		_fail(errors, "the cornet cell accepted a guidon")
	node._on_key(KEY_V)
	if not String(node.mode_label.text).contains("Fanion"):
		_fail(errors, "fanion mark was not named")
	var fanion_button: Button = null
	guidon_button = null
	for entry in node.mode_buttons:
		if int(entry["mode"]) == Sim.FANION:
			fanion_button = entry["button"]
		elif int(entry["mode"]) == Sim.GUIDON:
			guidon_button = entry["button"]
	if fanion_button == null or guidon_button == null:
		_fail(errors, "fanion button is missing beside the guidon")
	elif not String(fanion_button.text).contains("Fanion") or not String(guidon_button.text).contains("Guidon"):
		_fail(errors, "fanion button is not labeled beside the guidon")
	elif fanion_button.get_parent() != guidon_button.get_parent() or fanion_button.get_index() != guidon_button.get_index() + 1:
		_fail(errors, "fanion button does not sit beside the guidon")
	else:
		var fanion_style := fanion_button.get_theme_stylebox("normal") as StyleBoxFlat
		if fanion_style == null or fanion_style.get_border_width(SIDE_LEFT) != 3 or fanion_style.border_color != Color("f0c14a"):
			_fail(errors, "selected fanion has no gold outline")
	node._on_key(KEY_UP)
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -18)) != Sim.FANION:
		_fail(errors, "keyboard cursor did not paint a fanion at 14,-18")
	node._on_key(KEY_U)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -18)) != Sim.FANION:
		_fail(errors, "the fanion cell accepted a guidon")
	node._on_key(KEY_DOWN)
	node._on_key(KEY_V)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -17)) != Sim.GUIDON:
		_fail(errors, "the guidon cell accepted a fanion")
	node._on_key(KEY_X)
	if not String(node.mode_label.text).contains("Pennon"):
		_fail(errors, "pennon mark was not named")
	var pennon_button: Button = null
	fanion_button = null
	for entry in node.mode_buttons:
		if int(entry["mode"]) == Sim.PENNON:
			pennon_button = entry["button"]
		elif int(entry["mode"]) == Sim.FANION:
			fanion_button = entry["button"]
	if pennon_button == null or fanion_button == null:
		_fail(errors, "pennon button is missing beside the fanion")
	elif not String(pennon_button.text).contains("Pennon") or not String(fanion_button.text).contains("Fanion"):
		_fail(errors, "pennon button is not labeled beside the fanion")
	elif pennon_button.get_parent() != fanion_button.get_parent() or pennon_button.get_index() != fanion_button.get_index() + 1:
		_fail(errors, "pennon button does not sit beside the fanion")
	else:
		var pennon_style := pennon_button.get_theme_stylebox("normal") as StyleBoxFlat
		if pennon_style == null or pennon_style.get_border_width(SIDE_LEFT) != 3 or pennon_style.border_color != Color("f0c14a"):
			_fail(errors, "selected pennon has no gold outline")
	node._on_key(KEY_UP)
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -19)) != Sim.PENNON:
		_fail(errors, "keyboard cursor did not paint a pennon at 14,-19")
	node._on_key(KEY_V)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -19)) != Sim.PENNON:
		_fail(errors, "the pennon cell accepted a fanion")
	node._on_key(KEY_DOWN)
	node._on_key(KEY_X)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -18)) != Sim.FANION:
		_fail(errors, "the fanion cell accepted a pennon")
	node._on_key(KEY_Y)
	if not String(node.mode_label.text).contains("Gonfalon"):
		_fail(errors, "gonfalon mark was not named")
	var gonfalon_button: Button = null
	pennon_button = null
	for entry in node.mode_buttons:
		if int(entry["mode"]) == Sim.GONFALON:
			gonfalon_button = entry["button"]
		elif int(entry["mode"]) == Sim.PENNON:
			pennon_button = entry["button"]
	if gonfalon_button == null or pennon_button == null:
		_fail(errors, "gonfalon button is missing beside the pennon")
	elif not String(gonfalon_button.text).contains("Gonfalon") or not String(pennon_button.text).contains("Pennon"):
		_fail(errors, "gonfalon button is not labeled beside the pennon")
	elif gonfalon_button.get_parent() != pennon_button.get_parent() or gonfalon_button.get_index() != pennon_button.get_index() + 1:
		_fail(errors, "gonfalon button does not sit beside the pennon")
	else:
		var gonfalon_style := gonfalon_button.get_theme_stylebox("normal") as StyleBoxFlat
		if gonfalon_style == null or gonfalon_style.get_border_width(SIDE_LEFT) != 3 or gonfalon_style.border_color != Color("f0c14a"):
			_fail(errors, "selected gonfalon has no gold outline")
	node._on_key(KEY_UP)
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -20)) != Sim.GONFALON:
		_fail(errors, "keyboard cursor did not paint a gonfalon at 14,-20")
	node._on_key(KEY_X)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -20)) != Sim.GONFALON:
		_fail(errors, "the gonfalon cell accepted a pennon")
	node._on_key(KEY_DOWN)
	node._on_key(KEY_Y)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -19)) != Sim.PENNON:
		_fail(errors, "the pennon cell accepted a gonfalon")
	node._on_key(KEY_Z)
	if not String(node.mode_label.text).contains("Oriflamme"):
		_fail(errors, "oriflamme mark was not named")
	var oriflamme_button: Button = null
	gonfalon_button = null
	for entry in node.mode_buttons:
		if int(entry["mode"]) == Sim.ORIFLAMME:
			oriflamme_button = entry["button"]
		elif int(entry["mode"]) == Sim.GONFALON:
			gonfalon_button = entry["button"]
	if oriflamme_button == null or gonfalon_button == null:
		_fail(errors, "oriflamme button is missing beside the gonfalon")
	elif not String(oriflamme_button.text).contains("Oriflamme") or not String(gonfalon_button.text).contains("Gonfalon"):
		_fail(errors, "oriflamme button is not labeled beside the gonfalon")
	elif oriflamme_button.get_parent() != gonfalon_button.get_parent() or oriflamme_button.get_index() != gonfalon_button.get_index() + 1:
		_fail(errors, "oriflamme button does not sit beside the gonfalon")
	else:
		var oriflamme_style := oriflamme_button.get_theme_stylebox("normal") as StyleBoxFlat
		if oriflamme_style == null or oriflamme_style.get_border_width(SIDE_LEFT) != 3 or oriflamme_style.border_color != Color("f0c14a"):
			_fail(errors, "selected oriflamme has no gold outline")
	node._on_key(KEY_UP)
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -21)) != Sim.ORIFLAMME:
		_fail(errors, "keyboard cursor did not paint an oriflamme at 14,-21")
	node._on_key(KEY_Y)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -21)) != Sim.ORIFLAMME:
		_fail(errors, "the oriflamme cell accepted a gonfalon")
	node._on_key(KEY_DOWN)
	node._on_key(KEY_Z)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -20)) != Sim.GONFALON:
		_fail(errors, "the gonfalon cell accepted an oriflamme")
	node._on_key(KEY_SEMICOLON)
	if not String(node.mode_label.text).contains("Vexillum"):
		_fail(errors, "vexillum mark was not named")
	var vexillum_button: Button = null
	oriflamme_button = null
	for entry in node.mode_buttons:
		if int(entry["mode"]) == Sim.VEXILLUM:
			vexillum_button = entry["button"]
		elif int(entry["mode"]) == Sim.ORIFLAMME:
			oriflamme_button = entry["button"]
	if vexillum_button == null or oriflamme_button == null:
		_fail(errors, "vexillum button is missing beside the oriflamme")
	elif not String(vexillum_button.text).contains("Vexillum") or not String(oriflamme_button.text).contains("Oriflamme"):
		_fail(errors, "vexillum button is not labeled beside the oriflamme")
	elif vexillum_button.get_parent() != oriflamme_button.get_parent() or vexillum_button.get_index() != oriflamme_button.get_index() + 1:
		_fail(errors, "vexillum button does not sit beside the oriflamme")
	else:
		var vexillum_style := vexillum_button.get_theme_stylebox("normal") as StyleBoxFlat
		if vexillum_style == null or vexillum_style.get_border_width(SIDE_LEFT) != 3 or vexillum_style.border_color != Color("f0c14a"):
			_fail(errors, "selected vexillum has no gold outline")
	node._on_key(KEY_UP)
	node._on_key(KEY_UP)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -22)) != Sim.VEXILLUM:
		_fail(errors, "keyboard cursor did not paint a vexillum at 14,-22")
	node._on_key(KEY_Z)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -22)) != Sim.VEXILLUM:
		_fail(errors, "the vexillum cell accepted an oriflamme")
	node._on_key(KEY_DOWN)
	node._on_key(KEY_SEMICOLON)
	node._on_key(KEY_SPACE)
	if int(node.sim.get_paint(14, -21)) != Sim.ORIFLAMME:
		_fail(errors, "the oriflamme cell accepted a vexillum")
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
	if rules == null or not String(rules.text).to_lower().contains("horn"):
		_fail(errors, "rules text does not mention the horn")
	if rules == null or not String(rules.text).to_lower().contains("sound one"):
		_fail(errors, "rules text does not name the horn cap of one")
	if rules == null or not String(rules.text).to_lower().contains("flag"):
		_fail(errors, "rules text does not mention the flag")
	if rules == null or not String(rules.text).to_lower().contains("raise one"):
		_fail(errors, "rules text does not name the flag cap of one")
	if rules == null or not String(rules.text).to_lower().contains("banner"):
		_fail(errors, "rules text does not mention the banner")
	if rules == null or not String(rules.text).to_lower().contains("hoist one"):
		_fail(errors, "rules text does not name the banner cap of one")
	if rules == null or not String(rules.text).to_lower().contains("pennant"):
		_fail(errors, "rules text does not mention the pennant")
	if rules == null or not String(rules.text).to_lower().contains("fly one"):
		_fail(errors, "rules text does not name the pennant cap of one")
	if rules == null or not String(rules.text).to_lower().contains("standard"):
		_fail(errors, "rules text does not mention the standard")
	if rules == null or not String(rules.text).to_lower().contains("carry one"):
		_fail(errors, "rules text does not name the standard cap of one")
	if rules == null or not String(rules.text).to_lower().contains("jack"):
		_fail(errors, "rules text does not mention the jack")
	if rules == null or not String(rules.text).to_lower().contains("show one"):
		_fail(errors, "rules text does not name the jack cap of one")
	if rules == null or not String(rules.text).to_lower().contains("ensign"):
		_fail(errors, "rules text does not mention the ensign")
	if rules == null or not String(rules.text).to_lower().contains("break one"):
		_fail(errors, "rules text does not name the ensign cap of one")
	if rules == null or not String(rules.text).to_lower().contains("burgee"):
		_fail(errors, "rules text does not mention the burgee")
	if rules == null or not String(rules.text).to_lower().contains("strike one"):
		_fail(errors, "rules text does not name the burgee cap of one")
	if rules == null or not String(rules.text).to_lower().contains("cornet"):
		_fail(errors, "rules text does not mention the cornet")
	if rules == null or not String(rules.text).to_lower().contains("dip one"):
		_fail(errors, "rules text does not name the cornet cap of one")
	if rules == null or not String(rules.text).to_lower().contains("guidon"):
		_fail(errors, "rules text does not mention the guidon")
	if rules == null or not String(rules.text).to_lower().contains("salute one"):
		_fail(errors, "rules text does not name the guidon cap of one")
	if rules == null or not String(rules.text).to_lower().contains("fanion"):
		_fail(errors, "rules text does not mention the fanion")
	if rules == null or not String(rules.text).to_lower().contains("present one"):
		_fail(errors, "rules text does not name the fanion cap of one")
	if rules == null or not String(rules.text).to_lower().contains("pennon"):
		_fail(errors, "rules text does not mention the pennon")
	if rules == null or not String(rules.text).to_lower().contains("furl one"):
		_fail(errors, "rules text does not name the pennon cap of one")
	if rules == null or not String(rules.text).to_lower().contains("gonfalon"):
		_fail(errors, "rules text does not mention the gonfalon")
	if rules == null or not String(rules.text).to_lower().contains("already furled"):
		_fail(errors, "rules text does not name the gonfalon dip of one furled hire")
	if rules == null or not String(rules.text).to_lower().contains("oriflamme"):
		_fail(errors, "rules text does not mention the oriflamme")
	if rules == null or not String(rules.text).to_lower().contains("lower one"):
		_fail(errors, "rules text does not name the oriflamme lower of one dipped hire")
	if rules == null or not String(rules.text).to_lower().contains("vexillum"):
		_fail(errors, "rules text does not mention the vexillum")
	if rules == null or not String(rules.text).to_lower().contains("house one"):
		_fail(errors, "rules text does not name the vexillum house of one lowered hire")
	var hint = node.find_child("HintLine", true, false)
	if hint == null or not String(hint.text).to_lower().contains("watch"):
		_fail(errors, "hint line does not name the watch")
	if hint == null or not String(hint.text).to_lower().contains("lamp"):
		_fail(errors, "hint line does not name the lamp")
	if hint == null or not String(hint.text).to_lower().contains("bell"):
		_fail(errors, "hint line does not name the bell")
	if hint == null or not String(hint.text).to_lower().contains("horn"):
		_fail(errors, "hint line does not name the horn")
	if hint == null or not String(hint.text).to_lower().contains("k flag"):
		_fail(errors, "hint line does not name the flag")
	if hint == null or not String(hint.text).to_lower().contains("l banner"):
		_fail(errors, "hint line does not name the banner")
	if hint == null or not String(hint.text).to_lower().contains("m pennant"):
		_fail(errors, "hint line does not name the pennant")
	if hint == null or not String(hint.text).to_lower().contains("n standard"):
		_fail(errors, "hint line does not name the standard")
	if hint == null or not String(hint.text).to_lower().contains("o jack"):
		_fail(errors, "hint line does not name the jack")
	var hint_lines: PackedStringArray = String(hint.text).split("\n") if hint != null else PackedStringArray()
	var hint_last := hint_lines[hint_lines.size() - 1].to_lower() if hint_lines.size() > 0 else ""
	if hint_last.find("n standard") < hint_last.find("m pennant") or not hint_last.contains("n standard"):
		_fail(errors, "hint's last line does not name the standard after the pennant: %s" % hint_last)
	if hint_last.find("o jack") < hint_last.find("n standard") or not hint_last.contains("o jack"):
		_fail(errors, "hint's last line does not name the jack after the standard: %s" % hint_last)
	if hint_last.find("p ensign") < hint_last.find("o jack") or not hint_last.contains("p ensign"):
		_fail(errors, "hint's last line does not name the ensign after the jack: %s" % hint_last)
	if hint_last.find("q burgee") < hint_last.find("p ensign") or not hint_last.contains("q burgee"):
		_fail(errors, "hint's last line does not name the burgee after the ensign: %s" % hint_last)
	if hint_last.find("t cornet") < hint_last.find("q burgee") or not hint_last.contains("t cornet"):
		_fail(errors, "hint's last line does not name the cornet after the burgee: %s" % hint_last)
	if hint_last.find("u guidon") < hint_last.find("t cornet") or not hint_last.contains("u guidon"):
		_fail(errors, "hint's last line does not name the guidon after the cornet: %s" % hint_last)
	if hint_last.find("v fanion") < hint_last.find("u guidon") or not hint_last.contains("v fanion"):
		_fail(errors, "hint's last line does not name the fanion after the guidon: %s" % hint_last)
	if hint_last.find("x pennon") < hint_last.find("v fanion") or not hint_last.contains("x pennon"):
		_fail(errors, "hint's last line does not name the pennon after the fanion: %s" % hint_last)
	if hint_last.find("y gonfalon") < hint_last.find("x pennon") or not hint_last.contains("y gonfalon"):
		_fail(errors, "hint's last line does not name the gonfalon after the pennon: %s" % hint_last)
	if hint_last.find("z oriflamme") < hint_last.find("y gonfalon") or not hint_last.contains("z oriflamme"):
		_fail(errors, "hint's last line does not name the oriflamme after the gonfalon: %s" % hint_last)
	if hint_last.find("; vexillum") < hint_last.find("z oriflamme") or not hint_last.contains("; vexillum"):
		_fail(errors, "hint's last line does not name the vexillum after the oriflamme: %s" % hint_last)
	if hint != null and (int(hint.position.y) != 1512 or int(hint.size.x) != 1022 or not hint.clip_contents):
		_fail(errors, "hint line left its box (y %s w %s clip %s)" % [hint.position.y, hint.size.x, hint.clip_contents])
	if hint == null or not String(hint.text).contains("\n"):
		_fail(errors, "hint line is still one long line")
	var panel = node.find_child("Panel", true, false)
	if hint != null and panel != null and hint.position.x + hint.size.x > panel.position.x:
		_fail(errors, "hint line runs under the side panel")
	if hint != null and hint.position.y + hint.size.y > 1616.0:
		_fail(errors, "hint line continues past the window")
	var map_bottom := 58.0 + float(Sim.GRID_H - Sim.GRID_NORTH) * 42.0
	if hint != null and hint.position.y < map_bottom:
		_fail(errors, "hint line covers the jack row")
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
	var spun_horn := 0
	while int(node.sim.get_beat()) != Sim.HORNING and not node.sim.is_over() and spun_horn < int(Sim.BELL_TICK) + 2:
		node.sim.tick()
		spun_horn += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.HORNING or node.sim.is_over():
		_fail(errors, "the scene did not open the horn beat")
	elif not String(node.rain_label.text).to_lower().contains("horn"):
		_fail(errors, "horn countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.HORN_TICK):
		_fail(errors, "horn countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.HORN_TICK])
	elif not String(node.season_label.text).to_lower().contains("horn"):
		_fail(errors, "horn note does not mention the horn: %s" % node.season_label.text)
	var spun_flag := 0
	while int(node.sim.get_beat()) != Sim.FLAGGING and not node.sim.is_over() and spun_flag < int(Sim.HORN_TICK) + 2:
		node.sim.tick()
		spun_flag += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.FLAGGING or node.sim.is_over():
		_fail(errors, "the scene did not open the flag beat")
	elif not String(node.rain_label.text).to_lower().contains("flag"):
		_fail(errors, "flag countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.FLAG_TICK):
		_fail(errors, "flag countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.FLAG_TICK])
	elif not String(node.season_label.text).to_lower().contains("flag"):
		_fail(errors, "flag note does not mention the flag: %s" % node.season_label.text)
	var spun_banner := 0
	while int(node.sim.get_beat()) != Sim.BANNERING and not node.sim.is_over() and spun_banner < int(Sim.FLAG_TICK) + 2:
		node.sim.tick()
		spun_banner += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.BANNERING or node.sim.is_over():
		_fail(errors, "the scene did not open the banner beat")
	elif not String(node.rain_label.text).to_lower().contains("banner"):
		_fail(errors, "banner countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.BANNER_TICK):
		_fail(errors, "banner countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.BANNER_TICK])
	elif not String(node.season_label.text).to_lower().contains("banner"):
		_fail(errors, "banner note does not mention the banner: %s" % node.season_label.text)
	var spun_pennant := 0
	while int(node.sim.get_beat()) != Sim.PENNANTING and not node.sim.is_over() and spun_pennant < int(Sim.BANNER_TICK) + 2:
		node.sim.tick()
		spun_pennant += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.PENNANTING or node.sim.is_over():
		_fail(errors, "the scene did not open the pennant beat")
	elif not String(node.rain_label.text).to_lower().contains("pennant"):
		_fail(errors, "pennant countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.PENNANT_TICK):
		_fail(errors, "pennant countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.PENNANT_TICK])
	elif not String(node.season_label.text).to_lower().contains("pennant"):
		_fail(errors, "pennant note does not mention the pennant: %s" % node.season_label.text)
	var spun_standard := 0
	while int(node.sim.get_beat()) != Sim.STANDARDING and not node.sim.is_over() and spun_standard < int(Sim.PENNANT_TICK) + 2:
		node.sim.tick()
		spun_standard += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.STANDARDING or node.sim.is_over():
		_fail(errors, "the scene did not open the standard beat")
	elif not String(node.rain_label.text).to_lower().contains("standard"):
		_fail(errors, "standard countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.STANDARD_TICK):
		_fail(errors, "standard countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.STANDARD_TICK])
	elif not String(node.season_label.text).to_lower().contains("standard"):
		_fail(errors, "standard note does not mention the standard: %s" % node.season_label.text)
	var spun_jack := 0
	while int(node.sim.get_beat()) != Sim.JACKING and not node.sim.is_over() and spun_jack < int(Sim.STANDARD_TICK) + 2:
		node.sim.tick()
		spun_jack += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.JACKING or node.sim.is_over():
		_fail(errors, "the scene did not open the jack beat")
	elif not String(node.rain_label.text).to_lower().contains("jack"):
		_fail(errors, "jack countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.JACK_TICK):
		_fail(errors, "jack countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.JACK_TICK])
	elif not String(node.season_label.text).to_lower().contains("jack"):
		_fail(errors, "jack note does not mention the jack: %s" % node.season_label.text)
	var spun_ensign := 0
	while int(node.sim.get_beat()) != Sim.ENSIGNING and not node.sim.is_over() and spun_ensign < int(Sim.JACK_TICK) + 2:
		node.sim.tick()
		spun_ensign += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.ENSIGNING or node.sim.is_over():
		_fail(errors, "the scene did not open the ensign beat")
	elif not String(node.rain_label.text).to_lower().contains("ensign"):
		_fail(errors, "ensign countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.ENSIGN_TICK):
		_fail(errors, "ensign countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.ENSIGN_TICK])
	elif not String(node.season_label.text).to_lower().contains("ensign"):
		_fail(errors, "ensign note does not mention the ensign: %s" % node.season_label.text)
	var spun_burgee := 0
	while int(node.sim.get_beat()) != Sim.BURGEEING and not node.sim.is_over() and spun_burgee < int(Sim.ENSIGN_TICK) + 2:
		node.sim.tick()
		spun_burgee += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.BURGEEING or node.sim.is_over():
		_fail(errors, "the scene did not open the burgee beat")
	elif not String(node.rain_label.text).to_lower().contains("burgee"):
		_fail(errors, "burgee countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.BURGEE_TICK):
		_fail(errors, "burgee countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.BURGEE_TICK])
	elif not String(node.season_label.text).to_lower().contains("burgee"):
		_fail(errors, "burgee note does not mention the burgee: %s" % node.season_label.text)
	var spun_cornet := 0
	while int(node.sim.get_beat()) != Sim.CORNETING and not node.sim.is_over() and spun_cornet < int(Sim.BURGEE_TICK) + 2:
		node.sim.tick()
		spun_cornet += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.CORNETING or node.sim.is_over():
		_fail(errors, "the scene did not open the cornet beat")
	elif not String(node.rain_label.text).to_lower().contains("cornet"):
		_fail(errors, "cornet countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.CORNET_TICK):
		_fail(errors, "cornet countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.CORNET_TICK])
	elif not String(node.season_label.text).to_lower().contains("cornet"):
		_fail(errors, "cornet note does not mention the cornet: %s" % node.season_label.text)
	var spun_guidon := 0
	while int(node.sim.get_beat()) != Sim.GUIDONING and not node.sim.is_over() and spun_guidon < int(Sim.CORNET_TICK) + 2:
		node.sim.tick()
		spun_guidon += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.GUIDONING or node.sim.is_over():
		_fail(errors, "the scene did not open the guidon beat")
	elif not String(node.rain_label.text).to_lower().contains("guidon"):
		_fail(errors, "guidon countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.GUIDON_TICK):
		_fail(errors, "guidon countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.GUIDON_TICK])
	elif not String(node.season_label.text).to_lower().contains("guidon"):
		_fail(errors, "guidon note does not mention the guidon: %s" % node.season_label.text)
	var spun_fanion := 0
	while int(node.sim.get_beat()) != Sim.FANIONING and not node.sim.is_over() and spun_fanion < int(Sim.GUIDON_TICK) + 2:
		node.sim.tick()
		spun_fanion += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.FANIONING or node.sim.is_over():
		_fail(errors, "the scene did not open the fanion beat")
	elif not String(node.rain_label.text).to_lower().contains("fanion"):
		_fail(errors, "fanion countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.FANION_TICK):
		_fail(errors, "fanion countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.FANION_TICK])
	elif not String(node.season_label.text).to_lower().contains("fanion"):
		_fail(errors, "fanion note does not mention the fanion: %s" % node.season_label.text)
	var spun_pennon := 0
	while int(node.sim.get_beat()) != Sim.PENNONING and not node.sim.is_over() and spun_pennon < int(Sim.FANION_TICK) + 2:
		node.sim.tick()
		spun_pennon += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.PENNONING or node.sim.is_over():
		_fail(errors, "the scene did not open the pennon beat")
	elif not String(node.rain_label.text).to_lower().contains("pennon"):
		_fail(errors, "pennon countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.PENNON_TICK):
		_fail(errors, "pennon countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.PENNON_TICK])
	elif not String(node.season_label.text).to_lower().contains("pennon"):
		_fail(errors, "pennon note does not mention the pennon: %s" % node.season_label.text)
	var spun_gonfalon := 0
	while int(node.sim.get_beat()) != Sim.GONFALONING and not node.sim.is_over() and spun_gonfalon < int(Sim.PENNON_TICK) + 2:
		node.sim.tick()
		spun_gonfalon += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.GONFALONING or node.sim.is_over():
		_fail(errors, "the scene did not open the gonfalon beat")
	elif not String(node.rain_label.text).to_lower().contains("gonfalon"):
		_fail(errors, "gonfalon countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.GONFALON_TICK):
		_fail(errors, "gonfalon countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.GONFALON_TICK])
	elif not String(node.season_label.text).to_lower().contains("gonfalon"):
		_fail(errors, "gonfalon note does not mention the gonfalon: %s" % node.season_label.text)
	var spun_oriflamme := 0
	while int(node.sim.get_beat()) != Sim.ORIFLAMMING and not node.sim.is_over() and spun_oriflamme < int(Sim.GONFALON_TICK) + 2:
		node.sim.tick()
		spun_oriflamme += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.ORIFLAMMING or node.sim.is_over():
		_fail(errors, "the scene did not open the oriflamme beat")
	elif not String(node.rain_label.text).to_lower().contains("oriflamme"):
		_fail(errors, "oriflamme countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.ORIFLAMME_TICK):
		_fail(errors, "oriflamme countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.ORIFLAMME_TICK])
	elif not String(node.season_label.text).to_lower().contains("oriflamme"):
		_fail(errors, "oriflamme note does not mention the oriflamme: %s" % node.season_label.text)
	var spun_vexillum := 0
	while int(node.sim.get_beat()) != Sim.VEXILLUMING and not node.sim.is_over() and spun_vexillum < int(Sim.ORIFLAMME_TICK) + 2:
		node.sim.tick()
		spun_vexillum += 1
	node._refresh()
	if int(node.sim.get_beat()) != Sim.VEXILLUMING or node.sim.is_over():
		_fail(errors, "the scene did not open the vexillum beat")
	elif not String(node.rain_label.text).to_lower().contains("vexillum"):
		_fail(errors, "vexillum countdown was not named: %s" % node.rain_label.text)
	elif int(node.sim.get_ticks_until_rain()) != int(Sim.VEXILLUM_TICK):
		_fail(errors, "vexillum countdown started at %d, expected %d" % [node.sim.get_ticks_until_rain(), Sim.VEXILLUM_TICK])
	elif not String(node.season_label.text).to_lower().contains("vexillum"):
		_fail(errors, "vexillum note does not mention the vexillum: %s" % node.season_label.text)
	node._on_key(KEY_R)
	if int(node.sim.get_paint(9, 5)) != Sim.EMPTY or int(node.sim.get_paint(8, 5)) != Sim.EMPTY or int(node.sim.get_paint(8, 6)) != Sim.EMPTY or int(node.sim.get_paint(7, 6)) != Sim.EMPTY or int(node.sim.get_paint(7, 5)) != Sim.EMPTY or int(node.sim.get_paint(7, 4)) != Sim.EMPTY or int(node.sim.get_paint(7, 3)) != Sim.EMPTY or int(node.sim.get_paint(7, 2)) != Sim.EMPTY or int(node.sim.get_paint(7, 1)) != Sim.EMPTY or int(node.sim.get_paint(7, 0)) != Sim.EMPTY or int(node.sim.get_paint(7, -1)) != Sim.EMPTY or int(node.sim.get_paint(7, -2)) != Sim.EMPTY or int(node.sim.get_paint(7, -3)) != Sim.EMPTY or int(node.sim.get_paint(7, -4)) != Sim.EMPTY or int(node.sim.get_paint(7, -5)) != Sim.EMPTY or int(node.sim.get_paint(7, -6)) != Sim.EMPTY or int(node.sim.get_paint(7, -7)) != Sim.EMPTY or int(node.sim.get_paint(14, -11)) != Sim.EMPTY or int(node.sim.get_paint(14, -12)) != Sim.EMPTY or int(node.sim.get_paint(14, -13)) != Sim.EMPTY or int(node.sim.get_paint(14, -14)) != Sim.EMPTY or int(node.sim.get_paint(14, -15)) != Sim.EMPTY or int(node.sim.get_paint(14, -16)) != Sim.EMPTY or int(node.sim.get_paint(14, -17)) != Sim.EMPTY or int(node.sim.get_paint(14, -18)) != Sim.EMPTY or int(node.sim.get_paint(14, -19)) != Sim.EMPTY or int(node.sim.get_paint(14, -20)) != Sim.EMPTY or int(node.sim.get_paint(14, -21)) != Sim.EMPTY or int(node.sim.get_paint(14, -22)) != Sim.EMPTY:
		_fail(errors, "restart scenario did not clear the marks")
	if int(node.sim.get_season()) != Sim.WET or int(node.sim.get_wet_haul()) != 0 or int(node.sim.get_beat()) != Sim.WET or int(node.sim.get_carted()) != 0 or int(node.sim.get_shipped()) != 0 or int(node.sim.get_coins()) != 0 or int(node.sim.get_banked()) != 0 or int(node.sim.get_hired()) != 0 or int(node.sim.get_lofted()) != 0 or int(node.sim.get_gated()) != 0 or int(node.sim.get_paid()) != 0 or int(node.sim.get_posted()) != 0 or int(node.sim.get_stood()) != 0 or int(node.sim.get_lit()) != 0 or int(node.sim.get_rung()) != 0 or int(node.sim.get_sounded()) != 0 or int(node.sim.get_raised()) != 0 or int(node.sim.get_hoisted()) != 0 or int(node.sim.get_flown()) != 0 or int(node.sim.get_carried()) != 0 or int(node.sim.get_shown()) != 0 or int(node.sim.get_broken()) != 0 or int(node.sim.get_struck()) != 0 or int(node.sim.get_dipped()) != 0 or int(node.sim.get_saluted()) != 0 or int(node.sim.get_presented()) != 0 or int(node.sim.get_furled()) != 0 or int(node.sim.get_gonfalon_dipped()) != 0 or int(node.sim.get_oriflamme_lowered()) != 0 or int(node.sim.get_vexillum_housed()) != 0:
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
	if fresh.paint_cell(14, -11, Sim.GATE):
		_fail(errors, "the row north of the banner accepted a mark")
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
	if fresh.paint_cell(14, -11, Sim.WAGE):
		_fail(errors, "the row north of the banner accepted a mark")
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
	if fresh.paint_cell(14, -11, Sim.RELIEF):
		_fail(errors, "the row north of the banner accepted a mark")
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
	if fresh.paint_cell(14, -11, Sim.WATCH):
		_fail(errors, "the row north of the banner accepted a mark")
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
	if fresh.paint_cell(14, -11, Sim.LAMP):
		_fail(errors, "the row north of the banner accepted a mark")
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


func _assert_chain(sim, errors: Array, label: String, wet: int, stored: int, carted: int, shipped: int, coins: int, hired: int, yard: int, paid: int, posted: int, stood: int, lit: int, rung: int, sounded: int = 0, raised: int = 0, hoisted: int = 0, flown: int = 0, carried: int = 0, shown: int = 0, broken: int = 0, struck: int = 0, dipped: int = 0, saluted: int = 0, presented: int = 0, furled: int = 0, gonfalon: int = 0, oriflamme: int = 0, vexillum: int = 0) -> void:
	if sim == null:
		_fail(errors, "%s did not run" % label)
		return
	if int(sim.get_wet_haul()) != wet or int(sim.get_stored_salt()) != stored or int(sim.get_carted()) != carted or int(sim.get_shipped()) != shipped or int(sim.get_coins()) != coins or int(sim.get_hired()) != hired or int(sim.get_yard_left()) != yard or int(sim.get_paid()) != paid or int(sim.get_posted()) != posted or int(sim.get_stood()) != stood or int(sim.get_lit()) != lit or int(sim.get_rung()) != rung or int(sim.get_sounded()) != sounded or int(sim.get_raised()) != raised or int(sim.get_hoisted()) != hoisted or int(sim.get_flown()) != flown or int(sim.get_carried()) != carried or int(sim.get_shown()) != shown or int(sim.get_broken()) != broken or int(sim.get_struck()) != struck or int(sim.get_dipped()) != dipped or int(sim.get_saluted()) != saluted or int(sim.get_presented()) != presented or int(sim.get_furled()) != furled or int(sim.get_gonfalon_dipped()) != gonfalon or int(sim.get_oriflamme_lowered()) != oriflamme or int(sim.get_vexillum_housed()) != vexillum:
		_fail(errors, "%s changed (wet %d stored %d carted %d shipped %d coins %d hired %d yard %d paid %d posted %d stood %d lit %d rung %d sounded %d raised %d hoisted %d flown %d carried %d shown %d broken %d struck %d dipped %d saluted %d presented %d furled %d gonfalon %d oriflamme %d vexillum %d)" % [label, sim.get_wet_haul(), sim.get_stored_salt(), sim.get_carted(), sim.get_shipped(), sim.get_coins(), sim.get_hired(), sim.get_yard_left(), sim.get_paid(), sim.get_posted(), sim.get_stood(), sim.get_lit(), sim.get_rung(), sim.get_sounded(), sim.get_raised(), sim.get_hoisted(), sim.get_flown(), sim.get_carried(), sim.get_shown(), sim.get_broken(), sim.get_struck(), sim.get_dipped(), sim.get_saluted(), sim.get_presented(), sim.get_furled(), sim.get_gonfalon_dipped(), sim.get_oriflamme_lowered(), sim.get_vexillum_housed()])


func _test_bell(errors: Array) -> void:
	if int(Sim.BELL_TICK) != 100 or int(Sim.BELL_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "bell beat length %s is not 100 ticks (10 seconds)" % Sim.BELL_TICK)
	if int(Sim.BELL_CAP) != 2:
		_fail(errors, "bell cap is %s, expected 2" % Sim.BELL_CAP)
	var fresh = Sim.new()
	if fresh.paint_cell(14, -7, Sim.BELL) == false or int(fresh.get_paint(14, -7)) != Sim.BELL:
		_fail(errors, "the cell north of the lamp rejected the bell mark")
	if fresh.paint_cell(14, -11, Sim.BELL):
		_fail(errors, "the row north of the banner accepted a mark")
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


func _test_horn(errors: Array) -> void:
	if int(Sim.HORN_TICK) != 100 or int(Sim.HORN_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "horn beat length %s is not 100 ticks (10 seconds)" % Sim.HORN_TICK)
	if int(Sim.HORN_CAP) != 1:
		_fail(errors, "horn cap is %s, expected 1" % Sim.HORN_CAP)
	var fresh = Sim.new()
	if fresh.paint_cell(14, -8, Sim.HORN) == false or int(fresh.get_paint(14, -8)) != Sim.HORN:
		_fail(errors, "the cell north of the bell rejected the horn mark")
	if fresh.paint_cell(14, -11, Sim.HORN):
		_fail(errors, "the row north of the banner accepted a mark")
	if fresh.paint_cell(Sim.COAST_X, -8, Sim.HORN):
		_fail(errors, "the brine accepted a horn")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.HORN):
		_fail(errors, "the anthill accepted a horn")
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
	var rung = _run_plan(plans, "rung", errors)
	var dry_rung = _run_plan(plans, "dry_rung", errors)
	var ignored = _run_plan(plans, "no_horn", errors)
	var bare = _run_plan(plans, "horn_only", errors)
	var sounded = _run_plan(plans, "sounded", errors)
	var sounded_again = _run_plan(plans, "sounded", errors)
	var late = _run_plan(plans, "late_sounded", errors)
	var dry_sounded = _run_plan(plans, "dry_sounded", errors)
	if won == null or dry == null or parked == null or loaded == null or sold == null or hired == null or lofted == null or passed == null or paid == null or dry_paid == null or posted == null or dry_posted == null or stood == null or dry_stood == null or lit == null or dry_lit == null or rung == null or dry_rung == null or ignored == null or bare == null or sounded == null or sounded_again == null or late == null or dry_sounded == null:
		return
	# Earlier plans keep the numbers they had before the horn existed.
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
	_assert_chain(rung, errors, "rung plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2)
	_assert_chain(dry_rung, errors, "dry bell", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 2)
	# Rung, no horn: the 2 who were rung stay on the bell. The 1 lit but not
	# rung stays on the lamp. The 1 stood but not lit stays on the watch. The
	# 2 posted but not stood stay on the relief. The 4 paid but not posted stay
	# on the wage. The 19 in the loft stay unpaid.
	var ignored_unpaid := int(ignored.get_hired()) - int(ignored.get_paid())
	var ignored_unposted := int(ignored.get_paid()) - int(ignored.get_posted())
	var ignored_unstood := int(ignored.get_posted()) - int(ignored.get_stood())
	var ignored_unlit := int(ignored.get_stood()) - int(ignored.get_lit())
	var ignored_unrung := int(ignored.get_lit()) - int(ignored.get_rung())
	if int(ignored.get_sounded()) != 0 or int(ignored.get_bell_left()) != 2 or int(ignored.get_rung()) != 2 or ignored_unrung != 1 or int(ignored.get_lamp_left()) != 1 or int(ignored.get_lit()) != 3 or ignored_unlit != 1 or int(ignored.get_watch_left()) != 1 or ignored_unstood != 2 or ignored_unposted != 4 or ignored_unpaid != 19 or int(ignored.get_relief_left()) != 2 or int(ignored.get_wage_left()) != 4 or int(ignored.get_loft_left()) != 19 or int(ignored.get_gate_left()) != 0 or int(ignored.get_yard_left()) != 57 or int(ignored.get_stood()) != 4 or int(ignored.get_posted()) != 6 or int(ignored.get_paid()) != 10 or int(ignored.get_hired()) != 29 or int(ignored.get_coins()) != 2997 or int(ignored.get_stored_salt()) != 2997 or int(ignored.get_carted()) != 2997 or int(ignored.get_shipped()) != 2997:
		_fail(errors, "no_horn sounded someone (stored %d carted %d shipped %d coins %d hired %d yard %d paid %d posted %d stood %d lit %d rung %d bell %d sounded %d unpaid %d unposted %d unstood %d loft %d wage %d)" % [ignored.get_stored_salt(), ignored.get_carted(), ignored.get_shipped(), ignored.get_coins(), ignored.get_hired(), ignored.get_yard_left(), ignored.get_paid(), ignored.get_posted(), ignored.get_stood(), ignored.get_lit(), ignored.get_rung(), ignored.get_bell_left(), ignored.get_sounded(), ignored_unpaid, ignored_unposted, ignored_unstood, ignored.get_loft_left(), ignored.get_wage_left()])
	if String(ignored.get_summary()) != String(rung.get_summary()):
		_fail(errors, "no_horn summary changed: %s" % ignored.get_summary())
	if String(ignored.get_summary()).to_lower().contains("sounded") or String(ignored.get_summary()).to_lower().contains("horn"):
		_fail(errors, "no_horn summary names a horn: %s" % ignored.get_summary())
	var ignored_bell = plans["no_horn"]["bell"][0]
	var ignored_salt: Dictionary = ignored.get_cell_salt(int(ignored_bell[0]), int(ignored_bell[1]))
	var ignored_north: Dictionary = ignored.get_cell_salt(int(ignored_bell[0]), int(ignored_bell[1]) - 1)
	if int(ignored_salt.get("bell", 0)) != 2 or int(ignored_north.get("horn", 0)) != 0 or int(ignored_salt.get("horn", 0)) != 0:
		_fail(errors, "no_horn left %s at the bell and %s at a horn" % [ignored_salt.get("bell", 0), ignored_north.get("horn", 0)])
	# A horn with nobody rung sounds nobody. Lit hires stay on the lamp.
	var bare_unpaid := int(bare.get_hired()) - int(bare.get_paid())
	var bare_unstood := int(bare.get_posted()) - int(bare.get_stood())
	if int(bare.get_sounded()) != 0 or int(bare.get_rung()) != 0 or int(bare.get_bell_left()) != 0 or int(bare.get_lit()) != 3 or int(bare.get_lamp_left()) != 3 or int(bare.get_stood()) != 4 or int(bare.get_watch_left()) != 1 or int(bare.get_posted()) != 6 or int(bare.get_relief_left()) != 2 or bare_unstood != 2 or int(bare.get_paid()) != 10 or int(bare.get_wage_left()) != 4 or bare_unpaid != 19 or int(bare.get_loft_left()) != 19 or int(bare.get_gate_left()) != 0 or int(bare.get_yard_left()) != 57 or int(bare.get_hired()) != 29 or int(bare.get_coins()) != 2997 or int(bare.get_stored_salt()) != 2997 or int(bare.get_carted()) != 2997 or int(bare.get_shipped()) != 2997:
		_fail(errors, "horn without a bell sounded someone (stored %d carted %d shipped %d coins %d hired %d yard %d paid %d wage %d posted %d relief %d stood %d watch %d lit %d lamp %d rung %d sounded %d unpaid %d loft %d)" % [bare.get_stored_salt(), bare.get_carted(), bare.get_shipped(), bare.get_coins(), bare.get_hired(), bare.get_yard_left(), bare.get_paid(), bare.get_wage_left(), bare.get_posted(), bare.get_relief_left(), bare.get_stood(), bare.get_watch_left(), bare.get_lit(), bare.get_lamp_left(), bare.get_rung(), bare.get_sounded(), bare_unpaid, bare.get_loft_left()])
	if String(bare.get_summary()) != String(lit.get_summary()):
		_fail(errors, "horn without a bell changed the summary: %s" % bare.get_summary())
	if String(bare.get_summary()).to_lower().contains("sounded") or String(bare.get_summary()).to_lower().contains("horn") or String(bare.get_summary()).to_lower().contains("rung") or String(bare.get_summary()).to_lower().contains("bell"):
		_fail(errors, "horn without a bell names a horn: %s" % bare.get_summary())
	var bare_horn = plans["horn_only"]["horn"][0]
	var bare_lamp = plans["horn_only"]["lamp"][0]
	var bare_horn_salt: Dictionary = bare.get_cell_salt(int(bare_horn[0]), int(bare_horn[1]))
	var bare_lamp_salt: Dictionary = bare.get_cell_salt(int(bare_lamp[0]), int(bare_lamp[1]))
	if int(bare_horn_salt.get("horn", 0)) != 0 or int(bare_lamp_salt.get("lamp", 0)) != 3 or int(bare_horn_salt.get("bell", 0)) != 0:
		_fail(errors, "horn without a bell holds %s, lamp holds %s" % [bare_horn_salt.get("horn", 0), bare_lamp_salt.get("lamp", 0)])
	var horn_cell = plans["sounded"]["horn"][0]
	var bell_cell = plans["sounded"]["bell"][0]
	var lamp_cell = plans["sounded"]["lamp"][0]
	var watch_cell = plans["sounded"]["watch"][0]
	var relief_cell = plans["sounded"]["relief"][0]
	var wage_cell = plans["sounded"]["wage"][0]
	var gate_cell = plans["sounded"]["gate"][0]
	var loft_cell = plans["sounded"]["loft"][0]
	var yard_cell = plans["sounded"]["yard"][0]
	if int(horn_cell[0]) != int(bell_cell[0]) or int(horn_cell[1]) != int(bell_cell[1]) - 1:
		_fail(errors, "sounded plan's horn is not one cell north of the bell")
	if int(bell_cell[0]) != 14 or int(bell_cell[1]) != -7 or int(horn_cell[0]) != 14 or int(horn_cell[1]) != -8:
		_fail(errors, "sounded plan's horn is not at 14,-8 north of the bell at 14,-7")
	if int(bell_cell[0]) != int(lamp_cell[0]) or int(bell_cell[1]) != int(lamp_cell[1]) - 1:
		_fail(errors, "sounded plan's bell is not one cell north of the lamp")
	_assert_chain(sounded, errors, "sounded plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2, 1)
	var sounded_unpaid := int(sounded.get_hired()) - int(sounded.get_paid())
	var sounded_unposted := int(sounded.get_paid()) - int(sounded.get_posted())
	var sounded_unstood := int(sounded.get_posted()) - int(sounded.get_stood())
	var sounded_unlit := int(sounded.get_stood()) - int(sounded.get_lit())
	var sounded_unrung := int(sounded.get_lit()) - int(sounded.get_rung())
	if int(sounded.get_sounded()) != 1 or int(sounded.get_bell_left()) != 1 or sounded_unrung != 1 or sounded_unlit != 1 or sounded_unstood != 2 or sounded_unposted != 4 or sounded_unpaid != 19 or int(sounded.get_lamp_left()) != 1 or int(sounded.get_watch_left()) != 1 or int(sounded.get_relief_left()) != 2 or int(sounded.get_wage_left()) != 4 or int(sounded.get_loft_left()) != 19 or int(sounded.get_gate_left()) != 0 or int(sounded.get_yard_left()) != 57 or int(sounded.get_rung()) != 2 or int(sounded.get_lit()) != 3 or int(sounded.get_stood()) != 4 or int(sounded.get_posted()) != 6:
		_fail(errors, "sounded %d, left %d rung unsounded, lit unrung %d, stood unlit %d, posted unstood %d, paid unposted %d, unpaid %d, bell %d, lamp %d, watch %d, relief %d, wage %d, loft %d, gate %d, yard %d, rung %d, lit %d, stood %d, posted %d; expected 1, 1, 1, 1, 2, 4, 19, 1, 1, 1, 2, 4, 19, 0, 57, 2, 3, 4, 6" % [sounded.get_sounded(), sounded.get_bell_left(), sounded_unrung, sounded_unlit, sounded_unstood, sounded_unposted, sounded_unpaid, sounded.get_bell_left(), sounded.get_lamp_left(), sounded.get_watch_left(), sounded.get_relief_left(), sounded.get_wage_left(), sounded.get_loft_left(), sounded.get_gate_left(), sounded.get_yard_left(), sounded.get_rung(), sounded.get_lit(), sounded.get_stood(), sounded.get_posted()])
	if int(sounded.get_sounded()) > int(Sim.HORN_CAP):
		_fail(errors, "horn sounded %d, over the cap of %d" % [sounded.get_sounded(), Sim.HORN_CAP])
	var horn_salt: Dictionary = sounded.get_cell_salt(int(horn_cell[0]), int(horn_cell[1]))
	var bell_salt: Dictionary = sounded.get_cell_salt(int(bell_cell[0]), int(bell_cell[1]))
	var lamp_salt: Dictionary = sounded.get_cell_salt(int(lamp_cell[0]), int(lamp_cell[1]))
	var watch_salt: Dictionary = sounded.get_cell_salt(int(watch_cell[0]), int(watch_cell[1]))
	var relief_salt: Dictionary = sounded.get_cell_salt(int(relief_cell[0]), int(relief_cell[1]))
	var wage_salt: Dictionary = sounded.get_cell_salt(int(wage_cell[0]), int(wage_cell[1]))
	var gate_salt: Dictionary = sounded.get_cell_salt(int(gate_cell[0]), int(gate_cell[1]))
	var loft_salt: Dictionary = sounded.get_cell_salt(int(loft_cell[0]), int(loft_cell[1]))
	var yard_salt: Dictionary = sounded.get_cell_salt(int(yard_cell[0]), int(yard_cell[1]))
	if int(horn_salt.get("horn", 0)) != 1 or int(bell_salt.get("bell", 0)) != 1 or int(lamp_salt.get("lamp", 0)) != 1 or int(watch_salt.get("watch", 0)) != 1 or int(relief_salt.get("relief", 0)) != 2 or int(wage_salt.get("wage", 0)) != 4 or int(gate_salt.get("gate", 0)) != 0 or int(loft_salt.get("loft", 0)) != 19 or int(yard_salt.get("yard", 0)) != 57:
		_fail(errors, "horn cell holds %s, bell holds %s, lamp holds %s, watch holds %s, relief holds %s, wage holds %s, gate holds %s, loft holds %s, yard holds %s" % [horn_salt.get("horn", 0), bell_salt.get("bell", 0), lamp_salt.get("lamp", 0), watch_salt.get("watch", 0), relief_salt.get("relief", 0), wage_salt.get("wage", 0), gate_salt.get("gate", 0), loft_salt.get("loft", 0), yard_salt.get("yard", 0)])
	var sounded_summary := String(sounded.get_summary())
	if not sounded_summary.contains("Sounded 1 on the horn") or not sounded_summary.contains("Left 1 at the bell") or not sounded_summary.contains("Rung 2 on the bell") or not sounded_summary.contains("Left 1 at the lamp") or not sounded_summary.contains("Lit 3 on the lamp") or not sounded_summary.contains("Left 1 at the watch") or not sounded_summary.contains("Stood 4 on the watch") or not sounded_summary.contains("Left 2 at the relief") or not sounded_summary.contains("Posted 6") or not sounded_summary.contains("Left 4 at the wage") or not sounded_summary.contains("Paid 10") or not sounded_summary.contains("Left 19") or not sounded_summary.contains("Left 57"):
		_fail(errors, "sounded summary does not name the horn: %s" % sounded_summary)
	if not sounded_summary.contains("Coins 2997") or not sounded_summary.contains("Hired 29"):
		_fail(errors, "sounded summary dropped the earlier totals: %s" % sounded_summary)
	if int(sounded_again.get_sounded()) != int(sounded.get_sounded()) or int(sounded_again.get_bell_left()) != int(sounded.get_bell_left()) or int(sounded_again.get_rung()) != int(sounded.get_rung()) or int(sounded_again.get_lit()) != int(sounded.get_lit()) or int(sounded_again.get_stood()) != int(sounded.get_stood()) or int(sounded_again.get_posted()) != int(sounded.get_posted()) or int(sounded_again.get_yard_left()) != int(sounded.get_yard_left()) or int(sounded_again.get_stored_salt()) != int(sounded.get_stored_salt()) or String(sounded_again.get_summary()) != String(sounded.get_summary()):
		_fail(errors, "repeated horn paint sounded %d and left bell %d, then sounded %d and left bell %d" % [sounded.get_sounded(), sounded.get_bell_left(), sounded_again.get_sounded(), sounded_again.get_bell_left()])
	if int(late.get_sounded()) != 1 or int(late.get_bell_left()) != 1 or int(late.get_rung()) != 2 or int(late.get_lamp_left()) != 1 or int(late.get_lit()) != 3 or int(late.get_stood()) != 4 or int(late.get_posted()) != 6 or int(late.get_watch_left()) != 1 or int(late.get_relief_left()) != 2 or int(late.get_wage_left()) != 4 or int(late.get_paid()) != 10 or int(late.get_loft_left()) != 19 or int(late.get_yard_left()) != 57 or int(late.get_hired()) != 29 or int(late.get_coins()) != int(sounded.get_coins()) or int(late.get_stored_salt()) != int(sounded.get_stored_salt()) or int(late.get_carted()) != int(sounded.get_carted()) or int(late.get_shipped()) != int(sounded.get_shipped()):
		_fail(errors, "painting the horn at the horn beat (sounded %d bell %d rung %d lamp %d lit %d stood %d posted %d watch %d relief %d wage %d paid %d loft %d yard %d hired %d coins %d stored %d) did not match painting it early (sounded %d bell %d rung %d lamp %d lit %d stood %d posted %d watch %d relief %d wage %d paid %d loft %d yard %d hired %d coins %d stored %d)" % [late.get_sounded(), late.get_bell_left(), late.get_rung(), late.get_lamp_left(), late.get_lit(), late.get_stood(), late.get_posted(), late.get_watch_left(), late.get_relief_left(), late.get_wage_left(), late.get_paid(), late.get_loft_left(), late.get_yard_left(), late.get_hired(), late.get_coins(), late.get_stored_salt(), sounded.get_sounded(), sounded.get_bell_left(), sounded.get_rung(), sounded.get_lamp_left(), sounded.get_lit(), sounded.get_stood(), sounded.get_posted(), sounded.get_watch_left(), sounded.get_relief_left(), sounded.get_wage_left(), sounded.get_paid(), sounded.get_loft_left(), sounded.get_yard_left(), sounded.get_hired(), sounded.get_coins(), sounded.get_stored_salt()])
	_assert_chain(dry_sounded, errors, "dry horn", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 2, 1)
	var dry_unpaid := int(dry_sounded.get_hired()) - int(dry_sounded.get_paid())
	var dry_unposted := int(dry_sounded.get_paid()) - int(dry_sounded.get_posted())
	var dry_unstood := int(dry_sounded.get_posted()) - int(dry_sounded.get_stood())
	var dry_unlit := int(dry_sounded.get_stood()) - int(dry_sounded.get_lit())
	var dry_unrung := int(dry_sounded.get_lit()) - int(dry_sounded.get_rung())
	if int(dry_sounded.get_sounded()) != 1 or int(dry_sounded.get_bell_left()) != 1 or dry_unrung != 1 or dry_unlit != 1 or dry_unstood != 2 or dry_unposted != 2 or dry_unpaid != 2 or int(dry_sounded.get_lamp_left()) != 1 or int(dry_sounded.get_watch_left()) != 1 or int(dry_sounded.get_relief_left()) != 2 or int(dry_sounded.get_wage_left()) != 2 or int(dry_sounded.get_gate_left()) != 2 or int(dry_sounded.get_loft_left()) != 0 or int(dry_sounded.get_yard_left()) != 0 or int(dry_sounded.get_rung()) != 2 or int(dry_sounded.get_lit()) != 3 or int(dry_sounded.get_stood()) != 4 or int(dry_sounded.get_posted()) != 6 or int(dry_sounded.get_wet_haul()) != 0:
		_fail(errors, "dry horn changed the short crew (wet %d stored %d carted %d shipped %d coins %d hired %d paid %d posted %d stood %d lit %d rung %d sounded %d bell %d unrung %d unlit %d unstood %d unposted %d unpaid %d lamp %d watch %d relief %d wage %d gate %d loft %d yard %d)" % [dry_sounded.get_wet_haul(), dry_sounded.get_stored_salt(), dry_sounded.get_carted(), dry_sounded.get_shipped(), dry_sounded.get_coins(), dry_sounded.get_hired(), dry_sounded.get_paid(), dry_sounded.get_posted(), dry_sounded.get_stood(), dry_sounded.get_lit(), dry_sounded.get_rung(), dry_sounded.get_sounded(), dry_sounded.get_bell_left(), dry_unrung, dry_unlit, dry_unstood, dry_unposted, dry_unpaid, dry_sounded.get_lamp_left(), dry_sounded.get_watch_left(), dry_sounded.get_relief_left(), dry_sounded.get_wage_left(), dry_sounded.get_gate_left(), dry_sounded.get_loft_left(), dry_sounded.get_yard_left()])
	var dry_horn_cell = plans["dry_sounded"]["horn"][0]
	var dry_bell_cell = plans["dry_sounded"]["bell"][0]
	var dry_lamp_cell = plans["dry_sounded"]["lamp"][0]
	var dry_watch_cell = plans["dry_sounded"]["watch"][0]
	var dry_relief_cell = plans["dry_sounded"]["relief"][0]
	var dry_wage_cell = plans["dry_sounded"]["wage"][0]
	var dry_gate_cell = plans["dry_sounded"]["gate"][0]
	var dry_horn_salt: Dictionary = dry_sounded.get_cell_salt(int(dry_horn_cell[0]), int(dry_horn_cell[1]))
	var dry_bell_salt: Dictionary = dry_sounded.get_cell_salt(int(dry_bell_cell[0]), int(dry_bell_cell[1]))
	var dry_lamp_salt: Dictionary = dry_sounded.get_cell_salt(int(dry_lamp_cell[0]), int(dry_lamp_cell[1]))
	var dry_watch_salt: Dictionary = dry_sounded.get_cell_salt(int(dry_watch_cell[0]), int(dry_watch_cell[1]))
	var dry_relief_salt: Dictionary = dry_sounded.get_cell_salt(int(dry_relief_cell[0]), int(dry_relief_cell[1]))
	var dry_wage_salt: Dictionary = dry_sounded.get_cell_salt(int(dry_wage_cell[0]), int(dry_wage_cell[1]))
	var dry_gate_salt: Dictionary = dry_sounded.get_cell_salt(int(dry_gate_cell[0]), int(dry_gate_cell[1]))
	if int(dry_horn_salt.get("horn", 0)) != 1 or int(dry_bell_salt.get("bell", 0)) != 1 or int(dry_lamp_salt.get("lamp", 0)) != 1 or int(dry_watch_salt.get("watch", 0)) != 1 or int(dry_relief_salt.get("relief", 0)) != 2 or int(dry_wage_salt.get("wage", 0)) != 2 or int(dry_gate_salt.get("gate", 0)) != 2:
		_fail(errors, "dry horn cell holds %s, bell holds %s, lamp holds %s, watch holds %s, relief holds %s, wage holds %s, gate holds %s" % [dry_horn_salt.get("horn", 0), dry_bell_salt.get("bell", 0), dry_lamp_salt.get("lamp", 0), dry_watch_salt.get("watch", 0), dry_relief_salt.get("relief", 0), dry_wage_salt.get("wage", 0), dry_gate_salt.get("gate", 0)])
	if not String(dry_sounded.get_summary()).contains("Sounded 1 on the horn") or not String(dry_sounded.get_summary()).contains("Left 1 at the bell") or not String(dry_sounded.get_summary()).contains("Rung 2 on the bell") or not String(dry_sounded.get_summary()).contains("Left 1 at the lamp") or not String(dry_sounded.get_summary()).contains("Lit 3 on the lamp") or not String(dry_sounded.get_summary()).contains("Left 1 at the watch") or not String(dry_sounded.get_summary()).contains("Stood 4 on the watch") or not String(dry_sounded.get_summary()).contains("Left 2 at the relief") or not String(dry_sounded.get_summary()).contains("Posted 6") or not String(dry_sounded.get_summary()).contains("Left 2 at the wage") or not String(dry_sounded.get_summary()).contains("Paid 8") or not String(dry_sounded.get_summary()).contains("Left 2 unpaid") or not String(dry_sounded.get_summary()).contains("Left 0 in the yard"):
		_fail(errors, "dry horn summary does not name the cap: %s" % dry_sounded.get_summary())
	_assert_pop(sounded, errors, "sounded plan")
	_assert_pop(sounded_again, errors, "sounded plan again")
	_assert_pop(late, errors, "late_sounded")
	_assert_pop(dry_sounded, errors, "dry_sounded")
	_assert_pop(ignored, errors, "no_horn")
	_assert_pop(bare, errors, "horn_only")
	# The cap stops the horn while ticks remain and rung hires remain.
	# Hires still in the loft, hires who passed and were not paid, hires who
	# were paid but not posted, hires who were posted but not stood, hires
	# who were stood but not lit, and hires who were lit but not rung, stay put.
	var shore = _prepare_plan(plans, "sounded", errors)
	if shore == null:
		return
	var shore_guard := 0
	var shore_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + 2
	while int(shore.get_beat()) != Sim.HORNING and not shore.is_over() and shore_guard < shore_limit:
		shore.tick()
		shore_guard += 1
	if int(shore.get_beat()) != Sim.HORNING or shore.is_over():
		_fail(errors, "the bell beat did not open a horn beat for the cap check")
		return
	if int(shore.get_ticks_until_rain()) != int(Sim.HORN_TICK):
		_fail(errors, "horn countdown started at %d, expected %d" % [shore.get_ticks_until_rain(), Sim.HORN_TICK])
	if int(shore.get_sounded()) != 0 or int(shore.get_rung()) != 2 or int(shore.get_bell_left()) != 2 or int(shore.get_lit()) != 3 or int(shore.get_lamp_left()) != 1 or int(shore.get_stood()) != 4 or int(shore.get_watch_left()) != 1 or int(shore.get_posted()) != 6 or int(shore.get_yard_left()) != 57:
		_fail(errors, "horn opened early (sounded %d rung %d bell %d lit %d lamp %d stood %d watch %d posted %d yard %d)" % [shore.get_sounded(), shore.get_rung(), shore.get_bell_left(), shore.get_lit(), shore.get_lamp_left(), shore.get_stood(), shore.get_watch_left(), shore.get_posted(), shore.get_yard_left()])
	var saw_cap := false
	var sound_guard := 0
	while not shore.is_over() and sound_guard < int(Sim.HORN_TICK) + 2:
		shore.tick()
		sound_guard += 1
		if int(shore.get_sounded()) == int(Sim.HORN_CAP) and int(shore.get_bell_left()) == 1 and int(shore.get_rung()) == 2 and int(shore.get_lamp_left()) == 1 and int(shore.get_lit()) == 3 and int(shore.get_watch_left()) == 1 and int(shore.get_stood()) == 4 and int(shore.get_relief_left()) == 2 and int(shore.get_posted()) == 6 and int(shore.get_wage_left()) == 4 and int(shore.get_paid()) == 10 and int(shore.get_loft_left()) == 19 and int(shore.get_gate_left()) == 0 and int(shore.get_yard_left()) == 57 and int(shore.get_ticks_until_rain()) > 0:
			saw_cap = true
			var ticks_left := int(shore.get_ticks_until_rain())
			shore.tick()
			if int(shore.get_sounded()) != int(Sim.HORN_CAP) or int(shore.get_bell_left()) != 1 or int(shore.get_rung()) != 2 or int(shore.get_lamp_left()) != 1 or int(shore.get_lit()) != 3 or int(shore.get_watch_left()) != 1 or int(shore.get_stood()) != 4 or int(shore.get_relief_left()) != 2 or int(shore.get_posted()) != 6 or int(shore.get_wage_left()) != 4 or int(shore.get_loft_left()) != 19 or int(shore.get_gate_left()) != 0 or int(shore.get_yard_left()) != 57 or int(shore.get_paid()) != 10 or int(shore.get_stored_salt()) != 2997 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29:
				_fail(errors, "the horn kept sounding after the cap (sounded %d bell %d rung %d lamp %d lit %d watch %d stood %d relief %d posted %d wage %d loft %d gate %d yard %d paid %d)" % [shore.get_sounded(), shore.get_bell_left(), shore.get_rung(), shore.get_lamp_left(), shore.get_lit(), shore.get_watch_left(), shore.get_stood(), shore.get_relief_left(), shore.get_posted(), shore.get_wage_left(), shore.get_loft_left(), shore.get_gate_left(), shore.get_yard_left(), shore.get_paid()])
			elif not shore.is_over() and int(shore.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the horn beat did not spend a tick after the cap")
			break
	if not saw_cap:
		_fail(errors, "the horn did not stop at %d while ticks remained (sounded %d bell %d rung %d lamp %d lit %d watch %d stood %d relief %d posted %d wage %d loft %d yard %d ticks %d)" % [Sim.HORN_CAP, shore.get_sounded(), shore.get_bell_left(), shore.get_rung(), shore.get_lamp_left(), shore.get_lit(), shore.get_watch_left(), shore.get_stood(), shore.get_relief_left(), shore.get_posted(), shore.get_wage_left(), shore.get_loft_left(), shore.get_yard_left(), shore.get_ticks_until_rain()])
	# Dry pans ring 2 and the cap still sounds only 1. The 1 who was rung and
	# not sounded stays on the bell. The 1 who was lit and not rung stays on
	# the lamp. The 1 who was stood and not lit stays on the watch. The 2 who
	# were posted and not stood stay on the relief. The 2 who were paid and not
	# posted stay on the wage. The 2 who passed and were not paid stay on the
	# gate. The yard stays empty.
	var short = _prepare_plan(plans, "dry_sounded", errors)
	if short == null:
		return
	var short_guard := 0
	while int(short.get_beat()) != Sim.HORNING and not short.is_over() and short_guard < shore_limit:
		short.tick()
		short_guard += 1
	if int(short.get_beat()) != Sim.HORNING or short.is_over():
		_fail(errors, "the bell beat did not open a horn beat for the dry cap")
		return
	var saw_short := false
	var short_steps := 0
	while not short.is_over() and short_steps < int(Sim.HORN_TICK) + 2:
		short.tick()
		short_steps += 1
		if int(short.get_sounded()) == int(Sim.HORN_CAP) and int(short.get_bell_left()) == 1 and int(short.get_rung()) == 2 and int(short.get_lamp_left()) == 1 and int(short.get_lit()) == 3 and int(short.get_watch_left()) == 1 and int(short.get_stood()) == 4 and int(short.get_relief_left()) == 2 and int(short.get_posted()) == 6 and int(short.get_wage_left()) == 2 and int(short.get_gate_left()) == 2 and int(short.get_paid()) == 8 and int(short.get_yard_left()) == 0 and int(short.get_loft_left()) == 0 and int(short.get_ticks_until_rain()) > 0:
			saw_short = true
			var short_ticks := int(short.get_ticks_until_rain())
			short.tick()
			if int(short.get_sounded()) != 1 or int(short.get_bell_left()) != 1 or int(short.get_lamp_left()) != 1 or int(short.get_watch_left()) != 1 or int(short.get_relief_left()) != 2 or int(short.get_wage_left()) != 2 or int(short.get_gate_left()) != 2 or int(short.get_yard_left()) != 0 or int(short.get_rung()) != 2 or int(short.get_lit()) != 3 or int(short.get_stood()) != 4 or int(short.get_posted()) != 6 or int(short.get_paid()) != 8:
				_fail(errors, "the horn sounded an unrung hire or passed the cap (sounded %d bell %d lamp %d watch %d relief %d wage %d gate %d yard %d rung %d lit %d stood %d posted %d paid %d)" % [short.get_sounded(), short.get_bell_left(), short.get_lamp_left(), short.get_watch_left(), short.get_relief_left(), short.get_wage_left(), short.get_gate_left(), short.get_yard_left(), short.get_rung(), short.get_lit(), short.get_stood(), short.get_posted(), short.get_paid()])
			elif not short.is_over() and int(short.get_ticks_until_rain()) >= short_ticks:
				_fail(errors, "the horn beat did not spend a tick after the dry cap")
			break
	if not saw_short:
		_fail(errors, "dry horn did not stop at 1 with unrung hires left (sounded %d bell %d lamp %d watch %d relief %d wage %d gate %d yard %d rung %d lit %d stood %d posted %d paid %d ticks %d)" % [short.get_sounded(), short.get_bell_left(), short.get_lamp_left(), short.get_watch_left(), short.get_relief_left(), short.get_wage_left(), short.get_gate_left(), short.get_yard_left(), short.get_rung(), short.get_lit(), short.get_stood(), short.get_posted(), short.get_paid(), short.get_ticks_until_rain()])
	print("sounded %d left bell %d unrung %d unlit %d unstood %d unposted %d unpaid %d; dry sounded %d left bell %d unrung %d unlit %d unstood %d unposted %d unpaid %d; no horn sounded %d left bell %d; horn without bell sounded %d" % [sounded.get_sounded(), sounded.get_bell_left(), sounded_unrung, sounded_unlit, sounded_unstood, sounded_unposted, sounded_unpaid, dry_sounded.get_sounded(), dry_sounded.get_bell_left(), dry_unrung, dry_unlit, dry_unstood, dry_unposted, dry_unpaid, ignored.get_sounded(), ignored.get_bell_left(), bare.get_sounded()])


func _test_flag(errors: Array) -> void:
	if int(Sim.FLAG_TICK) != 100 or int(Sim.FLAG_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "flag beat length %s is not 100 ticks (10 seconds)" % Sim.FLAG_TICK)
	if int(Sim.FLAG_CAP) != 1:
		_fail(errors, "flag cap is %s, expected 1" % Sim.FLAG_CAP)
	var fresh = Sim.new()
	if fresh.paint_cell(14, -9, Sim.FLAG) == false or int(fresh.get_paint(14, -9)) != Sim.FLAG:
		_fail(errors, "the cell north of the horn rejected the flag mark")
	if fresh.paint_cell(14, -11, Sim.FLAG):
		_fail(errors, "the row north of the banner accepted a mark")
	if fresh.paint_cell(Sim.COAST_X, -9, Sim.FLAG):
		_fail(errors, "the brine accepted a flag")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.FLAG):
		_fail(errors, "the anthill accepted a flag")
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
	var rung = _run_plan(plans, "rung", errors)
	var dry_rung = _run_plan(plans, "dry_rung", errors)
	var sounded = _run_plan(plans, "sounded", errors)
	var dry_sounded = _run_plan(plans, "dry_sounded", errors)
	var ignored = _run_plan(plans, "no_flag", errors)
	var bare = _run_plan(plans, "flag_only", errors)
	var raised = _run_plan(plans, "raised", errors)
	var raised_again = _run_plan(plans, "raised", errors)
	var late = _run_plan(plans, "late_raised", errors)
	var dry_raised = _run_plan(plans, "dry_raised", errors)
	if won == null or dry == null or parked == null or loaded == null or sold == null or hired == null or lofted == null or passed == null or paid == null or dry_paid == null or posted == null or dry_posted == null or stood == null or dry_stood == null or lit == null or dry_lit == null or rung == null or dry_rung == null or sounded == null or dry_sounded == null or ignored == null or bare == null or raised == null or raised_again == null or late == null or dry_raised == null:
		return
	# Earlier plans keep the numbers they had before the flag existed.
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
	_assert_chain(rung, errors, "rung plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2)
	_assert_chain(dry_rung, errors, "dry bell", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 2)
	_assert_chain(sounded, errors, "sounded plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2, 1)
	_assert_chain(dry_sounded, errors, "dry horn", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 2, 1)
	# Sounded, no flag: the 1 who was sounded stays on the horn. The 1 rung but
	# not sounded stays on the bell. The 1 lit but not rung stays on the lamp.
	# The 1 stood but not lit stays on the watch. The 2 posted but not stood
	# stay on the relief. The 4 paid but not posted stay on the wage. The 19
	# in the loft stay unpaid.
	var ignored_unpaid := int(ignored.get_hired()) - int(ignored.get_paid())
	var ignored_unposted := int(ignored.get_paid()) - int(ignored.get_posted())
	var ignored_unstood := int(ignored.get_posted()) - int(ignored.get_stood())
	var ignored_unlit := int(ignored.get_stood()) - int(ignored.get_lit())
	var ignored_unrung := int(ignored.get_lit()) - int(ignored.get_rung())
	var ignored_unraised := int(ignored.get_sounded()) - int(ignored.get_raised())
	if int(ignored.get_raised()) != 0 or int(ignored.get_horn_left()) != 1 or ignored_unraised != 1 or int(ignored.get_sounded()) != 1 or int(ignored.get_bell_left()) != 1 or int(ignored.get_rung()) != 2 or ignored_unrung != 1 or int(ignored.get_lamp_left()) != 1 or int(ignored.get_lit()) != 3 or ignored_unlit != 1 or int(ignored.get_watch_left()) != 1 or ignored_unstood != 2 or ignored_unposted != 4 or ignored_unpaid != 19 or int(ignored.get_relief_left()) != 2 or int(ignored.get_wage_left()) != 4 or int(ignored.get_loft_left()) != 19 or int(ignored.get_gate_left()) != 0 or int(ignored.get_yard_left()) != 57 or int(ignored.get_stood()) != 4 or int(ignored.get_posted()) != 6 or int(ignored.get_paid()) != 10 or int(ignored.get_hired()) != 29 or int(ignored.get_coins()) != 2997 or int(ignored.get_stored_salt()) != 2997 or int(ignored.get_carted()) != 2997 or int(ignored.get_shipped()) != 2997:
		_fail(errors, "no_flag raised someone (stored %d carted %d shipped %d coins %d hired %d yard %d paid %d posted %d stood %d lit %d rung %d sounded %d horn %d raised %d unpaid %d unposted %d unstood %d loft %d wage %d)" % [ignored.get_stored_salt(), ignored.get_carted(), ignored.get_shipped(), ignored.get_coins(), ignored.get_hired(), ignored.get_yard_left(), ignored.get_paid(), ignored.get_posted(), ignored.get_stood(), ignored.get_lit(), ignored.get_rung(), ignored.get_sounded(), ignored.get_horn_left(), ignored.get_raised(), ignored_unpaid, ignored_unposted, ignored_unstood, ignored.get_loft_left(), ignored.get_wage_left()])
	if String(ignored.get_summary()) != String(sounded.get_summary()):
		_fail(errors, "no_flag summary changed: %s" % ignored.get_summary())
	if String(ignored.get_summary()).to_lower().contains("raised") or String(ignored.get_summary()).to_lower().contains("flag"):
		_fail(errors, "no_flag summary names a flag: %s" % ignored.get_summary())
	var ignored_horn = plans["no_flag"]["horn"][0]
	var ignored_salt: Dictionary = ignored.get_cell_salt(int(ignored_horn[0]), int(ignored_horn[1]))
	var ignored_north: Dictionary = ignored.get_cell_salt(int(ignored_horn[0]), int(ignored_horn[1]) - 1)
	if int(ignored_salt.get("horn", 0)) != 1 or int(ignored_north.get("flag", 0)) != 0 or int(ignored_salt.get("flag", 0)) != 0:
		_fail(errors, "no_flag left %s at the horn and %s at a flag" % [ignored_salt.get("horn", 0), ignored_north.get("flag", 0)])
	# A flag with nobody sounded raises nobody. Rung hires stay on the bell.
	var bare_unpaid := int(bare.get_hired()) - int(bare.get_paid())
	var bare_unstood := int(bare.get_posted()) - int(bare.get_stood())
	if int(bare.get_raised()) != 0 or int(bare.get_sounded()) != 0 or int(bare.get_horn_left()) != 0 or int(bare.get_rung()) != 2 or int(bare.get_bell_left()) != 2 or int(bare.get_lit()) != 3 or int(bare.get_lamp_left()) != 1 or int(bare.get_stood()) != 4 or int(bare.get_watch_left()) != 1 or int(bare.get_posted()) != 6 or int(bare.get_relief_left()) != 2 or bare_unstood != 2 or int(bare.get_paid()) != 10 or int(bare.get_wage_left()) != 4 or bare_unpaid != 19 or int(bare.get_loft_left()) != 19 or int(bare.get_gate_left()) != 0 or int(bare.get_yard_left()) != 57 or int(bare.get_hired()) != 29 or int(bare.get_coins()) != 2997 or int(bare.get_stored_salt()) != 2997 or int(bare.get_carted()) != 2997 or int(bare.get_shipped()) != 2997:
		_fail(errors, "flag without a horn raised someone (stored %d carted %d shipped %d coins %d hired %d yard %d paid %d wage %d posted %d relief %d stood %d watch %d lit %d lamp %d rung %d bell %d sounded %d raised %d unpaid %d loft %d)" % [bare.get_stored_salt(), bare.get_carted(), bare.get_shipped(), bare.get_coins(), bare.get_hired(), bare.get_yard_left(), bare.get_paid(), bare.get_wage_left(), bare.get_posted(), bare.get_relief_left(), bare.get_stood(), bare.get_watch_left(), bare.get_lit(), bare.get_lamp_left(), bare.get_rung(), bare.get_bell_left(), bare.get_sounded(), bare.get_raised(), bare_unpaid, bare.get_loft_left()])
	if String(bare.get_summary()) != String(rung.get_summary()):
		_fail(errors, "flag without a horn changed the summary: %s" % bare.get_summary())
	if String(bare.get_summary()).to_lower().contains("raised") or String(bare.get_summary()).to_lower().contains("flag") or String(bare.get_summary()).to_lower().contains("sounded") or String(bare.get_summary()).to_lower().contains("horn"):
		_fail(errors, "flag without a horn names a flag: %s" % bare.get_summary())
	var bare_flag = plans["flag_only"]["flag"][0]
	var bare_bell = plans["flag_only"]["bell"][0]
	var bare_flag_salt: Dictionary = bare.get_cell_salt(int(bare_flag[0]), int(bare_flag[1]))
	var bare_bell_salt: Dictionary = bare.get_cell_salt(int(bare_bell[0]), int(bare_bell[1]))
	if int(bare_flag_salt.get("flag", 0)) != 0 or int(bare_bell_salt.get("bell", 0)) != 2 or int(bare_flag_salt.get("horn", 0)) != 0:
		_fail(errors, "flag without a horn holds %s, bell holds %s" % [bare_flag_salt.get("flag", 0), bare_bell_salt.get("bell", 0)])
	var flag_cell = plans["raised"]["flag"][0]
	var horn_cell = plans["raised"]["horn"][0]
	var bell_cell = plans["raised"]["bell"][0]
	var lamp_cell = plans["raised"]["lamp"][0]
	var watch_cell = plans["raised"]["watch"][0]
	var relief_cell = plans["raised"]["relief"][0]
	var wage_cell = plans["raised"]["wage"][0]
	var gate_cell = plans["raised"]["gate"][0]
	var loft_cell = plans["raised"]["loft"][0]
	var yard_cell = plans["raised"]["yard"][0]
	if int(flag_cell[0]) != int(horn_cell[0]) or int(flag_cell[1]) != int(horn_cell[1]) - 1:
		_fail(errors, "raised plan's flag is not one cell north of the horn")
	if int(horn_cell[0]) != 14 or int(horn_cell[1]) != -8 or int(flag_cell[0]) != 14 or int(flag_cell[1]) != -9:
		_fail(errors, "raised plan's flag is not at 14,-9 north of the horn at 14,-8")
	if int(horn_cell[0]) != int(bell_cell[0]) or int(horn_cell[1]) != int(bell_cell[1]) - 1:
		_fail(errors, "raised plan's horn is not one cell north of the bell")
	_assert_chain(raised, errors, "raised plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2, 1, 1)
	var raised_unpaid := int(raised.get_hired()) - int(raised.get_paid())
	var raised_unposted := int(raised.get_paid()) - int(raised.get_posted())
	var raised_unstood := int(raised.get_posted()) - int(raised.get_stood())
	var raised_unlit := int(raised.get_stood()) - int(raised.get_lit())
	var raised_unrung := int(raised.get_lit()) - int(raised.get_rung())
	var raised_unraised := int(raised.get_sounded()) - int(raised.get_raised())
	if int(raised.get_raised()) != 1 or int(raised.get_horn_left()) != 0 or raised_unraised != 0 or int(raised.get_bell_left()) != 1 or raised_unrung != 1 or raised_unlit != 1 or raised_unstood != 2 or raised_unposted != 4 or raised_unpaid != 19 or int(raised.get_lamp_left()) != 1 or int(raised.get_watch_left()) != 1 or int(raised.get_relief_left()) != 2 or int(raised.get_wage_left()) != 4 or int(raised.get_loft_left()) != 19 or int(raised.get_gate_left()) != 0 or int(raised.get_yard_left()) != 57 or int(raised.get_sounded()) != 1 or int(raised.get_rung()) != 2 or int(raised.get_lit()) != 3 or int(raised.get_stood()) != 4 or int(raised.get_posted()) != 6:
		_fail(errors, "raised %d, left %d sounded unraised, rung unsounded %d, lit unrung %d, stood unlit %d, posted unstood %d, paid unposted %d, unpaid %d, horn %d, bell %d, lamp %d, watch %d, relief %d, wage %d, loft %d, gate %d, yard %d, sounded %d, rung %d, lit %d, stood %d, posted %d; expected 1, 0, 1, 1, 1, 2, 4, 19, 0, 1, 1, 1, 2, 4, 19, 0, 57, 1, 2, 3, 4, 6" % [raised.get_raised(), raised.get_horn_left(), raised.get_bell_left(), raised_unrung, raised_unlit, raised_unstood, raised_unposted, raised_unpaid, raised.get_horn_left(), raised.get_bell_left(), raised.get_lamp_left(), raised.get_watch_left(), raised.get_relief_left(), raised.get_wage_left(), raised.get_loft_left(), raised.get_gate_left(), raised.get_yard_left(), raised.get_sounded(), raised.get_rung(), raised.get_lit(), raised.get_stood(), raised.get_posted()])
	if int(raised.get_raised()) > int(Sim.FLAG_CAP):
		_fail(errors, "flag raised %d, over the cap of %d" % [raised.get_raised(), Sim.FLAG_CAP])
	var flag_salt: Dictionary = raised.get_cell_salt(int(flag_cell[0]), int(flag_cell[1]))
	var horn_salt: Dictionary = raised.get_cell_salt(int(horn_cell[0]), int(horn_cell[1]))
	var bell_salt: Dictionary = raised.get_cell_salt(int(bell_cell[0]), int(bell_cell[1]))
	var lamp_salt: Dictionary = raised.get_cell_salt(int(lamp_cell[0]), int(lamp_cell[1]))
	var watch_salt: Dictionary = raised.get_cell_salt(int(watch_cell[0]), int(watch_cell[1]))
	var relief_salt: Dictionary = raised.get_cell_salt(int(relief_cell[0]), int(relief_cell[1]))
	var wage_salt: Dictionary = raised.get_cell_salt(int(wage_cell[0]), int(wage_cell[1]))
	var gate_salt: Dictionary = raised.get_cell_salt(int(gate_cell[0]), int(gate_cell[1]))
	var loft_salt: Dictionary = raised.get_cell_salt(int(loft_cell[0]), int(loft_cell[1]))
	var yard_salt: Dictionary = raised.get_cell_salt(int(yard_cell[0]), int(yard_cell[1]))
	if int(flag_salt.get("flag", 0)) != 1 or int(horn_salt.get("horn", 0)) != 0 or int(bell_salt.get("bell", 0)) != 1 or int(lamp_salt.get("lamp", 0)) != 1 or int(watch_salt.get("watch", 0)) != 1 or int(relief_salt.get("relief", 0)) != 2 or int(wage_salt.get("wage", 0)) != 4 or int(gate_salt.get("gate", 0)) != 0 or int(loft_salt.get("loft", 0)) != 19 or int(yard_salt.get("yard", 0)) != 57:
		_fail(errors, "flag cell holds %s, horn holds %s, bell holds %s, lamp holds %s, watch holds %s, relief holds %s, wage holds %s, gate holds %s, loft holds %s, yard holds %s" % [flag_salt.get("flag", 0), horn_salt.get("horn", 0), bell_salt.get("bell", 0), lamp_salt.get("lamp", 0), watch_salt.get("watch", 0), relief_salt.get("relief", 0), wage_salt.get("wage", 0), gate_salt.get("gate", 0), loft_salt.get("loft", 0), yard_salt.get("yard", 0)])
	var raised_summary := String(raised.get_summary())
	if not raised_summary.contains("Raised 1 on the flag") or not raised_summary.contains("Left 0 at the horn") or not raised_summary.contains("Sounded 1 on the horn") or not raised_summary.contains("Left 1 at the bell") or not raised_summary.contains("Rung 2 on the bell") or not raised_summary.contains("Left 1 at the lamp") or not raised_summary.contains("Lit 3 on the lamp") or not raised_summary.contains("Left 1 at the watch") or not raised_summary.contains("Stood 4 on the watch") or not raised_summary.contains("Left 2 at the relief") or not raised_summary.contains("Posted 6") or not raised_summary.contains("Left 4 at the wage") or not raised_summary.contains("Paid 10") or not raised_summary.contains("Left 19") or not raised_summary.contains("Left 57"):
		_fail(errors, "raised summary does not name the flag: %s" % raised_summary)
	if not raised_summary.contains("Coins 2997") or not raised_summary.contains("Hired 29"):
		_fail(errors, "raised summary dropped the earlier totals: %s" % raised_summary)
	if int(raised_again.get_raised()) != int(raised.get_raised()) or int(raised_again.get_horn_left()) != int(raised.get_horn_left()) or int(raised_again.get_sounded()) != int(raised.get_sounded()) or int(raised_again.get_rung()) != int(raised.get_rung()) or int(raised_again.get_lit()) != int(raised.get_lit()) or int(raised_again.get_stood()) != int(raised.get_stood()) or int(raised_again.get_posted()) != int(raised.get_posted()) or int(raised_again.get_yard_left()) != int(raised.get_yard_left()) or int(raised_again.get_stored_salt()) != int(raised.get_stored_salt()) or String(raised_again.get_summary()) != String(raised.get_summary()):
		_fail(errors, "repeated flag paint raised %d and left horn %d, then raised %d and left horn %d" % [raised.get_raised(), raised.get_horn_left(), raised_again.get_raised(), raised_again.get_horn_left()])
	if int(late.get_raised()) != 1 or int(late.get_horn_left()) != 0 or int(late.get_sounded()) != 1 or int(late.get_bell_left()) != 1 or int(late.get_rung()) != 2 or int(late.get_lamp_left()) != 1 or int(late.get_lit()) != 3 or int(late.get_stood()) != 4 or int(late.get_posted()) != 6 or int(late.get_watch_left()) != 1 or int(late.get_relief_left()) != 2 or int(late.get_wage_left()) != 4 or int(late.get_paid()) != 10 or int(late.get_loft_left()) != 19 or int(late.get_yard_left()) != 57 or int(late.get_hired()) != 29 or int(late.get_coins()) != int(raised.get_coins()) or int(late.get_stored_salt()) != int(raised.get_stored_salt()) or int(late.get_carted()) != int(raised.get_carted()) or int(late.get_shipped()) != int(raised.get_shipped()):
		_fail(errors, "painting the flag at the flag beat (raised %d horn %d sounded %d bell %d rung %d lamp %d lit %d stood %d posted %d watch %d relief %d wage %d paid %d loft %d yard %d hired %d coins %d stored %d) did not match painting it early (raised %d horn %d sounded %d bell %d rung %d lamp %d lit %d stood %d posted %d watch %d relief %d wage %d paid %d loft %d yard %d hired %d coins %d stored %d)" % [late.get_raised(), late.get_horn_left(), late.get_sounded(), late.get_bell_left(), late.get_rung(), late.get_lamp_left(), late.get_lit(), late.get_stood(), late.get_posted(), late.get_watch_left(), late.get_relief_left(), late.get_wage_left(), late.get_paid(), late.get_loft_left(), late.get_yard_left(), late.get_hired(), late.get_coins(), late.get_stored_salt(), raised.get_raised(), raised.get_horn_left(), raised.get_sounded(), raised.get_bell_left(), raised.get_rung(), raised.get_lamp_left(), raised.get_lit(), raised.get_stood(), raised.get_posted(), raised.get_watch_left(), raised.get_relief_left(), raised.get_wage_left(), raised.get_paid(), raised.get_loft_left(), raised.get_yard_left(), raised.get_hired(), raised.get_coins(), raised.get_stored_salt()])
	_assert_chain(dry_raised, errors, "dry flag", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 2, 1, 1)
	var dry_unpaid := int(dry_raised.get_hired()) - int(dry_raised.get_paid())
	var dry_unposted := int(dry_raised.get_paid()) - int(dry_raised.get_posted())
	var dry_unstood := int(dry_raised.get_posted()) - int(dry_raised.get_stood())
	var dry_unlit := int(dry_raised.get_stood()) - int(dry_raised.get_lit())
	var dry_unrung := int(dry_raised.get_lit()) - int(dry_raised.get_rung())
	var dry_unraised := int(dry_raised.get_sounded()) - int(dry_raised.get_raised())
	if int(dry_raised.get_raised()) != 1 or int(dry_raised.get_horn_left()) != 0 or dry_unraised != 0 or int(dry_raised.get_bell_left()) != 1 or dry_unrung != 1 or dry_unlit != 1 or dry_unstood != 2 or dry_unposted != 2 or dry_unpaid != 2 or int(dry_raised.get_lamp_left()) != 1 or int(dry_raised.get_watch_left()) != 1 or int(dry_raised.get_relief_left()) != 2 or int(dry_raised.get_wage_left()) != 2 or int(dry_raised.get_gate_left()) != 2 or int(dry_raised.get_loft_left()) != 0 or int(dry_raised.get_yard_left()) != 0 or int(dry_raised.get_sounded()) != 1 or int(dry_raised.get_rung()) != 2 or int(dry_raised.get_lit()) != 3 or int(dry_raised.get_stood()) != 4 or int(dry_raised.get_posted()) != 6 or int(dry_raised.get_wet_haul()) != 0:
		_fail(errors, "dry flag changed the short crew (wet %d stored %d carted %d shipped %d coins %d hired %d paid %d posted %d stood %d lit %d rung %d sounded %d raised %d horn %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d lamp %d watch %d relief %d wage %d gate %d loft %d yard %d)" % [dry_raised.get_wet_haul(), dry_raised.get_stored_salt(), dry_raised.get_carted(), dry_raised.get_shipped(), dry_raised.get_coins(), dry_raised.get_hired(), dry_raised.get_paid(), dry_raised.get_posted(), dry_raised.get_stood(), dry_raised.get_lit(), dry_raised.get_rung(), dry_raised.get_sounded(), dry_raised.get_raised(), dry_raised.get_horn_left(), dry_unraised, dry_raised.get_bell_left(), dry_unrung, dry_unlit, dry_unstood, dry_unposted, dry_unpaid, dry_raised.get_lamp_left(), dry_raised.get_watch_left(), dry_raised.get_relief_left(), dry_raised.get_wage_left(), dry_raised.get_gate_left(), dry_raised.get_loft_left(), dry_raised.get_yard_left()])
	var dry_flag_cell = plans["dry_raised"]["flag"][0]
	var dry_horn_cell = plans["dry_raised"]["horn"][0]
	var dry_bell_cell = plans["dry_raised"]["bell"][0]
	var dry_lamp_cell = plans["dry_raised"]["lamp"][0]
	var dry_watch_cell = plans["dry_raised"]["watch"][0]
	var dry_relief_cell = plans["dry_raised"]["relief"][0]
	var dry_wage_cell = plans["dry_raised"]["wage"][0]
	var dry_gate_cell = plans["dry_raised"]["gate"][0]
	var dry_flag_salt: Dictionary = dry_raised.get_cell_salt(int(dry_flag_cell[0]), int(dry_flag_cell[1]))
	var dry_horn_salt: Dictionary = dry_raised.get_cell_salt(int(dry_horn_cell[0]), int(dry_horn_cell[1]))
	var dry_bell_salt: Dictionary = dry_raised.get_cell_salt(int(dry_bell_cell[0]), int(dry_bell_cell[1]))
	var dry_lamp_salt: Dictionary = dry_raised.get_cell_salt(int(dry_lamp_cell[0]), int(dry_lamp_cell[1]))
	var dry_watch_salt: Dictionary = dry_raised.get_cell_salt(int(dry_watch_cell[0]), int(dry_watch_cell[1]))
	var dry_relief_salt: Dictionary = dry_raised.get_cell_salt(int(dry_relief_cell[0]), int(dry_relief_cell[1]))
	var dry_wage_salt: Dictionary = dry_raised.get_cell_salt(int(dry_wage_cell[0]), int(dry_wage_cell[1]))
	var dry_gate_salt: Dictionary = dry_raised.get_cell_salt(int(dry_gate_cell[0]), int(dry_gate_cell[1]))
	if int(dry_flag_salt.get("flag", 0)) != 1 or int(dry_horn_salt.get("horn", 0)) != 0 or int(dry_bell_salt.get("bell", 0)) != 1 or int(dry_lamp_salt.get("lamp", 0)) != 1 or int(dry_watch_salt.get("watch", 0)) != 1 or int(dry_relief_salt.get("relief", 0)) != 2 or int(dry_wage_salt.get("wage", 0)) != 2 or int(dry_gate_salt.get("gate", 0)) != 2:
		_fail(errors, "dry flag cell holds %s, horn holds %s, bell holds %s, lamp holds %s, watch holds %s, relief holds %s, wage holds %s, gate holds %s" % [dry_flag_salt.get("flag", 0), dry_horn_salt.get("horn", 0), dry_bell_salt.get("bell", 0), dry_lamp_salt.get("lamp", 0), dry_watch_salt.get("watch", 0), dry_relief_salt.get("relief", 0), dry_wage_salt.get("wage", 0), dry_gate_salt.get("gate", 0)])
	if not String(dry_raised.get_summary()).contains("Raised 1 on the flag") or not String(dry_raised.get_summary()).contains("Left 0 at the horn") or not String(dry_raised.get_summary()).contains("Sounded 1 on the horn") or not String(dry_raised.get_summary()).contains("Left 1 at the bell") or not String(dry_raised.get_summary()).contains("Rung 2 on the bell") or not String(dry_raised.get_summary()).contains("Left 1 at the lamp") or not String(dry_raised.get_summary()).contains("Lit 3 on the lamp") or not String(dry_raised.get_summary()).contains("Left 1 at the watch") or not String(dry_raised.get_summary()).contains("Stood 4 on the watch") or not String(dry_raised.get_summary()).contains("Left 2 at the relief") or not String(dry_raised.get_summary()).contains("Posted 6") or not String(dry_raised.get_summary()).contains("Left 2 at the wage") or not String(dry_raised.get_summary()).contains("Paid 8") or not String(dry_raised.get_summary()).contains("Left 2 unpaid") or not String(dry_raised.get_summary()).contains("Left 0 in the yard"):
		_fail(errors, "dry flag summary does not name the cap: %s" % dry_raised.get_summary())
	_assert_pop(raised, errors, "raised plan")
	_assert_pop(raised_again, errors, "raised plan again")
	_assert_pop(late, errors, "late_raised")
	_assert_pop(dry_raised, errors, "dry_raised")
	_assert_pop(ignored, errors, "no_flag")
	_assert_pop(bare, errors, "flag_only")
	# The cap stops the flag while ticks remain. Because the horn sounded 1,
	# the winning shore leaves 0 sounded hires on the horn. Hires who were not
	# sounded stay put.
	var shore = _prepare_plan(plans, "raised", errors)
	if shore == null:
		return
	var shore_guard := 0
	var shore_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + 2
	while int(shore.get_beat()) != Sim.FLAGGING and not shore.is_over() and shore_guard < shore_limit:
		shore.tick()
		shore_guard += 1
	if int(shore.get_beat()) != Sim.FLAGGING or shore.is_over():
		_fail(errors, "the horn beat did not open a flag beat for the cap check")
		return
	if int(shore.get_ticks_until_rain()) != int(Sim.FLAG_TICK):
		_fail(errors, "flag countdown started at %d, expected %d" % [shore.get_ticks_until_rain(), Sim.FLAG_TICK])
	if int(shore.get_raised()) != 0 or int(shore.get_sounded()) != 1 or int(shore.get_horn_left()) != 1 or int(shore.get_rung()) != 2 or int(shore.get_bell_left()) != 1 or int(shore.get_lit()) != 3 or int(shore.get_lamp_left()) != 1 or int(shore.get_stood()) != 4 or int(shore.get_watch_left()) != 1 or int(shore.get_posted()) != 6 or int(shore.get_yard_left()) != 57:
		_fail(errors, "flag opened early (raised %d sounded %d horn %d rung %d bell %d lit %d lamp %d stood %d watch %d posted %d yard %d)" % [shore.get_raised(), shore.get_sounded(), shore.get_horn_left(), shore.get_rung(), shore.get_bell_left(), shore.get_lit(), shore.get_lamp_left(), shore.get_stood(), shore.get_watch_left(), shore.get_posted(), shore.get_yard_left()])
	var saw_cap := false
	var raise_guard := 0
	while not shore.is_over() and raise_guard < int(Sim.FLAG_TICK) + 2:
		shore.tick()
		raise_guard += 1
		if int(shore.get_raised()) == int(Sim.FLAG_CAP) and int(shore.get_horn_left()) == 0 and int(shore.get_sounded()) == 1 and int(shore.get_bell_left()) == 1 and int(shore.get_rung()) == 2 and int(shore.get_lamp_left()) == 1 and int(shore.get_lit()) == 3 and int(shore.get_watch_left()) == 1 and int(shore.get_stood()) == 4 and int(shore.get_relief_left()) == 2 and int(shore.get_posted()) == 6 and int(shore.get_wage_left()) == 4 and int(shore.get_paid()) == 10 and int(shore.get_loft_left()) == 19 and int(shore.get_gate_left()) == 0 and int(shore.get_yard_left()) == 57 and int(shore.get_ticks_until_rain()) > 0:
			saw_cap = true
			var ticks_left := int(shore.get_ticks_until_rain())
			shore.tick()
			if int(shore.get_raised()) != int(Sim.FLAG_CAP) or int(shore.get_horn_left()) != 0 or int(shore.get_sounded()) != 1 or int(shore.get_bell_left()) != 1 or int(shore.get_rung()) != 2 or int(shore.get_lamp_left()) != 1 or int(shore.get_lit()) != 3 or int(shore.get_watch_left()) != 1 or int(shore.get_stood()) != 4 or int(shore.get_relief_left()) != 2 or int(shore.get_posted()) != 6 or int(shore.get_wage_left()) != 4 or int(shore.get_loft_left()) != 19 or int(shore.get_gate_left()) != 0 or int(shore.get_yard_left()) != 57 or int(shore.get_paid()) != 10 or int(shore.get_stored_salt()) != 2997 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29:
				_fail(errors, "the flag kept raising after the cap (raised %d horn %d sounded %d bell %d rung %d lamp %d lit %d watch %d stood %d relief %d posted %d wage %d loft %d gate %d yard %d paid %d)" % [shore.get_raised(), shore.get_horn_left(), shore.get_sounded(), shore.get_bell_left(), shore.get_rung(), shore.get_lamp_left(), shore.get_lit(), shore.get_watch_left(), shore.get_stood(), shore.get_relief_left(), shore.get_posted(), shore.get_wage_left(), shore.get_loft_left(), shore.get_gate_left(), shore.get_yard_left(), shore.get_paid()])
			elif not shore.is_over() and int(shore.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the flag beat did not spend a tick after the cap")
			break
	if not saw_cap:
		_fail(errors, "the flag did not stop at %d while ticks remained (raised %d horn %d sounded %d bell %d rung %d lamp %d lit %d watch %d stood %d relief %d posted %d wage %d loft %d yard %d ticks %d)" % [Sim.FLAG_CAP, shore.get_raised(), shore.get_horn_left(), shore.get_sounded(), shore.get_bell_left(), shore.get_rung(), shore.get_lamp_left(), shore.get_lit(), shore.get_watch_left(), shore.get_stood(), shore.get_relief_left(), shore.get_posted(), shore.get_wage_left(), shore.get_loft_left(), shore.get_yard_left(), shore.get_ticks_until_rain()])
	# Dry pans sound 1 and the cap still raises only that 1. The horn is left
	# empty. The 1 who was rung and not sounded stays on the bell. The yard
	# stays empty.
	var short = _prepare_plan(plans, "dry_raised", errors)
	if short == null:
		return
	var short_guard := 0
	while int(short.get_beat()) != Sim.FLAGGING and not short.is_over() and short_guard < shore_limit:
		short.tick()
		short_guard += 1
	if int(short.get_beat()) != Sim.FLAGGING or short.is_over():
		_fail(errors, "the horn beat did not open a flag beat for the dry cap")
		return
	var saw_short := false
	var short_steps := 0
	while not short.is_over() and short_steps < int(Sim.FLAG_TICK) + 2:
		short.tick()
		short_steps += 1
		if int(short.get_raised()) == int(Sim.FLAG_CAP) and int(short.get_horn_left()) == 0 and int(short.get_sounded()) == 1 and int(short.get_bell_left()) == 1 and int(short.get_rung()) == 2 and int(short.get_lamp_left()) == 1 and int(short.get_lit()) == 3 and int(short.get_watch_left()) == 1 and int(short.get_stood()) == 4 and int(short.get_relief_left()) == 2 and int(short.get_posted()) == 6 and int(short.get_wage_left()) == 2 and int(short.get_gate_left()) == 2 and int(short.get_paid()) == 8 and int(short.get_yard_left()) == 0 and int(short.get_loft_left()) == 0 and int(short.get_ticks_until_rain()) > 0:
			saw_short = true
			var short_ticks := int(short.get_ticks_until_rain())
			short.tick()
			if int(short.get_raised()) != 1 or int(short.get_horn_left()) != 0 or int(short.get_sounded()) != 1 or int(short.get_bell_left()) != 1 or int(short.get_lamp_left()) != 1 or int(short.get_watch_left()) != 1 or int(short.get_relief_left()) != 2 or int(short.get_wage_left()) != 2 or int(short.get_gate_left()) != 2 or int(short.get_yard_left()) != 0 or int(short.get_rung()) != 2 or int(short.get_lit()) != 3 or int(short.get_stood()) != 4 or int(short.get_posted()) != 6 or int(short.get_paid()) != 8:
				_fail(errors, "the flag raised an unsounded hire or passed the cap (raised %d horn %d sounded %d bell %d lamp %d watch %d relief %d wage %d gate %d yard %d rung %d lit %d stood %d posted %d paid %d)" % [short.get_raised(), short.get_horn_left(), short.get_sounded(), short.get_bell_left(), short.get_lamp_left(), short.get_watch_left(), short.get_relief_left(), short.get_wage_left(), short.get_gate_left(), short.get_yard_left(), short.get_rung(), short.get_lit(), short.get_stood(), short.get_posted(), short.get_paid()])
			elif not short.is_over() and int(short.get_ticks_until_rain()) >= short_ticks:
				_fail(errors, "the flag beat did not spend a tick after the dry cap")
			break
	if not saw_short:
		_fail(errors, "dry flag did not stop at 1 with the horn clear (raised %d horn %d sounded %d bell %d lamp %d watch %d relief %d wage %d gate %d yard %d rung %d lit %d stood %d posted %d paid %d ticks %d)" % [short.get_raised(), short.get_horn_left(), short.get_sounded(), short.get_bell_left(), short.get_lamp_left(), short.get_watch_left(), short.get_relief_left(), short.get_wage_left(), short.get_gate_left(), short.get_yard_left(), short.get_rung(), short.get_lit(), short.get_stood(), short.get_posted(), short.get_paid(), short.get_ticks_until_rain()])
	print("raised %d left horn %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d; dry raised %d left horn %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d; no flag raised %d left horn %d; flag without horn raised %d" % [raised.get_raised(), raised.get_horn_left(), raised.get_bell_left(), raised_unrung, raised_unlit, raised_unstood, raised_unposted, raised_unpaid, dry_raised.get_raised(), dry_raised.get_horn_left(), dry_raised.get_bell_left(), dry_unrung, dry_unlit, dry_unstood, dry_unposted, dry_unpaid, ignored.get_raised(), ignored.get_horn_left(), bare.get_raised()])


func _test_banner(errors: Array) -> void:
	if int(Sim.BANNER_TICK) != 100 or int(Sim.BANNER_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "banner beat length %s is not 100 ticks (10 seconds)" % Sim.BANNER_TICK)
	if int(Sim.BANNER_CAP) != 1:
		_fail(errors, "banner cap is %s, expected 1" % Sim.BANNER_CAP)
	var fresh = Sim.new()
	if fresh.paint_cell(14, -10, Sim.BANNER) == false or int(fresh.get_paint(14, -10)) != Sim.BANNER:
		_fail(errors, "the cell north of the flag rejected the banner mark")
	if fresh.paint_cell(14, -11, Sim.BANNER):
		_fail(errors, "the row north of the banner accepted a mark")
	if fresh.paint_cell(Sim.COAST_X, -10, Sim.BANNER):
		_fail(errors, "the brine accepted a banner")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.BANNER):
		_fail(errors, "the anthill accepted a banner")
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
	var posted = _run_plan(plans, "posted", errors)
	var stood = _run_plan(plans, "stood", errors)
	var lit = _run_plan(plans, "lit", errors)
	var rung = _run_plan(plans, "rung", errors)
	var sounded = _run_plan(plans, "sounded", errors)
	var raised = _run_plan(plans, "raised", errors)
	var dry_raised = _run_plan(plans, "dry_raised", errors)
	var ignored = _run_plan(plans, "no_banner", errors)
	var bare = _run_plan(plans, "banner_only", errors)
	var hoisted = _run_plan(plans, "hoisted", errors)
	var hoisted_again = _run_plan(plans, "hoisted", errors)
	var late = _run_plan(plans, "late_hoisted", errors)
	var dry_hoisted = _run_plan(plans, "dry_hoisted", errors)
	if won == null or dry == null or parked == null or loaded == null or sold == null or hired == null or lofted == null or passed == null or paid == null or posted == null or stood == null or lit == null or rung == null or sounded == null or raised == null or dry_raised == null or ignored == null or bare == null or hoisted == null or hoisted_again == null or late == null or dry_hoisted == null:
		return
	# Earlier plans keep the numbers they had before the banner existed, including a flag and no banner.
	_assert_chain(won, errors, "winning shore", 2997, 2997, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	_assert_chain(dry, errors, "dry pans", 0, 1032, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	_assert_chain(parked, errors, "carted plan", 2997, 2997, 2997, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	_assert_chain(loaded, errors, "shipped plan", 2997, 2997, 2997, 2997, 0, 0, 0, 0, 0, 0, 0, 0)
	_assert_chain(sold, errors, "sold plan", 2997, 2997, 2997, 2997, 2997, 0, 0, 0, 0, 0, 0, 0)
	_assert_chain(hired, errors, "hired plan", 2997, 2997, 2997, 2997, 2997, 29, 97, 0, 0, 0, 0, 0)
	_assert_chain(lofted, errors, "lofted plan", 2997, 2997, 2997, 2997, 2997, 29, 97, 0, 0, 0, 0, 0)
	_assert_chain(passed, errors, "gated plan", 2997, 2997, 2997, 2997, 2997, 29, 97, 0, 0, 0, 0, 0)
	_assert_chain(paid, errors, "paid plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 0, 0, 0, 0)
	_assert_chain(posted, errors, "posted plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 0, 0, 0)
	_assert_chain(stood, errors, "stood plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 0, 0)
	_assert_chain(lit, errors, "lit plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 0)
	_assert_chain(rung, errors, "rung plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2)
	_assert_chain(sounded, errors, "sounded plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2, 1)
	_assert_chain(raised, errors, "raised plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2, 1, 1)
	_assert_chain(dry_raised, errors, "dry flag", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 2, 1, 1)
	if int(raised.get_hoisted()) != 0 or int(raised.get_flag_left()) != 1 or int(dry_raised.get_hoisted()) != 0 or int(dry_raised.get_flag_left()) != 1:
		_fail(errors, "a flag with no banner hoisted someone (hoisted %d flag %d; dry hoisted %d flag %d)" % [raised.get_hoisted(), raised.get_flag_left(), dry_raised.get_hoisted(), dry_raised.get_flag_left()])
	if String(raised.get_summary()).to_lower().contains("hoisted") or String(raised.get_summary()).to_lower().contains("banner"):
		_fail(errors, "raised plan summary names a banner: %s" % raised.get_summary())
	# Raised, no banner: the 1 who was raised stays on the flag.
	var ignored_unpaid := int(ignored.get_hired()) - int(ignored.get_paid())
	var ignored_unposted := int(ignored.get_paid()) - int(ignored.get_posted())
	var ignored_unstood := int(ignored.get_posted()) - int(ignored.get_stood())
	var ignored_unlit := int(ignored.get_stood()) - int(ignored.get_lit())
	var ignored_unrung := int(ignored.get_lit()) - int(ignored.get_rung())
	var ignored_unraised := int(ignored.get_sounded()) - int(ignored.get_raised())
	var ignored_unhoisted := int(ignored.get_raised()) - int(ignored.get_hoisted())
	if int(ignored.get_hoisted()) != 0 or int(ignored.get_flag_left()) != 1 or ignored_unhoisted != 1 or int(ignored.get_raised()) != 1 or ignored_unraised != 0 or int(ignored.get_horn_left()) != 0 or int(ignored.get_sounded()) != 1 or int(ignored.get_bell_left()) != 1 or int(ignored.get_rung()) != 2 or ignored_unrung != 1 or int(ignored.get_lamp_left()) != 1 or int(ignored.get_lit()) != 3 or ignored_unlit != 1 or int(ignored.get_watch_left()) != 1 or ignored_unstood != 2 or ignored_unposted != 4 or ignored_unpaid != 19 or int(ignored.get_relief_left()) != 2 or int(ignored.get_wage_left()) != 4 or int(ignored.get_loft_left()) != 19 or int(ignored.get_gate_left()) != 0 or int(ignored.get_yard_left()) != 57 or int(ignored.get_stood()) != 4 or int(ignored.get_posted()) != 6 or int(ignored.get_paid()) != 10 or int(ignored.get_hired()) != 29 or int(ignored.get_coins()) != 2997 or int(ignored.get_stored_salt()) != 2997:
		_fail(errors, "no_banner hoisted someone (stored %d coins %d hired %d yard %d raised %d flag %d hoisted %d unpaid %d)" % [ignored.get_stored_salt(), ignored.get_coins(), ignored.get_hired(), ignored.get_yard_left(), ignored.get_raised(), ignored.get_flag_left(), ignored.get_hoisted(), ignored_unpaid])
	if String(ignored.get_summary()) != String(raised.get_summary()):
		_fail(errors, "no_banner summary changed: %s" % ignored.get_summary())
	if String(ignored.get_summary()).to_lower().contains("hoisted") or String(ignored.get_summary()).to_lower().contains("banner"):
		_fail(errors, "no_banner summary names a banner: %s" % ignored.get_summary())
	var ignored_flag = plans["no_banner"]["flag"][0]
	var ignored_salt: Dictionary = ignored.get_cell_salt(int(ignored_flag[0]), int(ignored_flag[1]))
	var ignored_north: Dictionary = ignored.get_cell_salt(int(ignored_flag[0]), int(ignored_flag[1]) - 1)
	if int(ignored_salt.get("flag", 0)) != 1 or int(ignored_north.get("banner", 0)) != 0 or int(ignored_salt.get("banner", 0)) != 0:
		_fail(errors, "no_banner left %s at the flag and %s at a banner" % [ignored_salt.get("flag", 0), ignored_north.get("banner", 0)])
	# A banner with nobody raised hoists nobody. The sounded hire stays on the horn.
	var bare_unpaid := int(bare.get_hired()) - int(bare.get_paid())
	if int(bare.get_hoisted()) != 0 or int(bare.get_raised()) != 0 or int(bare.get_flag_left()) != 0 or int(bare.get_sounded()) != 1 or int(bare.get_horn_left()) != 1 or int(bare.get_rung()) != 2 or int(bare.get_bell_left()) != 1 or int(bare.get_lit()) != 3 or int(bare.get_lamp_left()) != 1 or int(bare.get_stood()) != 4 or int(bare.get_watch_left()) != 1 or int(bare.get_posted()) != 6 or int(bare.get_relief_left()) != 2 or int(bare.get_paid()) != 10 or int(bare.get_wage_left()) != 4 or bare_unpaid != 19 or int(bare.get_loft_left()) != 19 or int(bare.get_gate_left()) != 0 or int(bare.get_yard_left()) != 57 or int(bare.get_hired()) != 29 or int(bare.get_coins()) != 2997 or int(bare.get_stored_salt()) != 2997:
		_fail(errors, "banner without a flag hoisted someone (hoisted %d raised %d horn %d sounded %d bell %d unpaid %d loft %d yard %d)" % [bare.get_hoisted(), bare.get_raised(), bare.get_horn_left(), bare.get_sounded(), bare.get_bell_left(), bare_unpaid, bare.get_loft_left(), bare.get_yard_left()])
	if String(bare.get_summary()) != String(sounded.get_summary()):
		_fail(errors, "banner without a flag changed the summary: %s" % bare.get_summary())
	if String(bare.get_summary()).to_lower().contains("hoisted") or String(bare.get_summary()).to_lower().contains("banner") or String(bare.get_summary()).to_lower().contains("raised") or String(bare.get_summary()).to_lower().contains("flag"):
		_fail(errors, "banner without a flag names a banner: %s" % bare.get_summary())
	var bare_banner = plans["banner_only"]["banner"][0]
	var bare_horn = plans["banner_only"]["horn"][0]
	var bare_banner_salt: Dictionary = bare.get_cell_salt(int(bare_banner[0]), int(bare_banner[1]))
	var bare_horn_salt: Dictionary = bare.get_cell_salt(int(bare_horn[0]), int(bare_horn[1]))
	if int(bare_banner_salt.get("banner", 0)) != 0 or int(bare_horn_salt.get("horn", 0)) != 1 or int(bare_banner_salt.get("flag", 0)) != 0:
		_fail(errors, "banner without a flag holds %s, horn holds %s" % [bare_banner_salt.get("banner", 0), bare_horn_salt.get("horn", 0)])
	var banner_cell = plans["hoisted"]["banner"][0]
	var flag_cell = plans["hoisted"]["flag"][0]
	var horn_cell = plans["hoisted"]["horn"][0]
	if int(banner_cell[0]) != int(flag_cell[0]) or int(banner_cell[1]) != int(flag_cell[1]) - 1:
		_fail(errors, "hoisted plan's banner is not one cell north of the flag")
	if int(banner_cell[0]) != 14 or int(banner_cell[1]) != -10 or int(flag_cell[0]) != 14 or int(flag_cell[1]) != -9:
		_fail(errors, "hoisted plan's banner is not at 14,-10 north of the flag at 14,-9")
	_assert_chain(hoisted, errors, "hoisted plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2, 1, 1, 1)
	var hoisted_unpaid := int(hoisted.get_hired()) - int(hoisted.get_paid())
	var hoisted_unposted := int(hoisted.get_paid()) - int(hoisted.get_posted())
	var hoisted_unstood := int(hoisted.get_posted()) - int(hoisted.get_stood())
	var hoisted_unlit := int(hoisted.get_stood()) - int(hoisted.get_lit())
	var hoisted_unrung := int(hoisted.get_lit()) - int(hoisted.get_rung())
	var hoisted_unraised := int(hoisted.get_sounded()) - int(hoisted.get_raised())
	var hoisted_unhoisted := int(hoisted.get_raised()) - int(hoisted.get_hoisted())
	if int(hoisted.get_hoisted()) != 1 or int(hoisted.get_flag_left()) != 0 or hoisted_unhoisted != 0 or hoisted_unraised != 0 or int(hoisted.get_horn_left()) != 0 or int(hoisted.get_bell_left()) != 1 or hoisted_unrung != 1 or hoisted_unlit != 1 or hoisted_unstood != 2 or hoisted_unposted != 4 or hoisted_unpaid != 19 or int(hoisted.get_lamp_left()) != 1 or int(hoisted.get_watch_left()) != 1 or int(hoisted.get_relief_left()) != 2 or int(hoisted.get_wage_left()) != 4 or int(hoisted.get_loft_left()) != 19 or int(hoisted.get_gate_left()) != 0 or int(hoisted.get_yard_left()) != 57 or int(hoisted.get_raised()) != 1 or int(hoisted.get_sounded()) != 1 or int(hoisted.get_rung()) != 2 or int(hoisted.get_lit()) != 3 or int(hoisted.get_stood()) != 4 or int(hoisted.get_posted()) != 6 or int(hoisted.get_coins()) != 2997 or int(hoisted.get_hired()) != 29:
		_fail(errors, "hoisted %d, left %d raised unhoisted, sounded unraised %d, rung unsounded %d, lit unrung %d, stood unlit %d, posted unstood %d, paid unposted %d, unpaid %d, flag %d, horn %d, yard %d, raised %d, sounded %d, rung %d, lit %d, stood %d, posted %d, coins %d, hired %d" % [hoisted.get_hoisted(), hoisted.get_flag_left(), hoisted_unraised, hoisted.get_bell_left(), hoisted_unrung, hoisted_unlit, hoisted_unstood, hoisted_unposted, hoisted_unpaid, hoisted.get_flag_left(), hoisted.get_horn_left(), hoisted.get_yard_left(), hoisted.get_raised(), hoisted.get_sounded(), hoisted.get_rung(), hoisted.get_lit(), hoisted.get_stood(), hoisted.get_posted(), hoisted.get_coins(), hoisted.get_hired()])
	if int(hoisted.get_hoisted()) > int(Sim.BANNER_CAP):
		_fail(errors, "banner hoisted %d, over the cap of %d" % [hoisted.get_hoisted(), Sim.BANNER_CAP])
	var banner_salt: Dictionary = hoisted.get_cell_salt(int(banner_cell[0]), int(banner_cell[1]))
	var flag_salt: Dictionary = hoisted.get_cell_salt(int(flag_cell[0]), int(flag_cell[1]))
	var horn_salt: Dictionary = hoisted.get_cell_salt(int(horn_cell[0]), int(horn_cell[1]))
	if int(banner_salt.get("banner", 0)) != 1 or int(flag_salt.get("flag", 0)) != 0 or int(horn_salt.get("horn", 0)) != 0:
		_fail(errors, "banner cell holds %s, flag holds %s, horn holds %s" % [banner_salt.get("banner", 0), flag_salt.get("flag", 0), horn_salt.get("horn", 0)])
	var hoisted_summary := String(hoisted.get_summary())
	if not hoisted_summary.contains("Hoisted 1 on the banner") or not hoisted_summary.contains("Left 0 at the flag") or not hoisted_summary.contains("Raised 1 on the flag") or not hoisted_summary.contains("Left 0 at the horn") or not hoisted_summary.contains("Sounded 1 on the horn") or not hoisted_summary.contains("Coins 2997") or not hoisted_summary.contains("Hired 29") or not hoisted_summary.contains("Left 57"):
		_fail(errors, "hoisted summary does not name the banner: %s" % hoisted_summary)
	if int(hoisted_again.get_hoisted()) != int(hoisted.get_hoisted()) or int(hoisted_again.get_flag_left()) != int(hoisted.get_flag_left()) or int(hoisted_again.get_raised()) != int(hoisted.get_raised()) or int(hoisted_again.get_yard_left()) != int(hoisted.get_yard_left()) or int(hoisted_again.get_stored_salt()) != int(hoisted.get_stored_salt()) or String(hoisted_again.get_summary()) != String(hoisted.get_summary()):
		_fail(errors, "repeated banner paint hoisted %d and left flag %d, then hoisted %d and left flag %d" % [hoisted.get_hoisted(), hoisted.get_flag_left(), hoisted_again.get_hoisted(), hoisted_again.get_flag_left()])
	if int(late.get_hoisted()) != 1 or int(late.get_flag_left()) != 0 or int(late.get_raised()) != 1 or int(late.get_sounded()) != 1 or int(late.get_horn_left()) != 0 or int(late.get_rung()) != 2 or int(late.get_lit()) != 3 or int(late.get_stood()) != 4 or int(late.get_posted()) != 6 or int(late.get_yard_left()) != 57 or int(late.get_hired()) != 29 or int(late.get_coins()) != 2997 or int(late.get_stored_salt()) != 2997 or int(late.get_loft_left()) != 19 or int(late.get_wage_left()) != 4:
		_fail(errors, "painting the banner at the banner beat (hoisted %d flag %d raised %d horn %d yard %d) did not match painting it early (hoisted %d flag %d raised %d)" % [late.get_hoisted(), late.get_flag_left(), late.get_raised(), late.get_horn_left(), late.get_yard_left(), hoisted.get_hoisted(), hoisted.get_flag_left(), hoisted.get_raised()])
	_assert_chain(dry_hoisted, errors, "dry banner", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 2, 1, 1, 1)
	var dry_unpaid := int(dry_hoisted.get_hired()) - int(dry_hoisted.get_paid())
	var dry_unposted := int(dry_hoisted.get_paid()) - int(dry_hoisted.get_posted())
	var dry_unstood := int(dry_hoisted.get_posted()) - int(dry_hoisted.get_stood())
	var dry_unlit := int(dry_hoisted.get_stood()) - int(dry_hoisted.get_lit())
	var dry_unrung := int(dry_hoisted.get_lit()) - int(dry_hoisted.get_rung())
	var dry_unraised := int(dry_hoisted.get_sounded()) - int(dry_hoisted.get_raised())
	var dry_unhoisted := int(dry_hoisted.get_raised()) - int(dry_hoisted.get_hoisted())
	if int(dry_hoisted.get_hoisted()) != 1 or int(dry_hoisted.get_flag_left()) != 0 or dry_unhoisted != 0 or dry_unraised != 0 or int(dry_hoisted.get_horn_left()) != 0 or int(dry_hoisted.get_bell_left()) != 1 or dry_unrung != 1 or dry_unlit != 1 or dry_unstood != 2 or dry_unposted != 2 or dry_unpaid != 2 or int(dry_hoisted.get_yard_left()) != 0 or int(dry_hoisted.get_raised()) != 1 or int(dry_hoisted.get_sounded()) != 1 or int(dry_hoisted.get_rung()) != 2 or int(dry_hoisted.get_lit()) != 3 or int(dry_hoisted.get_stood()) != 4 or int(dry_hoisted.get_posted()) != 6 or int(dry_hoisted.get_wet_haul()) != 0 or int(dry_hoisted.get_gate_left()) != 2 or int(dry_hoisted.get_wage_left()) != 2 or int(dry_hoisted.get_loft_left()) != 0:
		_fail(errors, "dry banner changed the short crew (wet %d stored %d hoisted %d flag %d raised %d sounded %d unhoisted %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d yard %d gate %d wage %d)" % [dry_hoisted.get_wet_haul(), dry_hoisted.get_stored_salt(), dry_hoisted.get_hoisted(), dry_hoisted.get_flag_left(), dry_hoisted.get_raised(), dry_hoisted.get_sounded(), dry_unhoisted, dry_unraised, dry_hoisted.get_bell_left(), dry_unrung, dry_unlit, dry_unstood, dry_unposted, dry_unpaid, dry_hoisted.get_yard_left(), dry_hoisted.get_gate_left(), dry_hoisted.get_wage_left()])
	var dry_banner_cell = plans["dry_hoisted"]["banner"][0]
	var dry_flag_cell = plans["dry_hoisted"]["flag"][0]
	var dry_banner_salt: Dictionary = dry_hoisted.get_cell_salt(int(dry_banner_cell[0]), int(dry_banner_cell[1]))
	var dry_flag_salt: Dictionary = dry_hoisted.get_cell_salt(int(dry_flag_cell[0]), int(dry_flag_cell[1]))
	if int(dry_banner_salt.get("banner", 0)) != 1 or int(dry_flag_salt.get("flag", 0)) != 0:
		_fail(errors, "dry banner cell holds %s, flag holds %s" % [dry_banner_salt.get("banner", 0), dry_flag_salt.get("flag", 0)])
	if not String(dry_hoisted.get_summary()).contains("Hoisted 1 on the banner") or not String(dry_hoisted.get_summary()).contains("Left 0 at the flag") or not String(dry_hoisted.get_summary()).contains("Raised 1 on the flag") or not String(dry_hoisted.get_summary()).contains("Left 0 in the yard"):
		_fail(errors, "dry banner summary does not name the cap: %s" % dry_hoisted.get_summary())
	_assert_pop(hoisted, errors, "hoisted plan")
	_assert_pop(hoisted_again, errors, "hoisted plan again")
	_assert_pop(late, errors, "late_hoisted")
	_assert_pop(dry_hoisted, errors, "dry_hoisted")
	_assert_pop(ignored, errors, "no_banner")
	_assert_pop(bare, errors, "banner_only")
	# The cap stops the banner while ticks remain. The winning shore leaves 0 raised hires on the flag.
	var shore = _prepare_plan(plans, "hoisted", errors)
	if shore == null:
		return
	var shore_guard := 0
	var shore_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + 2
	while int(shore.get_beat()) != Sim.BANNERING and not shore.is_over() and shore_guard < shore_limit:
		shore.tick()
		shore_guard += 1
	if int(shore.get_beat()) != Sim.BANNERING or shore.is_over():
		_fail(errors, "the flag beat did not open a banner beat for the cap check")
		return
	if int(shore.get_ticks_until_rain()) != int(Sim.BANNER_TICK):
		_fail(errors, "banner countdown started at %d, expected %d" % [shore.get_ticks_until_rain(), Sim.BANNER_TICK])
	if int(shore.get_hoisted()) != 0 or int(shore.get_raised()) != 1 or int(shore.get_flag_left()) != 1 or int(shore.get_sounded()) != 1 or int(shore.get_yard_left()) != 57:
		_fail(errors, "banner opened early (hoisted %d raised %d flag %d sounded %d yard %d)" % [shore.get_hoisted(), shore.get_raised(), shore.get_flag_left(), shore.get_sounded(), shore.get_yard_left()])
	var saw_cap := false
	var hoist_guard := 0
	while not shore.is_over() and hoist_guard < int(Sim.BANNER_TICK) + 2:
		shore.tick()
		hoist_guard += 1
		if int(shore.get_hoisted()) == int(Sim.BANNER_CAP) and int(shore.get_flag_left()) == 0 and int(shore.get_raised()) == 1 and int(shore.get_sounded()) == 1 and int(shore.get_horn_left()) == 0 and int(shore.get_yard_left()) == 57 and int(shore.get_coins()) == 2997 and int(shore.get_hired()) == 29 and int(shore.get_ticks_until_rain()) > 0:
			saw_cap = true
			var ticks_left := int(shore.get_ticks_until_rain())
			shore.tick()
			if int(shore.get_hoisted()) != int(Sim.BANNER_CAP) or int(shore.get_flag_left()) != 0 or int(shore.get_raised()) != 1 or int(shore.get_sounded()) != 1 or int(shore.get_yard_left()) != 57 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29 or int(shore.get_stored_salt()) != 2997 or int(shore.get_posted()) != 6 or int(shore.get_stood()) != 4 or int(shore.get_lit()) != 3 or int(shore.get_rung()) != 2:
				_fail(errors, "the banner kept hoisting after the cap (hoisted %d flag %d raised %d sounded %d yard %d)" % [shore.get_hoisted(), shore.get_flag_left(), shore.get_raised(), shore.get_sounded(), shore.get_yard_left()])
			elif not shore.is_over() and int(shore.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the banner beat did not spend a tick after the cap")
			break
	if not saw_cap:
		_fail(errors, "the banner did not stop at %d while ticks remained (hoisted %d flag %d raised %d ticks %d)" % [Sim.BANNER_CAP, shore.get_hoisted(), shore.get_flag_left(), shore.get_raised(), shore.get_ticks_until_rain()])
	var short = _prepare_plan(plans, "dry_hoisted", errors)
	if short == null:
		return
	var short_guard := 0
	while int(short.get_beat()) != Sim.BANNERING and not short.is_over() and short_guard < shore_limit:
		short.tick()
		short_guard += 1
	if int(short.get_beat()) != Sim.BANNERING or short.is_over():
		_fail(errors, "the flag beat did not open a banner beat for the dry cap")
		return
	var saw_short := false
	var short_steps := 0
	while not short.is_over() and short_steps < int(Sim.BANNER_TICK) + 2:
		short.tick()
		short_steps += 1
		if int(short.get_hoisted()) == int(Sim.BANNER_CAP) and int(short.get_flag_left()) == 0 and int(short.get_raised()) == 1 and int(short.get_sounded()) == 1 and int(short.get_yard_left()) == 0 and int(short.get_wet_haul()) == 0 and int(short.get_ticks_until_rain()) > 0:
			saw_short = true
			var short_ticks := int(short.get_ticks_until_rain())
			short.tick()
			if int(short.get_hoisted()) != 1 or int(short.get_flag_left()) != 0 or int(short.get_raised()) != 1 or int(short.get_yard_left()) != 0 or int(short.get_posted()) != 6:
				_fail(errors, "the banner hoisted an unraised hire or passed the cap (hoisted %d flag %d raised %d yard %d)" % [short.get_hoisted(), short.get_flag_left(), short.get_raised(), short.get_yard_left()])
			elif not short.is_over() and int(short.get_ticks_until_rain()) >= short_ticks:
				_fail(errors, "the banner beat did not spend a tick after the dry cap")
			break
	if not saw_short:
		_fail(errors, "dry banner did not stop at 1 with the flag clear (hoisted %d flag %d raised %d yard %d ticks %d)" % [short.get_hoisted(), short.get_flag_left(), short.get_raised(), short.get_yard_left(), short.get_ticks_until_rain()])
	print("hoisted %d left flag %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d; dry hoisted %d left flag %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d; no banner hoisted %d left flag %d; banner without flag hoisted %d" % [hoisted.get_hoisted(), hoisted.get_flag_left(), hoisted_unraised, hoisted.get_bell_left(), hoisted_unrung, hoisted_unlit, hoisted_unstood, hoisted_unposted, hoisted_unpaid, dry_hoisted.get_hoisted(), dry_hoisted.get_flag_left(), dry_unraised, dry_hoisted.get_bell_left(), dry_unrung, dry_unlit, dry_unstood, dry_unposted, dry_unpaid, ignored.get_hoisted(), ignored.get_flag_left(), bare.get_hoisted()])


func _test_pennant(errors: Array) -> void:
	if int(Sim.PENNANT_TICK) != 100 or int(Sim.PENNANT_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "pennant beat length %s is not 100 ticks (10 seconds)" % Sim.PENNANT_TICK)
	if int(Sim.PENNANT_CAP) != 1:
		_fail(errors, "pennant cap is %s, expected 1" % Sim.PENNANT_CAP)
	var fresh = Sim.new()
	if fresh.paint_cell(14, -11, Sim.PENNANT) == false or int(fresh.get_paint(14, -11)) != Sim.PENNANT:
		_fail(errors, "the cell north of the banner rejected the pennant mark")
	if fresh.paint_cell(14, -10, Sim.PENNANT):
		_fail(errors, "the banner cell accepted a pennant")
	if fresh.paint_cell(14, -11, Sim.BANNER):
		_fail(errors, "the pennant cell accepted a banner")
	if int(fresh.get_paint(14, -11)) != Sim.PENNANT:
		_fail(errors, "a rejected banner erased the pennant")
	if fresh.paint_cell(14, -10, Sim.BANNER) == false or int(fresh.get_paint(14, -10)) != Sim.BANNER:
		_fail(errors, "the banner cell no longer accepts a banner")
	if fresh.paint_cell(14, -12, Sim.PENNANT):
		_fail(errors, "the row north of the pennant accepted a pennant")
	if fresh.paint_cell(13, -11, Sim.PENNANT) or fresh.paint_cell(15, -11, Sim.PENNANT):
		_fail(errors, "a neighbor of the pennant cell accepted a pennant")
	if fresh.paint_cell(Sim.COAST_X, -11, Sim.PENNANT):
		_fail(errors, "the brine accepted a pennant")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.PENNANT):
		_fail(errors, "the anthill accepted a pennant")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var won = _run_plan(plans, "winning", errors)
	var dry = _run_plan(plans, "dry_pans", errors)
	var hoisted = _run_plan(plans, "hoisted", errors)
	var raised = _run_plan(plans, "raised", errors)
	var ignored = _run_plan(plans, "no_pennant", errors)
	var bare = _run_plan(plans, "pennant_only", errors)
	var flown = _run_plan(plans, "flown", errors)
	var flown_again = _run_plan(plans, "flown", errors)
	var late = _run_plan(plans, "late_flown", errors)
	var dry_flown = _run_plan(plans, "dry_flown", errors)
	if won == null or dry == null or hoisted == null or raised == null or ignored == null or bare == null or flown == null or flown_again == null or late == null or dry_flown == null:
		return
	_assert_chain(won, errors, "winning shore", 2997, 2997, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	_assert_chain(dry, errors, "dry pans", 0, 1032, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	_assert_chain(raised, errors, "raised plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2, 1, 1)
	_assert_chain(hoisted, errors, "hoisted plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2, 1, 1, 1, 0)
	if int(hoisted.get_flown()) != 0 or int(hoisted.get_banner_left()) != 1:
		_fail(errors, "a banner with no pennant flew someone (flown %d banner %d)" % [hoisted.get_flown(), hoisted.get_banner_left()])
	# Hoisted, no pennant: the 1 who was hoisted stays on the banner.
	var ignored_unpaid := int(ignored.get_hired()) - int(ignored.get_paid())
	var ignored_unposted := int(ignored.get_paid()) - int(ignored.get_posted())
	var ignored_unstood := int(ignored.get_posted()) - int(ignored.get_stood())
	var ignored_unlit := int(ignored.get_stood()) - int(ignored.get_lit())
	var ignored_unrung := int(ignored.get_lit()) - int(ignored.get_rung())
	var ignored_unraised := int(ignored.get_sounded()) - int(ignored.get_raised())
	var ignored_unhoisted := int(ignored.get_raised()) - int(ignored.get_hoisted())
	var ignored_unflown := int(ignored.get_hoisted()) - int(ignored.get_flown())
	if int(ignored.get_flown()) != 0 or int(ignored.get_banner_left()) != 1 or ignored_unflown != 1 or int(ignored.get_hoisted()) != 1 or ignored_unhoisted != 0 or int(ignored.get_flag_left()) != 0 or int(ignored.get_raised()) != 1 or ignored_unraised != 0 or int(ignored.get_horn_left()) != 0 or int(ignored.get_sounded()) != 1 or int(ignored.get_bell_left()) != 1 or int(ignored.get_rung()) != 2 or ignored_unrung != 1 or int(ignored.get_lamp_left()) != 1 or int(ignored.get_lit()) != 3 or ignored_unlit != 1 or int(ignored.get_watch_left()) != 1 or ignored_unstood != 2 or ignored_unposted != 4 or ignored_unpaid != 19 or int(ignored.get_relief_left()) != 2 or int(ignored.get_wage_left()) != 4 or int(ignored.get_loft_left()) != 19 or int(ignored.get_gate_left()) != 0 or int(ignored.get_yard_left()) != 57 or int(ignored.get_stood()) != 4 or int(ignored.get_posted()) != 6 or int(ignored.get_paid()) != 10 or int(ignored.get_hired()) != 29 or int(ignored.get_coins()) != 2997 or int(ignored.get_stored_salt()) != 2997:
		_fail(errors, "no_pennant flew someone (stored %d coins %d hired %d yard %d hoisted %d banner %d flown %d unpaid %d)" % [ignored.get_stored_salt(), ignored.get_coins(), ignored.get_hired(), ignored.get_yard_left(), ignored.get_hoisted(), ignored.get_banner_left(), ignored.get_flown(), ignored_unpaid])
	if String(ignored.get_summary()) != String(hoisted.get_summary()):
		_fail(errors, "no_pennant summary changed: %s" % ignored.get_summary())
	if String(ignored.get_summary()).to_lower().contains("flew") or String(ignored.get_summary()).to_lower().contains("pennant"):
		_fail(errors, "no_pennant summary names a pennant: %s" % ignored.get_summary())
	var ignored_banner = plans["no_pennant"]["banner"][0]
	var ignored_salt: Dictionary = ignored.get_cell_salt(int(ignored_banner[0]), int(ignored_banner[1]))
	var ignored_north: Dictionary = ignored.get_cell_salt(int(ignored_banner[0]), int(ignored_banner[1]) - 1)
	if int(ignored_salt.get("banner", 0)) != 1 or int(ignored_north.get("pennant", 0)) != 0 or int(ignored_salt.get("pennant", 0)) != 0:
		_fail(errors, "no_pennant left %s at the banner and %s at a pennant" % [ignored_salt.get("banner", 0), ignored_north.get("pennant", 0)])
	# A pennant with nobody hoisted flies nobody. The raised hire stays on the flag.
	var bare_unpaid := int(bare.get_hired()) - int(bare.get_paid())
	if int(bare.get_flown()) != 0 or int(bare.get_hoisted()) != 0 or int(bare.get_banner_left()) != 0 or int(bare.get_raised()) != 1 or int(bare.get_flag_left()) != 1 or int(bare.get_sounded()) != 1 or int(bare.get_horn_left()) != 0 or int(bare.get_rung()) != 2 or int(bare.get_bell_left()) != 1 or int(bare.get_lit()) != 3 or int(bare.get_lamp_left()) != 1 or int(bare.get_stood()) != 4 or int(bare.get_watch_left()) != 1 or int(bare.get_posted()) != 6 or int(bare.get_relief_left()) != 2 or int(bare.get_paid()) != 10 or int(bare.get_wage_left()) != 4 or bare_unpaid != 19 or int(bare.get_loft_left()) != 19 or int(bare.get_gate_left()) != 0 or int(bare.get_yard_left()) != 57 or int(bare.get_hired()) != 29 or int(bare.get_coins()) != 2997 or int(bare.get_stored_salt()) != 2997:
		_fail(errors, "pennant without a banner flew someone (flown %d hoisted %d flag %d raised %d unpaid %d loft %d yard %d)" % [bare.get_flown(), bare.get_hoisted(), bare.get_flag_left(), bare.get_raised(), bare_unpaid, bare.get_loft_left(), bare.get_yard_left()])
	if String(bare.get_summary()) != String(raised.get_summary()):
		_fail(errors, "pennant without a banner changed the summary: %s" % bare.get_summary())
	if String(bare.get_summary()).to_lower().contains("flew") or String(bare.get_summary()).to_lower().contains("pennant") or String(bare.get_summary()).to_lower().contains("hoisted") or String(bare.get_summary()).to_lower().contains("banner"):
		_fail(errors, "pennant without a banner names a pennant: %s" % bare.get_summary())
	var bare_pennant = plans["pennant_only"]["pennant"][0]
	var bare_flag = plans["pennant_only"]["flag"][0]
	var bare_pennant_salt: Dictionary = bare.get_cell_salt(int(bare_pennant[0]), int(bare_pennant[1]))
	var bare_flag_salt: Dictionary = bare.get_cell_salt(int(bare_flag[0]), int(bare_flag[1]))
	if int(bare_pennant_salt.get("pennant", 0)) != 0 or int(bare_flag_salt.get("flag", 0)) != 1 or int(bare_pennant_salt.get("banner", 0)) != 0:
		_fail(errors, "pennant without a banner holds %s, flag holds %s" % [bare_pennant_salt.get("pennant", 0), bare_flag_salt.get("flag", 0)])
	var pennant_cell = plans["flown"]["pennant"][0]
	var banner_cell = plans["flown"]["banner"][0]
	var flag_cell = plans["flown"]["flag"][0]
	if int(pennant_cell[0]) != int(banner_cell[0]) or int(pennant_cell[1]) != int(banner_cell[1]) - 1:
		_fail(errors, "flown plan's pennant is not one cell north of the banner")
	if int(pennant_cell[0]) != 14 or int(pennant_cell[1]) != -11 or int(banner_cell[0]) != 14 or int(banner_cell[1]) != -10:
		_fail(errors, "flown plan's pennant is not at 14,-11 north of the banner at 14,-10")
	_assert_chain(flown, errors, "flown plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2, 1, 1, 1, 1)
	var flown_unpaid := int(flown.get_hired()) - int(flown.get_paid())
	var flown_unposted := int(flown.get_paid()) - int(flown.get_posted())
	var flown_unstood := int(flown.get_posted()) - int(flown.get_stood())
	var flown_unlit := int(flown.get_stood()) - int(flown.get_lit())
	var flown_unrung := int(flown.get_lit()) - int(flown.get_rung())
	var flown_unraised := int(flown.get_sounded()) - int(flown.get_raised())
	var flown_unhoisted := int(flown.get_raised()) - int(flown.get_hoisted())
	var flown_unflown := int(flown.get_hoisted()) - int(flown.get_flown())
	if int(flown.get_flown()) != 1 or int(flown.get_banner_left()) != 0 or flown_unflown != 0 or flown_unhoisted != 0 or flown_unraised != 0 or int(flown.get_horn_left()) != 0 or int(flown.get_bell_left()) != 1 or flown_unrung != 1 or flown_unlit != 1 or flown_unstood != 2 or flown_unposted != 4 or flown_unpaid != 19 or int(flown.get_lamp_left()) != 1 or int(flown.get_watch_left()) != 1 or int(flown.get_relief_left()) != 2 or int(flown.get_wage_left()) != 4 or int(flown.get_loft_left()) != 19 or int(flown.get_gate_left()) != 0 or int(flown.get_yard_left()) != 57 or int(flown.get_hoisted()) != 1 or int(flown.get_raised()) != 1 or int(flown.get_sounded()) != 1 or int(flown.get_rung()) != 2 or int(flown.get_lit()) != 3 or int(flown.get_stood()) != 4 or int(flown.get_posted()) != 6 or int(flown.get_coins()) != 2997 or int(flown.get_hired()) != 29:
		_fail(errors, "flown %d, left %d hoisted unflown, raised unhoisted %d, sounded unraised %d, rung unsounded %d, lit unrung %d, stood unlit %d, posted unstood %d, paid unposted %d, unpaid %d, banner %d, flag %d, yard %d, hoisted %d, raised %d, sounded %d, rung %d, lit %d, stood %d, posted %d, coins %d, hired %d" % [flown.get_flown(), flown.get_banner_left(), flown_unhoisted, flown_unraised, flown.get_bell_left(), flown_unrung, flown_unlit, flown_unstood, flown_unposted, flown_unpaid, flown.get_banner_left(), flown.get_flag_left(), flown.get_yard_left(), flown.get_hoisted(), flown.get_raised(), flown.get_sounded(), flown.get_rung(), flown.get_lit(), flown.get_stood(), flown.get_posted(), flown.get_coins(), flown.get_hired()])
	if int(flown.get_flown()) > int(Sim.PENNANT_CAP):
		_fail(errors, "pennant flew %d, over the cap of %d" % [flown.get_flown(), Sim.PENNANT_CAP])
	var pennant_salt: Dictionary = flown.get_cell_salt(int(pennant_cell[0]), int(pennant_cell[1]))
	var banner_salt: Dictionary = flown.get_cell_salt(int(banner_cell[0]), int(banner_cell[1]))
	var flag_salt: Dictionary = flown.get_cell_salt(int(flag_cell[0]), int(flag_cell[1]))
	if int(pennant_salt.get("pennant", 0)) != 1 or int(banner_salt.get("banner", 0)) != 0 or int(flag_salt.get("flag", 0)) != 0:
		_fail(errors, "pennant cell holds %s, banner holds %s, flag holds %s" % [pennant_salt.get("pennant", 0), banner_salt.get("banner", 0), flag_salt.get("flag", 0)])
	var flown_summary := String(flown.get_summary())
	if not flown_summary.contains("Flew 1 on the pennant") or not flown_summary.contains("Left 0 at the banner") or not flown_summary.contains("Hoisted 1 on the banner") or not flown_summary.contains("Left 0 at the flag") or not flown_summary.contains("Coins 2997") or not flown_summary.contains("Hired 29") or not flown_summary.contains("Left 57"):
		_fail(errors, "flown summary does not name the pennant: %s" % flown_summary)
	if int(flown_again.get_flown()) != int(flown.get_flown()) or int(flown_again.get_banner_left()) != int(flown.get_banner_left()) or int(flown_again.get_hoisted()) != int(flown.get_hoisted()) or int(flown_again.get_yard_left()) != int(flown.get_yard_left()) or int(flown_again.get_stored_salt()) != int(flown.get_stored_salt()) or String(flown_again.get_summary()) != String(flown.get_summary()):
		_fail(errors, "repeated pennant paint flew %d and left banner %d, then flew %d and left banner %d" % [flown.get_flown(), flown.get_banner_left(), flown_again.get_flown(), flown_again.get_banner_left()])
	if int(late.get_flown()) != 1 or int(late.get_banner_left()) != 0 or int(late.get_hoisted()) != 1 or int(late.get_raised()) != 1 or int(late.get_sounded()) != 1 or int(late.get_rung()) != 2 or int(late.get_lit()) != 3 or int(late.get_stood()) != 4 or int(late.get_posted()) != 6 or int(late.get_yard_left()) != 57 or int(late.get_hired()) != 29 or int(late.get_coins()) != 2997 or int(late.get_stored_salt()) != 2997 or int(late.get_loft_left()) != 19 or int(late.get_wage_left()) != 4:
		_fail(errors, "painting the pennant at the pennant beat (flown %d banner %d hoisted %d yard %d) did not match painting it early (flown %d banner %d hoisted %d)" % [late.get_flown(), late.get_banner_left(), late.get_hoisted(), late.get_yard_left(), flown.get_flown(), flown.get_banner_left(), flown.get_hoisted()])
	_assert_chain(dry_flown, errors, "dry pennant", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 2, 1, 1, 1, 1)
	var dry_unpaid := int(dry_flown.get_hired()) - int(dry_flown.get_paid())
	var dry_unposted := int(dry_flown.get_paid()) - int(dry_flown.get_posted())
	var dry_unstood := int(dry_flown.get_posted()) - int(dry_flown.get_stood())
	var dry_unlit := int(dry_flown.get_stood()) - int(dry_flown.get_lit())
	var dry_unrung := int(dry_flown.get_lit()) - int(dry_flown.get_rung())
	var dry_unraised := int(dry_flown.get_sounded()) - int(dry_flown.get_raised())
	var dry_unhoisted := int(dry_flown.get_raised()) - int(dry_flown.get_hoisted())
	var dry_unflown := int(dry_flown.get_hoisted()) - int(dry_flown.get_flown())
	if int(dry_flown.get_flown()) != 1 or int(dry_flown.get_banner_left()) != 0 or dry_unflown != 0 or dry_unhoisted != 0 or dry_unraised != 0 or int(dry_flown.get_horn_left()) != 0 or int(dry_flown.get_bell_left()) != 1 or dry_unrung != 1 or dry_unlit != 1 or dry_unstood != 2 or dry_unposted != 2 or dry_unpaid != 2 or int(dry_flown.get_yard_left()) != 0 or int(dry_flown.get_hoisted()) != 1 or int(dry_flown.get_raised()) != 1 or int(dry_flown.get_sounded()) != 1 or int(dry_flown.get_rung()) != 2 or int(dry_flown.get_lit()) != 3 or int(dry_flown.get_stood()) != 4 or int(dry_flown.get_posted()) != 6 or int(dry_flown.get_wet_haul()) != 0 or int(dry_flown.get_stored_salt()) != 1032 or int(dry_flown.get_gate_left()) != 2 or int(dry_flown.get_wage_left()) != 2 or int(dry_flown.get_loft_left()) != 0:
		_fail(errors, "dry pennant changed the short crew (wet %d stored %d flown %d banner %d hoisted %d raised %d unflown %d unhoisted %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d yard %d)" % [dry_flown.get_wet_haul(), dry_flown.get_stored_salt(), dry_flown.get_flown(), dry_flown.get_banner_left(), dry_flown.get_hoisted(), dry_flown.get_raised(), dry_unflown, dry_unhoisted, dry_unraised, dry_flown.get_bell_left(), dry_unrung, dry_unlit, dry_unstood, dry_unposted, dry_unpaid, dry_flown.get_yard_left()])
	var dry_pennant_cell = plans["dry_flown"]["pennant"][0]
	var dry_banner_cell = plans["dry_flown"]["banner"][0]
	var dry_pennant_salt: Dictionary = dry_flown.get_cell_salt(int(dry_pennant_cell[0]), int(dry_pennant_cell[1]))
	var dry_banner_salt: Dictionary = dry_flown.get_cell_salt(int(dry_banner_cell[0]), int(dry_banner_cell[1]))
	if int(dry_pennant_salt.get("pennant", 0)) != 1 or int(dry_banner_salt.get("banner", 0)) != 0:
		_fail(errors, "dry pennant cell holds %s, banner holds %s" % [dry_pennant_salt.get("pennant", 0), dry_banner_salt.get("banner", 0)])
	if not String(dry_flown.get_summary()).contains("Flew 1 on the pennant") or not String(dry_flown.get_summary()).contains("Left 0 at the banner") or not String(dry_flown.get_summary()).contains("Hoisted 1 on the banner") or not String(dry_flown.get_summary()).contains("Left 0 in the yard"):
		_fail(errors, "dry pennant summary does not name the cap: %s" % dry_flown.get_summary())
	_assert_pop(flown, errors, "flown plan")
	_assert_pop(flown_again, errors, "flown plan again")
	_assert_pop(late, errors, "late_flown")
	_assert_pop(dry_flown, errors, "dry_flown")
	_assert_pop(ignored, errors, "no_pennant")
	_assert_pop(bare, errors, "pennant_only")
	# The cap stops the pennant while ticks remain. The winning shore leaves 0 hoisted hires on the banner.
	var shore = _prepare_plan(plans, "flown", errors)
	if shore == null:
		return
	var shore_guard := 0
	var shore_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + 2
	while int(shore.get_beat()) != Sim.PENNANTING and not shore.is_over() and shore_guard < shore_limit:
		shore.tick()
		shore_guard += 1
	if int(shore.get_beat()) != Sim.PENNANTING or shore.is_over():
		_fail(errors, "the banner beat did not open a pennant beat for the cap check")
		return
	if int(shore.get_ticks_until_rain()) != int(Sim.PENNANT_TICK):
		_fail(errors, "pennant countdown started at %d, expected %d" % [shore.get_ticks_until_rain(), Sim.PENNANT_TICK])
	if int(shore.get_flown()) != 0 or int(shore.get_hoisted()) != 1 or int(shore.get_banner_left()) != 1 or int(shore.get_raised()) != 1 or int(shore.get_yard_left()) != 57 or int(shore.get_coins()) != 2997 or int(shore.get_stored_salt()) != 2997:
		_fail(errors, "pennant opened early (flown %d hoisted %d banner %d raised %d yard %d coins %d stored %d)" % [shore.get_flown(), shore.get_hoisted(), shore.get_banner_left(), shore.get_raised(), shore.get_yard_left(), shore.get_coins(), shore.get_stored_salt()])
	var saw_cap := false
	var fly_guard := 0
	while not shore.is_over() and fly_guard < int(Sim.PENNANT_TICK) + 2:
		shore.tick()
		fly_guard += 1
		if int(shore.get_flown()) == int(Sim.PENNANT_CAP) and int(shore.get_banner_left()) == 0 and int(shore.get_hoisted()) == 1 and int(shore.get_raised()) == 1 and int(shore.get_yard_left()) == 57 and int(shore.get_coins()) == 2997 and int(shore.get_hired()) == 29 and int(shore.get_ticks_until_rain()) > 0:
			saw_cap = true
			var ticks_left := int(shore.get_ticks_until_rain())
			shore.tick()
			if int(shore.get_flown()) != int(Sim.PENNANT_CAP) or int(shore.get_banner_left()) != 0 or int(shore.get_hoisted()) != 1 or int(shore.get_raised()) != 1 or int(shore.get_yard_left()) != 57 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29 or int(shore.get_stored_salt()) != 2997 or int(shore.get_posted()) != 6 or int(shore.get_stood()) != 4 or int(shore.get_lit()) != 3 or int(shore.get_rung()) != 2 or int(shore.get_sounded()) != 1:
				_fail(errors, "the pennant kept flying after the cap (flown %d banner %d hoisted %d raised %d yard %d)" % [shore.get_flown(), shore.get_banner_left(), shore.get_hoisted(), shore.get_raised(), shore.get_yard_left()])
			elif not shore.is_over() and int(shore.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the pennant beat did not spend a tick after the cap")
			break
	if not saw_cap:
		_fail(errors, "the pennant did not stop at %d while ticks remained (flown %d banner %d hoisted %d ticks %d)" % [Sim.PENNANT_CAP, shore.get_flown(), shore.get_banner_left(), shore.get_hoisted(), shore.get_ticks_until_rain()])
	var short = _prepare_plan(plans, "dry_flown", errors)
	if short == null:
		return
	var short_guard := 0
	while int(short.get_beat()) != Sim.PENNANTING and not short.is_over() and short_guard < shore_limit:
		short.tick()
		short_guard += 1
	if int(short.get_beat()) != Sim.PENNANTING or short.is_over():
		_fail(errors, "the banner beat did not open a pennant beat for the dry cap")
		return
	var saw_short := false
	var short_steps := 0
	while not short.is_over() and short_steps < int(Sim.PENNANT_TICK) + 2:
		short.tick()
		short_steps += 1
		if int(short.get_flown()) == int(Sim.PENNANT_CAP) and int(short.get_banner_left()) == 0 and int(short.get_hoisted()) == 1 and int(short.get_raised()) == 1 and int(short.get_yard_left()) == 0 and int(short.get_wet_haul()) == 0 and int(short.get_ticks_until_rain()) > 0:
			saw_short = true
			var short_ticks := int(short.get_ticks_until_rain())
			short.tick()
			if int(short.get_flown()) != 1 or int(short.get_banner_left()) != 0 or int(short.get_hoisted()) != 1 or int(short.get_yard_left()) != 0 or int(short.get_posted()) != 6 or int(short.get_stored_salt()) != 1032:
				_fail(errors, "the pennant flew an unhoisted hire or passed the cap (flown %d banner %d hoisted %d yard %d)" % [short.get_flown(), short.get_banner_left(), short.get_hoisted(), short.get_yard_left()])
			elif not short.is_over() and int(short.get_ticks_until_rain()) >= short_ticks:
				_fail(errors, "the pennant beat did not spend a tick after the dry cap")
			break
	if not saw_short:
		_fail(errors, "dry pennant did not stop at 1 with the banner clear (flown %d banner %d hoisted %d yard %d ticks %d)" % [short.get_flown(), short.get_banner_left(), short.get_hoisted(), short.get_yard_left(), short.get_ticks_until_rain()])
	print("flown %d left banner %d unhoisted %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d; dry flown %d left banner %d unhoisted %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d; no pennant flown %d left banner %d; pennant without banner flown %d" % [flown.get_flown(), flown.get_banner_left(), flown_unhoisted, flown_unraised, flown.get_bell_left(), flown_unrung, flown_unlit, flown_unstood, flown_unposted, flown_unpaid, dry_flown.get_flown(), dry_flown.get_banner_left(), dry_unhoisted, dry_unraised, dry_flown.get_bell_left(), dry_unrung, dry_unlit, dry_unstood, dry_unposted, dry_unpaid, ignored.get_flown(), ignored.get_banner_left(), bare.get_flown()])


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


func _test_standard(errors: Array) -> void:
	if int(Sim.STANDARD_TICK) != 100 or int(Sim.STANDARD_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "standard beat length %s is not 100 ticks (10 seconds)" % Sim.STANDARD_TICK)
	if int(Sim.STANDARD_CAP) != 1:
		_fail(errors, "standard cap is %s, expected 1" % Sim.STANDARD_CAP)
	if int(Sim.STANDARD_CELL.y) != -12 or int(Sim.STANDARD_CELL.x) != 14:
		_fail(errors, "the standard cell moved off 14,-12")
	if int(Sim.PENNANT_CELL.x) != 14 or int(Sim.PENNANT_CELL.y) != -11:
		_fail(errors, "the pennant moved off 14,-11")
	var fresh = Sim.new()
	if fresh.paint_cell(14, -12, Sim.STANDARD) == false or int(fresh.get_paint(14, -12)) != Sim.STANDARD:
		_fail(errors, "the cell north of the pennant rejected the standard mark")
	if fresh.paint_cell(14, -11, Sim.STANDARD):
		_fail(errors, "the pennant cell accepted a standard")
	if fresh.paint_cell(14, -12, Sim.PENNANT):
		_fail(errors, "the standard cell accepted a pennant")
	if int(fresh.get_paint(14, -12)) != Sim.STANDARD:
		_fail(errors, "a rejected pennant erased the standard")
	if fresh.paint_cell(14, -11, Sim.PENNANT) == false or int(fresh.get_paint(14, -11)) != Sim.PENNANT:
		_fail(errors, "the pennant cell no longer accepts a pennant")
	if fresh.paint_cell(14, -10, Sim.BANNER) == false or int(fresh.get_paint(14, -10)) != Sim.BANNER:
		_fail(errors, "the banner cell no longer accepts a banner")
	if fresh.paint_cell(14, -13, Sim.STANDARD):
		_fail(errors, "the row north of the standard accepted a standard")
	if fresh.paint_cell(13, -12, Sim.STANDARD) or fresh.paint_cell(15, -12, Sim.STANDARD):
		_fail(errors, "a neighbor of the standard cell accepted a standard")
	if fresh.paint_cell(Sim.COAST_X, -12, Sim.STANDARD):
		_fail(errors, "the brine accepted a standard")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.STANDARD):
		_fail(errors, "the anthill accepted a standard")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var won = _run_plan(plans, "winning", errors)
	var dry = _run_plan(plans, "dry_pans", errors)
	var flown = _run_plan(plans, "flown", errors)
	var hoisted = _run_plan(plans, "hoisted", errors)
	var ignored = _run_plan(plans, "no_standard", errors)
	var bare = _run_plan(plans, "standard_only", errors)
	var carried = _run_plan(plans, "carried", errors)
	var carried_again = _run_plan(plans, "carried", errors)
	var late = _run_plan(plans, "late_carried", errors)
	var dry_carried = _run_plan(plans, "dry_carried", errors)
	if won == null or dry == null or flown == null or hoisted == null or ignored == null or bare == null or carried == null or carried_again == null or late == null or dry_carried == null:
		return
	_assert_chain(won, errors, "winning shore", 2997, 2997, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	_assert_chain(dry, errors, "dry pans", 0, 1032, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	_assert_chain(flown, errors, "flown plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2, 1, 1, 1, 1, 0)
	if int(flown.get_carried()) != 0 or int(flown.get_pennant_left()) != 1 or int(flown.get_flown()) != 1:
		_fail(errors, "a pennant with no standard carried someone (carried %d pennant %d flown %d)" % [flown.get_carried(), flown.get_pennant_left(), flown.get_flown()])
	if String(flown.get_summary()).to_lower().contains("carried") or String(flown.get_summary()).to_lower().contains("standard"):
		_fail(errors, "a pennant with no standard names a standard: %s" % flown.get_summary())
	var ignored_unpaid := int(ignored.get_hired()) - int(ignored.get_paid())
	var ignored_unposted := int(ignored.get_paid()) - int(ignored.get_posted())
	var ignored_unstood := int(ignored.get_posted()) - int(ignored.get_stood())
	var ignored_unlit := int(ignored.get_stood()) - int(ignored.get_lit())
	var ignored_unrung := int(ignored.get_lit()) - int(ignored.get_rung())
	var ignored_unraised := int(ignored.get_sounded()) - int(ignored.get_raised())
	var ignored_unhoisted := int(ignored.get_raised()) - int(ignored.get_hoisted())
	var ignored_unflown := int(ignored.get_hoisted()) - int(ignored.get_flown())
	var ignored_uncarried := int(ignored.get_flown()) - int(ignored.get_carried())
	if int(ignored.get_carried()) != 0 or int(ignored.get_pennant_left()) != 1 or ignored_uncarried != 1 or int(ignored.get_flown()) != 1 or ignored_unflown != 0 or int(ignored.get_banner_left()) != 0 or int(ignored.get_hoisted()) != 1 or ignored_unhoisted != 0 or int(ignored.get_flag_left()) != 0 or int(ignored.get_raised()) != 1 or ignored_unraised != 0 or int(ignored.get_horn_left()) != 0 or int(ignored.get_sounded()) != 1 or int(ignored.get_bell_left()) != 1 or int(ignored.get_rung()) != 2 or ignored_unrung != 1 or int(ignored.get_lamp_left()) != 1 or int(ignored.get_lit()) != 3 or ignored_unlit != 1 or int(ignored.get_watch_left()) != 1 or ignored_unstood != 2 or ignored_unposted != 4 or ignored_unpaid != 19 or int(ignored.get_relief_left()) != 2 or int(ignored.get_wage_left()) != 4 or int(ignored.get_loft_left()) != 19 or int(ignored.get_gate_left()) != 0 or int(ignored.get_yard_left()) != 57 or int(ignored.get_stood()) != 4 or int(ignored.get_posted()) != 6 or int(ignored.get_paid()) != 10 or int(ignored.get_hired()) != 29 or int(ignored.get_coins()) != 2997 or int(ignored.get_stored_salt()) != 2997:
		_fail(errors, "no_standard carried someone (stored %d coins %d hired %d yard %d flown %d pennant %d carried %d unpaid %d)" % [ignored.get_stored_salt(), ignored.get_coins(), ignored.get_hired(), ignored.get_yard_left(), ignored.get_flown(), ignored.get_pennant_left(), ignored.get_carried(), ignored_unpaid])
	if String(ignored.get_summary()) != String(flown.get_summary()):
		_fail(errors, "no_standard summary changed: %s" % ignored.get_summary())
	if String(ignored.get_summary()).to_lower().contains("carried") or String(ignored.get_summary()).to_lower().contains("standard"):
		_fail(errors, "no_standard summary names a standard: %s" % ignored.get_summary())
	var ignored_pennant = plans["no_standard"]["pennant"][0]
	var ignored_salt: Dictionary = ignored.get_cell_salt(int(ignored_pennant[0]), int(ignored_pennant[1]))
	var ignored_north: Dictionary = ignored.get_cell_salt(int(ignored_pennant[0]), int(ignored_pennant[1]) - 1)
	if int(ignored_salt.get("pennant", 0)) != 1 or int(ignored_north.get("standard", 0)) != 0 or int(ignored_salt.get("standard", 0)) != 0:
		_fail(errors, "no_standard left %s at the pennant and %s at a standard" % [ignored_salt.get("pennant", 0), ignored_north.get("standard", 0)])
	var bare_unpaid := int(bare.get_hired()) - int(bare.get_paid())
	if int(bare.get_carried()) != 0 or int(bare.get_flown()) != 0 or int(bare.get_pennant_left()) != 0 or int(bare.get_hoisted()) != 1 or int(bare.get_banner_left()) != 1 or int(bare.get_raised()) != 1 or int(bare.get_flag_left()) != 0 or int(bare.get_sounded()) != 1 or int(bare.get_horn_left()) != 0 or int(bare.get_rung()) != 2 or int(bare.get_bell_left()) != 1 or int(bare.get_lit()) != 3 or int(bare.get_lamp_left()) != 1 or int(bare.get_stood()) != 4 or int(bare.get_watch_left()) != 1 or int(bare.get_posted()) != 6 or int(bare.get_relief_left()) != 2 or int(bare.get_paid()) != 10 or int(bare.get_wage_left()) != 4 or bare_unpaid != 19 or int(bare.get_loft_left()) != 19 or int(bare.get_gate_left()) != 0 or int(bare.get_yard_left()) != 57 or int(bare.get_hired()) != 29 or int(bare.get_coins()) != 2997 or int(bare.get_stored_salt()) != 2997:
		_fail(errors, "standard without a pennant carried someone (carried %d flown %d banner %d hoisted %d unpaid %d loft %d yard %d)" % [bare.get_carried(), bare.get_flown(), bare.get_banner_left(), bare.get_hoisted(), bare_unpaid, bare.get_loft_left(), bare.get_yard_left()])
	if String(bare.get_summary()) != String(hoisted.get_summary()):
		_fail(errors, "standard without a pennant changed the summary: %s" % bare.get_summary())
	if String(bare.get_summary()).to_lower().contains("carried") or String(bare.get_summary()).to_lower().contains("standard") or String(bare.get_summary()).to_lower().contains("flew") or String(bare.get_summary()).to_lower().contains("pennant"):
		_fail(errors, "standard without a pennant names a standard: %s" % bare.get_summary())
	var bare_standard = plans["standard_only"]["standard"][0]
	var bare_banner = plans["standard_only"]["banner"][0]
	var bare_standard_salt: Dictionary = bare.get_cell_salt(int(bare_standard[0]), int(bare_standard[1]))
	var bare_banner_salt: Dictionary = bare.get_cell_salt(int(bare_banner[0]), int(bare_banner[1]))
	if int(bare_standard_salt.get("standard", 0)) != 0 or int(bare_banner_salt.get("banner", 0)) != 1 or int(bare_standard_salt.get("pennant", 0)) != 0:
		_fail(errors, "standard without a pennant holds %s, banner holds %s" % [bare_standard_salt.get("standard", 0), bare_banner_salt.get("banner", 0)])
	var standard_cell = plans["carried"]["standard"][0]
	var pennant_cell = plans["carried"]["pennant"][0]
	var banner_cell = plans["carried"]["banner"][0]
	var flag_cell = plans["carried"]["flag"][0]
	if int(standard_cell[0]) != int(pennant_cell[0]) or int(standard_cell[1]) != int(pennant_cell[1]) - 1:
		_fail(errors, "carried plan's standard is not one cell north of the pennant")
	if int(standard_cell[0]) != 14 or int(standard_cell[1]) != -12 or int(pennant_cell[0]) != 14 or int(pennant_cell[1]) != -11 or int(banner_cell[0]) != 14 or int(banner_cell[1]) != -10:
		_fail(errors, "carried plan's standard is not at 14,-12 north of the pennant at 14,-11")
	_assert_chain(carried, errors, "carried plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2, 1, 1, 1, 1, 1)
	var carried_unpaid := int(carried.get_hired()) - int(carried.get_paid())
	var carried_unposted := int(carried.get_paid()) - int(carried.get_posted())
	var carried_unstood := int(carried.get_posted()) - int(carried.get_stood())
	var carried_unlit := int(carried.get_stood()) - int(carried.get_lit())
	var carried_unrung := int(carried.get_lit()) - int(carried.get_rung())
	var carried_unraised := int(carried.get_sounded()) - int(carried.get_raised())
	var carried_unhoisted := int(carried.get_raised()) - int(carried.get_hoisted())
	var carried_unflown := int(carried.get_hoisted()) - int(carried.get_flown())
	var carried_uncarried := int(carried.get_flown()) - int(carried.get_carried())
	if int(carried.get_carried()) != 1 or int(carried.get_pennant_left()) != 0 or carried_uncarried != 0 or int(carried.get_flown()) != 1 or carried_unflown != 0 or carried_unhoisted != 0 or carried_unraised != 0 or int(carried.get_horn_left()) != 0 or int(carried.get_bell_left()) != 1 or carried_unrung != 1 or carried_unlit != 1 or carried_unstood != 2 or carried_unposted != 4 or carried_unpaid != 19 or int(carried.get_lamp_left()) != 1 or int(carried.get_watch_left()) != 1 or int(carried.get_relief_left()) != 2 or int(carried.get_wage_left()) != 4 or int(carried.get_loft_left()) != 19 or int(carried.get_gate_left()) != 0 or int(carried.get_yard_left()) != 57 or int(carried.get_hoisted()) != 1 or int(carried.get_raised()) != 1 or int(carried.get_sounded()) != 1 or int(carried.get_rung()) != 2 or int(carried.get_lit()) != 3 or int(carried.get_stood()) != 4 or int(carried.get_posted()) != 6 or int(carried.get_coins()) != 2997 or int(carried.get_hired()) != 29:
		_fail(errors, "carried %d, left %d flown uncarried, hoisted unflown %d, raised unhoisted %d, sounded unraised %d, rung unsounded %d, lit unrung %d, stood unlit %d, posted unstood %d, paid unposted %d, unpaid %d, pennant %d, yard %d, flown %d, hoisted %d, raised %d, sounded %d, rung %d, lit %d, stood %d, posted %d, coins %d, hired %d" % [carried.get_carried(), carried.get_pennant_left(), carried_unflown, carried_unhoisted, carried_unraised, carried.get_bell_left(), carried_unrung, carried_unlit, carried_unstood, carried_unposted, carried_unpaid, carried.get_pennant_left(), carried.get_yard_left(), carried.get_flown(), carried.get_hoisted(), carried.get_raised(), carried.get_sounded(), carried.get_rung(), carried.get_lit(), carried.get_stood(), carried.get_posted(), carried.get_coins(), carried.get_hired()])
	if int(carried.get_carried()) > int(Sim.STANDARD_CAP):
		_fail(errors, "standard carried %d, over the cap of %d" % [carried.get_carried(), Sim.STANDARD_CAP])
	var standard_salt: Dictionary = carried.get_cell_salt(int(standard_cell[0]), int(standard_cell[1]))
	var pennant_salt: Dictionary = carried.get_cell_salt(int(pennant_cell[0]), int(pennant_cell[1]))
	var banner_salt: Dictionary = carried.get_cell_salt(int(banner_cell[0]), int(banner_cell[1]))
	var flag_salt: Dictionary = carried.get_cell_salt(int(flag_cell[0]), int(flag_cell[1]))
	if int(standard_salt.get("standard", 0)) != 1 or int(pennant_salt.get("pennant", 0)) != 0 or int(banner_salt.get("banner", 0)) != 0 or int(flag_salt.get("flag", 0)) != 0:
		_fail(errors, "standard cell holds %s, pennant holds %s, banner holds %s, flag holds %s" % [standard_salt.get("standard", 0), pennant_salt.get("pennant", 0), banner_salt.get("banner", 0), flag_salt.get("flag", 0)])
	var carried_summary := String(carried.get_summary())
	if not carried_summary.contains("Carried 1 on the standard") or not carried_summary.contains("Left 0 at the pennant") or not carried_summary.contains("Flew 1 on the pennant") or not carried_summary.contains("Left 0 at the banner") or not carried_summary.contains("Coins 2997") or not carried_summary.contains("Hired 29") or not carried_summary.contains("Left 57"):
		_fail(errors, "carried summary does not name the standard: %s" % carried_summary)
	if int(carried_again.get_carried()) != int(carried.get_carried()) or int(carried_again.get_pennant_left()) != int(carried.get_pennant_left()) or int(carried_again.get_flown()) != int(carried.get_flown()) or int(carried_again.get_yard_left()) != int(carried.get_yard_left()) or int(carried_again.get_stored_salt()) != int(carried.get_stored_salt()) or String(carried_again.get_summary()) != String(carried.get_summary()):
		_fail(errors, "repeated standard paint carried %d and left pennant %d, then carried %d and left pennant %d" % [carried.get_carried(), carried.get_pennant_left(), carried_again.get_carried(), carried_again.get_pennant_left()])
	if int(late.get_carried()) != 1 or int(late.get_pennant_left()) != 0 or int(late.get_flown()) != 1 or int(late.get_hoisted()) != 1 or int(late.get_raised()) != 1 or int(late.get_sounded()) != 1 or int(late.get_rung()) != 2 or int(late.get_lit()) != 3 or int(late.get_stood()) != 4 or int(late.get_posted()) != 6 or int(late.get_yard_left()) != 57 or int(late.get_hired()) != 29 or int(late.get_coins()) != 2997 or int(late.get_stored_salt()) != 2997 or int(late.get_loft_left()) != 19 or int(late.get_wage_left()) != 4:
		_fail(errors, "painting the standard at the standard beat (carried %d pennant %d flown %d yard %d) did not match painting it early (carried %d pennant %d flown %d)" % [late.get_carried(), late.get_pennant_left(), late.get_flown(), late.get_yard_left(), carried.get_carried(), carried.get_pennant_left(), carried.get_flown()])
	_assert_chain(dry_carried, errors, "dry standard", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 2, 1, 1, 1, 1, 1)
	var dry_unpaid := int(dry_carried.get_hired()) - int(dry_carried.get_paid())
	var dry_unposted := int(dry_carried.get_paid()) - int(dry_carried.get_posted())
	var dry_unstood := int(dry_carried.get_posted()) - int(dry_carried.get_stood())
	var dry_unlit := int(dry_carried.get_stood()) - int(dry_carried.get_lit())
	var dry_unrung := int(dry_carried.get_lit()) - int(dry_carried.get_rung())
	var dry_unraised := int(dry_carried.get_sounded()) - int(dry_carried.get_raised())
	var dry_unhoisted := int(dry_carried.get_raised()) - int(dry_carried.get_hoisted())
	var dry_unflown := int(dry_carried.get_hoisted()) - int(dry_carried.get_flown())
	var dry_uncarried := int(dry_carried.get_flown()) - int(dry_carried.get_carried())
	if int(dry_carried.get_carried()) != 1 or int(dry_carried.get_pennant_left()) != 0 or dry_uncarried != 0 or int(dry_carried.get_flown()) != 1 or dry_unflown != 0 or dry_unhoisted != 0 or dry_unraised != 0 or int(dry_carried.get_horn_left()) != 0 or int(dry_carried.get_bell_left()) != 1 or dry_unrung != 1 or dry_unlit != 1 or dry_unstood != 2 or dry_unposted != 2 or dry_unpaid != 2 or int(dry_carried.get_yard_left()) != 0 or int(dry_carried.get_hoisted()) != 1 or int(dry_carried.get_raised()) != 1 or int(dry_carried.get_sounded()) != 1 or int(dry_carried.get_rung()) != 2 or int(dry_carried.get_lit()) != 3 or int(dry_carried.get_stood()) != 4 or int(dry_carried.get_posted()) != 6 or int(dry_carried.get_wet_haul()) != 0 or int(dry_carried.get_stored_salt()) != 1032 or int(dry_carried.get_gate_left()) != 2 or int(dry_carried.get_wage_left()) != 2 or int(dry_carried.get_loft_left()) != 0:
		_fail(errors, "dry standard changed the short crew (wet %d stored %d carried %d pennant %d flown %d banner %d hoisted %d uncarried %d unflown %d unhoisted %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d yard %d)" % [dry_carried.get_wet_haul(), dry_carried.get_stored_salt(), dry_carried.get_carried(), dry_carried.get_pennant_left(), dry_carried.get_flown(), dry_carried.get_banner_left(), dry_carried.get_hoisted(), dry_uncarried, dry_unflown, dry_unhoisted, dry_unraised, dry_carried.get_bell_left(), dry_unrung, dry_unlit, dry_unstood, dry_unposted, dry_unpaid, dry_carried.get_yard_left()])
	var dry_standard_cell = plans["dry_carried"]["standard"][0]
	var dry_pennant_cell = plans["dry_carried"]["pennant"][0]
	var dry_standard_salt: Dictionary = dry_carried.get_cell_salt(int(dry_standard_cell[0]), int(dry_standard_cell[1]))
	var dry_pennant_salt: Dictionary = dry_carried.get_cell_salt(int(dry_pennant_cell[0]), int(dry_pennant_cell[1]))
	if int(dry_standard_salt.get("standard", 0)) != 1 or int(dry_pennant_salt.get("pennant", 0)) != 0:
		_fail(errors, "dry standard cell holds %s, pennant holds %s" % [dry_standard_salt.get("standard", 0), dry_pennant_salt.get("pennant", 0)])
	if not String(dry_carried.get_summary()).contains("Carried 1 on the standard") or not String(dry_carried.get_summary()).contains("Left 0 at the pennant") or not String(dry_carried.get_summary()).contains("Flew 1 on the pennant") or not String(dry_carried.get_summary()).contains("Left 0 in the yard"):
		_fail(errors, "dry standard summary does not name the cap: %s" % dry_carried.get_summary())
	_assert_pop(carried, errors, "carried plan")
	_assert_pop(carried_again, errors, "carried plan again")
	_assert_pop(late, errors, "late_carried")
	_assert_pop(dry_carried, errors, "dry_carried")
	_assert_pop(ignored, errors, "no_standard")
	_assert_pop(bare, errors, "standard_only")
	var shore = _prepare_plan(plans, "carried", errors)
	if shore == null:
		return
	var shore_guard := 0
	var shore_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + 2
	while int(shore.get_beat()) != Sim.STANDARDING and not shore.is_over() and shore_guard < shore_limit:
		shore.tick()
		shore_guard += 1
	if int(shore.get_beat()) != Sim.STANDARDING or shore.is_over():
		_fail(errors, "the pennant beat did not open a standard beat for the cap check")
		return
	if int(shore.get_ticks_until_rain()) != int(Sim.STANDARD_TICK):
		_fail(errors, "standard countdown started at %d, expected %d" % [shore.get_ticks_until_rain(), Sim.STANDARD_TICK])
	if int(shore.get_carried()) != 0 or int(shore.get_flown()) != 1 or int(shore.get_pennant_left()) != 1 or int(shore.get_hoisted()) != 1 or int(shore.get_yard_left()) != 57 or int(shore.get_coins()) != 2997 or int(shore.get_stored_salt()) != 2997:
		_fail(errors, "standard opened early (carried %d flown %d pennant %d hoisted %d yard %d coins %d stored %d)" % [shore.get_carried(), shore.get_flown(), shore.get_pennant_left(), shore.get_hoisted(), shore.get_yard_left(), shore.get_coins(), shore.get_stored_salt()])
	var saw_cap := false
	var carry_guard := 0
	while not shore.is_over() and carry_guard < int(Sim.STANDARD_TICK) + 2:
		shore.tick()
		carry_guard += 1
		if int(shore.get_carried()) == int(Sim.STANDARD_CAP) and int(shore.get_pennant_left()) == 0 and int(shore.get_flown()) == 1 and int(shore.get_hoisted()) == 1 and int(shore.get_yard_left()) == 57 and int(shore.get_coins()) == 2997 and int(shore.get_hired()) == 29 and int(shore.get_ticks_until_rain()) > 0:
			saw_cap = true
			var ticks_left := int(shore.get_ticks_until_rain())
			shore.tick()
			if int(shore.get_carried()) != int(Sim.STANDARD_CAP) or int(shore.get_pennant_left()) != 0 or int(shore.get_flown()) != 1 or int(shore.get_hoisted()) != 1 or int(shore.get_raised()) != 1 or int(shore.get_yard_left()) != 57 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29 or int(shore.get_stored_salt()) != 2997 or int(shore.get_posted()) != 6 or int(shore.get_stood()) != 4 or int(shore.get_lit()) != 3 or int(shore.get_rung()) != 2 or int(shore.get_sounded()) != 1:
				_fail(errors, "the standard kept carrying after the cap (carried %d pennant %d flown %d hoisted %d yard %d)" % [shore.get_carried(), shore.get_pennant_left(), shore.get_flown(), shore.get_hoisted(), shore.get_yard_left()])
			elif not shore.is_over() and int(shore.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the standard beat did not spend a tick after the cap")
			break
	if not saw_cap:
		_fail(errors, "the standard did not stop at %d while ticks remained (carried %d pennant %d flown %d ticks %d)" % [Sim.STANDARD_CAP, shore.get_carried(), shore.get_pennant_left(), shore.get_flown(), shore.get_ticks_until_rain()])
	var short = _prepare_plan(plans, "dry_carried", errors)
	if short == null:
		return
	var short_guard := 0
	while int(short.get_beat()) != Sim.STANDARDING and not short.is_over() and short_guard < shore_limit:
		short.tick()
		short_guard += 1
	if int(short.get_beat()) != Sim.STANDARDING or short.is_over():
		_fail(errors, "the pennant beat did not open a standard beat for the dry cap")
		return
	var saw_short := false
	var short_steps := 0
	while not short.is_over() and short_steps < int(Sim.STANDARD_TICK) + 2:
		short.tick()
		short_steps += 1
		if int(short.get_carried()) == int(Sim.STANDARD_CAP) and int(short.get_pennant_left()) == 0 and int(short.get_flown()) == 1 and int(short.get_hoisted()) == 1 and int(short.get_yard_left()) == 0 and int(short.get_wet_haul()) == 0 and int(short.get_ticks_until_rain()) > 0:
			saw_short = true
			var short_ticks := int(short.get_ticks_until_rain())
			short.tick()
			if int(short.get_carried()) != 1 or int(short.get_pennant_left()) != 0 or int(short.get_flown()) != 1 or int(short.get_yard_left()) != 0 or int(short.get_posted()) != 6 or int(short.get_stored_salt()) != 1032:
				_fail(errors, "the standard carried an unflown hire or passed the cap (carried %d pennant %d flown %d yard %d)" % [short.get_carried(), short.get_pennant_left(), short.get_flown(), short.get_yard_left()])
			elif not short.is_over() and int(short.get_ticks_until_rain()) >= short_ticks:
				_fail(errors, "the standard beat did not spend a tick after the dry cap")
			break
	if not saw_short:
		_fail(errors, "dry standard did not stop at 1 with the pennant clear (carried %d pennant %d flown %d yard %d ticks %d)" % [short.get_carried(), short.get_pennant_left(), short.get_flown(), short.get_yard_left(), short.get_ticks_until_rain()])
	print("carried %d left pennant %d unflown %d unhoisted %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d; dry carried %d left pennant %d unflown %d unhoisted %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d; no standard carried %d left pennant %d; standard without pennant carried %d" % [carried.get_carried(), carried.get_pennant_left(), carried_unflown, carried_unhoisted, carried_unraised, carried.get_bell_left(), carried_unrung, carried_unlit, carried_unstood, carried_unposted, carried_unpaid, dry_carried.get_carried(), dry_carried.get_pennant_left(), dry_unflown, dry_unhoisted, dry_unraised, dry_carried.get_bell_left(), dry_unrung, dry_unlit, dry_unstood, dry_unposted, dry_unpaid, ignored.get_carried(), ignored.get_pennant_left(), bare.get_carried()])


func _test_jack(errors: Array) -> void:
	if int(Sim.JACK_TICK) != 100 or int(Sim.JACK_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "jack beat length %s is not 100 ticks (10 seconds)" % Sim.JACK_TICK)
	if int(Sim.JACK_CAP) != 1:
		_fail(errors, "jack cap is %s, expected 1" % Sim.JACK_CAP)
	if int(Sim.GRID_NORTH) > -13:
		_fail(errors, "the map was not extended to the jack row (north %s)" % Sim.GRID_NORTH)
	if int(Sim.JACK_CELL.x) != 14 or int(Sim.JACK_CELL.y) != -13:
		_fail(errors, "the jack cell is not at 14,-13")
	if int(Sim.STANDARD_CELL.x) != 14 or int(Sim.STANDARD_CELL.y) != -12:
		_fail(errors, "the standard moved off 14,-12")
	if int(Sim.PENNANT_CELL.x) != 14 or int(Sim.PENNANT_CELL.y) != -11:
		_fail(errors, "the pennant moved off 14,-11")
	var fresh = Sim.new()
	if fresh.paint_cell(14, -13, Sim.JACK) == false or int(fresh.get_paint(14, -13)) != Sim.JACK:
		_fail(errors, "the cell north of the standard rejected the jack mark")
	if fresh.paint_cell(14, -12, Sim.JACK):
		_fail(errors, "the standard cell accepted a jack")
	if int(fresh.get_paint(14, -12)) != Sim.EMPTY:
		_fail(errors, "a rejected jack painted the standard cell")
	if fresh.paint_cell(14, -13, Sim.STANDARD):
		_fail(errors, "the jack cell accepted a standard")
	if int(fresh.get_paint(14, -13)) != Sim.JACK:
		_fail(errors, "a rejected standard erased the jack")
	if fresh.paint_cell(14, -12, Sim.STANDARD) == false or int(fresh.get_paint(14, -12)) != Sim.STANDARD:
		_fail(errors, "the standard cell no longer accepts a standard")
	if fresh.paint_cell(14, -11, Sim.PENNANT) == false or int(fresh.get_paint(14, -11)) != Sim.PENNANT:
		_fail(errors, "the pennant cell no longer accepts a pennant")
	if fresh.paint_cell(14, -10, Sim.BANNER) == false or int(fresh.get_paint(14, -10)) != Sim.BANNER:
		_fail(errors, "the banner cell no longer accepts a banner")
	if fresh.paint_cell(14, -9, Sim.FLAG) == false or int(fresh.get_paint(14, -9)) != Sim.FLAG:
		_fail(errors, "the flag cell no longer accepts a flag")
	if fresh.paint_cell(14, -14, Sim.JACK) or fresh.paint_cell(13, -13, Sim.JACK) or fresh.paint_cell(15, -13, Sim.JACK):
		_fail(errors, "a cell other than 14,-13 accepted a jack")
	if fresh.paint_cell(Sim.COAST_X, -13, Sim.JACK):
		_fail(errors, "the brine accepted a jack")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.JACK):
		_fail(errors, "the anthill accepted a jack")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var won = _run_plan(plans, "winning", errors)
	var dry = _run_plan(plans, "dry_pans", errors)
	var carried = _run_plan(plans, "carried", errors)
	var flown = _run_plan(plans, "flown", errors)
	var no_jack = _run_plan(plans, "no_jack", errors)
	var bare = _run_plan(plans, "jack_only", errors)
	var shown = _run_plan(plans, "shown", errors)
	var shown_again = _run_plan(plans, "shown", errors)
	var late = _run_plan(plans, "late_shown", errors)
	var dry_shown = _run_plan(plans, "dry_shown", errors)
	if won == null or dry == null or carried == null or flown == null or no_jack == null or bare == null or shown == null or shown_again == null or late == null or dry_shown == null:
		return
	_assert_chain(won, errors, "winning shore", 2997, 2997, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	_assert_chain(dry, errors, "dry pans", 0, 1032, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	if int(won.get_shown()) != 0 or int(dry.get_shown()) != 0:
		_fail(errors, "a plan with no jack showed someone (winning %d dry %d)" % [won.get_shown(), dry.get_shown()])
	if String(carried.get_summary()) != String(no_jack.get_summary()):
		_fail(errors, "a standard with no jack changed the carried summary: %s" % no_jack.get_summary())
	if String(no_jack.get_summary()).to_lower().contains("showed") or String(no_jack.get_summary()).to_lower().contains("jack"):
		_fail(errors, "a standard with no jack names a jack: %s" % no_jack.get_summary())
	var kept_unshown := int(no_jack.get_carried()) - int(no_jack.get_shown())
	if int(no_jack.get_shown()) != 0 or int(no_jack.get_standard_left()) != 1 or kept_unshown != 1 or int(no_jack.get_carried()) != 1 or int(no_jack.get_pennant_left()) != 0 or int(no_jack.get_flown()) != 1 or int(no_jack.get_hoisted()) != 1 or int(no_jack.get_raised()) != 1 or int(no_jack.get_sounded()) != 1 or int(no_jack.get_rung()) != 2 or int(no_jack.get_lit()) != 3 or int(no_jack.get_stood()) != 4 or int(no_jack.get_posted()) != 6 or int(no_jack.get_yard_left()) != 57 or int(no_jack.get_coins()) != 2997 or int(no_jack.get_hired()) != 29 or int(no_jack.get_stored_salt()) != 2997:
		_fail(errors, "a standard with no jack showed someone (shown %d standard %d carried %d coins %d hired %d yard %d)" % [no_jack.get_shown(), no_jack.get_standard_left(), no_jack.get_carried(), no_jack.get_coins(), no_jack.get_hired(), no_jack.get_yard_left()])
	var kept_standard = plans["no_jack"]["standard"][0]
	var kept_salt: Dictionary = no_jack.get_cell_salt(int(kept_standard[0]), int(kept_standard[1]))
	var kept_north: Dictionary = no_jack.get_cell_salt(int(kept_standard[0]), int(kept_standard[1]) - 1)
	if int(kept_salt.get("standard", 0)) != 1 or int(kept_north.get("jack", 0)) != 0 or int(kept_salt.get("jack", 0)) != 0:
		_fail(errors, "a standard with no jack left %s on the standard and %s on a jack" % [kept_salt.get("standard", 0), kept_north.get("jack", 0)])
	if String(bare.get_summary()) != String(flown.get_summary()):
		_fail(errors, "a jack with no standard changed the flown summary: %s" % bare.get_summary())
	if String(bare.get_summary()).to_lower().contains("showed") or String(bare.get_summary()).to_lower().contains("jack") or String(bare.get_summary()).to_lower().contains("carried") or String(bare.get_summary()).to_lower().contains("standard"):
		_fail(errors, "a jack with no standard names a jack: %s" % bare.get_summary())
	if int(bare.get_shown()) != 0 or int(bare.get_carried()) != 0 or int(bare.get_standard_left()) != 0 or int(bare.get_flown()) != 1 or int(bare.get_pennant_left()) != 1 or int(bare.get_hoisted()) != 1 or int(bare.get_banner_left()) != 0 or int(bare.get_yard_left()) != 57 or int(bare.get_coins()) != 2997 or int(bare.get_hired()) != 29:
		_fail(errors, "a jack with no standard showed someone (shown %d carried %d pennant %d flown %d)" % [bare.get_shown(), bare.get_carried(), bare.get_pennant_left(), bare.get_flown()])
	var bare_jack = plans["jack_only"]["jack"][0]
	var bare_pennant = plans["jack_only"]["pennant"][0]
	var bare_jack_salt: Dictionary = bare.get_cell_salt(int(bare_jack[0]), int(bare_jack[1]))
	var bare_pennant_salt: Dictionary = bare.get_cell_salt(int(bare_pennant[0]), int(bare_pennant[1]))
	if int(bare_jack_salt.get("jack", 0)) != 0 or int(bare_pennant_salt.get("pennant", 0)) != 1 or int(bare_jack_salt.get("standard", 0)) != 0:
		_fail(errors, "jack without a standard holds %s, pennant holds %s" % [bare_jack_salt.get("jack", 0), bare_pennant_salt.get("pennant", 0)])
	var jack_cell = plans["shown"]["jack"][0]
	var standard_cell = plans["shown"]["standard"][0]
	var pennant_cell = plans["shown"]["pennant"][0]
	var banner_cell = plans["shown"]["banner"][0]
	var flag_cell = plans["shown"]["flag"][0]
	if int(jack_cell[0]) != int(standard_cell[0]) or int(jack_cell[1]) != int(standard_cell[1]) - 1:
		_fail(errors, "shown plan's jack is not one cell north of the standard")
	if int(jack_cell[0]) != 14 or int(jack_cell[1]) != -13 or int(standard_cell[0]) != 14 or int(standard_cell[1]) != -12 or int(pennant_cell[0]) != 14 or int(pennant_cell[1]) != -11 or int(banner_cell[0]) != 14 or int(banner_cell[1]) != -10 or int(flag_cell[0]) != 14 or int(flag_cell[1]) != -9:
		_fail(errors, "shown plan moved the jack, the standard, the pennant, the banner, or the flag")
	_assert_chain(shown, errors, "shown plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2, 1, 1, 1, 1, 1, 1)
	var shown_unpaid := int(shown.get_hired()) - int(shown.get_paid())
	var shown_unposted := int(shown.get_paid()) - int(shown.get_posted())
	var shown_unstood := int(shown.get_posted()) - int(shown.get_stood())
	var shown_unlit := int(shown.get_stood()) - int(shown.get_lit())
	var shown_unrung := int(shown.get_lit()) - int(shown.get_rung())
	var shown_unraised := int(shown.get_sounded()) - int(shown.get_raised())
	var shown_unhoisted := int(shown.get_raised()) - int(shown.get_hoisted())
	var shown_unflown := int(shown.get_hoisted()) - int(shown.get_flown())
	var shown_uncarried := int(shown.get_flown()) - int(shown.get_carried())
	var shown_unshown := int(shown.get_carried()) - int(shown.get_shown())
	if int(shown.get_shown()) != 1 or int(shown.get_standard_left()) != 0 or shown_unshown != 0 or int(shown.get_carried()) != 1 or shown_uncarried != 0 or int(shown.get_pennant_left()) != 0 or shown_unflown != 0 or shown_unhoisted != 0 or shown_unraised != 0 or int(shown.get_horn_left()) != 0 or int(shown.get_bell_left()) != 1 or shown_unrung != 1 or shown_unlit != 1 or shown_unstood != 2 or shown_unposted != 4 or shown_unpaid != 19 or int(shown.get_lamp_left()) != 1 or int(shown.get_watch_left()) != 1 or int(shown.get_relief_left()) != 2 or int(shown.get_wage_left()) != 4 or int(shown.get_loft_left()) != 19 or int(shown.get_gate_left()) != 0 or int(shown.get_yard_left()) != 57 or int(shown.get_flown()) != 1 or int(shown.get_hoisted()) != 1 or int(shown.get_raised()) != 1 or int(shown.get_sounded()) != 1 or int(shown.get_rung()) != 2 or int(shown.get_lit()) != 3 or int(shown.get_stood()) != 4 or int(shown.get_posted()) != 6 or int(shown.get_coins()) != 2997 or int(shown.get_hired()) != 29 or int(shown.get_stored_salt()) != 2997:
		_fail(errors, "shown %d, left %d carried unshown, flown uncarried %d, hoisted unflown %d, raised unhoisted %d, sounded unraised %d, rung unsounded %d, lit unrung %d, stood unlit %d, posted unstood %d, paid unposted %d, unpaid %d, standard %d, yard %d, carried %d, flown %d, hoisted %d, raised %d, sounded %d, rung %d, lit %d, stood %d, posted %d, coins %d, hired %d" % [shown.get_shown(), shown.get_standard_left(), shown_uncarried, shown_unflown, shown_unhoisted, shown_unraised, shown.get_bell_left(), shown_unrung, shown_unlit, shown_unstood, shown_unposted, shown_unpaid, shown.get_standard_left(), shown.get_yard_left(), shown.get_carried(), shown.get_flown(), shown.get_hoisted(), shown.get_raised(), shown.get_sounded(), shown.get_rung(), shown.get_lit(), shown.get_stood(), shown.get_posted(), shown.get_coins(), shown.get_hired()])
	if int(shown.get_shown()) > int(Sim.JACK_CAP):
		_fail(errors, "jack showed %d, over the cap of %d" % [shown.get_shown(), Sim.JACK_CAP])
	var jack_salt: Dictionary = shown.get_cell_salt(int(jack_cell[0]), int(jack_cell[1]))
	var standard_salt: Dictionary = shown.get_cell_salt(int(standard_cell[0]), int(standard_cell[1]))
	var pennant_salt: Dictionary = shown.get_cell_salt(int(pennant_cell[0]), int(pennant_cell[1]))
	if int(jack_salt.get("jack", 0)) != 1 or int(standard_salt.get("standard", 0)) != 0 or int(pennant_salt.get("pennant", 0)) != 0 or int(jack_salt.get("standard", 0)) != 0:
		_fail(errors, "jack cell holds %s, standard holds %s, pennant holds %s" % [jack_salt.get("jack", 0), standard_salt.get("standard", 0), pennant_salt.get("pennant", 0)])
	var shown_summary := String(shown.get_summary())
	if not shown_summary.contains("Showed 1 on the jack") or not shown_summary.contains("Left 0 at the standard") or not shown_summary.contains("Carried 1 on the standard") or not shown_summary.contains("Coins 2997") or not shown_summary.contains("Hired 29") or not shown_summary.contains("Left 57"):
		_fail(errors, "shown summary does not name the jack: %s" % shown_summary)
	if int(shown_again.get_shown()) != int(shown.get_shown()) or int(shown_again.get_standard_left()) != int(shown.get_standard_left()) or int(shown_again.get_carried()) != int(shown.get_carried()) or int(shown_again.get_yard_left()) != int(shown.get_yard_left()) or int(shown_again.get_stored_salt()) != int(shown.get_stored_salt()) or String(shown_again.get_summary()) != String(shown.get_summary()):
		_fail(errors, "repeated jack paint showed %d and left standard %d, then showed %d and left standard %d" % [shown.get_shown(), shown.get_standard_left(), shown_again.get_shown(), shown_again.get_standard_left()])
	if int(late.get_shown()) != 1 or int(late.get_standard_left()) != 0 or int(late.get_carried()) != 1 or int(late.get_flown()) != 1 or int(late.get_hoisted()) != 1 or int(late.get_raised()) != 1 or int(late.get_sounded()) != 1 or int(late.get_rung()) != 2 or int(late.get_lit()) != 3 or int(late.get_stood()) != 4 or int(late.get_posted()) != 6 or int(late.get_yard_left()) != 57 or int(late.get_hired()) != 29 or int(late.get_coins()) != 2997 or int(late.get_stored_salt()) != 2997 or int(late.get_loft_left()) != 19 or int(late.get_wage_left()) != 4:
		_fail(errors, "painting the jack at the jack beat (shown %d standard %d carried %d yard %d) did not match painting it early (shown %d standard %d carried %d)" % [late.get_shown(), late.get_standard_left(), late.get_carried(), late.get_yard_left(), shown.get_shown(), shown.get_standard_left(), shown.get_carried()])
	_assert_chain(dry_shown, errors, "dry jack", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 2, 1, 1, 1, 1, 1, 1)
	var dry_unpaid := int(dry_shown.get_hired()) - int(dry_shown.get_paid())
	var dry_unposted := int(dry_shown.get_paid()) - int(dry_shown.get_posted())
	var dry_unstood := int(dry_shown.get_posted()) - int(dry_shown.get_stood())
	var dry_unlit := int(dry_shown.get_stood()) - int(dry_shown.get_lit())
	var dry_unrung := int(dry_shown.get_lit()) - int(dry_shown.get_rung())
	var dry_unraised := int(dry_shown.get_sounded()) - int(dry_shown.get_raised())
	var dry_unhoisted := int(dry_shown.get_raised()) - int(dry_shown.get_hoisted())
	var dry_unflown := int(dry_shown.get_hoisted()) - int(dry_shown.get_flown())
	var dry_uncarried := int(dry_shown.get_flown()) - int(dry_shown.get_carried())
	var dry_unshown := int(dry_shown.get_carried()) - int(dry_shown.get_shown())
	if int(dry_shown.get_shown()) != 1 or int(dry_shown.get_standard_left()) != 0 or dry_unshown != 0 or int(dry_shown.get_carried()) != 1 or dry_uncarried != 0 or int(dry_shown.get_pennant_left()) != 0 or dry_unflown != 0 or dry_unhoisted != 0 or dry_unraised != 0 or int(dry_shown.get_horn_left()) != 0 or int(dry_shown.get_bell_left()) != 1 or dry_unrung != 1 or dry_unlit != 1 or dry_unstood != 2 or dry_unposted != 2 or dry_unpaid != 2 or int(dry_shown.get_yard_left()) != 0 or int(dry_shown.get_flown()) != 1 or int(dry_shown.get_hoisted()) != 1 or int(dry_shown.get_raised()) != 1 or int(dry_shown.get_sounded()) != 1 or int(dry_shown.get_rung()) != 2 or int(dry_shown.get_lit()) != 3 or int(dry_shown.get_stood()) != 4 or int(dry_shown.get_posted()) != 6 or int(dry_shown.get_wet_haul()) != 0 or int(dry_shown.get_stored_salt()) != 1032 or int(dry_shown.get_gate_left()) != 2 or int(dry_shown.get_wage_left()) != 2 or int(dry_shown.get_loft_left()) != 0:
		_fail(errors, "dry jack changed the short crew (wet %d stored %d shown %d standard %d carried %d pennant %d flown %d unshown %d uncarried %d unflown %d unhoisted %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d yard %d)" % [dry_shown.get_wet_haul(), dry_shown.get_stored_salt(), dry_shown.get_shown(), dry_shown.get_standard_left(), dry_shown.get_carried(), dry_shown.get_pennant_left(), dry_shown.get_flown(), dry_unshown, dry_uncarried, dry_unflown, dry_unhoisted, dry_unraised, dry_shown.get_bell_left(), dry_unrung, dry_unlit, dry_unstood, dry_unposted, dry_unpaid, dry_shown.get_yard_left()])
	var dry_jack_cell = plans["dry_shown"]["jack"][0]
	var dry_standard_cell = plans["dry_shown"]["standard"][0]
	var dry_jack_salt: Dictionary = dry_shown.get_cell_salt(int(dry_jack_cell[0]), int(dry_jack_cell[1]))
	var dry_standard_salt: Dictionary = dry_shown.get_cell_salt(int(dry_standard_cell[0]), int(dry_standard_cell[1]))
	if int(dry_jack_salt.get("jack", 0)) != 1 or int(dry_standard_salt.get("standard", 0)) != 0:
		_fail(errors, "dry jack cell holds %s, standard holds %s" % [dry_jack_salt.get("jack", 0), dry_standard_salt.get("standard", 0)])
	if not String(dry_shown.get_summary()).contains("Showed 1 on the jack") or not String(dry_shown.get_summary()).contains("Left 0 at the standard") or not String(dry_shown.get_summary()).contains("Carried 1 on the standard") or not String(dry_shown.get_summary()).contains("Left 0 in the yard"):
		_fail(errors, "dry jack summary does not name the cap: %s" % dry_shown.get_summary())
	_assert_pop(shown, errors, "shown plan")
	_assert_pop(shown_again, errors, "shown plan again")
	_assert_pop(late, errors, "late_shown")
	_assert_pop(dry_shown, errors, "dry_shown")
	_assert_pop(no_jack, errors, "no_jack")
	_assert_pop(bare, errors, "jack_only")
	var shore = _prepare_plan(plans, "shown", errors)
	if shore == null:
		return
	var shore_guard := 0
	var shore_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + int(Sim.STANDARD_TICK) + 2
	while int(shore.get_beat()) != Sim.JACKING and not shore.is_over() and shore_guard < shore_limit:
		shore.tick()
		shore_guard += 1
	if int(shore.get_beat()) != Sim.JACKING or shore.is_over():
		_fail(errors, "the standard beat did not open a jack beat for the cap check")
		return
	if int(shore.get_ticks_until_rain()) != int(Sim.JACK_TICK):
		_fail(errors, "jack countdown started at %d, expected %d" % [shore.get_ticks_until_rain(), Sim.JACK_TICK])
	if int(shore.get_shown()) != 0 or int(shore.get_carried()) != 1 or int(shore.get_standard_left()) != 1 or int(shore.get_flown()) != 1 or int(shore.get_pennant_left()) != 0 or int(shore.get_yard_left()) != 57 or int(shore.get_coins()) != 2997 or int(shore.get_stored_salt()) != 2997:
		_fail(errors, "jack opened early (shown %d carried %d standard %d flown %d yard %d coins %d stored %d)" % [shore.get_shown(), shore.get_carried(), shore.get_standard_left(), shore.get_flown(), shore.get_yard_left(), shore.get_coins(), shore.get_stored_salt()])
	var saw_cap := false
	var show_guard := 0
	while not shore.is_over() and show_guard < int(Sim.JACK_TICK) + 2:
		shore.tick()
		show_guard += 1
		if int(shore.get_shown()) == int(Sim.JACK_CAP) and int(shore.get_standard_left()) == 0 and int(shore.get_carried()) == 1 and int(shore.get_flown()) == 1 and int(shore.get_hoisted()) == 1 and int(shore.get_yard_left()) == 57 and int(shore.get_coins()) == 2997 and int(shore.get_hired()) == 29 and int(shore.get_ticks_until_rain()) > 0:
			saw_cap = true
			var ticks_left := int(shore.get_ticks_until_rain())
			shore.tick()
			if int(shore.get_shown()) != int(Sim.JACK_CAP) or int(shore.get_standard_left()) != 0 or int(shore.get_carried()) != 1 or int(shore.get_flown()) != 1 or int(shore.get_hoisted()) != 1 or int(shore.get_raised()) != 1 or int(shore.get_yard_left()) != 57 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29 or int(shore.get_stored_salt()) != 2997 or int(shore.get_posted()) != 6 or int(shore.get_stood()) != 4 or int(shore.get_lit()) != 3 or int(shore.get_rung()) != 2 or int(shore.get_sounded()) != 1:
				_fail(errors, "the jack kept showing after the cap (shown %d standard %d carried %d flown %d yard %d)" % [shore.get_shown(), shore.get_standard_left(), shore.get_carried(), shore.get_flown(), shore.get_yard_left()])
			elif not shore.is_over() and int(shore.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the jack beat did not spend a tick after the cap")
			break
	if not saw_cap:
		_fail(errors, "the jack did not stop at %d while ticks remained (shown %d standard %d carried %d ticks %d)" % [Sim.JACK_CAP, shore.get_shown(), shore.get_standard_left(), shore.get_carried(), shore.get_ticks_until_rain()])
	var short = _prepare_plan(plans, "dry_shown", errors)
	if short == null:
		return
	var short_guard := 0
	while int(short.get_beat()) != Sim.JACKING and not short.is_over() and short_guard < shore_limit:
		short.tick()
		short_guard += 1
	if int(short.get_beat()) != Sim.JACKING or short.is_over():
		_fail(errors, "the standard beat did not open a jack beat for the dry cap")
		return
	var saw_short := false
	var short_steps := 0
	while not short.is_over() and short_steps < int(Sim.JACK_TICK) + 2:
		short.tick()
		short_steps += 1
		if int(short.get_shown()) == int(Sim.JACK_CAP) and int(short.get_standard_left()) == 0 and int(short.get_carried()) == 1 and int(short.get_flown()) == 1 and int(short.get_yard_left()) == 0 and int(short.get_wet_haul()) == 0 and int(short.get_ticks_until_rain()) > 0:
			saw_short = true
			var short_ticks := int(short.get_ticks_until_rain())
			short.tick()
			if int(short.get_shown()) != 1 or int(short.get_standard_left()) != 0 or int(short.get_carried()) != 1 or int(short.get_flown()) != 1 or int(short.get_yard_left()) != 0 or int(short.get_posted()) != 6 or int(short.get_stored_salt()) != 1032:
				_fail(errors, "the jack showed an uncarried hire or passed the cap (shown %d standard %d carried %d yard %d)" % [short.get_shown(), short.get_standard_left(), short.get_carried(), short.get_yard_left()])
			elif not short.is_over() and int(short.get_ticks_until_rain()) >= short_ticks:
				_fail(errors, "the jack beat did not spend a tick after the dry cap")
			break
	if not saw_short:
		_fail(errors, "dry jack did not stop at 1 with the standard clear (shown %d standard %d carried %d yard %d ticks %d)" % [short.get_shown(), short.get_standard_left(), short.get_carried(), short.get_yard_left(), short.get_ticks_until_rain()])
	print("shown %d left standard %d uncarried %d unflown %d unhoisted %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d; dry shown %d left standard %d uncarried %d unflown %d unhoisted %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d; no jack shown %d left standard %d; jack without standard shown %d" % [shown.get_shown(), shown.get_standard_left(), shown_uncarried, shown_unflown, shown_unhoisted, shown_unraised, shown.get_bell_left(), shown_unrung, shown_unlit, shown_unstood, shown_unposted, shown_unpaid, dry_shown.get_shown(), dry_shown.get_standard_left(), dry_uncarried, dry_unflown, dry_unhoisted, dry_unraised, dry_shown.get_bell_left(), dry_unrung, dry_unlit, dry_unstood, dry_unposted, dry_unpaid, no_jack.get_shown(), no_jack.get_standard_left(), bare.get_shown()])


func _test_ensign(errors: Array) -> void:
	if int(Sim.ENSIGN_TICK) != 100 or int(Sim.ENSIGN_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "ensign beat length %s is not 100 ticks (10 seconds)" % Sim.ENSIGN_TICK)
	if int(Sim.ENSIGN_CAP) != 1:
		_fail(errors, "ensign cap is %s, expected 1" % Sim.ENSIGN_CAP)
	if int(Sim.GRID_NORTH) > -14:
		_fail(errors, "the map was not extended to the ensign row (north %s)" % Sim.GRID_NORTH)
	if int(Sim.ENSIGN_CELL.x) != 14 or int(Sim.ENSIGN_CELL.y) != -14:
		_fail(errors, "the ensign cell is not at 14,-14")
	if int(Sim.JACK_CELL.x) != 14 or int(Sim.JACK_CELL.y) != -13:
		_fail(errors, "the jack moved off 14,-13")
	if int(Sim.STANDARD_CELL.x) != 14 or int(Sim.STANDARD_CELL.y) != -12:
		_fail(errors, "the standard moved off 14,-12")
	if int(Sim.PENNANT_CELL.x) != 14 or int(Sim.PENNANT_CELL.y) != -11:
		_fail(errors, "the pennant moved off 14,-11")
	var fresh = Sim.new()
	if fresh.paint_cell(14, -14, Sim.ENSIGN) == false or int(fresh.get_paint(14, -14)) != Sim.ENSIGN:
		_fail(errors, "the cell north of the jack rejected the ensign mark")
	if fresh.paint_cell(14, -13, Sim.ENSIGN):
		_fail(errors, "the jack cell accepted an ensign")
	if int(fresh.get_paint(14, -13)) != Sim.EMPTY:
		_fail(errors, "a rejected ensign painted the jack cell")
	if fresh.paint_cell(14, -14, Sim.JACK):
		_fail(errors, "the ensign cell accepted a jack")
	if int(fresh.get_paint(14, -14)) != Sim.ENSIGN:
		_fail(errors, "a rejected jack erased the ensign")
	if fresh.paint_cell(14, -13, Sim.JACK) == false or int(fresh.get_paint(14, -13)) != Sim.JACK:
		_fail(errors, "the jack cell no longer accepts a jack")
	if fresh.paint_cell(14, -12, Sim.STANDARD) == false or int(fresh.get_paint(14, -12)) != Sim.STANDARD:
		_fail(errors, "the standard cell no longer accepts a standard")
	if fresh.paint_cell(14, -11, Sim.PENNANT) == false or int(fresh.get_paint(14, -11)) != Sim.PENNANT:
		_fail(errors, "the pennant cell no longer accepts a pennant")
	if fresh.paint_cell(14, -10, Sim.BANNER) == false or int(fresh.get_paint(14, -10)) != Sim.BANNER:
		_fail(errors, "the banner cell no longer accepts a banner")
	if fresh.paint_cell(14, -9, Sim.FLAG) == false or int(fresh.get_paint(14, -9)) != Sim.FLAG:
		_fail(errors, "the flag cell no longer accepts a flag")
	if fresh.paint_cell(14, -15, Sim.ENSIGN) or fresh.paint_cell(13, -14, Sim.ENSIGN) or fresh.paint_cell(15, -14, Sim.ENSIGN) or fresh.paint_cell(14, -12, Sim.ENSIGN):
		_fail(errors, "a cell other than 14,-14 accepted an ensign")
	if fresh.paint_cell(Sim.COAST_X, -14, Sim.ENSIGN):
		_fail(errors, "the brine accepted an ensign")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.ENSIGN):
		_fail(errors, "the anthill accepted an ensign")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var won = _run_plan(plans, "winning", errors)
	var dry = _run_plan(plans, "dry_pans", errors)
	var shown = _run_plan(plans, "shown", errors)
	var no_ensign = _run_plan(plans, "no_ensign", errors)
	var bare = _run_plan(plans, "ensign_only", errors)
	var carried = _run_plan(plans, "no_jack", errors)
	var broken = _run_plan(plans, "broken", errors)
	var broken_again = _run_plan(plans, "broken", errors)
	var late = _run_plan(plans, "late_broken", errors)
	var dry_broken = _run_plan(plans, "dry_broken", errors)
	if won == null or dry == null or shown == null or no_ensign == null or bare == null or carried == null or broken == null or broken_again == null or late == null or dry_broken == null:
		return
	if int(won.get_broken()) != 0 or int(dry.get_broken()) != 0 or int(shown.get_broken()) != 0:
		_fail(errors, "a plan with no ensign broke someone (winning %d dry %d shown %d)" % [won.get_broken(), dry.get_broken(), shown.get_broken()])
	if String(shown.get_summary()) != String(no_ensign.get_summary()):
		_fail(errors, "a jack with no ensign changed the shown summary: %s" % no_ensign.get_summary())
	if String(no_ensign.get_summary()).to_lower().contains("broke") or String(no_ensign.get_summary()).to_lower().contains("ensign"):
		_fail(errors, "a jack with no ensign names an ensign: %s" % no_ensign.get_summary())
	if int(no_ensign.get_broken()) != 0 or int(no_ensign.get_jack_left()) != 1 or int(no_ensign.get_shown()) != 1 or int(no_ensign.get_standard_left()) != 0 or int(no_ensign.get_carried()) != 1 or int(no_ensign.get_yard_left()) != 57 or int(no_ensign.get_coins()) != 2997 or int(no_ensign.get_hired()) != 29 or int(no_ensign.get_stored_salt()) != 2997:
		_fail(errors, "a jack with no ensign broke someone (broken %d jack %d shown %d coins %d hired %d yard %d)" % [no_ensign.get_broken(), no_ensign.get_jack_left(), no_ensign.get_shown(), no_ensign.get_coins(), no_ensign.get_hired(), no_ensign.get_yard_left()])
	var kept_jack = plans["no_ensign"]["jack"][0]
	var kept_salt: Dictionary = no_ensign.get_cell_salt(int(kept_jack[0]), int(kept_jack[1]))
	var kept_north: Dictionary = no_ensign.get_cell_salt(int(kept_jack[0]), int(kept_jack[1]) - 1)
	if int(kept_salt.get("jack", 0)) != 1 or int(kept_north.get("ensign", 0)) != 0 or int(kept_salt.get("ensign", 0)) != 0:
		_fail(errors, "a jack with no ensign left %s on the jack and %s on an ensign" % [kept_salt.get("jack", 0), kept_north.get("ensign", 0)])
	if String(bare.get_summary()) != String(carried.get_summary()):
		_fail(errors, "an ensign with no jack changed the carried summary: %s" % bare.get_summary())
	if String(bare.get_summary()).to_lower().contains("broke") or String(bare.get_summary()).to_lower().contains("ensign") or String(bare.get_summary()).to_lower().contains("showed") or String(bare.get_summary()).to_lower().contains("jack"):
		_fail(errors, "an ensign with no jack names an ensign: %s" % bare.get_summary())
	if int(bare.get_broken()) != 0 or int(bare.get_shown()) != 0 or int(bare.get_jack_left()) != 0 or int(bare.get_carried()) != 1 or int(bare.get_standard_left()) != 1 or int(bare.get_flown()) != 1 or int(bare.get_pennant_left()) != 0 or int(bare.get_yard_left()) != 57 or int(bare.get_coins()) != 2997 or int(bare.get_hired()) != 29:
		_fail(errors, "an ensign with no jack broke someone (broken %d shown %d standard %d carried %d)" % [bare.get_broken(), bare.get_shown(), bare.get_standard_left(), bare.get_carried()])
	var bare_ensign = plans["ensign_only"]["ensign"][0]
	var bare_standard = plans["ensign_only"]["standard"][0]
	var bare_ensign_salt: Dictionary = bare.get_cell_salt(int(bare_ensign[0]), int(bare_ensign[1]))
	var bare_standard_salt: Dictionary = bare.get_cell_salt(int(bare_standard[0]), int(bare_standard[1]))
	if int(bare_ensign_salt.get("ensign", 0)) != 0 or int(bare_standard_salt.get("standard", 0)) != 1 or int(bare_ensign_salt.get("jack", 0)) != 0:
		_fail(errors, "ensign without a jack holds %s, standard holds %s" % [bare_ensign_salt.get("ensign", 0), bare_standard_salt.get("standard", 0)])
	var ensign_cell = plans["broken"]["ensign"][0]
	var jack_cell = plans["broken"]["jack"][0]
	var standard_cell = plans["broken"]["standard"][0]
	var pennant_cell = plans["broken"]["pennant"][0]
	var banner_cell = plans["broken"]["banner"][0]
	var flag_cell = plans["broken"]["flag"][0]
	if int(ensign_cell[0]) != int(jack_cell[0]) or int(ensign_cell[1]) != int(jack_cell[1]) - 1:
		_fail(errors, "broken plan's ensign is not one cell north of the jack")
	if int(ensign_cell[0]) != 14 or int(ensign_cell[1]) != -14 or int(jack_cell[0]) != 14 or int(jack_cell[1]) != -13 or int(standard_cell[0]) != 14 or int(standard_cell[1]) != -12 or int(pennant_cell[0]) != 14 or int(pennant_cell[1]) != -11 or int(banner_cell[0]) != 14 or int(banner_cell[1]) != -10 or int(flag_cell[0]) != 14 or int(flag_cell[1]) != -9:
		_fail(errors, "broken plan moved the ensign, the jack, the standard, the pennant, the banner, or the flag")
	_assert_chain(broken, errors, "broken plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1)
	var broken_unpaid := int(broken.get_hired()) - int(broken.get_paid())
	var broken_unposted := int(broken.get_paid()) - int(broken.get_posted())
	var broken_unstood := int(broken.get_posted()) - int(broken.get_stood())
	var broken_unlit := int(broken.get_stood()) - int(broken.get_lit())
	var broken_unrung := int(broken.get_lit()) - int(broken.get_rung())
	var broken_unraised := int(broken.get_sounded()) - int(broken.get_raised())
	var broken_unhoisted := int(broken.get_raised()) - int(broken.get_hoisted())
	var broken_unflown := int(broken.get_hoisted()) - int(broken.get_flown())
	var broken_uncarried := int(broken.get_flown()) - int(broken.get_carried())
	var broken_unshown := int(broken.get_carried()) - int(broken.get_shown())
	var broken_unbroken := int(broken.get_shown()) - int(broken.get_broken())
	if int(broken.get_broken()) != 1 or int(broken.get_jack_left()) != 0 or broken_unbroken != 0 or int(broken.get_shown()) != 1 or int(broken.get_standard_left()) != 0 or broken_unshown != 0 or int(broken.get_carried()) != 1 or broken_uncarried != 0 or int(broken.get_pennant_left()) != 0 or broken_unflown != 0 or broken_unhoisted != 0 or broken_unraised != 0 or int(broken.get_horn_left()) != 0 or int(broken.get_bell_left()) != 1 or broken_unrung != 1 or broken_unlit != 1 or broken_unstood != 2 or broken_unposted != 4 or broken_unpaid != 19 or int(broken.get_lamp_left()) != 1 or int(broken.get_watch_left()) != 1 or int(broken.get_relief_left()) != 2 or int(broken.get_wage_left()) != 4 or int(broken.get_loft_left()) != 19 or int(broken.get_gate_left()) != 0 or int(broken.get_yard_left()) != 57 or int(broken.get_flown()) != 1 or int(broken.get_hoisted()) != 1 or int(broken.get_raised()) != 1 or int(broken.get_sounded()) != 1 or int(broken.get_rung()) != 2 or int(broken.get_lit()) != 3 or int(broken.get_stood()) != 4 or int(broken.get_posted()) != 6 or int(broken.get_coins()) != 2997 or int(broken.get_hired()) != 29 or int(broken.get_stored_salt()) != 2997:
		_fail(errors, "broken %d, left %d shown unbroken, carried unshown %d, flown uncarried %d, hoisted unflown %d, raised unhoisted %d, sounded unraised %d, rung unsounded %d, lit unrung %d, stood unlit %d, posted unstood %d, paid unposted %d, unpaid %d, jack %d, yard %d, shown %d, carried %d, flown %d, hoisted %d, raised %d, sounded %d, rung %d, lit %d, stood %d, posted %d, coins %d, hired %d" % [broken.get_broken(), broken.get_jack_left(), broken_unshown, broken_uncarried, broken_unflown, broken_unhoisted, broken_unraised, broken.get_bell_left(), broken_unrung, broken_unlit, broken_unstood, broken_unposted, broken_unpaid, broken.get_jack_left(), broken.get_yard_left(), broken.get_shown(), broken.get_carried(), broken.get_flown(), broken.get_hoisted(), broken.get_raised(), broken.get_sounded(), broken.get_rung(), broken.get_lit(), broken.get_stood(), broken.get_posted(), broken.get_coins(), broken.get_hired()])
	if int(broken.get_broken()) > int(Sim.ENSIGN_CAP):
		_fail(errors, "ensign broke %d, over the cap of %d" % [broken.get_broken(), Sim.ENSIGN_CAP])
	var ensign_salt: Dictionary = broken.get_cell_salt(int(ensign_cell[0]), int(ensign_cell[1]))
	var jack_salt: Dictionary = broken.get_cell_salt(int(jack_cell[0]), int(jack_cell[1]))
	var standard_salt: Dictionary = broken.get_cell_salt(int(standard_cell[0]), int(standard_cell[1]))
	if int(ensign_salt.get("ensign", 0)) != 1 or int(jack_salt.get("jack", 0)) != 0 or int(standard_salt.get("standard", 0)) != 0 or int(ensign_salt.get("jack", 0)) != 0:
		_fail(errors, "ensign cell holds %s, jack holds %s, standard holds %s" % [ensign_salt.get("ensign", 0), jack_salt.get("jack", 0), standard_salt.get("standard", 0)])
	var broken_summary := String(broken.get_summary())
	if not broken_summary.contains("Broke 1 on the ensign") or not broken_summary.contains("Left 0 at the jack") or not broken_summary.contains("Showed 1 on the jack") or not broken_summary.contains("Left 0 at the standard") or not broken_summary.contains("Coins 2997") or not broken_summary.contains("Hired 29") or not broken_summary.contains("Left 57"):
		_fail(errors, "broken summary does not name the ensign: %s" % broken_summary)
	if int(broken_again.get_broken()) != int(broken.get_broken()) or int(broken_again.get_jack_left()) != int(broken.get_jack_left()) or int(broken_again.get_shown()) != int(broken.get_shown()) or int(broken_again.get_yard_left()) != int(broken.get_yard_left()) or int(broken_again.get_stored_salt()) != int(broken.get_stored_salt()) or String(broken_again.get_summary()) != String(broken.get_summary()):
		_fail(errors, "repeated ensign paint broke %d and left jack %d, then broke %d and left jack %d" % [broken.get_broken(), broken.get_jack_left(), broken_again.get_broken(), broken_again.get_jack_left()])
	if int(late.get_broken()) != 1 or int(late.get_jack_left()) != 0 or int(late.get_shown()) != 1 or int(late.get_carried()) != 1 or int(late.get_flown()) != 1 or int(late.get_hoisted()) != 1 or int(late.get_raised()) != 1 or int(late.get_sounded()) != 1 or int(late.get_rung()) != 2 or int(late.get_lit()) != 3 or int(late.get_stood()) != 4 or int(late.get_posted()) != 6 or int(late.get_yard_left()) != 57 or int(late.get_hired()) != 29 or int(late.get_coins()) != 2997 or int(late.get_stored_salt()) != 2997 or int(late.get_loft_left()) != 19 or int(late.get_wage_left()) != 4:
		_fail(errors, "painting the ensign at the ensign beat (broken %d jack %d shown %d yard %d) did not match painting it early (broken %d jack %d shown %d)" % [late.get_broken(), late.get_jack_left(), late.get_shown(), late.get_yard_left(), broken.get_broken(), broken.get_jack_left(), broken.get_shown()])
	_assert_chain(dry_broken, errors, "dry ensign", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1)
	var dry_unpaid := int(dry_broken.get_hired()) - int(dry_broken.get_paid())
	var dry_unposted := int(dry_broken.get_paid()) - int(dry_broken.get_posted())
	var dry_unstood := int(dry_broken.get_posted()) - int(dry_broken.get_stood())
	var dry_unlit := int(dry_broken.get_stood()) - int(dry_broken.get_lit())
	var dry_unrung := int(dry_broken.get_lit()) - int(dry_broken.get_rung())
	var dry_unraised := int(dry_broken.get_sounded()) - int(dry_broken.get_raised())
	var dry_unhoisted := int(dry_broken.get_raised()) - int(dry_broken.get_hoisted())
	var dry_unflown := int(dry_broken.get_hoisted()) - int(dry_broken.get_flown())
	var dry_uncarried := int(dry_broken.get_flown()) - int(dry_broken.get_carried())
	var dry_unshown := int(dry_broken.get_carried()) - int(dry_broken.get_shown())
	var dry_unbroken := int(dry_broken.get_shown()) - int(dry_broken.get_broken())
	if int(dry_broken.get_broken()) != 1 or int(dry_broken.get_jack_left()) != 0 or dry_unbroken != 0 or int(dry_broken.get_shown()) != 1 or int(dry_broken.get_standard_left()) != 0 or dry_unshown != 0 or int(dry_broken.get_carried()) != 1 or dry_uncarried != 0 or int(dry_broken.get_pennant_left()) != 0 or dry_unflown != 0 or dry_unhoisted != 0 or dry_unraised != 0 or int(dry_broken.get_horn_left()) != 0 or int(dry_broken.get_bell_left()) != 1 or dry_unrung != 1 or dry_unlit != 1 or dry_unstood != 2 or dry_unposted != 2 or dry_unpaid != 2 or int(dry_broken.get_yard_left()) != 0 or int(dry_broken.get_flown()) != 1 or int(dry_broken.get_hoisted()) != 1 or int(dry_broken.get_raised()) != 1 or int(dry_broken.get_sounded()) != 1 or int(dry_broken.get_rung()) != 2 or int(dry_broken.get_lit()) != 3 or int(dry_broken.get_stood()) != 4 or int(dry_broken.get_posted()) != 6 or int(dry_broken.get_wet_haul()) != 0 or int(dry_broken.get_stored_salt()) != 1032 or int(dry_broken.get_gate_left()) != 2 or int(dry_broken.get_wage_left()) != 2 or int(dry_broken.get_loft_left()) != 0:
		_fail(errors, "dry ensign changed the short crew (wet %d stored %d broken %d jack %d shown %d standard %d carried %d pennant %d flown %d unbroken %d unshown %d uncarried %d unflown %d unhoisted %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d yard %d)" % [dry_broken.get_wet_haul(), dry_broken.get_stored_salt(), dry_broken.get_broken(), dry_broken.get_jack_left(), dry_broken.get_shown(), dry_broken.get_standard_left(), dry_broken.get_carried(), dry_broken.get_pennant_left(), dry_broken.get_flown(), dry_unbroken, dry_unshown, dry_uncarried, dry_unflown, dry_unhoisted, dry_unraised, dry_broken.get_bell_left(), dry_unrung, dry_unlit, dry_unstood, dry_unposted, dry_unpaid, dry_broken.get_yard_left()])
	var dry_ensign_cell = plans["dry_broken"]["ensign"][0]
	var dry_jack_cell = plans["dry_broken"]["jack"][0]
	var dry_ensign_salt: Dictionary = dry_broken.get_cell_salt(int(dry_ensign_cell[0]), int(dry_ensign_cell[1]))
	var dry_jack_salt: Dictionary = dry_broken.get_cell_salt(int(dry_jack_cell[0]), int(dry_jack_cell[1]))
	if int(dry_ensign_salt.get("ensign", 0)) != 1 or int(dry_jack_salt.get("jack", 0)) != 0:
		_fail(errors, "dry ensign cell holds %s, jack holds %s" % [dry_ensign_salt.get("ensign", 0), dry_jack_salt.get("jack", 0)])
	if not String(dry_broken.get_summary()).contains("Broke 1 on the ensign") or not String(dry_broken.get_summary()).contains("Left 0 at the jack") or not String(dry_broken.get_summary()).contains("Showed 1 on the jack") or not String(dry_broken.get_summary()).contains("Left 0 in the yard"):
		_fail(errors, "dry ensign summary does not name the cap: %s" % dry_broken.get_summary())
	_assert_pop(broken, errors, "broken plan")
	_assert_pop(broken_again, errors, "broken plan again")
	_assert_pop(late, errors, "late_broken")
	_assert_pop(dry_broken, errors, "dry_broken")
	_assert_pop(no_ensign, errors, "no_ensign")
	_assert_pop(bare, errors, "ensign_only")
	var shore = _prepare_plan(plans, "broken", errors)
	if shore == null:
		return
	var shore_guard := 0
	var shore_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + int(Sim.STANDARD_TICK) + int(Sim.JACK_TICK) + 2
	while int(shore.get_beat()) != Sim.ENSIGNING and not shore.is_over() and shore_guard < shore_limit:
		shore.tick()
		shore_guard += 1
	if int(shore.get_beat()) != Sim.ENSIGNING or shore.is_over():
		_fail(errors, "the jack beat did not open an ensign beat for the cap check")
		return
	if int(shore.get_ticks_until_rain()) != int(Sim.ENSIGN_TICK):
		_fail(errors, "ensign countdown started at %d, expected %d" % [shore.get_ticks_until_rain(), Sim.ENSIGN_TICK])
	if int(shore.get_broken()) != 0 or int(shore.get_shown()) != 1 or int(shore.get_jack_left()) != 1 or int(shore.get_carried()) != 1 or int(shore.get_standard_left()) != 0 or int(shore.get_yard_left()) != 57 or int(shore.get_coins()) != 2997 or int(shore.get_stored_salt()) != 2997:
		_fail(errors, "ensign opened early (broken %d shown %d jack %d carried %d yard %d coins %d stored %d)" % [shore.get_broken(), shore.get_shown(), shore.get_jack_left(), shore.get_carried(), shore.get_yard_left(), shore.get_coins(), shore.get_stored_salt()])
	var saw_cap := false
	var break_guard := 0
	while not shore.is_over() and break_guard < int(Sim.ENSIGN_TICK) + 2:
		shore.tick()
		break_guard += 1
		if int(shore.get_broken()) == int(Sim.ENSIGN_CAP) and int(shore.get_jack_left()) == 0 and int(shore.get_shown()) == 1 and int(shore.get_carried()) == 1 and int(shore.get_flown()) == 1 and int(shore.get_hoisted()) == 1 and int(shore.get_yard_left()) == 57 and int(shore.get_coins()) == 2997 and int(shore.get_hired()) == 29 and int(shore.get_ticks_until_rain()) > 0:
			saw_cap = true
			var ticks_left := int(shore.get_ticks_until_rain())
			shore.tick()
			if int(shore.get_broken()) != int(Sim.ENSIGN_CAP) or int(shore.get_jack_left()) != 0 or int(shore.get_shown()) != 1 or int(shore.get_carried()) != 1 or int(shore.get_flown()) != 1 or int(shore.get_hoisted()) != 1 or int(shore.get_raised()) != 1 or int(shore.get_yard_left()) != 57 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29 or int(shore.get_stored_salt()) != 2997 or int(shore.get_posted()) != 6 or int(shore.get_stood()) != 4 or int(shore.get_lit()) != 3 or int(shore.get_rung()) != 2 or int(shore.get_sounded()) != 1:
				_fail(errors, "the ensign kept breaking after the cap (broken %d jack %d shown %d carried %d yard %d)" % [shore.get_broken(), shore.get_jack_left(), shore.get_shown(), shore.get_carried(), shore.get_yard_left()])
			elif not shore.is_over() and int(shore.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the ensign beat did not spend a tick after the cap")
			break
	if not saw_cap:
		_fail(errors, "the ensign did not stop at %d while ticks remained (broken %d jack %d shown %d ticks %d)" % [Sim.ENSIGN_CAP, shore.get_broken(), shore.get_jack_left(), shore.get_shown(), shore.get_ticks_until_rain()])
	var end_guard := 0
	while int(shore.get_beat()) == Sim.ENSIGNING and not shore.is_over() and end_guard < int(Sim.ENSIGN_TICK) + 2:
		shore.tick()
		end_guard += 1
		if int(shore.get_broken()) != 1 or int(shore.get_jack_left()) != 0 or int(shore.get_shown()) != 1:
			_fail(errors, "the ensign broke again after the cap (broken %d jack %d shown %d)" % [shore.get_broken(), shore.get_jack_left(), shore.get_shown()])
			break
	if shore.is_over() or int(shore.get_beat()) != Sim.BURGEEING:
		_fail(errors, "the ensign beat ended the scenario instead of opening the burgee")
	elif int(shore.get_broken()) != 1 or int(shore.get_struck()) != 0 or int(shore.get_ensign_left()) != 1:
		_fail(errors, "the ensign beat changed its break count when the burgee opened (broken %d struck %d ensign %d)" % [shore.get_broken(), shore.get_struck(), shore.get_ensign_left()])
	var short = _prepare_plan(plans, "dry_broken", errors)
	if short == null:
		return
	var short_guard := 0
	while int(short.get_beat()) != Sim.ENSIGNING and not short.is_over() and short_guard < shore_limit:
		short.tick()
		short_guard += 1
	if int(short.get_beat()) != Sim.ENSIGNING or short.is_over():
		_fail(errors, "the jack beat did not open an ensign beat for the dry cap")
		return
	var saw_short := false
	var short_steps := 0
	while not short.is_over() and short_steps < int(Sim.ENSIGN_TICK) + 2:
		short.tick()
		short_steps += 1
		if int(short.get_broken()) == int(Sim.ENSIGN_CAP) and int(short.get_jack_left()) == 0 and int(short.get_shown()) == 1 and int(short.get_carried()) == 1 and int(short.get_flown()) == 1 and int(short.get_yard_left()) == 0 and int(short.get_wet_haul()) == 0 and int(short.get_ticks_until_rain()) > 0:
			saw_short = true
			var short_ticks := int(short.get_ticks_until_rain())
			short.tick()
			if int(short.get_broken()) != 1 or int(short.get_jack_left()) != 0 or int(short.get_shown()) != 1 or int(short.get_carried()) != 1 or int(short.get_flown()) != 1 or int(short.get_yard_left()) != 0 or int(short.get_posted()) != 6 or int(short.get_stored_salt()) != 1032:
				_fail(errors, "the ensign broke an unshown hire or passed the cap (broken %d jack %d shown %d yard %d)" % [short.get_broken(), short.get_jack_left(), short.get_shown(), short.get_yard_left()])
			elif not short.is_over() and int(short.get_ticks_until_rain()) >= short_ticks:
				_fail(errors, "the ensign beat did not spend a tick after the dry cap")
			break
	if not saw_short:
		_fail(errors, "dry ensign did not stop at 1 with the jack clear (broken %d jack %d shown %d yard %d ticks %d)" % [short.get_broken(), short.get_jack_left(), short.get_shown(), short.get_yard_left(), short.get_ticks_until_rain()])
	print("broken %d left jack %d unshown %d uncarried %d unflown %d unhoisted %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d; dry broken %d left jack %d unshown %d uncarried %d unflown %d unhoisted %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d; no ensign broken %d left jack %d; ensign without jack broken %d" % [broken.get_broken(), broken.get_jack_left(), broken_unshown, broken_uncarried, broken_unflown, broken_unhoisted, broken_unraised, broken.get_bell_left(), broken_unrung, broken_unlit, broken_unstood, broken_unposted, broken_unpaid, dry_broken.get_broken(), dry_broken.get_jack_left(), dry_unshown, dry_uncarried, dry_unflown, dry_unhoisted, dry_unraised, dry_broken.get_bell_left(), dry_unrung, dry_unlit, dry_unstood, dry_unposted, dry_unpaid, no_ensign.get_broken(), no_ensign.get_jack_left(), bare.get_broken()])


func _test_burgee(errors: Array) -> void:
	if int(Sim.BURGEE_TICK) != 100 or int(Sim.BURGEE_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "burgee beat length %s is not 100 ticks (10 seconds)" % Sim.BURGEE_TICK)
	if int(Sim.BURGEE_CAP) != 1:
		_fail(errors, "burgee cap is %s, expected 1" % Sim.BURGEE_CAP)
	if int(Sim.ENSIGN_CAP) != 1:
		_fail(errors, "ensign cap changed to %s" % Sim.ENSIGN_CAP)
	if int(Sim.GRID_NORTH) > -15:
		_fail(errors, "the map was not extended to the burgee row (north %s)" % Sim.GRID_NORTH)
	if int(Sim.BURGEE_CELL.x) != 14 or int(Sim.BURGEE_CELL.y) != -15:
		_fail(errors, "the burgee cell is not at 14,-15")
	if int(Sim.ENSIGN_CELL.x) != 14 or int(Sim.ENSIGN_CELL.y) != -14:
		_fail(errors, "the ensign moved off 14,-14")
	if int(Sim.JACK_CELL.x) != 14 or int(Sim.JACK_CELL.y) != -13:
		_fail(errors, "the jack moved off 14,-13")
	if int(Sim.STANDARD_CELL.x) != 14 or int(Sim.STANDARD_CELL.y) != -12:
		_fail(errors, "the standard moved off 14,-12")
	if int(Sim.PENNANT_CELL.x) != 14 or int(Sim.PENNANT_CELL.y) != -11:
		_fail(errors, "the pennant moved off 14,-11")
	var fresh = Sim.new()
	if fresh.paint_cell(14, -15, Sim.BURGEE) == false or int(fresh.get_paint(14, -15)) != Sim.BURGEE:
		_fail(errors, "the cell north of the ensign rejected the burgee mark")
	if fresh.paint_cell(14, -14, Sim.BURGEE):
		_fail(errors, "the ensign cell accepted a burgee")
	if int(fresh.get_paint(14, -14)) != Sim.EMPTY:
		_fail(errors, "a rejected burgee painted the ensign cell")
	if fresh.paint_cell(14, -15, Sim.ENSIGN):
		_fail(errors, "the burgee cell accepted an ensign")
	if int(fresh.get_paint(14, -15)) != Sim.BURGEE:
		_fail(errors, "a rejected ensign erased the burgee")
	if fresh.paint_cell(14, -14, Sim.ENSIGN) == false or int(fresh.get_paint(14, -14)) != Sim.ENSIGN:
		_fail(errors, "the ensign cell no longer accepts an ensign")
	if fresh.paint_cell(14, -13, Sim.JACK) == false or int(fresh.get_paint(14, -13)) != Sim.JACK:
		_fail(errors, "the jack cell no longer accepts a jack")
	if fresh.paint_cell(14, -12, Sim.STANDARD) == false or int(fresh.get_paint(14, -12)) != Sim.STANDARD:
		_fail(errors, "the standard cell no longer accepts a standard")
	if fresh.paint_cell(14, -11, Sim.PENNANT) == false or int(fresh.get_paint(14, -11)) != Sim.PENNANT:
		_fail(errors, "the pennant cell no longer accepts a pennant")
	if fresh.paint_cell(14, -10, Sim.BANNER) == false or int(fresh.get_paint(14, -10)) != Sim.BANNER:
		_fail(errors, "the banner cell no longer accepts a banner")
	if fresh.paint_cell(14, -9, Sim.FLAG) == false or int(fresh.get_paint(14, -9)) != Sim.FLAG:
		_fail(errors, "the flag cell no longer accepts a flag")
	if fresh.paint_cell(14, -16, Sim.BURGEE) or fresh.paint_cell(13, -15, Sim.BURGEE) or fresh.paint_cell(15, -15, Sim.BURGEE) or fresh.paint_cell(14, -14, Sim.BURGEE) or fresh.paint_cell(14, -13, Sim.BURGEE):
		_fail(errors, "a cell other than 14,-15 accepted a burgee")
	if int(fresh.get_paint(14, -14)) != Sim.ENSIGN:
		_fail(errors, "a rejected burgee erased the ensign")
	if fresh.paint_cell(Sim.COAST_X, -15, Sim.BURGEE):
		_fail(errors, "the brine accepted a burgee")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.BURGEE):
		_fail(errors, "the anthill accepted a burgee")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var won = _run_plan(plans, "winning", errors)
	var dry = _run_plan(plans, "dry_pans", errors)
	var broken = _run_plan(plans, "broken", errors)
	var no_burgee = _run_plan(plans, "no_burgee", errors)
	var bare = _run_plan(plans, "burgee_only", errors)
	var shown = _run_plan(plans, "no_ensign", errors)
	var struck = _run_plan(plans, "struck", errors)
	var struck_again = _run_plan(plans, "struck", errors)
	var late = _run_plan(plans, "late_struck", errors)
	var dry_struck = _run_plan(plans, "dry_struck", errors)
	if won == null or dry == null or broken == null or no_burgee == null or bare == null or shown == null or struck == null or struck_again == null or late == null or dry_struck == null:
		return
	if int(won.get_struck()) != 0 or int(dry.get_struck()) != 0 or int(broken.get_struck()) != 0:
		_fail(errors, "a plan with no burgee struck someone (winning %d dry %d broken %d)" % [won.get_struck(), dry.get_struck(), broken.get_struck()])
	if String(broken.get_summary()) != String(no_burgee.get_summary()):
		_fail(errors, "an ensign with no burgee changed the broken summary: %s" % no_burgee.get_summary())
	if String(no_burgee.get_summary()).to_lower().contains("struck") or String(no_burgee.get_summary()).to_lower().contains("burgee"):
		_fail(errors, "an ensign with no burgee names a burgee: %s" % no_burgee.get_summary())
	var no_unpaid := int(no_burgee.get_hired()) - int(no_burgee.get_paid())
	var no_unposted := int(no_burgee.get_paid()) - int(no_burgee.get_posted())
	var no_unstood := int(no_burgee.get_posted()) - int(no_burgee.get_stood())
	var no_unlit := int(no_burgee.get_stood()) - int(no_burgee.get_lit())
	var no_unrung := int(no_burgee.get_lit()) - int(no_burgee.get_rung())
	if int(no_burgee.get_struck()) != 0 or int(no_burgee.get_ensign_left()) != 1 or int(no_burgee.get_broken()) != 1 or int(no_burgee.get_jack_left()) != 0 or int(no_burgee.get_shown()) != 1 or int(no_burgee.get_standard_left()) != 0 or int(no_burgee.get_carried()) != 1 or int(no_burgee.get_pennant_left()) != 0 or int(no_burgee.get_flown()) != 1 or int(no_burgee.get_banner_left()) != 0 or int(no_burgee.get_hoisted()) != 1 or int(no_burgee.get_flag_left()) != 0 or int(no_burgee.get_raised()) != 1 or int(no_burgee.get_horn_left()) != 0 or int(no_burgee.get_sounded()) != 1 or int(no_burgee.get_bell_left()) != 1 or no_unrung != 1 or no_unlit != 1 or no_unstood != 2 or no_unposted != 4 or no_unpaid != 19 or int(no_burgee.get_yard_left()) != 57 or int(no_burgee.get_coins()) != 2997 or int(no_burgee.get_hired()) != 29 or int(no_burgee.get_stored_salt()) != 2997:
		_fail(errors, "an ensign with no burgee struck someone (struck %d ensign %d broken %d jack %d shown %d unpaid %d)" % [no_burgee.get_struck(), no_burgee.get_ensign_left(), no_burgee.get_broken(), no_burgee.get_jack_left(), no_burgee.get_shown(), no_unpaid])
	var kept_ensign = plans["no_burgee"]["ensign"][0]
	var kept_salt: Dictionary = no_burgee.get_cell_salt(int(kept_ensign[0]), int(kept_ensign[1]))
	var kept_north: Dictionary = no_burgee.get_cell_salt(int(kept_ensign[0]), int(kept_ensign[1]) - 1)
	if int(kept_salt.get("ensign", 0)) != 1 or int(kept_north.get("burgee", 0)) != 0 or int(kept_salt.get("burgee", 0)) != 0:
		_fail(errors, "an ensign with no burgee left %s on the ensign and %s on a burgee" % [kept_salt.get("ensign", 0), kept_north.get("burgee", 0)])
	if String(bare.get_summary()) != String(shown.get_summary()):
		_fail(errors, "a burgee with no ensign changed the shown summary: %s" % bare.get_summary())
	if String(bare.get_summary()).to_lower().contains("struck") or String(bare.get_summary()).to_lower().contains("burgee") or String(bare.get_summary()).to_lower().contains("broke") or String(bare.get_summary()).to_lower().contains("ensign"):
		_fail(errors, "a burgee with no ensign names a burgee: %s" % bare.get_summary())
	if int(bare.get_struck()) != 0 or int(bare.get_broken()) != 0 or int(bare.get_ensign_left()) != 0 or int(bare.get_shown()) != 1 or int(bare.get_jack_left()) != 1 or int(bare.get_carried()) != 1 or int(bare.get_standard_left()) != 0 or int(bare.get_yard_left()) != 57 or int(bare.get_coins()) != 2997 or int(bare.get_hired()) != 29:
		_fail(errors, "a burgee with no ensign struck someone (struck %d broken %d shown %d jack %d)" % [bare.get_struck(), bare.get_broken(), bare.get_shown(), bare.get_jack_left()])
	var bare_burgee = plans["burgee_only"]["burgee"][0]
	var bare_jack = plans["burgee_only"]["jack"][0]
	var bare_burgee_salt: Dictionary = bare.get_cell_salt(int(bare_burgee[0]), int(bare_burgee[1]))
	var bare_jack_salt: Dictionary = bare.get_cell_salt(int(bare_jack[0]), int(bare_jack[1]))
	if int(bare_burgee_salt.get("burgee", 0)) != 0 or int(bare_jack_salt.get("jack", 0)) != 1 or int(bare_burgee_salt.get("ensign", 0)) != 0:
		_fail(errors, "burgee without an ensign holds %s, jack holds %s" % [bare_burgee_salt.get("burgee", 0), bare_jack_salt.get("jack", 0)])
	var burgee_cell = plans["struck"]["burgee"][0]
	var ensign_cell = plans["struck"]["ensign"][0]
	var jack_cell = plans["struck"]["jack"][0]
	var standard_cell = plans["struck"]["standard"][0]
	var pennant_cell = plans["struck"]["pennant"][0]
	var banner_cell = plans["struck"]["banner"][0]
	var flag_cell = plans["struck"]["flag"][0]
	if int(burgee_cell[0]) != int(ensign_cell[0]) or int(burgee_cell[1]) != int(ensign_cell[1]) - 1:
		_fail(errors, "struck plan's burgee is not one cell north of the ensign")
	if int(burgee_cell[0]) != 14 or int(burgee_cell[1]) != -15 or int(ensign_cell[0]) != 14 or int(ensign_cell[1]) != -14 or int(jack_cell[0]) != 14 or int(jack_cell[1]) != -13 or int(standard_cell[0]) != 14 or int(standard_cell[1]) != -12 or int(pennant_cell[0]) != 14 or int(pennant_cell[1]) != -11 or int(banner_cell[0]) != 14 or int(banner_cell[1]) != -10 or int(flag_cell[0]) != 14 or int(flag_cell[1]) != -9:
		_fail(errors, "struck plan moved the burgee, the ensign, the jack, the standard, the pennant, the banner, or the flag")
	_assert_chain(struck, errors, "struck plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1)
	var struck_unpaid := int(struck.get_hired()) - int(struck.get_paid())
	var struck_unposted := int(struck.get_paid()) - int(struck.get_posted())
	var struck_unstood := int(struck.get_posted()) - int(struck.get_stood())
	var struck_unlit := int(struck.get_stood()) - int(struck.get_lit())
	var struck_unrung := int(struck.get_lit()) - int(struck.get_rung())
	var struck_unraised := int(struck.get_sounded()) - int(struck.get_raised())
	var struck_unhoisted := int(struck.get_raised()) - int(struck.get_hoisted())
	var struck_unflown := int(struck.get_hoisted()) - int(struck.get_flown())
	var struck_uncarried := int(struck.get_flown()) - int(struck.get_carried())
	var struck_unshown := int(struck.get_carried()) - int(struck.get_shown())
	var struck_unbroken := int(struck.get_shown()) - int(struck.get_broken())
	var struck_unstruck := int(struck.get_broken()) - int(struck.get_struck())
	if int(struck.get_struck()) != 1 or int(struck.get_ensign_left()) != 0 or struck_unstruck != 0 or int(struck.get_broken()) != 1 or int(struck.get_jack_left()) != 0 or struck_unbroken != 0 or int(struck.get_shown()) != 1 or int(struck.get_standard_left()) != 0 or struck_unshown != 0 or int(struck.get_carried()) != 1 or struck_uncarried != 0 or int(struck.get_pennant_left()) != 0 or struck_unflown != 0 or struck_unhoisted != 0 or struck_unraised != 0 or int(struck.get_horn_left()) != 0 or int(struck.get_bell_left()) != 1 or struck_unrung != 1 or struck_unlit != 1 or struck_unstood != 2 or struck_unposted != 4 or struck_unpaid != 19 or int(struck.get_lamp_left()) != 1 or int(struck.get_watch_left()) != 1 or int(struck.get_relief_left()) != 2 or int(struck.get_wage_left()) != 4 or int(struck.get_loft_left()) != 19 or int(struck.get_gate_left()) != 0 or int(struck.get_yard_left()) != 57 or int(struck.get_flown()) != 1 or int(struck.get_hoisted()) != 1 or int(struck.get_raised()) != 1 or int(struck.get_sounded()) != 1 or int(struck.get_rung()) != 2 or int(struck.get_lit()) != 3 or int(struck.get_stood()) != 4 or int(struck.get_posted()) != 6 or int(struck.get_coins()) != 2997 or int(struck.get_hired()) != 29 or int(struck.get_stored_salt()) != 2997 or int(struck.get_carted()) != 2997 or int(struck.get_shipped()) != 2997:
		_fail(errors, "struck %d, left %d broken unstruck, shown unbroken %d, carried unshown %d, flown uncarried %d, hoisted unflown %d, raised unhoisted %d, sounded unraised %d, rung unsounded %d, lit unrung %d, stood unlit %d, posted unstood %d, paid unposted %d, unpaid %d, ensign %d, yard %d, broken %d, shown %d, carried %d, flown %d, hoisted %d, raised %d, sounded %d, rung %d, lit %d, stood %d, posted %d, coins %d, hired %d" % [struck.get_struck(), struck.get_ensign_left(), struck_unbroken, struck_uncarried, struck_unflown, struck_unhoisted, struck_unraised, struck.get_bell_left(), struck_unrung, struck_unlit, struck_unstood, struck_unposted, struck_unpaid, struck.get_ensign_left(), struck.get_yard_left(), struck.get_broken(), struck.get_shown(), struck.get_carried(), struck.get_flown(), struck.get_hoisted(), struck.get_raised(), struck.get_sounded(), struck.get_rung(), struck.get_lit(), struck.get_stood(), struck.get_posted(), struck.get_coins(), struck.get_hired()])
	if int(struck.get_struck()) > int(Sim.BURGEE_CAP):
		_fail(errors, "burgee struck %d, over the cap of %d" % [struck.get_struck(), Sim.BURGEE_CAP])
	var burgee_salt: Dictionary = struck.get_cell_salt(int(burgee_cell[0]), int(burgee_cell[1]))
	var ensign_salt: Dictionary = struck.get_cell_salt(int(ensign_cell[0]), int(ensign_cell[1]))
	var jack_salt: Dictionary = struck.get_cell_salt(int(jack_cell[0]), int(jack_cell[1]))
	if int(burgee_salt.get("burgee", 0)) != 1 or int(ensign_salt.get("ensign", 0)) != 0 or int(jack_salt.get("jack", 0)) != 0 or int(burgee_salt.get("ensign", 0)) != 0:
		_fail(errors, "burgee cell holds %s, ensign holds %s, jack holds %s" % [burgee_salt.get("burgee", 0), ensign_salt.get("ensign", 0), jack_salt.get("jack", 0)])
	var struck_summary := String(struck.get_summary())
	if not struck_summary.contains("Struck 1 on the burgee") or not struck_summary.contains("Left 0 at the ensign") or not struck_summary.contains("Broke 1 on the ensign") or not struck_summary.contains("Left 0 at the jack") or not struck_summary.contains("Coins 2997") or not struck_summary.contains("Hired 29") or not struck_summary.contains("Left 57"):
		_fail(errors, "struck summary does not name the burgee: %s" % struck_summary)
	if int(struck_again.get_struck()) != int(struck.get_struck()) or int(struck_again.get_ensign_left()) != int(struck.get_ensign_left()) or int(struck_again.get_broken()) != int(struck.get_broken()) or int(struck_again.get_yard_left()) != int(struck.get_yard_left()) or int(struck_again.get_stored_salt()) != int(struck.get_stored_salt()) or String(struck_again.get_summary()) != String(struck.get_summary()):
		_fail(errors, "repeated burgee paint struck %d and left ensign %d, then struck %d and left ensign %d" % [struck.get_struck(), struck.get_ensign_left(), struck_again.get_struck(), struck_again.get_ensign_left()])
	if int(late.get_struck()) != 1 or int(late.get_ensign_left()) != 0 or int(late.get_broken()) != 1 or int(late.get_shown()) != 1 or int(late.get_carried()) != 1 or int(late.get_flown()) != 1 or int(late.get_hoisted()) != 1 or int(late.get_raised()) != 1 or int(late.get_sounded()) != 1 or int(late.get_rung()) != 2 or int(late.get_lit()) != 3 or int(late.get_stood()) != 4 or int(late.get_posted()) != 6 or int(late.get_yard_left()) != 57 or int(late.get_hired()) != 29 or int(late.get_coins()) != 2997 or int(late.get_stored_salt()) != 2997 or int(late.get_loft_left()) != 19 or int(late.get_wage_left()) != 4:
		_fail(errors, "painting the burgee at the burgee beat (struck %d ensign %d broken %d yard %d) did not match painting it early (struck %d ensign %d broken %d)" % [late.get_struck(), late.get_ensign_left(), late.get_broken(), late.get_yard_left(), struck.get_struck(), struck.get_ensign_left(), struck.get_broken()])
	_assert_chain(dry_struck, errors, "dry burgee", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1)
	var dry_unpaid := int(dry_struck.get_hired()) - int(dry_struck.get_paid())
	var dry_unposted := int(dry_struck.get_paid()) - int(dry_struck.get_posted())
	var dry_unstood := int(dry_struck.get_posted()) - int(dry_struck.get_stood())
	var dry_unlit := int(dry_struck.get_stood()) - int(dry_struck.get_lit())
	var dry_unrung := int(dry_struck.get_lit()) - int(dry_struck.get_rung())
	var dry_unraised := int(dry_struck.get_sounded()) - int(dry_struck.get_raised())
	var dry_unhoisted := int(dry_struck.get_raised()) - int(dry_struck.get_hoisted())
	var dry_unflown := int(dry_struck.get_hoisted()) - int(dry_struck.get_flown())
	var dry_uncarried := int(dry_struck.get_flown()) - int(dry_struck.get_carried())
	var dry_unshown := int(dry_struck.get_carried()) - int(dry_struck.get_shown())
	var dry_unbroken := int(dry_struck.get_shown()) - int(dry_struck.get_broken())
	var dry_unstruck := int(dry_struck.get_broken()) - int(dry_struck.get_struck())
	if int(dry_struck.get_struck()) != 1 or int(dry_struck.get_ensign_left()) != 0 or dry_unstruck != 0 or int(dry_struck.get_broken()) != 1 or int(dry_struck.get_jack_left()) != 0 or dry_unbroken != 0 or int(dry_struck.get_shown()) != 1 or int(dry_struck.get_standard_left()) != 0 or dry_unshown != 0 or int(dry_struck.get_carried()) != 1 or dry_uncarried != 0 or int(dry_struck.get_pennant_left()) != 0 or dry_unflown != 0 or dry_unhoisted != 0 or dry_unraised != 0 or int(dry_struck.get_horn_left()) != 0 or int(dry_struck.get_bell_left()) != 1 or dry_unrung != 1 or dry_unlit != 1 or dry_unstood != 2 or dry_unposted != 2 or dry_unpaid != 2 or int(dry_struck.get_yard_left()) != 0 or int(dry_struck.get_flown()) != 1 or int(dry_struck.get_hoisted()) != 1 or int(dry_struck.get_raised()) != 1 or int(dry_struck.get_sounded()) != 1 or int(dry_struck.get_rung()) != 2 or int(dry_struck.get_lit()) != 3 or int(dry_struck.get_stood()) != 4 or int(dry_struck.get_posted()) != 6 or int(dry_struck.get_wet_haul()) != 0 or int(dry_struck.get_stored_salt()) != 1032 or int(dry_struck.get_gate_left()) != 2 or int(dry_struck.get_wage_left()) != 2 or int(dry_struck.get_loft_left()) != 0:
		_fail(errors, "dry burgee changed the short crew (wet %d stored %d struck %d ensign %d broken %d jack %d shown %d standard %d carried %d pennant %d flown %d unstruck %d unbroken %d unshown %d uncarried %d unflown %d unhoisted %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d yard %d)" % [dry_struck.get_wet_haul(), dry_struck.get_stored_salt(), dry_struck.get_struck(), dry_struck.get_ensign_left(), dry_struck.get_broken(), dry_struck.get_jack_left(), dry_struck.get_shown(), dry_struck.get_standard_left(), dry_struck.get_carried(), dry_struck.get_pennant_left(), dry_struck.get_flown(), dry_unstruck, dry_unbroken, dry_unshown, dry_uncarried, dry_unflown, dry_unhoisted, dry_unraised, dry_struck.get_bell_left(), dry_unrung, dry_unlit, dry_unstood, dry_unposted, dry_unpaid, dry_struck.get_yard_left()])
	var dry_burgee_cell = plans["dry_struck"]["burgee"][0]
	var dry_ensign_cell = plans["dry_struck"]["ensign"][0]
	var dry_burgee_salt: Dictionary = dry_struck.get_cell_salt(int(dry_burgee_cell[0]), int(dry_burgee_cell[1]))
	var dry_ensign_salt: Dictionary = dry_struck.get_cell_salt(int(dry_ensign_cell[0]), int(dry_ensign_cell[1]))
	if int(dry_burgee_salt.get("burgee", 0)) != 1 or int(dry_ensign_salt.get("ensign", 0)) != 0:
		_fail(errors, "dry burgee cell holds %s, ensign holds %s" % [dry_burgee_salt.get("burgee", 0), dry_ensign_salt.get("ensign", 0)])
	if not String(dry_struck.get_summary()).contains("Struck 1 on the burgee") or not String(dry_struck.get_summary()).contains("Left 0 at the ensign") or not String(dry_struck.get_summary()).contains("Broke 1 on the ensign") or not String(dry_struck.get_summary()).contains("Left 0 in the yard"):
		_fail(errors, "dry burgee summary does not name the cap: %s" % dry_struck.get_summary())
	_assert_pop(struck, errors, "struck plan")
	_assert_pop(struck_again, errors, "struck plan again")
	_assert_pop(late, errors, "late_struck")
	_assert_pop(dry_struck, errors, "dry_struck")
	_assert_pop(no_burgee, errors, "no_burgee")
	_assert_pop(bare, errors, "burgee_only")
	var shore = _prepare_plan(plans, "struck", errors)
	if shore == null:
		return
	var shore_guard := 0
	var shore_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + int(Sim.STANDARD_TICK) + int(Sim.JACK_TICK) + int(Sim.ENSIGN_TICK) + 2
	while int(shore.get_beat()) != Sim.BURGEEING and not shore.is_over() and shore_guard < shore_limit:
		shore.tick()
		shore_guard += 1
	if int(shore.get_beat()) != Sim.BURGEEING or shore.is_over():
		_fail(errors, "the ensign beat did not open a burgee beat for the cap check")
		return
	if int(shore.get_ticks_until_rain()) != int(Sim.BURGEE_TICK):
		_fail(errors, "burgee countdown started at %d, expected %d" % [shore.get_ticks_until_rain(), Sim.BURGEE_TICK])
	if int(shore.get_struck()) != 0 or int(shore.get_broken()) != 1 or int(shore.get_ensign_left()) != 1 or int(shore.get_shown()) != 1 or int(shore.get_jack_left()) != 0 or int(shore.get_carried()) != 1 or int(shore.get_standard_left()) != 0 or int(shore.get_yard_left()) != 57 or int(shore.get_coins()) != 2997 or int(shore.get_stored_salt()) != 2997:
		_fail(errors, "burgee opened early (struck %d broken %d ensign %d shown %d jack %d carried %d yard %d coins %d stored %d)" % [shore.get_struck(), shore.get_broken(), shore.get_ensign_left(), shore.get_shown(), shore.get_jack_left(), shore.get_carried(), shore.get_yard_left(), shore.get_coins(), shore.get_stored_salt()])
	var saw_cap := false
	var strike_guard := 0
	while not shore.is_over() and strike_guard < int(Sim.BURGEE_TICK) + 2:
		shore.tick()
		strike_guard += 1
		if int(shore.get_struck()) == int(Sim.BURGEE_CAP) and int(shore.get_ensign_left()) == 0 and int(shore.get_broken()) == 1 and int(shore.get_shown()) == 1 and int(shore.get_carried()) == 1 and int(shore.get_flown()) == 1 and int(shore.get_hoisted()) == 1 and int(shore.get_yard_left()) == 57 and int(shore.get_coins()) == 2997 and int(shore.get_hired()) == 29 and int(shore.get_ticks_until_rain()) > 0:
			saw_cap = true
			var ticks_left := int(shore.get_ticks_until_rain())
			shore.tick()
			if int(shore.get_struck()) != int(Sim.BURGEE_CAP) or int(shore.get_ensign_left()) != 0 or int(shore.get_broken()) != 1 or int(shore.get_shown()) != 1 or int(shore.get_carried()) != 1 or int(shore.get_flown()) != 1 or int(shore.get_hoisted()) != 1 or int(shore.get_raised()) != 1 or int(shore.get_yard_left()) != 57 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29 or int(shore.get_stored_salt()) != 2997 or int(shore.get_posted()) != 6 or int(shore.get_stood()) != 4 or int(shore.get_lit()) != 3 or int(shore.get_rung()) != 2 or int(shore.get_sounded()) != 1:
				_fail(errors, "the burgee kept striking after the cap (struck %d ensign %d broken %d shown %d carried %d yard %d)" % [shore.get_struck(), shore.get_ensign_left(), shore.get_broken(), shore.get_shown(), shore.get_carried(), shore.get_yard_left()])
			elif not shore.is_over() and int(shore.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the burgee beat did not spend a tick after the cap")
			break
	if not saw_cap:
		_fail(errors, "the burgee did not stop at %d while ticks remained (struck %d ensign %d broken %d ticks %d)" % [Sim.BURGEE_CAP, shore.get_struck(), shore.get_ensign_left(), shore.get_broken(), shore.get_ticks_until_rain()])
	var end_guard := 0
	while int(shore.get_beat()) == Sim.BURGEEING and not shore.is_over() and end_guard < int(Sim.BURGEE_TICK) + 2:
		shore.tick()
		end_guard += 1
		if int(shore.get_struck()) != 1 or int(shore.get_ensign_left()) != 0 or int(shore.get_broken()) != 1:
			_fail(errors, "the burgee struck again after the cap (struck %d ensign %d broken %d)" % [shore.get_struck(), shore.get_ensign_left(), shore.get_broken()])
			break
	if shore.is_over() or int(shore.get_beat()) != Sim.CORNETING:
		_fail(errors, "the burgee beat ended the scenario instead of opening the cornet")
	elif int(shore.get_struck()) != 1 or int(shore.get_dipped()) != 0 or int(shore.get_burgee_left()) != 1:
		_fail(errors, "the burgee beat changed its strike count when the cornet opened (struck %d dipped %d burgee %d)" % [shore.get_struck(), shore.get_dipped(), shore.get_burgee_left()])
	var short = _prepare_plan(plans, "dry_struck", errors)
	if short == null:
		return
	var short_guard := 0
	while int(short.get_beat()) != Sim.BURGEEING and not short.is_over() and short_guard < shore_limit:
		short.tick()
		short_guard += 1
	if int(short.get_beat()) != Sim.BURGEEING or short.is_over():
		_fail(errors, "the ensign beat did not open a burgee beat for the dry cap")
		return
	var saw_short := false
	var short_steps := 0
	while not short.is_over() and short_steps < int(Sim.BURGEE_TICK) + 2:
		short.tick()
		short_steps += 1
		if int(short.get_struck()) == int(Sim.BURGEE_CAP) and int(short.get_ensign_left()) == 0 and int(short.get_broken()) == 1 and int(short.get_shown()) == 1 and int(short.get_carried()) == 1 and int(short.get_flown()) == 1 and int(short.get_yard_left()) == 0 and int(short.get_wet_haul()) == 0 and int(short.get_ticks_until_rain()) > 0:
			saw_short = true
			var short_ticks := int(short.get_ticks_until_rain())
			short.tick()
			if int(short.get_struck()) != 1 or int(short.get_ensign_left()) != 0 or int(short.get_broken()) != 1 or int(short.get_shown()) != 1 or int(short.get_carried()) != 1 or int(short.get_flown()) != 1 or int(short.get_yard_left()) != 0 or int(short.get_posted()) != 6 or int(short.get_stored_salt()) != 1032:
				_fail(errors, "the burgee struck an unbroken hire or passed the cap (struck %d ensign %d broken %d yard %d)" % [short.get_struck(), short.get_ensign_left(), short.get_broken(), short.get_yard_left()])
			elif not short.is_over() and int(short.get_ticks_until_rain()) >= short_ticks:
				_fail(errors, "the burgee beat did not spend a tick after the dry cap")
			break
	if not saw_short:
		_fail(errors, "dry burgee did not stop at 1 with the ensign clear (struck %d ensign %d broken %d yard %d ticks %d)" % [short.get_struck(), short.get_ensign_left(), short.get_broken(), short.get_yard_left(), short.get_ticks_until_rain()])
	print("struck %d left ensign %d unbroken %d unshown %d uncarried %d unflown %d unhoisted %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d; dry struck %d left ensign %d unbroken %d unshown %d uncarried %d unflown %d unhoisted %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d; no burgee struck %d left ensign %d; burgee without ensign struck %d" % [struck.get_struck(), struck.get_ensign_left(), struck_unbroken, struck_unshown, struck_uncarried, struck_unflown, struck_unhoisted, struck_unraised, struck.get_bell_left(), struck_unrung, struck_unlit, struck_unstood, struck_unposted, struck_unpaid, dry_struck.get_struck(), dry_struck.get_ensign_left(), dry_unbroken, dry_unshown, dry_uncarried, dry_unflown, dry_unhoisted, dry_unraised, dry_struck.get_bell_left(), dry_unrung, dry_unlit, dry_unstood, dry_unposted, dry_unpaid, no_burgee.get_struck(), no_burgee.get_ensign_left(), bare.get_struck()])

func _test_cornet(errors: Array) -> void:
	if int(Sim.CORNET_TICK) != 100 or int(Sim.CORNET_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "cornet beat length %s is not 100 ticks (10 seconds)" % Sim.CORNET_TICK)
	if int(Sim.CORNET_CAP) != 1:
		_fail(errors, "cornet cap is %s, expected 1" % Sim.CORNET_CAP)
	if int(Sim.BURGEE_CAP) != 1:
		_fail(errors, "burgee cap changed to %s" % Sim.BURGEE_CAP)
	if int(Sim.GRID_NORTH) > -16:
		_fail(errors, "the map was not extended to the cornet row (north %s)" % Sim.GRID_NORTH)
	if int(Sim.CORNET_CELL.x) != 14 or int(Sim.CORNET_CELL.y) != -16:
		_fail(errors, "the cornet cell is not at 14,-16")
	if int(Sim.BURGEE_CELL.x) != 14 or int(Sim.BURGEE_CELL.y) != -15:
		_fail(errors, "the burgee moved off 14,-15")
	if int(Sim.ENSIGN_CELL.x) != 14 or int(Sim.ENSIGN_CELL.y) != -14:
		_fail(errors, "the ensign moved off 14,-14")
	if int(Sim.JACK_CELL.x) != 14 or int(Sim.JACK_CELL.y) != -13:
		_fail(errors, "the jack moved off 14,-13")
	if int(Sim.STANDARD_CELL.x) != 14 or int(Sim.STANDARD_CELL.y) != -12:
		_fail(errors, "the standard moved off 14,-12")
	if int(Sim.PENNANT_CELL.x) != 14 or int(Sim.PENNANT_CELL.y) != -11:
		_fail(errors, "the pennant moved off 14,-11")
	var fresh = Sim.new()
	if fresh.paint_cell(14, -16, Sim.CORNET) == false or int(fresh.get_paint(14, -16)) != Sim.CORNET:
		_fail(errors, "the cell north of the burgee rejected the cornet mark")
	if fresh.paint_cell(14, -15, Sim.CORNET):
		_fail(errors, "the burgee cell accepted a cornet")
	if int(fresh.get_paint(14, -15)) != Sim.EMPTY:
		_fail(errors, "a rejected cornet painted the burgee cell")
	if fresh.paint_cell(14, -16, Sim.BURGEE):
		_fail(errors, "the cornet cell accepted a burgee")
	if int(fresh.get_paint(14, -16)) != Sim.CORNET:
		_fail(errors, "a rejected burgee erased the cornet")
	if fresh.paint_cell(14, -15, Sim.BURGEE) == false or int(fresh.get_paint(14, -15)) != Sim.BURGEE:
		_fail(errors, "the burgee cell no longer accepts a burgee")
	if fresh.paint_cell(14, -14, Sim.ENSIGN) == false or int(fresh.get_paint(14, -14)) != Sim.ENSIGN:
		_fail(errors, "the ensign cell no longer accepts an ensign")
	if fresh.paint_cell(14, -13, Sim.JACK) == false or int(fresh.get_paint(14, -13)) != Sim.JACK:
		_fail(errors, "the jack cell no longer accepts a jack")
	if fresh.paint_cell(14, -12, Sim.STANDARD) == false or int(fresh.get_paint(14, -12)) != Sim.STANDARD:
		_fail(errors, "the standard cell no longer accepts a standard")
	if fresh.paint_cell(14, -11, Sim.PENNANT) == false or int(fresh.get_paint(14, -11)) != Sim.PENNANT:
		_fail(errors, "the pennant cell no longer accepts a pennant")
	if fresh.paint_cell(14, -10, Sim.BANNER) == false or int(fresh.get_paint(14, -10)) != Sim.BANNER:
		_fail(errors, "the banner cell no longer accepts a banner")
	if fresh.paint_cell(14, -9, Sim.FLAG) == false or int(fresh.get_paint(14, -9)) != Sim.FLAG:
		_fail(errors, "the flag cell no longer accepts a flag")
	if fresh.paint_cell(14, -17, Sim.CORNET) or fresh.paint_cell(13, -16, Sim.CORNET) or fresh.paint_cell(15, -16, Sim.CORNET) or fresh.paint_cell(14, -15, Sim.CORNET) or fresh.paint_cell(14, -14, Sim.CORNET):
		_fail(errors, "a cell other than 14,-16 accepted a cornet")
	if int(fresh.get_paint(14, -15)) != Sim.BURGEE:
		_fail(errors, "a rejected cornet erased the burgee")
	if fresh.paint_cell(Sim.COAST_X, -16, Sim.CORNET):
		_fail(errors, "the brine accepted a cornet")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.CORNET):
		_fail(errors, "the anthill accepted a cornet")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var won = _run_plan(plans, "winning", errors)
	var dry = _run_plan(plans, "dry_pans", errors)
	var struck = _run_plan(plans, "struck", errors)
	var no_cornet = _run_plan(plans, "no_cornet", errors)
	var bare = _run_plan(plans, "cornet_only", errors)
	var broken_shore = _run_plan(plans, "no_burgee", errors)
	var dipped = _run_plan(plans, "dipped", errors)
	var dipped_again = _run_plan(plans, "dipped", errors)
	var late = _run_plan(plans, "late_dipped", errors)
	var dry_dipped = _run_plan(plans, "dry_dipped", errors)
	if won == null or dry == null or struck == null or no_cornet == null or bare == null or broken_shore == null or dipped == null or dipped_again == null or late == null or dry_dipped == null:
		return
	if int(won.get_dipped()) != 0 or int(dry.get_dipped()) != 0 or int(struck.get_dipped()) != 0:
		_fail(errors, "a plan with no cornet dipped someone (winning %d dry %d struck %d)" % [won.get_dipped(), dry.get_dipped(), struck.get_dipped()])
	if String(struck.get_summary()) != String(no_cornet.get_summary()):
		_fail(errors, "a burgee with no cornet changed the struck summary: %s" % no_cornet.get_summary())
	if String(no_cornet.get_summary()).to_lower().contains("dipped") or String(no_cornet.get_summary()).to_lower().contains("cornet"):
		_fail(errors, "a burgee with no cornet names a cornet: %s" % no_cornet.get_summary())
	var no_unpaid := int(no_cornet.get_hired()) - int(no_cornet.get_paid())
	var no_unposted := int(no_cornet.get_paid()) - int(no_cornet.get_posted())
	var no_unstood := int(no_cornet.get_posted()) - int(no_cornet.get_stood())
	var no_unlit := int(no_cornet.get_stood()) - int(no_cornet.get_lit())
	var no_unrung := int(no_cornet.get_lit()) - int(no_cornet.get_rung())
	if int(no_cornet.get_dipped()) != 0 or int(no_cornet.get_burgee_left()) != 1 or int(no_cornet.get_struck()) != 1 or int(no_cornet.get_ensign_left()) != 0 or int(no_cornet.get_broken()) != 1 or int(no_cornet.get_jack_left()) != 0 or int(no_cornet.get_shown()) != 1 or int(no_cornet.get_standard_left()) != 0 or int(no_cornet.get_carried()) != 1 or int(no_cornet.get_pennant_left()) != 0 or int(no_cornet.get_flown()) != 1 or int(no_cornet.get_banner_left()) != 0 or int(no_cornet.get_hoisted()) != 1 or int(no_cornet.get_flag_left()) != 0 or int(no_cornet.get_raised()) != 1 or int(no_cornet.get_horn_left()) != 0 or int(no_cornet.get_sounded()) != 1 or int(no_cornet.get_bell_left()) != 1 or no_unrung != 1 or no_unlit != 1 or no_unstood != 2 or no_unposted != 4 or no_unpaid != 19 or int(no_cornet.get_yard_left()) != 57 or int(no_cornet.get_coins()) != 2997 or int(no_cornet.get_hired()) != 29 or int(no_cornet.get_stored_salt()) != 2997:
		_fail(errors, "a burgee with no cornet dipped someone (dipped %d burgee %d struck %d ensign %d broken %d unpaid %d)" % [no_cornet.get_dipped(), no_cornet.get_burgee_left(), no_cornet.get_struck(), no_cornet.get_ensign_left(), no_cornet.get_broken(), no_unpaid])
	var kept_burgee = plans["no_cornet"]["burgee"][0]
	var kept_salt: Dictionary = no_cornet.get_cell_salt(int(kept_burgee[0]), int(kept_burgee[1]))
	var kept_north: Dictionary = no_cornet.get_cell_salt(int(kept_burgee[0]), int(kept_burgee[1]) - 1)
	if int(kept_salt.get("burgee", 0)) != 1 or int(kept_north.get("cornet", 0)) != 0 or int(kept_salt.get("cornet", 0)) != 0:
		_fail(errors, "a burgee with no cornet left %s on the burgee and %s on a cornet" % [kept_salt.get("burgee", 0), kept_north.get("cornet", 0)])
	if String(bare.get_summary()) != String(broken_shore.get_summary()):
		_fail(errors, "a cornet with no burgee changed the broken summary: %s" % bare.get_summary())
	if String(bare.get_summary()).to_lower().contains("dipped") or String(bare.get_summary()).to_lower().contains("cornet") or String(bare.get_summary()).to_lower().contains("struck") or String(bare.get_summary()).to_lower().contains("burgee"):
		_fail(errors, "a cornet with no burgee names a cornet: %s" % bare.get_summary())
	if int(bare.get_dipped()) != 0 or int(bare.get_struck()) != 0 or int(bare.get_burgee_left()) != 0 or int(bare.get_broken()) != 1 or int(bare.get_ensign_left()) != 1 or int(bare.get_shown()) != 1 or int(bare.get_jack_left()) != 0 or int(bare.get_carried()) != 1 or int(bare.get_standard_left()) != 0 or int(bare.get_yard_left()) != 57 or int(bare.get_coins()) != 2997 or int(bare.get_hired()) != 29:
		_fail(errors, "a cornet with no burgee dipped someone (dipped %d struck %d broken %d ensign %d)" % [bare.get_dipped(), bare.get_struck(), bare.get_broken(), bare.get_ensign_left()])
	var bare_cornet = plans["cornet_only"]["cornet"][0]
	var bare_ensign = plans["cornet_only"]["ensign"][0]
	var bare_cornet_salt: Dictionary = bare.get_cell_salt(int(bare_cornet[0]), int(bare_cornet[1]))
	var bare_ensign_salt: Dictionary = bare.get_cell_salt(int(bare_ensign[0]), int(bare_ensign[1]))
	if int(bare_cornet_salt.get("cornet", 0)) != 0 or int(bare_ensign_salt.get("ensign", 0)) != 1 or int(bare_cornet_salt.get("burgee", 0)) != 0:
		_fail(errors, "cornet without a burgee holds %s, ensign holds %s" % [bare_cornet_salt.get("cornet", 0), bare_ensign_salt.get("ensign", 0)])
	var cornet_cell = plans["dipped"]["cornet"][0]
	var burgee_cell = plans["dipped"]["burgee"][0]
	var ensign_cell = plans["dipped"]["ensign"][0]
	var jack_cell = plans["dipped"]["jack"][0]
	var standard_cell = plans["dipped"]["standard"][0]
	var pennant_cell = plans["dipped"]["pennant"][0]
	var banner_cell = plans["dipped"]["banner"][0]
	var flag_cell = plans["dipped"]["flag"][0]
	if int(cornet_cell[0]) != int(burgee_cell[0]) or int(cornet_cell[1]) != int(burgee_cell[1]) - 1:
		_fail(errors, "dipped plan's cornet is not one cell north of the burgee")
	if int(cornet_cell[0]) != 14 or int(cornet_cell[1]) != -16 or int(burgee_cell[0]) != 14 or int(burgee_cell[1]) != -15 or int(ensign_cell[0]) != 14 or int(ensign_cell[1]) != -14 or int(jack_cell[0]) != 14 or int(jack_cell[1]) != -13 or int(standard_cell[0]) != 14 or int(standard_cell[1]) != -12 or int(pennant_cell[0]) != 14 or int(pennant_cell[1]) != -11 or int(banner_cell[0]) != 14 or int(banner_cell[1]) != -10 or int(flag_cell[0]) != 14 or int(flag_cell[1]) != -9:
		_fail(errors, "dipped plan moved the cornet, the burgee, the ensign, the jack, the standard, the pennant, the banner, or the flag")
	_assert_chain(dipped, errors, "dipped plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1)
	var dipped_unpaid := int(dipped.get_hired()) - int(dipped.get_paid())
	var dipped_unposted := int(dipped.get_paid()) - int(dipped.get_posted())
	var dipped_unstood := int(dipped.get_posted()) - int(dipped.get_stood())
	var dipped_unlit := int(dipped.get_stood()) - int(dipped.get_lit())
	var dipped_unrung := int(dipped.get_lit()) - int(dipped.get_rung())
	var dipped_unraised := int(dipped.get_sounded()) - int(dipped.get_raised())
	var dipped_unhoisted := int(dipped.get_raised()) - int(dipped.get_hoisted())
	var dipped_unflown := int(dipped.get_hoisted()) - int(dipped.get_flown())
	var dipped_uncarried := int(dipped.get_flown()) - int(dipped.get_carried())
	var dipped_unshown := int(dipped.get_carried()) - int(dipped.get_shown())
	var dipped_unbroken := int(dipped.get_shown()) - int(dipped.get_broken())
	var dipped_unstruck := int(dipped.get_broken()) - int(dipped.get_struck())
	var dipped_undipped := int(dipped.get_struck()) - int(dipped.get_dipped())
	if int(dipped.get_dipped()) != 1 or int(dipped.get_burgee_left()) != 0 or dipped_undipped != 0 or int(dipped.get_struck()) != 1 or int(dipped.get_ensign_left()) != 0 or dipped_unstruck != 0 or int(dipped.get_broken()) != 1 or int(dipped.get_jack_left()) != 0 or dipped_unbroken != 0 or int(dipped.get_shown()) != 1 or int(dipped.get_standard_left()) != 0 or dipped_unshown != 0 or int(dipped.get_carried()) != 1 or dipped_uncarried != 0 or int(dipped.get_pennant_left()) != 0 or dipped_unflown != 0 or dipped_unhoisted != 0 or dipped_unraised != 0 or int(dipped.get_horn_left()) != 0 or int(dipped.get_bell_left()) != 1 or dipped_unrung != 1 or dipped_unlit != 1 or dipped_unstood != 2 or dipped_unposted != 4 or dipped_unpaid != 19 or int(dipped.get_lamp_left()) != 1 or int(dipped.get_watch_left()) != 1 or int(dipped.get_relief_left()) != 2 or int(dipped.get_wage_left()) != 4 or int(dipped.get_loft_left()) != 19 or int(dipped.get_gate_left()) != 0 or int(dipped.get_yard_left()) != 57 or int(dipped.get_flown()) != 1 or int(dipped.get_hoisted()) != 1 or int(dipped.get_raised()) != 1 or int(dipped.get_sounded()) != 1 or int(dipped.get_rung()) != 2 or int(dipped.get_lit()) != 3 or int(dipped.get_stood()) != 4 or int(dipped.get_posted()) != 6 or int(dipped.get_coins()) != 2997 or int(dipped.get_hired()) != 29 or int(dipped.get_stored_salt()) != 2997 or int(dipped.get_carted()) != 2997 or int(dipped.get_shipped()) != 2997:
		_fail(errors, "dipped %d, left %d struck undipped, broken unstruck %d, shown unbroken %d, carried unshown %d, flown uncarried %d, hoisted unflown %d, raised unhoisted %d, sounded unraised %d, rung unsounded %d, lit unrung %d, stood unlit %d, posted unstood %d, paid unposted %d, unpaid %d, burgee %d, yard %d, struck %d, broken %d, shown %d, carried %d, flown %d, hoisted %d, raised %d, sounded %d, rung %d, lit %d, stood %d, posted %d, coins %d, hired %d" % [dipped.get_dipped(), dipped.get_burgee_left(), dipped_unstruck, dipped_unshown, dipped_uncarried, dipped_unflown, dipped_unhoisted, dipped_unraised, dipped.get_bell_left(), dipped_unrung, dipped_unlit, dipped_unstood, dipped_unposted, dipped_unpaid, dipped.get_burgee_left(), dipped.get_yard_left(), dipped.get_struck(), dipped.get_broken(), dipped.get_shown(), dipped.get_carried(), dipped.get_flown(), dipped.get_hoisted(), dipped.get_raised(), dipped.get_sounded(), dipped.get_rung(), dipped.get_lit(), dipped.get_stood(), dipped.get_posted(), dipped.get_coins(), dipped.get_hired()])
	if int(dipped.get_dipped()) > int(Sim.CORNET_CAP):
		_fail(errors, "cornet dipped %d, over the cap of %d" % [dipped.get_dipped(), Sim.CORNET_CAP])
	var cornet_salt: Dictionary = dipped.get_cell_salt(int(cornet_cell[0]), int(cornet_cell[1]))
	var burgee_salt: Dictionary = dipped.get_cell_salt(int(burgee_cell[0]), int(burgee_cell[1]))
	var ensign_salt: Dictionary = dipped.get_cell_salt(int(ensign_cell[0]), int(ensign_cell[1]))
	if int(cornet_salt.get("cornet", 0)) != 1 or int(burgee_salt.get("burgee", 0)) != 0 or int(ensign_salt.get("ensign", 0)) != 0 or int(cornet_salt.get("burgee", 0)) != 0:
		_fail(errors, "cornet cell holds %s, burgee holds %s, ensign holds %s" % [cornet_salt.get("cornet", 0), burgee_salt.get("burgee", 0), ensign_salt.get("ensign", 0)])
	var dipped_summary := String(dipped.get_summary())
	if not dipped_summary.contains("Dipped 1 on the cornet") or not dipped_summary.contains("Left 0 at the burgee") or not dipped_summary.contains("Struck 1 on the burgee") or not dipped_summary.contains("Left 0 at the ensign") or not dipped_summary.contains("Coins 2997") or not dipped_summary.contains("Hired 29") or not dipped_summary.contains("Left 57"):
		_fail(errors, "dipped summary does not name the cornet: %s" % dipped_summary)
	if int(dipped_again.get_dipped()) != int(dipped.get_dipped()) or int(dipped_again.get_burgee_left()) != int(dipped.get_burgee_left()) or int(dipped_again.get_struck()) != int(dipped.get_struck()) or int(dipped_again.get_yard_left()) != int(dipped.get_yard_left()) or int(dipped_again.get_stored_salt()) != int(dipped.get_stored_salt()) or String(dipped_again.get_summary()) != String(dipped.get_summary()):
		_fail(errors, "repeated cornet paint dipped %d and left burgee %d, then dipped %d and left burgee %d" % [dipped.get_dipped(), dipped.get_burgee_left(), dipped_again.get_dipped(), dipped_again.get_burgee_left()])
	if int(late.get_dipped()) != 1 or int(late.get_burgee_left()) != 0 or int(late.get_struck()) != 1 or int(late.get_broken()) != 1 or int(late.get_shown()) != 1 or int(late.get_carried()) != 1 or int(late.get_flown()) != 1 or int(late.get_hoisted()) != 1 or int(late.get_raised()) != 1 or int(late.get_sounded()) != 1 or int(late.get_rung()) != 2 or int(late.get_lit()) != 3 or int(late.get_stood()) != 4 or int(late.get_posted()) != 6 or int(late.get_yard_left()) != 57 or int(late.get_hired()) != 29 or int(late.get_coins()) != 2997 or int(late.get_stored_salt()) != 2997 or int(late.get_loft_left()) != 19 or int(late.get_wage_left()) != 4:
		_fail(errors, "painting the cornet at the cornet beat (dipped %d burgee %d struck %d yard %d) did not match painting it early (dipped %d burgee %d struck %d)" % [late.get_dipped(), late.get_burgee_left(), late.get_struck(), late.get_yard_left(), dipped.get_dipped(), dipped.get_burgee_left(), dipped.get_struck()])
	_assert_chain(dry_dipped, errors, "dry cornet", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1)
	var dry_struck = _run_plan(plans, "dry_struck", errors)
	if dry_struck == null:
		return
	var dry_unpaid := int(dry_dipped.get_hired()) - int(dry_dipped.get_paid())
	var dry_unposted := int(dry_dipped.get_paid()) - int(dry_dipped.get_posted())
	var dry_unstood := int(dry_dipped.get_posted()) - int(dry_dipped.get_stood())
	var dry_unlit := int(dry_dipped.get_stood()) - int(dry_dipped.get_lit())
	var dry_unrung := int(dry_dipped.get_lit()) - int(dry_dipped.get_rung())
	var dry_unraised := int(dry_dipped.get_sounded()) - int(dry_dipped.get_raised())
	var dry_unhoisted := int(dry_dipped.get_raised()) - int(dry_dipped.get_hoisted())
	var dry_unflown := int(dry_dipped.get_hoisted()) - int(dry_dipped.get_flown())
	var dry_uncarried := int(dry_dipped.get_flown()) - int(dry_dipped.get_carried())
	var dry_unshown := int(dry_dipped.get_carried()) - int(dry_dipped.get_shown())
	var dry_unbroken := int(dry_dipped.get_shown()) - int(dry_dipped.get_broken())
	var dry_unstruck := int(dry_dipped.get_broken()) - int(dry_dipped.get_struck())
	var dry_undipped := int(dry_dipped.get_struck()) - int(dry_dipped.get_dipped())
	var kept_unpaid := int(dry_struck.get_hired()) - int(dry_struck.get_paid())
	var kept_unposted := int(dry_struck.get_paid()) - int(dry_struck.get_posted())
	if int(dry_dipped.get_dipped()) != 1 or int(dry_dipped.get_burgee_left()) != 0 or dry_undipped != 0 or int(dry_dipped.get_struck()) != 1 or int(dry_dipped.get_ensign_left()) != 0 or dry_unstruck != 0 or int(dry_dipped.get_broken()) != 1 or int(dry_dipped.get_jack_left()) != 0 or dry_unbroken != 0 or int(dry_dipped.get_shown()) != 1 or int(dry_dipped.get_standard_left()) != 0 or dry_unshown != 0 or int(dry_dipped.get_carried()) != 1 or dry_uncarried != 0 or int(dry_dipped.get_pennant_left()) != 0 or dry_unflown != 0 or dry_unhoisted != 0 or dry_unraised != 0 or int(dry_dipped.get_horn_left()) != 0 or int(dry_dipped.get_bell_left()) != 1 or dry_unrung != 1 or dry_unlit != 1 or dry_unstood != 2 or dry_unposted != kept_unposted or dry_unpaid != kept_unpaid or dry_unpaid != 2 or dry_unposted != 2 or int(dry_dipped.get_yard_left()) != 0 or int(dry_dipped.get_flown()) != 1 or int(dry_dipped.get_hoisted()) != 1 or int(dry_dipped.get_raised()) != 1 or int(dry_dipped.get_sounded()) != 1 or int(dry_dipped.get_rung()) != 2 or int(dry_dipped.get_lit()) != 3 or int(dry_dipped.get_stood()) != 4 or int(dry_dipped.get_posted()) != 6 or int(dry_dipped.get_wet_haul()) != 0 or int(dry_dipped.get_stored_salt()) != 1032 or int(dry_dipped.get_gate_left()) != 2 or int(dry_dipped.get_wage_left()) != 2 or int(dry_dipped.get_loft_left()) != 0 or int(dry_struck.get_burgee_left()) != 1:
		_fail(errors, "dry cornet changed the short crew (wet %d stored %d dipped %d burgee %d struck %d ensign %d broken %d jack %d shown %d standard %d carried %d pennant %d flown %d undipped %d unstruck %d unbroken %d unshown %d uncarried %d unflown %d unhoisted %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d yard %d)" % [dry_dipped.get_wet_haul(), dry_dipped.get_stored_salt(), dry_dipped.get_dipped(), dry_dipped.get_burgee_left(), dry_dipped.get_struck(), dry_dipped.get_ensign_left(), dry_dipped.get_broken(), dry_dipped.get_jack_left(), dry_dipped.get_shown(), dry_dipped.get_standard_left(), dry_dipped.get_carried(), dry_dipped.get_pennant_left(), dry_dipped.get_flown(), dry_undipped, dry_unstruck, dry_unbroken, dry_unshown, dry_uncarried, dry_unflown, dry_unhoisted, dry_unraised, dry_dipped.get_bell_left(), dry_unrung, dry_unlit, dry_unstood, dry_unposted, dry_unpaid, dry_dipped.get_yard_left()])
	var dry_cornet_cell = plans["dry_dipped"]["cornet"][0]
	var dry_burgee_cell = plans["dry_dipped"]["burgee"][0]
	var dry_cornet_salt: Dictionary = dry_dipped.get_cell_salt(int(dry_cornet_cell[0]), int(dry_cornet_cell[1]))
	var dry_burgee_salt: Dictionary = dry_dipped.get_cell_salt(int(dry_burgee_cell[0]), int(dry_burgee_cell[1]))
	if int(dry_cornet_salt.get("cornet", 0)) != 1 or int(dry_burgee_salt.get("burgee", 0)) != 0:
		_fail(errors, "dry cornet cell holds %s, burgee holds %s" % [dry_cornet_salt.get("cornet", 0), dry_burgee_salt.get("burgee", 0)])
	if not String(dry_dipped.get_summary()).contains("Dipped 1 on the cornet") or not String(dry_dipped.get_summary()).contains("Left 0 at the burgee") or not String(dry_dipped.get_summary()).contains("Struck 1 on the burgee") or not String(dry_dipped.get_summary()).contains("Left 0 in the yard"):
		_fail(errors, "dry cornet summary does not name the cap: %s" % dry_dipped.get_summary())
	_assert_pop(dipped, errors, "dipped plan")
	_assert_pop(dipped_again, errors, "dipped plan again")
	_assert_pop(late, errors, "late_dipped")
	_assert_pop(dry_dipped, errors, "dry_dipped")
	_assert_pop(no_cornet, errors, "no_cornet")
	_assert_pop(bare, errors, "cornet_only")
	var shore = _prepare_plan(plans, "dipped", errors)
	if shore == null:
		return
	var shore_guard := 0
	var shore_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + int(Sim.STANDARD_TICK) + int(Sim.JACK_TICK) + int(Sim.ENSIGN_TICK) + int(Sim.BURGEE_TICK) + 2
	while int(shore.get_beat()) != Sim.CORNETING and not shore.is_over() and shore_guard < shore_limit:
		shore.tick()
		shore_guard += 1
	if int(shore.get_beat()) != Sim.CORNETING or shore.is_over():
		_fail(errors, "the burgee beat did not open a cornet beat for the cap check")
		return
	if int(shore.get_ticks_until_rain()) != int(Sim.CORNET_TICK):
		_fail(errors, "cornet countdown started at %d, expected %d" % [shore.get_ticks_until_rain(), Sim.CORNET_TICK])
	if int(shore.get_dipped()) != 0 or int(shore.get_struck()) != 1 or int(shore.get_burgee_left()) != 1 or int(shore.get_broken()) != 1 or int(shore.get_ensign_left()) != 0 or int(shore.get_shown()) != 1 or int(shore.get_jack_left()) != 0 or int(shore.get_carried()) != 1 or int(shore.get_standard_left()) != 0 or int(shore.get_yard_left()) != 57 or int(shore.get_coins()) != 2997 or int(shore.get_stored_salt()) != 2997:
		_fail(errors, "cornet opened early (dipped %d struck %d burgee %d broken %d ensign %d shown %d jack %d carried %d yard %d coins %d stored %d)" % [shore.get_dipped(), shore.get_struck(), shore.get_burgee_left(), shore.get_broken(), shore.get_ensign_left(), shore.get_shown(), shore.get_jack_left(), shore.get_carried(), shore.get_yard_left(), shore.get_coins(), shore.get_stored_salt()])
	var saw_cap := false
	var dip_guard := 0
	while not shore.is_over() and dip_guard < int(Sim.CORNET_TICK) + 2:
		shore.tick()
		dip_guard += 1
		if int(shore.get_dipped()) == int(Sim.CORNET_CAP) and int(shore.get_burgee_left()) == 0 and int(shore.get_struck()) == 1 and int(shore.get_broken()) == 1 and int(shore.get_shown()) == 1 and int(shore.get_carried()) == 1 and int(shore.get_flown()) == 1 and int(shore.get_hoisted()) == 1 and int(shore.get_yard_left()) == 57 and int(shore.get_coins()) == 2997 and int(shore.get_hired()) == 29 and int(shore.get_ticks_until_rain()) > 0:
			saw_cap = true
			var ticks_left := int(shore.get_ticks_until_rain())
			shore.tick()
			if int(shore.get_dipped()) != int(Sim.CORNET_CAP) or int(shore.get_burgee_left()) != 0 or int(shore.get_struck()) != 1 or int(shore.get_broken()) != 1 or int(shore.get_shown()) != 1 or int(shore.get_carried()) != 1 or int(shore.get_flown()) != 1 or int(shore.get_hoisted()) != 1 or int(shore.get_raised()) != 1 or int(shore.get_yard_left()) != 57 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29 or int(shore.get_stored_salt()) != 2997 or int(shore.get_posted()) != 6 or int(shore.get_stood()) != 4 or int(shore.get_lit()) != 3 or int(shore.get_rung()) != 2 or int(shore.get_sounded()) != 1:
				_fail(errors, "the cornet kept dipping after the cap (dipped %d burgee %d struck %d broken %d shown %d carried %d yard %d)" % [shore.get_dipped(), shore.get_burgee_left(), shore.get_struck(), shore.get_broken(), shore.get_shown(), shore.get_carried(), shore.get_yard_left()])
			elif not shore.is_over() and int(shore.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the cornet beat did not spend a tick after the cap")
			break
	if not saw_cap:
		_fail(errors, "the cornet did not stop at %d while ticks remained (dipped %d burgee %d struck %d ticks %d)" % [Sim.CORNET_CAP, shore.get_dipped(), shore.get_burgee_left(), shore.get_struck(), shore.get_ticks_until_rain()])
	var end_guard := 0
	while int(shore.get_beat()) == Sim.CORNETING and not shore.is_over() and end_guard < int(Sim.CORNET_TICK) + 2:
		shore.tick()
		end_guard += 1
		if int(shore.get_dipped()) != 1 or int(shore.get_burgee_left()) != 0 or int(shore.get_struck()) != 1:
			_fail(errors, "the cornet dipped again after the cap (dipped %d burgee %d struck %d)" % [shore.get_dipped(), shore.get_burgee_left(), shore.get_struck()])
			break
	if shore.is_over() or int(shore.get_beat()) != Sim.GUIDONING:
		_fail(errors, "the cornet beat ended the scenario instead of opening the guidon")
	elif int(shore.get_dipped()) != 1 or int(shore.get_saluted()) != 0 or int(shore.get_cornet_left()) != 1:
		_fail(errors, "the cornet beat changed its dip count when the guidon opened (dipped %d saluted %d cornet %d)" % [shore.get_dipped(), shore.get_saluted(), shore.get_cornet_left()])
	var short = _prepare_plan(plans, "dry_dipped", errors)
	if short == null:
		return
	var short_guard := 0
	while int(short.get_beat()) != Sim.CORNETING and not short.is_over() and short_guard < shore_limit:
		short.tick()
		short_guard += 1
	if int(short.get_beat()) != Sim.CORNETING or short.is_over():
		_fail(errors, "the burgee beat did not open a cornet beat for the dry cap")
		return
	var saw_short := false
	var short_steps := 0
	while not short.is_over() and short_steps < int(Sim.CORNET_TICK) + 2:
		short.tick()
		short_steps += 1
		if int(short.get_dipped()) == int(Sim.CORNET_CAP) and int(short.get_burgee_left()) == 0 and int(short.get_struck()) == 1 and int(short.get_broken()) == 1 and int(short.get_shown()) == 1 and int(short.get_carried()) == 1 and int(short.get_flown()) == 1 and int(short.get_yard_left()) == 0 and int(short.get_wet_haul()) == 0 and int(short.get_ticks_until_rain()) > 0:
			saw_short = true
			var short_ticks := int(short.get_ticks_until_rain())
			short.tick()
			if int(short.get_dipped()) != 1 or int(short.get_burgee_left()) != 0 or int(short.get_struck()) != 1 or int(short.get_broken()) != 1 or int(short.get_shown()) != 1 or int(short.get_carried()) != 1 or int(short.get_flown()) != 1 or int(short.get_yard_left()) != 0 or int(short.get_posted()) != 6 or int(short.get_stored_salt()) != 1032:
				_fail(errors, "the cornet dipped an unstruck hire or passed the cap (dipped %d burgee %d struck %d yard %d)" % [short.get_dipped(), short.get_burgee_left(), short.get_struck(), short.get_yard_left()])
			elif not short.is_over() and int(short.get_ticks_until_rain()) >= short_ticks:
				_fail(errors, "the cornet beat did not spend a tick after the dry cap")
			break
	if not saw_short:
		_fail(errors, "dry cornet did not stop at 1 with the burgee clear (dipped %d burgee %d struck %d yard %d ticks %d)" % [short.get_dipped(), short.get_burgee_left(), short.get_struck(), short.get_yard_left(), short.get_ticks_until_rain()])
	print("dipped %d left burgee %d unstruck %d unbroken %d unshown %d uncarried %d unflown %d unhoisted %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d; dry dipped %d left burgee %d unstruck %d unbroken %d unshown %d uncarried %d unflown %d unhoisted %d unraised %d unsounded %d unrung %d unlit %d unstood %d unposted %d unpaid %d; no cornet dipped %d left burgee %d; cornet without burgee dipped %d" % [dipped.get_dipped(), dipped.get_burgee_left(), dipped_unstruck, dipped_unbroken, dipped_unshown, dipped_uncarried, dipped_unflown, dipped_unhoisted, dipped_unraised, dipped.get_bell_left(), dipped_unrung, dipped_unlit, dipped_unstood, dipped_unposted, dipped_unpaid, dry_dipped.get_dipped(), dry_dipped.get_burgee_left(), dry_unstruck, dry_unbroken, dry_unshown, dry_uncarried, dry_unflown, dry_unhoisted, dry_unraised, dry_dipped.get_bell_left(), dry_unrung, dry_unlit, dry_unstood, dry_unposted, dry_unpaid, no_cornet.get_dipped(), no_cornet.get_burgee_left(), bare.get_dipped()])


func _test_guidon(errors: Array) -> void:
	if int(Sim.GUIDON_TICK) != 100 or int(Sim.GUIDON_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "guidon beat length %s is not 100 ticks (10 seconds)" % Sim.GUIDON_TICK)
	if int(Sim.GUIDON_CAP) != 1:
		_fail(errors, "guidon cap is %s, expected 1" % Sim.GUIDON_CAP)
	if int(Sim.CORNET_CAP) != 1:
		_fail(errors, "cornet cap changed to %s" % Sim.CORNET_CAP)
	if int(Sim.GRID_NORTH) > -17:
		_fail(errors, "the map was not extended to the guidon row (north %s)" % Sim.GRID_NORTH)
	if int(Sim.GUIDON_CELL.x) != 14 or int(Sim.GUIDON_CELL.y) != -17:
		_fail(errors, "the guidon cell is not at 14,-17")
	if int(Sim.CORNET_CELL.x) != 14 or int(Sim.CORNET_CELL.y) != -16:
		_fail(errors, "the cornet moved off 14,-16")
	if int(Sim.BURGEE_CELL.x) != 14 or int(Sim.BURGEE_CELL.y) != -15:
		_fail(errors, "the burgee moved off 14,-15")
	if int(Sim.ENSIGN_CELL.x) != 14 or int(Sim.ENSIGN_CELL.y) != -14:
		_fail(errors, "the ensign moved off 14,-14")
	if int(Sim.JACK_CELL.x) != 14 or int(Sim.JACK_CELL.y) != -13:
		_fail(errors, "the jack moved off 14,-13")
	if int(Sim.STANDARD_CELL.x) != 14 or int(Sim.STANDARD_CELL.y) != -12:
		_fail(errors, "the standard moved off 14,-12")
	if int(Sim.PENNANT_CELL.x) != 14 or int(Sim.PENNANT_CELL.y) != -11:
		_fail(errors, "the pennant moved off 14,-11")
	var fresh = Sim.new()
	if fresh.paint_cell(14, -17, Sim.GUIDON) == false or int(fresh.get_paint(14, -17)) != Sim.GUIDON:
		_fail(errors, "the cell north of the cornet rejected the guidon mark")
	if fresh.paint_cell(14, -16, Sim.GUIDON):
		_fail(errors, "the cornet cell accepted a guidon")
	if int(fresh.get_paint(14, -16)) != Sim.EMPTY:
		_fail(errors, "a rejected guidon painted the cornet cell")
	if fresh.paint_cell(14, -17, Sim.CORNET):
		_fail(errors, "the guidon cell accepted a cornet")
	if int(fresh.get_paint(14, -17)) != Sim.GUIDON:
		_fail(errors, "a rejected cornet erased the guidon")
	if fresh.paint_cell(14, -16, Sim.CORNET) == false or int(fresh.get_paint(14, -16)) != Sim.CORNET:
		_fail(errors, "the cornet cell no longer accepts a cornet")
	if fresh.paint_cell(14, -15, Sim.BURGEE) == false or int(fresh.get_paint(14, -15)) != Sim.BURGEE:
		_fail(errors, "the burgee cell no longer accepts a burgee")
	if fresh.paint_cell(14, -14, Sim.ENSIGN) == false or int(fresh.get_paint(14, -14)) != Sim.ENSIGN:
		_fail(errors, "the ensign cell no longer accepts an ensign")
	if fresh.paint_cell(14, -13, Sim.JACK) == false or int(fresh.get_paint(14, -13)) != Sim.JACK:
		_fail(errors, "the jack cell no longer accepts a jack")
	if fresh.paint_cell(14, -12, Sim.STANDARD) == false or int(fresh.get_paint(14, -12)) != Sim.STANDARD:
		_fail(errors, "the standard cell no longer accepts a standard")
	if fresh.paint_cell(14, -11, Sim.PENNANT) == false or int(fresh.get_paint(14, -11)) != Sim.PENNANT:
		_fail(errors, "the pennant cell no longer accepts a pennant")
	if fresh.paint_cell(14, -10, Sim.BANNER) == false or int(fresh.get_paint(14, -10)) != Sim.BANNER:
		_fail(errors, "the banner cell no longer accepts a banner")
	if fresh.paint_cell(14, -9, Sim.FLAG) == false or int(fresh.get_paint(14, -9)) != Sim.FLAG:
		_fail(errors, "the flag cell no longer accepts a flag")
	if fresh.paint_cell(14, -18, Sim.GUIDON) or fresh.paint_cell(13, -17, Sim.GUIDON) or fresh.paint_cell(15, -17, Sim.GUIDON) or fresh.paint_cell(14, -16, Sim.GUIDON) or fresh.paint_cell(14, -15, Sim.GUIDON):
		_fail(errors, "a cell other than 14,-17 accepted a guidon")
	if int(fresh.get_paint(14, -16)) != Sim.CORNET:
		_fail(errors, "a rejected guidon erased the cornet")
	if fresh.paint_cell(Sim.COAST_X, -17, Sim.GUIDON):
		_fail(errors, "the brine accepted a guidon")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.GUIDON):
		_fail(errors, "the anthill accepted a guidon")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var won = _run_plan(plans, "winning", errors)
	var dry = _run_plan(plans, "dry_pans", errors)
	var dipped = _run_plan(plans, "dipped", errors)
	var no_guidon = _run_plan(plans, "no_guidon", errors)
	var bare = _run_plan(plans, "guidon_only", errors)
	var struck_shore = _run_plan(plans, "no_cornet", errors)
	var saluted = _run_plan(plans, "saluted", errors)
	var saluted_again = _run_plan(plans, "saluted", errors)
	var late = _run_plan(plans, "late_saluted", errors)
	var dry_saluted = _run_plan(plans, "dry_saluted", errors)
	if won == null or dry == null or dipped == null or no_guidon == null or bare == null or struck_shore == null or saluted == null or saluted_again == null or late == null or dry_saluted == null:
		return
	if int(won.get_saluted()) != 0 or int(dry.get_saluted()) != 0 or int(dipped.get_saluted()) != 0:
		_fail(errors, "a plan with no guidon saluted someone (winning %d dry %d dipped %d)" % [won.get_saluted(), dry.get_saluted(), dipped.get_saluted()])
	if String(dipped.get_summary()) != String(no_guidon.get_summary()):
		_fail(errors, "a cornet with no guidon changed the dipped summary: %s" % no_guidon.get_summary())
	if String(no_guidon.get_summary()).to_lower().contains("saluted") or String(no_guidon.get_summary()).to_lower().contains("guidon"):
		_fail(errors, "a cornet with no guidon names a guidon: %s" % no_guidon.get_summary())
	var no_unpaid := int(no_guidon.get_hired()) - int(no_guidon.get_paid())
	var no_unposted := int(no_guidon.get_paid()) - int(no_guidon.get_posted())
	var no_unstood := int(no_guidon.get_posted()) - int(no_guidon.get_stood())
	var no_unlit := int(no_guidon.get_stood()) - int(no_guidon.get_lit())
	var no_unrung := int(no_guidon.get_lit()) - int(no_guidon.get_rung())
	if int(no_guidon.get_saluted()) != 0 or int(no_guidon.get_cornet_left()) != 1 or int(no_guidon.get_dipped()) != 1 or int(no_guidon.get_burgee_left()) != 0 or int(no_guidon.get_struck()) != 1 or int(no_guidon.get_ensign_left()) != 0 or int(no_guidon.get_broken()) != 1 or int(no_guidon.get_jack_left()) != 0 or int(no_guidon.get_shown()) != 1 or int(no_guidon.get_standard_left()) != 0 or int(no_guidon.get_carried()) != 1 or int(no_guidon.get_pennant_left()) != 0 or int(no_guidon.get_flown()) != 1 or int(no_guidon.get_banner_left()) != 0 or int(no_guidon.get_hoisted()) != 1 or int(no_guidon.get_flag_left()) != 0 or int(no_guidon.get_raised()) != 1 or int(no_guidon.get_horn_left()) != 0 or int(no_guidon.get_sounded()) != 1 or int(no_guidon.get_bell_left()) != 1 or no_unrung != 1 or no_unlit != 1 or no_unstood != 2 or no_unposted != 4 or no_unpaid != 19 or int(no_guidon.get_yard_left()) != 57 or int(no_guidon.get_coins()) != 2997 or int(no_guidon.get_hired()) != 29 or int(no_guidon.get_stored_salt()) != 2997:
		_fail(errors, "a cornet with no guidon saluted someone (saluted %d cornet %d dipped %d struck %d yard %d coins %d hired %d)" % [no_guidon.get_saluted(), no_guidon.get_cornet_left(), no_guidon.get_dipped(), no_guidon.get_struck(), no_guidon.get_yard_left(), no_guidon.get_coins(), no_guidon.get_hired()])
	var kept_cornet = plans["no_guidon"]["cornet"][0]
	var kept_salt: Dictionary = no_guidon.get_cell_salt(int(kept_cornet[0]), int(kept_cornet[1]))
	var kept_north: Dictionary = no_guidon.get_cell_salt(int(kept_cornet[0]), int(kept_cornet[1]) - 1)
	if int(kept_salt.get("cornet", 0)) != 1 or int(kept_north.get("guidon", 0)) != 0 or int(kept_salt.get("guidon", 0)) != 0:
		_fail(errors, "a cornet with no guidon left %s on the cornet and %s on a guidon" % [kept_salt.get("cornet", 0), kept_north.get("guidon", 0)])
	if String(bare.get_summary()) != String(struck_shore.get_summary()):
		_fail(errors, "a guidon with no cornet changed the struck summary: %s" % bare.get_summary())
	if String(bare.get_summary()).to_lower().contains("saluted") or String(bare.get_summary()).to_lower().contains("guidon") or String(bare.get_summary()).to_lower().contains("dipped") or String(bare.get_summary()).to_lower().contains("cornet"):
		_fail(errors, "a guidon with no cornet names a guidon: %s" % bare.get_summary())
	if int(bare.get_saluted()) != 0 or int(bare.get_dipped()) != 0 or int(bare.get_cornet_left()) != 0 or int(bare.get_struck()) != 1 or int(bare.get_burgee_left()) != 1 or int(bare.get_broken()) != 1 or int(bare.get_ensign_left()) != 0 or int(bare.get_yard_left()) != 57 or int(bare.get_coins()) != 2997 or int(bare.get_hired()) != 29:
		_fail(errors, "a guidon with no cornet saluted someone (saluted %d dipped %d struck %d burgee %d)" % [bare.get_saluted(), bare.get_dipped(), bare.get_struck(), bare.get_burgee_left()])
	var bare_guidon = plans["guidon_only"]["guidon"][0]
	var bare_burgee = plans["guidon_only"]["burgee"][0]
	var bare_guidon_salt: Dictionary = bare.get_cell_salt(int(bare_guidon[0]), int(bare_guidon[1]))
	var bare_burgee_salt: Dictionary = bare.get_cell_salt(int(bare_burgee[0]), int(bare_burgee[1]))
	if int(bare_guidon_salt.get("guidon", 0)) != 0 or int(bare_burgee_salt.get("burgee", 0)) != 1 or int(bare_guidon_salt.get("cornet", 0)) != 0:
		_fail(errors, "guidon without a cornet holds %s, burgee holds %s" % [bare_guidon_salt.get("guidon", 0), bare_burgee_salt.get("burgee", 0)])
	var guidon_cell = plans["saluted"]["guidon"][0]
	var cornet_cell = plans["saluted"]["cornet"][0]
	var burgee_cell = plans["saluted"]["burgee"][0]
	var ensign_cell = plans["saluted"]["ensign"][0]
	var jack_cell = plans["saluted"]["jack"][0]
	var standard_cell = plans["saluted"]["standard"][0]
	var pennant_cell = plans["saluted"]["pennant"][0]
	var banner_cell = plans["saluted"]["banner"][0]
	var flag_cell = plans["saluted"]["flag"][0]
	if int(guidon_cell[0]) != int(cornet_cell[0]) or int(guidon_cell[1]) != int(cornet_cell[1]) - 1:
		_fail(errors, "saluted plan's guidon is not one cell north of the cornet")
	if int(guidon_cell[0]) != 14 or int(guidon_cell[1]) != -17 or int(cornet_cell[0]) != 14 or int(cornet_cell[1]) != -16 or int(burgee_cell[0]) != 14 or int(burgee_cell[1]) != -15 or int(ensign_cell[0]) != 14 or int(ensign_cell[1]) != -14 or int(jack_cell[0]) != 14 or int(jack_cell[1]) != -13 or int(standard_cell[0]) != 14 or int(standard_cell[1]) != -12 or int(pennant_cell[0]) != 14 or int(pennant_cell[1]) != -11 or int(banner_cell[0]) != 14 or int(banner_cell[1]) != -10 or int(flag_cell[0]) != 14 or int(flag_cell[1]) != -9:
		_fail(errors, "saluted plan moved the guidon, the cornet, the burgee, the ensign, the jack, the standard, the pennant, the banner, or the flag")
	_assert_chain(saluted, errors, "saluted plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
	var saluted_unpaid := int(saluted.get_hired()) - int(saluted.get_paid())
	var saluted_unposted := int(saluted.get_paid()) - int(saluted.get_posted())
	var saluted_unstood := int(saluted.get_posted()) - int(saluted.get_stood())
	var saluted_unlit := int(saluted.get_stood()) - int(saluted.get_lit())
	var saluted_unrung := int(saluted.get_lit()) - int(saluted.get_rung())
	var saluted_unsaluted := int(saluted.get_dipped()) - int(saluted.get_saluted())
	if int(saluted.get_saluted()) != 1 or int(saluted.get_cornet_left()) != 0 or saluted_unsaluted != 0 or int(saluted.get_dipped()) != 1 or int(saluted.get_burgee_left()) != 0 or int(saluted.get_struck()) != 1 or int(saluted.get_broken()) != 1 or int(saluted.get_shown()) != 1 or int(saluted.get_carried()) != 1 or int(saluted.get_flown()) != 1 or int(saluted.get_hoisted()) != 1 or int(saluted.get_raised()) != 1 or int(saluted.get_sounded()) != 1 or int(saluted.get_rung()) != 2 or int(saluted.get_lit()) != 3 or int(saluted.get_stood()) != 4 or int(saluted.get_posted()) != 6 or saluted_unrung != 1 or saluted_unlit != 1 or saluted_unstood != 2 or saluted_unposted != 4 or saluted_unpaid != 19 or int(saluted.get_yard_left()) != 57 or int(saluted.get_coins()) != 2997 or int(saluted.get_hired()) != 29 or int(saluted.get_stored_salt()) != int(dipped.get_stored_salt()) or int(saluted.get_carted()) != int(dipped.get_carted()) or int(saluted.get_shipped()) != int(dipped.get_shipped()) or int(saluted.get_wet_haul()) != int(dipped.get_wet_haul()):
		_fail(errors, "saluted %d, left %d dipped unsaluted, dipped %d, struck %d, unpaid %d, cornet %d, yard %d, coins %d, hired %d" % [saluted.get_saluted(), saluted.get_cornet_left(), saluted.get_dipped(), saluted.get_struck(), saluted_unpaid, saluted.get_cornet_left(), saluted.get_yard_left(), saluted.get_coins(), saluted.get_hired()])
	if int(saluted.get_saluted()) > int(Sim.GUIDON_CAP):
		_fail(errors, "guidon saluted %d, over the cap of %d" % [saluted.get_saluted(), Sim.GUIDON_CAP])
	var guidon_salt: Dictionary = saluted.get_cell_salt(int(guidon_cell[0]), int(guidon_cell[1]))
	var cornet_salt: Dictionary = saluted.get_cell_salt(int(cornet_cell[0]), int(cornet_cell[1]))
	var burgee_salt: Dictionary = saluted.get_cell_salt(int(burgee_cell[0]), int(burgee_cell[1]))
	if int(guidon_salt.get("guidon", 0)) != 1 or int(cornet_salt.get("cornet", 0)) != 0 or int(burgee_salt.get("burgee", 0)) != 0 or int(guidon_salt.get("cornet", 0)) != 0:
		_fail(errors, "guidon cell holds %s, cornet holds %s, burgee holds %s" % [guidon_salt.get("guidon", 0), cornet_salt.get("cornet", 0), burgee_salt.get("burgee", 0)])
	var saluted_summary := String(saluted.get_summary())
	if not saluted_summary.contains("Saluted 1 on the guidon") or not saluted_summary.contains("Left 0 at the cornet") or not saluted_summary.contains("Dipped 1 on the cornet") or not saluted_summary.contains("Struck 1 on the burgee") or not saluted_summary.contains("Coins 2997") or not saluted_summary.contains("Hired 29") or not saluted_summary.contains("Left 57"):
		_fail(errors, "saluted summary does not name the guidon: %s" % saluted_summary)
	if int(saluted_again.get_saluted()) != int(saluted.get_saluted()) or int(saluted_again.get_cornet_left()) != int(saluted.get_cornet_left()) or int(saluted_again.get_dipped()) != int(saluted.get_dipped()) or int(saluted_again.get_yard_left()) != int(saluted.get_yard_left()) or int(saluted_again.get_stored_salt()) != int(saluted.get_stored_salt()) or String(saluted_again.get_summary()) != String(saluted.get_summary()):
		_fail(errors, "repeated guidon paint saluted %d and left cornet %d, then saluted %d and left cornet %d" % [saluted.get_saluted(), saluted.get_cornet_left(), saluted_again.get_saluted(), saluted_again.get_cornet_left()])
	if int(late.get_saluted()) != 1 or int(late.get_cornet_left()) != 0 or int(late.get_dipped()) != 1 or int(late.get_struck()) != 1 or int(late.get_broken()) != 1 or int(late.get_shown()) != 1 or int(late.get_carried()) != 1 or int(late.get_yard_left()) != 57 or int(late.get_hired()) != 29 or int(late.get_coins()) != 2997 or int(late.get_stored_salt()) != 2997:
		_fail(errors, "painting the guidon at the guidon beat (saluted %d cornet %d dipped %d yard %d) did not match painting it early (saluted %d cornet %d dipped %d)" % [late.get_saluted(), late.get_cornet_left(), late.get_dipped(), late.get_yard_left(), saluted.get_saluted(), saluted.get_cornet_left(), saluted.get_dipped()])
	_assert_chain(dry_saluted, errors, "dry guidon", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
	var dry_dipped = _run_plan(plans, "dry_dipped", errors)
	if dry_dipped == null:
		return
	var dry_unpaid := int(dry_saluted.get_hired()) - int(dry_saluted.get_paid())
	var dry_unposted := int(dry_saluted.get_paid()) - int(dry_saluted.get_posted())
	var kept_unpaid := int(dry_dipped.get_hired()) - int(dry_dipped.get_paid())
	var kept_unposted := int(dry_dipped.get_paid()) - int(dry_dipped.get_posted())
	if int(dry_saluted.get_saluted()) != 1 or int(dry_saluted.get_cornet_left()) != 0 or int(dry_saluted.get_dipped()) != 1 or int(dry_saluted.get_struck()) != 1 or int(dry_saluted.get_yard_left()) != 0 or int(dry_saluted.get_wet_haul()) != 0 or int(dry_saluted.get_stored_salt()) != 1032 or dry_unpaid != kept_unpaid or dry_unposted != kept_unposted or dry_unpaid != 2 or dry_unposted != 2 or int(dry_dipped.get_cornet_left()) != 1 or int(dry_dipped.get_saluted()) != 0:
		_fail(errors, "dry guidon changed the short crew (wet %d stored %d saluted %d cornet %d dipped %d struck %d unpaid %d unposted %d yard %d)" % [dry_saluted.get_wet_haul(), dry_saluted.get_stored_salt(), dry_saluted.get_saluted(), dry_saluted.get_cornet_left(), dry_saluted.get_dipped(), dry_saluted.get_struck(), dry_unpaid, dry_unposted, dry_saluted.get_yard_left()])
	var dry_guidon_cell = plans["dry_saluted"]["guidon"][0]
	var dry_cornet_cell = plans["dry_saluted"]["cornet"][0]
	var dry_guidon_salt: Dictionary = dry_saluted.get_cell_salt(int(dry_guidon_cell[0]), int(dry_guidon_cell[1]))
	var dry_cornet_salt: Dictionary = dry_saluted.get_cell_salt(int(dry_cornet_cell[0]), int(dry_cornet_cell[1]))
	if int(dry_guidon_salt.get("guidon", 0)) != 1 or int(dry_cornet_salt.get("cornet", 0)) != 0:
		_fail(errors, "dry guidon cell holds %s, cornet holds %s" % [dry_guidon_salt.get("guidon", 0), dry_cornet_salt.get("cornet", 0)])
	if not String(dry_saluted.get_summary()).contains("Saluted 1 on the guidon") or not String(dry_saluted.get_summary()).contains("Left 0 at the cornet") or not String(dry_saluted.get_summary()).contains("Dipped 1 on the cornet") or not String(dry_saluted.get_summary()).contains("Left 0 in the yard"):
		_fail(errors, "dry guidon summary does not name the cap: %s" % dry_saluted.get_summary())
	_assert_pop(saluted, errors, "saluted plan")
	_assert_pop(saluted_again, errors, "saluted plan again")
	_assert_pop(late, errors, "late_saluted")
	_assert_pop(dry_saluted, errors, "dry_saluted")
	_assert_pop(no_guidon, errors, "no_guidon")
	_assert_pop(bare, errors, "guidon_only")
	var shore = _prepare_plan(plans, "saluted", errors)
	if shore == null:
		return
	var shore_guard := 0
	var shore_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + int(Sim.STANDARD_TICK) + int(Sim.JACK_TICK) + int(Sim.ENSIGN_TICK) + int(Sim.BURGEE_TICK) + int(Sim.CORNET_TICK) + 2
	while int(shore.get_beat()) != Sim.GUIDONING and not shore.is_over() and shore_guard < shore_limit:
		shore.tick()
		shore_guard += 1
	if int(shore.get_beat()) != Sim.GUIDONING or shore.is_over():
		_fail(errors, "the cornet beat did not open a guidon beat for the cap check")
		return
	if int(shore.get_ticks_until_rain()) != int(Sim.GUIDON_TICK):
		_fail(errors, "guidon countdown started at %d, expected %d" % [shore.get_ticks_until_rain(), Sim.GUIDON_TICK])
	if int(shore.get_saluted()) != 0 or int(shore.get_dipped()) != 1 or int(shore.get_cornet_left()) != 1 or int(shore.get_struck()) != 1 or int(shore.get_burgee_left()) != 0 or int(shore.get_yard_left()) != 57 or int(shore.get_coins()) != 2997 or int(shore.get_stored_salt()) != 2997 or int(shore.get_hired()) != 29:
		_fail(errors, "guidon opened early (saluted %d dipped %d cornet %d struck %d yard %d coins %d stored %d)" % [shore.get_saluted(), shore.get_dipped(), shore.get_cornet_left(), shore.get_struck(), shore.get_yard_left(), shore.get_coins(), shore.get_stored_salt()])
	var saw_cap := false
	var salute_guard := 0
	while not shore.is_over() and salute_guard < int(Sim.GUIDON_TICK) + 2:
		shore.tick()
		salute_guard += 1
		if int(shore.get_saluted()) == int(Sim.GUIDON_CAP) and int(shore.get_cornet_left()) == 0 and int(shore.get_dipped()) == 1 and int(shore.get_struck()) == 1 and int(shore.get_yard_left()) == 57 and int(shore.get_coins()) == 2997 and int(shore.get_hired()) == 29 and int(shore.get_ticks_until_rain()) > 0:
			saw_cap = true
			var ticks_left := int(shore.get_ticks_until_rain())
			shore.tick()
			if int(shore.get_saluted()) != int(Sim.GUIDON_CAP) or int(shore.get_cornet_left()) != 0 or int(shore.get_dipped()) != 1 or int(shore.get_struck()) != 1 or int(shore.get_broken()) != 1 or int(shore.get_yard_left()) != 57 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29 or int(shore.get_stored_salt()) != 2997 or int(shore.get_posted()) != 6:
				_fail(errors, "the guidon kept saluting after the cap (saluted %d cornet %d dipped %d struck %d yard %d)" % [shore.get_saluted(), shore.get_cornet_left(), shore.get_dipped(), shore.get_struck(), shore.get_yard_left()])
			elif not shore.is_over() and int(shore.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the guidon beat did not spend a tick after the cap")
			break
	if not saw_cap:
		_fail(errors, "the guidon did not stop at %d while ticks remained (saluted %d cornet %d dipped %d ticks %d)" % [Sim.GUIDON_CAP, shore.get_saluted(), shore.get_cornet_left(), shore.get_dipped(), shore.get_ticks_until_rain()])
	var end_guard := 0
	while int(shore.get_beat()) == Sim.GUIDONING and end_guard < int(Sim.GUIDON_TICK) + 2:
		shore.tick()
		end_guard += 1
		if int(shore.get_saluted()) != 1 or int(shore.get_cornet_left()) != 0 or int(shore.get_dipped()) != 1:
			_fail(errors, "the guidon saluted again after the cap (saluted %d cornet %d dipped %d)" % [shore.get_saluted(), shore.get_cornet_left(), shore.get_dipped()])
			break
	if shore.is_over() or int(shore.get_beat()) != Sim.FANIONING:
		_fail(errors, "the guidon beat ended the scenario instead of opening the fanion")
	elif int(shore.get_saluted()) != 1 or int(shore.get_presented()) != 0 or int(shore.get_guidon_left()) != 1 or int(shore.get_cornet_left()) != 0:
		_fail(errors, "a guidon with no fanion presented a hire (presented %d guidon %d saluted %d)" % [shore.get_presented(), shore.get_guidon_left(), shore.get_saluted()])
	var short = _prepare_plan(plans, "dry_saluted", errors)
	if short == null:
		return
	var short_guard := 0
	while int(short.get_beat()) != Sim.GUIDONING and not short.is_over() and short_guard < shore_limit:
		short.tick()
		short_guard += 1
	if int(short.get_beat()) != Sim.GUIDONING or short.is_over():
		_fail(errors, "the cornet beat did not open a guidon beat for the dry cap")
		return
	var saw_short := false
	var short_steps := 0
	while not short.is_over() and short_steps < int(Sim.GUIDON_TICK) + 2:
		short.tick()
		short_steps += 1
		if int(short.get_saluted()) == int(Sim.GUIDON_CAP) and int(short.get_cornet_left()) == 0 and int(short.get_dipped()) == 1 and int(short.get_struck()) == 1 and int(short.get_yard_left()) == 0 and int(short.get_wet_haul()) == 0 and int(short.get_ticks_until_rain()) > 0:
			saw_short = true
			var short_ticks := int(short.get_ticks_until_rain())
			short.tick()
			if int(short.get_saluted()) != 1 or int(short.get_cornet_left()) != 0 or int(short.get_dipped()) != 1 or int(short.get_struck()) != 1 or int(short.get_yard_left()) != 0 or int(short.get_posted()) != 6 or int(short.get_stored_salt()) != 1032:
				_fail(errors, "the guidon saluted an undipped hire or passed the cap (saluted %d cornet %d dipped %d yard %d)" % [short.get_saluted(), short.get_cornet_left(), short.get_dipped(), short.get_yard_left()])
			elif not short.is_over() and int(short.get_ticks_until_rain()) >= short_ticks:
				_fail(errors, "the guidon beat did not spend a tick after the dry cap")
			break
	if not saw_short:
		_fail(errors, "dry guidon did not stop at 1 with the cornet clear (saluted %d cornet %d dipped %d yard %d ticks %d)" % [short.get_saluted(), short.get_cornet_left(), short.get_dipped(), short.get_yard_left(), short.get_ticks_until_rain()])
	print("saluted %d left cornet %d undipped %d unstruck %d unpaid %d; dry saluted %d left cornet %d undipped %d unpaid %d; no guidon saluted %d left cornet %d; guidon without cornet saluted %d" % [saluted.get_saluted(), saluted.get_cornet_left(), saluted_unsaluted, int(saluted.get_broken()) - int(saluted.get_struck()), saluted_unpaid, dry_saluted.get_saluted(), dry_saluted.get_cornet_left(), int(dry_saluted.get_struck()) - int(dry_saluted.get_dipped()), dry_unpaid, no_guidon.get_saluted(), no_guidon.get_cornet_left(), bare.get_saluted()])



func _test_fanion(errors: Array) -> void:
	if int(Sim.FANION_TICK) != 100 or int(Sim.FANION_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "fanion beat length %s is not 100 ticks (10 seconds)" % Sim.FANION_TICK)
	if int(Sim.FANION_CAP) != 1:
		_fail(errors, "fanion cap is %s, expected 1" % Sim.FANION_CAP)
	if int(Sim.GUIDON_CAP) != 1:
		_fail(errors, "guidon cap changed to %s" % Sim.GUIDON_CAP)
	if int(Sim.GRID_NORTH) > -18:
		_fail(errors, "the map was not extended to the fanion row (north %s)" % Sim.GRID_NORTH)
	if int(Sim.FANION_CELL.x) != 14 or int(Sim.FANION_CELL.y) != -18:
		_fail(errors, "the fanion cell is not at 14,-18")
	if int(Sim.GUIDON_CELL.x) != 14 or int(Sim.GUIDON_CELL.y) != -17:
		_fail(errors, "the guidon moved off 14,-17")
	if int(Sim.CORNET_CELL.x) != 14 or int(Sim.CORNET_CELL.y) != -16:
		_fail(errors, "the cornet moved off 14,-16")
	if int(Sim.BURGEE_CELL.x) != 14 or int(Sim.BURGEE_CELL.y) != -15:
		_fail(errors, "the burgee moved off 14,-15")
	var fresh = Sim.new()
	if fresh.paint_cell(14, -18, Sim.FANION) == false or int(fresh.get_paint(14, -18)) != Sim.FANION:
		_fail(errors, "the cell north of the guidon rejected the fanion mark")
	if fresh.paint_cell(14, -17, Sim.FANION):
		_fail(errors, "the guidon cell accepted a fanion")
	if int(fresh.get_paint(14, -17)) != Sim.EMPTY:
		_fail(errors, "a rejected fanion painted the guidon cell")
	if fresh.paint_cell(14, -18, Sim.GUIDON):
		_fail(errors, "the fanion cell accepted a guidon")
	if int(fresh.get_paint(14, -18)) != Sim.FANION:
		_fail(errors, "a rejected guidon erased the fanion")
	if fresh.paint_cell(14, -17, Sim.GUIDON) == false or int(fresh.get_paint(14, -17)) != Sim.GUIDON:
		_fail(errors, "the guidon cell no longer accepts a guidon")
	if fresh.paint_cell(14, -16, Sim.CORNET) == false or int(fresh.get_paint(14, -16)) != Sim.CORNET:
		_fail(errors, "the cornet cell no longer accepts a cornet")
	if fresh.paint_cell(14, -15, Sim.BURGEE) == false or int(fresh.get_paint(14, -15)) != Sim.BURGEE:
		_fail(errors, "the burgee cell no longer accepts a burgee")
	if fresh.paint_cell(14, -19, Sim.FANION) or fresh.paint_cell(13, -18, Sim.FANION) or fresh.paint_cell(15, -18, Sim.FANION) or fresh.paint_cell(14, -17, Sim.FANION) or fresh.paint_cell(14, -16, Sim.FANION):
		_fail(errors, "a cell other than 14,-18 accepted a fanion")
	if int(fresh.get_paint(14, -17)) != Sim.GUIDON:
		_fail(errors, "a rejected fanion erased the guidon")
	if fresh.paint_cell(Sim.COAST_X, -18, Sim.FANION):
		_fail(errors, "the brine accepted a fanion")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.FANION):
		_fail(errors, "the anthill accepted a fanion")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var won = _run_plan(plans, "winning", errors)
	var dry = _run_plan(plans, "dry_pans", errors)
	var saluted = _run_plan(plans, "saluted", errors)
	var no_fanion = _run_plan(plans, "no_fanion", errors)
	var bare = _run_plan(plans, "fanion_only", errors)
	var dipped_shore = _run_plan(plans, "no_guidon", errors)
	var presented = _run_plan(plans, "presented", errors)
	var presented_again = _run_plan(plans, "presented", errors)
	var late = _run_plan(plans, "late_presented", errors)
	var dry_presented = _run_plan(plans, "dry_presented", errors)
	if won == null or dry == null or saluted == null or no_fanion == null or bare == null or dipped_shore == null or presented == null or presented_again == null or late == null or dry_presented == null:
		return
	if int(won.get_presented()) != 0 or int(dry.get_presented()) != 0 or int(saluted.get_presented()) != 0:
		_fail(errors, "a plan with no fanion presented someone (winning %d dry %d saluted %d)" % [won.get_presented(), dry.get_presented(), saluted.get_presented()])
	if String(saluted.get_summary()) != String(no_fanion.get_summary()):
		_fail(errors, "a guidon with no fanion changed the saluted summary: %s" % no_fanion.get_summary())
	if String(no_fanion.get_summary()).to_lower().contains("presented") or String(no_fanion.get_summary()).to_lower().contains("fanion"):
		_fail(errors, "a guidon with no fanion names a fanion: %s" % no_fanion.get_summary())
	if not String(no_fanion.get_summary()).contains("Saluted 1 on the guidon") or not String(no_fanion.get_summary()).contains("Left 0 at the cornet"):
		_fail(errors, "a guidon with no fanion dropped the guidon clause: %s" % no_fanion.get_summary())
	if int(no_fanion.get_presented()) != 0 or int(no_fanion.get_guidon_left()) != 1 or int(no_fanion.get_saluted()) != 1 or int(no_fanion.get_cornet_left()) != 0 or int(no_fanion.get_dipped()) != 1 or int(no_fanion.get_yard_left()) != 57 or int(no_fanion.get_coins()) != 2997 or int(no_fanion.get_hired()) != 29 or int(no_fanion.get_stored_salt()) != 2997:
		_fail(errors, "a guidon with no fanion presented someone (presented %d guidon %d saluted %d yard %d coins %d hired %d)" % [no_fanion.get_presented(), no_fanion.get_guidon_left(), no_fanion.get_saluted(), no_fanion.get_yard_left(), no_fanion.get_coins(), no_fanion.get_hired()])
	var kept_guidon = plans["no_fanion"]["guidon"][0]
	var kept_salt: Dictionary = no_fanion.get_cell_salt(int(kept_guidon[0]), int(kept_guidon[1]))
	var kept_north: Dictionary = no_fanion.get_cell_salt(int(kept_guidon[0]), int(kept_guidon[1]) - 1)
	if int(kept_salt.get("guidon", 0)) != 1 or int(kept_north.get("fanion", 0)) != 0 or int(kept_salt.get("fanion", 0)) != 0:
		_fail(errors, "a guidon with no fanion left %s on the guidon and %s on a fanion" % [kept_salt.get("guidon", 0), kept_north.get("fanion", 0)])
	if String(bare.get_summary()) != String(dipped_shore.get_summary()):
		_fail(errors, "a fanion with nobody saluted changed the dipped summary: %s" % bare.get_summary())
	if String(bare.get_summary()).to_lower().contains("presented") or String(bare.get_summary()).to_lower().contains("fanion") or String(bare.get_summary()).to_lower().contains("saluted") or String(bare.get_summary()).to_lower().contains("guidon"):
		_fail(errors, "a fanion with nobody saluted names a fanion: %s" % bare.get_summary())
	if not String(bare.get_summary()).contains("Dipped 1 on the cornet"):
		_fail(errors, "a fanion with nobody saluted dropped the cornet clause: %s" % bare.get_summary())
	if int(bare.get_presented()) != 0 or int(bare.get_saluted()) != 0 or int(bare.get_guidon_left()) != 0 or int(bare.get_dipped()) != 1 or int(bare.get_cornet_left()) != 1 or int(bare.get_yard_left()) != 57 or int(bare.get_coins()) != 2997 or int(bare.get_hired()) != 29:
		_fail(errors, "a fanion with nobody saluted presented someone (presented %d saluted %d dipped %d cornet %d)" % [bare.get_presented(), bare.get_saluted(), bare.get_dipped(), bare.get_cornet_left()])
	var bare_fanion = plans["fanion_only"]["fanion"][0]
	var bare_cornet = plans["fanion_only"]["cornet"][0]
	var bare_fanion_salt: Dictionary = bare.get_cell_salt(int(bare_fanion[0]), int(bare_fanion[1]))
	var bare_cornet_salt: Dictionary = bare.get_cell_salt(int(bare_cornet[0]), int(bare_cornet[1]))
	if int(bare_fanion_salt.get("fanion", 0)) != 0 or int(bare_cornet_salt.get("cornet", 0)) != 1 or int(bare_fanion_salt.get("guidon", 0)) != 0:
		_fail(errors, "fanion without a guidon holds %s, cornet holds %s" % [bare_fanion_salt.get("fanion", 0), bare_cornet_salt.get("cornet", 0)])
	var fanion_cell = plans["presented"]["fanion"][0]
	var guidon_cell = plans["presented"]["guidon"][0]
	var cornet_cell = plans["presented"]["cornet"][0]
	if int(fanion_cell[0]) != int(guidon_cell[0]) or int(fanion_cell[1]) != int(guidon_cell[1]) - 1:
		_fail(errors, "presented plan's fanion is not one cell north of the guidon")
	if int(fanion_cell[0]) != 14 or int(fanion_cell[1]) != -18 or int(guidon_cell[0]) != 14 or int(guidon_cell[1]) != -17 or int(cornet_cell[0]) != 14 or int(cornet_cell[1]) != -16:
		_fail(errors, "presented plan moved the fanion, the guidon, or the cornet")
	_assert_chain(presented, errors, "presented plan", 2997, 2997, 2997, 2997, 2997, 29, 57, 10, 6, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
	if int(presented.get_presented()) != 1 or int(presented.get_guidon_left()) != 0 or int(presented.get_saluted()) != 1 or int(presented.get_cornet_left()) != 0 or int(presented.get_dipped()) != 1 or int(presented.get_struck()) != 1 or int(presented.get_yard_left()) != 57 or int(presented.get_coins()) != 2997 or int(presented.get_hired()) != 29 or int(presented.get_stored_salt()) != int(saluted.get_stored_salt()) or int(presented.get_carted()) != int(saluted.get_carted()) or int(presented.get_shipped()) != int(saluted.get_shipped()) or int(presented.get_wet_haul()) != int(saluted.get_wet_haul()):
		_fail(errors, "presented %d, left %d saluted, saluted %d, dipped %d, yard %d, coins %d, hired %d" % [presented.get_presented(), presented.get_guidon_left(), presented.get_saluted(), presented.get_dipped(), presented.get_yard_left(), presented.get_coins(), presented.get_hired()])
	if int(presented.get_presented()) > int(Sim.FANION_CAP):
		_fail(errors, "fanion presented %d, over the cap of %d" % [presented.get_presented(), Sim.FANION_CAP])
	var fanion_salt: Dictionary = presented.get_cell_salt(int(fanion_cell[0]), int(fanion_cell[1]))
	var guidon_salt: Dictionary = presented.get_cell_salt(int(guidon_cell[0]), int(guidon_cell[1]))
	var cornet_salt: Dictionary = presented.get_cell_salt(int(cornet_cell[0]), int(cornet_cell[1]))
	if int(fanion_salt.get("fanion", 0)) != 1 or int(guidon_salt.get("guidon", 0)) != 0 or int(cornet_salt.get("cornet", 0)) != 0 or int(fanion_salt.get("guidon", 0)) != 0:
		_fail(errors, "fanion cell holds %s, guidon holds %s, cornet holds %s" % [fanion_salt.get("fanion", 0), guidon_salt.get("guidon", 0), cornet_salt.get("cornet", 0)])
	var presented_summary := String(presented.get_summary())
	if not presented_summary.contains("Presented 1 on the fanion") or not presented_summary.contains("Left 0 at the guidon") or not presented_summary.contains("Saluted 1 on the guidon") or not presented_summary.contains("Left 0 at the cornet") or not presented_summary.contains("Dipped 1 on the cornet") or not presented_summary.contains("Coins 2997") or not presented_summary.contains("Hired 29") or not presented_summary.contains("Left 57"):
		_fail(errors, "presented summary does not name the fanion: %s" % presented_summary)
	if int(presented_again.get_presented()) != int(presented.get_presented()) or int(presented_again.get_guidon_left()) != int(presented.get_guidon_left()) or int(presented_again.get_saluted()) != int(presented.get_saluted()) or int(presented_again.get_yard_left()) != int(presented.get_yard_left()) or String(presented_again.get_summary()) != String(presented.get_summary()):
		_fail(errors, "repeated fanion paint presented %d and left guidon %d, then presented %d and left guidon %d" % [presented.get_presented(), presented.get_guidon_left(), presented_again.get_presented(), presented_again.get_guidon_left()])
	if int(late.get_presented()) != 1 or int(late.get_guidon_left()) != 0 or int(late.get_saluted()) != 1 or int(late.get_dipped()) != 1 or int(late.get_yard_left()) != 57 or int(late.get_hired()) != 29 or int(late.get_coins()) != 2997 or int(late.get_stored_salt()) != 2997:
		_fail(errors, "painting the fanion at the fanion beat (presented %d guidon %d saluted %d yard %d) did not match painting it early (presented %d guidon %d saluted %d)" % [late.get_presented(), late.get_guidon_left(), late.get_saluted(), late.get_yard_left(), presented.get_presented(), presented.get_guidon_left(), presented.get_saluted()])
	_assert_chain(dry_presented, errors, "dry fanion", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
	var dry_saluted = _run_plan(plans, "dry_saluted", errors)
	if dry_saluted == null:
		return
	if int(dry_presented.get_presented()) != 1 or int(dry_presented.get_guidon_left()) != 0 or int(dry_presented.get_saluted()) != 1 or int(dry_presented.get_dipped()) != 1 or int(dry_presented.get_yard_left()) != 0 or int(dry_presented.get_wet_haul()) != 0 or int(dry_presented.get_stored_salt()) != 1032 or int(dry_saluted.get_presented()) != 0 or int(dry_saluted.get_guidon_left()) != 1:
		_fail(errors, "dry fanion changed the short crew (wet %d stored %d presented %d guidon %d saluted %d dipped %d yard %d)" % [dry_presented.get_wet_haul(), dry_presented.get_stored_salt(), dry_presented.get_presented(), dry_presented.get_guidon_left(), dry_presented.get_saluted(), dry_presented.get_dipped(), dry_presented.get_yard_left()])
	if not String(dry_presented.get_summary()).contains("Presented 1 on the fanion") or not String(dry_presented.get_summary()).contains("Left 0 at the guidon") or not String(dry_presented.get_summary()).contains("Saluted 1 on the guidon") or not String(dry_presented.get_summary()).contains("Left 0 in the yard"):
		_fail(errors, "dry fanion summary does not name the cap: %s" % dry_presented.get_summary())
	_assert_pop(presented, errors, "presented plan")
	_assert_pop(presented_again, errors, "presented plan again")
	_assert_pop(late, errors, "late_presented")
	_assert_pop(dry_presented, errors, "dry_presented")
	_assert_pop(no_fanion, errors, "no_fanion")
	_assert_pop(bare, errors, "fanion_only")
	var shore = _prepare_plan(plans, "presented", errors)
	if shore == null:
		return
	var shore_guard := 0
	var shore_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + int(Sim.STANDARD_TICK) + int(Sim.JACK_TICK) + int(Sim.ENSIGN_TICK) + int(Sim.BURGEE_TICK) + int(Sim.CORNET_TICK) + int(Sim.GUIDON_TICK) + 2
	while int(shore.get_beat()) != Sim.FANIONING and not shore.is_over() and shore_guard < shore_limit:
		shore.tick()
		shore_guard += 1
	if int(shore.get_beat()) != Sim.FANIONING or shore.is_over():
		_fail(errors, "the guidon beat did not open a fanion beat for the cap check")
		return
	if int(shore.get_ticks_until_rain()) != int(Sim.FANION_TICK):
		_fail(errors, "fanion countdown started at %d, expected %d" % [shore.get_ticks_until_rain(), Sim.FANION_TICK])
	if int(shore.get_presented()) != 0 or int(shore.get_saluted()) != 1 or int(shore.get_guidon_left()) != 1 or int(shore.get_dipped()) != 1 or int(shore.get_cornet_left()) != 0 or int(shore.get_yard_left()) != 57 or int(shore.get_coins()) != 2997 or int(shore.get_stored_salt()) != 2997 or int(shore.get_hired()) != 29:
		_fail(errors, "fanion opened early (presented %d saluted %d guidon %d dipped %d yard %d coins %d stored %d)" % [shore.get_presented(), shore.get_saluted(), shore.get_guidon_left(), shore.get_dipped(), shore.get_yard_left(), shore.get_coins(), shore.get_stored_salt()])
	var saw_cap := false
	var present_guard := 0
	while not shore.is_over() and present_guard < int(Sim.FANION_TICK) + 2:
		shore.tick()
		present_guard += 1
		if int(shore.get_presented()) == int(Sim.FANION_CAP) and int(shore.get_guidon_left()) == 0 and int(shore.get_saluted()) == 1 and int(shore.get_dipped()) == 1 and int(shore.get_yard_left()) == 57 and int(shore.get_coins()) == 2997 and int(shore.get_hired()) == 29 and int(shore.get_ticks_until_rain()) > 0:
			saw_cap = true
			var ticks_left := int(shore.get_ticks_until_rain())
			shore.tick()
			if int(shore.get_presented()) != int(Sim.FANION_CAP) or int(shore.get_guidon_left()) != 0 or int(shore.get_saluted()) != 1 or int(shore.get_dipped()) != 1 or int(shore.get_yard_left()) != 57 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29 or int(shore.get_stored_salt()) != 2997:
				_fail(errors, "the fanion kept presenting after the cap (presented %d guidon %d saluted %d dipped %d yard %d)" % [shore.get_presented(), shore.get_guidon_left(), shore.get_saluted(), shore.get_dipped(), shore.get_yard_left()])
			elif not shore.is_over() and int(shore.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the fanion beat did not spend a tick after the cap")
			break
	if not saw_cap:
		_fail(errors, "the fanion did not stop at %d while ticks remained (presented %d guidon %d saluted %d ticks %d)" % [Sim.FANION_CAP, shore.get_presented(), shore.get_guidon_left(), shore.get_saluted(), shore.get_ticks_until_rain()])
	var end_guard := 0
	while not shore.is_over() and end_guard < int(Sim.FANION_TICK) + 2:
		shore.tick()
		end_guard += 1
		if int(shore.get_presented()) != 1 or int(shore.get_guidon_left()) != 0 or int(shore.get_saluted()) != 1:
			_fail(errors, "the fanion presented again after the cap (presented %d guidon %d saluted %d)" % [shore.get_presented(), shore.get_guidon_left(), shore.get_saluted()])
			break
	if not shore.is_over():
		_fail(errors, "the fanion beat did not end the scenario")
	print("presented %d left guidon %d unsaluted %d; dry presented %d left guidon %d; no fanion presented %d left guidon %d; fanion without guidon presented %d" % [presented.get_presented(), presented.get_guidon_left(), int(presented.get_saluted()) - int(presented.get_presented()), dry_presented.get_presented(), dry_presented.get_guidon_left(), no_fanion.get_presented(), no_fanion.get_guidon_left(), bare.get_presented()])


func _test_pennon(errors: Array) -> void:
	if int(Sim.PENNON_TICK) != 100 or int(Sim.PENNON_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "pennon beat length %s is not 100 ticks (10 seconds)" % Sim.PENNON_TICK)
	if int(Sim.PENNON_CAP) != 1:
		_fail(errors, "pennon cap is %s, expected 1" % Sim.PENNON_CAP)
	if int(Sim.FANION_CAP) != 1:
		_fail(errors, "fanion cap changed to %s" % Sim.FANION_CAP)
	if int(Sim.GRID_NORTH) > -19:
		_fail(errors, "the map was not extended to the pennon row (north %s)" % Sim.GRID_NORTH)
	if int(Sim.PENNON_CELL.x) != 14 or int(Sim.PENNON_CELL.y) != -19:
		_fail(errors, "the pennon cell is not at 14,-19")
	if int(Sim.FANION_CELL.x) != 14 or int(Sim.FANION_CELL.y) != -18:
		_fail(errors, "the fanion moved off 14,-18")
	if int(Sim.GUIDON_CELL.x) != 14 or int(Sim.GUIDON_CELL.y) != -17:
		_fail(errors, "the guidon moved off 14,-17")
	var fresh = Sim.new()
	if fresh.paint_cell(14, -19, Sim.PENNON) == false or int(fresh.get_paint(14, -19)) != Sim.PENNON:
		_fail(errors, "the cell north of the fanion rejected the pennon mark")
	if fresh.paint_cell(14, -18, Sim.PENNON):
		_fail(errors, "the fanion cell accepted a pennon")
	if int(fresh.get_paint(14, -18)) != Sim.EMPTY:
		_fail(errors, "a rejected pennon painted the fanion cell")
	if fresh.paint_cell(14, -19, Sim.FANION):
		_fail(errors, "the pennon cell accepted a fanion")
	if int(fresh.get_paint(14, -19)) != Sim.PENNON:
		_fail(errors, "a rejected fanion erased the pennon")
	if fresh.paint_cell(14, -18, Sim.FANION) == false or int(fresh.get_paint(14, -18)) != Sim.FANION:
		_fail(errors, "the fanion cell no longer accepts a fanion")
	if fresh.paint_cell(14, -20, Sim.PENNON) or fresh.paint_cell(13, -19, Sim.PENNON) or fresh.paint_cell(15, -19, Sim.PENNON) or fresh.paint_cell(14, -18, Sim.PENNON) or fresh.paint_cell(14, -17, Sim.PENNON):
		_fail(errors, "a cell other than 14,-19 accepted a pennon")
	if int(fresh.get_paint(14, -18)) != Sim.FANION:
		_fail(errors, "a rejected pennon erased the fanion")
	if fresh.paint_cell(Sim.COAST_X, -19, Sim.PENNON):
		_fail(errors, "the brine accepted a pennon")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.PENNON):
		_fail(errors, "the anthill accepted a pennon")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var kept = _run_plan(plans, "presented", errors)
	var furled = _run_plan(plans, "furled", errors)
	var furled_again = _run_plan(plans, "furled", errors)
	var late = _run_plan(plans, "late_furled", errors)
	var dry_furled = _run_plan(plans, "dry_furled", errors)
	var bare = _run_plan(plans, "pennon_only", errors)
	var no_fanion = _run_plan(plans, "no_fanion", errors)
	if kept == null or furled == null or furled_again == null or late == null or dry_furled == null or bare == null or no_fanion == null:
		return
	if not kept.is_over() or int(kept.get_beat()) == Sim.PENNONING or int(kept.get_furled()) != 0 or int(kept.get_fanion_left()) != 1 or int(kept.get_presented()) != 1 or int(kept.get_saluted()) != 1 or int(kept.get_coins()) != 2997 or int(kept.get_hired()) != 29 or int(kept.get_yard_left()) != 57:
		_fail(errors, "a fanion with no pennon changed the locked counts (over %s beat %s furled %d fanion %d presented %d coins %d hired %d yard %d)" % [kept.is_over(), kept.get_beat(), kept.get_furled(), kept.get_fanion_left(), kept.get_presented(), kept.get_coins(), kept.get_hired(), kept.get_yard_left()])
	var kept_summary := String(kept.get_summary())
	if kept_summary.to_lower().contains("pennon") or kept_summary.contains("Furled") or not kept_summary.contains("Presented 1 on the fanion"):
		_fail(errors, "a shut pennon changed the fanion summary: %s" % kept_summary)
	if int(furled.get_furled()) != 1 or int(furled.get_fanion_left()) != 0 or int(furled.get_presented()) != 1 or int(furled.get_saluted()) != 1 or int(furled.get_dipped()) != 1 or int(furled.get_coins()) != 2997 or int(furled.get_hired()) != 29 or int(furled.get_yard_left()) != 57 or int(furled.get_stored_salt()) != int(kept.get_stored_salt()) or int(furled.get_carted()) != int(kept.get_carted()) or int(furled.get_shipped()) != int(kept.get_shipped()) or int(furled.get_wet_haul()) != int(kept.get_wet_haul()):
		_fail(errors, "furled %d, left %d presented, presented %d, saluted %d, coins %d, hired %d, yard %d" % [furled.get_furled(), furled.get_fanion_left(), furled.get_presented(), furled.get_saluted(), furled.get_coins(), furled.get_hired(), furled.get_yard_left()])
	if int(furled.get_furled()) > int(Sim.PENNON_CAP):
		_fail(errors, "pennon furled %d, over the cap of %d" % [furled.get_furled(), Sim.PENNON_CAP])
	var pennon_cell: Array = plans["furled"]["pennon"][0]
	var fanion_cell: Array = plans["furled"]["fanion"][0]
	var pennon_salt: Dictionary = furled.get_cell_salt(int(pennon_cell[0]), int(pennon_cell[1]))
	var fanion_salt: Dictionary = furled.get_cell_salt(int(fanion_cell[0]), int(fanion_cell[1]))
	if int(pennon_salt.get("pennon", 0)) != 1 or int(fanion_salt.get("fanion", 0)) != 0 or int(pennon_salt.get("fanion", 0)) != 0:
		_fail(errors, "pennon cell holds %s, fanion holds %s" % [pennon_salt.get("pennon", 0), fanion_salt.get("fanion", 0)])
	var furled_summary := String(furled.get_summary())
	if not furled_summary.contains("Furled 1 on the pennon") or not furled_summary.contains("Left 0 at the fanion") or not furled_summary.contains("Presented 1 on the fanion") or not furled_summary.contains("Left 0 at the guidon") or not furled_summary.contains("Coins 2997") or not furled_summary.contains("Hired 29") or not furled_summary.contains("Left 57"):
		_fail(errors, "furled summary does not name the pennon: %s" % furled_summary)
	if int(furled_again.get_furled()) != int(furled.get_furled()) or int(furled_again.get_fanion_left()) != int(furled.get_fanion_left()) or int(furled_again.get_presented()) != int(furled.get_presented()) or String(furled_again.get_summary()) != furled_summary:
		_fail(errors, "repeated pennon paint furled %d then %d" % [furled.get_furled(), furled_again.get_furled()])
	if int(late.get_furled()) != 1 or int(late.get_fanion_left()) != 0 or int(late.get_presented()) != 1 or int(late.get_saluted()) != 1 or int(late.get_coins()) != 2997 or int(late.get_hired()) != 29 or int(late.get_yard_left()) != 57 or int(late.get_stored_salt()) != 2997:
		_fail(errors, "painting the pennon at the fanion beat (furled %d fanion %d presented %d) did not match painting it early" % [late.get_furled(), late.get_fanion_left(), late.get_presented()])
	_assert_chain(dry_furled, errors, "dry pennon", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
	if int(dry_furled.get_furled()) != 1 or int(dry_furled.get_fanion_left()) != 0 or int(dry_furled.get_presented()) != 1 or int(dry_furled.get_yard_left()) != 0 or int(dry_furled.get_wet_haul()) != 0:
		_fail(errors, "dry pennon changed the short crew (wet %d furled %d fanion %d presented %d yard %d)" % [dry_furled.get_wet_haul(), dry_furled.get_furled(), dry_furled.get_fanion_left(), dry_furled.get_presented(), dry_furled.get_yard_left()])
	if not String(dry_furled.get_summary()).contains("Furled 1 on the pennon") or not String(dry_furled.get_summary()).contains("Left 0 at the fanion"):
		_fail(errors, "dry pennon summary does not name the cap: %s" % dry_furled.get_summary())
	if int(bare.get_furled()) != 0 or int(bare.get_presented()) != 0 or int(bare.get_fanion_left()) != 0 or int(bare.get_saluted()) != 1 or int(bare.get_guidon_left()) != 1 or int(bare.get_coins()) != int(no_fanion.get_coins()) or int(bare.get_hired()) != int(no_fanion.get_hired()) or int(bare.get_stored_salt()) != int(no_fanion.get_stored_salt()) or String(bare.get_summary()) != String(no_fanion.get_summary()):
		_fail(errors, "a pennon with nobody presented furled %d presented %d saluted %d guidon %d" % [bare.get_furled(), bare.get_presented(), bare.get_saluted(), bare.get_guidon_left()])
	if String(bare.get_summary()).to_lower().contains("pennon") or String(bare.get_summary()).contains("Furled"):
		_fail(errors, "an empty pennon was named: %s" % bare.get_summary())
	_assert_pop(furled, errors, "furled plan")
	_assert_pop(late, errors, "late_furled")
	_assert_pop(dry_furled, errors, "dry_furled")
	_assert_pop(bare, errors, "pennon_only")
	_assert_pop(kept, errors, "presented without pennon")
	var shore = _prepare_plan(plans, "furled", errors)
	if shore == null:
		return
	var shore_guard := 0
	var shore_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + int(Sim.STANDARD_TICK) + int(Sim.JACK_TICK) + int(Sim.ENSIGN_TICK) + int(Sim.BURGEE_TICK) + int(Sim.CORNET_TICK) + int(Sim.GUIDON_TICK) + int(Sim.FANION_TICK) + 2
	while int(shore.get_beat()) != Sim.PENNONING and not shore.is_over() and shore_guard < shore_limit:
		shore.tick()
		shore_guard += 1
	if int(shore.get_beat()) != Sim.PENNONING or shore.is_over():
		_fail(errors, "the fanion beat did not open a pennon beat for the cap check")
		return
	if int(shore.get_ticks_until_rain()) != int(Sim.PENNON_TICK):
		_fail(errors, "pennon countdown started at %d, expected %d" % [shore.get_ticks_until_rain(), Sim.PENNON_TICK])
	if int(shore.get_furled()) != 0 or int(shore.get_fanion_left()) != 1 or int(shore.get_presented()) != 1 or int(shore.get_saluted()) != 1 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29 or int(shore.get_yard_left()) != 57:
		_fail(errors, "pennon opened early (furled %d fanion %d presented %d coins %d hired %d)" % [shore.get_furled(), shore.get_fanion_left(), shore.get_presented(), shore.get_coins(), shore.get_hired()])
	var saw_cap := false
	var furl_guard := 0
	while not shore.is_over() and furl_guard < int(Sim.PENNON_TICK) + 2:
		shore.tick()
		furl_guard += 1
		if int(shore.get_furled()) == int(Sim.PENNON_CAP) and int(shore.get_fanion_left()) == 0 and int(shore.get_presented()) == 1 and int(shore.get_saluted()) == 1 and int(shore.get_coins()) == 2997 and int(shore.get_hired()) == 29 and int(shore.get_ticks_until_rain()) > 0:
			saw_cap = true
			var ticks_left := int(shore.get_ticks_until_rain())
			shore.tick()
			if int(shore.get_furled()) != int(Sim.PENNON_CAP) or int(shore.get_fanion_left()) != 0 or int(shore.get_presented()) != 1 or int(shore.get_saluted()) != 1 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29:
				_fail(errors, "the pennon kept furling after the cap (furled %d fanion %d presented %d)" % [shore.get_furled(), shore.get_fanion_left(), shore.get_presented()])
			elif not shore.is_over() and int(shore.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the pennon beat did not spend a tick after the cap")
			break
	if not saw_cap:
		_fail(errors, "the pennon did not stop at %d while ticks remained (furled %d fanion %d presented %d ticks %d)" % [Sim.PENNON_CAP, shore.get_furled(), shore.get_fanion_left(), shore.get_presented(), shore.get_ticks_until_rain()])
	var end_guard := 0
	while not shore.is_over() and end_guard < int(Sim.PENNON_TICK) + 2:
		shore.tick()
		end_guard += 1
		if int(shore.get_furled()) != 1 or int(shore.get_fanion_left()) != 0 or int(shore.get_presented()) != 1:
			_fail(errors, "the pennon furled again after the cap (furled %d fanion %d presented %d)" % [shore.get_furled(), shore.get_fanion_left(), shore.get_presented()])
			break
	if not shore.is_over():
		_fail(errors, "the pennon beat did not end the scenario")
	print("furled %d left fanion %d unpresented %d; no pennon furled %d left fanion %d; pennon without fanion furled %d" % [furled.get_furled(), furled.get_fanion_left(), int(furled.get_presented()) - int(furled.get_furled()), kept.get_furled(), kept.get_fanion_left(), bare.get_furled()])


func _test_gonfalon(errors: Array) -> void:
	if int(Sim.GONFALON_TICK) != 100 or int(Sim.GONFALON_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "gonfalon beat length %s is not 100 ticks (10 seconds)" % Sim.GONFALON_TICK)
	if int(Sim.GONFALON_CAP) != 1:
		_fail(errors, "gonfalon cap is %s, expected 1" % Sim.GONFALON_CAP)
	if int(Sim.PENNON_CAP) != 1:
		_fail(errors, "pennon cap changed to %s" % Sim.PENNON_CAP)
	if int(Sim.GRID_NORTH) > -20:
		_fail(errors, "the map was not extended to the gonfalon row (north %s)" % Sim.GRID_NORTH)
	if int(Sim.GONFALON_CELL.x) != 14 or int(Sim.GONFALON_CELL.y) != -20:
		_fail(errors, "the gonfalon cell is not at 14,-20")
	if int(Sim.PENNON_CELL.x) != 14 or int(Sim.PENNON_CELL.y) != -19:
		_fail(errors, "the pennon moved off 14,-19")
	if int(Sim.FANION_CELL.x) != 14 or int(Sim.FANION_CELL.y) != -18:
		_fail(errors, "the fanion moved off 14,-18")
	var fresh = Sim.new()
	if fresh.paint_cell(14, -20, Sim.GONFALON) == false or int(fresh.get_paint(14, -20)) != Sim.GONFALON:
		_fail(errors, "the cell north of the pennon rejected the gonfalon mark")
	if fresh.paint_cell(14, -19, Sim.GONFALON):
		_fail(errors, "the pennon cell accepted a gonfalon")
	if int(fresh.get_paint(14, -19)) != Sim.EMPTY:
		_fail(errors, "a rejected gonfalon painted the pennon cell")
	if fresh.paint_cell(14, -20, Sim.PENNON):
		_fail(errors, "the gonfalon cell accepted a pennon")
	if int(fresh.get_paint(14, -20)) != Sim.GONFALON:
		_fail(errors, "a rejected pennon erased the gonfalon")
	if fresh.paint_cell(14, -19, Sim.PENNON) == false or int(fresh.get_paint(14, -19)) != Sim.PENNON:
		_fail(errors, "the pennon cell no longer accepts a pennon")
	if fresh.paint_cell(14, -21, Sim.GONFALON) or fresh.paint_cell(13, -20, Sim.GONFALON) or fresh.paint_cell(15, -20, Sim.GONFALON) or fresh.paint_cell(14, -19, Sim.GONFALON) or fresh.paint_cell(14, -18, Sim.GONFALON):
		_fail(errors, "a cell other than 14,-20 accepted a gonfalon")
	if int(fresh.get_paint(14, -19)) != Sim.PENNON:
		_fail(errors, "a rejected gonfalon erased the pennon")
	if fresh.paint_cell(Sim.COAST_X, -20, Sim.GONFALON):
		_fail(errors, "the brine accepted a gonfalon")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.GONFALON):
		_fail(errors, "the anthill accepted a gonfalon")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var kept = _run_plan(plans, "furled", errors)
	var dipped = _run_plan(plans, "gonfalon", errors)
	var dipped_again = _run_plan(plans, "gonfalon", errors)
	var late = _run_plan(plans, "late_gonfalon", errors)
	var dry_gonfalon = _run_plan(plans, "dry_gonfalon", errors)
	var bare = _run_plan(plans, "gonfalon_only", errors)
	var no_furled = _run_plan(plans, "pennon_only", errors)
	if kept == null or dipped == null or dipped_again == null or late == null or dry_gonfalon == null or bare == null or no_furled == null:
		return
	if not kept.is_over() or int(kept.get_beat()) == Sim.GONFALONING or int(kept.get_gonfalon_dipped()) != 0 or int(kept.get_pennon_left()) != 1 or int(kept.get_furled()) != 1 or int(kept.get_presented()) != 1 or int(kept.get_coins()) != 2997 or int(kept.get_hired()) != 29 or int(kept.get_yard_left()) != 57:
		_fail(errors, "a pennon with no gonfalon changed the locked counts (over %s beat %s dipped %d pennon %d furled %d presented %d coins %d hired %d yard %d)" % [kept.is_over(), kept.get_beat(), kept.get_gonfalon_dipped(), kept.get_pennon_left(), kept.get_furled(), kept.get_presented(), kept.get_coins(), kept.get_hired(), kept.get_yard_left()])
	var kept_summary := String(kept.get_summary())
	if kept_summary.to_lower().contains("gonfalon") or not kept_summary.contains("Furled 1 on the pennon"):
		_fail(errors, "a shut gonfalon changed the pennon summary: %s" % kept_summary)
	if int(dipped.get_gonfalon_dipped()) != 1 or int(dipped.get_pennon_left()) != 0 or int(dipped.get_furled()) != 1 or int(dipped.get_presented()) != 1 or int(dipped.get_saluted()) != 1 or int(dipped.get_dipped()) != 1 or int(dipped.get_coins()) != 2997 or int(dipped.get_hired()) != 29 or int(dipped.get_yard_left()) != 57 or int(dipped.get_stored_salt()) != int(kept.get_stored_salt()) or int(dipped.get_carted()) != int(kept.get_carted()) or int(dipped.get_shipped()) != int(kept.get_shipped()) or int(dipped.get_wet_haul()) != int(kept.get_wet_haul()):
		_fail(errors, "dipped %d, left %d furled, furled %d, presented %d, coins %d, hired %d, yard %d" % [dipped.get_gonfalon_dipped(), dipped.get_pennon_left(), dipped.get_furled(), dipped.get_presented(), dipped.get_coins(), dipped.get_hired(), dipped.get_yard_left()])
	if int(dipped.get_gonfalon_dipped()) > int(Sim.GONFALON_CAP):
		_fail(errors, "gonfalon dipped %d, over the cap of %d" % [dipped.get_gonfalon_dipped(), Sim.GONFALON_CAP])
	var gonfalon_cell: Array = plans["gonfalon"]["gonfalon"][0]
	var pennon_cell: Array = plans["gonfalon"]["pennon"][0]
	var gonfalon_salt: Dictionary = dipped.get_cell_salt(int(gonfalon_cell[0]), int(gonfalon_cell[1]))
	var pennon_salt: Dictionary = dipped.get_cell_salt(int(pennon_cell[0]), int(pennon_cell[1]))
	if int(gonfalon_salt.get("gonfalon", 0)) != 1 or int(pennon_salt.get("pennon", 0)) != 0 or int(gonfalon_salt.get("pennon", 0)) != 0:
		_fail(errors, "gonfalon cell holds %s, pennon holds %s" % [gonfalon_salt.get("gonfalon", 0), pennon_salt.get("pennon", 0)])
	var dipped_summary := String(dipped.get_summary())
	if not dipped_summary.contains("Dipped 1 on the gonfalon") or not dipped_summary.contains("Left 0 at the pennon") or not dipped_summary.contains("Furled 1 on the pennon") or not dipped_summary.contains("Left 0 at the fanion") or not dipped_summary.contains("Dipped 1 on the cornet") or not dipped_summary.contains("Coins 2997") or not dipped_summary.contains("Hired 29") or not dipped_summary.contains("Left 57"):
		_fail(errors, "gonfalon summary does not name the dip: %s" % dipped_summary)
	if int(dipped_again.get_gonfalon_dipped()) != 1 or int(dipped_again.get_pennon_left()) != 0 or int(dipped_again.get_furled()) != 1 or int(dipped_again.get_presented()) != 1 or int(dipped_again.get_coins()) != 2997 or int(dipped_again.get_hired()) != 29 or String(dipped_again.get_summary()) != dipped_summary:
		_fail(errors, "repeated gonfalon paint dipped %d then %d" % [dipped.get_gonfalon_dipped(), dipped_again.get_gonfalon_dipped()])
	if int(late.get_gonfalon_dipped()) != 1 or int(late.get_pennon_left()) != 0 or int(late.get_furled()) != 1 or int(late.get_presented()) != 1 or int(late.get_coins()) != 2997 or int(late.get_hired()) != 29 or int(late.get_yard_left()) != 57 or int(late.get_stored_salt()) != 2997:
		_fail(errors, "painting the gonfalon at the pennon beat (dipped %d pennon %d furled %d) did not match painting it early" % [late.get_gonfalon_dipped(), late.get_pennon_left(), late.get_furled()])
	_assert_chain(dry_gonfalon, errors, "dry gonfalon", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
	if int(dry_gonfalon.get_gonfalon_dipped()) != 1 or int(dry_gonfalon.get_pennon_left()) != 0 or int(dry_gonfalon.get_furled()) != 1 or int(dry_gonfalon.get_presented()) != 1 or int(dry_gonfalon.get_yard_left()) != 0 or int(dry_gonfalon.get_wet_haul()) != 0:
		_fail(errors, "dry gonfalon changed the short crew (wet %d dipped %d pennon %d furled %d presented %d yard %d)" % [dry_gonfalon.get_wet_haul(), dry_gonfalon.get_gonfalon_dipped(), dry_gonfalon.get_pennon_left(), dry_gonfalon.get_furled(), dry_gonfalon.get_presented(), dry_gonfalon.get_yard_left()])
	if not String(dry_gonfalon.get_summary()).contains("Dipped 1 on the gonfalon") or not String(dry_gonfalon.get_summary()).contains("Left 0 at the pennon"):
		_fail(errors, "dry gonfalon summary does not name the cap: %s" % dry_gonfalon.get_summary())
	if int(bare.get_gonfalon_dipped()) != 0 or int(bare.get_furled()) != 0 or int(bare.get_presented()) != 0 or int(bare.get_pennon_left()) != 0 or int(bare.get_coins()) != int(no_furled.get_coins()) or int(bare.get_hired()) != int(no_furled.get_hired()) or int(bare.get_stored_salt()) != int(no_furled.get_stored_salt()) or String(bare.get_summary()) != String(no_furled.get_summary()):
		_fail(errors, "a gonfalon with nobody furled dipped %d furled %d presented %d coins %d hired %d" % [bare.get_gonfalon_dipped(), bare.get_furled(), bare.get_presented(), bare.get_coins(), bare.get_hired()])
	if String(bare.get_summary()).to_lower().contains("gonfalon"):
		_fail(errors, "an empty gonfalon was named: %s" % bare.get_summary())
	_assert_pop(dipped, errors, "gonfalon plan")
	_assert_pop(late, errors, "late_gonfalon")
	_assert_pop(dry_gonfalon, errors, "dry_gonfalon")
	_assert_pop(bare, errors, "gonfalon_only")
	_assert_pop(kept, errors, "furled without gonfalon")
	var shore = _prepare_plan(plans, "gonfalon", errors)
	if shore == null:
		return
	var shore_guard := 0
	var shore_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + int(Sim.STANDARD_TICK) + int(Sim.JACK_TICK) + int(Sim.ENSIGN_TICK) + int(Sim.BURGEE_TICK) + int(Sim.CORNET_TICK) + int(Sim.GUIDON_TICK) + int(Sim.FANION_TICK) + int(Sim.PENNON_TICK) + 2
	while int(shore.get_beat()) != Sim.GONFALONING and not shore.is_over() and shore_guard < shore_limit:
		shore.tick()
		shore_guard += 1
	if int(shore.get_beat()) != Sim.GONFALONING or shore.is_over():
		_fail(errors, "the pennon beat did not open a gonfalon beat for the cap check")
		return
	if int(shore.get_ticks_until_rain()) != int(Sim.GONFALON_TICK):
		_fail(errors, "gonfalon countdown started at %d, expected %d" % [shore.get_ticks_until_rain(), Sim.GONFALON_TICK])
	if int(shore.get_gonfalon_dipped()) != 0 or int(shore.get_pennon_left()) != 1 or int(shore.get_furled()) != 1 or int(shore.get_presented()) != 1 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29 or int(shore.get_yard_left()) != 57:
		_fail(errors, "gonfalon opened early (dipped %d pennon %d furled %d presented %d coins %d hired %d)" % [shore.get_gonfalon_dipped(), shore.get_pennon_left(), shore.get_furled(), shore.get_presented(), shore.get_coins(), shore.get_hired()])
	var saw_cap := false
	var dip_guard := 0
	while not shore.is_over() and dip_guard < int(Sim.GONFALON_TICK) + 2:
		shore.tick()
		dip_guard += 1
		if int(shore.get_gonfalon_dipped()) == int(Sim.GONFALON_CAP) and int(shore.get_pennon_left()) == 0 and int(shore.get_furled()) == 1 and int(shore.get_presented()) == 1 and int(shore.get_coins()) == 2997 and int(shore.get_hired()) == 29 and int(shore.get_ticks_until_rain()) > 0:
			saw_cap = true
			var ticks_left := int(shore.get_ticks_until_rain())
			shore.tick()
			if int(shore.get_gonfalon_dipped()) != int(Sim.GONFALON_CAP) or int(shore.get_pennon_left()) != 0 or int(shore.get_furled()) != 1 or int(shore.get_presented()) != 1 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29:
				_fail(errors, "the gonfalon kept dipping after the cap (dipped %d pennon %d furled %d presented %d)" % [shore.get_gonfalon_dipped(), shore.get_pennon_left(), shore.get_furled(), shore.get_presented()])
			elif not shore.is_over() and int(shore.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the gonfalon beat did not spend a tick after the cap")
			break
	if not saw_cap:
		_fail(errors, "the gonfalon did not stop at %d while ticks remained (dipped %d pennon %d furled %d ticks %d)" % [Sim.GONFALON_CAP, shore.get_gonfalon_dipped(), shore.get_pennon_left(), shore.get_furled(), shore.get_ticks_until_rain()])
	var end_guard := 0
	while not shore.is_over() and end_guard < int(Sim.GONFALON_TICK) + 2:
		shore.tick()
		end_guard += 1
		if int(shore.get_gonfalon_dipped()) != 1 or int(shore.get_pennon_left()) != 0 or int(shore.get_furled()) != 1 or int(shore.get_presented()) != 1:
			_fail(errors, "the gonfalon dipped again after the cap (dipped %d pennon %d furled %d presented %d)" % [shore.get_gonfalon_dipped(), shore.get_pennon_left(), shore.get_furled(), shore.get_presented()])
			break
	if not shore.is_over():
		_fail(errors, "the gonfalon beat did not end the scenario")
	print("gonfalon dipped %d left pennon %d; no gonfalon dipped %d left pennon %d furled %d presented %d coins %d hired %d; gonfalon without a furled hire dipped %d coins %d hired %d" % [dipped.get_gonfalon_dipped(), dipped.get_pennon_left(), kept.get_gonfalon_dipped(), kept.get_pennon_left(), kept.get_furled(), kept.get_presented(), kept.get_coins(), kept.get_hired(), bare.get_gonfalon_dipped(), bare.get_coins(), bare.get_hired()])


func _test_oriflamme(errors: Array) -> void:
	if int(Sim.ORIFLAMME_TICK) != 100 or int(Sim.ORIFLAMME_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "oriflamme beat length %s is not 100 ticks (10 seconds)" % Sim.ORIFLAMME_TICK)
	if int(Sim.ORIFLAMME_CAP) != 1:
		_fail(errors, "oriflamme cap is %s, expected 1" % Sim.ORIFLAMME_CAP)
	if int(Sim.GONFALON_CAP) != 1:
		_fail(errors, "gonfalon cap changed to %s" % Sim.GONFALON_CAP)
	if int(Sim.GRID_NORTH) > -21:
		_fail(errors, "the map was not extended to the oriflamme row (north %s)" % Sim.GRID_NORTH)
	if int(Sim.ORIFLAMME_CELL.x) != 14 or int(Sim.ORIFLAMME_CELL.y) != -21:
		_fail(errors, "the oriflamme cell is not at 14,-21")
	if int(Sim.GONFALON_CELL.x) != 14 or int(Sim.GONFALON_CELL.y) != -20:
		_fail(errors, "the gonfalon moved off 14,-20")
	if int(Sim.PENNON_CELL.x) != 14 or int(Sim.PENNON_CELL.y) != -19:
		_fail(errors, "the pennon moved off 14,-19")
	var fresh = Sim.new()
	if fresh.paint_cell(14, -21, Sim.ORIFLAMME) == false or int(fresh.get_paint(14, -21)) != Sim.ORIFLAMME:
		_fail(errors, "the cell north of the gonfalon rejected the oriflamme mark")
	if fresh.paint_cell(14, -20, Sim.ORIFLAMME):
		_fail(errors, "the gonfalon cell accepted an oriflamme")
	if int(fresh.get_paint(14, -20)) != Sim.EMPTY:
		_fail(errors, "a rejected oriflamme painted the gonfalon cell")
	if fresh.paint_cell(14, -21, Sim.GONFALON):
		_fail(errors, "the oriflamme cell accepted a gonfalon")
	if int(fresh.get_paint(14, -21)) != Sim.ORIFLAMME:
		_fail(errors, "a rejected gonfalon erased the oriflamme")
	if fresh.paint_cell(14, -20, Sim.GONFALON) == false or int(fresh.get_paint(14, -20)) != Sim.GONFALON:
		_fail(errors, "the gonfalon cell no longer accepts a gonfalon")
	if fresh.paint_cell(14, -22, Sim.ORIFLAMME) or fresh.paint_cell(13, -21, Sim.ORIFLAMME) or fresh.paint_cell(15, -21, Sim.ORIFLAMME) or fresh.paint_cell(14, -20, Sim.ORIFLAMME) or fresh.paint_cell(14, -19, Sim.ORIFLAMME):
		_fail(errors, "a cell other than 14,-21 accepted an oriflamme")
	if int(fresh.get_paint(14, -20)) != Sim.GONFALON:
		_fail(errors, "a rejected oriflamme erased the gonfalon")
	if fresh.paint_cell(Sim.COAST_X, -21, Sim.ORIFLAMME):
		_fail(errors, "the brine accepted an oriflamme")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.ORIFLAMME):
		_fail(errors, "the anthill accepted an oriflamme")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var kept = _run_plan(plans, "gonfalon", errors)
	var lowered = _run_plan(plans, "oriflamme", errors)
	var lowered_again = _run_plan(plans, "oriflamme", errors)
	var late = _run_plan(plans, "late_oriflamme", errors)
	var dry_oriflamme = _run_plan(plans, "dry_oriflamme", errors)
	var bare = _run_plan(plans, "oriflamme_only", errors)
	var no_dipped = _run_plan(plans, "gonfalon_only", errors)
	if kept == null or lowered == null or lowered_again == null or late == null or dry_oriflamme == null or bare == null or no_dipped == null:
		return
	if not kept.is_over() or int(kept.get_beat()) == Sim.ORIFLAMMING or int(kept.get_oriflamme_lowered()) != 0 or int(kept.get_gonfalon_dipped()) != 1 or int(kept.get_gonfalon_left()) != 1 or int(kept.get_pennon_left()) != 0 or int(kept.get_furled()) != 1 or int(kept.get_presented()) != 1 or int(kept.get_coins()) != 2997 or int(kept.get_hired()) != 29 or int(kept.get_yard_left()) != 57:
		_fail(errors, "a gonfalon with no oriflamme changed the locked counts (over %s beat %s lowered %d dipped %d left %d pennon %d furled %d presented %d coins %d hired %d yard %d)" % [kept.is_over(), kept.get_beat(), kept.get_oriflamme_lowered(), kept.get_gonfalon_dipped(), kept.get_gonfalon_left(), kept.get_pennon_left(), kept.get_furled(), kept.get_presented(), kept.get_coins(), kept.get_hired(), kept.get_yard_left()])
	var kept_summary := String(kept.get_summary())
	if kept_summary.to_lower().contains("oriflamme") or kept_summary.contains("Lowered") or not kept_summary.contains("Dipped 1 on the gonfalon"):
		_fail(errors, "a shut oriflamme changed the gonfalon summary: %s" % kept_summary)
	if int(lowered.get_oriflamme_lowered()) != 1 or int(lowered.get_gonfalon_left()) != 0 or int(lowered.get_gonfalon_dipped()) != 1 or int(lowered.get_pennon_left()) != 0 or int(lowered.get_furled()) != 1 or int(lowered.get_presented()) != 1 or int(lowered.get_saluted()) != 1 or int(lowered.get_dipped()) != 1 or int(lowered.get_coins()) != 2997 or int(lowered.get_hired()) != 29 or int(lowered.get_yard_left()) != 57 or int(lowered.get_stored_salt()) != int(kept.get_stored_salt()) or int(lowered.get_carted()) != int(kept.get_carted()) or int(lowered.get_shipped()) != int(kept.get_shipped()) or int(lowered.get_wet_haul()) != int(kept.get_wet_haul()):
		_fail(errors, "lowered %d, left %d dipped, dipped %d, pennon %d, furled %d, presented %d, coins %d, hired %d, yard %d" % [lowered.get_oriflamme_lowered(), lowered.get_gonfalon_left(), lowered.get_gonfalon_dipped(), lowered.get_pennon_left(), lowered.get_furled(), lowered.get_presented(), lowered.get_coins(), lowered.get_hired(), lowered.get_yard_left()])
	if int(lowered.get_oriflamme_lowered()) > int(Sim.ORIFLAMME_CAP):
		_fail(errors, "oriflamme lowered %d, over the cap of %d" % [lowered.get_oriflamme_lowered(), Sim.ORIFLAMME_CAP])
	var oriflamme_cell: Array = plans["oriflamme"]["oriflamme"][0]
	var gonfalon_cell: Array = plans["oriflamme"]["gonfalon"][0]
	var oriflamme_salt: Dictionary = lowered.get_cell_salt(int(oriflamme_cell[0]), int(oriflamme_cell[1]))
	var gonfalon_salt: Dictionary = lowered.get_cell_salt(int(gonfalon_cell[0]), int(gonfalon_cell[1]))
	if int(oriflamme_salt.get("oriflamme", 0)) != 1 or int(gonfalon_salt.get("gonfalon", 0)) != 0 or int(oriflamme_salt.get("gonfalon", 0)) != 0:
		_fail(errors, "oriflamme cell holds %s, gonfalon holds %s" % [oriflamme_salt.get("oriflamme", 0), gonfalon_salt.get("gonfalon", 0)])
	var lowered_summary := String(lowered.get_summary())
	if not lowered_summary.contains("Lowered 1 on the oriflamme") or not lowered_summary.contains("Left 0 at the gonfalon") or not lowered_summary.contains("Dipped 1 on the gonfalon") or not lowered_summary.contains("Left 0 at the pennon") or not lowered_summary.contains("Furled 1 on the pennon") or not lowered_summary.contains("Dipped 1 on the cornet") or not lowered_summary.contains("Coins 2997") or not lowered_summary.contains("Hired 29") or not lowered_summary.contains("Left 57"):
		_fail(errors, "oriflamme summary does not name the lowering: %s" % lowered_summary)
	if int(lowered_again.get_oriflamme_lowered()) != 1 or int(lowered_again.get_gonfalon_left()) != 0 or int(lowered_again.get_gonfalon_dipped()) != 1 or int(lowered_again.get_furled()) != 1 or int(lowered_again.get_presented()) != 1 or int(lowered_again.get_coins()) != 2997 or int(lowered_again.get_hired()) != 29 or String(lowered_again.get_summary()) != lowered_summary:
		_fail(errors, "repeated oriflamme paint lowered %d then %d" % [lowered.get_oriflamme_lowered(), lowered_again.get_oriflamme_lowered()])
	if int(late.get_oriflamme_lowered()) != 1 or int(late.get_gonfalon_left()) != 0 or int(late.get_gonfalon_dipped()) != 1 or int(late.get_furled()) != 1 or int(late.get_presented()) != 1 or int(late.get_coins()) != 2997 or int(late.get_hired()) != 29 or int(late.get_yard_left()) != 57 or int(late.get_stored_salt()) != 2997:
		_fail(errors, "painting the oriflamme at the gonfalon beat (lowered %d left %d dipped %d) did not match painting it early" % [late.get_oriflamme_lowered(), late.get_gonfalon_left(), late.get_gonfalon_dipped()])
	_assert_chain(dry_oriflamme, errors, "dry oriflamme", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
	if int(dry_oriflamme.get_oriflamme_lowered()) != 1 or int(dry_oriflamme.get_gonfalon_left()) != 0 or int(dry_oriflamme.get_gonfalon_dipped()) != 1 or int(dry_oriflamme.get_furled()) != 1 or int(dry_oriflamme.get_presented()) != 1 or int(dry_oriflamme.get_yard_left()) != 0 or int(dry_oriflamme.get_wet_haul()) != 0:
		_fail(errors, "dry oriflamme changed the short crew (wet %d lowered %d left %d dipped %d furled %d presented %d yard %d)" % [dry_oriflamme.get_wet_haul(), dry_oriflamme.get_oriflamme_lowered(), dry_oriflamme.get_gonfalon_left(), dry_oriflamme.get_gonfalon_dipped(), dry_oriflamme.get_furled(), dry_oriflamme.get_presented(), dry_oriflamme.get_yard_left()])
	if not String(dry_oriflamme.get_summary()).contains("Lowered 1 on the oriflamme") or not String(dry_oriflamme.get_summary()).contains("Left 0 at the gonfalon"):
		_fail(errors, "dry oriflamme summary does not name the cap: %s" % dry_oriflamme.get_summary())
	if int(bare.get_oriflamme_lowered()) != 0 or int(bare.get_gonfalon_dipped()) != 0 or int(bare.get_furled()) != 0 or int(bare.get_presented()) != 0 or int(bare.get_coins()) != int(no_dipped.get_coins()) or int(bare.get_hired()) != int(no_dipped.get_hired()) or int(bare.get_stored_salt()) != int(no_dipped.get_stored_salt()) or String(bare.get_summary()) != String(no_dipped.get_summary()):
		_fail(errors, "an oriflamme with nobody dipped lowered %d dipped %d furled %d presented %d coins %d hired %d" % [bare.get_oriflamme_lowered(), bare.get_gonfalon_dipped(), bare.get_furled(), bare.get_presented(), bare.get_coins(), bare.get_hired()])
	if String(bare.get_summary()).to_lower().contains("oriflamme") or String(bare.get_summary()).contains("Lowered"):
		_fail(errors, "an empty oriflamme was named: %s" % bare.get_summary())
	_assert_pop(lowered, errors, "oriflamme plan")
	_assert_pop(late, errors, "late_oriflamme")
	_assert_pop(dry_oriflamme, errors, "dry_oriflamme")
	_assert_pop(bare, errors, "oriflamme_only")
	_assert_pop(kept, errors, "gonfalon without oriflamme")
	var shore = _prepare_plan(plans, "oriflamme", errors)
	if shore == null:
		return
	var shore_guard := 0
	var shore_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + int(Sim.STANDARD_TICK) + int(Sim.JACK_TICK) + int(Sim.ENSIGN_TICK) + int(Sim.BURGEE_TICK) + int(Sim.CORNET_TICK) + int(Sim.GUIDON_TICK) + int(Sim.FANION_TICK) + int(Sim.PENNON_TICK) + int(Sim.GONFALON_TICK) + 2
	while int(shore.get_beat()) != Sim.ORIFLAMMING and not shore.is_over() and shore_guard < shore_limit:
		shore.tick()
		shore_guard += 1
	if int(shore.get_beat()) != Sim.ORIFLAMMING or shore.is_over():
		_fail(errors, "the gonfalon beat did not open an oriflamme beat for the cap check")
		return
	if int(shore.get_ticks_until_rain()) != int(Sim.ORIFLAMME_TICK):
		_fail(errors, "oriflamme countdown started at %d, expected %d" % [shore.get_ticks_until_rain(), Sim.ORIFLAMME_TICK])
	if int(shore.get_oriflamme_lowered()) != 0 or int(shore.get_gonfalon_left()) != 1 or int(shore.get_gonfalon_dipped()) != 1 or int(shore.get_pennon_left()) != 0 or int(shore.get_furled()) != 1 or int(shore.get_presented()) != 1 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29 or int(shore.get_yard_left()) != 57:
		_fail(errors, "oriflamme opened early (lowered %d left %d dipped %d pennon %d furled %d presented %d coins %d hired %d)" % [shore.get_oriflamme_lowered(), shore.get_gonfalon_left(), shore.get_gonfalon_dipped(), shore.get_pennon_left(), shore.get_furled(), shore.get_presented(), shore.get_coins(), shore.get_hired()])
	var saw_cap := false
	var lower_guard := 0
	while not shore.is_over() and lower_guard < int(Sim.ORIFLAMME_TICK) + 2:
		shore.tick()
		lower_guard += 1
		if int(shore.get_oriflamme_lowered()) == int(Sim.ORIFLAMME_CAP) and int(shore.get_gonfalon_left()) == 0 and int(shore.get_gonfalon_dipped()) == 1 and int(shore.get_furled()) == 1 and int(shore.get_presented()) == 1 and int(shore.get_coins()) == 2997 and int(shore.get_hired()) == 29 and int(shore.get_ticks_until_rain()) > 0:
			saw_cap = true
			var ticks_left := int(shore.get_ticks_until_rain())
			shore.tick()
			if int(shore.get_oriflamme_lowered()) != int(Sim.ORIFLAMME_CAP) or int(shore.get_gonfalon_left()) != 0 or int(shore.get_gonfalon_dipped()) != 1 or int(shore.get_furled()) != 1 or int(shore.get_presented()) != 1 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29:
				_fail(errors, "the oriflamme kept lowering after the cap (lowered %d left %d dipped %d furled %d presented %d)" % [shore.get_oriflamme_lowered(), shore.get_gonfalon_left(), shore.get_gonfalon_dipped(), shore.get_furled(), shore.get_presented()])
			elif not shore.is_over() and int(shore.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the oriflamme beat did not spend a tick after the cap")
			break
	if not saw_cap:
		_fail(errors, "the oriflamme did not stop at %d while ticks remained (lowered %d left %d dipped %d ticks %d)" % [Sim.ORIFLAMME_CAP, shore.get_oriflamme_lowered(), shore.get_gonfalon_left(), shore.get_gonfalon_dipped(), shore.get_ticks_until_rain()])
	var end_guard := 0
	while not shore.is_over() and end_guard < int(Sim.ORIFLAMME_TICK) + 2:
		shore.tick()
		end_guard += 1
		if int(shore.get_oriflamme_lowered()) != 1 or int(shore.get_gonfalon_left()) != 0 or int(shore.get_gonfalon_dipped()) != 1 or int(shore.get_furled()) != 1 or int(shore.get_presented()) != 1:
			_fail(errors, "the oriflamme lowered again after the cap (lowered %d left %d dipped %d furled %d presented %d)" % [shore.get_oriflamme_lowered(), shore.get_gonfalon_left(), shore.get_gonfalon_dipped(), shore.get_furled(), shore.get_presented()])
			break
	if not shore.is_over():
		_fail(errors, "the oriflamme beat did not end the scenario")
	print("oriflamme lowered %d left gonfalon %d dipped %d pennon %d furled %d presented %d coins %d hired %d; no oriflamme lowered %d dipped %d left %d pennon %d furled %d presented %d coins %d hired %d; oriflamme without a dipped hire lowered %d coins %d hired %d" % [lowered.get_oriflamme_lowered(), lowered.get_gonfalon_left(), lowered.get_gonfalon_dipped(), lowered.get_pennon_left(), lowered.get_furled(), lowered.get_presented(), lowered.get_coins(), lowered.get_hired(), kept.get_oriflamme_lowered(), kept.get_gonfalon_dipped(), kept.get_gonfalon_left(), kept.get_pennon_left(), kept.get_furled(), kept.get_presented(), kept.get_coins(), kept.get_hired(), bare.get_oriflamme_lowered(), bare.get_coins(), bare.get_hired()])


func _test_vexillum(errors: Array) -> void:
	if int(Sim.VEXILLUM_TICK) != 100 or int(Sim.VEXILLUM_TICK) != int(Sim.TICK_HZ) * 10:
		_fail(errors, "vexillum beat length %s is not 100 ticks (10 seconds)" % Sim.VEXILLUM_TICK)
	if int(Sim.VEXILLUM_CAP) != 1:
		_fail(errors, "vexillum cap is %s, expected 1" % Sim.VEXILLUM_CAP)
	if int(Sim.ORIFLAMME_CAP) != 1:
		_fail(errors, "oriflamme cap changed to %s" % Sim.ORIFLAMME_CAP)
	if int(Sim.GRID_NORTH) != -22:
		_fail(errors, "the map was not extended to the vexillum row (north %s)" % Sim.GRID_NORTH)
	if int(Sim.VEXILLUM_CELL.x) != 14 or int(Sim.VEXILLUM_CELL.y) != -22:
		_fail(errors, "the vexillum cell is not at 14,-22")
	if int(Sim.ORIFLAMME_CELL.x) != 14 or int(Sim.ORIFLAMME_CELL.y) != -21:
		_fail(errors, "the oriflamme moved off 14,-21")
	if int(Sim.GONFALON_CELL.x) != 14 or int(Sim.GONFALON_CELL.y) != -20:
		_fail(errors, "the gonfalon moved off 14,-20")
	if int(Sim.PENNON_CELL.x) != 14 or int(Sim.PENNON_CELL.y) != -19:
		_fail(errors, "the pennon moved off 14,-19")
	var fresh = Sim.new()
	if fresh.paint_cell(14, -22, Sim.VEXILLUM) == false or int(fresh.get_paint(14, -22)) != Sim.VEXILLUM:
		_fail(errors, "the cell north of the oriflamme rejected the vexillum mark")
	if fresh.paint_cell(14, -21, Sim.VEXILLUM):
		_fail(errors, "the oriflamme cell accepted a vexillum")
	if int(fresh.get_paint(14, -21)) != Sim.EMPTY:
		_fail(errors, "a rejected vexillum painted the oriflamme cell")
	if fresh.paint_cell(14, -22, Sim.ORIFLAMME):
		_fail(errors, "the vexillum cell accepted an oriflamme")
	if int(fresh.get_paint(14, -22)) != Sim.VEXILLUM:
		_fail(errors, "a rejected oriflamme erased the vexillum")
	if fresh.paint_cell(14, -21, Sim.ORIFLAMME) == false or int(fresh.get_paint(14, -21)) != Sim.ORIFLAMME:
		_fail(errors, "the oriflamme cell no longer accepts an oriflamme")
	if fresh.paint_cell(14, -23, Sim.VEXILLUM) or fresh.paint_cell(13, -22, Sim.VEXILLUM) or fresh.paint_cell(15, -22, Sim.VEXILLUM) or fresh.paint_cell(14, -21, Sim.VEXILLUM) or fresh.paint_cell(14, -20, Sim.VEXILLUM):
		_fail(errors, "a cell other than 14,-22 accepted a vexillum")
	if int(fresh.get_paint(14, -21)) != Sim.ORIFLAMME:
		_fail(errors, "a rejected vexillum erased the oriflamme")
	if fresh.paint_cell(Sim.COAST_X, -22, Sim.VEXILLUM):
		_fail(errors, "the brine accepted a vexillum")
	if fresh.paint_cell(Sim.ANTHILL.x, Sim.ANTHILL.y, Sim.VEXILLUM):
		_fail(errors, "the anthill accepted a vexillum")
	var plans := _plans(errors)
	if plans.is_empty():
		return
	var kept = _run_plan(plans, "oriflamme", errors)
	var housed = _run_plan(plans, "vexillum", errors)
	var housed_again = _run_plan(plans, "vexillum", errors)
	var late = _run_plan(plans, "late_vexillum", errors)
	var dry_vexillum = _run_plan(plans, "dry_vexillum", errors)
	var bare = _run_plan(plans, "vexillum_only", errors)
	var no_lowered = _run_plan(plans, "oriflamme_only", errors)
	if kept == null or housed == null or housed_again == null or late == null or dry_vexillum == null or bare == null or no_lowered == null:
		return
	if not kept.is_over() or int(kept.get_beat()) == Sim.VEXILLUMING or int(kept.get_vexillum_housed()) != 0 or int(kept.get_oriflamme_lowered()) != 1 or int(kept.get_oriflamme_left()) != 1 or int(kept.get_gonfalon_left()) != 0 or int(kept.get_pennon_left()) != 0 or int(kept.get_furled()) != 1 or int(kept.get_presented()) != 1 or int(kept.get_coins()) != 2997 or int(kept.get_hired()) != 29 or int(kept.get_yard_left()) != 57:
		_fail(errors, "an oriflamme with no vexillum changed the locked counts (over %s beat %s housed %d lowered %d left %d dipped %d pennon %d furled %d presented %d coins %d hired %d yard %d)" % [kept.is_over(), kept.get_beat(), kept.get_vexillum_housed(), kept.get_oriflamme_lowered(), kept.get_oriflamme_left(), kept.get_gonfalon_left(), kept.get_pennon_left(), kept.get_furled(), kept.get_presented(), kept.get_coins(), kept.get_hired(), kept.get_yard_left()])
	var kept_summary := String(kept.get_summary())
	if kept_summary.to_lower().contains("vexillum") or kept_summary.contains("Housed") or not kept_summary.contains("Lowered 1 on the oriflamme"):
		_fail(errors, "a shut vexillum changed the oriflamme summary: %s" % kept_summary)
	if int(housed.get_vexillum_housed()) != 1 or int(housed.get_oriflamme_left()) != 0 or int(housed.get_oriflamme_lowered()) != 1 or int(housed.get_gonfalon_left()) != 0 or int(housed.get_gonfalon_dipped()) != 1 or int(housed.get_pennon_left()) != 0 or int(housed.get_furled()) != 1 or int(housed.get_presented()) != 1 or int(housed.get_saluted()) != 1 or int(housed.get_dipped()) != 1 or int(housed.get_coins()) != 2997 or int(housed.get_hired()) != 29 or int(housed.get_yard_left()) != 57 or int(housed.get_stored_salt()) != int(kept.get_stored_salt()) or int(housed.get_carted()) != int(kept.get_carted()) or int(housed.get_shipped()) != int(kept.get_shipped()) or int(housed.get_wet_haul()) != int(kept.get_wet_haul()):
		_fail(errors, "housed %d, left %d lowered, lowered %d, dipped left %d, pennon %d, furled %d, presented %d, coins %d, hired %d, yard %d" % [housed.get_vexillum_housed(), housed.get_oriflamme_left(), housed.get_oriflamme_lowered(), housed.get_gonfalon_left(), housed.get_pennon_left(), housed.get_furled(), housed.get_presented(), housed.get_coins(), housed.get_hired(), housed.get_yard_left()])
	if int(housed.get_vexillum_housed()) > int(Sim.VEXILLUM_CAP):
		_fail(errors, "vexillum housed %d, over the cap of %d" % [housed.get_vexillum_housed(), Sim.VEXILLUM_CAP])
	var vexillum_cell: Array = plans["vexillum"]["vexillum"][0]
	var oriflamme_cell: Array = plans["vexillum"]["oriflamme"][0]
	var vexillum_salt: Dictionary = housed.get_cell_salt(int(vexillum_cell[0]), int(vexillum_cell[1]))
	var oriflamme_salt: Dictionary = housed.get_cell_salt(int(oriflamme_cell[0]), int(oriflamme_cell[1]))
	if int(vexillum_salt.get("vexillum", 0)) != 1 or int(oriflamme_salt.get("oriflamme", 0)) != 0 or int(vexillum_salt.get("oriflamme", 0)) != 0:
		_fail(errors, "vexillum cell holds %s, oriflamme holds %s" % [vexillum_salt.get("vexillum", 0), oriflamme_salt.get("oriflamme", 0)])
	var housed_summary := String(housed.get_summary())
	if not housed_summary.contains("Housed 1 on the vexillum") or not housed_summary.contains("Left 0 at the oriflamme") or not housed_summary.contains("Lowered 1 on the oriflamme") or not housed_summary.contains("Left 0 at the gonfalon") or not housed_summary.contains("Dipped 1 on the gonfalon") or not housed_summary.contains("Left 0 at the pennon") or not housed_summary.contains("Furled 1 on the pennon") or not housed_summary.contains("Coins 2997") or not housed_summary.contains("Hired 29") or not housed_summary.contains("Left 57"):
		_fail(errors, "vexillum summary does not name the housing: %s" % housed_summary)
	if int(housed_again.get_vexillum_housed()) != 1 or int(housed_again.get_oriflamme_left()) != 0 or int(housed_again.get_oriflamme_lowered()) != 1 or int(housed_again.get_furled()) != 1 or int(housed_again.get_presented()) != 1 or int(housed_again.get_coins()) != 2997 or int(housed_again.get_hired()) != 29 or String(housed_again.get_summary()) != housed_summary:
		_fail(errors, "repeated vexillum paint housed %d then %d" % [housed.get_vexillum_housed(), housed_again.get_vexillum_housed()])
	if int(late.get_vexillum_housed()) != 1 or int(late.get_oriflamme_left()) != 0 or int(late.get_oriflamme_lowered()) != 1 or int(late.get_furled()) != 1 or int(late.get_presented()) != 1 or int(late.get_coins()) != 2997 or int(late.get_hired()) != 29 or int(late.get_yard_left()) != 57 or int(late.get_stored_salt()) != 2997:
		_fail(errors, "painting the vexillum at the oriflamme beat (housed %d left %d lowered %d) did not match painting it early" % [late.get_vexillum_housed(), late.get_oriflamme_left(), late.get_oriflamme_lowered()])
	_assert_chain(dry_vexillum, errors, "dry vexillum", 0, 1032, 1032, 1032, 1032, 10, 0, 8, 6, 4, 3, 2, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
	if int(dry_vexillum.get_vexillum_housed()) != 1 or int(dry_vexillum.get_oriflamme_left()) != 0 or int(dry_vexillum.get_oriflamme_lowered()) != 1 or int(dry_vexillum.get_furled()) != 1 or int(dry_vexillum.get_presented()) != 1 or int(dry_vexillum.get_yard_left()) != 0 or int(dry_vexillum.get_wet_haul()) != 0:
		_fail(errors, "dry vexillum changed the short crew (wet %d housed %d left %d lowered %d furled %d presented %d yard %d)" % [dry_vexillum.get_wet_haul(), dry_vexillum.get_vexillum_housed(), dry_vexillum.get_oriflamme_left(), dry_vexillum.get_oriflamme_lowered(), dry_vexillum.get_furled(), dry_vexillum.get_presented(), dry_vexillum.get_yard_left()])
	if not String(dry_vexillum.get_summary()).contains("Housed 1 on the vexillum") or not String(dry_vexillum.get_summary()).contains("Left 0 at the oriflamme"):
		_fail(errors, "dry vexillum summary does not name the cap: %s" % dry_vexillum.get_summary())
	if int(bare.get_vexillum_housed()) != 0 or int(bare.get_oriflamme_lowered()) != 0 or int(bare.get_furled()) != 0 or int(bare.get_presented()) != 0 or int(bare.get_coins()) != int(no_lowered.get_coins()) or int(bare.get_hired()) != int(no_lowered.get_hired()) or int(bare.get_stored_salt()) != int(no_lowered.get_stored_salt()) or String(bare.get_summary()) != String(no_lowered.get_summary()):
		_fail(errors, "a vexillum with nobody lowered housed %d lowered %d furled %d presented %d coins %d hired %d" % [bare.get_vexillum_housed(), bare.get_oriflamme_lowered(), bare.get_furled(), bare.get_presented(), bare.get_coins(), bare.get_hired()])
	if String(bare.get_summary()).to_lower().contains("vexillum") or String(bare.get_summary()).contains("Housed"):
		_fail(errors, "an empty vexillum was named: %s" % bare.get_summary())
	_assert_pop(housed, errors, "vexillum plan")
	_assert_pop(late, errors, "late_vexillum")
	_assert_pop(dry_vexillum, errors, "dry_vexillum")
	_assert_pop(bare, errors, "vexillum_only")
	_assert_pop(kept, errors, "oriflamme without vexillum")
	var shore = _prepare_plan(plans, "vexillum", errors)
	if shore == null:
		return
	var shore_guard := 0
	var shore_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + int(Sim.STANDARD_TICK) + int(Sim.JACK_TICK) + int(Sim.ENSIGN_TICK) + int(Sim.BURGEE_TICK) + int(Sim.CORNET_TICK) + int(Sim.GUIDON_TICK) + int(Sim.FANION_TICK) + int(Sim.PENNON_TICK) + int(Sim.GONFALON_TICK) + int(Sim.ORIFLAMME_TICK) + 2
	while int(shore.get_beat()) != Sim.VEXILLUMING and not shore.is_over() and shore_guard < shore_limit:
		shore.tick()
		shore_guard += 1
	if int(shore.get_beat()) != Sim.VEXILLUMING or shore.is_over():
		_fail(errors, "the oriflamme beat did not open a vexillum beat for the cap check")
		return
	if int(shore.get_ticks_until_rain()) != int(Sim.VEXILLUM_TICK):
		_fail(errors, "vexillum countdown started at %d, expected %d" % [shore.get_ticks_until_rain(), Sim.VEXILLUM_TICK])
	if int(shore.get_vexillum_housed()) != 0 or int(shore.get_oriflamme_left()) != 1 or int(shore.get_oriflamme_lowered()) != 1 or int(shore.get_gonfalon_left()) != 0 or int(shore.get_pennon_left()) != 0 or int(shore.get_furled()) != 1 or int(shore.get_presented()) != 1 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29 or int(shore.get_yard_left()) != 57:
		_fail(errors, "vexillum opened early (housed %d left %d lowered %d dipped %d pennon %d furled %d presented %d coins %d hired %d)" % [shore.get_vexillum_housed(), shore.get_oriflamme_left(), shore.get_oriflamme_lowered(), shore.get_gonfalon_left(), shore.get_pennon_left(), shore.get_furled(), shore.get_presented(), shore.get_coins(), shore.get_hired()])
	var saw_cap := false
	var house_guard := 0
	while not shore.is_over() and house_guard < int(Sim.VEXILLUM_TICK) + 2:
		shore.tick()
		house_guard += 1
		if int(shore.get_vexillum_housed()) == int(Sim.VEXILLUM_CAP) and int(shore.get_oriflamme_left()) == 0 and int(shore.get_oriflamme_lowered()) == 1 and int(shore.get_furled()) == 1 and int(shore.get_presented()) == 1 and int(shore.get_coins()) == 2997 and int(shore.get_hired()) == 29 and int(shore.get_ticks_until_rain()) > 0:
			saw_cap = true
			var ticks_left := int(shore.get_ticks_until_rain())
			shore.tick()
			if int(shore.get_vexillum_housed()) != int(Sim.VEXILLUM_CAP) or int(shore.get_oriflamme_left()) != 0 or int(shore.get_oriflamme_lowered()) != 1 or int(shore.get_furled()) != 1 or int(shore.get_presented()) != 1 or int(shore.get_coins()) != 2997 or int(shore.get_hired()) != 29:
				_fail(errors, "the vexillum kept housing after the cap (housed %d left %d lowered %d furled %d presented %d)" % [shore.get_vexillum_housed(), shore.get_oriflamme_left(), shore.get_oriflamme_lowered(), shore.get_furled(), shore.get_presented()])
			elif not shore.is_over() and int(shore.get_ticks_until_rain()) >= ticks_left:
				_fail(errors, "the vexillum beat did not spend a tick after the cap")
			break
	if not saw_cap:
		_fail(errors, "the vexillum did not stop at %d while ticks remained (housed %d left %d lowered %d ticks %d)" % [Sim.VEXILLUM_CAP, shore.get_vexillum_housed(), shore.get_oriflamme_left(), shore.get_oriflamme_lowered(), shore.get_ticks_until_rain()])
	var end_guard := 0
	while not shore.is_over() and end_guard < int(Sim.VEXILLUM_TICK) + 2:
		shore.tick()
		end_guard += 1
		if int(shore.get_vexillum_housed()) != 1 or int(shore.get_oriflamme_left()) != 0 or int(shore.get_oriflamme_lowered()) != 1 or int(shore.get_furled()) != 1 or int(shore.get_presented()) != 1:
			_fail(errors, "the vexillum housed again after the cap (housed %d left %d lowered %d furled %d presented %d)" % [shore.get_vexillum_housed(), shore.get_oriflamme_left(), shore.get_oriflamme_lowered(), shore.get_furled(), shore.get_presented()])
			break
	if not shore.is_over():
		_fail(errors, "the vexillum beat did not end the scenario")
	print("vexillum housed %d left oriflamme %d lowered %d dipped left %d pennon %d furled %d presented %d coins %d hired %d; no vexillum housed %d lowered %d left %d dipped %d pennon %d furled %d presented %d coins %d hired %d; vexillum without a lowered hire housed %d coins %d hired %d" % [housed.get_vexillum_housed(), housed.get_oriflamme_left(), housed.get_oriflamme_lowered(), housed.get_gonfalon_left(), housed.get_pennon_left(), housed.get_furled(), housed.get_presented(), housed.get_coins(), housed.get_hired(), kept.get_vexillum_housed(), kept.get_oriflamme_lowered(), kept.get_oriflamme_left(), kept.get_gonfalon_left(), kept.get_pennon_left(), kept.get_furled(), kept.get_presented(), kept.get_coins(), kept.get_hired(), bare.get_vexillum_housed(), bare.get_coins(), bare.get_hired()])


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
	if plan.has("after_bell"):
		var horn_guard := 0
		var horn_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + 2
		while int(sim.get_beat()) != Sim.HORNING and not sim.is_over() and horn_guard < horn_limit:
			sim.tick()
			horn_guard += 1
		if int(sim.get_beat()) != Sim.HORNING or sim.is_over():
			_fail(errors, "%s did not open the horn beat after the bell" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.HORN_TICK):
			_fail(errors, "%s horn countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.HORN_TICK,
			])
			return null
		var horn_before := errors.size()
		_apply_marks(sim, plan["after_bell"], errors)
		if errors.size() > horn_before:
			return null
	if plan.has("after_horn"):
		var flag_guard := 0
		var flag_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + 2
		while int(sim.get_beat()) != Sim.FLAGGING and not sim.is_over() and flag_guard < flag_limit:
			sim.tick()
			flag_guard += 1
		if int(sim.get_beat()) != Sim.FLAGGING or sim.is_over():
			_fail(errors, "%s did not open the flag beat after the horn" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.FLAG_TICK):
			_fail(errors, "%s flag countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.FLAG_TICK,
			])
			return null
		var flag_before := errors.size()
		_apply_marks(sim, plan["after_horn"], errors)
		if errors.size() > flag_before:
			return null
	if plan.has("after_flag"):
		var banner_guard := 0
		var banner_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + 2
		while int(sim.get_beat()) != Sim.BANNERING and not sim.is_over() and banner_guard < banner_limit:
			sim.tick()
			banner_guard += 1
		if int(sim.get_beat()) != Sim.BANNERING or sim.is_over():
			_fail(errors, "%s did not open the banner beat after the flag" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.BANNER_TICK):
			_fail(errors, "%s banner countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.BANNER_TICK,
			])
			return null
		var banner_before := errors.size()
		_apply_marks(sim, plan["after_flag"], errors)
		if errors.size() > banner_before:
			return null
	if plan.has("after_banner"):
		var pennant_guard := 0
		var pennant_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + 2
		while int(sim.get_beat()) != Sim.PENNANTING and not sim.is_over() and pennant_guard < pennant_limit:
			sim.tick()
			pennant_guard += 1
		if int(sim.get_beat()) != Sim.PENNANTING or sim.is_over():
			_fail(errors, "%s did not open the pennant beat after the banner" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.PENNANT_TICK):
			_fail(errors, "%s pennant countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.PENNANT_TICK,
			])
			return null
		var pennant_before := errors.size()
		_apply_marks(sim, plan["after_banner"], errors)
		if errors.size() > pennant_before:
			return null
	if plan.has("after_pennant"):
		var standard_guard := 0
		var standard_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + 2
		while int(sim.get_beat()) != Sim.STANDARDING and not sim.is_over() and standard_guard < standard_limit:
			sim.tick()
			standard_guard += 1
		if int(sim.get_beat()) != Sim.STANDARDING or sim.is_over():
			_fail(errors, "%s did not open the standard beat after the pennant" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.STANDARD_TICK):
			_fail(errors, "%s standard countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.STANDARD_TICK,
			])
			return null
		var standard_before := errors.size()
		_apply_marks(sim, plan["after_pennant"], errors)
		if errors.size() > standard_before:
			return null
	if plan.has("after_standard"):
		var jack_guard := 0
		var jack_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + int(Sim.STANDARD_TICK) + 2
		while int(sim.get_beat()) != Sim.JACKING and not sim.is_over() and jack_guard < jack_limit:
			sim.tick()
			jack_guard += 1
		if int(sim.get_beat()) != Sim.JACKING or sim.is_over():
			_fail(errors, "%s did not open the jack beat after the standard" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.JACK_TICK):
			_fail(errors, "%s jack countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.JACK_TICK,
			])
			return null
		var jack_before := errors.size()
		_apply_marks(sim, plan["after_standard"], errors)
		if errors.size() > jack_before:
			return null
	if plan.has("after_jack"):
		var ensign_guard := 0
		var ensign_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + int(Sim.STANDARD_TICK) + int(Sim.JACK_TICK) + 2
		while int(sim.get_beat()) != Sim.ENSIGNING and not sim.is_over() and ensign_guard < ensign_limit:
			sim.tick()
			ensign_guard += 1
		if int(sim.get_beat()) != Sim.ENSIGNING or sim.is_over():
			_fail(errors, "%s did not open the ensign beat after the jack" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.ENSIGN_TICK):
			_fail(errors, "%s ensign countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.ENSIGN_TICK,
			])
			return null
		var ensign_before := errors.size()
		_apply_marks(sim, plan["after_jack"], errors)
		if errors.size() > ensign_before:
			return null
	if plan.has("after_ensign"):
		var burgee_guard := 0
		var burgee_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + int(Sim.STANDARD_TICK) + int(Sim.JACK_TICK) + int(Sim.ENSIGN_TICK) + 2
		while int(sim.get_beat()) != Sim.BURGEEING and not sim.is_over() and burgee_guard < burgee_limit:
			sim.tick()
			burgee_guard += 1
		if int(sim.get_beat()) != Sim.BURGEEING or sim.is_over():
			_fail(errors, "%s did not open the burgee beat after the ensign" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.BURGEE_TICK):
			_fail(errors, "%s burgee countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.BURGEE_TICK,
			])
			return null
		var burgee_before := errors.size()
		_apply_marks(sim, plan["after_ensign"], errors)
		if errors.size() > burgee_before:
			return null
	if plan.has("after_burgee"):
		var cornet_guard := 0
		var cornet_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + int(Sim.STANDARD_TICK) + int(Sim.JACK_TICK) + int(Sim.ENSIGN_TICK) + int(Sim.BURGEE_TICK) + 2
		while int(sim.get_beat()) != Sim.CORNETING and not sim.is_over() and cornet_guard < cornet_limit:
			sim.tick()
			cornet_guard += 1
		if int(sim.get_beat()) != Sim.CORNETING or sim.is_over():
			_fail(errors, "%s did not open the cornet beat after the burgee" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.CORNET_TICK):
			_fail(errors, "%s cornet countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.CORNET_TICK,
			])
			return null
		var cornet_before := errors.size()
		_apply_marks(sim, plan["after_burgee"], errors)
		if errors.size() > cornet_before:
			return null
	if plan.has("after_cornet"):
		var guidon_guard := 0
		var guidon_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + int(Sim.STANDARD_TICK) + int(Sim.JACK_TICK) + int(Sim.ENSIGN_TICK) + int(Sim.BURGEE_TICK) + int(Sim.CORNET_TICK) + 2
		while int(sim.get_beat()) != Sim.GUIDONING and not sim.is_over() and guidon_guard < guidon_limit:
			sim.tick()
			guidon_guard += 1
		if int(sim.get_beat()) != Sim.GUIDONING or sim.is_over():
			_fail(errors, "%s did not open the guidon beat after the cornet" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.GUIDON_TICK):
			_fail(errors, "%s guidon countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.GUIDON_TICK,
			])
			return null
		var guidon_before := errors.size()
		_apply_marks(sim, plan["after_cornet"], errors)
		if errors.size() > guidon_before:
			return null
	if plan.has("after_guidon"):
		var fanion_guard := 0
		var fanion_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + int(Sim.STANDARD_TICK) + int(Sim.JACK_TICK) + int(Sim.ENSIGN_TICK) + int(Sim.BURGEE_TICK) + int(Sim.CORNET_TICK) + int(Sim.GUIDON_TICK) + 2
		while int(sim.get_beat()) != Sim.FANIONING and not sim.is_over() and fanion_guard < fanion_limit:
			sim.tick()
			fanion_guard += 1
		if int(sim.get_beat()) != Sim.FANIONING or sim.is_over():
			_fail(errors, "%s did not open the fanion beat after the guidon" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.FANION_TICK):
			_fail(errors, "%s fanion countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.FANION_TICK,
			])
			return null
		var fanion_before := errors.size()
		_apply_marks(sim, plan["after_guidon"], errors)
		if errors.size() > fanion_before:
			return null
	if plan.has("after_fanion"):
		var pennon_guard := 0
		var pennon_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + int(Sim.STANDARD_TICK) + int(Sim.JACK_TICK) + int(Sim.ENSIGN_TICK) + int(Sim.BURGEE_TICK) + int(Sim.CORNET_TICK) + int(Sim.GUIDON_TICK) + 2
		while int(sim.get_beat()) != Sim.FANIONING and not sim.is_over() and pennon_guard < pennon_limit:
			sim.tick()
			pennon_guard += 1
		if int(sim.get_beat()) != Sim.FANIONING or sim.is_over():
			_fail(errors, "%s did not open the fanion beat before the pennon" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.FANION_TICK):
			_fail(errors, "%s fanion countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.FANION_TICK,
			])
			return null
		var pennon_before := errors.size()
		_apply_marks(sim, plan["after_fanion"], errors)
		if errors.size() > pennon_before:
			return null
	if plan.has("after_pennon"):
		var gonfalon_guard := 0
		var gonfalon_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + int(Sim.STANDARD_TICK) + int(Sim.JACK_TICK) + int(Sim.ENSIGN_TICK) + int(Sim.BURGEE_TICK) + int(Sim.CORNET_TICK) + int(Sim.GUIDON_TICK) + int(Sim.FANION_TICK) + 2
		while int(sim.get_beat()) != Sim.PENNONING and not sim.is_over() and gonfalon_guard < gonfalon_limit:
			sim.tick()
			gonfalon_guard += 1
		if int(sim.get_beat()) != Sim.PENNONING or sim.is_over():
			_fail(errors, "%s did not open the pennon beat before the gonfalon" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.PENNON_TICK):
			_fail(errors, "%s pennon countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.PENNON_TICK,
			])
			return null
		var gonfalon_before := errors.size()
		_apply_marks(sim, plan["after_pennon"], errors)
		if errors.size() > gonfalon_before:
			return null
	if plan.has("after_gonfalon"):
		var oriflamme_guard := 0
		var oriflamme_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + int(Sim.STANDARD_TICK) + int(Sim.JACK_TICK) + int(Sim.ENSIGN_TICK) + int(Sim.BURGEE_TICK) + int(Sim.CORNET_TICK) + int(Sim.GUIDON_TICK) + int(Sim.FANION_TICK) + int(Sim.PENNON_TICK) + 2
		while int(sim.get_beat()) != Sim.GONFALONING and not sim.is_over() and oriflamme_guard < oriflamme_limit:
			sim.tick()
			oriflamme_guard += 1
		if int(sim.get_beat()) != Sim.GONFALONING or sim.is_over():
			_fail(errors, "%s did not open the gonfalon beat before the oriflamme" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.GONFALON_TICK):
			_fail(errors, "%s gonfalon countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.GONFALON_TICK,
			])
			return null
		var oriflamme_before := errors.size()
		_apply_marks(sim, plan["after_gonfalon"], errors)
		if errors.size() > oriflamme_before:
			return null
	if plan.has("after_oriflamme"):
		var vexillum_guard := 0
		var vexillum_limit := int(Sim.RAIN_TICK) + int(Sim.DRY_TICK) + int(Sim.CART_TICK) + int(Sim.SHIP_TICK) + int(Sim.MARKET_TICK) + int(Sim.YARD_TICK) + int(Sim.BUNK_TICK) + int(Sim.LOFT_TICK) + int(Sim.GATE_TICK) + int(Sim.WAGE_TICK) + int(Sim.RELIEF_TICK) + int(Sim.WATCH_TICK) + int(Sim.LAMP_TICK) + int(Sim.BELL_TICK) + int(Sim.HORN_TICK) + int(Sim.FLAG_TICK) + int(Sim.BANNER_TICK) + int(Sim.PENNANT_TICK) + int(Sim.STANDARD_TICK) + int(Sim.JACK_TICK) + int(Sim.ENSIGN_TICK) + int(Sim.BURGEE_TICK) + int(Sim.CORNET_TICK) + int(Sim.GUIDON_TICK) + int(Sim.FANION_TICK) + int(Sim.PENNON_TICK) + int(Sim.GONFALON_TICK) + 2
		while int(sim.get_beat()) != Sim.ORIFLAMMING and not sim.is_over() and vexillum_guard < vexillum_limit:
			sim.tick()
			vexillum_guard += 1
		if int(sim.get_beat()) != Sim.ORIFLAMMING or sim.is_over():
			_fail(errors, "%s did not open the oriflamme beat before the vexillum" % plan_name)
			return null
		if int(sim.get_ticks_until_rain()) != int(Sim.ORIFLAMME_TICK):
			_fail(errors, "%s oriflamme countdown started at %d, expected %d" % [
				plan_name, sim.get_ticks_until_rain(), Sim.ORIFLAMME_TICK,
			])
			return null
		var vexillum_before := errors.size()
		_apply_marks(sim, plan["after_oriflamme"], errors)
		if errors.size() > vexillum_before:
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
	if plan.has("horn"):
		_apply_cells(sim, plan["horn"], Sim.HORN, errors)
	if plan.has("flag"):
		_apply_cells(sim, plan["flag"], Sim.FLAG, errors)
	if plan.has("banner"):
		_apply_cells(sim, plan["banner"], Sim.BANNER, errors)
	if plan.has("pennant"):
		_apply_cells(sim, plan["pennant"], Sim.PENNANT, errors)
	if plan.has("standard"):
		_apply_cells(sim, plan["standard"], Sim.STANDARD, errors)
	if plan.has("jack"):
		_apply_cells(sim, plan["jack"], Sim.JACK, errors)
	if plan.has("ensign"):
		_apply_cells(sim, plan["ensign"], Sim.ENSIGN, errors)
	if plan.has("burgee"):
		_apply_cells(sim, plan["burgee"], Sim.BURGEE, errors)
	if plan.has("cornet"):
		_apply_cells(sim, plan["cornet"], Sim.CORNET, errors)
	if plan.has("guidon"):
		_apply_cells(sim, plan["guidon"], Sim.GUIDON, errors)
	if plan.has("fanion"):
		_apply_cells(sim, plan["fanion"], Sim.FANION, errors)
	if plan.has("pennon"):
		_apply_cells(sim, plan["pennon"], Sim.PENNON, errors)
	if plan.has("gonfalon"):
		_apply_cells(sim, plan["gonfalon"], Sim.GONFALON, errors)
	if plan.has("oriflamme"):
		_apply_cells(sim, plan["oriflamme"], Sim.ORIFLAMME, errors)
	if plan.has("vexillum"):
		_apply_cells(sim, plan["vexillum"], Sim.VEXILLUM, errors)
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
