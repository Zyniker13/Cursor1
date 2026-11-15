extends SceneTree

# Headless proof for Harbor Glass.
#   godot --headless --path harbor-glass -s res://tests/run_tests.gd
#
# Prism exits asserted here are the contract in beam_tracer.gd:
#   rot 0:  white traveling N -> red traveling W, blue traveling E, white consumed
#   rot 90: white traveling E -> red traveling N, blue traveling S, white consumed

const Tracer := preload("res://scripts/beam_tracer.gd")
const Charts := preload("res://scripts/charts.gd")
const Hints := preload("res://scripts/hint.gd")

var passed := 0
var failed := 0

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	test_mirror_table()
	test_prism_exits()
	test_prism_rejects_other_light()
	test_pane_filter()
	test_wrong_color_does_not_count()
	test_flood_stops_the_beam()
	test_flooded_lantern_is_dark()
	test_mirror_loop_terminates()
	test_charts()
	test_reach_book()
	test_basin_book()
	test_painted_book()
	test_west_book()
	test_meet_book()
	test_tide_mirror_rule()
	test_tide_book()
	test_shutter_rule()
	test_shutter_book()
	test_stain_rule()
	test_stain_book()
	test_vane_rule()
	test_vane_book()
	test_well_rule()
	test_well_book()
	test_chart_4_boat()
	test_one_rotation_is_not_solved()
	test_hint_points_at_one_piece()
	test_hint_budget_never_marks_every_piece()
	test_chart_3_tide()
	test_chart_6_combined()
	test_smoke()
	print("RESULT passed=%d failed=%d" % [passed, failed])
	quit(0 if failed == 0 else 1)

func check(cond: bool, name: String) -> void:
	if cond:
		passed += 1
	else:
		failed += 1
		print("FAIL ", name)

func test_mirror_table() -> void:
	# "/" rot 0: N<->E, S<->W. "\" rot 90: N<->W, S<->E.
	check(Tracer.reflect(0, "N") == "E", "mirror / N to E")
	check(Tracer.reflect(0, "E") == "N", "mirror / E to N")
	check(Tracer.reflect(0, "S") == "W", "mirror / S to W")
	check(Tracer.reflect(0, "W") == "S", "mirror / W to S")
	check(Tracer.reflect(180, "E") == "N", "mirror 180 matches /")
	check(Tracer.reflect(90, "N") == "W", "mirror \\ N to W")
	check(Tracer.reflect(90, "E") == "S", "mirror \\ E to S")
	check(Tracer.reflect(90, "S") == "E", "mirror \\ S to E")
	check(Tracer.reflect(90, "W") == "N", "mirror \\ W to N")
	check(Tracer.reflect(270, "E") == "S", "mirror 270 matches \\")

func test_prism_exits() -> void:
	var ports: Dictionary = Tracer.prism_ports(0)
	check(ports["entry"] == "N" and ports["red"] == "W" and ports["blue"] == "E", "prism rot 0 ports")
	var turned: Dictionary = Tracer.prism_ports(90)
	check(turned["entry"] == "E" and turned["red"] == "N" and turned["blue"] == "S", "prism rot 90 ports")
	# White traveling north into a rot-0 prism. Red dock to the west, blue to the east,
	# white dock to the north must stay dark because white is consumed.
	var chart := _blank(5, 5)
	chart["lanterns"] = [_lamp("L", 2, 3, "N", "white")]
	chart["docks"] = [_need("W", 1, 2, "red"), _need("E", 3, 2, "blue"), _need("N", 2, 1, "white")]
	chart["pieces"] = [_fixed_prism(2, 2, 0)]
	var state := Charts.make_state(chart, true)
	var result: Dictionary = Tracer.trace(chart, state)
	check(result["docks"]["W"].has("red") and result["docks"]["W"].size() == 1, "prism sends red west")
	check(result["docks"]["E"].has("blue") and result["docks"]["E"].size() == 1, "prism sends blue east")
	check(result["docks"]["N"].is_empty(), "prism consumes white; nothing exits north")
	var reached_north := false
	for raw_seg in result["segments"]:
		var seg: Dictionary = raw_seg
		if is_equal_approx(float(seg["y1"]), 1.5) and is_equal_approx(float(seg["x1"]), 2.5):
			reached_north = true
	check(not reached_north, "prism beam does not continue north")

func test_prism_rejects_other_light() -> void:
	var red_in := _blank(5, 5)
	red_in["lanterns"] = [_lamp("L", 2, 3, "N", "red")]
	red_in["docks"] = [_need("W", 1, 2, "red"), _need("E", 3, 2, "blue")]
	red_in["pieces"] = [_fixed_prism(2, 2, 0)]
	var red_state := Charts.make_state(red_in, true)
	var red_hit: Dictionary = Tracer.trace(red_in, red_state)
	check(red_hit["docks"]["W"].is_empty() and red_hit["docks"]["E"].is_empty(), "prism absorbs non-white")
	var side := _blank(5, 5)
	side["lanterns"] = [_lamp("L", 1, 2, "E", "white")]
	side["docks"] = [_need("W", 1, 2, "red"), _need("E", 3, 2, "blue")]
	side["pieces"] = [_fixed_prism(2, 2, 0)]
	var side_hit: Dictionary = Tracer.trace(side, Charts.make_state(side, true))
	check(side_hit["docks"]["W"].is_empty() and side_hit["docks"]["E"].is_empty(), "prism absorbs the wrong entry")

func test_pane_filter() -> void:
	check(Tracer.pane_color(0) == "red" and Tracer.pane_color(180) == "red", "pane 0 passes red")
	check(Tracer.pane_color(90) == "blue" and Tracer.pane_color(270) == "blue", "pane 90 passes blue")
	var chart := _blank(5, 1)
	chart["lanterns"] = [_lamp("L", 0, 0, "E", "red")]
	chart["docks"] = [_need("D", 4, 0, "red")]
	chart["pieces"] = [_fixed_pane(2, 0, 0)]
	check(Tracer.is_cleared(chart, Charts.make_state(chart, true)), "red pane passes red")
	chart["pieces"][0]["solution_rot"] = 90
	check(not Tracer.is_cleared(chart, Charts.make_state(chart, true)), "blue pane blocks red")
	chart["lanterns"][0]["color"] = "white"
	chart["pieces"][0]["solution_rot"] = 0
	check(not Tracer.is_cleared(chart, Charts.make_state(chart, true)), "red pane blocks white")
	chart["lanterns"][0]["color"] = "blue"
	chart["docks"][0]["color"] = "blue"
	chart["pieces"][0]["solution_rot"] = 90
	check(Tracer.is_cleared(chart, Charts.make_state(chart, true)), "blue pane passes blue")

func test_wrong_color_does_not_count() -> void:
	var chart := _blank(3, 1)
	chart["lanterns"] = [_lamp("L", 0, 0, "E", "blue")]
	chart["docks"] = [_need("D", 2, 0, "red")]
	var state := Charts.make_state(chart, true)
	var notes := Tracer.failure_notes(chart, state)
	check(not Tracer.is_cleared(chart, state), "blue does not satisfy a red dock")
	check(notes.has("A dock has the wrong color."), "wrong color is reported as the wrong color")
	chart["lanterns"][0]["color"] = "red"
	check(Tracer.is_cleared(chart, Charts.make_state(chart, true)), "red satisfies a red dock")

func test_flood_stops_the_beam() -> void:
	# Three rows. Flood count 2 covers rows 1 and 2. A southbound beam from row 0
	# stops at the waterline and never reaches the dock on row 2.
	var chart := _blank(1, 3)
	chart["tide_phases"] = [0, 2]
	chart["lanterns"] = [_lamp("L", 0, 0, "S", "white")]
	chart["docks"] = [_need("D", 0, 2, "white")]
	var dry := {"tide_index": 0, "pieces": {}}
	var wet := {"tide_index": 1, "pieces": {}}
	check(Tracer.is_cleared(chart, dry), "beam reaches the dock while the row is dry")
	var stopped: Dictionary = Tracer.trace(chart, wet)
	check(not stopped["docks"]["D"].has("white"), "beam into a flooded row does not reach the dock")
	check(not Tracer.is_cleared(chart, wet), "flooded row fails the chart")
	var saw_dock := false
	for raw in stopped["segments"]:
		var seg: Dictionary = raw
		if is_equal_approx(float(seg["y1"]), 2.5) or is_equal_approx(float(seg["y0"]), 2.5):
			saw_dock = true
	check(not saw_dock, "flooded beam segment stops before the dock cell")

func test_flooded_lantern_is_dark() -> void:
	var chart := _blank(3, 2)
	chart["tide_phases"] = [0, 1]
	chart["lanterns"] = [_lamp("L", 0, 1, "E", "white")]
	chart["docks"] = [_need("D", 2, 1, "white")]
	var dry := {"tide_index": 0, "pieces": {}}
	var wet := {"tide_index": 1, "pieces": {}}
	check(Tracer.is_cleared(chart, dry), "dry lantern reaches the dock")
	var result: Dictionary = Tracer.trace(chart, wet)
	check(result["segments"].is_empty() and not Tracer.is_cleared(chart, wet), "flooded lantern does not emit")

func test_mirror_loop_terminates() -> void:
	# Rectangle B(2,1) C(4,1) D(4,3) E(2,3). White enters B traveling north
	# and the four mirrors return it to the same cell and direction.
	var chart := _blank(6, 5)
	chart["fixtures"] = [
		{"id": "B", "kind": "mirror", "x": 2, "y": 1, "rot": 0},
		{"id": "C", "kind": "mirror", "x": 4, "y": 1, "rot": 90},
		{"id": "D", "kind": "mirror", "x": 4, "y": 3, "rot": 0},
		{"id": "E", "kind": "mirror", "x": 2, "y": 3, "rot": 90},
	]
	var state := {"tide_index": 0, "pieces": {}}
	var result: Dictionary = Tracer.cast_beam(chart, state, Vector2i(2, 1), "N", "white")
	var count := int(result["segments"].size())
	check(count > 4 and count <= Tracer.MAX_SEGMENTS, "mirror loop terminates (%d segments)" % count)

func test_charts() -> void:
	var book: Array = Charts.all()
	check(Charts.quay().size() == 6, "quay keeps six charts")
	check(Charts.reach().size() == 8, "reach adds eight charts")
	check(Charts.basin().size() == 8, "basin adds eight charts")
	check(Charts.painted().size() == 8, "painted lock adds eight charts")
	check(Charts.west().size() == 8, "west return adds eight charts")
	check(Charts.meet().size() == 8, "meeting glass adds eight charts")
	check(Charts.tide().size() == 8, "tide mirror adds eight charts")
	check(Charts.shutter().size() == 8, "shutter adds eight charts")
	check(Charts.stain().size() == 8, "stain adds eight charts")
	check(Charts.vane().size() == 8, "vane adds eight charts")
	check(Charts.well().size() == 8, "well adds eight charts")
	check(book.size() == 86, "eighty-six charts")
	check(str(book[13]["id"]) == "14" and str(book[13]["title"]) == "The Holding Line", "chart 14 stays the reach capstone")
	check(str(book[14]["title"]) == "North Light", "chart 15 opens the basin")
	check(str(book[21]["id"]) == "22" and str(book[21]["title"]) == "The Basin Mark", "chart 22 stays the basin capstone")
	check(str(book[22]["title"]) == "Red Already", "chart 23 opens the painted lock")
	check(str(book[29]["id"]) == "30" and str(book[29]["title"]) == "The Painted Mark", "chart 30 stays the painted capstone")
	check(str(book[30]["title"]) == "West Light", "chart 31 opens the west return")
	check(str(book[37]["id"]) == "38" and str(book[37]["title"]) == "The Return Mark", "chart 38 stays the west capstone")
	check(str(book[38]["title"]) == "Two Lamps", "chart 39 opens the meeting glass")
	check(str(book[45]["id"]) == "46" and str(book[45]["title"]) == "The Meeting Mark", "chart 46 stays the meeting capstone")
	check(str(book[46]["title"]) == "Wet Glass", "chart 47 opens the tide mirror")
	check(str(book[53]["id"]) == "54" and str(book[53]["title"]) == "The Tide Mark", "chart 54 stays the tide capstone")
	check(str(book[54]["title"]) == "The Dry Gate", "chart 55 opens the shutter")
	check(str(book[61]["id"]) == "62" and str(book[61]["title"]) == "The Shutter Mark", "chart 62 stays the shutter capstone")
	check(str(book[62]["title"]) == "The Red Stain", "chart 63 opens the stain")
	check(str(book[69]["id"]) == "70" and str(book[69]["title"]) == "The Stain Mark", "chart 70 stays the stain capstone")
	check(str(book[70]["title"]) == "The East Vane", "chart 71 opens the vane")
	check(str(book[77]["id"]) == "78" and str(book[77]["title"]) == "The Vane Mark", "chart 78 stays the vane capstone")
	check(str(book[78]["title"]) == "The North Well", "chart 79 opens the well")
	var seen_ids := {}
	var seen_titles := {}
	var quay_titles := ["First Glass", "Around the Pilings", "High Water", "Sleeping Hull", "Split the White", "The Night Mark"]
	for i in Charts.quay().size():
		check(str(Charts.quay()[i]["title"]) == quay_titles[i], "quay chart %d keeps its title" % (i + 1))
	for raw in book:
		var chart: Dictionary = raw
		var id := str(chart["id"])
		var title := str(chart["title"])
		check(not seen_ids.has(id), "chart id %s is unique" % id)
		if seen_titles.has(title):
			var echoed := (title == "After the Color" and id == "81") or (title == "Above the Gate" and id == "84")
			check(echoed, "chart title %s is unique" % title)
		else:
			check(true, "chart title %s is unique" % title)
			seen_titles[title] = true
		seen_ids[id] = true
		var initial := Charts.make_state(chart, false)
		var solved := Charts.make_state(chart, true)
		var initial_errors: Array = Charts.placement_errors(chart, initial)
		var solved_errors: Array = Charts.placement_errors(chart, solved)
		check(initial_errors.is_empty(), "chart %s initial placement %s" % [id, str(initial_errors)])
		check(solved_errors.is_empty(), "chart %s solution placement %s" % [id, str(solved_errors)])
		var moved := false
		for piece_raw in chart["pieces"]:
			var piece: Dictionary = piece_raw
			var kind := str(piece["kind"])
			var start_rot := Tracer.norm_rot(kind, int(piece["start_rot"]))
			var sol_rot := Tracer.norm_rot(kind, int(piece["solution_rot"]))
			if start_rot != sol_rot or str(piece["start_socket"]) != str(piece["solution_socket"]):
				moved = true
		check(moved, "chart %s pieces start unsolved" % id)
		if not Tracer.is_cleared(chart, initial):
			check(true, "chart %s initial is unsolved" % id)
		else:
			check(false, "chart %s initial is unsolved %s" % [id, str(Tracer.trace(chart, initial))])
		var solved_trace: Dictionary = Tracer.trace(chart, solved)
		var solved_again: Dictionary = Tracer.trace(chart, solved)
		check(_trace_sig(solved_trace) == _trace_sig(solved_again), "chart %s solution trace is deterministic" % id)
		var initial_trace: Dictionary = Tracer.trace(chart, initial)
		var initial_again: Dictionary = Tracer.trace(chart, initial)
		check(_trace_sig(initial_trace) == _trace_sig(initial_again), "chart %s initial trace is deterministic" % id)
		if Tracer.is_cleared(chart, solved):
			check(true, "chart %s solution clears" % id)
		else:
			check(false, "chart %s solution clears notes=%s trace=%s" % [id, str(Tracer.failure_notes(chart, solved)), str(solved_trace)])
		check(int(solved_trace["segments"].size()) > 0, "chart %s solution draws a beam" % id)
		var lit: Dictionary = Tracer.trace(chart, solved)
		for dock_raw in chart["docks"]:
			var dock: Dictionary = dock_raw
			check(lit["docks"][str(dock["id"])].has(str(dock["color"])), "chart %s dock %s has its color" % [id, str(dock["id"])])
		for boat_raw in chart["boats"]:
			var boat: Dictionary = boat_raw
			check(not bool(lit["boats"][str(boat["id"])]), "chart %s boat %s stays dark" % [id, str(boat["id"])])
		var clears: Array = _clears(chart)
		if clears.size() == 1:
			check(true, "chart %s has one clearing state" % id)
			check(_same_solution(chart, clears[0], solved), "chart %s clearing state is the authored solution" % id)
		else:
			var shown: Array = clears.slice(0, 4)
			check(false, "chart %s has one clearing state (found %d) %s" % [id, clears.size(), str(shown)])

func test_chart_4_boat() -> void:
	var chart: Dictionary = Charts.all()[3]
	var solved := Charts.make_state(chart, true)
	check(not bool(Tracer.trace(chart, solved)["boats"]["B"]), "chart 4 solution keeps the hull dark")
	var spoiled := Charts.duplicate_state(solved)
	spoiled["pieces"]["M"]["rot"] = 90
	var lit: Dictionary = Tracer.trace(chart, spoiled)
	check(bool(lit["boats"]["B"]), "chart 4 mutated solution lights the hull")
	check(not Tracer.is_cleared(chart, spoiled), "chart 4 mutated solution does not clear")

func test_one_rotation_is_not_solved() -> void:
	var chart: Dictionary = Charts.all()[0]
	var almost := Charts.make_state(chart, true)
	var rot := int(almost["pieces"]["M"]["rot"])
	almost["pieces"]["M"]["rot"] = Tracer.turn_rot("mirror", rot)
	check(not Tracer.is_cleared(chart, almost), "chart 1 one turn from solved is not solved")
	check(Tracer.is_cleared(chart, Charts.make_state(chart, true)), "chart 1 solved state still clears")

func test_hint_points_at_one_piece() -> void:
	var chart: Dictionary = Charts.all()[0]
	var solved := Charts.make_state(chart, true)
	check(Hints.first_wrong(chart, solved) == "", "hint does not mark a solved chart")
	check(Hints.wrong_pieces(chart, solved).is_empty(), "solved chart has no wrong pieces")
	var equivalent := Charts.duplicate_state(solved)
	equivalent["pieces"]["M"]["rot"] = 180
	check(Tracer.is_cleared(chart, equivalent), "mirror turned 180 degrees still solves")
	check(Hints.first_wrong(chart, equivalent) == "", "equivalent mirror facing is not marked wrong")
	var almost := Charts.duplicate_state(solved)
	almost["pieces"]["M"]["rot"] = Tracer.turn_rot("mirror", int(almost["pieces"]["M"]["rot"]))
	var wrong := Hints.wrong_pieces(chart, almost)
	check(wrong.size() == 1 and wrong[0] == "M", "nearly solved chart has one wrong piece")
	check(Hints.first_wrong(chart, almost) == "M", "hint points at the one wrong piece")
	var taken: Dictionary = Hints.take_hint(chart, almost, 3, "")
	check(taken["kind"] == "new" and taken["mark"] == "M" and int(taken["hints_left"]) == 2, "hint spends one and marks M")
	var again: Dictionary = Hints.take_hint(chart, almost, int(taken["hints_left"]), str(taken["mark"]))
	check(again["kind"] == "same" and int(again["hints_left"]) == 2, "the same hint is not spent twice")

func test_hint_budget_never_marks_every_piece() -> void:
	var chart: Dictionary = Charts.all()[5]
	var state := Charts.make_state(chart, false)
	var left := 3
	var mark := ""
	var revealed: Array = []
	for _i in 3:
		var step: Dictionary = Hints.take_hint(chart, state, left, mark)
		check(step["kind"] == "new", "chart 6 hint %d is new" % (revealed.size() + 1))
		left = int(step["hints_left"])
		mark = str(step["mark"])
		revealed.append(mark)
		_solve_piece(chart, state, mark)
		mark = ""
	check(left == 0, "three hints are spent")
	check(not Hints.wrong_pieces(chart, state).is_empty(), "a wrong piece remains after three hints")
	var blocked: Dictionary = Hints.take_hint(chart, state, left, "")
	check(blocked["kind"] == "empty", "the fourth hint reveals nothing")
	var remaining := Hints.wrong_pieces(chart, state)
	check(remaining.size() == 1 and not revealed.has(remaining[0]), "the last wrong piece was never marked")

func test_chart_3_tide() -> void:
	var chart: Dictionary = Charts.all()[2]
	var low := Charts.make_state(chart, false)
	var open: Dictionary = Tracer.trace(chart, low)
	check(open["docks"]["D"].has("white"), "chart 3 low route lights the dock at low tide")
	check(bool(open["boats"]["B"]), "chart 3 low tide leaves the hull in the light")
	check(not Tracer.is_cleared(chart, low), "chart 3 low tide does not clear")
	var drowned := Charts.duplicate_state(low)
	drowned["tide_index"] = 2
	var shut: Dictionary = Tracer.trace(chart, drowned)
	check(not shut["docks"]["D"].has("white"), "chart 3 flooded low route no longer reaches the dock")
	check(not bool(shut["boats"]["B"]), "chart 3 flooded low lantern leaves the hull dark")
	var high_dry := Charts.make_state(chart, true)
	high_dry["tide_index"] = 0
	var early: Dictionary = Tracer.trace(chart, high_dry)
	check(early["docks"]["D"].has("white") and bool(early["boats"]["B"]), "chart 3 high path at low tide still lights the hull")
	check(not Tracer.is_cleared(chart, high_dry), "chart 3 requires the high-water mark")
	for raw in _clears(chart):
		var clearing: Dictionary = raw
		check(int(clearing["tide_index"]) == 2, "every chart 3 clear is at the high-water mark")

func test_chart_6_combined() -> void:
	var chart: Dictionary = Charts.all()[5]
	var solved := Charts.make_state(chart, true)
	var held: Dictionary = Tracer.trace(chart, solved)
	check(held["docks"]["D"].has("red") and not bool(held["boats"]["B"]), "chart 6 solution is red on the dock and a dark hull")
	var low := Charts.duplicate_state(solved)
	low["tide_index"] = 0
	check(bool(Tracer.trace(chart, low)["boats"]["B"]), "chart 6 low tide lights the hull")
	check(not Tracer.is_cleared(chart, low), "chart 6 low tide does not clear")
	var aimed := Charts.duplicate_state(solved)
	aimed["pieces"]["M"]["rot"] = 90
	check(bool(Tracer.trace(chart, aimed)["boats"]["B"]), "chart 6 mirror turned into the hull lights it")
	check(not Tracer.is_cleared(chart, aimed), "chart 6 hull-lighting mirror does not clear")
	var tint := Charts.duplicate_state(solved)
	tint["pieces"]["C"]["rot"] = 90
	check(not Tracer.trace(chart, tint)["docks"]["D"].has("red"), "chart 6 blue pane blocks red")
	check(not Tracer.is_cleared(chart, tint), "chart 6 wrong pane does not clear")
	for raw in _clears(chart):
		var clearing: Dictionary = raw
		check(int(clearing["tide_index"]) == 1, "every chart 6 clear has the tide raised")

func test_reach_book() -> void:
	var reach: Array = Charts.reach()
	check(reach.size() == 8, "reach book has eight charts")
	check(str(reach[0]["teach"]).to_lower().contains("blue"), "chart 7 teaches the blue face")
	check(str(reach[1]["teach"]).to_lower().contains("middle"), "chart 8 teaches the middle mark")
	for raw in reach:
		var chart: Dictionary = raw
		check(str(chart["harbor"]) == Charts.REACH, "chart %s belongs to the reach" % str(chart["id"]))

	var blue: Dictionary = reach[0]
	var blue_solved := Charts.make_state(blue, true)
	var blue_hit: Dictionary = Tracer.trace(blue, blue_solved)
	check(blue_hit["docks"]["Rd"].has("red") and blue_hit["docks"]["Bd"].has("blue"), "chart 7 lands red and blue")
	var blue_blocked := Charts.duplicate_state(blue_solved)
	blue_blocked["pieces"]["C"]["rot"] = 0
	var blocked_hit: Dictionary = Tracer.trace(blue, blue_blocked)
	check(blocked_hit["docks"]["Rd"].has("red") and not blocked_hit["docks"]["Bd"].has("blue"), "chart 7 red pane lets red climb and stops blue")

	var marks: Dictionary = reach[1]
	var mid := Charts.make_state(marks, true)
	check(int(mid["tide_index"]) == 1, "chart 8 is authored at mid water")
	var low := Charts.duplicate_state(mid)
	low["tide_index"] = 0
	check(bool(Tracer.trace(marks, low)["boats"]["B"]), "chart 8 low water lights the hull")
	check(not Tracer.is_cleared(marks, low), "chart 8 low water does not clear")
	var high := Charts.duplicate_state(mid)
	high["tide_index"] = 2
	check(not Tracer.trace(marks, high)["docks"]["D"].has("white"), "chart 8 high water misses the dock")
	check(not Tracer.is_cleared(marks, high), "chart 8 high water does not clear")

	var shield: Dictionary = reach[2]
	var shield_solved := Charts.make_state(shield, true)
	var shield_hit: Dictionary = Tracer.trace(shield, shield_solved)
	check(shield_hit["docks"]["Rd"].has("red") and not bool(shield_hit["boats"]["B"]), "chart 9 keeps red and a dark hull")
	var open_shield := Charts.duplicate_state(shield_solved)
	open_shield["pieces"]["C"]["rot"] = 90
	var open_hit: Dictionary = Tracer.trace(shield, open_shield)
	check(bool(open_hit["boats"]["B"]) and open_hit["docks"]["Rd"].has("red"), "chart 9 blue pane lets blue wake the hull")
	check(not Tracer.is_cleared(shield, open_shield), "chart 9 open pane does not clear")

	var bend: Dictionary = reach[3]
	var bend_solved := Charts.make_state(bend, true)
	var missed := Charts.duplicate_state(bend_solved)
	missed["pieces"]["M"]["rot"] = 90
	check(not Tracer.trace(bend, missed)["docks"]["Rd"].has("red"), "chart 10 wrong mirror misses the red dock")
	var tinted := Charts.duplicate_state(bend_solved)
	tinted["pieces"]["C"]["rot"] = 0
	check(not Tracer.trace(bend, tinted)["docks"]["Bd"].has("blue"), "chart 10 red pane blocks blue")

	var dry: Dictionary = reach[4]
	var dry_solved := Charts.make_state(dry, true)
	check(int(dry_solved["tide_index"]) == 1, "chart 11 is authored at mid water")
	var dry_low := Charts.duplicate_state(dry_solved)
	dry_low["tide_index"] = 0
	check(bool(Tracer.trace(dry, dry_low)["boats"]["B"]), "chart 11 low water lights the hull")
	var dry_high := Charts.duplicate_state(dry_solved)
	dry_high["tide_index"] = 2
	check(not Tracer.trace(dry, dry_high)["docks"]["Bd"].has("blue"), "chart 11 high water shuts the blue dock")
	for raw_clear in _clears(dry):
		var clearing: Dictionary = raw_clear
		check(int(clearing["tide_index"]) == 1, "every chart 11 clear is mid water")

	var socket: Dictionary = reach[5]
	var socket_start := Charts.make_state(socket, false)
	check(str(socket_start["pieces"]["P"]["socket"]) == "side", "chart 12 prism starts off the lantern row")
	check(not Tracer.trace(socket, socket_start)["docks"]["Rd"].has("red"), "chart 12 side socket does not feed the red dock")

	var crossed: Dictionary = reach[6]
	var crossed_solved := Charts.make_state(crossed, true)
	var crossed_hit: Dictionary = Tracer.trace(crossed, crossed_solved)
	check(crossed_hit["docks"]["Rd"].has("red") and crossed_hit["docks"]["Bd"].has("blue"), "chart 13 lands both colors")
	check(not bool(crossed_hit["boats"]["B"]), "chart 13 solution leaves the hull dark")
	var into_hull := Charts.duplicate_state(crossed_solved)
	into_hull["pieces"]["Mr"]["rot"] = 90
	check(bool(Tracer.trace(crossed, into_hull)["boats"]["B"]), "chart 13 top mirror turned west wakes the hull")

	var hold: Dictionary = reach[7]
	var hold_solved := Charts.make_state(hold, true)
	check(int(hold_solved["tide_index"]) == 1, "chart 14 is authored at mid water")
	var hold_hit: Dictionary = Tracer.trace(hold, hold_solved)
	check(hold_hit["docks"]["Rd"].has("red") and hold_hit["docks"]["Bd"].has("blue") and not bool(hold_hit["boats"]["B"]), "chart 14 solution holds both docks and a dark hull")
	var hold_low := Charts.duplicate_state(hold_solved)
	hold_low["tide_index"] = 0
	check(bool(Tracer.trace(hold, hold_low)["boats"]["B"]), "chart 14 low water lights the hull")
	var hold_high := Charts.duplicate_state(hold_solved)
	hold_high["tide_index"] = 2
	check(not Tracer.trace(hold, hold_high)["docks"]["Bd"].has("blue"), "chart 14 high water misses the blue dock")
	for raw_hold in _clears(hold):
		var hold_clear: Dictionary = raw_hold
		check(int(hold_clear["tide_index"]) == 1, "every chart 14 clear is mid water")
