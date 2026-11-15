extends RefCounted

## Kiln Route rooms. Wing 1 is the first eight. Wing 2 is rooms 9-16.
## Wing 3 is rooms 17-24. Wing 4 is rooms 25-32. Wing 5 is rooms 33-40.
## Wing 6 is rooms 41-48. Wing 7 is rooms 49-56. Wing 8 is rooms 57-64.
## Wing 9 is rooms 65-72. Wing 10 is rooms 73-80. Wing 11 is rooms 81-88.
## Wing 12 is rooms 89-96. Wing 13 is rooms 97-104.
## Wing 14 is rooms 105-112.
## Wing 15 is rooms 113-120.
## Wing 16 is rooms 121-128.
## Wing 17 is rooms 129-136.
## Wing 18 is rooms 137-144.
## The dwell is taught before a later room depends on it.
## The twin is taught before a later room depends on it.
## The pass is taught before a later room depends on it.
## The slip is taught before a later room depends on it.
## The shed is taught before a later room depends on it.
## The rake is taught before a later room depends on it.
## The hoe is taught before a later room depends on it.
## The harrow is taught before a later room depends on it.
## The fork is taught before a later room depends on it.
## The prong is taught before a later room depends on it.
## The roller, the weir, the bridge, the grate, the hook, the arm, the drop, the lift, the dwell, the twin, the pass, the slip, the shed, the rake, the hoe, the harrow, the fork, and the prong are taught before a later room depends on them.
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
		reach(),
		feed(),
		clip(),
		heft(),
		sweep(),
		surge(),
		cull(),
		audit(),
		fall(),
		pour(),
		pare(),
		perch(),
		skirt(),
		gush(),
		rake(),
		yield_room(),
		hoist(),
		raise_room(),
		cinch(),
		sling(),
		flank(),
		spurt(),
		glean(),
		remit(),
		pause_lane(),
		bank(),
		stint(),
		late_room(),
		bend_back(),
		second_heat(),
		scrap_room(),
		both_bins(),
		pair_room(),
		match_room(),
		stint_pair(),
		late_pair(),
		bend_pair(),
		second_heat_pair(),
		after_scrap(),
		both_bins_pair(),
		pair_pass(),
		match_pass(),
		stint_pass(),
		late_pass(),
		bend_pass(),
		second_heat_pass(),
		after_scrap_pass(),
		both_bins_pass(),
		hold_slip(),
		keep_slip(),
		still_slip(),
		seat_slip(),
		turn_slip(),
		spare_heat_slip(),
		after_hold_slip(),
		one_bin_slip(),
		aside_shed(),
		keep_left_shed(),
		still_left_shed(),
		seat_shed(),
		corner_shed(),
		left_heat_shed(),
		after_stay_shed(),
		side_bin_shed(),
		draw_left(),
		push_ore(),
		still_rake(),
		seat_rake(),
		corner_rake(),
		left_heat_rake(),
		after_push(),
		side_bin_rake(),
		draw_right(),
		push_ore_hoe(),
		still_hoe(),
		seat_hoe(),
		corner_hoe(),
		right_heat(),
		after_push_hoe(),
		side_bin_hoe(),
		late_draw(),
		second_ore(),
		still_harrow(),
		seat_harrow(),
		late_corner(),
		arrival_heat(),
		after_stay_harrow(),
		late_bin(),
		both_ways(),
		split_ore(),
		still_fork(),
		seat_fork(),
		split_corner(),
		two_heats(),
		after_split(),
		split_bin(),
		both_ways_prong(),
		split_ore_prong(),
		still_prong(),
		seat_prong(),
		split_corner_prong(),
		two_heats_prong(),
		after_split_prong(),
		split_bin_prong(),
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


static func reach() -> Dictionary:
	var rules = Rules
	# Plates have to come in from the left and leave forward.
	# Ore pushes into the back of that cell. A belt takes the ore, and the plate bin refuses it.
	return {
		"id": 41,
		"name": "Reach",
		"blurb": "The arm takes plates from its left and sends them on. A belt on that cell takes the ore and stalls.",
		"rule": "An arm holds one item and takes it only from the left. It sends that item forward and does not send left. A belt on that cell takes the ore from behind, and the plate bin refuses it.",
		"w": 4,
		"h": 2,
		"sources": [
			source(1, 1, rules.Dir.EAST, [rules.Mat.ORE], 2),
			source(0, 0, rules.Dir.EAST, [rules.Mat.PLATE], 2),
		],
		"sinks": [sink(3, 1, [rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 2, rules.Kind.ARM, 1]),
		"quota": kv([rules.Mat.PLATE, 40]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 0, rules.Dir.SOUTH),
			piece(rules.Kind.ARM, 2, 1, rules.Dir.EAST),
		],
	}


static func feed() -> Dictionary:
	var rules = Rules
	# Ore comes from the left into the kiln. The plate behind a belt stalls the smelt.
	return {
		"id": 42,
		"name": "Feed",
		"blurb": "Take the ore from the left into the kiln. A belt on that cell lets the plate stall the smelt.",
		"rule": "The arm takes ore from its left and sends it forward into the kiln. It refuses the plate behind it. A belt facing the kiln takes that plate, and the kiln will not smelt it.",
		"w": 6,
		"h": 2,
		"sources": [
			source(0, 1, rules.Dir.EAST, [rules.Mat.PLATE], 2),
			source(1, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 2),
		],
		"sinks": [sink(5, 1, [rules.Mat.INGOT])],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 2, rules.Kind.ARM, 1, rules.Kind.KILN, 1]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.ARM, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
		],
	}


static func clip() -> Dictionary:
	var rules = Rules
	# One belt. It has to sit between the kiln and the bin. A belt on the
	# arm's cell runs ore east into the pit, and the plate behind stalls a turn.
	return {
		"id": 43,
		"name": "Clip",
		"blurb": "The tray has one belt. Spend it above the kiln, and take the ore with the arm.",
		"rule": "The arm takes ore from its left and sends it forward into the kiln. It refuses the plate behind it. Spend the one belt between the kiln and the bin. A belt on the arm's cell dumps the ore into the pit.",
		"w": 3,
		"h": 5,
		"sources": [
			source(0, 3, rules.Dir.EAST, [rules.Mat.ORE], 2),
			source(1, 4, rules.Dir.NORTH, [rules.Mat.PLATE], 2),
		],
		"sinks": [sink(1, 0, [rules.Mat.INGOT])],
		"chutes": [cell(2, 3)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 1, rules.Kind.ARM, 1, rules.Kind.KILN, 1]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.ARM, 1, 3, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 1, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 1, 1, rules.Dir.NORTH),
		],
	}


static func heft() -> Dictionary:
	var rules = Rules
	# The only arm starts off the lane. The route has no spare cell for it.
	return {
		"id": 44,
		"name": "Heft",
		"blurb": "That arm is off the lane. Pick it up and seat it where the plates come in from the left.",
		"rule": "Pickup puts this arm back on the tray. It takes plates from the left and sends them forward. A belt on that cell takes the ore. It starts off the route.",
		"w": 5,
		"h": 2,
		"sources": [
			source(2, 1, rules.Dir.EAST, [rules.Mat.ORE], 2),
			source(0, 0, rules.Dir.EAST, [rules.Mat.PLATE], 2),
		],
		"sinks": [sink(4, 1, [rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.ARM, 1]),
		"quota": kv([rules.Mat.PLATE, 40]),
		"initial": [
			piece(rules.Kind.ARM, 0, 1, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.BELT, 1, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 0, rules.Dir.SOUTH),
			piece(rules.Kind.ARM, 3, 1, rules.Dir.EAST),
		],
	}


static func sweep() -> Dictionary:
	var rules = Rules
	# The straight south drop is walled. Plates come around into the arm's
	# left side, and the arm sends them forward. Ore behind a belt stalls the bin.
	return {
		"id": 45,
		"name": "Sweep",
		"blurb": "A wall closes the straight drop. Bring the plates in from the arm's left.",
		"rule": "The wall blocks a straight drop. Bring the plates around into the left side of the arm. It sends them forward and refuses the ore behind it. A belt on that cell takes the ore.",
		"w": 6,
		"h": 3,
		"sources": [
			source(0, 0, rules.Dir.EAST, [rules.Mat.PLATE], 2),
			source(3, 2, rules.Dir.EAST, [rules.Mat.ORE], 2),
		],
		"sinks": [sink(5, 2, [rules.Mat.PLATE])],
		"chutes": [],
		"walls": [cell(0, 1), cell(1, 1), cell(2, 1), cell(3, 1)],
		"budget": kv([rules.Kind.BELT, 5, rules.Kind.ARM, 1]),
		"quota": kv([rules.Mat.PLATE, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 0, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.SOUTH),
			piece(rules.Kind.ARM, 4, 2, rules.Dir.EAST),
		],
	}


static func surge() -> Dictionary:
	var rules = Rules
	# Period 1 ore is faster than one kiln. The arm takes it from the left
	# onto the weir and refuses the plate behind it.
	return {
		"id": 46,
		"name": "Surge",
		"blurb": "Take the ore from the left onto the weir, then spill the extra into a second kiln.",
		"rule": "The arm takes ore from its left and sends it forward onto the weir. It refuses the plate behind it. The weir fills the forward kiln and spills the rest right. One kiln cannot reach the quota.",
		"w": 4,
		"h": 6,
		"sources": [
			source(2, 5, rules.Dir.NORTH, [rules.Mat.PLATE], 2),
			source(0, 4, rules.Dir.EAST, [rules.Mat.ORE], 1),
		],
		"sinks": [
			sink(2, 0, [rules.Mat.INGOT]),
			sink(3, 0, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.ARM, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.KILN, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 70]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 4, rules.Dir.EAST),
			piece(rules.Kind.ARM, 2, 4, rules.Dir.NORTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.NORTH),
		],
	}


static func cull() -> Dictionary:
	var rules = Rules
	# The filter scraps ingots. Ore turns south into the arm's left side and
	# goes forward into the kiln. A plate on the arm's right stalls a belt.
	return {
		"id": 47,
		"name": "Cull",
		"blurb": "Scrap the raw ingots, then take the ore from the left into the kiln.",
		"rule": "Ore leaves the filter forward and ingots fall into the pit. The arm takes that ore from its left and sends it forward into the kiln. It refuses the plate on its right. A belt on that cell takes the plate, and the kiln will not smelt it.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 3, rules.Dir.NORTH, [rules.Mat.PLATE], 2),
			source(0, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.INGOT], 2),
		],
		"sinks": [sink(5, 2, [rules.Mat.INGOT])],
		"chutes": [cell(2, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 2,
			rules.Kind.FILTER, 1,
			rules.Kind.ARM, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 18]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.ARM, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 2, rules.Dir.EAST),
		],
	}


static func audit() -> Dictionary:
	var rules = Rules
	# Upper plates are short of the plate quota. Pressing every ingot misses
	# the ingot bin. The arm is what gets ore into the kiln without the plate.
	return {
		"id": 48,
		"name": "Audit",
		"blurb": "Take the ore from the left into the kiln, then split ingots between the bin and the press.",
		"rule": "The arm takes ore from its left and sends it forward into the kiln. It refuses the plate on its right. The upper plates are not enough alone. Split the ingots between the bin and the press.",
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
			rules.Kind.ARM, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 12, rules.Mat.PLATE, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 0, rules.Dir.EAST),
			piece(rules.Kind.ARM, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 4, 3, rules.Dir.EAST),
		],
	}


static func fall() -> Dictionary:
	var rules = Rules
	# Plates fall onto the face of a north-facing drop and leave to its right.
	# Ore pushes into the left of that cell. A belt takes the ore, and the plate bin refuses it.
	return {
		"id": 49,
		"name": "Fall",
		"blurb": "The drop takes plates from above and sends them right. A belt on that cell takes the ore and stalls.",
		"rule": "A drop holds one item and takes it only from above, the side it faces. It sends that item right and does not send forward. A belt on that cell takes the ore from the left, and the plate bin refuses it.",
		"w": 4,
		"h": 2,
		"sources": [
			source(1, 1, rules.Dir.EAST, [rules.Mat.ORE], 2),
			source(0, 0, rules.Dir.EAST, [rules.Mat.PLATE], 2),
		],
		"sinks": [sink(3, 1, [rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 2, rules.Kind.DROP, 1]),
		"quota": kv([rules.Mat.PLATE, 40]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 0, rules.Dir.SOUTH),
			piece(rules.Kind.DROP, 2, 1, rules.Dir.NORTH),
		],
	}


static func pour() -> Dictionary:
	var rules = Rules
	# Ore falls onto the drop and leaves right into the kiln. The plate on the left stalls a belt.
	return {
		"id": 50,
		"name": "Pour",
		"blurb": "Take the ore from above into the kiln. A belt on that cell lets the plate stall the smelt.",
		"rule": "The drop takes ore from above and sends it right into the kiln. It refuses the plate on its left. A belt facing the kiln takes that plate, and the kiln will not smelt it.",
		"w": 6,
		"h": 2,
		"sources": [
			source(0, 1, rules.Dir.EAST, [rules.Mat.PLATE], 2),
			source(1, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 2),
		],
		"sinks": [sink(5, 1, [rules.Mat.INGOT])],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 2, rules.Kind.DROP, 1, rules.Kind.KILN, 1]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.DROP, 1, 1, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
		],
	}


static func pare() -> Dictionary:
	var rules = Rules
	# One belt. It has to sit between the kiln and the bin. A belt on the
	# drop's cell runs ore east into the pit, and the plate on the left stalls a turn.
	return {
		"id": 51,
		"name": "Pare",
		"blurb": "The tray has one belt. Spend it above the kiln, and take the ore into the face of the drop.",
		"rule": "The drop takes ore from the side it faces and sends it right into the kiln. It refuses the plate on its left. Spend the one belt between the kiln and the bin. A belt on the drop's cell dumps the ore into the pit.",
		"w": 3,
		"h": 5,
		"sources": [
			source(0, 3, rules.Dir.EAST, [rules.Mat.ORE], 2),
			source(1, 4, rules.Dir.NORTH, [rules.Mat.PLATE], 2),
		],
		"sinks": [sink(1, 0, [rules.Mat.INGOT])],
		"chutes": [cell(2, 3)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 1, rules.Kind.DROP, 1, rules.Kind.KILN, 1]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.DROP, 1, 3, rules.Dir.WEST),
			piece(rules.Kind.KILN, 1, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 1, 1, rules.Dir.NORTH),
		],
	}


static func perch() -> Dictionary:
	var rules = Rules
	# The only drop starts off the lane, aimed the wrong way. The route has no spare cell for it.
	return {
		"id": 52,
		"name": "Perch",
		"blurb": "That drop is off the lane. Pick it up, point it north, and seat it where the plates come in from above.",
		"rule": "Pickup puts this drop back on the tray. Point it north so plates fall in from above and leave to the right. A belt on that cell takes the ore. It starts off the route.",
		"w": 5,
		"h": 2,
		"sources": [
			source(2, 1, rules.Dir.EAST, [rules.Mat.ORE], 2),
			source(0, 0, rules.Dir.EAST, [rules.Mat.PLATE], 2),
		],
		"sinks": [sink(4, 1, [rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.DROP, 1]),
		"quota": kv([rules.Mat.PLATE, 40]),
		"initial": [
			piece(rules.Kind.DROP, 0, 1, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.BELT, 1, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 0, rules.Dir.SOUTH),
			piece(rules.Kind.DROP, 3, 1, rules.Dir.NORTH),
		],
	}


static func skirt() -> Dictionary:
	var rules = Rules
	# The straight south run is walled. Plates come around onto the drop's face,
	# and the drop sends them right. Ore on the left stalls a belt.
	return {
		"id": 53,
		"name": "Skirt",
		"blurb": "A wall closes the straight lane. Bring the plates in from above the drop.",
		"rule": "The wall blocks a straight lane. Bring the plates around onto the face of the drop. It sends them right and refuses the ore on its left. A belt on that cell takes the ore.",
		"w": 6,
		"h": 3,
		"sources": [
			source(0, 0, rules.Dir.EAST, [rules.Mat.PLATE], 2),
			source(3, 2, rules.Dir.EAST, [rules.Mat.ORE], 2),
		],
		"sinks": [sink(5, 2, [rules.Mat.PLATE])],
		"chutes": [],
		"walls": [cell(0, 1), cell(1, 1), cell(2, 1), cell(3, 1)],
		"budget": kv([rules.Kind.BELT, 5, rules.Kind.DROP, 1]),
		"quota": kv([rules.Mat.PLATE, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 0, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.SOUTH),
			piece(rules.Kind.DROP, 4, 2, rules.Dir.NORTH),
		],
	}


static func gush() -> Dictionary:
	var rules = Rules
	# Period 1 ore is faster than one kiln. The drop takes it from the face
	# and sends it right onto the weir. The plate on the left stalls a belt.
	return {
		"id": 54,
		"name": "Gush",
		"blurb": "Take the ore into the face of the drop and onto the weir, then spill the extra into a second kiln.",
		"rule": "The drop takes ore from the side it faces and sends it right onto the weir. It refuses the plate on its left. The weir fills the forward kiln and spills the rest right. One kiln cannot reach the quota. A belt on the drop's cell takes the plate.",
		"w": 4,
		"h": 6,
		"sources": [
			source(2, 5, rules.Dir.NORTH, [rules.Mat.PLATE], 2),
			source(0, 4, rules.Dir.EAST, [rules.Mat.ORE], 1),
		],
		"sinks": [
			sink(2, 0, [rules.Mat.INGOT]),
			sink(3, 0, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.DROP, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.KILN, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 70]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 4, rules.Dir.EAST),
			piece(rules.Kind.DROP, 2, 4, rules.Dir.WEST),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.NORTH),
		],
	}


