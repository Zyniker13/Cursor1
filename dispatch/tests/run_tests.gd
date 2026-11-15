extends SceneTree

const Sim = preload("res://scripts/sim.gd")
const Puzzles = preload("res://scripts/puzzles.gd")
const Scoring = preload("res://scripts/scoring.gd")

var _failures: Array[String] = []


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_campaign()
	_fresh_parcels_are_unstamped()
	_empty_graphs()
	_introduction_order()
	_mutation()
	_alternate_graph()
	_latch_rules()
	_teaching_blocks_matter()
	_tick_cap()
	_return_routes()
	_filter_rules()
	_building_two()
	_primer_rules()
	_building_three()
	_bridge_rules()
	_building_four()
	_turn_rules()
	_building_five()
	_slide_rules()
	_building_six()
	_bin_rules()
	_building_seven()
	_hook_rules()
	_building_eight()
	_return_rules()
	_building_nine()
	_pause_rules()
	_building_ten()
	_ui_uses_simulated_par()
	if _failures.is_empty():
		print("ALL TESTS PASSED")
		quit(0)
	else:
		print("FAILED %d" % _failures.size())
		for msg in _failures:
			print(" - ", msg)
		quit(1)


func _check(ok: bool, msg: String) -> void:
	if ok:
		print("  ok  ", msg)
	else:
		_failures.append(msg)
		print("  FAIL ", msg)


func _campaign() -> void:
	print("reference graphs")
	for puzzle in Puzzles.all():
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		_check(bool(result["success"]), "puzzle %d delivers" % int(puzzle["id"]))
		if not bool(result["success"]):
			_dump(result)
			continue
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(par["success"]), "puzzle %d par simulation succeeds" % int(puzzle["id"]))
		_check(int(par["cycles"]) == int(result["cycles"]), "puzzle %d par cycles come from the sim" % int(puzzle["id"]))
		_check(int(par["blocks"]) == int(result["blocks"]), "puzzle %d par blocks come from the sim" % int(puzzle["id"]))
		_check(int(par["blocks"]) == puzzle["reference"].size(), "puzzle %d par blocks count the reference" % int(puzzle["id"]))
		var poisoned: Dictionary = puzzle.duplicate(true)
		poisoned["par_cycles"] = 999
		poisoned["par_blocks"] = 999
		var again: Dictionary = Sim.run(poisoned, poisoned["reference"])
		var text := Scoring.present(poisoned, again)
		_check(text.find("Par cycles %d" % int(par["cycles"])) >= 0, "puzzle %d shows simulated par cycles" % int(puzzle["id"]))
		_check(text.find("Par blocks %d" % int(par["blocks"])) >= 0, "puzzle %d shows simulated par blocks" % int(puzzle["id"]))
		_check(text.find("999") < 0, "puzzle %d ignores handwritten par fields" % int(puzzle["id"]))
		var failed := Scoring.present(puzzle, {"success": false, "reason": "stuck", "cycles": 0, "blocks": 0})
		_check(failed.find("Par") < 0, "puzzle %d hides par before a solution" % int(puzzle["id"]))
		print("    par puzzle %d  cycles %d  blocks %d" % [int(puzzle["id"]), int(par["cycles"]), int(par["blocks"])])


func _fresh_parcels_are_unstamped() -> void:
	print("parcel stamps")
	var puzzle: Dictionary = Puzzles.all()[0]
	var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
	var saw := false
	for frame in result["frames"]:
		for parcel in frame["parcels"]:
			saw = true
			_check(int(parcel["count"]) == 0, "a parcel starts at count 0 until a counter stamps it")
			return
	_check(saw, "puzzle 1 puts a parcel on the belt")


func _empty_graphs() -> void:
	print("empty graphs")
	for puzzle in Puzzles.all():
		var result: Dictionary = Sim.run(puzzle, [])
		_check(not bool(result["success"]), "puzzle %d empty graph fails" % int(puzzle["id"]))


func _introduction_order() -> void:
	print("introduction order")
	var allowed := {}
	var next_intro := 0
	var puzzles := Puzzles.all()
	for puzzle in puzzles:
		var introduced := str(puzzle.get("unlocks", ""))
		if introduced != "":
			var expected := ""
			if next_intro < Puzzles.INTRO.size():
				expected = Puzzles.INTRO[next_intro]
			_check(introduced == expected, "puzzle %d introduces %s" % [int(puzzle["id"]), expected])
			allowed[introduced] = true
			next_intro += 1
			var used := false
			for block in puzzle["reference"]:
				if str(block["type"]) == introduced:
					used = true
			_check(used, "puzzle %d reference uses %s" % [int(puzzle["id"]), introduced])
		for block in puzzle["reference"]:
			_check(allowed.has(str(block["type"])), "puzzle %d reference stays within introduced blocks (%s)" % [int(puzzle["id"]), str(block["type"])])
	_check(next_intro == Puzzles.INTRO.size(), "every block is introduced in order")
	_check(Puzzles.unlocked_at(0) == ["conveyor"], "puzzle 1 unlocks only the conveyor")
	_check(Puzzles.unlocked_at(2) == ["conveyor"], "early puzzles stay on conveyors")
	_check(Puzzles.unlocked_at(3).has("latch") and not Puzzles.unlocked_at(3).has("splitter"), "latch arrives before the splitter")
	_check(not Puzzles.unlocked_at(4).has("painter"), "painter is still locked on the splitter puzzle")
	_check(Puzzles.unlocked_at(7).size() == 5, "the last puzzle has every block")


func _mutation() -> void:
	print("mutation")
	var puzzle: Dictionary = Puzzles.all()[0]
	var mutated: Array = puzzle["reference"].duplicate(true)
	var turned := false
	for block in mutated:
		if int(block["x"]) == 2 and int(block["y"]) == 1:
			block["dir"] = (int(block["dir"]) + 1) % 4
			turned = true
	_check(turned, "found the conveyor to mutate")
	var result: Dictionary = Sim.run(puzzle, mutated)
	_check(not bool(result["success"]), "rotating one block of puzzle 1 fails")
	if bool(result["success"]):
		_dump(result)


func _alternate_graph() -> void:
	print("alternate solution")
	var puzzle: Dictionary = Puzzles.all()[0]
	var par: Dictionary = Scoring.compute_par(puzzle)
	var alt := [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 1, "dir": 1},
		{"type": "conveyor", "x": 2, "y": 2, "dir": 0},
		{"type": "conveyor", "x": 3, "y": 2, "dir": 0},
		{"type": "conveyor", "x": 4, "y": 2, "dir": 3},
		{"type": "conveyor", "x": 4, "y": 1, "dir": 0},
	]
	var result: Dictionary = Sim.run(puzzle, alt)
	_check(bool(result["success"]), "a different puzzle 1 graph also delivers")
	_check(int(result["cycles"]) != int(par["cycles"]) or int(result["blocks"]) != int(par["blocks"]), "the alternate graph is not the reference")
	var text := Scoring.present(puzzle, result)
	_check(text.find("Cycles %d" % int(result["cycles"])) >= 0, "alternate cycles are shown")
	_check(text.find("Blocks %d" % int(result["blocks"])) >= 0, "alternate blocks are shown")
	_check(text.find("Par cycles %d" % int(par["cycles"])) >= 0, "par cycles sit beside the alternate")
	_check(text.find("Par blocks %d" % int(par["blocks"])) >= 0, "par blocks sit beside the alternate")


func _latch_rules() -> void:
	print("latch")
	var micro := {
		"width": 3, "height": 1, "walls": [],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 2, "y": 0},
		"order": [{"color": "gray"}],
	}
	var held: Dictionary = Sim.run(micro, [{"type": "latch", "x": 1, "y": 0, "dir": 0}])
	var flowed: Dictionary = Sim.run(micro, [{"type": "conveyor", "x": 1, "y": 0, "dir": 0}])
	_check(bool(held["success"]) and bool(flowed["success"]), "latch and conveyor both deliver a clear parcel")
	_check(int(held["cycles"]) == int(flowed["cycles"]) + 1, "a latch holds for one extra tick before releasing")

	var cross := {
		"width": 6, "height": 4, "walls": [],
		"sources": [
			{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 3, "y": 3, "dir": 3, "parcels": [{"color": "gray"}]},
		],
		"dock": {"x": 5, "y": 0},
		"order": [{"color": "gray"}, {"color": "gray"}],
	}
	var with_latch := [
		{"type": "conveyor", "x": 1, "y": 0, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 0, "dir": 0},
		{"type": "conveyor", "x": 3, "y": 0, "dir": 0},
		{"type": "conveyor", "x": 4, "y": 0, "dir": 0},
		{"type": "conveyor", "x": 3, "y": 2, "dir": 3},
		{"type": "latch", "x": 3, "y": 1, "dir": 3},
	]
	var latched: Dictionary = Sim.run(cross, with_latch)
	_check(bool(latched["success"]), "latch waits out a crossing parcel")
	var frame := _frame(latched, 4)
	_check(not frame.is_empty(), "tick 4 of the latch crossing was recorded")
	if not frame.is_empty():
		_check(_at(frame, 3, 1) and _at(frame, 4, 0) and not _at(frame, 3, 0), "latch does not enter a cell another parcel is leaving")
	var with_belt: Array = with_latch.duplicate(true)
	for block in with_belt:
		if str(block["type"]) == "latch":
			block["type"] = "conveyor"
	var belted: Dictionary = Sim.run(cross, with_belt)
	_check(not bool(belted["success"]), "a conveyor in the latch's place collides")


func _teaching_blocks_matter() -> void:
	print("teaching swaps")
	var puzzles := Puzzles.all()
	var latch_puzzle: Dictionary = puzzles[3]
	var swapped: Array = latch_puzzle["reference"].duplicate(true)
	for block in swapped:
		if str(block["type"]) == "latch":
			block["type"] = "conveyor"
	_check(not bool(Sim.run(latch_puzzle, swapped)["success"]), "replacing puzzle 4's latch with a conveyor jams")
	var painter_puzzle: Dictionary = puzzles[5]
	var unpainted: Array = painter_puzzle["reference"].duplicate(true)
	for block in unpainted:
		if str(block["type"]) == "painter":
			block["type"] = "conveyor"
			block.erase("color")
	_check(not bool(Sim.run(painter_puzzle, unpainted)["success"]), "puzzle 6 fails without the painter")
	var counter_puzzle: Dictionary = puzzles[6]
	var uncounted: Array = counter_puzzle["reference"].duplicate(true)
	for block in uncounted:
		if str(block["type"]) == "counter":
			block["type"] = "conveyor"
	_check(not bool(Sim.run(counter_puzzle, uncounted)["success"]), "puzzle 7 fails without the counter")


