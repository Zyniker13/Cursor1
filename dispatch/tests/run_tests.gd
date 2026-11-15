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
	_chute_rules()
	_building_eleven()
	_shunt_rules()
	_building_twelve()
	_bias_rules()
	_building_thirteen()
	_vault_rules()
	_building_fourteen()
	_sling_rules()
	_building_fifteen()
	_cant_rules()
	_building_sixteen()
	_balk_rules()
	_building_seventeen()
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


func _swap_cell(puzzle: Dictionary, x: int, y: int, to_type: String) -> Array:
	var graph: Array = puzzle["reference"].duplicate(true)
	for block in graph:
		if int(block["x"]) != x or int(block["y"]) != y:
			continue
		block["type"] = to_type
		if to_type != "painter" and to_type != "filter" and to_type != "primer":
			block.erase("color")
	return graph


func _omit_cell(puzzle: Dictionary, x: int, y: int) -> Array:
	var graph: Array = []
	for block in puzzle["reference"]:
		if int(block["x"]) == x and int(block["y"]) == y:
			continue
		graph.append(block.duplicate(true))
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
	_check(puzzles.size() >= 78, "building 10 adds routes 72 through 78")
	_check(Puzzles.INTRO.size() >= 14 and Puzzles.INTRO[13] == "pause", "the pause is the block building 10 teaches")
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
		if id > 78:
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


func _chute_rules() -> void:
	print("chute")
	var straight := {
		"width": 3, "height": 4,
		"walls": [
			{"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 2, "y": 0},
			{"x": 0, "y": 1},
			{"x": 0, "y": 2}, {"x": 2, "y": 2},
			{"x": 0, "y": 3}, {"x": 2, "y": 3},
		],
		"sources": [{"x": 1, "y": 3, "dir": 3, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 2, "y": 1},
		"order": [{"color": "gray"}],
	}
	var graph := [
		{"type": "conveyor", "x": 1, "y": 2, "dir": 3},
		{"type": "chute", "x": 1, "y": 1, "dir": 0},
	]
	var sent: Dictionary = Sim.run(straight, graph)
	_check(bool(sent["success"]), "a chute writes its facing and then delivers")
	_check(int(sent["cycles"]) == 4 and int(sent["blocks"]) == 2, "the chute waits a tick and delivers on tick 4")
	var born := _frame(sent, 2)
	var aimed := _frame(sent, 3)
	_check(not born.is_empty() and _dir_at(born, 1, 1) == 3, "the parcel arrives facing north")
	_check(not aimed.is_empty() and _at(aimed, 1, 1) and not _at(aimed, 2, 1), "the chute does not move the parcel on that tick")
	_check(_dir_at(aimed, 1, 1) == 0, "the chute writes east onto the parcel")
	_check(_count_at(aimed, 1, 1) == 0 and _color_at(aimed, 1, 1) == "gray", "a chute does not stamp or paint")
	var tinted: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 2, "dir": 3},
		{"type": "chute", "x": 1, "y": 1, "dir": 0, "color": "red"},
	])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a chute is ignored")
	for dir in range(4):
		var spun: Dictionary = Sim.run(straight, [
			{"type": "conveyor", "x": 1, "y": 2, "dir": 3},
			{"type": "chute", "x": 1, "y": 1, "dir": dir},
		])
		if dir == 0:
			_check(bool(spun["success"]) and int(spun["cycles"]) == 4, "an east chute steps east onto the dock")
		else:
			_check(not bool(spun["success"]), "rotating the chute off east misses the dock")
	var early: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 2, "dir": 3},
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
	])
	_check(bool(early["success"]) and int(early["cycles"]) == 3, "an east conveyor in the chute's cell leaves on the arrival tick and still delivers")
	var kept: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 2, "dir": 3},
		{"type": "pause", "x": 1, "y": 1, "dir": 0},
	])
	_check(not bool(kept["success"]), "a pause in the chute's cell keeps north and misses the dock")
	var kept_face := _frame(kept, 3)
	_check(not kept_face.is_empty() and _dir_at(kept_face, 1, 1) == 3, "a pause leaves the north facing unchanged")
	var backed: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 2, "dir": 3},
		{"type": "return", "x": 1, "y": 1, "dir": 0},
	])
	_check(not bool(backed["success"]), "a return in the chute's cell misses the dock")
	var backed_face := _frame(backed, 3)
	_check(not backed_face.is_empty() and _dir_at(backed_face, 1, 1) == 1, "a return sends the northbound parcel south")
	var hooked: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 2, "dir": 3},
		{"type": "hook", "x": 1, "y": 1, "dir": 0},
	])
	_check(not bool(hooked["success"]), "a hook in the chute's cell misses the dock")
	var hooked_face := _frame(hooked, 3)
	_check(not hooked_face.is_empty() and _dir_at(hooked_face, 1, 1) == 2, "a hook sends the northbound parcel west")
	var turned: Dictionary = Sim.run(straight, [
		{"type": "turn", "x": 1, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 1, "y": 2, "dir": 3},
	])
	_check(bool(turned["success"]) and int(turned["cycles"]) == 4, "a turn also steps east, because a clockwise quarter from north is east")
	var turned_face := _frame(turned, 3)
	_check(not turned_face.is_empty() and _dir_at(turned_face, 1, 1) == 0, "the turn writes east before it steps")

	var aims := [
		{"dir": 0, "src": Vector2i(1, 2), "arrival": 3, "chute": Vector2i(1, 1), "dock": Vector2i(2, 1), "name": "east"},
		{"dir": 1, "src": Vector2i(0, 1), "arrival": 0, "chute": Vector2i(1, 1), "dock": Vector2i(1, 2), "name": "south"},
		{"dir": 2, "src": Vector2i(1, 0), "arrival": 1, "chute": Vector2i(1, 1), "dock": Vector2i(0, 1), "name": "west"},
		{"dir": 3, "src": Vector2i(2, 1), "arrival": 2, "chute": Vector2i(1, 1), "dock": Vector2i(1, 0), "name": "north"},
	]
	for spec in aims:
		var dir := int(spec["dir"])
		var chute_at: Vector2i = spec["chute"]
		var dock_at: Vector2i = spec["dock"]
		var src_at: Vector2i = spec["src"]
		var lane := {
			"width": 3, "height": 3, "walls": [],
			"sources": [{"x": src_at.x, "y": src_at.y, "dir": int(spec["arrival"]), "parcels": [{"color": "gray"}]}],
			"dock": {"x": dock_at.x, "y": dock_at.y},
			"order": [{"color": "gray"}],
		}
		var aimed_run: Dictionary = Sim.run(lane, [{"type": "chute", "x": chute_at.x, "y": chute_at.y, "dir": dir}])
		var still := _frame(aimed_run, 2)
		_check(bool(aimed_run["success"]) and int(aimed_run["cycles"]) == 3, "a chute aims %s and then steps that way" % str(spec["name"]))
		_check(not still.is_empty() and _at(still, chute_at.x, chute_at.y) and _dir_at(still, chute_at.x, chute_at.y) == dir, "a chute writes %s on the arrival tick" % str(spec["name"]))

	var hop := {
		"width": 4, "height": 1, "walls": [{"x": 2, "y": 0}],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "gray"}],
	}
	var blocked: Dictionary = Sim.run(hop, [{"type": "chute", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(blocked["success"]), "a chute does not carry a parcel over the next cell")
	var crossed := false
	for frame in blocked["frames"]:
		if _at(frame, 3, 0):
			crossed = true
	_check(not crossed, "the parcel never reaches the cell past a chute")
	var slid: Dictionary = Sim.run(hop, [{"type": "slide", "x": 1, "y": 0, "dir": 0}])
	_check(bool(slid["success"]), "a slide still crosses the cell a chute cannot")

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
		{"type": "chute", "x": 2, "y": 1, "dir": 0},
		{"type": "latch", "x": 3, "y": 1, "dir": 3},
		{"type": "conveyor", "x": 4, "y": 1, "dir": 2},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 6, "a chute can enter a cell another parcel is leaving")
	var into := _frame(followed, 4)
	_check(not into.is_empty() and _color_at(into, 3, 1) == "gray", "the chute steps into the cell the latch left")
	_check(into.get("delivered", []).size() == 1 and str(into["delivered"][0]["color"]) == "blue", "the parcel ahead is delivered on that tick")

	var held_board := {
		"width": 4, "height": 3, "walls": [],
		"sources": [
			{"x": 1, "y": 2, "dir": 3, "parcels": [{"color": "gray"}]},
			{"x": 2, "y": 0, "dir": 1, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 3, "y": 1},
		"order": [{"color": "gray"}],
	}
	var waiting: Dictionary = Sim.run(held_board, [
		{"type": "chute", "x": 1, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 1, "dir": 3},
	])
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a chute keeps waiting while its exit stays blocked")
	var same := _frame(waiting, 2)
	var first_try := _frame(waiting, 3)
	var later := _frame(waiting, 4)
	_check(not same.is_empty() and _dir_at(same, 1, 1) == 0, "the blocked chute has already written east")
	_check(not first_try.is_empty() and _at(first_try, 1, 1) and _dir_at(first_try, 1, 1) == 0, "the first blocked step does not write the facing again")
	_check(not later.is_empty() and _at(later, 1, 1) and _dir_at(later, 1, 1) == 0 and _color_at(later, 2, 1) == "blue", "the chute keeps the written facing while the other parcel stays")


func _building_eleven() -> void:
	print("building 11")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 85, "building 11 adds routes 79 through 85")
	_check(Puzzles.INTRO.size() >= 15 and Puzzles.INTRO[14] == "chute", "the chute is the block building 11 teaches")
	_check(not Puzzles.unlocked_at(77).has("chute"), "the chute stays locked through route 78")
	_check(Puzzles.unlocked_at(78).has("chute"), "route 79 unlocks the chute")
	_check(Puzzles.unlocked_at(84).size() == 15, "building 11 ends with every block")
	var pars := {
		79: [4, 2],
		80: [4, 4],
		81: [4, 2],
		82: [5, 6],
		83: [7, 6],
		84: [9, 5],
		85: [13, 12],
	}
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id < 79:
			_check(int(puzzle.get("building", 1)) < 11, "route %d stays out of building 11" % id)
			continue
		if id > 85:
			continue
		_check(int(puzzle.get("building", 1)) == 11, "route %d is building 11" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		var locked: Array = pars[id]
		_check(int(par["cycles"]) == int(locked[0]) and int(par["blocks"]) == int(locked[1]), "route %d par is %d cycles and %d blocks" % [id, int(locked[0]), int(locked[1])])
		if id == 79:
			_check(str(puzzle.get("unlocks", "")) == "chute", "route 79 teaches the chute")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_chute := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "chute":
				uses_chute = true
		_check(uses_chute, "route %d reference uses the chute" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	var lesson: Dictionary = Sim.run(_by_id(79), _by_id(79)["reference"])
	var arrived := _frame(lesson, 2)
	var aimed := _frame(lesson, 3)
	_check(not arrived.is_empty() and _dir_at(arrived, 1, 1) == 3, "route 79 starts the parcel facing north on the chute")
	_check(not aimed.is_empty() and _at(aimed, 1, 1) and _dir_at(aimed, 1, 1) == 0, "route 79 writes east without moving the parcel")
	for dir in range(4):
		var spun: Array = _by_id(79)["reference"].duplicate(true)
		for block in spun:
			if str(block["type"]) == "chute":
				block["dir"] = dir
		var spun_run: Dictionary = Sim.run(_by_id(79), spun)
		if dir == 0:
			_check(bool(spun_run["success"]), "route 79 delivers when the chute faces east")
		else:
			_check(not bool(spun_run["success"]), "route 79 misses when the chute is rotated off the dock")
	for id in [79, 80, 81, 82, 83, 84, 85]:
		_check(not bool(Sim.run(_by_id(id), _swap(_by_id(id), "chute", "pause"))["success"]), "route %d fails if the chute is a pause" % id)
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "chute":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the chute is missing" % id)
	for id in [79, 80, 81, 83, 84, 85]:
		_check(not bool(Sim.run(_by_id(id), _swap(_by_id(id), "chute", "return"))["success"]), "route %d fails if the chute is a return" % id)
	for id in [79, 80, 81, 82, 83]:
		_check(not bool(Sim.run(_by_id(id), _swap(_by_id(id), "chute", "hook"))["success"]), "route %d fails if the chute is a hook" % id)
	for id in [82, 83, 84, 85]:
		_check(not bool(Sim.run(_by_id(id), _swap(_by_id(id), "chute", "turn"))["success"]), "route %d fails if the chute is a turn" % id)
	for id in [80, 82]:
		_check(not bool(Sim.run(_by_id(id), _swap(_by_id(id), "chute", "conveyor"))["success"]), "route %d fails if the chute is a conveyor" % id)
	for id in [79, 81, 83, 84, 85]:
		var belted: Dictionary = Sim.run(_by_id(id), _swap(_by_id(id), "chute", "conveyor"))
		_check(bool(belted["success"]), "route %d still delivers if the chute is a conveyor aimed the same way" % id)
		if id == 79:
			_check(int(belted["cycles"]) == 3, "route 79's east conveyor leaves on the arrival tick and delivers one tick sooner")
		elif id == 81:
			_check(int(belted["cycles"]) == 3 and int(belted["delivered"][0]["count"]) == 1, "route 81's east conveyor still stamps 1")
		elif id == 83:
			_check(int(belted["cycles"]) == 6, "route 83's east conveyor delivers both parcels one tick sooner")
		elif id == 84:
			_check(int(belted["cycles"]) == 8, "route 84's north conveyor delivers the yellow stamp one tick sooner")
		elif id == 85:
			_check(int(belted["cycles"]) == 13, "route 85's east conveyor still delivers on the long belt's tick")
	_check(bool(Sim.run(_by_id(79), _swap(_by_id(79), "chute", "turn"))["success"]), "route 79 still delivers if the chute is a turn")
	_check(bool(Sim.run(_by_id(80), _swap(_by_id(80), "chute", "turn"))["success"]), "route 80 still delivers if the chute is a turn")
	_check(bool(Sim.run(_by_id(81), _swap(_by_id(81), "chute", "turn"))["success"]), "route 81 still delivers if the chute is a turn")
	_check(bool(Sim.run(_by_id(82), _swap(_by_id(82), "chute", "return"))["success"]), "route 82 still delivers if the chute is a return")
	_check(bool(Sim.run(_by_id(84), _swap(_by_id(84), "chute", "hook"))["success"]), "route 84 still delivers if the chute is a hook")
	_check(bool(Sim.run(_by_id(85), _swap(_by_id(85), "chute", "hook"))["success"]), "route 85 still delivers if the chute is a hook")

	var let_face := _frame(Sim.run(_by_id(80), _swap(_by_id(80), "chute", "pause")), 3)
	_check(not let_face.is_empty() and _dir_at(let_face, 1, 1) == 3, "route 80's pause keeps the first parcel facing north")
	_check(not bool(Sim.run(_by_id(81), _swap(_by_id(81), "counter", "conveyor"))["success"]), "route 81 fails without the counter")
	var clear_hook := _frame(Sim.run(_by_id(82), _swap(_by_id(82), "chute", "hook")), 4)
	var clear_turn := _frame(Sim.run(_by_id(82), _swap(_by_id(82), "chute", "turn")), 4)
	var clear_pause := _frame(Sim.run(_by_id(82), _swap(_by_id(82), "chute", "pause")), 4)
	_check(not clear_pause.is_empty() and _dir_at(clear_pause, 2, 1) == 2, "route 82's pause keeps red facing west")
	_check(not clear_hook.is_empty() and _dir_at(clear_hook, 2, 1) == 1, "route 82 hooks red south off the belt")
	_check(not clear_turn.is_empty() and _dir_at(clear_turn, 2, 1) == 3, "route 82 turns red north off the belt")
	var paired: Dictionary = Sim.run(_by_id(83), _by_id(83)["reference"])
	var red_on := _frame(paired, 2)
	var blue_on := _frame(paired, 4)
	_check(not red_on.is_empty() and _at(red_on, 2, 2) and _dir_at(red_on, 2, 2) == 1, "route 83 starts red facing south on the chute")
	_check(not blue_on.is_empty() and _at(blue_on, 2, 2) and _dir_at(blue_on, 2, 2) == 3, "route 83 starts blue facing north on the chute")
	var red_aimed := _frame(paired, 3)
	var blue_aimed := _frame(paired, 5)
	_check(not red_aimed.is_empty() and _at(red_aimed, 2, 2) and _dir_at(red_aimed, 2, 2) == 0, "route 83 writes east onto red without moving it")
	_check(not blue_aimed.is_empty() and _at(blue_aimed, 2, 2) and _dir_at(blue_aimed, 2, 2) == 0, "route 83 writes east onto blue without moving it")
	var both_pause: Dictionary = Sim.run(_by_id(83), _swap(_by_id(83), "chute", "pause"))
	_check(not bool(both_pause["success"]), "route 83 misses when a pause keeps each arrival")
	_check(_dir_at(_frame(both_pause, 3), 2, 2) == 1, "route 83's pause keeps red facing south")
	_check(_dir_at(_frame(both_pause, 4), 2, 2) == 3, "route 83's pause keeps blue facing north")
	var both_back: Dictionary = Sim.run(_by_id(83), _swap(_by_id(83), "chute", "return"))
	_check(not bool(both_back["success"]), "route 83 misses when a return sends each parcel back")
	_check(_dir_at(_frame(both_back, 3), 2, 2) == 3, "route 83 sends red back north")
	_check(_dir_at(_frame(both_back, 5), 2, 2) == 1, "route 83 sends blue back south")
	var both_hook: Dictionary = Sim.run(_by_id(83), _swap(_by_id(83), "chute", "hook"))
	_check(not bool(both_hook["success"]), "route 83 misses when a hook turns both counterclockwise")
	_check(_dir_at(_frame(both_hook, 3), 2, 2) == 0, "route 83 hooks red a quarter counterclockwise")
	_check(_dir_at(_frame(both_hook, 5), 2, 2) == 2, "route 83 hooks blue a quarter counterclockwise")
	var both_turn: Dictionary = Sim.run(_by_id(83), _chute_turn_exit(_swap(_by_id(83), "chute", "turn")))
	_check(not bool(both_turn["success"]), "route 83 still misses when a turn can leave the cell")
	_check(_dir_at(_frame(both_turn, 3), 2, 2) == 2, "route 83 turns red a quarter clockwise")
	_check(_dir_at(_frame(both_turn, 5), 2, 2) == 0, "route 83 turns blue a quarter clockwise")
	_check(not bool(Sim.run(_by_id(84), _swap(_by_id(84), "painter", "conveyor"))["success"]), "route 84 fails if the parcel is not painted")
	_check(not bool(Sim.run(_by_id(84), _swap(_by_id(84), "counter", "conveyor"))["success"]), "route 84 fails without the second stamp")
	_check(not bool(Sim.run(_by_id(84), _swap(_by_id(84), "splitter", "conveyor"))["success"]), "route 84 loops if the splitter cannot send the second pass east")
	var off_dock := _frame(Sim.run(_by_id(84), _swap(_by_id(84), "chute", "pause")), 8)
	_check(not off_dock.is_empty() and _at(off_dock, 3, 1) and _dir_at(off_dock, 3, 1) == 0, "route 84's pause keeps the east facing, off the dock")
	var aimed_north := _frame(Sim.run(_by_id(84), _by_id(84)["reference"]), 8)
	_check(not aimed_north.is_empty() and _at(aimed_north, 3, 1) and _dir_at(aimed_north, 3, 1) == 3, "route 84 writes north onto the parcel")
	_check(not bool(Sim.run(_by_id(85), _swap(_by_id(85), "primer", "painter"))["success"]), "route 85 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(85), _swap(_by_id(85), "filter", "conveyor"))["success"]), "route 85 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(85), _swap(_by_id(85), "counter", "conveyor"))["success"]), "route 85 fails without the counter")
	var night := _frame(Sim.run(_by_id(85), _by_id(85)["reference"]), 5)
	_check(not night.is_empty() and _at(night, 2, 2) and _dir_at(night, 2, 2) == 0, "route 85 writes east onto red")
	var night_pause := _frame(Sim.run(_by_id(85), _swap(_by_id(85), "chute", "pause")), 5)
	_check(not night_pause.is_empty() and _dir_at(night_pause, 2, 2) == 1, "route 85's pause keeps red facing south")
	var reversed := _frame(Sim.run(_by_id(85), _swap(_by_id(85), "chute", "return")), 5)
	_check(not reversed.is_empty() and _dir_at(reversed, 2, 2) == 3, "route 85 reverses red if the chute is a return")


func _chute_turn_exit(graph: Array) -> Array:
	var copy: Array = graph.duplicate(true)
	copy.append({"type": "conveyor", "x": 1, "y": 2, "dir": 2})
	return copy


func _shunt_rules() -> void:
	print("shunt")
	var straight := {
		"width": 4, "height": 3,
		"walls": [
			{"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 2, "y": 0}, {"x": 3, "y": 0},
			{"x": 3, "y": 1},
			{"x": 0, "y": 2}, {"x": 1, "y": 2},
		],
		"sources": [{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 3, "y": 2},
		"order": [{"color": "gray"}],
	}
	var graph := [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "shunt", "x": 2, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 2, "dir": 0},
	]
	var sent: Dictionary = Sim.run(straight, graph)
	_check(bool(sent["success"]), "a shunt steps aside and the kept facing delivers")
	_check(int(sent["cycles"]) == 6 and int(sent["blocks"]) == 3, "the shunt waits a tick and delivers on tick 6")
	var born := _frame(sent, 2)
	var waited := _frame(sent, 3)
	var stepped := _frame(sent, 4)
	_check(not born.is_empty() and _dir_at(born, 2, 1) == 0, "the parcel arrives facing east")
	_check(not waited.is_empty() and _at(waited, 2, 1) and not _at(waited, 2, 2), "the shunt does not move the parcel on that tick")
	_check(_dir_at(waited, 2, 1) == 0, "the shunt leaves the east facing unchanged")
	_check(_count_at(waited, 2, 1) == 0 and _color_at(waited, 2, 1) == "gray", "a shunt does not stamp or paint")
	_check(not stepped.is_empty() and _at(stepped, 2, 2) and _dir_at(stepped, 2, 2) == 0, "the side step goes south and the parcel still faces east")
	var tinted: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "shunt", "x": 2, "y": 1, "dir": 0, "color": "red"},
		{"type": "pause", "x": 2, "y": 2, "dir": 0},
	])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a shunt is ignored")
	for dir in range(4):
		var spun: Array = graph.duplicate(true)
		spun[1]["dir"] = dir
		var run: Dictionary = Sim.run(straight, spun)
		_check(bool(run["success"]) and int(run["cycles"]) == 6, "rotating a shunt does not change the side step")
	var turned: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "turn", "x": 2, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 2, "dir": 0},
	])
	_check(not bool(turned["success"]), "a turn in the shunt's cell faces south and the pause misses the dock")
	var turned_face := _frame(turned, 3)
	var turned_step := _frame(turned, 4)
	_check(not turned_face.is_empty() and _dir_at(turned_face, 2, 1) == 1, "the turn writes south before it steps")
	_check(not turned_step.is_empty() and _at(turned_step, 2, 2) and _dir_at(turned_step, 2, 2) == 1, "the turn's step faces the way it moved")
	var kept: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 2, "dir": 0},
	])
	_check(not bool(kept["success"]), "a pause in the shunt's cell keeps east and never steps south")
	var kept_face := _frame(kept, 3)
	_check(not kept_face.is_empty() and _at(kept_face, 2, 1) and _dir_at(kept_face, 2, 1) == 0 and not _at(kept_face, 2, 2), "the pause is still on the shunt cell facing east")
	var aimed: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "chute", "x": 2, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 2, "dir": 0},
	])
	_check(not bool(aimed["success"]), "an east chute sends the parcel east and misses the side step")
	var hooked: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "hook", "x": 2, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 2, "dir": 0},
	])
	_check(not bool(hooked["success"]), "a hook in the shunt's cell misses the dock")
	_check(_dir_at(_frame(hooked, 3), 2, 1) == 3, "a hook sends the eastbound parcel north")
	var backed: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "return", "x": 2, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 2, "dir": 0},
	])
	_check(not bool(backed["success"]) and str(backed["reason"]) == "tick_cap", "a return in the shunt's cell misses the dock")
	_check(_dir_at(_frame(backed, 3), 2, 1) == 2, "a return sends the eastbound parcel west")
	_check(_at(_frame(backed, 4), 1, 1) and _dir_at(_frame(backed, 4), 1, 1) == 2, "the return then steps back west")
	var early_board := {
		"width": 4, "height": 3,
		"walls": [
			{"x": 0, "y": 0}, {"x": 1, "y": 0}, {"x": 2, "y": 0}, {"x": 3, "y": 0},
			{"x": 0, "y": 2}, {"x": 1, "y": 2},
		],
		"sources": [{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 3, "y": 2},
		"order": [{"color": "gray"}],
	}
	var early_graph := [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "shunt", "x": 2, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 3, "y": 1, "dir": 3},
		{"type": "pause", "x": 2, "y": 2, "dir": 0},
	]
	var held_side: Dictionary = Sim.run(early_board, early_graph)
	_check(bool(held_side["success"]) and int(held_side["cycles"]) == 6, "an unused east belt does not change the shunt")
	_check(_at(_frame(held_side, 3), 2, 1) and not _at(_frame(held_side, 3), 3, 1), "the shunt is still waiting on the arrival tick")
	var early: Dictionary = Sim.run(early_board, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 3, "y": 1, "dir": 3},
		{"type": "pause", "x": 2, "y": 2, "dir": 0},
	])
	_check(not bool(early["success"]), "an east conveyor leaves on the arrival tick and misses the dock")
	_check(_at(_frame(early, 3), 3, 1), "the conveyor is already east while a shunt would still be waiting")

	var rights := [
		{"name": "east", "src": Vector2i(0, 1), "arrival": 0, "shunt": Vector2i(1, 1), "side": Vector2i(1, 2), "dock": Vector2i(2, 2)},
		{"name": "south", "src": Vector2i(1, 0), "arrival": 1, "shunt": Vector2i(1, 1), "side": Vector2i(0, 1), "dock": Vector2i(0, 2)},
		{"name": "west", "src": Vector2i(2, 1), "arrival": 2, "shunt": Vector2i(1, 1), "side": Vector2i(1, 0), "dock": Vector2i(0, 0)},
		{"name": "north", "src": Vector2i(1, 2), "arrival": 3, "shunt": Vector2i(1, 1), "side": Vector2i(2, 1), "dock": Vector2i(2, 0)},
	]
	for spec in rights:
		var src_at: Vector2i = spec["src"]
		var shunt_at: Vector2i = spec["shunt"]
		var side_at: Vector2i = spec["side"]
		var dock_at: Vector2i = spec["dock"]
		var arrival := int(spec["arrival"])
		var lane := {
			"width": 3, "height": 3, "walls": [],
			"sources": [{"x": src_at.x, "y": src_at.y, "dir": arrival, "parcels": [{"color": "gray"}]}],
			"dock": {"x": dock_at.x, "y": dock_at.y},
			"order": [{"color": "gray"}],
		}
		var blocks := [
			{"type": "shunt", "x": shunt_at.x, "y": shunt_at.y, "dir": 0},
			{"type": "pause", "x": side_at.x, "y": side_at.y, "dir": 0},
		]
		var run: Dictionary = Sim.run(lane, blocks)
		var moved := _frame(run, 3)
		_check(bool(run["success"]) and int(run["cycles"]) == 5, "a %s parcel steps to its right and the pause follows the old facing" % str(spec["name"]))
		_check(not moved.is_empty() and _at(moved, side_at.x, side_at.y) and _dir_at(moved, side_at.x, side_at.y) == arrival, "a %s parcel still faces %s after the side step" % [str(spec["name"]), str(spec["name"])])

	var hop := {
		"width": 3, "height": 4, "walls": [{"x": 1, "y": 2}],
		"sources": [{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 1, "y": 3},
		"order": [{"color": "gray"}],
	}
	var blocked: Dictionary = Sim.run(hop, [{"type": "shunt", "x": 1, "y": 1, "dir": 0}])
	_check(not bool(blocked["success"]), "a shunt does not carry a parcel over the next cell")
	var crossed := false
	for frame in blocked["frames"]:
		if _at(frame, 1, 3):
			crossed = true
	_check(not crossed, "the parcel never reaches the cell past a shunt")

	var gap := {
		"width": 4, "height": 3, "walls": [],
		"sources": [
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 0, "y": 2, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 3, "y": 2},
		"order": [{"color": "blue"}, {"color": "gray"}],
	}
	var followed: Dictionary = Sim.run(gap, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "shunt", "x": 2, "y": 1, "dir": 0},
		{"type": "pause", "x": 1, "y": 2, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 2, "dir": 0},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 5, "a shunt can enter a cell another parcel is leaving")
	var into := _frame(followed, 4)
	_check(not into.is_empty() and _color_at(into, 2, 2) == "gray" and _dir_at(into, 2, 2) == 0, "the shunt steps into the cell the other parcel left and still faces east")
	_check(into.get("delivered", []).size() == 1 and str(into["delivered"][0]["color"]) == "blue", "the parcel ahead is delivered on that tick")

	var held_board := {
		"width": 4, "height": 4, "walls": [{"x": 3, "y": 2}],
		"sources": [
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 2, "y": 3, "dir": 3, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 3, "y": 1},
		"order": [{"color": "gray"}],
	}
	var waiting: Dictionary = Sim.run(held_board, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "shunt", "x": 2, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 2, "dir": 0},
	])
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a shunt keeps waiting while its side cell stays blocked")
	var same := _frame(waiting, 3)
	var first_try := _frame(waiting, 4)
	var later := _frame(waiting, 5)
	_check(not same.is_empty() and _at(same, 2, 1) and _dir_at(same, 2, 1) == 0, "the blocked shunt still faces east on the wait")
	_check(not first_try.is_empty() and _at(first_try, 2, 1) and _dir_at(first_try, 2, 1) == 0, "the first blocked side step does not change the facing")
	_check(not later.is_empty() and _at(later, 2, 1) and _dir_at(later, 2, 1) == 0 and _color_at(later, 2, 2) == "blue", "the shunt keeps the arrival facing while the other parcel stays")


