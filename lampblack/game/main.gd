extends Node2D

const Rules = preload("res://rules/rules.gd")
const Puzzles = preload("res://puzzles/puzzles.gd")
const SessionScript = preload("res://game/session.gd")

const INK := Color("14110e")
const GROUT := Color("1a1714")
const FLOOR := Color("2c2824")
const FLOOR_ALT := Color("332e29")
const WALL := Color("3c352d")
const WALL_EDGE := Color("6a5e50")
const LIT := Color("7c623c")
const LIGHT := Color(1.0, 0.78, 0.4, 0.34)
const WATCH := Color(0.9, 0.16, 0.12, 0.45)
const PLAYER_COLOR := Color("f4e6d4")
const BRASS := Color("e0c17a")
const FLAME := Color("ffb24a")
const EXIT_COLOR := Color("9dbe93")
const ARROW := Color("ffe7a3")
const CREAM := Color("f6ead8")
const MUTED := Color("b7a892")

var session = null
var puzzle_index := 0
var puzzle: Dictionary = {}
var origin := Vector2.ZERO
var tile := 64.0
var hover := Vector2i(-1, -1)
var frozen := false
var status := ""

var title_label: Label
var lesson_label: Label
var status_label: Label
var legend_label: Label
var turn_label: Label
var buttons: Array = []
var top_panel: Panel
var bottom_panel: Panel


func _ready() -> void:
	session = SessionScript.new()
	_build_hud()
	get_viewport().size_changed.connect(_layout)
	_select_puzzle(0)


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	top_panel = Panel.new()
	top_panel.add_theme_stylebox_override("panel", _panel_style())
	layer.add_child(top_panel)

	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 28)
	title_label.add_theme_color_override("font_color", CREAM)
	top_panel.add_child(title_label)

	lesson_label = Label.new()
	lesson_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lesson_label.add_theme_font_size_override("font_size", 16)
	lesson_label.add_theme_color_override("font_color", MUTED)
	top_panel.add_child(lesson_label)

	bottom_panel = Panel.new()
	bottom_panel.add_theme_stylebox_override("panel", _panel_style())
	layer.add_child(bottom_panel)

	var controls := Label.new()
	controls.text = "Arrows move    F lamp you face    Space wait    U undo    R restart    1–8 puzzles    click a neighbor or a lamp"
	controls.add_theme_font_size_override("font_size", 14)
	controls.add_theme_color_override("font_color", MUTED)
	controls.position = Vector2(20, 8)
	bottom_panel.add_child(controls)

	var row := HBoxContainer.new()
	row.position = Vector2(16, 36)
	row.add_theme_constant_override("separation", 8)
	bottom_panel.add_child(row)
	for i in Puzzles.count():
		var button := Button.new()
		button.text = str(i + 1)
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(40, 32)
		button.pressed.connect(_select_puzzle.bind(i))
		row.add_child(button)
		buttons.append(button)
	var restart := Button.new()
	restart.text = "Restart"
	restart.focus_mode = Control.FOCUS_NONE
	restart.custom_minimum_size = Vector2(88, 32)
	restart.pressed.connect(_restart)
	row.add_child(restart)

	legend_label = Label.new()
	legend_label.text = "Gold diamond — lamplight, you cannot walk it.    Red diamond — a guard is watching.    Arrow — that guard's next step."
	legend_label.position = Vector2(20, 76)
	legend_label.add_theme_font_size_override("font_size", 14)
	legend_label.add_theme_color_override("font_color", MUTED)
	bottom_panel.add_child(legend_label)

	status_label = Label.new()
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", CREAM)
	status_label.position = Vector2(20, 74)
	bottom_panel.add_child(status_label)

	turn_label = Label.new()
	turn_label.add_theme_font_size_override("font_size", 16)
	turn_label.add_theme_color_override("font_color", BRASS)
	top_panel.add_child(turn_label)


func _panel_style() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.08, 0.07, 0.06, 0.94)
	return box


func _button_style(active: bool) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color("6b5428") if active else Color("2a241c")
	box.border_color = BRASS
	box.set_border_width_all(2 if active else 1)
	box.set_corner_radius_all(2)
	box.content_margin_left = 6
	box.content_margin_right = 6
	box.content_margin_top = 4
	box.content_margin_bottom = 4
	return box


