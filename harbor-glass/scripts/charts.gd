extends RefCounted
class_name ChartBook

# Six hand-authored charts for South Lantern Quay.
# Piece rotations are degrees. Mirrors and panes use 0 or 90 (the other two
# facings repeat). Prisms use 0, 90, 180, and 270. See BeamTracer for the
# optical meaning of each number.
#
# Every chart starts away from its solution: a wrong rotation, a wrong socket,
# or both. Tide index picks an entry of tide_phases, which is the count of
# flooded rows measured up from the bottom.

const HARBOR := "South Lantern Quay"

static func all() -> Array:
	return [chart_1(), chart_2(), chart_3(), chart_4(), chart_5(), chart_6()]

static func chart_1() -> Dictionary:
	# One mirror. "/" sends the eastbound beam north into the dock.
	# "\" dumps it south into the flooded bottom row, where it stops.
	return {
		"id": "1",
		"title": "First Glass",
		"teach": "Turn the mirror (click it, or press R) so the beam lands on the dock. The tide line shuts any glass it covers. Lock Chart (Space) checks the beams. Hint (H) marks one wrong piece, three times.",
		"win": "The dock lamp takes the beam.",
		"cols": 5,
		"rows": 5,
		"tide_phases": [1],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 2, "E", "white")],
		"docks": [_dock("D", 2, 0, "white")],
		"boats": [],
		"fixtures": [],
		"pieces": [_mirror("M", "Mirror", 2, 2, 90, 0)],
	}

static func chart_2() -> Dictionary:
	# Two mirrors route the beam up and then east, over the pilings.
	# The straight line from the lantern is open but ends in the pilings
	# only if a mirror is missing; the mirrors sit off that line and bend
	# around columns 2-4 on row 2.
	return {
		"id": "2",
		"title": "Around the Pilings",
		"teach": "Two mirrors. Bend the beam up, then east, around the pilings.",
		"win": "The beam clears the pilings.",
		"cols": 7,
		"rows": 5,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2)],
		"lanterns": [_lantern("L", 0, 3, "E", "white")],
		"docks": [_dock("D", 6, 1, "white")],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_mirror("M1", "Lower mirror", 1, 3, 90, 0),
			_mirror("M2", "Upper mirror", 1, 1, 90, 0),
		],
	}

static func chart_3() -> Dictionary:
	# Tide phases flood 0, then the bottom row, then the bottom two rows.
	# The pivot starts on the low route: "\" into the fixed glass on row 4,
	# east to the fixed glass under the dock, then north. That route lights
	# the dock only while row 4 is dry.
	# At the high-water mark (phase index 2) row 4 is shut, so the pivot must
	# turn to "/" and the high mirror must send the beam east.
	# The lower lantern shines across row 4 into the hull until that row
	# floods, so a low tide cannot lock even when the high path is already set.
	return {
		"id": "3",
		"title": "High Water",
		"teach": "Raise the tide until the low quay floods. The lower route dies, so the beam has to take the high glass. Leave the hull dark.",
		"win": "High water, and the high glass still reaches the dock.",
		"cols": 8,
		"rows": 6,
		"tide_phases": [0, 1, 2],
		"start_tide_index": 0,
		"solution_tide_index": 2,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 3, "E", "white"),
			_lantern("S", 0, 4, "E", "white"),
		],
		"docks": [_dock("D", 7, 1, "white")],
		"boats": [_boat("B", 2, 4)],
		"fixtures": [
			_fixture("HL", "mirror", 3, 4, 90),
			_fixture("G", "mirror", 7, 4, 0),
		],
		"pieces": [
			_mirror("A", "Pivot mirror", 3, 3, 90, 0),
			_mirror("H", "High mirror", 3, 1, 90, 0),
		],
	}

static func chart_4() -> Dictionary:
	# "/" sends the beam north to the dock. "\" sends it south into the hull.
	return {
		"id": "4",
		"title": "Sleeping Hull",
		"teach": "Light the dock. The sleeping hull has to stay dark.",
		"win": "The dock is lit. The hull stays asleep.",
		"cols": 5,
		"rows": 4,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 2, "E", "white")],
		"docks": [_dock("D", 1, 0, "white")],
		"boats": [_boat("B", 1, 3)],
		"fixtures": [],
		"pieces": [_mirror("M", "Mirror", 1, 2, 90, 0)],
	}

