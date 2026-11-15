extends Node2D
class_name HarborBoard

# The quay is drawn here: stone cells, glass, hulls, and a water shader on the
# flooded rows. Beams are Line2D children so they stay visible above the glass.

const Tracer := preload("res://scripts/beam_tracer.gd")
const Charts := preload("res://scripts/charts.gd")
const Palette := preload("res://scripts/palette.gd")

var chart: Dictionary = {}
var puzzle_state: Dictionary = {}
var trace: Dictionary = {}
var selected_id := ""
var hint_id := ""
var cell := 76.0
var _pulse := 0.0
var _water: Polygon2D
var _glow: Array[Line2D] = []
var _core: Array[Line2D] = []

func _ready() -> void:
	_water = Polygon2D.new()
	_water.show_behind_parent = true
	_water.color = Color.WHITE
	_water.antialiased = true
	var shader: Shader = load("res://shaders/water.gdshader")
	if shader:
		var mat := ShaderMaterial.new()
		mat.shader = shader
		_water.material = mat
	add_child(_water)

func _process(_delta: float) -> void:
	_pulse = 0.5 + 0.5 * sin(Time.get_ticks_msec() / 1000.0 * 3.2)
	queue_redraw()

func present(next_chart: Dictionary, next_state: Dictionary, next_trace: Dictionary, selected: String, hint: String) -> void:
	chart = next_chart
	puzzle_state = next_state
	trace = next_trace
	selected_id = selected
	hint_id = hint
	_sync_beams()
	_layout_water()
	queue_redraw()

func cell_at_global(global_pos: Vector2) -> Vector2i:
	if chart.is_empty() or cell <= 1.0:
		return Vector2i(-1, -1)
	var local := get_global_transform_with_canvas().affine_inverse() * global_pos
	var c := int(floor(local.x / cell))
	var r := int(floor(local.y / cell))
	if c < 0 or r < 0 or c >= int(chart["cols"]) or r >= int(chart["rows"]):
		return Vector2i(-1, -1)
	return Vector2i(c, r)

func _layout_water() -> void:
	if chart.is_empty():
		_water.polygon = PackedVector2Array()
		return
	var cols := int(chart["cols"])
	var rows := int(chart["rows"])
	var flood := int(trace.get("flood", 0))
	var top := float(rows) * cell
	if flood > 0:
		top = float(rows - flood) * cell
	var bottom := float(rows) * cell + cell * 0.42
	var left := -6.0
	var right := float(cols) * cell + 6.0
	_water.polygon = PackedVector2Array([
		Vector2(left, top),
		Vector2(right, top),
		Vector2(right, bottom),
		Vector2(left, bottom),
	])
	_water.uv = PackedVector2Array([
		Vector2(0, 0),
		Vector2(1, 0),
		Vector2(1, 1),
		Vector2(0, 1),
	])

func _sync_beams() -> void:
	var segments: Array = _coalesce(trace.get("segments", []))
	while _glow.size() < segments.size():
		var glow := Line2D.new()
		glow.width = 15.0
		glow.joint_mode = Line2D.LINE_JOINT_ROUND
		glow.begin_cap_mode = Line2D.LINE_CAP_ROUND
		glow.end_cap_mode = Line2D.LINE_CAP_ROUND
		glow.z_index = 4
		add_child(glow)
		_glow.append(glow)
		var core := Line2D.new()
		core.width = 3.5
		core.joint_mode = Line2D.LINE_JOINT_ROUND
		core.begin_cap_mode = Line2D.LINE_CAP_ROUND
		core.end_cap_mode = Line2D.LINE_CAP_ROUND
		core.z_index = 5
		add_child(core)
		_core.append(core)
	for i in _glow.size():
		var on := i < segments.size()
		_glow[i].visible = on
		_core[i].visible = on
		if not on:
			continue
		var seg: Dictionary = segments[i]
		var a := Vector2(float(seg["x0"]), float(seg["y0"])) * cell
		var b := Vector2(float(seg["x1"]), float(seg["y1"])) * cell
		var col := Palette.beam(str(seg["color"]))
		_glow[i].points = PackedVector2Array([a, b])
		_core[i].points = PackedVector2Array([a, b])
		var soft := col
		soft.a = 0.38
		_glow[i].default_color = soft
		var hot := col
		hot.a = 0.95
		_core[i].default_color = hot

