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
		"stain":
			_draw_stain(at, rot)
		"vane":
			_draw_vane(at, rot)
		"well":
			_draw_well(at)
		"siphon":
			_draw_siphon(at)
		"sluice":
			_draw_sluice(at, rot)
		"weir":
			_draw_weir(at, rot)
		"lintel":
			_draw_lintel(at)
		"mullion":
			_draw_mullion(at)
		"transom":
			_draw_transom(at)
		"casement":
			_draw_casement(at, rot)
		"jamb":
			_draw_jamb(at, rot)
		"astragal":
			_draw_astragal(at, rot)
		"scotia":
			_draw_scotia(at, rot)
		"torus":
			_draw_torus(at, rot)
		"ogee":
			_draw_ogee(at, rot)
		"ovolo":
			_draw_ovolo(at, rot)
		"cavetto":
			_draw_cavetto(at, rot)
		"fillet":
			_draw_fillet(at, rot)
		"corona":
			_draw_corona(at, rot)
		"bead":
			_draw_bead(at, rot)
		"quirk":
			_draw_quirk(at, rot)
		"cyma":
			_draw_cyma(at, rot)
		"fascia":
			_draw_fascia(at, rot)
		"soffit":
			_draw_soffit(at, rot)
		"drip":
			_draw_drip(at, rot)
		"beak":
			_draw_beak(at, rot)
		"hood":
			_draw_hood(at, rot)
		"throat":
			_draw_throat(at, rot)
		"larmier":
			_draw_larmier(at, rot)
		"cill":
			_draw_cill(at, rot)
		"threshold":
			_draw_threshold(at, rot)
		"impost":
			_draw_impost(at, rot)
		"architrave":
			_draw_architrave(at, rot)
		"archivolt":
			_draw_archivolt(at, rot)
		"abacus":
			_draw_abacus(at, rot)
		"rebate":
			_draw_rebate(at, rot)
		"echinus":
			_draw_echinus(at, rot)
		"annulet":
			_draw_annulet(at, rot)
		"listel":
			_draw_listel(at, rot)
		"necking":
			_draw_necking(at, rot)
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
	# These still act under water, so the closed bars are not drawn over them.
	return kind == "tide_mirror" or kind == "shutter" or kind == "stain" or kind == "well" or kind == "siphon" or kind == "sluice" or kind == "weir"

func _draw_shutter_gate(at: Vector2i) -> void:
	# A shutter, not a mirror. Closed bars while the row is dry. An open slot
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

func _draw_stain(at: Vector2i, rot: int) -> void:
	# A blot of pigment on glass. No facing: the color is the whole piece.
	var center := _center(at)
	var tint := Tracer.stain_color(rot)
	var col := Palette.BEAM_RED if tint == "red" else Palette.BEAM_BLUE
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	draw_circle(center, cell * 0.30, Color(Palette.GLASS.r, Palette.GLASS.g, Palette.GLASS.b, 0.28))
	draw_arc(center, cell * 0.30, 0, TAU, 28, Palette.GLASS_EDGE, 2.0, true)
	var blot := col
	blot.a = 0.88
	draw_circle(center + Vector2(-6, 3), cell * 0.15, blot)
	draw_circle(center + Vector2(7, -4), cell * 0.09, blot)
	draw_circle(center + Vector2(1, 9), cell * 0.06, blot)
	draw_line(center + Vector2(1, 8), center + Vector2(3, cell * 0.22), blot, 3.0)
	var chip := Rect2(center.x - 18.0, center.y - 9.0, 36.0, 16.0)
	draw_rect(chip, Color(0.05, 0.04, 0.06, 0.78))
	_label(center + Vector2(-14, 4), tint, 12, Color.WHITE)
	if flooded:
		draw_arc(center, cell * 0.34, 0, TAU, 24, Palette.FOAM, 1.5, true)

func _draw_vane(at: Vector2i, rot: int) -> void:
	# A weather vane cut from the quay glass. The arrow is the facing.
	# Head-on light meets the tip and stops. Light from the tail or either
	# flank leaves along the arrow.
	var center := _center(at)
	var facing := Tracer.vane_facing(rot)
	var dir := _dir_vec(facing)
	var flank := Vector2(-dir.y, dir.x)
	var r := cell * 0.30
	draw_circle(center, r, Color(Palette.GLASS.r, Palette.GLASS.g, Palette.GLASS.b, 0.34))
	draw_arc(center, r, 0, TAU, 28, Palette.GLASS_EDGE, 2.0, true)
	var tail := center - dir * r * 0.72
	draw_line(center, tail, Palette.GATE, 4.0)
	draw_line(tail + flank * 7.0, tail - flank * 7.0, Palette.GATE, 3.0)
	var tip := center + dir * r * 0.88
	var head := PackedVector2Array([
		tip,
		center + dir * r * 0.16 + flank * r * 0.46,
		center + dir * r * 0.16 - flank * r * 0.46,
	])
	draw_colored_polygon(head, Palette.LANTERN)
	draw_line(center - dir * r * 0.08, center + dir * r * 0.2, Palette.LANTERN, 4.0)
	draw_circle(center, 3.5, Palette.WOOD_DARK)

func _draw_well(at: Vector2i) -> void:
	# A round dark mouth, separate from the vane's arrow. Dry boards lie
	# across the mouth. Flooded water leaves it open.
	var center := _center(at)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var outer := cell * 0.30
	var mouth := cell * 0.16
	draw_circle(center, outer, Color(Palette.WOOD_DARK.r, Palette.WOOD_DARK.g, Palette.WOOD_DARK.b, 0.96))
	draw_arc(center, outer, 0, TAU, 32, Palette.WOOD, 3.0, true)
	draw_circle(center, mouth, Color("07090d"))
	draw_arc(center, mouth, 0, TAU, 28, Palette.HULL_EDGE, 1.5, true)
	if flooded:
		draw_arc(center, mouth * 0.62, 0.35, PI - 0.35, 14, Palette.FOAM, 1.5, true)
		draw_circle(center + Vector2(-mouth * 0.28, -mouth * 0.2), 2.2, Color(Palette.FOAM.r, Palette.FOAM.g, Palette.FOAM.b, 0.85))
	else:
		draw_line(center + Vector2(-mouth * 0.92, -2.0), center + Vector2(mouth * 0.92, -2.0), Palette.WOOD, 2.5)
		draw_line(center + Vector2(-mouth * 0.68, 4.0), center + Vector2(mouth * 0.68, 4.0), Palette.PILE_EDGE, 2.0)

func _draw_siphon(at: Vector2i) -> void:
	# A bent tube with a north spout. The silhouette is an arch and two legs,
	# not the well's round mouth. Dry bars close the tube. Flood opens the
	# spout and shows the red/blue swap.
	var center := _center(at)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var metal := Palette.TIDE if flooded else Palette.GATE_IRON
	var arch_c := center + Vector2(0, -cell * 0.04)
	var radius := cell * 0.18
	draw_arc(arch_c, radius, PI, TAU, 20, metal, 5.0, true)
	var west_top := arch_c + Vector2(-radius, 0)
	var west_foot := west_top + Vector2(0, cell * 0.30)
	draw_line(west_top, west_foot, metal, 5.0)
	var east_top := arch_c + Vector2(radius, 0)
	var spout := center + Vector2(cell * 0.06, -cell * 0.36)
	draw_line(east_top, spout, metal, 5.0)
	var tip := spout + Vector2(0, -cell * 0.10)
	var flank := cell * 0.07
	var head := PackedVector2Array([
		tip,
		spout + Vector2(-flank, cell * 0.02),
		spout + Vector2(flank, cell * 0.02),
	])
	draw_colored_polygon(head, Palette.LANTERN if flooded else Palette.GATE)
	var red_at := center + Vector2(-cell * 0.08, cell * 0.06)
	var blue_at := center + Vector2(cell * 0.08, cell * 0.00)
	draw_rect(Rect2(red_at, Vector2(8, 8)), Palette.BEAM_RED)
	draw_rect(Rect2(blue_at, Vector2(8, 8)), Palette.BEAM_BLUE)
	draw_line(red_at + Vector2(8, 4), blue_at + Vector2(0, 4), Palette.GLASS_EDGE, 1.5)
	if flooded:
		draw_arc(arch_c, radius * 0.55, PI + 0.35, TAU - 0.35, 12, Palette.FOAM, 2.0, true)
	else:
		draw_line(west_top + Vector2(-6, cell * 0.12), west_top + Vector2(6, cell * 0.12), Palette.WOOD, 3.0)
		draw_line(east_top + Vector2(-4, cell * 0.08), east_top + Vector2(8, cell * 0.12), Palette.WOOD, 3.0)