func _return_routes() -> void:
	print("return routes")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 15, "seven return routes follow the first eight")
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id < 9 or id > 15:
			continue
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "return route %d delivers" % id)
		_check(int(result["cycles"]) <= int(par["cycles"]), "return route %d cycles are at or under par" % id)
		_check(int(result["blocks"]) <= int(par["blocks"]), "return route %d blocks are at or under par" % id)
		_check(str(puzzle.get("unlocks", "")) == "", "return puzzle %d adds no new block" % id)
	_check(Puzzles.unlocked_at(14).size() == 5, "return routes keep every block")

	var second: Dictionary = _by_id(9)
	var straight := [
		{"type": "counter", "x": 1, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 1, "dir": 0},
	]
	var once: Dictionary = Sim.run(second, straight)
	_check(not bool(once["success"]), "puzzle 9 fails if the parcel crosses the counter once")

	var merged: Dictionary = _by_id(12)
	var rushed: Array = merged["reference"].duplicate(true)
	for block in rushed:
		if str(block["type"]) == "latch":
			block["type"] = "conveyor"
	_check(not bool(Sim.run(merged, rushed)["success"]), "puzzle 12 jams if the latch is a conveyor")

	var desk: Dictionary = _by_id(15)
	var unlatched: Array = desk["reference"].duplicate(true)
	for block in unlatched:
		if str(block["type"]) == "latch":
			block["type"] = "conveyor"
	_check(not bool(Sim.run(desk, unlatched)["success"]), "puzzle 15 jams if yellow is not held")


func _by_id(id: int) -> Dictionary:
	for puzzle in Puzzles.all():
		if int(puzzle["id"]) == id:
			return puzzle
	return {}


func _tick_cap() -> void:
	print("tick cap")
	var loop := {
		"width": 3, "height": 3, "walls": [],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 0, "y": 2},
		"order": [{"color": "gray"}],
	}
	var graph := [
		{"type": "conveyor", "x": 1, "y": 0, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 0, "dir": 1},
		{"type": "conveyor", "x": 2, "y": 1, "dir": 2},
		{"type": "conveyor", "x": 1, "y": 1, "dir": 3},
	]
	var result: Dictionary = Sim.run(loop, graph)
	_check(not bool(result["success"]), "a loop fails")
	_check(str(result["reason"]) == "tick_cap", "a loop ends at the tick cap")
	_check(int(result["ticks"]) == Sim.TICK_CAP, "the loop stops on the cap tick")


func _filter_rules() -> void:
	print("filter")
	var belt := {
		"width": 3, "height": 2, "walls": [],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "blue"}, {"color": "red"}]}],
		"dock": {"x": 2, "y": 0},
		"order": [{"color": "red"}, {"color": "blue"}],
	}
	var graph := [
		{"type": "filter", "x": 1, "y": 0, "dir": 0, "color": "red"},
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 1, "dir": 3},
	]
	var sorted: Dictionary = Sim.run(belt, graph)
	_check(bool(sorted["success"]), "a red filter lets red pass and sends blue clockwise")
	var frame := _frame(sorted, 2)
	_check(not frame.is_empty() and _at(frame, 1, 1) and not _at(frame, 2, 0), "blue leaves the filter clockwise on tick 2")
	var matched := graph.duplicate(true)
	matched[0]["color"] = "blue"
	var matched_belt: Dictionary = belt.duplicate(true)
	matched_belt["order"] = [{"color": "blue"}, {"color": "red"}]
	var straight: Dictionary = Sim.run(matched_belt, matched)
	var early := _frame(straight, 2)
	_check(bool(straight["success"]), "a matching color still reaches the dock")
	_check(not early.is_empty() and not _at(early, 1, 1), "a matching color does not turn clockwise")
	_check(early["delivered"].size() == 1 and str(early["delivered"][0]["color"]) == "blue", "the matching parcel is delivered on tick 2")
	var bare := Sim.run(belt, [{"type": "filter", "x": 1, "y": 0, "dir": 0}])
	_check(str(bare["reason"]) == "invalid", "a filter with no color cannot run")


func _building_two() -> void:
	print("building 2")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 22, "routes 16 through 22 follow building 1")
	for i in puzzles.size():
		_check(int(puzzles[i]["id"]) == i + 1, "route %d keeps its place" % (i + 1))
	_check(Puzzles.INTRO.size() >= 6 and Puzzles.INTRO[5] == "filter", "the filter is the block building 2 teaches")
	_check(not Puzzles.unlocked_at(14).has("filter"), "the filter stays locked through route 15")
	_check(Puzzles.unlocked_at(15).has("filter"), "route 16 unlocks the filter")
	_check(Puzzles.unlocked_at(21).size() == 6, "building 2 ends with every block")
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		var building := int(puzzle.get("building", 1))
		if id < 16:
			_check(building == 1, "route %d stays in building 1" % id)
			continue
		if id > 22:
			continue
		_check(building == 2, "route %d is building 2" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		if id == 16:
			_check(str(puzzle.get("unlocks", "")) == "filter", "route 16 teaches the filter")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_filter := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "filter":
				uses_filter = true
		_check(uses_filter, "route %d reference uses the filter" % id)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	_check(not bool(Sim.run(_by_id(16), _swap(_by_id(16), "filter", "conveyor"))["success"]), "route 16 fails if the filter is a conveyor")
	_check(not bool(Sim.run(_by_id(16), _swap(_by_id(16), "filter", "splitter"))["success"]), "route 16 fails if the filter is a splitter")
	_check(not bool(Sim.run(_by_id(19), _swap(_by_id(19), "latch", "conveyor"))["success"]), "route 19 jams if blue is not held")
	_check(not bool(Sim.run(_by_id(20), _swap(_by_id(20), "painter", "conveyor"))["success"]), "route 20 loops if blue is not painted red")
	_check(not bool(Sim.run(_by_id(21), _swap(_by_id(21), "filter", "splitter"))["success"]), "route 21 fails if a splitter sorts the colors")
	_check(not bool(Sim.run(_by_id(22), _swap(_by_id(22), "filter", "conveyor"))["success"]), "route 22 fails if blue is not turned aside")


func _primer_rules() -> void:
	print("primer")
	var belt := {
		"width": 4, "height": 1, "walls": [],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}, {"color": "red"}]}],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "blue"}, {"color": "red"}],
	}
	var graph := [
		{"type": "primer", "x": 1, "y": 0, "dir": 0, "color": "blue"},
		{"type": "conveyor", "x": 2, "y": 0, "dir": 0},
	]
	var coated: Dictionary = Sim.run(belt, graph)
	_check(bool(coated["success"]), "a primer paints gray and leaves red alone")
	var frame := _frame(coated, 2)
	_check(not frame.is_empty() and _color_at(frame, 2, 0) == "blue", "gray leaves the primer blue on tick 2")
	var later := _frame(coated, 3)
	_check(not later.is_empty() and _color_at(later, 2, 0) == "red", "red crosses the same primer and stays red")
	var painted := graph.duplicate(true)
	painted[0]["type"] = "painter"
	_check(not bool(Sim.run(belt, painted)["success"]), "a painter in the primer's place recolors red")
	var bare := Sim.run(belt, [{"type": "primer", "x": 1, "y": 0, "dir": 0}])
	_check(str(bare["reason"]) == "invalid", "a primer with no color cannot run")


