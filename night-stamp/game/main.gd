extends Control

const Rules = preload("res://rules/rules.gd")
const FormBoard = preload("res://game/form_board.gd")

const BG := Color("12141c")
const PANEL := Color("1e2230")
const PANEL_EDGE := Color("343a52")
const TEXT := Color("f4efe6")
const MUTED := Color("b7b1a6")
const INK := Color("e2a25a")
const STAMP := Color("c4523a")

const STAMP_COLORS := {
	"duty": Color("e07a5f"),
	"exemption": Color("8fbf9a"),
	"hold": Color("f2cc8f"),
	"surcharge": Color("e0a15a"),
	"entry_mark": Color("d7c4a3"),
	"visa_dot": Color("8eb4d4"),
	"wax_seal": Color("d36b6b"),
	"corner_notch": Color("c9a27a"),
	"pair_stamp": Color("d39b73"),
	"ledger_line": Color("b7c48a"),
	"column_tally": Color("9db8a0"),
	"echo": Color("c7b0d4"),
	"reply": Color("b0c4d4"),
	"ripple": Color("7fafc4"),
	"waiver": Color("d4c48a"),
	"queue_push": Color("e0b07a"),
	"night_fee": Color("c48ab4"),
	"heavy_chop": Color("c47a62"),
	"cross_check": Color("a8b0c4"),
	"final_notice": Color("d4846a"),
}

var state
var selected := 0
var cursor_row := 1
var cursor_col := 1
var _refresh_queued := false

var seed_edit: LineEdit
var relic_label: Label
var encounter_label: Label
var desk_label: Label
var shift_button: Button
var closing_button: Button
var name_label: Label
var rule_label: Label
var meta_label: Label
var progress_label: Label
var progress_bar: ProgressBar
var patience_label: Label
var pip_box: HBoxContainer
var board
var detail_label: Label
var ink_label: Label
var ink_pips: HBoxContainer
var deck_label: Label
var log_label: RichTextLabel
var hand_box: HBoxContainer
var end_button: Button
var overlay: ColorRect
var modal_box: VBoxContainer


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	var theme := Theme.new()
	theme.default_font_size = 18
	set_theme(theme)
	_build()
	state = Rules.new_run(12345)
	seed_edit.text = "12345"
	_refresh_ui()
	var viewport := get_viewport()
	if viewport != null:
		viewport.gui_release_focus()


func _build() -> void:
	var background := ColorRect.new()
	background.color = BG
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_bottom", 12)
	add_child(margin)

	var root := VBoxContainer.new()
	root.add_theme_constant_override("separation", 8)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(root)

	root.add_child(_build_top())
	root.add_child(_build_traveler())

	var mid := HBoxContainer.new()
	mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mid.add_theme_constant_override("separation", 16)
	root.add_child(mid)
	mid.add_child(_build_form_column())
	mid.add_child(_build_side())

	root.add_child(_section_label("Hand"))
	hand_box = HBoxContainer.new()
	hand_box.add_theme_constant_override("separation", 8)
	hand_box.custom_minimum_size = Vector2(0, 62)
	root.add_child(hand_box)

	var hint := _label("Arrows move the cursor. 1–5 select. Enter stamps. E ends the turn. Click a stamp, then a cell. The queue resolves from the top row downward. Chains stop after %d retriggers. A turn grants at most %d progress." % [Rules.CHAIN_CAP, Rules.PROGRESS_CAP], 14, MUTED)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD
	root.add_child(hint)

	overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.72)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.visible = false
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var modal := PanelContainer.new()
	modal.custom_minimum_size = Vector2(680, 0)
	modal.add_theme_stylebox_override("panel", _flat(PANEL, INK, 12))
	center.add_child(modal)
	modal_box = VBoxContainer.new()
	modal_box.add_theme_constant_override("separation", 10)
	modal.add_child(modal_box)


