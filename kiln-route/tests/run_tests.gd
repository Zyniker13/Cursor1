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
	_test_bridge_keeps_lanes()
	_test_bridge_refuses_front_and_right()
	_test_bridge_blocked_lane_does_not_spill()
	_test_grate_parts_metals()
	_test_grate_blocked_exit_does_not_spill()
	_test_hook_sends_left()
	_test_hook_refuses_front_and_side()
	_test_hook_blocked_exit_does_not_spill()
	_test_arm_sends_forward()
	_test_arm_refuses_behind_and_side()
	_test_arm_blocked_exit_does_not_send_left()
	_test_rooms()
	_test_over_budget()
	_test_pickup()
	_test_room7_tempting()
	_test_order_does_not_matter()
	_test_flood_is_deterministic()
	_test_room5_needs_both_kilns()
	_test_room8_both_products()
	_test_wing2_lessons()
	_test_wing3_lessons()
	_test_wing4_lessons()
	_test_wing5_lessons()
	_test_wing6_lessons()
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


func _test_bridge_keeps_lanes() -> void:
	var room := _bridge_cross([Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE], 1)
	var placed := [Rooms.piece(Rules.Kind.BRIDGE, 1, 1, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 4)
	var again := World.simulate(room, placed, 4)
	var expected := "2:2,1:0|2:1,2:0|3:2,1:1|3:1,2:1|4:2,1:2|4:1,2:2"
	check(_trace(result) == expected, "bridge keeps each material on its own lane, got %s" % _trace(result))
	check(_same(result, again), "the same bridge crossing is deterministic (seed %d)" % result.seed)
	var belt := World.simulate(room, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST)], 4)
	check(int(belt.counts[Rules.Mat.ORE]) > 0 and int(belt.counts[Rules.Mat.PLATE]) > 0, "a belt mixes both materials onto the forward sink")
	check(_trace(belt).find(":1,2:") < 0, "a belt sends nothing down the cross exit, got %s" % _trace(belt))
	var slow := _bridge_cross([Rules.Mat.PLATE], 3)
	var slow_run := World.simulate(slow, placed, 4)
	var slow_again := World.simulate(slow, placed, 4)
	check(_same(slow_run, slow_again), "a slower bridge crossing is deterministic")
	check(not _same(result, slow_run), "different bridge crossings do not collapse to one output")


func _test_bridge_refuses_front_and_right() -> void:
	var from_exit := {
		"id": 0,
		"name": "bridge exit",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [
			Rooms.source(0, 1, Rules.Dir.EAST, [Rules.Mat.ORE], 1),
			Rooms.source(1, 2, Rules.Dir.NORTH, [Rules.Mat.PLATE], 1),
		],
		"sinks": [Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.BRIDGE, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var exit_run := World.simulate(from_exit, [Rooms.piece(Rules.Kind.BRIDGE, 1, 1, Rules.Dir.EAST)], 5)
	check(_trace(exit_run) == "2:2,1:0|3:2,1:0|4:2,1:0|5:2,1:0", "bridge passes ore from behind, got %s" % _trace(exit_run))
	check(int(exit_run.counts[Rules.Mat.PLATE]) == 0 and int(exit_run.world.sources[1].pending) == Rules.Mat.PLATE, "bridge refuses an item pushed into the cross exit")
	var head_on := {
		"id": 0,
		"name": "bridge front",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [
			Rooms.source(2, 1, Rules.Dir.WEST, [Rules.Mat.INGOT], 1),
			Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.PLATE], 1),
		],
		"sinks": [Rooms.sink(1, 2, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.BRIDGE, 1]),
		"quota": Rooms.kv([Rules.Mat.PLATE, 1]),
		"initial": [],
		"solution": [],
	}
	var front_run := World.simulate(head_on, [Rooms.piece(Rules.Kind.BRIDGE, 1, 1, Rules.Dir.EAST)], 5)
	check(_trace(front_run) == "2:1,2:2|3:1,2:2|4:1,2:2|5:1,2:2", "bridge passes the cross lane while the front is blocked, got %s" % _trace(front_run))
	check(int(front_run.counts[Rules.Mat.INGOT]) == 0 and int(front_run.world.sources[0].pending) == Rules.Mat.INGOT, "bridge refuses a head-on item")


func _test_bridge_blocked_lane_does_not_spill() -> void:
	var forward_blocked := _bridge_cross([Rules.Mat.ORE], 1)
	forward_blocked.sources[1] = Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.PLATE], 1)
	forward_blocked.walls = [Rooms.cell(2, 1)]
	var placed := [Rooms.piece(Rules.Kind.BRIDGE, 1, 1, Rules.Dir.EAST)]
	var held := World.simulate(forward_blocked, placed, 6)
	var bridge = held.world.machines[Vector2i(1, 1)]
	check(int(held.counts[Rules.Mat.ORE]) == 0, "a blocked forward lane does not deliver ore, got %s" % _trace(held))
	check(int(held.counts[Rules.Mat.PLATE]) == 5, "the cross lane still delivers while forward is blocked, got %s" % _trace(held))
	check(bridge.hold == Rules.Mat.ORE and bridge.cross == Rules.Mat.PLATE, "blocked ore stays on the forward lane")
	check(int(bridge.phase) == 0, "a bridge does not keep a splitter phase")
	var cross_blocked := _bridge_cross([Rules.Mat.ORE], 1)
	cross_blocked.sources[1] = Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.PLATE], 1)
	cross_blocked.walls = [Rooms.cell(1, 2)]
	var side := World.simulate(cross_blocked, placed, 6)
	var stuck = side.world.machines[Vector2i(1, 1)]
	check(int(side.counts[Rules.Mat.PLATE]) == 0, "a blocked cross lane does not deliver plates, got %s" % _trace(side))
	check(int(side.counts[Rules.Mat.ORE]) == 5, "the forward lane still delivers while the cross is blocked, got %s" % _trace(side))
	check(stuck.cross == Rules.Mat.PLATE and stuck.hold == Rules.Mat.ORE, "blocked plate stays on the cross lane")


