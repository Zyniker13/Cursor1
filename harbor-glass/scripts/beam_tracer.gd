extends RefCounted
class_name BeamTracer

# Deterministic beam tracer for Harbor Glass.
#
# The result is a pure function of the chart, the piece state, and the tide.
# Cardinal directions only. y grows downward (south), matching the board.
#
# Mirrors
# -------
# A mirror is two-sided and has two distinct orientations.
#   rot 0 and 180, drawn "/":  N->E, E->N, S->W, W->S
#   rot 90 and 270, drawn "\": N->W, W->N, S->E, E->S
#
# Prism
# -----
# Rotation is clockwise, in degrees: 0, 90, 180, 270.
# rot 0:
#   A WHITE beam traveling N (entering from the south) is consumed.
#   RED leaves traveling W.
#   BLUE leaves traveling E.
#   Nothing continues traveling N. White is not passed through.
#   Any other color is absorbed.
#   White arriving from any other direction is absorbed.
# Clockwise quarter-turns rotate the entry, the red exit, and the blue exit together:
#   rot 90:  white traveling E -> red traveling N, blue traveling S
#   rot 180: white traveling S -> red traveling E, blue traveling W
#   rot 270: white traveling W -> red traveling S, blue traveling N
#
# Tinted pane
# -----------
# Rotation selects the pass color, not an axis.
#   rot 0 and 180: red passes, every other color stops.
#   rot 90 and 270: blue passes, every other color stops.
# A passing beam keeps its direction. White is neither red nor blue, so a pane
# always blocks white. The prism is what turns white into red and blue.
#
# Tide
# ----
# tide_phases[tide_index] is how many rows, counting up from the bottom, are
# under water. A cell is flooded when y >= rows - flood_count. A flooded cell
# stops a beam at the waterline unless it is a tide mirror, a shutter, a
# stain, a well, a siphon, or a sluice. Lanterns on a flooded cell do not emit.
# Mirrors, prisms, panes, and vanes there are shut and do not act. A well is
# not shut. A siphon is not shut. A sluice is not shut.
#
# Tide mirror
# -----------
# A tide mirror is not a meeting mirror and it does not replace one.
# It has the same two facings as a mirror, and it never changes color.
#   rot 0 and 180, drawn "/":  N->E, E->N, S->W, W->S
#   rot 90 and 270, drawn "\": N->W, W->N, S->E, E->S
# It reflects only while its own row is flooded. The beam may enter that
# flooded cell. The next flooded cell that is not itself a tide mirror, a
# shutter, a stain, a well, a siphon, or a sluice still stops the beam at the waterline,
# and a flooded lantern, mirror, prism, pane, vane, dock, or hull still follows
# its own rule. A flooded vane does not enter.
# While its row is dry, a beam that hits it keeps its direction and its color.
#
# Shutter
# -------
# A shutter is not a tide mirror and it does not replace one. It has no facing
# and it never reflects. Rotation is ignored.
# While its own row is dry, a beam that hits it stops.
# While that row is flooded, the beam may enter the cell and passes straight
# through in the same direction and the same color.
# The next flooded cell that is not itself a shutter, a tide mirror, a stain,
# a well, a siphon, or a sluice still stops the beam at the waterline.
#
# Stain
# -----
# A stain is not a shutter, a pane, or a prism, and it does not replace one.
# It has a color and no facing. Rotation is ignored.
#   rot 0 and 180: red
#   rot 90 and 270: blue
# A beam that hits it continues straight in the same direction, and its color
# becomes the stain's color. White becomes that color too. It does not split
# and it does not reflect. Clicking swaps red and blue. It does not rotate.
# It does this on a dry row and on a flooded row. On a flooded row the beam
# may enter that cell, the same way it may enter a shutter, and it leaves
# recolored. The next flooded cell that is not itself a stain, a shutter, a
# tide mirror, a well, a siphon, or a sluice still stops the beam.
#
# Vane
# ----
# A vane is not a stain, a mirror, or a shutter, and it does not replace one.
# It has a facing and it never changes color. It does not split.
#   rot 0: north, rot 90: east, rot 180: south, rot 270: west
# Clicking turns that facing clockwise: north, east, south, west.
# A beam already traveling in the facing passes straight and keeps its color.
# A beam that arrives from either side leaves traveling in the facing and
# keeps its color. The entry direction does not pick the exit. The facing does.
# A beam traveling against the facing is head-on. It stops.
# On a flooded row the vane is shut, the same way a mirror is shut. The beam
# stops at the waterline and does not enter the cell. Flood does not let it
# through: a vane is not a shutter, a tide mirror, a stain, a well, a siphon,
# or a sluice.
#
# Well
# ----
# A well is not a vane, a shutter, a stain, or a tide mirror, and it does not
# replace one. It has no facing. Rotation is ignored. Clicking does nothing.
# It does not split and it does not recolor.
# While its own row is dry, a beam that hits it stops. It does not pass.
# While that row is flooded, the beam may enter the cell and leaves traveling
# north, keeping its color, no matter which way it arrived. The arrival
# direction does not pick the exit.
# The next flooded cell that is not itself a well, a siphon, a sluice, a
# shutter, a tide mirror, or a stain still stops the beam at the waterline. A
# flooded vane, mirror, prism, pane, dock, or hull still follows its own rule.
# A flooded vane does not enter. A well does.
# A well costs a bounce when it sends the beam on, the same way a vane does.
#
# Siphon
# ------
# A siphon is not a well, a vane, a shutter, a stain, or a tide mirror, and it
# does not replace one. It has no facing. Rotation is ignored. Clicking does
# nothing. It does not split.
# While its own row is dry, a beam that hits it stops. It does not pass.
# While that row is flooded, the beam may enter the cell and always leaves
# north, keeping no memory of the arrival direction. The arrival direction
# does not pick the exit. That exit costs a bounce.
# On that north exit the color flips: red becomes blue, and blue becomes red.
# White stays white. The siphon does not paint white into another color.
# It is a flood carrier, the same way a well is. The next flooded cell that is
# not itself a siphon, a well, a sluice, a shutter, a tide mirror, or a stain
# still stops the beam at the waterline. A flooded vane does not enter. A
# siphon does.
# A well keeps the color. A siphon swaps red and blue. A stain sets one chosen
# color and goes straight, dry or flooded. A shutter keeps the arrival direction.
#
# Sluice
# ------
# A sluice is not a siphon, a well, a vane, a shutter, a stain, or a tide
# mirror, and it does not replace one. It has a facing.
#   rot 0: north, rot 90: east, rot 180: south, rot 270: west
# Clicking turns that facing clockwise. A hint uses that facing.
# While its own row is dry, a beam that hits it stops, whichever way it faces.
# While that row is flooded, the beam may enter from any side and always leaves
# along the facing. The arrival direction does not pick the exit. That exit
# costs a bounce. It does not swap colors. Red stays red, blue stays blue, and
# white stays white.
# It is a flood carrier, the same way a well and a siphon are. The next flooded
# cell that is not itself a sluice, a siphon, a well, a shutter, a tide mirror,
# or a stain still stops the beam at the waterline. A flooded vane does not
# enter. A sluice does.
# A north-facing sluice is not a well and it is not a siphon. A well has no
# facing and keeps the color. A siphon has no facing and swaps red with blue.
# A sluice keeps the color, and the exit follows the facing.
#
# Docks and boats
# ---------------
# A dock records every color that enters its cell. It is satisfied only when
# its required color is among those hits. A wrong color does not satisfy it.
# Extra colors do not cancel a hit that already has the required color.
# A boat is lit if any beam of any color enters its cell.
#
# Loops
# -----
# Each mirror, prism, pane, vane, well, siphon, and sluice costs a bounce. Past MAX_BOUNCES the beam stops.
# A (cell, direction, color) triple is never entered twice, and each cast also
# stops after MAX_STEPS cells. Those caps are what make a mirror loop return.

