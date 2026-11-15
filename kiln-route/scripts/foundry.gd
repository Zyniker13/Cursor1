extends RefCounted

## Shared constants for Kiln Route. Behavior is specified in README.md
## and locked by tests/run_tests.gd.

enum Mat { ORE, INGOT, PLATE }
enum Kind { BELT, KILN, PRESS, FILTER, SPLITTER, ROLLER, WEIR, BRIDGE, GRATE, HOOK, ARM, DROP, LIFT, DWELL, TWIN, PASS, SLIP, SHED, RAKE, HOE, HARROW, FORK, PRONG, SHARE, COULTER }
enum Dir { EAST, SOUTH, WEST, NORTH }

## One simulated minute. Every room runs this many ticks.
const SIM_TICKS := 120
## Ticks from ore entry until an ingot can leave a kiln.
const KILN_DELAY := 2
## Ticks from the second ingot until a plate can leave a press.
const PRESS_DELAY := 1
## Ticks a dwell keeps an item after the arrival tick, before it may leave.
## A belt sends on the tick after arrival. This extra tick is the whole difference.
const DWELL_HOLD := 1
## The simulator has no RNG. Runs record this so equal seeds are obvious.
const SEED := 0

const VEC := [
	Vector2i(1, 0),
	Vector2i(0, 1),
	Vector2i(-1, 0),
	Vector2i(0, -1),
]

const KIND_NAME := ["Belt", "Kiln", "Press", "Filter", "Splitter", "Roller", "Weir", "Bridge", "Grate", "Hook", "Arm", "Drop", "Lift", "Dwell", "Twin", "Pass", "Slip", "Shed", "Rake", "Hoe", "Harrow", "Fork", "Prong", "Share", "Coulter"]
const MAT_NAME := ["Ore", "Ingot", "Plate"]
const DIR_NAME := ["East", "South", "West", "North"]

static func vec(dir: int) -> Vector2i:
	return VEC[dir & 3]

static func right(dir: int) -> int:
	return (dir + 1) & 3

static func left(dir: int) -> int:
	return (dir + 3) & 3

static func opposite(dir: int) -> int:
	return (dir + 2) & 3
