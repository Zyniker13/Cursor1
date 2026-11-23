extends Node2D

const Sim = preload("res://scripts/sim.gd")
const Puzzles = preload("res://scripts/puzzles.gd")
const Scoring = preload("res://scripts/scoring.gd")

const HEADER_H := 168.0
const PANEL_W := 438.0
const MARGIN := 18.0
const FRAME_SEC := 0.36

const INK := Color("#f3ead8")
const MUTED := Color("#b3a894")
const AMBER := Color("#e4a45c")
const PANEL := Color("#171b26")
const FLOOR := Color("#1d2230")

var _puzzles: Array = []
var _index := 0
var _puzzle: Dictionary = {}
var _placed: Dictionary = {}
var _selected := "conveyor"
var _ghost_dir := 0
var _paint := "red"
var _hover := Vector2i(-1, -1)
var _frames: Array = []
var _frame_i := 0
var _frame_t := 0.0
var _playing := false
var _last_result: Dictionary = {}
var _banner_up := false
var _grid_origin := Vector2.ZERO
var _cell := 80.0
var _font: Font

var _help: Label
var _brief: Label
var _name: Label
var _building_label: Label
var _facing: Label
var _tick: Label
var _placed_label: Label
var _banner: PanelContainer
var _banner_label: Label
var _tool_box: Container
var _swatch_row: HBoxContainer
var _order_box: VBoxContainer
var _puzzle_buttons: Array = []
var _tool_buttons: Dictionary = {}
var _swatches: Dictionary = {}
var _order_labels: Array = []


func _ready() -> void:
	_font = ThemeDB.fallback_font
	_puzzles = Puzzles.all()
	_build_ui()
	select_puzzle(0)
	if get_viewport() != null:
		get_viewport().size_changed.connect(_on_resized)


func get_puzzle() -> Dictionary:
	return _puzzle


func select_puzzle(index: int) -> void:
	if index < 0 or index >= _puzzles.size():
		return
	_index = index
	_puzzle = _puzzles[index]
	_placed = {}
	_playing = false
	_frames = []
	_frame_i = 0
	_frame_t = 0.0
	_last_result = {}
	_ghost_dir = 0
	_hover = Vector2i(-1, -1)
	var unlocked: Array = Puzzles.unlocked_at(index)
	if unlocked.is_empty():
		_selected = "conveyor"
	elif not unlocked.has(_selected):
		_selected = str(unlocked[0])
	_hide_banner()
	_layout()
	_refresh_copy()
	_rebuild_tools()
	_rebuild_order()
	_style_puzzle_buttons()
	_sync_facing()
	_sync_placed()
	_sync_tick()
	queue_redraw()


func format_result(result: Dictionary) -> String:
	return Scoring.present(_puzzle, result)


func _process(delta: float) -> void:
	if not _playing:
		return
	_frame_t += delta
	if _frame_t >= FRAME_SEC:
		_frame_t -= FRAME_SEC
		_frame_i += 1
		if _frame_i >= _frames.size() - 1:
			_frame_i = maxi(_frames.size() - 1, 0)
			_playing = false
			_reveal()
		_sync_tick()
		_sync_order()
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var motion := event as InputEventMouseMotion
		var cell := _cell_at(motion.position)
		if cell != _hover:
			_hover = cell
			queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var button := event as InputEventMouseButton
		if button.button_index == MOUSE_BUTTON_LEFT:
			_on_left(button.position)
		elif button.button_index == MOUSE_BUTTON_RIGHT:
			_delete_cell(_cell_at(button.position))
	elif event is InputEventKey and event.pressed:
		var key := event as InputEventKey
		if key.echo and key.keycode != KEY_R:
			return
		if key.keycode == KEY_R:
			_on_rotate()
		elif key.keycode == KEY_DELETE:
			_delete_cell(_hover)
		elif key.keycode == KEY_ENTER or key.keycode == KEY_KP_ENTER:
			_submit()
		elif key.keycode == KEY_BACKSPACE:
			_restart()
		elif key.keycode >= KEY_1 and key.keycode <= KEY_8:
			select_puzzle(int(key.keycode) - int(KEY_1))
		elif key.keycode == KEY_BRACKETLEFT:
			select_puzzle(_index - 1)
		elif key.keycode == KEY_BRACKETRIGHT:
			select_puzzle(_index + 1)


func _on_resized() -> void:
	_layout()
	queue_redraw()


func _submit() -> void:
	if _playing or _puzzle.is_empty():
		return
	var graph: Array = []
	for key in _placed.keys():
		var block: Dictionary = _placed[key]
		var item := {
			"type": str(block["type"]),
			"x": int(block["x"]),
			"y": int(block["y"]),
			"dir": int(block["dir"]),
		}
		if str(block["type"]) == "painter" or str(block["type"]) == "filter" or str(block["type"]) == "primer":
			item["color"] = str(block["color"])
		graph.append(item)
	_last_result = Sim.run(_puzzle, graph)
	_frames = _last_result["frames"]
	if _frames.size() > 36:
		var shortened: Array = []
		for i in range(24):
			shortened.append(_frames[i])
		shortened.append(_frames[_frames.size() - 1])
		_frames = shortened
	_frame_i = 0
	_frame_t = 0.0
	_hide_banner()
	_playing = _frames.size() > 1
	if not _playing:
		_reveal()
	_sync_tick()
	_sync_order()
	queue_redraw()


func _restart() -> void:
	_placed = {}
	_playing = false
	_frames = []
	_frame_i = 0
	_last_result = {}
	_hide_banner()
	_sync_tick()
	_sync_order()
	_sync_placed()
	queue_redraw()


func _reveal() -> void:
	if _banner == null or _last_result.is_empty():
		return
	var won := bool(_last_result.get("success", false))
	_banner_label.text = format_result(_last_result)
	var border := Color("#9ed67f") if won else Color("#e06a5c")
	var fill := Color("#1a2820") if won else Color("#2c1a1c")
	_banner.add_theme_stylebox_override("panel", _box(fill, border, 12))
	_banner.visible = true
	_banner.mouse_filter = Control.MOUSE_FILTER_STOP
	_banner_up = true
	_sync_tick()


func _hide_banner() -> void:
	_banner_up = false
	if _banner == null:
		return
	_banner.visible = false
	_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _dismiss_result() -> void:
	if _banner_up or not _frames.is_empty():
		_playing = false
		_frames = []
		_frame_i = 0
		_last_result = {}
		_hide_banner()
		_sync_tick()
		_sync_order()


func _on_left(screen: Vector2) -> void:
	if _playing:
		return
	var cell := _cell_at(screen)
	if not _can_place(cell):
		return
	_dismiss_result()
	if not _placed.has(cell):
		_put(cell)
	else:
		var block: Dictionary = _placed[cell]
		if str(block["type"]) != _selected:
			_put(cell)
		elif (str(block["type"]) == "painter" or str(block["type"]) == "filter" or str(block["type"]) == "primer") and str(block.get("color", "")) != _paint:
			block["color"] = _paint
		else:
			block["dir"] = (int(block["dir"]) + 1) % 4
	_sync_placed()
	queue_redraw()


func _on_rotate() -> void:
	if _playing:
		return
	if _hover.x >= 0 and _placed.has(_hover):
		var block: Dictionary = _placed[_hover]
		block["dir"] = (int(block["dir"]) + 1) % 4
		_dismiss_result()
	else:
		_ghost_dir = (_ghost_dir + 1) % 4
		_sync_facing()
	queue_redraw()


func _delete_cell(cell: Vector2i) -> void:
	if _playing:
		return
	if cell.x < 0 or not _placed.has(cell):
		return
	_placed.erase(cell)
	_dismiss_result()
	_sync_placed()
	queue_redraw()


func _put(cell: Vector2i) -> void:
	var block := {
		"type": _selected,
		"x": cell.x,
		"y": cell.y,
		"dir": _ghost_dir,
	}
	if _selected == "painter" or _selected == "filter" or _selected == "primer":
		block["color"] = _paint
	_placed[cell] = block