func test_basin_book() -> void:
	var basin: Array = Charts.basin()
	check(basin.size() == 8, "basin book has eight charts")
	var titles := ["North Light", "Bend North", "The South Door", "The Covered Row", "The Open Socket", "The Twin Climb", "The Middle Socket", "The Basin Mark"]
	for i in basin.size():
		var chart: Dictionary = basin[i]
		check(str(chart["id"]) == str(i + 15), "basin chart %d keeps its number" % (i + 15))
		check(str(chart["title"]) == str(titles[i]), "basin chart %d keeps its title" % (i + 15))
		check(str(chart["harbor"]) == Charts.BASIN, "chart %s belongs to the basin" % str(chart["id"]))
	check(str(basin[0]["teach"]).to_lower().contains("north"), "chart 15 teaches the north light")
	check(str(basin[1]["teach"]).to_lower().contains("bend"), "chart 16 teaches the bend")
	check(str(basin[1]["teach"]).to_lower().contains("north"), "chart 16 names the north light")
	check(str(basin[2]["teach"]).to_lower().contains("south"), "chart 17 teaches the south door")

	var north: Dictionary = basin[0]
	var north_solved := Charts.make_state(north, true)
	var north_hit: Dictionary = Tracer.trace(north, north_solved)
	check(north_hit["docks"]["Rd"].has("red") and north_hit["docks"]["Bd"].has("blue"), "chart 15 lands red west and blue east")
	var east_face := Charts.duplicate_state(north_solved)
	east_face["pieces"]["P"]["rot"] = 90
	check(not Tracer.trace(north, east_face)["docks"]["Rd"].has("red"), "chart 15 east face absorbs the north beam")

	var bend: Dictionary = basin[1]
	var bend_hit: Dictionary = Tracer.trace(bend, Charts.make_state(bend, true))
	check(bend_hit["docks"]["Rd"].has("red") and bend_hit["docks"]["Bd"].has("blue"), "chart 16 bent beam splits on the set prism")
	var down := Charts.make_state(bend, true)
	down["pieces"]["M"]["rot"] = 90
	check(not Tracer.trace(bend, down)["docks"]["Rd"].has("red"), "chart 16 mirror turned south misses both docks")

	var door: Dictionary = basin[2]
	var door_solved := Charts.make_state(door, true)
	var door_hit: Dictionary = Tracer.trace(door, door_solved)
	check(door_hit["docks"]["Rd"].has("red") and door_hit["docks"]["Bd"].has("blue") and not bool(door_hit["boats"]["H"]), "chart 17 lands both colors and keeps the hull dark")
	var into_hull := Charts.duplicate_state(door_solved)
	into_hull["pieces"]["M"]["rot"] = 0
	check(bool(Tracer.trace(door, into_hull)["boats"]["H"]), "chart 17 mirror turned north wakes the hull")
	var blocked := Charts.duplicate_state(door_solved)
	blocked["pieces"]["C"]["rot"] = 90
	var blocked_hit: Dictionary = Tracer.trace(door, blocked)
	check(not blocked_hit["docks"]["Rd"].has("red") and blocked_hit["docks"]["Bd"].has("blue"), "chart 17 blue pane stops red and lets blue pass")
	var north_face := Charts.duplicate_state(door_solved)
	north_face["pieces"]["P"]["rot"] = 0
	check(not Tracer.trace(door, north_face)["docks"]["Bd"].has("blue"), "chart 17 north face does not drink the southbound beam")

	var covered: Dictionary = basin[3]
	var covered_solved := Charts.make_state(covered, true)
	check(int(covered_solved["tide_index"]) == 1, "chart 18 is authored at mid water")
	var covered_low := Charts.duplicate_state(covered_solved)
	covered_low["tide_index"] = 0
	check(bool(Tracer.trace(covered, covered_low)["boats"]["B"]), "chart 18 low water lights the lower hull")
	var covered_high := Charts.duplicate_state(covered_solved)
	covered_high["tide_index"] = 2
	var covered_high_hit: Dictionary = Tracer.trace(covered, covered_high)
	check(not covered_high_hit["docks"]["Rd"].has("red") and not covered_high_hit["docks"]["Bd"].has("blue"), "chart 18 high water shuts the glass row")
	for raw_clear in _clears(covered):
		var clearing: Dictionary = raw_clear
		check(int(clearing["tide_index"]) == 1, "every chart 18 clear is mid water")

	var socket: Dictionary = basin[4]
	var socket_start := Charts.make_state(socket, false)
	check(str(socket_start["pieces"]["P"]["socket"]) == "side", "chart 19 prism starts off the beam")
	check(not Tracer.trace(socket, socket_start)["docks"]["Rd"].has("red"), "chart 19 side socket does not feed the red dock")
	var socket_solved := Charts.make_state(socket, true)
	var aimed_out := Charts.duplicate_state(socket_solved)
	aimed_out["pieces"]["M"]["rot"] = 0
	check(bool(Tracer.trace(socket, aimed_out)["boats"]["H"]), "chart 19 mirror turned north wakes the hull")

	var climb: Dictionary = basin[5]
	var climb_solved := Charts.make_state(climb, true)
	var climb_hit: Dictionary = Tracer.trace(climb, climb_solved)
	check(climb_hit["docks"]["Rd"].has("red") and climb_hit["docks"]["Bd"].has("blue") and not bool(climb_hit["boats"]["B"]), "chart 20 climbs both colors past a dark hull")
	var lower := Charts.duplicate_state(climb_solved)
	lower["pieces"]["M"]["rot"] = 90
	check(bool(Tracer.trace(climb, lower)["boats"]["B"]), "chart 20 lower mirror turned south wakes the hull")
	var red_pane := Charts.duplicate_state(climb_solved)
	red_pane["pieces"]["Cr"]["rot"] = 90
	var red_pane_hit: Dictionary = Tracer.trace(climb, red_pane)
	check(not red_pane_hit["docks"]["Rd"].has("red") and red_pane_hit["docks"]["Bd"].has("blue"), "chart 20 blue pane on the red climb stops red")
	var blue_pane := Charts.duplicate_state(climb_solved)
	blue_pane["pieces"]["Cb"]["rot"] = 0
	var blue_pane_hit: Dictionary = Tracer.trace(climb, blue_pane)
	check(blue_pane_hit["docks"]["Rd"].has("red") and not blue_pane_hit["docks"]["Bd"].has("blue"), "chart 20 red pane on the blue climb stops blue")
	var south_face := Charts.duplicate_state(climb_solved)
	south_face["pieces"]["P"]["rot"] = 180
	check(not Tracer.trace(climb, south_face)["docks"]["Rd"].has("red"), "chart 20 south face does not drink the northbound beam")

	var mid: Dictionary = basin[6]
	var mid_solved := Charts.make_state(mid, true)
	check(int(mid_solved["tide_index"]) == 1, "chart 21 is authored at mid water")
	var mid_low := Charts.duplicate_state(mid_solved)
	mid_low["tide_index"] = 0
	check(bool(Tracer.trace(mid, mid_low)["boats"]["B"]), "chart 21 low water lights the lower hull")
	var mid_high := Charts.duplicate_state(mid_solved)
	mid_high["tide_index"] = 2
	check(not Tracer.trace(mid, mid_high)["docks"]["Bd"].has("blue"), "chart 21 high water shuts the glass row")
	var mid_side := Charts.duplicate_state(mid_solved)
	mid_side["pieces"]["P"]["socket"] = "side"
	check(not Tracer.trace(mid, mid_side)["docks"]["Rd"].has("red"), "chart 21 side socket misses the red dock")
	for raw_mid in _clears(mid):
		var mid_clear: Dictionary = raw_mid
		check(int(mid_clear["tide_index"]) == 1, "every chart 21 clear is mid water")

	var mark: Dictionary = basin[7]
	var mark_solved := Charts.make_state(mark, true)
	check(int(mark_solved["tide_index"]) == 1, "chart 22 is authored at mid water")
	var mark_hit: Dictionary = Tracer.trace(mark, mark_solved)
	check(mark_hit["docks"]["Rd"].has("red") and mark_hit["docks"]["Bd"].has("blue") and not bool(mark_hit["boats"]["B"]) and not bool(mark_hit["boats"]["H"]), "chart 22 holds both docks and both hulls")
	var mark_low := Charts.duplicate_state(mark_solved)
	mark_low["tide_index"] = 0
	check(bool(Tracer.trace(mark, mark_low)["boats"]["B"]), "chart 22 low water lights the lower hull")
	var mark_high := Charts.duplicate_state(mark_solved)
	mark_high["tide_index"] = 2
	var mark_high_hit: Dictionary = Tracer.trace(mark, mark_high)
	check(mark_high_hit["docks"]["Rd"].has("red") and not mark_high_hit["docks"]["Bd"].has("blue"), "chart 22 high water keeps red and loses blue")
	var mark_feed := Charts.duplicate_state(mark_solved)
	mark_feed["pieces"]["Mf"]["rot"] = 0
	check(bool(Tracer.trace(mark, mark_feed)["boats"]["H"]), "chart 22 feed mirror turned north wakes the upper hull")
	for raw_mark in _clears(mark):
		var mark_clear: Dictionary = raw_mark
		check(int(mark_clear["tide_index"]) == 1, "every chart 22 clear is mid water")


func test_painted_book() -> void:
	var painted: Array = Charts.painted()
	check(painted.size() == 8, "painted book has eight charts")
	var titles := ["Red Already", "White Only", "The Side Lamp", "Off the Red Row", "The Covered Lamp", "The South Socket", "The Dry Lamp", "The Painted Mark"]
	for i in painted.size():
		var chart: Dictionary = painted[i]
		check(str(chart["id"]) == str(i + 23), "painted chart %d keeps its number" % (i + 23))
		check(str(chart["title"]) == str(titles[i]), "painted chart %d keeps its title" % (i + 23))
		check(str(chart["harbor"]) == Charts.PAINTED, "chart %s belongs to the painted lock" % str(chart["id"]))
	for raw_old in [Charts.quay(), Charts.reach(), Charts.basin()]:
		var older: Array = raw_old
		for raw_chart in older:
			var old_chart: Dictionary = raw_chart
			for raw_lamp in old_chart["lanterns"]:
				var lamp: Dictionary = raw_lamp
				check(str(lamp["color"]) == "white", "chart %s lantern stays white" % str(old_chart["id"]))
	check(str(painted[0]["teach"]).to_lower().contains("red"), "chart 23 teaches the red lamp")
	check(str(painted[1]["teach"]).to_lower().contains("white"), "chart 24 teaches that a prism drinks white")
	check(str(painted[1]["teach"]).to_lower().contains("red"), "chart 24 names the red lamp")

	var red_lamp: Dictionary = painted[0]
	var red_solved := Charts.make_state(red_lamp, true)
	var red_hit: Dictionary = Tracer.trace(red_lamp, red_solved)
	check(red_hit["docks"]["Rd"].has("red") and not bool(red_hit["boats"]["H"]), "chart 23 lands red and keeps the hull dark")
	var blocked := Charts.duplicate_state(red_solved)
	blocked["pieces"]["C"]["rot"] = 90
	check(not Tracer.trace(red_lamp, blocked)["docks"]["Rd"].has("red"), "chart 23 blue pane stops the red lamp")
	var into_hull := Charts.duplicate_state(red_solved)
	into_hull["pieces"]["M"]["rot"] = 90
	check(bool(Tracer.trace(red_lamp, into_hull)["boats"]["H"]), "chart 23 lower mirror turned south wakes the hull")

	var white_only: Dictionary = painted[1]
	var white_solved := Charts.make_state(white_only, true)
	var white_hit: Dictionary = Tracer.trace(white_only, white_solved)
	check(white_hit["docks"]["Rd"].has("red") and white_hit["docks"]["Bd"].has("blue") and not bool(white_hit["boats"]["H"]), "chart 24 keeps the lamp and splits white")
	var on_red := Charts.duplicate_state(white_solved)
	on_red["pieces"]["P"]["socket"] = "line"
	var swallowed: Dictionary = Tracer.trace(white_only, on_red)
	check(not swallowed["docks"]["Rd"].has("red") and not swallowed["docks"]["Bd"].has("blue"), "chart 24 prism on the red row swallows the lamp and misses the split")
	var east_face := Charts.duplicate_state(white_solved)
	east_face["pieces"]["P"]["rot"] = 90
	check(not Tracer.trace(white_only, east_face)["docks"]["Bd"].has("blue"), "chart 24 east face does not drink the northbound beam")
	var south_split := Charts.duplicate_state(white_solved)
	south_split["pieces"]["P"]["socket"] = "line"
	south_split["pieces"]["P"]["rot"] = 180
	south_split["pieces"]["M"]["rot"] = 90
	var south_hit: Dictionary = Tracer.trace(white_only, south_split)
	check(south_hit["docks"]["Rd"].has("red") and not south_hit["docks"]["Bd"].has("blue"), "chart 24 south face can feed red and still misses blue")

	var side: Dictionary = painted[2]
	var side_solved := Charts.make_state(side, true)
	var side_hit: Dictionary = Tracer.trace(side, side_solved)
	check(side_hit["docks"]["Rd"].has("red") and side_hit["docks"]["Bd"].has("blue") and not bool(side_hit["boats"]["H"]) and not bool(side_hit["boats"]["B"]), "chart 25 lands both colors and keeps both hulls dark")
	var side_red := Charts.duplicate_state(side_solved)
	side_red["pieces"]["Mr"]["rot"] = 90
	check(bool(Tracer.trace(side, side_red)["boats"]["H"]), "chart 25 red mirror turned south wakes the hull")
	var side_white := Charts.duplicate_state(side_solved)
	side_white["pieces"]["Mw"]["rot"] = 90
	check(bool(Tracer.trace(side, side_white)["boats"]["B"]) and not Tracer.trace(side, side_white)["docks"]["Bd"].has("blue"), "chart 25 white mirror turned south wakes the hull and misses blue")
	var side_pane := Charts.duplicate_state(side_solved)
	side_pane["pieces"]["C"]["rot"] = 90
	check(not Tracer.trace(side, side_pane)["docks"]["Rd"].has("red") and Tracer.trace(side, side_pane)["docks"]["Bd"].has("blue"), "chart 25 blue pane stops the red lamp and lets blue through")

	var off: Dictionary = painted[3]
	var off_start := Charts.make_state(off, false)
	check(str(off_start["pieces"]["P"]["socket"]) == "lamp", "chart 26 prism starts on the red lamp")
	check(not Tracer.trace(off, off_start)["docks"]["Rd"].has("red"), "chart 26 lamp socket swallows the red lamp")
	var off_solved := Charts.make_state(off, true)
	var off_hit: Dictionary = Tracer.trace(off, off_solved)
	check(off_hit["docks"]["Rd"].has("red") and off_hit["docks"]["Bd"].has("blue") and not bool(off_hit["boats"]["H"]) and not bool(off_hit["boats"]["B"]), "chart 26 solution holds both docks and both hulls")
	var off_red := Charts.duplicate_state(off_solved)
	off_red["pieces"]["Mr"]["rot"] = 90
	check(bool(Tracer.trace(off, off_red)["boats"]["B"]), "chart 26 lower red mirror turned south wakes the hull")
	var off_white := Charts.duplicate_state(off_solved)
	off_white["pieces"]["Mw"]["rot"] = 90
	check(bool(Tracer.trace(off, off_white)["boats"]["H"]), "chart 26 white mirror turned south wakes the hull")

	var covered: Dictionary = painted[4]
	var covered_solved := Charts.make_state(covered, true)
	check(int(covered_solved["tide_index"]) == 1, "chart 27 is authored at mid water")
	var covered_hit: Dictionary = Tracer.trace(covered, covered_solved)
	check(covered_hit["docks"]["Rd"].has("red") and covered_hit["docks"]["Bd"].has("blue") and not bool(covered_hit["boats"]["H"]), "chart 27 mid water holds both docks and a dark hull")
	var covered_low := Charts.duplicate_state(covered_solved)
	covered_low["tide_index"] = 0
	check(bool(Tracer.trace(covered, covered_low)["boats"]["H"]), "chart 27 low water lights the hull")
	var covered_high := Charts.duplicate_state(covered_solved)
	covered_high["tide_index"] = 2
	check(not Tracer.trace(covered, covered_high)["docks"]["Rd"].has("red") and Tracer.trace(covered, covered_high)["docks"]["Bd"].has("blue"), "chart 27 high water keeps blue and loses the red lamp")
	for raw_covered in _clears(covered):
		var covered_clear: Dictionary = raw_covered
		check(int(covered_clear["tide_index"]) == 1, "every chart 27 clear is mid water")

	var south: Dictionary = painted[5]
	var south_start := Charts.make_state(south, false)
	check(str(south_start["pieces"]["P"]["socket"]) == "line", "chart 28 prism starts on the red lamp")
	var south_solved := Charts.make_state(south, true)
	var south_held: Dictionary = Tracer.trace(south, south_solved)
	check(south_held["docks"]["Rl"].has("red") and south_held["docks"]["Rs"].has("red") and south_held["docks"]["Bd"].has("blue"), "chart 28 lands the lamp and both split colors")
	check(not bool(south_held["boats"]["H"]) and not bool(south_held["boats"]["B"]), "chart 28 solution leaves both hulls dark")
	var south_side := Charts.duplicate_state(south_solved)
	south_side["pieces"]["P"]["socket"] = "line"
	var south_side_hit: Dictionary = Tracer.trace(south, south_side)
	check(not south_side_hit["docks"]["Rl"].has("red") and bool(south_side_hit["boats"]["B"]), "chart 28 lamp socket swallows red and the south beam wakes the lower hull")
	var south_north := Charts.duplicate_state(south_solved)
	south_north["pieces"]["Mw"]["rot"] = 0
	check(bool(Tracer.trace(south, south_north)["boats"]["H"]), "chart 28 mirror turned north wakes the upper hull")
	var south_face := Charts.duplicate_state(south_solved)
	south_face["pieces"]["P"]["rot"] = 0
	check(not Tracer.trace(south, south_face)["docks"]["Bd"].has("blue"), "chart 28 north face does not drink the southbound beam")

	var dry: Dictionary = painted[6]
	var dry_solved := Charts.make_state(dry, true)
	check(int(dry_solved["tide_index"]) == 1, "chart 29 is authored at mid water")
	var dry_hit: Dictionary = Tracer.trace(dry, dry_solved)
	check(dry_hit["docks"]["Rl"].has("red") and dry_hit["docks"]["Rs"].has("red") and dry_hit["docks"]["Bd"].has("blue") and not bool(dry_hit["boats"]["B"]) and not bool(dry_hit["boats"]["H"]), "chart 29 mid water holds the lamp, the split, and dark hulls")
	var dry_low := Charts.duplicate_state(dry_solved)
	dry_low["tide_index"] = 0
	check(bool(Tracer.trace(dry, dry_low)["boats"]["B"]), "chart 29 low water lights the lower hull")
	var dry_high := Charts.duplicate_state(dry_solved)
	dry_high["tide_index"] = 2
	var dry_high_hit: Dictionary = Tracer.trace(dry, dry_high)
	check(dry_high_hit["docks"]["Rl"].has("red") and not dry_high_hit["docks"]["Bd"].has("blue") and not dry_high_hit["docks"]["Rs"].has("red"), "chart 29 high water keeps the lamp and loses the split")
	var dry_lamp := Charts.duplicate_state(dry_solved)
	dry_lamp["pieces"]["P"]["socket"] = "lamp"
	check(not Tracer.trace(dry, dry_lamp)["docks"]["Rl"].has("red"), "chart 29 lamp socket swallows the red lamp")
	for raw_dry in _clears(dry):
		var dry_clear: Dictionary = raw_dry
		check(int(dry_clear["tide_index"]) == 1, "every chart 29 clear is mid water")

	var mark: Dictionary = painted[7]
	var mark_solved := Charts.make_state(mark, true)
	check(int(mark_solved["tide_index"]) == 1, "chart 30 is authored at mid water")
	var mark_hit: Dictionary = Tracer.trace(mark, mark_solved)
	check(mark_hit["docks"]["Rl"].has("red") and mark_hit["docks"]["Rs"].has("red") and mark_hit["docks"]["Bd"].has("blue"), "chart 30 lands the lamp and both split colors")
	check(not bool(mark_hit["boats"]["H"]) and not bool(mark_hit["boats"]["R"]) and not bool(mark_hit["boats"]["B"]), "chart 30 solution leaves every hull dark")
	var mark_low := Charts.duplicate_state(mark_solved)
	mark_low["tide_index"] = 0
	check(bool(Tracer.trace(mark, mark_low)["boats"]["B"]), "chart 30 low water lights the lower hull")
	var mark_high := Charts.duplicate_state(mark_solved)
	mark_high["tide_index"] = 2
	var mark_high_hit: Dictionary = Tracer.trace(mark, mark_high)
	check(mark_high_hit["docks"]["Rl"].has("red") and not mark_high_hit["docks"]["Bd"].has("blue"), "chart 30 high water keeps the lamp and loses blue")
	var mark_feed := Charts.duplicate_state(mark_solved)
	mark_feed["pieces"]["Mw"]["rot"] = 0
	check(bool(Tracer.trace(mark, mark_feed)["boats"]["H"]), "chart 30 white mirror turned north wakes the upper hull")
	var mark_lamp := Charts.duplicate_state(mark_solved)
	mark_lamp["pieces"]["Mr"]["rot"] = 90
	check(bool(Tracer.trace(mark, mark_lamp)["boats"]["R"]), "chart 30 lamp mirror turned south wakes the side hull")
	var mark_blue := Charts.duplicate_state(mark_solved)
	mark_blue["pieces"]["Cb"]["rot"] = 0
	check(not Tracer.trace(mark, mark_blue)["docks"]["Bd"].has("blue") and Tracer.trace(mark, mark_blue)["docks"]["Rs"].has("red"), "chart 30 red pane on the blue exit stops blue")
	for raw_paint in _clears(mark):
		var paint_clear: Dictionary = raw_paint
		check(int(paint_clear["tide_index"]) == 1, "every chart 30 clear is mid water")


func test_west_book() -> void:
	var west: Array = Charts.west()
	check(west.size() == 8, "west book has eight charts")
	var titles := ["West Light", "Bend West", "The Long Return", "The Returning Lamp", "Off the West Row", "The Covered Return", "The South Face", "The Return Mark"]
	for i in west.size():
		var chart: Dictionary = west[i]
		check(str(chart["id"]) == str(i + 31), "west chart %d keeps its number" % (i + 31))
		check(str(chart["title"]) == str(titles[i]), "west chart %d keeps its title" % (i + 31))
		check(str(chart["harbor"]) == Charts.WEST, "chart %s belongs to the west return" % str(chart["id"]))
	var ports: Dictionary = Tracer.prism_ports(270)
	check(ports["entry"] == "W" and ports["red"] == "S" and ports["blue"] == "N", "west face sends blue north and red south")
	check(str(west[0]["teach"]).to_lower().contains("west"), "chart 31 teaches the west light")
	check(str(west[1]["teach"]).to_lower().contains("around"), "chart 32 teaches the turn around")
	check(str(west[1]["teach"]).to_lower().contains("west"), "chart 32 names the west face")

	var light: Dictionary = west[0]
	var light_solved := Charts.make_state(light, true)
	var light_hit: Dictionary = Tracer.trace(light, light_solved)
	check(light_hit["docks"]["Bd"].has("blue") and light_hit["docks"]["Rd"].has("red"), "chart 31 lands blue north and red south")
	var east_face := Charts.duplicate_state(light_solved)
	east_face["pieces"]["P"]["rot"] = 90
	check(not Tracer.trace(light, east_face)["docks"]["Bd"].has("blue"), "chart 31 east face absorbs the west beam")
	var north_face := Charts.duplicate_state(light_solved)
	north_face["pieces"]["P"]["rot"] = 0
	check(not Tracer.trace(light, north_face)["docks"]["Rd"].has("red"), "chart 31 north face absorbs the west beam")
	var south_face := Charts.duplicate_state(light_solved)
	south_face["pieces"]["P"]["rot"] = 180
	check(not Tracer.trace(light, south_face)["docks"]["Bd"].has("blue"), "chart 31 south face absorbs the west beam")

	var bend: Dictionary = west[1]
	var bend_solved := Charts.make_state(bend, true)
	var bend_hit: Dictionary = Tracer.trace(bend, bend_solved)
	check(bend_hit["docks"]["Bd"].has("blue") and bend_hit["docks"]["Rd"].has("red") and not bool(bend_hit["boats"]["H"]), "chart 32 folds the beam onto both docks")
	var bend_up := Charts.duplicate_state(bend_solved)
	bend_up["pieces"]["A"]["rot"] = 0
	check(bool(Tracer.trace(bend, bend_up)["boats"]["H"]), "chart 32 first mirror turned north wakes the hull")
	var bend_east := Charts.duplicate_state(bend_solved)
	bend_east["pieces"]["B"]["rot"] = 90
	check(not Tracer.trace(bend, bend_east)["docks"]["Bd"].has("blue"), "chart 32 second mirror turned east misses the prism")

	var longer: Dictionary = west[2]
	var longer_solved := Charts.make_state(longer, true)
	var longer_hit: Dictionary = Tracer.trace(longer, longer_solved)
	check(longer_hit["docks"]["Bd"].has("blue") and longer_hit["docks"]["Rd"].has("red") and not bool(longer_hit["boats"]["H"]), "chart 33 lands both colors and keeps the hull dark")
	var longer_up := Charts.duplicate_state(longer_solved)
	longer_up["pieces"]["A"]["rot"] = 0
	check(bool(Tracer.trace(longer, longer_up)["boats"]["H"]), "chart 33 upper mirror turned north wakes the hull")
	var longer_pane := Charts.duplicate_state(longer_solved)
	longer_pane["pieces"]["C"]["rot"] = 90
	check(not Tracer.trace(longer, longer_pane)["docks"]["Rd"].has("red") and Tracer.trace(longer, longer_pane)["docks"]["Bd"].has("blue"), "chart 33 blue pane stops red and lets blue climb")
	var longer_east := Charts.duplicate_state(longer_solved)
	longer_east["pieces"]["P"]["rot"] = 90
	check(not Tracer.trace(longer, longer_east)["docks"]["Bd"].has("blue"), "chart 33 east face absorbs the returning beam")

	var lamp: Dictionary = west[3]
	var lamp_solved := Charts.make_state(lamp, true)
	var lamp_hit: Dictionary = Tracer.trace(lamp, lamp_solved)
	check(lamp_hit["docks"]["Rl"].has("red") and lamp_hit["docks"]["Bd"].has("blue") and lamp_hit["docks"]["Rw"].has("red"), "chart 34 lands the lamp and both split colors")
	check(not bool(lamp_hit["boats"]["Hr"]) and not bool(lamp_hit["boats"]["Ha"]), "chart 34 solution leaves both hulls dark")
	var lamp_down := Charts.duplicate_state(lamp_solved)
	lamp_down["pieces"]["Mr"]["rot"] = 90
	check(bool(Tracer.trace(lamp, lamp_down)["boats"]["Hr"]), "chart 34 lamp mirror turned south wakes the hull")
	var lamp_white := Charts.duplicate_state(lamp_solved)
	lamp_white["pieces"]["Ma"]["rot"] = 0
	check(bool(Tracer.trace(lamp, lamp_white)["boats"]["Ha"]), "chart 34 white mirror turned north wakes the hull")
	var lamp_pane := Charts.duplicate_state(lamp_solved)
	lamp_pane["pieces"]["Cp"]["rot"] = 90
	check(not Tracer.trace(lamp, lamp_pane)["docks"]["Rl"].has("red") and Tracer.trace(lamp, lamp_pane)["docks"]["Bd"].has("blue"), "chart 34 blue pane stops the lamp and lets the split through")

	var off: Dictionary = west[4]
	var off_start := Charts.make_state(off, false)
	check(str(off_start["pieces"]["P"]["socket"]) == "lamp", "chart 35 prism starts on the red lamp")
	check(not Tracer.trace(off, off_start)["docks"]["Rl"].has("red"), "chart 35 lamp socket swallows the red lamp")
	var off_solved := Charts.make_state(off, true)
	var off_hit: Dictionary = Tracer.trace(off, off_solved)
	check(off_hit["docks"]["Rl"].has("red") and off_hit["docks"]["Bd"].has("blue") and off_hit["docks"]["Rw"].has("red"), "chart 35 solution holds the lamp and the west split")
	check(not bool(off_hit["boats"]["Hr"]) and not bool(off_hit["boats"]["Ha"]), "chart 35 solution leaves both hulls dark")
	var off_lamp := Charts.duplicate_state(off_solved)
	off_lamp["pieces"]["P"]["socket"] = "lamp"
	check(not Tracer.trace(off, off_lamp)["docks"]["Rl"].has("red") and not Tracer.trace(off, off_lamp)["docks"]["Bd"].has("blue"), "chart 35 lamp socket swallows red and misses the split")
	var off_red := Charts.duplicate_state(off_solved)
	off_red["pieces"]["Mr"]["rot"] = 90
	check(bool(Tracer.trace(off, off_red)["boats"]["Hr"]), "chart 35 lamp mirror turned south wakes the hull")
	var off_white := Charts.duplicate_state(off_solved)
	off_white["pieces"]["Ma"]["rot"] = 0
	check(bool(Tracer.trace(off, off_white)["boats"]["Ha"]), "chart 35 white mirror turned north wakes the hull")

	var covered: Dictionary = west[5]
	var covered_solved := Charts.make_state(covered, true)
	check(int(covered_solved["tide_index"]) == 1, "chart 36 is authored at mid water")
	var covered_hit: Dictionary = Tracer.trace(covered, covered_solved)
	check(covered_hit["docks"]["Rl"].has("red") and covered_hit["docks"]["Bd"].has("blue") and not bool(covered_hit["boats"]["Hb"]), "chart 36 mid water holds the lamp, the blue climb, and a dark hull")
	var covered_low := Charts.duplicate_state(covered_solved)
	covered_low["tide_index"] = 0
	check(bool(Tracer.trace(covered, covered_low)["boats"]["Hb"]), "chart 36 low water lights the lower hull")
	var covered_high := Charts.duplicate_state(covered_solved)
	covered_high["tide_index"] = 2
	check(covered_high["tide_index"] == 2 and Tracer.trace(covered, covered_high)["docks"]["Rl"].has("red") and not Tracer.trace(covered, covered_high)["docks"]["Bd"].has("blue"), "chart 36 high water keeps the lamp and loses blue")
	var covered_pane := Charts.duplicate_state(covered_solved)
	covered_pane["pieces"]["Cb"]["rot"] = 0
	check(not Tracer.trace(covered, covered_pane)["docks"]["Bd"].has("blue") and Tracer.trace(covered, covered_pane)["docks"]["Rl"].has("red"), "chart 36 red pane on the blue climb stops blue")
	for raw_covered in _clears(covered):
		var covered_clear: Dictionary = raw_covered
		check(int(covered_clear["tide_index"]) == 1, "every chart 36 clear is mid water")

	var south: Dictionary = west[6]
	var south_solved := Charts.make_state(south, true)
	var south_hit: Dictionary = Tracer.trace(south, south_solved)
	check(south_hit["docks"]["Bs"].has("blue") and south_hit["docks"]["Rs"].has("red"), "chart 37 south face lands blue west and red east")
	check(south_hit["docks"]["Bw"].has("blue") and south_hit["docks"]["Rw"].has("red") and south_hit["docks"]["Rl"].has("red"), "chart 37 west face and the lamp take their docks")
	check(not bool(south_hit["boats"]["Hs"]) and not bool(south_hit["boats"]["Ha"]), "chart 37 solution leaves both hulls dark")
	var south_up := Charts.duplicate_state(south_solved)
	south_up["pieces"]["Ms"]["rot"] = 0
	check(bool(Tracer.trace(south, south_up)["boats"]["Hs"]), "chart 37 south mirror turned north wakes the hull")
	var south_white := Charts.duplicate_state(south_solved)
	south_white["pieces"]["Ma"]["rot"] = 0
	check(bool(Tracer.trace(south, south_white)["boats"]["Ha"]), "chart 37 white mirror turned north wakes the hull")
	var south_pane := Charts.duplicate_state(south_solved)
	south_pane["pieces"]["Cs"]["rot"] = 90
	check(not Tracer.trace(south, south_pane)["docks"]["Rs"].has("red") and Tracer.trace(south, south_pane)["docks"]["Bs"].has("blue"), "chart 37 blue pane stops the south red and lets blue pass")
	var south_east := Charts.duplicate_state(south_solved)
	south_east["pieces"]["P"]["rot"] = 90
	check(not Tracer.trace(south, south_east)["docks"]["Bw"].has("blue") and Tracer.trace(south, south_east)["docks"]["Rs"].has("red"), "chart 37 east face misses the west dock and leaves the south face")

	var mark: Dictionary = west[7]
	var mark_start := Charts.make_state(mark, false)
	check(str(mark_start["pieces"]["P"]["socket"]) == "lamp", "chart 38 prism starts on the red lamp")
	var mark_solved := Charts.make_state(mark, true)
	check(int(mark_solved["tide_index"]) == 1, "chart 38 is authored at mid water")
	var mark_hit: Dictionary = Tracer.trace(mark, mark_solved)
	check(mark_hit["docks"]["Rl"].has("red") and mark_hit["docks"]["Bs"].has("blue") and mark_hit["docks"]["Rs"].has("red") and mark_hit["docks"]["Bw"].has("blue"), "chart 38 mid water holds the lamp, the south face, and the blue climb")
	check(not bool(mark_hit["boats"]["Hs"]) and not bool(mark_hit["boats"]["Ha"]) and not bool(mark_hit["boats"]["Hb"]), "chart 38 solution leaves every hull dark")
	var mark_low := Charts.duplicate_state(mark_solved)
	mark_low["tide_index"] = 0
	check(bool(Tracer.trace(mark, mark_low)["boats"]["Hb"]), "chart 38 low water lights the lower hull")
	var mark_high := Charts.duplicate_state(mark_solved)
	mark_high["tide_index"] = 2
	var mark_high_hit: Dictionary = Tracer.trace(mark, mark_high)
	check(mark_high_hit["docks"]["Rl"].has("red") and mark_high_hit["docks"]["Rs"].has("red") and mark_high_hit["docks"]["Bs"].has("blue") and not mark_high_hit["docks"]["Bw"].has("blue"), "chart 38 high water keeps the lamp and the south face and loses blue")
	var mark_lamp := Charts.duplicate_state(mark_solved)
	mark_lamp["pieces"]["P"]["socket"] = "lamp"
	check(not Tracer.trace(mark, mark_lamp)["docks"]["Rl"].has("red"), "chart 38 lamp socket swallows the red lamp")
	var mark_feed := Charts.duplicate_state(mark_solved)
	mark_feed["pieces"]["Ms"]["rot"] = 0
	check(bool(Tracer.trace(mark, mark_feed)["boats"]["Hs"]), "chart 38 south mirror turned north wakes the hull")
	var mark_white := Charts.duplicate_state(mark_solved)
	mark_white["pieces"]["Ma"]["rot"] = 0
	check(bool(Tracer.trace(mark, mark_white)["boats"]["Ha"]), "chart 38 white mirror turned north wakes the hull")
	for raw_mark in _clears(mark):
		var mark_clear: Dictionary = raw_mark
		check(int(mark_clear["tide_index"]) == 1, "every chart 38 clear is mid water")


