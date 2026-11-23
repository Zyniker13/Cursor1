extends Control

const Rules := preload("res://scripts/census_rules.gd")

signal run_finished(state)

const INK := Color(0.15, 0.10, 0.07)
const PARCHMENT := Color(0.90, 0.82, 0.64)
const PARCHMENT_DARK := Color(0.78, 0.68, 0.48)
const AMBER := Color(0.93, 0.68, 0.28)
const NIGHT := Color(0.06, 0.05, 0.08)

var state: Rules.RunState
var last_message := ""
var flash := 0.0
var return_button: Button
var _closed := false
var _mouse_x := 0.0
var _font: Font


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_font = ThemeDB.fallback_font
	return_button = Button.new()
	return_button.text = "Return to town"
	return_button.visible = false
	return_button.focus_mode = Control.FOCUS_NONE
	return_button.position = Vector2(928, 640)
	return_button.size = Vector2(328, 52)
	return_button.pressed.connect(_finish)
	_style_return(return_button)
	add_child(return_button)


func begin(next_state: Rules.RunState) -> void:
	state = next_state
	_closed = false
	flash = 0.0
	_mouse_x = 0.0
	last_message = "The square under your boots is already inked."
	return_button.text = "Return to town"
	return_button.visible = false
	queue_redraw()


func _process(delta: float) -> void:
	if not visible or state == null:
		return
	if flash > 0.0:
		flash = maxf(0.0, flash - delta * 1.5)
	queue_redraw()


func _input(event: InputEvent) -> void:
	if not visible or state == null:
		return
	if event is InputEventMouseMotion and state.end_reason == Rules.EndReason.NONE:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
			_turn_from_mouse(event.relative.x)
			get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if _on_key(event):
			get_viewport().set_input_as_handled()


func _turn_from_mouse(dx: float) -> void:
	_mouse_x += dx
	while _mouse_x >= 56.0:
		_mouse_x -= 56.0
		_apply(Rules.Action.TURN_RIGHT)
	while _mouse_x <= -56.0:
		_mouse_x += 56.0
		_apply(Rules.Action.TURN_LEFT)


func _on_key(event: InputEventKey) -> bool:
	var key := event.physical_keycode
	if key == 0:
		key = event.keycode
	if state.end_reason != Rules.EndReason.NONE:
		if key == KEY_ENTER or key == KEY_KP_ENTER or key == KEY_SPACE or key == KEY_ESCAPE:
			_finish()
		return true
	match key:
		KEY_LEFT, KEY_A:
			_apply(Rules.Action.TURN_LEFT)
		KEY_RIGHT, KEY_D:
			_apply(Rules.Action.TURN_RIGHT)
		KEY_UP, KEY_W:
			_apply(Rules.Action.FORWARD)
		KEY_DOWN, KEY_S:
			_apply(Rules.Action.BACK)
		KEY_Q:
			_apply(Rules.Action.STRAFE_LEFT)
		KEY_E:
			_apply(Rules.Action.STRAFE_RIGHT)
		KEY_SPACE, KEY_PERIOD:
			_apply(Rules.Action.WAIT)
		KEY_M:
			_apply(Rules.Action.MARK)
		KEY_ESCAPE:
			Rules.abandon(state)
			last_message = "You leave the sheet in the dark."
			_open_return()
		_:
			return false
	return true


func _apply(action: int) -> void:
	if state == null or state.end_reason != Rules.EndReason.NONE:
		return
	var result := Rules.act(state, action)
	last_message = String(result.message)
	if bool(result.hit):
		flash = 1.0
	if state.end_reason != Rules.EndReason.NONE:
		_open_return()


func _open_return() -> void:
	return_button.text = _return_caption()
	return_button.visible = true


func _return_caption() -> String:
	if state != null and state.end_reason == Rules.EndReason.EXTRACTED and Rules.census_accepted(state.marks, state.floor):
		return "Return to floor select"
	return "Return to town"


func _finish() -> void:
	if _closed or state == null:
		return
	_closed = true
	return_button.visible = false
	run_finished.emit(state)


func _draw() -> void:
	if _font == null:
		_font = ThemeDB.fallback_font
	var layout := _layout()
	draw_rect(Rect2(Vector2.ZERO, size if size.x > 32.0 else Vector2(2872, 720)), NIGHT)
	if state == null or state.floor == null:
		return
	_draw_view(layout.view)
	_draw_sheet(layout.sheet)
	_draw_hud(layout.hud)


func _layout() -> Dictionary:
	var vp := size
	if vp.x < 200.0:
		vp = Vector2(2872, 720)
	var margin := 16.0
	var hud_h := 200.0
	var sheet_w := minf(488.0, vp.x * 0.38)
	var view := Rect2(margin, margin, vp.x - sheet_w - margin * 3.0, vp.y - hud_h - margin)
	var sheet := Rect2(vp.x - sheet_w - margin, margin, sheet_w, view.size.y)
	var hud := Rect2(margin, view.position.y + view.size.y + 8.0, vp.x - margin * 2.0, vp.y - (view.position.y + view.size.y + 8.0) - 8.0)
	return {"view": view, "sheet": sheet, "hud": hud}