func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	var root := Control.new()
	root.name = "UI"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(root)
	var theme := Theme.new()
	theme.default_font_size = 16
	theme.set_color("font_color", "Label", INK)
	root.theme = theme

	var header := PanelContainer.new()
	header.mouse_filter = Control.MOUSE_FILTER_STOP
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.offset_bottom = HEADER_H
	header.add_theme_stylebox_override("panel", _box(PANEL, Color("#2a3144"), 0))
	root.add_child(header)
	var header_margin := MarginContainer.new()
	for side in ["left", "right", "top", "bottom"]:
		header_margin.add_theme_constant_override("margin_%s" % side, 12 if side != "top" else 8)
	header.add_child(header_margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 2)
	header_margin.add_child(column)

	var title_row := HBoxContainer.new()
	column.add_child(title_row)
	var word := Label.new()
	word.text = "DISPATCH"
	word.add_theme_font_size_override("font_size", 28)
	word.add_theme_color_override("font_color", AMBER)
	title_row.add_child(word)
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title_row.add_child(gap)
	_building_label = Label.new()
	_building_label.name = "BuildingLabel"
	_building_label.text = "BUILDING 1"
	_building_label.add_theme_color_override("font_color", MUTED)
	_building_label.add_theme_font_size_override("font_size", 16)
	title_row.add_child(_building_label)

	var puzzles_row := HBoxContainer.new()
	puzzles_row.name = "PuzzleRow"
	puzzles_row.add_theme_constant_override("separation", 2)
	column.add_child(puzzles_row)
	for i in _puzzles.size():
		var building_now := int(_puzzles[i].get("building", 1))
		var building_prev := 1
		if i > 0:
			building_prev = int(_puzzles[i - 1].get("building", 1))
		if building_now > 1 and building_now != building_prev:
			var mark := Label.new()
			mark.name = _building_mark_name(building_now)
			mark.text = "B%d" % building_now
			mark.add_theme_color_override("font_color", AMBER)
			mark.add_theme_font_size_override("font_size", 11)
			puzzles_row.add_child(mark)
		var button := Button.new()
		button.name = "RouteButton%d" % (i + 1)
		button.text = str(i + 1)
		button.tooltip_text = str(_puzzles[i]["title"])
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(16, 24)
		button.add_theme_font_size_override("font_size", 10)
		button.pressed.connect(select_puzzle.bind(i))
		puzzles_row.add_child(button)
		_puzzle_buttons.append(button)

	_name = Label.new()
	_name.add_theme_font_size_override("font_size", 20)
	column.add_child(_name)
	_brief = Label.new()
	_brief.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_brief)
	_help = Label.new()
	_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_help.custom_minimum_size = Vector2(0, 40)
	_help.add_theme_font_size_override("font_size", 14)
	_help.add_theme_color_override("font_color", MUTED)
	column.add_child(_help)

	var side := PanelContainer.new()
	side.mouse_filter = Control.MOUSE_FILTER_STOP
	side.anchor_left = 1.0
	side.anchor_right = 1.0
	side.anchor_top = 0.0
	side.anchor_bottom = 1.0
	side.offset_left = -(PANEL_W + 12.0)
	side.offset_right = -12.0
	side.offset_top = HEADER_H + 10.0
	side.offset_bottom = -12.0
	side.add_theme_stylebox_override("panel", _box(PANEL, Color("#2a3144"), 8))
	root.add_child(side)
	var side_margin := MarginContainer.new()
	for side_name in ["left", "right", "top", "bottom"]:
		side_margin.add_theme_constant_override("margin_%s" % side_name, 12)
	side.add_child(side_margin)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 6)
	side_margin.add_child(stack)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	stack.add_child(scroll)
	var upper := VBoxContainer.new()
	upper.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	upper.add_theme_constant_override("separation", 6)
	scroll.add_child(upper)

	upper.add_child(_section("BLOCKS"))
	var tools := HFlowContainer.new()
	tools.name = "ToolBox"
	tools.add_theme_constant_override("h_separation", 6)
	tools.add_theme_constant_override("v_separation", 6)
	_tool_box = tools
	upper.add_child(_tool_box)
	_swatch_row = HBoxContainer.new()
	_swatch_row.add_theme_constant_override("separation", 6)
	upper.add_child(_swatch_row)
	_facing = Label.new()
	_facing.add_theme_color_override("font_color", MUTED)
	upper.add_child(_facing)
	_placed_label = Label.new()
	upper.add_child(_placed_label)
	upper.add_child(_section("ORDER"))
	_order_box = VBoxContainer.new()
	_order_box.add_theme_constant_override("separation", 2)
	upper.add_child(_order_box)

	_tick = Label.new()
	_tick.add_theme_color_override("font_color", AMBER)
	stack.add_child(_tick)
	var submit := _action_button("Submit   Enter")
	submit.pressed.connect(_submit)
	stack.add_child(submit)
	var restart := _action_button("Restart   Backspace")
	restart.pressed.connect(_restart)
	stack.add_child(restart)
	var keys := Label.new()
	keys.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	keys.text = "R rotate    Delete remove\n1-8 puzzle    [ ] step"
	keys.add_theme_font_size_override("font_size", 13)
	keys.add_theme_color_override("font_color", MUTED)
	stack.add_child(keys)

	_banner = PanelContainer.new()
	_banner.visible = false
	_banner.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_banner.set_anchors_preset(Control.PRESET_TOP_LEFT)
	_banner.add_theme_stylebox_override("panel", _box(Color("#1a2820"), Color("#9ed67f"), 12))
	root.add_child(_banner)
	_banner_label = Label.new()
	_banner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_banner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_banner_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_banner_label.custom_minimum_size = Vector2(420, 230)
	_banner_label.add_theme_font_size_override("font_size", 28)
	_banner.add_child(_banner_label)


func _building_mark_name(building: int) -> String:
	match building:
		2:
			return "BuildingTwoMark"
		3:
			return "BuildingThreeMark"
		4:
			return "BuildingFourMark"
		5:
			return "BuildingFiveMark"
		6:
			return "BuildingSixMark"
		7:
			return "BuildingSevenMark"
		8:
			return "BuildingEightMark"
		9:
			return "BuildingNineMark"
		10:
			return "BuildingTenMark"
		11:
			return "BuildingElevenMark"
		12:
			return "BuildingTwelveMark"
		13:
			return "BuildingThirteenMark"
		14:
			return "BuildingFourteenMark"
		15:
			return "BuildingFifteenMark"
		16:
			return "BuildingSixteenMark"
		17:
			return "BuildingSeventeenMark"
		18:
			return "BuildingEighteenMark"
		19:
			return "BuildingNineteenMark"
		20:
			return "BuildingTwentyMark"
		21:
			return "BuildingTwentyOneMark"
		22:
			return "BuildingTwentyTwoMark"
		23:
			return "BuildingTwentyThreeMark"
		24:
			return "BuildingTwentyFourMark"
		25:
			return "BuildingTwentyFiveMark"
		26:
			return "BuildingTwentySixMark"
		27:
			return "BuildingTwentySevenMark"
		28:
			return "BuildingTwentyEightMark"
		29:
			return "BuildingTwentyNineMark"
		30:
			return "BuildingThirtyMark"
		31:
			return "BuildingThirtyOneMark"
		32:
			return "BuildingThirtyTwoMark"
		33:
			return "BuildingThirtyThreeMark"
		34:
			return "BuildingThirtyFourMark"
		35:
			return "BuildingThirtyFiveMark"
		36:
			return "BuildingThirtySixMark"
		37:
			return "BuildingThirtySevenMark"
		38:
			return "BuildingThirtyEightMark"
		39:
			return "BuildingThirtyNineMark"
		40:
			return "BuildingFortyMark"
		41:
			return "BuildingFortyOneMark"
		42:
			return "BuildingFortyTwoMark"
		43:
			return "BuildingFortyThreeMark"
		44:
			return "BuildingFortyFourMark"
		_:
			return "Building%dMark" % building


func _section(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 13)
	label.add_theme_color_override("font_color", AMBER)
	return label


func _action_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.custom_minimum_size = Vector2(0, 40)
	_paint_button(button, Color("#2c3348"), INK, AMBER)
	return button