func test_meet_book() -> void:
	var meet: Array = Charts.meet()
	check(meet.size() == 8, "meeting book has eight charts")
	var titles := ["Two Lamps", "Still White", "The Joined Bend", "Off the Glass", "The Covered Meeting", "The West Meeting", "The South Meeting", "The Meeting Mark"]
	for i in meet.size():
		var chart: Dictionary = meet[i]
		check(str(chart["id"]) == str(i + 39), "meeting chart %d keeps its number" % (i + 39))
		check(str(chart["title"]) == str(titles[i]), "meeting chart %d keeps its title" % (i + 39))
		check(str(chart["harbor"]) == Charts.MEET, "chart %s belongs to the meeting glass" % str(chart["id"]))
	check(str(meet[0]["teach"]).to_lower().contains("two lamps"), "chart 39 teaches two lamps on one mirror")
	check(str(meet[1]["teach"]).to_lower().contains("still white"), "chart 40 teaches that the meeting mirror leaves white whole")

	var lamps: Dictionary = meet[0]
	var lamps_solved := Charts.make_state(lamps, true)
	var lamps_hit: Dictionary = Tracer.trace(lamps, lamps_solved)
	check(lamps_hit["docks"]["Rd"].has("red") and lamps_hit["docks"]["Dw"].has("white"), "chart 39 sends red north and white east")
	var lamps_other := Charts.duplicate_state(lamps_solved)
	lamps_other["pieces"]["M"]["rot"] = 90
	var lamps_miss: Dictionary = Tracer.trace(lamps, lamps_other)
	check(lamps_miss["docks"]["Rd"].is_empty() and lamps_miss["docks"]["Dw"].is_empty(), "chart 39 other face sends each beam into the other lamp")

	var whole: Dictionary = meet[1]
	var whole_solved := Charts.make_state(whole, true)
	var whole_hit: Dictionary = Tracer.trace(whole, whole_solved)
	check(whole_hit["docks"]["Rd"].has("red") and whole_hit["docks"]["Rs"].has("red") and whole_hit["docks"]["Bd"].has("blue"), "chart 40 keeps red and splits the white")
	var whole_pane := Charts.duplicate_state(whole_solved)
	whole_pane["pieces"]["C"]["rot"] = 90
	var whole_pane_hit: Dictionary = Tracer.trace(whole, whole_pane)
	check(not whole_pane_hit["docks"]["Rd"].has("red") and whole_pane_hit["docks"]["Rs"].has("red") and whole_pane_hit["docks"]["Bd"].has("blue"), "chart 40 blue pane stops red and leaves the split")
	var whole_face := Charts.duplicate_state(whole_solved)
	whole_face["pieces"]["M"]["rot"] = 90
	var whole_face_hit: Dictionary = Tracer.trace(whole, whole_face)
	check(whole_face_hit["docks"]["Rd"].is_empty() and whole_face_hit["docks"]["Rs"].is_empty() and whole_face_hit["docks"]["Bd"].is_empty(), "chart 40 other face misses every dock")

	var joined: Dictionary = meet[2]
	var joined_solved := Charts.make_state(joined, true)
	var joined_hit: Dictionary = Tracer.trace(joined, joined_solved)
	check(joined_hit["docks"]["Rd"].has("red") and joined_hit["docks"]["Rs"].has("red") and joined_hit["docks"]["Bd"].has("blue") and not bool(joined_hit["boats"]["H"]), "chart 41 lands both bends and keeps the hull dark")
	var joined_up := Charts.duplicate_state(joined_solved)
	joined_up["pieces"]["U"]["rot"] = 90
	check(bool(Tracer.trace(joined, joined_up)["boats"]["H"]) and not Tracer.trace(joined, joined_up)["docks"]["Rd"].has("red"), "chart 41 upper mirror turned west wakes the hull")
	var joined_prism := Charts.duplicate_state(joined_solved)
	joined_prism["pieces"]["P"]["rot"] = 0
	check(Tracer.trace(joined, joined_prism)["docks"]["Rd"].has("red") and not Tracer.trace(joined, joined_prism)["docks"]["Bd"].has("blue"), "chart 41 north face absorbs the eastbound white")
	var joined_pane := Charts.duplicate_state(joined_solved)
	joined_pane["pieces"]["Cb"]["rot"] = 0
	check(not Tracer.trace(joined, joined_pane)["docks"]["Bd"].has("blue") and Tracer.trace(joined, joined_pane)["docks"]["Rs"].has("red"), "chart 41 red pane on the blue exit stops blue")

	var off: Dictionary = meet[3]
	var off_start := Charts.make_state(off, false)
	check(str(off_start["pieces"]["P"]["socket"]) == "lamp", "chart 42 prism starts on the red lamp")
	var off_solved := Charts.make_state(off, true)
	var off_hit: Dictionary = Tracer.trace(off, off_solved)
	check(off_hit["docks"]["Rd"].has("red") and off_hit["docks"]["Rs"].has("red") and off_hit["docks"]["Bd"].has("blue"), "chart 42 solution holds the lamp and the split")
	check(not bool(off_hit["boats"]["Hu"]) and not bool(off_hit["boats"]["Hw"]), "chart 42 solution leaves both hulls dark")
	var off_lamp := Charts.duplicate_state(off_solved)
	off_lamp["pieces"]["P"]["socket"] = "lamp"
	var off_lamp_hit: Dictionary = Tracer.trace(off, off_lamp)
	check(off_lamp_hit["docks"]["Rd"].is_empty() and bool(off_lamp_hit["boats"]["Hw"]), "chart 42 lamp socket swallows red and lets white wake the hull")
	var off_up := Charts.duplicate_state(off_solved)
	off_up["pieces"]["U"]["rot"] = 90
	check(bool(Tracer.trace(off, off_up)["boats"]["Hu"]) and Tracer.trace(off, off_up)["docks"]["Bd"].has("blue"), "chart 42 upper mirror turned west wakes the hull and leaves the split")

	var covered: Dictionary = meet[4]
	var covered_solved := Charts.make_state(covered, true)
	check(int(covered_solved["tide_index"]) == 1, "chart 43 is authored at mid water")
	var covered_hit: Dictionary = Tracer.trace(covered, covered_solved)
	check(covered_hit["docks"]["Rd"].has("red") and covered_hit["docks"]["Bd"].has("blue") and not bool(covered_hit["boats"]["Hb"]), "chart 43 mid water holds the lamp, the blue dock, and a dark hull")
	var covered_low := Charts.duplicate_state(covered_solved)
	covered_low["tide_index"] = 0
	check(bool(Tracer.trace(covered, covered_low)["boats"]["Hb"]), "chart 43 low water lights the lower hull")
	check(not Tracer.is_cleared(covered, covered_low), "chart 43 low water does not clear")
	var covered_high := Charts.duplicate_state(covered_solved)
	covered_high["tide_index"] = 2
	var covered_high_hit: Dictionary = Tracer.trace(covered, covered_high)
	check(covered_high_hit["docks"]["Rd"].has("red") and not covered_high_hit["docks"]["Bd"].has("blue"), "chart 43 high water keeps the lamp and loses blue")
	for raw_covered in _clears(covered):
		var covered_clear: Dictionary = raw_covered
		check(int(covered_clear["tide_index"]) == 1, "every chart 43 clear is mid water")

	var west: Dictionary = meet[5]
	var west_solved := Charts.make_state(west, true)
	var west_hit: Dictionary = Tracer.trace(west, west_solved)
	check(west_hit["docks"]["Rd"].has("red") and west_hit["docks"]["Bd"].has("blue") and west_hit["docks"]["Rw"].has("red"), "chart 44 lands the lamp and the west face")
	check(not bool(west_hit["boats"]["Hu"]) and not bool(west_hit["boats"]["Ha"]) and not bool(west_hit["boats"]["Hb"]), "chart 44 solution leaves every hull dark")
	var west_east := Charts.duplicate_state(west_solved)
	west_east["pieces"]["P"]["rot"] = 90
	check(Tracer.trace(west, west_east)["docks"]["Rd"].has("red") and not Tracer.trace(west, west_east)["docks"]["Bd"].has("blue"), "chart 44 east face absorbs the returning beam")
	var west_feed := Charts.duplicate_state(west_solved)
	west_feed["pieces"]["A"]["rot"] = 0
	check(bool(Tracer.trace(west, west_feed)["boats"]["Ha"]), "chart 44 east mirror turned north wakes the hull")
	var west_fold := Charts.duplicate_state(west_solved)
	west_fold["pieces"]["B"]["rot"] = 90
	check(bool(Tracer.trace(west, west_fold)["boats"]["Hb"]), "chart 44 west mirror turned east wakes the hull")
	var west_up := Charts.duplicate_state(west_solved)
	west_up["pieces"]["U"]["rot"] = 90
	check(bool(Tracer.trace(west, west_up)["boats"]["Hu"]) and Tracer.trace(west, west_up)["docks"]["Bd"].has("blue"), "chart 44 upper mirror turned west wakes the hull and leaves the west face")
	var west_pane := Charts.duplicate_state(west_solved)
	west_pane["pieces"]["Cb"]["rot"] = 0
	check(not Tracer.trace(west, west_pane)["docks"]["Bd"].has("blue") and Tracer.trace(west, west_pane)["docks"]["Rw"].has("red"), "chart 44 red pane on the blue climb stops blue")

	var south: Dictionary = meet[6]
	var south_start := Charts.make_state(south, false)
	check(str(south_start["pieces"]["P"]["socket"]) == "lamp", "chart 45 prism starts on the red lamp")
	var south_solved := Charts.make_state(south, true)
	var south_hit: Dictionary = Tracer.trace(south, south_solved)
	check(south_hit["docks"]["Rd"].has("red") and south_hit["docks"]["Bd"].has("blue") and south_hit["docks"]["Rs"].has("red"), "chart 45 lands the lamp and the south face")
	check(not bool(south_hit["boats"]["Hu"]) and not bool(south_hit["boats"]["Ha"]) and not bool(south_hit["boats"]["Hb"]), "chart 45 solution leaves every hull dark")
	var south_lamp := Charts.duplicate_state(south_solved)
	south_lamp["pieces"]["P"]["socket"] = "lamp"
	var south_lamp_hit: Dictionary = Tracer.trace(south, south_lamp)
	check(south_lamp_hit["docks"]["Rd"].is_empty() and bool(south_lamp_hit["boats"]["Hb"]), "chart 45 lamp socket swallows red and lets white wake the lower hull")
	var south_up := Charts.duplicate_state(south_solved)
	south_up["pieces"]["S"]["rot"] = 0
	check(bool(Tracer.trace(south, south_up)["boats"]["Ha"]) and Tracer.trace(south, south_up)["docks"]["Rd"].has("red"), "chart 45 south mirror turned north wakes the hull and leaves the lamp")
	var south_pane := Charts.duplicate_state(south_solved)
	south_pane["pieces"]["Cb"]["rot"] = 0
	check(not Tracer.trace(south, south_pane)["docks"]["Bd"].has("blue") and Tracer.trace(south, south_pane)["docks"]["Rs"].has("red"), "chart 45 red pane on the blue exit stops blue")

	var mark: Dictionary = meet[7]
	var mark_start := Charts.make_state(mark, false)
	check(str(mark_start["pieces"]["P"]["socket"]) == "lamp", "chart 46 prism starts on the red lamp")
	check(bool(Tracer.trace(mark, mark_start)["boats"]["Hb"]) and bool(Tracer.trace(mark, mark_start)["boats"]["Hs"]), "chart 46 start wakes the lower hull and the south hull")
	var mark_solved := Charts.make_state(mark, true)
	check(int(mark_solved["tide_index"]) == 1, "chart 46 is authored at mid water")
	var mark_hit: Dictionary = Tracer.trace(mark, mark_solved)
	check(mark_hit["docks"]["Rd"].has("red") and mark_hit["docks"]["Bd"].has("blue") and mark_hit["docks"]["Bs"].has("blue") and mark_hit["docks"]["Rs"].has("red"), "chart 46 mid water holds the lamp, the south face, and the blue climb")
	check(not bool(mark_hit["boats"]["Hu"]) and not bool(mark_hit["boats"]["Ha"]) and not bool(mark_hit["boats"]["Hs"]) and not bool(mark_hit["boats"]["Hw"]) and not bool(mark_hit["boats"]["He"]) and not bool(mark_hit["boats"]["Hb"]), "chart 46 solution leaves every hull dark")
	var mark_low := Charts.duplicate_state(mark_solved)
	mark_low["tide_index"] = 0
	check(bool(Tracer.trace(mark, mark_low)["boats"]["Hb"]), "chart 46 low water lights the lower hull")
	check(not Tracer.is_cleared(mark, mark_low), "chart 46 low water does not clear")
	var mark_high := Charts.duplicate_state(mark_solved)
	mark_high["tide_index"] = 2
	var mark_high_hit: Dictionary = Tracer.trace(mark, mark_high)
	check(mark_high_hit["docks"]["Rd"].has("red") and mark_high_hit["docks"]["Bs"].has("blue") and mark_high_hit["docks"]["Rs"].has("red") and not mark_high_hit["docks"]["Bd"].has("blue"), "chart 46 high water keeps the lamp and the south face and loses blue")
	var mark_lamp := Charts.duplicate_state(mark_solved)
	mark_lamp["pieces"]["P"]["socket"] = "lamp"
	var mark_lamp_hit: Dictionary = Tracer.trace(mark, mark_lamp)
	check(not mark_lamp_hit["docks"]["Rd"].has("red") and bool(mark_lamp_hit["boats"]["Hw"]) and mark_lamp_hit["docks"]["Bs"].has("blue"), "chart 46 lamp socket swallows red, wakes the west hull, and leaves the south face")
	var mark_south := Charts.duplicate_state(mark_solved)
	mark_south["pieces"]["Ms"]["rot"] = 0
	check(bool(Tracer.trace(mark, mark_south)["boats"]["Hs"]) and Tracer.trace(mark, mark_south)["docks"]["Bd"].has("blue"), "chart 46 south mirror turned north wakes the hull and leaves the west climb")
	var mark_east := Charts.duplicate_state(mark_solved)
	mark_east["pieces"]["A"]["rot"] = 0
	check(bool(Tracer.trace(mark, mark_east)["boats"]["Ha"]), "chart 46 east mirror turned north wakes the hull")
	var mark_fold := Charts.duplicate_state(mark_solved)
	mark_fold["pieces"]["B"]["rot"] = 90
	check(bool(Tracer.trace(mark, mark_fold)["boats"]["He"]), "chart 46 west mirror turned east wakes the hull")
	var mark_pane := Charts.duplicate_state(mark_solved)
	mark_pane["pieces"]["Cb"]["rot"] = 0
	check(not Tracer.trace(mark, mark_pane)["docks"]["Bd"].has("blue") and Tracer.trace(mark, mark_pane)["docks"]["Rs"].has("red"), "chart 46 red pane on the blue climb stops blue")
	for raw_mark in _clears(mark):
		var mark_clear: Dictionary = raw_mark
		check(int(mark_clear["tide_index"]) == 1, "every chart 46 clear is mid water")



func test_tide_mirror_rule() -> void:
	var dry := _blank(5, 3)
	dry["lanterns"] = [_lamp("L", 0, 1, "E", "red")]
	dry["docks"] = [_need("D", 4, 1, "red")]
	dry["pieces"] = [_fixed_tide("T", 2, 1, 0)]
	var dry_state := Charts.make_state(dry, true)
	var dry_hit: Dictionary = Tracer.trace(dry, dry_state)
	check(dry_hit["docks"]["D"].has("red") and dry_hit["docks"]["D"].size() == 1, "dry tide mirror passes red straight through")
	check(_segments_are(dry_hit, "red"), "dry pass keeps the red color")
	dry["pieces"][0]["solution_rot"] = 90
	var turned: Dictionary = Tracer.trace(dry, Charts.make_state(dry, true))
	check(turned["docks"]["D"].has("red") and turned["docks"]["D"].size() == 1, "dry tide mirror ignores its facing")
	dry["lanterns"][0]["color"] = "white"
	dry["docks"][0]["color"] = "white"
	dry["pieces"][0]["solution_rot"] = 0
	var whole: Dictionary = Tracer.trace(dry, Charts.make_state(dry, true))
	check(whole["docks"]["D"].has("white") and whole["docks"]["D"].size() == 1, "dry tide mirror leaves white whole")
	check(_segments_are(whole, "white"), "dry pass does not tint white")

	var wet := _blank(4, 4)
	wet["tide_phases"] = [0, 2]
	wet["solution_tide_index"] = 1
	wet["lanterns"] = [_lamp("L", 1, 0, "S", "red")]
	wet["docks"] = [_need("Sd", 1, 3, "red"), _need("Nd", 2, 1, "red")]
	wet["pieces"] = [_fixed_tide("T", 1, 2, 90), _fixed_tide("U", 2, 2, 0)]
	var wet_state := Charts.make_state(wet, true)
	var wet_hit: Dictionary = Tracer.trace(wet, wet_state)
	check(wet_hit["docks"]["Nd"].has("red") and wet_hit["docks"]["Nd"].size() == 1, "flooded tide mirror reflects red and keeps the color")
	check(wet_hit["docks"]["Sd"].is_empty(), "flooded tide mirror does not pass the beam straight through")
	check(_segments_are(wet_hit, "red"), "flooded reflection stays red")
	var open := Charts.duplicate_state(wet_state)
	open["tide_index"] = 0
	var open_hit: Dictionary = Tracer.trace(wet, open)
	check(open_hit["docks"]["Sd"].has("red") and open_hit["docks"]["Nd"].is_empty(), "the same glass passes south while its row is dry")
	var aside := Charts.duplicate_state(wet_state)
	aside["pieces"]["T"]["rot"] = 0
	check(not Tracer.trace(wet, aside)["docks"]["Nd"].has("red"), "the other flooded facing misses the north dock")

	var shut := _blank(4, 4)
	shut["tide_phases"] = [0, 2]
	shut["solution_tide_index"] = 1
	shut["lanterns"] = [_lamp("L", 1, 0, "S", "white")]
	shut["docks"] = [_need("E", 2, 2, "white"), _need("S", 1, 3, "white")]
	shut["pieces"] = [_fixed_mirror(1, 2, 90)]
	var shut_dry := Charts.make_state(shut, true)
	shut_dry["tide_index"] = 0
	var shut_dry_hit: Dictionary = Tracer.trace(shut, shut_dry)
	check(shut_dry_hit["docks"]["E"].has("white") and shut_dry_hit["docks"]["S"].is_empty(), "a dry mirror still reflects")
	var shut_wet: Dictionary = Tracer.trace(shut, Charts.make_state(shut, true))
	check(shut_wet["docks"]["E"].is_empty() and shut_wet["docks"]["S"].is_empty(), "a flooded mirror stays shut and does not pass the beam")