func _coalesce(segments: Array) -> Array:
	var merged: Array = []
	for raw in segments:
		var seg: Dictionary = raw
		if merged.is_empty():
			merged.append(seg.duplicate())
			continue
		var prev: Dictionary = merged[merged.size() - 1]
		var same_color := str(prev["color"]) == str(seg["color"])
		var connected := is_equal_approx(float(prev["x1"]), float(seg["x0"])) and is_equal_approx(float(prev["y1"]), float(seg["y0"]))
		var dx1 := float(prev["x1"]) - float(prev["x0"])
		var dy1 := float(prev["y1"]) - float(prev["y0"])
		var dx2 := float(seg["x1"]) - float(seg["x0"])
		var dy2 := float(seg["y1"]) - float(seg["y0"])
		var colinear := absf(dx1 * dy2 - dy1 * dx2) < 0.001
		if same_color and connected and colinear:
			prev["x1"] = seg["x1"]
			prev["y1"] = seg["y1"]
		else:
			merged.append(seg.duplicate())
	return merged

func _draw() -> void:
	if chart.is_empty():
		return
	var cols := int(chart["cols"])
	var rows := int(chart["rows"])
	var frame := Rect2(Vector2(-8, -8), Vector2(cols * cell + 16, rows * cell + 16))
	draw_rect(frame, Color("0e1822"), false, 2.0)
	for r in rows:
		for c in cols:
			var flooded := Tracer.is_flooded(chart, puzzle_state, Vector2i(c, r))
			var rect := _cell_rect(c, r)
			if flooded:
				draw_rect(rect, Color(0.07, 0.30, 0.44, 0.94))
				draw_rect(rect, Color(0.62, 0.88, 0.94, 0.35), false, 1.0)
			else:
				var stone := Palette.STONE if (c + r) % 2 == 0 else Palette.STONE_ALT
				draw_rect(rect, stone)
				draw_rect(rect, Palette.GRID_LINE, false, 1.0)
	var flood := int(trace.get("flood", 0))
	if flood > 0:
		var y := float(rows - flood) * cell
		draw_line(Vector2(-6, y), Vector2(cols * cell + 6, y), Palette.FOAM, 2.0)
	for raw in chart["obstacles"]:
		_draw_piling(raw)
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		_draw_kind(str(fix["kind"]), int(fix["rot"]), Vector2i(int(fix["x"]), int(fix["y"])), false, true)
	for raw in chart["lanterns"]:
		var lantern: Dictionary = raw
		_draw_lantern(lantern)
	for raw in chart["boats"]:
		var boat: Dictionary = raw
		_draw_boat(boat)
	for raw in chart["docks"]:
		var dock: Dictionary = raw
		_draw_dock(dock)
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		var id := str(piece["id"])
		var at := Charts.piece_cell(chart, puzzle_state, id)
		var pst: Dictionary = puzzle_state["pieces"][id]
		_draw_kind(str(piece["kind"]), int(pst["rot"]), at, true, false)
		_draw_sockets(piece, at)
		if not _keeps_its_face_under_water(str(piece["kind"])) and Tracer.is_flooded(chart, puzzle_state, at):
			_draw_shutters(at)
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		var at := Vector2i(int(fix["x"]), int(fix["y"]))
		if not _keeps_its_face_under_water(str(fix["kind"])) and Tracer.is_flooded(chart, puzzle_state, at):
			_draw_shutters(at)
	for raw in chart["lanterns"]:
		var lantern: Dictionary = raw
		var at := Vector2i(int(lantern["x"]), int(lantern["y"]))
		if Tracer.is_flooded(chart, puzzle_state, at):
			_draw_shutters(at)
	_draw_marks()

func _draw_sockets(piece: Dictionary, occupied: Vector2i) -> void:
	if not bool(piece["movable"]):
		return
	if str(piece["id"]) != selected_id:
		return
	for raw in piece["sockets"]:
		var sock: Dictionary = raw
		var at := Vector2i(int(sock["x"]), int(sock["y"]))
		if at == occupied:
			continue
		var center := _center(at)
		var col := Palette.SELECT
		col.a = 0.45 + 0.35 * _pulse
		draw_arc(center, cell * 0.28, 0, TAU, 24, col, 2.0, true)

func _draw_marks() -> void:
	if selected_id != "":
		var at := Charts.piece_cell(chart, puzzle_state, selected_id)
		if at.x >= 0:
			var col := Palette.SELECT
			col.a = 0.55 + 0.45 * _pulse
			draw_rect(_cell_rect(at.x, at.y).grow(3), col, false, 2.5)
	if hint_id != "" and hint_id != "tide":
		var at := Charts.piece_cell(chart, puzzle_state, hint_id)
		if at.x >= 0:
			var col := Palette.HINT
			col.a = 0.4 + 0.6 * _pulse
			draw_rect(_cell_rect(at.x, at.y).grow(7), col, false, 3.0)

