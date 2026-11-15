extends SceneTree

## Headless suite. Fails the process when any check fails.
## godot --headless --path kiln-route --script res://tests/run_tests.gd

const Rules = preload("res://scripts/foundry.gd")
const World = preload("res://scripts/world.gd")
const Rooms = preload("res://scripts/rooms.gd")
const Planner = preload("res://scripts/planner.gd")

var passed := 0
var failed := 0
var _finished := false


func _initialize() -> void:
	_finish()


func _process(_delta: float) -> bool:
	_finish()
	return false


func _finish() -> void:
	if _finished:
		return
	_finished = true
	_run()
	print("passed=%d failed=%d" % [passed, failed])
	quit(0 if failed == 0 else 1)


func _run() -> void:
	var version: Dictionary = Engine.get_version_info()
	print("Kiln Route tests")
	print("godot %s" % version.get("string", str(version)))
	_test_constants()
	_test_belt_steps()
	_test_belt_waits_when_blocked()
	_test_kiln_delay()
	_test_press()
	_test_filter_rule()
	_test_splitter_alternates()
	_test_splitter_waits_without_flipping()
	_test_roller_passes_every_material()
	_test_roller_refuses_side()
	_test_weir_prefers_forward()
	_test_weir_spills_when_forward_is_blocked()
	_test_weir_tries_forward_again()
	_test_rooms()
	_test_over_budget()
	_test_pickup()
	_test_room7_tempting()
	_test_order_does_not_matter()
	_test_flood_is_deterministic()
	_test_room5_needs_both_kilns()
	_test_room8_both_products()
	_test_wing2_lessons()
	_test_game_object()


func check(cond: bool, message: String) -> void:
	if cond:
		passed += 1
		print("PASS ", message)
	else:
		failed += 1
		print("FAIL ", message)


func _test_constants() -> void:
	check(Rules.SIM_TICKS == 120, "simulated minute is 120 ticks")
	check(Rules.KILN_DELAY == 2, "kiln delay is 2 ticks")
	check(Rules.PRESS_DELAY == 1, "press delay is 1 tick")
	check(Rules.SEED == 0, "simulator seed is fixed at 0")


func _test_belt_steps() -> void:
	var result := _run_line(3, 6, Rules.Mat.ORE, 1, [])
	check(result.trace.size() >= 2, "belt line produced two deliveries")
	if result.trace.size() >= 2:
		check(result.trace[0] == "4:4,0:0", "first ore arrives on tick 4 after 3 belts, got %s" % str(result.trace[0]))
		check(result.trace[1] == "5:4,0:0", "second ore arrives one tick later, got %s" % str(result.trace[1]))
	else:
		check(false, "missing belt trace")
		check(false, "missing second belt delivery")


func _test_belt_waits_when_blocked() -> void:
	var walls := [Rooms.cell(2, 0)]
	var result := _run_line(1, 6, Rules.Mat.ORE, 1, walls)
	var machine = result.world.machines[Vector2i(1, 0)]
	check(machine.hold == Rules.Mat.ORE, "blocked belt keeps the ore")
	check(int(result.counts[Rules.Mat.ORE]) == 0, "blocked belt does not deliver")


func _test_kiln_delay() -> void:
	var room := _machine_room(Rules.Kind.KILN, [Rules.Mat.ORE], 1, [Rules.Mat.INGOT])
	var placed := [Rooms.piece(Rules.Kind.KILN, 1, 0, Rules.Dir.EAST)]
	var early := World.simulate(room, placed, 2)
	var done := World.simulate(room, placed, 3)
	check(int(early.counts[Rules.Mat.INGOT]) == 0, "kiln has no ingot before the delay, got %s" % early.text)
	check(int(done.counts[Rules.Mat.INGOT]) == 1, "ore that enters on tick 1 leaves as an ingot on tick 3")
	check(int(done.counts[Rules.Mat.ORE]) == 0, "kiln does not pass ore through")
	check(done.trace[0] == "3:2,0:1", "first ingot trace is tick 3, got %s" % str(done.trace))


