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
const CRYPT_AWNING := Color(0.36, 0.26, 0.46)
const OSSUARY_AWNING := Color(0.55, 0.48, 0.32)
const RELIQUARY_AWNING := Color(0.58, 0.28, 0.18)
const UNDERCROFT_AWNING := Color(0.18, 0.34, 0.30)
const WELL_AWNING := Color(0.20, 0.28, 0.42)
const SCRIPTORIUM_AWNING := Color(0.28, 0.16, 0.22)
const BINDING_AWNING := Color(0.38, 0.32, 0.22)
const CHART_AWNING := Color(0.12, 0.20, 0.46)
const BELL_AWNING := Color(0.55, 0.32, 0.12)
const CLOCK_AWNING := Color(0.63, 0.48, 0.20)
const FONT_AWNING := Color(0.36, 0.46, 0.26)
const APSE_AWNING := Color(0.78, 0.66, 0.38)
const CHOIR_AWNING := Color(0.58, 0.40, 0.18)
const ROOD_AWNING := Color(0.38, 0.40, 0.44)
const CROSSING_AWNING := Color(0.32, 0.34, 0.28)
const TRANSEPT_AWNING := Color(0.74, 0.68, 0.52)
const AMBULATORY_AWNING := Color(0.62, 0.70, 0.74)
const CHEVET_AWNING := Color(0.22, 0.16, 0.40)
const RETROCHOIR_AWNING := Color(0.84, 0.64, 0.22)
const LADY_CHAPEL_AWNING := Color(0.18, 0.32, 0.68)
const FERETORY_AWNING := Color(0.70, 0.66, 0.58)
const CHANTRY_AWNING := Color(0.64, 0.15, 0.22)
const SACRISTY_AWNING := Color(0.30, 0.16, 0.08)
const PYX_AWNING := Color(0.55, 0.40, 0.12)
const AUMBRY_AWNING := Color(0.58, 0.54, 0.46)
const PISCINA_AWNING := Color(0.34, 0.48, 0.52)
const SEDILIA_AWNING := Color(0.46, 0.40, 0.32)
const CREDENCE_AWNING := Color(0.64, 0.54, 0.38)
const REREDOS_AWNING := Color(0.42, 0.32, 0.48)
const PREDELLA_AWNING := Color(0.50, 0.28, 0.22)
const DOSSAL_AWNING := Color(0.36, 0.10, 0.16)
const RETABLE_AWNING := Color(0.74, 0.56, 0.18)
const TESTER_AWNING := Color(0.28, 0.16, 0.36)
const RIDDEL_AWNING := Color(0.34, 0.38, 0.50)
const FRONTAL_AWNING := Color(0.16, 0.34, 0.28)
const WINDOW_W := 2600.0

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
	var margin := 12.0
	var gap := 8.0
	var card_w := (WINDOW_W - margin * 2.0 - gap * float(floors.size() - 1)) / float(floors.size())
	var x := margin
	var narrow := card_w < 220.0
	var inset := 4.0 if card_w < 90.0 else (6.0 if card_w < 112.0 else (8.0 if card_w < 150.0 else (12.0 if narrow else 20.0)))
	var record_size := 10 if card_w < 90.0 else (11 if card_w < 112.0 else (12 if card_w < 130.0 else (13 if card_w < 150.0 else (15 if narrow else 18))))
	var status_size := 10 if card_w < 90.0 else (11 if card_w < 112.0 else (12 if card_w < 130.0 else (13 if card_w < 150.0 else (16 if narrow else 20))))
	for floor in floors:
		var card := _panel(Vector2(x, 176), Vector2(card_w, 320), _awning_for(str(floor.id)), floor.title)
		add_child(card)
		var record := _label(floor.record, record_size, PARCHMENT)
		record.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		record.clip_text = true
		record.position = Vector2(inset, 56)
		record.custom_minimum_size = Vector2(card_w - inset * 2.0, 0)
		record.size = Vector2(card_w - inset * 2.0, 152)
		card.add_child(record)
		_record[floor.id] = record
		var status := _label("Census open", status_size, PARCHMENT)
		status.position = Vector2(inset, 212)
		status.size = Vector2(card_w - inset * 2.0, 28)
		card.add_child(status)
		_status[floor.id] = status
		var button := _button("Descend", 2 if card_w < 96.0 else 12)
		if card_w < 90.0:
			button.add_theme_font_size_override("font_size", 9)
		elif card_w < 112.0:
			button.add_theme_font_size_override("font_size", 10)
		elif card_w < 130.0:
			button.add_theme_font_size_override("font_size", 11)
		elif card_w < 150.0:
			button.add_theme_font_size_override("font_size", 12)
		elif card_w < 160.0:
			button.add_theme_font_size_override("font_size", 13)
		elif narrow:
			button.add_theme_font_size_override("font_size", 16)
		button.position = Vector2(inset, 244)
		button.size = Vector2(card_w - inset * 2.0, 56)
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
	if floor_id == "cloister":
		return CLOISTER_AWNING
	if floor_id == "crypt":
		return CRYPT_AWNING
	if floor_id == "ossuary":
		return OSSUARY_AWNING
	if floor_id == "reliquary":
		return RELIQUARY_AWNING
	if floor_id == "undercroft":
		return UNDERCROFT_AWNING
	if floor_id == "wellhouse":
		return WELL_AWNING
	if floor_id == "scriptorium":
		return SCRIPTORIUM_AWNING
	if floor_id == "binding":
		return BINDING_AWNING
	if floor_id == "bellloft":
		return BELL_AWNING
	if floor_id == "clockroom":
		return CLOCK_AWNING
	if floor_id == "font":
		return FONT_AWNING
	if floor_id == "apse":
		return APSE_AWNING
	if floor_id == "choir":
		return CHOIR_AWNING
	if floor_id == "rood":
		return ROOD_AWNING
	if floor_id == "crossing":
		return CROSSING_AWNING
	if floor_id == "transept":
		return TRANSEPT_AWNING
	if floor_id == "ambulatory":
		return AMBULATORY_AWNING
	if floor_id == "chevet":
		return CHEVET_AWNING
	if floor_id == "retrochoir":
		return RETROCHOIR_AWNING
	if floor_id == "ladychapel":
		return LADY_CHAPEL_AWNING
	if floor_id == "feretory":
		return FERETORY_AWNING
	if floor_id == "chantry":
		return CHANTRY_AWNING
	if floor_id == "sacristy":
		return SACRISTY_AWNING
	if floor_id == "pyx":
		return PYX_AWNING
	if floor_id == "aumbry":
		return AUMBRY_AWNING
	if floor_id == "piscina":
		return PISCINA_AWNING
	if floor_id == "sedilia":
		return SEDILIA_AWNING
	if floor_id == "credence":
		return CREDENCE_AWNING
	if floor_id == "reredos":
		return REREDOS_AWNING
	if floor_id == "predella":
		return PREDELLA_AWNING
	if floor_id == "dossal":
		return DOSSAL_AWNING
	if floor_id == "retable":
		return RETABLE_AWNING
	if floor_id == "tester":
		return TESTER_AWNING
	if floor_id == "riddel":
		return RIDDEL_AWNING
	if floor_id == "frontal":
		return FRONTAL_AWNING
	return CHART_AWNING


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
	draw_rect(Rect2(Vector2.ZERO, size if size.x > 32.0 else Vector2(WINDOW_W, 720)), NIGHT)
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
	var title_size := 26
	if panel_size.x < 90.0:
		title_size = 9
	elif panel_size.x < 112.0:
		title_size = 10
	elif panel_size.x < 130.0:
		title_size = 11
	elif panel_size.x < 150.0:
		title_size = 12
	elif panel_size.x < 160.0:
		title_size = 13
	elif panel_size.x < 180.0:
		title_size = 15
	elif panel_size.x < 220.0:
		title_size = 18
	var inset := 4.0 if panel_size.x < 90.0 else (6.0 if panel_size.x < 112.0 else (8.0 if panel_size.x < 150.0 else (12.0 if panel_size.x < 220.0 else 20.0)))
	var heading := _label(title, title_size, PARCHMENT)
	heading.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	heading.clip_text = true
	heading.position = Vector2(inset, 4)
	heading.size = Vector2(panel_size.x - inset * 2.0, 44)
	panel.add_child(heading)
	return panel


func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _button(text: String, horizontal_pad: int = 12) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 20)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", INK)
	button.add_theme_color_override("font_pressed_color", INK)
	button.add_theme_color_override("font_disabled_color", Color(0.55, 0.48, 0.40))
	var normal := _box(AMBER, Color(0.35, 0.22, 0.08), horizontal_pad)
	var hover := _box(Color(0.98, 0.78, 0.40), Color(0.45, 0.28, 0.08), horizontal_pad)
	var pressed := _box(Color(0.78, 0.52, 0.18), Color(0.30, 0.18, 0.06), horizontal_pad)
	var disabled := _box(Color(0.28, 0.24, 0.20), Color(0.18, 0.15, 0.12), horizontal_pad)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_stylebox_override("focus", hover)
	return button


func _box(fill: Color, edge: Color, horizontal_pad: int = 12) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = fill
	box.border_color = edge
	box.set_border_width_all(2)
	box.set_corner_radius_all(3)
	box.content_margin_left = horizontal_pad
	box.content_margin_right = horizontal_pad
	return box
