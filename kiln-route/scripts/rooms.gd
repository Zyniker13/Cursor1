extends RefCounted

## Kiln Route rooms. Wing 1 is the first eight. Wing 2 is rooms 9-16.
## Wing 3 is rooms 17-24. Wing 4 is rooms 25-32. Wing 5 is rooms 33-40.
## The roller, the weir, the bridge, the grate, and the hook are taught before a later room depends on them.
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
		span(),
		thread(),
		seam(),
		skew(),
		bend(),
		brim(),
		sift(),
		ledger(),
		screen(),
		temper(),
		crimp(),
		cant(),
		jink(),
		charge(),
		clarify(),
		reckon(),
		veer(),
		draw(),
		nip(),
		slue(),
		jibe(),
		spate(),
		winnow(),
		tally(),
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


static func span() -> Dictionary:
	var rules = Rules
	# Ingot lane west to east, plate lane north to south. Only a bridge
	# carries both. A belt on the crossing mixes them and both bins stall.
	return {
		"id": 17,
		"name": "Span",
		"blurb": "The bridge keeps the ingot lane and the plate lane apart. Both bins have to fill.",
		"rule": "A bridge holds one item on the forward lane and one on the cross lane. Forward accepts only from behind and leaves forward. The cross lane accepts only from the left and leaves to the right. A belt on the crossing takes the plates, and the ingot bin refuses them.",
		"w": 5,
		"h": 5,
		"sources": [
			source(0, 1, rules.Dir.EAST, [rules.Mat.INGOT], 2),
			source(2, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(4, 1, [rules.Mat.INGOT]),
			sink(2, 4, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 4, rules.Kind.BRIDGE, 1]),
		"quota": kv([rules.Mat.INGOT, 36, rules.Mat.PLATE, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.BRIDGE, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.SOUTH),
		],
	}


static func thread() -> Dictionary:
	var rules = Rules
	# Plates cross the ore that has to be smelted. A plate in front of the kiln stalls it.
	return {
		"id": 18,
		"name": "Thread",
		"blurb": "Cross the plates over the ore, then smelt the ore the bridge lets through.",
		"rule": "The kiln accepts ore from behind and refuses plates. Plates that enter the ore lane block the kiln, and they never reach the plate bin. The bridge keeps each material on its own lane.",
		"w": 7,
		"h": 4,
		"sources": [
			source(0, 1, rules.Dir.EAST, [rules.Mat.ORE], 2),
			source(2, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(6, 1, [rules.Mat.INGOT]),
			sink(2, 3, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 4, rules.Kind.BRIDGE, 1, rules.Kind.KILN, 1]),
		"quota": kv([rules.Mat.INGOT, 24, rules.Mat.PLATE, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.BRIDGE, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.SOUTH),
		],
	}


static func seam() -> Dictionary:
	var rules = Rules
	# One belt. The plate lane needs it, so the kiln has to touch the bridge.
	return {
		"id": 19,
		"name": "Seam",
		"blurb": "The tray has one belt. Spend it on the plates, and set the kiln against the bridge.",
		"rule": "The tray pays for one belt. The plate bin needs that belt, so nothing is left to stand between the bridge and the kiln. The kiln still takes ore only from behind.",
		"w": 4,
		"h": 4,
		"sources": [
			source(0, 1, rules.Dir.EAST, [rules.Mat.ORE], 2),
			source(1, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(3, 1, [rules.Mat.INGOT]),
			sink(1, 3, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 1, rules.Kind.BRIDGE, 1, rules.Kind.KILN, 1]),
		"quota": kv([rules.Mat.INGOT, 24, rules.Mat.PLATE, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BRIDGE, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 1, 2, rules.Dir.SOUTH),
		],
	}


static func skew() -> Dictionary:
	var rules = Rules
	# The only bridge starts off the crossing. The lane has no spare cell for it.
	return {
		"id": 20,
		"name": "Skew",
		"blurb": "That bridge is off the crossing. Pick it up and seat it where the lanes meet.",
		"rule": "Pickup returns a piece to the tray, including this bridge. It has to sit on the crossing, forward along the ingots and open to the plates on its left. The cell it starts on is not on the route.",
		"w": 5,
		"h": 5,
		"sources": [
			source(0, 1, rules.Dir.EAST, [rules.Mat.INGOT], 2),
			source(2, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(4, 1, [rules.Mat.INGOT]),
			sink(2, 4, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 4, rules.Kind.BRIDGE, 1]),
		"quota": kv([rules.Mat.INGOT, 36, rules.Mat.PLATE, 36]),
		"initial": [
			piece(rules.Kind.BRIDGE, 1, 0, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.BRIDGE, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.SOUTH),
		],
	}


static func bend() -> Dictionary:
	var rules = Rules
	# The plate source cannot drop straight onto the bridge. The belts have to turn.
	return {
		"id": 21,
		"name": "Bend",
		"blurb": "A wall closes the straight drop. Turn the plates into the bridge's left side.",
		"rule": "Walls and empty floor do not carry items. Plates have to turn south into the bridge's left side. The forward lane still accepts only from behind, so the ingot belts must face the bridge.",
		"w": 6,
		"h": 4,
		"sources": [
			source(0, 0, rules.Dir.EAST, [rules.Mat.PLATE], 2),
			source(0, 2, rules.Dir.EAST, [rules.Mat.INGOT], 2),
		],
		"sinks": [
			sink(5, 2, [rules.Mat.INGOT]),
			sink(3, 3, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(0, 1), cell(1, 1), cell(2, 1)],
		"budget": kv([rules.Kind.BELT, 7, rules.Kind.BRIDGE, 1]),
		"quota": kv([rules.Mat.INGOT, 36, rules.Mat.PLATE, 24]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 0, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.BRIDGE, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.EAST),
		],
	}


static func brim() -> Dictionary:
	var rules = Rules
	# Period 1 ore is faster than one kiln. Plates cross before the weir and must stay there.
	return {
		"id": 22,
		"name": "Brim",
		"blurb": "Plates stay on the cross. Spill the extra ore into a second kiln or the quota is short.",
		"rule": "The bridge keeps plates out of the ore. The weir fills the forward kiln and spills the rest to the right. One kiln cannot reach the ingot quota. A spill does not change the next item's preference.",
		"w": 8,
		"h": 3,
		"sources": [
			source(0, 1, rules.Dir.EAST, [rules.Mat.ORE], 1),
			source(2, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(7, 1, [rules.Mat.INGOT]),
			sink(7, 2, [rules.Mat.INGOT]),
			sink(2, 2, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 5,
			rules.Kind.BRIDGE, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.KILN, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 70, rules.Mat.PLATE, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.BRIDGE, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 2, rules.Dir.EAST),
		],
	}


static func sift() -> Dictionary:
	var rules = Rules
	# Mixed ore and ingots. The filter scraps ingots, then plates cross the ore lane.
	return {
		"id": 23,
		"name": "Sift",
		"blurb": "Scrap the raw ingots, smelt the ore, and let the plates cross on the bridge.",
		"rule": "Ore leaves the filter forward into the bridge and the kiln. Ingots leave the filter to the right and fall into the waste chute. Plates cross the bridge and are not smelted. A raw ingot against the kiln stops the ore.",
		"w": 8,
		"h": 4,
		"sources": [
			source(0, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.INGOT], 2),
			source(4, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(7, 1, [rules.Mat.INGOT]),
			sink(4, 3, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.FILTER, 1,
			rules.Kind.BRIDGE, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 12, rules.Mat.PLATE, 24]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BRIDGE, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.SOUTH),
		],
	}


static func ledger() -> Dictionary:
	var rules = Rules
	# Crossing plates are too few on their own. Pressed plates are too few on their own.
	# The ingot bin still has to receive the splitter's forward half.
	return {
		"id": 24,
		"name": "Ledger",
		"blurb": "Cross the plates, then split the kiln. The bins want ingots and more plates than either line can make alone.",
		"rule": "The bridge carries plates to their bin while ore goes to the kiln. The splitter alternates ingots forward to the ingot bin and right through the press. Crossing plates alone miss the plate quota, and pressing every ingot misses the ingot bin.",
		"w": 7,
		"h": 4,
		"sources": [
			source(0, 1, rules.Dir.EAST, [rules.Mat.ORE], 2),
			source(2, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 4),
		],
		"sinks": [
			sink(6, 1, [rules.Mat.INGOT]),
			sink(6, 2, [rules.Mat.PLATE]),
			sink(2, 3, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.BRIDGE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 16, rules.Mat.PLATE, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.BRIDGE, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 5, 2, rules.Dir.EAST),
		],
	}


static func screen() -> Dictionary:
	var rules = Rules
	# Plates and ingots share one line. Only the grate parts them.
	# A belt on the split takes the ingot into the plate bin and stalls.
	return {
		"id": 25,
		"name": "Screen",
		"blurb": "The grate sends plates forward and turns ingots out to the right.",
		"rule": "A grate holds one item and accepts it only from behind. Plates leave forward. Ore and ingots leave to the right. A blocked exit waits, and a belt on that cell lets the ingot stall the plate bin.",
		"w": 5,
		"h": 4,
		"sources": [source(0, 1, rules.Dir.EAST, [rules.Mat.PLATE, rules.Mat.INGOT], 2)],
		"sinks": [
			sink(4, 1, [rules.Mat.PLATE]),
			sink(2, 3, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 24, rules.Mat.INGOT, 24]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.SOUTH),
		],
	}


static func temper() -> Dictionary:
	var rules = Rules
	# Plates stay on the forward lane. Ore turns off the grate into a kiln.
	return {
		"id": 26,
		"name": "Temper",
		"blurb": "Send the plates on, and smelt the ore that turns off the grate.",
		"rule": "Plates leave the grate forward into their bin. Ore leaves to the right and into the kiln. The kiln refuses plates, so a shared belt stalls both quotas.",
		"w": 6,
		"h": 4,
		"sources": [source(0, 1, rules.Dir.EAST, [rules.Mat.PLATE, rules.Mat.ORE], 2)],
		"sinks": [
			sink(5, 1, [rules.Mat.PLATE]),
			sink(3, 3, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 4, rules.Kind.GRATE, 1, rules.Kind.KILN, 1]),
		"quota": kv([rules.Mat.PLATE, 24, rules.Mat.INGOT, 20]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.EAST),
		],
	}


static func crimp() -> Dictionary:
	var rules = Rules
	# One belt. The plate sink is one cell past the grate, so the belt has to
	# sit there. The kiln touches the grate. The other drop is a waste pit.
	return {
		"id": 27,
		"name": "Crimp",
		"blurb": "The tray has one belt. Spend it on the plates and set the kiln against the grate.",
		"rule": "Plates need that belt to reach the bin. Ore leaves to the right into the kiln. The pit beside the kiln is the wrong drop: ore that falls in is gone, and the kiln never sees it.",
		"w": 4,
		"h": 4,
		"sources": [source(0, 1, rules.Dir.EAST, [rules.Mat.PLATE, rules.Mat.ORE], 2)],
		"sinks": [
			sink(3, 1, [rules.Mat.PLATE]),
			sink(1, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 2)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 1, rules.Kind.GRATE, 1, rules.Kind.KILN, 1]),
		"quota": kv([rules.Mat.PLATE, 24, rules.Mat.INGOT, 20]),
		"initial": [],
		"solution": [
			piece(rules.Kind.GRATE, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 2, rules.Dir.SOUTH),
		],
	}


static func cant() -> Dictionary:
	var rules = Rules
	# The only grate starts off the split. The lane has no spare cell for it.
	return {
		"id": 28,
		"name": "Cant",
		"blurb": "That grate is off the split. Pick it up and seat it where the line divides.",
		"rule": "Pickup returns a piece to the tray, including this grate. It has to face the plates, with ingots leaving to its right. The cell it starts on is not on the route.",
		"w": 5,
		"h": 4,
		"sources": [source(0, 1, rules.Dir.EAST, [rules.Mat.PLATE, rules.Mat.INGOT], 2)],
		"sinks": [
			sink(4, 1, [rules.Mat.PLATE]),
			sink(2, 3, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 24, rules.Mat.INGOT, 24]),
		"initial": [
			piece(rules.Kind.GRATE, 1, 0, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.SOUTH),
		],
	}


static func jink() -> Dictionary:
	var rules = Rules
	# The cell south of a naive early drop is walled. Ingots have to fall
	# through the one open cell and turn east.
	return {
		"id": 29,
		"name": "Jink",
		"blurb": "A wall closes the straight drop. Turn the ingots out of the grate's right side.",
		"rule": "Plates leave the grate forward. Ingots leave to the right and have to turn east under the wall. A belt that keeps going south runs off the route and delivers no ingot.",
		"w": 6,
		"h": 3,
		"sources": [source(0, 0, rules.Dir.EAST, [rules.Mat.PLATE, rules.Mat.INGOT], 2)],
		"sinks": [
			sink(5, 0, [rules.Mat.PLATE]),
			sink(5, 2, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [cell(0, 1), cell(1, 1), cell(2, 1), cell(4, 1)],
		"budget": kv([rules.Kind.BELT, 6, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 24, rules.Mat.INGOT, 20]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 0, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 3, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.EAST),
		],
	}


static func charge() -> Dictionary:
	var rules = Rules
	# Two ores then a plate, every tick. The grate peels plates. The ore that
	# remains is still faster than one kiln.
	return {
		"id": 30,
		"name": "Charge",
		"blurb": "Peel the plates off, then spill the extra ore into a second kiln.",
		"rule": "The grate keeps plates out of the ore. The weir fills the forward kiln and spills the rest to the right. One kiln cannot reach the ingot quota.",
		"w": 7,
		"h": 3,
		"sources": [source(0, 0, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.ORE, rules.Mat.PLATE], 1)],
		"sinks": [
			sink(5, 0, [rules.Mat.PLATE]),
			sink(5, 1, [rules.Mat.INGOT]),
			sink(5, 2, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 5,
			rules.Kind.GRATE, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.KILN, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 70, rules.Mat.PLATE, 24]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 0, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 2, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 2, rules.Dir.EAST),
		],
	}