func test_tide_book() -> void:
	var tide: Array = Charts.tide()
	check(tide.size() == 8, "tide book has eight charts")
	var titles := ["Wet Glass", "Still Red", "The Wet Bend", "Off the Tide", "The Clear Row", "The West Tide", "The South Tide", "The Tide Mark"]
	for i in tide.size():
		var chart: Dictionary = tide[i]
		check(str(chart["id"]) == str(i + 47), "tide chart %d keeps its number" % (i + 47))
		check(str(chart["title"]) == str(titles[i]), "tide chart %d keeps its title" % (i + 47))
		check(str(chart["harbor"]) == Charts.TIDE, "chart %s belongs to the tide mirror" % str(chart["id"]))
		var phases: Array = chart["tide_phases"]
		check(int(chart["solution_tide_index"]) != int(chart["start_tide_index"]), "chart %s tide starts away from its solution" % str(chart["id"]))
		check(phases.size() > 1, "chart %s has a tide phase to check" % str(chart["id"]))
	check(str(tide[0]["teach"]).to_lower().contains("wrong tide"), "chart 47 warns about the wrong tide")
	check(str(tide[0]["teach"]).to_lower().contains("passes straight through"), "chart 47 teaches the dry pass")
	check(str(tide[1]["teach"]).to_lower().contains("does not change color"), "chart 48 teaches that the color stays")
	var warned := 0
	for raw_warn in tide:
		var warned_chart: Dictionary = raw_warn
		if not str(warned_chart["teach"]).to_lower().contains("wrong tide"):
			continue
		warned += 1
		var warned_solved := Charts.make_state(warned_chart, true)
		var wrong := Charts.duplicate_state(warned_solved)
		wrong["tide_index"] = 0 if int(warned_solved["tide_index"]) != 0 else 1
		check(not Tracer.is_cleared(warned_chart, wrong), "chart %s fails when its tide mirror is used on the wrong tide" % str(warned_chart["id"]))
	check(warned == 2, "two charts warn about the wrong tide")
	for raw_old in Charts.all().slice(0, 46):
		var older: Dictionary = raw_old
		for raw_piece in older["pieces"]:
			var older_piece: Dictionary = raw_piece
			check(str(older_piece["kind"]) != "tide_mirror", "chart %s keeps its pieces" % str(older["id"]))
		for raw_fix in older["fixtures"]:
			var older_fix: Dictionary = raw_fix
			check(str(older_fix["kind"]) != "tide_mirror", "chart %s keeps its fixed glass" % str(older["id"]))
	check(str(Charts.meet()[0]["pieces"][0]["kind"]) == "mirror", "the meeting mirror stays a mirror")

	var glass: Dictionary = tide[0]
	var glass_solved := Charts.make_state(glass, true)
	var glass_hit: Dictionary = Tracer.trace(glass, glass_solved)
	check(glass_hit["docks"]["D"].has("white") and not bool(glass_hit["boats"]["Hb"]) and not bool(glass_hit["boats"]["Hm"]), "chart 47 flooded glass lands on the dock")
	var glass_dry := Charts.duplicate_state(glass_solved)
	glass_dry["tide_index"] = 0
	var glass_dry_hit: Dictionary = Tracer.trace(glass, glass_dry)
	check(bool(glass_dry_hit["boats"]["Hb"]) and not glass_dry_hit["docks"]["D"].has("white"), "chart 47 dry tide passes the lower lamp through to the hull")
	check(not Tracer.is_cleared(glass, glass_dry), "chart 47 wrong tide does not clear")
	var glass_up := Charts.duplicate_state(glass_solved)
	glass_up["pieces"]["M"]["rot"] = 0
	check(bool(Tracer.trace(glass, glass_up)["boats"]["Hm"]), "chart 47 upper mirror turned north wakes the hull")

	var red: Dictionary = tide[1]
	var red_solved := Charts.make_state(red, true)
	var red_hit: Dictionary = Tracer.trace(red, red_solved)
	check(red_hit["docks"]["Rd"].has("red") and red_hit["docks"]["Rd"].size() == 1 and not bool(red_hit["boats"]["Hb"]), "chart 48 keeps red and a dark hull")
	var red_pane := Charts.duplicate_state(red_solved)
	red_pane["pieces"]["C"]["rot"] = 90
	check(not Tracer.trace(red, red_pane)["docks"]["Rd"].has("red"), "chart 48 blue pane stops the red climb")
	var red_dry := Charts.duplicate_state(red_solved)
	red_dry["tide_index"] = 0
	check(bool(Tracer.trace(red, red_dry)["boats"]["Hb"]) and not Tracer.trace(red, red_dry)["docks"]["Rd"].has("red"), "chart 48 dry tide passes through and misses the dock")

	var bend: Dictionary = tide[2]
	var bend_solved := Charts.make_state(bend, true)
	var bend_hit: Dictionary = Tracer.trace(bend, bend_solved)
	check(bend_hit["docks"]["Rd"].has("red") and not bool(bend_hit["boats"]["Hw"]) and not bool(bend_hit["boats"]["Hb"]), "chart 49 bends red onto the dock")
	var bend_west := Charts.duplicate_state(bend_solved)
	bend_west["pieces"]["N"]["rot"] = 90
	check(bool(Tracer.trace(bend, bend_west)["boats"]["Hw"]), "chart 49 upper mirror turned west wakes the hull")
	var bend_dry := Charts.duplicate_state(bend_solved)
	bend_dry["tide_index"] = 0
	check(bool(Tracer.trace(bend, bend_dry)["boats"]["Hb"]) and not Tracer.is_cleared(bend, bend_dry), "chart 49 dry tide wakes the lower hull")

	var off: Dictionary = tide[3]
	var off_start := Charts.make_state(off, false)
	check(str(off_start["pieces"]["P"]["socket"]) == "side", "chart 50 prism starts off the column")
	var off_solved := Charts.make_state(off, true)
	var off_hit: Dictionary = Tracer.trace(off, off_solved)
	check(off_hit["docks"]["Rd"].has("red") and off_hit["docks"]["Bd"].has("blue") and not bool(off_hit["boats"]["Hw"]), "chart 50 splits the climb")
	var off_side := Charts.duplicate_state(off_solved)
	off_side["pieces"]["P"]["socket"] = "side"
	check(bool(Tracer.trace(off, off_side)["boats"]["Hw"]) and not Tracer.trace(off, off_side)["docks"]["Rd"].has("red"), "chart 50 side socket lets white wake the hull")
	var off_face := Charts.duplicate_state(off_solved)
	off_face["pieces"]["P"]["rot"] = 90
	check(not Tracer.trace(off, off_face)["docks"]["Bd"].has("blue") and not Tracer.trace(off, off_face)["docks"]["Rd"].has("red"), "chart 50 east face absorbs the northbound beam")
	var off_feed := Charts.duplicate_state(off_solved)
	off_feed["pieces"]["M"]["rot"] = 0
	check(bool(Tracer.trace(off, off_feed)["boats"]["Hm"]), "chart 50 feed mirror turned north wakes the hull")

	var clear: Dictionary = tide[4]
	var clear_solved := Charts.make_state(clear, true)
	check(int(clear_solved["tide_index"]) == 1, "chart 51 is authored at mid water")
	var clear_hit: Dictionary = Tracer.trace(clear, clear_solved)
	check(clear_hit["docks"]["D"].has("white") and not bool(clear_hit["boats"]["Hb"]), "chart 51 mid water holds the dock and a dark hull")
	var clear_low := Charts.duplicate_state(clear_solved)
	clear_low["tide_index"] = 0
	check(bool(Tracer.trace(clear, clear_low)["boats"]["Hb"]) and not Tracer.is_cleared(clear, clear_low), "chart 51 low water is the wrong tide")
	var clear_high := Charts.duplicate_state(clear_solved)
	clear_high["tide_index"] = 2
	check(not Tracer.trace(clear, clear_high)["docks"]["D"].has("white") and not Tracer.is_cleared(clear, clear_high), "chart 51 high water covers the dock")
	for raw_clear in _clears(clear):
		var clear_state: Dictionary = raw_clear
		check(int(clear_state["tide_index"]) == 1, "every chart 51 clear is mid water")

	var west: Dictionary = tide[5]
	var west_solved := Charts.make_state(west, true)
	var west_hit: Dictionary = Tracer.trace(west, west_solved)
	check(west_hit["docks"]["Bd"].has("blue") and west_hit["docks"]["Rd"].has("red") and not bool(west_hit["boats"]["Ha"]) and not bool(west_hit["boats"]["Hb"]), "chart 52 lands blue north and red south")
	var west_face := Charts.duplicate_state(west_solved)
	west_face["pieces"]["P"]["rot"] = 90
	check(not Tracer.trace(west, west_face)["docks"]["Bd"].has("blue"), "chart 52 east face absorbs the west beam")
	var west_fold := Charts.duplicate_state(west_solved)
	west_fold["pieces"]["A"]["rot"] = 0
	check(bool(Tracer.trace(west, west_fold)["boats"]["Ha"]), "chart 52 west mirror turned east wakes the hull")
	var west_pane := Charts.duplicate_state(west_solved)
	west_pane["pieces"]["Cb"]["rot"] = 0
	check(not Tracer.trace(west, west_pane)["docks"]["Bd"].has("blue") and Tracer.trace(west, west_pane)["docks"]["Rd"].has("red"), "chart 52 red pane on the blue climb stops blue")
	var west_dry := Charts.duplicate_state(west_solved)
	west_dry["tide_index"] = 0
	check(bool(Tracer.trace(west, west_dry)["boats"]["Hb"]) and not Tracer.is_cleared(west, west_dry), "chart 52 dry tide wakes the lower hull")

	var south: Dictionary = tide[6]
	var south_solved := Charts.make_state(south, true)
	var south_hit: Dictionary = Tracer.trace(south, south_solved)
	check(south_hit["docks"]["Bd"].has("blue") and south_hit["docks"]["Rs"].has("red") and not bool(south_hit["boats"]["He"]) and not bool(south_hit["boats"]["Hf"]), "chart 53 south face lands both colors")
	var south_face := Charts.duplicate_state(south_solved)
	south_face["pieces"]["P"]["rot"] = 90
	check(not Tracer.trace(south, south_face)["docks"]["Bd"].has("blue"), "chart 53 east face absorbs the southbound beam")
	var south_east := Charts.duplicate_state(south_solved)
	south_east["pieces"]["E"]["rot"] = 90
	check(bool(Tracer.trace(south, south_east)["boats"]["He"]), "chart 53 east mirror turned west wakes the hull")
	var south_down := Charts.duplicate_state(south_solved)
	south_down["pieces"]["F"]["rot"] = 0
	check(bool(Tracer.trace(south, south_down)["boats"]["Hf"]), "chart 53 south mirror turned north wakes the hull")
	var south_blue := Charts.duplicate_state(south_solved)
	south_blue["pieces"]["Cb"]["rot"] = 0
	check(not Tracer.trace(south, south_blue)["docks"]["Bd"].has("blue") and Tracer.trace(south, south_blue)["docks"]["Rs"].has("red"), "chart 53 red pane on the blue exit stops blue")
	var south_red := Charts.duplicate_state(south_solved)
	south_red["pieces"]["Cr"]["rot"] = 90
	check(not Tracer.trace(south, south_red)["docks"]["Rs"].has("red") and Tracer.trace(south, south_red)["docks"]["Bd"].has("blue"), "chart 53 blue pane on the red exit stops red")

	var mark: Dictionary = tide[7]
	var mark_start := Charts.make_state(mark, false)
	check(str(mark_start["pieces"]["P"]["socket"]) == "lamp", "chart 54 prism starts on the red lamp")
	var mark_solved := Charts.make_state(mark, true)
	check(int(mark_solved["tide_index"]) == 1, "chart 54 is authored at mid water")
	var mark_hit: Dictionary = Tracer.trace(mark, mark_solved)
	check(mark_hit["docks"]["Rl"].has("red") and mark_hit["docks"]["Bd"].has("blue"), "chart 54 mid water holds the lamp and the blue climb")
	check(not bool(mark_hit["boats"]["Hu"]) and not bool(mark_hit["boats"]["Hm"]) and not bool(mark_hit["boats"]["Ha"]) and not bool(mark_hit["boats"]["He"]) and not bool(mark_hit["boats"]["Hb"]), "chart 54 solution leaves every hull dark")
	var mark_low := Charts.duplicate_state(mark_solved)
	mark_low["tide_index"] = 0
	check(bool(Tracer.trace(mark, mark_low)["boats"]["Hb"]) and Tracer.trace(mark, mark_low)["docks"]["Rl"].has("red") and not Tracer.is_cleared(mark, mark_low), "chart 54 low water wakes the lower hull")
	var mark_high := Charts.duplicate_state(mark_solved)
	mark_high["tide_index"] = 2
	var mark_high_hit: Dictionary = Tracer.trace(mark, mark_high)
	check(mark_high_hit["docks"]["Rl"].has("red") and not mark_high_hit["docks"]["Bd"].has("blue"), "chart 54 high water keeps the lamp and loses blue")
	var mark_lamp := Charts.duplicate_state(mark_solved)
	mark_lamp["pieces"]["P"]["socket"] = "lamp"
	var mark_lamp_hit: Dictionary = Tracer.trace(mark, mark_lamp)
	check(not mark_lamp_hit["docks"]["Rl"].has("red") and not mark_lamp_hit["docks"]["Bd"].has("blue"), "chart 54 lamp socket swallows red and misses the split")
	var mark_feed := Charts.duplicate_state(mark_solved)
	mark_feed["pieces"]["Mr"]["rot"] = 90
	check(bool(Tracer.trace(mark, mark_feed)["boats"]["Hm"]) and Tracer.trace(mark, mark_feed)["docks"]["Bd"].has("blue"), "chart 54 lamp mirror turned south wakes the hull")
	var mark_upper := Charts.duplicate_state(mark_solved)
	mark_upper["pieces"]["Mu"]["rot"] = 90
	check(bool(Tracer.trace(mark, mark_upper)["boats"]["Hu"]), "chart 54 upper mirror turned west wakes the hull")
	var mark_white := Charts.duplicate_state(mark_solved)
	mark_white["pieces"]["M"]["rot"] = 0
	check(bool(Tracer.trace(mark, mark_white)["boats"]["Hm"]) and Tracer.trace(mark, mark_white)["docks"]["Rl"].has("red"), "chart 54 feed mirror turned north wakes the hull and leaves the lamp")
	var mark_south := Charts.duplicate_state(mark_solved)
	mark_south["pieces"]["C"]["rot"] = 0
	check(bool(Tracer.trace(mark, mark_south)["boats"]["Ha"]), "chart 54 south mirror turned north wakes the hull")
	var mark_fold := Charts.duplicate_state(mark_solved)
	mark_fold["pieces"]["D"]["rot"] = 90
	check(bool(Tracer.trace(mark, mark_fold)["boats"]["He"]), "chart 54 west mirror turned east wakes the hull")
	var mark_blue := Charts.duplicate_state(mark_solved)
	mark_blue["pieces"]["Cb"]["rot"] = 0
	check(not Tracer.trace(mark, mark_blue)["docks"]["Bd"].has("blue") and Tracer.trace(mark, mark_blue)["docks"]["Rl"].has("red"), "chart 54 red pane on the blue climb stops blue")
	for raw_mark in _clears(mark):
		var mark_clear: Dictionary = raw_mark
		check(int(mark_clear["tide_index"]) == 1, "every chart 54 clear is mid water")


func test_shutter_rule() -> void:
	check(Tracer.norm_rot("shutter", 90) == 0 and Tracer.norm_rot("shutter", 270) == 0, "a shutter has no facing")
	check(Tracer.turn_rot("shutter", 0) == 0 and Tracer.turn_rot("shutter", 90) == 0, "a shutter does not turn")

	var dry := _blank(5, 3)
	dry["lanterns"] = [_lamp("L", 0, 1, "E", "red")]
	dry["docks"] = [_need("D", 4, 1, "red")]
	dry["pieces"] = [_fixed_shutter("G", 2, 1)]
	var dry_hit: Dictionary = Tracer.trace(dry, Charts.make_state(dry, true))
	check(dry_hit["docks"]["D"].is_empty(), "a dry shutter stops the beam")
	check(_center_hit(dry_hit, 2, 1) and not _center_hit(dry_hit, 3, 1), "a dry shutter does not let the beam continue")
	dry["pieces"][0]["solution_rot"] = 90
	var dry_turned: Dictionary = Tracer.trace(dry, Charts.make_state(dry, true))
	check(dry_turned["docks"]["D"].is_empty(), "a dry shutter ignores its facing")

	var wet := _blank(4, 4)
	wet["tide_phases"] = [0, 2]
	wet["solution_tide_index"] = 1
	wet["lanterns"] = [_lamp("L", 1, 0, "S", "red")]
	wet["docks"] = [_need("D", 2, 1, "red")]
	wet["pieces"] = [
		_fixed_shutter("G", 1, 2),
		_fixed_shutter("U", 2, 2),
		_fixed_tide("T", 1, 3, 90),
		_fixed_tide("B", 2, 3, 0),
	]
	var wet_state := Charts.make_state(wet, true)
	var wet_hit: Dictionary = Tracer.trace(wet, wet_state)
	check(wet_hit["docks"]["D"].has("red") and wet_hit["docks"]["D"].size() == 1, "a flooded shutter passes red straight through")
	check(_segments_are(wet_hit, "red"), "a flooded shutter keeps the red color")
	check(_center_hit(wet_hit, 1, 3) and not _center_hit(wet_hit, 0, 2), "a flooded shutter does not reflect")
	var spun := Charts.duplicate_state(wet_state)
	spun["pieces"]["G"]["rot"] = 90
	spun["pieces"]["U"]["rot"] = 90
	var spun_hit: Dictionary = Tracer.trace(wet, spun)
	check(spun_hit["docks"]["D"].has("red") and spun_hit["docks"]["D"].size() == 1, "a flooded shutter ignores its facing")
	var open := Charts.duplicate_state(wet_state)
	open["tide_index"] = 0
	check(Tracer.trace(wet, open)["docks"]["D"].is_empty(), "the same shutter stops the beam while its row is dry")

	wet["lanterns"][0]["color"] = "white"
	wet["docks"][0]["color"] = "white"
	var whole: Dictionary = Tracer.trace(wet, Charts.make_state(wet, true))
	check(whole["docks"]["D"].has("white") and whole["docks"]["D"].size() == 1, "a flooded shutter leaves white whole")
	check(_segments_are(whole, "white"), "a flooded pass does not tint white")

	var blocked := _blank(4, 4)
	blocked["tide_phases"] = [0, 2]
	blocked["solution_tide_index"] = 1
	blocked["lanterns"] = [_lamp("L", 1, 0, "S", "red")]
	blocked["docks"] = [_need("D", 2, 1, "red")]
	blocked["pieces"] = [
		_fixed_shutter("U", 2, 2),
		_fixed_tide("T", 1, 3, 90),
		_fixed_tide("B", 2, 3, 0),
	]
	check(Tracer.trace(blocked, Charts.make_state(blocked, true))["docks"]["D"].is_empty(), "an empty flooded cell still stops the beam")

	var onward := _blank(3, 4)
	onward["tide_phases"] = [2]
	onward["solution_tide_index"] = 0
	onward["lanterns"] = [_lamp("L", 1, 0, "S", "white")]
	onward["pieces"] = [_fixed_shutter("G", 1, 2)]
	var onward_hit: Dictionary = Tracer.trace(onward, Charts.make_state(onward, true))
	check(_center_hit(onward_hit, 1, 2) and not _center_hit(onward_hit, 1, 3), "the next flooded cell after a shutter still stops the beam")

	var stood_in := _blank(4, 4)
	stood_in["tide_phases"] = [2]
	stood_in["solution_tide_index"] = 0
	stood_in["lanterns"] = [_lamp("L", 1, 0, "S", "red")]
	stood_in["docks"] = [_need("D", 2, 1, "red")]
	stood_in["pieces"] = [
		_fixed_tide("G", 1, 2, 0),
		_fixed_shutter("U", 2, 2),
		_fixed_tide("T", 1, 3, 90),
		_fixed_tide("B", 2, 3, 0),
	]
	check(Tracer.trace(stood_in, Charts.make_state(stood_in, true))["docks"]["D"].is_empty(), "a flooded tide mirror still reflects instead of passing straight")


func test_shutter_book() -> void:
	var book: Array = Charts.shutter()
	check(book.size() == 8, "shutter book has eight charts")
	var titles := ["The Dry Gate", "Straight Red", "The Open Bend", "Off the Gate", "The Held Gate", "The West Gate", "The South Gate", "The Shutter Mark"]
	for i in book.size():
		var chart: Dictionary = book[i]
		check(str(chart["id"]) == str(i + 55), "shutter chart %d keeps its number" % (i + 55))
		check(str(chart["title"]) == str(titles[i]), "shutter chart %d keeps its title" % (i + 55))
		check(str(chart["harbor"]) == Charts.SHUTTER, "chart %s belongs to the shutter" % str(chart["id"]))
		var phases: Array = chart["tide_phases"]
		check(int(chart["solution_tide_index"]) != int(chart["start_tide_index"]), "chart %s tide starts away from its solution" % str(chart["id"]))
		check(phases.size() > 1, "chart %s has a tide phase to check" % str(chart["id"]))
		var shutter_count := 0
		for raw_piece in chart["pieces"]:
			var piece: Dictionary = raw_piece
			if str(piece["kind"]) == "shutter":
				shutter_count += 1
		check(shutter_count > 0, "chart %s uses a shutter" % str(chart["id"]))
	check(str(book[0]["teach"]).to_lower().contains("wrong tide"), "chart 55 warns about the wrong tide")
	check(str(book[0]["teach"]).to_lower().contains("passes straight through"), "chart 55 teaches the flooded pass")
	check(str(book[0]["teach"]).to_lower().contains("does not reflect"), "chart 55 teaches that a shutter does not reflect")
	check(str(book[1]["teach"]).to_lower().contains("does not change color"), "chart 56 teaches that the color stays")
	check(str(book[1]["teach"]).to_lower().contains("does not reflect"), "chart 56 teaches that a shutter does not reflect")
	var warned := 0
	for raw_warn in book:
		var warned_chart: Dictionary = raw_warn
		if not str(warned_chart["teach"]).to_lower().contains("wrong tide"):
			continue
		warned += 1
		var warned_solved := Charts.make_state(warned_chart, true)
		var wrong := Charts.duplicate_state(warned_solved)
		wrong["tide_index"] = 0 if int(warned_solved["tide_index"]) != 0 else 1
		check(not Tracer.is_cleared(warned_chart, wrong), "chart %s fails when its shutter is used on the wrong tide" % str(warned_chart["id"]))
	check(warned == 2, "two shutter charts warn about the wrong tide")
	for raw_old in Charts.all().slice(0, 54):
		var older: Dictionary = raw_old
		for raw_piece in older["pieces"]:
			var older_piece: Dictionary = raw_piece
			check(str(older_piece["kind"]) != "shutter", "chart %s keeps its pieces" % str(older["id"]))
		for raw_fix in older["fixtures"]:
			var older_fix: Dictionary = raw_fix
			check(str(older_fix["kind"]) != "shutter", "chart %s keeps its fixed glass" % str(older["id"]))
	for raw_tide in Charts.tide():
		var tide_chart: Dictionary = raw_tide
		var tide_mirrors := 0
		for raw_piece in tide_chart["pieces"]:
			var tide_piece: Dictionary = raw_piece
			check(str(tide_piece["kind"]) != "shutter", "chart %s keeps its tide mirror" % str(tide_chart["id"]))
			if str(tide_piece["kind"]) == "tide_mirror":
				tide_mirrors += 1
		check(tide_mirrors > 0, "chart %s still uses a tide mirror" % str(tide_chart["id"]))

	var gate: Dictionary = book[0]
	var gate_solved := Charts.make_state(gate, true)
	var gate_hit: Dictionary = Tracer.trace(gate, gate_solved)
	check(gate_hit["docks"]["D"].has("white") and not bool(gate_hit["boats"]["Hb"]) and not bool(gate_hit["boats"]["Hm"]), "chart 55 flooded shutter lets the beam climb")
	var gate_dry := Charts.duplicate_state(gate_solved)
	gate_dry["tide_index"] = 0
	var gate_dry_hit: Dictionary = Tracer.trace(gate, gate_dry)
	check(bool(gate_dry_hit["boats"]["Hb"]) and not gate_dry_hit["docks"]["D"].has("white"), "chart 55 dry shutter stops the beam and the lower lamp wakes the hull")
	check(not Tracer.is_cleared(gate, gate_dry), "chart 55 wrong tide does not clear")
	var gate_up := Charts.duplicate_state(gate_solved)
	gate_up["pieces"]["M"]["rot"] = 0
	check(bool(Tracer.trace(gate, gate_up)["boats"]["Hm"]), "chart 55 feed mirror turned north wakes the hull")

	var red: Dictionary = book[1]
	var red_solved := Charts.make_state(red, true)
	var red_hit: Dictionary = Tracer.trace(red, red_solved)
	check(red_hit["docks"]["Rd"].has("red") and red_hit["docks"]["Rd"].size() == 1 and not bool(red_hit["boats"]["Hb"]), "chart 56 keeps red and a dark hull")
	var red_pane := Charts.duplicate_state(red_solved)
	red_pane["pieces"]["C"]["rot"] = 90
	check(not Tracer.trace(red, red_pane)["docks"]["Rd"].has("red"), "chart 56 blue pane stops the red climb")
	var red_dry := Charts.duplicate_state(red_solved)
	red_dry["tide_index"] = 0
	check(bool(Tracer.trace(red, red_dry)["boats"]["Hb"]) and not Tracer.trace(red, red_dry)["docks"]["Rd"].has("red"), "chart 56 dry shutter stops the beam and the lower lamp wakes the hull")
	var red_up := Charts.duplicate_state(red_solved)
	red_up["pieces"]["M"]["rot"] = 0
	check(bool(Tracer.trace(red, red_up)["boats"]["Hm"]), "chart 56 feed mirror turned north wakes the hull")

	var bend: Dictionary = book[2]
	var bend_solved := Charts.make_state(bend, true)
	var bend_hit: Dictionary = Tracer.trace(bend, bend_solved)
	check(bend_hit["docks"]["Rd"].has("red") and not bool(bend_hit["boats"]["Hw"]) and not bool(bend_hit["boats"]["Hb"]) and not bool(bend_hit["boats"]["Hm"]), "chart 57 bends red onto the dock")
	var bend_west := Charts.duplicate_state(bend_solved)
	bend_west["pieces"]["N"]["rot"] = 90
	check(bool(Tracer.trace(bend, bend_west)["boats"]["Hw"]), "chart 57 upper mirror turned west wakes the hull")
	var bend_pane := Charts.duplicate_state(bend_solved)
	bend_pane["pieces"]["C"]["rot"] = 90
	check(not Tracer.trace(bend, bend_pane)["docks"]["Rd"].has("red"), "chart 57 blue pane stops the red bend")
	var bend_dry := Charts.duplicate_state(bend_solved)
	bend_dry["tide_index"] = 0
	check(bool(Tracer.trace(bend, bend_dry)["boats"]["Hb"]) and not Tracer.is_cleared(bend, bend_dry), "chart 57 dry shutter wakes the lower hull")

	var off: Dictionary = book[3]
	var off_start := Charts.make_state(off, false)
	check(str(off_start["pieces"]["P"]["socket"]) == "side", "chart 58 prism starts off the climb")
	var off_solved := Charts.make_state(off, true)
	var off_hit: Dictionary = Tracer.trace(off, off_solved)
	check(off_hit["docks"]["Rd"].has("red") and off_hit["docks"]["Bd"].has("blue") and not bool(off_hit["boats"]["Hw"]) and not bool(off_hit["boats"]["Hm"]), "chart 58 splits the climb")
	var off_side := Charts.duplicate_state(off_solved)
	off_side["pieces"]["P"]["socket"] = "side"
	check(bool(Tracer.trace(off, off_side)["boats"]["Hw"]) and not Tracer.trace(off, off_side)["docks"]["Rd"].has("red"), "chart 58 side socket lets white wake the hull")
	var off_face := Charts.duplicate_state(off_solved)
	off_face["pieces"]["P"]["rot"] = 90
	check(not Tracer.trace(off, off_face)["docks"]["Bd"].has("blue") and not Tracer.trace(off, off_face)["docks"]["Rd"].has("red"), "chart 58 east face absorbs the northbound beam")
	var off_feed := Charts.duplicate_state(off_solved)
	off_feed["pieces"]["M"]["rot"] = 0
	check(bool(Tracer.trace(off, off_feed)["boats"]["Hm"]), "chart 58 feed mirror turned north wakes the hull")
	var off_dry := Charts.duplicate_state(off_solved)
	off_dry["tide_index"] = 0
	check(bool(Tracer.trace(off, off_dry)["boats"]["Hb"]) and not Tracer.is_cleared(off, off_dry), "chart 58 dry shutter wakes the lower hull")

	var held: Dictionary = book[4]
	var held_solved := Charts.make_state(held, true)
	check(int(held_solved["tide_index"]) == 1, "chart 59 is authored at mid water")
	var held_hit: Dictionary = Tracer.trace(held, held_solved)
	check(held_hit["docks"]["D"].has("white") and not bool(held_hit["boats"]["Hb"]) and not bool(held_hit["boats"]["Hm"]), "chart 59 mid water holds the dock and a dark hull")
	var held_low := Charts.duplicate_state(held_solved)
	held_low["tide_index"] = 0
	check(bool(Tracer.trace(held, held_low)["boats"]["Hb"]) and not Tracer.is_cleared(held, held_low), "chart 59 low water is the wrong tide")
	var held_high := Charts.duplicate_state(held_solved)
	held_high["tide_index"] = 2
	check(not Tracer.trace(held, held_high)["docks"]["D"].has("white") and not Tracer.is_cleared(held, held_high), "chart 59 high water covers the dock")
	var held_up := Charts.duplicate_state(held_solved)
	held_up["pieces"]["M"]["rot"] = 0
	check(bool(Tracer.trace(held, held_up)["boats"]["Hm"]), "chart 59 feed mirror turned north wakes the hull")
	for raw_held in _clears(held):
		var held_state: Dictionary = raw_held
		check(int(held_state["tide_index"]) == 1, "every chart 59 clear is mid water")

	var west: Dictionary = book[5]
	var west_solved := Charts.make_state(west, true)
	var west_hit: Dictionary = Tracer.trace(west, west_solved)
	check(west_hit["docks"]["Bd"].has("blue") and west_hit["docks"]["Rd"].has("red") and not bool(west_hit["boats"]["Ha"]) and not bool(west_hit["boats"]["Hb"]) and not bool(west_hit["boats"]["Hm"]), "chart 60 lands blue north and red south")
	var west_face := Charts.duplicate_state(west_solved)
	west_face["pieces"]["P"]["rot"] = 90
	check(not Tracer.trace(west, west_face)["docks"]["Bd"].has("blue"), "chart 60 east face absorbs the west beam")
	var west_fold := Charts.duplicate_state(west_solved)
	west_fold["pieces"]["A"]["rot"] = 0
	check(bool(Tracer.trace(west, west_fold)["boats"]["Ha"]), "chart 60 west mirror turned east wakes the hull")
	var west_pane := Charts.duplicate_state(west_solved)
	west_pane["pieces"]["Cb"]["rot"] = 0
	check(not Tracer.trace(west, west_pane)["docks"]["Bd"].has("blue") and Tracer.trace(west, west_pane)["docks"]["Rd"].has("red"), "chart 60 red pane on the blue climb stops blue")
	var west_feed := Charts.duplicate_state(west_solved)
	west_feed["pieces"]["M"]["rot"] = 0
	check(bool(Tracer.trace(west, west_feed)["boats"]["Hm"]), "chart 60 feed mirror turned north wakes the hull")
	var west_dry := Charts.duplicate_state(west_solved)
	west_dry["tide_index"] = 0
	check(bool(Tracer.trace(west, west_dry)["boats"]["Hb"]) and not Tracer.is_cleared(west, west_dry), "chart 60 dry shutter wakes the lower hull")

	var south: Dictionary = book[6]
	var south_solved := Charts.make_state(south, true)
	var south_hit: Dictionary = Tracer.trace(south, south_solved)
	check(south_hit["docks"]["Bd"].has("blue") and south_hit["docks"]["Rs"].has("red") and not bool(south_hit["boats"]["He"]) and not bool(south_hit["boats"]["Hf"]) and not bool(south_hit["boats"]["Hb"]) and not bool(south_hit["boats"]["Hm"]), "chart 61 south face lands both colors")
	var south_face := Charts.duplicate_state(south_solved)
	south_face["pieces"]["P"]["rot"] = 90
	check(not Tracer.trace(south, south_face)["docks"]["Bd"].has("blue"), "chart 61 east face absorbs the southbound beam")
	var south_east := Charts.duplicate_state(south_solved)
	south_east["pieces"]["E"]["rot"] = 90
	check(bool(Tracer.trace(south, south_east)["boats"]["He"]), "chart 61 east mirror turned west wakes the hull")
	var south_down := Charts.duplicate_state(south_solved)
	south_down["pieces"]["F"]["rot"] = 0
	check(bool(Tracer.trace(south, south_down)["boats"]["Hf"]), "chart 61 south mirror turned north wakes the hull")
	var south_blue := Charts.duplicate_state(south_solved)
	south_blue["pieces"]["Cb"]["rot"] = 0
	check(not Tracer.trace(south, south_blue)["docks"]["Bd"].has("blue") and Tracer.trace(south, south_blue)["docks"]["Rs"].has("red"), "chart 61 red pane on the blue exit stops blue")
	var south_red := Charts.duplicate_state(south_solved)
	south_red["pieces"]["Cr"]["rot"] = 90
	check(not Tracer.trace(south, south_red)["docks"]["Rs"].has("red") and Tracer.trace(south, south_red)["docks"]["Bd"].has("blue"), "chart 61 blue pane on the red exit stops red")
	var south_dry := Charts.duplicate_state(south_solved)
	south_dry["tide_index"] = 0
	check(bool(Tracer.trace(south, south_dry)["boats"]["Hb"]) and not Tracer.is_cleared(south, south_dry), "chart 61 dry shutter wakes the lower hull")

	var mark: Dictionary = book[7]
	var mark_start := Charts.make_state(mark, false)
	check(str(mark_start["pieces"]["P"]["socket"]) == "lamp", "chart 62 prism starts on the red lamp")
	var mark_solved := Charts.make_state(mark, true)
	check(int(mark_solved["tide_index"]) == 1, "chart 62 is authored at mid water")
	var mark_hit: Dictionary = Tracer.trace(mark, mark_solved)
	check(mark_hit["docks"]["Rl"].has("red") and mark_hit["docks"]["Bd"].has("blue"), "chart 62 mid water holds the lamp and the blue climb")
	check(not bool(mark_hit["boats"]["Hu"]) and not bool(mark_hit["boats"]["Hm"]) and not bool(mark_hit["boats"]["Hw"]) and not bool(mark_hit["boats"]["Ha"]) and not bool(mark_hit["boats"]["He"]) and not bool(mark_hit["boats"]["Hb"]), "chart 62 solution leaves every hull dark")
	var mark_low := Charts.duplicate_state(mark_solved)
	mark_low["tide_index"] = 0
	check(bool(Tracer.trace(mark, mark_low)["boats"]["Hb"]) and Tracer.trace(mark, mark_low)["docks"]["Rl"].has("red") and not Tracer.is_cleared(mark, mark_low), "chart 62 low water stops on the dry shutter and wakes the lower hull")
	var mark_high := Charts.duplicate_state(mark_solved)
	mark_high["tide_index"] = 2
	var mark_high_hit: Dictionary = Tracer.trace(mark, mark_high)
	check(mark_high_hit["docks"]["Rl"].has("red") and not mark_high_hit["docks"]["Bd"].has("blue"), "chart 62 high water keeps the lamp and loses blue")
	var mark_lamp := Charts.duplicate_state(mark_solved)
	mark_lamp["pieces"]["P"]["socket"] = "lamp"
	var mark_lamp_hit: Dictionary = Tracer.trace(mark, mark_lamp)
	check(not mark_lamp_hit["docks"]["Rl"].has("red") and not mark_lamp_hit["docks"]["Bd"].has("blue"), "chart 62 lamp socket swallows red and misses the split")
	var mark_feed := Charts.duplicate_state(mark_solved)
	mark_feed["pieces"]["Mr"]["rot"] = 90
	check(bool(Tracer.trace(mark, mark_feed)["boats"]["Hm"]) and Tracer.trace(mark, mark_feed)["docks"]["Bd"].has("blue"), "chart 62 lamp mirror turned south wakes the hull")
	var mark_upper := Charts.duplicate_state(mark_solved)
	mark_upper["pieces"]["Mu"]["rot"] = 90
	check(bool(Tracer.trace(mark, mark_upper)["boats"]["Hu"]), "chart 62 upper mirror turned west wakes the hull")
	var mark_white := Charts.duplicate_state(mark_solved)
	mark_white["pieces"]["M"]["rot"] = 0
	check(bool(Tracer.trace(mark, mark_white)["boats"]["Hw"]) and Tracer.trace(mark, mark_white)["docks"]["Rl"].has("red"), "chart 62 feed mirror turned north wakes the hull and leaves the lamp")
	var mark_east := Charts.duplicate_state(mark_solved)
	mark_east["pieces"]["H"]["rot"] = 90
	check(bool(Tracer.trace(mark, mark_east)["boats"]["Hw"]), "chart 62 east mirror turned west wakes the hull")
	var mark_south := Charts.duplicate_state(mark_solved)
	mark_south["pieces"]["F"]["rot"] = 0
	check(bool(Tracer.trace(mark, mark_south)["boats"]["Ha"]), "chart 62 south mirror turned north wakes the hull")
	var mark_fold := Charts.duplicate_state(mark_solved)
	mark_fold["pieces"]["D"]["rot"] = 90
	check(bool(Tracer.trace(mark, mark_fold)["boats"]["He"]), "chart 62 west mirror turned east wakes the hull")
	var mark_blue := Charts.duplicate_state(mark_solved)
	mark_blue["pieces"]["Cb"]["rot"] = 0
	check(not Tracer.trace(mark, mark_blue)["docks"]["Bd"].has("blue") and Tracer.trace(mark, mark_blue)["docks"]["Rl"].has("red"), "chart 62 red pane on the blue climb stops blue")
	for raw_mark in _clears(mark):
		var mark_clear: Dictionary = raw_mark
		check(int(mark_clear["tide_index"]) == 1, "every chart 62 clear is mid water")


