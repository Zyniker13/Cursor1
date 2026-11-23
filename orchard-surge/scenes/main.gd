extends Node2D

## View and input for Orchard Surge. Combat, light, planting, and damage live in OrchardSim.

const Sim = preload("res://sim/orchard_sim.gd")
const Catalog = preload("res://sim/plant_catalog.gd")
const Tooltip = preload("res://ui/plant_tooltip.gd")

const ORIGIN := Vector2(16, 76)
const CARD_W := 352.0
const CARD_H := 340.0
const CARD_GAP := 6.0
const CARD_LEFT := 752.0
const CARD_TOP := 72.0

const KIND_COLOR := [
	Color(0.561, 0.859, 0.333, 1),
	Color(0.243, 0.561, 0.333, 1),
	Color(1.0, 0.784, 0.341, 1),
	Color(0.878, 0.478, 0.184, 1),
	Color(0.93, 0.34, 0.2, 1),
	Color(0.737, 0.373, 0.478, 1),
	Color(0.98, 0.86, 0.42, 1),
	Color(0.45, 0.78, 0.86, 1),
	Color(0.72, 0.64, 0.86, 1),
	Color(0.55, 0.84, 0.78, 1),
	Color(0.71, 0.48, 0.30, 1),
	Color(0.62, 0.68, 0.74, 1),
	Color(0.86, 0.70, 0.42, 1),
	Color(0.48, 0.40, 0.66, 1),
	Color(0.86, 0.82, 0.72, 1),
	Color(0.64, 0.50, 0.38, 1),
	Color(0.42, 0.36, 0.58, 1),
	Color(0.28, 0.52, 0.46, 1),
	Color(0.62, 0.36, 0.52, 1),
	Color(0.86, 0.82, 0.70, 1),
	Color(0.72, 0.82, 0.76, 1),
	Color(0.84, 0.80, 0.68, 1),
	Color(0.62, 0.70, 0.42, 1),
	Color(0.93, 0.91, 0.84, 1),
	Color(0.78, 0.72, 0.52, 1),
	Color(0.72, 0.34, 0.16, 1),
	Color(0.70, 0.16, 0.18, 1),
	Color(0.74, 0.84, 0.78, 1),
	Color(0.86, 0.80, 0.62, 1),
	Color(0.78, 0.86, 0.92, 1),
	Color(0.96, 0.94, 0.88, 1),
	Color(0.36, 0.42, 0.62, 1),
	Color(0.94, 0.96, 0.98, 1),
	Color(0.96, 0.93, 0.82, 1),
	Color(0.55, 0.16, 0.22, 1),
	Color(0.36, 0.22, 0.52, 1),
	Color(0.18, 0.18, 0.20, 1),
]

var sim = null
var run_seed := 1
var selected := 0
var accumulator := 0.0
var motes: Array = []
var reject_left := 0.0
var plant_card_boxes: Array = []
var card_panels: Array = []
var card_styles: Array = []

var title_label: Label
var phase_label: Label
var hp_label: Label
var seeds_label: Label
var seed_label: Label
var hint_label: Label
var reject_label: Label
var hp_fill: ColorRect
var overlay: Control
var outcome_label: Label
var _booted := false


func _ready() -> void:
	if _booted:
		return
	_booted = true
	_bind_keys()
	sim = Sim.new(run_seed)
	_build_hud()
	_refresh_hud()


func _process(delta: float) -> void:
	if sim == null:
		return
	var capped := minf(delta, 0.1)
	_update_motes(capped)
	if reject_left > 0.0:
		reject_left -= capped
	accumulator += capped
	var steps := 0
	while accumulator >= Sim.DT and steps < 5:
		accumulator -= Sim.DT
		sim.step(_command())
		_consume_events()
		steps += 1
	_refresh_hud()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.is_action_pressed("restart"):
			_restart()
		elif event.is_action_pressed("plant_1"):
			selected = 0
		elif event.is_action_pressed("plant_2"):
			selected = 1
		elif event.is_action_pressed("plant_3"):
			selected = 2
		elif event.is_action_pressed("plant_4"):
			selected = 3
		elif event.is_action_pressed("plant_5"):
			selected = 4
		elif event.is_action_pressed("plant_6"):
			selected = 5
		elif event.is_action_pressed("plant_7"):
			selected = 6
		elif event.is_action_pressed("plant_8"):
			selected = 7
		elif event.is_action_pressed("plant_9"):
			selected = 8
		elif event.is_action_pressed("plant_0"):
			selected = 9
		elif event.is_action_pressed("plant_b"):
			selected = 10
		elif event.is_action_pressed("plant_c"):
			selected = 11
		elif event.is_action_pressed("plant_e"):
			selected = 12
		elif event.is_action_pressed("plant_f"):
			selected = Catalog.SHADE
		elif event.is_action_pressed("plant_g"):
			selected = Catalog.COWL
		elif event.is_action_pressed("plant_h"):
			selected = Catalog.HOOD
		elif event.is_action_pressed("plant_i"):
			selected = Catalog.CLOAK
		elif event.is_action_pressed("plant_j"):
			selected = Catalog.CAPE
		elif event.is_action_pressed("plant_k"):
			selected = Catalog.SHAWL
		elif event.is_action_pressed("plant_l"):
			selected = Catalog.STOLE
		elif event.is_action_pressed("plant_m"):
			selected = Catalog.MANTLE
		elif event.is_action_pressed("plant_n"):
			selected = Catalog.TIPPET
		elif event.is_action_pressed("plant_o"):
			selected = Catalog.WIMPLE
		elif event.is_action_pressed("plant_p"):
			selected = Catalog.ALB
		elif event.is_action_pressed("plant_q"):
			selected = Catalog.AMICE
		elif event.is_action_pressed("plant_t"):
			selected = Catalog.ORPHREY
		elif event.is_action_pressed("plant_u"):
			selected = Catalog.MANIPLE
		elif event.is_action_pressed("plant_v"):
			selected = Catalog.CHASUBLE
		elif event.is_action_pressed("plant_x"):
			selected = Catalog.DALMATIC
		elif event.is_action_pressed("plant_y"):
			selected = Catalog.TUNICLE
		elif event.is_action_pressed("plant_z"):
			selected = Catalog.ROCHET
		elif event.is_action_pressed("plant_comma"):
			selected = Catalog.COPE
		elif event.is_action_pressed("plant_period"):
			selected = Catalog.SURPLICE
		elif event.is_action_pressed("plant_slash"):
			selected = Catalog.COTTA
		elif event.is_action_pressed("plant_semicolon"):
			selected = Catalog.CHIMERE
		elif event.is_action_pressed("plant_apostrophe"):
			selected = Catalog.MOZZETTA
		elif event.is_action_pressed("plant_backslash"):
			selected = Catalog.BIRETTA
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if sim != null and sim.outcome == Sim.OUTCOME_RUNNING and sim.phase == Sim.PHASE_PLANT:
			var cell := _mouse_cell()
			if cell.x >= 0:
				_pending_kind = selected
				_pending_cell = cell


var _pending_kind := -1
var _pending_cell := Vector2i(-1, -1)


func _command():
	var cmd = Sim.Command.new()
	var move := _movement()
	cmd.move_x = move.x
	cmd.move_y = move.y
	if _pending_kind >= 0:
		cmd.plant_kind = _pending_kind
		cmd.tile = _pending_cell
		_pending_kind = -1
	return cmd


func tooltip_label_texts(kind: int) -> PackedStringArray:
	var lines := PackedStringArray()
	if kind < 0 or kind >= plant_card_boxes.size():
		return lines
	var box: Node = plant_card_boxes[kind]
	for child in box.get_children():
		if child is Label and str(child.name).begins_with("Stat"):
			lines.append((child as Label).text)
	return lines


func _restart() -> void:
	run_seed += 1
	if run_seed > 999983:
		run_seed = 1
	sim = Sim.new(run_seed)
	motes.clear()
	accumulator = 0.0
	reject_left = 0.0
	_pending_kind = -1
	overlay.visible = false
	_refresh_hud()
	queue_redraw()


func _bind_keys() -> void:
	_bind("move_left", [KEY_A, KEY_LEFT])
	_bind("move_right", [KEY_D, KEY_RIGHT])
	_bind("move_up", [KEY_W, KEY_UP])
	_bind("move_down", [KEY_S, KEY_DOWN])
	_bind("plant_1", [KEY_1, KEY_KP_1])
	_bind("plant_2", [KEY_2, KEY_KP_2])
	_bind("plant_3", [KEY_3, KEY_KP_3])
	_bind("plant_4", [KEY_4, KEY_KP_4])
	_bind("plant_5", [KEY_5, KEY_KP_5])
	_bind("plant_6", [KEY_6, KEY_KP_6])
	_bind("plant_7", [KEY_7, KEY_KP_7])
	_bind("plant_8", [KEY_8, KEY_KP_8])
	_bind("plant_9", [KEY_9, KEY_KP_9])
	_bind("plant_0", [KEY_0, KEY_KP_0])
	_bind("plant_b", [KEY_B])
	_bind("plant_c", [KEY_C])
	_bind("plant_e", [KEY_E])
	_bind("plant_f", [KEY_F])
	_bind("plant_g", [KEY_G])
	_bind("plant_h", [KEY_H])
	_bind("plant_i", [KEY_I])
	_bind("plant_j", [KEY_J])
	_bind("plant_k", [KEY_K])
	_bind("plant_l", [KEY_L])
	_bind("plant_m", [KEY_M])
	_bind("plant_n", [KEY_N])
	_bind("plant_o", [KEY_O])
	_bind("plant_p", [KEY_P])
	_bind("plant_q", [KEY_Q])
	_bind("plant_t", [KEY_T])
	_bind("plant_u", [KEY_U])
	_bind("plant_v", [KEY_V])
	_bind("plant_x", [KEY_X])
	_bind("plant_y", [KEY_Y])
	_bind("plant_z", [KEY_Z])
	_bind("plant_comma", [KEY_COMMA])
	_bind("plant_period", [KEY_PERIOD])
	_bind("plant_slash", [KEY_SLASH])
	_bind("plant_semicolon", [KEY_SEMICOLON])
	_bind("plant_apostrophe", [KEY_APOSTROPHE])
	_bind("plant_backslash", [KEY_BACKSLASH])
	_bind("restart", [KEY_R])


func _bind(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	else:
		InputMap.action_erase_events(action)
	for keycode in keys:
		var ev := InputEventKey.new()
		ev.keycode = keycode
		ev.physical_keycode = keycode
		InputMap.action_add_event(action, ev)


func _movement() -> Vector2i:
	var x := 0
	var y := 0
	if InputMap.has_action("move_left") and Input.is_action_pressed("move_left"):
		x -= 1
	if InputMap.has_action("move_right") and Input.is_action_pressed("move_right"):
		x += 1
	if InputMap.has_action("move_up") and Input.is_action_pressed("move_up"):
		y -= 1
	if InputMap.has_action("move_down") and Input.is_action_pressed("move_down"):
		y += 1
	return Vector2i(x, y)


func _mouse_cell() -> Vector2i:
	var mouse := get_viewport().get_mouse_position()
	var local := mouse - ORIGIN
	if local.x < 0.0 or local.y < 0.0:
		return Vector2i(-1, -1)
	var cell := Vector2i(floori(local.x / Sim.TILE), floori(local.y / Sim.TILE))
	if cell.x < 0 or cell.y < 0 or cell.x >= Sim.MAP_W or cell.y >= Sim.MAP_H:
		return Vector2i(-1, -1)
	return cell


func _consume_events() -> void:
	for event in sim.events:
		var kind := str(event.get("type", ""))
		if kind == "died" and not bool(event.get("hidden", false)):
			_burst(Vector2(float(event["x"]), float(event["y"])))
		elif kind == "plant_rejected":
			reject_left = 1.4


func _burst(at: Vector2) -> void:
	for i in 8:
		var angle := float(i) / 8.0 * TAU + 0.15
		var speed := 26.0 + float(i % 3) * 12.0
		var color := Color(1.0, 0.94, 0.75) if i % 2 == 0 else Color(0.78, 1.0, 0.84)
		motes.append({
			"pos": at,
			"vel": Vector2(cos(angle), sin(angle)) * speed + Vector2(0, -16),
			"life": 0.75,
			"max_life": 0.75,
			"color": color,
			"radius": 2.2 + float(i % 3) * 0.7,
		})


func _update_motes(delta: float) -> void:
	var next: Array = []
	for mote in motes:
		mote["life"] = float(mote["life"]) - delta
		if float(mote["life"]) <= 0.0:
			continue
		var vel: Vector2 = mote["vel"]
		vel.y += 18.0 * delta
		mote["vel"] = vel
		mote["pos"] = (mote["pos"] as Vector2) + vel * delta
		next.append(mote)
	motes = next


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	title_label = _label("ORCHARD SURGE", 22, Color("f3e6c4"))
	title_label.position = Vector2(16, 8)
	title_label.size = Vector2(360, 30)
	layer.add_child(title_label)

	phase_label = _label("", 16, Color("d7e2c8"))
	phase_label.position = Vector2(16, 40)
	phase_label.size = Vector2(430, 26)
	layer.add_child(phase_label)

	hp_label = _label("HP 100", 15, Color("f0d2c8"))
	hp_label.position = Vector2(450, 40)
	hp_label.size = Vector2(90, 24)
	layer.add_child(hp_label)

	var hp_bg := ColorRect.new()
	hp_bg.position = Vector2(530, 46)
	hp_bg.size = Vector2(160, 12)
	hp_bg.color = Color(0.12, 0.08, 0.08)
	hp_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hp_bg)
	hp_fill = ColorRect.new()
	hp_fill.position = Vector2(530, 46)
	hp_fill.size = Vector2(160, 12)
	hp_fill.color = Color("6eae55")
	hp_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(hp_fill)

	seeds_label = _label("Seeds 34", 15, Color("e7d7a4"))
	seeds_label.position = Vector2(704, 40)
	seeds_label.size = Vector2(110, 24)
	layer.add_child(seeds_label)

	seed_label = _label("Seed 1", 15, Color("b7c3b0"))
	seed_label.position = Vector2(820, 40)
	seed_label.size = Vector2(140, 24)
	layer.add_child(seed_label)

	var restart := Button.new()
	restart.text = "Restart"
	restart.position = Vector2(980, 34)
	restart.size = Vector2(120, 30)
	restart.focus_mode = Control.FOCUS_NONE
	restart.pressed.connect(_restart)
	layer.add_child(restart)

	var hint_box := Control.new()
	hint_box.position = Vector2(16, 612)
	hint_box.size = Vector2(720, 112)
	hint_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint_box.clip_contents = true
	layer.add_child(hint_box)
	hint_label = _label("Move: WASD. Plant: 1-9, 0, B, C, E, F, G, H, I, J, K, L, M, N, O, P, Q, T, U, V, X, Y, Z, comma, period, slash, semicolon, apostrophe, backslash. Only a wick burns shroud. Only a briar cracks rind. Only a flare melts pitch. Only a hearth thaws frost. Only a shear cuts web. Only a chime cracks glass. Only a rasp strips scale. Only a maul cracks mail. Only a bill splits hide. Only a shade shades dusk. Only a cowl cowls veil. Only a hood hoods pall. Only a cloak cloaks gloom. Only a cape capes murk. Only a shawl shawls dread. Only a stole stoles woe. Only a mantle mantles blight. Only a tippet tippets rot. Only a wimple wimples mildew. Only an alb albs rust. Only an amice amices scab. Only an orphrey orphreys spot. Only a maniple maniples scald. Only a chasuble chasubles blister. Only a dalmatic dalmatics char. Only a tunicle tunicles scorch. Only a rochet rochets sear. Only a cope copes singe. Only a surplice surplices brand. Only a cotta cottas scathe. Only a chimere chimeres cauter. Only a mozzetta mozzettas blain. Only a biretta birettas scurf.", 7, Color("aeb8a4"))
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hint_label.clip_text = true
	hint_box.add_child(hint_label)

	reject_label = _label("", 14, Color("e0b4a0"))
	reject_label.position = Vector2(16, 588)
	reject_label.size = Vector2(720, 24)
	layer.add_child(reject_label)

	for kind in Catalog.COUNT:
		var panel := PanelContainer.new()
		panel.position = Vector2(CARD_LEFT, _card_top_for(kind))
		panel.size = Vector2(CARD_W, CARD_H)
		panel.custom_minimum_size = Vector2(CARD_W, CARD_H)
		panel.clip_contents = true
		panel.focus_mode = Control.FOCUS_NONE
		panel.mouse_filter = Control.MOUSE_FILTER_STOP
		var style := _panel_style(Color(0.08, 0.09, 0.08, 0.94), Color(0.32, 0.3, 0.22))
		panel.add_theme_stylebox_override("panel", style)
		panel.gui_input.connect(_on_card_input.bind(kind))
		layer.add_child(panel)
		card_panels.append(panel)
		card_styles.append(style)

		var box := VBoxContainer.new()
		box.name = "Box"
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# The scurf line still has to fit the locked 340px card, margins included.
		box.add_theme_constant_override("separation", -7)
		panel.add_child(box)
		var hotkey := _label(_hotkey_text(kind), 11, KIND_COLOR[kind])
		hotkey.add_theme_constant_override("line_spacing", 0)
		hotkey.name = "Hotkey"
		hotkey.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(hotkey)
		var index := 0
		for line in Tooltip.stat_lines(kind):
			var row := _label(line, 10 if index > 0 else 14, Color("f4f0e4") if index == 0 else Color("d5d0c4"))
			row.add_theme_constant_override("line_spacing", 0)
			row.name = "Stat%d" % index
			row.mouse_filter = Control.MOUSE_FILTER_IGNORE
			box.add_child(row)
			index += 1
		plant_card_boxes.append(box)

	overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.visible = false
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	layer.add_child(overlay)
	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.02, 0.025, 0.03, 0.78)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.add_child(dim)
	outcome_label = _label("", 26, Color("f6edd4"))
	outcome_label.position = Vector2(36, 250)
	outcome_label.size = Vector2(680, 120)
	outcome_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outcome_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	overlay.add_child(outcome_label)
	var again := Button.new()
	again.text = "Plant again"
	again.position = Vector2(296, 390)
	again.size = Vector2(160, 40)
	again.focus_mode = Control.FOCUS_NONE
	again.pressed.connect(_restart)
	overlay.add_child(again)