func _draw_view(view: Rect2) -> void:
	draw_rect(view.grow(4), Color(0.32, 0.22, 0.12))
	_draw_sky_floor(view)
	var cols := maxi(80, int(view.size.x / 3.0))
	var col_w := view.size.x / float(cols)
	var origin := Vector2(state.pos.x + 0.5, state.pos.y + 0.5)
	var angle := _facing_angle(state.facing)
	var dir := Vector2(cos(angle), sin(angle))
	var plane := Vector2(-sin(angle), cos(angle)) * tan(deg_to_rad(66.0) * 0.5)
	var zbuf := PackedFloat32Array()
	zbuf.resize(cols)
	for c in cols:
		var camera_x := 2.0 * float(c) / float(cols) - 1.0
		var ray := dir + plane * camera_x
		var hit := _cast(origin, ray)
		var dist: float = hit.dist
		if dist < 0.0001:
			dist = 0.0001
		zbuf[c] = dist
		var line_h := view.size.y / dist
		var y0 := view.position.y + (view.size.y - line_h) * 0.5
		var y1 := y0 + line_h
		var clip0 := maxf(y0, view.position.y)
		var clip1 := minf(y1, view.position.y + view.size.y)
		if clip1 <= clip0:
			continue
		var shade := clampf(1.15 - dist / 8.0, 0.08, 1.0)
		var cell: Vector2i = hit.cell
		var glyph := Rules.glyph_at(cell, state.floor)
		var col := Color(0.58, 0.40, 0.26)
		if state.floor.id == "cistern":
			col = Color(0.40, 0.45, 0.44)
		elif state.floor.id == "cloister":
			col = Color(0.64, 0.56, 0.42)
		elif state.floor.id == "crypt":
			col = Color(0.40, 0.36, 0.48)
		elif state.floor.id == "ossuary":
			col = Color(0.50, 0.48, 0.40)
		elif state.floor.id == "reliquary":
			col = Color(0.46, 0.22, 0.20)
		elif state.floor.id == "undercroft":
			col = Color(0.34, 0.40, 0.36)
		elif state.floor.id == "wellhouse":
			col = Color(0.48, 0.44, 0.34)
		elif state.floor.id == "scriptorium":
			col = Color(0.46, 0.32, 0.18)
		elif state.floor.id == "binding":
			col = Color(0.76, 0.70, 0.56)
		elif state.floor.id == "chartroom":
			col = Color(0.20, 0.28, 0.48)
		elif state.floor.id == "bellloft":
			col = Color(0.30, 0.28, 0.26)
		elif state.floor.id == "clockroom":
			col = Color(0.24, 0.14, 0.07)
		elif state.floor.id == "font":
			col = Color(0.55, 0.58, 0.50)
		elif state.floor.id == "apse":
			col = Color(0.72, 0.67, 0.55)
		elif state.floor.id == "choir":
			col = Color(0.30, 0.16, 0.07)
		elif state.floor.id == "rood":
			col = Color(0.28, 0.27, 0.25)
		elif state.floor.id == "crossing":
			col = Color(0.38, 0.36, 0.31)
		elif state.floor.id == "transept":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "ambulatory":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "chevet":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "retrochoir":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "ladychapel":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "feretory":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "chantry":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "sacristy":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "pyx":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "aumbry":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "piscina":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "sedilia":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "credence":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "reredos":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "predella":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "dossal":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "retable":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "tester":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "riddel":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "frontal":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "pall":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "herse":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "catafalque":
			col = Color(0.78, 0.66, 0.42)
		elif state.floor.id == "bier":
			col = Color(0.78, 0.66, 0.42)
		if glyph == "*":
			col = Color(0.14, 0.38, 0.42)
		elif glyph == "+":
			col = Color(0.12, 0.24, 0.16)
		elif glyph == "=":
			col = Color(0.74, 0.70, 0.60)
		elif glyph == "x":
			col = Color(0.86, 0.78, 0.58)
		elif glyph == "R":
			if state.floor.id == "rood":
				col = Color(0.22, 0.11, 0.06)
			else:
				col = Color(0.78, 0.58, 0.22)
		elif glyph == "B":
			col = Color(0.08, 0.26, 0.28)
		elif glyph == "W":
			col = Color(0.08, 0.18, 0.28)
		elif glyph == "D":
			col = Color(0.72, 0.62, 0.40)
		elif glyph == "P":
			col = Color(0.30, 0.31, 0.34)
		elif glyph == "T":
			col = Color(0.90, 0.88, 0.72)
		elif glyph == "Y":
			col = Color(0.80, 0.50, 0.22)
		elif glyph == "K":
			col = Color(0.93, 0.90, 0.78)
		elif glyph == "N":
			col = Color(0.14, 0.16, 0.15)
		elif glyph == "A":
			col = Color(0.93, 0.90, 0.82)
		elif glyph == "C":
			col = Color(0.89, 0.74, 0.46)
		elif glyph == "X":
			col = Color(0.15, 0.16, 0.19)
		elif glyph == "V":
			col = Color(0.82, 0.84, 0.80)
		elif glyph == "U":
			col = Color(0.86, 0.90, 0.94)
		elif glyph == "Q":
			col = Color(0.10, 0.12, 0.28)
		elif glyph == "O":
			col = Color(0.95, 0.82, 0.42)
		elif glyph == "M":
			col = Color(0.22, 0.38, 0.78)
		elif glyph == "J":
			col = Color(0.76, 0.73, 0.66)
		elif glyph == "I":
			col = Color(0.62, 0.14, 0.18)
		elif glyph == "G":
			col = Color(0.22, 0.12, 0.06)
		elif glyph == "F":
			col = Color(0.42, 0.32, 0.12)
		elif glyph == "Z":
			col = Color(0.62, 0.58, 0.50)
		elif glyph == "@":
			col = Color(0.50, 0.58, 0.60)
		elif glyph == "?":
			col = Color(0.56, 0.50, 0.42)
		elif glyph == ">":
			col = Color(0.74, 0.66, 0.50)
		elif glyph == "<":
			col = Color(0.70, 0.64, 0.54)
		elif glyph == "[":
			col = Color(0.62, 0.46, 0.36)
		elif glyph == "{":
			col = Color(0.58, 0.16, 0.20)
		elif glyph == "]":
			col = Color(0.72, 0.56, 0.18)
		elif glyph == "}":
			col = Color(0.30, 0.20, 0.36)
		elif glyph == "~":
			col = Color(0.38, 0.42, 0.52)
		elif glyph == "!":
			col = Color(0.16, 0.34, 0.28)
		elif glyph == "\"":
			col = Color(0.86, 0.82, 0.70)
		elif glyph == "$":
			col = Color(0.32, 0.34, 0.38)
		elif glyph == "%":
			col = Color(0.36, 0.22, 0.14)
		elif glyph == "&":
			col = Color(0.45, 0.28, 0.14)
		col *= shade
		if int(hit.side) == 1:
			col *= 0.74
		if glyph != "*" and glyph != "+" and glyph != "=" and glyph != "x" and glyph != "R" and glyph != "B" and glyph != "W" and glyph != "D" and glyph != "P" and glyph != "T" and glyph != "Y" and glyph != "K" and glyph != "N" and glyph != "A" and glyph != "C" and glyph != "X" and glyph != "V" and glyph != "U" and glyph != "Q" and glyph != "O" and glyph != "M" and glyph != "J" and glyph != "I" and glyph != "G" and glyph != "F" and glyph != "Z" and glyph != "@" and glyph != "?" and glyph != ">" and glyph != "<" and glyph != "[" and glyph != "{" and glyph != "]" and glyph != "}" and glyph != "~" and glyph != "!" and glyph != "\"" and glyph != "$" and glyph != "%" and glyph != "&" and (cell.x + cell.y) % 2 == 0:
			if state.floor.id == "cloister":
				col = col.lerp(Color(0.42, 0.34, 0.22), 0.22)
			elif state.floor.id == "crypt":
				col = col.lerp(Color(0.26, 0.22, 0.32), 0.22)
			elif state.floor.id == "ossuary":
				col = col.lerp(Color(0.32, 0.28, 0.20), 0.22)
			elif state.floor.id == "reliquary":
				col = col.lerp(Color(0.32, 0.12, 0.12), 0.22)
			elif state.floor.id == "undercroft":
				col = col.lerp(Color(0.14, 0.20, 0.16), 0.22)
			elif state.floor.id == "wellhouse":
				col = col.lerp(Color(0.24, 0.22, 0.14), 0.22)
			elif state.floor.id == "scriptorium":
				col = col.lerp(Color(0.28, 0.16, 0.08), 0.22)
			elif state.floor.id == "binding":
				col = col.lerp(Color(0.50, 0.42, 0.30), 0.22)
			elif state.floor.id == "chartroom":
				col = col.lerp(Color(0.08, 0.12, 0.28), 0.22)
			elif state.floor.id == "bellloft":
				col = col.lerp(Color(0.10, 0.09, 0.08), 0.22)
			elif state.floor.id == "clockroom":
				col = col.lerp(Color(0.08, 0.04, 0.02), 0.22)
			elif state.floor.id == "font":
				col = col.lerp(Color(0.32, 0.36, 0.28), 0.22)
			elif state.floor.id == "apse":
				col = col.lerp(Color(0.50, 0.44, 0.34), 0.22)
			elif state.floor.id == "choir":
				col = col.lerp(Color(0.14, 0.07, 0.03), 0.22)
			elif state.floor.id == "rood":
				col = col.lerp(Color(0.10, 0.10, 0.09), 0.22)
			elif state.floor.id == "crossing":
				col = col.lerp(Color(0.16, 0.15, 0.12), 0.22)
			elif state.floor.id == "transept":
				col = col.lerp(Color(0.52, 0.40, 0.22), 0.22)
			elif state.floor.id == "ambulatory":
				col = col.lerp(Color(0.52, 0.40, 0.22), 0.22)
			elif state.floor.id == "chevet":
				col = col.lerp(Color(0.52, 0.40, 0.22), 0.22)
			elif state.floor.id == "retrochoir":
				col = col.lerp(Color(0.52, 0.40, 0.22), 0.22)
			elif state.floor.id == "ladychapel":
				col = col.lerp(Color(0.52, 0.40, 0.22), 0.22)
			elif state.floor.id == "feretory":
				col = col.lerp(Color(0.52, 0.40, 0.22), 0.22)
			elif state.floor.id == "chantry":
				col = col.lerp(Color(0.52, 0.40, 0.22), 0.22)
			elif state.floor.id == "sacristy":
				col = col.lerp(Color(0.52, 0.40, 0.22), 0.22)
			elif state.floor.id == "pyx":
				col = col.lerp(Color(0.52, 0.40, 0.22), 0.22)
			elif state.floor.id == "aumbry":
				col = col.lerp(Color(0.52, 0.40, 0.22), 0.22)
			elif state.floor.id == "piscina":
				col = col.lerp(Color(0.52, 0.40, 0.22), 0.22)
			elif state.floor.id == "sedilia":
				col = col.lerp(Color(0.52, 0.40, 0.22), 0.22)
			elif state.floor.id == "credence":
				col = col.lerp(Color(0.52, 0.40, 0.22), 0.22)
			elif state.floor.id == "reredos":
				col = col.lerp(Color(0.40, 0.32, 0.28), 0.22)
			elif state.floor.id == "predella":
				col = col.lerp(Color(0.46, 0.30, 0.22), 0.22)
			elif state.floor.id == "dossal":
				col = col.lerp(Color(0.40, 0.12, 0.14), 0.22)
			elif state.floor.id == "retable":
				col = col.lerp(Color(0.36, 0.26, 0.10), 0.22)
			elif state.floor.id == "tester":
				col = col.lerp(Color(0.24, 0.16, 0.28), 0.22)
			elif state.floor.id == "riddel":
				col = col.lerp(Color(0.22, 0.24, 0.32), 0.22)
			elif state.floor.id == "frontal":
				col = col.lerp(Color(0.14, 0.24, 0.22), 0.22)
			elif state.floor.id == "pall":
				col = col.lerp(Color(0.42, 0.38, 0.30), 0.22)
			elif state.floor.id == "herse":
				col = col.lerp(Color(0.24, 0.24, 0.26), 0.22)
			elif state.floor.id == "catafalque":
				col = col.lerp(Color(0.28, 0.16, 0.12), 0.22)
			elif state.floor.id == "bier":
				col = col.lerp(Color(0.30, 0.18, 0.10), 0.22)
			else:
				col = col.lerp(Color(0.32, 0.20, 0.14), 0.22)
		var wall_x := origin.y + dist * ray.y if int(hit.side) == 0 else origin.x + dist * ray.x
		wall_x = wall_x - floor(wall_x)
		if wall_x < 0.08 or wall_x > 0.92:
			col = col.darkened(0.38)
		if glyph == "M":
			var fleck := int(wall_x * 11.0) + cell.x * 3 + cell.y * 5
			if fleck % 5 == 0:
				col = Color(0.96, 0.91, 0.68)
		if glyph == "J":
			if wall_x < 0.07 or wall_x > 0.93 or (wall_x > 0.46 and wall_x < 0.54):
				col = Color(0.88, 0.90, 0.92)
			elif wall_x > 0.20 and wall_x < 0.30:
				col = Color(0.58, 0.55, 0.50)
		if glyph == "I":
			if wall_x < 0.08 or wall_x > 0.92:
				col = Color(0.86, 0.68, 0.22)
			elif wall_x > 0.38 and wall_x < 0.62:
				col = Color(0.93, 0.84, 0.72)
			elif wall_x > 0.22 and wall_x < 0.38:
				col = Color(0.18, 0.28, 0.62)
			else:
				col = Color(0.62, 0.14, 0.18)
		if glyph == "G":
			if wall_x < 0.08 or wall_x > 0.92:
				col = Color(0.10, 0.06, 0.03)
			elif wall_x > 0.42 and wall_x < 0.58:
				col = Color(0.86, 0.82, 0.70)
			elif int(wall_x * 8.0) % 2 == 0:
				col = Color(0.28, 0.15, 0.07)
			else:
				col = Color(0.16, 0.09, 0.04)
		if glyph == "F":
			var bar := int(wall_x * 18.0)
			if wall_x > 0.44 and wall_x < 0.56:
				col = Color(0.93, 0.74, 0.28)
			elif wall_x > 0.40 and wall_x < 0.60:
				col = Color(0.10, 0.18, 0.36)
			elif bar % 2 == 0:
				col = Color(0.16, 0.16, 0.18)
			else:
				col = Color(0.46, 0.36, 0.14)
		if glyph == "Z":
			if wall_x < 0.14 or wall_x > 0.86:
				col = Color(0.74, 0.68, 0.56)
			elif wall_x > 0.40 and wall_x < 0.60:
				col = Color(0.07, 0.06, 0.05)
			elif wall_x > 0.30 and wall_x < 0.70:
				col = Color(0.50, 0.46, 0.40)
			else:
				col = Color(0.64, 0.58, 0.48)
		if glyph == "@":
			if wall_x < 0.12 or wall_x > 0.88:
				col = Color(0.72, 0.70, 0.62)
			elif wall_x > 0.47 and wall_x < 0.53:
				col = Color(0.06, 0.10, 0.14)
			elif wall_x > 0.32 and wall_x < 0.68:
				col = Color(0.40, 0.52, 0.56)
			else:
				col = Color(0.60, 0.58, 0.52)
		if glyph == "?":
			var seat := int(wall_x * 3.0)
			if seat > 2:
				seat = 2
			var frac := wall_x * 3.0 - float(seat)
			if frac < 0.18:
				col = Color(0.72, 0.68, 0.58)
			elif frac > 0.55 and frac < 0.80:
				col = Color(0.32, 0.28, 0.22)
			else:
				col = Color(0.58, 0.52, 0.44)
		if glyph == ">":
			if wall_x < 0.16 or wall_x > 0.84:
				col = Color(0.48, 0.40, 0.30)
			elif wall_x > 0.44 and wall_x < 0.56:
				col = Color(0.30, 0.22, 0.14)
			else:
				col = Color(0.82, 0.76, 0.62)
		if glyph == "<":
			if wall_x < 0.12 or wall_x > 0.88 or (wall_x > 0.46 and wall_x < 0.54):
				col = Color(0.36, 0.28, 0.24)
			elif wall_x > 0.22 and wall_x < 0.34:
				col = Color(0.58, 0.50, 0.42)
			else:
				col = Color(0.84, 0.78, 0.68)
		if glyph == "[":
			if wall_x < 0.10 or wall_x > 0.90:
				col = Color(0.78, 0.70, 0.58)
			elif wall_x > 0.28 and wall_x < 0.72:
				col = Color(0.55, 0.24, 0.20)
			else:
				col = Color(0.72, 0.64, 0.52)
		if glyph == "{":
			if wall_x < 0.08 or wall_x > 0.92:
				col = Color(0.28, 0.08, 0.10)
			elif int(wall_x * 8.0) % 2 == 0:
				col = Color(0.62, 0.12, 0.18)
			else:
				col = Color(0.78, 0.62, 0.28)
		if glyph == "]":
			if wall_x < 0.12 or wall_x > 0.88:
				col = Color(0.82, 0.66, 0.24)
			elif wall_x > 0.28 and wall_x < 0.72:
				col = Color(0.16, 0.18, 0.28)
			else:
				col = Color(0.58, 0.42, 0.16)
		if glyph == "}":
			if wall_x < 0.08 or wall_x > 0.92:
				col = Color(0.72, 0.56, 0.22)
			elif int(wall_x * 9.0) % 3 == 0:
				col = Color(0.78, 0.64, 0.28)
			else:
				col = Color(0.26, 0.16, 0.34)
		if glyph == "~":
			if wall_x < 0.16 or wall_x > 0.84:
				col = Color(0.46, 0.50, 0.60)
			elif int(wall_x * 7.0) % 2 == 0:
				col = Color(0.58, 0.60, 0.66)
			else:
				col = Color(0.28, 0.30, 0.38)
		if glyph == "!":
			if wall_x > 0.78:
				col = Color(0.74, 0.66, 0.46)
			elif int(wall_x * 5.0) % 2 == 0:
				col = Color(0.18, 0.38, 0.32)
			else:
				col = Color(0.12, 0.28, 0.24)
		if glyph == "\"":
			if wall_x < 0.12 or wall_x > 0.88:
				col = Color(0.62, 0.56, 0.44)
			else:
				col = Color(0.90, 0.86, 0.74)
		if glyph == "$":
			if wall_x < 0.16:
				col = Color(0.95, 0.74, 0.28)
			elif int(wall_x * 7.0) % 2 == 0:
				col = Color(0.22, 0.24, 0.28)
			else:
				col = Color(0.46, 0.48, 0.52)
		if glyph == "%":
			if wall_x > 0.72:
				col = Color(0.42, 0.26, 0.16)
			elif int(wall_x * 4.0) % 2 == 0:
				col = Color(0.22, 0.12, 0.16)
			else:
				col = Color(0.34, 0.18, 0.22)
		if glyph == "&":
			if wall_x < 0.14 or wall_x > 0.86:
				col = Color(0.50, 0.32, 0.16)
			elif int(wall_x * 6.0) % 2 == 0:
				col = Color(0.36, 0.20, 0.10)
			else:
				col = Color(0.22, 0.12, 0.08)
		if state.oil <= 2:
			col *= 0.45
		elif state.oil <= 4:
			col *= 0.7
		draw_rect(Rect2(view.position.x + float(c) * col_w, clip0, col_w + 0.75, clip1 - clip0), col)
	_draw_sprites(view, origin, dir, plane, zbuf, cols, col_w)
	if state.oil <= 4:
		var gloom := 0.28 if state.oil <= 2 else 0.14
		draw_rect(view, Color(0.02, 0.01, 0.03, gloom))
	if flash > 0.0:
		draw_rect(view, Color(0.90, 0.32, 0.12, 0.33 * flash))
	var mid := view.position + view.size * 0.5
	draw_line(mid + Vector2(-10, 0), mid + Vector2(-3, 0), AMBER, 2.0)
	draw_line(mid + Vector2(3, 0), mid + Vector2(10, 0), AMBER, 2.0)
	draw_line(mid + Vector2(0, -10), mid + Vector2(0, -3), AMBER, 2.0)
	draw_line(mid + Vector2(0, 3), mid + Vector2(0, 10), AMBER, 2.0)
	draw_string(_font, view.position + Vector2(18, 28), state.floor.title, HORIZONTAL_ALIGNMENT_LEFT, view.size.x * 0.55, 20, AMBER)
	var lamp := view.position + Vector2(view.size.x * 0.82, view.size.y * 0.9)
	draw_circle(lamp, 34, Color(0.95, 0.62, 0.18, 0.10))
	draw_circle(lamp, 14, Color(0.98, 0.82, 0.40, 0.95))
	draw_rect(Rect2(lamp + Vector2(-4, 12), Vector2(8, 16)), Color(0.35, 0.24, 0.12))
	if state.end_reason != Rules.EndReason.NONE:
		var box := Rect2(view.position + Vector2(18, view.size.y * 0.40), Vector2(view.size.x - 36, 78))
		draw_rect(box, Color(0.08, 0.06, 0.05, 0.9))
		draw_string(_font, box.position + Vector2(16, 46), _banner(), HORIZONTAL_ALIGNMENT_LEFT, box.size.x - 32, 22, PARCHMENT)


