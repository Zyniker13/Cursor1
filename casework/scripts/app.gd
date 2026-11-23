extends Control

const Catalog = preload("res://scripts/catalog.gd")
const Verdict = preload("res://scripts/verdict.gd")

const DESK := Color("#231e1a")
const INK := Color("#241c16")
const CREAM := Color("#f6f0e4")
const CREAM_WARM := Color("#f3ead7")
const SEAL := Color("#8f2d2d")
const FELT := Color("#1c3a32")
const FELT_EDGE := Color("#3e6b5c")
const FELT_INK := Color("#f3ead7")
const MUTED := Color("#cbbfa8")
const GOOD := Color("#1d4a36")
const BAD := Color("#6e2430")
const AMBER := Color("#6a4a1c")

var _serif: Font
var _sans: Font
var _book
var _screens := {}
var _pins := {"who": "", "place": "", "hour": ""}
var _pin_buttons := {}
var _slot_titles := {}
var _theory_line: Label
var _verdict: Label
var _verdict_panel: PanelContainer


func _ready() -> void:
	# The headless suite can enter the tree before the window is ready and call this by hand.
	if not _screens.is_empty():
		return
	_serif = _font(["Liberation Serif", "DejaVu Serif"])
	_sans = _font(["Inter", "Liberation Sans", "DejaVu Sans"])
	set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	theme = _base_theme()
	var desk := DeskBackdrop.new()
	desk.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	desk.mouse_filter = MOUSE_FILTER_IGNORE
	add_child(desk)
	_screens["menu"] = _build_menu()
	_screens["howto"] = _build_howto()
	for screen in _screens.values():
		add_child(screen)
	_show("menu")


func _font(names: Array) -> Font:
	var font := SystemFont.new()
	font.font_names = PackedStringArray(names)
	font.antialiasing = TextServer.FONT_ANTIALIASING_GRAY
	font.hinting = TextServer.HINTING_LIGHT
	return font


func _base_theme() -> Theme:
	var skin := Theme.new()
	skin.default_font = _sans
	skin.default_font_size = 16
	var normal := _box(CREAM, Color("#d9cbb6"), 3, 1)
	var hover := _box(Color("#fffaf1"), SEAL, 3, 1)
	var pressed := _box(SEAL, SEAL, 3, 1)
	var focus := _box(CREAM, SEAL, 3, 2)
	skin.set_stylebox("normal", "Button", normal)
	skin.set_stylebox("hover", "Button", hover)
	skin.set_stylebox("pressed", "Button", pressed)
	skin.set_stylebox("focus", "Button", focus)
	skin.set_stylebox("disabled", "Button", _box(Color("#d9d0c2"), Color("#d9d0c2"), 3, 1))
	skin.set_color("font_color", "Button", INK)
	skin.set_color("font_hover_color", "Button", INK)
	skin.set_color("font_pressed_color", "Button", CREAM)
	skin.set_color("font_focus_color", "Button", INK)
	skin.set_color("font_color", "Label", INK)
	var grabber := _box(Color("#cbbfa8"), Color("#cbbfa8"), 4, 0)
	var trough := _box(Color("#00000028"), Color("#00000000"), 4, 0)
	skin.set_stylebox("grabber", "VScrollBar", grabber)
	skin.set_stylebox("grabber_highlight", "VScrollBar", _box(Color("#f6f0e4"), Color("#f6f0e4"), 4, 0))
	skin.set_stylebox("grabber_pressed", "VScrollBar", _box(CREAM, CREAM, 4, 0))
	skin.set_stylebox("scroll", "VScrollBar", trough)
	return skin


func _box(bg: Color, border: Color, radius: int, border_width: int) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(border_width)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 14
	box.content_margin_right = 14
	box.content_margin_top = 8
	box.content_margin_bottom = 8
	return box


func _show(screen_name: String) -> void:
	for key in _screens:
		_screens[key].visible = key == screen_name