func _test_press() -> void:
	var room := _machine_room(Rules.Kind.PRESS, [Rules.Mat.INGOT], 1, [Rules.Mat.PLATE])
	var placed := [Rooms.piece(Rules.Kind.PRESS, 1, 0, Rules.Dir.EAST)]
	var two := World.simulate(room, placed, 2)
	var three := World.simulate(room, placed, 3)
	check(int(two.counts[Rules.Mat.PLATE]) == 0, "press has no plate before the second ingot finishes")
	check(int(three.counts[Rules.Mat.PLATE]) == 1, "second ingot on tick 2 yields a plate on tick 3")
	var once := _machine_room(Rules.Kind.PRESS, [Rules.Mat.INGOT], 100, [Rules.Mat.PLATE])
	var single := World.simulate(once, placed, 8)
	var press = single.world.machines[Vector2i(1, 0)]
	check(int(single.counts[Rules.Mat.PLATE]) == 0 and press.buffer == 1, "one ingot stays buffered")
	var ore_room := _machine_room(Rules.Kind.PRESS, [Rules.Mat.ORE], 1, [Rules.Mat.PLATE])
	var refused := World.simulate(ore_room, placed, 6)
	var stuck = refused.world.sources[0]
	check(int(refused.counts[Rules.Mat.PLATE]) == 0 and stuck.pending == Rules.Mat.ORE, "press refuses ore and the source holds it")


func _test_filter_rule() -> void:
	var room := _fork_room([Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE], Rules.Kind.FILTER)
	var placed := [Rooms.piece(Rules.Kind.FILTER, 1, 0, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 7)
	var expected := "2:2,0:0|3:1,1:1|4:1,1:2|5:2,0:0|6:1,1:1|7:1,1:2"
	check(_trace(result) == expected, "filter sends ore forward and metals right, got %s" % _trace(result))


func _test_splitter_alternates() -> void:
	var room := _fork_room([Rules.Mat.ORE], Rules.Kind.SPLITTER)
	var placed := [Rooms.piece(Rules.Kind.SPLITTER, 1, 0, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 5)
	var expected := "2:2,0:0|3:1,1:0|4:2,0:0|5:1,1:0"
	check(_trace(result) == expected, "splitter alternates forward then right, got %s" % _trace(result))


func _test_splitter_waits_without_flipping() -> void:
	var room := _fork_room([Rules.Mat.ORE], Rules.Kind.SPLITTER)
	room.walls = [Rooms.cell(2, 0)]
	room.w = 3
	var placed := [Rooms.piece(Rules.Kind.SPLITTER, 1, 0, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 8)
	var splitter = result.world.machines[Vector2i(1, 0)]
	check(result.trace.is_empty(), "blocked splitter does not spill to the other exit")
	check(splitter.phase == 0, "blocked splitter does not advance its turn")
	check(splitter.hold == Rules.Mat.ORE, "blocked splitter keeps the item")


func _test_roller_passes_every_material() -> void:
	var room := _machine_room(Rules.Kind.ROLLER, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE], 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])
	var placed := [Rooms.piece(Rules.Kind.ROLLER, 1, 0, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 6)
	var expected := "2:2,0:0|3:2,0:1|4:2,0:2|5:2,0:0|6:2,0:1"
	check(_trace(result) == expected, "roller sends every material forward, got %s" % _trace(result))


func _test_roller_refuses_side() -> void:
	var room := {
		"id": 0,
		"name": "roller side",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 2,
		"sources": [
			Rooms.source(0, 1, Rules.Dir.EAST, [Rules.Mat.ORE], 1),
			Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.PLATE], 1),
		],
		"sinks": [Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.ROLLER, 1, Rules.Kind.BELT, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var roller := World.simulate(room, [Rooms.piece(Rules.Kind.ROLLER, 1, 1, Rules.Dir.EAST)], 5)
	var expected := "2:2,1:0|3:2,1:0|4:2,1:0|5:2,1:0"
	check(_trace(roller) == expected, "roller ignores the side plate and passes ore, got %s" % _trace(roller))
	check(int(roller.counts[Rules.Mat.PLATE]) == 0, "roller delivers no plate")
	check(int(roller.world.sources[1].pending) == Rules.Mat.PLATE, "refused plate stays on the side source")
	var side_only := room.duplicate()
	side_only.sources = [Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.PLATE], 1)]
	var belt := World.simulate(side_only, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST)], 4)
	var roller_side := World.simulate(side_only, [Rooms.piece(Rules.Kind.ROLLER, 1, 1, Rules.Dir.EAST)], 4)
	check(_trace(belt) == "2:2,1:2|3:2,1:2|4:2,1:2", "a belt takes a plate from the side, got %s" % _trace(belt))
	check(int(roller_side.counts[Rules.Mat.PLATE]) == 0 and int(roller_side.world.sources[0].pending) == Rules.Mat.PLATE, "a roller refuses that same side plate")