func _draw_sky_floor(view: Rect2) -> void:
	var bands := 7
	var half := view.size.y * 0.5
	var band_h := half / float(bands)
	var sky_hi := Color(0.05, 0.05, 0.09)
	var sky_lo := Color(0.22, 0.13, 0.08)
	var ground_hi := Color(0.07, 0.05, 0.04)
	var ground_lo := Color(0.30, 0.18, 0.10)
	if state.floor.id == "cloister":
		sky_hi = Color(0.09, 0.07, 0.04)
		sky_lo = Color(0.30, 0.18, 0.08)
		ground_hi = Color(0.08, 0.07, 0.04)
		ground_lo = Color(0.34, 0.24, 0.12)
	elif state.floor.id == "crypt":
		sky_hi = Color(0.05, 0.04, 0.08)
		sky_lo = Color(0.16, 0.12, 0.22)
		ground_hi = Color(0.05, 0.04, 0.07)
		ground_lo = Color(0.20, 0.16, 0.24)
	elif state.floor.id == "ossuary":
		sky_hi = Color(0.07, 0.07, 0.05)
		sky_lo = Color(0.24, 0.20, 0.12)
		ground_hi = Color(0.07, 0.06, 0.04)
		ground_lo = Color(0.32, 0.26, 0.16)
	elif state.floor.id == "reliquary":
		sky_hi = Color(0.08, 0.04, 0.05)
		sky_lo = Color(0.26, 0.10, 0.10)
		ground_hi = Color(0.07, 0.04, 0.04)
		ground_lo = Color(0.28, 0.14, 0.10)
	elif state.floor.id == "undercroft":
		sky_hi = Color(0.04, 0.06, 0.06)
		sky_lo = Color(0.12, 0.18, 0.16)
		ground_hi = Color(0.05, 0.06, 0.05)
		ground_lo = Color(0.16, 0.22, 0.18)
	elif state.floor.id == "wellhouse":
		sky_hi = Color(0.05, 0.06, 0.09)
		sky_lo = Color(0.16, 0.20, 0.28)
		ground_hi = Color(0.06, 0.06, 0.05)
		ground_lo = Color(0.22, 0.20, 0.14)
	elif state.floor.id == "scriptorium":
		sky_hi = Color(0.08, 0.05, 0.04)
		sky_lo = Color(0.28, 0.16, 0.08)
		ground_hi = Color(0.08, 0.05, 0.03)
		ground_lo = Color(0.32, 0.20, 0.10)
	elif state.floor.id == "binding":
		sky_hi = Color(0.09, 0.08, 0.05)
		sky_lo = Color(0.34, 0.26, 0.14)
		ground_hi = Color(0.09, 0.07, 0.04)
		ground_lo = Color(0.40, 0.32, 0.18)
	elif state.floor.id == "chartroom":
		sky_hi = Color(0.04, 0.06, 0.12)
		sky_lo = Color(0.14, 0.22, 0.40)
		ground_hi = Color(0.10, 0.10, 0.08)
		ground_lo = Color(0.36, 0.32, 0.22)
	elif state.floor.id == "bellloft":
		sky_hi = Color(0.05, 0.05, 0.05)
		sky_lo = Color(0.24, 0.14, 0.08)
		ground_hi = Color(0.06, 0.05, 0.04)
		ground_lo = Color(0.20, 0.14, 0.10)
	elif state.floor.id == "clockroom":
		sky_hi = Color(0.07, 0.05, 0.03)
		sky_lo = Color(0.28, 0.16, 0.08)
		ground_hi = Color(0.06, 0.04, 0.02)
		ground_lo = Color(0.22, 0.12, 0.06)
	elif state.floor.id == "font":
		sky_hi = Color(0.05, 0.07, 0.05)
		sky_lo = Color(0.22, 0.26, 0.18)
		ground_hi = Color(0.06, 0.07, 0.05)
		ground_lo = Color(0.26, 0.28, 0.18)
	elif state.floor.id == "apse":
		sky_hi = Color(0.09, 0.08, 0.06)
		sky_lo = Color(0.34, 0.30, 0.22)
		ground_hi = Color(0.10, 0.09, 0.07)
		ground_lo = Color(0.40, 0.36, 0.26)
	elif state.floor.id == "choir":
		sky_hi = Color(0.04, 0.03, 0.02)
		sky_lo = Color(0.20, 0.11, 0.06)
		ground_hi = Color(0.06, 0.04, 0.02)
		ground_lo = Color(0.24, 0.13, 0.07)
	elif state.floor.id == "rood":
		sky_hi = Color(0.05, 0.05, 0.06)
		sky_lo = Color(0.20, 0.20, 0.22)
		ground_hi = Color(0.06, 0.06, 0.05)
		ground_lo = Color(0.24, 0.23, 0.21)
	elif state.floor.id == "crossing":
		sky_hi = Color(0.04, 0.05, 0.05)
		sky_lo = Color(0.16, 0.18, 0.16)
		ground_hi = Color(0.05, 0.05, 0.04)
		ground_lo = Color(0.26, 0.25, 0.20)
	elif state.floor.id == "transept":
		sky_hi = Color(0.10, 0.08, 0.05)
		sky_lo = Color(0.38, 0.30, 0.16)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "ambulatory":
		sky_hi = Color(0.12, 0.14, 0.16)
		sky_lo = Color(0.70, 0.78, 0.84)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "chevet":
		sky_hi = Color(0.05, 0.04, 0.10)
		sky_lo = Color(0.22, 0.16, 0.40)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "retrochoir":
		sky_hi = Color(0.18, 0.12, 0.05)
		sky_lo = Color(0.78, 0.62, 0.28)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "ladychapel":
		sky_hi = Color(0.03, 0.05, 0.14)
		sky_lo = Color(0.20, 0.32, 0.62)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "feretory":
		sky_hi = Color(0.14, 0.13, 0.12)
		sky_lo = Color(0.52, 0.49, 0.44)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "chantry":
		sky_hi = Color(0.10, 0.04, 0.05)
		sky_lo = Color(0.42, 0.16, 0.12)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "sacristy":
		sky_hi = Color(0.08, 0.05, 0.03)
		sky_lo = Color(0.28, 0.16, 0.08)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "pyx":
		sky_hi = Color(0.07, 0.08, 0.10)
		sky_lo = Color(0.28, 0.24, 0.14)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "aumbry":
		sky_hi = Color(0.11, 0.11, 0.12)
		sky_lo = Color(0.40, 0.37, 0.32)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "piscina":
		sky_hi = Color(0.08, 0.12, 0.14)
		sky_lo = Color(0.32, 0.40, 0.42)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "sedilia":
		sky_hi = Color(0.12, 0.10, 0.09)
		sky_lo = Color(0.42, 0.34, 0.26)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "credence":
		sky_hi = Color(0.16, 0.12, 0.08)
		sky_lo = Color(0.48, 0.36, 0.20)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "reredos":
		sky_hi = Color(0.10, 0.08, 0.14)
		sky_lo = Color(0.36, 0.28, 0.32)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "predella":
		sky_hi = Color(0.18, 0.10, 0.08)
		sky_lo = Color(0.46, 0.28, 0.18)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "dossal":
		sky_hi = Color(0.12, 0.05, 0.07)
		sky_lo = Color(0.42, 0.12, 0.16)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "retable":
		sky_hi = Color(0.10, 0.09, 0.06)
		sky_lo = Color(0.42, 0.32, 0.14)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "tester":
		sky_hi = Color(0.08, 0.07, 0.12)
		sky_lo = Color(0.28, 0.18, 0.32)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "riddel":
		sky_hi = Color(0.07, 0.08, 0.12)
		sky_lo = Color(0.30, 0.32, 0.40)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "frontal":
		sky_hi = Color(0.06, 0.10, 0.09)
		sky_lo = Color(0.22, 0.34, 0.30)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "pall":
		sky_hi = Color(0.16, 0.15, 0.13)
		sky_lo = Color(0.46, 0.42, 0.34)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "herse":
		sky_hi = Color(0.08, 0.08, 0.10)
		sky_lo = Color(0.28, 0.28, 0.32)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "catafalque":
		sky_hi = Color(0.08, 0.06, 0.07)
		sky_lo = Color(0.30, 0.18, 0.16)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	elif state.floor.id == "bier":
		sky_hi = Color(0.10, 0.07, 0.05)
		sky_lo = Color(0.36, 0.22, 0.14)
		ground_hi = Color(0.12, 0.10, 0.07)
		ground_lo = Color(0.44, 0.36, 0.22)
	for i in bands:
		var t := float(i) / float(bands)
		var sky := sky_hi.lerp(sky_lo, t)
		draw_rect(Rect2(view.position + Vector2(0, i * band_h), Vector2(view.size.x, band_h + 1.0)), sky)
		var ground := ground_hi.lerp(ground_lo, t)
		draw_rect(Rect2(view.position + Vector2(0, half + i * band_h), Vector2(view.size.x, band_h + 1.0)), ground)
	if state.floor.id == "ladychapel":
		var star_spots: Array = [Vector2(48, 18), Vector2(140, 36), Vector2(230, 14), Vector2(310, 42), Vector2(420, 22), Vector2(510, 8)]
		for spot in star_spots:
			if spot.x < view.size.x and spot.y < half:
				draw_circle(view.position + spot, 1.6, Color(0.96, 0.93, 0.78))
	elif state.floor.id == "feretory":
		for course in 3:
			var course_y := view.position.y + float(course + 1) * half / 5.0
			draw_rect(Rect2(view.position.x, course_y, view.size.x, 2.0), Color(0.72, 0.69, 0.62, 0.55))
	elif state.floor.id == "chantry":
		var flames: Array = [Vector2(70, 28), Vector2(210, 40), Vector2(380, 22), Vector2(540, 34)]
		for spot in flames:
			if spot.x < view.size.x and spot.y < half:
				draw_circle(view.position + spot, 3.2, Color(0.99, 0.78, 0.28))
				draw_circle(view.position + spot + Vector2(0, 6), 1.4, Color(0.55, 0.28, 0.08))
	elif state.floor.id == "sacristy":
		var folds: Array = [Vector2(90, 36), Vector2(240, 48), Vector2(410, 30), Vector2(560, 44)]
		for spot in folds:
			if spot.x < view.size.x and spot.y < half:
				draw_rect(Rect2(view.position + spot, Vector2(10, 22)), Color(0.90, 0.86, 0.74, 0.85))
				draw_rect(Rect2(view.position + spot + Vector2(3, 4), Vector2(2, 14)), Color(0.62, 0.56, 0.42, 0.9))
	elif state.floor.id == "pyx":
		var links: Array = [Vector2(80, 40), Vector2(220, 32), Vector2(400, 46), Vector2(560, 28)]
		for spot in links:
			if spot.x < view.size.x and spot.y < half:
				draw_rect(Rect2(view.position + spot, Vector2(18, 2)), Color(0.35, 0.32, 0.28))
				draw_circle(view.position + spot + Vector2(9, 8), 3.0, Color(0.86, 0.66, 0.22))
	elif state.floor.id == "aumbry":
		var niches: Array = [Vector2(100, 30), Vector2(250, 42), Vector2(420, 26), Vector2(560, 38)]
		for spot in niches:
			if spot.x < view.size.x and spot.y < half:
				draw_rect(Rect2(view.position + spot, Vector2(14, 18)), Color(0.16, 0.14, 0.12, 0.9))
				draw_rect(Rect2(view.position + spot + Vector2(2, 8), Vector2(10, 2)), Color(0.72, 0.66, 0.54, 0.9))
	elif state.floor.id == "piscina":
		var basins: Array = [Vector2(110, 34), Vector2(260, 28), Vector2(430, 40), Vector2(570, 30)]
		for spot in basins:
			if spot.x < view.size.x and spot.y < half:
				draw_rect(Rect2(view.position + spot, Vector2(16, 8)), Color(0.55, 0.64, 0.66, 0.85))
				draw_circle(view.position + spot + Vector2(8, 4), 2.2, Color(0.08, 0.12, 0.16))
	elif state.floor.id == "sedilia":
		var seats: Array = [Vector2(90, 36), Vector2(180, 36), Vector2(270, 36)]
		for spot in seats:
			if spot.x < view.size.x and spot.y < half:
				draw_rect(Rect2(view.position + spot, Vector2(28, 16)), Color(0.62, 0.56, 0.46, 0.9))
				draw_rect(Rect2(view.position + spot + Vector2(4, 8), Vector2(20, 6)), Color(0.34, 0.28, 0.22, 0.9))
	elif state.floor.id == "credence":
		var shelf := Vector2(160, 40)
		if shelf.x < view.size.x and shelf.y < half:
			draw_rect(Rect2(view.position + shelf, Vector2(70, 6)), Color(0.84, 0.76, 0.60, 0.9))
			draw_rect(Rect2(view.position + shelf + Vector2(8, 6), Vector2(6, 14)), Color(0.48, 0.40, 0.30, 0.9))
			draw_rect(Rect2(view.position + shelf + Vector2(56, 6), Vector2(6, 14)), Color(0.48, 0.40, 0.30, 0.9))
			draw_rect(Rect2(view.position + shelf + Vector2(30, -8), Vector2(10, 8)), Color(0.36, 0.26, 0.16, 0.9))
	elif state.floor.id == "reredos":
		var screen := Vector2(150, 18)
		if screen.x < view.size.x and screen.y < half:
			draw_rect(Rect2(view.position + screen, Vector2(84, 48)), Color(0.72, 0.66, 0.58, 0.9))
			draw_rect(Rect2(view.position + screen + Vector2(38, 4), Vector2(8, 40)), Color(0.36, 0.28, 0.24, 0.95))
			draw_rect(Rect2(view.position + screen + Vector2(18, 16), Vector2(48, 6)), Color(0.36, 0.28, 0.24, 0.95))
	elif state.floor.id == "predella":
		var plinth := Vector2(130, 58)
		if plinth.x < view.size.x and plinth.y < half:
			draw_rect(Rect2(view.position + plinth, Vector2(120, 14)), Color(0.74, 0.66, 0.54, 0.92))
			draw_rect(Rect2(view.position + plinth + Vector2(18, 3), Vector2(84, 8)), Color(0.55, 0.24, 0.20, 0.95))
	elif state.floor.id == "dossal":
		var hangings: Array = [Vector2(110, 6), Vector2(190, 6), Vector2(270, 6), Vector2(350, 6)]
		for spot in hangings:
			if spot.x < view.size.x and spot.y < half:
				draw_rect(Rect2(view.position + spot, Vector2(18, 46)), Color(0.62, 0.12, 0.18, 0.92))
				draw_rect(Rect2(view.position + spot + Vector2(8, 0), Vector2(2, 46)), Color(0.78, 0.62, 0.28, 0.9))
	elif state.floor.id == "retable":
		var panel := Vector2(148, 8)
		if panel.x < view.size.x and panel.y < half:
			draw_rect(Rect2(view.position + panel, Vector2(100, 50)), Color(0.82, 0.66, 0.24, 0.95))
			draw_rect(Rect2(view.position + panel + Vector2(8, 6), Vector2(84, 38)), Color(0.16, 0.18, 0.28, 0.96))
			draw_rect(Rect2(view.position + panel + Vector2(36, 14), Vector2(28, 16)), Color(0.74, 0.56, 0.18, 0.9))
	elif state.floor.id == "tester":
		var canopy := Vector2(70, 6)
		var canopy_w := minf(view.size.x - 140.0, 300.0)
		if canopy.y < half:
			draw_rect(Rect2(view.position + canopy, Vector2(canopy_w, 18)), Color(0.28, 0.16, 0.36, 0.94))
			draw_rect(Rect2(view.position + canopy + Vector2(0, 16), Vector2(canopy_w, 4)), Color(0.78, 0.62, 0.24, 0.95))
			for nail in 5:
				draw_circle(view.position + canopy + Vector2(18.0 + float(nail) * canopy_w / 6.0, 18), 2.2, Color(0.62, 0.46, 0.16, 0.95))
	elif state.floor.id == "riddel":
		var curtain := Vector2(46, 8)
		var right_x := minf(view.size.x - 72.0, 430.0)
		if curtain.y < half and right_x > curtain.x + 40.0:
			draw_rect(Rect2(view.position + curtain, Vector2(22, 58)), Color(0.36, 0.40, 0.52, 0.94))
			draw_rect(Rect2(view.position + curtain + Vector2(8, 0), Vector2(4, 58)), Color(0.62, 0.64, 0.70, 0.92))
			draw_rect(Rect2(view.position + Vector2(right_x, 8), Vector2(22, 58)), Color(0.36, 0.40, 0.52, 0.94))
			draw_rect(Rect2(view.position + Vector2(right_x + 10.0, 8), Vector2(4, 58)), Color(0.62, 0.64, 0.70, 0.92))
	elif state.floor.id == "frontal":
		var cloth := Vector2(120, 28)
		var cloth_w := minf(view.size.x - 240.0, 220.0)
		if cloth.y < half and cloth_w > 40.0:
			draw_rect(Rect2(view.position + cloth, Vector2(cloth_w, 36)), Color(0.16, 0.36, 0.30, 0.94))
			draw_rect(Rect2(view.position + cloth + Vector2(0, 32), Vector2(cloth_w, 8)), Color(0.74, 0.66, 0.46, 0.95))
	elif state.floor.id == "pall":
		var linen := Vector2(168, 16)
		if linen.y < half:
			draw_rect(Rect2(view.position + linen, Vector2(72, 52)), Color(0.90, 0.86, 0.74, 0.94))
			draw_rect(Rect2(view.position + linen, Vector2(72, 4)), Color(0.62, 0.56, 0.44, 0.95))
			draw_rect(Rect2(view.position + linen + Vector2(0, 48), Vector2(72, 4)), Color(0.62, 0.56, 0.44, 0.95))
			draw_rect(Rect2(view.position + linen, Vector2(4, 52)), Color(0.62, 0.56, 0.44, 0.95))
			draw_rect(Rect2(view.position + linen + Vector2(68, 0), Vector2(4, 52)), Color(0.62, 0.56, 0.44, 0.95))
	elif state.floor.id == "herse":
		var frame := Vector2(150, 36)
		if frame.y < half:
			draw_rect(Rect2(view.position + frame, Vector2(96, 6)), Color(0.28, 0.30, 0.34, 0.95))
			for spike in 4:
				var sx := frame.x + 12.0 + float(spike) * 24.0
				draw_rect(Rect2(view.position + Vector2(sx, frame.y - 22.0), Vector2(3, 22)), Color(0.28, 0.30, 0.34, 0.95))
				draw_circle(view.position + Vector2(sx + 1.5, frame.y - 26.0), 3.0, Color(0.95, 0.72, 0.28, 0.95))
	elif state.floor.id == "catafalque":
		var stand := Vector2(148, 40)
		if stand.y < half:
			draw_rect(Rect2(view.position + stand, Vector2(110, 14)), Color(0.42, 0.26, 0.16, 0.95))
			draw_rect(Rect2(view.position + stand + Vector2(8, -18), Vector2(94, 22)), Color(0.22, 0.12, 0.16, 0.94))
			draw_rect(Rect2(view.position + stand + Vector2(8, -18), Vector2(94, 4)), Color(0.40, 0.28, 0.22, 0.95))
	elif state.floor.id == "bier":
		var poles := Vector2(140, 28)
		if poles.y < half:
			draw_rect(Rect2(view.position + poles, Vector2(120, 5)), Color(0.50, 0.32, 0.16, 0.95))
			draw_rect(Rect2(view.position + poles + Vector2(0, 28), Vector2(120, 5)), Color(0.50, 0.32, 0.16, 0.95))
			for board in 3:
				var bx := poles.x + 16.0 + float(board) * 36.0
				draw_rect(Rect2(view.position + Vector2(bx, poles.y), Vector2(8, 33)), Color(0.32, 0.18, 0.10, 0.95))