func _building_three() -> void:
	print("building 3")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 29, "routes 23 through 29 follow building 2")
	_check(Puzzles.INTRO.size() >= 7 and Puzzles.INTRO[6] == "primer", "the primer is the block building 3 teaches")
	_check(not Puzzles.unlocked_at(21).has("primer"), "the primer stays locked through route 22")
	_check(Puzzles.unlocked_at(22).has("primer"), "route 23 unlocks the primer")
	_check(Puzzles.unlocked_at(28).size() == 7, "building 3 ends with every block")
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id < 23:
			_check(int(puzzle.get("building", 1)) < 3, "route %d stays out of building 3" % id)
			continue
		if id > 29:
			continue
		_check(int(puzzle.get("building", 1)) == 3, "route %d is building 3" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		if id == 23:
			_check(str(puzzle.get("unlocks", "")) == "primer", "route 23 teaches the primer")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_primer := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "primer":
				uses_primer = true
		_check(uses_primer, "route %d reference uses the primer" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	_check(not bool(Sim.run(_by_id(23), _swap(_by_id(23), "primer", "painter"))["success"]), "route 23 fails if the primer overwrites red")
	_check(not bool(Sim.run(_by_id(23), _swap(_by_id(23), "primer", "conveyor"))["success"]), "route 23 fails if gray is not primed")
	_check(not bool(Sim.run(_by_id(24), _swap(_by_id(24), "primer", "painter"))["success"]), "route 24 fails if every parcel is painted")
	_check(not bool(Sim.run(_by_id(24), _swap(_by_id(24), "counter", "conveyor"))["success"]), "route 24 fails without the counter")
	_check(not bool(Sim.run(_by_id(25), _swap(_by_id(25), "latch", "conveyor"))["success"]), "route 25 fails if the south belt is not held")
	_check(not bool(Sim.run(_by_id(25), _swap(_by_id(25), "primer", "painter"))["success"]), "route 25 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(25), _swap(_by_id(25), "filter", "conveyor"))["success"]), "route 25 fails if red is not let through")
	_check(not bool(Sim.run(_by_id(26), _swap(_by_id(26), "primer", "painter"))["success"]), "route 26 fails if blue is painted red")
	_check(not bool(Sim.run(_by_id(26), _swap(_by_id(26), "filter", "conveyor"))["success"]), "route 26 fails if the new red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(27), _swap(_by_id(27), "latch", "conveyor"))["success"]), "route 27 jams if gray is not held")
	_check(not bool(Sim.run(_by_id(27), _swap(_by_id(27), "primer", "painter"))["success"]), "route 27 fails if red is painted yellow")
	_check(not bool(Sim.run(_by_id(28), _swap(_by_id(28), "primer", "painter"))["success"]), "route 28 fails if blue is painted red")
	_check(not bool(Sim.run(_by_id(28), _swap(_by_id(28), "filter", "conveyor"))["success"]), "route 28 fails if blue is not let into the counter first")
	_check(not bool(Sim.run(_by_id(29), _swap(_by_id(29), "latch", "conveyor"))["success"]), "route 29 jams if the south belt is not held")
	_check(not bool(Sim.run(_by_id(29), _swap(_by_id(29), "primer", "painter"))["success"]), "route 29 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(29), _swap(_by_id(29), "filter", "conveyor"))["success"]), "route 29 fails if red is not taken first")


func _bridge_rules() -> void:
	print("bridge")
	var belt := {
		"width": 4, "height": 1, "walls": [{"x": 2, "y": 0}],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "gray"}],
	}
	var hopped: Dictionary = Sim.run(belt, [{"type": "bridge", "x": 1, "y": 0, "dir": 0}])
	_check(bool(hopped["success"]), "a bridge carries a parcel over the next cell")
	_check(int(hopped["cycles"]) == 2, "the hop delivers on tick 2")
	var stood_on_brick := false
	for frame in hopped["frames"]:
		if _at(frame, 2, 0):
			stood_on_brick = true
	_check(not stood_on_brick, "the parcel never stands on the cell it crosses")
	var walked: Dictionary = Sim.run(belt, [{"type": "conveyor", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(walked["success"]) and str(walked["reason"]) == "stuck", "a conveyor stops at the brick a bridge crosses")

	var cross := {
		"width": 4, "height": 2, "walls": [],
		"sources": [
			{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "red"}]},
			{"x": 2, "y": 1, "dir": 3, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "red"}],
	}
	var over: Dictionary = Sim.run(cross, [
		{"type": "bridge", "x": 1, "y": 0, "dir": 0},
		{"type": "latch", "x": 2, "y": 0, "dir": 1},
	])
	_check(bool(over["success"]), "a bridge can cross a cell that already holds a parcel")
	var under := _frame(over, 2)
	_check(not under.is_empty() and _color_at(under, 2, 0) == "blue", "the parcel under the jump stays put")
	_check(under.get("delivered", []).size() == 1 and str(under["delivered"][0]["color"]) == "red", "the jumping parcel reaches the dock")


func _building_four() -> void:
	print("building 4")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 36, "routes 30 through 36 follow building 3")
	_check(Puzzles.INTRO.size() >= 8 and Puzzles.INTRO[7] == "bridge", "the bridge is the block building 4 teaches")
	_check(not Puzzles.unlocked_at(28).has("bridge"), "the bridge stays locked through route 29")
	_check(Puzzles.unlocked_at(29).has("bridge"), "route 30 unlocks the bridge")
	_check(Puzzles.unlocked_at(35).size() == 8, "building 4 ends with every block")
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id < 30:
			_check(int(puzzle.get("building", 1)) < 4, "route %d stays out of building 4" % id)
			continue
		if id > 36:
			continue
		_check(int(puzzle.get("building", 1)) == 4, "route %d is building 4" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		if id == 30:
			_check(str(puzzle.get("unlocks", "")) == "bridge", "route 30 teaches the bridge")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_bridge := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "bridge":
				uses_bridge = true
		_check(uses_bridge, "route %d reference uses the bridge" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	_check(not bool(Sim.run(_by_id(30), _swap(_by_id(30), "bridge", "conveyor"))["success"]), "route 30 stops if the bridge is a conveyor")
	_check(not bool(Sim.run(_by_id(31), _swap(_by_id(31), "bridge", "conveyor"))["success"]), "route 31 delivers blue first if red cannot jump")
	_check(not bool(Sim.run(_by_id(32), _swap(_by_id(32), "bridge", "conveyor"))["success"]), "route 32 stops if the parcels cannot cross the brick")
	_check(not bool(Sim.run(_by_id(32), _swap(_by_id(32), "counter", "conveyor"))["success"]), "route 32 fails without the counter")
	_check(not bool(Sim.run(_by_id(33), _swap(_by_id(33), "bridge", "conveyor"))["success"]), "route 33 delivers blue first if red cannot jump")
	_check(not bool(Sim.run(_by_id(33), _swap(_by_id(33), "latch", "conveyor"))["success"]), "route 33 jams if blue is not held")
	_check(not bool(Sim.run(_by_id(34), _swap(_by_id(34), "bridge", "conveyor"))["success"]), "route 34 fails if blue cannot cross the brick")
	_check(not bool(Sim.run(_by_id(34), _swap(_by_id(34), "painter", "conveyor"))["success"]), "route 34 fails if gray is not painted")
	_check(not bool(Sim.run(_by_id(34), _swap(_by_id(34), "splitter", "conveyor"))["success"]), "route 34 fails if gray takes the bridge")
	_check(not bool(Sim.run(_by_id(35), _swap(_by_id(35), "bridge", "conveyor"))["success"]), "route 35 stops if the exit is not a bridge")
	_check(not bool(Sim.run(_by_id(35), _swap(_by_id(35), "painter", "conveyor"))["success"]), "route 35 fails if the return is not painted")
	_check(not bool(Sim.run(_by_id(35), _swap(_by_id(35), "counter", "conveyor"))["success"]), "route 35 fails without the second stamp")
	_check(not bool(Sim.run(_by_id(35), _swap(_by_id(35), "splitter", "conveyor"))["success"]), "route 35 fails if the parcel leaves on the first pass")
	_check(not bool(Sim.run(_by_id(36), _swap(_by_id(36), "bridge", "conveyor"))["success"]), "route 36 fails if red cannot cross the brick")
	_check(not bool(Sim.run(_by_id(36), _swap(_by_id(36), "primer", "painter"))["success"]), "route 36 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(36), _swap(_by_id(36), "filter", "conveyor"))["success"]), "route 36 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(36), _swap(_by_id(36), "counter", "conveyor"))["success"]), "route 36 fails without the counter")


func _turn_rules() -> void:
	print("turn")
	var corner := {
		"width": 3, "height": 2,
		"walls": [{"x": 2, "y": 0}, {"x": 0, "y": 1}, {"x": 2, "y": 1}],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 1, "y": 1},
		"order": [{"color": "gray"}],
	}
	var turned: Dictionary = Sim.run(corner, [{"type": "turn", "x": 1, "y": 0, "dir": 0}])
	_check(bool(turned["success"]), "a turn delivers the parcel after rotating it")
	_check(int(turned["cycles"]) == 3, "the turn waits a tick and delivers on tick 3")
	var born := _frame(turned, 1)
	var paused := _frame(turned, 2)
	_check(not born.is_empty() and _dir_at(born, 1, 0) == 0, "the parcel arrives facing east")
	_check(not paused.is_empty() and _at(paused, 1, 0) and not _at(paused, 1, 1), "the turn does not move the parcel on that tick")
	_check(_dir_at(paused, 1, 0) == 1, "the turn rotates the parcel one quarter clockwise")
	_check(_count_at(paused, 1, 0) == 0 and _color_at(paused, 1, 0) == "gray", "a turn does not stamp or paint")
	var tinted: Dictionary = Sim.run(corner, [{"type": "turn", "x": 1, "y": 0, "dir": 0, "color": "red"}])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a turn is ignored")
	var east: Dictionary = Sim.run(corner, [{"type": "conveyor", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(east["success"]), "a conveyor aimed with the turn keeps going east")

	var hop := {
		"width": 4, "height": 1, "walls": [{"x": 2, "y": 0}],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "gray"}],
	}
	var blocked: Dictionary = Sim.run(hop, [{"type": "turn", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(blocked["success"]), "a turn does not carry a parcel over the next cell")
	var crossed := false
	for frame in blocked["frames"]:
		if _at(frame, 2, 0) or _at(frame, 3, 0):
			crossed = true
	_check(not crossed, "the parcel never reaches the cell past a turn")
	var bridged: Dictionary = Sim.run(hop, [{"type": "bridge", "x": 1, "y": 0, "dir": 0}])
	_check(bool(bridged["success"]), "a bridge still crosses the cell a turn cannot")


func _building_five() -> void:
	print("building 5")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 43, "routes 37 through 43 follow building 4")
	_check(Puzzles.INTRO.size() >= 9 and Puzzles.INTRO[8] == "turn", "the turn is the block building 5 teaches")
	_check(not Puzzles.unlocked_at(35).has("turn"), "the turn stays locked through route 36")
	_check(Puzzles.unlocked_at(36).has("turn"), "route 37 unlocks the turn")
	_check(Puzzles.unlocked_at(42).size() == 9, "building 5 ends with the turn")
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id < 37:
			_check(int(puzzle.get("building", 1)) < 5, "route %d stays out of building 5" % id)
			continue
		if id > 43:
			continue
		_check(int(puzzle.get("building", 1)) == 5, "route %d is building 5" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		if id == 37:
			_check(str(puzzle.get("unlocks", "")) == "turn", "route 37 teaches the turn")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_turn := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "turn":
				uses_turn = true
		_check(uses_turn, "route %d reference uses the turn" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	var lesson: Dictionary = Sim.run(_by_id(37), _by_id(37)["reference"])
	var born := _frame(lesson, 1)
	var paused := _frame(lesson, 2)
	_check(not born.is_empty() and _dir_at(born, 1, 0) == 0, "route 37 starts the parcel facing east")
	_check(not paused.is_empty() and _at(paused, 1, 0) and _dir_at(paused, 1, 0) == 1, "route 37 turns the parcel clockwise without moving it")
	_check(not bool(Sim.run(_by_id(37), _swap(_by_id(37), "turn", "conveyor"))["success"]), "route 37 stops if the turn is a conveyor")
	_check(not bool(Sim.run(_by_id(38), _swap(_by_id(38), "turn", "conveyor"))["success"]), "route 38 stops if red cannot turn onto the belt")
	var cut := _by_id(38)
	var hurried: Array = cut["reference"].duplicate(true)
	hurried[0] = {"type": "conveyor", "x": 2, "y": 0, "dir": 1}
	_check(not bool(Sim.run(cut, hurried)["success"]), "route 38 delivers red too early if the turn does not wait")
	var held: Array = cut["reference"].duplicate(true)
	held[0] = {"type": "latch", "x": 2, "y": 0, "dir": 1}
	_check(not bool(Sim.run(cut, held)["success"]), "route 38 misses the gap if the turn is a latch")
	_check(not bool(Sim.run(_by_id(39), _swap(_by_id(39), "turn", "conveyor"))["success"]), "route 39 stops if the parcel cannot turn onto the counter")
	_check(not bool(Sim.run(_by_id(39), _swap(_by_id(39), "counter", "conveyor"))["success"]), "route 39 fails without the counter")
	_check(not bool(Sim.run(_by_id(40), _swap(_by_id(40), "turn", "conveyor"))["success"]), "route 40 stops if red cannot turn onto the dock")
	_check(not bool(Sim.run(_by_id(40), _swap(_by_id(40), "latch", "conveyor"))["success"]), "route 40 jams if blue is not held")
	_check(not bool(Sim.run(_by_id(41), _swap(_by_id(41), "turn", "conveyor"))["success"]), "route 41 jams if both parcels are sent the same way")
	_check(not bool(Sim.run(_by_id(42), _swap(_by_id(42), "turn", "conveyor"))["success"]), "route 42 stops if the exit is not a turn")
	_check(not bool(Sim.run(_by_id(42), _swap(_by_id(42), "painter", "conveyor"))["success"]), "route 42 fails if the return is not painted")
	_check(not bool(Sim.run(_by_id(42), _swap(_by_id(42), "counter", "conveyor"))["success"]), "route 42 fails without the second stamp")
	_check(not bool(Sim.run(_by_id(42), _swap(_by_id(42), "splitter", "conveyor"))["success"]), "route 42 loops if the splitter cannot send the second pass east")
	_check(not bool(Sim.run(_by_id(43), _swap(_by_id(43), "turn", "conveyor"))["success"]), "route 43 fails if red cannot turn onto the counter")
	_check(not bool(Sim.run(_by_id(43), _swap(_by_id(43), "primer", "painter"))["success"]), "route 43 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(43), _swap(_by_id(43), "filter", "conveyor"))["success"]), "route 43 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(43), _swap(_by_id(43), "counter", "conveyor"))["success"]), "route 43 fails without the counter")


func _slide_rules() -> void:
	print("slide")
	var belt := {
		"width": 4, "height": 1, "walls": [{"x": 2, "y": 0}],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "gray"}],
	}
	var hopped: Dictionary = Sim.run(belt, [{"type": "slide", "x": 1, "y": 0, "dir": 2}])
	_check(bool(hopped["success"]), "a slide carries a parcel two cells in its facing")
	_check(int(hopped["cycles"]) == 2, "the slide delivers on tick 2")
	var born := _frame(hopped, 1)
	_check(not born.is_empty() and _dir_at(born, 1, 0) == 0, "the parcel arrives on the slide facing east")
	var stood_on_brick := false
	for frame in hopped["frames"]:
		if _at(frame, 2, 0):
			stood_on_brick = true
	_check(not stood_on_brick, "the parcel never stands on the cell a slide crosses")
	var walked: Dictionary = Sim.run(belt, [{"type": "conveyor", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(walked["success"]) and str(walked["reason"]) == "stuck", "a conveyor stops at the brick a slide crosses")
	var aimed: Dictionary = Sim.run(belt, [{"type": "bridge", "x": 1, "y": 0, "dir": 2}])
	_check(not bool(aimed["success"]), "a bridge aimed against the facing does not copy the slide")
	for dir in range(4):
		var turned: Dictionary = Sim.run(belt, [{"type": "slide", "x": 1, "y": 0, "dir": dir, "color": "red"}])
		_check(bool(turned["success"]) and str(turned["delivered"][0]["color"]) == "gray" and int(turned["delivered"][0]["count"]) == 0, "rotating or tinting a slide does not aim, paint, or stamp it")

	var over_belt := {
		"width": 4, "height": 2, "walls": [],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "gray"}],
	}
	var crossed_belt: Dictionary = Sim.run(over_belt, [
		{"type": "slide", "x": 1, "y": 0, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 0, "dir": 1},
	])
	_check(bool(crossed_belt["success"]), "a slide crosses a belt without taking that belt")
	var rode := false
	for frame in crossed_belt["frames"]:
		if _at(frame, 2, 0) or _at(frame, 2, 1):
			rode = true
	_check(not rode, "the parcel never stands on the belt it crosses")

	var crowd := {
		"width": 4, "height": 2, "walls": [],
		"sources": [
			{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "red"}]},
			{"x": 2, "y": 1, "dir": 3, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "red"}],
	}
	var over: Dictionary = Sim.run(crowd, [
		{"type": "slide", "x": 1, "y": 0, "dir": 1},
		{"type": "latch", "x": 2, "y": 0, "dir": 1},
	])
	_check(bool(over["success"]), "a slide can cross a cell that already holds a parcel")
	var under := _frame(over, 2)
	_check(not under.is_empty() and _color_at(under, 2, 0) == "blue", "the parcel under the slide stays put")
	_check(under.get("delivered", []).size() == 1 and str(under["delivered"][0]["color"]) == "red", "the sliding parcel reaches the dock")

	var held := {
		"width": 5, "height": 2, "walls": [{"x": 2, "y": 0}],
		"sources": [
			{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 3, "y": 1, "dir": 3, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 4, "y": 0},
		"order": [{"color": "blue"}, {"color": "gray"}],
	}
	var waited: Dictionary = Sim.run(held, [
		{"type": "slide", "x": 1, "y": 0, "dir": 1},
		{"type": "latch", "x": 3, "y": 0, "dir": 0},
	])
	_check(bool(waited["success"]), "a slide waits when its landing is blocked and then finishes")
	_check(int(waited["cycles"]) == 5, "the blocked slide delivers on tick 5")
	var paused := _frame(waited, 2)
	_check(not paused.is_empty() and _at(paused, 1, 0) and _dir_at(paused, 1, 0) == 0, "a blocked slide stays put and does not rotate")
	_check(_color_at(paused, 3, 0) == "blue", "the parcel blocking the landing is still there")
	var resumed := _frame(waited, 3)
	_check(not resumed.is_empty() and _at(resumed, 3, 0) and _dir_at(resumed, 3, 0) == 0, "the slide continues east once the landing clears")

	var corner := {
		"width": 3, "height": 4,
		"walls": [
			{"x": 2, "y": 0}, {"x": 0, "y": 1}, {"x": 2, "y": 1},
			{"x": 0, "y": 2}, {"x": 1, "y": 2}, {"x": 2, "y": 2},
			{"x": 0, "y": 3}, {"x": 2, "y": 3},
		],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 1, "y": 3},
		"order": [{"color": "gray"}],
	}
	var bent: Dictionary = Sim.run(corner, [
		{"type": "turn", "x": 1, "y": 0, "dir": 0},
		{"type": "slide", "x": 1, "y": 1, "dir": 0},
	])
	_check(bool(bent["success"]), "a turn before a slide changes where the slide lands")
	var aimed_south := _frame(bent, 3)
	_check(not aimed_south.is_empty() and _dir_at(aimed_south, 1, 1) == 1, "the parcel reaches the slide facing south")
	var bridged: Dictionary = Sim.run(corner, [
		{"type": "turn", "x": 1, "y": 0, "dir": 0},
		{"type": "bridge", "x": 1, "y": 1, "dir": 0},
	])
	_check(not bool(bridged["success"]), "a bridge aimed along the chute does not follow the turn")


