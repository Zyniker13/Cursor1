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
	_test_drop_sends_right()
	_test_drop_refuses_left_and_behind()
	_test_drop_blocked_exit_does_not_send_forward()
	_test_lift_sends_back()
	_test_lift_refuses_above_and_front()
	_test_lift_blocked_exit_does_not_send_right()
	_test_dwell_holds_one_tick()
	_test_dwell_refuses_side_and_front()
	_test_dwell_blocked_does_not_spill()
	_test_twin_waits_for_a_pair()
	_test_twin_refuses_side_front_and_other()
	_test_twin_blocked_does_not_spill()
	_test_pass_waits_until_pushed()
	_test_pass_refuses_side_and_front()
	_test_pass_blocked_does_not_spill()
	_test_slip_keeps_the_first()
	_test_slip_refuses_side_and_front()
	_test_slip_blocked_does_not_spill()
	_test_shed_keeps_the_first()
	_test_shed_refuses_side_and_front()
	_test_shed_blocked_does_not_spill()
	_test_rake_sends_the_waiter()
	_test_rake_refuses_side_and_front()
	_test_rake_blocked_does_not_spill()
	_test_hoe_sends_the_waiter()
	_test_hoe_refuses_side_and_front()
	_test_hoe_blocked_does_not_spill()
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
	_test_wing7_lessons()
	_test_wing8_lessons()
	_test_wing9_lessons()
	_test_wing10_lessons()
	_test_wing11_lessons()
	_test_wing12_lessons()
	_test_wing13_lessons()
	_test_wing14_lessons()
	_test_wing15_lessons()
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
	check(Rules.DWELL_HOLD == 1, "dwell hold is 1 tick past a belt")
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


func _test_drop_sends_right() -> void:
	var room := _drop_lane([Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])
	var placed := [Rooms.piece(Rules.Kind.DROP, 1, 1, Rules.Dir.NORTH)]
	var result := World.simulate(room, placed, 7)
	var again := World.simulate(room, placed, 7)
	var expected := "2:2,1:0|3:2,1:1|4:2,1:2|5:2,1:0|6:2,1:1|7:2,1:2"
	check(_trace(result) == expected, "drop sends every material right, got %s" % _trace(result))
	check(_same(result, again), "the same drop lane is deterministic (seed %d)" % result.seed)
	check(int(result.world.machines[Vector2i(1, 1)].phase) == 0, "a drop does not keep a splitter phase")
	check(_trace(result).find(":1,2:") < 0, "a drop does not send backward, got %s" % _trace(result))
	var arm := World.simulate(room, [Rooms.piece(Rules.Kind.ARM, 1, 1, Rules.Dir.NORTH)], 7)
	check(arm.trace.is_empty(), "an arm on the drop cell does not take a load from above, got %s" % _trace(arm))
	check(int(arm.world.sources[0].pending) == Rules.Mat.ORE, "the refused above load stays on the source")
	var belt := World.simulate(room, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST)], 4)
	check(_trace(belt).begins_with("2:2,1:0"), "a belt can carry that same above load to the right, got %s" % _trace(belt))
	var plates := _drop_lane([Rules.Mat.PLATE])
	var plate_run := World.simulate(plates, placed, 7)
	var plate_again := World.simulate(plates, placed, 7)
	check(_same(plate_run, plate_again), "a drop fed only plates is deterministic")
	check(not _same(result, plate_run), "different drop inputs do not collapse to one output")


func _test_drop_refuses_left_and_behind() -> void:
	var room := {
		"id": 0,
		"name": "drop refuse",
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
		"budget": Rooms.kv([Rules.Kind.DROP, 1, Rules.Kind.BELT, 1]),
		"quota": Rooms.kv([Rules.Mat.PLATE, 1]),
		"initial": [],
		"solution": [],
	}
	var placed := [Rooms.piece(Rules.Kind.DROP, 1, 1, Rules.Dir.NORTH)]
	var result := World.simulate(room, placed, 5)
	check(_trace(result) == "2:2,1:2|3:2,1:2|4:2,1:2|5:2,1:2", "drop passes plates from above, got %s" % _trace(result))
	check(int(result.counts[Rules.Mat.ORE]) == 0 and int(result.world.sources[0].pending) == Rules.Mat.ORE, "drop refuses ore from the left")
	check(int(result.counts[Rules.Mat.INGOT]) == 0 and int(result.world.sources[2].pending) == Rules.Mat.INGOT, "drop refuses an ingot from behind")
	var belt := World.simulate(room, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST)], 4)
	check(int(belt.counts[Rules.Mat.ORE]) > 0, "a belt takes the ore the drop refused, got %s" % _trace(belt))
	var right := {
		"id": 0,
		"name": "drop right",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [
			Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.PLATE], 1),
			Rooms.source(2, 1, Rules.Dir.WEST, [Rules.Mat.INGOT], 1),
		],
		"sinks": [
			Rooms.sink(1, 2, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(0, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.DROP, 1]),
		"quota": Rooms.kv([Rules.Mat.PLATE, 1]),
		"initial": [],
		"solution": [],
	}
	var blocked := World.simulate(right, placed, 5)
	var drop = blocked.world.machines[Vector2i(1, 1)]
	check(int(blocked.counts[Rules.Mat.INGOT]) == 0 and int(blocked.world.sources[1].pending) == Rules.Mat.INGOT, "drop refuses an ingot from the right")
	check(drop.hold == Rules.Mat.PLATE, "the above load stays on the drop while the right is blocked")
	check(blocked.trace.is_empty(), "a blocked right side does not send the plate forward, got %s" % _trace(blocked))


func _test_drop_blocked_exit_does_not_send_forward() -> void:
	var room := _drop_lane([Rules.Mat.ORE])
	room.walls = [Rooms.cell(2, 1)]
	var placed := [Rooms.piece(Rules.Kind.DROP, 1, 1, Rules.Dir.NORTH)]
	var held := World.simulate(room, placed, 6)
	var drop = held.world.machines[Vector2i(1, 1)]
	check(held.trace.is_empty(), "a blocked drop does not deliver, got %s" % _trace(held))
	check(int(held.counts[Rules.Mat.ORE]) == 0, "a blocked drop delivers no ore")
	check(drop.hold == Rules.Mat.ORE, "blocked ore stays on the drop")
	check(int(drop.phase) == 0, "a blocked drop does not advance a phase")
	check(int(held.discarded) == 0, "a blocked drop does not discard")
	var boxed := {
		"id": 0,
		"name": "drop boxed",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [],
		"sinks": [
			Rooms.sink(1, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(0, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [Rooms.cell(2, 1)],
		"walls": [Rooms.cell(1, 2)],
		"budget": Rooms.kv([Rules.Kind.DROP, 1, Rules.Kind.ARM, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var drop_world = World.new()
	drop_world.setup(boxed, [Rooms.piece(Rules.Kind.DROP, 1, 1, Rules.Dir.EAST)])
	drop_world.machines[Vector2i(1, 1)].hold = Rules.Mat.ORE
	drop_world.step()
	check(drop_world.error == "" and drop_world.discarded == 0 and drop_world.trace.is_empty(), "a blocked drop does not send forward into the chute")
	check(drop_world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "the drop still holds the ore")
	check(int(drop_world.counts[Rules.Mat.ORE]) == 0, "the blocked drop did not reach a side sink")
	var arm_world = World.new()
	arm_world.setup(boxed, [Rooms.piece(Rules.Kind.ARM, 1, 1, Rules.Dir.EAST)])
	arm_world.machines[Vector2i(1, 1)].hold = Rules.Mat.ORE
	arm_world.step()
	check(arm_world.discarded == 1 and arm_world.machines[Vector2i(1, 1)].hold < 0, "the same cell lets an arm send forward into the chute")


func _test_lift_sends_back() -> void:
	var room := _lift_lane([Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])
	var placed := [Rooms.piece(Rules.Kind.LIFT, 1, 1, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 7)
	var again := World.simulate(room, placed, 7)
	var expected := "2:0,1:0|3:0,1:1|4:0,1:2|5:0,1:0|6:0,1:1|7:0,1:2"
	check(_trace(result) == expected, "lift sends every material back, got %s" % _trace(result))
	check(_same(result, again), "the same lift lane is deterministic (seed %d)" % result.seed)
	check(int(result.world.machines[Vector2i(1, 1)].phase) == 0, "a lift does not keep a splitter phase")
	check(_trace(result).find(":2,1:") < 0, "a lift does not send forward, got %s" % _trace(result))
	check(_trace(result).find(":1,2:") < 0, "a lift does not send right, got %s" % _trace(result))
	var drop := World.simulate(room, [Rooms.piece(Rules.Kind.DROP, 1, 1, Rules.Dir.EAST)], 7)
	check(drop.trace.is_empty(), "a drop on the lift cell does not take a load from below, got %s" % _trace(drop))
	check(int(drop.world.sources[0].pending) == Rules.Mat.ORE, "the refused below load stays on the source")
	var belt := World.simulate(room, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.WEST)], 4)
	check(_trace(belt).begins_with("2:0,1:0"), "a belt can carry that same below load back, got %s" % _trace(belt))
	var plates := _lift_lane([Rules.Mat.PLATE])
	var plate_run := World.simulate(plates, placed, 7)
	var plate_again := World.simulate(plates, placed, 7)
	check(_same(plate_run, plate_again), "a lift fed only plates is deterministic")
	check(not _same(result, plate_run), "different lift inputs do not collapse to one output")


func _test_lift_refuses_above_and_front() -> void:
	var room := {
		"id": 0,
		"name": "lift refuse",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [
			Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.PLATE], 1),
			Rooms.source(1, 2, Rules.Dir.NORTH, [Rules.Mat.ORE], 1),
			Rooms.source(2, 1, Rules.Dir.WEST, [Rules.Mat.INGOT], 1),
		],
		"sinks": [Rooms.sink(0, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.LIFT, 1, Rules.Kind.BELT, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var placed := [Rooms.piece(Rules.Kind.LIFT, 1, 1, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 5)
	check(_trace(result) == "2:0,1:0|3:0,1:0|4:0,1:0|5:0,1:0", "lift passes ore from below, got %s" % _trace(result))
	check(int(result.counts[Rules.Mat.PLATE]) == 0 and int(result.world.sources[0].pending) == Rules.Mat.PLATE, "lift refuses a plate from above")
	check(int(result.counts[Rules.Mat.INGOT]) == 0 and int(result.world.sources[2].pending) == Rules.Mat.INGOT, "lift refuses a head-on ingot")
	var belt := World.simulate(room, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.WEST)], 4)
	check(int(belt.counts[Rules.Mat.PLATE]) > 0, "a belt takes the plate the lift refused, got %s" % _trace(belt))
	var behind := {
		"id": 0,
		"name": "lift behind",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [
			Rooms.source(0, 1, Rules.Dir.EAST, [Rules.Mat.INGOT], 1),
			Rooms.source(1, 2, Rules.Dir.NORTH, [Rules.Mat.ORE], 1),
		],
		"sinks": [
			Rooms.sink(1, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.LIFT, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var blocked := World.simulate(behind, placed, 5)
	var lift = blocked.world.machines[Vector2i(1, 1)]
	check(int(blocked.counts[Rules.Mat.INGOT]) == 0 and int(blocked.world.sources[0].pending) == Rules.Mat.INGOT, "lift refuses an ingot from behind")
	check(lift.hold == Rules.Mat.ORE, "the below load stays on the lift while the back is blocked")
	check(blocked.trace.is_empty(), "a blocked back exit does not send the ore right, got %s" % _trace(blocked))


func _test_lift_blocked_exit_does_not_send_right() -> void:
	var room := _lift_lane([Rules.Mat.ORE])
	room.walls = [Rooms.cell(0, 1)]
	var placed := [Rooms.piece(Rules.Kind.LIFT, 1, 1, Rules.Dir.EAST)]
	var held := World.simulate(room, placed, 6)
	var lift = held.world.machines[Vector2i(1, 1)]
	check(held.trace.is_empty(), "a blocked lift does not deliver, got %s" % _trace(held))
	check(int(held.counts[Rules.Mat.ORE]) == 0, "a blocked lift delivers no ore")
	check(lift.hold == Rules.Mat.ORE, "blocked ore stays on the lift")
	check(int(lift.phase) == 0, "a blocked lift does not advance a phase")
	check(int(held.discarded) == 0, "a blocked lift does not discard")
	var boxed := {
		"id": 0,
		"name": "lift boxed",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [],
		"sinks": [
			Rooms.sink(1, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [Rooms.cell(1, 2)],
		"walls": [Rooms.cell(0, 1)],
		"budget": Rooms.kv([Rules.Kind.LIFT, 1, Rules.Kind.DROP, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var lift_world = World.new()
	lift_world.setup(boxed, [Rooms.piece(Rules.Kind.LIFT, 1, 1, Rules.Dir.EAST)])
	lift_world.machines[Vector2i(1, 1)].hold = Rules.Mat.ORE
	lift_world.step()
	check(lift_world.error == "" and lift_world.discarded == 0 and lift_world.trace.is_empty(), "a blocked lift does not send right into the chute")
	check(lift_world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "the lift still holds the ore")
	check(int(lift_world.counts[Rules.Mat.ORE]) == 0, "the blocked lift did not reach a side sink")
	var drop_world = World.new()
	drop_world.setup(boxed, [Rooms.piece(Rules.Kind.DROP, 1, 1, Rules.Dir.EAST)])
	drop_world.machines[Vector2i(1, 1)].hold = Rules.Mat.ORE
	drop_world.step()
	check(drop_world.discarded == 1 and drop_world.machines[Vector2i(1, 1)].hold < 0, "the same cell lets a drop send right into the chute")


func _lift_lane(pattern: Array) -> Dictionary:
	return {
		"id": 0,
		"name": "lift",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [Rooms.source(1, 2, Rules.Dir.NORTH, pattern, 1)],
		"sinks": [
			Rooms.sink(0, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(1, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.LIFT, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}


func _drop_lane(pattern: Array) -> Dictionary:
	return {
		"id": 0,
		"name": "drop",
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
		"budget": Rooms.kv([Rules.Kind.DROP, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}


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
	check(catalog.size() == 120, "fifteen wings have 120 rooms")
	check(catalog[0].name == "Haul" and catalog[7].name == "Two Orders", "rooms 1 through 8 stay the first wing")
	check(catalog[8].name == "Straight" and catalog[15].name == "Balance", "rooms 9 through 16 are the second wing")
	check(catalog[16].name == "Span" and catalog[23].name == "Ledger", "rooms 17 through 24 are the third wing")
	check(catalog[24].name == "Screen" and catalog[31].name == "Reckon", "rooms 25 through 32 are the fourth wing")
	check(catalog[32].name == "Veer" and catalog[39].name == "Tally", "rooms 33 through 40 are the fifth wing")
	check(catalog[40].name == "Reach" and catalog[47].name == "Audit", "rooms 41 through 48 are the sixth wing")
	check(catalog[48].name == "Fall" and catalog[55].name == "Yield", "rooms 49 through 56 are the seventh wing")
	check(catalog[56].name == "Hoist" and catalog[63].name == "Remit", "rooms 57 through 64 are the eighth wing")
	check(catalog[64].name == "Pause" and catalog[71].name == "Both Bins", "rooms 65 through 72 are the ninth wing")
	check(catalog[72].name == "Pair" and catalog[79].name == "Both Bins", "rooms 73 through 80 are the tenth wing")
	check(catalog[80].name == "Pair" and catalog[87].name == "Both Bins", "rooms 81 through 88 are the eleventh wing")
	check(catalog[88].name == "Hold" and catalog[95].name == "One Bin", "rooms 89 through 96 are the twelfth wing")
	check(catalog[96].name == "Aside" and catalog[103].name == "Side Bin", "rooms 97 through 104 are the thirteenth wing")
	check(catalog[104].name == "Draw Left" and catalog[111].name == "Side Bin", "rooms 105 through 112 are the fourteenth wing")
	check(catalog[112].name == "Draw Right" and catalog[119].name == "Side Bin", "rooms 113 through 120 are the fifteenth wing")
	for index in catalog.size():
		var bridge_count := int(catalog[index].budget.get(Rules.Kind.BRIDGE, 0))
		var grate_count := int(catalog[index].budget.get(Rules.Kind.GRATE, 0))
		var hook_count := int(catalog[index].budget.get(Rules.Kind.HOOK, 0))
		var arm_count := int(catalog[index].budget.get(Rules.Kind.ARM, 0))
		var drop_count := int(catalog[index].budget.get(Rules.Kind.DROP, 0))
		var lift_count := int(catalog[index].budget.get(Rules.Kind.LIFT, 0))
		var dwell_count := int(catalog[index].budget.get(Rules.Kind.DWELL, 0))
		var twin_count := int(catalog[index].budget.get(Rules.Kind.TWIN, 0))
		var pass_count := int(catalog[index].budget.get(Rules.Kind.PASS, 0))
		var slip_count := int(catalog[index].budget.get(Rules.Kind.SLIP, 0))
		var shed_count := int(catalog[index].budget.get(Rules.Kind.SHED, 0))
		var rake_count := int(catalog[index].budget.get(Rules.Kind.RAKE, 0))
		var hoe_count := int(catalog[index].budget.get(Rules.Kind.HOE, 0))
		if index < 112:
			check(hoe_count == 0, "room %d does not use the hoe" % (index + 1))
		if index < 104:
			check(rake_count == 0, "room %d does not use the rake" % (index + 1))
		if index < 96:
			check(shed_count == 0, "room %d does not use the shed" % (index + 1))
		if index < 88:
			check(slip_count == 0, "room %d does not use the slip" % (index + 1))
		if index < 80:
			check(pass_count == 0, "room %d does not use the pass" % (index + 1))
		if index < 64:
			check(dwell_count == 0, "room %d does not use the dwell" % (index + 1))
		if index < 72:
			check(twin_count == 0, "room %d does not use the twin" % (index + 1))
		if index < 16:
			check(bridge_count == 0, "room %d does not use the bridge" % (index + 1))
			check(grate_count == 0, "room %d does not use the grate" % (index + 1))
			check(hook_count == 0, "room %d does not use the hook" % (index + 1))
			check(arm_count == 0, "room %d does not use the arm" % (index + 1))
			check(drop_count == 0, "room %d does not use the drop" % (index + 1))
			check(lift_count == 0, "room %d does not use the lift" % (index + 1))
		elif index < 24:
			check(bridge_count >= 1, "room %d depends on the bridge" % (index + 1))
			check(grate_count == 0, "room %d does not use the grate" % (index + 1))
			check(hook_count == 0, "room %d does not use the hook" % (index + 1))
			check(arm_count == 0, "room %d does not use the arm" % (index + 1))
			check(drop_count == 0, "room %d does not use the drop" % (index + 1))
			check(lift_count == 0, "room %d does not use the lift" % (index + 1))
		elif index < 32:
			check(grate_count >= 1, "room %d depends on the grate" % (index + 1))
			check(hook_count == 0, "room %d does not use the hook" % (index + 1))
			check(arm_count == 0, "room %d does not use the arm" % (index + 1))
			check(drop_count == 0, "room %d does not use the drop" % (index + 1))
			check(lift_count == 0, "room %d does not use the lift" % (index + 1))
		elif index < 40:
			check(hook_count >= 1, "room %d depends on the hook" % (index + 1))
			check(arm_count == 0, "room %d does not use the arm" % (index + 1))
			check(drop_count == 0, "room %d does not use the drop" % (index + 1))
			check(lift_count == 0, "room %d does not use the lift" % (index + 1))
		elif index < 48:
			check(arm_count >= 1, "room %d depends on the arm" % (index + 1))
			check(drop_count == 0, "room %d does not use the drop" % (index + 1))
			check(lift_count == 0, "room %d does not use the lift" % (index + 1))
		elif index < 56:
			check(drop_count >= 1, "room %d depends on the drop" % (index + 1))
			check(arm_count == 0, "room %d does not use the arm" % (index + 1))
			check(lift_count == 0, "room %d does not use the lift" % (index + 1))
		elif index < 64:
			check(lift_count >= 1, "room %d depends on the lift" % (index + 1))
			check(drop_count == 0, "room %d does not use the drop" % (index + 1))
			check(arm_count == 0, "room %d does not use the arm" % (index + 1))
		elif index < 72:
			check(dwell_count >= 1, "room %d depends on the dwell" % (index + 1))
			check(lift_count == 0, "room %d does not use the lift" % (index + 1))
			check(drop_count == 0, "room %d does not use the drop" % (index + 1))
			check(arm_count == 0, "room %d does not use the arm" % (index + 1))
			check(hook_count == 0, "room %d does not use the hook" % (index + 1))
		elif index < 80:
			check(twin_count >= 1, "room %d depends on the twin" % (index + 1))
			check(dwell_count == 0, "room %d does not use the dwell" % (index + 1))
			check(lift_count == 0, "room %d does not use the lift" % (index + 1))
			check(drop_count == 0, "room %d does not use the drop" % (index + 1))
			check(arm_count == 0, "room %d does not use the arm" % (index + 1))
			check(hook_count == 0, "room %d does not use the hook" % (index + 1))
		elif index < 88:
			check(pass_count >= 1, "room %d depends on the pass" % (index + 1))
			check(twin_count == 0, "room %d does not use the twin" % (index + 1))
			check(dwell_count == 0, "room %d does not use the dwell" % (index + 1))
			check(lift_count == 0, "room %d does not use the lift" % (index + 1))
			check(drop_count == 0, "room %d does not use the drop" % (index + 1))
			check(arm_count == 0, "room %d does not use the arm" % (index + 1))
			check(hook_count == 0, "room %d does not use the hook" % (index + 1))
		elif index < 96:
			check(slip_count >= 1, "room %d depends on the slip" % (index + 1))
			check(pass_count == 0, "room %d does not use the pass" % (index + 1))
			check(twin_count == 0, "room %d does not use the twin" % (index + 1))
			check(dwell_count == 0, "room %d does not use the dwell" % (index + 1))
			check(lift_count == 0, "room %d does not use the lift" % (index + 1))
			check(drop_count == 0, "room %d does not use the drop" % (index + 1))
			check(arm_count == 0, "room %d does not use the arm" % (index + 1))
			check(hook_count == 0, "room %d does not use the hook" % (index + 1))
		elif index < 104:
			check(shed_count >= 1, "room %d depends on the shed" % (index + 1))
			check(slip_count == 0, "room %d does not use the slip" % (index + 1))
			check(pass_count == 0, "room %d does not use the pass" % (index + 1))
			check(twin_count == 0, "room %d does not use the twin" % (index + 1))
			check(dwell_count == 0, "room %d does not use the dwell" % (index + 1))
			check(lift_count == 0, "room %d does not use the lift" % (index + 1))
			check(drop_count == 0, "room %d does not use the drop" % (index + 1))
			check(arm_count == 0, "room %d does not use the arm" % (index + 1))
			check(hook_count == 0, "room %d does not use the hook" % (index + 1))
		elif index < 112:
			check(rake_count >= 1, "room %d depends on the rake" % (index + 1))
			check(hoe_count == 0, "room %d does not use the hoe" % (index + 1))
			check(shed_count == 0, "room %d does not use the shed" % (index + 1))
			check(slip_count == 0, "room %d does not use the slip" % (index + 1))
			check(pass_count == 0, "room %d does not use the pass" % (index + 1))
			check(twin_count == 0, "room %d does not use the twin" % (index + 1))
			check(dwell_count == 0, "room %d does not use the dwell" % (index + 1))
			check(lift_count == 0, "room %d does not use the lift" % (index + 1))
			check(drop_count == 0, "room %d does not use the drop" % (index + 1))
			check(arm_count == 0, "room %d does not use the arm" % (index + 1))
			check(hook_count == 0, "room %d does not use the hook" % (index + 1))
		else:
			check(hoe_count >= 1, "room %d depends on the hoe" % (index + 1))
			check(rake_count == 0, "room %d does not use the rake" % (index + 1))
			check(shed_count == 0, "room %d does not use the shed" % (index + 1))
			check(slip_count == 0, "room %d does not use the slip" % (index + 1))
			check(pass_count == 0, "room %d does not use the pass" % (index + 1))
			check(twin_count == 0, "room %d does not use the twin" % (index + 1))
			check(dwell_count == 0, "room %d does not use the dwell" % (index + 1))
			check(lift_count == 0, "room %d does not use the lift" % (index + 1))
			check(drop_count == 0, "room %d does not use the drop" % (index + 1))
			check(arm_count == 0, "room %d does not use the arm" % (index + 1))
			check(hook_count == 0, "room %d does not use the hook" % (index + 1))
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
	var perch: Dictionary = Rooms.all()[51]
	var seated = Planner.new(perch)
	check(seated.at(0, 1) != null and seated.remaining(Rules.Kind.DROP) == 0, "perch starts with the drop off the tray")
	check(seated.pickup(0, 1), "pickup lifts the pre-placed drop")
	check(seated.at(0, 1) == null and seated.remaining(Rules.Kind.DROP) == 1, "pre-placed drop returns to the tray")
	check(seated.place(Rules.Kind.DROP, 3, 1, Rules.Dir.NORTH), "the returned drop can be seated on the lane")
	var sling: Dictionary = Rooms.all()[59]
	var slung = Planner.new(sling)
	check(slung.at(0, 1) != null and slung.remaining(Rules.Kind.LIFT) == 0, "sling starts with the lift off the tray")
	check(slung.pickup(0, 1), "pickup lifts the pre-placed lift")
	check(slung.at(0, 1) == null and slung.remaining(Rules.Kind.LIFT) == 1, "pre-placed lift returns to the tray")
	check(slung.place(Rules.Kind.LIFT, 3, 1, Rules.Dir.EAST), "the returned lift can be seated on the lane")
	var late: Dictionary = Rooms.all()[67]
	var waited = Planner.new(late)
	check(waited.at(0, 2) != null and waited.remaining(Rules.Kind.DWELL) == 0, "late starts with the dwell off the tray")
	check(waited.pickup(0, 2), "pickup lifts the pre-placed dwell")
	check(waited.at(0, 2) == null and waited.remaining(Rules.Kind.DWELL) == 1, "pre-placed dwell returns to the tray")
	check(waited.place(Rules.Kind.DWELL, 3, 1, Rules.Dir.EAST), "the returned dwell can be seated on the lane")
	var late_pair: Dictionary = Rooms.all()[75]
	var paired = Planner.new(late_pair)
	check(paired.at(0, 4) != null and paired.remaining(Rules.Kind.TWIN) == 0, "late starts with the twin off the tray")
	check(paired.pickup(0, 4), "pickup lifts the pre-placed twin")
	check(paired.at(0, 4) == null and paired.remaining(Rules.Kind.TWIN) == 1, "pre-placed twin returns to the tray")
	check(paired.place(Rules.Kind.TWIN, 1, 3, Rules.Dir.EAST), "the returned twin can be seated on the lane")
	var late_pass: Dictionary = Rooms.all()[83]
	var passed_piece = Planner.new(late_pass)
	check(passed_piece.at(0, 4) != null and passed_piece.remaining(Rules.Kind.PASS) == 0, "late starts with the pass off the tray")
	check(passed_piece.pickup(0, 4), "pickup lifts the pre-placed pass")
	check(passed_piece.at(0, 4) == null and passed_piece.remaining(Rules.Kind.PASS) == 1, "pre-placed pass returns to the tray")
	check(passed_piece.place(Rules.Kind.PASS, 1, 3, Rules.Dir.EAST), "the returned pass can be seated on the lane")


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


func _test_wing7_lessons() -> void:
	var fall: Dictionary = Rooms.all()[48]
	var fall_belt: Array = [
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.DROP, 0, 1, Rules.Dir.NORTH),
	]
	var fall_run: Dictionary = World.simulate(fall, fall_belt)
	check(World.budget_met(fall_belt, fall.budget), "belt on the fall lane stays inside the tray")
	check(int(fall_run.counts[Rules.Mat.PLATE]) == 0, "belt on the fall lane delivers no plate (%s)" % fall_run.text)
	check(not fall_run.quota_ok, "belt on the fall lane misses the quota")
	var pour: Dictionary = Rooms.all()[49]
	var pour_belt: Array = [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.DROP, 0, 0, Rules.Dir.NORTH),
	]
	var pour_run: Dictionary = World.simulate(pour, pour_belt)
	check(World.budget_met(pour_belt, pour.budget), "belt on the pour lane stays inside the tray")
	check(int(pour_run.counts[Rules.Mat.INGOT]) == 0, "belt on the pour lane delivers no ingot (%s)" % pour_run.text)
	check(not pour_run.success, "a plate against the pour kiln misses")
	var pare: Dictionary = Rooms.all()[50]
	var dumped_pieces: Array = [
		Rooms.piece(Rules.Kind.BELT, 1, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 1, 2, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.DROP, 0, 2, Rules.Dir.WEST),
	]
	var dumped: Dictionary = World.simulate(pare, dumped_pieces)
	var pared: Dictionary = World.simulate(pare, pare.solution)
	check(World.budget_met(dumped_pieces, pare.budget), "pare's belt on the drop cell stays inside the tray")
	check(int(dumped.counts[Rules.Mat.INGOT]) == 0 and int(dumped.discarded) > 0, "pare's pit eats the ore (%s discarded %d)" % [dumped.text, dumped.discarded])
	check(not dumped.success, "ore in the pit misses pare")
	check(int(pared.counts[Rules.Mat.INGOT]) >= int(pare.quota[Rules.Mat.INGOT]) and int(pared.discarded) == 0, "pare's drop keeps the ore out of the pit (%s discarded %d)" % [pared.text, pared.discarded])
	var perch: Dictionary = Rooms.all()[51]
	var parked: Array = perch.initial.duplicate(true)
	parked.append(Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST))
	var gap: Dictionary = World.simulate(perch, parked)
	check(World.budget_met(parked, perch.budget), "leaving the perch drop parked stays inside the tray")
	check(int(gap.counts[Rules.Mat.PLATE]) == 0 and not gap.quota_ok, "a parked drop leaves the lane to a belt and misses (%s)" % gap.text)
	var skirt: Dictionary = Rooms.all()[52]
	var into_wall: Dictionary = World.simulate(skirt, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 0, Rules.Dir.SOUTH),
	])
	check(int(into_wall.counts[Rules.Mat.PLATE]) == 0, "skirt belts that run into the wall deliver nothing")
	var swapped_pieces: Array = [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 0, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.DROP, 4, 1, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.BELT, 4, 2, Rules.Dir.EAST),
	]
	var swapped: Dictionary = World.simulate(skirt, swapped_pieces)
	check(World.budget_met(swapped_pieces, skirt.budget), "skirt's belt on the drop cell stays inside the tray")
	check(int(swapped.counts[Rules.Mat.PLATE]) == 0, "a belt on the skirt lane delivers no plate (%s)" % swapped.text)
	var gush: Dictionary = Rooms.all()[53]
	var one_kiln: Dictionary = World.simulate(gush, [
		Rooms.piece(Rules.Kind.BELT, 1, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.DROP, 2, 4, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.KILN, 2, 2, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.NORTH),
	])
	var both: Dictionary = World.simulate(gush, gush.solution)
	var gush_quota := int(gush.quota[Rules.Mat.INGOT])
	check(int(one_kiln.counts[Rules.Mat.INGOT]) < gush_quota, "one gush kiln misses %d (%s)" % [gush_quota, one_kiln.text])
	check(int(both.counts[Rules.Mat.INGOT]) >= gush_quota, "both gush kilns reach the quota (%s)" % both.text)
	check(int(both.counts[Rules.Mat.INGOT]) > int(one_kiln.counts[Rules.Mat.INGOT]), "the gush spill kiln adds ingots")
	var clogged_pieces: Array = [
		Rooms.piece(Rules.Kind.BELT, 1, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 4, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.KILN, 2, 2, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.NORTH),
	]
	var clogged: Dictionary = World.simulate(gush, clogged_pieces)
	check(World.budget_met(clogged_pieces, gush.budget), "gush's belt in place of the drop stays inside the tray")
	check(int(clogged.counts[Rules.Mat.INGOT]) == 0, "gush without a drop delivers nothing (%s)" % clogged.text)
	var rake: Dictionary = Rooms.all()[54]
	var raked: Dictionary = World.simulate(rake, rake.solution)
	check(int(raked.counts[Rules.Mat.INGOT]) >= int(rake.quota[Rules.Mat.INGOT]) and int(raked.discarded) > 0, "rake counts kiln ingots and discards the raw ones (%s discarded %d)" % [raked.text, raked.discarded])
	var no_filter: Dictionary = World.simulate(rake, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.DROP, 3, 2, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.KILN, 4, 2, Rules.Dir.EAST),
	])
	check(int(no_filter.counts[Rules.Mat.INGOT]) < int(rake.quota[Rules.Mat.INGOT]), "rake without a filter misses (%s)" % no_filter.text)
	var no_drop_pieces: Array = [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.FILTER, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 4, 2, Rules.Dir.EAST),
	]
	var no_drop: Dictionary = World.simulate(rake, no_drop_pieces)
	check(World.budget_met(no_drop_pieces, rake.budget), "rake's belt on the drop cell stays inside the tray")
	check(int(no_drop.counts[Rules.Mat.INGOT]) == 0, "a belt on the rake lane delivers no ingot (%s)" % no_drop.text)
	var no_kiln: Dictionary = World.simulate(rake, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.FILTER, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.DROP, 3, 2, Rules.Dir.NORTH),
	])
	check(int(no_kiln.counts[Rules.Mat.INGOT]) == 0, "rake without a kiln delivers no ingot (%s)" % no_kiln.text)
	var yield_room: Dictionary = Rooms.all()[55]
	var solved: Dictionary = World.simulate(yield_room, yield_room.solution)
	check(int(solved.counts[Rules.Mat.INGOT]) >= int(yield_room.quota[Rules.Mat.INGOT]) and int(solved.counts[Rules.Mat.PLATE]) >= int(yield_room.quota[Rules.Mat.PLATE]), "yield hits both quotas (%s)" % solved.text)
	var plates_only: Dictionary = World.simulate(yield_room, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
	])
	check(int(plates_only.counts[Rules.Mat.INGOT]) == 0 and int(plates_only.counts[Rules.Mat.PLATE]) < int(yield_room.quota[Rules.Mat.PLATE]), "yield's upper plates alone miss (%s)" % plates_only.text)
	check(not plates_only.success, "upper plates alone miss yield")
	var pressed: Dictionary = World.simulate(yield_room, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.DROP, 1, 2, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.KILN, 2, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.PRESS, 4, 3, Rules.Dir.EAST),
	])
	check(int(pressed.counts[Rules.Mat.INGOT]) == 0 and int(pressed.counts[Rules.Mat.PLATE]) > 0, "yield without the splitter is plates only (%s)" % pressed.text)
	check(not pressed.success, "plates alone miss yield")
	var undropped_pieces: Array = [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 1, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 2, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.SPLITTER, 3, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 2, Rules.Dir.EAST),
	]
	var undropped: Dictionary = World.simulate(yield_room, undropped_pieces)
	check(World.budget_met(undropped_pieces, yield_room.budget), "yield's belt in place of the drop stays inside the tray")
	check(int(undropped.counts[Rules.Mat.INGOT]) < int(yield_room.quota[Rules.Mat.INGOT]) and int(undropped.counts[Rules.Mat.PLATE]) < int(yield_room.quota[Rules.Mat.PLATE]), "a belt in place of the yield drop misses (%s)" % undropped.text)
	check(not undropped.success, "a belt in place of the yield drop does not clear")


func _test_wing8_lessons() -> void:
	var hoist: Dictionary = Rooms.all()[56]
	var hoist_belt: Array = [
		Rooms.piece(Rules.Kind.BELT, 1, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.LIFT, 0, 0, Rules.Dir.EAST),
	]
	var hoist_run: Dictionary = World.simulate(hoist, hoist_belt)
	check(World.budget_met(hoist_belt, hoist.budget), "belt on the hoist lane stays inside the tray")
	check(int(hoist_run.counts[Rules.Mat.PLATE]) == 0, "belt on the hoist lane delivers no plate (%s)" % hoist_run.text)
	check(not hoist_run.quota_ok, "belt on the hoist lane misses the quota")
	var raise_room: Dictionary = Rooms.all()[57]
	var raise_belt: Array = [
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.KILN, 3, 1, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.BELT, 4, 1, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.LIFT, 0, 0, Rules.Dir.EAST),
	]
	var raise_run: Dictionary = World.simulate(raise_room, raise_belt)
	check(World.budget_met(raise_belt, raise_room.budget), "belt on the raise lane stays inside the tray")
	check(int(raise_run.counts[Rules.Mat.INGOT]) == 0, "belt on the raise lane delivers no ingot (%s)" % raise_run.text)
	check(not raise_run.success, "a plate against the raise kiln misses")
	var cinch: Dictionary = Rooms.all()[58]
	var dumped_pieces: Array = [
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 2, 1, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.LIFT, 0, 2, Rules.Dir.EAST),
	]
	var dumped: Dictionary = World.simulate(cinch, dumped_pieces)
	var cinched: Dictionary = World.simulate(cinch, cinch.solution)
	check(World.budget_met(dumped_pieces, cinch.budget), "cinch's belt on the lift cell stays inside the tray")
	check(int(dumped.counts[Rules.Mat.INGOT]) == 0 and int(dumped.discarded) > 0, "cinch's pit eats the ore (%s discarded %d)" % [dumped.text, dumped.discarded])
	check(not dumped.success, "ore in the pit misses cinch")
	check(int(cinched.counts[Rules.Mat.INGOT]) >= int(cinch.quota[Rules.Mat.INGOT]) and int(cinched.discarded) == 0, "cinch's lift keeps the ore out of the pit (%s discarded %d)" % [cinched.text, cinched.discarded])
	var sling: Dictionary = Rooms.all()[59]
	var parked: Array = sling.initial.duplicate(true)
	parked.append(Rooms.piece(Rules.Kind.BELT, 1, 2, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 2, 2, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.WEST))
	var gap: Dictionary = World.simulate(sling, parked)
	check(World.budget_met(parked, sling.budget), "leaving the sling lift parked stays inside the tray")
	check(int(gap.counts[Rules.Mat.PLATE]) == 0 and not gap.quota_ok, "a parked lift leaves the lane to a belt and misses (%s)" % gap.text)
	var flank: Dictionary = Rooms.all()[60]
	var into_wall: Dictionary = World.simulate(flank, [
		Rooms.piece(Rules.Kind.BELT, 1, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 3, Rules.Dir.NORTH),
	])
	check(int(into_wall.counts[Rules.Mat.PLATE]) == 0, "flank belts that run into the wall deliver nothing")
	var swapped_pieces: Array = [
		Rooms.piece(Rules.Kind.BELT, 1, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.LIFT, 4, 2, Rules.Dir.EAST),
	]
	var swapped: Dictionary = World.simulate(flank, swapped_pieces)
	check(World.budget_met(swapped_pieces, flank.budget), "flank's belt on the lift cell stays inside the tray")
	check(int(swapped.counts[Rules.Mat.PLATE]) == 0, "a belt on the flank lane delivers no plate (%s)" % swapped.text)
	var spurt: Dictionary = Rooms.all()[61]
	var one_kiln: Dictionary = World.simulate(spurt, [
		Rooms.piece(Rules.Kind.BELT, 4, 2, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.LIFT, 4, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.WEIR, 3, 1, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.KILN, 2, 1, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.WEST),
	])
	var both: Dictionary = World.simulate(spurt, spurt.solution)
	var spurt_quota := int(spurt.quota[Rules.Mat.INGOT])
	check(int(one_kiln.counts[Rules.Mat.INGOT]) < spurt_quota, "one spurt kiln misses %d (%s)" % [spurt_quota, one_kiln.text])
	check(int(both.counts[Rules.Mat.INGOT]) >= spurt_quota, "both spurt kilns reach the quota (%s)" % both.text)
	check(int(both.counts[Rules.Mat.INGOT]) > int(one_kiln.counts[Rules.Mat.INGOT]), "the spurt spill kiln adds ingots")
	var clogged_pieces: Array = [
		Rooms.piece(Rules.Kind.BELT, 4, 2, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.BELT, 4, 1, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.WEIR, 3, 1, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.KILN, 2, 1, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.WEST),
	]
	var clogged: Dictionary = World.simulate(spurt, clogged_pieces)
	check(World.budget_met(clogged_pieces, spurt.budget), "spurt's belt in place of the lift stays inside the tray")
	check(int(clogged.counts[Rules.Mat.INGOT]) == 0, "spurt without a lift delivers nothing (%s)" % clogged.text)
	var glean: Dictionary = Rooms.all()[62]
	var gleaned: Dictionary = World.simulate(glean, glean.solution)
	check(int(gleaned.counts[Rules.Mat.INGOT]) >= int(glean.quota[Rules.Mat.INGOT]) and int(gleaned.discarded) > 0, "glean counts kiln ingots and discards the raw ones (%s discarded %d)" % [gleaned.text, gleaned.discarded])
	var no_filter: Dictionary = World.simulate(glean, [
		Rooms.piece(Rules.Kind.BELT, 1, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 3, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.BELT, 2, 2, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.LIFT, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 1, 1, Rules.Dir.WEST),
	])
	check(int(no_filter.counts[Rules.Mat.INGOT]) < int(glean.quota[Rules.Mat.INGOT]), "glean without a filter misses (%s)" % no_filter.text)
	var no_lift_pieces: Array = [
		Rooms.piece(Rules.Kind.FILTER, 1, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 3, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.KILN, 1, 1, Rules.Dir.WEST),
	]
	var no_lift: Dictionary = World.simulate(glean, no_lift_pieces)
	check(World.budget_met(no_lift_pieces, glean.budget), "glean's belt on the lift cell stays inside the tray")
	check(int(no_lift.counts[Rules.Mat.INGOT]) == 0, "a belt on the glean lane delivers no ingot (%s)" % no_lift.text)
	var no_kiln: Dictionary = World.simulate(glean, [
		Rooms.piece(Rules.Kind.FILTER, 1, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 3, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.BELT, 2, 2, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.LIFT, 2, 1, Rules.Dir.EAST),
	])
	check(int(no_kiln.counts[Rules.Mat.INGOT]) == 0, "glean without a kiln delivers no ingot (%s)" % no_kiln.text)
	var remit: Dictionary = Rooms.all()[63]
	var solved: Dictionary = World.simulate(remit, remit.solution)
	check(int(solved.counts[Rules.Mat.INGOT]) >= int(remit.quota[Rules.Mat.INGOT]) and int(solved.counts[Rules.Mat.PLATE]) >= int(remit.quota[Rules.Mat.PLATE]), "remit hits both quotas (%s)" % solved.text)
	var plates_only: Dictionary = World.simulate(remit, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.WEST),
	])
	check(int(plates_only.counts[Rules.Mat.INGOT]) == 0 and int(plates_only.counts[Rules.Mat.PLATE]) < int(remit.quota[Rules.Mat.PLATE]), "remit's upper plates alone miss (%s)" % plates_only.text)
	check(not plates_only.success, "upper plates alone miss remit")
	var pressed: Dictionary = World.simulate(remit, [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.LIFT, 4, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 3, 2, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.BELT, 2, 2, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.PRESS, 1, 1, Rules.Dir.WEST),
	])
	check(int(pressed.counts[Rules.Mat.INGOT]) == 0 and int(pressed.counts[Rules.Mat.PLATE]) > 0, "remit without the splitter is plates only (%s)" % pressed.text)
	check(not pressed.success, "plates alone miss remit")
	var unlifted_pieces: Array = [
		Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.BELT, 2, 0, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.BELT, 4, 2, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.KILN, 3, 2, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.SPLITTER, 2, 2, Rules.Dir.WEST),
		Rooms.piece(Rules.Kind.BELT, 1, 2, Rules.Dir.WEST),
	]
	var unlifted: Dictionary = World.simulate(remit, unlifted_pieces)
	check(World.budget_met(unlifted_pieces, remit.budget), "remit's belt in place of the lift stays inside the tray")
	check(int(unlifted.counts[Rules.Mat.INGOT]) < int(remit.quota[Rules.Mat.INGOT]) and int(unlifted.counts[Rules.Mat.PLATE]) < int(remit.quota[Rules.Mat.PLATE]), "a belt in place of the remit lift misses (%s)" % unlifted.text)
	check(not unlifted.success, "a belt in place of the remit lift does not clear")