func _draw_kind(kind: String, rot: int, at: Vector2i, player: bool, fixed: bool) -> void:
	match kind:
		"mirror":
			_draw_mirror(at, rot, player, fixed)
		"tide_mirror":
			_draw_tide_mirror(at, rot)
		"shutter":
			_draw_shutter_gate(at)
		"prism":
			_draw_prism(at, rot, fixed)
		"pane":
			_draw_pane(at, rot, fixed)
		_:
			pass

func _draw_mirror(at: Vector2i, rot: int, player: bool, fixed: bool) -> void:
	var center := _center(at)
	var r := cell * 0.30
	var glass := Palette.GLASS if player else Palette.SET_GLASS
	if fixed:
		glass = Palette.SET_GLASS
	var poly := PackedVector2Array([
		center + Vector2(0, -r),
		center + Vector2(r, 0),
		center + Vector2(0, r),
		center + Vector2(-r, 0),
	])
	draw_colored_polygon(poly, Color(glass.r, glass.g, glass.b, 0.88))
	var slash := Tracer.norm_rot("mirror", rot) == 0
	var a: Vector2
	var b: Vector2
	if slash:
		a = center + Vector2(-r * 0.72, r * 0.72)
		b = center + Vector2(r * 0.72, -r * 0.72)
	else:
		a = center + Vector2(-r * 0.72, -r * 0.72)
		b = center + Vector2(r * 0.72, r * 0.72)
	draw_line(a, b, Palette.GLASS_EDGE, 4.0)
	draw_line(a, b, Color("7f5a32"), 1.5)

func _draw_tide_mirror(at: Vector2i, rot: int) -> void:
	var center := _center(at)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var r := cell * 0.30
	var poly := PackedVector2Array([
		center + Vector2(0, -r),
		center + Vector2(r, 0),
		center + Vector2(0, r),
		center + Vector2(-r, 0),
	])
	var fill := Palette.TIDE if flooded else Palette.GLASS
	fill.a = 0.9 if flooded else 0.22
	draw_colored_polygon(poly, fill)
	var rim := poly.duplicate()
	rim.append(poly[0])
	draw_polyline(rim, Palette.FOAM if flooded else Palette.TIDE, 2.0)
	var slash := Tracer.norm_rot("tide_mirror", rot) == 0
	var a := center + (Vector2(-r, r) if slash else Vector2(-r, -r)) * 0.72
	var b := center + (Vector2(r, -r) if slash else Vector2(r, r)) * 0.72
	if flooded:
		draw_line(a, b, Palette.FOAM, 4.0)
		draw_line(a, b, Palette.TIDE_DEEP, 1.5)
	else:
		var mid := (a + b) * 0.5
		var gap := (b - a).normalized() * cell * 0.08
		draw_line(a, mid - gap, Palette.TIDE, 3.0)
		draw_line(mid + gap, b, Palette.TIDE, 3.0)
	var wave := center.y + r * 0.62
	var wave_col := Palette.FOAM if flooded else Palette.TIDE_DEEP
	draw_line(Vector2(center.x - r * 0.62, wave), Vector2(center.x - r * 0.16, wave - 3.0), wave_col, 2.0)
	draw_line(Vector2(center.x - r * 0.16, wave - 3.0), Vector2(center.x + r * 0.16, wave + 3.0), wave_col, 2.0)
	draw_line(Vector2(center.x + r * 0.16, wave + 3.0), Vector2(center.x + r * 0.62, wave), wave_col, 2.0)

func _keeps_its_face_under_water(kind: String) -> bool:
	return kind == "tide_mirror" or kind == "shutter"