static func chart_5() -> Dictionary:
	# Prism at the high socket, rot 90: white traveling E splits.
	# Red leaves traveling N onto the red dock. Blue leaves traveling S
	# onto the blue dock. The low socket is off the lantern's row.
	# See BeamTracer.prism_ports for the exits.
	return {
		"id": "5",
		"title": "Split the White",
		"teach": "A prism splits white into red and blue. Move it into the working socket and turn it so each dock takes its color.",
		"win": "Red and blue rest on their own docks.",
		"cols": 5,
		"rows": 5,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 2, "E", "white")],
		"docks": [
			_dock("Rd", 2, 0, "red"),
			_dock("Bd", 2, 4, "blue"),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["low", 2, 3], ["high", 2, 2]], "low", 0, "high", 90),
		],
	}

static func chart_6() -> Dictionary:
	# Combined chart.
	# Prism rot 90 splits the eastbound white beam: red goes north into the
	# mirror, blue goes south and dies on the flooded bottom row.
	# The mirror's "/" sends red east through a red pane to the red dock.
	# Its "\" sends red west into the hull.
	# The pane passes only its own color, so a blue pane stops the red beam.
	# A lower lantern on the bottom row bounces north into the same hull
	# until the tide covers that row. Low tide cannot lock.
	return {
		"id": "6",
		"title": "The Night Mark",
		"teach": "Raise the tide, keep the hull dark, and let red through the pane. The pane passes only its own color.",
		"win": "Tide, color, and a dark hull. The night mark holds.",
		"cols": 7,
		"rows": 6,
		"tide_phases": [0, 1],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 4, "E", "white"),
			_lantern("S", 0, 5, "E", "white"),
		],
		"docks": [_dock("D", 6, 2, "red")],
		"boats": [_boat("B", 1, 2)],
		"fixtures": [
			_fixture("Fs", "mirror", 1, 5, 0),
		],
		"pieces": [
			_prism("P", "Prism", [["a", 2, 4]], "a", 0, "a", 90),
			_mirror("M", "Mirror", 2, 2, 90, 0),
			_pane("C", "Tinted pane", 4, 2, 90, 0),
		],
	}

static func make_state(chart: Dictionary, solved: bool) -> Dictionary:
	var pieces := {}
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		pieces[str(piece["id"])] = {
			"socket": str(piece["solution_socket"] if solved else piece["start_socket"]),
			"rot": int(piece["solution_rot"] if solved else piece["start_rot"]),
		}
	return {
		"tide_index": int(chart["solution_tide_index"] if solved else chart["start_tide_index"]),
		"pieces": pieces,
	}

static func duplicate_state(state: Dictionary) -> Dictionary:
	var pieces := {}
	var src: Dictionary = state["pieces"]
	for id in src.keys():
		var piece: Dictionary = src[id]
		pieces[str(id)] = {"socket": str(piece["socket"]), "rot": int(piece["rot"])}
	return {"tide_index": int(state["tide_index"]), "pieces": pieces}

static func piece_def(chart: Dictionary, id: String) -> Dictionary:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["id"]) == id:
			return piece
	return {}

static func piece_cell(chart: Dictionary, state: Dictionary, id: String) -> Vector2i:
	var piece := piece_def(chart, id)
	if piece.is_empty():
		return Vector2i(-1, -1)
	var pst: Dictionary = state["pieces"][id]
	return _socket_cell(piece, str(pst["socket"]))