func _test_grate_parts_metals() -> void:
	var room := _fork_room([Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE], Rules.Kind.GRATE)
	var placed := [Rooms.piece(Rules.Kind.GRATE, 1, 0, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 7)
	var again := World.simulate(room, placed, 7)
	var expected := "2:1,1:0|3:1,1:1|4:2,0:2|5:1,1:0|6:1,1:1|7:2,0:2"
	check(_trace(result) == expected, "grate sends plates forward and ore and ingots right, got %s" % _trace(result))
	check(_same(result, again), "the same grate sort is deterministic (seed %d)" % result.seed)
	check(int(result.world.machines[Vector2i(1, 0)].phase) == 0, "a grate does not keep a splitter phase")
	var filtered := World.simulate(room, [Rooms.piece(Rules.Kind.FILTER, 1, 0, Rules.Dir.EAST)], 7)
	check(_trace(filtered) != expected, "a filter does not sort the way a grate does, got %s" % _trace(filtered))
	var ingots := _fork_room([Rules.Mat.INGOT], Rules.Kind.GRATE)
	var ingot_run := World.simulate(ingots, placed, 7)
	var ingot_again := World.simulate(ingots, placed, 7)
	check(_same(ingot_run, ingot_again), "a grate fed only ingots is deterministic")
	check(not _same(result, ingot_run), "different grate inputs do not collapse to one output")


func _test_grate_blocked_exit_does_not_spill() -> void:
	var forward_blocked := _fork_room([Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE], Rules.Kind.GRATE)
	forward_blocked.walls = [Rooms.cell(2, 0)]
	var placed := [Rooms.piece(Rules.Kind.GRATE, 1, 0, Rules.Dir.EAST)]
	var held := World.simulate(forward_blocked, placed, 8)
	var grate = held.world.machines[Vector2i(1, 0)]
	check(_trace(held) == "2:1,1:0|3:1,1:1", "a blocked plate waits and earlier metals still turn, got %s" % _trace(held))
	check(int(held.counts[Rules.Mat.PLATE]) == 0, "a blocked forward exit does not deliver the plate")
	check(grate.hold == Rules.Mat.PLATE, "the blocked plate stays on the grate")
	check(int(grate.phase) == 0, "a blocked grate does not advance a phase")
	var side_blocked := _fork_room([Rules.Mat.ORE], Rules.Kind.GRATE)
	side_blocked.walls = [Rooms.cell(1, 1)]
	var side := World.simulate(side_blocked, placed, 6)
	var stuck = side.world.machines[Vector2i(1, 0)]
	check(side.trace.is_empty(), "a blocked side exit does not spill ore forward")
	check(stuck.hold == Rules.Mat.ORE, "blocked ore stays on the grate")
	check(int(side.counts[Rules.Mat.ORE]) == 0, "a blocked grate delivers no ore")


func _bridge_cross(pattern: Array, period: int) -> Dictionary:
	return {
		"id": 0,
		"name": "bridge",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [
			Rooms.source(0, 1, Rules.Dir.EAST, pattern, period),
			Rooms.source(1, 0, Rules.Dir.SOUTH, pattern, period),
		],
		"sinks": [
			Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(1, 2, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.BRIDGE, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}


func _test_hook_sends_left() -> void:
	var room := _hook_turn([Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])
	var placed := [Rooms.piece(Rules.Kind.HOOK, 1, 1, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 7)
	var again := World.simulate(room, placed, 7)
	var expected := "2:1,0:0|3:1,0:1|4:1,0:2|5:1,0:0|6:1,0:1|7:1,0:2"
	check(_trace(result) == expected, "hook sends every material left, got %s" % _trace(result))
	check(_same(result, again), "the same hook turn is deterministic (seed %d)" % result.seed)
	check(int(result.world.machines[Vector2i(1, 1)].phase) == 0, "a hook does not keep a splitter phase")
	var belt := World.simulate(room, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST)], 7)
	check(_trace(belt).find(":1,0:") < 0, "a belt on the hook cell does not send left, got %s" % _trace(belt))
	check(_trace(belt).begins_with("2:2,1:0"), "a belt sends the same load forward, got %s" % _trace(belt))
	var weir := World.simulate(room, [Rooms.piece(Rules.Kind.WEIR, 1, 1, Rules.Dir.EAST)], 4)
	check(_trace(weir).begins_with("2:2,1:0"), "a weir prefers forward instead of the hook's left, got %s" % _trace(weir))
	var plates := _hook_turn([Rules.Mat.PLATE])
	var plate_run := World.simulate(plates, placed, 7)
	var plate_again := World.simulate(plates, placed, 7)
	check(_same(plate_run, plate_again), "a hook fed only plates is deterministic")
	check(not _same(result, plate_run), "different hook inputs do not collapse to one output")


func _test_hook_refuses_front_and_side() -> void:
	var room := {
		"id": 0,
		"name": "hook refuse",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [
			Rooms.source(0, 1, Rules.Dir.EAST, [Rules.Mat.ORE], 1),
			Rooms.source(2, 1, Rules.Dir.WEST, [Rules.Mat.PLATE], 1),
			Rooms.source(1, 2, Rules.Dir.NORTH, [Rules.Mat.INGOT], 1),
		],
		"sinks": [Rooms.sink(1, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.HOOK, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var result := World.simulate(room, [Rooms.piece(Rules.Kind.HOOK, 1, 1, Rules.Dir.EAST)], 5)
	check(_trace(result) == "2:1,0:0|3:1,0:0|4:1,0:0|5:1,0:0", "hook passes ore from behind, got %s" % _trace(result))
	check(int(result.counts[Rules.Mat.PLATE]) == 0 and int(result.world.sources[1].pending) == Rules.Mat.PLATE, "hook refuses a head-on plate")
	check(int(result.counts[Rules.Mat.INGOT]) == 0 and int(result.world.sources[2].pending) == Rules.Mat.INGOT, "hook refuses an ingot from the side")


func _test_hook_blocked_exit_does_not_spill() -> void:
	var room := _hook_turn([Rules.Mat.ORE])
	room.walls = [Rooms.cell(1, 0)]
	var placed := [Rooms.piece(Rules.Kind.HOOK, 1, 1, Rules.Dir.EAST)]
	var held := World.simulate(room, placed, 6)
	var hook = held.world.machines[Vector2i(1, 1)]
	check(held.trace.is_empty(), "a blocked hook does not spill forward, got %s" % _trace(held))
	check(int(held.counts[Rules.Mat.ORE]) == 0, "a blocked hook delivers no ore")
	check(hook.hold == Rules.Mat.ORE, "blocked ore stays on the hook")
	check(int(hook.phase) == 0, "a blocked hook does not advance a phase")


func _hook_turn(pattern: Array) -> Dictionary:
	return {
		"id": 0,
		"name": "hook",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [Rooms.source(0, 1, Rules.Dir.EAST, pattern, 1)],
		"sinks": [
			Rooms.sink(1, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.HOOK, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}


func _test_arm_sends_forward() -> void:
	var room := _arm_lane([Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])
	var placed := [Rooms.piece(Rules.Kind.ARM, 1, 1, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 7)
	var again := World.simulate(room, placed, 7)
	var expected := "2:2,1:0|3:2,1:1|4:2,1:2|5:2,1:0|6:2,1:1|7:2,1:2"
	check(_trace(result) == expected, "arm sends every material forward, got %s" % _trace(result))
	check(_same(result, again), "the same arm lane is deterministic (seed %d)" % result.seed)
	check(int(result.world.machines[Vector2i(1, 1)].phase) == 0, "an arm does not keep a splitter phase")
	check(_trace(result).find(":1,2:") < 0, "an arm does not send to the right, got %s" % _trace(result))
	var hook := World.simulate(room, [Rooms.piece(Rules.Kind.HOOK, 1, 1, Rules.Dir.EAST)], 7)
	check(hook.trace.is_empty(), "a hook on the arm cell does not take a load from the left, got %s" % _trace(hook))
	check(int(hook.world.sources[0].pending) == Rules.Mat.ORE, "the refused left load stays on the source")
	var belt := World.simulate(room, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST)], 4)
	check(_trace(belt).begins_with("2:2,1:0"), "a belt can carry that same left load forward, got %s" % _trace(belt))
	var plates := _arm_lane([Rules.Mat.PLATE])
	var plate_run := World.simulate(plates, placed, 7)
	var plate_again := World.simulate(plates, placed, 7)
	check(_same(plate_run, plate_again), "an arm fed only plates is deterministic")
	check(not _same(result, plate_run), "different arm inputs do not collapse to one output")


func _test_arm_refuses_behind_and_side() -> void:
	var room := {
		"id": 0,
		"name": "arm refuse",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [
			Rooms.source(0, 1, Rules.Dir.EAST, [Rules.Mat.ORE], 1),
			Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.PLATE], 1),
			Rooms.source(1, 2, Rules.Dir.NORTH, [Rules.Mat.INGOT], 1),
		],
		"sinks": [Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.ARM, 1, Rules.Kind.BELT, 1]),
		"quota": Rooms.kv([Rules.Mat.PLATE, 1]),
		"initial": [],
		"solution": [],
	}
	var placed := [Rooms.piece(Rules.Kind.ARM, 1, 1, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 5)
	check(_trace(result) == "2:2,1:2|3:2,1:2|4:2,1:2|5:2,1:2", "arm passes plates from the left, got %s" % _trace(result))
	check(int(result.counts[Rules.Mat.ORE]) == 0 and int(result.world.sources[0].pending) == Rules.Mat.ORE, "arm refuses ore from behind")
	check(int(result.counts[Rules.Mat.INGOT]) == 0 and int(result.world.sources[2].pending) == Rules.Mat.INGOT, "arm refuses an ingot from the right")
	var belt := World.simulate(room, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST)], 4)
	check(int(belt.counts[Rules.Mat.ORE]) > 0, "a belt takes the ore the arm refused, got %s" % _trace(belt))
	var front := {
		"id": 0,
		"name": "arm front",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [
			Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.ORE], 1),
			Rooms.source(2, 1, Rules.Dir.WEST, [Rules.Mat.INGOT], 1),
		],
		"sinks": [Rooms.sink(1, 2, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.ARM, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var blocked := World.simulate(front, placed, 5)
	var arm = blocked.world.machines[Vector2i(1, 1)]
	check(int(blocked.counts[Rules.Mat.INGOT]) == 0 and int(blocked.world.sources[1].pending) == Rules.Mat.INGOT, "arm refuses a head-on ingot")
	check(arm.hold == Rules.Mat.ORE, "the left load stays on the arm while the front is blocked")
	check(blocked.trace.is_empty(), "a head-on block does not send the ore left, got %s" % _trace(blocked))


func _test_arm_blocked_exit_does_not_send_left() -> void:
	var room := _arm_lane([Rules.Mat.ORE])
	room.walls = [Rooms.cell(2, 1)]
	var placed := [Rooms.piece(Rules.Kind.ARM, 1, 1, Rules.Dir.EAST)]
	var held := World.simulate(room, placed, 6)
	var arm = held.world.machines[Vector2i(1, 1)]
	check(held.trace.is_empty(), "a blocked arm does not deliver, got %s" % _trace(held))
	check(int(held.counts[Rules.Mat.ORE]) == 0, "a blocked arm delivers no ore")
	check(arm.hold == Rules.Mat.ORE, "blocked ore stays on the arm")
	check(int(arm.phase) == 0, "a blocked arm does not advance a phase")
	check(int(held.discarded) == 0, "a blocked arm does not discard")
	var boxed := {
		"id": 0,
		"name": "arm boxed",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [],
		"sinks": [
			Rooms.sink(1, 2, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(0, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [Rooms.cell(1, 0)],
		"walls": [Rooms.cell(2, 1)],
		"budget": Rooms.kv([Rules.Kind.ARM, 1, Rules.Kind.HOOK, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var arm_world = World.new()
	arm_world.setup(boxed, [Rooms.piece(Rules.Kind.ARM, 1, 1, Rules.Dir.EAST)])
	arm_world.machines[Vector2i(1, 1)].hold = Rules.Mat.ORE
	arm_world.step()
	check(arm_world.error == "" and arm_world.discarded == 0 and arm_world.trace.is_empty(), "a blocked arm does not send left into the chute")
	check(arm_world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "the arm still holds the ore")
	check(int(arm_world.counts[Rules.Mat.ORE]) == 0, "the blocked arm did not reach a side sink")
	var hook_world = World.new()
	hook_world.setup(boxed, [Rooms.piece(Rules.Kind.HOOK, 1, 1, Rules.Dir.EAST)])
	hook_world.machines[Vector2i(1, 1)].hold = Rules.Mat.ORE
	hook_world.step()
	check(hook_world.discarded == 1 and hook_world.machines[Vector2i(1, 1)].hold < 0, "the same cell lets a hook send left into the chute")


func _arm_lane(pattern: Array) -> Dictionary:
	return {
		"id": 0,
		"name": "arm",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [Rooms.source(1, 0, Rules.Dir.SOUTH, pattern, 1)],
		"sinks": [
			Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(1, 2, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.ARM, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}


func _test_rooms() -> void:
	var catalog := Rooms.all()
	check(catalog.size() == 48, "six wings have 48 rooms")
	check(catalog[0].name == "Haul" and catalog[7].name == "Two Orders", "rooms 1 through 8 stay the first wing")
	check(catalog[8].name == "Straight" and catalog[15].name == "Balance", "rooms 9 through 16 are the second wing")
	check(catalog[16].name == "Span" and catalog[23].name == "Ledger", "rooms 17 through 24 are the third wing")
	check(catalog[24].name == "Screen" and catalog[31].name == "Reckon", "rooms 25 through 32 are the fourth wing")
	check(catalog[32].name == "Veer" and catalog[39].name == "Tally", "rooms 33 through 40 are the fifth wing")
	check(catalog[40].name == "Reach" and catalog[47].name == "Audit", "rooms 41 through 48 are the sixth wing")
	for index in catalog.size():
		var bridge_count := int(catalog[index].budget.get(Rules.Kind.BRIDGE, 0))
		var grate_count := int(catalog[index].budget.get(Rules.Kind.GRATE, 0))
		var hook_count := int(catalog[index].budget.get(Rules.Kind.HOOK, 0))
		var arm_count := int(catalog[index].budget.get(Rules.Kind.ARM, 0))
		if index < 16:
			check(bridge_count == 0, "room %d does not use the bridge" % (index + 1))
			check(grate_count == 0, "room %d does not use the grate" % (index + 1))
			check(hook_count == 0, "room %d does not use the hook" % (index + 1))
			check(arm_count == 0, "room %d does not use the arm" % (index + 1))
		elif index < 24:
			check(bridge_count >= 1, "room %d depends on the bridge" % (index + 1))
			check(grate_count == 0, "room %d does not use the grate" % (index + 1))
			check(hook_count == 0, "room %d does not use the hook" % (index + 1))
			check(arm_count == 0, "room %d does not use the arm" % (index + 1))
		elif index < 32:
			check(grate_count >= 1, "room %d depends on the grate" % (index + 1))
			check(hook_count == 0, "room %d does not use the hook" % (index + 1))
			check(arm_count == 0, "room %d does not use the arm" % (index + 1))
		elif index < 40:
			check(hook_count >= 1, "room %d depends on the hook" % (index + 1))
			check(arm_count == 0, "room %d does not use the arm" % (index + 1))
		else:
			check(arm_count >= 1, "room %d depends on the arm" % (index + 1))
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
	var skew: Dictionary = Rooms.all()[19]
	var off = Planner.new(skew)
	check(off.at(1, 0) != null and off.remaining(Rules.Kind.BRIDGE) == 0, "skew starts with the bridge off the tray")
	check(off.pickup(1, 0), "pickup lifts the pre-placed bridge")
	check(off.at(1, 0) == null and off.remaining(Rules.Kind.BRIDGE) == 1, "pre-placed bridge returns to the tray")
	check(off.place(Rules.Kind.BRIDGE, 2, 1, Rules.Dir.EAST), "the returned bridge can be seated on the crossing")
	var cant: Dictionary = Rooms.all()[27]
	var aside = Planner.new(cant)
	check(aside.at(1, 0) != null and aside.remaining(Rules.Kind.GRATE) == 0, "cant starts with the grate off the tray")
	check(aside.pickup(1, 0), "pickup lifts the pre-placed grate")
	check(aside.at(1, 0) == null and aside.remaining(Rules.Kind.GRATE) == 1, "pre-placed grate returns to the tray")
	check(aside.place(Rules.Kind.GRATE, 2, 1, Rules.Dir.EAST), "the returned grate can be seated on the split")
	var slue: Dictionary = Rooms.all()[35]
	var veered = Planner.new(slue)
	check(veered.at(0, 0) != null and veered.remaining(Rules.Kind.HOOK) == 0, "slue starts with the hook off the tray")
	check(veered.pickup(0, 0), "pickup lifts the pre-placed hook")
	check(veered.at(0, 0) == null and veered.remaining(Rules.Kind.HOOK) == 1, "pre-placed hook returns to the tray")
	check(veered.place(Rules.Kind.HOOK, 3, 1, Rules.Dir.EAST), "the returned hook can be seated on the turn")
	var heft: Dictionary = Rooms.all()[43]
	var lifted = Planner.new(heft)
	check(lifted.at(0, 1) != null and lifted.remaining(Rules.Kind.ARM) == 0, "heft starts with the arm off the tray")
	check(lifted.pickup(0, 1), "pickup lifts the pre-placed arm")
	check(lifted.at(0, 1) == null and lifted.remaining(Rules.Kind.ARM) == 1, "pre-placed arm returns to the tray")
	check(lifted.place(Rules.Kind.ARM, 3, 1, Rules.Dir.EAST), "the returned arm can be seated on the lane")


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


func _test_wing3_lessons() -> void:
	var span: Dictionary = Rooms.all()[16]
	var span_jam: Array = [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BRIDGE, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 2, 3, Rules.Dir.SOUTH),
	]
	var span_run: Dictionary = World.simulate(span, span_jam)
	check(World.budget_met(span_jam, span.budget), "belt on the span crossing stays inside the tray")
	check(int(span_run.counts[Rules.Mat.INGOT]) == 0 and int(span_run.counts[Rules.Mat.PLATE]) == 0, "belt on the span crossing delivers nothing (%s)" % span_run.text)
	check(not span_run.quota_ok, "belt on the span crossing misses the quota")
	var thread: Dictionary = Rooms.all()[17]
	var thread_jam: Dictionary = World.simulate(thread, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 4, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 5, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BRIDGE, 2, 2, Rules.Dir.SOUTH),
	])
	check(int(thread_jam.counts[Rules.Mat.INGOT]) == 0 and int(thread_jam.counts[Rules.Mat.PLATE]) == 0, "belt on the thread crossing delivers nothing (%s)" % thread_jam.text)
	var seam: Dictionary = Rooms.all()[18]
	var seam_belt: Dictionary = World.simulate(seam, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BRIDGE, 1, 2, Rules.Dir.SOUTH),
	])
	check(World.budget_met([
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BRIDGE, 1, 2, Rules.Dir.SOUTH),
	], seam.budget), "seam's wrong belt stays inside the tray")
	check(int(seam_belt.counts[Rules.Mat.PLATE]) == 0 and int(seam_belt.counts[Rules.Mat.INGOT]) < int(seam.quota[Rules.Mat.INGOT]), "spending seam's belt on the ore lane misses (%s)" % seam_belt.text)
	check(not seam_belt.success, "seam without the plate belt misses")
	var skew: Dictionary = Rooms.all()[19]
	var parked: Array = skew.initial.duplicate(true)
	parked.append(Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 2, 2, Rules.Dir.SOUTH))
	parked.append(Rooms.piece(Rules.Kind.BELT, 2, 3, Rules.Dir.SOUTH))
	var gap: Dictionary = World.simulate(skew, parked)
	check(World.budget_met(parked, skew.budget), "leaving the skew bridge parked stays inside the tray")
	check(int(gap.counts[Rules.Mat.INGOT]) == 0 and int(gap.counts[Rules.Mat.PLATE]) == 0 and not gap.quota_ok, "a parked bridge leaves a gap and misses (%s)" % gap.text)
	var bend: Dictionary = Rooms.all()[20]
	var no_turn: Dictionary = World.simulate(bend, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 1, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BRIDGE, 3, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 2, Rules.Dir.EAST),
	])
	check(int(no_turn.counts[Rules.Mat.PLATE]) == 0 and int(no_turn.counts[Rules.Mat.INGOT]) > 0, "bend without the turn delivers ingots and no plate (%s)" % no_turn.text)
	check(not no_turn.success, "plates that miss the bridge's left side miss bend")
	var brim: Dictionary = Rooms.all()[21]
	var one_kiln: Dictionary = World.simulate(brim, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BRIDGE, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.WEIR, 4, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 5, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 6, 1, Rules.Dir.EAST),
	])
	var both: Dictionary = World.simulate(brim, brim.solution)
	var brim_quota := int(brim.quota[Rules.Mat.INGOT])
	check(int(one_kiln.counts[Rules.Mat.INGOT]) < brim_quota, "one brim kiln misses %d (%s)" % [brim_quota, one_kiln.text])
	check(int(one_kiln.counts[Rules.Mat.PLATE]) >= int(brim.quota[Rules.Mat.PLATE]), "one brim kiln still crosses the plates (%s)" % one_kiln.text)
	check(int(both.counts[Rules.Mat.INGOT]) >= brim_quota and int(both.counts[Rules.Mat.PLATE]) >= int(brim.quota[Rules.Mat.PLATE]), "both brim kilns reach the quota (%s)" % both.text)
	check(int(both.counts[Rules.Mat.INGOT]) > int(one_kiln.counts[Rules.Mat.INGOT]), "the brim spill kiln adds ingots")
	var sift: Dictionary = Rooms.all()[22]
	var sifted: Dictionary = World.simulate(sift, sift.solution)
	check(int(sifted.counts[Rules.Mat.INGOT]) >= int(sift.quota[Rules.Mat.INGOT]) and int(sifted.counts[Rules.Mat.PLATE]) >= int(sift.quota[Rules.Mat.PLATE]) and int(sifted.discarded) > 0, "sift counts kiln ingots, crosses plates, and discards raw ingots (%s discarded %d)" % [sifted.text, sifted.discarded])
	var raw: Dictionary = World.simulate(sift, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BRIDGE, 4, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 5, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 6, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.FILTER, 3, 0, Rules.Dir.EAST),
	])
	check(int(raw.counts[Rules.Mat.INGOT]) < int(sift.quota[Rules.Mat.INGOT]), "raw ingots against the kiln miss sift (%s)" % raw.text)
	var ledger: Dictionary = Rooms.all()[23]
	var solved: Dictionary = World.simulate(ledger, ledger.solution)
	check(int(solved.counts[Rules.Mat.INGOT]) >= int(ledger.quota[Rules.Mat.INGOT]) and int(solved.counts[Rules.Mat.PLATE]) >= int(ledger.quota[Rules.Mat.PLATE]), "ledger hits both quotas (%s)" % solved.text)
	var ingots_only: Dictionary = World.simulate(ledger, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BRIDGE, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 5, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 2, Rules.Dir.SOUTH),
	])
	check(int(ingots_only.counts[Rules.Mat.INGOT]) > 0 and int(ingots_only.counts[Rules.Mat.PLATE]) < int(ledger.quota[Rules.Mat.PLATE]), "ledger without the press is short on plates (%s)" % ingots_only.text)
	check(not ingots_only.success, "crossing plates alone miss ledger")
	var plates_only: Dictionary = World.simulate(ledger, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BRIDGE, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 4, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.PRESS, 5, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 2, Rules.Dir.SOUTH),
	])
	check(int(plates_only.counts[Rules.Mat.INGOT]) == 0 and int(plates_only.counts[Rules.Mat.PLATE]) > 0, "ledger without the splitter is plates only (%s)" % plates_only.text)
	check(not plates_only.success, "plates alone miss ledger")
	var mixed: Dictionary = World.simulate(ledger, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.SPLITTER, 4, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 5, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 4, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.PRESS, 5, 2, Rules.Dir.EAST),
	])
	check(int(mixed.counts[Rules.Mat.INGOT]) == 0 and int(mixed.counts[Rules.Mat.PLATE]) == 0, "a belt on the ledger crossing delivers nothing (%s)" % mixed.text)