func _on_card_input(event: InputEvent, kind: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		selected = kind


func _refresh_hud() -> void:
	if sim == null:
		return
	phase_label.text = sim.phase_text()
	hp_label.text = "HP %d" % sim.player_hp
	seeds_label.text = "Seeds %d" % sim.seeds
	seed_label.text = "Seed %d" % sim.run_seed
	var fraction := clampf(float(sim.player_hp) / float(Sim.PLAYER_HP), 0.0, 1.0)
	hp_fill.size.x = 160.0 * fraction
	hp_fill.color = Color("6eae55").lerp(Color("c2503c"), 1.0 - fraction)
	reject_label.text = "That tile won't take a seed." if reject_left > 0.0 else ""
	for i in card_styles.size():
		var style := card_styles[i] as StyleBoxFlat
		if i == selected:
			style.border_color = KIND_COLOR[i]
			style.set_border_width_all(2)
		else:
			style.border_color = Color(0.3, 0.28, 0.22)
			style.set_border_width_all(1)
	if sim.outcome == Sim.OUTCOME_RUNNING:
		overlay.visible = false
		return
	overlay.visible = true
	if sim.outcome == Sim.OUTCOME_WON:
		outcome_label.text = "The surge breaks.\nSixty-nine nights passed, and the orchard still stands."
	else:
		outcome_label.text = "The lights went out.\nHealth reached zero before the orchard was clear."


func _hotkey_text(kind: int) -> String:
	if kind == Catalog.CHIME:
		return "0"
	if kind == Catalog.RASP:
		return "B"
	if kind == Catalog.MAUL:
		return "C"
	if kind == Catalog.BILL:
		return "E"
	if kind == Catalog.SHADE:
		return "F"
	if kind == Catalog.COWL:
		return "G"
	if kind == Catalog.HOOD:
		return "H"
	if kind == Catalog.CLOAK:
		return "I"
	if kind == Catalog.CAPE:
		return "J"
	if kind == Catalog.SHAWL:
		return "K"
	if kind == Catalog.STOLE:
		return "L"
	if kind == Catalog.MANTLE:
		return "M"
	if kind == Catalog.TIPPET:
		return "N"
	if kind == Catalog.WIMPLE:
		return "O"
	if kind == Catalog.ALB:
		return "P"
	if kind == Catalog.AMICE:
		return "Q"
	if kind == Catalog.ORPHREY:
		return "T"
	if kind == Catalog.MANIPLE:
		return "U"
	if kind == Catalog.CHASUBLE:
		return "V"
	if kind == Catalog.DALMATIC:
		return "X"
	if kind == Catalog.TUNICLE:
		return "Y"
	if kind == Catalog.ROCHET:
		return "Z"
	if kind == Catalog.COPE:
		return ","
	if kind == Catalog.SURPLICE:
		return "."
	if kind == Catalog.COTTA:
		return "/"
	if kind == Catalog.CHIMERE:
		return ";"
	if kind == Catalog.MOZZETTA:
		return "'"
	if kind == Catalog.BIRETTA:
		return "\\"
	return str(kind + 1)


func _card_top_for(kind: int) -> float:
	var y := CARD_TOP + float(kind) * (CARD_H + CARD_GAP)
	# Shawl stays y 6294–6634. Stole stays y 6634–6974. Mantle stays y 6974–7314.
	# Tippet stays y 7314–7654. The wimple card stays y 7654–7994.
	# The alb card stays on the wimple's bottom, y 7994–8334.
	# The amice card stays on the alb's bottom, y 8334–8674.
	# The orphrey card stays on the amice's bottom, y 8674–9014.
	# The maniple card stays on the orphrey's bottom, y 9014–9354.
	# The chasuble card stays on the maniple's bottom, y 9354–9694.
	# The dalmatic card stays on the chasuble's bottom, y 9694–10034.
	# The tunicle card stays on the dalmatic's bottom, y 10034–10374.
	# The rochet card stays on the tunicle's bottom, y 10374–10714.
	# The cope card starts on the rochet's bottom, y 10714–11054.
	# The surplice card starts on the cope's bottom, y 11054–11394.
	# The cotta card stays y 11394–11734.
	# The chimere card stays y 11734–12074.
	# The mozzetta card stays y 12074–12414. The biretta card starts on the mozzetta's bottom, y 12414–12754, so the 12820 window keeps the same 66px spare.
	if kind >= Catalog.BIRETTA:
		y -= CARD_GAP * 19.0
	elif kind >= Catalog.MOZZETTA:
		y -= CARD_GAP * 18.0
	elif kind >= Catalog.CHIMERE:
		y -= CARD_GAP * 17.0
	elif kind >= Catalog.COTTA:
		y -= CARD_GAP * 16.0
	elif kind >= Catalog.SURPLICE:
		y -= CARD_GAP * 15.0
	elif kind >= Catalog.COPE:
		y -= CARD_GAP * 14.0
	elif kind >= Catalog.ROCHET:
		y -= CARD_GAP * 13.0
	elif kind >= Catalog.TUNICLE:
		y -= CARD_GAP * 12.0
	elif kind >= Catalog.DALMATIC:
		y -= CARD_GAP * 11.0
	elif kind >= Catalog.CHASUBLE:
		y -= CARD_GAP * 10.0
	elif kind >= Catalog.MANIPLE:
		y -= CARD_GAP * 9.0
	elif kind >= Catalog.ORPHREY:
		y -= CARD_GAP * 8.0
	elif kind >= Catalog.AMICE:
		y -= CARD_GAP * 7.0
	elif kind >= Catalog.ALB:
		y -= CARD_GAP * 6.0
	elif kind >= Catalog.WIMPLE:
		y -= CARD_GAP * 5.0
	elif kind >= Catalog.TIPPET:
		y -= CARD_GAP * 4.0
	elif kind >= Catalog.MANTLE:
		y -= CARD_GAP * 3.0
	elif kind >= Catalog.STOLE:
		y -= CARD_GAP * 2.0
	elif kind >= Catalog.SHAWL:
		y -= CARD_GAP
	return y


func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.focus_mode = Control.FOCUS_NONE
	return label


func _panel_style(bg: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 10
	style.content_margin_right = 10
	# The mildew line still has to fit the locked 340px card. Two pixels less vertical padding keeps that card from growing.
	style.content_margin_top = 2
	style.content_margin_bottom = 2
	return style


func _draw() -> void:
	var view := get_viewport_rect().size
	draw_rect(Rect2(Vector2.ZERO, view), Color(0.03, 0.034, 0.05), true)
	if sim == null:
		return
	_draw_ground()
	_draw_fog()
	_draw_hover()
	for plant in sim.plants:
		_draw_plant(plant)
	for shot in sim.projectiles:
		if shot.alive:
			_draw_shot(shot)
	for pest in sim.pests:
		if pest.alive and not pest.hidden:
			_draw_pest(pest)
	_draw_motes()
	_draw_gardener()
	for plant in sim.plants:
		if plant.alive:
			var ring: Color = KIND_COLOR[plant.kind]
			ring.a = 0.28
			draw_arc(_screen(plant.pos), plant.light_radius, 0.0, TAU, 48, ring, 1.2, true)
	var frame := Rect2(ORIGIN, Vector2(Sim.MAP_W * Sim.TILE, Sim.MAP_H * Sim.TILE))
	draw_rect(frame, Color(0.35, 0.32, 0.22, 0.7), false, 2.0)


func _draw_ground() -> void:
	for ty in Sim.MAP_H:
		for tx in Sim.MAP_W:
			var rect := _tile_rect(tx, ty)
			var border := tx == 0 or ty == 0 or tx == Sim.MAP_W - 1 or ty == Sim.MAP_H - 1
			if border:
				draw_rect(rect, Color("1a1612"), true)
				_draw_tree(rect)
			else:
				var n := (tx * 13 + ty * 29) % 4
				var soil := Color("2a241c") if (tx + ty) % 2 == 0 else Color("221c16")
				soil = soil.lerp(Color("3a2e22"), float(n) * 0.08)
				draw_rect(rect, soil, true)
				draw_line(rect.position + Vector2(8, 30), rect.position + Vector2(40, 30), Color(0.12, 0.2, 0.1, 0.55), 2.0)


func _draw_tree(rect: Rect2) -> void:
	var trunk := Rect2(rect.position + Vector2(20, 22), Vector2(8, 22))
	draw_rect(trunk, Color("2c241c"), true)
	draw_circle(rect.position + Vector2(24, 18), 14.0, Color("122016"))
	draw_circle(rect.position + Vector2(16, 22), 8.0, Color("0e1a12"))


func _draw_fog() -> void:
	var late: bool = sim.wave >= 4 or (sim.phase == Sim.PHASE_PLANT and sim.wave >= 3)
	for ty in Sim.MAP_H:
		for tx in Sim.MAP_W:
			var rect := _tile_rect(tx, ty)
			if sim.tile_burns_shroud(tx, ty):
				draw_rect(rect, Color(0.9, 0.32, 0.12, 0.12), true)
				if sim.tile_cracks_rind(tx, ty):
					draw_rect(rect, Color(0.72, 0.28, 0.4, 0.08), true)
			elif sim.tile_cracks_rind(tx, ty):
				draw_rect(rect, Color(0.72, 0.28, 0.4, 0.12), true)
			elif sim.tile_lit(tx, ty):
				draw_rect(rect, Color(0.95, 0.82, 0.45, 0.07), true)
			else:
				var alpha := 0.7 if late else 0.58
				draw_rect(rect, Color(0.015, 0.02, 0.035, alpha), true)
			if sim.tile_melts_pitch(tx, ty):
				draw_rect(rect, Color(0.95, 0.78, 0.28, 0.1), true)
			if sim.tile_thaws_frost(tx, ty):
				draw_rect(rect, Color(0.62, 0.86, 0.98, 0.1), true)
			if sim.tile_cuts_web(tx, ty):
				draw_rect(rect, Color(0.78, 0.7, 0.95, 0.1), true)
			if sim.tile_cracks_glass(tx, ty):
				draw_rect(rect, Color(0.7, 0.95, 0.88, 0.1), true)
			if sim.tile_strips_scale(tx, ty):
				draw_rect(rect, Color(0.86, 0.62, 0.32, 0.1), true)
			if sim.tile_cracks_mail(tx, ty):
				draw_rect(rect, Color(0.72, 0.78, 0.84, 0.1), true)
			if sim.tile_shades_dusk(tx, ty):
				draw_rect(rect, Color(0.42, 0.34, 0.62, 0.16), true)
			if sim.tile_cowls_veil(tx, ty):
				draw_rect(rect, Color(0.9, 0.86, 0.74, 0.14), true)
			if sim.tile_hoods_pall(tx, ty):
				draw_rect(rect, Color(0.72, 0.56, 0.4, 0.14), true)
			if sim.tile_cloaks_gloom(tx, ty):
				draw_rect(rect, Color(0.36, 0.30, 0.52, 0.16), true)
			if sim.tile_capes_murk(tx, ty):
				draw_rect(rect, Color(0.22, 0.42, 0.38, 0.16), true)
			if sim.tile_shawls_dread(tx, ty):
				draw_rect(rect, Color(0.62, 0.32, 0.48, 0.16), true)
			if sim.tile_stoles_woe(tx, ty):
				draw_rect(rect, Color(0.86, 0.84, 0.74, 0.16), true)
			if sim.tile_mantles_blight(tx, ty):
				draw_rect(rect, Color(0.74, 0.86, 0.76, 0.16), true)
			if sim.tile_tippets_rot(tx, ty):
				draw_rect(rect, Color(0.62, 0.5, 0.34, 0.16), true)
			if sim.tile_wimples_mildew(tx, ty):
				draw_rect(rect, Color(0.58, 0.66, 0.36, 0.16), true)
			if sim.tile_albs_rust(tx, ty):
				draw_rect(rect, Color(0.78, 0.46, 0.22, 0.16), true)
			if sim.tile_amices_scab(tx, ty):
				draw_rect(rect, Color(0.62, 0.52, 0.36, 0.16), true)
			if sim.tile_orphreys_spot(tx, ty):
				draw_rect(rect, Color(0.72, 0.42, 0.16, 0.16), true)
			if sim.tile_maniples_scald(tx, ty):
				draw_rect(rect, Color(0.62, 0.16, 0.18, 0.16), true)
			if sim.tile_chasubles_blister(tx, ty):
				draw_rect(rect, Color(0.74, 0.86, 0.78, 0.16), true)
			if sim.tile_dalmatics_char(tx, ty):
				draw_rect(rect, Color(0.78, 0.70, 0.48, 0.16), true)
			if sim.tile_tunicles_scorch(tx, ty):
				draw_rect(rect, Color(0.62, 0.74, 0.82, 0.16), true)
			if sim.tile_rochets_sear(tx, ty):
				draw_rect(rect, Color(0.93, 0.90, 0.82, 0.16), true)
			if sim.tile_copes_singe(tx, ty):
				draw_rect(rect, Color(0.45, 0.52, 0.78, 0.16), true)
			if sim.tile_surplices_brand(tx, ty):
				draw_rect(rect, Color(0.93, 0.95, 0.98, 0.18), true)
			if sim.tile_cottas_scathe(tx, ty):
				draw_rect(rect, Color(0.95, 0.90, 0.74, 0.16), true)
			if sim.tile_chimeres_cauter(tx, ty):
				draw_rect(rect, Color(0.55, 0.18, 0.16, 0.16), true)
			if sim.tile_mozzettas_blain(tx, ty):
				draw_rect(rect, Color(0.42, 0.24, 0.58, 0.16), true)
			if sim.tile_birettas_scurf(tx, ty):
				draw_rect(rect, Color(0.28, 0.28, 0.30, 0.16), true)
			if sim.tile_splits_hide(tx, ty):
				draw_rect(rect, Color(0.86, 0.7, 0.42, 0.1), true)


func _draw_hover() -> void:
	if sim.outcome != Sim.OUTCOME_RUNNING or sim.phase != Sim.PHASE_PLANT:
		return
	var cell := _mouse_cell()
	if not sim.is_plantable(cell):
		return
	var tint: Color = KIND_COLOR[selected]
	tint.a = 0.28
	draw_rect(_tile_rect(cell.x, cell.y), tint, true)


func _draw_plant(plant) -> void:
	var at := _screen(plant.pos)
	match int(plant.kind):
		Catalog.PEA:
			draw_line(at + Vector2(0, 16), at + Vector2(0, -2), Color("2f6b32"), 3.0)
			draw_line(at + Vector2(0, 4), at + Vector2(-10, -2), Color("67b84a"), 2.0)
			draw_line(at + Vector2(0, 6), at + Vector2(10, 0), Color("67b84a"), 2.0)
			draw_circle(at + Vector2(0, -8), 7.0, Color("8fdb55"))
			draw_circle(at + Vector2(-2, -10), 2.0, Color("e7ffcf"))
		Catalog.VINE:
			draw_line(at + Vector2(0, 16), at + Vector2(-6, 4), Color("245c34"), 3.0)
			draw_line(at + Vector2(-6, 4), at + Vector2(6, -4), Color("3e8f55"), 3.0)
			draw_line(at + Vector2(6, -4), at + Vector2(-4, -12), Color("6ec47a"), 2.5)
			draw_circle(at + Vector2(-6, 4), 3.0, Color("8fd18a"))
			draw_circle(at + Vector2(6, -4), 3.0, Color("8fd18a"))
			draw_circle(at + Vector2(-4, -12), 3.5, Color("d7ffcf"))
		Catalog.LANTERN:
			draw_rect(Rect2(at + Vector2(-3, -2), Vector2(6, 20)), Color("5a4632"), true)
			draw_circle(at + Vector2(0, -8), 16.0, Color(1.0, 0.78, 0.35, 0.22))
			draw_circle(at + Vector2(0, -8), 7.0, Color("ffc857"))
			draw_circle(at + Vector2(0, -8), 3.0, Color("fff4cf"))
		Catalog.GOURD:
			draw_set_transform(at + Vector2(0, 4), 0.0, Vector2(1.2, 0.82))
			draw_circle(Vector2.ZERO, 12.0, Color("e07a2f"))
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			draw_circle(at + Vector2(0, -8), 4.0, Color("c46822"))
			draw_line(at + Vector2(0, -12), at + Vector2(2, -18), Color("6a8f3a"), 2.0)
		Catalog.WICK:
			draw_line(at + Vector2(0, 16), at + Vector2(0, 0), Color("2c221c"), 3.2)
			draw_line(at + Vector2(-8, 9), at + Vector2(-1, 2), Color("3d2e26"), 2.0)
			draw_line(at + Vector2(8, 11), at + Vector2(1, 3), Color("3d2e26"), 2.0)
			var pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.18)
			draw_circle(at + Vector2(0, -7), 11.0, Color(1.0, 0.32, 0.1, 0.16 + 0.1 * pulse))
			draw_circle(at + Vector2(0, -7), 3.6, Color("ff5c32"))
			draw_circle(at + Vector2(-0.6, -8.0), 1.4, Color("fff1e4"))
		Catalog.BRIAR:
			draw_line(at + Vector2(0, 16), at + Vector2(-1, -2), Color("5c3a38"), 3.0)
			draw_line(at + Vector2(-1, 8), at + Vector2(-11, 3), Color("7a4e4a"), 2.0)
			draw_line(at + Vector2(0, 1), at + Vector2(10, -4), Color("7a4e4a"), 2.0)
			draw_line(at + Vector2(-1, -6), at + Vector2(-8, -14), Color("8d5c58"), 2.0)
			draw_circle(at + Vector2(-8, -14), 3.2, Color("a33d55"))
			draw_circle(at + Vector2(10, -4), 2.5, Color("c45a6a"))
			draw_circle(at + Vector2(-1, -12), 2.2, Color("f0d4da"))
		Catalog.FLARE:
			draw_line(at + Vector2(0, 16), at + Vector2(0, 2), Color("3a2c18"), 3.2)
			draw_rect(Rect2(at + Vector2(-5, 0), Vector2(10, 5)), Color("5c4324"), true)
			var flare_pulse := 0.6 + 0.4 * sin(float(sim.tick) * 0.22)
			draw_circle(at + Vector2(0, -8), 12.0, Color(1.0, 0.86, 0.4, 0.14 + 0.1 * flare_pulse))
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(0, -18),
				at + Vector2(5, -4),
				at + Vector2(-5, -4),
			]), Color("ffe28a"))
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(0, -13),
				at + Vector2(2.4, -5),
				at + Vector2(-2.4, -5),
			]), Color("fff6d4"))
		Catalog.HEARTH:
			draw_rect(Rect2(at + Vector2(-11, 6), Vector2(22, 8)), Color("3e4a54"), true)
			draw_rect(Rect2(at + Vector2(-8, 4), Vector2(16, 5)), Color("6d7c88"), true)
			var hearth_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.16)
			draw_circle(at + Vector2(0, -2), 10.0, Color(0.7, 0.9, 1.0, 0.14 + 0.1 * hearth_pulse))
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(0, -14),
				at + Vector2(4.5, 2),
				at + Vector2(-4.5, 2),
			]), Color("d7f2ff"))
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(0, -9),
				at + Vector2(2.2, 1),
				at + Vector2(-2.2, 1),
			]), Color("f4fcff"))
		Catalog.SHEAR:
			draw_line(at + Vector2(-7, 14), at + Vector2(-1, 1), Color("3c4048"), 3.0)
			draw_line(at + Vector2(7, 14), at + Vector2(1, 1), Color("3c4048"), 3.0)
			draw_circle(at + Vector2(0, 0), 2.6, Color("efe8dc"))
			draw_line(at + Vector2(-1, -1), at + Vector2(-11, -15), Color("c8c6d4"), 2.4)
			draw_line(at + Vector2(1, -1), at + Vector2(11, -15), Color("f2eef8"), 2.4)
			var shear_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.2)
			draw_circle(at + Vector2(0, -8), 10.0, Color(0.78, 0.7, 0.96, 0.12 + 0.1 * shear_pulse))
			draw_line(at + Vector2(-6, -6), at + Vector2(6, -12), Color(0.92, 0.86, 1.0, 0.45 + 0.3 * shear_pulse), 1.2)
		Catalog.CHIME:
			draw_line(at + Vector2(0, 16), at + Vector2(0, -2), Color("2c3c40"), 2.4)
			draw_line(at + Vector2(-10, -2), at + Vector2(10, -2), Color("8fd0c8"), 2.2)
			draw_line(at + Vector2(-7, -2), at + Vector2(-7, 8), Color("d7f4ef"), 1.6)
			draw_circle(at + Vector2(-7, 10), 2.4, Color("e9fffb"))
			draw_line(at + Vector2(0, -2), at + Vector2(0, 11), Color("b7ebe4"), 1.6)
			draw_circle(at + Vector2(0, 13), 2.8, Color("f4fffd"))
			draw_line(at + Vector2(7, -2), at + Vector2(7, 7), Color("d7f4ef"), 1.6)
			draw_circle(at + Vector2(7, 9), 2.4, Color("e9fffb"))
			var chime_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.19)
			draw_circle(at + Vector2(0, 2), 12.0, Color(0.7, 0.95, 0.9, 0.12 + 0.1 * chime_pulse))
		Catalog.RASP:
			draw_rect(Rect2(at + Vector2(-4, 6), Vector2(8, 12)), Color("5a3e2c"), true)
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-5, 8),
				at + Vector2(5, 8),
				at + Vector2(3, -16),
				at + Vector2(-3, -16),
			]), Color("c4895a"))
			draw_line(at + Vector2(-4, 2), at + Vector2(4, -1), Color("8a5a34"), 1.2)
			draw_line(at + Vector2(-4, -2), at + Vector2(4, -5), Color("8a5a34"), 1.2)
			draw_line(at + Vector2(-3, -6), at + Vector2(3, -9), Color("f0d2b0"), 1.2)
			draw_line(at + Vector2(-3, -10), at + Vector2(3, -13), Color("f0d2b0"), 1.2)
			var rasp_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.17)
			draw_circle(at + Vector2(0, -4), 12.0, Color(0.86, 0.58, 0.32, 0.12 + 0.1 * rasp_pulse))
		Catalog.MAUL:
			draw_rect(Rect2(at + Vector2(-2, 4), Vector2(4, 14)), Color("4a4038"), true)
			draw_rect(Rect2(at + Vector2(-11, -8), Vector2(22, 10)), Color("8d97a1"), true)
			draw_rect(Rect2(at + Vector2(-11, -8), Vector2(22, 3)), Color("d5dde4"), true)
			draw_rect(Rect2(at + Vector2(-11, -1), Vector2(22, 3)), Color("5e6872"), true)
			var maul_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.15)
			draw_circle(at + Vector2(0, -4), 13.0, Color(0.7, 0.76, 0.84, 0.12 + 0.1 * maul_pulse))
		Catalog.BILL:
			draw_line(at + Vector2(0, 16), at + Vector2(0, -1), Color("6a5344"), 3.0)
			draw_line(at + Vector2(0, -1), at + Vector2(11, -12), Color("e6d3b0"), 2.6)
			draw_line(at + Vector2(11, -12), at + Vector2(4, -6), Color("c4a882"), 2.4)
			draw_line(at + Vector2(4, -6), at + Vector2(8, -2), Color("f0e2c8"), 1.6)
			var bill_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.14)
			draw_circle(at + Vector2(2, -6), 12.0, Color(0.86, 0.7, 0.42, 0.12 + 0.1 * bill_pulse))
		Catalog.SHADE:
			draw_line(at + Vector2(0, 16), at + Vector2(0, 2), Color("2a241c"), 3.0)
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-16, 4),
				at + Vector2(0, -12),
				at + Vector2(16, 4),
			]), Color("2a2638"))
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-10, 2),
				at + Vector2(0, -8),
				at + Vector2(10, 2),
			]), Color("3c3850"))
			var shade_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.12)
			draw_arc(at + Vector2(0, -2), 14.0, 0.6, TAU - 0.45, 18, Color(0.55, 0.46, 0.78, 0.35 + 0.3 * shade_pulse), 1.6, true)
		Catalog.COWL:
			draw_line(at + Vector2(0, 16), at + Vector2(0, 4), Color("4a453c"), 3.0)
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-13, 3),
				at + Vector2(-9, -12),
				at + Vector2(9, -12),
				at + Vector2(13, 3),
			]), Color("cfc6b6"))
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-8, 2),
				at + Vector2(-4, -7),
				at + Vector2(4, -7),
				at + Vector2(8, 2),
			]), Color("f6f1e6"))
			draw_line(at + Vector2(-9, 3), at + Vector2(-6, 13), Color(0.9, 0.86, 0.76, 0.75), 1.5)
			draw_line(at + Vector2(9, 3), at + Vector2(6, 13), Color(0.9, 0.86, 0.76, 0.75), 1.5)
			var cowl_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.11)
			draw_arc(at + Vector2(0, -2), 14.0, 0.4, TAU - 0.55, 18, Color(0.95, 0.91, 0.82, 0.35 + 0.3 * cowl_pulse), 1.6, true)
		Catalog.HOOD:
			draw_line(at + Vector2(0, 16), at + Vector2(0, 6), Color("5a4638"), 3.2)
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-14, 6),
				at + Vector2(-8, -14),
				at + Vector2(8, -14),
				at + Vector2(14, 6),
			]), Color("8a6a4e"))
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-8, 4),
				at + Vector2(-3, -6),
				at + Vector2(3, -6),
				at + Vector2(8, 4),
			]), Color("2a221c"))
			draw_line(at + Vector2(-12, 6), at + Vector2(-8, 16), Color("c4b09a"), 1.6)
			draw_line(at + Vector2(12, 6), at + Vector2(8, 16), Color("c4b09a"), 1.6)
			var hood_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.1)
			draw_arc(at + Vector2(0, -1), 14.0, 0.55, TAU - 0.7, 18, Color(0.72, 0.56, 0.4, 0.35 + 0.3 * hood_pulse), 1.6, true)
		Catalog.CLOAK:
			draw_line(at + Vector2(0, 16), at + Vector2(0, 8), Color("2a2634"), 3.2)
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-16, 8),
				at + Vector2(-10, -14),
				at + Vector2(10, -14),
				at + Vector2(16, 8),
			]), Color("3c3850"))
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-9, 6),
				at + Vector2(-4, -6),
				at + Vector2(4, -6),
				at + Vector2(9, 6),
			]), Color("1c1a24"))
			draw_line(at + Vector2(-14, 8), at + Vector2(-10, 17), Color("6a6280"), 1.6)
			draw_line(at + Vector2(14, 8), at + Vector2(10, 17), Color("6a6280"), 1.6)
			var cloak_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.09)
			draw_arc(at + Vector2(0, -1), 15.0, 0.7, TAU - 0.85, 18, Color(0.42, 0.36, 0.58, 0.35 + 0.3 * cloak_pulse), 1.6, true)
		Catalog.CAPE:
			draw_line(at + Vector2(0, 16), at + Vector2(0, 8), Color("1e2c28"), 3.2)
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-16, 8),
				at + Vector2(-10, -14),
				at + Vector2(10, -14),
				at + Vector2(16, 8),
			]), Color("2f4a44"))
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-9, 6),
				at + Vector2(-4, -6),
				at + Vector2(4, -6),
				at + Vector2(9, 6),
			]), Color("14201c"))
			draw_line(at + Vector2(-14, 8), at + Vector2(-10, 17), Color("6a8a80"), 1.6)
			draw_line(at + Vector2(14, 8), at + Vector2(10, 17), Color("6a8a80"), 1.6)
			var cape_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.08)
			draw_arc(at + Vector2(0, -1), 16.0, 0.35, TAU - 0.5, 18, Color(0.28, 0.52, 0.46, 0.35 + 0.3 * cape_pulse), 1.6, true)
		Catalog.SHAWL:
			# Folded cloth: overlapping creased panels, not a hanging cape.
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-15, 8),
				at + Vector2(-4, -6),
				at + Vector2(12, -2),
				at + Vector2(6, 12),
			]), Color("6a3a56"))
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-8, 4),
				at + Vector2(4, -12),
				at + Vector2(16, 2),
				at + Vector2(2, 10),
			]), Color("c9a0b4"))
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-2, 6),
				at + Vector2(6, -4),
				at + Vector2(14, 6),
				at + Vector2(4, 14),
			]), Color("8d5872"))
			draw_line(at + Vector2(-4, -6), at + Vector2(6, 12), Color("3a2432"), 1.5)
			draw_line(at + Vector2(4, -12), at + Vector2(2, 10), Color("f3e4ea"), 1.2)
			var shawl_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.07)
			draw_arc(at + Vector2(1, 2), 15.0, 1.15, TAU - 1.05, 16, Color(0.72, 0.4, 0.58, 0.35 + 0.3 * shawl_pulse), 1.6, true)
		Catalog.STOLE:
			# A long pale strip. Not the shawl's folded cloth.
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-22, -1),
				at + Vector2(22, -5),
				at + Vector2(22, 1),
				at + Vector2(-22, 5),
			]), Color("efe8d6"))
			draw_line(at + Vector2(-22, 2), at + Vector2(22, -2), Color("b7b09e"), 1.4)
			draw_line(at + Vector2(-18, -2), at + Vector2(18, -4), Color("f8f4ea"), 1.0)
			var stole_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.06)
			draw_arc(at, 16.0, 2.15, TAU - 0.35, 18, Color(0.86, 0.82, 0.7, 0.35 + 0.3 * stole_pulse), 1.6, true)
		Catalog.MANTLE:
			# A pale hem: a folded lower curve. Not the stole's long pale strip.
			draw_arc(at + Vector2(0, 8), 16.0, 0.25, PI - 0.25, 14, Color("d5ddd6"), 3.4, true)
			draw_arc(at + Vector2(0, 5), 14.0, 0.4, PI - 0.4, 12, Color("f3f7f2"), 1.3, true)
			draw_line(at + Vector2(-15, 10), at + Vector2(-17, 16), Color("b7c2b8"), 1.4)
			draw_line(at + Vector2(15, 10), at + Vector2(17, 16), Color("b7c2b8"), 1.4)
			var mantle_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.05)
			draw_arc(at + Vector2(0, 2), 17.0, 0.15, PI - 0.15, 16, Color(0.72, 0.82, 0.76, 0.35 + 0.3 * mantle_pulse), 1.5, true)
		Catalog.TIPPET:
			# A narrow pale band. Not the mantle's hem and not the stole's long strip.
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-11, -1.5),
				at + Vector2(11, -1.5),
				at + Vector2(11, 1.5),
				at + Vector2(-11, 1.5),
			]), Color("d8d2c4"))
			draw_line(at + Vector2(-11, 0), at + Vector2(11, 0), Color("f6f3ea"), 0.8)
			var tippet_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.045)
			draw_arc(at + Vector2(0, 1), 13.0, 0.9, PI - 0.9, 10, Color(0.72, 0.66, 0.5, 0.35 + 0.3 * tippet_pulse), 1.2, true)
		Catalog.WIMPLE:
			# A wrapped linen coif: crown cloth and a chin fold. Not the tippet's narrow band.
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-12, -10),
				at + Vector2(12, -10),
				at + Vector2(10, 2),
				at + Vector2(-10, 2),
			]), Color("d5ddc4"))
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-10, 2),
				at + Vector2(10, 2),
				at + Vector2(7, 12),
				at + Vector2(-7, 12),
			]), Color("9aa884"))
			draw_line(at + Vector2(-8, -6), at + Vector2(8, -6), Color("f4f7ee"), 1.0)
			var wimple_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.04)
			draw_arc(at + Vector2(0, 1), 14.0, 3.5, TAU - 0.55, 12, Color(0.55, 0.64, 0.36, 0.35 + 0.3 * wimple_pulse), 1.3, true)
		Catalog.ALB:
			# A long white robe. Not the wimple's wrapped coif and not the stole's pale strip.
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-8, -14),
				at + Vector2(8, -14),
				at + Vector2(12, 16),
				at + Vector2(-12, 16),
			]), Color("f4f0e4"))
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-5, -14),
				at + Vector2(5, -14),
				at + Vector2(4, -6),
				at + Vector2(-4, -6),
			]), Color("e4d8c4"))
			draw_line(at + Vector2(-10, 12), at + Vector2(10, 12), Color("c8c0b0"), 1.2)
			var alb_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.035)
			draw_arc(at + Vector2(0, 2), 15.0, 0.4, PI - 0.4, 12, Color(0.86, 0.62, 0.34, 0.35 + 0.3 * alb_pulse), 1.3, true)
		Catalog.AMICE:
			# A shoulder linen. Not the alb's long white robe and not the wimple's wrapped coif.
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-16, -2),
				at + Vector2(16, -2),
				at + Vector2(14, 6),
				at + Vector2(-14, 6),
			]), Color("d8c49a"))
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-6, -10),
				at + Vector2(6, -10),
				at + Vector2(5, -1),
				at + Vector2(-5, -1),
			]), Color("efe4cc"))
			draw_line(at + Vector2(-14, 2), at + Vector2(14, 2), Color("8a7048"), 1.1)
			var amice_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.03)
			draw_arc(at + Vector2(0, 4), 16.0, 0.15, PI - 0.15, 14, Color(0.62, 0.48, 0.28, 0.35 + 0.3 * amice_pulse), 1.4, true)
		Catalog.ORPHREY:
			# An embroidered band. Not the amice's shoulder linen and not the alb's long white robe.
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-15, -4),
				at + Vector2(15, -4),
				at + Vector2(13, 5),
				at + Vector2(-13, 5),
			]), Color("c45a22"))
			draw_line(at + Vector2(-12, 0), at + Vector2(12, 0), Color("f0c36a"), 1.4)
			draw_line(at + Vector2(0, -3), at + Vector2(0, 4), Color("f0c36a"), 1.2)
			draw_line(at + Vector2(-3, 0), at + Vector2(3, 0), Color("6a3018"), 1.0)
			var orphrey_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.028)
			draw_arc(at + Vector2(0, 1), 16.0, 0.2, PI - 0.2, 14, Color(0.72, 0.34, 0.16, 0.35 + 0.3 * orphrey_pulse), 1.4, true)
		Catalog.MANIPLE:
			# A hanging wrist band. Not the orphrey's embroidered band and not the amice's shoulder linen.
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-4, -14),
				at + Vector2(4, -14),
				at + Vector2(5, 14),
				at + Vector2(-5, 14),
			]), Color("9c2430"))
			draw_line(at + Vector2(-3, -8), at + Vector2(3, -8), Color("f0c8c0"), 1.2)
			draw_line(at + Vector2(-3, 0), at + Vector2(3, 0), Color("6a1018"), 1.2)
			draw_line(at + Vector2(-3, 8), at + Vector2(3, 8), Color("f0c8c0"), 1.2)
			var maniple_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.026)
			draw_arc(at + Vector2(0, 2), 12.0, -0.6, 0.6, 8, Color(0.70, 0.16, 0.18, 0.35 + 0.3 * maniple_pulse), 1.4, true)
		Catalog.CHASUBLE:
			# A pale outer shell. Not the maniple's hanging wrist band and not the orphrey's embroidered arc.
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-14, -6),
				at + Vector2(0, -16),
				at + Vector2(14, -6),
				at + Vector2(12, 12),
				at + Vector2(0, 16),
				at + Vector2(-12, 12),
			]), Color("d7ebe2"))
			draw_polyline(PackedVector2Array([
				at + Vector2(-10, -2),
				at + Vector2(0, -11),
				at + Vector2(10, -2),
				at + Vector2(8, 8),
				at + Vector2(0, 11),
				at + Vector2(-8, 8),
				at + Vector2(-10, -2),
			]), Color("f7fbf8"), 1.5, true)
			var chasuble_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.024)
			draw_arc(at, 17.0, 0.45, TAU - 0.45, 18, Color(0.74, 0.84, 0.78, 0.35 + 0.3 * chasuble_pulse), 1.6, true)
		Catalog.DALMATIC:
			# A pale wide sleeve. Not the chasuble's outer shell and not the maniple's hanging wrist band.
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-16, -5),
				at + Vector2(16, -5),
				at + Vector2(14, 6),
				at + Vector2(-14, 6),
			]), Color("efe6c8"))
			draw_line(at + Vector2(-14, 0), at + Vector2(14, 0), Color("f8f4e4"), 1.5)
			draw_line(at + Vector2(-12, -3), at + Vector2(-12, 4), Color("b7a878"), 1.2)
			draw_line(at + Vector2(12, -3), at + Vector2(12, 4), Color("b7a878"), 1.2)
			var dalmatic_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.022)
			draw_arc(at + Vector2(0, 1), 16.0, PI + 0.4, TAU - 0.4, 12, Color(0.86, 0.80, 0.62, 0.35 + 0.3 * dalmatic_pulse), 1.6, true)
		Catalog.TUNICLE:
			# A narrow pale sleeve with a dark cuff. Not the dalmatic's wide sleeve.
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-8, -4),
				at + Vector2(9, -4),
				at + Vector2(8, 4),
				at + Vector2(-8, 4),
			]), Color("e7f1f6"))
			draw_line(at + Vector2(-6, 0), at + Vector2(5, 0), Color("f7fbfd"), 1.2)
			draw_line(at + Vector2(6, -4), at + Vector2(6, 4), Color("24303a"), 2.2)
			var tunicle_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.02)
			draw_arc(at + Vector2(-1, 1), 10.0, PI + 0.55, TAU - 0.55, 8, Color(0.62, 0.74, 0.82, 0.35 + 0.3 * tunicle_pulse), 1.4, true)
		Catalog.ROCHET:
			# A white skirt with a square yoke. Not the tunicle's narrow sleeve and not the dalmatic's wide sleeve.
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-5, -1),
				at + Vector2(5, -1),
				at + Vector2(11, 9),
				at + Vector2(-11, 9),
			]), Color("f7f4ee"))
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-4, -8),
				at + Vector2(4, -8),
				at + Vector2(4, -1),
				at + Vector2(-4, -1),
			]), Color("ffffff"))
			draw_rect(Rect2(at + Vector2(-4, -8), Vector2(8, 7)), Color("6e675c"), false, 1.2)
			var rochet_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.018)
			draw_arc(at + Vector2(0, 4), 9.0, 0.2, PI - 0.2, 8, Color(0.96, 0.94, 0.88, 0.35 + 0.3 * rochet_pulse), 1.3, true)
		Catalog.BIRETTA:
			# A black square cap with a pale pompon. Not the mozzetta's closed violet cape.
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-8, -8),
				at + Vector2(8, -8),
				at + Vector2(8, 2),
				at + Vector2(-8, 2),
			]), Color("2a2a2e"))
			draw_line(at + Vector2(-8, -3), at + Vector2(8, -3), Color("4a4a50"), 1.2)
			draw_circle(at + Vector2(0, -8), 2.2, Color("e7d7a4"))
			var biretta_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.012)
			draw_arc(at + Vector2(0, -2), 6.0, PI + 0.4, TAU - 0.4, 8, Color(0.75, 0.68, 0.42, 0.35 + 0.3 * biretta_pulse), 1.2, true)
		Catalog.MOZZETTA:
			# A short closed violet cape with one button. Not the chimere's open scarlet cape and pale lining.
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-10, -5),
				at + Vector2(10, -5),
				at + Vector2(8, 7),
				at + Vector2(-8, 7),
			]), Color("4a2a68"))
			draw_line(at + Vector2(-8, -5), at + Vector2(8, -5), Color("c9b6e0"), 1.3)
			draw_circle(at + Vector2(0, 1), 1.6, Color("f3e6d0"))
			var mozzetta_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.01)
			draw_arc(at + Vector2(0, 2), 7.0, 0.55, PI - 0.55, 8, Color(0.42, 0.24, 0.62, 0.35 + 0.3 * mozzetta_pulse), 1.2, true)
		Catalog.CHIMERE:
			# A scarlet shoulder cape with a pale lining, open in front. Not the cotta's short white flare and lace hem.
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-11, -6),
				at + Vector2(-2, -8),
				at + Vector2(-1, 8),
				at + Vector2(-12, 6),
			]), Color("8c1e28"))
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(11, -6),
				at + Vector2(2, -8),
				at + Vector2(1, 8),
				at + Vector2(12, 6),
			]), Color("8c1e28"))
			draw_line(at + Vector2(-2, -8), at + Vector2(-1, 8), Color("f3e6d0"), 1.4)
			draw_line(at + Vector2(2, -8), at + Vector2(1, 8), Color("f3e6d0"), 1.4)
			var chimere_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.011)
			draw_arc(at + Vector2(0, 1), 8.0, 0.4, PI - 0.4, 8, Color(0.85, 0.28, 0.32, 0.35 + 0.3 * chimere_pulse), 1.2, true)
		Catalog.COTTA:
			# A short white cotta, wider at a lace hem, with a dark collar. Not the surplice's long rectangle and solid hem.
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-5, -8),
				at + Vector2(5, -8),
				at + Vector2(9, 8),
				at + Vector2(-9, 8),
			]), Color("fbf6ea"))
			draw_rect(Rect2(at + Vector2(-5, -8), Vector2(10, 3)), Color("6d624c"), true)
			draw_line(at + Vector2(-7, 8), at + Vector2(-3, 8), Color("c8b48a"), 1.4)
			draw_line(at + Vector2(-1, 8), at + Vector2(3, 8), Color("c8b48a"), 1.4)
			draw_line(at + Vector2(5, 8), at + Vector2(9, 8), Color("c8b48a"), 1.4)
			var cotta_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.012)
			draw_line(at + Vector2(-4, 2), at + Vector2(4, 2), Color(0.86, 0.78, 0.58, 0.35 + 0.3 * cotta_pulse), 1.1)
		Catalog.SURPLICE:
			# A long white vestment with a straight hem. Not the cope's semicircle and gold clasp, and not the rochet's flared skirt.
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-6, -11),
				at + Vector2(6, -11),
				at + Vector2(6, 12),
				at + Vector2(-6, 12),
			]), Color("fbfcfe"))
			draw_line(at + Vector2(-6, 12), at + Vector2(6, 12), Color("8ea0b4"), 2.0)
			draw_line(at + Vector2(0, -11), at + Vector2(0, 12), Color("d5dde8"), 1.0)
			var surplice_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.014)
			draw_line(at + Vector2(-6, 2), at + Vector2(6, 2), Color(0.86, 0.90, 0.96, 0.35 + 0.3 * surplice_pulse), 1.2)
		Catalog.COPE:
			# A semicircular cope with a gold clasp. Not the rochet's white skirt and square yoke.
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-12, -2),
				at + Vector2(0, -8),
				at + Vector2(12, -2),
				at + Vector2(14, 9),
				at + Vector2(0, 12),
				at + Vector2(-14, 9),
			]), Color("3c4a78"))
			draw_line(at + Vector2(0, -7), at + Vector2(0, 11), Color("e2b34a"), 1.6)
			draw_circle(at + Vector2(0, -6), 2.2, Color("f0d48a"))
			var cope_pulse := 0.55 + 0.45 * sin(float(sim.tick) * 0.016)
			draw_arc(at + Vector2(0, 3), 13.0, 0.15, PI - 0.15, 12, Color(0.55, 0.62, 0.86, 0.35 + 0.3 * cope_pulse), 1.4, true)
		_:
			draw_circle(at, 6.0, Color.WHITE)


