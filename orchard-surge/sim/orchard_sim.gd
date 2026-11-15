extends RefCounted

## Fixed-timestep orchard combat. No SceneTree, no drawing, no input devices.
## Given the same seed and the same command each tick, the run is deterministic.
## The scene only reads this state and sends commands.
## Shroud moths stay hidden in ordinary light and ignore shots until a wick burns their tile.
## Rind moths stay hidden until a briar cracks their tile.
## Pitch moths stay hidden until a flare melts their tile.
## Frost moths stay hidden until a hearth thaws their tile.
## Web moths stay hidden until a shear cuts their tile. A moth can carry more than one lock.

const Catalog = preload("res://sim/plant_catalog.gd")

const DT := Catalog.DT
const MAP_W := 15
const MAP_H := 11
const TILE := 48.0

const PHASE_PLANT := 0
const PHASE_WAVE := 1
const OUTCOME_RUNNING := 0
const OUTCOME_WON := 1
const OUTCOME_LOST := 2

const PLAYER_HP := 100
const PLAYER_SPEED := 130.0
const PLAYER_RADIUS := 12.0
const CONTACT_DAMAGE := 20
const HURT_TICKS := 12
const PEST_HP := 12
const PEST_SPEED := 42.0
const PEST_RADIUS := 11.0
const START_SEEDS := 7
const PLANT_TICKS := 240
const WAVE_COUNT := 13
const START_CELL := Vector2i(7, 5)
const PROJECTILE_RADIUS := 4.0
const PROJECTILE_LIFE := 75

# Nights 1–3 are the original waves. Nights 4 and 5 bring shroud moths, not a boss.
# Nights 6 and 7 bring rind moths. Night 7 sends rind and shroud on the same moths.
# Nights 8 and 9 bring pitch moths. Night 9 sends pitch, rind, and shroud together.
# Nights 10 and 11 bring frost moths. Night 11 sends frost, pitch, rind, and shroud together.
# Nights 12 and 13 bring web moths. Night 13 sends web, frost, pitch, rind, and shroud together.
# shroud_every / rind_every / pitch_every / frost_every / web_every 0: none. 1: every spawn. N: every Nth spawn, the Nth included.
const WAVES := [
	{"count": 8, "interval": 72, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "name": ""},
	{"count": 12, "interval": 66, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "name": ""},
	{"count": 22, "interval": 60, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "name": ""},
	{"count": 8, "interval": 78, "shroud_every": 1, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "name": "Shroud"},
	{"count": 16, "interval": 54, "shroud_every": 2, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 0, "name": "Ash"},
	{"count": 10, "interval": 72, "shroud_every": 0, "rind_every": 1, "pitch_every": 0, "frost_every": 0, "web_every": 0, "name": "Rind"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 0, "frost_every": 0, "web_every": 0, "name": "Gall"},
	{"count": 10, "interval": 72, "shroud_every": 0, "rind_every": 0, "pitch_every": 1, "frost_every": 0, "web_every": 0, "name": "Pitch"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 0, "web_every": 0, "name": "Tar"},
	{"count": 10, "interval": 72, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 1, "web_every": 0, "name": "Frost"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 0, "name": "Rime"},
	{"count": 10, "interval": 72, "shroud_every": 0, "rind_every": 0, "pitch_every": 0, "frost_every": 0, "web_every": 1, "name": "Web"},
	{"count": 16, "interval": 60, "shroud_every": 2, "rind_every": 1, "pitch_every": 1, "frost_every": 1, "web_every": 1, "name": "Snare"},
]


class Command:
	var move_x: int = 0
	var move_y: int = 0
	var plant_kind: int = -1
	var tile: Vector2i = Vector2i(-1, -1)


class Plant:
	var alive: bool = true
	var kind: int = 0
	var cell: Vector2i = Vector2i.ZERO
	var pos: Vector2 = Vector2.ZERO
	var damage: int = 0
	var fire_ticks: int = 1
	var cooldown: int = 0
	var light_radius: float = 0.0
	var weapon_range: float = 0.0
	var projectile_speed: float = 0.0
	var slow_factor: float = 1.0
	var slow_ticks: int = 0
	var splash_radius: float = 0.0
	var burns_shroud: bool = false
	var cracks_rind: bool = false
	var melts_pitch: bool = false
	var thaws_frost: bool = false
	var cuts_web: bool = false