func _build_top() -> Control:
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 12)
	var title := _label("NIGHT STAMP", 32, TEXT)
	bar.add_child(title)
	desk_label = _label("Act 1 · border desk", 16, MUTED)
	bar.add_child(desk_label)
	encounter_label = _label("Encounter 1 of 4", 16, INK)
	bar.add_child(encounter_label)
	bar.add_child(_spacer())
	bar.add_child(_label("Seed", 16, MUTED))
	seed_edit = LineEdit.new()
	seed_edit.custom_minimum_size = Vector2(120, 40)
	seed_edit.placeholder_text = "12345"
	seed_edit.focus_mode = Control.FOCUS_CLICK
	seed_edit.add_theme_font_size_override("font_size", 18)
	seed_edit.text_submitted.connect(func(_text): _restart_act())
	bar.add_child(seed_edit)
	var restart_encounter := _button("Restart encounter")
	restart_encounter.pressed.connect(_restart_encounter)
	bar.add_child(restart_encounter)
	var restart_act := _button("Restart act")
	restart_act.pressed.connect(_restart_act)
	bar.add_child(restart_act)
	return bar


func _build_traveler() -> Control:
	var panel := PanelContainer.new()
	panel.add_theme_stylebox_override("panel", _flat(PANEL, PANEL_EDGE, 10))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)
	var header := HBoxContainer.new()
	name_label = _label("Traveler", 26, TEXT)
	header.add_child(name_label)
	shift_button = _button("Late shift")
	shift_button.pressed.connect(_toggle_shift)
	header.add_child(shift_button)
	closing_button = _button("Closing bell")
	closing_button.pressed.connect(_toggle_closing)
	header.add_child(closing_button)
	header.add_child(_spacer())
	relic_label = _label("Relic: none", 16, INK)
	header.add_child(relic_label)
	box.add_child(header)
	rule_label = _label("Rule", 20, Color("f0d7a2"))
	rule_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	box.add_child(rule_label)
	meta_label = _label("", 16, MUTED)
	box.add_child(meta_label)
	progress_label = _label("Progress", 16, TEXT)
	box.add_child(progress_label)
	progress_bar = ProgressBar.new()
	progress_bar.show_percentage = false
	progress_bar.custom_minimum_size = Vector2(0, 16)
	progress_bar.add_theme_stylebox_override("background", _bar_style(Color("12141c"), PANEL_EDGE))
	progress_bar.add_theme_stylebox_override("fill", _bar_style(STAMP, STAMP))
	box.add_child(progress_bar)
	var patience_row := HBoxContainer.new()
	patience_row.add_theme_constant_override("separation", 8)
	patience_label = _label("Patience", 18, TEXT)
	patience_row.add_child(patience_label)
	pip_box = HBoxContainer.new()
	pip_box.add_theme_constant_override("separation", 6)
	patience_row.add_child(pip_box)
	box.add_child(patience_row)
	return panel


func _build_form_column() -> Control:
	var column := VBoxContainer.new()
	column.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(_section_label("Form"))
	board = FormBoard.new()
	board.cell_pressed.connect(_on_cell)
	column.add_child(board)
	return column