func _draw_sluice(at: Vector2i, rot: int) -> void:
	# A straight gate with a spout along the facing. Not the siphon's bent
	# tube, and not the well's round mouth. Dry bars close the gate. Flood
	# opens the channel and the spout shows the exit.
	var center := _center(at)
	var facing := Tracer.sluice_facing(rot)
	var dir := _dir_vec(facing)
	var flank := Vector2(-dir.y, dir.x)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var metal := Palette.TIDE if flooded else Palette.GATE_IRON
	var length := cell * 0.34
	var half := cell * 0.11
	var tail := center - dir * length
	var mouth := center + dir * length * 0.42
	draw_line(tail + flank * half, mouth + flank * half, metal, 4.0)
	draw_line(tail - flank * half, mouth - flank * half, metal, 4.0)
	draw_line(tail + flank * half, tail - flank * half, metal, 4.0)
	var tip := center + dir * length * 1.05
	var base := center + dir * length * 0.28
	var head := PackedVector2Array([
		tip,
		base + flank * half * 1.7,
		base - flank * half * 1.7,
	])
	draw_colored_polygon(head, Palette.LANTERN if flooded else Palette.GATE)
	if flooded:
		draw_line(tail + dir * cell * 0.08, mouth, Palette.FOAM, 2.0)
	else:
		for i in 3:
			var p := tail.lerp(mouth, 0.28 + float(i) * 0.24)
			draw_line(p + flank * half, p - flank * half, Palette.WOOD, 3.0)

func _draw_weir(at: Vector2i, rot: int) -> void:
	# A straight gate with an open spout along the facing and a twist mark on
	# the gate. Not the sluice's filled spout, and not the siphon's bent tube.
	# Dry bars close the gate. Flood opens the channel and leaves the twist.
	var center := _center(at)
	var facing := Tracer.weir_facing(rot)
	var dir := _dir_vec(facing)
	var flank := Vector2(-dir.y, dir.x)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var metal := Palette.TIDE if flooded else Palette.GATE_IRON
	var length := cell * 0.34
	var half := cell * 0.11
	var tail := center - dir * length
	var mouth := center + dir * length * 0.42
	draw_line(tail + flank * half, mouth + flank * half, metal, 4.0)
	draw_line(tail - flank * half, mouth - flank * half, metal, 4.0)
	draw_line(tail + flank * half, tail - flank * half, metal, 4.0)
	var tip := center + dir * length * 1.02
	var lip := half * 0.45
	draw_line(mouth + flank * half, tip + flank * lip, metal, 4.0)
	draw_line(mouth - flank * half, tip - flank * lip, metal, 4.0)
	draw_line(tip + flank * lip, tip - flank * lip, Palette.LANTERN if flooded else Palette.GATE, 3.0)
	if flooded:
		draw_line(tail + dir * cell * 0.1, mouth - dir * cell * 0.02, Palette.FOAM, 2.0)
	else:
		for i in 3:
			var p := tail.lerp(mouth, 0.22 + float(i) * 0.26)
			draw_line(p + flank * half, p - flank * half, Palette.WOOD, 3.0)
	var twist := tail.lerp(mouth, 0.48)
	var along := dir * half * 0.95
	var across := flank * half * 0.72
	draw_line(twist - along + across, twist - across * 0.15, Palette.BEAM_RED, 2.5)
	draw_line(twist - across * 0.15, twist + along - across, Palette.BEAM_BLUE, 2.5)

func _draw_lintel(at: Vector2i) -> void:
	# A flat stone bar with a gap under it. Not the weir's gate, spout, or
	# twist mark. The bar does not turn: a lintel has no facing.
	var center := _center(at)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var stone := Palette.WOOD if flooded else Palette.WOOD_DARK
	var edge := Palette.PILE_EDGE if flooded else Palette.WOOD
	var bar := Rect2(center + Vector2(-cell * 0.36, -cell * 0.30), Vector2(cell * 0.72, cell * 0.14))
	draw_rect(bar, stone)
	draw_rect(bar, edge, false, 2.0)
	draw_line(bar.position + Vector2(5, 3), bar.position + Vector2(bar.size.x - 5, 3), Palette.LANTERN_HOT, 1.5)
	var jamb_w := cell * 0.12
	var gap_top := bar.end.y + cell * 0.06
	var gap_bot := center.y + cell * 0.32
	var jamb_h := maxf(gap_bot - gap_top, 8.0)
	var left := Rect2(Vector2(bar.position.x, gap_top), Vector2(jamb_w, jamb_h))
	var right := Rect2(Vector2(bar.end.x - jamb_w, gap_top), Vector2(jamb_w, jamb_h))
	draw_rect(left, stone)
	draw_rect(right, stone)
	draw_rect(left, edge, false, 1.5)
	draw_rect(right, edge, false, 1.5)

func _draw_mullion(at: Vector2i) -> void:
	# A vertical stone bar. Not the lintel's horizontal bar, and not a shutter slat.
	# The bar does not turn: a mullion has no facing.
	var center := _center(at)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var stone := Palette.WOOD if flooded else Palette.WOOD_DARK
	var edge := Palette.PILE_EDGE if flooded else Palette.WOOD
	var cap_w := cell * 0.30
	var cap_h := cell * 0.10
	var shaft_w := cell * 0.16
	var top := center.y - cell * 0.38
	var bot := center.y + cell * 0.38
	var top_cap := Rect2(Vector2(center.x - cap_w * 0.5, top), Vector2(cap_w, cap_h))
	var bot_cap := Rect2(Vector2(center.x - cap_w * 0.5, bot - cap_h), Vector2(cap_w, cap_h))
	var shaft := Rect2(Vector2(center.x - shaft_w * 0.5, top_cap.end.y), Vector2(shaft_w, bot_cap.position.y - top_cap.end.y))
	draw_rect(top_cap, stone)
	draw_rect(bot_cap, stone)
	draw_rect(shaft, stone)
	draw_rect(top_cap, edge, false, 1.5)
	draw_rect(bot_cap, edge, false, 1.5)
	draw_rect(shaft, edge, false, 2.0)
	draw_line(Vector2(center.x, shaft.position.y + 4.0), Vector2(center.x, shaft.end.y - 4.0), Palette.LANTERN_HOT, 1.5)

func _draw_transom(at: Vector2i) -> void:
	# A pale horizontal bar with a dark center stroke. Not the lintel's solid
	# stone bar, and not the mullion's vertical bar. The bar does not turn:
	# a transom has no facing.
	var center := _center(at)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var pale := Palette.GLASS
	pale.a = 0.55 if flooded else 0.96
	var bar := Rect2(center + Vector2(-cell * 0.42, -cell * 0.11), Vector2(cell * 0.84, cell * 0.22))
	draw_rect(bar, pale)
	draw_rect(bar, Palette.FOAM if flooded else Palette.GLASS_EDGE, false, 2.0)
	draw_line(Vector2(bar.position.x + 6.0, center.y), Vector2(bar.end.x - 6.0, center.y), Palette.GATE_IRON, 3.0)

