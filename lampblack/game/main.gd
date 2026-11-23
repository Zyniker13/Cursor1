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
	controls_label.text = "Arrows move    F lamp you face    Space wait    U undo    R restart    click a neighbor or a lamp\n1–8 east    Shift+1–6 west    Ctrl+1–6 north    Alt+1–6 south    F1–F6 attic    F7–F12 cellar    Keypad 1–6 gallery\nShift+F1–F6 court    Alt+F1–F6 nave    Ctrl+F1–F6 cloister    Ctrl+Shift+F1–F6 porch    Alt+Shift+F1–F6 oriel    Alt+Shift+1–6 veil    Ctrl+Alt+1–6 shade    Ctrl+Shift+1–6 screen    Ctrl+Alt+Shift+1–6 glaze    Ctrl+Alt+Shift+F1–F6 mica    Meta+Ctrl+Alt+Shift+F1–F6 baize    Meta+Ctrl+Alt+Shift+1–6 scrim    Meta+Ctrl+Alt+1–6 gauze    Meta+Alt+1–6 voile    Meta+Alt+Shift+1–6 lawn    Meta+Shift+1–6 muslin    Meta+1–6 cambric    Meta+Alt+Shift+F1–F6 holland    Meta+F13–F18 buckram Meta+Ctrl+F13–F18 ticking Meta+Alt+F13–F18 denim"
	controls_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	controls_label.add_theme_font_size_override("font_size", 14)
	controls_label.add_theme_color_override("font_color", MUTED)
	controls_label.position = Vector2(20, 4)
	controls_label.size = Vector2(1240, 100)
	bottom_panel.add_child(controls_label)

	var row_y := 106.0
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
	legend_label.text = "Gold diamond — lamplight, you cannot walk it.    Red diamond — a guard is watching.    Arrow — that guard's next step.    Brass disc — a plate. Step on it in the dark and the nearest guard is called.    Iron cup — a bell. Step on it in the dark and every guard who can reach it is called.    Iron bars — a grate. It stays dark, you may enter it, and a guard cannot.    Stone sill — a lamp lights it, light stops there, and a guard cannot enter or see through it.    Pale sheet — a pane. Light and sight pass through it, and neither you nor a guard can step on it.    Dark cloth — a curtain. A lamp lights it, light passes, sight stops, and a guard can step on it.    Dark louver — a shade. It stays dark, light stops, sight stops, you may step on it, and a guard cannot.    Pale lattice — a screen. A lamp lights it, light passes, sight stops, you may step on it, and a guard cannot.    Ivory sheet, bright cross — a glaze. A lamp lights it, light passes, sight passes while it is lit, you may step on it, and a guard cannot.    Pale gray sheet, dark ring — a mica. It stays dark, light passes, sight passes, you may step on it, and a guard cannot.    Deep green cloth, pale hem — a baize. It stays dark, light stops, sight passes, you may step on it, and a guard cannot.    Pale gold cloth, dark thread — a scrim. A lamp lights it, light stops, sight passes while it is lit, you may step on it only while it is dark, and a guard cannot.    Pale cloth, open stitches — a gauze. A lamp lights it, a second lamp's light passes, sight passes while it is lit, you may step on it only while it is dark, and a guard cannot.    Pale sheer, broken slant — a voile. A lamp lights it, a second lamp's light passes, the early step onto it succeeds, and a guard cannot.    Green field, short blades — a lawn. A lamp lights it, a second lamp's light stops, the early step onto it succeeds, and a guard cannot.    Cream cloth, loose threads — a muslin. The early step fails and a guard can enter.    Pale cloth, a fine cross weave — a cambric. The early step succeeds and a guard can enter.    Warm linen, a fine rib — a holland. The early step succeeds and a guard can enter.    Stiff linen, a close rib — a buckram. The early step fails and a guard can enter.    Close stripes — a ticking. Sight stops and a guard can enter.    Blue twill — a denim. Leave only on the lit cloth. Light and sight pass, the early step succeeds, and a guard can enter."
	legend_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	legend_label.position = Vector2(20, row_y + 2.0)
	legend_label.size = Vector2(1240, 260)
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
	bottom_h = row_y + 270.0

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
		controls_label.size = Vector2(maxf(200.0, view.x - 40.0), 100)
	if legend_label:
		legend_label.size = Vector2(maxf(200.0, view.x - 40.0), 260)
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
	# Ctrl+Alt+F1–F6 without Shift already selects the nave. Meta+Ctrl+Alt+Shift
	# on F1–F6 selected nothing. Claim it before the mica, which rejects Meta.
	var baize := _baize_index(event)
	if baize >= 0:
		return 104 + baize
	# Ctrl+Alt+Shift on F1–F6 is the mica, and only when Meta is not held.
	# That chord has to be claimed before Ctrl+Shift without Alt selects the porch.
	var mica := _mica_index(event)
	if mica >= 0:
		return 98 + mica
	var porch := _porch_index(event)
	if porch >= 0:
		return 62 + porch
	var oriel := _oriel_index(event)
	if oriel >= 0:
		return 68 + oriel
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
	# Meta+F1–F6 without Ctrl, without Alt, and without Shift is the cloister.
	# Meta+Shift+F1–F6 is the porch. Meta+Alt+F1–F6 is the nave.
	# Meta+Ctrl+Alt+Shift+F1–F6 is the baize. Meta+Alt+Shift+F1–F6 without Ctrl
	# selected nothing. Claim it before a function key with no digit falls
	# through. Ctrl stays off this chord. Plain F1–F6 stay the attic.
	var holland := _holland_index(event)
	if holland >= 0:
		return 146 + holland
	# Meta+Ctrl+F1–F6 without Alt and without Shift is the cloister.
	# Meta+Ctrl+Shift+F1–F6 without Alt is the porch.
	# Meta+Ctrl+Alt+F1–F6 without Shift is the nave.
	# Meta+F7–F12 is the cellar. Meta+F13–F18 without Ctrl, without Alt, and
	# without Shift selected nothing. Claim it before a function key with no
	# digit falls through. Meta+Alt+Shift+F1–F6 stays the holland.
	var buckram := _buckram_index(event)
	if buckram >= 0:
		return 152 + buckram
	# Meta+F13–F18 without Ctrl, without Alt, and without Shift is the buckram.
	# Meta+Alt+F13–F18 without Ctrl and without Shift selected nothing, and so
	# did Meta+Shift+F13–F18 without Ctrl and without Alt. Meta+Ctrl+F13–F18
	# without Alt and without Shift selected nothing. Claim it before a
	# function key with no digit falls through. Meta+F7–F12 stays the cellar.
	var ticking := _ticking_index(event)
	if ticking >= 0:
		return 158 + ticking
	# Meta+Ctrl+F13–F18 without Alt and without Shift is the ticking.
	# Meta+F13–F18 without Ctrl, without Alt, and without Shift is the buckram.
	# Meta+Shift+F13–F18 without Ctrl and without Alt selected nothing, and so
	# did Meta+Ctrl+Alt+F13–F18 without Shift. Meta+Alt+F13–F18 without Ctrl
	# and without Shift selected nothing. Claim it before a function key with
	# no digit falls through.
	var denim := _denim_index(event)
	if denim >= 0:
		return 164 + denim
	var cellar := _cellar_index(event)
	if cellar >= 0:
		return 32 + cellar
	var digit := _digit_from_key(event)
	if digit < 0:
		return -1
	# Meta+Ctrl+Alt+Shift on 1–6 selected nothing. Claim it before the glaze,
	# which rejects Meta. Ctrl+Alt+Shift+1–6 without Meta stays the glaze.
	var scrim := _scrim_index(event)
	if scrim >= 0:
		return 110 + scrim
	# Ctrl+Alt+Shift on a digit is the glaze, and only when Meta is not held.
	# That chord has to be claimed before Alt combined with Ctrl selects nothing.
	var glaze := _glaze_index(event)
	if glaze >= 0:
		return 92 + glaze
	# Ctrl+Alt on a digit is the shade, and only when Shift and Meta are not held.
	# That chord has to be claimed before Alt combined with Ctrl selects nothing.
	var shade := _shade_index(event)
	if shade >= 0:
		return 80 + shade
	# Ctrl+Shift on a digit is the screen, and only when Alt and Meta are not held.
	# That chord has to be claimed before Ctrl without Shift selects the north wing.
	var screen := _screen_index(event)
	if screen >= 0:
		return 86 + screen
	# Alt+Shift on a digit is the veil, and only when Ctrl and Meta are not held.
	# That chord has to be claimed before Alt combined with Shift selects nothing.
	var veil := _veil_index(event)
	if veil >= 0:
		return 74 + veil
	# Meta+Ctrl+Alt on 1–6 without Shift selected nothing, because Alt combined
	# with Ctrl returns -1. Claim it before that fallthrough. Shift stays the
	# scrim. Ctrl+Alt without Meta and without Shift stays the shade.
	var gauze := _gauze_index(event)
	if gauze >= 0:
		return 116 + gauze
	# Ctrl+Alt+Shift+1–6 is the glaze. Meta+Alt+1–6 without Ctrl and without
	# Shift selected nothing. Claim it before the fallthrough. Ctrl stays off
	# this chord, and Shift stays off it.
	var voile := _voile_index(event)
	if voile >= 0:
		return 122 + voile
	# Meta+Ctrl+1–6 without Alt and without Shift is the north wing. Meta+Alt+Shift
	# on a digit selected nothing. Claim it before the fallthrough. Ctrl stays off
	# this chord. Meta+Alt without Shift stays the voile.
	var lawn := _lawn_index(event)
	if lawn >= 0:
		return 128 + lawn
	# Meta+Ctrl+Shift+1–6 without Alt is the north wing. Meta+Shift on a digit,
	# without Ctrl and without Alt, is the muslin. Meta+Alt+Shift stays the lawn.
	var muslin := _muslin_index(event)
	if muslin >= 0:
		return 134 + muslin
	# Meta+1–6 without Ctrl, without Alt, and without Shift selects the north
	# wing, because Meta alone falls through with Ctrl. Every other Meta digit
	# chord is already a wing or is locked to that north wing. No Meta digit
	# chord selects nothing. Claim Meta alone before the fallthrough. Ctrl+1–6
	# stays the north wing. Meta+Shift stays the muslin. Meta+Ctrl and
	# Meta+Ctrl+Shift stay the north wing. Meta+Alt+Shift stays the lawn.
	var cambric := _cambric_index(event)
	if cambric >= 0:
		return 140 + cambric
	# Alt alone is the south wing. Alt combined with Ctrl, Meta, or a leftover
	# Shift selects nothing, so the other wings stay where they were.
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