func _building_six() -> void:
	print("building 6")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 50, "routes 44 through 50 follow building 5")
	_check(Puzzles.INTRO.size() >= 10 and Puzzles.INTRO[9] == "slide", "the slide is the block building 6 teaches")
	_check(not Puzzles.unlocked_at(42).has("slide"), "the slide stays locked through route 43")
	_check(Puzzles.unlocked_at(43).has("slide"), "route 44 unlocks the slide")
	_check(Puzzles.unlocked_at(49).size() == 10, "building 6 ends with every block")
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id < 44 or id > 50:
			if id < 44:
				_check(int(puzzle.get("building", 1)) < 6, "route %d stays out of building 6" % id)
			continue
		_check(int(puzzle.get("building", 1)) == 6, "route %d is building 6" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		if id == 44:
			_check(str(puzzle.get("unlocks", "")) == "slide", "route 44 teaches the slide")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_slide := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "slide":
				uses_slide = true
		_check(uses_slide, "route %d reference uses the slide" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	var lesson: Dictionary = Sim.run(_by_id(44), _by_id(44)["reference"])
	var started := _frame(lesson, 1)
	_check(not started.is_empty() and _dir_at(started, 1, 1) == 0, "route 44 starts the parcel facing east")
	_check(not bool(Sim.run(_by_id(44), _swap(_by_id(44), "slide", "conveyor"))["success"]), "route 44 stops if the slide is a conveyor")
	for dir in range(4):
		var spun: Array = _by_id(44)["reference"].duplicate(true)
		spun[0]["dir"] = dir
		_check(bool(Sim.run(_by_id(44), spun)["success"]), "route 44 ignores which way the slide block is rotated")
	_check(not bool(Sim.run(_by_id(45), _swap(_by_id(45), "slide", "conveyor"))["success"]), "route 45 stops if the slide is a conveyor")
	_check(not bool(Sim.run(_by_id(45), _swap(_by_id(45), "slide", "bridge"))["success"]), "route 45 misses the dock if the slide is a bridge aimed along the chute")
	_check(not bool(Sim.run(_by_id(45), _swap(_by_id(45), "turn", "conveyor"))["success"]), "route 45 stops if the parcel cannot turn before the slide")
	_check(not bool(Sim.run(_by_id(46), _swap(_by_id(46), "slide", "conveyor"))["success"]), "route 46 stops if the parcels cannot cross the brick")
	_check(not bool(Sim.run(_by_id(46), _swap(_by_id(46), "slide", "bridge"))["success"]), "route 46 misses the counter if the slide is a bridge aimed along the chute")
	_check(not bool(Sim.run(_by_id(46), _swap(_by_id(46), "counter", "conveyor"))["success"]), "route 46 fails without the counter")
	_check(not bool(Sim.run(_by_id(47), _swap(_by_id(47), "slide", "conveyor"))["success"]), "route 47 delivers blue first if red cannot slide over the latch")
	_check(not bool(Sim.run(_by_id(47), _swap(_by_id(47), "slide", "bridge"))["success"]), "route 47 delivers blue first if the slide is a bridge aimed along the chute")
	_check(not bool(Sim.run(_by_id(47), _swap(_by_id(47), "latch", "conveyor"))["success"]), "route 47 jams if blue is not held")
	_check(not bool(Sim.run(_by_id(48), _swap(_by_id(48), "slide", "conveyor"))["success"]), "route 48 fails if both parcels are sent along a belt")
	for dir in range(4):
		var bridged: Array = _by_id(48)["reference"].duplicate(true)
		for block in bridged:
			if str(block["type"]) == "slide":
				block["type"] = "bridge"
				block["dir"] = dir
		_check(not bool(Sim.run(_by_id(48), bridged)["success"]), "route 48 fails if the slide is a bridge aimed %s" % Sim.DIR_NAMES[dir])
	_check(not bool(Sim.run(_by_id(49), _swap(_by_id(49), "slide", "conveyor"))["success"]), "route 49 stops if the exit is not a slide")
	_check(not bool(Sim.run(_by_id(49), _swap(_by_id(49), "painter", "conveyor"))["success"]), "route 49 fails if the return is not painted")
	_check(not bool(Sim.run(_by_id(49), _swap(_by_id(49), "counter", "conveyor"))["success"]), "route 49 fails without the second stamp")
	_check(not bool(Sim.run(_by_id(49), _swap(_by_id(49), "splitter", "conveyor"))["success"]), "route 49 loops if the splitter cannot send the second pass east")
	_check(not bool(Sim.run(_by_id(50), _swap(_by_id(50), "slide", "conveyor"))["success"]), "route 50 fails if red cannot cross the brick")
	_check(not bool(Sim.run(_by_id(50), _swap(_by_id(50), "slide", "bridge"))["success"]), "route 50 fails if the slide is a bridge aimed along the chute")
	_check(not bool(Sim.run(_by_id(50), _swap(_by_id(50), "turn", "conveyor"))["success"]), "route 50 fails if red cannot turn before the slide")
	_check(not bool(Sim.run(_by_id(50), _swap(_by_id(50), "latch", "conveyor"))["success"]), "route 50 jams if the south belt is not held")
	_check(not bool(Sim.run(_by_id(50), _swap(_by_id(50), "primer", "painter"))["success"]), "route 50 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(50), _swap(_by_id(50), "filter", "conveyor"))["success"]), "route 50 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(50), _swap(_by_id(50), "counter", "conveyor"))["success"]), "route 50 fails without the counter")


func _bin_rules() -> void:
	print("bin")
	var pit := {
		"width": 4, "height": 1, "walls": [],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "red"}]}],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "red"}],
	}
	var scrapped: Dictionary = Sim.run(pit, [
		{"type": "bin", "x": 1, "y": 0, "dir": 2},
		{"type": "conveyor", "x": 2, "y": 0, "dir": 0},
	])
	_check(not bool(scrapped["success"]) and scrapped["delivered"].is_empty(), "a parcel that stands on a bin is not delivered")
	var stood := _frame(scrapped, 1)
	_check(not stood.is_empty() and _color_at(stood, 1, 0) == "red", "the parcel stands on the bin before it is removed")
	var gone := _frame(scrapped, 2)
	_check(not gone.is_empty() and not _at(gone, 1, 0) and gone["delivered"].is_empty(), "the next tick removes the parcel in place")
	for dir in range(4):
		var spun: Dictionary = Sim.run(pit, [
			{"type": "bin", "x": 1, "y": 0, "dir": dir},
			{"type": "conveyor", "x": 2, "y": 0, "dir": 0},
		])
		_check(not bool(spun["success"]) and spun["delivered"].is_empty(), "rotating a bin still scraps the parcel standing on it")

	var hop := {
		"width": 4, "height": 1, "walls": [],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "blue"}]}],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "blue"}],
	}
	var slid: Dictionary = Sim.run(hop, [
		{"type": "slide", "x": 1, "y": 0, "dir": 2},
		{"type": "bin", "x": 2, "y": 0, "dir": 1},
	])
	_check(bool(slid["success"]) and int(slid["cycles"]) == 2, "a slide hops over a bin and still delivers")
	var crossed := false
	for frame in slid["frames"]:
		if _at(frame, 2, 0):
			crossed = true
	_check(not crossed, "the hopping parcel never stands on the bin")
	var bridged: Dictionary = Sim.run(hop, [
		{"type": "bridge", "x": 1, "y": 0, "dir": 0},
		{"type": "bin", "x": 2, "y": 0, "dir": 3},
	])
	_check(bool(bridged["success"]), "a bridge hops over a bin and still delivers")


