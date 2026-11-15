extends RefCounted

## Kiln Route rooms. Wing 1 is the first eight. Wing 2 is rooms 9-16.
## The roller and the weir are taught before a later room depends on them.
## Each solution is a full layout, not a delta from the initial pieces.
## Quotas are minimums inside SIM_TICKS.

const Rules = preload("res://scripts/foundry.gd")


static func all() -> Array:
	return [
		haul(),
		smelt(),
		stamp(),
		room_sort(),
		divide(),
		pinch(),
		relight(),
		two_orders(),
		straight(),
		spill(),
		keep(),
		detour(),
		refine(),
		miscast(),
		hearth(),
		balance(),
	]


static func kv(pairs: Array) -> Dictionary:
	var built := {}
	var index := 0
	while index + 1 < pairs.size():
		built[pairs[index]] = pairs[index + 1]
		index += 2
	return built


static func piece(kind: int, x: int, y: int, dir: int) -> Dictionary:
	return {"kind": kind, "x": x, "y": y, "dir": dir}


static func source(x: int, y: int, dir: int, pattern: Array, period: int) -> Dictionary:
	return {"x": x, "y": y, "dir": dir, "pattern": pattern, "period": period}


static func sink(x: int, y: int, accepts: Array) -> Dictionary:
	return {"x": x, "y": y, "accepts": accepts}


static func cell(x: int, y: int) -> Dictionary:
	return {"x": x, "y": y}


static func haul() -> Dictionary:
	var rules = Rules
	return {
		"id": 1,
		"name": "Haul",
		"blurb": "Left-click places a tray piece, left-click a placed piece picks it up, R rotates, and Space runs the minute.",
		"rule": "A belt holds one item and moves it one cell forward each tick. It accepts from behind and from either side, and refuses anything pushing into its front.",
		"w": 5,
		"h": 3,
		"sources": [source(0, 1, rules.Dir.EAST, [rules.Mat.ORE], 2)],
		"sinks": [sink(4, 1, [rules.Mat.ORE])],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3]),
		"quota": kv([rules.Mat.ORE, 24]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.EAST),
		],
	}


static func smelt() -> Dictionary:
	var rules = Rules
	return {
		"id": 2,
		"name": "Smelt",
		"blurb": "Feed the kiln ore. Two ticks later it pushes an ingot, and this bin takes nothing else.",
		"rule": "A kiln accepts one ore from behind. After 2 ticks it pushes an ingot forward. It takes nothing while smelting or while that ingot is blocked.",
		"w": 5,
		"h": 3,
		"sources": [source(0, 1, rules.Dir.EAST, [rules.Mat.ORE], 2)],
		"sinks": [sink(4, 1, [rules.Mat.INGOT])],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 2, rules.Kind.KILN, 1]),
		"quota": kv([rules.Mat.INGOT, 18]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.EAST),
		],
	}


static func stamp() -> Dictionary:
	var rules = Rules
	return {
		"id": 3,
		"name": "Stamp",
		"blurb": "The press swallows two ingots and pushes out one plate.",
		"rule": "A press accepts ingots from behind and refuses everything else. The second ingot becomes a plate after 1 tick. The plate leaves forward.",
		"w": 7,
		"h": 3,
		"sources": [source(0, 1, rules.Dir.EAST, [rules.Mat.ORE], 2)],
		"sinks": [sink(6, 1, [rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.KILN, 1, rules.Kind.PRESS, 1]),
		"quota": kv([rules.Mat.PLATE, 8]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
		],
	}


static func room_sort() -> Dictionary:
	var rules = Rules
	return {
		"id": 4,
		"name": "Sort",
		"blurb": "The filter sends ore forward and sends ingots and plates out its right side.",
		"rule": "Ore leaves along the filter's facing. Ingots and plates leave 90 degrees clockwise. A blocked exit waits on the filter. The pit accepts waste and does not count.",
		"w": 5,
		"h": 5,
		"sources": [source(0, 2, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.INGOT], 2)],
		"sinks": [sink(2, 4, [rules.Mat.INGOT])],
		"chutes": [cell(4, 2)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.FILTER, 1]),
		"quota": kv([rules.Mat.INGOT, 10]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.SOUTH),
		],
	}


static func divide() -> Dictionary:
	var rules = Rules
	# Two symmetric kiln lines. One kiln's throughput cannot reach the quota.
	return {
		"id": 5,
		"name": "Divide",
		"blurb": "The splitter alternates forward, then right. One kiln cannot hit this quota alone.",
		"rule": "The first item leaves forward, the next leaves to the right, and so on. If the chosen exit is blocked, the item waits and the turn does not advance.",
		"w": 7,
		"h": 3,
		"sources": [source(0, 1, rules.Dir.EAST, [rules.Mat.ORE], 1)],
		"sinks": [
			sink(6, 1, [rules.Mat.INGOT]),
			sink(5, 2, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 5, rules.Kind.KILN, 2, rules.Kind.SPLITTER, 1]),
		"quota": kv([rules.Mat.INGOT, 70]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.EAST),
		],
	}