func _draw_casement(at: Vector2i, rot: int) -> void:
	# A pale hinged leaf. The dark hinge sits on the facing edge and moves
	# when the piece is rotated. The leaf has no center stroke, so it is not
	# the transom's thin bar, and it is not the mullion's vertical shaft.
	var center := _center(at)
	var facing := Tracer.casement_facing(rot)
	var dir := _dir_vec(facing)
	var flank := Vector2(-dir.y, dir.x)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var pale := Palette.GLASS
	pale.a = 0.42 if flooded else 0.96
	var half_along := cell * 0.28
	var half_across := cell * 0.20
	var mid := center - dir * cell * 0.06
	var back := mid - dir * half_along
	var front := mid + dir * half_along
	var leaf := PackedVector2Array([
		back - flank * half_across,
		back + flank * half_across,
		front + flank * half_across,
		front - flank * half_across,
	])
	draw_colored_polygon(leaf, pale)
	var rim := leaf.duplicate()
	rim.append(leaf[0])
	draw_polyline(rim, Palette.FOAM if flooded else Palette.GLASS_EDGE, 2.0)
	var hinge_a := front - flank * (half_across + cell * 0.04)
	var hinge_b := front + flank * (half_across + cell * 0.04)
	draw_line(hinge_a, hinge_b, Palette.GATE_IRON, 6.0)
	draw_circle(hinge_a, 4.2, Palette.WOOD_DARK)
	draw_circle(hinge_b, 4.2, Palette.WOOD_DARK)
	draw_circle(hinge_a.lerp(hinge_b, 0.5), 3.2, Palette.GATE_IRON)

func _draw_jamb(at: Vector2i, rot: int) -> void:
	# Two dark posts on the edges of the open axis, with a pale gap between
	# them. North or south puts the posts on the north and south edges. East
	# or west puts them on the east and west edges. Not one hinge, not one
	# bar, and not one shaft.
	var center := _center(at)
	var facing := Tracer.jamb_facing(rot)
	var north_south := facing == "N" or facing == "S"
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var post := Palette.WOOD_DARK if not flooded else Palette.WOOD
	var edge := Palette.PILE_EDGE if not flooded else Palette.FOAM
	var gap := Palette.GLASS
	gap.a = 0.42 if flooded else 0.96
	if north_south:
		var post_w := cell * 0.70
		var post_h := cell * 0.13
		var north := Rect2(center + Vector2(-post_w * 0.5, -cell * 0.42), Vector2(post_w, post_h))
		var south := Rect2(center + Vector2(-post_w * 0.5, cell * 0.42 - post_h), Vector2(post_w, post_h))
		var opening := Rect2(center + Vector2(-cell * 0.11, -cell * 0.24), Vector2(cell * 0.22, cell * 0.48))
		draw_rect(opening, gap)
		draw_rect(opening, Palette.GLASS_EDGE, false, 1.5)
		draw_rect(north, post)
		draw_rect(south, post)
		draw_rect(north, edge, false, 2.0)
		draw_rect(south, edge, false, 2.0)
	else:
		var post_w := cell * 0.13
		var post_h := cell * 0.70
		var west := Rect2(center + Vector2(-cell * 0.42, -post_h * 0.5), Vector2(post_w, post_h))
		var east := Rect2(center + Vector2(cell * 0.42 - post_w, -post_h * 0.5), Vector2(post_w, post_h))
		var opening := Rect2(center + Vector2(-cell * 0.24, -cell * 0.11), Vector2(cell * 0.48, cell * 0.22))
		draw_rect(opening, gap)
		draw_rect(opening, Palette.GLASS_EDGE, false, 1.5)
		draw_rect(west, post)
		draw_rect(east, post)
		draw_rect(west, edge, false, 2.0)
		draw_rect(east, edge, false, 2.0)

func _draw_astragal(at: Vector2i, rot: int) -> void:
	# Two dark posts on the facing edge and the clockwise edge, with a pale
	# corner between them. A north astragal puts the posts on the north and
	# east edges. Not the jamb's two opposite posts, not the casement's single
	# hinge, not the transom's one horizontal bar, and not the mullion's one
	# vertical shaft.
	var center := _center(at)
	var facing := Tracer.astragal_facing(rot)
	var clock := Tracer.rotate_dir(facing, 1)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var post := Palette.GATE_IRON if not flooded else Palette.WOOD
	var edge := Palette.WOOD_DARK if not flooded else Palette.FOAM
	var gap := Palette.GLASS
	gap.a = 0.5 if flooded else 0.98
	var sx := 1.0 if facing == "E" or clock == "E" else -1.0
	var sy := 1.0 if facing == "S" or clock == "S" else -1.0
	var reach := cell * 0.40
	var thick := cell * 0.15
	var pocket := cell * 0.24
	var corner_x := center.x + sx * reach
	var corner_y := center.y + sy * reach
	var pale_x := corner_x - (pocket if sx > 0.0 else 0.0)
	var pale_y := corner_y - (pocket if sy > 0.0 else 0.0)
	var pale := Rect2(Vector2(pale_x, pale_y), Vector2(pocket, pocket))
	draw_rect(pale, gap)
	draw_rect(pale, Palette.GLASS_EDGE, false, 2.0)
	var face_post := _astragal_post(center, facing, sx, sy, reach, thick, pocket)
	var clock_post := _astragal_post(center, clock, sx, sy, reach, thick, pocket)
	draw_rect(face_post, post)
	draw_rect(clock_post, post)
	draw_rect(face_post, edge, false, 2.0)
	draw_rect(clock_post, edge, false, 2.0)

func _draw_scotia(at: Vector2i, rot: int) -> void:
	# Two dark posts on the facing edge and the counterclockwise edge, with a
	# pale cove between them. A north scotia puts the posts on the north and
	# west edges. The cove is a quarter-round of pale wood, not the astragal's
	# square glass pocket, and the posts are dark timber rather than iron bars.
	var center := _center(at)
	var facing := Tracer.scotia_facing(rot)
	var back := Tracer.rotate_dir(facing, -1)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var post := Palette.WOOD_DARK if not flooded else Palette.WOOD
	var edge := Palette.PILE if not flooded else Palette.FOAM
	var cove := Palette.GATE
	cove.a = 0.55 if flooded else 0.98
	var sx := 1.0 if facing == "E" or back == "E" else -1.0
	var sy := 1.0 if facing == "S" or back == "S" else -1.0
	var reach := cell * 0.42
	var thick := cell * 0.18
	var pocket := cell * 0.28
	var corner := Vector2(center.x + sx * reach, center.y + sy * reach)
	var into := Vector2(-sx, -sy)
	var cove_poly := PackedVector2Array()
	cove_poly.append(corner)
	var steps := 8
	for i in steps + 1:
		var t := float(i) / float(steps) * PI * 0.5
		cove_poly.append(corner + Vector2(into.x * cos(t), into.y * sin(t)) * pocket)
	draw_colored_polygon(cove_poly, cove)
	var groove := PackedVector2Array()
	for i in steps + 1:
		var t := float(i) / float(steps) * PI * 0.5
		groove.append(corner + Vector2(into.x * cos(t), into.y * sin(t)) * pocket * 0.62)
	draw_polyline(groove, Palette.WOOD_DARK if not flooded else Palette.FOAM, 2.0)
	var face_post := _scotia_post(center, facing, sx, sy, reach, thick, pocket)
	var back_post := _scotia_post(center, back, sx, sy, reach, thick, pocket)
	draw_rect(face_post, post)
	draw_rect(back_post, post)
	draw_rect(face_post, edge, false, 2.5)
	draw_rect(back_post, edge, false, 2.5)
	_scotia_fillet(face_post, facing, flooded)
	_scotia_fillet(back_post, back, flooded)