static func clarify() -> Dictionary:
	var rules = Rules
	# Three materials. The filter takes ore to the kiln. The grate parts the metals.
	# Raw ingots alone, or kiln ingots alone, miss the ingot quota.
	return {
		"id": 31,
		"name": "Clarify",
		"blurb": "Filter the ore into the kiln, then grate the metals into plates and ingots.",
		"rule": "Ore leaves the filter forward and is smelted. Ingots and plates leave the filter to the right. The grate sends those plates forward and the raw ingots to its right. Neither line of ingots is enough alone.",
		"w": 6,
		"h": 5,
		"sources": [source(0, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.INGOT, rules.Mat.PLATE], 2)],
		"sinks": [
			sink(5, 1, [rules.Mat.INGOT]),
			sink(5, 3, [rules.Mat.PLATE]),
			sink(4, 4, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 6,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
			rules.Kind.GRATE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 30, rules.Mat.PLATE, 14]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 4, rules.Dir.EAST),
		],
	}


static func reckon() -> Dictionary:
	var rules = Rules
	# Plates leave the grate forward. Ore turns off to the right, into the kiln.
	# Peeled plates are short of the plate quota. Pressing every ingot misses the ingot bin.
	return {
		"id": 32,
		"name": "Reckon",
		"blurb": "Grate the plates aside, then split the kiln between the ingot bin and the press.",
		"rule": "Plates leave the grate forward and are not enough on their own. Ore turns off to the right, into the kiln. The splitter alternates ingots to the ingot bin and the press. Pressing every ingot misses the ingot bin.",
		"w": 7,
		"h": 4,
		"sources": [source(0, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 2)],
		"sinks": [
			sink(4, 1, [rules.Mat.PLATE]),
			sink(6, 2, [rules.Mat.INGOT]),
			sink(6, 3, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 5,
			rules.Kind.GRATE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 10, rules.Mat.PLATE, 32]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 5, 3, rules.Dir.EAST),
		],
	}