func _refresh_copy() -> void:
	if _name == null:
		return
	_name.text = "%d   %s" % [int(_puzzle["id"]), str(_puzzle["title"])]
	_brief.text = str(_puzzle["brief"])
	if _building_label:
		_building_label.text = "BUILDING %d" % int(_puzzle.get("building", 1))
	var lines: PackedStringArray = []
	if str(_puzzle.get("how_to", "")) != "":
		lines.append(str(_puzzle["how_to"]))
	if str(_puzzle.get("hint", "")) != "":
		lines.append(str(_puzzle["hint"]))
	_help.text = "\n".join(lines)


func _rebuild_tools() -> void:
	if _tool_box == null:
		return
	for child in _tool_box.get_children():
		child.queue_free()
	_tool_buttons.clear()
	for child in _swatch_row.get_children():
		child.queue_free()
	_swatches.clear()
	var unlocked: Array = Puzzles.unlocked_at(_index)
	for tool in unlocked:
		var button := Button.new()
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(124, 30)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.text = str(tool).capitalize()
		if str(_puzzle.get("unlocks", "")) == str(tool):
			button.text += " *"
		button.tooltip_text = _tool_tip(str(tool))
		button.pressed.connect(_choose_tool.bind(str(tool)))
		_tool_box.add_child(button)
		_tool_buttons[str(tool)] = button
	_style_tools()
	if unlocked.has("painter") or unlocked.has("filter") or unlocked.has("primer"):
		for color_name in Sim.PAINTS:
			var swatch := Button.new()
			swatch.focus_mode = Control.FOCUS_NONE
			swatch.custom_minimum_size = Vector2(36, 28)
			swatch.tooltip_text = str(color_name)
			swatch.pressed.connect(_choose_paint.bind(str(color_name)))
			_swatch_row.add_child(swatch)
			_swatches[str(color_name)] = swatch
		_style_swatches()


func _rebuild_order() -> void:
	if _order_box == null:
		return
	for child in _order_box.get_children():
		child.queue_free()
	_order_labels.clear()
	for spec in _puzzle["order"]:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		var chip := ColorRect.new()
		chip.custom_minimum_size = Vector2(16, 16)
		chip.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		chip.color = _spec_color(spec)
		var label := Label.new()
		row.add_child(chip)
		row.add_child(label)
		_order_box.add_child(row)
		_order_labels.append(label)
	_sync_order()


func _choose_tool(tool: String) -> void:
	_selected = tool
	_style_tools()
	_sync_facing()


func _choose_paint(color_name: String) -> void:
	_paint = color_name
	_style_swatches()
	queue_redraw()


func _style_puzzle_buttons() -> void:
	for i in _puzzle_buttons.size():
		var button: Button = _puzzle_buttons[i]
		if i == _index:
			_paint_button(button, AMBER, Color("#1a140e"), Color("#f6e2c2"), 1)
		else:
			_paint_button(button, Color("#2c3348"), INK, Color("#4a536c"), 1)


func _style_tools() -> void:
	for tool in _tool_buttons.keys():
		var button: Button = _tool_buttons[tool]
		var accent := _tool_color(str(tool))
		if str(tool) == _selected:
			_paint_button(button, accent.darkened(0.45), INK, INK)
		else:
			_paint_button(button, Color("#242a3a"), INK, accent)


func _style_swatches() -> void:
	for color_name in _swatches.keys():
		var button: Button = _swatches[color_name]
		var fill := _parcel_color(str(color_name))
		var border := INK if str(color_name) == _paint else Color("#1a140e")
		_paint_button(button, fill, Color("#1a140e"), border)


func _paint_button(button: Button, fill: Color, font: Color, border: Color, pad: int = 8) -> void:
	var normal := _box(fill, border, 4, pad)
	var hover := _box(fill.lightened(0.12), border, 4, pad)
	var pressed := _box(fill.darkened(0.12), border, 4, pad)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	button.add_theme_color_override("font_color", font)
	button.add_theme_color_override("font_hover_color", font)
	button.add_theme_color_override("font_pressed_color", font)


func _sync_facing() -> void:
	if _facing:
		if _selected == "turn":
			_facing.text = "Facing   clockwise"
		elif _selected == "hook":
			_facing.text = "Facing   counterclockwise"
		elif _selected == "slide":
			_facing.text = "Facing   with the parcel"
		elif _selected == "bin" or _selected == "return" or _selected == "pause" or _selected == "shunt" or _selected == "bias" or _selected == "vault" or _selected == "sling" or _selected == "cant" or _selected == "balk" or _selected == "loft" or _selected == "keel" or _selected == "sheer" or _selected == "strake" or _selected == "wale" or _selected == "garboard" or _selected == "stealer" or _selected == "rabbet" or _selected == "futtock" or _selected == "keelson" or _selected == "stemson" or _selected == "apron" or _selected == "deadwood" or _selected == "gripe" or _selected == "forefoot" or _selected == "knighthead" or _selected == "hawse" or _selected == "breasthook" or _selected == "cathead" or _selected == "gammon" or _selected == "bobstay" or _selected == "bumpkin" or _selected == "dolphin" or _selected == "martingale" or _selected == "jibboom" or _selected == "whisker" or _selected == "cranse":
			_facing.text = "Facing   none"
		else:
			_facing.text = "Facing   %s" % Sim.DIR_NAMES[_ghost_dir]


func _sync_placed() -> void:
	if _placed_label:
		_placed_label.text = "Placed   %d" % _placed.size()


func _sync_tick() -> void:
	if _tick == null:
		return
	if _playing and not _frames.is_empty():
		_tick.text = "Tick   %d" % int(_frames[_frame_i]["tick"])
		_tick.visible = true
	else:
		_tick.text = ""
		_tick.visible = false


func _sync_order() -> void:
	var delivered: Array = []
	if not _frames.is_empty() and _frame_i >= 0 and _frame_i < _frames.size():
		delivered = _frames[_frame_i]["delivered"]
	var order: Array = _puzzle.get("order", [])
	for i in _order_labels.size():
		var spec: Dictionary = order[i]
		var mark := "[ ]  "
		if i < delivered.size():
			mark = "[x]  " if _spec_met(spec, delivered[i]) else "[!]  "
		_order_labels[i].text = mark + _spec_line(spec)


func _spec_line(spec: Dictionary) -> String:
	var color_name := str(spec["color"]) if spec.has("color") else ""
	var count_name := "#%d" % int(spec["count"]) if spec.has("count") else ""
	if color_name != "" and count_name != "":
		return "%s   %s" % [color_name, count_name]
	if color_name != "":
		return color_name
	if count_name != "":
		return count_name
	return "parcel"


func _spec_met(spec: Dictionary, parcel: Dictionary) -> bool:
	if spec.has("color") and str(spec["color"]) != str(parcel["color"]):
		return false
	if spec.has("count") and int(spec["count"]) != int(parcel["count"]):
		return false
	return true


func _spec_color(spec: Dictionary) -> Color:
	if spec.has("color"):
		return _parcel_color(str(spec["color"]))
	return _parcel_color("gray")


func _layout() -> void:
	if _puzzle.is_empty():
		return
	var vp := _viewport_size()
	var area_pos := Vector2(MARGIN, HEADER_H + 12.0)
	var area_size := Vector2(vp.x - PANEL_W - MARGIN - 36.0, vp.y - HEADER_H - 28.0)
	var slots := Vector2(float(_puzzle["width"]), float(_puzzle["height"]))
	var raw := minf(area_size.x / slots.x, area_size.y / slots.y)
	_cell = floor(clampf(raw, 56.0, 108.0))
	var grid_size := slots * _cell
	_grid_origin = area_pos + (area_size - grid_size) * 0.5
	_place_banner()


func _place_banner() -> void:
	if _banner == null:
		return
	var vp := _viewport_size()
	var left := MARGIN
	var right := vp.x - PANEL_W - 36.0
	var top := HEADER_H + 16.0
	var bottom := vp.y - 20.0
	var banner_size := Vector2(440, 250)
	var origin := Vector2(left, top) + (Vector2(right - left, bottom - top) - banner_size) * 0.5
	_banner.offset_left = origin.x
	_banner.offset_top = origin.y
	_banner.offset_right = origin.x + banner_size.x
	_banner.offset_bottom = origin.y + banner_size.y