func _cast(origin: Vector2, ray_dir: Vector2) -> Dictionary:
	var map_x := int(floor(origin.x))
	var map_y := int(floor(origin.y))
	var delta_x := 1e30 if is_zero_approx(ray_dir.x) else absf(1.0 / ray_dir.x)
	var delta_y := 1e30 if is_zero_approx(ray_dir.y) else absf(1.0 / ray_dir.y)
	var step_x := 1 if ray_dir.x >= 0.0 else -1
	var step_y := 1 if ray_dir.y >= 0.0 else -1
	var side_x := (float(map_x + 1) - origin.x) * delta_x if step_x > 0 else (origin.x - float(map_x)) * delta_x
	var side_y := (float(map_y + 1) - origin.y) * delta_y if step_y > 0 else (origin.y - float(map_y)) * delta_y
	var side := 0
	var hit := false
	for _i in 64:
		if side_x < side_y:
			side_x += delta_x
			map_x += step_x
			side = 0
		else:
			side_y += delta_y
			map_y += step_y
			side = 1
		if Rules.tile_at(Vector2i(map_x, map_y), state.floor) == Rules.Tile.WALL:
			hit = true
			break
	var perp := (side_x - delta_x) if side == 0 else (side_y - delta_y)
	if not hit:
		perp = 24.0
	return {"dist": perp, "side": side, "cell": Vector2i(map_x, map_y)}