func _draw_shot(shot) -> void:
	var at := _screen(shot.pos)
	match int(shot.kind):
		Catalog.PEA:
			draw_circle(at, 3.2, Color("d6ff9a"))
		Catalog.VINE:
			draw_line(at - shot.dir * 7.0, at, Color("9be7a0"), 2.0)
		Catalog.LANTERN:
			draw_circle(at, 2.6, Color("fff1c2"))
		Catalog.WICK:
			draw_circle(at, 3.6, Color(1.0, 0.35, 0.12, 0.35))
			draw_circle(at, 2.2, Color("ff6a3a"))
			draw_circle(at, 1.0, Color("fff0e2"))
		Catalog.BRIAR:
			draw_line(at - shot.dir * 6.0, at, Color("a33d55"), 2.2)
			draw_circle(at, 2.0, Color("f0d0d4"))
		Catalog.FLARE:
			draw_circle(at, 4.0, Color(1.0, 0.82, 0.32, 0.35))
			draw_circle(at, 2.2, Color("ffe7a0"))
			draw_circle(at, 1.0, Color("fffaf0"))
		Catalog.HEARTH:
			draw_circle(at, 3.6, Color(0.7, 0.9, 1.0, 0.4))
			draw_circle(at, 2.0, Color("e7f6ff"))
			draw_circle(at, 0.9, Color("ffffff"))
		Catalog.SHEAR:
			draw_line(at - shot.dir * 7.0, at, Color("d9d0ee"), 2.0)
			draw_circle(at, 1.8, Color("f7f3ff"))
		Catalog.CHIME:
			draw_line(at + Vector2(-4, 0), at + Vector2(4, 0), Color("d8fff6"), 1.4)
			draw_line(at + Vector2(0, -4), at + Vector2(0, 4), Color("d8fff6"), 1.4)
			draw_circle(at, 1.6, Color("f4fffd"))
		Catalog.RASP:
			draw_line(at - shot.dir * 6.0, at, Color("e0b07a"), 2.2)
			draw_circle(at, 1.7, Color("f6e2c8"))
		Catalog.MAUL:
			draw_line(at - shot.dir * 7.0, at, Color("c5ced6"), 2.4)
			draw_circle(at, 2.0, Color("eef3f7"))
		Catalog.BILL:
			draw_line(at - shot.dir * 6.0, at, Color("e6d3b0"), 2.2)
			draw_circle(at, 1.8, Color("f6ead4"))
		Catalog.SHADE:
			draw_circle(at, 3.2, Color(0.35, 0.28, 0.48, 0.45))
			draw_circle(at, 1.6, Color("6a5c8a"))
		Catalog.COWL:
			draw_circle(at, 3.4, Color(0.93, 0.9, 0.82, 0.4))
			draw_arc(at, 4.4, 0.45, TAU - 0.6, 12, Color("f7f1e4"), 1.3, true)
		Catalog.HOOD:
			draw_circle(at, 3.2, Color(0.72, 0.56, 0.4, 0.45))
			draw_arc(at, 4.6, 0.5, TAU - 0.7, 12, Color("e6d4c0"), 1.3, true)
		Catalog.CLOAK:
			draw_circle(at, 3.0, Color(0.42, 0.36, 0.58, 0.5))
			draw_arc(at, 4.8, 0.65, TAU - 0.85, 12, Color("b7aed0"), 1.3, true)
		Catalog.CAPE:
			draw_circle(at, 3.0, Color(0.28, 0.52, 0.46, 0.5))
			draw_arc(at, 5.0, 0.35, TAU - 0.5, 12, Color("9ec8bc"), 1.3, true)
		Catalog.SHAWL:
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-4, 1),
				at + Vector2(-1, -4),
				at + Vector2(4, -1),
				at + Vector2(1, 4),
			]), Color("e7c9d6"))
			draw_line(at + Vector2(-1, -4), at + Vector2(1, 4), Color("6a3a56"), 1.3)
		Catalog.STOLE:
			draw_line(at - shot.dir * 6.0, at, Color("efe8d6"), 2.2)
			draw_line(at - shot.dir * 3.0, at, Color("8a8478"), 1.1)
		Catalog.MANTLE:
			draw_arc(at, 4.4, 0.3, PI - 0.3, 8, Color("e4eee6"), 1.7, true)
		Catalog.TIPPET:
			draw_line(at - shot.dir * 3.5, at + shot.dir * 3.5, Color("e8e2d4"), 1.2)
		Catalog.WIMPLE:
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-3, -2),
				at + Vector2(3, -3),
				at + Vector2(2, 3),
				at + Vector2(-3, 2),
			]), Color("c5d2a8"))
		Catalog.ALB:
			draw_line(at + Vector2(0, -5), at + Vector2(0, 5), Color("f4f0e4"), 2.0)
			draw_line(at + Vector2(-3, 4), at + Vector2(3, 4), Color("c8b89a"), 1.2)
		Catalog.AMICE:
			draw_line(at + Vector2(-5, 0), at + Vector2(5, 0), Color("d8c49a"), 2.2)
			draw_line(at + Vector2(-3, -2), at + Vector2(-3, 2), Color("8a7048"), 1.1)
			draw_line(at + Vector2(3, -2), at + Vector2(3, 2), Color("8a7048"), 1.1)
		Catalog.ORPHREY:
			draw_line(at + Vector2(-4, 0), at + Vector2(4, 0), Color("f0c36a"), 1.6)
			draw_line(at + Vector2(0, -4), at + Vector2(0, 4), Color("c45a22"), 1.6)
		Catalog.MANIPLE:
			draw_line(at + Vector2(0, -6), at + Vector2(0, 6), Color("9c2430"), 2.2)
			draw_line(at + Vector2(-3, -4), at + Vector2(3, -4), Color("f0c8c0"), 1.1)
		Catalog.CHASUBLE:
			draw_arc(at, 4.2, 0.5, TAU - 0.5, 12, Color("d7ebe2"), 1.6, true)
			draw_circle(at, 1.3, Color("f7fbf8"))
		Catalog.DALMATIC:
			draw_line(at + Vector2(-6, 0), at + Vector2(6, 0), Color("efe6c8"), 2.4)
			draw_line(at + Vector2(-5, -2), at + Vector2(-5, 2), Color("b7a878"), 1.1)
			draw_line(at + Vector2(5, -2), at + Vector2(5, 2), Color("b7a878"), 1.1)
		Catalog.TUNICLE:
			draw_line(at + Vector2(-4, 0), at + Vector2(3, 0), Color("e7f1f6"), 1.8)
			draw_line(at + Vector2(4, -2), at + Vector2(4, 2), Color("24303a"), 1.8)
		Catalog.ROCHET:
			draw_colored_polygon(PackedVector2Array([
				at + Vector2(-2, -3),
				at + Vector2(2, -3),
				at + Vector2(2, 1),
				at + Vector2(-2, 1),
			]), Color("ffffff"))
			draw_line(at + Vector2(-3, 2), at + Vector2(3, 4), Color("f7f4ee"), 1.6)
		Catalog.BIRETTA:
			draw_rect(Rect2(at + Vector2(-4, -3), Vector2(8, 5)), Color("2a2a2e"), true)
			draw_circle(at + Vector2(0, -3), 1.3, Color("e7d7a4"))
		Catalog.MOZZETTA:
			draw_line(at + Vector2(-5, -2), at + Vector2(5, -2), Color("4a2a68"), 2.0)
			draw_line(at + Vector2(-4, 2), at + Vector2(4, 3), Color("4a2a68"), 1.6)
			draw_circle(at + Vector2(0, 0), 1.2, Color("f3e6d0"))
		Catalog.CHIMERE:
			draw_line(at + Vector2(-2, -3), at + Vector2(-6, 2), Color("8c1e28"), 1.8)
			draw_line(at + Vector2(2, -3), at + Vector2(6, 2), Color("8c1e28"), 1.8)
			draw_circle(at + Vector2(0, -1), 1.2, Color("f3e6d0"))
		Catalog.COTTA:
			draw_line(at + Vector2(-3, -2), at + Vector2(-5, 4), Color("fbf6ea"), 1.6)
			draw_line(at + Vector2(3, -2), at + Vector2(5, 4), Color("fbf6ea"), 1.6)
			draw_circle(at + Vector2(0, -3), 1.3, Color("6d624c"))
		Catalog.SURPLICE:
			draw_line(at + Vector2(0, -6), at + Vector2(0, 5), Color("fbfcfe"), 2.0)
			draw_line(at + Vector2(-4, 5), at + Vector2(4, 5), Color("8ea0b4"), 1.6)
		Catalog.COPE:
			draw_arc(at, 4.6, 0.2, PI - 0.2, 8, Color("3c4a78"), 1.8, true)
			draw_circle(at + Vector2(0, -2), 1.4, Color("f0d48a"))
		_:
			draw_circle(at, 6.0, Color("ffb15a"))
			draw_circle(at, 2.5, Color("fff0d2"))


