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
## Wing 19 is rooms 145-152.
## Wing 20 is rooms 153-160.
## Wing 21 is rooms 161-168.
## Wing 22 is rooms 169-176.
## Wing 23 is rooms 177-184.
## Wing 24 is rooms 185-192.
## Wing 25 is rooms 193-200.
## Wing 26 is rooms 201-208.
## Wing 27 is rooms 209-216.
## Wing 28 is rooms 217-224.
## Wing 29 is rooms 225-232.
## Wing 30 is rooms 233-240.
## Wing 31 is rooms 241-248.
## Wing 32 is rooms 249-256.
## Wing 33 is rooms 257-264.
## Wing 34 is rooms 265-272.
## Wing 35 is rooms 273-280.
## Wing 36 is rooms 281-288.
## Wing 37 is rooms 289-296.
## Wing 38 is rooms 297-304.
## Wing 39 is rooms 305-312.
## Wing 40 is rooms 313-320.
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
## The share is taught before a later room depends on it.
## The coulter is taught before a later room depends on it.
## The moldboard is taught before a later room depends on it.
## The landside is taught before a later room depends on it.
## The slade is taught before a later room depends on it.
## The heel is taught before a later room depends on it.
## The stilt is taught before a later room depends on it.
## The clevis is taught before a later room depends on it.
## The beam is taught before a later room depends on it.
## The hake is taught before a later room depends on it.
## The sole is taught before a later room depends on it.
## The frog is taught before a later room depends on it.
## The shin is taught before a later room depends on it.
## The point is taught before a later room depends on it.
## The throat is taught before a later room depends on it.
## The wrest is taught before a later room depends on it.
## The jointer is taught before a later room depends on it.
## The bridle is taught before a later room depends on it.
## The trashboard is taught before a later room depends on it.
## The gauge is taught before a later room depends on it.
## The breast is taught before a later room depends on it.
## The hardie is taught before a later room depends on it.
## The roller, the weir, the bridge, the grate, the hook, the arm, the drop, the lift, the dwell, the twin, the pass, the slip, the shed, the rake, the hoe, the harrow, the fork, the prong, the share, the coulter, the moldboard, the landside, the slade, the heel, the stilt, the clevis, the beam, the hake, the sole, the frog, the shin, the point, the throat, the wrest, the jointer, the bridle, the trashboard, the gauge, the breast, and the hardie are taught before a later room depends on them.
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
		forward_left(),
		split_ore_share(),
		still_share(),
		seat_share(),
		split_corner_share(),
		two_heats_share(),
		after_split_share(),
		split_bin_share(),
		forward_right(),
		split_ore_coulter(),
		still_coulter(),
		seat_coulter(),
		split_corner_coulter(),
		two_heats_coulter(),
		after_split_coulter(),
		split_bin_coulter(),
		left_ore(),
		still_moldboard(),
		seat_moldboard(),
		split_corner_moldboard(),
		two_stocks(),
		after_split_moldboard(),
		split_bin_moldboard(),
		held_pair(),
		right_ore(),
		still_landside(),
		seat_landside(),
		split_corner_landside(),
		two_stocks_landside(),
		after_split_landside(),
		split_bin_landside(),
		held_pair_landside(),
		back_ore(),
		still_slade(),
		seat_slade(),
		split_corner_slade(),
		two_stocks_slade(),
		after_split_slade(),
		split_bin_slade(),
		held_pair_slade(),
		forward_ore(),
		still_heel(),
		seat_heel(),
		split_corner_heel(),
		two_stocks_heel(),
		after_split_heel(),
		split_bin_heel(),
		held_pair_heel(),
		left_ore_stilt(),
		still_stilt(),
		seat_stilt(),
		split_corner_stilt(),
		two_stocks_stilt(),
		after_split_stilt(),
		split_bin_stilt(),
		held_pair_stilt(),
		right_ore_clevis(),
		still_clevis(),
		seat_clevis(),
		split_corner_clevis(),
		two_stocks_clevis(),
		after_split_clevis(),
		split_bin_clevis(),
		held_pair_clevis(),
		ahead_ore_beam(),
		still_beam(),
		seat_beam(),
		split_corner_beam(),
		two_stocks_beam(),
		after_split_beam(),
		split_bin_beam(),
		held_pair_beam(),
		ahead_ore_hake(),
		still_hake(),
		seat_hake(),
		split_corner_hake(),
		two_stocks_hake(),
		after_split_hake(),
		split_bin_hake(),
		held_pair_hake(),
		ahead_ore_sole(),
		still_sole(),
		seat_sole(),
		split_corner_sole(),
		two_stocks_sole(),
		after_split_sole(),
		split_bin_sole(),
		held_pair_sole(),
		ahead_ore_frog(),
		still_frog(),
		seat_frog(),
		split_corner_frog(),
		two_stocks_frog(),
		after_split_frog(),
		split_bin_frog(),
		held_pair_frog(),
		ahead_ore_shin(),
		still_shin(),
		seat_shin(),
		split_corner_shin(),
		two_stocks_shin(),
		after_split_shin(),
		split_bin_shin(),
		held_pair_shin(),
		ahead_ore_point(),
		still_point(),
		seat_point(),
		split_corner_point(),
		two_stocks_point(),
		after_split_point(),
		split_bin_point(),
		held_pair_point(),
		ahead_ore_throat(),
		still_throat(),
		seat_throat(),
		split_corner_throat(),
		two_stocks_throat(),
		after_split_throat(),
		split_bin_throat(),
		held_pair_throat(),
		ahead_ore_wrest(),
		still_wrest(),
		seat_wrest(),
		split_corner_wrest(),
		two_stocks_wrest(),
		after_split_wrest(),
		split_bin_wrest(),
		held_pair_wrest(),
		ahead_ore_jointer(),
		still_jointer(),
		seat_jointer(),
		split_corner_jointer(),
		two_stocks_jointer(),
		after_split_jointer(),
		split_bin_jointer(),
		held_pair_jointer(),
		ahead_ore_bridle(),
		still_bridle(),
		seat_bridle(),
		split_corner_bridle(),
		two_stocks_bridle(),
		after_split_bridle(),
		split_bin_bridle(),
		held_pair_bridle(),
		ahead_ore_trashboard(),
		still_trashboard(),
		seat_trashboard(),
		split_corner_trashboard(),
		two_stocks_trashboard(),
		after_split_trashboard(),
		split_bin_trashboard(),
		held_pair_trashboard(),
		ahead_ore_gauge(),
		still_gauge(),
		seat_gauge(),
		split_corner_gauge(),
		two_stocks_gauge(),
		after_split_gauge(),
		split_bin_gauge(),
		held_pair_gauge(),
		ahead_ore_breast(),
		still_breast(),
		seat_breast(),
		split_corner_breast(),
		two_stocks_breast(),
		after_split_breast(),
		split_bin_breast(),
		held_pair_breast(),
		ahead_ore_hardie(),
		still_hardie(),
		seat_hardie(),
		split_corner_hardie(),
		two_stocks_hardie(),
		after_split_hardie(),
		split_bin_hardie(),
		held_pair_hardie(),
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


static func forward_left() -> Dictionary:
	var rules = Rules
	# Forward bin is one belt ahead. Left bin is one belt away.
	# The right cell is a pit, so a swapped side does not count.
	return {
		"id": 145,
		"name": "Forward Left",
		"blurb": "The first plate leaves forward and the later plate leaves left. A fork misses the forward bin.",
		"rule": "The share sends the first plate forward and the later plate left. The forward bin is one belt ahead, and the left bin is one belt away. Both bins together are the quota. A fork sends the first plate left and the later plate right into the pit, so the forward bin misses. A prong sends the first plate right into the pit and the later plate left, so the forward bin misses. A pass sends the plates forward and holds the last one. A slip sends the later plates forward and holds the first. A rake sends the plates left and holds the last one. A belt, a dwell, or a twin finishes short of the forward bin. A shed and a hook finish short of the left bin. A hoe and a harrow dump into the pit.",
		"w": 5,
		"h": 4,
		"sources": [
			source(2, 3, rules.Dir.NORTH, [rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 0, [rules.Mat.PLATE]),
			sink(0, 2, [rules.Mat.PLATE]),
		],
		"chutes": [cell(3, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 2,
			rules.Kind.SHARE, 1,
		]),
		"quota": kv([rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SHARE, 2, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 1, 2, rules.Dir.WEST),
		],
	}


static func split_ore_share() -> Dictionary:
	var rules = Rules
	# Ore forward into the kiln. The plate behind it leaves left into the bin.
	return {
		"id": 146,
		"name": "Split Ore",
		"blurb": "The first item is ore and leaves forward into a kiln. The plate behind it leaves left into the bin.",
		"rule": "The first item is ore. It leaves forward into the kiln. The plate that arrives behind it leaves left into the plate bin. A fork sends the ore left onto the plate line and the plate right into the pit. The plate bin refuses the ore, so both quotas miss. A prong sends the ore right into the pit and the plate left, so the kiln misses. A pass sends the ore forward and then pushes the plate into the kiln, which refuses it. A slip sends the plate forward and holds the ore. A rake sends the ore left and holds the plate. A belt, a dwell, or a twin dumps the load forward and the kiln refuses the plate. A shed and a hook send left and stall. A hoe and a harrow send right into the pit.",
		"w": 5,
		"h": 5,
		"sources": [
			source(3, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(3, 0, [rules.Mat.INGOT]),
			sink(0, 3, [rules.Mat.PLATE]),
		],
		"chutes": [cell(4, 3), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.KILN, 1,
			rules.Kind.SHARE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 29]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SHARE, 3, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.WEST),
			piece(rules.Kind.BELT, 1, 3, rules.Dir.WEST),
		],
	}


static func still_share() -> Dictionary:
	var rules = Rules
	# The share faces south. Forward is the kiln. Left is the weir.
	# The right cell is a wall, so a fork or a prong cannot release.
	return {
		"id": 147,
		"name": "Still Share",
		"blurb": "The tray has one belt, on the crossing. The share faces south. The first item leaves forward into the kiln and the later item leaves left.",
		"rule": "The tray has one belt, on the crossing. The share faces south. The first ore stays until a plate arrives, then leaves forward into the kiln, and the plate leaves left, out of the scrap pit. The crossing belt is full, so the weir spills that plate into the bin. The cell to the right is a wall. A fork would send the plate into that wall and a prong would send the ore into it, so the pair stays and the kiln is missed. A pass sends the ore forward and holds the plate until that plate is pushed into the kiln. A slip sends the plate forward and holds the ore. A belt, a dwell, a twin, a shed, a hook, a rake, a hoe, or a harrow misses the room.",
		"w": 7,
		"h": 5,
		"sources": [
			source(2, 0, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(4, 4, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(2, 3, [rules.Mat.INGOT]),
			sink(3, 2, [rules.Mat.PLATE]),
		],
		"chutes": [cell(5, 2), cell(6, 1)],
		"walls": [cell(1, 1)],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.ROLLER, 2,
			rules.Kind.SHARE, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SHARE, 2, 1, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.WEIR, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.ROLLER, 4, 2, rules.Dir.NORTH),
			piece(rules.Kind.ROLLER, 4, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 5, 1, rules.Dir.EAST),
		],
	}


static func seat_share() -> Dictionary:
	var rules = Rules
	# The share starts off the lane. Seat it on the forward-left split.
	return {
		"id": 148,
		"name": "Seat",
		"blurb": "The share starts off the lane. Seat it where the first item leaves forward and the later item leaves left.",
		"rule": "The share starts off the lane. Pick it up and seat it where the first plate has to leave forward and the later plate has to leave left. Leaving it parked misses. A fork or a prong seated there misses the forward bin. A pass holds the later plate. A rake sends the plates left and holds the last one. A belt, a dwell, a twin, a slip, a shed, a hook, a hoe, or a harrow misses.",
		"w": 5,
		"h": 4,
		"sources": [
			source(2, 3, rules.Dir.NORTH, [rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 0, [rules.Mat.PLATE]),
			sink(0, 2, [rules.Mat.PLATE]),
		],
		"chutes": [cell(3, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 2,
			rules.Kind.SHARE, 1,
		]),
		"quota": kv([rules.Mat.PLATE, 60]),
		"initial": [
			piece(rules.Kind.SHARE, 0, 3, rules.Dir.WEST),
		],
		"solution": [
			piece(rules.Kind.SHARE, 2, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 1, 2, rules.Dir.WEST),
		],
	}


static func split_corner_share() -> Dictionary:
	var rules = Rules
	# The wall closes the straight lane. Ore forward, plate left through the grate.
	# The right lane runs up to the kiln's side and cannot enter it.
	return {
		"id": 149,
		"name": "Split Corner",
		"blurb": "A wall closes the straight side lane. The waiter leaves forward and the arrival leaves left.",
		"rule": "A wall closes the straight side lane. Later items enter from behind. The ore leaves forward into the kiln and the plate leaves left. The grate passes plates and scraps ore that is sent left. A fork sends the plate right, toward the kiln's side, and the ore left into the grate, so the ore is scrapped and the kiln refuses the plate. A prong sends the ore right and misses the forward kiln. A rake, a shed, and a hook send left, so the grate scraps the ore and the kiln misses. A hoe and a harrow send right and the kiln misses. Belts that run into the wall deliver nothing. A belt, a dwell, a twin, a pass, or a slip in the share cell misses.",
		"w": 6,
		"h": 5,
		"sources": [
			source(2, 4, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(4, 0, [rules.Mat.INGOT]),
			sink(0, 3, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 2)],
		"walls": [cell(5, 4)],
		"budget": kv([
			rules.Kind.BELT, 8,
			rules.Kind.SHARE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.GRATE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 57, rules.Mat.PLATE, 57]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 3, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 4, rules.Dir.NORTH),
			piece(rules.Kind.SHARE, 4, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.WEST),
			piece(rules.Kind.GRATE, 2, 3, rules.Dir.WEST),
			piece(rules.Kind.BELT, 1, 3, rules.Dir.WEST),
			piece(rules.Kind.BELT, 5, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 5, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.WEST),
		],
	}


static func two_heats_share() -> Dictionary:
	var rules = Rules
	# The waiter feeds the forward kiln. The arrival feeds the left kiln.
	# The right cell is a pit, so a swapped right exit does not count.
	return {
		"id": 150,
		"name": "Two Heats",
		"blurb": "The forward exit feeds one kiln with the waiter. The left exit feeds another kiln with the arrival.",
		"rule": "The forward kiln is fed by the waiting ore. The left kiln is fed by the ore that arrives behind it. One kiln is half the quota. A fork feeds only the left kiln and sends the arrival into the pit. A prong feeds the left kiln with the arrival and misses the forward kiln. A pass feeds only the forward kiln and holds the last ore. A hoe feeds only the right, into the pit. A harrow feeds only the right with the arrival. A rake, a shed, and a hook each cover the left and miss. A belt, a dwell, a twin, or a slip dumps the ore forward into one kiln.",
		"w": 9,
		"h": 6,
		"sources": [
			source(4, 5, rules.Dir.NORTH, [rules.Mat.ORE], 1),
		],
		"sinks": [
			sink(4, 0, [rules.Mat.INGOT]),
			sink(0, 4, [rules.Mat.INGOT]),
		],
		"chutes": [cell(5, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.KILN, 2,
			rules.Kind.SHARE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 116]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SHARE, 4, 4, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 3, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 4, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 3, 4, rules.Dir.WEST),
			piece(rules.Kind.KILN, 2, 4, rules.Dir.WEST),
			piece(rules.Kind.BELT, 1, 4, rules.Dir.WEST),
		],
	}