func _test_dwell_holds_one_tick() -> void:
	var room := _dwell_lane([Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])
	var placed := [Rooms.piece(Rules.Kind.DWELL, 1, 1, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 7)
	var again := World.simulate(room, placed, 7)
	var expected := "3:2,1:0|5:2,1:1|7:2,1:2"
	check(_trace(result) == expected, "dwell sends every material one tick after a belt would, got %s" % _trace(result))
	check(_same(result, again), "the same dwell lane is deterministic (seed %d)" % result.seed)
	check(int(result.counts[Rules.Mat.ORE]) == 1 and int(result.counts[Rules.Mat.INGOT]) == 1 and int(result.counts[Rules.Mat.PLATE]) == 1, "dwell passes ore, ingot, and plate")
	check(_trace(result).find(":1,0:") < 0 and _trace(result).find(":1,2:") < 0, "a dwell does not send to the side, got %s" % _trace(result))
	check(int(result.world.machines[Vector2i(1, 1)].phase) <= Rules.DWELL_HOLD, "a dwell hold counter stays at the extra tick")
	var belt := World.simulate(room, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST)], 6)
	check(_trace(belt) == "2:2,1:0|3:2,1:1|4:2,1:2|5:2,1:0|6:2,1:1", "a belt on that cell sends on the tick after arrival, got %s" % _trace(belt))
	var ore := _dwell_lane([Rules.Mat.ORE])
	var ore_run := World.simulate(ore, placed, 6)
	check(_trace(ore_run) == "3:2,1:0|5:2,1:0", "a saturated dwell delivers every other tick, got %s" % _trace(ore_run))
	var ore_belt := World.simulate(ore, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST)], 6)
	check(_trace(ore_belt) == "2:2,1:0|3:2,1:0|4:2,1:0|5:2,1:0|6:2,1:0", "a saturated belt delivers every tick, got %s" % _trace(ore_belt))
	var plates := _dwell_lane([Rules.Mat.PLATE])
	var plate_run := World.simulate(plates, placed, 7)
	var plate_again := World.simulate(plates, placed, 7)
	check(_same(plate_run, plate_again), "a dwell fed only plates is deterministic")
	check(not _same(result, plate_run), "different dwell inputs do not collapse to one output")