func _draw_pest(pest) -> void:
	var at := _screen(pest.pos)
	var flutter := sin(float(sim.tick) * 0.45 + float(pest.id)) * 3.0
	if _scurf_only(pest):
		_draw_scurf_moth(at, pest, flutter)
		return
	if _blain_only(pest):
		_draw_blain_moth(at, pest, flutter)
		return
	if _cauter_only(pest):
		_draw_cauter_moth(at, pest, flutter)
		return
	if _scathe_only(pest):
		_draw_scathe_moth(at, pest, flutter)
		return
	if _brand_only(pest):
		_draw_brand_moth(at, pest, flutter)
		return
	if _singe_only(pest):
		_draw_singe_moth(at, pest, flutter)
		return
	if _sear_only(pest):
		_draw_sear_moth(at, pest, flutter)
		return
	if _scorch_only(pest):
		_draw_scorch_moth(at, pest, flutter)
		return
	if _char_only(pest):
		_draw_char_moth(at, pest, flutter)
		return
	if _blister_only(pest):
		_draw_blister_moth(at, pest, flutter)
		return
	if _scald_only(pest):
		_draw_scald_moth(at, pest, flutter)
		return
	if _spot_only(pest):
		_draw_spot_moth(at, pest, flutter)
		return
	if _scab_only(pest):
		_draw_scab_moth(at, pest, flutter)
		return
	if _rust_only(pest):
		_draw_rust_moth(at, pest, flutter)
		return
	if _mildew_only(pest):
		_draw_mildew_moth(at, pest, flutter)
		return
	if _rot_only(pest):
		_draw_rot_moth(at, pest, flutter)
		return
	if _blight_only(pest):
		_draw_blight_moth(at, pest, flutter)
		return
	if _woe_only(pest):
		_draw_woe_moth(at, pest, flutter)
		return
	if _dread_only(pest):
		_draw_dread_moth(at, pest, flutter)
		return
	var wing := Color("3c3554")
	var body := Color("2a2438")
	if pest.shrouded and pest.rinded:
		wing = Color("34282c")
		body = Color("160e12")
	elif pest.shrouded:
		wing = Color("241820")
		body = Color("120e14")
	elif pest.rinded:
		wing = Color("6a5344")
		body = Color("3c2c22")
	elif pest.pitched:
		wing = Color("4a4030")
		body = Color("241c12")
	elif pest.frosted:
		wing = Color("7f97a8")
		body = Color("d5e6f0")
	elif pest.webbed:
		wing = Color("6a6280")
		body = Color("e4dced")
	elif pest.glassed:
		wing = Color("7eaaa4")
		body = Color("d7f3ee")
	elif pest.scaled:
		wing = Color("8a7058")
		body = Color("e6d2b4")
	elif pest.mailed:
		wing = Color("5c6770")
		body = Color("c5ced6")
	elif pest.hided:
		wing = Color("8a6a48")
		body = Color("e4c89a")
	elif pest.dusked:
		wing = Color("2e2c32")
		body = Color("141216")
	elif pest.veiled:
		wing = Color("d9d3c4")
		body = Color("f4efe4")
	elif pest.palled:
		wing = Color("b7a898")
		body = Color("efe4d4")
	elif pest.gloomed:
		wing = Color("4a4458")
		body = Color("2c2836")
	elif pest.murked:
		wing = Color("3a5248")
		body = Color("24342e")
	if pest.slow_ticks > 0:
		wing = Color("2f6b58")
		body = Color("21483c")
		if pest.shrouded or pest.rinded or pest.pitched or pest.frosted or pest.webbed or pest.glassed or pest.scaled or pest.mailed or pest.hided or pest.dusked or pest.veiled or pest.palled or pest.gloomed or pest.murked or pest.dreaded or pest.woed or pest.blighted or pest.rotted or pest.mildewed or pest.rusted or pest.scabbed or pest.spotted or pest.scalded or pest.blistered or pest.charred or pest.scorched or pest.seared or pest.singed or pest.branded or pest.scathed or pest.cautered or pest.blained or pest.scurfed:
			wing = Color("2a4038")
			body = Color("1c2c28")
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-14, flutter),
		at + Vector2(-4, 0),
		at + Vector2(-12, 8),
	]), wing)
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(14, -flutter),
		at + Vector2(4, 0),
		at + Vector2(12, 8),
	]), wing)
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(0, -8),
		at + Vector2(7, 0),
		at + Vector2(0, 8),
		at + Vector2(-7, 0),
	]), body)
	var eye := Color("f2e7c8")
	if pest.shrouded:
		eye = Color("ffb080")
	elif pest.frosted:
		eye = Color("d7f4ff")
	elif pest.webbed:
		eye = Color("f6e9ff")
	elif pest.glassed:
		eye = Color("e8fff8")
	elif pest.scaled:
		eye = Color("f0d8b0")
	elif pest.mailed:
		eye = Color("e7eef4")
	elif pest.hided:
		eye = Color("f6e6c8")
	elif pest.dusked:
		eye = Color("c8b8a8")
	elif pest.veiled:
		eye = Color("fff8ea")
	elif pest.palled:
		eye = Color("fff6ea")
	elif pest.gloomed:
		eye = Color("d8d0e4")
	elif pest.murked:
		eye = Color("d4e4dc")
	elif pest.pitched:
		eye = Color("e6c56a")
	draw_circle(at + Vector2(-2, -1), 1.3, eye)
	draw_circle(at + Vector2(2, -1), 1.3, eye)
	if pest.shrouded:
		draw_arc(at, 13.0, 0.45, TAU - 0.35, 18, Color(1.0, 0.42, 0.18, 0.85), 1.3, true)
	if pest.rinded:
		draw_arc(at, 16.0, 0.9, TAU - 0.7, 16, Color(0.86, 0.55, 0.62, 0.9), 1.3, true)
	if pest.pitched:
		draw_arc(at, 19.0, 0.2, TAU - 0.85, 14, Color(0.95, 0.78, 0.32, 0.9), 1.3, true)
	if pest.frosted:
		draw_arc(at, 22.0, 0.15, TAU - 0.5, 16, Color(0.75, 0.92, 1.0, 0.9), 1.3, true)
	if pest.webbed:
		draw_arc(at, 25.0, 0.35, TAU - 0.55, 18, Color(0.86, 0.78, 0.98, 0.9), 1.3, true)
	if pest.glassed:
		draw_arc(at, 28.0, 0.2, TAU - 0.45, 20, Color(0.72, 0.95, 0.9, 0.9), 1.3, true)
	if pest.scaled:
		draw_arc(at, 31.0, 0.25, TAU - 0.4, 20, Color(0.86, 0.64, 0.36, 0.9), 1.3, true)
	if pest.mailed:
		draw_arc(at, 34.0, 0.3, TAU - 0.35, 18, Color(0.78, 0.84, 0.9, 0.9), 1.3, true)
	if pest.hided:
		draw_arc(at, 37.0, 0.2, TAU - 0.4, 18, Color(0.86, 0.68, 0.4, 0.9), 1.3, true)
	if pest.dusked:
		draw_arc(at, 40.0, 0.45, TAU - 0.5, 18, Color(0.62, 0.5, 0.82, 0.9), 1.3, true)
	if pest.veiled:
		draw_arc(at, 43.0, 0.35, TAU - 0.55, 18, Color(0.95, 0.91, 0.82, 0.9), 1.3, true)
	if pest.palled:
		draw_arc(at, 46.0, 0.4, TAU - 0.6, 18, Color(0.62, 0.48, 0.36, 0.9), 1.3, true)
	if pest.gloomed:
		draw_arc(at, 49.0, 0.55, TAU - 0.75, 18, Color(0.42, 0.36, 0.58, 0.9), 1.3, true)
	if pest.murked:
		draw_arc(at, 52.0, 0.25, TAU - 0.5, 18, Color(0.32, 0.62, 0.52, 0.9), 1.3, true)
	if pest.dreaded:
		draw_arc(at, 55.0, 1.05, TAU - 1.2, 16, Color(0.82, 0.36, 0.44, 0.9), 1.3, true)
	if pest.woed:
		draw_arc(at, 58.0, 2.2, TAU - 0.45, 14, Color(0.22, 0.2, 0.18, 0.95), 2.0, true)
	if pest.blighted:
		draw_arc(at, 61.0, 0.55, TAU - 0.7, 16, Color(0.42, 0.58, 0.28, 0.95), 1.6, true)
	if pest.rotted:
		draw_arc(at, 64.0, 0.35, TAU - 0.9, 14, Color(0.55, 0.36, 0.18, 0.95), 1.6, true)
	if pest.mildewed:
		draw_arc(at, 67.0, 0.85, TAU - 1.15, 14, Color(0.62, 0.72, 0.34, 0.95), 1.6, true)
	if pest.rusted:
		draw_arc(at, 70.0, 0.55, TAU - 1.35, 14, Color(0.86, 0.42, 0.16, 0.95), 1.8, true)
	if pest.scabbed:
		draw_arc(at, 73.0, 0.7, TAU - 1.5, 14, Color(0.55, 0.42, 0.30, 0.95), 1.8, true)
	if pest.spotted:
		draw_arc(at, 76.0, 0.85, TAU - 1.7, 12, Color(0.78, 0.46, 0.14, 0.95), 1.8, true)
	if pest.scalded:
		draw_arc(at, 79.0, 1.05, TAU - 1.9, 12, Color(0.70, 0.16, 0.18, 0.95), 1.8, true)
	if pest.blistered:
		draw_arc(at, 82.0, 1.2, TAU - 2.05, 12, Color(0.74, 0.84, 0.78, 0.95), 1.8, true)
	if pest.charred:
		draw_arc(at, 85.0, 1.35, TAU - 2.2, 12, Color(0.42, 0.36, 0.28, 0.95), 1.8, true)
	if pest.scorched:
		draw_arc(at, 88.0, 1.5, TAU - 2.35, 12, Color(0.86, 0.42, 0.16, 0.95), 1.8, true)
	if pest.seared:
		draw_arc(at, 91.0, 1.65, TAU - 2.5, 12, Color(0.95, 0.90, 0.78, 0.95), 1.8, true)
	if pest.singed:
		draw_arc(at, 94.0, 1.8, TAU - 2.65, 12, Color(0.72, 0.36, 0.16, 0.95), 1.8, true)
	if pest.branded:
		draw_arc(at, 97.0, 1.95, TAU - 2.8, 12, Color(0.82, 0.88, 0.94, 0.95), 1.8, true)
	if pest.scathed:
		draw_arc(at, 100.0, 2.1, TAU - 2.95, 12, Color(0.86, 0.74, 0.42, 0.95), 1.8, true)
	if pest.cautered:
		draw_arc(at, 103.0, 2.25, TAU - 3.1, 12, Color(0.72, 0.28, 0.16, 0.95), 1.8, true)
	if pest.blained:
		draw_arc(at, 106.0, 2.4, TAU - 3.25, 12, Color(0.42, 0.24, 0.62, 0.95), 1.8, true)
	if pest.scurfed:
		draw_arc(at, 109.0, 2.55, TAU - 3.4, 12, Color(0.75, 0.68, 0.42, 0.95), 1.8, true)
	if pest.hp < Sim.PEST_HP:
		var width := 16.0 * clampf(float(pest.hp) / float(Sim.PEST_HP), 0.0, 1.0)
		draw_rect(Rect2(at + Vector2(-8, -14), Vector2(16, 3)), Color(0, 0, 0, 0.45), true)
		draw_rect(Rect2(at + Vector2(-8, -14), Vector2(width, 3)), Color("e0c48a"), true)


