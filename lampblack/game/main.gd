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
var controls_label: Label
var turn_label: Label
var buttons: Array = []
var top_panel: Panel
var bottom_panel: Panel
var bottom_h := 140.0


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

	controls_label = Label.new()
	controls_label.text = "Arrows move    F lamp you face    Space wait    U undo    R restart    click a neighbor or a lamp\n1–8 east    Shift+1–6 west    Ctrl+1–6 north    Alt+1–6 south    F1–F6 attic    F7–F12 cellar    Keypad 1–6 gallery\nShift+F1–F6 court    Alt+F1–F6 nave    Ctrl+F1–F6 cloister    Ctrl+Shift+F1–F6 porch"
	controls_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls_label.add_theme_font_size_override("font_size", 14)
	controls_label.add_theme_color_override("font_color", MUTED)
	controls_label.position = Vector2(20, 4)
	controls_label.size = Vector2(1240, 84)
	bottom_panel.add_child(controls_label)

	var row_y := 90.0
	var wings: Array = Puzzles.wings()
	for wing_i in wings.size():
		var wing: Dictionary = wings[wing_i]
		var row := HBoxContainer.new()
		row.position = Vector2(16, row_y)
		row.add_theme_constant_override("separation", 8)
		bottom_panel.add_child(row)
		var wing_label := Label.new()
		wing_label.text = str(wing["name"])
		wing_label.custom_minimum_size = Vector2(136, 32)
		wing_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		wing_label.add_theme_font_size_override("font_size", 15)
		wing_label.add_theme_color_override("font_color", CREAM)
		row.add_child(wing_label)
		var first := int(wing["first"])
		for n in int(wing["count"]):
			var index := first + n
			var puzzle_info: Dictionary = Puzzles.get_puzzle(index)
			var button := Button.new()
			button.text = str(puzzle_info["wing_number"])
			button.tooltip_text = str(puzzle_info["title"])
			button.focus_mode = Control.FOCUS_NONE
			button.custom_minimum_size = Vector2(40, 32)
			button.pressed.connect(_select_puzzle.bind(index))
			row.add_child(button)
			buttons.append(button)
		if wing_i == wings.size() - 1:
			var restart := Button.new()
			restart.text = "Restart"
			restart.focus_mode = Control.FOCUS_NONE
			restart.custom_minimum_size = Vector2(88, 32)
			restart.pressed.connect(_restart)
			row.add_child(restart)
		row_y += 36.0

	legend_label = Label.new()
	legend_label.text = "Gold diamond — lamplight, you cannot walk it.    Red diamond — a guard is watching.    Arrow — that guard's next step.    Brass disc — a plate. Step on it in the dark and the nearest guard is called.    Iron cup — a bell. Step on it in the dark and every guard who can reach it is called.    Iron bars — a grate. It stays dark, you may enter it, and a guard cannot.    Stone sill — a lamp lights it, light stops there, and a guard cannot enter or see through it."
	legend_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	legend_label.position = Vector2(20, row_y + 2.0)
	legend_label.size = Vector2(1240, 64)
	legend_label.add_theme_font_size_override("font_size", 14)
	legend_label.add_theme_color_override("font_color", MUTED)
	bottom_panel.add_child(legend_label)

	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.add_theme_color_override("font_color", CREAM)
	status_label.position = Vector2(20, row_y + 2.0)
	status_label.size = Vector2(1240, 52)
	bottom_panel.add_child(status_label)
	bottom_h = row_y + 74.0

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
	top_panel.position = Vector2.ZERO
	top_panel.size = Vector2(view.x, top_h)
	bottom_panel.position = Vector2(0, view.y - bottom_h)
	bottom_panel.size = Vector2(view.x, bottom_h)
	if controls_label:
		controls_label.size = Vector2(maxf(200.0, view.x - 40.0), 84)
	if legend_label:
		legend_label.size = Vector2(maxf(200.0, view.x - 40.0), 64)
	if status_label:
		status_label.size = Vector2(maxf(200.0, view.x - 40.0), 52)
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
	title_label.text = "LAMPBLACK    %s    %d  %s" % [puzzle["wing"], puzzle["wing_number"], puzzle["title"]]
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


func _puzzle_index_for_key(event: InputEventKey) -> int:
	var gallery := _gallery_index(event)
	if gallery >= 0:
		return 38 + gallery
	var porch := _porch_index(event)
	if porch >= 0:
		return 62 + porch
	var court := _court_index(event)
	if court >= 0:
		return 44 + court
	var nave := _nave_index(event)
	if nave >= 0:
		return 50 + nave
	var cloister := _cloister_index(event)
	if cloister >= 0:
		return 56 + cloister
	var attic := _attic_index(event)
	if attic >= 0:
		return 26 + attic
	var cellar := _cellar_index(event)
	if cellar >= 0:
		return 32 + cellar
	var digit := _digit_from_key(event)
	if digit < 0:
		return -1
	# Alt alone is the south wing. Alt combined with another modifier keeps the
	# older behavior: it selects nothing, so Shift and Ctrl stay where they were.
	if event.alt_pressed:
		if event.ctrl_pressed or event.meta_pressed or event.shift_pressed or _is_shifted_digit(event.keycode):
			return -1
		if digit > 5:
			return -1
		return 20 + digit
	if event.ctrl_pressed or event.meta_pressed:
		if digit > 5:
			return -1
		return 14 + digit
	var shifted := event.shift_pressed or _is_shifted_digit(event.keycode)
	if shifted:
		if digit > 5:
			return -1
		return 8 + digit
	if digit > 7:
		return -1
	return digit


