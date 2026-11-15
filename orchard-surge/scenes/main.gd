extends Node2D

## View and input for Orchard Surge. Combat, light, planting, and damage live in OrchardSim.

const Sim = preload("res://sim/orchard_sim.gd")
const Catalog = preload("res://sim/plant_catalog.gd")
const Tooltip = preload("res://ui/plant_tooltip.gd")

const ORIGIN := Vector2(16, 76)
const PANEL_X := 752.0
const PANEL_W := 352.0

const KIND_COLOR := [
	Color(0.561, 0.859, 0.333, 1),
	Color(0.243, 0.561, 0.333, 1),
	Color(1.0, 0.784, 0.341, 1),
	Color(0.878, 0.478, 0.184, 1),
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

	seeds_label = _label("Seeds 6", 15, Color("e7d7a4"))
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

	hint_label = _label("Move: WASD / arrows (paused while planting). Plant: 1-4 then click a tile. Unlit tiles hide pests.", 13, Color("aeb8a4"))
	hint_label.position = Vector2(16, 640)
	hint_label.size = Vector2(720, 44)
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layer.add_child(hint_label)

	reject_label = _label("", 14, Color("e0b4a0"))
	reject_label.position = Vector2(16, 588)
	reject_label.size = Vector2(720, 24)
	layer.add_child(reject_label)

	for kind in Catalog.COUNT:
		var panel := PanelContainer.new()
		panel.position = Vector2(PANEL_X, 76 + float(kind) * 176.0)
		panel.size = Vector2(PANEL_W, 168)
		panel.custom_minimum_size = Vector2(PANEL_W, 168)
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
		var hotkey := _label("%d" % (kind + 1), 12, KIND_COLOR[kind])
		hotkey.name = "Hotkey"
		hotkey.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.add_child(hotkey)
		var index := 0
		for line in Tooltip.stat_lines(kind):
			var row := _label(line, 12 if index > 0 else 16, Color("f4f0e4") if index == 0 else Color("d5d0c4"))
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
		outcome_label.text = "The surge breaks.\nThree waves passed, and the orchard still stands."
	else:
		outcome_label.text = "The lights went out.\nHealth reached zero before the orchard was clear."


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
	for ty in Sim.MAP_H:
		for tx in Sim.MAP_W:
			var rect := _tile_rect(tx, ty)
			if sim.tile_lit(tx, ty):
				draw_rect(rect, Color(0.95, 0.82, 0.45, 0.07), true)
			else:
				draw_rect(rect, Color(0.015, 0.02, 0.035, 0.58), true)


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
		_:
			draw_circle(at, 6.0, Color("ffb15a"))
			draw_circle(at, 2.5, Color("fff0d2"))


func _draw_pest(pest) -> void:
	var at := _screen(pest.pos)
	var flutter := sin(float(sim.tick) * 0.45 + float(pest.id)) * 3.0
	var wing := Color("3c3554")
	var body := Color("2a2438")
	if pest.slow_ticks > 0:
		wing = Color("2f6b58")
		body = Color("21483c")
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
	draw_circle(at + Vector2(-2, -1), 1.3, Color("f2e7c8"))
	draw_circle(at + Vector2(2, -1), 1.3, Color("f2e7c8"))
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