class Pest:
	var id: int = 0
	var pos: Vector2 = Vector2.ZERO
	var hp: int = 0
	var alive: bool = true
	var hidden: bool = true
	var shrouded: bool = false
	var rinded: bool = false
	var pitched: bool = false
	var frosted: bool = false
	var webbed: bool = false
	var speed: float = 0.0
	var slow_factor: float = 1.0
	var slow_ticks: int = 0


class Projectile:
	var alive: bool = true
	var kind: int = 0
	var pos: Vector2 = Vector2.ZERO
	var dir: Vector2 = Vector2.RIGHT
	var speed: float = 0.0
	var damage: int = 0
	var target_id: int = -1
	var life: int = 0
	var splash_radius: float = 0.0
	var slow_factor: float = 1.0
	var slow_ticks: int = 0


var run_seed: int = 1
var tick: int = 0
var phase: int = PHASE_PLANT
var phase_ticks: int = 0
var wave: int = 0
var outcome: int = OUTCOME_RUNNING
var seeds: int = START_SEEDS
var player_hp: int = PLAYER_HP
var player_pos: Vector2 = Vector2.ZERO
var hurt_ticks: int = 0
var spawns_left: int = 0
var spawn_wait: int = 0
var spawn_interval: int = 0
var shots_fired: int = 0
var shrouds_spawned: int = 0
var shrouds_killed: int = 0
var rinds_spawned: int = 0
var rinds_killed: int = 0
var pitches_spawned: int = 0
var pitches_killed: int = 0
var frosts_spawned: int = 0
var frosts_killed: int = 0
var webs_spawned: int = 0
var webs_killed: int = 0
var plants: Array = []
var pests: Array = []
var projectiles: Array = []
var events: Array = []

var _rng := RandomNumberGenerator.new()
var _next_pest_id: int = 1


func _init(start_seed: int = 1) -> void:
	run_seed = start_seed
	_rng.seed = start_seed
	player_pos = tile_center(START_CELL.x, START_CELL.y)
	player_hp = PLAYER_HP
	seeds = START_SEEDS
	phase = PHASE_PLANT
	outcome = OUTCOME_RUNNING


func step(cmd: Command) -> void:
	if outcome != OUTCOME_RUNNING:
		return
	events.clear()
	tick += 1
	var started_wave := false
	if phase == PHASE_PLANT:
		_try_plant(cmd)
		phase_ticks += 1
		if phase_ticks >= PLANT_TICKS:
			_begin_wave()
			started_wave = true
	if phase == PHASE_WAVE and not started_wave:
		_move_player(cmd)
		_wave_spawns()
	_move_pests()
	_refresh_visibility()
	_plants_fire()
	_move_projectiles()
	_contact()
	if outcome == OUTCOME_RUNNING and phase == PHASE_WAVE and not started_wave:
		_maybe_end_wave()
	_cull()


func tile_center(tx: int, ty: int) -> Vector2:
	return Vector2((float(tx) + 0.5) * TILE, (float(ty) + 0.5) * TILE)


func cell_of(pos: Vector2) -> Vector2i:
	var tx := clampi(floori(pos.x / TILE), 0, MAP_W - 1)
	var ty := clampi(floori(pos.y / TILE), 0, MAP_H - 1)
	return Vector2i(tx, ty)


func tile_lit(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, false)


func tile_burns_shroud(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, true, false, false, false, false)


func tile_cracks_rind(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, true, false, false, false)


func tile_melts_pitch(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, true, false, false)


func tile_thaws_frost(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, true, false)


func tile_cuts_web(tx: int, ty: int) -> bool:
	return _tile_in_light(tx, ty, false, false, false, false, true)