func _build_side() -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.custom_minimum_size = Vector2(380, 0)
	panel.add_theme_stylebox_override("panel", _flat(PANEL, PANEL_EDGE, 10))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 8)
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(box)
	box.add_child(_section_label("Selected stamp"))
	detail_label = _label("", 16, TEXT)
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	detail_label.custom_minimum_size = Vector2(320, 72)
	box.add_child(detail_label)
	ink_label = _label("Ink", 20, INK)
	box.add_child(ink_label)
	ink_pips = HBoxContainer.new()
	ink_pips.add_theme_constant_override("separation", 6)
	box.add_child(ink_pips)
	end_button = _button("End turn  [E]")
	end_button.pressed.connect(_end_turn)
	box.add_child(end_button)
	deck_label = _label("", 15, MUTED)
	box.add_child(deck_label)
	box.add_child(_section_label("Queue log"))
	log_label = RichTextLabel.new()
	log_label.bbcode_enabled = false
	log_label.scroll_following = true
	log_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_label.custom_minimum_size = Vector2(320, 72)
	log_label.add_theme_color_override("default_color", TEXT)
	log_label.add_theme_font_size_override("normal_font_size", 15)
	box.add_child(log_label)
	return panel


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	var key = event.keycode
	if state.phase == "draft":
		if key == KEY_1:
			_pick_draft(0)
		elif key == KEY_2:
			_pick_draft(1)
		elif key == KEY_3:
			_pick_draft(2)
		else:
			return
		get_viewport().set_input_as_handled()
		return
	if state.phase == "relic":
		if key == KEY_1:
			_pick_relic(0)
		elif key == KEY_2:
			_pick_relic(1)
		else:
			return
		get_viewport().set_input_as_handled()
		return
	if state.phase != "play":
		return
	var handled := true
	match key:
		KEY_LEFT, KEY_A:
			cursor_col = maxi(0, cursor_col - 1)
		KEY_RIGHT, KEY_D:
			cursor_col = mini(2, cursor_col + 1)
		KEY_UP, KEY_W:
			cursor_row = maxi(0, cursor_row - 1)
		KEY_DOWN, KEY_S:
			cursor_row = mini(2, cursor_row + 1)
		KEY_E:
			Rules.end_turn(state)
		KEY_ENTER, KEY_KP_ENTER, KEY_SPACE:
			_try_play(selected, cursor_row, cursor_col)
		KEY_TAB:
			if state.hand.size() > 0:
				var step := -1 if event.shift_pressed else 1
				selected = posmod(selected + step, state.hand.size())
		KEY_1, KEY_2, KEY_3, KEY_4, KEY_5, KEY_6, KEY_7, KEY_8, KEY_9:
			_select_number(key)
		_:
			handled = false
	if handled:
		_request_refresh()
		get_viewport().set_input_as_handled()


func _select_number(key: Key) -> void:
	var index := -1
	match key:
		KEY_1:
			index = 0
		KEY_2:
			index = 1
		KEY_3:
			index = 2
		KEY_4:
			index = 3
		KEY_5:
			index = 4
		KEY_6:
			index = 5
		KEY_7:
			index = 6
		KEY_8:
			index = 7
		KEY_9:
			index = 8
	if index >= 0 and index < state.hand.size():
		selected = index


func _on_cell(row: int, col: int) -> void:
	cursor_row = row
	cursor_col = col
	_try_play(selected, row, col)
	_request_refresh()


func _try_play(hand_index: int, row: int, col: int) -> void:
	if state.phase != "play":
		return
	if Rules.play_stamp(state, hand_index, row, col):
		return
	Rules.note(state, "That stamp does not fit.")


func _end_turn() -> void:
	if state.phase == "play":
		Rules.end_turn(state)
	_request_refresh()


func _restart_encounter() -> void:
	Rules.restart_encounter(state)
	selected = 0
	_request_refresh()


func _restart_act() -> void:
	var shift := Rules.SHIFT_FIRST
	if state != null:
		shift = int(state.shift)
	_open_shift(shift, _parse_seed())


func _toggle_shift() -> void:
	var next := Rules.SHIFT_LATE
	if state.shift == Rules.SHIFT_LATE:
		next = Rules.SHIFT_FIRST
	_open_shift(next, _parse_seed())


func _begin_late_shift() -> void:
	_open_shift(Rules.SHIFT_LATE, state.seed)


func _begin_first_bell() -> void:
	_open_shift(Rules.SHIFT_FIRST, state.seed)


func _toggle_closing() -> void:
	var next := Rules.SHIFT_CLOSING
	if state.shift == Rules.SHIFT_CLOSING:
		next = Rules.SHIFT_FIRST
	_open_shift(next, _parse_seed())