func _test_dwell_refuses_side_and_front() -> void:
	var room := {
		"id": 0,
		"name": "dwell refuse",
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
		"budget": Rooms.kv([Rules.Kind.DWELL, 1, Rules.Kind.BELT, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var placed := [Rooms.piece(Rules.Kind.DWELL, 1, 1, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 6)
	check(_trace(result) == "3:2,1:0|5:2,1:0", "dwell passes ore from behind, got %s" % _trace(result))
	check(int(result.counts[Rules.Mat.PLATE]) == 0 and int(result.world.sources[1].pending) == Rules.Mat.PLATE, "dwell refuses a plate from the side")
	check(int(result.counts[Rules.Mat.INGOT]) == 0 and int(result.world.sources[2].pending) == Rules.Mat.INGOT, "dwell refuses an ingot from the other side")
	var side_only := room.duplicate()
	side_only.sources = [Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.PLATE], 1)]
	var belt := World.simulate(side_only, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST)], 4)
	var dwell_side := World.simulate(side_only, placed, 4)
	check(_trace(belt) == "2:2,1:2|3:2,1:2|4:2,1:2", "a belt takes a plate from the side, got %s" % _trace(belt))
	check(int(dwell_side.counts[Rules.Mat.PLATE]) == 0 and int(dwell_side.world.sources[0].pending) == Rules.Mat.PLATE, "a dwell refuses that same side plate")
	var front := {
		"id": 0,
		"name": "dwell front",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 1,
		"sources": [
			Rooms.source(0, 0, Rules.Dir.EAST, [Rules.Mat.ORE], 1),
			Rooms.source(2, 0, Rules.Dir.WEST, [Rules.Mat.INGOT], 1),
		],
		"sinks": [],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.DWELL, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var blocked := World.simulate(front, [Rooms.piece(Rules.Kind.DWELL, 1, 0, Rules.Dir.EAST)], 5)
	var dwell = blocked.world.machines[Vector2i(1, 0)]
	check(int(blocked.counts[Rules.Mat.INGOT]) == 0 and int(blocked.world.sources[1].pending) == Rules.Mat.INGOT, "dwell refuses a head-on ingot")
	check(dwell.hold == Rules.Mat.ORE, "the rear load stays on the dwell")
	check(blocked.trace.is_empty(), "a head-on entry does not leave the dwell, got %s" % _trace(blocked))


func _test_dwell_blocked_does_not_spill() -> void:
	var boxed := {
		"id": 0,
		"name": "dwell boxed",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [],
		"sinks": [
			Rooms.sink(0, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(1, 2, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [Rooms.cell(1, 0)],
		"walls": [Rooms.cell(2, 1)],
		"budget": Rooms.kv([Rules.Kind.DWELL, 1, Rules.Kind.WEIR, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var held = World.new()
	held.setup(boxed, [Rooms.piece(Rules.Kind.DWELL, 1, 1, Rules.Dir.EAST)])
	held.machines[Vector2i(1, 1)].hold = Rules.Mat.ORE
	held.machines[Vector2i(1, 1)].phase = 0
	held.step()
	check(held.error == "" and held.discarded == 0 and held.trace.is_empty(), "a blocked dwell does not spill to the side or back")
	check(held.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "blocked ore stays on the dwell")
	check(int(held.counts[Rules.Mat.ORE]) == 0, "the blocked dwell did not reach a side or back sink")
	check(int(held.machines[Vector2i(1, 1)].phase) == 0, "a blocked dwell does not advance a phase")
	var waiting = World.new()
	waiting.setup(boxed, [Rooms.piece(Rules.Kind.DWELL, 1, 1, Rules.Dir.EAST)])
	waiting.machines[Vector2i(1, 1)].hold = Rules.Mat.PLATE
	waiting.machines[Vector2i(1, 1)].phase = Rules.DWELL_HOLD
	waiting.step()
	check(waiting.trace.is_empty() and waiting.discarded == 0 and waiting.machines[Vector2i(1, 1)].hold == Rules.Mat.PLATE, "the hold tick does not send")
	check(int(waiting.machines[Vector2i(1, 1)].phase) == 0, "the hold tick clears the extra wait")
	waiting.step()
	check(waiting.trace.is_empty() and waiting.discarded == 0 and int(waiting.counts[Rules.Mat.PLATE]) == 0, "after the hold, a blocked dwell still does not spill")
	check(waiting.machines[Vector2i(1, 1)].hold == Rules.Mat.PLATE, "the plate is still on the dwell")
	var weir = World.new()
	weir.setup(boxed, [Rooms.piece(Rules.Kind.WEIR, 1, 1, Rules.Dir.EAST)])
	weir.machines[Vector2i(1, 1)].hold = Rules.Mat.ORE
	weir.step()
	check(int(weir.counts[Rules.Mat.ORE]) == 1 and weir.machines[Vector2i(1, 1)].hold < 0, "the same cell lets a weir spill right into the sink")


func _dwell_lane(pattern: Array) -> Dictionary:
	return {
		"id": 0,
		"name": "dwell",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [Rooms.source(0, 1, Rules.Dir.EAST, pattern, 1)],
		"sinks": [
			Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(1, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(1, 2, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.DWELL, 1, Rules.Kind.BELT, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}


func _test_wing9_lessons() -> void:
	for index in range(64, 72):
		var room: Dictionary = Rooms.all()[index]
		var swapped := _dwell_as_belt(room.solution)
		var belt_run: Dictionary = World.simulate(room, swapped)
		check(belt_run.error == "", "belt in place of the room %d dwell simulates (%s)" % [room.id, belt_run.error])
		check(not belt_run.quota_ok, "belt in place of the room %d dwell misses the quota (%s)" % [room.id, belt_run.text])
		check(not belt_run.success, "belt in place of the room %d dwell does not clear" % room.id)
		var planner = Planner.new(room)
		for piece in room.initial:
			check(planner.pickup(int(piece.x), int(piece.y)), "room %d picks up its starting piece" % room.id)
		for piece in room.solution:
			check(planner.place(int(piece.kind), int(piece.x), int(piece.y), int(piece.dir)), "room %d places its solution from the tray" % room.id)
		var spare := _spare_cell(room)
		check(spare.x >= 0, "room %d has an empty cell for an extra piece" % room.id)
		check(not planner.place(Rules.Kind.BELT, spare.x, spare.y, Rules.Dir.EAST), "room %d rejects a belt past the tray" % room.id)
		var extra: Array = room.solution.duplicate(true)
		extra.append(Rooms.piece(Rules.Kind.BELT, spare.x, spare.y, Rules.Dir.EAST))
		var over: Dictionary = World.simulate(room, extra)
		check(over.quota_ok and not over.budget_ok and not over.success, "room %d extra belt meets the quota and is rejected (%s)" % [room.id, over.text])
	var pause_lane: Dictionary = Rooms.all()[64]
	var paused: Dictionary = World.simulate(pause_lane, pause_lane.solution)
	var pause_belt: Dictionary = World.simulate(pause_lane, _dwell_as_belt(pause_lane.solution))
	check(int(paused.counts[Rules.Mat.PLATE]) >= int(pause_lane.quota[Rules.Mat.PLATE]), "pause delivers the plates (%s)" % paused.text)
	check(int(pause_belt.counts[Rules.Mat.PLATE]) == 0 and int(pause_belt.discarded) > 0, "pause without the hold dumps the plates (%s discarded %d)" % [pause_belt.text, pause_belt.discarded])
	var bank: Dictionary = Rooms.all()[65]
	var banked: Dictionary = World.simulate(bank, bank.solution)
	var bank_belt: Dictionary = World.simulate(bank, _dwell_as_belt(bank.solution))
	check(int(banked.counts[Rules.Mat.INGOT]) >= int(bank.quota[Rules.Mat.INGOT]), "bank feeds the kiln (%s)" % banked.text)
	check(int(bank_belt.counts[Rules.Mat.INGOT]) == 0 and int(bank_belt.discarded) > 0, "bank without the hold dumps the ore (%s discarded %d)" % [bank_belt.text, bank_belt.discarded])
	var stint: Dictionary = Rooms.all()[66]
	var stinted: Dictionary = World.simulate(stint, stint.solution)
	var dumped: Dictionary = World.simulate(stint, _dwell_as_belt(stint.solution))
	check(int(stint.budget[Rules.Kind.BELT]) == 1, "stint budgets one belt")
	check(int(stinted.counts[Rules.Mat.INGOT]) >= int(stint.quota[Rules.Mat.INGOT]), "stint's dwell keeps the ore out of the pit (%s)" % stinted.text)
	check(int(dumped.counts[Rules.Mat.INGOT]) == 0 and int(dumped.discarded) > 0, "stint's belt on the dwell cell dumps the ore (%s discarded %d)" % [dumped.text, dumped.discarded])
	var late: Dictionary = Rooms.all()[67]
	var parked: Array = late.initial.duplicate(true)
	parked.append(Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 5, 1, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.WEIR, 4, 1, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.GRATE, 6, 1, Rules.Dir.EAST))
	var gap: Dictionary = World.simulate(late, parked)
	check(World.budget_met(parked, late.budget), "leaving the late dwell parked stays inside the tray")
	check(int(gap.counts[Rules.Mat.PLATE]) == 0 and not gap.quota_ok, "a parked dwell leaves a gap and misses (%s)" % gap.text)
	var bend_back: Dictionary = Rooms.all()[68]
	var into_wall: Dictionary = World.simulate(bend_back, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.SOUTH),
	])
	check(int(into_wall.counts[Rules.Mat.PLATE]) == 0, "bend belts that turn into the wall deliver nothing")
	var heat: Dictionary = Rooms.all()[69]
	var one_kiln_pieces: Array = []
	for piece in heat.solution:
		if int(piece.x) == 3 and int(piece.y) >= 2:
			continue
		one_kiln_pieces.append(piece)
	var one_kiln: Dictionary = World.simulate(heat, one_kiln_pieces)
	var both: Dictionary = World.simulate(heat, heat.solution)
	var heat_belt: Dictionary = World.simulate(heat, _dwell_as_belt(heat.solution))
	var heat_quota := int(heat.quota[Rules.Mat.INGOT])
	check(int(one_kiln.counts[Rules.Mat.INGOT]) < heat_quota, "one second-heat kiln misses %d (%s)" % [heat_quota, one_kiln.text])
	check(int(both.counts[Rules.Mat.INGOT]) >= heat_quota, "both second-heat kilns reach the quota (%s)" % both.text)
	check(int(both.counts[Rules.Mat.INGOT]) > int(one_kiln.counts[Rules.Mat.INGOT]), "the second-heat spill kiln adds ingots")
	check(int(heat_belt.counts[Rules.Mat.INGOT]) < heat_quota, "a belt in place of the second-heat dwell jams a kiln (%s)" % heat_belt.text)
	var scrap_room: Dictionary = Rooms.all()[70]
	var scraped: Dictionary = World.simulate(scrap_room, scrap_room.solution)
	check(int(scraped.counts[Rules.Mat.INGOT]) >= int(scrap_room.quota[Rules.Mat.INGOT]) and int(scraped.discarded) > 0, "scrap counts kiln ingots and discards the raw ones (%s discarded %d)" % [scraped.text, scraped.discarded])
	var no_filter: Dictionary = World.simulate(scrap_room, [
		Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.DWELL, 3, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.WEIR, 4, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 5, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 6, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 7, 1, Rules.Dir.EAST),
	])
	check(int(no_filter.counts[Rules.Mat.INGOT]) < int(scrap_room.quota[Rules.Mat.INGOT]), "scrap without a filter misses (%s)" % no_filter.text)
	var scrap_belt: Dictionary = World.simulate(scrap_room, _dwell_as_belt(scrap_room.solution))
	check(int(scrap_belt.counts[Rules.Mat.INGOT]) == 0, "a belt in place of the scrap dwell delivers no ingot (%s)" % scrap_belt.text)
	var both_bins: Dictionary = Rooms.all()[71]
	var solved: Dictionary = World.simulate(both_bins, both_bins.solution)
	check(int(solved.counts[Rules.Mat.INGOT]) >= int(both_bins.quota[Rules.Mat.INGOT]) and int(solved.counts[Rules.Mat.PLATE]) >= int(both_bins.quota[Rules.Mat.PLATE]), "both bins hits both quotas (%s)" % solved.text)
	var plates_only: Dictionary = World.simulate(both_bins, [
		Rooms.piece(Rules.Kind.BELT, 1, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 4, Rules.Dir.EAST),
	])
	check(int(plates_only.counts[Rules.Mat.INGOT]) == 0 and int(plates_only.counts[Rules.Mat.PLATE]) < int(both_bins.quota[Rules.Mat.PLATE]), "both bins' upper plates alone miss (%s)" % plates_only.text)
	check(not plates_only.success, "upper plates alone miss both bins")
	var pressed: Dictionary = World.simulate(both_bins, [
		Rooms.piece(Rules.Kind.BELT, 1, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.DWELL, 1, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.WEIR, 2, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.FILTER, 4, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 5, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 6, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 6, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.PRESS, 7, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 8, 3, Rules.Dir.EAST),
	])
	check(int(pressed.counts[Rules.Mat.INGOT]) == 0 and int(pressed.counts[Rules.Mat.PLATE]) > int(plates_only.counts[Rules.Mat.PLATE]), "both bins without the splitter is plates only (%s)" % pressed.text)
	check(not pressed.success, "pressing every ingot misses both bins")
	var unheld: Dictionary = World.simulate(both_bins, _dwell_as_belt(both_bins.solution))
	check(int(unheld.counts[Rules.Mat.INGOT]) < int(both_bins.quota[Rules.Mat.INGOT]) and int(unheld.counts[Rules.Mat.PLATE]) < int(both_bins.quota[Rules.Mat.PLATE]), "a belt in place of the both-bins dwell misses (%s)" % unheld.text)


func _test_twin_waits_for_a_pair() -> void:
	var ore := _twin_forward([Rules.Mat.ORE], 4)
	var placed := [Rooms.piece(Rules.Kind.TWIN, 1, 0, Rules.Dir.EAST)]
	var early := World.simulate(ore, placed, 4)
	var result := World.simulate(ore, placed, 12)
	var again := World.simulate(ore, placed, 12)
	check(_trace(early) == "" and early.world.machines[Vector2i(1, 0)].hold == Rules.Mat.ORE, "a lone ore is still in the twin after the belt tick and the dwell tick")
	check(_trace(result) == "5:2,0:0|9:2,0:0", "a twin sends the waiting ore on the tick its match arrives, got %s" % _trace(result))
	check(result.world.machines[Vector2i(1, 0)].hold == Rules.Mat.ORE, "the last ore of the run stays in the twin")
	check(int(result.counts[Rules.Mat.ORE]) == 2, "two paired ores leave and the third waits")
	check(_same(result, again), "the same twin lane is deterministic (seed %d)" % result.seed)
	var belt := World.simulate(ore, [Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST)], 12)
	var dwell := World.simulate(ore, [Rooms.piece(Rules.Kind.DWELL, 1, 0, Rules.Dir.EAST)], 12)
	check(_trace(belt) == "2:2,0:0|6:2,0:0|10:2,0:0", "a belt on that cell sends on the next tick, got %s" % _trace(belt))
	check(_trace(dwell) == "3:2,0:0|7:2,0:0|11:2,0:0", "a dwell on that cell sends one tick after a belt, got %s" % _trace(dwell))
	for mat in [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]:
		var lane := _twin_forward([mat], 80)
		var lone := World.simulate(lane, placed, 15)
		check(_trace(lone) == "" and lone.world.machines[Vector2i(1, 0)].hold == mat, "a lone %s never leaves a twin" % Rules.MAT_NAME[mat])
		var paired := _twin_forward([mat], 4)
		var run := World.simulate(paired, placed, 8)
		check(_trace(run) == "5:2,0:%d" % mat, "a twin pairs %s, got %s" % [Rules.MAT_NAME[mat], _trace(run)])
	var plates := World.simulate(_twin_forward([Rules.Mat.PLATE], 4), placed, 12)
	check(_same(plates, World.simulate(_twin_forward([Rules.Mat.PLATE], 4), placed, 12)), "a twin fed only plates is deterministic")
	check(not _same(result, plates), "different twin inputs do not collapse to one output")


func _test_twin_refuses_side_front_and_other() -> void:
	var room := {
		"id": 0,
		"name": "twin refuse",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [
			Rooms.source(0, 1, Rules.Dir.EAST, [Rules.Mat.ORE], 4),
			Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.PLATE], 1),
			Rooms.source(1, 2, Rules.Dir.NORTH, [Rules.Mat.INGOT], 1),
		],
		"sinks": [Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.TWIN, 1, Rules.Kind.BELT, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var placed := [Rooms.piece(Rules.Kind.TWIN, 1, 1, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 8)
	check(_trace(result) == "5:2,1:0", "twin passes ore from behind when the next ore arrives, got %s" % _trace(result))
	check(int(result.counts[Rules.Mat.PLATE]) == 0 and int(result.world.sources[1].pending) == Rules.Mat.PLATE, "twin refuses a plate from the side")
	check(int(result.counts[Rules.Mat.INGOT]) == 0 and int(result.world.sources[2].pending) == Rules.Mat.INGOT, "twin refuses an ingot from the other side")
	var side_only := room.duplicate()
	side_only.sources = [Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.PLATE], 1)]
	var belt := World.simulate(side_only, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST)], 4)
	var twin_side := World.simulate(side_only, placed, 4)
	check(_trace(belt) == "2:2,1:2|3:2,1:2|4:2,1:2", "a belt takes a plate from the side, got %s" % _trace(belt))
	check(int(twin_side.counts[Rules.Mat.PLATE]) == 0 and int(twin_side.world.sources[0].pending) == Rules.Mat.PLATE, "a twin refuses that same side plate")
	var front := {
		"id": 0,
		"name": "twin front",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 1,
		"sources": [
			Rooms.source(0, 0, Rules.Dir.EAST, [Rules.Mat.ORE], 4),
			Rooms.source(2, 0, Rules.Dir.WEST, [Rules.Mat.INGOT], 1),
		],
		"sinks": [],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.TWIN, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var blocked := World.simulate(front, [Rooms.piece(Rules.Kind.TWIN, 1, 0, Rules.Dir.EAST)], 6)
	var twin = blocked.world.machines[Vector2i(1, 0)]
	check(int(blocked.world.sources[1].pending) == Rules.Mat.INGOT, "twin refuses a head-on ingot")
	check(twin.hold == Rules.Mat.ORE, "the rear load stays on the twin")
	check(blocked.trace.is_empty(), "a head-on entry does not leave the twin, got %s" % _trace(blocked))
	var mixed := _twin_forward([Rules.Mat.ORE, Rules.Mat.INGOT], 1)
	var clash := World.simulate(mixed, placed_forward(), 6)
	check(clash.trace.is_empty(), "a different material does not push the waiting ore out, got %s" % _trace(clash))
	check(clash.world.machines[Vector2i(1, 0)].hold == Rules.Mat.ORE, "the waiting ore stays when the next item differs")
	check(int(clash.world.sources[0].pending) == Rules.Mat.INGOT, "the different item waits on the previous piece")
	check(int(clash.counts[Rules.Mat.INGOT]) == 0 and int(clash.counts[Rules.Mat.ORE]) == 0, "a refused material is not delivered")


func _test_twin_blocked_does_not_spill() -> void:
	var boxed := {
		"id": 0,
		"name": "twin boxed",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [Rooms.source(0, 1, Rules.Dir.EAST, [Rules.Mat.ORE], 1)],
		"sinks": [
			Rooms.sink(1, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(1, 2, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [Rooms.cell(0, 0)],
		"walls": [Rooms.cell(2, 1)],
		"budget": Rooms.kv([Rules.Kind.TWIN, 1, Rules.Kind.WEIR, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var held := World.simulate(boxed, [Rooms.piece(Rules.Kind.TWIN, 1, 1, Rules.Dir.EAST)], 6)
	check(held.error == "" and held.discarded == 0 and held.trace.is_empty(), "a blocked twin does not spill to the side or back")
	check(held.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "blocked ore stays on the twin")
	check(int(held.world.sources[0].pending) == Rules.Mat.ORE, "the partner is not accepted while the forward cell refuses")
	check(int(held.counts[Rules.Mat.ORE]) == 0, "the blocked twin did not reach a side sink")
	check(int(held.world.machines[Vector2i(1, 1)].phase) == 0, "a twin does not rotate or alternate")
	var weir := World.simulate(boxed, [Rooms.piece(Rules.Kind.WEIR, 1, 1, Rules.Dir.EAST)], 4)
	check(int(weir.counts[Rules.Mat.ORE]) >= 1, "the same cell lets a weir spill right into the sink")


func _twin_forward(pattern: Array, period: int) -> Dictionary:
	return {
		"id": 0,
		"name": "twin",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 1,
		"sources": [Rooms.source(0, 0, Rules.Dir.EAST, pattern, period)],
		"sinks": [Rooms.sink(2, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.TWIN, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}


func placed_forward() -> Array:
	return [Rooms.piece(Rules.Kind.TWIN, 1, 0, Rules.Dir.EAST)]


func _test_wing10_lessons() -> void:
	for index in range(72, 80):
		var room: Dictionary = Rooms.all()[index]
		var as_belt := _swap_kind(room.solution, Rules.Kind.TWIN, Rules.Kind.BELT)
		var belt_run: Dictionary = World.simulate(room, as_belt)
		check(belt_run.error == "", "belt in place of the room %d twin simulates (%s)" % [room.id, belt_run.error])
		check(not belt_run.quota_ok, "belt in place of the room %d twin misses the quota (%s)" % [room.id, belt_run.text])
		check(not belt_run.success, "belt in place of the room %d twin does not clear" % room.id)
		var as_dwell := _swap_kind(room.solution, Rules.Kind.TWIN, Rules.Kind.DWELL)
		var dwell_run: Dictionary = World.simulate(room, as_dwell)
		check(dwell_run.error == "", "dwell in place of the room %d twin simulates (%s)" % [room.id, dwell_run.error])
		check(not dwell_run.quota_ok, "dwell in place of the room %d twin misses the quota (%s)" % [room.id, dwell_run.text])
		check(not dwell_run.success, "dwell in place of the room %d twin does not clear" % room.id)
		var planner = Planner.new(room)
		for piece in room.initial:
			check(planner.pickup(int(piece.x), int(piece.y)), "room %d picks up its starting piece" % room.id)
		for piece in room.solution:
			check(planner.place(int(piece.kind), int(piece.x), int(piece.y), int(piece.dir)), "room %d places its solution from the tray" % room.id)
		var spare := _spare_cell(room)
		check(spare.x >= 0, "room %d has an empty cell for an extra piece" % room.id)
		check(not planner.place(Rules.Kind.BELT, spare.x, spare.y, Rules.Dir.EAST), "room %d rejects a belt past the tray" % room.id)
		var extra: Array = room.solution.duplicate(true)
		extra.append(Rooms.piece(Rules.Kind.BELT, spare.x, spare.y, Rules.Dir.EAST))
		var over: Dictionary = World.simulate(room, extra)
		check(over.quota_ok and not over.budget_ok and not over.success, "room %d extra belt meets the quota and is rejected (%s)" % [room.id, over.text])
	var pair_room: Dictionary = Rooms.all()[72]
	var paired: Dictionary = World.simulate(pair_room, pair_room.solution)
	var pair_belt: Dictionary = World.simulate(pair_room, _swap_kind(pair_room.solution, Rules.Kind.TWIN, Rules.Kind.BELT))
	var pair_dwell: Dictionary = World.simulate(pair_room, _swap_kind(pair_room.solution, Rules.Kind.TWIN, Rules.Kind.DWELL))
	check(int(paired.counts[Rules.Mat.PLATE]) >= int(pair_room.quota[Rules.Mat.PLATE]), "pair delivers the plates (%s)" % paired.text)
	check(paired.world.machines[Vector2i(1, 3)].hold == Rules.Mat.PLATE, "pair leaves the last plate in the twin")
	check(int(pair_belt.counts[Rules.Mat.PLATE]) == 0 and int(pair_belt.discarded) > 0, "pair without the pair dumps the plates (%s discarded %d)" % [pair_belt.text, pair_belt.discarded])
	check(int(pair_dwell.counts[Rules.Mat.PLATE]) == 0 and int(pair_dwell.discarded) > 0, "pair with a dwell still dumps the plates (%s discarded %d)" % [pair_dwell.text, pair_dwell.discarded])
	var match_room: Dictionary = Rooms.all()[73]
	var matched: Dictionary = World.simulate(match_room, match_room.solution)
	var match_belt: Dictionary = World.simulate(match_room, _swap_kind(match_room.solution, Rules.Kind.TWIN, Rules.Kind.BELT))
	var match_dwell: Dictionary = World.simulate(match_room, _swap_kind(match_room.solution, Rules.Kind.TWIN, Rules.Kind.DWELL))
	check(int(matched.counts[Rules.Mat.INGOT]) >= int(match_room.quota[Rules.Mat.INGOT]), "match feeds the kiln (%s)" % matched.text)
	check(matched.world.machines[Vector2i(1, 3)].hold == Rules.Mat.ORE, "match leaves the last ore in the twin")
	check(int(match_belt.counts[Rules.Mat.INGOT]) == 0 and int(match_belt.discarded) > 0, "match without the pair dumps the ore (%s discarded %d)" % [match_belt.text, match_belt.discarded])
	check(int(match_dwell.counts[Rules.Mat.INGOT]) == 0 and int(match_dwell.discarded) > 0, "match with a dwell still dumps the ore (%s discarded %d)" % [match_dwell.text, match_dwell.discarded])
	var stint: Dictionary = Rooms.all()[74]
	var stinted: Dictionary = World.simulate(stint, stint.solution)
	var stint_belt: Dictionary = World.simulate(stint, _swap_kind(stint.solution, Rules.Kind.TWIN, Rules.Kind.BELT))
	var stint_dwell: Dictionary = World.simulate(stint, _swap_kind(stint.solution, Rules.Kind.TWIN, Rules.Kind.DWELL))
	check(int(stint.budget[Rules.Kind.BELT]) == 1, "stint budgets one belt")
	check(int(stinted.counts[Rules.Mat.INGOT]) >= int(stint.quota[Rules.Mat.INGOT]), "stint's twin keeps the ore out of the pit (%s)" % stinted.text)
	check(int(stint_belt.counts[Rules.Mat.INGOT]) == 0 and int(stint_belt.discarded) > 0, "stint's belt on the twin cell dumps the ore (%s discarded %d)" % [stint_belt.text, stint_belt.discarded])
	check(int(stint_dwell.counts[Rules.Mat.INGOT]) == 0 and int(stint_dwell.discarded) > 0, "stint's dwell on the twin cell dumps the ore (%s discarded %d)" % [stint_dwell.text, stint_dwell.discarded])
	var late: Dictionary = Rooms.all()[75]
	var parked: Array = late.initial.duplicate(true)
	parked.append(Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.GRATE, 4, 3, Rules.Dir.EAST))
	var gap: Dictionary = World.simulate(late, parked)
	check(World.budget_met(parked, late.budget), "leaving the late twin parked stays inside the tray")
	check(int(gap.counts[Rules.Mat.PLATE]) == 0 and not gap.quota_ok, "a parked twin leaves a gap and misses (%s)" % gap.text)
	var bend_pair: Dictionary = Rooms.all()[76]
	var into_wall: Dictionary = World.simulate(bend_pair, [
		Rooms.piece(Rules.Kind.BELT, 1, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 2, Rules.Dir.SOUTH),
	])
	check(int(into_wall.counts[Rules.Mat.PLATE]) == 0, "bend belts that turn into the wall deliver nothing")
	var heat: Dictionary = Rooms.all()[77]
	var one_kiln_pieces: Array = []
	for piece in heat.solution:
		if int(piece.x) == 3 and int(piece.y) >= 2:
			continue
		one_kiln_pieces.append(piece)
	var one_kiln: Dictionary = World.simulate(heat, one_kiln_pieces)
	var both: Dictionary = World.simulate(heat, heat.solution)
	var heat_belt: Dictionary = World.simulate(heat, _swap_kind(heat.solution, Rules.Kind.TWIN, Rules.Kind.BELT))
	var heat_dwell: Dictionary = World.simulate(heat, _swap_kind(heat.solution, Rules.Kind.TWIN, Rules.Kind.DWELL))
	var heat_quota := int(heat.quota[Rules.Mat.INGOT])
	check(int(one_kiln.counts[Rules.Mat.INGOT]) < heat_quota, "one second-heat kiln misses %d (%s)" % [heat_quota, one_kiln.text])
	check(int(both.counts[Rules.Mat.INGOT]) >= heat_quota, "both second-heat kilns reach the quota (%s)" % both.text)
	check(int(both.counts[Rules.Mat.INGOT]) > int(one_kiln.counts[Rules.Mat.INGOT]), "the second-heat spill kiln adds ingots")
	check(int(heat_belt.counts[Rules.Mat.INGOT]) < heat_quota, "a belt in place of the second-heat twin jams a kiln (%s)" % heat_belt.text)
	check(int(heat_dwell.counts[Rules.Mat.INGOT]) < heat_quota, "a dwell in place of the second-heat twin jams a kiln (%s)" % heat_dwell.text)
	var scrap: Dictionary = Rooms.all()[78]
	var scraped: Dictionary = World.simulate(scrap, scrap.solution)
	check(int(scraped.counts[Rules.Mat.INGOT]) >= int(scrap.quota[Rules.Mat.INGOT]) and int(scraped.discarded) > 0, "after the scrap counts kiln ingots and discards the raw ones (%s discarded %d)" % [scraped.text, scraped.discarded])
	var no_filter: Dictionary = World.simulate(scrap, [
		Rooms.piece(Rules.Kind.TWIN, 1, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 5, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 6, 3, Rules.Dir.EAST),
	])
	check(int(no_filter.counts[Rules.Mat.INGOT]) < int(scrap.quota[Rules.Mat.INGOT]), "after the scrap without a filter misses (%s)" % no_filter.text)
	var scrap_belt: Dictionary = World.simulate(scrap, _swap_kind(scrap.solution, Rules.Kind.TWIN, Rules.Kind.BELT))
	var scrap_dwell: Dictionary = World.simulate(scrap, _swap_kind(scrap.solution, Rules.Kind.TWIN, Rules.Kind.DWELL))
	check(int(scrap_belt.counts[Rules.Mat.INGOT]) == 0, "a belt in place of the scrap twin delivers no ingot (%s)" % scrap_belt.text)
	check(int(scrap_dwell.counts[Rules.Mat.INGOT]) == 0, "a dwell in place of the scrap twin delivers no ingot (%s)" % scrap_dwell.text)
	var both_bins: Dictionary = Rooms.all()[79]
	var solved: Dictionary = World.simulate(both_bins, both_bins.solution)
	check(int(solved.counts[Rules.Mat.INGOT]) >= int(both_bins.quota[Rules.Mat.INGOT]) and int(solved.counts[Rules.Mat.PLATE]) >= int(both_bins.quota[Rules.Mat.PLATE]), "both bins hits both quotas (%s)" % solved.text)
	var plates_only: Dictionary = World.simulate(both_bins, [
		Rooms.piece(Rules.Kind.BELT, 1, 5, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 5, Rules.Dir.EAST),
	])
	check(int(plates_only.counts[Rules.Mat.INGOT]) == 0 and int(plates_only.counts[Rules.Mat.PLATE]) < int(both_bins.quota[Rules.Mat.PLATE]), "both bins' upper plates alone miss (%s)" % plates_only.text)
	check(not plates_only.success, "upper plates alone miss both bins")
	var pressed: Dictionary = World.simulate(both_bins, [
		Rooms.piece(Rules.Kind.BELT, 1, 5, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 5, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.TWIN, 1, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.FILTER, 4, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 5, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 6, 3, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 6, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.PRESS, 7, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 8, 4, Rules.Dir.EAST),
	])
	check(int(pressed.counts[Rules.Mat.INGOT]) == 0 and int(pressed.counts[Rules.Mat.PLATE]) > int(plates_only.counts[Rules.Mat.PLATE]), "both bins without the splitter is plates only (%s)" % pressed.text)
	check(not pressed.success, "pressing every ingot misses both bins")
	var unheld: Dictionary = World.simulate(both_bins, _swap_kind(both_bins.solution, Rules.Kind.TWIN, Rules.Kind.BELT))
	var undwelt: Dictionary = World.simulate(both_bins, _swap_kind(both_bins.solution, Rules.Kind.TWIN, Rules.Kind.DWELL))
	check(int(unheld.counts[Rules.Mat.INGOT]) < int(both_bins.quota[Rules.Mat.INGOT]) and int(unheld.counts[Rules.Mat.PLATE]) < int(both_bins.quota[Rules.Mat.PLATE]), "a belt in place of the both-bins twin misses (%s)" % unheld.text)
	check(int(undwelt.counts[Rules.Mat.INGOT]) < int(both_bins.quota[Rules.Mat.INGOT]) and int(undwelt.counts[Rules.Mat.PLATE]) < int(both_bins.quota[Rules.Mat.PLATE]), "a dwell in place of the both-bins twin misses (%s)" % undwelt.text)


func _test_pass_waits_until_pushed() -> void:
	var ore := _pass_forward([Rules.Mat.ORE], 4)
	var placed := [Rooms.piece(Rules.Kind.PASS, 1, 0, Rules.Dir.EAST)]
	var early := World.simulate(ore, placed, 4)
	var result := World.simulate(ore, placed, 12)
	var again := World.simulate(ore, placed, 12)
	check(_trace(early) == "" and early.world.machines[Vector2i(1, 0)].hold == Rules.Mat.ORE, "a lone ore is still in the pass after the belt tick and the dwell tick")
	check(_trace(result) == "5:2,0:0|9:2,0:0", "a pass sends the waiting ore on the tick the next ore arrives, got %s" % _trace(result))
	check(result.world.machines[Vector2i(1, 0)].hold == Rules.Mat.ORE, "the last ore of the run stays in the pass")
	check(int(result.counts[Rules.Mat.ORE]) == 2, "two ores leave and the third waits")
	check(_same(result, again), "the same pass lane is deterministic (seed %d)" % result.seed)
	var belt := World.simulate(ore, [Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST)], 12)
	var dwell := World.simulate(ore, [Rooms.piece(Rules.Kind.DWELL, 1, 0, Rules.Dir.EAST)], 12)
	check(_trace(belt) == "2:2,0:0|6:2,0:0|10:2,0:0", "a belt on that cell sends on the next tick, got %s" % _trace(belt))
	check(_trace(dwell) == "3:2,0:0|7:2,0:0|11:2,0:0", "a dwell on that cell sends one tick after a belt, got %s" % _trace(dwell))
	for mat in [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]:
		var lane := _pass_forward([mat], 80)
		var lone := World.simulate(lane, placed, 15)
		check(_trace(lone) == "" and lone.world.machines[Vector2i(1, 0)].hold == mat, "a lone %s never leaves a pass" % Rules.MAT_NAME[mat])
		var paired := _pass_forward([mat], 4)
		var run := World.simulate(paired, placed, 8)
		check(_trace(run) == "5:2,0:%d" % mat, "a pass sends %s when the next item arrives, got %s" % [Rules.MAT_NAME[mat], _trace(run)])
	var mixed := _pass_forward([Rules.Mat.ORE, Rules.Mat.INGOT], 4)
	var held := World.simulate(mixed, placed, 4)
	var pushed := World.simulate(mixed, placed, 12)
	check(_trace(held) == "" and held.world.machines[Vector2i(1, 0)].hold == Rules.Mat.ORE, "a pass does not release before the different material arrives")
	check(_trace(pushed) == "5:2,0:0|9:2,0:1", "a different material pushes the waiting item, got %s" % _trace(pushed))
	check(pushed.world.machines[Vector2i(1, 0)].hold == Rules.Mat.ORE, "the last item of a mixed run stays in the pass")
	var twin_mixed := World.simulate(mixed, [Rooms.piece(Rules.Kind.TWIN, 1, 0, Rules.Dir.EAST)], 12)
	check(_trace(twin_mixed) == "" and twin_mixed.world.machines[Vector2i(1, 0)].hold == Rules.Mat.ORE, "a twin refuses that different material")
	check(int(twin_mixed.world.sources[0].pending) == Rules.Mat.INGOT, "the refused material waits on the previous piece")
	var fast := _pass_forward([Rules.Mat.ORE, Rules.Mat.INGOT], 1)
	var fast_run := World.simulate(fast, placed, 4)
	var fast_twin := World.simulate(fast, [Rooms.piece(Rules.Kind.TWIN, 1, 0, Rules.Dir.EAST)], 4)
	check(_trace(fast_run) == "2:2,0:0|3:2,0:1|4:2,0:0", "period 1 lets the next material push on the following tick, got %s" % _trace(fast_run))
	check(_trace(fast_twin) == "", "a twin on that period-1 lane never releases, got %s" % _trace(fast_twin))
	var plates := World.simulate(_pass_forward([Rules.Mat.PLATE], 4), placed, 12)
	check(_same(plates, World.simulate(_pass_forward([Rules.Mat.PLATE], 4), placed, 12)), "a pass fed only plates is deterministic")
	check(not _same(result, plates), "different pass inputs do not collapse to one output")


func _test_pass_refuses_side_and_front() -> void:
	var room := {
		"id": 0,
		"name": "pass refuse",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [
			Rooms.source(0, 1, Rules.Dir.EAST, [Rules.Mat.ORE], 4),
			Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.PLATE], 1),
			Rooms.source(1, 2, Rules.Dir.NORTH, [Rules.Mat.INGOT], 1),
		],
		"sinks": [Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.PASS, 1, Rules.Kind.BELT, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var placed := [Rooms.piece(Rules.Kind.PASS, 1, 1, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 8)
	check(_trace(result) == "5:2,1:0", "pass sends ore from behind when the next ore arrives, got %s" % _trace(result))
	check(int(result.counts[Rules.Mat.PLATE]) == 0 and int(result.world.sources[1].pending) == Rules.Mat.PLATE, "pass refuses a plate from the side")
	check(int(result.counts[Rules.Mat.INGOT]) == 0 and int(result.world.sources[2].pending) == Rules.Mat.INGOT, "pass refuses an ingot from the other side")
	check(int(result.world.machines[Vector2i(1, 1)].phase) == 0, "a pass does not rotate or alternate")
	var side_only := room.duplicate()
	side_only.sources = [Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.PLATE], 1)]
	var belt := World.simulate(side_only, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST)], 4)
	var pass_side := World.simulate(side_only, placed, 4)
	check(_trace(belt) == "2:2,1:2|3:2,1:2|4:2,1:2", "a belt takes a plate from the side, got %s" % _trace(belt))
	check(int(pass_side.counts[Rules.Mat.PLATE]) == 0 and int(pass_side.world.sources[0].pending) == Rules.Mat.PLATE, "a pass refuses that same side plate")
	var front := {
		"id": 0,
		"name": "pass front",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 1,
		"sources": [
			Rooms.source(0, 0, Rules.Dir.EAST, [Rules.Mat.ORE], 4),
			Rooms.source(2, 0, Rules.Dir.WEST, [Rules.Mat.INGOT], 1),
		],
		"sinks": [],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.PASS, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var blocked := World.simulate(front, [Rooms.piece(Rules.Kind.PASS, 1, 0, Rules.Dir.EAST)], 6)
	var machine = blocked.world.machines[Vector2i(1, 0)]
	check(int(blocked.world.sources[1].pending) == Rules.Mat.INGOT, "pass refuses a head-on ingot")
	check(machine.hold == Rules.Mat.ORE, "the rear load stays on the pass")
	check(blocked.trace.is_empty(), "a head-on entry does not leave the pass, got %s" % _trace(blocked))
	check(int(machine.phase) == 0, "a head-on entry does not rotate the pass")


func _test_pass_blocked_does_not_spill() -> void:
	var boxed := {
		"id": 0,
		"name": "pass boxed",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [Rooms.source(0, 1, Rules.Dir.EAST, [Rules.Mat.ORE, Rules.Mat.PLATE], 1)],
		"sinks": [
			Rooms.sink(1, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(1, 2, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [Rooms.cell(0, 0)],
		"walls": [Rooms.cell(2, 1)],
		"budget": Rooms.kv([Rules.Kind.PASS, 1, Rules.Kind.WEIR, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var held := World.simulate(boxed, [Rooms.piece(Rules.Kind.PASS, 1, 1, Rules.Dir.EAST)], 6)
	check(held.error == "" and held.discarded == 0 and held.trace.is_empty(), "a blocked pass does not spill to the side or back")
	check(held.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "blocked ore stays on the pass")
	check(int(held.world.sources[0].pending) == Rules.Mat.PLATE, "the different item is not accepted while the forward cell refuses")
	check(int(held.counts[Rules.Mat.ORE]) == 0 and int(held.counts[Rules.Mat.PLATE]) == 0, "the blocked pass did not reach a side sink")
	check(int(held.world.machines[Vector2i(1, 1)].phase) == 0, "a pass does not rotate or alternate when blocked")
	var weir := World.simulate(boxed, [Rooms.piece(Rules.Kind.WEIR, 1, 1, Rules.Dir.EAST)], 4)
	check(int(weir.counts[Rules.Mat.ORE]) >= 1, "the same cell lets a weir spill right into the sink")


func _pass_forward(pattern: Array, period: int) -> Dictionary:
	return {
		"id": 0,
		"name": "pass",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 1,
		"sources": [Rooms.source(0, 0, Rules.Dir.EAST, pattern, period)],
		"sinks": [Rooms.sink(2, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.PASS, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}


func _test_wing11_lessons() -> void:
	for index in range(80, 88):
		var room: Dictionary = Rooms.all()[index]
		var as_belt := _swap_kind(room.solution, Rules.Kind.PASS, Rules.Kind.BELT)
		var belt_run: Dictionary = World.simulate(room, as_belt)
		check(belt_run.error == "", "belt in place of the room %d pass simulates (%s)" % [room.id, belt_run.error])
		check(not belt_run.quota_ok, "belt in place of the room %d pass misses the quota (%s)" % [room.id, belt_run.text])
		check(not belt_run.success, "belt in place of the room %d pass does not clear" % room.id)
		var as_dwell := _swap_kind(room.solution, Rules.Kind.PASS, Rules.Kind.DWELL)
		var dwell_run: Dictionary = World.simulate(room, as_dwell)
		check(dwell_run.error == "", "dwell in place of the room %d pass simulates (%s)" % [room.id, dwell_run.error])
		check(not dwell_run.quota_ok, "dwell in place of the room %d pass misses the quota (%s)" % [room.id, dwell_run.text])
		check(not dwell_run.success, "dwell in place of the room %d pass does not clear" % room.id)
		var as_twin := _swap_kind(room.solution, Rules.Kind.PASS, Rules.Kind.TWIN)
		var twin_run: Dictionary = World.simulate(room, as_twin)
		check(twin_run.error == "", "twin in place of the room %d pass simulates (%s)" % [room.id, twin_run.error])
		check(not twin_run.quota_ok, "twin in place of the room %d pass misses the quota (%s)" % [room.id, twin_run.text])
		check(not twin_run.success, "twin in place of the room %d pass does not clear" % room.id)
		var planner = Planner.new(room)
		for piece in room.initial:
			check(planner.pickup(int(piece.x), int(piece.y)), "room %d picks up its starting piece" % room.id)
		for piece in room.solution:
			check(planner.place(int(piece.kind), int(piece.x), int(piece.y), int(piece.dir)), "room %d places its solution from the tray" % room.id)
		var spare := _spare_cell(room)
		check(spare.x >= 0, "room %d has an empty cell for an extra piece" % room.id)
		check(not planner.place(Rules.Kind.BELT, spare.x, spare.y, Rules.Dir.EAST), "room %d rejects a belt past the tray" % room.id)
		var extra: Array = room.solution.duplicate(true)
		extra.append(Rooms.piece(Rules.Kind.BELT, spare.x, spare.y, Rules.Dir.EAST))
		var over: Dictionary = World.simulate(room, extra)
		check(over.quota_ok and not over.budget_ok and not over.success, "room %d extra belt meets the quota and is rejected (%s)" % [room.id, over.text])
	var pair_room: Dictionary = Rooms.all()[80]
	var paired: Dictionary = World.simulate(pair_room, pair_room.solution)
	var pair_belt: Dictionary = World.simulate(pair_room, _swap_kind(pair_room.solution, Rules.Kind.PASS, Rules.Kind.BELT))
	var pair_dwell: Dictionary = World.simulate(pair_room, _swap_kind(pair_room.solution, Rules.Kind.PASS, Rules.Kind.DWELL))
	var pair_twin: Dictionary = World.simulate(pair_room, _swap_kind(pair_room.solution, Rules.Kind.PASS, Rules.Kind.TWIN))
	check(int(paired.counts[Rules.Mat.PLATE]) >= int(pair_room.quota[Rules.Mat.PLATE]), "pair delivers the plates (%s)" % paired.text)
	check(paired.world.machines[Vector2i(1, 3)].hold == Rules.Mat.INGOT, "pair leaves the last ingot in the pass")
	check(int(pair_belt.counts[Rules.Mat.PLATE]) == 0 and int(pair_belt.discarded) > 0, "pair without the pass dumps the plates (%s discarded %d)" % [pair_belt.text, pair_belt.discarded])
	check(int(pair_dwell.counts[Rules.Mat.PLATE]) == 0 and int(pair_dwell.discarded) > 0, "pair with a dwell still dumps the plates (%s discarded %d)" % [pair_dwell.text, pair_dwell.discarded])
	check(int(pair_twin.counts[Rules.Mat.PLATE]) == 0, "pair with a twin never lets the plate leave (%s)" % pair_twin.text)
	var match_room: Dictionary = Rooms.all()[81]
	var matched: Dictionary = World.simulate(match_room, match_room.solution)
	var match_belt: Dictionary = World.simulate(match_room, _swap_kind(match_room.solution, Rules.Kind.PASS, Rules.Kind.BELT))
	var match_dwell: Dictionary = World.simulate(match_room, _swap_kind(match_room.solution, Rules.Kind.PASS, Rules.Kind.DWELL))
	var match_twin: Dictionary = World.simulate(match_room, _swap_kind(match_room.solution, Rules.Kind.PASS, Rules.Kind.TWIN))
	check(int(matched.counts[Rules.Mat.INGOT]) >= int(match_room.quota[Rules.Mat.INGOT]), "match feeds the kiln (%s)" % matched.text)
	check(matched.world.machines[Vector2i(1, 3)].hold == Rules.Mat.PLATE, "match leaves the last plate in the pass")
	check(int(match_belt.counts[Rules.Mat.INGOT]) == 0 and int(match_belt.discarded) > 0, "match without the pass dumps the ore (%s discarded %d)" % [match_belt.text, match_belt.discarded])
	check(int(match_dwell.counts[Rules.Mat.INGOT]) == 0 and int(match_dwell.discarded) > 0, "match with a dwell still dumps the ore (%s discarded %d)" % [match_dwell.text, match_dwell.discarded])
	check(int(match_twin.counts[Rules.Mat.INGOT]) == 0, "match with a twin never lets the ore reach the kiln (%s)" % match_twin.text)
	var stint: Dictionary = Rooms.all()[82]
	var stinted: Dictionary = World.simulate(stint, stint.solution)
	var stint_belt: Dictionary = World.simulate(stint, _swap_kind(stint.solution, Rules.Kind.PASS, Rules.Kind.BELT))
	var stint_dwell: Dictionary = World.simulate(stint, _swap_kind(stint.solution, Rules.Kind.PASS, Rules.Kind.DWELL))
	var stint_twin: Dictionary = World.simulate(stint, _swap_kind(stint.solution, Rules.Kind.PASS, Rules.Kind.TWIN))
	check(int(stint.budget[Rules.Kind.BELT]) == 1, "stint budgets one belt")
	check(int(stinted.counts[Rules.Mat.INGOT]) >= int(stint.quota[Rules.Mat.INGOT]), "stint's pass keeps the ore out of the pit (%s)" % stinted.text)
	check(int(stint_belt.counts[Rules.Mat.INGOT]) == 0 and int(stint_belt.discarded) > 0, "stint's belt on the pass cell dumps the ore (%s discarded %d)" % [stint_belt.text, stint_belt.discarded])
	check(int(stint_dwell.counts[Rules.Mat.INGOT]) == 0 and int(stint_dwell.discarded) > 0, "stint's dwell on the pass cell dumps the ore (%s discarded %d)" % [stint_dwell.text, stint_dwell.discarded])
	check(int(stint_twin.counts[Rules.Mat.INGOT]) == 0, "stint's twin never releases the ore (%s)" % stint_twin.text)
	var late: Dictionary = Rooms.all()[83]
	var parked: Array = late.initial.duplicate(true)
	parked.append(Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.GRATE, 4, 3, Rules.Dir.EAST))
	var gap: Dictionary = World.simulate(late, parked)
	check(World.budget_met(parked, late.budget), "leaving the late pass parked stays inside the tray")
	check(int(gap.counts[Rules.Mat.PLATE]) == 0 and not gap.quota_ok, "a parked pass leaves a gap and misses (%s)" % gap.text)
	var bend_room: Dictionary = Rooms.all()[84]
	var into_wall: Dictionary = World.simulate(bend_room, [
		Rooms.piece(Rules.Kind.BELT, 1, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 2, Rules.Dir.SOUTH),
	])
	check(int(into_wall.counts[Rules.Mat.PLATE]) == 0, "bend belts that turn into the wall deliver nothing")
	var heat: Dictionary = Rooms.all()[85]
	var one_kiln_pieces: Array = []
	for piece in heat.solution:
		if int(piece.x) == 3 and int(piece.y) >= 2:
			continue
		one_kiln_pieces.append(piece)
	var one_kiln: Dictionary = World.simulate(heat, one_kiln_pieces)
	var both: Dictionary = World.simulate(heat, heat.solution)
	var heat_belt: Dictionary = World.simulate(heat, _swap_kind(heat.solution, Rules.Kind.PASS, Rules.Kind.BELT))
	var heat_dwell: Dictionary = World.simulate(heat, _swap_kind(heat.solution, Rules.Kind.PASS, Rules.Kind.DWELL))
	var heat_twin: Dictionary = World.simulate(heat, _swap_kind(heat.solution, Rules.Kind.PASS, Rules.Kind.TWIN))
	var heat_quota := int(heat.quota[Rules.Mat.INGOT])
	check(int(one_kiln.counts[Rules.Mat.INGOT]) < heat_quota, "one second-heat kiln misses %d (%s)" % [heat_quota, one_kiln.text])
	check(int(both.counts[Rules.Mat.INGOT]) >= heat_quota, "both second-heat kilns reach the quota (%s)" % both.text)
	check(int(both.counts[Rules.Mat.INGOT]) > int(one_kiln.counts[Rules.Mat.INGOT]), "the second-heat spill kiln adds ingots")
	check(int(heat_belt.counts[Rules.Mat.INGOT]) < heat_quota, "a belt in place of the second-heat pass misses (%s)" % heat_belt.text)
	check(int(heat_dwell.counts[Rules.Mat.INGOT]) < heat_quota, "a dwell in place of the second-heat pass misses (%s)" % heat_dwell.text)
	check(int(heat_twin.counts[Rules.Mat.INGOT]) < heat_quota, "a twin in place of the second-heat pass never releases the ore (%s)" % heat_twin.text)
	var scrap: Dictionary = Rooms.all()[86]
	var scraped: Dictionary = World.simulate(scrap, scrap.solution)
	check(int(scraped.counts[Rules.Mat.INGOT]) >= int(scrap.quota[Rules.Mat.INGOT]) and int(scraped.discarded) > 0, "after the scrap counts kiln ingots and discards the raw ones (%s discarded %d)" % [scraped.text, scraped.discarded])
	var no_filter: Dictionary = World.simulate(scrap, [
		Rooms.piece(Rules.Kind.PASS, 1, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 5, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 6, 3, Rules.Dir.EAST),
	])
	check(int(no_filter.counts[Rules.Mat.INGOT]) < int(scrap.quota[Rules.Mat.INGOT]), "after the scrap without a filter misses (%s)" % no_filter.text)
	var scrap_belt: Dictionary = World.simulate(scrap, _swap_kind(scrap.solution, Rules.Kind.PASS, Rules.Kind.BELT))
	var scrap_dwell: Dictionary = World.simulate(scrap, _swap_kind(scrap.solution, Rules.Kind.PASS, Rules.Kind.DWELL))
	var scrap_twin: Dictionary = World.simulate(scrap, _swap_kind(scrap.solution, Rules.Kind.PASS, Rules.Kind.TWIN))
	check(int(scrap_belt.counts[Rules.Mat.INGOT]) == 0, "a belt in place of the scrap pass delivers no ingot (%s)" % scrap_belt.text)
	check(int(scrap_dwell.counts[Rules.Mat.INGOT]) == 0, "a dwell in place of the scrap pass delivers no ingot (%s)" % scrap_dwell.text)
	check(int(scrap_twin.counts[Rules.Mat.INGOT]) == 0, "a twin in place of the scrap pass delivers no ingot (%s)" % scrap_twin.text)
	var both_bins: Dictionary = Rooms.all()[87]
	var solved: Dictionary = World.simulate(both_bins, both_bins.solution)
	check(int(solved.counts[Rules.Mat.INGOT]) >= int(both_bins.quota[Rules.Mat.INGOT]) and int(solved.counts[Rules.Mat.PLATE]) >= int(both_bins.quota[Rules.Mat.PLATE]), "both bins hits both quotas (%s)" % solved.text)
	var plates_only: Dictionary = World.simulate(both_bins, [
		Rooms.piece(Rules.Kind.BELT, 1, 5, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 5, Rules.Dir.EAST),
	])
	check(int(plates_only.counts[Rules.Mat.INGOT]) == 0 and int(plates_only.counts[Rules.Mat.PLATE]) < int(both_bins.quota[Rules.Mat.PLATE]), "both bins' upper plates alone miss (%s)" % plates_only.text)
	check(not plates_only.success, "upper plates alone miss both bins")
	var pressed: Dictionary = World.simulate(both_bins, [
		Rooms.piece(Rules.Kind.BELT, 1, 5, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 5, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.PASS, 1, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.FILTER, 4, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 5, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 6, 3, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 6, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.PRESS, 7, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 8, 4, Rules.Dir.EAST),
	])
	check(int(pressed.counts[Rules.Mat.INGOT]) == 0 and int(pressed.counts[Rules.Mat.PLATE]) > int(plates_only.counts[Rules.Mat.PLATE]), "both bins without the splitter is plates only (%s)" % pressed.text)
	check(not pressed.success, "pressing every ingot misses both bins")
	var unheld: Dictionary = World.simulate(both_bins, _swap_kind(both_bins.solution, Rules.Kind.PASS, Rules.Kind.BELT))
	var undwelt: Dictionary = World.simulate(both_bins, _swap_kind(both_bins.solution, Rules.Kind.PASS, Rules.Kind.DWELL))
	var untwinned: Dictionary = World.simulate(both_bins, _swap_kind(both_bins.solution, Rules.Kind.PASS, Rules.Kind.TWIN))
	check(int(unheld.counts[Rules.Mat.INGOT]) < int(both_bins.quota[Rules.Mat.INGOT]) and int(unheld.counts[Rules.Mat.PLATE]) < int(both_bins.quota[Rules.Mat.PLATE]), "a belt in place of the both-bins pass misses (%s)" % unheld.text)
	check(int(undwelt.counts[Rules.Mat.INGOT]) < int(both_bins.quota[Rules.Mat.INGOT]) and int(undwelt.counts[Rules.Mat.PLATE]) < int(both_bins.quota[Rules.Mat.PLATE]), "a dwell in place of the both-bins pass misses (%s)" % undwelt.text)
	check(int(untwinned.counts[Rules.Mat.INGOT]) < int(both_bins.quota[Rules.Mat.INGOT]) and int(untwinned.counts[Rules.Mat.PLATE]) < int(both_bins.quota[Rules.Mat.PLATE]), "a twin in place of the both-bins pass misses (%s)" % untwinned.text)


func _swap_kind(pieces: Array, source_kind: int, dest_kind: int) -> Array:
	var swapped: Array = []
	for piece in pieces:
		var copy: Dictionary = piece.duplicate()
		if int(copy.kind) == source_kind:
			copy.kind = dest_kind
		swapped.append(copy)
	return swapped


func _dwell_as_belt(pieces: Array) -> Array:
	var swapped: Array = []
	for piece in pieces:
		var copy: Dictionary = piece.duplicate()
		if int(copy.kind) == Rules.Kind.DWELL:
			copy.kind = Rules.Kind.BELT
		swapped.append(copy)
	return swapped


func _spare_cell(room: Dictionary) -> Vector2i:
	var used := {}
	for key in ["sources", "sinks", "chutes", "walls"]:
		for entry in room[key]:
			used[Vector2i(int(entry.x), int(entry.y))] = true
	for piece in room.solution:
		used[Vector2i(int(piece.x), int(piece.y))] = true
	for y in int(room.h):
		for x in int(room.w):
			var cell := Vector2i(x, y)
			if not used.has(cell):
				return cell
	return Vector2i(-1, -1)


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
	check(main._kind_for_key(KEY_EQUAL) == Rules.Kind.DROP, "equals selects the drop")
	check(main._kind_for_key(KEY_KP_ADD) == Rules.Kind.DROP, "keypad plus selects the drop")
	check(main._key_label(Rules.Kind.DROP) == "=", "drop key is equals")
	check(main._key_label(Rules.Kind.DROP) != "0", "drop does not reuse the hook key")
	check(main._key_label(Rules.Kind.DROP) != "-", "drop does not reuse the arm key")
	check(main._kind_for_key(KEY_0) == Rules.Kind.HOOK, "hook stays on key 0 beside the drop")
	check(main._kind_for_key(KEY_BACKSLASH) == Rules.Kind.LIFT, "backslash selects the lift")
	check(main._kind_for_key(KEY_KP_MULTIPLY) == Rules.Kind.LIFT, "keypad multiply selects the lift")
	check(main._key_label(Rules.Kind.LIFT) == "\\", "lift key is backslash")
	check(main._key_label(Rules.Kind.LIFT) != "0", "lift does not reuse the hook key")
	check(main._key_label(Rules.Kind.LIFT) != "-", "lift does not reuse the arm key")
	check(main._key_label(Rules.Kind.LIFT) != "=", "lift does not reuse the drop key")
	check(main._kind_for_key(KEY_MINUS) == Rules.Kind.ARM, "minus stays on the arm beside the lift")
	check(main._kind_for_key(KEY_EQUAL) == Rules.Kind.DROP, "equals stays on the drop beside the lift")
	check(main._kind_for_key(KEY_SEMICOLON) == Rules.Kind.DWELL, "semicolon selects the dwell")
	check(main._kind_for_key(KEY_KP_PERIOD) == Rules.Kind.DWELL, "keypad period selects the dwell")
	check(main._key_label(Rules.Kind.DWELL) == ";", "dwell key is semicolon")
	check(main._key_label(Rules.Kind.DWELL) != "0", "dwell does not reuse the hook key")
	check(main._key_label(Rules.Kind.DWELL) != "-", "dwell does not reuse the arm key")
	check(main._key_label(Rules.Kind.DWELL) != "=", "dwell does not reuse the drop key")
	check(main._key_label(Rules.Kind.DWELL) != "\\", "dwell does not reuse the lift key")
	check(main._kind_for_key(KEY_0) == Rules.Kind.HOOK, "hook stays on key 0 beside the dwell")
	check(main._kind_for_key(KEY_MINUS) == Rules.Kind.ARM, "minus stays on the arm beside the dwell")
	check(main._kind_for_key(KEY_EQUAL) == Rules.Kind.DROP, "equals stays on the drop beside the dwell")
	check(main._kind_for_key(KEY_BACKSLASH) == Rules.Kind.LIFT, "backslash stays on the lift beside the dwell")
	check(main._kind_for_key(KEY_COMMA) == Rules.Kind.TWIN, "comma selects the twin")
	check(main._key_label(Rules.Kind.TWIN) == ",", "twin key is comma")
	check(main._key_label(Rules.Kind.TWIN) != "0", "twin does not reuse the hook key")
	check(main._key_label(Rules.Kind.TWIN) != "-", "twin does not reuse the arm key")
	check(main._key_label(Rules.Kind.TWIN) != "=", "twin does not reuse the drop key")
	check(main._key_label(Rules.Kind.TWIN) != "\\", "twin does not reuse the lift key")
	check(main._key_label(Rules.Kind.TWIN) != ";", "twin does not reuse the dwell key")
	check(main._kind_for_key(KEY_0) == Rules.Kind.HOOK, "hook stays on key 0 beside the twin")
	check(main._kind_for_key(KEY_KP_0) == Rules.Kind.HOOK, "keypad 0 stays on the hook")
	check(main._kind_for_key(KEY_MINUS) == Rules.Kind.ARM, "minus stays on the arm beside the twin")
	check(main._kind_for_key(KEY_EQUAL) == Rules.Kind.DROP, "equals stays on the drop beside the twin")
	check(main._kind_for_key(KEY_BACKSLASH) == Rules.Kind.LIFT, "backslash stays on the lift beside the twin")
	check(main._kind_for_key(KEY_SEMICOLON) == Rules.Kind.DWELL, "semicolon stays on the dwell beside the twin")
	check(main._kind_for_key(KEY_APOSTROPHE) == Rules.Kind.PASS, "apostrophe selects the pass")
	check(main._kind_for_key(KEY_KP_DIVIDE) == Rules.Kind.PASS, "keypad divide selects the pass")
	check(main._key_label(Rules.Kind.PASS) == "'", "pass key is apostrophe")
	check(main._key_label(Rules.Kind.PASS) != "0", "pass does not reuse the hook key")
	check(main._key_label(Rules.Kind.PASS) != "-", "pass does not reuse the arm key")
	check(main._key_label(Rules.Kind.PASS) != "=", "pass does not reuse the drop key")
	check(main._key_label(Rules.Kind.PASS) != "\\", "pass does not reuse the lift key")
	check(main._key_label(Rules.Kind.PASS) != ";", "pass does not reuse the dwell key")
	check(main._key_label(Rules.Kind.PASS) != ",", "pass does not reuse the twin key")
	check(main._kind_for_key(KEY_0) == Rules.Kind.HOOK, "hook stays on key 0 beside the pass")
	check(main._kind_for_key(KEY_KP_0) == Rules.Kind.HOOK, "keypad 0 stays on the hook")
	check(main._kind_for_key(KEY_KP_SUBTRACT) == Rules.Kind.ARM, "keypad minus stays on the arm")
	check(main._kind_for_key(KEY_KP_ADD) == Rules.Kind.DROP, "keypad plus stays on the drop")
	check(main._kind_for_key(KEY_KP_MULTIPLY) == Rules.Kind.LIFT, "keypad multiply stays on the lift")
	check(main._kind_for_key(KEY_KP_PERIOD) == Rules.Kind.DWELL, "keypad period stays on the dwell")
	check(main._kind_for_key(KEY_PERIOD) == Rules.Kind.SLIP, "period selects the slip")
	check(main._key_label(Rules.Kind.SLIP) == ".", "slip key is period")
	check(main._key_label(Rules.Kind.SLIP) != "'", "slip does not reuse the pass key")
	check(main._key_label(Rules.Kind.SLIP) != "0", "slip does not reuse the hook key")
	check(main._key_label(Rules.Kind.SLIP) != "-", "slip does not reuse the arm key")
	check(main._key_label(Rules.Kind.SLIP) != "=", "slip does not reuse the drop key")
	check(main._key_label(Rules.Kind.SLIP) != "\\", "slip does not reuse the lift key")
	check(main._key_label(Rules.Kind.SLIP) != ";", "slip does not reuse the dwell key")
	check(main._key_label(Rules.Kind.SLIP) != ",", "slip does not reuse the twin key")
	check(main._kind_for_key(KEY_KP_PERIOD) == Rules.Kind.DWELL, "keypad period stays on the dwell beside the slip")
	check(main._kind_for_key(KEY_KP_DIVIDE) == Rules.Kind.PASS, "keypad divide stays on the pass beside the slip")
	check(main._kind_for_key(KEY_KP_0) == Rules.Kind.HOOK, "keypad 0 stays on the hook beside the slip")
	check(main._kind_for_key(KEY_KP_SUBTRACT) == Rules.Kind.ARM, "keypad minus stays on the arm beside the slip")
	check(main._kind_for_key(KEY_KP_ADD) == Rules.Kind.DROP, "keypad plus stays on the drop beside the slip")
	check(main._kind_for_key(KEY_APOSTROPHE) == Rules.Kind.PASS, "apostrophe stays on the pass beside the slip")
	check(main._kind_for_key(KEY_SLASH) == Rules.Kind.SHED, "slash selects the shed")
	check(main._key_label(Rules.Kind.SHED) == "/", "shed key is slash")
	check(main._key_label(Rules.Kind.SHED) != ".", "shed does not reuse the slip key")
	check(main._key_label(Rules.Kind.SHED) != "'", "shed does not reuse the pass key")
	check(main._key_label(Rules.Kind.SHED) != "0", "shed does not reuse the hook key")
	check(main._key_label(Rules.Kind.SHED) != "-", "shed does not reuse the arm key")
	check(main._key_label(Rules.Kind.SHED) != "=", "shed does not reuse the drop key")
	check(main._key_label(Rules.Kind.SHED) != "\\", "shed does not reuse the lift key")
	check(main._key_label(Rules.Kind.SHED) != ";", "shed does not reuse the dwell key")
	check(main._key_label(Rules.Kind.SHED) != ",", "shed does not reuse the twin key")
	check(main._kind_for_key(KEY_PERIOD) == Rules.Kind.SLIP, "period stays on the slip beside the shed")
	check(main._kind_for_key(KEY_KP_PERIOD) == Rules.Kind.DWELL, "keypad period stays on the dwell beside the shed")
	check(main._kind_for_key(KEY_KP_DIVIDE) == Rules.Kind.PASS, "keypad divide stays on the pass beside the shed")
	check(main._kind_for_key(KEY_KP_0) == Rules.Kind.HOOK, "keypad 0 stays on the hook beside the shed")
	check(main._kind_for_key(KEY_0) == Rules.Kind.HOOK, "0 stays on the hook beside the shed")
	check(main._kind_for_key(KEY_MINUS) == Rules.Kind.ARM, "minus stays on the arm beside the shed")
	check(main._kind_for_key(KEY_EQUAL) == Rules.Kind.DROP, "equals stays on the drop beside the shed")
	check(main._kind_for_key(KEY_BACKSLASH) == Rules.Kind.LIFT, "backslash stays on the lift beside the shed")
	check(main._kind_for_key(KEY_SEMICOLON) == Rules.Kind.DWELL, "semicolon stays on the dwell beside the shed")
	check(main._kind_for_key(KEY_COMMA) == Rules.Kind.TWIN, "comma stays on the twin beside the shed")
	check(main._kind_for_key(KEY_APOSTROPHE) == Rules.Kind.PASS, "apostrophe stays on the pass beside the shed")
	check(main._kind_for_key(KEY_QUOTELEFT) == Rules.Kind.RAKE, "backtick selects the rake")
	check(main._key_label(Rules.Kind.RAKE) == "`", "rake key is backtick")
	check(main._key_label(Rules.Kind.RAKE) != "/", "rake does not reuse the shed key")
	check(main._key_label(Rules.Kind.RAKE) != ".", "rake does not reuse the slip key")
	check(main._key_label(Rules.Kind.RAKE) != "'", "rake does not reuse the pass key")
	check(main._key_label(Rules.Kind.RAKE) != "0", "rake does not reuse the hook key")
	check(main._key_label(Rules.Kind.RAKE) != "-", "rake does not reuse the arm key")
	check(main._key_label(Rules.Kind.RAKE) != "=", "rake does not reuse the drop key")
	check(main._key_label(Rules.Kind.RAKE) != "\\", "rake does not reuse the lift key")
	check(main._key_label(Rules.Kind.RAKE) != ";", "rake does not reuse the dwell key")
	check(main._key_label(Rules.Kind.RAKE) != ",", "rake does not reuse the twin key")
	check(main._kind_for_key(KEY_SLASH) == Rules.Kind.SHED, "slash stays on the shed beside the rake")
	check(main._kind_for_key(KEY_PERIOD) == Rules.Kind.SLIP, "period stays on the slip beside the rake")
	check(main._kind_for_key(KEY_KP_PERIOD) == Rules.Kind.DWELL, "keypad period stays on the dwell beside the rake")
	check(main._kind_for_key(KEY_KP_DIVIDE) == Rules.Kind.PASS, "keypad divide stays on the pass beside the rake")
	check(main._kind_for_key(KEY_KP_0) == Rules.Kind.HOOK, "keypad 0 stays on the hook beside the rake")
	check(main._kind_for_key(KEY_0) == Rules.Kind.HOOK, "0 stays on the hook beside the rake")
	check(main._kind_for_key(KEY_KP_MULTIPLY) == Rules.Kind.LIFT, "keypad multiply stays on the lift beside the rake")
	check(main._kind_for_key(KEY_KP_ADD) == Rules.Kind.DROP, "keypad plus stays on the drop beside the rake")
	check(main._kind_for_key(KEY_KP_SUBTRACT) == Rules.Kind.ARM, "keypad minus stays on the arm beside the rake")
	check(main._kind_for_key(KEY_KP_ENTER) == -1, "keypad enter is not a rake key")
	check(main._kind_for_key(KEY_Y) == Rules.Kind.HOE, "Y selects the hoe")
	check(main._key_label(Rules.Kind.HOE) == "y", "hoe key is Y")
	check(main._key_label(Rules.Kind.HOE) != "`", "hoe does not reuse the rake key")
	check(main._key_label(Rules.Kind.HOE) != "/", "hoe does not reuse the shed key")
	check(main._key_label(Rules.Kind.HOE) != ".", "hoe does not reuse the slip key")
	check(main._key_label(Rules.Kind.HOE) != "'", "hoe does not reuse the pass key")
	check(main._key_label(Rules.Kind.HOE) != "0", "hoe does not reuse the hook key")
	check(main._key_label(Rules.Kind.HOE) != "-", "hoe does not reuse the arm key")
	check(main._key_label(Rules.Kind.HOE) != "=", "hoe does not reuse the drop key")
	check(main._key_label(Rules.Kind.HOE) != "\\", "hoe does not reuse the lift key")
	check(main._key_label(Rules.Kind.HOE) != ";", "hoe does not reuse the dwell key")
	check(main._key_label(Rules.Kind.HOE) != ",", "hoe does not reuse the twin key")
	check(main._kind_for_key(KEY_QUOTELEFT) == Rules.Kind.RAKE, "backtick stays on the rake beside the hoe")
	check(main._kind_for_key(KEY_SLASH) == Rules.Kind.SHED, "slash stays on the shed beside the hoe")
	check(main._kind_for_key(KEY_PERIOD) == Rules.Kind.SLIP, "period stays on the slip beside the hoe")
	check(main._kind_for_key(KEY_KP_PERIOD) == Rules.Kind.DWELL, "keypad period stays on the dwell beside the hoe")
	check(main._kind_for_key(KEY_KP_DIVIDE) == Rules.Kind.PASS, "keypad divide stays on the pass beside the hoe")
	check(main._kind_for_key(KEY_KP_0) == Rules.Kind.HOOK, "keypad 0 stays on the hook beside the hoe")
	check(main._kind_for_key(KEY_0) == Rules.Kind.HOOK, "0 stays on the hook beside the hoe")
	check(main._kind_for_key(KEY_Q) == -1, "Q stays a control beside the hoe")
	check(main._kind_for_key(KEY_E) == -1, "E stays a control beside the hoe")
	check(main._kind_for_key(KEY_R) == -1, "R stays a control beside the hoe")
	check(main._kind_for_key(KEY_F) == -1, "F stays a control beside the hoe")
	check(main._kind_for_key(KEY_SPACE) == -1, "Space stays a control beside the hoe")
	check(main._kind_for_key(KEY_ENTER) == -1, "Enter stays a control beside the hoe")
	check(main._kind_for_key(KEY_BACKSPACE) == -1, "Backspace stays a control beside the hoe")
	check(main._kind_for_key(KEY_BRACKETLEFT) == -1, "[ stays a control beside the hoe")
	check(main._kind_for_key(KEY_BRACKETRIGHT) == -1, "] stays a control beside the hoe")
	check(main._kind_for_key(KEY_COMMA) == Rules.Kind.TWIN, "comma stays on the twin beside the pass")
	check(main._kind_for_key(KEY_MINUS) == Rules.Kind.ARM, "minus stays on the arm beside the pass")
	check(main._kind_for_key(KEY_EQUAL) == Rules.Kind.DROP, "equals stays on the drop beside the pass")
	check(main._kind_for_key(KEY_BACKSLASH) == Rules.Kind.LIFT, "backslash stays on the lift beside the pass")
	check(main._kind_for_key(KEY_SEMICOLON) == Rules.Kind.DWELL, "semicolon stays on the dwell beside the pass")
	check(main._kind_for_key(KEY_KP_ENTER) == -1, "keypad enter stays a control")
	check(main._kind_for_key(KEY_R) == -1, "R stays a control")
	check(main._kind_for_key(KEY_E) == -1, "E stays a control")
	check(main._kind_for_key(KEY_Q) == -1, "Q stays a control")
	check(main._kind_for_key(KEY_SPACE) == -1, "Space stays a control")
	check(main._kind_for_key(KEY_ENTER) == -1, "Enter stays a control")
	check(main._kind_for_key(KEY_F) == -1, "F stays a control")
	check(main._kind_for_key(KEY_BACKSPACE) == -1, "Backspace stays a control")
	check(main._kind_for_key(KEY_BRACKETLEFT) == -1, "[ stays a control")
	check(main._kind_for_key(KEY_BRACKETRIGHT) == -1, "] stays a control")
	var catalog := Rooms.all()
	check(not main.is_unlocked(9), "room 9 stays locked until room 8 is cleared")
	check(not main.is_unlocked(17), "room 17 stays locked until room 16 is cleared")
	check(not main.is_unlocked(25), "room 25 stays locked until room 24 is cleared")
	check(not main.is_unlocked(33), "room 33 stays locked until room 32 is cleared")
	check(not main.is_unlocked(41), "room 41 stays locked until room 40 is cleared")
	check(not main.is_unlocked(49), "room 49 stays locked until room 48 is cleared")
	check(not main.is_unlocked(57), "room 57 stays locked until room 56 is cleared")
	check(not main.is_unlocked(65), "room 65 stays locked until room 64 is cleared")
	check(not main.is_unlocked(73), "room 73 stays locked until room 72 is cleared")
	check(not main.is_unlocked(81), "room 81 stays locked until room 80 is cleared")
	check(not main.is_unlocked(89), "room 89 stays locked until room 88 is cleared")
	check(not main.is_unlocked(97), "room 97 stays locked until room 96 is cleared")
	check(not main.is_unlocked(105), "room 105 stays locked until room 104 is cleared")
	check(not main.is_unlocked(113), "room 113 stays locked until room 112 is cleared")
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
		if index == 47:
			check(main.is_unlocked(49), "clearing room 48 unlocks room 49")
			check(not main.is_unlocked(50), "room 50 stays locked until room 49 is cleared")
		if index == 55:
			check(main.is_unlocked(57), "clearing room 56 unlocks room 57")
			check(not main.is_unlocked(58), "room 58 stays locked until room 57 is cleared")
		if index == 63:
			check(main.is_unlocked(65), "clearing room 64 unlocks room 65")
			check(not main.is_unlocked(66), "room 66 stays locked until room 65 is cleared")
		if index == 71:
			check(main.is_unlocked(73), "clearing room 72 unlocks room 73")
			check(not main.is_unlocked(74), "room 74 stays locked until room 73 is cleared")
		if index == 79:
			check(main.is_unlocked(81), "clearing room 80 unlocks room 81")
			check(not main.is_unlocked(82), "room 82 stays locked until room 81 is cleared")
		if index == 87:
			check(main.is_unlocked(89), "clearing room 88 unlocks room 89")
			check(not main.is_unlocked(90), "room 90 stays locked until room 89 is cleared")
		if index == 95:
			check(main.is_unlocked(97), "clearing room 96 unlocks room 97")
			check(not main.is_unlocked(98), "room 98 stays locked until room 97 is cleared")
		if index == 103:
			check(main.is_unlocked(105), "clearing room 104 unlocks room 105")
			check(not main.is_unlocked(106), "room 106 stays locked until room 105 is cleared")
		if index == 111:
			check(main.is_unlocked(113), "clearing room 112 unlocks room 113")
			check(not main.is_unlocked(114), "room 114 stays locked until room 113 is cleared")
	check(main.is_unlocked(72), "clearing room 71 unlocks room 72")
	check(main.is_unlocked(80), "clearing room 79 unlocks room 80")
	check(main.is_unlocked(88), "clearing room 87 unlocks room 88")
	check(main.is_unlocked(96), "clearing room 95 unlocks room 96")
	check(main.is_unlocked(104), "clearing room 103 unlocks room 104")
	check(main.is_unlocked(112), "clearing room 111 unlocks room 112")
	check(main.is_unlocked(120), "clearing room 119 unlocks room 120")
	check(not main.is_unlocked(121), "there is no room 121 to unlock")
	check(not main.testing_select(120), "room select rejects an unknown room")
	_check_window(main)
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

func _test_slip_keeps_the_first() -> void:
	var ore := _slip_forward([Rules.Mat.ORE], 4)
	var placed := [Rooms.piece(Rules.Kind.SLIP, 1, 0, Rules.Dir.EAST)]
	var early := World.simulate(ore, placed, 4)
	var mid := World.simulate(ore, placed, 8)
	var result := World.simulate(ore, placed, 12)
	var again := World.simulate(ore, placed, 12)
	check(_trace(early) == "" and early.world.machines[Vector2i(1, 0)].hold == Rules.Mat.ORE, "a lone ore is still in the slip after the belt tick and the dwell tick")
	check(_trace(mid) == "5:2,0:0" and mid.world.machines[Vector2i(1, 0)].hold == Rules.Mat.ORE, "the next ore leaves forward and the first ore stays, got %s" % _trace(mid))
	check(_trace(result) == "5:2,0:0|9:2,0:0", "later ore keeps leaving the slip, got %s" % _trace(result))
	check(result.world.machines[Vector2i(1, 0)].hold == Rules.Mat.ORE, "the first ore of the run stays in the slip")
	check(int(result.counts[Rules.Mat.ORE]) == 2, "two ores leave and the first waits")
	check(_same(result, again), "the same slip lane is deterministic (seed %d)" % result.seed)
	var belt := World.simulate(ore, [Rooms.piece(Rules.Kind.BELT, 1, 0, Rules.Dir.EAST)], 12)
	var dwell := World.simulate(ore, [Rooms.piece(Rules.Kind.DWELL, 1, 0, Rules.Dir.EAST)], 12)
	check(_trace(belt) == "2:2,0:0|6:2,0:0|10:2,0:0", "a belt on that cell sends on the next tick, got %s" % _trace(belt))
	check(_trace(dwell) == "3:2,0:0|7:2,0:0|11:2,0:0", "a dwell on that cell sends one tick after a belt, got %s" % _trace(dwell))
	for mat in [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]:
		var lane := _slip_forward([mat], 80)
		var lone := World.simulate(lane, placed, 15)
		check(_trace(lone) == "" and lone.world.machines[Vector2i(1, 0)].hold == mat, "a lone %s never leaves a slip" % Rules.MAT_NAME[mat])
	var mixed := _slip_forward([Rules.Mat.ORE, Rules.Mat.INGOT], 4)
	var held := World.simulate(mixed, placed, 4)
	var pushed := World.simulate(mixed, placed, 8)
	var later := World.simulate(mixed, placed, 12)
	check(_trace(held) == "" and held.world.machines[Vector2i(1, 0)].hold == Rules.Mat.ORE, "a slip does not release before the different material arrives")
	check(_trace(pushed) == "5:2,0:1", "a later item of a different material leaves forward, got %s" % _trace(pushed))
	check(pushed.world.machines[Vector2i(1, 0)].hold == Rules.Mat.ORE, "the first item stays when a different material leaves")
	check(_trace(later) == "5:2,0:1|9:2,0:0" and later.world.machines[Vector2i(1, 0)].hold == Rules.Mat.ORE, "the first ore is still the waiting item after the next ore leaves, got %s" % _trace(later))
	check(int(pushed.world.machines[Vector2i(1, 0)].phase) == 0, "a slip does not rotate or alternate")
	var as_pass := World.simulate(mixed, [Rooms.piece(Rules.Kind.PASS, 1, 0, Rules.Dir.EAST)], 8)
	check(_trace(as_pass) == "5:2,0:0" and as_pass.world.machines[Vector2i(1, 0)].hold == Rules.Mat.INGOT, "a pass sends the waiter and keeps the arrival, got %s" % _trace(as_pass))
	var as_twin := World.simulate(mixed, [Rooms.piece(Rules.Kind.TWIN, 1, 0, Rules.Dir.EAST)], 8)
	check(_trace(as_twin) == "" and as_twin.world.machines[Vector2i(1, 0)].hold == Rules.Mat.ORE, "a twin refuses that different material")
	check(int(as_twin.world.sources[0].pending) == Rules.Mat.INGOT, "the twin leaves the different material on the previous piece")


func _test_slip_refuses_side_and_front() -> void:
	var room := {
		"id": 0,
		"name": "slip refuse",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [
			Rooms.source(0, 1, Rules.Dir.EAST, [Rules.Mat.ORE, Rules.Mat.INGOT], 4),
			Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.PLATE], 1),
			Rooms.source(1, 2, Rules.Dir.NORTH, [Rules.Mat.INGOT], 1),
		],
		"sinks": [Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.SLIP, 1, Rules.Kind.BELT, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var placed := [Rooms.piece(Rules.Kind.SLIP, 1, 1, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 8)
	check(_trace(result) == "5:2,1:1", "slip sends the later ingot forward and keeps the ore, got %s" % _trace(result))
	check(result.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "the first ore stays in the slip")
	check(int(result.counts[Rules.Mat.PLATE]) == 0 and int(result.world.sources[1].pending) == Rules.Mat.PLATE, "slip refuses a plate from the side")
	check(int(result.world.sources[2].pending) == Rules.Mat.INGOT, "slip refuses an ingot from the other side")
	check(int(result.world.machines[Vector2i(1, 1)].phase) == 0, "a slip does not rotate or alternate")
	var side_only := room.duplicate()
	side_only.sources = [Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.PLATE], 1)]
	var belt := World.simulate(side_only, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST)], 4)
	var slip_side := World.simulate(side_only, placed, 4)
	check(_trace(belt) == "2:2,1:2|3:2,1:2|4:2,1:2", "a belt takes a plate from the side, got %s" % _trace(belt))
	check(int(slip_side.counts[Rules.Mat.PLATE]) == 0 and int(slip_side.world.sources[0].pending) == Rules.Mat.PLATE, "a slip refuses that same side plate")
	var front := {
		"id": 0,
		"name": "slip front",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 1,
		"sources": [
			Rooms.source(0, 0, Rules.Dir.EAST, [Rules.Mat.ORE], 4),
			Rooms.source(2, 0, Rules.Dir.WEST, [Rules.Mat.INGOT], 1),
		],
		"sinks": [],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.SLIP, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var blocked := World.simulate(front, [Rooms.piece(Rules.Kind.SLIP, 1, 0, Rules.Dir.EAST)], 6)
	var machine = blocked.world.machines[Vector2i(1, 0)]
	check(int(blocked.world.sources[1].pending) == Rules.Mat.INGOT, "slip refuses a head-on ingot")
	check(machine.hold == Rules.Mat.ORE, "the rear load stays on the slip")
	check(blocked.trace.is_empty(), "a head-on entry does not leave the slip, got %s" % _trace(blocked))
	check(int(machine.phase) == 0, "a head-on entry does not rotate the slip")


func _test_slip_blocked_does_not_spill() -> void:
	var boxed := {
		"id": 0,
		"name": "slip boxed",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [Rooms.source(0, 1, Rules.Dir.EAST, [Rules.Mat.ORE, Rules.Mat.PLATE], 1)],
		"sinks": [
			Rooms.sink(1, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(1, 2, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [Rooms.cell(0, 0)],
		"walls": [Rooms.cell(2, 1)],
		"budget": Rooms.kv([Rules.Kind.SLIP, 1, Rules.Kind.WEIR, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var held := World.simulate(boxed, [Rooms.piece(Rules.Kind.SLIP, 1, 1, Rules.Dir.EAST)], 6)
	check(held.error == "" and held.discarded == 0 and held.trace.is_empty(), "a blocked slip does not spill to the side or back")
	check(held.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "blocked ore stays on the slip")
	check(int(held.world.sources[0].pending) == Rules.Mat.PLATE, "the later item is not accepted while the forward cell refuses")
	check(int(held.counts[Rules.Mat.ORE]) == 0 and int(held.counts[Rules.Mat.PLATE]) == 0, "the blocked slip did not reach a side sink")
	check(int(held.world.machines[Vector2i(1, 1)].phase) == 0, "a slip does not rotate or alternate when blocked")
	var weir := World.simulate(boxed, [Rooms.piece(Rules.Kind.WEIR, 1, 1, Rules.Dir.EAST)], 4)
	check(int(weir.counts[Rules.Mat.ORE]) >= 1, "the same cell lets a weir spill right into the sink")


func _slip_forward(pattern: Array, period: int) -> Dictionary:
	return {
		"id": 0,
		"name": "slip",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 1,
		"sources": [Rooms.source(0, 0, Rules.Dir.EAST, pattern, period)],
		"sinks": [Rooms.sink(2, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.SLIP, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}


func _test_wing12_lessons() -> void:
	var wrong_kinds: Array = [Rules.Kind.BELT, Rules.Kind.DWELL, Rules.Kind.TWIN, Rules.Kind.PASS]
	for index in range(88, 96):
		var room: Dictionary = Rooms.all()[index]
		for kind in wrong_kinds:
			var swapped := _swap_kind(room.solution, Rules.Kind.SLIP, int(kind))
			var run: Dictionary = World.simulate(room, swapped)
			check(run.error == "", "%s in place of the room %d slip simulates (%s)" % [Rules.KIND_NAME[int(kind)], room.id, run.error])
			check(not run.quota_ok, "%s in place of the room %d slip misses the quota (%s)" % [Rules.KIND_NAME[int(kind)], room.id, run.text])
			check(not run.success, "%s in place of the room %d slip does not clear" % [Rules.KIND_NAME[int(kind)], room.id])
		var planner = Planner.new(room)
		for piece in room.initial:
			check(planner.pickup(int(piece.x), int(piece.y)), "room %d picks up its starting piece" % room.id)
		for piece in room.solution:
			check(planner.place(int(piece.kind), int(piece.x), int(piece.y), int(piece.dir)), "room %d places its solution from the tray" % room.id)
		var spare := _spare_cell(room)
		check(spare.x >= 0, "room %d has an empty cell for an extra piece" % room.id)
		check(not planner.place(Rules.Kind.BELT, spare.x, spare.y, Rules.Dir.EAST), "room %d rejects a belt past the tray" % room.id)
		var extra: Array = room.solution.duplicate(true)
		extra.append(Rooms.piece(Rules.Kind.BELT, spare.x, spare.y, Rules.Dir.EAST))
		var over: Dictionary = World.simulate(room, extra)
		check(over.quota_ok and not over.budget_ok and not over.success, "room %d extra belt meets the quota and is rejected (%s)" % [room.id, over.text])
	var hold: Dictionary = Rooms.all()[88]
	var held: Dictionary = World.simulate(hold, hold.solution)
	check(held.world.machines[Vector2i(1, 3)].hold == Rules.Mat.PLATE, "hold keeps the first plate")
	check(int(held.counts[Rules.Mat.PLATE]) >= int(hold.quota[Rules.Mat.PLATE]), "hold delivers the later plates (%s)" % held.text)
	var hold_belt: Dictionary = World.simulate(hold, _swap_kind(hold.solution, Rules.Kind.SLIP, Rules.Kind.BELT))
	var hold_twin: Dictionary = World.simulate(hold, _swap_kind(hold.solution, Rules.Kind.SLIP, Rules.Kind.TWIN))
	var hold_pass: Dictionary = World.simulate(hold, _swap_kind(hold.solution, Rules.Kind.SLIP, Rules.Kind.PASS))
	check(int(hold_belt.counts[Rules.Mat.PLATE]) == 0 and int(hold_belt.discarded) > 0, "hold's belt sends the plate into the pit (%s)" % hold_belt.text)
	check(int(hold_twin.counts[Rules.Mat.PLATE]) == 0 and hold_twin.world.machines[Vector2i(1, 3)].hold == Rules.Mat.PLATE, "hold's twin refuses the other material (%s)" % hold_twin.text)
	check(int(hold_pass.counts[Rules.Mat.PLATE]) < int(hold.quota[Rules.Mat.PLATE]), "hold's pass sends the plate and misses (%s)" % hold_pass.text)
	var keep: Dictionary = Rooms.all()[89]
	var kept: Dictionary = World.simulate(keep, keep.solution)
	check(kept.world.machines[Vector2i(1, 3)].hold == Rules.Mat.ORE, "keep holds the first ore")
	check(int(kept.counts[Rules.Mat.PLATE]) >= int(keep.quota[Rules.Mat.PLATE]), "keep feeds the press (%s)" % kept.text)
	var keep_pass: Dictionary = World.simulate(keep, _swap_kind(keep.solution, Rules.Kind.SLIP, Rules.Kind.PASS))
	check(int(keep_pass.counts[Rules.Mat.PLATE]) == 0, "keep's pass sends the ore onward (%s)" % keep_pass.text)
	var still: Dictionary = Rooms.all()[90]
	var stilled: Dictionary = World.simulate(still, still.solution)
	check(int(still.budget[Rules.Kind.BELT]) == 1, "still budgets one belt")
	check(stilled.world.machines[Vector2i(1, 3)].hold == Rules.Mat.ORE, "still keeps the first ore out of the pit")
	check(int(stilled.counts[Rules.Mat.INGOT]) >= int(still.quota[Rules.Mat.INGOT]), "still's later ore reaches the kiln (%s)" % stilled.text)
	var seat: Dictionary = Rooms.all()[91]
	var parked: Array = seat.initial.duplicate(true)
	parked.append(Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.GRATE, 4, 3, Rules.Dir.EAST))
	var gap: Dictionary = World.simulate(seat, parked)
	check(World.budget_met(parked, seat.budget), "leaving the seat slip parked stays inside the tray")
	check(int(gap.counts[Rules.Mat.PLATE]) == 0 and not gap.quota_ok, "a parked slip leaves a gap and misses (%s)" % gap.text)
	var seat_planner = Planner.new(seat)
	check(seat_planner.at(0, 4) != null and seat_planner.remaining(Rules.Kind.SLIP) == 0, "seat starts with the slip off the tray")
	check(seat_planner.pickup(0, 4), "pickup lifts the pre-placed slip")
	check(seat_planner.at(0, 4) == null and seat_planner.remaining(Rules.Kind.SLIP) == 1, "pre-placed slip returns to the tray")
	check(seat_planner.place(Rules.Kind.SLIP, 1, 3, Rules.Dir.EAST), "the returned slip can be seated on the lane")
	var turn: Dictionary = Rooms.all()[92]
	var into_wall: Dictionary = World.simulate(turn, [
		Rooms.piece(Rules.Kind.BELT, 1, 2, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 2, Rules.Dir.SOUTH),
	])
	check(int(into_wall.counts[Rules.Mat.PLATE]) == 0, "turn belts that turn into the wall deliver nothing")
	check(World.simulate(turn, turn.solution).world.machines[Vector2i(3, 2)].hold == Rules.Mat.PLATE, "turn keeps the first plate in the slip")
	var heat: Dictionary = Rooms.all()[93]
	var one_kiln_pieces: Array = []
	for piece in heat.solution:
		if int(piece.x) == 3 and int(piece.y) >= 2:
			continue
		one_kiln_pieces.append(piece)
	var one_kiln: Dictionary = World.simulate(heat, one_kiln_pieces)
	var both: Dictionary = World.simulate(heat, heat.solution)
	var heat_quota := int(heat.quota[Rules.Mat.INGOT])
	check(int(one_kiln.counts[Rules.Mat.INGOT]) < heat_quota, "one spare-heat kiln misses %d (%s)" % [heat_quota, one_kiln.text])
	check(int(both.counts[Rules.Mat.INGOT]) >= heat_quota, "both spare-heat kilns reach the quota (%s)" % both.text)
	check(int(both.counts[Rules.Mat.INGOT]) > int(one_kiln.counts[Rules.Mat.INGOT]), "the spare-heat spill kiln adds ingots")
	check(both.world.machines[Vector2i(1, 1)].hold == Rules.Mat.PLATE, "spare heat keeps the first plate")
	var scrap: Dictionary = Rooms.all()[94]
	var scraped: Dictionary = World.simulate(scrap, scrap.solution)
	check(int(scraped.counts[Rules.Mat.INGOT]) >= int(scrap.quota[Rules.Mat.INGOT]) and int(scraped.discarded) > 0, "after the hold counts kiln ingots and discards the scrap (%s discarded %d)" % [scraped.text, scraped.discarded])
	check(scraped.world.machines[Vector2i(1, 3)].hold == Rules.Mat.ORE, "after the hold keeps the first ore")
	var no_filter: Dictionary = World.simulate(scrap, [
		Rooms.piece(Rules.Kind.SLIP, 1, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 5, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 6, 3, Rules.Dir.EAST),
	])
	check(int(no_filter.counts[Rules.Mat.INGOT]) < int(scrap.quota[Rules.Mat.INGOT]), "after the hold without a filter misses (%s)" % no_filter.text)
	var both_bins: Dictionary = Rooms.all()[95]
	var solved: Dictionary = World.simulate(both_bins, both_bins.solution)
	check(int(solved.counts[Rules.Mat.INGOT]) >= int(both_bins.quota[Rules.Mat.INGOT]) and int(solved.counts[Rules.Mat.PLATE]) >= int(both_bins.quota[Rules.Mat.PLATE]), "one bin hits both quotas (%s)" % solved.text)
	check(solved.world.machines[Vector2i(1, 3)].hold == Rules.Mat.PLATE, "one bin keeps the first plate")
	var plates_only: Dictionary = World.simulate(both_bins, [
		Rooms.piece(Rules.Kind.BELT, 1, 5, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 5, Rules.Dir.EAST),
	])
	check(int(plates_only.counts[Rules.Mat.INGOT]) == 0 and int(plates_only.counts[Rules.Mat.PLATE]) < int(both_bins.quota[Rules.Mat.PLATE]), "one bin's upper plates alone miss (%s)" % plates_only.text)
	var pressed: Dictionary = World.simulate(both_bins, [
		Rooms.piece(Rules.Kind.BELT, 1, 5, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 5, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.SLIP, 1, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.FILTER, 4, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 5, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 6, 3, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 6, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.PRESS, 7, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 8, 4, Rules.Dir.EAST),
	])
	check(int(pressed.counts[Rules.Mat.INGOT]) == 0 and not pressed.success, "pressing every ingot misses one bin (%s)" % pressed.text)
	for kind in wrong_kinds:
		var missed: Dictionary = World.simulate(both_bins, _swap_kind(both_bins.solution, Rules.Kind.SLIP, int(kind)))
		check(int(missed.counts[Rules.Mat.INGOT]) < int(both_bins.quota[Rules.Mat.INGOT]) and int(missed.counts[Rules.Mat.PLATE]) < int(both_bins.quota[Rules.Mat.PLATE]), "%s in place of the one-bin slip misses both quotas (%s)" % [Rules.KIND_NAME[int(kind)], missed.text])


func _test_shed_keeps_the_first() -> void:
	var ore := _shed_left([Rules.Mat.ORE], 4)
	var placed := [Rooms.piece(Rules.Kind.SHED, 1, 1, Rules.Dir.EAST)]
	var early := World.simulate(ore, placed, 4)
	var mid := World.simulate(ore, placed, 8)
	var result := World.simulate(ore, placed, 12)
	var again := World.simulate(ore, placed, 12)
	check(_trace(early) == "" and early.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "a lone ore is still in the shed after the belt tick and the dwell tick")
	check(_trace(mid) == "5:1,0:0" and mid.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "the next ore leaves left and the first ore stays, got %s" % _trace(mid))
	check(_trace(result) == "5:1,0:0|9:1,0:0", "later ore keeps leaving the shed to the left, got %s" % _trace(result))
	check(result.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "the first ore of the run stays in the shed")
	check(int(result.counts[Rules.Mat.ORE]) == 2, "two ores leave left and the first waits")
	check(not ("2,1:" in _trace(result)), "a shed does not send the later ore forward")
	check(_same(result, again), "the same shed lane is deterministic (seed %d)" % result.seed)
	var belt := World.simulate(ore, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST)], 12)
	var dwell := World.simulate(ore, [Rooms.piece(Rules.Kind.DWELL, 1, 1, Rules.Dir.EAST)], 12)
	check(_trace(belt) == "2:2,1:0|6:2,1:0|10:2,1:0", "a belt on that cell sends forward on the next tick, got %s" % _trace(belt))
	check(_trace(dwell) == "3:2,1:0|7:2,1:0|11:2,1:0", "a dwell on that cell sends forward one tick after a belt, got %s" % _trace(dwell))
	var hook := World.simulate(ore, [Rooms.piece(Rules.Kind.HOOK, 1, 1, Rules.Dir.EAST)], 12)
	check(_trace(hook) == "2:1,0:0|6:1,0:0|10:1,0:0", "a hook sends its one item left and does not keep the first, got %s" % _trace(hook))
	check(hook.world.machines[Vector2i(1, 1)].hold < 0, "a hook does not keep a first item in place")
	for mat in [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]:
		var lane := _shed_left([mat], 80)
		var lone := World.simulate(lane, placed, 15)
		check(_trace(lone) == "" and lone.world.machines[Vector2i(1, 1)].hold == mat, "a lone %s never leaves a shed" % Rules.MAT_NAME[mat])
	var mixed := _shed_left([Rules.Mat.ORE, Rules.Mat.INGOT], 4)
	var held := World.simulate(mixed, placed, 4)
	var pushed := World.simulate(mixed, placed, 8)
	var later := World.simulate(mixed, placed, 12)
	check(_trace(held) == "" and held.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "a shed does not release before the different material arrives")
	check(_trace(pushed) == "5:1,0:1", "a later item of a different material leaves left, got %s" % _trace(pushed))
	check(pushed.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "the first item stays when a different material leaves left")
	check(_trace(later) == "5:1,0:1|9:1,0:0" and later.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "the first ore is still the waiting item after the next ore leaves left, got %s" % _trace(later))
	check(int(pushed.world.machines[Vector2i(1, 1)].phase) == 0, "a shed does not rotate or alternate")
	var as_slip := World.simulate(mixed, [Rooms.piece(Rules.Kind.SLIP, 1, 1, Rules.Dir.EAST)], 8)
	check(_trace(as_slip) == "5:2,1:1" and as_slip.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "a slip sends that arrival forward and keeps the first, got %s" % _trace(as_slip))
	var as_pass := World.simulate(mixed, [Rooms.piece(Rules.Kind.PASS, 1, 1, Rules.Dir.EAST)], 8)
	check(_trace(as_pass) == "5:2,1:0" and as_pass.world.machines[Vector2i(1, 1)].hold == Rules.Mat.INGOT, "a pass sends the waiter forward and keeps the arrival, got %s" % _trace(as_pass))
	var as_twin := World.simulate(mixed, [Rooms.piece(Rules.Kind.TWIN, 1, 1, Rules.Dir.EAST)], 8)
	check(_trace(as_twin) == "" and as_twin.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "a twin refuses that different material")
	check(int(as_twin.world.sources[0].pending) == Rules.Mat.INGOT, "the twin leaves the different material on the previous piece")
	var south := {
		"id": 0,
		"name": "shed south",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.ORE, Rules.Mat.INGOT], 4)],
		"sinks": [
			Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(1, 2, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.SHED, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var turned := World.simulate(south, [Rooms.piece(Rules.Kind.SHED, 1, 1, Rules.Dir.SOUTH)], 8)
	check(_trace(turned) == "5:2,1:1" and turned.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "a south-facing shed sends the later item east, got %s" % _trace(turned))


func _test_shed_refuses_side_and_front() -> void:
	var room := {
		"id": 0,
		"name": "shed refuse",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [
			Rooms.source(0, 1, Rules.Dir.EAST, [Rules.Mat.ORE, Rules.Mat.INGOT], 4),
			Rooms.source(1, 2, Rules.Dir.NORTH, [Rules.Mat.INGOT], 1),
			Rooms.source(2, 1, Rules.Dir.WEST, [Rules.Mat.PLATE], 1),
		],
		"sinks": [Rooms.sink(1, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.SHED, 1, Rules.Kind.BELT, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var placed := [Rooms.piece(Rules.Kind.SHED, 1, 1, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 8)
	check(_trace(result) == "5:1,0:1", "shed sends the later ingot left and keeps the ore, got %s" % _trace(result))
	check(result.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "the first ore stays in the shed")
	check(int(result.world.sources[1].pending) == Rules.Mat.INGOT, "shed refuses an ingot from the side")
	check(int(result.world.sources[2].pending) == Rules.Mat.PLATE, "shed refuses a head-on plate")
	check(int(result.world.machines[Vector2i(1, 1)].phase) == 0, "a shed does not rotate or alternate")
	var side_only := {
		"id": 0,
		"name": "shed side",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.PLATE], 1)],
		"sinks": [Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.SHED, 1, Rules.Kind.BELT, 1]),
		"quota": Rooms.kv([Rules.Mat.PLATE, 1]),
		"initial": [],
		"solution": [],
	}
	var belt := World.simulate(side_only, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST)], 4)
	var shed_side := World.simulate(side_only, placed, 4)
	check(_trace(belt) == "2:2,1:2|3:2,1:2|4:2,1:2", "a belt takes a plate from the side, got %s" % _trace(belt))
	check(int(shed_side.counts[Rules.Mat.PLATE]) == 0 and int(shed_side.world.sources[0].pending) == Rules.Mat.PLATE, "a shed refuses that same side plate")
	var front := {
		"id": 0,
		"name": "shed front",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 1,
		"sources": [
			Rooms.source(0, 0, Rules.Dir.EAST, [Rules.Mat.ORE], 4),
			Rooms.source(2, 0, Rules.Dir.WEST, [Rules.Mat.INGOT], 1),
		],
		"sinks": [],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.SHED, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var blocked := World.simulate(front, [Rooms.piece(Rules.Kind.SHED, 1, 0, Rules.Dir.EAST)], 6)
	var machine = blocked.world.machines[Vector2i(1, 0)]
	check(int(blocked.world.sources[1].pending) == Rules.Mat.INGOT, "shed refuses a head-on ingot")
	check(machine.hold == Rules.Mat.ORE, "the rear load stays on the shed")
	check(blocked.trace.is_empty(), "a head-on entry does not leave the shed, got %s" % _trace(blocked))
	check(int(machine.phase) == 0, "a head-on entry does not rotate the shed")


func _test_shed_blocked_does_not_spill() -> void:
	var boxed := {
		"id": 0,
		"name": "shed boxed",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [Rooms.source(0, 1, Rules.Dir.EAST, [Rules.Mat.ORE, Rules.Mat.PLATE], 1)],
		"sinks": [
			Rooms.sink(1, 2, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [Rooms.cell(0, 0), Rooms.cell(2, 0)],
		"walls": [Rooms.cell(1, 0), Rooms.cell(2, 1)],
		"budget": Rooms.kv([Rules.Kind.SHED, 1, Rules.Kind.WEIR, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var held := World.simulate(boxed, [Rooms.piece(Rules.Kind.SHED, 1, 1, Rules.Dir.EAST)], 6)
	check(held.error == "" and held.discarded == 0 and held.trace.is_empty(), "a blocked shed does not spill forward, right, or back")
	check(held.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "blocked ore stays on the shed")
	check(int(held.world.sources[0].pending) == Rules.Mat.PLATE, "the later item is not accepted while the left cell refuses")
	check(int(held.counts[Rules.Mat.ORE]) == 0 and int(held.counts[Rules.Mat.PLATE]) == 0, "the blocked shed did not reach a forward or right sink")
	check(int(held.world.machines[Vector2i(1, 1)].phase) == 0, "a shed does not rotate or alternate when blocked")
	var weir := World.simulate(boxed, [Rooms.piece(Rules.Kind.WEIR, 1, 1, Rules.Dir.EAST)], 4)
	check(int(weir.counts[Rules.Mat.ORE]) >= 1, "the same cell lets a weir spill right into the sink")


func _shed_left(pattern: Array, period: int) -> Dictionary:
	return {
		"id": 0,
		"name": "shed",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 2,
		"sources": [Rooms.source(0, 1, Rules.Dir.EAST, pattern, period)],
		"sinks": [
			Rooms.sink(1, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.SHED, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}


func _test_wing13_lessons() -> void:
	var wrong_kinds: Array = [Rules.Kind.BELT, Rules.Kind.DWELL, Rules.Kind.TWIN, Rules.Kind.PASS, Rules.Kind.SLIP]
	for index in range(96, 104):
		var room: Dictionary = Rooms.all()[index]
		for kind in wrong_kinds:
			var swapped := _swap_kind(room.solution, Rules.Kind.SHED, int(kind))
			var run: Dictionary = World.simulate(room, swapped)
			check(run.error == "", "%s in place of the room %d shed simulates (%s)" % [Rules.KIND_NAME[int(kind)], room.id, run.error])
			check(not run.quota_ok, "%s in place of the room %d shed misses the quota (%s)" % [Rules.KIND_NAME[int(kind)], room.id, run.text])
			check(not run.success, "%s in place of the room %d shed does not clear" % [Rules.KIND_NAME[int(kind)], room.id])
		var planner = Planner.new(room)
		for piece in room.initial:
			check(planner.pickup(int(piece.x), int(piece.y)), "room %d picks up its starting piece" % room.id)
		for piece in room.solution:
			check(planner.place(int(piece.kind), int(piece.x), int(piece.y), int(piece.dir)), "room %d places its solution from the tray" % room.id)
		var spare := _spare_cell(room)
		check(spare.x >= 0, "room %d has an empty cell for an extra piece" % room.id)
		check(not planner.place(Rules.Kind.BELT, spare.x, spare.y, Rules.Dir.EAST), "room %d rejects a belt past the tray" % room.id)
		var extra: Array = room.solution.duplicate(true)
		extra.append(Rooms.piece(Rules.Kind.BELT, spare.x, spare.y, Rules.Dir.EAST))
		var over: Dictionary = World.simulate(room, extra)
		check(over.quota_ok and not over.budget_ok and not over.success, "room %d extra belt meets the quota and is rejected (%s)" % [room.id, over.text])
	var aside: Dictionary = Rooms.all()[96]
	var held: Dictionary = World.simulate(aside, aside.solution)
	check(held.world.machines[Vector2i(1, 3)].hold == Rules.Mat.PLATE, "aside keeps the first plate")
	check(int(held.counts[Rules.Mat.PLATE]) >= int(aside.quota[Rules.Mat.PLATE]), "aside delivers the later plates (%s)" % held.text)
	var aside_belt: Dictionary = World.simulate(aside, _swap_kind(aside.solution, Rules.Kind.SHED, Rules.Kind.BELT))
	var aside_twin: Dictionary = World.simulate(aside, _swap_kind(aside.solution, Rules.Kind.SHED, Rules.Kind.TWIN))
	var aside_slip: Dictionary = World.simulate(aside, _swap_kind(aside.solution, Rules.Kind.SHED, Rules.Kind.SLIP))
	check(int(aside_belt.counts[Rules.Mat.PLATE]) == 0 and int(aside_belt.discarded) > 0, "aside's belt sends the plate into the pit (%s)" % aside_belt.text)
	check(int(aside_twin.counts[Rules.Mat.PLATE]) == 0 and aside_twin.world.machines[Vector2i(1, 3)].hold == Rules.Mat.PLATE, "aside's twin refuses the other material (%s)" % aside_twin.text)
	check(int(aside_slip.counts[Rules.Mat.PLATE]) == 0 and int(aside_slip.discarded) > 0, "aside's slip sends the later items forward (%s)" % aside_slip.text)
	var keep: Dictionary = Rooms.all()[97]
	var kept: Dictionary = World.simulate(keep, keep.solution)
	check(kept.world.machines[Vector2i(1, 3)].hold == Rules.Mat.ORE, "keep left holds the first ore")
	check(int(kept.counts[Rules.Mat.PLATE]) >= int(keep.quota[Rules.Mat.PLATE]), "keep left feeds the press (%s)" % kept.text)
	var keep_slip: Dictionary = World.simulate(keep, _swap_kind(keep.solution, Rules.Kind.SHED, Rules.Kind.SLIP))
	check(int(keep_slip.counts[Rules.Mat.PLATE]) == 0, "keep left's slip sends the ingots forward, off the press (%s)" % keep_slip.text)
	var still: Dictionary = Rooms.all()[98]
	var stilled: Dictionary = World.simulate(still, still.solution)
	check(int(still.budget[Rules.Kind.BELT]) == 1, "still left budgets one belt")
	check(stilled.world.machines[Vector2i(1, 3)].hold == Rules.Mat.ORE, "still left keeps the first ore out of the pit")
	check(int(stilled.counts[Rules.Mat.INGOT]) >= int(still.quota[Rules.Mat.INGOT]), "still left's later ore reaches the kiln (%s)" % stilled.text)
	var seat: Dictionary = Rooms.all()[99]
	var parked: Array = seat.initial.duplicate(true)
	parked.append(Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.GRATE, 4, 3, Rules.Dir.EAST))
	var gap: Dictionary = World.simulate(seat, parked)
	check(World.budget_met(parked, seat.budget), "leaving the seat shed parked stays inside the tray")
	check(int(gap.counts[Rules.Mat.PLATE]) == 0 and not gap.quota_ok, "a parked shed leaves a gap and misses (%s)" % gap.text)
	var seat_planner = Planner.new(seat)
	check(seat_planner.at(0, 4) != null and seat_planner.remaining(Rules.Kind.SHED) == 0, "seat starts with the shed off the tray")
	check(seat_planner.pickup(0, 4), "pickup lifts the pre-placed shed")
	check(seat_planner.at(0, 4) == null and seat_planner.remaining(Rules.Kind.SHED) == 1, "pre-placed shed returns to the tray")
	check(seat_planner.place(Rules.Kind.SHED, 1, 3, Rules.Dir.SOUTH), "the returned shed can be seated on the lane")
	var corner: Dictionary = Rooms.all()[100]
	var into_wall: Dictionary = World.simulate(corner, [
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST),
	])
	check(int(into_wall.counts[Rules.Mat.PLATE]) == 0, "corner belts that run into the wall deliver nothing")
	check(World.simulate(corner, corner.solution).world.machines[Vector2i(3, 2)].hold == Rules.Mat.PLATE, "corner keeps the first plate in the shed")
	var heat: Dictionary = Rooms.all()[101]
	var one_kiln_pieces: Array = []
	var no_forward: Array = []
	for piece in heat.solution:
		if not (int(piece.x) == 3 and int(piece.y) >= 2):
			one_kiln_pieces.append(piece)
		if not (int(piece.x) == 1 and int(piece.y) >= 2):
			no_forward.append(piece)
	var one_kiln: Dictionary = World.simulate(heat, one_kiln_pieces)
	var left_only: Dictionary = World.simulate(heat, no_forward)
	var both: Dictionary = World.simulate(heat, heat.solution)
	var heat_quota := int(heat.quota[Rules.Mat.INGOT])
	check(int(one_kiln.counts[Rules.Mat.INGOT]) < heat_quota, "one left-heat kiln misses %d (%s)" % [heat_quota, one_kiln.text])
	check(int(left_only.counts[Rules.Mat.INGOT]) < heat_quota, "the left kilns without the forward lane miss %d (%s)" % [heat_quota, left_only.text])
	check(int(both.counts[Rules.Mat.INGOT]) >= heat_quota, "left heat reaches the quota (%s)" % both.text)
	check(int(both.counts[Rules.Mat.INGOT]) > int(one_kiln.counts[Rules.Mat.INGOT]), "the left-heat spill kiln adds ingots")
	check(both.world.machines[Vector2i(1, 1)].hold == Rules.Mat.PLATE, "left heat keeps the first plate")
	var heat_slip: Dictionary = World.simulate(heat, _swap_kind(heat.solution, Rules.Kind.SHED, Rules.Kind.SLIP))
	check(int(heat_slip.counts[Rules.Mat.INGOT]) < heat_quota, "left heat's slip feeds the forward lane and misses (%s)" % heat_slip.text)
	var scrap: Dictionary = Rooms.all()[102]
	var scraped: Dictionary = World.simulate(scrap, scrap.solution)
	check(int(scraped.counts[Rules.Mat.INGOT]) >= int(scrap.quota[Rules.Mat.INGOT]) and int(scraped.discarded) > 0, "after the stay counts kiln ingots and discards the scrap (%s discarded %d)" % [scraped.text, scraped.discarded])
	check(scraped.world.machines[Vector2i(1, 3)].hold == Rules.Mat.ORE, "after the stay keeps the first ore")
	var scrap_slip: Dictionary = World.simulate(scrap, _swap_kind(scrap.solution, Rules.Kind.SHED, Rules.Kind.SLIP))
	check(int(scrap_slip.counts[Rules.Mat.INGOT]) == 0 and int(scrap_slip.discarded) > 0, "after the stay's slip sends the ore into the scrap (%s)" % scrap_slip.text)
	var no_filter: Dictionary = World.simulate(scrap, [
		Rooms.piece(Rules.Kind.SHED, 1, 3, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 5, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 6, 3, Rules.Dir.EAST),
	])
	check(int(no_filter.counts[Rules.Mat.INGOT]) < int(scrap.quota[Rules.Mat.INGOT]), "after the stay without a filter misses (%s)" % no_filter.text)
	var side_bin: Dictionary = Rooms.all()[103]
	var solved: Dictionary = World.simulate(side_bin, side_bin.solution)
	check(int(solved.counts[Rules.Mat.INGOT]) >= int(side_bin.quota[Rules.Mat.INGOT]) and int(solved.counts[Rules.Mat.PLATE]) >= int(side_bin.quota[Rules.Mat.PLATE]), "side bin hits both quotas (%s)" % solved.text)
	check(solved.world.machines[Vector2i(1, 3)].hold == Rules.Mat.PLATE, "side bin keeps the first plate")
	var plates_only: Dictionary = World.simulate(side_bin, [
		Rooms.piece(Rules.Kind.BELT, 1, 5, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 5, Rules.Dir.EAST),
	])
	check(int(plates_only.counts[Rules.Mat.INGOT]) == 0 and int(plates_only.counts[Rules.Mat.PLATE]) < int(side_bin.quota[Rules.Mat.PLATE]), "side bin's upper plates alone miss (%s)" % plates_only.text)
	var pressed: Dictionary = World.simulate(side_bin, [
		Rooms.piece(Rules.Kind.BELT, 1, 5, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 5, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.SHED, 1, 3, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.FILTER, 4, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 5, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 6, 3, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 6, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.PRESS, 7, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 8, 4, Rules.Dir.EAST),
	])
	check(int(pressed.counts[Rules.Mat.INGOT]) == 0 and not pressed.success, "pressing every ingot misses side bin (%s)" % pressed.text)
	for kind in wrong_kinds:
		var missed: Dictionary = World.simulate(side_bin, _swap_kind(side_bin.solution, Rules.Kind.SHED, int(kind)))
		check(int(missed.counts[Rules.Mat.INGOT]) < int(side_bin.quota[Rules.Mat.INGOT]) and int(missed.counts[Rules.Mat.PLATE]) < int(side_bin.quota[Rules.Mat.PLATE]), "%s in place of the side-bin shed misses both quotas (%s)" % [Rules.KIND_NAME[int(kind)], missed.text])


func _check_window(main) -> void:
	check(main.testing_select(103), "select the shed side bin to measure the window")
	var shed_lay: Dictionary = main._layout()
	var size: Vector2 = shed_lay.size
	check(size.x == 1280.0 and size.y == 720.0, "the window is 1280 by 720 (%s)" % size)
	_check_tray_fits(shed_lay, "shed side bin")
	var shed_tab: Rect2 = shed_lay.tabs[103]
	check(shed_tab.position.y + shed_tab.size.y < (shed_lay.play as Rect2).position.y, "the shed room tab stays above the board")
	check(main.testing_select(111), "select the rake side bin to measure the window")
	var rake_lay: Dictionary = main._layout()
	_check_tray_fits(rake_lay, "rake side bin")
	var rake_tab: Rect2 = rake_lay.tabs[111]
	check(rake_tab.position.y + rake_tab.size.y < (rake_lay.play as Rect2).position.y, "the rake room tab stays above the board")
	check(main.testing_select(119), "select the hoe side bin to measure the window")
	var hoe_lay: Dictionary = main._layout()
	_check_tray_fits(hoe_lay, "hoe side bin")
	var hoe_tab: Rect2 = hoe_lay.tabs[119]
	check(hoe_tab.position.y + hoe_tab.size.y < (hoe_lay.play as Rect2).position.y, "the hoe room tab stays above the board")
	check(shed_tab.position.y + shed_tab.size.y < (hoe_lay.play as Rect2).position.y, "the twelfth room row still leaves the shed tab above the board")
	var footer := "1-9 0 - = \\ ; , ' . / ` y select   R rotate   LMB place or pick up   RMB rotate   Space run   F skip   Bksp restart"
	var footer_size: Vector2 = main.font.get_string_size(footer, HORIZONTAL_ALIGNMENT_LEFT, -1, 13)
	var footer_w := footer_size.x
	check(footer_w <= size.x - 48.0, "the footer fits the window (%s px)" % footer_w)
	check(footer_w > 600.0, "the footer stays readable (%s px)" % footer_w)
	var tab_w: float = shed_lay.tabs[0].size.x
	check(absf(tab_w - 116.0) < 0.01, "the room tab stays 116 px wide (%s)" % tab_w)
	var worst := ""
	var worst_w := 0.0
	for room in Rooms.all():
		var label := "%d  %s" % [int(room.id), room.name]
		var label_size: Vector2 = main.font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10)
		var width := label_size.x
		if width > worst_w:
			worst_w = width
			worst = label
	check(worst_w <= tab_w, "the room strip fits %s (%s px in %s)" % [worst, worst_w, tab_w])


func _check_tray_fits(lay: Dictionary, label: String) -> void:
	var size: Vector2 = lay.size
	var play: Rect2 = lay.play
	check(play.size.x > 0.0 and play.size.y > 0.0 and float(lay.cell) >= 24.0, "%s board still has room to draw (%s)" % [label, lay.cell])
	var saw_shed := false
	var saw_rake := false
	var saw_hoe := false
	for slot in lay.tray:
		var rect: Rect2 = slot.rect
		check(rect.position.x >= 0.0 and rect.position.y >= play.position.y + play.size.y, "%s tray stays below the board" % label)
		check(rect.position.x + rect.size.x <= size.x and rect.position.y + rect.size.y <= size.y - 24.0, "%s tray stays inside the window" % label)
		if int(slot.kind) == Rules.Kind.SHED:
			saw_shed = true
		if int(slot.kind) == Rules.Kind.RAKE:
			saw_rake = true
		if int(slot.kind) == Rules.Kind.HOE:
			saw_hoe = true
	if label.begins_with("shed"):
		check(saw_shed, "the shed tray slot is on the shed room")
	elif label.begins_with("hoe"):
		check(saw_hoe, "the hoe tray slot is on the hoe room")
	else:
		check(saw_rake, "the rake tray slot is on the rake room")


func _test_rake_sends_the_waiter() -> void:
	var ore := _rake_left([Rules.Mat.ORE], 4)
	var placed := [Rooms.piece(Rules.Kind.RAKE, 1, 1, Rules.Dir.EAST)]
	var early := World.simulate(ore, placed, 4)
	var mid := World.simulate(ore, placed, 8)
	var result := World.simulate(ore, placed, 12)
	var again := World.simulate(ore, placed, 12)
	check(_trace(early) == "" and early.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "a lone ore is still in the rake after the belt tick and the dwell tick")
	check(_trace(mid) == "5:1,0:0" and mid.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "the first ore leaves left and the next ore waits, got %s" % _trace(mid))
	check(_trace(result) == "5:1,0:0|9:1,0:0", "later ore keeps leaving the rake to the left, got %s" % _trace(result))
	check(result.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "the latest ore of the run stays in the rake")
	check(int(result.counts[Rules.Mat.ORE]) == 2, "two ores leave left and the latest waits")
	check(not ("2,1:" in _trace(result)), "a rake does not send the waiter forward")
	check(_same(result, again), "the same rake lane is deterministic (seed %d)" % result.seed)
	var belt := World.simulate(ore, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST)], 12)
	var dwell := World.simulate(ore, [Rooms.piece(Rules.Kind.DWELL, 1, 1, Rules.Dir.EAST)], 12)
	check(_trace(belt) == "2:2,1:0|6:2,1:0|10:2,1:0", "a belt on that cell sends forward on the next tick, got %s" % _trace(belt))
	check(_trace(dwell) == "3:2,1:0|7:2,1:0|11:2,1:0", "a dwell on that cell sends forward one tick after a belt, got %s" % _trace(dwell))
	var hook := World.simulate(ore, [Rooms.piece(Rules.Kind.HOOK, 1, 1, Rules.Dir.EAST)], 12)
	check(_trace(hook) == "2:1,0:0|6:1,0:0|10:1,0:0", "a hook sends its one item left and does not keep a last item, got %s" % _trace(hook))
	check(hook.world.machines[Vector2i(1, 1)].hold < 0, "a hook does not keep an item in place")
	for mat in [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]:
		var lane := _rake_left([mat], 80)
		var lone := World.simulate(lane, placed, 15)
		check(_trace(lone) == "" and lone.world.machines[Vector2i(1, 1)].hold == mat, "a lone %s never leaves a rake" % Rules.MAT_NAME[mat])
	var mixed := _rake_left([Rules.Mat.ORE, Rules.Mat.INGOT], 4)
	var held := World.simulate(mixed, placed, 4)
	var pushed := World.simulate(mixed, placed, 8)
	var later := World.simulate(mixed, placed, 12)
	check(_trace(held) == "" and held.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "a rake does not release before the different material arrives")
	check(_trace(pushed) == "5:1,0:0", "the waiting ore leaves left when a different material arrives, got %s" % _trace(pushed))
	check(pushed.world.machines[Vector2i(1, 1)].hold == Rules.Mat.INGOT, "the arrival stays when the waiter leaves left")
	check(_trace(later) == "5:1,0:0|9:1,0:1" and later.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "the next arrival becomes the waiting item, got %s" % _trace(later))
	check(int(pushed.world.machines[Vector2i(1, 1)].phase) == 0, "a rake does not rotate or alternate")
	var as_slip := World.simulate(mixed, [Rooms.piece(Rules.Kind.SLIP, 1, 1, Rules.Dir.EAST)], 8)
	check(_trace(as_slip) == "5:2,1:1" and as_slip.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "a slip sends that arrival forward and keeps the first, got %s" % _trace(as_slip))
	var as_pass := World.simulate(mixed, [Rooms.piece(Rules.Kind.PASS, 1, 1, Rules.Dir.EAST)], 8)
	check(_trace(as_pass) == "5:2,1:0" and as_pass.world.machines[Vector2i(1, 1)].hold == Rules.Mat.INGOT, "a pass sends the waiter forward and keeps the arrival, got %s" % _trace(as_pass))
	var as_twin := World.simulate(mixed, [Rooms.piece(Rules.Kind.TWIN, 1, 1, Rules.Dir.EAST)], 8)
	check(_trace(as_twin) == "" and as_twin.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "a twin refuses that different material")
	check(int(as_twin.world.sources[0].pending) == Rules.Mat.INGOT, "the twin leaves the different material on the previous piece")
	var as_shed := World.simulate(mixed, [Rooms.piece(Rules.Kind.SHED, 1, 1, Rules.Dir.EAST)], 8)
	check(_trace(as_shed) == "5:1,0:1" and as_shed.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "a shed sends the arrival left and keeps the waiter, got %s" % _trace(as_shed))
	var south := {
		"id": 0,
		"name": "rake south",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.ORE, Rules.Mat.INGOT], 4)],
		"sinks": [
			Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(1, 2, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.RAKE, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var turned := World.simulate(south, [Rooms.piece(Rules.Kind.RAKE, 1, 1, Rules.Dir.SOUTH)], 8)
	check(_trace(turned) == "5:2,1:0" and turned.world.machines[Vector2i(1, 1)].hold == Rules.Mat.INGOT, "a south-facing rake sends the waiter east and keeps the arrival, got %s" % _trace(turned))


func _test_rake_refuses_side_and_front() -> void:
	var room := {
		"id": 0,
		"name": "rake refuse",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [
			Rooms.source(0, 1, Rules.Dir.EAST, [Rules.Mat.ORE, Rules.Mat.INGOT], 4),
			Rooms.source(1, 2, Rules.Dir.NORTH, [Rules.Mat.INGOT], 1),
			Rooms.source(2, 1, Rules.Dir.WEST, [Rules.Mat.PLATE], 1),
		],
		"sinks": [Rooms.sink(1, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.RAKE, 1, Rules.Kind.BELT, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var placed := [Rooms.piece(Rules.Kind.RAKE, 1, 1, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 8)
	check(_trace(result) == "5:1,0:0", "rake sends the waiting ore left and keeps the ingot, got %s" % _trace(result))
	check(result.world.machines[Vector2i(1, 1)].hold == Rules.Mat.INGOT, "the arrival stays in the rake")
	check(int(result.world.sources[1].pending) == Rules.Mat.INGOT, "rake refuses an ingot from the side")
	check(int(result.world.sources[2].pending) == Rules.Mat.PLATE, "rake refuses a head-on plate")
	check(int(result.world.machines[Vector2i(1, 1)].phase) == 0, "a rake does not rotate or alternate")
	var side_only := {
		"id": 0,
		"name": "rake side",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.PLATE], 1)],
		"sinks": [Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.RAKE, 1, Rules.Kind.BELT, 1]),
		"quota": Rooms.kv([Rules.Mat.PLATE, 1]),
		"initial": [],
		"solution": [],
	}
	var belt := World.simulate(side_only, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST)], 4)
	var rake_side := World.simulate(side_only, placed, 4)
	check(_trace(belt) == "2:2,1:2|3:2,1:2|4:2,1:2", "a belt takes a plate from the side, got %s" % _trace(belt))
	check(int(rake_side.counts[Rules.Mat.PLATE]) == 0 and int(rake_side.world.sources[0].pending) == Rules.Mat.PLATE, "a rake refuses that same side plate")
	var front := {
		"id": 0,
		"name": "rake front",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 1,
		"sources": [
			Rooms.source(0, 0, Rules.Dir.EAST, [Rules.Mat.ORE], 4),
			Rooms.source(2, 0, Rules.Dir.WEST, [Rules.Mat.INGOT], 1),
		],
		"sinks": [],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.RAKE, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var blocked := World.simulate(front, [Rooms.piece(Rules.Kind.RAKE, 1, 0, Rules.Dir.EAST)], 6)
	var machine = blocked.world.machines[Vector2i(1, 0)]
	check(int(blocked.world.sources[1].pending) == Rules.Mat.INGOT, "rake refuses a head-on ingot")
	check(machine.hold == Rules.Mat.ORE, "the rear load stays on the rake")
	check(blocked.trace.is_empty(), "a head-on entry does not leave the rake, got %s" % _trace(blocked))
	check(int(machine.phase) == 0, "a head-on entry does not rotate the rake")


func _test_rake_blocked_does_not_spill() -> void:
	var boxed := {
		"id": 0,
		"name": "rake boxed",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [Rooms.source(0, 1, Rules.Dir.EAST, [Rules.Mat.ORE, Rules.Mat.PLATE], 1)],
		"sinks": [
			Rooms.sink(1, 2, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [Rooms.cell(0, 0), Rooms.cell(2, 0)],
		"walls": [Rooms.cell(1, 0), Rooms.cell(2, 1)],
		"budget": Rooms.kv([Rules.Kind.RAKE, 1, Rules.Kind.WEIR, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var held := World.simulate(boxed, [Rooms.piece(Rules.Kind.RAKE, 1, 1, Rules.Dir.EAST)], 6)
	check(held.error == "" and held.discarded == 0 and held.trace.is_empty(), "a blocked rake does not spill forward, right, or back")
	check(held.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "blocked ore stays on the rake")
	check(int(held.world.sources[0].pending) == Rules.Mat.PLATE, "the later item is not accepted while the left cell refuses")
	check(int(held.counts[Rules.Mat.ORE]) == 0 and int(held.counts[Rules.Mat.PLATE]) == 0, "the blocked rake did not reach a forward or right sink")
	check(int(held.world.machines[Vector2i(1, 1)].phase) == 0, "a rake does not rotate or alternate when blocked")
	var weir := World.simulate(boxed, [Rooms.piece(Rules.Kind.WEIR, 1, 1, Rules.Dir.EAST)], 4)
	check(int(weir.counts[Rules.Mat.ORE]) >= 1, "the same cell lets a weir spill right into the sink")


func _rake_left(pattern: Array, period: int) -> Dictionary:
	return {
		"id": 0,
		"name": "rake",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 2,
		"sources": [Rooms.source(0, 1, Rules.Dir.EAST, pattern, period)],
		"sinks": [
			Rooms.sink(1, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.RAKE, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}


func _test_wing14_lessons() -> void:
	var wrong_kinds: Array = [Rules.Kind.BELT, Rules.Kind.DWELL, Rules.Kind.TWIN, Rules.Kind.PASS, Rules.Kind.SLIP, Rules.Kind.SHED]
	var hook_misses: Array = [106, 109]
	for index in range(104, 112):
		var room: Dictionary = Rooms.all()[index]
		for kind in wrong_kinds:
			var swapped := _swap_kind(room.solution, Rules.Kind.RAKE, int(kind))
			var run: Dictionary = World.simulate(room, swapped)
			check(run.error == "", "%s in place of the room %d rake simulates (%s)" % [Rules.KIND_NAME[int(kind)], room.id, run.error])
			check(not run.quota_ok, "%s in place of the room %d rake misses the quota (%s)" % [Rules.KIND_NAME[int(kind)], room.id, run.text])
			check(not run.success, "%s in place of the room %d rake does not clear" % [Rules.KIND_NAME[int(kind)], room.id])
		var hooked: Dictionary = World.simulate(room, _swap_kind(room.solution, Rules.Kind.RAKE, Rules.Kind.HOOK))
		check(hooked.error == "", "a hook in place of the room %d rake simulates (%s)" % [room.id, hooked.error])
		if hook_misses.has(int(room.id)):
			check(not hooked.quota_ok and not hooked.success, "a hook in place of the room %d rake misses the quota (%s)" % [room.id, hooked.text])
		else:
			check(hooked.quota_ok and not hooked.success, "a hook in place of the room %d rake meets the quota and is not in the tray (%s)" % [room.id, hooked.text])
		var planner = Planner.new(room)
		for piece in room.initial:
			check(planner.pickup(int(piece.x), int(piece.y)), "room %d picks up its starting piece" % room.id)
		for piece in room.solution:
			check(planner.place(int(piece.kind), int(piece.x), int(piece.y), int(piece.dir)), "room %d places its solution from the tray" % room.id)
		var spare := _spare_cell(room)
		check(spare.x >= 0, "room %d has an empty cell for an extra piece" % room.id)
		check(not planner.place(Rules.Kind.BELT, spare.x, spare.y, Rules.Dir.EAST), "room %d rejects a belt past the tray" % room.id)
		var extra: Array = room.solution.duplicate(true)
		extra.append(Rooms.piece(Rules.Kind.BELT, spare.x, spare.y, Rules.Dir.EAST))
		var over: Dictionary = World.simulate(room, extra)
		check(over.quota_ok and not over.budget_ok and not over.success, "room %d extra belt meets the quota and is rejected (%s)" % [room.id, over.text])
	var draw: Dictionary = Rooms.all()[104]
	var drawn: Dictionary = World.simulate(draw, draw.solution)
	check(drawn.world.machines[Vector2i(1, 3)].hold == Rules.Mat.INGOT, "draw left keeps the last ingot")
	check(int(drawn.counts[Rules.Mat.PLATE]) >= int(draw.quota[Rules.Mat.PLATE]), "draw left delivers the waiting plates (%s)" % drawn.text)
	var draw_shed: Dictionary = World.simulate(draw, _swap_kind(draw.solution, Rules.Kind.RAKE, Rules.Kind.SHED))
	check(int(draw_shed.counts[Rules.Mat.PLATE]) == 0 and draw_shed.world.machines[Vector2i(1, 3)].hold == Rules.Mat.PLATE, "draw left's shed keeps the first plate (%s)" % draw_shed.text)
	var draw_belt: Dictionary = World.simulate(draw, _swap_kind(draw.solution, Rules.Kind.RAKE, Rules.Kind.BELT))
	var draw_twin: Dictionary = World.simulate(draw, _swap_kind(draw.solution, Rules.Kind.RAKE, Rules.Kind.TWIN))
	check(int(draw_belt.counts[Rules.Mat.PLATE]) == 0 and int(draw_belt.discarded) > 0, "draw left's belt sends the plate into the pit (%s)" % draw_belt.text)
	check(int(draw_twin.counts[Rules.Mat.PLATE]) == 0 and draw_twin.world.machines[Vector2i(1, 3)].hold == Rules.Mat.PLATE, "draw left's twin refuses the other material (%s)" % draw_twin.text)
	var push: Dictionary = Rooms.all()[105]
	var pushed: Dictionary = World.simulate(push, push.solution)
	check(pushed.world.machines[Vector2i(1, 3)].hold == Rules.Mat.PLATE, "push ore holds the last plate")
	check(int(pushed.counts[Rules.Mat.INGOT]) >= int(push.quota[Rules.Mat.INGOT]), "push ore feeds the kiln (%s)" % pushed.text)
	var push_shed: Dictionary = World.simulate(push, _swap_kind(push.solution, Rules.Kind.RAKE, Rules.Kind.SHED))
	check(push_shed.world.machines[Vector2i(1, 3)].hold == Rules.Mat.ORE and int(push_shed.counts[Rules.Mat.INGOT]) == int(push.quota[Rules.Mat.INGOT]) - 1, "push ore's shed keeps the first ore and finishes one ingot short (%s)" % push_shed.text)
	var still: Dictionary = Rooms.all()[106]
	var stilled: Dictionary = World.simulate(still, still.solution)
	check(int(still.budget[Rules.Kind.BELT]) == 1, "still rake budgets one belt")
	check(stilled.world.machines[Vector2i(1, 3)].hold == Rules.Mat.PLATE, "still rake keeps the last plate")
	check(int(stilled.counts[Rules.Mat.INGOT]) >= int(still.quota[Rules.Mat.INGOT]), "still rake's waiting ore reaches the kiln (%s)" % stilled.text)
	var still_shed: Dictionary = World.simulate(still, _swap_kind(still.solution, Rules.Kind.RAKE, Rules.Kind.SHED))
	check(int(still_shed.counts[Rules.Mat.INGOT]) == 0 and still_shed.world.machines[Vector2i(1, 3)].hold == Rules.Mat.ORE, "still rake's shed keeps the ore out of the kiln (%s)" % still_shed.text)
	var seat: Dictionary = Rooms.all()[107]
	var parked: Array = seat.initial.duplicate(true)
	parked.append(Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.GRATE, 4, 3, Rules.Dir.EAST))
	var gap: Dictionary = World.simulate(seat, parked)
	check(World.budget_met(parked, seat.budget), "leaving the seat rake parked stays inside the tray")
	check(int(gap.counts[Rules.Mat.PLATE]) == 0 and not gap.quota_ok, "a parked rake leaves a gap and misses (%s)" % gap.text)
	var seat_planner = Planner.new(seat)
	check(seat_planner.at(0, 4) != null and seat_planner.remaining(Rules.Kind.RAKE) == 0, "seat starts with the rake off the tray")
	check(seat_planner.pickup(0, 4), "pickup lifts the pre-placed rake")
	check(seat_planner.at(0, 4) == null and seat_planner.remaining(Rules.Kind.RAKE) == 1, "pre-placed rake returns to the tray")
	check(seat_planner.place(Rules.Kind.RAKE, 1, 3, Rules.Dir.SOUTH), "the returned rake can be seated on the lane")
	var corner: Dictionary = Rooms.all()[108]
	var into_wall: Dictionary = World.simulate(corner, [
		Rooms.piece(Rules.Kind.BELT, 2, 1, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.EAST),
	])
	check(int(into_wall.counts[Rules.Mat.PLATE]) == 0, "corner belts that run into the wall deliver nothing")
	check(World.simulate(corner, corner.solution).world.machines[Vector2i(3, 2)].hold == Rules.Mat.INGOT, "corner keeps the last ingot in the rake")
	var heat: Dictionary = Rooms.all()[109]
	var one_kiln_pieces: Array = []
	var no_forward: Array = []
	for piece in heat.solution:
		if not (int(piece.x) == 3 and int(piece.y) >= 2):
			one_kiln_pieces.append(piece)
		if not (int(piece.x) == 1 and int(piece.y) >= 2):
			no_forward.append(piece)
	var one_kiln: Dictionary = World.simulate(heat, one_kiln_pieces)
	var left_only: Dictionary = World.simulate(heat, no_forward)
	var both: Dictionary = World.simulate(heat, heat.solution)
	var heat_quota := int(heat.quota[Rules.Mat.INGOT])
	check(int(one_kiln.counts[Rules.Mat.INGOT]) < heat_quota, "one left-heat kiln misses %d (%s)" % [heat_quota, one_kiln.text])
	check(int(left_only.counts[Rules.Mat.INGOT]) < heat_quota, "the left kilns without the forward lane miss %d (%s)" % [heat_quota, left_only.text])
	check(int(both.counts[Rules.Mat.INGOT]) >= heat_quota, "left heat reaches the quota (%s)" % both.text)
	check(int(both.counts[Rules.Mat.INGOT]) > int(one_kiln.counts[Rules.Mat.INGOT]), "the left-heat spill kiln adds ingots")
	var heat_shed: Dictionary = World.simulate(heat, _swap_kind(heat.solution, Rules.Kind.RAKE, Rules.Kind.SHED))
	check(int(heat_shed.counts[Rules.Mat.INGOT]) == heat_quota - 1, "left heat's shed finishes one ingot short (%s)" % heat_shed.text)
	var heat_hook: Dictionary = World.simulate(heat, _swap_kind(heat.solution, Rules.Kind.RAKE, Rules.Kind.HOOK))
	check(int(heat_hook.counts[Rules.Mat.INGOT]) >= heat_quota and not heat_hook.success, "left heat's hook meets the count and is not in the tray (%s)" % heat_hook.text)
	var scrap: Dictionary = Rooms.all()[110]
	var scraped: Dictionary = World.simulate(scrap, scrap.solution)
	check(int(scraped.counts[Rules.Mat.INGOT]) >= int(scrap.quota[Rules.Mat.INGOT]) and int(scraped.discarded) > 0, "after the push counts kiln ingots and discards the scrap (%s discarded %d)" % [scraped.text, scraped.discarded])
	check(scraped.world.machines[Vector2i(1, 3)].hold == Rules.Mat.PLATE, "after the push keeps the last plate")
	var scrap_shed: Dictionary = World.simulate(scrap, _swap_kind(scrap.solution, Rules.Kind.RAKE, Rules.Kind.SHED))
	check(int(scrap_shed.counts[Rules.Mat.INGOT]) == 0 and scrap_shed.world.machines[Vector2i(1, 3)].hold == Rules.Mat.ORE, "after the push's shed keeps the first ore (%s)" % scrap_shed.text)
	var no_filter: Dictionary = World.simulate(scrap, [
		Rooms.piece(Rules.Kind.RAKE, 1, 3, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 5, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 6, 3, Rules.Dir.EAST),
	])
	check(int(no_filter.counts[Rules.Mat.INGOT]) < int(scrap.quota[Rules.Mat.INGOT]), "after the push without a filter misses (%s)" % no_filter.text)
	var side_rake: Dictionary = Rooms.all()[111]
	var solved: Dictionary = World.simulate(side_rake, side_rake.solution)
	check(int(solved.counts[Rules.Mat.INGOT]) >= int(side_rake.quota[Rules.Mat.INGOT]) and int(solved.counts[Rules.Mat.PLATE]) >= int(side_rake.quota[Rules.Mat.PLATE]), "side bin hits both quotas (%s)" % solved.text)
	check(solved.world.machines[Vector2i(1, 3)].hold == Rules.Mat.ORE, "side bin keeps the last ore")
	var plates_only: Dictionary = World.simulate(side_rake, [
		Rooms.piece(Rules.Kind.BELT, 1, 5, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 5, Rules.Dir.EAST),
	])
	check(int(plates_only.counts[Rules.Mat.INGOT]) == 0 and int(plates_only.counts[Rules.Mat.PLATE]) < int(side_rake.quota[Rules.Mat.PLATE]), "side bin's upper plates alone miss (%s)" % plates_only.text)
	var pressed: Dictionary = World.simulate(side_rake, [
		Rooms.piece(Rules.Kind.BELT, 1, 5, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 5, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.RAKE, 1, 3, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.FILTER, 4, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 5, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 6, 3, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 6, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.PRESS, 7, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 8, 4, Rules.Dir.EAST),
	])
	check(int(pressed.counts[Rules.Mat.INGOT]) == 0 and not pressed.success, "pressing every ingot misses side bin (%s)" % pressed.text)
	for kind in wrong_kinds:
		var missed: Dictionary = World.simulate(side_rake, _swap_kind(side_rake.solution, Rules.Kind.RAKE, int(kind)))
		check(int(missed.counts[Rules.Mat.INGOT]) < int(side_rake.quota[Rules.Mat.INGOT]) and int(missed.counts[Rules.Mat.PLATE]) < int(side_rake.quota[Rules.Mat.PLATE]), "%s in place of the side-bin rake misses both quotas (%s)" % [Rules.KIND_NAME[int(kind)], missed.text])
	var side_hook: Dictionary = World.simulate(side_rake, _swap_kind(side_rake.solution, Rules.Kind.RAKE, Rules.Kind.HOOK))
	check(int(side_hook.counts[Rules.Mat.INGOT]) >= int(side_rake.quota[Rules.Mat.INGOT]) and int(side_hook.counts[Rules.Mat.PLATE]) >= int(side_rake.quota[Rules.Mat.PLATE]) and not side_hook.success, "a hook in place of the side-bin rake meets both counts and is not in the tray (%s)" % side_hook.text)


func _test_hoe_sends_the_waiter() -> void:
	var ore := _hoe_right([Rules.Mat.ORE], 4)
	var placed := [Rooms.piece(Rules.Kind.HOE, 1, 1, Rules.Dir.EAST)]
	var early := World.simulate(ore, placed, 4)
	var mid := World.simulate(ore, placed, 8)
	var result := World.simulate(ore, placed, 12)
	var again := World.simulate(ore, placed, 12)
	check(_trace(early) == "" and early.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "a lone ore is still in the hoe after the belt tick and the dwell tick")
	check(_trace(mid) == "5:1,2:0" and mid.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "the first ore leaves right and the next ore waits, got %s" % _trace(mid))
	check(_trace(result) == "5:1,2:0|9:1,2:0", "later ore keeps leaving the hoe to the right, got %s" % _trace(result))
	check(result.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "the latest ore of the run stays in the hoe")
	check(int(result.counts[Rules.Mat.ORE]) == 2, "two ores leave right and the latest waits")
	check(not ("2,1:" in _trace(result)), "a hoe does not send the waiter forward")
	check(not ("1,0:" in _trace(result)), "a hoe does not send the waiter left")
	check(_same(result, again), "the same hoe lane is deterministic (seed %d)" % result.seed)
	var belt := World.simulate(ore, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST)], 12)
	var dwell := World.simulate(ore, [Rooms.piece(Rules.Kind.DWELL, 1, 1, Rules.Dir.EAST)], 12)
	check(_trace(belt) == "2:2,1:0|6:2,1:0|10:2,1:0", "a belt on that cell sends forward on the next tick, got %s" % _trace(belt))
	check(_trace(dwell) == "3:2,1:0|7:2,1:0|11:2,1:0", "a dwell on that cell sends forward one tick after a belt, got %s" % _trace(dwell))
	var hook := World.simulate(ore, [Rooms.piece(Rules.Kind.HOOK, 1, 1, Rules.Dir.EAST)], 12)
	check(_trace(hook) == "2:1,0:0|6:1,0:0|10:1,0:0", "a hook sends its one item left and does not keep a last item, got %s" % _trace(hook))
	check(hook.world.machines[Vector2i(1, 1)].hold < 0, "a hook does not keep an item in place")
	var as_rake := World.simulate(ore, [Rooms.piece(Rules.Kind.RAKE, 1, 1, Rules.Dir.EAST)], 12)
	check(_trace(as_rake) == "5:1,0:0|9:1,0:0", "a rake on the hoe lane sends the waiter left, got %s" % _trace(as_rake))
	for mat in [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]:
		var lane := _hoe_right([mat], 80)
		var lone := World.simulate(lane, placed, 15)
		check(_trace(lone) == "" and lone.world.machines[Vector2i(1, 1)].hold == mat, "a lone %s never leaves a hoe" % Rules.MAT_NAME[mat])
	var mixed := _hoe_right([Rules.Mat.ORE, Rules.Mat.INGOT], 4)
	var held := World.simulate(mixed, placed, 4)
	var pushed := World.simulate(mixed, placed, 8)
	var later := World.simulate(mixed, placed, 12)
	check(_trace(held) == "" and held.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "a hoe does not release before the different material arrives")
	check(_trace(pushed) == "5:1,2:0", "the waiting ore leaves right when a different material arrives, got %s" % _trace(pushed))
	check(pushed.world.machines[Vector2i(1, 1)].hold == Rules.Mat.INGOT, "the arrival stays when the waiter leaves right")
	check(_trace(later) == "5:1,2:0|9:1,2:1" and later.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "the next arrival becomes the waiting item, got %s" % _trace(later))
	check(int(pushed.world.machines[Vector2i(1, 1)].phase) == 0, "a hoe does not rotate or alternate")
	var as_slip := World.simulate(mixed, [Rooms.piece(Rules.Kind.SLIP, 1, 1, Rules.Dir.EAST)], 8)
	check(_trace(as_slip) == "5:2,1:1" and as_slip.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "a slip sends that arrival forward and keeps the first, got %s" % _trace(as_slip))
	var as_pass := World.simulate(mixed, [Rooms.piece(Rules.Kind.PASS, 1, 1, Rules.Dir.EAST)], 8)
	check(_trace(as_pass) == "5:2,1:0" and as_pass.world.machines[Vector2i(1, 1)].hold == Rules.Mat.INGOT, "a pass sends the waiter forward and keeps the arrival, got %s" % _trace(as_pass))
	var as_twin := World.simulate(mixed, [Rooms.piece(Rules.Kind.TWIN, 1, 1, Rules.Dir.EAST)], 8)
	check(_trace(as_twin) == "" and as_twin.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "a twin refuses that different material")
	check(int(as_twin.world.sources[0].pending) == Rules.Mat.INGOT, "the twin leaves the different material on the previous piece")
	var as_shed := World.simulate(mixed, [Rooms.piece(Rules.Kind.SHED, 1, 1, Rules.Dir.EAST)], 8)
	check(_trace(as_shed) == "5:1,0:1" and as_shed.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "a shed sends the arrival left and keeps the waiter, got %s" % _trace(as_shed))
	var as_drop := World.simulate(mixed, [Rooms.piece(Rules.Kind.DROP, 1, 1, Rules.Dir.NORTH)], 8)
	check(as_drop.trace.is_empty(), "a drop on the hoe cell does not take the load from behind, got %s" % _trace(as_drop))
	var south := {
		"id": 0,
		"name": "hoe south",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.ORE, Rules.Mat.INGOT], 4)],
		"sinks": [
			Rooms.sink(0, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(1, 2, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.HOE, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var turned := World.simulate(south, [Rooms.piece(Rules.Kind.HOE, 1, 1, Rules.Dir.SOUTH)], 8)
	check(_trace(turned) == "5:0,1:0" and turned.world.machines[Vector2i(1, 1)].hold == Rules.Mat.INGOT, "a south-facing hoe sends the waiter west and keeps the arrival, got %s" % _trace(turned))
	var raked := World.simulate(south, [Rooms.piece(Rules.Kind.RAKE, 1, 1, Rules.Dir.SOUTH)], 8)
	check(_trace(raked) == "5:2,1:0", "a south-facing rake sends that waiter east, got %s" % _trace(raked))


func _test_hoe_refuses_side_and_front() -> void:
	var room := {
		"id": 0,
		"name": "hoe refuse",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [
			Rooms.source(0, 1, Rules.Dir.EAST, [Rules.Mat.ORE, Rules.Mat.INGOT], 4),
			Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.INGOT], 1),
			Rooms.source(2, 1, Rules.Dir.WEST, [Rules.Mat.PLATE], 1),
		],
		"sinks": [Rooms.sink(1, 2, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.HOE, 1, Rules.Kind.BELT, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var placed := [Rooms.piece(Rules.Kind.HOE, 1, 1, Rules.Dir.EAST)]
	var result := World.simulate(room, placed, 8)
	check(_trace(result) == "5:1,2:0", "hoe sends the waiting ore right and keeps the ingot, got %s" % _trace(result))
	check(result.world.machines[Vector2i(1, 1)].hold == Rules.Mat.INGOT, "the arrival stays in the hoe")
	check(int(result.world.sources[1].pending) == Rules.Mat.INGOT, "hoe refuses an ingot from the side")
	check(int(result.world.sources[2].pending) == Rules.Mat.PLATE, "hoe refuses a head-on plate")
	check(int(result.world.machines[Vector2i(1, 1)].phase) == 0, "a hoe does not rotate or alternate")
	var side_only := {
		"id": 0,
		"name": "hoe side",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [Rooms.source(1, 0, Rules.Dir.SOUTH, [Rules.Mat.PLATE], 1)],
		"sinks": [Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE])],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.HOE, 1, Rules.Kind.BELT, 1]),
		"quota": Rooms.kv([Rules.Mat.PLATE, 1]),
		"initial": [],
		"solution": [],
	}
	var belt := World.simulate(side_only, [Rooms.piece(Rules.Kind.BELT, 1, 1, Rules.Dir.EAST)], 4)
	var hoe_side := World.simulate(side_only, placed, 4)
	check(_trace(belt) == "2:2,1:2|3:2,1:2|4:2,1:2", "a belt takes a plate from the side, got %s" % _trace(belt))
	check(int(hoe_side.counts[Rules.Mat.PLATE]) == 0 and int(hoe_side.world.sources[0].pending) == Rules.Mat.PLATE, "a hoe refuses that same side plate")
	var front := {
		"id": 0,
		"name": "hoe front",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 1,
		"sources": [
			Rooms.source(0, 0, Rules.Dir.EAST, [Rules.Mat.ORE], 4),
			Rooms.source(2, 0, Rules.Dir.WEST, [Rules.Mat.INGOT], 1),
		],
		"sinks": [],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.HOE, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var blocked := World.simulate(front, [Rooms.piece(Rules.Kind.HOE, 1, 0, Rules.Dir.EAST)], 6)
	var machine = blocked.world.machines[Vector2i(1, 0)]
	check(int(blocked.world.sources[1].pending) == Rules.Mat.INGOT, "hoe refuses a head-on ingot")
	check(machine.hold == Rules.Mat.ORE, "the rear load stays on the hoe")
	check(blocked.trace.is_empty(), "a head-on entry does not leave the hoe, got %s" % _trace(blocked))
	check(int(machine.phase) == 0, "a head-on entry does not rotate the hoe")


func _test_hoe_blocked_does_not_spill() -> void:
	var boxed := {
		"id": 0,
		"name": "hoe boxed",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [Rooms.source(0, 1, Rules.Dir.EAST, [Rules.Mat.ORE, Rules.Mat.PLATE], 1)],
		"sinks": [
			Rooms.sink(1, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [Rooms.cell(0, 0), Rooms.cell(2, 0), Rooms.cell(0, 2), Rooms.cell(2, 2)],
		"walls": [Rooms.cell(1, 2), Rooms.cell(2, 1)],
		"budget": Rooms.kv([Rules.Kind.HOE, 1, Rules.Kind.HOOK, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}
	var held := World.simulate(boxed, [Rooms.piece(Rules.Kind.HOE, 1, 1, Rules.Dir.EAST)], 6)
	check(held.error == "" and held.discarded == 0 and held.trace.is_empty(), "a blocked hoe does not spill forward, left, or back")
	check(held.world.machines[Vector2i(1, 1)].hold == Rules.Mat.ORE, "blocked ore stays on the hoe")
	check(int(held.world.sources[0].pending) == Rules.Mat.PLATE, "the later item is not accepted while the right cell refuses")
	check(int(held.counts[Rules.Mat.ORE]) == 0 and int(held.counts[Rules.Mat.PLATE]) == 0, "the blocked hoe did not reach a forward or left sink")
	check(int(held.world.machines[Vector2i(1, 1)].phase) == 0, "a hoe does not rotate or alternate when blocked")
	var hook := World.simulate(boxed, [Rooms.piece(Rules.Kind.HOOK, 1, 1, Rules.Dir.EAST)], 4)
	check(int(hook.counts[Rules.Mat.ORE]) >= 1, "the same cell lets a hook send left into the sink")


func _hoe_right(pattern: Array, period: int) -> Dictionary:
	return {
		"id": 0,
		"name": "hoe",
		"blurb": "",
		"rule": "",
		"w": 3,
		"h": 3,
		"sources": [Rooms.source(0, 1, Rules.Dir.EAST, pattern, period)],
		"sinks": [
			Rooms.sink(1, 2, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(2, 1, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
			Rooms.sink(1, 0, [Rules.Mat.ORE, Rules.Mat.INGOT, Rules.Mat.PLATE]),
		],
		"chutes": [],
		"walls": [],
		"budget": Rooms.kv([Rules.Kind.HOE, 1]),
		"quota": Rooms.kv([Rules.Mat.ORE, 1]),
		"initial": [],
		"solution": [],
	}


func _test_wing15_lessons() -> void:
	var wrong_kinds: Array = [
		Rules.Kind.BELT,
		Rules.Kind.DWELL,
		Rules.Kind.TWIN,
		Rules.Kind.PASS,
		Rules.Kind.SLIP,
		Rules.Kind.SHED,
		Rules.Kind.HOOK,
		Rules.Kind.RAKE,
	]
	for index in range(112, 120):
		var room: Dictionary = Rooms.all()[index]
		for kind in wrong_kinds:
			var swapped := _swap_kind(room.solution, Rules.Kind.HOE, int(kind))
			var run: Dictionary = World.simulate(room, swapped)
			check(run.error == "", "%s in place of the room %d hoe simulates (%s)" % [Rules.KIND_NAME[int(kind)], room.id, run.error])
			check(not run.quota_ok, "%s in place of the room %d hoe misses the quota (%s)" % [Rules.KIND_NAME[int(kind)], room.id, run.text])
			check(not run.success, "%s in place of the room %d hoe does not clear" % [Rules.KIND_NAME[int(kind)], room.id])
		var planner = Planner.new(room)
		for piece in room.initial:
			check(planner.pickup(int(piece.x), int(piece.y)), "room %d picks up its starting piece" % room.id)
		for piece in room.solution:
			check(planner.place(int(piece.kind), int(piece.x), int(piece.y), int(piece.dir)), "room %d places its solution from the tray" % room.id)
		var spare := _spare_cell(room)
		check(spare.x >= 0, "room %d has an empty cell for an extra piece" % room.id)
		check(not planner.place(Rules.Kind.BELT, spare.x, spare.y, Rules.Dir.EAST), "room %d rejects a belt past the tray" % room.id)
		var extra: Array = room.solution.duplicate(true)
		extra.append(Rooms.piece(Rules.Kind.BELT, spare.x, spare.y, Rules.Dir.EAST))
		var over: Dictionary = World.simulate(room, extra)
		check(over.quota_ok and not over.budget_ok and not over.success, "room %d extra belt meets the quota and is rejected (%s)" % [room.id, over.text])
	var draw: Dictionary = Rooms.all()[112]
	var drawn: Dictionary = World.simulate(draw, draw.solution)
	check(drawn.world.machines[Vector2i(1, 3)].hold == Rules.Mat.INGOT, "draw right keeps the last ingot")
	check(int(drawn.counts[Rules.Mat.PLATE]) >= int(draw.quota[Rules.Mat.PLATE]), "draw right delivers the waiting plates (%s)" % drawn.text)
	var draw_rake: Dictionary = World.simulate(draw, _swap_kind(draw.solution, Rules.Kind.HOE, Rules.Kind.RAKE))
	check(int(draw_rake.counts[Rules.Mat.PLATE]) == 0 and int(draw_rake.discarded) > 0, "draw right's rake sends the plate left into the pit (%s)" % draw_rake.text)
	var draw_shed: Dictionary = World.simulate(draw, _swap_kind(draw.solution, Rules.Kind.HOE, Rules.Kind.SHED))
	check(int(draw_shed.counts[Rules.Mat.PLATE]) == 0 and draw_shed.world.machines[Vector2i(1, 3)].hold == Rules.Mat.PLATE, "draw right's shed keeps the first plate (%s)" % draw_shed.text)
	var draw_belt: Dictionary = World.simulate(draw, _swap_kind(draw.solution, Rules.Kind.HOE, Rules.Kind.BELT))
	var draw_twin: Dictionary = World.simulate(draw, _swap_kind(draw.solution, Rules.Kind.HOE, Rules.Kind.TWIN))
	check(int(draw_belt.counts[Rules.Mat.PLATE]) == 0 and int(draw_belt.discarded) > 0, "draw right's belt sends the plate into the pit (%s)" % draw_belt.text)
	check(int(draw_twin.counts[Rules.Mat.PLATE]) == 0 and draw_twin.world.machines[Vector2i(1, 3)].hold == Rules.Mat.PLATE, "draw right's twin refuses the other material (%s)" % draw_twin.text)
	var push: Dictionary = Rooms.all()[113]
	var pushed: Dictionary = World.simulate(push, push.solution)
	check(pushed.world.machines[Vector2i(1, 3)].hold == Rules.Mat.PLATE, "push ore holds the last plate")
	check(int(pushed.counts[Rules.Mat.INGOT]) >= int(push.quota[Rules.Mat.INGOT]), "push ore feeds the kiln (%s)" % pushed.text)
	var push_rake: Dictionary = World.simulate(push, _swap_kind(push.solution, Rules.Kind.HOE, Rules.Kind.RAKE))
	check(int(push_rake.counts[Rules.Mat.INGOT]) == 0, "push ore's rake sends the ore left and the kiln stays empty (%s)" % push_rake.text)
	var still: Dictionary = Rooms.all()[114]
	var stilled: Dictionary = World.simulate(still, still.solution)
	check(int(still.budget[Rules.Kind.BELT]) == 1, "still hoe budgets one belt")
	check(stilled.world.machines[Vector2i(1, 3)].hold == Rules.Mat.PLATE, "still hoe keeps the last plate")
	check(int(stilled.counts[Rules.Mat.INGOT]) >= int(still.quota[Rules.Mat.INGOT]), "still hoe's waiting ore reaches the kiln (%s)" % stilled.text)
	var still_rake: Dictionary = World.simulate(still, _swap_kind(still.solution, Rules.Kind.HOE, Rules.Kind.RAKE))
	check(int(still_rake.counts[Rules.Mat.INGOT]) == 0, "still hoe's rake sends the ore into the pit (%s)" % still_rake.text)
	var seat: Dictionary = Rooms.all()[115]
	var parked: Array = seat.initial.duplicate(true)
	parked.append(Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH))
	parked.append(Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST))
	parked.append(Rooms.piece(Rules.Kind.GRATE, 4, 3, Rules.Dir.EAST))
	var gap: Dictionary = World.simulate(seat, parked)
	check(World.budget_met(parked, seat.budget), "leaving the seat hoe parked stays inside the tray")
	check(int(gap.counts[Rules.Mat.PLATE]) == 0 and not gap.quota_ok, "a parked hoe leaves a gap and misses (%s)" % gap.text)
	var seat_planner = Planner.new(seat)
	check(seat_planner.at(0, 4) != null and seat_planner.remaining(Rules.Kind.HOE) == 0, "seat starts with the hoe off the tray")
	check(seat_planner.pickup(0, 4), "pickup lifts the pre-placed hoe")
	check(seat_planner.at(0, 4) == null and seat_planner.remaining(Rules.Kind.HOE) == 1, "pre-placed hoe returns to the tray")
	check(seat_planner.place(Rules.Kind.HOE, 1, 3, Rules.Dir.NORTH), "the returned hoe can be seated on the lane")
	var corner: Dictionary = Rooms.all()[116]
	var into_wall: Dictionary = World.simulate(corner, [
		Rooms.piece(Rules.Kind.BELT, 2, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 4, Rules.Dir.EAST),
	])
	check(int(into_wall.counts[Rules.Mat.PLATE]) == 0, "corner belts that run into the wall deliver nothing")
	check(World.simulate(corner, corner.solution).world.machines[Vector2i(3, 3)].hold == Rules.Mat.INGOT, "corner keeps the last ingot in the hoe")
	var heat: Dictionary = Rooms.all()[117]
	var one_kiln_pieces: Array = []
	var no_left: Array = []
	for piece in heat.solution:
		if not (int(piece.x) == 3 and int(piece.y) >= 2):
			one_kiln_pieces.append(piece)
		if int(piece.x) != 0:
			no_left.append(piece)
	var one_kiln: Dictionary = World.simulate(heat, one_kiln_pieces)
	var left_only: Dictionary = World.simulate(heat, no_left)
	var both: Dictionary = World.simulate(heat, heat.solution)
	var heat_quota := int(heat.quota[Rules.Mat.INGOT])
	check(int(one_kiln.counts[Rules.Mat.INGOT]) < heat_quota, "one right-heat kiln misses %d (%s)" % [heat_quota, one_kiln.text])
	check(int(left_only.counts[Rules.Mat.INGOT]) < heat_quota, "the right kilns without the left lane miss %d (%s)" % [heat_quota, left_only.text])
	check(int(both.counts[Rules.Mat.INGOT]) >= heat_quota, "right heat reaches the quota (%s)" % both.text)
	check(int(both.counts[Rules.Mat.INGOT]) > int(one_kiln.counts[Rules.Mat.INGOT]), "the right-heat spill kiln adds ingots")
	var heat_rake: Dictionary = World.simulate(heat, _swap_kind(heat.solution, Rules.Kind.HOE, Rules.Kind.RAKE))
	check(int(heat_rake.counts[Rules.Mat.INGOT]) < heat_quota, "right heat's rake feeds the left lane and misses (%s)" % heat_rake.text)
	var heat_hook: Dictionary = World.simulate(heat, _swap_kind(heat.solution, Rules.Kind.HOE, Rules.Kind.HOOK))
	check(int(heat_hook.counts[Rules.Mat.INGOT]) < heat_quota and not heat_hook.success, "right heat's hook misses and is not in the tray (%s)" % heat_hook.text)
	var scrap: Dictionary = Rooms.all()[118]
	var scraped: Dictionary = World.simulate(scrap, scrap.solution)
	check(int(scraped.counts[Rules.Mat.INGOT]) >= int(scrap.quota[Rules.Mat.INGOT]) and int(scraped.discarded) > 0, "after the push counts kiln ingots and discards the scrap (%s discarded %d)" % [scraped.text, scraped.discarded])
	check(scraped.world.machines[Vector2i(1, 3)].hold == Rules.Mat.PLATE, "after the push keeps the last plate")
	var scrap_rake: Dictionary = World.simulate(scrap, _swap_kind(scrap.solution, Rules.Kind.HOE, Rules.Kind.RAKE))
	check(int(scrap_rake.counts[Rules.Mat.INGOT]) == 0, "after the push's rake sends the first ore into the scrap (%s)" % scrap_rake.text)
	var no_filter: Dictionary = World.simulate(scrap, [
		Rooms.piece(Rules.Kind.HOE, 1, 3, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 4, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 5, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 6, 3, Rules.Dir.EAST),
	])
	check(int(no_filter.counts[Rules.Mat.INGOT]) < int(scrap.quota[Rules.Mat.INGOT]), "after the push without a filter misses (%s)" % no_filter.text)
	var side_hoe: Dictionary = Rooms.all()[119]
	var solved: Dictionary = World.simulate(side_hoe, side_hoe.solution)
	check(int(solved.counts[Rules.Mat.INGOT]) >= int(side_hoe.quota[Rules.Mat.INGOT]) and int(solved.counts[Rules.Mat.PLATE]) >= int(side_hoe.quota[Rules.Mat.PLATE]), "side bin hits both quotas (%s)" % solved.text)
	check(solved.world.machines[Vector2i(1, 3)].hold == Rules.Mat.ORE, "side bin keeps the last ore")
	var plates_only: Dictionary = World.simulate(side_hoe, [
		Rooms.piece(Rules.Kind.BELT, 1, 5, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 5, Rules.Dir.EAST),
	])
	check(int(plates_only.counts[Rules.Mat.INGOT]) == 0 and int(plates_only.counts[Rules.Mat.PLATE]) < int(side_hoe.quota[Rules.Mat.PLATE]), "side bin's lower plates alone miss (%s)" % plates_only.text)
	var pressed: Dictionary = World.simulate(side_hoe, [
		Rooms.piece(Rules.Kind.BELT, 1, 5, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 2, 5, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 1, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 3, 2, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.HOE, 1, 3, Rules.Dir.NORTH),
		Rooms.piece(Rules.Kind.WEIR, 2, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 3, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.FILTER, 4, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.KILN, 5, 3, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 6, 3, Rules.Dir.SOUTH),
		Rooms.piece(Rules.Kind.BELT, 6, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.PRESS, 7, 4, Rules.Dir.EAST),
		Rooms.piece(Rules.Kind.BELT, 8, 4, Rules.Dir.EAST),
	])
	check(int(pressed.counts[Rules.Mat.INGOT]) == 0 and not pressed.success, "pressing every ingot misses the hoe side bin (%s)" % pressed.text)
	for kind in wrong_kinds:
		var missed: Dictionary = World.simulate(side_hoe, _swap_kind(side_hoe.solution, Rules.Kind.HOE, int(kind)))
		check(int(missed.counts[Rules.Mat.INGOT]) < int(side_hoe.quota[Rules.Mat.INGOT]) and int(missed.counts[Rules.Mat.PLATE]) < int(side_hoe.quota[Rules.Mat.PLATE]), "%s in place of the side-bin hoe misses both quotas (%s)" % [Rules.KIND_NAME[int(kind)], missed.text])