func _dread_only(pest) -> bool:
	return pest.dreaded and not pest.shrouded and not pest.rinded and not pest.pitched and not pest.frosted and not pest.webbed and not pest.glassed and not pest.scaled and not pest.mailed and not pest.hided and not pest.dusked and not pest.veiled and not pest.palled and not pest.gloomed and not pest.murked and not pest.woed and not pest.blighted and not pest.rotted and not pest.mildewed and not pest.rusted and not pest.scabbed and not pest.spotted and not pest.scalded and not pest.blistered and not pest.charred and not pest.scorched and not pest.seared and not pest.singed and not pest.branded and not pest.scathed and not pest.cautered and not pest.blained and not pest.scurfed


func _woe_only(pest) -> bool:
	return pest.woed and not pest.shrouded and not pest.rinded and not pest.pitched and not pest.frosted and not pest.webbed and not pest.glassed and not pest.scaled and not pest.mailed and not pest.hided and not pest.dusked and not pest.veiled and not pest.palled and not pest.gloomed and not pest.murked and not pest.dreaded and not pest.blighted and not pest.rotted and not pest.mildewed and not pest.rusted and not pest.scabbed and not pest.spotted and not pest.scalded and not pest.blistered and not pest.charred and not pest.scorched and not pest.seared and not pest.singed and not pest.branded and not pest.scathed and not pest.cautered and not pest.blained and not pest.scurfed