static func rake() -> Dictionary:
	var rules = Rules
	# The filter scraps ingots. Ore turns south onto the drop's face and
	# goes right into the kiln. A plate behind the drop stalls a belt.
	return {
		"id": 55,
		"name": "Rake",
		"blurb": "Scrap the raw ingots, then take the ore from above into the kiln.",
		"rule": "Ore leaves the filter forward and ingots fall into the pit. The drop takes that ore from above and sends it right into the kiln. It refuses the plate behind it. A belt on that cell takes the plate, and the kiln will not smelt it.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 3, rules.Dir.NORTH, [rules.Mat.PLATE], 2),
			source(0, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.INGOT], 2),
		],
		"sinks": [sink(5, 2, [rules.Mat.INGOT])],
		"chutes": [cell(2, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 2,
			rules.Kind.FILTER, 1,
			rules.Kind.DROP, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 18]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.DROP, 3, 2, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 4, 2, rules.Dir.EAST),
		],
	}


static func yield_room() -> Dictionary:
	var rules = Rules
	# Upper plates are short of the plate quota. Pressing every ingot misses
	# the ingot bin. The drop is what gets ore into the kiln without the plate.
	return {
		"id": 56,
		"name": "Yield",
		"blurb": "Take the ore from above into the kiln, then split ingots between the bin and the press.",
		"rule": "The drop takes ore from above and sends it right into the kiln. It refuses the plate behind it. The upper plates are not enough alone. Split the ingots between the bin and the press. Pressing every ingot misses the ingot bin.",
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
			rules.Kind.DROP, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 12, rules.Mat.PLATE, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 0, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 0, rules.Dir.EAST),
			piece(rules.Kind.DROP, 1, 2, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 4, 3, rules.Dir.EAST),
		],
	}


static func hoist() -> Dictionary:
	var rules = Rules
	# Plates rise into an east-facing lift and leave back to the west.
	# Ore pushes down from above. A belt takes that ore, and the plate bin refuses it.
	return {
		"id": 57,
		"name": "Hoist",
		"blurb": "The lift takes plates from below and sends them back. A belt on that cell takes the ore and stalls.",
		"rule": "A lift holds one item and takes it only from below. Pointed east, below is the south cell, and it sends that item back to the west. It does not take the ore from above and it does not send right. A belt on that cell takes the ore, and the plate bin refuses it.",
		"w": 3,
		"h": 3,
		"sources": [
			source(0, 2, rules.Dir.EAST, [rules.Mat.PLATE], 2),
			source(2, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 2),
		],
		"sinks": [sink(1, 1, [rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 2, rules.Kind.LIFT, 1]),
		"quota": kv([rules.Mat.PLATE, 40]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.NORTH),
			piece(rules.Kind.LIFT, 2, 1, rules.Dir.EAST),
		],
	}


static func raise_room() -> Dictionary:
	var rules = Rules
	# Ore rises into the lift and leaves back into the kiln. The plate from above stalls a belt.
	return {
		"id": 58,
		"name": "Raise",
		"blurb": "Take the ore from below into the kiln. A belt on that cell lets the plate stall the smelt.",
		"rule": "The lift takes ore from below and sends it back into the kiln. It refuses the plate from above. A belt facing the kiln takes that plate, and the kiln will not smelt it.",
		"w": 5,
		"h": 3,
		"sources": [
			source(4, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 2),
			source(4, 2, rules.Dir.NORTH, [rules.Mat.ORE], 2),
		],
		"sinks": [sink(0, 1, [rules.Mat.INGOT])],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 2, rules.Kind.LIFT, 1, rules.Kind.KILN, 1]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.WEST),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.WEST),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.WEST),
			piece(rules.Kind.LIFT, 4, 1, rules.Dir.EAST),
		],
	}


static func cinch() -> Dictionary:
	var rules = Rules
	# One belt. It has to sit between the kiln and the bin. A belt on the
	# lift's cell runs ore east into the pit, and the plate from above stalls a turn.
	return {
		"id": 59,
		"name": "Cinch",
		"blurb": "The tray has one belt. Spend it after the kiln, and take the ore into the lift from below.",
		"rule": "The lift takes ore from below and sends it back into the kiln. It refuses the plate from above. Spend the one belt between the kiln and the bin. A belt on the lift's cell dumps the ore into the pit.",
		"w": 5,
		"h": 3,
		"sources": [
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 2),
			source(3, 2, rules.Dir.NORTH, [rules.Mat.ORE], 2),
		],
		"sinks": [sink(0, 1, [rules.Mat.INGOT])],
		"chutes": [cell(4, 1)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 1, rules.Kind.LIFT, 1, rules.Kind.KILN, 1]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.WEST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.WEST),
			piece(rules.Kind.LIFT, 3, 1, rules.Dir.EAST),
		],
	}


static func sling() -> Dictionary:
	var rules = Rules
	# The only lift starts off the lane, aimed the wrong way. The route has no spare cell for it.
	return {
		"id": 60,
		"name": "Sling",
		"blurb": "That lift is off the lane. Pick it up, point it east, and seat it where the plates come in from below.",
		"rule": "Pickup puts this lift back on the tray. Point it east so plates come in from below and leave back to the west. A belt on that cell takes the ore. It starts off the route.",
		"w": 4,
		"h": 3,
		"sources": [
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 2),
			source(0, 2, rules.Dir.EAST, [rules.Mat.PLATE], 2),
		],
		"sinks": [sink(2, 1, [rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.LIFT, 1]),
		"quota": kv([rules.Mat.PLATE, 40]),
		"initial": [
			piece(rules.Kind.LIFT, 0, 1, rules.Dir.NORTH),
		],
		"solution": [
			piece(rules.Kind.BELT, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.NORTH),
			piece(rules.Kind.LIFT, 3, 1, rules.Dir.EAST),
		],
	}


static func flank() -> Dictionary:
	var rules = Rules
	# The straight north run is walled. Plates come around under the lift,
	# and the lift sends them back. Ore from above stalls a belt.
	return {
		"id": 61,
		"name": "Flank",
		"blurb": "A wall closes the straight lane. Bring the plates in from below the lift.",
		"rule": "The wall blocks a straight lane. Bring the plates around to the south side of the lift. It sends them back and refuses the ore from above. A belt that turns north into the wall delivers nothing. A belt on the lift's cell takes the ore.",
		"w": 5,
		"h": 4,
		"sources": [
			source(0, 3, rules.Dir.EAST, [rules.Mat.PLATE], 2),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 2),
		],
		"sinks": [sink(2, 1, [rules.Mat.PLATE])],
		"chutes": [],
		"walls": [cell(0, 2), cell(1, 2), cell(2, 2)],
		"budget": kv([rules.Kind.BELT, 4, rules.Kind.LIFT, 1]),
		"quota": kv([rules.Mat.PLATE, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.NORTH),
			piece(rules.Kind.LIFT, 3, 1, rules.Dir.EAST),
		],
	}


static func spurt() -> Dictionary:
	var rules = Rules
	# Period 1 ore is faster than one kiln. The lift takes it from below
	# and sends it back onto the weir. The plate from above stalls a belt.
	return {
		"id": 62,
		"name": "Spurt",
		"blurb": "Take the ore from below onto the weir, then spill the extra into a second kiln.",
		"rule": "The lift takes ore from below and sends it back onto the weir. It refuses the plate from above. The weir fills the forward kiln and spills the rest to its right. One kiln cannot reach the quota. A belt on the lift's cell takes the plate.",
		"w": 5,
		"h": 4,
		"sources": [
			source(4, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 2),
			source(4, 3, rules.Dir.NORTH, [rules.Mat.ORE], 1),
		],
		"sinks": [
			sink(0, 0, [rules.Mat.INGOT]),
			sink(0, 1, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.LIFT, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.KILN, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 70]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 0, rules.Dir.WEST),
			piece(rules.Kind.KILN, 2, 0, rules.Dir.WEST),
			piece(rules.Kind.BELT, 3, 0, rules.Dir.WEST),
			piece(rules.Kind.BELT, 1, 1, rules.Dir.WEST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.WEST),
			piece(rules.Kind.WEIR, 3, 1, rules.Dir.WEST),
			piece(rules.Kind.LIFT, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.NORTH),
		],
	}


static func glean() -> Dictionary:
	var rules = Rules
	# The filter scraps ingots. Ore turns north into the lift from below
	# and goes back into the kiln. A plate from above stalls a belt.
	return {
		"id": 63,
		"name": "Glean",
		"blurb": "Scrap the raw ingots, then take the ore from below into the kiln.",
		"rule": "Ore leaves the filter forward and ingots fall into the pit. The lift takes that ore from below and sends it back into the kiln. It refuses the plate from above. A belt on that cell takes the plate, and the kiln will not smelt it.",
		"w": 4,
		"h": 5,
		"sources": [
			source(2, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 2),
			source(0, 3, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.INGOT], 2),
		],
		"sinks": [sink(0, 1, [rules.Mat.INGOT])],
		"chutes": [cell(1, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 2,
			rules.Kind.FILTER, 1,
			rules.Kind.LIFT, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 18]),
		"initial": [],
		"solution": [
			piece(rules.Kind.FILTER, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.NORTH),
			piece(rules.Kind.LIFT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
		],
	}


static func remit() -> Dictionary:
	var rules = Rules
	# Upper plates are short of the plate quota. Pressing every ingot misses
	# the ingot bin. The lift is what gets ore into the kiln without the plate.
	return {
		"id": 64,
		"name": "Remit",
		"blurb": "Take the ore from below into the kiln, then split ingots between the bin and the press.",
		"rule": "The lift takes ore from below and sends it back into the kiln. It refuses the plate from above. The upper plates are not enough alone. Split the ingots between the bin and the press. Pressing every ingot misses the ingot bin.",
		"w": 5,
		"h": 4,
		"sources": [
			source(3, 0, rules.Dir.WEST, [rules.Mat.PLATE], 4),
			source(4, 1, rules.Dir.SOUTH, [rules.Mat.PLATE], 2),
			source(4, 3, rules.Dir.NORTH, [rules.Mat.ORE], 2),
		],
		"sinks": [
			sink(0, 0, [rules.Mat.PLATE]),
			sink(0, 1, [rules.Mat.PLATE]),
			sink(0, 2, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.LIFT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 12, rules.Mat.PLATE, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 0, rules.Dir.WEST),
			piece(rules.Kind.BELT, 2, 0, rules.Dir.WEST),
			piece(rules.Kind.PRESS, 1, 1, rules.Dir.WEST),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.WEST),
			piece(rules.Kind.BELT, 1, 2, rules.Dir.WEST),
			piece(rules.Kind.SPLITTER, 2, 2, rules.Dir.WEST),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.WEST),
			piece(rules.Kind.LIFT, 4, 2, rules.Dir.EAST),
		],
	}


static func pause_lane() -> Dictionary:
	var rules = Rules
	# Two lead belts, then the dwell, then a weir. Period-3 ore occupies the
	# belt in front of the grate on the tick a belt would release the plate.
	# The extra hold lets that ore leave, so the plate goes through the grate.
	return {
		"id": 65,
		"name": "Pause",
		"blurb": "The dwell holds each plate one tick so the ore crossing clears. A belt on that cell sends the plate into the pit.",
		"rule": "A dwell holds one item and takes it only from behind. It does not send on the tick it accepts, and it does not send on the next tick either. A belt would have sent on that next tick. After the hold, the plate leaves forward. The grate then passes it into the bin and drops the ore into the pit. A belt releases the plate while that ore still occupies the belt, and the weir dumps the plate into the pit.",
		"w": 8,
		"h": 3,
		"sources": [
			source(0, 1, rules.Dir.EAST, [rules.Mat.PLATE], 3),
			source(5, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 3),
		],
		"sinks": [sink(7, 1, [rules.Mat.PLATE])],
		"chutes": [cell(4, 2), cell(6, 2)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.DWELL, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.DWELL, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 6, 1, rules.Dir.EAST),
		],
	}


static func bank() -> Dictionary:
	var rules = Rules
	# The plate crosses the belt in front of the filter. The dwell's extra
	# tick sends the ore through after the plate has left. A belt meets the plate
	# and the weir spills the ore into the pit, so the kiln never sees it.
	return {
		"id": 66,
		"name": "Bank",
		"blurb": "The dwell holds each ore one tick so the plate can cross. A belt on that cell dumps the ore into the pit.",
		"rule": "The dwell holds the ore one tick so the plate can finish crossing the belt in front of the filter. The filter sends ore into the kiln and the plate into the pit. A belt releases the ore while the plate still occupies that belt, and the weir dumps the ore into the pit. The kiln never sees it.",
		"w": 8,
		"h": 4,
		"sources": [
			source(0, 2, rules.Dir.EAST, [rules.Mat.ORE], 3),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 3),
		],
		"sinks": [sink(7, 2, [rules.Mat.INGOT])],
		"chutes": [cell(2, 3), cell(4, 3)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.DWELL, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.DWELL, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 2, rules.Dir.EAST),
		],
	}


static func stint() -> Dictionary:
	var rules = Rules
	# One belt, and it is the crossing in front of the filter. The roller
	# brings the plate onto that belt. The kiln sits against the bin.
	# A belt on the dwell's cell meets the plate, and the weir spills the ore.
	return {
		"id": 67,
		"name": "Stint",
		"blurb": "The tray has one belt. Leave it on the crossing. A belt in place of the dwell dumps the ore into the pit.",
		"rule": "The tray has one belt. It has to stay on the crossing in front of the filter. The roller brings the plate onto that belt, and the dwell holds the ore until the plate has left. The kiln sits against the bin. A belt in place of the dwell releases the ore while the plate is still on the crossing, and the weir dumps the ore into the pit.",
		"w": 7,
		"h": 4,
		"sources": [
			source(0, 2, rules.Dir.EAST, [rules.Mat.ORE], 3),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 3),
		],
		"sinks": [sink(6, 2, [rules.Mat.INGOT])],
		"chutes": [cell(2, 3), cell(4, 3)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.ROLLER, 1,
			rules.Kind.DWELL, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.DWELL, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.ROLLER, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 2, rules.Dir.EAST),
		],
	}


static func late_room() -> Dictionary:
	var rules = Rules
	# Same lane as Pause. The dwell starts off the row, aimed the wrong way.
	return {
		"id": 68,
		"name": "Late",
		"blurb": "That dwell is off the lane. Pick it up and seat it where the plates have to wait.",
		"rule": "Pickup puts this dwell back on the tray. Seat it on the plate lane, pointing east, so each plate waits one tick and the ore crossing clears. It starts off the route. A belt on that cell sends the plate into the pit.",
		"w": 8,
		"h": 3,
		"sources": [
			source(0, 1, rules.Dir.EAST, [rules.Mat.PLATE], 3),
			source(5, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 3),
		],
		"sinks": [sink(7, 1, [rules.Mat.PLATE])],
		"chutes": [cell(4, 2), cell(6, 2)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.DWELL, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 36]),
		"initial": [
			piece(rules.Kind.DWELL, 0, 2, rules.Dir.WEST),
		],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.DWELL, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 6, 1, rules.Dir.EAST),
		],
	}