static func veer() -> Dictionary:
	var rules = Rules
	# Ingots have to turn left. A plate pushes into the front of that cell.
	# A belt facing the bin takes the plate and the ingot sink refuses it.
	return {
		"id": 33,
		"name": "Veer",
		"blurb": "The hook turns ingots to its left. A belt on that cell takes the plate and stalls.",
		"rule": "A hook holds one item and takes it only from behind. It sends that item left and does not send forward. A belt on that cell takes the plate, and the ingot bin refuses it.",
		"w": 4,
		"h": 2,
		"sources": [
			source(0, 1, rules.Dir.EAST, [rules.Mat.INGOT], 2),
			source(3, 1, rules.Dir.WEST, [rules.Mat.PLATE], 2),
		],
		"sinks": [sink(3, 0, [rules.Mat.INGOT])],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 2, rules.Kind.HOOK, 1]),
		"quota": kv([rules.Mat.INGOT, 40]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.HOOK, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 0, rules.Dir.EAST),
		],
	}


static func draw() -> Dictionary:
	var rules = Rules
	# Ore turns left into the kiln. The plate on the hook's front stalls a belt.
	return {
		"id": 34,
		"name": "Draw",
		"blurb": "Turn the ore left into the kiln. A belt on that cell lets the plate stall the smelt.",
		"rule": "The hook sends ore left into the kiln and refuses the plate in front of it. A belt facing the kiln takes that plate, and the kiln will not smelt it.",
		"w": 4,
		"h": 3,
		"sources": [
			source(0, 2, rules.Dir.EAST, [rules.Mat.ORE], 2),
			source(3, 2, rules.Dir.WEST, [rules.Mat.PLATE], 2),
		],
		"sinks": [sink(3, 0, [rules.Mat.INGOT])],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 2, rules.Kind.HOOK, 1, rules.Kind.KILN, 1]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.HOOK, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 0, rules.Dir.EAST),
		],
	}