const DIRS: PackedStringArray = ["N", "E", "S", "W"]
const MAX_BOUNCES := 16
const MAX_STEPS := 48
const MAX_SEGMENTS := 80

const VEC := {
	"N": Vector2i(0, -1),
	"E": Vector2i(1, 0),
	"S": Vector2i(0, 1),
	"W": Vector2i(-1, 0),
}

static func rotate_dir(dir: String, turns: int) -> String:
	var i := DIRS.find(dir)
	if i < 0:
		return "N"
	return DIRS[posmod(i + turns, 4)]

static func norm_rot(kind: String, rot: int) -> int:
	# A prism has four faces. A vane has four facings: 0 north, 90 east,
	# 180 south, 270 west. A sluice uses that same facing. Opposite facings
	# are not the same piece.
	if kind == "prism" or kind == "vane" or kind == "sluice":
		return posmod(rot, 360)
	# A shutter has no facing. Dry stops the beam; flooded water lets it pass.
	# A well has no facing either. Dry stops the beam; flooded water sends it north.
	# A siphon has no facing either. Dry stops the beam; flooded water sends it
	# north and swaps red with blue. White stays white.
	if kind == "shutter" or kind == "well" or kind == "siphon":
		return 0
	# A stain has no facing. 0 is red and 90 is blue; 180 and 270 repeat them.
	if kind == "stain":
		return 0 if posmod(rot, 180) == 0 else 90
	# Mirrors, tide mirrors, and panes repeat every 180 degrees.
	return posmod(rot, 180)