static func placement_errors(chart: Dictionary, state: Dictionary) -> Array:
	var errors: Array = []
	var seen := {}
	var cols := int(chart["cols"])
	var rows := int(chart["rows"])
	for raw in chart["obstacles"]:
		_note_cell(raw, "obstacle", cols, rows, seen, errors)
	for raw in chart["lanterns"]:
		var lantern: Dictionary = raw
		_note_cell(Vector2i(int(lantern["x"]), int(lantern["y"])), "lantern %s" % str(lantern["id"]), cols, rows, seen, errors)
	for raw in chart["docks"]:
		var dock: Dictionary = raw
		_note_cell(Vector2i(int(dock["x"]), int(dock["y"])), "dock %s" % str(dock["id"]), cols, rows, seen, errors)
	for raw in chart["boats"]:
		var boat: Dictionary = raw
		_note_cell(Vector2i(int(boat["x"]), int(boat["y"])), "boat %s" % str(boat["id"]), cols, rows, seen, errors)
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		_note_cell(Vector2i(int(fix["x"]), int(fix["y"])), "fixture %s" % str(fix["id"]), cols, rows, seen, errors)
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		var id := str(piece["id"])
		_note_cell(piece_cell(chart, state, id), "piece %s" % id, cols, rows, seen, errors)
		var known := {}
		for sock_raw in piece["sockets"]:
			var sock: Dictionary = sock_raw
			known[str(sock["id"])] = true
		if not known.has(str(piece["start_socket"])):
			errors.append("%s missing start socket" % id)
		if not known.has(str(piece["solution_socket"])):
			errors.append("%s missing solution socket" % id)
	var phases: Array = chart["tide_phases"]
	if int(chart["start_tide_index"]) < 0 or int(chart["start_tide_index"]) >= phases.size():
		errors.append("start tide out of range")
	if int(chart["solution_tide_index"]) < 0 or int(chart["solution_tide_index"]) >= phases.size():
		errors.append("solution tide out of range")
	if int(state["tide_index"]) < 0 or int(state["tide_index"]) >= phases.size():
		errors.append("state tide out of range")
	return errors

static func _note_cell(cell: Vector2i, label: String, cols: int, rows: int, seen: Dictionary, errors: Array) -> void:
	if cell.x < 0 or cell.y < 0 or cell.x >= cols or cell.y >= rows:
		errors.append("%s out of bounds at %s" % [label, str(cell)])
		return
	var key := "%d,%d" % [cell.x, cell.y]
	if seen.has(key):
		errors.append("%s overlaps %s at %s" % [label, str(seen[key]), key])
	seen[key] = label

static func _socket_cell(piece: Dictionary, socket_id: String) -> Vector2i:
	for raw in piece["sockets"]:
		var sock: Dictionary = raw
		if str(sock["id"]) == socket_id:
			return Vector2i(int(sock["x"]), int(sock["y"]))
	return Vector2i(-1, -1)

static func _lantern(id: String, x: int, y: int, dir: String, color: String) -> Dictionary:
	return {"id": id, "x": x, "y": y, "dir": dir, "color": color}

static func _dock(id: String, x: int, y: int, color: String) -> Dictionary:
	return {"id": id, "x": x, "y": y, "color": color}

static func _boat(id: String, x: int, y: int) -> Dictionary:
	return {"id": id, "x": x, "y": y}

static func _fixture(id: String, kind: String, x: int, y: int, rot: int) -> Dictionary:
	return {"id": id, "kind": kind, "x": x, "y": y, "rot": rot}

static func _mirror(id: String, name: String, x: int, y: int, start_rot: int, sol_rot: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "mirror",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": start_rot,
		"solution_socket": "a",
		"solution_rot": sol_rot,
	}

static func _pane(id: String, name: String, x: int, y: int, start_rot: int, sol_rot: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "pane",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": start_rot,
		"solution_socket": "a",
		"solution_rot": sol_rot,
	}

static func _prism(id: String, name: String, sockets: Array, start_socket: String, start_rot: int, sol_socket: String, sol_rot: int) -> Dictionary:
	var packed: Array = []
	for raw in sockets:
		var spec: Array = raw
		packed.append({"id": str(spec[0]), "x": int(spec[1]), "y": int(spec[2])})
	return {
		"id": id,
		"name": name,
		"kind": "prism",
		"movable": packed.size() > 1,
		"sockets": packed,
		"start_socket": start_socket,
		"start_rot": start_rot,
		"solution_socket": sol_socket,
		"solution_rot": sol_rot,
	}
