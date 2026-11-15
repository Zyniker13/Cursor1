extends RefCounted

## Single source of plant numbers. Combat copies these fields onto each plant.
## Tooltip text is formatted from the same dictionary. Do not duplicate the table.

const DT := 1.0 / 30.0

const PEA := 0
const VINE := 1
const LANTERN := 2
const GOURD := 3
const COUNT := 4

# fire_ticks and slow_ticks are sim ticks of length DT.
# light_radius, weapon_range, projectile_speed, and splash_radius are pixels.
# slow_factor is the movement multiplier applied on hit (1.0 means no slow).
const DEFS := [
	{
		"name": "Pea",
		"role": "Fast weak shots, small light.",
		"damage": 4,
		"fire_ticks": 6,
		"light_radius": 64.0,
		"weapon_range": 340.0,
		"projectile_speed": 640.0,
		"slow_factor": 1.0,
		"slow_ticks": 0,
		"splash_radius": 0.0,
	},
	{
		"name": "Vine",
		"role": "Slows pests, tiny damage, small light.",
		"damage": 2,
		"fire_ticks": 18,
		"light_radius": 84.0,
		"weapon_range": 300.0,
		"projectile_speed": 360.0,
		"slow_factor": 0.40,
		"slow_ticks": 60,
		"splash_radius": 0.0,
	},
	{
		"name": "Lantern",
		"role": "Almost no damage, large light.",
		"damage": 1,
		"fire_ticks": 45,
		"light_radius": 220.0,
		"weapon_range": 52.0,
		"projectile_speed": 220.0,
		"slow_factor": 1.0,
		"slow_ticks": 0,
		"splash_radius": 0.0,
	},
	{
		"name": "Gourd",
		"role": "Slow heavy burst, medium light.",
		"damage": 14,
		"fire_ticks": 36,
		"light_radius": 132.0,
		"weapon_range": 300.0,
		"projectile_speed": 300.0,
		"slow_factor": 1.0,
		"slow_ticks": 0,
		"splash_radius": 64.0,
	},
]


static func get_stats(kind: int) -> Dictionary:
	var out := (DEFS[kind] as Dictionary).duplicate(true)
	out["kind"] = kind
	out["fire_interval"] = float(out["fire_ticks"]) * DT
	out["slow_duration"] = float(out["slow_ticks"]) * DT
	return out
