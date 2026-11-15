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
	_test_fog_visibility()
	_test_no_dominance()
	_test_scene_shows_tooltips()
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
	var tiles := [Vector2i(2, 2), Vector2i(4, 2), Vector2i(6, 2), Vector2i(8, 2)]
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
	print("  stationary outcome=%s wave=%s hp=%s tick=%s" % [sim.outcome, sim.wave, sim.player_hp, sim.tick])
	_expect(sim.seeds == Sim.START_SEEDS, "stationary bot planted nothing")
	_expect(sim.outcome == Sim.OUTCOME_LOST, "stationary bot died")
	_expect(sim.player_hp == 0, "health reached zero")
	_expect(sim.wave < 3, "died before wave 3 (wave %s)" % str(sim.wave))


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


func _test_scripted_survives() -> void:
	print("scripted lantern + pea bot on seed 42")
	var sim = Sim.new(42)
	var guard := 0
	while sim.outcome == Sim.OUTCOME_RUNNING and guard < 30000:
		sim.step(_survival_command(sim))
		guard += 1
	print("  survival outcome=%s wave=%s hp=%s tick=%s seeds=%s plants=%s" % [sim.outcome, sim.wave, sim.player_hp, sim.tick, sim.seeds, sim.plants.size()])
	_expect(sim.has_plant(Catalog.LANTERN), "bot planted a lantern through the sim API")
	_expect(sim.has_plant(Catalog.PEA), "bot planted a pea through the sim API")
	_expect(sim.seeds == Sim.START_SEEDS - 2, "bot spent only those two seeds")
	_expect(sim.outcome == Sim.OUTCOME_WON, "bot survived all 3 waves")
	_expect(sim.wave == 3, "win is recorded on wave 3")
	for extra_seed in [1, 7, 99, 256, 2026]:
		var extra = Sim.new(extra_seed)
		var extra_guard := 0
		while extra.outcome == Sim.OUTCOME_RUNNING and extra_guard < 30000:
			extra.step(_survival_command(extra))
			extra_guard += 1
		_expect(extra.outcome == Sim.OUTCOME_WON, "same bot clears seed %s (outcome=%s wave=%s hp=%s)" % [extra_seed, extra.outcome, extra.wave, extra.player_hp])


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
	node.queue_free()