func _viewport_size() -> Vector2:
	var vp := get_viewport()
	if vp == null:
		return Vector2(1280, 720)
	var size := vp.get_visible_rect().size
	if size.x < 64.0 or size.y < 64.0:
		return Vector2(1280, 720)
	return size


func _cell_rect(x: int, y: int) -> Rect2:
	return Rect2(_grid_origin + Vector2(x, y) * _cell, Vector2(_cell, _cell))


func _cell_at(screen: Vector2) -> Vector2i:
	if _puzzle.is_empty() or _cell <= 0.0:
		return Vector2i(-1, -1)
	var local := screen - _grid_origin
	var x := int(floor(local.x / _cell))
	var y := int(floor(local.y / _cell))
	if x < 0 or y < 0 or x >= int(_puzzle["width"]) or y >= int(_puzzle["height"]):
		return Vector2i(-1, -1)
	return Vector2i(x, y)


func _can_place(cell: Vector2i) -> bool:
	if cell.x < 0:
		return false
	if cell.x >= int(_puzzle["width"]) or cell.y >= int(_puzzle["height"]):
		return false
	if _is_wall(cell) or _is_source(cell) or _is_dock(cell):
		return false
	return true


func _is_wall(cell: Vector2i) -> bool:
	for wall in _puzzle.get("walls", []):
		if int(wall["x"]) == cell.x and int(wall["y"]) == cell.y:
			return true
	return false


func _is_source(cell: Vector2i) -> bool:
	for source in _puzzle["sources"]:
		if int(source["x"]) == cell.x and int(source["y"]) == cell.y:
			return true
	return false


func _is_dock(cell: Vector2i) -> bool:
	var dock: Dictionary = _puzzle["dock"]
	return int(dock["x"]) == cell.x and int(dock["y"]) == cell.y


func _draw() -> void:
	var vp := _viewport_size()
	draw_rect(Rect2(Vector2.ZERO, vp), Color("#12151c"))
	if _puzzle.is_empty():
		return
	var slots := Vector2(float(_puzzle["width"]), float(_puzzle["height"]))
	var floor_rect := Rect2(_grid_origin, slots * _cell)
	draw_rect(floor_rect.grow(10), Color("#0e1118"))
	draw_rect(floor_rect, FLOOR)
	for y in int(_puzzle["height"]):
		for x in int(_puzzle["width"]):
			var rect := _cell_rect(x, y).grow(-2)
			var fill := Color("#2a3144")
			if _hover == Vector2i(x, y) and _can_place(_hover) and not _playing:
				fill = Color("#343c54")
			draw_rect(rect, fill)
	for wall in _puzzle.get("walls", []):
		_draw_wall(int(wall["x"]), int(wall["y"]))
	for source in _puzzle["sources"]:
		_draw_source(source)
	_draw_dock()
	for key in _placed.keys():
		_draw_block(_placed[key], 1.0)
	if not _playing and _can_place(_hover) and not _placed.has(_hover):
		_draw_block({
			"type": _selected,
			"x": _hover.x,
			"y": _hover.y,
			"dir": _ghost_dir,
			"color": _paint,
		}, 0.4)
	for parcel in _shown_parcels():
		_draw_parcel(parcel)
	if _banner_up:
		draw_rect(Rect2(Vector2.ZERO, vp), Color(0, 0, 0, 0.42))


func _draw_wall(x: int, y: int) -> void:
	var rect := _cell_rect(x, y).grow(-2)
	draw_rect(rect, Color("#4a3438"))
	var brick := Color("#2c2024")
	var row := rect.position.y + 7.0
	var band := 0
	while row < rect.end.y - 4.0:
		draw_line(Vector2(rect.position.x + 4.0, row), Vector2(rect.end.x - 4.0, row), brick, 2.0)
		var offset := 8.0 if band % 2 == 0 else rect.size.x * 0.5
		var x0 := rect.position.x + offset
		while x0 < rect.end.x - 4.0:
			draw_line(Vector2(x0, row - 6.0), Vector2(x0, row), brick, 2.0)
			x0 += rect.size.x * 0.5
		row += 8.0
		band += 1


func _draw_source(source: Dictionary) -> void:
	var rect := _cell_rect(int(source["x"]), int(source["y"])).grow(-3)
	_plate(rect, Color("#6a655d"), Color("#e6dccb"))
	_edge_arrow(rect, int(source["dir"]), Color("#1a140e"))
	_centered(rect, "IN", 15, Color("#1a140e"), -_cell * 0.12)
	var recipe: Array = source["parcels"]
	var gap := 12.0
	var total := float(recipe.size() - 1) * gap
	var origin := rect.get_center() + Vector2(-total * 0.5, rect.size.y * 0.22)
	for i in recipe.size():
		var spec: Dictionary = recipe[i]
		draw_circle(origin + Vector2(float(i) * gap, 0), 5.0, _parcel_color(str(spec.get("color", "gray"))))


func _draw_dock() -> void:
	var dock: Dictionary = _puzzle["dock"]
	var rect := _cell_rect(int(dock["x"]), int(dock["y"])).grow(-3)
	_plate(rect, Color("#f0d7a4"), Color("#8a6a3a"))
	var stripe := Color("#e4a45c")
	if not _frames.is_empty():
		var delivered: Array = _frames[_frame_i]["delivered"]
		if not delivered.is_empty():
			stripe = _parcel_color(str(delivered[delivered.size() - 1]["color"]))
	var band := Rect2(rect.position + Vector2(8, rect.size.y * 0.62), Vector2(rect.size.x - 16, 8))
	draw_rect(band, stripe)
	_centered(rect, "DOCK", 15, Color("#2a2116"), -6)