func _tile_in_light(tx: int, ty: int, shroud_only: bool, rind_only: bool, pitch_only: bool, frost_only: bool, web_only: bool) -> bool:
	if tx < 0 or ty < 0 or tx >= MAP_W or ty >= MAP_H:
		return false
	var rect_min := Vector2(float(tx) * TILE, float(ty) * TILE)
	var rect_max := rect_min + Vector2(TILE, TILE)
	for plant in plants:
		var grown := plant as Plant
		if not grown.alive:
			continue
		if shroud_only and not grown.burns_shroud:
			continue
		if rind_only and not grown.cracks_rind:
			continue
		if pitch_only and not grown.melts_pitch:
			continue
		if frost_only and not grown.thaws_frost:
			continue
		if web_only and not grown.cuts_web:
			continue
		var source: Vector2 = grown.pos
		var closest := Vector2(
			clampf(source.x, rect_min.x, rect_max.x),
			clampf(source.y, rect_min.y, rect_max.y)
		)
		if source.distance_to(closest) <= grown.light_radius:
			return true
	return false


func is_plantable(cell: Vector2i) -> bool:
	if outcome != OUTCOME_RUNNING or phase != PHASE_PLANT or seeds <= 0:
		return false
	if not _in_orchard(cell):
		return false
	return _plant_on(cell) == null


func has_plant(kind: int) -> bool:
	return plant_of_kind(kind) != null


func plant_of_kind(kind: int):
	for plant in plants:
		if (plant as Plant).alive and (plant as Plant).kind == kind:
			return plant
	return null


func pest_by_id(pest_id: int):
	for pest in pests:
		if (pest as Pest).id == pest_id:
			return pest
	return null


func living_pest_count() -> int:
	var count := 0
	for pest in pests:
		if (pest as Pest).alive:
			count += 1
	return count


func pests_remaining() -> int:
	return living_pest_count() + spawns_left


func plant_seconds_left() -> float:
	if phase != PHASE_PLANT:
		return 0.0
	return maxf(float(PLANT_TICKS - phase_ticks), 0.0) * DT


func phase_text() -> String:
	if outcome == OUTCOME_WON:
		return "The orchard holds"
	if outcome == OUTCOME_LOST:
		return "The lights went out"
	if phase == PHASE_PLANT:
		var next_wave := mini(wave + 1, WAVE_COUNT)
		return "Planting — night %d%s in %.1fs" % [next_wave, _night_suffix(next_wave), plant_seconds_left()]
	return "Night %d of %d%s — %d pests left" % [wave, WAVE_COUNT, _night_suffix(wave), pests_remaining()]


func _night_suffix(index: int) -> String:
	if index < 1 or index > WAVES.size():
		return ""
	var name := str(WAVES[index - 1].get("name", ""))
	if name == "":
		return ""
	return " (%s)" % name


## Shared entry for wave spawns and the visibility test. Does not alter damage or health.
func spawn_pest(pos: Vector2, shrouded: bool = false, rinded: bool = false, pitched: bool = false, frosted: bool = false, webbed: bool = false):
	var pest := Pest.new()
	pest.id = _next_pest_id
	_next_pest_id += 1
	pest.pos = pos
	pest.hp = PEST_HP
	pest.alive = true
	pest.speed = PEST_SPEED
	pest.slow_factor = 1.0
	pest.slow_ticks = 0
	pest.shrouded = shrouded
	pest.rinded = rinded
	pest.pitched = pitched
	pest.frosted = frosted
	pest.webbed = webbed
	if shrouded:
		shrouds_spawned += 1
	if rinded:
		rinds_spawned += 1
	if pitched:
		pitches_spawned += 1
	if frosted:
		frosts_spawned += 1
	if webbed:
		webs_spawned += 1
	_apply_visibility(pest)
	pests.append(pest)
	return pest


func _begin_wave() -> void:
	wave += 1
	phase = PHASE_WAVE
	var spec: Dictionary = WAVES[wave - 1]
	spawns_left = int(spec["count"])
	spawn_interval = int(spec["interval"])
	spawn_wait = 0
	events.append({"type": "wave", "wave": wave})