func _blight_only(pest) -> bool:
	return pest.blighted and not pest.shrouded and not pest.rinded and not pest.pitched and not pest.frosted and not pest.webbed and not pest.glassed and not pest.scaled and not pest.mailed and not pest.hided and not pest.dusked and not pest.veiled and not pest.palled and not pest.gloomed and not pest.murked and not pest.dreaded and not pest.woed and not pest.rotted and not pest.mildewed and not pest.rusted and not pest.scabbed and not pest.spotted and not pest.scalded and not pest.blistered and not pest.charred and not pest.scorched and not pest.seared and not pest.singed and not pest.branded and not pest.scathed and not pest.cautered and not pest.blained and not pest.scurfed


func _rot_only(pest) -> bool:
	return pest.rotted and not pest.shrouded and not pest.rinded and not pest.pitched and not pest.frosted and not pest.webbed and not pest.glassed and not pest.scaled and not pest.mailed and not pest.hided and not pest.dusked and not pest.veiled and not pest.palled and not pest.gloomed and not pest.murked and not pest.dreaded and not pest.woed and not pest.blighted and not pest.mildewed and not pest.rusted and not pest.scabbed and not pest.spotted and not pest.scalded and not pest.blistered and not pest.charred and not pest.scorched and not pest.seared and not pest.singed and not pest.branded and not pest.scathed and not pest.cautered and not pest.blained and not pest.scurfed


func _mildew_only(pest) -> bool:
	return pest.mildewed and not pest.shrouded and not pest.rinded and not pest.pitched and not pest.frosted and not pest.webbed and not pest.glassed and not pest.scaled and not pest.mailed and not pest.hided and not pest.dusked and not pest.veiled and not pest.palled and not pest.gloomed and not pest.murked and not pest.dreaded and not pest.woed and not pest.blighted and not pest.rotted and not pest.rusted and not pest.scabbed and not pest.spotted and not pest.scalded and not pest.blistered and not pest.charred and not pest.scorched and not pest.seared and not pest.singed and not pest.branded and not pest.scathed and not pest.cautered and not pest.blained and not pest.scurfed


func _scurf_only(pest) -> bool:
	return pest.scurfed and not pest.shrouded and not pest.rinded and not pest.pitched and not pest.frosted and not pest.webbed and not pest.glassed and not pest.scaled and not pest.mailed and not pest.hided and not pest.dusked and not pest.veiled and not pest.palled and not pest.gloomed and not pest.murked and not pest.dreaded and not pest.woed and not pest.blighted and not pest.rotted and not pest.mildewed and not pest.rusted and not pest.scabbed and not pest.spotted and not pest.scalded and not pest.blistered and not pest.charred and not pest.scorched and not pest.seared and not pest.singed and not pest.branded and not pest.scathed and not pest.cautered and not pest.blained


func _draw_scurf_moth(at: Vector2, pest, flutter: float) -> void:
	# A charcoal square cap with a pale pompon. Not the blain moth's plum cape and button.
	var cloth := Color("3a3a42")
	var pom := Color("e7d7a4")
	if pest.slow_ticks > 0:
		cloth = Color("24242c")
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-7, -7),
		at + Vector2(7, -7),
		at + Vector2(7, 3),
		at + Vector2(-7, 3),
	]), cloth)
	draw_circle(at + Vector2(0, -7 + flutter * 0.04), 1.6, pom)
	draw_arc(at, 14.0, PI + 0.5, TAU - 0.5, 10, Color("c8b88a"), 1.3, true)


func _blain_only(pest) -> bool:
	return pest.blained and not pest.shrouded and not pest.rinded and not pest.pitched and not pest.frosted and not pest.webbed and not pest.glassed and not pest.scaled and not pest.mailed and not pest.hided and not pest.dusked and not pest.veiled and not pest.palled and not pest.gloomed and not pest.murked and not pest.dreaded and not pest.woed and not pest.blighted and not pest.rotted and not pest.mildewed and not pest.rusted and not pest.scabbed and not pest.spotted and not pest.scalded and not pest.blistered and not pest.charred and not pest.scorched and not pest.seared and not pest.singed and not pest.branded and not pest.scathed and not pest.cautered and not pest.scurfed


func _draw_blain_moth(at: Vector2, pest, flutter: float) -> void:
	# A plum body closed by one button. Not the cauter moth's copper split.
	var cloth := Color("5c2a6a")
	var button := Color("f3e6d0")
	if pest.slow_ticks > 0:
		cloth = Color("3a1a44")
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-7, -6),
		at + Vector2(7, -6),
		at + Vector2(6, 6),
		at + Vector2(-6, 6),
	]), cloth)
	draw_circle(at + Vector2(0, flutter * 0.04), 1.5, button)
	draw_arc(at, 13.0, 0.8, TAU - 0.8, 10, Color("c9b6e0"), 1.3, true)


func _cauter_only(pest) -> bool:
	return pest.cautered and not pest.shrouded and not pest.rinded and not pest.pitched and not pest.frosted and not pest.webbed and not pest.glassed and not pest.scaled and not pest.mailed and not pest.hided and not pest.dusked and not pest.veiled and not pest.palled and not pest.gloomed and not pest.murked and not pest.dreaded and not pest.woed and not pest.blighted and not pest.rotted and not pest.mildewed and not pest.rusted and not pest.scabbed and not pest.spotted and not pest.scalded and not pest.blistered and not pest.charred and not pest.scorched and not pest.seared and not pest.singed and not pest.branded and not pest.scathed and not pest.blained and not pest.scurfed


func _draw_cauter_moth(at: Vector2, pest, flutter: float) -> void:
	# A copper body split down the front. Not the scathe moth's ivory notch.
	var cloth := Color("c45a32")
	var split := Color("f3e6d0")
	if pest.slow_ticks > 0:
		cloth = Color("8a3a28")
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-8, -6),
		at + Vector2(-1, -8),
		at + Vector2(-2, 7),
		at + Vector2(-9, 5),
	]), cloth)
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(8, -6),
		at + Vector2(1, -8),
		at + Vector2(2, 7),
		at + Vector2(9, 5),
	]), cloth)
	draw_line(at + Vector2(0, -8), at + Vector2(0, 7 + flutter * 0.04), split, 1.3)
	draw_arc(at, 12.0, 0.7, TAU - 0.7, 10, Color("e7b089"), 1.3, true)


func _scathe_only(pest) -> bool:
	return pest.scathed and not pest.shrouded and not pest.rinded and not pest.pitched and not pest.frosted and not pest.webbed and not pest.glassed and not pest.scaled and not pest.mailed and not pest.hided and not pest.dusked and not pest.veiled and not pest.palled and not pest.gloomed and not pest.murked and not pest.dreaded and not pest.woed and not pest.blighted and not pest.rotted and not pest.mildewed and not pest.rusted and not pest.scabbed and not pest.spotted and not pest.scalded and not pest.blistered and not pest.charred and not pest.scorched and not pest.seared and not pest.singed and not pest.branded and not pest.cautered and not pest.blained and not pest.scurfed


func _draw_scathe_moth(at: Vector2, pest, flutter: float) -> void:
	# An ivory body with a notched hem. Not the brand moth's grey rectangle and straight white hem.
	var cloth := Color("efe6c4")
	var notch := Color("8a7040")
	if pest.slow_ticks > 0:
		cloth = Color("c4b48a")
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-6, -7),
		at + Vector2(6, -7),
		at + Vector2(8, 5),
		at + Vector2(0, 2),
		at + Vector2(-8, 5),
	]), cloth)
	draw_line(at + Vector2(-8, 5), at + Vector2(0, 2 + flutter * 0.05), notch, 1.4)
	draw_line(at + Vector2(8, 5), at + Vector2(0, 2), notch, 1.4)
	draw_arc(at, 12.0, 0.55, TAU - 0.55, 10, Color("e2d2a4"), 1.3, true)