static func pinch() -> Dictionary:
	var rules = Rules
	# The stamp-room spacing wants a belt in every gap. This tray has two belts
	# for four cells, so two machines have to touch.
	return {
		"id": 6,
		"name": "Pinch",
		"blurb": "Two belts, not three. Something in the line has to sit against something else.",
		"rule": "Machines push their own output forward. The tray will not pay for a belt between every machine, and placing past the tray is refused.",
		"w": 6,
		"h": 3,
		"sources": [source(0, 1, rules.Dir.EAST, [rules.Mat.ORE], 2)],
		"sinks": [sink(5, 1, [rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 2, rules.Kind.KILN, 1, rules.Kind.PRESS, 1]),
		"quota": kv([rules.Mat.PLATE, 8]),
		"initial": [],
		"solution": [
			piece(rules.Kind.KILN, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
		],
	}


static func relight() -> Dictionary:
	var rules = Rules
	# The kiln starts one row above the route. Both belts cannot bridge the gap
	# while that kiln still occupies the budget, so it has to be lifted.
	return {
		"id": 7,
		"name": "Relight",
		"blurb": "That kiln is on the wrong cell. Pick it up and seat it on the route.",
		"rule": "Pickup always returns a piece to the tray, including a piece the room already placed. Leaving the kiln off the route spends the budget and misses the bin.",
		"w": 5,
		"h": 3,
		"sources": [source(0, 1, rules.Dir.EAST, [rules.Mat.ORE], 2)],
		"sinks": [sink(4, 1, [rules.Mat.INGOT])],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 2, rules.Kind.KILN, 1]),
		"quota": kv([rules.Mat.INGOT, 14]),
		"initial": [
			piece(rules.Kind.KILN, 2, 0, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.EAST),
		],
	}


static func two_orders() -> Dictionary:
	var rules = Rules
	# One kiln, no spare pieces. The splitter has to feed the bin and the press.
	return {
		"id": 8,
		"name": "Two Orders",
		"blurb": "The bin wants plates and ingots. The tray is exact, so one kiln has to serve both.",
		"rule": "Split the kiln's ingots. One branch goes to the bin, the other goes through the press. Using every piece still has to stay inside the tray.",
		"w": 6,
		"h": 3,
		"sources": [source(0, 1, rules.Dir.EAST, [rules.Mat.ORE], 2)],
		"sinks": [
			sink(5, 1, [rules.Mat.INGOT, rules.Mat.PLATE]),
			sink(5, 2, [rules.Mat.INGOT, rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.KILN, 1,
			rules.Kind.PRESS, 1,
			rules.Kind.SPLITTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 8, rules.Mat.PLATE, 3]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 4, 2, rules.Dir.EAST),
		],
	}


static func straight() -> Dictionary:
	var rules = Rules
	# Ore drops onto the lane. A belt would carry it into an ingot bin and stall.
	# The roller is the only tray piece that refuses that side load.
	return {
		"id": 9,
		"name": "Straight",
		"blurb": "The roller takes a load only from behind. The ore beside it has to be refused.",
		"rule": "A roller holds one item and pushes it forward. It accepts only from behind, so ore from the side stays on the source. A belt there would take the ore, and the ingot bin would refuse it.",
		"w": 7,
		"h": 2,
		"sources": [
			source(0, 1, rules.Dir.EAST, [rules.Mat.INGOT], 2),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 2),
		],
		"sinks": [sink(6, 1, [rules.Mat.INGOT])],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 4, rules.Kind.ROLLER, 1]),
		"quota": kv([rules.Mat.INGOT, 24]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.ROLLER, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
		],
	}


static func spill() -> Dictionary:
	var rules = Rules
	# Period 1 is faster than one kiln. The weir keeps the forward kiln full
	# and only the overflow reaches the lower kiln.
	return {
		"id": 10,
		"name": "Spill",
		"blurb": "The weir fills the forward kiln and spills the rest to the kiln on its right.",
		"rule": "A weir holds one item. It tries forward first and uses the right side only when forward refuses. It does not alternate, and the next item tries forward again. One kiln cannot reach the quota.",
		"w": 6,
		"h": 2,
		"sources": [source(0, 0, rules.Dir.EAST, [rules.Mat.ORE], 1)],
		"sinks": [
			sink(5, 0, [rules.Mat.INGOT]),
			sink(5, 1, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 4, rules.Kind.KILN, 2, rules.Kind.WEIR, 1]),
		"quota": kv([rules.Mat.INGOT, 70]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 0, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 0, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
		],
	}