func _cambric_index(event: InputEventKey) -> int:
	if event.ctrl_pressed or event.alt_pressed or event.shift_pressed or not event.meta_pressed or _is_shifted_digit(event.keycode):
		return -1
	var digit := _digit_from_key(event)
	if digit < 0 or digit > 5:
		return -1
	return digit


func _muslin_index(event: InputEventKey) -> int:
	if event.ctrl_pressed or event.alt_pressed or not event.meta_pressed or not event.shift_pressed or _is_shifted_digit(event.keycode):
		return -1
	var digit := _digit_from_key(event)
	if digit < 0 or digit > 5:
		return -1
	return digit


func _lawn_index(event: InputEventKey) -> int:
	if event.ctrl_pressed or not event.meta_pressed or not event.alt_pressed or not event.shift_pressed or _is_shifted_digit(event.keycode):
		return -1
	var digit := _digit_from_key(event)
	if digit < 0 or digit > 5:
		return -1
	return digit


func _voile_index(event: InputEventKey) -> int:
	if event.ctrl_pressed or event.shift_pressed or not event.meta_pressed or not event.alt_pressed or _is_shifted_digit(event.keycode):
		return -1
	var digit := _digit_from_key(event)
	if digit < 0 or digit > 5:
		return -1
	return digit


func _gauze_index(event: InputEventKey) -> int:
	if not event.ctrl_pressed or not event.alt_pressed or not event.meta_pressed or event.shift_pressed or _is_shifted_digit(event.keycode):
		return -1
	var digit := _digit_from_key(event)
	if digit < 0 or digit > 5:
		return -1
	return digit