func _test_wing4_lessons() -> void:
	var screen: Dictionary = Rooms.all()[24]
	var mixed_belts: Array = [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST),
	]
	var screen_run: Dictionary = World.simulate(screen, mixed_belts)
	check(World.budget_met(mixed_belts, screen.budget), "belt on the screen split stays inside the tray")
	check(int(screen_run.counts[Rules.Mat.INGOT]) == 0 and int(screen_run.counts[Rules.Mat.PLATE]) < int(screen.quota[Rules.Mat.PLATE]), "belt on the screen split stalls (%s)" % screen_run.text)
	check(not screen_run.quota_ok, "belt on the screen split misses the quota")
	var temper: Dictionary = Rooms.all()[25]
	var shared: Dictionary = World.simulate(temper, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 1, Rules.Dir.EAST),
	])
	check(int(shared.counts[Rules.Mat.INGOT]) == 0 and int(shared.counts[Rules.Mat.PLATE]) == 0, "temper without a grate delivers nothing (%s)" % shared.text)
	check(not shared.success, "a shared temper belt misses both quotas")
	var crimp: Dictionary = Rooms.all()[26]
	var upstream_pieces: Array = [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.GRATE, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 1, 2, Rules.Dir.SOUTH),
	]
	var upstream: Dictionary = World.simulate(crimp, upstream_pieces)
	var crimped: Dictionary = World.simulate(crimp, crimp.solution)
	check(World.budget_met(upstream_pieces, crimp.budget), "crimp's upstream belt stays inside the tray")
	check(int(upstream.counts[Rules.Mat.PLATE]) >= int(crimp.quota[Rules.Mat.PLATE]) and int(upstream.counts[Rules.Mat.INGOT]) == 0, "crimp's pit eats the ore while plates still arrive (%s)" % upstream.text)
	check(not upstream.success, "ingots miss when crimp's kiln is off the ore")
	check(int(crimped.counts[Rules.Mat.INGOT]) >= int(crimp.quota[Rules.Mat.INGOT]) and int(crimped.discarded) == 0, "crimp's kiln keeps the ore out of the pit (%s discarded %d)" % [crimped.text, crimped.discarded])
	var cant: Dictionary = Rooms.all()[27]
	var parked: Array = cant.initial.duplicate(true)
	parked.append(Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST))
	var gap: Dictionary = World.simulate(cant, parked)
	check(World.budget_met(parked, cant.budget), "leaving the cant grate parked stays inside the tray")
	check(int(gap.counts[Rules.Mat.INGOT]) == 0 and int(gap.counts[Rules.Mat.PLATE]) < int(cant.quota[Rules.Mat.PLATE]) and not gap.quota_ok, "a parked grate leaves the split to a belt and misses (%s)" % gap.text)
	var jink: Dictionary = Rooms.all()[28]
	var no_turn: Dictionary = World.simulate(jink, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.GRATE, 3, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 4, 2, Rules.Dir.EAST),
	])
	check(int(no_turn.counts[Rules.Mat.INGOT]) == 0 and int(no_turn.counts[Rules.Mat.PLATE]) < int(jink.quota[Rules.Mat.PLATE]), "jink without the turn delivers no ingot and misses the plates (%s)" % no_turn.text)
	check(not no_turn.success, "ingots that run south off the route miss jink")
	var charge: Dictionary = Rooms.all()[29]
	var one_kiln: Dictionary = World.simulate(charge, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.GRATE, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.WEIR, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 4, 1, Rules.Dir.EAST),
	])
	var both: Dictionary = World.simulate(charge, charge.solution)
	var charge_quota := int(charge.quota[Rules.Mat.INGOT])
	check(int(one_kiln.counts[Rules.Mat.INGOT]) < charge_quota, "one charge kiln misses %d (%s)" % [charge_quota, one_kiln.text])
	check(int(one_kiln.counts[Rules.Mat.PLATE]) >= int(charge.quota[Rules.Mat.PLATE]), "one charge kiln still passes the plates (%s)" % one_kiln.text)
	check(int(both.counts[Rules.Mat.INGOT]) >= charge_quota and int(both.counts[Rules.Mat.PLATE]) >= int(charge.quota[Rules.Mat.PLATE]), "both charge kilns reach the quota (%s)" % both.text)
	check(int(both.counts[Rules.Mat.INGOT]) > int(one_kiln.counts[Rules.Mat.INGOT]), "the charge spill kiln adds ingots")
	var clogged: Dictionary = World.simulate(charge, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 0, Rules.Dir.EAST),
	])
	check(int(clogged.counts[Rules.Mat.INGOT]) == 0 and int(clogged.counts[Rules.Mat.PLATE]) == 0, "charge without a grate delivers nothing (%s)" % clogged.text)
	var clarify: Dictionary = Rooms.all()[30]
	var clarified: Dictionary = World.simulate(clarify, clarify.solution)
	check(int(clarified.counts[Rules.Mat.INGOT]) >= int(clarify.quota[Rules.Mat.INGOT]) and int(clarified.counts[Rules.Mat.PLATE]) >= int(clarify.quota[Rules.Mat.PLATE]), "clarify hits both quotas (%s)" % clarified.text)
	var no_grate: Dictionary = World.simulate(clarify, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.FILTER, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 2, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 3, Rules.Dir.EAST),
	])
	check(int(no_grate.counts[Rules.Mat.INGOT]) < int(clarify.quota[Rules.Mat.INGOT]) and int(no_grate.counts[Rules.Mat.PLATE]) == 0, "clarify without a grate misses (%s)" % no_grate.text)
	var no_filter: Dictionary = World.simulate(clarify, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 2, 3, Rules.Dir.EAST),
	])
	check(int(no_filter.counts[Rules.Mat.INGOT]) < int(clarify.quota[Rules.Mat.INGOT]) and int(no_filter.counts[Rules.Mat.PLATE]) == 0, "clarify without a filter misses (%s)" % no_filter.text)
	var no_kiln: Dictionary = World.simulate(clarify, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.FILTER, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 2, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.GRATE, 3, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 3, Rules.Dir.EAST),
	])
	check(int(no_kiln.counts[Rules.Mat.INGOT]) < int(clarify.quota[Rules.Mat.INGOT]) and int(no_kiln.counts[Rules.Mat.PLATE]) < int(clarify.quota[Rules.Mat.PLATE]), "clarify without a kiln misses (%s)" % no_kiln.text)
	var reckon: Dictionary = Rooms.all()[31]
	var solved: Dictionary = World.simulate(reckon, reckon.solution)
	check(int(solved.counts[Rules.Mat.INGOT]) >= int(reckon.quota[Rules.Mat.INGOT]) and int(solved.counts[Rules.Mat.PLATE]) >= int(reckon.quota[Rules.Mat.PLATE]), "reckon hits both quotas (%s)" % solved.text)
	var peeled: Dictionary = World.simulate(reckon, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.GRATE, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 3, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 5, 2, Rules.Dir.EAST),
	])
	check(int(peeled.counts[Rules.Mat.INGOT]) > 0 and int(peeled.counts[Rules.Mat.PLATE]) < int(reckon.quota[Rules.Mat.PLATE]), "reckon without the press is short on plates (%s)" % peeled.text)
	check(not peeled.success, "peeled plates alone miss reckon")
	var pressed: Dictionary = World.simulate(reckon, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.GRATE, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 3, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 4, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.PRESS, 5, 3, Rules.Dir.EAST),
	])
	check(int(pressed.counts[Rules.Mat.INGOT]) == 0 and int(pressed.counts[Rules.Mat.PLATE]) > 0, "reckon without the splitter is plates only (%s)" % pressed.text)
	check(not pressed.success, "plates alone miss reckon")
	var unsorted: Dictionary = World.simulate(reckon, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST),
	])
	check(int(unsorted.counts[Rules.Mat.INGOT]) == 0 and int(unsorted.counts[Rules.Mat.PLATE]) == 0, "a belt in place of the reckon grate delivers nothing (%s)" % unsorted.text)