func _begin_closing_bell() -> void:
	_open_shift(Rules.SHIFT_CLOSING, state.seed)


func _open_shift(shift_index: int, seed_value: int) -> void:
	state = Rules.new_run(seed_value, shift_index)
	seed_edit.text = str(state.seed)
	selected = 0
	cursor_row = 1
	cursor_col = 1
	_request_refresh()


func _parse_seed() -> int:
	var text := seed_edit.text.strip_edges()
	if text.is_valid_int():
		return int(text)
	return 12345


func _pick_draft(index: int) -> void:
	if Rules.choose_draft(state, index):
		selected = 0
	_request_refresh()


func _pick_relic(index: int) -> void:
	if index < 0 or index >= state.relic_options.size():
		return
	Rules.choose_relic(state, String(state.relic_options[index]))
	_request_refresh()


func _request_refresh() -> void:
	if _refresh_queued:
		return
	_refresh_queued = true
	call_deferred("_refresh_ui")


func _refresh_ui() -> void:
	_refresh_queued = false
	if state == null:
		return
	if state.hand.is_empty():
		selected = -1
	else:
		selected = clampi(selected, 0, state.hand.size() - 1)
	var traveler = Rules.traveler(state)
	desk_label.text = "%s · border desk" % Rules.shift_label(state)
	encounter_label.text = "Encounter %d of %d" % [int(state.traveler_index) + 1, Rules.roster_size(state)]
	shift_button.text = "First bell" if state.shift == Rules.SHIFT_LATE else "Late shift"
	closing_button.text = "First bell" if state.shift == Rules.SHIFT_CLOSING else "Closing bell"
	name_label.text = String(traveler["name"])
	rule_label.text = "\"%s\"" % traveler["rule_text"]
	var lane := String(Rules.COL_NAMES[int(traveler["lane"])])
	var exempt := String(Rules.ROW_NAMES[int(traveler["exemption_row"])])
	if traveler.has("form_name"):
		meta_label.text = "%s    ·    Lane %s    ·    Exemption matches the %s" % [traveler["form_name"], lane, exempt]
	else:
		meta_label.text = "Lane %s    ·    Exemption matches the %s" % [lane, exempt]
	if state.relic_id == "":
		relic_label.text = "Relic: none"
	else:
		relic_label.text = "Relic: %s" % Rules.RELICS[state.relic_id]["name"]
	var goal := int(traveler["goal"])
	progress_label.text = "Progress %d / %d" % [state.progress, goal]
	progress_bar.max_value = goal
	progress_bar.value = mini(state.progress, goal)
	patience_label.text = "Patience %d" % maxi(state.patience, 0)
	_rebuild_pips(int(traveler["patience"]), maxi(state.patience, 0))
	_show_form()
	_show_detail()
	var ink_max := Rules.ink_per_turn(state)
	ink_label.text = "Ink %d / %d" % [state.ink, ink_max]
	_rebuild_ink(state.ink, ink_max)
	deck_label.text = "Draw pile %d   ·   Discard %d   ·   Turn %d" % [state.draw_pile.size(), state.discard.size(), state.turn_number]
	end_button.disabled = state.phase != "play"
	var lines := ""
	for i in state.log.size():
		if i > 0:
			lines += "\n"
		lines += String(state.log[i])
	log_label.text = lines
	_rebuild_hand()
	_fill_modal()


func _show_form() -> void:
	var display: Array = []
	for row in 3:
		var line: Array = []
		for col in 3:
			var stamp = state.form[row][col]
			if stamp == null:
				line.append(null)
			else:
				var card_id := String(stamp["card_id"])
				line.append({
					"name": String(Rules.CARDS[card_id]["name"]),
					"color": STAMP_COLORS.get(card_id, Color("d7c4a3")),
				})
		display.append(line)
	board.set_board(display, cursor_row, cursor_col)