func _scrim_index(event: InputEventKey) -> int:
	if not event.ctrl_pressed or not event.alt_pressed or not event.shift_pressed or not event.meta_pressed:
		return -1
	var digit := _digit_from_key(event)
	if digit < 0 or digit > 5:
		return -1
	return digit


func _baize_index(event: InputEventKey) -> int:
	if not event.ctrl_pressed or not event.alt_pressed or not event.shift_pressed or not event.meta_pressed:
		return -1
	var key := event.physical_keycode
	if key < KEY_F1 or key > KEY_F6:
		key = event.keycode
	if key < KEY_F1 or key > KEY_F6:
		return -1
	return int(key) - int(KEY_F1)


func _mica_index(event: InputEventKey) -> int:
	if not event.ctrl_pressed or not event.alt_pressed or not event.shift_pressed or event.meta_pressed:
		return -1
	var key := event.physical_keycode
	if key < KEY_F1 or key > KEY_F6:
		key = event.keycode
	if key < KEY_F1 or key > KEY_F6:
		return -1
	return int(key) - int(KEY_F1)


func _glaze_index(event: InputEventKey) -> int:
	if not event.ctrl_pressed or not event.alt_pressed or not event.shift_pressed or event.meta_pressed:
		return -1
	var digit := _digit_from_key(event)
	if digit < 0 or digit > 5:
		return -1
	return digit


