extends Control

const Rules := preload("res://scripts/census_rules.gd")

signal floors_pressed
signal buy_pressed
signal restart_pressed

const NIGHT := Color(0.07, 0.06, 0.10)
const AMBER := Color(0.93, 0.67, 0.28)
const PARCHMENT := Color(0.93, 0.86, 0.70)
const INK := Color(0.16, 0.11, 0.08)
const PANEL := Color(0.15, 0.12, 0.11, 0.94)
const AWNING_A := Color(0.50, 0.18, 0.16)
const AWNING_B := Color(0.16, 0.32, 0.34)

var purse_label: Label
var flask_label: Label
var price_label: Label
var buy_button: Button
var floors_button: Button
var outcome_label: Label
var receipt_label: Label


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	_build()


func _build() -> void:
	var title := _label("Lantern Census", 42, AMBER)
	title.position = Vector2(48, 20)
	title.size = Vector2(760, 56)
	add_child(title)

	var flavor := _label("The guild pays for the map you carry out of each floor.", 20, PARCHMENT)
	flavor.position = Vector2(48, 78)
	flavor.size = Vector2(900, 30)
	add_child(flavor)

	var instruction := _label(Rules.TOWN_LINE, 18, Color(0.98, 0.94, 0.84))
	instruction.position = Vector2(48, 118)
	instruction.size = Vector2(1184, 32)
	add_child(instruction)

	var outfitter := _panel(Vector2(40, 168), Vector2(580, 392), AWNING_A, "Outfitter")
	add_child(outfitter)
	purse_label = _label("", 22, PARCHMENT)
	purse_label.position = Vector2(24, 72)
	purse_label.size = Vector2(532, 32)
	outfitter.add_child(purse_label)
	flask_label = _label("", 20, PARCHMENT)
	flask_label.position = Vector2(24, 114)
	flask_label.size = Vector2(532, 64)
	flask_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	outfitter.add_child(flask_label)
	price_label = _label("", 18, Color(0.86, 0.78, 0.62))
	price_label.position = Vector2(24, 188)
	price_label.size = Vector2(532, 96)
	price_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	outfitter.add_child(price_label)
	buy_button = _button("Buy large flask")
	buy_button.position = Vector2(24, 308)
	buy_button.size = Vector2(532, 60)
	buy_button.pressed.connect(func() -> void: buy_pressed.emit())
	outfitter.add_child(buy_button)

	var clerk := _panel(Vector2(660, 168), Vector2(580, 392), AWNING_B, "Guild clerk")
	add_child(clerk)
	outcome_label = _label("", 18, PARCHMENT)
	outcome_label.position = Vector2(24, 68)
	outcome_label.size = Vector2(532, 64)
	outcome_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	clerk.add_child(outcome_label)
	var paper := ColorRect.new()
	paper.color = PARCHMENT
	paper.position = Vector2(24, 142)
	paper.size = Vector2(532, 120)
	paper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	clerk.add_child(paper)
	receipt_label = _label("", 20, INK)
	receipt_label.position = Vector2(16, 12)
	receipt_label.size = Vector2(500, 100)
	receipt_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	var mono := SystemFont.new()
	mono.font_names = PackedStringArray(["DejaVu Sans Mono", "Liberation Mono", "Courier New", "monospace"])
	receipt_label.add_theme_font_override("font", mono)
	paper.add_child(receipt_label)
	var rate := RichTextLabel.new()
	rate.text = Rules.RATE_CARD
	rate.bbcode_enabled = false
	rate.scroll_active = false
	rate.fit_content = false
	rate.position = Vector2(24, 270)
	rate.size = Vector2(532, 112)
	rate.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rate.add_theme_font_size_override("normal_font_size", 16)
	rate.add_theme_color_override("default_color", Color(0.86, 0.78, 0.62))
	clerk.add_child(rate)

	floors_button = _button("Floor select")
	floors_button.position = Vector2(40, 584)
	floors_button.size = Vector2(300, 64)
	floors_button.pressed.connect(func() -> void: floors_pressed.emit())
	add_child(floors_button)

	var restart := _button("Restart")
	restart.position = Vector2(360, 584)
	restart.size = Vector2(220, 64)
	restart.pressed.connect(func() -> void: restart_pressed.emit())
	add_child(restart)


func show_campaign(campaign: Rules.Campaign) -> void:
	purse_label.text = "Purse: %d coin" % campaign.purse
	if campaign.upgraded:
		flask_label.text = "Packed flask: %d oil. The large flask is yours." % campaign.flask_oil
		buy_button.text = "Large flask packed"
		buy_button.disabled = true
	else:
		if campaign.purse <= 0:
			flask_label.text = "Packed flask: %d oil. The purse is empty, so this descent uses the small flask." % campaign.flask_oil
		elif campaign.purse < Rules.LARGE_FLASK_COST:
			flask_label.text = "Packed flask: %d oil. The purse is still short of the large flask." % campaign.flask_oil
		else:
			flask_label.text = "Packed flask: %d oil. The purse can buy the large flask." % campaign.flask_oil
		buy_button.text = "Buy large flask (%d oil) for %d coin" % [Rules.LARGE_FLASK_OIL, Rules.LARGE_FLASK_COST]
		buy_button.disabled = not Rules.can_buy(campaign)
	price_label.text = "Large flask: %d oil for %d coin. It replaces the small flask for later descents." % [Rules.LARGE_FLASK_OIL, Rules.LARGE_FLASK_COST]
	outcome_label.text = Rules.outcome_line(campaign)
	if campaign.last_outcome == "fresh":
		receipt_label.text = "Corridors\nHazards\nRing\nTotal"
	else:
		receipt_label.text = Rules.format_bill(campaign.last_bill)
	queue_redraw()


func _draw() -> void:
	var sky := NIGHT
	draw_rect(Rect2(Vector2.ZERO, size), sky)
	for i in 8:
		var t := float(i) / 8.0
		var band := Color(0.09, 0.08, 0.14).lerp(Color(0.20, 0.13, 0.10), t)
		draw_rect(Rect2(0, 520 + i * 26, size.x, 28), band)
	draw_circle(Vector2(1080, 70), 26, Color(0.93, 0.90, 0.78, 0.85))
	draw_circle(Vector2(180, 560), 18, Color(0.95, 0.72, 0.30, 0.35))
	draw_circle(Vector2(1100, 560), 18, Color(0.95, 0.72, 0.30, 0.35))
	# Cobble ticks along the street, under the buttons.
	for x in range(40, 1240, 28):
		draw_line(Vector2(x, 668), Vector2(x + 10, 692), Color(0.22, 0.16, 0.12, 0.7), 2.0)


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