func _test_wing5_lessons() -> void:
	var veer: Dictionary = Rooms.all()[32]
	var veer_belt: Array = [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.HOOK, 2, 0, Rules.Dir.EAST),
	]
	var veer_run: Dictionary = World.simulate(veer, veer_belt)
	check(World.budget_met(veer_belt, veer.budget), "belt on the veer turn stays inside the tray")
	check(int(veer_run.counts[Rules.Mat.INGOT]) == 0, "belt on the veer turn delivers no ingot (%s)" % veer_run.text)
	check(not veer_run.quota_ok, "belt on the veer turn misses the quota")
	var draw: Dictionary = Rooms.all()[33]
	var draw_belt: Dictionary = World.simulate(draw, [
		Rooms.piece(Rules.Kind.BELT, 1, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 2, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.KILN, 2, 1, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.HOOK, 2, 0, Rules.Dir.EAST),
	])
	check(int(draw_belt.counts[Rules.Mat.INGOT]) == 0, "belt on the draw turn delivers no ingot (%s)" % draw_belt.text)
	check(not draw_belt.success, "a plate against the draw kiln misses")
	var nip: Dictionary = Rooms.all()[34]
	var dumped_pieces: Array = [
		Rooms.piece(Rules.Kind.BELT, 1, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 1, 2, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.HOOK, 0, 2, Rules.Dir.EAST),
	]
	var dumped: Dictionary = World.simulate(nip, dumped_pieces)
	var nipped: Dictionary = World.simulate(nip, nip.solution)
	check(World.budget_met(dumped_pieces, nip.budget), "nip's belt on the hook cell stays inside the tray")
	check(int(dumped.counts[Rules.Mat.INGOT]) == 0 and int(dumped.discarded) > 0, "nip's pit eats the ore (%s discarded %d)" % [dumped.text, dumped.discarded])
	check(not dumped.success, "ore in the pit misses nip")
	check(int(nipped.counts[Rules.Mat.INGOT]) >= int(nip.quota[Rules.Mat.INGOT]) and int(nipped.discarded) == 0, "nip's hook keeps the ore out of the pit (%s discarded %d)" % [nipped.text, nipped.discarded])
	var slue: Dictionary = Rooms.all()[35]
	var parked: Array = slue.initial.duplicate(true)
	parked.append(Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.NORTH))
	var gap: Dictionary = World.simulate(slue, parked)
	check(World.budget_met(parked, slue.budget), "leaving the slue hook parked stays inside the tray")
	check(int(gap.counts[Rules.Mat.INGOT]) == 0 and not gap.quota_ok, "a parked hook leaves the turn to a belt and misses (%s)" % gap.text)
	var jibe: Dictionary = Rooms.all()[36]
	var into_wall: Dictionary = World.simulate(jibe, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 0, Rules.Dir.SOUTH),
	])
	check(int(into_wall.counts[Rules.Mat.INGOT]) == 0, "jibe belts that run into the wall deliver nothing")
	var swapped: Dictionary = World.simulate(jibe, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 0, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.HOOK, 4, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 4, 2, Rules.Dir.EAST),
	])
	check(World.budget_met([
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 0, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.HOOK, 4, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 4, 2, Rules.Dir.EAST),
	], jibe.budget), "jibe's belt on the hook cell stays inside the tray")
	check(int(swapped.counts[Rules.Mat.INGOT]) == 0, "a belt on the jibe turn delivers no ingot (%s)" % swapped.text)
	var spate: Dictionary = Rooms.all()[37]
	var one_kiln: Dictionary = World.simulate(spate, [
		Rooms.piece(Rules.Kind.BELT, 1, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.HOOK, 2, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.KILN, 2, 2, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.NORTH),
	])
	var both: Dictionary = World.simulate(spate, spate.solution)
	var spate_quota := int(spate.quota[Rules.Mat.INGOT])
	check(int(one_kiln.counts[Rules.Mat.INGOT]) < spate_quota, "one spate kiln misses %d (%s)" % [spate_quota, one_kiln.text])
	check(int(both.counts[Rules.Mat.INGOT]) >= spate_quota, "both spate kilns reach the quota (%s)" % both.text)
	check(int(both.counts[Rules.Mat.INGOT]) > int(one_kiln.counts[Rules.Mat.INGOT]), "the spate spill kiln adds ingots")
	var clogged: Dictionary = World.simulate(spate, [
		Rooms.piece(Rules.Kind.BELT, 1, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 4, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.KILN, 2, 2, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.NORTH),
	])
	check(int(clogged.counts[Rules.Mat.INGOT]) == 0, "spate without a hook delivers nothing (%s)" % clogged.text)
	var winnow: Dictionary = Rooms.all()[38]
	var winnowed: Dictionary = World.simulate(winnow, winnow.solution)
	check(int(winnowed.counts[Rules.Mat.INGOT]) >= int(winnow.quota[Rules.Mat.INGOT]) and int(winnowed.discarded) > 0, "winnow counts kiln ingots and discards the raw ones (%s discarded %d)" % [winnowed.text, winnowed.discarded])
	var no_filter: Dictionary = World.simulate(winnow, [
		Rooms.piece(Rules.Kind.BELT, 1, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.HOOK, 3, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 3, 1, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.BELT, 3, 0, Rules.Dir.EAST),
	])
	check(int(no_filter.counts[Rules.Mat.INGOT]) < int(winnow.quota[Rules.Mat.INGOT]), "winnow without a filter misses (%s)" % no_filter.text)
	var no_hook: Dictionary = World.simulate(winnow, [
		Rooms.piece(Rules.Kind.BELT, 1, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.FILTER, 2, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.KILN, 3, 1, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.BELT, 3, 0, Rules.Dir.EAST),
	])
	check(int(no_hook.counts[Rules.Mat.INGOT]) == 0, "a belt on the winnow turn delivers no ingot (%s)" % no_hook.text)
	var no_kiln: Dictionary = World.simulate(winnow, [
		Rooms.piece(Rules.Kind.BELT, 1, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.FILTER, 2, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.HOOK, 3, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.BELT, 3, 0, Rules.Dir.EAST),
	])
	check(int(no_kiln.counts[Rules.Mat.INGOT]) == 0, "winnow without a kiln delivers no ingot (%s)" % no_kiln.text)
	var tally: Dictionary = Rooms.all()[39]
	var solved: Dictionary = World.simulate(tally, tally.solution)
	check(int(solved.counts[Rules.Mat.INGOT]) >= int(tally.quota[Rules.Mat.INGOT]) and int(solved.counts[Rules.Mat.PLATE]) >= int(tally.quota[Rules.Mat.PLATE]), "tally hits both quotas (%s)" % solved.text)
	var plates_only: Dictionary = World.simulate(tally, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
	])
	check(int(plates_only.counts[Rules.Mat.INGOT]) == 0 and int(plates_only.counts[Rules.Mat.PLATE]) < int(tally.quota[Rules.Mat.PLATE]), "tally's upper plates alone miss (%s)" % plates_only.text)
	check(not plates_only.success, "upper plates alone miss tally")
	var pressed: Dictionary = World.simulate(tally, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.HOOK, 1, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.KILN, 2, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.PRESS, 4, 3, Rules.Dir.EAST),
	])
	check(int(pressed.counts[Rules.Mat.INGOT]) == 0 and int(pressed.counts[Rules.Mat.PLATE]) > 0, "tally without the splitter is plates only (%s)" % pressed.text)
	check(not pressed.success, "plates alone miss tally")
	var unhooked: Dictionary = World.simulate(tally, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 1, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 2, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.SPLITTER, 3, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 2, Rules.Dir.EAST),
	])
	check(int(unhooked.counts[Rules.Mat.INGOT]) < int(tally.quota[Rules.Mat.INGOT]) and int(unhooked.counts[Rules.Mat.PLATE]) < int(tally.quota[Rules.Mat.PLATE]), "a belt in place of the tally hook misses (%s)" % unhooked.text)
	check(not unhooked.success, "a belt in place of the tally hook does not clear")