func _screen_index(event: InputEventKey) -> int:
	if not event.ctrl_pressed or event.alt_pressed or event.meta_pressed or not event.shift_pressed:
		return -1
	var digit := _digit_from_key(event)
	if digit < 0 or digit > 5:
		return -1
	return digit


func _shade_index(event: InputEventKey) -> int:
	if not event.ctrl_pressed or not event.alt_pressed or event.meta_pressed or event.shift_pressed or _is_shifted_digit(event.keycode):
		return -1
	var digit := _digit_from_key(event)
	if digit < 0 or digit > 5:
		return -1
	return digit


func _veil_index(event: InputEventKey) -> int:
	if event.ctrl_pressed or event.meta_pressed or not event.alt_pressed or not event.shift_pressed:
		return -1
	var digit := _digit_from_key(event)
	if digit < 0 or digit > 5:
		return -1
	return digit


func _oriel_index(event: InputEventKey) -> int:
	if event.ctrl_pressed or event.meta_pressed or not event.alt_pressed or not event.shift_pressed:
		return -1
	var key := event.physical_keycode
	if key < KEY_F1 or key > KEY_F6:
		key = event.keycode
	if key < KEY_F1 or key > KEY_F6:
		return -1
	return int(key) - int(KEY_F1)


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
	if not event.shift_pressed or event.ctrl_pressed or event.meta_pressed or event.alt_pressed:
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


func _holland_index(event: InputEventKey) -> int:
	if event.ctrl_pressed or not event.meta_pressed or not event.alt_pressed or not event.shift_pressed:
		return -1
	var key := event.physical_keycode
	if key < KEY_F1 or key > KEY_F6:
		key = event.keycode
	if key < KEY_F1 or key > KEY_F6:
		return -1
	return int(key) - int(KEY_F1)


func _buckram_index(event: InputEventKey) -> int:
	if event.ctrl_pressed or event.alt_pressed or event.shift_pressed or not event.meta_pressed:
		return -1
	var key := event.physical_keycode
	if key < KEY_F13 or key > KEY_F18:
		key = event.keycode
	if key < KEY_F13 or key > KEY_F18:
		return -1
	return int(key) - int(KEY_F13)


func _ticking_index(event: InputEventKey) -> int:
	if not event.meta_pressed or not event.ctrl_pressed or event.alt_pressed or event.shift_pressed:
		return -1
	var key := event.physical_keycode
	if key < KEY_F13 or key > KEY_F18:
		key = event.keycode
	if key < KEY_F13 or key > KEY_F18:
		return -1
	return int(key) - int(KEY_F13)