func _porch_index(event: InputEventKey) -> int:
	if event.alt_pressed or not event.shift_pressed:
		return -1
	if not event.ctrl_pressed and not event.meta_pressed:
		return -1
	var key := event.physical_keycode
	if key < KEY_F1 or key > KEY_F6:
		key = event.keycode
	if key < KEY_F1 or key > KEY_F6:
		return -1
	return int(key) - int(KEY_F1)


func _cloister_index(event: InputEventKey) -> int:
	if event.shift_pressed or event.alt_pressed:
		return -1
	if not event.ctrl_pressed and not event.meta_pressed:
		return -1
	var key := event.physical_keycode
	if key < KEY_F1 or key > KEY_F6:
		key = event.keycode
	if key < KEY_F1 or key > KEY_F6:
		return -1
	return int(key) - int(KEY_F1)


func _nave_index(event: InputEventKey) -> int:
	if not event.alt_pressed or event.shift_pressed:
		return -1
	var key := event.physical_keycode
	if key < KEY_F1 or key > KEY_F6:
		key = event.keycode
	if key < KEY_F1 or key > KEY_F6:
		return -1
	return int(key) - int(KEY_F1)


func _court_index(event: InputEventKey) -> int:
	if not event.shift_pressed or event.ctrl_pressed or event.meta_pressed:
		return -1
	var key := event.physical_keycode
	if key < KEY_F1 or key > KEY_F6:
		key = event.keycode
	if key < KEY_F1 or key > KEY_F6:
		return -1
	return int(key) - int(KEY_F1)


func _gallery_index(event: InputEventKey) -> int:
	var key := event.physical_keycode
	if key < KEY_KP_1 or key > KEY_KP_6:
		key = event.keycode
	if key < KEY_KP_1 or key > KEY_KP_6:
		return -1
	return int(key) - int(KEY_KP_1)


func _attic_index(event: InputEventKey) -> int:
	if event.alt_pressed or event.ctrl_pressed or event.meta_pressed:
		return -1
	var key := event.physical_keycode
	if key < KEY_F1 or key > KEY_F6:
		key = event.keycode
	if key < KEY_F1 or key > KEY_F6:
		return -1
	return int(key) - int(KEY_F1)


func _cellar_index(event: InputEventKey) -> int:
	var key := event.physical_keycode
	if key < KEY_F7 or key > KEY_F12:
		key = event.keycode
	if key < KEY_F7 or key > KEY_F12:
		return -1
	return int(key) - int(KEY_F7)


func _digit_from_key(event: InputEventKey) -> int:
	var key := event.physical_keycode
	if key >= KEY_1 and key <= KEY_8:
		return key - KEY_1
	key = event.keycode
	if key >= KEY_1 and key <= KEY_8:
		return key - KEY_1
	match key:
		KEY_EXCLAM:
			return 0
		KEY_AT:
			return 1
		KEY_NUMBERSIGN:
			return 2
		KEY_DOLLAR:
			return 3
		KEY_PERCENT:
			return 4
		KEY_ASCIICIRCUM:
			return 5
	return -1


func _is_shifted_digit(key: Key) -> bool:
	return key == KEY_EXCLAM or key == KEY_AT or key == KEY_NUMBERSIGN or key == KEY_DOLLAR or key == KEY_PERCENT or key == KEY_ASCIICIRCUM


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var cell := _cell_at(event.position)
		if cell != hover:
			hover = cell
			queue_redraw()
		return
	if not (event is InputEventKey) or not event.pressed:
		return
	var key_event := event as InputEventKey
	var key := key_event.keycode
	var puzzle_pick := _puzzle_index_for_key(key_event)
	if puzzle_pick >= 0:
		if not event.echo:
			_select_puzzle(puzzle_pick)
		get_viewport().set_input_as_handled()
		return
	if key_event.alt_pressed:
		return
	if key_event.ctrl_pressed or key_event.meta_pressed:
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
	if lit.has(cell) and kind != Rules.Tile.GRATE:
		floor_color = LIT
	draw_rect(inset, floor_color)
	if kind == Rules.Tile.SILL:
		_draw_sill(inset)
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
	if lit.has(cell) and kind != Rules.Tile.GRATE:
		draw_colored_polygon(_diamond(center, tile * 0.34, tile * 0.34), LIGHT)
	if kind == Rules.Tile.PLATE:
		_draw_plate(center)
	if kind == Rules.Tile.BELL:
		_draw_bell(center)
	if kind == Rules.Tile.GRATE:
		_draw_grate(inset)
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


