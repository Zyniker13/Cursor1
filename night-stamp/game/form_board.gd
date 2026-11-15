extends Control

signal cell_pressed(row, col)

const PAPER := Color("efe2c9")
const EDGE := Color("8a7048")
const INK := Color("241910")
const HOVER := Color("c4523a")

var cells: Array = []
var cursor_row := 1
var cursor_col := 1
var hover_row := -1
var hover_col := -1

var _pad := 10
var _gap := 8
var _cell := 104


func _ready() -> void:
	var span := _pad * 2 + _cell * 3 + _gap * 2
	custom_minimum_size = Vector2(span, span)
	mouse_filter = Control.MOUSE_FILTER_STOP
	if cells.is_empty():
		cells = _empty()


func set_board(next_cells: Array, next_row: int, next_col: int) -> void:
	cells = next_cells
	cursor_row = next_row
	cursor_col = next_col
	queue_redraw()


func _empty() -> Array:
	var form: Array = []
	for _row in 3:
		var line: Array = [null, null, null]
		form.append(line)
	return form


func _cell_rect(row: int, col: int) -> Rect2:
	return Rect2(
		_pad + col * (_cell + _gap),
		_pad + row * (_cell + _gap),
		_cell,
		_cell
	)


func _cell_at(point: Vector2) -> Vector2i:
	for row in 3:
		for col in 3:
			if _cell_rect(row, col).has_point(point):
				return Vector2i(row, col)
	return Vector2i(-1, -1)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var hovered = _cell_at(event.position)
		if hovered.x != hover_row or hovered.y != hover_col:
			hover_row = hovered.x
			hover_col = hovered.y
			queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var hit = _cell_at(event.position)
		if hit.x >= 0:
			cell_pressed.emit(hit.x, hit.y)
			accept_event()


func _draw() -> void:
	var span := _pad * 2 + _cell * 3 + _gap * 2
	draw_rect(Rect2(8, 10, span - 10, span - 8), Color(0, 0, 0, 0.28))
	draw_rect(Rect2(0, 0, span, span), Color("f4ead6"))
	draw_rect(Rect2(0, 0, span, span), EDGE, false, 4)
	var font := ThemeDB.fallback_font
	var row_hints := ["Top", "Mid", "Bot"]
	for row in 3:
		for col in 3:
			var rect := _cell_rect(row, col)
			var stamp = null
			if row < cells.size() and col < cells[row].size():
				stamp = cells[row][col]
			var fill := PAPER
			if stamp != null:
				fill = stamp["color"]
			draw_rect(rect, fill)
			draw_rect(rect, EDGE, false, 3)
			if stamp != null:
				var center := rect.get_center()
				draw_arc(center, _cell * 0.30, 0, TAU, 40, Color(0.14, 0.07, 0.05, 0.45), 3.0)
				draw_arc(center, _cell * 0.22, 0, TAU, 32, Color(0.14, 0.07, 0.05, 0.28), 2.0)
				_draw_name(font, rect, String(stamp["name"]))
			else:
				var hint := "%s %d" % [row_hints[row], col + 1]
				var hint_size := 16
				var hint_width := font.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1, hint_size).x
				var hint_pos := rect.position + Vector2((_cell - hint_width) * 0.5, _cell * 0.56)
				draw_string(font, hint_pos, hint, HORIZONTAL_ALIGNMENT_LEFT, -1, hint_size, Color(0.35, 0.28, 0.18, 0.55))
			if row == cursor_row and col == cursor_col:
				draw_rect(rect.grow(-3), Color("241910"), false, 5)
				draw_rect(rect.grow(-7), Color("fff8ee"), false, 3)
			elif row == hover_row and col == hover_col:
				draw_rect(rect.grow(-5), HOVER, false, 3)


func _draw_name(font: Font, rect: Rect2, text: String) -> void:
	var size := 18
	var limit := rect.size.x - 18
	while size > 12 and font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > limit:
		size -= 2
	var width := font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var pos := rect.position + Vector2((rect.size.x - width) * 0.5, rect.size.y * 0.58)
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, INK)