func _denim_index(event: InputEventKey) -> int:
	if not event.meta_pressed or not event.alt_pressed or event.ctrl_pressed or event.shift_pressed:
		return -1
	var key := event.physical_keycode
	if key < KEY_F13 or key > KEY_F18:
		key = event.keycode
	if key < KEY_F13 or key > KEY_F18:
		return -1
	return int(key) - int(KEY_F13)


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
	if kind == Rules.Tile.PANE:
		draw_rect(rect, GROUT)
		var sheet := Rect2(rect.position + Vector2(2, 2), rect.size - Vector2(4, 4))
		_draw_pane(sheet)
		if hover == cell:
			draw_rect(sheet, Color(1, 1, 1, 0.08), false, 2.0)
		return
	var floor_color := FLOOR_ALT if (x + y) % 2 == 0 else FLOOR
	draw_rect(rect, GROUT)
	var inset := Rect2(rect.position + Vector2(2, 2), rect.size - Vector2(4, 4))
	if lit.has(cell) and kind != Rules.Tile.GRATE and kind != Rules.Tile.SHADE and kind != Rules.Tile.BAIZE:
		floor_color = LIT
	draw_rect(inset, floor_color)
	if kind == Rules.Tile.GLAZE:
		_draw_glaze_sheet(inset)
	if kind == Rules.Tile.MICA:
		_draw_mica(inset)
	if kind == Rules.Tile.BAIZE:
		_draw_baize(inset)
	if kind == Rules.Tile.SCRIM:
		_draw_scrim_cloth(inset)
	if kind == Rules.Tile.GAUZE:
		_draw_gauze_cloth(inset)
	if kind == Rules.Tile.VOILE:
		_draw_voile_cloth(inset)
	if kind == Rules.Tile.LAWN:
		_draw_lawn_field(inset)
	if kind == Rules.Tile.MUSLIN:
		_draw_muslin_cloth(inset)
	if kind == Rules.Tile.CAMBRIC:
		_draw_cambric_cloth(inset)
	if kind == Rules.Tile.HOLLAND:
		_draw_holland_cloth(inset)
	if kind == Rules.Tile.BUCKRAM:
		_draw_buckram_cloth(inset)
	if kind == Rules.Tile.TICKING:
		_draw_ticking_cloth(inset)
	if kind == Rules.Tile.DENIM:
		_draw_denim_cloth(inset)
	if kind == Rules.Tile.SILL:
		_draw_sill(inset)
	if kind == Rules.Tile.CURTAIN:
		_draw_curtain(inset)
	if kind == Rules.Tile.SHADE:
		_draw_shade(inset)
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
	if lit.has(cell) and kind != Rules.Tile.GRATE and kind != Rules.Tile.SHADE and kind != Rules.Tile.BAIZE:
		draw_colored_polygon(_diamond(center, tile * 0.34, tile * 0.34), LIGHT)
	if kind == Rules.Tile.SCREEN:
		_draw_screen(inset)
	if kind == Rules.Tile.PLATE:
		_draw_plate(center)
	if kind == Rules.Tile.BELL:
		_draw_bell(center)
	if kind == Rules.Tile.GRATE:
		_draw_grate(inset)
	if watched.has(cell):
		draw_colored_polygon(_diamond(center, tile * 0.26, tile * 0.26), WATCH)
		draw_polyline(_diamond_loop(center, tile * 0.3, tile * 0.3), Color(1, 0.55, 0.45, 0.9), 1.5)
	if kind == Rules.Tile.GLAZE:
		_draw_glaze_cross(inset)
	if kind == Rules.Tile.SCRIM:
		_draw_scrim_thread(inset)
	if kind == Rules.Tile.GAUZE:
		_draw_gauze_stitches(inset)
	if kind == Rules.Tile.VOILE:
		_draw_voile_slant(inset)
	if kind == Rules.Tile.LAWN:
		_draw_lawn_blades(inset)
	if kind == Rules.Tile.MUSLIN:
		_draw_muslin_threads(inset)
	if kind == Rules.Tile.CAMBRIC:
		_draw_cambric_weave(inset)
	if kind == Rules.Tile.HOLLAND:
		_draw_holland_rib(inset)
	if kind == Rules.Tile.BUCKRAM:
		_draw_buckram_rib(inset)
	if kind == Rules.Tile.TICKING:
		_draw_ticking_stripes(inset)
	if kind == Rules.Tile.DENIM:
		_draw_denim_twill(inset)
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


func _draw_denim_cloth(inset: Rect2) -> void:
	# Indigo twill. The diagonal is drawn after the lamp diamond.
	draw_rect(inset, Color("35527a"))


func _draw_denim_twill(inset: Rect2) -> void:
	# Long diagonals, not ticking's vertical stripes and not buckram's short ribs.
	var ink := Color("d5e2f2")
	var thick := maxf(1.5, tile * 0.035)
	for i in 4:
		var start := inset.position + Vector2(inset.size.x * (0.08 + i * 0.24), inset.size.y * 0.92)
		draw_line(start, start + Vector2(inset.size.x * 0.22, -inset.size.y * 0.72), ink, thick)


func _draw_ticking_cloth(inset: Rect2) -> void:
	# Cream ground. The close stripes are drawn after the lamp diamond.
	draw_rect(inset, Color("efe6d4"))


func _draw_ticking_stripes(inset: Rect2) -> void:
	# Full-height stripes, closer than a buckram's short ribs and not holland's horizontals.
	var ink := Color("243044")
	var thick := maxf(1.6, tile * 0.045)
	for i in 4:
		var x := inset.position.x + inset.size.x * (0.18 + i * 0.2)
		draw_line(Vector2(x, inset.position.y + inset.size.y * 0.08), Vector2(x, inset.position.y + inset.size.y * 0.92), ink, thick)


func _draw_buckram_cloth(inset: Rect2) -> void:
	# Stiff linen. The close ribs are drawn after the lamp diamond.
	draw_rect(inset, Color("c8b48a"))