func test_stain_rule() -> void:
	check(Tracer.stain_color(0) == "red" and Tracer.stain_color(180) == "red", "stain 0 is red")
	check(Tracer.stain_color(90) == "blue" and Tracer.stain_color(270) == "blue", "stain 90 is blue")
	check(Tracer.norm_rot("stain", 180) == 0 and Tracer.norm_rot("stain", 270) == 90, "a stain has no facing")
	check(Tracer.turn_rot("stain", 0) == 90 and Tracer.turn_rot("stain", 90) == 0, "clicking a stain swaps its color")
	check(Tracer.turn_rot("stain", 180) == 90 and Tracer.turn_rot("stain", 270) == 0, "a stain click does not walk through a facing")
	check(Tracer.turn_rot("stain", Tracer.turn_rot("stain", 0)) == 0, "two clicks restore the stain color")

	var red := _blank(6, 3)
	red["lanterns"] = [_lamp("L", 0, 1, "E", "white")]
	red["docks"] = [_need("D", 5, 1, "red")]
	red["pieces"] = [_fixed_stain("K", 2, 1, 0)]
	var red_hit: Dictionary = Tracer.trace(red, Charts.make_state(red, true))
	check(red_hit["docks"]["D"].has("red") and red_hit["docks"]["D"].size() == 1, "a white beam leaves a red stain as red")
	check(_same_row(red_hit, 1), "a red stain keeps the beam on a straight row")
	check(_arrives(red_hit, 2, 1, "white") and _departs(red_hit, 2, 1, "red"), "the beam is white into a red stain and red after it")
	check(not _center_hit(red_hit, 2, 0) and not _center_hit(red_hit, 2, 2), "a red stain does not reflect")
	red["pieces"][0]["solution_rot"] = 180
	var spun: Dictionary = Tracer.trace(red, Charts.make_state(red, true))
	check(spun["docks"]["D"].has("red") and spun["docks"]["D"].size() == 1, "stain 180 matches red")

	var blue := _blank(6, 3)
	blue["lanterns"] = [_lamp("L", 0, 1, "E", "white")]
	blue["docks"] = [_need("D", 5, 1, "blue")]
	blue["pieces"] = [_fixed_stain("K", 2, 1, 90)]
	var blue_hit: Dictionary = Tracer.trace(blue, Charts.make_state(blue, true))
	check(blue_hit["docks"]["D"].has("blue") and blue_hit["docks"]["D"].size() == 1, "a white beam leaves a blue stain as blue")
	check(_same_row(blue_hit, 1) and _departs(blue_hit, 2, 1, "blue"), "a blue stain keeps the beam straight and blue")
	check(not _center_hit(blue_hit, 2, 0) and not _center_hit(blue_hit, 2, 2), "a blue stain does not reflect")

	var dyed := _blank(6, 1)
	dyed["lanterns"] = [_lamp("L", 0, 0, "E", "blue")]
	dyed["docks"] = [_need("D", 5, 0, "red")]
	dyed["pieces"] = [_fixed_stain("K", 2, 0, 0)]
	var dyed_hit: Dictionary = Tracer.trace(dyed, Charts.make_state(dyed, true))
	check(dyed_hit["docks"]["D"].has("red") and dyed_hit["docks"]["D"].size() == 1, "a dry stain turns blue into red")
	check(_departs(dyed_hit, 2, 0, "red") and _center_hit(dyed_hit, 3, 0), "a dry stain does not stop the beam")

	var wet := _blank(4, 5)
	wet["tide_phases"] = [2]
	wet["lanterns"] = [_lamp("L", 1, 0, "S", "white")]
	wet["docks"] = [_need("D", 2, 2, "red")]
	wet["pieces"] = [
		_fixed_stain("K", 1, 3, 0),
		_fixed_tide("T", 1, 4, 90),
		_fixed_tide("B", 2, 4, 0),
		_fixed_shutter("U", 2, 3),
	]
	var wet_state := Charts.make_state(wet, true)
	check(Tracer.is_flooded(wet, wet_state, Vector2i(1, 3)), "the sample stain is under water")
	var wet_hit: Dictionary = Tracer.trace(wet, wet_state)
	check(wet_hit["docks"]["D"].has("red") and wet_hit["docks"]["D"].size() == 1, "a flooded stain recolors white to red")
	check(_center_hit(wet_hit, 1, 3) and _center_hit(wet_hit, 1, 4), "a flooded stain does not stop the beam")
	check(_departs(wet_hit, 1, 3, "red"), "a flooded stain leaves red")
	wet["pieces"][0]["solution_rot"] = 90
	wet["docks"][0]["color"] = "blue"
	var wet_blue: Dictionary = Tracer.trace(wet, Charts.make_state(wet, true))
	check(wet_blue["docks"]["D"].has("blue") and wet_blue["docks"]["D"].size() == 1, "a flooded blue stain leaves blue")

	var onward := _blank(3, 4)
	onward["tide_phases"] = [2]
	onward["lanterns"] = [_lamp("L", 1, 0, "S", "white")]
	onward["pieces"] = [_fixed_stain("K", 1, 2, 0)]
	var onward_hit: Dictionary = Tracer.trace(onward, Charts.make_state(onward, true))
	check(_center_hit(onward_hit, 1, 2) and not _center_hit(onward_hit, 1, 3), "the next flooded cell after a stain still stops the beam")
	check(_departs(onward_hit, 1, 2, "red"), "the beam is already red when that next cell stops it")


func test_stain_book() -> void:
	var book: Array = Charts.stain()
	check(book.size() == 8, "stain book has eight charts")
	var titles := ["The Red Stain", "Dry Color", "Blue to Red", "The Swap", "One Color", "After the Gate", "The Held Stain", "The Stain Mark"]
	var solution_tides := [0, 0, 0, 0, 0, 1, 1, 1]
	for i in book.size():
		var chart: Dictionary = book[i]
		check(str(chart["id"]) == str(i + 63), "stain chart %d keeps its number" % (i + 63))
		check(str(chart["title"]) == str(titles[i]), "stain chart %d keeps its title" % (i + 63))
		check(str(chart["harbor"]) == Charts.STAIN, "chart %s belongs to the stain" % str(chart["id"]))
		check(int(chart["solution_tide_index"]) == int(solution_tides[i]), "chart %s keeps its clearing tide" % str(chart["id"]))
		var stain_count := 0
		for raw_piece in chart["pieces"]:
			var piece: Dictionary = raw_piece
			if str(piece["kind"]) == "stain":
				stain_count += 1
		check(stain_count == 1, "chart %s needs one stain" % str(chart["id"]))
		var tides := {}
		for raw_clear in _clears(chart):
			var clearing: Dictionary = raw_clear
			tides[int(clearing["tide_index"])] = true
		check(tides.size() == 1 and tides.has(int(solution_tides[i])), "chart %s has one clearing tide" % str(chart["id"]))
	check(str(book[0]["teach"]).to_lower().contains("does not split"), "chart 63 teaches that a stain does not split")
	check(str(book[0]["teach"]).to_lower().contains("does not reflect"), "chart 63 teaches that a stain does not reflect")
	check(str(book[0]["teach"]).to_lower().contains("pane"), "chart 63 teaches the pane difference")
	check(str(book[0]["teach"]).to_lower().contains("prism"), "chart 63 teaches the prism difference")
	check(str(book[1]["teach"]).to_lower().contains("shutter"), "chart 64 teaches the shutter difference")
	check(str(book[3]["teach"]).to_lower().contains("starts blue"), "chart 66 teaches the opening color")
	check(str(book[4]["teach"]).to_lower().contains("unclicked"), "chart 67 teaches the unclicked stain")
	check(str(book[6]["teach"]).to_lower().contains("wrong tide"), "chart 69 warns about the wrong tide")
	check(str(book[6]["teach"]).to_lower().contains("middle"), "chart 69 teaches the middle mark")
	check(str(book[7]["teach"]).to_lower().contains("middle"), "chart 70 teaches the middle mark")
	for raw_old in Charts.all().slice(0, 62):
		var older: Dictionary = raw_old
		for raw_piece in older["pieces"]:
			var older_piece: Dictionary = raw_piece
			check(str(older_piece["kind"]) != "stain", "chart %s keeps its pieces" % str(older["id"]))
		for raw_fix in older["fixtures"]:
			var older_fix: Dictionary = raw_fix
			check(str(older_fix["kind"]) != "stain", "chart %s keeps its fixed glass" % str(older["id"]))

	var red: Dictionary = book[0]
	var red_solved := Charts.make_state(red, true)
	var red_hit: Dictionary = Tracer.trace(red, red_solved)
	check(red_hit["docks"]["D"].has("red") and red_hit["docks"]["D"].size() == 1, "chart 63 lands red")
	check(_same_row(red_hit, 1), "chart 63 stays straight")
	var red_blue := Charts.duplicate_state(red_solved)
	red_blue["pieces"]["K"]["rot"] = 90
	check(red_hit["docks"]["D"].has("red") and Tracer.trace(red, red_blue)["docks"]["D"].has("blue") and not Tracer.is_cleared(red, red_blue), "chart 63 blue stain fails the red dock")
	var red_same := Charts.duplicate_state(red_solved)
	red_same["pieces"]["K"]["rot"] = 180
	check(Tracer.is_cleared(red, red_same) and Hints.first_wrong(red, red_same) == "", "chart 63 stain 180 is the same red")
	var as_pane: Dictionary = Charts.stain()[0]
	_retarget(as_pane, "K", "pane", 0)
	var pane_hit: Dictionary = Tracer.trace(as_pane, Charts.make_state(as_pane, true))
	check(pane_hit["docks"]["D"].is_empty() and not Tracer.is_cleared(as_pane, Charts.make_state(as_pane, true)), "a pane cannot turn chart 63's white beam red")
	check(_center_hit(pane_hit, 2, 1) and not _center_hit(pane_hit, 3, 1), "chart 63's pane stops white")
	var as_prism: Dictionary = Charts.stain()[0]
	_retarget(as_prism, "K", "prism", 90)
	var prism_hit: Dictionary = Tracer.trace(as_prism, Charts.make_state(as_prism, true))
	check(prism_hit["docks"]["D"].is_empty() and not Tracer.is_cleared(as_prism, Charts.make_state(as_prism, true)), "a prism cannot pass chart 63's white beam straight through")
	check(_center_hit(prism_hit, 2, 0) and _center_hit(prism_hit, 2, 2) and not _center_hit(prism_hit, 3, 1), "chart 63's prism splits instead of going straight")

	var dry: Dictionary = book[1]
	var dry_solved := Charts.make_state(dry, true)
	check(int(dry_solved["tide_index"]) == 0, "chart 64 is authored dry")
	check(not Tracer.is_flooded(dry, dry_solved, Vector2i(2, 1)), "chart 64 stain is on a dry row")
	var dry_hit: Dictionary = Tracer.trace(dry, dry_solved)
	check(dry_hit["docks"]["Rd"].has("red") and dry_hit["docks"]["Rd"].size() == 1, "chart 64 dry stain turns white red")
	var dry_blue := Charts.duplicate_state(dry_solved)
	dry_blue["pieces"]["K"]["rot"] = 90
	check(Tracer.trace(dry, dry_blue)["docks"]["Rd"].has("blue") and not Tracer.is_cleared(dry, dry_blue), "chart 64 blue stain misses the red dock")
	var dry_wet := Charts.duplicate_state(dry_solved)
	dry_wet["tide_index"] = 1
	check(Tracer.trace(dry, dry_wet)["docks"]["Rd"].is_empty() and not Tracer.is_cleared(dry, dry_wet), "chart 64 high water covers the dock")
	var as_shutter: Dictionary = Charts.stain()[1]
	_retarget(as_shutter, "K", "shutter", 0)
	var shutter_hit: Dictionary = Tracer.trace(as_shutter, Charts.make_state(as_shutter, true))
	check(shutter_hit["docks"]["Rd"].is_empty() and not Tracer.is_cleared(as_shutter, Charts.make_state(as_shutter, true)), "a shutter in chart 64's stain cell stops the dry beam")
	check(_center_hit(shutter_hit, 2, 1) and not _center_hit(shutter_hit, 2, 2), "chart 64's shutter does not let the beam continue")

	var tinted: Dictionary = book[2]
	var tinted_solved := Charts.make_state(tinted, true)
	check(tinted_solved["pieces"]["K"]["rot"] == 0 and tinted_solved["pieces"]["C"]["rot"] == 0, "chart 65 solution is a red stain and a red pane")
	var tinted_hit: Dictionary = Tracer.trace(tinted, tinted_solved)
	check(tinted_hit["docks"]["Rd"].has("red") and tinted_hit["docks"]["Rd"].size() == 1, "chart 65 blue becomes red and passes the pane")
	var tinted_left := Charts.duplicate_state(tinted_solved)
	tinted_left["pieces"]["K"]["rot"] = 90
	check(Tracer.trace(tinted, tinted_left)["docks"]["Rd"].is_empty() and not Tracer.is_cleared(tinted, tinted_left), "chart 65 left blue, the red pane stops it")

	var swap: Dictionary = book[3]
	var swap_start := Charts.make_state(swap, false)
	check(int(swap_start["pieces"]["K"]["rot"]) == 90, "chart 66 stain starts blue")
	var swap_solved := Charts.make_state(swap, true)
	var swap_hit: Dictionary = Tracer.trace(swap, swap_solved)
	check(swap_hit["docks"]["Rd"].has("red") and not bool(swap_hit["boats"]["Hm"]), "chart 66 clicked stain lands red")
	var swap_left := Charts.duplicate_state(swap_solved)
	swap_left["pieces"]["K"]["rot"] = 90
	check(Tracer.trace(swap, swap_left)["docks"]["Rd"].has("blue") and not Tracer.is_cleared(swap, swap_left), "chart 66 unclicked stain fails the dock")
	var swap_down := Charts.duplicate_state(swap_solved)
	swap_down["pieces"]["M"]["rot"] = 90
	check(bool(Tracer.trace(swap, swap_down)["boats"]["Hm"]), "chart 66 mirror turned south wakes the hull")

	var one: Dictionary = book[4]
	var one_solved := Charts.make_state(one, true)
	var one_hit: Dictionary = Tracer.trace(one, one_solved)
	check(one_hit["docks"]["Rn"].has("red") and one_hit["docks"]["Rs"].has("red"), "chart 67 both docks take red")
	check(one_hit["docks"]["Rs"].size() == 1, "chart 67 lower dock is only red")
	var one_left := Charts.duplicate_state(one_solved)
	one_left["pieces"]["K"]["rot"] = 90
	var one_left_hit: Dictionary = Tracer.trace(one, one_left)
	check(one_left_hit["docks"]["Rn"].has("red") and one_left_hit["docks"]["Rs"].has("blue") and not Tracer.is_cleared(one, one_left), "chart 67 unclicked stain leaves the lower dock blue")
	var one_face := Charts.duplicate_state(one_solved)
	one_face["pieces"]["P"]["rot"] = 0
	check(Tracer.trace(one, one_face)["docks"]["Rn"].is_empty() and Tracer.trace(one, one_face)["docks"]["Rs"].is_empty(), "chart 67 north face absorbs the east beam")

	var gate: Dictionary = book[5]
	var gate_solved := Charts.make_state(gate, true)
	check(int(gate_solved["tide_index"]) == 1, "chart 68 opens on the flood")
	check(Tracer.is_flooded(gate, gate_solved, Vector2i(3, 5)), "chart 68 stain is beyond the shutter, under water")
	var gate_hit: Dictionary = Tracer.trace(gate, gate_solved)
	check(gate_hit["docks"]["Rd"].has("red") and not gate_hit["docks"]["Rd"].has("white") and not bool(gate_hit["boats"]["Hb"]) and not bool(gate_hit["boats"]["Hm"]), "chart 68 stain turns the gated beam red")
	var gate_dry := Charts.duplicate_state(gate_solved)
	gate_dry["tide_index"] = 0
	check(bool(Tracer.trace(gate, gate_dry)["boats"]["Hb"]) and not Tracer.trace(gate, gate_dry)["docks"]["Rd"].has("red"), "chart 68 dry shutter stops the beam and the lower lamp wakes the hull")
	var gate_blue := Charts.duplicate_state(gate_solved)
	gate_blue["pieces"]["K"]["rot"] = 90
	check(Tracer.trace(gate, gate_blue)["docks"]["Rd"].has("blue") and not Tracer.is_cleared(gate, gate_blue), "chart 68 blue stain misses the red dock")
	var gate_up := Charts.duplicate_state(gate_solved)
	gate_up["pieces"]["M"]["rot"] = 0
	check(bool(Tracer.trace(gate, gate_up)["boats"]["Hm"]), "chart 68 feed mirror turned north wakes the hull")
	var gate_shutter: Dictionary = Charts.stain()[5]
	_retarget(gate_shutter, "K", "shutter", 0)
	var gate_white: Dictionary = Tracer.trace(gate_shutter, Charts.make_state(gate_shutter, true))
	check(gate_white["docks"]["Rd"].has("white") and not gate_white["docks"]["Rd"].has("red") and not Tracer.is_cleared(gate_shutter, Charts.make_state(gate_shutter, true)), "a shutter beyond chart 68's gate keeps white and misses")

	var held: Dictionary = book[6]
	var held_solved := Charts.make_state(held, true)
	check(int(held_solved["tide_index"]) == 1, "chart 69 is authored at mid water")
	check(Tracer.is_flooded(held, held_solved, Vector2i(3, 6)), "chart 69 stain is flooded at the middle mark")
	var held_hit: Dictionary = Tracer.trace(held, held_solved)
	check(held_hit["docks"]["Rd"].has("red") and not held_hit["docks"]["Rd"].has("white") and not bool(held_hit["boats"]["Hb"]) and not bool(held_hit["boats"]["Hm"]), "chart 69 middle mark recolors and holds the dock")
	var held_low := Charts.duplicate_state(held_solved)
	held_low["tide_index"] = 0
	check(bool(Tracer.trace(held, held_low)["boats"]["Hb"]) and not Tracer.is_cleared(held, held_low), "chart 69 low water is the wrong tide")
	var held_high := Charts.duplicate_state(held_solved)
	held_high["tide_index"] = 2
	check(not Tracer.trace(held, held_high)["docks"]["Rd"].has("red") and not Tracer.is_cleared(held, held_high), "chart 69 high water covers the dock")
	var held_blue := Charts.duplicate_state(held_solved)
	held_blue["pieces"]["K"]["rot"] = 90
	check(Tracer.trace(held, held_blue)["docks"]["Rd"].has("blue") and not Tracer.is_cleared(held, held_blue), "chart 69 blue stain misses at the middle mark")
	var held_up := Charts.duplicate_state(held_solved)
	held_up["pieces"]["M"]["rot"] = 0
	check(bool(Tracer.trace(held, held_up)["boats"]["Hm"]), "chart 69 feed mirror turned north wakes the hull")
	for raw_held in _clears(held):
		var held_state: Dictionary = raw_held
		check(int(held_state["tide_index"]) == 1, "every chart 69 clear is mid water")

	var mark: Dictionary = book[7]
	var mark_start := Charts.make_state(mark, false)
	check(str(mark_start["pieces"]["P"]["socket"]) == "side", "chart 70 prism starts off the beam")
	check(int(mark_start["pieces"]["K"]["rot"]) == 90, "chart 70 stain starts blue")
	var mark_solved := Charts.make_state(mark, true)
	check(int(mark_solved["tide_index"]) == 1 and str(mark_solved["pieces"]["P"]["socket"]) == "line", "chart 70 solution moves the prism and holds mid water")
	var mark_hit: Dictionary = Tracer.trace(mark, mark_solved)
	check(mark_hit["docks"]["Rn"].has("red") and mark_hit["docks"]["Rs"].has("red") and mark_hit["docks"]["Rs"].size() == 1, "chart 70 lands red on both docks")
	check(not bool(mark_hit["boats"]["Hw"]) and not bool(mark_hit["boats"]["Hb"]), "chart 70 solution leaves both hulls dark")
	var mark_side := Charts.duplicate_state(mark_solved)
	mark_side["pieces"]["P"]["socket"] = "side"
	check(bool(Tracer.trace(mark, mark_side)["boats"]["Hw"]) and not Tracer.trace(mark, mark_side)["docks"]["Rn"].has("red"), "chart 70 side socket lets white wake the hull")
	var mark_left := Charts.duplicate_state(mark_solved)
	mark_left["pieces"]["K"]["rot"] = 90
	var mark_left_hit: Dictionary = Tracer.trace(mark, mark_left)
	check(mark_left_hit["docks"]["Rn"].has("red") and mark_left_hit["docks"]["Rs"].has("blue") and not Tracer.is_cleared(mark, mark_left), "chart 70 unclicked stain fails the lower dock")
	var mark_low := Charts.duplicate_state(mark_solved)
	mark_low["tide_index"] = 0
	check(bool(Tracer.trace(mark, mark_low)["boats"]["Hb"]) and Tracer.trace(mark, mark_low)["docks"]["Rn"].has("red") and not Tracer.is_cleared(mark, mark_low), "chart 70 low water is the wrong tide")
	var mark_high := Charts.duplicate_state(mark_solved)
	mark_high["tide_index"] = 2
	check(Tracer.trace(mark, mark_high)["docks"]["Rn"].has("red") and not Tracer.trace(mark, mark_high)["docks"]["Rs"].has("red") and not Tracer.is_cleared(mark, mark_high), "chart 70 high water covers the lower dock")
	for raw_mark in _clears(mark):
		var mark_clear: Dictionary = raw_mark
		check(int(mark_clear["tide_index"]) == 1, "every chart 70 clear is mid water")


func test_vane_rule() -> void:
	check(Tracer.vane_facing(0) == "N" and Tracer.vane_facing(90) == "E", "vane 0 faces north and 90 faces east")
	check(Tracer.vane_facing(180) == "S" and Tracer.vane_facing(270) == "W", "vane 180 faces south and 270 faces west")
	check(Tracer.vane_facing(360) == "N" and Tracer.vane_facing(450) == "E", "vane facing repeats every full turn")
	check(Tracer.norm_rot("vane", 0) == 0 and Tracer.norm_rot("vane", 90) == 90, "a vane keeps its east facing")
	check(Tracer.norm_rot("vane", 180) == 180 and Tracer.norm_rot("vane", 270) == 270, "a vane's opposite facing is not the same")
	check(Tracer.turn_rot("vane", 0) == 90 and Tracer.turn_rot("vane", 90) == 180, "clicking a vane turns clockwise")
	check(Tracer.turn_rot("vane", 180) == 270 and Tracer.turn_rot("vane", 270) == 0, "a vane click walks all four facings")
	var spun := 0
	for _i in 4:
		spun = Tracer.turn_rot("vane", spun)
	check(spun == 0, "four clicks restore the vane facing")

	var side := _blank(6, 5)
	side["lanterns"] = [_lamp("L", 2, 4, "N", "red")]
	side["docks"] = [_need("D", 4, 2, "red"), _need("N", 2, 0, "red"), _need("W", 0, 2, "red")]
	side["pieces"] = [_fixed_vane("V", 2, 2, 90)]
	var side_hit: Dictionary = Tracer.trace(side, Charts.make_state(side, true))
	check(side_hit["docks"]["D"].has("red") and side_hit["docks"]["D"].size() == 1, "a side entry leaves in the vane's facing")
	check(side_hit["docks"]["N"].is_empty() and side_hit["docks"]["W"].is_empty(), "a side entry does not keep its old direction")
	check(_arrives(side_hit, 2, 2, "red") and _departs(side_hit, 2, 2, "red"), "a side entry keeps its color")
	check(_center_hit(side_hit, 3, 2) and not _center_hit(side_hit, 2, 1), "the east facing, not the entry, picks the exit")

	var other := _blank(6, 5)
	other["lanterns"] = [_lamp("L", 2, 0, "S", "red")]
	other["docks"] = [_need("D", 4, 2, "red"), _need("S", 2, 4, "red")]
	other["pieces"] = [_fixed_vane("V", 2, 2, 90)]
	var other_hit: Dictionary = Tracer.trace(other, Charts.make_state(other, true))
	check(other_hit["docks"]["D"].has("red") and other_hit["docks"]["D"].size() == 1, "the other side also leaves in the vane's facing")
	check(other_hit["docks"]["S"].is_empty(), "the other side does not pass straight")
	check(_departs(other_hit, 2, 2, "red") and _segments_are(other_hit, "red"), "the other side keeps its color")

	var north := _blank(5, 5)
	north["lanterns"] = [_lamp("L", 0, 2, "E", "blue")]
	north["docks"] = [_need("N", 2, 0, "blue"), _need("E", 4, 2, "blue")]
	north["pieces"] = [_fixed_vane("V", 2, 2, 0)]
	var north_hit: Dictionary = Tracer.trace(north, Charts.make_state(north, true))
	check(north_hit["docks"]["N"].has("blue") and north_hit["docks"]["N"].size() == 1, "a side entry follows a north facing")
	check(north_hit["docks"]["E"].is_empty() and _departs(north_hit, 2, 2, "blue"), "a north vane does not recolor and does not send the beam east")

	var aligned := _blank(6, 3)
	aligned["lanterns"] = [_lamp("L", 0, 1, "E", "blue")]
	aligned["docks"] = [_need("D", 5, 1, "blue")]
	aligned["pieces"] = [_fixed_vane("V", 2, 1, 90)]
	var aligned_hit: Dictionary = Tracer.trace(aligned, Charts.make_state(aligned, true))
	check(aligned_hit["docks"]["D"].has("blue") and aligned_hit["docks"]["D"].size() == 1, "a beam already aligned passes straight")
	check(_same_row(aligned_hit, 1) and _segments_are(aligned_hit, "blue"), "an aligned vane keeps the row and the color")

	var head := _blank(6, 3)
	head["lanterns"] = [_lamp("L", 4, 1, "W", "white")]
	head["docks"] = [_need("W", 0, 1, "white"), _need("N", 2, 0, "white"), _need("S", 2, 2, "white")]
	head["pieces"] = [_fixed_vane("V", 2, 1, 90)]
	var head_hit: Dictionary = Tracer.trace(head, Charts.make_state(head, true))
	check(head_hit["docks"]["W"].is_empty() and head_hit["docks"]["N"].is_empty() and head_hit["docks"]["S"].is_empty(), "a head-on beam stops")
	check(_center_hit(head_hit, 2, 1) and not _center_hit(head_hit, 1, 1), "a head-on beam does not leave the vane")
	check(_segments_are(head_hit, "white"), "a head-on stop does not recolor")

	var wet := _blank(3, 4)
	wet["tide_phases"] = [0, 2]
	wet["solution_tide_index"] = 1
	wet["lanterns"] = [_lamp("L", 1, 0, "S", "white")]
	wet["docks"] = [_need("D", 1, 3, "white")]
	wet["pieces"] = [_fixed_vane("V", 1, 2, 180)]
	var wet_state := Charts.make_state(wet, true)
	check(Tracer.is_flooded(wet, wet_state, Vector2i(1, 2)), "the sample vane is under water")
	var wet_hit: Dictionary = Tracer.trace(wet, wet_state)
	check(wet_hit["docks"]["D"].is_empty() and not _center_hit(wet_hit, 1, 2), "a flooded vane stops the beam at the waterline")
	check(not _center_hit(wet_hit, 1, 3), "a flooded vane does not let the beam through")
	var on_line := false
	for raw_line in wet_hit["segments"]:
		var line: Dictionary = raw_line
		if is_equal_approx(float(line["x1"]), 1.5) and is_equal_approx(float(line["y1"]), 2.0):
			on_line = true
	check(on_line, "a flooded vane ends on the waterline")
	var dry := Charts.duplicate_state(wet_state)
	dry["tide_index"] = 0
	check(Tracer.trace(wet, dry)["docks"]["D"].has("white"), "the same vane passes while its row is dry")
	var gate := _blank(3, 4)
	gate["tide_phases"] = [2]
	gate["lanterns"] = [_lamp("L", 1, 0, "S", "white")]
	gate["docks"] = [_need("D", 1, 3, "white")]
	gate["pieces"] = [_fixed_shutter("G", 1, 2)]
	var gate_hit: Dictionary = Tracer.trace(gate, Charts.make_state(gate, true))
	check(_center_hit(gate_hit, 1, 2) and not _center_hit(wet_hit, 1, 2), "a flooded shutter opens and a flooded vane does not")