static func bend_back() -> Dictionary:
	var rules = Rules
	# The straight east run from the plate source is walled. Plates go north
	# into the back of the same Pause chain, so the hold still clears the ore.
	return {
		"id": 69,
		"name": "Bend",
		"blurb": "A wall closes the straight lane. Bring the plates into the back of the dwell.",
		"rule": "The wall blocks a straight lane. Bring the plates north, then east into the back of the dwell. It holds each plate one tick so the ore crossing clears, and the grate passes the plate into the bin. A belt on that cell sends the plate into the pit. A belt that turns south into the wall delivers nothing.",
		"w": 8,
		"h": 4,
		"sources": [
			source(1, 2, rules.Dir.NORTH, [rules.Mat.PLATE], 3),
			source(5, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 3),
		],
		"sinks": [sink(7, 1, [rules.Mat.PLATE])],
		"chutes": [cell(4, 2), cell(6, 2)],
		"walls": [cell(0, 1), cell(2, 2), cell(3, 2)],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.DWELL, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.DWELL, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 6, 1, rules.Dir.EAST),
		],
	}


static func second_heat() -> Dictionary:
	var rules = Rules
	# Period-1 ore feeds a weir and two kilns, about 114 ingots when both run.
	# Plates aimed at the forward kiln's output belt would jam it. Two belts
	# before the dwell make the belt release into an empty belt (one kiln, 57)
	# and the dwell release into a full belt, so the plate spills and both kilns run.
	return {
		"id": 70,
		"name": "Second Heat",
		"blurb": "Hold the plates off the forward kiln's output. A belt lets a plate jam that kiln, and one kiln misses.",
		"rule": "The ore weir fills the forward kiln and spills the rest into a second kiln. One kiln misses the quota. Plates drop toward that forward kiln's output belt. The dwell holds each plate one tick, so the plate weir finds the belt full and spills the plate into the pit. A belt in place of the dwell lets the plate onto that output while it is empty, and one kiln misses.",
		"w": 8,
		"h": 7,
		"sources": [
			source(0, 1, rules.Dir.EAST, [rules.Mat.ORE], 1),
			source(5, 6, rules.Dir.NORTH, [rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(7, 1, [rules.Mat.INGOT]),
			sink(4, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(6, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 7,
			rules.Kind.DWELL, 1,
			rules.Kind.WEIR, 2,
			rules.Kind.KILN, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 70]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 5, 2, rules.Dir.NORTH),
			piece(rules.Kind.DWELL, 5, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 5, 4, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 5, 5, rules.Dir.NORTH),
		],
	}


static func scrap_room() -> Dictionary:
	var rules = Rules
	# The filter before the kiln scraps ingots. A period-3 ingot stream crosses
	# the belt in front of it. Lead 2 makes the dwell miss that stream and a belt hit it.
	return {
		"id": 71,
		"name": "Scrap",
		"blurb": "The filter scraps raw ingots. The dwell holds the ore one tick so it misses the scrap stream.",
		"rule": "Ore leaves the filter forward and ingots fall into the pit. A second ingot stream crosses the belt in front of the filter. The dwell holds the ore one tick so that stream has passed, and the ore reaches the kiln. A belt releases the ore into the crossing, and the weir dumps the load into the pit.",
		"w": 9,
		"h": 4,
		"sources": [
			source(0, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.INGOT], 2),
			source(5, 0, rules.Dir.SOUTH, [rules.Mat.INGOT], 3),
		],
		"sinks": [sink(8, 1, [rules.Mat.INGOT])],
		"chutes": [cell(4, 2), cell(6, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.DWELL, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 18]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.DWELL, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 6, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 7, 1, rules.Dir.EAST),
		],
	}


static func both_bins() -> Dictionary:
	var rules = Rules
	# Bank's ore line, then a splitter. Upper plates on period 4 are 30, short of 36.
	# The press adds the rest. A belt on the dwell cell kills the ore line, so both quotas miss.
	return {
		"id": 72,
		"name": "Both Bins",
		"blurb": "Dwell the ore into the kiln, then split ingots between the bin and the press.",
		"rule": "The dwell holds the ore one tick so the plate can cross, and the filter feeds the kiln. The upper plates are not enough alone. Split the ingots between the bin and the press. Pressing every ingot misses the ingot bin. A belt in place of the dwell dumps the ore into the pit, and the plate quota misses too.",
		"w": 11,
		"h": 5,
		"sources": [
			source(0, 4, rules.Dir.EAST, [rules.Mat.PLATE], 4),
			source(0, 2, rules.Dir.EAST, [rules.Mat.ORE], 3),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 3),
		],
		"sinks": [
			sink(3, 4, [rules.Mat.PLATE]),
			sink(9, 2, [rules.Mat.INGOT]),
			sink(9, 3, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 3), cell(4, 3)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 8,
			rules.Kind.DWELL, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 12, rules.Mat.PLATE, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.DWELL, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 6, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 7, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 8, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 3, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 7, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 8, 3, rules.Dir.EAST),
		],
	}


static func pair_room() -> Dictionary:
	var rules = Rules
	# Period-3 plates, no lead belt. Two ore belts north of the gate hold the
	# crossing for the belt's release and the dwell's release. The next plate
	# frees the first one tick later, after the ore has left.
	return {
		"id": 73,
		"name": "Pair",
		"blurb": "The twin holds the first plate until the next plate arrives, then sends the first. The last plate stays.",
		"rule": "A twin holds one item and takes it only from behind. The first plate stays until the next plate arrives, and that arrival sends the first plate forward. A belt would have sent the first plate on the next tick, into the ore crossing, and the weir would dump it. A dwell waits one tick longer than a belt and still releases the plate while the crossing is full. The grate passes the paired plate into the bin and drops the ore into the pit. The last plate stays in the twin.",
		"w": 6,
		"h": 5,
		"sources": [
			source(0, 3, rules.Dir.EAST, [rules.Mat.PLATE], 3),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 3),
		],
		"sinks": [sink(5, 3, [rules.Mat.PLATE])],
		"chutes": [cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.TWIN, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.TWIN, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 4, 3, rules.Dir.EAST),
		],
	}


static func match_room() -> Dictionary:
	var rules = Rules
	# Same crossing phase as Pair, with ore as the payload. The plate blocks
	# the belt in front of the filter on the belt tick and the dwell tick.
	return {
		"id": 74,
		"name": "Match",
		"blurb": "The twin feeds ore to the kiln only as the next ore arrives. A dwell lets a plate block the line.",
		"rule": "The twin holds each ore until the next ore arrives, then sends the first toward the kiln. A plate crosses the belt in front of the filter. A belt releases the ore while that plate is still there, and a dwell releases it on the following tick, which is still blocked. The weir dumps the ore into the pit and the kiln never sees it. The filter sends a plate that does land into the pit and sends ore on into the kiln.",
		"w": 8,
		"h": 5,
		"sources": [
			source(0, 3, rules.Dir.EAST, [rules.Mat.ORE], 3),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 3),
		],
		"sinks": [sink(7, 3, [rules.Mat.INGOT])],
		"chutes": [cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.TWIN, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.TWIN, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 3, rules.Dir.EAST),
		],
	}


static func stint_pair() -> Dictionary:
	var rules = Rules
	# Two rollers stand in for the plate belts, so the only belt is the crossing.
	# The kiln sits on the bin. Belt and dwell both meet the plate and spill.
	return {
		"id": 75,
		"name": "Stint",
		"blurb": "The tray has one belt. Leave it on the crossing. A belt or a dwell dumps the ore into the pit.",
		"rule": "The tray has one belt. It has to stay on the crossing in front of the filter, and the kiln sits against the bin. Two rollers bring the plate onto that belt. The twin holds the ore until the next ore arrives, after the plate has left. A belt releases the ore while the plate is still on the crossing, and a dwell does too. The weir dumps the ore into the pit.",
		"w": 7,
		"h": 5,
		"sources": [
			source(0, 3, rules.Dir.EAST, [rules.Mat.ORE], 3),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 3),
		],
		"sinks": [sink(6, 3, [rules.Mat.INGOT])],
		"chutes": [cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.ROLLER, 2,
			rules.Kind.TWIN, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.TWIN, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.ROLLER, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.ROLLER, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
		],
	}


static func late_pair() -> Dictionary:
	var rules = Rules
	# Same lane as Pair. The twin starts off the row, aimed the wrong way.
	return {
		"id": 76,
		"name": "Late",
		"blurb": "That twin is off the lane. Pick it up and seat it where the plates have to pair.",
		"rule": "Pickup puts this twin back on the tray. Seat it on the plate lane, pointing east, so each plate waits for the next plate and the ore crossing clears. It starts off the route. A belt on that cell sends the plate into the pit, and a dwell releases the plate before the crossing is clear.",
		"w": 6,
		"h": 5,
		"sources": [
			source(0, 3, rules.Dir.EAST, [rules.Mat.PLATE], 3),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 3),
		],
		"sinks": [sink(5, 3, [rules.Mat.PLATE])],
		"chutes": [cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.TWIN, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 36]),
		"initial": [
			piece(rules.Kind.TWIN, 0, 4, rules.Dir.WEST),
		],
		"solution": [
			piece(rules.Kind.TWIN, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 4, 3, rules.Dir.EAST),
		],
	}


static func bend_pair() -> Dictionary:
	var rules = Rules
	# Two plate belts into the back of the twin, one ore belt. That is the
	# lead-2 crossing that still separates a belt and a dwell from a twin.
	return {
		"id": 77,
		"name": "Bend",
		"blurb": "A wall closes the straight lane. Bring the plates into the back of the twin.",
		"rule": "The wall blocks a straight lane. Bring the plates north, then east into the back of the twin. It holds each plate until the next plate arrives, so the ore crossing clears, and the grate passes the plate into the bin. A belt on that cell sends the plate into the pit, and a dwell releases it before the crossing is clear. A belt that turns south into the wall delivers nothing.",
		"w": 8,
		"h": 4,
		"sources": [
			source(1, 3, rules.Dir.NORTH, [rules.Mat.PLATE], 3),
			source(5, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 3),
		],
		"sinks": [sink(7, 2, [rules.Mat.PLATE])],
		"chutes": [cell(4, 3), cell(6, 3)],
		"walls": [cell(0, 2), cell(2, 3), cell(3, 3)],
		"budget": kv([rules.Kind.BELT, 4, rules.Kind.TWIN, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.TWIN, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 6, 2, rules.Dir.EAST),
		],
	}


static func second_heat_pair() -> Dictionary:
	var rules = Rules
	# Period-4 plates into the north face of the twin. A belt or a dwell drops
	# the first plate onto an empty kiln output and that plate stays there.
	# The pair releases only once the output belt is already holding an ingot.
	return {
		"id": 78,
		"name": "Second Heat",
		"blurb": "Pair the plates before the forward kiln's output. A belt or a dwell lets a plate jam that kiln.",
		"rule": "The ore weir fills the forward kiln and spills the rest into a second kiln. One kiln misses the quota. Plates rise toward that forward kiln's output belt. The twin holds each plate until the next plate arrives, so the plate weir finds the belt full and spills the plate into the pit. A belt or a dwell releases the plate while that output is empty, and the plate jams the kiln.",
		"w": 8,
		"h": 5,
		"sources": [
			source(0, 1, rules.Dir.EAST, [rules.Mat.ORE], 1),
			source(5, 4, rules.Dir.NORTH, [rules.Mat.PLATE], 4),
		],
		"sinks": [
			sink(7, 1, [rules.Mat.INGOT]),
			sink(4, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(6, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 5,
			rules.Kind.TWIN, 1,
			rules.Kind.WEIR, 2,
			rules.Kind.KILN, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 70]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 5, 2, rules.Dir.NORTH),
			piece(rules.Kind.TWIN, 5, 3, rules.Dir.NORTH),
		],
	}


static func after_scrap() -> Dictionary:
	var rules = Rules
	# Match's crossing, with ingots instead of plates. The filter has to scrap
	# those ingots or they sit in front of the kiln and the ore stops.
	return {
		"id": 79,
		"name": "After the Scrap",
		"blurb": "The filter scraps raw ingots. The twin holds the ore until the next ore arrives.",
		"rule": "A scrap stream of ingots crosses the belt in front of the filter. The twin holds each ore until the next ore arrives, so the ore misses that stream and the filter sends it into the kiln. Ingots that do land fall into the pit. A belt releases the ore into the crossing, and a dwell releases it on the next tick, which is still full. The weir dumps the load into the pit. Without the filter the ingots jam the kiln.",
		"w": 8,
		"h": 5,
		"sources": [
			source(0, 3, rules.Dir.EAST, [rules.Mat.ORE], 3),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.INGOT], 3),
		],
		"sinks": [sink(7, 3, [rules.Mat.INGOT])],
		"chutes": [cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.TWIN, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 18]),
		"initial": [],
		"solution": [
			piece(rules.Kind.TWIN, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 3, rules.Dir.EAST),
		],
	}


static func both_bins_pair() -> Dictionary:
	var rules = Rules
	# Match's ore line, then a splitter. Upper plates on period 4 are 30, short of 36.
	# The press adds the rest. A belt or a dwell kills the ore, so both quotas miss.
	return {
		"id": 80,
		"name": "Both Bins",
		"blurb": "Twin the ore into the kiln, then split ingots between the bin and the press.",
		"rule": "The twin holds the ore until the next ore arrives, so the plate can cross, and the filter feeds the kiln. The upper plates are not enough alone. Split the ingots between the bin and the press. Pressing every ingot misses the ingot bin. A belt or a dwell dumps the ore into the pit, so the ingot bin misses and the plate quota misses too.",
		"w": 10,
		"h": 6,
		"sources": [
			source(0, 5, rules.Dir.EAST, [rules.Mat.PLATE], 4),
			source(0, 3, rules.Dir.EAST, [rules.Mat.ORE], 3),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 3),
		],
		"sinks": [
			sink(3, 5, [rules.Mat.PLATE]),
			sink(9, 3, [rules.Mat.INGOT]),
			sink(9, 4, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 9,
			rules.Kind.TWIN, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 12, rules.Mat.PLATE, 36]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 5, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 5, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.TWIN, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 6, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 7, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 8, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 4, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 7, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 8, 4, rules.Dir.EAST),
		],
	}


static func pair_pass() -> Dictionary:
	var rules = Rules
	# Period-3 plates pushed by ingots. Two ore belts hold the crossing for a
	# belt's release and a dwell's release. The ingot frees the plate one tick
	# later, after the ore has left. A twin refuses that ingot.
	return {
		"id": 81,
		"name": "Pair",
		"blurb": "The pass holds the first plate until a different material arrives, then sends the plate. The last item stays.",
		"rule": "A pass holds one item and takes it only from behind. The first plate stays until an ingot arrives from behind, and that arrival sends the plate forward. A twin refuses the ingot, so the plate never leaves. A belt would have sent the first plate on the next tick, into the ore crossing, and the weir would dump it. A dwell waits one tick longer than a belt and still releases the plate while the crossing is full. The grate passes the plate into the bin and drops the ore into the pit. The last ingot stays in the pass.",
		"w": 6,
		"h": 5,
		"sources": [
			source(0, 3, rules.Dir.EAST, [rules.Mat.PLATE, rules.Mat.INGOT], 3),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 3),
		],
		"sinks": [sink(5, 3, [rules.Mat.PLATE])],
		"chutes": [cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.PASS, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 19]),
		"initial": [],
		"solution": [
			piece(rules.Kind.PASS, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 4, 3, rules.Dir.EAST),
		],
	}


static func match_pass() -> Dictionary:
	var rules = Rules
	# Same crossing phase as Pair, with ore as the payload and a plate as the pusher.
	return {
		"id": 82,
		"name": "Match",
		"blurb": "The pass feeds ore to the kiln only when a plate arrives behind it. A twin refuses that plate.",
		"rule": "The pass holds each ore until a plate arrives from behind, then sends the ore toward the kiln. A twin refuses that plate, so the ore never reaches the kiln. A plate crosses the belt in front of the filter. A belt releases the ore while that plate is still there, and a dwell releases it on the following tick, which is still blocked. The weir dumps the ore into the pit. The filter sends a plate that does land into the pit and sends ore on into the kiln. The last plate stays in the pass.",
		"w": 8,
		"h": 5,
		"sources": [
			source(0, 3, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 3),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 3),
		],
		"sinks": [sink(7, 3, [rules.Mat.INGOT])],
		"chutes": [cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.PASS, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 19]),
		"initial": [],
		"solution": [
			piece(rules.Kind.PASS, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 3, rules.Dir.EAST),
		],
	}