func _maybe_end_wave() -> void:
	if spawns_left > 0 or living_pest_count() > 0:
		return
	if wave >= WAVE_COUNT:
		outcome = OUTCOME_WON
		events.append({"type": "won"})
	else:
		phase = PHASE_PLANT
		phase_ticks = 0
		events.append({"type": "plant_phase", "wave": wave + 1})


func _try_plant(cmd: Command) -> void:
	if cmd.plant_kind < 0:
		return
	var kind := cmd.plant_kind
	if phase != PHASE_PLANT or seeds <= 0 or kind < 0 or kind >= Catalog.COUNT:
		events.append({"type": "plant_rejected"})
		return
	if not _in_orchard(cmd.tile) or _plant_on(cmd.tile) != null:
		events.append({"type": "plant_rejected"})
		return
	var stats := Catalog.get_stats(kind)
	var plant := Plant.new()
	plant.kind = kind
	plant.cell = cmd.tile
	plant.pos = tile_center(cmd.tile.x, cmd.tile.y)
	plant.damage = int(stats["damage"])
	plant.fire_ticks = int(stats["fire_ticks"])
	plant.cooldown = 0
	plant.light_radius = float(stats["light_radius"])
	plant.weapon_range = float(stats["weapon_range"])
	plant.projectile_speed = float(stats["projectile_speed"])
	plant.slow_factor = float(stats["slow_factor"])
	plant.slow_ticks = int(stats["slow_ticks"])
	plant.splash_radius = float(stats["splash_radius"])
	plant.burns_shroud = bool(stats["burns_shroud"])
	plant.cracks_rind = bool(stats["cracks_rind"])
	plant.melts_pitch = bool(stats["melts_pitch"])
	plant.thaws_frost = bool(stats["thaws_frost"])
	plant.cuts_web = bool(stats["cuts_web"])
	plants.append(plant)
	seeds -= 1
	events.append({"type": "planted", "kind": kind, "x": cmd.tile.x, "y": cmd.tile.y})


func _move_player(cmd: Command) -> void:
	var direction := Vector2(float(cmd.move_x), float(cmd.move_y))
	if direction.length_squared() > 1.0:
		direction = direction.normalized()
	if direction == Vector2.ZERO:
		return
	player_pos += direction * PLAYER_SPEED * DT
	var margin := 14.0
	player_pos.x = clampf(player_pos.x, margin, MAP_W * TILE - margin)
	player_pos.y = clampf(player_pos.y, margin, MAP_H * TILE - margin)


func _wave_spawns() -> void:
	if spawns_left <= 0:
		return
	if spawn_wait > 0:
		spawn_wait -= 1
		return
	var edge := _rng.randi() % 4
	var cell := Vector2i.ZERO
	if edge == 0:
		cell = Vector2i(_rng.randi() % MAP_W, 0)
	elif edge == 1:
		cell = Vector2i(_rng.randi() % MAP_W, MAP_H - 1)
	elif edge == 2:
		cell = Vector2i(0, 1 + _rng.randi() % (MAP_H - 2))
	else:
		cell = Vector2i(MAP_W - 1, 1 + _rng.randi() % (MAP_H - 2))
	var spec: Dictionary = WAVES[wave - 1]
	var shroud_every := int(spec.get("shroud_every", 0))
	var rind_every := int(spec.get("rind_every", 0))
	var pitch_every := int(spec.get("pitch_every", 0))
	var frost_every := int(spec.get("frost_every", 0))
	var web_every := int(spec.get("web_every", 0))
	var index := int(spec["count"]) - spawns_left
	var shrouded := shroud_every > 0 and index % shroud_every == shroud_every - 1
	var rinded := rind_every > 0 and index % rind_every == rind_every - 1
	var pitched := pitch_every > 0 and index % pitch_every == pitch_every - 1
	var frosted := frost_every > 0 and index % frost_every == frost_every - 1
	var webbed := web_every > 0 and index % web_every == web_every - 1
	spawn_pest(tile_center(cell.x, cell.y), shrouded, rinded, pitched, frosted, webbed)
	spawns_left -= 1
	spawn_wait = spawn_interval


