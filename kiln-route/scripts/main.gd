extends Node2D

const Rules = preload("res://scripts/foundry.gd")
const World = preload("res://scripts/world.gd")
const Rooms = preload("res://scripts/rooms.gd")
const Planner = preload("res://scripts/planner.gd")

const SAVE_PATH := "user://kiln_route.cfg"
const TICK_SEC := 0.05

const COL_BG := Color("12100e")
const COL_PANEL := Color("1e1914")
const COL_EDGE := Color("3c332b")
const COL_TILE := Color("3a322a")
const COL_TEXT := Color("f6f0e6")
const COL_DIM := Color("b5a89a")
const COL_ACCENT := Color("e8883a")
const COL_OK := Color("9cbe78")
const COL_BAD := Color("d35b45")
const COL_LOCK := Color("6d6258")
const COL_SOURCE := Color("a85a32")
const COL_SINK := Color("3e7d68")
const COL_CHUTE := Color("1a1418")
const COL_WALL := Color("14110f")

enum Mode { EDIT, RUN, DONE }

var rooms: Array = []
var planners: Array = []
var room_index := 0
var cleared := {}
var save_enabled := true
var selected_kind := 0
var selected_dir := 0
var hover := Vector2i(-1, -1)
var mode := Mode.EDIT
var world = null
var acc := 0.0
var last_result := {}
var font: Font


func _ready() -> void:
	boot()


func boot() -> void:
	if not rooms.is_empty():
		return
	font = ThemeDB.fallback_font
	if font == null:
		font = SystemFont.new()
	rooms = Rooms.all()
	save_enabled = not _launched_by_tests()
	if save_enabled:
		_load_progress()
	for room in rooms:
		planners.append(Planner.new(room))
	selected_dir = Rules.Dir.EAST
	selected_kind = _default_kind()
	queue_redraw()


func _process(delta: float) -> void:
	if rooms.is_empty():
		return
	var cell := _cell_at(get_local_mouse_position())
	if cell != hover:
		hover = cell
		queue_redraw()
	if mode != Mode.RUN or world == null:
		return
	acc += delta
	var steps := 0
	while acc >= TICK_SEC and mode == Mode.RUN and steps < 8:
		acc -= TICK_SEC
		_advance_tick()
		steps += 1
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if rooms.is_empty():
		return
	if event is InputEventMouseMotion:
		var cell := _cell_at(event.position)
		if cell != hover:
			hover = cell
			queue_redraw()
		return
	if event is InputEventMouseButton and event.pressed:
		_on_click(event.button_index, event.position)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed:
		if event.echo and event.keycode != KEY_R and event.keycode != KEY_Q and event.keycode != KEY_E:
			return
		if _on_key(event.keycode):
			get_viewport().set_input_as_handled()


func _on_click(button: int, pos: Vector2) -> void:
	var lay := _layout()
	for index in lay.tabs.size():
		if lay.tabs[index].has_point(pos):
			if is_unlocked(rooms[index].id):
				_select_room(index)
			return
	if lay.run_btn.has_point(pos):
		_on_run_pressed()
		return
	if lay.restart_btn.has_point(pos):
		_restart_room()
		return
	for slot in lay.tray:
		if slot.rect.has_point(pos):
			_select_kind(int(slot.kind))
			return
	var cell := _cell_at(pos)
	if cell.x < 0:
		return
	if button == MOUSE_BUTTON_RIGHT:
		if _planner().at(cell.x, cell.y) != null:
			_try_rotate_at(cell.x, cell.y, true)
		else:
			selected_dir = Rules.right(selected_dir)
			queue_redraw()
		return
	if button != MOUSE_BUTTON_LEFT:
		return
	if _planner().at(cell.x, cell.y) != null:
		_try_pickup(cell.x, cell.y)
		queue_redraw()
		return
	if mode == Mode.RUN:
		return
	_try_place(selected_kind, cell.x, cell.y, selected_dir)
	queue_redraw()


func _on_key(code: int) -> bool:
	var kind := _kind_for_key(code)
	if kind >= 0:
		_select_kind(kind)
		return true
	if code == KEY_R or code == KEY_E:
		_rotate_selection(true)
		return true
	if code == KEY_Q:
		_rotate_selection(false)
		return true
	if code == KEY_SPACE or code == KEY_ENTER or code == KEY_KP_ENTER:
		_on_run_pressed()
		return true
	if code == KEY_F:
		if mode == Mode.RUN:
			_on_run_pressed()
		return true
	if code == KEY_BACKSPACE:
		_restart_room()
		return true
	if code == KEY_BRACKETRIGHT:
		_step_room(1)
		return true
	if code == KEY_BRACKETLEFT:
		_step_room(-1)
		return true
	return false


func _kind_for_key(code: int) -> int:
	var map := {
		KEY_1: Rules.Kind.BELT,
		KEY_KP_1: Rules.Kind.BELT,
		KEY_2: Rules.Kind.KILN,
		KEY_KP_2: Rules.Kind.KILN,
		KEY_3: Rules.Kind.PRESS,
		KEY_KP_3: Rules.Kind.PRESS,
		KEY_4: Rules.Kind.FILTER,
		KEY_KP_4: Rules.Kind.FILTER,
		KEY_5: Rules.Kind.SPLITTER,
		KEY_KP_5: Rules.Kind.SPLITTER,
		KEY_6: Rules.Kind.ROLLER,
		KEY_KP_6: Rules.Kind.ROLLER,
		KEY_7: Rules.Kind.WEIR,
		KEY_KP_7: Rules.Kind.WEIR,
		KEY_8: Rules.Kind.BRIDGE,
		KEY_KP_8: Rules.Kind.BRIDGE,
		KEY_9: Rules.Kind.GRATE,
		KEY_KP_9: Rules.Kind.GRATE,
		KEY_0: Rules.Kind.HOOK,
		KEY_KP_0: Rules.Kind.HOOK,
		KEY_MINUS: Rules.Kind.ARM,
		KEY_KP_SUBTRACT: Rules.Kind.ARM,
		KEY_EQUAL: Rules.Kind.DROP,
		KEY_KP_ADD: Rules.Kind.DROP,
		KEY_BACKSLASH: Rules.Kind.LIFT,
		KEY_KP_MULTIPLY: Rules.Kind.LIFT,
		KEY_SEMICOLON: Rules.Kind.DWELL,
		KEY_KP_PERIOD: Rules.Kind.DWELL,
		KEY_COMMA: Rules.Kind.TWIN,
		KEY_APOSTROPHE: Rules.Kind.PASS,
		KEY_KP_DIVIDE: Rules.Kind.PASS,
		KEY_PERIOD: Rules.Kind.SLIP,
		KEY_SLASH: Rules.Kind.SHED,
		KEY_QUOTELEFT: Rules.Kind.RAKE,
		KEY_Y: Rules.Kind.HOE,
		KEY_U: Rules.Kind.HARROW,
		KEY_I: Rules.Kind.FORK,
		KEY_O: Rules.Kind.PRONG,
		KEY_P: Rules.Kind.SHARE,
		KEY_T: Rules.Kind.COULTER,
		KEY_G: Rules.Kind.MOLDBOARD,
		KEY_H: Rules.Kind.LANDSIDE,
		KEY_J: Rules.Kind.SLADE,
		KEY_K: Rules.Kind.HEEL,
		KEY_L: Rules.Kind.STILT,
		KEY_M: Rules.Kind.CLEVIS,
		KEY_N: Rules.Kind.BEAM,
		KEY_B: Rules.Kind.HAKE,
		KEY_V: Rules.Kind.SOLE,
		KEY_C: Rules.Kind.FROG,
		KEY_X: Rules.Kind.SHIN,
		KEY_Z: Rules.Kind.POINT,
		KEY_D: Rules.Kind.THROAT,
		KEY_A: Rules.Kind.WREST,
		KEY_S: Rules.Kind.JOINTER,
		KEY_W: Rules.Kind.BRIDLE,
		KEY_TAB: Rules.Kind.TRASHBOARD,
	}
	if not map.has(code):
		return -1
	return int(map[code])


func _rotate_selection(clockwise: bool) -> void:
	if hover.x >= 0 and _planner().at(hover.x, hover.y) != null:
		_try_rotate_at(hover.x, hover.y, clockwise)
		return
	selected_dir = Rules.right(selected_dir) if clockwise else Rules.left(selected_dir)
	queue_redraw()


func _select_kind(kind: int) -> void:
	if int(_room().budget.get(kind, 0)) <= 0:
		return
	selected_kind = kind
	queue_redraw()


func _select_room(index: int) -> void:
	if index < 0 or index >= rooms.size():
		return
	if not is_unlocked(rooms[index].id):
		return
	_back_to_edit()
	room_index = index
	selected_kind = _default_kind()
	queue_redraw()


func _step_room(delta: int) -> void:
	if rooms.is_empty():
		return
	var index := room_index
	for _hop in rooms.size():
		index = posmod(index + delta, rooms.size())
		if is_unlocked(rooms[index].id):
			_select_room(index)
			return


func _on_run_pressed() -> void:
	if mode == Mode.RUN:
		var guard := Rules.SIM_TICKS + 5
		while mode == Mode.RUN and guard > 0:
			_advance_tick()
			guard -= 1
		queue_redraw()
		return
	_start_run()


func _restart_room() -> void:
	_back_to_edit()
	_planner().reset()
	selected_kind = _default_kind()
	queue_redraw()


func _start_run() -> void:
	var built = World.new()
	built.setup(_room(), _planner().placements)
	world = built
	mode = Mode.RUN
	acc = 0.0
	last_result = {}
	if built.error != "":
		_finish_run()
	queue_redraw()


func _advance_tick() -> void:
	if mode != Mode.RUN or world == null:
		return
	if world.error != "" or world.tick >= Rules.SIM_TICKS:
		_finish_run()
		return
	world.step()
	if world.tick >= Rules.SIM_TICKS or world.error != "":
		_finish_run()


func _finish_run() -> void:
	last_result = world.summarize(_planner().placements) if world != null else {}
	mode = Mode.DONE
	if not last_result.is_empty() and last_result.success:
		cleared[int(_room().id)] = true
		_save_progress()
	queue_redraw()


func _back_to_edit() -> void:
	mode = Mode.EDIT
	world = null
	acc = 0.0
	last_result = {}


func _try_place(kind: int, x: int, y: int, dir: int) -> bool:
	if mode == Mode.RUN:
		return false
	if mode == Mode.DONE:
		_back_to_edit()
	return _planner().place(kind, x, y, dir)


func _try_pickup(x: int, y: int) -> bool:
	if _planner().at(x, y) == null:
		return false
	if mode != Mode.EDIT:
		_back_to_edit()
	return _planner().pickup(x, y)


func _try_rotate_at(x: int, y: int, clockwise: bool) -> bool:
	if _planner().at(x, y) == null:
		return false
	if mode != Mode.EDIT:
		_back_to_edit()
	var ok: bool = _planner().rotate_at(x, y, clockwise)
	queue_redraw()
	return ok


func is_unlocked(room_id: int) -> bool:
	if room_id <= 1:
		return true
	if rooms.is_empty() or room_id > rooms.size():
		return false
	return cleared.has(room_id - 1) or cleared.has(room_id)


func _room() -> Dictionary:
	return rooms[room_index]


func _planner():
	return planners[room_index]