static func stint_pass() -> Dictionary:
	var rules = Rules
	# Two rollers stand in for the plate belts, so the only belt is the crossing.
	# The kiln sits on the bin. Belt, dwell, and twin all miss.
	return {
		"id": 83,
		"name": "Stint",
		"blurb": "The tray has one belt. Leave it on the crossing. A belt, a dwell, or a twin dumps the ore or never releases it.",
		"rule": "The tray has one belt. It has to stay on the crossing in front of the filter, and the kiln sits against the bin. Two rollers bring the plate onto that belt. The pass holds the ore until a plate arrives from behind, after the crossing plate has left. A twin refuses that plate, so the ore never leaves. A belt releases the ore while the crossing plate is still there, and a dwell does too. The weir dumps the ore into the pit.",
		"w": 7,
		"h": 5,
		"sources": [
			source(0, 3, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 3),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 3),
		],
		"sinks": [sink(6, 3, [rules.Mat.INGOT])],
		"chutes": [cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.ROLLER, 2,
			rules.Kind.PASS, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 19]),
		"initial": [],
		"solution": [
			piece(rules.Kind.PASS, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.ROLLER, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.ROLLER, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
		],
	}


static func late_pass() -> Dictionary:
	var rules = Rules
	# Same lane as Pair. The pass starts off the row, aimed the wrong way.
	return {
		"id": 84,
		"name": "Late",
		"blurb": "That pass is off the lane. Pick it up and seat it where the different material has to push the plates.",
		"rule": "Pickup puts this pass back on the tray. Seat it on the plate lane, pointing east, so each plate waits for an ingot and the ore crossing clears. It starts off the route. A twin on that cell refuses the ingot, so the plate never leaves. A belt sends the plate into the pit, and a dwell releases the plate before the crossing is clear.",
		"w": 6,
		"h": 5,
		"sources": [
			source(0, 3, rules.Dir.EAST, [rules.Mat.PLATE, rules.Mat.INGOT], 3),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 3),
		],
		"sinks": [sink(5, 3, [rules.Mat.PLATE])],
		"chutes": [cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.PASS, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 19]),
		"initial": [
			piece(rules.Kind.PASS, 0, 4, rules.Dir.WEST),
		],
		"solution": [
			piece(rules.Kind.PASS, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 4, 3, rules.Dir.EAST),
		],
	}


static func bend_pass() -> Dictionary:
	var rules = Rules
	# Two belts bring plates and ingots into the back of the pass. One ore belt
	# holds the crossing. A twin refuses the ingot pusher.
	return {
		"id": 85,
		"name": "Bend",
		"blurb": "A wall closes the straight lane. Bring the pushing items into the back of the pass.",
		"rule": "The wall blocks a straight lane. Bring the plates and the ingots north, then east into the back of the pass. It holds each plate until an ingot arrives, so the ore crossing clears, and the grate passes the plate into the bin. A twin refuses the ingot, so the plate never leaves. A belt on that cell sends the plate into the pit, and a dwell releases it before the crossing is clear. A belt that turns south into the wall delivers nothing.",
		"w": 8,
		"h": 4,
		"sources": [
			source(1, 3, rules.Dir.NORTH, [rules.Mat.PLATE, rules.Mat.INGOT], 3),
			source(5, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 3),
		],
		"sinks": [sink(7, 2, [rules.Mat.PLATE])],
		"chutes": [cell(4, 3), cell(6, 3)],
		"walls": [cell(0, 2), cell(2, 3), cell(3, 3), cell(5, 3)],
		"budget": kv([rules.Kind.BELT, 4, rules.Kind.PASS, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 19]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.PASS, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 6, 2, rules.Dir.EAST),
		],
	}


static func second_heat_pass() -> Dictionary:
	var rules = Rules
	# Ore, ore, plate on period 1. The plate source is listed first and aims at
	# the side of the pass, so a belt is occupied by plates and the ore never
	# enters. The pass refuses that side and the rear stream fills two kilns.
	# One kiln is short. A twin stops when the plate in the rear stream arrives.
	return {
		"id": 86,
		"name": "Second Heat",
		"blurb": "Pass the ore, then a weir into two kilns. A belt, a dwell, or a twin jams a kiln or never releases the ore.",
		"rule": "The pass takes the ore stream from behind and refuses the plate aimed at its side. Plates in that stream push the waiting ore, and the filter scraps those plates. The weir keeps the forward kiln full and spills the rest into a second kiln. One kiln misses the quota. A belt accepts the side plate, so the ore never enters. A dwell refuses the side plate but releases too slowly to feed both kilns. A twin refuses the plate behind the ore, so the ore stops.",
		"w": 8,
		"h": 4,
		"sources": [
			source(1, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 1),
			source(0, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(7, 1, [rules.Mat.INGOT]),
			sink(4, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.PASS, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.KILN, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 70]),
		"initial": [],
		"solution": [
			piece(rules.Kind.PASS, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
		],
	}


static func after_scrap_pass() -> Dictionary:
	var rules = Rules
	# Match's crossing, with ingots instead of plates. The filter has to scrap
	# those ingots. A plate from behind is what releases the ore.
	return {
		"id": 87,
		"name": "After the Scrap",
		"blurb": "The filter scraps one stream. The pass holds the ore until a different material arrives.",
		"rule": "A scrap stream of ingots crosses the belt in front of the filter. The pass holds each ore until a plate arrives from behind, so the ore misses that stream and the filter sends it into the kiln. A twin refuses that plate, so the ore never leaves. Ingots that do land fall into the pit. A belt releases the ore into the crossing, and a dwell releases it on the next tick, which is still full. The weir dumps the load into the pit. Without the filter the ingots jam the kiln.",
		"w": 8,
		"h": 5,
		"sources": [
			source(0, 3, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 3),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.INGOT], 3),
		],
		"sinks": [sink(7, 3, [rules.Mat.INGOT])],
		"chutes": [cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.PASS, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 19]),
		"initial": [],
		"solution": [
			piece(rules.Kind.PASS, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 3, rules.Dir.EAST),
		],
	}


static func both_bins_pass() -> Dictionary:
	var rules = Rules
	# Match's ore line, then a splitter. Upper plates on period 4 are 30, short of 34.
	# The press adds the rest. A belt, a dwell, or a twin kills the ore, so both quotas miss.
	return {
		"id": 88,
		"name": "Both Bins",
		"blurb": "Pass the ore into the kiln, then split ingots between the bin and the press.",
		"rule": "The pass holds the ore until a plate arrives from behind, so the crossing plate can pass, and the filter feeds the kiln. A twin refuses that plate, so the ore never reaches the kiln. The upper plates are not enough alone. Split the ingots between the bin and the press. Pressing every ingot misses the ingot bin. A belt or a dwell dumps the ore into the pit, so the ingot bin misses and the plate quota misses too.",
		"w": 10,
		"h": 6,
		"sources": [
			source(0, 5, rules.Dir.EAST, [rules.Mat.PLATE], 4),
			source(0, 3, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 3),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 3),
		],
		"sinks": [
			sink(3, 5, [rules.Mat.PLATE]),
			sink(9, 3, [rules.Mat.INGOT]),
			sink(9, 4, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 9,
			rules.Kind.PASS, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 10, rules.Mat.PLATE, 34]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 5, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 5, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.PASS, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 6, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 7, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 8, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 4, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 7, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 8, 4, rules.Dir.EAST),
		],
	}

static func hold_slip() -> Dictionary:
	var rules = Rules
	# Period-2 plates and ingots. Crossing ore on period 4 sits on the junction
	# when a belt, a dwell, or a pass lets a plate go. The slip keeps the first
	# plate and lets later plates through on the clear phase.
	return {
		"id": 89,
		"name": "Hold",
		"blurb": "The slip keeps the first plate and lets every later item through. A pass sends that plate and keeps the last item.",
		"rule": "A slip holds one item and takes it only from behind. The first plate stays. Every later item moves one cell forward on the tick it arrives, and that plate remains the waiting item. A pass sends the plate and keeps the last item, so the plates hit the ore crossing and the weir dumps them. A belt sends the plate on the next tick, into the crossing. A dwell releases it while the crossing is still full. A twin refuses the ingot, so the plate never leaves and nothing behind it can pass. The grate passes later plates into the bin and drops ore and ingots into the pit.",
		"w": 6,
		"h": 5,
		"sources": [
			source(0, 3, rules.Dir.EAST, [rules.Mat.PLATE, rules.Mat.INGOT], 2),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 4),
		],
		"sinks": [sink(5, 3, [rules.Mat.PLATE])],
		"chutes": [cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.SLIP, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 29]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SLIP, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 4, 3, rules.Dir.EAST),
		],
	}


static func keep_slip() -> Dictionary:
	var rules = Rules
	# Match's crossing. The filter faces east, so ore falls into the east pit
	# and ingots drop south into the press. The slip holds the first ore.
	return {
		"id": 90,
		"name": "Keep",
		"blurb": "The slip holds the first ore and lets the ingots through to the press. A pass sends that ore onward.",
		"rule": "The slip holds the first ore and lets later ingots through. The filter scraps ore into the pit and feeds ingots to the press. A pass sends that ore onward, so the press never fills and the plate bin misses. A belt and a dwell release the ore into the crossing, and the weir dumps the load. A twin refuses the ingot, so the ore never leaves.",
		"w": 8,
		"h": 5,
		"sources": [
			source(0, 3, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.INGOT], 1),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 6),
		],
		"sinks": [sink(6, 4, [rules.Mat.PLATE])],
		"chutes": [cell(2, 4), cell(5, 3)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.SLIP, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.PLATE, 19]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SLIP, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 4, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 5, 4, rules.Dir.EAST),
		],
	}


static func still_slip() -> Dictionary:
	var rules = Rules
	# Stint's single belt stays on the crossing. The slip keeps the first ore
	# out of the pit and lets later ore through once the crossing plate has left.
	return {
		"id": 91,
		"name": "Still",
		"blurb": "The tray has one belt. Leave it on the crossing. The slip keeps the first ore out of the pit.",
		"rule": "The tray has one belt. It has to stay on the crossing in front of the filter, and the kiln sits against the bin. Two rollers bring the plate onto that belt. The slip keeps the first ore and lets later ore through after the crossing plate has left. A pass sends that ore into the crossing and the weir dumps it. A belt and a dwell release it into the pit as well. A twin refuses the plate, so the ore never leaves.",
		"w": 7,
		"h": 5,
		"sources": [
			source(0, 3, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 4),
		],
		"sinks": [sink(6, 3, [rules.Mat.INGOT])],
		"chutes": [cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.ROLLER, 2,
			rules.Kind.SLIP, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SLIP, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.ROLLER, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.ROLLER, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
		],
	}


static func seat_slip() -> Dictionary:
	var rules = Rules
	# Same lane as Hold. The slip starts off the row, aimed the wrong way.
	return {
		"id": 92,
		"name": "Seat",
		"blurb": "That slip is off the lane. Pick it up and seat it where the first plate has to stay.",
		"rule": "Pickup puts this slip back on the tray. Seat it on the plate lane, pointing east, so the first plate stays and later plates miss the ore crossing. It starts off the route. A pass on that cell sends the plate into the pit and keeps the last item. A belt sends the plate on the next tick. A dwell releases the plate before the crossing is clear. A twin refuses the ingot, so the plate never leaves.",
		"w": 6,
		"h": 5,
		"sources": [
			source(0, 3, rules.Dir.EAST, [rules.Mat.PLATE, rules.Mat.INGOT], 2),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 4),
		],
		"sinks": [sink(5, 3, [rules.Mat.PLATE])],
		"chutes": [cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.SLIP, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 29]),
		"initial": [
			piece(rules.Kind.SLIP, 0, 4, rules.Dir.WEST),
		],
		"solution": [
			piece(rules.Kind.SLIP, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 4, 3, rules.Dir.EAST),
		],
	}


static func turn_slip() -> Dictionary:
	var rules = Rules
	# Bend's wall. Two belts bring plates and ingots into the back of the slip.
	return {
		"id": 93,
		"name": "Turn",
		"blurb": "A wall closes the straight lane. Bring the later items into the back of the slip.",
		"rule": "The wall blocks a straight lane. Bring the plates and the ingots north, then east into the back of the slip. The first plate stays, and later plates miss the ore crossing. The grate passes them into the bin. A pass sends the first plate and keeps an ingot, so the bin misses. A belt on that cell sends the plate into the pit, and a dwell releases it before the crossing is clear. A twin refuses the ingot, so the plate never leaves. A belt that turns south into the wall delivers nothing.",
		"w": 8,
		"h": 4,
		"sources": [
			source(1, 3, rules.Dir.NORTH, [rules.Mat.PLATE, rules.Mat.INGOT], 1),
			source(5, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 4),
		],
		"sinks": [sink(7, 2, [rules.Mat.PLATE])],
		"chutes": [cell(4, 3), cell(6, 3)],
		"walls": [cell(0, 2), cell(2, 3), cell(3, 3), cell(5, 3)],
		"budget": kv([rules.Kind.BELT, 4, rules.Kind.SLIP, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.SLIP, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 6, 2, rules.Dir.EAST),
		],
	}


static func spare_heat_slip() -> Dictionary:
	var rules = Rules
	# Plate, then three ores, on period 1. The side plate aims at the slip.
	# The slip keeps the plate. A pass sends it and holds an ore, so the quota misses.
	# One kiln cannot take the ore the weir spills.
	return {
		"id": 94,
		"name": "Spare Heat",
		"blurb": "Slip the ore into two kilns. A pass holds the ore, and one kiln misses.",
		"rule": "The slip takes the stream from behind and refuses the plate aimed at its side. It keeps the first plate and lets the ore through. The filter scraps later plates. The weir keeps the forward kiln full and spills the rest into a second kiln. One kiln misses the quota. A pass sends the plate and holds an ore, so the quota misses. A belt accepts the side plate, so the ore never enters. A dwell refuses the side plate but releases too slowly to feed both kilns. A twin refuses the ore behind the plate, so the ore stops.",
		"w": 8,
		"h": 4,
		"sources": [
			source(1, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 1),
			source(0, 1, rules.Dir.EAST, [rules.Mat.PLATE, rules.Mat.ORE, rules.Mat.ORE, rules.Mat.ORE], 1),
		],
		"sinks": [
			sink(7, 1, [rules.Mat.INGOT]),
			sink(4, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.SLIP, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.KILN, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 86]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SLIP, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
		],
	}


static func after_hold_slip() -> Dictionary:
	var rules = Rules
	# Scrap's crossing, with the slip keeping the first ore. Later ore misses
	# the ingot stream. A pass sends that ore into the crossing.
	return {
		"id": 95,
		"name": "After the Hold",
		"blurb": "The filter scraps one stream. The slip keeps the first ore while later items pass.",
		"rule": "A scrap stream of ingots crosses the belt in front of the filter. The slip keeps the first ore and lets later ore through after that stream has passed, and the filter sends it into the kiln. A pass sends that ore onward into the crossing, and the weir dumps it. A belt and a dwell do too. A twin refuses the plate, so the ore never leaves. Ingots that do land fall into the pit. Without the filter the ingots jam the kiln.",
		"w": 8,
		"h": 5,
		"sources": [
			source(0, 3, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [sink(7, 3, [rules.Mat.INGOT])],
		"chutes": [cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.SLIP, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SLIP, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 3, rules.Dir.EAST),
		],
	}


static func one_bin_slip() -> Dictionary:
	var rules = Rules
	# Both bins' splitter. The slip keeps the first plate and lets ore through
	# to the kiln. Upper plates on period 4 are 30, short of 39.
	return {
		"id": 96,
		"name": "One Bin",
		"blurb": "The slip keeps the first plate. Later ingots split between the bin and the press.",
		"rule": "The slip keeps the first plate and lets the ore through to the kiln. The filter scraps the crossing plates. Split the ingots between the bin and the press. The upper plates are not enough alone. A pass sends that plate and holds an ore, so both quotas miss. A belt or a dwell dumps the ore into the pit, and a twin refuses the ore, so the plate never leaves. Pressing every ingot misses the ingot bin.",
		"w": 10,
		"h": 6,
		"sources": [
			source(0, 5, rules.Dir.EAST, [rules.Mat.PLATE], 4),
			source(0, 3, rules.Dir.EAST, [rules.Mat.PLATE, rules.Mat.ORE], 1),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 6),
		],
		"sinks": [
			sink(3, 5, [rules.Mat.PLATE]),
			sink(9, 3, [rules.Mat.INGOT]),
			sink(9, 4, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 9,
			rules.Kind.SLIP, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 19, rules.Mat.PLATE, 39]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 5, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 5, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.SLIP, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 6, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 7, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 8, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 4, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 7, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 8, 4, rules.Dir.EAST),
		],
	}