func _draw_torus(at: Vector2i, rot: int) -> void:
	# Two rounded beads on the opposite edge and the clockwise edge, with a
	# pale gap between them. A north torus puts the beads on the south and
	# east edges. The beads are round and pale. They are not the scotia's two
	# dark posts, and they are not the astragal's iron bars.
	var center := _center(at)
	var facing := Tracer.torus_facing(rot)
	var opposite := Tracer.rotate_dir(facing, 2)
	var clock := Tracer.rotate_dir(facing, 1)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var sx := 1.0 if opposite == "E" or clock == "E" else -1.0
	var sy := 1.0 if opposite == "S" or clock == "S" else -1.0
	var bead_r := cell * 0.115
	var along := cell * 0.05
	var edge := cell * 0.34
	var opp_at := center + Vector2(sx * along, sy * edge)
	var clock_at := center + Vector2(sx * edge, sy * along)
	var gap_at := (opp_at + clock_at) * 0.5
	var gap := Palette.GLASS
	gap.a = 0.42 if flooded else 0.98
	draw_circle(gap_at, cell * 0.075, gap)
	draw_arc(gap_at, cell * 0.075, 0.0, TAU, 16, Palette.GLASS_EDGE, 1.5)
	var bead := Palette.GATE if not flooded else Palette.WOOD
	var rim := Palette.LANTERN if not flooded else Palette.FOAM
	var highlight := Color(1, 1, 1, 0.28 if flooded else 0.72)
	for bead_at in [opp_at, clock_at]:
		draw_circle(bead_at, bead_r, bead)
		draw_arc(bead_at, bead_r, 0.0, TAU, 20, rim, 2.5)
		draw_circle(bead_at + Vector2(-bead_r * 0.28, -bead_r * 0.28), bead_r * 0.32, highlight)

func _draw_ogee(at: Vector2i, rot: int) -> void:
	# A pale S-curve on the opposite edge and the counterclockwise edge.
	# A north ogee puts the curve on the south and west edges. The curve is
	# an S of pale glass. It is not the torus's round beads, and it is not
	# the scotia's two dark posts.
	var center := _center(at)
	var facing := Tracer.ogee_facing(rot)
	var opposite := Tracer.rotate_dir(facing, 2)
	var back := Tracer.rotate_dir(facing, -1)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var curve := Palette.GLASS if not flooded else Palette.FOAM
	var shade := Palette.TIDE if not flooded else Palette.WOOD
	_ogee_curve(center, opposite, curve, shade)
	_ogee_curve(center, back, curve, shade)

func _ogee_curve(center: Vector2, dir: String, curve: Color, shade: Color) -> void:
	var along := Vector2.RIGHT
	var outward := Vector2.DOWN
	match dir:
		"N":
			along = Vector2.RIGHT
			outward = Vector2.UP
		"S":
			along = Vector2.RIGHT
			outward = Vector2.DOWN
		"E":
			along = Vector2.DOWN
			outward = Vector2.RIGHT
		_:
			along = Vector2.DOWN
			outward = Vector2.LEFT
	var edge := cell * 0.36
	var amp := cell * 0.11
	var half := cell * 0.28
	var origin := center + outward * edge - along * half
	var steps := 16
	var spine := PackedVector2Array()
	var inner := PackedVector2Array()
	for i in steps + 1:
		var t := float(i) / float(steps)
		var bow := sin(t * TAU)
		var at := origin + along * (half * 2.0 * t) + outward * (amp * bow)
		spine.append(at)
		inner.append(at - outward * (cell * 0.035))
	draw_polyline(spine, curve, 3.5)
	draw_polyline(inner, shade, 1.75)

func _draw_ovolo(at: Vector2i, rot: int) -> void:
	# A pale convex bow on every open edge. A north ovolo bows on the east,
	# south, and west edges. Each bow is one quarter-round hump. It is not
	# the torus beads, not the scotia posts, and not the ogee S-curve.
	var center := _center(at)
	var facing := Tracer.ovolo_facing(rot)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var bow := Palette.GLASS if not flooded else Palette.FOAM
	var shade := Palette.TIDE if not flooded else Palette.WOOD
	for dir in ["N", "E", "S", "W"]:
		if dir == facing:
			continue
		_ovolo_bow(center, dir, bow, shade)

func _ovolo_bow(center: Vector2, dir: String, bow: Color, shade: Color) -> void:
	var along := Vector2.RIGHT
	var outward := Vector2.DOWN
	match dir:
		"N":
			along = Vector2.RIGHT
			outward = Vector2.UP
		"S":
			along = Vector2.RIGHT
			outward = Vector2.DOWN
		"E":
			along = Vector2.DOWN
			outward = Vector2.RIGHT
		_:
			along = Vector2.DOWN
			outward = Vector2.LEFT
	var edge := cell * 0.34
	var rise := cell * 0.13
	var half := cell * 0.24
	var origin := center + outward * edge - along * half
	var steps := 12
	var spine := PackedVector2Array()
	var inner := PackedVector2Array()
	for i in steps + 1:
		var t := float(i) / float(steps)
		var hump := sin(t * PI)
		var bow_at := origin + along * (half * 2.0 * t) + outward * (rise * hump)
		spine.append(bow_at)
		inner.append(bow_at - outward * (cell * 0.04))
	draw_polyline(spine, bow, 4.0)
	draw_polyline(inner, shade, 1.6)

func _draw_cavetto(at: Vector2i, rot: int) -> void:
	# A pale inward notch on every open edge. A north cavetto notches the
	# north, east, and west edges. The notch is a V cut into the glass. It is
	# not the torus beads, not the scotia posts, not the ogee S-curve, and
	# not the ovolo bow.
	var center := _center(at)
	var facing := Tracer.cavetto_facing(rot)
	var stopped := Tracer.rotate_dir(facing, 2)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var notch := Palette.GLASS if not flooded else Palette.FOAM
	var shade := Palette.WOOD_DARK if not flooded else Palette.WOOD
	for dir in ["N", "E", "S", "W"]:
		if dir == stopped:
			continue
		_cavetto_notch(center, dir, notch, shade)

func _cavetto_notch(center: Vector2, dir: String, notch: Color, shade: Color) -> void:
	var along := Vector2.RIGHT
	var outward := Vector2.DOWN
	match dir:
		"N":
			along = Vector2.RIGHT
			outward = Vector2.UP
		"S":
			along = Vector2.RIGHT
			outward = Vector2.DOWN
		"E":
			along = Vector2.DOWN
			outward = Vector2.RIGHT
		_:
			along = Vector2.DOWN
			outward = Vector2.LEFT
	var edge := cell * 0.36
	var depth := cell * 0.18
	var half := cell * 0.20
	var mouth := center + outward * edge
	var left := mouth - along * half
	var right := mouth + along * half
	var tip := mouth - outward * depth
	var fill := PackedVector2Array([left, tip, right])
	draw_colored_polygon(fill, notch)
	draw_polyline(PackedVector2Array([left, tip, right]), shade, 2.2)

func _draw_fillet(at: Vector2i, rot: int) -> void:
	# A thin pale flat band on the one passing edge. A north fillet bands the
	# south edge. The band is a straight rectangle. It is not the cavetto
	# notch, not the ovolo bow, and not the ogee S-curve.
	var center := _center(at)
	var passing := Tracer.rotate_dir(Tracer.fillet_facing(rot), 2)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var band := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	_fillet_band(center, passing, band)

func _fillet_band(center: Vector2, dir: String, band: Color) -> void:
	var along := Vector2.RIGHT
	var outward := Vector2.DOWN
	match dir:
		"N":
			along = Vector2.RIGHT
			outward = Vector2.UP
		"S":
			along = Vector2.RIGHT
			outward = Vector2.DOWN
		"E":
			along = Vector2.DOWN
			outward = Vector2.RIGHT
		_:
			along = Vector2.DOWN
			outward = Vector2.LEFT
	var edge := cell * 0.34
	var thick := cell * 0.07
	var half := cell * 0.26
	var outer := center + outward * edge
	var inner := outer - outward * thick
	var rect := PackedVector2Array([
		outer - along * half,
		outer + along * half,
		inner + along * half,
		inner - along * half,
	])
	draw_colored_polygon(rect, band)

func _draw_corona(at: Vector2i, rot: int) -> void:
	# A thin pale shelf on each passing edge. A north corona shelves the east
	# and west edges. Each shelf is a flat ledge. It is not the fillet's
	# single band and not the cavetto's inward V-notch.
	var center := _center(at)
	var facing := Tracer.corona_facing(rot)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var shelf := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	var lip := Palette.GLASS if not flooded else Palette.TIDE
	for turn in [1, -1]:
		_corona_shelf(center, Tracer.rotate_dir(facing, turn), shelf, lip)