func _draw_sprites(view: Rect2, origin: Vector2, dir: Vector2, plane: Vector2, zbuf: PackedFloat32Array, cols: int, col_w: float) -> void:
	var items: Array = []
	items.append({"pos": Rules.enemy_pos(state.floor), "kind": "warden"})
	items.append({"pos": Rules.telegraph_tile(state.telegraph_index, state.floor), "kind": "swing"})
	items.append({"pos": Rules.lift_pos(state.floor), "kind": "lift"})
	var hazard_kind := "hazard"
	if state.floor.id == "cistern":
		hazard_kind = "seep"
	elif state.floor.id == "cloister":
		hazard_kind = "cinder"
	elif state.floor.id == "crypt":
		hazard_kind = "ash"
	elif state.floor.id == "ossuary":
		hazard_kind = "chalk"
	elif state.floor.id == "reliquary":
		hazard_kind = "nail"
	elif state.floor.id == "undercroft":
		hazard_kind = "salt"
	elif state.floor.id == "wellhouse":
		hazard_kind = "well"
	elif state.floor.id == "scriptorium":
		hazard_kind = "ink"
	elif state.floor.id == "binding":
		hazard_kind = "glue"
	elif state.floor.id == "chartroom":
		hazard_kind = "chart"
	elif state.floor.id == "bellloft":
		hazard_kind = "bell"
	elif state.floor.id == "clockroom":
		hazard_kind = "clock"
	elif state.floor.id == "font":
		hazard_kind = "font"
	elif state.floor.id == "apse":
		hazard_kind = "apse"
	elif state.floor.id == "choir":
		hazard_kind = "choir"
	elif state.floor.id == "rood":
		hazard_kind = "rood"
	elif state.floor.id == "crossing":
		hazard_kind = "crossing"
	elif state.floor.id == "transept":
		hazard_kind = "transept"
	elif state.floor.id == "ambulatory":
		hazard_kind = "ambulatory"
	elif state.floor.id == "chevet":
		hazard_kind = "chevet"
	elif state.floor.id == "retrochoir":
		hazard_kind = "retrochoir"
	elif state.floor.id == "ladychapel":
		hazard_kind = "ladychapel"
	elif state.floor.id == "feretory":
		hazard_kind = "feretory"
	elif state.floor.id == "chantry":
		hazard_kind = "chantry"
	elif state.floor.id == "sacristy":
		hazard_kind = "sacristy"
	elif state.floor.id == "pyx":
		hazard_kind = "pyx"
	elif state.floor.id == "aumbry":
		hazard_kind = "aumbry"
	elif state.floor.id == "piscina":
		hazard_kind = "piscina"
	elif state.floor.id == "sedilia":
		hazard_kind = "sedilia"
	elif state.floor.id == "credence":
		hazard_kind = "credence"
	elif state.floor.id == "reredos":
		hazard_kind = "reredos"
	elif state.floor.id == "predella":
		hazard_kind = "predella"
	elif state.floor.id == "dossal":
		hazard_kind = "dossal"
	elif state.floor.id == "retable":
		hazard_kind = "retable"
	elif state.floor.id == "tester":
		hazard_kind = "tester"
	elif state.floor.id == "riddel":
		hazard_kind = "riddel"
	elif state.floor.id == "frontal":
		hazard_kind = "frontal"
	elif state.floor.id == "pall":
		hazard_kind = "pall"
	elif state.floor.id == "herse":
		hazard_kind = "herse"
	elif state.floor.id == "catafalque":
		hazard_kind = "catafalque"
	elif state.floor.id == "bier":
		hazard_kind = "bier"
	for hazard in Rules.hazard_cells(state.floor):
		items.append({"pos": hazard, "kind": hazard_kind})
	var drawn: Array = []
	for item in items:
		var cell: Vector2i = item.pos
		if cell == state.pos:
			continue
		var world := Vector2(cell.x + 0.5, cell.y + 0.5)
		var proj := _project(origin, dir, plane, world)
		if not bool(proj.ok):
			continue
		proj["kind"] = item.kind
		drawn.append(proj)
	drawn.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return float(a.depth) > float(b.depth))
	for spr in drawn:
		_blit_sprite(view, spr, zbuf, cols, col_w)