func _layout() -> void:
	var view := get_viewport_rect().size
	var top_h := 124.0
	var bottom_h := 108.0
	top_panel.position = Vector2.ZERO
	top_panel.size = Vector2(view.x, top_h)
	bottom_panel.position = Vector2(0, view.y - bottom_h)
	bottom_panel.size = Vector2(view.x, bottom_h)
	title_label.position = Vector2(24, 16)
	title_label.size = Vector2(view.x - 220, 34)
	lesson_label.position = Vector2(24, 54)
	lesson_label.size = Vector2(view.x - 48, 62)
	turn_label.position = Vector2(view.x - 180, 20)
	turn_label.size = Vector2(156, 28)
	if session == null or session.state.is_empty():
		return
	var state: Dictionary = session.state
	var avail_w := view.x - 48.0
	var avail_h := view.y - top_h - bottom_h - 28.0
	tile = minf(avail_w / float(state["w"]), avail_h / float(state["h"]))
	tile = clampf(tile, 32.0, 84.0)
	var board := Vector2(tile * state["w"], tile * state["h"])
	origin = Vector2((view.x - board.x) * 0.5, top_h + (avail_h - board.y) * 0.5 + 10.0)
	queue_redraw()


func _select_puzzle(index: int) -> void:
	puzzle_index = index
	puzzle = Puzzles.get_puzzle(index)
	session.reset(puzzle["rows"], puzzle["lamps"], puzzle["guards"])
	frozen = false
	status = ""
	title_label.text = "LAMPBLACK    %d  %s" % [puzzle["number"], puzzle["title"]]
	lesson_label.text = puzzle["lesson"]
	_refresh_chrome()
	_layout()


func _restart() -> void:
	_select_puzzle(puzzle_index)
	status = "The room is as you found it."
	_refresh_chrome()


func _refresh_chrome() -> void:
	turn_label.text = "Turn %d" % session.undo_stack.size()
	var showing_status := status != ""
	status_label.visible = showing_status
	status_label.text = status
	legend_label.visible = not showing_status
	for i in buttons.size():
		var button: Button = buttons[i]
		button.add_theme_stylebox_override("normal", _button_style(i == puzzle_index))
		button.add_theme_stylebox_override("hover", _button_style(i == puzzle_index))
		button.add_theme_stylebox_override("pressed", _button_style(true))
		button.add_theme_color_override("font_color", CREAM)
		button.add_theme_color_override("font_hover_color", CREAM)
	queue_redraw()


func _do(action: Dictionary) -> void:
	if frozen:
		return
	var out: Dictionary = session.act(action)
	_note(out)
	_refresh_chrome()


func _note(out: Dictionary) -> void:
	match int(out["result"]):
		Rules.Result.WIN:
			frozen = true
			status = "The door opens. You are out of the wing."
		Rules.Result.LOSS:
			frozen = true
			if out["reason"] == "guard":
				status = "A guard reached your tile. Undo, or restart."
			else:
				status = "A guard is watching that tile. Undo, or restart."
		Rules.Result.ILLEGAL:
			match str(out["reason"]):
				"lit":
					status = "Lit floor is closed to you."
				"darkgap":
					status = "That gap is dark. Cross it only while its lamp is lit."
				"range":
					status = "Stand next to the lamp to touch it."
				_:
					status = ""
		_:
			status = ""


func _undo() -> void:
	if session.undo():
		frozen = false
		status = "Undid the last turn."
	else:
		status = "Nothing to undo."
	_refresh_chrome()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var cell := _cell_at(event.position)
		if cell != hover:
			hover = cell
			queue_redraw()
		return
	if not (event is InputEventKey) or not event.pressed:
		return
	if event.ctrl_pressed or event.alt_pressed or event.meta_pressed:
		return
	var key_event := event as InputEventKey
	var key := key_event.keycode
	if key >= KEY_1 and key <= KEY_8:
		if not event.echo:
			_select_puzzle(key - KEY_1)
		get_viewport().set_input_as_handled()
		return
	if key >= KEY_KP_1 and key <= KEY_KP_8:
		if not event.echo:
			_select_puzzle(key - KEY_KP_1)
		get_viewport().set_input_as_handled()
		return
	if key == KEY_U:
		if not event.echo:
			_undo()
		get_viewport().set_input_as_handled()
		return
	if key == KEY_R:
		if not event.echo:
			_restart()
		get_viewport().set_input_as_handled()
		return
	if key == KEY_F:
		if not event.echo:
			_toggle_facing()
		get_viewport().set_input_as_handled()
		return
	if key == KEY_SPACE:
		_do({"type": "wait"})
		get_viewport().set_input_as_handled()
		return
	var dir := Vector2i.ZERO
	match key:
		KEY_UP:
			dir = Vector2i(0, -1)
		KEY_RIGHT:
			dir = Vector2i(1, 0)
		KEY_DOWN:
			dir = Vector2i(0, 1)
		KEY_LEFT:
			dir = Vector2i(-1, 0)
	if dir == Vector2i.ZERO:
		return
	_try_move(dir)
	get_viewport().set_input_as_handled()