func _corona_shelf(center: Vector2, dir: String, shelf: Color, lip: Color) -> void:
	var along := Vector2.RIGHT
	var outward := Vector2.DOWN
	match dir:
		"N":
			along = Vector2.RIGHT
			outward = Vector2.UP
		"S":
			along = Vector2.RIGHT
			outward = Vector2.DOWN
		"E":
			along = Vector2.DOWN
			outward = Vector2.RIGHT
		_:
			along = Vector2.DOWN
			outward = Vector2.LEFT
	var edge := cell * 0.40
	var thick := cell * 0.05
	var half := cell * 0.32
	var outer := center + outward * edge
	var inner := outer - outward * thick
	var rect := PackedVector2Array([
		outer - along * half,
		outer + along * half,
		inner + along * half,
		inner - along * half,
	])
	draw_colored_polygon(rect, shelf)
	draw_line(inner - along * half, inner + along * half, lip, 1.4)

func _draw_bead(at: Vector2i, rot: int) -> void:
	# One small square pip on the single clockwise edge. A north bead marks
	# the east edge. The pip is square. It is not the torus's two round beads,
	# not the fillet's band, and not the corona's two shelves.
	var center := _center(at)
	var passing := Tracer.rotate_dir(Tracer.bead_facing(rot), 1)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var pip := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	var outward := Vector2.DOWN
	match passing:
		"N":
			outward = Vector2.UP
		"S":
			outward = Vector2.DOWN
		"E":
			outward = Vector2.RIGHT
		_:
			outward = Vector2.LEFT
	var half := cell * 0.07
	var spot := center + outward * cell * 0.34
	var rect := Rect2(spot - Vector2(half, half), Vector2(half * 2.0, half * 2.0))
	draw_rect(rect, pip)

func _draw_quirk(at: Vector2i, rot: int) -> void:
	# One small pale diamond on the single counterclockwise edge. A north quirk
	# marks the west edge. The mark is a diamond. It is not the bead's square
	# pip, not the fillet's band, and not the corona's two shelves.
	var center := _center(at)
	var passing := Tracer.rotate_dir(Tracer.quirk_facing(rot), -1)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var pip := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	var outward := Vector2.LEFT
	match passing:
		"N":
			outward = Vector2.UP
		"S":
			outward = Vector2.DOWN
		"E":
			outward = Vector2.RIGHT
		_:
			outward = Vector2.LEFT
	var half := cell * 0.08
	var spot := center + outward * cell * 0.34
	var diamond := PackedVector2Array([
		spot + Vector2(0, -half),
		spot + Vector2(half, 0),
		spot + Vector2(0, half),
		spot + Vector2(-half, 0),
	])
	draw_colored_polygon(diamond, pip)

func _draw_cyma(at: Vector2i, rot: int) -> void:
	# A short pale wave on the facing edge. A north cyma marks the north edge.
	# The wave is not the quirk's diamond and not the bead's square pip.
	var center := _center(at)
	var passing := Tracer.cyma_facing(rot)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var wave := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	var outward := Vector2.UP
	var along := Vector2.RIGHT
	match passing:
		"N":
			outward = Vector2.UP
			along = Vector2.RIGHT
		"S":
			outward = Vector2.DOWN
			along = Vector2.RIGHT
		"E":
			outward = Vector2.RIGHT
			along = Vector2.DOWN
		_:
			outward = Vector2.LEFT
			along = Vector2.DOWN
	var half := cell * 0.16
	var spot := center + outward * cell * 0.30
	var left := spot - along * half + outward * cell * 0.06
	var mid := spot - outward * cell * 0.05
	var right := spot + along * half + outward * cell * 0.06
	draw_line(left, mid, wave, 2.2)
	draw_line(mid, right, wave, 2.2)

func _draw_fascia(at: Vector2i, rot: int) -> void:
	# Two short pale ticks on the stopped clockwise edge. A north fascia marks
	# the east edge. The ticks are not the cyma's wave and not the fillet's band.
	var center := _center(at)
	var stopped := Tracer.rotate_dir(Tracer.fascia_facing(rot), 1)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var mark := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	var outward := Vector2.RIGHT
	var along := Vector2.DOWN
	match stopped:
		"N":
			outward = Vector2.UP
			along = Vector2.RIGHT
		"S":
			outward = Vector2.DOWN
			along = Vector2.RIGHT
		"E":
			outward = Vector2.RIGHT
			along = Vector2.DOWN
		_:
			outward = Vector2.LEFT
			along = Vector2.DOWN
	var spot := center + outward * cell * 0.32
	var gap := cell * 0.05
	var reach := cell * 0.11
	draw_line(spot - along * (gap + reach), spot - along * gap, mark, 2.4)
	draw_line(spot + along * gap, spot + along * (gap + reach), mark, 2.4)

func _draw_soffit(at: Vector2i, rot: int) -> void:
	# One short pale bar on the stopped counterclockwise edge. A north soffit
	# marks the west edge. The bar is not the fascia's two ticks.
	var center := _center(at)
	var stopped := Tracer.rotate_dir(Tracer.soffit_facing(rot), -1)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var mark := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	var outward := Vector2.LEFT
	var along := Vector2.DOWN
	match stopped:
		"N":
			outward = Vector2.UP
			along = Vector2.RIGHT
		"S":
			outward = Vector2.DOWN
			along = Vector2.RIGHT
		"E":
			outward = Vector2.RIGHT
			along = Vector2.DOWN
		_:
			outward = Vector2.LEFT
			along = Vector2.DOWN
	var spot := center + outward * cell * 0.30
	var half := cell * 0.14
	draw_line(spot - along * half, spot + along * half, mark, 3.2)

func _draw_drip(at: Vector2i, rot: int) -> void:
	# A pale drop on the dry-stopped edge, which is the edge that opens under
	# water. A north drip marks the west edge. The drop is not the soffit's bar.
	var center := _center(at)
	var marked := Tracer.rotate_dir(Tracer.drip_facing(rot), -1)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var drop := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	var outward := Vector2.LEFT
	match marked:
		"N":
			outward = Vector2.UP
		"S":
			outward = Vector2.DOWN
		"E":
			outward = Vector2.RIGHT
		_:
			outward = Vector2.LEFT
	var spot := center + outward * cell * 0.30
	draw_circle(spot, cell * 0.07, drop)

func _draw_beak(at: Vector2i, rot: int) -> void:
	# A pale point on the dry-stopped clockwise edge, which opens under water.
	# A north beak marks the east edge. The point is not the drip's circle.
	var center := _center(at)
	var marked := Tracer.rotate_dir(Tracer.beak_facing(rot), 1)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var tip := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	var outward := Vector2.RIGHT
	var along := Vector2.DOWN
	match marked:
		"N":
			outward = Vector2.UP
			along = Vector2.RIGHT
		"S":
			outward = Vector2.DOWN
			along = Vector2.RIGHT
		"E":
			outward = Vector2.RIGHT
			along = Vector2.DOWN
		_:
			outward = Vector2.LEFT
			along = Vector2.DOWN
	var nose := center + outward * cell * 0.34
	var base := center + outward * cell * 0.18
	draw_colored_polygon(PackedVector2Array([
		nose,
		base + along * cell * 0.08,
		base - along * cell * 0.08,
	]), tip)

func _draw_hood(at: Vector2i, rot: int) -> void:
	# A wide pale cap on the facing edge, the edge that opens under water.
	# A north hood caps the north edge. The cap is not the beak's point and
	# not the ovolo's bow.
	var center := _center(at)
	var marked := Tracer.hood_facing(rot)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var cap := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	var outward := Vector2.UP
	var along := Vector2.RIGHT
	match marked:
		"N":
			outward = Vector2.UP
			along = Vector2.RIGHT
		"S":
			outward = Vector2.DOWN
			along = Vector2.RIGHT
		"E":
			outward = Vector2.RIGHT
			along = Vector2.DOWN
		_:
			outward = Vector2.LEFT
			along = Vector2.DOWN
	var brim := center + outward * cell * 0.22
	var eave := center + outward * cell * 0.34
	var half := cell * 0.22
	var lip := cell * 0.12
	draw_colored_polygon(PackedVector2Array([
		brim - along * half,
		brim + along * half,
		eave + along * lip,
		eave - along * lip,
	]), cap)

