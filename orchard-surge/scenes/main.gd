extends Node2D

## View and input for Orchard Surge. Combat, light, planting, and damage live in OrchardSim.

const Sim = preload("res://sim/orchard_sim.gd")
const Catalog = preload("res://sim/plant_catalog.gd")
const Tooltip = preload("res://ui/plant_tooltip.gd")

const ORIGIN := Vector2(16, 76)
const CARD_W := 352.0
const CARD_H := 312.0
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

	seeds_label = _label("Seeds 11", 15, Color("e7d7a4"))
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
	hint_box.size = Vector2(720, 88)
	hint_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint_box.clip_contents = true
	layer.add_child(hint_box)
	hint_label = _label("Move: WASD or arrows, paused while planting. Plant with 1-9, 0, B, C, E, or F, then click a tile. Only a wick burns shroud. Only a briar cracks rind. Only a flare melts pitch. Only a hearth thaws frost. Only a shear cuts web. Only a chime cracks glass. Only a rasp strips scale. Only a maul cracks mail. Only a bill splits hide. Only a shade shades dusk.", 13, Color("aeb8a4"))
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
		panel.position = Vector2(CARD_LEFT, CARD_TOP + float(kind) * (CARD_H + CARD_GAP))
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
		box.add_theme_constant_override("separation", 0)
		panel.add_child(box)
		var hotkey := _label(_hotkey_text(kind), 12, KIND_COLOR[kind])
		hotkey.name = "Hotkey"
		hotkey.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(hotkey)
		var index := 0
		for line in Tooltip.stat_lines(kind):
			var row := _label(line, 12 if index > 0 else 15, Color("f4f0e4") if index == 0 else Color("d5d0c4"))
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
		outcome_label.text = "The surge breaks.\nTwenty-three nights passed, and the orchard still stands."
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
	return str(kind + 1)


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
	style.content_margin_top = 6
	style.content_margin_bottom = 6
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
		_:
			draw_circle(at, 6.0, Color("ffb15a"))
			draw_circle(at, 2.5, Color("fff0d2"))


func _draw_pest(pest) -> void:
	var at := _screen(pest.pos)
	var flutter := sin(float(sim.tick) * 0.45 + float(pest.id)) * 3.0
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
	if pest.slow_ticks > 0:
		wing = Color("2f6b58")
		body = Color("21483c")
		if pest.shrouded or pest.rinded or pest.pitched or pest.frosted or pest.webbed or pest.glassed or pest.scaled or pest.mailed or pest.hided or pest.dusked:
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
	if pest.hp < Sim.PEST_HP:
		var width := 16.0 * clampf(float(pest.hp) / float(Sim.PEST_HP), 0.0, 1.0)
		draw_rect(Rect2(at + Vector2(-8, -14), Vector2(16, 3)), Color(0, 0, 0, 0.45), true)
		draw_rect(Rect2(at + Vector2(-8, -14), Vector2(width, 3)), Color("e0c48a"), true)


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