func _test_weir_prefers_forward() -> void:
	var room := _fork_room([Rules.Mat.ORE], Rules.Kind.WEIR)
	var placed := [Rooms.piece(Rules.Kind.WEIR, 1, 0, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 5)
	var expected := "2:2,0:0|3:2,0:0|4:2,0:0|5:2,0:0"
	check(_trace(result) == expected, "open weir sends every item forward, got %s" % _trace(result))
	check(int(result.world.machines[Vector2i(1, 0)].phase) == 0, "weir does not keep a splitter phase")


func _test_weir_spills_when_forward_is_blocked() -> void:
	var room := _fork_room([Rules.Mat.ORE], Rules.Kind.WEIR)
	room.walls = [Rooms.cell(2, 0)]
	room.w = 3
	var placed := [Rooms.piece(Rules.Kind.WEIR, 1, 0, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 5)
	var expected := "2:1,1:0|3:1,1:0|4:1,1:0|5:1,1:0"
	check(_trace(result) == expected, "blocked weir spills to the right, got %s" % _trace(result))
	check(int(result.world.machines[Vector2i(1, 0)].phase) == 0, "a spill does not stick the weir on the side")


func _test_weir_tries_forward_again() -> void:
	var room := {
		"id": 0,
		"name": "weir kiln",
		"blurb": "",
		"rule": "",
		"w": 4,
		"h": 2,
		"sources": [Rooms.source(0, 0, Rules.Dir.EAST, [Rules.Mat.ORE], 1)],
		"sinks": [
			Rooms.sink(3, 0, [Rules.Mat.INGOT]),
			Rooms.sink(1, 1, [Rules.Mat.ORE]),
		],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.WEIR, 1, Rules.Kind.KILN, 1]),
		"quota": Rooms.kv([Rules.Mat.INGOT, 1]),
		"initial": [],
		"solution": [],
	}
	var placed := [
		Rooms.piece(Rules.Kind.WEIR, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 2, 0, Rules.Dir.EAST),
	]
	var result := World.simulate(room, placed, 40)
	var ingots := int(result.counts[Rules.Mat.INGOT])
	var spilled := int(result.counts[Rules.Mat.ORE])
	check(ingots >= 10, "weir keeps feeding the kiln after spills (%d ingots)" % ingots)
	check(spilled >= 10, "weir keeps spilling ore the kiln cannot take (%d ore)" % spilled)
	check(int(result.world.machines[Vector2i(1, 0)].phase) == 0, "kiln-fed weir still has no phase")


func _test_rooms() -> void:
	var catalog := Rooms.all()
	check(catalog.size() == 16, "two wings have 16 rooms")
	check(catalog[0].name == "Haul" and catalog[7].name == "Two Orders", "rooms 1 through 8 stay the first wing")
	check(catalog[8].name == "Straight" and catalog[15].name == "Balance", "rooms 9 through 16 are the second wing")
	check(not ("\n" in str(catalog[0].blurb)), "room 1 instruction is one line")
	for index in catalog.size():
		var room: Dictionary = catalog[index]
		check(not ("\n" in str(room.blurb)), "room %d instruction is one line" % int(room.id))
		check(int(room.id) == index + 1, "room id %d" % (index + 1))
		var initial: Dictionary = World.simulate(room, room.initial)
		check(
			not initial.quota_ok and initial.error == "",
			"room %d %s initial misses quota (%s)" % [room.id, room.name, initial.text]
		)
		var solved: Dictionary = World.simulate(room, room.solution)
		var solved_ok: bool = solved.success and solved.error == "" and int(solved.ticks) == Rules.SIM_TICKS and int(solved.seed) == Rules.SEED
		check(
			solved_ok,
			"room %d %s solution clears inside the minute and the budget (%s) err=%s" % [room.id, room.name, solved.text, solved.error]
		)
		check(
			World.budget_exact(room.solution, room.budget),
			"room %d solution uses the tray exactly" % room.id
		)
		check(World.budget_met(room.initial, room.budget), "room %d initial pieces fit the tray" % room.id)
		if not solved_ok:
			print(solved.world.debug_state())