func _building_seven() -> void:
	print("building 7")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 57, "building 7 adds routes 51 through 57")
	_check(Puzzles.INTRO.size() >= 11 and Puzzles.INTRO[10] == "bin", "the bin is the block building 7 teaches")
	_check(not Puzzles.unlocked_at(49).has("bin"), "the bin stays locked through route 50")
	_check(Puzzles.unlocked_at(50).has("bin"), "route 51 unlocks the bin")
	_check(Puzzles.unlocked_at(56).size() == 11, "building 7 ends with every block")
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id < 51 or id > 57:
			if id < 51:
				_check(int(puzzle.get("building", 1)) < 7, "route %d stays out of building 7" % id)
			continue
		_check(int(puzzle.get("building", 1)) == 7, "route %d is building 7" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		if id == 51:
			_check(str(puzzle.get("unlocks", "")) == "bin", "route 51 teaches the bin")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_bin := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "bin":
				uses_bin = true
		_check(uses_bin, "route %d reference uses the bin" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	for dir in range(4):
		var spun: Array = _by_id(51)["reference"].duplicate(true)
		for block in spun:
			if str(block["type"]) == "bin":
				block["dir"] = dir
		_check(bool(Sim.run(_by_id(51), spun)["success"]), "route 51 ignores which way the bin is rotated")
	var spare: Dictionary = Sim.run(_by_id(51), _swap(_by_id(51), "bin", "conveyor"))
	_check(not bool(spare["success"]) and str(spare["reason"]) == "wrong_delivery", "delivering the spare on route 51 fails")
	_check(spare["delivered"].size() >= 1 and str(spare["delivered"][0]["color"]) == "red", "the spare on route 51 reaches the dock when it is not binned")
	for id in [51, 52, 53, 54, 55, 56, 57]:
		for kind in ["conveyor", "slide", "bridge"]:
			var replaced: Dictionary = Sim.run(_by_id(id), _swap(_by_id(id), "bin", kind))
			_check(not bool(replaced["success"]), "route %d fails if the bin is a %s" % [id, kind])
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "bin":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the bin is missing" % id)
	_check(not bool(Sim.run(_by_id(57), _swap(_by_id(57), "latch", "conveyor"))["success"]), "route 57 jams if gray is not held")
	_check(not bool(Sim.run(_by_id(57), _swap(_by_id(57), "primer", "painter"))["success"]), "route 57 fails if red is painted yellow")
	_check(not bool(Sim.run(_by_id(57), _swap(_by_id(57), "filter", "conveyor"))["success"]), "route 57 fails if blue is not sent into the bin")
	_check(not bool(Sim.run(_by_id(57), _swap(_by_id(57), "counter", "conveyor"))["success"]), "route 57 fails without the counter")


func _hook_rules() -> void:
	print("hook")
	var corner := {
		"width": 3, "height": 2,
		"walls": [{"x": 2, "y": 1}, {"x": 0, "y": 0}, {"x": 2, "y": 0}],
		"sources": [{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 1, "y": 0},
		"order": [{"color": "gray"}],
	}
	var hooked: Dictionary = Sim.run(corner, [{"type": "hook", "x": 1, "y": 1, "dir": 0}])
	_check(bool(hooked["success"]), "a hook delivers the parcel after rotating it")
	_check(int(hooked["cycles"]) == 3, "the hook waits a tick and delivers on tick 3")
	var born := _frame(hooked, 1)
	var paused := _frame(hooked, 2)
	_check(not born.is_empty() and _dir_at(born, 1, 1) == 0, "the parcel arrives facing east")
	_check(not paused.is_empty() and _at(paused, 1, 1) and not _at(paused, 1, 0), "the hook does not move the parcel on that tick")
	_check(_dir_at(paused, 1, 1) == 3, "the hook rotates the parcel one quarter counterclockwise")
	_check(_count_at(paused, 1, 1) == 0 and _color_at(paused, 1, 1) == "gray", "a hook does not stamp or paint")
	var tinted: Dictionary = Sim.run(corner, [{"type": "hook", "x": 1, "y": 1, "dir": 0, "color": "red"}])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a hook is ignored")
	for dir in range(4):
		var spun: Dictionary = Sim.run(corner, [{"type": "hook", "x": 1, "y": 1, "dir": dir}])
		_check(bool(spun["success"]) and int(spun["cycles"]) == 3, "rotating a hook does not change the quarter")
	var east: Dictionary = Sim.run(corner, [{"type": "conveyor", "x": 1, "y": 1, "dir": 0}])
	_check(not bool(east["success"]), "a conveyor aimed with the hook keeps going east")
	var clockwise: Dictionary = Sim.run(corner, [{"type": "turn", "x": 1, "y": 1, "dir": 0}])
	_check(not bool(clockwise["success"]), "a turn in the hook's cell misses the dock")

	var right_angle := {
		"width": 3, "height": 2,
		"walls": [{"x": 2, "y": 0}, {"x": 0, "y": 1}, {"x": 2, "y": 1}],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 1, "y": 1},
		"order": [{"color": "gray"}],
	}
	_check(bool(Sim.run(right_angle, [{"type": "turn", "x": 1, "y": 0, "dir": 0}])["success"]), "a turn still leaves clockwise")
	_check(not bool(Sim.run(right_angle, [{"type": "hook", "x": 1, "y": 0, "dir": 0}])["success"]), "a hook does not leave the way a turn leaves")

	var hop := {
		"width": 4, "height": 1, "walls": [{"x": 2, "y": 0}],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "gray"}],
	}
	var blocked: Dictionary = Sim.run(hop, [{"type": "hook", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(blocked["success"]), "a hook does not carry a parcel over the next cell")
	var crossed := false
	for frame in blocked["frames"]:
		if _at(frame, 2, 0) or _at(frame, 3, 0):
			crossed = true
	_check(not crossed, "the parcel never reaches the cell past a hook")
	var slid: Dictionary = Sim.run(hop, [{"type": "slide", "x": 1, "y": 0, "dir": 1}])
	_check(bool(slid["success"]), "a slide still crosses the cell a hook cannot")

	var gap := {
		"width": 3, "height": 2, "walls": [],
		"sources": [
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 2, "y": 0},
		"order": [{"color": "blue"}, {"color": "gray"}],
	}
	var followed: Dictionary = Sim.run(gap, [
		{"type": "hook", "x": 1, "y": 1, "dir": 2},
		{"type": "latch", "x": 1, "y": 0, "dir": 0},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 5, "a hook can enter a cell another parcel is leaving")
	var into := _frame(followed, 3)
	_check(not into.is_empty() and _color_at(into, 1, 0) == "gray", "the hook steps into the cell the latch left")
	_check(into.get("delivered", []).size() == 1 and str(into["delivered"][0]["color"]) == "blue", "the parcel ahead is delivered on that tick")

	var held := {
		"width": 3, "height": 2, "walls": [{"x": 2, "y": 0}],
		"sources": [
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 2, "y": 1},
		"order": [{"color": "gray"}],
	}
	var waiting: Dictionary = Sim.run(held, [
		{"type": "hook", "x": 1, "y": 1, "dir": 1},
		{"type": "conveyor", "x": 1, "y": 0, "dir": 0},
	])
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a hook keeps waiting while its exit stays blocked")
	var turned := _frame(waiting, 2)
	var first_try := _frame(waiting, 3)
	var later := _frame(waiting, 4)
	_check(not turned.is_empty() and _dir_at(turned, 1, 1) == 3, "the blocked hook has already rotated counterclockwise")
	_check(not first_try.is_empty() and _at(first_try, 1, 1) and _dir_at(first_try, 1, 1) == 3, "the first blocked step does not rotate the parcel again")
	_check(not later.is_empty() and _at(later, 1, 1) and _dir_at(later, 1, 1) == 3 and _color_at(later, 1, 0) == "blue", "the hook keeps the new facing while the other parcel stays")


func _building_eight() -> void:
	print("building 8")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 64, "building 8 adds routes 58 through 64")
	_check(Puzzles.INTRO.size() >= 12 and Puzzles.INTRO[11] == "hook", "the hook is the block building 8 teaches")
	_check(not Puzzles.unlocked_at(56).has("hook"), "the hook stays locked through route 57")
	_check(Puzzles.unlocked_at(57).has("hook"), "route 58 unlocks the hook")
	_check(Puzzles.unlocked_at(63).size() == 12, "building 8 ends with every block")
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id < 58 or id > 64:
			if id < 58:
				_check(int(puzzle.get("building", 1)) < 8, "route %d stays out of building 8" % id)
			continue
		_check(int(puzzle.get("building", 1)) == 8, "route %d is building 8" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		if id == 58:
			_check(str(puzzle.get("unlocks", "")) == "hook", "route 58 teaches the hook")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_hook := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "hook":
				uses_hook = true
		_check(uses_hook, "route %d reference uses the hook" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	var lesson: Dictionary = Sim.run(_by_id(58), _by_id(58)["reference"])
	var born := _frame(lesson, 1)
	var paused := _frame(lesson, 2)
	_check(not born.is_empty() and _dir_at(born, 1, 1) == 0, "route 58 starts the parcel facing east")
	_check(not paused.is_empty() and _at(paused, 1, 1) and _dir_at(paused, 1, 1) == 3, "route 58 hooks the parcel counterclockwise without moving it")
	for dir in range(4):
		var spun: Array = _by_id(58)["reference"].duplicate(true)
		spun[0]["dir"] = dir
		_check(bool(Sim.run(_by_id(58), spun)["success"]), "route 58 ignores which way the hook block is rotated")
	for id in [58, 59, 60, 61, 62, 63, 64]:
		_check(not bool(Sim.run(_by_id(id), _swap(_by_id(id), "hook", "turn"))["success"]), "route %d fails if the hook is a turn" % id)
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "hook":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the hook is missing" % id)
	_check(not bool(Sim.run(_by_id(59), _swap(_by_id(59), "hook", "conveyor"))["success"]), "route 59 stops if red cannot hook onto the belt")
	_check(not bool(Sim.run(_by_id(60), _swap(_by_id(60), "counter", "conveyor"))["success"]), "route 60 fails without the counter")
	_check(not bool(Sim.run(_by_id(61), _swap(_by_id(61), "latch", "conveyor"))["success"]), "route 61 jams if blue is not held")
	var paired: Dictionary = Sim.run(_by_id(62), _by_id(62)["reference"])
	var met := _frame(paired, 1)
	var bent := _frame(paired, 2)
	_check(not met.is_empty() and _dir_at(met, 3, 1) == 2, "route 62 starts blue facing west")
	_check(not bent.is_empty() and _at(bent, 3, 1) and _dir_at(bent, 3, 1) == 1, "route 62 hooks blue south without moving it")
	_check(not bool(Sim.run(_by_id(63), _swap(_by_id(63), "painter", "conveyor"))["success"]), "route 63 fails if the return is not painted")
	_check(not bool(Sim.run(_by_id(63), _swap(_by_id(63), "counter", "conveyor"))["success"]), "route 63 fails without the second stamp")
	_check(not bool(Sim.run(_by_id(63), _swap(_by_id(63), "splitter", "conveyor"))["success"]), "route 63 loops if the splitter cannot send the second pass east")
	_check(not bool(Sim.run(_by_id(64), _swap(_by_id(64), "primer", "painter"))["success"]), "route 64 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(64), _swap(_by_id(64), "filter", "conveyor"))["success"]), "route 64 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(64), _swap(_by_id(64), "counter", "conveyor"))["success"]), "route 64 fails without the counter")


func _swap(puzzle: Dictionary, from_type: String, to_type: String) -> Array:
	var graph: Array = puzzle["reference"].duplicate(true)
	for block in graph:
		if str(block["type"]) != from_type:
			continue
		block["type"] = to_type
		if to_type != "painter" and to_type != "filter" and to_type != "primer":
			block.erase("color")
	return graph


func _return_rules() -> void:
	print("return")
	var back := {
		"width": 4, "height": 3,
		"walls": [
			{"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 2, "y": 0}, {"x": 3, "y": 0},
			{"x": 0, "y": 2}, {"x": 1, "y": 2}, {"x": 2, "y": 2}, {"x": 3, "y": 2},
		],
		"sources": [{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 2, "y": 1},
		"order": [{"color": "gray"}],
	}
	var graph := [
		{"type": "slide", "x": 1, "y": 1, "dir": 0},
		{"type": "return", "x": 3, "y": 1, "dir": 0},
	]
	var sent: Dictionary = Sim.run(back, graph)
	_check(bool(sent["success"]), "a return delivers the parcel after reversing it")
	_check(int(sent["cycles"]) == 4, "the return waits a tick and delivers on tick 4")
	var born := _frame(sent, 2)
	var paused := _frame(sent, 3)
	_check(not born.is_empty() and _dir_at(born, 3, 1) == 0, "the parcel arrives facing east")
	_check(not paused.is_empty() and _at(paused, 3, 1) and not _at(paused, 2, 1), "the return does not move the parcel on that tick")
	_check(_dir_at(paused, 3, 1) == 2, "the return reverses east to west")
	_check(_count_at(paused, 3, 1) == 0 and _color_at(paused, 3, 1) == "gray", "a return does not stamp or paint")
	var tinted: Dictionary = Sim.run(back, [
		{"type": "slide", "x": 1, "y": 1, "dir": 0},
		{"type": "return", "x": 3, "y": 1, "dir": 0, "color": "red"},
	])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a return is ignored")
	for dir in range(4):
		var spun: Dictionary = Sim.run(back, [
			{"type": "slide", "x": 1, "y": 1, "dir": dir},
			{"type": "return", "x": 3, "y": 1, "dir": dir},
		])
		_check(bool(spun["success"]) and int(spun["cycles"]) == 4, "rotating a return does not change the reversal")
	var east: Dictionary = Sim.run(back, [
		{"type": "slide", "x": 1, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 3, "y": 1, "dir": 0},
	])
	_check(not bool(east["success"]), "a conveyor in the return's cell keeps going east")
	var hooked: Dictionary = Sim.run(back, [
		{"type": "slide", "x": 1, "y": 1, "dir": 0},
		{"type": "hook", "x": 3, "y": 1, "dir": 0},
	])
	_check(not bool(hooked["success"]), "a hook in the return's cell misses the dock")
	var hooked_face := _frame(hooked, 3)
	_check(not hooked_face.is_empty() and _dir_at(hooked_face, 3, 1) == 3, "a hook sends the eastbound parcel north")
	var turned: Dictionary = Sim.run(back, [
		{"type": "slide", "x": 1, "y": 1, "dir": 0},
		{"type": "turn", "x": 3, "y": 1, "dir": 0},
	])
	_check(not bool(turned["success"]), "a turn in the return's cell misses the dock")
	var turned_face := _frame(turned, 3)
	_check(not turned_face.is_empty() and _dir_at(turned_face, 3, 1) == 1, "a turn sends the eastbound parcel south")

	var hop := {
		"width": 5, "height": 1, "walls": [{"x": 2, "y": 0}],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 4, "y": 0},
		"order": [{"color": "gray"}],
	}
	var blocked: Dictionary = Sim.run(hop, [
		{"type": "slide", "x": 1, "y": 0, "dir": 0},
		{"type": "return", "x": 3, "y": 0, "dir": 1},
	])
	_check(not bool(blocked["success"]), "a return does not carry a parcel over the next cell")
	var crossed := false
	for frame in blocked["frames"]:
		if _at(frame, 2, 0) or _at(frame, 4, 0):
			crossed = true
	_check(not crossed, "the parcel never reaches the cell past a return")

	var gap := {
		"width": 4, "height": 3, "walls": [],
		"sources": [
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 3, "y": 2, "dir": 2, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 2, "y": 0},
		"order": [{"color": "blue"}, {"color": "gray"}],
	}
	var followed: Dictionary = Sim.run(gap, [
		{"type": "slide", "x": 1, "y": 1, "dir": 0},
		{"type": "latch", "x": 2, "y": 1, "dir": 3},
		{"type": "return", "x": 3, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 2, "dir": 3},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 6, "a return can enter a cell another parcel is leaving")
	var into := _frame(followed, 4)
	_check(not into.is_empty() and _color_at(into, 2, 1) == "gray", "the return steps into the cell the latch left")
	_check(into.get("delivered", []).size() == 1 and str(into["delivered"][0]["color"]) == "blue", "the parcel ahead is delivered on that tick")

	var held := {
		"width": 4, "height": 2, "walls": [],
		"sources": [
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 2, "y": 0, "dir": 1, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "gray"}],
	}
	var waiting: Dictionary = Sim.run(held, [
		{"type": "slide", "x": 1, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 1, "dir": 3},
		{"type": "return", "x": 3, "y": 1, "dir": 0},
	])
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a return keeps waiting while its exit stays blocked")
	var reversed := _frame(waiting, 3)
	var first_try := _frame(waiting, 4)
	var later := _frame(waiting, 5)
	_check(not reversed.is_empty() and _dir_at(reversed, 3, 1) == 2, "the blocked return has already reversed to the west")
	_check(not first_try.is_empty() and _at(first_try, 3, 1) and _dir_at(first_try, 3, 1) == 2, "the first blocked step does not reverse the parcel again")
	_check(not later.is_empty() and _at(later, 3, 1) and _dir_at(later, 3, 1) == 2 and _color_at(later, 2, 1) == "blue", "the return keeps the reversed facing while the other parcel stays")


func _building_nine() -> void:
	print("building 9")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 71, "building 9 adds routes 65 through 71")
	_check(Puzzles.INTRO[12] == "return", "the return is the block building 9 teaches")
	_check(not Puzzles.unlocked_at(63).has("return"), "the return stays locked through route 64")
	_check(Puzzles.unlocked_at(64).has("return"), "route 65 unlocks the return")
	_check(Puzzles.unlocked_at(70).size() == 13, "building 9 ends with every block")
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id < 65:
			_check(int(puzzle.get("building", 1)) < 9, "route %d stays out of building 9" % id)
			continue
		if id > 71:
			continue
		_check(int(puzzle.get("building", 1)) == 9, "route %d is building 9" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		if id == 65:
			_check(str(puzzle.get("unlocks", "")) == "return", "route 65 teaches the return")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_return := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "return":
				uses_return = true
		_check(uses_return, "route %d reference uses the return" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	var lesson: Dictionary = Sim.run(_by_id(65), _by_id(65)["reference"])
	var arrived := _frame(lesson, 2)
	var paused := _frame(lesson, 3)
	_check(not arrived.is_empty() and _dir_at(arrived, 3, 1) == 0, "route 65 starts the parcel facing east on the return")
	_check(not paused.is_empty() and _at(paused, 3, 1) and _dir_at(paused, 3, 1) == 2, "route 65 reverses the parcel west without moving it")
	for dir in range(4):
		var spun: Array = _by_id(65)["reference"].duplicate(true)
		for block in spun:
			if str(block["type"]) == "return":
				block["dir"] = dir
		_check(bool(Sim.run(_by_id(65), spun)["success"]), "route 65 ignores which way the return block is rotated")
	for id in [65, 66, 67, 68, 69, 70, 71]:
		_check(not bool(Sim.run(_by_id(id), _swap(_by_id(id), "return", "hook"))["success"]), "route %d fails if the return is a hook" % id)
		_check(not bool(Sim.run(_by_id(id), _swap(_by_id(id), "return", "turn"))["success"]), "route %d fails if the return is a turn" % id)
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "return":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the return is missing" % id)
	_check(not bool(Sim.run(_by_id(66), _swap(_by_id(66), "return", "conveyor"))["success"]), "route 66 stops if red cannot return onto the belt")
	_check(not bool(Sim.run(_by_id(67), _swap(_by_id(67), "counter", "conveyor"))["success"]), "route 67 fails without the counter")
	var jammed: Dictionary = Sim.run(_by_id(68), _swap(_by_id(68), "latch", "conveyor"))
	_check(not bool(jammed["success"]) and str(jammed["reason"]) == "tick_cap", "route 68 jams if blue is not held")
	var paired: Dictionary = Sim.run(_by_id(69), _by_id(69)["reference"])
	var red_back := _frame(paired, 3)
	var blue_back := _frame(paired, 5)
	_check(not red_back.is_empty() and _at(red_back, 3, 1) and _dir_at(red_back, 3, 1) == 2, "route 69 sends red back west without moving it")
	_check(not blue_back.is_empty() and _at(blue_back, 3, 1) and _dir_at(blue_back, 3, 1) == 0, "route 69 sends blue back east without moving it")
	var both_hook: Dictionary = Sim.run(_by_id(69), _swap(_by_id(69), "return", "hook"))
	var red_hook := _frame(both_hook, 3)
	var blue_hook := _frame(both_hook, 5)
	_check(not red_hook.is_empty() and _dir_at(red_hook, 3, 1) == 3, "route 69 hooks red a quarter counterclockwise")
	_check(not blue_hook.is_empty() and _dir_at(blue_hook, 3, 1) == 1, "route 69 hooks blue a quarter counterclockwise")
	var both_turn: Dictionary = Sim.run(_by_id(69), _swap(_by_id(69), "return", "turn"))
	var red_turn := _frame(both_turn, 3)
	var blue_turn := _frame(both_turn, 5)
	_check(not red_turn.is_empty() and _dir_at(red_turn, 3, 1) == 1, "route 69 turns red a quarter clockwise")
	_check(not blue_turn.is_empty() and _dir_at(blue_turn, 3, 1) == 3, "route 69 turns blue a quarter clockwise")
	_check(not bool(Sim.run(_by_id(70), _swap(_by_id(70), "painter", "conveyor"))["success"]), "route 70 fails if the return is not painted")
	_check(not bool(Sim.run(_by_id(70), _swap(_by_id(70), "counter", "conveyor"))["success"]), "route 70 fails without the second stamp")
	_check(not bool(Sim.run(_by_id(70), _swap(_by_id(70), "splitter", "conveyor"))["success"]), "route 70 loops if the splitter cannot send the second pass east")
	_check(not bool(Sim.run(_by_id(71), _swap(_by_id(71), "primer", "painter"))["success"]), "route 71 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(71), _swap(_by_id(71), "filter", "conveyor"))["success"]), "route 71 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(71), _swap(_by_id(71), "counter", "conveyor"))["success"]), "route 71 fails without the counter")


func _pause_rules() -> void:
	print("pause")
	var straight := {
		"width": 4, "height": 3,
		"walls": [
			{"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 2, "y": 0}, {"x": 3, "y": 0},
			{"x": 0, "y": 2}, {"x": 1, "y": 2}, {"x": 2, "y": 2}, {"x": 3, "y": 2},
		],
		"sources": [{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 3, "y": 1},
		"order": [{"color": "gray"}],
	}
	var graph := [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 1, "dir": 0},
	]
	var sent: Dictionary = Sim.run(straight, graph)
	_check(bool(sent["success"]), "a pause delivers the parcel without turning it")
	_check(int(sent["cycles"]) == 4, "the pause waits a tick and delivers on tick 4")
	var born := _frame(sent, 2)
	var waited := _frame(sent, 3)
	_check(not born.is_empty() and _dir_at(born, 2, 1) == 0, "the parcel arrives facing east")
	_check(not waited.is_empty() and _at(waited, 2, 1) and not _at(waited, 3, 1), "the pause does not move the parcel on that tick")
	_check(_dir_at(waited, 2, 1) == 0, "the pause leaves the east facing unchanged")
	_check(_count_at(waited, 2, 1) == 0 and _color_at(waited, 2, 1) == "gray", "a pause does not stamp or paint")
	var tinted: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 1, "dir": 0, "color": "red"},
	])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a pause is ignored")
	for dir in range(4):
		var spun: Dictionary = Sim.run(straight, [
			{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
			{"type": "pause", "x": 2, "y": 1, "dir": dir},
		])
		_check(bool(spun["success"]) and int(spun["cycles"]) == 4, "rotating a pause does not change the step")
	var early: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 1, "dir": 0},
	])
	_check(bool(early["success"]) and int(early["cycles"]) == 3, "a conveyor in the pause's cell leaves on the arrival tick")
	var backed: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "return", "x": 2, "y": 1, "dir": 0},
	])
	_check(not bool(backed["success"]), "a return in the pause's cell misses the dock")
	var backed_face := _frame(backed, 3)
	_check(not backed_face.is_empty() and _dir_at(backed_face, 2, 1) == 2, "a return sends the eastbound parcel west")
	var hooked: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "hook", "x": 2, "y": 1, "dir": 0},
	])
	_check(not bool(hooked["success"]), "a hook in the pause's cell misses the dock")
	var hooked_face := _frame(hooked, 3)
	_check(not hooked_face.is_empty() and _dir_at(hooked_face, 2, 1) == 3, "a hook sends the eastbound parcel north")
	var turned: Dictionary = Sim.run(straight, [
		{"type": "turn", "x": 2, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
	])
	_check(not bool(turned["success"]), "a turn in the pause's cell misses the dock")
	var turned_face := _frame(turned, 3)
	_check(not turned_face.is_empty() and _dir_at(turned_face, 2, 1) == 1, "a turn sends the eastbound parcel south")
	var facings := [
		{"dir": 0, "src": Vector2i(0, 1), "pause": Vector2i(1, 1), "dock": Vector2i(2, 1), "name": "east"},
		{"dir": 1, "src": Vector2i(1, 0), "pause": Vector2i(1, 1), "dock": Vector2i(1, 2), "name": "south"},
		{"dir": 2, "src": Vector2i(2, 1), "pause": Vector2i(1, 1), "dock": Vector2i(0, 1), "name": "west"},
		{"dir": 3, "src": Vector2i(1, 2), "pause": Vector2i(1, 1), "dock": Vector2i(1, 0), "name": "north"},
	]
	for spec in facings:
		var dir := int(spec["dir"])
		var pause_at: Vector2i = spec["pause"]
		var dock_at: Vector2i = spec["dock"]
		var src_at: Vector2i = spec["src"]
		var lane := {
			"width": 3, "height": 3, "walls": [],
			"sources": [{"x": src_at.x, "y": src_at.y, "dir": dir, "parcels": [{"color": "gray"}]}],
			"dock": {"x": dock_at.x, "y": dock_at.y},
			"order": [{"color": "gray"}],
		}
		var held: Dictionary = Sim.run(lane, [{"type": "pause", "x": pause_at.x, "y": pause_at.y, "dir": 0}])
		var still := _frame(held, 2)
		_check(bool(held["success"]) and int(held["cycles"]) == 3, "a pause keeps %s and then steps that way" % str(spec["name"]))
		_check(not still.is_empty() and _at(still, pause_at.x, pause_at.y) and _dir_at(still, pause_at.x, pause_at.y) == dir, "a pause does not change a %s facing" % str(spec["name"]))

	var hop := {
		"width": 4, "height": 1, "walls": [{"x": 2, "y": 0}],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "gray"}],
	}
	var blocked: Dictionary = Sim.run(hop, [{"type": "pause", "x": 1, "y": 0, "dir": 1}])
	_check(not bool(blocked["success"]), "a pause does not carry a parcel over the next cell")
	var crossed := false
	for frame in blocked["frames"]:
		if _at(frame, 2, 0) or _at(frame, 3, 0):
			crossed = true
	_check(not crossed, "the parcel never reaches the cell past a pause")
	var slid: Dictionary = Sim.run(hop, [{"type": "slide", "x": 1, "y": 0, "dir": 1}])
	_check(bool(slid["success"]), "a slide still crosses the cell a pause cannot")

	var gap := {
		"width": 5, "height": 3, "walls": [],
		"sources": [
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 4, "y": 2, "dir": 3, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "blue"}, {"color": "gray"}],
	}
	var followed: Dictionary = Sim.run(gap, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 1, "dir": 0},
		{"type": "latch", "x": 3, "y": 1, "dir": 3},
		{"type": "conveyor", "x": 4, "y": 1, "dir": 2},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 6, "a pause can enter a cell another parcel is leaving")
	var into := _frame(followed, 4)
	_check(not into.is_empty() and _color_at(into, 3, 1) == "gray", "the pause steps into the cell the latch left")
	_check(into.get("delivered", []).size() == 1 and str(into["delivered"][0]["color"]) == "blue", "the parcel ahead is delivered on that tick")

	var held_board := {
		"width": 4, "height": 2, "walls": [],
		"sources": [
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 2, "y": 0, "dir": 1, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "gray"}],
	}
	var waiting: Dictionary = Sim.run(held_board, [
		{"type": "pause", "x": 1, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 1, "dir": 3},
	])
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a pause keeps waiting while its exit stays blocked")
	var same := _frame(waiting, 2)
	var first_try := _frame(waiting, 3)
	var later := _frame(waiting, 4)
	_check(not same.is_empty() and _dir_at(same, 1, 1) == 0, "the blocked pause does not change the east facing")
	_check(not first_try.is_empty() and _at(first_try, 1, 1) and _dir_at(first_try, 1, 1) == 0, "the first blocked step does not change the facing")
	_check(not later.is_empty() and _at(later, 1, 1) and _dir_at(later, 1, 1) == 0 and _color_at(later, 2, 1) == "blue", "the pause keeps the arrival facing while the other parcel stays")