func _draw_buckram_rib(inset: Rect2) -> void:
	# Short vertical ribs. They do not span the tile, and they are not holland's horizontal ribs.
	var ink := Color("5c4630")
	var thick := maxf(1.4, tile * 0.03)
	var ribs: Array[Vector2] = [Vector2(0.28, 0.14), Vector2(0.46, 0.40), Vector2(0.68, 0.18), Vector2(0.34, 0.52)]
	for mark in ribs:
		var top := inset.position + Vector2(inset.size.x * mark.x, inset.size.y * mark.y)
		draw_line(top, top + Vector2(0, inset.size.y * 0.22), ink, thick)


func _draw_holland_cloth(inset: Rect2) -> void:
	# Warm linen. The short ribs are drawn after the lamp diamond.
	draw_rect(inset, Color("e7dcc8"))


func _draw_holland_rib(inset: Rect2) -> void:
	# Short horizontal ribs. They do not span the tile, and they are not a cross weave.
	var ink := Color("6b5b45")
	var thick := maxf(1.4, tile * 0.03)
	var ribs: Array[Vector2] = [Vector2(0.14, 0.28), Vector2(0.40, 0.46), Vector2(0.18, 0.68), Vector2(0.52, 0.34)]
	for mark in ribs:
		var left := inset.position + Vector2(inset.size.x * mark.x, inset.size.y * mark.y)
		draw_line(left, left + Vector2(inset.size.x * 0.22, 0), ink, thick)


func _draw_cambric_cloth(inset: Rect2) -> void:
	# Pale cloth. The short cross weave is drawn after the lamp diamond.
	draw_rect(inset, Color("d5dde8"))


func _draw_cambric_weave(inset: Rect2) -> void:
	# Short diagonals in both directions. They do not span the tile.
	var ink := Color("3e5166")
	var thick := maxf(1.4, tile * 0.03)
	var down: Array[Vector2] = [Vector2(0.16, 0.28), Vector2(0.48, 0.58), Vector2(0.22, 0.70), Vector2(0.58, 0.22)]
	for mark in down:
		var start := inset.position + Vector2(inset.size.x * mark.x, inset.size.y * mark.y)
		draw_line(start, start + Vector2(inset.size.x * 0.16, inset.size.y * 0.16), ink, thick)
	var up: Array[Vector2] = [Vector2(0.30, 0.22), Vector2(0.62, 0.48)]
	for mark in up:
		var start := inset.position + Vector2(inset.size.x * mark.x, inset.size.y * mark.y)
		draw_line(start, start + Vector2(inset.size.x * 0.16, -inset.size.y * 0.16), ink, thick)


func _draw_muslin_cloth(inset: Rect2) -> void:
	# Cream cloth. The loose threads are drawn after the lamp diamond.
	draw_rect(inset, Color("efe6d6"))


func _draw_muslin_threads(inset: Rect2) -> void:
	# A few short threads. They do not span the tile, and they are not a grid or a hem.
	var ink := Color("b7a48a")
	var thick := maxf(1.4, tile * 0.03)
	var across: Array[Vector2] = [Vector2(0.18, 0.34), Vector2(0.46, 0.62)]
	var down: Array[Vector2] = [Vector2(0.38, 0.16), Vector2(0.70, 0.42)]
	for mark in across:
		var left := inset.position + Vector2(inset.size.x * mark.x, inset.size.y * mark.y)
		draw_line(left, left + Vector2(inset.size.x * 0.22, 0), ink, thick)
	for mark in down:
		var top := inset.position + Vector2(inset.size.x * mark.x, inset.size.y * mark.y)
		draw_line(top, top + Vector2(0, inset.size.y * 0.24), ink, thick)


func _draw_lawn_field(inset: Rect2) -> void:
	# Green field. The short blades are drawn after the lamp diamond.
	draw_rect(inset, Color("3d7a4e"))


func _draw_lawn_blades(inset: Rect2) -> void:
	# A few short vertical strokes. They do not span the tile, and they are not a hem or a grid.
	var ink := Color("d7e2c8")
	var thick := maxf(1.4, tile * 0.035)
	var marks: Array[Vector2] = [
		Vector2(0.18, 0.30),
		Vector2(0.34, 0.20),
		Vector2(0.52, 0.38),
		Vector2(0.70, 0.24),
		Vector2(0.84, 0.42),
	]
	var lengths: Array[float] = [0.32, 0.26, 0.34, 0.28, 0.24]
	for i in marks.size():
		var top := inset.position + Vector2(inset.size.x * marks[i].x, inset.size.y * marks[i].y)
		var bot := top + Vector2(0, inset.size.y * lengths[i])
		draw_line(top, bot, ink, thick)