func _building_twelve() -> void:
	print("building 12")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 92, "building 12 adds routes 86 through 92")
	_check(Puzzles.INTRO.size() >= 16 and Puzzles.INTRO[15] == "shunt", "the shunt is the block building 12 teaches")
	_check(not Puzzles.unlocked_at(84).has("shunt"), "the shunt stays locked through route 85")
	_check(Puzzles.unlocked_at(85).has("shunt"), "route 86 unlocks the shunt")
	_check(Puzzles.unlocked_at(91).size() == 16, "building 12 ends with every block")
	var pars := {
		86: [6, 3],
		87: [8, 10],
		88: [7, 4],
		89: [8, 10],
		90: [18, 16],
		91: [11, 6],
		92: [12, 12],
	}
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id < 86:
			_check(int(puzzle.get("building", 1)) < 12, "route %d stays out of building 12" % id)
			continue
		if id > 92:
			continue
		_check(int(puzzle.get("building", 1)) == 12, "route %d is building 12" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		var locked: Array = pars[id]
		_check(int(par["cycles"]) == int(locked[0]) and int(par["blocks"]) == int(locked[1]), "route %d par is %d cycles and %d blocks" % [id, int(locked[0]), int(locked[1])])
		if id == 86:
			_check(str(puzzle.get("unlocks", "")) == "shunt", "route 86 teaches the shunt")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_shunt := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "shunt":
				uses_shunt = true
		_check(uses_shunt, "route %d reference uses the shunt" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	var lesson: Dictionary = Sim.run(_by_id(86), _by_id(86)["reference"])
	_check(not _frame(lesson, 2).is_empty() and _dir_at(_frame(lesson, 2), 2, 1) == 0, "route 86 starts the parcel facing east on the shunt")
	_check(_at(_frame(lesson, 3), 2, 1) and _dir_at(_frame(lesson, 3), 2, 1) == 0, "route 86 keeps the parcel facing east without moving it")
	_check(_at(_frame(lesson, 4), 2, 2) and _dir_at(_frame(lesson, 4), 2, 2) == 0, "route 86 steps south and still faces east")
	for id in [86, 87, 88, 89, 90, 91, 92]:
		for dir in range(4):
			var spun: Array = _by_id(id)["reference"].duplicate(true)
			for block in spun:
				if str(block["type"]) == "shunt":
					block["dir"] = dir
			var spun_run: Dictionary = Sim.run(_by_id(id), spun)
			_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == int(pars[id][0]), "route %d ignores which way the shunt block is rotated" % id)
		for kind in ["turn", "pause", "chute", "hook", "return", "conveyor"]:
			var swapped: Dictionary = Sim.run(_by_id(id), _swap(_by_id(id), "shunt", kind))
			_check(not bool(swapped["success"]), "route %d fails if the shunt is a %s" % [id, kind])
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "shunt":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the shunt is missing" % id)

	var let_turn := _frame(Sim.run(_by_id(87), _swap(_by_id(87), "shunt", "turn")), 4)
	_check(not let_turn.is_empty() and _at(let_turn, 2, 2) and _dir_at(let_turn, 2, 2) == 1, "route 87's turn steps south facing south")
	_check(str(Sim.run(_by_id(87), _swap(_by_id(87), "shunt", "conveyor"))["reason"]) == "wrong_delivery", "route 87's conveyor delivers red before blue")
	_check(str(Sim.run(_by_id(87), _swap(_by_id(87), "shunt", "pause"))["reason"]) == "wrong_delivery", "route 87's pause sends red east ahead of blue")
	var counted: Dictionary = Sim.run(_by_id(88), _by_id(88)["reference"])
	_check(int(counted["delivered"][0]["count"]) == 1, "route 88 delivers count 1")
	_check(_at(_frame(counted, 4), 2, 2) and _dir_at(_frame(counted, 4), 2, 2) == 0, "route 88 lands facing east, not along the side step")
	var count_turn := _frame(Sim.run(_by_id(88), _swap(_by_id(88), "shunt", "turn")), 4)
	_check(not count_turn.is_empty() and _at(count_turn, 2, 2) and _dir_at(count_turn, 2, 2) == 1, "route 88's turn reaches the side cell facing south")
	_check(not bool(Sim.run(_by_id(88), _swap(_by_id(88), "counter", "conveyor"))["success"]), "route 88 fails without the counter")
	var clear_turn := _frame(Sim.run(_by_id(89), _swap(_by_id(89), "shunt", "turn")), 4)
	_check(not clear_turn.is_empty() and _at(clear_turn, 2, 3) and _dir_at(clear_turn, 2, 3) == 1, "route 89's turn steps aside facing south")
	_check(str(Sim.run(_by_id(89), _swap(_by_id(89), "shunt", "pause"))["reason"]) == "wrong_delivery", "route 89's pause does not step aside")
	var paired: Dictionary = Sim.run(_by_id(90), _by_id(90)["reference"])
	_check(_at(_frame(paired, 4), 2, 3) and _dir_at(_frame(paired, 4), 2, 3) == 0, "route 90 steps red south and leaves it facing east")
	_check(_at(_frame(paired, 6), 2, 1) and _dir_at(_frame(paired, 6), 2, 1) == 2, "route 90 steps blue north and leaves it facing west")
	var both_turn: Dictionary = Sim.run(_by_id(90), _swap(_by_id(90), "shunt", "turn"))
	_check(_dir_at(_frame(both_turn, 3), 2, 2) == 1, "route 90 turns red a quarter clockwise")
	_check(_dir_at(_frame(both_turn, 5), 2, 2) == 3, "route 90 turns blue a quarter clockwise")
	_check(not bool(Sim.run(_by_id(91), _swap(_by_id(91), "painter", "conveyor"))["success"]), "route 91 fails if the parcel is not painted")
	_check(not bool(Sim.run(_by_id(91), _swap(_by_id(91), "counter", "conveyor"))["success"]), "route 91 fails without the second stamp")
	_check(not bool(Sim.run(_by_id(91), _swap(_by_id(91), "splitter", "conveyor"))["success"]), "route 91 loops if the splitter cannot send the second pass east")
	var second: Dictionary = Sim.run(_by_id(91), _by_id(91)["reference"])
	_check(str(second["delivered"][0]["color"]) == "yellow" and int(second["delivered"][0]["count"]) == 2, "route 91 delivers yellow 2")
	_check(_at(_frame(second, 9), 3, 2) and _dir_at(_frame(second, 9), 3, 2) == 0, "route 91 steps south and still faces east")
	var second_turn := _frame(Sim.run(_by_id(91), _swap(_by_id(91), "shunt", "turn")), 9)
	_check(not second_turn.is_empty() and _at(second_turn, 3, 2) and _dir_at(second_turn, 3, 2) == 1, "route 91's turn reaches the side cell facing south")
	var second_pause := _frame(Sim.run(_by_id(91), _swap(_by_id(91), "shunt", "pause")), 8)
	_check(not second_pause.is_empty() and _at(second_pause, 3, 1) and _dir_at(second_pause, 3, 1) == 0 and not _at(second_pause, 3, 2), "route 91's pause never takes the side step")
	_check(not bool(Sim.run(_by_id(92), _swap(_by_id(92), "primer", "painter"))["success"]), "route 92 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(92), _swap(_by_id(92), "filter", "conveyor"))["success"]), "route 92 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(92), _swap(_by_id(92), "counter", "conveyor"))["success"]), "route 92 fails without the counter")
	var night: Dictionary = Sim.run(_by_id(92), _by_id(92)["reference"])
	_check(str(night["delivered"][0]["color"]) == "red" and int(night["delivered"][0]["count"]) == 1, "route 92 stamps red 1")
	_check(str(night["delivered"][1]["color"]) == "yellow" and int(night["delivered"][1]["count"]) == 2, "route 92 stamps yellow 2")
	_check(str(night["delivered"][2]["color"]) == "blue" and int(night["delivered"][2]["count"]) == 3, "route 92 stamps blue 3")
	_check(_at(_frame(night, 6), 3, 2) and _dir_at(_frame(night, 6), 3, 2) == 0, "route 92 steps red south and leaves it facing east")
	var night_turn := _frame(Sim.run(_by_id(92), _swap(_by_id(92), "shunt", "turn")), 6)
	_check(not night_turn.is_empty() and _at(night_turn, 3, 2) and _dir_at(night_turn, 3, 2) == 1, "route 92's turn steps aside facing south")
	var night_pause := _frame(Sim.run(_by_id(92), _swap(_by_id(92), "shunt", "pause")), 6)
	_check(not night_pause.is_empty() and _at(night_pause, 3, 1) and _dir_at(night_pause, 3, 1) == 0 and not _at(night_pause, 3, 2), "route 92's pause keeps east and does not step aside")
	var night_chute := _frame(Sim.run(_by_id(92), _swap(_by_id(92), "shunt", "chute")), 5)
	_check(not night_chute.is_empty() and _dir_at(night_chute, 3, 1) == 0, "route 92's chute writes its own east facing")