static func nip() -> Dictionary:
	var rules = Rules
	# One belt. It has to sit between the kiln and the bin. A belt on the
	# hook's cell runs ore east into the pit, and the plate below stalls a turn.
	return {
		"id": 35,
		"name": "Nip",
		"blurb": "The tray has one belt. Spend it above the kiln, and turn the ore with the hook.",
		"rule": "The hook turns ore left into the kiln and refuses the plate under it. Spend the one belt between the kiln and the bin. A belt on the hook's cell dumps the ore into the pit.",
		"w": 3,
		"h": 5,
		"sources": [
			source(0, 3, rules.Dir.EAST, [rules.Mat.ORE], 2),
			source(1, 4, rules.Dir.NORTH, [rules.Mat.PLATE], 2),
		],
		"sinks": [sink(1, 0, [rules.Mat.INGOT])],
		"chutes": [cell(2, 3)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 1, rules.Kind.HOOK, 1, rules.Kind.KILN, 1]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HOOK, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 1, 1, rules.Dir.NORTH),
		],
	}


static func slue() -> Dictionary:
	var rules = Rules
	# The only hook starts off the turn. The lane has no spare cell for it.
	return {
		"id": 36,
		"name": "Slue",
		"blurb": "That hook is off the turn. Pick it up and seat it where the ingots have to veer.",
		"rule": "Pickup puts this hook back on the tray. Face it along the ingots so they leave to its left. A belt on that cell takes the plate. It starts off the route.",
		"w": 5,
		"h": 2,
		"sources": [
			source(0, 1, rules.Dir.EAST, [rules.Mat.INGOT], 2),
			source(4, 1, rules.Dir.WEST, [rules.Mat.PLATE], 2),
		],
		"sinks": [sink(4, 0, [rules.Mat.INGOT])],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.HOOK, 1]),
		"quota": kv([rules.Mat.INGOT, 40]),
		"initial": [
			piece(rules.Kind.HOOK, 0, 0, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.HOOK, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 0, rules.Dir.EAST),
		],
	}