static func keep() -> Dictionary:
	var rules = Rules
	# Inverse of Sort: ore is the product, and the metal is waste.
	return {
		"id": 11,
		"name": "Keep",
		"blurb": "Aim the filter at the ore bin. Ingots turn right into the waste chute.",
		"rule": "Ore leaves along the filter's face. Ingots and plates leave 90 degrees clockwise. Point the face at the ore bin and the right side at the waste chute. The first ingot clogs a plain belt line.",
		"w": 5,
		"h": 2,
		"sources": [source(0, 0, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.INGOT], 2)],
		"sinks": [sink(4, 0, [rules.Mat.ORE])],
		"chutes": [cell(2, 1)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 2, rules.Kind.FILTER, 1]),
		"quota": kv([rules.Mat.ORE, 12]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 0, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 2, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 0, rules.Dir.EAST),
		],
	}


static func detour() -> Dictionary:
	var rules = Rules
	# The middle row is shut. The only route is around the right edge.
	return {
		"id": 12,
		"name": "Detour",
		"blurb": "A wall closes the middle row. Turn the belts and go around.",
		"rule": "Walls and empty floor do not carry items. A belt accepts from behind or either side and pushes forward, so each corner belt faces the way the ore turns.",
		"w": 4,
		"h": 3,
		"sources": [source(0, 0, rules.Dir.EAST, [rules.Mat.ORE], 2)],
		"sinks": [sink(0, 2, [rules.Mat.ORE])],
		"chutes": [],
		"walls": [cell(0, 1), cell(1, 1), cell(2, 1)],
		"budget": kv([rules.Kind.BELT, 7]),
		"quota": kv([rules.Mat.ORE, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 0, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.WEST),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.WEST),
			piece(rules.Kind.BELT, 1, 2, rules.Dir.WEST),
		],
	}


static func refine() -> Dictionary:
	var rules = Rules
	# Same aim as Keep, then the kiln. A raw ingot against the kiln stalls the ore.
	return {
		"id": 13,
		"name": "Refine",
		"blurb": "Throw out the raw ingots. Smelt the ore the filter sends forward.",
		"rule": "The filter's ore goes into the kiln. Its ingots go into the waste chute and are not counted. A raw ingot stuck against the kiln stops the ore behind it.",
		"w": 6,
		"h": 2,
		"sources": [source(0, 0, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.INGOT], 2)],
		"sinks": [sink(5, 0, [rules.Mat.INGOT])],
		"chutes": [cell(2, 1)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 2, rules.Kind.FILTER, 1, rules.Kind.KILN, 1]),
		"quota": kv([rules.Mat.INGOT, 12]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 0, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 2, 0, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 0, rules.Dir.EAST),
		],
	}


static func miscast() -> Dictionary:
	var rules = Rules
	# The only roller starts off the lane. Five pieces cover the five lane cells,
	# so it has to be picked up and seated on the ore crossing.
	return {
		"id": 14,
		"name": "Miscast",
		"blurb": "That roller is off the route. Pick it up and put it on the crossing.",
		"rule": "Pickup returns a piece to the tray, including this roller. It has to face along the ingots on the crossing. The cell it starts on is not on the route.",
		"w": 7,
		"h": 2,
		"sources": [
			source(0, 1, rules.Dir.EAST, [rules.Mat.INGOT], 2),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 2),
		],
		"sinks": [sink(6, 1, [rules.Mat.INGOT])],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 4, rules.Kind.ROLLER, 1]),
		"quota": kv([rules.Mat.INGOT, 24]),
		"initial": [
			piece(rules.Kind.ROLLER, 1, 0, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.ROLLER, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
		],
	}


static func hearth() -> Dictionary:
	var rules = Rules
	# One kiln's plates cannot reach the quota. The spill kiln merges in from below.
	return {
		"id": 15,
		"name": "Hearth",
		"blurb": "One kiln cannot stamp this many plates. Spill the extra ore into the second.",
		"rule": "The forward kiln stays busy. Extra ore spills to the lower kiln, and a belt merges both ingot lines into the press. The press still spends two ingots on each plate.",
		"w": 8,
		"h": 2,
		"sources": [source(0, 0, rules.Dir.EAST, [rules.Mat.ORE], 1)],
		"sinks": [sink(7, 0, [rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 5,
			rules.Kind.WEIR, 1,
			rules.Kind.KILN, 2,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.PLATE, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 0, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 0, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 0, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 5, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.NORTH),
		],
	}


static func balance() -> Dictionary:
	var rules = Rules
	# Plates cross the ingot line. The roller has to sit there; the splitter,
	# not the weir, is what feeds the bin and the press at the same time.
	return {
		"id": 16,
		"name": "Balance",
		"blurb": "Block the crossing plates with the roller, then split ingots to the bin and the press.",
		"rule": "The roller refuses crossing plates. The splitter alternates ingots forward to the ingot bin and right through the press. Each bin refuses the other product.",
		"w": 7,
		"h": 3,
		"sources": [
			source(0, 1, rules.Dir.EAST, [rules.Mat.ORE], 2),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(6, 1, [rules.Mat.INGOT]),
			sink(6, 2, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.KILN, 1,
			rules.Kind.ROLLER, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 16, rules.Mat.PLATE, 8]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.ROLLER, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 5, 2, rules.Dir.EAST),
		],
	}