func _bias_rules() -> void:
	print("bias")
	var straight := {
		"width": 4, "height": 3,
		"walls": [
			{"x": 0, "y": 0}, {"x": 1, "y": 0},
			{"x": 3, "y": 1},
			{"x": 0, "y": 2}, {"x": 1, "y": 2}, {"x": 2, "y": 2}, {"x": 3, "y": 2},
		],
		"sources": [{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "gray"}],
	}
	var graph := [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "bias", "x": 2, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
	]
	var sent: Dictionary = Sim.run(straight, graph)
	_check(bool(sent["success"]), "a bias steps aside and the kept facing delivers")
	_check(int(sent["cycles"]) == 6 and int(sent["blocks"]) == 3, "the bias waits a tick and delivers on tick 6")
	var born := _frame(sent, 2)
	var waited := _frame(sent, 3)
	var stepped := _frame(sent, 4)
	_check(not born.is_empty() and _dir_at(born, 2, 1) == 0, "the parcel arrives facing east")
	_check(not waited.is_empty() and _at(waited, 2, 1) and not _at(waited, 2, 0), "the bias does not move the parcel on that tick")
	_check(_dir_at(waited, 2, 1) == 0, "the bias leaves the east facing unchanged")
	_check(_count_at(waited, 2, 1) == 0 and _color_at(waited, 2, 1) == "gray", "a bias does not stamp or paint")
	_check(not stepped.is_empty() and _at(stepped, 2, 0) and _dir_at(stepped, 2, 0) == 0, "the side step goes north and the parcel still faces east")
	var tinted: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "bias", "x": 2, "y": 1, "dir": 0, "color": "red"},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
	])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a bias is ignored")
	var blue_board: Dictionary = straight.duplicate(true)
	blue_board["sources"][0]["parcels"][0]["color"] = "blue"
	blue_board["order"] = [{"color": "blue"}]
	var blue_run: Dictionary = Sim.run(blue_board, graph)
	_check(bool(blue_run["success"]) and _at(_frame(blue_run, 4), 2, 0) and _dir_at(_frame(blue_run, 4), 2, 0) == 0, "a bias does not filter, so blue takes the same side step")
	for dir in range(4):
		var spun: Array = graph.duplicate(true)
		spun[1]["dir"] = dir
		var run: Dictionary = Sim.run(straight, spun)
		_check(bool(run["success"]) and int(run["cycles"]) == 6, "rotating a bias does not change the side step")
	var turned: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "turn", "x": 2, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
	])
	_check(not bool(turned["success"]) and str(turned["reason"]) == "stuck", "a turn in the bias's cell faces south and cannot reach the dock")
	_check(_dir_at(_frame(turned, 3), 2, 1) == 1 and not _at(_frame(turned, 3), 2, 0), "the turn writes south and does not take the north step")
	var hooked: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "hook", "x": 2, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
	])
	_check(not bool(hooked["success"]), "a hook in the bias's cell faces north and the pause misses the dock")
	_check(_dir_at(_frame(hooked, 3), 2, 1) == 3, "the hook writes north before it steps")
	_check(_at(_frame(hooked, 4), 2, 0) and _dir_at(_frame(hooked, 4), 2, 0) == 3, "the hook's step faces the way it moved")
	var kept: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
	])
	_check(not bool(kept["success"]), "a pause in the bias's cell keeps east and never steps north")
	var kept_face := _frame(kept, 3)
	_check(not kept_face.is_empty() and _at(kept_face, 2, 1) and _dir_at(kept_face, 2, 1) == 0 and not _at(kept_face, 2, 0), "the pause is still on the bias cell facing east")
	var aimed: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "chute", "x": 2, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
	])
	_check(not bool(aimed["success"]), "an east chute sends the parcel east and misses the side step")
	var backed: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "return", "x": 2, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
	])
	_check(not bool(backed["success"]) and str(backed["reason"]) == "tick_cap", "a return in the bias's cell misses the dock")
	_check(_dir_at(_frame(backed, 3), 2, 1) == 2, "a return sends the eastbound parcel west")
	_check(_at(_frame(backed, 4), 1, 1) and _dir_at(_frame(backed, 4), 1, 1) == 2, "the return then steps back west")
	var shunted: Dictionary = Sim.run(straight, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "shunt", "x": 2, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
	])
	_check(not bool(shunted["success"]) and str(shunted["reason"]) == "stuck", "a shunt in the bias's cell aims south and misses the dock")
	_check(_at(_frame(shunted, 3), 2, 1) and _dir_at(_frame(shunted, 3), 2, 1) == 0 and not _at(_frame(shunted, 3), 2, 0), "the shunt keeps the east facing and never reaches the north pause")
	var open_south := {
		"width": 4, "height": 3,
		"walls": [
			{"x": 0, "y": 0}, {"x": 1, "y": 0},
			{"x": 3, "y": 1},
			{"x": 0, "y": 2}, {"x": 1, "y": 2}, {"x": 3, "y": 2},
		],
		"sources": [{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "gray"}],
	}
	var open_graph := [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "bias", "x": 2, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
		{"type": "pause", "x": 2, "y": 2, "dir": 0},
	]
	var north_way: Dictionary = Sim.run(open_south, open_graph)
	_check(bool(north_way["success"]) and int(north_way["cycles"]) == 6, "an unused south pause does not change the bias")
	var south_graph: Array = open_graph.duplicate(true)
	south_graph[1]["type"] = "shunt"
	var south_way: Dictionary = Sim.run(open_south, south_graph)
	_check(not bool(south_way["success"]), "a shunt steps south and that pause misses the dock")
	var south_step := _frame(south_way, 4)
	_check(not south_step.is_empty() and _at(south_step, 2, 2) and _dir_at(south_step, 2, 2) == 0, "the shunt's side step goes south and the parcel still faces east")
	var early_board := {
		"width": 4, "height": 3,
		"walls": [
			{"x": 0, "y": 0}, {"x": 1, "y": 0},
			{"x": 0, "y": 2}, {"x": 1, "y": 2}, {"x": 2, "y": 2}, {"x": 3, "y": 2},
		],
		"sources": [{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "gray"}],
	}
	var early_graph := [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "bias", "x": 2, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 3, "y": 1, "dir": 1},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
	]
	var held_side: Dictionary = Sim.run(early_board, early_graph)
	_check(bool(held_side["success"]) and int(held_side["cycles"]) == 6, "an unused east belt does not change the bias")
	_check(_at(_frame(held_side, 3), 2, 1) and not _at(_frame(held_side, 3), 3, 1), "the bias is still waiting on the arrival tick")
	var early: Dictionary = Sim.run(early_board, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 3, "y": 1, "dir": 1},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
	])
	_check(not bool(early["success"]), "an east conveyor leaves on the arrival tick and misses the dock")
	_check(_at(_frame(early, 3), 3, 1), "the conveyor is already east while a bias would still be waiting")

	var lefts := [
		{"name": "east", "src": Vector2i(0, 1), "arrival": 0, "bias": Vector2i(1, 1), "side": Vector2i(1, 0), "dock": Vector2i(2, 0)},
		{"name": "south", "src": Vector2i(1, 0), "arrival": 1, "bias": Vector2i(1, 1), "side": Vector2i(2, 1), "dock": Vector2i(2, 2)},
		{"name": "west", "src": Vector2i(2, 1), "arrival": 2, "bias": Vector2i(1, 1), "side": Vector2i(1, 2), "dock": Vector2i(0, 2)},
		{"name": "north", "src": Vector2i(1, 2), "arrival": 3, "bias": Vector2i(1, 1), "side": Vector2i(0, 1), "dock": Vector2i(0, 0)},
	]
	for spec in lefts:
		var src_at: Vector2i = spec["src"]
		var bias_at: Vector2i = spec["bias"]
		var side_at: Vector2i = spec["side"]
		var dock_at: Vector2i = spec["dock"]
		var arrival := int(spec["arrival"])
		var lane := {
			"width": 3, "height": 3, "walls": [],
			"sources": [{"x": src_at.x, "y": src_at.y, "dir": arrival, "parcels": [{"color": "gray"}]}],
			"dock": {"x": dock_at.x, "y": dock_at.y},
			"order": [{"color": "gray"}],
		}
		var blocks := [
			{"type": "bias", "x": bias_at.x, "y": bias_at.y, "dir": 0},
			{"type": "pause", "x": side_at.x, "y": side_at.y, "dir": 0},
		]
		var run: Dictionary = Sim.run(lane, blocks)
		var moved := _frame(run, 3)
		_check(bool(run["success"]) and int(run["cycles"]) == 5, "a %s parcel steps to its left and the pause follows the old facing" % str(spec["name"]))
		_check(not moved.is_empty() and _at(moved, side_at.x, side_at.y) and _dir_at(moved, side_at.x, side_at.y) == arrival, "a %s parcel still faces %s after the side step" % [str(spec["name"]), str(spec["name"])])

	var hop := {
		"width": 3, "height": 4, "walls": [{"x": 1, "y": 1}],
		"sources": [{"x": 0, "y": 2, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 1, "y": 0},
		"order": [{"color": "gray"}],
	}
	var blocked: Dictionary = Sim.run(hop, [{"type": "bias", "x": 1, "y": 2, "dir": 0}])
	_check(not bool(blocked["success"]), "a bias does not carry a parcel over the next cell")
	var crossed := false
	for frame in blocked["frames"]:
		if _at(frame, 1, 0):
			crossed = true
	_check(not crossed, "the parcel never reaches the cell past a bias")

	var gap := {
		"width": 4, "height": 3, "walls": [],
		"sources": [
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "blue"}, {"color": "gray"}],
	}
	var followed: Dictionary = Sim.run(gap, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "bias", "x": 2, "y": 1, "dir": 0},
		{"type": "pause", "x": 1, "y": 0, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 0, "dir": 0},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 5, "a bias can enter a cell another parcel is leaving")
	var into := _frame(followed, 4)
	_check(not into.is_empty() and _color_at(into, 2, 0) == "gray" and _dir_at(into, 2, 0) == 0, "the bias steps into the cell the other parcel left and still faces east")
	_check(into.get("delivered", []).size() == 1 and str(into["delivered"][0]["color"]) == "blue", "the parcel ahead is delivered on that tick")

	var held_board := {
		"width": 4, "height": 4, "walls": [],
		"sources": [
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 3, "y": 0, "dir": 2, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 3, "y": 1},
		"order": [{"color": "gray"}],
	}
	var waiting: Dictionary = Sim.run(held_board, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "bias", "x": 2, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 0, "dir": 0},
	])
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a bias keeps waiting while its side cell stays blocked")
	var same := _frame(waiting, 3)
	var first_try := _frame(waiting, 4)
	var later := _frame(waiting, 5)
	_check(not same.is_empty() and _at(same, 2, 1) and _dir_at(same, 2, 1) == 0, "the blocked bias still faces east on the wait")
	_check(not first_try.is_empty() and _at(first_try, 2, 1) and _dir_at(first_try, 2, 1) == 0, "the first blocked side step does not change the facing")
	_check(not later.is_empty() and _at(later, 2, 1) and _dir_at(later, 2, 1) == 0 and _color_at(later, 2, 0) == "blue", "the bias keeps the arrival facing while the other parcel stays")


func _building_thirteen() -> void:
	print("building 13")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 99, "building 13 adds routes 93 through 99")
	_check(Puzzles.INTRO.size() >= 17 and Puzzles.INTRO[16] == "bias", "the bias is the block building 13 teaches")
	_check(not Puzzles.unlocked_at(91).has("bias"), "the bias stays locked through route 92")
	_check(Puzzles.unlocked_at(92).has("bias"), "route 93 unlocks the bias")
	_check(Puzzles.unlocked_at(98).size() == 17, "building 13 ends with every block")
	var pars := {
		93: [6, 3],
		94: [8, 10],
		95: [7, 4],
		96: [8, 10],
		97: [18, 16],
		98: [11, 6],
		99: [13, 14],
	}
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id <= 92:
			_check(int(puzzle.get("building", 1)) < 13, "route %d stays out of building 13" % id)
			if id >= 86:
				_check(int(puzzle.get("building", 1)) == 12, "route %d stays in building 12" % id)
			continue
		if id > 99:
			continue
		_check(int(puzzle.get("building", 1)) == 13, "route %d is building 13" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		var locked: Array = pars[id]
		_check(int(par["cycles"]) == int(locked[0]) and int(par["blocks"]) == int(locked[1]), "route %d par is %d cycles and %d blocks" % [id, int(locked[0]), int(locked[1])])
		if id == 93:
			_check(str(puzzle.get("unlocks", "")) == "bias", "route 93 teaches the bias")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_bias := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "bias":
				uses_bias = true
		_check(uses_bias, "route %d reference uses the bias" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	var lesson: Dictionary = Sim.run(_by_id(93), _by_id(93)["reference"])
	_check(not _frame(lesson, 2).is_empty() and _dir_at(_frame(lesson, 2), 2, 1) == 0, "route 93 starts the parcel facing east on the bias")
	_check(_at(_frame(lesson, 3), 2, 1) and _dir_at(_frame(lesson, 3), 2, 1) == 0, "route 93 keeps the parcel facing east without moving it")
	_check(_at(_frame(lesson, 4), 2, 0) and _dir_at(_frame(lesson, 4), 2, 0) == 0, "route 93 steps north and still faces east")
	for id in [93, 94, 95, 96, 97, 98, 99]:
		for dir in range(4):
			var spun: Array = _by_id(id)["reference"].duplicate(true)
			for block in spun:
				if str(block["type"]) == "bias":
					block["dir"] = dir
			var spun_run: Dictionary = Sim.run(_by_id(id), spun)
			_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == int(pars[id][0]), "route %d ignores which way the bias block is rotated" % id)
		for kind in ["shunt", "turn", "pause", "chute", "hook", "return", "conveyor"]:
			var swapped: Dictionary = Sim.run(_by_id(id), _swap(_by_id(id), "bias", kind))
			_check(not bool(swapped["success"]), "route %d fails if the bias is a %s" % [id, kind])
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "bias":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the bias is missing" % id)

	var lesson_hook := _frame(Sim.run(_by_id(93), _swap(_by_id(93), "bias", "hook")), 4)
	_check(not lesson_hook.is_empty() and _at(lesson_hook, 2, 0) and _dir_at(lesson_hook, 2, 0) == 3, "route 93's hook steps north facing north")
	var lesson_turn := _frame(Sim.run(_by_id(93), _swap(_by_id(93), "bias", "turn")), 3)
	_check(not lesson_turn.is_empty() and _at(lesson_turn, 2, 1) and _dir_at(lesson_turn, 2, 1) == 1 and not _at(lesson_turn, 2, 0), "route 93's turn faces south and misses the north pause")
	var let_hook := _frame(Sim.run(_by_id(94), _swap(_by_id(94), "bias", "hook")), 4)
	_check(not let_hook.is_empty() and _at(let_hook, 2, 0) and _dir_at(let_hook, 2, 0) == 3, "route 94's hook steps north facing north")
	_check(str(Sim.run(_by_id(94), _swap(_by_id(94), "bias", "conveyor"))["reason"]) == "wrong_delivery", "route 94's conveyor delivers red before blue")
	_check(str(Sim.run(_by_id(94), _swap(_by_id(94), "bias", "pause"))["reason"]) == "wrong_delivery", "route 94's pause sends red east ahead of blue")
	var counted: Dictionary = Sim.run(_by_id(95), _by_id(95)["reference"])
	_check(int(counted["delivered"][0]["count"]) == 1, "route 95 delivers count 1")
	_check(_at(_frame(counted, 4), 2, 0) and _dir_at(_frame(counted, 4), 2, 0) == 0, "route 95 lands facing east, not along the side step")
	var count_hook := _frame(Sim.run(_by_id(95), _swap(_by_id(95), "bias", "hook")), 4)
	_check(not count_hook.is_empty() and _at(count_hook, 2, 0) and _dir_at(count_hook, 2, 0) == 3, "route 95's hook reaches the side cell facing north")
	var count_turn := _frame(Sim.run(_by_id(95), _swap(_by_id(95), "bias", "turn")), 3)
	_check(not count_turn.is_empty() and _at(count_turn, 2, 1) and _dir_at(count_turn, 2, 1) == 1 and not _at(count_turn, 2, 0), "route 95's turn faces south and misses the side cell")
	_check(not bool(Sim.run(_by_id(95), _swap(_by_id(95), "counter", "conveyor"))["success"]), "route 95 fails without the counter")
	var clear_hook := _frame(Sim.run(_by_id(96), _swap(_by_id(96), "bias", "hook")), 4)
	_check(not clear_hook.is_empty() and _at(clear_hook, 2, 0) and _dir_at(clear_hook, 2, 0) == 3, "route 96's hook steps aside facing north")
	_check(str(Sim.run(_by_id(96), _swap(_by_id(96), "bias", "pause"))["reason"]) == "wrong_delivery", "route 96's pause does not step aside")
	var paired: Dictionary = Sim.run(_by_id(97), _by_id(97)["reference"])
	_check(_at(_frame(paired, 4), 2, 0) and _dir_at(_frame(paired, 4), 2, 0) == 0, "route 97 steps red north and leaves it facing east")
	_check(_at(_frame(paired, 6), 2, 2) and _dir_at(_frame(paired, 6), 2, 2) == 2, "route 97 steps blue south and leaves it facing west")
	var both_shunt: Dictionary = Sim.run(_by_id(97), _swap(_by_id(97), "bias", "shunt"))
	_check(_at(_frame(both_shunt, 4), 2, 2) and _dir_at(_frame(both_shunt, 4), 2, 2) == 0, "route 97's shunt steps red south and leaves it facing east")
	_check(_at(_frame(both_shunt, 6), 2, 0) and _dir_at(_frame(both_shunt, 6), 2, 0) == 2, "route 97's shunt steps blue north and leaves it facing west")
	var both_hook: Dictionary = Sim.run(_by_id(97), _swap(_by_id(97), "bias", "hook"))
	_check(_dir_at(_frame(both_hook, 3), 2, 1) == 3, "route 97 hooks red a quarter counterclockwise")
	_check(_dir_at(_frame(both_hook, 5), 2, 1) == 1, "route 97 hooks blue a quarter counterclockwise")
	var both_turn: Dictionary = Sim.run(_by_id(97), _swap(_by_id(97), "bias", "turn"))
	_check(_dir_at(_frame(both_turn, 3), 2, 1) == 1, "route 97 turns red a quarter clockwise")
	_check(_dir_at(_frame(both_turn, 5), 2, 1) == 3, "route 97 turns blue a quarter clockwise")
	var both_chute := _frame(Sim.run(_by_id(97), _swap(_by_id(97), "bias", "chute")), 5)
	_check(not both_chute.is_empty() and _at(both_chute, 2, 1) and _dir_at(both_chute, 2, 1) == 0, "route 97's chute writes east onto the westbound parcel")
	var both_pause := _frame(Sim.run(_by_id(97), _swap(_by_id(97), "bias", "pause")), 4)
	_check(not both_pause.is_empty() and _at(both_pause, 3, 1) and _dir_at(both_pause, 3, 1) == 0, "route 97's pause sends red east along its arrival")
	_check(not bool(Sim.run(_by_id(98), _swap(_by_id(98), "painter", "conveyor"))["success"]), "route 98 fails if the parcel is not painted")
	_check(not bool(Sim.run(_by_id(98), _swap(_by_id(98), "counter", "conveyor"))["success"]), "route 98 fails without the second stamp")
	_check(not bool(Sim.run(_by_id(98), _swap(_by_id(98), "splitter", "conveyor"))["success"]), "route 98 loops if the splitter cannot send the second pass east")
	var second: Dictionary = Sim.run(_by_id(98), _by_id(98)["reference"])
	_check(str(second["delivered"][0]["color"]) == "yellow" and int(second["delivered"][0]["count"]) == 2, "route 98 delivers yellow 2")
	_check(_at(_frame(second, 9), 3, 0) and _dir_at(_frame(second, 9), 3, 0) == 0, "route 98 steps north and still faces east")
	var second_hook := _frame(Sim.run(_by_id(98), _swap(_by_id(98), "bias", "hook")), 9)
	_check(not second_hook.is_empty() and _at(second_hook, 3, 0) and _dir_at(second_hook, 3, 0) == 3, "route 98's hook reaches the side cell facing north")
	var second_pause := _frame(Sim.run(_by_id(98), _swap(_by_id(98), "bias", "pause")), 8)
	_check(not second_pause.is_empty() and _at(second_pause, 3, 1) and _dir_at(second_pause, 3, 1) == 0 and not _at(second_pause, 3, 0), "route 98's pause never takes the side step")
	_check(not bool(Sim.run(_by_id(99), _swap(_by_id(99), "primer", "painter"))["success"]), "route 99 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(99), _swap(_by_id(99), "filter", "conveyor"))["success"]), "route 99 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(99), _swap(_by_id(99), "counter", "conveyor"))["success"]), "route 99 fails without the counter")
	var night: Dictionary = Sim.run(_by_id(99), _by_id(99)["reference"])
	_check(str(night["delivered"][0]["color"]) == "red" and int(night["delivered"][0]["count"]) == 1, "route 99 stamps red 1")
	_check(str(night["delivered"][1]["color"]) == "yellow" and int(night["delivered"][1]["count"]) == 2, "route 99 stamps yellow 2")
	_check(str(night["delivered"][2]["color"]) == "blue" and int(night["delivered"][2]["count"]) == 3, "route 99 stamps blue 3")
	_check(_at(_frame(night, 6), 2, 0) and _dir_at(_frame(night, 6), 2, 0) == 0, "route 99 steps red north and leaves it facing east")
	var night_shunt := _frame(Sim.run(_by_id(99), _swap(_by_id(99), "bias", "shunt")), 6)
	_check(not night_shunt.is_empty() and _at(night_shunt, 2, 2) and _dir_at(night_shunt, 2, 2) == 0, "route 99's shunt steps red south and leaves it facing east")
	var night_turn := _frame(Sim.run(_by_id(99), _swap(_by_id(99), "bias", "turn")), 6)
	_check(not night_turn.is_empty() and _at(night_turn, 2, 2) and _dir_at(night_turn, 2, 2) == 1, "route 99's turn steps south facing south")
	var night_pause := _frame(Sim.run(_by_id(99), _swap(_by_id(99), "bias", "pause")), 6)
	_check(not night_pause.is_empty() and _at(night_pause, 2, 1) and _dir_at(night_pause, 2, 1) == 0 and not _at(night_pause, 2, 0), "route 99's pause keeps east and does not step aside")
	var night_chute := _frame(Sim.run(_by_id(99), _swap(_by_id(99), "bias", "chute")), 5)
	_check(not night_chute.is_empty() and _dir_at(night_chute, 2, 1) == 0, "route 99's chute writes its own east facing")