func _test_over_budget() -> void:
	var room: Dictionary = Rooms.all()[0]
	var base: Dictionary = World.simulate(room, room.solution)
	var extra: Array = room.solution.duplicate(true)
	extra.append(Rooms.piece(Rules.Kind.BELT, 0, 0, Rules.Dir.EAST))
	var over: Dictionary = World.simulate(room, extra)
	check(base.success, "budget baseline clears")
	check(over.quota_ok, "extra belt still meets the ore quota (%s)" % over.text)
	check(not over.budget_ok, "extra belt exceeds the belt budget")
	check(not over.success, "quota without the budget is rejected")
	check(base.sig == over.sig, "inert extra belt does not change deliveries (%s vs %s)" % [base.sig, over.sig])
	var planner = Planner.new(room)
	for piece in room.solution:
		check(planner.place(int(piece.kind), int(piece.x), int(piece.y), int(piece.dir)), "placing a budgeted belt")
	check(not planner.place(Rules.Kind.BELT, 0, 0, Rules.Dir.EAST), "planner refuses a belt past the tray")
	check(planner.remaining(Rules.Kind.BELT) == 0, "tray is empty after the budget is spent")


func _test_pickup() -> void:
	var room: Dictionary = Rooms.all()[0]
	var planner = Planner.new(room)
	var before := planner.remaining(Rules.Kind.BELT)
	check(planner.place(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST), "place a belt from the tray")
	check(planner.remaining(Rules.Kind.BELT) == before - 1, "placing spends one belt")
	check(planner.pickup(1, 1), "pickup returns the belt")
	check(planner.remaining(Rules.Kind.BELT) == before, "tray count is restored")
	check(planner.at(1, 1) == null, "picked-up cell is empty")
	var relight: Dictionary = Rooms.all()[6]
	var started = Planner.new(relight)
	check(started.at(2, 0) != null and started.remaining(Rules.Kind.KILN) == 0, "relight starts with the kiln off the tray")
	check(started.pickup(2, 0), "pickup lifts the pre-placed kiln")
	check(started.at(2, 0) == null and started.remaining(Rules.Kind.KILN) == 1, "pre-placed kiln returns to the tray")
	var miscast: Dictionary = Rooms.all()[13]
	var parked = Planner.new(miscast)
	check(parked.at(1, 0) != null and parked.remaining(Rules.Kind.ROLLER) == 0, "miscast starts with the roller off the tray")
	check(parked.pickup(1, 0), "pickup lifts the pre-placed roller")
	check(parked.at(1, 0) == null and parked.remaining(Rules.Kind.ROLLER) == 1, "pre-placed roller returns to the tray")
	check(parked.place(Rules.Kind.ROLLER, 3, 1, Rules.Dir.EAST), "the returned roller can be seated on the crossing")


func _test_room7_tempting() -> void:
	var room: Dictionary = Rooms.all()[6]
	var tempting: Array = room.initial.duplicate(true)
	tempting.append(Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST))
	tempting.append(Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST))
	var missed: Dictionary = World.simulate(room, tempting)
	check(World.budget_met(tempting, room.budget), "tempting relight layout stays inside the tray")
	check(not missed.quota_ok, "tempting relight layout misses the quota (%s)" % missed.text)
	var solved: Dictionary = World.simulate(room, room.solution)
	check(solved.success, "lifting the kiln onto the route clears relight (%s)" % solved.text)