func _project(origin: Vector2, dir: Vector2, plane: Vector2, world: Vector2) -> Dictionary:
	var spr := world - origin
	var denom := plane.x * dir.y - dir.x * plane.y
	if absf(denom) < 0.00001:
		return {"ok": false, "depth": 0.0, "x": 0.0}
	var inv := 1.0 / denom
	var tx := inv * (dir.y * spr.x - dir.x * spr.y)
	var ty := inv * (-plane.y * spr.x + plane.x * spr.y)
	return {"ok": ty > 0.12, "depth": ty, "x": tx}


func _blit_sprite(view: Rect2, spr: Dictionary, zbuf: PackedFloat32Array, cols: int, col_w: float) -> void:
	var depth := float(spr.depth)
	var sprite_h := absf(view.size.y / depth)
	var screen_x := (float(cols) * 0.5) * (1.0 + float(spr.x) / depth)
	var width_cols := maxf(sprite_h / col_w, 1.0)
	var start_c := int(floor(screen_x - width_cols * 0.5))
	var end_c := int(ceil(screen_x + width_cols * 0.5))
	var top := view.position.y + (view.size.y - sprite_h) * 0.5
	var fog := clampf(1.05 - depth / 9.0, 0.2, 1.0)
	for c in range(maxi(0, start_c), mini(cols, end_c)):
		if depth >= zbuf[c] - 0.02:
			continue
		var u := float(c - start_c) / maxf(1.0, float(end_c - start_c))
		_sprite_column(view, c, col_w, top, sprite_h, u, String(spr.kind), fog)


func _sprite_column(view: Rect2, column: int, col_w: float, top: float, sprite_h: float, u: float, kind: String, fog: float) -> void:
	var x := view.position.x + float(column) * col_w
	var slices: Array = []
	match kind:
		"warden":
			if u > 0.30 and u < 0.70:
				slices.append([0.38, 0.92, Color(0.17, 0.15, 0.24)])
			if u > 0.38 and u < 0.62:
				slices.append([0.20, 0.42, Color(0.10, 0.09, 0.14)])
			if u > 0.60 and u < 0.84:
				slices.append([0.48, 0.66, Color(0.97, 0.78, 0.32)])
		"swing":
			var half := absf(u - 0.5) * 2.0
			if half < 1.0:
				var thick := (1.0 - half) * 0.16
				slices.append([0.78 - thick, 0.78 + thick, Color(0.95, 0.42, 0.18)])
		"seep":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.28, 0.72, 0.66)])
				slices.append([0.76, 0.84, Color(0.10, 0.38, 0.42)])
		"cinder":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.86, 0.28, 0.10)])
				slices.append([0.76, 0.84, Color(0.22, 0.10, 0.08)])
		"ash":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.78, 0.76, 0.70)])
				slices.append([0.76, 0.84, Color(0.30, 0.26, 0.36)])
		"chalk":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.94, 0.90, 0.70)])
				slices.append([0.76, 0.84, Color(0.55, 0.48, 0.32)])
		"nail":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.72, 0.42, 0.22)])
				slices.append([0.76, 0.84, Color(0.18, 0.12, 0.12)])
		"salt":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.86, 0.92, 0.82)])
				slices.append([0.76, 0.84, Color(0.24, 0.34, 0.28)])
		"well":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.55, 0.78, 0.86)])
				slices.append([0.76, 0.84, Color(0.12, 0.28, 0.40)])
		"ink":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.20, 0.24, 0.55)])
				slices.append([0.76, 0.84, Color(0.06, 0.06, 0.14)])
		"glue":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.93, 0.62, 0.16)])
				slices.append([0.76, 0.84, Color(0.55, 0.32, 0.08)])
		"chart":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.78, 0.28, 0.16)])
				slices.append([0.76, 0.84, Color(0.42, 0.12, 0.08)])
		"bell":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.96, 0.74, 0.22)])
				slices.append([0.76, 0.84, Color(0.62, 0.36, 0.08)])
		"clock":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.86, 0.72, 0.32)])
				slices.append([0.76, 0.84, Color(0.52, 0.38, 0.14)])
		"font":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.80, 0.92, 0.48)])
				slices.append([0.76, 0.84, Color(0.40, 0.52, 0.18)])
		"apse":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.98, 0.84, 0.36)])
				slices.append([0.76, 0.84, Color(0.70, 0.48, 0.12)])
		"choir":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.97, 0.93, 0.72)])
				slices.append([0.76, 0.84, Color(0.74, 0.58, 0.28)])
		"rood":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.72, 0.74, 0.78)])
				slices.append([0.76, 0.84, Color(0.34, 0.36, 0.40)])
		"crossing":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.58, 0.62, 0.66)])
				slices.append([0.76, 0.84, Color(0.22, 0.24, 0.28)])
		"transept":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.95, 0.72, 0.22)])
				slices.append([0.76, 0.84, Color(0.55, 0.36, 0.08)])
		"ambulatory":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.96, 0.97, 0.94)])
				slices.append([0.76, 0.84, Color(0.70, 0.74, 0.72)])
		"chevet":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.62, 0.28, 0.82)])
				slices.append([0.76, 0.84, Color(0.34, 0.10, 0.52)])
		"retrochoir":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.92, 0.52, 0.24)])
				slices.append([0.76, 0.84, Color(0.62, 0.30, 0.12)])
		"ladychapel":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.28, 0.45, 0.95)])
				slices.append([0.76, 0.84, Color(0.10, 0.18, 0.58)])
		"feretory":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.90, 0.92, 0.94)])
				slices.append([0.76, 0.84, Color(0.62, 0.64, 0.68)])
		"chantry":
			if u > 0.46 and u < 0.54:
				slices.append([0.16, 0.26, Color(0.99, 0.86, 0.32)])
				slices.append([0.26, 0.74, Color(0.86, 0.62, 0.18)])
				slices.append([0.74, 0.84, Color(0.22, 0.12, 0.06)])
		"sacristy":
			if u > 0.30 and u < 0.70:
				slices.append([0.58, 0.66, Color(0.93, 0.90, 0.80)])
				slices.append([0.66, 0.78, Color(0.74, 0.70, 0.58)])
				slices.append([0.78, 0.86, Color(0.48, 0.42, 0.30)])
		"pyx":
			if u > 0.42 and u < 0.58:
				slices.append([0.18, 0.34, Color(0.22, 0.20, 0.18)])
				slices.append([0.34, 0.50, Color(0.55, 0.40, 0.16)])
				slices.append([0.50, 0.64, Color(0.12, 0.11, 0.10)])
		"aumbry":
			if u > 0.34 and u < 0.66:
				slices.append([0.52, 0.60, Color(0.84, 0.80, 0.72)])
				slices.append([0.60, 0.74, Color(0.62, 0.58, 0.50)])
				slices.append([0.74, 0.84, Color(0.46, 0.42, 0.36)])
		"piscina":
			if u > 0.36 and u < 0.64:
				slices.append([0.40, 0.52, Color(0.55, 0.66, 0.70)])
				slices.append([0.52, 0.68, Color(0.28, 0.40, 0.46)])
				slices.append([0.68, 0.80, Color(0.14, 0.22, 0.28)])
		"sedilia":
			if u > 0.30 and u < 0.70:
				slices.append([0.48, 0.58, Color(0.72, 0.66, 0.54)])
				slices.append([0.58, 0.72, Color(0.42, 0.36, 0.28)])
				slices.append([0.72, 0.84, Color(0.28, 0.24, 0.18)])
		"credence":
			if u > 0.28 and u < 0.72:
				slices.append([0.36, 0.46, Color(0.86, 0.78, 0.62)])
				slices.append([0.46, 0.62, Color(0.70, 0.62, 0.48)])
				slices.append([0.62, 0.78, Color(0.42, 0.34, 0.24)])
		"reredos":
			if u > 0.22 and u < 0.78:
				slices.append([0.28, 0.40, Color(0.78, 0.74, 0.68)])
				slices.append([0.40, 0.72, Color(0.48, 0.46, 0.42)])
				slices.append([0.72, 0.84, Color(0.32, 0.28, 0.26)])
		"predella":
			if u > 0.20 and u < 0.80:
				slices.append([0.70, 0.78, Color(0.86, 0.78, 0.62)])
				slices.append([0.78, 0.86, Color(0.62, 0.36, 0.24)])
		"dossal":
			if u > 0.24 and u < 0.76:
				slices.append([0.16, 0.34, Color(0.72, 0.14, 0.18)])
				slices.append([0.34, 0.46, Color(0.86, 0.72, 0.36)])
				slices.append([0.62, 0.80, Color(0.34, 0.08, 0.12)])
		"retable":
			if u > 0.26 and u < 0.74:
				slices.append([0.20, 0.34, Color(0.86, 0.70, 0.28)])
				slices.append([0.34, 0.46, Color(0.22, 0.12, 0.08)])
				slices.append([0.58, 0.76, Color(0.74, 0.54, 0.16)])
		"tester":
			if u > 0.42 and u < 0.58:
				slices.append([0.24, 0.36, Color(0.78, 0.62, 0.26)])
				slices.append([0.36, 0.48, Color(0.36, 0.24, 0.12)])
				slices.append([0.64, 0.76, Color(0.58, 0.42, 0.16)])
		"riddel":
			if u > 0.16 and u < 0.38:
				slices.append([0.16, 0.84, Color(0.46, 0.50, 0.60)])
				slices.append([0.28, 0.72, Color(0.64, 0.66, 0.72)])
			if u > 0.62 and u < 0.84:
				slices.append([0.16, 0.84, Color(0.46, 0.50, 0.60)])
				slices.append([0.28, 0.72, Color(0.32, 0.34, 0.42)])
		"frontal":
			if u > 0.22 and u < 0.78:
				slices.append([0.42, 0.70, Color(0.16, 0.36, 0.30)])
				slices.append([0.70, 0.84, Color(0.74, 0.66, 0.46)])
		"pall":
			if u > 0.30 and u < 0.70:
				slices.append([0.28, 0.72, Color(0.90, 0.86, 0.74)])
				slices.append([0.28, 0.34, Color(0.62, 0.56, 0.44)])
				slices.append([0.66, 0.72, Color(0.62, 0.56, 0.44)])
		"herse":
			if u > 0.18 and u < 0.82:
				slices.append([0.22, 0.78, Color(0.30, 0.32, 0.36)])
				slices.append([0.16, 0.26, Color(0.95, 0.74, 0.28)])
		"catafalque":
			if u > 0.22 and u < 0.78:
				slices.append([0.46, 0.78, Color(0.42, 0.26, 0.16)])
				slices.append([0.28, 0.52, Color(0.22, 0.12, 0.16)])
		"bier":
			if u > 0.16 and u < 0.84:
				slices.append([0.18, 0.28, Color(0.50, 0.32, 0.16)])
				slices.append([0.62, 0.72, Color(0.50, 0.32, 0.16)])
				slices.append([0.30, 0.62, Color(0.32, 0.18, 0.10)])
		"hazard":
			if u > 0.22 and u < 0.78:
				slices.append([0.62, 0.70, Color(0.72, 0.34, 0.14)])
				slices.append([0.76, 0.84, Color(0.55, 0.24, 0.10)])
		"lift":
			if u > 0.28 and u < 0.72:
				slices.append([0.22, 0.88, Color(0.72, 0.58, 0.28)])
			if u > 0.36 and u < 0.64:
				slices.append([0.46, 0.54, Color(0.18, 0.12, 0.08)])
	for slice in slices:
		var y0 := top + sprite_h * float(slice[0])
		var y1 := top + sprite_h * float(slice[1])
		var clip0 := maxf(y0, view.position.y)
		var clip1 := minf(y1, view.position.y + view.size.y)
		if clip1 <= clip0:
			continue
		var color: Color = slice[2]
		draw_rect(Rect2(x, clip0, col_w + 0.75, clip1 - clip0), color * fog)