func _move_pests() -> void:
	for entry in pests:
		var pest := entry as Pest
		if not pest.alive:
			continue
		if pest.slow_ticks > 0:
			pest.slow_ticks -= 1
			if pest.slow_ticks <= 0:
				pest.slow_factor = 1.0
		var offset := player_pos - pest.pos
		var distance := offset.length()
		if distance <= 0.001:
			continue
		var step_len := pest.speed * pest.slow_factor * DT
		if step_len >= distance:
			pest.pos = player_pos
		else:
			pest.pos += offset * (step_len / distance)


func _refresh_visibility() -> void:
	for entry in pests:
		_apply_visibility(entry as Pest)


func _apply_visibility(pest: Pest) -> void:
	if not pest.alive:
		pest.hidden = true
		return
	var cell := cell_of(pest.pos)
	if pest.shrouded or pest.rinded or pest.pitched or pest.frosted or pest.webbed:
		var open := true
		if pest.shrouded:
			open = open and tile_burns_shroud(cell.x, cell.y)
		if pest.rinded:
			open = open and tile_cracks_rind(cell.x, cell.y)
		if pest.pitched:
			open = open and tile_melts_pitch(cell.x, cell.y)
		if pest.frosted:
			open = open and tile_thaws_frost(cell.x, cell.y)
		if pest.webbed:
			open = open and tile_cuts_web(cell.x, cell.y)
		pest.hidden = not open
	else:
		pest.hidden = not tile_lit(cell.x, cell.y)


func _shroud_up(pest: Pest) -> bool:
	if not pest.shrouded:
		return false
	var cell := cell_of(pest.pos)
	return not tile_burns_shroud(cell.x, cell.y)


func _rind_up(pest: Pest) -> bool:
	if not pest.rinded:
		return false
	var cell := cell_of(pest.pos)
	return not tile_cracks_rind(cell.x, cell.y)


func _pitch_up(pest: Pest) -> bool:
	if not pest.pitched:
		return false
	var cell := cell_of(pest.pos)
	return not tile_melts_pitch(cell.x, cell.y)


func _frost_up(pest: Pest) -> bool:
	if not pest.frosted:
		return false
	var cell := cell_of(pest.pos)
	return not tile_thaws_frost(cell.x, cell.y)


func _web_up(pest: Pest) -> bool:
	if not pest.webbed:
		return false
	var cell := cell_of(pest.pos)
	return not tile_cuts_web(cell.x, cell.y)


func _plants_fire() -> void:
	for entry in plants:
		var plant := entry as Plant
		if not plant.alive:
			continue
		if plant.cooldown > 0:
			plant.cooldown -= 1
			continue
		var target: Pest = _choose_target(plant)
		if target == null:
			continue
		var shot := Projectile.new()
		shot.kind = plant.kind
		shot.pos = plant.pos
		shot.speed = plant.projectile_speed
		shot.damage = plant.damage
		shot.target_id = target.id
		shot.life = PROJECTILE_LIFE
		shot.splash_radius = plant.splash_radius
		shot.slow_factor = plant.slow_factor
		shot.slow_ticks = plant.slow_ticks
		var aim := target.pos - plant.pos
		shot.dir = aim.normalized() if aim.length_squared() > 0.0001 else Vector2.RIGHT
		projectiles.append(shot)
		plant.cooldown = plant.fire_ticks
		shots_fired += 1


func _choose_target(plant: Plant) -> Pest:
	var best: Pest = null
	var best_player_distance := INF
	var best_id := 0
	for entry in pests:
		var pest := entry as Pest
		if not pest.alive or pest.hidden:
			continue
		if plant.pos.distance_to(pest.pos) > plant.weapon_range:
			continue
		var player_distance := player_pos.distance_to(pest.pos)
		if best == null or player_distance < best_player_distance - 0.001 or (absf(player_distance - best_player_distance) <= 0.001 and pest.id < best_id):
			best = pest
			best_player_distance = player_distance
			best_id = pest.id
	return best