func _test_order_does_not_matter() -> void:
	for room in Rooms.all():
		var forward: Dictionary = World.simulate(room, room.solution)
		var backward: Array = room.solution.duplicate(true)
		backward.reverse()
		var reverse: Dictionary = World.simulate(room, backward)
		check(
			forward.sig == reverse.sig and _trace(forward) == _trace(reverse) and int(forward.seed) == int(reverse.seed),
			"room %d placement order does not change seed %d output" % [room.id, forward.seed]
		)


func _test_flood_is_deterministic() -> void:
	var belt_a := _flood_belt([Rules.Mat.ORE], 2, [Rules.Mat.INGOT], 1)
	var belt_a2 := _flood_belt([Rules.Mat.ORE], 2, [Rules.Mat.INGOT], 1)
	var belt_b := _flood_belt([Rules.Mat.PLATE], 2, [Rules.Mat.ORE], 1)
	var belt_b2 := _flood_belt([Rules.Mat.PLATE], 2, [Rules.Mat.ORE], 1)
	check(_same(belt_a, belt_a2), "flooding a belt from two inputs is deterministic (seed %d)" % belt_a.seed)
	check(_same(belt_b, belt_b2), "a different flood of the same belt is deterministic")
	check(not _same(belt_a, belt_b), "different floods do not collapse to the same output")
	var split_a := _flood_splitter([Rules.Mat.ORE, Rules.Mat.ORE, Rules.Mat.INGOT])
	var split_a2 := _flood_splitter([Rules.Mat.ORE, Rules.Mat.ORE, Rules.Mat.INGOT])
	var split_b := _flood_splitter([Rules.Mat.PLATE, Rules.Mat.INGOT])
	var split_b2 := _flood_splitter([Rules.Mat.PLATE, Rules.Mat.INGOT])
	check(_same(split_a, split_a2), "flooding a splitter is deterministic")
	check(_same(split_b, split_b2), "flooding a splitter with another pattern is deterministic")
	check(not _same(split_a, split_b), "splitter floods with different inputs differ")
	var kiln_fast := _flood_kiln(1)
	var kiln_fast2 := _flood_kiln(1)
	var kiln_slow := _flood_kiln(4)
	var kiln_slow2 := _flood_kiln(4)
	check(_same(kiln_fast, kiln_fast2), "flooding a kiln every tick is deterministic")
	check(_same(kiln_slow, kiln_slow2), "a slower kiln flood is deterministic")
	check(not _same(kiln_fast, kiln_slow), "kiln flood rate changes the output without becoming random")


func _test_room5_needs_both_kilns() -> void:
	var room: Dictionary = Rooms.all()[4]
	var solved: Dictionary = World.simulate(room, room.solution)
	var single_room := {
		"id": 0,
		"name": "one kiln",
		"blurb": "",
		"rule": "",
		"w": 5,
		"h": 1,
		"sources": [Rooms.source(0, 0, Rules.Dir.EAST, [Rules.Mat.ORE], 1)],
		"sinks": [Rooms.sink(4, 0, [Rules.Mat.INGOT])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.BELT, 2, Rules.Kind.KILN, 1]),
		"quota": Rooms.kv([Rules.Mat.INGOT, 1]),
		"initial": [],
		"solution": [],
	}
	var single: Dictionary = World.simulate(single_room, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 0, Rules.Dir.EAST),
	])
	var quota := int(room.quota[Rules.Mat.INGOT])
	var both := int(solved.counts[Rules.Mat.INGOT])
	var one := int(single.counts[Rules.Mat.INGOT])
	check(both > one, "two kilns outproduce one (%d > %d)" % [both, one])
	check(quota > one, "divide quota %d is above one kiln's %d" % [quota, one])
	check(both >= quota, "divide solution reaches %d/%d" % [both, quota])