static func after_split_share() -> Dictionary:
	var rules = Rules
	# Same crossing as Still Share, with belts instead of rollers.
	# The share faces south and sends ore forward, away from the scrap.
	return {
		"id": 151,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The share faces south. It sends the ore forward, away from the scrap, and the other item left.",
		"rule": "A filter scraps the crossing ingots. The share faces south. It sends the ore forward, away from the scrap, into the kiln, and the plate left. The weir spills that plate into the bin. A fork sends the ore left, toward the scrap, and the plate right into the pit, so the kiln misses. A prong sends the ore right into the pit and misses the forward kiln. A pass sends the ore forward and holds the plate until the kiln refuses it. A slip holds the ore. A belt, a dwell, a twin, a shed, a hook, a rake, a hoe, or a harrow misses.",
		"w": 7,
		"h": 5,
		"sources": [
			source(2, 0, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(4, 4, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(2, 3, [rules.Mat.INGOT]),
			sink(3, 2, [rules.Mat.PLATE]),
		],
		"chutes": [cell(1, 1), cell(5, 2), cell(6, 1)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.SHARE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SHARE, 2, 1, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.WEIR, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 5, 1, rules.Dir.EAST),
		],
	}


static func split_bin_share() -> Dictionary:
	var rules = Rules
	# Plates leave forward into their own bin. Ore leaves left, is smelted, and splits.
	return {
		"id": 152,
		"name": "Split Bin",
		"blurb": "The forward stream and the left stream each reach a different quota. A fork, a prong, a harrow, a hoe, and a rake each miss at least one.",
		"rule": "The share sends the plates forward into their bin and the ore left into the kiln. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. A fork sends the plates toward the kiln and the ore into the pit, so at least one quota misses. A prong sends the plates into the pit and the ore left, so the plate quota misses. A harrow, a hoe, and a rake each miss at least one quota. A belt, a dwell, a twin, a pass, a slip, a shed, and a hook miss too. Pressing every ingot misses the ingot bin.",
		"w": 10,
		"h": 6,
		"sources": [
			source(9, 5, rules.Dir.WEST, [rules.Mat.PLATE], 4),
			source(8, 4, rules.Dir.NORTH, [rules.Mat.PLATE, rules.Mat.ORE], 1),
			source(6, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 6),
		],
		"sinks": [
			sink(8, 2, [rules.Mat.PLATE]),
			sink(6, 5, [rules.Mat.PLATE]),
			sink(0, 3, [rules.Mat.INGOT]),
			sink(0, 2, [rules.Mat.PLATE]),
		],
		"chutes": [cell(9, 3), cell(7, 2), cell(5, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 9,
			rules.Kind.SHARE, 1,
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
			piece(rules.Kind.SHARE, 8, 3, rules.Dir.NORTH),
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


static func forward_right() -> Dictionary:
	var rules = Rules
	# Forward bin is one belt ahead. Right bin is one belt away.
	# The left cell is a pit, so a share's later plate is lost.
	return {
		"id": 153,
		"name": "Forward Right",
		"blurb": "The first plate leaves forward and the later plate leaves right. A share sends the later plate left, into a pit.",
		"rule": "The coulter sends the first plate forward and the later plate right. The forward bin is one belt ahead, and the right bin is one belt away. Both bins together are the quota. A share sends the later plate left, into a pit, so the right bin misses. A fork sends the first plate left and the later plate right, so the forward bin misses. A prong sends the first plate right and the later plate left, so the forward bin misses. A pass sends only the first plate forward and holds the later plate. A slip sends the later plate forward and holds the first. A hoe sends the first plate right and holds the later plate. A belt, a dwell, a twin, a shed, a hook, a rake, and a harrow miss too.",
		"w": 5,
		"h": 4,
		"sources": [
			source(2, 3, rules.Dir.NORTH, [rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 0, [rules.Mat.PLATE]),
			sink(4, 2, [rules.Mat.PLATE]),
		],
		"chutes": [cell(1, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 2,
			rules.Kind.COULTER, 1,
		]),
		"quota": kv([rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.COULTER, 2, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.EAST),
		],
	}


static func split_ore_coulter() -> Dictionary:
	var rules = Rules
	# Ore forward into the kiln. The plate behind it leaves right into the bin.
	# The left cell is a pit, so a share loses the plate.
	return {
		"id": 154,
		"name": "Split Ore",
		"blurb": "The first item is ore and leaves forward into a kiln. The plate behind it leaves right into the bin.",
		"rule": "The first item is ore. It leaves forward into the kiln. The plate that arrives behind it leaves right into the plate bin. A share sends the plate left, into a pit. A fork sends the ore left and the plate right, so the kiln misses. A prong sends the ore right and the plate left. A pass sends the ore forward and holds the plate. A hoe sends the ore right and holds the plate. A belt, a dwell, a twin, a slip, a shed, a hook, a rake, and a harrow miss too.",
		"w": 5,
		"h": 5,
		"sources": [
			source(1, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(1, 0, [rules.Mat.INGOT]),
			sink(4, 3, [rules.Mat.PLATE]),
		],
		"chutes": [cell(0, 3), cell(0, 4), cell(2, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.KILN, 1,
			rules.Kind.COULTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 29]),
		"initial": [],
		"solution": [
			piece(rules.Kind.COULTER, 1, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 1, 2, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
		],
	}


static func still_coulter() -> Dictionary:
	var rules = Rules
	# The coulter faces south. Forward is the kiln. Right is the weir.
	# The crossing belt jams against a wall, so the weir spills the plate
	# north, out of the scrap pit. The left cell is a wall.
	return {
		"id": 155,
		"name": "Still Coulter",
		"blurb": "The tray has one belt, on the crossing. The coulter faces south. The first item leaves forward into the kiln and the later item leaves right.",
		"rule": "The tray has one belt, on the crossing. The coulter faces south. The first item stays until a later item arrives, then the first leaves forward into the kiln, out of the forward pit, and the later item leaves right, out of the scrap pit. The crossing belt is full, so the weir spills that plate into the bin. The cell to the left is a wall. A share sends the plate left, so the pair stays. A fork and a prong miss the forward kiln. A pass holds the later item. A hoe holds the plate. A belt, a dwell, a twin, a slip, a shed, a hook, a rake, and a harrow miss too.",
		"w": 7,
		"h": 5,
		"sources": [
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(1, 4, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
			source(6, 3, rules.Dir.WEST, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(3, 3, [rules.Mat.INGOT]),
			sink(2, 0, [rules.Mat.PLATE]),
		],
		"chutes": [cell(5, 2), cell(3, 4)],
		"walls": [cell(0, 1), cell(4, 1)],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.ROLLER, 2,
			rules.Kind.COULTER, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.COULTER, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.WEIR, 2, 1, rules.Dir.WEST),
			piece(rules.Kind.BELT, 1, 1, rules.Dir.WEST),
			piece(rules.Kind.ROLLER, 1, 2, rules.Dir.NORTH),
			piece(rules.Kind.ROLLER, 1, 3, rules.Dir.NORTH),
			piece(rules.Kind.FILTER, 5, 3, rules.Dir.WEST),
		],
	}


static func seat_coulter() -> Dictionary:
	var rules = Rules
	# The coulter starts off the lane. Seat it on the forward-right split.
	return {
		"id": 156,
		"name": "Seat",
		"blurb": "The coulter starts off the lane. Seat it where the first item leaves forward and the later item leaves right.",
		"rule": "The coulter starts off the lane. Pick it up and seat it where the first plate has to leave forward and the later plate has to leave right. Leaving it parked misses. A share seated there sends the later plate left and misses the right bin. A fork or a prong seated there misses the forward bin. A pass holds the later plate. A belt, a dwell, a twin, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 5,
		"h": 4,
		"sources": [
			source(2, 3, rules.Dir.NORTH, [rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 0, [rules.Mat.PLATE]),
			sink(4, 2, [rules.Mat.PLATE]),
		],
		"chutes": [cell(1, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 2,
			rules.Kind.COULTER, 1,
		]),
		"quota": kv([rules.Mat.PLATE, 60]),
		"initial": [
			piece(rules.Kind.COULTER, 0, 3, rules.Dir.WEST),
		],
		"solution": [
			piece(rules.Kind.COULTER, 2, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.EAST),
		],
	}


static func split_corner_coulter() -> Dictionary:
	var rules = Rules
	# The wall closes the straight lane. Ore forward, plate right.
	# The left cell is a grate that scraps the arrival's plate into a pit.
	return {
		"id": 157,
		"name": "Split Corner",
		"blurb": "A wall closes the straight side lane. The waiter leaves forward and the arrival leaves right.",
		"rule": "A wall closes the straight side lane. Later items enter from behind. The ore leaves forward into the kiln and the plate leaves right. The left grate scraps a plate that is sent left. A share sends the plate left, into the grate. A fork sends the ore left and the plate right, so the kiln misses. A prong misses the forward kiln. A rake, a shed, and a hook send left and the kiln misses. A belt, a dwell, a twin, a pass, a slip, a hoe, and a harrow miss too.",
		"w": 9,
		"h": 5,
		"sources": [
			source(2, 4, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(4, 0, [rules.Mat.INGOT]),
			sink(8, 3, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 3), cell(3, 2)],
		"walls": [cell(5, 4)],
		"budget": kv([
			rules.Kind.BELT, 6,
			rules.Kind.COULTER, 1,
			rules.Kind.KILN, 1,
			rules.Kind.GRATE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 57, rules.Mat.PLATE, 57]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 3, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 4, rules.Dir.NORTH),
			piece(rules.Kind.COULTER, 4, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 7, 3, rules.Dir.EAST),
			piece(rules.Kind.GRATE, 3, 3, rules.Dir.WEST),
		],
	}


static func two_heats_coulter() -> Dictionary:
	var rules = Rules
	# The waiter feeds the forward kiln. The arrival feeds the right kiln.
	# The left cell is a pit, so a share loses the arrival.
	return {
		"id": 158,
		"name": "Two Heats",
		"blurb": "The forward exit feeds one kiln with the waiter. The right exit feeds another kiln with the arrival.",
		"rule": "The forward kiln is fed by the waiting ore. The right kiln is fed by the ore that arrives behind it. One kiln is half the quota. A share feeds only the forward kiln and sends the arrival left, where there is no kiln. A fork feeds the right kiln with the arrival and misses the forward kiln. A prong feeds the right kiln with the waiter and misses the forward kiln. A pass feeds only the forward kiln and holds the rest. A hoe feeds only the right and holds the arrival. A harrow feeds only the right with the arrival. A belt, a dwell, a twin, a slip, a shed, a hook, and a rake miss too.",
		"w": 9,
		"h": 6,
		"sources": [
			source(4, 5, rules.Dir.NORTH, [rules.Mat.ORE], 1),
		],
		"sinks": [
			sink(4, 0, [rules.Mat.INGOT]),
			sink(8, 4, [rules.Mat.INGOT]),
		],
		"chutes": [cell(3, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 4,
			rules.Kind.KILN, 2,
			rules.Kind.COULTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 116]),
		"initial": [],
		"solution": [
			piece(rules.Kind.COULTER, 4, 4, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 3, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 4, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 5, 4, rules.Dir.EAST),
			piece(rules.Kind.KILN, 6, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 7, 4, rules.Dir.EAST),
		],
	}


static func after_split_coulter() -> Dictionary:
	var rules = Rules
	# The coulter faces south. Ore goes forward, away from the scrap.
	# The plate goes right. The left cell is the scrap pit.
	return {
		"id": 159,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The coulter faces south. It sends the ore forward, away from the scrap, and the other item right.",
		"rule": "A filter scraps the crossing ingots. The coulter faces south. It sends the ore forward, away from the scrap, into the kiln, and the plate right into the bin. A share sends the plate left, toward the scrap. A fork sends the ore toward the scrap. A prong misses the forward kiln. A belt, a dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 5,
		"sources": [
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 4, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(3, 3, [rules.Mat.INGOT]),
			sink(1, 1, [rules.Mat.PLATE]),
		],
		"chutes": [cell(4, 1), cell(7, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 2,
			rules.Kind.ROLLER, 2,
			rules.Kind.COULTER, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.COULTER, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.WEST),
			piece(rules.Kind.ROLLER, 6, 3, rules.Dir.NORTH),
			piece(rules.Kind.ROLLER, 6, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 6, 1, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 7, 1, rules.Dir.EAST),
		],
	}


static func split_bin_coulter() -> Dictionary:
	var rules = Rules
	# Plates leave forward into their own bin. Ore leaves right, is smelted, and splits.
	# The left cell is a pit, so a share loses the ore.
	return {
		"id": 160,
		"name": "Split Bin",
		"blurb": "The forward stream and the right stream each reach a different quota. A share, a fork, a prong, a harrow, a hoe, and a rake each miss at least one.",
		"rule": "The coulter sends the plates forward into their bin and the ore right into the kiln. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. A share sends the ore left, into a pit, so the ingot quota misses. A fork sends the plates left and the ore right, so the forward plates miss. A prong sends the plates right and the ore left. A harrow, a hoe, and a rake each miss at least one quota. A belt, a dwell, a twin, a pass, a slip, a shed, and a hook miss too. Pressing every ingot misses the ingot bin.",
		"w": 10,
		"h": 6,
		"sources": [
			source(0, 5, rules.Dir.EAST, [rules.Mat.PLATE], 4),
			source(1, 4, rules.Dir.NORTH, [rules.Mat.PLATE, rules.Mat.ORE], 1),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 6),
		],
		"sinks": [
			sink(1, 2, [rules.Mat.PLATE]),
			sink(3, 5, [rules.Mat.PLATE]),
			sink(9, 3, [rules.Mat.INGOT]),
			sink(9, 4, [rules.Mat.PLATE]),
		],
		"chutes": [cell(0, 3), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 9,
			rules.Kind.COULTER, 1,
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
			piece(rules.Kind.COULTER, 1, 3, rules.Dir.NORTH),
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


static func left_ore() -> Dictionary:
	var rules = Rules
	# Ore leaves left into the kiln. The plate behind it leaves forward.
	# The right cell is a pit, so a coulter's plate is lost.
	return {
		"id": 161,
		"name": "Left Ore",
		"blurb": "The first item is ore and leaves left into a kiln. The plate that arrives behind it leaves forward into the plate bin.",
		"rule": "The first item is ore. It leaves left into the kiln. The plate that arrives behind it leaves forward into the plate bin. A share sends the ore forward and the plate left, so the kiln misses. A coulter sends the plate right, where there is no bin. A fork sends the plate right and misses the forward bin. A slip sends the plate forward and holds the ore. A rake sends the ore left and holds the plate. A prong sends the ore right and the plate left. A belt, a dwell, a twin, a pass, a shed, a hook, a hoe, and a harrow miss too.",
		"w": 5,
		"h": 5,
		"sources": [
			source(3, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(3, 0, [rules.Mat.PLATE]),
			sink(0, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(4, 3), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.KILN, 1,
			rules.Kind.MOLDBOARD, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 29]),
		"initial": [],
		"solution": [
			piece(rules.Kind.MOLDBOARD, 3, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.WEST),
			piece(rules.Kind.KILN, 1, 3, rules.Dir.WEST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.NORTH),
		],
	}


static func still_moldboard() -> Dictionary:
	var rules = Rules
	# The moldboard faces south. Left is the kiln. Forward is the weir.
	# The one belt sits on the crossing and empties into the scrap chute.
	return {
		"id": 162,
		"name": "Still Moldboard",
		"blurb": "The tray has one belt, on the crossing. The moldboard faces south. The first item stays until a later item arrives, then the first leaves left into the kiln and the later item leaves forward.",
		"rule": "The tray has one belt, on the crossing. The moldboard faces south. The first item stays until a later item arrives, then the first leaves left into the kiln, out of the left pit, and the later item leaves forward, out of the scrap pit. The crossing belt is full, so the weir spills that plate into the bin. A share sends the ore forward into the scrap. A coulter sends the plate right. A fork misses the forward bin. A prong misses both. A belt, a dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 5,
		"sources": [
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 3, rules.Dir.WEST, [rules.Mat.INGOT], 4),
			source(0, 4, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(6, 1, [rules.Mat.INGOT]),
			sink(2, 2, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 1), cell(7, 1), cell(1, 3), cell(3, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.ROLLER, 3,
			rules.Kind.MOLDBOARD, 1,
			rules.Kind.KILN, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.MOLDBOARD, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.ROLLER, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.WEIR, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.SOUTH),
			piece(rules.Kind.ROLLER, 4, 3, rules.Dir.WEST),
			piece(rules.Kind.ROLLER, 5, 3, rules.Dir.WEST),
			piece(rules.Kind.FILTER, 0, 3, rules.Dir.NORTH),
		],
	}


static func seat_moldboard() -> Dictionary:
	var rules = Rules
	# The moldboard starts off the lane. Seat it so ore leaves left and plate leaves forward.
	return {
		"id": 163,
		"name": "Seat",
		"blurb": "The moldboard starts off the lane. Seat it where the ore has to leave left and the plate has to leave forward.",
		"rule": "The moldboard starts off the lane. Pick it up and seat it where the ore has to leave left into the kiln and the plate has to leave forward into the plate bin. Leaving it parked misses. A share seated there swaps them and misses the kiln. A coulter seated there misses the forward bin. A fork sends the plate right. A slip sends the plate forward and holds the ore. A rake sends the ore left and holds the plate. A belt, a dwell, a twin, a pass, a prong, a shed, a hook, a hoe, and a harrow miss too.",
		"w": 5,
		"h": 5,
		"sources": [
			source(3, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(3, 1, [rules.Mat.PLATE]),
			sink(0, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(4, 3), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 2,
			rules.Kind.KILN, 1,
			rules.Kind.MOLDBOARD, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [
			piece(rules.Kind.MOLDBOARD, 0, 4, rules.Dir.WEST),
		],
		"solution": [
			piece(rules.Kind.MOLDBOARD, 3, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.WEST),
			piece(rules.Kind.KILN, 1, 3, rules.Dir.WEST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.NORTH),
		],
	}


static func split_corner_moldboard() -> Dictionary:
	var rules = Rules
	# The wall closes the right lane. Ore leaves left through the grate. Plate leaves forward.
	return {
		"id": 164,
		"name": "Split Corner",
		"blurb": "A wall closes the right lane a coulter would use. Later items enter from behind. The waiter leaves left and the arrival leaves forward.",
		"rule": "A wall closes the right lane a coulter would use. Later items enter from behind. The waiter leaves left and the arrival leaves forward. The left grate sends the ore on toward the kiln and scraps a plate. A share swaps them into the grate and the wrong bin. A coulter sends the arrival right into the wall. A fork sends the arrival right and misses the forward bin. A prong misses both. A rake sends the ore left and holds the plate. A belt, a dwell, a twin, a pass, a slip, a shed, a hook, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 5,
		"sources": [
			source(2, 4, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(7, 1, [rules.Mat.PLATE]),
			sink(2, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(1, 3)],
		"walls": [cell(5, 4), cell(5, 3)],
		"budget": kv([
			rules.Kind.BELT, 7,
			rules.Kind.MOLDBOARD, 1,
			rules.Kind.KILN, 1,
			rules.Kind.GRATE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 57, rules.Mat.PLATE, 57]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 3, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 4, rules.Dir.NORTH),
			piece(rules.Kind.MOLDBOARD, 4, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.WEST),
			piece(rules.Kind.GRATE, 2, 3, rules.Dir.WEST),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.NORTH),
		],
	}


static func two_stocks() -> Dictionary:
	var rules = Rules
	# The ore waiter feeds the left kiln. The plate arrival feeds the forward bin.
	# The right cell is a pit. Both exits are not ore kilns.
	return {
		"id": 165,
		"name": "Two Stocks",
		"blurb": "The left exit feeds a kiln with the ore waiter. The forward exit feeds a plate bin with the plate arrival.",
		"rule": "The left exit feeds a kiln with the ore waiter. The forward exit feeds a plate bin with the plate arrival. A share feeds the kiln with the plate and the plate bin with the ore, so both miss. A coulter sends the plate right, where there is no bin. A fork sends the plate right and misses the forward bin. A prong misses both. A slip sends the plate forward and holds the ore. A rake sends the ore left and holds the plate. A belt, a dwell, a twin, a pass, a shed, a hook, a hoe, and a harrow miss too.",
		"w": 9,
		"h": 6,
		"sources": [
			source(4, 5, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(4, 0, [rules.Mat.PLATE]),
			sink(0, 4, [rules.Mat.INGOT]),
		],
		"chutes": [cell(5, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 5,
			rules.Kind.KILN, 1,
			rules.Kind.MOLDBOARD, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 58, rules.Mat.PLATE, 58]),
		"initial": [],
		"solution": [
			piece(rules.Kind.MOLDBOARD, 4, 4, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 3, 4, rules.Dir.WEST),
			piece(rules.Kind.KILN, 2, 4, rules.Dir.WEST),
			piece(rules.Kind.BELT, 1, 4, rules.Dir.WEST),
			piece(rules.Kind.BELT, 4, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.NORTH),
		],
	}


static func after_split_moldboard() -> Dictionary:
	var rules = Rules
	# The moldboard faces south. Ore leaves left, away from the scrap.
	# The plate leaves forward. The filter scraps the crossing ingots.
	return {
		"id": 166,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The moldboard faces south. It sends the ore left, away from the scrap, and the other item forward.",
		"rule": "A filter scraps the crossing ingots. The moldboard faces south. It sends the ore left, away from the scrap, into the kiln, and the plate forward into the bin. The scrap pit is past that bin. A share sends the ore forward, toward the scrap, and the plate left, so both miss. A coulter sends the plate right, where there is no bin. A fork sends the plate right and misses the forward bin. A prong misses both. A belt, a dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 5,
		"sources": [
			source(2, 0, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 4, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(5, 1, [rules.Mat.INGOT]),
			sink(2, 3, [rules.Mat.PLATE]),
		],
		"chutes": [cell(1, 1), cell(2, 4), cell(7, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.ROLLER, 2,
			rules.Kind.MOLDBOARD, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.MOLDBOARD, 2, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.ROLLER, 6, 3, rules.Dir.NORTH),
			piece(rules.Kind.ROLLER, 6, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 6, 1, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 7, 1, rules.Dir.EAST),
		],
	}


static func split_bin_moldboard() -> Dictionary:
	var rules = Rules
	# Ore leaves left into the kiln line. Plates leave forward into their bin.
	# A share swaps those exits and misses the ingot quota.
	return {
		"id": 167,
		"name": "Split Bin",
		"blurb": "The left stream and the forward stream each reach a different quota. A share swaps them and misses at least one.",
		"rule": "The moldboard sends the ore left into the kiln and the plate forward into its bin. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. A share swaps the two exits and misses the ingot quota. A coulter sends the plate right and misses both. A fork misses the plate quota. A prong misses both. A harrow, a hoe, and a rake each miss at least one quota. A belt, a dwell, a twin, a pass, a slip, a shed, and a hook miss too. Pressing every ingot misses the ingot bin.",
		"w": 10,
		"h": 6,
		"sources": [
			source(9, 5, rules.Dir.WEST, [rules.Mat.PLATE], 4),
			source(8, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(6, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 6),
		],
		"sinks": [
			sink(8, 2, [rules.Mat.PLATE]),
			sink(6, 5, [rules.Mat.PLATE]),
			sink(0, 3, [rules.Mat.INGOT]),
			sink(0, 2, [rules.Mat.PLATE]),
		],
		"chutes": [cell(9, 3), cell(7, 2), cell(5, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 9,
			rules.Kind.MOLDBOARD, 1,
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
			piece(rules.Kind.MOLDBOARD, 8, 3, rules.Dir.NORTH),
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


static func held_pair() -> Dictionary:
	var rules = Rules
	# Period 2, one cell behind the moldboard. The first ore waits through the empty tick.
	return {
		"id": 168,
		"name": "Held Pair",
		"blurb": "The first item waits through a tick with nothing behind it, then the pair leaves on the arrival tick. A belt would have moved the first item on the first tick.",
		"rule": "The first item waits through a tick with nothing behind it, then the pair leaves on the arrival tick. A belt would have moved the first item on that first tick. A lone item never leaves. The ore still has to leave left into the kiln and the plate forward into the bin, so a share misses. A coulter sends the plate right, where there is no bin. A fork sends the plate right and misses the forward bin. A slip sends the plate forward and holds the ore. A rake sends the ore left and holds the plate. A prong misses both. A dwell, a twin, a pass, a shed, a hook, a hoe, and a harrow miss too.",
		"w": 5,
		"h": 5,
		"sources": [
			source(3, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(3, 1, [rules.Mat.PLATE]),
			sink(0, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(4, 3), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 2,
			rules.Kind.KILN, 1,
			rules.Kind.MOLDBOARD, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.MOLDBOARD, 3, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.WEST),
			piece(rules.Kind.KILN, 1, 3, rules.Dir.WEST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.NORTH),
		],
	}


static func right_ore() -> Dictionary:
	var rules = Rules
	# Ore leaves right into the kiln. The plate behind it leaves forward.
	# The left cell is a pit, so a moldboard's ore is lost.
	return {
		"id": 169,
		"name": "Right Ore",
		"blurb": "The first item is ore and leaves right into a kiln. The plate that arrives behind it leaves forward into the plate bin.",
		"rule": "The first item is ore. It leaves right into the kiln. The plate that arrives behind it leaves forward into the plate bin. A moldboard sends the ore left, into a pit. A coulter sends the ore forward and the plate right, so the kiln misses. A share sends the ore forward. A fork and a prong miss the forward bin. A slip sends the plate forward and holds the ore. A hoe sends the ore right and holds the plate. A belt, a dwell, a twin, a pass, a shed, a hook, a rake, and a harrow miss too.",
		"w": 5,
		"h": 5,
		"sources": [
			source(1, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(1, 0, [rules.Mat.PLATE]),
			sink(4, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(0, 3), cell(2, 4), cell(0, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.KILN, 1,
			rules.Kind.LANDSIDE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 29]),
		"initial": [],
		"solution": [
			piece(rules.Kind.LANDSIDE, 1, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 1, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 1, 1, rules.Dir.NORTH),
		],
	}


static func still_landside() -> Dictionary:
	var rules = Rules
	# The landside faces south. Right is the kiln. Forward is the weir.
	# The one belt sits on the crossing and empties into the scrap chute.
	return {
		"id": 170,
		"name": "Still Landside",
		"blurb": "The tray has one belt, on the crossing. The landside faces south. The first item stays until a later item arrives, then the first leaves right and the later item leaves forward.",
		"rule": "The tray has one belt, on the crossing. The landside faces south. The first item stays until a later item arrives, then the first leaves right into the kiln and the later item leaves forward, out of the scrap pit. The crossing belt is full, so the weir spills that plate into the bin. A moldboard sends the ore left, into a pit. A coulter sends the ore forward into the scrap. A share sends the ore forward and the plate left. A fork misses the forward bin. A prong misses the plate bin. A belt, a dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 5,
		"sources": [
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 3, rules.Dir.WEST, [rules.Mat.INGOT], 4),
			source(0, 4, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(0, 1, [rules.Mat.INGOT]),
			sink(2, 2, [rules.Mat.PLATE]),
		],
		"chutes": [cell(4, 1), cell(7, 1), cell(1, 3), cell(3, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.ROLLER, 3,
			rules.Kind.LANDSIDE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.LANDSIDE, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.ROLLER, 2, 1, rules.Dir.WEST),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
			piece(rules.Kind.WEIR, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.SOUTH),
			piece(rules.Kind.ROLLER, 4, 3, rules.Dir.WEST),
			piece(rules.Kind.ROLLER, 5, 3, rules.Dir.WEST),
			piece(rules.Kind.FILTER, 0, 3, rules.Dir.NORTH),
		],
	}


static func seat_landside() -> Dictionary:
	var rules = Rules
	# The landside starts off the lane. Seat it so ore leaves right and plate leaves forward.
	return {
		"id": 171,
		"name": "Seat",
		"blurb": "The landside starts off the lane. Seat it where the ore has to leave right and the plate has to leave forward.",
		"rule": "The landside starts off the lane. Pick it up and seat it where the ore has to leave right into the kiln and the plate has to leave forward into the plate bin. Leaving it parked misses. A moldboard seated there sends the ore left. A coulter seated there misses the forward bin. A share sends the ore forward. A fork sends the plate right. A slip sends the plate forward and holds the ore. A hoe sends the ore right and holds the plate. A belt, a dwell, a twin, a pass, a prong, a shed, a hook, a rake, and a harrow miss too.",
		"w": 5,
		"h": 5,
		"sources": [
			source(1, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(1, 1, [rules.Mat.PLATE]),
			sink(4, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(0, 3), cell(2, 4), cell(0, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 2,
			rules.Kind.KILN, 1,
			rules.Kind.LANDSIDE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [
			piece(rules.Kind.LANDSIDE, 4, 4, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.LANDSIDE, 1, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 1, 2, rules.Dir.NORTH),
		],
	}


static func split_corner_landside() -> Dictionary:
	var rules = Rules
	# The wall closes the left lane. Ore leaves right through the grate. Plate leaves forward.
	return {
		"id": 172,
		"name": "Split Corner",
		"blurb": "A wall closes the left lane a moldboard would use. The waiter leaves right and the arrival leaves forward.",
		"rule": "A wall closes the left lane a moldboard would use. Later items enter from behind. The waiter leaves right and the arrival leaves forward. The right grate sends the ore on toward the kiln and scraps a plate. A moldboard sends the waiter into the wall. A coulter sends the ore forward and the plate right. A share sends the ore forward. A fork and a prong miss the forward bin. A hoe sends the ore right and holds the plate. A belt, a dwell, a twin, a pass, a slip, a shed, a hook, a rake, and a harrow miss too.",
		"w": 8,
		"h": 5,
		"sources": [
			source(0, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(7, 1, [rules.Mat.PLATE]),
			sink(1, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(3, 4)],
		"walls": [cell(3, 0), cell(4, 0)],
		"budget": kv([
			rules.Kind.BELT, 6,
			rules.Kind.LANDSIDE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.GRATE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 57, rules.Mat.PLATE, 57]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BELT, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.LANDSIDE, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.GRATE, 3, 3, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 2, 3, rules.Dir.WEST),
		],
	}


static func two_stocks_landside() -> Dictionary:
	var rules = Rules
	# Two landsides. Each sends the ore waiter right into a kiln and the plate arrival forward.
	return {
		"id": 173,
		"name": "Two Stocks",
		"blurb": "Two landsides, two materials. Both quotas are met only when each landside sends the waiter right and the arrival forward.",
		"rule": "Two landsides, two materials. The right exit of each feeds a kiln with the ore waiter. The forward exit of each feeds a plate bin with the plate arrival. Both quotas are met only when each landside sends the waiter right and the arrival forward. A moldboard sends the ore left, into a pit. A coulter sends the ore forward and the plate right. A share sends the ore forward. A fork and a prong miss the forward bins. A slip sends the plate forward and holds the ore. A hoe sends the ore right and holds the plate. A belt, a dwell, a twin, a pass, a shed, a hook, a rake, and a harrow miss too.",
		"w": 10,
		"h": 6,
		"sources": [
			source(1, 5, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(6, 5, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(1, 0, [rules.Mat.PLATE]),
			sink(4, 4, [rules.Mat.INGOT]),
			sink(6, 0, [rules.Mat.PLATE]),
			sink(9, 4, [rules.Mat.INGOT]),
		],
		"chutes": [cell(0, 4), cell(5, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 8,
			rules.Kind.KILN, 2,
			rules.Kind.LANDSIDE, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 116, rules.Mat.PLATE, 116]),
		"initial": [],
		"solution": [
			piece(rules.Kind.LANDSIDE, 1, 4, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 4, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 1, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 1, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 1, 1, rules.Dir.NORTH),
			piece(rules.Kind.LANDSIDE, 6, 4, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 7, 4, rules.Dir.EAST),
			piece(rules.Kind.KILN, 8, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 6, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 6, 1, rules.Dir.NORTH),
		],
	}


static func after_split_landside() -> Dictionary:
	var rules = Rules
	# The landside faces south. Ore leaves right, away from the scrap.
	# The plate leaves forward. The filter scraps the crossing ingots.
	return {
		"id": 174,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The landside sends the ore right, away from the scrap, and the other item forward.",
		"rule": "A filter scraps the crossing ingots. The landside faces south. It sends the ore right, away from the scrap, into the kiln, and the plate forward into the bin. The scrap pit is past that bin. A moldboard sends the ore left, toward the scrap side. A coulter sends the ore forward, toward the scrap, and the plate right. A share sends the ore forward and the plate left. A fork sends the plate right and misses the forward bin. A prong misses the plate bin. A belt, a dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 5,
		"sources": [
			source(4, 0, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 4, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(1, 1, [rules.Mat.INGOT]),
			sink(4, 3, [rules.Mat.PLATE]),
		],
		"chutes": [cell(5, 1), cell(4, 4), cell(7, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.ROLLER, 2,
			rules.Kind.LANDSIDE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.LANDSIDE, 4, 1, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 1, rules.Dir.WEST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.WEST),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.SOUTH),
			piece(rules.Kind.ROLLER, 6, 3, rules.Dir.NORTH),
			piece(rules.Kind.ROLLER, 6, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 6, 1, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 7, 1, rules.Dir.EAST),
		],
	}


static func split_bin_landside() -> Dictionary:
	var rules = Rules
	# Ore leaves right into the kiln line. Plates leave forward into their bin.
	# Swapping those exits misses at least one quota.
	return {
		"id": 175,
		"name": "Split Bin",
		"blurb": "The right stream and the forward stream each reach a different quota. Swapping them misses at least one.",
		"rule": "The landside sends the ore right into the kiln and the plate forward into its bin. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. A moldboard sends the ore left, into a pit. A coulter swaps the two exits and misses at least one quota. A share sends the plate left. A fork misses the plate quota. A prong misses the forward plates. A harrow, a hoe, and a rake each miss at least one quota. A belt, a dwell, a twin, a pass, a slip, a shed, and a hook miss too. Pressing every ingot misses the ingot bin.",
		"w": 10,
		"h": 6,
		"sources": [
			source(0, 5, rules.Dir.EAST, [rules.Mat.PLATE], 4),
			source(1, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.PLATE], 6),
		],
		"sinks": [
			sink(1, 2, [rules.Mat.PLATE]),
			sink(3, 5, [rules.Mat.PLATE]),
			sink(9, 3, [rules.Mat.INGOT]),
			sink(9, 4, [rules.Mat.PLATE]),
		],
		"chutes": [cell(0, 3), cell(2, 4), cell(4, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 9,
			rules.Kind.LANDSIDE, 1,
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
			piece(rules.Kind.LANDSIDE, 1, 3, rules.Dir.NORTH),
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


static func held_pair_landside() -> Dictionary:
	var rules = Rules
	# Period 2, one cell behind the landside. The first ore waits through the empty tick.
	return {
		"id": 176,
		"name": "Held Pair",
		"blurb": "The pair has to leave on the arrival tick, waiter right and arrival forward, and the cell is empty afterward.",
		"rule": "The first item waits through a tick with nothing behind it, then the pair leaves on the arrival tick, the waiter right and the arrival forward, and the cell is empty afterward. A belt would have moved the first item on that first tick. A lone item never leaves. A piece that keeps either item misses. A moldboard sends the ore left. A coulter sends the ore forward and the plate right. A share sends the ore forward. A fork and a prong miss the forward bin. A slip sends the plate forward and holds the ore. A hoe sends the ore right and holds the plate. A dwell, a twin, a pass, a shed, a hook, a rake, and a harrow miss too.",
		"w": 5,
		"h": 5,
		"sources": [
			source(1, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(1, 1, [rules.Mat.PLATE]),
			sink(4, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(0, 3), cell(2, 4), cell(0, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 2,
			rules.Kind.KILN, 1,
			rules.Kind.LANDSIDE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.LANDSIDE, 1, 3, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 1, 2, rules.Dir.NORTH),
		],
	}


static func back_ore() -> Dictionary:
	var rules = Rules
	# Slade faces east. Ore steps through the source into the kiln. Plate leaves forward.
	return {
		"id": 177,
		"name": "Back Ore",
		"blurb": "The first item is ore and leaves backward into a kiln. The plate that arrives behind it leaves forward into the plate bin.",
		"rule": "The first item is ore. It leaves backward into the kiln. The source between them cannot hold that ore, so the ore steps through into the kiln. The plate that arrives behind it leaves forward into the plate bin. A landside sends the ore right, into a pit. A moldboard sends the ore left, into a pit. A coulter sends the ore forward and the plate right, so the kiln misses. A share sends the ore forward. A fork and a prong miss the forward bin. A slip sends the plate forward and holds the ore. A hoe sends the ore right and holds the plate. A belt, a dwell, a twin, a pass, a shed, a hook, a rake, and a harrow miss too.",
		"w": 7,
		"h": 3,
		"sources": [
			source(2, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(6, 1, [rules.Mat.PLATE]),
			sink(0, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(3, 0), cell(3, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 2,
			rules.Kind.KILN, 1,
			rules.Kind.SLADE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 29]),
		"initial": [],
		"solution": [
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
			piece(rules.Kind.SLADE, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
		],
	}


static func still_slade() -> Dictionary:
	var rules = Rules
	# The slade faces south. Backward is the kiln. Forward is the weir.
	# The one belt sits on the crossing and stays full, so the weir spills.
	return {
		"id": 178,
		"name": "Still Slade",
		"blurb": "The tray has one belt, on the crossing. The slade faces south. The first item stays until a later item arrives, then the first leaves backward and the later item leaves forward.",
		"rule": "The tray has one belt, on the crossing. The slade faces south. The first item stays until a later item arrives, then the first leaves backward into the kiln and the later item leaves forward, out of the scrap pit. The crossing belt is full, so the weir spills that plate into the bin. A landside sends the ore right, into a pit. A moldboard sends the ore left, into a pit. A coulter sends the ore forward into the crossing. A share sends the ore forward and the plate left. A fork misses the forward bin. A prong misses the plate bin. A belt, a dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 6,
		"sources": [
			source(3, 2, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(4, 5, rules.Dir.WEST, [rules.Mat.INGOT], 1),
			source(0, 5, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(3, 0, [rules.Mat.INGOT]),
			sink(2, 4, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 3), cell(4, 3), cell(1, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.SLADE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.WEIR, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.KILN, 3, 1, rules.Dir.NORTH),
			piece(rules.Kind.SLADE, 3, 3, rules.Dir.SOUTH),
			piece(rules.Kind.WEIR, 3, 4, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 5, rules.Dir.SOUTH),
			piece(rules.Kind.FILTER, 0, 4, rules.Dir.NORTH),
		],
	}


static func seat_slade() -> Dictionary:
	var rules = Rules
	# The slade starts off the lane. Seat it so ore leaves backward and plate leaves forward.
	return {
		"id": 179,
		"name": "Seat",
		"blurb": "The slade starts off the lane. Seat it where the ore leaves backward and the plate leaves forward.",
		"rule": "The slade starts off the lane. Pick it up and seat it where the ore has to leave backward into the kiln and the plate has to leave forward into the plate bin. Leaving it parked misses. A landside seated there sends the ore right. A moldboard seated there sends the ore left. A coulter seated there misses the forward bin. A share sends the ore forward. A fork sends the plate right. A slip sends the plate forward and holds the ore. A hoe sends the ore right and holds the plate. A belt, a dwell, a twin, a pass, a prong, a shed, a hook, a rake, and a harrow miss too.",
		"w": 6,
		"h": 3,
		"sources": [
			source(2, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(5, 1, [rules.Mat.PLATE]),
			sink(0, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(3, 0), cell(3, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SLADE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [
			piece(rules.Kind.SLADE, 5, 2, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
			piece(rules.Kind.SLADE, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
		],
	}


static func split_corner_slade() -> Dictionary:
	var rules = Rules
	# The wall closes the right lane. Ore leaves backward through the source. Plate leaves forward.
	return {
		"id": 180,
		"name": "Split Corner",
		"blurb": "A wall closes the right lane a landside would use. The waiter leaves backward and the arrival leaves forward.",
		"rule": "A wall closes the right lane a landside would use. Later items enter from behind. The waiter leaves backward and the arrival leaves forward. The ore steps through the source into the kiln. A landside sends the waiter into the wall. A moldboard sends the ore left, into a pit. A coulter sends the ore forward and the plate right. A share sends the ore forward. A fork and a prong miss the forward bin. A hoe sends the ore right and holds the plate. A belt, a dwell, a twin, a pass, a slip, a shed, a hook, a rake, and a harrow miss too.",
		"w": 7,
		"h": 3,
		"sources": [
			source(2, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(6, 1, [rules.Mat.PLATE]),
			sink(0, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(3, 0)],
		"walls": [cell(3, 2), cell(4, 2)],
		"budget": kv([
			rules.Kind.BELT, 2,
			rules.Kind.SLADE, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 59, rules.Mat.PLATE, 59]),
		"initial": [],
		"solution": [
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
			piece(rules.Kind.SLADE, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
		],
	}


static func two_stocks_slade() -> Dictionary:
	var rules = Rules
	# Two slades. Each sends the ore waiter backward into a kiln and the plate arrival forward.
	return {
		"id": 181,
		"name": "Two Stocks",
		"blurb": "Two slades, two materials. Both quotas are met only when each slade sends the waiter backward and the arrival forward.",
		"rule": "Two slades, two materials. The backward exit of each feeds a kiln with the ore waiter. The forward exit of each feeds a plate bin with the plate arrival. Both quotas are met only when each slade sends the waiter backward and the arrival forward. A landside sends the ore right, into a pit. A moldboard sends the ore left, into a pit. A coulter sends the ore forward and the plate right. A share sends the ore forward. A fork and a prong miss the forward bins. A slip sends the plate forward and holds the ore. A hoe sends the ore right and holds the plate. A belt, a dwell, a twin, a pass, a shed, a hook, a rake, and a harrow miss too.",
		"w": 6,
		"h": 5,
		"sources": [
			source(2, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(2, 3, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(5, 1, [rules.Mat.PLATE]),
			sink(0, 1, [rules.Mat.INGOT]),
			sink(5, 3, [rules.Mat.PLATE]),
			sink(0, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(3, 0), cell(3, 2), cell(3, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 2,
			rules.Kind.KILN, 2,
			rules.Kind.SLADE, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 118, rules.Mat.PLATE, 118]),
		"initial": [],
		"solution": [
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
			piece(rules.Kind.SLADE, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 3, rules.Dir.WEST),
			piece(rules.Kind.SLADE, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 3, rules.Dir.EAST),
		],
	}


static func after_split_slade() -> Dictionary:
	var rules = Rules
	# The slade faces south. Ore leaves backward, away from the scrap.
	# The plate leaves forward. The filter scraps the side ingots.
	return {
		"id": 182,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The slade sends the ore backward, away from the scrap, and the other item forward.",
		"rule": "A filter scraps the side ingots. The slade faces south. It sends the ore backward, away from the scrap, into the kiln, and the plate forward into the bin. A landside sends the ore right, into a pit. A moldboard sends the ore left, toward the scrap side. A coulter sends the ore forward, toward the plate line, and the plate right. A share sends the ore forward and the plate left. A fork sends the plate right and misses the forward bin. A prong misses the plate bin. A belt, a dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 6,
		"sources": [
			source(4, 2, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 5, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(4, 0, [rules.Mat.INGOT]),
			sink(4, 5, [rules.Mat.PLATE]),
		],
		"chutes": [cell(3, 3), cell(5, 3), cell(7, 3)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.ROLLER, 1,
			rules.Kind.SLADE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.KILN, 4, 1, rules.Dir.NORTH),
			piece(rules.Kind.SLADE, 4, 3, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 4, 4, rules.Dir.SOUTH),
			piece(rules.Kind.ROLLER, 6, 4, rules.Dir.NORTH),
			piece(rules.Kind.FILTER, 6, 3, rules.Dir.NORTH),
		],
	}


static func split_bin_slade() -> Dictionary:
	var rules = Rules
	# Ore leaves backward into the kiln line. Plates leave forward into their bin.
	# The splitter shares the ingots with the press. The lower plates are not enough alone.
	return {
		"id": 183,
		"name": "Split Bin",
		"blurb": "The backward stream and the forward stream each reach a different quota. A landside, a moldboard, a coulter, a share, a fork, and a prong each miss at least one.",
		"rule": "The slade sends the ore backward into the kiln and the plate forward into its bin. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. A landside sends the ore right, into a pit. A moldboard sends the ore left, into a pit. A coulter sends the ore forward and misses at least one quota. A share sends the plate left. A fork misses the plate quota. A prong misses the forward plates. A harrow, a hoe, and a rake each miss at least one quota. A belt, a dwell, a twin, a pass, a slip, a shed, and a hook miss too. Pressing every ingot misses the ingot bin.",
		"w": 6,
		"h": 6,
		"sources": [
			source(1, 3, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(0, 5, rules.Dir.EAST, [rules.Mat.PLATE], 4),
		],
		"sinks": [
			sink(1, 1, [rules.Mat.PLATE]),
			sink(2, 5, [rules.Mat.PLATE]),
			sink(4, 4, [rules.Mat.INGOT]),
			sink(5, 5, [rules.Mat.PLATE]),
		],
		"chutes": [cell(0, 2), cell(2, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.SLADE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 104]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SLADE, 1, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 1, 4, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 4, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 3, 4, rules.Dir.EAST),
			piece(rules.Kind.BELT, 1, 5, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 5, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 4, 5, rules.Dir.EAST),
		],
	}


static func held_pair_slade() -> Dictionary:
	var rules = Rules
	# Period 2, one cell behind the slade. The first ore waits through the empty tick.
	return {
		"id": 184,
		"name": "Held Pair",
		"blurb": "The pair leaves on the arrival tick, waiter backward and arrival forward, and the cell is empty afterward.",
		"rule": "The first item waits through a tick with nothing behind it, then the pair leaves on the arrival tick, the waiter backward and the arrival forward, and the cell is empty afterward. A belt would have moved the first item on that first tick. A lone item never leaves. A piece that keeps either item misses. A landside sends the ore right. A moldboard sends the ore left. A coulter sends the ore forward and the plate right. A share sends the ore forward. A fork and a prong miss the forward bin. A slip sends the plate forward and holds the ore. A hoe sends the ore right and holds the plate. A dwell, a twin, a pass, a shed, a hook, a rake, and a harrow miss too.",
		"w": 6,
		"h": 3,
		"sources": [
			source(2, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(5, 1, [rules.Mat.PLATE]),
			sink(0, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(3, 0), cell(3, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SLADE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
			piece(rules.Kind.SLADE, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
		],
	}



static func forward_ore() -> Dictionary:
	var rules = Rules
	# Heel faces east. Ore leaves forward into the kiln. Plate leaves backward onto the source bin.
	return {
		"id": 185,
		"name": "Forward Ore",
		"blurb": "The first item is ore and leaves forward into a kiln. The plate that arrives behind it leaves backward into the plate bin.",
		"rule": "The first item is ore. It leaves forward into the kiln. The plate that arrives behind it leaves backward into the plate bin on the source. A landside sends the ore right. A moldboard sends the ore left. A coulter sends the plate right. A share sends the plate left. A slade sends the ore backward into the plate bin, which refuses ore. A fork and a prong miss both bins. A slip sends the plate forward and holds the ore. A hoe sends the ore right and holds the plate. A belt, a dwell, a twin, a pass, a shed, a hook, a rake, and a harrow miss too.",
		"w": 6,
		"h": 3,
		"sources": [
			source(2, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 1, [rules.Mat.PLATE]),
			sink(5, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(3, 0), cell(3, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.HEEL, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HEEL, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.EAST),
		],
	}


static func still_heel() -> Dictionary:
	var rules = Rules
	# The heel faces south. The one belt is the crossing that turns the kiln output.
	return {
		"id": 186,
		"name": "Still Heel",
		"blurb": "The tray has one belt, on the crossing. The heel faces south. The first item stays until a later item arrives, then the first leaves forward and the later item leaves backward.",
		"rule": "The tray has one belt, on the crossing. The heel faces south. The first item stays until a later item arrives, then the ore leaves forward into the kiln and the plate leaves backward into the plate bin. The belt turns the ingot off that lane. A filter scraps a side stream. A landside sends the ore right. A moldboard sends the ore left. A coulter sends the plate right. A share sends the plate left. A slade sends the ore backward. A fork misses both bins. A belt, a dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(0, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(3, 0, [rules.Mat.PLATE]),
			sink(4, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 1), cell(4, 1), cell(1, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.HEEL, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HEEL, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 0, 2, rules.Dir.NORTH),
		],
	}


static func seat_heel() -> Dictionary:
	var rules = Rules
	return {
		"id": 187,
		"name": "Seat",
		"blurb": "The heel starts off the lane. Seat it where the ore leaves forward and the plate leaves backward.",
		"rule": "The heel starts off the lane. Pick it up and seat it where the ore has to leave forward into the kiln and the plate has to leave backward into the plate bin. Leaving it parked misses. A landside seated there sends the ore right. A moldboard seated there sends the ore left. A coulter seated there misses the plate bin. A slade seated there sends the ore backward. A slip sends the plate forward and holds the ore. A hoe sends the ore right and holds the plate. A belt, a dwell, a twin, a pass, a share, a fork, a prong, a shed, a hook, a rake, and a harrow miss too.",
		"w": 6,
		"h": 3,
		"sources": [
			source(2, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 1, [rules.Mat.PLATE]),
			sink(5, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(3, 0), cell(3, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.HEEL, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [
			piece(rules.Kind.HEEL, 5, 2, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.HEEL, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.EAST),
		],
	}


static func split_corner_heel() -> Dictionary:
	var rules = Rules
	return {
		"id": 188,
		"name": "Split Corner",
		"blurb": "A wall closes the right lane a landside would use. The waiter leaves forward and the arrival leaves backward.",
		"rule": "A wall closes the right lane a landside would use. Later items enter from behind. The waiter leaves forward into the kiln and the arrival leaves backward into the plate bin. A landside sends the waiter into the wall. A coulter sends the plate into the wall. A moldboard sends the ore left, into a pit. A share sends the plate left. A slade sends the ore backward. A fork and a prong miss both bins. A belt, a dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 3,
		"sources": [
			source(1, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(1, 1, [rules.Mat.PLATE]),
			sink(4, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 0)],
		"walls": [cell(2, 2), cell(3, 2)],
		"budget": kv([
			rules.Kind.HEEL, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 59, rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HEEL, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.EAST),
		],
	}


static func two_stocks_heel() -> Dictionary:
	var rules = Rules
	return {
		"id": 189,
		"name": "Two Stocks",
		"blurb": "Two heels, two materials. Both quotas are met only when each heel sends the waiter forward and the arrival backward.",
		"rule": "Two heels, two materials. The forward exit of each feeds a kiln with the ore waiter. The backward exit of each feeds a plate bin with the plate arrival. Both quotas are met only when each heel sends the waiter forward and the arrival backward. A landside sends the ore right. A moldboard sends the ore left. A coulter sends the plate right. A share sends the plate left. A slade sends the ore backward. A fork and a prong miss the bins. A slip holds the ore. A hoe holds the plate. A belt, a dwell, a twin, a pass, a shed, a hook, a rake, and a harrow miss too.",
		"w": 6,
		"h": 5,
		"sources": [
			source(1, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(1, 3, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(1, 1, [rules.Mat.PLATE]),
			sink(4, 1, [rules.Mat.INGOT]),
			sink(1, 3, [rules.Mat.PLATE]),
			sink(4, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 0), cell(2, 2), cell(2, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 2,
			rules.Kind.HEEL, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 118, rules.Mat.PLATE, 120]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HEEL, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.HEEL, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 3, rules.Dir.EAST),
		],
	}


static func after_split_heel() -> Dictionary:
	var rules = Rules
	return {
		"id": 190,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The heel sends the ore forward, away from the scrap, and the other item backward.",
		"rule": "A filter scraps the side ingots. The heel faces south. It sends the ore forward, away from the scrap, into the kiln, and the plate backward into the bin. A landside sends the ore right. A moldboard sends the ore left. A coulter sends the plate right. A share sends the plate left. A slade sends the ore backward, into the plate bin. A fork misses the forward kiln. A belt, a dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(4, 0, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 2, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(4, 0, [rules.Mat.PLATE]),
			sink(5, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(3, 1), cell(5, 1), cell(7, 1)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.HEEL, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HEEL, 4, 1, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 4, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 6, 1, rules.Dir.NORTH),
		],
	}


static func split_bin_heel() -> Dictionary:
	var rules = Rules
	return {
		"id": 191,
		"name": "Split Bin",
		"blurb": "The forward stream and the backward stream each reach a different quota. A landside, a moldboard, a coulter, a share, a fork, a prong, and a slade each miss at least one.",
		"rule": "The heel sends the ore forward into the kiln and the plate backward into its bin. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. A landside sends the ore right. A moldboard sends the ore left. A coulter sends the plate right. A share sends the plate left. A slade sends the ore backward. A fork and a prong miss the forward kiln. A belt, a dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too. Pressing every ingot misses the ingot bin.",
		"w": 8,
		"h": 5,
		"sources": [
			source(1, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(0, 3, rules.Dir.EAST, [rules.Mat.PLATE], 4),
		],
		"sinks": [
			sink(1, 1, [rules.Mat.PLATE]),
			sink(6, 1, [rules.Mat.INGOT]),
			sink(6, 2, [rules.Mat.PLATE]),
			sink(2, 3, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 0), cell(2, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.HEEL, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 104]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HEEL, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 1, 3, rules.Dir.EAST),
		],
	}


static func held_pair_heel() -> Dictionary:
	var rules = Rules
	return {
		"id": 192,
		"name": "Held Pair",
		"blurb": "The pair leaves on the arrival tick, waiter forward and arrival backward, and the cell is empty afterward.",
		"rule": "The first item waits through a tick with nothing behind it, then the pair leaves on the arrival tick, the waiter forward and the arrival backward, and the cell is empty afterward. A belt would have moved the first item on that first tick. A lone item never leaves. A piece that keeps either item misses. A landside sends the ore right. A moldboard sends the ore left. A coulter sends the plate right. A share sends the plate left. A slade sends the ore backward. A fork and a prong miss both bins. A slip sends the plate forward and holds the ore. A hoe sends the ore right and holds the plate. A dwell, a twin, a pass, a shed, a hook, a rake, and a harrow miss too.",
		"w": 7,
		"h": 3,
		"sources": [
			source(2, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 1, [rules.Mat.PLATE]),
			sink(6, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(3, 0), cell(3, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.HEEL, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HEEL, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 1, rules.Dir.EAST),
		],
	}



static func left_ore_stilt() -> Dictionary:
	var rules = Rules
	# Stilt faces east. Ore arrives from the left and leaves backward into the kiln. Plate leaves forward.
	return {
		"id": 193,
		"name": "Left Ore",
		"blurb": "The first item arrives from the left and leaves backward into a kiln. The plate that arrives from the left leaves forward into the plate bin.",
		"rule": "The first item is ore. It arrives from the left and leaves backward into the kiln. The plate that arrives from the left leaves forward into the plate bin. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind, so none of them takes the pair. A belt sends the ore forward into the plate bin and stalls. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 3,
		"sources": [
			source(2, 0, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(0, 1, [rules.Mat.INGOT]),
			sink(3, 1, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.STILT, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.STILT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
		],
	}


static func still_stilt() -> Dictionary:
	var rules = Rules
	# The stilt faces south. The one belt turns the kiln output off the backward lane.
	return {
		"id": 194,
		"name": "Still Stilt",
		"blurb": "The tray has one belt, on the crossing. The stilt faces south. The first item arrives from the left and leaves backward, and the later item leaves forward.",
		"rule": "The tray has one belt, on the crossing. The stilt faces south and takes the pair from the left. The ore leaves backward into the kiln and the plate leaves forward into the plate bin. The belt turns the ingot off that lane. A filter scraps a side stream. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A belt in the stilt cell sends the ore forward and stalls. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(4, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(0, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(3, 3, [rules.Mat.PLATE]),
			sink(4, 0, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 2), cell(1, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.STILT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.STILT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 3, 0, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 0, 2, rules.Dir.NORTH),
		],
	}


static func seat_stilt() -> Dictionary:
	var rules = Rules
	return {
		"id": 195,
		"name": "Seat",
		"blurb": "The stilt starts off the lane. Seat it where the ore arrives from the left and leaves backward.",
		"rule": "The stilt starts off the lane. Pick it up and seat it where the ore arrives from the left and leaves backward into the kiln, and the plate leaves forward into the plate bin. Leaving it parked misses. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A belt seated there stalls on the plate bin. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 3,
		"sources": [
			source(2, 0, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(0, 1, [rules.Mat.INGOT]),
			sink(3, 1, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.STILT, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [
			piece(rules.Kind.STILT, 5, 2, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.STILT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
		],
	}


static func split_corner_stilt() -> Dictionary:
	var rules = Rules
	return {
		"id": 196,
		"name": "Split Corner",
		"blurb": "A wall closes the right lane. The waiter leaves backward and the arrival leaves forward.",
		"rule": "A wall closes the right lane. Items arrive from the left. The waiter leaves backward into the kiln and the arrival leaves forward into the plate bin. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A belt sends the ore forward and stalls. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 3,
		"sources": [
			source(2, 0, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(0, 1, [rules.Mat.INGOT]),
			sink(3, 1, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(2, 2), cell(3, 2)],
		"budget": kv([
			rules.Kind.STILT, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 59, rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.STILT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
		],
	}


static func two_stocks_stilt() -> Dictionary:
	var rules = Rules
	return {
		"id": 197,
		"name": "Two Stocks",
		"blurb": "Two stilts, two materials. Both quotas are met only when each stilt sends the waiter backward and the arrival forward.",
		"rule": "Two stilts, two materials. Each takes its pair from the left. The backward exit of each feeds a kiln with the ore waiter. The forward exit of each feeds a plate bin with the plate arrival. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A belt stalls on each plate bin. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 5,
		"sources": [
			source(2, 0, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(2, 2, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(0, 1, [rules.Mat.INGOT]),
			sink(3, 1, [rules.Mat.PLATE]),
			sink(0, 3, [rules.Mat.INGOT]),
			sink(3, 3, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 2,
			rules.Kind.STILT, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 118, rules.Mat.PLATE, 120]),
		"initial": [],
		"solution": [
			piece(rules.Kind.STILT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
			piece(rules.Kind.STILT, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 3, rules.Dir.WEST),
		],
	}


static func after_split_stilt() -> Dictionary:
	var rules = Rules
	return {
		"id": 198,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The stilt sends the ore backward, away from the scrap, and the other item forward.",
		"rule": "A filter scraps the side ingots. The stilt faces south and takes the pair from the left. It sends the ore backward, away from the scrap, into the kiln, and the plate forward into the bin. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A belt sends the ore forward and stalls. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(5, 2, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(2, 3, [rules.Mat.PLATE]),
			sink(3, 0, [rules.Mat.INGOT]),
		],
		"chutes": [cell(1, 2), cell(6, 1)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.STILT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.STILT, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 0, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 5, 1, rules.Dir.NORTH),
		],
	}


static func split_bin_stilt() -> Dictionary:
	var rules = Rules
	return {
		"id": 199,
		"name": "Split Bin",
		"blurb": "The backward stream and the forward stream each reach a different quota. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel each miss at least one.",
		"rule": "The stilt takes the pair from the left. It sends the ore backward into the kiln and the plate forward into its bin. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A belt stalls on the forward plate bin. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too. Pressing every ingot misses the ingot bin.",
		"w": 8,
		"h": 5,
		"sources": [
			source(2, 2, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(0, 3, rules.Dir.EAST, [rules.Mat.PLATE], 4),
		],
		"sinks": [
			sink(1, 1, [rules.Mat.PLATE]),
			sink(6, 1, [rules.Mat.INGOT]),
			sink(6, 2, [rules.Mat.PLATE]),
			sink(2, 3, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 0)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.STILT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 104]),
		"initial": [],
		"solution": [
			piece(rules.Kind.STILT, 2, 1, rules.Dir.WEST),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 1, 3, rules.Dir.EAST),
		],
	}


static func held_pair_stilt() -> Dictionary:
	var rules = Rules
	return {
		"id": 200,
		"name": "Held Pair",
		"blurb": "The pair leaves on the arrival tick, waiter backward and arrival forward, and the cell is empty afterward.",
		"rule": "The first item arrives from the left and waits through a tick with nothing beside it, then the pair leaves on the arrival tick, the waiter backward and the arrival forward, and the cell is empty afterward. A belt would have moved the first item on that first tick. A lone item never leaves. A piece that keeps either item misses. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 7,
		"h": 3,
		"sources": [
			source(3, 0, rules.Dir.SOUTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(1, 1, [rules.Mat.INGOT]),
			sink(5, 1, [rules.Mat.PLATE]),
		],
		"chutes": [cell(3, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.STILT, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.KILN, 2, 1, rules.Dir.WEST),
			piece(rules.Kind.STILT, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
		],
	}



static func right_ore_clevis() -> Dictionary:
	var rules = Rules
	# Clevis faces east. Ore arrives from the right and leaves forward into the kiln. Plate leaves backward.
	return {
		"id": 201,
		"name": "Right Ore",
		"blurb": "The first item arrives from the right and leaves forward into a kiln. The plate that arrives from the right leaves backward into the plate bin.",
		"rule": "The first item is ore. It arrives from the right and leaves forward into the kiln. The plate that arrives from the right leaves backward into the plate bin. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A belt sends the ore forward and stalls the plate in the kiln. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 3,
		"sources": [
			source(2, 2, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(1, 1, [rules.Mat.PLATE]),
			sink(4, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 0)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.CLEVIS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.CLEVIS, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.EAST),
		],
	}


static func still_clevis() -> Dictionary:
	var rules = Rules
	# The clevis faces south. The one belt turns the kiln output off the forward lane.
	return {
		"id": 202,
		"name": "Still Clevis",
		"blurb": "The tray has one belt, on the crossing. The clevis faces south. The first item arrives from the right and leaves forward, and the later item leaves backward.",
		"rule": "The tray has one belt, on the crossing. The clevis faces south and takes the pair from the right. The ore leaves forward into the kiln and the plate leaves backward into the plate bin. The belt turns the ingot off that lane. A filter scraps a side stream. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A belt in the clevis cell sends the ore forward and stalls the plate. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(2, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(0, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(3, 0, [rules.Mat.PLATE]),
			sink(4, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(4, 1), cell(1, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.CLEVIS, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.CLEVIS, 3, 1, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 0, 2, rules.Dir.NORTH),
		],
	}


static func seat_clevis() -> Dictionary:
	var rules = Rules
	return {
		"id": 203,
		"name": "Seat",
		"blurb": "The clevis starts off the lane. Seat it where the ore arrives from the right and leaves forward.",
		"rule": "The clevis starts off the lane. Pick it up and seat it where the ore arrives from the right and leaves forward into the kiln, and the plate leaves backward into the plate bin. Leaving it parked misses. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A belt seated there stalls the plate in the kiln. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 3,
		"sources": [
			source(2, 2, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(1, 1, [rules.Mat.PLATE]),
			sink(4, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 0)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.CLEVIS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [
			piece(rules.Kind.CLEVIS, 5, 2, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.CLEVIS, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.EAST),
		],
	}


static func split_corner_clevis() -> Dictionary:
	var rules = Rules
	return {
		"id": 204,
		"name": "Split Corner",
		"blurb": "A wall closes the left lane. The waiter leaves forward and the arrival leaves backward.",
		"rule": "A wall closes the left lane. Items arrive from the right. The waiter leaves forward into the kiln and the arrival leaves backward into the plate bin. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A belt sends the ore forward and stalls the plate. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 3,
		"sources": [
			source(2, 2, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(1, 1, [rules.Mat.PLATE]),
			sink(4, 1, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [cell(2, 0), cell(3, 0)],
		"budget": kv([
			rules.Kind.CLEVIS, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 59, rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.CLEVIS, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.EAST),
		],
	}


static func two_stocks_clevis() -> Dictionary:
	var rules = Rules
	return {
		"id": 205,
		"name": "Two Stocks",
		"blurb": "Two clevises, two materials. Both quotas are met only when each clevis sends the waiter forward and the arrival backward.",
		"rule": "Two clevises, two materials. Each takes its pair from the right. The forward exit of each feeds a kiln with the ore waiter. The backward exit of each feeds a plate bin with the plate arrival. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A belt stalls the plate in each kiln. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 5,
		"sources": [
			source(2, 2, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(2, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(1, 1, [rules.Mat.PLATE]),
			sink(4, 1, [rules.Mat.INGOT]),
			sink(1, 3, [rules.Mat.PLATE]),
			sink(4, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 0)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 2,
			rules.Kind.CLEVIS, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 118, rules.Mat.PLATE, 120]),
		"initial": [],
		"solution": [
			piece(rules.Kind.CLEVIS, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.CLEVIS, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 3, rules.Dir.EAST),
		],
	}


static func after_split_clevis() -> Dictionary:
	var rules = Rules
	return {
		"id": 206,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The clevis sends the ore forward, away from the scrap, and the other item backward.",
		"rule": "A filter scraps the side ingots. The clevis faces south and takes the pair from the right. It sends the ore forward, away from the scrap, into the kiln, and the plate backward into the bin. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A belt sends the ore forward and stalls the plate. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(1, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(5, 2, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(2, 0, [rules.Mat.PLATE]),
			sink(3, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(3, 1), cell(6, 1)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.CLEVIS, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.CLEVIS, 2, 1, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 5, 1, rules.Dir.NORTH),
		],
	}


static func split_bin_clevis() -> Dictionary:
	var rules = Rules
	return {
		"id": 207,
		"name": "Split Bin",
		"blurb": "The forward stream and the backward stream each reach a different quota. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, a heel, and a stilt each miss at least one.",
		"rule": "The clevis takes the pair from the right. It sends the ore forward into the kiln and the plate backward into its bin. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A belt stalls the plate in the kiln. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too. Pressing every ingot misses the ingot bin.",
		"w": 8,
		"h": 5,
		"sources": [
			source(2, 2, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(0, 3, rules.Dir.EAST, [rules.Mat.PLATE], 4),
		],
		"sinks": [
			sink(1, 1, [rules.Mat.PLATE]),
			sink(6, 1, [rules.Mat.INGOT]),
			sink(6, 2, [rules.Mat.PLATE]),
			sink(2, 3, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 0)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.CLEVIS, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 104]),
		"initial": [],
		"solution": [
			piece(rules.Kind.CLEVIS, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 1, 3, rules.Dir.EAST),
		],
	}


static func held_pair_clevis() -> Dictionary:
	var rules = Rules
	return {
		"id": 208,
		"name": "Held Pair",
		"blurb": "The pair leaves on the arrival tick, waiter forward and arrival backward, and the cell is empty afterward.",
		"rule": "The first item arrives from the right and waits through a tick with nothing beside it, then the pair leaves on the arrival tick, the waiter forward and the arrival backward, and the cell is empty afterward. A belt would have moved the first item on that first tick. A lone item never leaves. A piece that keeps either item misses. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 7,
		"h": 3,
		"sources": [
			source(3, 2, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 1, [rules.Mat.PLATE]),
			sink(6, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(3, 0)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.CLEVIS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.CLEVIS, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 1, rules.Dir.EAST),
		],
	}



static func ahead_ore_beam() -> Dictionary:
	var rules = Rules
	# Beam faces east. Ore arrives from ahead and leaves backward into the kiln. Plate leaves left.
	return {
		"id": 209,
		"name": "Ahead Ore",
		"blurb": "The first item arrives from ahead and leaves backward into a kiln. The plate that arrives from ahead leaves left into the plate bin.",
		"rule": "The first item is ore. It arrives from ahead and leaves backward into the kiln. The plate that arrives from ahead leaves left into the plate bin. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 3,
		"sources": [
			source(3, 1, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 0, [rules.Mat.PLATE]),
			sink(0, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.BEAM, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BEAM, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
		],
	}


static func still_beam() -> Dictionary:
	var rules = Rules
	# The beam faces south. The one belt turns the kiln output off the backward lane.
	return {
		"id": 210,
		"name": "Still Beam",
		"blurb": "The tray has one belt, on the crossing. The beam faces south. The first item arrives from ahead and leaves backward, and the later item leaves left.",
		"rule": "The tray has one belt, on the crossing. The beam faces south and takes the pair from ahead. The ore leaves backward into the kiln and the plate leaves left into the plate bin. The belt turns the ingot off that lane. A filter scraps a side stream. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt in the beam cell refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(3, 3, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(0, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(4, 2, [rules.Mat.PLATE]),
			sink(4, 0, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 2), cell(1, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.BEAM, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BEAM, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 3, 0, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 0, 2, rules.Dir.NORTH),
		],
	}


static func seat_beam() -> Dictionary:
	var rules = Rules
	return {
		"id": 211,
		"name": "Seat",
		"blurb": "The beam starts off the lane. Seat it where the ore arrives from ahead and leaves backward.",
		"rule": "The beam starts off the lane. Pick it up and seat it where the ore arrives from ahead and leaves backward into the kiln, and the plate leaves left into the plate bin. Leaving it parked misses. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt seated there refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 3,
		"sources": [
			source(3, 1, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 0, [rules.Mat.PLATE]),
			sink(0, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.BEAM, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [
			piece(rules.Kind.BEAM, 5, 2, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.BEAM, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
		],
	}


static func split_corner_beam() -> Dictionary:
	var rules = Rules
	return {
		"id": 212,
		"name": "Split Corner",
		"blurb": "A wall closes the right lane. The waiter leaves backward and the arrival leaves left.",
		"rule": "A wall closes the right lane. Items arrive from ahead. The waiter leaves backward into the kiln and the arrival leaves left into the plate bin. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 3,
		"sources": [
			source(3, 1, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(2, 0, [rules.Mat.PLATE]),
			sink(0, 1, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [cell(2, 2), cell(3, 2)],
		"budget": kv([
			rules.Kind.BEAM, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 59, rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BEAM, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
		],
	}


static func two_stocks_beam() -> Dictionary:
	var rules = Rules
	return {
		"id": 213,
		"name": "Two Stocks",
		"blurb": "Two beams, two materials. Both quotas are met only when each beam sends the waiter backward and the arrival left.",
		"rule": "Two beams, two materials. Each takes its pair from ahead. The backward exit of each feeds a kiln with the ore waiter. The left exit of each feeds a plate bin with the plate arrival. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 1, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(3, 3, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(2, 0, [rules.Mat.PLATE]),
			sink(0, 1, [rules.Mat.INGOT]),
			sink(2, 2, [rules.Mat.PLATE]),
			sink(0, 3, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 2,
			rules.Kind.BEAM, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 118, rules.Mat.PLATE, 120]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BEAM, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
			piece(rules.Kind.BEAM, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 3, rules.Dir.WEST),
		],
	}


static func after_split_beam() -> Dictionary:
	var rules = Rules
	return {
		"id": 214,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The beam sends the ore backward, away from the scrap, and the other item left.",
		"rule": "A filter scraps the side ingots. The beam faces south and takes the pair from ahead. It sends the ore backward, away from the scrap, into the kiln, and the plate left into the bin. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(3, 3, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(0, 2, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(4, 2, [rules.Mat.PLATE]),
			sink(4, 0, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 2), cell(1, 1)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.BEAM, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BEAM, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 3, 0, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 0, 1, rules.Dir.NORTH),
		],
	}


static func split_bin_beam() -> Dictionary:
	var rules = Rules
	return {
		"id": 215,
		"name": "Split Bin",
		"blurb": "The backward stream and the left stream each reach a different quota. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, a heel, a stilt, and a clevis each miss at least one.",
		"rule": "The beam takes the pair from ahead. It sends the ore backward into the kiln and the plate left into its bin. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too. Pressing every ingot misses the ingot bin.",
		"w": 8,
		"h": 5,
		"sources": [
			source(1, 1, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(0, 3, rules.Dir.EAST, [rules.Mat.PLATE], 4),
		],
		"sinks": [
			sink(2, 2, [rules.Mat.PLATE]),
			sink(6, 1, [rules.Mat.INGOT]),
			sink(6, 2, [rules.Mat.PLATE]),
			sink(2, 3, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 0)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.BEAM, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 104]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BEAM, 2, 1, rules.Dir.WEST),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 1, 3, rules.Dir.EAST),
		],
	}


static func held_pair_beam() -> Dictionary:
	var rules = Rules
	return {
		"id": 216,
		"name": "Held Pair",
		"blurb": "The pair leaves on the arrival tick, waiter backward and arrival left, and the cell is empty afterward.",
		"rule": "The first item arrives from ahead and waits through a tick with nothing beside it, then the pair leaves on the arrival tick, the waiter backward and the arrival left, and the cell is empty afterward. A belt refuses that arrival from ahead, so the first item never steps onto the next cell. A lone item never leaves. A piece that keeps either item misses. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 7,
		"h": 3,
		"sources": [
			source(4, 1, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(3, 0, [rules.Mat.PLATE]),
			sink(0, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(3, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.BEAM, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BEAM, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.WEST),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
		],
	}



static func ahead_ore_hake() -> Dictionary:
	var rules = Rules
	# Hake faces east. Ore arrives from ahead and leaves backward into the kiln. Plate leaves right.
	return {
		"id": 217,
		"name": "Ahead Ore",
		"blurb": "The first item arrives from ahead and leaves backward into a kiln. The plate that arrives from ahead leaves right into the plate bin.",
		"rule": "The first item is ore. It arrives from ahead and leaves backward into the kiln. The plate that arrives from ahead leaves right into the plate bin. A beam sends that plate left. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 3,
		"sources": [
			source(3, 1, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 2, [rules.Mat.PLATE]),
			sink(0, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 0)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.HAKE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HAKE, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
		],
	}


static func still_hake() -> Dictionary:
	var rules = Rules
	# The hake faces south. The one belt turns the kiln output off the backward lane.
	return {
		"id": 218,
		"name": "Still Hake",
		"blurb": "The tray has one belt, on the crossing. The hake faces south. The first item arrives from ahead and leaves backward, and the later item leaves right.",
		"rule": "The tray has one belt, on the crossing. The hake faces south and takes the pair from ahead. The ore leaves backward into the kiln and the plate leaves right into the plate bin. The belt turns the ingot off that lane. A filter scraps a side stream. A beam would send the plate left. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt in the hake cell refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(3, 3, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(2, 2, [rules.Mat.PLATE]),
			sink(4, 0, [rules.Mat.INGOT]),
		],
		"chutes": [cell(4, 2), cell(7, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.HAKE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HAKE, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 3, 0, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 6, 2, rules.Dir.NORTH),
		],
	}


static func seat_hake() -> Dictionary:
	var rules = Rules
	return {
		"id": 219,
		"name": "Seat",
		"blurb": "The hake starts off the lane. Seat it where the ore arrives from ahead and leaves backward.",
		"rule": "The hake starts off the lane. Pick it up and seat it where the ore arrives from ahead and leaves backward into the kiln, and the plate leaves right into the plate bin. Leaving it parked misses. A beam would send the plate left. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt seated there refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 3,
		"sources": [
			source(3, 1, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 2, [rules.Mat.PLATE]),
			sink(0, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 0)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.HAKE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [
			piece(rules.Kind.HAKE, 5, 0, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.HAKE, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
		],
	}


static func split_corner_hake() -> Dictionary:
	var rules = Rules
	return {
		"id": 220,
		"name": "Split Corner",
		"blurb": "A wall closes the left lane. The waiter leaves backward and the arrival leaves right.",
		"rule": "A wall closes the left lane a beam would use. Items arrive from ahead. The waiter leaves backward into the kiln and the arrival leaves right into the plate bin. A beam sends the plate into the wall. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 3,
		"sources": [
			source(3, 1, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(2, 2, [rules.Mat.PLATE]),
			sink(0, 1, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [cell(2, 0), cell(3, 0)],
		"budget": kv([
			rules.Kind.HAKE, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 59, rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HAKE, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
		],
	}


static func two_stocks_hake() -> Dictionary:
	var rules = Rules
	return {
		"id": 221,
		"name": "Two Stocks",
		"blurb": "Two hakes, two materials. Both quotas are met only when each hake sends the waiter backward and the arrival right.",
		"rule": "Two hakes, two materials. Each takes its pair from ahead. The backward exit of each feeds a kiln with the ore waiter. The right exit of each feeds a plate bin with the plate arrival. A beam sends each plate left. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 0, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(2, 1, [rules.Mat.PLATE]),
			sink(0, 0, [rules.Mat.INGOT]),
			sink(2, 3, [rules.Mat.PLATE]),
			sink(0, 2, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 2,
			rules.Kind.HAKE, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 118, rules.Mat.PLATE, 120]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HAKE, 2, 0, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 0, rules.Dir.WEST),
			piece(rules.Kind.HAKE, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 2, rules.Dir.WEST),
		],
	}


static func after_split_hake() -> Dictionary:
	var rules = Rules
	return {
		"id": 222,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The hake sends the ore backward, away from the scrap, and the other item right.",
		"rule": "A filter scraps the side ingots. The hake faces south and takes the pair from ahead. It sends the ore backward, away from the scrap, into the kiln, and the plate right into the bin. A beam would send the plate toward the scrap. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(2, 3, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(1, 2, [rules.Mat.PLATE]),
			sink(3, 0, [rules.Mat.INGOT]),
		],
		"chutes": [cell(3, 2), cell(7, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.HAKE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HAKE, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 0, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 6, 2, rules.Dir.NORTH),
		],
	}


static func split_bin_hake() -> Dictionary:
	var rules = Rules
	return {
		"id": 223,
		"name": "Split Bin",
		"blurb": "The backward stream and the right stream each reach a different quota. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, a heel, a stilt, a clevis, and a beam each miss at least one.",
		"rule": "The hake takes the pair from ahead. It sends the ore backward into the kiln and the plate right into its bin. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. A beam sends the plate the other way. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too. Pressing every ingot misses the ingot bin.",
		"w": 8,
		"h": 5,
		"sources": [
			source(1, 2, rules.Dir.EAST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(0, 4, rules.Dir.EAST, [rules.Mat.PLATE], 4),
		],
		"sinks": [
			sink(2, 1, [rules.Mat.PLATE]),
			sink(6, 2, [rules.Mat.INGOT]),
			sink(6, 3, [rules.Mat.PLATE]),
			sink(2, 4, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 3)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.HAKE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 104]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HAKE, 2, 2, rules.Dir.WEST),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 1, 4, rules.Dir.EAST),
		],
	}


static func held_pair_hake() -> Dictionary:
	var rules = Rules
	return {
		"id": 224,
		"name": "Held Pair",
		"blurb": "The pair leaves on the arrival tick, waiter backward and arrival right, and the cell is empty afterward.",
		"rule": "The first item arrives from ahead and waits through a tick with nothing beside it, then the pair leaves on the arrival tick, the waiter backward and the arrival right, and the cell is empty afterward. A belt refuses that arrival from ahead, so the first item never steps onto the next cell. A beam would send the arrival left. A lone item never leaves. A piece that keeps either item misses. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 7,
		"h": 3,
		"sources": [
			source(4, 1, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(3, 2, [rules.Mat.PLATE]),
			sink(0, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(3, 0)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.HAKE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HAKE, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.WEST),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
		],
	}



static func ahead_ore_sole() -> Dictionary:
	var rules = Rules
	# Sole faces east. The plate arrives from ahead and leaves forward into the bin on the source. Ore leaves right.
	return {
		"id": 225,
		"name": "Ahead Ore",
		"blurb": "The first item arrives from ahead and leaves forward into the plate bin. The ore that arrives from ahead leaves right into a kiln.",
		"rule": "The first item is a plate. It arrives from ahead and leaves forward into the plate bin. The ore that arrives from ahead leaves right into the kiln. A hake sends that plate backward. A beam sends the ore left. A coulter, a landside, a moldboard, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 1, rules.Dir.WEST, [rules.Mat.PLATE, rules.Mat.ORE], 2),
		],
		"sinks": [
			sink(3, 1, [rules.Mat.PLATE]),
			sink(2, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(1, 1), cell(2, 0)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.SOLE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SOLE, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.SOUTH),
		],
	}


static func still_sole() -> Dictionary:
	var rules = Rules
	# The sole faces south. The one belt turns the kiln output off the right lane.
	return {
		"id": 226,
		"name": "Still Sole",
		"blurb": "The tray has one belt, on the crossing. The sole faces south. The first item arrives from ahead and leaves forward, and the later item leaves right.",
		"rule": "The tray has one belt, on the crossing. The sole faces south and takes the pair from ahead. The plate leaves forward into the plate bin and the ore leaves right into the kiln. The belt turns the ingot off that lane. A filter scraps a side stream. A hake would send the plate backward. A beam would send the ore left. A coulter, a landside, a moldboard, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt in the sole cell refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(3, 3, rules.Dir.NORTH, [rules.Mat.PLATE, rules.Mat.ORE], 2),
			source(6, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(3, 3, [rules.Mat.PLATE]),
			sink(1, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(3, 1), cell(4, 2), cell(7, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.SOLE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SOLE, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.WEST),
			piece(rules.Kind.BELT, 1, 2, rules.Dir.NORTH),
			piece(rules.Kind.FILTER, 6, 2, rules.Dir.NORTH),
		],
	}


static func seat_sole() -> Dictionary:
	var rules = Rules
	return {
		"id": 227,
		"name": "Seat",
		"blurb": "The sole starts off the lane. Seat it where the plate arrives from ahead and leaves forward.",
		"rule": "The sole starts off the lane. Pick it up and seat it where the plate arrives from ahead and leaves forward into the plate bin, and the ore leaves right into the kiln. Leaving it parked misses. A hake would send the plate backward. A beam would send the ore left. A coulter, a landside, a moldboard, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt seated there refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 1, rules.Dir.WEST, [rules.Mat.PLATE, rules.Mat.ORE], 2),
		],
		"sinks": [
			sink(3, 1, [rules.Mat.PLATE]),
			sink(2, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(1, 1), cell(2, 0)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.SOLE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [
			piece(rules.Kind.SOLE, 5, 0, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.SOLE, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.SOUTH),
		],
	}


static func split_corner_sole() -> Dictionary:
	var rules = Rules
	return {
		"id": 228,
		"name": "Split Corner",
		"blurb": "A wall closes the backward lane. The waiter leaves forward and the arrival leaves right.",
		"rule": "A wall closes the backward lane a hake would use. Items arrive from ahead. The waiter leaves forward into the plate bin and the arrival leaves right into the kiln. A hake sends the plate into the wall. A beam sends the ore into the other wall. A coulter, a landside, a moldboard, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 1, rules.Dir.WEST, [rules.Mat.PLATE, rules.Mat.ORE], 1),
		],
		"sinks": [
			sink(3, 1, [rules.Mat.PLATE]),
			sink(2, 3, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [cell(1, 1), cell(0, 1), cell(2, 0), cell(3, 0)],
		"budget": kv([
			rules.Kind.SOLE, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 59, rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SOLE, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.SOUTH),
		],
	}


static func two_stocks_sole() -> Dictionary:
	var rules = Rules
	return {
		"id": 229,
		"name": "Two Stocks",
		"blurb": "Two soles, two materials. Both quotas are met only when each sole sends the waiter forward and the arrival right.",
		"rule": "Two soles, two materials. Each takes its pair from ahead. The forward exit of each feeds the plate bin on its source. The right exit of each feeds a kiln with the ore arrival. A hake sends each plate backward. A beam sends each ore left. A coulter, a landside, a moldboard, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(2, 1, rules.Dir.WEST, [rules.Mat.PLATE, rules.Mat.ORE], 1),
			source(5, 1, rules.Dir.WEST, [rules.Mat.PLATE, rules.Mat.ORE], 1),
		],
		"sinks": [
			sink(2, 1, [rules.Mat.PLATE]),
			sink(1, 3, [rules.Mat.INGOT]),
			sink(5, 1, [rules.Mat.PLATE]),
			sink(4, 3, [rules.Mat.INGOT]),
		],
		"chutes": [cell(0, 1), cell(3, 1), cell(1, 0), cell(4, 0)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 2,
			rules.Kind.SOLE, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 118, rules.Mat.PLATE, 120]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SOLE, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 2, rules.Dir.SOUTH),
			piece(rules.Kind.SOLE, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 2, rules.Dir.SOUTH),
		],
	}


static func after_split_sole() -> Dictionary:
	var rules = Rules
	return {
		"id": 230,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The sole sends the plate forward and the ore right, away from the scrap.",
		"rule": "A filter scraps the side ingots. The sole faces south and takes the pair from ahead. It sends the plate forward into the bin and the ore right, away from the scrap, into the kiln. A hake would send the plate backward. A beam would send the ore toward the scrap. A coulter, a landside, a moldboard, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(2, 3, rules.Dir.NORTH, [rules.Mat.PLATE, rules.Mat.ORE], 2),
			source(6, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(2, 3, [rules.Mat.PLATE]),
			sink(0, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 1), cell(3, 2), cell(7, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.SOLE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SOLE, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 1, 2, rules.Dir.WEST),
			piece(rules.Kind.BELT, 0, 2, rules.Dir.NORTH),
			piece(rules.Kind.FILTER, 6, 2, rules.Dir.NORTH),
		],
	}


static func split_bin_sole() -> Dictionary:
	var rules = Rules
	return {
		"id": 231,
		"name": "Split Bin",
		"blurb": "The forward stream and the right stream each reach a different quota. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, a heel, a stilt, a clevis, a beam, and a hake each miss at least one.",
		"rule": "The sole takes the pair from ahead. It sends the plate forward into its bin and the ore right into the kiln. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. A hake sends the plate the other way. A beam sends the ore the other way. A coulter, a landside, a moldboard, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too. Pressing every ingot misses the ingot bin.",
		"w": 8,
		"h": 5,
		"sources": [
			source(2, 1, rules.Dir.SOUTH, [rules.Mat.PLATE, rules.Mat.ORE], 1),
			source(0, 4, rules.Dir.EAST, [rules.Mat.PLATE], 4),
		],
		"sinks": [
			sink(2, 1, [rules.Mat.PLATE]),
			sink(6, 2, [rules.Mat.INGOT]),
			sink(6, 3, [rules.Mat.PLATE]),
			sink(2, 4, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 3), cell(1, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.SOLE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 104]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SOLE, 2, 2, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 1, 4, rules.Dir.EAST),
		],
	}


static func held_pair_sole() -> Dictionary:
	var rules = Rules
	return {
		"id": 232,
		"name": "Held Pair",
		"blurb": "The pair leaves on the arrival tick, waiter forward and arrival right, and the cell is empty afterward.",
		"rule": "The first item arrives from ahead and waits through a tick with nothing beside it, then the pair leaves on the arrival tick, the waiter forward and the arrival right, and the cell is empty afterward. A belt refuses that arrival from ahead, so the first item never steps onto the next cell. A hake would send the waiter backward. A lone item never leaves. A piece that keeps either item misses. A coulter, a landside, a moldboard, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A beam sends the arrival left. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 7,
		"h": 5,
		"sources": [
			source(4, 1, rules.Dir.WEST, [rules.Mat.PLATE, rules.Mat.ORE], 2),
		],
		"sinks": [
			sink(4, 1, [rules.Mat.PLATE]),
			sink(3, 4, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 1), cell(3, 0)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SOLE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SOLE, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 3, 3, rules.Dir.SOUTH),
		],
	}



static func ahead_ore_frog() -> Dictionary:
	var rules = Rules
	# Frog faces east. The plate leaves forward onto the source. Ore leaves left into the kiln.
	return {
		"id": 233,
		"name": "Ahead Ore",
		"blurb": "The first item arrives from ahead and leaves forward into the plate bin. The ore that arrives from ahead leaves left into a kiln.",
		"rule": "The first item is a plate. It arrives from ahead and leaves forward into the plate bin. The ore that arrives from ahead leaves left into the kiln. A sole sends that ore right. A beam sends the plate backward. A share accepts only from behind. A hake sends the plate backward and the ore right. A coulter, a landside, a moldboard, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.PLATE, rules.Mat.ORE], 2),
		],
		"sinks": [
			sink(3, 2, [rules.Mat.PLATE]),
			sink(2, 0, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 3), cell(1, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.FROG, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.FROG, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.NORTH),
		],
	}


static func still_frog() -> Dictionary:
	var rules = Rules
	# The frog faces south. The one belt turns the kiln output off the left lane.
	return {
		"id": 234,
		"name": "Still Frog",
		"blurb": "The tray has one belt, on the crossing. The frog faces south. The first item arrives from ahead and leaves forward, and the later item leaves left.",
		"rule": "The tray has one belt, on the crossing. The frog faces south and takes the pair from ahead. The plate leaves forward into the plate bin and the ore leaves left into the kiln. The belt turns the ingot off that lane. A filter scraps a side stream. A sole would send the ore right. A beam would send the plate backward. A share accepts only from behind. A hake sends the plate backward. A coulter, a landside, a moldboard, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt in the frog cell refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(2, 3, rules.Dir.NORTH, [rules.Mat.PLATE, rules.Mat.ORE], 2),
			source(6, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(2, 3, [rules.Mat.PLATE]),
			sink(4, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 1), cell(1, 2), cell(7, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.FROG, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.FROG, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.NORTH),
			piece(rules.Kind.FILTER, 6, 2, rules.Dir.NORTH),
		],
	}


static func seat_frog() -> Dictionary:
	var rules = Rules
	return {
		"id": 235,
		"name": "Seat",
		"blurb": "The frog starts off the lane. Seat it where the plate arrives from ahead and leaves forward.",
		"rule": "The frog starts off the lane. Pick it up and seat it where the plate arrives from ahead and leaves forward into the plate bin, and the ore leaves left into the kiln. Leaving it parked misses. A sole would send the ore right. A beam would send the plate backward. A share accepts only from behind. A hake sends the plate backward. A coulter, a landside, a moldboard, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt seated there refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.PLATE, rules.Mat.ORE], 2),
		],
		"sinks": [
			sink(3, 2, [rules.Mat.PLATE]),
			sink(2, 0, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 3), cell(1, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.FROG, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [
			piece(rules.Kind.FROG, 5, 0, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.FROG, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.NORTH),
		],
	}


static func split_corner_frog() -> Dictionary:
	var rules = Rules
	return {
		"id": 236,
		"name": "Split Corner",
		"blurb": "A wall closes the right lane. The waiter leaves forward and the arrival leaves left.",
		"rule": "A wall closes the right lane a sole would use. Items arrive from ahead. The waiter leaves forward into the plate bin and the arrival leaves left into the kiln. A sole sends the ore into the wall. A beam sends the plate into the backward wall. A share accepts only from behind. A hake sends the plate backward. A coulter, a landside, a moldboard, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.PLATE, rules.Mat.ORE], 1),
		],
		"sinks": [
			sink(3, 2, [rules.Mat.PLATE]),
			sink(2, 0, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [cell(2, 3), cell(3, 3), cell(1, 2), cell(0, 2)],
		"budget": kv([
			rules.Kind.FROG, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 59, rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.FROG, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.NORTH),
		],
	}


static func two_stocks_frog() -> Dictionary:
	var rules = Rules
	return {
		"id": 237,
		"name": "Two Stocks",
		"blurb": "Two frogs, two materials. Both quotas are met only when each frog sends the waiter forward and the arrival left.",
		"rule": "Two frogs, two materials. Each takes its pair from ahead. The forward exit of each feeds the plate bin on its source. The left exit of each feeds a kiln with the ore arrival. A sole sends each ore right. A beam sends each plate backward. A share accepts only from behind. A hake sends each plate backward. A coulter, a landside, a moldboard, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(2, 2, rules.Dir.WEST, [rules.Mat.PLATE, rules.Mat.ORE], 1),
			source(5, 2, rules.Dir.WEST, [rules.Mat.PLATE, rules.Mat.ORE], 1),
		],
		"sinks": [
			sink(2, 2, [rules.Mat.PLATE]),
			sink(1, 0, [rules.Mat.INGOT]),
			sink(5, 2, [rules.Mat.PLATE]),
			sink(4, 0, [rules.Mat.INGOT]),
		],
		"chutes": [cell(1, 3), cell(4, 3), cell(0, 2), cell(3, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 2,
			rules.Kind.FROG, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 118, rules.Mat.PLATE, 120]),
		"initial": [],
		"solution": [
			piece(rules.Kind.FROG, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.NORTH),
			piece(rules.Kind.FROG, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.NORTH),
		],
	}


static func after_split_frog() -> Dictionary:
	var rules = Rules
	return {
		"id": 238,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The frog sends the plate forward and the ore left, away from the scrap.",
		"rule": "A filter scraps the side ingots. The frog faces south and takes the pair from ahead. It sends the plate forward into the bin and the ore left, away from the scrap, into the kiln. A sole would send the ore toward the scrap. A beam would send the plate backward. A share accepts only from behind. A hake sends the plate backward. A coulter, a landside, a moldboard, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(4, 3, rules.Dir.NORTH, [rules.Mat.PLATE, rules.Mat.ORE], 2),
			source(1, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(4, 3, [rules.Mat.PLATE]),
			sink(6, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(4, 1), cell(3, 2), cell(2, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.FROG, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.FROG, 4, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 2, rules.Dir.NORTH),
			piece(rules.Kind.FILTER, 1, 2, rules.Dir.NORTH),
		],
	}


static func split_bin_frog() -> Dictionary:
	var rules = Rules
	return {
		"id": 239,
		"name": "Split Bin",
		"blurb": "The forward stream and the left stream each reach a different quota. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, a heel, a stilt, a clevis, a beam, a hake, and a sole each miss at least one.",
		"rule": "The frog takes the pair from ahead. It sends the plate forward into its bin and the ore left into the kiln. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. A sole sends the ore the other way. A beam sends the plate the other way. A share accepts only from behind. A hake sends the plate backward. A coulter, a landside, a moldboard, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too. Pressing every ingot misses the ingot bin.",
		"w": 8,
		"h": 5,
		"sources": [
			source(2, 3, rules.Dir.NORTH, [rules.Mat.PLATE, rules.Mat.ORE], 1),
			source(0, 4, rules.Dir.EAST, [rules.Mat.PLATE], 4),
		],
		"sinks": [
			sink(2, 3, [rules.Mat.PLATE]),
			sink(6, 2, [rules.Mat.INGOT]),
			sink(6, 3, [rules.Mat.PLATE]),
			sink(2, 4, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 1), cell(1, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.FROG, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 104]),
		"initial": [],
		"solution": [
			piece(rules.Kind.FROG, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 1, 4, rules.Dir.EAST),
		],
	}


static func held_pair_frog() -> Dictionary:
	var rules = Rules
	return {
		"id": 240,
		"name": "Held Pair",
		"blurb": "The pair leaves on the arrival tick, waiter forward and arrival left, and the cell is empty afterward.",
		"rule": "The first item arrives from ahead and waits through a tick with nothing beside it, then the pair leaves on the arrival tick, the waiter forward and the arrival left, and the cell is empty afterward. A belt refuses that arrival from ahead, so the first item never steps onto the next cell. A sole would send the arrival right. A lone item never leaves. A piece that keeps either item misses. A share accepts only from behind. A beam sends the waiter backward. A hake sends the waiter backward and the arrival right. A coulter, a landside, a moldboard, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 7,
		"h": 5,
		"sources": [
			source(4, 3, rules.Dir.WEST, [rules.Mat.PLATE, rules.Mat.ORE], 2),
		],
		"sinks": [
			sink(4, 3, [rules.Mat.PLATE]),
			sink(3, 0, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 3), cell(3, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FROG, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.FROG, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.NORTH),
		],
	}



static func ahead_ore_shin() -> Dictionary:
	var rules = Rules
	# Shin faces east. Ore leaves left into the kiln. The plate leaves forward onto the source.
	return {
		"id": 241,
		"name": "Ahead Ore",
		"blurb": "The first item arrives from ahead and leaves left into a kiln. The plate that arrives from ahead leaves forward into the plate bin.",
		"rule": "The first item is ore. It arrives from ahead and leaves left into the kiln. The plate that arrives from ahead leaves forward into the plate bin. A frog sends that ore forward. A beam sends the ore backward. A moldboard accepts only from behind. A sole sends the ore forward and the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(3, 2, [rules.Mat.PLATE]),
			sink(2, 0, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 3), cell(1, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.SHIN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SHIN, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.NORTH),
		],
	}


static func still_shin() -> Dictionary:
	var rules = Rules
	return {
		"id": 242,
		"name": "Still Shin",
		"blurb": "The tray has one belt, on the crossing. The shin faces south. The first item arrives from ahead and leaves left, and the later item leaves forward.",
		"rule": "The tray has one belt, on the crossing. The shin faces south and takes the pair from ahead. The ore leaves left into the kiln and the plate leaves forward into the plate bin. The belt turns the ingot off that lane. A filter scraps a side stream. A frog would send the ore forward. A beam would send the ore backward. A moldboard accepts only from behind. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt in the shin cell refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(2, 3, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(2, 3, [rules.Mat.PLATE]),
			sink(4, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 1), cell(1, 2), cell(7, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.SHIN, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SHIN, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.NORTH),
			piece(rules.Kind.FILTER, 6, 2, rules.Dir.NORTH),
		],
	}


static func seat_shin() -> Dictionary:
	var rules = Rules
	return {
		"id": 243,
		"name": "Seat",
		"blurb": "The shin starts off the lane. Seat it where the ore arrives from ahead and leaves left.",
		"rule": "The shin starts off the lane. Pick it up and seat it where the ore arrives from ahead and leaves left into the kiln, and the plate leaves forward into the plate bin. Leaving it parked misses. A frog would send the ore forward. A beam would send the ore backward. A moldboard accepts only from behind. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt seated there refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(3, 2, [rules.Mat.PLATE]),
			sink(2, 0, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 3), cell(1, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.SHIN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [
			piece(rules.Kind.SHIN, 5, 0, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.SHIN, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.NORTH),
		],
	}


static func split_corner_shin() -> Dictionary:
	var rules = Rules
	return {
		"id": 244,
		"name": "Split Corner",
		"blurb": "A wall closes the forward lane a frog would use. The waiter leaves left and the arrival leaves forward.",
		"rule": "A wall closes the right lane. Items arrive from ahead. The waiter leaves left into the kiln and the arrival leaves forward into the plate bin. A frog sends the ore into the plate bin and misses the kiln. A beam sends the ore into the backward wall. A moldboard accepts only from behind. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(3, 2, [rules.Mat.PLATE]),
			sink(2, 0, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [cell(2, 3), cell(3, 3), cell(1, 2), cell(0, 2)],
		"budget": kv([
			rules.Kind.SHIN, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 59, rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SHIN, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.NORTH),
		],
	}


static func two_stocks_shin() -> Dictionary:
	var rules = Rules
	return {
		"id": 245,
		"name": "Two Stocks",
		"blurb": "Two shins, two materials. Both quotas are met only when each shin sends the waiter left and the arrival forward.",
		"rule": "Two shins, two materials. Each takes its pair from ahead. The left exit of each feeds a kiln with the ore waiter. The forward exit of each feeds the plate bin on its source. A frog sends each ore forward. A beam sends each ore backward. A moldboard accepts only from behind. A sole sends each ore forward. A hake sends each ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(2, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(5, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(2, 2, [rules.Mat.PLATE]),
			sink(1, 0, [rules.Mat.INGOT]),
			sink(5, 2, [rules.Mat.PLATE]),
			sink(4, 0, [rules.Mat.INGOT]),
		],
		"chutes": [cell(1, 3), cell(4, 3), cell(0, 2), cell(3, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 2,
			rules.Kind.SHIN, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 118, rules.Mat.PLATE, 120]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SHIN, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.NORTH),
			piece(rules.Kind.SHIN, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.NORTH),
		],
	}


static func after_split_shin() -> Dictionary:
	var rules = Rules
	return {
		"id": 246,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The shin sends the ore left, away from the scrap, and the plate forward.",
		"rule": "A filter scraps the side ingots. The shin faces south and takes the pair from ahead. It sends the ore left, away from the scrap, into the kiln, and the plate forward into the bin. A frog would send the ore forward. A beam would send the ore backward. A moldboard accepts only from behind. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(4, 3, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(1, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(4, 3, [rules.Mat.PLATE]),
			sink(6, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(4, 1), cell(3, 2), cell(2, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.SHIN, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SHIN, 4, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 2, rules.Dir.NORTH),
			piece(rules.Kind.FILTER, 1, 2, rules.Dir.NORTH),
		],
	}


static func split_bin_shin() -> Dictionary:
	var rules = Rules
	return {
		"id": 247,
		"name": "Split Bin",
		"blurb": "The left stream and the forward stream each reach a different quota. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, a heel, a stilt, a clevis, a beam, a hake, a sole, and a frog each miss at least one.",
		"rule": "The shin takes the pair from ahead. It sends the ore left into the kiln and the plate forward into its bin. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. A frog sends the ore forward. A beam sends the ore backward. A moldboard accepts only from behind. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too. Pressing every ingot misses the ingot bin.",
		"w": 8,
		"h": 5,
		"sources": [
			source(2, 3, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(0, 4, rules.Dir.EAST, [rules.Mat.PLATE], 4),
		],
		"sinks": [
			sink(2, 3, [rules.Mat.PLATE]),
			sink(6, 2, [rules.Mat.INGOT]),
			sink(6, 3, [rules.Mat.PLATE]),
			sink(2, 4, [rules.Mat.PLATE]),
		],
		"chutes": [cell(2, 1), cell(1, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.SHIN, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 104]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SHIN, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 3, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 1, 4, rules.Dir.EAST),
		],
	}


static func held_pair_shin() -> Dictionary:
	var rules = Rules
	return {
		"id": 248,
		"name": "Held Pair",
		"blurb": "The pair leaves on the arrival tick, waiter left and arrival forward, and the cell is empty afterward.",
		"rule": "The first item arrives from ahead and waits through a tick with nothing beside it, then the pair leaves on the arrival tick, the waiter left and the arrival forward, and the cell is empty afterward. A belt refuses that arrival from ahead, so the first item never steps onto the next cell. A frog would send the waiter forward. A lone item never leaves. A piece that keeps either item misses. A moldboard accepts only from behind. A beam sends the waiter backward. A sole sends the waiter forward and the arrival right. A hake sends the waiter backward and the arrival right. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 7,
		"h": 5,
		"sources": [
			source(4, 3, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(4, 3, [rules.Mat.PLATE]),
			sink(3, 0, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 3), cell(3, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SHIN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.SHIN, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.NORTH),
		],
	}



static func ahead_ore_point() -> Dictionary:
	var rules = Rules
	# Point faces east. Ore leaves right into the kiln. The plate leaves forward onto the source.
	return {
		"id": 249,
		"name": "Ahead Ore",
		"blurb": "The first item arrives from ahead and leaves right into a kiln. The plate that arrives from ahead leaves forward into the plate bin.",
		"rule": "The first item is ore. It arrives from ahead and leaves right into the kiln. The plate that arrives from ahead leaves forward into the plate bin. A shin sends that ore left. A frog sends that ore forward. A sole sends the ore forward and the plate right. A beam sends the ore backward. A moldboard accepts only from behind. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 5,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(3, 2, [rules.Mat.PLATE]),
			sink(2, 4, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 1), cell(1, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.POINT, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.POINT, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 3, rules.Dir.SOUTH),
		],
	}


static func still_point() -> Dictionary:
	var rules = Rules
	return {
		"id": 250,
		"name": "Still Point",
		"blurb": "The tray has one belt, on the crossing. The point faces south. The first item arrives from ahead and leaves right, and the later item leaves forward.",
		"rule": "The tray has one belt, on the crossing. The point faces south and takes the pair from ahead. The ore leaves right into the kiln and the plate leaves forward into the plate bin. The belt turns the ingot off that lane. A filter scraps a side stream. A shin would send the ore left. A frog would send the ore forward. A sole sends the ore forward. A beam would send the ore backward. A moldboard accepts only from behind. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt in the point cell refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(2, 3, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(2, 3, [rules.Mat.PLATE]),
			sink(0, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 1), cell(3, 2), cell(7, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.POINT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.POINT, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 1, 2, rules.Dir.WEST),
			piece(rules.Kind.BELT, 0, 2, rules.Dir.NORTH),
			piece(rules.Kind.FILTER, 6, 2, rules.Dir.NORTH),
		],
	}


static func seat_point() -> Dictionary:
	var rules = Rules
	return {
		"id": 251,
		"name": "Seat",
		"blurb": "The point starts off the lane. Seat it where the ore arrives from ahead and leaves right.",
		"rule": "The point starts off the lane. Pick it up and seat it where the ore arrives from ahead and leaves right into the kiln, and the plate leaves forward into the plate bin. Leaving it parked misses. A shin would send the ore left. A frog would send the ore forward. A sole sends the ore forward. A beam would send the ore backward. A moldboard accepts only from behind. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt seated there refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 5,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(3, 2, [rules.Mat.PLATE]),
			sink(2, 4, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 1), cell(1, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.POINT, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [
			piece(rules.Kind.POINT, 5, 0, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.POINT, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 3, rules.Dir.SOUTH),
		],
	}


static func split_corner_point() -> Dictionary:
	var rules = Rules
	return {
		"id": 252,
		"name": "Split Corner",
		"blurb": "A wall closes the left lane a shin would use. The waiter leaves right and the arrival leaves forward.",
		"rule": "A wall closes the left lane. Items arrive from ahead. The waiter leaves right into the kiln and the arrival leaves forward into the plate bin. A shin sends the ore into the left wall. A frog sends the ore into the plate bin and misses the kiln. A sole sends the ore forward. A beam sends the ore into the backward wall. A moldboard accepts only from behind. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 5,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(3, 2, [rules.Mat.PLATE]),
			sink(2, 4, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [cell(2, 1), cell(3, 1), cell(1, 2), cell(0, 2)],
		"budget": kv([
			rules.Kind.POINT, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 59, rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.POINT, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 3, rules.Dir.SOUTH),
		],
	}


static func two_stocks_point() -> Dictionary:
	var rules = Rules
	return {
		"id": 253,
		"name": "Two Stocks",
		"blurb": "Two points, two materials. Both quotas are met only when each point sends the waiter right and the arrival forward.",
		"rule": "Two points, two materials. Each takes its pair from ahead. The right exit of each feeds a kiln with the ore waiter. The forward exit of each feeds the plate bin on its source. A shin sends each ore left. A frog sends each ore forward. A sole sends each ore forward. A beam sends each ore backward. A moldboard accepts only from behind. A hake sends each ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 5,
		"sources": [
			source(2, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(5, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(2, 2, [rules.Mat.PLATE]),
			sink(1, 4, [rules.Mat.INGOT]),
			sink(5, 2, [rules.Mat.PLATE]),
			sink(4, 4, [rules.Mat.INGOT]),
		],
		"chutes": [cell(1, 1), cell(4, 1), cell(0, 2), cell(3, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 2,
			rules.Kind.POINT, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 118, rules.Mat.PLATE, 120]),
		"initial": [],
		"solution": [
			piece(rules.Kind.POINT, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 3, rules.Dir.SOUTH),
			piece(rules.Kind.POINT, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 3, rules.Dir.SOUTH),
		],
	}


static func after_split_point() -> Dictionary:
	var rules = Rules
	return {
		"id": 254,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The point sends the ore right, away from the scrap, and the plate forward.",
		"rule": "A filter scraps the side ingots. The point faces south and takes the pair from ahead. It sends the ore right, away from the scrap, into the kiln, and the plate forward into the bin. A shin would send the ore toward the scrap. A frog would send the ore forward. A sole sends the ore forward. A beam would send the ore backward. A moldboard accepts only from behind. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(4, 3, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(4, 3, [rules.Mat.PLATE]),
			sink(2, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(4, 1), cell(5, 2), cell(7, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.POINT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.POINT, 4, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.WEST),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.NORTH),
			piece(rules.Kind.FILTER, 6, 2, rules.Dir.NORTH),
		],
	}


static func split_bin_point() -> Dictionary:
	var rules = Rules
	return {
		"id": 255,
		"name": "Split Bin",
		"blurb": "The right stream and the forward stream each reach a different quota. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, a heel, a stilt, a clevis, a beam, a hake, a sole, a frog, and a shin each miss at least one.",
		"rule": "The point takes the pair from ahead. It sends the ore right into the kiln and the plate forward into its bin. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. A shin sends the ore the other way. A frog sends the ore forward. A sole sends the ore forward. A beam sends the ore backward. A moldboard accepts only from behind. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too. Pressing every ingot misses the ingot bin.",
		"w": 8,
		"h": 6,
		"sources": [
			source(5, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(7, 5, rules.Dir.WEST, [rules.Mat.PLATE], 4),
		],
		"sinks": [
			sink(5, 4, [rules.Mat.PLATE]),
			sink(1, 3, [rules.Mat.INGOT]),
			sink(3, 0, [rules.Mat.PLATE]),
			sink(5, 5, [rules.Mat.PLATE]),
		],
		"chutes": [cell(5, 2), cell(6, 3)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.POINT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 104]),
		"initial": [],
		"solution": [
			piece(rules.Kind.POINT, 5, 3, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 4, 3, rules.Dir.WEST),
			piece(rules.Kind.SPLITTER, 3, 3, rules.Dir.WEST),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.WEST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.NORTH),
			piece(rules.Kind.PRESS, 3, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 6, 5, rules.Dir.WEST),
		],
	}


static func held_pair_point() -> Dictionary:
	var rules = Rules
	return {
		"id": 256,
		"name": "Held Pair",
		"blurb": "The pair leaves on the arrival tick, waiter right and arrival forward, and the cell is empty afterward.",
		"rule": "The first item arrives from ahead and waits through a tick with nothing beside it, then the pair leaves on the arrival tick, the waiter right and the arrival forward, and the cell is empty afterward. A belt refuses that arrival from ahead, so the first item never steps onto the next cell. A shin would send the waiter left. A frog would send the waiter forward. A lone item never leaves. A piece that keeps either item misses. A moldboard accepts only from behind. A beam sends the waiter backward. A sole sends the waiter forward and the arrival right. A hake sends the waiter backward and the arrival right. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 7,
		"h": 6,
		"sources": [
			source(4, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(4, 2, [rules.Mat.PLATE]),
			sink(3, 5, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 2), cell(3, 1)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.POINT, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.POINT, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 3, 4, rules.Dir.SOUTH),
		],
	}



static func ahead_ore_throat() -> Dictionary:
	var rules = Rules
	# Throat faces east. Ore leaves behind into the kiln. The plate leaves forward onto the source.
	return {
		"id": 257,
		"name": "Ahead Ore",
		"blurb": "The first item arrives from ahead and leaves behind into a kiln. The plate that arrives from ahead leaves forward into the plate bin.",
		"rule": "The first item is ore. It arrives from ahead and leaves behind into the kiln. The plate that arrives from ahead leaves forward into the plate bin. A point sends that ore right. A shin sends that ore left. A frog sends that ore forward. A sole sends the ore forward. A beam sends the ore backward and the plate left. A moldboard accepts only from behind. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(3, 2, [rules.Mat.PLATE]),
			sink(0, 2, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 1), cell(2, 3)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.THROAT, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.THROAT, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 2, rules.Dir.WEST),
		],
	}


static func still_throat() -> Dictionary:
	var rules = Rules
	return {
		"id": 258,
		"name": "Still Throat",
		"blurb": "The tray has one belt, on the crossing. The throat faces south. The first item arrives from ahead and leaves behind, and the later item leaves forward.",
		"rule": "The tray has one belt, on the crossing. The throat faces south and takes the pair from ahead. The ore leaves behind into the kiln and the plate leaves forward into the plate bin. The belt turns the ingot off that lane. A filter scraps a side stream. A point would send the ore right. A shin would send the ore left. A frog would send the ore forward. A sole sends the ore forward. A beam sends the ore backward and the plate left. A moldboard accepts only from behind. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt in the throat cell refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(2, 3, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(2, 3, [rules.Mat.PLATE]),
			sink(3, 0, [rules.Mat.INGOT]),
		],
		"chutes": [cell(1, 2), cell(3, 2), cell(7, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.THROAT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.THROAT, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 0, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 6, 2, rules.Dir.NORTH),
		],
	}


static func seat_throat() -> Dictionary:
	var rules = Rules
	return {
		"id": 259,
		"name": "Seat",
		"blurb": "The throat starts off the lane. Seat it where the ore arrives from ahead and leaves behind.",
		"rule": "The throat starts off the lane. Pick it up and seat it where the ore arrives from ahead and leaves behind into the kiln, and the plate leaves forward into the plate bin. Leaving it parked misses. A point would send the ore right. A shin would send the ore left. A frog would send the ore forward. A sole sends the ore forward. A beam sends the ore backward and the plate left. A moldboard accepts only from behind. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt seated there refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(3, 2, [rules.Mat.PLATE]),
			sink(0, 2, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 1), cell(2, 3)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.THROAT, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [
			piece(rules.Kind.THROAT, 5, 0, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.THROAT, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 2, rules.Dir.WEST),
		],
	}


static func split_corner_throat() -> Dictionary:
	var rules = Rules
	return {
		"id": 260,
		"name": "Split Corner",
		"blurb": "Walls close the side lanes a point or a shin would use. The waiter leaves behind and the arrival leaves forward.",
		"rule": "Walls close the side lanes. Items arrive from ahead. The waiter leaves behind into the kiln and the arrival leaves forward into the plate bin. A point sends the ore into the right wall. A shin sends the ore into the left wall. A frog sends the ore into the plate bin and misses the kiln. A sole sends the ore forward. A beam sends the plate into a side wall. A moldboard accepts only from behind. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(3, 2, [rules.Mat.PLATE]),
			sink(0, 2, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [cell(2, 1), cell(2, 3), cell(3, 1), cell(3, 3)],
		"budget": kv([
			rules.Kind.THROAT, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 59, rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.THROAT, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 2, rules.Dir.WEST),
		],
	}


static func two_stocks_throat() -> Dictionary:
	var rules = Rules
	return {
		"id": 261,
		"name": "Two Stocks",
		"blurb": "Two throats, two materials. Both quotas are met only when each throat sends the waiter behind and the arrival forward.",
		"rule": "Two throats, two materials. Each takes its pair from ahead. The behind exit of each feeds a kiln with the ore waiter. The forward exit of each feeds the plate bin on its source. A point sends each ore right. A shin sends each ore left. A frog sends each ore forward. A sole sends each ore forward. A beam sends each plate left. A moldboard accepts only from behind. A hake sends each ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(7, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(3, 2, [rules.Mat.PLATE]),
			sink(0, 2, [rules.Mat.INGOT]),
			sink(7, 2, [rules.Mat.PLATE]),
			sink(4, 2, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 1), cell(2, 3), cell(6, 1), cell(6, 3)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 2,
			rules.Kind.THROAT, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 118, rules.Mat.PLATE, 120]),
		"initial": [],
		"solution": [
			piece(rules.Kind.THROAT, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 2, rules.Dir.WEST),
			piece(rules.Kind.THROAT, 6, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 5, 2, rules.Dir.WEST),
		],
	}


static func after_split_throat() -> Dictionary:
	var rules = Rules
	return {
		"id": 262,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The throat sends the ore behind, away from the scrap, and the plate forward.",
		"rule": "A filter scraps the side ingots. The throat faces south and takes the pair from ahead. It sends the ore behind, away from the scrap, into the kiln, and the plate forward into the bin. A point would send the ore right. A shin would send the ore toward the scrap. A frog would send the ore forward. A sole sends the ore forward. A beam sends the plate left. A moldboard accepts only from behind. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(4, 3, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(4, 3, [rules.Mat.PLATE]),
			sink(3, 0, [rules.Mat.INGOT]),
		],
		"chutes": [cell(3, 2), cell(5, 2), cell(7, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.THROAT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.THROAT, 4, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 0, rules.Dir.WEST),
			piece(rules.Kind.FILTER, 6, 2, rules.Dir.NORTH),
		],
	}


static func split_bin_throat() -> Dictionary:
	var rules = Rules
	return {
		"id": 263,
		"name": "Split Bin",
		"blurb": "The behind stream and the forward stream each reach a different quota. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, a heel, a stilt, a clevis, a beam, a hake, a sole, a frog, a shin, and a point each miss at least one.",
		"rule": "The throat takes the pair from ahead. It sends the ore behind into the kiln and the plate forward into its bin. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. A point sends the ore right. A shin sends the ore left. A frog sends the ore forward. A sole sends the ore forward. A beam sends the plate left. A moldboard accepts only from behind. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too. Pressing every ingot misses the ingot bin.",
		"w": 8,
		"h": 6,
		"sources": [
			source(6, 3, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(7, 5, rules.Dir.WEST, [rules.Mat.PLATE], 4),
		],
		"sinks": [
			sink(6, 3, [rules.Mat.PLATE]),
			sink(1, 3, [rules.Mat.INGOT]),
			sink(3, 0, [rules.Mat.PLATE]),
			sink(5, 5, [rules.Mat.PLATE]),
		],
		"chutes": [cell(5, 2), cell(5, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.THROAT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 104]),
		"initial": [],
		"solution": [
			piece(rules.Kind.THROAT, 5, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 3, rules.Dir.WEST),
			piece(rules.Kind.SPLITTER, 3, 3, rules.Dir.WEST),
			piece(rules.Kind.BELT, 2, 3, rules.Dir.WEST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.NORTH),
			piece(rules.Kind.PRESS, 3, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 6, 5, rules.Dir.WEST),
		],
	}


static func held_pair_throat() -> Dictionary:
	var rules = Rules
	return {
		"id": 264,
		"name": "Held Pair",
		"blurb": "The pair leaves on the arrival tick, waiter behind and arrival forward, and the cell is empty afterward.",
		"rule": "The first item arrives from ahead and waits through a tick with nothing beside it, then the pair leaves on the arrival tick, the waiter behind and the arrival forward, and the cell is empty afterward. A belt refuses that arrival from ahead, so the first item never steps onto the next cell. A point would send the waiter right. A shin would send the waiter left. A lone item never leaves. A piece that keeps either item misses. A moldboard accepts only from behind. A beam sends the waiter backward and the arrival left. A sole sends the waiter forward. A frog sends the waiter forward. A hake sends the waiter backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(4, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(4, 2, [rules.Mat.PLATE]),
			sink(0, 2, [rules.Mat.INGOT]),
		],
		"chutes": [cell(3, 1), cell(3, 3)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.THROAT, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.THROAT, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.WEST),
			piece(rules.Kind.KILN, 1, 2, rules.Dir.WEST),
		],
	}



static func ahead_ore_wrest() -> Dictionary:
	var rules = Rules
	# Wrest faces east. Ore leaves left into the kiln. The plate leaves right into the plate bin.
	return {
		"id": 265,
		"name": "Ahead Ore",
		"blurb": "The first item arrives from ahead and leaves left into a kiln. The plate that arrives from ahead leaves right into the plate bin.",
		"rule": "The first item is ore. It arrives from ahead and leaves left into the kiln. The plate that arrives from ahead leaves right into the plate bin. Neither leaves forward. A throat sends that ore behind. A shin sends the plate forward. A point sends the ore right. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 0, [rules.Mat.INGOT]),
			sink(2, 3, [rules.Mat.PLATE]),
		],
		"chutes": [cell(1, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.WREST, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.WREST, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.NORTH),
		],
	}


static func still_wrest() -> Dictionary:
	var rules = Rules
	return {
		"id": 266,
		"name": "Still Wrest",
		"blurb": "The tray has one belt, on the crossing. The wrest faces south. The first item arrives from ahead and leaves left, and the later item leaves right.",
		"rule": "The tray has one belt, on the crossing. The wrest faces south and takes the pair from ahead. The ore leaves left into the kiln and the plate leaves right into the plate bin. Neither leaves forward. The belt turns the ingot off that lane. A filter scraps a side stream. A throat would send the ore behind. A shin would send the plate forward. A point would send the ore right. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt in the wrest cell refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(2, 3, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(1, 2, [rules.Mat.PLATE]),
			sink(4, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 1), cell(7, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.WREST, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.WREST, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.NORTH),
			piece(rules.Kind.FILTER, 6, 2, rules.Dir.NORTH),
		],
	}


static func seat_wrest() -> Dictionary:
	var rules = Rules
	return {
		"id": 267,
		"name": "Seat",
		"blurb": "The wrest starts off the lane. Seat it where the ore arrives from ahead and leaves left.",
		"rule": "The wrest starts off the lane. Pick it up and seat it where the ore arrives from ahead and leaves left into the kiln, and the plate leaves right into the plate bin. Leaving it parked misses. A throat would send the ore behind. A shin would send the plate forward. A point would send the ore right. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt seated there refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 0, [rules.Mat.INGOT]),
			sink(2, 3, [rules.Mat.PLATE]),
		],
		"chutes": [cell(1, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.WREST, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [
			piece(rules.Kind.WREST, 5, 0, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.WREST, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.NORTH),
		],
	}


static func split_corner_wrest() -> Dictionary:
	var rules = Rules
	return {
		"id": 268,
		"name": "Split Corner",
		"blurb": "A wall closes the behind lane a throat would use. The waiter leaves left and the arrival leaves right.",
		"rule": "A wall closes the behind lane. Items arrive from ahead. The waiter leaves left into the kiln and the arrival leaves right into the plate bin. Neither leaves forward. A throat sends the ore into the wall. A shin sends the plate forward. A point sends the ore right. A beam sends the ore into the wall. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(2, 0, [rules.Mat.INGOT]),
			sink(2, 3, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(1, 2), cell(0, 2)],
		"budget": kv([
			rules.Kind.WREST, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 59, rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.WREST, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.NORTH),
		],
	}


static func two_stocks_wrest() -> Dictionary:
	var rules = Rules
	return {
		"id": 269,
		"name": "Two Stocks",
		"blurb": "Two wrests, two materials. Both quotas are met only when each wrest sends the waiter left and the arrival right.",
		"rule": "Two wrests, two materials. Each takes its pair from ahead. The left exit of each feeds a kiln with the ore waiter. The right exit of each feeds the plate bin. Neither leaves forward. A throat sends each ore behind. A shin sends each plate forward. A point sends each ore right. A beam sends each ore backward. A moldboard accepts only from behind. A frog sends each ore forward. A sole sends each ore forward. A hake sends each ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(2, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(5, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(1, 0, [rules.Mat.INGOT]),
			sink(1, 3, [rules.Mat.PLATE]),
			sink(4, 0, [rules.Mat.INGOT]),
			sink(4, 3, [rules.Mat.PLATE]),
		],
		"chutes": [cell(0, 2), cell(3, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 2,
			rules.Kind.WREST, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 118, rules.Mat.PLATE, 120]),
		"initial": [],
		"solution": [
			piece(rules.Kind.WREST, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.NORTH),
			piece(rules.Kind.WREST, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.NORTH),
		],
	}


static func after_split_wrest() -> Dictionary:
	var rules = Rules
	return {
		"id": 270,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The wrest sends the ore left, away from the scrap, and the plate right.",
		"rule": "A filter scraps the side ingots. The wrest faces south and takes the pair from ahead. It sends the ore left, away from the scrap, into the kiln, and the plate right into the bin. Neither leaves forward. A throat would send the ore behind. A shin would send the plate forward. A point would send the ore toward the scrap. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(4, 3, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(1, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(3, 2, [rules.Mat.PLATE]),
			sink(6, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(4, 1), cell(2, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.WREST, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.WREST, 4, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 2, rules.Dir.NORTH),
			piece(rules.Kind.FILTER, 1, 2, rules.Dir.NORTH),
		],
	}


static func split_bin_wrest() -> Dictionary:
	var rules = Rules
	return {
		"id": 271,
		"name": "Split Bin",
		"blurb": "The left stream and the right stream each reach a different quota. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, a heel, a stilt, a clevis, a beam, a hake, a sole, a frog, a shin, a point, and a throat each miss at least one.",
		"rule": "The wrest takes the pair from ahead. It sends the ore left into the kiln and the plate right into its bin. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. Neither leaves forward. A throat sends the ore behind. A shin sends the plate forward. A point sends the ore right. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too. Pressing every ingot misses the ingot bin.",
		"w": 8,
		"h": 6,
		"sources": [
			source(5, 4, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(0, 5, rules.Dir.EAST, [rules.Mat.PLATE], 4),
		],
		"sinks": [
			sink(4, 5, [rules.Mat.PLATE]),
			sink(4, 0, [rules.Mat.INGOT]),
			sink(7, 2, [rules.Mat.PLATE]),
			sink(2, 5, [rules.Mat.PLATE]),
		],
		"chutes": [cell(3, 4)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.WREST, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 104]),
		"initial": [],
		"solution": [
			piece(rules.Kind.WREST, 4, 4, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 3, rules.Dir.NORTH),
			piece(rules.Kind.SPLITTER, 4, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 6, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 1, 5, rules.Dir.EAST),
		],
	}


static func held_pair_wrest() -> Dictionary:
	var rules = Rules
	return {
		"id": 272,
		"name": "Held Pair",
		"blurb": "The pair leaves on the arrival tick, waiter left and arrival right, and the cell is empty afterward.",
		"rule": "The first item arrives from ahead and waits through a tick with nothing beside it, then the pair leaves on the arrival tick, the waiter left and the arrival right, and the cell is empty afterward. Neither leaves forward. A belt refuses that arrival from ahead, so the first item never steps onto the next cell. A throat would send the waiter behind. A shin would send the arrival forward. A point would send the waiter right. A lone item never leaves. A piece that keeps either item misses. A moldboard accepts only from behind. A beam sends the waiter backward. A sole sends the waiter forward. A frog sends the waiter forward. A hake sends the waiter backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 5,
		"sources": [
			source(4, 3, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(3, 4, [rules.Mat.PLATE]),
			sink(3, 0, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 3)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.WREST, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.WREST, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.NORTH),
		],
	}



static func ahead_ore_jointer() -> Dictionary:
	var rules = Rules
	# Jointer faces east. Ore leaves right into the kiln. The plate leaves left into the plate bin.
	return {
		"id": 273,
		"name": "Ahead Ore",
		"blurb": "The first item arrives from ahead and leaves right into a kiln. The plate that arrives from ahead leaves left into the plate bin.",
		"rule": "The first item is ore. It arrives from ahead and leaves right into the kiln. The plate that arrives from ahead leaves left into the plate bin. Neither leaves forward. A wrest sends that ore left. A shin sends the plate forward. A point sends the plate left. A throat sends the ore behind. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 1, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 3, [rules.Mat.INGOT]),
			sink(2, 0, [rules.Mat.PLATE]),
		],
		"chutes": [cell(1, 1)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.JOINTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.JOINTER, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.SOUTH),
		],
	}


static func still_jointer() -> Dictionary:
	var rules = Rules
	return {
		"id": 274,
		"name": "Still Jointer",
		"blurb": "The tray has one belt, on the crossing. The jointer faces south. The first item arrives from ahead and leaves right, and the later item leaves left.",
		"rule": "The tray has one belt, on the crossing. The jointer faces south and takes the pair from ahead. The ore leaves right into the kiln and the plate leaves left into the plate bin. Neither leaves forward. The belt turns the ingot off that lane. A filter scraps a side stream. A wrest would send the ore left. A shin would send the plate forward. A point would send the plate left. A throat would send the ore behind. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt in the jointer cell refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(2, 3, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(5, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(3, 2, [rules.Mat.PLATE]),
			sink(0, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 1), cell(6, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.JOINTER, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.JOINTER, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 1, 2, rules.Dir.WEST),
			piece(rules.Kind.BELT, 0, 2, rules.Dir.NORTH),
			piece(rules.Kind.FILTER, 5, 2, rules.Dir.NORTH),
		],
	}


static func seat_jointer() -> Dictionary:
	var rules = Rules
	return {
		"id": 275,
		"name": "Seat",
		"blurb": "The jointer starts off the lane. Seat it where the ore arrives from ahead and leaves right.",
		"rule": "The jointer starts off the lane. Pick it up and seat it where the ore arrives from ahead and leaves right into the kiln, and the plate leaves left into the plate bin. Leaving it parked misses. A wrest would send the ore left. A shin would send the plate forward. A point would send the plate left. A throat would send the ore behind. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt seated there refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 1, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 3, [rules.Mat.INGOT]),
			sink(2, 0, [rules.Mat.PLATE]),
		],
		"chutes": [cell(1, 1)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.JOINTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [
			piece(rules.Kind.JOINTER, 5, 0, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.JOINTER, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.SOUTH),
		],
	}


static func split_corner_jointer() -> Dictionary:
	var rules = Rules
	return {
		"id": 276,
		"name": "Split Corner",
		"blurb": "A wall closes the behind lane a throat would use. The waiter leaves right and the arrival leaves left.",
		"rule": "A wall closes the behind lane. Items arrive from ahead. The waiter leaves right into the kiln and the arrival leaves left into the plate bin. Neither leaves forward. A wrest sends the ore into the plate bin. A throat sends the ore into the wall. A shin sends the plate forward. A point sends the plate left. A beam sends the ore into the wall. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 1, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(2, 3, [rules.Mat.INGOT]),
			sink(2, 0, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(1, 1), cell(0, 1)],
		"budget": kv([
			rules.Kind.JOINTER, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 59, rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.JOINTER, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.SOUTH),
		],
	}


static func two_stocks_jointer() -> Dictionary:
	var rules = Rules
	return {
		"id": 277,
		"name": "Two Stocks",
		"blurb": "Two jointers, two materials. Both quotas are met only when each jointer sends the waiter right and the arrival left.",
		"rule": "Two jointers, two materials. Each takes its pair from ahead. The right exit of each feeds a kiln with the ore waiter. The left exit of each feeds the plate bin. Neither leaves forward. A wrest sends each ore left. A throat sends each ore behind. A shin sends each plate forward. A point sends each plate left. A beam sends each ore backward. A moldboard accepts only from behind. A frog sends each ore forward. A sole sends each ore forward. A hake sends each ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 5,
		"sources": [
			source(2, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(5, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(1, 4, [rules.Mat.INGOT]),
			sink(1, 1, [rules.Mat.PLATE]),
			sink(4, 4, [rules.Mat.INGOT]),
			sink(4, 1, [rules.Mat.PLATE]),
		],
		"chutes": [cell(0, 2), cell(3, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.KILN, 2,
			rules.Kind.JOINTER, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 118, rules.Mat.PLATE, 120]),
		"initial": [],
		"solution": [
			piece(rules.Kind.JOINTER, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 3, rules.Dir.SOUTH),
			piece(rules.Kind.JOINTER, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 3, rules.Dir.SOUTH),
		],
	}


static func after_split_jointer() -> Dictionary:
	var rules = Rules
	return {
		"id": 278,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The jointer sends the ore right, away from the scrap, and the plate left.",
		"rule": "A filter scraps the side ingots. The jointer faces south and takes the pair from ahead. It sends the ore right, away from the scrap, into the kiln, and the plate left into the bin. Neither leaves forward. A wrest would send the ore toward the scrap. A shin would send the plate forward. A point would send the plate left. A throat would send the ore behind. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(2, 3, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(5, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(3, 2, [rules.Mat.PLATE]),
			sink(0, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 1), cell(6, 2)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.JOINTER, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.JOINTER, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 1, 2, rules.Dir.WEST),
			piece(rules.Kind.BELT, 0, 2, rules.Dir.NORTH),
			piece(rules.Kind.FILTER, 5, 2, rules.Dir.NORTH),
		],
	}


static func split_bin_jointer() -> Dictionary:
	var rules = Rules
	return {
		"id": 279,
		"name": "Split Bin",
		"blurb": "The left stream and the right stream each reach a different quota. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, a heel, a stilt, a clevis, a beam, a hake, a sole, a frog, a shin, a point, a throat, and a wrest each miss at least one.",
		"rule": "The jointer takes the pair from ahead. It sends the ore right into the kiln and the plate left into its bin. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. Neither leaves forward. A wrest sends the ore left. A throat sends the ore behind. A shin sends the plate forward. A point sends the plate left. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too. Pressing every ingot misses the ingot bin.",
		"w": 8,
		"h": 6,
		"sources": [
			source(5, 1, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(7, 5, rules.Dir.WEST, [rules.Mat.PLATE], 4),
		],
		"sinks": [
			sink(4, 0, [rules.Mat.PLATE]),
			sink(4, 5, [rules.Mat.INGOT]),
			sink(1, 3, [rules.Mat.PLATE]),
			sink(5, 5, [rules.Mat.PLATE]),
		],
		"chutes": [cell(3, 1)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.JOINTER, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 104]),
		"initial": [],
		"solution": [
			piece(rules.Kind.JOINTER, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 2, rules.Dir.SOUTH),
			piece(rules.Kind.SPLITTER, 4, 3, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 4, 4, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.WEST),
			piece(rules.Kind.PRESS, 2, 3, rules.Dir.WEST),
			piece(rules.Kind.BELT, 6, 5, rules.Dir.WEST),
		],
	}


static func held_pair_jointer() -> Dictionary:
	var rules = Rules
	return {
		"id": 280,
		"name": "Held Pair",
		"blurb": "The pair leaves on the arrival tick, waiter right and arrival left, and the cell is empty afterward.",
		"rule": "The first item arrives from ahead and waits through a tick with nothing beside it, then the pair leaves on the arrival tick, the waiter right and the arrival left, and the cell is empty afterward. Neither leaves forward. A belt refuses that arrival from ahead, so the first item never steps onto the next cell. A wrest would send the waiter left. A throat would send the waiter behind. A shin would send the arrival forward. A point would send the arrival left. A lone item never leaves. A piece that keeps either item misses. A moldboard accepts only from behind. A beam sends the waiter backward. A sole sends the waiter forward. A frog sends the waiter forward. A hake sends the waiter backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 5,
		"sources": [
			source(4, 1, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(3, 0, [rules.Mat.PLATE]),
			sink(3, 4, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 1)],
		"walls": [],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.JOINTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.JOINTER, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 3, 3, rules.Dir.SOUTH),
		],
	}



static func ahead_ore_bridle() -> Dictionary:
	var rules = Rules
	# Bridle faces east. Ore leaves left into the kiln. The plate leaves behind into the plate bin.
	return {
		"id": 281,
		"name": "Ahead Ore",
		"blurb": "The first item arrives from ahead and leaves left into a kiln. The plate that arrives from ahead leaves behind into the plate bin.",
		"rule": "The first item is ore. It arrives from ahead and leaves left into the kiln. The plate that arrives from ahead leaves behind into the plate bin. Neither leaves forward. A jointer sends that ore right. A wrest sends the plate right. A shin sends the plate forward. A point sends the ore right. A throat sends the ore into the plate bin. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 0, [rules.Mat.INGOT]),
			sink(1, 2, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(2, 3)],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.BRIDLE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BRIDLE, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.NORTH),
		],
	}


static func still_bridle() -> Dictionary:
	var rules = Rules
	return {
		"id": 282,
		"name": "Still Bridle",
		"blurb": "The tray has one belt, on the crossing. The bridle faces south. The first item arrives from ahead and leaves left, and the later item leaves behind.",
		"rule": "The tray has one belt, on the crossing. The bridle faces south and takes the pair from ahead. The ore leaves left into the kiln and the plate leaves behind into the plate bin. Neither leaves forward. The belt turns the ingot off that lane. A filter scraps a side stream. A jointer would send the ore right. A wrest would send the plate right. A shin would send the plate forward. A point would send the ore right. A throat would send the ore into the plate bin. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt in the bridle cell refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(2, 3, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(2, 1, [rules.Mat.PLATE]),
			sink(4, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(7, 2)],
		"walls": [cell(1, 2)],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.BRIDLE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BRIDLE, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 4, 2, rules.Dir.NORTH),
			piece(rules.Kind.FILTER, 6, 2, rules.Dir.NORTH),
		],
	}


static func seat_bridle() -> Dictionary:
	var rules = Rules
	return {
		"id": 283,
		"name": "Seat",
		"blurb": "The bridle starts off the lane. Seat it where the ore arrives from ahead and leaves left.",
		"rule": "The bridle starts off the lane. Pick it up and seat it where the ore arrives from ahead and leaves left into the kiln, and the plate leaves behind into the plate bin. Leaving it parked misses. A jointer would send the ore right. A wrest would send the plate right. A shin would send the plate forward. A point would send the ore right. A throat would send the ore into the plate bin. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt seated there refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 0, [rules.Mat.INGOT]),
			sink(1, 2, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(2, 3)],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.BRIDLE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [
			piece(rules.Kind.BRIDLE, 5, 0, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.BRIDLE, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.NORTH),
		],
	}


static func split_corner_bridle() -> Dictionary:
	var rules = Rules
	return {
		"id": 284,
		"name": "Split Corner",
		"blurb": "A wall closes the right lane a jointer would use. The waiter leaves left and the arrival leaves behind.",
		"rule": "A wall closes the right lane. Items arrive from ahead. The waiter leaves left into the kiln and the arrival leaves behind into the plate bin. Neither leaves forward. A jointer sends the ore into the wall. A wrest sends the plate into the wall. A shin sends the plate forward. A point sends the ore into the wall. A throat sends the ore into the plate bin. A beam sends the ore into the plate bin. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(2, 0, [rules.Mat.INGOT]),
			sink(1, 2, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(2, 3), cell(3, 3)],
		"budget": kv([
			rules.Kind.BRIDLE, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 59, rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BRIDLE, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 1, rules.Dir.NORTH),
		],
	}


static func two_stocks_bridle() -> Dictionary:
	var rules = Rules
	return {
		"id": 285,
		"name": "Two Stocks",
		"blurb": "Two bridles, two materials. Both quotas are met only when each bridle sends the waiter left and the arrival behind.",
		"rule": "Two bridles, two materials. Each takes its pair from ahead. The left exit of each feeds a kiln with the ore waiter. The behind exit of each feeds the plate bin. Neither leaves forward. A jointer sends each ore right. A wrest sends each plate right. A throat sends each ore into the plate bin. A shin sends each plate forward. A point sends each ore right. A beam sends each ore backward. A moldboard accepts only from behind. A frog sends each ore forward. A sole sends each ore forward. A hake sends each ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(2, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(5, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(1, 0, [rules.Mat.INGOT]),
			sink(0, 2, [rules.Mat.PLATE]),
			sink(4, 0, [rules.Mat.INGOT]),
			sink(3, 2, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(1, 3), cell(4, 3)],
		"budget": kv([
			rules.Kind.KILN, 2,
			rules.Kind.BRIDLE, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 118, rules.Mat.PLATE, 120]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BRIDLE, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.NORTH),
			piece(rules.Kind.BRIDLE, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 1, rules.Dir.NORTH),
		],
	}


static func after_split_bridle() -> Dictionary:
	var rules = Rules
	return {
		"id": 286,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The bridle sends the ore left, away from the scrap, and the plate behind.",
		"rule": "A filter scraps the side ingots. The bridle faces south and takes the pair from ahead. It sends the ore left, away from the scrap, into the kiln, and the plate behind into the bin. Neither leaves forward. A jointer would send the ore toward the scrap. A wrest would send the plate right. A shin would send the plate forward. A point would send the ore toward the scrap. A throat would send the ore into the plate bin. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(4, 3, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(1, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(4, 1, [rules.Mat.PLATE]),
			sink(6, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 2)],
		"walls": [cell(3, 2)],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.BRIDLE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BRIDLE, 4, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 2, rules.Dir.NORTH),
			piece(rules.Kind.FILTER, 1, 2, rules.Dir.NORTH),
		],
	}


static func split_bin_bridle() -> Dictionary:
	var rules = Rules
	return {
		"id": 287,
		"name": "Split Bin",
		"blurb": "The left stream and the behind stream each reach a different quota. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, a heel, a stilt, a clevis, a beam, a hake, a sole, a frog, a shin, a point, a throat, a wrest, and a jointer each miss at least one.",
		"rule": "The bridle takes the pair from ahead. It sends the ore left into the kiln and the plate behind into its bin. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. Neither leaves forward. A jointer sends the ore right. A wrest sends the plate right. A throat sends the ore into the plate bin. A shin sends the plate forward. A point sends the ore right. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too. Pressing every ingot misses the ingot bin.",
		"w": 8,
		"h": 6,
		"sources": [
			source(5, 4, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(0, 5, rules.Dir.EAST, [rules.Mat.PLATE], 4),
		],
		"sinks": [
			sink(3, 4, [rules.Mat.PLATE]),
			sink(4, 0, [rules.Mat.INGOT]),
			sink(7, 2, [rules.Mat.PLATE]),
			sink(2, 5, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(4, 5)],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.BRIDLE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 104]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BRIDLE, 4, 4, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 3, rules.Dir.NORTH),
			piece(rules.Kind.SPLITTER, 4, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.PRESS, 6, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 1, 5, rules.Dir.EAST),
		],
	}


static func held_pair_bridle() -> Dictionary:
	var rules = Rules
	return {
		"id": 288,
		"name": "Held Pair",
		"blurb": "The pair leaves on the arrival tick, waiter left and arrival behind, and the cell is empty afterward.",
		"rule": "The first item arrives from ahead and waits through a tick with nothing beside it, then the pair leaves on the arrival tick, the waiter left and the arrival behind, and the cell is empty afterward. Neither leaves forward. A belt refuses that arrival from ahead, so the first item never steps onto the next cell. A jointer would send the waiter right. A wrest would send the arrival right. A throat would send the waiter into the plate bin. A shin would send the arrival forward. A point would send the waiter right. A lone item never leaves. A piece that keeps either item misses. A moldboard accepts only from behind. A beam sends the waiter backward. A sole sends the waiter forward. A frog sends the waiter forward. A hake sends the waiter backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 5,
		"sources": [
			source(4, 3, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 3, [rules.Mat.PLATE]),
			sink(3, 0, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [cell(3, 4)],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.BRIDLE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BRIDLE, 3, 3, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.NORTH),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.NORTH),
		],
	}



static func ahead_ore_trashboard() -> Dictionary:
	var rules = Rules
	# Trashboard faces east. Ore leaves right into the kiln. The plate leaves behind into the plate bin.
	return {
		"id": 289,
		"name": "Ahead Ore",
		"blurb": "The first item arrives from ahead and leaves right into a kiln. The plate that arrives from ahead leaves behind into the plate bin.",
		"rule": "The first item is ore. It arrives from ahead and leaves right into the kiln. The plate that arrives from ahead leaves behind into the plate bin. Neither leaves forward. A bridle sends that ore left. A jointer sends the plate left. A wrest sends the ore left. A shin sends the plate forward. A point sends the plate left. A throat sends the ore into the plate bin. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 5,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 4, [rules.Mat.INGOT]),
			sink(1, 2, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(2, 1)],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.TRASHBOARD, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.TRASHBOARD, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 3, rules.Dir.SOUTH),
		],
	}


static func still_trashboard() -> Dictionary:
	var rules = Rules
	return {
		"id": 290,
		"name": "Still Trashboard",
		"blurb": "The tray has one belt, on the crossing. The trashboard faces south. The first item arrives from ahead and leaves right, and the later item leaves behind.",
		"rule": "The tray has one belt, on the crossing. The trashboard faces south and takes the pair from ahead. The ore leaves right into the kiln and the plate leaves behind into the plate bin. Neither leaves forward. The belt turns the ingot off that lane. A filter scraps a side stream. A bridle would send the ore left. A jointer would send the plate left. A wrest would send the ore left. A shin would send the plate forward. A point would send the plate left. A throat would send the ore into the plate bin. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt in the trashboard cell refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(2, 3, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(2, 1, [rules.Mat.PLATE]),
			sink(0, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(7, 2)],
		"walls": [cell(3, 2)],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.TRASHBOARD, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.TRASHBOARD, 2, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 1, 2, rules.Dir.WEST),
			piece(rules.Kind.BELT, 0, 2, rules.Dir.NORTH),
			piece(rules.Kind.FILTER, 6, 2, rules.Dir.NORTH),
		],
	}


static func seat_trashboard() -> Dictionary:
	var rules = Rules
	return {
		"id": 291,
		"name": "Seat",
		"blurb": "The trashboard starts off the lane. Seat it where the ore arrives from ahead and leaves right.",
		"rule": "The trashboard starts off the lane. Pick it up and seat it where the ore arrives from ahead and leaves right into the kiln, and the plate leaves behind into the plate bin. Leaving it parked misses. A bridle would send the ore left. A jointer would send the plate left. A wrest would send the ore left. A shin would send the plate forward. A point would send the plate left. A throat would send the ore into the plate bin. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt seated there refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 5,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 4, [rules.Mat.INGOT]),
			sink(1, 2, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(2, 1)],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.TRASHBOARD, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [
			piece(rules.Kind.TRASHBOARD, 5, 0, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.TRASHBOARD, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 3, rules.Dir.SOUTH),
		],
	}


static func split_corner_trashboard() -> Dictionary:
	var rules = Rules
	return {
		"id": 292,
		"name": "Split Corner",
		"blurb": "A wall closes the left lane a bridle would use. The waiter leaves right and the arrival leaves behind.",
		"rule": "A wall closes the left lane. Items arrive from ahead. The waiter leaves right into the kiln and the arrival leaves behind into the plate bin. Neither leaves forward. A bridle sends the ore into the wall. A jointer sends the plate into the wall. A wrest sends the ore into the wall. A shin sends the plate forward. A point sends the plate into the wall. A throat sends the ore into the plate bin. A beam sends the ore into the plate bin. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 5,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(2, 4, [rules.Mat.INGOT]),
			sink(1, 2, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(2, 1), cell(2, 0)],
		"budget": kv([
			rules.Kind.TRASHBOARD, 1,
			rules.Kind.KILN, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 59, rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.TRASHBOARD, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 2, 3, rules.Dir.SOUTH),
		],
	}


static func two_stocks_trashboard() -> Dictionary:
	var rules = Rules
	return {
		"id": 293,
		"name": "Two Stocks",
		"blurb": "Two trashboards, two materials. Both quotas are met only when each trashboard sends the waiter right and the arrival behind.",
		"rule": "Two trashboards, two materials. Each takes its pair from ahead. The right exit of each feeds a kiln with the ore waiter. The behind exit of each feeds the plate bin. Neither leaves forward. A bridle sends each ore left. A jointer sends each plate left. A wrest sends each ore left. A throat sends each ore into the plate bin. A shin sends each plate forward. A point sends each plate left. A beam sends each ore backward. A moldboard accepts only from behind. A frog sends each ore forward. A sole sends each ore forward. A hake sends each ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 5,
		"sources": [
			source(2, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(5, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(1, 4, [rules.Mat.INGOT]),
			sink(0, 2, [rules.Mat.PLATE]),
			sink(4, 4, [rules.Mat.INGOT]),
			sink(3, 2, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(1, 1), cell(4, 1)],
		"budget": kv([
			rules.Kind.KILN, 2,
			rules.Kind.TRASHBOARD, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 118, rules.Mat.PLATE, 120]),
		"initial": [],
		"solution": [
			piece(rules.Kind.TRASHBOARD, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 3, rules.Dir.SOUTH),
			piece(rules.Kind.TRASHBOARD, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 3, rules.Dir.SOUTH),
		],
	}


static func after_split_trashboard() -> Dictionary:
	var rules = Rules
	return {
		"id": 294,
		"name": "After the Split",
		"blurb": "A filter scraps one stream. The trashboard sends the ore right, away from the scrap, and the plate behind.",
		"rule": "A filter scraps the side ingots. The trashboard faces south and takes the pair from ahead. It sends the ore right, away from the scrap, into the kiln, and the plate behind into the bin. Neither leaves forward. A bridle would send the ore toward the scrap. A jointer would send the plate left. A wrest would send the ore toward the scrap. A shin would send the plate forward. A point would send the plate left. A throat would send the ore into the plate bin. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 4,
		"sources": [
			source(3, 3, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(3, 1, [rules.Mat.PLATE]),
			sink(1, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(7, 2)],
		"walls": [cell(4, 2)],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.TRASHBOARD, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.TRASHBOARD, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.WEST),
			piece(rules.Kind.BELT, 1, 2, rules.Dir.NORTH),
			piece(rules.Kind.FILTER, 6, 2, rules.Dir.NORTH),
		],
	}


static func split_bin_trashboard() -> Dictionary:
	var rules = Rules
	return {
		"id": 295,
		"name": "Split Bin",
		"blurb": "The right stream and the behind stream each reach a different quota. A landside, a moldboard, a coulter, a share, a fork, a prong, a slade, a heel, a stilt, a clevis, a beam, a hake, a sole, a frog, a shin, a point, a throat, a wrest, a jointer, and a bridle each miss at least one.",
		"rule": "The trashboard takes the pair from ahead. It sends the ore right into the kiln and the plate behind into its bin. Those ingots split between the ingot bin and the press. The lower plates are not enough alone. Neither leaves forward. A bridle sends the ore left. A jointer sends the plate left. A wrest sends the ore left. A throat sends the ore into the plate bin. A shin sends the plate forward. A point sends the plate left. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the ore forward. A sole sends the ore forward. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too. Pressing every ingot misses the ingot bin.",
		"w": 8,
		"h": 6,
		"sources": [
			source(5, 1, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(7, 5, rules.Dir.WEST, [rules.Mat.PLATE], 4),
		],
		"sinks": [
			sink(3, 1, [rules.Mat.PLATE]),
			sink(4, 5, [rules.Mat.INGOT]),
			sink(1, 3, [rules.Mat.PLATE]),
			sink(5, 5, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(4, 0)],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.TRASHBOARD, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 104]),
		"initial": [],
		"solution": [
			piece(rules.Kind.TRASHBOARD, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 2, rules.Dir.SOUTH),
			piece(rules.Kind.SPLITTER, 4, 3, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 4, 4, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.WEST),
			piece(rules.Kind.PRESS, 2, 3, rules.Dir.WEST),
			piece(rules.Kind.BELT, 6, 5, rules.Dir.WEST),
		],
	}


static func held_pair_trashboard() -> Dictionary:
	var rules = Rules
	return {
		"id": 296,
		"name": "Held Pair",
		"blurb": "The pair leaves on the arrival tick, waiter right and arrival behind, and the cell is empty afterward.",
		"rule": "The first item arrives from ahead and waits through a tick with nothing beside it, then the pair leaves on the arrival tick, the waiter right and the arrival behind, and the cell is empty afterward. Neither leaves forward. A belt refuses that arrival from ahead, so the first item never steps onto the next cell. A bridle would send the waiter left. A jointer would send the arrival left. A wrest would send the waiter left. A throat would send the waiter into the plate bin. A shin would send the arrival forward. A point would send the arrival left. A lone item never leaves. A piece that keeps either item misses. A moldboard accepts only from behind. A beam sends the waiter backward. A sole sends the waiter forward. A frog sends the waiter forward. A hake sends the waiter backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 5,
		"sources": [
			source(4, 1, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(2, 1, [rules.Mat.PLATE]),
			sink(3, 4, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [cell(3, 0)],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.TRASHBOARD, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.TRASHBOARD, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 3, 3, rules.Dir.SOUTH),
		],
	}


static func ahead_ore_gauge() -> Dictionary:
	var rules = Rules
	# Gauge faces east. Ore leaves forward, through the source, into the kiln. The plate leaves behind.
	return {
		"id": 297,
		"name": "Ahead Ore",
		"blurb": "The first item arrives from ahead and leaves forward into a kiln. The plate that arrives from ahead leaves behind into the plate bin.",
		"rule": "The first item is ore. It arrives from ahead and leaves forward into the kiln. The plate that arrives from ahead leaves behind into the plate bin. The source cell cannot hold the ore, so the ore steps through into the kiln. A trashboard sends that ore right. A bridle sends the ore left. A jointer sends the plate left. A wrest sends the ore left. A shin sends the plate forward. A point sends the plate left. A throat sends the ore into the plate bin and the plate forward. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the plate left. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(2, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(4, 2, [rules.Mat.INGOT]),
			sink(0, 2, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(1, 1), cell(1, 3)],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.GAUGE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.GAUGE, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.EAST),
		],
	}


static func still_gauge() -> Dictionary:
	var rules = Rules
	return {
		"id": 298,
		"name": "Still Gauge",
		"blurb": "The tray has one belt, on the crossing. The gauge faces south. The first item arrives from ahead and leaves forward, and the later item leaves behind.",
		"rule": "The tray has one belt, on the crossing. The gauge faces south and takes the pair from ahead. The ore leaves forward into the kiln and the plate leaves behind into the plate bin. The belt turns the ingot off that lane. A filter scraps a side stream. A trashboard would send the ore right. A bridle would send the ore left. A jointer would send the plate left. A wrest would send the ore left. A shin would send the plate forward. A point would send the plate left. A throat would send the ore into the plate bin. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the plate left. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt in the gauge cell refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 6,
		"sources": [
			source(2, 2, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(2, 0, [rules.Mat.PLATE]),
			sink(3, 4, [rules.Mat.INGOT]),
		],
		"chutes": [cell(7, 2)],
		"walls": [cell(1, 1)],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.GAUGE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.GAUGE, 2, 1, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 2, 3, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 2, 4, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 6, 2, rules.Dir.NORTH),
		],
	}


static func seat_gauge() -> Dictionary:
	var rules = Rules
	return {
		"id": 299,
		"name": "Seat",
		"blurb": "The gauge starts off the lane. Seat it where the ore arrives from ahead and leaves forward.",
		"rule": "The gauge starts off the lane. Pick it up and seat it where the ore arrives from ahead and leaves forward into the kiln, and the plate leaves behind into the plate bin. Leaving it parked misses. A trashboard would send the ore right. A bridle would send the ore left. A jointer would send the plate left. A wrest would send the ore left. A shin would send the plate forward. A point would send the plate left. A throat would send the ore into the plate bin. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the plate left. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt seated there refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(2, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(4, 2, [rules.Mat.INGOT]),
			sink(0, 2, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(1, 1), cell(1, 3)],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.GAUGE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [
			piece(rules.Kind.GAUGE, 5, 0, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.GAUGE, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.EAST),
		],
	}


static func split_corner_gauge() -> Dictionary:
	var rules = Rules
	return {
		"id": 300,
		"name": "Split Corner",
		"blurb": "A wall closes the right. The ore still leaves forward into the kiln, and the plate leaves behind.",
		"rule": "A wall closes the right. The first item arrives from ahead and leaves forward into the kiln. The plate that arrives from ahead leaves behind into the plate bin. A trashboard would send the ore into that wall. A bridle would send the ore left. A jointer would send the plate left. A wrest would send the ore left. A shin would send the plate forward. A point would send the plate left. A throat would send the ore into the plate bin. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the plate left. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(2, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(4, 2, [rules.Mat.INGOT]),
			sink(0, 2, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(1, 1), cell(1, 3)],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.GAUGE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 59, rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.GAUGE, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.EAST),
		],
	}


static func two_stocks_gauge() -> Dictionary:
	var rules = Rules
	return {
		"id": 301,
		"name": "Two Stocks",
		"blurb": "Two gauges take two stocks from ahead. Each ore leaves forward, and each plate leaves behind.",
		"rule": "Two gauges take two stocks from ahead. Each first item leaves forward into its kiln. Each plate leaves behind into its plate bin. A trashboard on either lane sends the ore right. A bridle sends the ore left. A jointer sends the plate left. A wrest sends the ore left. A shin sends the plate forward. A point sends the plate left. A throat sends the ore into the plate bin. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the plate left. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 5,
		"sources": [
			source(2, 1, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(2, 3, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(4, 1, [rules.Mat.INGOT]),
			sink(4, 3, [rules.Mat.INGOT]),
			sink(0, 1, [rules.Mat.PLATE]),
			sink(0, 3, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(1, 0), cell(1, 2), cell(1, 4)],
		"budget": kv([
			rules.Kind.KILN, 2,
			rules.Kind.GAUGE, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 118, rules.Mat.PLATE, 120]),
		"initial": [],
		"solution": [
			piece(rules.Kind.GAUGE, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.GAUGE, 1, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 3, rules.Dir.EAST),
		],
	}


static func after_split_gauge() -> Dictionary:
	var rules = Rules
	return {
		"id": 302,
		"name": "After the Split",
		"blurb": "The ore leaves forward, away from the scrap, and the plate leaves behind.",
		"rule": "The first item arrives from ahead and leaves forward into the kiln, away from the scrap. The plate that arrives from ahead leaves behind into the plate bin. A filter still throws its own stream away. A trashboard would send the ore right. A bridle would send the ore left. A jointer would send the plate left. A wrest would send the ore left. A shin would send the plate forward. A point would send the plate left. A throat would send the ore into the plate bin. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the plate left. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt in the gauge cell refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 6,
		"sources": [
			source(4, 2, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(1, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(4, 0, [rules.Mat.PLATE]),
			sink(5, 4, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 2)],
		"walls": [cell(3, 1)],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.GAUGE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.GAUGE, 4, 1, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 4, 3, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 4, 4, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 1, 2, rules.Dir.NORTH),
		],
	}


static func split_bin_gauge() -> Dictionary:
	var rules = Rules
	return {
		"id": 303,
		"name": "Split Bin",
		"blurb": "The ore leaves forward into the split, and the plate leaves behind. The lower stream is not enough on its own.",
		"rule": "The first item arrives from ahead and leaves forward into the kiln. The plate that arrives from ahead leaves behind into the plate bin. The kiln feeds a splitter, and the press plates join a lower stream that is not enough on its own. A trashboard would send the ore right. A bridle would send the ore left. A jointer would send the plate left. A wrest would send the ore left. A shin would send the plate forward. A point would send the plate left. A throat would send the ore into the plate bin. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the plate left. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt in the gauge cell refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 6,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(0, 5, rules.Dir.EAST, [rules.Mat.PLATE], 4),
		],
		"sinks": [
			sink(7, 2, [rules.Mat.INGOT]),
			sink(5, 5, [rules.Mat.PLATE]),
			sink(1, 2, [rules.Mat.PLATE]),
			sink(2, 5, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(2, 1), cell(2, 3)],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.GAUGE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 104]),
		"initial": [],
		"solution": [
			piece(rules.Kind.GAUGE, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 3, rules.Dir.SOUTH),
			piece(rules.Kind.PRESS, 5, 4, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 1, 5, rules.Dir.EAST),
		],
	}


static func held_pair_gauge() -> Dictionary:
	var rules = Rules
	return {
		"id": 304,
		"name": "Held Pair",
		"blurb": "The pair leaves on the arrival tick, waiter forward and arrival behind, and the cell is empty afterward.",
		"rule": "The first item arrives from ahead and waits through a tick with nothing beside it, then the pair leaves on the arrival tick, the waiter forward and the arrival behind, and the cell is empty afterward. A belt refuses that arrival from ahead, so the first item never steps onto the next cell. A trashboard would send the waiter right. A bridle would send the waiter left. A jointer would send the arrival left. A wrest would send the waiter left. A throat would send the waiter into the plate bin. A shin would send the arrival forward. A point would send the arrival left. A lone item never leaves. A piece that keeps either item misses. A moldboard accepts only from behind. A beam sends the waiter backward. A sole sends the waiter forward. A frog sends the waiter forward. A hake sends the waiter backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(2, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(0, 2, [rules.Mat.PLATE]),
			sink(5, 2, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [cell(1, 1), cell(1, 3)],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.GAUGE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.GAUGE, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 2, rules.Dir.EAST),
		],
	}


static func ahead_ore_breast() -> Dictionary:
	var rules = Rules
	# Breast faces east. Ore leaves behind into the kiln. The plate leaves forward, through the source, into the plate bin.
	return {
		"id": 305,
		"name": "Ahead Ore",
		"blurb": "The first item arrives from ahead and leaves behind into a kiln. The plate that arrives from ahead leaves forward into the plate bin.",
		"rule": "The first item is ore. It arrives from ahead and leaves behind into the kiln. The plate that arrives from ahead leaves forward into the plate bin. The source cell cannot hold the plate, so the plate steps through into the bin. A gauge sends that ore forward into the plate bin and the plate behind into the kiln. A trashboard sends the ore right. A bridle sends the ore left. A jointer sends the plate left. A wrest sends the ore left. A shin sends the plate forward without stepping through the source. A point sends the plate left. A throat sends the ore behind and the plate into the source. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the plate left. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(0, 2, [rules.Mat.INGOT]),
			sink(4, 2, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(2, 1), cell(2, 3)],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.BREAST, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BREAST, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 2, rules.Dir.WEST),
		],
	}


static func still_breast() -> Dictionary:
	var rules = Rules
	return {
		"id": 306,
		"name": "Still Breast",
		"blurb": "The tray has one belt, on the crossing. The breast faces south. The first item arrives from ahead and leaves behind, and the later item leaves forward.",
		"rule": "The tray has one belt, on the crossing. The breast faces south and takes the pair from ahead. The ore leaves behind into the kiln and the plate leaves forward into the plate bin. The belt turns the ingot off that lane. A filter scraps a side stream. A gauge would send the ore forward into the plate bin. A trashboard would send the ore right. A bridle would send the ore left. A jointer would send the plate left. A wrest would send the ore left. A shin would send the plate forward without stepping through the source. A point would send the plate left. A throat would send the plate into the source. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the plate left. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt in the breast cell refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 6,
		"sources": [
			source(2, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(2, 5, [rules.Mat.PLATE]),
			sink(3, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(7, 2)],
		"walls": [cell(1, 3)],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.BREAST, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BREAST, 2, 3, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 2, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 6, 2, rules.Dir.NORTH),
		],
	}


static func seat_breast() -> Dictionary:
	var rules = Rules
	return {
		"id": 307,
		"name": "Seat",
		"blurb": "The breast starts off the lane. Seat it where the ore arrives from ahead and leaves behind.",
		"rule": "The breast starts off the lane. Pick it up and seat it where the ore arrives from ahead and leaves behind into the kiln, and the plate leaves forward into the plate bin. Leaving it parked misses. A gauge would send the ore forward into the plate bin. A trashboard would send the ore right. A bridle would send the ore left. A jointer would send the plate left. A wrest would send the ore left. A shin would send the plate forward without stepping through the source. A point would send the plate left. A throat would send the plate into the source. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the plate left. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt seated there refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(0, 2, [rules.Mat.INGOT]),
			sink(4, 2, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(2, 1), cell(2, 3)],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.BREAST, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [
			piece(rules.Kind.BREAST, 5, 0, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.BREAST, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 2, rules.Dir.WEST),
		],
	}


static func split_corner_breast() -> Dictionary:
	var rules = Rules
	return {
		"id": 308,
		"name": "Split Corner",
		"blurb": "A wall closes the right. The ore still leaves behind into the kiln, and the plate leaves forward.",
		"rule": "A wall closes the right. The first item arrives from ahead and leaves behind into the kiln. The plate that arrives from ahead leaves forward into the plate bin. A gauge would send the ore forward into the plate bin. A trashboard would send the ore into that wall. A bridle would send the ore left. A jointer would send the plate left. A wrest would send the ore left. A shin would send the plate forward without stepping through the source. A point would send the plate left. A throat would send the plate into the source. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the plate left. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(0, 2, [rules.Mat.INGOT]),
			sink(4, 2, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(2, 1), cell(2, 3)],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.BREAST, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 59, rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BREAST, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 2, rules.Dir.WEST),
		],
	}


static func two_stocks_breast() -> Dictionary:
	var rules = Rules
	return {
		"id": 309,
		"name": "Two Stocks",
		"blurb": "Two breasts take two stocks from ahead. Each ore leaves behind, and each plate leaves forward.",
		"rule": "Two breasts take two stocks from ahead. Each first item leaves behind into its kiln. Each plate leaves forward into its plate bin. A gauge on either lane sends the ore forward. A trashboard sends the ore right. A bridle sends the ore left. A jointer sends the plate left. A wrest sends the ore left. A shin sends the plate forward without stepping through the source. A point sends the plate left. A throat sends the plate into the source. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the plate left. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 5,
		"sources": [
			source(3, 1, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(3, 3, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(0, 1, [rules.Mat.INGOT]),
			sink(0, 3, [rules.Mat.INGOT]),
			sink(4, 1, [rules.Mat.PLATE]),
			sink(4, 3, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(2, 0), cell(2, 2), cell(2, 4)],
		"budget": kv([
			rules.Kind.KILN, 2,
			rules.Kind.BREAST, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 118, rules.Mat.PLATE, 120]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BREAST, 2, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 1, rules.Dir.WEST),
			piece(rules.Kind.BREAST, 2, 3, rules.Dir.EAST),
			piece(rules.Kind.KILN, 1, 3, rules.Dir.WEST),
		],
	}


static func after_split_breast() -> Dictionary:
	var rules = Rules
	return {
		"id": 310,
		"name": "After the Split",
		"blurb": "The ore leaves behind, away from the scrap, and the plate leaves forward.",
		"rule": "The first item arrives from ahead and leaves behind into the kiln, away from the scrap. The plate that arrives from ahead leaves forward into the plate bin. A filter still throws its own stream away. A gauge would send the ore forward into the plate bin. A trashboard would send the ore right. A bridle would send the ore left. A jointer would send the plate left. A wrest would send the ore left. A shin would send the plate forward without stepping through the source. A point would send the plate left. A throat would send the plate into the source. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the plate left. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt in the breast cell refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 6,
		"sources": [
			source(4, 4, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(1, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(4, 5, [rules.Mat.PLATE]),
			sink(5, 1, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 2)],
		"walls": [cell(3, 3)],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.BREAST, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BREAST, 4, 3, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 4, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 4, 1, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 1, 2, rules.Dir.NORTH),
		],
	}


static func split_bin_breast() -> Dictionary:
	var rules = Rules
	return {
		"id": 311,
		"name": "Split Bin",
		"blurb": "The ore leaves behind into the split, and the plate leaves forward. The lower stream is not enough on its own.",
		"rule": "The first item arrives from ahead and leaves behind into the kiln. The plate that arrives from ahead leaves forward into the plate bin. The kiln feeds a splitter, and the press plates join a lower stream that is not enough on its own. A gauge would send the ore forward into the plate bin. A trashboard would send the ore right. A bridle would send the ore left. A jointer would send the plate left. A wrest would send the ore left. A shin would send the plate forward without stepping through the source. A point would send the plate left. A throat would send the plate into the source. A beam sends the ore backward. A moldboard accepts only from behind. A frog sends the plate left. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt in the breast cell refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 6,
		"sources": [
			source(6, 4, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(0, 5, rules.Dir.EAST, [rules.Mat.PLATE], 4),
		],
		"sinks": [
			sink(1, 4, [rules.Mat.INGOT]),
			sink(3, 1, [rules.Mat.PLATE]),
			sink(7, 4, [rules.Mat.PLATE]),
			sink(2, 5, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(5, 3), cell(5, 5)],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.BREAST, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 104]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BREAST, 5, 4, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 4, rules.Dir.WEST),
			piece(rules.Kind.SPLITTER, 3, 4, rules.Dir.WEST),
			piece(rules.Kind.BELT, 2, 4, rules.Dir.WEST),
			piece(rules.Kind.BELT, 3, 3, rules.Dir.NORTH),
			piece(rules.Kind.PRESS, 3, 2, rules.Dir.NORTH),
			piece(rules.Kind.BELT, 1, 5, rules.Dir.EAST),
		],
	}


static func held_pair_breast() -> Dictionary:
	var rules = Rules
	return {
		"id": 312,
		"name": "Held Pair",
		"blurb": "The pair leaves on the arrival tick, waiter behind and arrival forward, and the cell is empty afterward.",
		"rule": "The first item arrives from ahead and waits through a tick with nothing beside it, then the pair leaves on the arrival tick, the waiter behind and the arrival forward, and the cell is empty afterward. A belt refuses that arrival from ahead, so the first item never steps onto the next cell. A gauge would send the waiter forward. A trashboard would send the waiter right. A bridle would send the waiter left. A jointer would send the arrival left. A wrest would send the waiter left. A throat would send the arrival into the source. A shin would send the arrival forward without stepping through the source. A point would send the arrival left. A lone item never leaves. A piece that keeps either item misses. A moldboard accepts only from behind. A beam sends the waiter backward. A sole sends the waiter forward. A frog sends the waiter forward. A hake sends the waiter backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(4, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(5, 2, [rules.Mat.PLATE]),
			sink(0, 2, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [cell(3, 1), cell(3, 3)],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.BREAST, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.BREAST, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 2, 2, rules.Dir.WEST),
			piece(rules.Kind.KILN, 1, 2, rules.Dir.WEST),
		],
	}


static func ahead_ore_hardie() -> Dictionary:
	var rules = Rules
	# Hardie faces east. Ore leaves forward, through the source, into the kiln. The plate leaves left.
	return {
		"id": 313,
		"name": "Ahead Ore",
		"blurb": "The first item arrives from ahead and leaves forward into a kiln. The plate that arrives from ahead leaves left into the plate bin.",
		"rule": "The first item is ore. It arrives from ahead and leaves forward into the kiln. The plate that arrives from ahead leaves left into the plate bin. The source cell cannot hold the ore, so the ore steps through into the kiln. A breast sends that ore behind. A gauge sends the plate behind. A frog sends the ore forward without stepping through the source. A trashboard sends the ore right. A bridle sends the ore left. A jointer sends the plate left. A wrest sends the ore left. A shin sends the plate forward. A point sends the plate left. A throat sends the ore behind. A beam sends the ore backward. A moldboard accepts only from behind. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(2, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(4, 2, [rules.Mat.INGOT]),
			sink(1, 1, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(0, 2), cell(1, 3)],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.HARDIE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HARDIE, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.EAST),
		],
	}


static func still_hardie() -> Dictionary:
	var rules = Rules
	return {
		"id": 314,
		"name": "Still Hardie",
		"blurb": "The tray has one belt, on the crossing. The hardie faces south. The first item arrives from ahead and leaves forward, and the later item leaves left.",
		"rule": "The tray has one belt, on the crossing. The hardie faces south and takes the pair from ahead. The ore leaves forward into the kiln and the plate leaves left into the plate bin. The belt turns the ingot off that lane. A filter scraps a side stream. A breast would send the ore behind. A gauge would send the plate behind. A frog would send the ore forward without stepping through the source. A trashboard would send the ore right. A bridle would send the ore left. A jointer would send the plate left. A wrest would send the ore left. A shin would send the plate forward. A point would send the plate left. A throat would send the ore behind. A beam sends the ore backward. A moldboard accepts only from behind. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt in the hardie cell refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 6,
		"sources": [
			source(2, 2, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(6, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(3, 1, [rules.Mat.PLATE]),
			sink(3, 4, [rules.Mat.INGOT]),
		],
		"chutes": [cell(7, 2)],
		"walls": [cell(2, 0), cell(1, 1)],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.HARDIE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HARDIE, 2, 1, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 2, 3, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 2, 4, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 6, 2, rules.Dir.NORTH),
		],
	}


static func seat_hardie() -> Dictionary:
	var rules = Rules
	return {
		"id": 315,
		"name": "Seat",
		"blurb": "The hardie starts off the lane. Seat it where the ore arrives from ahead and leaves forward.",
		"rule": "The hardie starts off the lane. Pick it up and seat it where the ore arrives from ahead and leaves forward into the kiln, and the plate leaves left into the plate bin. Leaving it parked misses. A breast would send the ore behind. A gauge would send the plate behind. A frog would send the ore forward without stepping through the source. A trashboard would send the ore right. A bridle would send the ore left. A jointer would send the plate left. A wrest would send the ore left. A shin would send the plate forward. A point would send the plate left. A throat would send the ore behind. A beam sends the ore backward. A moldboard accepts only from behind. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt seated there refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(2, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(4, 2, [rules.Mat.INGOT]),
			sink(1, 1, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(0, 2), cell(1, 3)],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.HARDIE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [
			piece(rules.Kind.HARDIE, 5, 0, rules.Dir.EAST),
		],
		"solution": [
			piece(rules.Kind.HARDIE, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.EAST),
		],
	}


static func split_corner_hardie() -> Dictionary:
	var rules = Rules
	return {
		"id": 316,
		"name": "Split Corner",
		"blurb": "A wall closes the right. The ore still leaves forward into the kiln, and the plate leaves left.",
		"rule": "A wall closes the right. The first item arrives from ahead and leaves forward into the kiln. The plate that arrives from ahead leaves left into the plate bin. A breast would send the ore behind. A gauge would send the plate behind. A frog would send the ore forward without stepping through the source. A trashboard would send the ore into that wall. A bridle would send the ore left. A jointer would send the plate left. A wrest would send the ore left. A shin would send the plate forward. A point would send the plate left. A throat would send the ore behind. A beam sends the ore backward. A moldboard accepts only from behind. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(2, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(4, 2, [rules.Mat.INGOT]),
			sink(1, 1, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(0, 2), cell(1, 3)],
		"budget": kv([
			rules.Kind.KILN, 1,
			rules.Kind.HARDIE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 59, rules.Mat.PLATE, 60]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HARDIE, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 2, rules.Dir.EAST),
		],
	}


static func two_stocks_hardie() -> Dictionary:
	var rules = Rules
	return {
		"id": 317,
		"name": "Two Stocks",
		"blurb": "Two hardies take two stocks from ahead. Each ore leaves forward, and each plate leaves left.",
		"rule": "Two hardies take two stocks from ahead. Each first item leaves forward into its kiln. Each plate leaves left into its plate bin. A breast on either lane sends the ore behind. A gauge sends the plate behind. A frog sends the ore forward without stepping through the source. A trashboard sends the ore right. A bridle sends the ore left. A jointer sends the plate left. A wrest sends the ore left. A shin sends the plate forward. A point sends the plate left. A throat sends the ore behind. A beam sends the ore backward. A moldboard accepts only from behind. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt refuses an arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 6,
		"sources": [
			source(2, 1, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(2, 4, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
		],
		"sinks": [
			sink(4, 1, [rules.Mat.INGOT]),
			sink(4, 4, [rules.Mat.INGOT]),
			sink(1, 0, [rules.Mat.PLATE]),
			sink(1, 3, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(0, 1), cell(1, 2), cell(0, 4), cell(1, 5)],
		"budget": kv([
			rules.Kind.KILN, 2,
			rules.Kind.HARDIE, 2,
		]),
		"quota": kv([rules.Mat.INGOT, 118, rules.Mat.PLATE, 120]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HARDIE, 1, 1, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 1, rules.Dir.EAST),
			piece(rules.Kind.HARDIE, 1, 4, rules.Dir.EAST),
			piece(rules.Kind.KILN, 3, 4, rules.Dir.EAST),
		],
	}


static func after_split_hardie() -> Dictionary:
	var rules = Rules
	return {
		"id": 318,
		"name": "After the Split",
		"blurb": "The ore leaves forward, away from the scrap, and the plate leaves left.",
		"rule": "The first item arrives from ahead and leaves forward into the kiln, away from the scrap. The plate that arrives from ahead leaves left into the plate bin. A filter still throws its own stream away. A breast would send the ore behind. A gauge would send the plate behind. A frog would send the ore forward without stepping through the source. A trashboard would send the ore right. A bridle would send the ore left. A jointer would send the plate left. A wrest would send the ore left. A shin would send the plate forward. A point would send the plate left. A throat would send the ore behind. A beam sends the ore backward. A moldboard accepts only from behind. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt in the hardie cell refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 6,
		"sources": [
			source(4, 2, rules.Dir.NORTH, [rules.Mat.ORE, rules.Mat.PLATE], 2),
			source(1, 3, rules.Dir.NORTH, [rules.Mat.INGOT], 4),
		],
		"sinks": [
			sink(5, 1, [rules.Mat.PLATE]),
			sink(5, 4, [rules.Mat.INGOT]),
		],
		"chutes": [cell(2, 2)],
		"walls": [cell(4, 0), cell(3, 1)],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.HARDIE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.FILTER, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HARDIE, 4, 1, rules.Dir.SOUTH),
			piece(rules.Kind.KILN, 4, 3, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 4, 4, rules.Dir.EAST),
			piece(rules.Kind.FILTER, 1, 2, rules.Dir.NORTH),
		],
	}


static func split_bin_hardie() -> Dictionary:
	var rules = Rules
	return {
		"id": 319,
		"name": "Split Bin",
		"blurb": "The ore leaves forward into the split, and the plate leaves left. The lower stream is not enough on its own.",
		"rule": "The first item arrives from ahead and leaves forward into the kiln. The plate that arrives from ahead leaves left into the plate bin. The kiln feeds a splitter, and the press plates join a lower stream that is not enough on its own. A breast would send the ore behind. A gauge would send the plate behind. A frog would send the ore forward without stepping through the source. A trashboard would send the ore right. A bridle would send the ore left. A jointer would send the plate left. A wrest would send the ore left. A shin would send the plate forward. A point would send the plate left. A throat would send the ore behind. A beam sends the ore backward. A moldboard accepts only from behind. A sole sends the plate right. A hake sends the ore backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A belt in the hardie cell refuses the arrival from ahead. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 8,
		"h": 6,
		"sources": [
			source(3, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 1),
			source(0, 5, rules.Dir.EAST, [rules.Mat.PLATE], 4),
		],
		"sinks": [
			sink(7, 2, [rules.Mat.INGOT]),
			sink(5, 5, [rules.Mat.PLATE]),
			sink(2, 1, [rules.Mat.PLATE]),
			sink(2, 5, [rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [cell(1, 2), cell(2, 3)],
		"budget": kv([
			rules.Kind.BELT, 3,
			rules.Kind.HARDIE, 1,
			rules.Kind.KILN, 1,
			rules.Kind.SPLITTER, 1,
			rules.Kind.PRESS, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 104]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HARDIE, 2, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 2, rules.Dir.EAST),
			piece(rules.Kind.SPLITTER, 5, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 6, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 5, 3, rules.Dir.SOUTH),
			piece(rules.Kind.PRESS, 5, 4, rules.Dir.SOUTH),
			piece(rules.Kind.BELT, 1, 5, rules.Dir.EAST),
		],
	}


static func held_pair_hardie() -> Dictionary:
	var rules = Rules
	return {
		"id": 320,
		"name": "Held Pair",
		"blurb": "The pair leaves on the arrival tick, waiter forward and arrival left, and the cell is empty afterward.",
		"rule": "The first item arrives from ahead and waits through a tick with nothing beside it, then the pair leaves on the arrival tick, the waiter forward and the arrival left, and the cell is empty afterward. A belt refuses that arrival from ahead, so the first item never steps onto the next cell. A breast would send the waiter behind. A gauge would send the arrival behind. A frog would send the waiter forward without stepping through the source. A trashboard would send the waiter right. A bridle would send the waiter left. A jointer would send the arrival left. A wrest would send the waiter left. A throat would send the waiter behind. A shin would send the arrival forward. A point would send the arrival left. A lone item never leaves. A piece that keeps either item misses. A moldboard accepts only from behind. A beam sends the waiter backward. A sole sends the waiter forward. A hake sends the waiter backward. A coulter, a landside, a share, a fork, a prong, a slade, and a heel accept only from behind. A stilt accepts only from the left. A clevis accepts only from the right. A dwell, a twin, a pass, a slip, a shed, a hook, a rake, a hoe, and a harrow miss too.",
		"w": 6,
		"h": 4,
		"sources": [
			source(2, 2, rules.Dir.WEST, [rules.Mat.ORE, rules.Mat.PLATE], 2),
		],
		"sinks": [
			sink(1, 1, [rules.Mat.PLATE]),
			sink(5, 2, [rules.Mat.INGOT]),
		],
		"chutes": [],
		"walls": [cell(0, 2), cell(1, 3)],
		"budget": kv([
			rules.Kind.BELT, 1,
			rules.Kind.KILN, 1,
			rules.Kind.HARDIE, 1,
		]),
		"quota": kv([rules.Mat.INGOT, 29, rules.Mat.PLATE, 30]),
		"initial": [],
		"solution": [
			piece(rules.Kind.HARDIE, 1, 2, rules.Dir.EAST),
			piece(rules.Kind.BELT, 3, 2, rules.Dir.EAST),
			piece(rules.Kind.KILN, 4, 2, rules.Dir.EAST),
		],
	}
