extends Control

const Sport = preload("res://scripts/sport.gd")
const SeriesScript = preload("res://scripts/series.gd")

const COL_BG := Color("1B2430")
const COL_PANEL := Color("273244")
const COL_PANEL_2 := Color("314056")
const COL_TEXT := Color("F4EFE6")
const COL_MUTED := Color("C5BEB2")
const COL_ACCENT := Color("E2A23A")
const COL_HOME := Color("D4652F")
const COL_AWAY := Color("2A9D8F")
const COL_BAD := Color("E07A6A")
const COL_GOOD := Color("8FCB7A")

const TACTIC_HELP := {
	"aggressive": "Aggressive drives with Lash against the fielder's Arm and leans Far. Scores come more often. Field is built to take that drive away.",
	"patient": "Patient places with Eye against the fielder's Glove and leans Near. Marks come more often than clean scores. A second mark scores the first.",
	"field": "Field lifts defensive Arm by 3 and Glove by 1, and the rover's Arm by 1. Batting uses the Lash/Eye blend and drops Read by 1.",
}

const WATCH_SECONDS := 1.0

var series = null
var phase := "office"
var lineup: Array = [0, 1, 2, 3]
var selected_slot := 0
var tactic := "aggressive"
var training := "lash"
var watch_log: Array = []
var shown := 0
var current_match: Dictionary = {}

var office_panel: Control
var match_panel: Control
var board_panel: Control
var board_label: Label
var explanation_label: Label
var log_label: Label
var log_scroll: ScrollContainer
var error_label: Label
var result_label: Label
var skip_button: Button
var watch_button: Button
var continue_button: Button
var restart_button: Button
var board_restart_button: Button
var match_skip_button: Button
var roster_buttons: Array = []
var tactic_buttons: Array = []
var training_buttons: Array = []
var slot_buttons: Array = []
var lineup_name_labels: Array = []
var field_board = null
var ticker: Timer
var score_label: Label
var pa_label: Label
var status_label: Label
var stat_strip: Label
var week_label: Label
var record_label: Label
var goal_label: Label
var opponent_label: Label
var tactic_help: Label
var training_help: Label
var seed_label: Label


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	ticker = Timer.new()
	ticker.wait_time = WATCH_SECONDS
	ticker.one_shot = false
	ticker.timeout.connect(_on_tick)
	add_child(ticker)
	start_new_series(606)


func start_new_series(series_seed: int) -> void:
	if ticker != null:
		ticker.stop()
	series = SeriesScript.new(series_seed)
	lineup = [0, 1, 2, 3]
	selected_slot = 0
	tactic = "aggressive"
	training = "lash"
	watch_log = []
	shown = 0
	current_match = {}
	phase = "office"
	if error_label != null:
		error_label.text = ""
	if result_label != null:
		result_label.text = ""
	_sync_log_label()
	_refresh_office()
	_apply_visibility()
	_focus_control(watch_button)


func press_watch() -> void:
	if phase != "office":
		return
	if not _start_playback():
		return
	phase = "watch"
	_apply_visibility()
	_reveal(0)
	shown = 1
	ticker.start()
	_focus_control(match_skip_button)


func press_skip() -> void:
	if phase == "office":
		if not _start_playback():
			return
		phase = "watch"
		shown = 0
		_apply_visibility()
	if phase != "watch":
		return
	ticker.stop()
	var total := _pa_count()
	while shown < total:
		_reveal(shown)
		shown += 1
	_enter_result()


func fast_forward_watch() -> void:
	if phase != "watch":
		return
	ticker.stop()
	var total := _pa_count()
	while shown < total:
		_reveal(shown)
		shown += 1


func press_continue() -> void:
	if phase != "result":
		return
	var committed: Dictionary = series.commit_match()
	if not bool(committed.get("ok", false)):
		error_label.text = str(committed.get("error", "Could not record the match."))
		return
	if series.is_over():
		_show_board()
	else:
		_show_office()


func press_restart() -> void:
	var next_seed := 606
	if series != null:
		next_seed = int(series.seed) + 1
	start_new_series(next_seed)