func _build_menu() -> Control:
	var layer := _full_layer()
	var scroll := ScrollContainer.new()
	scroll.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layer.add_child(scroll)
	var margin := MarginContainer.new()
	margin.size_flags_horizontal = SIZE_EXPAND_FILL
	margin.size_flags_vertical = SIZE_EXPAND_FILL
	for side in ["left", "top", "right"]:
		margin.add_theme_constant_override("margin_%s" % side, 24)
	margin.add_theme_constant_override("margin_bottom", 14)
	scroll.add_child(margin)
	var center := CenterContainer.new()
	center.size_flags_horizontal = SIZE_EXPAND_FILL
	center.size_flags_vertical = SIZE_EXPAND_FILL
	margin.add_child(center)
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(560, 0)
	card.add_theme_stylebox_override("panel", _paper_style(Color("#f7f1e4")))
	center.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	card.add_child(box)
	box.add_child(_label("FILES", 13, SEAL, _sans))
	box.add_child(_label("Casework", 64, INK, _serif))
	box.add_child(_rule(INK))
	box.add_child(_wrapped("Seventy-two files in all. Open one, then pin who, the room, and the hour together.", 20, INK, _serif, 480))
	for book in Catalog.all():
		_add_case_offer(box, book)
	var how_to := _action("How to play", false)
	how_to.pressed.connect(func() -> void: _show("howto"))
	box.add_child(how_to)
	return layer


func _add_case_offer(box: VBoxContainer, book) -> void:
	var offer := VBoxContainer.new()
	offer.add_theme_constant_override("separation", 8)
	box.add_child(offer)
	offer.add_child(_label("%s   %s" % [book.FILE_CODE, book.TITLE], 28, INK, _serif))
	offer.add_child(_wrapped(str(book.BLURB), 18, INK, _serif, 480))
	var open_case := _action("Open %s" % book.TITLE, true)
	var chosen = book
	open_case.pressed.connect(func() -> void: _open_case(chosen))
	offer.add_child(open_case)


func _open_case(book) -> void:
	if _book == book and _screens.has("case"):
		_show("case")
		return
	_book = book
	_pins = {"who": "", "place": "", "hour": ""}
	_pin_buttons = {}
	_slot_titles = {}
	_theory_line = null
	_verdict = null
	_verdict_panel = null
	if _screens.has("case"):
		var old: Node = _screens["case"]
		_screens.erase("case")
		remove_child(old)
		old.queue_free()
	var screen := _build_case()
	_screens["case"] = screen
	add_child(screen)
	_show("case")


func _build_howto() -> Control:
	var layer := _full_layer()
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	layer.add_child(center)
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(680, 0)
	card.add_theme_stylebox_override("panel", _paper_style(Color("#f7f1e4")))
	center.add_child(card)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	card.add_child(box)
	box.add_child(_label("How to play", 36, INK, _serif))
	box.add_child(_rule(INK))
	var copy := (
		"Casework keeps one true timeline for the file you open. You do not see it written out until a theory fits every exhibit in that file.\n\n"
		+ "Open The spare key, The rehearsal score, The gilt stamp, The ferry bell, The weather slate, The loom shuttle, The hive smoker, The glass pontil, The press proof, The assay cup, The kiln chalk, The tide ledger, The night bell, The salt mark, The wick trim, The glass anneal, The orchard graft, The dye vat, The tar kettle, The cork press, The net loft, The cask hoop, The linen fold, The dovetail, The mortise, The rebate, The housing, The tenon, The bridle, The dado, The spline, The mitre, The lap, The scarf, The finger, The haunch, The dowel, The tongue, The quirk, The chamfer, The scotia, The cyma, The cavetto, The reed, The annulet, The hood, The listel, The abacus, The girdle, The reglet, The gutta, The mutule, The modillion, The taenia, The apophyge, The trochilus, The talon, The bellcast, The metope, The triglyph, The regula, The bowtell, The cable, The chevron, The volute, The helix, The guilloche, The fret, The meander, The interlace, The diaper, or The knotwork. Each file asks three things: who, the room, and the hour. Other lines in the file are evidence. They are not extra pins.\n\n"
		+ "Read every exhibit. Pin one person, one room, and one hour, then submit the theory.\n\n"
		+ "The theory is accepted only when it fits every exhibit. If it does not, the reply names the exhibits and the claim they conflict with. If a slot is empty, the board names that slot. An empty slot is not called a wrong theory."
	)
	box.add_child(_wrapped(copy, 18, INK, _serif, 620))
	var back := _action("Back to the menu", false)
	back.pressed.connect(func() -> void: _show("menu"))
	box.add_child(back)
	return layer