func _draw_voile_cloth(inset: Rect2) -> void:
	# Pale sheer. The broken slant is drawn after the lamp diamond.
	draw_rect(inset, Color("f7f4ef"))


func _draw_voile_slant(inset: Rect2) -> void:
	# Two short slants. They do not meet, and they do not cross the tile.
	var ink := Color("8d8478")
	var thick := maxf(1.4, tile * 0.03)
	var a := inset.position + Vector2(inset.size.x * 0.14, inset.size.y * 0.64)
	var b := inset.position + Vector2(inset.size.x * 0.40, inset.size.y * 0.40)
	var c := inset.position + Vector2(inset.size.x * 0.56, inset.size.y * 0.70)
	var d := inset.position + Vector2(inset.size.x * 0.82, inset.size.y * 0.46)
	draw_line(a, b, ink, thick)
	draw_line(c, d, ink, thick)


func _draw_gauze_cloth(inset: Rect2) -> void:
	# Pale sheer cloth. The open stitches are drawn after the lamp diamond.
	draw_rect(inset, Color("f4f7f2"))


func _draw_gauze_stitches(inset: Rect2) -> void:
	# Short offset stitches. They do not span the tile and do not form a grid.
	var stitch := Color("5c6b62")
	var thick := maxf(1.4, tile * 0.03)
	var spans := [
		[0.08, 0.28, 0.32],
		[0.46, 0.48, 0.26],
		[0.16, 0.70, 0.30],
	]
	for span in spans:
		var x := inset.position.x + inset.size.x * float(span[0])
		var y := inset.position.y + inset.size.y * float(span[1]) - thick * 0.5
		var w := inset.size.x * float(span[2])
		draw_rect(Rect2(Vector2(x, y), Vector2(w, thick)), stitch)


func _draw_scrim_cloth(inset: Rect2) -> void:
	# Pale gold cloth. The dark thread is drawn after the lamp diamond.
	draw_rect(inset, Color("f3e6c4"))


func _draw_scrim_thread(inset: Rect2) -> void:
	# One dark horizontal thread. Not a hem, not a ring, and not a cross.
	var thread := maxf(1.5, tile * 0.045)
	var y := inset.position.y + inset.size.y * 0.5 - thread * 0.5
	draw_rect(Rect2(Vector2(inset.position.x, y), Vector2(inset.size.x, thread)), Color("2c2416"))


func _draw_baize(inset: Rect2) -> void:
	# Deep green cloth, with a thin pale hem. Not the mica ring and not the glaze cross.
	draw_rect(inset, Color("1b4332"))
	var hem := maxf(1.5, tile * 0.045)
	var pale := Color("d7e2c8")
	draw_rect(Rect2(inset.position, Vector2(inset.size.x, hem)), pale)
	draw_rect(Rect2(Vector2(inset.position.x, inset.end.y - hem), Vector2(inset.size.x, hem)), pale)
	draw_rect(Rect2(inset.position, Vector2(hem, inset.size.y)), pale)
	draw_rect(Rect2(Vector2(inset.end.x - hem, inset.position.y), Vector2(hem, inset.size.y)), pale)


func _draw_mica(inset: Rect2) -> void:
	# Pale gray, with a thin dark ring. Not the glaze cross, the screen lattice,
	# the pane gleam, or the shade louver.
	draw_rect(inset, Color("c8c6c2"))
	var center := inset.position + inset.size * 0.5
	var radius := minf(inset.size.x, inset.size.y) * 0.28
	draw_arc(center, radius, 0.0, TAU, 40, Color("2a2826"), maxf(1.6, tile * 0.035), true)


func _draw_glaze_sheet(inset: Rect2) -> void:
	# Ivory, not the pane's blue sheet and not the screen's bone lattice.
	draw_rect(inset, Color("e7f3ea"))


func _draw_glaze_cross(inset: Rect2) -> void:
	var bright := Color("fff6a8")
	var arm := maxf(1.6, tile * 0.03)
	var cx := inset.position.x + inset.size.x * 0.5
	var cy := inset.position.y + inset.size.y * 0.5
	draw_rect(Rect2(Vector2(inset.position.x + inset.size.x * 0.06, cy - arm * 0.5), Vector2(inset.size.x * 0.88, arm)), bright)
	draw_rect(Rect2(Vector2(cx - arm * 0.5, inset.position.y + inset.size.y * 0.06), Vector2(arm, inset.size.y * 0.88)), bright)