func _building_ten() -> void:
	print("building 10")
	var puzzles := Puzzles.all()
	_check(puzzles.size() == 78, "building 10 adds routes 72 through 78")
	_check(Puzzles.INTRO.size() == 14 and Puzzles.INTRO[13] == "pause", "the pause is the block building 10 teaches")
	_check(not Puzzles.unlocked_at(70).has("pause"), "the pause stays locked through route 71")
	_check(Puzzles.unlocked_at(71).has("pause"), "route 72 unlocks the pause")
	_check(Puzzles.unlocked_at(77).size() == 14, "building 10 ends with every block")
	var pars := {
		72: [4, 2],
		73: [4, 4],
		74: [4, 2],
		75: [5, 6],
		76: [11, 11],
		77: [9, 5],
		78: [11, 10],
	}
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id < 72:
			_check(int(puzzle.get("building", 1)) < 10, "route %d stays out of building 10" % id)
			continue
		_check(int(puzzle.get("building", 1)) == 10, "route %d is building 10" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		var locked: Array = pars[id]
		_check(int(par["cycles"]) == int(locked[0]) and int(par["blocks"]) == int(locked[1]), "route %d par is %d cycles and %d blocks" % [id, int(locked[0]), int(locked[1])])
		if id == 72:
			_check(str(puzzle.get("unlocks", "")) == "pause", "route 72 teaches the pause")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_pause := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "pause":
				uses_pause = true
		_check(uses_pause, "route %d reference uses the pause" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	var lesson: Dictionary = Sim.run(_by_id(72), _by_id(72)["reference"])
	var arrived := _frame(lesson, 2)
	var paused := _frame(lesson, 3)
	_check(not arrived.is_empty() and _dir_at(arrived, 2, 1) == 0, "route 72 starts the parcel facing east on the pause")
	_check(not paused.is_empty() and _at(paused, 2, 1) and _dir_at(paused, 2, 1) == 0, "route 72 keeps the parcel facing east without moving it")
	for dir in range(4):
		var spun: Array = _by_id(72)["reference"].duplicate(true)
		for block in spun:
			if str(block["type"]) == "pause":
				block["dir"] = dir
		_check(bool(Sim.run(_by_id(72), spun)["success"]), "route 72 ignores which way the pause block is rotated")
	for id in [72, 73, 74, 75, 76, 77, 78]:
		_check(not bool(Sim.run(_by_id(id), _swap(_by_id(id), "pause", "return"))["success"]), "route %d fails if the pause is a return" % id)
		_check(not bool(Sim.run(_by_id(id), _swap(_by_id(id), "pause", "hook"))["success"]), "route %d fails if the pause is a hook" % id)
		_check(not bool(Sim.run(_by_id(id), _swap(_by_id(id), "pause", "turn"))["success"]), "route %d fails if the pause is a turn" % id)
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "pause":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the pause is missing" % id)
	for id in [73, 75, 76, 78]:
		_check(not bool(Sim.run(_by_id(id), _swap(_by_id(id), "pause", "conveyor"))["success"]), "route %d fails if the pause is a conveyor" % id)
	var let_back: Dictionary = Sim.run(_by_id(73), _swap(_by_id(73), "pause", "return"))
	var let_face := _frame(let_back, 3)
	_check(not let_face.is_empty() and _dir_at(let_face, 2, 1) == 2, "route 73 sends the first parcel back west")
	_check(not bool(Sim.run(_by_id(74), _swap(_by_id(74), "counter", "conveyor"))["success"]), "route 74 fails without the counter")
	var clear_hook := _frame(Sim.run(_by_id(75), _swap(_by_id(75), "pause", "hook")), 3)
	var clear_turn := _frame(Sim.run(_by_id(75), _swap(_by_id(75), "pause", "turn")), 3)
	_check(not clear_hook.is_empty() and _dir_at(clear_hook, 2, 1) == 3, "route 75 hooks red north off the belt")
	_check(not clear_turn.is_empty() and _dir_at(clear_turn, 2, 1) == 1, "route 75 turns red south off the belt")
	var paired: Dictionary = Sim.run(_by_id(76), _by_id(76)["reference"])
	var red_on := _frame(paired, 3)
	var blue_on := _frame(paired, 5)
	_check(not red_on.is_empty() and _at(red_on, 3, 1) and _dir_at(red_on, 3, 1) == 0, "route 76 keeps red facing east without moving it")
	_check(not blue_on.is_empty() and _at(blue_on, 3, 1) and _dir_at(blue_on, 3, 1) == 2, "route 76 keeps blue facing west without moving it")
	var both_hook: Dictionary = Sim.run(_by_id(76), _pause_exits(_swap(_by_id(76), "pause", "hook")))
	var red_hook := _frame(both_hook, 3)
	var blue_hook := _frame(both_hook, 5)
	_check(not bool(both_hook["success"]), "route 76 still misses when a hook can leave the cell")
	_check(not red_hook.is_empty() and _dir_at(red_hook, 3, 1) == 3, "route 76 hooks red a quarter counterclockwise")
	_check(not blue_hook.is_empty() and _dir_at(blue_hook, 3, 1) == 1, "route 76 hooks blue a quarter counterclockwise")
	var both_turn: Dictionary = Sim.run(_by_id(76), _pause_exits(_swap(_by_id(76), "pause", "turn")))
	var red_turn := _frame(both_turn, 3)
	var blue_turn := _frame(both_turn, 5)
	_check(not bool(both_turn["success"]), "route 76 still misses when a turn can leave the cell")
	_check(not red_turn.is_empty() and _dir_at(red_turn, 3, 1) == 1, "route 76 turns red a quarter clockwise")
	_check(not blue_turn.is_empty() and _dir_at(blue_turn, 3, 1) == 3, "route 76 turns blue a quarter clockwise")
	var both_back: Dictionary = Sim.run(_by_id(76), _swap(_by_id(76), "pause", "return"))
	var red_back := _frame(both_back, 3)
	var blue_back := _frame(both_back, 5)
	_check(not red_back.is_empty() and _dir_at(red_back, 3, 1) == 2, "route 76 sends red back west")
	_check(not blue_back.is_empty() and _dir_at(blue_back, 3, 1) == 0, "route 76 sends blue back east")
	_check(not bool(Sim.run(_by_id(77), _swap(_by_id(77), "painter", "conveyor"))["success"]), "route 77 fails if the parcel is not painted")
	_check(not bool(Sim.run(_by_id(77), _swap(_by_id(77), "counter", "conveyor"))["success"]), "route 77 fails without the second stamp")
	_check(not bool(Sim.run(_by_id(77), _swap(_by_id(77), "splitter", "conveyor"))["success"]), "route 77 loops if the splitter cannot send the second pass east")
	var sent_back := _frame(Sim.run(_by_id(77), _swap(_by_id(77), "pause", "return")), 8)
	_check(not sent_back.is_empty() and _dir_at(sent_back, 3, 1) == 2, "route 77 sends the parcel back the other way")
	_check(not bool(Sim.run(_by_id(78), _swap(_by_id(78), "primer", "painter"))["success"]), "route 78 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(78), _swap(_by_id(78), "filter", "conveyor"))["success"]), "route 78 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(78), _swap(_by_id(78), "counter", "conveyor"))["success"]), "route 78 fails without the counter")
	var night := _frame(Sim.run(_by_id(78), _by_id(78)["reference"]), 5)
	_check(not night.is_empty() and _at(night, 2, 2) and _dir_at(night, 2, 2) == 1, "route 78 keeps red facing south on the pause")
	var reversed := _frame(Sim.run(_by_id(78), _swap(_by_id(78), "pause", "return")), 5)
	_check(not reversed.is_empty() and _dir_at(reversed, 2, 2) == 3, "route 78 would reverse red if the pause were a return")