func _try_move(dir: Vector2i) -> void:
	if frozen:
		return
	var out: Dictionary = session.act({"type": "move", "dx": dir.x, "dy": dir.y})
	if out["result"] == Rules.Result.ILLEGAL:
		session.state["player"]["fx"] = dir.x
		session.state["player"]["fy"] = dir.y
		_note(out)
		_refresh_chrome()
		return
	_note(out)
	_refresh_chrome()


func _toggle_facing() -> void:
	if frozen:
		return
	var player: Dictionary = session.state["player"]
	var target := Vector2i(player["x"] + player["fx"], player["y"] + player["fy"])
	var index := _lamp_at(target)
	if index < 0:
		status = "No lamp in the direction you are facing."
		_refresh_chrome()
		return
	_do({"type": "toggle", "lamp": index})


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_click(event.position)


func _click(pos: Vector2) -> void:
	if frozen:
		return
	var cell := _cell_at(pos)
	if cell.x < 0:
		return
	var player: Dictionary = session.state["player"]
	var here := Vector2i(player["x"], player["y"])
	if cell == here:
		_do({"type": "wait"})
		return
	if absi(cell.x - here.x) + absi(cell.y - here.y) != 1:
		return
	var lamp := _lamp_at(cell)
	if lamp >= 0:
		_do({"type": "toggle", "lamp": lamp})
		return
	_try_move(cell - here)


func _lamp_at(cell: Vector2i) -> int:
	var lamps: Array = session.state["lamps"]
	for i in lamps.size():
		if lamps[i]["x"] == cell.x and lamps[i]["y"] == cell.y:
			return i
	return -1


func _cell_at(pos: Vector2) -> Vector2i:
	if session == null or session.state.is_empty():
		return Vector2i(-1, -1)
	var local := pos - origin
	var x := int(floor(local.x / tile))
	var y := int(floor(local.y / tile))
	var state: Dictionary = session.state
	if x < 0 or y < 0 or x >= state["w"] or y >= state["h"]:
		return Vector2i(-1, -1)
	return Vector2i(x, y)


func _draw() -> void:
	var view := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, view), INK)
	if session == null or session.state.is_empty():
		return
	var state: Dictionary = session.state
	var lit := Rules.light_map(state)
	var watched := Rules.watched_tiles(state, lit)
	for y in state["h"]:
		for x in state["w"]:
			_draw_tile(state, x, y, lit, watched)
	for i in state["guards"].size():
		_draw_plan(state, i)
	for i in state["lamps"].size():
		_draw_lamp(state["lamps"][i])
	for i in state["guards"].size():
		_draw_guard(state["guards"][i], i)
	_draw_player(state["player"])


func _draw_tile(state: Dictionary, x: int, y: int, lit: Dictionary, watched: Dictionary) -> void:
	var rect := Rect2(origin + Vector2(x, y) * tile, Vector2(tile, tile))
	var kind := Rules.tile_at(state, x, y)
	var cell := Vector2i(x, y)
	if kind == Rules.Tile.WALL:
		draw_rect(rect, WALL)
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, maxf(3.0, tile * 0.1))), WALL_EDGE)
		draw_line(rect.position + Vector2(4, tile * 0.45), rect.position + Vector2(tile - 4, tile * 0.45), Color(WALL_EDGE, 0.35), 1.0)
		draw_line(rect.position + Vector2(4, tile * 0.72), rect.position + Vector2(tile - 4, tile * 0.72), Color(WALL_EDGE, 0.25), 1.0)
		return
	var floor_color := FLOOR_ALT if (x + y) % 2 == 0 else FLOOR
	draw_rect(rect, GROUT)
	var inset := Rect2(rect.position + Vector2(2, 2), rect.size - Vector2(4, 4))
	if lit.has(cell):
		floor_color = LIT
	draw_rect(inset, floor_color)
	if kind == Rules.Tile.GAP:
		var pit := Rect2(inset.position + inset.size * 0.16, inset.size * 0.68)
		draw_rect(pit, Color("070605"))
		if lit.has(cell):
			for i in 3:
				var py := pit.position.y + pit.size.y * (0.22 + i * 0.26)
				draw_line(Vector2(pit.position.x + 3, py), Vector2(pit.position.x + pit.size.x - 3, py), Color("8a6a42"), maxf(2.0, tile * 0.05))
	if kind == Rules.Tile.EXIT:
		var door := Rect2(inset.position + Vector2(inset.size.x * 0.22, inset.size.y * 0.12), Vector2(inset.size.x * 0.56, inset.size.y * 0.76))
		draw_rect(Rect2(door.position - Vector2(3, 3), door.size + Vector2(6, 6)), EXIT_COLOR)
		draw_rect(door, Color("10210f"))
	var center := rect.get_center()
	if lit.has(cell):
		draw_colored_polygon(_diamond(center, tile * 0.34, tile * 0.34), LIGHT)
	if watched.has(cell):
		draw_colored_polygon(_diamond(center, tile * 0.26, tile * 0.26), WATCH)
		draw_polyline(_diamond_loop(center, tile * 0.3, tile * 0.3), Color(1, 0.55, 0.45, 0.9), 1.5)
	if hover == cell:
		draw_rect(inset, Color(1, 1, 1, 0.08), false, 2.0)