func test_vane_book() -> void:
	var book: Array = Charts.vane()
	check(book.size() == 8, "vane book has eight charts")
	var titles := ["The East Vane", "After the Color", "Dry Turn", "The Quarter", "Two Bends", "Above the Gate", "The Held Vane", "The Vane Mark"]
	var solution_tides := [0, 0, 0, 0, 0, 1, 1, 1]
	for i in book.size():
		var chart: Dictionary = book[i]
		check(str(chart["id"]) == str(i + 71), "vane chart %d keeps its number" % (i + 71))
		check(str(chart["title"]) == str(titles[i]), "vane chart %d keeps its title" % (i + 71))
		check(str(chart["harbor"]) == Charts.VANE, "chart %s belongs to the vane" % str(chart["id"]))
		check(int(chart["solution_tide_index"]) == int(solution_tides[i]), "chart %s keeps its clearing tide" % str(chart["id"]))
		var vane_count := 0
		for raw_piece in chart["pieces"]:
			var piece: Dictionary = raw_piece
			if str(piece["kind"]) == "vane":
				vane_count += 1
		check(vane_count >= 1, "chart %s needs the vane" % str(chart["id"]))
		var tides := {}
		for raw_clear in _clears(chart):
			var clearing: Dictionary = raw_clear
			tides[int(clearing["tide_index"])] = true
		check(tides.size() == 1 and tides.has(int(solution_tides[i])), "chart %s has one clearing tide" % str(chart["id"]))
	check(str(book[0]["teach"]).to_lower().contains("does not recolor"), "chart 71 teaches that a vane does not recolor")
	check(str(book[0]["teach"]).to_lower().contains("does not split"), "chart 71 teaches that a vane does not split")
	check(str(book[0]["teach"]).to_lower().contains("head-on"), "chart 71 teaches the head-on stop")
	check(str(book[0]["teach"]).to_lower().contains("stain"), "chart 71 teaches the stain difference")
	check(str(book[1]["teach"]).to_lower().contains("unrotated"), "chart 72 teaches the unrotated vane")
	check(str(book[2]["teach"]).to_lower().contains("shutter"), "chart 73 teaches the shutter difference")
	check(str(book[2]["teach"]).to_lower().contains("waterline"), "chart 73 teaches the waterline")
	check(str(book[3]["teach"]).to_lower().contains("unclicked"), "chart 74 teaches the unclicked vane")
	check(str(book[3]["teach"]).to_lower().contains("two facings"), "chart 74 teaches that a mirror has two facings")
	check(str(book[4]["teach"]).to_lower().contains("unrotated"), "chart 75 teaches either vane left unrotated")
	check(str(book[5]["teach"]).to_lower().contains("dry row"), "chart 76 teaches the dry row")
	check(str(book[5]["teach"]).to_lower().contains("flooded row"), "chart 76 teaches the flooded row")
	check(str(book[6]["teach"]).to_lower().contains("wrong tide"), "chart 77 warns about the wrong tide")
	check(str(book[6]["teach"]).to_lower().contains("middle"), "chart 77 teaches the middle mark")
	check(str(book[7]["teach"]).to_lower().contains("middle"), "chart 78 teaches the middle mark")
	for raw_old in Charts.all().slice(0, 70):
		var older: Dictionary = raw_old
		for raw_piece in older["pieces"]:
			var older_piece: Dictionary = raw_piece
			check(str(older_piece["kind"]) != "vane", "chart %s keeps its pieces" % str(older["id"]))
		for raw_fix in older["fixtures"]:
			var older_fix: Dictionary = raw_fix
			check(str(older_fix["kind"]) != "vane", "chart %s keeps its fixed glass" % str(older["id"]))

	var east: Dictionary = book[0]
	var east_solved := Charts.make_state(east, true)
	check(int(east_solved["pieces"]["V"]["rot"]) == 90, "chart 71 solution faces east")
	var east_hit: Dictionary = Tracer.trace(east, east_solved)
	check(east_hit["docks"]["D"].has("white") and east_hit["docks"]["D"].size() == 1, "chart 71 lands white on the dock")
	check(not bool(east_hit["boats"]["Hn"]) and not bool(east_hit["boats"]["Hw"]), "chart 71 solution leaves both hulls dark")
	check(_departs(east_hit, 2, 2, "white") and _center_hit(east_hit, 4, 2), "chart 71 leaves the vane heading east")
	var east_north := Charts.duplicate_state(east_solved)
	east_north["pieces"]["V"]["rot"] = 0
	check(bool(Tracer.trace(east, east_north)["boats"]["Hn"]) and not Tracer.trace(east, east_north)["docks"]["D"].has("white"), "chart 71 faced north passes and misses")
	var east_west := Charts.duplicate_state(east_solved)
	east_west["pieces"]["V"]["rot"] = 270
	check(bool(Tracer.trace(east, east_west)["boats"]["Hw"]) and not Tracer.is_cleared(east, east_west), "chart 71 faced west leaves west")
	var east_head := Charts.duplicate_state(east_solved)
	east_head["pieces"]["V"]["rot"] = 180
	var east_head_hit: Dictionary = Tracer.trace(east, east_head)
	check(east_head_hit["docks"]["D"].is_empty() and not bool(east_head_hit["boats"]["Hn"]) and not bool(east_head_hit["boats"]["Hw"]), "chart 71 faced south is head-on and stops")
	check(_center_hit(east_head_hit, 2, 2) and not _center_hit(east_head_hit, 2, 1) and not _center_hit(east_head_hit, 3, 2), "chart 71 head-on beam does not leave the vane")
	var east_same := Charts.duplicate_state(east_solved)
	east_same["pieces"]["V"]["rot"] = 450
	check(Tracer.is_cleared(east, east_same) and Hints.first_wrong(east, east_same) == "", "chart 71 vane 450 is the same east facing")
	var east_flip := Charts.duplicate_state(east_solved)
	east_flip["pieces"]["V"]["rot"] = 270
	check(Hints.first_wrong(east, east_flip) == "V", "chart 71 west facing is not an equivalent east")
	var as_stain: Dictionary = Charts.vane()[0]
	_retarget(as_stain, "V", "stain", 0)
	var stain_hit: Dictionary = Tracer.trace(as_stain, Charts.make_state(as_stain, true))
	check(bool(stain_hit["boats"]["Hn"]) and stain_hit["docks"]["D"].is_empty() and not Tracer.is_cleared(as_stain, Charts.make_state(as_stain, true)), "a stain cannot turn chart 71's beam onto the dock")
	check(_center_hit(stain_hit, 2, 1) and _center_hit(stain_hit, 2, 0) and not _center_hit(stain_hit, 3, 2), "chart 71's stain keeps going north")

	var color: Dictionary = book[1]
	var color_start := Charts.make_state(color, false)
	check(int(color_start["pieces"]["K"]["rot"]) == 90 and int(color_start["pieces"]["V"]["rot"]) == 90, "chart 72 starts with a blue stain and an east vane")
	var color_solved := Charts.make_state(color, true)
	var color_hit: Dictionary = Tracer.trace(color, color_solved)
	check(color_hit["docks"]["Rd"].has("red") and color_hit["docks"]["Rd"].size() == 1 and not bool(color_hit["boats"]["Hs"]), "chart 72 turns the red beam onto the dock")
	check(_arrives(color_hit, 3, 2, "red") and _departs(color_hit, 3, 2, "red"), "chart 72 vane keeps the red")
	var color_left := Charts.duplicate_state(color_solved)
	color_left["pieces"]["V"]["rot"] = 90
	var color_left_hit: Dictionary = Tracer.trace(color, color_left)
	check(color_left_hit["docks"]["Rd"].is_empty() and _center_hit(color_left_hit, 4, 2) and not _center_hit(color_left_hit, 3, 1), "chart 72 unrotated vane passes east and misses")
	var color_south := Charts.duplicate_state(color_solved)
	color_south["pieces"]["V"]["rot"] = 180
	check(bool(Tracer.trace(color, color_south)["boats"]["Hs"]) and not Tracer.is_cleared(color, color_south), "chart 72 faced south wakes the hull")
	var color_blue := Charts.duplicate_state(color_solved)
	color_blue["pieces"]["K"]["rot"] = 90
	check(Tracer.trace(color, color_blue)["docks"]["Rd"].has("blue") and not Tracer.is_cleared(color, color_blue), "chart 72 blue stain misses the red dock")

	var dry: Dictionary = book[2]
	var dry_solved := Charts.make_state(dry, true)
	check(int(dry_solved["tide_index"]) == 0, "chart 73 is authored dry")
	check(not Tracer.is_flooded(dry, dry_solved, Vector2i(2, 3)), "chart 73 vane is on a dry row")
	var dry_hit: Dictionary = Tracer.trace(dry, dry_solved)
	check(dry_hit["docks"]["D"].has("white") and dry_hit["docks"]["D"].size() == 1 and not bool(dry_hit["boats"]["Hs"]), "chart 73 dry vane turns onto the dock")
	var dry_south := Charts.duplicate_state(dry_solved)
	dry_south["pieces"]["V"]["rot"] = 180
	check(bool(Tracer.trace(dry, dry_south)["boats"]["Hs"]) and not Tracer.is_cleared(dry, dry_south), "chart 73 faced south passes into the hull")
	var dry_wet := Charts.duplicate_state(dry_solved)
	dry_wet["tide_index"] = 1
	var dry_wet_hit: Dictionary = Tracer.trace(dry, dry_wet)
	check(Tracer.is_flooded(dry, dry_wet, Vector2i(2, 3)), "chart 73 flood covers the vane")
	check(dry_wet_hit["docks"]["D"].is_empty() and not _center_hit(dry_wet_hit, 2, 3) and not Tracer.is_cleared(dry, dry_wet), "chart 73 flood shuts the vane at the waterline")
	var as_shutter: Dictionary = Charts.vane()[2]
	_retarget(as_shutter, "V", "shutter", 0)
	var shutter_dry: Dictionary = Tracer.trace(as_shutter, Charts.make_state(as_shutter, true))
	check(shutter_dry["docks"]["D"].is_empty() and not Tracer.is_cleared(as_shutter, Charts.make_state(as_shutter, true)), "a shutter in chart 73's vane cell stops the dry beam")
	check(_center_hit(shutter_dry, 2, 3) and not _center_hit(shutter_dry, 3, 3), "chart 73's dry shutter does not turn the beam")
	var shutter_wet_state := Charts.make_state(as_shutter, true)
	shutter_wet_state["tide_index"] = 1
	var shutter_wet: Dictionary = Tracer.trace(as_shutter, shutter_wet_state)
	check(_center_hit(shutter_wet, 2, 3) and shutter_wet["docks"]["D"].is_empty(), "chart 73's shutter opens under water and still misses the dock")

	var quarter: Dictionary = book[3]
	var quarter_start := Charts.make_state(quarter, false)
	check(int(quarter_start["pieces"]["V"]["rot"]) == 270, "chart 74 vane starts facing west")
	var quarter_open: Dictionary = Tracer.trace(quarter, quarter_start)
	check(bool(quarter_open["boats"]["Hw"]) and quarter_open["docks"]["D"].is_empty(), "chart 74 unclicked vane misses into the hull")
	var quarter_solved := Charts.make_state(quarter, true)
	var quarter_hit: Dictionary = Tracer.trace(quarter, quarter_solved)
	check(quarter_hit["docks"]["D"].has("white") and quarter_hit["docks"]["D"].size() == 1 and not bool(quarter_hit["boats"]["Hw"]), "chart 74 both beams leave east")
	var quarter_north := Charts.duplicate_state(quarter_solved)
	quarter_north["pieces"]["V"]["rot"] = 0
	check(quarter_north["pieces"]["V"]["rot"] == Tracer.turn_rot("vane", 270) and not Tracer.is_cleared(quarter, quarter_north), "chart 74 one click from west still misses")
	var as_slash: Dictionary = Charts.vane()[3]
	_retarget(as_slash, "V", "mirror", 0)
	var slash_hit: Dictionary = Tracer.trace(as_slash, Charts.make_state(as_slash, true))
	check(bool(slash_hit["boats"]["Hw"]) and not Tracer.is_cleared(as_slash, Charts.make_state(as_slash, true)), "a slash mirror cannot replace chart 74's vane")
	var as_backslash: Dictionary = Charts.vane()[3]
	_retarget(as_backslash, "V", "mirror", 90)
	var back_hit: Dictionary = Tracer.trace(as_backslash, Charts.make_state(as_backslash, true))
	check(bool(back_hit["boats"]["Hw"]) and not Tracer.is_cleared(as_backslash, Charts.make_state(as_backslash, true)), "a backslash mirror cannot replace chart 74's vane")

	var bends: Dictionary = book[4]
	var bends_start := Charts.make_state(bends, false)
	check(int(bends_start["pieces"]["V1"]["rot"]) == 90 and int(bends_start["pieces"]["V2"]["rot"]) == 0, "chart 75 both vanes start unrotated")
	var bends_solved := Charts.make_state(bends, true)
	var bends_hit: Dictionary = Tracer.trace(bends, bends_solved)
	check(bends_hit["docks"]["D"].has("white") and not bool(bends_hit["boats"]["H"]), "chart 75 walks the beam around the hull")
	var bends_first := Charts.duplicate_state(bends_solved)
	bends_first["pieces"]["V1"]["rot"] = 90
	check(bool(Tracer.trace(bends, bends_first)["boats"]["H"]) and not Tracer.is_cleared(bends, bends_first), "chart 75 first vane left unrotated wakes the hull")
	var bends_second := Charts.duplicate_state(bends_solved)
	bends_second["pieces"]["V2"]["rot"] = 0
	var bends_second_hit: Dictionary = Tracer.trace(bends, bends_second)
	check(bends_second_hit["docks"]["D"].is_empty() and _center_hit(bends_second_hit, 2, 4) and not _center_hit(bends_second_hit, 3, 4), "chart 75 second vane left unrotated stops the beam")

	var gate_chart: Dictionary = book[5]
	var gate_solved := Charts.make_state(gate_chart, true)
	check(int(gate_solved["tide_index"]) == 1, "chart 76 opens on the flood")
	check(not Tracer.is_flooded(gate_chart, gate_solved, Vector2i(3, 3)), "chart 76 vane is above the water")
	check(Tracer.is_flooded(gate_chart, gate_solved, Vector2i(2, 4)) and Tracer.is_flooded(gate_chart, gate_solved, Vector2i(3, 4)), "chart 76 gate rows are flooded")
	var gate_beam: Dictionary = Tracer.trace(gate_chart, gate_solved)
	check(gate_beam["docks"]["D"].has("white") and not bool(gate_beam["boats"]["Hm"]) and not bool(gate_beam["boats"]["Ha"]) and not bool(gate_beam["boats"]["Hb"]), "chart 76 vane turns the beam above the gate")
	var gate_low := Charts.duplicate_state(gate_solved)
	gate_low["tide_index"] = 0
	check(bool(Tracer.trace(gate_chart, gate_low)["boats"]["Hb"]) and not Tracer.trace(gate_chart, gate_low)["docks"]["D"].has("white"), "chart 76 dry shutter stops the beam and the lower lamp wakes the hull")
	var gate_north := Charts.duplicate_state(gate_solved)
	gate_north["pieces"]["V"]["rot"] = 0
	check(bool(Tracer.trace(gate_chart, gate_north)["boats"]["Ha"]) and not Tracer.is_cleared(gate_chart, gate_north), "chart 76 vane facing north wakes the hull")
	var gate_feed := Charts.duplicate_state(gate_solved)
	gate_feed["pieces"]["M"]["rot"] = 0
	check(bool(Tracer.trace(gate_chart, gate_feed)["boats"]["Hm"]), "chart 76 feed mirror turned north wakes the hull")
	var sunk: Dictionary = Charts.vane()[5]
	for raw_sunk in sunk["pieces"]:
		var sunk_piece: Dictionary = raw_sunk
		if str(sunk_piece["id"]) != "V":
			continue
		var sunk_socks: Array = sunk_piece["sockets"]
		var sunk_sock: Dictionary = sunk_socks[0]
		sunk_sock["y"] = 4
	var sunk_state := Charts.make_state(sunk, true)
	check(Tracer.is_flooded(sunk, sunk_state, Vector2i(3, 4)), "chart 76 vane moved onto the gate is under water")
	var sunk_hit: Dictionary = Tracer.trace(sunk, sunk_state)
	check(sunk_hit["docks"]["D"].is_empty() and not _center_hit(sunk_hit, 3, 4) and not Tracer.is_cleared(sunk, sunk_state), "a vane on chart 76's flooded row stops at the waterline")

	var held: Dictionary = book[6]
	var held_solved := Charts.make_state(held, true)
	check(int(held_solved["tide_index"]) == 1, "chart 77 is authored at mid water")
	check(not Tracer.is_flooded(held, held_solved, Vector2i(3, 4)), "chart 77 vane is dry at the middle mark")
	var held_hit: Dictionary = Tracer.trace(held, held_solved)
	check(held_hit["docks"]["D"].has("white") and not bool(held_hit["boats"]["Hm"]) and not bool(held_hit["boats"]["Ha"]) and not bool(held_hit["boats"]["Hb"]), "chart 77 middle mark turns the beam and holds the dock")
	var held_low := Charts.duplicate_state(held_solved)
	held_low["tide_index"] = 0
	check(bool(Tracer.trace(held, held_low)["boats"]["Hb"]) and not Tracer.is_cleared(held, held_low), "chart 77 low water is the wrong tide")
	var held_high := Charts.duplicate_state(held_solved)
	held_high["tide_index"] = 2
	check(Tracer.is_flooded(held, held_high, Vector2i(5, 4)) and not Tracer.trace(held, held_high)["docks"]["D"].has("white") and not Tracer.is_cleared(held, held_high), "chart 77 high water covers the dock")
	var held_north := Charts.duplicate_state(held_solved)
	held_north["pieces"]["V"]["rot"] = 0
	check(bool(Tracer.trace(held, held_north)["boats"]["Ha"]) and not Tracer.is_cleared(held, held_north), "chart 77 vane facing north wakes the hull")
	var held_feed := Charts.duplicate_state(held_solved)
	held_feed["pieces"]["M"]["rot"] = 0
	check(bool(Tracer.trace(held, held_feed)["boats"]["Hm"]), "chart 77 feed mirror turned north wakes the hull")
	for raw_held in _clears(held):
		var held_state: Dictionary = raw_held
		check(int(held_state["tide_index"]) == 1, "every chart 77 clear is mid water")

	var mark: Dictionary = book[7]
	var mark_start := Charts.make_state(mark, false)
	check(str(mark_start["pieces"]["P"]["socket"]) == "side", "chart 78 prism starts off the beam")
	check(int(mark_start["pieces"]["K"]["rot"]) == 90, "chart 78 stain starts blue")
	check(int(mark_start["pieces"]["V"]["rot"]) == 0, "chart 78 vane starts facing north")
	var mark_solved := Charts.make_state(mark, true)
	check(int(mark_solved["tide_index"]) == 1 and str(mark_solved["pieces"]["P"]["socket"]) == "line", "chart 78 solution moves the prism and holds mid water")
	check(int(mark_solved["pieces"]["K"]["rot"]) == 0 and int(mark_solved["pieces"]["V"]["rot"]) == 90, "chart 78 solution clicks the stain and faces the vane east")
	var mark_hit: Dictionary = Tracer.trace(mark, mark_solved)
	check(mark_hit["docks"]["Rn"].has("red") and mark_hit["docks"]["Rs"].has("red") and mark_hit["docks"]["Rs"].size() == 1, "chart 78 lands red on both docks")
	check(not bool(mark_hit["boats"]["Hw"]) and not bool(mark_hit["boats"]["Hb"]) and not bool(mark_hit["boats"]["Ha"]), "chart 78 solution leaves every hull dark")
	var mark_side := Charts.duplicate_state(mark_solved)
	mark_side["pieces"]["P"]["socket"] = "side"
	check(bool(Tracer.trace(mark, mark_side)["boats"]["Hw"]) and not Tracer.trace(mark, mark_side)["docks"]["Rn"].has("red"), "chart 78 side socket lets white wake the hull")
	var mark_blue := Charts.duplicate_state(mark_solved)
	mark_blue["pieces"]["K"]["rot"] = 90
	var mark_blue_hit: Dictionary = Tracer.trace(mark, mark_blue)
	check(mark_blue_hit["docks"]["Rn"].has("red") and mark_blue_hit["docks"]["Rs"].has("blue") and not Tracer.is_cleared(mark, mark_blue), "chart 78 unclicked stain fails the lower dock")
	var mark_north := Charts.duplicate_state(mark_solved)
	mark_north["pieces"]["V"]["rot"] = 0
	check(bool(Tracer.trace(mark, mark_north)["boats"]["Ha"]) and not Tracer.trace(mark, mark_north)["docks"]["Rs"].has("red"), "chart 78 vane facing north wakes the hull and misses the dock")
	var mark_low := Charts.duplicate_state(mark_solved)
	mark_low["tide_index"] = 0
	check(bool(Tracer.trace(mark, mark_low)["boats"]["Hb"]) and Tracer.trace(mark, mark_low)["docks"]["Rn"].has("red") and not Tracer.is_cleared(mark, mark_low), "chart 78 low water is the wrong tide")
	var mark_high := Charts.duplicate_state(mark_solved)
	mark_high["tide_index"] = 2
	check(Tracer.trace(mark, mark_high)["docks"]["Rn"].has("red") and not Tracer.trace(mark, mark_high)["docks"]["Rs"].has("red") and not Tracer.is_cleared(mark, mark_high), "chart 78 high water covers the lower dock")
	var mark_face := Charts.duplicate_state(mark_solved)
	mark_face["pieces"]["P"]["rot"] = 0
	check(Tracer.trace(mark, mark_face)["docks"]["Rn"].is_empty() and Tracer.trace(mark, mark_face)["docks"]["Rs"].is_empty(), "chart 78 north face absorbs the east beam")
	for raw_mark in _clears(mark):
		var mark_clear: Dictionary = raw_mark
		check(int(mark_clear["tide_index"]) == 1, "every chart 78 clear is mid water")


func test_well_rule() -> void:
	check(Tracer.norm_rot("well", 0) == 0 and Tracer.norm_rot("well", 90) == 0, "a well ignores a quarter turn")
	check(Tracer.norm_rot("well", 180) == 0 and Tracer.norm_rot("well", 270) == 0, "a well ignores a half turn")
	check(Tracer.turn_rot("well", 0) == 0 and Tracer.turn_rot("well", 90) == 0, "clicking a well does not turn it")
	check(Tracer.turn_rot("well", 270) == 0, "a well click does not walk a facing")
	var hinted: Dictionary = Charts.well()[0]
	var spun := Charts.make_state(hinted, true)
	spun["pieces"]["W"]["rot"] = 270
	check(Hints.first_wrong(hinted, spun) == "", "a hint does not call a well wrong for its rotation")
	var mirror_off := Charts.duplicate_state(spun)
	mirror_off["pieces"]["M"]["rot"] = 90
	var mirror_wrong := Hints.wrong_pieces(hinted, mirror_off)
	check(mirror_wrong.has("M") and not mirror_wrong.has("W"), "a wrong mirror is marked and the well's rotation is not")

	var dry := _blank(5, 4)
	dry["lanterns"] = [_lamp("L", 0, 1, "E", "red")]
	dry["docks"] = [_need("E", 4, 1, "red"), _need("N", 2, 0, "red")]
	dry["pieces"] = [_fixed_well("W", 2, 1)]
	var dry_hit: Dictionary = Tracer.trace(dry, Charts.make_state(dry, true))
	check(dry_hit["docks"]["E"].is_empty() and dry_hit["docks"]["N"].is_empty(), "a dry well stops the beam")
	check(_center_hit(dry_hit, 2, 1) and not _departs(dry_hit, 2, 1, "red"), "a dry well does not pass")
	check(not _center_hit(dry_hit, 3, 1) and _segments_are(dry_hit, "red"), "a dry stop keeps the color and does not leave the cell")

	var back := _blank(5, 5)
	back["tide_phases"] = [0, 2]
	back["solution_tide_index"] = 1
	back["lanterns"] = [_lamp("L", 2, 1, "S", "blue")]
	back["docks"] = [_need("S", 2, 4, "blue"), _need("N", 2, 0, "blue")]
	back["pieces"] = [_fixed_well("W", 2, 3)]
	var wet := Charts.make_state(back, true)
	check(Tracer.is_flooded(back, wet, Vector2i(2, 3)), "the sample well is under water")
	var back_hit: Dictionary = Tracer.trace(back, wet)
	check(_leaves(back_hit, 2, 3, "N", "blue"), "a southbound beam leaves the well traveling north")
	check(not _leaves(back_hit, 2, 3, "S", "blue") and back_hit["docks"]["S"].is_empty(), "the arrival direction does not keep the beam going south")
	check(_segments_are(back_hit, "blue") and back_hit["docks"]["N"].is_empty(), "the north exit keeps its color and the lantern stops the return")
	var back_dry := Charts.duplicate_state(wet)
	back_dry["tide_index"] = 0
	var back_dry_hit: Dictionary = Tracer.trace(back, back_dry)
	check(not _departs(back_dry_hit, 2, 3, "blue") and back_dry_hit["docks"]["S"].is_empty(), "the same well stops while its row is dry")

	var east := _blank(6, 6)
	east["tide_phases"] = [2]
	east["lanterns"] = [_lamp("L", 5, 3, "W", "red")]
	east["docks"] = [_need("D", 2, 0, "red"), _need("S", 2, 5, "red")]
	east["fixtures"] = [
		{"id": "M", "kind": "mirror", "x": 4, "y": 3, "rot": 0},
		{"id": "T", "kind": "tide_mirror", "x": 4, "y": 4, "rot": 0},
		{"id": "G", "kind": "shutter", "x": 3, "y": 4, "rot": 0},
	]
	east["pieces"] = [_fixed_well("W", 2, 4)]
	var east_hit: Dictionary = Tracer.trace(east, Charts.make_state(east, true))
	check(_arrives_from(east_hit, 2, 4, "W", "red") and _leaves(east_hit, 2, 4, "N", "red"), "a beam from the east leaves north")
	check(east_hit["docks"]["D"].has("red") and east_hit["docks"]["D"].size() == 1, "the north exit keeps a single color")
	check(east_hit["docks"]["S"].is_empty() and not _leaves(east_hit, 2, 4, "W", "red"), "the arrival direction does not pick the exit")

	var covered := _blank(6, 5)
	covered["tide_phases"] = [2]
	covered["lanterns"] = [_lamp("L", 5, 2, "W", "white")]
	covered["docks"] = [_need("D", 2, 3, "white")]
	covered["fixtures"] = [
		{"id": "M", "kind": "mirror", "x": 4, "y": 2, "rot": 0},
		{"id": "Gs", "kind": "shutter", "x": 4, "y": 3, "rot": 0},
		{"id": "T", "kind": "tide_mirror", "x": 4, "y": 4, "rot": 0},
		{"id": "Gw", "kind": "shutter", "x": 3, "y": 4, "rot": 0},
	]
	covered["pieces"] = [_fixed_well("W", 2, 4)]
	var covered_hit: Dictionary = Tracer.trace(covered, Charts.make_state(covered, true))
	check(covered_hit["docks"]["D"].is_empty() and not _center_hit(covered_hit, 2, 3), "a flooded dock still stops the beam at the waterline")
	covered["pieces"] = [_fixed_vane("V", 2, 3, 180)]
	covered["docks"] = [_need("D", 2, 0, "white")]
	# The well has to stay, or the feed never turns north into the vane.
	covered["pieces"] = [_fixed_well("W", 2, 4), _fixed_vane("V", 2, 3, 180)]
	var vane_block: Dictionary = Tracer.trace(covered, Charts.make_state(covered, true))
	check(not _center_hit(vane_block, 2, 3) and vane_block["docks"]["D"].is_empty(), "a flooded vane still does not enter")
	covered["pieces"] = [_fixed_well("W", 2, 4), _fixed_shutter("G", 2, 3)]
	covered["docks"] = [_need("D", 2, 0, "white")]
	var opened: Dictionary = Tracer.trace(covered, Charts.make_state(covered, true))
	check(_center_hit(opened, 2, 3) and opened["docks"]["D"].has("white"), "a flooded shutter north of a well still passes")

	var chain15 := _well_climb(15)
	var chain16 := _well_climb(16)
	check(Tracer.trace(chain15, Charts.make_state(chain15, true))["docks"]["D"].has("white"), "fifteen wells still pay their bounces and reach the dock")
	check(Tracer.trace(chain16, Charts.make_state(chain16, true))["docks"]["D"].is_empty(), "the sixteenth well spends the last bounce")