func _build_case() -> Control:
	var layer := _full_layer()
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	for side in ["left", "top", "right", "bottom"]:
		margin.add_theme_constant_override("margin_%s" % side, 22)
	layer.add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	column.size_flags_horizontal = SIZE_EXPAND_FILL
	column.size_flags_vertical = SIZE_EXPAND_FILL
	margin.add_child(column)
	column.add_child(_case_header())
	var split := HSplitContainer.new()
	split.size_flags_vertical = SIZE_EXPAND_FILL
	split.size_flags_horizontal = SIZE_EXPAND_FILL
	split.split_offset = 720
	column.add_child(split)
	split.add_child(_exhibit_column())
	split.add_child(_board())
	_refresh_pins()
	_show_ready()
	return layer


func _case_header() -> Control:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 16)
	var back := _action("Menu", false)
	back.custom_minimum_size = Vector2(96, 40)
	back.pressed.connect(func() -> void: _show("menu"))
	row.add_child(back)
	var titles := VBoxContainer.new()
	titles.size_flags_horizontal = SIZE_EXPAND_FILL
	titles.add_child(_label("CASEWORK  ·  FILE %s" % _book.FILE_CODE, 13, MUTED, _sans))
	titles.add_child(_label(str(_book.TITLE), 32, CREAM, _serif))
	row.add_child(titles)
	return row


func _exhibit_column() -> Control:
	var column := VBoxContainer.new()
	column.size_flags_horizontal = SIZE_EXPAND_FILL
	column.size_flags_vertical = SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 8)
	column.custom_minimum_size = Vector2(420, 0)
	column.add_child(_label(_book.exhibit_heading(), 16, MUTED, _sans))
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(scroll)
	var papers := VBoxContainer.new()
	papers.add_theme_constant_override("separation", 14)
	papers.size_flags_horizontal = SIZE_EXPAND_FILL
	papers.size_flags_vertical = SIZE_SHRINK_BEGIN
	scroll.add_child(papers)
	var shades: Array[Color] = [
		Color("#f7f1e4"),
		Color("#f4efe2"),
		Color("#f8f3e8"),
		Color("#f3ecdf"),
		Color("#f6f0e6"),
		Color("#f5efe3"),
		Color("#f7f2e6"),
	]
	for index in _book.EXHIBITS.size():
		papers.add_child(_paper(_book.EXHIBITS[index], shades[index % shades.size()]))
	return column


func _paper(exhibit: Dictionary, shade: Color) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = SIZE_EXPAND_FILL
	var style := _paper_style(shade)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 14
	style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", style)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	panel.add_child(box)
	var heading := HBoxContainer.new()
	heading.add_theme_constant_override("separation", 10)
	var badge := PanelContainer.new()
	var badge_style := _box(SEAL, SEAL, 2, 0)
	badge_style.content_margin_left = 8
	badge_style.content_margin_right = 8
	badge_style.content_margin_top = 2
	badge_style.content_margin_bottom = 2
	badge.add_theme_stylebox_override("panel", badge_style)
	badge.add_child(_label(str(exhibit["id"]), 14, CREAM, _sans))
	heading.add_child(badge)
	var source := _label(str(exhibit["source"]), 14, SEAL, _sans)
	source.size_flags_horizontal = SIZE_EXPAND_FILL
	source.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	heading.add_child(source)
	box.add_child(heading)
	box.add_child(_label(str(exhibit["title"]), 22, INK, _serif))
	box.add_child(_rule(Color("#cbbfa8")))
	var body := _label(str(exhibit["text"]), 18, INK, _serif)
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.size_flags_horizontal = SIZE_EXPAND_FILL
	box.add_child(body)
	return panel


