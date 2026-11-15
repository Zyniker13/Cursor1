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
	check(book.size() == 46, "forty-six charts")
	check(str(book[13]["id"]) == "14" and str(book[13]["title"]) == "The Holding Line", "chart 14 stays the reach capstone")
	check(str(book[14]["title"]) == "North Light", "chart 15 opens the basin")
	check(str(book[21]["id"]) == "22" and str(book[21]["title"]) == "The Basin Mark", "chart 22 stays the basin capstone")
	check(str(book[22]["title"]) == "Red Already", "chart 23 opens the painted lock")
	check(str(book[29]["id"]) == "30" and str(book[29]["title"]) == "The Painted Mark", "chart 30 stays the painted capstone")
	check(str(book[30]["title"]) == "West Light", "chart 31 opens the west return")
	check(str(book[37]["id"]) == "38" and str(book[37]["title"]) == "The Return Mark", "chart 38 stays the west capstone")
	check(str(book[38]["title"]) == "Two Lamps", "chart 39 opens the meeting glass")
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
		check(not seen_titles.has(title), "chart title %s is unique" % title)
		seen_ids[id] = true
		seen_titles[title] = true
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
	check(main.quay_grid.visible and not main.reach_grid.visible and not main.basin_grid.visible and not main.paint_grid.visible and not main.west_grid.visible and not main.meet_grid.visible, "the quay grid is the one on screen")
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
	check(main.basin_grid.visible and not main.reach_grid.visible and not main.quay_grid.visible and not main.paint_grid.visible and not main.west_grid.visible, "the basin grid opens with North Light")
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
	check(main.paint_grid.visible and not main.basin_grid.visible and not main.reach_grid.visible and not main.quay_grid.visible and not main.west_grid.visible, "the painted grid opens with Red Already")
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
	check(main.west_grid.visible and not main.paint_grid.visible and not main.basin_grid.visible and not main.reach_grid.visible and not main.quay_grid.visible and not main.meet_grid.visible, "the west grid opens with West Light")
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
	check(main.meet_grid.visible and not main.west_grid.visible and not main.paint_grid.visible and not main.basin_grid.visible and not main.reach_grid.visible and not main.quay_grid.visible, "the meeting grid opens with Two Lamps")
	check(str(main.harbor_label.text) == Charts.MEET, "the harbor name follows the meeting glass")
	check(not main.raise_button.visible, "chart 39 tide is fixed")
	var meet_rot := int(main.state["pieces"]["M"]["rot"])
	_tap(main, KEY_R)
	check(int(main.state["pieces"]["M"]["rot"]) != meet_rot, "R turns the meeting mirror")
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
	check(main.reach_grid.visible and not main.quay_grid.visible and not main.basin_grid.visible and not main.paint_grid.visible and not main.west_grid.visible and not main.meet_grid.visible, "the reach grid opens with Blue Glass")
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
	check(str(main.chart["id"]) == "39", "Meet returns to Two Lamps")
	check(main.meet_grid.visible and not main.west_grid.visible, "Meet shows the meeting grid")
	main.select_chart(41)
	check(str(main.chart["id"]) == "42" and str(main.state["pieces"]["P"]["socket"]) == "lamp", "the meeting prism starts on the red lamp")
	_tap(main, KEY_M)
	check(str(main.state["pieces"]["P"]["socket"]) == "line", "M moves the prism onto the white beam")
	check(main.select_chart(45), "the meeting mark opens")
	check(str(main.chart["id"]) == "46" and main.raise_button.visible, "chart 46 is the meeting capstone")
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
	var rots: Array = [0, 90, 180, 270] if str(piece["kind"]) == "prism" else [0, 90]
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