func _vault_rules() -> void:
	print("vault")
	var hop := {
		"width": 4, "height": 1, "walls": [],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "gray"}],
	}
	var graph := [{"type": "vault", "x": 1, "y": 0, "dir": 0}]
	var sent: Dictionary = Sim.run(hop, graph)
	_check(bool(sent["success"]), "a vault jumps two cells and the kept facing delivers")
	_check(int(sent["cycles"]) == 3 and int(sent["blocks"]) == 1, "the vault waits a tick and delivers on tick 3")
	var born := _frame(sent, 1)
	var waited := _frame(sent, 2)
	_check(not born.is_empty() and _at(born, 1, 0) and _dir_at(born, 1, 0) == 0, "the parcel arrives facing east")
	_check(not waited.is_empty() and _at(waited, 1, 0) and _dir_at(waited, 1, 0) == 0 and not _at(waited, 3, 0), "the vault does not move the parcel on that tick")
	_check(_count_at(waited, 1, 0) == 0 and _color_at(waited, 1, 0) == "gray", "a vault does not stamp or paint")
	var crossed := false
	for frame in sent["frames"]:
		if _at(frame, 2, 0):
			crossed = true
	_check(not crossed, "the vault does not enter the cell immediately ahead")
	var tinted: Dictionary = Sim.run(hop, [{"type": "vault", "x": 1, "y": 0, "dir": 0, "color": "red"}])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a vault is ignored")
	var blue_board: Dictionary = hop.duplicate(true)
	blue_board["sources"][0]["parcels"][0]["color"] = "blue"
	blue_board["order"] = [{"color": "blue"}]
	var blue_run: Dictionary = Sim.run(blue_board, graph)
	_check(bool(blue_run["success"]) and int(blue_run["cycles"]) == 3, "a vault does not filter, so blue takes the same jump")
	for dir in range(4):
		var spun: Array = graph.duplicate(true)
		spun[0]["dir"] = dir
		var run: Dictionary = Sim.run(hop, spun)
		_check(bool(run["success"]) and int(run["cycles"]) == 3, "rotating a vault does not change the jump")
	var paused: Dictionary = Sim.run(hop, [{"type": "pause", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(paused["success"]) and str(paused["reason"]) == "stuck", "a pause in the vault's cell steps one cell and never reaches the dock")
	_check(_at(_frame(paused, 2), 1, 0) and _dir_at(_frame(paused, 2), 1, 0) == 0, "the pause is still on the vault cell facing east")
	var biased: Dictionary = Sim.run(hop, [{"type": "bias", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(biased["success"]) and str(biased["reason"]) == "stuck", "a bias steps north and misses the two-cell jump")
	var shunted: Dictionary = Sim.run(hop, [{"type": "shunt", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(shunted["success"]) and str(shunted["reason"]) == "stuck", "a shunt steps south and misses the two-cell jump")
	var early: Dictionary = Sim.run(hop, [{"type": "conveyor", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(early["success"]) and str(early["reason"]) == "stuck", "a conveyor leaves on the arrival tick and misses the dock")

	var lane := {
		"width": 6, "height": 3,
		"walls": [{"x": 3, "y": 0}, {"x": 3, "y": 2}],
		"sources": [{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 5, "y": 1},
		"order": [{"color": "gray"}],
	}
	var lane_graph := [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "vault", "x": 2, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 3, "y": 1, "dir": 1},
		{"type": "pause", "x": 4, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
		{"type": "pause", "x": 2, "y": 2, "dir": 0},
	]
	var held: Dictionary = Sim.run(lane, lane_graph)
	_check(bool(held["success"]) and int(held["cycles"]) == 6, "the vault jumps the belt between and the pause follows east")
	_check(_at(_frame(held, 3), 2, 1) and _dir_at(_frame(held, 3), 2, 1) == 0 and not _at(_frame(held, 3), 3, 1), "the vault is still waiting on the arrival tick")
	_check(_at(_frame(held, 4), 4, 1) and _dir_at(_frame(held, 4), 4, 1) == 0 and not _at(_frame(held, 4), 3, 1), "the jump lands two cells east and still faces east")
	var lane_pause: Dictionary = Sim.run(lane, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 3, "y": 1, "dir": 1},
		{"type": "pause", "x": 4, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
		{"type": "pause", "x": 2, "y": 2, "dir": 0},
	])
	_check(not bool(lane_pause["success"]), "a pause steps one cell onto the belt between and misses the far pause")
	var one := _frame(lane_pause, 4)
	_check(not one.is_empty() and _at(one, 3, 1) and _dir_at(one, 3, 1) == 0 and not _at(one, 4, 1), "the pause is one cell east, still facing east")
	var lane_belt: Dictionary = Sim.run(lane, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 3, "y": 1, "dir": 1},
		{"type": "pause", "x": 4, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
		{"type": "pause", "x": 2, "y": 2, "dir": 0},
	])
	_check(not bool(lane_belt["success"]), "a conveyor leaves on the arrival tick and misses the jump")
	_check(_at(_frame(lane_belt, 3), 3, 1), "the conveyor is already one cell east while a vault would still be waiting")
	var lane_bias: Dictionary = Sim.run(lane, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "bias", "x": 2, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 3, "y": 1, "dir": 1},
		{"type": "pause", "x": 4, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
		{"type": "pause", "x": 2, "y": 2, "dir": 0},
	])
	_check(not bool(lane_bias["success"]), "a bias steps north and misses the dock")
	var north := _frame(lane_bias, 4)
	_check(not north.is_empty() and _at(north, 2, 0) and _dir_at(north, 2, 0) == 0, "the bias steps north and the parcel still faces east")
	var lane_shunt: Dictionary = Sim.run(lane, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "shunt", "x": 2, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 3, "y": 1, "dir": 1},
		{"type": "pause", "x": 4, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
		{"type": "pause", "x": 2, "y": 2, "dir": 0},
	])
	_check(not bool(lane_shunt["success"]), "a shunt steps south and misses the dock")
	var south := _frame(lane_shunt, 4)
	_check(not south.is_empty() and _at(south, 2, 2) and _dir_at(south, 2, 2) == 0, "the shunt steps south and the parcel still faces east")
	var turned: Dictionary = Sim.run(lane, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "turn", "x": 2, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 3, "y": 1, "dir": 1},
		{"type": "pause", "x": 4, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
		{"type": "pause", "x": 2, "y": 2, "dir": 0},
	])
	_check(not bool(turned["success"]), "a turn faces south and does not jump two cells")
	_check(_dir_at(_frame(turned, 3), 2, 1) == 1, "the turn writes south before it steps")
	var hooked: Dictionary = Sim.run(lane, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "hook", "x": 2, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 3, "y": 1, "dir": 1},
		{"type": "pause", "x": 4, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
		{"type": "pause", "x": 2, "y": 2, "dir": 0},
	])
	_check(not bool(hooked["success"]), "a hook faces north and does not jump two cells")
	_check(_dir_at(_frame(hooked, 3), 2, 1) == 3, "the hook writes north before it steps")
	var aimed: Dictionary = Sim.run(lane, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "chute", "x": 2, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 3, "y": 1, "dir": 1},
		{"type": "pause", "x": 4, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
		{"type": "pause", "x": 2, "y": 2, "dir": 0},
	])
	_check(not bool(aimed["success"]), "an east chute sends the parcel one cell east")
	_check(_at(_frame(aimed, 4), 3, 1) and _dir_at(_frame(aimed, 4), 3, 1) == 0 and not _at(_frame(aimed, 4), 4, 1), "the chute lands on the cell between and still faces east")
	var backed: Dictionary = Sim.run(lane, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "return", "x": 2, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 3, "y": 1, "dir": 1},
		{"type": "pause", "x": 4, "y": 1, "dir": 0},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
		{"type": "pause", "x": 2, "y": 2, "dir": 0},
	])
	_check(not bool(backed["success"]) and str(backed["reason"]) == "tick_cap", "a return in the vault's cell misses the dock")
	_check(_dir_at(_frame(backed, 3), 2, 1) == 2, "a return sends the eastbound parcel west")

	var jumps := [
		{"name": "east", "src": Vector2i(0, 0), "arrival": 0, "vault": Vector2i(1, 0), "land": Vector2i(3, 0), "dock": Vector2i(4, 0), "size": Vector2i(5, 1)},
		{"name": "south", "src": Vector2i(0, 0), "arrival": 1, "vault": Vector2i(0, 1), "land": Vector2i(0, 3), "dock": Vector2i(0, 4), "size": Vector2i(1, 5)},
		{"name": "west", "src": Vector2i(4, 0), "arrival": 2, "vault": Vector2i(3, 0), "land": Vector2i(1, 0), "dock": Vector2i(0, 0), "size": Vector2i(5, 1)},
		{"name": "north", "src": Vector2i(0, 4), "arrival": 3, "vault": Vector2i(0, 3), "land": Vector2i(0, 1), "dock": Vector2i(0, 0), "size": Vector2i(1, 5)},
	]
	for spec in jumps:
		var src_at: Vector2i = spec["src"]
		var vault_at: Vector2i = spec["vault"]
		var land_at: Vector2i = spec["land"]
		var dock_at: Vector2i = spec["dock"]
		var size_at: Vector2i = spec["size"]
		var arrival := int(spec["arrival"])
		var strip := {
			"width": size_at.x, "height": size_at.y, "walls": [],
			"sources": [{"x": src_at.x, "y": src_at.y, "dir": arrival, "parcels": [{"color": "gray"}]}],
			"dock": {"x": dock_at.x, "y": dock_at.y},
			"order": [{"color": "gray"}],
		}
		var blocks := [
			{"type": "vault", "x": vault_at.x, "y": vault_at.y, "dir": 0},
			{"type": "pause", "x": land_at.x, "y": land_at.y, "dir": 0},
		]
		var run: Dictionary = Sim.run(strip, blocks)
		var moved := _frame(run, 3)
		_check(bool(run["success"]) and int(run["cycles"]) == 5, "a %s parcel jumps two cells and the pause follows the old facing" % str(spec["name"]))
		_check(not moved.is_empty() and _at(moved, land_at.x, land_at.y) and _dir_at(moved, land_at.x, land_at.y) == arrival, "a %s parcel still faces %s after the jump" % [str(spec["name"]), str(spec["name"])])

	var rider := {
		"width": 4, "height": 2, "walls": [],
		"sources": [
			{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 2, "y": 1, "dir": 3, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "gray"}],
	}
	var over: Dictionary = Sim.run(rider, [{"type": "vault", "x": 1, "y": 0, "dir": 0}])
	_check(bool(over["success"]) and int(over["cycles"]) == 3, "a parcel in the cell ahead does not block the jump")
	_check(_color_at(_frame(over, 2), 2, 0) == "blue" and _color_at(_frame(over, 2), 1, 0) == "gray", "the vault waits while the other parcel sits in front")
	var hopped := false
	for frame in over["frames"]:
		if _color_at(frame, 2, 0) == "gray":
			hopped = true
	_check(not hopped and _color_at(_frame(over, 3), 2, 0) == "blue", "the jump does not enter that cell and does not move the parcel sitting there")

	var gap := {
		"width": 6, "height": 2, "walls": [],
		"sources": [
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 2, "y": 0, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 5, "y": 1},
		"order": [{"color": "blue"}, {"color": "gray"}],
	}
	var followed: Dictionary = Sim.run(gap, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "vault", "x": 2, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 3, "y": 0, "dir": 0},
		{"type": "conveyor", "x": 4, "y": 0, "dir": 1},
		{"type": "conveyor", "x": 4, "y": 1, "dir": 0},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 5, "a vault can land in a cell another parcel is leaving")
	var into := _frame(followed, 4)
	_check(not into.is_empty() and _color_at(into, 4, 1) == "gray" and _dir_at(into, 4, 1) == 0, "the jump lands in the cell the other parcel left and still faces east")
	_check(into.get("delivered", []).size() == 1 and str(into["delivered"][0]["color"]) == "blue", "the parcel ahead is delivered on that tick")

	var held_board := {
		"width": 5, "height": 2, "walls": [],
		"sources": [
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 4, "y": 0, "dir": 1, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 0, "y": 0},
		"order": [{"color": "gray"}],
	}
	var waiting: Dictionary = Sim.run(held_board, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "vault", "x": 2, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 4, "y": 1, "dir": 0},
	])
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a vault keeps waiting while its landing stays blocked")
	var same := _frame(waiting, 3)
	var first_try := _frame(waiting, 4)
	var later := _frame(waiting, 5)
	_check(not same.is_empty() and _at(same, 2, 1) and _dir_at(same, 2, 1) == 0, "the blocked vault still faces east on the wait")
	_check(not first_try.is_empty() and _at(first_try, 2, 1) and _dir_at(first_try, 2, 1) == 0, "the first blocked jump does not change the facing")
	_check(not later.is_empty() and _at(later, 2, 1) and _dir_at(later, 2, 1) == 0 and _color_at(later, 4, 1) == "blue", "the vault keeps the arrival facing while the other parcel stays")

	var outside := {
		"width": 3, "height": 1, "walls": [],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 2, "y": 0},
		"order": [{"color": "gray"}],
	}
	var missed: Dictionary = Sim.run(outside, [{"type": "vault", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(missed["success"]) and str(missed["reason"]) == "stuck", "a vault does not jump out of bounds, even over the dock")
	_check(_at(_frame(missed, 2), 1, 0) and _dir_at(_frame(missed, 2), 1, 0) == 0, "the out-of-bounds jump leaves the parcel facing east")
	var floor := {
		"width": 4, "height": 1, "walls": [],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 2, "y": 0},
		"order": [{"color": "gray"}],
	}
	var bare: Dictionary = Sim.run(floor, [{"type": "vault", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(bare["success"]) and str(bare["reason"]) == "stuck", "a vault does not land on empty floor")
	_check(_at(_frame(bare, 2), 1, 0) and _dir_at(_frame(bare, 2), 1, 0) == 0 and not _at(_frame(bare, 2), 2, 0), "the empty landing leaves the parcel on the vault, still facing east")


func _building_fourteen() -> void:
	print("building 14")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 106, "building 14 adds routes 100 through 106")
	_check(Puzzles.INTRO.size() >= 18 and Puzzles.INTRO[17] == "vault", "the vault is the block building 14 teaches")
	_check(not Puzzles.unlocked_at(98).has("vault"), "the vault stays locked through route 99")
	_check(Puzzles.unlocked_at(99).has("vault"), "route 100 unlocks the vault")
	_check(Puzzles.unlocked_at(105).size() == 18, "building 14 ends with every block")
	var pars := {
		100: [6, 3],
		101: [8, 12],
		102: [6, 4],
		103: [8, 11],
		104: [19, 19],
		105: [11, 6],
		106: [12, 11],
	}
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id <= 99:
			_check(int(puzzle.get("building", 1)) < 14, "route %d stays out of building 14" % id)
			if id >= 93:
				_check(int(puzzle.get("building", 1)) == 13, "route %d stays in building 13" % id)
			continue
		if id > 106:
			continue
		_check(int(puzzle.get("building", 1)) == 14, "route %d is building 14" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		var locked: Array = pars[id]
		_check(int(par["cycles"]) == int(locked[0]) and int(par["blocks"]) == int(locked[1]), "route %d par is %d cycles and %d blocks" % [id, int(locked[0]), int(locked[1])])
		if id == 100:
			_check(str(puzzle.get("unlocks", "")) == "vault", "route 100 teaches the vault")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_vault := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "vault":
				uses_vault = true
		_check(uses_vault, "route %d reference uses the vault" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	for id in [100, 101, 102, 103, 104, 105, 106]:
		for dir in range(4):
			var spun: Array = _by_id(id)["reference"].duplicate(true)
			for block in spun:
				if str(block["type"]) == "vault":
					block["dir"] = dir
			var spun_run: Dictionary = Sim.run(_by_id(id), spun)
			_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == int(pars[id][0]), "route %d ignores which way the vault block is rotated" % id)
		for kind in ["bias", "shunt", "turn", "pause", "chute", "hook", "return", "conveyor"]:
			var swapped: Dictionary = Sim.run(_by_id(id), _swap(_by_id(id), "vault", kind))
			_check(not bool(swapped["success"]), "route %d fails if the vault is a %s" % [id, kind])
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "vault":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the vault is missing" % id)

	var lesson: Dictionary = Sim.run(_by_id(100), _by_id(100)["reference"])
	_check(_at(_frame(lesson, 2), 2, 1) and _dir_at(_frame(lesson, 2), 2, 1) == 0, "route 100 starts the parcel facing east on the vault")
	_check(_at(_frame(lesson, 3), 2, 1) and _dir_at(_frame(lesson, 3), 2, 1) == 0 and not _at(_frame(lesson, 3), 4, 1), "route 100 keeps the parcel facing east without moving it")
	_check(_at(_frame(lesson, 4), 4, 1) and _dir_at(_frame(lesson, 4), 4, 1) == 0, "route 100 jumps two cells east and still faces east")
	var stepped_between := false
	for frame in lesson["frames"]:
		if _at(frame, 3, 1):
			stepped_between = true
	_check(not stepped_between, "route 100 never enters the cell between the vault and the pause")
	var lesson_pause := _frame(Sim.run(_by_id(100), _swap(_by_id(100), "vault", "pause")), 3)
	_check(not lesson_pause.is_empty() and _at(lesson_pause, 2, 1) and _dir_at(lesson_pause, 2, 1) == 0 and not _at(lesson_pause, 4, 1), "route 100's pause never reaches the far pause")
	var let_long: Dictionary = Sim.run(_by_id(101), _by_id(101)["reference"])
	_check(_color_at(_frame(let_long, 3), 2, 1) == "red" and _dir_at(_frame(let_long, 3), 2, 1) == 0, "route 101 holds red facing east")
	_check(_color_at(_frame(let_long, 4), 4, 1) == "red" and _dir_at(_frame(let_long, 4), 4, 1) == 0, "route 101 jumps red two cells east and still faces east")
	_check(_frame(let_long, 7).get("delivered", []).size() == 1 and str(_frame(let_long, 7)["delivered"][0]["color"]) == "blue", "route 101 lets blue take the dock first")
	_check(str(Sim.run(_by_id(101), _swap(_by_id(101), "vault", "conveyor"))["reason"]) == "wrong_delivery", "route 101's conveyor lets red leave on the arrival tick")
	_check(str(Sim.run(_by_id(101), _swap(_by_id(101), "vault", "pause"))["reason"]) == "wrong_delivery", "route 101's pause steps one cell and red arrives first")
	var counted: Dictionary = Sim.run(_by_id(102), _by_id(102)["reference"])
	_check(int(counted["delivered"][0]["count"]) == 1, "route 102 delivers count 1")
	_check(_at(_frame(counted, 3), 3, 1) and _dir_at(_frame(counted, 3), 3, 1) == 0 and not _at(_frame(counted, 3), 2, 1), "route 102 jumps onto the pause facing east")
	var count_pause := _frame(Sim.run(_by_id(102), _swap(_by_id(102), "vault", "pause")), 3)
	_check(not count_pause.is_empty() and _at(count_pause, 2, 1) and _dir_at(count_pause, 2, 1) == 0 and not _at(count_pause, 4, 1), "route 102's pause lands on the cell between and misses the counter")
	var count_chute := _frame(Sim.run(_by_id(102), _swap(_by_id(102), "vault", "chute")), 3)
	_check(not count_chute.is_empty() and _at(count_chute, 2, 1) and _dir_at(count_chute, 2, 1) == 0, "route 102's east chute sends the parcel one cell east")
	var clear: Dictionary = Sim.run(_by_id(103), _by_id(103)["reference"])
	_check(_color_at(_frame(clear, 4), 4, 1) == "red" and _dir_at(_frame(clear, 4), 4, 1) == 0, "route 103 jumps red east and leaves it facing east")
	_check(_color_at(_frame(clear, 5), 3, 1) == "blue" and _color_at(_frame(clear, 5), 4, 1) == "red", "route 103 jumps red over the cell blue is using")
	var red_on_gap := false
	for frame in clear["frames"]:
		if _color_at(frame, 3, 1) == "red":
			red_on_gap = true
	_check(not red_on_gap, "route 103's red never enters the cell it jumps")
	_check(str(Sim.run(_by_id(103), _swap(_by_id(103), "vault", "pause"))["reason"]) == "wrong_delivery", "route 103's pause does not jump, so red arrives before blue")
	var paired: Dictionary = Sim.run(_by_id(104), _by_id(104)["reference"])
	_check(_color_at(_frame(paired, 5), 6, 2) == "red" and _dir_at(_frame(paired, 5), 6, 2) == 0, "route 104 jumps red east and leaves it facing east")
	_check(_color_at(_frame(paired, 7), 2, 2) == "blue" and _dir_at(_frame(paired, 7), 2, 2) == 2, "route 104 jumps blue west and leaves it facing west")
	var both_pause := _frame(Sim.run(_by_id(104), _swap(_by_id(104), "vault", "pause")), 5)
	_check(not both_pause.is_empty() and _color_at(both_pause, 5, 2) == "red" and _dir_at(both_pause, 5, 2) == 0, "route 104's pause sends red one cell along its arrival")
	var both_chute := _frame(Sim.run(_by_id(104), _swap(_by_id(104), "vault", "chute")), 6)
	_check(not both_chute.is_empty() and _color_at(both_chute, 4, 2) == "blue" and _dir_at(both_chute, 4, 2) == 0, "route 104's chute writes east onto the westbound parcel")
	var second: Dictionary = Sim.run(_by_id(105), _by_id(105)["reference"])
	_check(str(second["delivered"][0]["color"]) == "yellow" and int(second["delivered"][0]["count"]) == 2, "route 105 delivers yellow 2")
	_check(_at(_frame(second, 8), 3, 1) and _dir_at(_frame(second, 8), 3, 1) == 0, "route 105 waits on the vault facing east")
	_check(_at(_frame(second, 9), 5, 1) and _dir_at(_frame(second, 9), 5, 1) == 0, "route 105 jumps two cells east and still faces east")
	var second_pause := _frame(Sim.run(_by_id(105), _swap(_by_id(105), "vault", "pause")), 8)
	_check(not second_pause.is_empty() and _at(second_pause, 3, 1) and _dir_at(second_pause, 3, 1) == 0 and not _at(second_pause, 5, 1), "route 105's pause never jumps far enough")
	_check(not bool(Sim.run(_by_id(105), _swap(_by_id(105), "painter", "conveyor"))["success"]), "route 105 fails if the parcel is not painted")
	_check(not bool(Sim.run(_by_id(105), _swap(_by_id(105), "counter", "conveyor"))["success"]), "route 105 fails without the second stamp")
	_check(not bool(Sim.run(_by_id(105), _swap(_by_id(105), "splitter", "conveyor"))["success"]), "route 105 loops if the splitter cannot send the second pass east")
	var night: Dictionary = Sim.run(_by_id(106), _by_id(106)["reference"])
	_check(str(night["delivered"][0]["color"]) == "red" and int(night["delivered"][0]["count"]) == 1, "route 106 stamps red 1")
	_check(str(night["delivered"][1]["color"]) == "yellow" and int(night["delivered"][1]["count"]) == 2, "route 106 stamps yellow 2")
	_check(str(night["delivered"][2]["color"]) == "blue" and int(night["delivered"][2]["count"]) == 3, "route 106 stamps blue 3")
	_check(_color_at(_frame(night, 5), 2, 1) == "red" and _dir_at(_frame(night, 5), 2, 1) == 0, "route 106 holds red facing east")
	_check(_color_at(_frame(night, 6), 4, 1) == "red" and _dir_at(_frame(night, 6), 4, 1) == 0, "route 106 jumps red onto the counter and leaves it facing east")
	var night_pause := _frame(Sim.run(_by_id(106), _swap(_by_id(106), "vault", "pause")), 6)
	_check(not night_pause.is_empty() and _color_at(night_pause, 2, 1) == "red" and _dir_at(night_pause, 2, 1) == 0 and _color_at(night_pause, 4, 1) != "red", "route 106's pause keeps east and does not reach the counter")
	var night_chute := _frame(Sim.run(_by_id(106), _swap(_by_id(106), "vault", "chute")), 5)
	_check(not night_chute.is_empty() and _dir_at(night_chute, 2, 1) == 0, "route 106's chute writes its own east facing")
	_check(not bool(Sim.run(_by_id(106), _swap(_by_id(106), "primer", "painter"))["success"]), "route 106 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(106), _swap(_by_id(106), "filter", "conveyor"))["success"]), "route 106 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(106), _swap(_by_id(106), "counter", "conveyor"))["success"]), "route 106 fails without the counter")


func _sling_rules() -> void:
	print("sling")
	var hop := {
		"width": 3, "height": 3, "walls": [],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 1, "y": 2},
		"order": [{"color": "gray"}],
	}
	var graph := [{"type": "sling", "x": 1, "y": 0, "dir": 0}]
	var sent: Dictionary = Sim.run(hop, graph)
	_check(bool(sent["success"]), "a sling jumps two cells to the right and the kept facing delivers")
	_check(int(sent["cycles"]) == 3 and int(sent["blocks"]) == 1, "the sling waits a tick and delivers on tick 3")
	var born := _frame(sent, 1)
	var waited := _frame(sent, 2)
	_check(not born.is_empty() and _at(born, 1, 0) and _dir_at(born, 1, 0) == 0, "the parcel arrives facing east")
	_check(not waited.is_empty() and _at(waited, 1, 0) and _dir_at(waited, 1, 0) == 0 and not _at(waited, 1, 2), "the sling does not move the parcel on that tick")
	_check(_count_at(waited, 1, 0) == 0 and _color_at(waited, 1, 0) == "gray", "a sling does not stamp or paint")
	var crossed := false
	for frame in sent["frames"]:
		if _at(frame, 1, 1):
			crossed = true
	_check(not crossed, "the sling does not enter the cell immediately to the right")
	var tinted: Dictionary = Sim.run(hop, [{"type": "sling", "x": 1, "y": 0, "dir": 0, "color": "red"}])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a sling is ignored")
	var blue_board: Dictionary = hop.duplicate(true)
	blue_board["sources"][0]["parcels"][0]["color"] = "blue"
	blue_board["order"] = [{"color": "blue"}]
	var blue_run: Dictionary = Sim.run(blue_board, graph)
	_check(bool(blue_run["success"]) and int(blue_run["cycles"]) == 3, "a sling does not filter, so blue takes the same jump")
	for dir in range(4):
		var spun: Array = graph.duplicate(true)
		spun[0]["dir"] = dir
		var run: Dictionary = Sim.run(hop, spun)
		_check(bool(run["success"]) and int(run["cycles"]) == 3, "rotating a sling does not change the jump")
	var shunted: Dictionary = Sim.run(hop, [{"type": "shunt", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(shunted["success"]) and str(shunted["reason"]) == "stuck", "a shunt steps one cell to the right and never reaches the dock")
	var vaulted: Dictionary = Sim.run(hop, [{"type": "vault", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(vaulted["success"]) and str(vaulted["reason"]) == "stuck", "a vault jumps two cells east and misses the side jump")
	var biased: Dictionary = Sim.run(hop, [{"type": "bias", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(biased["success"]) and str(biased["reason"]) == "stuck", "a bias steps north and misses the side jump")
	var paused: Dictionary = Sim.run(hop, [{"type": "pause", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(paused["success"]) and str(paused["reason"]) == "stuck", "a pause steps one cell east and never reaches the dock")
	_check(_at(_frame(paused, 2), 1, 0) and _dir_at(_frame(paused, 2), 1, 0) == 0, "the pause is still on the sling cell facing east")
	var slid: Dictionary = Sim.run(hop, [{"type": "slide", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(slid["success"]) and str(slid["reason"]) == "stuck", "a slide jumps forward on the arrival tick and misses the side")
	var bridged: Dictionary = Sim.run(hop, [{"type": "bridge", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(bridged["success"]) and str(bridged["reason"]) == "stuck", "a bridge jumps along its arrow and misses the side")
	var early: Dictionary = Sim.run(hop, [{"type": "conveyor", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(early["success"]) and str(early["reason"]) == "stuck", "a conveyor leaves on the arrival tick and misses the dock")

	var jumps := [
		{"name": "east", "src": Vector2i(0, 0), "arrival": 0, "sling": Vector2i(1, 0), "skip": Vector2i(1, 1), "land": Vector2i(1, 2), "dock": Vector2i(2, 2), "size": Vector2i(3, 3)},
		{"name": "south", "src": Vector2i(2, 0), "arrival": 1, "sling": Vector2i(2, 1), "skip": Vector2i(1, 1), "land": Vector2i(0, 1), "dock": Vector2i(0, 2), "size": Vector2i(3, 3)},
		{"name": "west", "src": Vector2i(2, 2), "arrival": 2, "sling": Vector2i(1, 2), "skip": Vector2i(1, 1), "land": Vector2i(1, 0), "dock": Vector2i(0, 0), "size": Vector2i(3, 3)},
		{"name": "north", "src": Vector2i(0, 2), "arrival": 3, "sling": Vector2i(0, 1), "skip": Vector2i(1, 1), "land": Vector2i(2, 1), "dock": Vector2i(2, 0), "size": Vector2i(3, 3)},
	]
	for spec in jumps:
		var src_at: Vector2i = spec["src"]
		var sling_at: Vector2i = spec["sling"]
		var skip_at: Vector2i = spec["skip"]
		var land_at: Vector2i = spec["land"]
		var dock_at: Vector2i = spec["dock"]
		var size_at: Vector2i = spec["size"]
		var arrival := int(spec["arrival"])
		var strip := {
			"width": size_at.x, "height": size_at.y, "walls": [],
			"sources": [{"x": src_at.x, "y": src_at.y, "dir": arrival, "parcels": [{"color": "gray"}]}],
			"dock": {"x": dock_at.x, "y": dock_at.y},
			"order": [{"color": "gray"}],
		}
		var blocks := [
			{"type": "sling", "x": sling_at.x, "y": sling_at.y, "dir": 0},
			{"type": "pause", "x": land_at.x, "y": land_at.y, "dir": 0},
		]
		var run: Dictionary = Sim.run(strip, blocks)
		var moved := _frame(run, 3)
		var entered := false
		for frame in run["frames"]:
			if _at(frame, skip_at.x, skip_at.y):
				entered = true
		_check(bool(run["success"]) and int(run["cycles"]) == 5, "a %s parcel jumps two cells to its right and the pause follows the old facing" % str(spec["name"]))
		_check(not moved.is_empty() and _at(moved, land_at.x, land_at.y) and _dir_at(moved, land_at.x, land_at.y) == arrival, "a %s parcel still faces %s after the jump" % [str(spec["name"]), str(spec["name"])])
		_check(not entered, "a %s sling does not enter the cell immediately to its right" % str(spec["name"]))

	var rider := {
		"width": 3, "height": 3, "walls": [],
		"sources": [
			{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 1, "y": 2},
		"order": [{"color": "gray"}],
	}
	var over: Dictionary = Sim.run(rider, [{"type": "sling", "x": 1, "y": 0, "dir": 0}])
	_check(bool(over["success"]) and int(over["cycles"]) == 3, "a parcel in the cell to the right does not block the jump")
	_check(_color_at(_frame(over, 2), 1, 1) == "blue" and _color_at(_frame(over, 2), 1, 0) == "gray", "the sling waits while the other parcel sits to the right")
	var hopped := false
	for frame in over["frames"]:
		if _color_at(frame, 1, 1) == "gray":
			hopped = true
	_check(not hopped and _color_at(_frame(over, 3), 1, 1) == "blue", "the jump does not enter that cell and does not move the parcel sitting there")

	var gap := {
		"width": 4, "height": 4, "walls": [],
		"sources": [
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 0, "y": 3, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 3, "y": 3},
		"order": [{"color": "blue"}, {"color": "gray"}],
	}
	var followed: Dictionary = Sim.run(gap, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "sling", "x": 2, "y": 1, "dir": 0},
		{"type": "pause", "x": 1, "y": 3, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 3, "dir": 0},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 5, "a sling can land in a cell another parcel is leaving")
	var into := _frame(followed, 4)
	_check(not into.is_empty() and _color_at(into, 2, 3) == "gray" and _dir_at(into, 2, 3) == 0, "the jump lands in the cell the other parcel left and still faces east")
	_check(into.get("delivered", []).size() == 1 and str(into["delivered"][0]["color"]) == "blue", "the parcel ahead is delivered on that tick")

	var held_board := {
		"width": 3, "height": 4, "walls": [],
		"sources": [
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 2, "y": 2, "dir": 1, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 0, "y": 0},
		"order": [{"color": "gray"}],
	}
	var waiting: Dictionary = Sim.run(held_board, [
		{"type": "conveyor", "x": 1, "y": 1, "dir": 0},
		{"type": "sling", "x": 2, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 3, "dir": 1},
	])
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a sling keeps waiting while its landing stays blocked")
	var same := _frame(waiting, 3)
	var first_try := _frame(waiting, 4)
	var later := _frame(waiting, 5)
	_check(not same.is_empty() and _at(same, 2, 1) and _dir_at(same, 2, 1) == 0, "the blocked sling still faces east on the wait")
	_check(not first_try.is_empty() and _at(first_try, 2, 1) and _dir_at(first_try, 2, 1) == 0, "the first blocked jump does not change the facing")
	_check(not later.is_empty() and _at(later, 2, 1) and _dir_at(later, 2, 1) == 0 and _color_at(later, 2, 3) == "blue", "the sling keeps the arrival facing while the other parcel stays")

	var outside := {
		"width": 3, "height": 2, "walls": [],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 2, "y": 0},
		"order": [{"color": "gray"}],
	}
	var missed: Dictionary = Sim.run(outside, [{"type": "sling", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(missed["success"]) and str(missed["reason"]) == "stuck", "a sling does not jump out of bounds")
	_check(_at(_frame(missed, 2), 1, 0) and _dir_at(_frame(missed, 2), 1, 0) == 0, "the out-of-bounds jump leaves the parcel facing east")
	var floor := {
		"width": 3, "height": 3, "walls": [],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 2, "y": 0},
		"order": [{"color": "gray"}],
	}
	var bare: Dictionary = Sim.run(floor, [{"type": "sling", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(bare["success"]) and str(bare["reason"]) == "stuck", "a sling does not land on empty floor")
	_check(_at(_frame(bare, 2), 1, 0) and _dir_at(_frame(bare, 2), 1, 0) == 0 and not _at(_frame(bare, 2), 1, 1), "the empty landing leaves the parcel on the sling, still facing east")


func _building_fifteen() -> void:
	print("building 15")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 113, "building 15 adds routes 107 through 113")
	_check(Puzzles.INTRO.size() >= 19 and Puzzles.INTRO[18] == "sling", "the sling is the block building 15 teaches")
	_check(not Puzzles.unlocked_at(105).has("sling"), "the sling stays locked through route 106")
	_check(Puzzles.unlocked_at(106).has("sling"), "route 107 unlocks the sling")
	_check(Puzzles.unlocked_at(112).size() == 19, "building 15 ends with every block")
	var pars := {
		107: [6, 3],
		108: [9, 15],
		109: [7, 5],
		110: [6, 3],
		111: [16, 12],
		112: [11, 6],
		113: [14, 13],
	}
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id <= 106:
			_check(int(puzzle.get("building", 1)) < 15, "route %d stays out of building 15" % id)
			if id >= 100:
				_check(int(puzzle.get("building", 1)) == 14, "route %d stays in building 14" % id)
			continue
		if id > 113:
			continue
		_check(int(puzzle.get("building", 1)) == 15, "route %d is building 15" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		var locked: Array = pars[id]
		_check(int(par["cycles"]) == int(locked[0]) and int(par["blocks"]) == int(locked[1]), "route %d par is %d cycles and %d blocks" % [id, int(locked[0]), int(locked[1])])
		if id == 107:
			_check(str(puzzle.get("unlocks", "")) == "sling", "route 107 teaches the sling")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_sling := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "sling":
				uses_sling = true
		_check(uses_sling, "route %d reference uses the sling" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	for id in [107, 108, 109, 110, 111, 112, 113]:
		for dir in range(4):
			var spun: Array = _by_id(id)["reference"].duplicate(true)
			for block in spun:
				if str(block["type"]) == "sling":
					block["dir"] = dir
			var spun_run: Dictionary = Sim.run(_by_id(id), spun)
			_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == int(pars[id][0]), "route %d ignores which way the sling block is rotated" % id)
		for kind in ["vault", "shunt", "bias", "pause", "slide", "bridge", "turn", "chute", "hook", "return", "conveyor"]:
			var swapped: Dictionary = Sim.run(_by_id(id), _swap(_by_id(id), "sling", kind))
			_check(not bool(swapped["success"]), "route %d fails if the sling is a %s" % [id, kind])
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "sling":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the sling is missing" % id)

	var lesson: Dictionary = Sim.run(_by_id(107), _by_id(107)["reference"])
	_check(_at(_frame(lesson, 2), 2, 1) and _dir_at(_frame(lesson, 2), 2, 1) == 0, "route 107 starts the parcel facing east on the sling")
	_check(_at(_frame(lesson, 3), 2, 1) and _dir_at(_frame(lesson, 3), 2, 1) == 0 and not _at(_frame(lesson, 3), 2, 3), "route 107 keeps the parcel facing east without moving it")
	_check(_at(_frame(lesson, 4), 2, 3) and _dir_at(_frame(lesson, 4), 2, 3) == 0, "route 107 jumps two cells south and still faces east")
	var stepped_side := false
	var side_block := false
	for frame in lesson["frames"]:
		if _at(frame, 2, 2):
			stepped_side = true
	for block in _by_id(107)["reference"]:
		if int(block["x"]) == 2 and int(block["y"]) == 2:
			side_block = true
	for wall in _by_id(107)["walls"]:
		if int(wall["x"]) == 2 and int(wall["y"]) == 2:
			side_block = true
	_check(not side_block, "route 107 leaves the cell to the right empty of blocks")
	_check(not stepped_side, "route 107 never enters the cell immediately to the right")
	var lesson_shunt := _frame(Sim.run(_by_id(107), _swap(_by_id(107), "sling", "shunt")), 3)
	_check(not lesson_shunt.is_empty() and _at(lesson_shunt, 2, 1) and _dir_at(lesson_shunt, 2, 1) == 0 and not _at(lesson_shunt, 2, 3), "route 107's shunt never reaches the pause")
	var let_sling: Dictionary = Sim.run(_by_id(108), _by_id(108)["reference"])
	_check(_color_at(_frame(let_sling, 3), 2, 1) == "red" and _dir_at(_frame(let_sling, 3), 2, 1) == 0, "route 108 holds red facing east")
	_check(_color_at(_frame(let_sling, 4), 2, 3) == "red" and _dir_at(_frame(let_sling, 4), 2, 3) == 0, "route 108 jumps red two cells to its right and still faces east")
	_check(_frame(let_sling, 8).get("delivered", []).size() == 1 and str(_frame(let_sling, 8)["delivered"][0]["color"]) == "blue", "route 108 lets blue take the dock first")
	_check(str(Sim.run(_by_id(108), _swap(_by_id(108), "sling", "slide"))["reason"]) == "wrong_delivery", "route 108's slide leaves on the arrival tick and red arrives first")
	_check(str(Sim.run(_by_id(108), _swap(_by_id(108), "sling", "bridge"))["reason"]) == "wrong_delivery", "route 108's bridge leaves on the arrival tick and red arrives first")
	var counted: Dictionary = Sim.run(_by_id(109), _by_id(109)["reference"])
	_check(int(counted["delivered"][0]["count"]) == 1, "route 109 delivers count 1")
	_check(_at(_frame(counted, 4), 2, 3) and _dir_at(_frame(counted, 4), 2, 3) == 0 and not _at(_frame(counted, 4), 2, 2), "route 109 jumps onto the pause facing east")
	var count_shunt := _frame(Sim.run(_by_id(109), _swap(_by_id(109), "sling", "shunt")), 4)
	_check(not count_shunt.is_empty() and _at(count_shunt, 2, 2) and _dir_at(count_shunt, 2, 2) == 0 and not _at(count_shunt, 2, 3), "route 109's shunt lands one cell short and misses the counter")
	var clear: Dictionary = Sim.run(_by_id(110), _by_id(110)["reference"])
	_check(_color_at(_frame(clear, 4), 2, 3) == "gray" and _dir_at(_frame(clear, 4), 2, 3) == 0 and _color_at(_frame(clear, 4), 2, 2) == "blue", "route 110 jumps over the parcel sitting to the right")
	var blue_moved := false
	var gray_crossed := false
	for frame in clear["frames"]:
		if _color_at(frame, 2, 2) == "gray":
			gray_crossed = true
		if int(frame["tick"]) >= 1 and _color_at(frame, 2, 2) != "blue":
			blue_moved = true
	_check(not blue_moved and not gray_crossed, "route 110's sitting parcel does not move and the jump does not enter its cell")
	var clear_shunt := _frame(Sim.run(_by_id(110), _swap(_by_id(110), "sling", "shunt")), 4)
	_check(not clear_shunt.is_empty() and _color_at(clear_shunt, 2, 1) == "gray" and _color_at(clear_shunt, 2, 2) == "blue" and not _at(clear_shunt, 2, 3), "route 110's shunt cannot enter the occupied cell")
	var paired: Dictionary = Sim.run(_by_id(111), _by_id(111)["reference"])
	_check(_color_at(_frame(paired, 3), 3, 4) == "red" and _dir_at(_frame(paired, 3), 3, 4) == 0, "route 111 jumps red south and leaves it facing east")
	_check(_color_at(_frame(paired, 4), 3, 2) == "blue" and _dir_at(_frame(paired, 4), 3, 2) == 2, "route 111 holds blue facing west")
	_check(_color_at(_frame(paired, 5), 3, 0) == "blue" and _dir_at(_frame(paired, 5), 3, 0) == 2, "route 111 jumps blue north and leaves it facing west")
	var both_shunt := _frame(Sim.run(_by_id(111), _swap(_by_id(111), "sling", "shunt")), 2)
	_check(not both_shunt.is_empty() and _color_at(both_shunt, 3, 2) == "red" and not _at(both_shunt, 3, 4), "route 111's shunt does not send red two cells south")
	var both_chute := _frame(Sim.run(_by_id(111), _swap(_by_id(111), "sling", "chute")), 2)
	_check(not both_chute.is_empty() and _color_at(both_chute, 3, 2) == "red" and _dir_at(both_chute, 3, 2) == 0, "route 111's chute writes east onto the eastbound parcel")
	var second: Dictionary = Sim.run(_by_id(112), _by_id(112)["reference"])
	_check(str(second["delivered"][0]["color"]) == "yellow" and int(second["delivered"][0]["count"]) == 2, "route 112 delivers yellow 2")
	_check(_at(_frame(second, 8), 3, 1) and _dir_at(_frame(second, 8), 3, 1) == 0 and _count_at(_frame(second, 8), 3, 1) == 2, "route 112 waits on the sling facing east")
	_check(_at(_frame(second, 9), 3, 3) and _dir_at(_frame(second, 9), 3, 3) == 0, "route 112 jumps two cells south and still faces east")
	var second_shunt: Dictionary = Sim.run(_by_id(112), _swap(_by_id(112), "sling", "shunt"))
	var shunt_landed := false
	for frame in second_shunt["frames"]:
		if _at(frame, 3, 3):
			shunt_landed = true
	_check(not bool(second_shunt["success"]) and _at(_frame(second_shunt, 8), 3, 1) and not shunt_landed, "route 112's shunt is one cell short")
	var second_pause: Dictionary = Sim.run(_by_id(112), _swap(_by_id(112), "sling", "pause"))
	var pause_landed := false
	for frame in second_pause["frames"]:
		if _at(frame, 3, 3):
			pause_landed = true
	_check(not bool(second_pause["success"]) and _at(_frame(second_pause, 8), 3, 1) and _dir_at(_frame(second_pause, 8), 3, 1) == 0 and not pause_landed, "route 112's pause never jumps far enough")
	_check(not bool(Sim.run(_by_id(112), _swap(_by_id(112), "painter", "conveyor"))["success"]), "route 112 fails if the parcel is not painted")
	_check(not bool(Sim.run(_by_id(112), _swap(_by_id(112), "counter", "conveyor"))["success"]), "route 112 fails without the second stamp")
	_check(not bool(Sim.run(_by_id(112), _swap(_by_id(112), "splitter", "conveyor"))["success"]), "route 112 loops if the splitter cannot send the second pass east")
	var night: Dictionary = Sim.run(_by_id(113), _by_id(113)["reference"])
	_check(str(night["delivered"][0]["color"]) == "red" and int(night["delivered"][0]["count"]) == 1, "route 113 stamps red 1")
	_check(str(night["delivered"][1]["color"]) == "yellow" and int(night["delivered"][1]["count"]) == 2, "route 113 stamps yellow 2")
	_check(str(night["delivered"][2]["color"]) == "blue" and int(night["delivered"][2]["count"]) == 3, "route 113 stamps blue 3")
	_check(_color_at(_frame(night, 5), 2, 1) == "red" and _dir_at(_frame(night, 5), 2, 1) == 0, "route 113 holds red facing east")
	_check(_color_at(_frame(night, 6), 2, 3) == "red" and _dir_at(_frame(night, 6), 2, 3) == 0, "route 113 jumps red onto the counter and leaves it facing east")
	var night_shunt := _frame(Sim.run(_by_id(113), _swap(_by_id(113), "sling", "shunt")), 6)
	_check(not night_shunt.is_empty() and _color_at(night_shunt, 2, 1) == "red" and _color_at(night_shunt, 2, 3) != "red", "route 113's shunt is one cell short of the counter")
	var night_pause := _frame(Sim.run(_by_id(113), _swap(_by_id(113), "sling", "pause")), 6)
	_check(not night_pause.is_empty() and _color_at(night_pause, 2, 1) == "red" and _dir_at(night_pause, 2, 1) == 0 and _color_at(night_pause, 2, 3) != "red", "route 113's pause keeps east and only steps one cell")
	var night_chute := _frame(Sim.run(_by_id(113), _swap(_by_id(113), "sling", "chute")), 5)
	_check(not night_chute.is_empty() and _dir_at(night_chute, 2, 1) == 0, "route 113's chute writes its own east facing")
	_check(not bool(Sim.run(_by_id(113), _swap(_by_id(113), "primer", "painter"))["success"]), "route 113 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(113), _swap(_by_id(113), "filter", "conveyor"))["success"]), "route 113 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(113), _swap(_by_id(113), "counter", "conveyor"))["success"]), "route 113 fails without the counter")


func _cant_rules() -> void:
	print("cant")
	var hop := {
		"width": 3, "height": 3, "walls": [],
		"sources": [{"x": 0, "y": 2, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 1, "y": 0},
		"order": [{"color": "gray"}],
	}
	var graph := [{"type": "cant", "x": 1, "y": 2, "dir": 0}]
	var sent: Dictionary = Sim.run(hop, graph)
	_check(bool(sent["success"]), "a cant jumps two cells to the left and the kept facing delivers")
	_check(int(sent["cycles"]) == 3 and int(sent["blocks"]) == 1, "the cant waits a tick and delivers on tick 3")
	var born := _frame(sent, 1)
	var waited := _frame(sent, 2)
	_check(not born.is_empty() and _at(born, 1, 2) and _dir_at(born, 1, 2) == 0, "the parcel arrives facing east")
	_check(not waited.is_empty() and _at(waited, 1, 2) and _dir_at(waited, 1, 2) == 0 and not _at(waited, 1, 0), "the cant does not move the parcel on that tick")
	_check(_count_at(waited, 1, 2) == 0 and _color_at(waited, 1, 2) == "gray", "a cant does not stamp or paint")
	var crossed := false
	for frame in sent["frames"]:
		if _at(frame, 1, 1):
			crossed = true
	_check(not crossed, "the cant does not enter the cell immediately to the left")
	var tinted: Dictionary = Sim.run(hop, [{"type": "cant", "x": 1, "y": 2, "dir": 0, "color": "red"}])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a cant is ignored")
	var blue_board: Dictionary = hop.duplicate(true)
	blue_board["sources"][0]["parcels"][0]["color"] = "blue"
	blue_board["order"] = [{"color": "blue"}]
	var blue_run: Dictionary = Sim.run(blue_board, graph)
	_check(bool(blue_run["success"]) and int(blue_run["cycles"]) == 3, "a cant does not filter, so blue takes the same jump")
	for dir in range(4):
		var spun: Array = graph.duplicate(true)
		spun[0]["dir"] = dir
		var run: Dictionary = Sim.run(hop, spun)
		_check(bool(run["success"]) and int(run["cycles"]) == 3, "rotating a cant does not change the jump")
	var biased: Dictionary = Sim.run(hop, [{"type": "bias", "x": 1, "y": 2, "dir": 0}])
	_check(not bool(biased["success"]) and str(biased["reason"]) == "stuck", "a bias steps one cell to the left and never reaches the dock")
	var slung: Dictionary = Sim.run(hop, [{"type": "sling", "x": 1, "y": 2, "dir": 0}])
	_check(not bool(slung["success"]) and str(slung["reason"]) == "stuck", "a sling jumps two cells to the right and misses the side jump")
	var vaulted: Dictionary = Sim.run(hop, [{"type": "vault", "x": 1, "y": 2, "dir": 0}])
	_check(not bool(vaulted["success"]) and str(vaulted["reason"]) == "stuck", "a vault jumps two cells east and misses the side jump")
	var shunted: Dictionary = Sim.run(hop, [{"type": "shunt", "x": 1, "y": 2, "dir": 0}])
	_check(not bool(shunted["success"]) and str(shunted["reason"]) == "stuck", "a shunt steps south and misses the side jump")
	var paused: Dictionary = Sim.run(hop, [{"type": "pause", "x": 1, "y": 2, "dir": 0}])
	_check(not bool(paused["success"]) and str(paused["reason"]) == "stuck", "a pause steps one cell east and never reaches the dock")
	_check(_at(_frame(paused, 2), 1, 2) and _dir_at(_frame(paused, 2), 1, 2) == 0, "the pause is still on the cant cell facing east")
	var slid: Dictionary = Sim.run(hop, [{"type": "slide", "x": 1, "y": 2, "dir": 0}])
	_check(not bool(slid["success"]) and str(slid["reason"]) == "stuck", "a slide jumps forward on the arrival tick and misses the side")
	var bridged: Dictionary = Sim.run(hop, [{"type": "bridge", "x": 1, "y": 2, "dir": 0}])
	_check(not bool(bridged["success"]) and str(bridged["reason"]) == "stuck", "a bridge jumps along its arrow and misses the side")
	var early: Dictionary = Sim.run(hop, [{"type": "conveyor", "x": 1, "y": 2, "dir": 0}])
	_check(not bool(early["success"]) and str(early["reason"]) == "stuck", "a conveyor leaves on the arrival tick and misses the dock")

	var jumps := [
		{"name": "east", "src": Vector2i(0, 2), "arrival": 0, "cant": Vector2i(1, 2), "skip": Vector2i(1, 1), "land": Vector2i(1, 0), "dock": Vector2i(2, 0), "size": Vector2i(3, 3)},
		{"name": "south", "src": Vector2i(0, 0), "arrival": 1, "cant": Vector2i(0, 1), "skip": Vector2i(1, 1), "land": Vector2i(2, 1), "dock": Vector2i(2, 2), "size": Vector2i(3, 3)},
		{"name": "west", "src": Vector2i(2, 0), "arrival": 2, "cant": Vector2i(1, 0), "skip": Vector2i(1, 1), "land": Vector2i(1, 2), "dock": Vector2i(0, 2), "size": Vector2i(3, 3)},
		{"name": "north", "src": Vector2i(2, 2), "arrival": 3, "cant": Vector2i(2, 1), "skip": Vector2i(1, 1), "land": Vector2i(0, 1), "dock": Vector2i(0, 0), "size": Vector2i(3, 3)},
	]
	for spec in jumps:
		var src_at: Vector2i = spec["src"]
		var cant_at: Vector2i = spec["cant"]
		var skip_at: Vector2i = spec["skip"]
		var land_at: Vector2i = spec["land"]
		var dock_at: Vector2i = spec["dock"]
		var size_at: Vector2i = spec["size"]
		var arrival := int(spec["arrival"])
		var strip := {
			"width": size_at.x, "height": size_at.y, "walls": [],
			"sources": [{"x": src_at.x, "y": src_at.y, "dir": arrival, "parcels": [{"color": "gray"}]}],
			"dock": {"x": dock_at.x, "y": dock_at.y},
			"order": [{"color": "gray"}],
		}
		var blocks := [
			{"type": "cant", "x": cant_at.x, "y": cant_at.y, "dir": 0},
			{"type": "pause", "x": land_at.x, "y": land_at.y, "dir": 0},
		]
		var run: Dictionary = Sim.run(strip, blocks)
		var moved := _frame(run, 3)
		var entered := false
		for frame in run["frames"]:
			if _at(frame, skip_at.x, skip_at.y):
				entered = true
		_check(bool(run["success"]) and int(run["cycles"]) == 5, "a %s parcel jumps two cells to its left and the pause follows the old facing" % str(spec["name"]))
		_check(not moved.is_empty() and _at(moved, land_at.x, land_at.y) and _dir_at(moved, land_at.x, land_at.y) == arrival, "a %s parcel still faces %s after the jump" % [str(spec["name"]), str(spec["name"])])
		_check(not entered, "a %s cant does not enter the cell immediately to its left" % str(spec["name"]))

	var rider := {
		"width": 3, "height": 3, "walls": [],
		"sources": [
			{"x": 0, "y": 2, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 1, "y": 0},
		"order": [{"color": "gray"}],
	}
	var over: Dictionary = Sim.run(rider, [{"type": "cant", "x": 1, "y": 2, "dir": 0}])
	_check(bool(over["success"]) and int(over["cycles"]) == 3, "a parcel in the cell to the left does not block the jump")
	_check(_color_at(_frame(over, 2), 1, 1) == "blue" and _color_at(_frame(over, 2), 1, 2) == "gray", "the cant waits while the other parcel sits to the left")
	var hopped := false
	for frame in over["frames"]:
		if _color_at(frame, 1, 1) == "gray":
			hopped = true
	_check(not hopped and _color_at(_frame(over, 3), 1, 1) == "blue", "the jump does not enter that cell and does not move the parcel sitting there")

	var gap := {
		"width": 4, "height": 4, "walls": [],
		"sources": [
			{"x": 0, "y": 2, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "blue"}, {"color": "gray"}],
	}
	var followed: Dictionary = Sim.run(gap, [
		{"type": "conveyor", "x": 1, "y": 2, "dir": 0},
		{"type": "cant", "x": 2, "y": 2, "dir": 0},
		{"type": "pause", "x": 1, "y": 0, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 0, "dir": 0},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 5, "a cant can land in a cell another parcel is leaving")
	var into := _frame(followed, 4)
	_check(not into.is_empty() and _color_at(into, 2, 0) == "gray" and _dir_at(into, 2, 0) == 0, "the jump lands in the cell the other parcel left and still faces east")
	_check(into.get("delivered", []).size() == 1 and str(into["delivered"][0]["color"]) == "blue", "the parcel ahead is delivered on that tick")

	var held_board := {
		"width": 3, "height": 4, "walls": [],
		"sources": [
			{"x": 0, "y": 2, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 2, "y": 1, "dir": 3, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 0, "y": 3},
		"order": [{"color": "gray"}],
	}
	var waiting: Dictionary = Sim.run(held_board, [
		{"type": "conveyor", "x": 1, "y": 2, "dir": 0},
		{"type": "cant", "x": 2, "y": 2, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 0, "dir": 3},
	])
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a cant keeps waiting while its landing stays blocked")
	var same := _frame(waiting, 3)
	var first_try := _frame(waiting, 4)
	var later := _frame(waiting, 5)
	_check(not same.is_empty() and _at(same, 2, 2) and _dir_at(same, 2, 2) == 0, "the blocked cant still faces east on the wait")
	_check(not first_try.is_empty() and _at(first_try, 2, 2) and _dir_at(first_try, 2, 2) == 0, "the first blocked jump does not change the facing")
	_check(not later.is_empty() and _at(later, 2, 2) and _dir_at(later, 2, 2) == 0 and _color_at(later, 2, 0) == "blue", "the cant keeps the arrival facing while the other parcel stays")

	var outside := {
		"width": 3, "height": 2, "walls": [],
		"sources": [{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 2, "y": 1},
		"order": [{"color": "gray"}],
	}
	var missed: Dictionary = Sim.run(outside, [{"type": "cant", "x": 1, "y": 1, "dir": 0}])
	_check(not bool(missed["success"]) and str(missed["reason"]) == "stuck", "a cant does not jump out of bounds")
	_check(_at(_frame(missed, 2), 1, 1) and _dir_at(_frame(missed, 2), 1, 1) == 0, "the out-of-bounds jump leaves the parcel facing east")
	var floor := {
		"width": 3, "height": 3, "walls": [],
		"sources": [{"x": 0, "y": 2, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 2, "y": 2},
		"order": [{"color": "gray"}],
	}
	var bare: Dictionary = Sim.run(floor, [{"type": "cant", "x": 1, "y": 2, "dir": 0}])
	_check(not bool(bare["success"]) and str(bare["reason"]) == "stuck", "a cant does not land on empty floor")
	_check(_at(_frame(bare, 2), 1, 2) and _dir_at(_frame(bare, 2), 1, 2) == 0 and not _at(_frame(bare, 2), 1, 1), "the empty landing leaves the parcel on the cant, still facing east")


func _building_sixteen() -> void:
	print("building 16")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 120, "building 16 adds routes 114 through 120")
	_check(int(puzzles[112]["id"]) == 113, "route 113 is the last route before the cant")
	_check(int(puzzles[113]["id"]) == 114, "the cant begins at route 114")
	_check(Puzzles.INTRO.size() >= 20 and Puzzles.INTRO[19] == "cant", "the cant is the block building 16 teaches")
	_check(not Puzzles.unlocked_at(112).has("cant"), "the cant stays locked through route 113")
	_check(Puzzles.unlocked_at(113).has("cant"), "route 114 unlocks the cant")
	_check(Puzzles.unlocked_at(119).size() == 20, "building 16 ends with every block")
	var pars := {
		114: [6, 3],
		115: [9, 15],
		116: [7, 5],
		117: [6, 3],
		118: [16, 12],
		119: [11, 6],
		120: [15, 14],
	}
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id <= 113:
			_check(int(puzzle.get("building", 1)) < 16, "route %d stays out of building 16" % id)
			if id >= 107:
				_check(int(puzzle.get("building", 1)) == 15, "route %d stays in building 15" % id)
			continue
		if id > 120:
			continue
		_check(int(puzzle.get("building", 1)) == 16, "route %d is building 16" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		var locked: Array = pars[id]
		_check(int(par["cycles"]) == int(locked[0]) and int(par["blocks"]) == int(locked[1]), "route %d par is %d cycles and %d blocks" % [id, int(locked[0]), int(locked[1])])
		if id == 114:
			_check(str(puzzle.get("unlocks", "")) == "cant", "route 114 teaches the cant")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_cant := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "cant":
				uses_cant = true
		_check(uses_cant, "route %d reference uses the cant" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	for id in [114, 115, 116, 117, 118, 119, 120]:
		for dir in range(4):
			var spun: Array = _by_id(id)["reference"].duplicate(true)
			for block in spun:
				if str(block["type"]) == "cant":
					block["dir"] = dir
			var spun_run: Dictionary = Sim.run(_by_id(id), spun)
			_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == int(pars[id][0]), "route %d ignores which way the cant block is rotated" % id)
		for kind in ["sling", "bias", "vault", "shunt", "pause", "slide", "bridge", "turn", "chute", "hook", "return", "conveyor"]:
			var swapped: Dictionary = Sim.run(_by_id(id), _swap(_by_id(id), "cant", kind))
			_check(not bool(swapped["success"]), "route %d fails if the cant is a %s" % [id, kind])
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "cant":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the cant is missing" % id)

	var lesson: Dictionary = Sim.run(_by_id(114), _by_id(114)["reference"])
	_check(_at(_frame(lesson, 2), 2, 2) and _dir_at(_frame(lesson, 2), 2, 2) == 0, "route 114 starts the parcel facing east on the cant")
	_check(_at(_frame(lesson, 3), 2, 2) and _dir_at(_frame(lesson, 3), 2, 2) == 0 and not _at(_frame(lesson, 3), 2, 0), "route 114 keeps the parcel facing east without moving it")
	_check(_at(_frame(lesson, 4), 2, 0) and _dir_at(_frame(lesson, 4), 2, 0) == 0, "route 114 jumps two cells north and still faces east")
	var stepped_side := false
	var side_block := false
	for frame in lesson["frames"]:
		if _at(frame, 2, 1):
			stepped_side = true
	for block in _by_id(114)["reference"]:
		if int(block["x"]) == 2 and int(block["y"]) == 1:
			side_block = true
	for wall in _by_id(114)["walls"]:
		if int(wall["x"]) == 2 and int(wall["y"]) == 1:
			side_block = true
	_check(not side_block, "route 114 leaves the cell to the left empty of blocks")
	_check(not stepped_side, "route 114 never enters the cell immediately to the left")
	var lesson_bias_run: Dictionary = Sim.run(_by_id(114), _swap(_by_id(114), "cant", "bias"))
	var lesson_bias := _frame(lesson_bias_run, 3)
	_check(str(lesson_bias_run["reason"]) == "stuck" and not lesson_bias.is_empty() and _at(lesson_bias, 2, 2) and _dir_at(lesson_bias, 2, 2) == 0 and not _at(lesson_bias, 2, 0), "route 114's bias never reaches the pause")
	var lesson_sling_run: Dictionary = Sim.run(_by_id(114), _swap(_by_id(114), "cant", "sling"))
	var lesson_sling := _frame(lesson_sling_run, 3)
	_check(str(lesson_sling_run["reason"]) == "stuck" and not lesson_sling.is_empty() and _at(lesson_sling, 2, 2) and not _at(lesson_sling, 2, 0), "route 114's sling jumps the other way and never reaches the pause")
	var let_cant: Dictionary = Sim.run(_by_id(115), _by_id(115)["reference"])
	_check(_color_at(_frame(let_cant, 3), 2, 4) == "red" and _dir_at(_frame(let_cant, 3), 2, 4) == 0, "route 115 holds red facing east")
	_check(_color_at(_frame(let_cant, 4), 2, 2) == "red" and _dir_at(_frame(let_cant, 4), 2, 2) == 0, "route 115 jumps red two cells to its left and still faces east")
	_check(_frame(let_cant, 8).get("delivered", []).size() == 1 and str(_frame(let_cant, 8)["delivered"][0]["color"]) == "blue", "route 115 lets blue take the dock first")
	_check(str(Sim.run(_by_id(115), _swap(_by_id(115), "cant", "slide"))["reason"]) == "wrong_delivery", "route 115's slide leaves on the arrival tick and red arrives first")
	_check(str(Sim.run(_by_id(115), _swap(_by_id(115), "cant", "bridge"))["reason"]) == "wrong_delivery", "route 115's bridge leaves on the arrival tick and red arrives first")
	var counted: Dictionary = Sim.run(_by_id(116), _by_id(116)["reference"])
	_check(int(counted["delivered"][0]["count"]) == 1, "route 116 delivers count 1")
	_check(_at(_frame(counted, 4), 2, 0) and _dir_at(_frame(counted, 4), 2, 0) == 0 and not _at(_frame(counted, 4), 2, 1), "route 116 jumps onto the pause facing east")
	var count_bias := _frame(Sim.run(_by_id(116), _swap(_by_id(116), "cant", "bias")), 4)
	_check(not count_bias.is_empty() and _at(count_bias, 2, 1) and _dir_at(count_bias, 2, 1) == 0 and not _at(count_bias, 2, 0), "route 116's bias lands one cell short and misses the counter")
	var clear: Dictionary = Sim.run(_by_id(117), _by_id(117)["reference"])
	_check(_color_at(_frame(clear, 4), 2, 0) == "gray" and _dir_at(_frame(clear, 4), 2, 0) == 0 and _color_at(_frame(clear, 4), 2, 1) == "blue", "route 117 jumps over the parcel sitting to the left")
	var blue_moved := false
	var gray_crossed := false
	for frame in clear["frames"]:
		if _color_at(frame, 2, 1) == "gray":
			gray_crossed = true
		if int(frame["tick"]) >= 1 and _color_at(frame, 2, 1) != "blue":
			blue_moved = true
	_check(not blue_moved and not gray_crossed, "route 117's sitting parcel does not move and the jump does not enter its cell")
	var clear_bias := _frame(Sim.run(_by_id(117), _swap(_by_id(117), "cant", "bias")), 4)
	_check(not clear_bias.is_empty() and _color_at(clear_bias, 2, 2) == "gray" and _color_at(clear_bias, 2, 1) == "blue" and not _at(clear_bias, 2, 0), "route 117's bias cannot enter the occupied cell")
	var paired: Dictionary = Sim.run(_by_id(118), _by_id(118)["reference"])
	_check(_color_at(_frame(paired, 3), 3, 0) == "red" and _dir_at(_frame(paired, 3), 3, 0) == 0, "route 118 jumps red north and leaves it facing east")
	_check(_color_at(_frame(paired, 4), 3, 2) == "blue" and _dir_at(_frame(paired, 4), 3, 2) == 2, "route 118 holds blue facing west")
	_check(_color_at(_frame(paired, 5), 3, 4) == "blue" and _dir_at(_frame(paired, 5), 3, 4) == 2, "route 118 jumps blue south and leaves it facing west")
	var both_bias := _frame(Sim.run(_by_id(118), _swap(_by_id(118), "cant", "bias")), 3)
	_check(not both_bias.is_empty() and _color_at(both_bias, 3, 2) == "red" and not _at(both_bias, 3, 0), "route 118's bias does not send red two cells north")
	var both_chute := _frame(Sim.run(_by_id(118), _swap(_by_id(118), "cant", "chute")), 2)
	_check(not both_chute.is_empty() and _color_at(both_chute, 3, 2) == "red" and _dir_at(both_chute, 3, 2) == 0, "route 118's chute writes east onto the eastbound parcel")
	var second: Dictionary = Sim.run(_by_id(119), _by_id(119)["reference"])
	_check(str(second["delivered"][0]["color"]) == "yellow" and int(second["delivered"][0]["count"]) == 2, "route 119 delivers yellow 2")
	_check(_at(_frame(second, 8), 3, 2) and _dir_at(_frame(second, 8), 3, 2) == 0 and _count_at(_frame(second, 8), 3, 2) == 2, "route 119 waits on the cant facing east")
	_check(_at(_frame(second, 9), 3, 0) and _dir_at(_frame(second, 9), 3, 0) == 0, "route 119 jumps two cells north and still faces east")
	var second_bias: Dictionary = Sim.run(_by_id(119), _swap(_by_id(119), "cant", "bias"))
	var bias_landed := false
	for frame in second_bias["frames"]:
		if _at(frame, 3, 0):
			bias_landed = true
	_check(not bool(second_bias["success"]) and _at(_frame(second_bias, 8), 3, 2) and not bias_landed, "route 119's bias is one cell short")
	var second_pause: Dictionary = Sim.run(_by_id(119), _swap(_by_id(119), "cant", "pause"))
	var pause_landed := false
	for frame in second_pause["frames"]:
		if _at(frame, 3, 0):
			pause_landed = true
	_check(not bool(second_pause["success"]) and _at(_frame(second_pause, 8), 3, 2) and _dir_at(_frame(second_pause, 8), 3, 2) == 0 and not pause_landed, "route 119's pause never jumps far enough")
	_check(not bool(Sim.run(_by_id(119), _swap(_by_id(119), "painter", "conveyor"))["success"]), "route 119 fails if the parcel is not painted")
	_check(not bool(Sim.run(_by_id(119), _swap(_by_id(119), "counter", "conveyor"))["success"]), "route 119 fails without the second stamp")
	_check(not bool(Sim.run(_by_id(119), _swap(_by_id(119), "splitter", "conveyor"))["success"]), "route 119 loops if the splitter cannot send the second pass east")
	var night: Dictionary = Sim.run(_by_id(120), _by_id(120)["reference"])
	_check(str(night["delivered"][0]["color"]) == "red" and int(night["delivered"][0]["count"]) == 1, "route 120 stamps red 1")
	_check(str(night["delivered"][1]["color"]) == "yellow" and int(night["delivered"][1]["count"]) == 2, "route 120 stamps yellow 2")
	_check(str(night["delivered"][2]["color"]) == "blue" and int(night["delivered"][2]["count"]) == 3, "route 120 stamps blue 3")
	_check(_color_at(_frame(night, 5), 3, 3) == "red" and _dir_at(_frame(night, 5), 3, 3) == 0, "route 120 holds red facing east")
	_check(_color_at(_frame(night, 6), 3, 1) == "red" and _dir_at(_frame(night, 6), 3, 1) == 0, "route 120 jumps red onto the counter and leaves it facing east")
	var night_side := false
	for block in _by_id(120)["reference"]:
		if int(block["x"]) == 3 and int(block["y"]) == 2:
			night_side = true
	for wall in _by_id(120)["walls"]:
		if int(wall["x"]) == 3 and int(wall["y"]) == 2:
			night_side = true
	var night_entered := false
	for frame in night["frames"]:
		if _at(frame, 3, 2):
			night_entered = true
	_check(not night_side, "route 120 leaves the cell to the left empty of blocks")
	_check(not night_entered, "route 120 does not enter the cell immediately to the left")
	var night_bias := _frame(Sim.run(_by_id(120), _swap(_by_id(120), "cant", "bias")), 6)
	_check(not night_bias.is_empty() and _color_at(night_bias, 3, 3) == "red" and _color_at(night_bias, 3, 1) != "red", "route 120's bias is one cell short of the counter")
	var night_sling := _frame(Sim.run(_by_id(120), _swap(_by_id(120), "cant", "sling")), 6)
	_check(not night_sling.is_empty() and _color_at(night_sling, 3, 3) == "red" and _color_at(night_sling, 3, 1) != "red", "route 120's sling jumps the other way")
	var night_vault := _frame(Sim.run(_by_id(120), _swap(_by_id(120), "cant", "vault")), 6)
	_check(not night_vault.is_empty() and _color_at(night_vault, 3, 3) == "red" and _color_at(night_vault, 3, 1) != "red", "route 120's vault jumps forward and misses the counter")
	var night_pause := _frame(Sim.run(_by_id(120), _swap(_by_id(120), "cant", "pause")), 6)
	_check(not night_pause.is_empty() and _color_at(night_pause, 3, 3) == "red" and _dir_at(night_pause, 3, 3) == 0 and _color_at(night_pause, 3, 1) != "red", "route 120's pause keeps east and only steps one cell")
	var night_chute := _frame(Sim.run(_by_id(120), _swap(_by_id(120), "cant", "chute")), 5)
	_check(not night_chute.is_empty() and _dir_at(night_chute, 3, 3) == 0, "route 120's chute writes its own east facing")
	_check(not bool(Sim.run(_by_id(120), _swap(_by_id(120), "primer", "painter"))["success"]), "route 120 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(120), _swap(_by_id(120), "filter", "conveyor"))["success"]), "route 120 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(120), _swap(_by_id(120), "counter", "conveyor"))["success"]), "route 120 fails without the counter")


func _balk_rules() -> void:
	print("balk")
	var hop := {
		"width": 3, "height": 1, "walls": [],
		"sources": [{"x": 1, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 0, "y": 0},
		"order": [{"color": "gray"}],
	}
	var graph := [{"type": "balk", "x": 2, "y": 0, "dir": 0}]
	var sent: Dictionary = Sim.run(hop, graph)
	_check(bool(sent["success"]), "a balk jumps two cells backward and the kept facing delivers")
	_check(int(sent["cycles"]) == 3 and int(sent["blocks"]) == 1, "the balk waits a tick and delivers on tick 3")
	var born := _frame(sent, 1)
	var waited := _frame(sent, 2)
	_check(not born.is_empty() and _at(born, 2, 0) and _dir_at(born, 2, 0) == 0, "the parcel arrives facing east")
	_check(not waited.is_empty() and _at(waited, 2, 0) and _dir_at(waited, 2, 0) == 0 and not _at(waited, 0, 0), "the balk does not move the parcel on that tick")
	_check(_count_at(waited, 2, 0) == 0 and _color_at(waited, 2, 0) == "gray", "a balk does not stamp or paint")
	var crossed := false
	for frame in sent["frames"]:
		if _at(frame, 1, 0):
			crossed = true
	_check(not crossed, "the balk does not enter the cell immediately behind")
	var tinted: Dictionary = Sim.run(hop, [{"type": "balk", "x": 2, "y": 0, "dir": 0, "color": "red"}])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a balk is ignored")
	var blue_board: Dictionary = hop.duplicate(true)
	blue_board["sources"][0]["parcels"][0]["color"] = "blue"
	blue_board["order"] = [{"color": "blue"}]
	var blue_run: Dictionary = Sim.run(blue_board, graph)
	_check(bool(blue_run["success"]) and int(blue_run["cycles"]) == 3, "a balk does not filter, so blue takes the same jump")
	for dir in range(4):
		var spun: Array = graph.duplicate(true)
		spun[0]["dir"] = dir
		var run: Dictionary = Sim.run(hop, spun)
		_check(bool(run["success"]) and int(run["cycles"]) == 3, "rotating a balk does not change the jump")
	var returned: Dictionary = Sim.run(hop, [{"type": "return", "x": 2, "y": 0, "dir": 0}])
	_check(not bool(returned["success"]) and str(returned["reason"]) == "stuck", "a return reverses the facing and cannot step through the source")
	_check(_at(_frame(returned, 2), 2, 0) and _dir_at(_frame(returned, 2), 2, 0) == 2, "the return is facing west on the balk cell")
	var vaulted: Dictionary = Sim.run(hop, [{"type": "vault", "x": 2, "y": 0, "dir": 0}])
	_check(not bool(vaulted["success"]) and str(vaulted["reason"]) == "stuck", "a vault jumps two cells east and misses the backward jump")
	var canted: Dictionary = Sim.run(hop, [{"type": "cant", "x": 2, "y": 0, "dir": 0}])
	_check(not bool(canted["success"]) and str(canted["reason"]) == "stuck", "a cant jumps two cells north and misses the backward jump")
	var slung: Dictionary = Sim.run(hop, [{"type": "sling", "x": 2, "y": 0, "dir": 0}])
	_check(not bool(slung["success"]) and str(slung["reason"]) == "stuck", "a sling jumps two cells south and misses the backward jump")
	var biased: Dictionary = Sim.run(hop, [{"type": "bias", "x": 2, "y": 0, "dir": 0}])
	_check(not bool(biased["success"]) and str(biased["reason"]) == "stuck", "a bias steps one cell north and never reaches the dock")
	var shunted: Dictionary = Sim.run(hop, [{"type": "shunt", "x": 2, "y": 0, "dir": 0}])
	_check(not bool(shunted["success"]) and str(shunted["reason"]) == "stuck", "a shunt steps one cell south and never reaches the dock")
	var paused: Dictionary = Sim.run(hop, [{"type": "pause", "x": 2, "y": 0, "dir": 0}])
	_check(not bool(paused["success"]) and str(paused["reason"]) == "stuck", "a pause steps one cell east and never reaches the dock")
	var slid: Dictionary = Sim.run(hop, [{"type": "slide", "x": 2, "y": 0, "dir": 0}])
	_check(not bool(slid["success"]) and str(slid["reason"]) == "stuck", "a slide jumps forward on the arrival tick and misses the dock")

	var back_step := {
		"width": 4, "height": 2, "walls": [],
		"sources": [{"x": 1, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 1, "y": 1},
		"order": [{"color": "gray"}],
	}
	var walked: Dictionary = Sim.run(back_step, [
		{"type": "conveyor", "x": 2, "y": 1, "dir": 0},
		{"type": "balk", "x": 3, "y": 1, "dir": 0},
	])
	_check(bool(walked["success"]) and int(walked["cycles"]) == 4, "a balk jumps the dock two cells back")
	_check(_at(_frame(walked, 3), 3, 1) and _dir_at(_frame(walked, 3), 3, 1) == 0, "the balk keeps the east facing through its wait")
	var stepped_back := false
	for frame in walked["frames"]:
		if _at(frame, 2, 1) and int(frame["tick"]) >= 3:
			stepped_back = true
	_check(not stepped_back, "the jump does not re-enter the cell immediately behind")
	var one_back: Dictionary = Sim.run(back_step, [
		{"type": "conveyor", "x": 2, "y": 1, "dir": 0},
		{"type": "return", "x": 3, "y": 1, "dir": 0},
	])
	_check(not bool(one_back["success"]), "a return does not jump the dock")
	_check(_at(_frame(one_back, 4), 2, 1) and _dir_at(_frame(one_back, 4), 2, 1) == 2, "a return steps one cell west into the cell immediately behind")

	var jumps := [
		{"name": "east", "src": Vector2i(1, 1), "arrival": 0, "bias": Vector2i(2, 1), "balk": Vector2i(2, 0), "skip": Vector2i(1, 0), "land": Vector2i(0, 0), "dock": Vector2i(1, 0), "size": Vector2i(3, 2)},
		{"name": "south", "src": Vector2i(0, 1), "arrival": 1, "bias": Vector2i(0, 2), "balk": Vector2i(1, 2), "skip": Vector2i(1, 1), "land": Vector2i(1, 0), "dock": Vector2i(1, 1), "size": Vector2i(2, 3)},
		{"name": "west", "src": Vector2i(1, 0), "arrival": 2, "bias": Vector2i(0, 0), "balk": Vector2i(0, 1), "skip": Vector2i(1, 1), "land": Vector2i(2, 1), "dock": Vector2i(1, 1), "size": Vector2i(3, 2)},
		{"name": "north", "src": Vector2i(2, 1), "arrival": 3, "bias": Vector2i(2, 0), "balk": Vector2i(1, 0), "skip": Vector2i(1, 1), "land": Vector2i(1, 2), "dock": Vector2i(1, 1), "size": Vector2i(3, 3)},
	]
	for spec in jumps:
		var src_at: Vector2i = spec["src"]
		var bias_at: Vector2i = spec["bias"]
		var balk_at: Vector2i = spec["balk"]
		var skip_at: Vector2i = spec["skip"]
		var land_at: Vector2i = spec["land"]
		var dock_at: Vector2i = spec["dock"]
		var size_at: Vector2i = spec["size"]
		var arrival := int(spec["arrival"])
		var strip := {
			"width": size_at.x, "height": size_at.y, "walls": [],
			"sources": [{"x": src_at.x, "y": src_at.y, "dir": arrival, "parcels": [{"color": "gray"}]}],
			"dock": {"x": dock_at.x, "y": dock_at.y},
			"order": [{"color": "gray"}],
		}
		var blocks := [
			{"type": "bias", "x": bias_at.x, "y": bias_at.y, "dir": 0},
			{"type": "balk", "x": balk_at.x, "y": balk_at.y, "dir": 0},
			{"type": "pause", "x": land_at.x, "y": land_at.y, "dir": 0},
		]
		var run: Dictionary = Sim.run(strip, blocks)
		var moved := _frame(run, 5)
		_check(bool(run["success"]) and int(run["cycles"]) == 7, "a %s parcel jumps two cells backward and the pause follows the old facing" % str(spec["name"]))
		_check(not moved.is_empty() and _at(moved, land_at.x, land_at.y) and _dir_at(moved, land_at.x, land_at.y) == arrival and not _at(moved, skip_at.x, skip_at.y), "a %s parcel still faces %s after the jump and has not entered the cell behind" % [str(spec["name"]), str(spec["name"])])

	var rider := {
		"width": 4, "height": 3, "walls": [],
		"sources": [
			{"x": 2, "y": 2, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 2, "y": 0, "dir": 1, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 1, "y": 1},
		"order": [{"color": "gray"}],
	}
	var over: Dictionary = Sim.run(rider, [
		{"type": "bias", "x": 3, "y": 2, "dir": 0},
		{"type": "balk", "x": 3, "y": 1, "dir": 0},
	])
	_check(bool(over["success"]) and int(over["cycles"]) == 5, "a parcel in the cell behind does not block the jump")
	_check(_color_at(_frame(over, 4), 2, 1) == "blue" and _color_at(_frame(over, 4), 3, 1) == "gray" and _dir_at(_frame(over, 4), 3, 1) == 0, "the balk waits while the other parcel sits behind it")
	var hopped := false
	var blue_moved := false
	for frame in over["frames"]:
		if _color_at(frame, 2, 1) == "gray":
			hopped = true
		if int(frame["tick"]) >= 1 and _color_at(frame, 2, 1) != "blue":
			blue_moved = true
	_check(not hopped and not blue_moved, "the jump does not enter that cell and does not move the parcel sitting there")

	var gap := {
		"width": 4, "height": 2, "walls": [],
		"sources": [
			{"x": 2, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "blue"}, {"color": "gray"}],
	}
	var followed: Dictionary = Sim.run(gap, [
		{"type": "balk", "x": 3, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 1, "y": 1, "dir": 3},
		{"type": "conveyor", "x": 1, "y": 0, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 0, "dir": 0},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 6, "a balk can land in a cell another parcel is leaving")
	var into := _frame(followed, 3)
	_check(not into.is_empty() and _color_at(into, 1, 1) == "gray" and _dir_at(into, 1, 1) == 0 and _color_at(into, 2, 0) == "blue", "the jump lands in the cell the other parcel left and still faces east")

	var held_board := {
		"width": 4, "height": 2, "walls": [],
		"sources": [
			{"x": 2, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 0, "y": 0},
		"order": [{"color": "gray"}],
	}
	var waiting: Dictionary = Sim.run(held_board, [{"type": "balk", "x": 3, "y": 1, "dir": 0}])
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a balk keeps waiting while its landing stays blocked")
	var same := _frame(waiting, 2)
	var later := _frame(waiting, 5)
	_check(not same.is_empty() and _at(same, 3, 1) and _dir_at(same, 3, 1) == 0, "the first blocked jump does not change the facing")
	_check(not later.is_empty() and _at(later, 3, 1) and _dir_at(later, 3, 1) == 0 and _color_at(later, 1, 1) == "blue", "the balk keeps the arrival facing while the other parcel stays")

	var outside := {
		"width": 3, "height": 2, "walls": [],
		"sources": [{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 2, "y": 1},
		"order": [{"color": "gray"}],
	}
	var missed: Dictionary = Sim.run(outside, [{"type": "balk", "x": 1, "y": 1, "dir": 0}])
	_check(not bool(missed["success"]) and str(missed["reason"]) == "stuck", "a balk does not jump out of bounds")
	_check(_at(_frame(missed, 2), 1, 1) and _dir_at(_frame(missed, 2), 1, 1) == 0, "the out-of-bounds jump leaves the parcel facing east")
	var floor := {
		"width": 4, "height": 1, "walls": [],
		"sources": [{"x": 2, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 0, "y": 0},
		"order": [{"color": "gray"}],
	}
	var bare: Dictionary = Sim.run(floor, [{"type": "balk", "x": 3, "y": 0, "dir": 0}])
	_check(not bool(bare["success"]) and str(bare["reason"]) == "stuck", "a balk does not land on empty floor")
	_check(_at(_frame(bare, 2), 3, 0) and _dir_at(_frame(bare, 2), 3, 0) == 0 and not _at(_frame(bare, 2), 1, 0), "the empty landing leaves the parcel on the balk, still facing east")


func _building_seventeen() -> void:
	print("building 17")
	var puzzles := Puzzles.all()
	_check(puzzles.size() == 127, "building 17 adds routes 121 through 127")
	_check(int(puzzles[119]["id"]) == 120, "route 120 is the last route before the balk")
	_check(int(puzzles[120]["id"]) == 121, "the balk begins at route 121")
	_check(Puzzles.INTRO.size() == 21 and Puzzles.INTRO[20] == "balk", "the balk is the block building 17 teaches")
	_check(not Puzzles.unlocked_at(119).has("balk"), "the balk stays locked through route 120")
	_check(Puzzles.unlocked_at(120).has("balk"), "route 121 unlocks the balk")
	_check(Puzzles.unlocked_at(126).size() == 21, "building 17 ends with every block")
	var pars := {
		121: [4, 2],
		122: [11, 10],
		123: [11, 11],
		124: [5, 3],
		125: [4, 3],
		126: [7, 3],
		127: [15, 15],
	}
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id <= 120:
			_check(int(puzzle.get("building", 1)) < 17, "route %d stays out of building 17" % id)
			if id >= 114:
				_check(int(puzzle.get("building", 1)) == 16, "route %d stays in building 16" % id)
			continue
		_check(int(puzzle.get("building", 1)) == 17, "route %d is building 17" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		var locked: Array = pars[id]
		_check(int(par["cycles"]) == int(locked[0]) and int(par["blocks"]) == int(locked[1]), "route %d par is %d cycles and %d blocks" % [id, int(locked[0]), int(locked[1])])
		if id == 121:
			_check(str(puzzle.get("unlocks", "")) == "balk", "route 121 teaches the balk")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_balk := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "balk":
				uses_balk = true
		_check(uses_balk, "route %d reference uses the balk" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	for id in [121, 122, 123, 124, 125, 126, 127]:
		for dir in range(4):
			var spun: Array = _by_id(id)["reference"].duplicate(true)
			for block in spun:
				if str(block["type"]) == "balk":
					block["dir"] = dir
			var spun_run: Dictionary = Sim.run(_by_id(id), spun)
			_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == int(pars[id][0]), "route %d ignores which way the balk block is rotated" % id)
		for kind in ["cant", "sling", "vault", "return", "bias", "shunt", "slide", "bridge", "pause", "chute", "turn", "hook", "conveyor"]:
			var swapped: Dictionary = Sim.run(_by_id(id), _swap(_by_id(id), "balk", kind))
			_check(not bool(swapped["success"]), "route %d fails if the balk is a %s" % [id, kind])
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "balk":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the balk is missing" % id)

	var lesson: Dictionary = Sim.run(_by_id(121), _by_id(121)["reference"])
	_check(_at(_frame(lesson, 2), 2, 1) and _dir_at(_frame(lesson, 2), 2, 1) == 0, "route 121 starts the parcel facing east on the balk")
	_check(_at(_frame(lesson, 3), 2, 1) and _dir_at(_frame(lesson, 3), 2, 1) == 0, "route 121 keeps the parcel facing east without moving it")
	_check(int(lesson["cycles"]) == 4, "route 121 delivers on the jump")
	var lesson_return: Dictionary = Sim.run(_by_id(121), _swap(_by_id(121), "balk", "return"))
	_check(not bool(lesson_return["success"]) and _at(_frame(lesson_return, 4), 1, 1) and _dir_at(_frame(lesson_return, 4), 1, 1) == 2, "route 121's return reverses the facing and steps only one cell west")
	var lesson_vault: Dictionary = Sim.run(_by_id(121), _swap(_by_id(121), "balk", "vault"))
	_check(str(lesson_vault["reason"]) == "stuck" and _at(_frame(lesson_vault, 3), 2, 1) and _dir_at(_frame(lesson_vault, 3), 2, 1) == 0, "route 121's vault jumps two cells east")
	var lesson_cant: Dictionary = Sim.run(_by_id(121), _swap(_by_id(121), "balk", "cant"))
	_check(str(lesson_cant["reason"]) == "stuck" and _at(_frame(lesson_cant, 3), 2, 1), "route 121's cant jumps two cells north")

	var let_balk: Dictionary = Sim.run(_by_id(122), _by_id(122)["reference"])
	_check(_color_at(_frame(let_balk, 4), 5, 1) == "red" and _dir_at(_frame(let_balk, 4), 5, 1) == 0 and _color_at(_frame(let_balk, 4), 3, 1) == "blue", "route 122 holds red while blue is on the landing")
	_check(_color_at(_frame(let_balk, 5), 5, 1) == "red" and _dir_at(_frame(let_balk, 5), 5, 1) == 0 and _color_at(_frame(let_balk, 5), 3, 1) == "blue", "route 122 waits again because the landing is still taken")
	_check(_color_at(_frame(let_balk, 6), 3, 1) == "red" and _dir_at(_frame(let_balk, 6), 3, 1) == 0 and _color_at(_frame(let_balk, 6), 4, 1) == "gray", "route 122 jumps over the parcel sitting behind the balk")
	var gray_left := false
	var red_behind := false
	for frame in let_balk["frames"]:
		if _color_at(frame, 4, 1) != "gray" and int(frame["tick"]) >= 1:
			gray_left = true
		if _color_at(frame, 4, 1) == "red":
			red_behind = true
	_check(not gray_left and not red_behind, "route 122's sitting parcel does not move and the jump does not enter its cell")

	var counted: Dictionary = Sim.run(_by_id(123), _by_id(123)["reference"])
	_check(str(counted["delivered"][0]["color"]) == "blue" and int(counted["delivered"][0]["count"]) == 1, "route 123 delivers blue count 1")
	_check(str(counted["delivered"][1]["color"]) == "red" and int(counted["delivered"][1]["count"]) == 2, "route 123 delivers red count 2")
	_check(_color_at(_frame(counted, 6), 2, 1) == "red" and _dir_at(_frame(counted, 6), 2, 1) == 0 and _color_at(_frame(counted, 6), 3, 1) != "red", "route 123 jumps over the counter and still faces east")
	_check(_color_at(_frame(counted, 8), 3, 1) == "red" and _count_at(_frame(counted, 8), 3, 1) == 0, "route 123 reaches the counter after the jump")
	_check(_count_at(_frame(counted, 9), 3, 2) == 2, "route 123's counter stamps 2")
	var count_belt: Dictionary = Sim.run(_by_id(123), _swap(_by_id(123), "balk", "conveyor"))
	_check(str(count_belt["reason"]) == "wrong_delivery" and int(count_belt["delivered"][0]["count"]) == 1 and str(count_belt["delivered"][0]["color"]) == "red", "route 123's conveyor stamps a different number")
	var count_return: Dictionary = Sim.run(_by_id(123), _swap(_by_id(123), "balk", "return"))
	_check(_color_at(_frame(count_return, 6), 3, 1) == "red" and _dir_at(_frame(count_return, 6), 3, 1) == 2, "route 123's return steps into the near cell")
	_check(str(count_return["reason"]) == "wrong_delivery" and int(count_return["delivered"][0]["count"]) == 1, "route 123's return is stamped on the wrong tick")
	var count_vault := _frame(Sim.run(_by_id(123), _swap(_by_id(123), "balk", "vault")), 8)
	_check(not count_vault.is_empty() and _color_at(count_vault, 4, 1) == "red" and _color_at(count_vault, 3, 1) != "red", "route 123's vault jumps forward and misses the counter")

	var clear: Dictionary = Sim.run(_by_id(124), _by_id(124)["reference"])
	_check(_at(_frame(clear, 4), 3, 1) and _dir_at(_frame(clear, 4), 3, 1) == 0, "route 124 waits on the balk facing east")
	_check(int(clear["cycles"]) == 5, "route 124 lands two cells back on the dock")
	var brick_entered := false
	for frame in clear["frames"]:
		if _at(frame, 2, 1):
			brick_entered = true
	_check(not brick_entered, "route 124 does not enter the brick immediately behind")
	var clear_return: Dictionary = Sim.run(_by_id(124), _swap(_by_id(124), "balk", "return"))
	var clear_return_frame := _frame(clear_return, 4)
	_check(str(clear_return["reason"]) == "stuck" and not clear_return_frame.is_empty() and _at(clear_return_frame, 3, 1) and _dir_at(clear_return_frame, 3, 1) == 2 and not _at(clear_return_frame, 2, 1), "route 124's return tries to enter the brick and sticks")
	var clear_bias: Dictionary = Sim.run(_by_id(124), _swap(_by_id(124), "balk", "bias"))
	var clear_bias_frame := _frame(clear_bias, 5)
	_check(not bool(clear_bias["success"]) and not clear_bias_frame.is_empty() and _at(clear_bias_frame, 3, 0) and _dir_at(clear_bias_frame, 3, 0) == 0 and not _at(clear_bias_frame, 1, 1), "route 124's bias steps north into a cell the order does not use")

	var paired: Dictionary = Sim.run(_by_id(125), _by_id(125)["reference"])
	_check(_color_at(_frame(paired, 2), 4, 2) == "red" and _dir_at(_frame(paired, 2), 4, 2) == 0, "route 125 holds the east-facing parcel")
	_check(_color_at(_frame(paired, 2), 2, 0) == "blue" and _dir_at(_frame(paired, 2), 2, 0) == 3, "route 125 holds the north-facing parcel")
	_check(_frame(paired, 3).get("delivered", []).size() == 1 and str(_frame(paired, 3)["delivered"][0]["color"]) == "red", "route 125 jumps the east-facing parcel back onto the dock")
	_check(_frame(paired, 4).get("delivered", []).size() == 2 and str(_frame(paired, 4)["delivered"][1]["color"]) == "blue", "route 125 jumps the north-facing parcel back onto the dock")
	for cell in [Vector2i(4, 2), Vector2i(2, 0)]:
		for kind in ["cant", "sling", "vault"]:
			var one: Dictionary = Sim.run(_by_id(125), _swap_cell(_by_id(125), cell.x, cell.y, kind))
			_check(not bool(one["success"]), "route 125 misses the dock if the balk at %d,%d is a %s" % [cell.x, cell.y, kind])

	var second: Dictionary = Sim.run(_by_id(126), _by_id(126)["reference"])
	_check(_at(_frame(second, 2), 2, 1) and _dir_at(_frame(second, 2), 2, 1) == 0, "route 126 waits on the first balk facing east")
	_check(_at(_frame(second, 3), 0, 1) and _dir_at(_frame(second, 3), 0, 1) == 0, "route 126 jumps back and still faces east")
	_check(_at(_frame(second, 4), 0, 1) and _dir_at(_frame(second, 4), 0, 1) == 1, "route 126 turns onto the new facing")
	_check(_at(_frame(second, 6), 0, 2) and _dir_at(_frame(second, 6), 0, 2) == 1, "route 126 waits on the second balk facing south")
	_check(int(second["cycles"]) == 7, "route 126 jumps back on the new facing")
	_check(not bool(Sim.run(_by_id(126), _omit_cell(_by_id(126), 2, 1))["success"]), "route 126 fails without the first balk")
	_check(not bool(Sim.run(_by_id(126), _omit_cell(_by_id(126), 0, 2))["success"]), "route 126 fails without the second balk")

	var night: Dictionary = Sim.run(_by_id(127), _by_id(127)["reference"])
	_check(str(night["delivered"][0]["color"]) == "red" and int(night["delivered"][0]["count"]) == 1, "route 127 stamps red 1")
	_check(str(night["delivered"][1]["color"]) == "yellow" and int(night["delivered"][1]["count"]) == 2, "route 127 stamps yellow 2")
	_check(str(night["delivered"][2]["color"]) == "blue" and int(night["delivered"][2]["count"]) == 3, "route 127 stamps blue 3")
	_check(_color_at(_frame(night, 6), 3, 1) == "red" and _dir_at(_frame(night, 6), 3, 1) == 0, "route 127 holds red facing east")
	_check(_color_at(_frame(night, 8), 1, 1) == "red" and _dir_at(_frame(night, 8), 1, 1) == 0, "route 127 jumps red onto the counter and leaves it facing east")
	var night_entered := false
	for frame in night["frames"]:
		if _at(frame, 2, 1):
			night_entered = true
	_check(not night_entered, "route 127 does not enter the cell immediately behind")
	var night_cant: Dictionary = Sim.run(_by_id(127), _swap(_by_id(127), "balk", "cant"))
	_check(not bool(night_cant["success"]), "route 127's cant jumps left and misses the dock")
	_check(not bool(Sim.run(_by_id(127), _swap(_by_id(127), "primer", "painter"))["success"]), "route 127 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(127), _swap(_by_id(127), "filter", "conveyor"))["success"]), "route 127 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(127), _swap(_by_id(127), "counter", "conveyor"))["success"]), "route 127 fails without the counter")


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
	_check(routes == 127, "all 127 routes are on the board")
	print("    route row width ", width)
	_check(width == 2700.0, "the route row minimum width is 2700 (%s)" % width)
	_check(int(ProjectSettings.get_setting("display/window/size/viewport_width")) == 2740, "the window is 2740 wide")
	_check(int(ProjectSettings.get_setting("display/window/size/viewport_height")) == 720, "the window is 720 tall")
	_check(width + 40.0 == 2740.0, "the window keeps 20 pixels of spare on each side of the route row")
	_check(node.find_child("BuildingTwelveMark", true, false) != null, "building 12's mark stays on the route row")
	_check(node.find_child("BuildingThirteenMark", true, false) != null, "the route row marks building 13")
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
	var saw_chute := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Chute"):
				saw_chute = true
	_check(not saw_chute, "route 78 keeps the chute locked")
	node.select_puzzle(78)
	_check(building != null and building.text == "BUILDING 11", "route 79 opens building 11")
	_check(node.find_child("BuildingElevenMark", true, false) != null, "the route row marks building 11")
	tools = node.find_child("ToolBox", true, false)
	saw_chute = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Chute"):
				saw_chute = true
	_check(saw_chute, "route 79 offers the chute")
	node.select_puzzle(84)
	_check(building != null and building.text == "BUILDING 11", "route 85 stays in building 11")
	tools = node.find_child("ToolBox", true, false)
	saw_chute = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Chute"):
				saw_chute = true
	_check(saw_chute, "route 85 still offers the chute")
	var saw_shunt := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Shunt"):
				saw_shunt = true
	_check(not saw_shunt, "route 85 keeps the shunt locked")
	node.select_puzzle(85)
	_check(building != null and building.text == "BUILDING 12", "route 86 opens building 12")
	_check(node.find_child("BuildingTwelveMark", true, false) != null, "the route row marks building 12")
	tools = node.find_child("ToolBox", true, false)
	saw_shunt = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Shunt"):
				saw_shunt = true
	_check(saw_shunt, "route 86 offers the shunt")
	node.select_puzzle(91)
	_check(building != null and building.text == "BUILDING 12", "route 92 stays in building 12")
	tools = node.find_child("ToolBox", true, false)
	saw_shunt = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Shunt"):
				saw_shunt = true
	_check(saw_shunt, "route 92 still offers the shunt")
	var saw_bias := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Bias"):
				saw_bias = true
	_check(not saw_bias, "route 92 keeps the bias locked")
	node.select_puzzle(92)
	_check(building != null and building.text == "BUILDING 13", "route 93 opens building 13")
	_check(node.find_child("BuildingThirteenMark", true, false) != null, "the route row marks building 13")
	_check(node.find_child("BuildingTwelveMark", true, false) != null, "building 12's mark stays beside building 13")
	tools = node.find_child("ToolBox", true, false)
	saw_bias = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Bias"):
				saw_bias = true
	_check(saw_bias, "route 93 offers the bias")
	node.select_puzzle(98)
	_check(building != null and building.text == "BUILDING 13", "route 99 stays in building 13")
	tools = node.find_child("ToolBox", true, false)
	saw_bias = false
	saw_shunt = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Bias"):
				saw_bias = true
			if str(child.text).begins_with("Shunt"):
				saw_shunt = true
	_check(saw_bias, "route 99 still offers the bias")
	_check(saw_shunt, "route 99 still offers the shunt")
	var saw_vault := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Vault"):
				saw_vault = true
	_check(not saw_vault, "route 99 keeps the vault locked")
	node.select_puzzle(99)
	_check(building != null and building.text == "BUILDING 14", "route 100 opens building 14")
	_check(node.find_child("BuildingFourteenMark", true, false) != null, "the route row marks building 14")
	_check(node.find_child("BuildingThirteenMark", true, false) != null, "building 13's mark stays beside building 14")
	tools = node.find_child("ToolBox", true, false)
	saw_vault = false
	saw_bias = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Vault"):
				saw_vault = true
			if str(child.text).begins_with("Bias"):
				saw_bias = true
	_check(saw_vault, "route 100 offers the vault")
	_check(saw_bias, "route 100 still offers the bias")
	node.select_puzzle(105)
	_check(building != null and building.text == "BUILDING 14", "route 106 stays in building 14")
	tools = node.find_child("ToolBox", true, false)
	saw_vault = false
	saw_bias = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Vault"):
				saw_vault = true
			if str(child.text).begins_with("Bias"):
				saw_bias = true
	_check(saw_vault, "route 106 still offers the vault")
	_check(saw_bias, "route 106 still offers the bias")
	var saw_sling := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Sling"):
				saw_sling = true
	_check(not saw_sling, "route 106 keeps the sling locked")
	node.select_puzzle(106)
	_check(building != null and building.text == "BUILDING 15", "route 107 opens building 15")
	_check(node.find_child("BuildingFifteenMark", true, false) != null, "the route row marks building 15")
	_check(node.find_child("BuildingFourteenMark", true, false) != null, "building 14's mark stays beside building 15")
	tools = node.find_child("ToolBox", true, false)
	saw_sling = false
	saw_vault = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Sling"):
				saw_sling = true
			if str(child.text).begins_with("Vault"):
				saw_vault = true
	_check(saw_sling, "route 107 offers the sling")
	_check(saw_vault, "route 107 still offers the vault")
	node.select_puzzle(112)
	_check(building != null and building.text == "BUILDING 15", "route 113 stays in building 15")
	tools = node.find_child("ToolBox", true, false)
	saw_sling = false
	saw_vault = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Sling"):
				saw_sling = true
			if str(child.text).begins_with("Vault"):
				saw_vault = true
	_check(saw_sling, "route 113 still offers the sling")
	_check(saw_vault, "route 113 still offers the vault")
	var saw_cant := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Cant"):
				saw_cant = true
	_check(not saw_cant, "route 113 keeps the cant locked")
	node.select_puzzle(113)
	_check(building != null and building.text == "BUILDING 16", "route 114 opens building 16")
	_check(node.find_child("BuildingSixteenMark", true, false) != null, "the route row marks building 16")
	_check(node.find_child("BuildingFifteenMark", true, false) != null, "building 15's mark stays beside building 16")
	tools = node.find_child("ToolBox", true, false)
	saw_cant = false
	saw_sling = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Cant"):
				saw_cant = true
			if str(child.text).begins_with("Sling"):
				saw_sling = true
	_check(saw_cant, "route 114 offers the cant")
	_check(saw_sling, "route 114 still offers the sling")
	node.select_puzzle(119)
	_check(building != null and building.text == "BUILDING 16", "route 120 stays in building 16")
	tools = node.find_child("ToolBox", true, false)
	saw_cant = false
	saw_sling = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Cant"):
				saw_cant = true
			if str(child.text).begins_with("Sling"):
				saw_sling = true
	_check(saw_cant, "route 120 still offers the cant")
	_check(saw_sling, "route 120 still offers the sling")
	var saw_balk := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Balk"):
				saw_balk = true
	_check(not saw_balk, "route 120 keeps the balk locked")
	node.select_puzzle(120)
	_check(building != null and building.text == "BUILDING 17", "route 121 opens building 17")
	_check(node.find_child("BuildingSeventeenMark", true, false) != null, "the route row marks building 17")
	_check(node.find_child("BuildingSixteenMark", true, false) != null, "building 16's mark stays beside building 17")
	tools = node.find_child("ToolBox", true, false)
	saw_balk = false
	saw_cant = false
	var balk_button: Button = null
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Balk"):
				saw_balk = true
				balk_button = child
			if str(child.text).begins_with("Cant"):
				saw_cant = true
	_check(saw_balk, "route 121 offers the balk")
	_check(saw_cant, "route 121 still offers the cant")
	if balk_button != null:
		_check(str(balk_button.tooltip_text).begins_with("Waits one tick, then jumps a parcel two cells backward"), "the balk tooltip describes the backward jump")
		_check(str(balk_button.text).begins_with("Balk"), "the balk button reads Balk")
	node.select_puzzle(126)
	_check(building != null and building.text == "BUILDING 17", "route 127 stays in building 17")
	tools = node.find_child("ToolBox", true, false)
	saw_balk = false
	saw_cant = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Balk"):
				saw_balk = true
			if str(child.text).begins_with("Cant"):
				saw_cant = true
	_check(saw_balk, "route 127 still offers the balk")
	_check(saw_cant, "route 127 still offers the cant")
	node.select_puzzle(0)
	node._unhandled_input(_key_press(KEY_8))
	_check(int(node.get_puzzle()["id"]) == 8, "key 8 still selects route 8")
	node._unhandled_input(_key_press(KEY_1))
	_check(int(node.get_puzzle()["id"]) == 1, "key 1 still selects route 1")
	node._unhandled_input(_key_press(KEY_BRACKETRIGHT))
	_check(int(node.get_puzzle()["id"]) == 2, "] still steps to the next route")
	node._unhandled_input(_key_press(KEY_BRACKETLEFT))
	_check(int(node.get_puzzle()["id"]) == 1, "[ still steps to the previous route")
	node.queue_free()


func _key_press(keycode: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = keycode
	event.echo = false
	return event


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
