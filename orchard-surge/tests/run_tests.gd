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
	var tiles := [Vector2i(2, 2), Vector2i(4, 2), Vector2i(6, 2), Vector2i(8, 2), Vector2i(10, 2), Vector2i(12, 2), Vector2i(12, 4), Vector2i(10, 4), Vector2i(8, 4)]
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
		_expect(sim.seeds == Sim.START_SEEDS - 2, "seed %s spent only those two seeds" % run_seed)


func _garden_command(sim, wick_tile: Vector2i, briar_tile: Vector2i = Vector2i(-1, -1), flare_tile: Vector2i = Vector2i(-1, -1), hearth_tile: Vector2i = Vector2i(-1, -1), shear_tile: Vector2i = Vector2i(-1, -1)):
	var cmd = Sim.Command.new()
	if sim.outcome != Sim.OUTCOME_RUNNING or sim.phase != Sim.PHASE_PLANT or sim.seeds <= 0:
		return cmd
	if not sim.has_plant(Catalog.LANTERN):
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


# [outcome, wave, phase, tick, hp, shots, shrouds_spawned, shrouds_killed, seeds, plants, rinds_spawned, rinds_killed, pitches_spawned, pitches_killed, frosts_spawned, frosts_killed, webs_spawned, webs_killed]
func _play(seed: int, planner: Callable, stop_after_night: int = -1) -> Array:
	var sim = Sim.new(seed)
	var guard := 0
	while sim.outcome == Sim.OUTCOME_RUNNING and guard < 60000:
		if stop_after_night > 0 and sim.wave == stop_after_night and sim.phase == Sim.PHASE_PLANT and sim.phase_ticks == 0:
			break
		sim.step(planner.call(sim))
		guard += 1
	return [sim.outcome, sim.wave, sim.phase, sim.tick, sim.player_hp, sim.shots_fired, sim.shrouds_spawned, sim.shrouds_killed, sim.seeds, sim.plants.size(), sim.rinds_spawned, sim.rinds_killed, sim.pitches_spawned, sim.pitches_killed, sim.frosts_spawned, sim.frosts_killed, sim.webs_spawned, sim.webs_killed]


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
	_expect(Sim.WAVE_COUNT == 13, "thirteen nights")
	_expect(int(Sim.WAVES[0]["count"]) == 8 and int(Sim.WAVES[0]["interval"]) == 72 and int(Sim.WAVES[0]["shroud_every"]) == 0 and int(Sim.WAVES[0]["rind_every"]) == 0 and int(Sim.WAVES[0]["pitch_every"]) == 0, "night 1 is the original wave")
	_expect(int(Sim.WAVES[1]["count"]) == 12 and int(Sim.WAVES[1]["interval"]) == 66 and int(Sim.WAVES[1]["shroud_every"]) == 0 and int(Sim.WAVES[1]["rind_every"]) == 0 and int(Sim.WAVES[1]["pitch_every"]) == 0, "night 2 is the original wave")
	_expect(int(Sim.WAVES[2]["count"]) == 22 and int(Sim.WAVES[2]["interval"]) == 60 and int(Sim.WAVES[2]["shroud_every"]) == 0 and int(Sim.WAVES[2]["rind_every"]) == 0 and int(Sim.WAVES[2]["pitch_every"]) == 0, "night 3 is the original wave")
	_expect(int(Sim.WAVES[3]["count"]) == 8 and int(Sim.WAVES[3]["interval"]) == 78 and int(Sim.WAVES[3]["shroud_every"]) == 1 and int(Sim.WAVES[3]["rind_every"]) == 0 and int(Sim.WAVES[3]["pitch_every"]) == 0 and str(Sim.WAVES[3]["name"]) == "Shroud", "night 4 is all shroud")
	_expect(int(Sim.WAVES[4]["count"]) == 16 and int(Sim.WAVES[4]["interval"]) == 54 and int(Sim.WAVES[4]["shroud_every"]) == 2 and int(Sim.WAVES[4]["rind_every"]) == 0 and int(Sim.WAVES[4]["pitch_every"]) == 0 and str(Sim.WAVES[4]["name"]) == "Ash", "night 5 alternates shroud")
	var named = Sim.new(1)
	named.wave = 4
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 4 of 13 (Shroud) — 0 pests left", "night 4 heading: %s" % named.phase_text())
	named.wave = 5
	_expect(named.phase_text() == "Night 5 of 13 (Ash) — 0 pests left", "night 5 heading: %s" % named.phase_text())
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
	_expect(named.phase_text() == "Night 6 of 13 (Rind) — 0 pests left", "night 6 heading: %s" % named.phase_text())
	named.wave = 7
	_expect(named.phase_text() == "Night 7 of 13 (Gall) — 0 pests left", "night 7 heading: %s" % named.phase_text())
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
	_expect(named.phase_text() == "Night 8 of 13 (Pitch) — 0 pests left", "night 8 heading: %s" % named.phase_text())
	named.wave = 9
	_expect(named.phase_text() == "Night 9 of 13 (Tar) — 0 pests left", "night 9 heading: %s" % named.phase_text())
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
	_expect(Sim.WAVES.size() == 13 and Sim.WAVE_COUNT == 13, "thirteen nights")
	for i in nights.size():
		var spec: Dictionary = Sim.WAVES[i]
		var want: Array = nights[i]
		var same := int(spec["count"]) == int(want[0]) and int(spec["interval"]) == int(want[1])
		same = same and int(spec["shroud_every"]) == int(want[2]) and int(spec["rind_every"]) == int(want[3])
		same = same and int(spec["pitch_every"]) == int(want[4]) and int(spec["frost_every"]) == int(want[5])
		same = same and str(spec["name"]) == str(want[6])
		same = same and int(spec["web_every"]) == 0
		_expect(same, "night %d stays on the eleven-night table" % (i + 1))
	var named = Sim.new(1)
	named.wave = 10
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 10 of 13 (Frost) — 0 pests left", "night 10 heading: %s" % named.phase_text())
	named.wave = 11
	_expect(named.phase_text() == "Night 11 of 13 (Rime) — 0 pests left", "night 11 heading: %s" % named.phase_text())
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
	_expect(int(Sim.WAVES[11]["count"]) == 10 and int(Sim.WAVES[11]["interval"]) == 72 and int(Sim.WAVES[11]["shroud_every"]) == 0 and int(Sim.WAVES[11]["rind_every"]) == 0 and int(Sim.WAVES[11]["pitch_every"]) == 0 and int(Sim.WAVES[11]["frost_every"]) == 0 and int(Sim.WAVES[11]["web_every"]) == 1 and str(Sim.WAVES[11]["name"]) == "Web", "night 12 is all web")
	_expect(int(Sim.WAVES[12]["count"]) == 16 and int(Sim.WAVES[12]["interval"]) == 60 and int(Sim.WAVES[12]["shroud_every"]) == 2 and int(Sim.WAVES[12]["rind_every"]) == 1 and int(Sim.WAVES[12]["pitch_every"]) == 1 and int(Sim.WAVES[12]["frost_every"]) == 1 and int(Sim.WAVES[12]["web_every"]) == 1 and str(Sim.WAVES[12]["name"]) == "Snare", "night 13 is web, frost, pitch, and rind, every second also a shroud")
	var named = Sim.new(1)
	named.wave = 12
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 12 of 13 (Web) — 0 pests left", "night 12 heading: %s" % named.phase_text())
	named.wave = 13
	_expect(named.phase_text() == "Night 13 of 13 (Snare) — 0 pests left", "night 13 heading: %s" % named.phase_text())
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
		var held := _play(run_seed, Callable(self, "_shear_command"))
		print("  shear seed=%s outcome=%s night=%s hp=%s tick=%s shrouds=%s/%s rinds=%s/%s pitches=%s/%s frosts=%s/%s webs=%s/%s" % [run_seed, held[0], held[1], held[4], held[3], held[7], held[6], held[11], held[10], held[13], held[12], held[15], held[14], held[17], held[16]])
		_expect(int(held[0]) == Sim.OUTCOME_WON, "seed %s clears all thirteen nights with the shear beside the gardener" % run_seed)
		_expect(int(held[1]) == 13, "seed %s win is night 13" % run_seed)
		_expect(int(held[4]) > 0, "seed %s finished with health %s" % [run_seed, held[4]])
		_expect(int(held[6]) == 48 and int(held[7]) == 48, "seed %s burned every shroud moth (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[10]) == 74 and int(held[11]) == 74, "seed %s cracked every rind moth (%s/%s)" % [run_seed, held[11], held[10]])
		_expect(int(held[12]) == 58 and int(held[13]) == 58, "seed %s melted every pitch moth (%s/%s)" % [run_seed, held[13], held[12]])
		_expect(int(held[14]) == 42 and int(held[15]) == 42, "seed %s thawed every frost moth (%s/%s)" % [run_seed, held[15], held[14]])
		_expect(int(held[16]) == 26 and int(held[17]) == 26, "seed %s cut every web moth (%s/%s)" % [run_seed, held[17], held[16]])
		_expect(int(held[8]) == Sim.START_SEEDS - 7 and int(held[9]) == 7, "seed %s spent lantern, pea, wick, briar, flare, hearth, and shear" % run_seed)
	var again := _play(42, Callable(self, "_shear_command"))
	var replay := _play(42, Callable(self, "_shear_command"))
	_expect(str(again) == str(replay), "same seed and shear plan replay")


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
		_expect(specials <= 1, "%s keeps a single light rule" % stats["name"])
		scores.append(stats)
	_expect(burners == 1, "only one plant burns shroud")
	_expect(crackers == 1, "only one plant cracks rind")
	_expect(melters == 1, "only one plant melts pitch")
	_expect(thawers == 1, "only one plant thaws frost")
	_expect(cutters == 1, "only one plant cuts web")
	var wick := Catalog.get_stats(Catalog.WICK)
	_expect(bool(wick["burns_shroud"]), "wick burns shroud")
	_expect(not bool(wick["cracks_rind"]), "wick does not crack rind")
	_expect(not bool(wick["melts_pitch"]), "wick does not melt pitch")
	_expect(not bool(wick["thaws_frost"]), "wick does not thaw frost")
	_expect(not bool(wick["cuts_web"]), "wick does not cut web")
	_expect(int(wick["damage"]) < damage_max, "wick is not the highest damage")
	_expect(float(wick["light_radius"]) < radius_max, "wick is not the largest light")
	_expect(int(wick["fire_ticks"]) > fastest, "wick is not the fastest fire")
	var briar := Catalog.get_stats(Catalog.BRIAR)
	_expect(bool(briar["cracks_rind"]), "briar cracks rind")
	_expect(not bool(briar["burns_shroud"]), "briar does not burn shroud")
	_expect(not bool(briar["melts_pitch"]), "briar does not melt pitch")
	_expect(not bool(briar["thaws_frost"]), "briar does not thaw frost")
	_expect(not bool(briar["cuts_web"]), "briar does not cut web")
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
	var hearth := Catalog.get_stats(Catalog.HEARTH)
	_expect(bool(hearth["thaws_frost"]), "hearth thaws frost")
	_expect(not bool(hearth["burns_shroud"]), "hearth does not burn shroud")
	_expect(not bool(hearth["cracks_rind"]), "hearth does not crack rind")
	_expect(not bool(hearth["melts_pitch"]), "hearth does not melt pitch")
	_expect(int(hearth["damage"]) < damage_max, "hearth is not the highest damage")
	_expect(float(hearth["light_radius"]) < radius_max, "hearth is not the largest light")
	_expect(int(hearth["fire_ticks"]) > fastest, "hearth is not the fastest fire")
	_expect(not bool(hearth["cuts_web"]), "hearth does not cut web")
	var shear := Catalog.get_stats(Catalog.SHEAR)
	_expect(bool(shear["cuts_web"]), "shear cuts web")
	_expect(not bool(shear["burns_shroud"]), "shear does not burn shroud")
	_expect(not bool(shear["cracks_rind"]), "shear does not crack rind")
	_expect(not bool(shear["melts_pitch"]), "shear does not melt pitch")
	_expect(not bool(shear["thaws_frost"]), "shear does not thaw frost")
	_expect(int(shear["damage"]) < damage_max, "shear is not the highest damage")
	_expect(float(shear["light_radius"]) < radius_max, "shear is not the largest light")
	_expect(int(shear["fire_ticks"]) > fastest, "shear is not the fastest fire")
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
	node.sim.outcome = Sim.OUTCOME_WON
	node.sim.wave = 13
	node._refresh_hud()
	_expect(str(node.outcome_label.text).find("Thirteen nights") >= 0, "win copy counts thirteen nights: %s" % node.outcome_label.text)
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
		_expect(bottom <= 2690.0, "card %d stays on screen (bottom %.1f)" % [kind, bottom])
		_expect(right <= 1112.0, "card %d stays on screen (right %.1f)" % [kind, right])
	var hint_end: float = _scene_node.hint_label.get_global_rect().end.x
	_expect(hint_end <= 748.0, "hint ends before the plant cards (%.1f)" % hint_end)
	_expect(_scene_node.hint_label.get_line_count() <= 3, "hint fits in %d line(s)" % _scene_node.hint_label.get_line_count())