func _draw_block(block: Dictionary, alpha: float) -> void:
	var rect := _cell_rect(int(block["x"]), int(block["y"])).grow(-5)
	var typ := str(block["type"])
	var fill := _tool_color(typ)
	if typ == "painter" or typ == "filter" or typ == "primer":
		fill = _parcel_color(str(block.get("color", _paint)))
	fill.a = alpha
	var border := Color(1, 1, 1, 0.35 * alpha)
	_plate(rect, fill, border)
	var ink := _ink_for(fill)
	ink.a = alpha
	var dir := int(block["dir"])
	if typ == "splitter":
		var phase := _splitter_phase(int(block["x"]), int(block["y"]))
		var primary := dir if phase == 0 else (dir + 1) % 4
		var secondary := (dir + 1) % 4 if phase == 0 else dir
		draw_circle(rect.get_center(), 4.0, ink)
		_edge_arrow(rect, primary, ink, 1.25)
		var dim := ink
		dim.a = alpha * 0.92
		_edge_arrow(rect, secondary, dim, 1.05)
	elif typ == "latch":
		_shifted_arrow(rect, dir, ink, -0.06, 0.22, 0.11)
		_gate(rect, dir, ink)
	elif typ == "counter":
		_edge_arrow(rect, dir, ink)
		var value := _counter_value(int(block["x"]), int(block["y"]))
		var label := str(value) if value > 0 else "#"
		_centered(rect, label, int(_cell * 0.36), ink, -2)
	elif typ == "painter":
		draw_circle(rect.get_center(), _cell * 0.13, Color(1, 1, 1, 0.9 * alpha))
		_edge_arrow(rect, dir, ink)
	elif typ == "filter":
		var miss := (dir + 1) % 4
		_filter_bar(rect, dir, ink)
		_edge_arrow(rect, dir, ink, 1.2)
		var dim := ink
		dim.a = alpha * 0.55
		_edge_arrow(rect, miss, dim, 1.0)
	elif typ == "primer":
		draw_arc(rect.get_center(), _cell * 0.16, 0, TAU, 20, ink, 2.5)
		draw_circle(rect.get_center(), _cell * 0.045, Color(0.851, 0.827, 0.780, alpha))
		_edge_arrow(rect, dir, ink)
	elif typ == "bridge":
		_shifted_arrow(rect, dir, ink, -0.18, 0.16, 0.09)
		_edge_arrow(rect, dir, ink, 1.2)
	elif typ == "turn":
		_turn_mark(rect, ink)
	elif typ == "hook":
		_hook_mark(rect, ink)
	elif typ == "return":
		_return_mark(rect, ink)
	elif typ == "pause":
		_pause_mark(rect, ink)
	elif typ == "chute":
		_chute_mark(rect, dir, ink)
	elif typ == "shunt":
		_shunt_mark(rect, ink)
	elif typ == "bias":
		_bias_mark(rect, ink)
	elif typ == "vault":
		_vault_mark(rect, ink)
	elif typ == "sling":
		_sling_mark(rect, ink)
	elif typ == "cant":
		_cant_mark(rect, ink)
	elif typ == "balk":
		_balk_mark(rect, ink)
	elif typ == "loft":
		_loft_mark(rect, ink)
	elif typ == "keel":
		_keel_mark(rect, ink)
	elif typ == "sheer":
		_sheer_mark(rect, ink)
	elif typ == "strake":
		_strake_mark(rect, ink)
	elif typ == "wale":
		_wale_mark(rect, ink)
	elif typ == "garboard":
		_garboard_mark(rect, ink)
	elif typ == "stealer":
		_stealer_mark(rect, ink)
	elif typ == "rabbet":
		_rabbet_mark(rect, ink)
	elif typ == "futtock":
		_futtock_mark(rect, ink)
	elif typ == "keelson":
		_keelson_mark(rect, ink)
	elif typ == "stemson":
		_stemson_mark(rect, ink)
	elif typ == "apron":
		_apron_mark(rect, ink)
	elif typ == "deadwood":
		_deadwood_mark(rect, ink)
	elif typ == "gripe":
		_gripe_mark(rect, ink)
	elif typ == "forefoot":
		_forefoot_mark(rect, ink)
	elif typ == "knighthead":
		_knighthead_mark(rect, ink)
	elif typ == "hawse":
		_hawse_mark(rect, ink)
	elif typ == "breasthook":
		_breasthook_mark(rect, ink)
	elif typ == "cathead":
		_cathead_mark(rect, ink)
	elif typ == "gammon":
		_gammon_mark(rect, ink)
	elif typ == "bobstay":
		_bobstay_mark(rect, ink)
	elif typ == "bumpkin":
		_bumpkin_mark(rect, ink)
	elif typ == "dolphin":
		_dolphin_mark(rect, ink)
	elif typ == "martingale":
		_martingale_mark(rect, ink)
	elif typ == "jibboom":
		_jibboom_mark(rect, ink)
	elif typ == "whisker":
		_whisker_mark(rect, ink)
	elif typ == "cranse":
		_cranse_mark(rect, ink)
	elif typ == "slide":
		_slide_mark(rect, ink)
	elif typ == "bin":
		_bin_mark(rect, ink, alpha)
	else:
		_arrow(rect, dir, ink, 0.78)


func _draw_parcel(parcel: Dictionary) -> void:
	var alpha := float(parcel["alpha"])
	if alpha <= 0.02:
		return
	var center := _grid_origin + Vector2(float(parcel["x"]) + 0.5, float(parcel["y"]) + 0.5) * _cell
	var side := _cell * 0.42
	var rect := Rect2(center - Vector2(side, side) * 0.5, Vector2(side, side))
	var fill := _parcel_color(str(parcel["color"]))
	fill.a = alpha
	draw_colored_polygon(_chamfer(rect, side * 0.2), fill)
	var tape := Rect2(rect.position.x + 3, center.y - side * 0.08, side - 6, side * 0.16)
	var band := fill.darkened(0.38)
	band.a = alpha
	draw_rect(tape, band)
	if int(parcel["count"]) > 0:
		_centered(rect, str(int(parcel["count"])), int(side * 0.55), _ink_for(fill), side * 0.08)
	var facing := int(parcel.get("dir", 0))
	var vec := _dir_vec(facing)
	var mark := Color(1, 1, 1, 0.9 * alpha)
	_tri(center + vec * side * 0.34, vec, side * 0.16, side * 0.1, mark)


func _shown_parcels() -> Array:
	if _frames.is_empty():
		return []
	var current: Dictionary = _frames[_frame_i]
	var blend := 0.0
	var nxt: Dictionary = {}
	var anim := _playing and _frame_i + 1 < _frames.size()
	if anim:
		nxt = _frames[_frame_i + 1]
		var linear := clampf(_frame_t / FRAME_SEC, 0.0, 1.0)
		blend = linear * linear * (3.0 - 2.0 * linear)
	var out: Array = []
	var next_by_id := {}
	if anim:
		for parcel in nxt["parcels"]:
			next_by_id[int(parcel["id"])] = parcel
	for parcel in current["parcels"]:
		var origin := Vector2(int(parcel["x"]), int(parcel["y"]))
		var dest := origin
		var alpha := 1.0
		var color := str(parcel["color"])
		var count := int(parcel["count"])
		var facing := int(parcel.get("dir", 0))
		if anim:
			var ahead = next_by_id.get(int(parcel["id"]))
			if ahead != null:
				dest = Vector2(int(ahead["x"]), int(ahead["y"]))
				color = str(ahead["color"])
				count = int(ahead["count"])
				facing = int(ahead.get("dir", facing))
			else:
				var cell := Vector2i(int(parcel["x"]), int(parcel["y"]))
				var stood: Dictionary = _placed.get(cell, {})
				alpha = 1.0 - blend
				if str(stood.get("type", "")) != "bin":
					var dock: Dictionary = _puzzle["dock"]
					dest = Vector2(int(dock["x"]), int(dock["y"]))
		var pos := origin.lerp(dest, blend)
		out.append({"x": pos.x, "y": pos.y, "color": color, "count": count, "dir": facing, "alpha": alpha})
	if anim:
		var seen := {}
		for parcel in current["parcels"]:
			seen[int(parcel["id"])] = true
		for parcel in nxt["parcels"]:
			if seen.has(int(parcel["id"])):
				continue
			out.append({
				"x": float(parcel["x"]),
				"y": float(parcel["y"]),
				"color": str(parcel["color"]),
				"count": int(parcel["count"]),
				"dir": int(parcel.get("dir", 0)),
				"alpha": blend,
			})
	return out


func _splitter_phase(x: int, y: int) -> int:
	return int(_marker(x, y, "splitter").get("phase", 0))


func _counter_value(x: int, y: int) -> int:
	return int(_marker(x, y, "counter").get("value", 0))


func _marker(x: int, y: int, kind: String) -> Dictionary:
	if _frames.is_empty():
		return {}
	for marker in _frames[_frame_i].get("markers", []):
		if int(marker["x"]) == x and int(marker["y"]) == y and str(marker["kind"]) == kind:
			return marker
	return {}


func _plate(rect: Rect2, fill: Color, border: Color) -> void:
	var pts := _chamfer(rect, 7.0)
	draw_colored_polygon(pts, fill)
	var loop := pts.duplicate()
	loop.append(pts[0])
	draw_polyline(loop, border, 2.0, true)


func _arrow(rect: Rect2, dir: int, color: Color, scale: float) -> void:
	var vec := _dir_vec(dir)
	var center := rect.get_center()
	var length := rect.size.x * 0.34 * scale
	var width := rect.size.x * 0.16 * scale
	var side := Vector2(-vec.y, vec.x)
	var tip := center + vec * length
	var base := center - vec * length * 0.45
	draw_colored_polygon(PackedVector2Array([tip, base + side * width, base - side * width]), color)


func _edge_arrow(rect: Rect2, dir: int, color: Color, scale: float = 1.0) -> void:
	var vec := _dir_vec(dir)
	var center := rect.get_center() + vec * rect.size.x * 0.3
	_tri(center, vec, rect.size.x * 0.12 * scale, rect.size.x * 0.09 * scale, color)


func _shifted_arrow(rect: Rect2, dir: int, color: Color, shift: float, length: float, width: float) -> void:
	var vec := _dir_vec(dir)
	var center := rect.get_center() + vec * rect.size.x * shift
	_tri(center, vec, rect.size.x * length, rect.size.x * width, color)