func _draw_shutter_gate(at: Vector2i) -> void:
	# A sluice, not a mirror. Closed bars while the row is dry. An open slot
	# while that row is flooded, so the beam can pass straight through.
	var center := _center(at)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var rect := Rect2(center - Vector2(cell * 0.30, cell * 0.32), Vector2(cell * 0.60, cell * 0.64))
	var frame := Palette.GATE_IRON
	draw_rect(rect, Color(frame.r, frame.g, frame.b, 0.55 if flooded else 0.92))
	draw_rect(rect, Palette.GATE if flooded else Palette.GATE_IRON, false, 2.0)
	var bar := Palette.FOAM if flooded else Palette.GATE
	if flooded:
		var gap := cell * 0.16
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, 5.0)), bar)
		draw_rect(Rect2(Vector2(rect.position.x, rect.end.y - 5.0), Vector2(rect.size.x, 5.0)), bar)
		draw_rect(Rect2(rect.position, Vector2(5.0, rect.size.y)), bar)
		draw_rect(Rect2(Vector2(rect.end.x - 5.0, rect.position.y), Vector2(5.0, rect.size.y)), bar)
		draw_line(Vector2(rect.position.x + 8.0, center.y), Vector2(center.x - gap, center.y), bar, 3.0)
		draw_line(Vector2(center.x + gap, center.y), Vector2(rect.end.x - 8.0, center.y), bar, 3.0)
	else:
		for i in 4:
			var y := rect.position.y + 6.0 + float(i) * (rect.size.y - 10.0) / 3.0
			draw_line(Vector2(rect.position.x + 4.0, y), Vector2(rect.end.x - 4.0, y), bar, 3.0)

func _draw_prism(at: Vector2i, rot: int, set_in_stone: bool) -> void:
	var center := _center(at)
	var r := cell * 0.32
	var poly := PackedVector2Array([
		center + Vector2(0, -r),
		center + Vector2(r * 0.9, r * 0.7),
		center + Vector2(-r * 0.9, r * 0.7),
	])
	var glass := Palette.SET_GLASS if set_in_stone else Palette.GLASS
	draw_colored_polygon(poly, Color(glass.r, glass.g, glass.b, 0.78))
	var ports := Tracer.prism_ports(rot)
	var red_at := center + _dir_vec(str(ports["red"])) * r * 0.62
	var blue_at := center + _dir_vec(str(ports["blue"])) * r * 0.62
	draw_circle(red_at, 5.5, Palette.BEAM_RED)
	draw_circle(blue_at, 5.5, Palette.BEAM_BLUE)
	_label(red_at + Vector2(6, 4), "R", 12, Color("2a060c"))
	_label(blue_at + Vector2(6, 4), "B", 12, Color("041424"))

func _draw_pane(at: Vector2i, rot: int, set_in_stone: bool) -> void:
	var center := _center(at)
	var tint := Tracer.pane_color(rot)
	var col := Palette.BEAM_RED if tint == "red" else Palette.BEAM_BLUE
	var rect := Rect2(center - Vector2(cell * 0.22, cell * 0.30), Vector2(cell * 0.44, cell * 0.60))
	var fill := col
	fill.a = 0.38 if set_in_stone else 0.55
	draw_rect(rect, fill)
	draw_rect(rect, Palette.GLASS_EDGE, false, 2.0)
	draw_line(rect.position + Vector2(4, 6), rect.position + Vector2(rect.size.x - 8, 6), Color(1, 1, 1, 0.55), 2.0)
	var chip := Rect2(center.x - 18.0, center.y - 9.0, 36.0, 16.0)
	draw_rect(chip, Color(0.03, 0.05, 0.08, 0.78))
	_label(center + Vector2(-13, 4), tint, 13, Color.WHITE)

func _draw_lantern(lantern: Dictionary) -> void:
	var at := Vector2i(int(lantern["x"]), int(lantern["y"]))
	var center := _center(at)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var body := Rect2(center - Vector2(cell * 0.16, cell * 0.22), Vector2(cell * 0.32, cell * 0.40))
	draw_rect(body, Color("3a2a22"))
	draw_rect(body, Color("6b4a32"), false, 2.0)
	var tint := str(lantern["color"])
	var glow := Palette.LANTERN_HOT if not flooded else Color("5c5148")
	var rim := Palette.LANTERN
	if tint != "white":
		glow = Palette.beam(tint) if not flooded else Color("5c5148")
		rim = Palette.beam(tint)
	draw_circle(center + Vector2(0, -2), cell * 0.12, glow)
	draw_circle(center + Vector2(0, -2), cell * 0.12, rim, false, 2.0)
	if not flooded:
		var dir := _dir_vec(str(lantern["dir"]))
		draw_line(center, center + dir * cell * 0.34, rim if tint != "white" else Palette.LANTERN, 3.0)
	if tint != "white":
		_label(center + Vector2(-14, cell * 0.36), tint, 12, Palette.beam(tint))