func _brand_only(pest) -> bool:
	return pest.branded and not pest.shrouded and not pest.rinded and not pest.pitched and not pest.frosted and not pest.webbed and not pest.glassed and not pest.scaled and not pest.mailed and not pest.hided and not pest.dusked and not pest.veiled and not pest.palled and not pest.gloomed and not pest.murked and not pest.dreaded and not pest.woed and not pest.blighted and not pest.rotted and not pest.mildewed and not pest.rusted and not pest.scabbed and not pest.spotted and not pest.scalded and not pest.blistered and not pest.charred and not pest.scorched and not pest.seared and not pest.singed and not pest.scathed and not pest.cautered and not pest.blained and not pest.scurfed


func _draw_brand_moth(at: Vector2, pest, flutter: float) -> void:
	# A grey body with a straight white hem. Not the singe moth's curled toast and not the sear moth's pale square.
	var cloth := Color("9aa6b4")
	var hem := Color("f7f9fc")
	if pest.slow_ticks > 0:
		cloth = Color("7e8b9a")
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-7, -6),
		at + Vector2(7, -6),
		at + Vector2(7, 6),
		at + Vector2(-7, 6),
	]), cloth)
	draw_line(at + Vector2(-7, 6), at + Vector2(7, 6), hem, 1.8)
	draw_line(at + Vector2(-2, -4 + flutter * 0.1), at + Vector2(-2, 4), hem, 1.0)
	draw_arc(at, 12.0, 0.4, TAU - 0.4, 12, Color("d5dde6"), 1.3, true)


func _singe_only(pest) -> bool:
	return pest.singed and not pest.shrouded and not pest.rinded and not pest.pitched and not pest.frosted and not pest.webbed and not pest.glassed and not pest.scaled and not pest.mailed and not pest.hided and not pest.dusked and not pest.veiled and not pest.palled and not pest.gloomed and not pest.murked and not pest.dreaded and not pest.woed and not pest.blighted and not pest.rotted and not pest.mildewed and not pest.rusted and not pest.scabbed and not pest.spotted and not pest.scalded and not pest.blistered and not pest.charred and not pest.scorched and not pest.seared and not pest.branded and not pest.scathed and not pest.cautered and not pest.blained and not pest.scurfed


func _draw_singe_moth(at: Vector2, pest, flutter: float) -> void:
	# A toasted body with a curled edge. Not the sear moth's pale square or the rochet's white skirt.
	var toast := Color("c46a32")
	var crust := Color("5a2e16")
	if pest.slow_ticks > 0:
		toast = Color("a85628")
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-10, flutter * 0.2),
		at + Vector2(-3, 2),
		at + Vector2(-8, 8),
		at + Vector2(-4, 5),
	]), crust)
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(9, -flutter * 0.15),
		at + Vector2(2, -1),
		at + Vector2(7, -7),
	]), crust)
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-2, -5),
		at + Vector2(4, -3),
		at + Vector2(2, 5),
		at + Vector2(-3, 3),
	]), toast)
	draw_line(at + Vector2(-1, -3), at + Vector2(3, 3), Color("f0c48a"), 1.2)
	draw_arc(at, 11.0, 0.9, TAU - 1.8, 10, Color("e08a3a"), 1.4, true)


func _sear_only(pest) -> bool:
	return pest.seared and not pest.shrouded and not pest.rinded and not pest.pitched and not pest.frosted and not pest.webbed and not pest.glassed and not pest.scaled and not pest.mailed and not pest.hided and not pest.dusked and not pest.veiled and not pest.palled and not pest.gloomed and not pest.murked and not pest.dreaded and not pest.woed and not pest.blighted and not pest.rotted and not pest.mildewed and not pest.rusted and not pest.scabbed and not pest.spotted and not pest.scalded and not pest.blistered and not pest.charred and not pest.scorched and not pest.singed and not pest.branded and not pest.scathed and not pest.cautered and not pest.blained and not pest.scurfed


func _scorch_only(pest) -> bool:
	return pest.scorched and not pest.shrouded and not pest.rinded and not pest.pitched and not pest.frosted and not pest.webbed and not pest.glassed and not pest.scaled and not pest.mailed and not pest.hided and not pest.dusked and not pest.veiled and not pest.palled and not pest.gloomed and not pest.murked and not pest.dreaded and not pest.woed and not pest.blighted and not pest.rotted and not pest.mildewed and not pest.rusted and not pest.scabbed and not pest.spotted and not pest.scalded and not pest.blistered and not pest.charred and not pest.seared and not pest.singed and not pest.branded and not pest.scathed and not pest.cautered and not pest.blained and not pest.scurfed


func _char_only(pest) -> bool:
	return pest.charred and not pest.shrouded and not pest.rinded and not pest.pitched and not pest.frosted and not pest.webbed and not pest.glassed and not pest.scaled and not pest.mailed and not pest.hided and not pest.dusked and not pest.veiled and not pest.palled and not pest.gloomed and not pest.murked and not pest.dreaded and not pest.woed and not pest.blighted and not pest.rotted and not pest.mildewed and not pest.rusted and not pest.scabbed and not pest.spotted and not pest.scalded and not pest.blistered and not pest.scorched and not pest.seared and not pest.singed and not pest.branded and not pest.scathed and not pest.cautered and not pest.blained and not pest.scurfed


func _blister_only(pest) -> bool:
	return pest.blistered and not pest.shrouded and not pest.rinded and not pest.pitched and not pest.frosted and not pest.webbed and not pest.glassed and not pest.scaled and not pest.mailed and not pest.hided and not pest.dusked and not pest.veiled and not pest.palled and not pest.gloomed and not pest.murked and not pest.dreaded and not pest.woed and not pest.blighted and not pest.rotted and not pest.mildewed and not pest.rusted and not pest.scabbed and not pest.spotted and not pest.scalded and not pest.charred and not pest.scorched and not pest.seared and not pest.singed and not pest.branded and not pest.scathed and not pest.cautered and not pest.blained and not pest.scurfed


func _scald_only(pest) -> bool:
	return pest.scalded and not pest.shrouded and not pest.rinded and not pest.pitched and not pest.frosted and not pest.webbed and not pest.glassed and not pest.scaled and not pest.mailed and not pest.hided and not pest.dusked and not pest.veiled and not pest.palled and not pest.gloomed and not pest.murked and not pest.dreaded and not pest.woed and not pest.blighted and not pest.rotted and not pest.mildewed and not pest.rusted and not pest.scabbed and not pest.spotted and not pest.blistered and not pest.charred and not pest.scorched and not pest.seared and not pest.singed and not pest.branded and not pest.scathed and not pest.cautered and not pest.blained and not pest.scurfed


func _spot_only(pest) -> bool:
	return pest.spotted and not pest.shrouded and not pest.rinded and not pest.pitched and not pest.frosted and not pest.webbed and not pest.glassed and not pest.scaled and not pest.mailed and not pest.hided and not pest.dusked and not pest.veiled and not pest.palled and not pest.gloomed and not pest.murked and not pest.dreaded and not pest.woed and not pest.blighted and not pest.rotted and not pest.mildewed and not pest.rusted and not pest.scabbed and not pest.scalded and not pest.blistered and not pest.charred and not pest.scorched and not pest.seared and not pest.singed and not pest.branded and not pest.scathed and not pest.cautered and not pest.blained and not pest.scurfed


func _scab_only(pest) -> bool:
	return pest.scabbed and not pest.shrouded and not pest.rinded and not pest.pitched and not pest.frosted and not pest.webbed and not pest.glassed and not pest.scaled and not pest.mailed and not pest.hided and not pest.dusked and not pest.veiled and not pest.palled and not pest.gloomed and not pest.murked and not pest.dreaded and not pest.woed and not pest.blighted and not pest.rotted and not pest.mildewed and not pest.rusted and not pest.spotted and not pest.scalded and not pest.blistered and not pest.charred and not pest.scorched and not pest.seared and not pest.singed and not pest.branded and not pest.scathed and not pest.cautered and not pest.blained and not pest.scurfed


func _rust_only(pest) -> bool:
	return pest.rusted and not pest.shrouded and not pest.rinded and not pest.pitched and not pest.frosted and not pest.webbed and not pest.glassed and not pest.scaled and not pest.mailed and not pest.hided and not pest.dusked and not pest.veiled and not pest.palled and not pest.gloomed and not pest.murked and not pest.dreaded and not pest.woed and not pest.blighted and not pest.rotted and not pest.mildewed and not pest.scabbed and not pest.spotted and not pest.scalded and not pest.blistered and not pest.charred and not pest.scorched and not pest.seared and not pest.singed and not pest.branded and not pest.scathed and not pest.cautered and not pest.blained and not pest.scurfed


func _draw_sear_moth(at: Vector2, pest, flutter: float) -> void:
	# A bleached sear with a square crack. Not the scorch moth's heat ring or the char moth's charcoal ring.
	var pale := Color("f3efe4")
	var crust := Color("8a5a32")
	if pest.slow_ticks > 0:
		pale = Color("e4d8c4")
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-8, flutter * 0.12),
		at + Vector2(-2, 1),
		at + Vector2(-6, 6),
	]), crust)
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(8, -flutter * 0.12),
		at + Vector2(2, 0),
		at + Vector2(6, -5),
	]), crust)
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-3, -4),
		at + Vector2(3, -4),
		at + Vector2(3, 4),
		at + Vector2(-3, 4),
	]), pale)
	draw_rect(Rect2(at + Vector2(-2, -2), Vector2(4, 4)), crust, false, 1.1)
	draw_arc(at, 12.0, 0.4, TAU - 1.2, 12, Color("f7f1e2"), 1.4, true)


func _draw_scorch_moth(at: Vector2, pest, flutter: float) -> void:
	# A blackened body and a broken heat ring. Not the char moth's charcoal ring or the dalmatic's wide sleeve.
	var crack := Color("e07030")
	var coal := Color("241c16")
	if pest.slow_ticks > 0:
		coal = Color("1a1612")
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-9, flutter * 0.15),
		at + Vector2(-2, 0),
		at + Vector2(-7, 7),
	]), Color("4a3428"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(9, -flutter * 0.15),
		at + Vector2(2, 0),
		at + Vector2(7, -6),
	]), Color("4a3428"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-3, -5),
		at + Vector2(3, -4),
		at + Vector2(2, 5),
		at + Vector2(-2, 4),
	]), coal)
	draw_line(at + Vector2(-1, -2), at + Vector2(2, 2), crack, 1.2)
	draw_arc(at, 13.0, 0.7, TAU - 1.5, 12, crack, 1.5, true)


func _draw_char_moth(at: Vector2, pest, flutter: float) -> void:
	# A charred body and a broken charcoal ring. Not the blister moth's pale shell or the scald moth's heat blisters.
	var ash := Color("c8bba4")
	var soot := Color("3a342c")
	if pest.slow_ticks > 0:
		soot = Color("2a2824")
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-12, flutter * 0.2),
		at + Vector2(-3, 1),
		at + Vector2(-10, 8),
	]), Color("6a5e4e"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(12, -flutter * 0.2),
		at + Vector2(3, 1),
		at + Vector2(10, 8),
	]), Color("6a5e4e"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(0, -8),
		at + Vector2(6, 0),
		at + Vector2(4, 9),
		at + Vector2(-4, 9),
		at + Vector2(-6, 0),
	]), soot)
	draw_line(at + Vector2(-3, 2), at + Vector2(2, -1), ash, 1.1)
	draw_line(at + Vector2(1, 3), at + Vector2(3, 0), ash, 1.0)
	draw_circle(at + Vector2(-2, -1), 0.7, Color("1c1814"))
	draw_circle(at + Vector2(2, -1), 0.7, Color("1c1814"))
	draw_arc(at, 16.0, 1.35, TAU - 2.2, 10, Color(0.42, 0.36, 0.28, 0.95), 2.0, true)
	if pest.hp < Sim.PEST_HP:
		var width := 16.0 * clampf(float(pest.hp) / float(Sim.PEST_HP), 0.0, 1.0)
		draw_rect(Rect2(at + Vector2(-8, -14), Vector2(16, 3)), Color(0, 0, 0, 0.45), true)
		draw_rect(Rect2(at + Vector2(-8, -14), Vector2(width, 3)), Color("e0c48a"), true)


func _draw_blister_moth(at: Vector2, pest, flutter: float) -> void:
	# A pale shell and a broken shell ring. Not the scald moth's heat blisters, the spot moth's marks, or the scab moth's crust.
	var shell := Color("e7f3ec")
	var body := Color("8aa898")
	if pest.slow_ticks > 0:
		body = Color("5c6e64")
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-12, flutter * 0.2),
		at + Vector2(-3, 1),
		at + Vector2(-10, 8),
	]), Color("b7d0c4"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(12, -flutter * 0.2),
		at + Vector2(3, 1),
		at + Vector2(10, 8),
	]), Color("b7d0c4"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(0, -8),
		at + Vector2(6, 0),
		at + Vector2(4, 9),
		at + Vector2(-4, 9),
		at + Vector2(-6, 0),
	]), body)
	draw_circle(at + Vector2(-3, 1), 2.2, shell)
	draw_circle(at + Vector2(3, 2), 1.8, shell)
	draw_circle(at + Vector2(0, -2), 1.5, shell)
	draw_circle(at + Vector2(-2, -1), 0.7, Color("24302c"))
	draw_circle(at + Vector2(2, -1), 0.7, Color("24302c"))
	draw_arc(at, 16.0, 1.2, TAU - 2.05, 10, Color(0.74, 0.84, 0.78, 0.95), 2.0, true)
	if pest.hp < Sim.PEST_HP:
		var width := 16.0 * clampf(float(pest.hp) / float(Sim.PEST_HP), 0.0, 1.0)
		draw_rect(Rect2(at + Vector2(-8, -14), Vector2(16, 3)), Color(0, 0, 0, 0.45), true)
		draw_rect(Rect2(at + Vector2(-8, -14), Vector2(width, 3)), Color("e0c48a"), true)


func _draw_scald_moth(at: Vector2, pest, flutter: float) -> void:
	# A blistered body and a broken heat ring. Not the spot moth's marks, the scab moth's crust, or the rust moth's copper flake.
	var blister := Color("f2d2c8")
	var heat := Color("7a1824")
	if pest.slow_ticks > 0:
		heat = Color("4a3030")
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-11, flutter * 0.25),
		at + Vector2(-2, 0),
		at + Vector2(-9, 7),
	]), Color("c45048"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(11, -flutter * 0.25),
		at + Vector2(2, 0),
		at + Vector2(9, 7),
	]), Color("c45048"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(0, -7),
		at + Vector2(5, 1),
		at + Vector2(3, 8),
		at + Vector2(-3, 8),
		at + Vector2(-5, 1),
	]), heat)
	draw_circle(at + Vector2(-2, 2), 1.8, blister)
	draw_circle(at + Vector2(2, 3), 1.4, blister)
	draw_circle(at + Vector2(0, 0), 1.2, blister)
	draw_circle(at + Vector2(-2, -1), 0.8, Color("2a0c10"))
	draw_circle(at + Vector2(2, -1), 0.8, Color("2a0c10"))
	draw_arc(at, 16.0, 1.05, TAU - 1.9, 10, Color(0.70, 0.16, 0.18, 0.95), 2.0, true)
	if pest.hp < Sim.PEST_HP:
		var width := 16.0 * clampf(float(pest.hp) / float(Sim.PEST_HP), 0.0, 1.0)
		draw_rect(Rect2(at + Vector2(-8, -16), Vector2(16, 3)), Color(0, 0, 0, 0.45), true)
		draw_rect(Rect2(at + Vector2(-8, -16), Vector2(width, 3)), Color("e0c48a"), true)