func _test_room8_both_products() -> void:
	var room: Dictionary = Rooms.all()[7]
	var solved: Dictionary = World.simulate(room, room.solution)
	check(int(solved.counts[Rules.Mat.ORE]) == 0, "two orders does not count ore")
	check(solved.discarded == 0, "two orders does not discard")
	var ingots_only: Dictionary = World.simulate(room, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 1, Rules.Dir.EAST),
	])
	check(int(ingots_only.counts[Rules.Mat.PLATE]) == 0 and int(ingots_only.counts[Rules.Mat.INGOT]) > 0, "skipping the press yields ingots only (%s)" % ingots_only.text)
	check(not ingots_only.success, "ingots alone miss two orders")
	var plates_only: Dictionary = World.simulate(room, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.PRESS, 4, 1, Rules.Dir.EAST),
	])
	check(int(plates_only.counts[Rules.Mat.INGOT]) == 0 and int(plates_only.counts[Rules.Mat.PLATE]) > 0, "sending everything through the press yields plates only (%s)" % plates_only.text)
	check(not plates_only.success, "plates alone miss two orders")
	check(int(solved.counts[Rules.Mat.INGOT]) >= int(room.quota[Rules.Mat.INGOT]) and int(solved.counts[Rules.Mat.PLATE]) >= int(room.quota[Rules.Mat.PLATE]), "split solution hits both counts (%s)" % solved.text)
	var sort_room: Dictionary = Rooms.all()[3]
	var sorted_run: Dictionary = World.simulate(sort_room, sort_room.solution)
	check(int(sorted_run.counts[Rules.Mat.ORE]) == 0 and int(sorted_run.discarded) > 0, "sort sends ore into the waste chute (%s discarded %d)" % [sorted_run.text, sorted_run.discarded])


