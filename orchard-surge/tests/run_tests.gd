extends SceneTree

## Headless checks for Orchard Surge. No window. Non-zero exit if any check fails.
##   godot --headless --path orchard-surge --script res://tests/run_tests.gd

const Sim = preload("res://sim/orchard_sim.gd")
const Catalog = preload("res://sim/plant_catalog.gd")
const Tooltip = preload("res://ui/plant_tooltip.gd")

var _failures := 0


func _initialize() -> void:
	print("Orchard Surge tests")
	print("Godot ", Engine.get_version_info()["string"])
	_test_tooltip_matches_sim()
	_test_planting_and_movement()
	_test_stationary_dies()
	_test_scripted_survives()
	_test_shroud_rule()
	_test_later_nights()
	_test_rind_rule()
	_test_deeper_nights()
	_test_pitch_rule()
	_test_eighth_nights()
	_test_frost_rule()
	_test_tenth_nights()
	_test_web_rule()
	_test_twelfth_nights()
	_test_glass_rule()
	_test_fourteenth_nights()
	_test_scale_rule()
	_test_sixteenth_nights()
	_test_mail_rule()
	_test_eighteenth_nights()
	_test_hide_rule()
	_test_twentieth_nights()
	_test_dusk_rule()
	_test_twenty_second_nights()
	_test_veil_rule()
	_test_twenty_fourth_nights()
	_test_pall_rule()
	_test_twenty_sixth_nights()
	_test_gloom_rule()
	_test_twenty_eighth_nights()
	_test_murk_rule()
	_test_thirtieth_nights()
	_test_dread_rule()
	_test_thirty_second_nights()
	_test_woe_rule()
	_test_thirty_fourth_nights()
	_test_blight_rule()
	_test_thirty_sixth_nights()
	_test_rot_rule()
	_test_thirty_eighth_nights()
	_test_mildew_rule()
	_test_fortieth_nights()
	_test_rust_rule()
	_test_forty_second_nights()
	_test_scab_rule()
	_test_forty_fourth_nights()
	_test_spot_rule()
	_test_forty_sixth_nights()
	_test_fog_visibility()
	_test_no_dominance()
	_test_scene_shows_tooltips()
	call_deferred("_finish")


var _scene_node = null


func _finish() -> void:
	await process_frame
	_test_card_layout()
	if _scene_node != null:
		_scene_node.queue_free()
	if _failures > 0:
		printerr("%d test(s) failed" % _failures)
		quit(1)
	else:
		print("ALL TESTS PASSED")
		quit(0)


func _expect(ok: bool, msg: String) -> void:
	if ok:
		print("  PASS  ", msg)
	else:
		printerr("  FAIL  ", msg)
		_failures += 1


func _test_tooltip_matches_sim() -> void:
	print("tooltip numbers match planted sim stats and dealt damage")
	var planter = Sim.new(3)
	planter.seeds = Catalog.COUNT
	var tiles := [Vector2i(2, 2), Vector2i(4, 2), Vector2i(6, 2), Vector2i(8, 2), Vector2i(10, 2), Vector2i(12, 2), Vector2i(12, 4), Vector2i(10, 4), Vector2i(8, 4), Vector2i(6, 4), Vector2i(4, 4), Vector2i(2, 4), Vector2i(2, 6), Vector2i(4, 6), Vector2i(6, 6), Vector2i(8, 6), Vector2i(10, 6), Vector2i(12, 6), Vector2i(12, 8), Vector2i(10, 8), Vector2i(8, 8), Vector2i(6, 8), Vector2i(4, 8), Vector2i(2, 8), Vector2i(13, 2), Vector2i(13, 4)]
	for kind in Catalog.COUNT:
		var cmd = Sim.Command.new()
		cmd.plant_kind = kind
		cmd.tile = tiles[kind]
		planter.step(cmd)
		var plant = planter.plant_of_kind(kind)
		var stats := Catalog.get_stats(kind)
		_expect(plant != null, "planted %s" % str(stats["name"]))
		if plant == null:
			continue
		_expect(int(plant.damage) == int(stats["damage"]), "%s damage constant copied" % stats["name"])
		_expect(int(plant.fire_ticks) == int(stats["fire_ticks"]), "%s fire ticks copied" % stats["name"])
		_expect(is_equal_approx(float(plant.light_radius), float(stats["light_radius"])), "%s light copied" % stats["name"])
		_expect(is_equal_approx(float(plant.weapon_range), float(stats["weapon_range"])), "%s range copied" % stats["name"])
		_expect(is_equal_approx(float(plant.projectile_speed), float(stats["projectile_speed"])), "%s projectile speed copied" % stats["name"])
		_expect(is_equal_approx(float(plant.slow_factor), float(stats["slow_factor"])), "%s slow factor copied" % stats["name"])
		_expect(int(plant.slow_ticks) == int(stats["slow_ticks"]), "%s slow ticks copied" % stats["name"])
		_expect(is_equal_approx(float(plant.splash_radius), float(stats["splash_radius"])), "%s splash copied" % stats["name"])
		_expect(bool(plant.burns_shroud) == bool(stats["burns_shroud"]), "%s shroud rule copied" % stats["name"])
		_expect(bool(plant.cracks_rind) == bool(stats["cracks_rind"]), "%s rind rule copied" % stats["name"])
		_expect(bool(plant.melts_pitch) == bool(stats["melts_pitch"]), "%s pitch rule copied" % stats["name"])
		_expect(bool(plant.thaws_frost) == bool(stats["thaws_frost"]), "%s frost rule copied" % stats["name"])
		_expect(bool(plant.cuts_web) == bool(stats["cuts_web"]), "%s web rule copied" % stats["name"])
		_expect(bool(plant.cracks_glass) == bool(stats["cracks_glass"]), "%s glass rule copied" % stats["name"])
		_expect(bool(plant.strips_scale) == bool(stats["strips_scale"]), "%s scale rule copied" % stats["name"])
		_expect(bool(plant.cracks_mail) == bool(stats["cracks_mail"]), "%s mail rule copied" % stats["name"])
		_expect(bool(plant.splits_hide) == bool(stats["splits_hide"]), "%s hide rule copied" % stats["name"])
		_expect(bool(plant.shades_dusk) == bool(stats["shades_dusk"]), "%s dusk rule copied" % stats["name"])
		_expect(bool(plant.cowls_veil) == bool(stats["cowls_veil"]), "%s veil rule copied" % stats["name"])
		_expect(bool(plant.hoods_pall) == bool(stats["hoods_pall"]), "%s pall rule copied" % stats["name"])
		_expect(bool(plant.cloaks_gloom) == bool(stats["cloaks_gloom"]), "%s gloom rule copied" % stats["name"])
		_expect(bool(plant.capes_murk) == bool(stats["capes_murk"]), "%s murk rule copied" % stats["name"])
		_expect(bool(plant.shawls_dread) == bool(stats["shawls_dread"]), "%s dread rule copied" % stats["name"])
		_expect(bool(plant.stoles_woe) == bool(stats["stoles_woe"]), "%s woe rule copied" % stats["name"])
		_expect(bool(plant.mantles_blight) == bool(stats["mantles_blight"]), "%s blight rule copied" % stats["name"])
		_expect(bool(plant.tippets_rot) == bool(stats["tippets_rot"]), "%s rot rule copied" % stats["name"])
		_expect(bool(plant.wimples_mildew) == bool(stats["wimples_mildew"]), "%s mildew rule copied" % stats["name"])
		_expect(bool(plant.albs_rust) == bool(stats["albs_rust"]), "%s rust rule copied" % stats["name"])
		_expect(bool(plant.amices_scab) == bool(stats["amices_scab"]), "%s scab rule copied" % stats["name"])
		_expect(bool(plant.orphreys_spot) == bool(stats["orphreys_spot"]), "%s spot rule copied" % stats["name"])
		_expect(bool(plant.casts_light) == bool(stats["casts_light"]), "%s light rule copied" % stats["name"])
		var shown := _parse_tooltip(kind)
		_expect(int(shown["damage"]) == int(plant.damage), "%s tooltip damage" % stats["name"])
		_expect(is_equal_approx(float(shown["fire"]), float(plant.fire_ticks) * Catalog.DT), "%s tooltip fire interval" % stats["name"])
		_expect(is_equal_approx(float(shown["light"]), float(plant.light_radius)), "%s tooltip light" % stats["name"])
		if int(plant.slow_ticks) == 0:
			_expect(bool(shown["slow_none"]), "%s tooltip says no slow" % stats["name"])
		else:
			_expect(is_equal_approx(float(shown["slow_factor"]), float(plant.slow_factor)), "%s tooltip slow factor" % stats["name"])
			_expect(is_equal_approx(float(shown["slow_duration"]), float(plant.slow_ticks) * Catalog.DT), "%s tooltip slow duration" % stats["name"])
		_expect(is_equal_approx(float(shown["splash"]), float(plant.splash_radius)), "%s tooltip splash" % stats["name"])
		var shroud_line := Tooltip.stat_lines(kind)[7]
		if bool(plant.burns_shroud):
			_expect(shroud_line == "Shroud: burns", "%s tooltip burns shroud" % stats["name"])
		else:
			_expect(shroud_line == "Shroud: none", "%s tooltip has no shroud burn" % stats["name"])
		var rind_line := Tooltip.stat_lines(kind)[8]
		if bool(plant.cracks_rind):
			_expect(rind_line == "Rind: cracks", "%s tooltip cracks rind" % stats["name"])
		else:
			_expect(rind_line == "Rind: none", "%s tooltip has no rind crack" % stats["name"])
		var pitch_line := Tooltip.stat_lines(kind)[9]
		if bool(plant.melts_pitch):
			_expect(pitch_line == "Pitch: melts", "%s tooltip melts pitch" % stats["name"])
		else:
			_expect(pitch_line == "Pitch: none", "%s tooltip has no pitch melt" % stats["name"])
		var frost_line := Tooltip.stat_lines(kind)[10]
		if bool(plant.thaws_frost):
			_expect(frost_line == "Frost: thaws", "%s tooltip thaws frost" % stats["name"])
		else:
			_expect(frost_line == "Frost: none", "%s tooltip has no frost thaw" % stats["name"])
		var web_line := Tooltip.stat_lines(kind)[11]
		if bool(plant.cuts_web):
			_expect(web_line == "Web: cuts", "%s tooltip cuts web" % stats["name"])
		else:
			_expect(web_line == "Web: none", "%s tooltip has no web cut" % stats["name"])
		var glass_line := Tooltip.stat_lines(kind)[12]
		if bool(plant.cracks_glass):
			_expect(glass_line == "Glass: cracks", "%s tooltip cracks glass" % stats["name"])
		else:
			_expect(glass_line == "Glass: none", "%s tooltip has no glass crack" % stats["name"])
		var scale_line := Tooltip.stat_lines(kind)[13]
		if bool(plant.strips_scale):
			_expect(scale_line == "Scale: strips", "%s tooltip strips scale" % stats["name"])
		else:
			_expect(scale_line == "Scale: none", "%s tooltip has no scale strip" % stats["name"])
		var mail_line := Tooltip.stat_lines(kind)[14]
		if bool(plant.cracks_mail):
			_expect(mail_line == "Mail: cracks", "%s tooltip cracks mail" % stats["name"])
		else:
			_expect(mail_line == "Mail: none", "%s tooltip has no mail crack" % stats["name"])
		var hide_line := Tooltip.stat_lines(kind)[15]
		if bool(plant.splits_hide):
			_expect(hide_line == "Hide: splits", "%s tooltip splits hide" % stats["name"])
		else:
			_expect(hide_line == "Hide: none", "%s tooltip has no hide split" % stats["name"])
		var dusk_line := Tooltip.stat_lines(kind)[16]
		if bool(plant.shades_dusk):
			_expect(dusk_line == "Dusk: shades", "%s tooltip shades dusk" % stats["name"])
		else:
			_expect(dusk_line == "Dusk: none", "%s tooltip has no dusk shade" % stats["name"])
		var veil_line := Tooltip.stat_lines(kind)[17]
		if bool(plant.cowls_veil):
			_expect(veil_line == "Veil: cowls", "%s tooltip cowls veil" % stats["name"])
		else:
			_expect(veil_line == "Veil: none", "%s tooltip has no veil cowl" % stats["name"])
		var pall_line := Tooltip.stat_lines(kind)[18]
		if bool(plant.hoods_pall):
			_expect(pall_line == "Pall: hoods", "%s tooltip hoods pall" % stats["name"])
		else:
			_expect(pall_line == "Pall: none", "%s tooltip has no pall hood" % stats["name"])
		var gloom_line := Tooltip.stat_lines(kind)[19]
		if bool(plant.cloaks_gloom):
			_expect(gloom_line == "Gloom: cloaks", "%s tooltip cloaks gloom" % stats["name"])
		else:
			_expect(gloom_line == "Gloom: none", "%s tooltip has no gloom cloak" % stats["name"])
		var murk_line := Tooltip.stat_lines(kind)[20]
		if bool(plant.capes_murk):
			_expect(murk_line == "Murk: capes", "%s tooltip capes murk" % stats["name"])
		else:
			_expect(murk_line == "Murk: none", "%s tooltip has no murk cape" % stats["name"])
		var dread_line := Tooltip.stat_lines(kind)[21]
		if bool(plant.shawls_dread):
			_expect(dread_line == "Dread: shawls", "%s tooltip shawls dread" % stats["name"])
		else:
			_expect(dread_line == "Dread: none", "%s tooltip has no dread shawl" % stats["name"])
		var woe_line := Tooltip.stat_lines(kind)[22]
		if bool(plant.stoles_woe):
			_expect(woe_line == "Woe: stoles", "%s tooltip stoles woe" % stats["name"])
		else:
			_expect(woe_line == "Woe: none", "%s tooltip has no woe stole" % stats["name"])
		var blight_line := Tooltip.stat_lines(kind)[23]
		if bool(plant.mantles_blight):
			_expect(blight_line == "Blight: mantles", "%s tooltip mantles blight" % stats["name"])
		else:
			_expect(blight_line == "Blight: none", "%s tooltip has no blight mantle" % stats["name"])
		var rot_line := Tooltip.stat_lines(kind)[24]
		if bool(plant.tippets_rot):
			_expect(rot_line == "Rot: tippets", "%s tooltip tippets rot" % stats["name"])
		else:
			_expect(rot_line == "Rot: none", "%s tooltip has no rot tippet" % stats["name"])
		var mildew_line := Tooltip.stat_lines(kind)[25]
		if bool(plant.wimples_mildew):
			_expect(mildew_line == "Mildew: wimples", "%s tooltip wimples mildew" % stats["name"])
		else:
			_expect(mildew_line == "Mildew: none", "%s tooltip has no mildew wimple" % stats["name"])
		var rust_line := Tooltip.stat_lines(kind)[26]
		if bool(plant.albs_rust):
			_expect(rust_line == "Rust: albs", "%s tooltip albs rust" % stats["name"])
		else:
			_expect(rust_line == "Rust: none", "%s tooltip has no rust alb" % stats["name"])
		var scab_line := Tooltip.stat_lines(kind)[27]
		if bool(plant.amices_scab):
			_expect(scab_line == "Scab: amices", "%s tooltip amices scab" % stats["name"])
		else:
			_expect(scab_line == "Scab: none", "%s tooltip has no scab amice" % stats["name"])
		var spot_line := Tooltip.stat_lines(kind)[28]
		if bool(plant.orphreys_spot):
			_expect(spot_line == "Spot: orphreys", "%s tooltip orphreys spot" % stats["name"])
		else:
			_expect(spot_line == "Spot: none", "%s tooltip has no spot orphrey" % stats["name"])
		var radius_line := Tooltip.stat_lines(kind)[4]
		if bool(plant.cowls_veil):
			_expect(radius_line.begins_with("Cowl: "), "%s tooltip calls its radius a cowl" % stats["name"])
		elif bool(plant.hoods_pall):
			_expect(radius_line.begins_with("Hood: "), "%s tooltip calls its radius a hood" % stats["name"])
		elif bool(plant.cloaks_gloom):
			_expect(radius_line.begins_with("Cloak: "), "%s tooltip calls its radius a cloak" % stats["name"])
		elif bool(plant.capes_murk):
			_expect(radius_line.begins_with("Cape: "), "%s tooltip calls its radius a cape" % stats["name"])
		elif bool(plant.shawls_dread):
			_expect(radius_line.begins_with("Shawl: "), "%s tooltip calls its radius a shawl" % stats["name"])
		elif bool(plant.stoles_woe):
			_expect(radius_line.begins_with("Stole: "), "%s tooltip calls its radius a stole" % stats["name"])
		elif bool(plant.mantles_blight):
			_expect(radius_line.begins_with("Mantle: "), "%s tooltip calls its radius a mantle" % stats["name"])
		elif bool(plant.tippets_rot):
			_expect(radius_line.begins_with("Tippet: "), "%s tooltip calls its radius a tippet" % stats["name"])
		elif bool(plant.wimples_mildew):
			_expect(radius_line.begins_with("Wimple: "), "%s tooltip calls its radius a wimple" % stats["name"])
		elif bool(plant.albs_rust):
			_expect(radius_line.begins_with("Alb: "), "%s tooltip calls its radius an alb" % stats["name"])
		elif bool(plant.amices_scab):
			_expect(radius_line.begins_with("Amice: "), "%s tooltip calls its radius an amice" % stats["name"])
		elif bool(plant.orphreys_spot):
			_expect(radius_line.begins_with("Orphrey: "), "%s tooltip calls its radius an orphrey" % stats["name"])
		elif bool(plant.casts_light):
			_expect(radius_line.begins_with("Light: "), "%s tooltip calls its radius light" % stats["name"])
		else:
			_expect(radius_line.begins_with("Shade: "), "%s tooltip calls its radius shade" % stats["name"])
		var dealt := _first_hit_damage(kind)
		_expect(dealt == int(plant.damage), "%s first hit deals %s (got %s)" % [stats["name"], str(plant.damage), str(dealt)])


func _parse_tooltip(kind: int) -> Dictionary:
	var lines := Tooltip.stat_lines(kind)
	var fire_text := _after_colon(lines[3]).trim_suffix("s")
	var light_text := _after_colon(lines[4]).trim_suffix("px")
	var slow_text := _after_colon(lines[5])
	var splash_text := _after_colon(lines[6])
	var slow_none := slow_text == "none"
	var slow_factor := 1.0
	var slow_duration := 0.0
	if not slow_none:
		var bits := slow_text.split(" for ")
		slow_factor = float(bits[0])
		slow_duration = float(str(bits[1]).trim_suffix("s"))
	var splash := 0.0
	if splash_text != "none":
		splash = float(splash_text.trim_suffix("px"))
	return {
		"damage": int(_after_colon(lines[2])),
		"fire": float(fire_text),
		"light": float(light_text),
		"slow_none": slow_none,
		"slow_factor": slow_factor,
		"slow_duration": slow_duration,
		"splash": splash,
	}


func _after_colon(line: String) -> String:
	var parts := line.split(": ", false, 1)
	return parts[1] if parts.size() > 1 else ""


func _first_hit_damage(kind: int) -> int:
	var sim = Sim.new(11 + kind)
	var plant_cmd = Sim.Command.new()
	plant_cmd.plant_kind = kind
	plant_cmd.tile = Sim.START_CELL
	sim.step(plant_cmd)
	if not bool(Catalog.get_stats(kind)["casts_light"]):
		var lamp = Sim.Command.new()
		lamp.plant_kind = Catalog.LANTERN
		lamp.tile = Vector2i(6, 5)
		sim.step(lamp)
	var idle = Sim.Command.new()
	var guard := 0
	while sim.outcome == Sim.OUTCOME_RUNNING and guard < 20000:
		var before := {}
		for pest in sim.pests:
			if pest.alive:
				before[pest.id] = pest.hp
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event.get("kind", -1)) != kind:
				continue
			var dealt := int(event["damage"])
			var pest_id := int(event["pest_id"])
			if not before.has(pest_id):
				continue
			var hp_after := int(event["hp_after"])
			var expected := maxi(int(before[pest_id]) - dealt, 0)
			if hp_after != expected:
				printerr("  hp_after ", hp_after, " expected ", expected)
				return -1
			return dealt
	return -1


func _test_planting_and_movement() -> void:
	print("planting rules and movement pause")
	var sim = Sim.new(5)
	var start: Vector2 = sim.player_pos
	var move = Sim.Command.new()
	move.move_x = 1
	sim.step(move)
	_expect(is_equal_approx(sim.player_pos.x, start.x) and is_equal_approx(sim.player_pos.y, start.y), "movement paused during planting")
	var outside = Sim.Command.new()
	outside.plant_kind = Catalog.PEA
	outside.tile = Vector2i(0, 0)
	var seeds_before: int = sim.seeds
	sim.step(outside)
	_expect(sim.seeds == seeds_before and not sim.has_plant(Catalog.PEA), "border tiles reject seeds")
	var sow = Sim.Command.new()
	sow.plant_kind = Catalog.PEA
	sow.tile = Vector2i(3, 3)
	sim.step(sow)
	_expect(sim.has_plant(Catalog.PEA) and sim.seeds == seeds_before - 1, "orchard tile spends one seed")
	var again = Sim.Command.new()
	again.plant_kind = Catalog.VINE
	again.tile = Vector2i(3, 3)
	sim.step(again)
	_expect(not sim.has_plant(Catalog.VINE) and sim.seeds == seeds_before - 1, "occupied tile rejects a second plant")
	var idle = Sim.Command.new()
	var guard := 0
	while sim.phase == Sim.PHASE_PLANT and guard < 2000:
		sim.step(idle)
		guard += 1
	_expect(sim.phase == Sim.PHASE_WAVE, "planting interval ends and a wave starts")
	var during = Sim.Command.new()
	during.plant_kind = Catalog.GOURD
	during.tile = Vector2i(4, 4)
	var seeds_mid: int = sim.seeds
	sim.step(during)
	_expect(sim.seeds == seeds_mid and not sim.has_plant(Catalog.GOURD), "cannot plant during a wave")
	var before: Vector2 = sim.player_pos
	var stride = Sim.Command.new()
	stride.move_x = 1
	sim.step(stride)
	_expect(sim.player_pos.x > before.x + 0.1, "movement works during a wave")


func _test_stationary_dies() -> void:
	print("stationary bot with no plants")
	var sim = Sim.new(42)
	var idle = Sim.Command.new()
	var guard := 0
	while sim.outcome == Sim.OUTCOME_RUNNING and sim.wave < 3 and guard < 30000:
		sim.step(idle)
		guard += 1
	print("  stationary outcome=%s night=%s hp=%s tick=%s" % [sim.outcome, sim.wave, sim.player_hp, sim.tick])
	_expect(sim.seeds == Sim.START_SEEDS, "stationary bot planted nothing")
	_expect(sim.outcome == Sim.OUTCOME_LOST, "stationary bot died")
	_expect(sim.player_hp == 0, "health reached zero")
	_expect(sim.wave < 3, "died before night 3 (night %s)" % str(sim.wave))


func _survival_command(sim):
	var cmd = Sim.Command.new()
	if sim.outcome != Sim.OUTCOME_RUNNING:
		return cmd
	if sim.phase != Sim.PHASE_PLANT or sim.seeds <= 0:
		return cmd
	if not sim.has_plant(Catalog.LANTERN):
		cmd.plant_kind = Catalog.LANTERN
		cmd.tile = Vector2i(7, 5)
	elif not sim.has_plant(Catalog.PEA):
		cmd.plant_kind = Catalog.PEA
		cmd.tile = Vector2i(8, 5)
	return cmd


func _cleared_third_night(sim) -> bool:
	return sim.outcome == Sim.OUTCOME_RUNNING and sim.wave == 3 and sim.phase == Sim.PHASE_PLANT


func _test_scripted_survives() -> void:
	print("scripted lantern + pea bot clears the first three nights")
	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var sim = Sim.new(run_seed)
		var guard := 0
		while sim.outcome == Sim.OUTCOME_RUNNING and not _cleared_third_night(sim) and guard < 30000:
			sim.step(_survival_command(sim))
			guard += 1
		print("  three-night seed=%s outcome=%s night=%s phase=%s hp=%s tick=%s" % [run_seed, sim.outcome, sim.wave, sim.phase, sim.player_hp, sim.tick])
		_expect(_cleared_third_night(sim), "seed %s cleared nights 1-3 (outcome=%s night=%s hp=%s)" % [run_seed, sim.outcome, sim.wave, sim.player_hp])
		_expect(sim.has_plant(Catalog.LANTERN), "seed %s planted a lantern" % run_seed)
		_expect(sim.has_plant(Catalog.PEA), "seed %s planted a pea" % run_seed)
		_expect(not sim.has_plant(Catalog.WICK), "seed %s did not need a wick yet" % run_seed)
		_expect(not sim.has_plant(Catalog.BRIAR), "seed %s did not need a briar yet" % run_seed)
		_expect(not sim.has_plant(Catalog.FLARE), "seed %s did not need a flare yet" % run_seed)
		_expect(not sim.has_plant(Catalog.HEARTH), "seed %s did not need a hearth yet" % run_seed)
		_expect(not sim.has_plant(Catalog.SHEAR), "seed %s did not need a shear yet" % run_seed)
		_expect(not sim.has_plant(Catalog.CHIME), "seed %s did not need a chime yet" % run_seed)
		_expect(not sim.has_plant(Catalog.RASP), "seed %s did not need a rasp yet" % run_seed)
		_expect(not sim.has_plant(Catalog.MAUL), "seed %s did not need a maul yet" % run_seed)
		_expect(not sim.has_plant(Catalog.BILL), "seed %s did not need a bill yet" % run_seed)
		_expect(not sim.has_plant(Catalog.SHADE), "seed %s did not need a shade yet" % run_seed)
		_expect(not sim.has_plant(Catalog.COWL), "seed %s did not need a cowl yet" % run_seed)
		_expect(not sim.has_plant(Catalog.HOOD), "seed %s did not need a hood yet" % run_seed)
		_expect(not sim.has_plant(Catalog.CLOAK), "seed %s did not need a cloak yet" % run_seed)
		_expect(not sim.has_plant(Catalog.CAPE), "seed %s did not need a cape yet" % run_seed)
		_expect(not sim.has_plant(Catalog.SHAWL), "seed %s did not need a shawl yet" % run_seed)
		_expect(not sim.has_plant(Catalog.STOLE), "seed %s did not need a stole yet" % run_seed)
		_expect(not sim.has_plant(Catalog.MANTLE), "seed %s did not need a mantle yet" % run_seed)
		_expect(not sim.has_plant(Catalog.TIPPET), "seed %s did not need a tippet yet" % run_seed)
		_expect(not sim.has_plant(Catalog.WIMPLE), "seed %s did not need a wimple yet" % run_seed)
		_expect(not sim.has_plant(Catalog.ALB), "seed %s did not need an alb yet" % run_seed)
		_expect(not sim.has_plant(Catalog.AMICE), "seed %s did not need an amice yet" % run_seed)
		_expect(not sim.has_plant(Catalog.ORPHREY), "seed %s did not need an orphrey yet" % run_seed)
		_expect(sim.seeds == Sim.START_SEEDS - 2, "seed %s spent only those two seeds" % run_seed)


func _garden_command(sim, wick_tile: Vector2i, briar_tile: Vector2i = Vector2i(-1, -1), flare_tile: Vector2i = Vector2i(-1, -1), hearth_tile: Vector2i = Vector2i(-1, -1), shear_tile: Vector2i = Vector2i(-1, -1), chime_tile: Vector2i = Vector2i(-1, -1), rasp_tile: Vector2i = Vector2i(-1, -1), maul_tile: Vector2i = Vector2i(-1, -1), bill_tile: Vector2i = Vector2i(-1, -1), shade_tile: Vector2i = Vector2i(-1, -1), use_lantern: bool = true, cowl_tile: Vector2i = Vector2i(-1, -1), hood_tile: Vector2i = Vector2i(-1, -1), cloak_tile: Vector2i = Vector2i(-1, -1), cape_tile: Vector2i = Vector2i(-1, -1), shawl_tile: Vector2i = Vector2i(-1, -1), stole_tile: Vector2i = Vector2i(-1, -1), mantle_tile: Vector2i = Vector2i(-1, -1), tippet_tile: Vector2i = Vector2i(-1, -1), wimple_tile: Vector2i = Vector2i(-1, -1), alb_tile: Vector2i = Vector2i(-1, -1), amice_tile: Vector2i = Vector2i(-1, -1), orphrey_tile: Vector2i = Vector2i(-1, -1)):
	var cmd = Sim.Command.new()
	if sim.outcome != Sim.OUTCOME_RUNNING or sim.phase != Sim.PHASE_PLANT or sim.seeds <= 0:
		return cmd
	if use_lantern and not sim.has_plant(Catalog.LANTERN):
		cmd.plant_kind = Catalog.LANTERN
		cmd.tile = Vector2i(7, 5)
	elif not sim.has_plant(Catalog.PEA):
		cmd.plant_kind = Catalog.PEA
		cmd.tile = Vector2i(8, 5)
	elif not sim.has_plant(Catalog.WICK):
		cmd.plant_kind = Catalog.WICK
		cmd.tile = wick_tile
	elif briar_tile.x >= 0 and not sim.has_plant(Catalog.BRIAR):
		cmd.plant_kind = Catalog.BRIAR
		cmd.tile = briar_tile
	elif flare_tile.x >= 0 and not sim.has_plant(Catalog.FLARE):
		cmd.plant_kind = Catalog.FLARE
		cmd.tile = flare_tile
	elif hearth_tile.x >= 0 and not sim.has_plant(Catalog.HEARTH):
		cmd.plant_kind = Catalog.HEARTH
		cmd.tile = hearth_tile
	elif shear_tile.x >= 0 and not sim.has_plant(Catalog.SHEAR):
		cmd.plant_kind = Catalog.SHEAR
		cmd.tile = shear_tile
	elif chime_tile.x >= 0 and not sim.has_plant(Catalog.CHIME):
		cmd.plant_kind = Catalog.CHIME
		cmd.tile = chime_tile
	elif rasp_tile.x >= 0 and not sim.has_plant(Catalog.RASP):
		cmd.plant_kind = Catalog.RASP
		cmd.tile = rasp_tile
	elif maul_tile.x >= 0 and not sim.has_plant(Catalog.MAUL):
		cmd.plant_kind = Catalog.MAUL
		cmd.tile = maul_tile
	elif bill_tile.x >= 0 and not sim.has_plant(Catalog.BILL):
		cmd.plant_kind = Catalog.BILL
		cmd.tile = bill_tile
	elif shade_tile.x >= 0 and not sim.has_plant(Catalog.SHADE):
		cmd.plant_kind = Catalog.SHADE
		cmd.tile = shade_tile
	elif cowl_tile.x >= 0 and not sim.has_plant(Catalog.COWL):
		cmd.plant_kind = Catalog.COWL
		cmd.tile = cowl_tile
	elif hood_tile.x >= 0 and not sim.has_plant(Catalog.HOOD):
		cmd.plant_kind = Catalog.HOOD
		cmd.tile = hood_tile
	elif cloak_tile.x >= 0 and not sim.has_plant(Catalog.CLOAK):
		cmd.plant_kind = Catalog.CLOAK
		cmd.tile = cloak_tile
	elif cape_tile.x >= 0 and not sim.has_plant(Catalog.CAPE):
		cmd.plant_kind = Catalog.CAPE
		cmd.tile = cape_tile
	elif shawl_tile.x >= 0 and not sim.has_plant(Catalog.SHAWL):
		cmd.plant_kind = Catalog.SHAWL
		cmd.tile = shawl_tile
	elif stole_tile.x >= 0 and not sim.has_plant(Catalog.STOLE):
		cmd.plant_kind = Catalog.STOLE
		cmd.tile = stole_tile
	elif mantle_tile.x >= 0 and not sim.has_plant(Catalog.MANTLE):
		cmd.plant_kind = Catalog.MANTLE
		cmd.tile = mantle_tile
	elif tippet_tile.x >= 0 and not sim.has_plant(Catalog.TIPPET):
		cmd.plant_kind = Catalog.TIPPET
		cmd.tile = tippet_tile
	elif wimple_tile.x >= 0 and not sim.has_plant(Catalog.WIMPLE):
		cmd.plant_kind = Catalog.WIMPLE
		cmd.tile = wimple_tile
	elif alb_tile.x >= 0 and not sim.has_plant(Catalog.ALB):
		cmd.plant_kind = Catalog.ALB
		cmd.tile = alb_tile
	elif amice_tile.x >= 0 and not sim.has_plant(Catalog.AMICE):
		cmd.plant_kind = Catalog.AMICE
		cmd.tile = amice_tile
	elif orphrey_tile.x >= 0 and not sim.has_plant(Catalog.ORPHREY):
		cmd.plant_kind = Catalog.ORPHREY
		cmd.tile = orphrey_tile
	return cmd


func _wick_command(sim):
	return _garden_command(sim, Vector2i(6, 5))


func _corner_wick_command(sim):
	return _garden_command(sim, Vector2i(1, 1))


func _briar_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4))


func _corner_briar_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(1, 1))


func _flare_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4))


func _corner_flare_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(1, 1))


func _hearth_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5))


func _corner_hearth_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(1, 1))


func _shear_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6))


func _corner_shear_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(1, 1))


func _chime_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6))


func _corner_chime_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(1, 1))


func _rasp_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5))


func _corner_rasp_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(1, 1))


func _maul_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6))


func _corner_maul_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(1, 1))


func _bill_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4))


func _corner_bill_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(1, 1))


func _shade_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false)


func _corner_shade_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(1, 1), false)


func _cowl_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5))


func _corner_cowl_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(1, 1))


func _hood_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6))


func _corner_hood_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(1, 1))


func _cloak_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6), Vector2i(4, 6))


func _corner_cloak_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6), Vector2i(1, 1))


func _cape_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6), Vector2i(4, 6), Vector2i(3, 6))


func _corner_cape_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6), Vector2i(4, 6), Vector2i(1, 1))


func _shawl_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6), Vector2i(4, 6), Vector2i(3, 6), Vector2i(2, 6))


func _corner_shawl_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6), Vector2i(4, 6), Vector2i(3, 6), Vector2i(1, 1))


# (1, 6) is open, west of the shawl, but its 320px radius misses the bill tile (8, 4). (1, 5) is the next open tile that covers every kill tile the shawl covers.
const STOLE_TILE := Vector2i(1, 5)


func _stole_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6), Vector2i(4, 6), Vector2i(3, 6), Vector2i(2, 6), STOLE_TILE)


func _corner_stole_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6), Vector2i(4, 6), Vector2i(3, 6), Vector2i(2, 6), Vector2i(1, 1))


# (1, 6) is open, south of the stole and west of the shawl. A 336px radius there covers the stole and every tile a Canker moth needs all at once. Rasp (9, 5) and maul (9, 6) sit outside that intersection, so they are not a miss.
const MANTLE_TILE := Vector2i(1, 6)


func _mantle_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6), Vector2i(4, 6), Vector2i(3, 6), Vector2i(2, 6), STOLE_TILE, MANTLE_TILE)


func _corner_mantle_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6), Vector2i(4, 6), Vector2i(3, 6), Vector2i(2, 6), STOLE_TILE, Vector2i(1, 1))


# (1, 7) is the first open tile south of the mantle. A 352px radius there covers the mantle and every tile a Smut moth needs all at once. Rasp (9, 5) and maul (9, 6) sit outside that intersection, so they are not a miss.
const TIPPET_TILE := Vector2i(1, 7)


func _tippet_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6), Vector2i(4, 6), Vector2i(3, 6), Vector2i(2, 6), STOLE_TILE, MANTLE_TILE, TIPPET_TILE)


func _corner_tippet_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6), Vector2i(4, 6), Vector2i(3, 6), Vector2i(2, 6), STOLE_TILE, MANTLE_TILE, Vector2i(1, 1))


# (1, 8) is open, one tile south of the tippet. A 368px radius there covers the tippet and every tile an Ergot moth needs all at once. Rasp (9, 5) sits outside that radius. Maul (9, 6) is inside the radius, and both rasp and maul sit outside the shared kill intersection, so neither is a miss.
const WIMPLE_TILE := Vector2i(1, 8)

# (1, 9) is open, one tile south of the wimple. A 384px radius there covers the wimple and every tile a Brand moth needs all at once. Rasp (9, 5) sits outside that radius. Maul (9, 6) is inside the radius, and both rasp and maul sit outside the shared kill intersection, so neither is a miss.
const ALB_TILE := Vector2i(1, 9)


func _wimple_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6), Vector2i(4, 6), Vector2i(3, 6), Vector2i(2, 6), STOLE_TILE, MANTLE_TILE, TIPPET_TILE, WIMPLE_TILE)


func _corner_wimple_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6), Vector2i(4, 6), Vector2i(3, 6), Vector2i(2, 6), STOLE_TILE, MANTLE_TILE, TIPPET_TILE, Vector2i(1, 1))


# [outcome, wave, phase, tick, hp, shots, shrouds_spawned, shrouds_killed, seeds, plants, rinds_spawned, rinds_killed, pitches_spawned, pitches_killed, frosts_spawned, frosts_killed, webs_spawned, webs_killed, glasses_spawned, glasses_killed, scales_spawned, scales_killed, mails_spawned, mails_killed, hides_spawned, hides_killed, dusks_spawned, dusks_killed, veils_spawned, veils_killed, palls_spawned, palls_killed, glooms_spawned, glooms_killed, murks_spawned, murks_killed, dreads_spawned, dreads_killed, woes_spawned, woes_killed, blights_spawned, blights_killed, rots_spawned, rots_killed, mildews_spawned, mildews_killed, rusts_spawned, rusts_killed, scabs_spawned, scabs_killed, spots_spawned, spots_killed]
func _play(seed: int, planner: Callable, stop_after_night: int = -1) -> Array:
	var sim = Sim.new(seed)
	var guard := 0
	while sim.outcome == Sim.OUTCOME_RUNNING and guard < 120000:
		if stop_after_night > 0 and sim.wave == stop_after_night and sim.phase == Sim.PHASE_PLANT and sim.phase_ticks == 0:
			break
		sim.step(planner.call(sim))
		guard += 1
	return [sim.outcome, sim.wave, sim.phase, sim.tick, sim.player_hp, sim.shots_fired, sim.shrouds_spawned, sim.shrouds_killed, sim.seeds, sim.plants.size(), sim.rinds_spawned, sim.rinds_killed, sim.pitches_spawned, sim.pitches_killed, sim.frosts_spawned, sim.frosts_killed, sim.webs_spawned, sim.webs_killed, sim.glasses_spawned, sim.glasses_killed, sim.scales_spawned, sim.scales_killed, sim.mails_spawned, sim.mails_killed, sim.hides_spawned, sim.hides_killed, sim.dusks_spawned, sim.dusks_killed, sim.veils_spawned, sim.veils_killed, sim.palls_spawned, sim.palls_killed, sim.glooms_spawned, sim.glooms_killed, sim.murks_spawned, sim.murks_killed, sim.dreads_spawned, sim.dreads_killed, sim.woes_spawned, sim.woes_killed, sim.blights_spawned, sim.blights_killed, sim.rots_spawned, sim.rots_killed, sim.mildews_spawned, sim.mildews_killed, sim.rusts_spawned, sim.rusts_killed, sim.scabs_spawned, sim.scabs_killed, sim.spots_spawned, sim.spots_killed]


func _test_shroud_rule() -> void:
	print("wick shroud rule")
	var placed = Sim.new(4)
	var lantern = Sim.Command.new()
	lantern.plant_kind = Catalog.LANTERN
	lantern.tile = Vector2i(7, 5)
	placed.step(lantern)
	var corner = Sim.Command.new()
	corner.plant_kind = Catalog.WICK
	corner.tile = Vector2i(1, 1)
	placed.step(corner)
	var idle = Sim.Command.new()
	placed.step(idle)
	_expect(placed.tile_lit(7, 5), "lantern lights the gardener tile")
	_expect(not placed.tile_burns_shroud(7, 5), "a corner wick does not burn the gardener tile")
	var beside = Sim.Command.new()
	beside.plant_kind = Catalog.WICK
	beside.tile = Vector2i(6, 5)
	placed.step(beside)
	_expect(placed.tile_burns_shroud(7, 5), "a wick beside the gardener burns that tile")

	var sim = Sim.new(6)
	var sow_lantern = Sim.Command.new()
	sow_lantern.plant_kind = Catalog.LANTERN
	sow_lantern.tile = Vector2i(7, 5)
	sim.step(sow_lantern)
	var sow_pea = Sim.Command.new()
	sow_pea.plant_kind = Catalog.PEA
	sow_pea.tile = Vector2i(8, 5)
	sim.step(sow_pea)
	var shroud = sim.spawn_pest(sim.tile_center(7, 1), true)
	var normal = sim.spawn_pest(sim.tile_center(7, 8), false)
	var shroud_id := int(shroud.id)
	var normal_id := int(normal.id)
	sim.step(idle)
	_expect(sim.tile_lit(7, 1) and shroud.hidden, "ordinary light leaves the shroud hidden")
	_expect(not normal.hidden, "ordinary light reveals a normal moth")
	var normal_hit := false
	var shroud_hit := false
	var guard := 0
	while guard < 40 and sim.outcome == Sim.OUTCOME_RUNNING:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == normal_id:
				normal_hit = true
			if int(event["pest_id"]) == shroud_id:
				shroud_hit = true
	var untouched = sim.pest_by_id(shroud_id)
	_expect(normal_hit, "pea damages the lit normal moth")
	_expect(not shroud_hit and untouched != null and int(untouched.hp) == Sim.PEST_HP, "pea does not damage a shroud outside wick light")
	var cell: Vector2i = sim.cell_of(untouched.pos)
	var wick_tile := Vector2i(cell.x + 1, cell.y)
	if wick_tile.x > Sim.MAP_W - 2:
		wick_tile.x = cell.x - 1
	var sow_wick = Sim.Command.new()
	sow_wick.plant_kind = Catalog.WICK
	sow_wick.tile = wick_tile
	sim.step(sow_wick)
	var revealed = sim.pest_by_id(shroud_id)
	_expect(revealed != null and not revealed.hidden, "wick light beside the shroud reveals it")
	var burned := false
	guard = 0
	while guard < 80 and sim.outcome == Sim.OUTCOME_RUNNING and not burned:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == shroud_id:
				burned = true
	_expect(burned, "the revealed shroud takes a hit (hp=%s outcome=%s)" % [sim.player_hp, sim.outcome])

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	splash.step(sow_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5), false)
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a shroud outside wick light")


func _test_later_nights() -> void:
	print("nights 4 and 5")
	_expect(Sim.WAVE_COUNT == 47, "forty-seven nights")
	_expect(int(Sim.WAVES[0]["count"]) == 8 and int(Sim.WAVES[0]["interval"]) == 72 and int(Sim.WAVES[0]["shroud_every"]) == 0 and int(Sim.WAVES[0]["rind_every"]) == 0 and int(Sim.WAVES[0]["pitch_every"]) == 0, "night 1 is the original wave")
	_expect(int(Sim.WAVES[1]["count"]) == 12 and int(Sim.WAVES[1]["interval"]) == 66 and int(Sim.WAVES[1]["shroud_every"]) == 0 and int(Sim.WAVES[1]["rind_every"]) == 0 and int(Sim.WAVES[1]["pitch_every"]) == 0, "night 2 is the original wave")
	_expect(int(Sim.WAVES[2]["count"]) == 22 and int(Sim.WAVES[2]["interval"]) == 60 and int(Sim.WAVES[2]["shroud_every"]) == 0 and int(Sim.WAVES[2]["rind_every"]) == 0 and int(Sim.WAVES[2]["pitch_every"]) == 0, "night 3 is the original wave")
	_expect(int(Sim.WAVES[3]["count"]) == 8 and int(Sim.WAVES[3]["interval"]) == 78 and int(Sim.WAVES[3]["shroud_every"]) == 1 and int(Sim.WAVES[3]["rind_every"]) == 0 and int(Sim.WAVES[3]["pitch_every"]) == 0 and str(Sim.WAVES[3]["name"]) == "Shroud", "night 4 is all shroud")
	_expect(int(Sim.WAVES[4]["count"]) == 16 and int(Sim.WAVES[4]["interval"]) == 54 and int(Sim.WAVES[4]["shroud_every"]) == 2 and int(Sim.WAVES[4]["rind_every"]) == 0 and int(Sim.WAVES[4]["pitch_every"]) == 0 and str(Sim.WAVES[4]["name"]) == "Ash", "night 5 alternates shroud")
	var named = Sim.new(1)
	named.wave = 4
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 4 of 47 (Shroud) — 0 pests left", "night 4 heading: %s" % named.phase_text())
	named.wave = 5
	_expect(named.phase_text() == "Night 5 of 47 (Ash) — 0 pests left", "night 5 heading: %s" % named.phase_text())
	named.wave = 3
	named.phase = Sim.PHASE_PLANT
	named.phase_ticks = 0
	_expect(named.phase_text().begins_with("Planting — night 4 (Shroud)"), "planting before shroud: %s" % named.phase_text())

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var ignored := _play(run_seed, Callable(self, "_corner_wick_command"))
		print("  ignore seed=%s outcome=%s night=%s hp=%s tick=%s spawned=%s killed=%s" % [run_seed, ignored[0], ignored[1], ignored[4], ignored[3], ignored[6], ignored[7]])
		_expect(int(ignored[0]) == Sim.OUTCOME_LOST, "seed %s dies when wick light misses the gardener" % run_seed)
		_expect(int(ignored[1]) == 4, "seed %s dies on the shroud night (night %s)" % [run_seed, ignored[1]])
		_expect(int(ignored[4]) == 0, "seed %s health reached zero" % run_seed)
		_expect(int(ignored[8]) == Sim.START_SEEDS - 3 and int(ignored[9]) == 3, "seed %s planted the wick, just not where the night arrives" % run_seed)
		_expect(int(ignored[6]) > int(ignored[7]), "seed %s left shroud moths unburned (%s spawned, %s killed)" % [run_seed, ignored[6], ignored[7]])
		var cleared := _play(run_seed, Callable(self, "_wick_command"), 5)
		print("  wick through night 5 seed=%s outcome=%s night=%s phase=%s hp=%s shrouds=%s/%s rinds=%s" % [run_seed, cleared[0], cleared[1], cleared[2], cleared[4], cleared[7], cleared[6], cleared[10]])
		_expect(int(cleared[0]) == Sim.OUTCOME_RUNNING and int(cleared[1]) == 5 and int(cleared[2]) == Sim.PHASE_PLANT, "seed %s still clears night 5 with wick light on the gardener" % run_seed)
		_expect(int(cleared[4]) == 100, "seed %s takes no damage through night 5 (hp %s)" % [run_seed, cleared[4]])
		_expect(int(cleared[6]) == 16 and int(cleared[7]) == 16, "seed %s burned every shroud moth of nights 4 and 5 (%s/%s)" % [run_seed, cleared[7], cleared[6]])
		_expect(int(cleared[10]) == 0 and int(cleared[11]) == 0, "seed %s meets no rind moth before night 6" % run_seed)
		_expect(int(cleared[12]) == 0 and int(cleared[13]) == 0, "seed %s meets no pitch moth before night 6" % run_seed)
		_expect(int(cleared[8]) == Sim.START_SEEDS - 3, "seed %s spent lantern, pea, and wick" % run_seed)
		var held := _play(run_seed, Callable(self, "_wick_command"))
		print("  wick without briar seed=%s outcome=%s night=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s" % [run_seed, held[0], held[1], held[4], held[3], held[7], held[6], held[11], held[10]])
		_expect(int(held[0]) == Sim.OUTCOME_LOST, "seed %s dies when the briar rule is ignored" % run_seed)
		_expect(int(held[1]) == 6, "seed %s dies on the rind night (night %s)" % [run_seed, held[1]])
		_expect(int(held[4]) == 0, "seed %s health reached zero on the rind night" % run_seed)
		_expect(int(held[6]) == 16 and int(held[7]) == 16, "seed %s had already burned the shroud nights (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) > 0 and int(held[11]) == 0, "seed %s left every rind moth uncracked (%s spawned, %s killed)" % [run_seed, held[10], held[11]])
		_expect(int(held[8]) == Sim.START_SEEDS - 3 and int(held[9]) == 3, "seed %s never planted a briar" % run_seed)
	var again := _play(42, Callable(self, "_wick_command"))
	var replay := _play(42, Callable(self, "_wick_command"))
	_expect(str(again) == str(replay), "same seed and wick plan replay")


func _test_rind_rule() -> void:
	print("briar rind rule")
	var placed = Sim.new(4)
	var lantern = Sim.Command.new()
	lantern.plant_kind = Catalog.LANTERN
	lantern.tile = Vector2i(7, 5)
	placed.step(lantern)
	var wick = Sim.Command.new()
	wick.plant_kind = Catalog.WICK
	wick.tile = Vector2i(6, 5)
	placed.step(wick)
	var idle = Sim.Command.new()
	placed.step(idle)
	_expect(placed.tile_burns_shroud(6, 4), "the wick burns the tile north of itself")
	_expect(not placed.tile_cracks_rind(6, 4), "wick light does not crack rind")
	var corner = Sim.Command.new()
	corner.plant_kind = Catalog.BRIAR
	corner.tile = Vector2i(1, 1)
	placed.step(corner)
	_expect(not placed.tile_cracks_rind(7, 5), "a corner briar does not crack the gardener tile")
	var beside = Sim.Command.new()
	beside.plant_kind = Catalog.BRIAR
	beside.tile = Vector2i(6, 4)
	placed.step(beside)
	_expect(placed.tile_cracks_rind(6, 4), "a briar on that tile cracks it")
	_expect(placed.tile_cracks_rind(7, 5), "that briar also cracks the gardener tile")
	_expect(not placed.plant_of_kind(Catalog.BRIAR).burns_shroud, "the briar does not burn shroud")
	_expect(not placed.plant_of_kind(Catalog.WICK).cracks_rind, "the wick does not crack rind")

	var sim = Sim.new(6)
	var sow_lantern = Sim.Command.new()
	sow_lantern.plant_kind = Catalog.LANTERN
	sow_lantern.tile = Vector2i(7, 5)
	sim.step(sow_lantern)
	var sow_pea = Sim.Command.new()
	sow_pea.plant_kind = Catalog.PEA
	sow_pea.tile = Vector2i(8, 5)
	sim.step(sow_pea)
	var sow_wick = Sim.Command.new()
	sow_wick.plant_kind = Catalog.WICK
	sow_wick.tile = Vector2i(6, 5)
	sim.step(sow_wick)
	var rind = sim.spawn_pest(sim.tile_center(6, 4), false, true)
	var normal = sim.spawn_pest(sim.tile_center(8, 8), false, false)
	var shroud = sim.spawn_pest(sim.tile_center(8, 2), true, false)
	var rind_id := int(rind.id)
	var normal_id := int(normal.id)
	var shroud_id := int(shroud.id)
	_expect(sim.tile_lit(6, 4) and sim.tile_burns_shroud(6, 4) and rind.hidden, "wick light leaves the rind hidden")
	_expect(shroud.hidden, "briar-less light leaves the shroud hidden")
	var normal_hit := false
	var rind_hit := false
	var shroud_hit := false
	var guard := 0
	while guard < 30 and sim.outcome == Sim.OUTCOME_RUNNING:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == normal_id:
				normal_hit = true
			if int(event["pest_id"]) == rind_id:
				rind_hit = true
			if int(event["pest_id"]) == shroud_id:
				shroud_hit = true
	var rind_now = sim.pest_by_id(rind_id)
	var shroud_now = sim.pest_by_id(shroud_id)
	_expect(normal_hit, "pea still damages an ordinary moth")
	_expect(not rind_hit and rind_now != null and int(rind_now.hp) == Sim.PEST_HP, "pea does not damage a rind outside briar light")
	_expect(not shroud_hit and shroud_now != null and int(shroud_now.hp) == Sim.PEST_HP, "wick rule still blocks a shroud outside wick light")
	var sow_briar = Sim.Command.new()
	sow_briar.plant_kind = Catalog.BRIAR
	sow_briar.tile = Vector2i(7, 4)
	sim.step(sow_briar)
	var revealed = sim.pest_by_id(rind_id)
	_expect(revealed != null and not revealed.hidden, "briar light beside the rind reveals it")
	var burned_shroud = sim.pest_by_id(shroud_id)
	_expect(burned_shroud != null and burned_shroud.hidden, "briar light does not reveal a shroud")
	var cracked := false
	guard = 0
	while guard < 80 and sim.outcome == Sim.OUTCOME_RUNNING and not cracked:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == rind_id:
				cracked = true
	_expect(cracked, "the revealed rind takes a hit (hp=%s outcome=%s)" % [sim.player_hp, sim.outcome])

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	splash.step(sow_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5), false, false)
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the rind")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a rind outside briar light")

	var gall = Sim.new(9)
	var gall_lamp = Sim.Command.new()
	gall_lamp.plant_kind = Catalog.LANTERN
	gall_lamp.tile = Vector2i(7, 5)
	gall.step(gall_lamp)
	var gall_wick = Sim.Command.new()
	gall_wick.plant_kind = Catalog.WICK
	gall_wick.tile = Vector2i(6, 5)
	gall.step(gall_wick)
	var gall_pea = Sim.Command.new()
	gall_pea.plant_kind = Catalog.PEA
	gall_pea.tile = Vector2i(8, 5)
	gall.step(gall_pea)
	var both = gall.spawn_pest(gall.tile_center(6, 6), true, true)
	var both_id := int(both.id)
	_expect(gall.tile_burns_shroud(6, 6) and not gall.tile_cracks_rind(6, 6) and both.hidden, "wick light alone leaves a gall moth hidden")
	guard = 0
	var gall_hit := false
	while guard < 20 and gall.outcome == Sim.OUTCOME_RUNNING:
		gall.step(idle)
		guard += 1
		for event in gall.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == both_id:
				gall_hit = true
	var both_now = gall.pest_by_id(both_id)
	_expect(not gall_hit and both_now != null and int(both_now.hp) == Sim.PEST_HP, "a gall moth ignores shots until the briar cracks it")
	var gall_briar = Sim.Command.new()
	gall_briar.plant_kind = Catalog.BRIAR
	gall_briar.tile = Vector2i(6, 4)
	gall.step(gall_briar)
	var opened = gall.pest_by_id(both_id)
	_expect(opened != null and not opened.hidden, "wick and briar together reveal a gall moth")
	var opened_hit := false
	guard = 0
	while guard < 80 and gall.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		gall.step(idle)
		guard += 1
		for event in gall.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == both_id:
				opened_hit = true
	_expect(opened_hit, "the opened gall moth takes a hit")


func _test_deeper_nights() -> void:
	print("nights 6 and 7")
	_expect(int(Sim.WAVES[5]["count"]) == 10 and int(Sim.WAVES[5]["interval"]) == 72 and int(Sim.WAVES[5]["shroud_every"]) == 0 and int(Sim.WAVES[5]["rind_every"]) == 1 and int(Sim.WAVES[5]["pitch_every"]) == 0 and str(Sim.WAVES[5]["name"]) == "Rind", "night 6 is all rind")
	_expect(int(Sim.WAVES[6]["count"]) == 16 and int(Sim.WAVES[6]["interval"]) == 60 and int(Sim.WAVES[6]["shroud_every"]) == 2 and int(Sim.WAVES[6]["rind_every"]) == 1 and int(Sim.WAVES[6]["pitch_every"]) == 0 and str(Sim.WAVES[6]["name"]) == "Gall", "night 7 is rind with every second also a shroud")
	var named = Sim.new(1)
	named.wave = 6
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 6 of 47 (Rind) — 0 pests left", "night 6 heading: %s" % named.phase_text())
	named.wave = 7
	_expect(named.phase_text() == "Night 7 of 47 (Gall) — 0 pests left", "night 7 heading: %s" % named.phase_text())
	named.wave = 5
	named.phase = Sim.PHASE_PLANT
	named.phase_ticks = 0
	_expect(named.phase_text().begins_with("Planting — night 6 (Rind)"), "planting before rind: %s" % named.phase_text())

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var missed := _play(run_seed, Callable(self, "_corner_briar_command"))
		print("  corner briar seed=%s outcome=%s night=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s" % [run_seed, missed[0], missed[1], missed[4], missed[3], missed[7], missed[6], missed[11], missed[10]])
		_expect(int(missed[0]) == Sim.OUTCOME_LOST, "seed %s dies when briar light misses the gardener" % run_seed)
		_expect(int(missed[1]) == 6, "seed %s dies on the rind night (night %s)" % [run_seed, missed[1]])
		_expect(int(missed[4]) == 0, "seed %s health reached zero" % run_seed)
		_expect(int(missed[8]) == Sim.START_SEEDS - 4 and int(missed[9]) == 4, "seed %s planted the briar, just not where the night arrives" % run_seed)
		_expect(int(missed[7]) >= 16, "seed %s had already burned the shroud nights (%s killed)" % [run_seed, missed[7]])
		_expect(int(missed[10]) > int(missed[11]), "seed %s left rind moths uncracked (%s spawned, %s killed)" % [run_seed, missed[10], missed[11]])
		var held := _play(run_seed, Callable(self, "_briar_command"), 7)
		print("  briar through night 7 seed=%s outcome=%s night=%s phase=%s hp=%s shrouds=%s/%s rinds=%s/%s pitches=%s" % [run_seed, held[0], held[1], held[2], held[4], held[7], held[6], held[11], held[10], held[12]])
		_expect(int(held[0]) == Sim.OUTCOME_RUNNING and int(held[1]) == 7 and int(held[2]) == Sim.PHASE_PLANT, "seed %s still clears night 7 with lantern, pea, wick, and briar" % run_seed)
		_expect(int(held[4]) > 0, "seed %s still has health after night 7 (%s)" % [run_seed, held[4]])
		_expect(int(held[6]) == 24 and int(held[7]) == 24, "seed %s burned every shroud moth through night 7 (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 26 and int(held[11]) == 26, "seed %s cracked every rind moth through night 7 (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 0 and int(held[13]) == 0, "seed %s meets no pitch moth before night 8" % run_seed)
		_expect(int(held[8]) == Sim.START_SEEDS - 4 and int(held[9]) == 4, "seed %s spent lantern, pea, wick, and briar" % run_seed)
	var again := _play(42, Callable(self, "_briar_command"), 7)
	var replay := _play(42, Callable(self, "_briar_command"), 7)
	_expect(str(again) == str(replay), "same seed and briar plan replay through night 7")


func _test_pitch_rule() -> void:
	print("flare pitch rule")
	var placed = Sim.new(4)
	var lantern = Sim.Command.new()
	lantern.plant_kind = Catalog.LANTERN
	lantern.tile = Vector2i(7, 5)
	placed.step(lantern)
	var wick = Sim.Command.new()
	wick.plant_kind = Catalog.WICK
	wick.tile = Vector2i(6, 5)
	placed.step(wick)
	var briar = Sim.Command.new()
	briar.plant_kind = Catalog.BRIAR
	briar.tile = Vector2i(6, 4)
	placed.step(briar)
	var idle = Sim.Command.new()
	placed.step(idle)
	_expect(placed.tile_burns_shroud(7, 4) and placed.tile_cracks_rind(7, 4), "wick and briar already cover the tile north of the gardener")
	_expect(not placed.tile_melts_pitch(7, 4), "wick and briar light does not melt pitch")
	var corner = Sim.Command.new()
	corner.plant_kind = Catalog.FLARE
	corner.tile = Vector2i(1, 1)
	placed.step(corner)
	_expect(not placed.tile_melts_pitch(7, 5), "a corner flare does not melt the gardener tile")
	var beside = Sim.Command.new()
	beside.plant_kind = Catalog.FLARE
	beside.tile = Vector2i(7, 4)
	placed.step(beside)
	_expect(placed.tile_melts_pitch(7, 4), "a flare on that tile melts it")
	_expect(placed.tile_melts_pitch(7, 5), "that flare also melts the gardener tile")
	var flare_plant = placed.plant_of_kind(Catalog.FLARE)
	_expect(flare_plant != null and not flare_plant.burns_shroud and not flare_plant.cracks_rind, "the flare does not burn shroud or crack rind")
	_expect(not placed.plant_of_kind(Catalog.WICK).melts_pitch, "the wick does not melt pitch")
	_expect(not placed.plant_of_kind(Catalog.BRIAR).melts_pitch, "the briar does not melt pitch")

	var sim = Sim.new(6)
	var sow_lantern = Sim.Command.new()
	sow_lantern.plant_kind = Catalog.LANTERN
	sow_lantern.tile = Vector2i(7, 5)
	sim.step(sow_lantern)
	var sow_pea = Sim.Command.new()
	sow_pea.plant_kind = Catalog.PEA
	sow_pea.tile = Vector2i(8, 5)
	sim.step(sow_pea)
	var sow_wick = Sim.Command.new()
	sow_wick.plant_kind = Catalog.WICK
	sow_wick.tile = Vector2i(6, 5)
	sim.step(sow_wick)
	var sow_briar = Sim.Command.new()
	sow_briar.plant_kind = Catalog.BRIAR
	sow_briar.tile = Vector2i(6, 4)
	sim.step(sow_briar)
	var pitch = sim.spawn_pest(sim.tile_center(7, 4), false, false, true)
	var normal = sim.spawn_pest(sim.tile_center(8, 8), false, false, false)
	var shroud = sim.spawn_pest(sim.tile_center(8, 2), true, false, false)
	var rind = sim.spawn_pest(sim.tile_center(8, 6), false, true, false)
	var pitch_id := int(pitch.id)
	var normal_id := int(normal.id)
	var shroud_id := int(shroud.id)
	var rind_id := int(rind.id)
	_expect(sim.tile_lit(7, 4) and sim.tile_burns_shroud(7, 4) and sim.tile_cracks_rind(7, 4) and pitch.hidden, "wick and briar light leaves the pitch hidden")
	var normal_hit := false
	var pitch_hit := false
	var shroud_hit := false
	var rind_hit := false
	var guard := 0
	while guard < 30 and sim.outcome == Sim.OUTCOME_RUNNING:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == normal_id:
				normal_hit = true
			if int(event["pest_id"]) == pitch_id:
				pitch_hit = true
			if int(event["pest_id"]) == shroud_id:
				shroud_hit = true
			if int(event["pest_id"]) == rind_id:
				rind_hit = true
	var pitch_now = sim.pest_by_id(pitch_id)
	_expect(normal_hit, "pea still damages an ordinary moth")
	_expect(not pitch_hit and pitch_now != null and int(pitch_now.hp) == Sim.PEST_HP, "pea does not damage a pitch outside flare light")
	_expect(not shroud_hit, "wick rule still blocks a shroud outside wick light")
	_expect(rind_hit, "briar light still lets a rind take damage")
	var sow_flare = Sim.Command.new()
	sow_flare.plant_kind = Catalog.FLARE
	sow_flare.tile = Vector2i(8, 4)
	sim.step(sow_flare)
	var revealed = sim.pest_by_id(pitch_id)
	_expect(revealed != null and not revealed.hidden, "flare light beside the pitch reveals it")
	var still_shroud = sim.pest_by_id(shroud_id)
	_expect(still_shroud != null and still_shroud.hidden, "flare light does not reveal a shroud")
	var melted := false
	guard = 0
	while guard < 80 and sim.outcome == Sim.OUTCOME_RUNNING and not melted:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == pitch_id:
				melted = true
	_expect(melted, "the revealed pitch takes a hit (hp=%s outcome=%s)" % [sim.player_hp, sim.outcome])

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	splash.step(sow_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5), false, false, false)
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the pitch")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a pitch outside flare light")

	var tar = Sim.new(9)
	var tar_lamp = Sim.Command.new()
	tar_lamp.plant_kind = Catalog.LANTERN
	tar_lamp.tile = Vector2i(7, 5)
	tar.step(tar_lamp)
	var tar_wick = Sim.Command.new()
	tar_wick.plant_kind = Catalog.WICK
	tar_wick.tile = Vector2i(6, 5)
	tar.step(tar_wick)
	var tar_briar = Sim.Command.new()
	tar_briar.plant_kind = Catalog.BRIAR
	tar_briar.tile = Vector2i(6, 4)
	tar.step(tar_briar)
	var tar_pea = Sim.Command.new()
	tar_pea.plant_kind = Catalog.PEA
	tar_pea.tile = Vector2i(8, 5)
	tar.step(tar_pea)
	var sealed = tar.spawn_pest(tar.tile_center(7, 4), true, true, true)
	var sealed_id := int(sealed.id)
	_expect(tar.tile_burns_shroud(7, 4) and tar.tile_cracks_rind(7, 4) and not tar.tile_melts_pitch(7, 4) and sealed.hidden, "wick and briar leave a tar moth sealed")
	guard = 0
	var sealed_hit := false
	while guard < 20 and tar.outcome == Sim.OUTCOME_RUNNING:
		tar.step(idle)
		guard += 1
		for event in tar.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				sealed_hit = true
	var sealed_now = tar.pest_by_id(sealed_id)
	_expect(not sealed_hit and sealed_now != null and int(sealed_now.hp) == Sim.PEST_HP, "a tar moth ignores shots until the flare melts it")
	var tar_flare = Sim.Command.new()
	tar_flare.plant_kind = Catalog.FLARE
	tar_flare.tile = Vector2i(7, 6)
	tar.step(tar_flare)
	var opened = tar.pest_by_id(sealed_id)
	_expect(opened != null and not opened.hidden, "wick, briar, and flare together reveal a tar moth")
	var opened_hit := false
	guard = 0
	while guard < 80 and tar.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		tar.step(idle)
		guard += 1
		for event in tar.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				opened_hit = true
	_expect(opened_hit, "the opened tar moth takes a hit")


func _test_eighth_nights() -> void:
	print("nights 8 and 9")
	_expect(int(Sim.WAVES[7]["count"]) == 10 and int(Sim.WAVES[7]["interval"]) == 72 and int(Sim.WAVES[7]["shroud_every"]) == 0 and int(Sim.WAVES[7]["rind_every"]) == 0 and int(Sim.WAVES[7]["pitch_every"]) == 1 and int(Sim.WAVES[7]["frost_every"]) == 0 and str(Sim.WAVES[7]["name"]) == "Pitch", "night 8 is all pitch")
	_expect(int(Sim.WAVES[8]["count"]) == 16 and int(Sim.WAVES[8]["interval"]) == 60 and int(Sim.WAVES[8]["shroud_every"]) == 2 and int(Sim.WAVES[8]["rind_every"]) == 1 and int(Sim.WAVES[8]["pitch_every"]) == 1 and int(Sim.WAVES[8]["frost_every"]) == 0 and str(Sim.WAVES[8]["name"]) == "Tar", "night 9 is pitch and rind, every second also a shroud")
	var named = Sim.new(1)
	named.wave = 8
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 8 of 47 (Pitch) — 0 pests left", "night 8 heading: %s" % named.phase_text())
	named.wave = 9
	_expect(named.phase_text() == "Night 9 of 47 (Tar) — 0 pests left", "night 9 heading: %s" % named.phase_text())
	named.wave = 7
	named.phase = Sim.PHASE_PLANT
	named.phase_ticks = 0
	_expect(named.phase_text().begins_with("Planting — night 8 (Pitch)"), "planting before pitch: %s" % named.phase_text())

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var ignored := _play(run_seed, Callable(self, "_briar_command"))
		print("  no flare seed=%s outcome=%s night=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s" % [run_seed, ignored[0], ignored[1], ignored[4], ignored[3], ignored[7], ignored[6], ignored[11], ignored[10], ignored[13], ignored[12]])
		_expect(int(ignored[0]) == Sim.OUTCOME_LOST, "seed %s dies when the flare rule is ignored" % run_seed)
		_expect(int(ignored[1]) == 8, "seed %s dies on the pitch night (night %s)" % [run_seed, ignored[1]])
		_expect(int(ignored[4]) == 0, "seed %s health reached zero on the pitch night" % run_seed)
		_expect(int(ignored[6]) == 24 and int(ignored[7]) == 24, "seed %s had already burned the shroud nights (%s/%s)" % [run_seed, ignored[7], ignored[6]])
		_expect(int(ignored[10]) == 26 and int(ignored[11]) == 26, "seed %s had already cracked the rind nights (%s/%s)" % [run_seed, ignored[11], ignored[10]])
		_expect(int(ignored[12]) > 0 and int(ignored[13]) == 0, "seed %s left every pitch moth unmelted (%s spawned, %s killed)" % [run_seed, ignored[12], ignored[13]])
		_expect(int(ignored[8]) == Sim.START_SEEDS - 4 and int(ignored[9]) == 4, "seed %s never planted a flare" % run_seed)
		var missed := _play(run_seed, Callable(self, "_corner_flare_command"))
		print("  corner flare seed=%s outcome=%s night=%s hp=%s tick=%s pitches=%s/%s" % [run_seed, missed[0], missed[1], missed[4], missed[3], missed[13], missed[12]])
		_expect(int(missed[0]) == Sim.OUTCOME_LOST, "seed %s dies when flare light misses the gardener" % run_seed)
		_expect(int(missed[1]) == 8, "seed %s dies on the pitch night with a corner flare (night %s)" % [run_seed, missed[1]])
		_expect(int(missed[4]) == 0, "seed %s health reached zero" % run_seed)
		_expect(int(missed[8]) == Sim.START_SEEDS - 5 and int(missed[9]) == 5, "seed %s planted the flare, just not where the night arrives" % run_seed)
		_expect(int(missed[12]) > int(missed[13]), "seed %s left pitch moths unmelted (%s spawned, %s killed)" % [run_seed, missed[12], missed[13]])
		var held := _play(run_seed, Callable(self, "_flare_command"), 9)
		print("  flare through night 9 seed=%s outcome=%s night=%s phase=%s hp=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s" % [run_seed, held[0], held[1], held[2], held[4], held[7], held[6], held[11], held[10], held[13], held[12], held[14]])
		_expect(int(held[0]) == Sim.OUTCOME_RUNNING and int(held[1]) == 9 and int(held[2]) == Sim.PHASE_PLANT, "seed %s still clears night 9 with lantern, pea, wick, briar, and flare" % run_seed)
		_expect(int(held[4]) > 0, "seed %s still has health after night 9 (%s)" % [run_seed, held[4]])
		_expect(int(held[6]) == 32 and int(held[7]) == 32, "seed %s burned every shroud moth through night 9 (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 42 and int(held[11]) == 42, "seed %s cracked every rind moth through night 9 (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 26 and int(held[13]) == 26, "seed %s melted every pitch moth through night 9 (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 0 and int(held[15]) == 0, "seed %s meets no frost moth before night 10" % run_seed)
		_expect(int(held[8]) == Sim.START_SEEDS - 5 and int(held[9]) == 5, "seed %s spent lantern, pea, wick, briar, and flare" % run_seed)
	var again := _play(42, Callable(self, "_flare_command"), 9)
	var replay := _play(42, Callable(self, "_flare_command"), 9)
	_expect(str(again) == str(replay), "same seed and flare plan replay through night 9")


func _test_frost_rule() -> void:
	print("hearth frost rule")
	var placed = Sim.new(4)
	var lantern = Sim.Command.new()
	lantern.plant_kind = Catalog.LANTERN
	lantern.tile = Vector2i(7, 5)
	placed.step(lantern)
	var wick = Sim.Command.new()
	wick.plant_kind = Catalog.WICK
	wick.tile = Vector2i(6, 5)
	placed.step(wick)
	var briar = Sim.Command.new()
	briar.plant_kind = Catalog.BRIAR
	briar.tile = Vector2i(6, 4)
	placed.step(briar)
	var flare = Sim.Command.new()
	flare.plant_kind = Catalog.FLARE
	flare.tile = Vector2i(7, 4)
	placed.step(flare)
	var idle = Sim.Command.new()
	placed.step(idle)
	_expect(placed.tile_burns_shroud(7, 5) and placed.tile_cracks_rind(7, 5) and placed.tile_melts_pitch(7, 5), "wick, briar, and flare already cover the gardener")
	_expect(not placed.tile_thaws_frost(7, 5), "wick, briar, and flare light does not thaw frost")
	var corner = Sim.Command.new()
	corner.plant_kind = Catalog.HEARTH
	corner.tile = Vector2i(1, 1)
	placed.step(corner)
	_expect(not placed.tile_thaws_frost(7, 5), "a corner hearth does not thaw the gardener tile")
	var beside = Sim.Command.new()
	beside.plant_kind = Catalog.HEARTH
	beside.tile = Vector2i(5, 5)
	placed.step(beside)
	_expect(placed.tile_thaws_frost(5, 5), "a hearth on its own tile thaws it")
	_expect(placed.tile_thaws_frost(7, 5), "that hearth also thaws the gardener tile")
	var hearth_plant = placed.plant_of_kind(Catalog.HEARTH)
	_expect(hearth_plant != null and hearth_plant.thaws_frost and not hearth_plant.burns_shroud and not hearth_plant.cracks_rind and not hearth_plant.melts_pitch, "the hearth thaws frost and does not burn, crack, or melt")
	_expect(not placed.plant_of_kind(Catalog.WICK).thaws_frost, "the wick does not thaw frost")
	_expect(not placed.plant_of_kind(Catalog.BRIAR).thaws_frost, "the briar does not thaw frost")
	_expect(not placed.plant_of_kind(Catalog.FLARE).thaws_frost, "the flare does not thaw frost")

	var sim = Sim.new(6)
	var sow_lantern = Sim.Command.new()
	sow_lantern.plant_kind = Catalog.LANTERN
	sow_lantern.tile = Vector2i(7, 5)
	sim.step(sow_lantern)
	var sow_pea = Sim.Command.new()
	sow_pea.plant_kind = Catalog.PEA
	sow_pea.tile = Vector2i(8, 5)
	sim.step(sow_pea)
	var sow_wick = Sim.Command.new()
	sow_wick.plant_kind = Catalog.WICK
	sow_wick.tile = Vector2i(6, 5)
	sim.step(sow_wick)
	var sow_briar = Sim.Command.new()
	sow_briar.plant_kind = Catalog.BRIAR
	sow_briar.tile = Vector2i(6, 4)
	sim.step(sow_briar)
	var sow_flare = Sim.Command.new()
	sow_flare.plant_kind = Catalog.FLARE
	sow_flare.tile = Vector2i(7, 4)
	sim.step(sow_flare)
	var frost = sim.spawn_pest(sim.tile_center(7, 4), false, false, false, true)
	var normal = sim.spawn_pest(sim.tile_center(8, 8), false, false, false, false)
	var shroud = sim.spawn_pest(sim.tile_center(8, 2), true, false, false, false)
	var rind = sim.spawn_pest(sim.tile_center(8, 6), false, true, false, false)
	var pitch = sim.spawn_pest(sim.tile_center(8, 4), false, false, true, false)
	var frost_id := int(frost.id)
	var normal_id := int(normal.id)
	var shroud_id := int(shroud.id)
	var rind_id := int(rind.id)
	var pitch_id := int(pitch.id)
	_expect(sim.tile_lit(7, 4) and sim.tile_burns_shroud(7, 4) and sim.tile_cracks_rind(7, 4) and sim.tile_melts_pitch(7, 4) and frost.hidden, "wick, briar, and flare light leaves the frost hidden")
	var normal_hit := false
	var frost_hit := false
	var shroud_hit := false
	var rind_hit := false
	var pitch_hit := false
	var guard := 0
	while guard < 40 and sim.outcome == Sim.OUTCOME_RUNNING:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == normal_id:
				normal_hit = true
			if int(event["pest_id"]) == frost_id:
				frost_hit = true
			if int(event["pest_id"]) == shroud_id:
				shroud_hit = true
			if int(event["pest_id"]) == rind_id:
				rind_hit = true
			if int(event["pest_id"]) == pitch_id:
				pitch_hit = true
	var frost_now = sim.pest_by_id(frost_id)
	_expect(normal_hit, "pea still damages an ordinary moth")
	_expect(not frost_hit and frost_now != null and int(frost_now.hp) == Sim.PEST_HP, "pea does not damage a frost outside hearth light")
	_expect(not shroud_hit, "wick rule still blocks a shroud outside wick light")
	_expect(rind_hit, "briar light still lets a rind take damage")
	_expect(pitch_hit, "flare light still lets a pitch take damage")
	var sow_hearth = Sim.Command.new()
	sow_hearth.plant_kind = Catalog.HEARTH
	sow_hearth.tile = Vector2i(5, 5)
	sim.step(sow_hearth)
	var revealed = sim.pest_by_id(frost_id)
	_expect(revealed != null and not revealed.hidden, "hearth light beside the frost reveals it")
	var parked = sim.spawn_pest(sim.tile_center(4, 7), true, false, false, false)
	_expect(sim.tile_thaws_frost(4, 7) and not sim.tile_burns_shroud(4, 7), "the hearth covers that shroud tile without burning it")
	_expect(parked != null and parked.hidden, "hearth light does not reveal a shroud")
	var thawed := false
	guard = 0
	while guard < 80 and sim.outcome == Sim.OUTCOME_RUNNING and not thawed:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == frost_id:
				thawed = true
	_expect(thawed, "the revealed frost takes a hit (hp=%s outcome=%s)" % [sim.player_hp, sim.outcome])

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	splash.step(sow_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false)
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the frost")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a frost outside hearth light")

	var rime = Sim.new(9)
	var rime_lamp = Sim.Command.new()
	rime_lamp.plant_kind = Catalog.LANTERN
	rime_lamp.tile = Vector2i(7, 5)
	rime.step(rime_lamp)
	var rime_wick = Sim.Command.new()
	rime_wick.plant_kind = Catalog.WICK
	rime_wick.tile = Vector2i(6, 5)
	rime.step(rime_wick)
	var rime_briar = Sim.Command.new()
	rime_briar.plant_kind = Catalog.BRIAR
	rime_briar.tile = Vector2i(6, 4)
	rime.step(rime_briar)
	var rime_flare = Sim.Command.new()
	rime_flare.plant_kind = Catalog.FLARE
	rime_flare.tile = Vector2i(7, 4)
	rime.step(rime_flare)
	var rime_pea = Sim.Command.new()
	rime_pea.plant_kind = Catalog.PEA
	rime_pea.tile = Vector2i(8, 5)
	rime.step(rime_pea)
	var sealed = rime.spawn_pest(rime.tile_center(7, 4), true, true, true, true)
	var sealed_id := int(sealed.id)
	_expect(rime.tile_burns_shroud(7, 4) and rime.tile_cracks_rind(7, 4) and rime.tile_melts_pitch(7, 4) and not rime.tile_thaws_frost(7, 4) and sealed.hidden, "wick, briar, and flare leave a rime moth sealed")
	guard = 0
	var sealed_hit := false
	while guard < 20 and rime.outcome == Sim.OUTCOME_RUNNING:
		rime.step(idle)
		guard += 1
		for event in rime.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				sealed_hit = true
	var sealed_now = rime.pest_by_id(sealed_id)
	_expect(not sealed_hit and sealed_now != null and int(sealed_now.hp) == Sim.PEST_HP, "a rime moth ignores shots until the hearth thaws it")
	var rime_hearth = Sim.Command.new()
	rime_hearth.plant_kind = Catalog.HEARTH
	rime_hearth.tile = Vector2i(5, 5)
	rime.step(rime_hearth)
	var opened = rime.pest_by_id(sealed_id)
	_expect(opened != null and not opened.hidden, "wick, briar, flare, and hearth together reveal a rime moth")
	var opened_hit := false
	guard = 0
	while guard < 80 and rime.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		rime.step(idle)
		guard += 1
		for event in rime.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				opened_hit = true
	_expect(opened_hit, "the opened rime moth takes a hit")


func _test_tenth_nights() -> void:
	print("nights 10 and 11")
	# count, interval, shroud, rind, pitch, frost, name. Nights 1–9 stay on the nine-night table.
	var nights := [
		[8, 72, 0, 0, 0, 0, ""],
		[12, 66, 0, 0, 0, 0, ""],
		[22, 60, 0, 0, 0, 0, ""],
		[8, 78, 1, 0, 0, 0, "Shroud"],
		[16, 54, 2, 0, 0, 0, "Ash"],
		[10, 72, 0, 1, 0, 0, "Rind"],
		[16, 60, 2, 1, 0, 0, "Gall"],
		[10, 72, 0, 0, 1, 0, "Pitch"],
		[16, 60, 2, 1, 1, 0, "Tar"],
		[10, 72, 0, 0, 0, 1, "Frost"],
		[16, 60, 2, 1, 1, 1, "Rime"],
	]
	_expect(Sim.WAVES.size() == 47 and Sim.WAVE_COUNT == 47, "forty-seven nights")
	for i in nights.size():
		var spec: Dictionary = Sim.WAVES[i]
		var want: Array = nights[i]
		var same := int(spec["count"]) == int(want[0]) and int(spec["interval"]) == int(want[1])
		same = same and int(spec["shroud_every"]) == int(want[2]) and int(spec["rind_every"]) == int(want[3])
		same = same and int(spec["pitch_every"]) == int(want[4]) and int(spec["frost_every"]) == int(want[5])
		same = same and str(spec["name"]) == str(want[6])
		same = same and int(spec["web_every"]) == 0
		same = same and int(spec["glass_every"]) == 0
		same = same and int(spec["scale_every"]) == 0
		same = same and int(spec["mail_every"]) == 0
		same = same and int(spec["hide_every"]) == 0
		_expect(same, "night %d stays on the eleven-night table" % (i + 1))
	var named = Sim.new(1)
	named.wave = 10
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 10 of 47 (Frost) — 0 pests left", "night 10 heading: %s" % named.phase_text())
	named.wave = 11
	_expect(named.phase_text() == "Night 11 of 47 (Rime) — 0 pests left", "night 11 heading: %s" % named.phase_text())
	named.wave = 9
	named.phase = Sim.PHASE_PLANT
	named.phase_ticks = 0
	_expect(named.phase_text().begins_with("Planting — night 10 (Frost)"), "planting before frost: %s" % named.phase_text())

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var ignored := _play(run_seed, Callable(self, "_flare_command"))
		print("  no hearth seed=%s outcome=%s night=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s" % [run_seed, ignored[0], ignored[1], ignored[4], ignored[3], ignored[7], ignored[6], ignored[11], ignored[10], ignored[13], ignored[12], ignored[15], ignored[14]])
		_expect(int(ignored[0]) == Sim.OUTCOME_LOST, "seed %s dies when the hearth rule is ignored" % run_seed)
		_expect(int(ignored[1]) == 10, "seed %s dies on the frost night (night %s)" % [run_seed, ignored[1]])
		_expect(int(ignored[4]) == 0, "seed %s health reached zero on the frost night" % run_seed)
		_expect(int(ignored[6]) == 32 and int(ignored[7]) == 32, "seed %s had already burned the shroud nights (%s/%s)" % [run_seed, ignored[7], ignored[6]])
		_expect(int(ignored[10]) == 42 and int(ignored[11]) == 42, "seed %s had already cracked the rind nights (%s/%s)" % [run_seed, ignored[11], ignored[10]])
		_expect(int(ignored[12]) == 26 and int(ignored[13]) == 26, "seed %s had already melted the pitch nights (%s/%s)" % [run_seed, ignored[13], ignored[12]])
		_expect(int(ignored[14]) > 0 and int(ignored[15]) == 0, "seed %s left every frost moth unthawed (%s spawned, %s killed)" % [run_seed, ignored[14], ignored[15]])
		_expect(int(ignored[8]) == Sim.START_SEEDS - 5 and int(ignored[9]) == 5, "seed %s never planted a hearth" % run_seed)
		var missed := _play(run_seed, Callable(self, "_corner_hearth_command"))
		print("  corner hearth seed=%s outcome=%s night=%s hp=%s tick=%s frosts=%s/%s" % [run_seed, missed[0], missed[1], missed[4], missed[3], missed[15], missed[14]])
		_expect(int(missed[0]) == Sim.OUTCOME_LOST, "seed %s dies when hearth light misses the gardener" % run_seed)
		_expect(int(missed[1]) == 10 or int(missed[1]) == 11, "seed %s dies on night 10 or 11 with a corner hearth (night %s)" % [run_seed, missed[1]])
		_expect(int(missed[4]) == 0, "seed %s health reached zero" % run_seed)
		_expect(int(missed[8]) == Sim.START_SEEDS - 6 and int(missed[9]) == 6, "seed %s planted the hearth, just not where the night arrives" % run_seed)
		_expect(int(missed[14]) > int(missed[15]), "seed %s left frost moths unthawed (%s spawned, %s killed)" % [run_seed, missed[14], missed[15]])
		var held := _play(run_seed, Callable(self, "_hearth_command"), 11)
		print("  hearth through night 11 seed=%s outcome=%s night=%s phase=%s hp=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s" % [run_seed, held[0], held[1], held[2], held[4], held[7], held[6], held[11], held[10], held[13], held[12], held[15], held[14], held[16]])
		_expect(int(held[0]) == Sim.OUTCOME_RUNNING and int(held[1]) == 11 and int(held[2]) == Sim.PHASE_PLANT, "seed %s still clears night 11 with lantern, pea, wick, briar, flare, and hearth" % run_seed)
		_expect(int(held[4]) > 0, "seed %s still has health after night 11 (%s)" % [run_seed, held[4]])
		_expect(int(held[6]) == 40 and int(held[7]) == 40, "seed %s burned every shroud moth through night 11 (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 58 and int(held[11]) == 58, "seed %s cracked every rind moth through night 11 (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 42 and int(held[13]) == 42, "seed %s melted every pitch moth through night 11 (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 26 and int(held[15]) == 26, "seed %s thawed every frost moth through night 11 (%s/%s)" % [run_seed, held[15], held[14]])
		_expect(int(held[16]) == 0 and int(held[17]) == 0, "seed %s meets no web moth before night 12" % run_seed)
		_expect(int(held[8]) == Sim.START_SEEDS - 6 and int(held[9]) == 6, "seed %s spent lantern, pea, wick, briar, flare, and hearth" % run_seed)
	var again := _play(42, Callable(self, "_hearth_command"), 11)
	var replay := _play(42, Callable(self, "_hearth_command"), 11)
	_expect(str(again) == str(replay), "same seed and hearth plan replay through night 11")


func _test_web_rule() -> void:
	print("shear web rule")
	var placed = Sim.new(4)
	var lantern = Sim.Command.new()
	lantern.plant_kind = Catalog.LANTERN
	lantern.tile = Vector2i(7, 5)
	placed.step(lantern)
	var wick = Sim.Command.new()
	wick.plant_kind = Catalog.WICK
	wick.tile = Vector2i(6, 5)
	placed.step(wick)
	var briar = Sim.Command.new()
	briar.plant_kind = Catalog.BRIAR
	briar.tile = Vector2i(6, 4)
	placed.step(briar)
	var flare = Sim.Command.new()
	flare.plant_kind = Catalog.FLARE
	flare.tile = Vector2i(7, 4)
	placed.step(flare)
	var hearth = Sim.Command.new()
	hearth.plant_kind = Catalog.HEARTH
	hearth.tile = Vector2i(5, 5)
	placed.step(hearth)
	var idle = Sim.Command.new()
	placed.step(idle)
	_expect(placed.tile_burns_shroud(7, 5) and placed.tile_cracks_rind(7, 5) and placed.tile_melts_pitch(7, 5) and placed.tile_thaws_frost(7, 5), "wick, briar, flare, and hearth already cover the gardener")
	_expect(not placed.tile_cuts_web(7, 5), "wick, briar, flare, and hearth light does not cut web")
	var corner = Sim.Command.new()
	corner.plant_kind = Catalog.SHEAR
	corner.tile = Vector2i(1, 1)
	placed.step(corner)
	_expect(not placed.tile_cuts_web(7, 5), "a corner shear does not cut the gardener tile")
	var beside = Sim.Command.new()
	beside.plant_kind = Catalog.SHEAR
	beside.tile = Vector2i(7, 6)
	placed.step(beside)
	_expect(placed.tile_cuts_web(7, 6), "a shear on its own tile cuts it")
	_expect(placed.tile_cuts_web(7, 5), "that shear also cuts the gardener tile")
	var shear_plant = placed.plant_of_kind(Catalog.SHEAR)
	_expect(shear_plant != null and shear_plant.cuts_web and not shear_plant.burns_shroud and not shear_plant.cracks_rind and not shear_plant.melts_pitch and not shear_plant.thaws_frost, "the shear cuts web and does not burn, crack, melt, or thaw")
	_expect(not placed.plant_of_kind(Catalog.WICK).cuts_web, "the wick does not cut web")
	_expect(not placed.plant_of_kind(Catalog.BRIAR).cuts_web, "the briar does not cut web")
	_expect(not placed.plant_of_kind(Catalog.FLARE).cuts_web, "the flare does not cut web")
	_expect(not placed.plant_of_kind(Catalog.HEARTH).cuts_web, "the hearth does not cut web")

	var sim = Sim.new(6)
	var sow_lantern = Sim.Command.new()
	sow_lantern.plant_kind = Catalog.LANTERN
	sow_lantern.tile = Vector2i(7, 5)
	sim.step(sow_lantern)
	var sow_pea = Sim.Command.new()
	sow_pea.plant_kind = Catalog.PEA
	sow_pea.tile = Vector2i(8, 5)
	sim.step(sow_pea)
	var sow_wick = Sim.Command.new()
	sow_wick.plant_kind = Catalog.WICK
	sow_wick.tile = Vector2i(6, 5)
	sim.step(sow_wick)
	var sow_briar = Sim.Command.new()
	sow_briar.plant_kind = Catalog.BRIAR
	sow_briar.tile = Vector2i(6, 4)
	sim.step(sow_briar)
	var sow_flare = Sim.Command.new()
	sow_flare.plant_kind = Catalog.FLARE
	sow_flare.tile = Vector2i(7, 4)
	sim.step(sow_flare)
	var sow_hearth = Sim.Command.new()
	sow_hearth.plant_kind = Catalog.HEARTH
	sow_hearth.tile = Vector2i(5, 5)
	sim.step(sow_hearth)
	var web = sim.spawn_pest(sim.tile_center(7, 4), false, false, false, false, true)
	var normal = sim.spawn_pest(sim.tile_center(8, 8), false, false, false, false, false)
	var shroud = sim.spawn_pest(sim.tile_center(8, 2), true, false, false, false, false)
	var rind = sim.spawn_pest(sim.tile_center(8, 6), false, true, false, false, false)
	var pitch = sim.spawn_pest(sim.tile_center(8, 4), false, false, true, false, false)
	var frost = sim.spawn_pest(sim.tile_center(5, 4), false, false, false, true, false)
	var web_id := int(web.id)
	var normal_id := int(normal.id)
	var shroud_id := int(shroud.id)
	var rind_id := int(rind.id)
	var pitch_id := int(pitch.id)
	var frost_id := int(frost.id)
	_expect(sim.tile_lit(7, 4) and sim.tile_burns_shroud(7, 4) and sim.tile_cracks_rind(7, 4) and sim.tile_melts_pitch(7, 4) and sim.tile_thaws_frost(7, 4) and web.hidden, "wick, briar, flare, and hearth light leaves the web hidden")
	_expect(not frost.hidden, "hearth light still reveals a frost")
	var normal_hit := false
	var web_hit := false
	var shroud_hit := false
	var rind_hit := false
	var pitch_hit := false
	var frost_hit := false
	var guard := 0
	while guard < 40 and sim.outcome == Sim.OUTCOME_RUNNING:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == normal_id:
				normal_hit = true
			if int(event["pest_id"]) == web_id:
				web_hit = true
			if int(event["pest_id"]) == shroud_id:
				shroud_hit = true
			if int(event["pest_id"]) == rind_id:
				rind_hit = true
			if int(event["pest_id"]) == pitch_id:
				pitch_hit = true
			if int(event["pest_id"]) == frost_id:
				frost_hit = true
	var web_now = sim.pest_by_id(web_id)
	_expect(normal_hit, "pea still damages an ordinary moth")
	_expect(not web_hit and web_now != null and int(web_now.hp) == Sim.PEST_HP, "pea does not damage a web outside shear light")
	_expect(not shroud_hit, "wick rule still blocks a shroud outside wick light")
	_expect(rind_hit, "briar light still lets a rind take damage")
	_expect(pitch_hit, "flare light still lets a pitch take damage")
	_expect(frost_hit, "hearth light still lets a frost take damage")
	var sow_shear = Sim.Command.new()
	sow_shear.plant_kind = Catalog.SHEAR
	sow_shear.tile = Vector2i(7, 6)
	sim.step(sow_shear)
	var revealed = sim.pest_by_id(web_id)
	_expect(revealed != null and not revealed.hidden, "shear light beside the web reveals it")
	var parked = sim.spawn_pest(sim.tile_center(7, 8), true, false, false, false, false)
	_expect(sim.tile_cuts_web(7, 8) and not sim.tile_burns_shroud(7, 8), "the shear covers that shroud tile without burning it")
	_expect(parked != null and parked.hidden, "shear light does not reveal a shroud")
	var cut := false
	guard = 0
	while guard < 80 and sim.outcome == Sim.OUTCOME_RUNNING and not cut:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == web_id:
				cut = true
	_expect(cut, "the revealed web takes a hit (hp=%s outcome=%s)" % [sim.player_hp, sim.outcome])

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	splash.step(sow_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false)
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the web")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a web outside shear light")

	var snare = Sim.new(9)
	var snare_lamp = Sim.Command.new()
	snare_lamp.plant_kind = Catalog.LANTERN
	snare_lamp.tile = Vector2i(7, 5)
	snare.step(snare_lamp)
	var snare_wick = Sim.Command.new()
	snare_wick.plant_kind = Catalog.WICK
	snare_wick.tile = Vector2i(6, 5)
	snare.step(snare_wick)
	var snare_briar = Sim.Command.new()
	snare_briar.plant_kind = Catalog.BRIAR
	snare_briar.tile = Vector2i(6, 4)
	snare.step(snare_briar)
	var snare_flare = Sim.Command.new()
	snare_flare.plant_kind = Catalog.FLARE
	snare_flare.tile = Vector2i(7, 4)
	snare.step(snare_flare)
	var snare_pea = Sim.Command.new()
	snare_pea.plant_kind = Catalog.PEA
	snare_pea.tile = Vector2i(8, 5)
	snare.step(snare_pea)
	var snare_hearth = Sim.Command.new()
	snare_hearth.plant_kind = Catalog.HEARTH
	snare_hearth.tile = Vector2i(5, 5)
	snare.step(snare_hearth)
	var sealed = snare.spawn_pest(snare.tile_center(7, 4), true, true, true, true, true)
	var sealed_id := int(sealed.id)
	_expect(snare.tile_burns_shroud(7, 4) and snare.tile_cracks_rind(7, 4) and snare.tile_melts_pitch(7, 4) and snare.tile_thaws_frost(7, 4) and not snare.tile_cuts_web(7, 4) and sealed.hidden, "wick, briar, flare, and hearth leave a snare moth sealed")
	guard = 0
	var sealed_hit := false
	while guard < 20 and snare.outcome == Sim.OUTCOME_RUNNING:
		snare.step(idle)
		guard += 1
		for event in snare.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				sealed_hit = true
	var sealed_now = snare.pest_by_id(sealed_id)
	_expect(not sealed_hit and sealed_now != null and int(sealed_now.hp) == Sim.PEST_HP, "a snare moth ignores shots until the shear cuts it")
	var snare_shear = Sim.Command.new()
	snare_shear.plant_kind = Catalog.SHEAR
	snare_shear.tile = Vector2i(7, 6)
	snare.step(snare_shear)
	var opened = snare.pest_by_id(sealed_id)
	_expect(opened != null and not opened.hidden, "wick, briar, flare, hearth, and shear together reveal a snare moth")
	var opened_hit := false
	guard = 0
	while guard < 80 and snare.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		snare.step(idle)
		guard += 1
		for event in snare.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				opened_hit = true
	_expect(opened_hit, "the opened snare moth takes a hit")


func _test_twelfth_nights() -> void:
	print("nights 12 and 13")
	_expect(int(Sim.WAVES[11]["count"]) == 10 and int(Sim.WAVES[11]["interval"]) == 72 and int(Sim.WAVES[11]["shroud_every"]) == 0 and int(Sim.WAVES[11]["rind_every"]) == 0 and int(Sim.WAVES[11]["pitch_every"]) == 0 and int(Sim.WAVES[11]["frost_every"]) == 0 and int(Sim.WAVES[11]["web_every"]) == 1 and int(Sim.WAVES[11]["glass_every"]) == 0 and int(Sim.WAVES[11]["scale_every"]) == 0 and str(Sim.WAVES[11]["name"]) == "Web", "night 12 is all web")
	_expect(int(Sim.WAVES[12]["count"]) == 16 and int(Sim.WAVES[12]["interval"]) == 60 and int(Sim.WAVES[12]["shroud_every"]) == 2 and int(Sim.WAVES[12]["rind_every"]) == 1 and int(Sim.WAVES[12]["pitch_every"]) == 1 and int(Sim.WAVES[12]["frost_every"]) == 1 and int(Sim.WAVES[12]["web_every"]) == 1 and int(Sim.WAVES[12]["glass_every"]) == 0 and int(Sim.WAVES[12]["scale_every"]) == 0 and str(Sim.WAVES[12]["name"]) == "Snare", "night 13 is web, frost, pitch, and rind, every second also a shroud")
	var named = Sim.new(1)
	named.wave = 12
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 12 of 47 (Web) — 0 pests left", "night 12 heading: %s" % named.phase_text())
	named.wave = 13
	_expect(named.phase_text() == "Night 13 of 47 (Snare) — 0 pests left", "night 13 heading: %s" % named.phase_text())
	named.wave = 11
	named.phase = Sim.PHASE_PLANT
	named.phase_ticks = 0
	_expect(named.phase_text().begins_with("Planting — night 12 (Web)"), "planting before web: %s" % named.phase_text())

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var ignored := _play(run_seed, Callable(self, "_hearth_command"))
		print("  no shear seed=%s outcome=%s night=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s/%s" % [run_seed, ignored[0], ignored[1], ignored[4], ignored[3], ignored[7], ignored[6], ignored[11], ignored[10], ignored[13], ignored[12], ignored[15], ignored[14], ignored[17], ignored[16]])
		_expect(int(ignored[0]) == Sim.OUTCOME_LOST, "seed %s dies when the shear rule is ignored" % run_seed)
		_expect(int(ignored[1]) == 12, "seed %s dies on the web night (night %s)" % [run_seed, ignored[1]])
		_expect(int(ignored[4]) == 0, "seed %s health reached zero on the web night" % run_seed)
		_expect(int(ignored[6]) == 40 and int(ignored[7]) == 40, "seed %s had already burned the shroud nights (%s/%s)" % [run_seed, ignored[7], ignored[6]])
		_expect(int(ignored[10]) == 58 and int(ignored[11]) == 58, "seed %s had already cracked the rind nights (%s/%s)" % [run_seed, ignored[11], ignored[10]])
		_expect(int(ignored[12]) == 42 and int(ignored[13]) == 42, "seed %s had already melted the pitch nights (%s/%s)" % [run_seed, ignored[13], ignored[12]])
		_expect(int(ignored[14]) == 26 and int(ignored[15]) == 26, "seed %s had already thawed the frost nights (%s/%s)" % [run_seed, ignored[15], ignored[14]])
		_expect(int(ignored[16]) > 0 and int(ignored[17]) == 0, "seed %s left every web moth uncut (%s spawned, %s killed)" % [run_seed, ignored[16], ignored[17]])
		_expect(int(ignored[8]) == Sim.START_SEEDS - 6 and int(ignored[9]) == 6, "seed %s never planted a shear" % run_seed)
		var missed := _play(run_seed, Callable(self, "_corner_shear_command"))
		print("  corner shear seed=%s outcome=%s night=%s hp=%s tick=%s webs=%s/%s" % [run_seed, missed[0], missed[1], missed[4], missed[3], missed[17], missed[16]])
		_expect(int(missed[0]) == Sim.OUTCOME_LOST, "seed %s dies when shear light misses the gardener" % run_seed)
		_expect(int(missed[1]) == 12 or int(missed[1]) == 13, "seed %s dies on night 12 or 13 with a corner shear (night %s)" % [run_seed, missed[1]])
		_expect(int(missed[4]) == 0, "seed %s health reached zero" % run_seed)
		_expect(int(missed[8]) == Sim.START_SEEDS - 7 and int(missed[9]) == 7, "seed %s planted the shear, just not where the night arrives" % run_seed)
		_expect(int(missed[16]) > int(missed[17]), "seed %s left web moths uncut (%s spawned, %s killed)" % [run_seed, missed[16], missed[17]])
		var held := _play(run_seed, Callable(self, "_shear_command"), 13)
		print("  shear through night 13 seed=%s outcome=%s night=%s phase=%s hp=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s/%s glasses=%s" % [run_seed, held[0], held[1], held[2], held[4], held[7], held[6], held[11], held[10], held[13], held[12], held[15], held[14], held[17], held[16], held[18]])
		_expect(int(held[0]) == Sim.OUTCOME_RUNNING and int(held[1]) == 13 and int(held[2]) == Sim.PHASE_PLANT, "seed %s still clears night 13 with the shear at (7, 6)" % run_seed)
		_expect(int(held[4]) > 0, "seed %s still has health after night 13 (%s)" % [run_seed, held[4]])
		_expect(int(held[6]) == 48 and int(held[7]) == 48, "seed %s burned every shroud moth through night 13 (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 74 and int(held[11]) == 74, "seed %s cracked every rind moth through night 13 (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 58 and int(held[13]) == 58, "seed %s melted every pitch moth through night 13 (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 42 and int(held[15]) == 42, "seed %s thawed every frost moth through night 13 (%s/%s)" % [run_seed, held[15], held[14]])
		_expect(int(held[16]) == 26 and int(held[17]) == 26, "seed %s cut every web moth through night 13 (%s/%s)" % [run_seed, held[17], held[16]])
		_expect(int(held[18]) == 0 and int(held[19]) == 0, "seed %s meets no glass moth before night 14" % run_seed)
		_expect(int(held[8]) == Sim.START_SEEDS - 7 and int(held[9]) == 7, "seed %s spent lantern, pea, wick, briar, flare, hearth, and shear" % run_seed)
	var again := _play(42, Callable(self, "_shear_command"), 13)
	var replay := _play(42, Callable(self, "_shear_command"), 13)
	_expect(str(again) == str(replay), "same seed and shear plan replay through night 13")


func _test_glass_rule() -> void:
	print("chime glass rule")
	var placed = Sim.new(4)
	var lantern = Sim.Command.new()
	lantern.plant_kind = Catalog.LANTERN
	lantern.tile = Vector2i(7, 5)
	placed.step(lantern)
	var wick = Sim.Command.new()
	wick.plant_kind = Catalog.WICK
	wick.tile = Vector2i(6, 5)
	placed.step(wick)
	var briar = Sim.Command.new()
	briar.plant_kind = Catalog.BRIAR
	briar.tile = Vector2i(6, 4)
	placed.step(briar)
	var flare = Sim.Command.new()
	flare.plant_kind = Catalog.FLARE
	flare.tile = Vector2i(7, 4)
	placed.step(flare)
	var hearth = Sim.Command.new()
	hearth.plant_kind = Catalog.HEARTH
	hearth.tile = Vector2i(5, 5)
	placed.step(hearth)
	var shear = Sim.Command.new()
	shear.plant_kind = Catalog.SHEAR
	shear.tile = Vector2i(7, 6)
	placed.step(shear)
	var idle = Sim.Command.new()
	placed.step(idle)
	_expect(placed.tile_burns_shroud(7, 5) and placed.tile_cracks_rind(7, 5) and placed.tile_melts_pitch(7, 5) and placed.tile_thaws_frost(7, 5) and placed.tile_cuts_web(7, 5), "wick, briar, flare, hearth, and shear already cover the gardener")
	_expect(not placed.tile_cracks_glass(7, 5), "wick, briar, flare, hearth, and shear light does not crack glass")
	var corner = Sim.Command.new()
	corner.plant_kind = Catalog.CHIME
	corner.tile = Vector2i(1, 1)
	placed.step(corner)
	_expect(not placed.tile_cracks_glass(7, 5), "a corner chime does not crack the gardener tile")
	var beside = Sim.Command.new()
	beside.plant_kind = Catalog.CHIME
	beside.tile = Vector2i(8, 6)
	placed.step(beside)
	_expect(placed.tile_cracks_glass(8, 6), "a chime on its own tile cracks it")
	_expect(placed.tile_cracks_glass(7, 5), "that chime also cracks the gardener tile")
	var chime_plant = placed.plant_of_kind(Catalog.CHIME)
	_expect(chime_plant != null and chime_plant.cracks_glass and not chime_plant.burns_shroud and not chime_plant.cracks_rind and not chime_plant.melts_pitch and not chime_plant.thaws_frost and not chime_plant.cuts_web, "the chime cracks glass and does not burn, crack rind, melt, thaw, or cut web")
	_expect(not placed.plant_of_kind(Catalog.WICK).cracks_glass, "the wick does not crack glass")
	_expect(not placed.plant_of_kind(Catalog.BRIAR).cracks_glass, "the briar does not crack glass")
	_expect(not placed.plant_of_kind(Catalog.FLARE).cracks_glass, "the flare does not crack glass")
	_expect(not placed.plant_of_kind(Catalog.HEARTH).cracks_glass, "the hearth does not crack glass")
	_expect(not placed.plant_of_kind(Catalog.SHEAR).cracks_glass, "the shear does not crack glass")

	var sim = Sim.new(6)
	var sow_lantern = Sim.Command.new()
	sow_lantern.plant_kind = Catalog.LANTERN
	sow_lantern.tile = Vector2i(7, 5)
	sim.step(sow_lantern)
	var sow_pea = Sim.Command.new()
	sow_pea.plant_kind = Catalog.PEA
	sow_pea.tile = Vector2i(8, 5)
	sim.step(sow_pea)
	var sow_wick = Sim.Command.new()
	sow_wick.plant_kind = Catalog.WICK
	sow_wick.tile = Vector2i(6, 5)
	sim.step(sow_wick)
	var sow_briar = Sim.Command.new()
	sow_briar.plant_kind = Catalog.BRIAR
	sow_briar.tile = Vector2i(6, 4)
	sim.step(sow_briar)
	var sow_flare = Sim.Command.new()
	sow_flare.plant_kind = Catalog.FLARE
	sow_flare.tile = Vector2i(7, 4)
	sim.step(sow_flare)
	var sow_hearth = Sim.Command.new()
	sow_hearth.plant_kind = Catalog.HEARTH
	sow_hearth.tile = Vector2i(5, 5)
	sim.step(sow_hearth)
	var sow_shear = Sim.Command.new()
	sow_shear.plant_kind = Catalog.SHEAR
	sow_shear.tile = Vector2i(7, 6)
	sim.step(sow_shear)
	var glass = sim.spawn_pest(sim.tile_center(7, 4), false, false, false, false, false, true)
	var normal = sim.spawn_pest(sim.tile_center(8, 8), false, false, false, false, false, false)
	var shroud = sim.spawn_pest(sim.tile_center(8, 2), true, false, false, false, false, false)
	var rind = sim.spawn_pest(sim.tile_center(8, 6), false, true, false, false, false, false)
	var pitch = sim.spawn_pest(sim.tile_center(8, 4), false, false, true, false, false, false)
	var frost = sim.spawn_pest(sim.tile_center(5, 4), false, false, false, true, false, false)
	var web = sim.spawn_pest(sim.tile_center(7, 6), false, false, false, false, true, false)
	var glass_id := int(glass.id)
	var normal_id := int(normal.id)
	var shroud_id := int(shroud.id)
	var rind_id := int(rind.id)
	var pitch_id := int(pitch.id)
	var frost_id := int(frost.id)
	var web_id := int(web.id)
	_expect(sim.tile_lit(7, 4) and sim.tile_burns_shroud(7, 4) and sim.tile_cracks_rind(7, 4) and sim.tile_melts_pitch(7, 4) and sim.tile_thaws_frost(7, 4) and sim.tile_cuts_web(7, 4) and glass.hidden, "wick, briar, flare, hearth, and shear light leaves the glass hidden")
	_expect(not web.hidden, "shear light still reveals a web")
	var normal_hit := false
	var glass_hit := false
	var shroud_hit := false
	var rind_hit := false
	var pitch_hit := false
	var frost_hit := false
	var web_hit := false
	var guard := 0
	while guard < 50 and sim.outcome == Sim.OUTCOME_RUNNING:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == normal_id:
				normal_hit = true
			if int(event["pest_id"]) == glass_id:
				glass_hit = true
			if int(event["pest_id"]) == shroud_id:
				shroud_hit = true
			if int(event["pest_id"]) == rind_id:
				rind_hit = true
			if int(event["pest_id"]) == pitch_id:
				pitch_hit = true
			if int(event["pest_id"]) == frost_id:
				frost_hit = true
			if int(event["pest_id"]) == web_id:
				web_hit = true
	var glass_now = sim.pest_by_id(glass_id)
	_expect(normal_hit, "pea still damages an ordinary moth")
	_expect(not glass_hit and glass_now != null and int(glass_now.hp) == Sim.PEST_HP, "pea does not damage a glass outside chime light")
	_expect(not shroud_hit, "wick rule still blocks a shroud outside wick light")
	_expect(rind_hit, "briar light still lets a rind take damage")
	_expect(pitch_hit, "flare light still lets a pitch take damage")
	_expect(frost_hit, "hearth light still lets a frost take damage")
	_expect(web_hit, "shear light still lets a web take damage")
	var sow_chime = Sim.Command.new()
	sow_chime.plant_kind = Catalog.CHIME
	sow_chime.tile = Vector2i(8, 6)
	sim.step(sow_chime)
	var revealed = sim.pest_by_id(glass_id)
	_expect(revealed != null and not revealed.hidden, "chime light beside the glass reveals it")
	var parked = sim.spawn_pest(sim.tile_center(8, 8), true, false, false, false, false, false)
	_expect(sim.tile_cracks_glass(8, 8) and not sim.tile_burns_shroud(8, 8), "the chime covers that shroud tile without burning it")
	_expect(parked != null and parked.hidden, "chime light does not reveal a shroud")
	var cracked := false
	guard = 0
	while guard < 80 and sim.outcome == Sim.OUTCOME_RUNNING and not cracked:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == glass_id:
				cracked = true
	_expect(cracked, "the revealed glass takes a hit (hp=%s outcome=%s)" % [sim.player_hp, sim.outcome])

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	splash.step(sow_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false)
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the glass")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a glass outside chime light")

	var pane = Sim.new(9)
	var pane_lamp = Sim.Command.new()
	pane_lamp.plant_kind = Catalog.LANTERN
	pane_lamp.tile = Vector2i(7, 5)
	pane.step(pane_lamp)
	var pane_wick = Sim.Command.new()
	pane_wick.plant_kind = Catalog.WICK
	pane_wick.tile = Vector2i(6, 5)
	pane.step(pane_wick)
	var pane_briar = Sim.Command.new()
	pane_briar.plant_kind = Catalog.BRIAR
	pane_briar.tile = Vector2i(6, 4)
	pane.step(pane_briar)
	var pane_flare = Sim.Command.new()
	pane_flare.plant_kind = Catalog.FLARE
	pane_flare.tile = Vector2i(7, 4)
	pane.step(pane_flare)
	var pane_pea = Sim.Command.new()
	pane_pea.plant_kind = Catalog.PEA
	pane_pea.tile = Vector2i(8, 5)
	pane.step(pane_pea)
	var pane_hearth = Sim.Command.new()
	pane_hearth.plant_kind = Catalog.HEARTH
	pane_hearth.tile = Vector2i(5, 5)
	pane.step(pane_hearth)
	var pane_shear = Sim.Command.new()
	pane_shear.plant_kind = Catalog.SHEAR
	pane_shear.tile = Vector2i(7, 6)
	pane.step(pane_shear)
	var sealed = pane.spawn_pest(pane.tile_center(7, 4), true, true, true, true, true, true)
	var sealed_id := int(sealed.id)
	_expect(pane.tile_burns_shroud(7, 4) and pane.tile_cracks_rind(7, 4) and pane.tile_melts_pitch(7, 4) and pane.tile_thaws_frost(7, 4) and pane.tile_cuts_web(7, 4) and not pane.tile_cracks_glass(7, 4) and sealed.hidden, "wick, briar, flare, hearth, and shear leave a pane moth sealed")
	guard = 0
	var sealed_hit := false
	while guard < 20 and pane.outcome == Sim.OUTCOME_RUNNING:
		pane.step(idle)
		guard += 1
		for event in pane.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				sealed_hit = true
	var sealed_now = pane.pest_by_id(sealed_id)
	_expect(not sealed_hit and sealed_now != null and int(sealed_now.hp) == Sim.PEST_HP, "a pane moth ignores shots until the chime cracks it")
	var pane_chime = Sim.Command.new()
	pane_chime.plant_kind = Catalog.CHIME
	pane_chime.tile = Vector2i(8, 6)
	pane.step(pane_chime)
	var opened = pane.pest_by_id(sealed_id)
	_expect(opened != null and not opened.hidden, "wick, briar, flare, hearth, shear, and chime together reveal a pane moth")
	var opened_hit := false
	guard = 0
	while guard < 80 and pane.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		pane.step(idle)
		guard += 1
		for event in pane.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				opened_hit = true
	_expect(opened_hit, "the opened pane moth takes a hit")


func _test_fourteenth_nights() -> void:
	print("nights 14 and 15")
	_expect(int(Sim.WAVES[13]["count"]) == 10 and int(Sim.WAVES[13]["interval"]) == 72 and int(Sim.WAVES[13]["shroud_every"]) == 0 and int(Sim.WAVES[13]["rind_every"]) == 0 and int(Sim.WAVES[13]["pitch_every"]) == 0 and int(Sim.WAVES[13]["frost_every"]) == 0 and int(Sim.WAVES[13]["web_every"]) == 0 and int(Sim.WAVES[13]["glass_every"]) == 1 and int(Sim.WAVES[13]["scale_every"]) == 0 and str(Sim.WAVES[13]["name"]) == "Glass", "night 14 is all glass")
	_expect(int(Sim.WAVES[14]["count"]) == 16 and int(Sim.WAVES[14]["interval"]) == 60 and int(Sim.WAVES[14]["shroud_every"]) == 2 and int(Sim.WAVES[14]["rind_every"]) == 1 and int(Sim.WAVES[14]["pitch_every"]) == 1 and int(Sim.WAVES[14]["frost_every"]) == 1 and int(Sim.WAVES[14]["web_every"]) == 1 and int(Sim.WAVES[14]["glass_every"]) == 1 and int(Sim.WAVES[14]["scale_every"]) == 0 and str(Sim.WAVES[14]["name"]) == "Pane", "night 15 is glass, web, frost, pitch, and rind, every second also a shroud")
	var named = Sim.new(1)
	named.wave = 14
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 14 of 47 (Glass) — 0 pests left", "night 14 heading: %s" % named.phase_text())
	named.wave = 15
	_expect(named.phase_text() == "Night 15 of 47 (Pane) — 0 pests left", "night 15 heading: %s" % named.phase_text())
	named.wave = 13
	named.phase = Sim.PHASE_PLANT
	named.phase_ticks = 0
	_expect(named.phase_text().begins_with("Planting — night 14 (Glass)"), "planting before glass: %s" % named.phase_text())

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var ignored := _play(run_seed, Callable(self, "_shear_command"))
		print("  no chime seed=%s outcome=%s night=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s/%s glasses=%s/%s" % [run_seed, ignored[0], ignored[1], ignored[4], ignored[3], ignored[7], ignored[6], ignored[11], ignored[10], ignored[13], ignored[12], ignored[15], ignored[14], ignored[17], ignored[16], ignored[19], ignored[18]])
		_expect(int(ignored[0]) == Sim.OUTCOME_LOST, "seed %s dies when the chime rule is ignored" % run_seed)
		_expect(int(ignored[1]) == 14, "seed %s dies on the glass night (night %s)" % [run_seed, ignored[1]])
		_expect(int(ignored[4]) == 0, "seed %s health reached zero on the glass night" % run_seed)
		_expect(int(ignored[6]) == 48 and int(ignored[7]) == 48, "seed %s had already burned the shroud nights (%s/%s)" % [run_seed, ignored[7], ignored[6]])
		_expect(int(ignored[10]) == 74 and int(ignored[11]) == 74, "seed %s had already cracked the rind nights (%s/%s)" % [run_seed, ignored[11], ignored[10]])
		_expect(int(ignored[12]) == 58 and int(ignored[13]) == 58, "seed %s had already melted the pitch nights (%s/%s)" % [run_seed, ignored[13], ignored[12]])
		_expect(int(ignored[14]) == 42 and int(ignored[15]) == 42, "seed %s had already thawed the frost nights (%s/%s)" % [run_seed, ignored[15], ignored[14]])
		_expect(int(ignored[16]) == 26 and int(ignored[17]) == 26, "seed %s had already cut the web nights (%s/%s)" % [run_seed, ignored[17], ignored[16]])
		_expect(int(ignored[18]) > 0 and int(ignored[19]) == 0, "seed %s left every glass moth uncracked (%s spawned, %s killed)" % [run_seed, ignored[18], ignored[19]])
		_expect(int(ignored[8]) == Sim.START_SEEDS - 7 and int(ignored[9]) == 7, "seed %s never planted a chime" % run_seed)
		var missed := _play(run_seed, Callable(self, "_corner_chime_command"))
		print("  corner chime seed=%s outcome=%s night=%s hp=%s tick=%s glasses=%s/%s" % [run_seed, missed[0], missed[1], missed[4], missed[3], missed[19], missed[18]])
		_expect(int(missed[0]) == Sim.OUTCOME_LOST, "seed %s dies when chime light misses the gardener" % run_seed)
		_expect(int(missed[1]) == 14, "seed %s dies on night 14 with a corner chime (night %s)" % [run_seed, missed[1]])
		_expect(int(missed[4]) == 0, "seed %s health reached zero" % run_seed)
		_expect(int(missed[8]) == Sim.START_SEEDS - 8 and int(missed[9]) == 8, "seed %s planted the chime, just not where the night arrives" % run_seed)
		_expect(int(missed[18]) > int(missed[19]), "seed %s left glass moths uncracked (%s spawned, %s killed)" % [run_seed, missed[18], missed[19]])
		var held := _play(run_seed, Callable(self, "_chime_command"), 15)
		print("  chime through night 15 seed=%s outcome=%s night=%s phase=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s/%s glasses=%s/%s scales=%s" % [run_seed, held[0], held[1], held[2], held[4], held[3], held[7], held[6], held[11], held[10], held[13], held[12], held[15], held[14], held[17], held[16], held[19], held[18], held[20]])
		_expect(int(held[0]) == Sim.OUTCOME_RUNNING and int(held[1]) == 15 and int(held[2]) == Sim.PHASE_PLANT, "seed %s still clears night 15 with the chime at (8, 6)" % run_seed)
		_expect(int(held[4]) > 0, "seed %s finished night 15 with health %s" % [run_seed, held[4]])
		_expect(int(held[6]) == 56 and int(held[7]) == 56, "seed %s burned every shroud moth (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 90 and int(held[11]) == 90, "seed %s cracked every rind moth (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 74 and int(held[13]) == 74, "seed %s melted every pitch moth (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 58 and int(held[15]) == 58, "seed %s thawed every frost moth (%s/%s)" % [run_seed, held[15], held[14]])
		_expect(int(held[16]) == 42 and int(held[17]) == 42, "seed %s cut every web moth (%s/%s)" % [run_seed, held[17], held[16]])
		_expect(int(held[18]) == 26 and int(held[19]) == 26, "seed %s cracked every glass moth (%s/%s)" % [run_seed, held[19], held[18]])
		_expect(int(held[20]) == 0 and int(held[21]) == 0, "seed %s meets no scale moth before night 16" % run_seed)
		_expect(int(held[8]) == Sim.START_SEEDS - 8 and int(held[9]) == 8, "seed %s spent lantern, pea, wick, briar, flare, hearth, shear, and chime" % run_seed)
	var again := _play(42, Callable(self, "_chime_command"), 15)
	var replay := _play(42, Callable(self, "_chime_command"), 15)
	_expect(str(again) == str(replay), "same seed and chime plan replay through night 15")


func _test_scale_rule() -> void:
	print("rasp scale rule")
	var placed = Sim.new(4)
	var lantern = Sim.Command.new()
	lantern.plant_kind = Catalog.LANTERN
	lantern.tile = Vector2i(7, 5)
	placed.step(lantern)
	var wick = Sim.Command.new()
	wick.plant_kind = Catalog.WICK
	wick.tile = Vector2i(6, 5)
	placed.step(wick)
	var briar = Sim.Command.new()
	briar.plant_kind = Catalog.BRIAR
	briar.tile = Vector2i(6, 4)
	placed.step(briar)
	var flare = Sim.Command.new()
	flare.plant_kind = Catalog.FLARE
	flare.tile = Vector2i(7, 4)
	placed.step(flare)
	var hearth = Sim.Command.new()
	hearth.plant_kind = Catalog.HEARTH
	hearth.tile = Vector2i(5, 5)
	placed.step(hearth)
	var shear = Sim.Command.new()
	shear.plant_kind = Catalog.SHEAR
	shear.tile = Vector2i(7, 6)
	placed.step(shear)
	var chime = Sim.Command.new()
	chime.plant_kind = Catalog.CHIME
	chime.tile = Vector2i(8, 6)
	placed.step(chime)
	var idle = Sim.Command.new()
	placed.step(idle)
	_expect(placed.tile_burns_shroud(7, 5) and placed.tile_cracks_rind(7, 5) and placed.tile_melts_pitch(7, 5) and placed.tile_thaws_frost(7, 5) and placed.tile_cuts_web(7, 5) and placed.tile_cracks_glass(7, 5), "wick, briar, flare, hearth, shear, and chime already cover the gardener")
	_expect(not placed.tile_strips_scale(7, 5), "wick, briar, flare, hearth, shear, and chime light does not strip scale")
	var corner = Sim.Command.new()
	corner.plant_kind = Catalog.RASP
	corner.tile = Vector2i(1, 1)
	placed.step(corner)
	_expect(not placed.tile_strips_scale(7, 5), "a corner rasp does not strip the gardener tile")
	var beside = Sim.Command.new()
	beside.plant_kind = Catalog.RASP
	beside.tile = Vector2i(9, 5)
	placed.step(beside)
	_expect(placed.tile_strips_scale(9, 5), "a rasp on its own tile strips it")
	_expect(placed.tile_strips_scale(7, 5), "that rasp also strips the gardener tile")
	var rasp_plant = placed.plant_of_kind(Catalog.RASP)
	_expect(rasp_plant != null and rasp_plant.strips_scale and not rasp_plant.burns_shroud and not rasp_plant.cracks_rind and not rasp_plant.melts_pitch and not rasp_plant.thaws_frost and not rasp_plant.cuts_web and not rasp_plant.cracks_glass, "the rasp strips scale and does not burn, crack rind, melt, thaw, cut web, or crack glass")
	_expect(not placed.plant_of_kind(Catalog.WICK).strips_scale, "the wick does not strip scale")
	_expect(not placed.plant_of_kind(Catalog.BRIAR).strips_scale, "the briar does not strip scale")
	_expect(not placed.plant_of_kind(Catalog.FLARE).strips_scale, "the flare does not strip scale")
	_expect(not placed.plant_of_kind(Catalog.HEARTH).strips_scale, "the hearth does not strip scale")
	_expect(not placed.plant_of_kind(Catalog.SHEAR).strips_scale, "the shear does not strip scale")
	_expect(not placed.plant_of_kind(Catalog.CHIME).strips_scale, "the chime does not strip scale")

	var sim = Sim.new(6)
	var sow_lantern = Sim.Command.new()
	sow_lantern.plant_kind = Catalog.LANTERN
	sow_lantern.tile = Vector2i(7, 5)
	sim.step(sow_lantern)
	var sow_pea = Sim.Command.new()
	sow_pea.plant_kind = Catalog.PEA
	sow_pea.tile = Vector2i(8, 5)
	sim.step(sow_pea)
	var sow_wick = Sim.Command.new()
	sow_wick.plant_kind = Catalog.WICK
	sow_wick.tile = Vector2i(6, 5)
	sim.step(sow_wick)
	var sow_briar = Sim.Command.new()
	sow_briar.plant_kind = Catalog.BRIAR
	sow_briar.tile = Vector2i(6, 4)
	sim.step(sow_briar)
	var sow_flare = Sim.Command.new()
	sow_flare.plant_kind = Catalog.FLARE
	sow_flare.tile = Vector2i(7, 4)
	sim.step(sow_flare)
	var sow_hearth = Sim.Command.new()
	sow_hearth.plant_kind = Catalog.HEARTH
	sow_hearth.tile = Vector2i(5, 5)
	sim.step(sow_hearth)
	var sow_shear = Sim.Command.new()
	sow_shear.plant_kind = Catalog.SHEAR
	sow_shear.tile = Vector2i(7, 6)
	sim.step(sow_shear)
	var sow_chime = Sim.Command.new()
	sow_chime.plant_kind = Catalog.CHIME
	sow_chime.tile = Vector2i(8, 6)
	sim.step(sow_chime)
	var scale = sim.spawn_pest(sim.tile_center(7, 4), false, false, false, false, false, false, true)
	var normal = sim.spawn_pest(sim.tile_center(8, 8), false, false, false, false, false, false, false)
	var shroud = sim.spawn_pest(sim.tile_center(8, 2), true, false, false, false, false, false, false)
	var rind = sim.spawn_pest(sim.tile_center(8, 6), false, true, false, false, false, false, false)
	var pitch = sim.spawn_pest(sim.tile_center(8, 4), false, false, true, false, false, false, false)
	var frost = sim.spawn_pest(sim.tile_center(5, 4), false, false, false, true, false, false, false)
	var web = sim.spawn_pest(sim.tile_center(7, 6), false, false, false, false, true, false, false)
	var glass = sim.spawn_pest(sim.tile_center(7, 3), false, false, false, false, false, true, false)
	var scale_id := int(scale.id)
	var normal_id := int(normal.id)
	var shroud_id := int(shroud.id)
	var rind_id := int(rind.id)
	var pitch_id := int(pitch.id)
	var frost_id := int(frost.id)
	var web_id := int(web.id)
	var glass_id := int(glass.id)
	_expect(sim.tile_lit(7, 4) and sim.tile_burns_shroud(7, 4) and sim.tile_cracks_rind(7, 4) and sim.tile_melts_pitch(7, 4) and sim.tile_thaws_frost(7, 4) and sim.tile_cuts_web(7, 4) and sim.tile_cracks_glass(7, 4) and scale.hidden, "wick, briar, flare, hearth, shear, and chime light leaves the scale hidden")
	_expect(not glass.hidden, "chime light still reveals a glass")
	var normal_hit := false
	var scale_hit := false
	var shroud_hit := false
	var rind_hit := false
	var pitch_hit := false
	var frost_hit := false
	var web_hit := false
	var glass_hit := false
	var guard := 0
	while guard < 50 and sim.outcome == Sim.OUTCOME_RUNNING:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == normal_id:
				normal_hit = true
			if int(event["pest_id"]) == scale_id:
				scale_hit = true
			if int(event["pest_id"]) == shroud_id:
				shroud_hit = true
			if int(event["pest_id"]) == rind_id:
				rind_hit = true
			if int(event["pest_id"]) == pitch_id:
				pitch_hit = true
			if int(event["pest_id"]) == frost_id:
				frost_hit = true
			if int(event["pest_id"]) == web_id:
				web_hit = true
			if int(event["pest_id"]) == glass_id:
				glass_hit = true
	var scale_now = sim.pest_by_id(scale_id)
	_expect(normal_hit, "pea still damages an ordinary moth")
	_expect(not scale_hit and scale_now != null and int(scale_now.hp) == Sim.PEST_HP, "pea does not damage a scale outside rasp light")
	_expect(not shroud_hit, "wick rule still blocks a shroud outside wick light")
	_expect(rind_hit, "briar light still lets a rind take damage")
	_expect(pitch_hit, "flare light still lets a pitch take damage")
	_expect(frost_hit, "hearth light still lets a frost take damage")
	_expect(web_hit, "shear light still lets a web take damage")
	_expect(glass_hit, "chime light still lets a glass take damage")
	var sow_rasp = Sim.Command.new()
	sow_rasp.plant_kind = Catalog.RASP
	sow_rasp.tile = Vector2i(9, 5)
	sim.step(sow_rasp)
	var revealed = sim.pest_by_id(scale_id)
	_expect(revealed != null and not revealed.hidden, "rasp light beside the scale reveals it")
	var parked = sim.spawn_pest(sim.tile_center(9, 8), true, false, false, false, false, false, false)
	_expect(sim.tile_strips_scale(9, 8) and not sim.tile_burns_shroud(9, 8), "the rasp covers that shroud tile without burning it")
	_expect(parked != null and parked.hidden, "rasp light does not reveal a shroud")
	var stripped := false
	guard = 0
	while guard < 80 and sim.outcome == Sim.OUTCOME_RUNNING and not stripped:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == scale_id:
				stripped = true
	_expect(stripped, "the revealed scale takes a hit (hp=%s outcome=%s)" % [sim.player_hp, sim.outcome])

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	splash.step(sow_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false)
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the scale")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a scale outside rasp light")

	var plate = Sim.new(9)
	var plate_lamp = Sim.Command.new()
	plate_lamp.plant_kind = Catalog.LANTERN
	plate_lamp.tile = Vector2i(7, 5)
	plate.step(plate_lamp)
	var plate_wick = Sim.Command.new()
	plate_wick.plant_kind = Catalog.WICK
	plate_wick.tile = Vector2i(6, 5)
	plate.step(plate_wick)
	var plate_briar = Sim.Command.new()
	plate_briar.plant_kind = Catalog.BRIAR
	plate_briar.tile = Vector2i(6, 4)
	plate.step(plate_briar)
	var plate_flare = Sim.Command.new()
	plate_flare.plant_kind = Catalog.FLARE
	plate_flare.tile = Vector2i(7, 4)
	plate.step(plate_flare)
	var plate_pea = Sim.Command.new()
	plate_pea.plant_kind = Catalog.PEA
	plate_pea.tile = Vector2i(8, 5)
	plate.step(plate_pea)
	var plate_hearth = Sim.Command.new()
	plate_hearth.plant_kind = Catalog.HEARTH
	plate_hearth.tile = Vector2i(5, 5)
	plate.step(plate_hearth)
	var plate_shear = Sim.Command.new()
	plate_shear.plant_kind = Catalog.SHEAR
	plate_shear.tile = Vector2i(7, 6)
	plate.step(plate_shear)
	var plate_chime = Sim.Command.new()
	plate_chime.plant_kind = Catalog.CHIME
	plate_chime.tile = Vector2i(8, 6)
	plate.step(plate_chime)
	var sealed = plate.spawn_pest(plate.tile_center(7, 4), true, true, true, true, true, true, true)
	var sealed_id := int(sealed.id)
	_expect(plate.tile_burns_shroud(7, 4) and plate.tile_cracks_rind(7, 4) and plate.tile_melts_pitch(7, 4) and plate.tile_thaws_frost(7, 4) and plate.tile_cuts_web(7, 4) and plate.tile_cracks_glass(7, 4) and not plate.tile_strips_scale(7, 4) and sealed.hidden, "chime, shear, wick, briar, flare, and hearth leave a scale moth sealed")
	guard = 0
	var sealed_hit := false
	while guard < 20 and plate.outcome == Sim.OUTCOME_RUNNING:
		plate.step(idle)
		guard += 1
		for event in plate.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				sealed_hit = true
	var sealed_now = plate.pest_by_id(sealed_id)
	_expect(not sealed_hit and sealed_now != null and int(sealed_now.hp) == Sim.PEST_HP, "a plate moth ignores shots until the rasp strips it")
	var plate_rasp = Sim.Command.new()
	plate_rasp.plant_kind = Catalog.RASP
	plate_rasp.tile = Vector2i(9, 5)
	plate.step(plate_rasp)
	var opened = plate.pest_by_id(sealed_id)
	_expect(opened != null and not opened.hidden, "wick, briar, flare, hearth, shear, chime, and rasp together reveal a plate moth")
	var opened_hit := false
	guard = 0
	while guard < 80 and plate.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		plate.step(idle)
		guard += 1
		for event in plate.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				opened_hit = true
	_expect(opened_hit, "the opened plate moth takes a hit")


func _test_sixteenth_nights() -> void:
	print("nights 16 and 17")
	_expect(int(Sim.WAVES[15]["count"]) == 10 and int(Sim.WAVES[15]["interval"]) == 72 and int(Sim.WAVES[15]["shroud_every"]) == 0 and int(Sim.WAVES[15]["rind_every"]) == 0 and int(Sim.WAVES[15]["pitch_every"]) == 0 and int(Sim.WAVES[15]["frost_every"]) == 0 and int(Sim.WAVES[15]["web_every"]) == 0 and int(Sim.WAVES[15]["glass_every"]) == 0 and int(Sim.WAVES[15]["scale_every"]) == 1 and int(Sim.WAVES[15]["mail_every"]) == 0 and str(Sim.WAVES[15]["name"]) == "Scale", "night 16 is all scale")
	_expect(int(Sim.WAVES[16]["count"]) == 16 and int(Sim.WAVES[16]["interval"]) == 60 and int(Sim.WAVES[16]["shroud_every"]) == 2 and int(Sim.WAVES[16]["rind_every"]) == 1 and int(Sim.WAVES[16]["pitch_every"]) == 1 and int(Sim.WAVES[16]["frost_every"]) == 1 and int(Sim.WAVES[16]["web_every"]) == 1 and int(Sim.WAVES[16]["glass_every"]) == 1 and int(Sim.WAVES[16]["scale_every"]) == 1 and int(Sim.WAVES[16]["mail_every"]) == 0 and str(Sim.WAVES[16]["name"]) == "Plate", "night 17 is scale, glass, web, frost, pitch, and rind, every second also a shroud")
	for i in 15:
		_expect(int(Sim.WAVES[i]["scale_every"]) == 0, "night %d still spawns no scale" % (i + 1))
	var named = Sim.new(1)
	named.wave = 16
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 16 of 47 (Scale) — 0 pests left", "night 16 heading: %s" % named.phase_text())
	named.wave = 17
	_expect(named.phase_text() == "Night 17 of 47 (Plate) — 0 pests left", "night 17 heading: %s" % named.phase_text())
	named.wave = 15
	named.phase = Sim.PHASE_PLANT
	named.phase_ticks = 0
	_expect(named.phase_text().begins_with("Planting — night 16 (Scale)"), "planting before scale: %s" % named.phase_text())

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var ignored := _play(run_seed, Callable(self, "_chime_command"))
		print("  no rasp seed=%s outcome=%s night=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s/%s glasses=%s/%s scales=%s/%s" % [run_seed, ignored[0], ignored[1], ignored[4], ignored[3], ignored[7], ignored[6], ignored[11], ignored[10], ignored[13], ignored[12], ignored[15], ignored[14], ignored[17], ignored[16], ignored[19], ignored[18], ignored[21], ignored[20]])
		_expect(int(ignored[0]) == Sim.OUTCOME_LOST, "seed %s dies when the rasp rule is ignored" % run_seed)
		_expect(int(ignored[1]) == 16, "seed %s dies on the scale night (night %s)" % [run_seed, ignored[1]])
		_expect(int(ignored[4]) == 0, "seed %s health reached zero on the scale night" % run_seed)
		_expect(int(ignored[6]) == 56 and int(ignored[7]) == 56, "seed %s had already burned the shroud nights (%s/%s)" % [run_seed, ignored[7], ignored[6]])
		_expect(int(ignored[10]) == 90 and int(ignored[11]) == 90, "seed %s had already cracked the rind nights (%s/%s)" % [run_seed, ignored[11], ignored[10]])
		_expect(int(ignored[12]) == 74 and int(ignored[13]) == 74, "seed %s had already melted the pitch nights (%s/%s)" % [run_seed, ignored[13], ignored[12]])
		_expect(int(ignored[14]) == 58 and int(ignored[15]) == 58, "seed %s had already thawed the frost nights (%s/%s)" % [run_seed, ignored[15], ignored[14]])
		_expect(int(ignored[16]) == 42 and int(ignored[17]) == 42, "seed %s had already cut the web nights (%s/%s)" % [run_seed, ignored[17], ignored[16]])
		_expect(int(ignored[18]) == 26 and int(ignored[19]) == 26, "seed %s had already cracked the glass nights (%s/%s)" % [run_seed, ignored[19], ignored[18]])
		_expect(int(ignored[20]) > 0 and int(ignored[21]) == 0, "seed %s left every scale moth unstripped (%s spawned, %s killed)" % [run_seed, ignored[20], ignored[21]])
		_expect(int(ignored[8]) == Sim.START_SEEDS - 8 and int(ignored[9]) == 8, "seed %s never planted a rasp" % run_seed)
		var missed := _play(run_seed, Callable(self, "_corner_rasp_command"))
		print("  corner rasp seed=%s outcome=%s night=%s hp=%s tick=%s scales=%s/%s" % [run_seed, missed[0], missed[1], missed[4], missed[3], missed[21], missed[20]])
		_expect(int(missed[0]) == Sim.OUTCOME_LOST, "seed %s dies when rasp light misses the gardener" % run_seed)
		_expect(int(missed[1]) == 16, "seed %s dies on night 16 with a corner rasp (night %s)" % [run_seed, missed[1]])
		_expect(int(missed[4]) == 0, "seed %s health reached zero" % run_seed)
		_expect(int(missed[8]) == Sim.START_SEEDS - 9 and int(missed[9]) == 9, "seed %s planted the rasp, just not where the night arrives" % run_seed)
		_expect(int(missed[20]) > int(missed[21]), "seed %s left scale moths unstripped (%s spawned, %s killed)" % [run_seed, missed[20], missed[21]])
		var held := _play(run_seed, Callable(self, "_rasp_command"), 17)
		print("  rasp through night 17 seed=%s outcome=%s night=%s phase=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s/%s glasses=%s/%s scales=%s/%s mails=%s" % [run_seed, held[0], held[1], held[2], held[4], held[3], held[7], held[6], held[11], held[10], held[13], held[12], held[15], held[14], held[17], held[16], held[19], held[18], held[21], held[20], held[22]])
		_expect(int(held[0]) == Sim.OUTCOME_RUNNING and int(held[1]) == 17 and int(held[2]) == Sim.PHASE_PLANT, "seed %s still clears night 17 with the rasp at (9, 5)" % run_seed)
		_expect(int(held[4]) == 100, "seed %s finished night 17 at full health (%s)" % [run_seed, held[4]])
		_expect(int(held[6]) == 64 and int(held[7]) == 64, "seed %s burned every shroud moth (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 106 and int(held[11]) == 106, "seed %s cracked every rind moth (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 90 and int(held[13]) == 90, "seed %s melted every pitch moth (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 74 and int(held[15]) == 74, "seed %s thawed every frost moth (%s/%s)" % [run_seed, held[15], held[14]])
		_expect(int(held[16]) == 58 and int(held[17]) == 58, "seed %s cut every web moth (%s/%s)" % [run_seed, held[17], held[16]])
		_expect(int(held[18]) == 42 and int(held[19]) == 42, "seed %s cracked every glass moth (%s/%s)" % [run_seed, held[19], held[18]])
		_expect(int(held[20]) == 26 and int(held[21]) == 26, "seed %s stripped every scale moth (%s/%s)" % [run_seed, held[21], held[20]])
		_expect(int(held[22]) == 0 and int(held[23]) == 0, "seed %s meets no mail moth before night 18" % run_seed)
		_expect(int(held[8]) == Sim.START_SEEDS - 9 and int(held[9]) == 9, "seed %s spent lantern, pea, wick, briar, flare, hearth, shear, chime, and rasp" % run_seed)
	var again := _play(42, Callable(self, "_rasp_command"), 17)
	var replay := _play(42, Callable(self, "_rasp_command"), 17)
	_expect(str(again) == str(replay), "same seed and rasp plan replay through night 17")


func _test_mail_rule() -> void:
	print("maul mail rule")
	var placed = Sim.new(4)
	var lantern = Sim.Command.new()
	lantern.plant_kind = Catalog.LANTERN
	lantern.tile = Vector2i(7, 5)
	placed.step(lantern)
	var wick = Sim.Command.new()
	wick.plant_kind = Catalog.WICK
	wick.tile = Vector2i(6, 5)
	placed.step(wick)
	var briar = Sim.Command.new()
	briar.plant_kind = Catalog.BRIAR
	briar.tile = Vector2i(6, 4)
	placed.step(briar)
	var flare = Sim.Command.new()
	flare.plant_kind = Catalog.FLARE
	flare.tile = Vector2i(7, 4)
	placed.step(flare)
	var hearth = Sim.Command.new()
	hearth.plant_kind = Catalog.HEARTH
	hearth.tile = Vector2i(5, 5)
	placed.step(hearth)
	var shear = Sim.Command.new()
	shear.plant_kind = Catalog.SHEAR
	shear.tile = Vector2i(7, 6)
	placed.step(shear)
	var chime = Sim.Command.new()
	chime.plant_kind = Catalog.CHIME
	chime.tile = Vector2i(8, 6)
	placed.step(chime)
	var rasp = Sim.Command.new()
	rasp.plant_kind = Catalog.RASP
	rasp.tile = Vector2i(9, 5)
	placed.step(rasp)
	var idle = Sim.Command.new()
	placed.step(idle)
	_expect(placed.tile_burns_shroud(7, 5) and placed.tile_cracks_rind(7, 5) and placed.tile_melts_pitch(7, 5) and placed.tile_thaws_frost(7, 5) and placed.tile_cuts_web(7, 5) and placed.tile_cracks_glass(7, 5) and placed.tile_strips_scale(7, 5), "rasp, chime, shear, wick, briar, flare, and hearth already cover the gardener")
	_expect(not placed.tile_cracks_mail(7, 5), "rasp, chime, shear, wick, briar, flare, and hearth light does not crack mail")
	var corner = Sim.Command.new()
	corner.plant_kind = Catalog.MAUL
	corner.tile = Vector2i(1, 1)
	placed.step(corner)
	_expect(not placed.tile_cracks_mail(7, 5), "a corner maul does not crack the gardener tile")
	var beside = Sim.Command.new()
	beside.plant_kind = Catalog.MAUL
	beside.tile = Vector2i(9, 6)
	placed.step(beside)
	_expect(placed.tile_cracks_mail(9, 6), "a maul on its own tile cracks it")
	_expect(placed.tile_cracks_mail(7, 5), "that maul also cracks the gardener tile")
	var maul_plant = placed.plant_of_kind(Catalog.MAUL)
	_expect(maul_plant != null and maul_plant.cracks_mail and not maul_plant.burns_shroud and not maul_plant.cracks_rind and not maul_plant.melts_pitch and not maul_plant.thaws_frost and not maul_plant.cuts_web and not maul_plant.cracks_glass and not maul_plant.strips_scale, "the maul cracks mail and does not burn, crack rind, melt, thaw, cut web, crack glass, or strip scale")
	_expect(not placed.plant_of_kind(Catalog.WICK).cracks_mail, "the wick does not crack mail")
	_expect(not placed.plant_of_kind(Catalog.BRIAR).cracks_mail, "the briar does not crack mail")
	_expect(not placed.plant_of_kind(Catalog.FLARE).cracks_mail, "the flare does not crack mail")
	_expect(not placed.plant_of_kind(Catalog.HEARTH).cracks_mail, "the hearth does not crack mail")
	_expect(not placed.plant_of_kind(Catalog.SHEAR).cracks_mail, "the shear does not crack mail")
	_expect(not placed.plant_of_kind(Catalog.CHIME).cracks_mail, "the chime does not crack mail")
	_expect(not placed.plant_of_kind(Catalog.RASP).cracks_mail, "the rasp does not crack mail")

	var sim = Sim.new(6)
	var sow_lantern = Sim.Command.new()
	sow_lantern.plant_kind = Catalog.LANTERN
	sow_lantern.tile = Vector2i(7, 5)
	sim.step(sow_lantern)
	var sow_pea = Sim.Command.new()
	sow_pea.plant_kind = Catalog.PEA
	sow_pea.tile = Vector2i(8, 5)
	sim.step(sow_pea)
	var sow_wick = Sim.Command.new()
	sow_wick.plant_kind = Catalog.WICK
	sow_wick.tile = Vector2i(6, 5)
	sim.step(sow_wick)
	var sow_briar = Sim.Command.new()
	sow_briar.plant_kind = Catalog.BRIAR
	sow_briar.tile = Vector2i(6, 4)
	sim.step(sow_briar)
	var sow_flare = Sim.Command.new()
	sow_flare.plant_kind = Catalog.FLARE
	sow_flare.tile = Vector2i(7, 4)
	sim.step(sow_flare)
	var sow_hearth = Sim.Command.new()
	sow_hearth.plant_kind = Catalog.HEARTH
	sow_hearth.tile = Vector2i(5, 5)
	sim.step(sow_hearth)
	var sow_shear = Sim.Command.new()
	sow_shear.plant_kind = Catalog.SHEAR
	sow_shear.tile = Vector2i(7, 6)
	sim.step(sow_shear)
	var sow_chime = Sim.Command.new()
	sow_chime.plant_kind = Catalog.CHIME
	sow_chime.tile = Vector2i(8, 6)
	sim.step(sow_chime)
	var sow_rasp = Sim.Command.new()
	sow_rasp.plant_kind = Catalog.RASP
	sow_rasp.tile = Vector2i(9, 5)
	sim.step(sow_rasp)
	var mail = sim.spawn_pest(sim.tile_center(7, 4), false, false, false, false, false, false, false, true)
	var normal = sim.spawn_pest(sim.tile_center(8, 8), false, false, false, false, false, false, false, false)
	var shroud = sim.spawn_pest(sim.tile_center(8, 2), true, false, false, false, false, false, false, false)
	var scale = sim.spawn_pest(sim.tile_center(8, 7), false, false, false, false, false, false, true, false)
	var mail_id := int(mail.id)
	var normal_id := int(normal.id)
	var shroud_id := int(shroud.id)
	var scale_id := int(scale.id)
	_expect(sim.tile_lit(7, 4) and sim.tile_burns_shroud(7, 4) and sim.tile_cracks_rind(7, 4) and sim.tile_melts_pitch(7, 4) and sim.tile_thaws_frost(7, 4) and sim.tile_cuts_web(7, 4) and sim.tile_cracks_glass(7, 4) and sim.tile_strips_scale(7, 4) and not sim.tile_cracks_mail(7, 4) and mail.hidden, "rasp, chime, shear, wick, briar, flare, and hearth light leaves the mail hidden")
	_expect(not scale.hidden, "rasp light still reveals a scale")
	var normal_hit := false
	var mail_hit := false
	var shroud_hit := false
	var scale_hit := false
	var guard := 0
	while guard < 50 and sim.outcome == Sim.OUTCOME_RUNNING:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == normal_id:
				normal_hit = true
			if int(event["pest_id"]) == mail_id:
				mail_hit = true
			if int(event["pest_id"]) == shroud_id:
				shroud_hit = true
			if int(event["pest_id"]) == scale_id:
				scale_hit = true
	var mail_now = sim.pest_by_id(mail_id)
	_expect(normal_hit, "pea still damages an ordinary moth")
	_expect(not mail_hit and mail_now != null and int(mail_now.hp) == Sim.PEST_HP, "pea does not damage a mail outside maul light")
	_expect(not shroud_hit, "wick rule still blocks a shroud outside wick light")
	_expect(scale_hit, "rasp light still lets a scale take damage")
	var sow_maul = Sim.Command.new()
	sow_maul.plant_kind = Catalog.MAUL
	sow_maul.tile = Vector2i(9, 6)
	sim.step(sow_maul)
	var revealed = sim.pest_by_id(mail_id)
	_expect(revealed != null and not revealed.hidden, "maul light beside the mail reveals it")
	var parked = sim.spawn_pest(sim.tile_center(7, 9), true, false, false, false, false, false, false, false)
	_expect(sim.tile_cracks_mail(7, 9) and not sim.tile_strips_scale(7, 9) and not sim.tile_burns_shroud(7, 9), "the maul covers that shroud tile without stripping or burning it")
	_expect(parked != null and parked.hidden, "maul light does not reveal a shroud")
	var cracked := false
	guard = 0
	while guard < 80 and sim.outcome == Sim.OUTCOME_RUNNING and not cracked:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == mail_id:
				cracked = true
	_expect(cracked, "the revealed mail takes a hit (hp=%s outcome=%s)" % [sim.player_hp, sim.outcome])

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	splash.step(sow_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false)
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the mail")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a mail outside maul light")

	var armor = Sim.new(9)
	var armor_lamp = Sim.Command.new()
	armor_lamp.plant_kind = Catalog.LANTERN
	armor_lamp.tile = Vector2i(7, 5)
	armor.step(armor_lamp)
	var armor_wick = Sim.Command.new()
	armor_wick.plant_kind = Catalog.WICK
	armor_wick.tile = Vector2i(6, 5)
	armor.step(armor_wick)
	var armor_briar = Sim.Command.new()
	armor_briar.plant_kind = Catalog.BRIAR
	armor_briar.tile = Vector2i(6, 4)
	armor.step(armor_briar)
	var armor_flare = Sim.Command.new()
	armor_flare.plant_kind = Catalog.FLARE
	armor_flare.tile = Vector2i(7, 4)
	armor.step(armor_flare)
	var armor_pea = Sim.Command.new()
	armor_pea.plant_kind = Catalog.PEA
	armor_pea.tile = Vector2i(8, 5)
	armor.step(armor_pea)
	var armor_hearth = Sim.Command.new()
	armor_hearth.plant_kind = Catalog.HEARTH
	armor_hearth.tile = Vector2i(5, 5)
	armor.step(armor_hearth)
	var armor_shear = Sim.Command.new()
	armor_shear.plant_kind = Catalog.SHEAR
	armor_shear.tile = Vector2i(7, 6)
	armor.step(armor_shear)
	var armor_chime = Sim.Command.new()
	armor_chime.plant_kind = Catalog.CHIME
	armor_chime.tile = Vector2i(8, 6)
	armor.step(armor_chime)
	var armor_rasp = Sim.Command.new()
	armor_rasp.plant_kind = Catalog.RASP
	armor_rasp.tile = Vector2i(9, 5)
	armor.step(armor_rasp)
	var sealed = armor.spawn_pest(armor.tile_center(7, 4), true, true, true, true, true, true, true, true)
	var sealed_id := int(sealed.id)
	_expect(armor.tile_burns_shroud(7, 4) and armor.tile_cracks_rind(7, 4) and armor.tile_melts_pitch(7, 4) and armor.tile_thaws_frost(7, 4) and armor.tile_cuts_web(7, 4) and armor.tile_cracks_glass(7, 4) and armor.tile_strips_scale(7, 4) and not armor.tile_cracks_mail(7, 4) and sealed.hidden, "rasp, chime, shear, wick, briar, flare, and hearth leave a mail moth sealed")
	guard = 0
	var sealed_hit := false
	while guard < 20 and armor.outcome == Sim.OUTCOME_RUNNING:
		armor.step(idle)
		guard += 1
		for event in armor.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				sealed_hit = true
	var sealed_now = armor.pest_by_id(sealed_id)
	_expect(not sealed_hit and sealed_now != null and int(sealed_now.hp) == Sim.PEST_HP, "an armor moth ignores shots until the maul cracks it")
	var armor_maul = Sim.Command.new()
	armor_maul.plant_kind = Catalog.MAUL
	armor_maul.tile = Vector2i(9, 6)
	armor.step(armor_maul)
	var opened = armor.pest_by_id(sealed_id)
	_expect(opened != null and not opened.hidden, "wick, briar, flare, hearth, shear, chime, rasp, and maul together reveal an armor moth")
	var opened_hit := false
	guard = 0
	while guard < 80 and armor.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		armor.step(idle)
		guard += 1
		for event in armor.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				opened_hit = true
	_expect(opened_hit, "the opened armor moth takes a hit")


func _test_eighteenth_nights() -> void:
	print("nights 18 and 19")
	_expect(int(Sim.WAVES[17]["count"]) == 10 and int(Sim.WAVES[17]["interval"]) == 72 and int(Sim.WAVES[17]["shroud_every"]) == 0 and int(Sim.WAVES[17]["rind_every"]) == 0 and int(Sim.WAVES[17]["pitch_every"]) == 0 and int(Sim.WAVES[17]["frost_every"]) == 0 and int(Sim.WAVES[17]["web_every"]) == 0 and int(Sim.WAVES[17]["glass_every"]) == 0 and int(Sim.WAVES[17]["scale_every"]) == 0 and int(Sim.WAVES[17]["mail_every"]) == 1 and str(Sim.WAVES[17]["name"]) == "Mail", "night 18 is all mail")
	_expect(int(Sim.WAVES[18]["count"]) == 16 and int(Sim.WAVES[18]["interval"]) == 60 and int(Sim.WAVES[18]["shroud_every"]) == 2 and int(Sim.WAVES[18]["rind_every"]) == 1 and int(Sim.WAVES[18]["pitch_every"]) == 1 and int(Sim.WAVES[18]["frost_every"]) == 1 and int(Sim.WAVES[18]["web_every"]) == 1 and int(Sim.WAVES[18]["glass_every"]) == 1 and int(Sim.WAVES[18]["scale_every"]) == 1 and int(Sim.WAVES[18]["mail_every"]) == 1 and str(Sim.WAVES[18]["name"]) == "Armor", "night 19 is mail, scale, glass, web, frost, pitch, and rind, every second also a shroud")
	for i in 17:
		_expect(int(Sim.WAVES[i]["mail_every"]) == 0, "night %d still spawns no mail" % (i + 1))
	var named = Sim.new(1)
	named.wave = 18
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 18 of 47 (Mail) — 0 pests left", "night 18 heading: %s" % named.phase_text())
	named.wave = 19
	_expect(named.phase_text() == "Night 19 of 47 (Armor) — 0 pests left", "night 19 heading: %s" % named.phase_text())
	named.wave = 17
	named.phase = Sim.PHASE_PLANT
	named.phase_ticks = 0
	_expect(named.phase_text().begins_with("Planting — night 18 (Mail)"), "planting before mail: %s" % named.phase_text())

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var ignored := _play(run_seed, Callable(self, "_rasp_command"))
		print("  no maul seed=%s outcome=%s night=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s/%s glasses=%s/%s scales=%s/%s mails=%s/%s" % [run_seed, ignored[0], ignored[1], ignored[4], ignored[3], ignored[7], ignored[6], ignored[11], ignored[10], ignored[13], ignored[12], ignored[15], ignored[14], ignored[17], ignored[16], ignored[19], ignored[18], ignored[21], ignored[20], ignored[23], ignored[22]])
		_expect(int(ignored[0]) == Sim.OUTCOME_LOST, "seed %s dies when the maul rule is ignored" % run_seed)
		_expect(int(ignored[1]) == 18, "seed %s dies on the mail night (night %s)" % [run_seed, ignored[1]])
		_expect(int(ignored[4]) == 0, "seed %s health reached zero on the mail night" % run_seed)
		_expect(int(ignored[6]) == 64 and int(ignored[7]) == 64, "seed %s had already burned the shroud nights (%s/%s)" % [run_seed, ignored[7], ignored[6]])
		_expect(int(ignored[10]) == 106 and int(ignored[11]) == 106, "seed %s had already cracked the rind nights (%s/%s)" % [run_seed, ignored[11], ignored[10]])
		_expect(int(ignored[12]) == 90 and int(ignored[13]) == 90, "seed %s had already melted the pitch nights (%s/%s)" % [run_seed, ignored[13], ignored[12]])
		_expect(int(ignored[14]) == 74 and int(ignored[15]) == 74, "seed %s had already thawed the frost nights (%s/%s)" % [run_seed, ignored[15], ignored[14]])
		_expect(int(ignored[16]) == 58 and int(ignored[17]) == 58, "seed %s had already cut the web nights (%s/%s)" % [run_seed, ignored[17], ignored[16]])
		_expect(int(ignored[18]) == 42 and int(ignored[19]) == 42, "seed %s had already cracked the glass nights (%s/%s)" % [run_seed, ignored[19], ignored[18]])
		_expect(int(ignored[20]) == 26 and int(ignored[21]) == 26, "seed %s had already stripped the scale nights (%s/%s)" % [run_seed, ignored[21], ignored[20]])
		_expect(int(ignored[22]) > 0 and int(ignored[23]) == 0, "seed %s left every mail moth uncracked (%s spawned, %s killed)" % [run_seed, ignored[22], ignored[23]])
		_expect(int(ignored[8]) == Sim.START_SEEDS - 9 and int(ignored[9]) == 9, "seed %s never planted a maul" % run_seed)
		var missed := _play(run_seed, Callable(self, "_corner_maul_command"))
		print("  corner maul seed=%s outcome=%s night=%s hp=%s tick=%s mails=%s/%s" % [run_seed, missed[0], missed[1], missed[4], missed[3], missed[23], missed[22]])
		_expect(int(missed[0]) == Sim.OUTCOME_LOST, "seed %s dies when maul light misses the gardener" % run_seed)
		_expect(int(missed[1]) == 18, "seed %s dies on night 18 with a corner maul (night %s)" % [run_seed, missed[1]])
		_expect(int(missed[4]) == 0, "seed %s health reached zero" % run_seed)
		_expect(int(missed[8]) == Sim.START_SEEDS - 10 and int(missed[9]) == 10, "seed %s planted the maul, just not where the night arrives" % run_seed)
		_expect(int(missed[22]) > int(missed[23]), "seed %s left mail moths uncracked (%s spawned, %s killed)" % [run_seed, missed[22], missed[23]])
		var held := _play(run_seed, Callable(self, "_maul_command"), 19)
		print("  maul through night 19 seed=%s outcome=%s night=%s phase=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s/%s glasses=%s/%s scales=%s/%s mails=%s/%s hides=%s" % [run_seed, held[0], held[1], held[2], held[4], held[3], held[7], held[6], held[11], held[10], held[13], held[12], held[15], held[14], held[17], held[16], held[19], held[18], held[21], held[20], held[23], held[22], held[24]])
		_expect(int(held[0]) == Sim.OUTCOME_RUNNING and int(held[1]) == 19 and int(held[2]) == Sim.PHASE_PLANT, "seed %s still clears night 19 with the maul at (9, 6)" % run_seed)
		_expect(int(held[4]) == 100, "seed %s finished night 19 at full health (%s)" % [run_seed, held[4]])
		_expect(int(held[6]) == 72 and int(held[7]) == 72, "seed %s burned every shroud moth (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 122 and int(held[11]) == 122, "seed %s cracked every rind moth (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 106 and int(held[13]) == 106, "seed %s melted every pitch moth (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 90 and int(held[15]) == 90, "seed %s thawed every frost moth (%s/%s)" % [run_seed, held[15], held[14]])
		_expect(int(held[16]) == 74 and int(held[17]) == 74, "seed %s cut every web moth (%s/%s)" % [run_seed, held[17], held[16]])
		_expect(int(held[18]) == 58 and int(held[19]) == 58, "seed %s cracked every glass moth (%s/%s)" % [run_seed, held[19], held[18]])
		_expect(int(held[20]) == 42 and int(held[21]) == 42, "seed %s stripped every scale moth (%s/%s)" % [run_seed, held[21], held[20]])
		_expect(int(held[22]) == 26 and int(held[23]) == 26, "seed %s cracked every mail moth (%s/%s)" % [run_seed, held[23], held[22]])
		_expect(int(held[24]) == 0 and int(held[25]) == 0, "seed %s meets no hide moth before night 20" % run_seed)
		_expect(int(held[8]) == Sim.START_SEEDS - 10 and int(held[9]) == 10, "seed %s spent lantern, pea, wick, briar, flare, hearth, shear, chime, rasp, and maul" % run_seed)
	var again := _play(42, Callable(self, "_maul_command"), 19)
	var replay := _play(42, Callable(self, "_maul_command"), 19)
	_expect(str(again) == str(replay), "same seed and maul plan replay through night 19")


func _test_hide_rule() -> void:
	print("bill hide rule")
	var placed = Sim.new(4)
	var lantern = Sim.Command.new()
	lantern.plant_kind = Catalog.LANTERN
	lantern.tile = Vector2i(7, 5)
	placed.step(lantern)
	var wick = Sim.Command.new()
	wick.plant_kind = Catalog.WICK
	wick.tile = Vector2i(6, 5)
	placed.step(wick)
	var briar = Sim.Command.new()
	briar.plant_kind = Catalog.BRIAR
	briar.tile = Vector2i(6, 4)
	placed.step(briar)
	var flare = Sim.Command.new()
	flare.plant_kind = Catalog.FLARE
	flare.tile = Vector2i(7, 4)
	placed.step(flare)
	var hearth = Sim.Command.new()
	hearth.plant_kind = Catalog.HEARTH
	hearth.tile = Vector2i(5, 5)
	placed.step(hearth)
	var shear = Sim.Command.new()
	shear.plant_kind = Catalog.SHEAR
	shear.tile = Vector2i(7, 6)
	placed.step(shear)
	var chime = Sim.Command.new()
	chime.plant_kind = Catalog.CHIME
	chime.tile = Vector2i(8, 6)
	placed.step(chime)
	var rasp = Sim.Command.new()
	rasp.plant_kind = Catalog.RASP
	rasp.tile = Vector2i(9, 5)
	placed.step(rasp)
	var maul = Sim.Command.new()
	maul.plant_kind = Catalog.MAUL
	maul.tile = Vector2i(9, 6)
	placed.step(maul)
	var idle = Sim.Command.new()
	placed.step(idle)
	_expect(placed.tile_burns_shroud(7, 5) and placed.tile_cracks_rind(7, 5) and placed.tile_melts_pitch(7, 5) and placed.tile_thaws_frost(7, 5) and placed.tile_cuts_web(7, 5) and placed.tile_cracks_glass(7, 5) and placed.tile_strips_scale(7, 5) and placed.tile_cracks_mail(7, 5), "maul, rasp, chime, shear, wick, briar, flare, and hearth already cover the gardener")
	_expect(not placed.tile_splits_hide(7, 5), "maul, rasp, chime, shear, wick, briar, flare, and hearth light does not split hide")
	var corner = Sim.Command.new()
	corner.plant_kind = Catalog.BILL
	corner.tile = Vector2i(1, 1)
	placed.step(corner)
	_expect(not placed.tile_splits_hide(7, 5), "a corner bill does not split the gardener tile")
	var beside = Sim.Command.new()
	beside.plant_kind = Catalog.BILL
	beside.tile = Vector2i(8, 4)
	placed.step(beside)
	_expect(placed.tile_splits_hide(8, 4), "a bill on its own tile splits it")
	_expect(placed.tile_splits_hide(7, 5), "that bill also splits the gardener tile")
	var bill_plant = placed.plant_of_kind(Catalog.BILL)
	_expect(bill_plant != null and bill_plant.splits_hide and not bill_plant.burns_shroud and not bill_plant.cracks_rind and not bill_plant.melts_pitch and not bill_plant.thaws_frost and not bill_plant.cuts_web and not bill_plant.cracks_glass and not bill_plant.strips_scale and not bill_plant.cracks_mail, "the bill splits hide and does not burn, crack rind, melt, thaw, cut web, crack glass, strip scale, or crack mail")
	_expect(not placed.plant_of_kind(Catalog.WICK).splits_hide, "the wick does not split hide")
	_expect(not placed.plant_of_kind(Catalog.BRIAR).splits_hide, "the briar does not split hide")
	_expect(not placed.plant_of_kind(Catalog.FLARE).splits_hide, "the flare does not split hide")
	_expect(not placed.plant_of_kind(Catalog.HEARTH).splits_hide, "the hearth does not split hide")
	_expect(not placed.plant_of_kind(Catalog.SHEAR).splits_hide, "the shear does not split hide")
	_expect(not placed.plant_of_kind(Catalog.CHIME).splits_hide, "the chime does not split hide")
	_expect(not placed.plant_of_kind(Catalog.RASP).splits_hide, "the rasp does not split hide")
	_expect(not placed.plant_of_kind(Catalog.MAUL).splits_hide, "the maul does not split hide")

	var sim = Sim.new(6)
	var sow_lantern = Sim.Command.new()
	sow_lantern.plant_kind = Catalog.LANTERN
	sow_lantern.tile = Vector2i(7, 5)
	sim.step(sow_lantern)
	var sow_pea = Sim.Command.new()
	sow_pea.plant_kind = Catalog.PEA
	sow_pea.tile = Vector2i(8, 5)
	sim.step(sow_pea)
	var sow_wick = Sim.Command.new()
	sow_wick.plant_kind = Catalog.WICK
	sow_wick.tile = Vector2i(6, 5)
	sim.step(sow_wick)
	var sow_briar = Sim.Command.new()
	sow_briar.plant_kind = Catalog.BRIAR
	sow_briar.tile = Vector2i(6, 4)
	sim.step(sow_briar)
	var sow_flare = Sim.Command.new()
	sow_flare.plant_kind = Catalog.FLARE
	sow_flare.tile = Vector2i(7, 4)
	sim.step(sow_flare)
	var sow_hearth = Sim.Command.new()
	sow_hearth.plant_kind = Catalog.HEARTH
	sow_hearth.tile = Vector2i(5, 5)
	sim.step(sow_hearth)
	var sow_shear = Sim.Command.new()
	sow_shear.plant_kind = Catalog.SHEAR
	sow_shear.tile = Vector2i(7, 6)
	sim.step(sow_shear)
	var sow_chime = Sim.Command.new()
	sow_chime.plant_kind = Catalog.CHIME
	sow_chime.tile = Vector2i(8, 6)
	sim.step(sow_chime)
	var sow_rasp = Sim.Command.new()
	sow_rasp.plant_kind = Catalog.RASP
	sow_rasp.tile = Vector2i(9, 5)
	sim.step(sow_rasp)
	var sow_maul = Sim.Command.new()
	sow_maul.plant_kind = Catalog.MAUL
	sow_maul.tile = Vector2i(9, 6)
	sim.step(sow_maul)
	var hide = sim.spawn_pest(sim.tile_center(7, 4), false, false, false, false, false, false, false, false, true)
	var normal = sim.spawn_pest(sim.tile_center(8, 8), false, false, false, false, false, false, false, false, false)
	var shroud = sim.spawn_pest(sim.tile_center(8, 2), true, false, false, false, false, false, false, false, false)
	var mail = sim.spawn_pest(sim.tile_center(8, 7), false, false, false, false, false, false, false, true, false)
	var hide_id := int(hide.id)
	var normal_id := int(normal.id)
	var shroud_id := int(shroud.id)
	var mail_id := int(mail.id)
	_expect(sim.tile_lit(7, 4) and sim.tile_burns_shroud(7, 4) and sim.tile_cracks_rind(7, 4) and sim.tile_melts_pitch(7, 4) and sim.tile_thaws_frost(7, 4) and sim.tile_cuts_web(7, 4) and sim.tile_cracks_glass(7, 4) and sim.tile_strips_scale(7, 4) and sim.tile_cracks_mail(7, 4) and not sim.tile_splits_hide(7, 4) and hide.hidden, "maul, rasp, chime, shear, wick, briar, flare, and hearth light leaves the hide hidden")
	_expect(not mail.hidden, "maul light still reveals a mail")
	var normal_hit := false
	var hide_hit := false
	var shroud_hit := false
	var mail_hit := false
	var guard := 0
	while guard < 50 and sim.outcome == Sim.OUTCOME_RUNNING:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == normal_id:
				normal_hit = true
			if int(event["pest_id"]) == hide_id:
				hide_hit = true
			if int(event["pest_id"]) == shroud_id:
				shroud_hit = true
			if int(event["pest_id"]) == mail_id:
				mail_hit = true
	var hide_now = sim.pest_by_id(hide_id)
	_expect(normal_hit, "pea still damages an ordinary moth")
	_expect(not hide_hit and hide_now != null and int(hide_now.hp) == Sim.PEST_HP, "pea does not damage a hide outside bill light")
	_expect(not shroud_hit, "wick rule still blocks a shroud outside wick light")
	_expect(mail_hit, "maul light still lets a mail take damage")
	var sow_bill = Sim.Command.new()
	sow_bill.plant_kind = Catalog.BILL
	sow_bill.tile = Vector2i(8, 4)
	sim.step(sow_bill)
	var revealed = sim.pest_by_id(hide_id)
	_expect(revealed != null and not revealed.hidden, "bill light beside the hide reveals it")
	var parked = sim.spawn_pest(sim.tile_center(4, 1), true, false, false, false, false, false, false, false, false)
	_expect(sim.tile_splits_hide(4, 1) and not sim.tile_strips_scale(4, 1) and not sim.tile_burns_shroud(4, 1), "the bill covers that shroud tile without stripping or burning it")
	_expect(parked != null and parked.hidden, "bill light does not reveal a shroud")
	var split := false
	guard = 0
	while guard < 80 and sim.outcome == Sim.OUTCOME_RUNNING and not split:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == hide_id:
				split = true
	_expect(split, "the revealed hide takes a hit (hp=%s outcome=%s)" % [sim.player_hp, sim.outcome])

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	splash.step(sow_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, false)
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the hide")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a hide outside bill light")

	var coat = Sim.new(9)
	var coat_lamp = Sim.Command.new()
	coat_lamp.plant_kind = Catalog.LANTERN
	coat_lamp.tile = Vector2i(7, 5)
	coat.step(coat_lamp)
	var coat_wick = Sim.Command.new()
	coat_wick.plant_kind = Catalog.WICK
	coat_wick.tile = Vector2i(6, 5)
	coat.step(coat_wick)
	var coat_briar = Sim.Command.new()
	coat_briar.plant_kind = Catalog.BRIAR
	coat_briar.tile = Vector2i(6, 4)
	coat.step(coat_briar)
	var coat_flare = Sim.Command.new()
	coat_flare.plant_kind = Catalog.FLARE
	coat_flare.tile = Vector2i(7, 4)
	coat.step(coat_flare)
	var coat_pea = Sim.Command.new()
	coat_pea.plant_kind = Catalog.PEA
	coat_pea.tile = Vector2i(8, 5)
	coat.step(coat_pea)
	var coat_hearth = Sim.Command.new()
	coat_hearth.plant_kind = Catalog.HEARTH
	coat_hearth.tile = Vector2i(5, 5)
	coat.step(coat_hearth)
	var coat_shear = Sim.Command.new()
	coat_shear.plant_kind = Catalog.SHEAR
	coat_shear.tile = Vector2i(7, 6)
	coat.step(coat_shear)
	var coat_chime = Sim.Command.new()
	coat_chime.plant_kind = Catalog.CHIME
	coat_chime.tile = Vector2i(8, 6)
	coat.step(coat_chime)
	var coat_rasp = Sim.Command.new()
	coat_rasp.plant_kind = Catalog.RASP
	coat_rasp.tile = Vector2i(9, 5)
	coat.step(coat_rasp)
	var coat_maul = Sim.Command.new()
	coat_maul.plant_kind = Catalog.MAUL
	coat_maul.tile = Vector2i(9, 6)
	coat.step(coat_maul)
	var sealed = coat.spawn_pest(coat.tile_center(7, 4), true, true, true, true, true, true, true, true, true)
	var sealed_id := int(sealed.id)
	_expect(coat.tile_burns_shroud(7, 4) and coat.tile_cracks_rind(7, 4) and coat.tile_melts_pitch(7, 4) and coat.tile_thaws_frost(7, 4) and coat.tile_cuts_web(7, 4) and coat.tile_cracks_glass(7, 4) and coat.tile_strips_scale(7, 4) and coat.tile_cracks_mail(7, 4) and not coat.tile_splits_hide(7, 4) and sealed.hidden, "maul, rasp, chime, shear, wick, briar, flare, and hearth leave a hide moth sealed")
	guard = 0
	var sealed_hit := false
	while guard < 20 and coat.outcome == Sim.OUTCOME_RUNNING:
		coat.step(idle)
		guard += 1
		for event in coat.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				sealed_hit = true
	var sealed_now = coat.pest_by_id(sealed_id)
	_expect(not sealed_hit and sealed_now != null and int(sealed_now.hp) == Sim.PEST_HP, "a coat moth ignores shots until the bill splits it")
	var coat_bill = Sim.Command.new()
	coat_bill.plant_kind = Catalog.BILL
	coat_bill.tile = Vector2i(8, 4)
	coat.step(coat_bill)
	var opened = coat.pest_by_id(sealed_id)
	_expect(opened != null and not opened.hidden, "wick, briar, flare, hearth, shear, chime, rasp, maul, and bill together reveal a coat moth")
	var opened_hit := false
	guard = 0
	while guard < 80 and coat.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		coat.step(idle)
		guard += 1
		for event in coat.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				opened_hit = true
	_expect(opened_hit, "the opened coat moth takes a hit")


func _test_twentieth_nights() -> void:
	print("nights 20 and 21")
	_expect(int(Sim.WAVES[19]["count"]) == 10 and int(Sim.WAVES[19]["interval"]) == 72 and int(Sim.WAVES[19]["shroud_every"]) == 0 and int(Sim.WAVES[19]["rind_every"]) == 0 and int(Sim.WAVES[19]["pitch_every"]) == 0 and int(Sim.WAVES[19]["frost_every"]) == 0 and int(Sim.WAVES[19]["web_every"]) == 0 and int(Sim.WAVES[19]["glass_every"]) == 0 and int(Sim.WAVES[19]["scale_every"]) == 0 and int(Sim.WAVES[19]["mail_every"]) == 0 and int(Sim.WAVES[19]["hide_every"]) == 1 and str(Sim.WAVES[19]["name"]) == "Hide", "night 20 is all hide")
	_expect(int(Sim.WAVES[20]["count"]) == 16 and int(Sim.WAVES[20]["interval"]) == 60 and int(Sim.WAVES[20]["shroud_every"]) == 2 and int(Sim.WAVES[20]["rind_every"]) == 1 and int(Sim.WAVES[20]["pitch_every"]) == 1 and int(Sim.WAVES[20]["frost_every"]) == 1 and int(Sim.WAVES[20]["web_every"]) == 1 and int(Sim.WAVES[20]["glass_every"]) == 1 and int(Sim.WAVES[20]["scale_every"]) == 1 and int(Sim.WAVES[20]["mail_every"]) == 1 and int(Sim.WAVES[20]["hide_every"]) == 1 and str(Sim.WAVES[20]["name"]) == "Coat", "night 21 is hide, mail, scale, glass, web, frost, pitch, and rind, every second also a shroud")
	for i in 19:
		_expect(int(Sim.WAVES[i]["hide_every"]) == 0, "night %d still spawns no hide" % (i + 1))
	var named = Sim.new(1)
	named.wave = 20
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 20 of 47 (Hide) — 0 pests left", "night 20 heading: %s" % named.phase_text())
	named.wave = 21
	_expect(named.phase_text() == "Night 21 of 47 (Coat) — 0 pests left", "night 21 heading: %s" % named.phase_text())
	named.wave = 19
	named.phase = Sim.PHASE_PLANT
	named.phase_ticks = 0
	_expect(named.phase_text().begins_with("Planting — night 20 (Hide)"), "planting before hide: %s" % named.phase_text())

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var ignored := _play(run_seed, Callable(self, "_maul_command"))
		print("  no bill seed=%s outcome=%s night=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s/%s glasses=%s/%s scales=%s/%s mails=%s/%s hides=%s/%s" % [run_seed, ignored[0], ignored[1], ignored[4], ignored[3], ignored[7], ignored[6], ignored[11], ignored[10], ignored[13], ignored[12], ignored[15], ignored[14], ignored[17], ignored[16], ignored[19], ignored[18], ignored[21], ignored[20], ignored[23], ignored[22], ignored[25], ignored[24]])
		_expect(int(ignored[0]) == Sim.OUTCOME_LOST, "seed %s dies when the bill rule is ignored" % run_seed)
		_expect(int(ignored[1]) == 20, "seed %s dies on the hide night (night %s)" % [run_seed, ignored[1]])
		_expect(int(ignored[4]) == 0, "seed %s health reached zero on the hide night" % run_seed)
		_expect(int(ignored[6]) == 72 and int(ignored[7]) == 72, "seed %s had already burned the shroud nights (%s/%s)" % [run_seed, ignored[7], ignored[6]])
		_expect(int(ignored[10]) == 122 and int(ignored[11]) == 122, "seed %s had already cracked the rind nights (%s/%s)" % [run_seed, ignored[11], ignored[10]])
		_expect(int(ignored[12]) == 106 and int(ignored[13]) == 106, "seed %s had already melted the pitch nights (%s/%s)" % [run_seed, ignored[13], ignored[12]])
		_expect(int(ignored[14]) == 90 and int(ignored[15]) == 90, "seed %s had already thawed the frost nights (%s/%s)" % [run_seed, ignored[15], ignored[14]])
		_expect(int(ignored[16]) == 74 and int(ignored[17]) == 74, "seed %s had already cut the web nights (%s/%s)" % [run_seed, ignored[17], ignored[16]])
		_expect(int(ignored[18]) == 58 and int(ignored[19]) == 58, "seed %s had already cracked the glass nights (%s/%s)" % [run_seed, ignored[19], ignored[18]])
		_expect(int(ignored[20]) == 42 and int(ignored[21]) == 42, "seed %s had already stripped the scale nights (%s/%s)" % [run_seed, ignored[21], ignored[20]])
		_expect(int(ignored[22]) == 26 and int(ignored[23]) == 26, "seed %s had already cracked the mail nights (%s/%s)" % [run_seed, ignored[23], ignored[22]])
		_expect(int(ignored[24]) > 0 and int(ignored[25]) == 0, "seed %s left every hide moth unsplit (%s spawned, %s killed)" % [run_seed, ignored[24], ignored[25]])
		_expect(int(ignored[8]) == Sim.START_SEEDS - 10 and int(ignored[9]) == 10, "seed %s never planted a bill" % run_seed)
		var missed := _play(run_seed, Callable(self, "_corner_bill_command"))
		print("  corner bill seed=%s outcome=%s night=%s hp=%s tick=%s hides=%s/%s" % [run_seed, missed[0], missed[1], missed[4], missed[3], missed[25], missed[24]])
		_expect(int(missed[0]) == Sim.OUTCOME_LOST, "seed %s dies when bill light misses the gardener" % run_seed)
		_expect(int(missed[1]) == 20, "seed %s dies on night 20 with a corner bill (night %s)" % [run_seed, missed[1]])
		_expect(int(missed[4]) == 0, "seed %s health reached zero" % run_seed)
		_expect(int(missed[8]) == Sim.START_SEEDS - 11 and int(missed[9]) == 11, "seed %s planted the bill, just not where the night arrives" % run_seed)
		_expect(int(missed[24]) > int(missed[25]), "seed %s left hide moths unsplit (%s spawned, %s killed)" % [run_seed, missed[24], missed[25]])
		var held := _play(run_seed, Callable(self, "_bill_command"), 21)
		print("  bill seed=%s outcome=%s night=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s/%s glasses=%s/%s scales=%s/%s mails=%s/%s hides=%s/%s" % [run_seed, held[0], held[1], held[4], held[3], held[7], held[6], held[11], held[10], held[13], held[12], held[15], held[14], held[17], held[16], held[19], held[18], held[21], held[20], held[23], held[22], held[25], held[24]])
		_expect(int(held[0]) == Sim.OUTCOME_RUNNING and int(held[2]) == Sim.PHASE_PLANT, "seed %s is still planting after night 21" % run_seed)
		_expect(int(held[1]) == 21, "seed %s cleared through night 21" % run_seed)
		_expect(int(held[4]) == 100, "seed %s finished night 21 at full health (%s)" % [run_seed, held[4]])
		_expect(int(held[6]) == 80 and int(held[7]) == 80, "seed %s burned every shroud moth (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 138 and int(held[11]) == 138, "seed %s cracked every rind moth (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 122 and int(held[13]) == 122, "seed %s melted every pitch moth (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 106 and int(held[15]) == 106, "seed %s thawed every frost moth (%s/%s)" % [run_seed, held[15], held[14]])
		_expect(int(held[16]) == 90 and int(held[17]) == 90, "seed %s cut every web moth (%s/%s)" % [run_seed, held[17], held[16]])
		_expect(int(held[18]) == 74 and int(held[19]) == 74, "seed %s cracked every glass moth (%s/%s)" % [run_seed, held[19], held[18]])
		_expect(int(held[20]) == 58 and int(held[21]) == 58, "seed %s stripped every scale moth (%s/%s)" % [run_seed, held[21], held[20]])
		_expect(int(held[22]) == 42 and int(held[23]) == 42, "seed %s cracked every mail moth (%s/%s)" % [run_seed, held[23], held[22]])
		_expect(int(held[24]) == 26 and int(held[25]) == 26, "seed %s split every hide moth (%s/%s)" % [run_seed, held[25], held[24]])
		_expect(int(held[26]) == 0 and int(held[27]) == 0, "seed %s meets no dusk moth before night 22" % run_seed)
		_expect(int(held[8]) == Sim.START_SEEDS - 11 and int(held[9]) == 11, "seed %s spent lantern, pea, wick, briar, flare, hearth, shear, chime, rasp, maul, and bill" % run_seed)
		var fell := _play(run_seed, Callable(self, "_bill_command"))
		print("  bill into dusk seed=%s outcome=%s night=%s hp=%s dusk=%s/%s" % [run_seed, fell[0], fell[1], fell[4], fell[27], fell[26]])
		_expect(int(fell[0]) == Sim.OUTCOME_LOST, "seed %s dies when no shade is planted" % run_seed)
		_expect(int(fell[1]) == 22, "seed %s dies on the dusk night (night %s)" % [run_seed, fell[1]])
		_expect(int(fell[4]) == 0, "seed %s health reached zero on the dusk night" % run_seed)
		_expect(int(fell[26]) > 0 and int(fell[27]) == 0, "seed %s left every dusk moth unshaded (%s spawned, %s killed)" % [run_seed, fell[26], fell[27]])
		_expect(int(fell[6]) == 80 and int(fell[7]) == 80, "seed %s had already burned the shroud nights before dusk (%s/%s)" % [run_seed, fell[7], fell[6]])
		_expect(int(fell[24]) == 26 and int(fell[25]) == 26, "seed %s had already split the hide nights before dusk (%s/%s)" % [run_seed, fell[25], fell[24]])
	var again := _play(42, Callable(self, "_bill_command"))
	var replay := _play(42, Callable(self, "_bill_command"))
	_expect(str(again) == str(replay), "same seed and bill plan replay")


func _test_dusk_rule() -> void:
	print("shade dusk rule")
	var placed = Sim.new(4)
	placed.seeds = 14
	var lantern = Sim.Command.new()
	lantern.plant_kind = Catalog.LANTERN
	lantern.tile = Vector2i(7, 5)
	placed.step(lantern)
	var wick = Sim.Command.new()
	wick.plant_kind = Catalog.WICK
	wick.tile = Vector2i(6, 5)
	placed.step(wick)
	var briar = Sim.Command.new()
	briar.plant_kind = Catalog.BRIAR
	briar.tile = Vector2i(6, 4)
	placed.step(briar)
	var flare = Sim.Command.new()
	flare.plant_kind = Catalog.FLARE
	flare.tile = Vector2i(7, 4)
	placed.step(flare)
	var hearth = Sim.Command.new()
	hearth.plant_kind = Catalog.HEARTH
	hearth.tile = Vector2i(5, 5)
	placed.step(hearth)
	var shear = Sim.Command.new()
	shear.plant_kind = Catalog.SHEAR
	shear.tile = Vector2i(7, 6)
	placed.step(shear)
	var chime = Sim.Command.new()
	chime.plant_kind = Catalog.CHIME
	chime.tile = Vector2i(8, 6)
	placed.step(chime)
	var rasp = Sim.Command.new()
	rasp.plant_kind = Catalog.RASP
	rasp.tile = Vector2i(9, 5)
	placed.step(rasp)
	var maul = Sim.Command.new()
	maul.plant_kind = Catalog.MAUL
	maul.tile = Vector2i(9, 6)
	placed.step(maul)
	var bill = Sim.Command.new()
	bill.plant_kind = Catalog.BILL
	bill.tile = Vector2i(8, 4)
	placed.step(bill)
	var idle = Sim.Command.new()
	placed.step(idle)
	_expect(placed.tile_lit(7, 5) and placed.tile_splits_hide(7, 5), "the night-21 garden still lights and splits the gardener")
	_expect(not placed.tile_shades_dusk(7, 5), "bill light does not shade dusk")
	var corner = Sim.Command.new()
	corner.plant_kind = Catalog.SHADE
	corner.tile = Vector2i(1, 1)
	placed.step(corner)
	_expect(not placed.tile_shades_dusk(7, 5), "a corner shade does not shade the gardener tile")
	_expect(placed.tile_shades_dusk(1, 1), "a shade on its own tile shades it")
	_expect(not placed.tile_lit(1, 1), "a shade does not light its own tile")
	var beside = Sim.Command.new()
	beside.plant_kind = Catalog.SHADE
	beside.tile = Vector2i(6, 6)
	placed.step(beside)
	_expect(placed.tile_shades_dusk(6, 6), "the winning shade shades its own tile")
	_expect(placed.tile_shades_dusk(7, 5) and placed.tile_shades_dusk(8, 4) and placed.tile_shades_dusk(8, 5), "that shade covers the gardener, the bill, and the pea")
	var shade_plant = placed.plant_of_kind(Catalog.SHADE)
	_expect(shade_plant != null and shade_plant.shades_dusk and not shade_plant.casts_light and not shade_plant.cowls_veil and not shade_plant.splits_hide and not shade_plant.burns_shroud and not shade_plant.cracks_rind and not shade_plant.melts_pitch and not shade_plant.thaws_frost and not shade_plant.cuts_web and not shade_plant.cracks_glass and not shade_plant.strips_scale and not shade_plant.cracks_mail, "the shade shades dusk and does not light, cowl, split, burn, crack rind, melt, thaw, cut web, crack glass, strip scale, or crack mail")
	_expect(not placed.plant_of_kind(Catalog.BILL).shades_dusk, "the bill does not shade dusk")
	_expect(not placed.plant_of_kind(Catalog.WICK).shades_dusk, "the wick does not shade dusk")
	_expect(not placed.plant_of_kind(Catalog.MAUL).shades_dusk, "the maul does not shade dusk")

	var sim = Sim.new(6)
	var sow_bill = Sim.Command.new()
	sow_bill.plant_kind = Catalog.BILL
	sow_bill.tile = Vector2i(8, 4)
	sim.step(sow_bill)
	var sow_pea = Sim.Command.new()
	sow_pea.plant_kind = Catalog.PEA
	sow_pea.tile = Vector2i(8, 5)
	sim.step(sow_pea)
	var dusk = sim.spawn_pest(sim.tile_center(8, 4), false, false, false, false, false, false, false, false, false, true)
	var normal = sim.spawn_pest(sim.tile_center(8, 5), false, false, false, false, false, false, false, false, false, false)
	var hide = sim.spawn_pest(sim.tile_center(7, 4), false, false, false, false, false, false, false, false, true, false)
	var dusk_id := int(dusk.id)
	var normal_id := int(normal.id)
	var hide_id := int(hide.id)
	_expect(sim.tile_splits_hide(8, 4) and not sim.tile_shades_dusk(8, 4) and dusk.hidden, "bill light leaves the dusk moth sealed")
	_expect(not hide.hidden, "bill light still reveals a hide")
	var normal_hit := false
	var dusk_hit := false
	var hide_hit := false
	var guard := 0
	while guard < 50 and sim.outcome == Sim.OUTCOME_RUNNING:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == normal_id:
				normal_hit = true
			if int(event["pest_id"]) == dusk_id:
				dusk_hit = true
			if int(event["pest_id"]) == hide_id:
				hide_hit = true
	var dusk_now = sim.pest_by_id(dusk_id)
	_expect(normal_hit, "pea still damages an ordinary moth beside a bill")
	_expect(hide_hit, "bill light still lets a hide take damage")
	_expect(not dusk_hit and dusk_now != null and int(dusk_now.hp) == Sim.PEST_HP, "a bill does not damage a dusk moth")

	var only = Sim.new(5)
	var sow_shade = Sim.Command.new()
	sow_shade.plant_kind = Catalog.SHADE
	sow_shade.tile = Vector2i(6, 6)
	only.step(sow_shade)
	var sealed_hide = only.spawn_pest(only.tile_center(6, 6), false, false, false, false, false, false, false, false, true, false)
	var opened_dusk = only.spawn_pest(only.tile_center(6, 6), false, false, false, false, false, false, false, false, false, true)
	var plain = only.spawn_pest(only.tile_center(6, 6), false, false, false, false, false, false, false, false, false, false)
	_expect(only.tile_shades_dusk(6, 6) and not only.tile_lit(6, 6) and not only.tile_splits_hide(6, 6), "shade marks the tile without lighting it or splitting hide")
	_expect(sealed_hide.hidden, "a shade does not reveal a hide")
	_expect(not opened_dusk.hidden, "a shade reveals a dusk moth on its tile")
	_expect(plain.hidden, "an ordinary moth stays hidden in shade with no light")
	var shade_hit := false
	var hide_hurt := false
	guard = 0
	while guard < 80 and only.outcome == Sim.OUTCOME_RUNNING and not shade_hit:
		only.step(idle)
		guard += 1
		for event in only.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == int(opened_dusk.id):
				shade_hit = true
			if int(event["pest_id"]) == int(sealed_hide.id):
				hide_hurt = true
	var hide_left = only.pest_by_id(int(sealed_hide.id))
	_expect(shade_hit, "the revealed dusk moth takes a hit")
	_expect(not hide_hurt and hide_left != null and int(hide_left.hp) == Sim.PEST_HP, "shots do not hurt a hide standing in shade")

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	splash.step(sow_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, false, false)
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the dusk moth")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a dusk moth outside shade")

	var dim = Sim.new(9)
	dim.seeds = 14
	var dim_lamp = Sim.Command.new()
	dim_lamp.plant_kind = Catalog.LANTERN
	dim_lamp.tile = Vector2i(7, 5)
	dim.step(dim_lamp)
	var dim_wick = Sim.Command.new()
	dim_wick.plant_kind = Catalog.WICK
	dim_wick.tile = Vector2i(6, 5)
	dim.step(dim_wick)
	var dim_briar = Sim.Command.new()
	dim_briar.plant_kind = Catalog.BRIAR
	dim_briar.tile = Vector2i(6, 4)
	dim.step(dim_briar)
	var dim_flare = Sim.Command.new()
	dim_flare.plant_kind = Catalog.FLARE
	dim_flare.tile = Vector2i(7, 4)
	dim.step(dim_flare)
	var dim_pea = Sim.Command.new()
	dim_pea.plant_kind = Catalog.PEA
	dim_pea.tile = Vector2i(8, 5)
	dim.step(dim_pea)
	var dim_hearth = Sim.Command.new()
	dim_hearth.plant_kind = Catalog.HEARTH
	dim_hearth.tile = Vector2i(5, 5)
	dim.step(dim_hearth)
	var dim_shear = Sim.Command.new()
	dim_shear.plant_kind = Catalog.SHEAR
	dim_shear.tile = Vector2i(7, 6)
	dim.step(dim_shear)
	var dim_chime = Sim.Command.new()
	dim_chime.plant_kind = Catalog.CHIME
	dim_chime.tile = Vector2i(8, 6)
	dim.step(dim_chime)
	var dim_rasp = Sim.Command.new()
	dim_rasp.plant_kind = Catalog.RASP
	dim_rasp.tile = Vector2i(9, 5)
	dim.step(dim_rasp)
	var dim_maul = Sim.Command.new()
	dim_maul.plant_kind = Catalog.MAUL
	dim_maul.tile = Vector2i(9, 6)
	dim.step(dim_maul)
	var dim_bill = Sim.Command.new()
	dim_bill.plant_kind = Catalog.BILL
	dim_bill.tile = Vector2i(8, 4)
	dim.step(dim_bill)
	var sealed = dim.spawn_pest(dim.tile_center(7, 4), true, true, true, true, true, true, true, true, true, true)
	var sealed_id := int(sealed.id)
	_expect(dim.tile_burns_shroud(7, 4) and dim.tile_cracks_rind(7, 4) and dim.tile_melts_pitch(7, 4) and dim.tile_thaws_frost(7, 4) and dim.tile_cuts_web(7, 4) and dim.tile_cracks_glass(7, 4) and dim.tile_strips_scale(7, 4) and dim.tile_cracks_mail(7, 4) and dim.tile_splits_hide(7, 4) and not dim.tile_shades_dusk(7, 4) and sealed.hidden, "every older lock leaves a dusk moth sealed")
	guard = 0
	var sealed_hit := false
	while guard < 20 and dim.outcome == Sim.OUTCOME_RUNNING:
		dim.step(idle)
		guard += 1
		for event in dim.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				sealed_hit = true
	var sealed_now = dim.pest_by_id(sealed_id)
	_expect(not sealed_hit and sealed_now != null and int(sealed_now.hp) == Sim.PEST_HP, "a dim moth ignores shots until the shade covers it")
	var dim_shade = Sim.Command.new()
	dim_shade.plant_kind = Catalog.SHADE
	dim_shade.tile = Vector2i(6, 6)
	dim.step(dim_shade)
	var opened = dim.pest_by_id(sealed_id)
	_expect(opened != null and not opened.hidden, "shade plus the older locks together reveal a dim moth")
	var outside = dim.spawn_pest(dim.tile_center(1, 1), false, false, false, false, false, false, false, false, false, true)
	_expect(outside.hidden, "a dusk moth outside the shade seals again")
	var opened_hit := false
	guard = 0
	while guard < 80 and dim.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		dim.step(idle)
		guard += 1
		for event in dim.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				opened_hit = true
	_expect(opened_hit, "the opened dim moth takes a hit")


func _test_twenty_second_nights() -> void:
	print("nights 22 and 23")
	_expect(Sim.START_SEEDS == 23, "the run starts with twenty-three seeds")
	_expect(int(Sim.WAVES[21]["count"]) == 10 and int(Sim.WAVES[21]["interval"]) == 72 and int(Sim.WAVES[21]["shroud_every"]) == 0 and int(Sim.WAVES[21]["rind_every"]) == 0 and int(Sim.WAVES[21]["pitch_every"]) == 0 and int(Sim.WAVES[21]["frost_every"]) == 0 and int(Sim.WAVES[21]["web_every"]) == 0 and int(Sim.WAVES[21]["glass_every"]) == 0 and int(Sim.WAVES[21]["scale_every"]) == 0 and int(Sim.WAVES[21]["mail_every"]) == 0 and int(Sim.WAVES[21]["hide_every"]) == 0 and int(Sim.WAVES[21]["dusk_every"]) == 1 and str(Sim.WAVES[21]["name"]) == "Dusk", "night 22 is all dusk")
	_expect(int(Sim.WAVES[22]["count"]) == 16 and int(Sim.WAVES[22]["interval"]) == 60 and int(Sim.WAVES[22]["shroud_every"]) == 2 and int(Sim.WAVES[22]["rind_every"]) == 1 and int(Sim.WAVES[22]["pitch_every"]) == 1 and int(Sim.WAVES[22]["frost_every"]) == 1 and int(Sim.WAVES[22]["web_every"]) == 1 and int(Sim.WAVES[22]["glass_every"]) == 1 and int(Sim.WAVES[22]["scale_every"]) == 1 and int(Sim.WAVES[22]["mail_every"]) == 1 and int(Sim.WAVES[22]["hide_every"]) == 1 and int(Sim.WAVES[22]["dusk_every"]) == 1 and str(Sim.WAVES[22]["name"]) == "Dim", "night 23 is dusk, hide, mail, scale, glass, web, frost, pitch, and rind, every second also a shroud")
	for i in 21:
		_expect(int(Sim.WAVES[i].get("dusk_every", 0)) == 0, "night %d still spawns no dusk" % (i + 1))
	var named = Sim.new(1)
	named.wave = 22
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 22 of 47 (Dusk) — 0 pests left", "night 22 heading: %s" % named.phase_text())
	named.wave = 23
	_expect(named.phase_text() == "Night 23 of 47 (Dim) — 0 pests left", "night 23 heading: %s" % named.phase_text())
	named.wave = 21
	named.phase = Sim.PHASE_PLANT
	named.phase_ticks = 0
	_expect(named.phase_text().begins_with("Planting — night 22 (Dusk)"), "planting before dusk: %s" % named.phase_text())

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var missed := _play(run_seed, Callable(self, "_corner_shade_command"))
		print("  corner shade seed=%s outcome=%s night=%s hp=%s tick=%s dusk=%s/%s" % [run_seed, missed[0], missed[1], missed[4], missed[3], missed[27], missed[26]])
		_expect(int(missed[0]) == Sim.OUTCOME_LOST, "seed %s dies when the shade misses the kill tiles" % run_seed)
		_expect(int(missed[1]) == 22, "seed %s dies on night 22 with a corner shade (night %s)" % [run_seed, missed[1]])
		_expect(int(missed[4]) == 0, "seed %s health reached zero" % run_seed)
		_expect(int(missed[8]) == Sim.START_SEEDS - 11 and int(missed[9]) == 11, "seed %s planted the shade, just not where the night arrives" % run_seed)
		_expect(int(missed[26]) > int(missed[27]), "seed %s left dusk moths unshaded (%s spawned, %s killed)" % [run_seed, missed[26], missed[27]])
		var held := _play(run_seed, Callable(self, "_shade_command"), 23)
		print("  shade seed=%s outcome=%s night=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s/%s glasses=%s/%s scales=%s/%s mails=%s/%s hides=%s/%s dusk=%s/%s veils=%s/%s" % [run_seed, held[0], held[1], held[4], held[3], held[7], held[6], held[11], held[10], held[13], held[12], held[15], held[14], held[17], held[16], held[19], held[18], held[21], held[20], held[23], held[22], held[25], held[24], held[27], held[26], held[29], held[28]])
		_expect(int(held[0]) == Sim.OUTCOME_RUNNING and int(held[2]) == Sim.PHASE_PLANT, "seed %s is still planting after night 23" % run_seed)
		_expect(int(held[1]) == 23, "seed %s cleared through night 23" % run_seed)
		_expect(int(held[4]) == 100, "seed %s finished night 23 at full health (%s)" % [run_seed, held[4]])
		_expect(int(held[6]) == 88 and int(held[7]) == 88, "seed %s burned every shroud moth (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 154 and int(held[11]) == 154, "seed %s cracked every rind moth (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 138 and int(held[13]) == 138, "seed %s melted every pitch moth (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 122 and int(held[15]) == 122, "seed %s thawed every frost moth (%s/%s)" % [run_seed, held[15], held[14]])
		_expect(int(held[16]) == 106 and int(held[17]) == 106, "seed %s cut every web moth (%s/%s)" % [run_seed, held[17], held[16]])
		_expect(int(held[18]) == 90 and int(held[19]) == 90, "seed %s cracked every glass moth (%s/%s)" % [run_seed, held[19], held[18]])
		_expect(int(held[20]) == 74 and int(held[21]) == 74, "seed %s stripped every scale moth (%s/%s)" % [run_seed, held[21], held[20]])
		_expect(int(held[22]) == 58 and int(held[23]) == 58, "seed %s cracked every mail moth (%s/%s)" % [run_seed, held[23], held[22]])
		_expect(int(held[24]) == 42 and int(held[25]) == 42, "seed %s split every hide moth (%s/%s)" % [run_seed, held[25], held[24]])
		_expect(int(held[26]) == 26 and int(held[27]) == 26, "seed %s shaded every dusk moth (%s/%s)" % [run_seed, held[27], held[26]])
		_expect(int(held[28]) == 0 and int(held[29]) == 0, "seed %s meets no veil moth before night 24" % run_seed)
		_expect(int(held[8]) == Sim.START_SEEDS - 11 and int(held[9]) == 11, "seed %s spent eleven seeds and left the twelfth unspent" % run_seed)
		_expect(not _shade_garden_plants_lantern(run_seed), "seed %s left the lantern unplanted so the shade fit" % run_seed)
		var fell := _play(run_seed, Callable(self, "_shade_command"))
		print("  shade into veil seed=%s outcome=%s night=%s hp=%s veil=%s/%s" % [run_seed, fell[0], fell[1], fell[4], fell[29], fell[28]])
		_expect(int(fell[0]) == Sim.OUTCOME_LOST, "seed %s dies when no cowl is planted" % run_seed)
		_expect(int(fell[1]) == 24, "seed %s dies on the veil night (night %s)" % [run_seed, fell[1]])
		_expect(int(fell[4]) == 0, "seed %s health reached zero on the veil night" % run_seed)
		_expect(int(fell[28]) > 0 and int(fell[29]) == 0, "seed %s left every veil moth uncowled (%s spawned, %s killed)" % [run_seed, fell[28], fell[29]])
		_expect(int(fell[26]) == 26 and int(fell[27]) == 26, "seed %s had already shaded the dusk nights before veil (%s/%s)" % [run_seed, fell[27], fell[26]])
		_expect(int(fell[8]) == Sim.START_SEEDS - 11 and int(fell[9]) == 11, "seed %s still has the twelfth seed unspent when the veil arrives" % run_seed)
	var again := _play(42, Callable(self, "_shade_command"))
	var replay := _play(42, Callable(self, "_shade_command"))
	_expect(str(again) == str(replay), "same seed and shade plan replay")


func _shade_garden_plants_lantern(seed_value: int) -> bool:
	var sim = Sim.new(seed_value)
	var guard := 0
	while sim.phase == Sim.PHASE_PLANT and sim.outcome == Sim.OUTCOME_RUNNING and guard < 400:
		sim.step(_shade_command(sim))
		guard += 1
	return sim.has_plant(Catalog.LANTERN)


func _test_veil_rule() -> void:
	print("cowl veil rule")
	var placed = Sim.new(4)
	placed.seeds = 16
	var wick = Sim.Command.new()
	wick.plant_kind = Catalog.WICK
	wick.tile = Vector2i(6, 5)
	placed.step(wick)
	var briar = Sim.Command.new()
	briar.plant_kind = Catalog.BRIAR
	briar.tile = Vector2i(6, 4)
	placed.step(briar)
	var flare = Sim.Command.new()
	flare.plant_kind = Catalog.FLARE
	flare.tile = Vector2i(7, 4)
	placed.step(flare)
	var hearth = Sim.Command.new()
	hearth.plant_kind = Catalog.HEARTH
	hearth.tile = Vector2i(5, 5)
	placed.step(hearth)
	var shear = Sim.Command.new()
	shear.plant_kind = Catalog.SHEAR
	shear.tile = Vector2i(7, 6)
	placed.step(shear)
	var chime = Sim.Command.new()
	chime.plant_kind = Catalog.CHIME
	chime.tile = Vector2i(8, 6)
	placed.step(chime)
	var rasp = Sim.Command.new()
	rasp.plant_kind = Catalog.RASP
	rasp.tile = Vector2i(9, 5)
	placed.step(rasp)
	var maul = Sim.Command.new()
	maul.plant_kind = Catalog.MAUL
	maul.tile = Vector2i(9, 6)
	placed.step(maul)
	var bill = Sim.Command.new()
	bill.plant_kind = Catalog.BILL
	bill.tile = Vector2i(8, 4)
	placed.step(bill)
	var shade = Sim.Command.new()
	shade.plant_kind = Catalog.SHADE
	shade.tile = Vector2i(6, 6)
	placed.step(shade)
	var idle = Sim.Command.new()
	placed.step(idle)
	_expect(placed.tile_shades_dusk(7, 5) and placed.tile_splits_hide(7, 5) and placed.tile_lit(7, 5), "the night-23 garden still shades, splits, and lights the gardener")
	_expect(not placed.tile_cowls_veil(7, 5) and not placed.tile_cowls_veil(6, 6), "a shade does not cowl the gardener or its own tile")
	var corner = Sim.Command.new()
	corner.plant_kind = Catalog.COWL
	corner.tile = Vector2i(1, 1)
	placed.step(corner)
	_expect(not placed.tile_cowls_veil(7, 5), "a corner cowl does not cowl the gardener tile")
	_expect(placed.tile_cowls_veil(1, 1), "a cowl on its own tile cowls it")
	_expect(not placed.tile_lit(1, 1), "a cowl does not light its own tile")
	_expect(not placed.tile_shades_dusk(1, 1) and not placed.tile_splits_hide(1, 1), "a cowl does not shade dusk or split hide")
	var beside = Sim.Command.new()
	beside.plant_kind = Catalog.COWL
	beside.tile = Vector2i(7, 5)
	placed.step(beside)
	_expect(placed.tile_cowls_veil(7, 5) and placed.tile_cowls_veil(6, 6) and placed.tile_cowls_veil(8, 4) and placed.tile_cowls_veil(8, 5), "the winning cowl covers the gardener, the shade, the bill, and the pea")
	_expect(placed.tile_cowls_veil(7, 4) and placed.tile_cowls_veil(6, 5) and placed.tile_cowls_veil(5, 5), "that cowl also covers the flare, the wick, and the hearth")
	var cowl_plant = placed.plant_of_kind(Catalog.COWL)
	_expect(cowl_plant != null and cowl_plant.cowls_veil and not cowl_plant.casts_light and not cowl_plant.shades_dusk and not cowl_plant.splits_hide and not cowl_plant.burns_shroud and not cowl_plant.cracks_rind and not cowl_plant.melts_pitch and not cowl_plant.thaws_frost and not cowl_plant.cuts_web and not cowl_plant.cracks_glass and not cowl_plant.strips_scale and not cowl_plant.cracks_mail, "the cowl cowls veil and does not light, shade, split, burn, crack rind, melt, thaw, cut web, crack glass, strip scale, or crack mail")
	_expect(not placed.plant_of_kind(Catalog.SHADE).cowls_veil, "the shade does not cowl veil")
	_expect(not placed.plant_of_kind(Catalog.BILL).cowls_veil, "the bill does not cowl veil")
	_expect(not placed.plant_of_kind(Catalog.WICK).cowls_veil, "the wick does not cowl veil")

	var sim = Sim.new(6)
	var sow_shade = Sim.Command.new()
	sow_shade.plant_kind = Catalog.SHADE
	sow_shade.tile = Vector2i(6, 6)
	sim.step(sow_shade)
	var sow_pea = Sim.Command.new()
	sow_pea.plant_kind = Catalog.PEA
	sow_pea.tile = Vector2i(8, 5)
	sim.step(sow_pea)
	var veil = sim.spawn_pest(sim.tile_center(6, 6), false, false, false, false, false, false, false, false, false, false, true)
	var dusk = sim.spawn_pest(sim.tile_center(6, 6), false, false, false, false, false, false, false, false, false, true, false)
	var hide = sim.spawn_pest(sim.tile_center(8, 4), false, false, false, false, false, false, false, false, true, false, false)
	var sow_bill = Sim.Command.new()
	sow_bill.plant_kind = Catalog.BILL
	sow_bill.tile = Vector2i(8, 4)
	sim.step(sow_bill)
	var veil_id := int(veil.id)
	var dusk_id := int(dusk.id)
	var hide_id := int(hide.id)
	_expect(sim.tile_shades_dusk(6, 6) and not sim.tile_cowls_veil(6, 6) and veil.hidden and not dusk.hidden, "shade opens dusk and leaves the veil moth sealed")
	_expect(not hide.hidden, "bill light still reveals a hide")
	var veil_hit := false
	var dusk_hit := false
	var hide_hit := false
	var guard := 0
	while guard < 80 and sim.outcome == Sim.OUTCOME_RUNNING:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == veil_id:
				veil_hit = true
			if int(event["pest_id"]) == dusk_id:
				dusk_hit = true
			if int(event["pest_id"]) == hide_id:
				hide_hit = true
	var veil_now = sim.pest_by_id(veil_id)
	_expect(dusk_hit, "a shade still lets a dusk moth take damage")
	_expect(hide_hit, "bill light still lets a hide take damage")
	_expect(not veil_hit and veil_now != null and int(veil_now.hp) == Sim.PEST_HP, "a shade does not damage a veil moth")

	var only = Sim.new(5)
	var sow_cowl = Sim.Command.new()
	sow_cowl.plant_kind = Catalog.COWL
	sow_cowl.tile = Vector2i(7, 5)
	only.step(sow_cowl)
	var sealed_dusk = only.spawn_pest(only.tile_center(7, 5), false, false, false, false, false, false, false, false, false, true, false)
	var sealed_hide = only.spawn_pest(only.tile_center(7, 5), false, false, false, false, false, false, false, false, true, false, false)
	var opened_veil = only.spawn_pest(only.tile_center(7, 5), false, false, false, false, false, false, false, false, false, false, true)
	var plain = only.spawn_pest(only.tile_center(7, 5), false, false, false, false, false, false, false, false, false, false, false)
	_expect(only.tile_cowls_veil(7, 5) and not only.tile_lit(7, 5) and not only.tile_shades_dusk(7, 5) and not only.tile_splits_hide(7, 5), "cowl marks the tile without lighting it, shading dusk, or splitting hide")
	_expect(sealed_dusk.hidden, "a cowl does not reveal a dusk moth")
	_expect(sealed_hide.hidden, "a cowl does not reveal a hide")
	_expect(not opened_veil.hidden, "a cowl reveals a veil moth on its tile")
	_expect(plain.hidden, "an ordinary moth stays hidden in a cowl with no light")
	var cowl_hit := false
	var dusk_hurt := false
	var hide_hurt := false
	guard = 0
	while guard < 80 and only.outcome == Sim.OUTCOME_RUNNING and not cowl_hit:
		only.step(idle)
		guard += 1
		for event in only.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == int(opened_veil.id):
				cowl_hit = true
			if int(event["pest_id"]) == int(sealed_dusk.id):
				dusk_hurt = true
			if int(event["pest_id"]) == int(sealed_hide.id):
				hide_hurt = true
	var dusk_left = only.pest_by_id(int(sealed_dusk.id))
	var hide_left = only.pest_by_id(int(sealed_hide.id))
	_expect(cowl_hit, "the revealed veil moth takes a hit")
	_expect(not dusk_hurt and dusk_left != null and int(dusk_left.hp) == Sim.PEST_HP, "shots do not hurt a dusk moth standing in a cowl")
	_expect(not hide_hurt and hide_left != null and int(hide_left.hp) == Sim.PEST_HP, "shots do not hurt a hide standing in a cowl")

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	splash.step(sow_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, false, false, false)
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, false, false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the veil moth")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a veil moth outside a cowl")

	var mask = Sim.new(9)
	mask.seeds = 16
	var mask_wick = Sim.Command.new()
	mask_wick.plant_kind = Catalog.WICK
	mask_wick.tile = Vector2i(6, 5)
	mask.step(mask_wick)
	var mask_briar = Sim.Command.new()
	mask_briar.plant_kind = Catalog.BRIAR
	mask_briar.tile = Vector2i(6, 4)
	mask.step(mask_briar)
	var mask_flare = Sim.Command.new()
	mask_flare.plant_kind = Catalog.FLARE
	mask_flare.tile = Vector2i(7, 4)
	mask.step(mask_flare)
	var mask_pea = Sim.Command.new()
	mask_pea.plant_kind = Catalog.PEA
	mask_pea.tile = Vector2i(8, 5)
	mask.step(mask_pea)
	var mask_hearth = Sim.Command.new()
	mask_hearth.plant_kind = Catalog.HEARTH
	mask_hearth.tile = Vector2i(5, 5)
	mask.step(mask_hearth)
	var mask_shear = Sim.Command.new()
	mask_shear.plant_kind = Catalog.SHEAR
	mask_shear.tile = Vector2i(7, 6)
	mask.step(mask_shear)
	var mask_chime = Sim.Command.new()
	mask_chime.plant_kind = Catalog.CHIME
	mask_chime.tile = Vector2i(8, 6)
	mask.step(mask_chime)
	var mask_rasp = Sim.Command.new()
	mask_rasp.plant_kind = Catalog.RASP
	mask_rasp.tile = Vector2i(9, 5)
	mask.step(mask_rasp)
	var mask_maul = Sim.Command.new()
	mask_maul.plant_kind = Catalog.MAUL
	mask_maul.tile = Vector2i(9, 6)
	mask.step(mask_maul)
	var mask_bill = Sim.Command.new()
	mask_bill.plant_kind = Catalog.BILL
	mask_bill.tile = Vector2i(8, 4)
	mask.step(mask_bill)
	var mask_shade = Sim.Command.new()
	mask_shade.plant_kind = Catalog.SHADE
	mask_shade.tile = Vector2i(6, 6)
	mask.step(mask_shade)
	var sealed = mask.spawn_pest(mask.tile_center(7, 4), true, true, true, true, true, true, true, true, true, true, true)
	var sealed_id := int(sealed.id)
	_expect(mask.tile_burns_shroud(7, 4) and mask.tile_cracks_rind(7, 4) and mask.tile_melts_pitch(7, 4) and mask.tile_thaws_frost(7, 4) and mask.tile_cuts_web(7, 4) and mask.tile_cracks_glass(7, 4) and mask.tile_strips_scale(7, 4) and mask.tile_cracks_mail(7, 4) and mask.tile_splits_hide(7, 4) and mask.tile_shades_dusk(7, 4) and not mask.tile_cowls_veil(7, 4) and sealed.hidden, "every older lock leaves a veil moth sealed")
	guard = 0
	var sealed_hit := false
	while guard < 20 and mask.outcome == Sim.OUTCOME_RUNNING:
		mask.step(idle)
		guard += 1
		for event in mask.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				sealed_hit = true
	var sealed_now = mask.pest_by_id(sealed_id)
	_expect(not sealed_hit and sealed_now != null and int(sealed_now.hp) == Sim.PEST_HP, "a mask moth ignores shots until every lock, including the cowl, is open")
	var mask_cowl = Sim.Command.new()
	mask_cowl.plant_kind = Catalog.COWL
	mask_cowl.tile = Vector2i(7, 5)
	mask.step(mask_cowl)
	var opened = mask.pest_by_id(sealed_id)
	_expect(opened != null and not opened.hidden, "cowl plus the older locks together reveal a mask moth")
	var outside = mask.spawn_pest(mask.tile_center(1, 1), false, false, false, false, false, false, false, false, false, false, true)
	_expect(outside.hidden, "a veil moth outside the cowl seals again")
	var opened_hit := false
	guard = 0
	while guard < 80 and mask.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		mask.step(idle)
		guard += 1
		for event in mask.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				opened_hit = true
	_expect(opened_hit, "the opened mask moth takes a hit")


func _test_twenty_fourth_nights() -> void:
	print("nights 24 and 25")
	_expect(Sim.START_SEEDS == 23, "the run starts with twenty-three seeds")
	_expect(Sim.WAVE_COUNT == 47 and Sim.WAVES.size() == 47, "forty-seven nights")
	_expect(int(Sim.WAVES[23]["count"]) == 10 and int(Sim.WAVES[23]["interval"]) == 72 and int(Sim.WAVES[23]["shroud_every"]) == 0 and int(Sim.WAVES[23]["rind_every"]) == 0 and int(Sim.WAVES[23]["pitch_every"]) == 0 and int(Sim.WAVES[23]["frost_every"]) == 0 and int(Sim.WAVES[23]["web_every"]) == 0 and int(Sim.WAVES[23]["glass_every"]) == 0 and int(Sim.WAVES[23]["scale_every"]) == 0 and int(Sim.WAVES[23]["mail_every"]) == 0 and int(Sim.WAVES[23]["hide_every"]) == 0 and int(Sim.WAVES[23]["dusk_every"]) == 0 and int(Sim.WAVES[23]["veil_every"]) == 1 and str(Sim.WAVES[23]["name"]) == "Veil", "night 24 is all veil")
	_expect(int(Sim.WAVES[24]["count"]) == 16 and int(Sim.WAVES[24]["interval"]) == 60 and int(Sim.WAVES[24]["shroud_every"]) == 2 and int(Sim.WAVES[24]["rind_every"]) == 1 and int(Sim.WAVES[24]["pitch_every"]) == 1 and int(Sim.WAVES[24]["frost_every"]) == 1 and int(Sim.WAVES[24]["web_every"]) == 1 and int(Sim.WAVES[24]["glass_every"]) == 1 and int(Sim.WAVES[24]["scale_every"]) == 1 and int(Sim.WAVES[24]["mail_every"]) == 1 and int(Sim.WAVES[24]["hide_every"]) == 1 and int(Sim.WAVES[24]["dusk_every"]) == 1 and int(Sim.WAVES[24]["veil_every"]) == 1 and str(Sim.WAVES[24]["name"]) == "Mask", "night 25 is veil, dusk, hide, mail, scale, glass, web, frost, pitch, and rind, every second also a shroud")
	for i in 23:
		_expect(int(Sim.WAVES[i].get("veil_every", 0)) == 0, "night %d still spawns no veil" % (i + 1))
	_expect(int(Sim.WAVES[21]["dusk_every"]) == 1 and str(Sim.WAVES[21]["name"]) == "Dusk" and int(Sim.WAVES[21]["count"]) == 10, "night 22 is still the dusk wave")
	_expect(int(Sim.WAVES[22]["dusk_every"]) == 1 and int(Sim.WAVES[22].get("veil_every", 0)) == 0 and str(Sim.WAVES[22]["name"]) == "Dim" and int(Sim.WAVES[22]["count"]) == 16, "night 23 is still the dim wave and spawns no veil")
	var named = Sim.new(1)
	named.wave = 24
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 24 of 47 (Veil) — 0 pests left", "night 24 heading: %s" % named.phase_text())
	named.wave = 25
	_expect(named.phase_text() == "Night 25 of 47 (Mask) — 0 pests left", "night 25 heading: %s" % named.phase_text())
	named.wave = 23
	named.phase = Sim.PHASE_PLANT
	named.phase_ticks = 0
	_expect(named.phase_text().begins_with("Planting — night 24 (Veil)"), "planting before veil: %s" % named.phase_text())

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var missed := _play(run_seed, Callable(self, "_corner_cowl_command"))
		print("  corner cowl seed=%s outcome=%s night=%s hp=%s tick=%s veil=%s/%s" % [run_seed, missed[0], missed[1], missed[4], missed[3], missed[29], missed[28]])
		_expect(int(missed[0]) == Sim.OUTCOME_LOST, "seed %s dies when the cowl misses the kill tiles" % run_seed)
		_expect(int(missed[1]) == 24, "seed %s dies on night 24 with a corner cowl (night %s)" % [run_seed, missed[1]])
		_expect(int(missed[4]) == 0, "seed %s health reached zero" % run_seed)
		_expect(int(missed[8]) == Sim.START_SEEDS - 12 and int(missed[9]) == 12, "seed %s planted the cowl, just not where the night arrives" % run_seed)
		_expect(int(missed[28]) > int(missed[29]), "seed %s left veil moths uncowled (%s spawned, %s killed)" % [run_seed, missed[28], missed[29]])
		_expect(int(missed[26]) == 26 and int(missed[27]) == 26, "seed %s had already shaded dusk before the corner cowl failed (%s/%s)" % [run_seed, missed[27], missed[26]])
		var held := _play(run_seed, Callable(self, "_cowl_command"), 25)
		print("  cowl seed=%s outcome=%s night=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s/%s glasses=%s/%s scales=%s/%s mails=%s/%s hides=%s/%s dusk=%s/%s veil=%s/%s pall=%s/%s" % [run_seed, held[0], held[1], held[4], held[3], held[7], held[6], held[11], held[10], held[13], held[12], held[15], held[14], held[17], held[16], held[19], held[18], held[21], held[20], held[23], held[22], held[25], held[24], held[27], held[26], held[29], held[28], held[31], held[30]])
		_expect(int(held[0]) == Sim.OUTCOME_RUNNING and int(held[2]) == Sim.PHASE_PLANT, "seed %s is still planting after night 25" % run_seed)
		_expect(int(held[1]) == 25, "seed %s cleared through night 25" % run_seed)
		_expect(int(held[4]) == 100, "seed %s finished night 25 at full health (%s)" % [run_seed, held[4]])
		_expect(int(held[6]) == 96 and int(held[7]) == 96, "seed %s burned every shroud moth (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 170 and int(held[11]) == 170, "seed %s cracked every rind moth (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 154 and int(held[13]) == 154, "seed %s melted every pitch moth (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 138 and int(held[15]) == 138, "seed %s thawed every frost moth (%s/%s)" % [run_seed, held[15], held[14]])
		_expect(int(held[16]) == 122 and int(held[17]) == 122, "seed %s cut every web moth (%s/%s)" % [run_seed, held[17], held[16]])
		_expect(int(held[18]) == 106 and int(held[19]) == 106, "seed %s cracked every glass moth (%s/%s)" % [run_seed, held[19], held[18]])
		_expect(int(held[20]) == 90 and int(held[21]) == 90, "seed %s stripped every scale moth (%s/%s)" % [run_seed, held[21], held[20]])
		_expect(int(held[22]) == 74 and int(held[23]) == 74, "seed %s cracked every mail moth (%s/%s)" % [run_seed, held[23], held[22]])
		_expect(int(held[24]) == 58 and int(held[25]) == 58, "seed %s split every hide moth (%s/%s)" % [run_seed, held[25], held[24]])
		_expect(int(held[26]) == 42 and int(held[27]) == 42, "seed %s shaded every dusk moth (%s/%s)" % [run_seed, held[27], held[26]])
		_expect(int(held[28]) == 26 and int(held[29]) == 26, "seed %s cowled every veil moth (%s/%s)" % [run_seed, held[29], held[28]])
		_expect(int(held[30]) == 0 and int(held[31]) == 0, "seed %s meets no pall moth before night 26" % run_seed)
		_expect(int(held[8]) == Sim.START_SEEDS - 12 and int(held[9]) == 12, "seed %s spent twelve seeds and left the thirteenth unspent" % run_seed)
		var layout := _cowl_garden_layout(run_seed)
		_expect(not bool(layout["lantern"]), "seed %s left the lantern unplanted" % run_seed)
		_expect(layout["shade"] == Vector2i(6, 6), "seed %s kept the shade at (6, 6)" % run_seed)
		_expect(layout["cowl"] == Vector2i(7, 5), "seed %s planted the cowl at (7, 5)" % run_seed)
		_expect(not bool(layout["hood"]), "seed %s left the hood unplanted" % run_seed)
		var fell := _play(run_seed, Callable(self, "_cowl_command"))
		print("  cowl into pall seed=%s outcome=%s night=%s hp=%s pall=%s/%s" % [run_seed, fell[0], fell[1], fell[4], fell[31], fell[30]])
		_expect(int(fell[0]) == Sim.OUTCOME_LOST, "seed %s dies when no hood is planted" % run_seed)
		_expect(int(fell[1]) == 26, "seed %s dies on the pall night (night %s)" % [run_seed, fell[1]])
		_expect(int(fell[4]) == 0, "seed %s health reached zero on the pall night" % run_seed)
		_expect(int(fell[30]) > 0 and int(fell[31]) == 0, "seed %s left every pall moth unhooded (%s spawned, %s killed)" % [run_seed, fell[30], fell[31]])
		_expect(int(fell[28]) == 26 and int(fell[29]) == 26, "seed %s had already cowled the veil nights before pall (%s/%s)" % [run_seed, fell[29], fell[28]])
		_expect(int(fell[8]) == Sim.START_SEEDS - 12 and int(fell[9]) == 12, "seed %s still has the thirteenth seed unspent when the pall arrives" % run_seed)
	var again := _play(42, Callable(self, "_cowl_command"))
	var replay := _play(42, Callable(self, "_cowl_command"))
	_expect(str(again) == str(replay), "same seed and cowl plan replay")


func _cowl_garden_layout(seed_value: int) -> Dictionary:
	var sim = Sim.new(seed_value)
	var guard := 0
	while sim.phase == Sim.PHASE_PLANT and sim.outcome == Sim.OUTCOME_RUNNING and guard < 400:
		sim.step(_cowl_command(sim))
		guard += 1
	var cowl = sim.plant_of_kind(Catalog.COWL)
	var shade = sim.plant_of_kind(Catalog.SHADE)
	var cowl_cell := Vector2i(-1, -1)
	var shade_cell := Vector2i(-1, -1)
	if cowl != null:
		cowl_cell = cowl.cell
	if shade != null:
		shade_cell = shade.cell
	return {"lantern": sim.has_plant(Catalog.LANTERN), "cowl": cowl_cell, "shade": shade_cell, "hood": sim.has_plant(Catalog.HOOD)}


func _test_pall_rule() -> void:
	print("hood pall rule")
	var placed = Sim.new(4)
	placed.seeds = 16
	var wick = Sim.Command.new()
	wick.plant_kind = Catalog.WICK
	wick.tile = Vector2i(6, 5)
	placed.step(wick)
	var briar = Sim.Command.new()
	briar.plant_kind = Catalog.BRIAR
	briar.tile = Vector2i(6, 4)
	placed.step(briar)
	var flare = Sim.Command.new()
	flare.plant_kind = Catalog.FLARE
	flare.tile = Vector2i(7, 4)
	placed.step(flare)
	var hearth = Sim.Command.new()
	hearth.plant_kind = Catalog.HEARTH
	hearth.tile = Vector2i(5, 5)
	placed.step(hearth)
	var shear = Sim.Command.new()
	shear.plant_kind = Catalog.SHEAR
	shear.tile = Vector2i(7, 6)
	placed.step(shear)
	var chime = Sim.Command.new()
	chime.plant_kind = Catalog.CHIME
	chime.tile = Vector2i(8, 6)
	placed.step(chime)
	var rasp = Sim.Command.new()
	rasp.plant_kind = Catalog.RASP
	rasp.tile = Vector2i(9, 5)
	placed.step(rasp)
	var maul = Sim.Command.new()
	maul.plant_kind = Catalog.MAUL
	maul.tile = Vector2i(9, 6)
	placed.step(maul)
	var bill = Sim.Command.new()
	bill.plant_kind = Catalog.BILL
	bill.tile = Vector2i(8, 4)
	placed.step(bill)
	var shade = Sim.Command.new()
	shade.plant_kind = Catalog.SHADE
	shade.tile = Vector2i(6, 6)
	placed.step(shade)
	var cowl = Sim.Command.new()
	cowl.plant_kind = Catalog.COWL
	cowl.tile = Vector2i(7, 5)
	placed.step(cowl)
	var idle = Sim.Command.new()
	placed.step(idle)
	_expect(placed.tile_cowls_veil(7, 5) and placed.tile_shades_dusk(7, 5) and placed.tile_lit(7, 5), "the night-25 garden still cowls, shades, and lights the gardener")
	_expect(not placed.tile_hoods_pall(7, 5) and not placed.tile_hoods_pall(6, 6) and not placed.tile_hoods_pall(5, 5), "a cowl and a shade do not hood the gardener, the shade, or the hearth")
	var corner = Sim.Command.new()
	corner.plant_kind = Catalog.HOOD
	corner.tile = Vector2i(1, 1)
	placed.step(corner)
	_expect(not placed.tile_hoods_pall(7, 5), "a corner hood does not hood the gardener tile")
	_expect(placed.tile_hoods_pall(1, 1), "a hood on its own tile hoods it")
	_expect(not placed.tile_lit(1, 1), "a hood does not light its own tile")
	_expect(not placed.tile_cowls_veil(1, 1) and not placed.tile_shades_dusk(1, 1) and not placed.tile_splits_hide(1, 1), "a hood does not cowl veil, shade dusk, or split hide")
	var beside = Sim.Command.new()
	beside.plant_kind = Catalog.HOOD
	beside.tile = Vector2i(5, 6)
	placed.step(beside)
	_expect(placed.tile_hoods_pall(7, 5) and placed.tile_hoods_pall(6, 6) and placed.tile_hoods_pall(5, 5) and placed.tile_hoods_pall(8, 5), "the winning hood covers the gardener, the shade, the hearth, and the pea")
	_expect(placed.tile_hoods_pall(7, 4) and placed.tile_hoods_pall(6, 5) and placed.tile_hoods_pall(8, 4), "that hood also covers the flare, the wick, and the bill")
	_expect(not placed.tile_hoods_pall(13, 9), "the winning hood leaves the far orchard edge sealed")
	var hood_plant = placed.plant_of_kind(Catalog.HOOD)
	_expect(hood_plant != null and hood_plant.hoods_pall and not hood_plant.casts_light and not hood_plant.cowls_veil and not hood_plant.shades_dusk and not hood_plant.splits_hide and not hood_plant.burns_shroud and not hood_plant.cracks_rind and not hood_plant.melts_pitch and not hood_plant.thaws_frost and not hood_plant.cuts_web and not hood_plant.cracks_glass and not hood_plant.strips_scale and not hood_plant.cracks_mail, "the hood hoods pall and does not light, cowl, shade, split, burn, crack rind, melt, thaw, cut web, crack glass, strip scale, or crack mail")
	_expect(not placed.plant_of_kind(Catalog.COWL).hoods_pall, "the cowl does not hood pall")
	_expect(not placed.plant_of_kind(Catalog.SHADE).hoods_pall, "the shade does not hood pall")
	_expect(not placed.plant_of_kind(Catalog.BILL).hoods_pall, "the bill does not hood pall")
	_expect(not placed.plant_of_kind(Catalog.WICK).hoods_pall, "the wick does not hood pall")

	var sim = Sim.new(6)
	var sow_cowl = Sim.Command.new()
	sow_cowl.plant_kind = Catalog.COWL
	sow_cowl.tile = Vector2i(7, 5)
	sim.step(sow_cowl)
	var sow_shade = Sim.Command.new()
	sow_shade.plant_kind = Catalog.SHADE
	sow_shade.tile = Vector2i(6, 6)
	sim.step(sow_shade)
	var sow_pea = Sim.Command.new()
	sow_pea.plant_kind = Catalog.PEA
	sow_pea.tile = Vector2i(8, 5)
	sim.step(sow_pea)
	var pall = sim.spawn_pest(sim.tile_center(7, 5), false, false, false, false, false, false, false, false, false, false, false, true)
	var veil = sim.spawn_pest(sim.tile_center(7, 5), false, false, false, false, false, false, false, false, false, false, true, false)
	var dusk = sim.spawn_pest(sim.tile_center(6, 6), false, false, false, false, false, false, false, false, false, true, false, false)
	var pall_id := int(pall.id)
	var veil_id := int(veil.id)
	var dusk_id := int(dusk.id)
	_expect(sim.tile_cowls_veil(7, 5) and sim.tile_shades_dusk(6, 6) and not sim.tile_hoods_pall(7, 5) and pall.hidden and not veil.hidden and not dusk.hidden, "cowl opens veil and shade opens dusk while the pall moth stays sealed")
	var pall_hit := false
	var veil_hit := false
	var dusk_hit := false
	var guard := 0
	while guard < 80 and sim.outcome == Sim.OUTCOME_RUNNING:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == pall_id:
				pall_hit = true
			if int(event["pest_id"]) == veil_id:
				veil_hit = true
			if int(event["pest_id"]) == dusk_id:
				dusk_hit = true
	var pall_now = sim.pest_by_id(pall_id)
	_expect(veil_hit, "a cowl still lets a veil moth take damage")
	_expect(dusk_hit, "a shade still lets a dusk moth take damage")
	_expect(not pall_hit and pall_now != null and int(pall_now.hp) == Sim.PEST_HP, "a cowl and a shade do not damage a pall moth")

	var only = Sim.new(5)
	var sow_hood = Sim.Command.new()
	sow_hood.plant_kind = Catalog.HOOD
	sow_hood.tile = Vector2i(5, 6)
	only.step(sow_hood)
	var sealed_veil = only.spawn_pest(only.tile_center(5, 6), false, false, false, false, false, false, false, false, false, false, true, false)
	var sealed_dusk = only.spawn_pest(only.tile_center(5, 6), false, false, false, false, false, false, false, false, false, true, false, false)
	var sealed_hide = only.spawn_pest(only.tile_center(5, 6), false, false, false, false, false, false, false, false, true, false, false, false)
	var opened_pall = only.spawn_pest(only.tile_center(5, 6), false, false, false, false, false, false, false, false, false, false, false, true)
	var plain = only.spawn_pest(only.tile_center(5, 6), false, false, false, false, false, false, false, false, false, false, false, false)
	_expect(only.tile_hoods_pall(5, 6) and only.tile_hoods_pall(7, 5) and not only.tile_lit(5, 6) and not only.tile_cowls_veil(5, 6) and not only.tile_shades_dusk(5, 6), "hood marks the tile without lighting it, cowling veil, or shading dusk")
	_expect(sealed_veil.hidden, "a hood does not reveal a veil moth")
	_expect(sealed_dusk.hidden, "a hood does not reveal a dusk moth")
	_expect(sealed_hide.hidden, "a hood does not reveal a hide")
	_expect(not opened_pall.hidden, "a hood reveals a pall moth on its tile")
	_expect(plain.hidden, "an ordinary moth stays hidden in a hood with no light")
	var hood_hit := false
	var veil_hurt := false
	var dusk_hurt := false
	var hide_hurt := false
	guard = 0
	while guard < 80 and only.outcome == Sim.OUTCOME_RUNNING and not hood_hit:
		only.step(idle)
		guard += 1
		for event in only.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == int(opened_pall.id):
				hood_hit = true
			if int(event["pest_id"]) == int(sealed_veil.id):
				veil_hurt = true
			if int(event["pest_id"]) == int(sealed_dusk.id):
				dusk_hurt = true
			if int(event["pest_id"]) == int(sealed_hide.id):
				hide_hurt = true
	var veil_left = only.pest_by_id(int(sealed_veil.id))
	var dusk_left = only.pest_by_id(int(sealed_dusk.id))
	var hide_left = only.pest_by_id(int(sealed_hide.id))
	_expect(hood_hit, "the revealed pall moth takes a hit")
	_expect(not veil_hurt and veil_left != null and int(veil_left.hp) == Sim.PEST_HP, "shots do not hurt a veil moth standing in a hood")
	_expect(not dusk_hurt and dusk_left != null and int(dusk_left.hp) == Sim.PEST_HP, "shots do not hurt a dusk moth standing in a hood")
	_expect(not hide_hurt and hide_left != null and int(hide_left.hp) == Sim.PEST_HP, "shots do not hurt a hide standing in a hood")

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	splash.step(sow_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, false, false, false, false)
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, false, false, false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the pall moth")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a pall moth outside a hood")

	var mantle = Sim.new(9)
	mantle.seeds = 16
	var mantle_wick = Sim.Command.new()
	mantle_wick.plant_kind = Catalog.WICK
	mantle_wick.tile = Vector2i(6, 5)
	mantle.step(mantle_wick)
	var mantle_briar = Sim.Command.new()
	mantle_briar.plant_kind = Catalog.BRIAR
	mantle_briar.tile = Vector2i(6, 4)
	mantle.step(mantle_briar)
	var mantle_flare = Sim.Command.new()
	mantle_flare.plant_kind = Catalog.FLARE
	mantle_flare.tile = Vector2i(7, 4)
	mantle.step(mantle_flare)
	var mantle_pea = Sim.Command.new()
	mantle_pea.plant_kind = Catalog.PEA
	mantle_pea.tile = Vector2i(8, 5)
	mantle.step(mantle_pea)
	var mantle_hearth = Sim.Command.new()
	mantle_hearth.plant_kind = Catalog.HEARTH
	mantle_hearth.tile = Vector2i(5, 5)
	mantle.step(mantle_hearth)
	var mantle_shear = Sim.Command.new()
	mantle_shear.plant_kind = Catalog.SHEAR
	mantle_shear.tile = Vector2i(7, 6)
	mantle.step(mantle_shear)
	var mantle_chime = Sim.Command.new()
	mantle_chime.plant_kind = Catalog.CHIME
	mantle_chime.tile = Vector2i(8, 6)
	mantle.step(mantle_chime)
	var mantle_rasp = Sim.Command.new()
	mantle_rasp.plant_kind = Catalog.RASP
	mantle_rasp.tile = Vector2i(9, 5)
	mantle.step(mantle_rasp)
	var mantle_maul = Sim.Command.new()
	mantle_maul.plant_kind = Catalog.MAUL
	mantle_maul.tile = Vector2i(9, 6)
	mantle.step(mantle_maul)
	var mantle_bill = Sim.Command.new()
	mantle_bill.plant_kind = Catalog.BILL
	mantle_bill.tile = Vector2i(8, 4)
	mantle.step(mantle_bill)
	var mantle_shade = Sim.Command.new()
	mantle_shade.plant_kind = Catalog.SHADE
	mantle_shade.tile = Vector2i(6, 6)
	mantle.step(mantle_shade)
	var mantle_cowl = Sim.Command.new()
	mantle_cowl.plant_kind = Catalog.COWL
	mantle_cowl.tile = Vector2i(7, 5)
	mantle.step(mantle_cowl)
	var sealed = mantle.spawn_pest(mantle.tile_center(7, 4), true, true, true, true, true, true, true, true, true, true, true, true)
	var sealed_id := int(sealed.id)
	_expect(mantle.tile_burns_shroud(7, 4) and mantle.tile_cracks_rind(7, 4) and mantle.tile_melts_pitch(7, 4) and mantle.tile_thaws_frost(7, 4) and mantle.tile_cuts_web(7, 4) and mantle.tile_cracks_glass(7, 4) and mantle.tile_strips_scale(7, 4) and mantle.tile_cracks_mail(7, 4) and mantle.tile_splits_hide(7, 4) and mantle.tile_shades_dusk(7, 4) and mantle.tile_cowls_veil(7, 4) and not mantle.tile_hoods_pall(7, 4) and sealed.hidden, "every older lock leaves a pall moth sealed")
	guard = 0
	var sealed_hit := false
	while guard < 20 and mantle.outcome == Sim.OUTCOME_RUNNING:
		mantle.step(idle)
		guard += 1
		for event in mantle.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				sealed_hit = true
	var sealed_now = mantle.pest_by_id(sealed_id)
	_expect(not sealed_hit and sealed_now != null and int(sealed_now.hp) == Sim.PEST_HP, "a mantle moth ignores shots until every lock, including the hood, is open")
	var mantle_hood = Sim.Command.new()
	mantle_hood.plant_kind = Catalog.HOOD
	mantle_hood.tile = Vector2i(5, 6)
	mantle.step(mantle_hood)
	var opened = mantle.pest_by_id(sealed_id)
	_expect(opened != null and not opened.hidden, "hood plus the older locks together reveal a mantle moth")
	var outside = mantle.spawn_pest(mantle.tile_center(1, 1), false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(outside.hidden, "a pall moth outside the hood seals again")
	var opened_hit := false
	guard = 0
	while guard < 80 and mantle.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		mantle.step(idle)
		guard += 1
		for event in mantle.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				opened_hit = true
	_expect(opened_hit, "the opened mantle moth takes a hit")


func _test_twenty_sixth_nights() -> void:
	print("nights 26 and 27")
	_expect(Sim.START_SEEDS == 23, "the run starts with twenty-three seeds")
	_expect(Sim.WAVE_COUNT == 47 and Sim.WAVES.size() == 47, "forty-seven nights")
	_expect(int(Sim.WAVES[25]["count"]) == 10 and int(Sim.WAVES[25]["interval"]) == 72 and int(Sim.WAVES[25]["shroud_every"]) == 0 and int(Sim.WAVES[25]["rind_every"]) == 0 and int(Sim.WAVES[25]["pitch_every"]) == 0 and int(Sim.WAVES[25]["frost_every"]) == 0 and int(Sim.WAVES[25]["web_every"]) == 0 and int(Sim.WAVES[25]["glass_every"]) == 0 and int(Sim.WAVES[25]["scale_every"]) == 0 and int(Sim.WAVES[25]["mail_every"]) == 0 and int(Sim.WAVES[25]["hide_every"]) == 0 and int(Sim.WAVES[25]["dusk_every"]) == 0 and int(Sim.WAVES[25]["veil_every"]) == 0 and int(Sim.WAVES[25]["pall_every"]) == 1 and str(Sim.WAVES[25]["name"]) == "Pall", "night 26 is all pall")
	_expect(int(Sim.WAVES[26]["count"]) == 16 and int(Sim.WAVES[26]["interval"]) == 60 and int(Sim.WAVES[26]["shroud_every"]) == 2 and int(Sim.WAVES[26]["rind_every"]) == 1 and int(Sim.WAVES[26]["pitch_every"]) == 1 and int(Sim.WAVES[26]["frost_every"]) == 1 and int(Sim.WAVES[26]["web_every"]) == 1 and int(Sim.WAVES[26]["glass_every"]) == 1 and int(Sim.WAVES[26]["scale_every"]) == 1 and int(Sim.WAVES[26]["mail_every"]) == 1 and int(Sim.WAVES[26]["hide_every"]) == 1 and int(Sim.WAVES[26]["dusk_every"]) == 1 and int(Sim.WAVES[26]["veil_every"]) == 1 and int(Sim.WAVES[26]["pall_every"]) == 1 and str(Sim.WAVES[26]["name"]) == "Mantle", "night 27 is pall, veil, dusk, hide, mail, scale, glass, web, frost, pitch, and rind, every second also a shroud")
	for i in 25:
		_expect(int(Sim.WAVES[i].get("pall_every", 0)) == 0, "night %d still spawns no pall" % (i + 1))
	_expect(int(Sim.WAVES[23]["veil_every"]) == 1 and str(Sim.WAVES[23]["name"]) == "Veil" and int(Sim.WAVES[23]["count"]) == 10, "night 24 is still the veil wave")
	_expect(int(Sim.WAVES[24]["veil_every"]) == 1 and int(Sim.WAVES[24].get("pall_every", 0)) == 0 and str(Sim.WAVES[24]["name"]) == "Mask" and int(Sim.WAVES[24]["count"]) == 16, "night 25 is still the mask wave and spawns no pall")
	_expect(int(Sim.WAVES[25].get("gloom_every", 0)) == 0 and int(Sim.WAVES[26].get("gloom_every", 0)) == 0, "nights 26 and 27 spawn no gloom")
	var named = Sim.new(1)
	named.wave = 26
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 26 of 47 (Pall) — 0 pests left", "night 26 heading: %s" % named.phase_text())
	named.wave = 27
	_expect(named.phase_text() == "Night 27 of 47 (Mantle) — 0 pests left", "night 27 heading: %s" % named.phase_text())
	named.wave = 25
	named.phase = Sim.PHASE_PLANT
	named.phase_ticks = 0
	_expect(named.phase_text().begins_with("Planting — night 26 (Pall)"), "planting before pall: %s" % named.phase_text())

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var missed := _play(run_seed, Callable(self, "_corner_hood_command"))
		print("  corner hood seed=%s outcome=%s night=%s hp=%s tick=%s pall=%s/%s" % [run_seed, missed[0], missed[1], missed[4], missed[3], missed[31], missed[30]])
		_expect(int(missed[0]) == Sim.OUTCOME_LOST, "seed %s dies when the hood misses the kill tiles" % run_seed)
		_expect(int(missed[1]) == 26, "seed %s dies on night 26 with a corner hood (night %s)" % [run_seed, missed[1]])
		_expect(int(missed[4]) == 0, "seed %s health reached zero" % run_seed)
		_expect(int(missed[8]) == Sim.START_SEEDS - 13 and int(missed[9]) == 13, "seed %s planted the hood and left the fourteenth seed unspent" % run_seed)
		_expect(int(missed[30]) > int(missed[31]), "seed %s left pall moths unhooded (%s spawned, %s killed)" % [run_seed, missed[30], missed[31]])
		_expect(int(missed[28]) == 26 and int(missed[29]) == 26, "seed %s had already cowled veil before the corner hood failed (%s/%s)" % [run_seed, missed[29], missed[28]])
		var held := _play(run_seed, Callable(self, "_hood_command"), 27)
		print("  hood seed=%s outcome=%s night=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s/%s glasses=%s/%s scales=%s/%s mails=%s/%s hides=%s/%s dusk=%s/%s veil=%s/%s pall=%s/%s gloom=%s/%s" % [run_seed, held[0], held[1], held[4], held[3], held[7], held[6], held[11], held[10], held[13], held[12], held[15], held[14], held[17], held[16], held[19], held[18], held[21], held[20], held[23], held[22], held[25], held[24], held[27], held[26], held[29], held[28], held[31], held[30], held[33], held[32]])
		_expect(int(held[0]) == Sim.OUTCOME_RUNNING and int(held[2]) == Sim.PHASE_PLANT, "seed %s is still planting after night 27" % run_seed)
		_expect(int(held[1]) == 27, "seed %s cleared through night 27" % run_seed)
		_expect(int(held[4]) == 100, "seed %s finished night 27 at full health (%s)" % [run_seed, held[4]])
		_expect(int(held[6]) == 104 and int(held[7]) == 104, "seed %s burned every shroud moth (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 186 and int(held[11]) == 186, "seed %s cracked every rind moth (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 170 and int(held[13]) == 170, "seed %s melted every pitch moth (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 154 and int(held[15]) == 154, "seed %s thawed every frost moth (%s/%s)" % [run_seed, held[15], held[14]])
		_expect(int(held[16]) == 138 and int(held[17]) == 138, "seed %s cut every web moth (%s/%s)" % [run_seed, held[17], held[16]])
		_expect(int(held[18]) == 122 and int(held[19]) == 122, "seed %s cracked every glass moth (%s/%s)" % [run_seed, held[19], held[18]])
		_expect(int(held[20]) == 106 and int(held[21]) == 106, "seed %s stripped every scale moth (%s/%s)" % [run_seed, held[21], held[20]])
		_expect(int(held[22]) == 90 and int(held[23]) == 90, "seed %s cracked every mail moth (%s/%s)" % [run_seed, held[23], held[22]])
		_expect(int(held[24]) == 74 and int(held[25]) == 74, "seed %s split every hide moth (%s/%s)" % [run_seed, held[25], held[24]])
		_expect(int(held[26]) == 58 and int(held[27]) == 58, "seed %s shaded every dusk moth (%s/%s)" % [run_seed, held[27], held[26]])
		_expect(int(held[28]) == 42 and int(held[29]) == 42, "seed %s cowled every veil moth (%s/%s)" % [run_seed, held[29], held[28]])
		_expect(int(held[30]) == 26 and int(held[31]) == 26, "seed %s hooded every pall moth (%s/%s)" % [run_seed, held[31], held[30]])
		_expect(int(held[32]) == 0 and int(held[33]) == 0, "seed %s meets no gloom moth before night 28" % run_seed)
		_expect(int(held[8]) == Sim.START_SEEDS - 13 and int(held[9]) == 13, "seed %s spent thirteen seeds and left the fourteenth unspent" % run_seed)
		var layout := _hood_garden_layout(run_seed)
		_expect(not bool(layout["lantern"]), "seed %s left the lantern unplanted" % run_seed)
		_expect(layout["shade"] == Vector2i(6, 6), "seed %s kept the shade at (6, 6)" % run_seed)
		_expect(layout["cowl"] == Vector2i(7, 5), "seed %s kept the cowl at (7, 5)" % run_seed)
		_expect(layout["bill"] == Vector2i(8, 4), "seed %s kept the bill at (8, 4)" % run_seed)
		_expect(layout["hearth"] == Vector2i(5, 5), "seed %s kept the hearth at (5, 5)" % run_seed)
		_expect(layout["hood"] == Vector2i(5, 6), "seed %s planted the hood at (5, 6)" % run_seed)
		_expect(not bool(layout["cloak"]), "seed %s left the cloak unplanted" % run_seed)
		var fell := _play(run_seed, Callable(self, "_hood_command"))
		print("  unspent cloak seed=%s outcome=%s night=%s hp=%s gloom=%s/%s" % [run_seed, fell[0], fell[1], fell[4], fell[33], fell[32]])
		_expect(int(fell[0]) == Sim.OUTCOME_LOST, "seed %s dies when the fourteenth seed stays unspent" % run_seed)
		_expect(int(fell[1]) == 28, "seed %s dies on the gloom night (night %s)" % [run_seed, fell[1]])
		_expect(int(fell[4]) == 0, "seed %s health reached zero on the gloom night" % run_seed)
		_expect(int(fell[32]) > 0 and int(fell[33]) == 0, "seed %s left every gloom moth uncloaked (%s spawned, %s killed)" % [run_seed, fell[32], fell[33]])
		_expect(int(fell[30]) == 26 and int(fell[31]) == 26, "seed %s had already hooded the pall nights before gloom (%s/%s)" % [run_seed, fell[31], fell[30]])
		_expect(int(fell[8]) == Sim.START_SEEDS - 13 and int(fell[9]) == 13, "seed %s still has the fourteenth seed unspent when the gloom arrives" % run_seed)
	var again := _play(42, Callable(self, "_hood_command"), 27)
	var replay := _play(42, Callable(self, "_hood_command"), 27)
	_expect(str(again) == str(replay), "same seed and hood plan replay through night 27")


func _hood_garden_layout(seed_value: int) -> Dictionary:
	var sim = Sim.new(seed_value)
	var guard := 0
	while sim.phase == Sim.PHASE_PLANT and sim.outcome == Sim.OUTCOME_RUNNING and guard < 400:
		sim.step(_hood_command(sim))
		guard += 1
	return {
		"lantern": sim.has_plant(Catalog.LANTERN),
		"shade": _plant_cell(sim, Catalog.SHADE),
		"cowl": _plant_cell(sim, Catalog.COWL),
		"bill": _plant_cell(sim, Catalog.BILL),
		"hearth": _plant_cell(sim, Catalog.HEARTH),
		"hood": _plant_cell(sim, Catalog.HOOD),
		"cloak": sim.has_plant(Catalog.CLOAK),
	}


func _test_gloom_rule() -> void:
	print("cloak gloom rule")
	var placed = Sim.new(4)
	placed.seeds = 16
	var wick = Sim.Command.new()
	wick.plant_kind = Catalog.WICK
	wick.tile = Vector2i(6, 5)
	placed.step(wick)
	var briar = Sim.Command.new()
	briar.plant_kind = Catalog.BRIAR
	briar.tile = Vector2i(6, 4)
	placed.step(briar)
	var flare = Sim.Command.new()
	flare.plant_kind = Catalog.FLARE
	flare.tile = Vector2i(7, 4)
	placed.step(flare)
	var hearth = Sim.Command.new()
	hearth.plant_kind = Catalog.HEARTH
	hearth.tile = Vector2i(5, 5)
	placed.step(hearth)
	var shear = Sim.Command.new()
	shear.plant_kind = Catalog.SHEAR
	shear.tile = Vector2i(7, 6)
	placed.step(shear)
	var chime = Sim.Command.new()
	chime.plant_kind = Catalog.CHIME
	chime.tile = Vector2i(8, 6)
	placed.step(chime)
	var rasp = Sim.Command.new()
	rasp.plant_kind = Catalog.RASP
	rasp.tile = Vector2i(9, 5)
	placed.step(rasp)
	var maul = Sim.Command.new()
	maul.plant_kind = Catalog.MAUL
	maul.tile = Vector2i(9, 6)
	placed.step(maul)
	var bill = Sim.Command.new()
	bill.plant_kind = Catalog.BILL
	bill.tile = Vector2i(8, 4)
	placed.step(bill)
	var shade = Sim.Command.new()
	shade.plant_kind = Catalog.SHADE
	shade.tile = Vector2i(6, 6)
	placed.step(shade)
	var cowl = Sim.Command.new()
	cowl.plant_kind = Catalog.COWL
	cowl.tile = Vector2i(7, 5)
	placed.step(cowl)
	var hood = Sim.Command.new()
	hood.plant_kind = Catalog.HOOD
	hood.tile = Vector2i(5, 6)
	placed.step(hood)
	var idle = Sim.Command.new()
	placed.step(idle)
	_expect(placed.tile_hoods_pall(7, 5) and placed.tile_cowls_veil(7, 5) and placed.tile_shades_dusk(7, 5) and placed.tile_lit(7, 5), "the night-27 garden still hoods, cowls, shades, and lights the gardener")
	_expect(not placed.tile_cloaks_gloom(7, 5) and not placed.tile_cloaks_gloom(5, 6) and not placed.tile_cloaks_gloom(6, 6), "a hood, a cowl, and a shade do not cloak the gardener, the hood, or the shade")
	var corner = Sim.Command.new()
	corner.plant_kind = Catalog.CLOAK
	corner.tile = Vector2i(1, 1)
	placed.step(corner)
	_expect(not placed.tile_cloaks_gloom(7, 5), "a corner cloak does not cloak the gardener tile")
	_expect(placed.tile_cloaks_gloom(1, 1), "a cloak on its own tile cloaks it")
	_expect(not placed.tile_lit(1, 1), "a cloak does not light its own tile")
	_expect(not placed.tile_hoods_pall(1, 1) and not placed.tile_cowls_veil(1, 1) and not placed.tile_shades_dusk(1, 1), "a cloak does not hood pall, cowl veil, or shade dusk")
	var beside = Sim.Command.new()
	beside.plant_kind = Catalog.CLOAK
	beside.tile = Vector2i(4, 6)
	placed.step(beside)
	_expect(placed.tile_cloaks_gloom(7, 5) and placed.tile_cloaks_gloom(6, 6) and placed.tile_cloaks_gloom(5, 5) and placed.tile_cloaks_gloom(8, 5), "the winning cloak covers the gardener, the shade, the hearth, and the pea")
	_expect(placed.tile_cloaks_gloom(7, 4) and placed.tile_cloaks_gloom(6, 5) and placed.tile_cloaks_gloom(8, 4) and placed.tile_cloaks_gloom(5, 6), "that cloak also covers the flare, the wick, the bill, and the hood")
	_expect(not placed.tile_cloaks_gloom(13, 9), "the winning cloak leaves the far orchard edge sealed")
	var cloak_plant = placed.plant_of_kind(Catalog.CLOAK)
	_expect(cloak_plant != null and cloak_plant.cloaks_gloom and not cloak_plant.casts_light and not cloak_plant.hoods_pall and not cloak_plant.cowls_veil and not cloak_plant.shades_dusk and not cloak_plant.splits_hide and not cloak_plant.burns_shroud and not cloak_plant.cracks_rind and not cloak_plant.melts_pitch and not cloak_plant.thaws_frost and not cloak_plant.cuts_web and not cloak_plant.cracks_glass and not cloak_plant.strips_scale and not cloak_plant.cracks_mail, "the cloak cloaks gloom and does not light, hood, cowl, shade, split, burn, crack rind, melt, thaw, cut web, crack glass, strip scale, or crack mail")
	_expect(not placed.plant_of_kind(Catalog.HOOD).cloaks_gloom, "the hood does not cloak gloom")
	_expect(not placed.plant_of_kind(Catalog.COWL).cloaks_gloom, "the cowl does not cloak gloom")
	_expect(not placed.plant_of_kind(Catalog.SHADE).cloaks_gloom, "the shade does not cloak gloom")
	_expect(not placed.plant_of_kind(Catalog.BILL).cloaks_gloom, "the bill does not cloak gloom")
	_expect(not placed.plant_of_kind(Catalog.WICK).cloaks_gloom, "the wick does not cloak gloom")

	var sim = Sim.new(6)
	var sow_hood = Sim.Command.new()
	sow_hood.plant_kind = Catalog.HOOD
	sow_hood.tile = Vector2i(5, 6)
	sim.step(sow_hood)
	var sow_cowl = Sim.Command.new()
	sow_cowl.plant_kind = Catalog.COWL
	sow_cowl.tile = Vector2i(7, 5)
	sim.step(sow_cowl)
	var sow_shade = Sim.Command.new()
	sow_shade.plant_kind = Catalog.SHADE
	sow_shade.tile = Vector2i(6, 6)
	sim.step(sow_shade)
	var sow_pea = Sim.Command.new()
	sow_pea.plant_kind = Catalog.PEA
	sow_pea.tile = Vector2i(8, 5)
	sim.step(sow_pea)
	var gloom = sim.spawn_pest(sim.tile_center(7, 5), false, false, false, false, false, false, false, false, false, false, false, false, true)
	var pall = sim.spawn_pest(sim.tile_center(5, 6), false, false, false, false, false, false, false, false, false, false, false, true, false)
	var veil = sim.spawn_pest(sim.tile_center(7, 5), false, false, false, false, false, false, false, false, false, false, true, false, false)
	var dusk = sim.spawn_pest(sim.tile_center(6, 6), false, false, false, false, false, false, false, false, false, true, false, false, false)
	var gloom_id := int(gloom.id)
	var pall_id := int(pall.id)
	_expect(sim.tile_hoods_pall(5, 6) and sim.tile_cowls_veil(7, 5) and sim.tile_shades_dusk(6, 6) and not sim.tile_cloaks_gloom(7, 5) and gloom.hidden and not pall.hidden and not veil.hidden and not dusk.hidden, "hood opens pall, cowl opens veil, and shade opens dusk while the gloom moth stays sealed")
	var gloom_hit := false
	var pall_hit := false
	var guard := 0
	while guard < 80 and sim.outcome == Sim.OUTCOME_RUNNING:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == gloom_id:
				gloom_hit = true
			if int(event["pest_id"]) == pall_id:
				pall_hit = true
	var gloom_now = sim.pest_by_id(gloom_id)
	_expect(pall_hit, "a hood still lets a pall moth take damage")
	_expect(not gloom_hit and gloom_now != null and int(gloom_now.hp) == Sim.PEST_HP, "a hood, a cowl, and a shade do not damage a gloom moth")

	var only = Sim.new(5)
	var sow_cloak = Sim.Command.new()
	sow_cloak.plant_kind = Catalog.CLOAK
	sow_cloak.tile = Vector2i(4, 6)
	only.step(sow_cloak)
	var sealed_pall = only.spawn_pest(only.tile_center(4, 6), false, false, false, false, false, false, false, false, false, false, false, true, false)
	var sealed_veil = only.spawn_pest(only.tile_center(4, 6), false, false, false, false, false, false, false, false, false, false, true, false, false)
	var sealed_dusk = only.spawn_pest(only.tile_center(4, 6), false, false, false, false, false, false, false, false, false, true, false, false, false)
	var sealed_hide = only.spawn_pest(only.tile_center(4, 6), false, false, false, false, false, false, false, false, true, false, false, false, false)
	var opened_gloom = only.spawn_pest(only.tile_center(4, 6), false, false, false, false, false, false, false, false, false, false, false, false, true)
	var plain = only.spawn_pest(only.tile_center(4, 6), false, false, false, false, false, false, false, false, false, false, false, false, false)
	_expect(only.tile_cloaks_gloom(4, 6) and only.tile_cloaks_gloom(5, 6) and not only.tile_lit(4, 6) and not only.tile_hoods_pall(4, 6) and not only.tile_cowls_veil(4, 6) and not only.tile_shades_dusk(4, 6), "cloak marks the tile without lighting it, hooding pall, cowling veil, or shading dusk")
	_expect(sealed_pall.hidden, "a cloak does not reveal a pall moth")
	_expect(sealed_veil.hidden, "a cloak does not reveal a veil moth")
	_expect(sealed_dusk.hidden, "a cloak does not reveal a dusk moth")
	_expect(sealed_hide.hidden, "a cloak does not reveal a hide")
	_expect(not opened_gloom.hidden, "a cloak reveals a gloom moth on its tile")
	_expect(plain.hidden, "an ordinary moth stays hidden in a cloak with no light")
	var cloak_hit := false
	var pall_hurt := false
	var veil_hurt := false
	var dusk_hurt := false
	var hide_hurt := false
	guard = 0
	while guard < 120 and only.outcome == Sim.OUTCOME_RUNNING and not cloak_hit:
		only.step(idle)
		guard += 1
		for event in only.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == int(opened_gloom.id):
				cloak_hit = true
			if int(event["pest_id"]) == int(sealed_pall.id):
				pall_hurt = true
			if int(event["pest_id"]) == int(sealed_veil.id):
				veil_hurt = true
			if int(event["pest_id"]) == int(sealed_dusk.id):
				dusk_hurt = true
			if int(event["pest_id"]) == int(sealed_hide.id):
				hide_hurt = true
	var pall_left = only.pest_by_id(int(sealed_pall.id))
	var veil_left = only.pest_by_id(int(sealed_veil.id))
	var dusk_left = only.pest_by_id(int(sealed_dusk.id))
	var hide_left = only.pest_by_id(int(sealed_hide.id))
	_expect(cloak_hit, "the revealed gloom moth takes a hit")
	_expect(not pall_hurt and pall_left != null and int(pall_left.hp) == Sim.PEST_HP, "shots do not hurt a pall moth standing in a cloak")
	_expect(not veil_hurt and veil_left != null and int(veil_left.hp) == Sim.PEST_HP, "shots do not hurt a veil moth standing in a cloak")
	_expect(not dusk_hurt and dusk_left != null and int(dusk_left.hp) == Sim.PEST_HP, "shots do not hurt a dusk moth standing in a cloak")
	_expect(not hide_hurt and hide_left != null and int(hide_left.hp) == Sim.PEST_HP, "shots do not hurt a hide standing in a cloak")

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	splash.step(sow_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, false, false, false, false, false)
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, false, false, false, false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the gloom moth")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a gloom moth outside a cloak")

	var cope = Sim.new(9)
	cope.seeds = 16
	var cope_wick = Sim.Command.new()
	cope_wick.plant_kind = Catalog.WICK
	cope_wick.tile = Vector2i(6, 5)
	cope.step(cope_wick)
	var cope_briar = Sim.Command.new()
	cope_briar.plant_kind = Catalog.BRIAR
	cope_briar.tile = Vector2i(6, 4)
	cope.step(cope_briar)
	var cope_flare = Sim.Command.new()
	cope_flare.plant_kind = Catalog.FLARE
	cope_flare.tile = Vector2i(7, 4)
	cope.step(cope_flare)
	var cope_pea = Sim.Command.new()
	cope_pea.plant_kind = Catalog.PEA
	cope_pea.tile = Vector2i(8, 5)
	cope.step(cope_pea)
	var cope_hearth = Sim.Command.new()
	cope_hearth.plant_kind = Catalog.HEARTH
	cope_hearth.tile = Vector2i(5, 5)
	cope.step(cope_hearth)
	var cope_shear = Sim.Command.new()
	cope_shear.plant_kind = Catalog.SHEAR
	cope_shear.tile = Vector2i(7, 6)
	cope.step(cope_shear)
	var cope_chime = Sim.Command.new()
	cope_chime.plant_kind = Catalog.CHIME
	cope_chime.tile = Vector2i(8, 6)
	cope.step(cope_chime)
	var cope_rasp = Sim.Command.new()
	cope_rasp.plant_kind = Catalog.RASP
	cope_rasp.tile = Vector2i(9, 5)
	cope.step(cope_rasp)
	var cope_maul = Sim.Command.new()
	cope_maul.plant_kind = Catalog.MAUL
	cope_maul.tile = Vector2i(9, 6)
	cope.step(cope_maul)
	var cope_bill = Sim.Command.new()
	cope_bill.plant_kind = Catalog.BILL
	cope_bill.tile = Vector2i(8, 4)
	cope.step(cope_bill)
	var cope_shade = Sim.Command.new()
	cope_shade.plant_kind = Catalog.SHADE
	cope_shade.tile = Vector2i(6, 6)
	cope.step(cope_shade)
	var cope_cowl = Sim.Command.new()
	cope_cowl.plant_kind = Catalog.COWL
	cope_cowl.tile = Vector2i(7, 5)
	cope.step(cope_cowl)
	var cope_hood = Sim.Command.new()
	cope_hood.plant_kind = Catalog.HOOD
	cope_hood.tile = Vector2i(5, 6)
	cope.step(cope_hood)
	var sealed = cope.spawn_pest(cope.tile_center(7, 4), true, true, true, true, true, true, true, true, true, true, true, true, true)
	var sealed_id := int(sealed.id)
	_expect(cope.tile_burns_shroud(7, 4) and cope.tile_cracks_rind(7, 4) and cope.tile_melts_pitch(7, 4) and cope.tile_thaws_frost(7, 4) and cope.tile_cuts_web(7, 4) and cope.tile_cracks_glass(7, 4) and cope.tile_strips_scale(7, 4) and cope.tile_cracks_mail(7, 4) and cope.tile_splits_hide(7, 4) and cope.tile_shades_dusk(7, 4) and cope.tile_cowls_veil(7, 4) and cope.tile_hoods_pall(7, 4) and not cope.tile_cloaks_gloom(7, 4) and sealed.hidden, "every older lock leaves a gloom moth sealed")
	guard = 0
	var sealed_hit := false
	while guard < 20 and cope.outcome == Sim.OUTCOME_RUNNING:
		cope.step(idle)
		guard += 1
		for event in cope.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				sealed_hit = true
	var sealed_now = cope.pest_by_id(sealed_id)
	_expect(not sealed_hit and sealed_now != null and int(sealed_now.hp) == Sim.PEST_HP, "a cope moth ignores shots until every lock, including the cloak, is open")
	var cope_cloak = Sim.Command.new()
	cope_cloak.plant_kind = Catalog.CLOAK
	cope_cloak.tile = Vector2i(4, 6)
	cope.step(cope_cloak)
	var opened = cope.pest_by_id(sealed_id)
	_expect(opened != null and not opened.hidden, "cloak plus the older locks together reveal a cope moth")
	var outside = cope.spawn_pest(cope.tile_center(13, 9), false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(outside.hidden, "a gloom moth outside the cloak seals again")
	var opened_hit := false
	guard = 0
	while guard < 80 and cope.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		cope.step(idle)
		guard += 1
		for event in cope.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				opened_hit = true
	_expect(opened_hit, "the opened cope moth takes a hit")


func _test_twenty_eighth_nights() -> void:
	print("nights 28 and 29")
	_expect(Sim.START_SEEDS == 23, "the run starts with twenty-three seeds")
	_expect(Sim.WAVE_COUNT == 47 and Sim.WAVES.size() == 47, "forty-seven nights")
	_expect(int(Sim.WAVES[27]["count"]) == 10 and int(Sim.WAVES[27]["interval"]) == 72 and int(Sim.WAVES[27]["shroud_every"]) == 0 and int(Sim.WAVES[27]["rind_every"]) == 0 and int(Sim.WAVES[27]["pitch_every"]) == 0 and int(Sim.WAVES[27]["frost_every"]) == 0 and int(Sim.WAVES[27]["web_every"]) == 0 and int(Sim.WAVES[27]["glass_every"]) == 0 and int(Sim.WAVES[27]["scale_every"]) == 0 and int(Sim.WAVES[27]["mail_every"]) == 0 and int(Sim.WAVES[27]["hide_every"]) == 0 and int(Sim.WAVES[27]["dusk_every"]) == 0 and int(Sim.WAVES[27]["veil_every"]) == 0 and int(Sim.WAVES[27]["pall_every"]) == 0 and int(Sim.WAVES[27]["gloom_every"]) == 1 and int(Sim.WAVES[27].get("murk_every", 0)) == 0 and str(Sim.WAVES[27]["name"]) == "Gloom", "night 28 is all gloom")
	_expect(int(Sim.WAVES[28]["count"]) == 16 and int(Sim.WAVES[28]["interval"]) == 60 and int(Sim.WAVES[28]["shroud_every"]) == 2 and int(Sim.WAVES[28]["rind_every"]) == 1 and int(Sim.WAVES[28]["pitch_every"]) == 1 and int(Sim.WAVES[28]["frost_every"]) == 1 and int(Sim.WAVES[28]["web_every"]) == 1 and int(Sim.WAVES[28]["glass_every"]) == 1 and int(Sim.WAVES[28]["scale_every"]) == 1 and int(Sim.WAVES[28]["mail_every"]) == 1 and int(Sim.WAVES[28]["hide_every"]) == 1 and int(Sim.WAVES[28]["dusk_every"]) == 1 and int(Sim.WAVES[28]["veil_every"]) == 1 and int(Sim.WAVES[28]["pall_every"]) == 1 and int(Sim.WAVES[28]["gloom_every"]) == 1 and int(Sim.WAVES[28].get("murk_every", 0)) == 0 and str(Sim.WAVES[28]["name"]) == "Cope", "night 29 is gloom, pall, veil, dusk, hide, mail, scale, glass, web, frost, pitch, and rind, every second also a shroud, and no murk")
	for i in 27:
		_expect(int(Sim.WAVES[i].get("gloom_every", 0)) == 0, "night %d still spawns no gloom" % (i + 1))
	_expect(int(Sim.WAVES[25]["pall_every"]) == 1 and str(Sim.WAVES[25]["name"]) == "Pall" and int(Sim.WAVES[25]["count"]) == 10, "night 26 is still the pall wave")
	_expect(int(Sim.WAVES[26]["pall_every"]) == 1 and int(Sim.WAVES[26].get("gloom_every", 0)) == 0 and str(Sim.WAVES[26]["name"]) == "Mantle" and int(Sim.WAVES[26]["count"]) == 16, "night 27 is still the mantle wave and spawns no gloom")
	var named = Sim.new(1)
	named.wave = 28
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 28 of 47 (Gloom) — 0 pests left", "night 28 heading: %s" % named.phase_text())
	named.wave = 29
	_expect(named.phase_text() == "Night 29 of 47 (Cope) — 0 pests left", "night 29 heading: %s" % named.phase_text())
	named.wave = 27
	named.phase = Sim.PHASE_PLANT
	named.phase_ticks = 0
	_expect(named.phase_text().begins_with("Planting — night 28 (Gloom)"), "planting before gloom: %s" % named.phase_text())

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var missed := _play(run_seed, Callable(self, "_corner_cloak_command"))
		print("  corner cloak seed=%s outcome=%s night=%s hp=%s tick=%s gloom=%s/%s" % [run_seed, missed[0], missed[1], missed[4], missed[3], missed[33], missed[32]])
		_expect(int(missed[0]) == Sim.OUTCOME_LOST, "seed %s dies when the cloak misses the kill tiles" % run_seed)
		_expect(int(missed[1]) == 28, "seed %s dies on night 28 with a corner cloak (night %s)" % [run_seed, missed[1]])
		_expect(int(missed[4]) == 0, "seed %s health reached zero" % run_seed)
		_expect(int(missed[8]) == Sim.START_SEEDS - 14 and int(missed[9]) == 14, "seed %s planted the cloak and left the fifteenth seed unspent" % run_seed)
		_expect(int(missed[32]) > int(missed[33]), "seed %s left gloom moths uncloaked (%s spawned, %s killed)" % [run_seed, missed[32], missed[33]])
		_expect(int(missed[30]) == 26 and int(missed[31]) == 26, "seed %s had already hooded pall before the corner cloak failed (%s/%s)" % [run_seed, missed[31], missed[30]])
		var held := _play(run_seed, Callable(self, "_cloak_command"), 29)
		print("  cloak seed=%s outcome=%s night=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s/%s glasses=%s/%s scales=%s/%s mails=%s/%s hides=%s/%s dusk=%s/%s veil=%s/%s pall=%s/%s gloom=%s/%s murk=%s/%s" % [run_seed, held[0], held[1], held[4], held[3], held[7], held[6], held[11], held[10], held[13], held[12], held[15], held[14], held[17], held[16], held[19], held[18], held[21], held[20], held[23], held[22], held[25], held[24], held[27], held[26], held[29], held[28], held[31], held[30], held[33], held[32], held[35], held[34]])
		_expect(int(held[0]) == Sim.OUTCOME_RUNNING and int(held[2]) == Sim.PHASE_PLANT, "seed %s is still planting after night 29" % run_seed)
		_expect(int(held[1]) == 29, "seed %s cleared through night 29" % run_seed)
		_expect(int(held[4]) == 100, "seed %s finished night 29 at full health (%s)" % [run_seed, held[4]])
		_expect(int(held[6]) == 112 and int(held[7]) == 112, "seed %s burned every shroud moth (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 202 and int(held[11]) == 202, "seed %s cracked every rind moth (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 186 and int(held[13]) == 186, "seed %s melted every pitch moth (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 170 and int(held[15]) == 170, "seed %s thawed every frost moth (%s/%s)" % [run_seed, held[15], held[14]])
		_expect(int(held[16]) == 154 and int(held[17]) == 154, "seed %s cut every web moth (%s/%s)" % [run_seed, held[17], held[16]])
		_expect(int(held[18]) == 138 and int(held[19]) == 138, "seed %s cracked every glass moth (%s/%s)" % [run_seed, held[19], held[18]])
		_expect(int(held[20]) == 122 and int(held[21]) == 122, "seed %s stripped every scale moth (%s/%s)" % [run_seed, held[21], held[20]])
		_expect(int(held[22]) == 106 and int(held[23]) == 106, "seed %s cracked every mail moth (%s/%s)" % [run_seed, held[23], held[22]])
		_expect(int(held[24]) == 90 and int(held[25]) == 90, "seed %s split every hide moth (%s/%s)" % [run_seed, held[25], held[24]])
		_expect(int(held[26]) == 74 and int(held[27]) == 74, "seed %s shaded every dusk moth (%s/%s)" % [run_seed, held[27], held[26]])
		_expect(int(held[28]) == 58 and int(held[29]) == 58, "seed %s cowled every veil moth (%s/%s)" % [run_seed, held[29], held[28]])
		_expect(int(held[30]) == 42 and int(held[31]) == 42, "seed %s hooded every pall moth (%s/%s)" % [run_seed, held[31], held[30]])
		_expect(int(held[32]) == 26 and int(held[33]) == 26, "seed %s cloaked every gloom moth (%s/%s)" % [run_seed, held[33], held[32]])
		_expect(int(held[34]) == 0 and int(held[35]) == 0, "seed %s meets no murk moth before night 30" % run_seed)
		_expect(int(held[8]) == Sim.START_SEEDS - 14 and int(held[9]) == 14, "seed %s spent fourteen seeds and left the fifteenth unspent" % run_seed)
		var layout := _cloak_garden_layout(run_seed)
		_expect(not bool(layout["lantern"]), "seed %s left the lantern unplanted" % run_seed)
		_expect(layout["shade"] == Vector2i(6, 6), "seed %s kept the shade at (6, 6)" % run_seed)
		_expect(layout["cowl"] == Vector2i(7, 5), "seed %s kept the cowl at (7, 5)" % run_seed)
		_expect(layout["hood"] == Vector2i(5, 6), "seed %s kept the hood at (5, 6)" % run_seed)
		_expect(layout["cloak"] == Vector2i(4, 6), "seed %s planted the cloak at (4, 6)" % run_seed)
		_expect(not bool(layout["cape"]), "seed %s left the cape unplanted" % run_seed)
		var fell := _play(run_seed, Callable(self, "_cloak_command"))
		print("  unspent cape seed=%s outcome=%s night=%s hp=%s murk=%s/%s" % [run_seed, fell[0], fell[1], fell[4], fell[35], fell[34]])
		_expect(int(fell[0]) == Sim.OUTCOME_LOST, "seed %s dies when the fifteenth seed stays unspent" % run_seed)
		_expect(int(fell[1]) == 30, "seed %s dies on the murk night (night %s)" % [run_seed, fell[1]])
		_expect(int(fell[4]) == 0, "seed %s health reached zero on the murk night" % run_seed)
		_expect(int(fell[34]) > 0 and int(fell[35]) == 0, "seed %s left every murk moth uncaped (%s spawned, %s killed)" % [run_seed, fell[34], fell[35]])
		_expect(int(fell[32]) == 26 and int(fell[33]) == 26, "seed %s had already cloaked the gloom nights before murk (%s/%s)" % [run_seed, fell[33], fell[32]])
		_expect(int(fell[8]) == Sim.START_SEEDS - 14 and int(fell[9]) == 14, "seed %s still has the fifteenth seed unspent when the murk arrives" % run_seed)
	var again := _play(42, Callable(self, "_cloak_command"), 29)
	var replay := _play(42, Callable(self, "_cloak_command"), 29)
	_expect(str(again) == str(replay), "same seed and cloak plan replay through night 29")


func _cloak_garden_layout(seed_value: int) -> Dictionary:
	var sim = Sim.new(seed_value)
	var guard := 0
	while sim.phase == Sim.PHASE_PLANT and sim.outcome == Sim.OUTCOME_RUNNING and guard < 400:
		sim.step(_cloak_command(sim))
		guard += 1
	return {
		"lantern": sim.has_plant(Catalog.LANTERN),
		"shade": _plant_cell(sim, Catalog.SHADE),
		"cowl": _plant_cell(sim, Catalog.COWL),
		"hood": _plant_cell(sim, Catalog.HOOD),
		"cloak": _plant_cell(sim, Catalog.CLOAK),
		"cape": sim.has_plant(Catalog.CAPE),
	}


func _plant_cell(sim, kind: int) -> Vector2i:
	var plant = sim.plant_of_kind(kind)
	if plant == null:
		return Vector2i(-1, -1)
	return plant.cell


func _test_murk_rule() -> void:
	print("cape murk rule")
	var placed = Sim.new(4)
	placed.seeds = 18
	var wick = Sim.Command.new()
	wick.plant_kind = Catalog.WICK
	wick.tile = Vector2i(6, 5)
	placed.step(wick)
	var briar = Sim.Command.new()
	briar.plant_kind = Catalog.BRIAR
	briar.tile = Vector2i(6, 4)
	placed.step(briar)
	var flare = Sim.Command.new()
	flare.plant_kind = Catalog.FLARE
	flare.tile = Vector2i(7, 4)
	placed.step(flare)
	var hearth = Sim.Command.new()
	hearth.plant_kind = Catalog.HEARTH
	hearth.tile = Vector2i(5, 5)
	placed.step(hearth)
	var shear = Sim.Command.new()
	shear.plant_kind = Catalog.SHEAR
	shear.tile = Vector2i(7, 6)
	placed.step(shear)
	var chime = Sim.Command.new()
	chime.plant_kind = Catalog.CHIME
	chime.tile = Vector2i(8, 6)
	placed.step(chime)
	var rasp = Sim.Command.new()
	rasp.plant_kind = Catalog.RASP
	rasp.tile = Vector2i(9, 5)
	placed.step(rasp)
	var maul = Sim.Command.new()
	maul.plant_kind = Catalog.MAUL
	maul.tile = Vector2i(9, 6)
	placed.step(maul)
	var bill = Sim.Command.new()
	bill.plant_kind = Catalog.BILL
	bill.tile = Vector2i(8, 4)
	placed.step(bill)
	var shade = Sim.Command.new()
	shade.plant_kind = Catalog.SHADE
	shade.tile = Vector2i(6, 6)
	placed.step(shade)
	var cowl = Sim.Command.new()
	cowl.plant_kind = Catalog.COWL
	cowl.tile = Vector2i(7, 5)
	placed.step(cowl)
	var hood = Sim.Command.new()
	hood.plant_kind = Catalog.HOOD
	hood.tile = Vector2i(5, 6)
	placed.step(hood)
	var cloak = Sim.Command.new()
	cloak.plant_kind = Catalog.CLOAK
	cloak.tile = Vector2i(4, 6)
	placed.step(cloak)
	var idle = Sim.Command.new()
	placed.step(idle)
	_expect(placed.tile_cloaks_gloom(7, 5) and placed.tile_hoods_pall(7, 5) and placed.tile_cowls_veil(7, 5) and placed.tile_shades_dusk(7, 5) and placed.tile_lit(7, 5), "the night-29 garden still cloaks, hoods, cowls, shades, and lights the gardener")
	_expect(not placed.tile_capes_murk(7, 5) and not placed.tile_capes_murk(4, 6) and not placed.tile_capes_murk(5, 6) and not placed.tile_capes_murk(6, 6), "a cloak, a hood, a cowl, and a shade do not cape the gardener, the cloak, the hood, or the shade")
	var corner = Sim.Command.new()
	corner.plant_kind = Catalog.CAPE
	corner.tile = Vector2i(1, 1)
	placed.step(corner)
	_expect(not placed.tile_capes_murk(7, 5), "a corner cape does not cape the gardener tile")
	_expect(placed.tile_capes_murk(1, 1), "a cape on its own tile capes it")
	_expect(not placed.tile_lit(1, 1), "a cape does not light its own tile")
	var beside = Sim.Command.new()
	beside.plant_kind = Catalog.CAPE
	beside.tile = Vector2i(3, 6)
	placed.step(beside)
	_expect(placed.tile_capes_murk(7, 5) and placed.tile_capes_murk(6, 6) and placed.tile_capes_murk(5, 5) and placed.tile_capes_murk(8, 5), "the winning cape covers the gardener, the shade, the hearth, and the pea")
	_expect(placed.tile_capes_murk(7, 4) and placed.tile_capes_murk(6, 5) and placed.tile_capes_murk(8, 4) and placed.tile_capes_murk(5, 6) and placed.tile_capes_murk(4, 6), "that cape also covers the flare, the wick, the bill, the hood, and the cloak")
	_expect(not placed.tile_capes_murk(13, 9), "the winning cape leaves the far orchard edge sealed")
	var cape_plant = placed.plant_of_kind(Catalog.CAPE)
	_expect(cape_plant != null and cape_plant.capes_murk and not cape_plant.casts_light and not cape_plant.cloaks_gloom and not cape_plant.hoods_pall and not cape_plant.cowls_veil and not cape_plant.shades_dusk and not cape_plant.splits_hide and not cape_plant.burns_shroud and not cape_plant.cracks_rind and not cape_plant.melts_pitch and not cape_plant.thaws_frost and not cape_plant.cuts_web and not cape_plant.cracks_glass and not cape_plant.strips_scale and not cape_plant.cracks_mail, "the cape capes murk and does not light, cloak, hood, cowl, shade, split, burn, crack rind, melt, thaw, cut web, crack glass, strip scale, or crack mail")
	_expect(not placed.plant_of_kind(Catalog.CLOAK).capes_murk, "the cloak does not cape murk")
	_expect(not placed.plant_of_kind(Catalog.HOOD).capes_murk, "the hood does not cape murk")
	_expect(not placed.plant_of_kind(Catalog.COWL).capes_murk, "the cowl does not cape murk")
	_expect(not placed.plant_of_kind(Catalog.SHADE).capes_murk, "the shade does not cape murk")
	_expect(not placed.plant_of_kind(Catalog.BILL).capes_murk, "the bill does not cape murk")
	_expect(not placed.plant_of_kind(Catalog.WICK).capes_murk, "the wick does not cape murk")

	var sim = Sim.new(6)
	var sow_cloak = Sim.Command.new()
	sow_cloak.plant_kind = Catalog.CLOAK
	sow_cloak.tile = Vector2i(4, 6)
	sim.step(sow_cloak)
	var sow_hood = Sim.Command.new()
	sow_hood.plant_kind = Catalog.HOOD
	sow_hood.tile = Vector2i(5, 6)
	sim.step(sow_hood)
	var sow_cowl = Sim.Command.new()
	sow_cowl.plant_kind = Catalog.COWL
	sow_cowl.tile = Vector2i(7, 5)
	sim.step(sow_cowl)
	var sow_shade = Sim.Command.new()
	sow_shade.plant_kind = Catalog.SHADE
	sow_shade.tile = Vector2i(6, 6)
	sim.step(sow_shade)
	var sow_pea = Sim.Command.new()
	sow_pea.plant_kind = Catalog.PEA
	sow_pea.tile = Vector2i(8, 5)
	sim.step(sow_pea)
	var murk = sim.spawn_pest(sim.tile_center(7, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var gloom = sim.spawn_pest(sim.tile_center(4, 6), false, false, false, false, false, false, false, false, false, false, false, false, true)
	var pall = sim.spawn_pest(sim.tile_center(5, 6), false, false, false, false, false, false, false, false, false, false, false, true, false)
	var veil = sim.spawn_pest(sim.tile_center(7, 5), false, false, false, false, false, false, false, false, false, false, true, false, false)
	var dusk = sim.spawn_pest(sim.tile_center(6, 6), false, false, false, false, false, false, false, false, false, true, false, false, false)
	var murk_id := int(murk.id)
	var gloom_id := int(gloom.id)
	_expect(sim.tile_cloaks_gloom(4, 6) and sim.tile_hoods_pall(5, 6) and sim.tile_cowls_veil(7, 5) and sim.tile_shades_dusk(6, 6) and not sim.tile_capes_murk(7, 5) and murk.hidden and not gloom.hidden and not pall.hidden and not veil.hidden and not dusk.hidden, "cloak opens gloom, hood opens pall, cowl opens veil, and shade opens dusk while the murk moth stays sealed")
	var murk_hit := false
	var gloom_hit := false
	var guard := 0
	while guard < 80 and sim.outcome == Sim.OUTCOME_RUNNING:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == murk_id:
				murk_hit = true
			if int(event["pest_id"]) == gloom_id:
				gloom_hit = true
	var murk_now = sim.pest_by_id(murk_id)
	_expect(gloom_hit, "a cloak still lets a gloom moth take damage")
	_expect(not murk_hit and murk_now != null and int(murk_now.hp) == Sim.PEST_HP, "a cloak, a hood, a cowl, and a shade do not damage a murk moth")

	var only = Sim.new(5)
	var sow_cape = Sim.Command.new()
	sow_cape.plant_kind = Catalog.CAPE
	sow_cape.tile = Vector2i(3, 6)
	only.step(sow_cape)
	var sealed_gloom = only.spawn_pest(only.tile_center(3, 6), false, false, false, false, false, false, false, false, false, false, false, false, true)
	var sealed_pall = only.spawn_pest(only.tile_center(3, 6), false, false, false, false, false, false, false, false, false, false, false, true, false)
	var sealed_veil = only.spawn_pest(only.tile_center(3, 6), false, false, false, false, false, false, false, false, false, false, true, false, false)
	var sealed_dusk = only.spawn_pest(only.tile_center(3, 6), false, false, false, false, false, false, false, false, false, true, false, false, false)
	var sealed_hide = only.spawn_pest(only.tile_center(3, 6), false, false, false, false, false, false, false, false, true, false, false, false, false)
	var opened_murk = only.spawn_pest(only.tile_center(3, 6), false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var plain = only.spawn_pest(only.tile_center(3, 6), false, false, false, false, false, false, false, false, false, false, false, false, false)
	_expect(only.tile_capes_murk(3, 6) and only.tile_capes_murk(4, 6) and not only.tile_lit(3, 6) and not only.tile_cloaks_gloom(3, 6) and not only.tile_hoods_pall(3, 6) and not only.tile_cowls_veil(3, 6) and not only.tile_shades_dusk(3, 6), "cape marks the tile without lighting it, cloaking gloom, hooding pall, cowling veil, or shading dusk")
	_expect(sealed_gloom.hidden, "a cape does not reveal a gloom moth")
	_expect(sealed_pall.hidden, "a cape does not reveal a pall moth")
	_expect(sealed_veil.hidden, "a cape does not reveal a veil moth")
	_expect(sealed_dusk.hidden, "a cape does not reveal a dusk moth")
	_expect(sealed_hide.hidden, "a cape does not reveal a hide")
	_expect(not opened_murk.hidden, "a cape reveals a murk moth on its tile")
	_expect(plain.hidden, "an ordinary moth stays hidden in a cape with no light")
	var cape_hit := false
	var gloom_hurt := false
	var pall_hurt := false
	var veil_hurt := false
	var dusk_hurt := false
	var hide_hurt := false
	guard = 0
	while guard < 120 and only.outcome == Sim.OUTCOME_RUNNING and not cape_hit:
		only.step(idle)
		guard += 1
		for event in only.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == int(opened_murk.id):
				cape_hit = true
			if int(event["pest_id"]) == int(sealed_gloom.id):
				gloom_hurt = true
			if int(event["pest_id"]) == int(sealed_pall.id):
				pall_hurt = true
			if int(event["pest_id"]) == int(sealed_veil.id):
				veil_hurt = true
			if int(event["pest_id"]) == int(sealed_dusk.id):
				dusk_hurt = true
			if int(event["pest_id"]) == int(sealed_hide.id):
				hide_hurt = true
	var gloom_left = only.pest_by_id(int(sealed_gloom.id))
	var pall_left = only.pest_by_id(int(sealed_pall.id))
	var veil_left = only.pest_by_id(int(sealed_veil.id))
	var dusk_left = only.pest_by_id(int(sealed_dusk.id))
	var hide_left = only.pest_by_id(int(sealed_hide.id))
	_expect(cape_hit, "the revealed murk moth takes a hit")
	_expect(not gloom_hurt and gloom_left != null and int(gloom_left.hp) == Sim.PEST_HP, "shots do not hurt a gloom moth standing in a cape")
	_expect(not pall_hurt and pall_left != null and int(pall_left.hp) == Sim.PEST_HP, "shots do not hurt a pall moth standing in a cape")
	_expect(not veil_hurt and veil_left != null and int(veil_left.hp) == Sim.PEST_HP, "shots do not hurt a veil moth standing in a cape")
	_expect(not dusk_hurt and dusk_left != null and int(dusk_left.hp) == Sim.PEST_HP, "shots do not hurt a dusk moth standing in a cape")
	_expect(not hide_hurt and hide_left != null and int(hide_left.hp) == Sim.PEST_HP, "shots do not hurt a hide standing in a cape")

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	splash.step(sow_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, false, false, false, false, false)
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the murk moth")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a murk moth outside a cape")

	var fell = Sim.new(9)
	fell.seeds = 18
	var fell_wick = Sim.Command.new()
	fell_wick.plant_kind = Catalog.WICK
	fell_wick.tile = Vector2i(6, 5)
	fell.step(fell_wick)
	var fell_briar = Sim.Command.new()
	fell_briar.plant_kind = Catalog.BRIAR
	fell_briar.tile = Vector2i(6, 4)
	fell.step(fell_briar)
	var fell_flare = Sim.Command.new()
	fell_flare.plant_kind = Catalog.FLARE
	fell_flare.tile = Vector2i(7, 4)
	fell.step(fell_flare)
	var fell_pea = Sim.Command.new()
	fell_pea.plant_kind = Catalog.PEA
	fell_pea.tile = Vector2i(8, 5)
	fell.step(fell_pea)
	var fell_hearth = Sim.Command.new()
	fell_hearth.plant_kind = Catalog.HEARTH
	fell_hearth.tile = Vector2i(5, 5)
	fell.step(fell_hearth)
	var fell_shear = Sim.Command.new()
	fell_shear.plant_kind = Catalog.SHEAR
	fell_shear.tile = Vector2i(7, 6)
	fell.step(fell_shear)
	var fell_chime = Sim.Command.new()
	fell_chime.plant_kind = Catalog.CHIME
	fell_chime.tile = Vector2i(8, 6)
	fell.step(fell_chime)
	var fell_rasp = Sim.Command.new()
	fell_rasp.plant_kind = Catalog.RASP
	fell_rasp.tile = Vector2i(9, 5)
	fell.step(fell_rasp)
	var fell_maul = Sim.Command.new()
	fell_maul.plant_kind = Catalog.MAUL
	fell_maul.tile = Vector2i(9, 6)
	fell.step(fell_maul)
	var fell_bill = Sim.Command.new()
	fell_bill.plant_kind = Catalog.BILL
	fell_bill.tile = Vector2i(8, 4)
	fell.step(fell_bill)
	var fell_shade = Sim.Command.new()
	fell_shade.plant_kind = Catalog.SHADE
	fell_shade.tile = Vector2i(6, 6)
	fell.step(fell_shade)
	var fell_cowl = Sim.Command.new()
	fell_cowl.plant_kind = Catalog.COWL
	fell_cowl.tile = Vector2i(7, 5)
	fell.step(fell_cowl)
	var fell_hood = Sim.Command.new()
	fell_hood.plant_kind = Catalog.HOOD
	fell_hood.tile = Vector2i(5, 6)
	fell.step(fell_hood)
	var fell_cloak = Sim.Command.new()
	fell_cloak.plant_kind = Catalog.CLOAK
	fell_cloak.tile = Vector2i(4, 6)
	fell.step(fell_cloak)
	var sealed = fell.spawn_pest(fell.tile_center(7, 4), true, true, true, true, true, true, true, true, true, true, true, true, true, true)
	var sealed_id := int(sealed.id)
	_expect(fell.tile_burns_shroud(7, 4) and fell.tile_cracks_rind(7, 4) and fell.tile_melts_pitch(7, 4) and fell.tile_thaws_frost(7, 4) and fell.tile_cuts_web(7, 4) and fell.tile_cracks_glass(7, 4) and fell.tile_strips_scale(7, 4) and fell.tile_cracks_mail(7, 4) and fell.tile_splits_hide(7, 4) and fell.tile_shades_dusk(7, 4) and fell.tile_cowls_veil(7, 4) and fell.tile_hoods_pall(7, 4) and fell.tile_cloaks_gloom(7, 4) and not fell.tile_capes_murk(7, 4) and sealed.hidden, "every older lock leaves a murk moth sealed")
	guard = 0
	var sealed_hit := false
	while guard < 20 and fell.outcome == Sim.OUTCOME_RUNNING:
		fell.step(idle)
		guard += 1
		for event in fell.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				sealed_hit = true
	var sealed_now = fell.pest_by_id(sealed_id)
	_expect(not sealed_hit and sealed_now != null and int(sealed_now.hp) == Sim.PEST_HP, "a fell moth ignores shots until every lock, including the cape, is open")
	var fell_cape = Sim.Command.new()
	fell_cape.plant_kind = Catalog.CAPE
	fell_cape.tile = Vector2i(3, 6)
	fell.step(fell_cape)
	var opened = fell.pest_by_id(sealed_id)
	_expect(opened != null and not opened.hidden, "cape plus the older locks together reveal a fell moth")
	var outside = fell.spawn_pest(fell.tile_center(13, 9), false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(outside.hidden, "a murk moth outside the cape seals again")
	var opened_hit := false
	guard = 0
	while guard < 80 and fell.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		fell.step(idle)
		guard += 1
		for event in fell.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				opened_hit = true
	_expect(opened_hit, "the opened fell moth takes a hit")


func _test_thirtieth_nights() -> void:
	print("nights 30 and 31")
	_expect(Sim.START_SEEDS == 23, "the run starts with twenty-three seeds")
	_expect(Sim.WAVE_COUNT == 47 and Sim.WAVES.size() == 47, "forty-seven nights")
	_expect(int(Sim.WAVES[29]["count"]) == 10 and int(Sim.WAVES[29]["interval"]) == 72 and int(Sim.WAVES[29]["shroud_every"]) == 0 and int(Sim.WAVES[29]["rind_every"]) == 0 and int(Sim.WAVES[29]["pitch_every"]) == 0 and int(Sim.WAVES[29]["frost_every"]) == 0 and int(Sim.WAVES[29]["web_every"]) == 0 and int(Sim.WAVES[29]["glass_every"]) == 0 and int(Sim.WAVES[29]["scale_every"]) == 0 and int(Sim.WAVES[29]["mail_every"]) == 0 and int(Sim.WAVES[29]["hide_every"]) == 0 and int(Sim.WAVES[29]["dusk_every"]) == 0 and int(Sim.WAVES[29]["veil_every"]) == 0 and int(Sim.WAVES[29]["pall_every"]) == 0 and int(Sim.WAVES[29]["gloom_every"]) == 0 and int(Sim.WAVES[29]["murk_every"]) == 1 and str(Sim.WAVES[29]["name"]) == "Murk", "night 30 is all murk")
	_expect(int(Sim.WAVES[30]["count"]) == 16 and int(Sim.WAVES[30]["interval"]) == 60 and int(Sim.WAVES[30]["shroud_every"]) == 2 and int(Sim.WAVES[30]["rind_every"]) == 1 and int(Sim.WAVES[30]["pitch_every"]) == 1 and int(Sim.WAVES[30]["frost_every"]) == 1 and int(Sim.WAVES[30]["web_every"]) == 1 and int(Sim.WAVES[30]["glass_every"]) == 1 and int(Sim.WAVES[30]["scale_every"]) == 1 and int(Sim.WAVES[30]["mail_every"]) == 1 and int(Sim.WAVES[30]["hide_every"]) == 1 and int(Sim.WAVES[30]["dusk_every"]) == 1 and int(Sim.WAVES[30]["veil_every"]) == 1 and int(Sim.WAVES[30]["pall_every"]) == 1 and int(Sim.WAVES[30]["gloom_every"]) == 1 and int(Sim.WAVES[30]["murk_every"]) == 1 and int(Sim.WAVES[30].get("dread_every", 0)) == 0 and str(Sim.WAVES[30]["name"]) == "Fell", "night 31 is still Fell: murk, gloom, pall, veil, dusk, hide, mail, scale, glass, web, frost, pitch, and rind, every second also a shroud, and no dread")
	for i in 29:
		_expect(int(Sim.WAVES[i].get("murk_every", 0)) == 0, "night %d still spawns no murk" % (i + 1))
	_expect(int(Sim.WAVES[27]["gloom_every"]) == 1 and str(Sim.WAVES[27]["name"]) == "Gloom" and int(Sim.WAVES[27]["count"]) == 10, "night 28 is still the gloom wave")
	_expect(int(Sim.WAVES[28]["gloom_every"]) == 1 and int(Sim.WAVES[28].get("murk_every", 0)) == 0 and str(Sim.WAVES[28]["name"]) == "Cope" and int(Sim.WAVES[28]["count"]) == 16, "night 29 is still the cope wave and spawns no murk")
	_expect(int(Sim.WAVES[26]["pall_every"]) == 1 and int(Sim.WAVES[26].get("murk_every", 0)) == 0 and str(Sim.WAVES[26]["name"]) == "Mantle" and int(Sim.WAVES[26]["count"]) == 16, "night 27 is still the mantle wave and spawns no murk")
	var named = Sim.new(1)
	named.wave = 30
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 30 of 47 (Murk) — 0 pests left", "night 30 heading: %s" % named.phase_text())
	named.wave = 31
	_expect(named.phase_text() == "Night 31 of 47 (Fell) — 0 pests left", "night 31 heading: %s" % named.phase_text())
	named.wave = 29
	named.phase = Sim.PHASE_PLANT
	named.phase_ticks = 0
	_expect(named.phase_text().begins_with("Planting — night 30 (Murk)"), "planting before murk: %s" % named.phase_text())

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var missed := _play(run_seed, Callable(self, "_corner_cape_command"))
		print("  corner cape seed=%s outcome=%s night=%s hp=%s tick=%s murk=%s/%s" % [run_seed, missed[0], missed[1], missed[4], missed[3], missed[35], missed[34]])
		_expect(int(missed[0]) == Sim.OUTCOME_LOST, "seed %s dies when the cape misses the kill tiles" % run_seed)
		_expect(int(missed[1]) == 30, "seed %s dies on night 30 with a corner cape (night %s)" % [run_seed, missed[1]])
		_expect(int(missed[4]) == 0, "seed %s health reached zero" % run_seed)
		_expect(int(missed[8]) == Sim.START_SEEDS - 15 and int(missed[9]) == 15, "seed %s planted the cape, just not where the night arrives" % run_seed)
		_expect(int(missed[34]) > int(missed[35]), "seed %s left murk moths uncaped (%s spawned, %s killed)" % [run_seed, missed[34], missed[35]])
		_expect(int(missed[32]) == 26 and int(missed[33]) == 26, "seed %s had already cloaked gloom before the corner cape failed (%s/%s)" % [run_seed, missed[33], missed[32]])
		var held := _play(run_seed, Callable(self, "_cape_command"), 31)
		print("  cape seed=%s outcome=%s night=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s/%s glasses=%s/%s scales=%s/%s mails=%s/%s hides=%s/%s dusk=%s/%s veil=%s/%s pall=%s/%s gloom=%s/%s murk=%s/%s dread=%s/%s" % [run_seed, held[0], held[1], held[4], held[3], held[7], held[6], held[11], held[10], held[13], held[12], held[15], held[14], held[17], held[16], held[19], held[18], held[21], held[20], held[23], held[22], held[25], held[24], held[27], held[26], held[29], held[28], held[31], held[30], held[33], held[32], held[35], held[34], held[37], held[36]])
		_expect(int(held[0]) == Sim.OUTCOME_RUNNING and int(held[2]) == Sim.PHASE_PLANT, "seed %s is still planting after night 31" % run_seed)
		_expect(int(held[1]) == 31, "seed %s cleared through night 31" % run_seed)
		_expect(int(held[4]) == 100, "seed %s finished night 31 at full health (%s)" % [run_seed, held[4]])
		_expect(int(held[6]) == 120 and int(held[7]) == 120, "seed %s burned every shroud moth (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 218 and int(held[11]) == 218, "seed %s cracked every rind moth (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 202 and int(held[13]) == 202, "seed %s melted every pitch moth (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 186 and int(held[15]) == 186, "seed %s thawed every frost moth (%s/%s)" % [run_seed, held[15], held[14]])
		_expect(int(held[16]) == 170 and int(held[17]) == 170, "seed %s cut every web moth (%s/%s)" % [run_seed, held[17], held[16]])
		_expect(int(held[18]) == 154 and int(held[19]) == 154, "seed %s cracked every glass moth (%s/%s)" % [run_seed, held[19], held[18]])
		_expect(int(held[20]) == 138 and int(held[21]) == 138, "seed %s stripped every scale moth (%s/%s)" % [run_seed, held[21], held[20]])
		_expect(int(held[22]) == 122 and int(held[23]) == 122, "seed %s cracked every mail moth (%s/%s)" % [run_seed, held[23], held[22]])
		_expect(int(held[24]) == 106 and int(held[25]) == 106, "seed %s split every hide moth (%s/%s)" % [run_seed, held[25], held[24]])
		_expect(int(held[26]) == 90 and int(held[27]) == 90, "seed %s shaded every dusk moth (%s/%s)" % [run_seed, held[27], held[26]])
		_expect(int(held[28]) == 74 and int(held[29]) == 74, "seed %s cowled every veil moth (%s/%s)" % [run_seed, held[29], held[28]])
		_expect(int(held[30]) == 58 and int(held[31]) == 58, "seed %s hooded every pall moth (%s/%s)" % [run_seed, held[31], held[30]])
		_expect(int(held[32]) == 42 and int(held[33]) == 42, "seed %s cloaked every gloom moth (%s/%s)" % [run_seed, held[33], held[32]])
		_expect(int(held[34]) == 26 and int(held[35]) == 26, "seed %s caped every murk moth (%s/%s)" % [run_seed, held[35], held[34]])
		_expect(int(held[36]) == 0 and int(held[37]) == 0, "seed %s meets no dread moth before night 32" % run_seed)
		_expect(int(held[8]) == Sim.START_SEEDS - 15 and int(held[9]) == 15, "seed %s spent fifteen seeds and left the sixteenth unspent" % run_seed)
		var layout := _cape_garden_layout(run_seed)
		_expect(not bool(layout["lantern"]), "seed %s left the lantern unplanted" % run_seed)
		_expect(layout["shade"] == Vector2i(6, 6), "seed %s kept the shade at (6, 6)" % run_seed)
		_expect(layout["cowl"] == Vector2i(7, 5), "seed %s kept the cowl at (7, 5)" % run_seed)
		_expect(layout["hood"] == Vector2i(5, 6), "seed %s kept the hood at (5, 6)" % run_seed)
		_expect(layout["cloak"] == Vector2i(4, 6), "seed %s kept the cloak at (4, 6)" % run_seed)
		_expect(layout["cape"] == Vector2i(3, 6), "seed %s planted the cape at (3, 6)" % run_seed)
		_expect(not bool(layout["shawl"]), "seed %s left the shawl unplanted" % run_seed)
		var dread_night := _play(run_seed, Callable(self, "_cape_command"))
		print("  unspent shawl seed=%s outcome=%s night=%s hp=%s dread=%s/%s" % [run_seed, dread_night[0], dread_night[1], dread_night[4], dread_night[37], dread_night[36]])
		_expect(int(dread_night[0]) == Sim.OUTCOME_LOST, "seed %s dies when the sixteenth seed stays unspent" % run_seed)
		_expect(int(dread_night[1]) == 32, "seed %s dies on the dread night (night %s)" % [run_seed, dread_night[1]])
		_expect(int(dread_night[4]) == 0, "seed %s health reached zero on the dread night" % run_seed)
		_expect(int(dread_night[36]) > 0 and int(dread_night[37]) == 0, "seed %s left every dread moth unshawled (%s spawned, %s killed)" % [run_seed, dread_night[36], dread_night[37]])
		_expect(int(dread_night[34]) == 26 and int(dread_night[35]) == 26, "seed %s had already caped the murk nights before dread (%s/%s)" % [run_seed, dread_night[35], dread_night[34]])
		_expect(int(dread_night[8]) == Sim.START_SEEDS - 15 and int(dread_night[9]) == 15, "seed %s still has the sixteenth seed unspent when the dread arrives" % run_seed)
	var again := _play(42, Callable(self, "_cape_command"), 31)
	var replay := _play(42, Callable(self, "_cape_command"), 31)
	_expect(str(again) == str(replay), "same seed and cape plan replay through night 31")


func _cape_garden_layout(seed_value: int) -> Dictionary:
	var sim = Sim.new(seed_value)
	var guard := 0
	while sim.phase == Sim.PHASE_PLANT and sim.outcome == Sim.OUTCOME_RUNNING and guard < 400:
		sim.step(_cape_command(sim))
		guard += 1
	return {
		"lantern": sim.has_plant(Catalog.LANTERN),
		"shade": _plant_cell(sim, Catalog.SHADE),
		"cowl": _plant_cell(sim, Catalog.COWL),
		"hood": _plant_cell(sim, Catalog.HOOD),
		"cloak": _plant_cell(sim, Catalog.CLOAK),
		"cape": _plant_cell(sim, Catalog.CAPE),
		"shawl": sim.has_plant(Catalog.SHAWL),
	}


func _test_dread_rule() -> void:
	print("shawl dread rule")
	var placed = Sim.new(4)
	placed.seeds = 20
	var wick = Sim.Command.new()
	wick.plant_kind = Catalog.WICK
	wick.tile = Vector2i(6, 5)
	placed.step(wick)
	var briar = Sim.Command.new()
	briar.plant_kind = Catalog.BRIAR
	briar.tile = Vector2i(6, 4)
	placed.step(briar)
	var flare = Sim.Command.new()
	flare.plant_kind = Catalog.FLARE
	flare.tile = Vector2i(7, 4)
	placed.step(flare)
	var hearth = Sim.Command.new()
	hearth.plant_kind = Catalog.HEARTH
	hearth.tile = Vector2i(5, 5)
	placed.step(hearth)
	var shear = Sim.Command.new()
	shear.plant_kind = Catalog.SHEAR
	shear.tile = Vector2i(7, 6)
	placed.step(shear)
	var chime = Sim.Command.new()
	chime.plant_kind = Catalog.CHIME
	chime.tile = Vector2i(8, 6)
	placed.step(chime)
	var rasp = Sim.Command.new()
	rasp.plant_kind = Catalog.RASP
	rasp.tile = Vector2i(9, 5)
	placed.step(rasp)
	var maul = Sim.Command.new()
	maul.plant_kind = Catalog.MAUL
	maul.tile = Vector2i(9, 6)
	placed.step(maul)
	var bill = Sim.Command.new()
	bill.plant_kind = Catalog.BILL
	bill.tile = Vector2i(8, 4)
	placed.step(bill)
	var shade = Sim.Command.new()
	shade.plant_kind = Catalog.SHADE
	shade.tile = Vector2i(6, 6)
	placed.step(shade)
	var cowl = Sim.Command.new()
	cowl.plant_kind = Catalog.COWL
	cowl.tile = Vector2i(7, 5)
	placed.step(cowl)
	var hood = Sim.Command.new()
	hood.plant_kind = Catalog.HOOD
	hood.tile = Vector2i(5, 6)
	placed.step(hood)
	var cloak = Sim.Command.new()
	cloak.plant_kind = Catalog.CLOAK
	cloak.tile = Vector2i(4, 6)
	placed.step(cloak)
	var cape = Sim.Command.new()
	cape.plant_kind = Catalog.CAPE
	cape.tile = Vector2i(3, 6)
	placed.step(cape)
	var idle = Sim.Command.new()
	placed.step(idle)
	_expect(placed.tile_capes_murk(7, 5) and placed.tile_cloaks_gloom(7, 5) and placed.tile_hoods_pall(7, 5) and placed.tile_cowls_veil(7, 5) and placed.tile_shades_dusk(7, 5) and placed.tile_lit(7, 5), "the night-31 garden still capes, cloaks, hoods, cowls, shades, and lights the gardener")
	_expect(not placed.tile_shawls_dread(7, 5) and not placed.tile_shawls_dread(3, 6) and not placed.tile_shawls_dread(4, 6) and not placed.tile_shawls_dread(5, 6), "a cape, a cloak, a hood, and a shade do not shawl the gardener, the cape, the cloak, or the hood")
	var corner = Sim.Command.new()
	corner.plant_kind = Catalog.SHAWL
	corner.tile = Vector2i(1, 1)
	placed.step(corner)
	_expect(not placed.tile_shawls_dread(7, 5), "a corner shawl does not shawl the gardener tile")
	_expect(placed.tile_shawls_dread(1, 1), "a shawl on its own tile shawls it")
	_expect(not placed.tile_lit(1, 1), "a shawl does not light its own tile")
	var beside = Sim.Command.new()
	beside.plant_kind = Catalog.SHAWL
	beside.tile = Vector2i(2, 6)
	placed.step(beside)
	_expect(placed.tile_shawls_dread(7, 5) and placed.tile_shawls_dread(6, 6) and placed.tile_shawls_dread(5, 5) and placed.tile_shawls_dread(8, 5), "the winning shawl covers the gardener, the shade, the hearth, and the pea")
	_expect(placed.tile_shawls_dread(7, 4) and placed.tile_shawls_dread(6, 5) and placed.tile_shawls_dread(8, 4) and placed.tile_shawls_dread(5, 6) and placed.tile_shawls_dread(4, 6) and placed.tile_shawls_dread(3, 6), "that shawl also covers the flare, the wick, the bill, the hood, the cloak, and the cape")
	_expect(not placed.tile_shawls_dread(13, 9), "the winning shawl leaves the far orchard edge sealed")
	var shawl_plant = placed.plant_of_kind(Catalog.SHAWL)
	_expect(shawl_plant != null and shawl_plant.shawls_dread and not shawl_plant.casts_light and not shawl_plant.capes_murk and not shawl_plant.cloaks_gloom and not shawl_plant.hoods_pall and not shawl_plant.cowls_veil and not shawl_plant.shades_dusk and not shawl_plant.splits_hide and not shawl_plant.burns_shroud and not shawl_plant.cracks_rind and not shawl_plant.melts_pitch and not shawl_plant.thaws_frost and not shawl_plant.cuts_web and not shawl_plant.cracks_glass and not shawl_plant.strips_scale and not shawl_plant.cracks_mail, "the shawl shawls dread and does not light, cape, cloak, hood, cowl, shade, split, burn, crack rind, melt, thaw, cut web, crack glass, strip scale, or crack mail")
	_expect(not placed.plant_of_kind(Catalog.CAPE).shawls_dread, "the cape does not shawl dread")
	_expect(not placed.plant_of_kind(Catalog.CLOAK).shawls_dread, "the cloak does not shawl dread")
	_expect(not placed.plant_of_kind(Catalog.HOOD).shawls_dread, "the hood does not shawl dread")
	_expect(not placed.plant_of_kind(Catalog.COWL).shawls_dread, "the cowl does not shawl dread")
	_expect(not placed.plant_of_kind(Catalog.SHADE).shawls_dread, "the shade does not shawl dread")
	_expect(not placed.plant_of_kind(Catalog.BILL).shawls_dread, "the bill does not shawl dread")
	_expect(not placed.plant_of_kind(Catalog.WICK).shawls_dread, "the wick does not shawl dread")

	var sim = Sim.new(6)
	var sow_cape = Sim.Command.new()
	sow_cape.plant_kind = Catalog.CAPE
	sow_cape.tile = Vector2i(3, 6)
	sim.step(sow_cape)
	var sow_cloak = Sim.Command.new()
	sow_cloak.plant_kind = Catalog.CLOAK
	sow_cloak.tile = Vector2i(4, 6)
	sim.step(sow_cloak)
	var sow_hood = Sim.Command.new()
	sow_hood.plant_kind = Catalog.HOOD
	sow_hood.tile = Vector2i(5, 6)
	sim.step(sow_hood)
	var sow_cowl = Sim.Command.new()
	sow_cowl.plant_kind = Catalog.COWL
	sow_cowl.tile = Vector2i(7, 5)
	sim.step(sow_cowl)
	var sow_shade = Sim.Command.new()
	sow_shade.plant_kind = Catalog.SHADE
	sow_shade.tile = Vector2i(6, 6)
	sim.step(sow_shade)
	var sow_pea = Sim.Command.new()
	sow_pea.plant_kind = Catalog.PEA
	sow_pea.tile = Vector2i(8, 5)
	sim.step(sow_pea)
	var dread = sim.spawn_pest(sim.tile_center(7, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var murk = sim.spawn_pest(sim.tile_center(3, 6), false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var gloom = sim.spawn_pest(sim.tile_center(4, 6), false, false, false, false, false, false, false, false, false, false, false, false, true)
	var pall = sim.spawn_pest(sim.tile_center(5, 6), false, false, false, false, false, false, false, false, false, false, false, true, false)
	var veil = sim.spawn_pest(sim.tile_center(7, 5), false, false, false, false, false, false, false, false, false, false, true, false, false)
	var dusk = sim.spawn_pest(sim.tile_center(6, 6), false, false, false, false, false, false, false, false, false, true, false, false, false)
	var dread_id := int(dread.id)
	var murk_id := int(murk.id)
	_expect(sim.tile_capes_murk(3, 6) and sim.tile_cloaks_gloom(4, 6) and sim.tile_hoods_pall(5, 6) and sim.tile_cowls_veil(7, 5) and sim.tile_shades_dusk(6, 6) and not sim.tile_shawls_dread(7, 5) and dread.hidden and not murk.hidden and not gloom.hidden and not pall.hidden and not veil.hidden and not dusk.hidden, "cape opens murk, cloak opens gloom, hood opens pall, cowl opens veil, and shade opens dusk while the dread moth stays sealed")
	var dread_hit := false
	var murk_hit := false
	var guard := 0
	while guard < 80 and sim.outcome == Sim.OUTCOME_RUNNING:
		sim.step(idle)
		guard += 1
		for event in sim.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == dread_id:
				dread_hit = true
			if int(event["pest_id"]) == murk_id:
				murk_hit = true
	var dread_now = sim.pest_by_id(dread_id)
	_expect(murk_hit, "a cape still lets a murk moth take damage")
	_expect(not dread_hit and dread_now != null and int(dread_now.hp) == Sim.PEST_HP, "a cape, a cloak, a hood, a cowl, and a shade do not damage a dread moth")

	var only = Sim.new(5)
	var sow_shawl = Sim.Command.new()
	sow_shawl.plant_kind = Catalog.SHAWL
	sow_shawl.tile = Vector2i(2, 6)
	only.step(sow_shawl)
	var sealed_murk = only.spawn_pest(only.tile_center(2, 6), false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var sealed_gloom = only.spawn_pest(only.tile_center(2, 6), false, false, false, false, false, false, false, false, false, false, false, false, true)
	var sealed_pall = only.spawn_pest(only.tile_center(2, 6), false, false, false, false, false, false, false, false, false, false, false, true, false)
	var sealed_veil = only.spawn_pest(only.tile_center(2, 6), false, false, false, false, false, false, false, false, false, false, true, false, false)
	var sealed_dusk = only.spawn_pest(only.tile_center(2, 6), false, false, false, false, false, false, false, false, false, true, false, false, false)
	var sealed_hide = only.spawn_pest(only.tile_center(2, 6), false, false, false, false, false, false, false, false, true, false, false, false, false)
	var opened_dread = only.spawn_pest(only.tile_center(2, 6), false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var plain = only.spawn_pest(only.tile_center(2, 6), false, false, false, false, false, false, false, false, false, false, false, false, false)
	_expect(only.tile_shawls_dread(2, 6) and only.tile_shawls_dread(3, 6) and not only.tile_lit(2, 6) and not only.tile_capes_murk(2, 6) and not only.tile_cloaks_gloom(2, 6) and not only.tile_hoods_pall(2, 6) and not only.tile_cowls_veil(2, 6) and not only.tile_shades_dusk(2, 6), "shawl marks the tile without lighting it, caping murk, cloaking gloom, hooding pall, cowling veil, or shading dusk")
	_expect(sealed_murk.hidden, "a shawl does not reveal a murk moth")
	_expect(sealed_gloom.hidden, "a shawl does not reveal a gloom moth")
	_expect(sealed_pall.hidden, "a shawl does not reveal a pall moth")
	_expect(sealed_veil.hidden, "a shawl does not reveal a veil moth")
	_expect(sealed_dusk.hidden, "a shawl does not reveal a dusk moth")
	_expect(sealed_hide.hidden, "a shawl does not reveal a hide")
	_expect(not opened_dread.hidden, "a shawl reveals a dread moth on its tile")
	_expect(plain.hidden, "an ordinary moth stays hidden in a shawl with no light")
	var shawl_hit := false
	var murk_hurt := false
	var gloom_hurt := false
	var pall_hurt := false
	var veil_hurt := false
	var dusk_hurt := false
	var hide_hurt := false
	guard = 0
	while guard < 120 and only.outcome == Sim.OUTCOME_RUNNING and not shawl_hit:
		only.step(idle)
		guard += 1
		for event in only.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == int(opened_dread.id):
				shawl_hit = true
			if int(event["pest_id"]) == int(sealed_murk.id):
				murk_hurt = true
			if int(event["pest_id"]) == int(sealed_gloom.id):
				gloom_hurt = true
			if int(event["pest_id"]) == int(sealed_pall.id):
				pall_hurt = true
			if int(event["pest_id"]) == int(sealed_veil.id):
				veil_hurt = true
			if int(event["pest_id"]) == int(sealed_dusk.id):
				dusk_hurt = true
			if int(event["pest_id"]) == int(sealed_hide.id):
				hide_hurt = true
	var murk_left = only.pest_by_id(int(sealed_murk.id))
	var gloom_left = only.pest_by_id(int(sealed_gloom.id))
	var pall_left = only.pest_by_id(int(sealed_pall.id))
	var veil_left = only.pest_by_id(int(sealed_veil.id))
	var dusk_left = only.pest_by_id(int(sealed_dusk.id))
	var hide_left = only.pest_by_id(int(sealed_hide.id))
	_expect(shawl_hit, "the revealed dread moth takes a hit")
	_expect(not murk_hurt and murk_left != null and int(murk_left.hp) == Sim.PEST_HP, "shots do not hurt a murk moth standing in a shawl")
	_expect(not gloom_hurt and gloom_left != null and int(gloom_left.hp) == Sim.PEST_HP, "shots do not hurt a gloom moth standing in a shawl")
	_expect(not pall_hurt and pall_left != null and int(pall_left.hp) == Sim.PEST_HP, "shots do not hurt a pall moth standing in a shawl")
	_expect(not veil_hurt and veil_left != null and int(veil_left.hp) == Sim.PEST_HP, "shots do not hurt a veil moth standing in a shawl")
	_expect(not dusk_hurt and dusk_left != null and int(dusk_left.hp) == Sim.PEST_HP, "shots do not hurt a dusk moth standing in a shawl")
	_expect(not hide_hurt and hide_left != null and int(hide_left.hp) == Sim.PEST_HP, "shots do not hurt a hide standing in a shawl")

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	splash.step(sow_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, false, false, false, false, false)
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the dread moth")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a dread moth outside a shawl")

	var bane = Sim.new(9)
	bane.seeds = 20
	var bane_wick = Sim.Command.new()
	bane_wick.plant_kind = Catalog.WICK
	bane_wick.tile = Vector2i(6, 5)
	bane.step(bane_wick)
	var bane_briar = Sim.Command.new()
	bane_briar.plant_kind = Catalog.BRIAR
	bane_briar.tile = Vector2i(6, 4)
	bane.step(bane_briar)
	var bane_flare = Sim.Command.new()
	bane_flare.plant_kind = Catalog.FLARE
	bane_flare.tile = Vector2i(7, 4)
	bane.step(bane_flare)
	var bane_pea = Sim.Command.new()
	bane_pea.plant_kind = Catalog.PEA
	bane_pea.tile = Vector2i(8, 5)
	bane.step(bane_pea)
	var bane_hearth = Sim.Command.new()
	bane_hearth.plant_kind = Catalog.HEARTH
	bane_hearth.tile = Vector2i(5, 5)
	bane.step(bane_hearth)
	var bane_shear = Sim.Command.new()
	bane_shear.plant_kind = Catalog.SHEAR
	bane_shear.tile = Vector2i(7, 6)
	bane.step(bane_shear)
	var bane_chime = Sim.Command.new()
	bane_chime.plant_kind = Catalog.CHIME
	bane_chime.tile = Vector2i(8, 6)
	bane.step(bane_chime)
	var bane_rasp = Sim.Command.new()
	bane_rasp.plant_kind = Catalog.RASP
	bane_rasp.tile = Vector2i(9, 5)
	bane.step(bane_rasp)
	var bane_maul = Sim.Command.new()
	bane_maul.plant_kind = Catalog.MAUL
	bane_maul.tile = Vector2i(9, 6)
	bane.step(bane_maul)
	var bane_bill = Sim.Command.new()
	bane_bill.plant_kind = Catalog.BILL
	bane_bill.tile = Vector2i(8, 4)
	bane.step(bane_bill)
	var bane_shade = Sim.Command.new()
	bane_shade.plant_kind = Catalog.SHADE
	bane_shade.tile = Vector2i(6, 6)
	bane.step(bane_shade)
	var bane_cowl = Sim.Command.new()
	bane_cowl.plant_kind = Catalog.COWL
	bane_cowl.tile = Vector2i(7, 5)
	bane.step(bane_cowl)
	var bane_hood = Sim.Command.new()
	bane_hood.plant_kind = Catalog.HOOD
	bane_hood.tile = Vector2i(5, 6)
	bane.step(bane_hood)
	var bane_cloak = Sim.Command.new()
	bane_cloak.plant_kind = Catalog.CLOAK
	bane_cloak.tile = Vector2i(4, 6)
	bane.step(bane_cloak)
	var bane_cape = Sim.Command.new()
	bane_cape.plant_kind = Catalog.CAPE
	bane_cape.tile = Vector2i(3, 6)
	bane.step(bane_cape)
	var sealed = bane.spawn_pest(bane.tile_center(7, 4), true, true, true, true, true, true, true, true, true, true, true, true, true, true, true)
	var sealed_id := int(sealed.id)
	_expect(bane.tile_burns_shroud(7, 4) and bane.tile_cracks_rind(7, 4) and bane.tile_melts_pitch(7, 4) and bane.tile_thaws_frost(7, 4) and bane.tile_cuts_web(7, 4) and bane.tile_cracks_glass(7, 4) and bane.tile_strips_scale(7, 4) and bane.tile_cracks_mail(7, 4) and bane.tile_splits_hide(7, 4) and bane.tile_shades_dusk(7, 4) and bane.tile_cowls_veil(7, 4) and bane.tile_hoods_pall(7, 4) and bane.tile_cloaks_gloom(7, 4) and bane.tile_capes_murk(7, 4) and not bane.tile_shawls_dread(7, 4) and sealed.hidden, "every older lock leaves a dread moth sealed")
	guard = 0
	var sealed_hit := false
	while guard < 20 and bane.outcome == Sim.OUTCOME_RUNNING:
		bane.step(idle)
		guard += 1
		for event in bane.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				sealed_hit = true
	var sealed_now = bane.pest_by_id(sealed_id)
	_expect(not sealed_hit and sealed_now != null and int(sealed_now.hp) == Sim.PEST_HP, "a bane moth ignores shots until every lock, including the shawl, is open")
	var bane_shawl = Sim.Command.new()
	bane_shawl.plant_kind = Catalog.SHAWL
	bane_shawl.tile = Vector2i(2, 6)
	bane.step(bane_shawl)
	var opened = bane.pest_by_id(sealed_id)
	_expect(opened != null and not opened.hidden, "shawl plus the older locks together reveal a bane moth")
	var outside = bane.spawn_pest(bane.tile_center(13, 9), false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(outside.hidden, "a dread moth outside the shawl seals again")
	var opened_hit := false
	guard = 0
	while guard < 80 and bane.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		bane.step(idle)
		guard += 1
		for event in bane.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				opened_hit = true
	_expect(opened_hit, "the opened bane moth takes a hit")


func _test_thirty_second_nights() -> void:
	print("nights 32 and 33")
	_expect(Sim.START_SEEDS == 23, "the run starts with twenty-three seeds")
	_expect(Sim.WAVE_COUNT == 47 and Sim.WAVES.size() == 47, "forty-seven nights")
	_expect(int(Sim.WAVES[31]["count"]) == 10 and int(Sim.WAVES[31]["interval"]) == 72 and int(Sim.WAVES[31]["shroud_every"]) == 0 and int(Sim.WAVES[31]["rind_every"]) == 0 and int(Sim.WAVES[31]["pitch_every"]) == 0 and int(Sim.WAVES[31]["frost_every"]) == 0 and int(Sim.WAVES[31]["web_every"]) == 0 and int(Sim.WAVES[31]["glass_every"]) == 0 and int(Sim.WAVES[31]["scale_every"]) == 0 and int(Sim.WAVES[31]["mail_every"]) == 0 and int(Sim.WAVES[31]["hide_every"]) == 0 and int(Sim.WAVES[31]["dusk_every"]) == 0 and int(Sim.WAVES[31]["veil_every"]) == 0 and int(Sim.WAVES[31]["pall_every"]) == 0 and int(Sim.WAVES[31]["gloom_every"]) == 0 and int(Sim.WAVES[31]["murk_every"]) == 0 and int(Sim.WAVES[31]["dread_every"]) == 1 and str(Sim.WAVES[31]["name"]) == "Dread", "night 32 is all dread")
	_expect(int(Sim.WAVES[32]["count"]) == 16 and int(Sim.WAVES[32]["interval"]) == 60 and int(Sim.WAVES[32]["shroud_every"]) == 2 and int(Sim.WAVES[32]["rind_every"]) == 1 and int(Sim.WAVES[32]["pitch_every"]) == 1 and int(Sim.WAVES[32]["frost_every"]) == 1 and int(Sim.WAVES[32]["web_every"]) == 1 and int(Sim.WAVES[32]["glass_every"]) == 1 and int(Sim.WAVES[32]["scale_every"]) == 1 and int(Sim.WAVES[32]["mail_every"]) == 1 and int(Sim.WAVES[32]["hide_every"]) == 1 and int(Sim.WAVES[32]["dusk_every"]) == 1 and int(Sim.WAVES[32]["veil_every"]) == 1 and int(Sim.WAVES[32]["pall_every"]) == 1 and int(Sim.WAVES[32]["gloom_every"]) == 1 and int(Sim.WAVES[32]["murk_every"]) == 1 and int(Sim.WAVES[32]["dread_every"]) == 1 and int(Sim.WAVES[32].get("woe_every", 0)) == 0 and str(Sim.WAVES[32]["name"]) == "Bane", "night 33 is still Bane and carries no woe")
	_expect(int(Sim.WAVES[31].get("woe_every", 0)) == 0, "night 32 is still Dread and carries no woe")
	for i in 31:
		_expect(int(Sim.WAVES[i].get("dread_every", 0)) == 0, "night %d still spawns no dread" % (i + 1))
	_expect(int(Sim.WAVES[29]["murk_every"]) == 1 and str(Sim.WAVES[29]["name"]) == "Murk" and int(Sim.WAVES[29]["count"]) == 10 and int(Sim.WAVES[29].get("dread_every", 0)) == 0, "night 30 is still the murk wave and spawns no dread")
	_expect(int(Sim.WAVES[30]["murk_every"]) == 1 and int(Sim.WAVES[30].get("dread_every", 0)) == 0 and str(Sim.WAVES[30]["name"]) == "Fell" and int(Sim.WAVES[30]["count"]) == 16, "night 31 is still the fell wave and spawns no dread")
	_expect(int(Sim.WAVES[28]["gloom_every"]) == 1 and int(Sim.WAVES[28].get("dread_every", 0)) == 0 and str(Sim.WAVES[28]["name"]) == "Cope" and int(Sim.WAVES[28]["count"]) == 16, "night 29 is still the cope wave and spawns no dread")
	var named = Sim.new(1)
	named.wave = 32
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 32 of 47 (Dread) — 0 pests left", "night 32 heading: %s" % named.phase_text())
	named.wave = 33
	_expect(named.phase_text() == "Night 33 of 47 (Bane) — 0 pests left", "night 33 heading: %s" % named.phase_text())
	named.wave = 31
	named.phase = Sim.PHASE_PLANT
	named.phase_ticks = 0
	_expect(named.phase_text().begins_with("Planting — night 32 (Dread)"), "planting before dread: %s" % named.phase_text())

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var missed := _play(run_seed, Callable(self, "_corner_shawl_command"))
		print("  corner shawl seed=%s outcome=%s night=%s hp=%s tick=%s dread=%s/%s" % [run_seed, missed[0], missed[1], missed[4], missed[3], missed[37], missed[36]])
		_expect(int(missed[0]) == Sim.OUTCOME_LOST, "seed %s dies when the shawl misses the kill tiles" % run_seed)
		_expect(int(missed[1]) == 32, "seed %s dies on night 32 with a corner shawl (night %s)" % [run_seed, missed[1]])
		_expect(int(missed[4]) == 0, "seed %s health reached zero" % run_seed)
		_expect(int(missed[8]) == Sim.START_SEEDS - 16 and int(missed[9]) == 16, "seed %s planted the shawl, just not where the night arrives" % run_seed)
		_expect(int(missed[36]) > int(missed[37]), "seed %s left dread moths unshawled (%s spawned, %s killed)" % [run_seed, missed[36], missed[37]])
		_expect(int(missed[34]) == 26 and int(missed[35]) == 26, "seed %s had already caped murk before the corner shawl failed (%s/%s)" % [run_seed, missed[35], missed[34]])
		var held := _play(run_seed, Callable(self, "_shawl_command"), 33)
		print("  shawl seed=%s outcome=%s night=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s/%s glasses=%s/%s scales=%s/%s mails=%s/%s hides=%s/%s dusk=%s/%s veil=%s/%s pall=%s/%s gloom=%s/%s murk=%s/%s dread=%s/%s" % [run_seed, held[0], held[1], held[4], held[3], held[7], held[6], held[11], held[10], held[13], held[12], held[15], held[14], held[17], held[16], held[19], held[18], held[21], held[20], held[23], held[22], held[25], held[24], held[27], held[26], held[29], held[28], held[31], held[30], held[33], held[32], held[35], held[34], held[37], held[36]])
		_expect(int(held[0]) == Sim.OUTCOME_RUNNING and int(held[2]) == Sim.PHASE_PLANT, "seed %s is still planting after night 33" % run_seed)
		_expect(int(held[1]) == 33, "seed %s cleared through night 33" % run_seed)
		_expect(int(held[4]) == 100, "seed %s finished night 33 at full health (%s)" % [run_seed, held[4]])
		_expect(int(held[6]) == 128 and int(held[7]) == 128, "seed %s burned every shroud moth (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 234 and int(held[11]) == 234, "seed %s cracked every rind moth (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 218 and int(held[13]) == 218, "seed %s melted every pitch moth (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 202 and int(held[15]) == 202, "seed %s thawed every frost moth (%s/%s)" % [run_seed, held[15], held[14]])
		_expect(int(held[16]) == 186 and int(held[17]) == 186, "seed %s cut every web moth (%s/%s)" % [run_seed, held[17], held[16]])
		_expect(int(held[18]) == 170 and int(held[19]) == 170, "seed %s cracked every glass moth (%s/%s)" % [run_seed, held[19], held[18]])
		_expect(int(held[20]) == 154 and int(held[21]) == 154, "seed %s stripped every scale moth (%s/%s)" % [run_seed, held[21], held[20]])
		_expect(int(held[22]) == 138 and int(held[23]) == 138, "seed %s cracked every mail moth (%s/%s)" % [run_seed, held[23], held[22]])
		_expect(int(held[24]) == 122 and int(held[25]) == 122, "seed %s split every hide moth (%s/%s)" % [run_seed, held[25], held[24]])
		_expect(int(held[26]) == 106 and int(held[27]) == 106, "seed %s shaded every dusk moth (%s/%s)" % [run_seed, held[27], held[26]])
		_expect(int(held[28]) == 90 and int(held[29]) == 90, "seed %s cowled every veil moth (%s/%s)" % [run_seed, held[29], held[28]])
		_expect(int(held[30]) == 74 and int(held[31]) == 74, "seed %s hooded every pall moth (%s/%s)" % [run_seed, held[31], held[30]])
		_expect(int(held[32]) == 58 and int(held[33]) == 58, "seed %s cloaked every gloom moth (%s/%s)" % [run_seed, held[33], held[32]])
		_expect(int(held[34]) == 42 and int(held[35]) == 42, "seed %s caped every murk moth (%s/%s)" % [run_seed, held[35], held[34]])
		_expect(int(held[36]) == 26 and int(held[37]) == 26, "seed %s shawled every dread moth (%s/%s)" % [run_seed, held[37], held[36]])
		_expect(int(held[38]) == 0 and int(held[39]) == 0, "seed %s meets no woe moth before night 34" % run_seed)
		_expect(int(held[8]) == Sim.START_SEEDS - 16 and int(held[9]) == 16, "seed %s spent sixteen seeds and left the seventeenth unspent" % run_seed)
		var layout := _shawl_garden_layout(run_seed)
		_expect(not bool(layout["lantern"]), "seed %s left the lantern unplanted" % run_seed)
		_expect(layout["shade"] == Vector2i(6, 6), "seed %s kept the shade at (6, 6)" % run_seed)
		_expect(layout["cowl"] == Vector2i(7, 5), "seed %s kept the cowl at (7, 5)" % run_seed)
		_expect(layout["hood"] == Vector2i(5, 6), "seed %s kept the hood at (5, 6)" % run_seed)
		_expect(layout["cloak"] == Vector2i(4, 6), "seed %s kept the cloak at (4, 6)" % run_seed)
		_expect(layout["cape"] == Vector2i(3, 6), "seed %s kept the cape at (3, 6)" % run_seed)
		_expect(layout["shawl"] == Vector2i(2, 6), "seed %s planted the shawl at (2, 6)" % run_seed)
		_expect(not bool(layout["stole"]), "seed %s left the seventeenth seed unspent and the stole unplanted" % run_seed)
	var again := _play(42, Callable(self, "_shawl_command"), 33)
	var replay := _play(42, Callable(self, "_shawl_command"), 33)
	_expect(str(again) == str(replay), "same seed and shawl plan replay through night 33")


func _shawl_garden_layout(seed_value: int) -> Dictionary:
	var sim = Sim.new(seed_value)
	var guard := 0
	while sim.phase == Sim.PHASE_PLANT and sim.outcome == Sim.OUTCOME_RUNNING and guard < 400:
		sim.step(_shawl_command(sim))
		guard += 1
	return {
		"lantern": sim.has_plant(Catalog.LANTERN),
		"shade": _plant_cell(sim, Catalog.SHADE),
		"cowl": _plant_cell(sim, Catalog.COWL),
		"hood": _plant_cell(sim, Catalog.HOOD),
		"cloak": _plant_cell(sim, Catalog.CLOAK),
		"cape": _plant_cell(sim, Catalog.CAPE),
		"shawl": _plant_cell(sim, Catalog.SHAWL),
		"stole": sim.has_plant(Catalog.STOLE),
	}


func _test_woe_rule() -> void:
	print("stole woe rule")
	var placed = Sim.new(4)
	placed.seeds = 24
	for spec in [
		[Catalog.WICK, Vector2i(6, 5)],
		[Catalog.BRIAR, Vector2i(6, 4)],
		[Catalog.FLARE, Vector2i(7, 4)],
		[Catalog.HEARTH, Vector2i(5, 5)],
		[Catalog.SHEAR, Vector2i(7, 6)],
		[Catalog.CHIME, Vector2i(8, 6)],
		[Catalog.RASP, Vector2i(9, 5)],
		[Catalog.MAUL, Vector2i(9, 6)],
		[Catalog.BILL, Vector2i(8, 4)],
		[Catalog.SHADE, Vector2i(6, 6)],
		[Catalog.COWL, Vector2i(7, 5)],
		[Catalog.HOOD, Vector2i(5, 6)],
		[Catalog.CLOAK, Vector2i(4, 6)],
		[Catalog.CAPE, Vector2i(3, 6)],
		[Catalog.SHAWL, Vector2i(2, 6)],
	]:
		var sow = Sim.Command.new()
		sow.plant_kind = int(spec[0])
		sow.tile = spec[1]
		placed.step(sow)
	var idle = Sim.Command.new()
	placed.step(idle)
	_expect(placed.tile_shawls_dread(7, 5) and not placed.tile_stoles_woe(7, 5), "the shawl covers the gardener and does not stole woe")
	_expect(not placed.plant_of_kind(Catalog.SHAWL).stoles_woe, "a shawl does not stole woe")
	var west = Sim.new(4)
	var at_west = Sim.Command.new()
	at_west.plant_kind = Catalog.STOLE
	at_west.tile = Vector2i(1, 6)
	west.step(at_west)
	_expect(west.tile_stoles_woe(2, 6) and west.tile_stoles_woe(7, 5) and not west.tile_stoles_woe(8, 4), "a stole at (1, 6) overlaps the shawl and the gardener and misses the bill")
	_expect(not west.tile_lit(1, 6) and not west.tile_shawls_dread(1, 6), "a lone stole does not light its tile and does not shawl dread")
	var corner = Sim.Command.new()
	corner.plant_kind = Catalog.STOLE
	corner.tile = Vector2i(1, 1)
	placed.step(corner)
	_expect(placed.tile_stoles_woe(1, 1), "a stole on its own tile stoles it")
	_expect(not placed.tile_lit(1, 1), "a stole does not light its own tile")
	_expect(placed.tile_stoles_woe(7, 5), "a 320px stole at (1, 1) reaches the gardener tile")
	_expect(not placed.tile_stoles_woe(8, 5) and not placed.tile_stoles_woe(8, 4), "that corner stole misses the pea and the bill")
	var beside = Sim.Command.new()
	beside.plant_kind = Catalog.STOLE
	beside.tile = STOLE_TILE
	placed.step(beside)
	_expect(placed.tile_stoles_woe(7, 5) and placed.tile_stoles_woe(6, 6) and placed.tile_stoles_woe(5, 5) and placed.tile_stoles_woe(8, 5), "the winning stole covers the gardener, the shade, the hearth, and the pea")
	_expect(placed.tile_stoles_woe(7, 4) and placed.tile_stoles_woe(6, 5) and placed.tile_stoles_woe(8, 4) and placed.tile_stoles_woe(5, 6) and placed.tile_stoles_woe(4, 6) and placed.tile_stoles_woe(3, 6) and placed.tile_stoles_woe(2, 6), "that stole also covers the flare, the wick, the bill, the hood, the cloak, the cape, and the shawl")
	_expect(not placed.tile_stoles_woe(13, 9), "the winning stole leaves the far orchard edge sealed")
	var stole_plant = placed.plant_of_kind(Catalog.STOLE)
	_expect(stole_plant != null and stole_plant.stoles_woe and not stole_plant.casts_light and not stole_plant.shawls_dread and not stole_plant.capes_murk and not stole_plant.cloaks_gloom and not stole_plant.hoods_pall and not stole_plant.cowls_veil and not stole_plant.shades_dusk and not stole_plant.splits_hide and not stole_plant.burns_shroud and not stole_plant.cracks_rind and not stole_plant.melts_pitch and not stole_plant.thaws_frost and not stole_plant.cuts_web and not stole_plant.cracks_glass and not stole_plant.strips_scale and not stole_plant.cracks_mail, "the stole stoles woe and does not light, shawl, cape, cloak, hood, cowl, shade, split, burn, crack rind, melt, thaw, cut web, crack glass, strip scale, or crack mail")
	var winning_stole = null
	for plant in placed.plants:
		if plant.alive and plant.kind == Catalog.STOLE and plant.cell == STOLE_TILE:
			winning_stole = plant
	_expect(winning_stole != null and winning_stole.stoles_woe and not winning_stole.shawls_dread, "the stole at (1, 5) stoles woe and does not shawl dread")

	var only = Sim.new(5)
	var sow_stole = Sim.Command.new()
	sow_stole.plant_kind = Catalog.STOLE
	sow_stole.tile = STOLE_TILE
	only.step(sow_stole)
	var sealed_dread = only.spawn_pest(only.tile_center(1, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var opened_woe = only.spawn_pest(only.tile_center(1, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var plain = only.spawn_pest(only.tile_center(1, 5), false, false, false, false, false, false, false, false, false, false, false, false, false)
	_expect(only.tile_stoles_woe(1, 5) and only.tile_stoles_woe(2, 6) and not only.tile_lit(1, 5) and not only.tile_shawls_dread(1, 5), "stole marks the tile without lighting it or shawling dread")
	_expect(sealed_dread.hidden, "a stole does not reveal a dread moth")
	_expect(not opened_woe.hidden, "a stole reveals a woe moth on its tile")
	_expect(plain.hidden, "an ordinary moth stays hidden in a stole with no light")
	var stole_hit := false
	var dread_hurt := false
	var guard := 0
	while guard < 160 and only.outcome == Sim.OUTCOME_RUNNING and not stole_hit:
		only.step(idle)
		guard += 1
		for event in only.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == int(opened_woe.id):
				stole_hit = true
			if int(event["pest_id"]) == int(sealed_dread.id):
				dread_hurt = true
	var dread_left = only.pest_by_id(int(sealed_dread.id))
	_expect(stole_hit, "the revealed woe moth takes a hit")
	_expect(not dread_hurt and dread_left != null and int(dread_left.hp) == Sim.PEST_HP, "shots do not hurt a dread moth standing in a stole")

	var blocked = Sim.new(6)
	var sow_shawl = Sim.Command.new()
	sow_shawl.plant_kind = Catalog.SHAWL
	sow_shawl.tile = Vector2i(2, 6)
	blocked.step(sow_shawl)
	var sow_pea = Sim.Command.new()
	sow_pea.plant_kind = Catalog.PEA
	sow_pea.tile = Vector2i(8, 5)
	blocked.step(sow_pea)
	var hidden_woe = blocked.spawn_pest(blocked.tile_center(7, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var shown_dread = blocked.spawn_pest(blocked.tile_center(2, 6), false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(hidden_woe.hidden and not shown_dread.hidden, "a shawl opens dread and leaves woe sealed")
	var woe_id := int(hidden_woe.id)
	var woe_hit := false
	guard = 0
	while guard < 40 and blocked.outcome == Sim.OUTCOME_RUNNING:
		blocked.step(idle)
		guard += 1
		for event in blocked.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == woe_id:
				woe_hit = true
	var woe_now = blocked.pest_by_id(woe_id)
	_expect(not woe_hit and woe_now != null and int(woe_now.hp) == Sim.PEST_HP, "a shawl does not damage a woe moth")

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	splash.step(sow_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5))
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the woe moth")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a woe moth outside a stole")

	var hex = Sim.new(9)
	hex.seeds = 24
	for spec in [
		[Catalog.WICK, Vector2i(6, 5)],
		[Catalog.BRIAR, Vector2i(6, 4)],
		[Catalog.FLARE, Vector2i(7, 4)],
		[Catalog.PEA, Vector2i(8, 5)],
		[Catalog.HEARTH, Vector2i(5, 5)],
		[Catalog.SHEAR, Vector2i(7, 6)],
		[Catalog.CHIME, Vector2i(8, 6)],
		[Catalog.RASP, Vector2i(9, 5)],
		[Catalog.MAUL, Vector2i(9, 6)],
		[Catalog.BILL, Vector2i(8, 4)],
		[Catalog.SHADE, Vector2i(6, 6)],
		[Catalog.COWL, Vector2i(7, 5)],
		[Catalog.HOOD, Vector2i(5, 6)],
		[Catalog.CLOAK, Vector2i(4, 6)],
		[Catalog.CAPE, Vector2i(3, 6)],
		[Catalog.SHAWL, Vector2i(2, 6)],
	]:
		var sow = Sim.Command.new()
		sow.plant_kind = int(spec[0])
		sow.tile = spec[1]
		hex.step(sow)
	var sealed = hex.spawn_pest(hex.tile_center(7, 4), true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true)
	var sealed_id := int(sealed.id)
	_expect(hex.tile_shawls_dread(7, 4) and not hex.tile_stoles_woe(7, 4) and sealed.hidden, "every older lock leaves a woe moth sealed")
	guard = 0
	var sealed_hit := false
	while guard < 20 and hex.outcome == Sim.OUTCOME_RUNNING:
		hex.step(idle)
		guard += 1
		for event in hex.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				sealed_hit = true
	var sealed_now = hex.pest_by_id(sealed_id)
	_expect(not sealed_hit and sealed_now != null and int(sealed_now.hp) == Sim.PEST_HP, "a hex moth ignores shots until every lock, including the stole, is open")
	var hex_stole = Sim.Command.new()
	hex_stole.plant_kind = Catalog.STOLE
	hex_stole.tile = STOLE_TILE
	hex.step(hex_stole)
	var opened = hex.pest_by_id(sealed_id)
	_expect(opened != null and not opened.hidden, "stole plus the older locks together reveal a hex moth")
	var outside = hex.spawn_pest(hex.tile_center(13, 9), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(outside.hidden, "a woe moth outside the stole seals again")
	var opened_hit := false
	guard = 0
	while guard < 80 and hex.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		hex.step(idle)
		guard += 1
		for event in hex.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				opened_hit = true
	_expect(opened_hit, "the opened hex moth takes a hit")


func _test_thirty_fourth_nights() -> void:
	print("nights 34 and 35")
	_expect(Sim.START_SEEDS == 23, "the run starts with twenty-three seeds")
	_expect(Sim.WAVE_COUNT == 47 and Sim.WAVES.size() == 47, "forty-seven nights")
	_expect(int(Sim.WAVES[33]["count"]) == 10 and int(Sim.WAVES[33]["interval"]) == 72 and int(Sim.WAVES[33]["shroud_every"]) == 0 and int(Sim.WAVES[33]["rind_every"]) == 0 and int(Sim.WAVES[33]["pitch_every"]) == 0 and int(Sim.WAVES[33]["frost_every"]) == 0 and int(Sim.WAVES[33]["web_every"]) == 0 and int(Sim.WAVES[33]["glass_every"]) == 0 and int(Sim.WAVES[33]["scale_every"]) == 0 and int(Sim.WAVES[33]["mail_every"]) == 0 and int(Sim.WAVES[33]["hide_every"]) == 0 and int(Sim.WAVES[33]["dusk_every"]) == 0 and int(Sim.WAVES[33]["veil_every"]) == 0 and int(Sim.WAVES[33]["pall_every"]) == 0 and int(Sim.WAVES[33]["gloom_every"]) == 0 and int(Sim.WAVES[33]["murk_every"]) == 0 and int(Sim.WAVES[33]["dread_every"]) == 0 and int(Sim.WAVES[33]["woe_every"]) == 1 and int(Sim.WAVES[33].get("blight_every", 0)) == 0 and str(Sim.WAVES[33]["name"]) == "Woe", "night 34 is all woe and carries no blight")
	_expect(int(Sim.WAVES[34]["count"]) == 16 and int(Sim.WAVES[34]["interval"]) == 60 and int(Sim.WAVES[34]["shroud_every"]) == 2 and int(Sim.WAVES[34]["rind_every"]) == 1 and int(Sim.WAVES[34]["pitch_every"]) == 1 and int(Sim.WAVES[34]["frost_every"]) == 1 and int(Sim.WAVES[34]["web_every"]) == 1 and int(Sim.WAVES[34]["glass_every"]) == 1 and int(Sim.WAVES[34]["scale_every"]) == 1 and int(Sim.WAVES[34]["mail_every"]) == 1 and int(Sim.WAVES[34]["hide_every"]) == 1 and int(Sim.WAVES[34]["dusk_every"]) == 1 and int(Sim.WAVES[34]["veil_every"]) == 1 and int(Sim.WAVES[34]["pall_every"]) == 1 and int(Sim.WAVES[34]["gloom_every"]) == 1 and int(Sim.WAVES[34]["murk_every"]) == 1 and int(Sim.WAVES[34]["dread_every"]) == 1 and int(Sim.WAVES[34]["woe_every"]) == 1 and int(Sim.WAVES[34].get("blight_every", 0)) == 0 and str(Sim.WAVES[34]["name"]) == "Hex", "night 35 is still Hex and carries no blight")
	for i in 33:
		_expect(int(Sim.WAVES[i].get("woe_every", 0)) == 0, "night %d still spawns no woe" % (i + 1))
	_expect(int(Sim.WAVES[30].get("dread_every", 0)) == 0 and int(Sim.WAVES[30].get("woe_every", 0)) == 0 and str(Sim.WAVES[30]["name"]) == "Fell", "night 31 is still Fell and carries no dread and no woe")
	_expect(int(Sim.WAVES[31].get("woe_every", 0)) == 0 and str(Sim.WAVES[31]["name"]) == "Dread", "night 32 stays Dread and carries no woe")
	_expect(int(Sim.WAVES[32].get("woe_every", 0)) == 0 and int(Sim.WAVES[32].get("blight_every", 0)) == 0 and str(Sim.WAVES[32]["name"]) == "Bane", "night 33 stays Bane and carries no woe and no blight")
	var named = Sim.new(1)
	named.wave = 34
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 34 of 47 (Woe) — 0 pests left", "night 34 heading: %s" % named.phase_text())
	named.wave = 35
	_expect(named.phase_text() == "Night 35 of 47 (Hex) — 0 pests left", "night 35 heading: %s" % named.phase_text())
	named.wave = 33
	named.phase = Sim.PHASE_PLANT
	named.phase_ticks = 0
	_expect(named.phase_text().begins_with("Planting — night 34 (Woe)"), "planting before woe: %s" % named.phase_text())
	_expect(STOLE_TILE == Vector2i(1, 5), "the stole landed at (1, 5) because (1, 6) misses the bill")

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var bare := _play(run_seed, Callable(self, "_shawl_command"))
		print("  no stole seed=%s outcome=%s night=%s hp=%s woe=%s/%s dread=%s/%s" % [run_seed, bare[0], bare[1], bare[4], bare[39], bare[38], bare[37], bare[36]])
		_expect(int(bare[0]) == Sim.OUTCOME_LOST, "seed %s dies when the shawl has no stole" % run_seed)
		_expect(int(bare[1]) == 34, "seed %s dies on the woe night (night %s)" % [run_seed, bare[1]])
		_expect(int(bare[4]) == 0, "seed %s health reached zero on the woe night" % run_seed)
		_expect(int(bare[38]) > 0 and int(bare[39]) == 0, "seed %s left every woe moth unstoled (%s spawned, %s killed)" % [run_seed, bare[38], bare[39]])
		_expect(int(bare[36]) == 26 and int(bare[37]) == 26, "seed %s had already shawled dread before woe (%s/%s)" % [run_seed, bare[37], bare[36]])
		_expect(int(bare[8]) == Sim.START_SEEDS - 16 and int(bare[9]) == 16, "seed %s still has the seventeenth seed unspent when woe arrives" % run_seed)
		var held := _play(run_seed, Callable(self, "_stole_command"), 35)
		print("  stole seed=%s outcome=%s night=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s/%s glasses=%s/%s scales=%s/%s mails=%s/%s hides=%s/%s dusk=%s/%s veil=%s/%s pall=%s/%s gloom=%s/%s murk=%s/%s dread=%s/%s woe=%s/%s" % [run_seed, held[0], held[1], held[4], held[3], held[7], held[6], held[11], held[10], held[13], held[12], held[15], held[14], held[17], held[16], held[19], held[18], held[21], held[20], held[23], held[22], held[25], held[24], held[27], held[26], held[29], held[28], held[31], held[30], held[33], held[32], held[35], held[34], held[37], held[36], held[39], held[38]])
		_expect(int(held[0]) == Sim.OUTCOME_RUNNING and int(held[2]) == Sim.PHASE_PLANT, "seed %s is still planting after night 35" % run_seed)
		_expect(int(held[1]) == 35, "seed %s cleared through night 35" % run_seed)
		_expect(int(held[4]) == 100, "seed %s finished night 35 at full health (%s)" % [run_seed, held[4]])
		_expect(int(held[6]) == 136 and int(held[7]) == 136, "seed %s burned every shroud moth (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 250 and int(held[11]) == 250, "seed %s cracked every rind moth (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 234 and int(held[13]) == 234, "seed %s melted every pitch moth (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 218 and int(held[15]) == 218, "seed %s thawed every frost moth (%s/%s)" % [run_seed, held[15], held[14]])
		_expect(int(held[16]) == 202 and int(held[17]) == 202, "seed %s cut every web moth (%s/%s)" % [run_seed, held[17], held[16]])
		_expect(int(held[18]) == 186 and int(held[19]) == 186, "seed %s cracked every glass moth (%s/%s)" % [run_seed, held[19], held[18]])
		_expect(int(held[20]) == 170 and int(held[21]) == 170, "seed %s stripped every scale moth (%s/%s)" % [run_seed, held[21], held[20]])
		_expect(int(held[22]) == 154 and int(held[23]) == 154, "seed %s cracked every mail moth (%s/%s)" % [run_seed, held[23], held[22]])
		_expect(int(held[24]) == 138 and int(held[25]) == 138, "seed %s split every hide moth (%s/%s)" % [run_seed, held[25], held[24]])
		_expect(int(held[26]) == 122 and int(held[27]) == 122, "seed %s shaded every dusk moth (%s/%s)" % [run_seed, held[27], held[26]])
		_expect(int(held[28]) == 106 and int(held[29]) == 106, "seed %s cowled every veil moth (%s/%s)" % [run_seed, held[29], held[28]])
		_expect(int(held[30]) == 90 and int(held[31]) == 90, "seed %s hooded every pall moth (%s/%s)" % [run_seed, held[31], held[30]])
		_expect(int(held[32]) == 74 and int(held[33]) == 74, "seed %s cloaked every gloom moth (%s/%s)" % [run_seed, held[33], held[32]])
		_expect(int(held[34]) == 58 and int(held[35]) == 58, "seed %s caped every murk moth (%s/%s)" % [run_seed, held[35], held[34]])
		_expect(int(held[36]) == 42 and int(held[37]) == 42, "seed %s shawled every dread moth (%s/%s)" % [run_seed, held[37], held[36]])
		_expect(int(held[38]) == 26 and int(held[39]) == 26, "seed %s stoled every woe moth (%s/%s)" % [run_seed, held[39], held[38]])
		_expect(int(held[40]) == 0 and int(held[41]) == 0, "seed %s meets no blight moth before night 36" % run_seed)
		_expect(int(held[8]) == Sim.START_SEEDS - 17 and int(held[9]) == 17, "seed %s spent seventeen seeds and left the eighteenth unspent" % run_seed)
		var layout := _stole_garden_layout(run_seed)
		_expect(not bool(layout["lantern"]), "seed %s left the lantern unplanted" % run_seed)
		_expect(layout["shawl"] == Vector2i(2, 6), "seed %s kept the shawl at (2, 6)" % run_seed)
		_expect(layout["stole"] == STOLE_TILE, "seed %s planted the stole at (1, 5)" % run_seed)
		_expect(not bool(layout["mantle"]), "seed %s left the eighteenth seed unspent and the mantle unplanted" % run_seed)
	var again := _play(42, Callable(self, "_stole_command"), 35)
	var replay := _play(42, Callable(self, "_stole_command"), 35)
	_expect(str(again) == str(replay), "same seed and stole plan replay through night 35")


func _stole_garden_layout(seed_value: int) -> Dictionary:
	var sim = Sim.new(seed_value)
	var guard := 0
	while sim.phase == Sim.PHASE_PLANT and sim.outcome == Sim.OUTCOME_RUNNING and guard < 400:
		sim.step(_stole_command(sim))
		guard += 1
	return {
		"lantern": sim.has_plant(Catalog.LANTERN),
		"shawl": _plant_cell(sim, Catalog.SHAWL),
		"stole": _plant_cell(sim, Catalog.STOLE),
		"mantle": sim.has_plant(Catalog.MANTLE),
	}


func _test_blight_rule() -> void:
	print("mantle blight rule")
	var placed = Sim.new(4)
	placed.seeds = 24
	for spec in [
		[Catalog.WICK, Vector2i(6, 5)],
		[Catalog.BRIAR, Vector2i(6, 4)],
		[Catalog.FLARE, Vector2i(7, 4)],
		[Catalog.HEARTH, Vector2i(5, 5)],
		[Catalog.SHEAR, Vector2i(7, 6)],
		[Catalog.CHIME, Vector2i(8, 6)],
		[Catalog.RASP, Vector2i(9, 5)],
		[Catalog.MAUL, Vector2i(9, 6)],
		[Catalog.BILL, Vector2i(8, 4)],
		[Catalog.SHADE, Vector2i(6, 6)],
		[Catalog.COWL, Vector2i(7, 5)],
		[Catalog.HOOD, Vector2i(5, 6)],
		[Catalog.CLOAK, Vector2i(4, 6)],
		[Catalog.CAPE, Vector2i(3, 6)],
		[Catalog.SHAWL, Vector2i(2, 6)],
		[Catalog.STOLE, STOLE_TILE],
	]:
		var sow = Sim.Command.new()
		sow.plant_kind = int(spec[0])
		sow.tile = spec[1]
		placed.step(sow)
	var idle = Sim.Command.new()
	placed.step(idle)
	_expect(placed.tile_stoles_woe(7, 5) and not placed.tile_mantles_blight(7, 5), "the stole covers the gardener and does not mantle blight")
	_expect(not placed.plant_of_kind(Catalog.STOLE).mantles_blight, "a stole does not mantle blight")
	var west = Sim.new(4)
	var at_west = Sim.Command.new()
	at_west.plant_kind = Catalog.MANTLE
	at_west.tile = MANTLE_TILE
	west.step(at_west)
	_expect(west.tile_mantles_blight(1, 5) and west.tile_mantles_blight(2, 6) and west.tile_mantles_blight(7, 5) and west.tile_mantles_blight(8, 4) and west.tile_mantles_blight(8, 5) and west.tile_mantles_blight(8, 6), "a mantle at (1, 6) covers the stole and the kill tiles")
	_expect(not west.tile_mantles_blight(9, 5) and not west.tile_mantles_blight(9, 6), "rasp and maul sit outside the kill intersection, so missing them is not a lock miss")
	_expect(not west.tile_lit(1, 6) and not west.tile_stoles_woe(1, 6), "a lone mantle does not light its tile and does not stole woe")
	var corner = Sim.Command.new()
	corner.plant_kind = Catalog.MANTLE
	corner.tile = Vector2i(1, 1)
	placed.step(corner)
	_expect(placed.tile_mantles_blight(1, 1), "a mantle on its own tile mantles it")
	_expect(not placed.tile_lit(1, 1), "a mantle does not light its own tile")
	_expect(placed.tile_mantles_blight(7, 5) and placed.tile_mantles_blight(1, 5), "a 336px mantle at (1, 1) reaches the gardener and the stole")
	_expect(not placed.tile_mantles_blight(8, 5) and not placed.tile_mantles_blight(7, 6) and not placed.tile_mantles_blight(8, 6), "that corner mantle misses the pea, the shear, and the chime")
	var beside = Sim.Command.new()
	beside.plant_kind = Catalog.MANTLE
	beside.tile = MANTLE_TILE
	placed.step(beside)
	_expect(placed.tile_mantles_blight(1, 5) and placed.tile_mantles_blight(2, 6) and placed.tile_mantles_blight(7, 5) and placed.tile_mantles_blight(6, 6) and placed.tile_mantles_blight(5, 5) and placed.tile_mantles_blight(8, 5), "the winning mantle covers the stole, the shawl, the gardener, the shade, the hearth, and the pea")
	_expect(placed.tile_mantles_blight(7, 4) and placed.tile_mantles_blight(6, 5) and placed.tile_mantles_blight(8, 4) and placed.tile_mantles_blight(5, 6) and placed.tile_mantles_blight(4, 6) and placed.tile_mantles_blight(3, 6) and placed.tile_mantles_blight(6, 4) and placed.tile_mantles_blight(7, 6) and placed.tile_mantles_blight(8, 6), "that mantle also covers the flare, the wick, the bill, the hood, the cloak, the cape, the briar, the shear, and the chime")
	_expect(not placed.tile_mantles_blight(13, 9), "the winning mantle leaves the far orchard edge sealed")
	var mantle_plant = placed.plant_of_kind(Catalog.MANTLE)
	_expect(mantle_plant != null and mantle_plant.mantles_blight and not mantle_plant.casts_light and not mantle_plant.stoles_woe and not mantle_plant.shawls_dread and not mantle_plant.capes_murk and not mantle_plant.cloaks_gloom and not mantle_plant.hoods_pall and not mantle_plant.cowls_veil and not mantle_plant.shades_dusk and not mantle_plant.splits_hide and not mantle_plant.burns_shroud and not mantle_plant.cracks_rind and not mantle_plant.melts_pitch and not mantle_plant.thaws_frost and not mantle_plant.cuts_web and not mantle_plant.cracks_glass and not mantle_plant.strips_scale and not mantle_plant.cracks_mail, "the mantle mantles blight and does not light, stole, shawl, cape, cloak, hood, cowl, shade, split, burn, crack rind, melt, thaw, cut web, crack glass, strip scale, or crack mail")
	var winning_mantle = null
	for plant in placed.plants:
		if plant.alive and plant.kind == Catalog.MANTLE and plant.cell == MANTLE_TILE:
			winning_mantle = plant
	_expect(winning_mantle != null and winning_mantle.mantles_blight and not winning_mantle.stoles_woe, "the mantle at (1, 6) mantles blight and does not stole woe")

	var only = Sim.new(5)
	var sow_mantle = Sim.Command.new()
	sow_mantle.plant_kind = Catalog.MANTLE
	sow_mantle.tile = MANTLE_TILE
	only.step(sow_mantle)
	var sealed_woe = only.spawn_pest(only.tile_center(1, 6), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var opened_blight = only.spawn_pest(only.tile_center(1, 6), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var plain = only.spawn_pest(only.tile_center(1, 6), false, false, false, false, false, false, false, false, false, false, false, false, false)
	_expect(only.tile_mantles_blight(1, 6) and only.tile_mantles_blight(1, 5) and not only.tile_lit(1, 6) and not only.tile_stoles_woe(1, 6), "mantle marks the tile without lighting it or stoling woe")
	_expect(sealed_woe.hidden, "a mantle does not reveal a woe moth")
	_expect(not opened_blight.hidden, "a mantle reveals a blight moth on its tile")
	_expect(plain.hidden, "an ordinary moth stays hidden in a mantle with no light")
	var mantle_hit := false
	var woe_hurt := false
	var guard := 0
	while guard < 160 and only.outcome == Sim.OUTCOME_RUNNING and not mantle_hit:
		only.step(idle)
		guard += 1
		for event in only.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == int(opened_blight.id):
				mantle_hit = true
			if int(event["pest_id"]) == int(sealed_woe.id):
				woe_hurt = true
	var woe_left = only.pest_by_id(int(sealed_woe.id))
	_expect(mantle_hit, "the revealed blight moth takes a hit")
	_expect(not woe_hurt and woe_left != null and int(woe_left.hp) == Sim.PEST_HP, "shots do not hurt a woe moth standing in a mantle")

	var blocked = Sim.new(6)
	var sow_stole = Sim.Command.new()
	sow_stole.plant_kind = Catalog.STOLE
	sow_stole.tile = STOLE_TILE
	blocked.step(sow_stole)
	var sow_pea = Sim.Command.new()
	sow_pea.plant_kind = Catalog.PEA
	sow_pea.tile = Vector2i(8, 5)
	blocked.step(sow_pea)
	var hidden_blight = blocked.spawn_pest(blocked.tile_center(7, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var shown_woe = blocked.spawn_pest(blocked.tile_center(1, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(hidden_blight.hidden and not shown_woe.hidden, "a stole opens woe and leaves blight sealed")
	var blight_id := int(hidden_blight.id)
	var blight_hit := false
	guard = 0
	while guard < 40 and blocked.outcome == Sim.OUTCOME_RUNNING:
		blocked.step(idle)
		guard += 1
		for event in blocked.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == blight_id:
				blight_hit = true
	var blight_now = blocked.pest_by_id(blight_id)
	_expect(not blight_hit and blight_now != null and int(blight_now.hp) == Sim.PEST_HP, "a stole does not damage a blight moth")

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	splash.step(sow_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5))
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the blight moth")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a blight moth outside a mantle")

	var canker = Sim.new(9)
	canker.seeds = 24
	for spec in [
		[Catalog.WICK, Vector2i(6, 5)],
		[Catalog.BRIAR, Vector2i(6, 4)],
		[Catalog.FLARE, Vector2i(7, 4)],
		[Catalog.PEA, Vector2i(8, 5)],
		[Catalog.HEARTH, Vector2i(5, 5)],
		[Catalog.SHEAR, Vector2i(7, 6)],
		[Catalog.CHIME, Vector2i(8, 6)],
		[Catalog.RASP, Vector2i(9, 5)],
		[Catalog.MAUL, Vector2i(9, 6)],
		[Catalog.BILL, Vector2i(8, 4)],
		[Catalog.SHADE, Vector2i(6, 6)],
		[Catalog.COWL, Vector2i(7, 5)],
		[Catalog.HOOD, Vector2i(5, 6)],
		[Catalog.CLOAK, Vector2i(4, 6)],
		[Catalog.CAPE, Vector2i(3, 6)],
		[Catalog.SHAWL, Vector2i(2, 6)],
		[Catalog.STOLE, STOLE_TILE],
	]:
		var sow = Sim.Command.new()
		sow.plant_kind = int(spec[0])
		sow.tile = spec[1]
		canker.step(sow)
	var sealed = canker.spawn_pest(canker.tile_center(7, 4), true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true)
	var sealed_id := int(sealed.id)
	_expect(canker.tile_stoles_woe(7, 4) and not canker.tile_mantles_blight(7, 4) and sealed.hidden, "every older lock leaves a blight moth sealed")
	guard = 0
	var sealed_hit := false
	while guard < 20 and canker.outcome == Sim.OUTCOME_RUNNING:
		canker.step(idle)
		guard += 1
		for event in canker.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				sealed_hit = true
	var sealed_now = canker.pest_by_id(sealed_id)
	_expect(not sealed_hit and sealed_now != null and int(sealed_now.hp) == Sim.PEST_HP, "a canker moth ignores shots until every lock, including the mantle, is open")
	var canker_mantle = Sim.Command.new()
	canker_mantle.plant_kind = Catalog.MANTLE
	canker_mantle.tile = MANTLE_TILE
	canker.step(canker_mantle)
	var opened = canker.pest_by_id(sealed_id)
	_expect(opened != null and not opened.hidden, "mantle plus the older locks together reveal a canker moth")
	var outside = canker.spawn_pest(canker.tile_center(13, 9), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(outside.hidden, "a blight moth outside the mantle seals again")
	var opened_hit := false
	guard = 0
	while guard < 80 and canker.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		canker.step(idle)
		guard += 1
		for event in canker.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				opened_hit = true
	_expect(opened_hit, "the opened canker moth takes a hit")


func _test_thirty_sixth_nights() -> void:
	print("nights 36 and 37")
	_expect(Sim.START_SEEDS == 23, "the run starts with twenty-three seeds")
	_expect(Sim.WAVE_COUNT == 47 and Sim.WAVES.size() == 47, "forty-seven nights")
	_expect(int(Sim.WAVES[35]["count"]) == 10 and int(Sim.WAVES[35]["interval"]) == 78 and int(Sim.WAVES[35]["shroud_every"]) == 0 and int(Sim.WAVES[35]["rind_every"]) == 0 and int(Sim.WAVES[35]["pitch_every"]) == 0 and int(Sim.WAVES[35]["frost_every"]) == 0 and int(Sim.WAVES[35]["web_every"]) == 0 and int(Sim.WAVES[35]["glass_every"]) == 0 and int(Sim.WAVES[35]["scale_every"]) == 0 and int(Sim.WAVES[35]["mail_every"]) == 0 and int(Sim.WAVES[35]["hide_every"]) == 0 and int(Sim.WAVES[35]["dusk_every"]) == 0 and int(Sim.WAVES[35]["veil_every"]) == 0 and int(Sim.WAVES[35]["pall_every"]) == 0 and int(Sim.WAVES[35]["gloom_every"]) == 0 and int(Sim.WAVES[35]["murk_every"]) == 0 and int(Sim.WAVES[35]["dread_every"]) == 0 and int(Sim.WAVES[35]["woe_every"]) == 0 and int(Sim.WAVES[35]["blight_every"]) == 1 and str(Sim.WAVES[35]["name"]) == "Gall", "night 36 is all blight and no other lock")
	_expect(int(Sim.WAVES[36]["count"]) == 16 and int(Sim.WAVES[36]["interval"]) == 60 and int(Sim.WAVES[36]["shroud_every"]) == 2 and int(Sim.WAVES[36]["rind_every"]) == 1 and int(Sim.WAVES[36]["pitch_every"]) == 1 and int(Sim.WAVES[36]["frost_every"]) == 1 and int(Sim.WAVES[36]["web_every"]) == 1 and int(Sim.WAVES[36]["glass_every"]) == 1 and int(Sim.WAVES[36]["scale_every"]) == 1 and int(Sim.WAVES[36]["mail_every"]) == 1 and int(Sim.WAVES[36]["hide_every"]) == 1 and int(Sim.WAVES[36]["dusk_every"]) == 1 and int(Sim.WAVES[36]["veil_every"]) == 1 and int(Sim.WAVES[36]["pall_every"]) == 1 and int(Sim.WAVES[36]["gloom_every"]) == 1 and int(Sim.WAVES[36]["murk_every"]) == 1 and int(Sim.WAVES[36]["dread_every"]) == 1 and int(Sim.WAVES[36]["woe_every"]) == 1 and int(Sim.WAVES[36]["blight_every"]) == 1 and str(Sim.WAVES[36]["name"]) == "Canker", "night 37 is blight, woe, dread, murk, gloom, pall, veil, dusk, hide, mail, scale, glass, web, frost, pitch, and rind, every second also a shroud")
	for i in 35:
		_expect(int(Sim.WAVES[i].get("blight_every", 0)) == 0, "night %d still spawns no blight" % (i + 1))
	_expect(int(Sim.WAVES[32].get("blight_every", 0)) == 0 and str(Sim.WAVES[32]["name"]) == "Bane", "night 33 stays Bane and carries no blight")
	_expect(int(Sim.WAVES[33].get("blight_every", 0)) == 0 and str(Sim.WAVES[33]["name"]) == "Woe", "night 34 stays Woe and carries no blight")
	_expect(int(Sim.WAVES[34].get("blight_every", 0)) == 0 and str(Sim.WAVES[34]["name"]) == "Hex", "night 35 stays Hex and carries no blight")
	_expect(int(Sim.WAVES[35].get("rot_every", 0)) == 0, "night 36 Gall carries no rot")
	_expect(int(Sim.WAVES[36].get("rot_every", 0)) == 0, "night 37 Canker carries no rot")
	_expect(int(Sim.WAVES[35].get("mildew_every", 0)) == 0, "night 36 Gall carries no mildew")
	_expect(int(Sim.WAVES[36].get("mildew_every", 0)) == 0, "night 37 Canker carries no mildew")
	var named = Sim.new(1)
	named.wave = 36
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 36 of 47 (Gall) — 0 pests left", "night 36 heading: %s" % named.phase_text())
	named.wave = 37
	_expect(named.phase_text() == "Night 37 of 47 (Canker) — 0 pests left", "night 37 heading: %s" % named.phase_text())
	named.wave = 35
	named.phase = Sim.PHASE_PLANT
	named.phase_ticks = 0
	_expect(named.phase_text().begins_with("Planting — night 36 (Gall)"), "planting before blight: %s" % named.phase_text())
	_expect(MANTLE_TILE == Vector2i(1, 6), "the mantle landed at (1, 6) because that radius covers the stole and every Canker lock tile")

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var bare := _play(run_seed, Callable(self, "_stole_command"))
		print("  no mantle seed=%s outcome=%s night=%s hp=%s blight=%s/%s woe=%s/%s" % [run_seed, bare[0], bare[1], bare[4], bare[41], bare[40], bare[39], bare[38]])
		_expect(int(bare[0]) == Sim.OUTCOME_LOST, "seed %s dies when the stole has no mantle" % run_seed)
		_expect(int(bare[1]) == 36, "seed %s dies on the blight night (night %s)" % [run_seed, bare[1]])
		_expect(int(bare[4]) == 0, "seed %s health reached zero on the blight night" % run_seed)
		_expect(int(bare[40]) > 0 and int(bare[41]) == 0, "seed %s left every blight moth unmantled (%s spawned, %s killed)" % [run_seed, bare[40], bare[41]])
		_expect(int(bare[38]) == 26 and int(bare[39]) == 26, "seed %s had already stoled woe before blight (%s/%s)" % [run_seed, bare[39], bare[38]])
		_expect(int(bare[8]) == Sim.START_SEEDS - 17 and int(bare[9]) == 17, "seed %s still has the eighteenth seed unspent when blight arrives" % run_seed)
		var missed := _play(run_seed, Callable(self, "_corner_mantle_command"), 37)
		print("  corner mantle seed=%s outcome=%s night=%s hp=%s blight=%s/%s" % [run_seed, missed[0], missed[1], missed[4], missed[41], missed[40]])
		# (1, 1) still mantles the gardener tile, so Gall is not a sealed night. It misses the pea, the shear, and the chime, and it finishes night 37 below full health.
		_expect(int(missed[1]) == 37, "seed %s reaches night 37 with a corner mantle (night %s)" % [run_seed, missed[1]])
		_expect(int(missed[4]) < 100, "seed %s finishes night 37 below full health with a corner mantle (%s)" % [run_seed, missed[4]])
		_expect(int(missed[8]) == 5 and int(missed[9]) == 18, "seed %s planted the mantle and left the nineteenth, twentieth, twenty-first, twenty-second, and twenty-third seeds unspent" % run_seed)
		var held := _play(run_seed, Callable(self, "_mantle_command"), 37)
		print("  mantle seed=%s outcome=%s night=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s/%s glasses=%s/%s scales=%s/%s mails=%s/%s hides=%s/%s dusk=%s/%s veil=%s/%s pall=%s/%s gloom=%s/%s murk=%s/%s dread=%s/%s woe=%s/%s blight=%s/%s" % [run_seed, held[0], held[1], held[4], held[3], held[7], held[6], held[11], held[10], held[13], held[12], held[15], held[14], held[17], held[16], held[19], held[18], held[21], held[20], held[23], held[22], held[25], held[24], held[27], held[26], held[29], held[28], held[31], held[30], held[33], held[32], held[35], held[34], held[37], held[36], held[39], held[38], held[41], held[40]])
		_expect(int(held[0]) == Sim.OUTCOME_RUNNING and int(held[2]) == Sim.PHASE_PLANT, "seed %s is still planting after night 37" % run_seed)
		_expect(int(held[1]) == 37, "seed %s cleared through night 37" % run_seed)
		_expect(int(held[4]) == 100, "seed %s finished night 37 at full health (%s)" % [run_seed, held[4]])
		_expect(int(held[6]) == 144 and int(held[7]) == 144, "seed %s burned every shroud moth (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 266 and int(held[11]) == 266, "seed %s cracked every rind moth (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 250 and int(held[13]) == 250, "seed %s melted every pitch moth (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 234 and int(held[15]) == 234, "seed %s thawed every frost moth (%s/%s)" % [run_seed, held[15], held[14]])
		_expect(int(held[16]) == 218 and int(held[17]) == 218, "seed %s cut every web moth (%s/%s)" % [run_seed, held[17], held[16]])
		_expect(int(held[18]) == 202 and int(held[19]) == 202, "seed %s cracked every glass moth (%s/%s)" % [run_seed, held[19], held[18]])
		_expect(int(held[20]) == 186 and int(held[21]) == 186, "seed %s stripped every scale moth (%s/%s)" % [run_seed, held[21], held[20]])
		_expect(int(held[22]) == 170 and int(held[23]) == 170, "seed %s cracked every mail moth (%s/%s)" % [run_seed, held[23], held[22]])
		_expect(int(held[24]) == 154 and int(held[25]) == 154, "seed %s split every hide moth (%s/%s)" % [run_seed, held[25], held[24]])
		_expect(int(held[26]) == 138 and int(held[27]) == 138, "seed %s shaded every dusk moth (%s/%s)" % [run_seed, held[27], held[26]])
		_expect(int(held[28]) == 122 and int(held[29]) == 122, "seed %s cowled every veil moth (%s/%s)" % [run_seed, held[29], held[28]])
		_expect(int(held[30]) == 106 and int(held[31]) == 106, "seed %s hooded every pall moth (%s/%s)" % [run_seed, held[31], held[30]])
		_expect(int(held[32]) == 90 and int(held[33]) == 90, "seed %s cloaked every gloom moth (%s/%s)" % [run_seed, held[33], held[32]])
		_expect(int(held[34]) == 74 and int(held[35]) == 74, "seed %s caped every murk moth (%s/%s)" % [run_seed, held[35], held[34]])
		_expect(int(held[36]) == 58 and int(held[37]) == 58, "seed %s shawled every dread moth (%s/%s)" % [run_seed, held[37], held[36]])
		_expect(int(held[38]) == 42 and int(held[39]) == 42, "seed %s stoled every woe moth (%s/%s)" % [run_seed, held[39], held[38]])
		_expect(int(held[40]) == 26 and int(held[41]) == 26, "seed %s mantled every blight moth (%s/%s)" % [run_seed, held[41], held[40]])
		_expect(int(held[42]) == 0 and int(held[43]) == 0, "seed %s meets no rot moth before night 38" % run_seed)
		_expect(int(held[8]) == 5 and int(held[9]) == 18, "seed %s spent eighteen seeds and left the nineteenth, twentieth, twenty-first, twenty-second, and twenty-third unspent" % run_seed)
		var layout := _mantle_garden_layout(run_seed)
		_expect(not bool(layout["lantern"]), "seed %s left the lantern unplanted" % run_seed)
		_expect(layout["shawl"] == Vector2i(2, 6), "seed %s kept the shawl at (2, 6)" % run_seed)
		_expect(layout["stole"] == STOLE_TILE, "seed %s kept the stole at (1, 5)" % run_seed)
		_expect(layout["mantle"] == MANTLE_TILE, "seed %s planted the mantle at (1, 6)" % run_seed)
	var again := _play(42, Callable(self, "_mantle_command"), 37)
	var replay := _play(42, Callable(self, "_mantle_command"), 37)
	_expect(str(again) == str(replay), "same seed and mantle plan replay through night 37")


func _mantle_garden_layout(seed_value: int) -> Dictionary:
	var sim = Sim.new(seed_value)
	var guard := 0
	while sim.phase == Sim.PHASE_PLANT and sim.outcome == Sim.OUTCOME_RUNNING and guard < 400:
		sim.step(_mantle_command(sim))
		guard += 1
	return {
		"lantern": sim.has_plant(Catalog.LANTERN),
		"shawl": _plant_cell(sim, Catalog.SHAWL),
		"stole": _plant_cell(sim, Catalog.STOLE),
		"mantle": _plant_cell(sim, Catalog.MANTLE),
	}


func _test_rot_rule() -> void:
	print("tippet rot rule")
	var west = Sim.new(4)
	var at_west = Sim.Command.new()
	at_west.plant_kind = Catalog.TIPPET
	at_west.tile = TIPPET_TILE
	west.step(at_west)
	_expect(west.tile_tippets_rot(1, 6) and west.tile_tippets_rot(1, 5) and west.tile_tippets_rot(2, 6) and west.tile_tippets_rot(7, 5), "a tippet at (1, 7) covers the mantle, the stole, the shawl, and the gardener")
	_expect(west.tile_tippets_rot(8, 4) and west.tile_tippets_rot(8, 5) and west.tile_tippets_rot(8, 6) and west.tile_tippets_rot(7, 4) and west.tile_tippets_rot(6, 4) and west.tile_tippets_rot(7, 6) and west.tile_tippets_rot(6, 5) and west.tile_tippets_rot(6, 6) and west.tile_tippets_rot(5, 4) and west.tile_tippets_rot(5, 5) and west.tile_tippets_rot(5, 6) and west.tile_tippets_rot(7, 3) and west.tile_tippets_rot(6, 3), "that tippet covers every tile a Smut moth needs all at once")
	_expect(not west.tile_tippets_rot(9, 5) and not west.tile_tippets_rot(9, 6), "rasp and maul sit outside the kill intersection, so missing them is not a lock miss")
	_expect(not west.tile_lit(1, 7) and not west.tile_mantles_blight(1, 7) and not west.tile_stoles_woe(1, 7), "a lone tippet does not light its tile, mantle blight, or stole woe")
	var corner = Sim.new(4)
	var at_corner = Sim.Command.new()
	at_corner.plant_kind = Catalog.TIPPET
	at_corner.tile = Vector2i(1, 1)
	corner.step(at_corner)
	_expect(corner.tile_tippets_rot(7, 5), "a tippet at (1, 1) reaches the gardener")
	_expect(not corner.tile_tippets_rot(8, 5) and not corner.tile_tippets_rot(8, 6), "that corner tippet misses the pea and the chime")
	var tippet_plant = west.plant_of_kind(Catalog.TIPPET)
	_expect(tippet_plant != null and tippet_plant.tippets_rot and not tippet_plant.wimples_mildew and not tippet_plant.casts_light and not tippet_plant.mantles_blight and not tippet_plant.stoles_woe and not tippet_plant.shawls_dread and not tippet_plant.capes_murk and not tippet_plant.cloaks_gloom and not tippet_plant.hoods_pall and not tippet_plant.cowls_veil and not tippet_plant.shades_dusk and not tippet_plant.splits_hide and not tippet_plant.burns_shroud and not tippet_plant.cracks_rind and not tippet_plant.melts_pitch and not tippet_plant.thaws_frost and not tippet_plant.cuts_web and not tippet_plant.cracks_glass and not tippet_plant.strips_scale and not tippet_plant.cracks_mail, "the tippet tippets rot and does not wimple mildew, light, mantle, stole, shawl, cape, cloak, hood, cowl, shade, split, burn, crack rind, melt, thaw, cut web, crack glass, strip scale, or crack mail")

	var idle = Sim.Command.new()
	var only = Sim.new(5)
	var sow_tippet = Sim.Command.new()
	sow_tippet.plant_kind = Catalog.TIPPET
	sow_tippet.tile = TIPPET_TILE
	only.step(sow_tippet)
	var sealed_blight = only.spawn_pest(only.tile_center(1, 7), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var opened_rot = only.spawn_pest(only.tile_center(1, 7), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var plain = only.spawn_pest(only.tile_center(1, 7), false, false, false, false, false, false, false, false, false, false, false, false, false)
	_expect(only.tile_tippets_rot(1, 7) and not only.tile_lit(1, 7) and not only.tile_mantles_blight(1, 7), "tippet marks the tile without lighting it or mantling blight")
	_expect(sealed_blight.hidden, "a tippet does not reveal a blight moth")
	_expect(not opened_rot.hidden, "a tippet reveals a rot moth on its tile")
	_expect(plain.hidden, "an ordinary moth stays hidden in a tippet with no light")
	var rot_hit := false
	var blight_hurt := false
	var guard := 0
	while guard < 200 and only.outcome == Sim.OUTCOME_RUNNING and not rot_hit:
		only.step(idle)
		guard += 1
		for event in only.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == int(opened_rot.id):
				rot_hit = true
			if int(event["pest_id"]) == int(sealed_blight.id):
				blight_hurt = true
	var blight_left = only.pest_by_id(int(sealed_blight.id))
	_expect(rot_hit, "the revealed rot moth takes a hit")
	_expect(not blight_hurt and blight_left != null and int(blight_left.hp) == Sim.PEST_HP, "shots do not hurt a blight moth standing in a tippet")

	var blocked = Sim.new(6)
	var sow_mantle = Sim.Command.new()
	sow_mantle.plant_kind = Catalog.MANTLE
	sow_mantle.tile = MANTLE_TILE
	blocked.step(sow_mantle)
	var sow_pea = Sim.Command.new()
	sow_pea.plant_kind = Catalog.PEA
	sow_pea.tile = Vector2i(8, 5)
	blocked.step(sow_pea)
	var hidden_rot = blocked.spawn_pest(blocked.tile_center(7, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var shown_blight = blocked.spawn_pest(blocked.tile_center(1, 6), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(hidden_rot.hidden and not shown_blight.hidden, "a mantle opens blight and leaves rot sealed")
	var rot_id := int(hidden_rot.id)
	var mantle_rot_hit := false
	guard = 0
	while guard < 40 and blocked.outcome == Sim.OUTCOME_RUNNING:
		blocked.step(idle)
		guard += 1
		for event in blocked.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == rot_id:
				mantle_rot_hit = true
	var rot_now = blocked.pest_by_id(rot_id)
	_expect(not mantle_rot_hit and rot_now != null and int(rot_now.hp) == Sim.PEST_HP, "a mantle does not damage a rot moth")

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	splash.step(sow_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5))
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the rot moth")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a rot moth outside a tippet")

	var touch = Sim.new(11)
	var sealed_touch = touch.spawn_pest(touch.player_pos, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(sealed_touch.hidden, "a rot moth on the gardener stays closed with no tippet")
	touch.step(idle)
	var touched = touch.pest_by_id(int(sealed_touch.id))
	_expect(touch.player_hp == Sim.PLAYER_HP - Sim.CONTACT_DAMAGE, "contact damage still lands on a closed rot moth")
	_expect(touched != null and int(touched.hp) == Sim.PEST_HP, "that contact does not count as a shot")

	var smut = Sim.new(9)
	smut.seeds = 24
	for spec in [
		[Catalog.WICK, Vector2i(6, 5)],
		[Catalog.BRIAR, Vector2i(6, 4)],
		[Catalog.FLARE, Vector2i(7, 4)],
		[Catalog.PEA, Vector2i(8, 5)],
		[Catalog.HEARTH, Vector2i(5, 5)],
		[Catalog.SHEAR, Vector2i(7, 6)],
		[Catalog.CHIME, Vector2i(8, 6)],
		[Catalog.RASP, Vector2i(9, 5)],
		[Catalog.MAUL, Vector2i(9, 6)],
		[Catalog.BILL, Vector2i(8, 4)],
		[Catalog.SHADE, Vector2i(6, 6)],
		[Catalog.COWL, Vector2i(7, 5)],
		[Catalog.HOOD, Vector2i(5, 6)],
		[Catalog.CLOAK, Vector2i(4, 6)],
		[Catalog.CAPE, Vector2i(3, 6)],
		[Catalog.SHAWL, Vector2i(2, 6)],
		[Catalog.STOLE, STOLE_TILE],
		[Catalog.MANTLE, MANTLE_TILE],
	]:
		var sow = Sim.Command.new()
		sow.plant_kind = int(spec[0])
		sow.tile = spec[1]
		smut.step(sow)
	var sealed = smut.spawn_pest(smut.tile_center(7, 4), true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true)
	var sealed_id := int(sealed.id)
	_expect(smut.tile_mantles_blight(7, 4) and not smut.tile_tippets_rot(7, 4) and sealed.hidden, "every older lock leaves a rot moth sealed")
	guard = 0
	var sealed_hit := false
	while guard < 20 and smut.outcome == Sim.OUTCOME_RUNNING:
		smut.step(idle)
		guard += 1
		for event in smut.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				sealed_hit = true
	var sealed_now = smut.pest_by_id(sealed_id)
	_expect(not sealed_hit and sealed_now != null and int(sealed_now.hp) == Sim.PEST_HP, "a smut moth ignores shots until every lock, including the tippet, is open")
	var smut_tippet = Sim.Command.new()
	smut_tippet.plant_kind = Catalog.TIPPET
	smut_tippet.tile = TIPPET_TILE
	smut.step(smut_tippet)
	var opened = smut.pest_by_id(sealed_id)
	_expect(opened != null and not opened.hidden, "tippet plus the older locks together reveal a smut moth")
	var outside = smut.spawn_pest(smut.tile_center(13, 9), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(outside.hidden, "a rot moth outside the tippet seals again")
	var opened_hit := false
	guard = 0
	while guard < 80 and smut.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		smut.step(idle)
		guard += 1
		for event in smut.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				opened_hit = true
	_expect(opened_hit, "the opened smut moth takes a hit")


func _test_thirty_eighth_nights() -> void:
	print("nights 38 and 39")
	_expect(Sim.START_SEEDS == 23, "the run starts with twenty-three seeds")
	_expect(Sim.WAVE_COUNT == 47 and Sim.WAVES.size() == 47, "forty-seven nights")
	_expect(int(Sim.WAVES[37]["count"]) == 10 and int(Sim.WAVES[37]["interval"]) == 84 and int(Sim.WAVES[37]["shroud_every"]) == 0 and int(Sim.WAVES[37]["rind_every"]) == 0 and int(Sim.WAVES[37]["pitch_every"]) == 0 and int(Sim.WAVES[37]["frost_every"]) == 0 and int(Sim.WAVES[37]["web_every"]) == 0 and int(Sim.WAVES[37]["glass_every"]) == 0 and int(Sim.WAVES[37]["scale_every"]) == 0 and int(Sim.WAVES[37]["mail_every"]) == 0 and int(Sim.WAVES[37]["hide_every"]) == 0 and int(Sim.WAVES[37]["dusk_every"]) == 0 and int(Sim.WAVES[37]["veil_every"]) == 0 and int(Sim.WAVES[37]["pall_every"]) == 0 and int(Sim.WAVES[37]["gloom_every"]) == 0 and int(Sim.WAVES[37]["murk_every"]) == 0 and int(Sim.WAVES[37]["dread_every"]) == 0 and int(Sim.WAVES[37]["woe_every"]) == 0 and int(Sim.WAVES[37]["blight_every"]) == 0 and int(Sim.WAVES[37]["rot_every"]) == 1 and str(Sim.WAVES[37]["name"]) == "Rot", "night 38 is all rot and no other lock")
	_expect(int(Sim.WAVES[38]["count"]) == 16 and int(Sim.WAVES[38]["interval"]) == 60 and int(Sim.WAVES[38]["shroud_every"]) == 2 and int(Sim.WAVES[38]["rind_every"]) == 1 and int(Sim.WAVES[38]["pitch_every"]) == 1 and int(Sim.WAVES[38]["frost_every"]) == 1 and int(Sim.WAVES[38]["web_every"]) == 1 and int(Sim.WAVES[38]["glass_every"]) == 1 and int(Sim.WAVES[38]["scale_every"]) == 1 and int(Sim.WAVES[38]["mail_every"]) == 1 and int(Sim.WAVES[38]["hide_every"]) == 1 and int(Sim.WAVES[38]["dusk_every"]) == 1 and int(Sim.WAVES[38]["veil_every"]) == 1 and int(Sim.WAVES[38]["pall_every"]) == 1 and int(Sim.WAVES[38]["gloom_every"]) == 1 and int(Sim.WAVES[38]["murk_every"]) == 1 and int(Sim.WAVES[38]["dread_every"]) == 1 and int(Sim.WAVES[38]["woe_every"]) == 1 and int(Sim.WAVES[38]["blight_every"]) == 1 and int(Sim.WAVES[38]["rot_every"]) == 1 and str(Sim.WAVES[38]["name"]) == "Smut", "night 39 is rot, blight, woe, dread, murk, gloom, pall, veil, dusk, hide, mail, scale, glass, web, frost, pitch, and rind, every second also a shroud")
	for i in 37:
		_expect(int(Sim.WAVES[i].get("rot_every", 0)) == 0, "night %d still spawns no rot" % (i + 1))
	_expect(int(Sim.WAVES[37].get("mildew_every", 0)) == 0, "night 38 Rot carries no mildew")
	_expect(int(Sim.WAVES[38].get("mildew_every", 0)) == 0, "night 39 Smut carries no mildew")
	var named = Sim.new(1)
	named.wave = 38
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 38 of 47 (Rot) — 0 pests left", "night 38 heading: %s" % named.phase_text())
	named.wave = 39
	_expect(named.phase_text() == "Night 39 of 47 (Smut) — 0 pests left", "night 39 heading: %s" % named.phase_text())
	_expect(TIPPET_TILE == Vector2i(1, 7), "the tippet landed at (1, 7) because that radius covers the mantle and every Smut lock tile")

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var bare := _play(run_seed, Callable(self, "_mantle_command"))
		print("  no tippet seed=%s outcome=%s night=%s hp=%s rot=%s/%s" % [run_seed, bare[0], bare[1], bare[4], bare[43], bare[42]])
		_expect(int(bare[0]) == Sim.OUTCOME_LOST, "seed %s dies when the mantle has no tippet" % run_seed)
		_expect(int(bare[1]) == 38, "seed %s dies on the rot night (night %s)" % [run_seed, bare[1]])
		_expect(int(bare[4]) == 0, "seed %s health reached zero on the rot night" % run_seed)
		_expect(int(bare[42]) > 0 and int(bare[43]) == 0, "seed %s left every rot moth untippetted (%s spawned, %s killed)" % [run_seed, bare[42], bare[43]])
		_expect(int(bare[40]) == 26 and int(bare[41]) == 26, "seed %s had already mantled blight before rot (%s/%s)" % [run_seed, bare[41], bare[40]])
		_expect(int(bare[8]) == 5 and int(bare[9]) == 18, "seed %s still has the nineteenth, twentieth, twenty-first, twenty-second, and twenty-third seeds unspent when rot arrives" % run_seed)
		var held := _play(run_seed, Callable(self, "_tippet_command"), 39)
		print("  tippet seed=%s outcome=%s night=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s/%s glasses=%s/%s scales=%s/%s mails=%s/%s hides=%s/%s dusk=%s/%s veil=%s/%s pall=%s/%s gloom=%s/%s murk=%s/%s dread=%s/%s woe=%s/%s blight=%s/%s rot=%s/%s" % [run_seed, held[0], held[1], held[4], held[3], held[7], held[6], held[11], held[10], held[13], held[12], held[15], held[14], held[17], held[16], held[19], held[18], held[21], held[20], held[23], held[22], held[25], held[24], held[27], held[26], held[29], held[28], held[31], held[30], held[33], held[32], held[35], held[34], held[37], held[36], held[39], held[38], held[41], held[40], held[43], held[42]])
		_expect(int(held[0]) == Sim.OUTCOME_RUNNING and int(held[2]) == Sim.PHASE_PLANT, "seed %s is still planting after night 39" % run_seed)
		_expect(int(held[1]) == 39, "seed %s cleared through night 39" % run_seed)
		_expect(int(held[4]) == 100, "seed %s finished night 39 at full health (%s)" % [run_seed, held[4]])
		_expect(int(held[6]) == 152 and int(held[7]) == 152, "seed %s burned every shroud moth (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 282 and int(held[11]) == 282, "seed %s cracked every rind moth (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 266 and int(held[13]) == 266, "seed %s melted every pitch moth (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 250 and int(held[15]) == 250, "seed %s thawed every frost moth (%s/%s)" % [run_seed, held[15], held[14]])
		_expect(int(held[16]) == 234 and int(held[17]) == 234, "seed %s cut every web moth (%s/%s)" % [run_seed, held[17], held[16]])
		_expect(int(held[18]) == 218 and int(held[19]) == 218, "seed %s cracked every glass moth (%s/%s)" % [run_seed, held[19], held[18]])
		_expect(int(held[20]) == 202 and int(held[21]) == 202, "seed %s stripped every scale moth (%s/%s)" % [run_seed, held[21], held[20]])
		_expect(int(held[22]) == 186 and int(held[23]) == 186, "seed %s cracked every mail moth (%s/%s)" % [run_seed, held[23], held[22]])
		_expect(int(held[24]) == 170 and int(held[25]) == 170, "seed %s split every hide moth (%s/%s)" % [run_seed, held[25], held[24]])
		_expect(int(held[26]) == 154 and int(held[27]) == 154, "seed %s shaded every dusk moth (%s/%s)" % [run_seed, held[27], held[26]])
		_expect(int(held[28]) == 138 and int(held[29]) == 138, "seed %s cowled every veil moth (%s/%s)" % [run_seed, held[29], held[28]])
		_expect(int(held[30]) == 122 and int(held[31]) == 122, "seed %s hooded every pall moth (%s/%s)" % [run_seed, held[31], held[30]])
		_expect(int(held[32]) == 106 and int(held[33]) == 106, "seed %s cloaked every gloom moth (%s/%s)" % [run_seed, held[33], held[32]])
		_expect(int(held[34]) == 90 and int(held[35]) == 90, "seed %s caped every murk moth (%s/%s)" % [run_seed, held[35], held[34]])
		_expect(int(held[36]) == 74 and int(held[37]) == 74, "seed %s shawled every dread moth (%s/%s)" % [run_seed, held[37], held[36]])
		_expect(int(held[38]) == 58 and int(held[39]) == 58, "seed %s stoled every woe moth (%s/%s)" % [run_seed, held[39], held[38]])
		_expect(int(held[40]) == 42 and int(held[41]) == 42, "seed %s mantled every blight moth (%s/%s)" % [run_seed, held[41], held[40]])
		_expect(int(held[42]) == 26 and int(held[43]) == 26, "seed %s tippetted every rot moth (%s/%s)" % [run_seed, held[43], held[42]])
		_expect(int(held[44]) == 0 and int(held[45]) == 0, "seed %s meets no mildew moth before night 40" % run_seed)
		_expect(int(held[8]) == 4 and int(held[9]) == 19, "seed %s spent nineteen seeds and left the twentieth, twenty-first, twenty-second, and twenty-third unspent" % run_seed)
		var fell := _play(run_seed, Callable(self, "_tippet_command"))
		print("  no wimple seed=%s outcome=%s night=%s hp=%s mildew=%s/%s" % [run_seed, fell[0], fell[1], fell[4], fell[45], fell[44]])
		_expect(int(fell[0]) == Sim.OUTCOME_LOST, "seed %s dies when the tippet has no wimple" % run_seed)
		_expect(int(fell[1]) == 40, "seed %s dies on the mildew night (night %s)" % [run_seed, fell[1]])
		_expect(int(fell[4]) == 0, "seed %s health reached zero on the mildew night" % run_seed)
		_expect(int(fell[44]) > 0 and int(fell[45]) == 0, "seed %s left every mildew moth unwimpled (%s spawned, %s killed)" % [run_seed, fell[44], fell[45]])
		_expect(int(fell[42]) == 26 and int(fell[43]) == 26, "seed %s had already tippetted rot before mildew (%s/%s)" % [run_seed, fell[43], fell[42]])
		_expect(int(fell[8]) == 4 and int(fell[9]) == 19, "seed %s still has the twentieth, twenty-first, twenty-second, and twenty-third seeds unspent when mildew arrives" % run_seed)
		var layout := _tippet_garden_layout(run_seed)
		_expect(not bool(layout["lantern"]), "seed %s left the lantern unplanted" % run_seed)
		_expect(layout["shawl"] == Vector2i(2, 6), "seed %s kept the shawl at (2, 6)" % run_seed)
		_expect(layout["stole"] == STOLE_TILE, "seed %s kept the stole at (1, 5)" % run_seed)
		_expect(layout["mantle"] == MANTLE_TILE, "seed %s kept the mantle at (1, 6)" % run_seed)
		_expect(layout["tippet"] == TIPPET_TILE, "seed %s planted the tippet at (1, 7)" % run_seed)
		var missed := _play(run_seed, Callable(self, "_corner_tippet_command"), 39)
		print("  corner tippet seed=%s outcome=%s night=%s hp=%s rot=%s/%s" % [run_seed, missed[0], missed[1], missed[4], missed[43], missed[42]])
		# (1, 1) still tippets the gardener, so night 38 is not a sealed death. It misses the pea and the chime. The other plants stay put. Seeds 1, 7, 99, 256, and 2026 finish night 39 damaged. Seed 42 still kills every rot moth before contact and finishes at full health. The run stops before mildew, which this tippet cannot open.
		var corner_hp := 100
		if run_seed == 1 or run_seed == 256:
			corner_hp = 60
		elif run_seed == 7 or run_seed == 99:
			corner_hp = 40
		elif run_seed == 2026:
			corner_hp = 80
		_expect(int(missed[0]) == Sim.OUTCOME_RUNNING and int(missed[2]) == Sim.PHASE_PLANT and int(missed[1]) == 39, "seed %s with a corner tippet finishes night 39 (outcome %s night %s)" % [run_seed, missed[0], missed[1]])
		_expect(int(missed[4]) == corner_hp, "seed %s corner tippet health is %s (got %s)" % [run_seed, corner_hp, missed[4]])
		_expect(int(missed[42]) == 26 and int(missed[43]) == 26, "seed %s corner tippet still tippetted every rot moth (%s/%s)" % [run_seed, missed[43], missed[42]])
	var again := _play(42, Callable(self, "_tippet_command"))
	var replay := _play(42, Callable(self, "_tippet_command"))
	_expect(str(again) == str(replay), "same seed and tippet plan replay")


func _tippet_garden_layout(seed_value: int) -> Dictionary:
	var sim = Sim.new(seed_value)
	var guard := 0
	while sim.phase == Sim.PHASE_PLANT and sim.outcome == Sim.OUTCOME_RUNNING and guard < 400:
		sim.step(_tippet_command(sim))
		guard += 1
	return {
		"lantern": sim.has_plant(Catalog.LANTERN),
		"shawl": _plant_cell(sim, Catalog.SHAWL),
		"stole": _plant_cell(sim, Catalog.STOLE),
		"mantle": _plant_cell(sim, Catalog.MANTLE),
		"tippet": _plant_cell(sim, Catalog.TIPPET),
	}


func _test_mildew_rule() -> void:
	print("wimple mildew rule")
	var west = Sim.new(4)
	var at_west = Sim.Command.new()
	at_west.plant_kind = Catalog.WIMPLE
	at_west.tile = WIMPLE_TILE
	west.step(at_west)
	_expect(west.tile_wimples_mildew(1, 7) and west.tile_wimples_mildew(1, 6) and west.tile_wimples_mildew(1, 5) and west.tile_wimples_mildew(2, 6) and west.tile_wimples_mildew(7, 5), "a wimple at (1, 8) covers the tippet, the mantle, the stole, the shawl, and the gardener")
	_expect(west.tile_wimples_mildew(8, 4) and west.tile_wimples_mildew(8, 5) and west.tile_wimples_mildew(8, 6) and west.tile_wimples_mildew(7, 4) and west.tile_wimples_mildew(6, 4) and west.tile_wimples_mildew(7, 6) and west.tile_wimples_mildew(6, 5) and west.tile_wimples_mildew(6, 6) and west.tile_wimples_mildew(5, 4) and west.tile_wimples_mildew(5, 5) and west.tile_wimples_mildew(5, 6) and west.tile_wimples_mildew(7, 3) and west.tile_wimples_mildew(6, 3), "that wimple covers every tile an Ergot moth needs all at once")
	_expect(not west.tile_wimples_mildew(9, 5), "rasp at (9, 5) sits outside the 368px wimple")
	_expect(not west.tile_lit(1, 8) and not west.tile_tippets_rot(1, 8) and not west.tile_mantles_blight(1, 8), "a lone wimple does not light its tile, tippet rot, or mantle blight")
	var tippet_only = Sim.new(4)
	var sow_tippet_only = Sim.Command.new()
	sow_tippet_only.plant_kind = Catalog.TIPPET
	sow_tippet_only.tile = TIPPET_TILE
	tippet_only.step(sow_tippet_only)
	_expect(tippet_only.tile_tippets_rot(1, 7) and not tippet_only.tile_wimples_mildew(1, 7), "a tippet does not wimple mildew")
	var corner = Sim.new(4)
	var at_corner = Sim.Command.new()
	at_corner.plant_kind = Catalog.WIMPLE
	at_corner.tile = Vector2i(1, 1)
	corner.step(at_corner)
	_expect(corner.tile_wimples_mildew(7, 5), "a wimple at (1, 1) reaches the gardener")
	var wimple_plant = west.plant_of_kind(Catalog.WIMPLE)
	_expect(wimple_plant != null and wimple_plant.wimples_mildew and not wimple_plant.albs_rust and not wimple_plant.casts_light and not wimple_plant.tippets_rot and not wimple_plant.mantles_blight and not wimple_plant.stoles_woe and not wimple_plant.shawls_dread and not wimple_plant.capes_murk and not wimple_plant.cloaks_gloom and not wimple_plant.hoods_pall and not wimple_plant.cowls_veil and not wimple_plant.shades_dusk and not wimple_plant.splits_hide and not wimple_plant.burns_shroud and not wimple_plant.cracks_rind and not wimple_plant.melts_pitch and not wimple_plant.thaws_frost and not wimple_plant.cuts_web and not wimple_plant.cracks_glass and not wimple_plant.strips_scale and not wimple_plant.cracks_mail, "the wimple wimples mildew and does not alb rust, light, tippet, mantle, stole, shawl, cape, cloak, hood, cowl, shade, split, burn, crack rind, melt, thaw, cut web, crack glass, strip scale, or crack mail")

	var idle = Sim.Command.new()
	var lamp = Sim.new(5)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	lamp.step(sow_lamp)
	var lamp_mildew = lamp.spawn_pest(lamp.tile_center(7, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(lamp.tile_lit(7, 5) and lamp_mildew.hidden, "ordinary light does not reveal a mildew moth")

	var only = Sim.new(6)
	var sow_wimple = Sim.Command.new()
	sow_wimple.plant_kind = Catalog.WIMPLE
	sow_wimple.tile = WIMPLE_TILE
	only.step(sow_wimple)
	var sealed_rot = only.spawn_pest(only.tile_center(1, 8), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var opened_mildew = only.spawn_pest(only.tile_center(1, 8), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var both = only.spawn_pest(only.tile_center(1, 8), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true)
	_expect(only.tile_wimples_mildew(1, 8) and not only.tile_lit(1, 8) and not only.tile_tippets_rot(1, 8), "wimple marks the tile without lighting it or tippeting rot")
	_expect(sealed_rot.hidden, "a wimple does not reveal a rot moth")
	_expect(not opened_mildew.hidden, "a wimple reveals a mildew moth on its tile")
	_expect(both.hidden, "mildew plus rot stays closed until the tippet is open too")
	var mildew_hit := false
	var rot_hurt := false
	var guard := 0
	while guard < 200 and only.outcome == Sim.OUTCOME_RUNNING and not mildew_hit:
		only.step(idle)
		guard += 1
		for event in only.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == int(opened_mildew.id):
				mildew_hit = true
			if int(event["pest_id"]) == int(sealed_rot.id):
				rot_hurt = true
	var rot_left = only.pest_by_id(int(sealed_rot.id))
	_expect(mildew_hit, "the revealed mildew moth takes a hit")
	_expect(not rot_hurt and rot_left != null and int(rot_left.hp) == Sim.PEST_HP, "shots do not hurt a rot moth standing in a wimple")

	var blocked = Sim.new(7)
	var sow_tippet = Sim.Command.new()
	sow_tippet.plant_kind = Catalog.TIPPET
	sow_tippet.tile = TIPPET_TILE
	blocked.step(sow_tippet)
	var hidden_mildew = blocked.spawn_pest(blocked.tile_center(1, 7), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(blocked.tile_tippets_rot(1, 7) and hidden_mildew.hidden, "a tippet opens rot and leaves mildew sealed")
	var mildew_id := int(hidden_mildew.id)
	var tippet_mildew_hit := false
	guard = 0
	while guard < 40 and blocked.outcome == Sim.OUTCOME_RUNNING:
		blocked.step(idle)
		guard += 1
		for event in blocked.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == mildew_id:
				tippet_mildew_hit = true
	var mildew_now = blocked.pest_by_id(mildew_id)
	_expect(not tippet_mildew_hit and mildew_now != null and int(mildew_now.hp) == Sim.PEST_HP, "a tippet does not damage a mildew moth")

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_splash_lamp = Sim.Command.new()
	sow_splash_lamp.plant_kind = Catalog.LANTERN
	sow_splash_lamp.tile = Vector2i(7, 5)
	splash.step(sow_splash_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5))
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the mildew moth")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a mildew moth outside a wimple")

	var touch = Sim.new(11)
	var sealed_touch = touch.spawn_pest(touch.player_pos, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(sealed_touch.hidden, "a mildew moth on the gardener stays closed with no wimple")
	touch.step(idle)
	var touched = touch.pest_by_id(int(sealed_touch.id))
	_expect(touch.player_hp == Sim.PLAYER_HP - Sim.CONTACT_DAMAGE, "contact damage still lands on a closed mildew moth")
	_expect(touched != null and int(touched.hp) == Sim.PEST_HP, "that contact does not count as a shot")

	var ergot = Sim.new(9)
	ergot.seeds = 24
	for spec in [
		[Catalog.WICK, Vector2i(6, 5)],
		[Catalog.BRIAR, Vector2i(6, 4)],
		[Catalog.FLARE, Vector2i(7, 4)],
		[Catalog.PEA, Vector2i(8, 5)],
		[Catalog.HEARTH, Vector2i(5, 5)],
		[Catalog.SHEAR, Vector2i(7, 6)],
		[Catalog.CHIME, Vector2i(8, 6)],
		[Catalog.RASP, Vector2i(9, 5)],
		[Catalog.MAUL, Vector2i(9, 6)],
		[Catalog.BILL, Vector2i(8, 4)],
		[Catalog.SHADE, Vector2i(6, 6)],
		[Catalog.COWL, Vector2i(7, 5)],
		[Catalog.HOOD, Vector2i(5, 6)],
		[Catalog.CLOAK, Vector2i(4, 6)],
		[Catalog.CAPE, Vector2i(3, 6)],
		[Catalog.SHAWL, Vector2i(2, 6)],
		[Catalog.STOLE, STOLE_TILE],
		[Catalog.MANTLE, MANTLE_TILE],
		[Catalog.TIPPET, TIPPET_TILE],
	]:
		var sow = Sim.Command.new()
		sow.plant_kind = int(spec[0])
		sow.tile = spec[1]
		ergot.step(sow)
	var sealed = ergot.spawn_pest(ergot.tile_center(7, 4), true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true)
	var sealed_id := int(sealed.id)
	_expect(ergot.tile_tippets_rot(7, 4) and not ergot.tile_wimples_mildew(7, 4) and sealed.hidden, "every older lock leaves a mildew moth sealed")
	guard = 0
	var sealed_hit := false
	while guard < 20 and ergot.outcome == Sim.OUTCOME_RUNNING:
		ergot.step(idle)
		guard += 1
		for event in ergot.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				sealed_hit = true
	var sealed_now = ergot.pest_by_id(sealed_id)
	_expect(not sealed_hit and sealed_now != null and int(sealed_now.hp) == Sim.PEST_HP, "an ergot moth ignores shots until every lock, including the wimple, is open")
	var ergot_wimple = Sim.Command.new()
	ergot_wimple.plant_kind = Catalog.WIMPLE
	ergot_wimple.tile = WIMPLE_TILE
	ergot.step(ergot_wimple)
	var opened = ergot.pest_by_id(sealed_id)
	_expect(opened != null and not opened.hidden, "wimple plus the older locks together reveal an ergot moth")
	var outside = ergot.spawn_pest(ergot.tile_center(13, 9), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(outside.hidden, "a mildew moth outside the wimple seals again")
	var opened_hit := false
	guard = 0
	while guard < 80 and ergot.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		ergot.step(idle)
		guard += 1
		for event in ergot.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				opened_hit = true
	_expect(opened_hit, "the opened ergot moth takes a hit")


func _test_fortieth_nights() -> void:
	print("nights 40 and 41")
	_expect(Sim.START_SEEDS == 23, "the run starts with twenty-three seeds")
	_expect(Sim.WAVE_COUNT == 47 and Sim.WAVES.size() == 47, "forty-seven nights")
	_expect(int(Sim.WAVES[39]["count"]) == 10 and int(Sim.WAVES[39]["interval"]) == 90 and int(Sim.WAVES[39]["shroud_every"]) == 0 and int(Sim.WAVES[39]["rind_every"]) == 0 and int(Sim.WAVES[39]["pitch_every"]) == 0 and int(Sim.WAVES[39]["frost_every"]) == 0 and int(Sim.WAVES[39]["web_every"]) == 0 and int(Sim.WAVES[39]["glass_every"]) == 0 and int(Sim.WAVES[39]["scale_every"]) == 0 and int(Sim.WAVES[39]["mail_every"]) == 0 and int(Sim.WAVES[39]["hide_every"]) == 0 and int(Sim.WAVES[39]["dusk_every"]) == 0 and int(Sim.WAVES[39]["veil_every"]) == 0 and int(Sim.WAVES[39]["pall_every"]) == 0 and int(Sim.WAVES[39]["gloom_every"]) == 0 and int(Sim.WAVES[39]["murk_every"]) == 0 and int(Sim.WAVES[39]["dread_every"]) == 0 and int(Sim.WAVES[39]["woe_every"]) == 0 and int(Sim.WAVES[39]["blight_every"]) == 0 and int(Sim.WAVES[39]["rot_every"]) == 0 and int(Sim.WAVES[39]["mildew_every"]) == 1 and str(Sim.WAVES[39]["name"]) == "Mildew", "night 40 is all mildew and no other lock")
	_expect(int(Sim.WAVES[40]["count"]) == 16 and int(Sim.WAVES[40]["interval"]) == 60 and int(Sim.WAVES[40]["shroud_every"]) == 2 and int(Sim.WAVES[40]["rind_every"]) == 1 and int(Sim.WAVES[40]["pitch_every"]) == 1 and int(Sim.WAVES[40]["frost_every"]) == 1 and int(Sim.WAVES[40]["web_every"]) == 1 and int(Sim.WAVES[40]["glass_every"]) == 1 and int(Sim.WAVES[40]["scale_every"]) == 1 and int(Sim.WAVES[40]["mail_every"]) == 1 and int(Sim.WAVES[40]["hide_every"]) == 1 and int(Sim.WAVES[40]["dusk_every"]) == 1 and int(Sim.WAVES[40]["veil_every"]) == 1 and int(Sim.WAVES[40]["pall_every"]) == 1 and int(Sim.WAVES[40]["gloom_every"]) == 1 and int(Sim.WAVES[40]["murk_every"]) == 1 and int(Sim.WAVES[40]["dread_every"]) == 1 and int(Sim.WAVES[40]["woe_every"]) == 1 and int(Sim.WAVES[40]["blight_every"]) == 1 and int(Sim.WAVES[40]["rot_every"]) == 1 and int(Sim.WAVES[40]["mildew_every"]) == 1 and str(Sim.WAVES[40]["name"]) == "Ergot", "night 41 is mildew, rot, blight, woe, dread, murk, gloom, pall, veil, dusk, hide, mail, scale, glass, web, frost, pitch, and rind, every second also a shroud")
	for i in 39:
		_expect(int(Sim.WAVES[i].get("mildew_every", 0)) == 0, "night %d still spawns no mildew" % (i + 1))
	_expect(int(Sim.WAVES[35].get("mildew_every", 0)) == 0 and int(Sim.WAVES[36].get("mildew_every", 0)) == 0, "Gall and Canker still carry no mildew")
	_expect(int(Sim.WAVES[37].get("mildew_every", 0)) == 0 and int(Sim.WAVES[38].get("mildew_every", 0)) == 0, "Rot and Smut still carry no mildew")
	_expect(int(Sim.WAVES[35].get("rot_every", 0)) == 0 and int(Sim.WAVES[36].get("rot_every", 0)) == 0, "Gall and Canker still carry no rot")
	for i in 41:
		_expect(int(Sim.WAVES[i].get("rust_every", 0)) == 0, "night %d still spawns no rust" % (i + 1))
	_expect(str(Sim.WAVES[39]["name"]) == "Mildew" and int(Sim.WAVES[39].get("rust_every", 0)) == 0, "night 40 stays Mildew and carries no rust")
	_expect(str(Sim.WAVES[40]["name"]) == "Ergot" and int(Sim.WAVES[40].get("rust_every", 0)) == 0, "night 41 stays Ergot and carries no rust")
	var named = Sim.new(1)
	named.wave = 40
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 40 of 47 (Mildew) — 0 pests left", "night 40 heading: %s" % named.phase_text())
	named.wave = 41
	_expect(named.phase_text() == "Night 41 of 47 (Ergot) — 0 pests left", "night 41 heading: %s" % named.phase_text())
	_expect(WIMPLE_TILE == Vector2i(1, 8), "the wimple landed at (1, 8) because that radius covers the tippet and every Ergot lock tile")

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var held := _play(run_seed, Callable(self, "_wimple_command"), 41)
		print("  wimple seed=%s outcome=%s night=%s hp=%s mildew=%s/%s" % [run_seed, held[0], held[1], held[4], held[45], held[44]])
		_expect(int(held[0]) == Sim.OUTCOME_RUNNING and int(held[2]) == Sim.PHASE_PLANT, "seed %s is still planting after night 41" % run_seed)
		_expect(int(held[1]) == 41, "seed %s cleared through night 41" % run_seed)
		_expect(int(held[4]) == 100, "seed %s finished night 41 at full health (%s)" % [run_seed, held[4]])
		_expect(int(held[6]) == 160 and int(held[7]) == 160, "seed %s burned every shroud moth (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 298 and int(held[11]) == 298, "seed %s cracked every rind moth (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 282 and int(held[13]) == 282, "seed %s melted every pitch moth (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 266 and int(held[15]) == 266, "seed %s thawed every frost moth (%s/%s)" % [run_seed, held[15], held[14]])
		_expect(int(held[16]) == 250 and int(held[17]) == 250, "seed %s cut every web moth (%s/%s)" % [run_seed, held[17], held[16]])
		_expect(int(held[18]) == 234 and int(held[19]) == 234, "seed %s cracked every glass moth (%s/%s)" % [run_seed, held[19], held[18]])
		_expect(int(held[20]) == 218 and int(held[21]) == 218, "seed %s stripped every scale moth (%s/%s)" % [run_seed, held[21], held[20]])
		_expect(int(held[22]) == 202 and int(held[23]) == 202, "seed %s cracked every mail moth (%s/%s)" % [run_seed, held[23], held[22]])
		_expect(int(held[24]) == 186 and int(held[25]) == 186, "seed %s split every hide moth (%s/%s)" % [run_seed, held[25], held[24]])
		_expect(int(held[26]) == 170 and int(held[27]) == 170, "seed %s shaded every dusk moth (%s/%s)" % [run_seed, held[27], held[26]])
		_expect(int(held[28]) == 154 and int(held[29]) == 154, "seed %s cowled every veil moth (%s/%s)" % [run_seed, held[29], held[28]])
		_expect(int(held[30]) == 138 and int(held[31]) == 138, "seed %s hooded every pall moth (%s/%s)" % [run_seed, held[31], held[30]])
		_expect(int(held[32]) == 122 and int(held[33]) == 122, "seed %s cloaked every gloom moth (%s/%s)" % [run_seed, held[33], held[32]])
		_expect(int(held[34]) == 106 and int(held[35]) == 106, "seed %s caped every murk moth (%s/%s)" % [run_seed, held[35], held[34]])
		_expect(int(held[36]) == 90 and int(held[37]) == 90, "seed %s shawled every dread moth (%s/%s)" % [run_seed, held[37], held[36]])
		_expect(int(held[38]) == 74 and int(held[39]) == 74, "seed %s stoled every woe moth (%s/%s)" % [run_seed, held[39], held[38]])
		_expect(int(held[40]) == 58 and int(held[41]) == 58, "seed %s mantled every blight moth (%s/%s)" % [run_seed, held[41], held[40]])
		_expect(int(held[42]) == 42 and int(held[43]) == 42, "seed %s tippetted every rot moth (%s/%s)" % [run_seed, held[43], held[42]])
		_expect(int(held[44]) == 26 and int(held[45]) == 26, "seed %s wimpled every mildew moth (%s/%s)" % [run_seed, held[45], held[44]])
		_expect(int(held[46]) == 0 and int(held[47]) == 0, "seed %s meets no rust moth before night 42" % run_seed)
		_expect(int(held[8]) == 3 and int(held[9]) == 20, "seed %s spent twenty seeds and left the twenty-first, twenty-second, and twenty-third unspent" % run_seed)
		var layout := _wimple_garden_layout(run_seed)
		_expect(not bool(layout["lantern"]), "seed %s left the lantern unplanted" % run_seed)
		_expect(layout["shawl"] == Vector2i(2, 6), "seed %s kept the shawl at (2, 6)" % run_seed)
		_expect(layout["stole"] == STOLE_TILE, "seed %s kept the stole at (1, 5)" % run_seed)
		_expect(layout["mantle"] == MANTLE_TILE, "seed %s kept the mantle at (1, 6)" % run_seed)
		_expect(layout["tippet"] == TIPPET_TILE, "seed %s kept the tippet at (1, 7)" % run_seed)
		_expect(layout["wimple"] == WIMPLE_TILE, "seed %s planted the wimple at (1, 8)" % run_seed)
		var fell := _play(run_seed, Callable(self, "_wimple_command"))
		print("  no alb seed=%s outcome=%s night=%s hp=%s rust=%s/%s" % [run_seed, fell[0], fell[1], fell[4], fell[47], fell[46]])
		_expect(int(fell[0]) == Sim.OUTCOME_LOST, "seed %s dies when the wimple has no alb" % run_seed)
		_expect(int(fell[1]) == 42, "seed %s dies on the rust night (night %s)" % [run_seed, fell[1]])
		_expect(int(fell[4]) == 0, "seed %s health reached zero on the rust night" % run_seed)
		_expect(int(fell[46]) > 0 and int(fell[47]) == 0, "seed %s left every rust moth unalbed (%s spawned, %s killed)" % [run_seed, fell[46], fell[47]])
		_expect(int(fell[44]) == 26 and int(fell[45]) == 26, "seed %s had already wimpled mildew before rust (%s/%s)" % [run_seed, fell[45], fell[44]])
		_expect(int(fell[8]) == 3 and int(fell[9]) == 20, "seed %s still has the twenty-first, twenty-second, and twenty-third seeds unspent when rust arrives" % run_seed)
		var missed := _play(run_seed, Callable(self, "_corner_wimple_command"), 41)
		print("  corner wimple seed=%s outcome=%s night=%s hp=%s mildew=%s/%s" % [run_seed, missed[0], missed[1], missed[4], missed[45], missed[44]])
		# (1, 1) still wimples the gardener, so night 40 is not a sealed death. The other plants stay put. The run stops before rust, which this wimple cannot open. Every seed finishes night 41 with every mildew moth killed.
		_expect(int(missed[0]) == Sim.OUTCOME_RUNNING and int(missed[2]) == Sim.PHASE_PLANT and int(missed[1]) == 41, "seed %s with a corner wimple finishes night 41 (outcome %s night %s)" % [run_seed, missed[0], missed[1]])
		_expect(int(missed[4]) == 100, "seed %s corner wimple health is 100 (got %s)" % [run_seed, missed[4]])
		_expect(int(missed[44]) == 26 and int(missed[45]) == 26, "seed %s corner wimple still wimpled every mildew moth (%s/%s)" % [run_seed, missed[45], missed[44]])
		var corner_layout := _corner_wimple_garden_layout(run_seed)
		_expect(corner_layout["tippet"] == TIPPET_TILE and corner_layout["wimple"] == Vector2i(1, 1), "seed %s kept the tippet at (1, 7) and put the wimple at (1, 1)" % run_seed)
		_expect(corner_layout["shawl"] == Vector2i(2, 6) and corner_layout["stole"] == STOLE_TILE and corner_layout["mantle"] == MANTLE_TILE, "seed %s left the shawl, the stole, and the mantle where they were" % run_seed)
	var again := _play(42, Callable(self, "_wimple_command"))
	var replay := _play(42, Callable(self, "_wimple_command"))
	_expect(str(again) == str(replay), "same seed and wimple plan replay")


func _wimple_garden_layout(seed_value: int) -> Dictionary:
	return _layout_for(seed_value, Callable(self, "_wimple_command"))


func _corner_wimple_garden_layout(seed_value: int) -> Dictionary:
	return _layout_for(seed_value, Callable(self, "_corner_wimple_command"))


func _layout_for(seed_value: int, command: Callable) -> Dictionary:
	var sim = Sim.new(seed_value)
	var guard := 0
	while sim.phase == Sim.PHASE_PLANT and sim.outcome == Sim.OUTCOME_RUNNING and guard < 400:
		sim.step(command.call(sim))
		guard += 1
	return {
		"lantern": sim.has_plant(Catalog.LANTERN),
		"shawl": _plant_cell(sim, Catalog.SHAWL),
		"stole": _plant_cell(sim, Catalog.STOLE),
		"mantle": _plant_cell(sim, Catalog.MANTLE),
		"tippet": _plant_cell(sim, Catalog.TIPPET),
		"wimple": _plant_cell(sim, Catalog.WIMPLE),
		"alb": _plant_cell(sim, Catalog.ALB),
		"amice": _plant_cell(sim, Catalog.AMICE),
		"orphrey": _plant_cell(sim, Catalog.ORPHREY),
	}


func _alb_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6), Vector2i(4, 6), Vector2i(3, 6), Vector2i(2, 6), STOLE_TILE, MANTLE_TILE, TIPPET_TILE, WIMPLE_TILE, ALB_TILE)


func _corner_alb_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6), Vector2i(4, 6), Vector2i(3, 6), Vector2i(2, 6), STOLE_TILE, MANTLE_TILE, TIPPET_TILE, WIMPLE_TILE, Vector2i(1, 1))


func _test_rust_rule() -> void:
	print("alb rust rule")
	var west = Sim.new(4)
	var at_west = Sim.Command.new()
	at_west.plant_kind = Catalog.ALB
	at_west.tile = ALB_TILE
	west.step(at_west)
	_expect(west.tile_albs_rust(1, 8) and west.tile_albs_rust(1, 7) and west.tile_albs_rust(1, 6) and west.tile_albs_rust(1, 5) and west.tile_albs_rust(2, 6) and west.tile_albs_rust(7, 5), "an alb at (1, 9) covers the wimple, the tippet, the mantle, the stole, the shawl, and the gardener")
	_expect(west.tile_albs_rust(8, 4) and west.tile_albs_rust(8, 5) and west.tile_albs_rust(8, 6) and west.tile_albs_rust(7, 4) and west.tile_albs_rust(6, 4) and west.tile_albs_rust(7, 6) and west.tile_albs_rust(6, 5) and west.tile_albs_rust(6, 6) and west.tile_albs_rust(5, 4) and west.tile_albs_rust(5, 5) and west.tile_albs_rust(5, 6) and west.tile_albs_rust(7, 3) and west.tile_albs_rust(6, 3), "that alb covers every tile a Brand moth needs all at once")
	_expect(not west.tile_albs_rust(9, 5), "rasp at (9, 5) sits outside the 384px alb")
	_expect(west.tile_albs_rust(9, 6), "maul at (9, 6) sits inside the 384px alb")
	_expect(not west.tile_lit(1, 9) and not west.tile_wimples_mildew(1, 9) and not west.tile_tippets_rot(1, 9), "a lone alb does not light its tile, wimple mildew, or tippet rot")
	var wick_and_alb = Sim.new(4)
	var sow_wick = Sim.Command.new()
	sow_wick.plant_kind = Catalog.WICK
	sow_wick.tile = Vector2i(6, 5)
	wick_and_alb.step(sow_wick)
	var sow_alb_beside = Sim.Command.new()
	sow_alb_beside.plant_kind = Catalog.ALB
	sow_alb_beside.tile = ALB_TILE
	wick_and_alb.step(sow_alb_beside)
	_expect(wick_and_alb.tile_albs_rust(9, 6) and not wick_and_alb.tile_burns_shroud(9, 6), "maul is inside the alb and outside the shared kill intersection")
	var wimple_only = Sim.new(4)
	var sow_wimple_only = Sim.Command.new()
	sow_wimple_only.plant_kind = Catalog.WIMPLE
	sow_wimple_only.tile = WIMPLE_TILE
	wimple_only.step(sow_wimple_only)
	_expect(wimple_only.tile_wimples_mildew(1, 8) and not wimple_only.tile_albs_rust(1, 8), "a wimple does not alb rust")
	var corner = Sim.new(4)
	var at_corner = Sim.Command.new()
	at_corner.plant_kind = Catalog.ALB
	at_corner.tile = Vector2i(1, 1)
	corner.step(at_corner)
	_expect(corner.tile_albs_rust(7, 5), "an alb at (1, 1) reaches the gardener")
	var alb_plant = west.plant_of_kind(Catalog.ALB)
	_expect(alb_plant != null and alb_plant.albs_rust and not alb_plant.casts_light and not alb_plant.wimples_mildew and not alb_plant.tippets_rot and not alb_plant.mantles_blight and not alb_plant.stoles_woe and not alb_plant.shawls_dread and not alb_plant.capes_murk and not alb_plant.cloaks_gloom and not alb_plant.hoods_pall and not alb_plant.cowls_veil and not alb_plant.shades_dusk and not alb_plant.splits_hide and not alb_plant.burns_shroud and not alb_plant.cracks_rind and not alb_plant.melts_pitch and not alb_plant.thaws_frost and not alb_plant.cuts_web and not alb_plant.cracks_glass and not alb_plant.strips_scale and not alb_plant.cracks_mail, "the alb albs rust and does not light, wimple, tippet, mantle, stole, shawl, cape, cloak, hood, cowl, shade, split, burn, crack rind, melt, thaw, cut web, crack glass, strip scale, or crack mail")

	var idle = Sim.Command.new()
	var lamp = Sim.new(5)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	lamp.step(sow_lamp)
	var lamp_rust = lamp.spawn_pest(lamp.tile_center(7, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(lamp.tile_lit(7, 5) and lamp_rust.hidden, "ordinary light does not reveal a rust moth")

	var only = Sim.new(6)
	var sow_alb = Sim.Command.new()
	sow_alb.plant_kind = Catalog.ALB
	sow_alb.tile = ALB_TILE
	only.step(sow_alb)
	var sealed_mildew = only.spawn_pest(only.tile_center(1, 9), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var opened_rust = only.spawn_pest(only.tile_center(1, 9), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var both = only.spawn_pest(only.tile_center(1, 9), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true)
	_expect(only.tile_albs_rust(1, 9) and not only.tile_lit(1, 9) and not only.tile_wimples_mildew(1, 9), "alb marks the tile without lighting it or wimpling mildew")
	_expect(sealed_mildew.hidden, "an alb does not reveal a mildew moth")
	_expect(not opened_rust.hidden, "an alb reveals a rust moth on its tile")
	_expect(both.hidden, "rust plus mildew stays closed until the wimple is open too")
	var rust_hit := false
	var mildew_hurt := false
	var guard := 0
	while guard < 200 and only.outcome == Sim.OUTCOME_RUNNING and not rust_hit:
		only.step(idle)
		guard += 1
		for event in only.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == int(opened_rust.id):
				rust_hit = true
			if int(event["pest_id"]) == int(sealed_mildew.id):
				mildew_hurt = true
	var mildew_left = only.pest_by_id(int(sealed_mildew.id))
	_expect(rust_hit, "the revealed rust moth takes a hit")
	_expect(not mildew_hurt and mildew_left != null and int(mildew_left.hp) == Sim.PEST_HP, "shots do not hurt a mildew moth standing in an alb")

	var blocked = Sim.new(7)
	var sow_wimple = Sim.Command.new()
	sow_wimple.plant_kind = Catalog.WIMPLE
	sow_wimple.tile = WIMPLE_TILE
	blocked.step(sow_wimple)
	var hidden_rust = blocked.spawn_pest(blocked.tile_center(1, 8), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(blocked.tile_wimples_mildew(1, 8) and hidden_rust.hidden, "a wimple opens mildew and leaves rust sealed")
	var rust_id := int(hidden_rust.id)
	var wimple_rust_hit := false
	guard = 0
	while guard < 40 and blocked.outcome == Sim.OUTCOME_RUNNING:
		blocked.step(idle)
		guard += 1
		for event in blocked.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == rust_id:
				wimple_rust_hit = true
	var rust_now = blocked.pest_by_id(rust_id)
	_expect(not wimple_rust_hit and rust_now != null and int(rust_now.hp) == Sim.PEST_HP, "a wimple does not damage a rust moth")

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_splash_lamp = Sim.Command.new()
	sow_splash_lamp.plant_kind = Catalog.LANTERN
	sow_splash_lamp.tile = Vector2i(7, 5)
	splash.step(sow_splash_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5))
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the rust moth")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a rust moth outside an alb")

	var touch = Sim.new(11)
	var sealed_touch = touch.spawn_pest(touch.player_pos, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(sealed_touch.hidden, "a rust moth on the gardener stays closed with no alb")
	touch.step(idle)
	var touched = touch.pest_by_id(int(sealed_touch.id))
	_expect(touch.player_hp == Sim.PLAYER_HP - Sim.CONTACT_DAMAGE, "contact damage still lands on a closed rust moth")
	_expect(touched != null and int(touched.hp) == Sim.PEST_HP, "that contact does not count as a shot")

	var brand = Sim.new(9)
	brand.seeds = 24
	for spec in [
		[Catalog.WICK, Vector2i(6, 5)],
		[Catalog.BRIAR, Vector2i(6, 4)],
		[Catalog.FLARE, Vector2i(7, 4)],
		[Catalog.PEA, Vector2i(8, 5)],
		[Catalog.HEARTH, Vector2i(5, 5)],
		[Catalog.SHEAR, Vector2i(7, 6)],
		[Catalog.CHIME, Vector2i(8, 6)],
		[Catalog.RASP, Vector2i(9, 5)],
		[Catalog.MAUL, Vector2i(9, 6)],
		[Catalog.BILL, Vector2i(8, 4)],
		[Catalog.SHADE, Vector2i(6, 6)],
		[Catalog.COWL, Vector2i(7, 5)],
		[Catalog.HOOD, Vector2i(5, 6)],
		[Catalog.CLOAK, Vector2i(4, 6)],
		[Catalog.CAPE, Vector2i(3, 6)],
		[Catalog.SHAWL, Vector2i(2, 6)],
		[Catalog.STOLE, STOLE_TILE],
		[Catalog.MANTLE, MANTLE_TILE],
		[Catalog.TIPPET, TIPPET_TILE],
		[Catalog.WIMPLE, WIMPLE_TILE],
	]:
		var sow = Sim.Command.new()
		sow.plant_kind = int(spec[0])
		sow.tile = spec[1]
		brand.step(sow)
	var sealed = brand.spawn_pest(brand.tile_center(7, 4), true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true)
	var sealed_id := int(sealed.id)
	_expect(brand.tile_wimples_mildew(7, 4) and not brand.tile_albs_rust(7, 4) and sealed.hidden, "every older lock leaves a rust moth sealed")
	guard = 0
	var sealed_hit := false
	while guard < 20 and brand.outcome == Sim.OUTCOME_RUNNING:
		brand.step(idle)
		guard += 1
		for event in brand.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				sealed_hit = true
	var sealed_now = brand.pest_by_id(sealed_id)
	_expect(not sealed_hit and sealed_now != null and int(sealed_now.hp) == Sim.PEST_HP, "a brand moth ignores shots until every lock, including the alb, is open")
	var brand_alb = Sim.Command.new()
	brand_alb.plant_kind = Catalog.ALB
	brand_alb.tile = ALB_TILE
	brand.step(brand_alb)
	var opened = brand.pest_by_id(sealed_id)
	_expect(opened != null and not opened.hidden, "alb plus the older locks together reveal a brand moth")
	var outside = brand.spawn_pest(brand.tile_center(13, 9), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(outside.hidden, "a rust moth outside the alb seals again")
	var opened_hit := false
	guard = 0
	while guard < 80 and brand.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		brand.step(idle)
		guard += 1
		for event in brand.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				opened_hit = true
	_expect(opened_hit, "the opened brand moth takes a hit")


func _test_forty_second_nights() -> void:
	print("nights 42 and 43")
	_expect(Sim.START_SEEDS == 23, "the run starts with twenty-three seeds")
	_expect(Sim.WAVE_COUNT == 47 and Sim.WAVES.size() == 47, "forty-seven nights")
	_expect(int(Sim.WAVES[41]["count"]) == 10 and int(Sim.WAVES[41]["interval"]) == 96 and int(Sim.WAVES[41]["shroud_every"]) == 0 and int(Sim.WAVES[41]["rind_every"]) == 0 and int(Sim.WAVES[41]["pitch_every"]) == 0 and int(Sim.WAVES[41]["frost_every"]) == 0 and int(Sim.WAVES[41]["web_every"]) == 0 and int(Sim.WAVES[41]["glass_every"]) == 0 and int(Sim.WAVES[41]["scale_every"]) == 0 and int(Sim.WAVES[41]["mail_every"]) == 0 and int(Sim.WAVES[41]["hide_every"]) == 0 and int(Sim.WAVES[41]["dusk_every"]) == 0 and int(Sim.WAVES[41]["veil_every"]) == 0 and int(Sim.WAVES[41]["pall_every"]) == 0 and int(Sim.WAVES[41]["gloom_every"]) == 0 and int(Sim.WAVES[41]["murk_every"]) == 0 and int(Sim.WAVES[41]["dread_every"]) == 0 and int(Sim.WAVES[41]["woe_every"]) == 0 and int(Sim.WAVES[41]["blight_every"]) == 0 and int(Sim.WAVES[41]["rot_every"]) == 0 and int(Sim.WAVES[41]["mildew_every"]) == 0 and int(Sim.WAVES[41]["rust_every"]) == 1 and str(Sim.WAVES[41]["name"]) == "Rust", "night 42 is all rust and no other lock")
	_expect(int(Sim.WAVES[42]["count"]) == 16 and int(Sim.WAVES[42]["interval"]) == 60 and int(Sim.WAVES[42]["shroud_every"]) == 2 and int(Sim.WAVES[42]["rind_every"]) == 1 and int(Sim.WAVES[42]["pitch_every"]) == 1 and int(Sim.WAVES[42]["frost_every"]) == 1 and int(Sim.WAVES[42]["web_every"]) == 1 and int(Sim.WAVES[42]["glass_every"]) == 1 and int(Sim.WAVES[42]["scale_every"]) == 1 and int(Sim.WAVES[42]["mail_every"]) == 1 and int(Sim.WAVES[42]["hide_every"]) == 1 and int(Sim.WAVES[42]["dusk_every"]) == 1 and int(Sim.WAVES[42]["veil_every"]) == 1 and int(Sim.WAVES[42]["pall_every"]) == 1 and int(Sim.WAVES[42]["gloom_every"]) == 1 and int(Sim.WAVES[42]["murk_every"]) == 1 and int(Sim.WAVES[42]["dread_every"]) == 1 and int(Sim.WAVES[42]["woe_every"]) == 1 and int(Sim.WAVES[42]["blight_every"]) == 1 and int(Sim.WAVES[42]["rot_every"]) == 1 and int(Sim.WAVES[42]["mildew_every"]) == 1 and int(Sim.WAVES[42]["rust_every"]) == 1 and str(Sim.WAVES[42]["name"]) == "Brand", "night 43 is rust, mildew, rot, blight, woe, dread, murk, gloom, pall, veil, dusk, hide, mail, scale, glass, web, frost, pitch, and rind, every second also a shroud")
	_expect(int(Sim.WAVES[41].get("scab_every", 0)) == 0, "night 42 stays Rust and carries no scab")
	_expect(str(Sim.WAVES[42]["name"]) == "Brand" and int(Sim.WAVES[42].get("scab_every", 0)) == 0, "night 43 stays Brand and carries no scab")
	for i in 41:
		_expect(int(Sim.WAVES[i].get("rust_every", 0)) == 0, "night %d still spawns no rust" % (i + 1))
	_expect(str(Sim.WAVES[39]["name"]) == "Mildew" and int(Sim.WAVES[39].get("rust_every", 0)) == 0, "night 40 stays Mildew and carries no rust")
	_expect(str(Sim.WAVES[40]["name"]) == "Ergot" and int(Sim.WAVES[40].get("rust_every", 0)) == 0, "night 41 stays Ergot and carries no rust")
	var named = Sim.new(1)
	named.wave = 42
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 42 of 47 (Rust) — 0 pests left", "night 42 heading: %s" % named.phase_text())
	named.wave = 43
	_expect(named.phase_text() == "Night 43 of 47 (Brand) — 0 pests left", "night 43 heading: %s" % named.phase_text())
	_expect(ALB_TILE == Vector2i(1, 9), "the alb landed at (1, 9) because that radius covers the wimple and every Brand lock tile")

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var held := _play(run_seed, Callable(self, "_alb_command"), 43)
		print("  alb seed=%s outcome=%s night=%s hp=%s rust=%s/%s" % [run_seed, held[0], held[1], held[4], held[47], held[46]])
		_expect(int(held[0]) == Sim.OUTCOME_RUNNING and int(held[2]) == Sim.PHASE_PLANT, "seed %s is still planting after night 43" % run_seed)
		_expect(int(held[1]) == 43, "seed %s cleared through night 43" % run_seed)
		_expect(int(held[4]) == 100, "seed %s finished night 43 at full health (%s)" % [run_seed, held[4]])
		_expect(int(held[6]) == 168 and int(held[7]) == 168, "seed %s burned every shroud moth (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 314 and int(held[11]) == 314, "seed %s cracked every rind moth (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 298 and int(held[13]) == 298, "seed %s melted every pitch moth (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 282 and int(held[15]) == 282, "seed %s thawed every frost moth (%s/%s)" % [run_seed, held[15], held[14]])
		_expect(int(held[16]) == 266 and int(held[17]) == 266, "seed %s cut every web moth (%s/%s)" % [run_seed, held[17], held[16]])
		_expect(int(held[18]) == 250 and int(held[19]) == 250, "seed %s cracked every glass moth (%s/%s)" % [run_seed, held[19], held[18]])
		_expect(int(held[20]) == 234 and int(held[21]) == 234, "seed %s stripped every scale moth (%s/%s)" % [run_seed, held[21], held[20]])
		_expect(int(held[22]) == 218 and int(held[23]) == 218, "seed %s cracked every mail moth (%s/%s)" % [run_seed, held[23], held[22]])
		_expect(int(held[24]) == 202 and int(held[25]) == 202, "seed %s split every hide moth (%s/%s)" % [run_seed, held[25], held[24]])
		_expect(int(held[26]) == 186 and int(held[27]) == 186, "seed %s shaded every dusk moth (%s/%s)" % [run_seed, held[27], held[26]])
		_expect(int(held[28]) == 170 and int(held[29]) == 170, "seed %s cowled every veil moth (%s/%s)" % [run_seed, held[29], held[28]])
		_expect(int(held[30]) == 154 and int(held[31]) == 154, "seed %s hooded every pall moth (%s/%s)" % [run_seed, held[31], held[30]])
		_expect(int(held[32]) == 138 and int(held[33]) == 138, "seed %s cloaked every gloom moth (%s/%s)" % [run_seed, held[33], held[32]])
		_expect(int(held[34]) == 122 and int(held[35]) == 122, "seed %s caped every murk moth (%s/%s)" % [run_seed, held[35], held[34]])
		_expect(int(held[36]) == 106 and int(held[37]) == 106, "seed %s shawled every dread moth (%s/%s)" % [run_seed, held[37], held[36]])
		_expect(int(held[38]) == 90 and int(held[39]) == 90, "seed %s stoled every woe moth (%s/%s)" % [run_seed, held[39], held[38]])
		_expect(int(held[40]) == 74 and int(held[41]) == 74, "seed %s mantled every blight moth (%s/%s)" % [run_seed, held[41], held[40]])
		_expect(int(held[42]) == 58 and int(held[43]) == 58, "seed %s tippetted every rot moth (%s/%s)" % [run_seed, held[43], held[42]])
		_expect(int(held[44]) == 42 and int(held[45]) == 42, "seed %s wimpled every mildew moth (%s/%s)" % [run_seed, held[45], held[44]])
		_expect(int(held[46]) == 26 and int(held[47]) == 26, "seed %s albed every rust moth (%s/%s)" % [run_seed, held[47], held[46]])
		_expect(int(held[48]) == 0 and int(held[49]) == 0, "seed %s meets no scab moth before night 44" % run_seed)
		_expect(int(held[8]) == 2 and int(held[9]) == 21, "seed %s spent twenty-one seeds and left the twenty-second and twenty-third unspent" % run_seed)
		var layout := _alb_garden_layout(run_seed)
		_expect(not bool(layout["lantern"]), "seed %s left the lantern unplanted" % run_seed)
		_expect(layout["shawl"] == Vector2i(2, 6), "seed %s kept the shawl at (2, 6)" % run_seed)
		_expect(layout["stole"] == STOLE_TILE, "seed %s kept the stole at (1, 5)" % run_seed)
		_expect(layout["mantle"] == MANTLE_TILE, "seed %s kept the mantle at (1, 6)" % run_seed)
		_expect(layout["tippet"] == TIPPET_TILE, "seed %s kept the tippet at (1, 7)" % run_seed)
		_expect(layout["wimple"] == WIMPLE_TILE, "seed %s kept the wimple at (1, 8)" % run_seed)
		_expect(layout["alb"] == ALB_TILE, "seed %s planted the alb at (1, 9)" % run_seed)
		var fell := _play(run_seed, Callable(self, "_alb_command"))
		print("  no amice seed=%s outcome=%s night=%s hp=%s scab=%s/%s" % [run_seed, fell[0], fell[1], fell[4], fell[49], fell[48]])
		_expect(int(fell[0]) == Sim.OUTCOME_LOST, "seed %s dies when the alb has no amice" % run_seed)
		_expect(int(fell[1]) == 44, "seed %s dies on the scab night (night %s)" % [run_seed, fell[1]])
		_expect(int(fell[4]) == 0, "seed %s health reached zero on the scab night" % run_seed)
		_expect(int(fell[48]) > 0 and int(fell[49]) == 0, "seed %s left every scab moth unamiced (%s spawned, %s killed)" % [run_seed, fell[48], fell[49]])
		_expect(int(fell[46]) == 26 and int(fell[47]) == 26, "seed %s had already albed rust before scab (%s/%s)" % [run_seed, fell[47], fell[46]])
		_expect(int(fell[8]) == 2 and int(fell[9]) == 21, "seed %s still has the twenty-second and twenty-third seeds unspent when scab arrives" % run_seed)
		var missed := _play(run_seed, Callable(self, "_corner_alb_command"), 43)
		print("  corner alb seed=%s outcome=%s night=%s hp=%s rust=%s/%s" % [run_seed, missed[0], missed[1], missed[4], missed[47], missed[46]])
		# (1, 1) still albs the gardener, so night 42 is not a sealed death. The other plants stay put. Every seed finishes night 43 with every rust moth killed.
		_expect(int(missed[0]) == Sim.OUTCOME_RUNNING and int(missed[2]) == Sim.PHASE_PLANT and int(missed[1]) == 43, "seed %s with a corner alb finishes night 43 (outcome %s night %s)" % [run_seed, missed[0], missed[1]])
		_expect(int(missed[4]) == 100, "seed %s corner alb health is 100 (got %s)" % [run_seed, missed[4]])
		_expect(int(missed[46]) == 26 and int(missed[47]) == 26, "seed %s corner alb still albed every rust moth (%s/%s)" % [run_seed, missed[47], missed[46]])
		var corner_layout := _corner_alb_garden_layout(run_seed)
		_expect(corner_layout["wimple"] == WIMPLE_TILE and corner_layout["alb"] == Vector2i(1, 1), "seed %s kept the wimple at (1, 8) and put the alb at (1, 1)" % run_seed)
		_expect(corner_layout["shawl"] == Vector2i(2, 6) and corner_layout["stole"] == STOLE_TILE and corner_layout["mantle"] == MANTLE_TILE and corner_layout["tippet"] == TIPPET_TILE, "seed %s left the shawl, the stole, the mantle, and the tippet where they were" % run_seed)
	var again := _play(42, Callable(self, "_alb_command"))
	var replay := _play(42, Callable(self, "_alb_command"))
	_expect(str(again) == str(replay), "same seed and alb plan replay")


func _alb_garden_layout(seed_value: int) -> Dictionary:
	return _layout_for(seed_value, Callable(self, "_alb_command"))


func _corner_alb_garden_layout(seed_value: int) -> Dictionary:
	return _layout_for(seed_value, Callable(self, "_corner_alb_command"))


# (1, 10) is the south border, so it is not an open tile, and no plantable tile lies south of the alb. (2, 9) is the nearest open tile that covers the alb and every Blotch lock tile. A 400px radius there pulls rasp inside. No existing tower stays outside that radius. Maul sits inside the radius and outside the shared kill intersection.
const AMICE_TILE := Vector2i(2, 9)


func _amice_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6), Vector2i(4, 6), Vector2i(3, 6), Vector2i(2, 6), STOLE_TILE, MANTLE_TILE, TIPPET_TILE, WIMPLE_TILE, ALB_TILE, AMICE_TILE)


func _corner_amice_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6), Vector2i(4, 6), Vector2i(3, 6), Vector2i(2, 6), STOLE_TILE, MANTLE_TILE, TIPPET_TILE, WIMPLE_TILE, ALB_TILE, Vector2i(1, 1))


func _test_scab_rule() -> void:
	print("amice scab rule")
	var west = Sim.new(4)
	var at_west = Sim.Command.new()
	at_west.plant_kind = Catalog.AMICE
	at_west.tile = AMICE_TILE
	west.step(at_west)
	_expect(west.tile_amices_scab(1, 9) and west.tile_amices_scab(1, 8) and west.tile_amices_scab(1, 7) and west.tile_amices_scab(1, 6) and west.tile_amices_scab(1, 5) and west.tile_amices_scab(2, 6) and west.tile_amices_scab(7, 5), "an amice at (2, 9) covers the alb, the wimple, the tippet, the mantle, the stole, the shawl, and the gardener")
	_expect(west.tile_amices_scab(8, 4) and west.tile_amices_scab(8, 5) and west.tile_amices_scab(8, 6) and west.tile_amices_scab(7, 4) and west.tile_amices_scab(6, 4) and west.tile_amices_scab(7, 6) and west.tile_amices_scab(6, 5) and west.tile_amices_scab(6, 6) and west.tile_amices_scab(5, 4) and west.tile_amices_scab(5, 5) and west.tile_amices_scab(5, 6) and west.tile_amices_scab(7, 3) and west.tile_amices_scab(6, 3), "that amice covers every tile a Blotch moth needs all at once")
	_expect(west.tile_amices_scab(9, 5), "rasp at (9, 5) sits inside the 400px amice")
	_expect(west.tile_amices_scab(9, 6), "maul at (9, 6) sits inside the 400px amice")
	_expect(not west.tile_lit(2, 9) and not west.tile_albs_rust(2, 9) and not west.tile_wimples_mildew(2, 9), "a lone amice does not light its tile, alb rust, or wimple mildew")
	var wick_and_amice = Sim.new(4)
	var sow_wick = Sim.Command.new()
	sow_wick.plant_kind = Catalog.WICK
	sow_wick.tile = Vector2i(6, 5)
	wick_and_amice.step(sow_wick)
	var sow_amice_beside = Sim.Command.new()
	sow_amice_beside.plant_kind = Catalog.AMICE
	sow_amice_beside.tile = AMICE_TILE
	wick_and_amice.step(sow_amice_beside)
	_expect(wick_and_amice.tile_amices_scab(9, 6) and not wick_and_amice.tile_burns_shroud(9, 6), "maul is inside the amice and outside the shared kill intersection")
	var alb_only = Sim.new(4)
	var sow_alb_only = Sim.Command.new()
	sow_alb_only.plant_kind = Catalog.ALB
	sow_alb_only.tile = ALB_TILE
	alb_only.step(sow_alb_only)
	_expect(alb_only.tile_albs_rust(1, 9) and not alb_only.tile_amices_scab(1, 9), "an alb does not amice scab")
	var corner = Sim.new(4)
	var at_corner = Sim.Command.new()
	at_corner.plant_kind = Catalog.AMICE
	at_corner.tile = Vector2i(1, 1)
	corner.step(at_corner)
	_expect(corner.tile_amices_scab(7, 5), "an amice at (1, 1) reaches the gardener")
	_expect(corner.tile_amices_scab(9, 5) and not corner.tile_amices_scab(9, 6), "an amice at (1, 1) pulls rasp inside and leaves maul outside")
	var amice_plant = west.plant_of_kind(Catalog.AMICE)
	_expect(amice_plant != null and amice_plant.amices_scab and not amice_plant.casts_light and not amice_plant.albs_rust and not amice_plant.wimples_mildew and not amice_plant.tippets_rot and not amice_plant.mantles_blight and not amice_plant.stoles_woe and not amice_plant.shawls_dread and not amice_plant.capes_murk and not amice_plant.cloaks_gloom and not amice_plant.hoods_pall and not amice_plant.cowls_veil and not amice_plant.shades_dusk and not amice_plant.splits_hide and not amice_plant.burns_shroud and not amice_plant.cracks_rind and not amice_plant.melts_pitch and not amice_plant.thaws_frost and not amice_plant.cuts_web and not amice_plant.cracks_glass and not amice_plant.strips_scale and not amice_plant.cracks_mail and not amice_plant.orphreys_spot, "the amice amices scab and does not light, alb, wimple, tippet, mantle, stole, shawl, cape, cloak, hood, cowl, shade, split, burn, crack rind, melt, thaw, cut web, crack glass, strip scale, crack mail, or orphrey spot")

	var idle = Sim.Command.new()
	var lamp = Sim.new(5)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	lamp.step(sow_lamp)
	var lamp_scab = lamp.spawn_pest(lamp.tile_center(7, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(lamp.tile_lit(7, 5) and lamp_scab.hidden, "ordinary light does not reveal a scab moth")

	var only = Sim.new(6)
	var sow_amice = Sim.Command.new()
	sow_amice.plant_kind = Catalog.AMICE
	sow_amice.tile = AMICE_TILE
	only.step(sow_amice)
	var sealed_rust = only.spawn_pest(only.tile_center(2, 9), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var opened_scab = only.spawn_pest(only.tile_center(2, 9), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var both = only.spawn_pest(only.tile_center(2, 9), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true)
	_expect(only.tile_amices_scab(2, 9) and not only.tile_lit(2, 9) and not only.tile_albs_rust(2, 9), "amice marks the tile without lighting it or albing rust")
	_expect(sealed_rust.hidden, "an amice does not reveal a rust moth")
	_expect(not opened_scab.hidden, "an amice reveals a scab moth on its tile")
	_expect(both.hidden, "scab plus rust stays closed until the alb is open too")
	var scab_hit := false
	var rust_hurt := false
	var guard := 0
	while guard < 220 and only.outcome == Sim.OUTCOME_RUNNING and not scab_hit:
		only.step(idle)
		guard += 1
		for event in only.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == int(opened_scab.id):
				scab_hit = true
			if int(event["pest_id"]) == int(sealed_rust.id):
				rust_hurt = true
	var rust_left = only.pest_by_id(int(sealed_rust.id))
	_expect(scab_hit, "the revealed scab moth takes a hit")
	_expect(not rust_hurt and rust_left != null and int(rust_left.hp) == Sim.PEST_HP, "shots do not hurt a rust moth standing in an amice")

	var blocked = Sim.new(7)
	var sow_alb = Sim.Command.new()
	sow_alb.plant_kind = Catalog.ALB
	sow_alb.tile = ALB_TILE
	blocked.step(sow_alb)
	var hidden_scab = blocked.spawn_pest(blocked.tile_center(1, 9), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(blocked.tile_albs_rust(1, 9) and hidden_scab.hidden, "an alb opens rust and leaves scab sealed")
	var scab_id := int(hidden_scab.id)
	var alb_scab_hit := false
	guard = 0
	while guard < 40 and blocked.outcome == Sim.OUTCOME_RUNNING:
		blocked.step(idle)
		guard += 1
		for event in blocked.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == scab_id:
				alb_scab_hit = true
	var scab_now = blocked.pest_by_id(scab_id)
	_expect(not alb_scab_hit and scab_now != null and int(scab_now.hp) == Sim.PEST_HP, "an alb does not damage a scab moth")

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_splash_lamp = Sim.Command.new()
	sow_splash_lamp.plant_kind = Catalog.LANTERN
	sow_splash_lamp.tile = Vector2i(7, 5)
	splash.step(sow_splash_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5))
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the scab moth")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a scab moth outside an amice")

	var touch = Sim.new(11)
	var sealed_touch = touch.spawn_pest(touch.player_pos, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(sealed_touch.hidden, "a scab moth on the gardener stays closed with no amice")
	touch.step(idle)
	var touched = touch.pest_by_id(int(sealed_touch.id))
	_expect(touch.player_hp == Sim.PLAYER_HP - Sim.CONTACT_DAMAGE, "contact damage still lands on a closed scab moth")
	_expect(touched != null and int(touched.hp) == Sim.PEST_HP, "that contact does not count as a shot")

	var blotch = Sim.new(9)
	blotch.seeds = 26
	for spec in [
		[Catalog.WICK, Vector2i(6, 5)],
		[Catalog.BRIAR, Vector2i(6, 4)],
		[Catalog.FLARE, Vector2i(7, 4)],
		[Catalog.PEA, Vector2i(8, 5)],
		[Catalog.HEARTH, Vector2i(5, 5)],
		[Catalog.SHEAR, Vector2i(7, 6)],
		[Catalog.CHIME, Vector2i(8, 6)],
		[Catalog.RASP, Vector2i(9, 5)],
		[Catalog.MAUL, Vector2i(9, 6)],
		[Catalog.BILL, Vector2i(8, 4)],
		[Catalog.SHADE, Vector2i(6, 6)],
		[Catalog.COWL, Vector2i(7, 5)],
		[Catalog.HOOD, Vector2i(5, 6)],
		[Catalog.CLOAK, Vector2i(4, 6)],
		[Catalog.CAPE, Vector2i(3, 6)],
		[Catalog.SHAWL, Vector2i(2, 6)],
		[Catalog.STOLE, STOLE_TILE],
		[Catalog.MANTLE, MANTLE_TILE],
		[Catalog.TIPPET, TIPPET_TILE],
		[Catalog.WIMPLE, WIMPLE_TILE],
		[Catalog.ALB, ALB_TILE],
	]:
		var sow = Sim.Command.new()
		sow.plant_kind = int(spec[0])
		sow.tile = spec[1]
		blotch.step(sow)
	var sealed = blotch.spawn_pest(blotch.tile_center(7, 4), true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true)
	var sealed_id := int(sealed.id)
	_expect(blotch.tile_albs_rust(7, 4) and not blotch.tile_amices_scab(7, 4) and sealed.hidden, "every older lock leaves a scab moth sealed")
	guard = 0
	var sealed_hit := false
	while guard < 20 and blotch.outcome == Sim.OUTCOME_RUNNING:
		blotch.step(idle)
		guard += 1
		for event in blotch.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				sealed_hit = true
	var sealed_now = blotch.pest_by_id(sealed_id)
	_expect(not sealed_hit and sealed_now != null and int(sealed_now.hp) == Sim.PEST_HP, "a blotch moth ignores shots until every lock, including the amice, is open")
	var blotch_amice = Sim.Command.new()
	blotch_amice.plant_kind = Catalog.AMICE
	blotch_amice.tile = AMICE_TILE
	blotch.step(blotch_amice)
	var opened = blotch.pest_by_id(sealed_id)
	_expect(opened != null and not opened.hidden, "amice plus the older locks together reveal a blotch moth")
	var outside = blotch.spawn_pest(blotch.tile_center(13, 9), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(outside.hidden, "a scab moth outside the amice seals again")
	var opened_hit := false
	guard = 0
	while guard < 80 and blotch.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		blotch.step(idle)
		guard += 1
		for event in blotch.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				opened_hit = true
	_expect(opened_hit, "the opened blotch moth takes a hit")


func _test_forty_fourth_nights() -> void:
	print("nights 44 and 45")
	_expect(Sim.START_SEEDS == 23, "the run starts with twenty-three seeds")
	_expect(Sim.WAVE_COUNT == 47 and Sim.WAVES.size() == 47, "forty-seven nights")
	_expect(int(Sim.WAVES[43]["count"]) == 10 and int(Sim.WAVES[43]["interval"]) == 102 and int(Sim.WAVES[43]["shroud_every"]) == 0 and int(Sim.WAVES[43]["rind_every"]) == 0 and int(Sim.WAVES[43]["pitch_every"]) == 0 and int(Sim.WAVES[43]["frost_every"]) == 0 and int(Sim.WAVES[43]["web_every"]) == 0 and int(Sim.WAVES[43]["glass_every"]) == 0 and int(Sim.WAVES[43]["scale_every"]) == 0 and int(Sim.WAVES[43]["mail_every"]) == 0 and int(Sim.WAVES[43]["hide_every"]) == 0 and int(Sim.WAVES[43]["dusk_every"]) == 0 and int(Sim.WAVES[43]["veil_every"]) == 0 and int(Sim.WAVES[43]["pall_every"]) == 0 and int(Sim.WAVES[43]["gloom_every"]) == 0 and int(Sim.WAVES[43]["murk_every"]) == 0 and int(Sim.WAVES[43]["dread_every"]) == 0 and int(Sim.WAVES[43]["woe_every"]) == 0 and int(Sim.WAVES[43]["blight_every"]) == 0 and int(Sim.WAVES[43]["rot_every"]) == 0 and int(Sim.WAVES[43]["mildew_every"]) == 0 and int(Sim.WAVES[43]["rust_every"]) == 0 and int(Sim.WAVES[43]["scab_every"]) == 1 and str(Sim.WAVES[43]["name"]) == "Scab", "night 44 is all scab and no other lock")
	_expect(int(Sim.WAVES[44]["count"]) == 16 and int(Sim.WAVES[44]["interval"]) == 60 and int(Sim.WAVES[44]["shroud_every"]) == 2 and int(Sim.WAVES[44]["rind_every"]) == 1 and int(Sim.WAVES[44]["pitch_every"]) == 1 and int(Sim.WAVES[44]["frost_every"]) == 1 and int(Sim.WAVES[44]["web_every"]) == 1 and int(Sim.WAVES[44]["glass_every"]) == 1 and int(Sim.WAVES[44]["scale_every"]) == 1 and int(Sim.WAVES[44]["mail_every"]) == 1 and int(Sim.WAVES[44]["hide_every"]) == 1 and int(Sim.WAVES[44]["dusk_every"]) == 1 and int(Sim.WAVES[44]["veil_every"]) == 1 and int(Sim.WAVES[44]["pall_every"]) == 1 and int(Sim.WAVES[44]["gloom_every"]) == 1 and int(Sim.WAVES[44]["murk_every"]) == 1 and int(Sim.WAVES[44]["dread_every"]) == 1 and int(Sim.WAVES[44]["woe_every"]) == 1 and int(Sim.WAVES[44]["blight_every"]) == 1 and int(Sim.WAVES[44]["rot_every"]) == 1 and int(Sim.WAVES[44]["mildew_every"]) == 1 and int(Sim.WAVES[44]["rust_every"]) == 1 and int(Sim.WAVES[44]["scab_every"]) == 1 and str(Sim.WAVES[44]["name"]) == "Blotch", "night 45 is scab, rust, mildew, rot, blight, woe, dread, murk, gloom, pall, veil, dusk, hide, mail, scale, glass, web, frost, pitch, and rind, every second also a shroud")
	for i in 43:
		_expect(int(Sim.WAVES[i].get("scab_every", 0)) == 0, "night %d still spawns no scab" % (i + 1))
	_expect(str(Sim.WAVES[41]["name"]) == "Rust" and int(Sim.WAVES[41].get("scab_every", 0)) == 0, "night 42 stays Rust and carries no scab")
	_expect(str(Sim.WAVES[42]["name"]) == "Brand" and int(Sim.WAVES[42].get("scab_every", 0)) == 0, "night 43 stays Brand and carries no scab")
	for i in 45:
		_expect(int(Sim.WAVES[i].get("spot_every", 0)) == 0, "night %d spawns no spot" % (i + 1))
	_expect(int(Sim.WAVES[44].get("spot_every", 0)) == 0 and str(Sim.WAVES[44]["name"]) == "Blotch", "night 45 stays Blotch and still has no spot")
	var named = Sim.new(1)
	named.wave = 44
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 44 of 47 (Scab) — 0 pests left", "night 44 heading: %s" % named.phase_text())
	named.wave = 45
	_expect(named.phase_text() == "Night 45 of 47 (Blotch) — 0 pests left", "night 45 heading: %s" % named.phase_text())
	_expect(AMICE_TILE == Vector2i(2, 9), "the amice landed at (2, 9) because (1, 10) is not open and that radius covers the alb and every Blotch lock tile")

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var held := _play(run_seed, Callable(self, "_amice_command"), 45)
		print("  amice seed=%s outcome=%s night=%s hp=%s scab=%s/%s" % [run_seed, held[0], held[1], held[4], held[49], held[48]])
		_expect(int(held[0]) == Sim.OUTCOME_RUNNING and int(held[2]) == Sim.PHASE_PLANT, "seed %s is still planting after night 45" % run_seed)
		_expect(int(held[1]) == 45, "seed %s cleared through night 45" % run_seed)
		_expect(int(held[4]) == 100, "seed %s finished night 45 at full health (%s)" % [run_seed, held[4]])
		_expect(int(held[6]) == 176 and int(held[7]) == 176, "seed %s burned every shroud moth (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 330 and int(held[11]) == 330, "seed %s cracked every rind moth (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 314 and int(held[13]) == 314, "seed %s melted every pitch moth (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 298 and int(held[15]) == 298, "seed %s thawed every frost moth (%s/%s)" % [run_seed, held[15], held[14]])
		_expect(int(held[16]) == 282 and int(held[17]) == 282, "seed %s cut every web moth (%s/%s)" % [run_seed, held[17], held[16]])
		_expect(int(held[18]) == 266 and int(held[19]) == 266, "seed %s cracked every glass moth (%s/%s)" % [run_seed, held[19], held[18]])
		_expect(int(held[20]) == 250 and int(held[21]) == 250, "seed %s stripped every scale moth (%s/%s)" % [run_seed, held[21], held[20]])
		_expect(int(held[22]) == 234 and int(held[23]) == 234, "seed %s cracked every mail moth (%s/%s)" % [run_seed, held[23], held[22]])
		_expect(int(held[24]) == 218 and int(held[25]) == 218, "seed %s split every hide moth (%s/%s)" % [run_seed, held[25], held[24]])
		_expect(int(held[26]) == 202 and int(held[27]) == 202, "seed %s shaded every dusk moth (%s/%s)" % [run_seed, held[27], held[26]])
		_expect(int(held[28]) == 186 and int(held[29]) == 186, "seed %s cowled every veil moth (%s/%s)" % [run_seed, held[29], held[28]])
		_expect(int(held[30]) == 170 and int(held[31]) == 170, "seed %s hooded every pall moth (%s/%s)" % [run_seed, held[31], held[30]])
		_expect(int(held[32]) == 154 and int(held[33]) == 154, "seed %s cloaked every gloom moth (%s/%s)" % [run_seed, held[33], held[32]])
		_expect(int(held[34]) == 138 and int(held[35]) == 138, "seed %s caped every murk moth (%s/%s)" % [run_seed, held[35], held[34]])
		_expect(int(held[36]) == 122 and int(held[37]) == 122, "seed %s shawled every dread moth (%s/%s)" % [run_seed, held[37], held[36]])
		_expect(int(held[38]) == 106 and int(held[39]) == 106, "seed %s stoled every woe moth (%s/%s)" % [run_seed, held[39], held[38]])
		_expect(int(held[40]) == 90 and int(held[41]) == 90, "seed %s mantled every blight moth (%s/%s)" % [run_seed, held[41], held[40]])
		_expect(int(held[42]) == 74 and int(held[43]) == 74, "seed %s tippetted every rot moth (%s/%s)" % [run_seed, held[43], held[42]])
		_expect(int(held[44]) == 58 and int(held[45]) == 58, "seed %s wimpled every mildew moth (%s/%s)" % [run_seed, held[45], held[44]])
		_expect(int(held[46]) == 42 and int(held[47]) == 42, "seed %s albed every rust moth (%s/%s)" % [run_seed, held[47], held[46]])
		_expect(int(held[48]) == 26 and int(held[49]) == 26, "seed %s amiced every scab moth (%s/%s)" % [run_seed, held[49], held[48]])
		_expect(int(held[50]) == 0 and int(held[51]) == 0, "seed %s meets no spot moth before night 46" % run_seed)
		_expect(int(held[8]) == 1 and int(held[9]) == 22, "seed %s spent twenty-two seeds and left the twenty-third unspent" % run_seed)
		var layout := _amice_garden_layout(run_seed)
		_expect(not bool(layout["lantern"]), "seed %s left the lantern unplanted" % run_seed)
		_expect(layout["shawl"] == Vector2i(2, 6), "seed %s kept the shawl at (2, 6)" % run_seed)
		_expect(layout["stole"] == STOLE_TILE, "seed %s kept the stole at (1, 5)" % run_seed)
		_expect(layout["mantle"] == MANTLE_TILE, "seed %s kept the mantle at (1, 6)" % run_seed)
		_expect(layout["tippet"] == TIPPET_TILE, "seed %s kept the tippet at (1, 7)" % run_seed)
		_expect(layout["wimple"] == WIMPLE_TILE, "seed %s kept the wimple at (1, 8)" % run_seed)
		_expect(layout["alb"] == ALB_TILE, "seed %s kept the alb at (1, 9)" % run_seed)
		_expect(layout["amice"] == AMICE_TILE, "seed %s planted the amice at (2, 9)" % run_seed)
		_expect(layout["orphrey"] == Vector2i(-1, -1), "seed %s left the orphrey unplanted" % run_seed)
		var fell := _play(run_seed, Callable(self, "_amice_command"))
		print("  no orphrey seed=%s outcome=%s night=%s hp=%s spot=%s/%s" % [run_seed, fell[0], fell[1], fell[4], fell[51], fell[50]])
		_expect(int(fell[0]) == Sim.OUTCOME_LOST, "seed %s dies when the amice has no orphrey" % run_seed)
		_expect(int(fell[1]) == 46, "seed %s dies on the spot night (night %s)" % [run_seed, fell[1]])
		_expect(int(fell[4]) == 0, "seed %s health reached zero on the spot night" % run_seed)
		_expect(int(fell[50]) > 0 and int(fell[51]) == 0, "seed %s left every spot moth unorphreyed (%s spawned, %s killed)" % [run_seed, fell[50], fell[51]])
		_expect(int(fell[48]) == 26 and int(fell[49]) == 26, "seed %s had already amiced scab before spot (%s/%s)" % [run_seed, fell[49], fell[48]])
		_expect(int(fell[8]) == 1 and int(fell[9]) == 22, "seed %s still has the twenty-third seed unspent when spot arrives" % run_seed)
		var missed := _play(run_seed, Callable(self, "_corner_amice_command"), 45)
		print("  corner amice seed=%s outcome=%s night=%s hp=%s scab=%s/%s" % [run_seed, missed[0], missed[1], missed[4], missed[49], missed[48]])
		# (1, 1) still amices the gardener, so night 44 is not a sealed death. The other plants stay put. The run stops before spot, which this amice cannot open. Every seed finishes night 45 with every scab moth killed.
		_expect(int(missed[0]) == Sim.OUTCOME_RUNNING and int(missed[2]) == Sim.PHASE_PLANT and int(missed[1]) == 45, "seed %s with a corner amice finishes night 45 (outcome %s night %s)" % [run_seed, missed[0], missed[1]])
		_expect(int(missed[4]) == 100, "seed %s corner amice finished night 45 at full health (%s)" % [run_seed, missed[4]])
		_expect(int(missed[48]) == 26 and int(missed[49]) == 26, "seed %s corner amice still amiced every scab moth (%s/%s)" % [run_seed, missed[49], missed[48]])
		_expect(int(missed[50]) == 0 and int(missed[51]) == 0, "seed %s corner amice meets no spot moth before night 46" % run_seed)
		var corner_layout := _corner_amice_garden_layout(run_seed)
		_expect(corner_layout["alb"] == ALB_TILE and corner_layout["amice"] == Vector2i(1, 1), "seed %s kept the alb at (1, 9) and put the amice at (1, 1)" % run_seed)
		_expect(corner_layout["shawl"] == Vector2i(2, 6) and corner_layout["stole"] == STOLE_TILE and corner_layout["mantle"] == MANTLE_TILE and corner_layout["tippet"] == TIPPET_TILE and corner_layout["wimple"] == WIMPLE_TILE, "seed %s left the shawl, the stole, the mantle, the tippet, and the wimple where they were" % run_seed)
	var again := _play(42, Callable(self, "_amice_command"))
	var replay := _play(42, Callable(self, "_amice_command"))
	_expect(str(again) == str(replay), "same seed and amice plan replay")


func _amice_garden_layout(seed_value: int) -> Dictionary:
	return _layout_for(seed_value, Callable(self, "_amice_command"))


func _corner_amice_garden_layout(seed_value: int) -> Dictionary:
	return _layout_for(seed_value, Callable(self, "_corner_amice_command"))



# (3, 9) is open, one tile east of the amice. A 416px radius there covers the amice and every tile a Scorch moth needs all at once. Every existing tower sits inside that radius, including rasp at (9, 5). Maul at (9, 6) sits inside the radius and outside the shared kill intersection.
const ORPHREY_TILE := Vector2i(3, 9)


func _orphrey_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6), Vector2i(4, 6), Vector2i(3, 6), Vector2i(2, 6), STOLE_TILE, MANTLE_TILE, TIPPET_TILE, WIMPLE_TILE, ALB_TILE, AMICE_TILE, ORPHREY_TILE)


func _corner_orphrey_command(sim):
	return _garden_command(sim, Vector2i(6, 5), Vector2i(6, 4), Vector2i(7, 4), Vector2i(5, 5), Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 5), Vector2i(9, 6), Vector2i(8, 4), Vector2i(6, 6), false, Vector2i(7, 5), Vector2i(5, 6), Vector2i(4, 6), Vector2i(3, 6), Vector2i(2, 6), STOLE_TILE, MANTLE_TILE, TIPPET_TILE, WIMPLE_TILE, ALB_TILE, AMICE_TILE, Vector2i(1, 1))


func _test_spot_rule() -> void:
	print("orphrey spot rule")
	var west = Sim.new(4)
	var at_west = Sim.Command.new()
	at_west.plant_kind = Catalog.ORPHREY
	at_west.tile = ORPHREY_TILE
	west.step(at_west)
	_expect(west.tile_orphreys_spot(2, 9) and west.tile_orphreys_spot(1, 9) and west.tile_orphreys_spot(1, 8) and west.tile_orphreys_spot(1, 7) and west.tile_orphreys_spot(1, 6) and west.tile_orphreys_spot(1, 5) and west.tile_orphreys_spot(2, 6) and west.tile_orphreys_spot(7, 5), "an orphrey at (3, 9) covers the amice, the alb, the wimple, the tippet, the mantle, the stole, the shawl, and the gardener")
	_expect(west.tile_orphreys_spot(8, 4) and west.tile_orphreys_spot(8, 5) and west.tile_orphreys_spot(8, 6) and west.tile_orphreys_spot(7, 4) and west.tile_orphreys_spot(6, 4) and west.tile_orphreys_spot(7, 6) and west.tile_orphreys_spot(6, 5) and west.tile_orphreys_spot(6, 6) and west.tile_orphreys_spot(5, 4) and west.tile_orphreys_spot(5, 5) and west.tile_orphreys_spot(5, 6) and west.tile_orphreys_spot(7, 3) and west.tile_orphreys_spot(6, 3) and west.tile_orphreys_spot(7, 5), "that orphrey covers every tile a Scorch moth needs all at once")
	_expect(west.tile_orphreys_spot(9, 5) and west.tile_orphreys_spot(8, 5) and west.tile_orphreys_spot(9, 6) and west.tile_orphreys_spot(8, 4) and west.tile_orphreys_spot(6, 5) and west.tile_orphreys_spot(6, 4) and west.tile_orphreys_spot(7, 4) and west.tile_orphreys_spot(5, 5) and west.tile_orphreys_spot(7, 6) and west.tile_orphreys_spot(8, 6) and west.tile_orphreys_spot(6, 6) and west.tile_orphreys_spot(5, 6), "every existing tower sits inside the 416px orphrey")
	_expect(not west.tile_lit(3, 9) and not west.tile_amices_scab(3, 9) and not west.tile_albs_rust(3, 9), "a lone orphrey does not light its tile, amice scab, or alb rust")
	var wick_and_orphrey = Sim.new(4)
	var sow_wick = Sim.Command.new()
	sow_wick.plant_kind = Catalog.WICK
	sow_wick.tile = Vector2i(6, 5)
	wick_and_orphrey.step(sow_wick)
	var sow_beside = Sim.Command.new()
	sow_beside.plant_kind = Catalog.ORPHREY
	sow_beside.tile = ORPHREY_TILE
	wick_and_orphrey.step(sow_beside)
	_expect(wick_and_orphrey.tile_orphreys_spot(9, 6) and not wick_and_orphrey.tile_burns_shroud(9, 6), "maul at (9, 6) is inside the orphrey and outside the shared kill intersection")
	var amice_only = Sim.new(4)
	var sow_amice_only = Sim.Command.new()
	sow_amice_only.plant_kind = Catalog.AMICE
	sow_amice_only.tile = AMICE_TILE
	amice_only.step(sow_amice_only)
	_expect(amice_only.tile_amices_scab(2, 9) and not amice_only.tile_orphreys_spot(2, 9), "an amice does not orphrey spot")
	var corner = Sim.new(4)
	var at_corner = Sim.Command.new()
	at_corner.plant_kind = Catalog.ORPHREY
	at_corner.tile = Vector2i(1, 1)
	corner.step(at_corner)
	_expect(corner.tile_orphreys_spot(7, 5), "an orphrey at (1, 1) reaches the gardener")
	_expect(corner.tile_orphreys_spot(9, 5) and not corner.tile_orphreys_spot(9, 6), "an orphrey at (1, 1) pulls rasp inside and leaves maul outside")
	var orphrey_plant = west.plant_of_kind(Catalog.ORPHREY)
	_expect(orphrey_plant != null and orphrey_plant.orphreys_spot and not orphrey_plant.casts_light and not orphrey_plant.amices_scab and not orphrey_plant.albs_rust and int(orphrey_plant.damage) == 2 and int(orphrey_plant.fire_ticks) == 108 and is_equal_approx(float(orphrey_plant.light_radius), 416.0) and is_equal_approx(float(orphrey_plant.weapon_range), 12.0) and is_equal_approx(float(orphrey_plant.projectile_speed), 80.0) and is_equal_approx(float(orphrey_plant.splash_radius), 0.0) and int(orphrey_plant.slow_ticks) == 0, "the orphrey orphreys spot, deals 2, fires every 108 ticks, and has a 416px radius, a 12px range, and an 80px shot")

	var idle = Sim.Command.new()
	var lamp = Sim.new(5)
	var sow_lamp = Sim.Command.new()
	sow_lamp.plant_kind = Catalog.LANTERN
	sow_lamp.tile = Vector2i(7, 5)
	lamp.step(sow_lamp)
	var lamp_spot = lamp.spawn_pest(lamp.tile_center(7, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(lamp.tile_lit(7, 5) and lamp_spot.hidden, "ordinary light does not reveal a spot moth")

	var only = Sim.new(6)
	var sow_orphrey = Sim.Command.new()
	sow_orphrey.plant_kind = Catalog.ORPHREY
	sow_orphrey.tile = ORPHREY_TILE
	only.step(sow_orphrey)
	var sealed_scab = only.spawn_pest(only.tile_center(3, 9), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var opened_spot = only.spawn_pest(only.tile_center(3, 9), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var both = only.spawn_pest(only.tile_center(3, 9), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true, true)
	_expect(only.tile_orphreys_spot(3, 9) and not only.tile_lit(3, 9) and not only.tile_amices_scab(3, 9), "orphrey marks the tile without lighting it or amicing scab")
	_expect(sealed_scab.hidden, "an orphrey does not reveal a scab moth")
	_expect(not opened_spot.hidden, "an orphrey reveals a spot moth on its tile")
	_expect(both.hidden, "spot plus scab stays closed until the amice is open too")
	var spot_hit := false
	var scab_hurt := false
	var guard := 0
	while guard < 260 and only.outcome == Sim.OUTCOME_RUNNING and not spot_hit:
		only.step(idle)
		guard += 1
		for event in only.events:
			if str(event.get("type", "")) != "hit":
				continue
			if int(event["pest_id"]) == int(opened_spot.id):
				spot_hit = true
			if int(event["pest_id"]) == int(sealed_scab.id):
				scab_hurt = true
	var scab_left = only.pest_by_id(int(sealed_scab.id))
	_expect(spot_hit, "the revealed spot moth takes a hit")
	_expect(not scab_hurt and scab_left != null and int(scab_left.hp) == Sim.PEST_HP, "shots do not hurt a scab moth standing in an orphrey")

	var blocked = Sim.new(7)
	var sow_amice = Sim.Command.new()
	sow_amice.plant_kind = Catalog.AMICE
	sow_amice.tile = AMICE_TILE
	blocked.step(sow_amice)
	var hidden_spot = blocked.spawn_pest(blocked.tile_center(2, 9), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(blocked.tile_amices_scab(2, 9) and hidden_spot.hidden, "an amice opens scab and leaves spot sealed")
	var spot_id := int(hidden_spot.id)
	var amice_spot_hit := false
	guard = 0
	while guard < 40 and blocked.outcome == Sim.OUTCOME_RUNNING:
		blocked.step(idle)
		guard += 1
		for event in blocked.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == spot_id:
				amice_spot_hit = true
	var spot_now = blocked.pest_by_id(spot_id)
	_expect(not amice_spot_hit and spot_now != null and int(spot_now.hp) == Sim.PEST_HP, "an amice does not damage a spot moth")

	var splash = Sim.new(8)
	var sow_gourd = Sim.Command.new()
	sow_gourd.plant_kind = Catalog.GOURD
	sow_gourd.tile = Vector2i(5, 5)
	splash.step(sow_gourd)
	var sow_splash_lamp = Sim.Command.new()
	sow_splash_lamp.plant_kind = Catalog.LANTERN
	sow_splash_lamp.tile = Vector2i(7, 5)
	splash.step(sow_splash_lamp)
	var victim = splash.spawn_pest(splash.tile_center(10, 5))
	var ghost = splash.spawn_pest(splash.tile_center(10, 5), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	var ghost_id := int(ghost.id)
	var saw_splash_target := false
	guard = 0
	while guard < 80 and splash.outcome == Sim.OUTCOME_RUNNING and not saw_splash_target:
		splash.step(idle)
		guard += 1
		for event in splash.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == int(victim.id):
				saw_splash_target = true
	var ghost_now = splash.pest_by_id(ghost_id)
	_expect(saw_splash_target, "gourd hit the visible moth beside the spot moth")
	_expect(ghost_now != null and ghost_now.alive and int(ghost_now.hp) == Sim.PEST_HP, "gourd splash does not hurt a spot moth outside an orphrey")

	var touch = Sim.new(11)
	var sealed_touch = touch.spawn_pest(touch.player_pos, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(sealed_touch.hidden, "a spot moth on the gardener stays closed with no orphrey")
	touch.step(idle)
	var touched = touch.pest_by_id(int(sealed_touch.id))
	_expect(touch.player_hp == Sim.PLAYER_HP - Sim.CONTACT_DAMAGE, "contact damage still lands on a closed spot moth")
	_expect(touched != null and int(touched.hp) == Sim.PEST_HP, "that contact does not count as a shot")

	var scorch = Sim.new(9)
	scorch.seeds = 30
	for spec in [
		[Catalog.WICK, Vector2i(6, 5)],
		[Catalog.BRIAR, Vector2i(6, 4)],
		[Catalog.FLARE, Vector2i(7, 4)],
		[Catalog.PEA, Vector2i(8, 5)],
		[Catalog.HEARTH, Vector2i(5, 5)],
		[Catalog.SHEAR, Vector2i(7, 6)],
		[Catalog.CHIME, Vector2i(8, 6)],
		[Catalog.RASP, Vector2i(9, 5)],
		[Catalog.MAUL, Vector2i(9, 6)],
		[Catalog.BILL, Vector2i(8, 4)],
		[Catalog.SHADE, Vector2i(6, 6)],
		[Catalog.COWL, Vector2i(7, 5)],
		[Catalog.HOOD, Vector2i(5, 6)],
		[Catalog.CLOAK, Vector2i(4, 6)],
		[Catalog.CAPE, Vector2i(3, 6)],
		[Catalog.SHAWL, Vector2i(2, 6)],
		[Catalog.STOLE, STOLE_TILE],
		[Catalog.MANTLE, MANTLE_TILE],
		[Catalog.TIPPET, TIPPET_TILE],
		[Catalog.WIMPLE, WIMPLE_TILE],
		[Catalog.ALB, ALB_TILE],
		[Catalog.AMICE, AMICE_TILE],
	]:
		var sow = Sim.Command.new()
		sow.plant_kind = int(spec[0])
		sow.tile = spec[1]
		scorch.step(sow)
	var sealed = scorch.spawn_pest(scorch.tile_center(7, 4), true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true)
	var sealed_id := int(sealed.id)
	_expect(scorch.tile_amices_scab(7, 4) and not scorch.tile_orphreys_spot(7, 4) and sealed.hidden, "every older lock leaves a spot moth sealed")
	guard = 0
	var sealed_hit := false
	while guard < 20 and scorch.outcome == Sim.OUTCOME_RUNNING:
		scorch.step(idle)
		guard += 1
		for event in scorch.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				sealed_hit = true
	var sealed_now = scorch.pest_by_id(sealed_id)
	_expect(not sealed_hit and sealed_now != null and int(sealed_now.hp) == Sim.PEST_HP, "a scorch moth ignores shots until every lock, including the orphrey, is open")
	var scorch_orphrey = Sim.Command.new()
	scorch_orphrey.plant_kind = Catalog.ORPHREY
	scorch_orphrey.tile = ORPHREY_TILE
	scorch.step(scorch_orphrey)
	var opened = scorch.pest_by_id(sealed_id)
	_expect(opened != null and not opened.hidden, "orphrey plus the older locks together reveal a scorch moth")
	var outside = scorch.spawn_pest(scorch.tile_center(13, 9), false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, true)
	_expect(outside.hidden, "a spot moth outside the orphrey seals again")
	var opened_hit := false
	guard = 0
	while guard < 80 and scorch.outcome == Sim.OUTCOME_RUNNING and not opened_hit:
		scorch.step(idle)
		guard += 1
		for event in scorch.events:
			if str(event.get("type", "")) == "hit" and int(event["pest_id"]) == sealed_id:
				opened_hit = true
	_expect(opened_hit, "the opened scorch moth takes a hit")


func _test_forty_sixth_nights() -> void:
	print("nights 46 and 47")
	_expect(Sim.START_SEEDS == 23, "the run starts with twenty-three seeds")
	_expect(Sim.WAVE_COUNT == 47 and Sim.WAVES.size() == 47, "forty-seven nights")
	_expect(int(Sim.WAVES[45]["count"]) == 10 and int(Sim.WAVES[45]["interval"]) == 108 and int(Sim.WAVES[45]["shroud_every"]) == 0 and int(Sim.WAVES[45]["rind_every"]) == 0 and int(Sim.WAVES[45]["pitch_every"]) == 0 and int(Sim.WAVES[45]["frost_every"]) == 0 and int(Sim.WAVES[45]["web_every"]) == 0 and int(Sim.WAVES[45]["glass_every"]) == 0 and int(Sim.WAVES[45]["scale_every"]) == 0 and int(Sim.WAVES[45]["mail_every"]) == 0 and int(Sim.WAVES[45]["hide_every"]) == 0 and int(Sim.WAVES[45]["dusk_every"]) == 0 and int(Sim.WAVES[45]["veil_every"]) == 0 and int(Sim.WAVES[45]["pall_every"]) == 0 and int(Sim.WAVES[45]["gloom_every"]) == 0 and int(Sim.WAVES[45]["murk_every"]) == 0 and int(Sim.WAVES[45]["dread_every"]) == 0 and int(Sim.WAVES[45]["woe_every"]) == 0 and int(Sim.WAVES[45]["blight_every"]) == 0 and int(Sim.WAVES[45]["rot_every"]) == 0 and int(Sim.WAVES[45]["mildew_every"]) == 0 and int(Sim.WAVES[45]["rust_every"]) == 0 and int(Sim.WAVES[45]["scab_every"]) == 0 and int(Sim.WAVES[45]["spot_every"]) == 1 and str(Sim.WAVES[45]["name"]) == "Spot", "night 46 is all spot and no other lock")
	_expect(int(Sim.WAVES[46]["count"]) == 16 and int(Sim.WAVES[46]["count"]) == int(Sim.WAVES[44]["count"]) and int(Sim.WAVES[46]["interval"]) == 60 and int(Sim.WAVES[46]["shroud_every"]) == 2 and int(Sim.WAVES[46]["rind_every"]) == 1 and int(Sim.WAVES[46]["pitch_every"]) == 1 and int(Sim.WAVES[46]["frost_every"]) == 1 and int(Sim.WAVES[46]["web_every"]) == 1 and int(Sim.WAVES[46]["glass_every"]) == 1 and int(Sim.WAVES[46]["scale_every"]) == 1 and int(Sim.WAVES[46]["mail_every"]) == 1 and int(Sim.WAVES[46]["hide_every"]) == 1 and int(Sim.WAVES[46]["dusk_every"]) == 1 and int(Sim.WAVES[46]["veil_every"]) == 1 and int(Sim.WAVES[46]["pall_every"]) == 1 and int(Sim.WAVES[46]["gloom_every"]) == 1 and int(Sim.WAVES[46]["murk_every"]) == 1 and int(Sim.WAVES[46]["dread_every"]) == 1 and int(Sim.WAVES[46]["woe_every"]) == 1 and int(Sim.WAVES[46]["blight_every"]) == 1 and int(Sim.WAVES[46]["rot_every"]) == 1 and int(Sim.WAVES[46]["mildew_every"]) == 1 and int(Sim.WAVES[46]["rust_every"]) == 1 and int(Sim.WAVES[46]["scab_every"]) == 1 and int(Sim.WAVES[46]["spot_every"]) == 1 and str(Sim.WAVES[46]["name"]) == "Scorch", "night 47 keeps Blotch's 16 moths and adds spot on every one")
	for i in 45:
		_expect(int(Sim.WAVES[i].get("spot_every", 0)) == 0, "night %d spawns no spot moth" % (i + 1))
	_expect(str(Sim.WAVES[41]["name"]) == "Rust", "night 42 stays Rust")
	_expect(str(Sim.WAVES[42]["name"]) == "Brand", "night 43 stays Brand")
	_expect(str(Sim.WAVES[43]["name"]) == "Scab" and int(Sim.WAVES[43].get("spot_every", 0)) == 0, "night 44 stays Scab and carries no spot")
	_expect(str(Sim.WAVES[44]["name"]) == "Blotch" and int(Sim.WAVES[44].get("spot_every", 0)) == 0, "night 45 stays Blotch and carries no spot")
	var named = Sim.new(1)
	named.wave = 46
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 46 of 47 (Spot) — 0 pests left", "night 46 heading: %s" % named.phase_text())
	named.wave = 47
	_expect(named.phase_text() == "Night 47 of 47 (Scorch) — 0 pests left", "night 47 heading: %s" % named.phase_text())
	_expect(ORPHREY_TILE == Vector2i(3, 9), "the orphrey landed at (3, 9), one tile east of the amice")

	for run_seed in [42, 1, 7, 99, 256, 2026]:
		var held := _play(run_seed, Callable(self, "_orphrey_command"))
		print("  orphrey seed=%s outcome=%s night=%s hp=%s spot=%s/%s" % [run_seed, held[0], held[1], held[4], held[51], held[50]])
		_expect(int(held[0]) == Sim.OUTCOME_WON, "seed %s clears all forty-seven nights with the orphrey at (3, 9)" % run_seed)
		_expect(int(held[1]) == 47, "seed %s win is night 47" % run_seed)
		_expect(int(held[4]) == 100, "seed %s finished night 47 at full health (%s)" % [run_seed, held[4]])
		_expect(int(held[6]) == 184 and int(held[7]) == 184, "seed %s burned every shroud moth (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 346 and int(held[11]) == 346, "seed %s cracked every rind moth (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 330 and int(held[13]) == 330, "seed %s melted every pitch moth (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 314 and int(held[15]) == 314, "seed %s thawed every frost moth (%s/%s)" % [run_seed, held[15], held[14]])
		_expect(int(held[16]) == 298 and int(held[17]) == 298, "seed %s cut every web moth (%s/%s)" % [run_seed, held[17], held[16]])
		_expect(int(held[18]) == 282 and int(held[19]) == 282, "seed %s cracked every glass moth (%s/%s)" % [run_seed, held[19], held[18]])
		_expect(int(held[20]) == 266 and int(held[21]) == 266, "seed %s stripped every scale moth (%s/%s)" % [run_seed, held[21], held[20]])
		_expect(int(held[22]) == 250 and int(held[23]) == 250, "seed %s cracked every mail moth (%s/%s)" % [run_seed, held[23], held[22]])
		_expect(int(held[24]) == 234 and int(held[25]) == 234, "seed %s split every hide moth (%s/%s)" % [run_seed, held[25], held[24]])
		_expect(int(held[26]) == 218 and int(held[27]) == 218, "seed %s shaded every dusk moth (%s/%s)" % [run_seed, held[27], held[26]])
		_expect(int(held[28]) == 202 and int(held[29]) == 202, "seed %s cowled every veil moth (%s/%s)" % [run_seed, held[29], held[28]])
		_expect(int(held[30]) == 186 and int(held[31]) == 186, "seed %s hooded every pall moth (%s/%s)" % [run_seed, held[31], held[30]])
		_expect(int(held[32]) == 170 and int(held[33]) == 170, "seed %s cloaked every gloom moth (%s/%s)" % [run_seed, held[33], held[32]])
		_expect(int(held[34]) == 154 and int(held[35]) == 154, "seed %s caped every murk moth (%s/%s)" % [run_seed, held[35], held[34]])
		_expect(int(held[36]) == 138 and int(held[37]) == 138, "seed %s shawled every dread moth (%s/%s)" % [run_seed, held[37], held[36]])
		_expect(int(held[38]) == 122 and int(held[39]) == 122, "seed %s stoled every woe moth (%s/%s)" % [run_seed, held[39], held[38]])
		_expect(int(held[40]) == 106 and int(held[41]) == 106, "seed %s mantled every blight moth (%s/%s)" % [run_seed, held[41], held[40]])
		_expect(int(held[42]) == 90 and int(held[43]) == 90, "seed %s tippetted every rot moth (%s/%s)" % [run_seed, held[43], held[42]])
		_expect(int(held[44]) == 74 and int(held[45]) == 74, "seed %s wimpled every mildew moth (%s/%s)" % [run_seed, held[45], held[44]])
		_expect(int(held[46]) == 58 and int(held[47]) == 58, "seed %s albed every rust moth (%s/%s)" % [run_seed, held[47], held[46]])
		_expect(int(held[48]) == 42 and int(held[49]) == 42, "seed %s amiced every scab moth (%s/%s)" % [run_seed, held[49], held[48]])
		_expect(int(held[50]) == 26 and int(held[51]) == 26, "seed %s orphreyed every spot moth (%s/%s)" % [run_seed, held[51], held[50]])
		_expect(int(held[8]) == 0 and int(held[9]) == 23, "seed %s spent the twenty-three seeds, including the orphrey" % run_seed)
		var layout := _orphrey_garden_layout(run_seed)
		_expect(not bool(layout["lantern"]), "seed %s left the lantern unplanted" % run_seed)
		_expect(layout["shawl"] == Vector2i(2, 6), "seed %s kept the shawl at (2, 6)" % run_seed)
		_expect(layout["stole"] == STOLE_TILE, "seed %s kept the stole at (1, 5)" % run_seed)
		_expect(layout["mantle"] == MANTLE_TILE, "seed %s kept the mantle at (1, 6)" % run_seed)
		_expect(layout["tippet"] == TIPPET_TILE, "seed %s kept the tippet at (1, 7)" % run_seed)
		_expect(layout["wimple"] == WIMPLE_TILE, "seed %s kept the wimple at (1, 8)" % run_seed)
		_expect(layout["alb"] == ALB_TILE, "seed %s kept the alb at (1, 9)" % run_seed)
		_expect(layout["amice"] == AMICE_TILE, "seed %s kept the amice at (2, 9)" % run_seed)
		_expect(layout["orphrey"] == ORPHREY_TILE, "seed %s planted the orphrey at (3, 9)" % run_seed)
		var missed := _play(run_seed, Callable(self, "_corner_orphrey_command"))
		print("  CORNER_HP seed=%s outcome=%s night=%s hp=%s spot=%s/%s" % [run_seed, missed[0], missed[1], missed[4], missed[51], missed[50]])
		# (1, 1) still orphreys the gardener, so night 46 is not a sealed death. The other plants stay put. Every seed finishes night 47 with every spot moth killed.
		_expect(int(missed[0]) == Sim.OUTCOME_WON and int(missed[1]) == 47, "seed %s with a corner orphrey finishes night 47 (outcome %s night %s)" % [run_seed, missed[0], missed[1]])
		_expect(int(missed[4]) == 100, "seed %s corner orphrey finished night 47 at full health (%s)" % [run_seed, missed[4]])
		_expect(int(missed[50]) == int(missed[51]) and int(missed[50]) > 0, "seed %s corner orphrey killed every spot moth (%s/%s)" % [run_seed, missed[51], missed[50]])
		var corner_layout := _corner_orphrey_garden_layout(run_seed)
		_expect(corner_layout["amice"] == AMICE_TILE and corner_layout["orphrey"] == Vector2i(1, 1), "seed %s kept the amice at (2, 9) and put the orphrey at (1, 1)" % run_seed)
		_expect(corner_layout["shawl"] == Vector2i(2, 6) and corner_layout["stole"] == STOLE_TILE and corner_layout["mantle"] == MANTLE_TILE and corner_layout["tippet"] == TIPPET_TILE and corner_layout["wimple"] == WIMPLE_TILE and corner_layout["alb"] == ALB_TILE, "seed %s left the shawl, the stole, the mantle, the tippet, the wimple, and the alb where they were" % run_seed)
	var again := _play(42, Callable(self, "_orphrey_command"))
	var replay := _play(42, Callable(self, "_orphrey_command"))
	_expect(str(again) == str(replay), "same seed and orphrey plan replay")


func _orphrey_garden_layout(seed_value: int) -> Dictionary:
	return _layout_for(seed_value, Callable(self, "_orphrey_command"))


func _corner_orphrey_garden_layout(seed_value: int) -> Dictionary:
	return _layout_for(seed_value, Callable(self, "_corner_orphrey_command"))


func _test_fog_visibility() -> void:
	print("fog visibility")
	var sim = Sim.new(42)
	var far := Vector2i(1, 1)
	var pest = sim.spawn_pest(sim.tile_center(far.x, far.y))
	_expect(pest.hidden, "pest on an unlit tile is flagged hidden")
	_expect(not sim.tile_lit(far.x, far.y), "that tile is unlit before any plant")
	var cmd = Sim.Command.new()
	cmd.plant_kind = Catalog.LANTERN
	cmd.tile = Vector2i(1, 5)
	sim.step(cmd)
	var lantern = sim.plant_of_kind(Catalog.LANTERN)
	var same = sim.pest_by_id(pest.id)
	_expect(lantern != null and same != null, "lantern and the same pest still exist")
	if lantern == null or same == null:
		return
	var inside: bool = lantern.pos.distance_to(same.pos) <= float(lantern.light_radius)
	_expect((not same.hidden) and inside, "same pest inside the lantern radius is flagged visible (hidden=%s dist=%s radius=%s)" % [same.hidden, lantern.pos.distance_to(same.pos), lantern.light_radius])
	_expect(sim.tile_lit(sim.cell_of(same.pos).x, sim.cell_of(same.pos).y), "occupied tile is lit once the lantern covers it")


func _test_no_dominance() -> void:
	print("no plant strictly dominates the documented axes")
	var damage_max := -1
	var radius_max := -1.0
	var fastest := 999999
	var lantern_damage := 0
	var pea_radius := 0.0
	var gourd_ticks := 0
	for kind in Catalog.COUNT:
		var stats := Catalog.get_stats(kind)
		damage_max = maxi(damage_max, int(stats["damage"]))
		radius_max = maxf(radius_max, float(stats["light_radius"]))
		fastest = mini(fastest, int(stats["fire_ticks"]))
		if kind == Catalog.LANTERN:
			lantern_damage = int(stats["damage"])
		elif kind == Catalog.PEA:
			pea_radius = float(stats["light_radius"])
		elif kind == Catalog.GOURD:
			gourd_ticks = int(stats["fire_ticks"])
	_expect(lantern_damage < damage_max, "lantern is not the highest damage (%s < %s)" % [lantern_damage, damage_max])
	_expect(pea_radius < radius_max, "pea is not the largest radius (%s < %s)" % [pea_radius, radius_max])
	_expect(gourd_ticks > fastest, "gourd is not the fastest fire rate (%s ticks > %s)" % [gourd_ticks, fastest])
	var burners := 0
	var crackers := 0
	var melters := 0
	var thawers := 0
	var cutters := 0
	var glaziers := 0
	var strippers := 0
	var maulers := 0
	var splitters := 0
	var shaders := 0
	var cowlers := 0
	var hooders := 0
	var cloakers := 0
	var capers := 0
	var shawlers := 0
	var stolers := 0
	var mantlers := 0
	var tippeters := 0
	var wimplers := 0
	var albers := 0
	var amicers := 0
	var orphreyers := 0
	var scores: Array = []
	for kind in Catalog.COUNT:
		var stats := Catalog.get_stats(kind)
		if bool(stats["burns_shroud"]):
			burners += 1
		if bool(stats["cracks_rind"]):
			crackers += 1
		if bool(stats["melts_pitch"]):
			melters += 1
		if bool(stats["thaws_frost"]):
			thawers += 1
		if bool(stats["cuts_web"]):
			cutters += 1
		if bool(stats["cracks_glass"]):
			glaziers += 1
		if bool(stats["strips_scale"]):
			strippers += 1
		if bool(stats["cracks_mail"]):
			maulers += 1
		if bool(stats["splits_hide"]):
			splitters += 1
		if bool(stats["shades_dusk"]):
			shaders += 1
		if bool(stats["cowls_veil"]):
			cowlers += 1
		if bool(stats["hoods_pall"]):
			hooders += 1
		if bool(stats["cloaks_gloom"]):
			cloakers += 1
		if bool(stats["capes_murk"]):
			capers += 1
		if bool(stats["shawls_dread"]):
			shawlers += 1
		if bool(stats["stoles_woe"]):
			stolers += 1
		if bool(stats["mantles_blight"]):
			mantlers += 1
		if bool(stats["tippets_rot"]):
			tippeters += 1
		if bool(stats["wimples_mildew"]):
			wimplers += 1
		if bool(stats["albs_rust"]):
			albers += 1
		if bool(stats["amices_scab"]):
			amicers += 1
		if bool(stats["orphreys_spot"]):
			orphreyers += 1
		var specials := 0
		if bool(stats["burns_shroud"]):
			specials += 1
		if bool(stats["cracks_rind"]):
			specials += 1
		if bool(stats["melts_pitch"]):
			specials += 1
		if bool(stats["thaws_frost"]):
			specials += 1
		if bool(stats["cuts_web"]):
			specials += 1
		if bool(stats["cracks_glass"]):
			specials += 1
		if bool(stats["strips_scale"]):
			specials += 1
		if bool(stats["cracks_mail"]):
			specials += 1
		if bool(stats["splits_hide"]):
			specials += 1
		if bool(stats["shades_dusk"]):
			specials += 1
		if bool(stats["cowls_veil"]):
			specials += 1
		if bool(stats["hoods_pall"]):
			specials += 1
		if bool(stats["cloaks_gloom"]):
			specials += 1
		if bool(stats["capes_murk"]):
			specials += 1
		if bool(stats["shawls_dread"]):
			specials += 1
		if bool(stats["stoles_woe"]):
			specials += 1
		if bool(stats["mantles_blight"]):
			specials += 1
		if bool(stats["tippets_rot"]):
			specials += 1
		if bool(stats["wimples_mildew"]):
			specials += 1
		if bool(stats["albs_rust"]):
			specials += 1
		if bool(stats["amices_scab"]):
			specials += 1
		if bool(stats["orphreys_spot"]):
			specials += 1
		_expect(specials <= 1, "%s keeps a single light rule" % stats["name"])
		scores.append(stats)
	_expect(burners == 1, "only one plant burns shroud")
	_expect(crackers == 1, "only one plant cracks rind")
	_expect(melters == 1, "only one plant melts pitch")
	_expect(thawers == 1, "only one plant thaws frost")
	_expect(cutters == 1, "only one plant cuts web")
	_expect(glaziers == 1, "only one plant cracks glass")
	_expect(strippers == 1, "only one plant strips scale")
	_expect(maulers == 1, "only one plant cracks mail")
	_expect(splitters == 1, "only one plant splits hide")
	_expect(shaders == 1, "only one plant shades dusk")
	_expect(cowlers == 1, "only one plant cowls veil")
	_expect(hooders == 1, "only one plant hoods pall")
	_expect(cloakers == 1, "only one plant cloaks gloom")
	_expect(capers == 1, "only one plant capes murk")
	_expect(shawlers == 1, "only one plant shawls dread")
	_expect(stolers == 1, "only one plant stoles woe")
	_expect(mantlers == 1, "only one plant mantles blight")
	_expect(tippeters == 1, "only one plant tippets rot")
	_expect(wimplers == 1, "only one plant wimples mildew")
	_expect(albers == 1, "only one plant albs rust")
	_expect(amicers == 1, "only one plant amices scab")
	_expect(orphreyers == 1, "only one plant orphreys spot")
	var wick := Catalog.get_stats(Catalog.WICK)
	_expect(bool(wick["burns_shroud"]), "wick burns shroud")
	_expect(not bool(wick["cracks_rind"]), "wick does not crack rind")
	_expect(not bool(wick["melts_pitch"]), "wick does not melt pitch")
	_expect(not bool(wick["thaws_frost"]), "wick does not thaw frost")
	_expect(not bool(wick["cuts_web"]), "wick does not cut web")
	_expect(not bool(wick["cracks_glass"]), "wick does not crack glass")
	_expect(not bool(wick["strips_scale"]), "wick does not strip scale")
	_expect(not bool(wick["cracks_mail"]), "wick does not crack mail")
	_expect(not bool(wick["splits_hide"]), "wick does not split hide")
	_expect(not bool(wick["shades_dusk"]), "wick does not shade dusk")
	_expect(not bool(wick["cowls_veil"]), "wick does not cowl veil")
	_expect(int(wick["damage"]) < damage_max, "wick is not the highest damage")
	_expect(float(wick["light_radius"]) < radius_max, "wick is not the largest light")
	_expect(int(wick["fire_ticks"]) > fastest, "wick is not the fastest fire")
	var briar := Catalog.get_stats(Catalog.BRIAR)
	_expect(bool(briar["cracks_rind"]), "briar cracks rind")
	_expect(not bool(briar["burns_shroud"]), "briar does not burn shroud")
	_expect(not bool(briar["melts_pitch"]), "briar does not melt pitch")
	_expect(not bool(briar["thaws_frost"]), "briar does not thaw frost")
	_expect(not bool(briar["cuts_web"]), "briar does not cut web")
	_expect(not bool(briar["cracks_glass"]), "briar does not crack glass")
	_expect(not bool(briar["strips_scale"]), "briar does not strip scale")
	_expect(not bool(briar["cracks_mail"]), "briar does not crack mail")
	_expect(not bool(briar["splits_hide"]), "briar does not split hide")
	_expect(not bool(briar["shades_dusk"]), "briar does not shade dusk")
	_expect(not bool(briar["cowls_veil"]), "briar does not cowl veil")
	_expect(int(briar["damage"]) < damage_max, "briar is not the highest damage")
	_expect(float(briar["light_radius"]) < radius_max, "briar is not the largest light")
	_expect(int(briar["fire_ticks"]) > fastest, "briar is not the fastest fire")
	var flare := Catalog.get_stats(Catalog.FLARE)
	_expect(bool(flare["melts_pitch"]), "flare melts pitch")
	_expect(not bool(flare["burns_shroud"]), "flare does not burn shroud")
	_expect(not bool(flare["cracks_rind"]), "flare does not crack rind")
	_expect(int(flare["damage"]) < damage_max, "flare is not the highest damage")
	_expect(float(flare["light_radius"]) < radius_max, "flare is not the largest light")
	_expect(int(flare["fire_ticks"]) > fastest, "flare is not the fastest fire")
	_expect(not bool(flare["thaws_frost"]), "flare does not thaw frost")
	_expect(not bool(flare["cuts_web"]), "flare does not cut web")
	_expect(not bool(flare["cracks_glass"]), "flare does not crack glass")
	_expect(not bool(flare["strips_scale"]), "flare does not strip scale")
	_expect(not bool(flare["cracks_mail"]), "flare does not crack mail")
	_expect(not bool(flare["splits_hide"]), "flare does not split hide")
	_expect(not bool(flare["shades_dusk"]), "flare does not shade dusk")
	_expect(not bool(flare["cowls_veil"]), "flare does not cowl veil")
	var hearth := Catalog.get_stats(Catalog.HEARTH)
	_expect(bool(hearth["thaws_frost"]), "hearth thaws frost")
	_expect(not bool(hearth["burns_shroud"]), "hearth does not burn shroud")
	_expect(not bool(hearth["cracks_rind"]), "hearth does not crack rind")
	_expect(not bool(hearth["melts_pitch"]), "hearth does not melt pitch")
	_expect(int(hearth["damage"]) < damage_max, "hearth is not the highest damage")
	_expect(float(hearth["light_radius"]) < radius_max, "hearth is not the largest light")
	_expect(int(hearth["fire_ticks"]) > fastest, "hearth is not the fastest fire")
	_expect(not bool(hearth["cuts_web"]), "hearth does not cut web")
	_expect(not bool(hearth["cracks_glass"]), "hearth does not crack glass")
	_expect(not bool(hearth["strips_scale"]), "hearth does not strip scale")
	_expect(not bool(hearth["cracks_mail"]), "hearth does not crack mail")
	_expect(not bool(hearth["splits_hide"]), "hearth does not split hide")
	_expect(not bool(hearth["shades_dusk"]), "hearth does not shade dusk")
	_expect(not bool(hearth["cowls_veil"]), "hearth does not cowl veil")
	var shear := Catalog.get_stats(Catalog.SHEAR)
	_expect(bool(shear["cuts_web"]), "shear cuts web")
	_expect(not bool(shear["burns_shroud"]), "shear does not burn shroud")
	_expect(not bool(shear["cracks_rind"]), "shear does not crack rind")
	_expect(not bool(shear["melts_pitch"]), "shear does not melt pitch")
	_expect(not bool(shear["thaws_frost"]), "shear does not thaw frost")
	_expect(int(shear["damage"]) < damage_max, "shear is not the highest damage")
	_expect(float(shear["light_radius"]) < radius_max, "shear is not the largest light")
	_expect(int(shear["fire_ticks"]) > fastest, "shear is not the fastest fire")
	_expect(not bool(shear["cracks_glass"]), "shear does not crack glass")
	_expect(not bool(shear["strips_scale"]), "shear does not strip scale")
	_expect(not bool(shear["cracks_mail"]), "shear does not crack mail")
	_expect(not bool(shear["splits_hide"]), "shear does not split hide")
	_expect(not bool(shear["shades_dusk"]), "shear does not shade dusk")
	_expect(not bool(shear["cowls_veil"]), "shear does not cowl veil")
	var chime := Catalog.get_stats(Catalog.CHIME)
	_expect(bool(chime["cracks_glass"]), "chime cracks glass")
	_expect(not bool(chime["burns_shroud"]), "chime does not burn shroud")
	_expect(not bool(chime["cracks_rind"]), "chime does not crack rind")
	_expect(not bool(chime["melts_pitch"]), "chime does not melt pitch")
	_expect(not bool(chime["thaws_frost"]), "chime does not thaw frost")
	_expect(not bool(chime["cuts_web"]), "chime does not cut web")
	_expect(not bool(chime["strips_scale"]), "chime does not strip scale")
	_expect(not bool(chime["cracks_mail"]), "chime does not crack mail")
	_expect(not bool(chime["splits_hide"]), "chime does not split hide")
	_expect(not bool(chime["shades_dusk"]), "chime does not shade dusk")
	_expect(not bool(chime["cowls_veil"]), "chime does not cowl veil")
	_expect(int(chime["damage"]) < damage_max, "chime is not the highest damage")
	_expect(float(chime["light_radius"]) < radius_max, "chime is not the largest light")
	_expect(int(chime["fire_ticks"]) > fastest, "chime is not the fastest fire")
	var rasp := Catalog.get_stats(Catalog.RASP)
	_expect(bool(rasp["strips_scale"]), "rasp strips scale")
	_expect(not bool(rasp["burns_shroud"]), "rasp does not burn shroud")
	_expect(not bool(rasp["cracks_rind"]), "rasp does not crack rind")
	_expect(not bool(rasp["melts_pitch"]), "rasp does not melt pitch")
	_expect(not bool(rasp["thaws_frost"]), "rasp does not thaw frost")
	_expect(not bool(rasp["cuts_web"]), "rasp does not cut web")
	_expect(not bool(rasp["cracks_glass"]), "rasp does not crack glass")
	_expect(not bool(rasp["cracks_mail"]), "rasp does not crack mail")
	_expect(not bool(rasp["splits_hide"]), "rasp does not split hide")
	_expect(not bool(rasp["shades_dusk"]), "rasp does not shade dusk")
	_expect(not bool(rasp["cowls_veil"]), "rasp does not cowl veil")
	_expect(int(rasp["damage"]) < damage_max, "rasp is not the highest damage")
	_expect(float(rasp["light_radius"]) < radius_max, "rasp is not the largest light")
	_expect(int(rasp["fire_ticks"]) > fastest, "rasp is not the fastest fire")
	var maul := Catalog.get_stats(Catalog.MAUL)
	_expect(bool(maul["cracks_mail"]), "maul cracks mail")
	_expect(not bool(maul["burns_shroud"]), "maul does not burn shroud")
	_expect(not bool(maul["cracks_rind"]), "maul does not crack rind")
	_expect(not bool(maul["melts_pitch"]), "maul does not melt pitch")
	_expect(not bool(maul["thaws_frost"]), "maul does not thaw frost")
	_expect(not bool(maul["cuts_web"]), "maul does not cut web")
	_expect(not bool(maul["cracks_glass"]), "maul does not crack glass")
	_expect(not bool(maul["strips_scale"]), "maul does not strip scale")
	_expect(not bool(maul["splits_hide"]), "maul does not split hide")
	_expect(not bool(maul["shades_dusk"]), "maul does not shade dusk")
	_expect(not bool(maul["cowls_veil"]), "maul does not cowl veil")
	_expect(int(maul["damage"]) < damage_max, "maul is not the highest damage")
	_expect(float(maul["light_radius"]) < radius_max, "maul is not the largest light")
	_expect(int(maul["fire_ticks"]) > fastest, "maul is not the fastest fire")
	var bill := Catalog.get_stats(Catalog.BILL)
	_expect(bool(bill["splits_hide"]), "bill splits hide")
	_expect(not bool(bill["burns_shroud"]), "bill does not burn shroud")
	_expect(not bool(bill["cracks_rind"]), "bill does not crack rind")
	_expect(not bool(bill["melts_pitch"]), "bill does not melt pitch")
	_expect(not bool(bill["thaws_frost"]), "bill does not thaw frost")
	_expect(not bool(bill["cuts_web"]), "bill does not cut web")
	_expect(not bool(bill["cracks_glass"]), "bill does not crack glass")
	_expect(not bool(bill["strips_scale"]), "bill does not strip scale")
	_expect(not bool(bill["cracks_mail"]), "bill does not crack mail")
	_expect(not bool(bill["shades_dusk"]), "bill does not shade dusk")
	_expect(not bool(bill["cowls_veil"]), "bill does not cowl veil")
	_expect(int(bill["damage"]) < damage_max, "bill is not the highest damage")
	_expect(float(bill["light_radius"]) < radius_max, "bill is not the largest light")
	_expect(int(bill["fire_ticks"]) > fastest, "bill is not the fastest fire")
	var shade := Catalog.get_stats(Catalog.SHADE)
	_expect(bool(shade["shades_dusk"]), "shade shades dusk")
	_expect(not bool(shade["casts_light"]), "shade is not a light")
	_expect(not bool(shade["burns_shroud"]), "shade does not burn shroud")
	_expect(not bool(shade["cracks_rind"]), "shade does not crack rind")
	_expect(not bool(shade["melts_pitch"]), "shade does not melt pitch")
	_expect(not bool(shade["thaws_frost"]), "shade does not thaw frost")
	_expect(not bool(shade["cuts_web"]), "shade does not cut web")
	_expect(not bool(shade["cracks_glass"]), "shade does not crack glass")
	_expect(not bool(shade["strips_scale"]), "shade does not strip scale")
	_expect(not bool(shade["cracks_mail"]), "shade does not crack mail")
	_expect(not bool(shade["splits_hide"]), "shade does not split hide")
	_expect(not bool(shade["cowls_veil"]), "shade does not cowl veil")
	_expect(not bool(shade["hoods_pall"]), "shade does not hood pall")
	_expect(not bool(shade["cloaks_gloom"]), "shade does not cloak gloom")
	_expect(not bool(shade["capes_murk"]), "shade does not cape murk")
	_expect(not bool(shade["shawls_dread"]), "shade does not shawl dread")
	_expect(not bool(shade["stoles_woe"]), "shade does not stole woe")
	_expect(not bool(shade["mantles_blight"]), "shade does not mantle blight")
	_expect(not bool(shade["tippets_rot"]), "shade does not tippet rot")
	_expect(int(shade["damage"]) < damage_max, "shade is not the highest damage")
	_expect(int(shade["fire_ticks"]) > fastest, "shade is not the fastest fire")
	var cowl := Catalog.get_stats(Catalog.COWL)
	_expect(bool(cowl["cowls_veil"]), "cowl cowls veil")
	_expect(not bool(cowl["casts_light"]), "cowl is not a light")
	_expect(not bool(cowl["burns_shroud"]), "cowl does not burn shroud")
	_expect(not bool(cowl["cracks_rind"]), "cowl does not crack rind")
	_expect(not bool(cowl["melts_pitch"]), "cowl does not melt pitch")
	_expect(not bool(cowl["thaws_frost"]), "cowl does not thaw frost")
	_expect(not bool(cowl["cuts_web"]), "cowl does not cut web")
	_expect(not bool(cowl["cracks_glass"]), "cowl does not crack glass")
	_expect(not bool(cowl["strips_scale"]), "cowl does not strip scale")
	_expect(not bool(cowl["cracks_mail"]), "cowl does not crack mail")
	_expect(not bool(cowl["splits_hide"]), "cowl does not split hide")
	_expect(not bool(cowl["shades_dusk"]), "cowl does not shade dusk")
	_expect(not bool(cowl["hoods_pall"]), "cowl does not hood pall")
	_expect(not bool(cowl["cloaks_gloom"]), "cowl does not cloak gloom")
	_expect(not bool(cowl["capes_murk"]), "cowl does not cape murk")
	_expect(not bool(cowl["shawls_dread"]), "cowl does not shawl dread")
	_expect(not bool(cowl["stoles_woe"]), "cowl does not stole woe")
	_expect(not bool(cowl["mantles_blight"]), "cowl does not mantle blight")
	_expect(not bool(cowl["tippets_rot"]), "cowl does not tippet rot")
	_expect(int(cowl["damage"]) < damage_max, "cowl is not the highest damage")
	_expect(int(cowl["fire_ticks"]) > fastest, "cowl is not the fastest fire")
	_expect(float(cowl["light_radius"]) == 240.0, "cowl radius is 240px")
	var hood := Catalog.get_stats(Catalog.HOOD)
	_expect(bool(hood["hoods_pall"]), "hood hoods pall")
	_expect(not bool(hood["casts_light"]), "hood is not a light")
	_expect(not bool(hood["burns_shroud"]), "hood does not burn shroud")
	_expect(not bool(hood["cracks_rind"]), "hood does not crack rind")
	_expect(not bool(hood["melts_pitch"]), "hood does not melt pitch")
	_expect(not bool(hood["thaws_frost"]), "hood does not thaw frost")
	_expect(not bool(hood["cuts_web"]), "hood does not cut web")
	_expect(not bool(hood["cracks_glass"]), "hood does not crack glass")
	_expect(not bool(hood["strips_scale"]), "hood does not strip scale")
	_expect(not bool(hood["cracks_mail"]), "hood does not crack mail")
	_expect(not bool(hood["splits_hide"]), "hood does not split hide")
	_expect(not bool(hood["shades_dusk"]), "hood does not shade dusk")
	_expect(not bool(hood["cowls_veil"]), "hood does not cowl veil")
	_expect(not bool(hood["cloaks_gloom"]), "hood does not cloak gloom")
	_expect(not bool(hood["capes_murk"]), "hood does not cape murk")
	_expect(not bool(hood["shawls_dread"]), "hood does not shawl dread")
	_expect(not bool(hood["stoles_woe"]), "hood does not stole woe")
	_expect(not bool(hood["mantles_blight"]), "hood does not mantle blight")
	_expect(not bool(hood["tippets_rot"]), "hood does not tippet rot")
	_expect(int(hood["damage"]) < damage_max, "hood is not the highest damage")
	_expect(int(hood["fire_ticks"]) > fastest, "hood is not the fastest fire")
	_expect(float(hood["light_radius"]) == 256.0, "hood radius is 256px")
	_expect(float(hood["weapon_range"]) == 20.0, "hood weapon range is 20px")
	_expect(float(hood["projectile_speed"]) == 240.0, "hood shot speed is 240px/s")
	_expect(int(hood["fire_ticks"]) == 60, "hood fires every 60 ticks")
	_expect(int(hood["damage"]) == 2, "hood damage is 2")
	_expect(float(hood["splash_radius"]) == 0.0, "hood has no splash")
	_expect(int(hood["slow_ticks"]) == 0, "hood has no slow")
	var cloak := Catalog.get_stats(Catalog.CLOAK)
	_expect(bool(cloak["cloaks_gloom"]), "cloak cloaks gloom")
	_expect(not bool(cloak["casts_light"]), "cloak is not a light")
	_expect(not bool(cloak["burns_shroud"]), "cloak does not burn shroud")
	_expect(not bool(cloak["cracks_rind"]), "cloak does not crack rind")
	_expect(not bool(cloak["melts_pitch"]), "cloak does not melt pitch")
	_expect(not bool(cloak["thaws_frost"]), "cloak does not thaw frost")
	_expect(not bool(cloak["cuts_web"]), "cloak does not cut web")
	_expect(not bool(cloak["cracks_glass"]), "cloak does not crack glass")
	_expect(not bool(cloak["strips_scale"]), "cloak does not strip scale")
	_expect(not bool(cloak["cracks_mail"]), "cloak does not crack mail")
	_expect(not bool(cloak["splits_hide"]), "cloak does not split hide")
	_expect(not bool(cloak["shades_dusk"]), "cloak does not shade dusk")
	_expect(not bool(cloak["cowls_veil"]), "cloak does not cowl veil")
	_expect(not bool(cloak["hoods_pall"]), "cloak does not hood pall")
	_expect(not bool(cloak["capes_murk"]), "cloak does not cape murk")
	_expect(not bool(cloak["shawls_dread"]), "cloak does not shawl dread")
	_expect(not bool(cloak["stoles_woe"]), "cloak does not stole woe")
	_expect(not bool(cloak["mantles_blight"]), "cloak does not mantle blight")
	_expect(not bool(cloak["tippets_rot"]), "cloak does not tippet rot")
	_expect(int(cloak["damage"]) < damage_max, "cloak is not the highest damage")
	_expect(int(cloak["damage"]) > lantern_damage, "cloak damage stays above the lantern")
	_expect(int(cloak["fire_ticks"]) > fastest, "cloak is not the fastest fire")
	_expect(float(cloak["light_radius"]) == 272.0, "cloak radius is 272px")
	_expect(float(cloak["weapon_range"]) == 16.0, "cloak weapon range is 16px")
	_expect(float(cloak["projectile_speed"]) == 220.0, "cloak shot speed is 220px/s")
	_expect(int(cloak["fire_ticks"]) == 66, "cloak fires every 66 ticks")
	_expect(int(cloak["damage"]) == 2, "cloak damage is 2")
	_expect(float(cloak["splash_radius"]) == 0.0, "cloak has no splash")
	_expect(int(cloak["slow_ticks"]) == 0, "cloak has no slow")
	var cape := Catalog.get_stats(Catalog.CAPE)
	_expect(bool(cape["capes_murk"]), "cape capes murk")
	_expect(not bool(cape["casts_light"]), "cape is not a light")
	_expect(not bool(cape["cloaks_gloom"]), "cape does not cloak gloom")
	_expect(not bool(cape["hoods_pall"]), "cape does not hood pall")
	_expect(not bool(cape["cowls_veil"]), "cape does not cowl veil")
	_expect(not bool(cape["shades_dusk"]), "cape does not shade dusk")
	_expect(not bool(cape["burns_shroud"]), "cape does not burn shroud")
	_expect(not bool(cape["cracks_rind"]), "cape does not crack rind")
	_expect(not bool(cape["melts_pitch"]), "cape does not melt pitch")
	_expect(not bool(cape["thaws_frost"]), "cape does not thaw frost")
	_expect(not bool(cape["cuts_web"]), "cape does not cut web")
	_expect(not bool(cape["cracks_glass"]), "cape does not crack glass")
	_expect(not bool(cape["strips_scale"]), "cape does not strip scale")
	_expect(not bool(cape["cracks_mail"]), "cape does not crack mail")
	_expect(not bool(cape["splits_hide"]), "cape does not split hide")
	_expect(not bool(cape["shawls_dread"]), "cape does not shawl dread")
	_expect(not bool(cape["stoles_woe"]), "cape does not stole woe")
	_expect(not bool(cape["mantles_blight"]), "cape does not mantle blight")
	_expect(not bool(cape["tippets_rot"]), "cape does not tippet rot")
	_expect(int(cape["damage"]) < damage_max, "cape is not the highest damage")
	_expect(int(cape["damage"]) > lantern_damage, "cape damage stays above the lantern")
	_expect(int(cape["fire_ticks"]) > fastest, "cape is not the fastest fire")
	_expect(float(cape["light_radius"]) == 288.0, "cape radius is 288px")
	_expect(float(cape["weapon_range"]) == 16.0, "cape weapon range is 16px")
	_expect(float(cape["projectile_speed"]) == 220.0, "cape shot speed is 220px/s")
	_expect(int(cape["fire_ticks"]) == 66, "cape fires every 66 ticks")
	_expect(int(cape["damage"]) == 2, "cape damage is 2")
	_expect(float(cape["splash_radius"]) == 0.0, "cape has no splash")
	_expect(int(cape["slow_ticks"]) == 0, "cape has no slow")
	_expect(str(cape["role"]) == "Capes murk, modest shots, no light.", "cape role text")
	var shawl := Catalog.get_stats(Catalog.SHAWL)
	_expect(bool(shawl["shawls_dread"]), "shawl shawls dread")
	_expect(not bool(shawl["casts_light"]), "shawl is not a light")
	_expect(not bool(shawl["capes_murk"]), "shawl does not cape murk")
	_expect(not bool(shawl["cloaks_gloom"]), "shawl does not cloak gloom")
	_expect(not bool(shawl["hoods_pall"]), "shawl does not hood pall")
	_expect(not bool(shawl["cowls_veil"]), "shawl does not cowl veil")
	_expect(not bool(shawl["shades_dusk"]), "shawl does not shade dusk")
	_expect(not bool(shawl["burns_shroud"]), "shawl does not burn shroud")
	_expect(not bool(shawl["cracks_rind"]), "shawl does not crack rind")
	_expect(not bool(shawl["melts_pitch"]), "shawl does not melt pitch")
	_expect(not bool(shawl["thaws_frost"]), "shawl does not thaw frost")
	_expect(not bool(shawl["cuts_web"]), "shawl does not cut web")
	_expect(not bool(shawl["cracks_glass"]), "shawl does not crack glass")
	_expect(not bool(shawl["strips_scale"]), "shawl does not strip scale")
	_expect(not bool(shawl["cracks_mail"]), "shawl does not crack mail")
	_expect(not bool(shawl["splits_hide"]), "shawl does not split hide")
	_expect(int(shawl["damage"]) < damage_max, "shawl is not the highest damage")
	_expect(int(shawl["damage"]) > lantern_damage, "shawl damage stays above the lantern")
	_expect(int(shawl["fire_ticks"]) > fastest, "shawl is not the fastest fire")
	_expect(float(shawl["light_radius"]) == 304.0, "shawl radius is 304px")
	_expect(float(shawl["weapon_range"]) == 16.0, "shawl weapon range is 16px")
	_expect(float(shawl["projectile_speed"]) == 220.0, "shawl shot speed is 220px/s")
	_expect(int(shawl["fire_ticks"]) == 66, "shawl fires every 66 ticks")
	_expect(int(shawl["damage"]) == 2, "shawl damage is 2")
	_expect(float(shawl["splash_radius"]) == 0.0, "shawl has no splash")
	_expect(int(shawl["slow_ticks"]) == 0, "shawl has no slow")
	_expect(not bool(shawl["stoles_woe"]), "shawl does not stole woe")
	_expect(not bool(shawl["mantles_blight"]), "shawl does not mantle blight")
	_expect(not bool(shawl["tippets_rot"]), "shawl does not tippet rot")
	_expect(str(shawl["role"]) == "Shawls dread, modest shots, no light.", "shawl role text")
	var stole := Catalog.get_stats(Catalog.STOLE)
	_expect(bool(stole["stoles_woe"]), "stole stoles woe")
	_expect(not bool(stole["casts_light"]), "stole is not a light")
	_expect(not bool(stole["shawls_dread"]), "stole does not shawl dread")
	_expect(not bool(stole["capes_murk"]), "stole does not cape murk")
	_expect(not bool(stole["cloaks_gloom"]), "stole does not cloak gloom")
	_expect(not bool(stole["hoods_pall"]), "stole does not hood pall")
	_expect(not bool(stole["cowls_veil"]), "stole does not cowl veil")
	_expect(not bool(stole["shades_dusk"]), "stole does not shade dusk")
	_expect(not bool(stole["burns_shroud"]), "stole does not burn shroud")
	_expect(not bool(stole["cracks_rind"]), "stole does not crack rind")
	_expect(not bool(stole["melts_pitch"]), "stole does not melt pitch")
	_expect(not bool(stole["thaws_frost"]), "stole does not thaw frost")
	_expect(not bool(stole["cuts_web"]), "stole does not cut web")
	_expect(not bool(stole["cracks_glass"]), "stole does not crack glass")
	_expect(not bool(stole["strips_scale"]), "stole does not strip scale")
	_expect(not bool(stole["cracks_mail"]), "stole does not crack mail")
	_expect(not bool(stole["splits_hide"]), "stole does not split hide")
	_expect(int(stole["damage"]) < damage_max, "stole is not the highest damage")
	_expect(int(stole["damage"]) > lantern_damage, "stole damage stays above the lantern")
	_expect(int(stole["fire_ticks"]) > fastest, "stole is not the fastest fire")
	_expect(int(stole["fire_ticks"]) > int(shawl["fire_ticks"]), "stole fires slower than the shawl")
	_expect(float(stole["light_radius"]) == 320.0, "stole radius is 320px")
	_expect(float(stole["light_radius"]) > float(shawl["light_radius"]), "stole radius is wider than the shawl")
	_expect(float(stole["weapon_range"]) == 12.0, "stole weapon range is 12px")
	_expect(float(stole["weapon_range"]) < float(shawl["weapon_range"]), "stole shot is shorter than the shawl")
	_expect(float(stole["projectile_speed"]) == 200.0, "stole shot speed is 200px/s")
	_expect(float(stole["projectile_speed"]) < float(shawl["projectile_speed"]), "stole shot is slower than the shawl")
	_expect(int(stole["fire_ticks"]) == 72, "stole fires every 72 ticks")
	_expect(int(stole["damage"]) == 2, "stole damage is 2")
	_expect(float(stole["splash_radius"]) == 0.0, "stole has no splash")
	_expect(int(stole["slow_ticks"]) == 0, "stole has no slow")
	_expect(not bool(stole["mantles_blight"]), "stole does not mantle blight")
	_expect(not bool(stole["tippets_rot"]), "stole does not tippet rot")
	_expect(str(stole["role"]) == "Stoles woe, modest shots, no light.", "stole role text")
	var mantle := Catalog.get_stats(Catalog.MANTLE)
	_expect(bool(mantle["mantles_blight"]), "mantle mantles blight")
	_expect(not bool(mantle["casts_light"]), "mantle is not a light")
	_expect(not bool(mantle["stoles_woe"]), "mantle does not stole woe")
	_expect(not bool(mantle["shawls_dread"]), "mantle does not shawl dread")
	_expect(not bool(mantle["capes_murk"]), "mantle does not cape murk")
	_expect(not bool(mantle["cloaks_gloom"]), "mantle does not cloak gloom")
	_expect(not bool(mantle["hoods_pall"]), "mantle does not hood pall")
	_expect(not bool(mantle["cowls_veil"]), "mantle does not cowl veil")
	_expect(not bool(mantle["shades_dusk"]), "mantle does not shade dusk")
	_expect(not bool(mantle["burns_shroud"]), "mantle does not burn shroud")
	_expect(not bool(mantle["cracks_rind"]), "mantle does not crack rind")
	_expect(not bool(mantle["melts_pitch"]), "mantle does not melt pitch")
	_expect(not bool(mantle["thaws_frost"]), "mantle does not thaw frost")
	_expect(not bool(mantle["cuts_web"]), "mantle does not cut web")
	_expect(not bool(mantle["cracks_glass"]), "mantle does not crack glass")
	_expect(not bool(mantle["strips_scale"]), "mantle does not strip scale")
	_expect(not bool(mantle["cracks_mail"]), "mantle does not crack mail")
	_expect(not bool(mantle["splits_hide"]), "mantle does not split hide")
	_expect(int(mantle["damage"]) < damage_max, "mantle is not the highest damage")
	_expect(int(mantle["damage"]) > lantern_damage, "mantle damage stays above the lantern")
	_expect(int(mantle["fire_ticks"]) > fastest, "mantle is not the fastest fire")
	_expect(int(mantle["fire_ticks"]) > int(stole["fire_ticks"]), "mantle fires slower than the stole")
	_expect(float(mantle["light_radius"]) == 336.0, "mantle radius is 336px")
	_expect(float(mantle["light_radius"]) > float(stole["light_radius"]), "mantle radius is wider than the stole")
	_expect(float(mantle["weapon_range"]) == 12.0, "mantle weapon range is 12px")
	_expect(float(mantle["projectile_speed"]) == 180.0, "mantle shot speed is 180px/s")
	_expect(float(mantle["projectile_speed"]) < float(stole["projectile_speed"]), "mantle shot is slower than the stole")
	_expect(int(mantle["fire_ticks"]) == 78, "mantle fires every 78 ticks")
	_expect(int(mantle["damage"]) == 2, "mantle damage is 2")
	_expect(float(mantle["splash_radius"]) == 0.0, "mantle has no splash")
	_expect(int(mantle["slow_ticks"]) == 0, "mantle has no slow")
	_expect(not bool(mantle["tippets_rot"]), "mantle does not tippet rot")
	_expect(str(mantle["role"]) == "Mantles blight, modest shots, no light.", "mantle role text")
	var tippet := Catalog.get_stats(Catalog.TIPPET)
	_expect(bool(tippet["tippets_rot"]), "tippet tippets rot")
	_expect(not bool(tippet["casts_light"]), "tippet is not a light")
	_expect(not bool(tippet["mantles_blight"]), "tippet does not mantle blight")
	_expect(not bool(tippet["stoles_woe"]), "tippet does not stole woe")
	_expect(not bool(tippet["shawls_dread"]), "tippet does not shawl dread")
	_expect(not bool(tippet["capes_murk"]), "tippet does not cape murk")
	_expect(not bool(tippet["cloaks_gloom"]), "tippet does not cloak gloom")
	_expect(not bool(tippet["hoods_pall"]), "tippet does not hood pall")
	_expect(not bool(tippet["cowls_veil"]), "tippet does not cowl veil")
	_expect(not bool(tippet["shades_dusk"]), "tippet does not shade dusk")
	_expect(not bool(tippet["burns_shroud"]), "tippet does not burn shroud")
	_expect(not bool(tippet["cracks_rind"]), "tippet does not crack rind")
	_expect(not bool(tippet["melts_pitch"]), "tippet does not melt pitch")
	_expect(not bool(tippet["thaws_frost"]), "tippet does not thaw frost")
	_expect(not bool(tippet["cuts_web"]), "tippet does not cut web")
	_expect(not bool(tippet["cracks_glass"]), "tippet does not crack glass")
	_expect(not bool(tippet["strips_scale"]), "tippet does not strip scale")
	_expect(not bool(tippet["cracks_mail"]), "tippet does not crack mail")
	_expect(not bool(tippet["splits_hide"]), "tippet does not split hide")
	_expect(int(tippet["damage"]) < damage_max, "tippet is not the highest damage")
	_expect(int(tippet["damage"]) > lantern_damage, "tippet damage stays above the lantern")
	_expect(int(tippet["fire_ticks"]) > fastest, "tippet is not the fastest fire")
	_expect(int(tippet["fire_ticks"]) > int(mantle["fire_ticks"]), "tippet fires slower than the mantle")
	_expect(float(tippet["light_radius"]) == 352.0, "tippet radius is 352px")
	_expect(float(tippet["light_radius"]) > float(mantle["light_radius"]), "tippet radius is wider than the mantle")
	_expect(float(tippet["weapon_range"]) == 12.0, "tippet weapon range is 12px")
	_expect(float(tippet["projectile_speed"]) == 160.0, "tippet shot speed is 160px/s")
	_expect(float(tippet["projectile_speed"]) < float(mantle["projectile_speed"]), "tippet shot is slower than the mantle")
	_expect(int(tippet["fire_ticks"]) == 84, "tippet fires every 84 ticks")
	_expect(int(tippet["damage"]) == 2, "tippet damage is 2")
	_expect(float(tippet["splash_radius"]) == 0.0, "tippet has no splash")
	_expect(int(tippet["slow_ticks"]) == 0, "tippet has no slow")
	_expect(not bool(tippet["wimples_mildew"]), "tippet does not wimple mildew")
	_expect(str(tippet["role"]) == "Tippets rot, modest shots, no light.", "tippet role text")
	var wimple := Catalog.get_stats(Catalog.WIMPLE)
	_expect(bool(wimple["wimples_mildew"]), "wimple wimples mildew")
	_expect(not bool(wimple["casts_light"]), "wimple is not a light")
	_expect(not bool(wimple["tippets_rot"]), "wimple does not tippet rot")
	_expect(not bool(wimple["mantles_blight"]), "wimple does not mantle blight")
	_expect(not bool(wimple["stoles_woe"]), "wimple does not stole woe")
	_expect(not bool(wimple["shawls_dread"]), "wimple does not shawl dread")
	_expect(not bool(wimple["capes_murk"]), "wimple does not cape murk")
	_expect(not bool(wimple["cloaks_gloom"]), "wimple does not cloak gloom")
	_expect(not bool(wimple["hoods_pall"]), "wimple does not hood pall")
	_expect(not bool(wimple["cowls_veil"]), "wimple does not cowl veil")
	_expect(not bool(wimple["shades_dusk"]), "wimple does not shade dusk")
	_expect(not bool(wimple["burns_shroud"]), "wimple does not burn shroud")
	_expect(not bool(wimple["cracks_rind"]), "wimple does not crack rind")
	_expect(not bool(wimple["melts_pitch"]), "wimple does not melt pitch")
	_expect(not bool(wimple["thaws_frost"]), "wimple does not thaw frost")
	_expect(not bool(wimple["cuts_web"]), "wimple does not cut web")
	_expect(not bool(wimple["cracks_glass"]), "wimple does not crack glass")
	_expect(not bool(wimple["strips_scale"]), "wimple does not strip scale")
	_expect(not bool(wimple["cracks_mail"]), "wimple does not crack mail")
	_expect(not bool(wimple["splits_hide"]), "wimple does not split hide")
	_expect(int(wimple["damage"]) < damage_max, "wimple is not the highest damage")
	_expect(int(wimple["damage"]) > lantern_damage, "wimple damage stays above the lantern")
	_expect(int(wimple["fire_ticks"]) > fastest, "wimple is not the fastest fire")
	_expect(int(wimple["fire_ticks"]) > int(tippet["fire_ticks"]), "wimple fires slower than the tippet")
	_expect(float(wimple["light_radius"]) == 368.0, "wimple radius is 368px")
	_expect(float(wimple["light_radius"]) > float(tippet["light_radius"]), "wimple radius is wider than the tippet")
	_expect(float(wimple["weapon_range"]) == 12.0, "wimple weapon range is 12px")
	_expect(float(wimple["projectile_speed"]) == 140.0, "wimple shot speed is 140px/s")
	_expect(float(wimple["projectile_speed"]) < float(tippet["projectile_speed"]), "wimple shot is slower than the tippet")
	_expect(int(wimple["fire_ticks"]) == 90, "wimple fires every 90 ticks")
	_expect(int(wimple["damage"]) == 2, "wimple damage is 2")
	_expect(float(wimple["splash_radius"]) == 0.0, "wimple has no splash")
	_expect(int(wimple["slow_ticks"]) == 0, "wimple has no slow")
	_expect(not bool(wimple["albs_rust"]), "wimple does not alb rust")
	_expect(str(wimple["role"]) == "Wimples mildew, modest shots, no light.", "wimple role text")
	var alb := Catalog.get_stats(Catalog.ALB)
	_expect(bool(alb["albs_rust"]), "alb albs rust")
	_expect(not bool(alb["casts_light"]), "alb is not a light")
	_expect(not bool(alb["wimples_mildew"]), "alb does not wimple mildew")
	_expect(not bool(alb["tippets_rot"]), "alb does not tippet rot")
	_expect(not bool(alb["mantles_blight"]), "alb does not mantle blight")
	_expect(not bool(alb["stoles_woe"]), "alb does not stole woe")
	_expect(not bool(alb["shawls_dread"]), "alb does not shawl dread")
	_expect(not bool(alb["capes_murk"]), "alb does not cape murk")
	_expect(not bool(alb["cloaks_gloom"]), "alb does not cloak gloom")
	_expect(not bool(alb["hoods_pall"]), "alb does not hood pall")
	_expect(not bool(alb["cowls_veil"]), "alb does not cowl veil")
	_expect(not bool(alb["shades_dusk"]), "alb does not shade dusk")
	_expect(not bool(alb["burns_shroud"]), "alb does not burn shroud")
	_expect(not bool(alb["cracks_rind"]), "alb does not crack rind")
	_expect(not bool(alb["melts_pitch"]), "alb does not melt pitch")
	_expect(not bool(alb["thaws_frost"]), "alb does not thaw frost")
	_expect(not bool(alb["cuts_web"]), "alb does not cut web")
	_expect(not bool(alb["cracks_glass"]), "alb does not crack glass")
	_expect(not bool(alb["strips_scale"]), "alb does not strip scale")
	_expect(not bool(alb["cracks_mail"]), "alb does not crack mail")
	_expect(not bool(alb["splits_hide"]), "alb does not split hide")
	_expect(int(alb["damage"]) < damage_max, "alb is not the highest damage")
	_expect(int(alb["damage"]) > lantern_damage, "alb damage stays above the lantern")
	_expect(int(alb["fire_ticks"]) > fastest, "alb is not the fastest fire")
	_expect(int(alb["fire_ticks"]) > int(wimple["fire_ticks"]), "alb fires slower than the wimple")
	_expect(float(alb["light_radius"]) == 384.0, "alb radius is 384px")
	_expect(float(alb["light_radius"]) > float(wimple["light_radius"]), "alb radius is wider than the wimple")
	_expect(float(alb["weapon_range"]) == 12.0, "alb weapon range is 12px")
	_expect(float(alb["projectile_speed"]) == 120.0, "alb shot speed is 120px/s")
	_expect(float(alb["projectile_speed"]) < float(wimple["projectile_speed"]), "alb shot is slower than the wimple")
	_expect(int(alb["fire_ticks"]) == 96, "alb fires every 96 ticks")
	_expect(int(alb["damage"]) == 2, "alb damage is 2")
	_expect(float(alb["splash_radius"]) == 0.0, "alb has no splash")
	_expect(int(alb["slow_ticks"]) == 0, "alb has no slow")
	_expect(not bool(alb["amices_scab"]), "alb does not amice scab")
	_expect(not bool(alb["orphreys_spot"]), "alb does not orphrey spot")
	_expect(str(alb["role"]) == "Albs rust, modest shots, no light.", "alb role text")
	var amice := Catalog.get_stats(Catalog.AMICE)
	_expect(bool(amice["amices_scab"]), "amice amices scab")
	_expect(not bool(amice["casts_light"]), "amice is not a light")
	_expect(not bool(amice["albs_rust"]), "amice does not alb rust")
	_expect(not bool(amice["wimples_mildew"]), "amice does not wimple mildew")
	_expect(not bool(amice["tippets_rot"]), "amice does not tippet rot")
	_expect(not bool(amice["mantles_blight"]), "amice does not mantle blight")
	_expect(not bool(amice["stoles_woe"]), "amice does not stole woe")
	_expect(not bool(amice["shawls_dread"]), "amice does not shawl dread")
	_expect(not bool(amice["capes_murk"]), "amice does not cape murk")
	_expect(not bool(amice["cloaks_gloom"]), "amice does not cloak gloom")
	_expect(not bool(amice["hoods_pall"]), "amice does not hood pall")
	_expect(not bool(amice["cowls_veil"]), "amice does not cowl veil")
	_expect(not bool(amice["shades_dusk"]), "amice does not shade dusk")
	_expect(not bool(amice["burns_shroud"]), "amice does not burn shroud")
	_expect(not bool(amice["cracks_rind"]), "amice does not crack rind")
	_expect(not bool(amice["melts_pitch"]), "amice does not melt pitch")
	_expect(not bool(amice["thaws_frost"]), "amice does not thaw frost")
	_expect(not bool(amice["cuts_web"]), "amice does not cut web")
	_expect(not bool(amice["cracks_glass"]), "amice does not crack glass")
	_expect(not bool(amice["strips_scale"]), "amice does not strip scale")
	_expect(not bool(amice["cracks_mail"]), "amice does not crack mail")
	_expect(not bool(amice["splits_hide"]), "amice does not split hide")
	_expect(int(amice["damage"]) < damage_max, "amice is not the highest damage")
	_expect(int(amice["damage"]) > lantern_damage, "amice damage stays above the lantern")
	_expect(int(amice["fire_ticks"]) > fastest, "amice is not the fastest fire")
	_expect(int(amice["fire_ticks"]) > int(alb["fire_ticks"]), "amice fires slower than the alb")
	_expect(float(amice["light_radius"]) == 400.0, "amice radius is 400px")
	_expect(float(amice["light_radius"]) > float(alb["light_radius"]), "amice radius is wider than the alb")
	_expect(float(amice["weapon_range"]) == 12.0, "amice weapon range is 12px")
	_expect(float(amice["projectile_speed"]) == 100.0, "amice shot speed is 100px/s")
	_expect(float(amice["projectile_speed"]) < float(alb["projectile_speed"]), "amice shot is slower than the alb")
	_expect(int(amice["fire_ticks"]) == 102, "amice fires every 102 ticks")
	_expect(int(amice["damage"]) == 2, "amice damage is 2")
	_expect(float(amice["splash_radius"]) == 0.0, "amice has no splash")
	_expect(int(amice["slow_ticks"]) == 0, "amice has no slow")
	_expect(not bool(amice["orphreys_spot"]), "amice does not orphrey spot")
	_expect(str(amice["role"]) == "Amices scab, modest shots, no light.", "amice role text")
	var orphrey := Catalog.get_stats(Catalog.ORPHREY)
	_expect(bool(orphrey["orphreys_spot"]), "orphrey orphreys spot")
	_expect(not bool(orphrey["casts_light"]), "orphrey is not a light")
	_expect(not bool(orphrey["amices_scab"]), "orphrey does not amice scab")
	_expect(not bool(orphrey["albs_rust"]), "orphrey does not alb rust")
	_expect(not bool(orphrey["wimples_mildew"]), "orphrey does not wimple mildew")
	_expect(not bool(orphrey["tippets_rot"]), "orphrey does not tippet rot")
	_expect(not bool(orphrey["mantles_blight"]), "orphrey does not mantle blight")
	_expect(not bool(orphrey["stoles_woe"]), "orphrey does not stole woe")
	_expect(not bool(orphrey["shawls_dread"]), "orphrey does not shawl dread")
	_expect(not bool(orphrey["capes_murk"]), "orphrey does not cape murk")
	_expect(not bool(orphrey["cloaks_gloom"]), "orphrey does not cloak gloom")
	_expect(not bool(orphrey["hoods_pall"]), "orphrey does not hood pall")
	_expect(not bool(orphrey["cowls_veil"]), "orphrey does not cowl veil")
	_expect(not bool(orphrey["shades_dusk"]), "orphrey does not shade dusk")
	_expect(not bool(orphrey["burns_shroud"]), "orphrey does not burn shroud")
	_expect(not bool(orphrey["cracks_rind"]), "orphrey does not crack rind")
	_expect(not bool(orphrey["melts_pitch"]), "orphrey does not melt pitch")
	_expect(not bool(orphrey["thaws_frost"]), "orphrey does not thaw frost")
	_expect(not bool(orphrey["cuts_web"]), "orphrey does not cut web")
	_expect(not bool(orphrey["cracks_glass"]), "orphrey does not crack glass")
	_expect(not bool(orphrey["strips_scale"]), "orphrey does not strip scale")
	_expect(not bool(orphrey["cracks_mail"]), "orphrey does not crack mail")
	_expect(not bool(orphrey["splits_hide"]), "orphrey does not split hide")
	_expect(int(orphrey["damage"]) < damage_max, "orphrey is not the highest damage")
	_expect(int(orphrey["damage"]) > lantern_damage, "orphrey damage stays above the lantern")
	_expect(int(orphrey["fire_ticks"]) > fastest, "orphrey is not the fastest fire")
	_expect(int(orphrey["fire_ticks"]) > int(amice["fire_ticks"]), "orphrey fires slower than the amice")
	_expect(float(orphrey["light_radius"]) == 416.0, "orphrey radius is 416px")
	_expect(float(orphrey["light_radius"]) > float(amice["light_radius"]), "orphrey radius is wider than the amice")
	_expect(float(orphrey["weapon_range"]) == 12.0, "orphrey weapon range is 12px")
	_expect(float(orphrey["projectile_speed"]) == 80.0, "orphrey shot speed is 80px/s")
	_expect(float(orphrey["projectile_speed"]) < float(amice["projectile_speed"]), "orphrey shot is slower than the amice")
	_expect(int(orphrey["fire_ticks"]) == 108, "orphrey fires every 108 ticks")
	_expect(is_equal_approx(float(orphrey["fire_interval"]), 3.60), "orphrey fire interval is 3.60s")
	_expect(int(orphrey["damage"]) == 2, "orphrey damage is 2")
	_expect(float(orphrey["splash_radius"]) == 0.0, "orphrey has no splash")
	_expect(int(orphrey["slow_ticks"]) == 0, "orphrey has no slow")
	_expect(str(orphrey["role"]) == "Orphreys spot, modest shots, no light.", "orphrey role text")
	_expect(lantern_damage == 1, "lantern damage stays 1")
	for kind in Catalog.COUNT:
		_expect(int(Catalog.get_stats(kind)["damage"]) >= lantern_damage, "%s damage stays at or above the lantern" % str(Catalog.get_stats(kind)["name"]))
	for i in scores.size():
		for j in scores.size():
			if i == j:
				continue
			var better := 0
			var worse := 0
			var left: Array = _axis_scores(scores[i])
			var right: Array = _axis_scores(scores[j])
			for axis in left.size():
				if left[axis] > right[axis] + 0.001:
					better += 1
				elif right[axis] > left[axis] + 0.001:
					worse += 1
			var left_name := str(scores[i]["name"])
			var right_name := str(scores[j]["name"])
			_expect(not (better > 0 and worse == 0), "%s does not strictly dominate %s" % [left_name, right_name])


func _axis_scores(stats: Dictionary) -> Array:
	return [
		float(stats["damage"]),
		-float(stats["fire_ticks"]),
		float(stats["light_radius"]),
		float(stats["weapon_range"]),
		float(stats["splash_radius"]),
		1.0 if bool(stats["burns_shroud"]) else 0.0,
		1.0 if bool(stats["cracks_rind"]) else 0.0,
		1.0 if bool(stats["melts_pitch"]) else 0.0,
		1.0 if bool(stats["thaws_frost"]) else 0.0,
		1.0 if bool(stats["cuts_web"]) else 0.0,
		1.0 if bool(stats["cracks_glass"]) else 0.0,
		1.0 if bool(stats["strips_scale"]) else 0.0,
		1.0 if bool(stats["cracks_mail"]) else 0.0,
		1.0 if bool(stats["splits_hide"]) else 0.0,
		1.0 if bool(stats["shades_dusk"]) else 0.0,
		1.0 if bool(stats["cowls_veil"]) else 0.0,
		1.0 if bool(stats["hoods_pall"]) else 0.0,
		1.0 if bool(stats["cloaks_gloom"]) else 0.0,
		1.0 if bool(stats["capes_murk"]) else 0.0,
		1.0 if bool(stats["shawls_dread"]) else 0.0,
		1.0 if bool(stats["stoles_woe"]) else 0.0,
		1.0 if bool(stats["mantles_blight"]) else 0.0,
		1.0 if bool(stats["tippets_rot"]) else 0.0,
		1.0 if bool(stats["wimples_mildew"]) else 0.0,
		1.0 if bool(stats["albs_rust"]) else 0.0,
		1.0 if bool(stats["amices_scab"]) else 0.0,
		1.0 if bool(stats["orphreys_spot"]) else 0.0,
		1.0 if int(stats["slow_ticks"]) > 0 else 0.0,
	]


func _test_scene_shows_tooltips() -> void:
	print("scene tooltip labels")
	var packed = load("res://scenes/main.tscn")
	_expect(packed != null, "main scene loads")
	if packed == null:
		return
	var node = packed.instantiate()
	_expect(node.get_script() != null, "main scene script compiled")
	if node.get_script() == null:
		return
	root.add_child(node)
	if not node.is_node_ready():
		node._ready()
	_expect(node.sim != null, "scene built its simulation")
	for kind in Catalog.COUNT:
		var live: PackedStringArray = node.tooltip_label_texts(kind)
		var expected := Tooltip.stat_lines(kind)
		var same: bool = live.size() == expected.size()
		if same:
			for i in live.size():
				if live[i] != expected[i]:
					same = false
		_expect(same, "on-screen tooltip matches catalog text for %s" % str(expected[0]))
	for _i in 10:
		node._process(0.05)
	_expect(node.sim.tick >= 10, "scene steps the fixed simulation (%s ticks)" % str(node.sim.tick))
	_expect(str(node.hint_label.text).find("wick") >= 0, "hint tells the player about the wick")
	_expect(str(node.hint_label.text).find("briar") >= 0, "hint tells the player about the briar")
	_expect(str(node.hint_label.text).find("flare") >= 0, "hint tells the player about the flare")
	_expect(str(node.hint_label.text).find("hearth") >= 0, "hint tells the player about the hearth")
	_expect(str(node.hint_label.text).find("shear") >= 0, "hint tells the player about the shear")
	_expect(str(node.hint_label.text).find("chime") >= 0, "hint tells the player about the chime")
	_expect(str(node.hint_label.text).find("rasp") >= 0, "hint tells the player about the rasp")
	_expect(str(node.hint_label.text).find("maul") >= 0, "hint tells the player about the maul")
	_expect(str(node.hint_label.text).find("bill") >= 0, "hint tells the player about the bill")
	_expect(str(node.hint_label.text).find("shade") >= 0, "hint tells the player about the shade")
	_expect(str(node.hint_label.text).find("cowl") >= 0, "hint tells the player about the cowl")
	var rasp_box: Node = node.plant_card_boxes[Catalog.RASP]
	_expect(str(rasp_box.get_node("Hotkey").text) == "B", "rasp hotkey is B")
	_expect(InputMap.has_action("plant_b"), "rasp has a letter action")
	var rasp_keys: Array = InputMap.action_get_events("plant_b")
	_expect(rasp_keys.size() == 1 and int(rasp_keys[0].keycode) == KEY_B, "rasp is bound to B, the next free letter")
	var maul_box: Node = node.plant_card_boxes[Catalog.MAUL]
	_expect(str(maul_box.get_node("Hotkey").text) == "C", "maul hotkey is C")
	_expect(InputMap.has_action("plant_c"), "maul has a letter action")
	var maul_keys: Array = InputMap.action_get_events("plant_c")
	_expect(maul_keys.size() == 1 and int(maul_keys[0].keycode) == KEY_C, "maul is bound to C, the next free letter")
	var bill_box: Node = node.plant_card_boxes[Catalog.BILL]
	_expect(str(bill_box.get_node("Hotkey").text) == "E", "bill hotkey is E")
	_expect(InputMap.has_action("plant_e"), "bill has a letter action")
	var bill_keys: Array = InputMap.action_get_events("plant_e")
	_expect(bill_keys.size() == 1 and int(bill_keys[0].keycode) == KEY_E, "bill is bound to E, the next free letter")
	var shade_box: Node = node.plant_card_boxes[Catalog.SHADE]
	_expect(str(shade_box.get_node("Hotkey").text) == "F", "shade hotkey is F")
	_expect(InputMap.has_action("plant_f"), "shade has a letter action")
	var shade_keys: Array = InputMap.action_get_events("plant_f")
	_expect(shade_keys.size() == 1 and int(shade_keys[0].keycode) == KEY_F, "shade is bound to F, the next free letter")
	var cowl_box: Node = node.plant_card_boxes[Catalog.COWL]
	_expect(str(cowl_box.get_node("Hotkey").text) == "G", "cowl hotkey is G")
	_expect(InputMap.has_action("plant_g"), "cowl has a letter action")
	var cowl_keys: Array = InputMap.action_get_events("plant_g")
	_expect(cowl_keys.size() == 1 and int(cowl_keys[0].keycode) == KEY_G, "cowl is bound to G, the next free letter")
	var hood_box: Node = node.plant_card_boxes[Catalog.HOOD]
	_expect(str(hood_box.get_node("Hotkey").text) == "H", "hood hotkey is H")
	_expect(InputMap.has_action("plant_h"), "hood has a letter action")
	var hood_keys: Array = InputMap.action_get_events("plant_h")
	_expect(hood_keys.size() == 1 and int(hood_keys[0].keycode) == KEY_H, "hood is bound to H, the next free letter")
	_expect(str(node.hint_label.text).find("hood") >= 0, "hint tells the player about the hood")
	var cloak_box: Node = node.plant_card_boxes[Catalog.CLOAK]
	_expect(str(cloak_box.get_node("Hotkey").text) == "I", "cloak hotkey is I")
	_expect(InputMap.has_action("plant_i"), "cloak has a letter action")
	var cloak_keys: Array = InputMap.action_get_events("plant_i")
	_expect(cloak_keys.size() == 1 and int(cloak_keys[0].keycode) == KEY_I, "cloak is bound to I, the next free letter")
	_expect(str(node.hint_label.text).find("cloak") >= 0, "hint tells the player about the cloak")
	var cape_box: Node = node.plant_card_boxes[Catalog.CAPE]
	_expect(str(cape_box.get_node("Hotkey").text) == "J", "cape hotkey is J")
	_expect(InputMap.has_action("plant_j"), "cape has a letter action")
	var cape_keys: Array = InputMap.action_get_events("plant_j")
	_expect(cape_keys.size() == 1 and int(cape_keys[0].keycode) == KEY_J, "cape is bound to J, the next free letter")
	_expect(str(node.hint_label.text).find("cape") >= 0, "hint tells the player about the cape")
	var shawl_box: Node = node.plant_card_boxes[Catalog.SHAWL]
	_expect(str(shawl_box.get_node("Hotkey").text) == "K", "shawl hotkey is K")
	_expect(InputMap.has_action("plant_k"), "shawl has a letter action")
	var shawl_keys: Array = InputMap.action_get_events("plant_k")
	_expect(shawl_keys.size() == 1 and int(shawl_keys[0].keycode) == KEY_K, "shawl is bound to K, the next free letter")
	_expect(str(node.hint_label.text).find("shawl") >= 0, "hint tells the player about the shawl")
	var stole_box: Node = node.plant_card_boxes[Catalog.STOLE]
	_expect(str(stole_box.get_node("Hotkey").text) == "L", "stole hotkey is L")
	_expect(InputMap.has_action("plant_l"), "stole has a letter action")
	var stole_keys: Array = InputMap.action_get_events("plant_l")
	_expect(stole_keys.size() == 1 and int(stole_keys[0].keycode) == KEY_L, "stole is bound to L, the next free letter")
	_expect(str(node.hint_label.text).find("stole") >= 0, "hint tells the player about the stole")
	var mantle_box: Node = node.plant_card_boxes[Catalog.MANTLE]
	_expect(str(mantle_box.get_node("Hotkey").text) == "M", "mantle hotkey is M")
	_expect(InputMap.has_action("plant_m"), "mantle has a letter action")
	var mantle_keys: Array = InputMap.action_get_events("plant_m")
	_expect(mantle_keys.size() == 1 and int(mantle_keys[0].keycode) == KEY_M, "mantle is bound to M")
	_expect(str(node.hint_label.text).find("mantle") >= 0, "hint tells the player about the mantle")
	var tippet_box: Node = node.plant_card_boxes[Catalog.TIPPET]
	_expect(str(tippet_box.get_node("Hotkey").text) == "N", "tippet hotkey is N")
	_expect(InputMap.has_action("plant_n"), "tippet has a letter action")
	var tippet_keys: Array = InputMap.action_get_events("plant_n")
	_expect(tippet_keys.size() == 1 and int(tippet_keys[0].keycode) == KEY_N, "tippet is bound to N, the next free letter")
	_expect(str(node.hint_label.text).find("tippet") >= 0, "hint tells the player about the tippet")
	var wimple_box: Node = node.plant_card_boxes[Catalog.WIMPLE]
	_expect(str(wimple_box.get_node("Hotkey").text) == "O", "wimple hotkey is O")
	_expect(InputMap.has_action("plant_o"), "wimple has a letter action")
	var wimple_keys: Array = InputMap.action_get_events("plant_o")
	_expect(wimple_keys.size() == 1 and int(wimple_keys[0].keycode) == KEY_O, "wimple is bound to O, the next free letter")
	_expect(str(node.hint_label.text).find("wimple") >= 0, "hint tells the player about the wimple")
	var alb_box: Node = node.plant_card_boxes[Catalog.ALB]
	_expect(str(alb_box.get_node("Hotkey").text) == "P", "alb hotkey is P")
	_expect(InputMap.has_action("plant_p"), "alb has a letter action")
	var alb_keys: Array = InputMap.action_get_events("plant_p")
	_expect(alb_keys.size() == 1 and int(alb_keys[0].keycode) == KEY_P, "alb is bound to P, the next free letter")
	_expect(str(node.hint_label.text).find("alb") >= 0, "hint tells the player about the alb")
	var amice_box: Node = node.plant_card_boxes[Catalog.AMICE]
	_expect(str(amice_box.get_node("Hotkey").text) == "Q", "amice hotkey is Q")
	_expect(InputMap.has_action("plant_q"), "amice has a letter action")
	var amice_keys: Array = InputMap.action_get_events("plant_q")
	_expect(amice_keys.size() == 1 and int(amice_keys[0].keycode) == KEY_Q, "amice is bound to Q, the next free letter")
	_expect(str(node.hint_label.text).find("amice") >= 0, "hint tells the player about the amice")
	var orphrey_box: Node = node.plant_card_boxes[Catalog.ORPHREY]
	_expect(str(orphrey_box.get_node("Hotkey").text) == "T", "orphrey hotkey is T")
	_expect(InputMap.has_action("plant_t"), "orphrey has a letter action")
	var orphrey_keys: Array = InputMap.action_get_events("plant_t")
	_expect(orphrey_keys.size() == 1 and int(orphrey_keys[0].keycode) == KEY_T, "orphrey is bound to T, the next free letter")
	_expect(str(node.hint_label.text).find("orphrey") >= 0, "hint tells the player about the orphrey")
	var orphrey_lines: PackedStringArray = node.tooltip_label_texts(Catalog.ORPHREY)
	_expect(str(orphrey_lines[3]) == "Fire: 3.60s", "orphrey card shows the 3.60s interval (%s)" % str(orphrey_lines[3]))
	_expect(str(orphrey_lines[4]) == "Orphrey: 416px", "orphrey card shows the 416px radius (%s)" % str(orphrey_lines[4]))
	_expect(str(orphrey_lines[28]) == "Spot: orphreys", "orphrey card shows the spot seal (%s)" % str(orphrey_lines[28]))
	for action in ["move_left", "move_right", "move_up", "move_down", "restart"]:
		for ev in InputMap.action_get_events(action):
			_expect(int(ev.keycode) != KEY_K, "K is not bound to %s" % action)
			_expect(int(ev.keycode) != KEY_L, "L is not bound to %s" % action)
			_expect(int(ev.keycode) != KEY_M, "M is not bound to %s" % action)
			_expect(int(ev.keycode) != KEY_N, "N is not bound to %s" % action)
			_expect(int(ev.keycode) != KEY_O, "O is not bound to %s" % action)
			_expect(int(ev.keycode) != KEY_P, "P is not bound to %s" % action)
			_expect(int(ev.keycode) != KEY_Q, "Q is not bound to %s" % action)
			_expect(int(ev.keycode) != KEY_T, "T is not bound to %s" % action)
	node.sim.outcome = Sim.OUTCOME_WON
	node.sim.wave = 37
	node._refresh_hud()
	_expect(str(node.outcome_label.text).find("Forty-seven nights") >= 0, "win copy counts forty-seven nights: %s" % node.outcome_label.text)
	_scene_node = node


func _test_card_layout() -> void:
	print("plant cards fit the window")
	if _scene_node == null:
		_expect(false, "scene node survived until layout")
		return
	var node = _scene_node
	for kind in Catalog.COUNT:
		var panel: Control = node.card_panels[kind]
		var box: Control = node.plant_card_boxes[kind]
		var min_size: Vector2 = box.get_combined_minimum_size()
		var bottom := panel.position.y + panel.size.y
		var right := panel.position.x + panel.size.x
		var clipped := false
		for child in box.get_children():
			if child is Label and int((child as Label).get_line_count()) > 1:
				clipped = true
		_expect(min_size.y <= panel.size.y + 1.0, "card %d content height %.1f fits %.1f" % [kind, min_size.y, panel.size.y])
		_expect(min_size.x <= panel.size.x + 1.0, "card %d content width %.1f fits %.1f" % [kind, min_size.x, panel.size.x])
		_expect(not clipped, "card %d keeps each tooltip line on one row" % kind)
		var last_line: Label = null
		for child in box.get_children():
			if child is Label and str(child.name).begins_with("Stat"):
				last_line = child
		var line_inside := last_line != null and panel.get_global_rect().encloses(last_line.get_global_rect())
		_expect(line_inside, "card %d last tooltip line stays inside the card" % kind)
		_expect(bottom <= 9070.0, "card %d stays on screen (bottom %.1f)" % [kind, bottom])
		_expect(right <= 1112.0, "card %d stays on screen (right %.1f)" % [kind, right])
	var cowl_panel: Control = node.card_panels[Catalog.COWL]
	var hood_panel: Control = node.card_panels[Catalog.HOOD]
	var cloak_panel: Control = node.card_panels[Catalog.CLOAK]
	var cape_panel: Control = node.card_panels[Catalog.CAPE]
	_expect(is_equal_approx(cowl_panel.position.y + cowl_panel.size.y, 5256.0), "cowl card still ends at y 5256 (%.1f)" % (cowl_panel.position.y + cowl_panel.size.y))
	_expect(is_equal_approx(hood_panel.position.y, 5262.0), "hood card still starts at y 5262 (%.1f)" % hood_panel.position.y)
	_expect(is_equal_approx(hood_panel.position.y + hood_panel.size.y, 5602.0), "hood card still ends at y 5602 (%.1f)" % (hood_panel.position.y + hood_panel.size.y))
	_expect(is_equal_approx(cloak_panel.position.y, 5608.0), "cloak card still starts at y 5608 (%.1f)" % cloak_panel.position.y)
	_expect(is_equal_approx(cloak_panel.position.y + cloak_panel.size.y, 5948.0), "cloak card still ends at y 5948 (%.1f)" % (cloak_panel.position.y + cloak_panel.size.y))
	_expect(is_equal_approx(cape_panel.position.y, 5954.0), "cape card starts at y 5954 (%.1f)" % cape_panel.position.y)
	_expect(is_equal_approx(cape_panel.position.y + cape_panel.size.y, 6294.0), "cape card ends at y 6294 (%.1f)" % (cape_panel.position.y + cape_panel.size.y))
	var shawl_panel: Control = node.card_panels[Catalog.SHAWL]
	_expect(is_equal_approx(shawl_panel.position.y, 6294.0), "shawl card starts at y 6294 (%.1f)" % shawl_panel.position.y)
	_expect(is_equal_approx(shawl_panel.size.y, 340.0), "CARD_H stays 340 (%.1f)" % shawl_panel.size.y)
	_expect(is_equal_approx(shawl_panel.position.y + shawl_panel.size.y, 6634.0), "shawl card ends at y 6634 (%.1f)" % (shawl_panel.position.y + shawl_panel.size.y))
	var stole_panel: Control = node.card_panels[Catalog.STOLE]
	_expect(is_equal_approx(stole_panel.position.y, 6634.0), "stole card starts at y 6634 (%.1f)" % stole_panel.position.y)
	_expect(is_equal_approx(stole_panel.size.y, 340.0), "stole card keeps CARD_H at 340 (%.1f)" % stole_panel.size.y)
	_expect(is_equal_approx(stole_panel.position.y + stole_panel.size.y, 6974.0), "stole card ends at y 6974 (%.1f)" % (stole_panel.position.y + stole_panel.size.y))
	var mantle_panel: Control = node.card_panels[Catalog.MANTLE]
	_expect(is_equal_approx(mantle_panel.position.y, 6974.0), "mantle card starts at y 6974 (%.1f)" % mantle_panel.position.y)
	_expect(is_equal_approx(mantle_panel.size.y, 340.0), "mantle card keeps CARD_H at 340 (%.1f)" % mantle_panel.size.y)
	_expect(is_equal_approx(mantle_panel.position.y + mantle_panel.size.y, 7314.0), "mantle card ends at y 7314 (%.1f)" % (mantle_panel.position.y + mantle_panel.size.y))
	var tippet_panel: Control = node.card_panels[Catalog.TIPPET]
	_expect(is_equal_approx(tippet_panel.position.y, 7314.0), "tippet card starts at y 7314 (%.1f)" % tippet_panel.position.y)
	_expect(is_equal_approx(tippet_panel.size.y, 340.0), "tippet card keeps CARD_H at 340 (%.1f)" % tippet_panel.size.y)
	_expect(is_equal_approx(tippet_panel.position.y + tippet_panel.size.y, 7654.0), "tippet card ends at y 7654 (%.1f)" % (tippet_panel.position.y + tippet_panel.size.y))
	var wimple_panel: Control = node.card_panels[Catalog.WIMPLE]
	_expect(is_equal_approx(wimple_panel.position.y, 7654.0), "wimple card starts at y 7654 (%.1f)" % wimple_panel.position.y)
	_expect(is_equal_approx(wimple_panel.size.y, 340.0), "wimple card keeps CARD_H at 340 (%.1f)" % wimple_panel.size.y)
	_expect(is_equal_approx(wimple_panel.position.y + wimple_panel.size.y, 7994.0), "wimple card ends at y 7994 (%.1f)" % (wimple_panel.position.y + wimple_panel.size.y))
	var alb_panel: Control = node.card_panels[Catalog.ALB]
	_expect(is_equal_approx(alb_panel.position.y, 7994.0), "alb card starts at y 7994 (%.1f)" % alb_panel.position.y)
	_expect(is_equal_approx(alb_panel.size.y, 340.0), "alb card keeps CARD_H at 340 (%.1f)" % alb_panel.size.y)
	_expect(is_equal_approx(alb_panel.position.y + alb_panel.size.y, 8334.0), "alb card ends at y 8334 (%.1f)" % (alb_panel.position.y + alb_panel.size.y))
	var amice_panel: Control = node.card_panels[Catalog.AMICE]
	_expect(is_equal_approx(amice_panel.position.y, 8334.0), "amice card starts at y 8334 (%.1f)" % amice_panel.position.y)
	_expect(is_equal_approx(amice_panel.size.y, 340.0), "amice card keeps CARD_H at 340 (%.1f)" % amice_panel.size.y)
	_expect(is_equal_approx(amice_panel.position.y + amice_panel.size.y, 8674.0), "amice card ends at y 8674 (%.1f)" % (amice_panel.position.y + amice_panel.size.y))
	var orphrey_panel: Control = node.card_panels[Catalog.ORPHREY]
	_expect(is_equal_approx(orphrey_panel.position.y, 8674.0), "orphrey card starts at y 8674 (%.1f)" % orphrey_panel.position.y)
	_expect(is_equal_approx(orphrey_panel.size.y, 340.0), "orphrey card keeps CARD_H at 340 (%.1f)" % orphrey_panel.size.y)
	_expect(is_equal_approx(orphrey_panel.position.y + orphrey_panel.size.y, 9014.0), "orphrey card ends at y 9014 (%.1f)" % (orphrey_panel.position.y + orphrey_panel.size.y))
	_expect(is_equal_approx(orphrey_panel.position.y, amice_panel.position.y + amice_panel.size.y), "orphrey card starts where the amice card ends")
	_expect(is_equal_approx(node.get_viewport_rect().size.y - (orphrey_panel.position.y + orphrey_panel.size.y), 66.0), "gap under the orphrey card is the same 66px spare")
	var shawl_stat: Label = node.plant_card_boxes[Catalog.SHAWL].get_node("Stat2")
	_expect(int(shawl_stat.get_theme_font_size("font_size")) == 10, "stat lines stay 10px")
	_expect(is_equal_approx(node.get_viewport_rect().size.y, 9080.0), "window height is 9080 (%.1f)" % node.get_viewport_rect().size.y)
	_expect(int(ProjectSettings.get_setting("display/window/size/viewport_width")) == 1120, "window width is 1120")
	_expect(int(ProjectSettings.get_setting("display/window/size/viewport_height")) == 9080, "window height setting is 9080")
	var hint_end: float = _scene_node.hint_label.get_global_rect().end.x
	_expect(hint_end <= 748.0, "hint ends before the plant cards (%.1f)" % hint_end)
	_expect(_scene_node.hint_label.get_line_count() <= 5, "hint fits in %d line(s)" % _scene_node.hint_label.get_line_count())