func cycle_slot(slot: int, direction: int) -> void:
	if phase != "office":
		return
	if slot < 0 or slot >= lineup.size():
		return
	selected_slot = slot
	var count: int = series.player_roster.size()
	var candidate := int(lineup[slot])
	for _step in count:
		candidate = (candidate + direction) % count
		if candidate < 0:
			candidate += count
		var used := false
		for i in lineup.size():
			if i != slot and int(lineup[i]) == candidate:
				used = true
		if not used:
			lineup[slot] = candidate
			_refresh_office()
			return


func assign_player_to_selected(roster_index: int) -> void:
	if phase != "office":
		return
	var other := -1
	for i in lineup.size():
		if int(lineup[i]) == roster_index:
			other = i
	if other == selected_slot:
		_refresh_office()
		return
	if other >= 0:
		var tmp = lineup[selected_slot]
		lineup[selected_slot] = lineup[other]
		lineup[other] = tmp
	else:
		lineup[selected_slot] = roster_index
	_refresh_office()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return
	var key := event as InputEventKey
	if not key.pressed or key.echo:
		return
	var code := key.keycode
	var handled := false
	if phase == "office":
		if code == KEY_1 or code == KEY_KP_1:
			_select_slot(0)
			handled = true
		elif code == KEY_2 or code == KEY_KP_2:
			_select_slot(1)
			handled = true
		elif code == KEY_3 or code == KEY_KP_3:
			_select_slot(2)
			handled = true
		elif code == KEY_4 or code == KEY_KP_4:
			_select_slot(3)
			handled = true
		elif code == KEY_LEFT or code == KEY_A:
			cycle_slot(selected_slot, -1)
			handled = true
		elif code == KEY_RIGHT or code == KEY_D:
			cycle_slot(selected_slot, 1)
			handled = true
		elif code == KEY_T:
			_cycle_tactic()
			handled = true
		elif code == KEY_Y:
			_cycle_training()
			handled = true
		elif code == KEY_W:
			press_watch()
			handled = true
		elif code == KEY_S:
			press_skip()
			handled = true
		elif code == KEY_R:
			press_restart()
			handled = true
	elif phase == "watch" and code == KEY_S:
		press_skip()
		handled = true
	elif phase == "result" and (code == KEY_N or code == KEY_ENTER or code == KEY_KP_ENTER):
		press_continue()
		handled = true
	elif phase == "board" and (code == KEY_R or code == KEY_N or code == KEY_ENTER or code == KEY_KP_ENTER):
		press_restart()
		handled = true
	if handled:
		var viewport := get_viewport()
		if viewport != null:
			viewport.set_input_as_handled()