func test_well_book() -> void:
	var book: Array = Charts.well()
	check(book.size() == 8, "well book has eight charts")
	var titles := ["The North Well", "Side Entry", "After the Color", "Dry Stop", "Two Wells", "Above the Gate", "The Held Well", "The Well Mark"]
	var solution_tides := [1, 0, 0, 0, 0, 1, 1, 1]
	for i in book.size():
		var chart: Dictionary = book[i]
		check(str(chart["id"]) == str(i + 79), "well chart %d keeps its number" % (i + 79))
		check(str(chart["title"]) == str(titles[i]), "well chart %d keeps its title" % (i + 79))
		check(str(chart["harbor"]) == Charts.WELL, "chart %s belongs to the well" % str(chart["id"]))
		check(int(chart["solution_tide_index"]) == int(solution_tides[i]), "chart %s keeps its clearing tide" % str(chart["id"]))
		var well_count := 0
		for raw_piece in chart["pieces"]:
			var piece: Dictionary = raw_piece
			if str(piece["kind"]) == "well":
				well_count += 1
		check(well_count >= 1, "chart %s needs the well" % str(chart["id"]))
		var tides := {}
		for raw_clear in _clears(chart):
			var clearing: Dictionary = raw_clear
			tides[int(clearing["tide_index"])] = true
		check(tides.size() == 1 and tides.has(int(solution_tides[i])), "chart %s has one clearing tide" % str(chart["id"]))
		for kind in ["vane", "stain"]:
			for raw_piece in chart["pieces"]:
				var piece: Dictionary = raw_piece
				if str(piece["kind"]) != "well":
					continue
				var replaced: Dictionary = Charts.well()[i]
				_retarget(replaced, str(piece["id"]), kind, 0)
				check(not Tracer.is_cleared(replaced, Charts.make_state(replaced, true)), "a %s cannot replace %s on chart %s" % [kind, str(piece["id"]), str(chart["id"])])
		if str(chart["id"]) != "82":
			for raw_piece in chart["pieces"]:
				var piece: Dictionary = raw_piece
				if str(piece["kind"]) != "well":
					continue
				var replaced: Dictionary = Charts.well()[i]
				_retarget(replaced, str(piece["id"]), "shutter", 0)
				check(not Tracer.is_cleared(replaced, Charts.make_state(replaced, true)), "a shutter cannot replace %s on chart %s" % [str(piece["id"]), str(chart["id"])])
	check(str(book[0]["teach"]).to_lower().contains("does not split"), "chart 79 teaches that a well does not split")
	check(str(book[0]["teach"]).to_lower().contains("shutter"), "chart 79 teaches the shutter difference")
	check(str(book[0]["teach"]).to_lower().contains("vane"), "chart 79 teaches the vane difference")
	check(str(book[0]["teach"]).to_lower().contains("waterline"), "chart 79 teaches the waterline")
	check(str(book[1]["teach"]).to_lower().contains("arrives from the east"), "chart 80 teaches the eastern arrival")
	check(str(book[1]["teach"]).to_lower().contains("does not pick the exit"), "chart 80 teaches that arrival does not pick the exit")
	check(str(book[2]["teach"]).to_lower().contains("does not recolor"), "chart 81 teaches that a well does not recolor")
	check(str(book[3]["teach"]).to_lower().contains("dry phase"), "chart 82 names the dry phase")
	check(str(book[4]["teach"]).to_lower().contains("either well"), "chart 83 teaches either well")
	check(str(book[5]["teach"]).to_lower().contains("does not cover the dock"), "chart 84 teaches the uncovered dock")
	check(str(book[6]["teach"]).to_lower().contains("middle"), "chart 85 teaches the middle flood")
	check(str(book[6]["teach"]).to_lower().contains("wrong tide"), "chart 85 warns about the wrong tide")
	check(str(book[7]["teach"]).to_lower().contains("other color"), "chart 86 teaches the other color")
	for raw_old in Charts.all().slice(0, 78):
		var older: Dictionary = raw_old
		for raw_piece in older["pieces"]:
			var older_piece: Dictionary = raw_piece
			check(str(older_piece["kind"]) != "well", "chart %s keeps its pieces" % str(older["id"]))
		for raw_fix in older["fixtures"]:
			var older_fix: Dictionary = raw_fix
			check(str(older_fix["kind"]) != "well", "chart %s keeps its fixed glass" % str(older["id"]))

	var north: Dictionary = book[0]
	var north_solved := Charts.make_state(north, true)
	check(int(north_solved["tide_index"]) == 1 and int(north_solved["pieces"]["M"]["rot"]) == 0, "chart 79 solution turns the mirror and raises the tide")
	check(Tracer.is_flooded(north, north_solved, Vector2i(2, 4)) and not Tracer.is_flooded(north, north_solved, Vector2i(2, 0)), "chart 79 flood covers the well and not the dock")
	var north_hit: Dictionary = Tracer.trace(north, north_solved)
	check(north_hit["docks"]["D"].has("white") and north_hit["docks"]["D"].size() == 1, "chart 79 lands white on the dock")
	check(not bool(north_hit["boats"]["Hn"]) and not bool(north_hit["boats"]["Hs"]), "chart 79 solution leaves both hulls dark")
	check(_leaves(north_hit, 2, 4, "N", "white") and _center_hit(north_hit, 2, 0), "chart 79 leaves the well heading north")
	var north_dry := Charts.duplicate_state(north_solved)
	north_dry["tide_index"] = 0
	var north_dry_hit: Dictionary = Tracer.trace(north, north_dry)
	check(not Tracer.is_flooded(north, north_dry, Vector2i(2, 4)), "chart 79 low water leaves the well dry")
	check(_center_hit(north_dry_hit, 2, 4) and not _departs(north_dry_hit, 2, 4, "white"), "chart 79 dry reading of the well stops")
	check(north_dry_hit["docks"]["D"].is_empty() and bool(north_dry_hit["boats"]["Hs"]) and not Tracer.is_cleared(north, north_dry), "chart 79 dry phase misses the dock and wakes the hull")
	var north_shut: Dictionary = Charts.well()[0]
	_retarget(north_shut, "W", "shutter", 0)
	var north_shut_hit: Dictionary = Tracer.trace(north_shut, Charts.make_state(north_shut, true))
	check(north_shut_hit["docks"]["D"].is_empty() and _departs(north_shut_hit, 2, 4, "white") and not _leaves(north_shut_hit, 2, 4, "N", "white"), "a shutter in chart 79 passes in the arrival direction and misses")
	var north_vane: Dictionary = Charts.well()[0]
	_retarget(north_vane, "W", "vane", 180)
	var north_vane_hit: Dictionary = Tracer.trace(north_vane, Charts.make_state(north_vane, true))
	check(not _center_hit(north_vane_hit, 2, 4) and north_vane_hit["docks"]["D"].is_empty() and not Tracer.is_cleared(north_vane, Charts.make_state(north_vane, true)), "a vane in chart 79 is shut by the flood")

	var side: Dictionary = book[1]
	var side_hit: Dictionary = Tracer.trace(side, Charts.make_state(side, true))
	check(_arrives_from(side_hit, 2, 4, "W", "white") and _leaves(side_hit, 2, 4, "N", "white"), "chart 80 arrives from the east and leaves north")
	check(side_hit["docks"]["D"].has("white") and side_hit["docks"]["D"].size() == 1 and not bool(side_hit["boats"]["Ht"]) and not bool(side_hit["boats"]["Hn"]), "chart 80 lands on the dock and leaves the trap dark")
	var side_shut: Dictionary = Charts.well()[1]
	_retarget(side_shut, "W", "shutter", 0)
	var side_shut_hit: Dictionary = Tracer.trace(side_shut, Charts.make_state(side_shut, true))
	check(bool(side_shut_hit["boats"]["Ht"]) and side_shut_hit["docks"]["D"].is_empty(), "chart 80's shutter keeps going west into the hull")

	var color: Dictionary = book[2]
	var color_start := Charts.make_state(color, false)
	check(int(color_start["pieces"]["K"]["rot"]) == 90, "chart 81 stain starts blue")
	var color_solved := Charts.make_state(color, true)
	var color_hit: Dictionary = Tracer.trace(color, color_solved)
	check(color_hit["docks"]["Rd"].has("red") and color_hit["docks"]["Rd"].size() == 1, "chart 81 carries red north onto the dock")
	check(_arrives(color_hit, 2, 4, "red") and _leaves(color_hit, 2, 4, "N", "red"), "chart 81 well keeps the stain's red")
	var color_blue := Charts.duplicate_state(color_solved)
	color_blue["pieces"]["K"]["rot"] = 90
	check(Tracer.trace(color, color_blue)["docks"]["Rd"].has("blue") and not Tracer.is_cleared(color, color_blue), "chart 81 blue does not satisfy the red dock")

	var dry: Dictionary = book[3]
	var dry_solved := Charts.make_state(dry, true)
	check(int(dry_solved["tide_index"]) == 0 and not Tracer.is_flooded(dry, dry_solved, Vector2i(2, 4)), "chart 82 solution is the dry phase")
	var dry_hit: Dictionary = Tracer.trace(dry, dry_solved)
	check(dry_hit["docks"]["D"].has("white") and not bool(dry_hit["boats"]["Hn"]) and not bool(dry_hit["boats"]["He"]) and not bool(dry_hit["boats"]["Ht"]) and not bool(dry_hit["boats"]["Hs"]) and not bool(dry_hit["boats"]["Hm"]), "chart 82 dry well keeps every hull dark")
	check(_center_hit(dry_hit, 2, 4) and not _departs(dry_hit, 2, 4, "white"), "chart 82 dry well stops the beam that would reach the hull")
	var dry_flood := Charts.duplicate_state(dry_solved)
	dry_flood["tide_index"] = 1
	var dry_flood_hit: Dictionary = Tracer.trace(dry, dry_flood)
	check(Tracer.is_flooded(dry, dry_flood, Vector2i(2, 4)) and bool(dry_flood_hit["boats"]["Hn"]) and not Tracer.is_cleared(dry, dry_flood), "chart 82 flood lifts the beam onto the hull")
	var dry_stain: Dictionary = Charts.well()[3]
	_retarget(dry_stain, "W", "stain", 0)
	check(bool(Tracer.trace(dry_stain, Charts.make_state(dry_stain, true))["boats"]["He"]) and not Tracer.is_cleared(dry_stain, Charts.make_state(dry_stain, true)), "a stain in chart 82 lets the beam reach the hull")
	var dry_vane: Dictionary = Charts.well()[3]
	_retarget(dry_vane, "W", "vane", 0)
	check(bool(Tracer.trace(dry_vane, Charts.make_state(dry_vane, true))["boats"]["Hn"]) and not Tracer.is_cleared(dry_vane, Charts.make_state(dry_vane, true)), "a north-facing vane in chart 82 sends the beam into the hull")
	var dry_east: Dictionary = Charts.well()[3]
	_retarget(dry_east, "W", "vane", 90)
	check(bool(Tracer.trace(dry_east, Charts.make_state(dry_east, true))["boats"]["He"]) and not Tracer.is_cleared(dry_east, Charts.make_state(dry_east, true)), "an east-facing vane in chart 82 lets the beam reach the hull")
	var dry_south: Dictionary = Charts.well()[3]
	_retarget(dry_south, "W", "vane", 180)
	check(bool(Tracer.trace(dry_south, Charts.make_state(dry_south, true))["boats"]["Hs"]) and not Tracer.is_cleared(dry_south, Charts.make_state(dry_south, true)), "a south-facing vane in chart 82 sends the beam into the hull")
	var dry_head: Dictionary = Charts.well()[3]
	_retarget(dry_head, "W", "vane", 270)
	check(Tracer.is_cleared(dry_head, Charts.make_state(dry_head, true)), "a head-on vane stops the same dry beam a well stops on chart 82")
	var dry_shut: Dictionary = Charts.well()[3]
	_retarget(dry_shut, "W", "shutter", 0)
	var dry_shut_solved := Charts.make_state(dry_shut, true)
	check(int(dry_shut_solved["tide_index"]) == 0 and Tracer.is_cleared(dry_shut, dry_shut_solved), "a dry shutter stops the same beam a dry well stops on chart 82")
	var dry_shut_flood := Charts.duplicate_state(dry_shut_solved)
	dry_shut_flood["tide_index"] = 1
	var dry_shut_flood_hit: Dictionary = Tracer.trace(dry_shut, dry_shut_flood)
	check(bool(dry_shut_flood_hit["boats"]["Ht"]) and not bool(dry_shut_flood_hit["boats"]["Hn"]) and not Tracer.is_cleared(dry_shut, dry_shut_flood), "chart 82's flooded shutter misses the north hull and hits the trap")

	var two: Dictionary = book[4]
	var two_hit: Dictionary = Tracer.trace(two, Charts.make_state(two, true))
	check(two_hit["docks"]["D"].has("white") and not bool(two_hit["boats"]["Hn"]), "chart 83 two wells climb onto the dock")
	check(_leaves(two_hit, 2, 5, "N", "white") and _leaves(two_hit, 4, 4, "N", "white"), "chart 83 each well leaves north")
	var two_south: Dictionary = Charts.well()[4]
	_retarget(two_south, "W1", "shutter", 0)
	check(Tracer.trace(two_south, Charts.make_state(two_south, true))["docks"]["D"].is_empty() and not Tracer.is_cleared(two_south, Charts.make_state(two_south, true)), "a shutter cannot replace chart 83's south well")
	var two_north: Dictionary = Charts.well()[4]
	_retarget(two_north, "W2", "shutter", 0)
	check(Tracer.trace(two_north, Charts.make_state(two_north, true))["docks"]["D"].is_empty() and not _leaves(Tracer.trace(two_north, Charts.make_state(two_north, true)), 4, 4, "N", "white"), "a shutter cannot replace chart 83's north well")

	var gate: Dictionary = book[5]
	var gate_solved := Charts.make_state(gate, true)
	check(int(gate_solved["tide_index"]) == 1, "chart 84 opens on the flood")
	check(Tracer.is_flooded(gate, gate_solved, Vector2i(3, 4)) and not Tracer.is_flooded(gate, gate_solved, Vector2i(3, 2)), "chart 84 flood reaches the well and does not cover the dock")
	var gate_hit: Dictionary = Tracer.trace(gate, gate_solved)
	check(gate_hit["docks"]["D"].has("white") and _center_hit(gate_hit, 3, 3) and not bool(gate_hit["boats"]["Hn"]) and not bool(gate_hit["boats"]["Hs"]), "chart 84 lifts the beam onto the dry row")
	var gate_low := Charts.duplicate_state(gate_solved)
	gate_low["tide_index"] = 0
	var gate_low_hit: Dictionary = Tracer.trace(gate, gate_low)
	check(_center_hit(gate_low_hit, 3, 4) and not _departs(gate_low_hit, 3, 4, "white") and bool(gate_low_hit["boats"]["Hs"]) and not Tracer.is_cleared(gate, gate_low), "chart 84 low water stops on the well and wakes the hull")

	var held: Dictionary = book[6]
	var held_solved := Charts.make_state(held, true)
	check(int(held_solved["tide_index"]) == 1, "chart 85 is authored at mid water")
	check(Tracer.is_flooded(held, held_solved, Vector2i(3, 5)) and not Tracer.is_flooded(held, held_solved, Vector2i(3, 4)), "chart 85 middle flood covers the well and not the dock")
	var held_hit: Dictionary = Tracer.trace(held, held_solved)
	check(held_hit["docks"]["D"].has("white") and not bool(held_hit["boats"]["Hn"]) and not bool(held_hit["boats"]["Hs"]), "chart 85 middle flood lands the beam")
	var held_low := Charts.duplicate_state(held_solved)
	held_low["tide_index"] = 0
	var held_low_hit: Dictionary = Tracer.trace(held, held_low)
	check(_center_hit(held_low_hit, 3, 5) and not _departs(held_low_hit, 3, 5, "white") and bool(held_low_hit["boats"]["Hs"]) and not Tracer.is_cleared(held, held_low), "chart 85 low water stops on the dry well")
	var held_high := Charts.duplicate_state(held_solved)
	held_high["tide_index"] = 2
	check(Tracer.is_flooded(held, held_high, Vector2i(3, 4)) and not Tracer.trace(held, held_high)["docks"]["D"].has("white") and not Tracer.is_cleared(held, held_high), "chart 85 high water covers the dock")
	for raw_held in _clears(held):
		var held_state: Dictionary = raw_held
		check(int(held_state["tide_index"]) == 1, "every chart 85 clear is the middle flood")

	var mark: Dictionary = book[7]
	var mark_start := Charts.make_state(mark, false)
	check(str(mark_start["pieces"]["P"]["socket"]) == "side", "chart 86 prism starts off the beam")
	var mark_solved := Charts.make_state(mark, true)
	check(int(mark_solved["tide_index"]) == 1 and str(mark_solved["pieces"]["P"]["socket"]) == "line" and int(mark_solved["pieces"]["P"]["rot"]) == 90, "chart 86 solution puts the prism on the beam at mid flood")
	var mark_hit: Dictionary = Tracer.trace(mark, mark_solved)
	check(mark_hit["docks"]["Bd"].has("blue") and mark_hit["docks"]["Bd"].size() == 1 and not mark_hit["docks"]["Bd"].has("red"), "chart 86 one color climbs and the other does not satisfy the dock")
	check(_leaves(mark_hit, 4, 4, "N", "blue") and not bool(mark_hit["boats"]["Hw"]) and not bool(mark_hit["boats"]["Hs"]), "chart 86 blue leaves the well north and both hulls stay dark")
	var mark_side := Charts.duplicate_state(mark_solved)
	mark_side["pieces"]["P"]["socket"] = "side"
	check(bool(Tracer.trace(mark, mark_side)["boats"]["Hw"]) and not Tracer.trace(mark, mark_side)["docks"]["Bd"].has("blue"), "chart 86 side socket lets white wake the hull")
	var mark_low := Charts.duplicate_state(mark_solved)
	mark_low["tide_index"] = 0
	check(bool(Tracer.trace(mark, mark_low)["boats"]["Hs"]) and not Tracer.is_cleared(mark, mark_low), "chart 86 low water is the wrong tide")
	var mark_face := Charts.duplicate_state(mark_solved)
	mark_face["pieces"]["P"]["rot"] = 0
	check(Tracer.trace(mark, mark_face)["docks"]["Bd"].is_empty(), "chart 86 north face absorbs the east beam")
	for raw_mark in _clears(mark):
		var mark_clear: Dictionary = raw_mark
		check(int(mark_clear["tide_index"]) == 1, "every chart 86 clear is the flood that reaches the well")


func _segments_are(result: Dictionary, color: String) -> bool:
	var segs: Array = result["segments"]
	if segs.is_empty():
		return false
	for raw in segs:
		var seg: Dictionary = raw
		if str(seg["color"]) != color:
			return false
	return true