func _draw_sheet(sheet: Rect2) -> void:
	draw_rect(sheet.grow(3), Color(0.28, 0.18, 0.10))
	draw_rect(sheet, PARCHMENT)
	draw_rect(sheet.grow(-6), PARCHMENT_DARK, false, 2.0)
	draw_string(_font, sheet.position + Vector2(16, 24), "FIELD SHEET", HORIZONTAL_ALIGNMENT_LEFT, sheet.size.x - 64, 18, INK)
	draw_string(_font, sheet.position + Vector2(16, 44), state.floor.title, HORIZONTAL_ALIGNMENT_LEFT, sheet.size.x - 64, 16, INK)
	var cols := Rules.width(state.floor)
	var rows := Rules.height(state.floor)
	var grid := Rect2(sheet.position + Vector2(16, 56), Vector2(sheet.size.x - 32, sheet.size.y - 140))
	var cell := minf(grid.size.x / float(cols), grid.size.y / float(rows))
	var origin := grid.position + Vector2(
		(grid.size.x - cell * cols) * 0.5,
		(grid.size.y - cell * rows) * 0.5
	)
	for y in rows:
		for x in cols:
			var rect := Rect2(origin + Vector2(x, y) * cell, Vector2(cell, cell))
			draw_rect(rect, Color(0.84, 0.75, 0.56, 0.35), false, 1.0)
			var p := Vector2i(x, y)
			_draw_mark(rect, int(state.marks.get(p, Rules.Mark.NONE)), Rules.tile_at(p, state.floor))
	var faced := state.pos + Rules.dir_vector(state.facing)
	if Rules.in_bounds(faced, state.floor):
		var faced_rect := Rect2(origin + Vector2(faced) * cell, Vector2(cell, cell))
		draw_rect(faced_rect.grow(-1), AMBER, false, 2.0)
	var pulse := 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) / 180.0)
	var swing := Rules.telegraph_tile(state.telegraph_index, state.floor)
	if Rules.in_bounds(swing, state.floor):
		var center := origin + Vector2(swing) * cell + Vector2(cell, cell) * 0.5
		draw_arc(center, cell * (0.30 + 0.05 * pulse), 0, TAU, 18, Color(0.75, 0.22, 0.12), 2.0, true)
	_draw_warden_token(origin + Vector2(Rules.enemy_pos(state.floor)) * cell, cell)
	_draw_player_token(origin + Vector2(state.pos) * cell, cell, Rules.dir_vector(state.facing))
	var legend_y := sheet.position.y + sheet.size.y - 56
	var legend := "Square wall    dot corridor    triangle hazard"
	if state.floor.id == "cistern":
		legend = "Square wall    dot corridor    triangle seep"
	elif state.floor.id == "cloister":
		legend = "Square wall    dot corridor    triangle cinder"
	elif state.floor.id == "crypt":
		legend = "Square wall    dot corridor    triangle ash"
	elif state.floor.id == "ossuary":
		legend = "Square wall    dot corridor    triangle chalk"
	elif state.floor.id == "reliquary":
		legend = "Square wall    dot corridor    triangle nail"
	elif state.floor.id == "undercroft":
		legend = "Square wall    dot corridor    triangle salt"
	elif state.floor.id == "wellhouse":
		legend = "Square wall    dot corridor    triangle well"
	elif state.floor.id == "scriptorium":
		legend = "Square wall    dot corridor    triangle ink"
	elif state.floor.id == "binding":
		legend = "Square wall    dot corridor    triangle glue"
	elif state.floor.id == "chartroom":
		legend = "Square wall    dot corridor    triangle chart"
	elif state.floor.id == "bellloft":
		legend = "Square wall    dot corridor    triangle bell"
	elif state.floor.id == "clockroom":
		legend = "Square wall    dot corridor    triangle clock"
	elif state.floor.id == "font":
		legend = "Square wall    dot corridor    triangle font"
	elif state.floor.id == "apse":
		legend = "Square wall    dot corridor    triangle apse"
	elif state.floor.id == "choir":
		legend = "Square wall    dot corridor    triangle choir"
	elif state.floor.id == "rood":
		legend = "Square wall    dot corridor    triangle rood"
	elif state.floor.id == "crossing":
		legend = "Square wall    dot corridor    triangle crossing"
	elif state.floor.id == "transept":
		legend = "Square wall    dot corridor    triangle transept"
	elif state.floor.id == "ambulatory":
		legend = "Square wall    dot corridor    triangle ambulatory"
	elif state.floor.id == "chevet":
		legend = "Square wall    dot corridor    triangle chevet"
	elif state.floor.id == "retrochoir":
		legend = "Square wall    dot corridor    triangle retrochoir"
	elif state.floor.id == "ladychapel":
		legend = "Square wall    dot corridor    triangle lady chapel"
	elif state.floor.id == "feretory":
		legend = "Square wall    dot corridor    triangle feretory"
	elif state.floor.id == "chantry":
		legend = "Square wall    dot corridor    triangle chantry"
	elif state.floor.id == "sacristy":
		legend = "Square wall    dot corridor    triangle sacristy"
	elif state.floor.id == "pyx":
		legend = "Square wall    dot corridor    triangle pyx"
	elif state.floor.id == "aumbry":
		legend = "Square wall    dot corridor    triangle aumbry"
	elif state.floor.id == "piscina":
		legend = "Square wall    dot corridor    triangle piscina"
	elif state.floor.id == "sedilia":
		legend = "Square wall    dot corridor    triangle sedilia"
	elif state.floor.id == "credence":
		legend = "Square wall    dot corridor    triangle credence"
	elif state.floor.id == "reredos":
		legend = "Square wall    dot corridor    triangle reredos"
	elif state.floor.id == "predella":
		legend = "Square wall    dot corridor    triangle predella"
	elif state.floor.id == "dossal":
		legend = "Square wall    dot corridor    hanging dossal"
	elif state.floor.id == "retable":
		legend = "Square wall    dot corridor    framed retable"
	elif state.floor.id == "tester":
		legend = "Square wall    dot corridor    canopy tester"
	elif state.floor.id == "riddel":
		legend = "Square wall    dot corridor    curtain riddel"
	elif state.floor.id == "frontal":
		legend = "Square wall    dot corridor    frontal cloth"
	elif state.floor.id == "pall":
		legend = "Square wall    dot corridor    linen pall"
	elif state.floor.id == "herse":
		legend = "Square wall    dot corridor    candle herse"
	elif state.floor.id == "catafalque":
		legend = "Square wall    dot corridor    draped catafalque"
	elif state.floor.id == "bier":
		legend = "Square wall    dot corridor    timber bier"
	draw_string(_font, Vector2(sheet.position.x + 16, legend_y), legend, HORIZONTAL_ALIGNMENT_LEFT, sheet.size.x - 32, 14, INK)
	var swing_note := "Ring is the swing, not ink. Hood is the warden."
	if state.floor.id == "cistern":
		swing_note = "Red ring is the swing, not ink. Hood is the warden."
	draw_string(_font, Vector2(sheet.position.x + 16, legend_y + 20), swing_note, HORIZONTAL_ALIGNMENT_LEFT, sheet.size.x - 32, 14, INK)
	draw_circle(sheet.position + Vector2(sheet.size.x - 36, 28), 12, Color(0.62, 0.16, 0.14))