static func turn_rot(kind: String, rot: int) -> int:
	if kind == "shutter" or kind == "well" or kind == "siphon":
		return 0
	# Clicking swaps the color. It does not walk through a facing.
	if kind == "stain":
		return 90 if norm_rot("stain", rot) == 0 else 0
	var turned := posmod(rot + 90, 360)
	return norm_rot(kind, turned)

static func reflect(rot: int, incoming: String) -> String:
	var slash := norm_rot("mirror", rot) == 0
	if slash:
		match incoming:
			"N":
				return "E"
			"E":
				return "N"
			"S":
				return "W"
			"W":
				return "S"
	else:
		match incoming:
			"N":
				return "W"
			"E":
				return "S"
			"S":
				return "E"
			"W":
				return "N"
	return incoming

static func prism_ports(rot: int) -> Dictionary:
	var turns := posmod(int(rot / 90), 4)
	return {
		"entry": rotate_dir("N", turns),
		"red": rotate_dir("W", turns),
		"blue": rotate_dir("E", turns),
	}

static func pane_color(rot: int) -> String:
	return "red" if norm_rot("pane", rot) == 0 else "blue"

static func stain_color(rot: int) -> String:
	return "red" if norm_rot("stain", rot) == 0 else "blue"

static func siphon_color(color: String) -> String:
	# The north exit swaps the two lantern colors. White is not painted.
	if color == "red":
		return "blue"
	if color == "blue":
		return "red"
	return color

static func vane_facing(rot: int) -> String:
	return rotate_dir("N", posmod(int(rot / 90.0), 4))

static func sluice_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. The exit follows this facing.
	return rotate_dir("N", posmod(int(rot / 90.0), 4))

static func flood_count(chart: Dictionary, state: Dictionary) -> int:
	var phases: Array = chart["tide_phases"]
	if phases.is_empty():
		return 0
	var idx := clampi(int(state["tide_index"]), 0, phases.size() - 1)
	return int(phases[idx])

static func is_flooded(chart: Dictionary, state: Dictionary, cell: Vector2i) -> bool:
	var n := flood_count(chart, state)
	if n <= 0:
		return false
	return cell.y >= int(chart["rows"]) - n

# One beam, used to prove a mirror cycle dies. `start` is the first cell entered.
static func cast_beam(chart: Dictionary, state: Dictionary, start: Vector2i, dir: String, color: String) -> Dictionary:
	var occupants := _occupants(chart, state)
	var segments: Array = []
	var visited := {}
	var prev: Vector2i = start - VEC[dir]
	_cast(chart, state, occupants, start, dir, color, 0, visited, {}, {}, segments, prev)
	return {"segments": segments}

static func trace(chart: Dictionary, state: Dictionary) -> Dictionary:
	var occupants := _occupants(chart, state)
	var dock_hits := {}
	for raw_dock in chart["docks"]:
		var dock: Dictionary = raw_dock
		dock_hits[str(dock["id"])] = []
	var boat_lit := {}
	for raw_boat in chart["boats"]:
		var boat: Dictionary = raw_boat
		boat_lit[str(boat["id"])] = false
	var segments: Array = []
	var visited := {}
	for raw_lantern in chart["lanterns"]:
		var lantern: Dictionary = raw_lantern
		var origin := Vector2i(int(lantern["x"]), int(lantern["y"]))
		if is_flooded(chart, state, origin):
			continue
		var dir := str(lantern["dir"])
		var nxt: Vector2i = origin + VEC[dir]
		_cast(chart, state, occupants, nxt, dir, str(lantern["color"]), 0, visited, dock_hits, boat_lit, segments, origin)
	return {
		"docks": dock_hits,
		"boats": boat_lit,
		"segments": segments,
		"flood": flood_count(chart, state),
	}