func _show_detail() -> void:
	if selected < 0 or selected >= state.hand.size():
		detail_label.text = "Select a stamp from the hand."
		return
	var card_id := Rules.card_id_of(state, int(state.hand[selected]))
	var card = Rules.CARDS[card_id]
	var where := "%s, %s" % [Rules.ROW_NAMES[cursor_row], Rules.COL_NAMES[cursor_col]]
	var preview := Rules.preview_progress(state, card_id, cursor_row, cursor_col)
	var amount := "that cell is filled" if preview < 0 else ("%d progress" % preview)
	detail_label.text = "%s  ·  %d ink\n%s\nOn the cursor (%s): %s." % [
		card["name"], int(card["cost"]), card["text"], where, amount,
	]


func _rebuild_pips(maximum: int, filled: int) -> void:
	_clear(pip_box)
	for i in maximum:
		var pip := ColorRect.new()
		pip.custom_minimum_size = Vector2(22, 22)
		pip.color = INK if i < filled else Color("3a3e52")
		pip_box.add_child(pip)


func _rebuild_ink(current: int, maximum: int) -> void:
	_clear(ink_pips)
	for i in maximum:
		var pip := ColorRect.new()
		pip.custom_minimum_size = Vector2(28, 18)
		pip.color = INK if i < current else Color("3a3e52")
		ink_pips.add_child(pip)


func _rebuild_hand() -> void:
	_clear(hand_box)
	for i in state.hand.size():
		var card_id := Rules.card_id_of(state, int(state.hand[i]))
		var card = Rules.CARDS[card_id]
		var button := _button("%d  %s\n%d ink" % [i + 1, card["name"], int(card["cost"])])
		button.custom_minimum_size = Vector2(160, 58)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		_style_button(button, i == selected)
		button.pressed.connect(_select_hand.bind(i))
		hand_box.add_child(button)


func _select_hand(index: int) -> void:
	selected = index
	_request_refresh()


func _fill_modal() -> void:
	_clear(modal_box)
	overlay.visible = state.phase != "play"
	if state.phase == "play":
		return
	if state.phase == "draft":
		modal_box.add_child(_label("Draft one stamp", 28, TEXT))
		modal_box.add_child(_wrapped("Keys 1, 2, and 3 pick a card. It joins the deck for the next traveler.", 16, MUTED))
		for i in state.draft_options.size():
			var card_id := String(state.draft_options[i])
			var card = Rules.CARDS[card_id]
			var button := _button("%d   %s   ·   %d ink\n%s" % [i + 1, card["name"], int(card["cost"]), card["text"]])
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.custom_minimum_size = Vector2(620, 72)
			button.pressed.connect(_pick_draft.bind(i))
			modal_box.add_child(button)
		_add_modal_restarts()
	elif state.phase == "relic":
		modal_box.add_child(_label("The drawer offers a relic", 28, TEXT))
		modal_box.add_child(_wrapped("Pick one. It lasts for the rest of this night. Keys 1 and 2 choose.", 16, MUTED))
		for i in state.relic_options.size():
			var relic_id := String(state.relic_options[i])
			var relic = Rules.RELICS[relic_id]
			var button := _button("%d   %s\n%s" % [i + 1, relic["name"], relic["text"]])
			button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			button.custom_minimum_size = Vector2(620, 72)
			button.pressed.connect(_pick_relic.bind(i))
			modal_box.add_child(button)
		_add_modal_restarts()
	elif state.phase == "victory":
		if state.shift == Rules.SHIFT_CLOSING:
			modal_box.add_child(_label("The closing bell is clear", 32, TEXT))
			modal_box.add_child(_wrapped("Moss Quen, Kel Breck, Tansy Pell, and Lumen Peck passed the desk. Restart this night to run the seed again, or open another bell.", 18, MUTED))
			var restart_closing := _button("Restart act")
			restart_closing.pressed.connect(_restart_act)
			modal_box.add_child(restart_closing)
			var back_late := _button("Open the late shift")
			back_late.pressed.connect(_begin_late_shift)
			modal_box.add_child(back_late)
			var back_first := _button("Open the first bell")
			back_first.pressed.connect(_begin_first_bell)
			modal_box.add_child(back_first)
		elif state.shift == Rules.SHIFT_LATE:
			modal_box.add_child(_label("The late shift is clear", 32, TEXT))
			modal_box.add_child(_wrapped("Nell Parr, Sol Wicks, Pim Larke, and Rue Calder passed the desk. The closing bell is a third night: the same stamps, a fresh deck, and four new forms.", 18, MUTED))
			var closing := _button("Begin the closing bell")
			closing.pressed.connect(_begin_closing_bell)
			modal_box.add_child(closing)
			var restart_night := _button("Restart act")
			restart_night.pressed.connect(_restart_act)
			modal_box.add_child(restart_night)
			var first := _button("Open the first bell")
			first.pressed.connect(_begin_first_bell)
			modal_box.add_child(first)
		else:
			modal_box.add_child(_label("Act 1 is clear", 32, TEXT))
			modal_box.add_child(_wrapped("Four travelers passed the desk. The late shift is a second night: the same stamps, a fresh deck, and four new forms. The closing bell is the third night.", 18, MUTED))
			var late := _button("Begin the late shift")
			late.pressed.connect(_begin_late_shift)
			modal_box.add_child(late)
			var open_closing := _button("Open the closing bell")
			open_closing.pressed.connect(_begin_closing_bell)
			modal_box.add_child(open_closing)
			var button := _button("Restart act")
			button.pressed.connect(_restart_act)
			modal_box.add_child(button)
	elif state.phase == "defeat":
		modal_box.add_child(_label("Patience breaks", 32, TEXT))
		modal_box.add_child(_wrapped("%s turns away. Restart the encounter to deal the same hand, or restart the act." % Rules.traveler(state)["name"], 18, MUTED))
		var again := _button("Restart encounter")
		again.pressed.connect(_restart_encounter)
		modal_box.add_child(again)