func _draw_plate(center: Vector2) -> void:
	var radius := tile * 0.32
	draw_circle(center, radius, Color("5c4524"))
	draw_circle(center, radius * 0.78, Color("c6a15a"))
	draw_circle(center, radius * 0.78, Color("3a2c16"), false, maxf(1.5, tile * 0.035))
	var rivet := maxf(1.4, tile * 0.035)
	for corner in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		var spot: Vector2 = center + corner * radius * 0.46
		draw_circle(spot, rivet, Color("3a2c16"))
		draw_circle(spot, rivet * 0.45, Color("e7d3a1"))
	draw_rect(Rect2(center + Vector2(-tile * 0.07, -tile * 0.018), Vector2(tile * 0.14, tile * 0.036)), Color("3a2c16"))
	draw_circle(center, tile * 0.045, Color("8d7344"))
	draw_circle(center, tile * 0.02, Color("3a2c16"))


func _draw_sill(inset: Rect2) -> void:
	var stone := Color("b7a48c")
	var dark := Color("6d5e4e")
	var lip := Color("efe2d0")
	var mortar := Color("2a241c")
	var slab := Rect2(inset.position + Vector2(inset.size.x * 0.06, inset.size.y * 0.28), Vector2(inset.size.x * 0.88, inset.size.y * 0.44))
	draw_rect(slab, stone)
	var lip_h := maxf(3.0, tile * 0.08)
	draw_rect(Rect2(slab.position, Vector2(slab.size.x, lip_h)), lip)
	var base_h := maxf(3.0, tile * 0.07)
	draw_rect(Rect2(Vector2(slab.position.x, slab.position.y + slab.size.y - base_h), Vector2(slab.size.x, base_h)), dark)
	var joint_x := slab.position.x + slab.size.x * 0.5
	draw_line(Vector2(joint_x, slab.position.y + 2.0), Vector2(joint_x, slab.position.y + slab.size.y - 2.0), mortar, maxf(1.5, tile * 0.03))


func _draw_grate(inset: Rect2) -> void:
	var iron := Color("5c6770")
	var shine := Color("d5dee6")
	var gap := Color("07080a")
	var inner := Rect2(inset.position + inset.size * 0.12, inset.size * 0.76)
	draw_rect(inner, gap)
	var rail := maxf(2.0, tile * 0.045)
	draw_rect(Rect2(inner.position, Vector2(inner.size.x, rail)), iron)
	draw_rect(Rect2(Vector2(inner.position.x, inner.position.y + inner.size.y - rail), Vector2(inner.size.x, rail)), iron)
	var bars := 5
	var bar_w := maxf(2.0, tile * 0.055)
	for i in bars:
		var x := inner.position.x + inner.size.x * (float(i) + 0.5) / float(bars) - bar_w * 0.5
		draw_rect(Rect2(Vector2(x, inner.position.y), Vector2(bar_w, inner.size.y)), iron)
		draw_line(
			Vector2(x + bar_w * 0.32, inner.position.y + rail),
			Vector2(x + bar_w * 0.32, inner.position.y + inner.size.y - rail),
			shine,
			1.0
		)


func _draw_bell(center: Vector2) -> void:
	var iron := Color("6a727c")
	var iron_dark := Color("23272c")
	var iron_lip := Color("d5dee6")
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-tile * 0.24, -tile * 0.16),
		center + Vector2(tile * 0.24, -tile * 0.16),
		center + Vector2(tile * 0.13, tile * 0.16),
		center + Vector2(-tile * 0.13, tile * 0.16),
	]), iron)
	draw_rect(Rect2(center + Vector2(-tile * 0.16, tile * 0.14), Vector2(tile * 0.32, tile * 0.055)), iron_dark)
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(-tile * 0.16, -tile * 0.16),
		center + Vector2(tile * 0.16, -tile * 0.16),
		center + Vector2(tile * 0.10, -tile * 0.04),
		center + Vector2(-tile * 0.10, -tile * 0.04),
	]), iron_dark)
	draw_line(
		center + Vector2(-tile * 0.24, -tile * 0.16),
		center + Vector2(tile * 0.24, -tile * 0.16),
		iron_lip,
		maxf(2.0, tile * 0.045)
	)
	draw_line(center + Vector2(0, -tile * 0.04), center + Vector2(0, tile * 0.04), iron_dark, maxf(1.2, tile * 0.03))
	draw_circle(center + Vector2(0, tile * 0.07), tile * 0.04, iron_dark)
	draw_circle(center + Vector2(-tile * 0.08, -tile * 0.02), tile * 0.02, Color("9aa6b1"))


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