func _draw_throat(at: Vector2i, rot: int) -> void:
	# Two pale posts with a gap on the opposite edge, the edge that opens
	# under water. A north throat marks the south edge. The gap is not the
	# hood's cap and not the beak's point.
	var center := _center(at)
	var marked := Tracer.rotate_dir(Tracer.throat_facing(rot), 2)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var post := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	var outward := Vector2.DOWN
	var along := Vector2.RIGHT
	match marked:
		"N":
			outward = Vector2.UP
			along = Vector2.RIGHT
		"S":
			outward = Vector2.DOWN
			along = Vector2.RIGHT
		"E":
			outward = Vector2.RIGHT
			along = Vector2.DOWN
		_:
			outward = Vector2.LEFT
			along = Vector2.DOWN
	var edge := center + outward * cell * 0.30
	var inner := center + outward * cell * 0.16
	var gap := cell * 0.06
	var reach := cell * 0.18
	draw_colored_polygon(PackedVector2Array([
		inner + along * gap,
		inner + along * reach,
		edge + along * reach,
		edge + along * gap,
	]), post)
	draw_colored_polygon(PackedVector2Array([
		inner - along * gap,
		inner - along * reach,
		edge - along * reach,
		edge - along * gap,
	]), post)

func _draw_larmier(at: Vector2i, rot: int) -> void:
	# A short pale cap on the facing and on the opposite. A north larmier marks
	# the north edge and the south edge. The caps are not the corona's side
	# shelves and not the throat's gap.
	var center := _center(at)
	var facing := Tracer.larmier_facing(rot)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var cap := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	for turn in [0, 2]:
		var marked := Tracer.rotate_dir(facing, turn)
		var outward := Vector2.UP
		var along := Vector2.RIGHT
		match marked:
			"N":
				outward = Vector2.UP
				along = Vector2.RIGHT
			"S":
				outward = Vector2.DOWN
				along = Vector2.RIGHT
			"E":
				outward = Vector2.RIGHT
				along = Vector2.DOWN
			_:
				outward = Vector2.LEFT
				along = Vector2.DOWN
		var brim := center + outward * cell * 0.28
		var eave := center + outward * cell * 0.38
		var half := cell * 0.10
		var lip := cell * 0.05
		draw_colored_polygon(PackedVector2Array([
			brim - along * half,
			brim + along * half,
			eave + along * lip,
			eave - along * lip,
		]), cap)

func _draw_cill(at: Vector2i, rot: int) -> void:
	# A pale bar along the dry-stopped axis. A north cill bars east and west.
	# The bar is not the larmier's end caps and not the corona's side shelves.
	var center := _center(at)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var bar := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	var along_dir := Tracer.rotate_dir(Tracer.cill_facing(rot), 1)
	var along := Vector2.RIGHT if along_dir == "E" or along_dir == "W" else Vector2.DOWN
	var half := cell * 0.32
	var thick := cell * 0.08
	draw_colored_polygon(PackedVector2Array([
		center - along * half - along.orthogonal() * thick,
		center + along * half - along.orthogonal() * thick,
		center + along * half + along.orthogonal() * thick,
		center - along * half + along.orthogonal() * thick,
	]), bar)

func _draw_threshold(at: Vector2i, rot: int) -> void:
	# A low broken step on the opposite edge, the dry pass. A north threshold
	# steps the south edge. The gap in the step is not the fillet's solid band
	# and not the throat's two posts.
	var center := _center(at)
	var passing := Tracer.rotate_dir(Tracer.threshold_facing(rot), 2)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var step := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	var along := Vector2.RIGHT
	var outward := Vector2.DOWN
	match passing:
		"N":
			along = Vector2.RIGHT
			outward = Vector2.UP
		"S":
			along = Vector2.RIGHT
			outward = Vector2.DOWN
		"E":
			along = Vector2.DOWN
			outward = Vector2.RIGHT
		_:
			along = Vector2.DOWN
			outward = Vector2.LEFT
	var edge := center + outward * cell * 0.36
	var inner := center + outward * cell * 0.18
	var gap := cell * 0.05
	var reach := cell * 0.16
	draw_colored_polygon(PackedVector2Array([
		inner + along * gap,
		inner + along * reach,
		edge + along * reach,
		edge + along * gap,
	]), step)
	draw_colored_polygon(PackedVector2Array([
		inner - along * gap,
		inner - along * reach,
		edge - along * reach,
		edge - along * gap,
	]), step)

func _draw_impost(at: Vector2i, rot: int) -> void:
	# A keystone on the facing edge, the dry pass. A north impost caps the
	# north edge. The cap is wider than the cyma's wave and is not the
	# threshold's broken step.
	var center := _center(at)
	var passing := Tracer.impost_facing(rot)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var stone := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	var along := Vector2.RIGHT
	var outward := Vector2.UP
	match passing:
		"N":
			along = Vector2.RIGHT
			outward = Vector2.UP
		"S":
			along = Vector2.RIGHT
			outward = Vector2.DOWN
		"E":
			along = Vector2.DOWN
			outward = Vector2.RIGHT
		_:
			along = Vector2.DOWN
			outward = Vector2.LEFT
	var outer := center + outward * cell * 0.38
	var inner := center + outward * cell * 0.16
	var wide := cell * 0.18
	var narrow := cell * 0.08
	draw_colored_polygon(PackedVector2Array([
		inner + along * narrow,
		inner - along * narrow,
		outer - along * wide,
		outer + along * wide,
	]), stone)

func _draw_architrave(at: Vector2i, rot: int) -> void:
	# Two short posts on the perpendicular edges, the dry pass, and a cap on
	# the facing. A north architrave posts the east and west edges. The posts
	# are narrower than the corona's shelves.
	var center := _center(at)
	var facing := Tracer.architrave_facing(rot)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var mark := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	for turn in [1, -1]:
		_architrave_post(center, Tracer.rotate_dir(facing, turn), mark)
	_architrave_cap(center, facing, mark)

func _architrave_post(center: Vector2, dir: String, mark: Color) -> void:
	var along := Vector2.RIGHT
	var outward := Vector2.DOWN
	match dir:
		"N":
			along = Vector2.RIGHT
			outward = Vector2.UP
		"S":
			along = Vector2.RIGHT
			outward = Vector2.DOWN
		"E":
			along = Vector2.DOWN
			outward = Vector2.RIGHT
		_:
			along = Vector2.DOWN
			outward = Vector2.LEFT
	var edge := center + outward * cell * 0.34
	var inner := center + outward * cell * 0.18
	var half := cell * 0.07
	draw_colored_polygon(PackedVector2Array([
		inner - along * half,
		inner + along * half,
		edge + along * half,
		edge - along * half,
	]), mark)

func _architrave_cap(center: Vector2, dir: String, mark: Color) -> void:
	var along := Vector2.RIGHT
	var outward := Vector2.UP
	match dir:
		"N":
			along = Vector2.RIGHT
			outward = Vector2.UP
		"S":
			along = Vector2.RIGHT
			outward = Vector2.DOWN
		"E":
			along = Vector2.DOWN
			outward = Vector2.RIGHT
		_:
			along = Vector2.DOWN
			outward = Vector2.LEFT
	var tip := center + outward * cell * 0.22
	var base := center + outward * cell * 0.08
	draw_colored_polygon(PackedVector2Array([
		base - along * cell * 0.05,
		base + along * cell * 0.05,
		tip,
	]), mark)

func _draw_archivolt(at: Vector2i, rot: int) -> void:
	# A curved band on the facing, the dry stop, and an open notch on each
	# perpendicular edge, the flood pass. A north archivolt arches the north
	# edge and notches east and west. The band is curved. It is not the
	# architrave's two posts and not the corona's two shelves.
	var center := _center(at)
	var facing := Tracer.archivolt_facing(rot)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var mark := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	_archivolt_arch(center, facing, mark)
	for turn in [1, -1]:
		_archivolt_notch(center, Tracer.rotate_dir(facing, turn), mark)