static func aside_shed() -> Dictionary:
	var rules = Rules
	# Hold's lane. The shed faces south, so the first plate stays and later
	# items leave east. A slip on that cell sends those items south into the pit.
	return {
		"id": 97,
		"name": "Aside",
		"blurb": "The shed keeps the first plate and lets every later item out to the left. A slip sends those later items forward.",
		"rule": "A shed holds one item and takes it only from behind. The first plate stays. Every later item moves one cell to the left on the tick it arrives, and that plate remains the waiting item. A slip sends those later items forward into the pit. A pass sends the plate and keeps the last item, so the plates hit the ore crossing and the weir dumps them. A belt sends the plate on the next tick, into the pit. A dwell releases it forward as well. A twin refuses the ingot, so the plate never leaves and nothing behind it can pass. The grate passes later plates into the bin and drops ore and ingots into the pit.",
		"w": 6,
		"h": 5,
		"sources": [
			source(1, 2, rules.Dir.SOUTH, [rules.Mat.PLATE, rules.Mat.INGOT], 2),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 4),
		],
		"sinks": [sink(5, 3, [rules.Mat.PLATE])],
		"chutes": [cell(1, 4), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.SHED, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 29]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SHED, 1, 3, rules.Dir.SOUTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 4, 3, rules.Dir.EAST),
		],
	}


static func keep_left_shed() -> Dictionary:
	var rules = Rules
	# Keep's crossing. The shed faces south and lets ingots out to the left,
	# into the filter and the press. Forward is the pit, off the press.
	return {
		"id": 98,
		"name": "Keep Left",
		"blurb": "The shed holds the first ore and lets the later ingots out to the left, into the press. A slip sends those ingots forward, off the press.",
		"rule": "The shed holds the first ore and lets later ingots out to the left. The filter scraps ore into the pit and feeds ingots to the press. A slip sends those ingots forward, off the press, so the plate bin misses. A pass sends the ore onward into the pit as well. A belt and a dwell release the ore forward, and nothing reaches the press. A twin refuses the ingot, so the ore never leaves.",
		"w": 8,
		"h": 5,
		"sources": [
			source(1, 2, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.INGOT], 1),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 6),
		],
		"sinks": [sink(6, 4, [rules.Mat.PLATE])],
		"chutes": [cell(1, 4), cell(2, 4), cell(5, 3)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.SHED, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.PLATE, 19]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SHED, 1, 3, rules.Dir.SOUTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 4, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 5, 4, rules.Dir.EAST),
		],
	}


static func still_left_shed() -> Dictionary:
	var rules = Rules
	# Still's single belt stays on the crossing. The shed keeps the first ore
	# out of the forward pit and lets later ore out to the left.
	return {
		"id": 99,
		"name": "Still Left",
		"blurb": "The tray has one belt, on the crossing. The shed keeps the first item out of the pit.",
		"rule": "The tray has one belt. It has to stay on the crossing in front of the filter, and the kiln sits against the bin. Two rollers bring the plate onto that belt. The shed keeps the first ore and lets later ore out to the left after the crossing plate has left. A slip sends that ore forward into the pit. A pass sends it forward and the pit takes it. A belt and a dwell release it into the pit as well. A twin refuses the plate, so the ore never leaves.",
		"w": 7,
		"h": 5,
		"sources": [
			source(1, 2, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 4),
		],
		"sinks": [sink(6, 3, [rules.Mat.INGOT])],
		"chutes": [cell(1, 4), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.ROLLER, 2,
			rules.Kind.SHED, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SHED, 1, 3, rules.Dir.SOUTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.ROLLER, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.ROLLER, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
		],
	}


static func seat_shed() -> Dictionary:
	var rules = Rules
	# Same lane as Aside. The shed starts off the row, aimed the wrong way.
	return {
		"id": 100,
		"name": "Seat",
		"blurb": "That shed is off the lane. Pick it up and seat it where the first item has to stay and the later items leave left.",
		"rule": "Pickup puts this shed back on the tray. Seat it on the plate lane, pointing south, so the first plate stays and later plates leave left, missing the ore crossing. It starts off the route. A slip on that cell sends the later plates forward into the pit. A pass sends the plate into the pit and keeps the last item. A belt sends the plate on the next tick. A dwell releases the plate forward. A twin refuses the ingot, so the plate never leaves.",
		"w": 6,
		"h": 5,
		"sources": [
			source(1, 2, rules.Dir.SOUTH, [rules.Mat.PLATE, rules.Mat.INGOT], 2),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 4),
		],
		"sinks": [sink(5, 3, [rules.Mat.PLATE])],
		"chutes": [cell(1, 4), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.SHED, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 29]),
		"initial": [
			piece(rules.Kind.SHED, 0, 4, rules.Dir.WEST),
		],
		"solution": [
			piece(rules.Kind.SHED, 1, 3, rules.Dir.SOUTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 4, 3, rules.Dir.EAST),
		],
	}


static func corner_shed() -> Dictionary:
	var rules = Rules
	# Turn's downstream. Two belts before the shed match Turn's delay, and the
	# wall closes the straight east lane so the stream has to enter from behind.
	return {
		"id": 101,
		"name": "Corner",
		"blurb": "A wall closes the straight lane. Bring the later items into the back of the shed.",
		"rule": "The wall blocks a straight lane. Bring the plates and the ingots east, then south into the back of the shed. The first plate stays, and later plates leave left and miss the ore crossing. The grate passes them into the bin. A slip sends the later items forward into the pit. A pass sends the first plate and keeps an ingot, so the bin misses. A belt on that cell sends the plate into the pit, and a dwell releases it forward. A twin refuses the ingot, so the plate never leaves. A belt that runs east into the wall delivers nothing.",
		"w": 8,
		"h": 4,
		"sources": [
			source(1, 1, rules.Dir.EAST, [rules.Mat.PLATE, rules.Mat.INGOT], 1),
			source(5, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 4),
		],
		"sinks": [sink(7, 2, [rules.Mat.PLATE])],
		"chutes": [cell(3, 3), cell(4, 3), cell(6, 3)],
		"walls": [cell(4, 1), cell(6, 1), cell(7, 1)],
		"budget": kv([rules.Kind.BELT, 4, rules.Kind.SHED, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.SHED, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.WEIR, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 6, 2, rules.Dir.EAST),
		],
	}


static func left_heat_shed() -> Dictionary:
	var rules = Rules
	# Spare Heat's two kilns sit on the left exit. The forward lane is one kiln.
	# Its own ore counts in the solution. A slip sends the main stream there.
	return {
		"id": 102,
		"name": "Left Heat",
		"blurb": "The shed's left exit feeds the kilns. A slip feeds the forward lane, and one kiln misses.",
		"rule": "The shed takes the stream from behind and refuses the plate aimed at its side. It keeps the first plate and lets the ore out to the left. The filter scraps later plates. The weir keeps the forward kiln full and spills the rest into a second kiln. The lane ahead of the shed has its own kiln. One kiln misses the quota. A slip sends the ore forward onto that one kiln, so the left kilns starve and the quota misses. A belt accepts the side plate and sends the load forward. A dwell refuses the side plate but releases forward, onto the wrong lane. A twin refuses the ore behind the plate, so the ore stops. A pass sends the plate forward and the kiln jams.",
		"w": 8,
		"h": 5,
		"sources": [
			source(1, 0, rules.Dir.SOUTH, [rules.Mat.PLATE, rules.Mat.ORE, rules.Mat.ORE, rules.Mat.ORE], 1),
			source(0, 1, rules.Dir.EAST, [rules.Mat.PLATE], 1),
			source(0, 2, rules.Dir.EAST, [rules.Mat.ORE], 2),
		],
		"sinks": [
			sink(7, 1, [rules.Mat.INGOT]),
			sink(4, 3, [rules.Mat.INGOT]),
			sink(1, 4, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.SHED, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.KILN, 3,
		]),
		"quota": kv([rules.Mat.INGOT, 145]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SHED, 1, 1, rules.Dir.SOUTH),
			piece(rules.Kind.FILTER, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 1, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 1, 3, rules.Dir.SOUTH),
		],
	}


static func after_stay_shed() -> Dictionary:
	var rules = Rules
	# After the Hold, with the shed keeping the first ore and letting later ore
	# out to the left. A slip sends that ore south into the scrap chute.
	return {
		"id": 103,
		"name": "After the Stay",
		"blurb": "The filter scraps one stream. The shed keeps the first ore while later items leave left.",
		"rule": "A scrap stream of ingots crosses the belt in front of the filter. The shed keeps the first ore and lets later ore out to the left after that stream has passed, and the filter sends it into the kiln. A slip sends that ore forward into the scrap. A pass sends it forward as well, and the pit takes it. A belt and a dwell do too. A twin refuses the plate, so the ore never leaves. Ingots that do land fall into the pit. Without the filter the ingots jam the kiln.",
		"w": 8,
		"h": 5,
		"sources": [
			source(1, 2, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [sink(7, 3, [rules.Mat.INGOT])],
		"chutes": [cell(1, 4), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.SHED, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SHED, 1, 3, rules.Dir.SOUTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 3, rules.Dir.EAST),
		],
	}


static func side_bin_shed() -> Dictionary:
	var rules = Rules
	# One Bin's splitter, fed from the shed's left. The first plate stays.
	# Upper plates on period 4 are 30, short of the plate quota.
	return {
		"id": 104,
		"name": "Side Bin",
		"blurb": "The shed keeps the first plate. Later ingots leave left and split between the bin and the press.",
		"rule": "The shed keeps the first plate and lets the ore out to the left, into the kiln. The filter scraps the crossing plates. Split the ingots between the bin and the press. The upper plates are not enough alone. A slip sends that ore forward, off both bins, so both quotas miss. A pass sends the plate and holds an ore, so both quotas miss. A belt or a dwell dumps the load into the pit, and a twin refuses the ore, so the plate never leaves. Pressing every ingot misses the ingot bin.",
		"w": 10,
		"h": 6,
		"sources": [
			source(0, 5, rules.Dir.EAST, [rules.Mat.PLATE], 4),
			source(1, 2, rules.Dir.SOUTH, [rules.Mat.PLATE, rules.Mat.ORE], 1),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 6),
		],
		"sinks": [
			sink(3, 5, [rules.Mat.PLATE]),
			sink(9, 3, [rules.Mat.INGOT]),
			sink(9, 4, [rules.Mat.PLATE]),
		],
		"chutes": [cell(1, 4), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 9,
			rules.Kind.SHED, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 19, rules.Mat.PLATE, 39]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 5, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 5, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.SHED, 1, 3, rules.Dir.SOUTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 6, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 7, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 8, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 4, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 7, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 8, 4, rules.Dir.EAST),
		],
	}


static func draw_left() -> Dictionary:
	var rules = Rules
	# Aside's lane. Period-1 plates and ingots. The rake faces south, so the
	# first plate leaves east when the ingot arrives. A shed keeps that plate
	# and sends the ingot east, into the grate's pit.
	return {
		"id": 105,
		"name": "Draw Left",
		"blurb": "The rake holds the first plate until a later item arrives, then sends that plate left. A shed sends the later item left and the plate stays.",
		"rule": "A rake holds one item and takes it only from behind. The first plate waits until an ingot arrives, then that plate moves one cell to the left and the ingot becomes the waiting item. The last ingot stays. A shed keeps the plate and sends the ingot left, so the plate bin stays empty. A belt, a dwell, a pass, and a slip send the load forward into the pit. A twin refuses the ingot, so the plate never leaves. A hook also turns the plates left and meets this plate count. The grate passes the plates into the bin and drops ore and ingots into the pit.",
		"w": 6,
		"h": 5,
		"sources": [
			source(1, 2, rules.Dir.SOUTH, [rules.Mat.PLATE, rules.Mat.INGOT], 1),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 4),
		],
		"sinks": [sink(5, 3, [rules.Mat.PLATE])],
		"chutes": [cell(1, 4), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.RAKE, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 29]),
		"initial": [],
		"solution": [
			piece(rules.Kind.RAKE, 1, 3, rules.Dir.SOUTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 4, 3, rules.Dir.EAST),
		],
	}


static func push_ore() -> Dictionary:
	var rules = Rules
	# Keep's lane, turned to a kiln. Period-3 ore waits for a plate. The plate
	# crossing is full when a hook releases, and clear when the rake releases.
	return {
		"id": 106,
		"name": "Push Ore",
		"blurb": "The rake holds the first ore until a plate arrives, then sends that ore left into the kiln. A shed sends the plate left and the ore stays.",
		"rule": "The rake holds the first ore until a plate arrives from behind, then sends that ore left. The filter scraps plates and feeds the ore to the kiln. The last plate stays. A shed keeps the first ore and sends the plate left, so the kiln finishes one ingot short. A hook releases on the tick the crossing plate is still on the belt, and the weir dumps the load. A belt, a dwell, and a pass send the ore forward into the pit. A slip sends the plate forward and keeps the ore. A twin refuses the plate, so the ore never leaves.",
		"w": 8,
		"h": 5,
		"sources": [
			source(1, 2, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 3),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 6),
		],
		"sinks": [sink(7, 3, [rules.Mat.INGOT])],
		"chutes": [cell(1, 4), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.RAKE, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 19]),
		"initial": [],
		"solution": [
			piece(rules.Kind.RAKE, 1, 3, rules.Dir.SOUTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 3, rules.Dir.EAST),
		],
	}


static func still_rake() -> Dictionary:
	var rules = Rules
	# Still's single belt stays on the crossing. The rake sends the first ore
	# left once a plate arrives, after that crossing plate has moved on.
	return {
		"id": 107,
		"name": "Still Rake",
		"blurb": "The tray has one belt, on the crossing. The rake sends the first item left, out of the pit, and the last item stays.",
		"rule": "The tray has one belt. It has to stay on the crossing in front of the filter, and the kiln sits against the bin. Two rollers bring the plate onto that belt. The rake holds the first ore until a plate arrives, then sends that ore left, and the last plate stays. A shed keeps the ore and sends the plate left, so the kiln gets nothing. A belt, a dwell, and a pass release the load forward into the pit. A slip sends the plate forward and keeps the ore. A twin refuses the plate, so the ore never leaves. A hook also turns the ore left and meets this ingot count.",
		"w": 7,
		"h": 5,
		"sources": [
			source(1, 2, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 4),
		],
		"sinks": [sink(6, 3, [rules.Mat.INGOT])],
		"chutes": [cell(1, 4), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.ROLLER, 2,
			rules.Kind.RAKE, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.RAKE, 1, 3, rules.Dir.SOUTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.ROLLER, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.ROLLER, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
		],
	}


static func seat_rake() -> Dictionary:
	var rules = Rules
	# Same lane as Draw Left. The rake starts off the row, aimed the wrong way.
	return {
		"id": 108,
		"name": "Seat",
		"blurb": "That rake is off the lane. Pick it up and seat it where the first item has to leave left.",
		"rule": "Pickup puts this rake back on the tray. Seat it on the plate lane, pointing south, so the first plate waits for an ingot and then leaves left, missing the ore crossing. It starts off the route. A shed on that cell keeps the plate and sends the ingot left, so the bin stays empty. A belt sends the plate forward on the next tick. A dwell and a pass release it forward into the pit. A slip sends the later items forward. A twin refuses the ingot, so the plate never leaves. A hook seated there also meets this plate count.",
		"w": 6,
		"h": 5,
		"sources": [
			source(1, 2, rules.Dir.SOUTH, [rules.Mat.PLATE, rules.Mat.INGOT], 1),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 4),
		],
		"sinks": [sink(5, 3, [rules.Mat.PLATE])],
		"chutes": [cell(1, 4), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.RAKE, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 29]),
		"initial": [
			piece(rules.Kind.RAKE, 0, 4, rules.Dir.WEST),
		],
		"solution": [
			piece(rules.Kind.RAKE, 1, 3, rules.Dir.SOUTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 4, 3, rules.Dir.EAST),
		],
	}


static func corner_rake() -> Dictionary:
	var rules = Rules
	# Corner's downstream. Two belts before the rake match the delay that puts
	# a hook into the ore and lets the rake's plate through on the clear phase.
	return {
		"id": 109,
		"name": "Corner",
		"blurb": "A wall closes the straight lane. Bring the later items into the back of the rake.",
		"rule": "The wall blocks a straight lane. Bring the ingots and the plates east, then south into the back of the rake. The first ingot waits until a plate arrives, then leaves left, and later plates follow on the clear phase. The last ingot stays. The grate passes the plates into the bin. A shed sends those plates left while the ore is still on the crossing, and the weir dumps them. A hook releases a tick sooner and the pit takes them. A belt on that cell sends the load forward into the pit, and a dwell and a pass do too. A slip sends the arrival forward. A twin refuses the plate, so the ingot never leaves. A belt that runs east into the wall delivers nothing.",
		"w": 8,
		"h": 4,
		"sources": [
			source(1, 1, rules.Dir.EAST, [rules.Mat.INGOT, rules.Mat.PLATE], 2),
			source(5, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 4),
		],
		"sinks": [sink(7, 2, [rules.Mat.PLATE])],
		"chutes": [cell(3, 3), cell(4, 3), cell(6, 3)],
		"walls": [cell(4, 1), cell(6, 1), cell(7, 1)],
		"budget": kv([rules.Kind.BELT, 4, rules.Kind.RAKE, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.RAKE, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.WEIR, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 6, 2, rules.Dir.EAST),
		],
	}