static func failure_notes(chart: Dictionary, state: Dictionary) -> PackedStringArray:
	var result := trace(chart, state)
	var hull := false
	var dark := false
	var wrong := false
	for raw_boat in chart["boats"]:
		var boat: Dictionary = raw_boat
		if bool(result["boats"][str(boat["id"])]):
			hull = true
	for raw_dock in chart["docks"]:
		var dock: Dictionary = raw_dock
		var hits: Array = result["docks"][str(dock["id"])]
		if hits.has(str(dock["color"])):
			continue
		if hits.is_empty():
			dark = true
		else:
			wrong = true
	var notes := PackedStringArray()
	if hull:
		notes.append("A sleeping hull is still in the light.")
	if wrong:
		notes.append("A dock has the wrong color.")
	if dark:
		notes.append("A dock is still dark.")
	return notes

static func is_cleared(chart: Dictionary, state: Dictionary) -> bool:
	return failure_notes(chart, state).is_empty()

static func _occupants(chart: Dictionary, state: Dictionary) -> Dictionary:
	var map := {}
	for raw_obs in chart["obstacles"]:
		var cell: Vector2i = raw_obs
		map[cell] = {"kind": "obstacle", "id": "pile"}
	for raw_lantern in chart["lanterns"]:
		var lantern: Dictionary = raw_lantern
		map[Vector2i(int(lantern["x"]), int(lantern["y"]))] = {
			"kind": "lantern",
			"id": str(lantern["id"]),
		}
	for raw_dock in chart["docks"]:
		var dock: Dictionary = raw_dock
		map[Vector2i(int(dock["x"]), int(dock["y"]))] = {
			"kind": "dock",
			"id": str(dock["id"]),
			"color": str(dock["color"]),
		}
	for raw_boat in chart["boats"]:
		var boat: Dictionary = raw_boat
		map[Vector2i(int(boat["x"]), int(boat["y"]))] = {
			"kind": "boat",
			"id": str(boat["id"]),
		}
	for raw_fix in chart["fixtures"]:
		var fix: Dictionary = raw_fix
		map[Vector2i(int(fix["x"]), int(fix["y"]))] = {
			"kind": str(fix["kind"]),
			"id": str(fix["id"]),
			"rot": int(fix["rot"]),
		}
	var piece_state: Dictionary = state["pieces"]
	for raw_piece in chart["pieces"]:
		var piece: Dictionary = raw_piece
		var id := str(piece["id"])
		var pst: Dictionary = piece_state[id]
		var cell := _socket_cell(piece, str(pst["socket"]))
		map[cell] = {
			"kind": str(piece["kind"]),
			"id": id,
			"rot": int(pst["rot"]),
			"player": true,
		}
	return map

static func _socket_cell(piece: Dictionary, socket_id: String) -> Vector2i:
	for raw_sock in piece["sockets"]:
		var sock: Dictionary = raw_sock
		if str(sock["id"]) == socket_id:
			return Vector2i(int(sock["x"]), int(sock["y"]))
	return Vector2i(-1, -1)

