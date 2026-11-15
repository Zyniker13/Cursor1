extends RefCounted

## Single source of plant numbers. Combat copies these fields onto each plant.
## Tooltip text is formatted from the same dictionary. Do not duplicate the table.

const DT := 1.0 / 30.0

const PEA := 0
const VINE := 1
const LANTERN := 2
const GOURD := 3
const WICK := 4
const BRIAR := 5
const FLARE := 6
const HEARTH := 7
const SHEAR := 8
const CHIME := 9
const COUNT := 10

# fire_ticks and slow_ticks are sim ticks of length DT.
# light_radius, weapon_range, projectile_speed, and splash_radius are pixels.
# slow_factor is the movement multiplier applied on hit (1.0 means no slow).
# burns_shroud: this plant's light reveals shroud moths and lets shots hurt them.
# cracks_rind: this plant's light reveals rind moths and lets shots hurt them.
# melts_pitch: this plant's light reveals pitch moths and lets shots hurt them.
# thaws_frost: this plant's light reveals frost moths and lets shots hurt them.
# cuts_web: this plant's light reveals web moths and lets shots hurt them.
# cracks_glass: this plant's light reveals glass moths and lets shots hurt them.
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
		"burns_shroud": false,
		"cracks_rind": false,
		"melts_pitch": false,
		"thaws_frost": false,
		"cuts_web": false,
		"cracks_glass": false,
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
		"burns_shroud": false,
		"cracks_rind": false,
		"melts_pitch": false,
		"thaws_frost": false,
		"cuts_web": false,
		"cracks_glass": false,
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
		"burns_shroud": false,
		"cracks_rind": false,
		"melts_pitch": false,
		"thaws_frost": false,
		"cuts_web": false,
		"cracks_glass": false,
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
		"burns_shroud": false,
		"cracks_rind": false,
		"melts_pitch": false,
		"thaws_frost": false,
		"cuts_web": false,
		"cracks_glass": false,
	},
	{
		"name": "Wick",
		"role": "Burns shroud, modest shots, tight light.",
		"damage": 3,
		"fire_ticks": 12,
		"light_radius": 96.0,
		"weapon_range": 240.0,
		"projectile_speed": 480.0,
		"slow_factor": 1.0,
		"slow_ticks": 0,
		"splash_radius": 0.0,
		"burns_shroud": true,
		"cracks_rind": false,
		"melts_pitch": false,
		"thaws_frost": false,
		"cuts_web": false,
		"cracks_glass": false,
	},
	{
		"name": "Briar",
		"role": "Cracks rind, short shots, tight light.",
		"damage": 5,
		"fire_ticks": 15,
		"light_radius": 104.0,
		"weapon_range": 200.0,
		"projectile_speed": 420.0,
		"slow_factor": 1.0,
		"slow_ticks": 0,
		"splash_radius": 0.0,
		"burns_shroud": false,
		"cracks_rind": true,
		"melts_pitch": false,
		"thaws_frost": false,
		"cuts_web": false,
		"cracks_glass": false,
	},
	{
		"name": "Flare",
		"role": "Melts pitch, short shots, tight light.",
		"damage": 6,
		"fire_ticks": 9,
		"light_radius": 112.0,
		"weapon_range": 220.0,
		"projectile_speed": 460.0,
		"slow_factor": 1.0,
		"slow_ticks": 0,
		"splash_radius": 0.0,
		"burns_shroud": false,
		"cracks_rind": false,
		"melts_pitch": true,
		"thaws_frost": false,
		"cuts_web": false,
		"cracks_glass": false,
	},
	{
		"name": "Hearth",
		"role": "Thaws frost, modest shots, tight light.",
		"damage": 4,
		"fire_ticks": 21,
		"light_radius": 128.0,
		"weapon_range": 180.0,
		"projectile_speed": 400.0,
		"slow_factor": 1.0,
		"slow_ticks": 0,
		"splash_radius": 0.0,
		"burns_shroud": false,
		"cracks_rind": false,
		"melts_pitch": false,
		"thaws_frost": true,
		"cuts_web": false,
		"cracks_glass": false,
	},
	{
		"name": "Shear",
		"role": "Cuts web, modest shots, tight light.",
		"damage": 5,
		"fire_ticks": 24,
		"light_radius": 144.0,
		"weapon_range": 160.0,
		"projectile_speed": 380.0,
		"slow_factor": 1.0,
		"slow_ticks": 0,
		"splash_radius": 0.0,
		"burns_shroud": false,
		"cracks_rind": false,
		"melts_pitch": false,
		"thaws_frost": false,
		"cuts_web": true,
		"cracks_glass": false,
	},
	{
		"name": "Chime",
		"role": "Cracks glass, modest shots, tight light.",
		"damage": 3,
		"fire_ticks": 27,
		"light_radius": 160.0,
		"weapon_range": 140.0,
		"projectile_speed": 360.0,
		"slow_factor": 1.0,
		"slow_ticks": 0,
		"splash_radius": 0.0,
		"burns_shroud": false,
		"cracks_rind": false,
		"melts_pitch": false,
		"thaws_frost": false,
		"cuts_web": false,
		"cracks_glass": true,
	},
]


static func get_stats(kind: int) -> Dictionary:
	var out := (DEFS[kind] as Dictionary).duplicate(true)
	out["kind"] = kind
	out["fire_interval"] = float(out["fire_ticks"]) * DT
	out["slow_duration"] = float(out["slow_ticks"]) * DT
	return out