func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = COL_BG
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	office_panel = _full_margin()
	add_child(office_panel)
	var office_scroll := ScrollContainer.new()
	office_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	office_scroll.follow_focus = true
	office_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	office_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	office_panel.add_child(office_scroll)
	var office := VBoxContainer.new()
	office.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	office.add_theme_constant_override("separation", 8)
	office_scroll.add_child(office)

	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 16)
	office.add_child(title_row)
	title_row.add_child(_label("LOWBALL", 32, COL_ACCENT))
	title_row.add_child(_label(Sport.TOWN, 20, COL_TEXT))
	week_label = _label("Week 1 of 4", 18, COL_TEXT)
	title_row.add_child(week_label)
	record_label = _label("", 16, COL_TEXT)
	title_row.add_child(record_label)
	seed_label = _label("", 14, COL_MUTED)
	title_row.add_child(seed_label)

	goal_label = _label(Sport.GOAL_TEXT, 16, COL_ACCENT)
	goal_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	office.add_child(goal_label)

	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 12)
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	office.add_child(columns)

	var roster_panel := _section()
	roster_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	roster_panel.size_flags_stretch_ratio = 1.35
	columns.add_child(roster_panel)
	var roster_box := VBoxContainer.new()
	roster_box.add_theme_constant_override("separation", 4)
	roster_panel.add_child(roster_box)
	roster_box.add_child(_label(Sport.PLAYER_CLUB, 18, COL_HOME))
	roster_box.add_child(_label("Click a name to fill the selected slot. Keys 1-4 and Left/Right do the same.", 13, COL_MUTED))
	for i in Sport.ROSTER_SIZE:
		var roster_button := _make_button("Player")
		roster_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		roster_button.pressed.connect(_on_roster_pressed.bind(i))
		roster_box.add_child(roster_button)
		roster_buttons.append(roster_button)

	var right_column := VBoxContainer.new()
	right_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_column.add_theme_constant_override("separation", 6)
	columns.add_child(right_column)
	var opponent_panel := _section()
	opponent_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_column.add_child(opponent_panel)
	var opponent_box := VBoxContainer.new()
	opponent_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	opponent_panel.add_child(opponent_box)
	opponent_box.add_child(_label(Sport.OPPONENT_CLUB, 18, COL_AWAY))
	opponent_label = _label("", 14, COL_TEXT)
	opponent_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	opponent_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	opponent_box.add_child(opponent_label)
	right_column.add_child(_label("Lineup. Order is also Near, Mid, Far, and Rover.", 15, COL_TEXT))
	for slot in Sport.LINEUP_SIZE:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		right_column.add_child(row)
		var select := _make_button(str(slot + 1))
		select.custom_minimum_size = Vector2(44, 36)
		select.pressed.connect(_select_slot.bind(slot))
		row.add_child(select)
		slot_buttons.append(select)
		var previous := _make_button("<")
		previous.custom_minimum_size = Vector2(44, 36)
		previous.pressed.connect(cycle_slot.bind(slot, -1))
		row.add_child(previous)
		var name_label := _label("Batter", 16, COL_TEXT)
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(name_label)
		lineup_name_labels.append(name_label)
		var next := _make_button(">")
		next.custom_minimum_size = Vector2(44, 36)
		next.pressed.connect(cycle_slot.bind(slot, 1))
		row.add_child(next)
		row.add_child(_label("Fields " + str(Sport.SLOT_ROLE[slot]), 14, COL_MUTED))

	var choice_row := HBoxContainer.new()
	choice_row.add_theme_constant_override("separation", 18)
	office.add_child(choice_row)
	var tactic_box := VBoxContainer.new()
	tactic_box.add_theme_constant_override("separation", 4)
	choice_row.add_child(tactic_box)
	tactic_box.add_child(_label("Tactic", 16, COL_TEXT))
	var tactic_buttons_row := HBoxContainer.new()
	tactic_buttons_row.add_theme_constant_override("separation", 6)
	tactic_box.add_child(tactic_buttons_row)
	for tactic_name in Sport.TACTICS:
		var tactic_button := _make_button(Sport.TACTIC_LABEL[tactic_name])
		tactic_button.pressed.connect(_set_tactic.bind(tactic_name))
		tactic_buttons_row.add_child(tactic_button)
		tactic_buttons.append(tactic_button)
	var training_box := VBoxContainer.new()
	training_box.add_theme_constant_override("separation", 4)
	choice_row.add_child(training_box)
	training_box.add_child(_label("Training focus", 16, COL_TEXT))
	var training_buttons_row := HBoxContainer.new()
	training_buttons_row.add_theme_constant_override("separation", 6)
	training_box.add_child(training_buttons_row)
	for stat_name in Sport.STATS:
		var training_button := _make_button(Sport.STAT_LABEL[stat_name])
		training_button.pressed.connect(_set_training.bind(stat_name))
		training_buttons_row.add_child(training_button)
		training_buttons.append(training_button)

	tactic_help = _label("", 14, COL_TEXT)
	tactic_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	office.add_child(tactic_help)
	training_help = _label("", 14, COL_MUTED)
	training_help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	office.add_child(training_help)
	error_label = _label("", 14, COL_BAD)
	error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	office.add_child(error_label)

	var action_row := HBoxContainer.new()
	action_row.add_theme_constant_override("separation", 8)
	office.add_child(action_row)
	watch_button = _make_button("Watch at 1x")
	watch_button.pressed.connect(press_watch)
	action_row.add_child(watch_button)
	skip_button = _make_button("Skip to result")
	skip_button.pressed.connect(press_skip)
	action_row.add_child(skip_button)
	restart_button = _make_button("Restart series")
	restart_button.pressed.connect(press_restart)
	action_row.add_child(restart_button)

	var help := _label("Keyboard: Tab then Enter. Keys 1-4 pick a slot, Left/Right change that batter, T tactic, Y training, W watch, S skip, N continue, R restart on the office or the board.", 13, COL_MUTED)
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	office.add_child(help)

	match_panel = _full_margin()
	add_child(match_panel)
	var match_box := VBoxContainer.new()
	match_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	match_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	match_box.add_theme_constant_override("separation", 6)
	match_panel.add_child(match_box)
	score_label = _label("", 22, COL_TEXT)
	match_box.add_child(score_label)
	pa_label = _label("", 15, COL_MUTED)
	match_box.add_child(pa_label)
	stat_strip = _label("", 14, COL_TEXT)
	stat_strip.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	match_box.add_child(stat_strip)
	field_board = FieldBoard.new()
	field_board.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	field_board.size_flags_vertical = Control.SIZE_EXPAND_FILL
	field_board.custom_minimum_size = Vector2(0, 240)
	match_box.add_child(field_board)
	status_label = _label("", 14, COL_ACCENT)
	match_box.add_child(status_label)
	explanation_label = _label("", 16, COL_TEXT)
	explanation_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explanation_label.custom_minimum_size = Vector2(0, 78)
	match_box.add_child(explanation_label)
	result_label = _label("", 15, COL_GOOD)
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	result_label.visible = false
	match_box.add_child(result_label)
	log_scroll = ScrollContainer.new()
	log_scroll.custom_minimum_size = Vector2(0, 96)
	log_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	match_box.add_child(log_scroll)
	log_label = _label("", 13, COL_MUTED)
	log_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	log_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_scroll.add_child(log_label)
	var match_actions := HBoxContainer.new()
	match_actions.add_theme_constant_override("separation", 8)
	match_box.add_child(match_actions)
	match_skip_button = _make_button("Skip to result")
	match_skip_button.pressed.connect(press_skip)
	match_actions.add_child(match_skip_button)
	continue_button = _make_button("Continue")
	continue_button.pressed.connect(press_continue)
	match_actions.add_child(continue_button)
	var match_restart := _make_button("Restart series")
	match_restart.pressed.connect(press_restart)
	match_actions.add_child(match_restart)

	board_panel = _full_margin()
	add_child(board_panel)
	var board_scroll := ScrollContainer.new()
	board_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	board_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	board_panel.add_child(board_scroll)
	var board_box := VBoxContainer.new()
	board_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	board_box.add_theme_constant_override("separation", 10)
	board_scroll.add_child(board_box)
	board_box.add_child(_label("Board meeting", 32, COL_ACCENT))
	board_box.add_child(_label("Four weeks in %s." % Sport.TOWN, 18, COL_TEXT))
	board_label = _label("", 16, COL_TEXT)
	board_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	board_box.add_child(board_label)
	board_restart_button = _make_button("Restart series")
	board_restart_button.pressed.connect(press_restart)
	board_box.add_child(board_restart_button)
	board_box.add_child(_label("Enter or R starts a new series. The new roster uses the next seed.", 14, COL_MUTED))