func _draw_plan(state: Dictionary, index: int) -> void:
	var plan: Dictionary = Rules.plan_guard(state, state["guards"][index])
	var guard: Dictionary = state["guards"][index]
	var here := Vector2i(guard["x"], guard["y"])
	var step: Vector2i = plan["step"]
	if step == here:
		return
	_arrow(_center(here), _center(step), ARROW)


func _draw_lamp(lamp: Dictionary) -> void:
	var center := _center(Vector2i(lamp["x"], lamp["y"]))
	draw_circle(center, tile * 0.16, Color("1a140c"))
	draw_circle(center, tile * 0.12, BRASS if lamp["lit"] else Color("5c5346"))
	if lamp["lit"]:
		var flame := PackedVector2Array([
			center + Vector2(0, -tile * 0.2),
			center + Vector2(tile * 0.07, -tile * 0.02),
			center + Vector2(-tile * 0.07, -tile * 0.02),
		])
		draw_colored_polygon(flame, FLAME)
		draw_circle(center + Vector2(0, -tile * 0.08), tile * 0.035, Color("fff1c9"))


func _draw_guard(guard: Dictionary, index: int) -> void:
	var center := _center(Vector2i(guard["x"], guard["y"]))
	var coat := Color("8d2e2e") if index % 2 == 0 else Color("2c3f55")
	draw_rect(Rect2(center + Vector2(-tile * 0.16, -tile * 0.02), Vector2(tile * 0.32, tile * 0.28)), coat)
	draw_circle(center + Vector2(0, -tile * 0.12), tile * 0.1, Color("e4cbb3"))
	draw_rect(Rect2(center + Vector2(-tile * 0.11, -tile * 0.16), Vector2(tile * 0.22, tile * 0.05)), Color("1b1a17"))


func _draw_player(player: Dictionary) -> void:
	var center := _center(Vector2i(player["x"], player["y"]))
	draw_circle(center, tile * 0.16, PLAYER_COLOR)
	draw_circle(center, tile * 0.16, Color("2a2118"), false, 2.0)
	var facing := Vector2(player["fx"], player["fy"])
	if facing.length() > 0.0:
		draw_line(center, center + facing.normalized() * tile * 0.28, Color("2a2118"), maxf(2.0, tile * 0.06))


func _center(cell: Vector2i) -> Vector2:
	return origin + Vector2(cell) * tile + Vector2(tile, tile) * 0.5


func _diamond(center: Vector2, rx: float, ry: float) -> PackedVector2Array:
	return PackedVector2Array([
		center + Vector2(0, -ry),
		center + Vector2(rx, 0),
		center + Vector2(0, ry),
		center + Vector2(-rx, 0),
	])


func _diamond_loop(center: Vector2, rx: float, ry: float) -> PackedVector2Array:
	var pts := _diamond(center, rx, ry)
	pts.append(pts[0])
	return pts


func _arrow(from: Vector2, to: Vector2, color: Color) -> void:
	draw_line(from, to, color, maxf(2.0, tile * 0.045), true)
	var delta := to - from
	if delta.length() < 1.0:
		return
	var dir := delta.normalized()
	var side := Vector2(-dir.y, dir.x)
	var wing := tile * 0.16
	draw_colored_polygon(PackedVector2Array([
		to,
		to - dir * wing + side * wing * 0.55,
		to - dir * wing - side * wing * 0.55,
	]), color)