func _archivolt_arch(center: Vector2, dir: String, mark: Color) -> void:
	var along := Vector2.RIGHT
	var outward := Vector2.UP
	match dir:
		"N":
			along = Vector2.RIGHT
			outward = Vector2.UP
		"S":
			along = Vector2.RIGHT
			outward = Vector2.DOWN
		"E":
			along = Vector2.DOWN
			outward = Vector2.RIGHT
		_:
			along = Vector2.DOWN
			outward = Vector2.LEFT
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	for i in 7:
		var ang := lerpf(-PI * 0.5, PI * 0.5, float(i) / 6.0)
		var side := along * sin(ang) + outward * cos(ang)
		outer.append(center + side * cell * 0.40)
		inner.append(center + side * cell * 0.26)
	for i in 6:
		draw_colored_polygon(PackedVector2Array([outer[i], outer[i + 1], inner[i + 1], inner[i]]), mark)

func _archivolt_notch(center: Vector2, dir: String, mark: Color) -> void:
	var along := Vector2.RIGHT
	var outward := Vector2.DOWN
	match dir:
		"N":
			along = Vector2.RIGHT
			outward = Vector2.UP
		"S":
			along = Vector2.RIGHT
			outward = Vector2.DOWN
		"E":
			along = Vector2.DOWN
			outward = Vector2.RIGHT
		_:
			along = Vector2.DOWN
			outward = Vector2.LEFT
	var tip := center + outward * cell * 0.34
	var base := center + outward * cell * 0.14
	draw_line(base - along * cell * 0.10, tip, mark, 2.0)
	draw_line(base + along * cell * 0.10, tip, mark, 2.0)

func _draw_abacus(at: Vector2i, rot: int) -> void:
	# A flat square slab, the capital's abacus, with a peg on the facing.
	# A north abacus lays the slab across the upper half and pegs the north
	# edge. The slab is square-ended. It is not the archivolt's arch and not
	# the architrave's two posts.
	var center := _center(at)
	var facing := Tracer.abacus_facing(rot)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var mark := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	_abacus_slab(center, facing, mark)
	_abacus_peg(center, facing, mark)

func _abacus_slab(center: Vector2, dir: String, mark: Color) -> void:
	var along := Vector2.RIGHT
	var outward := Vector2.UP
	match dir:
		"N":
			along = Vector2.RIGHT
			outward = Vector2.UP
		"S":
			along = Vector2.RIGHT
			outward = Vector2.DOWN
		"E":
			along = Vector2.DOWN
			outward = Vector2.RIGHT
		_:
			along = Vector2.DOWN
			outward = Vector2.LEFT
	var outer := center + outward * cell * 0.34
	var inner := center + outward * cell * 0.08
	var half := cell * 0.36
	draw_colored_polygon(PackedVector2Array([
		inner - along * half,
		inner + along * half,
		outer + along * half,
		outer - along * half,
	]), mark)

func _abacus_peg(center: Vector2, dir: String, mark: Color) -> void:
	var along := Vector2.RIGHT
	var outward := Vector2.UP
	match dir:
		"N":
			along = Vector2.RIGHT
			outward = Vector2.UP
		"S":
			along = Vector2.RIGHT
			outward = Vector2.DOWN
		"E":
			along = Vector2.DOWN
			outward = Vector2.RIGHT
		_:
			along = Vector2.DOWN
			outward = Vector2.LEFT
	var tip := center + outward * cell * 0.42
	var base := center + outward * cell * 0.30
	var half := cell * 0.07
	draw_colored_polygon(PackedVector2Array([
		base - along * half,
		base + along * half,
		tip + along * half,
		tip - along * half,
	]), mark)

func _draw_rebate(at: Vector2i, rot: int) -> void:
	# A rectangular recess open on the opposite edge. A north rebate leaves
	# the south side open. It is not the abacus slab and not the archivolt arch.
	var center := _center(at)
	var facing := Tracer.rebate_facing(rot)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var mark := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	var gap := "S"
	match facing:
		"N":
			gap = "S"
		"S":
			gap = "N"
		"E":
			gap = "W"
		_:
			gap = "E"
	_rebate_channel(center, gap, mark)

func _rebate_channel(center: Vector2, gap: String, mark: Color) -> void:
	var along := Vector2.RIGHT
	var outward := Vector2.DOWN
	match gap:
		"S":
			along = Vector2.RIGHT
			outward = Vector2.DOWN
		"N":
			along = Vector2.RIGHT
			outward = Vector2.UP
		"W":
			along = Vector2.DOWN
			outward = Vector2.LEFT
		_:
			along = Vector2.DOWN
			outward = Vector2.RIGHT
	var half := cell * 0.34
	var thick := cell * 0.08
	var back := center - outward * cell * 0.28
	var side := cell * 0.28
	draw_colored_polygon(PackedVector2Array([
		back - along * half,
		back + along * half,
		back + along * half - outward * thick,
		back - along * half - outward * thick,
	]), mark)
	var cheek := center + outward * cell * 0.16
	draw_colored_polygon(PackedVector2Array([
		back - along * half,
		back - along * half + along * thick,
		cheek - along * side + along * thick,
		cheek - along * side,
	]), mark)
	draw_colored_polygon(PackedVector2Array([
		back + along * half,
		back + along * half - along * thick,
		cheek + along * side - along * thick,
		cheek + along * side,
	]), mark)

func _draw_echinus(at: Vector2i, rot: int) -> void:
	# A convex quarter-round under the capital, bulging toward the facing,
	# with a tick on the clockwise edge. It is not the rebate's open channel.
	var center := _center(at)
	var facing := Tracer.echinus_facing(rot)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var mark := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	_echinus_bulge(center, facing, mark)
	_echinus_tick(center, facing, mark)

func _echinus_bulge(center: Vector2, dir: String, mark: Color) -> void:
	var along := Vector2.RIGHT
	var outward := Vector2.UP
	match dir:
		"N":
			along = Vector2.RIGHT
			outward = Vector2.UP
		"S":
			along = Vector2.RIGHT
			outward = Vector2.DOWN
		"E":
			along = Vector2.DOWN
			outward = Vector2.RIGHT
		_:
			along = Vector2.DOWN
			outward = Vector2.LEFT
	var root := center - outward * cell * 0.06
	var crown := center + outward * cell * 0.36
	var hip := cell * 0.30
	draw_colored_polygon(PackedVector2Array([
		root - along * hip,
		root + along * hip,
		root + along * hip * 0.55 + outward * cell * 0.22,
		crown,
		root - along * hip * 0.55 + outward * cell * 0.22,
	]), mark)

func _echinus_tick(center: Vector2, dir: String, mark: Color) -> void:
	var clock := Vector2.RIGHT
	match dir:
		"N":
			clock = Vector2.RIGHT
		"E":
			clock = Vector2.DOWN
		"S":
			clock = Vector2.LEFT
		_:
			clock = Vector2.UP
	var inner := center + clock * cell * 0.18
	var outer := center + clock * cell * 0.40
	var half := cell * 0.06
	var across := Vector2(-clock.y, clock.x)
	draw_colored_polygon(PackedVector2Array([
		inner - across * half,
		inner + across * half,
		outer + across * half,
		outer - across * half,
	]), mark)

func _draw_annulet(at: Vector2i, rot: int) -> void:
	# A small closed ring, with a tick on the counterclockwise edge. It is
	# not the echinus bulge and not the rebate's open channel.
	var center := _center(at)
	var facing := Tracer.annulet_facing(rot)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var mark := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	_annulet_ring(center, mark)
	var counter := "W"
	match facing:
		"N":
			counter = "W"
		"E":
			counter = "N"
		"S":
			counter = "E"
		_:
			counter = "S"
	_annulet_tick(center, counter, mark)