func _draw_dock(dock: Dictionary) -> void:
	var at := Vector2i(int(dock["x"]), int(dock["y"]))
	var rect := _cell_rect(at.x, at.y)
	var wood := Rect2(rect.position + Vector2(6, rect.size.y * 0.42), Vector2(rect.size.x - 12, rect.size.y * 0.46))
	draw_rect(wood, Palette.WOOD)
	for i in 3:
		var y := wood.position.y + 6.0 + float(i) * (wood.size.y / 3.5)
		draw_line(Vector2(wood.position.x + 3, y), Vector2(wood.position.x + wood.size.x - 3, y), Palette.WOOD_DARK, 1.5)
	var required := str(dock["color"])
	var hits: Array = trace.get("docks", {}).get(str(dock["id"]), [])
	var lamp := Palette.beam(required)
	lamp = lamp.darkened(0.55)
	if hits.has(required):
		lamp = Palette.beam(required)
	elif not hits.is_empty():
		lamp = Palette.beam(str(hits[0])).darkened(0.15)
	var lamp_at := rect.position + Vector2(rect.size.x * 0.5, rect.size.y * 0.28)
	draw_rect(Rect2(lamp_at - Vector2(3, 10), Vector2(6, 12)), Palette.WOOD_DARK)
	draw_circle(lamp_at, 8.0, lamp)
	_label(rect.position + Vector2(rect.size.x * 0.5 - 18, 14), required, 13, Palette.TEXT)

func _draw_boat(boat: Dictionary) -> void:
	var at := Vector2i(int(boat["x"]), int(boat["y"]))
	var center := _center(at)
	var lit := bool(trace.get("boats", {}).get(str(boat["id"]), false))
	var hull := PackedVector2Array([
		center + Vector2(-cell * 0.34, cell * 0.02),
		center + Vector2(-cell * 0.18, cell * 0.20),
		center + Vector2(cell * 0.18, cell * 0.20),
		center + Vector2(cell * 0.34, cell * 0.02),
		center + Vector2(cell * 0.16, -cell * 0.16),
		center + Vector2(-cell * 0.16, -cell * 0.16),
	])
	draw_colored_polygon(hull, Palette.HULL)
	var rim := hull.duplicate()
	rim.append(hull[0])
	draw_polyline(rim, Palette.HULL_EDGE, 2.0)
	var cabin := Rect2(center + Vector2(-cell * 0.10, -cell * 0.12), Vector2(cell * 0.20, cell * 0.16))
	draw_rect(cabin, Color("1c2836"))
	var window := Palette.LANTERN if lit else Color("243140")
	draw_rect(Rect2(cabin.position + Vector2(4, 4), Vector2(cabin.size.x - 8, 6)), window)
	_label(center + Vector2(-18, cell * 0.36), "in light" if lit else "asleep", 11, Palette.WARN if lit else Palette.MUTED)

func _draw_piling(at: Vector2i) -> void:
	var center := _center(at)
	for offset in [Vector2(-12, 8), Vector2(0, 0), Vector2(12, 8)]:
		var post := Rect2(center + offset - Vector2(5, 16), Vector2(10, 28))
		draw_rect(post, Palette.PILE)
		draw_rect(post, Palette.PILE_EDGE, false, 1.0)
	draw_rect(Rect2(center + Vector2(-16, -18), Vector2(32, 6)), Palette.PILE_EDGE)

func _draw_shutters(at: Vector2i) -> void:
	var rect := _cell_rect(at.x, at.y)
	draw_rect(rect, Color(0.04, 0.14, 0.20, 0.42))
	for i in 3:
		var y := rect.position.y + rect.size.y * (0.30 + 0.18 * float(i))
		draw_line(Vector2(rect.position.x + 8, y), Vector2(rect.end.x - 8, y), Color(0.78, 0.92, 0.96, 0.7), 2.0)

func _label(at: Vector2, text: String, size: int, color: Color) -> void:
	var font := ThemeDB.fallback_font
	if font == null or text == "":
		return
	draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func _cell_rect(c: int, r: int) -> Rect2:
	return Rect2(Vector2(c, r) * cell, Vector2(cell, cell)).grow(-3)

func _center(at: Vector2i) -> Vector2:
	return Vector2(at.x + 0.5, at.y + 0.5) * cell

func _dir_vec(dir: String) -> Vector2:
	match dir:
		"N":
			return Vector2(0, -1)
		"E":
			return Vector2(1, 0)
		"S":
			return Vector2(0, 1)
		"W":
			return Vector2(-1, 0)
	return Vector2.ZERO