func _full_margin() -> MarginContainer:
	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 12)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 12)
	return margin


func _section() -> PanelContainer:
	var panel := PanelContainer.new()
	var style := _box(COL_PANEL, Color(0, 0, 0, 0), 0)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style)
	return panel


func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _make_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_ALL
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.custom_minimum_size = Vector2(0, 36)
	_paint_button(button, false)
	return button


func _box(bg: Color, border: Color, border_width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.set_corner_radius_all(4)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 6
	style.content_margin_bottom = 6
	style.border_color = border
	style.set_border_width_all(border_width)
	return style


func _paint_button(button: Button, selected: bool) -> void:
	var bg := COL_ACCENT if selected else COL_PANEL_2
	var fg := COL_BG if selected else COL_TEXT
	button.add_theme_color_override("font_color", fg)
	button.add_theme_color_override("font_hover_color", fg)
	button.add_theme_color_override("font_pressed_color", fg)
	button.add_theme_color_override("font_focus_color", COL_BG if selected else COL_ACCENT)
	button.add_theme_stylebox_override("normal", _box(bg, Color(0, 0, 0, 0), 0))
	button.add_theme_stylebox_override("hover", _box(bg.lightened(0.08), COL_ACCENT, 1))
	button.add_theme_stylebox_override("pressed", _box(bg.darkened(0.08), COL_ACCENT, 2))
	button.add_theme_stylebox_override("focus", _box(bg, COL_ACCENT, 3))
	button.add_theme_stylebox_override("disabled", _box(COL_PANEL, COL_MUTED, 0))


func _apply_visibility() -> void:
	office_panel.visible = phase == "office"
	match_panel.visible = phase == "watch" or phase == "result"
	board_panel.visible = phase == "board"
	if result_label != null:
		result_label.visible = phase == "result"
	if match_skip_button != null:
		match_skip_button.visible = phase == "watch"
	if continue_button != null:
		continue_button.visible = phase == "result"


func _show_office() -> void:
	phase = "office"
	_refresh_office()
	_apply_visibility()
	_focus_control(watch_button)


func _show_board() -> void:
	phase = "board"
	if ticker != null:
		ticker.stop()
	board_label.text = _board_text()
	_apply_visibility()
	_focus_control(board_restart_button)


func _refresh_office() -> void:
	if series == null or week_label == null:
		return
	var shown_week: int = mini(int(series.week) + 1, Sport.SERIES_WEEKS)
	week_label.text = "Week %d of %d" % [shown_week, Sport.SERIES_WEEKS]
	seed_label.text = "Series seed %d" % int(series.seed)
	var rec: Dictionary = series.record()
	goal_label.text = "%s  Wins so far: %d." % [Sport.GOAL_TEXT, int(rec["wins"])]
	record_label.text = "Record %d-%d-%d. %s" % [
		int(rec["wins"]),
		int(rec["losses"]),
		int(rec["ties"]),
		"You bat second." if series.player_bats_second() else "You bat first.",
	]
	for i in roster_buttons.size():
		var player: Dictionary = series.player_roster[i]
		var slot_of := -1
		for slot in lineup.size():
			if int(lineup[slot]) == i:
				slot_of = slot
		var prefix := "Slot %d  " % (slot_of + 1) if slot_of >= 0 else "Bench   "
		var bits := prefix + str(player["player_name"])
		for key in Sport.STATS:
			bits += "   %s %d" % [Sport.STAT_LABEL[key], Sport.get_stat(player, key)]
		roster_buttons[i].text = bits
		_paint_button(roster_buttons[i], slot_of >= 0)
	for slot in lineup.size():
		var player: Dictionary = series.player_roster[int(lineup[slot])]
		lineup_name_labels[slot].text = str(player["player_name"])
		var selected := slot == selected_slot
		slot_buttons[slot].text = "%d%s" % [slot + 1, " *" if selected else ""]
		_paint_button(slot_buttons[slot], selected)
	for i in tactic_buttons.size():
		var tactic_name: String = Sport.TACTICS[i]
		var on := tactic_name == tactic
		tactic_buttons[i].text = Sport.TACTIC_LABEL[tactic_name] + (" [on]" if on else "")
		_paint_button(tactic_buttons[i], on)
	for i in training_buttons.size():
		var stat_name: String = Sport.STATS[i]
		var on := stat_name == training
		training_buttons[i].text = Sport.STAT_LABEL[stat_name] + (" [on]" if on else "")
		_paint_button(training_buttons[i], on)
	tactic_help.text = str(TACTIC_HELP[tactic])
	training_help.text = "After the match, every %s player gains +1 %s, capped at %d." % [
		Sport.PLAYER_CLUB, Sport.STAT_LABEL[training], Sport.STAT_CAP,
	]
	opponent_label.text = _opponent_blurb()


func _opponent_blurb() -> String:
	var plan: Dictionary = Sport.opponent_plan(series.opponent_roster, int(series.week))
	var bits: Array = []
	var indices: Array = plan["lineup"]
	for n in indices.size():
		var player: Dictionary = series.opponent_roster[int(indices[n])]
		bits.append("%d %s (%s)" % [n + 1, str(player["player_name"]), str(Sport.SLOT_ROLE[n])])
	return "Posted tactic: %s.\nLineup: %s.\nThey drill %s after the match.\nBatting second gives no stat bonus. The side that bats second is only the bottom of each inning." % [
		Sport.TACTIC_LABEL[str(plan["tactic"])],
		", ".join(bits),
		Sport.STAT_LABEL[str(plan["training"])],
	]


func _select_slot(slot: int) -> void:
	if phase != "office":
		return
	selected_slot = clampi(slot, 0, Sport.LINEUP_SIZE - 1)
	_refresh_office()


func _set_tactic(next_tactic: String) -> void:
	if phase != "office":
		return
	tactic = next_tactic
	_refresh_office()


func _set_training(next_focus: String) -> void:
	if phase != "office":
		return
	training = next_focus
	_refresh_office()


func _cycle_tactic() -> void:
	var index := Sport.TACTICS.find(tactic)
	if index < 0:
		index = 0
	tactic = str(Sport.TACTICS[(index + 1) % Sport.TACTICS.size()])
	_refresh_office()


func _cycle_training() -> void:
	var index := Sport.STATS.find(training)
	if index < 0:
		index = 0
	training = str(Sport.STATS[(index + 1) % Sport.STATS.size()])
	_refresh_office()


func _on_roster_pressed(index: int) -> void:
	assign_player_to_selected(index)


func _start_playback() -> bool:
	var played: Dictionary = series.begin_match(lineup, tactic, training)
	if not bool(played.get("ok", false)):
		error_label.text = str(played.get("error", "Could not start the match."))
		return false
	error_label.text = ""
	current_match = played
	watch_log = []
	shown = 0
	_sync_log_label()
	result_label.text = ""
	return true


func _pa_count() -> int:
	if current_match.is_empty():
		return 0
	return (current_match["plate_appearances"] as Array).size()


func _reveal(index: int) -> void:
	var appearances: Array = current_match["plate_appearances"]
	var pa: Dictionary = appearances[index]
	if watch_log.size() == index:
		watch_log.append(str(pa["explanation"]))
		_sync_log_label()
	explanation_label.text = str(pa["explanation"])
	var away_score := int(pa["away_score"])
	var home_score := int(pa["home_score"])
	score_label.text = "%s  %d      %s  %d" % [
		str(current_match["away_club"]), away_score, str(current_match["home_club"]), home_score,
	]
	pa_label.text = "Inning %d %s  ·  plate appearance %d of %d  ·  %s batting  ·  1x, one plate appearance a second" % [
		int(pa["inning"]), str(pa["half"]), index + 1, appearances.size(), str(pa["batting_club"]),
	]
	stat_strip.text = _batter_strip(pa)
	var fielding_names: Array = current_match["away_names"]
	if str(pa["fielding_club"]) == str(current_match["home_club"]):
		fielding_names = current_match["home_names"]
	field_board.present(
		pa,
		fielding_names,
		_club_color(str(pa["batting_club"])),
		_club_color(str(pa["fielding_club"]))
	)
	var status := ""
	if index > 0:
		var previous: Dictionary = appearances[index - 1]
		var new_half := str(previous["half"]) != str(pa["half"]) or int(previous["inning"]) != int(pa["inning"])
		if bool(previous["mark_after"]) and new_half:
			status = "The mark did not carry into this half."
	status_label.text = status


func _batter_strip(pa: Dictionary) -> String:
	return "%s    Lash %d   Eye %d   Legs %d   Glove %d   Arm %d   Read %d" % [
		str(pa["batter_name"]),
		int(pa["base_lash"]),
		int(pa["base_eye"]),
		int(pa["base_legs"]),
		int(pa["batter_glove"]),
		int(pa["batter_arm"]),
		int(pa["base_read"]),
	]


func _sync_log_label() -> void:
	if log_label == null:
		return
	if watch_log.is_empty():
		log_label.text = "Watch log"
	else:
		log_label.text = "Watch log\n" + "\n".join(watch_log)


func _on_tick() -> void:
	if phase != "watch":
		ticker.stop()
		return
	var total := _pa_count()
	if shown >= total:
		ticker.stop()
		_enter_result()
		return
	_reveal(shown)
	shown += 1


func _enter_result() -> void:
	phase = "result"
	if ticker != null:
		ticker.stop()
	result_label.text = _result_text(current_match)
	_apply_visibility()
	_focus_control(continue_button)


func _result_text(played: Dictionary) -> String:
	var word := _result_word(str(played["player_result"]))
	var order := "second" if bool(played["player_bats_second"]) else "first"
	var player_notes: Array = Sport.preview_training(series.player_roster, str(played["player_focus"]))
	var opponent_notes: Array = Sport.preview_training(series.opponent_roster, str(played["opponent_focus"]))
	return "Final: %s %d, %s %d. %s. Reedmice batted %s. %s against %s.\n%s\n%s" % [
		Sport.PLAYER_CLUB,
		int(played["player_score"]),
		Sport.OPPONENT_CLUB,
		int(played["opponent_score"]),
		word,
		order,
		Sport.TACTIC_LABEL[str(played["player_tactic"])],
		Sport.TACTIC_LABEL[str(played["opponent_tactic"])],
		_drill_sentence(player_notes, Sport.PLAYER_CLUB),
		_drill_sentence(opponent_notes, Sport.OPPONENT_CLUB),
	]


func _drill_sentence(notes: Array, club: String) -> String:
	if notes.is_empty():
		return ""
	var raised := 0
	var capped := 0
	for note in notes:
		if int(note["after"]) == int(note["before"]):
			capped += 1
		else:
			raised += 1
	return "%s drill %s: %d gained 1, %d already at %d." % [
		club, Sport.STAT_LABEL[str(notes[0]["stat"])], raised, capped, Sport.STAT_CAP,
	]


func _board_text() -> String:
	var rec: Dictionary = series.record()
	var verdict := "MET" if series.goal_met() else "MISSED"
	var lines: Array = []
	lines.append(Sport.GOAL_TEXT)
	lines.append("Result: %s" % verdict)
	lines.append("Player wins: %d" % int(rec["wins"]))
	lines.append("Record: %d wins, %d losses, %d ties." % [int(rec["wins"]), int(rec["losses"]), int(rec["ties"])])
	lines.append("")
	for result in series.results:
		var order := "batted second" if bool(result["player_bats_second"]) else "batted first"
		lines.append(
			"Week %d: %s %d, %s %d. %s. %s. %s against %s." % [
				int(result["week"]) + 1,
				Sport.PLAYER_CLUB,
				int(result["player_score"]),
				Sport.OPPONENT_CLUB,
				int(result["opponent_score"]),
				_result_word(str(result["player_result"])),
				order.capitalize(),
				Sport.TACTIC_LABEL[str(result["player_tactic"])],
				Sport.TACTIC_LABEL[str(result["opponent_tactic"])],
			]
		)
	lines.append("")
	lines.append("Roster after drilling (cap %d):" % Sport.STAT_CAP)
	for player in series.player_roster:
		var bits := str(player["player_name"])
		for key in Sport.STATS:
			bits += "  %s %d" % [Sport.STAT_LABEL[key], Sport.get_stat(player, key)]
		lines.append(bits)
	return "\n".join(lines)


func _result_word(kind: String) -> String:
	if kind == "win":
		return "Win"
	if kind == "loss":
		return "Loss"
	return "Tie"


func _club_color(club: String) -> Color:
	if club == Sport.PLAYER_CLUB:
		return COL_HOME
	return COL_AWAY


func _focus_control(control: Control) -> void:
	if control == null or not is_inside_tree():
		return
	if not control.visible:
		return
	control.grab_focus()


class FieldBoard extends Control:
	var active_zone := ""
	var mark_on := false
	var batter_name := ""
	var names: Array = ["", "", "", ""]
	var batting_color := Color("D4652F")
	var fielding_color := Color("2A9D8F")

	func _ready() -> void:
		resized.connect(queue_redraw)

	func present(pa: Dictionary, fielding_names: Array, bat_color: Color, field_color: Color) -> void:
		active_zone = str(pa["zone"])
		mark_on = bool(pa["mark_after"])
		batter_name = str(pa["batter_name"])
		names = fielding_names
		batting_color = bat_color
		fielding_color = field_color
		queue_redraw()

	func _draw() -> void:
		var width := size.x
		var height := size.y
		if width < 20.0 or height < 20.0:
			return
		draw_rect(Rect2(Vector2.ZERO, size), Color("14361C"))
		var font := ThemeDB.fallback_font
		var top := 8.0
		var band_h := (height - 64.0) / 3.0
		if band_h < 8.0:
			return
		var zones := ["far", "mid", "near"]
		var zone_slot := [2, 1, 0]
		var fills := [Color("1A4A28"), Color("2A6B3C"), Color("3D8A50")]
		var titles := ["Far", "Mid", "Near"]
		for i in 3:
			var rect := Rect2(Vector2(10, top + band_h * i), Vector2(width - 20, band_h - 8))
			draw_rect(rect, fills[i])
			if zones[i] == active_zone:
				_stroke(rect, Color("F4EFE6"), 3.0)
			if font != null:
				draw_string(font, rect.position + Vector2(12, 22), titles[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("F4EFE6"))
			var dot := rect.position + Vector2(rect.size.x * 0.68, rect.size.y * 0.58)
			_person(dot, fielding_color, _family(int(zone_slot[i])), font)
			if zones[i] == active_zone:
				var ball := rect.position + Vector2(rect.size.x * 0.42, rect.size.y * 0.48)
				draw_circle(ball, 8, Color("F4EFE6"))
				draw_arc(ball, 9, 0, TAU, 20, Color("1B2430"), 2.0)
		var batter_at := Vector2(width * 0.40, height - 28)
		_person(batter_at, batting_color, _short(batter_name), font)
		draw_rect(Rect2(Vector2(width * 0.30, height - 12), Vector2(width * 0.18, 4)), Color("F4EFE6"))
		var rover_at := Vector2(width * 0.62, height - 36)
		_person(rover_at, fielding_color, _family(3), font)
		if font != null:
			draw_string(font, rover_at + Vector2(18, 4), "Rover", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("F4EFE6"))
		if mark_on:
			var mark_at := Vector2(28, height - 40)
			var diamond := PackedVector2Array([
				mark_at + Vector2(0, -12),
				mark_at + Vector2(12, 0),
				mark_at + Vector2(0, 12),
				mark_at + Vector2(-12, 0),
			])
			draw_colored_polygon(diamond, Color("E2A23A"))
			if font != null:
				draw_string(font, mark_at + Vector2(16, 4), "Mark", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("E2A23A"))

	func _person(at: Vector2, color: Color, caption: String, font: Font) -> void:
		draw_circle(at, 15, Color("0E1A12"))
		draw_circle(at, 12, color)
		if font != null and caption != "":
			draw_string(font, at + Vector2(16, 4), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("F4EFE6"))

	func _family(index: int) -> String:
		if index < 0 or index >= names.size():
			return ""
		return _short(str(names[index]))

	func _short(full_name: String) -> String:
		var parts := full_name.split(" ")
		if parts.is_empty():
			return ""
		return str(parts[parts.size() - 1])

	func _stroke(rect: Rect2, color: Color, thickness: float) -> void:
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, thickness)), color)
		draw_rect(Rect2(rect.position + Vector2(0, rect.size.y - thickness), Vector2(rect.size.x, thickness)), color)
		draw_rect(Rect2(rect.position, Vector2(thickness, rect.size.y)), color)
		draw_rect(Rect2(rect.position + Vector2(rect.size.x - thickness, 0), Vector2(thickness, rect.size.y)), color)
