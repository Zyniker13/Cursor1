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
	_loft_rules()
	_building_eighteen()
	_keel_rules()
	_building_nineteen()
	_sheer_rules()
	_building_twenty()
	_strake_rules()
	_building_twenty_one()
	_wale_rules()
	_building_twenty_two()
	_garboard_rules()
	_building_twenty_three()
	_stealer_rules()
	_building_twenty_four()
	_rabbet_rules()
	_building_twenty_five()
	_futtock_rules()
	_building_twenty_six()
	_keelson_rules()
	_building_twenty_seven()
	_stemson_rules()
	_building_twenty_eight()
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
	_check(puzzles.size() >= 127, "building 17 adds routes 121 through 127")
	_check(int(puzzles[119]["id"]) == 120, "route 120 is the last route before the balk")
	_check(int(puzzles[120]["id"]) == 121, "the balk begins at route 121")
	_check(Puzzles.INTRO.size() >= 21 and Puzzles.INTRO[20] == "balk", "the balk is the block building 17 teaches")
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
		if id > 127:
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


func _loft_rules() -> void:
	print("loft")
	var hop := {
		"width": 5, "height": 1, "walls": [],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 4, "y": 0},
		"order": [{"color": "gray"}],
	}
	var graph := [{"type": "loft", "x": 1, "y": 0, "dir": 0}]
	var sent: Dictionary = Sim.run(hop, graph)
	_check(bool(sent["success"]), "a loft jumps three cells forward and the kept facing delivers")
	_check(int(sent["cycles"]) == 3 and int(sent["blocks"]) == 1, "the loft waits a tick and delivers on tick 3")
	var born := _frame(sent, 1)
	var waited := _frame(sent, 2)
	_check(not born.is_empty() and _at(born, 1, 0) and _dir_at(born, 1, 0) == 0, "the parcel arrives facing east")
	_check(not waited.is_empty() and _at(waited, 1, 0) and _dir_at(waited, 1, 0) == 0 and not _at(waited, 4, 0), "the loft does not move the parcel on that tick")
	_check(_count_at(waited, 1, 0) == 0 and _color_at(waited, 1, 0) == "gray", "a loft does not stamp or paint")
	var crossed := false
	for frame in sent["frames"]:
		if _at(frame, 2, 0) or _at(frame, 3, 0):
			crossed = true
	_check(not crossed, "the loft does not enter either cell immediately ahead")
	var tinted: Dictionary = Sim.run(hop, [{"type": "loft", "x": 1, "y": 0, "dir": 0, "color": "red"}])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a loft is ignored")
	var blue_board: Dictionary = hop.duplicate(true)
	blue_board["sources"][0]["parcels"][0]["color"] = "blue"
	blue_board["order"] = [{"color": "blue"}]
	var blue_run: Dictionary = Sim.run(blue_board, graph)
	_check(bool(blue_run["success"]) and int(blue_run["cycles"]) == 3, "a loft does not filter, so blue takes the same jump")
	for dir in range(4):
		var spun: Array = graph.duplicate(true)
		spun[0]["dir"] = dir
		var run: Dictionary = Sim.run(hop, spun)
		_check(bool(run["success"]) and int(run["cycles"]) == 3, "rotating a loft does not change the jump")
	var short_board: Dictionary = hop.duplicate(true)
	var over_bin: Dictionary = Sim.run(short_board, [
		{"type": "loft", "x": 1, "y": 0, "dir": 0},
		{"type": "bin", "x": 3, "y": 0, "dir": 0},
	])
	_check(bool(over_bin["success"]) and int(over_bin["cycles"]) == 3, "a bin in a skipped cell does not stop the three-cell jump")
	var vaulted: Dictionary = Sim.run(short_board, [
		{"type": "vault", "x": 1, "y": 0, "dir": 0},
		{"type": "bin", "x": 3, "y": 0, "dir": 0},
	])
	_check(not bool(vaulted["success"]) and _at(_frame(vaulted, 3), 3, 0) and _dir_at(_frame(vaulted, 3), 3, 0) == 0 and not _at(_frame(vaulted, 3), 4, 0), "a vault lands one cell short of a loft")
	var balked: Dictionary = Sim.run(hop, [{"type": "balk", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(balked["success"]) and str(balked["reason"]) == "stuck", "a balk jumps two cells backward and misses the dock")
	var canted: Dictionary = Sim.run(hop, [{"type": "cant", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(canted["success"]) and str(canted["reason"]) == "stuck", "a cant jumps two cells north and misses the dock")
	var slung: Dictionary = Sim.run(hop, [{"type": "sling", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(slung["success"]) and str(slung["reason"]) == "stuck", "a sling jumps two cells south and misses the dock")
	var returned: Dictionary = Sim.run(hop, [{"type": "return", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(returned["success"]) and str(returned["reason"]) == "stuck", "a return reverses the facing and cannot step through the source")
	_check(_at(_frame(returned, 2), 1, 0) and _dir_at(_frame(returned, 2), 1, 0) == 2, "the return is facing west on the loft cell")
	var front := {
		"width": 5, "height": 1, "walls": [],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 4, "y": 0},
		"order": [{"color": "gray"}],
	}
	var cleared: Dictionary = Sim.run(front, [
		{"type": "loft", "x": 1, "y": 0, "dir": 0},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
	])
	_check(bool(cleared["success"]) and int(cleared["cycles"]) == 3, "a loft jumps over the first cell ahead")
	var stepped: Dictionary = Sim.run(front, [
		{"type": "conveyor", "x": 1, "y": 0, "dir": 0},
		{"type": "pause", "x": 2, "y": 0, "dir": 0},
	])
	_check(not bool(stepped["success"]) and _at(_frame(stepped, 2), 2, 0), "a conveyor enters the first cell ahead")
	var back_step := {
		"width": 6, "height": 1, "walls": [],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 5, "y": 0},
		"order": [{"color": "gray"}],
	}
	var walked: Dictionary = Sim.run(back_step, [
		{"type": "conveyor", "x": 1, "y": 0, "dir": 0},
		{"type": "loft", "x": 2, "y": 0, "dir": 0},
	])
	_check(bool(walked["success"]) and int(walked["cycles"]) == 4, "a loft jumps the dock three cells ahead")
	var one_back: Dictionary = Sim.run(back_step, [
		{"type": "conveyor", "x": 1, "y": 0, "dir": 0},
		{"type": "return", "x": 2, "y": 0, "dir": 0},
	])
	_check(not bool(one_back["success"]), "a return does not jump three cells forward")
	_check(_at(_frame(one_back, 4), 1, 0) and _dir_at(_frame(one_back, 4), 1, 0) == 2, "a return steps one cell west and reverses the facing")

	var jumps := [
		{"name": "east", "src": Vector2i(0, 1), "arrival": 0, "loft": Vector2i(1, 1), "near": Vector2i(2, 1), "far": Vector2i(3, 1), "land": Vector2i(4, 1), "dock": Vector2i(5, 1), "size": Vector2i(6, 2)},
		{"name": "south", "src": Vector2i(1, 0), "arrival": 1, "loft": Vector2i(1, 1), "near": Vector2i(1, 2), "far": Vector2i(1, 3), "land": Vector2i(1, 4), "dock": Vector2i(1, 5), "size": Vector2i(2, 6)},
		{"name": "west", "src": Vector2i(5, 1), "arrival": 2, "loft": Vector2i(4, 1), "near": Vector2i(3, 1), "far": Vector2i(2, 1), "land": Vector2i(1, 1), "dock": Vector2i(0, 1), "size": Vector2i(6, 2)},
		{"name": "north", "src": Vector2i(1, 5), "arrival": 3, "loft": Vector2i(1, 4), "near": Vector2i(1, 3), "far": Vector2i(1, 2), "land": Vector2i(1, 1), "dock": Vector2i(1, 0), "size": Vector2i(2, 6)},
	]
	for spec in jumps:
		var src_at: Vector2i = spec["src"]
		var loft_at: Vector2i = spec["loft"]
		var near_at: Vector2i = spec["near"]
		var far_at: Vector2i = spec["far"]
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
			{"type": "loft", "x": loft_at.x, "y": loft_at.y, "dir": 0},
			{"type": "pause", "x": land_at.x, "y": land_at.y, "dir": 0},
		]
		var run: Dictionary = Sim.run(strip, blocks)
		var moved := _frame(run, 3)
		_check(bool(run["success"]) and int(run["cycles"]) == 5, "a %s parcel jumps three cells forward and the pause follows the old facing" % str(spec["name"]))
		_check(not moved.is_empty() and _at(moved, land_at.x, land_at.y) and _dir_at(moved, land_at.x, land_at.y) == arrival and not _at(moved, near_at.x, near_at.y) and not _at(moved, far_at.x, far_at.y), "a %s parcel still faces %s after the jump and has not entered the two cells ahead" % [str(spec["name"]), str(spec["name"])])

	var rider := {
		"width": 5, "height": 2, "walls": [],
		"sources": [
			{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 2, "y": 1, "dir": 3, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 4, "y": 0},
		"order": [{"color": "gray"}],
	}
	var over: Dictionary = Sim.run(rider, [{"type": "loft", "x": 1, "y": 0, "dir": 0}])
	_check(bool(over["success"]) and int(over["cycles"]) == 3, "a parcel in a skipped cell does not block the jump")
	_check(_color_at(_frame(over, 2), 1, 0) == "gray" and _dir_at(_frame(over, 2), 1, 0) == 0 and _color_at(_frame(over, 2), 2, 0) == "blue", "the loft waits while the other parcel sits ahead of it")
	var hopped := false
	var blue_moved := false
	for frame in over["frames"]:
		if _color_at(frame, 2, 0) == "gray" or _color_at(frame, 3, 0) == "gray":
			hopped = true
		if int(frame["tick"]) >= 1 and _color_at(frame, 2, 0) != "blue":
			blue_moved = true
	_check(not hopped and not blue_moved, "the jump does not enter that cell and does not move the parcel sitting there")
	var far_rider: Dictionary = rider.duplicate(true)
	far_rider["sources"][1]["x"] = 3
	var over_far: Dictionary = Sim.run(far_rider, [{"type": "loft", "x": 1, "y": 0, "dir": 0}])
	_check(bool(over_far["success"]) and int(over_far["cycles"]) == 3 and _color_at(_frame(over_far, 3), 3, 0) == "blue", "a parcel in the second skipped cell does not block the jump and is not moved")

	var gap := {
		"width": 6, "height": 2, "walls": [],
		"sources": [
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 3, "y": 1, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 5, "y": 1},
		"order": [{"color": "blue"}, {"color": "gray"}],
	}
	var followed: Dictionary = Sim.run(gap, [
		{"type": "loft", "x": 1, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 4, "y": 1, "dir": 0},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 4, "a loft can land in a cell another parcel is leaving")
	var into := _frame(followed, 3)
	_check(not into.is_empty() and _color_at(into, 4, 1) == "gray" and _dir_at(into, 4, 1) == 0 and into.get("delivered", []).size() == 1, "the jump lands in the cell the other parcel left and still faces east")

	var held_board := {
		"width": 6, "height": 3, "walls": [{"x": 4, "y": 0}],
		"sources": [
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 4, "y": 2, "dir": 3, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 5, "y": 1},
		"order": [{"color": "gray"}],
	}
	var waiting: Dictionary = Sim.run(held_board, [
		{"type": "loft", "x": 1, "y": 1, "dir": 0},
		{"type": "pause", "x": 4, "y": 1, "dir": 0},
	])
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a loft keeps waiting while its landing stays blocked")
	var same := _frame(waiting, 2)
	var later := _frame(waiting, 5)
	_check(not same.is_empty() and _at(same, 1, 1) and _dir_at(same, 1, 1) == 0, "the first blocked jump does not change the facing")
	_check(not later.is_empty() and _at(later, 1, 1) and _dir_at(later, 1, 1) == 0 and _color_at(later, 4, 1) == "blue", "the loft keeps the arrival facing while the other parcel stays")

	var outside := {
		"width": 4, "height": 1, "walls": [],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "gray"}],
	}
	var missed: Dictionary = Sim.run(outside, [{"type": "loft", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(missed["success"]) and str(missed["reason"]) == "stuck", "a loft does not jump out of bounds")
	_check(_at(_frame(missed, 2), 1, 0) and _dir_at(_frame(missed, 2), 1, 0) == 0, "the out-of-bounds jump leaves the parcel facing east")
	var floor := {
		"width": 5, "height": 1, "walls": [],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 2, "y": 0},
		"order": [{"color": "gray"}],
	}
	var bare: Dictionary = Sim.run(floor, [{"type": "loft", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(bare["success"]) and str(bare["reason"]) == "stuck", "a loft does not land on empty floor")
	_check(_at(_frame(bare, 2), 1, 0) and _dir_at(_frame(bare, 2), 1, 0) == 0 and not _at(_frame(bare, 2), 2, 0) and not _at(_frame(bare, 2), 3, 0) and not _at(_frame(bare, 2), 4, 0), "the empty landing leaves the parcel on the loft, still facing east")
	var bricked := {
		"width": 5, "height": 1,
		"walls": [{"x": 2, "y": 0}, {"x": 3, "y": 0}],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 4, "y": 0},
		"order": [{"color": "gray"}],
	}
	var through: Dictionary = Sim.run(bricked, [{"type": "loft", "x": 1, "y": 0, "dir": 0}])
	_check(bool(through["success"]) and int(through["cycles"]) == 3, "bricks in the two cells ahead do not stop the jump")


func _building_eighteen() -> void:
	print("building 18")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 134, "building 18 adds routes 128 through 134")
	_check(int(puzzles[126]["id"]) == 127, "route 127 is the last route before the loft")
	_check(int(puzzles[127]["id"]) == 128, "the loft begins at route 128")
	_check(Puzzles.INTRO.size() >= 22 and Puzzles.INTRO[21] == "loft", "the loft is the block building 18 teaches")
	_check(not Puzzles.unlocked_at(126).has("loft"), "the loft stays locked through route 127")
	_check(Puzzles.unlocked_at(127).has("loft"), "route 128 unlocks the loft")
	_check(Puzzles.unlocked_at(133).size() == 22, "building 18 ends with every block")
	var pars := {
		128: [4, 4],
		129: [8, 6],
		130: [7, 8],
		131: [4, 3],
		132: [5, 5],
		133: [7, 3],
		134: [13, 12],
	}
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id <= 127:
			_check(int(puzzle.get("building", 1)) < 18, "route %d stays out of building 18" % id)
			if id >= 121:
				_check(int(puzzle.get("building", 1)) == 17, "route %d stays in building 17" % id)
			continue
		if id > 134:
			continue
		_check(int(puzzle.get("building", 1)) == 18, "route %d is building 18" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		var locked: Array = pars[id]
		_check(int(par["cycles"]) == int(locked[0]) and int(par["blocks"]) == int(locked[1]), "route %d par is %d cycles and %d blocks" % [id, int(locked[0]), int(locked[1])])
		if id == 128:
			_check(str(puzzle.get("unlocks", "")) == "loft", "route 128 teaches the loft")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_loft := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "loft":
				uses_loft = true
		_check(uses_loft, "route %d reference uses the loft" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	for id in [128, 129, 130, 131, 132, 133, 134]:
		for dir in range(4):
			var spun: Array = _by_id(id)["reference"].duplicate(true)
			for block in spun:
				if str(block["type"]) == "loft":
					block["dir"] = dir
			var spun_run: Dictionary = Sim.run(_by_id(id), spun)
			_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == int(pars[id][0]), "route %d ignores which way the loft block is rotated" % id)
		for kind in ["vault", "balk", "cant", "sling", "return", "conveyor", "pause", "slide", "bridge", "turn", "chute", "hook", "bias", "shunt"]:
			var swapped: Dictionary = Sim.run(_by_id(id), _swap(_by_id(id), "loft", kind))
			_check(not bool(swapped["success"]), "route %d fails if the loft is a %s" % [id, kind])
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "loft":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the loft is missing" % id)

	var lesson: Dictionary = Sim.run(_by_id(128), _by_id(128)["reference"])
	_check(_at(_frame(lesson, 2), 2, 1) and _dir_at(_frame(lesson, 2), 2, 1) == 0, "route 128 starts the parcel facing east on the loft")
	_check(_at(_frame(lesson, 3), 2, 1) and _dir_at(_frame(lesson, 3), 2, 1) == 0, "route 128 keeps the parcel facing east without moving it")
	_check(int(lesson["cycles"]) == 4, "route 128 delivers on the jump")
	var lesson_crossed := false
	for frame in lesson["frames"]:
		if _at(frame, 3, 1) or _at(frame, 4, 1):
			lesson_crossed = true
	_check(not lesson_crossed, "route 128 does not enter the two cells ahead")
	var lesson_vault: Dictionary = Sim.run(_by_id(128), _swap(_by_id(128), "loft", "vault"))
	_check(str(lesson_vault["reason"]) == "stuck" and _at(_frame(lesson_vault, 4), 4, 1) and _dir_at(_frame(lesson_vault, 4), 4, 1) == 0, "route 128's vault lands one cell short")
	var lesson_belt: Dictionary = Sim.run(_by_id(128), _swap(_by_id(128), "loft", "conveyor"))
	_check(str(lesson_belt["reason"]) == "stuck" and _at(_frame(lesson_belt, 3), 3, 1), "route 128's conveyor enters the first cell ahead")
	var lesson_return: Dictionary = Sim.run(_by_id(128), _swap(_by_id(128), "loft", "return"))
	_check(str(lesson_return["reason"]) == "tick_cap" and _at(_frame(lesson_return, 3), 2, 1) and _dir_at(_frame(lesson_return, 3), 2, 1) == 2 and _at(_frame(lesson_return, 4), 1, 1) and _dir_at(_frame(lesson_return, 4), 1, 1) == 2, "route 128's return reverses the facing and steps one cell west")
	var lesson_balk: Dictionary = Sim.run(_by_id(128), _swap(_by_id(128), "loft", "balk"))
	_check(str(lesson_balk["reason"]) == "stuck" and _at(_frame(lesson_balk, 3), 2, 1) and _dir_at(_frame(lesson_balk, 3), 2, 1) == 0, "route 128's balk jumps backward")
	var lesson_cant: Dictionary = Sim.run(_by_id(128), _swap(_by_id(128), "loft", "cant"))
	_check(str(lesson_cant["reason"]) == "stuck" and _at(_frame(lesson_cant, 3), 2, 1), "route 128's cant jumps left")
	var lesson_sling: Dictionary = Sim.run(_by_id(128), _swap(_by_id(128), "loft", "sling"))
	_check(str(lesson_sling["reason"]) == "stuck" and _at(_frame(lesson_sling, 3), 2, 1), "route 128's sling jumps right")

	var let_loft: Dictionary = Sim.run(_by_id(129), _by_id(129)["reference"])
	_check(_color_at(_frame(let_loft, 4), 2, 1) == "red" and _dir_at(_frame(let_loft, 4), 2, 1) == 0 and _color_at(_frame(let_loft, 4), 5, 1) == "blue" and _color_at(_frame(let_loft, 4), 4, 1) == "gray", "route 129 holds red while blue is on the landing and gray sits ahead")
	_check(_color_at(_frame(let_loft, 5), 5, 1) == "red" and _dir_at(_frame(let_loft, 5), 5, 1) == 0 and _color_at(_frame(let_loft, 5), 4, 1) == "gray", "route 129 jumps once the landing is free and still faces east")
	var gray_left := false
	var red_skipped := false
	for frame in let_loft["frames"]:
		if int(frame["tick"]) >= 1 and _color_at(frame, 4, 1) != "gray":
			gray_left = true
		if _color_at(frame, 3, 1) == "red" or _color_at(frame, 4, 1) == "red":
			red_skipped = true
	_check(not gray_left and not red_skipped, "route 129's sitting parcel does not move and the jump does not enter its cell")

	var counted: Dictionary = Sim.run(_by_id(130), _by_id(130)["reference"])
	_check(str(counted["delivered"][0]["color"]) == "blue" and int(counted["delivered"][0]["count"]) == 1, "route 130 delivers blue count 1")
	_check(str(counted["delivered"][1]["color"]) == "red" and int(counted["delivered"][1]["count"]) == 2, "route 130 delivers red count 2")
	_check(_color_at(_frame(counted, 3), 2, 1) == "red" and _dir_at(_frame(counted, 3), 2, 1) == 0, "route 130 waits on the loft facing east")
	_check(_color_at(_frame(counted, 4), 5, 1) == "red" and _dir_at(_frame(counted, 4), 5, 1) == 0 and _color_at(_frame(counted, 4), 3, 1) == "blue", "route 130 jumps over the belt and still faces east")
	_check(_color_at(_frame(counted, 6), 4, 1) == "red" and _count_at(_frame(counted, 6), 4, 1) == 0, "route 130 reaches the counter after the jump")
	var count_vault: Dictionary = Sim.run(_by_id(130), _swap(_by_id(130), "loft", "vault"))
	_check(str(count_vault["reason"]) == "wrong_delivery" and str(count_vault["delivered"][0]["color"]) == "red" and int(count_vault["delivered"][0]["count"]) == 1, "route 130's vault is stamped on a different cell")
	_check(_color_at(_frame(count_vault, 4), 4, 1) == "red" and _dir_at(_frame(count_vault, 4), 4, 1) == 0, "route 130's vault lands one cell short of the loft")
	var count_belt: Dictionary = Sim.run(_by_id(130), _swap(_by_id(130), "loft", "conveyor"))
	_check(str(count_belt["reason"]) == "wrong_delivery" and str(count_belt["delivered"][0]["color"]) == "red" and int(count_belt["delivered"][0]["count"]) == 1, "route 130's conveyor is stamped wrong")

	var clear: Dictionary = Sim.run(_by_id(131), _by_id(131)["reference"])
	_check(_color_at(_frame(clear, 3), 2, 1) == "gray" and _dir_at(_frame(clear, 3), 2, 1) == 0 and _color_at(_frame(clear, 3), 4, 1) == "blue", "route 131 waits while a parcel stays in front")
	_check(int(clear["cycles"]) == 4 and _color_at(_frame(clear, 4), 4, 1) == "blue", "route 131 lands three cells ahead and leaves the sitting parcel")
	var brick_entered := false
	for frame in clear["frames"]:
		if _at(frame, 3, 1):
			brick_entered = true
	_check(not brick_entered, "route 131 does not enter the brick immediately ahead")

	var paired: Dictionary = Sim.run(_by_id(132), _by_id(132)["reference"])
	_check(_color_at(_frame(paired, 3), 2, 2) == "red" and _dir_at(_frame(paired, 3), 2, 2) == 0, "route 132 holds the east-facing parcel")
	_check(_color_at(_frame(paired, 3), 5, 5) == "blue" and _dir_at(_frame(paired, 3), 5, 5) == 3, "route 132 holds the north-facing parcel")
	_check(_frame(paired, 4).get("delivered", []).size() == 1 and str(_frame(paired, 4)["delivered"][0]["color"]) == "red", "route 132 jumps the east-facing parcel onto the dock")
	_check(_frame(paired, 5).get("delivered", []).size() == 2 and str(_frame(paired, 5)["delivered"][1]["color"]) == "blue", "route 132 jumps the north-facing parcel onto the dock")
	for cell in [Vector2i(2, 2), Vector2i(5, 5)]:
		for kind in ["vault", "balk", "cant", "sling"]:
			var one: Dictionary = Sim.run(_by_id(132), _swap_cell(_by_id(132), cell.x, cell.y, kind))
			_check(not bool(one["success"]), "route 132 misses the dock if the loft at %d,%d is a %s" % [cell.x, cell.y, kind])

	var second: Dictionary = Sim.run(_by_id(133), _by_id(133)["reference"])
	_check(_at(_frame(second, 2), 1, 1) and _dir_at(_frame(second, 2), 1, 1) == 0, "route 133 waits on the first loft facing east")
	_check(_at(_frame(second, 3), 4, 1) and _dir_at(_frame(second, 3), 4, 1) == 0, "route 133 jumps ahead and still faces east")
	_check(_at(_frame(second, 5), 4, 2) and _dir_at(_frame(second, 5), 4, 2) == 1, "route 133 reaches the second loft facing south")
	_check(_at(_frame(second, 6), 4, 2) and _dir_at(_frame(second, 6), 4, 2) == 1, "route 133 waits on the second loft facing south")
	_check(int(second["cycles"]) == 7, "route 133 jumps ahead on the new facing")
	_check(not bool(Sim.run(_by_id(133), _omit_cell(_by_id(133), 1, 1))["success"]), "route 133 fails without the first loft")
	_check(not bool(Sim.run(_by_id(133), _omit_cell(_by_id(133), 4, 2))["success"]), "route 133 fails without the second loft")

	var night: Dictionary = Sim.run(_by_id(134), _by_id(134)["reference"])
	_check(int(night["cycles"]) < 250, "route 134 finishes before tick 250")
	_check(str(night["delivered"][0]["color"]) == "red" and int(night["delivered"][0]["count"]) == 1, "route 134 stamps red 1")
	_check(str(night["delivered"][1]["color"]) == "yellow" and int(night["delivered"][1]["count"]) == 2, "route 134 stamps yellow 2")
	_check(str(night["delivered"][2]["color"]) == "blue" and int(night["delivered"][2]["count"]) == 3, "route 134 stamps blue 3")
	_check(_color_at(_frame(night, 5), 2, 1) == "red" and _dir_at(_frame(night, 5), 2, 1) == 0, "route 134 holds red facing east")
	_check(_color_at(_frame(night, 6), 5, 1) == "red" and _dir_at(_frame(night, 6), 5, 1) == 0, "route 134 jumps red onto the counter and leaves it facing east")
	var night_entered := false
	for frame in night["frames"]:
		if _at(frame, 3, 1) or _at(frame, 4, 1):
			night_entered = true
	_check(not night_entered, "route 134 does not enter the two cells ahead")
	_check(not bool(Sim.run(_by_id(134), _swap(_by_id(134), "primer", "painter"))["success"]), "route 134 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(134), _swap(_by_id(134), "filter", "conveyor"))["success"]), "route 134 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(134), _swap(_by_id(134), "counter", "conveyor"))["success"]), "route 134 fails without the counter")


func _keel_rules() -> void:
	print("keel")
	var hop := {
		"width": 4, "height": 1, "walls": [],
		"sources": [{"x": 2, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 0, "y": 0},
		"order": [{"color": "gray"}],
	}
	var graph := [{"type": "keel", "x": 3, "y": 0, "dir": 0}]
	var sent: Dictionary = Sim.run(hop, graph)
	_check(bool(sent["success"]), "a keel jumps three cells backward and the kept facing delivers")
	_check(int(sent["cycles"]) == 3 and int(sent["blocks"]) == 1, "the keel waits a tick and delivers on tick 3")
	var born := _frame(sent, 1)
	var waited := _frame(sent, 2)
	_check(not born.is_empty() and _at(born, 3, 0) and _dir_at(born, 3, 0) == 0, "the parcel arrives facing east")
	_check(not waited.is_empty() and _at(waited, 3, 0) and _dir_at(waited, 3, 0) == 0 and not _at(waited, 0, 0), "the keel does not move the parcel on that tick")
	_check(_count_at(waited, 3, 0) == 0 and _color_at(waited, 3, 0) == "gray", "a keel does not stamp or paint")
	var crossed := false
	for frame in sent["frames"]:
		if _at(frame, 1, 0) or _at(frame, 2, 0):
			crossed = true
	_check(not crossed, "the keel does not enter either cell immediately behind")
	var tinted: Dictionary = Sim.run(hop, [{"type": "keel", "x": 3, "y": 0, "dir": 0, "color": "red"}])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a keel is ignored")
	var blue_board: Dictionary = hop.duplicate(true)
	blue_board["sources"][0]["parcels"][0]["color"] = "blue"
	blue_board["order"] = [{"color": "blue"}]
	var blue_run: Dictionary = Sim.run(blue_board, graph)
	_check(bool(blue_run["success"]) and int(blue_run["cycles"]) == 3, "a keel does not filter, so blue takes the same jump")
	for dir in range(4):
		var spun: Array = graph.duplicate(true)
		spun[0]["dir"] = dir
		var run: Dictionary = Sim.run(hop, spun)
		_check(bool(run["success"]) and int(run["cycles"]) == 3, "rotating a keel does not change the jump")
	var short_board: Dictionary = hop.duplicate(true)
	var over_bin: Dictionary = Sim.run(short_board, [
		{"type": "keel", "x": 3, "y": 0, "dir": 0},
		{"type": "bin", "x": 1, "y": 0, "dir": 0},
	])
	_check(bool(over_bin["success"]) and int(over_bin["cycles"]) == 3, "a bin in a skipped cell does not stop the three-cell jump")
	var balked: Dictionary = Sim.run(short_board, [
		{"type": "balk", "x": 3, "y": 0, "dir": 0},
		{"type": "bin", "x": 1, "y": 0, "dir": 0},
	])
	_check(not bool(balked["success"]) and _at(_frame(balked, 3), 1, 0) and _dir_at(_frame(balked, 3), 1, 0) == 0 and not _at(_frame(balked, 3), 0, 0), "a balk lands one cell short of a keel")
	var east_board := {
		"width": 7, "height": 1, "walls": [],
		"sources": [{"x": 2, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 0, "y": 0},
		"order": [{"color": "gray"}],
	}
	var lofted: Dictionary = Sim.run(east_board, [
		{"type": "loft", "x": 3, "y": 0, "dir": 0},
		{"type": "pause", "x": 6, "y": 0, "dir": 0},
	])
	_check(not bool(lofted["success"]) and _at(_frame(lofted, 3), 6, 0) and _dir_at(_frame(lofted, 3), 6, 0) == 0, "a loft jumps three cells east and misses the backward jump")
	var returned: Dictionary = Sim.run(hop, [{"type": "return", "x": 3, "y": 0, "dir": 0}])
	_check(not bool(returned["success"]) and str(returned["reason"]) == "stuck", "a return reverses the facing and cannot step through the source")
	_check(_at(_frame(returned, 2), 3, 0) and _dir_at(_frame(returned, 2), 3, 0) == 2, "the return is facing west on the keel cell")
	var canted: Dictionary = Sim.run(hop, [{"type": "cant", "x": 3, "y": 0, "dir": 0}])
	_check(not bool(canted["success"]) and str(canted["reason"]) == "stuck", "a cant jumps two cells north and misses the backward jump")
	var slung: Dictionary = Sim.run(hop, [{"type": "sling", "x": 3, "y": 0, "dir": 0}])
	_check(not bool(slung["success"]) and str(slung["reason"]) == "stuck", "a sling jumps two cells south and misses the backward jump")
	var vaulted: Dictionary = Sim.run(hop, [{"type": "vault", "x": 3, "y": 0, "dir": 0}])
	_check(not bool(vaulted["success"]) and str(vaulted["reason"]) == "stuck", "a vault jumps two cells east and misses the backward jump")
	var back_step := {
		"width": 6, "height": 2, "walls": [],
		"sources": [{"x": 4, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 2, "y": 0},
		"order": [{"color": "gray"}],
	}
	var walked: Dictionary = Sim.run(back_step, [
		{"type": "bias", "x": 5, "y": 1, "dir": 0},
		{"type": "keel", "x": 5, "y": 0, "dir": 0},
	])
	_check(bool(walked["success"]) and int(walked["cycles"]) == 5, "a keel jumps the dock three cells back")
	_check(_at(_frame(walked, 4), 5, 0) and _dir_at(_frame(walked, 4), 5, 0) == 0, "the keel keeps the east facing through its wait")
	var jumps := [
		{"name": "east", "src": Vector2i(4, 1), "arrival": 0, "keel": Vector2i(5, 1), "near": Vector2i(4, 1), "far": Vector2i(3, 1), "land": Vector2i(2, 1), "dock": Vector2i(3, 1), "size": Vector2i(6, 2)},
		{"name": "south", "src": Vector2i(1, 4), "arrival": 1, "keel": Vector2i(1, 5), "near": Vector2i(1, 4), "far": Vector2i(1, 3), "land": Vector2i(1, 2), "dock": Vector2i(1, 3), "size": Vector2i(2, 6)},
		{"name": "west", "src": Vector2i(5, 1), "arrival": 2, "keel": Vector2i(4, 1), "near": Vector2i(5, 1), "far": Vector2i(6, 1), "land": Vector2i(7, 1), "dock": Vector2i(6, 1), "size": Vector2i(8, 2)},
		{"name": "north", "src": Vector2i(1, 2), "arrival": 3, "keel": Vector2i(1, 1), "near": Vector2i(1, 2), "far": Vector2i(1, 3), "land": Vector2i(1, 4), "dock": Vector2i(1, 3), "size": Vector2i(2, 6)},
	]
	for spec in jumps:
		var src_at: Vector2i = spec["src"]
		var keel_at: Vector2i = spec["keel"]
		var near_at: Vector2i = spec["near"]
		var far_at: Vector2i = spec["far"]
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
			{"type": "keel", "x": keel_at.x, "y": keel_at.y, "dir": 0},
			{"type": "pause", "x": land_at.x, "y": land_at.y, "dir": 0},
		]
		var run: Dictionary = Sim.run(strip, blocks)
		var moved := _frame(run, 3)
		_check(bool(run["success"]) and int(run["cycles"]) == 5, "a %s parcel jumps three cells backward and the pause follows the old facing" % str(spec["name"]))
		_check(not moved.is_empty() and _at(moved, land_at.x, land_at.y) and _dir_at(moved, land_at.x, land_at.y) == arrival and not _at(moved, near_at.x, near_at.y) and not _at(moved, far_at.x, far_at.y), "a %s parcel still faces %s after the jump and has not entered the two cells behind" % [str(spec["name"]), str(spec["name"])])
	var rider := {
		"width": 5, "height": 3, "walls": [],
		"sources": [
			{"x": 3, "y": 2, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 3, "y": 0, "dir": 1, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 1, "y": 1},
		"order": [{"color": "gray"}],
	}
	var over: Dictionary = Sim.run(rider, [
		{"type": "bias", "x": 4, "y": 2, "dir": 0},
		{"type": "keel", "x": 4, "y": 1, "dir": 0},
	])
	_check(bool(over["success"]) and int(over["cycles"]) == 5, "a parcel in a skipped cell does not block the jump")
	_check(_color_at(_frame(over, 4), 4, 1) == "gray" and _dir_at(_frame(over, 4), 4, 1) == 0 and _color_at(_frame(over, 4), 3, 1) == "blue", "the keel waits while the other parcel sits behind it")
	var hopped := false
	var blue_moved := false
	for frame in over["frames"]:
		if _color_at(frame, 3, 1) == "gray" or _color_at(frame, 2, 1) == "gray":
			hopped = true
		if int(frame["tick"]) >= 1 and _color_at(frame, 3, 1) != "blue":
			blue_moved = true
	_check(not hopped and not blue_moved, "the jump does not enter that cell and does not move the parcel sitting there")
	var far_rider: Dictionary = rider.duplicate(true)
	far_rider["sources"][1]["x"] = 2
	far_rider["sources"][1]["y"] = 0
	var over_far: Dictionary = Sim.run(far_rider, [
		{"type": "bias", "x": 4, "y": 2, "dir": 0},
		{"type": "keel", "x": 4, "y": 1, "dir": 0},
	])
	_check(bool(over_far["success"]) and int(over_far["cycles"]) == 5 and _color_at(_frame(over_far, 5), 2, 1) == "blue", "a parcel in the second skipped cell does not block the jump and is not moved")
	var gap := {
		"width": 5, "height": 5, "walls": [],
		"sources": [
			{"x": 3, "y": 0, "dir": 1, "parcels": [{"color": "gray"}]},
			{"x": 1, "y": 4, "dir": 3, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 1, "y": 0},
		"order": [{"color": "blue"}, {"color": "gray"}],
	}
	var followed: Dictionary = Sim.run(gap, [
		{"type": "conveyor", "x": 3, "y": 1, "dir": 0},
		{"type": "keel", "x": 4, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 1, "y": 3, "dir": 3},
		{"type": "conveyor", "x": 1, "y": 2, "dir": 3},
		{"type": "conveyor", "x": 1, "y": 1, "dir": 3},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 5, "a keel can land in a cell another parcel is leaving")
	var into := _frame(followed, 4)
	_check(not into.is_empty() and _color_at(into, 1, 1) == "gray" and _dir_at(into, 1, 1) == 0 and into.get("delivered", []).size() == 1, "the jump lands in the cell the other parcel left and still faces east")
	var held_board := {
		"width": 6, "height": 3, "walls": [{"x": 1, "y": 0}],
		"sources": [
			{"x": 3, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 1, "y": 2, "dir": 3, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 0, "y": 1},
		"order": [{"color": "gray"}],
	}
	var waiting: Dictionary = Sim.run(held_board, [
		{"type": "keel", "x": 4, "y": 1, "dir": 0},
		{"type": "pause", "x": 1, "y": 1, "dir": 0},
	])
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a keel keeps waiting while its landing stays blocked")
	var same := _frame(waiting, 3)
	var later := _frame(waiting, 5)
	_check(not same.is_empty() and _at(same, 4, 1) and _dir_at(same, 4, 1) == 0, "the first blocked jump does not change the facing")
	_check(not later.is_empty() and _at(later, 4, 1) and _dir_at(later, 4, 1) == 0 and _color_at(later, 1, 1) == "blue", "the keel keeps the arrival facing while the other parcel stays")
	var outside := {
		"width": 4, "height": 1, "walls": [],
		"sources": [{"x": 0, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 3, "y": 0},
		"order": [{"color": "gray"}],
	}
	var missed: Dictionary = Sim.run(outside, [{"type": "keel", "x": 1, "y": 0, "dir": 0}])
	_check(not bool(missed["success"]) and str(missed["reason"]) == "stuck", "a keel does not jump out of bounds")
	_check(_at(_frame(missed, 2), 1, 0) and _dir_at(_frame(missed, 2), 1, 0) == 0, "the out-of-bounds jump leaves the parcel facing east")
	var floor := {
		"width": 5, "height": 1, "walls": [],
		"sources": [{"x": 3, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 0, "y": 0},
		"order": [{"color": "gray"}],
	}
	var bare: Dictionary = Sim.run(floor, [{"type": "keel", "x": 4, "y": 0, "dir": 0}])
	_check(not bool(bare["success"]) and str(bare["reason"]) == "stuck", "a keel does not land on empty floor")
	_check(_at(_frame(bare, 2), 4, 0) and _dir_at(_frame(bare, 2), 4, 0) == 0 and not _at(_frame(bare, 2), 1, 0) and not _at(_frame(bare, 2), 2, 0) and not _at(_frame(bare, 2), 3, 0), "the empty landing leaves the parcel on the keel, still facing east")
	var bricked := {
		"width": 5, "height": 2,
		"walls": [{"x": 3, "y": 0}, {"x": 2, "y": 0}],
		"sources": [{"x": 3, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 1, "y": 0},
		"order": [{"color": "gray"}],
	}
	var through: Dictionary = Sim.run(bricked, [
		{"type": "bias", "x": 4, "y": 1, "dir": 0},
		{"type": "keel", "x": 4, "y": 0, "dir": 0},
	])
	_check(bool(through["success"]) and int(through["cycles"]) == 5, "bricks in the two cells behind do not stop the jump")


func _building_nineteen() -> void:
	print("building 19")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 141, "building 19 adds routes 135 through 141")
	_check(int(puzzles[133]["id"]) == 134, "route 134 is the last route before the keel")
	_check(int(puzzles[134]["id"]) == 135, "the keel begins at route 135")
	_check(Puzzles.INTRO.size() >= 23 and Puzzles.INTRO[22] == "keel", "the keel is the block building 19 teaches")
	_check(not Puzzles.unlocked_at(133).has("keel"), "the keel stays locked through route 134")
	_check(Puzzles.unlocked_at(134).has("keel"), "route 135 unlocks the keel")
	_check(Puzzles.unlocked_at(140).size() == 23, "building 19 ends with every block")
	var pars := {
		135: [4, 4],
		136: [10, 9],
		137: [10, 10],
		138: [5, 3],
		139: [6, 5],
		140: [7, 3],
		141: [17, 17],
	}
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id <= 134:
			_check(int(puzzle.get("building", 1)) < 19, "route %d stays out of building 19" % id)
			if id >= 128:
				_check(int(puzzle.get("building", 1)) == 18, "route %d stays in building 18" % id)
			continue
		if id > 141:
			continue
		_check(int(puzzle.get("building", 1)) == 19, "route %d is building 19" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		var locked: Array = pars[id]
		_check(int(par["cycles"]) == int(locked[0]) and int(par["blocks"]) == int(locked[1]), "route %d par is %d cycles and %d blocks" % [id, int(locked[0]), int(locked[1])])
		if id == 135:
			_check(str(puzzle.get("unlocks", "")) == "keel", "route 135 teaches the keel")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_keel := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "keel":
				uses_keel = true
		_check(uses_keel, "route %d reference uses the keel" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	for id in [135, 136, 137, 138, 139, 140, 141]:
		for dir in range(4):
			var spun: Array = _by_id(id)["reference"].duplicate(true)
			for block in spun:
				if str(block["type"]) == "keel":
					block["dir"] = dir
			var spun_run: Dictionary = Sim.run(_by_id(id), spun)
			_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == int(pars[id][0]), "route %d ignores which way the keel block is rotated" % id)
		for kind in ["balk", "loft", "vault", "cant", "sling", "return", "conveyor", "pause", "slide", "bridge", "turn", "chute", "hook", "bias", "shunt"]:
			var swapped: Dictionary = Sim.run(_by_id(id), _swap(_by_id(id), "keel", kind))
			_check(not bool(swapped["success"]), "route %d fails if the keel is a %s" % [id, kind])
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "keel":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the keel is missing" % id)

	var lesson: Dictionary = Sim.run(_by_id(135), _by_id(135)["reference"])
	_check(_at(_frame(lesson, 2), 4, 1) and _dir_at(_frame(lesson, 2), 4, 1) == 0, "route 135 starts the parcel facing east on the keel")
	_check(_at(_frame(lesson, 3), 4, 1) and _dir_at(_frame(lesson, 3), 4, 1) == 0, "route 135 keeps the parcel facing east without moving it")
	_check(int(lesson["cycles"]) == 4, "route 135 delivers on the jump")
	var lesson_crossed := false
	for frame in lesson["frames"]:
		if int(frame["tick"]) >= 2 and (_at(frame, 2, 1) or _at(frame, 3, 1)):
			lesson_crossed = true
	_check(not lesson_crossed, "route 135 does not enter the two cells behind on the jump")
	var lesson_balk: Dictionary = Sim.run(_by_id(135), _swap(_by_id(135), "keel", "balk"))
	_check(str(lesson_balk["reason"]) == "stuck" and _at(_frame(lesson_balk, 4), 2, 1) and _dir_at(_frame(lesson_balk, 4), 2, 1) == 0, "route 135's balk lands one cell short")
	var lesson_loft: Dictionary = Sim.run(_by_id(135), _swap(_by_id(135), "keel", "loft"))
	_check(str(lesson_loft["reason"]) == "stuck" and _at(_frame(lesson_loft, 4), 7, 1) and _dir_at(_frame(lesson_loft, 4), 7, 1) == 0, "route 135's loft jumps three cells east")
	var lesson_return: Dictionary = Sim.run(_by_id(135), _swap(_by_id(135), "keel", "return"))
	_check(str(lesson_return["reason"]) == "tick_cap" and _at(_frame(lesson_return, 3), 4, 1) and _dir_at(_frame(lesson_return, 3), 4, 1) == 2 and _at(_frame(lesson_return, 4), 3, 1) and _dir_at(_frame(lesson_return, 4), 3, 1) == 2, "route 135's return reverses the facing and steps one cell west")

	var let_keel: Dictionary = Sim.run(_by_id(136), _by_id(136)["reference"])
	_check(_color_at(_frame(let_keel, 4), 5, 1) == "red" and _dir_at(_frame(let_keel, 4), 5, 1) == 0 and _color_at(_frame(let_keel, 4), 2, 1) == "blue" and _color_at(_frame(let_keel, 4), 4, 1) == "gray", "route 136 holds red while blue is on the landing and gray sits behind")
	_check(_color_at(_frame(let_keel, 5), 5, 1) == "red" and _dir_at(_frame(let_keel, 5), 5, 1) == 0 and _color_at(_frame(let_keel, 5), 2, 1) == "blue", "route 136 waits again because the landing is still taken")
	_check(_color_at(_frame(let_keel, 6), 2, 1) == "red" and _dir_at(_frame(let_keel, 6), 2, 1) == 0 and _color_at(_frame(let_keel, 6), 4, 1) == "gray", "route 136 jumps once the landing is free and still faces east")
	var gray_left := false
	var red_skipped := false
	for frame in let_keel["frames"]:
		if int(frame["tick"]) >= 1 and _color_at(frame, 4, 1) != "gray":
			gray_left = true
		if _color_at(frame, 4, 1) == "red" or _color_at(frame, 3, 1) == "red":
			red_skipped = true
	_check(not gray_left and not red_skipped, "route 136's sitting parcel does not move and the jump does not enter its cell")

	var counted: Dictionary = Sim.run(_by_id(137), _by_id(137)["reference"])
	_check(str(counted["delivered"][0]["color"]) == "blue" and int(counted["delivered"][0]["count"]) == 1, "route 137 delivers blue count 1")
	_check(str(counted["delivered"][1]["color"]) == "red" and int(counted["delivered"][1]["count"]) == 2, "route 137 delivers red count 2")
	_check(_color_at(_frame(counted, 4), 5, 1) == "red" and _dir_at(_frame(counted, 4), 5, 1) == 0, "route 137 waits on the keel facing east")
	_check(_color_at(_frame(counted, 5), 2, 1) == "red" and _dir_at(_frame(counted, 5), 2, 1) == 0 and _color_at(_frame(counted, 5), 3, 1) != "red", "route 137 jumps over the counter and still faces east")
	_check(_color_at(_frame(counted, 7), 3, 1) == "red" and _count_at(_frame(counted, 7), 3, 1) == 0, "route 137 reaches the counter after the jump")
	_check(_color_at(_frame(counted, 8), 3, 2) == "red" and _count_at(_frame(counted, 8), 3, 2) == 2, "route 137's counter stamps 2")
	var count_balk: Dictionary = Sim.run(_by_id(137), _swap(_by_id(137), "keel", "balk"))
	_check(str(count_balk["reason"]) == "wrong_delivery" and str(count_balk["delivered"][0]["color"]) == "red" and int(count_balk["delivered"][0]["count"]) == 1, "route 137's balk is stamped wrong")
	_check(_color_at(_frame(count_balk, 5), 3, 1) == "red" and _dir_at(_frame(count_balk, 5), 3, 1) == 0, "route 137's balk lands on the counter")

	var clear: Dictionary = Sim.run(_by_id(138), _by_id(138)["reference"])
	_check(_color_at(_frame(clear, 4), 4, 1) == "gray" and _dir_at(_frame(clear, 4), 4, 1) == 0 and _color_at(_frame(clear, 4), 2, 1) == "blue", "route 138 waits while a parcel stays behind")
	_check(int(clear["cycles"]) == 5 and _color_at(_frame(clear, 5), 2, 1) == "blue", "route 138 lands three cells back and leaves the sitting parcel")
	var brick_entered := false
	for frame in clear["frames"]:
		if _at(frame, 3, 1):
			brick_entered = true
	_check(not brick_entered, "route 138 does not enter the brick immediately behind")
	var clear_return: Dictionary = Sim.run(_by_id(138), _swap(_by_id(138), "keel", "return"))
	_check(str(clear_return["reason"]) == "stuck" and _at(_frame(clear_return, 4), 4, 1) and _dir_at(_frame(clear_return, 4), 4, 1) == 2 and not _at(_frame(clear_return, 4), 3, 1), "route 138's return tries to enter the brick and sticks")

	var paired: Dictionary = Sim.run(_by_id(139), _by_id(139)["reference"])
	_check(_color_at(_frame(paired, 4), 5, 3) == "red" and _dir_at(_frame(paired, 4), 5, 3) == 0, "route 139 holds the east-facing parcel")
	_check(_color_at(_frame(paired, 4), 2, 0) == "blue" and _dir_at(_frame(paired, 4), 2, 0) == 3, "route 139 holds the north-facing parcel")
	_check(_frame(paired, 5).get("delivered", []).size() == 1 and str(_frame(paired, 5)["delivered"][0]["color"]) == "red", "route 139 jumps the east-facing parcel onto the dock")
	_check(_frame(paired, 6).get("delivered", []).size() == 2 and str(_frame(paired, 6)["delivered"][1]["color"]) == "blue", "route 139 jumps the north-facing parcel onto the dock")
	for cell in [Vector2i(5, 3), Vector2i(2, 0)]:
		for kind in ["balk", "loft", "vault", "cant", "sling"]:
			var one: Dictionary = Sim.run(_by_id(139), _swap_cell(_by_id(139), cell.x, cell.y, kind))
			_check(not bool(one["success"]), "route 139 misses the dock if the keel at %d,%d is a %s" % [cell.x, cell.y, kind])

	var second: Dictionary = Sim.run(_by_id(140), _by_id(140)["reference"])
	_check(_at(_frame(second, 2), 6, 3) and _dir_at(_frame(second, 2), 6, 3) == 0, "route 140 waits on the first keel facing east")
	_check(_at(_frame(second, 3), 3, 3) and _dir_at(_frame(second, 3), 3, 3) == 0, "route 140 jumps back and still faces east")
	_check(_at(_frame(second, 5), 3, 4) and _dir_at(_frame(second, 5), 3, 4) == 1, "route 140 reaches the second keel facing south")
	_check(_at(_frame(second, 6), 3, 4) and _dir_at(_frame(second, 6), 3, 4) == 1, "route 140 waits on the second keel facing south")
	_check(int(second["cycles"]) == 7, "route 140 jumps back on the new facing")
	_check(not bool(Sim.run(_by_id(140), _omit_cell(_by_id(140), 6, 3))["success"]), "route 140 fails without the first keel")
	_check(not bool(Sim.run(_by_id(140), _omit_cell(_by_id(140), 3, 4))["success"]), "route 140 fails without the second keel")

	var night: Dictionary = Sim.run(_by_id(141), _by_id(141)["reference"])
	_check(int(night["cycles"]) < 250, "route 141 finishes before tick 250")
	_check(str(night["delivered"][0]["color"]) == "red" and int(night["delivered"][0]["count"]) == 1, "route 141 stamps red 1")
	_check(str(night["delivered"][1]["color"]) == "yellow" and int(night["delivered"][1]["count"]) == 2, "route 141 stamps yellow 2")
	_check(str(night["delivered"][2]["color"]) == "blue" and int(night["delivered"][2]["count"]) == 3, "route 141 stamps blue 3")
	_check(_color_at(_frame(night, 8), 4, 1) == "red" and _dir_at(_frame(night, 8), 4, 1) == 0, "route 141 holds red facing east")
	_check(_color_at(_frame(night, 9), 1, 1) == "red" and _dir_at(_frame(night, 9), 1, 1) == 0, "route 141 jumps red onto the counter and leaves it facing east")
	var night_entered := false
	for frame in night["frames"]:
		if _color_at(frame, 3, 1) == "red" or _color_at(frame, 2, 1) == "red":
			night_entered = true
	_check(not night_entered, "route 141 does not enter the two cells behind")
	var night_balk: Dictionary = Sim.run(_by_id(141), _swap(_by_id(141), "keel", "balk"))
	_check(not bool(night_balk["success"]) and _color_at(_frame(night_balk, 9), 2, 1) == "red" and _dir_at(_frame(night_balk, 9), 2, 1) == 0, "route 141's balk lands one cell short of the counter")
	_check(not bool(Sim.run(_by_id(141), _swap(_by_id(141), "primer", "painter"))["success"]), "route 141 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(141), _swap(_by_id(141), "filter", "conveyor"))["success"]), "route 141 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(141), _swap(_by_id(141), "counter", "conveyor"))["success"]), "route 141 fails without the counter")


func _sheer_rules() -> void:
	print("sheer")
	var hop := {
		"width": 3, "height": 4, "walls": [],
		"sources": [{"x": 1, "y": 0, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 2, "y": 3},
		"order": [{"color": "gray"}],
	}
	var graph := [{"type": "sheer", "x": 2, "y": 0, "dir": 0}]
	var sent: Dictionary = Sim.run(hop, graph)
	_check(bool(sent["success"]), "a sheer jumps three cells to the right and the kept facing delivers")
	_check(int(sent["cycles"]) == 3 and int(sent["blocks"]) == 1, "the sheer waits a tick and delivers on tick 3")
	var born := _frame(sent, 1)
	var waited := _frame(sent, 2)
	_check(not born.is_empty() and _at(born, 2, 0) and _dir_at(born, 2, 0) == 0, "the parcel arrives facing east")
	_check(not waited.is_empty() and _at(waited, 2, 0) and _dir_at(waited, 2, 0) == 0 and not _at(waited, 2, 3), "the sheer does not move the parcel on that tick")
	_check(_count_at(waited, 2, 0) == 0 and _color_at(waited, 2, 0) == "gray", "a sheer does not stamp or paint")
	var crossed := false
	for frame in sent["frames"]:
		if _at(frame, 2, 1) or _at(frame, 2, 2):
			crossed = true
	_check(not crossed, "the sheer does not enter either cell immediately to the right")
	var tinted: Dictionary = Sim.run(hop, [{"type": "sheer", "x": 2, "y": 0, "dir": 0, "color": "red"}])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a sheer is ignored")
	for dir in range(4):
		var spun: Array = graph.duplicate(true)
		spun[0]["dir"] = dir
		var run: Dictionary = Sim.run(hop, spun)
		_check(bool(run["success"]) and int(run["cycles"]) == 3, "rotating a sheer does not change the jump")
	var over_bin: Dictionary = Sim.run(hop, [
		{"type": "sheer", "x": 2, "y": 0, "dir": 0},
		{"type": "bin", "x": 2, "y": 2, "dir": 0},
	])
	_check(bool(over_bin["success"]) and int(over_bin["cycles"]) == 3, "a bin in a skipped cell does not stop the three-cell jump")
	var slung: Dictionary = Sim.run(hop, [
		{"type": "sling", "x": 2, "y": 0, "dir": 0},
		{"type": "bin", "x": 2, "y": 2, "dir": 0},
	])
	_check(not bool(slung["success"]) and _at(_frame(slung, 3), 2, 2) and _dir_at(_frame(slung, 3), 2, 2) == 0 and not _at(_frame(slung, 3), 2, 3), "a sling lands one cell short of a sheer")
	var lofted: Dictionary = Sim.run(hop, [{"type": "loft", "x": 2, "y": 0, "dir": 0}])
	_check(not bool(lofted["success"]) and str(lofted["reason"]) == "stuck", "a loft jumps three cells east and misses the rightward jump")
	var balked: Dictionary = Sim.run(hop, [{"type": "balk", "x": 2, "y": 0, "dir": 0}])
	_check(not bool(balked["success"]) and str(balked["reason"]) == "stuck", "a balk jumps two cells west and misses the rightward jump")
	var keeled: Dictionary = Sim.run(hop, [{"type": "keel", "x": 2, "y": 0, "dir": 0}])
	_check(not bool(keeled["success"]) and str(keeled["reason"]) == "stuck", "a keel jumps three cells west and misses the rightward jump")
	var returned: Dictionary = Sim.run(hop, [{"type": "return", "x": 2, "y": 0, "dir": 0}])
	_check(not bool(returned["success"]) and str(returned["reason"]) == "stuck", "a return reverses the facing and cannot step through the source")
	_check(_at(_frame(returned, 2), 2, 0) and _dir_at(_frame(returned, 2), 2, 0) == 2, "the return is facing west on the sheer cell")
	var jumps := [
		{"name": "east", "src": Vector2i(1, 1), "arrival": 0, "sheer": Vector2i(2, 1), "near": Vector2i(2, 2), "far": Vector2i(2, 3), "land": Vector2i(2, 4), "dock": Vector2i(3, 4), "size": Vector2i(4, 5)},
		{"name": "south", "src": Vector2i(4, 1), "arrival": 1, "sheer": Vector2i(4, 2), "near": Vector2i(3, 2), "far": Vector2i(2, 2), "land": Vector2i(1, 2), "dock": Vector2i(1, 3), "size": Vector2i(5, 4)},
		{"name": "west", "src": Vector2i(2, 4), "arrival": 2, "sheer": Vector2i(1, 4), "near": Vector2i(1, 3), "far": Vector2i(1, 2), "land": Vector2i(1, 1), "dock": Vector2i(0, 1), "size": Vector2i(3, 5)},
		{"name": "north", "src": Vector2i(1, 2), "arrival": 3, "sheer": Vector2i(1, 1), "near": Vector2i(2, 1), "far": Vector2i(3, 1), "land": Vector2i(4, 1), "dock": Vector2i(4, 0), "size": Vector2i(5, 3)},
	]
	for spec in jumps:
		var src_at: Vector2i = spec["src"]
		var sheer_at: Vector2i = spec["sheer"]
		var near_at: Vector2i = spec["near"]
		var far_at: Vector2i = spec["far"]
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
			{"type": "sheer", "x": sheer_at.x, "y": sheer_at.y, "dir": 0},
			{"type": "pause", "x": land_at.x, "y": land_at.y, "dir": 0},
		]
		var run: Dictionary = Sim.run(strip, blocks)
		var moved := _frame(run, 3)
		_check(bool(run["success"]) and int(run["cycles"]) == 5, "a %s parcel jumps three cells to the right and the pause follows the old facing" % str(spec["name"]))
		_check(not moved.is_empty() and _at(moved, land_at.x, land_at.y) and _dir_at(moved, land_at.x, land_at.y) == arrival and not _at(moved, near_at.x, near_at.y) and not _at(moved, far_at.x, far_at.y), "a %s parcel still faces %s after the jump and has not entered the two cells to the right" % [str(spec["name"]), str(spec["name"])])
	var held_board := {
		"width": 3, "height": 6, "walls": [{"x": 1, "y": 3}],
		"sources": [
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 1, "y": 5, "dir": 3, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 0, "y": 4},
		"order": [{"color": "gray"}],
	}
	var waiting: Dictionary = Sim.run(held_board, [
		{"type": "sheer", "x": 1, "y": 1, "dir": 0},
		{"type": "pause", "x": 1, "y": 4, "dir": 0},
	])
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a sheer keeps waiting while its landing stays blocked")
	_check(_at(_frame(waiting, 3), 1, 1) and _dir_at(_frame(waiting, 3), 1, 1) == 0 and _color_at(_frame(waiting, 5), 1, 4) == "blue", "the sheer keeps the arrival facing while the other parcel stays")
	var gap := {
		"width": 3, "height": 6, "walls": [],
		"sources": [
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 1, "y": 6, "dir": 3, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 1, "y": 3},
		"order": [{"color": "blue"}, {"color": "gray"}],
	}
	var followed: Dictionary = Sim.run(gap, [
		{"type": "sheer", "x": 1, "y": 1, "dir": 0},
		{"type": "conveyor", "x": 1, "y": 5, "dir": 3},
		{"type": "conveyor", "x": 1, "y": 4, "dir": 3},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 4, "a sheer can land in a cell another parcel is leaving")
	var into := _frame(followed, 3)
	_check(not into.is_empty() and _color_at(into, 1, 4) == "gray" and _dir_at(into, 1, 4) == 0 and into.get("delivered", []).size() == 1, "the jump lands in the cell the other parcel left and still faces east")
	var bricked := {
		"width": 3, "height": 5,
		"walls": [{"x": 2, "y": 2}, {"x": 2, "y": 3}],
		"sources": [{"x": 1, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 2, "y": 4},
		"order": [{"color": "gray"}],
	}
	var through: Dictionary = Sim.run(bricked, [{"type": "sheer", "x": 2, "y": 1, "dir": 0}])
	_check(bool(through["success"]) and int(through["cycles"]) == 3, "bricks in the two cells to the right do not stop the jump")


func _building_twenty() -> void:
	print("building 20")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 148, "building 20 adds routes 142 through 148")
	_check(int(puzzles[140]["id"]) == 141, "route 141 is the last route before the sheer")
	_check(int(puzzles[141]["id"]) == 142, "the sheer begins at route 142")
	_check(Puzzles.INTRO.size() >= 24 and Puzzles.INTRO[23] == "sheer", "the sheer is the block building 20 teaches")
	_check(not Puzzles.unlocked_at(140).has("sheer"), "the sheer stays locked through route 141")
	_check(Puzzles.unlocked_at(141).has("sheer"), "route 142 unlocks the sheer")
	_check(Puzzles.unlocked_at(147).size() == 24, "building 20 ends with every block")
	var pars := {
		142: [4, 4],
		143: [7, 6],
		144: [7, 6],
		145: [5, 3],
		146: [5, 3],
		147: [7, 3],
		148: [17, 16],
	}
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id <= 141:
			_check(int(puzzle.get("building", 1)) < 20, "route %d stays out of building 20" % id)
			if id >= 135:
				_check(int(puzzle.get("building", 1)) == 19, "route %d stays in building 19" % id)
			continue
		if id > 148:
			continue
		_check(int(puzzle.get("building", 1)) == 20, "route %d is building 20" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		var locked: Array = pars[id]
		_check(int(par["cycles"]) == int(locked[0]) and int(par["blocks"]) == int(locked[1]), "route %d par is %d cycles and %d blocks" % [id, int(locked[0]), int(locked[1])])
		if id == 142:
			_check(str(puzzle.get("unlocks", "")) == "sheer", "route 142 teaches the sheer")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_sheer := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "sheer":
				uses_sheer = true
		_check(uses_sheer, "route %d reference uses the sheer" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	for id in [142, 143, 144, 145, 146, 147, 148]:
		for dir in range(4):
			var spun: Array = _by_id(id)["reference"].duplicate(true)
			for block in spun:
				if str(block["type"]) == "sheer":
					block["dir"] = dir
			var spun_run: Dictionary = Sim.run(_by_id(id), spun)
			_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == int(pars[id][0]), "route %d ignores which way the sheer block is rotated" % id)
		for kind in ["sling", "loft", "balk", "keel", "return", "vault", "cant", "conveyor", "pause", "slide", "bridge", "turn", "chute", "hook", "bias", "shunt"]:
			var swapped: Dictionary = Sim.run(_by_id(id), _swap(_by_id(id), "sheer", kind))
			_check(not bool(swapped["success"]), "route %d fails if the sheer is a %s" % [id, kind])
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "sheer":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the sheer is missing" % id)

	var lesson: Dictionary = Sim.run(_by_id(142), _by_id(142)["reference"])
	_check(_at(_frame(lesson, 2), 4, 1) and _dir_at(_frame(lesson, 2), 4, 1) == 0, "route 142 starts the parcel facing east on the sheer")
	_check(_at(_frame(lesson, 3), 4, 1) and _dir_at(_frame(lesson, 3), 4, 1) == 0, "route 142 keeps the parcel facing east without moving it")
	_check(int(lesson["cycles"]) == 4, "route 142 delivers on the jump")
	var lesson_sling: Dictionary = Sim.run(_by_id(142), _swap(_by_id(142), "sheer", "sling"))
	_check(str(lesson_sling["reason"]) == "stuck" and _at(_frame(lesson_sling, 4), 4, 3) and _dir_at(_frame(lesson_sling, 4), 4, 3) == 0, "route 142's sling lands one cell short")
	var lesson_loft: Dictionary = Sim.run(_by_id(142), _swap(_by_id(142), "sheer", "loft"))
	_check(str(lesson_loft["reason"]) == "stuck" and _at(_frame(lesson_loft, 4), 7, 1) and _dir_at(_frame(lesson_loft, 4), 7, 1) == 0, "route 142's loft jumps three cells east")
	var lesson_balk: Dictionary = Sim.run(_by_id(142), _swap(_by_id(142), "sheer", "balk"))
	_check(str(lesson_balk["reason"]) == "stuck", "route 142's balk jumps two cells west")
	var lesson_keel: Dictionary = Sim.run(_by_id(142), _swap(_by_id(142), "sheer", "keel"))
	_check(str(lesson_keel["reason"]) == "stuck", "route 142's keel jumps three cells west")
	var lesson_return: Dictionary = Sim.run(_by_id(142), _swap(_by_id(142), "sheer", "return"))
	_check(str(lesson_return["reason"]) == "tick_cap" and _dir_at(_frame(lesson_return, 3), 4, 1) == 2, "route 142's return reverses the facing")

	var let_sheer: Dictionary = Sim.run(_by_id(143), _by_id(143)["reference"])
	_check(_color_at(_frame(let_sheer, 4), 4, 1) == "red" and _dir_at(_frame(let_sheer, 4), 4, 1) == 0 and _color_at(_frame(let_sheer, 4), 4, 4) == "blue" and _color_at(_frame(let_sheer, 4), 4, 2) == "gray", "route 143 holds red while blue is on the landing and gray sits beside it")
	_check(_color_at(_frame(let_sheer, 5), 4, 4) == "red" and _dir_at(_frame(let_sheer, 5), 4, 4) == 0 and _color_at(_frame(let_sheer, 5), 4, 2) == "gray", "route 143 jumps once the landing is free and still faces east")
	var gray_left := false
	var red_skipped := false
	for frame in let_sheer["frames"]:
		if int(frame["tick"]) >= 1 and _color_at(frame, 4, 2) != "gray":
			gray_left = true
		if _color_at(frame, 4, 2) == "red" or _color_at(frame, 4, 3) == "red":
			red_skipped = true
	_check(not gray_left and not red_skipped, "route 143's sitting parcel does not move and the jump does not enter its cell")

	var counted: Dictionary = Sim.run(_by_id(144), _by_id(144)["reference"])
	_check(str(counted["delivered"][0]["color"]) == "blue" and int(counted["delivered"][0]["count"]) == 1, "route 144 delivers blue count 1")
	_check(str(counted["delivered"][1]["color"]) == "red" and int(counted["delivered"][1]["count"]) == 2, "route 144 delivers red count 2")
	_check(_color_at(_frame(counted, 3), 2, 4) == "red" and _dir_at(_frame(counted, 3), 2, 4) == 0, "route 144 jumps south and still faces east")
	_check(_color_at(_frame(counted, 6), 3, 3) == "red" and _count_at(_frame(counted, 6), 3, 3) == 2, "route 144's counter stamps 2")
	var count_sling: Dictionary = Sim.run(_by_id(144), _swap(_by_id(144), "sheer", "sling"))
	_check(str(count_sling["reason"]) == "wrong_delivery" and str(count_sling["delivered"][0]["color"]) == "red" and int(count_sling["delivered"][0]["count"]) == 1, "route 144's sling is stamped wrong")

	var clear: Dictionary = Sim.run(_by_id(145), _by_id(145)["reference"])
	_check(_color_at(_frame(clear, 4), 2, 1) == "gray" and _dir_at(_frame(clear, 4), 2, 1) == 0 and _color_at(_frame(clear, 4), 2, 3) == "blue", "route 145 waits while a parcel stays to the right")
	_check(int(clear["cycles"]) == 5 and _color_at(_frame(clear, 5), 2, 3) == "blue", "route 145 lands three cells to the right and leaves the sitting parcel")
	var brick_entered := false
	for frame in clear["frames"]:
		if _at(frame, 2, 2):
			brick_entered = true
	_check(not brick_entered, "route 145 does not enter the brick immediately to the right")
	_check(str(Sim.run(_by_id(145), _swap(_by_id(145), "sheer", "sling"))["reason"]) == "tick_cap", "route 145's sling tries to land on the staying parcel")
	_check(not bool(Sim.run(_by_id(145), _swap(_by_id(145), "sheer", "return"))["success"]), "route 145's return steps back instead of to the right")

	var paired: Dictionary = Sim.run(_by_id(146), _by_id(146)["reference"])
	_check(_color_at(_frame(paired, 2), 4, 0) == "red" and _dir_at(_frame(paired, 2), 4, 0) == 0, "route 146 holds the east-facing parcel")
	_check(_color_at(_frame(paired, 4), 1, 3) == "blue" and _dir_at(_frame(paired, 4), 1, 3) == 3, "route 146 holds the north-facing parcel")
	_check(_frame(paired, 3).get("delivered", []).size() == 1 and str(_frame(paired, 3)["delivered"][0]["color"]) == "red", "route 146 jumps the east-facing parcel onto the dock")
	_check(int(paired["cycles"]) == 5, "route 146 jumps the north-facing parcel onto the dock")
	for cell in [Vector2i(4, 0), Vector2i(1, 3)]:
		for kind in ["sling", "loft", "balk", "keel"]:
			var one: Dictionary = Sim.run(_by_id(146), _swap_cell(_by_id(146), cell.x, cell.y, kind))
			_check(not bool(one["success"]), "route 146 misses the dock if the sheer at %d,%d is a %s" % [cell.x, cell.y, kind])

	var second: Dictionary = Sim.run(_by_id(147), _by_id(147)["reference"])
	_check(_at(_frame(second, 2), 3, 1) and _dir_at(_frame(second, 2), 3, 1) == 0, "route 147 waits on the first sheer facing east")
	_check(_at(_frame(second, 3), 3, 4) and _dir_at(_frame(second, 3), 3, 4) == 0, "route 147 jumps to the right and still faces east")
	_check(_at(_frame(second, 5), 3, 5) and _dir_at(_frame(second, 5), 3, 5) == 1, "route 147 reaches the second sheer facing south")
	_check(_at(_frame(second, 6), 3, 5) and _dir_at(_frame(second, 6), 3, 5) == 1, "route 147 waits on the second sheer facing south")
	_check(int(second["cycles"]) == 7, "route 147 jumps to the right on the new facing")
	_check(not bool(Sim.run(_by_id(147), _omit_cell(_by_id(147), 3, 1))["success"]), "route 147 fails without the first sheer")
	_check(not bool(Sim.run(_by_id(147), _omit_cell(_by_id(147), 3, 5))["success"]), "route 147 fails without the second sheer")

	var night: Dictionary = Sim.run(_by_id(148), _by_id(148)["reference"])
	_check(int(night["cycles"]) < 250, "route 148 finishes before tick 250")
	_check(str(night["delivered"][0]["color"]) == "red" and int(night["delivered"][0]["count"]) == 1, "route 148 stamps red 1")
	_check(str(night["delivered"][1]["color"]) == "yellow" and int(night["delivered"][1]["count"]) == 2, "route 148 stamps yellow 2")
	_check(str(night["delivered"][2]["color"]) == "blue" and int(night["delivered"][2]["count"]) == 3, "route 148 stamps blue 3")
	_check(_color_at(_frame(night, 9), 4, 1) == "red" and _dir_at(_frame(night, 9), 4, 1) == 0, "route 148 holds red facing east")
	_check(_color_at(_frame(night, 10), 4, 4) == "red" and _dir_at(_frame(night, 10), 4, 4) == 0, "route 148 jumps red onto the counter and leaves it facing east")
	var night_entered := false
	for frame in night["frames"]:
		if _color_at(frame, 4, 2) == "red" or _color_at(frame, 4, 3) == "red":
			night_entered = true
	_check(not night_entered, "route 148 does not enter the two cells to the right")
	var night_sling: Dictionary = Sim.run(_by_id(148), _swap(_by_id(148), "sheer", "sling"))
	_check(not bool(night_sling["success"]), "route 148's sling misses the counter")
	_check(not bool(Sim.run(_by_id(148), _swap(_by_id(148), "primer", "painter"))["success"]), "route 148 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(148), _swap(_by_id(148), "filter", "conveyor"))["success"]), "route 148 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(148), _swap(_by_id(148), "counter", "conveyor"))["success"]), "route 148 fails without the counter")


func _strake_rules() -> void:
	print("strake")
	var hop := {
		"width": 3, "height": 3, "walls": [],
		"sources": [{"x": 1, "y": 2, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 2, "y": 0},
		"order": [{"color": "gray"}],
	}
	var graph := [{"type": "strake", "x": 2, "y": 2, "dir": 0}]
	var sent: Dictionary = Sim.run(hop, graph)
	_check(bool(sent["success"]), "a strake jumps two cells to the left and the kept facing delivers")
	_check(int(sent["cycles"]) == 3 and int(sent["blocks"]) == 1, "the strake waits a tick and delivers on tick 3")
	var born := _frame(sent, 1)
	var waited := _frame(sent, 2)
	_check(not born.is_empty() and _at(born, 2, 2) and _dir_at(born, 2, 2) == 0, "the parcel arrives facing east")
	_check(not waited.is_empty() and _at(waited, 2, 2) and _dir_at(waited, 2, 2) == 0 and not _at(waited, 2, 0), "the strake does not move the parcel on that tick")
	_check(_count_at(waited, 2, 2) == 0 and _color_at(waited, 2, 2) == "gray", "a strake does not stamp or paint")
	var crossed := false
	for frame in sent["frames"]:
		if _at(frame, 2, 1):
			crossed = true
	_check(not crossed, "the strake does not enter the cell immediately to the left")
	var tinted: Dictionary = Sim.run(hop, [{"type": "strake", "x": 2, "y": 2, "dir": 0, "color": "red"}])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a strake is ignored")
	for dir in range(4):
		var spun: Array = graph.duplicate(true)
		spun[0]["dir"] = dir
		var spun_run: Dictionary = Sim.run(hop, spun)
		_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == 3, "rotating a strake does not change the jump")
	var over_bin: Dictionary = Sim.run(hop, [
		{"type": "strake", "x": 2, "y": 2, "dir": 0},
		{"type": "bin", "x": 2, "y": 1, "dir": 0},
	])
	_check(bool(over_bin["success"]) and int(over_bin["cycles"]) == 3, "a bin in the skipped cell does not stop the two-cell jump")
	var biased: Dictionary = Sim.run(hop, [
		{"type": "bias", "x": 2, "y": 2, "dir": 0},
		{"type": "bin", "x": 2, "y": 1, "dir": 0},
	])
	_check(not bool(biased["success"]) and _at(_frame(biased, 3), 2, 1) and _dir_at(_frame(biased, 3), 2, 1) == 0 and not _at(_frame(biased, 3), 2, 0), "a bias lands one cell short of a strake")
	var lofted: Dictionary = Sim.run(hop, [{"type": "loft", "x": 2, "y": 2, "dir": 0}])
	_check(not bool(lofted["success"]) and str(lofted["reason"]) == "stuck", "a loft jumps three cells east and misses the leftward jump")
	var balked: Dictionary = Sim.run(hop, [{"type": "balk", "x": 2, "y": 2, "dir": 0}])
	_check(not bool(balked["success"]) and str(balked["reason"]) == "stuck", "a balk jumps two cells west and misses the leftward jump")
	var keeled: Dictionary = Sim.run(hop, [{"type": "keel", "x": 2, "y": 2, "dir": 0}])
	_check(not bool(keeled["success"]) and str(keeled["reason"]) == "stuck", "a keel jumps three cells west and misses the leftward jump")
	var sheered: Dictionary = Sim.run(hop, [{"type": "sheer", "x": 2, "y": 2, "dir": 0}])
	_check(not bool(sheered["success"]) and str(sheered["reason"]) == "stuck", "a sheer jumps three cells south and misses the leftward jump")
	var returned: Dictionary = Sim.run(hop, [{"type": "return", "x": 2, "y": 2, "dir": 0}])
	_check(not bool(returned["success"]) and str(returned["reason"]) == "stuck", "a return reverses the facing and cannot step through the source")
	_check(_at(_frame(returned, 2), 2, 2) and _dir_at(_frame(returned, 2), 2, 2) == 2, "the return is facing west on the strake cell")
	var jumps := [
		{"name": "east", "src": Vector2i(1, 3), "arrival": 0, "strake": Vector2i(2, 3), "near": Vector2i(2, 2), "land": Vector2i(2, 1), "dock": Vector2i(3, 1), "size": Vector2i(4, 4)},
		{"name": "south", "src": Vector2i(1, 1), "arrival": 1, "strake": Vector2i(1, 2), "near": Vector2i(2, 2), "land": Vector2i(3, 2), "dock": Vector2i(3, 3), "size": Vector2i(4, 4)},
		{"name": "west", "src": Vector2i(2, 1), "arrival": 2, "strake": Vector2i(1, 1), "near": Vector2i(1, 2), "land": Vector2i(1, 3), "dock": Vector2i(0, 3), "size": Vector2i(3, 4)},
		{"name": "north", "src": Vector2i(3, 2), "arrival": 3, "strake": Vector2i(3, 1), "near": Vector2i(2, 1), "land": Vector2i(1, 1), "dock": Vector2i(1, 0), "size": Vector2i(4, 3)},
	]
	for spec in jumps:
		var src_at: Vector2i = spec["src"]
		var strake_at: Vector2i = spec["strake"]
		var near_at: Vector2i = spec["near"]
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
			{"type": "strake", "x": strake_at.x, "y": strake_at.y, "dir": 0},
			{"type": "pause", "x": land_at.x, "y": land_at.y, "dir": 0},
		]
		var side_run: Dictionary = Sim.run(strip, blocks)
		var moved := _frame(side_run, 3)
		_check(bool(side_run["success"]) and int(side_run["cycles"]) == 5, "a %s parcel jumps two cells to the left and the pause follows the old facing" % str(spec["name"]))
		_check(not moved.is_empty() and _at(moved, land_at.x, land_at.y) and _dir_at(moved, land_at.x, land_at.y) == arrival and not _at(moved, near_at.x, near_at.y), "a %s parcel still faces %s after the jump and has not entered the cell to the left" % [str(spec["name"]), str(spec["name"])])
	var held_board := {
		"width": 3, "height": 4, "walls": [{"x": 0, "y": 0}],
		"sources": [
			{"x": 0, "y": 2, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 2, "y": 0, "dir": 2, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 0, "y": 2},
		"order": [{"color": "gray"}],
	}
	var waiting: Dictionary = Sim.run(held_board, [
		{"type": "strake", "x": 1, "y": 2, "dir": 0},
		{"type": "pause", "x": 1, "y": 0, "dir": 0},
	])
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a strake keeps waiting while its landing stays blocked")
	_check(_at(_frame(waiting, 3), 1, 2) and _dir_at(_frame(waiting, 3), 1, 2) == 0 and _color_at(_frame(waiting, 5), 1, 0) == "blue", "the strake keeps the arrival facing while the other parcel stays")
	var gap := {
		"width": 4, "height": 4, "walls": [],
		"sources": [
			{"x": 0, "y": 3, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 3, "y": 1, "dir": 2, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 1, "y": 0},
		"order": [{"color": "blue"}, {"color": "gray"}],
	}
	var followed: Dictionary = Sim.run(gap, [
		{"type": "strake", "x": 1, "y": 3, "dir": 0},
		{"type": "conveyor", "x": 2, "y": 1, "dir": 2},
		{"type": "conveyor", "x": 1, "y": 1, "dir": 3},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 4, "a strake can land in a cell another parcel is leaving")
	var into := _frame(followed, 3)
	_check(not into.is_empty() and _color_at(into, 1, 1) == "gray" and _dir_at(into, 1, 1) == 0 and into.get("delivered", []).size() == 1, "the jump lands in the cell the other parcel left and still faces east")
	var bricked := {
		"width": 3, "height": 4,
		"walls": [{"x": 2, "y": 2}],
		"sources": [{"x": 1, "y": 3, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 2, "y": 1},
		"order": [{"color": "gray"}],
	}
	var through: Dictionary = Sim.run(bricked, [{"type": "strake", "x": 2, "y": 3, "dir": 0}])
	_check(bool(through["success"]) and int(through["cycles"]) == 3, "a brick in the cell to the left does not stop the jump")


func _building_twenty_one() -> void:
	print("building 21")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 155, "building 21 adds routes 149 through 155")
	_check(int(puzzles[147]["id"]) == 148, "route 148 is the last route before the strake")
	_check(int(puzzles[148]["id"]) == 149, "the strake begins at route 149")
	_check(Puzzles.INTRO.size() >= 25 and Puzzles.INTRO[24] == "strake", "the strake is the block building 21 teaches")
	_check(not Puzzles.unlocked_at(147).has("strake"), "the strake stays locked through route 148")
	_check(Puzzles.unlocked_at(148).has("strake"), "route 149 unlocks the strake")
	_check(Puzzles.unlocked_at(154).size() == 25, "building 21 ends with every block")
	var pars := {
		149: [4, 3],
		150: [7, 6],
		151: [7, 5],
		152: [4, 3],
		153: [5, 3],
		154: [7, 3],
		155: [15, 14],
	}
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id <= 148:
			_check(int(puzzle.get("building", 1)) < 21, "route %d stays out of building 21" % id)
			if id >= 142:
				_check(int(puzzle.get("building", 1)) == 20, "route %d stays in building 20" % id)
			continue
		if id > 155:
			continue
		_check(int(puzzle.get("building", 1)) == 21, "route %d is building 21" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		var locked: Array = pars[id]
		_check(int(par["cycles"]) == int(locked[0]) and int(par["blocks"]) == int(locked[1]), "route %d par is %d cycles and %d blocks" % [id, int(locked[0]), int(locked[1])])
		if id == 149:
			_check(str(puzzle.get("unlocks", "")) == "strake", "route 149 teaches the strake")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_strake := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "strake":
				uses_strake = true
		_check(uses_strake, "route %d reference uses the strake" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	for id in [149, 150, 151, 152, 153, 154, 155]:
		for dir in range(4):
			var spun: Array = _by_id(id)["reference"].duplicate(true)
			for block in spun:
				if str(block["type"]) == "strake":
					block["dir"] = dir
			var spun_run: Dictionary = Sim.run(_by_id(id), spun)
			_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == int(pars[id][0]), "route %d ignores which way the strake block is rotated" % id)
		for kind in ["bias", "sling", "loft", "balk", "keel", "sheer", "return", "vault", "conveyor", "pause", "slide", "bridge", "turn", "chute", "hook", "shunt"]:
			var swapped: Dictionary = Sim.run(_by_id(id), _swap(_by_id(id), "strake", kind))
			_check(not bool(swapped["success"]), "route %d fails if the strake is a %s" % [id, kind])
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "strake":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the strake is missing" % id)

	var lesson: Dictionary = Sim.run(_by_id(149), _by_id(149)["reference"])
	_check(_at(_frame(lesson, 2), 4, 3) and _dir_at(_frame(lesson, 2), 4, 3) == 0, "route 149 starts the parcel facing east on the strake")
	_check(_at(_frame(lesson, 3), 4, 3) and _dir_at(_frame(lesson, 3), 4, 3) == 0, "route 149 keeps the parcel facing east without moving it")
	_check(int(lesson["cycles"]) == 4, "route 149 delivers on the jump")
	var brick_entered := false
	for frame in lesson["frames"]:
		if _at(frame, 4, 2):
			brick_entered = true
	_check(not brick_entered, "route 149 does not enter the brick immediately to the left")
	_check(str(Sim.run(_by_id(149), _swap(_by_id(149), "strake", "bias"))["reason"]) == "stuck", "route 149's bias tries to step into the brick")
	_check(str(Sim.run(_by_id(149), _swap(_by_id(149), "strake", "loft"))["reason"]) == "stuck", "route 149's loft jumps three cells east")
	_check(str(Sim.run(_by_id(149), _swap(_by_id(149), "strake", "sheer"))["reason"]) == "stuck", "route 149's sheer jumps three cells south")
	var lesson_return: Dictionary = Sim.run(_by_id(149), _swap(_by_id(149), "strake", "return"))
	_check(str(lesson_return["reason"]) == "tick_cap" and _dir_at(_frame(lesson_return, 3), 4, 3) == 2, "route 149's return reverses the facing")

	var let_strake: Dictionary = Sim.run(_by_id(150), _by_id(150)["reference"])
	_check(_color_at(_frame(let_strake, 4), 4, 3) == "red" and _dir_at(_frame(let_strake, 4), 4, 3) == 0 and _color_at(_frame(let_strake, 4), 4, 1) == "blue" and _color_at(_frame(let_strake, 4), 4, 2) == "gray", "route 150 holds red while blue is on the landing and gray sits beside it")
	_check(_color_at(_frame(let_strake, 5), 4, 1) == "red" and _dir_at(_frame(let_strake, 5), 4, 1) == 0 and _color_at(_frame(let_strake, 5), 4, 2) == "gray", "route 150 jumps once the landing is free and still faces east")
	var gray_left := false
	var red_skipped := false
	for frame in let_strake["frames"]:
		if int(frame["tick"]) >= 1 and _color_at(frame, 4, 2) != "gray":
			gray_left = true
		if _color_at(frame, 4, 2) == "red":
			red_skipped = true
	_check(not gray_left and not red_skipped, "route 150's sitting parcel does not move and the jump does not enter its cell")

	var counted: Dictionary = Sim.run(_by_id(151), _by_id(151)["reference"])
	_check(str(counted["delivered"][0]["color"]) == "blue" and int(counted["delivered"][0]["count"]) == 1, "route 151 delivers blue count 1")
	_check(str(counted["delivered"][1]["color"]) == "red" and int(counted["delivered"][1]["count"]) == 2, "route 151 delivers red count 2")
	_check(_color_at(_frame(counted, 3), 2, 1) == "red" and _dir_at(_frame(counted, 3), 2, 1) == 0, "route 151 jumps north and still faces east")
	_check(_color_at(_frame(counted, 6), 3, 2) == "red" and _count_at(_frame(counted, 6), 3, 2) == 2, "route 151's counter stamps 2")
	_check(str(Sim.run(_by_id(151), _swap(_by_id(151), "strake", "bias"))["reason"]) == "tick_cap", "route 151's bias tries to land on the counter")

	var clear: Dictionary = Sim.run(_by_id(152), _by_id(152)["reference"])
	_check(_color_at(_frame(clear, 3), 2, 3) == "gray" and _dir_at(_frame(clear, 3), 2, 3) == 0 and _color_at(_frame(clear, 3), 2, 2) == "blue", "route 152 waits while a parcel stays to the left")
	_check(int(clear["cycles"]) == 4 and _color_at(_frame(clear, 4), 2, 2) == "blue", "route 152 lands two cells to the left and leaves the sitting parcel")
	_check(str(Sim.run(_by_id(152), _swap(_by_id(152), "strake", "bias"))["reason"]) == "tick_cap", "route 152's bias tries to land on the staying parcel")

	var paired: Dictionary = Sim.run(_by_id(153), _by_id(153)["reference"])
	_check(_color_at(_frame(paired, 2), 4, 3) == "red" and _dir_at(_frame(paired, 2), 4, 3) == 0, "route 153 holds the east-facing parcel")
	_check(_color_at(_frame(paired, 4), 6, 1) == "blue" and _dir_at(_frame(paired, 4), 6, 1) == 3, "route 153 holds the north-facing parcel")
	_check(_frame(paired, 3).get("delivered", []).size() == 1 and str(_frame(paired, 3)["delivered"][0]["color"]) == "red", "route 153 jumps the east-facing parcel onto the dock")
	_check(int(paired["cycles"]) == 5, "route 153 jumps the north-facing parcel onto the dock")
	for cell in [Vector2i(4, 3), Vector2i(6, 1)]:
		for kind in ["bias", "loft", "balk", "keel", "sheer"]:
			var one: Dictionary = Sim.run(_by_id(153), _swap_cell(_by_id(153), cell.x, cell.y, kind))
			_check(not bool(one["success"]), "route 153 misses the dock if the strake at %d,%d is a %s" % [cell.x, cell.y, kind])

	var second: Dictionary = Sim.run(_by_id(154), _by_id(154)["reference"])
	_check(_at(_frame(second, 2), 3, 5) and _dir_at(_frame(second, 2), 3, 5) == 0, "route 154 waits on the first strake facing east")
	_check(_at(_frame(second, 3), 3, 3) and _dir_at(_frame(second, 3), 3, 3) == 0, "route 154 jumps to the left and still faces east")
	_check(_at(_frame(second, 5), 3, 4) and _dir_at(_frame(second, 5), 3, 4) == 1, "route 154 reaches the second strake facing south")
	_check(_at(_frame(second, 6), 3, 4) and _dir_at(_frame(second, 6), 3, 4) == 1, "route 154 waits on the second strake facing south")
	_check(int(second["cycles"]) == 7, "route 154 jumps to the left on the new facing")
	_check(not bool(Sim.run(_by_id(154), _omit_cell(_by_id(154), 3, 5))["success"]), "route 154 fails without the first strake")
	_check(not bool(Sim.run(_by_id(154), _omit_cell(_by_id(154), 3, 4))["success"]), "route 154 fails without the second strake")

	var night: Dictionary = Sim.run(_by_id(155), _by_id(155)["reference"])
	_check(int(night["cycles"]) < 250, "route 155 finishes before tick 250")
	_check(str(night["delivered"][0]["color"]) == "red" and int(night["delivered"][0]["count"]) == 1, "route 155 stamps red 1")
	_check(str(night["delivered"][1]["color"]) == "yellow" and int(night["delivered"][1]["count"]) == 2, "route 155 stamps yellow 2")
	_check(str(night["delivered"][2]["color"]) == "blue" and int(night["delivered"][2]["count"]) == 3, "route 155 stamps blue 3")
	_check(_color_at(_frame(night, 7), 4, 4) == "red" and _dir_at(_frame(night, 7), 4, 4) == 0, "route 155 holds red facing east")
	_check(_color_at(_frame(night, 8), 4, 2) == "red" and _dir_at(_frame(night, 8), 4, 2) == 0, "route 155 jumps red onto the counter and leaves it facing east")
	var night_entered := false
	for frame in night["frames"]:
		if _color_at(frame, 4, 3) == "red":
			night_entered = true
	_check(not night_entered, "route 155 does not enter the cell to the left")
	_check(not bool(Sim.run(_by_id(155), _swap(_by_id(155), "strake", "bias"))["success"]), "route 155's bias misses the counter")
	_check(not bool(Sim.run(_by_id(155), _swap(_by_id(155), "primer", "painter"))["success"]), "route 155 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(155), _swap(_by_id(155), "filter", "conveyor"))["success"]), "route 155 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(155), _swap(_by_id(155), "counter", "conveyor"))["success"]), "route 155 fails without the counter")


func _wale_rules() -> void:
	print("wale")
	var hop := {
		"width": 3, "height": 4, "walls": [],
		"sources": [{"x": 1, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 2, "y": 2},
		"order": [{"color": "gray"}],
	}
	var graph := [{"type": "wale", "x": 2, "y": 1, "dir": 0}]
	var sent: Dictionary = Sim.run(hop, graph)
	_check(bool(sent["success"]), "a wale jumps one cell to the right and delivers")
	_check(int(sent["cycles"]) == 3 and int(sent["blocks"]) == 1, "the wale waits a tick and delivers on tick 3")
	var born := _frame(sent, 1)
	var waited := _frame(sent, 2)
	_check(not born.is_empty() and _at(born, 2, 1) and _dir_at(born, 2, 1) == 0, "the parcel arrives facing east")
	_check(not waited.is_empty() and _at(waited, 2, 1) and _dir_at(waited, 2, 1) == 0 and not _at(waited, 2, 2), "the wale does not move the parcel on that tick")
	_check(_count_at(waited, 2, 1) == 0 and _color_at(waited, 2, 1) == "gray", "a wale does not stamp or paint")
	var tinted: Dictionary = Sim.run(hop, [{"type": "wale", "x": 2, "y": 1, "dir": 0, "color": "red"}])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a wale is ignored")
	for dir in range(4):
		var spun: Array = graph.duplicate(true)
		spun[0]["dir"] = dir
		var spun_run: Dictionary = Sim.run(hop, spun)
		_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == 3, "rotating a wale does not change the jump")
	var over_bin: Dictionary = Sim.run(hop, [
		{"type": "wale", "x": 2, "y": 1, "dir": 0},
		{"type": "bin", "x": 2, "y": 3, "dir": 0},
	])
	_check(bool(over_bin["success"]) and int(over_bin["cycles"]) == 3, "a bin one cell past the landing does not stop the wale")
	var slung: Dictionary = Sim.run(hop, [
		{"type": "sling", "x": 2, "y": 1, "dir": 0},
		{"type": "bin", "x": 2, "y": 3, "dir": 0},
	])
	_check(not bool(slung["success"]) and _at(_frame(slung, 3), 2, 3) and _dir_at(_frame(slung, 3), 2, 3) == 0 and not _at(_frame(slung, 3), 2, 2), "a sling lands one cell past a wale")
	var lofted: Dictionary = Sim.run(hop, [{"type": "loft", "x": 2, "y": 1, "dir": 0}])
	_check(not bool(lofted["success"]) and str(lofted["reason"]) == "stuck", "a loft jumps three cells east and misses the rightward step")
	var balked: Dictionary = Sim.run(hop, [{"type": "balk", "x": 2, "y": 1, "dir": 0}])
	_check(not bool(balked["success"]) and str(balked["reason"]) == "stuck", "a balk jumps two cells west and misses the rightward step")
	var keeled: Dictionary = Sim.run(hop, [{"type": "keel", "x": 2, "y": 1, "dir": 0}])
	_check(not bool(keeled["success"]) and str(keeled["reason"]) == "stuck", "a keel jumps three cells west and misses the rightward step")
	var sheered: Dictionary = Sim.run(hop, [{"type": "sheer", "x": 2, "y": 1, "dir": 0}])
	_check(not bool(sheered["success"]) and str(sheered["reason"]) == "stuck", "a sheer jumps three cells south and misses the one-cell step")
	var straked: Dictionary = Sim.run(hop, [{"type": "strake", "x": 2, "y": 1, "dir": 0}])
	_check(not bool(straked["success"]) and str(straked["reason"]) == "stuck", "a strake jumps two cells north and misses the rightward step")
	var returned: Dictionary = Sim.run(hop, [{"type": "return", "x": 2, "y": 1, "dir": 0}])
	_check(not bool(returned["success"]) and str(returned["reason"]) == "stuck", "a return reverses the facing and cannot step through the source")
	_check(_at(_frame(returned, 2), 2, 1) and _dir_at(_frame(returned, 2), 2, 1) == 2, "the return is facing west on the wale cell")
	var jumps := [
		{"name": "east", "src": Vector2i(1, 1), "arrival": 0, "wale": Vector2i(2, 1), "land": Vector2i(2, 2), "dock": Vector2i(3, 2), "size": Vector2i(4, 4)},
		{"name": "south", "src": Vector2i(3, 1), "arrival": 1, "wale": Vector2i(3, 2), "land": Vector2i(2, 2), "dock": Vector2i(2, 3), "size": Vector2i(4, 4)},
		{"name": "west", "src": Vector2i(2, 3), "arrival": 2, "wale": Vector2i(1, 3), "land": Vector2i(1, 2), "dock": Vector2i(0, 2), "size": Vector2i(3, 4)},
		{"name": "north", "src": Vector2i(1, 2), "arrival": 3, "wale": Vector2i(1, 1), "land": Vector2i(2, 1), "dock": Vector2i(2, 0), "size": Vector2i(4, 3)},
	]
	for spec in jumps:
		var src_at: Vector2i = spec["src"]
		var wale_at: Vector2i = spec["wale"]
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
			{"type": "wale", "x": wale_at.x, "y": wale_at.y, "dir": 0},
			{"type": "pause", "x": land_at.x, "y": land_at.y, "dir": 0},
		]
		var side_run: Dictionary = Sim.run(strip, blocks)
		var moved := _frame(side_run, 3)
		_check(bool(side_run["success"]) and int(side_run["cycles"]) == 5, "a %s parcel jumps one cell to the right and the pause follows the old facing" % str(spec["name"]))
		_check(not moved.is_empty() and _at(moved, land_at.x, land_at.y) and _dir_at(moved, land_at.x, land_at.y) == arrival, "a %s parcel still faces %s after the one-cell jump" % [str(spec["name"]), str(spec["name"])])
	var held_board := {
		"width": 3, "height": 4, "walls": [{"x": 0, "y": 2}],
		"sources": [
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 2, "y": 2, "dir": 2, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 2, "y": 0},
		"order": [{"color": "gray"}],
	}
	var waiting: Dictionary = Sim.run(held_board, [
		{"type": "wale", "x": 1, "y": 1, "dir": 0},
		{"type": "pause", "x": 1, "y": 2, "dir": 0},
	])
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a wale keeps waiting while its landing stays blocked")
	_check(_at(_frame(waiting, 3), 1, 1) and _dir_at(_frame(waiting, 3), 1, 1) == 0 and _color_at(_frame(waiting, 5), 1, 2) == "blue", "the wale keeps the arrival facing while the other parcel stays")
	var gap := {
		"width": 3, "height": 4, "walls": [],
		"sources": [
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 0, "y": 2, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 2, "y": 2},
		"order": [{"color": "blue"}, {"color": "gray"}],
	}
	var followed: Dictionary = Sim.run(gap, [
		{"type": "wale", "x": 1, "y": 1, "dir": 0},
		{"type": "pause", "x": 1, "y": 2, "dir": 0},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 5, "a wale can land in a cell another parcel is leaving")
	var into := _frame(followed, 3)
	_check(not into.is_empty() and _color_at(into, 1, 2) == "gray" and _dir_at(into, 1, 2) == 0 and into.get("delivered", []).size() == 1, "the jump lands in the cell the other parcel left and still faces east")


func _building_twenty_two() -> void:
	print("building 22")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 162, "building 22 adds routes 156 through 162")
	_check(int(puzzles[154]["id"]) == 155, "route 155 is the last route before the wale")
	_check(int(puzzles[155]["id"]) == 156, "the wale begins at route 156")
	_check(Puzzles.INTRO.size() >= 26 and Puzzles.INTRO[25] == "wale", "the wale is the block building 22 teaches")
	_check(not Puzzles.unlocked_at(154).has("wale"), "the wale stays locked through route 155")
	_check(Puzzles.unlocked_at(155).has("wale"), "route 156 unlocks the wale")
	_check(Puzzles.unlocked_at(161).size() == 26, "building 22 ends with every block")
	var pars := {
		156: [6, 4],
		157: [7, 5],
		158: [7, 4],
		159: [6, 3],
		160: [6, 5],
		161: [7, 3],
		162: [15, 13],
	}
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id <= 155:
			_check(int(puzzle.get("building", 1)) < 22, "route %d stays out of building 22" % id)
			if id >= 149:
				_check(int(puzzle.get("building", 1)) == 21, "route %d stays in building 21" % id)
			continue
		if id > 162:
			continue
		_check(int(puzzle.get("building", 1)) == 22, "route %d is building 22" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		var locked: Array = pars[id]
		_check(int(par["cycles"]) == int(locked[0]) and int(par["blocks"]) == int(locked[1]), "route %d par is %d cycles and %d blocks" % [id, int(locked[0]), int(locked[1])])
		if id == 156:
			_check(str(puzzle.get("unlocks", "")) == "wale", "route 156 teaches the wale")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_wale := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "wale":
				uses_wale = true
		_check(uses_wale, "route %d reference uses the wale" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	for id in [156, 157, 158, 159, 160, 161, 162]:
		for dir in range(4):
			var spun: Array = _by_id(id)["reference"].duplicate(true)
			for block in spun:
				if str(block["type"]) == "wale":
					block["dir"] = dir
			var spun_run: Dictionary = Sim.run(_by_id(id), spun)
			_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == int(pars[id][0]), "route %d ignores which way the wale block is rotated" % id)
		for kind in ["bias", "sling", "loft", "balk", "keel", "sheer", "strake", "return", "vault", "conveyor", "pause", "slide", "bridge", "turn", "chute", "hook"]:
			var swapped: Dictionary = Sim.run(_by_id(id), _swap(_by_id(id), "wale", kind))
			_check(not bool(swapped["success"]), "route %d fails if the wale is a %s" % [id, kind])
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "wale":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the wale is missing" % id)

	var lesson: Dictionary = Sim.run(_by_id(156), _by_id(156)["reference"])
	_check(_at(_frame(lesson, 2), 4, 1) and _dir_at(_frame(lesson, 2), 4, 1) == 0, "route 156 starts the parcel facing east on the wale")
	_check(_at(_frame(lesson, 3), 4, 1) and _dir_at(_frame(lesson, 3), 4, 1) == 0, "route 156 keeps the parcel facing east without moving it")
	_check(_at(_frame(lesson, 4), 4, 2) and _dir_at(_frame(lesson, 4), 4, 2) == 0, "route 156 jumps one cell south and still faces east")
	_check(int(lesson["cycles"]) == 6, "route 156 delivers after the pause follows the kept facing")
	_check(str(Sim.run(_by_id(156), _swap(_by_id(156), "wale", "sling"))["reason"]) == "stuck", "route 156's sling jumps one cell too far")
	_check(str(Sim.run(_by_id(156), _swap(_by_id(156), "wale", "turn"))["reason"]) == "stuck", "route 156's turn faces south and misses the dock")
	var lesson_return: Dictionary = Sim.run(_by_id(156), _swap(_by_id(156), "wale", "return"))
	_check(str(lesson_return["reason"]) == "tick_cap" and _dir_at(_frame(lesson_return, 3), 4, 1) == 2, "route 156's return reverses the facing")

	var let_wale: Dictionary = Sim.run(_by_id(157), _by_id(157)["reference"])
	_check(_color_at(_frame(let_wale, 4), 4, 1) == "red" and _dir_at(_frame(let_wale, 4), 4, 1) == 0 and _color_at(_frame(let_wale, 4), 4, 2) == "blue", "route 157 holds red while blue stands on the landing")
	_check(_color_at(_frame(let_wale, 5), 4, 2) == "red" and _dir_at(_frame(let_wale, 5), 4, 2) == 0 and _frame(let_wale, 5).get("delivered", []).size() == 1, "route 157 jumps once the landing is free and still faces east")

	var counted: Dictionary = Sim.run(_by_id(158), _by_id(158)["reference"])
	_check(str(counted["delivered"][0]["color"]) == "blue" and int(counted["delivered"][0]["count"]) == 1, "route 158 delivers blue count 1")
	_check(str(counted["delivered"][1]["color"]) == "red" and int(counted["delivered"][1]["count"]) == 2, "route 158 delivers red count 2")
	_check(_color_at(_frame(counted, 3), 2, 2) == "red" and _dir_at(_frame(counted, 3), 2, 2) == 0, "route 158 jumps south and still faces east")
	_check(_color_at(_frame(counted, 6), 4, 2) == "red" and _count_at(_frame(counted, 6), 4, 2) == 2, "route 158's counter stamps 2")
	_check(str(Sim.run(_by_id(158), _swap(_by_id(158), "wale", "sling"))["reason"]) == "stuck", "route 158's sling jumps past the pause")

	var clear: Dictionary = Sim.run(_by_id(159), _by_id(159)["reference"])
	_check(_at(_frame(clear, 3), 2, 1) and _dir_at(_frame(clear, 3), 2, 1) == 0, "route 159 waits facing east")
	_check(_at(_frame(clear, 4), 2, 2) and _dir_at(_frame(clear, 4), 2, 2) == 0, "route 159 lands one cell south and still faces east")
	_check(int(clear["cycles"]) == 6, "route 159 delivers after the pause steps east")
	var brick_entered := false
	for frame in clear["frames"]:
		if _at(frame, 2, 3):
			brick_entered = true
	_check(not brick_entered, "route 159 does not enter the brick past the landing")
	_check(str(Sim.run(_by_id(159), _swap(_by_id(159), "wale", "sling"))["reason"]) == "stuck", "route 159's sling tries to land on the brick")
	_check(str(Sim.run(_by_id(159), _swap(_by_id(159), "wale", "turn"))["reason"]) == "stuck", "route 159's turn steps into the brick")

	var paired: Dictionary = Sim.run(_by_id(160), _by_id(160)["reference"])
	_check(_color_at(_frame(paired, 2), 4, 1) == "red" and _dir_at(_frame(paired, 2), 4, 1) == 0, "route 160 holds the east-facing parcel")
	_check(_color_at(_frame(paired, 4), 5, 3) == "blue" and _dir_at(_frame(paired, 4), 5, 3) == 3, "route 160 holds the north-facing parcel")
	_check(_frame(paired, 5).get("delivered", []).size() == 1 and str(_frame(paired, 5)["delivered"][0]["color"]) == "red", "route 160 delivers the east-facing parcel first")
	_check(int(paired["cycles"]) == 6, "route 160 delivers the north-facing parcel second")
	for cell in [Vector2i(4, 1), Vector2i(4, 3)]:
		for kind in ["sling", "turn", "strake", "sheer", "loft", "balk", "keel"]:
			var one: Dictionary = Sim.run(_by_id(160), _swap_cell(_by_id(160), cell.x, cell.y, kind))
			_check(not bool(one["success"]), "route 160 misses the dock if the wale at %d,%d is a %s" % [cell.x, cell.y, kind])

	var second: Dictionary = Sim.run(_by_id(161), _by_id(161)["reference"])
	_check(_at(_frame(second, 2), 3, 1) and _dir_at(_frame(second, 2), 3, 1) == 0, "route 161 waits on the first wale facing east")
	_check(_at(_frame(second, 3), 3, 2) and _dir_at(_frame(second, 3), 3, 2) == 0, "route 161 jumps to the right and still faces east")
	_check(_at(_frame(second, 5), 3, 3) and _dir_at(_frame(second, 5), 3, 3) == 1, "route 161 reaches the second wale facing south")
	_check(_at(_frame(second, 6), 3, 3) and _dir_at(_frame(second, 6), 3, 3) == 1, "route 161 waits on the second wale facing south")
	_check(int(second["cycles"]) == 7, "route 161 jumps to the right on the new facing")
	_check(not bool(Sim.run(_by_id(161), _omit_cell(_by_id(161), 3, 1))["success"]), "route 161 fails without the first wale")
	_check(not bool(Sim.run(_by_id(161), _omit_cell(_by_id(161), 3, 3))["success"]), "route 161 fails without the second wale")

	var night: Dictionary = Sim.run(_by_id(162), _by_id(162)["reference"])
	_check(int(night["cycles"]) < 250, "route 162 finishes before tick 250")
	_check(str(night["delivered"][0]["color"]) == "red" and int(night["delivered"][0]["count"]) == 1, "route 162 stamps red 1")
	_check(str(night["delivered"][1]["color"]) == "yellow" and int(night["delivered"][1]["count"]) == 2, "route 162 stamps yellow 2")
	_check(str(night["delivered"][2]["color"]) == "blue" and int(night["delivered"][2]["count"]) == 3, "route 162 stamps blue 3")
	_check(_color_at(_frame(night, 7), 4, 1) == "red" and _dir_at(_frame(night, 7), 4, 1) == 0, "route 162 holds red facing east")
	_check(_color_at(_frame(night, 8), 4, 2) == "red" and _dir_at(_frame(night, 8), 4, 2) == 0, "route 162 jumps red one cell south and leaves it facing east")
	_check(_color_at(_frame(night, 10), 5, 2) == "red" and _dir_at(_frame(night, 10), 5, 2) == 0 and _count_at(_frame(night, 10), 5, 2) == 0, "route 162 reaches the counter still facing east")
	var night_entered := false
	for frame in night["frames"]:
		if _color_at(frame, 4, 3) == "red":
			night_entered = true
	_check(not night_entered, "route 162 does not jump past the landing")
	_check(not bool(Sim.run(_by_id(162), _swap(_by_id(162), "wale", "sling"))["success"]), "route 162's sling misses the pause")
	_check(not bool(Sim.run(_by_id(162), _swap(_by_id(162), "primer", "painter"))["success"]), "route 162 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(162), _swap(_by_id(162), "filter", "conveyor"))["success"]), "route 162 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(162), _swap(_by_id(162), "counter", "conveyor"))["success"]), "route 162 fails without the counter")


func _garboard_rules() -> void:
	print("garboard")
	var hop := {
		"width": 3, "height": 4, "walls": [],
		"sources": [{"x": 1, "y": 2, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 2, "y": 1},
		"order": [{"color": "gray"}],
	}
	var graph := [{"type": "garboard", "x": 2, "y": 2, "dir": 0}]
	var sent: Dictionary = Sim.run(hop, graph)
	_check(bool(sent["success"]), "a garboard jumps one cell to the left and delivers")
	_check(int(sent["cycles"]) == 3 and int(sent["blocks"]) == 1, "the garboard waits a tick and delivers on tick 3")
	var born := _frame(sent, 1)
	var waited := _frame(sent, 2)
	_check(not born.is_empty() and _at(born, 2, 2) and _dir_at(born, 2, 2) == 0, "the parcel arrives facing east")
	_check(not waited.is_empty() and _at(waited, 2, 2) and _dir_at(waited, 2, 2) == 0 and not _at(waited, 2, 1), "the garboard does not move the parcel on that tick")
	_check(_count_at(waited, 2, 2) == 0 and _color_at(waited, 2, 2) == "gray", "a garboard does not stamp or paint")
	var tinted: Dictionary = Sim.run(hop, [{"type": "garboard", "x": 2, "y": 2, "dir": 0, "color": "red"}])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a garboard is ignored")
	for dir in range(4):
		var spun: Array = graph.duplicate(true)
		spun[0]["dir"] = dir
		var spun_run: Dictionary = Sim.run(hop, spun)
		_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == 3, "rotating a garboard does not change the jump")
	var biased: Dictionary = Sim.run(hop, [{"type": "bias", "x": 2, "y": 2, "dir": 0}])
	_check(bool(biased["success"]) and int(biased["cycles"]) == 3, "a bias also steps one cell to the left")
	var over_bin: Dictionary = Sim.run(hop, [
		{"type": "garboard", "x": 2, "y": 2, "dir": 0},
		{"type": "bin", "x": 2, "y": 0, "dir": 0},
	])
	_check(bool(over_bin["success"]) and int(over_bin["cycles"]) == 3, "a bin one cell past the landing does not stop the garboard")
	var straked: Dictionary = Sim.run(hop, [
		{"type": "strake", "x": 2, "y": 2, "dir": 0},
		{"type": "bin", "x": 2, "y": 0, "dir": 0},
	])
	_check(not bool(straked["success"]) and _at(_frame(straked, 3), 2, 0) and _dir_at(_frame(straked, 3), 2, 0) == 0 and not _at(_frame(straked, 3), 2, 1), "a strake lands one cell past a garboard")
	var waled: Dictionary = Sim.run(hop, [{"type": "wale", "x": 2, "y": 2, "dir": 0}])
	_check(not bool(waled["success"]) and str(waled["reason"]) == "stuck", "a wale jumps one cell south and misses the leftward step")
	var lofted: Dictionary = Sim.run(hop, [{"type": "loft", "x": 2, "y": 2, "dir": 0}])
	_check(not bool(lofted["success"]) and str(lofted["reason"]) == "stuck", "a loft jumps three cells east and misses the leftward step")
	var balked: Dictionary = Sim.run(hop, [{"type": "balk", "x": 2, "y": 2, "dir": 0}])
	_check(not bool(balked["success"]) and str(balked["reason"]) == "stuck", "a balk jumps two cells west and misses the leftward step")
	var keeled: Dictionary = Sim.run(hop, [{"type": "keel", "x": 2, "y": 2, "dir": 0}])
	_check(not bool(keeled["success"]) and str(keeled["reason"]) == "stuck", "a keel jumps three cells west and misses the leftward step")
	var sheered: Dictionary = Sim.run(hop, [{"type": "sheer", "x": 2, "y": 2, "dir": 0}])
	_check(not bool(sheered["success"]) and str(sheered["reason"]) == "stuck", "a sheer jumps three cells south and misses the leftward step")
	var turned: Dictionary = Sim.run(hop, [{"type": "turn", "x": 2, "y": 2, "dir": 0}])
	_check(not bool(turned["success"]) and str(turned["reason"]) == "stuck", "a turn faces south and misses the leftward step")
	var returned: Dictionary = Sim.run(hop, [{"type": "return", "x": 2, "y": 2, "dir": 0}])
	_check(not bool(returned["success"]) and str(returned["reason"]) == "stuck", "a return reverses the facing and cannot step through the source")
	_check(_at(_frame(returned, 2), 2, 2) and _dir_at(_frame(returned, 2), 2, 2) == 2, "the return is facing west on the garboard cell")
	var jumps := [
		{"name": "east", "src": Vector2i(1, 2), "arrival": 0, "garboard": Vector2i(2, 2), "land": Vector2i(2, 1), "dock": Vector2i(3, 1), "size": Vector2i(4, 4)},
		{"name": "south", "src": Vector2i(1, 1), "arrival": 1, "garboard": Vector2i(1, 2), "land": Vector2i(2, 2), "dock": Vector2i(2, 3), "size": Vector2i(4, 4)},
		{"name": "west", "src": Vector2i(2, 1), "arrival": 2, "garboard": Vector2i(1, 1), "land": Vector2i(1, 2), "dock": Vector2i(0, 2), "size": Vector2i(3, 4)},
		{"name": "north", "src": Vector2i(2, 2), "arrival": 3, "garboard": Vector2i(2, 1), "land": Vector2i(1, 1), "dock": Vector2i(1, 0), "size": Vector2i(4, 3)},
	]
	for spec in jumps:
		var src_at: Vector2i = spec["src"]
		var garboard_at: Vector2i = spec["garboard"]
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
			{"type": "garboard", "x": garboard_at.x, "y": garboard_at.y, "dir": 0},
			{"type": "pause", "x": land_at.x, "y": land_at.y, "dir": 0},
		]
		var side_run: Dictionary = Sim.run(strip, blocks)
		var moved := _frame(side_run, 3)
		_check(bool(side_run["success"]) and int(side_run["cycles"]) == 5, "a %s parcel jumps one cell to the left and the pause follows the old facing" % str(spec["name"]))
		_check(not moved.is_empty() and _at(moved, land_at.x, land_at.y) and _dir_at(moved, land_at.x, land_at.y) == arrival, "a %s parcel still faces %s after the one-cell jump" % [str(spec["name"]), str(spec["name"])])
	var held_board := {
		"width": 3, "height": 4, "walls": [{"x": 0, "y": 1}],
		"sources": [
			{"x": 0, "y": 2, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 2, "y": 1, "dir": 2, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 2, "y": 3},
		"order": [{"color": "gray"}],
	}
	var waiting: Dictionary = Sim.run(held_board, [
		{"type": "garboard", "x": 1, "y": 2, "dir": 0},
		{"type": "pause", "x": 1, "y": 1, "dir": 0},
	])
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a garboard keeps waiting while its landing stays blocked")
	_check(_at(_frame(waiting, 3), 1, 2) and _dir_at(_frame(waiting, 3), 1, 2) == 0 and _color_at(_frame(waiting, 5), 1, 1) == "blue", "the garboard keeps the arrival facing while the other parcel stays")
	var gap := {
		"width": 3, "height": 4, "walls": [],
		"sources": [
			{"x": 0, "y": 2, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 2, "y": 1},
		"order": [{"color": "blue"}, {"color": "gray"}],
	}
	var followed: Dictionary = Sim.run(gap, [
		{"type": "garboard", "x": 1, "y": 2, "dir": 0},
		{"type": "pause", "x": 1, "y": 1, "dir": 0},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 5, "a garboard can land in a cell another parcel is leaving")
	var into := _frame(followed, 3)
	_check(not into.is_empty() and _color_at(into, 1, 1) == "gray" and _dir_at(into, 1, 1) == 0 and into.get("delivered", []).size() == 1, "the jump lands in the cell the other parcel left and still faces east")


func _building_twenty_three() -> void:
	print("building 23")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 169, "building 23 adds routes 163 through 169")
	_check(int(puzzles[161]["id"]) == 162, "route 162 is the last route before the garboard")
	_check(int(puzzles[162]["id"]) == 163, "the garboard begins at route 163")
	_check(Puzzles.INTRO.size() >= 27 and Puzzles.INTRO[26] == "garboard", "the garboard is the block building 23 teaches")
	_check(not Puzzles.unlocked_at(161).has("garboard"), "the garboard stays locked through route 162")
	_check(Puzzles.unlocked_at(162).has("garboard"), "route 163 unlocks the garboard")
	_check(Puzzles.unlocked_at(168).size() == 27, "building 23 ends with every block")
	var pars := {
		163: [6, 3],
		164: [7, 5],
		165: [7, 4],
		166: [6, 3],
		167: [6, 5],
		168: [7, 3],
		169: [23, 24],
	}
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id <= 162:
			_check(int(puzzle.get("building", 1)) < 23, "route %d stays out of building 23" % id)
			if id >= 156:
				_check(int(puzzle.get("building", 1)) == 22, "route %d stays in building 22" % id)
			continue
		if id > 169:
			continue
		_check(int(puzzle.get("building", 1)) == 23, "route %d is building 23" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		var locked: Array = pars[id]
		_check(int(par["cycles"]) == int(locked[0]) and int(par["blocks"]) == int(locked[1]), "route %d par is %d cycles and %d blocks" % [id, int(locked[0]), int(locked[1])])
		if id == 163:
			_check(str(puzzle.get("unlocks", "")) == "garboard", "route 163 teaches the garboard")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_garboard := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "garboard":
				uses_garboard = true
		_check(uses_garboard, "route %d reference uses the garboard" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	for id in [163, 164, 165, 166, 167, 168, 169]:
		for dir in range(4):
			var spun: Array = _by_id(id)["reference"].duplicate(true)
			for block in spun:
				if str(block["type"]) == "garboard":
					block["dir"] = dir
			var spun_run: Dictionary = Sim.run(_by_id(id), spun)
			_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == int(pars[id][0]), "route %d ignores which way the garboard block is rotated" % id)
		for kind in ["wale", "shunt", "sling", "loft", "balk", "keel", "sheer", "strake", "cant", "return", "vault", "conveyor", "pause", "slide", "bridge", "turn", "chute", "hook"]:
			var swapped: Dictionary = Sim.run(_by_id(id), _swap(_by_id(id), "garboard", kind))
			_check(not bool(swapped["success"]), "route %d fails if the garboard is a %s" % [id, kind])
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "garboard":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the garboard is missing" % id)

	var lesson: Dictionary = Sim.run(_by_id(163), _by_id(163)["reference"])
	_check(_at(_frame(lesson, 2), 4, 2) and _dir_at(_frame(lesson, 2), 4, 2) == 0, "route 163 starts the parcel facing east on the garboard")
	_check(_at(_frame(lesson, 3), 4, 2) and _dir_at(_frame(lesson, 3), 4, 2) == 0, "route 163 keeps the parcel facing east without moving it")
	_check(_at(_frame(lesson, 4), 4, 1) and _dir_at(_frame(lesson, 4), 4, 1) == 0, "route 163 jumps one cell north and still faces east")
	_check(int(lesson["cycles"]) == 6, "route 163 delivers after the pause follows the kept facing")
	_check(str(Sim.run(_by_id(163), _swap(_by_id(163), "garboard", "strake"))["reason"]) == "stuck", "route 163's strake tries to land on the brick")
	_check(str(Sim.run(_by_id(163), _swap(_by_id(163), "garboard", "turn"))["reason"]) == "stuck", "route 163's turn faces south and misses the dock")
	_check(str(Sim.run(_by_id(163), _swap(_by_id(163), "garboard", "hook"))["reason"]) == "stuck", "route 163's hook faces north and misses the dock")
	var lesson_return: Dictionary = Sim.run(_by_id(163), _swap(_by_id(163), "garboard", "return"))
	_check(str(lesson_return["reason"]) == "tick_cap" and _dir_at(_frame(lesson_return, 3), 4, 2) == 2, "route 163's return reverses the facing")

	var let_garboard: Dictionary = Sim.run(_by_id(164), _by_id(164)["reference"])
	_check(_color_at(_frame(let_garboard, 4), 4, 2) == "red" and _dir_at(_frame(let_garboard, 4), 4, 2) == 0 and _color_at(_frame(let_garboard, 4), 4, 1) == "blue", "route 164 holds red while blue stands on the landing")
	_check(_color_at(_frame(let_garboard, 5), 4, 1) == "red" and _dir_at(_frame(let_garboard, 5), 4, 1) == 0 and _frame(let_garboard, 5).get("delivered", []).size() == 1, "route 164 jumps once the landing is free and still faces east")

	var counted: Dictionary = Sim.run(_by_id(165), _by_id(165)["reference"])
	_check(str(counted["delivered"][0]["color"]) == "blue" and int(counted["delivered"][0]["count"]) == 1, "route 165 delivers blue count 1")
	_check(str(counted["delivered"][1]["color"]) == "red" and int(counted["delivered"][1]["count"]) == 2, "route 165 delivers red count 2")
	_check(_color_at(_frame(counted, 3), 2, 1) == "red" and _dir_at(_frame(counted, 3), 2, 1) == 0, "route 165 jumps north and still faces east")
	_check(_color_at(_frame(counted, 6), 4, 1) == "red" and _count_at(_frame(counted, 6), 4, 1) == 2, "route 165's counter stamps 2")
	_check(str(Sim.run(_by_id(165), _swap(_by_id(165), "garboard", "wale"))["reason"]) == "stuck", "route 165's wale jumps the other way")

	var clear: Dictionary = Sim.run(_by_id(166), _by_id(166)["reference"])
	_check(_at(_frame(clear, 3), 2, 2) and _dir_at(_frame(clear, 3), 2, 2) == 0, "route 166 waits facing east")
	_check(_at(_frame(clear, 4), 2, 1) and _dir_at(_frame(clear, 4), 2, 1) == 0, "route 166 lands one cell north and still faces east")
	_check(int(clear["cycles"]) == 6, "route 166 delivers after the pause steps east")
	var brick_entered := false
	for frame in clear["frames"]:
		if _at(frame, 2, 0):
			brick_entered = true
	_check(not brick_entered, "route 166 does not enter the brick past the landing")
	_check(str(Sim.run(_by_id(166), _swap(_by_id(166), "garboard", "strake"))["reason"]) == "stuck", "route 166's strake tries to land on the brick")
	_check(str(Sim.run(_by_id(166), _swap(_by_id(166), "garboard", "hook"))["reason"]) == "stuck", "route 166's hook steps into the brick")

	var paired: Dictionary = Sim.run(_by_id(167), _by_id(167)["reference"])
	_check(_color_at(_frame(paired, 2), 4, 2) == "red" and _dir_at(_frame(paired, 2), 4, 2) == 0, "route 167 holds the east-facing parcel")
	_check(_color_at(_frame(paired, 2), 6, 2) == "blue" and _dir_at(_frame(paired, 2), 6, 2) == 3, "route 167 holds the north-facing parcel")
	_check(_frame(paired, 5).get("delivered", []).size() == 1 and str(_frame(paired, 5)["delivered"][0]["color"]) == "red", "route 167 delivers the east-facing parcel first")
	_check(int(paired["cycles"]) == 6, "route 167 delivers the north-facing parcel second")
	for cell in [Vector2i(4, 2), Vector2i(6, 2)]:
		for kind in ["wale", "sling", "turn", "hook", "strake", "sheer", "loft", "balk", "keel"]:
			var one: Dictionary = Sim.run(_by_id(167), _swap_cell(_by_id(167), cell.x, cell.y, kind))
			_check(not bool(one["success"]), "route 167 misses the dock if the garboard at %d,%d is a %s" % [cell.x, cell.y, kind])

	var second: Dictionary = Sim.run(_by_id(168), _by_id(168)["reference"])
	_check(_at(_frame(second, 2), 3, 2) and _dir_at(_frame(second, 2), 3, 2) == 0, "route 168 waits on the first garboard facing east")
	_check(_at(_frame(second, 3), 3, 1) and _dir_at(_frame(second, 3), 3, 1) == 0, "route 168 jumps to the left and still faces east")
	_check(_at(_frame(second, 5), 3, 0) and _dir_at(_frame(second, 5), 3, 0) == 3, "route 168 reaches the second garboard facing north")
	_check(_at(_frame(second, 6), 3, 0) and _dir_at(_frame(second, 6), 3, 0) == 3, "route 168 waits on the second garboard facing north")
	_check(int(second["cycles"]) == 7, "route 168 jumps to the left on the new facing")
	_check(not bool(Sim.run(_by_id(168), _omit_cell(_by_id(168), 3, 2))["success"]), "route 168 fails without the first garboard")
	_check(not bool(Sim.run(_by_id(168), _omit_cell(_by_id(168), 3, 0))["success"]), "route 168 fails without the second garboard")

	var night: Dictionary = Sim.run(_by_id(169), _by_id(169)["reference"])
	_check(int(night["cycles"]) < 250, "route 169 finishes before tick 250")
	_check(str(night["delivered"][0]["color"]) == "red" and int(night["delivered"][0]["count"]) == 1, "route 169 stamps red 1")
	_check(str(night["delivered"][1]["color"]) == "yellow" and int(night["delivered"][1]["count"]) == 2, "route 169 stamps yellow 2")
	_check(str(night["delivered"][2]["color"]) == "blue" and int(night["delivered"][2]["count"]) == 3, "route 169 stamps blue 3")
	_check(_color_at(_frame(night, 7), 4, 3) == "red" and _dir_at(_frame(night, 7), 4, 3) == 0, "route 169 holds red facing east")
	_check(_color_at(_frame(night, 9), 4, 2) == "red" and _dir_at(_frame(night, 9), 4, 2) == 0, "route 169 jumps red one cell north and leaves it facing east")
	_check(_color_at(_frame(night, 12), 6, 2) == "red" and _dir_at(_frame(night, 12), 6, 2) == 0 and _count_at(_frame(night, 12), 6, 2) == 0, "route 169 reaches the counter still facing east")
	var night_entered := false
	for frame in night["frames"]:
		if _color_at(frame, 4, 4) == "red":
			night_entered = true
	_check(not night_entered, "route 169 does not jump past the landing")
	_check(not bool(Sim.run(_by_id(169), _swap(_by_id(169), "garboard", "wale"))["success"]), "route 169's wale misses the pause")
	_check(not bool(Sim.run(_by_id(169), _swap(_by_id(169), "primer", "painter"))["success"]), "route 169 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(169), _swap(_by_id(169), "filter", "conveyor"))["success"]), "route 169 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(169), _swap(_by_id(169), "counter", "conveyor"))["success"]), "route 169 fails without the counter")


func _stealer_rules() -> void:
	print("stealer")
	var hop := {
		"width": 3, "height": 6, "walls": [],
		"sources": [{"x": 1, "y": 4, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 2, "y": 1},
		"order": [{"color": "gray"}],
	}
	var graph := [{"type": "stealer", "x": 2, "y": 4, "dir": 0}]
	var sent: Dictionary = Sim.run(hop, graph)
	_check(bool(sent["success"]), "a stealer jumps three cells to the left and delivers")
	_check(int(sent["cycles"]) == 3 and int(sent["blocks"]) == 1, "the stealer waits a tick and delivers on tick 3")
	var born := _frame(sent, 1)
	var waited := _frame(sent, 2)
	_check(not born.is_empty() and _at(born, 2, 4) and _dir_at(born, 2, 4) == 0, "the parcel arrives facing east")
	_check(not waited.is_empty() and _at(waited, 2, 4) and _dir_at(waited, 2, 4) == 0 and not _at(waited, 2, 1), "the stealer does not move the parcel on that tick")
	_check(_count_at(waited, 2, 4) == 0 and _color_at(waited, 2, 4) == "gray", "a stealer does not stamp or paint")
	var tinted: Dictionary = Sim.run(hop, [{"type": "stealer", "x": 2, "y": 4, "dir": 0, "color": "red"}])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a stealer is ignored")
	for dir in range(4):
		var spun: Array = graph.duplicate(true)
		spun[0]["dir"] = dir
		var spun_run: Dictionary = Sim.run(hop, spun)
		_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == 3, "rotating a stealer does not change the jump")
	var over_bin: Dictionary = Sim.run(hop, [
		{"type": "stealer", "x": 2, "y": 4, "dir": 0},
		{"type": "bin", "x": 2, "y": 3, "dir": 0},
		{"type": "bin", "x": 2, "y": 2, "dir": 0},
	])
	_check(bool(over_bin["success"]) and int(over_bin["cycles"]) == 3, "bins in the skipped cells do not stop the stealer")
	var skipped := false
	for frame in over_bin["frames"]:
		if _at(frame, 2, 3) or _at(frame, 2, 2):
			skipped = true
	_check(not skipped, "the stealer does not enter either cell beside it")
	var shorted: Dictionary = Sim.run(hop, [
		{"type": "strake", "x": 2, "y": 4, "dir": 0},
		{"type": "bin", "x": 2, "y": 2, "dir": 0},
	])
	_check(not bool(shorted["success"]) and _at(_frame(shorted, 3), 2, 2) and _dir_at(_frame(shorted, 3), 2, 2) == 0, "a strake lands one cell short of a stealer")
	var garboarded: Dictionary = Sim.run(hop, [{"type": "garboard", "x": 2, "y": 4, "dir": 0}])
	_check(not bool(garboarded["success"]) and str(garboarded["reason"]) == "stuck", "a garboard lands two cells short of a stealer")
	var waled: Dictionary = Sim.run(hop, [{"type": "wale", "x": 2, "y": 4, "dir": 0}])
	_check(not bool(waled["success"]) and str(waled["reason"]) == "stuck", "a wale jumps one cell south and misses the leftward jump")
	var sheered: Dictionary = Sim.run(hop, [{"type": "sheer", "x": 2, "y": 4, "dir": 0}])
	_check(not bool(sheered["success"]) and str(sheered["reason"]) == "stuck", "a sheer jumps three cells south and misses the leftward jump")
	var lofted: Dictionary = Sim.run(hop, [{"type": "loft", "x": 2, "y": 4, "dir": 0}])
	_check(not bool(lofted["success"]) and str(lofted["reason"]) == "stuck", "a loft jumps three cells east and misses the leftward jump")
	var balked: Dictionary = Sim.run(hop, [{"type": "balk", "x": 2, "y": 4, "dir": 0}])
	_check(not bool(balked["success"]) and str(balked["reason"]) == "stuck", "a balk jumps two cells west and misses the leftward jump")
	var keeled: Dictionary = Sim.run(hop, [{"type": "keel", "x": 2, "y": 4, "dir": 0}])
	_check(not bool(keeled["success"]) and str(keeled["reason"]) == "stuck", "a keel jumps three cells west and misses the leftward jump")
	var turned: Dictionary = Sim.run(hop, [{"type": "turn", "x": 2, "y": 4, "dir": 0}])
	_check(not bool(turned["success"]) and str(turned["reason"]) == "stuck", "a turn faces south and misses the three-cell jump")
	var hooked: Dictionary = Sim.run(hop, [{"type": "hook", "x": 2, "y": 4, "dir": 0}])
	_check(not bool(hooked["success"]) and str(hooked["reason"]) == "stuck", "a hook steps one cell and misses the three-cell jump")
	var returned: Dictionary = Sim.run(hop, [{"type": "return", "x": 2, "y": 4, "dir": 0}])
	_check(not bool(returned["success"]) and str(returned["reason"]) == "stuck", "a return reverses the facing and cannot step through the source")
	_check(_at(_frame(returned, 2), 2, 4) and _dir_at(_frame(returned, 2), 2, 4) == 2, "the return is facing west on the stealer cell")
	var jumps := [
		{"name": "east", "src": Vector2i(1, 4), "arrival": 0, "stealer": Vector2i(2, 4), "land": Vector2i(2, 1), "dock": Vector2i(3, 1), "size": Vector2i(4, 6)},
		{"name": "south", "src": Vector2i(1, 1), "arrival": 1, "stealer": Vector2i(1, 2), "land": Vector2i(4, 2), "dock": Vector2i(4, 3), "size": Vector2i(5, 5)},
		{"name": "west", "src": Vector2i(2, 1), "arrival": 2, "stealer": Vector2i(1, 1), "land": Vector2i(1, 4), "dock": Vector2i(0, 4), "size": Vector2i(3, 6)},
		{"name": "north", "src": Vector2i(4, 2), "arrival": 3, "stealer": Vector2i(4, 1), "land": Vector2i(1, 1), "dock": Vector2i(1, 0), "size": Vector2i(5, 4)},
	]
	for spec in jumps:
		var src_at: Vector2i = spec["src"]
		var stealer_at: Vector2i = spec["stealer"]
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
			{"type": "stealer", "x": stealer_at.x, "y": stealer_at.y, "dir": 0},
			{"type": "pause", "x": land_at.x, "y": land_at.y, "dir": 0},
		]
		var side_run: Dictionary = Sim.run(strip, blocks)
		var moved := _frame(side_run, 3)
		_check(bool(side_run["success"]) and int(side_run["cycles"]) == 5, "a %s parcel jumps three cells to the left and the pause follows the old facing" % str(spec["name"]))
		_check(not moved.is_empty() and _at(moved, land_at.x, land_at.y) and _dir_at(moved, land_at.x, land_at.y) == arrival, "a %s parcel still faces %s after the three-cell jump" % [str(spec["name"]), str(spec["name"])])
	var held_board := {
		"width": 3, "height": 6, "walls": [{"x": 0, "y": 1}],
		"sources": [
			{"x": 0, "y": 4, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 2, "y": 1, "dir": 2, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 2, "y": 5},
		"order": [{"color": "gray"}],
	}
	var waiting: Dictionary = Sim.run(held_board, [
		{"type": "stealer", "x": 1, "y": 4, "dir": 0},
		{"type": "pause", "x": 1, "y": 1, "dir": 0},
	])
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a stealer keeps waiting while its landing stays blocked")
	_check(_at(_frame(waiting, 3), 1, 4) and _dir_at(_frame(waiting, 3), 1, 4) == 0 and _color_at(_frame(waiting, 5), 1, 1) == "blue", "the stealer keeps the arrival facing while the other parcel stays")
	var gap := {
		"width": 3, "height": 6, "walls": [],
		"sources": [
			{"x": 0, "y": 4, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 2, "y": 1},
		"order": [{"color": "blue"}, {"color": "gray"}],
	}
	var followed: Dictionary = Sim.run(gap, [
		{"type": "stealer", "x": 1, "y": 4, "dir": 0},
		{"type": "pause", "x": 1, "y": 1, "dir": 0},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 5, "a stealer can land in a cell another parcel is leaving")
	var into := _frame(followed, 3)
	_check(not into.is_empty() and _color_at(into, 1, 1) == "gray" and _dir_at(into, 1, 1) == 0 and into.get("delivered", []).size() == 1, "the jump lands in the cell the other parcel left and still faces east")


func _building_twenty_four() -> void:
	print("building 24")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 176, "building 24 adds routes 170 through 176")
	_check(int(puzzles[168]["id"]) == 169, "route 169 is the last route before the stealer")
	_check(int(puzzles[169]["id"]) == 170, "the stealer begins at route 170")
	_check(Puzzles.INTRO.size() >= 28 and Puzzles.INTRO[27] == "stealer", "the stealer is the block building 24 teaches")
	_check(not Puzzles.unlocked_at(168).has("stealer"), "the stealer stays locked through route 169")
	_check(Puzzles.unlocked_at(169).has("stealer"), "route 170 unlocks the stealer")
	_check(Puzzles.unlocked_at(175).size() == 28, "building 24 ends with every block")
	var pars := {
		170: [6, 3],
		171: [7, 5],
		172: [7, 4],
		173: [6, 3],
		174: [6, 5],
		175: [7, 3],
		176: [16, 15],
	}
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id <= 169:
			_check(int(puzzle.get("building", 1)) < 24, "route %d stays out of building 24" % id)
			if id >= 163:
				_check(int(puzzle.get("building", 1)) == 23, "route %d stays in building 23" % id)
			continue
		if id > 176:
			continue
		_check(int(puzzle.get("building", 1)) == 24, "route %d is building 24" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		var locked: Array = pars[id]
		_check(int(par["cycles"]) == int(locked[0]) and int(par["blocks"]) == int(locked[1]), "route %d par is %d cycles and %d blocks" % [id, int(locked[0]), int(locked[1])])
		if id == 170:
			_check(str(puzzle.get("unlocks", "")) == "stealer", "route 170 teaches the stealer")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_stealer := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "stealer":
				uses_stealer = true
		_check(uses_stealer, "route %d reference uses the stealer" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	for id in [170, 171, 172, 173, 174, 175, 176]:
		for dir in range(4):
			var spun: Array = _by_id(id)["reference"].duplicate(true)
			for block in spun:
				if str(block["type"]) == "stealer":
					block["dir"] = dir
			var spun_run: Dictionary = Sim.run(_by_id(id), spun)
			_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == int(pars[id][0]), "route %d ignores which way the stealer block is rotated" % id)
		for kind in ["garboard", "strake", "cant", "sheer", "wale", "shunt", "hook", "turn", "sling", "loft", "balk", "keel", "return", "vault", "bias", "conveyor", "pause", "slide", "bridge", "chute"]:
			var swapped: Dictionary = Sim.run(_by_id(id), _swap(_by_id(id), "stealer", kind))
			_check(not bool(swapped["success"]), "route %d fails if the stealer is a %s" % [id, kind])
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "stealer":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the stealer is missing" % id)

	var lesson: Dictionary = Sim.run(_by_id(170), _by_id(170)["reference"])
	_check(_at(_frame(lesson, 2), 4, 3) and _dir_at(_frame(lesson, 2), 4, 3) == 0, "route 170 starts the parcel facing east on the stealer")
	_check(_at(_frame(lesson, 3), 4, 3) and _dir_at(_frame(lesson, 3), 4, 3) == 0, "route 170 keeps the parcel facing east without moving it")
	_check(_at(_frame(lesson, 4), 4, 0) and _dir_at(_frame(lesson, 4), 4, 0) == 0, "route 170 jumps three cells north and still faces east")
	_check(int(lesson["cycles"]) == 6, "route 170 delivers after the pause follows the kept facing")
	var lesson_entered := false
	for frame in lesson["frames"]:
		if _at(frame, 4, 2) or _at(frame, 4, 1):
			lesson_entered = true
	_check(not lesson_entered, "route 170 does not enter the cells between")
	_check(str(Sim.run(_by_id(170), _swap(_by_id(170), "stealer", "garboard"))["reason"]) == "stuck", "route 170's garboard lands on the near brick")
	_check(str(Sim.run(_by_id(170), _swap(_by_id(170), "stealer", "strake"))["reason"]) == "stuck", "route 170's strake lands on the far brick")
	_check(str(Sim.run(_by_id(170), _swap(_by_id(170), "stealer", "hook"))["reason"]) == "stuck", "route 170's hook steps into the near brick")
	_check(str(Sim.run(_by_id(170), _swap(_by_id(170), "stealer", "turn"))["reason"]) == "stuck", "route 170's turn faces south and misses the dock")

	var let_stealer: Dictionary = Sim.run(_by_id(171), _by_id(171)["reference"])
	_check(_color_at(_frame(let_stealer, 4), 4, 3) == "red" and _dir_at(_frame(let_stealer, 4), 4, 3) == 0 and _color_at(_frame(let_stealer, 4), 4, 0) == "blue", "route 171 holds red while blue stands on the landing")
	_check(_color_at(_frame(let_stealer, 5), 4, 0) == "red" and _dir_at(_frame(let_stealer, 5), 4, 0) == 0 and _frame(let_stealer, 5).get("delivered", []).size() == 1, "route 171 jumps once the landing is free and still faces east")

	var counted: Dictionary = Sim.run(_by_id(172), _by_id(172)["reference"])
	_check(str(counted["delivered"][0]["color"]) == "blue" and int(counted["delivered"][0]["count"]) == 1, "route 172 delivers blue count 1")
	_check(str(counted["delivered"][1]["color"]) == "red" and int(counted["delivered"][1]["count"]) == 2, "route 172 delivers red count 2")
	_check(_color_at(_frame(counted, 3), 2, 0) == "red" and _dir_at(_frame(counted, 3), 2, 0) == 0, "route 172 jumps three cells north and still faces east")
	_check(_color_at(_frame(counted, 6), 4, 0) == "red" and _count_at(_frame(counted, 6), 4, 0) == 2, "route 172's counter stamps 2")

	var clear: Dictionary = Sim.run(_by_id(173), _by_id(173)["reference"])
	_check(_at(_frame(clear, 3), 2, 3) and _dir_at(_frame(clear, 3), 2, 3) == 0, "route 173 waits facing east")
	_check(_at(_frame(clear, 4), 2, 0) and _dir_at(_frame(clear, 4), 2, 0) == 0, "route 173 lands three cells north and still faces east")
	var brick_entered := false
	for frame in clear["frames"]:
		if _at(frame, 2, 2) or _at(frame, 2, 1):
			brick_entered = true
	_check(not brick_entered, "route 173 does not enter either brick")
	_check(str(Sim.run(_by_id(173), _swap(_by_id(173), "stealer", "garboard"))["reason"]) == "stuck", "route 173's garboard tries to land on the near brick")
	_check(str(Sim.run(_by_id(173), _swap(_by_id(173), "stealer", "strake"))["reason"]) == "stuck", "route 173's strake tries to land on the far brick")

	var paired: Dictionary = Sim.run(_by_id(174), _by_id(174)["reference"])
	_check(_color_at(_frame(paired, 2), 4, 5) == "red" and _dir_at(_frame(paired, 2), 4, 5) == 0, "route 174 holds the east-facing parcel")
	_check(_color_at(_frame(paired, 2), 8, 3) == "blue" and _dir_at(_frame(paired, 2), 8, 3) == 3, "route 174 holds the north-facing parcel")
	_check(_frame(paired, 5).get("delivered", []).size() == 1 and str(_frame(paired, 5)["delivered"][0]["color"]) == "red", "route 174 delivers the east-facing parcel first")
	_check(int(paired["cycles"]) == 6, "route 174 delivers the north-facing parcel second")
	for cell in [Vector2i(4, 5), Vector2i(8, 3)]:
		for kind in ["garboard", "strake", "sheer", "wale", "hook", "turn"]:
			var one: Dictionary = Sim.run(_by_id(174), _swap_cell(_by_id(174), cell.x, cell.y, kind))
			_check(not bool(one["success"]), "route 174 misses the dock if the stealer at %d,%d is a %s" % [cell.x, cell.y, kind])

	var second: Dictionary = Sim.run(_by_id(175), _by_id(175)["reference"])
	_check(_at(_frame(second, 2), 3, 5) and _dir_at(_frame(second, 2), 3, 5) == 0, "route 175 waits on the first stealer facing east")
	_check(_at(_frame(second, 3), 3, 2) and _dir_at(_frame(second, 3), 3, 2) == 0, "route 175 jumps three cells to the left and still faces east")
	_check(_at(_frame(second, 5), 3, 1) and _dir_at(_frame(second, 5), 3, 1) == 3, "route 175 reaches the second stealer facing north")
	_check(_at(_frame(second, 6), 3, 1) and _dir_at(_frame(second, 6), 3, 1) == 3, "route 175 waits on the second stealer facing north")
	_check(int(second["cycles"]) == 7, "route 175 jumps three cells to the left on the new facing")
	_check(not bool(Sim.run(_by_id(175), _omit_cell(_by_id(175), 3, 5))["success"]), "route 175 fails without the first stealer")
	_check(not bool(Sim.run(_by_id(175), _omit_cell(_by_id(175), 3, 1))["success"]), "route 175 fails without the second stealer")

	var night: Dictionary = Sim.run(_by_id(176), _by_id(176)["reference"])
	_check(int(night["cycles"]) < 250, "route 176 finishes before tick 250")
	_check(str(night["delivered"][0]["color"]) == "red" and int(night["delivered"][0]["count"]) == 1, "route 176 stamps red 1")
	_check(str(night["delivered"][1]["color"]) == "yellow" and int(night["delivered"][1]["count"]) == 2, "route 176 stamps yellow 2")
	_check(str(night["delivered"][2]["color"]) == "blue" and int(night["delivered"][2]["count"]) == 3, "route 176 stamps blue 3")
	_check(_color_at(_frame(night, 7), 4, 3) == "red" and _dir_at(_frame(night, 7), 4, 3) == 0, "route 176 holds red facing east")
	_check(_color_at(_frame(night, 9), 4, 0) == "red" and _dir_at(_frame(night, 9), 4, 0) == 0, "route 176 jumps red three cells north and leaves it facing east")
	_check(_color_at(_frame(night, 12), 6, 0) == "red" and _dir_at(_frame(night, 12), 6, 0) == 0 and _count_at(_frame(night, 12), 6, 0) == 0, "route 176 reaches the counter still facing east")
	var night_entered := false
	for frame in night["frames"]:
		if _color_at(frame, 4, 2) == "red" or _color_at(frame, 4, 1) == "red":
			night_entered = true
	_check(not night_entered, "route 176 does not enter the cells between")
	_check(not bool(Sim.run(_by_id(176), _swap(_by_id(176), "stealer", "garboard"))["success"]), "route 176's garboard misses the pause")
	_check(not bool(Sim.run(_by_id(176), _swap(_by_id(176), "stealer", "strake"))["success"]), "route 176's strake misses the pause")
	_check(not bool(Sim.run(_by_id(176), _swap(_by_id(176), "primer", "painter"))["success"]), "route 176 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(176), _swap(_by_id(176), "filter", "conveyor"))["success"]), "route 176 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(176), _swap(_by_id(176), "counter", "conveyor"))["success"]), "route 176 fails without the counter")


func _rabbet_rules() -> void:
	print("rabbet")
	var hop := {
		"width": 6, "height": 5, "walls": [],
		"sources": [{"x": 3, "y": 3, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 3, "y": 1},
		"order": [{"color": "gray"}],
	}
	var graph := [
		{"type": "garboard", "x": 4, "y": 3, "dir": 0},
		{"type": "rabbet", "x": 4, "y": 2, "dir": 0},
		{"type": "hook", "x": 3, "y": 2, "dir": 0},
	]
	var sent: Dictionary = Sim.run(hop, graph)
	_check(bool(sent["success"]), "a rabbet jumps one cell backward and the hook follows the kept facing")
	_check(int(sent["cycles"]) == 7 and int(sent["blocks"]) == 3, "the rabbet waits a tick and delivers on tick 7")
	var born := _frame(sent, 3)
	var waited := _frame(sent, 4)
	_check(not born.is_empty() and _at(born, 4, 2) and _dir_at(born, 4, 2) == 0, "the parcel arrives facing east")
	_check(not waited.is_empty() and _at(waited, 4, 2) and _dir_at(waited, 4, 2) == 0 and not _at(waited, 3, 2), "the rabbet does not move the parcel on that tick")
	_check(_count_at(waited, 4, 2) == 0 and _color_at(waited, 4, 2) == "gray", "a rabbet does not stamp or paint")
	var tinted: Dictionary = Sim.run(hop, [
		{"type": "garboard", "x": 4, "y": 3, "dir": 0},
		{"type": "rabbet", "x": 4, "y": 2, "dir": 0, "color": "red"},
		{"type": "hook", "x": 3, "y": 2, "dir": 0},
	])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a rabbet is ignored")
	for dir in range(4):
		var spun: Array = graph.duplicate(true)
		spun[1]["dir"] = dir
		var spun_run: Dictionary = Sim.run(hop, spun)
		_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == 7, "rotating a rabbet does not change the jump")
	for kind in ["return", "balk", "keel", "stealer", "garboard", "turn"]:
		var missed: Array = graph.duplicate(true)
		missed[1]["type"] = kind
		var missed_run: Dictionary = Sim.run(hop, missed)
		_check(not bool(missed_run["success"]), "a %s misses the one-cell backward jump" % kind)
	var returned: Dictionary = Sim.run(hop, [
		{"type": "garboard", "x": 4, "y": 3, "dir": 0},
		{"type": "return", "x": 4, "y": 2, "dir": 0},
		{"type": "hook", "x": 3, "y": 2, "dir": 0},
	])
	_check(_at(_frame(returned, 4), 4, 2) and _dir_at(_frame(returned, 4), 4, 2) == 2, "the return is facing west on the rabbet cell")
	var jumps := [
		{"name": "east", "src": Vector2i(3, 3), "arrival": 0, "feed": Vector2i(4, 3), "rabbet": Vector2i(4, 2), "hook": Vector2i(3, 2), "dock": Vector2i(3, 1), "size": Vector2i(6, 5)},
		{"name": "south", "src": Vector2i(2, 1), "arrival": 1, "feed": Vector2i(2, 2), "rabbet": Vector2i(3, 2), "hook": Vector2i(3, 1), "dock": Vector2i(4, 1), "size": Vector2i(5, 4)},
		{"name": "west", "src": Vector2i(4, 1), "arrival": 2, "feed": Vector2i(3, 1), "rabbet": Vector2i(3, 2), "hook": Vector2i(4, 2), "dock": Vector2i(4, 3), "size": Vector2i(5, 4)},
		{"name": "north", "src": Vector2i(4, 3), "arrival": 3, "feed": Vector2i(4, 2), "rabbet": Vector2i(3, 2), "hook": Vector2i(3, 3), "dock": Vector2i(2, 3), "size": Vector2i(5, 4)},
	]
	for spec in jumps:
		var src_at: Vector2i = spec["src"]
		var feed_at: Vector2i = spec["feed"]
		var rabbet_at: Vector2i = spec["rabbet"]
		var hook_at: Vector2i = spec["hook"]
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
			{"type": "garboard", "x": feed_at.x, "y": feed_at.y, "dir": 0},
			{"type": "rabbet", "x": rabbet_at.x, "y": rabbet_at.y, "dir": 0},
			{"type": "hook", "x": hook_at.x, "y": hook_at.y, "dir": 0},
		]
		var side_run: Dictionary = Sim.run(strip, blocks)
		var moved := _frame(side_run, 5)
		_check(bool(side_run["success"]) and int(side_run["cycles"]) == 7, "a %s parcel jumps one cell backward and the hook follows the old facing" % str(spec["name"]))
		_check(not moved.is_empty() and _at(moved, hook_at.x, hook_at.y) and _dir_at(moved, hook_at.x, hook_at.y) == arrival, "a %s parcel still faces %s after the backward jump" % [str(spec["name"]), str(spec["name"])])
	var held_board := {
		"width": 6, "height": 5, "walls": [{"x": 3, "y": 1}],
		"sources": [
			{"x": 3, "y": 3, "dir": 0, "parcels": [{"color": "red"}]},
			{"x": 2, "y": 2, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 5, "y": 1},
		"order": [{"color": "red"}],
	}
	var waiting: Dictionary = Sim.run(held_board, graph)
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a rabbet keeps waiting while its landing stays blocked")
	_check(_at(_frame(waiting, 4), 4, 2) and _dir_at(_frame(waiting, 4), 4, 2) == 0 and _color_at(_frame(waiting, 5), 3, 2) == "blue", "the rabbet keeps the arrival facing while the other parcel stays")
	var gap := {
		"width": 7, "height": 5, "walls": [],
		"sources": [
			{"x": 4, "y": 3, "dir": 0, "parcels": [{"color": "red"}]},
			{"x": 0, "y": 2, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 4, "y": 1},
		"order": [{"color": "blue"}, {"color": "red"}],
	}
	var followed: Dictionary = Sim.run(gap, [
		{"type": "garboard", "x": 5, "y": 3, "dir": 0},
		{"type": "rabbet", "x": 5, "y": 2, "dir": 0},
		{"type": "hook", "x": 4, "y": 2, "dir": 0},
		{"type": "loft", "x": 1, "y": 2, "dir": 0},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 7, "a rabbet can land in a cell another parcel is leaving")
	var into := _frame(followed, 5)
	_check(not into.is_empty() and _color_at(into, 4, 2) == "red" and _dir_at(into, 4, 2) == 0 and into.get("delivered", []).size() == 1, "the jump lands in the cell the other parcel left and still faces east")


func _building_twenty_five() -> void:
	print("building 25")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 183, "building 25 adds routes 177 through 183")
	_check(int(puzzles[175]["id"]) == 176, "route 176 is the last route before the rabbet")
	_check(int(puzzles[176]["id"]) == 177, "the rabbet begins at route 177")
	_check(Puzzles.INTRO.size() >= 29 and Puzzles.INTRO[28] == "rabbet", "the rabbet is the block building 25 teaches")
	_check(not Puzzles.unlocked_at(175).has("rabbet"), "the rabbet stays locked through route 176")
	_check(Puzzles.unlocked_at(176).has("rabbet"), "route 177 unlocks the rabbet")
	_check(Puzzles.unlocked_at(182).size() == 29, "building 25 ends with every block")
	var pars := {
		177: [7, 3],
		178: [7, 4],
		179: [9, 7],
		180: [7, 3],
		181: [10, 8],
		182: [14, 7],
		183: [24, 24],
	}
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id <= 176:
			_check(int(puzzle.get("building", 1)) < 25, "route %d stays out of building 25" % id)
			if id >= 170:
				_check(int(puzzle.get("building", 1)) == 24, "route %d stays in building 24" % id)
			continue
		if id > 183:
			continue
		_check(int(puzzle.get("building", 1)) == 25, "route %d is building 25" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		var locked: Array = pars[id]
		_check(int(par["cycles"]) == int(locked[0]) and int(par["blocks"]) == int(locked[1]), "route %d par is %d cycles and %d blocks" % [id, int(locked[0]), int(locked[1])])
		if id == 177:
			_check(str(puzzle.get("unlocks", "")) == "rabbet", "route 177 teaches the rabbet")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_rabbet := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "rabbet":
				uses_rabbet = true
		_check(uses_rabbet, "route %d reference uses the rabbet" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	for id in [177, 178, 179, 180, 181, 182, 183]:
		for dir in range(4):
			var spun: Array = _by_id(id)["reference"].duplicate(true)
			for block in spun:
				if str(block["type"]) == "rabbet":
					block["dir"] = dir
			var spun_run: Dictionary = Sim.run(_by_id(id), spun)
			_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == int(pars[id][0]), "route %d ignores which way the rabbet block is rotated" % id)
		for kind in ["return", "balk", "keel", "stealer", "garboard", "turn", "hook", "pause", "conveyor", "slide", "vault", "loft", "bias", "cant", "strake", "wale", "shunt", "sheer", "sling", "bridge", "chute"]:
			var swapped: Dictionary = Sim.run(_by_id(id), _swap(_by_id(id), "rabbet", kind))
			_check(not bool(swapped["success"]), "route %d fails if the rabbet is a %s" % [id, kind])
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "rabbet":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the rabbet is missing" % id)

	var lesson: Dictionary = Sim.run(_by_id(177), _by_id(177)["reference"])
	_check(_at(_frame(lesson, 3), 4, 2) and _dir_at(_frame(lesson, 3), 4, 2) == 0, "route 177 starts the parcel facing east on the rabbet")
	_check(_at(_frame(lesson, 4), 4, 2) and _dir_at(_frame(lesson, 4), 4, 2) == 0, "route 177 keeps the parcel facing east without moving it")
	_check(_at(_frame(lesson, 5), 3, 2) and _dir_at(_frame(lesson, 5), 3, 2) == 0, "route 177 jumps one cell west and still faces east")
	_check(int(lesson["cycles"]) == 7, "route 177 delivers after the hook follows the kept facing")
	_check(str(Sim.run(_by_id(177), _swap(_by_id(177), "rabbet", "return"))["reason"]) == "stuck", "route 177's return faces west and the hook steps south")
	_check(str(Sim.run(_by_id(177), _swap(_by_id(177), "rabbet", "balk"))["reason"]) == "stuck", "route 177's balk lands on the far brick")
	_check(str(Sim.run(_by_id(177), _swap(_by_id(177), "rabbet", "turn"))["reason"]) == "stuck", "route 177's turn faces south and misses the hook")

	var let_rabbet: Dictionary = Sim.run(_by_id(178), _by_id(178)["reference"])
	_check(_color_at(_frame(let_rabbet, 4), 5, 2) == "red" and _dir_at(_frame(let_rabbet, 4), 5, 2) == 0 and _color_at(_frame(let_rabbet, 4), 4, 2) == "blue", "route 178 holds red while blue stands on the landing")
	_check(_color_at(_frame(let_rabbet, 5), 4, 2) == "red" and _dir_at(_frame(let_rabbet, 5), 4, 2) == 0 and _frame(let_rabbet, 5).get("delivered", []).size() == 1, "route 178 jumps once the landing is free and still faces east")

	var counted: Dictionary = Sim.run(_by_id(179), _by_id(179)["reference"])
	_check(str(counted["delivered"][0]["color"]) == "blue" and int(counted["delivered"][0]["count"]) == 1, "route 179 delivers blue count 1")
	_check(str(counted["delivered"][1]["color"]) == "red" and int(counted["delivered"][1]["count"]) == 2, "route 179 delivers red count 2")
	_check(_color_at(_frame(counted, 5), 3, 2) == "red" and _dir_at(_frame(counted, 5), 3, 2) == 0, "route 179 jumps one cell west and still faces east")
	_check(_color_at(_frame(counted, 8), 4, 1) == "red" and _count_at(_frame(counted, 8), 4, 1) == 2, "route 179's counter stamps 2")

	var clear: Dictionary = Sim.run(_by_id(180), _by_id(180)["reference"])
	_check(_at(_frame(clear, 4), 3, 2) and _dir_at(_frame(clear, 4), 3, 2) == 0, "route 180 waits facing east")
	_check(_at(_frame(clear, 5), 2, 2) and _dir_at(_frame(clear, 5), 2, 2) == 0, "route 180 lands one cell west and still faces east")
	_check(str(Sim.run(_by_id(180), _swap(_by_id(180), "rabbet", "balk"))["reason"]) == "stuck", "route 180's balk tries to land on the first brick")
	_check(str(Sim.run(_by_id(180), _swap(_by_id(180), "rabbet", "keel"))["reason"]) == "stuck", "route 180's keel tries to land on the far brick")

	var paired: Dictionary = Sim.run(_by_id(181), _by_id(181)["reference"])
	_check(_color_at(_frame(paired, 4), 6, 3) == "red" and _dir_at(_frame(paired, 4), 6, 3) == 0, "route 181 holds the east-facing parcel")
	_check(_color_at(_frame(paired, 4), 7, 1) == "blue" and _dir_at(_frame(paired, 4), 7, 1) == 3, "route 181 holds the north-facing parcel")
	_check(_frame(paired, 8).get("delivered", []).size() == 1 and str(_frame(paired, 8)["delivered"][0]["color"]) == "red", "route 181 delivers the east-facing parcel first")
	_check(int(paired["cycles"]) == 10, "route 181 delivers the north-facing parcel second")
	for cell in [Vector2i(6, 3), Vector2i(7, 1)]:
		for kind in ["return", "balk", "keel", "stealer", "garboard", "turn"]:
			var one: Dictionary = Sim.run(_by_id(181), _swap_cell(_by_id(181), cell.x, cell.y, kind))
			_check(not bool(one["success"]), "route 181 misses the dock if the rabbet at %d,%d is a %s" % [cell.x, cell.y, kind])

	var second: Dictionary = Sim.run(_by_id(182), _by_id(182)["reference"])
	_check(_at(_frame(second, 4), 5, 3) and _dir_at(_frame(second, 4), 5, 3) == 0, "route 182 waits on the first rabbet facing east")
	_check(_at(_frame(second, 5), 4, 3) and _dir_at(_frame(second, 5), 4, 3) == 0, "route 182 jumps one cell back and still faces east")
	_check(_at(_frame(second, 10), 3, 1) and _dir_at(_frame(second, 10), 3, 1) == 3, "route 182 reaches the second rabbet facing north")
	_check(_at(_frame(second, 12), 3, 2) and _dir_at(_frame(second, 12), 3, 2) == 3, "route 182 jumps one cell back on the new facing")
	_check(int(second["cycles"]) == 14, "route 182 delivers after the second backward jump")
	_check(not bool(Sim.run(_by_id(182), _omit_cell(_by_id(182), 5, 3))["success"]), "route 182 fails without the first rabbet")
	_check(not bool(Sim.run(_by_id(182), _omit_cell(_by_id(182), 3, 1))["success"]), "route 182 fails without the second rabbet")
	for cell in [Vector2i(5, 3), Vector2i(3, 1)]:
		for kind in ["return", "balk", "keel", "stealer", "garboard", "turn"]:
			var one: Dictionary = Sim.run(_by_id(182), _swap_cell(_by_id(182), cell.x, cell.y, kind))
			_check(not bool(one["success"]), "route 182 misses the dock if the rabbet at %d,%d is a %s" % [cell.x, cell.y, kind])

	var night: Dictionary = Sim.run(_by_id(183), _by_id(183)["reference"])
	_check(int(night["cycles"]) < 250, "route 183 finishes before tick 250")
	_check(str(night["delivered"][0]["color"]) == "red" and int(night["delivered"][0]["count"]) == 1, "route 183 stamps red 1")
	_check(str(night["delivered"][1]["color"]) == "yellow" and int(night["delivered"][1]["count"]) == 2, "route 183 stamps yellow 2")
	_check(str(night["delivered"][2]["color"]) == "blue" and int(night["delivered"][2]["count"]) == 3, "route 183 stamps blue 3")
	_check(_color_at(_frame(night, 8), 3, 2) == "red" and _dir_at(_frame(night, 8), 3, 2) == 0, "route 183 holds red facing east")
	_check(_color_at(_frame(night, 10), 2, 2) == "red" and _dir_at(_frame(night, 10), 2, 2) == 0, "route 183 jumps red one cell west and leaves it facing east")
	_check(_color_at(_frame(night, 14), 4, 0) == "red" and _dir_at(_frame(night, 14), 4, 0) == 0 and _count_at(_frame(night, 14), 4, 0) == 0, "route 183 reaches the counter still moving east")
	_check(not bool(Sim.run(_by_id(183), _swap(_by_id(183), "rabbet", "return"))["success"]), "route 183's return misses the counter")
	_check(not bool(Sim.run(_by_id(183), _swap(_by_id(183), "rabbet", "garboard"))["success"]), "route 183's garboard misses the hook")
	_check(not bool(Sim.run(_by_id(183), _swap(_by_id(183), "primer", "painter"))["success"]), "route 183 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(183), _swap(_by_id(183), "filter", "conveyor"))["success"]), "route 183 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(183), _swap(_by_id(183), "counter", "conveyor"))["success"]), "route 183 fails without the counter")


func _futtock_rules() -> void:
	print("futtock")
	var hop := {
		"width": 6, "height": 3, "walls": [],
		"sources": [{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 5, "y": 1},
		"order": [{"color": "gray"}],
	}
	var graph := [{"type": "futtock", "x": 1, "y": 1, "dir": 0}]
	var sent: Dictionary = Sim.run(hop, graph)
	_check(bool(sent["success"]), "a futtock jumps four cells forward and delivers")
	_check(int(sent["cycles"]) == 3 and int(sent["blocks"]) == 1, "the futtock waits a tick and delivers on tick 3")
	var born := _frame(sent, 1)
	var waited := _frame(sent, 2)
	_check(not born.is_empty() and _at(born, 1, 1) and _dir_at(born, 1, 1) == 0, "the parcel arrives facing east")
	_check(not waited.is_empty() and _at(waited, 1, 1) and _dir_at(waited, 1, 1) == 0 and not _at(waited, 5, 1), "the futtock does not move the parcel on that tick")
	_check(_count_at(waited, 1, 1) == 0 and _color_at(waited, 1, 1) == "gray", "a futtock does not stamp or paint")
	var tinted: Dictionary = Sim.run(hop, [{"type": "futtock", "x": 1, "y": 1, "dir": 0, "color": "red"}])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a futtock is ignored")
	for dir in range(4):
		var spun: Array = graph.duplicate(true)
		spun[0]["dir"] = dir
		var spun_run: Dictionary = Sim.run(hop, spun)
		_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == 3, "rotating a futtock does not change the jump")
	var over_bin: Dictionary = Sim.run(hop, [
		{"type": "futtock", "x": 1, "y": 1, "dir": 0},
		{"type": "bin", "x": 2, "y": 1, "dir": 0},
		{"type": "bin", "x": 3, "y": 1, "dir": 0},
		{"type": "bin", "x": 4, "y": 1, "dir": 0},
	])
	_check(bool(over_bin["success"]) and int(over_bin["cycles"]) == 3, "bins in the skipped cells do not stop the futtock")
	var skipped := false
	for frame in over_bin["frames"]:
		if _at(frame, 2, 1) or _at(frame, 3, 1) or _at(frame, 4, 1):
			skipped = true
	_check(not skipped, "the futtock does not enter any of the three cells in front")
	var lofted: Dictionary = Sim.run(hop, [{"type": "loft", "x": 1, "y": 1, "dir": 0}])
	_check(not bool(lofted["success"]) and str(lofted["reason"]) == "stuck", "a loft lands one cell short of a futtock")
	var shorted: Dictionary = Sim.run(hop, [
		{"type": "loft", "x": 1, "y": 1, "dir": 0},
		{"type": "bin", "x": 4, "y": 1, "dir": 0},
	])
	_check(not bool(shorted["success"]) and _at(_frame(shorted, 3), 4, 1) and _dir_at(_frame(shorted, 3), 4, 1) == 0, "a loft lands on the last cell a futtock skips")
	var vaulted: Dictionary = Sim.run(hop, [{"type": "vault", "x": 1, "y": 1, "dir": 0}])
	_check(not bool(vaulted["success"]) and str(vaulted["reason"]) == "stuck", "a vault lands two cells short of a futtock")
	var keeled: Dictionary = Sim.run(hop, [{"type": "keel", "x": 1, "y": 1, "dir": 0}])
	_check(not bool(keeled["success"]) and str(keeled["reason"]) == "stuck", "a keel jumps three cells back and misses the forward jump")
	var rabbeted: Dictionary = Sim.run(hop, [{"type": "rabbet", "x": 1, "y": 1, "dir": 0}])
	_check(not bool(rabbeted["success"]) and str(rabbeted["reason"]) == "stuck", "a rabbet jumps one cell back and misses the forward jump")
	var jumps := [
		{"name": "east", "src": Vector2i(0, 4), "arrival": 0, "futtock": Vector2i(1, 4), "land": Vector2i(5, 4), "dock": Vector2i(6, 4), "size": Vector2i(7, 6)},
		{"name": "south", "src": Vector2i(1, 0), "arrival": 1, "futtock": Vector2i(1, 1), "land": Vector2i(1, 5), "dock": Vector2i(1, 6), "size": Vector2i(3, 7)},
		{"name": "west", "src": Vector2i(6, 1), "arrival": 2, "futtock": Vector2i(5, 1), "land": Vector2i(1, 1), "dock": Vector2i(0, 1), "size": Vector2i(7, 3)},
		{"name": "north", "src": Vector2i(2, 6), "arrival": 3, "futtock": Vector2i(2, 5), "land": Vector2i(2, 1), "dock": Vector2i(2, 0), "size": Vector2i(3, 7)},
	]
	for spec in jumps:
		var src_at: Vector2i = spec["src"]
		var futtock_at: Vector2i = spec["futtock"]
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
			{"type": "futtock", "x": futtock_at.x, "y": futtock_at.y, "dir": 0},
			{"type": "pause", "x": land_at.x, "y": land_at.y, "dir": 0},
		]
		var side_run: Dictionary = Sim.run(strip, blocks)
		var moved := _frame(side_run, 3)
		_check(bool(side_run["success"]) and int(side_run["cycles"]) == 5, "a %s parcel jumps four cells forward and the pause follows the old facing" % str(spec["name"]))
		_check(not moved.is_empty() and _at(moved, land_at.x, land_at.y) and _dir_at(moved, land_at.x, land_at.y) == arrival, "a %s parcel still faces %s after the four-cell jump" % [str(spec["name"]), str(spec["name"])])
	var held_board := {
		"width": 7, "height": 6, "walls": [{"x": 6, "y": 4}],
		"sources": [
			{"x": 0, "y": 4, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 4, "y": 4, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 6, "y": 5},
		"order": [{"color": "gray"}],
	}
	var waiting: Dictionary = Sim.run(held_board, [
		{"type": "futtock", "x": 1, "y": 4, "dir": 0},
		{"type": "pause", "x": 5, "y": 4, "dir": 0},
	])
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a futtock keeps waiting while its landing stays blocked")
	_check(_at(_frame(waiting, 3), 1, 4) and _dir_at(_frame(waiting, 3), 1, 4) == 0 and _color_at(_frame(waiting, 5), 5, 4) == "blue", "the futtock keeps the arrival facing while the other parcel stays")
	var gap := {
		"width": 7, "height": 6, "walls": [],
		"sources": [
			{"x": 0, "y": 4, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 3, "y": 4, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 6, "y": 4},
		"order": [{"color": "blue"}, {"color": "gray"}],
	}
	var followed: Dictionary = Sim.run(gap, [
		{"type": "futtock", "x": 1, "y": 4, "dir": 0},
		{"type": "conveyor", "x": 4, "y": 4, "dir": 0},
		{"type": "pause", "x": 5, "y": 4, "dir": 0},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 6, "a futtock can land in a cell another parcel is leaving")
	var into := _frame(followed, 4)
	_check(not into.is_empty() and _color_at(into, 5, 4) == "gray" and _dir_at(into, 5, 4) == 0 and into.get("delivered", []).size() == 1, "the jump lands in the cell the other parcel left and still faces east")


func _building_twenty_six() -> void:
	print("building 26")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 190, "building 26 adds routes 184 through 190")
	_check(int(puzzles[182]["id"]) == 183, "route 183 is the last route before the futtock")
	_check(int(puzzles[183]["id"]) == 184, "the futtock begins at route 184")
	_check(Puzzles.INTRO.size() >= 30 and Puzzles.INTRO[29] == "futtock", "the futtock is the block building 26 teaches")
	_check(not Puzzles.unlocked_at(182).has("futtock"), "the futtock stays locked through route 183")
	_check(Puzzles.unlocked_at(183).has("futtock"), "route 184 unlocks the futtock")
	_check(Puzzles.unlocked_at(189).size() == 30, "building 26 ends with every block")
	var pars := {
		184: [6, 3],
		185: [7, 4],
		186: [7, 5],
		187: [5, 2],
		188: [7, 5],
		189: [7, 3],
		190: [16, 15],
	}
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id <= 183:
			_check(int(puzzle.get("building", 1)) < 26, "route %d stays out of building 26" % id)
			if id >= 177:
				_check(int(puzzle.get("building", 1)) == 25, "route %d stays in building 25" % id)
			continue
		if id > 190:
			continue
		_check(int(puzzle.get("building", 1)) == 26, "route %d is building 26" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		var locked: Array = pars[id]
		_check(int(par["cycles"]) == int(locked[0]) and int(par["blocks"]) == int(locked[1]), "route %d par is %d cycles and %d blocks" % [id, int(locked[0]), int(locked[1])])
		if id == 184:
			_check(str(puzzle.get("unlocks", "")) == "futtock", "route 184 teaches the futtock")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_futtock := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "futtock":
				uses_futtock = true
		_check(uses_futtock, "route %d reference uses the futtock" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	for id in [184, 185, 186, 187, 188, 189, 190]:
		for dir in range(4):
			var spun: Array = _by_id(id)["reference"].duplicate(true)
			for block in spun:
				if str(block["type"]) == "futtock":
					block["dir"] = dir
			var spun_run: Dictionary = Sim.run(_by_id(id), spun)
			_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == int(pars[id][0]), "route %d ignores which way the futtock block is rotated" % id)
		for kind in ["loft", "vault", "keel", "rabbet", "balk", "return", "turn", "hook", "pause", "conveyor", "slide", "garboard", "stealer", "bias", "cant", "strake", "wale", "shunt", "sheer", "sling", "bridge", "chute"]:
			var swapped: Dictionary = Sim.run(_by_id(id), _swap(_by_id(id), "futtock", kind))
			_check(not bool(swapped["success"]), "route %d fails if the futtock is a %s" % [id, kind])
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "futtock":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the futtock is missing" % id)

	var lesson: Dictionary = Sim.run(_by_id(184), _by_id(184)["reference"])
	_check(_at(_frame(lesson, 2), 2, 1) and _dir_at(_frame(lesson, 2), 2, 1) == 0, "route 184 starts the parcel facing east on the futtock")
	_check(_at(_frame(lesson, 3), 2, 1) and _dir_at(_frame(lesson, 3), 2, 1) == 0, "route 184 keeps the parcel facing east without moving it")
	_check(_at(_frame(lesson, 4), 6, 1) and _dir_at(_frame(lesson, 4), 6, 1) == 0, "route 184 jumps four cells east and still faces east")
	var lesson_entered := false
	for frame in lesson["frames"]:
		if _at(frame, 3, 1) or _at(frame, 4, 1) or _at(frame, 5, 1):
			lesson_entered = true
	_check(not lesson_entered, "route 184 does not enter the cells in front")
	_check(str(Sim.run(_by_id(184), _swap(_by_id(184), "futtock", "loft"))["reason"]) == "stuck", "route 184's loft lands on the last brick")
	_check(str(Sim.run(_by_id(184), _swap(_by_id(184), "futtock", "vault"))["reason"]) == "stuck", "route 184's vault lands on the middle brick")
	_check(str(Sim.run(_by_id(184), _swap(_by_id(184), "futtock", "keel"))["reason"]) == "stuck", "route 184's keel jumps three cells back")

	var let_futtock: Dictionary = Sim.run(_by_id(185), _by_id(185)["reference"])
	_check(_color_at(_frame(let_futtock, 4), 2, 1) == "red" and _dir_at(_frame(let_futtock, 4), 2, 1) == 0 and _color_at(_frame(let_futtock, 4), 6, 1) == "blue", "route 185 holds red while blue stands on the landing")
	_check(_color_at(_frame(let_futtock, 5), 6, 1) == "red" and _dir_at(_frame(let_futtock, 5), 6, 1) == 0 and _frame(let_futtock, 5).get("delivered", []).size() == 1, "route 185 jumps once the landing is free and still faces east")

	var counted: Dictionary = Sim.run(_by_id(186), _by_id(186)["reference"])
	_check(str(counted["delivered"][0]["color"]) == "blue" and int(counted["delivered"][0]["count"]) == 1, "route 186 delivers blue count 1")
	_check(str(counted["delivered"][1]["color"]) == "red" and int(counted["delivered"][1]["count"]) == 2, "route 186 delivers red count 2")
	_check(_color_at(_frame(counted, 3), 5, 1) == "red" and _dir_at(_frame(counted, 3), 5, 1) == 0, "route 186 jumps four cells east and still faces east")
	_check(_color_at(_frame(counted, 6), 7, 1) == "red" and _count_at(_frame(counted, 6), 7, 1) == 2, "route 186's counter stamps 2")

	var clear: Dictionary = Sim.run(_by_id(187), _by_id(187)["reference"])
	_check(_at(_frame(clear, 2), 1, 1) and _dir_at(_frame(clear, 2), 1, 1) == 0, "route 187 waits facing east")
	_check(_at(_frame(clear, 3), 5, 1) and _dir_at(_frame(clear, 3), 5, 1) == 0, "route 187 lands four cells east and still faces east")
	var brick_entered := false
	for frame in clear["frames"]:
		if _at(frame, 2, 1) or _at(frame, 3, 1) or _at(frame, 4, 1):
			brick_entered = true
	_check(not brick_entered, "route 187 does not enter any brick")
	_check(str(Sim.run(_by_id(187), _swap(_by_id(187), "futtock", "loft"))["reason"]) == "stuck", "route 187's loft tries to land on the last brick")
	_check(str(Sim.run(_by_id(187), _swap(_by_id(187), "futtock", "vault"))["reason"]) == "stuck", "route 187's vault tries to land on the middle brick")

	var paired: Dictionary = Sim.run(_by_id(188), _by_id(188)["reference"])
	_check(_color_at(_frame(paired, 2), 1, 7) == "red" and _dir_at(_frame(paired, 2), 1, 7) == 0, "route 188 holds the east-facing parcel")
	_check(_color_at(_frame(paired, 4), 6, 2) == "blue" and _dir_at(_frame(paired, 4), 6, 2) == 1, "route 188 holds the south-facing parcel")
	_check(_frame(paired, 5).get("delivered", []).size() == 1 and str(_frame(paired, 5)["delivered"][0]["color"]) == "red", "route 188 delivers the east-facing parcel first")
	_check(int(paired["cycles"]) == 7, "route 188 delivers the south-facing parcel second")
	for cell in [Vector2i(1, 7), Vector2i(6, 2)]:
		for kind in ["loft", "vault", "keel"]:
			var one: Dictionary = Sim.run(_by_id(188), _swap_cell(_by_id(188), cell.x, cell.y, kind))
			_check(not bool(one["success"]), "route 188 misses the dock if the futtock at %d,%d is a %s" % [cell.x, cell.y, kind])

	var second: Dictionary = Sim.run(_by_id(189), _by_id(189)["reference"])
	_check(_at(_frame(second, 2), 1, 5) and _dir_at(_frame(second, 2), 1, 5) == 0, "route 189 waits on the first futtock facing east")
	_check(_at(_frame(second, 3), 5, 5) and _dir_at(_frame(second, 3), 5, 5) == 0, "route 189 jumps four cells forward and still faces east")
	_check(_at(_frame(second, 5), 5, 4) and _dir_at(_frame(second, 5), 5, 4) == 3, "route 189 reaches the second futtock facing north")
	_check(_at(_frame(second, 6), 5, 4) and _dir_at(_frame(second, 6), 5, 4) == 3, "route 189 waits on the second futtock facing north")
	_check(int(second["cycles"]) == 7, "route 189 jumps four cells forward on the new facing")
	_check(not bool(Sim.run(_by_id(189), _omit_cell(_by_id(189), 1, 5))["success"]), "route 189 fails without the first futtock")
	_check(not bool(Sim.run(_by_id(189), _omit_cell(_by_id(189), 5, 4))["success"]), "route 189 fails without the second futtock")
	for cell in [Vector2i(1, 5), Vector2i(5, 4)]:
		for kind in ["loft", "vault", "keel"]:
			var missed: Dictionary = Sim.run(_by_id(189), _swap_cell(_by_id(189), cell.x, cell.y, kind))
			_check(not bool(missed["success"]), "route 189 misses the dock if the futtock at %d,%d is a %s" % [cell.x, cell.y, kind])

	var night: Dictionary = Sim.run(_by_id(190), _by_id(190)["reference"])
	_check(int(night["cycles"]) < 250, "route 190 finishes before tick 250")
	_check(str(night["delivered"][0]["color"]) == "red" and int(night["delivered"][0]["count"]) == 1, "route 190 stamps red 1")
	_check(str(night["delivered"][1]["color"]) == "yellow" and int(night["delivered"][1]["count"]) == 2, "route 190 stamps yellow 2")
	_check(str(night["delivered"][2]["color"]) == "blue" and int(night["delivered"][2]["count"]) == 3, "route 190 stamps blue 3")
	_check(_color_at(_frame(night, 6), 3, 3) == "red" and _dir_at(_frame(night, 6), 3, 3) == 0, "route 190 holds red facing east")
	_check(_color_at(_frame(night, 8), 7, 3) == "red" and _dir_at(_frame(night, 8), 7, 3) == 0, "route 190 jumps red four cells east and leaves it facing east")
	_check(_color_at(_frame(night, 10), 8, 3) == "red" and _dir_at(_frame(night, 10), 8, 3) == 0 and _count_at(_frame(night, 10), 8, 3) == 0, "route 190 reaches the counter still facing east")
	var night_entered := false
	for frame in night["frames"]:
		if _color_at(frame, 4, 3) == "red" or _color_at(frame, 5, 3) == "red" or _color_at(frame, 6, 3) == "red":
			night_entered = true
	_check(not night_entered, "route 190 does not enter the cells in front")
	_check(not bool(Sim.run(_by_id(190), _swap(_by_id(190), "futtock", "loft"))["success"]), "route 190's loft misses the pause")
	_check(not bool(Sim.run(_by_id(190), _swap(_by_id(190), "futtock", "vault"))["success"]), "route 190's vault misses the pause")
	_check(not bool(Sim.run(_by_id(190), _swap(_by_id(190), "futtock", "keel"))["success"]), "route 190's keel misses the pause")
	_check(not bool(Sim.run(_by_id(190), _swap(_by_id(190), "primer", "painter"))["success"]), "route 190 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(190), _swap(_by_id(190), "filter", "conveyor"))["success"]), "route 190 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(190), _swap(_by_id(190), "counter", "conveyor"))["success"]), "route 190 fails without the counter")


func _keelson_rules() -> void:
	print("keelson")
	var hop := {
		"width": 7, "height": 3, "walls": [],
		"sources": [{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 6, "y": 1},
		"order": [{"color": "gray"}],
	}
	var graph := [{"type": "keelson", "x": 1, "y": 1, "dir": 0}]
	var sent: Dictionary = Sim.run(hop, graph)
	_check(bool(sent["success"]), "a keelson jumps five cells forward and delivers")
	_check(int(sent["cycles"]) == 3 and int(sent["blocks"]) == 1, "the keelson waits a tick and delivers on tick 3")
	var born := _frame(sent, 1)
	var waited := _frame(sent, 2)
	_check(not born.is_empty() and _at(born, 1, 1) and _dir_at(born, 1, 1) == 0, "the parcel arrives facing east")
	_check(not waited.is_empty() and _at(waited, 1, 1) and _dir_at(waited, 1, 1) == 0 and not _at(waited, 6, 1), "the keelson does not move the parcel on that tick")
	_check(_count_at(waited, 1, 1) == 0 and _color_at(waited, 1, 1) == "gray", "a keelson does not stamp or paint")
	var tinted: Dictionary = Sim.run(hop, [{"type": "keelson", "x": 1, "y": 1, "dir": 0, "color": "red"}])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a keelson is ignored")
	for dir in range(4):
		var spun: Array = graph.duplicate(true)
		spun[0]["dir"] = dir
		var spun_run: Dictionary = Sim.run(hop, spun)
		_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == 3, "rotating a keelson does not change the jump")
	var over_bin: Dictionary = Sim.run(hop, [
		{"type": "keelson", "x": 1, "y": 1, "dir": 0},
		{"type": "bin", "x": 2, "y": 1, "dir": 0},
		{"type": "bin", "x": 3, "y": 1, "dir": 0},
		{"type": "bin", "x": 4, "y": 1, "dir": 0},
		{"type": "bin", "x": 5, "y": 1, "dir": 0},
	])
	_check(bool(over_bin["success"]) and int(over_bin["cycles"]) == 3, "bins in the skipped cells do not stop the keelson")
	var skipped := false
	for frame in over_bin["frames"]:
		if _at(frame, 2, 1) or _at(frame, 3, 1) or _at(frame, 4, 1) or _at(frame, 5, 1):
			skipped = true
	_check(not skipped, "the keelson does not enter any of the four cells in front")
	var short_futtock: Dictionary = Sim.run(hop, [
		{"type": "futtock", "x": 1, "y": 1, "dir": 0},
		{"type": "bin", "x": 5, "y": 1, "dir": 0},
	])
	_check(not bool(short_futtock["success"]) and _at(_frame(short_futtock, 3), 5, 1) and _dir_at(_frame(short_futtock, 3), 5, 1) == 0, "a futtock lands one cell short of a keelson")
	var short_loft: Dictionary = Sim.run(hop, [
		{"type": "loft", "x": 1, "y": 1, "dir": 0},
		{"type": "bin", "x": 4, "y": 1, "dir": 0},
	])
	_check(not bool(short_loft["success"]) and _at(_frame(short_loft, 3), 4, 1) and _dir_at(_frame(short_loft, 3), 4, 1) == 0, "a loft lands two cells short of a keelson")
	var short_vault: Dictionary = Sim.run(hop, [
		{"type": "vault", "x": 1, "y": 1, "dir": 0},
		{"type": "bin", "x": 3, "y": 1, "dir": 0},
	])
	_check(not bool(short_vault["success"]) and _at(_frame(short_vault, 3), 3, 1) and _dir_at(_frame(short_vault, 3), 3, 1) == 0, "a vault lands three cells short of a keelson")
	var keeled: Dictionary = Sim.run(hop, [{"type": "keel", "x": 1, "y": 1, "dir": 0}])
	_check(not bool(keeled["success"]) and str(keeled["reason"]) == "stuck", "a keel jumps three cells back and misses the forward jump")
	var rabbeted: Dictionary = Sim.run(hop, [{"type": "rabbet", "x": 1, "y": 1, "dir": 0}])
	_check(not bool(rabbeted["success"]) and str(rabbeted["reason"]) == "stuck", "a rabbet jumps one cell back and misses the forward jump")
	var jumps := [
		{"name": "east", "src": Vector2i(0, 4), "arrival": 0, "keelson": Vector2i(1, 4), "land": Vector2i(6, 4), "dock": Vector2i(7, 4), "size": Vector2i(8, 6)},
		{"name": "south", "src": Vector2i(1, 0), "arrival": 1, "keelson": Vector2i(1, 1), "land": Vector2i(1, 6), "dock": Vector2i(1, 7), "size": Vector2i(3, 8)},
		{"name": "west", "src": Vector2i(7, 1), "arrival": 2, "keelson": Vector2i(6, 1), "land": Vector2i(1, 1), "dock": Vector2i(0, 1), "size": Vector2i(8, 3)},
		{"name": "north", "src": Vector2i(2, 7), "arrival": 3, "keelson": Vector2i(2, 6), "land": Vector2i(2, 1), "dock": Vector2i(2, 0), "size": Vector2i(3, 8)},
	]
	for spec in jumps:
		var src_at: Vector2i = spec["src"]
		var keelson_at: Vector2i = spec["keelson"]
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
			{"type": "keelson", "x": keelson_at.x, "y": keelson_at.y, "dir": 0},
			{"type": "pause", "x": land_at.x, "y": land_at.y, "dir": 0},
		]
		var side_run: Dictionary = Sim.run(strip, blocks)
		var moved := _frame(side_run, 3)
		_check(bool(side_run["success"]) and int(side_run["cycles"]) == 5, "a %s parcel jumps five cells forward and the pause follows the old facing" % str(spec["name"]))
		_check(not moved.is_empty() and _at(moved, land_at.x, land_at.y) and _dir_at(moved, land_at.x, land_at.y) == arrival, "a %s parcel still faces %s after the five-cell jump" % [str(spec["name"]), str(spec["name"])])
	var held_board := {
		"width": 8, "height": 6, "walls": [{"x": 7, "y": 4}],
		"sources": [
			{"x": 0, "y": 4, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 5, "y": 4, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 7, "y": 5},
		"order": [{"color": "gray"}],
	}
	var waiting: Dictionary = Sim.run(held_board, [
		{"type": "keelson", "x": 1, "y": 4, "dir": 0},
		{"type": "pause", "x": 6, "y": 4, "dir": 0},
	])
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a keelson keeps waiting while its landing stays blocked")
	_check(_at(_frame(waiting, 3), 1, 4) and _dir_at(_frame(waiting, 3), 1, 4) == 0 and _color_at(_frame(waiting, 5), 6, 4) == "blue", "the keelson keeps the arrival facing while the other parcel stays")
	var gap := {
		"width": 8, "height": 6, "walls": [],
		"sources": [
			{"x": 0, "y": 4, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 4, "y": 4, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 7, "y": 4},
		"order": [{"color": "blue"}, {"color": "gray"}],
	}
	var followed: Dictionary = Sim.run(gap, [
		{"type": "keelson", "x": 1, "y": 4, "dir": 0},
		{"type": "conveyor", "x": 5, "y": 4, "dir": 0},
		{"type": "pause", "x": 6, "y": 4, "dir": 0},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 6, "a keelson can land in a cell another parcel is leaving")
	var into := _frame(followed, 4)
	_check(not into.is_empty() and _color_at(into, 6, 4) == "gray" and _dir_at(into, 6, 4) == 0 and into.get("delivered", []).size() == 1, "the jump lands in the cell the other parcel left and still faces east")


func _building_twenty_seven() -> void:
	print("building 27")
	var puzzles := Puzzles.all()
	_check(puzzles.size() >= 197, "building 27 adds routes 191 through 197")
	_check(int(puzzles[189]["id"]) == 190, "route 190 is the last route before the keelson")
	_check(int(puzzles[190]["id"]) == 191, "the keelson begins at route 191")
	_check(Puzzles.INTRO.size() >= 31 and Puzzles.INTRO[30] == "keelson", "the keelson is the block building 27 teaches")
	_check(not Puzzles.unlocked_at(189).has("keelson"), "the keelson stays locked through route 190")
	_check(Puzzles.unlocked_at(190).has("keelson"), "route 191 unlocks the keelson")
	_check(Puzzles.unlocked_at(196).size() == 31, "building 27 ends with every block")
	var pars := {
		191: [6, 3],
		192: [7, 4],
		193: [7, 5],
		194: [5, 2],
		195: [7, 5],
		196: [7, 3],
		197: [17, 16],
	}
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id <= 190:
			_check(int(puzzle.get("building", 1)) < 27, "route %d stays out of building 27" % id)
			if id >= 184:
				_check(int(puzzle.get("building", 1)) == 26, "route %d stays in building 26" % id)
			continue
		if id > 197:
			continue
		_check(int(puzzle.get("building", 1)) == 27, "route %d is building 27" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		var locked: Array = pars[id]
		_check(int(par["cycles"]) == int(locked[0]) and int(par["blocks"]) == int(locked[1]), "route %d par is %d cycles and %d blocks" % [id, int(locked[0]), int(locked[1])])
		if id == 191:
			_check(str(puzzle.get("unlocks", "")) == "keelson", "route 191 teaches the keelson")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_keelson := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "keelson":
				uses_keelson = true
		_check(uses_keelson, "route %d reference uses the keelson" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	for id in [191, 192, 193, 194, 195, 196, 197]:
		for dir in range(4):
			var spun: Array = _by_id(id)["reference"].duplicate(true)
			for block in spun:
				if str(block["type"]) == "keelson":
					block["dir"] = dir
			var spun_run: Dictionary = Sim.run(_by_id(id), spun)
			_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == int(pars[id][0]), "route %d ignores which way the keelson block is rotated" % id)
		for kind in ["futtock", "loft", "vault", "keel", "rabbet", "balk", "return", "turn", "hook", "pause", "conveyor", "slide", "garboard", "stealer", "bias", "cant", "strake", "wale", "shunt", "sheer", "sling", "bridge", "chute"]:
			var swapped: Dictionary = Sim.run(_by_id(id), _swap(_by_id(id), "keelson", kind))
			_check(not bool(swapped["success"]), "route %d fails if the keelson is a %s" % [id, kind])
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "keelson":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the keelson is missing" % id)

	var lesson: Dictionary = Sim.run(_by_id(191), _by_id(191)["reference"])
	_check(_at(_frame(lesson, 2), 2, 1) and _dir_at(_frame(lesson, 2), 2, 1) == 0, "route 191 starts the parcel facing east on the keelson")
	_check(_at(_frame(lesson, 3), 2, 1) and _dir_at(_frame(lesson, 3), 2, 1) == 0, "route 191 keeps the parcel facing east without moving it")
	_check(_at(_frame(lesson, 4), 7, 1) and _dir_at(_frame(lesson, 4), 7, 1) == 0, "route 191 jumps five cells east and still faces east")
	var lesson_entered := false
	for frame in lesson["frames"]:
		if _at(frame, 3, 1) or _at(frame, 4, 1) or _at(frame, 5, 1) or _at(frame, 6, 1):
			lesson_entered = true
	_check(not lesson_entered, "route 191 does not enter the cells in front")
	_check(str(Sim.run(_by_id(191), _swap(_by_id(191), "keelson", "futtock"))["reason"]) == "stuck", "route 191's futtock lands on the last brick")
	_check(str(Sim.run(_by_id(191), _swap(_by_id(191), "keelson", "loft"))["reason"]) == "stuck", "route 191's loft lands two cells short")
	_check(str(Sim.run(_by_id(191), _swap(_by_id(191), "keelson", "vault"))["reason"]) == "stuck", "route 191's vault lands three cells short")
	_check(str(Sim.run(_by_id(191), _swap(_by_id(191), "keelson", "keel"))["reason"]) == "stuck", "route 191's keel jumps three cells back")

	var let_keelson: Dictionary = Sim.run(_by_id(192), _by_id(192)["reference"])
	_check(_color_at(_frame(let_keelson, 4), 2, 1) == "red" and _dir_at(_frame(let_keelson, 4), 2, 1) == 0 and _color_at(_frame(let_keelson, 4), 7, 1) == "blue", "route 192 holds red while blue stands on the landing")
	_check(_color_at(_frame(let_keelson, 5), 7, 1) == "red" and _dir_at(_frame(let_keelson, 5), 7, 1) == 0 and _frame(let_keelson, 5).get("delivered", []).size() == 1, "route 192 jumps once the landing is free and still faces east")

	var counted: Dictionary = Sim.run(_by_id(193), _by_id(193)["reference"])
	_check(str(counted["delivered"][0]["color"]) == "blue" and int(counted["delivered"][0]["count"]) == 1, "route 193 delivers blue count 1")
	_check(str(counted["delivered"][1]["color"]) == "red" and int(counted["delivered"][1]["count"]) == 2, "route 193 delivers red count 2")
	_check(_color_at(_frame(counted, 3), 6, 1) == "red" and _dir_at(_frame(counted, 3), 6, 1) == 0, "route 193 jumps five cells east and still faces east")
	_check(_color_at(_frame(counted, 6), 8, 1) == "red" and _count_at(_frame(counted, 6), 8, 1) == 2, "route 193's counter stamps 2")

	var clear: Dictionary = Sim.run(_by_id(194), _by_id(194)["reference"])
	_check(_at(_frame(clear, 2), 1, 1) and _dir_at(_frame(clear, 2), 1, 1) == 0, "route 194 waits facing east")
	_check(_at(_frame(clear, 3), 6, 1) and _dir_at(_frame(clear, 3), 6, 1) == 0, "route 194 lands five cells east and still faces east")
	var brick_entered := false
	for frame in clear["frames"]:
		if _at(frame, 2, 1) or _at(frame, 3, 1) or _at(frame, 4, 1) or _at(frame, 5, 1):
			brick_entered = true
	_check(not brick_entered, "route 194 does not enter any brick")
	_check(str(Sim.run(_by_id(194), _swap(_by_id(194), "keelson", "futtock"))["reason"]) == "stuck", "route 194's futtock tries to land on the last brick")
	_check(str(Sim.run(_by_id(194), _swap(_by_id(194), "keelson", "loft"))["reason"]) == "stuck", "route 194's loft lands two cells short")

	var paired: Dictionary = Sim.run(_by_id(195), _by_id(195)["reference"])
	_check(_color_at(_frame(paired, 2), 1, 8) == "red" and _dir_at(_frame(paired, 2), 1, 8) == 0, "route 195 holds the east-facing parcel")
	_check(_color_at(_frame(paired, 4), 7, 2) == "blue" and _dir_at(_frame(paired, 4), 7, 2) == 1, "route 195 holds the south-facing parcel")
	_check(_frame(paired, 5).get("delivered", []).size() == 1 and str(_frame(paired, 5)["delivered"][0]["color"]) == "red", "route 195 delivers the east-facing parcel first")
	_check(int(paired["cycles"]) == 7, "route 195 delivers the south-facing parcel second")
	for cell in [Vector2i(1, 8), Vector2i(7, 2)]:
		for kind in ["futtock", "loft", "vault", "keel"]:
			var one: Dictionary = Sim.run(_by_id(195), _swap_cell(_by_id(195), cell.x, cell.y, kind))
			_check(not bool(one["success"]), "route 195 misses the dock if the keelson at %d,%d is a %s" % [cell.x, cell.y, kind])

	var second: Dictionary = Sim.run(_by_id(196), _by_id(196)["reference"])
	_check(_at(_frame(second, 2), 1, 6) and _dir_at(_frame(second, 2), 1, 6) == 0, "route 196 waits on the first keelson facing east")
	_check(_at(_frame(second, 3), 6, 6) and _dir_at(_frame(second, 3), 6, 6) == 0, "route 196 jumps five cells forward and still faces east")
	_check(_at(_frame(second, 5), 6, 5) and _dir_at(_frame(second, 5), 6, 5) == 3, "route 196 reaches the second keelson facing north")
	_check(_at(_frame(second, 6), 6, 5) and _dir_at(_frame(second, 6), 6, 5) == 3, "route 196 waits on the second keelson facing north")
	_check(int(second["cycles"]) == 7, "route 196 jumps five cells forward on the new facing")
	_check(not bool(Sim.run(_by_id(196), _omit_cell(_by_id(196), 1, 6))["success"]), "route 196 fails without the first keelson")
	_check(not bool(Sim.run(_by_id(196), _omit_cell(_by_id(196), 6, 5))["success"]), "route 196 fails without the second keelson")
	for cell in [Vector2i(1, 6), Vector2i(6, 5)]:
		for kind in ["futtock", "loft", "vault", "keel"]:
			var missed: Dictionary = Sim.run(_by_id(196), _swap_cell(_by_id(196), cell.x, cell.y, kind))
			_check(not bool(missed["success"]), "route 196 misses the dock if the keelson at %d,%d is a %s" % [cell.x, cell.y, kind])

	var night: Dictionary = Sim.run(_by_id(197), _by_id(197)["reference"])
	_check(int(night["cycles"]) < 250, "route 197 finishes before tick 250")
	_check(str(night["delivered"][0]["color"]) == "red" and int(night["delivered"][0]["count"]) == 1, "route 197 stamps red 1")
	_check(str(night["delivered"][1]["color"]) == "yellow" and int(night["delivered"][1]["count"]) == 2, "route 197 stamps yellow 2")
	_check(str(night["delivered"][2]["color"]) == "blue" and int(night["delivered"][2]["count"]) == 3, "route 197 stamps blue 3")
	_check(_color_at(_frame(night, 6), 3, 3) == "red" and _dir_at(_frame(night, 6), 3, 3) == 0, "route 197 holds red facing east")
	_check(_color_at(_frame(night, 8), 8, 3) == "red" and _dir_at(_frame(night, 8), 8, 3) == 0, "route 197 jumps red five cells east and leaves it facing east")
	_check(_color_at(_frame(night, 10), 9, 3) == "red" and _dir_at(_frame(night, 10), 9, 3) == 0 and _count_at(_frame(night, 10), 9, 3) == 0, "route 197 reaches the counter still facing east")
	var night_entered := false
	for frame in night["frames"]:
		if _color_at(frame, 4, 3) == "red" or _color_at(frame, 5, 3) == "red" or _color_at(frame, 6, 3) == "red" or _color_at(frame, 7, 3) == "red":
			night_entered = true
	_check(not night_entered, "route 197 does not enter the cells in front")
	_check(not bool(Sim.run(_by_id(197), _swap(_by_id(197), "keelson", "futtock"))["success"]), "route 197's futtock misses the pause")
	_check(not bool(Sim.run(_by_id(197), _swap(_by_id(197), "keelson", "loft"))["success"]), "route 197's loft misses the pause")
	_check(not bool(Sim.run(_by_id(197), _swap(_by_id(197), "keelson", "vault"))["success"]), "route 197's vault misses the pause")
	_check(not bool(Sim.run(_by_id(197), _swap(_by_id(197), "keelson", "keel"))["success"]), "route 197's keel misses the pause")
	_check(not bool(Sim.run(_by_id(197), _swap(_by_id(197), "primer", "painter"))["success"]), "route 197 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(197), _swap(_by_id(197), "filter", "conveyor"))["success"]), "route 197 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(197), _swap(_by_id(197), "counter", "conveyor"))["success"]), "route 197 fails without the counter")


func _stemson_rules() -> void:
	print("stemson")
	var hop := {
		"width": 8, "height": 3, "walls": [],
		"sources": [{"x": 0, "y": 1, "dir": 0, "parcels": [{"color": "gray"}]}],
		"dock": {"x": 7, "y": 1},
		"order": [{"color": "gray"}],
	}
	var graph := [{"type": "stemson", "x": 1, "y": 1, "dir": 0}]
	var sent: Dictionary = Sim.run(hop, graph)
	_check(bool(sent["success"]), "a stemson jumps six cells forward and delivers")
	_check(int(sent["cycles"]) == 3 and int(sent["blocks"]) == 1, "the stemson waits a tick and delivers on tick 3")
	var born := _frame(sent, 1)
	var waited := _frame(sent, 2)
	_check(not born.is_empty() and _at(born, 1, 1) and _dir_at(born, 1, 1) == 0, "the parcel arrives facing east")
	_check(not waited.is_empty() and _at(waited, 1, 1) and _dir_at(waited, 1, 1) == 0 and not _at(waited, 7, 1), "the stemson does not move the parcel on that tick")
	_check(_count_at(waited, 1, 1) == 0 and _color_at(waited, 1, 1) == "gray", "a stemson does not stamp or paint")
	var tinted: Dictionary = Sim.run(hop, [{"type": "stemson", "x": 1, "y": 1, "dir": 0, "color": "red"}])
	_check(bool(tinted["success"]) and str(tinted["delivered"][0]["color"]) == "gray" and int(tinted["delivered"][0]["count"]) == 0, "a color on a stemson is ignored")
	for dir in range(4):
		var spun: Array = graph.duplicate(true)
		spun[0]["dir"] = dir
		var spun_run: Dictionary = Sim.run(hop, spun)
		_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == 3, "rotating a stemson does not change the jump")
	var over_bin: Dictionary = Sim.run(hop, [
		{"type": "stemson", "x": 1, "y": 1, "dir": 0},
		{"type": "bin", "x": 2, "y": 1, "dir": 0},
		{"type": "bin", "x": 3, "y": 1, "dir": 0},
		{"type": "bin", "x": 4, "y": 1, "dir": 0},
		{"type": "bin", "x": 5, "y": 1, "dir": 0},
		{"type": "bin", "x": 6, "y": 1, "dir": 0},
	])
	_check(bool(over_bin["success"]) and int(over_bin["cycles"]) == 3, "bins in the skipped cells do not stop the stemson")
	var skipped := false
	for frame in over_bin["frames"]:
		if _at(frame, 2, 1) or _at(frame, 3, 1) or _at(frame, 4, 1) or _at(frame, 5, 1) or _at(frame, 6, 1):
			skipped = true
	_check(not skipped, "the stemson does not enter any of the five cells in front")
	var short_keelson: Dictionary = Sim.run(hop, [
		{"type": "keelson", "x": 1, "y": 1, "dir": 0},
		{"type": "bin", "x": 6, "y": 1, "dir": 0},
	])
	_check(not bool(short_keelson["success"]) and _at(_frame(short_keelson, 3), 6, 1) and _dir_at(_frame(short_keelson, 3), 6, 1) == 0, "a keelson lands one cell short of a stemson")
	var short_futtock: Dictionary = Sim.run(hop, [
		{"type": "futtock", "x": 1, "y": 1, "dir": 0},
		{"type": "bin", "x": 5, "y": 1, "dir": 0},
	])
	_check(not bool(short_futtock["success"]) and _at(_frame(short_futtock, 3), 5, 1) and _dir_at(_frame(short_futtock, 3), 5, 1) == 0, "a futtock lands two cells short of a stemson")
	var short_loft: Dictionary = Sim.run(hop, [
		{"type": "loft", "x": 1, "y": 1, "dir": 0},
		{"type": "bin", "x": 4, "y": 1, "dir": 0},
	])
	_check(not bool(short_loft["success"]) and _at(_frame(short_loft, 3), 4, 1) and _dir_at(_frame(short_loft, 3), 4, 1) == 0, "a loft lands three cells short of a stemson")
	var short_vault: Dictionary = Sim.run(hop, [
		{"type": "vault", "x": 1, "y": 1, "dir": 0},
		{"type": "bin", "x": 3, "y": 1, "dir": 0},
	])
	_check(not bool(short_vault["success"]) and _at(_frame(short_vault, 3), 3, 1) and _dir_at(_frame(short_vault, 3), 3, 1) == 0, "a vault lands four cells short of a stemson")
	var keeled: Dictionary = Sim.run(hop, [{"type": "keel", "x": 1, "y": 1, "dir": 0}])
	_check(not bool(keeled["success"]) and str(keeled["reason"]) == "stuck", "a keel jumps three cells back and misses the forward jump")
	var rabbeted: Dictionary = Sim.run(hop, [{"type": "rabbet", "x": 1, "y": 1, "dir": 0}])
	_check(not bool(rabbeted["success"]) and str(rabbeted["reason"]) == "stuck", "a rabbet jumps one cell back and misses the forward jump")
	var jumps := [
		{"name": "east", "src": Vector2i(0, 4), "arrival": 0, "stemson": Vector2i(1, 4), "land": Vector2i(7, 4), "dock": Vector2i(8, 4), "size": Vector2i(9, 6)},
		{"name": "south", "src": Vector2i(1, 0), "arrival": 1, "stemson": Vector2i(1, 1), "land": Vector2i(1, 7), "dock": Vector2i(1, 8), "size": Vector2i(3, 9)},
		{"name": "west", "src": Vector2i(8, 1), "arrival": 2, "stemson": Vector2i(7, 1), "land": Vector2i(1, 1), "dock": Vector2i(0, 1), "size": Vector2i(9, 3)},
		{"name": "north", "src": Vector2i(2, 8), "arrival": 3, "stemson": Vector2i(2, 7), "land": Vector2i(2, 1), "dock": Vector2i(2, 0), "size": Vector2i(3, 9)},
	]
	for spec in jumps:
		var src_at: Vector2i = spec["src"]
		var stemson_at: Vector2i = spec["stemson"]
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
			{"type": "stemson", "x": stemson_at.x, "y": stemson_at.y, "dir": 0},
			{"type": "pause", "x": land_at.x, "y": land_at.y, "dir": 0},
		]
		var side_run: Dictionary = Sim.run(strip, blocks)
		var moved := _frame(side_run, 3)
		_check(bool(side_run["success"]) and int(side_run["cycles"]) == 5, "a %s parcel jumps six cells forward and the pause follows the old facing" % str(spec["name"]))
		_check(not moved.is_empty() and _at(moved, land_at.x, land_at.y) and _dir_at(moved, land_at.x, land_at.y) == arrival, "a %s parcel still faces %s after the six-cell jump" % [str(spec["name"]), str(spec["name"])])
	var held_board := {
		"width": 9, "height": 6, "walls": [{"x": 8, "y": 4}],
		"sources": [
			{"x": 0, "y": 4, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 6, "y": 4, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 8, "y": 5},
		"order": [{"color": "gray"}],
	}
	var waiting: Dictionary = Sim.run(held_board, [
		{"type": "stemson", "x": 1, "y": 4, "dir": 0},
		{"type": "pause", "x": 7, "y": 4, "dir": 0},
	])
	_check(not bool(waiting["success"]) and str(waiting["reason"]) == "tick_cap", "a stemson keeps waiting while its landing stays blocked")
	_check(_at(_frame(waiting, 3), 1, 4) and _dir_at(_frame(waiting, 3), 1, 4) == 0 and _color_at(_frame(waiting, 5), 7, 4) == "blue", "the stemson keeps the arrival facing while the other parcel stays")
	var gap := {
		"width": 9, "height": 6, "walls": [],
		"sources": [
			{"x": 0, "y": 4, "dir": 0, "parcels": [{"color": "gray"}]},
			{"x": 5, "y": 4, "dir": 0, "parcels": [{"color": "blue"}]},
		],
		"dock": {"x": 8, "y": 4},
		"order": [{"color": "blue"}, {"color": "gray"}],
	}
	var followed: Dictionary = Sim.run(gap, [
		{"type": "stemson", "x": 1, "y": 4, "dir": 0},
		{"type": "conveyor", "x": 6, "y": 4, "dir": 0},
		{"type": "pause", "x": 7, "y": 4, "dir": 0},
	])
	_check(bool(followed["success"]) and int(followed["cycles"]) == 6, "a stemson can land in a cell another parcel is leaving")
	var into := _frame(followed, 4)
	_check(not into.is_empty() and _color_at(into, 7, 4) == "gray" and _dir_at(into, 7, 4) == 0 and into.get("delivered", []).size() == 1, "the jump lands in the cell the other parcel left and still faces east")


func _building_twenty_eight() -> void:
	print("building 28")
	var puzzles := Puzzles.all()
	_check(puzzles.size() == 204, "building 28 adds routes 198 through 204")
	_check(int(puzzles[196]["id"]) == 197, "route 197 is the last route before the stemson")
	_check(int(puzzles[197]["id"]) == 198, "the stemson begins at route 198")
	_check(Puzzles.INTRO.size() == 32 and Puzzles.INTRO[31] == "stemson", "the stemson is the block building 28 teaches")
	_check(not Puzzles.unlocked_at(196).has("stemson"), "the stemson stays locked through route 197")
	_check(Puzzles.unlocked_at(197).has("stemson"), "route 198 unlocks the stemson")
	_check(Puzzles.unlocked_at(203).size() == 32, "building 28 ends with every block")
	var pars := {
		198: [6, 3],
		199: [7, 4],
		200: [7, 5],
		201: [5, 2],
		202: [7, 5],
		203: [7, 3],
		204: [18, 17],
	}
	for puzzle in puzzles:
		var id := int(puzzle["id"])
		if id <= 197:
			_check(int(puzzle.get("building", 1)) < 28, "route %d stays out of building 28" % id)
			if id >= 191:
				_check(int(puzzle.get("building", 1)) == 27, "route %d stays in building 27" % id)
			continue
		_check(int(puzzle.get("building", 1)) == 28, "route %d is building 28" % id)
		var result: Dictionary = Sim.run(puzzle, puzzle["reference"])
		var par: Dictionary = Scoring.compute_par(puzzle)
		_check(bool(result["success"]), "route %d reference delivers" % id)
		_check(int(result["cycles"]) == int(par["cycles"]), "route %d reference meets par cycles" % id)
		_check(int(result["blocks"]) == int(par["blocks"]), "route %d reference meets par blocks" % id)
		_check(int(result["blocks"]) == puzzle["reference"].size(), "route %d plays the reference block count" % id)
		var locked: Array = pars[id]
		_check(int(par["cycles"]) == int(locked[0]) and int(par["blocks"]) == int(locked[1]), "route %d par is %d cycles and %d blocks" % [id, int(locked[0]), int(locked[1])])
		if id == 198:
			_check(str(puzzle.get("unlocks", "")) == "stemson", "route 198 teaches the stemson")
		else:
			_check(str(puzzle.get("unlocks", "")) == "", "route %d adds no further block" % id)
		var uses_stemson := false
		for block in puzzle["reference"]:
			if str(block["type"]) == "stemson":
				uses_stemson = true
		_check(uses_stemson, "route %d reference uses the stemson" % id)
		if not bool(result["success"]):
			_dump(result)
		print("    par route %d  cycles %d  blocks %d" % [id, int(par["cycles"]), int(par["blocks"])])

	for id in [198, 199, 200, 201, 202, 203, 204]:
		for dir in range(4):
			var spun: Array = _by_id(id)["reference"].duplicate(true)
			for block in spun:
				if str(block["type"]) == "stemson":
					block["dir"] = dir
			var spun_run: Dictionary = Sim.run(_by_id(id), spun)
			_check(bool(spun_run["success"]) and int(spun_run["cycles"]) == int(pars[id][0]), "route %d ignores which way the stemson block is rotated" % id)
		for kind in ["keelson", "futtock", "loft", "vault", "keel", "rabbet", "balk", "return", "turn", "hook", "pause", "conveyor", "slide", "garboard", "stealer", "bias", "cant", "strake", "wale", "shunt", "sheer", "sling", "bridge", "chute"]:
			var swapped: Dictionary = Sim.run(_by_id(id), _swap(_by_id(id), "stemson", kind))
			_check(not bool(swapped["success"]), "route %d fails if the stemson is a %s" % [id, kind])
		var omitted: Array = []
		for block in _by_id(id)["reference"]:
			if str(block["type"]) != "stemson":
				omitted.append(block)
		_check(not bool(Sim.run(_by_id(id), omitted)["success"]), "route %d fails if the stemson is missing" % id)

	var lesson: Dictionary = Sim.run(_by_id(198), _by_id(198)["reference"])
	_check(_at(_frame(lesson, 2), 2, 1) and _dir_at(_frame(lesson, 2), 2, 1) == 0, "route 198 starts the parcel facing east on the stemson")
	_check(_at(_frame(lesson, 3), 2, 1) and _dir_at(_frame(lesson, 3), 2, 1) == 0, "route 198 keeps the parcel facing east without moving it")
	_check(_at(_frame(lesson, 4), 8, 1) and _dir_at(_frame(lesson, 4), 8, 1) == 0, "route 198 jumps six cells east and still faces east")
	var lesson_entered := false
	for frame in lesson["frames"]:
		if _at(frame, 3, 1) or _at(frame, 4, 1) or _at(frame, 5, 1) or _at(frame, 6, 1) or _at(frame, 7, 1):
			lesson_entered = true
	_check(not lesson_entered, "route 198 does not enter the cells in front")
	_check(str(Sim.run(_by_id(198), _swap(_by_id(198), "stemson", "keelson"))["reason"]) == "stuck", "route 198's keelson lands on the last brick")
	_check(str(Sim.run(_by_id(198), _swap(_by_id(198), "stemson", "futtock"))["reason"]) == "stuck", "route 198's futtock lands two cells short")
	_check(str(Sim.run(_by_id(198), _swap(_by_id(198), "stemson", "loft"))["reason"]) == "stuck", "route 198's loft lands three cells short")
	_check(str(Sim.run(_by_id(198), _swap(_by_id(198), "stemson", "vault"))["reason"]) == "stuck", "route 198's vault lands four cells short")
	_check(str(Sim.run(_by_id(198), _swap(_by_id(198), "stemson", "keel"))["reason"]) == "stuck", "route 198's keel jumps three cells back")

	var let_stemson: Dictionary = Sim.run(_by_id(199), _by_id(199)["reference"])
	_check(_color_at(_frame(let_stemson, 4), 2, 1) == "red" and _dir_at(_frame(let_stemson, 4), 2, 1) == 0 and _color_at(_frame(let_stemson, 4), 8, 1) == "blue", "route 199 holds red while blue stands on the landing")
	_check(_color_at(_frame(let_stemson, 5), 8, 1) == "red" and _dir_at(_frame(let_stemson, 5), 8, 1) == 0 and _frame(let_stemson, 5).get("delivered", []).size() == 1, "route 199 jumps once the landing is free and still faces east")

	var counted: Dictionary = Sim.run(_by_id(200), _by_id(200)["reference"])
	_check(str(counted["delivered"][0]["color"]) == "blue" and int(counted["delivered"][0]["count"]) == 1, "route 200 delivers blue count 1")
	_check(str(counted["delivered"][1]["color"]) == "red" and int(counted["delivered"][1]["count"]) == 2, "route 200 delivers red count 2")
	_check(_color_at(_frame(counted, 3), 7, 1) == "red" and _dir_at(_frame(counted, 3), 7, 1) == 0, "route 200 jumps six cells east and still faces east")
	_check(_color_at(_frame(counted, 6), 9, 1) == "red" and _count_at(_frame(counted, 6), 9, 1) == 2, "route 200's counter stamps 2")

	var clear: Dictionary = Sim.run(_by_id(201), _by_id(201)["reference"])
	_check(_at(_frame(clear, 2), 1, 1) and _dir_at(_frame(clear, 2), 1, 1) == 0, "route 201 waits facing east")
	_check(_at(_frame(clear, 3), 7, 1) and _dir_at(_frame(clear, 3), 7, 1) == 0, "route 201 lands six cells east and still faces east")
	var brick_entered := false
	for frame in clear["frames"]:
		if _at(frame, 2, 1) or _at(frame, 3, 1) or _at(frame, 4, 1) or _at(frame, 5, 1) or _at(frame, 6, 1):
			brick_entered = true
	_check(not brick_entered, "route 201 does not enter any brick")
	_check(str(Sim.run(_by_id(201), _swap(_by_id(201), "stemson", "keelson"))["reason"]) == "stuck", "route 201's keelson tries to land on the last brick")
	_check(str(Sim.run(_by_id(201), _swap(_by_id(201), "stemson", "futtock"))["reason"]) == "stuck", "route 201's futtock lands two cells short")

	var paired: Dictionary = Sim.run(_by_id(202), _by_id(202)["reference"])
	_check(_color_at(_frame(paired, 2), 1, 9) == "red" and _dir_at(_frame(paired, 2), 1, 9) == 0, "route 202 holds the east-facing parcel")
	_check(_color_at(_frame(paired, 4), 8, 2) == "blue" and _dir_at(_frame(paired, 4), 8, 2) == 1, "route 202 holds the south-facing parcel")
	_check(_frame(paired, 5).get("delivered", []).size() == 1 and str(_frame(paired, 5)["delivered"][0]["color"]) == "red", "route 202 delivers the east-facing parcel first")
	_check(int(paired["cycles"]) == 7, "route 202 delivers the south-facing parcel second")
	for cell in [Vector2i(1, 9), Vector2i(8, 2)]:
		for kind in ["keelson", "futtock", "loft", "vault"]:
			var one: Dictionary = Sim.run(_by_id(202), _swap_cell(_by_id(202), cell.x, cell.y, kind))
			_check(not bool(one["success"]), "route 202 misses the dock if the stemson at %d,%d is a %s" % [cell.x, cell.y, kind])

	var second: Dictionary = Sim.run(_by_id(203), _by_id(203)["reference"])
	_check(_at(_frame(second, 2), 1, 7) and _dir_at(_frame(second, 2), 1, 7) == 0, "route 203 waits on the first stemson facing east")
	_check(_at(_frame(second, 3), 7, 7) and _dir_at(_frame(second, 3), 7, 7) == 0, "route 203 jumps six cells forward and still faces east")
	_check(_at(_frame(second, 5), 7, 6) and _dir_at(_frame(second, 5), 7, 6) == 3, "route 203 reaches the second stemson facing north")
	_check(_at(_frame(second, 6), 7, 6) and _dir_at(_frame(second, 6), 7, 6) == 3, "route 203 waits on the second stemson facing north")
	_check(int(second["cycles"]) == 7, "route 203 jumps six cells forward on the new facing")
	_check(not bool(Sim.run(_by_id(203), _omit_cell(_by_id(203), 1, 7))["success"]), "route 203 fails without the first stemson")
	_check(not bool(Sim.run(_by_id(203), _omit_cell(_by_id(203), 7, 6))["success"]), "route 203 fails without the second stemson")
	for cell in [Vector2i(1, 7), Vector2i(7, 6)]:
		for kind in ["keelson", "futtock", "loft", "vault"]:
			var missed: Dictionary = Sim.run(_by_id(203), _swap_cell(_by_id(203), cell.x, cell.y, kind))
			_check(not bool(missed["success"]), "route 203 misses the dock if the stemson at %d,%d is a %s" % [cell.x, cell.y, kind])

	var night: Dictionary = Sim.run(_by_id(204), _by_id(204)["reference"])
	_check(int(night["cycles"]) < 250, "route 204 finishes before tick 250")
	_check(str(night["delivered"][0]["color"]) == "red" and int(night["delivered"][0]["count"]) == 1, "route 204 stamps red 1")
	_check(str(night["delivered"][1]["color"]) == "yellow" and int(night["delivered"][1]["count"]) == 2, "route 204 stamps yellow 2")
	_check(str(night["delivered"][2]["color"]) == "blue" and int(night["delivered"][2]["count"]) == 3, "route 204 stamps blue 3")
	_check(_color_at(_frame(night, 6), 3, 3) == "red" and _dir_at(_frame(night, 6), 3, 3) == 0, "route 204 holds red facing east")
	_check(_color_at(_frame(night, 8), 9, 3) == "red" and _dir_at(_frame(night, 8), 9, 3) == 0, "route 204 jumps red six cells east and leaves it facing east")
	_check(_color_at(_frame(night, 10), 10, 3) == "red" and _dir_at(_frame(night, 10), 10, 3) == 0 and _count_at(_frame(night, 10), 10, 3) == 0, "route 204 reaches the counter still facing east")
	var night_entered := false
	for frame in night["frames"]:
		if _color_at(frame, 4, 3) == "red" or _color_at(frame, 5, 3) == "red" or _color_at(frame, 6, 3) == "red" or _color_at(frame, 7, 3) == "red" or _color_at(frame, 8, 3) == "red":
			night_entered = true
	_check(not night_entered, "route 204 does not enter the cells in front")
	_check(not bool(Sim.run(_by_id(204), _swap(_by_id(204), "stemson", "keelson"))["success"]), "route 204's keelson misses the pause")
	_check(not bool(Sim.run(_by_id(204), _swap(_by_id(204), "stemson", "futtock"))["success"]), "route 204's futtock misses the pause")
	_check(not bool(Sim.run(_by_id(204), _swap(_by_id(204), "stemson", "loft"))["success"]), "route 204's loft misses the pause")
	_check(not bool(Sim.run(_by_id(204), _swap(_by_id(204), "stemson", "vault"))["success"]), "route 204's vault misses the pause")
	_check(not bool(Sim.run(_by_id(204), _swap(_by_id(204), "primer", "painter"))["success"]), "route 204 fails if blue is painted yellow")
	_check(not bool(Sim.run(_by_id(204), _swap(_by_id(204), "filter", "conveyor"))["success"]), "route 204 fails if red is not pulled ahead")
	_check(not bool(Sim.run(_by_id(204), _swap(_by_id(204), "counter", "conveyor"))["success"]), "route 204 fails without the counter")


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
	_check(routes == 204, "all 204 routes are on the board")
	print("    route row width ", width)
	_check(width == 4636.0, "the route row minimum width is 4636 (%s)" % width)
	_check(int(ProjectSettings.get_setting("display/window/size/viewport_width")) == 4676, "the window is 4676 wide")
	_check(int(ProjectSettings.get_setting("display/window/size/viewport_height")) == 720, "the window is 720 tall")
	_check(width + 40.0 == 4676.0, "the window keeps 20 pixels of spare on each side of the route row")
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
	var saw_loft := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Loft"):
				saw_loft = true
	_check(not saw_loft, "route 127 keeps the loft locked")
	node.select_puzzle(127)
	_check(building != null and building.text == "BUILDING 18", "route 128 opens building 18")
	_check(node.find_child("BuildingEighteenMark", true, false) != null, "the route row marks building 18")
	_check(node.find_child("BuildingSeventeenMark", true, false) != null, "building 17's mark stays beside building 18")
	tools = node.find_child("ToolBox", true, false)
	saw_loft = false
	saw_balk = false
	var loft_button: Button = null
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Loft"):
				saw_loft = true
				loft_button = child
			if str(child.text).begins_with("Balk"):
				saw_balk = true
	_check(saw_loft, "route 128 offers the loft")
	_check(saw_balk, "route 128 still offers the balk")
	if loft_button != null:
		_check(str(loft_button.tooltip_text).begins_with("Waits one tick, then jumps a parcel three cells forward"), "the loft tooltip describes the three-cell jump")
		_check(str(loft_button.text).begins_with("Loft"), "the loft button reads Loft")
		_check(node._tool_color("loft") == Color("#c45c3e"), "the loft is #c45c3e")
		_check(node._tool_color("balk") == Color("#5a6e8a"), "the balk stays #5a6e8a")
		var loft_rect: Rect2 = loft_button.get_global_rect()
		var loft_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(loft_rect.position.x >= loft_view.position.x and loft_rect.position.y >= loft_view.position.y and loft_rect.end.x <= loft_view.end.x and loft_rect.end.y <= loft_view.end.y, "the loft button is fully on screen")
	var balk_again: Button = null
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Balk"):
				balk_again = child
	if balk_again != null:
		var balk_rect: Rect2 = balk_again.get_global_rect()
		var balk_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(balk_rect.position.x >= balk_view.position.x and balk_rect.position.y >= balk_view.position.y and balk_rect.end.x <= balk_view.end.x and balk_rect.end.y <= balk_view.end.y, "the balk button stays fully on screen")
	node.select_puzzle(133)
	_check(building != null and building.text == "BUILDING 18", "route 134 stays in building 18")
	tools = node.find_child("ToolBox", true, false)
	saw_loft = false
	saw_balk = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Loft"):
				saw_loft = true
			if str(child.text).begins_with("Balk"):
				saw_balk = true
	_check(saw_loft, "route 134 still offers the loft")
	_check(saw_balk, "route 134 still offers the balk")
	var saw_keel := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Keel"):
				saw_keel = true
	_check(not saw_keel, "route 134 keeps the keel locked")
	node.select_puzzle(134)
	_check(building != null and building.text == "BUILDING 19", "route 135 opens building 19")
	_check(node.find_child("BuildingNineteenMark", true, false) != null, "the route row marks building 19")
	_check(node.find_child("BuildingEighteenMark", true, false) != null, "building 18's mark stays beside building 19")
	tools = node.find_child("ToolBox", true, false)
	saw_keel = false
	saw_loft = false
	var keel_button: Button = null
	var loft_again: Button = null
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Keel"):
				saw_keel = true
				keel_button = child
			if str(child.text).begins_with("Loft"):
				saw_loft = true
				loft_again = child
	_check(saw_keel, "route 135 offers the keel")
	_check(saw_loft, "route 135 still offers the loft")
	if keel_button != null:
		_check(str(keel_button.tooltip_text).begins_with("Waits one tick, then jumps a parcel three cells backward"), "the keel tooltip describes the three-cell jump")
		_check(str(keel_button.text).begins_with("Keel"), "the keel button reads Keel")
		_check(node._tool_color("keel") == Color("#2a7f8c"), "the keel is #2a7f8c")
		_check(node._tool_color("loft") == Color("#c45c3e"), "the loft stays #c45c3e")
		var keel_rect: Rect2 = keel_button.get_global_rect()
		var keel_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(keel_rect.position.x >= keel_view.position.x and keel_rect.position.y >= keel_view.position.y and keel_rect.end.x <= keel_view.end.x and keel_rect.end.y <= keel_view.end.y, "the keel button is fully on screen")
	if loft_again != null:
		var loft_again_rect: Rect2 = loft_again.get_global_rect()
		var loft_again_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(loft_again_rect.position.x >= loft_again_view.position.x and loft_again_rect.position.y >= loft_again_view.position.y and loft_again_rect.end.x <= loft_again_view.end.x and loft_again_rect.end.y <= loft_again_view.end.y, "the loft button stays fully on screen")
	var keel_mark: Control = node.find_child("BuildingNineteenMark", true, false)
	if keel_mark != null:
		var mark_rect: Rect2 = keel_mark.get_global_rect()
		var mark_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(mark_rect.size.x > 1.0 and mark_rect.position.x >= mark_view.position.x and mark_rect.end.x <= mark_view.end.x and mark_rect.position.y >= mark_view.position.y and mark_rect.end.y <= mark_view.end.y, "the building 19 mark is fully on screen")
	node.select_puzzle(140)
	_check(building != null and building.text == "BUILDING 19", "route 141 stays in building 19")
	tools = node.find_child("ToolBox", true, false)
	saw_keel = false
	saw_loft = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Keel"):
				saw_keel = true
			if str(child.text).begins_with("Loft"):
				saw_loft = true
	_check(saw_keel, "route 141 still offers the keel")
	_check(saw_loft, "route 141 still offers the loft")
	var saw_sheer := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Sheer"):
				saw_sheer = true
	_check(not saw_sheer, "route 141 keeps the sheer locked")
	node.select_puzzle(141)
	_check(building != null and building.text == "BUILDING 20", "route 142 opens building 20")
	_check(node.find_child("BuildingTwentyMark", true, false) != null, "the route row marks building 20")
	_check(node.find_child("BuildingNineteenMark", true, false) != null, "building 19's mark stays beside building 20")
	tools = node.find_child("ToolBox", true, false)
	saw_sheer = false
	saw_keel = false
	var sheer_button: Button = null
	var keel_again: Button = null
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Sheer"):
				saw_sheer = true
				sheer_button = child
			if str(child.text).begins_with("Keel"):
				saw_keel = true
				keel_again = child
	_check(saw_sheer, "route 142 offers the sheer")
	_check(saw_keel, "route 142 still offers the keel")
	if sheer_button != null:
		_check(str(sheer_button.tooltip_text).begins_with("Waits one tick, then jumps a parcel three cells to its right"), "the sheer tooltip describes the three-cell jump")
		_check(str(sheer_button.text).begins_with("Sheer"), "the sheer button reads Sheer")
		_check(node._tool_color("sheer") == Color("#3d5bd4"), "the sheer is #3d5bd4")
		_check(node._tool_color("keel") == Color("#2a7f8c"), "the keel stays #2a7f8c")
		_check(node._tool_color("loft") == Color("#c45c3e"), "the loft stays #c45c3e")
		_check(node._tool_color("balk") == Color("#5a6e8a"), "the balk stays #5a6e8a")
		var sheer_rect: Rect2 = sheer_button.get_global_rect()
		var sheer_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(sheer_rect.position.x >= sheer_view.position.x and sheer_rect.position.y >= sheer_view.position.y and sheer_rect.end.x <= sheer_view.end.x and sheer_rect.end.y <= sheer_view.end.y, "the sheer button is fully on screen")
	if keel_again != null:
		var keel_again_rect: Rect2 = keel_again.get_global_rect()
		var keel_again_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(keel_again_rect.position.x >= keel_again_view.position.x and keel_again_rect.position.y >= keel_again_view.position.y and keel_again_rect.end.x <= keel_again_view.end.x and keel_again_rect.end.y <= keel_again_view.end.y, "the keel button stays fully on screen")
	var sheer_mark: Control = node.find_child("BuildingTwentyMark", true, false)
	if sheer_mark != null:
		var sheer_mark_rect: Rect2 = sheer_mark.get_global_rect()
		var sheer_mark_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(sheer_mark_rect.size.x > 1.0 and sheer_mark_rect.position.x >= sheer_mark_view.position.x and sheer_mark_rect.end.x <= sheer_mark_view.end.x and sheer_mark_rect.position.y >= sheer_mark_view.position.y and sheer_mark_rect.end.y <= sheer_mark_view.end.y, "the building 20 mark is fully on screen")
	node.select_puzzle(147)
	_check(building != null and building.text == "BUILDING 20", "route 148 stays in building 20")
	tools = node.find_child("ToolBox", true, false)
	saw_sheer = false
	saw_keel = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Sheer"):
				saw_sheer = true
			if str(child.text).begins_with("Keel"):
				saw_keel = true
	_check(saw_sheer, "route 148 still offers the sheer")
	_check(saw_keel, "route 148 still offers the keel")
	var saw_strake := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Strake"):
				saw_strake = true
	_check(not saw_strake, "route 148 keeps the strake locked")
	node.select_puzzle(148)
	_check(building != null and building.text == "BUILDING 21", "route 149 opens building 21")
	_check(node.find_child("BuildingTwentyOneMark", true, false) != null, "the route row marks building 21")
	_check(node.find_child("BuildingTwentyMark", true, false) != null, "building 20's mark stays beside building 21")
	tools = node.find_child("ToolBox", true, false)
	saw_strake = false
	saw_sheer = false
	var strake_button: Button = null
	var sheer_again: Button = null
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Strake"):
				saw_strake = true
				strake_button = child
			if str(child.text).begins_with("Sheer"):
				saw_sheer = true
				sheer_again = child
	_check(saw_strake, "route 149 offers the strake")
	_check(saw_sheer, "route 149 still offers the sheer")
	if strake_button != null:
		_check(str(strake_button.tooltip_text).begins_with("Waits one tick, then jumps a parcel two cells to its left"), "the strake tooltip describes the two-cell jump")
		_check(str(strake_button.text).begins_with("Strake"), "the strake button reads Strake")
		_check(node._tool_color("strake") == Color("#7a4e8a"), "the strake is #7a4e8a")
		_check(node._tool_color("sheer") == Color("#3d5bd4"), "the sheer stays #3d5bd4")
		_check(node._tool_color("keel") == Color("#2a7f8c"), "the keel stays #2a7f8c")
		_check(node._tool_color("loft") == Color("#c45c3e"), "the loft stays #c45c3e")
		_check(node._tool_color("balk") == Color("#5a6e8a"), "the balk stays #5a6e8a")
		var strake_rect: Rect2 = strake_button.get_global_rect()
		var strake_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(strake_rect.position.x >= strake_view.position.x and strake_rect.position.y >= strake_view.position.y and strake_rect.end.x <= strake_view.end.x and strake_rect.end.y <= strake_view.end.y, "the strake button is fully on screen")
	if sheer_again != null:
		var sheer_again_rect: Rect2 = sheer_again.get_global_rect()
		var sheer_again_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(sheer_again_rect.position.x >= sheer_again_view.position.x and sheer_again_rect.position.y >= sheer_again_view.position.y and sheer_again_rect.end.x <= sheer_again_view.end.x and sheer_again_rect.end.y <= sheer_again_view.end.y, "the sheer button stays fully on screen")
	var strake_mark: Control = node.find_child("BuildingTwentyOneMark", true, false)
	if strake_mark != null:
		var strake_mark_rect: Rect2 = strake_mark.get_global_rect()
		var strake_mark_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(strake_mark_rect.size.x > 1.0 and strake_mark_rect.position.x >= strake_mark_view.position.x and strake_mark_rect.end.x <= strake_mark_view.end.x and strake_mark_rect.position.y >= strake_mark_view.position.y and strake_mark_rect.end.y <= strake_mark_view.end.y, "the building 21 mark is fully on screen")
	node.select_puzzle(154)
	_check(building != null and building.text == "BUILDING 21", "route 155 stays in building 21")
	tools = node.find_child("ToolBox", true, false)
	saw_strake = false
	saw_sheer = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Strake"):
				saw_strake = true
			if str(child.text).begins_with("Sheer"):
				saw_sheer = true
	_check(saw_strake, "route 155 still offers the strake")
	_check(saw_sheer, "route 155 still offers the sheer")
	var saw_wale := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Wale"):
				saw_wale = true
	_check(not saw_wale, "route 155 keeps the wale locked")
	node.select_puzzle(155)
	_check(building != null and building.text == "BUILDING 22", "route 156 opens building 22")
	_check(node.find_child("BuildingTwentyTwoMark", true, false) != null, "the route row marks building 22")
	_check(node.find_child("BuildingTwentyOneMark", true, false) != null, "building 21's mark stays beside building 22")
	tools = node.find_child("ToolBox", true, false)
	saw_wale = false
	saw_strake = false
	var wale_button: Button = null
	var strake_again: Button = null
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Wale"):
				saw_wale = true
				wale_button = child
			if str(child.text).begins_with("Strake"):
				saw_strake = true
				strake_again = child
	_check(saw_wale, "route 156 offers the wale")
	_check(saw_strake, "route 156 still offers the strake")
	if wale_button != null:
		_check(str(wale_button.tooltip_text).begins_with("Waits one tick, then jumps a parcel one cell to its right"), "the wale tooltip describes the one-cell jump")
		_check(str(wale_button.text).begins_with("Wale"), "the wale button reads Wale")
		_check(node._tool_color("wale") == Color("#c47a3a"), "the wale is #c47a3a")
		_check(node._tool_color("strake") == Color("#7a4e8a"), "the strake stays #7a4e8a")
		_check(node._tool_color("sheer") == Color("#3d5bd4"), "the sheer stays #3d5bd4")
		_check(node._tool_color("keel") == Color("#2a7f8c"), "the keel stays #2a7f8c")
		_check(node._tool_color("loft") == Color("#c45c3e"), "the loft stays #c45c3e")
		_check(node._tool_color("balk") == Color("#5a6e8a"), "the balk stays #5a6e8a")
		var wale_rect: Rect2 = wale_button.get_global_rect()
		var wale_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(wale_rect.position.x >= wale_view.position.x and wale_rect.position.y >= wale_view.position.y and wale_rect.end.x <= wale_view.end.x and wale_rect.end.y <= wale_view.end.y, "the wale button is fully on screen")
	if strake_again != null:
		var strake_again_rect: Rect2 = strake_again.get_global_rect()
		var strake_again_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(strake_again_rect.position.x >= strake_again_view.position.x and strake_again_rect.position.y >= strake_again_view.position.y and strake_again_rect.end.x <= strake_again_view.end.x and strake_again_rect.end.y <= strake_again_view.end.y, "the strake button stays fully on screen")
	var wale_mark: Control = node.find_child("BuildingTwentyTwoMark", true, false)
	if wale_mark != null:
		var wale_mark_rect: Rect2 = wale_mark.get_global_rect()
		var wale_mark_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(wale_mark_rect.size.x > 1.0 and wale_mark_rect.position.x >= wale_mark_view.position.x and wale_mark_rect.end.x <= wale_mark_view.end.x and wale_mark_rect.position.y >= wale_mark_view.position.y and wale_mark_rect.end.y <= wale_mark_view.end.y, "the building 22 mark is fully on screen")
	node.select_puzzle(161)
	_check(building != null and building.text == "BUILDING 22", "route 162 stays in building 22")
	tools = node.find_child("ToolBox", true, false)
	saw_wale = false
	saw_strake = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Wale"):
				saw_wale = true
			if str(child.text).begins_with("Strake"):
				saw_strake = true
	_check(saw_wale, "route 162 still offers the wale")
	_check(saw_strake, "route 162 still offers the strake")
	var saw_garboard := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Garboard"):
				saw_garboard = true
	_check(not saw_garboard, "route 162 keeps the garboard locked")
	node.select_puzzle(162)
	_check(building != null and building.text == "BUILDING 23", "route 163 opens building 23")
	_check(node.find_child("BuildingTwentyThreeMark", true, false) != null, "the route row marks building 23")
	_check(node.find_child("BuildingTwentyTwoMark", true, false) != null, "building 22's mark stays beside building 23")
	tools = node.find_child("ToolBox", true, false)
	saw_garboard = false
	saw_wale = false
	var garboard_button: Button = null
	var wale_again: Button = null
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Garboard"):
				saw_garboard = true
				garboard_button = child
			if str(child.text).begins_with("Wale"):
				saw_wale = true
				wale_again = child
	_check(saw_garboard, "route 163 offers the garboard")
	_check(saw_wale, "route 163 still offers the wale")
	if garboard_button != null:
		_check(str(garboard_button.tooltip_text).begins_with("Waits one tick, then jumps a parcel one cell to its left"), "the garboard tooltip describes the one-cell jump")
		_check(str(garboard_button.text).begins_with("Garboard"), "the garboard button reads Garboard")
		_check(node._tool_color("garboard") == Color("#3e8f6a"), "the garboard is #3e8f6a")
		_check(node._tool_color("wale") == Color("#c47a3a"), "the wale stays #c47a3a")
		_check(node._tool_color("strake") == Color("#7a4e8a"), "the strake stays #7a4e8a")
		_check(node._tool_color("sheer") == Color("#3d5bd4"), "the sheer stays #3d5bd4")
		_check(node._tool_color("keel") == Color("#2a7f8c"), "the keel stays #2a7f8c")
		_check(node._tool_color("loft") == Color("#c45c3e"), "the loft stays #c45c3e")
		_check(node._tool_color("balk") == Color("#5a6e8a"), "the balk stays #5a6e8a")
		var garboard_rect: Rect2 = garboard_button.get_global_rect()
		var garboard_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(garboard_rect.position.x >= garboard_view.position.x and garboard_rect.position.y >= garboard_view.position.y and garboard_rect.end.x <= garboard_view.end.x and garboard_rect.end.y <= garboard_view.end.y, "the garboard button is fully on screen")
	if wale_again != null:
		var wale_again_rect: Rect2 = wale_again.get_global_rect()
		var wale_again_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(wale_again_rect.position.x >= wale_again_view.position.x and wale_again_rect.position.y >= wale_again_view.position.y and wale_again_rect.end.x <= wale_again_view.end.x and wale_again_rect.end.y <= wale_again_view.end.y, "the wale button stays fully on screen")
	var garboard_mark: Control = node.find_child("BuildingTwentyThreeMark", true, false)
	if garboard_mark != null:
		var garboard_mark_rect: Rect2 = garboard_mark.get_global_rect()
		var garboard_mark_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(garboard_mark_rect.size.x > 1.0 and garboard_mark_rect.position.x >= garboard_mark_view.position.x and garboard_mark_rect.end.x <= garboard_mark_view.end.x and garboard_mark_rect.position.y >= garboard_mark_view.position.y and garboard_mark_rect.end.y <= garboard_mark_view.end.y, "the building 23 mark is fully on screen")
	node.select_puzzle(168)
	_check(building != null and building.text == "BUILDING 23", "route 169 stays in building 23")
	tools = node.find_child("ToolBox", true, false)
	saw_garboard = false
	saw_wale = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Garboard"):
				saw_garboard = true
			if str(child.text).begins_with("Wale"):
				saw_wale = true
	_check(saw_garboard, "route 169 still offers the garboard")
	_check(saw_wale, "route 169 still offers the wale")
	var saw_stealer := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Stealer"):
				saw_stealer = true
	_check(not saw_stealer, "route 169 keeps the stealer locked")
	node.select_puzzle(169)
	_check(building != null and building.text == "BUILDING 24", "route 170 opens building 24")
	_check(node.find_child("BuildingTwentyFourMark", true, false) != null, "the route row marks building 24")
	_check(node.find_child("BuildingTwentyThreeMark", true, false) != null, "building 23's mark stays beside building 24")
	tools = node.find_child("ToolBox", true, false)
	saw_stealer = false
	saw_garboard = false
	var stealer_button: Button = null
	var garboard_again: Button = null
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Stealer"):
				saw_stealer = true
				stealer_button = child
			if str(child.text).begins_with("Garboard"):
				saw_garboard = true
				garboard_again = child
	_check(saw_stealer, "route 170 offers the stealer")
	_check(saw_garboard, "route 170 still offers the garboard")
	if stealer_button != null:
		_check(str(stealer_button.tooltip_text).begins_with("Waits one tick, then jumps a parcel three cells to its left"), "the stealer tooltip describes the three-cell jump")
		_check(str(stealer_button.text).begins_with("Stealer"), "the stealer button reads Stealer")
		_check(node._tool_color("stealer") == Color("#2f6f8f"), "the stealer is #2f6f8f")
		_check(node._tool_color("garboard") == Color("#3e8f6a"), "the garboard stays #3e8f6a")
		_check(node._tool_color("wale") == Color("#c47a3a"), "the wale stays #c47a3a")
		_check(node._tool_color("strake") == Color("#7a4e8a"), "the strake stays #7a4e8a")
		_check(node._tool_color("sheer") == Color("#3d5bd4"), "the sheer stays #3d5bd4")
		var stealer_rect: Rect2 = stealer_button.get_global_rect()
		var stealer_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(stealer_rect.position.x >= stealer_view.position.x and stealer_rect.position.y >= stealer_view.position.y and stealer_rect.end.x <= stealer_view.end.x and stealer_rect.end.y <= stealer_view.end.y, "the stealer button is fully on screen")
	if garboard_again != null:
		var garboard_again_rect: Rect2 = garboard_again.get_global_rect()
		var garboard_again_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(garboard_again_rect.position.x >= garboard_again_view.position.x and garboard_again_rect.position.y >= garboard_again_view.position.y and garboard_again_rect.end.x <= garboard_again_view.end.x and garboard_again_rect.end.y <= garboard_again_view.end.y, "the garboard button stays fully on screen")
	var stealer_mark: Control = node.find_child("BuildingTwentyFourMark", true, false)
	if stealer_mark != null:
		var stealer_mark_rect: Rect2 = stealer_mark.get_global_rect()
		var stealer_mark_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(stealer_mark_rect.size.x > 1.0 and stealer_mark_rect.position.x >= stealer_mark_view.position.x and stealer_mark_rect.end.x <= stealer_mark_view.end.x and stealer_mark_rect.position.y >= stealer_mark_view.position.y and stealer_mark_rect.end.y <= stealer_mark_view.end.y, "the building 24 mark is fully on screen")
	node.select_puzzle(175)
	_check(building != null and building.text == "BUILDING 24", "route 176 stays in building 24")
	tools = node.find_child("ToolBox", true, false)
	saw_stealer = false
	saw_garboard = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Stealer"):
				saw_stealer = true
			if str(child.text).begins_with("Garboard"):
				saw_garboard = true
	_check(saw_stealer, "route 176 still offers the stealer")
	_check(saw_garboard, "route 176 still offers the garboard")
	var saw_rabbet := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Rabbet"):
				saw_rabbet = true
	_check(not saw_rabbet, "route 176 keeps the rabbet locked")
	node.select_puzzle(176)
	_check(building != null and building.text == "BUILDING 25", "route 177 opens building 25")
	_check(node.find_child("BuildingTwentyFiveMark", true, false) != null, "the route row marks building 25")
	_check(node.find_child("BuildingTwentyFourMark", true, false) != null, "building 24's mark stays beside building 25")
	tools = node.find_child("ToolBox", true, false)
	saw_rabbet = false
	saw_stealer = false
	var rabbet_button: Button = null
	var stealer_again: Button = null
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Rabbet"):
				saw_rabbet = true
				rabbet_button = child
			if str(child.text).begins_with("Stealer"):
				saw_stealer = true
				stealer_again = child
	_check(saw_rabbet, "route 177 offers the rabbet")
	_check(saw_stealer, "route 177 still offers the stealer")
	if rabbet_button != null:
		_check(str(rabbet_button.tooltip_text).begins_with("Waits one tick, then jumps a parcel one cell backward"), "the rabbet tooltip describes the backward jump")
		_check(str(rabbet_button.text).begins_with("Rabbet"), "the rabbet button reads Rabbet")
		_check(node._tool_color("rabbet") == Color("#8f4e6a"), "the rabbet is #8f4e6a")
		_check(node._tool_color("stealer") == Color("#2f6f8f"), "the stealer stays #2f6f8f")
		_check(node._tool_color("garboard") == Color("#3e8f6a"), "the garboard stays #3e8f6a")
		_check(node._tool_color("wale") == Color("#c47a3a"), "the wale stays #c47a3a")
		_check(node._tool_color("strake") == Color("#7a4e8a"), "the strake stays #7a4e8a")
		_check(node._tool_color("sheer") == Color("#3d5bd4"), "the sheer stays #3d5bd4")
		var rabbet_rect: Rect2 = rabbet_button.get_global_rect()
		var rabbet_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(rabbet_rect.position.x >= rabbet_view.position.x and rabbet_rect.position.y >= rabbet_view.position.y and rabbet_rect.end.x <= rabbet_view.end.x and rabbet_rect.end.y <= rabbet_view.end.y, "the rabbet button is fully on screen")
	if stealer_again != null:
		var stealer_again_rect: Rect2 = stealer_again.get_global_rect()
		var stealer_again_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(stealer_again_rect.position.x >= stealer_again_view.position.x and stealer_again_rect.position.y >= stealer_again_view.position.y and stealer_again_rect.end.x <= stealer_again_view.end.x and stealer_again_rect.end.y <= stealer_again_view.end.y, "the stealer button stays fully on screen")
	var rabbet_mark: Control = node.find_child("BuildingTwentyFiveMark", true, false)
	if rabbet_mark != null:
		var rabbet_mark_rect: Rect2 = rabbet_mark.get_global_rect()
		var rabbet_mark_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(rabbet_mark_rect.size.x > 1.0 and rabbet_mark_rect.position.x >= rabbet_mark_view.position.x and rabbet_mark_rect.end.x <= rabbet_mark_view.end.x and rabbet_mark_rect.position.y >= rabbet_mark_view.position.y and rabbet_mark_rect.end.y <= rabbet_mark_view.end.y, "the building 25 mark is fully on screen")
	node.select_puzzle(182)
	_check(building != null and building.text == "BUILDING 25", "route 183 stays in building 25")
	tools = node.find_child("ToolBox", true, false)
	saw_rabbet = false
	saw_stealer = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Rabbet"):
				saw_rabbet = true
			if str(child.text).begins_with("Stealer"):
				saw_stealer = true
	_check(saw_rabbet, "route 183 still offers the rabbet")
	_check(saw_stealer, "route 183 still offers the stealer")
	var saw_futtock := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Futtock"):
				saw_futtock = true
	_check(not saw_futtock, "route 183 keeps the futtock locked")
	node.select_puzzle(183)
	_check(building != null and building.text == "BUILDING 26", "route 184 opens building 26")
	_check(node.find_child("BuildingTwentySixMark", true, false) != null, "the route row marks building 26")
	_check(node.find_child("BuildingTwentyFiveMark", true, false) != null, "building 25's mark stays beside building 26")
	tools = node.find_child("ToolBox", true, false)
	saw_futtock = false
	saw_rabbet = false
	var futtock_button: Button = null
	var rabbet_again: Button = null
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Futtock"):
				saw_futtock = true
				futtock_button = child
			if str(child.text).begins_with("Rabbet"):
				saw_rabbet = true
				rabbet_again = child
	_check(saw_futtock, "route 184 offers the futtock")
	_check(saw_rabbet, "route 184 still offers the rabbet")
	if futtock_button != null:
		_check(str(futtock_button.tooltip_text).begins_with("Waits one tick, then jumps a parcel four cells forward"), "the futtock tooltip describes the four-cell jump")
		_check(str(futtock_button.text).begins_with("Futtock"), "the futtock button reads Futtock")
		_check(node._tool_color("futtock") == Color("#6a8f3e"), "the futtock is #6a8f3e")
		_check(node._tool_color("rabbet") == Color("#8f4e6a"), "the rabbet stays #8f4e6a")
		_check(node._tool_color("stealer") == Color("#2f6f8f"), "the stealer stays #2f6f8f")
		_check(node._tool_color("garboard") == Color("#3e8f6a"), "the garboard stays #3e8f6a")
		_check(node._tool_color("wale") == Color("#c47a3a"), "the wale stays #c47a3a")
		_check(node._tool_color("strake") == Color("#7a4e8a"), "the strake stays #7a4e8a")
		_check(node._tool_color("sheer") == Color("#3d5bd4"), "the sheer stays #3d5bd4")
		var futtock_rect: Rect2 = futtock_button.get_global_rect()
		var futtock_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(futtock_rect.position.x >= futtock_view.position.x and futtock_rect.position.y >= futtock_view.position.y and futtock_rect.end.x <= futtock_view.end.x and futtock_rect.end.y <= futtock_view.end.y, "the futtock button is fully on screen")
	if rabbet_again != null:
		var rabbet_again_rect: Rect2 = rabbet_again.get_global_rect()
		var rabbet_again_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(rabbet_again_rect.position.x >= rabbet_again_view.position.x and rabbet_again_rect.position.y >= rabbet_again_view.position.y and rabbet_again_rect.end.x <= rabbet_again_view.end.x and rabbet_again_rect.end.y <= rabbet_again_view.end.y, "the rabbet button stays fully on screen")
	var futtock_mark: Control = node.find_child("BuildingTwentySixMark", true, false)
	if futtock_mark != null:
		var futtock_mark_rect: Rect2 = futtock_mark.get_global_rect()
		var futtock_mark_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(futtock_mark_rect.size.x > 1.0 and futtock_mark_rect.position.x >= futtock_mark_view.position.x and futtock_mark_rect.end.x <= futtock_mark_view.end.x and futtock_mark_rect.position.y >= futtock_mark_view.position.y and futtock_mark_rect.end.y <= futtock_mark_view.end.y, "the building 26 mark is fully on screen")
	node.select_puzzle(189)
	_check(building != null and building.text == "BUILDING 26", "route 190 stays in building 26")
	tools = node.find_child("ToolBox", true, false)
	saw_futtock = false
	saw_rabbet = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Futtock"):
				saw_futtock = true
			if str(child.text).begins_with("Rabbet"):
				saw_rabbet = true
	_check(saw_futtock, "route 190 still offers the futtock")
	_check(saw_rabbet, "route 190 still offers the rabbet")
	var saw_keelson := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Keelson"):
				saw_keelson = true
	_check(not saw_keelson, "route 190 keeps the keelson locked")
	node.select_puzzle(190)
	_check(building != null and building.text == "BUILDING 27", "route 191 opens building 27")
	_check(node.find_child("BuildingTwentySevenMark", true, false) != null, "the route row marks building 27")
	_check(node.find_child("BuildingTwentySixMark", true, false) != null, "building 26's mark stays beside building 27")
	tools = node.find_child("ToolBox", true, false)
	saw_keelson = false
	saw_futtock = false
	var keelson_button: Button = null
	var futtock_again: Button = null
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Keelson"):
				saw_keelson = true
				keelson_button = child
			if str(child.text).begins_with("Futtock"):
				saw_futtock = true
				futtock_again = child
	_check(saw_keelson, "route 191 offers the keelson")
	_check(saw_futtock, "route 191 still offers the futtock")
	if keelson_button != null:
		_check(str(keelson_button.tooltip_text).begins_with("Waits one tick, then jumps a parcel five cells forward"), "the keelson tooltip describes the five-cell jump")
		_check(str(keelson_button.text).begins_with("Keelson"), "the keelson button reads Keelson")
		_check(node._tool_color("keelson") == Color("#4a8f9a"), "the keelson is #4a8f9a")
		_check(node._tool_color("futtock") == Color("#6a8f3e"), "the futtock stays #6a8f3e")
		_check(node._tool_color("rabbet") == Color("#8f4e6a"), "the rabbet stays #8f4e6a")
		_check(node._tool_color("stealer") == Color("#2f6f8f"), "the stealer stays #2f6f8f")
		_check(node._tool_color("garboard") == Color("#3e8f6a"), "the garboard stays #3e8f6a")
		var keelson_rect: Rect2 = keelson_button.get_global_rect()
		var keelson_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(keelson_rect.position.x >= keelson_view.position.x and keelson_rect.position.y >= keelson_view.position.y and keelson_rect.end.x <= keelson_view.end.x and keelson_rect.end.y <= keelson_view.end.y, "the keelson button is fully on screen")
	if futtock_again != null:
		var futtock_again_rect: Rect2 = futtock_again.get_global_rect()
		var futtock_again_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(futtock_again_rect.position.x >= futtock_again_view.position.x and futtock_again_rect.position.y >= futtock_again_view.position.y and futtock_again_rect.end.x <= futtock_again_view.end.x and futtock_again_rect.end.y <= futtock_again_view.end.y, "the futtock button stays fully on screen")
	var keelson_mark: Control = node.find_child("BuildingTwentySevenMark", true, false)
	if keelson_mark != null:
		var keelson_mark_rect: Rect2 = keelson_mark.get_global_rect()
		var keelson_mark_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(keelson_mark_rect.size.x > 1.0 and keelson_mark_rect.position.x >= keelson_mark_view.position.x and keelson_mark_rect.end.x <= keelson_mark_view.end.x and keelson_mark_rect.position.y >= keelson_mark_view.position.y and keelson_mark_rect.end.y <= keelson_mark_view.end.y, "the building 27 mark is fully on screen")
	node.select_puzzle(196)
	_check(building != null and building.text == "BUILDING 27", "route 197 stays in building 27")
	tools = node.find_child("ToolBox", true, false)
	saw_keelson = false
	saw_futtock = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Keelson"):
				saw_keelson = true
			if str(child.text).begins_with("Futtock"):
				saw_futtock = true
	_check(saw_keelson, "route 197 still offers the keelson")
	_check(saw_futtock, "route 197 still offers the futtock")
	var saw_stemson := false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Stemson"):
				saw_stemson = true
	_check(not saw_stemson, "route 197 keeps the stemson locked")
	node.select_puzzle(197)
	_check(building != null and building.text == "BUILDING 28", "route 198 opens building 28")
	_check(node.find_child("BuildingTwentyEightMark", true, false) != null, "the route row marks building 28")
	_check(node.find_child("BuildingTwentySevenMark", true, false) != null, "building 27's mark stays beside building 28")
	tools = node.find_child("ToolBox", true, false)
	saw_stemson = false
	saw_keelson = false
	var stemson_button: Button = null
	var keelson_again: Button = null
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Stemson"):
				saw_stemson = true
				stemson_button = child
			if str(child.text).begins_with("Keelson"):
				saw_keelson = true
				keelson_again = child
	_check(saw_stemson, "route 198 offers the stemson")
	_check(saw_keelson, "route 198 still offers the keelson")
	if stemson_button != null:
		_check(str(stemson_button.tooltip_text).begins_with("Waits one tick, then jumps a parcel six cells forward"), "the stemson tooltip describes the six-cell jump")
		_check(str(stemson_button.text).begins_with("Stemson"), "the stemson button reads Stemson")
		_check(node._tool_color("stemson") == Color("#9a4a6a"), "the stemson is #9a4a6a")
		_check(node._tool_color("keelson") == Color("#4a8f9a"), "the keelson stays #4a8f9a")
		_check(node._tool_color("futtock") == Color("#6a8f3e"), "the futtock stays #6a8f3e")
		_check(node._tool_color("rabbet") == Color("#8f4e6a"), "the rabbet stays #8f4e6a")
		_check(node._tool_color("garboard") == Color("#3e8f6a"), "the garboard stays #3e8f6a")
		var stemson_rect: Rect2 = stemson_button.get_global_rect()
		var stemson_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(stemson_rect.position.x >= stemson_view.position.x and stemson_rect.position.y >= stemson_view.position.y and stemson_rect.end.x <= stemson_view.end.x and stemson_rect.end.y <= stemson_view.end.y, "the stemson button is fully on screen")
	if keelson_again != null:
		var keelson_again_rect: Rect2 = keelson_again.get_global_rect()
		var keelson_again_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(keelson_again_rect.position.x >= keelson_again_view.position.x and keelson_again_rect.position.y >= keelson_again_view.position.y and keelson_again_rect.end.x <= keelson_again_view.end.x and keelson_again_rect.end.y <= keelson_again_view.end.y, "the keelson button stays fully on screen")
	var stemson_mark: Control = node.find_child("BuildingTwentyEightMark", true, false)
	if stemson_mark != null:
		var stemson_mark_rect: Rect2 = stemson_mark.get_global_rect()
		var stemson_mark_view: Rect2 = node.get_viewport().get_visible_rect()
		_check(stemson_mark_rect.size.x > 1.0 and stemson_mark_rect.position.x >= stemson_mark_view.position.x and stemson_mark_rect.end.x <= stemson_mark_view.end.x and stemson_mark_rect.position.y >= stemson_mark_view.position.y and stemson_mark_rect.end.y <= stemson_mark_view.end.y, "the building 28 mark is fully on screen")
	node.select_puzzle(203)
	_check(building != null and building.text == "BUILDING 28", "route 204 stays in building 28")
	tools = node.find_child("ToolBox", true, false)
	saw_stemson = false
	saw_keelson = false
	if tools != null:
		for child in tools.get_children():
			if child.is_queued_for_deletion():
				continue
			if str(child.text).begins_with("Stemson"):
				saw_stemson = true
			if str(child.text).begins_with("Keelson"):
				saw_keelson = true
	_check(saw_stemson, "route 204 still offers the stemson")
	_check(saw_keelson, "route 204 still offers the keelson")
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
