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
	var tiles := [Vector2i(2, 2), Vector2i(4, 2), Vector2i(6, 2), Vector2i(8, 2), Vector2i(10, 2)]
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
		_expect(sim.seeds == Sim.START_SEEDS - 2, "seed %s spent only those two seeds" % run_seed)


func _garden_command(sim, wick_tile: Vector2i):
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
	return cmd


func _wick_command(sim):
	return _garden_command(sim, Vector2i(6, 5))


func _corner_wick_command(sim):
	return _garden_command(sim, Vector2i(1, 1))


# [outcome, wave, phase, tick, hp, shots, shrouds_spawned, shrouds_killed, seeds, plants]
func _play(seed: int, planner: Callable) -> Array:
	var sim = Sim.new(seed)
	var guard := 0
	while sim.outcome == Sim.OUTCOME_RUNNING and guard < 30000:
		sim.step(planner.call(sim))
		guard += 1
	return [sim.outcome, sim.wave, sim.phase, sim.tick, sim.player_hp, sim.shots_fired, sim.shrouds_spawned, sim.shrouds_killed, sim.seeds, sim.plants.size()]


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
	_expect(Sim.WAVE_COUNT == 5, "five nights")
	_expect(int(Sim.WAVES[0]["count"]) == 8 and int(Sim.WAVES[0]["interval"]) == 72 and int(Sim.WAVES[0]["shroud_every"]) == 0, "night 1 is the original wave")
	_expect(int(Sim.WAVES[1]["count"]) == 12 and int(Sim.WAVES[1]["interval"]) == 66 and int(Sim.WAVES[1]["shroud_every"]) == 0, "night 2 is the original wave")
	_expect(int(Sim.WAVES[2]["count"]) == 22 and int(Sim.WAVES[2]["interval"]) == 60 and int(Sim.WAVES[2]["shroud_every"]) == 0, "night 3 is the original wave")
	_expect(int(Sim.WAVES[3]["count"]) == 8 and int(Sim.WAVES[3]["interval"]) == 78 and int(Sim.WAVES[3]["shroud_every"]) == 1 and str(Sim.WAVES[3]["name"]) == "Shroud", "night 4 is all shroud")
	_expect(int(Sim.WAVES[4]["count"]) == 16 and int(Sim.WAVES[4]["interval"]) == 54 and int(Sim.WAVES[4]["shroud_every"]) == 2 and str(Sim.WAVES[4]["name"]) == "Ash", "night 5 alternates shroud")
	var named = Sim.new(1)
	named.wave = 4
	named.phase = Sim.PHASE_WAVE
	_expect(named.phase_text() == "Night 4 of 5 (Shroud) — 0 pests left", "night 4 heading: %s" % named.phase_text())
	named.wave = 5
	_expect(named.phase_text() == "Night 5 of 5 (Ash) — 0 pests left", "night 5 heading: %s" % named.phase_text())
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
		var held := _play(run_seed, Callable(self, "_wick_command"))
		print("  wick seed=%s outcome=%s night=%s hp=%s tick=%s spawned=%s killed=%s" % [run_seed, held[0], held[1], held[4], held[3], held[6], held[7]])
		_expect(int(held[0]) == Sim.OUTCOME_WON, "seed %s survives with wick light on the gardener" % run_seed)
		_expect(int(held[1]) == 5, "seed %s win is night 5" % run_seed)
		_expect(int(held[4]) > 0, "seed %s finished with health %s" % [run_seed, held[4]])
		_expect(int(held[6]) == 16 and int(held[7]) == 16, "seed %s burned every shroud moth (%s/%s)" % [run_seed, held[7], held[6]])
		_expect(int(held[8]) == Sim.START_SEEDS - 3, "seed %s spent lantern, pea, and wick" % run_seed)
	var again := _play(42, Callable(self, "_wick_command"))
	var replay := _play(42, Callable(self, "_wick_command"))
	_expect(str(again) == str(replay), "same seed and wick plan replay")


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
	var scores: Array = []
	for kind in Catalog.COUNT:
		var stats := Catalog.get_stats(kind)
		if bool(stats["burns_shroud"]):
			burners += 1
		scores.append(stats)
	_expect(burners == 1, "only one plant burns shroud")
	var wick := Catalog.get_stats(Catalog.WICK)
	_expect(bool(wick["burns_shroud"]), "wick burns shroud")
	_expect(int(wick["damage"]) < damage_max, "wick is not the highest damage")
	_expect(float(wick["light_radius"]) < radius_max, "wick is not the largest light")
	_expect(int(wick["fire_ticks"]) > fastest, "wick is not the fastest fire")
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
	node.sim.outcome = Sim.OUTCOME_WON
	node.sim.wave = 5
	node._refresh_hud()
	_expect(str(node.outcome_label.text).find("Five nights") >= 0, "win copy counts five nights: %s" % node.outcome_label.text)
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
		_expect(bottom <= 990.0, "card %d stays on screen (bottom %.1f)" % [kind, bottom])
		_expect(right <= 1112.0, "card %d stays on screen (right %.1f)" % [kind, right])
	var hint_end: float = _scene_node.hint_label.get_global_rect().end.x
	_expect(hint_end <= 748.0, "hint ends before the plant cards (%.1f)" % hint_end)
	_expect(_scene_node.hint_label.get_line_count() <= 3, "hint fits in %d line(s)" % _scene_node.hint_label.get_line_count())