func _tri(center: Vector2, vec: Vector2, length: float, width: float, color: Color) -> void:
	var side := Vector2(-vec.y, vec.x)
	var tip := center + vec * length
	var base := center - vec * length * 0.55
	draw_colored_polygon(PackedVector2Array([tip, base + side * width, base - side * width]), color)


func _filter_bar(rect: Rect2, dir: int, color: Color) -> void:
	var vec := _dir_vec(dir)
	var side := Vector2(-vec.y, vec.x)
	var center := rect.get_center()
	draw_line(center - side * rect.size.x * 0.16, center + side * rect.size.x * 0.16, color, 3.0)


func _slide_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var vec := Vector2(1, 0)
	_tri(center - vec * rect.size.x * 0.18, vec, rect.size.x * 0.14, rect.size.x * 0.085, color)
	_tri(center + vec * rect.size.x * 0.16, vec, rect.size.x * 0.14, rect.size.x * 0.085, color)


func _bin_mark(rect: Rect2, color: Color, alpha: float) -> void:
	var hole := rect.grow(-rect.size.x * 0.16)
	draw_colored_polygon(_chamfer(hole, 5.0), Color(0.07, 0.06, 0.05, alpha))
	var left := hole.position.x + hole.size.x * 0.28
	var right := hole.position.x + hole.size.x * 0.72
	var top := hole.position.y + hole.size.y * 0.28
	var bottom := hole.position.y + hole.size.y * 0.72
	draw_line(Vector2(left, top), Vector2(right, bottom), color, 3.0)
	draw_line(Vector2(right, top), Vector2(left, bottom), color, 3.0)


func _hook_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var radius := rect.size.x * 0.2
	var pts := PackedVector2Array()
	var steps := 8
	for i in steps + 1:
		var angle := lerpf(0.0, -PI * 0.5, float(i) / float(steps))
		pts.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_polyline(pts, color, 2.5, true)
	var tip: Vector2 = pts[pts.size() - 1]
	var prev: Vector2 = pts[pts.size() - 2]
	var vec := tip - prev
	if vec.length_squared() < 0.001:
		vec = Vector2(0, -1)
	_tri(tip, vec.normalized(), rect.size.x * 0.11, rect.size.x * 0.07, color)


func _chute_mark(rect: Rect2, dir: int, color: Color) -> void:
	var vec := _dir_vec(dir)
	var side := Vector2(-vec.y, vec.x)
	var center := rect.get_center()
	var mouth := rect.size.x * 0.30
	var neck := rect.size.x * 0.07
	var back := center - vec * rect.size.x * 0.24
	var throat := center + vec * rect.size.x * 0.04
	draw_line(back - side * mouth, back + side * mouth, color, 2.5)
	draw_line(back + side * mouth, throat + side * neck, color, 3.0)
	draw_line(back - side * mouth, throat - side * neck, color, 3.0)
	_tri(center + vec * rect.size.x * 0.20, vec, rect.size.x * 0.16, rect.size.x * 0.10, color)


func _shunt_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	var tail := center + Vector2(-span * 0.30, 0.0)
	var head := center + Vector2(span * 0.18, 0.0)
	draw_line(tail, head, color, 2.5)
	var bend := center + Vector2(-span * 0.02, 0.0)
	var foot := bend + Vector2(0.0, span * 0.30)
	draw_line(bend, foot, color, 2.5)
	_tri(foot, Vector2(0, 1), span * 0.12, span * 0.075, color)


func _bias_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	var tail := center + Vector2(-span * 0.30, 0.0)
	var head := center + Vector2(span * 0.18, 0.0)
	draw_line(tail, head, color, 2.5)
	var bend := center + Vector2(-span * 0.02, 0.0)
	var foot := bend + Vector2(0.0, -span * 0.30)
	draw_line(bend, foot, color, 2.5)
	_tri(foot, Vector2(0, -1), span * 0.12, span * 0.075, color)


func _vault_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	var left := center.x - span * 0.28
	var right := center.x + span * 0.28
	draw_line(Vector2(left, center.y - span * 0.10), Vector2(right, center.y - span * 0.10), color, 2.5)
	draw_line(Vector2(left, center.y + span * 0.10), Vector2(right, center.y + span * 0.10), color, 2.5)


func _sling_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	var tip := center + Vector2(0.0, span * 0.26)
	var left := tip + Vector2(-span * 0.30, -span * 0.42)
	var right := tip + Vector2(span * 0.30, -span * 0.42)
	draw_line(left, tip, color, 2.5)
	draw_line(right, tip, color, 2.5)


func _cant_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	var tip := center + Vector2(0.0, -span * 0.26)
	var left := tip + Vector2(-span * 0.30, span * 0.42)
	var right := tip + Vector2(span * 0.30, span * 0.42)
	draw_line(left, tip, color, 2.5)
	draw_line(right, tip, color, 2.5)


func _balk_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	var tip := center + Vector2(-span * 0.26, 0.0)
	var up := tip + Vector2(span * 0.42, -span * 0.30)
	var down := tip + Vector2(span * 0.42, span * 0.30)
	draw_line(up, tip, color, 2.5)
	draw_line(down, tip, color, 2.5)


func _loft_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 3:
		var tip := center + Vector2(-span * 0.32 + float(i) * span * 0.28, 0.0)
		var back := tip + Vector2(-span * 0.16, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.14), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.14), tip, color, 2.5)


func _keel_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 3:
		var tip := center + Vector2(span * 0.32 - float(i) * span * 0.28, 0.0)
		var back := tip + Vector2(span * 0.16, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.14), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.14), tip, color, 2.5)


func _sheer_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 3:
		var tip := center + Vector2(0.0, -span * 0.32 + float(i) * span * 0.28)
		var back := tip + Vector2(0.0, -span * 0.16)
		draw_line(back + Vector2(-span * 0.14, 0.0), tip, color, 2.5)
		draw_line(back + Vector2(span * 0.14, 0.0), tip, color, 2.5)


func _strake_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 2:
		var tip := center + Vector2(span * 0.20 - float(i) * span * 0.40, 0.0)
		var back := tip + Vector2(span * 0.18, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.16), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.16), tip, color, 2.5)


func _wale_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	var tip := center + Vector2(span * 0.22, 0.0)
	var back := tip + Vector2(-span * 0.28, 0.0)
	draw_line(back + Vector2(0.0, -span * 0.22), tip, color, 2.5)
	draw_line(back + Vector2(0.0, span * 0.22), tip, color, 2.5)


func _garboard_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	var tip := center + Vector2(-span * 0.22, 0.0)
	var back := tip + Vector2(span * 0.28, 0.0)
	draw_line(back + Vector2(0.0, -span * 0.22), tip, color, 2.5)
	draw_line(back + Vector2(0.0, span * 0.22), tip, color, 2.5)


func _stealer_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 3:
		var tip := center + Vector2(span * 0.32 - float(i) * span * 0.28, 0.0)
		var back := tip + Vector2(span * 0.16, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.14), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.14), tip, color, 2.5)


func _cranse_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 22:
		var tip := center + Vector2(-span * 0.50 + float(i) * span * 0.044, 0.0)
		var back := tip + Vector2(-span * 0.016, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.08), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.08), tip, color, 2.5)


func _whisker_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 21:
		var tip := center + Vector2(-span * 0.50 + float(i) * span * 0.046, 0.0)
		var back := tip + Vector2(-span * 0.018, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.08), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.08), tip, color, 2.5)


func _jibboom_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 20:
		var tip := center + Vector2(-span * 0.50 + float(i) * span * 0.048, 0.0)
		var back := tip + Vector2(-span * 0.020, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.08), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.08), tip, color, 2.5)


func _martingale_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 19:
		var tip := center + Vector2(-span * 0.50 + float(i) * span * 0.050, 0.0)
		var back := tip + Vector2(-span * 0.022, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.08), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.08), tip, color, 2.5)


func _dolphin_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 18:
		var tip := center + Vector2(-span * 0.50 + float(i) * span * 0.052, 0.0)
		var back := tip + Vector2(-span * 0.024, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.08), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.08), tip, color, 2.5)


func _bumpkin_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 17:
		var tip := center + Vector2(-span * 0.50 + float(i) * span * 0.056, 0.0)
		var back := tip + Vector2(-span * 0.026, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.08), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.08), tip, color, 2.5)


