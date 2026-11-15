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
	check(book.size() == 14, "fourteen charts")
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
	check(main.quay_grid.visible and not main.reach_grid.visible, "the quay grid is the one on screen")
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
	for i in main.charts.size():
		main.unlocked[i] = true
	check(main.select_chart(5), "the night mark opens")
	main.state = Charts.duplicate_state(Charts.make_state(main.chart, true))
	main._refresh()
	main.try_lock()
	check(main.board_locked and main.unlocked[6], "holding the night mark opens the reach")
	main._advance_from_win()
	check(str(main.chart["id"]) == "7", "next chart from the quay enters Blue Glass")
	check(main.reach_grid.visible and not main.quay_grid.visible, "the reach grid opens with Blue Glass")
	check(str(main.harbor_label.text) == Charts.REACH, "the harbor name follows the reach")
	check(not main.raise_button.visible, "chart 7 tide is fixed")
	var pane_rot := int(main.state["pieces"]["C"]["rot"])
	_tap(main, KEY_R)
	check(int(main.state["pieces"]["C"]["rot"]) != pane_rot, "R turns the reach pane")
	_tap(main, KEY_T, true)
	check(int(main.state["tide_index"]) == 0, "Shift+T does not move a fixed tide")
	main._on_book_pressed(0)
	check(str(main.chart["id"]) == "6", "Quay returns to the chart that was open")
	check(main.quay_grid.visible and not main.reach_grid.visible, "Quay shows the quay grid")
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
	check(main.select_chart(main.charts.size() - 1), "the holding line opens")
	check(str(main.chart["id"]) == "14" and main.raise_button.visible, "chart 14 is the reach capstone")
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
