extends RefCounted

## Wing 1 of Kiln Route: eight teaching rooms. Each solution is a full layout,
## not a delta from the initial pieces. Quotas are minimums inside SIM_TICKS.

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