func _kind_order() -> Array:
	return [
		Rules.Kind.BELT,
		Rules.Kind.KILN,
		Rules.Kind.PRESS,
		Rules.Kind.FILTER,
		Rules.Kind.SPLITTER,
		Rules.Kind.ROLLER,
		Rules.Kind.WEIR,
		Rules.Kind.BRIDGE,
		Rules.Kind.GRATE,
		Rules.Kind.HOOK,
		Rules.Kind.ARM,
		Rules.Kind.DROP,
		Rules.Kind.LIFT,
		Rules.Kind.DWELL,
		Rules.Kind.TWIN,
		Rules.Kind.PASS,
		Rules.Kind.SLIP,
		Rules.Kind.SHED,
		Rules.Kind.RAKE,
		Rules.Kind.HOE,
		Rules.Kind.HARROW,
		Rules.Kind.FORK,
		Rules.Kind.PRONG,
		Rules.Kind.SHARE,
		Rules.Kind.COULTER,
		Rules.Kind.MOLDBOARD,
		Rules.Kind.LANDSIDE,
		Rules.Kind.SLADE,
		Rules.Kind.HEEL,
		Rules.Kind.STILT,
		Rules.Kind.CLEVIS,
		Rules.Kind.BEAM,
		Rules.Kind.HAKE,
		Rules.Kind.SOLE,
		Rules.Kind.FROG,
		Rules.Kind.SHIN,
		Rules.Kind.POINT,
		Rules.Kind.THROAT,
		Rules.Kind.WREST,
		Rules.Kind.JOINTER,
		Rules.Kind.BRIDLE,
		Rules.Kind.TRASHBOARD,
	]


func _default_kind() -> int:
	var budget: Dictionary = _room().budget
	for kind in _kind_order():
		if int(budget.get(kind, 0)) > 0:
			return kind
	return Rules.Kind.BELT


func _tray_kinds() -> Array:
	var kinds: Array = []
	var budget: Dictionary = _room().budget
	for kind in _kind_order():
		if int(budget.get(kind, 0)) > 0:
			kinds.append(kind)
	return kinds


func _counts_now() -> Dictionary:
	if world != null:
		return world.counts
	return {Rules.Mat.ORE: 0, Rules.Mat.INGOT: 0, Rules.Mat.PLATE: 0}


func _layout() -> Dictionary:
	var size := Vector2(1280, 720)
	if is_inside_tree():
		var view := get_viewport_rect().size
		if view.x >= 100.0 and view.y >= 100.0:
			size = view
	# Past 32 rooms, rows of ten keep each name readable.
	# The sixth wing adds a fifth row. The seventh adds a sixth.
	# The eighth adds a seventh. The ninth adds an eighth. The tenth fills that row.
	# The twenty-fourth wing adds a twentieth row. One pixel shorter keeps a six-row board drawable.
	# The twenty-fifth wing fills that row. Tab width stays 116 unless a label is wider.
	# The twenty-sixth wing adds a twenty-first row. One pixel shorter keeps a six-row board drawable.
	# The twenty-seventh wing adds a twenty-second row. Fourteen pixels still leaves a six-row board drawable.
	# The twenty-eighth wing adds a twenty-third row. One pixel shorter keeps a six-row board drawable.
	# The twenty-ninth wing adds a twenty-fourth row. One pixel shorter keeps a six-row board drawable.
	# The thirtieth wing fills that row. Twelve pixels still leaves a six-row board drawable.
	# The thirty-first wing adds a twenty-fifth row. Twelve pixels still leaves a six-row board drawable.
	# The thirty-second wing adds a twenty-sixth row. Eleven pixels still leaves a six-row board drawable.
	# The thirty-third wing adds a twenty-seventh row. Eleven pixels still leaves a six-row board drawable.
	# The thirty-fourth wing adds a twenty-eighth row. Ten pixels still leaves a six-row board drawable.
	# The thirty-fifth wing fills that row. Ten pixels still leaves a six-row board drawable.
	# The thirty-sixth wing adds a twenty-ninth row. Ten pixels still leaves a six-row board drawable.
	# The thirty-seventh wing adds a thirtieth row. Ten pixels still leaves a six-row board drawable.
	# Shorter tabs give that row back so the rule text keeps its space.
	var per_row := 8
	var tab_h := 30.0
	var row_gap := 4.0
	if rooms.size() > 264:
		per_row = 10
		tab_h = 10.0
		row_gap = 1.0
	elif rooms.size() > 248:
		per_row = 10
		tab_h = 11.0
		row_gap = 1.0
	elif rooms.size() > 224:
		per_row = 10
		tab_h = 12.0
		row_gap = 1.0
	elif rooms.size() > 216:
		per_row = 10
		tab_h = 13.0
		row_gap = 1.0
	elif rooms.size() > 200:
		per_row = 10
		tab_h = 14.0
		row_gap = 1.0
	elif rooms.size() > 184:
		per_row = 10
		tab_h = 15.0
		row_gap = 1.0
	elif rooms.size() > 56:
		per_row = 10
		tab_h = 16.0
		row_gap = 1.0
	elif rooms.size() > 48:
		per_row = 10
		tab_h = 18.0
		row_gap = 2.0
	elif rooms.size() > 40:
		per_row = 10
		tab_h = 20.0
		row_gap = 2.0
	elif rooms.size() > 32:
		per_row = 10
		tab_h = 22.0
		row_gap = 2.0
	elif rooms.size() > 24:
		per_row = 11
	var rows := 1
	if not rooms.is_empty():
		rows = ceili(float(rooms.size()) / float(per_row))
	var tab_y := 48.0
	var tab_gap := 8.0
	var tabs: Array = []
	var tab_w := (size.x - 48.0 - tab_gap * float(per_row - 1)) / float(per_row)
	for index in rooms.size():
		var col := index % per_row
		var row: int = index / per_row
		tabs.append(Rect2(24.0 + float(col) * (tab_w + tab_gap), tab_y + float(row) * (tab_h + row_gap), tab_w, tab_h))
	var tabs_bottom := tab_y + float(rows) * tab_h + float(maxi(rows - 1, 0)) * row_gap
	var top := tabs_bottom + 42.0
	var footer := 156.0
	var play := Rect2(24, top, size.x - 24 - 312, size.y - top - footer)
	var side := Rect2(size.x - 300, top, 276, play.size.y)
	var room := _room()
	var cell := minf(96.0, minf(play.size.x / float(room.w), play.size.y / float(room.h)))
	var grid_size := Vector2(cell * float(room.w), cell * float(room.h))
	var origin := play.position + (play.size - grid_size) * 0.5
	var kinds := _tray_kinds()
	var slot := Vector2(158, 88)
	var gap := 10.0
	var total := kinds.size() * slot.x + maxf(0, kinds.size() - 1) * gap
	var x0 := (size.x - total) * 0.5
	var y0 := size.y - slot.y - 34.0
	var tray: Array = []
	for index in kinds.size():
		tray.append({
			"kind": kinds[index],
			"rect": Rect2(x0 + index * (slot.x + gap), y0, slot.x, slot.y),
		})
	return {
		"size": size,
		"tabs": tabs,
		"play": play,
		"side": side,
		"origin": origin,
		"cell": cell,
		"grid": Rect2(origin, grid_size),
		"run_btn": Rect2(side.position.x + 14, side.position.y + side.size.y - 118, side.size.x - 28, 42),
		"restart_btn": Rect2(side.position.x + 14, side.position.y + side.size.y - 68, side.size.x - 28, 36),
		"tray": tray,
		"blurb": Rect2(24, tabs_bottom + 6.0, size.x - 48, 30),
	}


func _cell_at(pos: Vector2) -> Vector2i:
	if rooms.is_empty():
		return Vector2i(-1, -1)
	var lay := _layout()
	var origin: Vector2 = lay.origin
	var cell: float = lay.cell
	var room := _room()
	var local := pos - origin
	if local.x < 0.0 or local.y < 0.0:
		return Vector2i(-1, -1)
	var x := int(local.x / cell)
	var y := int(local.y / cell)
	if x < 0 or y < 0 or x >= int(room.w) or y >= int(room.h):
		return Vector2i(-1, -1)
	return Vector2i(x, y)


func _draw() -> void:
	if rooms.is_empty() or font == null:
		return
	var lay := _layout()
	var size: Vector2 = lay.size
	draw_rect(Rect2(Vector2.ZERO, size), COL_BG)
	_text(Vector2(24, 14), "KILN ROUTE", 28, COL_TEXT)
	_text(Vector2(236, 26), "thirty-seven wings", 15, COL_DIM)
	var minute := "minute  %d / %d" % [_shown_tick(), Rules.SIM_TICKS]
	var minute_w := font.get_string_size(minute, HORIZONTAL_ALIGNMENT_LEFT, -1, 15).x
	_text(Vector2(size.x - 24 - minute_w, 26), minute, 15, COL_DIM)
	_draw_tabs(lay)
	_text_in(lay.blurb, _room().blurb, 16, COL_TEXT, HORIZONTAL_ALIGNMENT_LEFT)
	draw_rect((lay.play as Rect2).grow(8), COL_PANEL)
	_draw_grid(lay)
	_draw_side(lay)
	_draw_tray(lay)
	_text(Vector2(24, size.y - 28), "1-9 0 - = \\ ; , ' . / ` y u i o p t g h j k l m n b v c x z d a s w Tab select   R rotate   LMB place or pick up   RMB rotate   Space run   F skip   Bksp restart", 13, COL_DIM)


func _draw_tabs(lay: Dictionary) -> void:
	for index in lay.tabs.size():
		if index >= rooms.size():
			break
		var rect: Rect2 = lay.tabs[index]
		var room: Dictionary = rooms[index]
		var unlocked := is_unlocked(int(room.id))
		var current: bool = int(index) == room_index
		var bg := COL_PANEL
		if current:
			bg = Color("3a2618")
		elif not unlocked:
			bg = Color("171410")
		draw_rect(rect, bg)
		draw_rect(rect, COL_ACCENT if current else COL_EDGE, false, 2.0)
		if current:
			draw_rect(Rect2(rect.position.x, rect.position.y + rect.size.y - 3, rect.size.x, 3), COL_ACCENT)
		var label := "%d  %s" % [int(room.id), room.name]
		var tab_size := 15
		if rooms.size() > 56:
			tab_size = 10
		elif rooms.size() > 48:
			tab_size = 11
		elif rooms.size() > 24:
			tab_size = 12
		elif rooms.size() > 8:
			tab_size = 14
		_text_in(rect, label, tab_size, COL_TEXT if unlocked else COL_LOCK)
		var mark := rect.position + Vector2(rect.size.x - 14, rect.size.y * 0.5)
		if cleared.has(int(room.id)):
			draw_circle(mark, 4.0, COL_OK)
		elif not unlocked:
			_padlock(mark)


func _draw_grid(lay: Dictionary) -> void:
	var room := _room()
	var origin: Vector2 = lay.origin
	var cell: float = lay.cell
	var blocked: Dictionary = _planner().blocked
	for y in int(room.h):
		for x in int(room.w):
			var rect := Rect2(origin + Vector2(x, y) * cell, Vector2(cell, cell))
			var inner := rect.grow(-maxf(3.0, cell * 0.06))
			var pos := Vector2i(x, y)
			if blocked.has(pos):
				_draw_fixed(inner, pos)
			else:
				draw_rect(inner, COL_TILE)
				draw_rect(inner, COL_EDGE, false, 1.5)
				_draw_rivets(inner)
			var placed = _planner().at(x, y)
			if placed != null:
				var live = null
				if world != null:
					live = world.machines.get(pos)
				_draw_piece(inner, int(placed.kind), int(placed.dir), 1.0, live)
	_draw_ghost(lay)
	if mode == Mode.DONE and not last_result.is_empty():
		var border := COL_OK if last_result.success else COL_BAD
		draw_rect(lay.grid, border, false, 4.0)