func _move_projectiles() -> void:
	for entry in projectiles:
		var shot := entry as Projectile
		if not shot.alive:
			continue
		var target: Pest = pest_by_id(shot.target_id)
		if target != null and target.alive:
			var aim := target.pos - shot.pos
			if aim.length_squared() > 0.0001:
				shot.dir = aim.normalized()
		var dest := shot.pos + shot.dir * shot.speed * DT
		if target != null and target.alive:
			var reach := PROJECTILE_RADIUS + PEST_RADIUS
			if _segment_hits(shot.pos, dest, target.pos, reach):
				_impact(shot, target)
				continue
		shot.pos = dest
		shot.life -= 1
		if shot.life <= 0:
			shot.alive = false


func _impact(shot: Projectile, target: Pest) -> void:
	shot.alive = false
	var victims: Array = [target]
	if shot.splash_radius > 0.0:
		for entry in pests:
			var other := entry as Pest
			if other == target or not other.alive:
				continue
			if other.pos.distance_to(target.pos) <= shot.splash_radius:
				victims.append(other)
	for entry in victims:
		var pest := entry as Pest
		if pest.alive:
			_damage_pest(pest, shot)


func _damage_pest(pest: Pest, shot: Projectile) -> void:
	if _shroud_up(pest) or _rind_up(pest) or _pitch_up(pest) or _frost_up(pest) or _web_up(pest):
		return
	pest.hp -= shot.damage
	if shot.slow_ticks > 0:
		pest.slow_ticks = shot.slow_ticks
		pest.slow_factor = shot.slow_factor
	var hp_after := maxi(pest.hp, 0)
	events.append({
		"type": "hit",
		"damage": shot.damage,
		"pest_id": pest.id,
		"hp_after": hp_after,
		"kind": shot.kind,
	})
	if pest.hp <= 0:
		pest.hp = 0
		pest.alive = false
		if pest.shrouded:
			shrouds_killed += 1
		if pest.rinded:
			rinds_killed += 1
		if pest.pitched:
			pitches_killed += 1
		if pest.frosted:
			frosts_killed += 1
		if pest.webbed:
			webs_killed += 1
		events.append({
			"type": "died",
			"x": pest.pos.x,
			"y": pest.pos.y,
			"hidden": pest.hidden,
			"id": pest.id,
		})


func _contact() -> void:
	if hurt_ticks > 0:
		hurt_ticks -= 1
	if hurt_ticks > 0:
		return
	var reach := PLAYER_RADIUS + PEST_RADIUS
	for entry in pests:
		var pest := entry as Pest
		if not pest.alive:
			continue
		if player_pos.distance_to(pest.pos) > reach:
			continue
		player_hp -= CONTACT_DAMAGE
		hurt_ticks = HURT_TICKS
		if player_hp <= 0:
			player_hp = 0
			outcome = OUTCOME_LOST
		events.append({"type": "hurt", "hp": player_hp})
		if outcome == OUTCOME_LOST:
			events.append({"type": "lost"})
		return


func _cull() -> void:
	var next_pests: Array = []
	for entry in pests:
		if (entry as Pest).alive:
			next_pests.append(entry)
	pests = next_pests
	var next_shots: Array = []
	for entry in projectiles:
		if (entry as Projectile).alive:
			next_shots.append(entry)
	projectiles = next_shots


func _in_orchard(cell: Vector2i) -> bool:
	return cell.x >= 1 and cell.y >= 1 and cell.x <= MAP_W - 2 and cell.y <= MAP_H - 2


func _plant_on(cell: Vector2i):
	for entry in plants:
		var plant := entry as Plant
		if plant.alive and plant.cell == cell:
			return plant
	return null


func _segment_hits(start: Vector2, dest: Vector2, center: Vector2, radius: float) -> bool:
	var span := dest - start
	var length_sq := span.length_squared()
	var t := 0.0
	if length_sq > 0.000001:
		t = clampf((center - start).dot(span) / length_sq, 0.0, 1.0)
	var closest := start + span * t
	return closest.distance_squared_to(center) <= radius * radius