func _test_wing2_lessons() -> void:
	var straight: Dictionary = Rooms.all()[8]
	var jammed: Array = [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.ROLLER, 4, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 5, 1, Rules.Dir.EAST),
	]
	var jam_run: Dictionary = World.simulate(straight, jammed)
	check(World.budget_met(jammed, straight.budget), "belt on the straight crossing stays inside the tray")
	check(int(jam_run.counts[Rules.Mat.INGOT]) == 0, "belt on the straight crossing delivers no ingot (%s)" % jam_run.text)
	check(not jam_run.quota_ok, "belt on the straight crossing misses the quota")
	var spill: Dictionary = Rooms.all()[9]
	var one_kiln: Dictionary = World.simulate(spill, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.WEIR, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 3, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 0, Rules.Dir.EAST),
	])
	var both: Dictionary = World.simulate(spill, spill.solution)
	var spill_quota := int(spill.quota[Rules.Mat.INGOT])
	check(int(one_kiln.counts[Rules.Mat.INGOT]) < spill_quota, "one spill kiln misses %d (%s)" % [spill_quota, one_kiln.text])
	check(int(both.counts[Rules.Mat.INGOT]) >= spill_quota, "both spill kilns reach the quota (%s)" % both.text)
	check(int(both.counts[Rules.Mat.INGOT]) > int(one_kiln.counts[Rules.Mat.INGOT]), "the spill kiln adds ingots")
	var keep: Dictionary = Rooms.all()[10]
	var kept: Dictionary = World.simulate(keep, keep.solution)
	check(int(kept.counts[Rules.Mat.ORE]) >= int(keep.quota[Rules.Mat.ORE]) and int(kept.counts[Rules.Mat.INGOT]) == 0, "keep delivers ore and no ingot (%s)" % kept.text)
	check(int(kept.discarded) > 0, "keep drops ingots down the waste chute")
	var clogged: Dictionary = World.simulate(keep, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 0, Rules.Dir.EAST),
	])
	check(int(clogged.counts[Rules.Mat.ORE]) < int(keep.quota[Rules.Mat.ORE]), "keep without a filter clogs (%s)" % clogged.text)
	var detour: Dictionary = Rooms.all()[11]
	var into_wall: Dictionary = World.simulate(detour, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
	])
	check(int(into_wall.counts[Rules.Mat.ORE]) == 0, "detour belts that stop on the wall deliver nothing")
	var refine: Dictionary = Rooms.all()[12]
	var refined: Dictionary = World.simulate(refine, refine.solution)
	check(int(refined.counts[Rules.Mat.INGOT]) >= int(refine.quota[Rules.Mat.INGOT]) and int(refined.discarded) > 0, "refine counts kiln ingots and discards the raw ones (%s discarded %d)" % [refined.text, refined.discarded])
	var raw: Dictionary = World.simulate(refine, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 3, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 0, Rules.Dir.EAST),
	])
	check(int(raw.counts[Rules.Mat.INGOT]) < int(refine.quota[Rules.Mat.INGOT]), "raw ingots against the kiln miss refine (%s)" % raw.text)
	var miscast: Dictionary = Rooms.all()[13]
	var parked: Array = miscast.initial.duplicate(true)
	parked.append(Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 4, 1, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 5, 1, Rules.Dir.EAST))
	var left: Dictionary = World.simulate(miscast, parked)
	check(World.budget_met(parked, miscast.budget), "leaving the miscast roller parked stays inside the tray")
	check(int(left.counts[Rules.Mat.INGOT]) == 0 and not left.quota_ok, "a parked roller leaves a gap and misses (%s)" % left.text)
	var hearth: Dictionary = Rooms.all()[14]
	var single: Dictionary = World.simulate(hearth, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 3, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.PRESS, 5, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 6, 0, Rules.Dir.EAST),
	])
	var stamped: Dictionary = World.simulate(hearth, hearth.solution)
	var plate_quota := int(hearth.quota[Rules.Mat.PLATE])
	check(int(single.counts[Rules.Mat.PLATE]) < plate_quota, "one hearth kiln misses %d plates (%s)" % [plate_quota, single.text])
	check(int(stamped.counts[Rules.Mat.PLATE]) >= plate_quota, "both hearth kilns reach the plate quota (%s)" % stamped.text)
	var balance: Dictionary = Rooms.all()[15]
	var solved: Dictionary = World.simulate(balance, balance.solution)
	check(int(solved.counts[Rules.Mat.INGOT]) >= int(balance.quota[Rules.Mat.INGOT]) and int(solved.counts[Rules.Mat.PLATE]) >= int(balance.quota[Rules.Mat.PLATE]), "balance hits both quotas (%s)" % solved.text)
	var ingots_only: Dictionary = World.simulate(balance, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.ROLLER, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 5, 1, Rules.Dir.EAST),
	])
	check(int(ingots_only.counts[Rules.Mat.PLATE]) == 0 and int(ingots_only.counts[Rules.Mat.INGOT]) > 0, "balance without the press is ingots only (%s)" % ingots_only.text)
	check(not ingots_only.success, "ingots alone miss balance")
	var plates_only: Dictionary = World.simulate(balance, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.ROLLER, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 4, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.PRESS, 5, 2, Rules.Dir.EAST),
	])
	check(int(plates_only.counts[Rules.Mat.INGOT]) == 0 and int(plates_only.counts[Rules.Mat.PLATE]) > 0, "balance without the splitter is plates only (%s)" % plates_only.text)
	check(not plates_only.success, "plates alone miss balance")
	var crossed: Dictionary = World.simulate(balance, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.SPLITTER, 4, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 5, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.PRESS, 5, 2, Rules.Dir.EAST),
	])
	check(int(crossed.counts[Rules.Mat.INGOT]) == 0 and int(crossed.counts[Rules.Mat.PLATE]) == 0, "a belt on the balance crossing delivers nothing (%s)" % crossed.text)