func _draw_screen(inset: Rect2) -> void:
	var bone := Color("f4efe4")
	var pale := Color("e6d8c4")
	var joint := Color("fbf6ee")
	var frame := maxf(2.0, tile * 0.05)
	draw_rect(Rect2(inset.position, Vector2(inset.size.x, frame)), bone)
	draw_rect(Rect2(Vector2(inset.position.x, inset.end.y - frame), Vector2(inset.size.x, frame)), bone)
	draw_rect(Rect2(inset.position, Vector2(frame, inset.size.y)), bone)
	draw_rect(Rect2(Vector2(inset.end.x - frame, inset.position.y), Vector2(frame, inset.size.y)), bone)
	var bar := maxf(1.8, tile * 0.04)
	for i in [1, 2]:
		var x := inset.position.x + inset.size.x * float(i) / 3.0 - bar * 0.5
		var y := inset.position.y + inset.size.y * float(i) / 3.0 - bar * 0.5
		draw_rect(Rect2(Vector2(x, inset.position.y), Vector2(bar, inset.size.y)), pale)
		draw_rect(Rect2(Vector2(inset.position.x, y), Vector2(inset.size.x, bar)), pale)
	for ix in [1, 2]:
		for iy in [1, 2]:
			var cx := inset.position.x + inset.size.x * float(ix) / 3.0
			var cy := inset.position.y + inset.size.y * float(iy) / 3.0
			draw_rect(Rect2(Vector2(cx - bar, cy - bar), Vector2(bar * 2.0, bar * 2.0)), joint)


func _draw_shade(inset: Rect2) -> void:
	var field := Color("0c0a09")
	var blade := Color("322c26")
	var lip := Color("9a8d7c")
	var shadow := Color("161310")
	draw_rect(inset, field)
	var count := 4
	for i in count:
		var top := inset.position.y + inset.size.y * (0.1 + float(i) * 0.22)
		var height := maxf(4.0, inset.size.y * 0.1)
		var lean := inset.size.y * 0.05
		var left := inset.position.x + inset.size.x * 0.07
		var right := inset.end.x - inset.size.x * 0.07
		draw_colored_polygon(PackedVector2Array([
			Vector2(left, top),
			Vector2(right, top + lean),
			Vector2(right, top + lean + height),
			Vector2(left, top + height * 0.42),
		]), blade)
		draw_line(Vector2(left, top), Vector2(right, top + lean), lip, maxf(1.2, tile * 0.028))
		draw_line(Vector2(left, top + height * 0.42), Vector2(right, top + lean + height), shadow, maxf(1.0, tile * 0.02))


func _draw_curtain(inset: Rect2) -> void:
	var cloth := Color("2c1420")
	var deep := Color("14080e")
	var wine := Color("6a3050")
	var hem := Color("8a4870")
	draw_rect(inset, cloth)
	var bands := 3
	for i in bands:
		var band_w := inset.size.x * 0.16
		var x := inset.position.x + inset.size.x * (float(i) + 0.55) / float(bands) - band_w * 0.5
		draw_rect(Rect2(Vector2(x, inset.position.y), Vector2(band_w, inset.size.y)), deep if i % 2 == 0 else wine)
	var sag := inset.position.y + inset.size.y * 0.72
	draw_colored_polygon(PackedVector2Array([
		Vector2(inset.position.x, sag),
		Vector2(inset.position.x + inset.size.x * 0.28, inset.end.y),
		Vector2(inset.position.x + inset.size.x * 0.5, sag + inset.size.y * 0.1),
		Vector2(inset.position.x + inset.size.x * 0.74, inset.end.y),
		Vector2(inset.end.x, sag),
		inset.end,
		Vector2(inset.position.x, inset.end.y),
	]), hem)
	draw_line(
		Vector2(inset.position.x + inset.size.x * 0.08, inset.position.y + inset.size.y * 0.18),
		Vector2(inset.end.x - inset.size.x * 0.08, inset.position.y + inset.size.y * 0.18),
		wine,
		maxf(2.0, tile * 0.04)
	)


func _draw_pane(inset: Rect2) -> void:
	var glass := Color("d7e6ee")
	var edge := Color("7f9aab")
	var sheen := Color("f7fbfd")
	draw_rect(inset, glass)
	draw_rect(inset, edge, false, maxf(2.0, tile * 0.04))
	var gleam := Rect2(
		inset.position + Vector2(inset.size.x * 0.18, inset.size.y * 0.12),
		Vector2(maxf(3.0, inset.size.x * 0.14), inset.size.y * 0.76)
	)
	draw_rect(gleam, sheen)


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