static func left_heat_rake() -> Dictionary:
	var rules = Rules
	# Left Heat's two kilns sit on the left exit. Ore, ore, plate, ore. The
	# rake feeds the waiting ore left. The shed feeds the arrival and finishes
	# one ingot short of the quota.
	return {
		"id": 110,
		"name": "Left Heat",
		"blurb": "The rake's left exit feeds the kilns with the waiting item. A shed feeds them with the arrival, and the quota misses.",
		"rule": "The rake takes the stream from behind and refuses the plate aimed at its side. It holds each ore until the next item arrives, then sends that ore left. The filter scraps the plate in the stream. The weir keeps the forward kiln full and spills the rest into a second kiln. The lane ahead of the rake has its own kiln. One missing ingot misses the quota. A shed sends the arrival left and finishes one ingot short. A hook also feeds the kilns and meets this count. A belt accepts the side plate and the left kilns starve. A dwell and a pass release forward, onto the single kiln. A slip sends the arrival forward. A twin refuses the plate, so the ore stops.",
		"w": 8,
		"h": 5,
		"sources": [
			source(1, 0, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.ORE, rules.Mat.PLATE, rules.Mat.ORE], 1),
			source(0, 1, rules.Dir.EAST, [rules.Mat.PLATE], 1),
			source(0, 2, rules.Dir.EAST, [rules.Mat.ORE], 2),
		],
		"sinks": [
			sink(7, 1, [rules.Mat.INGOT]),
			sink(4, 3, [rules.Mat.INGOT]),
			sink(1, 4, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.RAKE, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.KILN, 3,
		]),
		"quota": kv([rules.Mat.INGOT, 145]),
		"initial": [],
		"solution": [
			piece(rules.Kind.RAKE, 1, 1, rules.Dir.SOUTH),
			piece(rules.Kind.FILTER, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 1, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 1, 3, rules.Dir.SOUTH),
		],
	}


static func after_push() -> Dictionary:
	var rules = Rules
	# After the Stay, with the rake sending the first ore left when a plate
	# arrives. Forward is the scrap chute. The crossing ingots are the scrap.
	return {
		"id": 111,
		"name": "After the Push",
		"blurb": "The filter scraps one stream. The rake sends the first ore left, away from the scrap, when a later item arrives.",
		"rule": "A scrap stream of ingots crosses the belt in front of the filter. The rake holds the first ore until a plate arrives, then sends that ore left, clear of the scrap, and the filter feeds the kiln. The last plate stays. A shed sends the later plate left and keeps the ore, so the kiln gets nothing. A belt, a dwell, and a pass send the ore forward into the scrap. A slip sends the plate forward and keeps the ore. A twin refuses the plate, so the ore never leaves. A hook also turns the ore left and meets this ingot count. Ingots that do land fall into the pit. Without the filter the ingots jam the kiln.",
		"w": 8,
		"h": 5,
		"sources": [
			source(1, 2, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [sink(7, 3, [rules.Mat.INGOT])],
		"chutes": [cell(1, 4), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.RAKE, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.RAKE, 1, 3, rules.Dir.SOUTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 3, rules.Dir.EAST),
		],
	}


static func side_bin_rake() -> Dictionary:
	var rules = Rules
	# Side Bin's splitter, fed from the rake's left. The first plate leaves
	# left and is scrapped. The ores that follow are smelted and split.
	# Upper plates on period 4 are 30, short of the plate quota.
	return {
		"id": 112,
		"name": "Side Bin",
		"blurb": "The rake sends the first plate left, and the items that leave left split between the bin and the press.",
		"rule": "The rake sends the first plate left when the next ore arrives, then sends that ore left when the following ore arrives. The filter scraps the plate and the crossing plates, and the kiln smelts the ore. Split the ingots between the bin and the press. The last ore stays. The upper plates are not enough alone. A shed keeps the plate and sends the later ore left while the crossing is occupied, so both quotas miss. A belt, a dwell, a pass, or a slip dumps the load into the pit. A twin refuses the ore behind the plate, so the plate never leaves. A hook also sends the load left and meets both counts. Pressing every ingot misses the ingot bin.",
		"w": 10,
		"h": 6,
		"sources": [
			source(0, 5, rules.Dir.EAST, [rules.Mat.PLATE], 4),
			source(1, 2, rules.Dir.SOUTH, [rules.Mat.PLATE, rules.Mat.ORE, rules.Mat.ORE], 1),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 6),
		],
		"sinks": [
			sink(3, 5, [rules.Mat.PLATE]),
			sink(9, 3, [rules.Mat.INGOT]),
			sink(9, 4, [rules.Mat.PLATE]),
		],
		"chutes": [cell(1, 4), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 9,
			rules.Kind.RAKE, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 19, rules.Mat.PLATE, 39]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 5, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 5, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.RAKE, 1, 3, rules.Dir.SOUTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 6, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 7, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 8, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 4, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 7, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 8, 4, rules.Dir.EAST),
		],
	}


static func draw_right() -> Dictionary:
	var rules = Rules
	# Draw Left's lane, turned so the exit is right. The hoe faces north:
	# behind is the plate source, right is the eastbound weir, left is a pit.
	return {
		"id": 113,
		"name": "Draw Right",
		"blurb": "The hoe holds the first plate until a later item arrives, then sends that plate right. A rake sends that plate left.",
		"rule": "A hoe holds one item and takes it only from behind. The first plate waits until an ingot arrives, then that plate moves one cell to the right and the ingot becomes the waiting item. The last ingot stays. A rake sends that plate left, into the pit. A belt, a dwell, and a pass send the load forward into the pit. A slip sends the later items forward. A twin refuses the ingot, so the plate never leaves. A shed sends the later item left and keeps the plate. A hook also turns left into the pit. The grate passes the plates into the bin and drops ore and ingots into the pit.",
		"w": 6,
		"h": 5,
		"sources": [
			source(1, 4, rules.Dir.NORTH, [rules.Mat.PLATE, rules.Mat.INGOT], 1),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 4),
		],
		"sinks": [sink(5, 3, [rules.Mat.PLATE])],
		"chutes": [cell(0, 3), cell(1, 2), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.HOE, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 29]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HOE, 1, 3, rules.Dir.NORTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 4, 3, rules.Dir.EAST),
		],
	}


static func push_ore_hoe() -> Dictionary:
	var rules = Rules
	# Push Ore, with the kiln on the hoe's right. A rake sends the ore left.
	return {
		"id": 114,
		"name": "Push Ore",
		"blurb": "The hoe holds the first ore until a plate arrives, then sends that ore right into the kiln. A rake sends the ore left.",
		"rule": "The hoe holds the first ore until a plate arrives from behind, then sends that ore right. The filter scraps plates and feeds the ore to the kiln. The last plate stays. A rake sends the ore left, into the pit, so the kiln gets nothing. A shed keeps the first ore and sends the plate left. A hook releases left into the pit. A belt, a dwell, and a pass send the ore forward into the pit. A slip sends the plate forward and keeps the ore. A twin refuses the plate, so the ore never leaves.",
		"w": 8,
		"h": 5,
		"sources": [
			source(1, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 3),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 6),
		],
		"sinks": [sink(7, 3, [rules.Mat.INGOT])],
		"chutes": [cell(0, 3), cell(1, 2), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.HOE, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 19]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HOE, 1, 3, rules.Dir.NORTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 3, rules.Dir.EAST),
		],
	}


static func still_hoe() -> Dictionary:
	var rules = Rules
	# Still Rake's single belt stays on the crossing. The hoe sends the first
	# ore right, out of the pit, once a plate arrives.
	return {
		"id": 115,
		"name": "Still Hoe",
		"blurb": "The tray has one belt, on the crossing. The hoe sends the first item right, out of the pit, and the last item stays.",
		"rule": "The tray has one belt. It has to stay on the crossing in front of the filter, and the kiln sits against the bin. Two rollers bring the plate onto that belt. The hoe holds the first ore until a plate arrives, then sends that ore right, and the last plate stays. A rake sends the first ore left, into the pit. A shed keeps the ore and sends the plate left. A belt, a dwell, and a pass release the load forward into the pit. A slip sends the plate forward and keeps the ore. A twin refuses the plate, so the ore never leaves. A hook also turns the ore left, into the pit.",
		"w": 7,
		"h": 5,
		"sources": [
			source(1, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 4),
		],
		"sinks": [sink(6, 3, [rules.Mat.INGOT])],
		"chutes": [cell(0, 3), cell(1, 2), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.ROLLER, 2,
			rules.Kind.HOE, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HOE, 1, 3, rules.Dir.NORTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.ROLLER, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.ROLLER, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
		],
	}


static func seat_hoe() -> Dictionary:
	var rules = Rules
	# Same lane as Draw Right. The hoe starts off the row, aimed the wrong way.
	return {
		"id": 116,
		"name": "Seat",
		"blurb": "That hoe is off the lane. Pick it up and seat it where the first item has to leave right.",
		"rule": "Pickup puts this hoe back on the tray. Seat it on the plate lane, pointing north, so the first plate waits for an ingot and then leaves right, missing the ore crossing. It starts off the route. A rake on that cell sends the plate left, into the pit. A shed keeps the plate and sends the ingot left. A belt sends the plate forward on the next tick. A dwell and a pass release it forward into the pit. A slip sends the later items forward. A twin refuses the ingot, so the plate never leaves. A hook seated there also turns left, into the pit.",
		"w": 6,
		"h": 5,
		"sources": [
			source(1, 4, rules.Dir.NORTH, [rules.Mat.PLATE, rules.Mat.INGOT], 1),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 4),
		],
		"sinks": [sink(5, 3, [rules.Mat.PLATE])],
		"chutes": [cell(0, 3), cell(1, 2), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.HOE, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 29]),
		"initial": [
			piece(rules.Kind.HOE, 0, 4, rules.Dir.WEST),
		],
		"solution": [
			piece(rules.Kind.HOE, 1, 3, rules.Dir.NORTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 4, 3, rules.Dir.EAST),
		],
	}


static func corner_hoe() -> Dictionary:
	var rules = Rules
	# The straight east lane is walled. Two belts bring the stream north into
	# the back of the hoe, and the hoe sends the waiting item right.
	return {
		"id": 117,
		"name": "Corner",
		"blurb": "A wall closes the straight lane. Bring the later items into the back of the hoe.",
		"rule": "The wall blocks a straight lane. Bring the ingots and the plates east, then north into the back of the hoe. The first ingot waits until a plate arrives, then leaves right, and later plates follow on the clear phase. The last ingot stays. The grate passes the plates into the bin. A rake sends those items left, into the pit. A hook releases a tick sooner, also left. A belt on that cell sends the load forward into the pit, and a dwell and a pass do too. A slip sends the arrival forward. A twin refuses the plate, so the ingot never leaves. A shed sends the arrival left. A belt that runs east into the wall delivers nothing.",
		"w": 8,
		"h": 5,
		"sources": [
			source(1, 4, rules.Dir.EAST, [rules.Mat.INGOT, rules.Mat.PLATE], 2),
			source(5, 1, rules.Dir.SOUTH, [rules.Mat.ORE], 4),
		],
		"sinks": [sink(7, 3, [rules.Mat.PLATE])],
		"chutes": [cell(2, 3), cell(3, 2), cell(6, 4)],
		"walls": [cell(4, 4), cell(4, 2), cell(6, 2), cell(7, 2)],
		"budget": kv([rules.Kind.BELT, 4, rules.Kind.HOE, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 2, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 4, rules.Dir.NORTH),
			piece(rules.Kind.HOE, 3, 3, rules.Dir.NORTH),
			piece(rules.Kind.WEIR, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 6, 3, rules.Dir.EAST),
		],
	}


static func right_heat() -> Dictionary:
	var rules = Rules
	# The weir kilns sit on the hoe's right. The left belt is its own kiln,
	# and it is also where a rake dumps the waiting ore.
	return {
		"id": 118,
		"name": "Right Heat",
		"blurb": "The hoe's right exit feeds the kilns with the waiting item. A rake feeds the left lane, and one kiln misses.",
		"rule": "The hoe takes the stream from behind and refuses the plate aimed at its front. It holds each ore until the next item arrives, then sends that ore right. The filter scraps the plate in the stream. The weir keeps the forward kiln full and spills the rest into a second kiln. The lane to the left has its own kiln. A rake sends the waiting ore left into that lane, and the right kilns miss. A hook and a shed also turn left. A belt, a dwell, and a pass release forward, into the plate, so only the left kiln remains. A slip sends the arrival forward. A twin refuses the plate, so the ore stops. One kiln cannot reach the quota.",
		"w": 8,
		"h": 5,
		"sources": [
			source(1, 2, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.ORE, rules.Mat.PLATE, rules.Mat.ORE], 1),
			source(1, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 1),
			source(0, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 2),
		],
		"sinks": [
			sink(7, 1, [rules.Mat.INGOT]),
			sink(4, 3, [rules.Mat.INGOT]),
			sink(0, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.HOE, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.KILN, 3,
		]),
		"quota": kv([rules.Mat.INGOT, 145]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HOE, 1, 1, rules.Dir.NORTH),
			piece(rules.Kind.FILTER, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 0, 1, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 0, 2, rules.Dir.SOUTH),
		],
	}


static func after_push_hoe() -> Dictionary:
	var rules = Rules
	# After the Push, with the hoe sending the first ore right when a plate
	# arrives. Left is the scrap pit. Forward meets the scrap stream.
	return {
		"id": 119,
		"name": "After the Push",
		"blurb": "The filter scraps one stream. The hoe sends the first ore right, away from the scrap, when a later item arrives.",
		"rule": "A scrap stream of ingots crosses the belt in front of the filter. The hoe holds the first ore until a plate arrives, then sends that ore right, clear of the scrap, and the filter feeds the kiln. The last plate stays. A rake sends that ore left, into the scrap pit, so the kiln gets nothing. A shed sends the later plate left and keeps the ore. A belt, a dwell, and a pass send the ore forward into the scrap. A slip sends the plate forward and keeps the ore. A twin refuses the plate, so the ore never leaves. A hook also turns the ore left, into the scrap. Ingots that do land on the filter fall into the pit. Without the filter the ingots jam the kiln.",
		"w": 8,
		"h": 5,
		"sources": [
			source(1, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [sink(7, 3, [rules.Mat.INGOT])],
		"chutes": [cell(0, 3), cell(1, 2), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.HOE, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HOE, 1, 3, rules.Dir.NORTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 3, rules.Dir.EAST),
		],
	}


static func side_bin_hoe() -> Dictionary:
	var rules = Rules
	# Side Bin's splitter, fed from the hoe's right. The first plate leaves
	# right and is scrapped. The ores that follow are smelted and split.
	# The lower plates on period 4 are 30, short of the plate quota.
	return {
		"id": 120,
		"name": "Side Bin",
		"blurb": "The hoe sends the first plate right, and the items that leave right split between the bin and the press.",
		"rule": "The hoe sends the first plate right when the next ore arrives, then sends that ore right when the following ore arrives. The filter scraps the plate and the crossing plates, and the kiln smelts the ore. Split the ingots between the bin and the press. The last ore stays. The lower plates are not enough alone. A rake sends the load left, into the pit, so both quotas miss. A shed keeps the plate and sends the later ore left. A belt, a dwell, a pass, or a slip dumps the load into the pit. A twin refuses the ore behind the plate, so the plate never leaves. A hook also sends the load left. Pressing every ingot misses the ingot bin.",
		"w": 10,
		"h": 6,
		"sources": [
			source(0, 5, rules.Dir.EAST, [rules.Mat.PLATE], 4),
			source(1, 4, rules.Dir.NORTH, [rules.Mat.PLATE, rules.Mat.ORE, rules.Mat.ORE], 1),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 6),
		],
		"sinks": [
			sink(3, 5, [rules.Mat.PLATE]),
			sink(9, 3, [rules.Mat.INGOT]),
			sink(9, 4, [rules.Mat.PLATE]),
		],
		"chutes": [cell(0, 3), cell(1, 2), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 9,
			rules.Kind.HOE, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 19, rules.Mat.PLATE, 39]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 5, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 5, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.HOE, 1, 3, rules.Dir.NORTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 6, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 7, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 8, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 4, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 7, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 8, 4, rules.Dir.EAST),
		],
	}