static func _cast(
	chart: Dictionary,
	state: Dictionary,
	occupants: Dictionary,
	cell: Vector2i,
	dir: String,
	color: String,
	bounces: int,
	visited: Dictionary,
	dock_hits: Dictionary,
	boat_lit: Dictionary,
	segments: Array,
	prev: Vector2i
) -> void:
	var steps := 0
	while steps < MAX_STEPS:
		steps += 1
		if bounces > MAX_BOUNCES or segments.size() > MAX_SEGMENTS:
			return
		if not _in_bounds(chart, cell):
			return
		var key := "%d,%d,%s,%s" % [cell.x, cell.y, dir, color]
		if visited.has(key):
			return
		visited[key] = true
		var flooded := is_flooded(chart, state, cell)
		if flooded and not _flood_carries(occupants, cell):
			segments.append(_boundary_seg(prev, cell, color))
			return
		segments.append(_center_seg(prev, cell, color))
		if not occupants.has(cell):
			prev = cell
			cell = cell + VEC[dir]
			continue
		var occ: Dictionary = occupants[cell]
		var kind := str(occ["kind"])
		if kind == "dock":
			_note_dock(dock_hits, str(occ["id"]), color)
			return
		if kind == "boat":
			boat_lit[str(occ["id"])] = true
			return
		if kind == "obstacle" or kind == "lantern":
			return
		if kind == "mirror":
			dir = reflect(int(occ["rot"]), dir)
			bounces += 1
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "tide_mirror":
			# Dry glass is open: direction and color stay as they are.
			if flooded:
				dir = reflect(int(occ["rot"]), dir)
				bounces += 1
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "shutter":
			# Dry glass is shut. Flooded glass is a straight gate: no turn, no tint.
			if not flooded:
				return
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "stain":
			# Straight through, dry or flooded. The color becomes the stain's.
			color = stain_color(int(occ["rot"]))
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "vane":
			# The facing picks the exit. A head-on beam stops. Color stays.
			var facing := vane_facing(int(occ["rot"]))
			if dir == rotate_dir(facing, 2):
				return
			dir = facing
			bounces += 1
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "well":
			# Dry mouth stops the beam. A flooded mouth always leaves north.
			if not flooded:
				return
			dir = "N"
			bounces += 1
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "siphon":
			# Dry tube stops the beam. A flooded tube always leaves north, and
			# that exit swaps red with blue. White stays white.
			if not flooded:
				return
			dir = "N"
			color = siphon_color(color)
			bounces += 1
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "sluice":
			# Dry gate stops the beam, whichever way it faces. A flooded gate
			# may be entered from any side and always leaves along its facing.
			# The color stays. That exit costs a bounce.
			if not flooded:
				return
			dir = sluice_facing(int(occ["rot"]))
			bounces += 1
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "pane":
			if color != pane_color(int(occ["rot"])):
				return
			bounces += 1
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "prism":
			var ports := prism_ports(int(occ["rot"]))
			if color == "white" and dir == str(ports["entry"]):
				var next_bounce := bounces + 1
				var red_dir := str(ports["red"])
				var blue_dir := str(ports["blue"])
				_cast(chart, state, occupants, cell + VEC[red_dir], red_dir, "red", next_bounce, visited, dock_hits, boat_lit, segments, cell)
				_cast(chart, state, occupants, cell + VEC[blue_dir], blue_dir, "blue", next_bounce, visited, dock_hits, boat_lit, segments, cell)
			return
		return

static func _flood_carries(occupants: Dictionary, cell: Vector2i) -> bool:
	# Tide mirrors reflect under water. Shutters pass straight through it.
	# A stain recolors and lets the beam leave. A well lets the beam enter
	# and leave north. A siphon lets the beam enter, leave north, and swap
	# red with blue. A sluice lets the beam enter and leave along its facing
	# without swapping colors. A vane is shut under water, so the beam stops
	# at the waterline and does not enter that cell. Every other flooded cell
	# stops.
	if not occupants.has(cell):
		return false
	var occ: Dictionary = occupants[cell]
	var kind := str(occ["kind"])
	return kind == "tide_mirror" or kind == "shutter" or kind == "stain" or kind == "well" or kind == "siphon" or kind == "sluice"

static func _in_bounds(chart: Dictionary, cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < int(chart["cols"]) and cell.y < int(chart["rows"])

static func _note_dock(dock_hits: Dictionary, id: String, color: String) -> void:
	var hits: Array = dock_hits[id]
	if not hits.has(color):
		hits.append(color)

static func _center_seg(a: Vector2i, b: Vector2i, color: String) -> Dictionary:
	return {
		"x0": a.x + 0.5,
		"y0": a.y + 0.5,
		"x1": b.x + 0.5,
		"y1": b.y + 0.5,
		"color": color,
	}

static func _boundary_seg(a: Vector2i, b: Vector2i, color: String) -> Dictionary:
	# Stop on the shared edge so the beam does not enter the flooded cell.
	var mid := (Vector2(a) + Vector2(b)) * 0.5
	return {
		"x0": a.x + 0.5,
		"y0": a.y + 0.5,
		"x1": mid.x + 0.5,
		"y1": mid.y + 0.5,
		"color": color,
	}