func _bobstay_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 16:
		var tip := center + Vector2(-span * 0.50 + float(i) * span * 0.060, 0.0)
		var back := tip + Vector2(-span * 0.028, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.08), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.08), tip, color, 2.5)


func _gammon_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 15:
		var tip := center + Vector2(-span * 0.50 + float(i) * span * 0.065, 0.0)
		var back := tip + Vector2(-span * 0.030, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.08), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.08), tip, color, 2.5)


func _cathead_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 14:
		var tip := center + Vector2(-span * 0.50 + float(i) * span * 0.070, 0.0)
		var back := tip + Vector2(-span * 0.032, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.08), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.08), tip, color, 2.5)


func _breasthook_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 13:
		var tip := center + Vector2(-span * 0.50 + float(i) * span * 0.075, 0.0)
		var back := tip + Vector2(-span * 0.036, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.08), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.08), tip, color, 2.5)


func _hawse_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 12:
		var tip := center + Vector2(-span * 0.50 + float(i) * span * 0.082, 0.0)
		var back := tip + Vector2(-span * 0.04, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.08), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.08), tip, color, 2.5)


func _knighthead_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 11:
		var tip := center + Vector2(-span * 0.50 + float(i) * span * 0.09, 0.0)
		var back := tip + Vector2(-span * 0.045, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.08), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.08), tip, color, 2.5)


func _forefoot_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 10:
		var tip := center + Vector2(-span * 0.50 + float(i) * span * 0.10, 0.0)
		var back := tip + Vector2(-span * 0.05, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.08), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.08), tip, color, 2.5)


func _gripe_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 9:
		var tip := center + Vector2(-span * 0.48 + float(i) * span * 0.11, 0.0)
		var back := tip + Vector2(-span * 0.06, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.08), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.08), tip, color, 2.5)


func _deadwood_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 8:
		var tip := center + Vector2(-span * 0.46 + float(i) * span * 0.12, 0.0)
		var back := tip + Vector2(-span * 0.07, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.08), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.08), tip, color, 2.5)


func _apron_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 7:
		var tip := center + Vector2(-span * 0.44 + float(i) * span * 0.13, 0.0)
		var back := tip + Vector2(-span * 0.08, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.08), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.08), tip, color, 2.5)


func _stemson_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 6:
		var tip := center + Vector2(-span * 0.42 + float(i) * span * 0.15, 0.0)
		var back := tip + Vector2(-span * 0.09, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.09), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.09), tip, color, 2.5)


func _keelson_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 5:
		var tip := center + Vector2(-span * 0.40 + float(i) * span * 0.18, 0.0)
		var back := tip + Vector2(-span * 0.10, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.10), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.10), tip, color, 2.5)


func _futtock_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	for i in 4:
		var tip := center + Vector2(-span * 0.36 + float(i) * span * 0.22, 0.0)
		var back := tip + Vector2(-span * 0.12, 0.0)
		draw_line(back + Vector2(0.0, -span * 0.11), tip, color, 2.5)
		draw_line(back + Vector2(0.0, span * 0.11), tip, color, 2.5)


func _rabbet_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var span := rect.size.x
	var tip := center + Vector2(-span * 0.30, 0.0)
	var tail := center + Vector2(span * 0.28, 0.0)
	draw_line(tail, tip, color, 2.5)
	draw_line(tip + Vector2(span * 0.22, -span * 0.16), tip, color, 2.5)
	draw_line(tip + Vector2(span * 0.22, span * 0.16), tip, color, 2.5)


func _pause_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var bar_w := maxf(rect.size.x * 0.12, 3.0)
	var bar_h := rect.size.y * 0.46
	var gap := rect.size.x * 0.08
	var top := center.y - bar_h * 0.5
	draw_rect(Rect2(center.x - gap - bar_w, top, bar_w, bar_h), color)
	draw_rect(Rect2(center.x + gap, top, bar_w, bar_h), color)


func _return_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var radius := rect.size.x * 0.22
	var pts := PackedVector2Array()
	var steps := 10
	for i in steps + 1:
		var angle := lerpf(0.0, PI, float(i) / float(steps))
		pts.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_polyline(pts, color, 2.5, true)
	var tip: Vector2 = pts[pts.size() - 1]
	var prev: Vector2 = pts[pts.size() - 2]
	var vec := tip - prev
	if vec.length_squared() < 0.001:
		vec = Vector2(-1, 0)
	_tri(tip, vec.normalized(), rect.size.x * 0.11, rect.size.x * 0.07, color)


func _turn_mark(rect: Rect2, color: Color) -> void:
	var center := rect.get_center()
	var radius := rect.size.x * 0.2
	var pts := PackedVector2Array()
	var steps := 8
	for i in steps + 1:
		var angle := lerpf(0.0, PI * 0.5, float(i) / float(steps))
		pts.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_polyline(pts, color, 2.5, true)
	var tip: Vector2 = pts[pts.size() - 1]
	var prev: Vector2 = pts[pts.size() - 2]
	var vec := tip - prev
	if vec.length_squared() < 0.001:
		vec = Vector2(0, 1)
	_tri(tip, vec.normalized(), rect.size.x * 0.11, rect.size.x * 0.07, color)


func _gate(rect: Rect2, dir: int, color: Color) -> void:
	var vec := _dir_vec(dir)
	var side := Vector2(-vec.y, vec.x)
	var center := rect.get_center() + vec * rect.size.x * 0.22
	draw_line(center - side * rect.size.x * 0.28, center + side * rect.size.x * 0.28, color, 3.0)


func _centered(rect: Rect2, text: String, size: int, color: Color, y_bias: float) -> void:
	if _font == null:
		return
	var height := _font.get_height(size)
	var baseline := rect.position.y + (rect.size.y + height * 0.72) * 0.5 + y_bias
	draw_string(_font, Vector2(rect.position.x, baseline), text, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x, size, color)


func _chamfer(rect: Rect2, cut: float) -> PackedVector2Array:
	var limit := minf(rect.size.x, rect.size.y) * 0.3
	cut = minf(cut, limit)
	var x := rect.position.x
	var y := rect.position.y
	var w := rect.size.x
	var h := rect.size.y
	return PackedVector2Array([
		Vector2(x + cut, y), Vector2(x + w - cut, y),
		Vector2(x + w, y + cut), Vector2(x + w, y + h - cut),
		Vector2(x + w - cut, y + h), Vector2(x + cut, y + h),
		Vector2(x, y + h - cut), Vector2(x, y + cut),
	])


func _dir_vec(dir: int) -> Vector2:
	var step: Vector2i = Sim.DIRS[dir]
	return Vector2(step.x, step.y)


func _tool_color(tool: String) -> Color:
	match tool:
		"conveyor":
			return AMBER
		"latch":
			return Color("#79b0d6")
		"splitter":
			return Color("#c98ad4")
		"counter":
			return Color("#8fc47c")
		"painter":
			return _parcel_color(_paint)
		"filter":
			return Color("#3aa89a")
		"primer":
			return Color("#c9844a")
		"bridge":
			return Color("#4f7d6a")
		"turn":
			return Color("#6e8bb8")
		"hook":
			return Color("#6d4c9a")
		"return":
			return Color("#9a3d55")
		"pause":
			return Color("#3f6f8a")
		"chute":
			return Color("#d4762c")
		"shunt":
			return Color("#2f8f78")
		"bias":
			return Color("#9a7424")
		"vault":
			return Color("#7c5cbf")
		"sling":
			return Color("#6b8f3a")
		"cant":
			return Color("#8a4e6a")
		"balk":
			return Color("#5a6e8a")
		"loft":
			return Color("#c45c3e")
		"keel":
			return Color("#2a7f8c")
		"sheer":
			return Color("#3d5bd4")
		"strake":
			return Color("#7a4e8a")
		"wale":
			return Color("#c47a3a")
		"garboard":
			return Color("#3e8f6a")
		"stealer":
			return Color("#2f6f8f")
		"rabbet":
			return Color("#8f4e6a")
		"futtock":
			return Color("#6a8f3e")
		"keelson":
			return Color("#4a8f9a")
		"stemson":
			return Color("#9a4a6a")
		"apron":
			return Color("#7a4a9a")
		"deadwood":
			return Color("#3e7a6a")
		"gripe":
			return Color("#8a3e6a")
		"forefoot":
			return Color("#3e6a8a")
		"knighthead":
			return Color("#6a8a3e")
		"hawse":
			return Color("#9a6a3e")
		"breasthook":
			return Color("#8a5a3e")
		"cathead":
			return Color("#9a3e7a")
		"gammon":
			return Color("#5a3e8a")
		"bobstay":
			return Color("#4a3a8a")
		"bumpkin":
			return Color("#8a3a4a")
		"dolphin":
			return Color("#3a6a5a")
		"martingale":
			return Color("#6a3a4a")
		"jibboom":
			return Color("#4a6a3a")
		"whisker":
			return Color("#3a4a6a")
		"cranse":
			return Color("#8a4a6a")
		"slide":
			return Color("#d06b86")
		"bin":
			return Color("#4d463f")
		_:
			return Color("#888888")