static func jibe() -> Dictionary:
	var rules = Rules
	# The straight south drop is walled. Ingots come around into the hook's
	# back, and the hook turns them left into the bin.
	return {
		"id": 37,
		"name": "Jibe",
		"blurb": "A wall closes the straight drop. Bring the ingots in from behind the hook.",
		"rule": "The wall blocks a straight drop. Bring the ingots around into the back of the hook. It sends them left into the bin and refuses the plate beside it.",
		"w": 6,
		"h": 3,
		"sources": [
			source(0, 0, rules.Dir.EAST, [rules.Mat.INGOT], 2),
			source(3, 2, rules.Dir.EAST, [rules.Mat.PLATE], 2),
		],
		"sinks": [sink(5, 2, [rules.Mat.INGOT])],
		"chutes": [],
		"walls": [cell(0, 1), cell(1, 1), cell(2, 1), cell(3, 1)],
		"budget": kv([rules.Kind.BELT, 5, rules.Kind.HOOK, 1]),
		"quota": kv([rules.Mat.INGOT, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 0, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.SOUTH),
			piece(rules.Kind.HOOK, 4, 2, rules.Dir.SOUTH),
		],
	}


static func spate() -> Dictionary:
	var rules = Rules
	# Period 1 ore is faster than one kiln. The hook turns it onto the weir
	# and refuses the plate on its front.
	return {
		"id": 38,
		"name": "Spate",
		"blurb": "Turn the ore onto the weir, then spill the extra into a second kiln.",
		"rule": "The hook turns ore left onto the weir and refuses the plate in front of it. The weir fills the forward kiln and spills the rest right. One kiln cannot reach the quota.",
		"w": 4,
		"h": 5,
		"sources": [
			source(0, 4, rules.Dir.EAST, [rules.Mat.ORE], 1),
			source(3, 4, rules.Dir.WEST, [rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 0, [rules.Mat.INGOT]),
			sink(3, 0, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.HOOK, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.KILN, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 70]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 4, rules.Dir.EAST),
			piece(rules.Kind.HOOK, 2, 4, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.NORTH),
		],
	}