func _board() -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(420, 0)
	panel.size_flags_horizontal = SIZE_EXPAND_FILL
	panel.size_flags_vertical = SIZE_EXPAND_FILL
	var felt := _box(FELT, FELT_EDGE, 8, 2)
	felt.content_margin_left = 8
	felt.content_margin_right = 8
	felt.content_margin_top = 8
	felt.content_margin_bottom = 8
	felt.shadow_color = Color(0, 0, 0, 0.35)
	felt.shadow_size = 10
	felt.shadow_offset = Vector2(0, 4)
	panel.add_theme_stylebox_override("panel", felt)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	panel.add_child(scroll)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.size_flags_horizontal = SIZE_EXPAND_FILL
	box.size_flags_vertical = SIZE_SHRINK_BEGIN
	scroll.add_child(box)
	box.add_child(_label("The board", 13, MUTED, _sans))
	box.add_child(_label(_book.board_question(), 20, FELT_INK, _serif))
	var brief := _label(_book.board_brief(), 14, MUTED, _sans)
	brief.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(brief)
	box.add_child(_label(_book.cast_line(), 14, MUTED, _sans))
	_theory_line = _label("", 16, CREAM, _sans)
	box.add_child(_theory_line)
	_add_choices(box, "who", "Who took it", _book.choices("who"))
	_add_choices(box, "place", "Where they took it", _book.choices("place"))
	_add_choices(box, "hour", "At which hour", _book.choices("hour"))
	_verdict_panel = PanelContainer.new()
	_verdict_panel.size_flags_horizontal = SIZE_EXPAND_FILL
	box.add_child(_verdict_panel)
	_verdict = _label("", 16, CREAM, _serif)
	_verdict.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_verdict.size_flags_horizontal = SIZE_EXPAND_FILL
	_verdict_panel.add_child(_verdict)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 8)
	var submit := _action("Submit theory", true)
	submit.pressed.connect(_on_submit)
	actions.add_child(submit)
	var clear := _action("Clear", false)
	clear.pressed.connect(_on_clear)
	actions.add_child(clear)
	box.add_child(actions)
	return panel


func _add_choices(parent: VBoxContainer, slot: String, title: String, choices: Array) -> void:
	var title_label := _label(title, 16, FELT_INK, _sans)
	parent.add_child(title_label)
	_slot_titles[slot] = title_label
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	parent.add_child(row)
	_pin_buttons[slot] = {}
	for choice in choices:
		var value := str(choice["value"])
		var button := Button.new()
		button.text = str(choice["label"])
		button.focus_mode = FOCUS_ALL
		button.mouse_default_cursor_shape = CURSOR_POINTING_HAND
		button.size_flags_horizontal = SIZE_EXPAND_FILL
		button.custom_minimum_size = Vector2(0, 42)
		var slot_name := slot
		var pin_value := value
		button.pressed.connect(func() -> void:
			_on_pin(slot_name, pin_value)
		)
		row.add_child(button)
		_pin_buttons[slot][value] = button


func _on_pin(slot: String, value: String) -> void:
	if str(_pins[slot]) == value:
		_pins[slot] = ""
	else:
		_pins[slot] = value
	_refresh_pins()
	_show_ready()


func _on_clear() -> void:
	_pins = {"who": "", "place": "", "hour": ""}
	_refresh_pins()
	_show_ready()


func _on_submit() -> void:
	var result: Dictionary = Verdict.submit({
		"who": _pins["who"],
		"place": _pins["place"],
		"hour": _pins["hour"],
	}, _book)
	_show_verdict(str(result["status"]), str(result["message"]))