func _parcel_color(name: String) -> Color:
	match name:
		"red":
			return Color("#e15d4c")
		"blue":
			return Color("#4f82e8")
		"yellow":
			return Color("#e6c34e")
		_:
			return Color("#d9d3c7")


func _ink_for(fill: Color) -> Color:
	if fill.get_luminance() > 0.62:
		return Color("#1a140e")
	return Color("#f6f1e6")


func _tool_tip(tool: String) -> String:
	match tool:
		"conveyor":
			return "Moves a parcel one step along its arrow each tick."
		"latch":
			return "Waits one tick, then moves only into a cell that is already empty."
		"splitter":
			return "First parcel follows the arrow. The next goes clockwise."
		"painter":
			return "Sets a parcel's color, then moves it forward."
		"counter":
			return "Stamps 1, then 2, then 3 on each parcel that passes."
		"filter":
			return "Sends its color along the arrow. Any other color turns clockwise."
		"primer":
			return "Paints a gray parcel, then moves it forward. A color already on the parcel stays."
		"bridge":
			return "Sets a parcel down two steps along its arrow, over the cell in front."
		"turn":
			return "Rotates a parcel one quarter clockwise and waits that tick. It leaves in the new facing on the next tick."
		"hook":
			return "Rotates a parcel one quarter counterclockwise and waits that tick. It leaves in the new facing on the next tick."
		"return":
			return "Reverses a parcel's facing and waits that tick. It steps back along that facing on the next tick."
		"pause":
			return "Waits one tick without turning the parcel. It then steps one cell in the facing the parcel already had."
		"chute":
			return "Writes its own facing onto a parcel and waits that tick. The parcel then steps one cell that way."
		"shunt":
			return "Waits one tick, then steps a parcel one cell to its right. The parcel keeps the facing it arrived with."
		"bias":
			return "Waits one tick, then steps a parcel one cell to its left. The parcel keeps the facing it arrived with."
		"vault":
			return "Waits one tick, then jumps a parcel two cells in the facing it already had. The cell in front is not entered, and the parcel keeps that facing."
		"sling":
			return "Waits one tick, then jumps a parcel two cells to its right. The cell beside it is not entered, and the parcel keeps the facing it arrived with."
		"cant":
			return "Waits one tick, then jumps a parcel two cells to its left. The cell beside it is not entered, and the parcel keeps the facing it arrived with."
		"balk":
			return "Waits one tick, then jumps a parcel two cells backward. The cell behind it is not entered, and the parcel keeps the facing it arrived with."
		"loft":
			return "Waits one tick, then jumps a parcel three cells forward. The two cells in front are not entered, and the parcel keeps the facing it arrived with."
		"keel":
			return "Waits one tick, then jumps a parcel three cells backward. The two cells behind it are not entered, and the parcel keeps the facing it arrived with."
		"sheer":
			return "Waits one tick, then jumps a parcel three cells to its right. The two cells beside it are not entered, and the parcel keeps the facing it arrived with."
		"strake":
			return "Waits one tick, then jumps a parcel two cells to its left. The cell beside it is not entered, and the parcel keeps the facing it arrived with."
		"wale":
			return "Waits one tick, then jumps a parcel one cell to its right. The parcel keeps the facing it arrived with."
		"garboard":
			return "Waits one tick, then jumps a parcel one cell to its left. The parcel keeps the facing it arrived with."
		"stealer":
			return "Waits one tick, then jumps a parcel three cells to its left. The two cells beside it are not entered, and the parcel keeps the facing it arrived with."
		"rabbet":
			return "Waits one tick, then jumps a parcel one cell backward. The parcel keeps the facing it arrived with."
		"futtock":
			return "Waits one tick, then jumps a parcel four cells forward. The three cells in front are not entered, and the parcel keeps the facing it arrived with."
		"keelson":
			return "Waits one tick, then jumps a parcel five cells forward. The four cells in front are not entered, and the parcel keeps the facing it arrived with."
		"stemson":
			return "Waits one tick, then jumps a parcel six cells forward. The five cells in front are not entered, and the parcel keeps the facing it arrived with."
		"apron":
			return "Waits one tick, then jumps a parcel seven cells forward. The six cells in front are not entered, and the parcel keeps the facing it arrived with."
		"deadwood":
			return "Waits one tick, then jumps a parcel eight cells forward. The seven cells in front are not entered, and the parcel keeps the facing it arrived with."
		"gripe":
			return "Waits one tick, then jumps a parcel nine cells forward. The eight cells in front are not entered, and the parcel keeps the facing it arrived with."
		"forefoot":
			return "Waits one tick, then jumps a parcel ten cells forward. The nine cells in front are not entered, and the parcel keeps the facing it arrived with."
		"knighthead":
			return "Waits one tick, then jumps a parcel eleven cells forward. The ten cells in front are not entered, and the parcel keeps the facing it arrived with."
		"hawse":
			return "Waits one tick, then jumps a parcel twelve cells forward. The eleven cells in front are not entered, and the parcel keeps the facing it arrived with."
		"breasthook":
			return "Waits one tick, then jumps a parcel thirteen cells forward. The twelve cells in front are not entered, and the parcel keeps the facing it arrived with."
		"cathead":
			return "Waits one tick, then jumps a parcel fourteen cells forward. The thirteen cells in front are not entered, and the parcel keeps the facing it arrived with."
		"gammon":
			return "Waits one tick, then jumps a parcel fifteen cells forward. The fourteen cells in front are not entered, and the parcel keeps the facing it arrived with."
		"bobstay":
			return "Waits one tick, then jumps a parcel sixteen cells forward. The fifteen cells in front are not entered, and the parcel keeps the facing it arrived with."
		"bumpkin":
			return "Waits one tick, then jumps a parcel seventeen cells forward. The sixteen cells in front are not entered, and the parcel keeps the facing it arrived with."
		"dolphin":
			return "Waits one tick, then jumps a parcel eighteen cells forward. The seventeen cells in front are not entered, and the parcel keeps the facing it arrived with."
		"martingale":
			return "Waits one tick, then jumps a parcel nineteen cells forward. The eighteen cells in front are not entered, and the parcel keeps the facing it arrived with."
		"jibboom":
			return "Waits one tick, then jumps a parcel twenty cells forward. The nineteen cells in front are not entered, and the parcel keeps the facing it arrived with."
		"whisker":
			return "Waits one tick, then jumps a parcel twenty-one cells forward. The twenty cells in front are not entered, and the parcel keeps the facing it arrived with."
		"cranse":
			return "Waits one tick, then jumps a parcel twenty-two cells forward. The twenty-one cells in front are not entered, and the parcel keeps the facing it arrived with."
		"slide":
			return "Moves a parcel two cells in its facing and does not rotate it. The cell between can be a brick, a belt, or another parcel."
		"bin":
			return "Removes a parcel that stands on it. A parcel that only hops over it is left alone."
		_:
			return ""


func _box(fill: Color, border: Color, radius: int, pad: int = 8) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(radius)
	style.content_margin_left = pad
	style.content_margin_right = pad
	style.content_margin_top = 4 if pad >= 8 else 1
	style.content_margin_bottom = 4 if pad >= 8 else 1
	return style