func _draw_spot_moth(at: Vector2, pest, flutter: float) -> void:
	# A marked body and a broken spot ring. Not the scab moth's crust, the rust moth's copper flake, or the rot moth's speckled husk.
	var mark := Color("5a3418")
	var cloth := Color("e7c39a")
	if pest.slow_ticks > 0:
		cloth = Color("8a7048")
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-12, flutter * 0.2),
		at + Vector2(-3, 1),
		at + Vector2(-10, 8),
	]), Color("a86830"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(12, -flutter * 0.2),
		at + Vector2(3, 1),
		at + Vector2(10, 8),
	]), Color("a86830"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(0, -6),
		at + Vector2(6, 0),
		at + Vector2(0, 8),
		at + Vector2(-6, 0),
	]), cloth)
	draw_circle(at + Vector2(-2, 2), 1.5, mark)
	draw_circle(at + Vector2(2, 3), 1.3, mark)
	draw_circle(at + Vector2(0, -1), 1.1, mark)
	draw_circle(at + Vector2(-2, -1), 0.9, Color("2a160c"))
	draw_circle(at + Vector2(2, -1), 0.9, Color("2a160c"))
	draw_arc(at, 16.0, 0.85, TAU - 1.7, 10, Color(0.78, 0.46, 0.14, 0.95), 2.0, true)
	if pest.hp < Sim.PEST_HP:
		var width := 16.0 * clampf(float(pest.hp) / float(Sim.PEST_HP), 0.0, 1.0)
		draw_rect(Rect2(at + Vector2(-8, -16), Vector2(16, 3)), Color(0, 0, 0, 0.45), true)
		draw_rect(Rect2(at + Vector2(-8, -16), Vector2(width, 3)), Color("e0c48a"), true)


func _draw_scab_moth(at: Vector2, pest, flutter: float) -> void:
	# A crusted body and a broken scab ring. Not the rust moth's copper flake and not the rot moth's speckled husk.
	var crust := Color("6e5a48")
	var shell := Color("c8b49a")
	if pest.slow_ticks > 0:
		shell = Color("8a8074")
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-13, flutter * 0.15),
		at + Vector2(-4, 2),
		at + Vector2(-11, 9),
	]), Color("4a3c30"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(13, -flutter * 0.15),
		at + Vector2(4, 2),
		at + Vector2(11, 9),
	]), Color("4a3c30"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(0, -7),
		at + Vector2(6, 1),
		at + Vector2(4, 9),
		at + Vector2(-4, 9),
		at + Vector2(-6, 1),
	]), shell)
	draw_circle(at + Vector2(-2, 3), 1.7, crust)
	draw_circle(at + Vector2(2, 5), 1.4, crust)
	draw_circle(at + Vector2(0, 1), 1.1, crust)
	draw_circle(at + Vector2(-2, -1), 1.0, Color("2c2218"))
	draw_circle(at + Vector2(2, -1), 1.0, Color("2c2218"))
	draw_arc(at, 16.0, 0.6, TAU - 1.55, 12, Color(0.55, 0.42, 0.30, 0.95), 2.1, true)
	if pest.hp < Sim.PEST_HP:
		var width := 16.0 * clampf(float(pest.hp) / float(Sim.PEST_HP), 0.0, 1.0)
		draw_rect(Rect2(at + Vector2(-8, -16), Vector2(16, 3)), Color(0, 0, 0, 0.45), true)
		draw_rect(Rect2(at + Vector2(-8, -16), Vector2(width, 3)), Color("e0c48a"), true)


func _draw_rust_moth(at: Vector2, pest, flutter: float) -> void:
	# A flaking copper body and a broken oxide ring. Not the rot moth's speckled husk.
	var flake := Color("c45a22")
	var copper := Color("e8a060")
	if pest.slow_ticks > 0:
		copper = Color("a88868")
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-12, flutter * 0.2),
		at + Vector2(-3, 1),
		at + Vector2(-10, 8),
	]), Color("8a3e18"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(12, -flutter * 0.2),
		at + Vector2(3, 1),
		at + Vector2(10, 8),
	]), Color("8a3e18"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(0, -8),
		at + Vector2(5, 0),
		at + Vector2(3, 8),
		at + Vector2(-3, 8),
		at + Vector2(-5, 0),
	]), copper)
	draw_circle(at + Vector2(-2, 2), 1.5, flake)
	draw_circle(at + Vector2(2, 4), 1.2, flake)
	draw_circle(at + Vector2(0, -1), 1.0, Color("4a2410"))
	draw_circle(at + Vector2(2, -1), 1.0, Color("4a2410"))
	draw_arc(at, 15.0, 0.45, TAU - 1.4, 12, Color(0.86, 0.42, 0.16, 0.95), 2.0, true)
	if pest.hp < Sim.PEST_HP:
		var width := 16.0 * clampf(float(pest.hp) / float(Sim.PEST_HP), 0.0, 1.0)
		draw_rect(Rect2(at + Vector2(-8, -16), Vector2(16, 3)), Color(0, 0, 0, 0.45), true)
		draw_rect(Rect2(at + Vector2(-8, -16), Vector2(width, 3)), Color("e0c48a"), true)


func _draw_mildew_moth(at: Vector2, pest, flutter: float) -> void:
	# A dusted body and a broken chartreuse ring. Not the rot moth's speckled husk.
	var dust := Color("8a9a62")
	var film := Color("e4ecd0")
	if pest.slow_ticks > 0:
		film = Color("9aa48c")
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-11, flutter * 0.25),
		at + Vector2(-2, 2),
		at + Vector2(-9, 7),
	]), Color("6a7848"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(11, -flutter * 0.25),
		at + Vector2(2, 2),
		at + Vector2(9, 7),
	]), Color("6a7848"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(0, -7),
		at + Vector2(4, 1),
		at + Vector2(2, 8),
		at + Vector2(-2, 8),
		at + Vector2(-4, 1),
	]), film)
	draw_circle(at + Vector2(-1, 2), 1.6, dust)
	draw_circle(at + Vector2(2, 4), 1.3, dust)
	draw_circle(at + Vector2(0, -1), 1.0, Color("3a4428"))
	draw_circle(at + Vector2(2, -1), 1.0, Color("3a4428"))
	draw_arc(at, 15.0, 0.7, TAU - 1.2, 12, Color(0.62, 0.72, 0.34, 0.95), 2.0, true)
	if pest.hp < Sim.PEST_HP:
		var width := 16.0 * clampf(float(pest.hp) / float(Sim.PEST_HP), 0.0, 1.0)
		draw_rect(Rect2(at + Vector2(-8, -16), Vector2(16, 3)), Color(0, 0, 0, 0.45), true)
		draw_rect(Rect2(at + Vector2(-8, -16), Vector2(width, 3)), Color("e0c48a"), true)


func _draw_rot_moth(at: Vector2, pest, flutter: float) -> void:
	# A speckled body and a broken rust ring. Not the blight moth's stained olive ring.
	var speck := Color("8a6238")
	var husk := Color("c4a882")
	if pest.slow_ticks > 0:
		husk = Color("8a8474")
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-12, flutter * 0.3),
		at + Vector2(-3, 1),
		at + Vector2(-10, 6),
	]), Color("6a5038"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(12, -flutter * 0.3),
		at + Vector2(3, 1),
		at + Vector2(10, 6),
	]), Color("6a5038"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(0, -8),
		at + Vector2(5, 0),
		at + Vector2(3, 9),
		at + Vector2(-3, 9),
		at + Vector2(-5, 0),
	]), husk)
	draw_circle(at + Vector2(-2, 1), 1.4, speck)
	draw_circle(at + Vector2(2, 4), 1.2, speck)
	draw_circle(at + Vector2(0, 6), 1.0, speck)
	draw_circle(at + Vector2(-2, -1), 1.0, Color("3a2818"))
	draw_circle(at + Vector2(2, -1), 1.0, Color("3a2818"))
	draw_arc(at, 15.0, 0.25, TAU - 1.05, 12, Color(0.55, 0.36, 0.18, 0.95), 2.0, true)
	if pest.hp < Sim.PEST_HP:
		var width := 16.0 * clampf(float(pest.hp) / float(Sim.PEST_HP), 0.0, 1.0)
		draw_rect(Rect2(at + Vector2(-8, -16), Vector2(16, 3)), Color(0, 0, 0, 0.45), true)
		draw_rect(Rect2(at + Vector2(-8, -16), Vector2(width, 3)), Color("e0c48a"), true)


func _draw_blight_moth(at: Vector2, pest, flutter: float) -> void:
	# A stained body and a broken olive ring. Not the woe moth's ash body and coal ring.
	var stain := Color("6a7a48")
	var leaf := Color("c5d2a4")
	if pest.slow_ticks > 0:
		leaf = Color("8a9478")
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-13, flutter * 0.35),
		at + Vector2(-4, 1),
		at + Vector2(-11, 7),
	]), Color("4e5a38"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(13, -flutter * 0.35),
		at + Vector2(4, 1),
		at + Vector2(11, 7),
	]), Color("4e5a38"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(0, -9),
		at + Vector2(6, 0),
		at + Vector2(3, 10),
		at + Vector2(-3, 10),
		at + Vector2(-6, 0),
	]), leaf)
	draw_circle(at + Vector2(-2, 2), 2.2, stain)
	draw_circle(at + Vector2(3, 5), 1.6, stain)
	draw_circle(at + Vector2(-2, -1), 1.1, Color("243018"))
	draw_circle(at + Vector2(2, -1), 1.1, Color("243018"))
	draw_arc(at, 15.0, 0.4, TAU - 0.85, 14, Color(0.42, 0.58, 0.28, 0.95), 2.0, true)
	if pest.hp < Sim.PEST_HP:
		var width := 16.0 * clampf(float(pest.hp) / float(Sim.PEST_HP), 0.0, 1.0)
		draw_rect(Rect2(at + Vector2(-8, -16), Vector2(16, 3)), Color(0, 0, 0, 0.45), true)
		draw_rect(Rect2(at + Vector2(-8, -16), Vector2(width, 3)), Color("e0c48a"), true)


func _draw_woe_moth(at: Vector2, pest, flutter: float) -> void:
	# An ash body and a broken coal ring. Not the dread moth's split shard.
	var ash := Color("8d8882")
	var coal := Color("1c1916")
	if pest.slow_ticks > 0:
		ash = Color("6e746c")
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-12, flutter * 0.4),
		at + Vector2(-3, -1),
		at + Vector2(-10, 6),
	]), Color("5c5854"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(12, -flutter * 0.4),
		at + Vector2(3, -1),
		at + Vector2(10, 6),
	]), Color("5c5854"))
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(0, -11),
		at + Vector2(5, -2),
		at + Vector2(4, 10),
		at + Vector2(-4, 10),
		at + Vector2(-5, -2),
	]), ash)
	draw_line(at + Vector2(-3, -6), at + Vector2(2, 8), Color("d9d4cc"), 1.1)
	draw_circle(at + Vector2(-2, -2), 1.1, Color("2a2622"))
	draw_circle(at + Vector2(2, -2), 1.1, Color("2a2622"))
	draw_arc(at, 15.0, 0.7, TAU - 1.35, 14, coal, 2.2, true)
	if pest.hp < Sim.PEST_HP:
		var width := 16.0 * clampf(float(pest.hp) / float(Sim.PEST_HP), 0.0, 1.0)
		draw_rect(Rect2(at + Vector2(-8, -16), Vector2(16, 3)), Color(0, 0, 0, 0.45), true)
		draw_rect(Rect2(at + Vector2(-8, -16), Vector2(width, 3)), Color("e0c48a"), true)


func _draw_dread_moth(at: Vector2, pest, flutter: float) -> void:
	# A split shard and torn wings. Not the murk moth's diamond and green ring.
	var wing := Color("4a3040")
	var shard := Color("f3e6d4")
	var crack := Color("2a1820")
	if pest.slow_ticks > 0:
		wing = Color("3a4038")
		shard = Color("d7d2c4")
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-18, flutter - 4),
		at + Vector2(-6, -2),
		at + Vector2(-13, 3),
		at + Vector2(-16, 7),
	]), wing)
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(17, -flutter + 3),
		at + Vector2(6, -1),
		at + Vector2(14, 5),
		at + Vector2(12, 9),
	]), wing)
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-1, -12),
		at + Vector2(-8, -1),
		at + Vector2(-2, 11),
		at + Vector2(-1, 0),
	]), shard)
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(3, -10),
		at + Vector2(10, 1),
		at + Vector2(3, 12),
		at + Vector2(2, 1),
	]), shard)
	draw_line(at + Vector2(-1, -10), at + Vector2(2, 11), crack, 1.6)
	draw_circle(at + Vector2(-3, -2), 1.2, Color("ffd2c8"))
	draw_circle(at + Vector2(4, -1), 1.2, Color("ffd2c8"))
	draw_arc(at, 55.0, 1.05, TAU - 1.2, 16, Color(0.82, 0.36, 0.44, 0.9), 1.3, true)
	if pest.hp < Sim.PEST_HP:
		var width := 16.0 * clampf(float(pest.hp) / float(Sim.PEST_HP), 0.0, 1.0)
		draw_rect(Rect2(at + Vector2(-8, -16), Vector2(16, 3)), Color(0, 0, 0, 0.45), true)
		draw_rect(Rect2(at + Vector2(-8, -16), Vector2(width, 3)), Color("e0c48a"), true)


func _draw_motes() -> void:
	for mote in motes:
		var life := clampf(float(mote["life"]) / float(mote["max_life"]), 0.0, 1.0)
		var color: Color = mote["color"]
		color.a = life
		var radius := float(mote["radius"]) * (0.55 + 0.45 * life)
		var at := _screen(mote["pos"])
		draw_circle(at, radius + 2.0, Color(color.r, color.g, color.b, life * 0.25))
		draw_circle(at, radius, color)


func _draw_gardener() -> void:
	var at := _screen(sim.player_pos)
	var flash: bool = int(sim.hurt_ticks) > Sim.HURT_TICKS - 6
	var coat := Color("f2f4f8") if flash else Color("24344a")
	var skin := Color("fff4ea") if flash else Color("e4c3a0")
	draw_set_transform(at + Vector2(0, 14), 0.0, Vector2(1.0, 0.4))
	draw_circle(Vector2.ZERO, 10.0, Color(0, 0, 0, 0.35))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_colored_polygon(PackedVector2Array([
		at + Vector2(-8, 12),
		at + Vector2(8, 12),
		at + Vector2(6, -2),
		at + Vector2(-6, -2),
	]), coat)
	draw_circle(at + Vector2(0, -8), 6.0, skin)
	draw_rect(Rect2(at + Vector2(-9, -12), Vector2(18, 3)), Color("3a3228"), true)
	draw_rect(Rect2(at + Vector2(-4, -18), Vector2(8, 7)), Color("4a4034"), true)


func _screen(world: Vector2) -> Vector2:
	return ORIGIN + world


func _tile_rect(tx: int, ty: int) -> Rect2:
	return Rect2(ORIGIN + Vector2(float(tx), float(ty)) * Sim.TILE, Vector2(Sim.TILE, Sim.TILE))