static func winnow() -> Dictionary:
	var rules = Rules
	# The filter scraps ingots. Ore continues into the hook and turns left
	# into the kiln. A plate on the hook's front stalls a belt.
	return {
		"id": 39,
		"name": "Winnow",
		"blurb": "Scrap the raw ingots, then hook the ore left into the kiln.",
		"rule": "Ore leaves the filter forward and ingots fall into the pit. The hook turns that ore left into the kiln. A raw ingot or a plate against the kiln stops the line.",
		"w": 5,
		"h": 4,
		"sources": [
			source(0, 2, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.INGOT], 2),
			source(4, 2, rules.Dir.WEST, [rules.Mat.PLATE], 2),
		],
		"sinks": [sink(4, 0, [rules.Mat.INGOT])],
		"chutes": [cell(2, 3)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 2,
			rules.Kind.FILTER, 1,
			rules.Kind.HOOK, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 18]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.HOOK, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 3, 0, rules.Dir.EAST),
		],
	}


static func tally() -> Dictionary:
	var rules = Rules
	# Upper plates are short of the plate quota. Pressing every ingot misses
	# the ingot bin. The hook is what gets ore into the kiln without the plate.
	return {
		"id": 40,
		"name": "Tally",
		"blurb": "Hook the ore into the kiln, then split ingots between the bin and the press.",
		"rule": "The hook turns ore left into the kiln and keeps the lower plate off that lane. The upper plates are not enough alone. Split the ingots between the bin and the press.",
		"w": 6,
		"h": 4,
		"sources": [
			source(0, 0, rules.Dir.EAST, [rules.Mat.PLATE], 4),
			source(1, 1, rules.Dir.SOUTH, [rules.Mat.ORE], 2),
			source(1, 3, rules.Dir.NORTH, [rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(3, 0, [rules.Mat.PLATE]),
			sink(5, 2, [rules.Mat.INGOT]),
			sink(5, 3, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.HOOK, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 12, rules.Mat.PLATE, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 0, rules.Dir.EAST),
			piece(rules.Kind.HOOK, 1, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 4, 3, rules.Dir.EAST),
		],
	}