func _pause_exits(graph: Array) -> Array:
	var copy: Array = graph.duplicate(true)
	copy.append({"type": "conveyor", "x": 3, "y": 0, "dir": 3})
	copy.append({"type": "conveyor", "x": 3, "y": 2, "dir": 1})
	return copy


func _ui_uses_simulated_par() -> void:
	print("scoreboard ui")
	var scene := load("res://scenes/main.tscn")
	if scene == null:
		_check(false, "main scene loads")
		return
	var node = scene.instantiate()
	root.add_child(node)
	for index in [0, 6, 14, Puzzles.all().size() - 1]:
		node.select_puzzle(index)
		var puzzle: Dictionary = node.get_puzzle()
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var shown: String = node.format_result(result)
		_check(shown == Scoring.present(puzzle, result), "puzzle %d banner is the simulated scoreboard" % int(puzzle["id"]))
	node.select_puzzle(14)
	var building: Label = node.find_child("BuildingLabel", true, false)
	_check(building != null and building.text == "BUILDING 1", "route 15 still reads as building 1")
	_check(node.find_child("BuildingTwoMark", true, false) != null, "the route row marks building 2")
	var row: Node = node.find_child("PuzzleRow", true, false)
	var routes := 0
	var width := 0.0
	if row != null:
		for child in row.get_children():
			width += child.get_combined_minimum_size().x
			if child is Button:
				routes += 1
		if row.get_child_count() > 1:
			width += float(row.get_theme_constant("separation")) * float(row.get_child_count() - 1)
	_check(routes == 78, "all 78 routes are on the board")
	print("    route row width ", width)
	_check(width == 1552.0, "the route row minimum width is 1552 (%s)" % width)
	_check(int(ProjectSettings.get_setting("display/window/size/viewport_width")) == 1592, "the window is 1592 wide")
	node.select_puzzle(15)
	_check(building != null and building.text == "BUILDING 2", "route 16 opens building 2")
	var tools: Node = node.find_child("ToolBox", true, false)
	var saw_filter := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Filter"):
				saw_filter = true
	_check(saw_filter, "route 16 offers the filter")
	node.select_puzzle(21)
	_check(building != null and building.text == "BUILDING 2", "route 22 stays in building 2")
	node.select_puzzle(22)
	_check(building != null and building.text == "BUILDING 3", "route 23 opens building 3")
	_check(node.find_child("BuildingThreeMark", true, false) != null, "the route row marks building 3")
	tools = node.find_child("ToolBox", true, false)
	var saw_primer := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Primer"):
				saw_primer = true
	_check(saw_primer, "route 23 offers the primer")
	node.select_puzzle(28)
	_check(building != null and building.text == "BUILDING 3", "route 29 stays in building 3")
	node.select_puzzle(29)
	_check(building != null and building.text == "BUILDING 4", "route 30 opens building 4")
	_check(node.find_child("BuildingFourMark", true, false) != null, "the route row marks building 4")
	tools = node.find_child("ToolBox", true, false)
	var saw_bridge := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Bridge"):
				saw_bridge = true
	_check(saw_bridge, "route 30 offers the bridge")
	node.select_puzzle(35)
	_check(building != null and building.text == "BUILDING 4", "route 36 stays in building 4")
	node.select_puzzle(36)
	_check(building != null and building.text == "BUILDING 5", "route 37 opens building 5")
	_check(node.find_child("BuildingFiveMark", true, false) != null, "the route row marks building 5")
	tools = node.find_child("ToolBox", true, false)
	var saw_turn := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Turn"):
				saw_turn = true
	_check(saw_turn, "route 37 offers the turn")
	node.select_puzzle(42)
	_check(building != null and building.text == "BUILDING 5", "route 43 stays in building 5")
	node.select_puzzle(43)
	_check(building != null and building.text == "BUILDING 6", "route 44 opens building 6")
	_check(node.find_child("BuildingSixMark", true, false) != null, "the route row marks building 6")
	tools = node.find_child("ToolBox", true, false)
	var saw_slide := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Slide"):
				saw_slide = true
	_check(saw_slide, "route 44 offers the slide")
	node.select_puzzle(49)
	_check(building != null and building.text == "BUILDING 6", "route 50 stays in building 6")
	node.select_puzzle(50)
	_check(building != null and building.text == "BUILDING 7", "route 51 opens building 7")
	_check(node.find_child("BuildingSevenMark", true, false) != null, "the route row marks building 7")
	tools = node.find_child("ToolBox", true, false)
	var saw_bin := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Bin"):
				saw_bin = true
	_check(saw_bin, "route 51 offers the bin")
	node.select_puzzle(56)
	_check(building != null and building.text == "BUILDING 7", "route 57 stays in building 7")
	node.select_puzzle(57)
	_check(building != null and building.text == "BUILDING 8", "route 58 opens building 8")
	_check(node.find_child("BuildingEightMark", true, false) != null, "the route row marks building 8")
	tools = node.find_child("ToolBox", true, false)
	var saw_hook := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Hook"):
				saw_hook = true
	_check(saw_hook, "route 58 offers the hook")
	node.select_puzzle(63)
	_check(building != null and building.text == "BUILDING 8", "route 64 stays in building 8")
	tools = node.find_child("ToolBox", true, false)
	saw_hook = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Hook"):
				saw_hook = true
	_check(saw_hook, "route 64 still offers the hook")
	var saw_return := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Return"):
				saw_return = true
	_check(not saw_return, "route 64 keeps the return locked")
	node.select_puzzle(64)
	_check(building != null and building.text == "BUILDING 9", "route 65 opens building 9")
	_check(node.find_child("BuildingNineMark", true, false) != null, "the route row marks building 9")
	tools = node.find_child("ToolBox", true, false)
	saw_return = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Return"):
				saw_return = true
	_check(saw_return, "route 65 offers the return")
	node.select_puzzle(70)
	_check(building != null and building.text == "BUILDING 9", "route 71 stays in building 9")
	tools = node.find_child("ToolBox", true, false)
	saw_return = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Return"):
				saw_return = true
	_check(saw_return, "route 71 still offers the return")
	var saw_pause := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Pause"):
				saw_pause = true
	_check(not saw_pause, "route 71 keeps the pause locked")
	node.select_puzzle(71)
	_check(building != null and building.text == "BUILDING 10", "route 72 opens building 10")
	_check(node.find_child("BuildingTenMark", true, false) != null, "the route row marks building 10")
	tools = node.find_child("ToolBox", true, false)
	saw_pause = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Pause"):
				saw_pause = true
	_check(saw_pause, "route 72 offers the pause")
	node.select_puzzle(77)
	_check(building != null and building.text == "BUILDING 10", "route 78 stays in building 10")
	tools = node.find_child("ToolBox", true, false)
	saw_pause = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Pause"):
				saw_pause = true
	_check(saw_pause, "route 78 still offers the pause")
	node.queue_free()