static func late_draw() -> Dictionary:
	var rules = Rules
	# Hold's lane, turned so the exit is right. The harrow faces north:
	# behind is the plate source, right is the eastbound weir, forward is a pit.
	return {
		"id": 121,
		"name": "Late Draw",
		"blurb": "The first plate stays in the harrow. A later plate leaves right. A hoe sends that plate right.",
		"rule": "A harrow holds one item and takes it only from behind. The first plate stays. Every later item moves one cell to the right on the tick it arrives, and that plate remains the waiting item. A hoe sends the first plate right and keeps the arrival, so the plates hit the ore crossing and the weir dumps them. A rake, a shed, and a hook send left, into the pit. A belt, a dwell, a pass, and a slip send the load forward into the pit. A twin refuses the ingot, so the plate never leaves. The grate passes later plates into the bin and drops ore and ingots into the pit.",
		"w": 6,
		"h": 5,
		"sources": [
			source(1, 4, rules.Dir.NORTH, [rules.Mat.PLATE, rules.Mat.INGOT], 2),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 4),
		],
		"sinks": [sink(5, 3, [rules.Mat.PLATE])],
		"chutes": [cell(0, 3), cell(1, 2), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.HARROW, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 29]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HARROW, 1, 3, rules.Dir.NORTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 4, 3, rules.Dir.EAST),
		],
	}


static func second_ore() -> Dictionary:
	var rules = Rules
	# The first item is a plate and stays. Ore that arrives behind it leaves
	# right. The filter scraps plates and the kiln takes the ore.
	return {
		"id": 122,
		"name": "Second Ore",
		"blurb": "The first plate stays. The ore that arrives behind it leaves right into the kiln. A hoe sends the plate and holds the ore.",
		"rule": "The harrow holds the first plate and lets the ore out to the right. The filter scraps plates and feeds that ore to the kiln. A hoe sends the plate right and holds the ore, so the kiln stays empty. A rake, a shed, and a hook send left, into the pit. A belt, a dwell, a pass, and a slip send the load forward into the pit. A twin refuses the ore behind the plate, so the plate never leaves.",
		"w": 8,
		"h": 5,
		"sources": [
			source(1, 4, rules.Dir.NORTH, [rules.Mat.PLATE, rules.Mat.ORE], 1),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 4),
		],
		"sinks": [sink(7, 3, [rules.Mat.INGOT])],
		"chutes": [cell(0, 3), cell(1, 2), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.HARROW, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HARROW, 1, 3, rules.Dir.NORTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 3, rules.Dir.EAST),
		],
	}


static func still_harrow() -> Dictionary:
	var rules = Rules
	# Still's single belt stays on the crossing. The first ore stays.
	# Later ore leaves right, out of the pit.
	return {
		"id": 123,
		"name": "Still Harrow",
		"blurb": "The tray has one belt, on the crossing. The first item stays. Later items leave right, out of the pit.",
		"rule": "The tray has one belt. It has to stay on the crossing in front of the filter, and the kiln sits against the bin. Two rollers bring the plate onto that belt. The harrow keeps the first ore and lets later ore out to the right after the crossing plate has left. A hoe sends that first ore right, into the crossing, and the weir dumps it. A rake, a shed, and a hook send left, into the pit. A belt, a dwell, a pass, and a slip release the load forward into the pit. A twin refuses the plate, so the ore never leaves.",
		"w": 7,
		"h": 5,
		"sources": [
			source(1, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 4),
		],
		"sinks": [sink(6, 3, [rules.Mat.INGOT])],
		"chutes": [cell(0, 3), cell(1, 2), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.ROLLER, 2,
			rules.Kind.HARROW, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HARROW, 1, 3, rules.Dir.NORTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.ROLLER, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.ROLLER, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
		],
	}


static func seat_harrow() -> Dictionary:
	var rules = Rules
	# Same lane as Late Draw. The harrow starts off the row, aimed the wrong way.
	return {
		"id": 124,
		"name": "Seat",
		"blurb": "That harrow is off the lane. Seat it where the later item leaves right and the first item stays.",
		"rule": "Pickup puts this harrow back on the tray. Seat it on the plate lane, pointing north, so the first plate stays and later plates leave right, missing the ore crossing. It starts off the route. A hoe on that cell sends the first plate right, into the crossing, and the weir dumps the plates. A rake, a shed, and a hook send left, into the pit. A belt sends the plate forward on the next tick. A dwell, a pass, and a slip release it forward into the pit. A twin refuses the ingot, so the plate never leaves.",
		"w": 6,
		"h": 5,
		"sources": [
			source(1, 4, rules.Dir.NORTH, [rules.Mat.PLATE, rules.Mat.INGOT], 2),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE], 4),
		],
		"sinks": [sink(5, 3, [rules.Mat.PLATE])],
		"chutes": [cell(0, 3), cell(1, 2), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([rules.Kind.BELT, 3, rules.Kind.HARROW, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 29]),
		"initial": [
			piece(rules.Kind.HARROW, 0, 4, rules.Dir.WEST),
		],
		"solution": [
			piece(rules.Kind.HARROW, 1, 3, rules.Dir.NORTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 4, 3, rules.Dir.EAST),
		],
	}


static func late_corner() -> Dictionary:
	var rules = Rules
	# The straight east lane is walled. Two belts bring the stream north into
	# the back of the harrow, and later items leave right.
	return {
		"id": 125,
		"name": "Late Corner",
		"blurb": "A wall closes the straight lane. Later items enter from behind and leave right.",
		"rule": "The wall blocks a straight lane. Bring the ingots and the plates east, then north into the back of the harrow. The first ingot stays, and later plates leave right and miss the ore crossing. The grate passes them into the bin. A hoe sends that first ingot right and finishes one plate short. A rake, a shed, and a hook send left, into the pit. A belt on that cell sends the load forward into the pit, and a dwell, a pass, and a slip do too. A twin refuses the plate, so the ingot never leaves. A belt that runs east into the wall delivers nothing.",
		"w": 8,
		"h": 5,
		"sources": [
			source(1, 4, rules.Dir.EAST, [rules.Mat.INGOT, rules.Mat.PLATE], 1),
			source(5, 1, rules.Dir.SOUTH, [rules.Mat.ORE], 4),
		],
		"sinks": [sink(7, 3, [rules.Mat.PLATE])],
		"chutes": [cell(2, 3), cell(3, 2), cell(6, 4)],
		"walls": [cell(4, 4), cell(4, 2), cell(6, 2), cell(7, 2)],
		"budget": kv([rules.Kind.BELT, 4, rules.Kind.HARROW, 1, rules.Kind.WEIR, 1, rules.Kind.GRATE, 1]),
		"quota": kv([rules.Mat.PLATE, 43]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 2, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 4, rules.Dir.NORTH),
			piece(rules.Kind.HARROW, 3, 3, rules.Dir.NORTH),
			piece(rules.Kind.WEIR, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 6, 3, rules.Dir.EAST),
		],
	}


static func arrival_heat() -> Dictionary:
	var rules = Rules
	# Spare Heat turned onto the right exit. The arrival is ore. The waiter
	# is the first plate. A hoe sends that plate and holds an ore.
	return {
		"id": 126,
		"name": "Arrival Heat",
		"blurb": "The right exit feeds the kilns with the arrival. A hoe feeds them with the waiter.",
		"rule": "The harrow takes the stream from behind and refuses the plate aimed at its side. It keeps the first plate and lets the ore out to the right. The filter scraps later plates. The weir keeps the forward kiln full and spills the rest into a second kiln. One kiln misses the quota. A hoe sends the plate right and holds an ore, so the kilns miss. A rake, a shed, and a hook send left, off the kilns. A belt accepts the side plate, so the ore never enters. A dwell, a pass, and a slip release forward, into the pit. A twin refuses the ore behind the plate, so the ore stops.",
		"w": 8,
		"h": 4,
		"sources": [
			source(1, 2, rules.Dir.NORTH, [rules.Mat.PLATE, rules.Mat.ORE, rules.Mat.ORE, rules.Mat.ORE], 1),
			source(0, 1, rules.Dir.EAST, [rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(7, 1, [rules.Mat.INGOT]),
			sink(4, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(1, 0), cell(2, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.HARROW, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.KILN, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 86]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HARROW, 1, 1, rules.Dir.NORTH),
			piece(rules.Kind.FILTER, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
		],
	}


static func after_stay_harrow() -> Dictionary:
	var rules = Rules
	# After the Hold, with the harrow keeping the first ore and letting later
	# ore out to the right, clear of the scrap.
	return {
		"id": 127,
		"name": "After the Stay",
		"blurb": "The filter scraps one stream. The harrow sends the later ore right, and the first item stays.",
		"rule": "A scrap stream of ingots crosses the belt in front of the filter. The harrow keeps the first ore and lets later ore out to the right after that stream has passed, and the filter sends it into the kiln. A hoe sends that first ore right, into the scrap, and the weir dumps it. A rake, a shed, and a hook send left, into the pit. A belt, a dwell, a pass, and a slip send the ore forward into the pit. A twin refuses the plate, so the ore never leaves. Ingots that do land fall into the pit. Without the filter the ingots jam the kiln.",
		"w": 8,
		"h": 5,
		"sources": [
			source(1, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [sink(7, 3, [rules.Mat.INGOT])],
		"chutes": [cell(0, 3), cell(1, 2), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.HARROW, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 28]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HARROW, 1, 3, rules.Dir.NORTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 3, rules.Dir.EAST),
		],
	}


static func late_bin() -> Dictionary:
	var rules = Rules
	# One Bin's splitter, fed from the harrow's right. The first plate stays.
	# Later ore leaves right, is smelted, and splits.
	return {
		"id": 128,
		"name": "Late Bin",
		"blurb": "The arrivals that leave right split between the bin and the press. A hoe sends the waiter instead.",
		"rule": "The harrow keeps the first plate and lets the ore out to the right, into the kiln. The filter scraps the crossing plates. Split the ingots between the bin and the press. The lower plates are not enough alone. A hoe sends the plate and holds the ore, so both quotas miss. A rake, a shed, and a hook send left, into the pit. A belt, a dwell, a pass, or a slip dumps the load into the pit. A twin refuses the ore behind the plate, so the plate never leaves. Pressing every ingot misses the ingot bin.",
		"w": 10,
		"h": 6,
		"sources": [
			source(0, 5, rules.Dir.EAST, [rules.Mat.PLATE], 4),
			source(1, 4, rules.Dir.NORTH, [rules.Mat.PLATE, rules.Mat.ORE], 1),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 6),
		],
		"sinks": [
			sink(3, 5, [rules.Mat.PLATE]),
			sink(9, 3, [rules.Mat.INGOT]),
			sink(9, 4, [rules.Mat.PLATE]),
		],
		"chutes": [cell(0, 3), cell(1, 2), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 9,
			rules.Kind.HARROW, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 19, rules.Mat.PLATE, 39]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 5, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 5, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.HARROW, 1, 3, rules.Dir.NORTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 6, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 7, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 8, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 4, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 7, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 8, 4, rules.Dir.EAST),
		],
	}



static func both_ways() -> Dictionary:
	var rules = Rules
	# One belt on the left. The right bin sits on the fork.
	# Both halves are required: either direction alone is one plate short.
	return {
		"id": 129,
		"name": "Both Ways",
		"blurb": "The first plate leaves left and the later plate leaves right. A harrow covers only the right.",
		"rule": "The fork sends the first plate left and the later plate right. The left bin is one belt away, and the right bin is on the fork. Both bins together are the quota. A harrow sends only the later plate right, so the left half misses. A rake sends only the first plate left, so the right half misses. A hoe, a shed, and a hook each cover only one side and finish one plate short. A belt, a dwell, a twin, a pass, or a slip dumps the plates into the pit ahead.",
		"w": 6,
		"h": 3,
		"sources": [
			source(2, 2, rules.Dir.NORTH, [rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(0, 1, [rules.Mat.PLATE]),
			sink(3, 1, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 0)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.FORK, 1,
		]),
		"quota": kv([rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.FORK, 2, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 1, 1, rules.Dir.WEST),
		],
	}


static func split_ore() -> Dictionary:
	var rules = Rules
	# Ore left into the kiln. The plate behind it leaves right into the bin.
	# A press refuses a plate, so the right exit is the plate bin.
	return {
		"id": 130,
		"name": "Split Ore",
		"blurb": "The first item is ore and leaves left into a kiln. The plate behind it leaves right into the bin.",
		"rule": "The first item is ore. It leaves left into the kiln. The plate that arrives behind it leaves right into the plate bin. A hoe sends the ore onto that plate line and holds the plate, so the kiln misses and the plate never reaches the bin. A harrow sends the plate right and holds the ore, so the kiln misses. A rake, a shed, and a hook send left and stall. A belt, a dwell, a pass, or a slip dumps the load into the pit. A twin refuses the plate behind the ore.",
		"w": 7,
		"h": 5,
		"sources": [
			source(3, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(0, 3, [rules.Mat.INGOT]),
			sink(6, 3, [rules.Mat.PLATE]),
		],
		"chutes": [cell(3, 2), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.KILN, 1,
			rules.Kind.FORK, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 29]),
		"initial": [],
		"solution": [
			piece(rules.Kind.FORK, 3, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.WEST),
			piece(rules.Kind.KILN, 1, 3, rules.Dir.WEST),
			piece(rules.Kind.BELT, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 3, rules.Dir.EAST),
		],
	}


static func still_fork() -> Dictionary:
	var rules = Rules
	# One belt, on the crossing. The first ore waits, then leaves left.
	# The plate leaves right, beside the scrap pit.
	return {
		"id": 131,
		"name": "Still Fork",
		"blurb": "The tray has one belt, on the crossing. The first item stays until a later item arrives, then the two leave opposite ways.",
		"rule": "The tray has one belt, on the crossing. The first ore stays until a plate arrives. Then the ore leaves left into the kiln, out of the forward pit, and the plate leaves right, out of the scrap pit. A harrow sends only the plate right, and the ore stays, so the kiln misses. A hoe, a rake, a shed, and a hook miss the room. A belt, a dwell, a twin, a pass, or a slip dumps the load into the pit.",
		"w": 7,
		"h": 5,
		"sources": [
			source(2, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(4, 0, rules.Dir.SOUTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(0, 3, [rules.Mat.INGOT]),
			sink(3, 4, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 2), cell(5, 4), cell(6, 3)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.ROLLER, 2,
			rules.Kind.FORK, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.FORK, 2, 3, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 1, 3, rules.Dir.WEST),
			piece(rules.Kind.WEIR, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.ROLLER, 4, 1, rules.Dir.SOUTH),
			piece(rules.Kind.ROLLER, 4, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 5, 3, rules.Dir.EAST),
		],
	}


static func seat_fork() -> Dictionary:
	var rules = Rules
	# The fork starts off the lane. Seat it on the both-ways split.
	return {
		"id": 132,
		"name": "Seat",
		"blurb": "The fork starts off the lane. Seat it where the first item leaves left and the later item leaves right.",
		"rule": "The fork starts off the lane. Pick it up and seat it where the first plate has to leave left and the later plate has to leave right. Leaving it parked misses. A harrow seated there sends only the later plate right, so one side misses. A rake seated there sends only the first plate left. A hoe, a shed, and a hook each cover only one side. A belt, a dwell, a twin, a pass, or a slip dumps the plates into the pit.",
		"w": 6,
		"h": 3,
		"sources": [
			source(2, 2, rules.Dir.NORTH, [rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(0, 1, [rules.Mat.PLATE]),
			sink(3, 1, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 0)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.FORK, 1,
		]),
		"quota": kv([rules.Mat.PLATE, 60]),
		"initial": [
			piece(rules.Kind.FORK, 0, 2, rules.Dir.WEST),
		],
		"solution": [
			piece(rules.Kind.FORK, 2, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 1, 1, rules.Dir.WEST),
		],
	}


static func split_corner() -> Dictionary:
	var rules = Rules
	# The wall closes the straight lane. Ore left, plate right through the grate.
	return {
		"id": 133,
		"name": "Split Corner",
		"blurb": "A wall closes the straight lane. The waiter leaves left and the arrival leaves right.",
		"rule": "A wall closes the straight lane. Later items enter from behind. The ore leaves left into the kiln and the plate leaves right. The grate passes plates and scraps ore that is sent right. A harrow covers only the right: the plates arrive and the kiln stays empty. A hoe covers only the right as well. A rake and a hook send left and stall the kiln with a plate. Belts that run into the wall deliver nothing. A belt, a dwell, a twin, a pass, a slip, or a shed in the fork cell misses.",
		"w": 8,
		"h": 5,
		"sources": [
			source(1, 4, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(0, 3, [rules.Mat.INGOT]),
			sink(7, 3, [rules.Mat.PLATE]),
		],
		"chutes": [cell(3, 2), cell(5, 4)],
		"walls": [cell(4, 4)],
		"budget": kv([
			rules.Kind.BELT, 5,
			rules.Kind.FORK, 1,
			rules.Kind.KILN, 1,
			rules.Kind.GRATE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 57, rules.Mat.PLATE, 57]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 2, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 4, rules.Dir.NORTH),
			piece(rules.Kind.FORK, 3, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.WEST),
			piece(rules.Kind.KILN, 1, 3, rules.Dir.WEST),
			piece(rules.Kind.BELT, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 3, rules.Dir.EAST),
		],
	}


static func two_heats() -> Dictionary:
	var rules = Rules
	# The waiter feeds the left kiln. The arrival feeds the right kiln.
	return {
		"id": 134,
		"name": "Two Heats",
		"blurb": "The left exit feeds one kiln with the waiter. The right exit feeds another kiln with the arrival.",
		"rule": "The left kiln is fed by the waiting ore. The right kiln is fed by the ore that arrives behind it. One side is half the quota. A hoe feeds only the right with the waiter. A harrow feeds only the right with the arrival. A rake, a shed, and a hook each cover one side and miss. A belt, a dwell, a twin, a pass, or a slip dumps the ore into the pit.",
		"w": 9,
		"h": 4,
		"sources": [
			source(4, 3, rules.Dir.NORTH, [rules.Mat.ORE], 1),
		],
		"sinks": [
			sink(0, 2, [rules.Mat.INGOT]),
			sink(8, 2, [rules.Mat.INGOT]),
		],
		"chutes": [cell(4, 1)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.KILN, 2,
			rules.Kind.FORK, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 116]),
		"initial": [],
		"solution": [
			piece(rules.Kind.FORK, 4, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.WEST),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.WEST),
			piece(rules.Kind.BELT, 1, 2, rules.Dir.WEST),
			piece(rules.Kind.BELT, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 6, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 7, 2, rules.Dir.EAST),
		],
	}


static func after_split() -> Dictionary:
	var rules = Rules
	# The filter scraps the crossing. Ore leaves left. The plate leaves right.
	return {
		"id": 135,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The fork sends the ore left, away from the scrap, and the other item right.",
		"rule": "A filter scraps the crossing ingots. The fork sends the ore left, away from the scrap, into the kiln, and the plate right into the bin. A harrow keeps the ore, and the right line stalls, so both quotas miss. A hoe, a rake, a shed, and a hook miss. A belt, a dwell, a twin, a pass, or a slip dumps the load into the pit.",
		"w": 7,
		"h": 5,
		"sources": [
			source(2, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(4, 0, rules.Dir.SOUTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(0, 3, [rules.Mat.INGOT]),
			sink(3, 4, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 2), cell(5, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.FORK, 1,
			rules.Kind.KILN, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.FORK, 2, 3, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 1, 3, rules.Dir.WEST),
			piece(rules.Kind.WEIR, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 5, 3, rules.Dir.EAST),
		],
	}


static func split_bin() -> Dictionary:
	var rules = Rules
	# Plates leave left into their own bin. Ore leaves right, is smelted, and splits.
	return {
		"id": 136,
		"name": "Split Bin",
		"blurb": "The left stream and the right stream each reach a different quota. A harrow, a hoe, and a rake each miss at least one.",
		"rule": "The fork sends the plates left into their bin and the ore right into the kiln. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. A harrow keeps the plates and still feeds the kiln, so the ingot count is met and the plate count misses. A hoe and a rake each miss at least one quota. A belt, a dwell, a twin, a pass, a slip, a shed, and a hook miss both. Pressing every ingot misses the ingot bin.",
		"w": 10,
		"h": 6,
		"sources": [
			source(0, 5, rules.Dir.EAST, [rules.Mat.PLATE], 4),
			source(1, 4, rules.Dir.NORTH, [rules.Mat.PLATE, rules.Mat.ORE], 1),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 6),
		],
		"sinks": [
			sink(0, 3, [rules.Mat.PLATE]),
			sink(3, 5, [rules.Mat.PLATE]),
			sink(9, 3, [rules.Mat.INGOT]),
			sink(9, 4, [rules.Mat.PLATE]),
		],
		"chutes": [cell(1, 2), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 9,
			rules.Kind.FORK, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 19, rules.Mat.PLATE, 99]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 5, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 5, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.FORK, 1, 3, rules.Dir.NORTH),
			piece(rules.Kind.WEIR, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 6, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 7, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 8, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 4, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 7, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 8, 4, rules.Dir.EAST),
		],
	}