func _test_wing6_lessons() -> void:
	var reach: Dictionary = Rooms.all()[40]
	var reach_belt: Array = [
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.ARM, 0, 1, Rules.Dir.EAST),
	]
	var reach_run: Dictionary = World.simulate(reach, reach_belt)
	check(World.budget_met(reach_belt, reach.budget), "belt on the reach lane stays inside the tray")
	check(int(reach_run.counts[Rules.Mat.PLATE]) == 0, "belt on the reach lane delivers no plate (%s)" % reach_run.text)
	check(not reach_run.quota_ok, "belt on the reach lane misses the quota")
	var feed: Dictionary = Rooms.all()[41]
	var feed_belt: Array = [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.ARM, 0, 0, Rules.Dir.EAST),
	]
	var feed_run: Dictionary = World.simulate(feed, feed_belt)
	check(World.budget_met(feed_belt, feed.budget), "belt on the feed lane stays inside the tray")
	check(int(feed_run.counts[Rules.Mat.INGOT]) == 0, "belt on the feed lane delivers no ingot (%s)" % feed_run.text)
	check(not feed_run.success, "a plate against the feed kiln misses")
	var clip: Dictionary = Rooms.all()[42]
	var dumped_pieces: Array = [
		Rooms.piece(Rules.Kind.BELT, 1, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 1, 2, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.ARM, 0, 2, Rules.Dir.EAST),
	]
	var dumped: Dictionary = World.simulate(clip, dumped_pieces)
	var clipped: Dictionary = World.simulate(clip, clip.solution)
	check(World.budget_met(dumped_pieces, clip.budget), "clip's belt on the arm cell stays inside the tray")
	check(int(dumped.counts[Rules.Mat.INGOT]) == 0 and int(dumped.discarded) > 0, "clip's pit eats the ore (%s discarded %d)" % [dumped.text, dumped.discarded])
	check(not dumped.success, "ore in the pit misses clip")
	check(int(clipped.counts[Rules.Mat.INGOT]) >= int(clip.quota[Rules.Mat.INGOT]) and int(clipped.discarded) == 0, "clip's arm keeps the ore out of the pit (%s discarded %d)" % [clipped.text, clipped.discarded])
	var heft: Dictionary = Rooms.all()[43]
	var parked: Array = heft.initial.duplicate(true)
	parked.append(Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST))
	var gap: Dictionary = World.simulate(heft, parked)
	check(World.budget_met(parked, heft.budget), "leaving the heft arm parked stays inside the tray")
	check(int(gap.counts[Rules.Mat.PLATE]) == 0 and not gap.quota_ok, "a parked arm leaves the lane to a belt and misses (%s)" % gap.text)
	var sweep: Dictionary = Rooms.all()[44]
	var into_wall: Dictionary = World.simulate(sweep, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 0, Rules.Dir.SOUTH),
	])
	check(int(into_wall.counts[Rules.Mat.PLATE]) == 0, "sweep belts that run into the wall deliver nothing")
	var swapped_pieces: Array = [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 0, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.ARM, 4, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 2, Rules.Dir.EAST),
	]
	var swapped: Dictionary = World.simulate(sweep, swapped_pieces)
	check(World.budget_met(swapped_pieces, sweep.budget), "sweep's belt on the arm cell stays inside the tray")
	check(int(swapped.counts[Rules.Mat.PLATE]) == 0, "a belt on the sweep lane delivers no plate (%s)" % swapped.text)
	var surge: Dictionary = Rooms.all()[45]
	var one_kiln: Dictionary = World.simulate(surge, [
		Rooms.piece(Rules.Kind.BELT, 1, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.ARM, 2, 4, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.KILN, 2, 2, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.NORTH),
	])
	var both: Dictionary = World.simulate(surge, surge.solution)
	var surge_quota := int(surge.quota[Rules.Mat.INGOT])
	check(int(one_kiln.counts[Rules.Mat.INGOT]) < surge_quota, "one surge kiln misses %d (%s)" % [surge_quota, one_kiln.text])
	check(int(both.counts[Rules.Mat.INGOT]) >= surge_quota, "both surge kilns reach the quota (%s)" % both.text)
	check(int(both.counts[Rules.Mat.INGOT]) > int(one_kiln.counts[Rules.Mat.INGOT]), "the surge spill kiln adds ingots")
	var clogged_pieces: Array = [
		Rooms.piece(Rules.Kind.BELT, 1, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 4, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.KILN, 2, 2, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.NORTH),
	]
	var clogged: Dictionary = World.simulate(surge, clogged_pieces)
	check(World.budget_met(clogged_pieces, surge.budget), "surge's belt in place of the arm stays inside the tray")
	check(int(clogged.counts[Rules.Mat.INGOT]) == 0, "surge without an arm delivers nothing (%s)" % clogged.text)
	var cull: Dictionary = Rooms.all()[46]
	var culled: Dictionary = World.simulate(cull, cull.solution)
	check(int(culled.counts[Rules.Mat.INGOT]) >= int(cull.quota[Rules.Mat.INGOT]) and int(culled.discarded) > 0, "cull counts kiln ingots and discards the raw ones (%s discarded %d)" % [culled.text, culled.discarded])
	var no_filter: Dictionary = World.simulate(cull, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.ARM, 3, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 4, 2, Rules.Dir.EAST),
	])
	check(int(no_filter.counts[Rules.Mat.INGOT]) < int(cull.quota[Rules.Mat.INGOT]), "cull without a filter misses (%s)" % no_filter.text)
	var no_arm: Dictionary = World.simulate(cull, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.FILTER, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 4, 2, Rules.Dir.EAST),
	])
	check(World.budget_met([
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.FILTER, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 4, 2, Rules.Dir.EAST),
	], cull.budget), "cull's belt on the arm cell stays inside the tray")
	check(int(no_arm.counts[Rules.Mat.INGOT]) == 0, "a belt on the cull lane delivers no ingot (%s)" % no_arm.text)
	var no_kiln: Dictionary = World.simulate(cull, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.FILTER, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.ARM, 3, 2, Rules.Dir.EAST),
	])
	check(int(no_kiln.counts[Rules.Mat.INGOT]) == 0, "cull without a kiln delivers no ingot (%s)" % no_kiln.text)
	var audit: Dictionary = Rooms.all()[47]
	var solved: Dictionary = World.simulate(audit, audit.solution)
	check(int(solved.counts[Rules.Mat.INGOT]) >= int(audit.quota[Rules.Mat.INGOT]) and int(solved.counts[Rules.Mat.PLATE]) >= int(audit.quota[Rules.Mat.PLATE]), "audit hits both quotas (%s)" % solved.text)
	var plates_only: Dictionary = World.simulate(audit, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
	])
	check(int(plates_only.counts[Rules.Mat.INGOT]) == 0 and int(plates_only.counts[Rules.Mat.PLATE]) < int(audit.quota[Rules.Mat.PLATE]), "audit's upper plates alone miss (%s)" % plates_only.text)
	check(not plates_only.success, "upper plates alone miss audit")
	var pressed: Dictionary = World.simulate(audit, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.ARM, 1, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 2, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.PRESS, 4, 3, Rules.Dir.EAST),
	])
	check(int(pressed.counts[Rules.Mat.INGOT]) == 0 and int(pressed.counts[Rules.Mat.PLATE]) > 0, "audit without the splitter is plates only (%s)" % pressed.text)
	check(not pressed.success, "plates alone miss audit")
	var unarmed_pieces: Array = [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 1, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 2, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.SPLITTER, 3, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 2, Rules.Dir.EAST),
	]
	var unarmed: Dictionary = World.simulate(audit, unarmed_pieces)
	check(World.budget_met(unarmed_pieces, audit.budget), "audit's belt in place of the arm stays inside the tray")
	check(int(unarmed.counts[Rules.Mat.INGOT]) < int(audit.quota[Rules.Mat.INGOT]) and int(unarmed.counts[Rules.Mat.PLATE]) < int(audit.quota[Rules.Mat.PLATE]), "a belt in place of the audit arm misses (%s)" % unarmed.text)
	check(not unarmed.success, "a belt in place of the audit arm does not clear")


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
	check(main._kind_for_key(KEY_0) == Rules.Kind.HOOK, "hook stays on key 0")
	check(main._kind_for_key(KEY_KP_0) == Rules.Kind.HOOK, "keypad 0 stays on the hook")
	check(main._kind_for_key(KEY_MINUS) == Rules.Kind.ARM, "minus selects the arm")
	check(main._kind_for_key(KEY_KP_SUBTRACT) == Rules.Kind.ARM, "keypad minus selects the arm")
	check(main._key_label(Rules.Kind.HOOK) == "0", "hook key label stays 0")
	check(main._key_label(Rules.Kind.ARM) == "-", "arm key is minus")
	check(main._key_label(Rules.Kind.ARM) != "0", "arm does not reuse the hook key")
	var catalog := Rooms.all()
	check(not main.is_unlocked(9), "room 9 stays locked until room 8 is cleared")
	check(not main.is_unlocked(17), "room 17 stays locked until room 16 is cleared")
	check(not main.is_unlocked(25), "room 25 stays locked until room 24 is cleared")
	check(not main.is_unlocked(33), "room 33 stays locked until room 32 is cleared")
	check(not main.is_unlocked(41), "room 41 stays locked until room 40 is cleared")
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
		if index == 15:
			check(main.is_unlocked(17), "clearing room 16 unlocks room 17")
			check(not main.is_unlocked(18), "room 18 stays locked until room 17 is cleared")
		if index == 23:
			check(main.is_unlocked(25), "clearing room 24 unlocks room 25")
			check(not main.is_unlocked(26), "room 26 stays locked until room 25 is cleared")
		if index == 31:
			check(main.is_unlocked(33), "clearing room 32 unlocks room 33")
			check(not main.is_unlocked(34), "room 34 stays locked until room 33 is cleared")
		if index == 39:
			check(main.is_unlocked(41), "clearing room 40 unlocks room 41")
			check(not main.is_unlocked(42), "room 42 stays locked until room 41 is cleared")
	check(not main.is_unlocked(49), "there is no room 49 to unlock")
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