func _test_game_object() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	var main = packed.instantiate()
	root.add_child(main)
	if not main.has_method("boot"):
		check(false, "main scene script failed to load")
		main.queue_free()
		return
	main.boot()
	main.testing_isolate()
	var catalog := Rooms.all()
	check(not main.is_unlocked(9), "room 9 stays locked until room 8 is cleared")
	check(not main.testing_select(8), "locked room 9 cannot be selected")
	check(main.testing_select(0), "room 1 can be selected")
	var before: int = main.testing_tray(Rules.Kind.BELT)
	check(main.testing_place(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST), "game place spends a belt")
	check(main.testing_tray(Rules.Kind.BELT) == before - 1, "game tray dropped by one")
	check(main.testing_pickup(1, 1), "game pickup lifts the belt")
	check(main.testing_tray(Rules.Kind.BELT) == before, "game pickup restored the tray")
	check(main.testing_place(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST), "place again before a run")
	main.testing_start_only()
	check(main.testing_pickup(1, 1), "pickup during a run still returns the belt")
	check(main.testing_mode_edit() and main.testing_tray(Rules.Kind.BELT) == before, "pickup during a run stops the minute and restores the tray")
	for index in catalog.size():
		check(main.testing_select(index), "select room %d" % (index + 1))
		var result: Dictionary = main.testing_apply_and_run(catalog[index].solution)
		check(result.success, "playing room %d %s clears (%s)" % [catalog[index].id, catalog[index].name, result.get("text", "")])
		if index == 0:
			check(main.is_unlocked(2), "clearing room 1 unlocks room 2")
			check(not main.is_unlocked(3), "room 3 stays locked until room 2 is cleared")
		if index == 7:
			check(main.is_unlocked(9), "clearing room 8 unlocks room 9")
			check(not main.is_unlocked(10), "room 10 stays locked until room 9 is cleared")
	check(not main.is_unlocked(17), "there is no room 17 to unlock")
	check(not main.testing_select(99), "room select rejects an unknown room")
	main.queue_free()


func _run_line(belts: int, ticks: int, mat: int, period: int, walls: Array) -> Dictionary:
	var pieces: Array = []
	for index in belts:
		pieces.append(Rooms.piece(Rules.Kind.BELT, index + 1, 0, Rules.Dir.EAST))
	var room := {
		"id": 0,
		"name": "line",
		"blurb": "",
		"rule": "",
		"w": belts + 2,
		"h": 1,
		"sources": [Rooms.source(0, 0, Rules.Dir.EAST, [mat], period)],
		"sinks": [Rooms.sink(belts + 1, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": walls,
		"budget": Rooms.kv([Rules.Kind.BELT, belts]),
		"quota": Rooms.kv([mat, 1]),
		"initial": [],
		"solution": [],
	}
	return World.simulate(room, pieces, ticks)


func _machine_room(kind: int, pattern: Array, period: int, accepts: Array) -> Dictionary:
	return {
		"id": 0,
		"name": "machine",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 1,
		"sources": [Rooms.source(0, 0, Rules.Dir.EAST, pattern, period)],
		"sinks": [Rooms.sink(2, 0, accepts)],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([kind, 1]),
		"quota": Rooms.kv([accepts[0], 1]),
		"initial": [],
		"solution": [],
	}


func _fork_room(pattern: Array, kind: int) -> Dictionary:
	return {
		"id": 0,
		"name": "fork",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 2,
		"sources": [Rooms.source(0, 0, Rules.Dir.EAST, pattern, 1)],
		"sinks": [
			Rooms.sink(2, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(1, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([kind, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}


func _flood_belt(west_pattern: Array, west_period: int, north_pattern: Array, north_period: int) -> Dictionary:
	var room := {
		"id": 0,
		"name": "flood belt",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 2,
		"sources": [
			Rooms.source(0, 1, Rules.Dir.EAST, west_pattern, west_period),
			Rooms.source(1, 0, Rules.Dir.SOUTH, north_pattern, north_period),
		],
		"sinks": [Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.BELT, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	return World.simulate(room, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST)], 80)


func _flood_splitter(pattern: Array) -> Dictionary:
	var room := _fork_room(pattern, Rules.Kind.SPLITTER)
	return World.simulate(room, [Rooms.piece(Rules.Kind.SPLITTER, 1, 0, Rules.Dir.EAST)], 80)


func _flood_kiln(period: int) -> Dictionary:
	var room := _machine_room(Rules.Kind.KILN, [Rules.Mat.ORE], period, [Rules.Mat.INGOT])
	return World.simulate(room, [Rooms.piece(Rules.Kind.KILN, 1, 0, Rules.Dir.EAST)], 80)


func _trace(result: Dictionary) -> String:
	var packed := PackedStringArray()
	for entry in result.trace:
		packed.append(str(entry))
	return "|".join(packed)


func _same(a: Dictionary, b: Dictionary) -> bool:
	return int(a.seed) == int(b.seed) and a.sig == b.sig and _trace(a) == _trace(b)