func _refresh_pins() -> void:
	for slot in _pin_buttons:
		for value in _pin_buttons[slot]:
			var selected: bool = str(_pins[slot]) == str(value)
			var button: Button = _pin_buttons[slot][value]
			if selected:
				_paint(button, SEAL, CREAM, SEAL)
			else:
				_paint(button, CREAM, INK, Color("#d9cbb6"))
		var title: Label = _slot_titles[slot]
		var missing: bool = str(_pins[slot]) == "" and _verdict != null and _verdict.text.begins_with("The board is incomplete")
		title.add_theme_color_override("font_color", Color("#e2b15a") if missing else FELT_INK)
	if _theory_line != null:
		_theory_line.text = "Pinned:  %s   ·   %s   ·   %s" % [
			_pin_text("who"),
			_pin_text("place"),
			_pin_text("hour"),
		]


func _pin_text(slot: String) -> String:
	var value := str(_pins[slot])
	if value == "":
		return "—"
	return _book.choice_label(slot, value)


func _show_ready() -> void:
	_show_verdict("ready", _book.ready_line())


func _show_verdict(status: String, message: String) -> void:
	_verdict.text = message
	var bg := Color("#16332c")
	match status:
		"accepted":
			bg = GOOD
		"rejected":
			bg = BAD
		"incomplete":
			bg = AMBER
		_:
			bg = Color("#16332c")
	var style := _box(bg, bg.lightened(0.12), 4, 1)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 10
	style.content_margin_bottom = 10
	_verdict_panel.add_theme_stylebox_override("panel", style)
	_refresh_pins()


func _paper_style(shade: Color) -> StyleBoxFlat:
	var style := _box(shade, Color("#ddcfc0"), 2, 1)
	style.shadow_color = Color(0, 0, 0, 0.28)
	style.shadow_size = 7
	style.shadow_offset = Vector2(0, 3)
	return style


func _label(text: String, size: int, color: Color, font: Font) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_override("font", font)
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _wrapped(text: String, size: int, color: Color, font: Font, width: float) -> Label:
	var label := _label(text, size, color, font)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.custom_minimum_size = Vector2(width, 0)
	return label


func _rule(color: Color) -> ColorRect:
	var rule := ColorRect.new()
	rule.color = color
	rule.custom_minimum_size = Vector2(0, 1)
	return rule


func _action(text: String, primary: bool) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = FOCUS_ALL
	button.mouse_default_cursor_shape = CURSOR_POINTING_HAND
	button.custom_minimum_size = Vector2(0, 42)
	if primary:
		_paint(button, SEAL, CREAM, SEAL)
	else:
		_paint(button, CREAM, INK, Color("#d9cbb6"))
	return button


func _paint(button: Button, bg: Color, fg: Color, border: Color) -> void:
	button.add_theme_stylebox_override("normal", _box(bg, border, 3, 1))
	button.add_theme_stylebox_override("hover", _box(bg.lightened(0.08), border, 3, 1))
	button.add_theme_stylebox_override("pressed", _box(bg.darkened(0.08), border, 3, 1))
	button.add_theme_stylebox_override("focus", _box(bg, Color("#e2b15a"), 3, 2))
	button.add_theme_color_override("font_color", fg)
	button.add_theme_color_override("font_hover_color", fg)
	button.add_theme_color_override("font_pressed_color", fg)
	button.add_theme_color_override("font_focus_color", fg)
	button.add_theme_font_override("font", _sans)


func _full_layer() -> Control:
	var layer := Control.new()
	layer.set_anchors_and_offsets_preset(PRESET_FULL_RECT)
	layer.mouse_filter = MOUSE_FILTER_IGNORE
	return layer


class DeskBackdrop extends Control:
	func _ready() -> void:
		resized.connect(queue_redraw)

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#231e1a"))
		var grain := Color(1, 1, 1, 0.015)
		var y := 0.0
		while y < size.y:
			draw_line(Vector2(0, y), Vector2(size.x, y), grain, 1.0)
			y += 5.0
