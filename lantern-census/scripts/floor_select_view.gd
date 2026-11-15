extends Control

const Rules := preload("res://scripts/census_rules.gd")

signal descend_requested(floor_id: String)
signal back_pressed

const NIGHT := Color(0.06, 0.07, 0.11)
const AMBER := Color(0.93, 0.67, 0.28)
const PARCHMENT := Color(0.93, 0.86, 0.70)
const INK := Color(0.16, 0.11, 0.08)
const PANEL := Color(0.15, 0.12, 0.11, 0.94)
const CELLAR_AWNING := Color(0.50, 0.18, 0.16)
const CISTERN_AWNING := Color(0.12, 0.36, 0.40)
const CLOISTER_AWNING := Color(0.42, 0.30, 0.14)

var notice_label: Label
var purse_label: Label
var receipt_label: Label
var back_button: Button
var _status: Dictionary = {}
var _record: Dictionary = {}
var _descend: Dictionary = {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()


func _build() -> void:
	var title := _label("Floor select", 42, AMBER)
	title.position = Vector2(48, 16)
	title.size = Vector2(800, 52)
	add_child(title)

	notice_label = _label("", 20, PARCHMENT)
	notice_label.position = Vector2(48, 72)
	notice_label.size = Vector2(1184, 64)
	notice_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(notice_label)

	var hint := _label("The small flask can reach every lift. A finished census needs the large flask.", 16, Color(0.86, 0.78, 0.62))
	hint.position = Vector2(48, 140)
	hint.size = Vector2(1184, 24)
	add_child(hint)

	var floors: Array = Rules.floors()
	var margin := 24.0
	var gap := 16.0
	var card_w := (1280.0 - margin * 2.0 - gap * float(floors.size() - 1)) / float(floors.size())
	var x := margin
	for floor in floors:
		var card := _panel(Vector2(x, 176), Vector2(card_w, 320), _awning_for(str(floor.id)), floor.title)
		add_child(card)
		var record := _label(floor.record, 18, PARCHMENT)
		record.position = Vector2(20, 64)
		record.size = Vector2(card_w - 40.0, 120)
		record.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		card.add_child(record)
		_record[floor.id] = record
		var status := _label("Census open", 20, PARCHMENT)
		status.position = Vector2(20, 188)
		status.size = Vector2(card_w - 40.0, 32)
		card.add_child(status)
		_status[floor.id] = status
		var button := _button("Descend")
		button.position = Vector2(20, 232)
		button.size = Vector2(card_w - 40.0, 64)
		_bind_descend(button, floor.id)
		card.add_child(button)
		_descend[floor.id] = button
		x += card_w + gap

	var paper := ColorRect.new()
	paper.color = PARCHMENT
	paper.position = Vector2(40, 512)
	paper.size = Vector2(860, 128)
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(paper)
	receipt_label = _label("", 20, INK)
	receipt_label.position = Vector2(16, 10)
	receipt_label.size = Vector2(828, 108)
	receipt_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	var mono := SystemFont.new()
	mono.font_names = PackedStringArray(["DejaVu Sans Mono", "Liberation Mono", "Courier New", "monospace"])
	receipt_label.add_theme_font_override("font", mono)
	paper.add_child(receipt_label)

	purse_label = _label("", 18, PARCHMENT)
	purse_label.position = Vector2(920, 512)
	purse_label.size = Vector2(320, 56)
	purse_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	add_child(purse_label)

	back_button = _button("Back to town")
	back_button.position = Vector2(920, 584)
	back_button.size = Vector2(320, 64)
	back_button.pressed.connect(func() -> void: back_pressed.emit())
	add_child(back_button)


func _awning_for(floor_id: String) -> Color:
	if floor_id == "cellar":
		return CELLAR_AWNING
	if floor_id == "cistern":
		return CISTERN_AWNING
	return CLOISTER_AWNING


func _bind_descend(button: Button, floor_id: String) -> void:
	button.pressed.connect(func() -> void: descend_requested.emit(floor_id))


func show_board(campaign: Rules.Campaign) -> void:
	notice_label.text = Rules.outcome_line(campaign)
	purse_label.text = "Purse: %d coin\nFlask: %d oil" % [campaign.purse, campaign.flask_oil]
	if campaign.last_outcome == "fresh":
		receipt_label.text = "Corridors\nHazards\nRing\nTotal"
	else:
		receipt_label.text = Rules.format_bill(campaign.last_bill)
	for floor in Rules.floors():
		var done := bool(campaign.completed.get(floor.id, false))
		_status[floor.id].text = "Census complete" if done else "Census open"
		_status[floor.id].add_theme_color_override("font_color", AMBER if done else PARCHMENT)
		_descend[floor.id].text = "Descend again" if done else "Descend"
	queue_redraw()


func status_for(id: String) -> String:
	return str(_status[id].text)


func record_for(id: String) -> String:
	return str(_record[id].text)


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size if size.x > 32.0 else Vector2(1280, 720)), NIGHT)
	for i in 8:
		var t := float(i) / 8.0
		var band := Color(0.07, 0.10, 0.12).lerp(Color(0.16, 0.20, 0.18), t)
		draw_rect(Rect2(0, 500 + i * 28, size.x, 30), band)
	draw_circle(Vector2(1180, 58), 22, Color(0.86, 0.90, 0.78, 0.75))
	draw_circle(Vector2(150, 58), 8, Color(0.45, 0.78, 0.74, 0.9))
	draw_circle(Vector2(188, 70), 4, Color(0.45, 0.78, 0.74, 0.55))
	for x in range(40, 1240, 28):
		draw_line(Vector2(x, 704), Vector2(x + 12, 718), Color(0.18, 0.26, 0.26, 0.7), 2.0)


func _panel(at: Vector2, panel_size: Vector2, awning: Color, title: String) -> Control:
	var panel := Control.new()
	panel.position = at
	panel.size = panel_size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.clip_contents = true
	var body := ColorRect.new()
	body.color = PANEL
	body.size = panel_size
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(body)
	var stripe := ColorRect.new()
	stripe.color = awning
	stripe.size = Vector2(panel_size.x, 52)
	stripe.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(stripe)
	var heading := _label(title, 26, PARCHMENT)
	heading.position = Vector2(20, 8)
	heading.size = Vector2(panel_size.x - 40, 36)
	panel.add_child(heading)
	return panel


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", INK)
	button.add_theme_color_override("font_pressed_color", INK)
	button.add_theme_color_override("font_disabled_color", Color(0.55, 0.48, 0.40))
	var normal := _box(AMBER, Color(0.35, 0.22, 0.08))
	var hover := _box(Color(0.98, 0.78, 0.40), Color(0.45, 0.28, 0.08))
	var pressed := _box(Color(0.78, 0.52, 0.18), Color(0.30, 0.18, 0.06))
	var disabled := _box(Color(0.28, 0.24, 0.20), Color(0.18, 0.15, 0.12))
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_stylebox_override("focus", hover)
	return button


func _box(fill: Color, edge: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = edge
	box.set_border_width_all(2)
	box.set_corner_radius_all(3)
	box.content_margin_left = 12
	box.content_margin_right = 12
	return box