func _draw_mark(rect: Rect2, mark: int, tile: int) -> void:
	var center := rect.position + rect.size * 0.5
	var radius := rect.size.x * 0.28
	if mark == Rules.Mark.WALL:
		draw_rect(rect.grow(-3), Color(0.24, 0.17, 0.13))
	elif mark == Rules.Mark.HAZARD:
		var tip := center + Vector2(0, -radius)
		var left := center + Vector2(-radius, radius * 0.85)
		var right := center + Vector2(radius, radius * 0.85)
		draw_colored_polygon(PackedVector2Array([tip, right, left]), Color(0.70, 0.32, 0.12))
	elif mark == Rules.Mark.CORRIDOR and tile == Rules.Tile.LIFT:
		draw_rect(Rect2(center - Vector2(radius * 0.7, radius), Vector2(radius * 1.4, radius * 1.7)), Color(0.62, 0.48, 0.18))
	elif mark == Rules.Mark.CORRIDOR:
		draw_circle(center, maxf(2.0, rect.size.x * 0.12), INK)


func _draw_player_token(rect_pos: Vector2, cell: float, direction: Vector2i) -> void:
	var center := rect_pos + Vector2(cell, cell) * 0.5
	var fwd := Vector2(direction.x, direction.y)
	if fwd.length() < 0.1:
		fwd = Vector2.RIGHT
	var side := Vector2(-fwd.y, fwd.x)
	var tip := center + fwd * cell * 0.34
	var a := center - fwd * cell * 0.2 + side * cell * 0.18
	var b := center - fwd * cell * 0.2 - side * cell * 0.18
	draw_colored_polygon(PackedVector2Array([tip, a, b]), Color(0.10, 0.07, 0.05))


func _draw_warden_token(rect_pos: Vector2, cell: float) -> void:
	var center := rect_pos + Vector2(cell, cell) * 0.5
	draw_rect(Rect2(center + Vector2(-cell * 0.12, -cell * 0.02), Vector2(cell * 0.24, cell * 0.28)), Color(0.20, 0.16, 0.30))
	draw_circle(center + Vector2(0, -cell * 0.12), cell * 0.12, Color(0.12, 0.10, 0.16))
	draw_circle(center + Vector2(cell * 0.12, 0.0), cell * 0.06, Color(0.95, 0.75, 0.28))


func _draw_hud(hud: Rect2) -> void:
	draw_rect(hud, Color(0.10, 0.08, 0.07, 0.92))
	var cap := maxi(1, state.flask_capacity)
	var ratio := clampf(float(state.oil) / float(cap), 0.0, 1.0)
	var bar := Rect2(hud.position + Vector2(16, 14), Vector2(280, 16))
	draw_rect(bar, Color(0.20, 0.15, 0.10))
	draw_rect(Rect2(bar.position, Vector2(bar.size.x * ratio, bar.size.y)), AMBER if state.oil > 4 else Color(0.75, 0.28, 0.16))
	var oil_text := "Oil %d/%d" % [state.oil, cap]
	if state.oil <= 4 and state.end_reason == Rules.EndReason.NONE:
		oil_text += "   The lamp is guttering."
	draw_string(_font, hud.position + Vector2(308, 28), oil_text, HORIZONTAL_ALIGNMENT_LEFT, 420, 18, PARCHMENT)
	var faced := state.pos + Rules.dir_vector(state.facing)
	var faced_mark := Rules.Mark.NONE
	if Rules.in_bounds(faced, state.floor):
		faced_mark = int(state.marks.get(faced, Rules.Mark.NONE))
	var lines := PackedStringArray([
		state.floor.record,
		Rules.strike_line(state),
		Rules.ahead_line(state),
		"Faced ink: %s. M cycles wall, hazard, corridor, clear." % Rules.mark_name(faced_mark),
		last_message,
		"Arrows or WASD move. Q and E strafe. Space waits. Esc leaves unpaid.",
	])
	if Rules.tile_at(state.pos, state.floor) == Rules.Tile.HAZARD and state.end_reason == Rules.EndReason.NONE:
		if state.floor.id == "cistern":
			lines.append("You are standing on a seep crack.")
		elif state.floor.id == "cloister":
			lines.append("You are standing on a cinder crack.")
		elif state.floor.id == "crypt":
			lines.append("You are standing on an ash crack.")
		elif state.floor.id == "ossuary":
			lines.append("You are standing on a chalk crack.")
		elif state.floor.id == "reliquary":
			lines.append("You are standing on a nail crack.")
		elif state.floor.id == "undercroft":
			lines.append("You are standing on a salt crack.")
		elif state.floor.id == "wellhouse":
			lines.append("You are standing on a well crack.")
		elif state.floor.id == "scriptorium":
			lines.append("You are standing on an ink crack.")
		elif state.floor.id == "binding":
			lines.append("You are standing on a glue crack.")
		elif state.floor.id == "chartroom":
			lines.append("You are standing on a chart crack.")
		elif state.floor.id == "bellloft":
			lines.append("You are standing on a bell crack.")
		elif state.floor.id == "clockroom":
			lines.append("You are standing on a clock crack.")
		elif state.floor.id == "font":
			lines.append("You are standing on a font crack.")
		elif state.floor.id == "apse":
			lines.append("You are standing on an apse crack.")
		elif state.floor.id == "choir":
			lines.append("You are standing on a choir crack.")
		elif state.floor.id == "rood":
			lines.append("You are standing on a rood crack.")
		elif state.floor.id == "crossing":
			lines.append("You are standing on a crossing crack.")
		elif state.floor.id == "transept":
			lines.append("You are standing on a transept crack.")
		elif state.floor.id == "ambulatory":
			lines.append("You are standing on an ambulatory crack.")
		elif state.floor.id == "chevet":
			lines.append("You are standing on a chevet crack.")
		elif state.floor.id == "retrochoir":
			lines.append("You are standing on a retrochoir crack.")
		elif state.floor.id == "ladychapel":
			lines.append("You are standing on a lady-chapel crack.")
		elif state.floor.id == "feretory":
			lines.append("You are standing on a feretory crack.")
		elif state.floor.id == "chantry":
			lines.append("You are standing on a chantry crack.")
		elif state.floor.id == "sacristy":
			lines.append("You are standing on a sacristy crack.")
		elif state.floor.id == "pyx":
			lines.append("You are standing on a pyx crack.")
		elif state.floor.id == "aumbry":
			lines.append("You are standing on an aumbry crack.")
		elif state.floor.id == "piscina":
			lines.append("You are standing on a piscina crack.")
		elif state.floor.id == "sedilia":
			lines.append("You are standing on a sedilia crack.")
		elif state.floor.id == "credence":
			lines.append("You are standing on a credence crack.")
		elif state.floor.id == "reredos":
			lines.append("You are standing on a reredos crack.")
		elif state.floor.id == "predella":
			lines.append("You are standing on a predella crack.")
		elif state.floor.id == "dossal":
			lines.append("You are standing on a dossal crack.")
		elif state.floor.id == "retable":
			lines.append("You are standing on a retable crack.")
		elif state.floor.id == "tester":
			lines.append("You are standing on a tester crack.")
		elif state.floor.id == "riddel":
			lines.append("You are standing on a riddel crack.")
		elif state.floor.id == "frontal":
			lines.append("You are standing on a frontal crack.")
		elif state.floor.id == "pall":
			lines.append("You are standing on a pall crack.")
		elif state.floor.id == "herse":
			lines.append("You are standing on a herse crack.")
		elif state.floor.id == "catafalque":
			lines.append("You are standing on a catafalque crack.")
		elif state.floor.id == "bier":
			lines.append("You are standing on a bier crack.")
		else:
			lines.append("You are standing on a hazard crack.")
	var y := hud.position.y + 46
	for line in lines:
		draw_string(_font, Vector2(hud.position.x + 16, y), line, HORIZONTAL_ALIGNMENT_LEFT, hud.size.x - 32, 16, PARCHMENT)
		y += 18

func _banner() -> String:
	if state.end_reason == Rules.EndReason.EXTRACTED and Rules.census_accepted(state.marks, state.floor):
		return "Census complete. Return to the floor select."
	match state.end_reason:
		Rules.EndReason.EXTRACTED:
			return "The lift is open. The census is still short. Return to town."
		Rules.EndReason.LAMP_OUT:
			return "The lamp is out. The sheet does not come back."
		_:
			return "You left the floor. The sheet pays nothing."

func _facing_angle(facing: int) -> float:
	match posmod(facing, 4):
		0:
			return -PI / 2.0
		1:
			return 0.0
		2:
			return PI / 2.0
		_:
			return PI


func _style_return(button: Button) -> void:
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", INK)
	var box := StyleBoxFlat.new()
	box.bg_color = AMBER
	box.set_corner_radius_all(3)
	button.add_theme_stylebox_override("normal", box)
	var hover := box.duplicate()
	hover.bg_color = Color(0.98, 0.78, 0.42)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", hover)