func _frame(result: Dictionary, tick: int) -> Dictionary:
	for frame in result["frames"]:
		if int(frame["tick"]) == tick:
			return frame
	return {}


func _at(frame: Dictionary, x: int, y: int) -> bool:
	return _color_at(frame, x, y) != ""


func _color_at(frame: Dictionary, x: int, y: int) -> String:
	for parcel in frame["parcels"]:
		if int(parcel["x"]) == x and int(parcel["y"]) == y:
			return str(parcel["color"])
	return ""


func _dir_at(frame: Dictionary, x: int, y: int) -> int:
	for parcel in frame["parcels"]:
		if int(parcel["x"]) == x and int(parcel["y"]) == y:
			return int(parcel.get("dir", -1))
	return -1


func _count_at(frame: Dictionary, x: int, y: int) -> int:
	for parcel in frame["parcels"]:
		if int(parcel["x"]) == x and int(parcel["y"]) == y:
			return int(parcel["count"])
	return -1


func _dump(result: Dictionary) -> void:
	print("    reason ", result.get("reason", ""), " ticks ", result.get("ticks", ""), " delivered ", result.get("delivered", []))
	var frames: Array = result.get("frames", [])
	var start := maxi(0, frames.size() - 6)
	for i in range(start, frames.size()):
		print("    ", frames[i])