func _annulet_ring(center: Vector2, mark: Color) -> void:
	var outer := cell * 0.34
	var inner := cell * 0.18
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-outer, -outer),
		center + Vector2(outer, -outer),
		center + Vector2(outer, -inner),
		center + Vector2(-outer, -inner),
	]), mark)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-outer, inner),
		center + Vector2(outer, inner),
		center + Vector2(outer, outer),
		center + Vector2(-outer, outer),
	]), mark)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-outer, -inner),
		center + Vector2(-inner, -inner),
		center + Vector2(-inner, inner),
		center + Vector2(-outer, inner),
	]), mark)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(inner, -inner),
		center + Vector2(outer, -inner),
		center + Vector2(outer, inner),
		center + Vector2(inner, inner),
	]), mark)

func _annulet_tick(center: Vector2, dir: String, mark: Color) -> void:
	var outward := Vector2.LEFT
	match dir:
		"N":
			outward = Vector2.UP
		"E":
			outward = Vector2.RIGHT
		"S":
			outward = Vector2.DOWN
		_:
			outward = Vector2.LEFT
	var across := Vector2(-outward.y, outward.x)
	var inner := center + outward * cell * 0.30
	var outer := center + outward * cell * 0.44
	var half := cell * 0.06
	draw_colored_polygon(PackedVector2Array([
		inner - across * half,
		inner + across * half,
		outer + across * half,
		outer - across * half,
	]), mark)

func _draw_listel(at: Vector2i, rot: int) -> void:
	# A narrow band with ticks on the facing and the clockwise edge. It is
	# thinner than the annulet ring.
	var center := _center(at)
	var facing := Tracer.listel_facing(rot)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var mark := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	var clock := "E"
	match facing:
		"N":
			clock = "E"
		"E":
			clock = "S"
		"S":
			clock = "W"
		_:
			clock = "N"
	_listel_band(center, facing, mark)
	_listel_tick(center, facing, mark)
	_listel_tick(center, clock, mark)

func _listel_band(center: Vector2, dir: String, mark: Color) -> void:
	var along := Vector2.RIGHT
	match dir:
		"N", "S":
			along = Vector2.RIGHT
		_:
			along = Vector2.DOWN
	var half := cell * 0.36
	var thick := cell * 0.05
	var across := Vector2(-along.y, along.x)
	draw_colored_polygon(PackedVector2Array([
		center - along * half - across * thick,
		center + along * half - across * thick,
		center + along * half + across * thick,
		center - along * half + across * thick,
	]), mark)

func _listel_tick(center: Vector2, dir: String, mark: Color) -> void:
	var outward := Vector2.UP
	match dir:
		"N":
			outward = Vector2.UP
		"E":
			outward = Vector2.RIGHT
		"S":
			outward = Vector2.DOWN
		_:
			outward = Vector2.LEFT
	var across := Vector2(-outward.y, outward.x)
	var inner := center + outward * cell * 0.08
	var outer := center + outward * cell * 0.28
	var half := cell * 0.045
	draw_colored_polygon(PackedVector2Array([
		inner - across * half,
		inner + across * half,
		outer + across * half,
		outer - across * half,
	]), mark)

func _draw_necking(at: Vector2i, rot: int) -> void:
	# A thin collar with ticks on the facing and the counterclockwise edge.
	# The collar stays square, unlike the listel's turning band.
	var center := _center(at)
	var facing := Tracer.necking_facing(rot)
	var flooded := Tracer.is_flooded(chart, puzzle_state, at)
	var mark := Palette.GLASS_EDGE if not flooded else Palette.FOAM
	var counter := "W"
	match facing:
		"N":
			counter = "W"
		"E":
			counter = "N"
		"S":
			counter = "E"
		_:
			counter = "S"
	var outer := cell * 0.34
	var inner := cell * 0.26
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-outer, -outer),
		center + Vector2(outer, -outer),
		center + Vector2(outer, -inner),
		center + Vector2(-outer, -inner),
	]), mark)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-outer, inner),
		center + Vector2(outer, inner),
		center + Vector2(outer, outer),
		center + Vector2(-outer, outer),
	]), mark)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-outer, -inner),
		center + Vector2(-inner, -inner),
		center + Vector2(-inner, inner),
		center + Vector2(-outer, inner),
	]), mark)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(inner, -inner),
		center + Vector2(outer, -inner),
		center + Vector2(outer, inner),
		center + Vector2(inner, inner),
	]), mark)
	_necking_tick(center, facing, mark)
	_necking_tick(center, counter, mark)

func _necking_tick(center: Vector2, dir: String, mark: Color) -> void:
	var outward := Vector2.UP
	match dir:
		"N":
			outward = Vector2.UP
		"E":
			outward = Vector2.RIGHT
		"S":
			outward = Vector2.DOWN
		_:
			outward = Vector2.LEFT
	var across := Vector2(-outward.y, outward.x)
	var inner := center + outward * cell * 0.36
	var outer := center + outward * cell * 0.48
	var half := cell * 0.04
	draw_colored_polygon(PackedVector2Array([
		inner - across * half,
		inner + across * half,
		outer + across * half,
		outer - across * half,
	]), mark)

func _scotia_post(center: Vector2, dir: String, sx: float, sy: float, reach: float, thick: float, pocket: float) -> Rect2:
	if dir == "N" or dir == "S":
		var y := center.y + sy * reach - (thick if sy > 0.0 else 0.0)
		var far := center.x - sx * reach
		var near := center.x + sx * (reach - pocket)
		return Rect2(Vector2(minf(far, near), y), Vector2(absf(near - far), thick))
	var x := center.x + sx * reach - (thick if sx > 0.0 else 0.0)
	var far_y := center.y - sy * reach
	var near_y := center.y + sy * (reach - pocket)
	return Rect2(Vector2(x, minf(far_y, near_y)), Vector2(thick, absf(near_y - far_y)))

func _scotia_fillet(post: Rect2, dir: String, flooded: bool) -> void:
	var fillet := Palette.GATE if not flooded else Palette.FOAM
	fillet.a = 0.95
	match dir:
		"N":
			draw_line(post.position + Vector2(3, post.size.y - 2), post.position + Vector2(post.size.x - 3, post.size.y - 2), fillet, 2.0)
		"S":
			draw_line(post.position + Vector2(3, 2), post.position + Vector2(post.size.x - 3, 2), fillet, 2.0)
		"W":
			draw_line(post.position + Vector2(post.size.x - 2, 3), post.position + Vector2(post.size.x - 2, post.size.y - 3), fillet, 2.0)
		_:
			draw_line(post.position + Vector2(2, 3), post.position + Vector2(2, post.size.y - 3), fillet, 2.0)

func _astragal_post(center: Vector2, dir: String, sx: float, sy: float, reach: float, thick: float, pocket: float) -> Rect2:
	if dir == "N" or dir == "S":
		var y := center.y + sy * reach - (thick if sy > 0.0 else 0.0)
		var far := center.x - sx * reach
		var near := center.x + sx * (reach - pocket)
		return Rect2(Vector2(minf(far, near), y), Vector2(absf(near - far), thick))
	var x := center.x + sx * reach - (thick if sx > 0.0 else 0.0)
	var far_y := center.y - sy * reach
	var near_y := center.y + sy * (reach - pocket)
	return Rect2(Vector2(x, minf(far_y, near_y)), Vector2(thick, absf(near_y - far_y)))

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
	if bool(dock.get("pass_other", false)):
		var slot := Rect2(wood.position.x + wood.size.x * 0.42, wood.position.y + 2.0, wood.size.x * 0.16, wood.size.y - 4.0)
		draw_rect(slot, Color(Palette.NIGHT.r, Palette.NIGHT.g, Palette.NIGHT.b, 0.55))
	var keep_dark := bool(dock.get("keep_dark", false))
	var required := "dark" if keep_dark else str(dock["color"])
	var hits: Array = trace.get("docks", {}).get(str(dock["id"]), [])
	var lamp := Palette.beam(required)
	lamp = lamp.darkened(0.55)
	if keep_dark:
		lamp = Color("243140") if hits.is_empty() else Palette.WARN
	elif hits.has(required):
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