func test_smoke() -> void:
	var main_script: Script = load("res://scripts/main.gd")
	main_script.persist_progress = false
	var packed: PackedScene = load("res://scenes/main.tscn")
	check(packed != null, "main scene loads")
	if packed == null:
		return
	var main = packed.instantiate()
	root.add_child(main)
	var teach := str(main.teach_label.text).to_lower()
	check(teach.contains("turn"), "chart 1 teaches turn")
	check(teach.contains("press r"), "chart 1 teaches R")
	check(teach.contains("tide"), "chart 1 teaches tide")
	check(teach.contains("lock"), "chart 1 teaches lock")
	check(teach.contains("hint"), "chart 1 teaches hint")
	check(str(main.chart["id"]) == "1", "game opens on chart 1")
	check(main.unlocked[0] and not main.unlocked[1], "only chart 1 starts unlocked")
	check(not main.raise_button.visible, "chart 1 has no tide lever")
	var stuck: int = main.chart_index
	check(not main.select_chart(2), "a locked chart stays shut")
	check(main.chart_index == stuck, "selecting a locked chart does not switch")
	check(not main.select_chart(6), "a locked reach chart stays shut")
	check(main.chart_index == stuck, "a locked reach chart does not switch")
	check(main.reach_book_button.disabled, "the reach book starts locked")
	main._on_book_pressed(1)
	check(main.chart_index == stuck, "Reach stays shut until the quay is finished")
	check(not main.select_chart(14), "a locked basin chart stays shut")
	check(main.chart_index == stuck, "a locked basin chart does not switch")
	check(main.basin_book_button.disabled, "the basin book starts locked")
	main._on_book_pressed(2)
	check(main.chart_index == stuck, "Basin stays shut until the reach is finished")
	check(not main.select_chart(22), "a locked painted chart stays shut")
	check(main.chart_index == stuck, "a locked painted chart does not switch")
	check(main.paint_book_button.disabled, "the painted lock starts locked")
	main._on_book_pressed(3)
	check(main.chart_index == stuck, "Paint stays shut until the basin is finished")
	check(str(main.status_label.text).to_lower().contains("painted"), "a locked painted lock is named")
	check(not main.select_chart(30), "a locked west chart stays shut")
	check(main.chart_index == stuck, "a locked west chart does not switch")
	check(main.west_book_button.disabled, "the west return starts locked")
	main._on_book_pressed(4)
	check(main.chart_index == stuck, "West stays shut until the painted lock is finished")
	check(str(main.status_label.text).to_lower().contains("west"), "a locked west return is named")
	check(not main.select_chart(38), "a locked meeting chart stays shut")
	check(main.chart_index == stuck, "a locked meeting chart does not switch")
	check(main.meet_book_button.disabled, "the meeting glass starts locked")
	main._on_book_pressed(5)
	check(main.chart_index == stuck, "Meet stays shut until the west return is finished")
	check(str(main.status_label.text).to_lower().contains("meeting"), "a locked meeting glass is named")
	check(not main.select_chart(46), "a locked tide chart stays shut")
	check(main.chart_index == stuck, "a locked tide chart does not switch")
	check(main.tide_book_button.disabled, "the tide mirror starts locked")
	main._on_book_pressed(6)
	check(main.chart_index == stuck, "Tide stays shut until the meeting glass is finished")
	check(str(main.status_label.text).to_lower().contains("tide"), "a locked tide mirror is named")
	check(not main.select_chart(54), "a locked shutter chart stays shut")
	check(main.chart_index == stuck, "a locked shutter chart does not switch")
	check(main.shutter_book_button.disabled, "the shutter starts locked")
	main._on_book_pressed(7)
	check(main.chart_index == stuck, "Shutter stays shut until the tide mark is held")
	check(str(main.status_label.text).to_lower().contains("shutter"), "a locked shutter is named")
	check(not main.select_chart(62), "a locked stain chart stays shut")
	check(main.chart_index == stuck, "a locked stain chart does not switch")
	check(main.stain_book_button.disabled, "the stain starts locked")
	main._on_book_pressed(8)
	check(main.chart_index == stuck, "Stain stays shut until the shutter mark is held")
	check(str(main.status_label.text).to_lower().contains("stain"), "a locked stain is named")
	check(not main.select_chart(70), "a locked vane chart stays shut")
	check(main.chart_index == stuck, "a locked vane chart does not switch")
	check(main.vane_book_button.disabled, "the vane starts locked")
	main._on_book_pressed(9)
	check(main.chart_index == stuck, "Vane stays shut until the stain mark is held")
	check(str(main.status_label.text).to_lower().contains("vane"), "a locked vane is named")
	check(not main.select_chart(78), "a locked well chart stays shut")
	check(main.chart_index == stuck, "a locked well chart does not switch")
	check(main.well_book_button.disabled, "the well starts locked")
	main._on_book_pressed(10)
	check(main.chart_index == stuck, "Well stays shut until the vane mark is held")
	check(str(main.status_label.text).to_lower().contains("well"), "a locked well is named")
	check(main.quay_grid.visible and not main.reach_grid.visible and not main.basin_grid.visible and not main.paint_grid.visible and not main.west_grid.visible and not main.meet_grid.visible and not main.tide_grid.visible and not main.shutter_grid.visible and not main.stain_grid.visible and not main.vane_grid.visible and not main.well_grid.visible, "the quay grid is the one on screen")
	_tap(main, KEY_R)
	_tap(main, KEY_SPACE)
	check(main.board_locked, "keyboard R then Space locks chart 1")
	check(main.win_layer.visible, "win banner is visible")
	check(main.unlocked[1] and main.solved[0], "chart 1 held and chart 2 unlocked")
	check(main.board.trace["segments"].size() > 0, "the locked chart draws a beam")
	main.restart_chart()
	check(not main.board_locked and not main.win_layer.visible, "restart clears the lock banner")
	_tap(main, KEY_H)
	check(str(main.hint_highlight) == "M" and int(main.hints_left) == 2, "H marks the mirror and spends one hint")
	_tap(main, KEY_H)
	check(int(main.hints_left) == 2, "H again does not spend a second hint")
	main.state = Charts.duplicate_state(Charts.make_state(main.chart, true))
	_tap(main, KEY_H)
	check(str(main.hint_highlight) == "", "H does not mark a solved chart")
	main.unlocked[2] = true
	check(main.select_chart(2), "chart 3 opens when unlocked")
	check(str(main.chart["id"]) == "3" and main.raise_button.visible, "chart 3 shows the tide lever")
	var before: int = int(main.state["tide_index"])
	_tap(main, KEY_T)
	check(int(main.state["tide_index"]) == before + 1, "T raises the tide")
	main.unlocked[4] = true
	main.select_chart(4)
	check(str(main.state["pieces"]["P"]["socket"]) == "low", "prism starts in the low socket")
	_tap(main, KEY_M)
	check(str(main.state["pieces"]["P"]["socket"]) == "high", "M moves the prism into the high socket")
	check(not main.move_selected_to("nowhere"), "a piece cannot be placed off its sockets")
	main.unlocked[3] = true
	main.select_chart(3)
	main.state = Charts.duplicate_state(Charts.make_state(main.chart, true))
	main._refresh()
	main.try_lock()
	check(main.board_locked, "chart 4 solution locks through the game")
	main.restart_chart()
	main.try_lock()
	check(not main.board_locked, "chart 4 start does not lock")
	check(str(main.status_label.text).to_lower().contains("hull"), "a lit hull is named when lock fails")
	main.unlocked[13] = true
	check(main.select_chart(13), "chart 14 opens when unlocked")
	check(main.basin_book_button.disabled, "the basin stays locked until the holding line is held")
	main.state = Charts.duplicate_state(Charts.make_state(main.chart, true))
	main._refresh()
	main.try_lock()
	check(main.board_locked and main.unlocked[14], "holding the line opens the basin")
	main._advance_from_win()
	check(str(main.chart["id"]) == "15", "next chart from the reach enters North Light")
	check(main.basin_grid.visible and not main.reach_grid.visible and not main.quay_grid.visible and not main.paint_grid.visible and not main.west_grid.visible and not main.tide_grid.visible and not main.shutter_grid.visible and not main.stain_grid.visible and not main.vane_grid.visible, "the basin grid opens with North Light")
	check(str(main.harbor_label.text) == Charts.BASIN, "the harbor name follows the basin")
	check(not main.raise_button.visible, "chart 15 tide is fixed")
	var north_rot := int(main.state["pieces"]["P"]["rot"])
	_tap(main, KEY_R)
	check(int(main.state["pieces"]["P"]["rot"]) != north_rot, "R turns the basin prism")
	main.unlocked[21] = true
	check(main.select_chart(21), "chart 22 opens when unlocked")
	check(main.paint_book_button.disabled, "the painted lock stays locked until the basin mark is held")
	main.state = Charts.duplicate_state(Charts.make_state(main.chart, true))
	main._refresh()
	main.try_lock()
	check(main.board_locked and main.unlocked[22], "holding the basin mark opens the painted lock")
	main._advance_from_win()
	check(str(main.chart["id"]) == "23", "next chart from the basin enters Red Already")
	check(main.paint_grid.visible and not main.basin_grid.visible and not main.reach_grid.visible and not main.quay_grid.visible and not main.west_grid.visible and not main.tide_grid.visible and not main.shutter_grid.visible and not main.stain_grid.visible and not main.vane_grid.visible, "the painted grid opens with Red Already")
	check(str(main.harbor_label.text) == Charts.PAINTED, "the harbor name follows the painted lock")
	check(not main.raise_button.visible, "chart 23 tide is fixed")
	var lamp_rot := int(main.state["pieces"]["M"]["rot"])
	_tap(main, KEY_R)
	check(int(main.state["pieces"]["M"]["rot"]) != lamp_rot, "R turns the painted lock mirror")
	main.unlocked[29] = true
	check(main.select_chart(29), "chart 30 opens when unlocked")
	check(main.west_book_button.disabled, "the west return stays locked until the painted mark is held")
	main.state = Charts.duplicate_state(Charts.make_state(main.chart, true))
	main._refresh()
	main.try_lock()
	check(main.board_locked and main.unlocked[30], "holding the painted mark opens the west return")
	main._advance_from_win()
	check(str(main.chart["id"]) == "31", "next chart from the painted lock enters West Light")
	check(main.west_grid.visible and not main.paint_grid.visible and not main.basin_grid.visible and not main.reach_grid.visible and not main.quay_grid.visible and not main.meet_grid.visible and not main.tide_grid.visible and not main.shutter_grid.visible and not main.stain_grid.visible and not main.vane_grid.visible, "the west grid opens with West Light")
	check(str(main.harbor_label.text) == Charts.WEST, "the harbor name follows the west return")
	check(not main.raise_button.visible, "chart 31 tide is fixed")
	var west_rot := int(main.state["pieces"]["P"]["rot"])
	_tap(main, KEY_R)
	check(int(main.state["pieces"]["P"]["rot"]) != west_rot, "R turns the west return prism")
	main.unlocked[37] = true
	check(main.select_chart(37), "chart 38 opens when unlocked")
	check(main.meet_book_button.disabled, "the meeting glass stays locked until the return mark is held")
	main.state = Charts.duplicate_state(Charts.make_state(main.chart, true))
	main._refresh()
	main.try_lock()
	check(main.board_locked and main.unlocked[38], "holding the return mark opens the meeting glass")
	main._advance_from_win()
	check(str(main.chart["id"]) == "39", "next chart from the west return enters Two Lamps")
	check(main.meet_grid.visible and not main.west_grid.visible and not main.paint_grid.visible and not main.basin_grid.visible and not main.reach_grid.visible and not main.quay_grid.visible and not main.tide_grid.visible and not main.shutter_grid.visible and not main.stain_grid.visible and not main.vane_grid.visible, "the meeting grid opens with Two Lamps")
	check(str(main.harbor_label.text) == Charts.MEET, "the harbor name follows the meeting glass")
	check(not main.raise_button.visible, "chart 39 tide is fixed")
	var meet_rot := int(main.state["pieces"]["M"]["rot"])
	_tap(main, KEY_R)
	check(int(main.state["pieces"]["M"]["rot"]) != meet_rot, "R turns the meeting mirror")
	main.unlocked[45] = true
	check(main.select_chart(45), "chart 46 opens when unlocked")
	check(main.tide_book_button.disabled, "the tide mirror stays locked until the meeting mark is held")
	main.state = Charts.duplicate_state(Charts.make_state(main.chart, true))
	main._refresh()
	main.try_lock()
	check(main.board_locked and main.unlocked[46], "holding the meeting mark opens the tide mirror")
	main._advance_from_win()
	check(str(main.chart["id"]) == "47", "next chart from the meeting glass enters Wet Glass")
	check(main.tide_grid.visible and not main.shutter_grid.visible and not main.stain_grid.visible and not main.vane_grid.visible and not main.meet_grid.visible and not main.west_grid.visible and not main.paint_grid.visible and not main.basin_grid.visible and not main.reach_grid.visible and not main.quay_grid.visible, "the tide grid opens with Wet Glass")
	check(str(main.harbor_label.text) == Charts.TIDE, "the harbor name follows the tide mirror")
	check(main.raise_button.visible, "chart 47 shows the tide lever")
	check(int(main.state["tide_index"]) == 0, "chart 47 starts at low water")
	var tide_rot := int(main.state["pieces"]["T"]["rot"])
	_tap(main, KEY_R)
	check(int(main.state["pieces"]["T"]["rot"]) != tide_rot, "R turns the tide mirror")
	main.unlocked[53] = true
	check(main.select_chart(53), "chart 54 opens when unlocked")
	check(main.shutter_book_button.disabled, "the shutter stays locked until the tide mark is held")
	main.state = Charts.duplicate_state(Charts.make_state(main.chart, true))
	main._refresh()
	main.try_lock()
	check(main.board_locked and main.unlocked[54], "holding the tide mark opens the shutter")
	main._advance_from_win()
	check(str(main.chart["id"]) == "55", "next chart from the tide mark enters The Dry Gate")
	check(main.shutter_grid.visible and not main.tide_grid.visible and not main.stain_grid.visible and not main.vane_grid.visible, "the shutter grid opens with The Dry Gate")
	check(str(main.harbor_label.text) == Charts.SHUTTER, "the harbor name follows the shutter")
	check(main.raise_button.visible, "chart 55 shows the tide lever")
	check(int(main.state["tide_index"]) == 0, "chart 55 starts at low water")
	var shutter_rot := int(main.state["pieces"]["M"]["rot"])
	_tap(main, KEY_R)
	check(int(main.state["pieces"]["M"]["rot"]) != shutter_rot, "R turns the feed mirror on the dry gate")
	_click_cell(main, 2, 4, false)
	check(str(main.selected_id) == "G", "a click selects the shutter")
	var gate_rot := int(main.state["pieces"]["G"]["rot"])
	_click_cell(main, 2, 4, false)
	check(int(main.state["pieces"]["G"]["rot"]) == gate_rot, "a second click does not turn the shutter")
	check(str(main.status_label.text).to_lower().contains("does not turn"), "the shutter says it does not turn")
	main.unlocked[61] = true
	check(main.select_chart(61), "chart 62 opens when unlocked")
	check(main.stain_book_button.disabled, "the stain stays locked until the shutter mark is held")
	main.state = Charts.duplicate_state(Charts.make_state(main.chart, true))
	main._refresh()
	main.try_lock()
	check(main.board_locked and main.unlocked[62], "holding the shutter mark opens the stain")
	main._advance_from_win()
	check(str(main.chart["id"]) == "63", "next chart from the shutter mark enters The Red Stain")
	check(main.stain_grid.visible and not main.shutter_grid.visible and not main.vane_grid.visible, "the stain grid opens with The Red Stain")
	check(str(main.harbor_label.text) == Charts.STAIN, "the harbor name follows the stain")
	check(not main.raise_button.visible, "chart 63 tide is fixed")
	check(int(main.state["pieces"]["K"]["rot"]) == 90, "chart 63 stain starts blue")
	_click_cell(main, 2, 1, false)
	check(int(main.state["pieces"]["K"]["rot"]) == 0, "a click swaps the stain to red")
	check(str(main.status_label.text).to_lower().contains("swaps") and str(main.status_label.text).to_lower().contains("does not turn"), "the stain says it swaps and does not turn")
	_click_cell(main, 2, 1, false)
	check(int(main.state["pieces"]["K"]["rot"]) == 90, "a second click swaps the stain back to blue")
	check(main.select_chart(54), "The Dry Gate stays open")
	check(main.select_chart(46), "Wet Glass is still open")
	check(main.select_chart(30), "West Light is still open")
	for i in main.charts.size():
		main.unlocked[i] = true
	check(main.select_chart(5), "the night mark opens")
	main.state = Charts.duplicate_state(Charts.make_state(main.chart, true))
	main._refresh()
	main.try_lock()
	check(main.board_locked and main.unlocked[6], "holding the night mark opens the reach")
	main._advance_from_win()
	check(str(main.chart["id"]) == "7", "next chart from the quay enters Blue Glass")
	check(main.reach_grid.visible and not main.quay_grid.visible and not main.basin_grid.visible and not main.paint_grid.visible and not main.west_grid.visible and not main.meet_grid.visible and not main.tide_grid.visible and not main.shutter_grid.visible and not main.stain_grid.visible and not main.vane_grid.visible, "the reach grid opens with Blue Glass")
	check(str(main.harbor_label.text) == Charts.REACH, "the harbor name follows the reach")
	check(not main.raise_button.visible, "chart 7 tide is fixed")
	var pane_rot := int(main.state["pieces"]["C"]["rot"])
	_tap(main, KEY_R)
	check(int(main.state["pieces"]["C"]["rot"]) != pane_rot, "R turns the reach pane")
	_tap(main, KEY_T, true)
	check(int(main.state["tide_index"]) == 0, "Shift+T does not move a fixed tide")
	main._on_book_pressed(0)
	check(str(main.chart["id"]) == "6", "Quay returns to the chart that was open")
	check(main.quay_grid.visible and not main.reach_grid.visible and not main.paint_grid.visible, "Quay shows the quay grid")
	main._on_book_pressed(1)
	check(str(main.chart["id"]) == "7", "Reach returns to Blue Glass")
	check(main.select_chart(7), "chart 8 opens")
	check(main.raise_button.visible and main.lower_button.visible, "chart 8 shows both tide levers")
	check(int(main.state["tide_index"]) == 0, "chart 8 starts at low water")
	_tap(main, KEY_T)
	check(int(main.state["tide_index"]) == 1, "T raises to the middle mark")
	_tap(main, KEY_T)
	check(int(main.state["tide_index"]) == 2, "T raises to high water")
	_tap(main, KEY_T, true)
	check(int(main.state["tide_index"]) == 1, "Shift+T lowers the tide")
	check(main.select_chart(13), "the holding line opens")
	check(str(main.chart["id"]) == "14" and main.raise_button.visible, "chart 14 is the reach capstone")
	check(main.select_chart(14), "north light opens from the chart list")
	check(main.basin_grid.visible and str(main.harbor_label.text) == Charts.BASIN, "the basin list shows North Light")
	main._on_book_pressed(1)
	check(str(main.chart["id"]) == "14", "Reach returns to the holding line")
	check(main.reach_grid.visible and not main.basin_grid.visible and not main.paint_grid.visible, "Reach shows the reach grid")
	main._on_book_pressed(2)
	check(str(main.chart["id"]) == "15", "Basin returns to North Light")
	main.select_chart(18)
	check(str(main.chart["id"]) == "19" and str(main.state["pieces"]["P"]["socket"]) == "side", "the open socket starts off the beam")
	_tap(main, KEY_M)
	check(str(main.state["pieces"]["P"]["socket"]) == "line", "M moves the basin prism into the working socket")
	main._on_book_pressed(3)
	check(str(main.chart["id"]) == "30", "Paint returns to the painted mark")
	check(main.paint_grid.visible and not main.basin_grid.visible, "Paint shows the painted grid")
	main.select_chart(23)
	check(str(main.chart["id"]) == "24" and str(main.state["pieces"]["P"]["socket"]) == "line", "the prism starts on the red lamp")
	_tap(main, KEY_M)
	check(str(main.state["pieces"]["P"]["socket"]) == "high", "M moves the prism off the red lamp")
	main._on_book_pressed(4)
	check(str(main.chart["id"]) == "31", "West returns to West Light")
	check(main.west_grid.visible and not main.paint_grid.visible, "West shows the west grid")
	main.select_chart(34)
	check(str(main.chart["id"]) == "35" and str(main.state["pieces"]["P"]["socket"]) == "lamp", "the west prism starts on the red lamp")
	_tap(main, KEY_M)
	check(str(main.state["pieces"]["P"]["socket"]) == "west", "M moves the prism onto the returning beam")
	main._on_book_pressed(5)
	check(str(main.chart["id"]) == "46", "Meet returns to the meeting mark")
	check(main.meet_grid.visible and not main.west_grid.visible, "Meet shows the meeting grid")
	main.select_chart(41)
	check(str(main.chart["id"]) == "42" and str(main.state["pieces"]["P"]["socket"]) == "lamp", "the meeting prism starts on the red lamp")
	_tap(main, KEY_M)
	check(str(main.state["pieces"]["P"]["socket"]) == "line", "M moves the prism onto the white beam")
	check(main.select_chart(45), "the meeting mark opens")
	check(str(main.chart["id"]) == "46" and main.raise_button.visible, "chart 46 is the meeting capstone")
	main._on_book_pressed(6)
	check(str(main.chart["id"]) == "47", "Tide returns to Wet Glass")
	check(main.tide_grid.visible and not main.shutter_grid.visible and not main.stain_grid.visible and not main.vane_grid.visible and not main.meet_grid.visible, "Tide shows the tide grid")
	main.select_chart(49)
	check(str(main.chart["id"]) == "50" and str(main.state["pieces"]["P"]["socket"]) == "side", "the tide prism starts off the column")
	_tap(main, KEY_M)
	check(str(main.state["pieces"]["P"]["socket"]) == "line", "M moves the prism onto the climb")
	check(main.select_chart(53), "the tide mark opens")
	check(str(main.chart["id"]) == "54" and main.raise_button.visible, "chart 54 is the tide capstone")
	main._on_book_pressed(7)
	check(str(main.chart["id"]) == "55", "Shutter returns to The Dry Gate")
	check(main.shutter_grid.visible and not main.tide_grid.visible and not main.stain_grid.visible and not main.vane_grid.visible, "Shutter shows the shutter grid")
	main.select_chart(57)
	check(str(main.chart["id"]) == "58" and str(main.state["pieces"]["P"]["socket"]) == "side", "the shutter prism starts off the climb")
	_tap(main, KEY_M)
	check(str(main.state["pieces"]["P"]["socket"]) == "line", "M moves the prism onto the gate")
	check(main.select_chart(61), "the shutter mark opens")
	check(str(main.chart["id"]) == "62" and main.raise_button.visible, "chart 62 is the shutter capstone")
	main._on_book_pressed(8)
	check(str(main.chart["id"]) == "63", "Stain returns to The Red Stain")
	check(main.stain_grid.visible and not main.shutter_grid.visible and not main.vane_grid.visible, "Stain shows the stain grid")
	main.unlocked[69] = true
	main.unlocked[70] = false
	check(main.select_chart(69), "chart 70 opens when unlocked")
	check(main.vane_book_button.disabled, "the vane stays locked until the stain mark is held")
	main.state = Charts.duplicate_state(Charts.make_state(main.chart, true))
	main._refresh()
	main.try_lock()
	check(main.board_locked and main.unlocked[70], "holding the stain mark opens the vane")
	main._advance_from_win()
	check(str(main.chart["id"]) == "71", "next chart from the stain mark enters The East Vane")
	check(main.vane_grid.visible and not main.stain_grid.visible and not main.well_grid.visible, "the vane grid opens with The East Vane")
	check(str(main.harbor_label.text) == Charts.VANE, "the harbor name follows the vane")
	check(not main.raise_button.visible, "chart 71 tide is fixed")
	check(int(main.state["pieces"]["V"]["rot"]) == 0, "chart 71 vane starts facing north")
	_click_cell(main, 2, 2, false)
	check(int(main.state["pieces"]["V"]["rot"]) == 90, "a click turns the vane from north to east")
	check(str(main.status_label.text).to_lower().contains("clockwise") and str(main.status_label.text).to_lower().contains("does not recolor"), "the vane says it turns and does not recolor")
	_click_cell(main, 2, 2, false)
	check(int(main.state["pieces"]["V"]["rot"]) == 180, "the next click faces the vane south")
	_click_cell(main, 2, 2, false)
	check(int(main.state["pieces"]["V"]["rot"]) == 270, "the next click faces the vane west")
	_click_cell(main, 2, 2, false)
	check(int(main.state["pieces"]["V"]["rot"]) == 0, "four clicks restore the north facing")
	_click_cell(main, 2, 2, false)
	check(int(main.state["pieces"]["V"]["rot"]) == 90, "the vane is east again")
	_tap(main, KEY_SPACE)
	check(main.board_locked and main.unlocked[71], "the east vane locks and opens the next chart")
	main._on_book_pressed(9)
	check(str(main.chart["id"]) == "71", "Vane returns to The East Vane")
	check(main.vane_grid.visible and not main.stain_grid.visible and not main.well_grid.visible, "Vane shows the vane grid")
	main.unlocked[77] = true
	main.unlocked[78] = false
	check(main.select_chart(77), "chart 78 opens when unlocked")
	check(main.well_book_button.disabled, "the well stays locked until the vane mark is held")
	main.state = Charts.duplicate_state(Charts.make_state(main.chart, true))
	main._refresh()
	main.try_lock()
	check(main.board_locked and main.unlocked[78], "holding the vane mark opens the well")
	main._advance_from_win()
	check(str(main.chart["id"]) == "79", "next chart from the vane mark enters The North Well")
	check(main.well_grid.visible and not main.vane_grid.visible, "the well grid opens with The North Well")
	check(str(main.harbor_label.text) == Charts.WELL, "the harbor name follows the well")
	check(main.raise_button.visible, "chart 79 shows the tide lever")
	check(int(main.state["tide_index"]) == 0, "chart 79 starts at low water")
	_click_cell(main, 2, 4, false)
	check(str(main.selected_id) == "W", "a click selects the well")
	var well_rot := int(main.state["pieces"]["W"]["rot"])
	_click_cell(main, 2, 4, false)
	check(int(main.state["pieces"]["W"]["rot"]) == well_rot, "a second click does not turn the well")
	check(str(main.status_label.text).to_lower().contains("does not turn"), "the well says it does not turn")
	_tap(main, KEY_R)
	check(int(main.state["pieces"]["W"]["rot"]) == well_rot, "R does not turn the well")
	main._on_book_pressed(10)
	check(str(main.chart["id"]) == "79", "Well returns to The North Well")
	check(main.well_grid.visible and not main.vane_grid.visible, "Well shows the well grid")
	main.select_chart(0)
	main.restart_chart()
	var before_rot := int(main.state["pieces"]["M"]["rot"])
	_click_cell(main, 2, 2, false)
	check(int(main.state["pieces"]["M"]["rot"]) != before_rot, "left click turns the selected mirror")
	_click_cell(main, 2, 2, true)
	check(int(main.state["pieces"]["M"]["rot"]) == before_rot, "right click turns the mirror back")
	main.free()

func _trace_sig(result: Dictionary) -> String:
	var parts := PackedStringArray()
	parts.append("flood=%d" % int(result["flood"]))
	var docks: Dictionary = result["docks"]
	var dock_ids: Array = docks.keys()
	dock_ids.sort()
	for dock_id in dock_ids:
		var hits: Array = docks[dock_id]
		var colors := PackedStringArray()
		for color in hits:
			colors.append(str(color))
		colors.sort()
		parts.append("dock %s=%s" % [str(dock_id), ",".join(colors)])
	var boats: Dictionary = result["boats"]
	var boat_ids: Array = boats.keys()
	boat_ids.sort()
	for boat_id in boat_ids:
		parts.append("boat %s=%s" % [str(boat_id), "1" if bool(boats[boat_id]) else "0"])
	var segs: Array = result["segments"]
	parts.append("segments=%d" % segs.size())
	for raw in segs:
		var seg: Dictionary = raw
		parts.append("%.4f,%.4f>%.4f,%.4f:%s" % [float(seg["x0"]), float(seg["y0"]), float(seg["x1"]), float(seg["y1"]), str(seg["color"])])
	return "|".join(parts)
func _clears(chart: Dictionary) -> Array:
	var found: Array = []
	for candidate in _enumerate(chart):
		if Tracer.is_cleared(chart, candidate):
			found.append(candidate)
	return found

func _enumerate(chart: Dictionary) -> Array:
	var found: Array = []
	_walk(chart, Charts.make_state(chart, false), 0, found)
	return found

func _walk(chart: Dictionary, state: Dictionary, index: int, found: Array) -> void:
	var pieces: Array = chart["pieces"]
	if index >= pieces.size():
		var phases: Array = chart["tide_phases"]
		for t in phases.size():
			var copy := Charts.duplicate_state(state)
			copy["tide_index"] = t
			found.append(copy)
		return
	var piece: Dictionary = pieces[index]
	var id := str(piece["id"])
	var kind := str(piece["kind"])
	# A shutter has no facing, so only one rotation is a distinct state.
	# A well has no facing either. Rotation is ignored.
	# A stain has no facing either, but 0 (red) and 90 (blue) are different colors.
	# A vane has four facings, the same count as a prism has faces.
	var rots: Array = [0]
	if kind == "prism" or kind == "vane":
		rots = [0, 90, 180, 270]
	elif kind != "shutter" and kind != "well":
		rots = [0, 90]
	for sock_raw in piece["sockets"]:
		var sock: Dictionary = sock_raw
		for rot in rots:
			state["pieces"][id]["socket"] = str(sock["id"])
			state["pieces"][id]["rot"] = int(rot)
			_walk(chart, state, index + 1, found)

func _same_solution(chart: Dictionary, live: Dictionary, authored: Dictionary) -> bool:
	if int(live["tide_index"]) != int(authored["tide_index"]):
		return false
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		var id := str(piece["id"])
		var kind := str(piece["kind"])
		var got: Dictionary = live["pieces"][id]
		var want: Dictionary = authored["pieces"][id]
		if str(got["socket"]) != str(want["socket"]):
			return false
		if Tracer.norm_rot(kind, int(got["rot"])) != Tracer.norm_rot(kind, int(want["rot"])):
			return false
	return true

func _solve_piece(chart: Dictionary, state: Dictionary, id: String) -> void:
	if id == "tide":
		state["tide_index"] = int(chart["solution_tide_index"])
		return
	var piece := Charts.piece_def(chart, id)
	state["pieces"][id]["rot"] = int(piece["solution_rot"])
	state["pieces"][id]["socket"] = str(piece["solution_socket"])

func _tap(node: Node, keycode: Key, shift := false) -> void:
	var event := InputEventKey.new()
	event.pressed = true
	event.echo = false
	event.keycode = keycode
	event.physical_keycode = keycode
	event.shift_pressed = shift
	node._unhandled_input(event)


func _click_cell(main, c: int, r: int, right: bool) -> void:
	var board: Node2D = main.board
	var cell_size := float(board.get("cell"))
	var local := Vector2(float(c) + 0.5, float(r) + 0.5) * cell_size
	var event := InputEventMouseButton.new()
	event.pressed = true
	event.button_index = MOUSE_BUTTON_RIGHT if right else MOUSE_BUTTON_LEFT
	event.position = board.get_global_transform_with_canvas() * local
	main._unhandled_input(event)


func _same_row(result: Dictionary, y: int) -> bool:
	var cy := float(y) + 0.5
	var segs: Array = result["segments"]
	if segs.is_empty():
		return false
	for raw in segs:
		var seg: Dictionary = raw
		if not is_equal_approx(float(seg["y0"]), cy) or not is_equal_approx(float(seg["y1"]), cy):
			return false
	return true


func _arrives(result: Dictionary, x: int, y: int, color: String) -> bool:
	var cx := float(x) + 0.5
	var cy := float(y) + 0.5
	for raw in result["segments"]:
		var seg: Dictionary = raw
		if str(seg["color"]) != color:
			continue
		if is_equal_approx(float(seg["x1"]), cx) and is_equal_approx(float(seg["y1"]), cy):
			return true
	return false


func _departs(result: Dictionary, x: int, y: int, color: String) -> bool:
	var cx := float(x) + 0.5
	var cy := float(y) + 0.5
	for raw in result["segments"]:
		var seg: Dictionary = raw
		if str(seg["color"]) != color:
			continue
		if is_equal_approx(float(seg["x0"]), cx) and is_equal_approx(float(seg["y0"]), cy):
			return true
	return false


func _retarget(chart: Dictionary, id: String, kind: String, rot: int) -> void:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["id"]) != id:
			continue
		piece["kind"] = kind
		piece["start_rot"] = rot
		piece["solution_rot"] = rot
		return


func _center_hit(result: Dictionary, x: int, y: int) -> bool:
	var cx := float(x) + 0.5
	var cy := float(y) + 0.5
	for raw in result["segments"]:
		var seg: Dictionary = raw
		var starts := is_equal_approx(float(seg["x0"]), cx) and is_equal_approx(float(seg["y0"]), cy)
		var ends := is_equal_approx(float(seg["x1"]), cx) and is_equal_approx(float(seg["y1"]), cy)
		if starts or ends:
			return true
	return false

func _fixed_stain(id: String, x: int, y: int, rot: int) -> Dictionary:
	return {
		"id": id,
		"name": "Stain",
		"kind": "stain",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": rot,
		"solution_socket": "a",
		"solution_rot": rot,
	}


func _leaves(result: Dictionary, x: int, y: int, dir: String, color: String) -> bool:
	var cx := float(x) + 0.5
	var cy := float(y) + 0.5
	var nx := cx
	var ny := cy
	match dir:
		"N":
			ny -= 1.0
		"S":
			ny += 1.0
		"E":
			nx += 1.0
		"W":
			nx -= 1.0
	for raw in result["segments"]:
		var seg: Dictionary = raw
		if str(seg["color"]) != color:
			continue
		if is_equal_approx(float(seg["x0"]), cx) and is_equal_approx(float(seg["y0"]), cy):
			if is_equal_approx(float(seg["x1"]), nx) and is_equal_approx(float(seg["y1"]), ny):
				return true
	return false


func _arrives_from(result: Dictionary, x: int, y: int, dir: String, color: String) -> bool:
	var cx := float(x) + 0.5
	var cy := float(y) + 0.5
	var px := cx
	var py := cy
	match dir:
		"N":
			py += 1.0
		"S":
			py -= 1.0
		"E":
			px -= 1.0
		"W":
			px += 1.0
	for raw in result["segments"]:
		var seg: Dictionary = raw
		if str(seg["color"]) != color:
			continue
		if is_equal_approx(float(seg["x1"]), cx) and is_equal_approx(float(seg["y1"]), cy):
			if is_equal_approx(float(seg["x0"]), px) and is_equal_approx(float(seg["y0"]), py):
				return true
	return false


func _well_climb(well_count: int) -> Dictionary:
	# One tide-mirror bounce, then one bounce per well. Fifteen wells still
	# reach the dock. Sixteen spend the cap before the dock.
	var south := well_count + 1
	var chart := _blank(3, south + 1)
	chart["tide_phases"] = [south + 1 - 2]
	chart["lanterns"] = [_lamp("L", 2, 1, "S", "white")]
	chart["docks"] = [_need("D", 1, 0, "white")]
	var pieces: Array = []
	for y in range(2, south):
		pieces.append(_fixed_shutter("S%d" % y, 2, y))
	pieces.append(_fixed_tide("T", 2, south, 0))
	for y in range(2, south + 1):
		pieces.append(_fixed_well("W%d" % y, 1, y))
	chart["pieces"] = pieces
	return chart


func _fixed_well(id: String, x: int, y: int) -> Dictionary:
	return {
		"id": id,
		"name": "Well",
		"kind": "well",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": 0,
		"solution_socket": "a",
		"solution_rot": 0,
	}


func _fixed_vane(id: String, x: int, y: int, rot: int) -> Dictionary:
	return {
		"id": id,
		"name": "Vane",
		"kind": "vane",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": rot,
		"solution_socket": "a",
		"solution_rot": rot,
	}


func _fixed_shutter(id: String, x: int, y: int) -> Dictionary:
	return {
		"id": id,
		"name": "Shutter",
		"kind": "shutter",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": 0,
		"solution_socket": "a",
		"solution_rot": 0,
	}

func _fixed_tide(id: String, x: int, y: int, rot: int) -> Dictionary:
	return {
		"id": id,
		"name": "Tide mirror",
		"kind": "tide_mirror",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": rot,
		"solution_socket": "a",
		"solution_rot": rot,
	}

func _fixed_mirror(x: int, y: int, rot: int) -> Dictionary:
	return {
		"id": "M",
		"name": "Mirror",
		"kind": "mirror",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": rot,
		"solution_socket": "a",
		"solution_rot": rot,
	}

func _blank(cols: int, rows: int) -> Dictionary:
	return {
		"id": "fixture",
		"title": "Fixture",
		"teach": "",
		"win": "",
		"cols": cols,
		"rows": rows,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [],
		"docks": [],
		"boats": [],
		"fixtures": [],
		"pieces": [],
	}

func _lamp(id: String, x: int, y: int, dir: String, color: String) -> Dictionary:
	return {"id": id, "x": x, "y": y, "dir": dir, "color": color}

func _need(id: String, x: int, y: int, color: String) -> Dictionary:
	return {"id": id, "x": x, "y": y, "color": color}

func _fixed_prism(x: int, y: int, rot: int) -> Dictionary:
	return {
		"id": "P",
		"name": "Prism",
		"kind": "prism",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": rot,
		"solution_socket": "a",
		"solution_rot": rot,
	}

func _fixed_pane(x: int, y: int, rot: int) -> Dictionary:
	return {
		"id": "C",
		"name": "Pane",
		"kind": "pane",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": rot,
		"solution_socket": "a",
		"solution_rot": rot,
	}