func _add_modal_restarts() -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	var encounter := _button("Restart encounter")
	encounter.pressed.connect(_restart_encounter)
	row.add_child(encounter)
	var act := _button("Restart act")
	act.pressed.connect(_restart_act)
	row.add_child(act)
	modal_box.add_child(row)


func _wrapped(text: String, size: int, color: Color) -> Label:
	var label := _label(text, size, color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.custom_minimum_size = Vector2(620, 0)
	return label


func _clear(node: Node) -> void:
	while node.get_child_count() > 0:
		var child := node.get_child(0)
		node.remove_child(child)
		child.free()


func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label


func _section_label(text: String) -> Label:
	return _label(text, 14, MUTED)


func _button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	_style_button(button, false)
	return button


func _style_button(button: Button, emphasized: bool) -> void:
	var border := INK if emphasized else Color("4a516e")
	var bg := Color("343a52") if emphasized else Color("2a3044")
	button.add_theme_stylebox_override("normal", _flat(bg, border, 8))
	button.add_theme_stylebox_override("hover", _flat(bg.lightened(0.08), border, 8))
	button.add_theme_stylebox_override("pressed", _flat(bg.darkened(0.1), border, 8))
	button.add_theme_stylebox_override("disabled", _flat(Color("222433"), Color("33364a"), 8))
	button.add_theme_color_override("font_color", TEXT)
	button.add_theme_color_override("font_hover_color", TEXT)
	button.add_theme_color_override("font_pressed_color", TEXT)
	button.add_theme_color_override("font_disabled_color", Color("888478"))
	button.add_theme_font_size_override("font_size", 16)


func _bar_style(fill: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.content_margin_left = 0
	style.content_margin_right = 0
	style.content_margin_top = 0
	style.content_margin_bottom = 0
	return style


func _flat(fill: Color, border: Color, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(2)
	style.set_corner_radius_all(radius)
	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style


func _spacer() -> Control:
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return spacer