static func both_ways_prong() -> Dictionary:
	var rules = Rules
	# The right sink sits on the prong. The left sink is one belt away.
	# Both halves are required. A hook through that belt finishes one plate short.
	return {
		"id": 137,
		"name": "Both Ways",
		"blurb": "The first plate leaves right and the later plate leaves left. A fork sends them the other way.",
		"rule": "The prong sends the first plate right and the later plate left. The right bin is on the prong, and the left bin is one belt away. Both bins together are the quota. A fork sends the first plate left and the later plate right, and both bins still fill. A harrow sends only the later plate right, so the quota misses by one. A hoe sends only the first plate right. A rake sends only the first plate left. A shed and a hook each cover only the left and finish one plate short. A belt, a dwell, a twin, a pass, or a slip dumps the plates into the pit ahead.",
		"w": 6,
		"h": 3,
		"sources": [
			source(3, 2, rules.Dir.NORTH, [rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(4, 1, [rules.Mat.PLATE]),
			sink(1, 1, [rules.Mat.PLATE]),
		],
		"chutes": [cell(3, 0)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.PRONG, 1,
		]),
		"quota": kv([rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.PRONG, 3, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.WEST),
		],
	}


static func split_ore_prong() -> Dictionary:
	var rules = Rules
	# Ore right into the kiln. The plate behind it leaves left into the bin.
	return {
		"id": 138,
		"name": "Split Ore",
		"blurb": "The first item is ore and leaves right into a kiln. The plate behind it leaves left into the bin.",
		"rule": "The first item is ore. It leaves right into the kiln. The plate that arrives behind it leaves left into the plate bin. A fork sends the ore left onto the plate line and the plate right toward the kiln. The kiln refuses that plate and the plate bin refuses the ore, so both quotas miss. A hoe sends the ore right and holds the plate, so the plate never reaches the bin. A harrow sends the plate right and holds the ore, so the kiln misses. A rake, a shed, and a hook send left and stall. A belt, a dwell, a pass, or a slip dumps the load into the pit. A twin refuses the plate behind the ore.",
		"w": 7,
		"h": 5,
		"sources": [
			source(3, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(6, 3, [rules.Mat.INGOT]),
			sink(0, 3, [rules.Mat.PLATE]),
		],
		"chutes": [cell(3, 2), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.KILN, 1,
			rules.Kind.PRONG, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 29]),
		"initial": [],
		"solution": [
			piece(rules.Kind.PRONG, 3, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.WEST),
			piece(rules.Kind.BELT, 1, 3, rules.Dir.WEST),
		],
	}


static func still_prong() -> Dictionary:
	var rules = Rules
	# The prong faces south so its right exit is the kiln and its left exit is
	# the weir. The weir is west of the crossing belt, so the belt is still
	# full when the plate looks for a way out and spills into the bin.
	return {
		"id": 139,
		"name": "Still Prong",
		"blurb": "The tray has one belt, on the crossing. The first item leaves right out of a pit and the later item leaves left out of a pit.",
		"rule": "The tray has one belt, on the crossing. The prong faces south. The first ore stays until a plate arrives, then leaves right into the kiln, out of the forward pit, and the plate leaves left. The crossing belt is full, so the weir spills that plate into the bin, out of the scrap pit. A fork sends the plate toward the kiln and the ore toward the scrap, so the kiln refuses the plate and the pair stays. A harrow, a hoe, a rake, a shed, and a hook miss the room. A belt, a dwell, a twin, a pass, or a slip dumps the load into the pit.",
		"w": 7,
		"h": 5,
		"sources": [
			source(2, 0, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(4, 4, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(0, 1, [rules.Mat.INGOT]),
			sink(3, 2, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 2), cell(5, 2), cell(6, 1)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.ROLLER, 2,
			rules.Kind.PRONG, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.PRONG, 2, 1, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
			piece(rules.Kind.WEIR, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.ROLLER, 4, 2, rules.Dir.NORTH),
			piece(rules.Kind.ROLLER, 4, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 5, 1, rules.Dir.EAST),
		],
	}


static func seat_prong() -> Dictionary:
	var rules = Rules
	# The prong starts off the lane. Seat it on the both-ways split.
	return {
		"id": 140,
		"name": "Seat",
		"blurb": "The prong starts off the lane. Seat it where the first item leaves right and the later item leaves left.",
		"rule": "The prong starts off the lane. Pick it up and seat it where the first plate has to leave right and the later plate has to leave left. Leaving it parked misses. A fork seated there sends the plates the other way, and both bins still fill. A harrow seated there sends only the later plate right, so one side misses. A rake seated there sends only the first plate left. A hoe, a shed, and a hook each cover only one side. A belt, a dwell, a twin, a pass, or a slip dumps the plates into the pit.",
		"w": 6,
		"h": 3,
		"sources": [
			source(3, 2, rules.Dir.NORTH, [rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(4, 1, [rules.Mat.PLATE]),
			sink(1, 1, [rules.Mat.PLATE]),
		],
		"chutes": [cell(3, 0)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.PRONG, 1,
		]),
		"quota": kv([rules.Mat.PLATE, 60]),
		"initial": [
			piece(rules.Kind.PRONG, 0, 2, rules.Dir.WEST),
		],
		"solution": [
			piece(rules.Kind.PRONG, 3, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.WEST),
		],
	}


static func split_corner_prong() -> Dictionary:
	var rules = Rules
	# The wall closes the straight lane. Ore right, plate left through the grate.
	return {
		"id": 141,
		"name": "Split Corner",
		"blurb": "A wall closes the straight lane. The waiter leaves right and the arrival leaves left.",
		"rule": "A wall closes the straight lane. Later items enter from behind. The ore leaves right into the kiln and the plate leaves left. The grate passes plates and scraps ore that is sent left. A fork sends the plate right toward the kiln and the ore left into the grate, so the ore is scrapped and both quotas miss. A harrow sends the plate toward the kiln and holds the ore, so both quotas miss. A hoe sends one ore right and then stalls. A rake, a shed, and a hook send left, so the grate scraps the ore and the kiln misses. Belts that run into the wall deliver nothing. A belt, a dwell, a twin, a pass, or a slip in the prong cell misses.",
		"w": 8,
		"h": 5,
		"sources": [
			source(2, 4, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(7, 3, [rules.Mat.INGOT]),
			sink(0, 3, [rules.Mat.PLATE]),
		],
		"chutes": [cell(4, 2), cell(2, 2)],
		"walls": [cell(5, 4)],
		"budget": kv([
			rules.Kind.BELT, 5,
			rules.Kind.PRONG, 1,
			rules.Kind.KILN, 1,
			rules.Kind.GRATE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 57, rules.Mat.PLATE, 57]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 3, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 4, rules.Dir.NORTH),
			piece(rules.Kind.PRONG, 4, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 6, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.WEST),
			piece(rules.Kind.GRATE, 2, 3, rules.Dir.WEST),
			piece(rules.Kind.BELT, 1, 3, rules.Dir.WEST),
		],
	}


static func two_heats_prong() -> Dictionary:
	var rules = Rules
	# The waiter feeds the right kiln. The arrival feeds the left kiln.
	return {
		"id": 142,
		"name": "Two Heats",
		"blurb": "The right exit feeds one kiln with the waiter. The left exit feeds another kiln with the arrival.",
		"rule": "The right kiln is fed by the waiting ore. The left kiln is fed by the ore that arrives behind it. One side is half the quota. A fork feeds the kilns the other way around and still meets the count, because both exits accept ore. A hoe feeds only the right with the waiter. A harrow feeds only the right with the arrival. A rake, a shed, and a hook each cover one side and miss. A belt, a dwell, a twin, a pass, or a slip dumps the ore into the pit.",
		"w": 9,
		"h": 4,
		"sources": [
			source(4, 3, rules.Dir.NORTH, [rules.Mat.ORE], 1),
		],
		"sinks": [
			sink(8, 2, [rules.Mat.INGOT]),
			sink(0, 2, [rules.Mat.INGOT]),
		],
		"chutes": [cell(4, 1)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.KILN, 2,
			rules.Kind.PRONG, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 116]),
		"initial": [],
		"solution": [
			piece(rules.Kind.PRONG, 4, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 6, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 7, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.WEST),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.WEST),
			piece(rules.Kind.BELT, 1, 2, rules.Dir.WEST),
		],
	}


static func after_split_prong() -> Dictionary:
	var rules = Rules
	# Same split as Still Prong. Three belts bring the scrap onto the crossing,
	# and the filter throws those ingots into the pit.
	return {
		"id": 143,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The prong sends the ore right, away from the scrap, and the other item left.",
		"rule": "A filter scraps the crossing ingots. The prong faces south. It sends the ore right, away from the scrap, into the kiln, and the plate left. The weir spills that plate into the bin. A fork sends the ore toward the scrap and the plate toward the kiln, so the kiln refuses the plate and the pair stays. A harrow keeps the ore, so both quotas miss. A hoe, a rake, a shed, and a hook miss. A belt, a dwell, a twin, a pass, or a slip dumps the load into the pit.",
		"w": 7,
		"h": 5,
		"sources": [
			source(2, 0, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(4, 4, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(0, 1, [rules.Mat.INGOT]),
			sink(3, 2, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 2), cell(5, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.PRONG, 1,
			rules.Kind.KILN, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.PRONG, 2, 1, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
			piece(rules.Kind.WEIR, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 5, 1, rules.Dir.EAST),
		],
	}


static func split_bin_prong() -> Dictionary:
	var rules = Rules
	# Plates leave right into their own bin. Ore leaves left, is smelted, and splits.
	return {
		"id": 144,
		"name": "Split Bin",
		"blurb": "The right stream and the left stream each reach a different quota. A fork, a harrow, a hoe, and a rake each miss at least one.",
		"rule": "The prong sends the plates right into their bin and the ore left into the kiln. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. A fork sends the plates toward the kiln and the ore toward the plate bin, so the plate bin refuses the ore and the pair stays. A harrow, a hoe, and a rake each miss at least one quota. A belt, a dwell, a twin, a pass, a slip, a shed, and a hook miss both. Pressing every ingot misses the ingot bin.",
		"w": 10,
		"h": 6,
		"sources": [
			source(9, 5, rules.Dir.WEST, [rules.Mat.PLATE], 4),
			source(8, 4, rules.Dir.NORTH, [rules.Mat.PLATE, rules.Mat.ORE], 1),
			source(6, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 6),
		],
		"sinks": [
			sink(9, 3, [rules.Mat.PLATE]),
			sink(6, 5, [rules.Mat.PLATE]),
			sink(0, 3, [rules.Mat.INGOT]),
			sink(0, 2, [rules.Mat.PLATE]),
		],
		"chutes": [cell(8, 2), cell(7, 2), cell(5, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 9,
			rules.Kind.PRONG, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 19, rules.Mat.PLATE, 99]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 8, 5, rules.Dir.WEST),
			piece(rules.Kind.BELT, 7, 5, rules.Dir.WEST),
			piece(rules.Kind.BELT, 6, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 6, 2, rules.Dir.SOUTH),
			piece(rules.Kind.PRONG, 8, 3, rules.Dir.NORTH),
			piece(rules.Kind.WEIR, 7, 3, rules.Dir.WEST),
			piece(rules.Kind.BELT, 6, 3, rules.Dir.WEST),
			piece(rules.Kind.FILTER, 5, 3, rules.Dir.WEST),
			piece(rules.Kind.KILN, 4, 3, rules.Dir.WEST),
			piece(rules.Kind.SPLITTER, 3, 3, rules.Dir.WEST),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.WEST),
			piece(rules.Kind.BELT, 1, 3, rules.Dir.WEST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.WEST),
			piece(rules.Kind.PRESS, 2, 2, rules.Dir.WEST),
			piece(rules.Kind.BELT, 1, 2, rules.Dir.WEST),
		],
	}