func _draw_fixed(rect: Rect2, pos: Vector2i) -> void:
	var room := _room()
	for src in room.sources:
		if int(src.x) == pos.x and int(src.y) == pos.y:
			draw_rect(rect, COL_SOURCE)
			_arrow(rect.get_center(), int(src.dir), rect.size.x * 0.28, rect.size.x * 0.16, Color("ffd7b0"))
			var pending := _source_pending(pos)
			if pending >= 0:
				_draw_item(rect.get_center(), pending, rect.size.x / 88.0)
			var pattern_label := _pattern_label(src.pattern)
			var pattern_size := 10 if pattern_label.length() > 11 else 12
			_text_in(Rect2(rect.position.x, rect.position.y + rect.size.y - 18, rect.size.x, 16), pattern_label, pattern_size, COL_TEXT)
			return
	for sink in room.sinks:
		if int(sink.x) == pos.x and int(sink.y) == pos.y:
			draw_rect(rect, COL_SINK)
			var well := rect.grow(-rect.size.x * 0.22)
			draw_rect(well, Color("1c3d34"))
			_text_in(rect, _accept_label(sink.accepts), 13, COL_TEXT)
			return
	for chute in room.chutes:
		if int(chute.x) == pos.x and int(chute.y) == pos.y:
			draw_rect(rect, COL_CHUTE)
			draw_circle(rect.get_center(), rect.size.x * 0.22, Color("0c0a0d"))
			draw_circle(rect.get_center(), rect.size.x * 0.22, Color("5c4a55"), false, 2.0)
			_text_in(Rect2(rect.position.x, rect.position.y + rect.size.y - 18, rect.size.x, 16), "Waste", 12, COL_DIM)
			return
	draw_rect(rect, COL_WALL)
	draw_line(rect.position, rect.position + rect.size, COL_EDGE, 2.0)
	draw_line(rect.position + Vector2(rect.size.x, 0), rect.position + Vector2(0, rect.size.y), COL_EDGE, 2.0)


func _draw_ghost(lay: Dictionary) -> void:
	if hover.x < 0 or mode == Mode.RUN:
		return
	var planner = _planner()
	var origin: Vector2 = lay.origin
	var cell: float = lay.cell
	var rect := Rect2(origin + Vector2(hover) * cell, Vector2(cell, cell)).grow(-maxf(3.0, cell * 0.06))
	if planner.at(hover.x, hover.y) != null:
		draw_rect(rect, COL_ACCENT, false, 2.5)
		return
	if planner.can_place(selected_kind, hover.x, hover.y):
		_draw_piece(rect, selected_kind, selected_dir, 0.45, null)
	elif not planner.blocked.has(hover):
		draw_rect(rect, Color(COL_BAD.r, COL_BAD.g, COL_BAD.b, 0.28))


func _draw_piece(rect: Rect2, kind: int, dir: int, alpha: float, live) -> void:
	var phase := 0
	if live != null:
		phase = int(live.phase)
	_glyph(rect, kind, dir, alpha, phase)
	if live == null:
		return
	var center := rect.get_center()
	var scale := rect.size.x / 88.0
	if kind == Rules.Kind.BRIDGE:
		var fwd := Vector2(Rules.vec(dir)) * rect.size.x * 0.1
		var across := Vector2(Rules.vec(Rules.right(dir))) * rect.size.x * 0.16
		if int(live.hold) >= 0:
			_draw_item(center + fwd, int(live.hold), scale * 0.72)
		if int(live.cross) >= 0:
			_draw_item(center + across, int(live.cross), scale * 0.72)
		return
	if int(live.hold) >= 0:
		_draw_item(center, int(live.hold), scale)
	elif live.output_ready:
		var mat := Rules.Mat.INGOT if kind == Rules.Kind.KILN else Rules.Mat.PLATE
		_draw_item(center, mat, scale)
	elif kind == Rules.Kind.KILN and int(live.timer) > 0:
		_draw_item(center, Rules.Mat.ORE, scale * 0.8)
		var frac := 1.0 - float(live.timer) / float(Rules.KILN_DELAY)
		draw_arc(center, 16.0 * scale, -PI * 0.5, -PI * 0.5 + TAU * frac, 18, COL_ACCENT, 2.5, true)
	elif kind == Rules.Kind.PRESS and int(live.buffer) > 0:
		for index in int(live.buffer):
			_draw_item(center + Vector2(-8 + index * 16, 6) * scale, Rules.Mat.INGOT, scale * 0.5)


func _glyph(rect: Rect2, kind: int, dir: int, alpha: float, phase: int) -> void:
	var color := _kind_color(kind)
	color.a = alpha
	var body := rect.grow(-rect.size.x * 0.14)
	draw_rect(body.grow(3), Color(0, 0, 0, 0.35 * alpha))
	draw_rect(body, color)
	var center := body.get_center()
	var light := Color(1, 1, 1, 0.9 * alpha)
	var front := center + Vector2(Rules.vec(dir)) * body.size.x * 0.18
	if kind == Rules.Kind.KILN:
		var chim := Rect2(body.position + Vector2(body.size.x * 0.18, -body.size.y * 0.16), Vector2(body.size.x * 0.18, body.size.y * 0.28))
		draw_rect(chim, color.darkened(0.25))
		draw_rect(Rect2(chim.position + Vector2(1, 0), Vector2(chim.size.x - 2, 4)), Color(COL_ACCENT.r, COL_ACCENT.g, COL_ACCENT.b, alpha))
	elif kind == Rules.Kind.PRESS:
		var ram := Rect2(body.position + Vector2(body.size.x * 0.18, body.size.y * 0.16), Vector2(body.size.x * 0.46, body.size.y * 0.18))
		draw_rect(ram, Color(0.22, 0.25, 0.3, alpha))
	elif kind == Rules.Kind.ROLLER:
		var axle := Color(0.12, 0.18, 0.26, alpha)
		var along := Vector2(Rules.vec(dir))
		draw_circle(center - along * body.size.x * 0.2, body.size.x * 0.09, axle)
		draw_circle(center + along * body.size.x * 0.02, body.size.x * 0.09, axle)
	elif kind == Rules.Kind.BRIDGE:
		var across := Vector2(Rules.vec(Rules.right(dir)))
		draw_line(center - across * body.size.x * 0.36, center + across * body.size.x * 0.36, Color(1, 1, 1, 0.34 * alpha), maxf(2.0, body.size.x * 0.08))
	elif kind == Rules.Kind.HOOK:
		var along := Vector2(Rules.vec(dir))
		var aside := Vector2(Rules.vec(Rules.left(dir)))
		var ink := Color(1, 1, 1, 0.72 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var tail := center - along * body.size.x * 0.28
		var bend := center + along * body.size.x * 0.02
		var tip := bend + aside * body.size.x * 0.28
		draw_line(tail, bend, ink, thick)
		draw_line(bend, tip, ink, thick)
	elif kind == Rules.Kind.ARM:
		var along := Vector2(Rules.vec(dir))
		var aside := Vector2(Rules.vec(Rules.left(dir)))
		var ink := Color(1, 1, 1, 0.72 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var grip := center + aside * body.size.x * 0.3
		var bend := center
		var tip := bend + along * body.size.x * 0.24
		draw_line(grip, bend, ink, thick)
		draw_line(bend, tip, ink, thick)
	elif kind == Rules.Kind.DROP:
		var along := Vector2(Rules.vec(dir))
		var aside := Vector2(Rules.vec(Rules.right(dir)))
		var ink := Color(1, 1, 1, 0.72 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var lip := center + along * body.size.x * 0.28
		var bend := center
		var tip := bend + aside * body.size.x * 0.28
		draw_line(lip, bend, ink, thick)
		draw_line(bend, tip, ink, thick)
	elif kind == Rules.Kind.LIFT:
		var along := Vector2(Rules.vec(dir))
		var aside := Vector2(Rules.vec(Rules.right(dir)))
		var ink := Color(1, 1, 1, 0.72 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var lip := center + aside * body.size.x * 0.28
		var bend := center
		var tip := bend - along * body.size.x * 0.28
		draw_line(lip, bend, ink, thick)
		draw_line(bend, tip, ink, thick)
	elif kind == Rules.Kind.DWELL:
		var along := Vector2(Rules.vec(dir))
		var across := Vector2(Rules.vec(Rules.right(dir)))
		var ink := Color(1, 1, 1, 0.78 * alpha)
		var thick := maxf(2.0, body.size.x * 0.08)
		var back := center - along * body.size.x * 0.2
		draw_line(back - across * body.size.x * 0.16, back + across * body.size.x * 0.16, ink, thick)
		var rear := back - along * body.size.x * 0.14
		draw_line(rear - across * body.size.x * 0.16, rear + across * body.size.x * 0.16, ink, thick)
	elif kind == Rules.Kind.TWIN:
		var along := Vector2(Rules.vec(dir))
		var ink := Color(1, 1, 1, 0.82 * alpha)
		var rear := center - along * body.size.x * 0.2
		draw_circle(rear - along * body.size.x * 0.12, body.size.x * 0.075, ink)
		draw_circle(rear + along * body.size.x * 0.08, body.size.x * 0.075, ink)
	elif kind == Rules.Kind.PASS:
		var along := Vector2(Rules.vec(dir))
		var across := Vector2(Rules.vec(Rules.right(dir)))
		var ink := Color(1, 1, 1, 0.82 * alpha)
		var thick := maxf(2.0, body.size.x * 0.08)
		var gate := center - along * body.size.x * 0.16
		draw_line(gate - across * body.size.x * 0.28, gate - across * body.size.x * 0.08, ink, thick)
		draw_line(gate + across * body.size.x * 0.08, gate + across * body.size.x * 0.28, ink, thick)
	elif kind == Rules.Kind.SLIP:
		var along := Vector2(Rules.vec(dir))
		var across := Vector2(Rules.vec(Rules.right(dir)))
		var ink := Color(1, 1, 1, 0.88 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var seat := center - along * body.size.x * 0.2
		var half := body.size.x * 0.1
		draw_rect(Rect2(seat - Vector2(half, half), Vector2(half * 2.0, half * 2.0)), ink)
		var tail := center + across * body.size.x * 0.22 - along * body.size.x * 0.02
		var tip := center - across * body.size.x * 0.16 + along * body.size.x * 0.28
		draw_line(tail, tip, ink, thick)
	elif kind == Rules.Kind.SHED:
		var along := Vector2(Rules.vec(dir))
		var left := Vector2(Rules.vec(Rules.left(dir)))
		var ink := Color(1, 1, 1, 0.88 * alpha)
		var thick := maxf(2.0, body.size.x * 0.08)
		var seat := center - along * body.size.x * 0.22
		var half := body.size.x * 0.11
		draw_rect(Rect2(seat - Vector2(half, half), Vector2(half * 2.0, half * 2.0)), ink)
		var root := center + along * body.size.x * 0.02
		var tip := root + left * body.size.x * 0.36
		draw_line(root, tip, ink, thick)
	elif kind == Rules.Kind.RAKE:
		# The square is the waiting item. The spur leaves that square and runs left.
		# A shed's spur starts ahead of its square, at the arrival.
		var along := Vector2(Rules.vec(dir))
		var left := Vector2(Rules.vec(Rules.left(dir)))
		var ink := Color(1, 1, 1, 0.92 * alpha)
		var thick := maxf(2.0, body.size.x * 0.08)
		var seat := center - along * body.size.x * 0.02
		var half := body.size.x * 0.13
		draw_rect(Rect2(seat - Vector2(half, half), Vector2(half * 2.0, half * 2.0)), ink)
		var root := seat + left * half
		var tip := root + left * body.size.x * 0.28
		draw_line(root, tip, ink, thick)
	elif kind == Rules.Kind.HOE:
		# The square is the waiting item. The spur leaves that square and runs right.
		# A rake's spur leaves that same square to the left.
		# A shed's spur starts ahead of its square, at the arrival, and runs left.
		var along := Vector2(Rules.vec(dir))
		var right_dir := Vector2(Rules.vec(Rules.right(dir)))
		var ink := Color(1, 1, 1, 0.92 * alpha)
		var thick := maxf(2.0, body.size.x * 0.08)
		var seat := center - along * body.size.x * 0.02
		var half := body.size.x * 0.13
		draw_rect(Rect2(seat - Vector2(half, half), Vector2(half * 2.0, half * 2.0)), ink)
		var root := seat + right_dir * half
		var tip := root + right_dir * body.size.x * 0.28
		draw_line(root, tip, ink, thick)
	elif kind == Rules.Kind.HARROW:
		# A row of teeth across the bar. The hoe is a square with one spur to the right.
		var along := Vector2(Rules.vec(dir))
		var across := Vector2(Rules.vec(Rules.right(dir)))
		var ink := Color(1, 1, 1, 0.92 * alpha)
		var thick := maxf(2.0, body.size.x * 0.055)
		var bar := center - along * body.size.x * 0.08
		var span := body.size.x * 0.32
		draw_line(bar - across * span, bar + across * span, ink, thick)
		var tooth := along * body.size.x * 0.26
		var tooth_at: Array[float] = [-0.28, -0.14, 0.0, 0.14, 0.28]
		for offset in tooth_at:
			var root := bar + across * body.size.x * offset
			draw_line(root, root + tooth, ink, thick)
	elif kind == Rules.Kind.FORK:
		# Two teeth pointing opposite ways, with a gap between them.
		# A harrow is a row of teeth on one bar. A hoe is a square and one spur.
		var along := Vector2(Rules.vec(dir))
		var left_v := Vector2(Rules.vec(Rules.left(dir)))
		var right_v := Vector2(Rules.vec(Rules.right(dir)))
		var ink := Color(1, 1, 1, 0.92 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var hub := center + along * body.size.x * 0.02
		var gap := body.size.x * 0.1
		var reach := body.size.x * 0.28
		var left_root := hub + left_v * gap
		var right_root := hub + right_v * gap
		draw_line(left_root, left_root + left_v * reach, ink, thick)
		draw_line(right_root, right_root + right_v * reach, ink, thick)
		var nick := along * body.size.x * 0.12
		draw_line(left_root + left_v * reach * 0.62, left_root + left_v * reach * 0.62 + nick, ink, thick)
		draw_line(right_root + right_v * reach * 0.62, right_root + right_v * reach * 0.62 + nick, ink, thick)
	elif kind == Rules.Kind.PRONG:
		# The right tine leaves from the waiting item. The left tine leaves from the arrival, ahead of it.
		# A fork's two tines share one hub.
		var along := Vector2(Rules.vec(dir))
		var left_v := Vector2(Rules.vec(Rules.left(dir)))
		var right_v := Vector2(Rules.vec(Rules.right(dir)))
		var ink := Color(1, 1, 1, 0.92 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var rear := center - along * body.size.x * 0.16
		var ahead := center + along * body.size.x * 0.14
		var reach := body.size.x * 0.26
		draw_line(rear, rear + right_v * reach, ink, thick)
		draw_line(ahead, ahead + left_v * reach, ink, thick)
		var nick := along * body.size.x * 0.1
		draw_line(rear + right_v * reach * 0.55, rear + right_v * reach * 0.55 - nick, ink, thick)
		draw_line(ahead + left_v * reach * 0.55, ahead + left_v * reach * 0.55 + nick, ink, thick)
	elif kind == Rules.Kind.SHARE:
		# The forward stroke leaves from the waiting item. The left stroke leaves from the arrival, ahead of it.
		# A prong's strokes leave right and left. A fork's two tines share one hub.
		var along := Vector2(Rules.vec(dir))
		var left_v := Vector2(Rules.vec(Rules.left(dir)))
		var ink := Color(1, 1, 1, 0.92 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var rear := center - along * body.size.x * 0.18
		var ahead := center + along * body.size.x * 0.12
		var reach := body.size.x * 0.28
		draw_line(rear, rear + along * reach, ink, thick)
		draw_line(ahead, ahead + left_v * reach, ink, thick)
		var nick := left_v * body.size.x * 0.08
		draw_line(rear + along * reach * 0.55, rear + along * reach * 0.55 + nick, ink, thick)
	elif kind == Rules.Kind.COULTER:
		# The forward stroke leaves from the waiting item. The right stroke leaves from the arrival, ahead of it.
		# A share's side stroke leaves left.
		var along := Vector2(Rules.vec(dir))
		var right_v := Vector2(Rules.vec(Rules.right(dir)))
		var ink := Color(1, 1, 1, 0.92 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var rear := center - along * body.size.x * 0.18
		var ahead := center + along * body.size.x * 0.12
		var reach := body.size.x * 0.28
		draw_line(rear, rear + along * reach, ink, thick)
		draw_line(ahead, ahead + right_v * reach, ink, thick)
		var nick := right_v * body.size.x * 0.08
		draw_line(rear + along * reach * 0.55, rear + along * reach * 0.55 - nick, ink, thick)
	elif kind == Rules.Kind.MOLDBOARD:
		# The left stroke leaves from the waiting item. The forward stroke leaves from the arrival, ahead of it.
		# A share's strokes are the same two exits with the items swapped. A coulter's side stroke leaves right.
		var along := Vector2(Rules.vec(dir))
		var left_v := Vector2(Rules.vec(Rules.left(dir)))
		var ink := Color("f3e1a8", 0.95 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var rear := center - along * body.size.x * 0.2
		var ahead := center + along * body.size.x * 0.14
		var reach := body.size.x * 0.24
		var shoulder := rear + left_v * body.size.x * 0.3
		var belly := center + left_v * body.size.x * 0.18
		var nose := ahead + along * body.size.x * 0.04
		var tip := ahead + along * body.size.x * 0.22 - left_v * body.size.x * 0.02
		draw_polyline(PackedVector2Array([shoulder, belly, nose, tip]), ink, thick)
		draw_line(rear, rear + left_v * reach, ink, thick)
		draw_line(ahead, ahead + along * reach, ink, thick)
	elif kind == Rules.Kind.LANDSIDE:
		# The right stroke leaves from the waiting item. The forward stroke leaves from the arrival, ahead of it.
		# A moldboard's side stroke leaves left. A coulter sends the waiter forward and the arrival right.
		var along := Vector2(Rules.vec(dir))
		var right_v := Vector2(Rules.vec(Rules.right(dir)))
		var ink := Color("f0c9a0", 0.95 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var rear := center - along * body.size.x * 0.2
		var ahead := center + along * body.size.x * 0.14
		var reach := body.size.x * 0.24
		var shoulder := rear + right_v * body.size.x * 0.3
		var belly := center + right_v * body.size.x * 0.18
		var nose := ahead + along * body.size.x * 0.04
		var tip := ahead + along * body.size.x * 0.22 - right_v * body.size.x * 0.02
		draw_polyline(PackedVector2Array([shoulder, belly, nose, tip]), ink, thick)
		draw_line(rear, rear + right_v * reach, ink, thick)
		draw_line(ahead, ahead + along * reach, ink, thick)
	elif kind == Rules.Kind.SLADE:
		# The backward stroke leaves from the waiting item. The forward stroke leaves from the arrival.
		# A landside's side stroke leaves right. A moldboard's side stroke leaves left.
		var along := Vector2(Rules.vec(dir))
		var back_v := -along
		var ink := Color("d5e4ef", 0.95 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var rear := center - along * body.size.x * 0.2
		var ahead := center + along * body.size.x * 0.14
		var reach := body.size.x * 0.24
		draw_line(rear, rear + back_v * reach, ink, thick)
		draw_line(ahead, ahead + along * reach, ink, thick)
	elif kind == Rules.Kind.HEEL:
		# The forward stroke leaves from the waiting item. The backward stroke leaves from the arrival.
		# A slade sends the waiter backward and the arrival forward.
		var along := Vector2(Rules.vec(dir))
		var back_v := -along
		var ink := Color("e7d7a2", 0.95 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var rear := center - along * body.size.x * 0.2
		var ahead := center + along * body.size.x * 0.14
		var reach := body.size.x * 0.24
		draw_line(rear, rear + along * reach, ink, thick)
		draw_line(ahead, ahead + back_v * reach, ink, thick)
	elif kind == Rules.Kind.STILT:
		# Entry is the left side. The waiter leaves backward. The arrival leaves forward.
		# A slade uses those same exits, but only for an arrival from behind.
		var along := Vector2(Rules.vec(dir))
		var back_v := -along
		var left_v := Vector2(Rules.vec(Rules.left(dir)))
		var ink := Color("d7f3ee", 0.95 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var rear := center - along * body.size.x * 0.2
		var ahead := center + along * body.size.x * 0.14
		var reach := body.size.x * 0.24
		var hip := center + left_v * body.size.x * 0.16
		draw_line(hip, hip + left_v * body.size.x * 0.16, ink, thick)
		draw_line(rear, rear + back_v * reach, ink, thick)
		draw_line(ahead, ahead + along * reach, ink, thick)
	elif kind == Rules.Kind.CLEVIS:
		# Entry is the right side. The waiter leaves forward. The arrival leaves backward.
		# A heel uses those same exits, but only for an arrival from behind.
		var along := Vector2(Rules.vec(dir))
		var back_v := -along
		var right_v := Vector2(Rules.vec(Rules.right(dir)))
		var ink := Color("f3d0d8", 0.95 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var rear := center - along * body.size.x * 0.2
		var ahead := center + along * body.size.x * 0.14
		var reach := body.size.x * 0.24
		var hip := center + right_v * body.size.x * 0.16
		draw_line(hip, hip + right_v * body.size.x * 0.16, ink, thick)
		draw_line(rear, rear + along * reach, ink, thick)
		draw_line(ahead, ahead + back_v * reach, ink, thick)
	elif kind == Rules.Kind.BEAM:
		# Entry is from ahead. The waiter leaves backward. The arrival leaves left.
		var along := Vector2(Rules.vec(dir))
		var back_v := -along
		var left_v := Vector2(Rules.vec(Rules.left(dir)))
		var ink := Color("e6dcf3", 0.95 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var rear := center - along * body.size.x * 0.2
		var reach := body.size.x * 0.24
		var nose := center + along * body.size.x * 0.16
		var hip := center + left_v * body.size.x * 0.1
		draw_line(nose, nose + along * body.size.x * 0.16, ink, thick)
		draw_line(rear, rear + back_v * reach, ink, thick)
		draw_line(hip, hip + left_v * reach, ink, thick)
	elif kind == Rules.Kind.HAKE:
		# Entry is from ahead. The waiter leaves backward. The arrival leaves right.
		# A beam uses the same entry and sends the arrival left.
		var along := Vector2(Rules.vec(dir))
		var back_v := -along
		var right_v := Vector2(Rules.vec(Rules.right(dir)))
		var ink := Color("cfe6ef", 0.95 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var rear := center - along * body.size.x * 0.2
		var reach := body.size.x * 0.24
		var nose := center + along * body.size.x * 0.16
		var hip := center + right_v * body.size.x * 0.1
		draw_line(nose, nose + along * body.size.x * 0.16, ink, thick)
		draw_line(rear, rear + back_v * reach, ink, thick)
		draw_line(hip, hip + right_v * reach, ink, thick)
	elif kind == Rules.Kind.SOLE:
		# Entry is from ahead. The waiter leaves forward. The arrival leaves right.
		# A hake uses the same entry and sends the waiter backward.
		var along := Vector2(Rules.vec(dir))
		var right_v := Vector2(Rules.vec(Rules.right(dir)))
		var ink := Color("f0d4c2", 0.95 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var nose := center + along * body.size.x * 0.16
		var reach := body.size.x * 0.24
		var hip := center + right_v * body.size.x * 0.1
		draw_line(nose, nose + along * body.size.x * 0.16, ink, thick)
		draw_line(center, center + along * reach, ink, thick)
		draw_line(hip, hip + right_v * reach, ink, thick)
	elif kind == Rules.Kind.FROG:
		# Entry is from ahead. The waiter leaves forward. The arrival leaves left.
		# A sole uses the same entry and sends the arrival right.
		var along := Vector2(Rules.vec(dir))
		var left_v := Vector2(Rules.vec(Rules.left(dir)))
		var ink := Color("d7efc4", 0.95 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var nose := center + along * body.size.x * 0.16
		var reach := body.size.x * 0.24
		var hip := center + left_v * body.size.x * 0.1
		draw_line(nose, nose + along * body.size.x * 0.16, ink, thick)
		draw_line(center, center + along * reach, ink, thick)
		draw_line(hip, hip + left_v * reach, ink, thick)
	elif kind == Rules.Kind.SHIN:
		# Entry is from ahead. The waiter leaves left. The arrival leaves forward.
		# A frog uses the same entry and sends the waiter forward.
		var along := Vector2(Rules.vec(dir))
		var left_v := Vector2(Rules.vec(Rules.left(dir)))
		var ink := Color("e4d6f2", 0.95 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var nose := center + along * body.size.x * 0.16
		var reach := body.size.x * 0.24
		var hip := center + left_v * body.size.x * 0.1
		draw_line(nose, nose + along * body.size.x * 0.16, ink, thick)
		draw_line(hip, hip + left_v * reach, ink, thick)
		draw_line(center, center + along * reach, ink, thick)
	elif kind == Rules.Kind.POINT:
		# Entry is from ahead. The waiter leaves right. The arrival leaves forward.
		# A shin uses the same entry and sends the waiter left.
		var along := Vector2(Rules.vec(dir))
		var right_v := Vector2(Rules.vec(Rules.right(dir)))
		var ink := Color("f3dcc4", 0.95 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var nose := center + along * body.size.x * 0.16
		var reach := body.size.x * 0.24
		var hip := center + right_v * body.size.x * 0.1
		draw_line(nose, nose + along * body.size.x * 0.16, ink, thick)
		draw_line(hip, hip + right_v * reach, ink, thick)
		draw_line(center, center + along * reach, ink, thick)
	elif kind == Rules.Kind.THROAT:
		# Entry is from ahead. The waiter leaves behind. The arrival leaves forward.
		# A point uses the same entry and sends the waiter right.
		var along := Vector2(Rules.vec(dir))
		var back_v := Vector2(Rules.vec(Rules.opposite(dir)))
		var ink := Color("f0c8d4", 0.95 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var nose := center + along * body.size.x * 0.16
		var reach := body.size.x * 0.24
		var hip := center + back_v * body.size.x * 0.1
		draw_line(nose, nose + along * body.size.x * 0.16, ink, thick)
		draw_line(hip, hip + back_v * reach, ink, thick)
		draw_line(center, center + along * reach, ink, thick)
	elif kind == Rules.Kind.WREST:
		# Entry is from ahead. The waiter leaves left. The arrival leaves right.
		# Neither leaves forward. A throat sends the waiter behind.
		var left_v := Vector2(Rules.vec(Rules.left(dir)))
		var right_v := Vector2(Rules.vec(Rules.right(dir)))
		var ink := Color("e0ecc8", 0.95 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var reach := body.size.x * 0.24
		var hip := center + left_v * body.size.x * 0.1
		var hip_r := center + right_v * body.size.x * 0.1
		draw_line(center, center + Vector2(Rules.vec(Rules.opposite(dir))) * body.size.x * 0.16, ink, thick)
		draw_line(hip, hip + left_v * reach, ink, thick)
		draw_line(hip_r, hip_r + right_v * reach, ink, thick)
	elif kind == Rules.Kind.JOINTER:
		# Entry is from ahead. The waiter leaves right. The arrival leaves left.
		# Neither leaves forward. A wrest sends the waiter left.
		var left_v := Vector2(Rules.vec(Rules.left(dir)))
		var right_v := Vector2(Rules.vec(Rules.right(dir)))
		var ink := Color("c8d4f0", 0.95 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var reach := body.size.x * 0.24
		var hip := center + right_v * body.size.x * 0.1
		var hip_l := center + left_v * body.size.x * 0.1
		draw_line(center, center + Vector2(Rules.vec(Rules.opposite(dir))) * body.size.x * 0.16, ink, thick)
		draw_line(hip, hip + right_v * reach, ink, thick)
		draw_line(hip_l, hip_l + left_v * reach, ink, thick)
	elif kind == Rules.Kind.BRIDLE:
		# Entry is from ahead. The waiter leaves left. The arrival leaves behind.
		# Neither leaves forward. A jointer sends the waiter right.
		var left_v := Vector2(Rules.vec(Rules.left(dir)))
		var back_v := Vector2(Rules.vec(Rules.opposite(dir)))
		var ink := Color("d4ccf0", 0.95 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var reach := body.size.x * 0.24
		var hip := center + left_v * body.size.x * 0.1
		var hip_b := center + back_v * body.size.x * 0.1
		draw_line(center, center + Vector2(Rules.vec(Rules.opposite(dir))) * body.size.x * 0.16, ink, thick)
		draw_line(hip, hip + left_v * reach, ink, thick)
		draw_line(hip_b, hip_b + back_v * reach, ink, thick)
	elif kind == Rules.Kind.TRASHBOARD:
		# Entry is from ahead. The waiter leaves right. The arrival leaves behind.
		# Neither leaves forward. A bridle sends the waiter left.
		var right_v := Vector2(Rules.vec(Rules.right(dir)))
		var back_v := Vector2(Rules.vec(Rules.opposite(dir)))
		var ink := Color("f0d4c0", 0.95 * alpha)
		var thick := maxf(2.0, body.size.x * 0.07)
		var reach := body.size.x * 0.24
		var hip := center + right_v * body.size.x * 0.1
		var hip_b := center + back_v * body.size.x * 0.1
		draw_line(center, center + Vector2(Rules.vec(Rules.opposite(dir))) * body.size.x * 0.16, ink, thick)
		draw_line(hip, hip + right_v * reach, ink, thick)
		draw_line(hip_b, hip_b + back_v * reach, ink, thick)
	elif kind == Rules.Kind.GRATE:
		var along := Vector2(Rules.vec(dir))
		var across := Vector2(Rules.vec(Rules.right(dir)))
		var bar := Color(1, 1, 1, 0.4 * alpha)
		var thick := maxf(1.5, body.size.x * 0.045)
		var offsets: Array[float] = [-0.18, 0.0, 0.18]
		for offset in offsets:
			var origin := center + across * body.size.x * offset
			draw_line(origin - along * body.size.x * 0.3, origin + along * body.size.x * 0.1, bar, thick)
	var forward_alpha := alpha
	var right_alpha := alpha
	if kind == Rules.Kind.SPLITTER:
		forward_alpha = alpha if phase == 0 else alpha * 0.35
		right_alpha = alpha if phase == 1 else alpha * 0.35
	elif kind == Rules.Kind.WEIR:
		right_alpha = alpha * 0.4
	var forward := light
	if kind == Rules.Kind.GRATE:
		forward = Color("d7dee6")
	if kind != Rules.Kind.HOOK and kind != Rules.Kind.DROP and kind != Rules.Kind.LIFT and kind != Rules.Kind.SHED and kind != Rules.Kind.RAKE and kind != Rules.Kind.HOE and kind != Rules.Kind.HARROW and kind != Rules.Kind.FORK and kind != Rules.Kind.PRONG and kind != Rules.Kind.SHARE and kind != Rules.Kind.COULTER and kind != Rules.Kind.MOLDBOARD and kind != Rules.Kind.LANDSIDE and kind != Rules.Kind.SLADE and kind != Rules.Kind.HEEL and kind != Rules.Kind.STILT and kind != Rules.Kind.CLEVIS and kind != Rules.Kind.BEAM and kind != Rules.Kind.HAKE and kind != Rules.Kind.SOLE and kind != Rules.Kind.FROG and kind != Rules.Kind.SHIN and kind != Rules.Kind.POINT and kind != Rules.Kind.THROAT and kind != Rules.Kind.WREST and kind != Rules.Kind.JOINTER and kind != Rules.Kind.BRIDLE and kind != Rules.Kind.TRASHBOARD:
		_arrow(front, dir, body.size.x * 0.2, body.size.x * 0.12, Color(forward.r, forward.g, forward.b, forward_alpha))
	if kind == Rules.Kind.HOOK:
		var turn := Rules.left(dir)
		var side := center + Vector2(Rules.vec(turn)) * body.size.x * 0.2
		var mark := Color("f4e1b5")
		_arrow(side, turn, body.size.x * 0.16, body.size.x * 0.1, Color(mark.r, mark.g, mark.b, alpha))
	elif kind == Rules.Kind.SHED:
		var turn := Rules.left(dir)
		var side := center + Vector2(Rules.vec(turn)) * body.size.x * 0.22
		var mark := Color("f0d2b8")
		_arrow(side, turn, body.size.x * 0.16, body.size.x * 0.1, Color(mark.r, mark.g, mark.b, alpha))
	elif kind == Rules.Kind.RAKE:
		var turn := Rules.left(dir)
		var side := center + Vector2(Rules.vec(turn)) * body.size.x * 0.3
		var mark := Color("e7d9f6")
		_arrow(side, turn, body.size.x * 0.16, body.size.x * 0.1, Color(mark.r, mark.g, mark.b, alpha))
	elif kind == Rules.Kind.HOE:
		var turn := Rules.right(dir)
		var side := center + Vector2(Rules.vec(turn)) * body.size.x * 0.3
		var mark := Color("d5f0c2")
		_arrow(side, turn, body.size.x * 0.16, body.size.x * 0.1, Color(mark.r, mark.g, mark.b, alpha))
	elif kind == Rules.Kind.HARROW:
		var turn := Rules.right(dir)
		var side := center + Vector2(Rules.vec(turn)) * body.size.x * 0.3
		var mark := Color("efe6c4")
		_arrow(side, turn, body.size.x * 0.16, body.size.x * 0.1, Color(mark.r, mark.g, mark.b, alpha))
	elif kind == Rules.Kind.FORK:
		var fork_mark := Color("d5e8f4")
		var left_turn := Rules.left(dir)
		var right_turn := Rules.right(dir)
		var left_side := center + Vector2(Rules.vec(left_turn)) * body.size.x * 0.3
		var right_side := center + Vector2(Rules.vec(right_turn)) * body.size.x * 0.3
		_arrow(left_side, left_turn, body.size.x * 0.14, body.size.x * 0.09, Color(fork_mark.r, fork_mark.g, fork_mark.b, alpha))
		_arrow(right_side, right_turn, body.size.x * 0.14, body.size.x * 0.09, Color(fork_mark.r, fork_mark.g, fork_mark.b, alpha))
	elif kind == Rules.Kind.PRONG:
		var prong_mark := Color("f3c4e0")
		var left_turn := Rules.left(dir)
		var right_turn := Rules.right(dir)
		var left_side := center + Vector2(Rules.vec(left_turn)) * body.size.x * 0.3
		var right_side := center + Vector2(Rules.vec(right_turn)) * body.size.x * 0.3
		_arrow(left_side, left_turn, body.size.x * 0.14, body.size.x * 0.09, Color(prong_mark.r, prong_mark.g, prong_mark.b, alpha))
		_arrow(right_side, right_turn, body.size.x * 0.14, body.size.x * 0.09, Color(prong_mark.r, prong_mark.g, prong_mark.b, alpha))
	elif kind == Rules.Kind.SHARE:
		var share_mark := Color("f6d2b4")
		var forward_turn := dir
		var left_turn := Rules.left(dir)
		var forward_side := center + Vector2(Rules.vec(forward_turn)) * body.size.x * 0.22
		var left_side := center + Vector2(Rules.vec(left_turn)) * body.size.x * 0.3
		_arrow(forward_side, forward_turn, body.size.x * 0.14, body.size.x * 0.09, Color(share_mark.r, share_mark.g, share_mark.b, alpha))
		_arrow(left_side, left_turn, body.size.x * 0.14, body.size.x * 0.09, Color(share_mark.r, share_mark.g, share_mark.b, alpha))
	elif kind == Rules.Kind.COULTER:
		var coulter_mark := Color("c5e6a8")
		var forward_turn := dir
		var right_turn := Rules.right(dir)
		var forward_side := center + Vector2(Rules.vec(forward_turn)) * body.size.x * 0.22
		var right_side := center + Vector2(Rules.vec(right_turn)) * body.size.x * 0.3
		_arrow(forward_side, forward_turn, body.size.x * 0.14, body.size.x * 0.09, Color(coulter_mark.r, coulter_mark.g, coulter_mark.b, alpha))
		_arrow(right_side, right_turn, body.size.x * 0.14, body.size.x * 0.09, Color(coulter_mark.r, coulter_mark.g, coulter_mark.b, alpha))
	elif kind == Rules.Kind.MOLDBOARD:
		var mold_mark := Color("f3e1a8")
		var left_turn := Rules.left(dir)
		var left_side := center + Vector2(Rules.vec(left_turn)) * body.size.x * 0.32
		var forward_side := center + Vector2(Rules.vec(dir)) * body.size.x * 0.28
		_arrow(left_side, left_turn, body.size.x * 0.14, body.size.x * 0.09, Color(mold_mark.r, mold_mark.g, mold_mark.b, alpha))
		_arrow(forward_side, dir, body.size.x * 0.14, body.size.x * 0.09, Color(mold_mark.r, mold_mark.g, mold_mark.b, alpha))
	elif kind == Rules.Kind.LANDSIDE:
		var land_mark := Color("f0c9a0")
		var right_turn := Rules.right(dir)
		var right_side := center + Vector2(Rules.vec(right_turn)) * body.size.x * 0.32
		var forward_side := center + Vector2(Rules.vec(dir)) * body.size.x * 0.28
		_arrow(right_side, right_turn, body.size.x * 0.14, body.size.x * 0.09, Color(land_mark.r, land_mark.g, land_mark.b, alpha))
		_arrow(forward_side, dir, body.size.x * 0.14, body.size.x * 0.09, Color(land_mark.r, land_mark.g, land_mark.b, alpha))
	elif kind == Rules.Kind.SLADE:
		var slade_mark := Color("d5e4ef")
		var back_turn := Rules.opposite(dir)
		var back_side := center + Vector2(Rules.vec(back_turn)) * body.size.x * 0.32
		var forward_side := center + Vector2(Rules.vec(dir)) * body.size.x * 0.28
		_arrow(back_side, back_turn, body.size.x * 0.14, body.size.x * 0.09, Color(slade_mark.r, slade_mark.g, slade_mark.b, alpha))
		_arrow(forward_side, dir, body.size.x * 0.14, body.size.x * 0.09, Color(slade_mark.r, slade_mark.g, slade_mark.b, alpha))
	elif kind == Rules.Kind.HEEL:
		var heel_mark := Color("e7d7a2")
		var back_turn := Rules.opposite(dir)
		var forward_side := center + Vector2(Rules.vec(dir)) * body.size.x * 0.32
		var back_side := center + Vector2(Rules.vec(back_turn)) * body.size.x * 0.28
		_arrow(forward_side, dir, body.size.x * 0.14, body.size.x * 0.09, Color(heel_mark.r, heel_mark.g, heel_mark.b, alpha))
		_arrow(back_side, back_turn, body.size.x * 0.14, body.size.x * 0.09, Color(heel_mark.r, heel_mark.g, heel_mark.b, alpha))
	elif kind == Rules.Kind.STILT:
		var stilt_mark := Color("d7f3ee")
		var back_turn := Rules.opposite(dir)
		var back_side := center + Vector2(Rules.vec(back_turn)) * body.size.x * 0.32
		var forward_side := center + Vector2(Rules.vec(dir)) * body.size.x * 0.28
		_arrow(back_side, back_turn, body.size.x * 0.14, body.size.x * 0.09, Color(stilt_mark.r, stilt_mark.g, stilt_mark.b, alpha))
		_arrow(forward_side, dir, body.size.x * 0.14, body.size.x * 0.09, Color(stilt_mark.r, stilt_mark.g, stilt_mark.b, alpha))
	elif kind == Rules.Kind.CLEVIS:
		var clevis_mark := Color("f3d0d8")
		var back_turn := Rules.opposite(dir)
		var forward_side := center + Vector2(Rules.vec(dir)) * body.size.x * 0.32
		var back_side := center + Vector2(Rules.vec(back_turn)) * body.size.x * 0.28
		_arrow(forward_side, dir, body.size.x * 0.14, body.size.x * 0.09, Color(clevis_mark.r, clevis_mark.g, clevis_mark.b, alpha))
		_arrow(back_side, back_turn, body.size.x * 0.14, body.size.x * 0.09, Color(clevis_mark.r, clevis_mark.g, clevis_mark.b, alpha))
	elif kind == Rules.Kind.BEAM:
		var beam_mark := Color("e6dcf3")
		var back_turn := Rules.opposite(dir)
		var left_turn := Rules.left(dir)
		var back_side := center + Vector2(Rules.vec(back_turn)) * body.size.x * 0.32
		var left_side := center + Vector2(Rules.vec(left_turn)) * body.size.x * 0.28
		_arrow(back_side, back_turn, body.size.x * 0.14, body.size.x * 0.09, Color(beam_mark.r, beam_mark.g, beam_mark.b, alpha))
		_arrow(left_side, left_turn, body.size.x * 0.14, body.size.x * 0.09, Color(beam_mark.r, beam_mark.g, beam_mark.b, alpha))
	elif kind == Rules.Kind.HAKE:
		var hake_mark := Color("cfe6ef")
		var back_turn := Rules.opposite(dir)
		var right_turn := Rules.right(dir)
		var back_side := center + Vector2(Rules.vec(back_turn)) * body.size.x * 0.32
		var right_side := center + Vector2(Rules.vec(right_turn)) * body.size.x * 0.28
		_arrow(back_side, back_turn, body.size.x * 0.14, body.size.x * 0.09, Color(hake_mark.r, hake_mark.g, hake_mark.b, alpha))
		_arrow(right_side, right_turn, body.size.x * 0.14, body.size.x * 0.09, Color(hake_mark.r, hake_mark.g, hake_mark.b, alpha))
	elif kind == Rules.Kind.SOLE:
		var sole_mark := Color("f0d4c2")
		var right_turn := Rules.right(dir)
		var forward_side := center + Vector2(Rules.vec(dir)) * body.size.x * 0.32
		var right_side := center + Vector2(Rules.vec(right_turn)) * body.size.x * 0.28
		_arrow(forward_side, dir, body.size.x * 0.14, body.size.x * 0.09, Color(sole_mark.r, sole_mark.g, sole_mark.b, alpha))
		_arrow(right_side, right_turn, body.size.x * 0.14, body.size.x * 0.09, Color(sole_mark.r, sole_mark.g, sole_mark.b, alpha))
	elif kind == Rules.Kind.FROG:
		var frog_mark := Color("d7efc4")
		var left_turn := Rules.left(dir)
		var forward_side := center + Vector2(Rules.vec(dir)) * body.size.x * 0.32
		var left_side := center + Vector2(Rules.vec(left_turn)) * body.size.x * 0.28
		_arrow(forward_side, dir, body.size.x * 0.14, body.size.x * 0.09, Color(frog_mark.r, frog_mark.g, frog_mark.b, alpha))
		_arrow(left_side, left_turn, body.size.x * 0.14, body.size.x * 0.09, Color(frog_mark.r, frog_mark.g, frog_mark.b, alpha))
	elif kind == Rules.Kind.SHIN:
		var shin_mark := Color("e4d6f2")
		var left_turn := Rules.left(dir)
		var left_side := center + Vector2(Rules.vec(left_turn)) * body.size.x * 0.28
		var forward_side := center + Vector2(Rules.vec(dir)) * body.size.x * 0.32
		_arrow(left_side, left_turn, body.size.x * 0.14, body.size.x * 0.09, Color(shin_mark.r, shin_mark.g, shin_mark.b, alpha))
		_arrow(forward_side, dir, body.size.x * 0.14, body.size.x * 0.09, Color(shin_mark.r, shin_mark.g, shin_mark.b, alpha))
	elif kind == Rules.Kind.POINT:
		var point_mark := Color("f3dcc4")
		var right_turn := Rules.right(dir)
		var right_side := center + Vector2(Rules.vec(right_turn)) * body.size.x * 0.28
		var forward_side := center + Vector2(Rules.vec(dir)) * body.size.x * 0.32
		_arrow(right_side, right_turn, body.size.x * 0.14, body.size.x * 0.09, Color(point_mark.r, point_mark.g, point_mark.b, alpha))
		_arrow(forward_side, dir, body.size.x * 0.14, body.size.x * 0.09, Color(point_mark.r, point_mark.g, point_mark.b, alpha))
	elif kind == Rules.Kind.THROAT:
		var throat_mark := Color("f0c8d4")
		var behind_turn := Rules.opposite(dir)
		var behind_side := center + Vector2(Rules.vec(behind_turn)) * body.size.x * 0.28
		var forward_side := center + Vector2(Rules.vec(dir)) * body.size.x * 0.32
		_arrow(behind_side, behind_turn, body.size.x * 0.14, body.size.x * 0.09, Color(throat_mark.r, throat_mark.g, throat_mark.b, alpha))
		_arrow(forward_side, dir, body.size.x * 0.14, body.size.x * 0.09, Color(throat_mark.r, throat_mark.g, throat_mark.b, alpha))
	elif kind == Rules.Kind.WREST:
		var wrest_mark := Color("e0ecc8")
		var left_turn := Rules.left(dir)
		var right_turn := Rules.right(dir)
		var left_side := center + Vector2(Rules.vec(left_turn)) * body.size.x * 0.28
		var right_side := center + Vector2(Rules.vec(right_turn)) * body.size.x * 0.28
		_arrow(left_side, left_turn, body.size.x * 0.14, body.size.x * 0.09, Color(wrest_mark.r, wrest_mark.g, wrest_mark.b, alpha))
		_arrow(right_side, right_turn, body.size.x * 0.14, body.size.x * 0.09, Color(wrest_mark.r, wrest_mark.g, wrest_mark.b, alpha))
	elif kind == Rules.Kind.JOINTER:
		var jointer_mark := Color("c8d4f0")
		var right_turn := Rules.right(dir)
		var left_turn := Rules.left(dir)
		var right_side := center + Vector2(Rules.vec(right_turn)) * body.size.x * 0.28
		var left_side := center + Vector2(Rules.vec(left_turn)) * body.size.x * 0.28
		_arrow(right_side, right_turn, body.size.x * 0.14, body.size.x * 0.09, Color(jointer_mark.r, jointer_mark.g, jointer_mark.b, alpha))
		_arrow(left_side, left_turn, body.size.x * 0.14, body.size.x * 0.09, Color(jointer_mark.r, jointer_mark.g, jointer_mark.b, alpha))
	elif kind == Rules.Kind.BRIDLE:
		var bridle_mark := Color("d4ccf0")
		var left_turn := Rules.left(dir)
		var behind_turn := Rules.opposite(dir)
		var left_side := center + Vector2(Rules.vec(left_turn)) * body.size.x * 0.28
		var behind_side := center + Vector2(Rules.vec(behind_turn)) * body.size.x * 0.28
		_arrow(left_side, left_turn, body.size.x * 0.14, body.size.x * 0.09, Color(bridle_mark.r, bridle_mark.g, bridle_mark.b, alpha))
		_arrow(behind_side, behind_turn, body.size.x * 0.14, body.size.x * 0.09, Color(bridle_mark.r, bridle_mark.g, bridle_mark.b, alpha))
	elif kind == Rules.Kind.TRASHBOARD:
		var trashboard_mark := Color("f0d4c0")
		var right_turn := Rules.right(dir)
		var behind_turn := Rules.opposite(dir)
		var right_side := center + Vector2(Rules.vec(right_turn)) * body.size.x * 0.28
		var behind_side := center + Vector2(Rules.vec(behind_turn)) * body.size.x * 0.28
		_arrow(right_side, right_turn, body.size.x * 0.14, body.size.x * 0.09, Color(trashboard_mark.r, trashboard_mark.g, trashboard_mark.b, alpha))
		_arrow(behind_side, behind_turn, body.size.x * 0.14, body.size.x * 0.09, Color(trashboard_mark.r, trashboard_mark.g, trashboard_mark.b, alpha))
	elif kind == Rules.Kind.DROP:
		var turn := Rules.right(dir)
		var side := center + Vector2(Rules.vec(turn)) * body.size.x * 0.2
		var mark := Color("e4d4f4")
		_arrow(side, turn, body.size.x * 0.16, body.size.x * 0.1, Color(mark.r, mark.g, mark.b, alpha))
	elif kind == Rules.Kind.LIFT:
		var turn := Rules.opposite(dir)
		var side := center + Vector2(Rules.vec(turn)) * body.size.x * 0.2
		var mark := Color("d6f0e4")
		_arrow(side, turn, body.size.x * 0.16, body.size.x * 0.1, Color(mark.r, mark.g, mark.b, alpha))
	elif kind == Rules.Kind.FILTER or kind == Rules.Kind.SPLITTER or kind == Rules.Kind.WEIR or kind == Rules.Kind.GRATE:
		var turn := Rules.right(dir)
		var side := center + Vector2(Rules.vec(turn)) * body.size.x * 0.18
		var mark := light
		if kind == Rules.Kind.FILTER:
			mark = Color("f2d48a")
		elif kind == Rules.Kind.GRATE:
			mark = Color("e7b15a")
		_arrow(side, turn, body.size.x * 0.16, body.size.x * 0.1, Color(mark.r, mark.g, mark.b, right_alpha))
	elif kind == Rules.Kind.BRIDGE:
		var turn := Rules.right(dir)
		var side := center + Vector2(Rules.vec(turn)) * body.size.x * 0.22
		_arrow(side, turn, body.size.x * 0.14, body.size.x * 0.09, Color(light.r, light.g, light.b, alpha))


func _draw_side(lay: Dictionary) -> void:
	var side: Rect2 = lay.side
	draw_rect(side, COL_PANEL)
	draw_rect(side, COL_EDGE, false, 2.0)
	var room := _room()
	var x := side.position.x + 16.0
	var y := side.position.y + 14.0
	_text(Vector2(x, y), "%02d   %s" % [int(room.id), room.name], 22, COL_TEXT)
	y += 40
	_text(Vector2(x, y), "QUOTA", 12, COL_DIM)
	y += 20
	var counts := _counts_now()
	var mats: Array = room.quota.keys()
	mats.sort()
	for mat in mats:
		var have := int(counts.get(int(mat), 0))
		var need := int(room.quota[mat])
		var done := have >= need and mode != Mode.EDIT
		_text(Vector2(x, y), Rules.MAT_NAME[int(mat)], 18, COL_OK if done else COL_TEXT)
		var ratio := "%d / %d" % [have, need]
		var ratio_w := font.get_string_size(ratio, HORIZONTAL_ALIGNMENT_LEFT, -1, 18).x
		_text(Vector2(side.position.x + side.size.x - 16 - ratio_w, y), ratio, 18, COL_OK if done else COL_ACCENT)
		y += 28
	y += 8
	_text(Vector2(x, y), "RULE", 12, COL_DIM)
	y += 18
	var limit := (lay.run_btn as Rect2).position.y - 40.0
	for line in _wrap(str(room.rule), side.size.x - 32.0, 14):
		if y > limit:
			break
		_text(Vector2(x, y), line, 14, COL_DIM)
		y += 18
	var run_label := "Run minute"
	if mode == Mode.RUN:
		run_label = "Skip to end"
	elif mode == Mode.DONE:
		run_label = "Run again"
	_button(lay.run_btn, run_label, true)
	_button(lay.restart_btn, "Restart room", false)
	if mode == Mode.DONE and not last_result.is_empty():
		var msg := "CLEARED"
		var col := COL_OK
		if not last_result.quota_ok:
			msg = "QUOTA MISSED"
			col = COL_BAD
		elif not last_result.budget_ok:
			msg = "OVER BUDGET"
			col = COL_BAD
		_text(Vector2(x, (lay.run_btn as Rect2).position.y - 18), msg, 16, col)


func _draw_tray(lay: Dictionary) -> void:
	for slot in lay.tray:
		var rect: Rect2 = slot.rect
		var kind := int(slot.kind)
		var selected := kind == selected_kind
		draw_rect(rect, Color("2a211b") if selected else COL_PANEL)
		draw_rect(rect, COL_ACCENT if selected else COL_EDGE, false, 2.0)
		var glyph := Rect2(rect.position + Vector2(8, 12), Vector2(64, 64))
		_glyph(glyph, kind, selected_dir if selected else Rules.Dir.EAST, 1.0, 0)
		var text_x := rect.position.x + 80.0
		_text(Vector2(text_x, rect.position.y + 14), Rules.KIND_NAME[kind], 15, COL_TEXT)
		var left: int = _planner().remaining(kind)
		_text(Vector2(text_x, rect.position.y + 36), _tray_count_line(kind, left), 18, COL_TEXT if left > 0 else COL_LOCK)
		_text(Vector2(text_x, rect.position.y + 60), "key %s" % _key_label(kind), 12, COL_DIM)


func _button(rect: Rect2, label: String, hot: bool) -> void:
	draw_rect(rect, COL_ACCENT if hot else Color("2a241e"))
	draw_rect(rect, COL_ACCENT if hot else COL_EDGE, false, 2.0)
	_text_in(rect, label, 16, Color("1a120c") if hot else COL_TEXT)


func _padlock(center: Vector2) -> void:
	draw_line(center + Vector2(-4, 0), center + Vector2(-4, -5), COL_LOCK, 1.5)
	draw_line(center + Vector2(-4, -5), center + Vector2(4, -5), COL_LOCK, 1.5)
	draw_line(center + Vector2(4, -5), center + Vector2(4, 0), COL_LOCK, 1.5)
	draw_rect(Rect2(center + Vector2(-5, 0), Vector2(10, 8)), COL_LOCK)


func _arrow(center: Vector2, dir: int, length: float, width: float, color: Color) -> void:
	var heading := Vector2(Rules.vec(dir))
	var normal := Vector2(-heading.y, heading.x)
	var tip := center + heading * length
	var base := center - heading * length * 0.35
	draw_colored_polygon(PackedVector2Array([tip, base + normal * width, base - normal * width]), color)


func _draw_rivets(rect: Rect2) -> void:
	var inset := 6.0
	var radius := 1.6
	var col := Color(1, 1, 1, 0.08)
	for corner in [
		rect.position + Vector2(inset, inset),
		rect.position + Vector2(rect.size.x - inset, inset),
		rect.position + Vector2(inset, rect.size.y - inset),
		rect.position + Vector2(rect.size.x - inset, rect.size.y - inset),
	]:
		draw_circle(corner, radius, col)


func _draw_item(center: Vector2, mat: int, scale: float) -> void:
	var col := _mat_color(mat)
	if mat == Rules.Mat.ORE:
		draw_circle(center, 12.0 * scale, Color(0, 0, 0, 0.45))
		draw_circle(center, 10.0 * scale, col)
		draw_circle(center + Vector2(-3, -3) * scale, 3.2 * scale, col.lightened(0.28))
	elif mat == Rules.Mat.INGOT:
		var size := Vector2(26, 11) * scale
		draw_rect(Rect2(center - size * 0.5 + Vector2(1, 1), size), Color(0, 0, 0, 0.4))
		draw_rect(Rect2(center - size * 0.5, size), col)
	else:
		var size := Vector2(34, 8) * scale
		draw_rect(Rect2(center - size * 0.5 + Vector2(1, 1), size), Color(0, 0, 0, 0.4))
		draw_rect(Rect2(center - size * 0.5, size), col)


func _key_label(kind: int) -> String:
	if kind == Rules.Kind.HOOK:
		return "0"
	if kind == Rules.Kind.ARM:
		return "-"
	if kind == Rules.Kind.DROP:
		return "="
	if kind == Rules.Kind.LIFT:
		return "\\"
	if kind == Rules.Kind.DWELL:
		return ";"
	if kind == Rules.Kind.TWIN:
		return ","
	if kind == Rules.Kind.PASS:
		return "'"
	if kind == Rules.Kind.SLIP:
		return "."
	if kind == Rules.Kind.SHED:
		return "/"
	if kind == Rules.Kind.RAKE:
		return "`"
	if kind == Rules.Kind.HOE:
		return "y"
	if kind == Rules.Kind.HARROW:
		return "u"
	if kind == Rules.Kind.FORK:
		return "i"
	if kind == Rules.Kind.PRONG:
		return "o"
	if kind == Rules.Kind.SHARE:
		return "p"
	if kind == Rules.Kind.COULTER:
		return "t"
	if kind == Rules.Kind.MOLDBOARD:
		return "g"
	if kind == Rules.Kind.LANDSIDE:
		return "h"
	if kind == Rules.Kind.SLADE:
		return "j"
	if kind == Rules.Kind.HEEL:
		return "k"
	if kind == Rules.Kind.STILT:
		return "l"
	if kind == Rules.Kind.CLEVIS:
		return "m"
	if kind == Rules.Kind.BEAM:
		return "n"
	if kind == Rules.Kind.HAKE:
		return "b"
	if kind == Rules.Kind.SOLE:
		return "v"
	if kind == Rules.Kind.FROG:
		return "c"
	if kind == Rules.Kind.SHIN:
		return "x"
	if kind == Rules.Kind.POINT:
		return "z"
	if kind == Rules.Kind.THROAT:
		return "d"
	if kind == Rules.Kind.WREST:
		return "a"
	if kind == Rules.Kind.JOINTER:
		return "s"
	if kind == Rules.Kind.BRIDLE:
		return "w"
	if kind == Rules.Kind.TRASHBOARD:
		return "Tab"
	return str(kind + 1)


func _tray_count_line(kind: int, count: int) -> String:
	# The clevis count reads "right" so room 201 shows "1 right" beside Clevis and its key.
	if kind == Rules.Kind.CLEVIS:
		return "%d right" % count
	# The beam count reads "ahead" so room 209 shows "1 ahead" beside Beam and its key.
	if kind == Rules.Kind.BEAM:
		return "%d ahead" % count
	# The hake count reads "ahead" so room 217 shows "1 ahead" beside Hake and its key.
	if kind == Rules.Kind.HAKE:
		return "%d ahead" % count
	# The sole count reads "ahead" so room 225 shows "1 ahead" beside Sole and its key.
	if kind == Rules.Kind.SOLE:
		return "%d ahead" % count
	# The frog count reads "ahead" so room 233 shows "1 ahead" beside Frog and its key.
	if kind == Rules.Kind.FROG:
		return "%d ahead" % count
	# The shin count reads "ahead" so room 241 shows "1 ahead" beside Shin and its key.
	if kind == Rules.Kind.SHIN:
		return "%d ahead" % count
	# The point count reads "ahead" so room 249 shows "1 ahead" beside Point and its key.
	if kind == Rules.Kind.POINT:
		return "%d ahead" % count
	# The throat count reads "ahead" so room 257 shows "1 ahead" beside Throat and its key.
	if kind == Rules.Kind.THROAT:
		return "%d ahead" % count
	# The wrest count reads "ahead" so room 265 shows "1 ahead" beside Wrest and its key.
	if kind == Rules.Kind.WREST:
		return "%d ahead" % count
	# The jointer count reads "ahead" so room 273 shows "1 ahead" beside Jointer and its key.
	if kind == Rules.Kind.JOINTER:
		return "%d ahead" % count
	# The bridle count reads "ahead" so room 281 shows "1 ahead" beside Bridle and its key.
	if kind == Rules.Kind.BRIDLE:
		return "%d ahead" % count
	# The trashboard count reads "ahead" so room 289 shows "1 ahead" beside Trashboard and its key.
	if kind == Rules.Kind.TRASHBOARD:
		return "%d ahead" % count
	return "%d left" % count


func _kind_color(kind: int) -> Color:
	if kind == Rules.Kind.BELT:
		return Color("e0a44a")
	if kind == Rules.Kind.KILN:
		return Color("d4532c")
	if kind == Rules.Kind.PRESS:
		return Color("b7c0cb")
	if kind == Rules.Kind.FILTER:
		return Color("3cb8b0")
	if kind == Rules.Kind.SPLITTER:
		return Color("c792ef")
	if kind == Rules.Kind.ROLLER:
		return Color("6aa6d8")
	if kind == Rules.Kind.WEIR:
		return Color("8fbf6a")
	if kind == Rules.Kind.BRIDGE:
		return Color("6f8f9a")
	if kind == Rules.Kind.GRATE:
		return Color("b56b7c")
	if kind == Rules.Kind.HOOK:
		return Color("3d6ea8")
	if kind == Rules.Kind.ARM:
		return Color("a35d3a")
	if kind == Rules.Kind.DROP:
		return Color("6e5aa8")
	if kind == Rules.Kind.LIFT:
		return Color("2a9a78")
	if kind == Rules.Kind.DWELL:
		return Color("c4a35a")
	if kind == Rules.Kind.TWIN:
		return Color("7d6bbd")
	if kind == Rules.Kind.PASS:
		return Color("d07a8c")
	if kind == Rules.Kind.SLIP:
		return Color("3f6f78")
	if kind == Rules.Kind.SHED:
		return Color("a34b3c")
	if kind == Rules.Kind.RAKE:
		return Color("5c4e86")
	if kind == Rules.Kind.HOE:
		return Color("c46a2f")
	if kind == Rules.Kind.HARROW:
		return Color("6e7a48")
	if kind == Rules.Kind.FORK:
		return Color("3d6f8a")
	if kind == Rules.Kind.PRONG:
		return Color("7a3e6d")
	if kind == Rules.Kind.SHARE:
		return Color("b85c38")
	if kind == Rules.Kind.COULTER:
		return Color("3f6b4e")
	if kind == Rules.Kind.MOLDBOARD:
		return Color("1e4d6b")
	if kind == Rules.Kind.LANDSIDE:
		return Color("6e4428")
	if kind == Rules.Kind.SLADE:
		return Color("3a5160")
	if kind == Rules.Kind.HEEL:
		return Color("8c6a2f")
	if kind == Rules.Kind.STILT:
		return Color("355e62")
	if kind == Rules.Kind.CLEVIS:
		return Color("6a3a4a")
	if kind == Rules.Kind.BEAM:
		return Color("4a3d62")
	if kind == Rules.Kind.HAKE:
		return Color("2a4a58")
	if kind == Rules.Kind.SOLE:
		return Color("5c3d2e")
	if kind == Rules.Kind.FROG:
		return Color("3e5a32")
	if kind == Rules.Kind.SHIN:
		return Color("4e3d6a")
	if kind == Rules.Kind.POINT:
		return Color("5a3e2a")
	if kind == Rules.Kind.THROAT:
		return Color("6a3040")
	if kind == Rules.Kind.WREST:
		return Color("4a5a30")
	if kind == Rules.Kind.JOINTER:
		return Color("28486a")
	if kind == Rules.Kind.BRIDLE:
		return Color("3a3068")
	if kind == Rules.Kind.TRASHBOARD:
		return Color("6a4030")
	return Color("c792ef")


func _mat_color(mat: int) -> Color:
	if mat == Rules.Mat.ORE:
		return Color("c4844a")
	if mat == Rules.Mat.INGOT:
		return Color("f2d48a")
	return Color("d7dee6")


func _pattern_label(pattern: Array) -> String:
	if pattern.size() == 1:
		return Rules.MAT_NAME[int(pattern[0])]
	var names: PackedStringArray = []
	var short := ["Ore", "Ing", "Plt"]
	var squeeze := pattern.size() >= 3
	for mat in pattern:
		var index := int(mat)
		names.append(short[index] if squeeze else Rules.MAT_NAME[index])
	return "/".join(names)


func _accept_label(accepts: Array) -> String:
	if accepts.size() >= 2:
		return "Ing+Plt"
	return Rules.MAT_NAME[int(accepts[0])]


func _source_pending(pos: Vector2i) -> int:
	if world == null:
		return -1
	for source in world.sources:
		if source.pos == pos:
			return int(source.pending)
	return -1


func _shown_tick() -> int:
	if world == null:
		return 0
	return int(world.tick)


func _text(pos: Vector2, text: String, size: int, color: Color) -> void:
	if font == null:
		return
	draw_string(font, pos + Vector2(0, font.get_ascent(size)), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


func _text_in(rect: Rect2, text: String, size: int, color: Color, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER) -> void:
	if font == null:
		return
	var ascent := font.get_ascent(size)
	var descent := font.get_descent(size)
	var baseline := rect.position.y + (rect.size.y - ascent - descent) * 0.5 + ascent
	draw_string(font, Vector2(rect.position.x + (8 if align == HORIZONTAL_ALIGNMENT_LEFT else 0), baseline), text, align, rect.size.x - (8 if align == HORIZONTAL_ALIGNMENT_LEFT else 0), size, color)


func _wrap(text: String, width: float, size: int) -> PackedStringArray:
	var lines: PackedStringArray = []
	if font == null:
		lines.append(text)
		return lines
	var current := ""
	for word in text.split(" "):
		var trial := word if current == "" else current + " " + word
		if font.get_string_size(trial, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > width and current != "":
			lines.append(current)
			current = word
		else:
			current = trial
	if current != "":
		lines.append(current)
	return lines


func _launched_by_tests() -> bool:
	for arg in OS.get_cmdline_args():
		if str(arg).contains("run_tests"):
			return true
	for arg in OS.get_cmdline_user_args():
		if str(arg).contains("run_tests"):
			return true
	return false


func _load_progress() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return
	for room_id in config.get_value("progress", "cleared", []):
		cleared[int(room_id)] = true


func _save_progress() -> void:
	if not save_enabled:
		return
	var config := ConfigFile.new()
	var ids: Array = []
	for room_id in cleared.keys():
		ids.append(int(room_id))
	ids.sort()
	config.set_value("progress", "cleared", ids)
	config.save(SAVE_PATH)


func testing_isolate() -> void:
	save_enabled = false
	cleared = {}


func testing_tray(kind: int) -> int:
	return _planner().remaining(kind)


func testing_place(kind: int, x: int, y: int, dir: int) -> bool:
	return _try_place(kind, x, y, dir)


func testing_pickup(x: int, y: int) -> bool:
	var ok := _try_pickup(x, y)
	queue_redraw()
	return ok


func testing_select(index: int) -> bool:
	if index < 0 or index >= rooms.size():
		return false
	if not is_unlocked(rooms[index].id):
		return false
	_select_room(index)
	return room_index == index


func testing_start_only() -> void:
	_start_run()


func testing_mode_edit() -> bool:
	return mode == Mode.EDIT


func testing_apply_and_run(placements: Array) -> Dictionary:
	if mode != Mode.EDIT:
		_back_to_edit()
	var snapshot: Array = _planner().placements.duplicate(true)
	for piece in snapshot:
		if not _try_pickup(int(piece.x), int(piece.y)):
			return {"success": false, "quota_ok": false, "budget_ok": false, "text": "pickup failed"}
	for piece in placements:
		if not _try_place(int(piece.kind), int(piece.x), int(piece.y), int(piece.dir)):
			return {"success": false, "quota_ok": false, "budget_ok": false, "text": "place failed %s" % str(piece)}
	_start_run()
	var guard := Rules.SIM_TICKS + 5
	while mode == Mode.RUN and guard > 0:
		_advance_tick()
		guard -= 1
	if mode != Mode.DONE:
		return {"success": false, "quota_ok": false, "budget_ok": false, "text": "run did not finish"}
	return last_result
