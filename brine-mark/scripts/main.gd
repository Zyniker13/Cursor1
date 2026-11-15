extends Node2D

# Pointer paints the flats. The keyboard moves a cursor and picks a mark.
# Workers are drawn from the sim; nothing in this scene selects one.

const Sim = preload("res://scripts/sim.gd")

const CELL := 44.0
const MAP_ORIGIN := Vector2(20, 92)
const PANEL_POS := Vector2(788, 12)
const PANEL_SIZE := Vector2(476, 696)

const SAND := Color("f3e4c4")
const SHORE := Color("e7d3a4")
const INK := Color("243038")
const PAPER := Color("f4efe6")
const GOLD := Color("f0c14a")

var sim = null
var font: Font = null
var current_mode: int = Sim.RAKE
var painting := false
var cursor := Vector2i(8, 5)
var accum := 0.0

var rain_label: Label
var detail_label: Label
var covered_label: Label
var salt_label: Label
var ants_label: Label
var mode_label: Label
var season_label: Label
var cursor_label: Label
var status_label: Label
var summary_label: Label
var mode_buttons: Array = []


func _ready() -> void:
	font = ThemeDB.fallback_font
	sim = Sim.new()
	_build_hud()
	_refresh()


func _process(delta: float) -> void:
	if sim == null:
		return
	if not sim.is_over():
		accum += delta
		var step := 1.0 / float(Sim.TICK_HZ)
		var guard := 0
		while accum >= step and not sim.is_over() and guard < 30:
			accum -= step
			sim.tick()
			guard += 1
		if accum > step * 5.0:
			accum = 0.0
	else:
		accum = 0.0
	_refresh()
	queue_redraw()


func _unhandled_input(event: InputEvent) -> void:
	if sim == null:
		return
	if event is InputEventMouseButton:
		var button := event as InputEventMouseButton
		if button.button_index == MOUSE_BUTTON_LEFT:
			painting = button.pressed
			if button.pressed:
				_paint_at_mouse(current_mode)
		elif button.button_index == MOUSE_BUTTON_RIGHT and button.pressed:
			_paint_at_mouse(Sim.EMPTY)
		_refresh()
		queue_redraw()
		return
	if event is InputEventMouseMotion and painting:
		_paint_at_mouse(current_mode)
		_refresh()
		queue_redraw()
		return
	if event is InputEventKey:
		var key := event as InputEventKey
		if not key.pressed:
			return
		if key.echo and not _is_move_key(key.keycode):
			return
		_on_key(key.keycode)
		_refresh()
		queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1600, 1000)), Color("e7dcc4"))
	if sim == null:
		return
	_draw_bars()
	for y in Sim.GRID_H:
		for x in Sim.GRID_W:
			_draw_cell(x, y)
	_draw_coast_label()
	_draw_ants()
	_draw_hill_tag()
	_draw_cursor()
	var ticks_left := int(sim.get_ticks_until_rain()) if sim != null else 0
	var beat := int(sim.get_beat()) if sim != null else Sim.WET
	var opening := false
	if sim != null and beat == Sim.DRY and not sim.is_over():
		opening = ticks_left > Sim.DRY_TICK - Sim.TICK_HZ * 3
	# The cart beat is clear weather. Rain shows for the season changes and the end.
	if sim != null and beat != Sim.CART and beat != Sim.SHIPPING and beat != Sim.MARKET and beat != Sim.YARDING and (sim.is_over() or ticks_left < Sim.TICK_HZ * 3 or opening):
		_draw_rain(sim.is_over() or opening)


func _draw_bars() -> void:
	if sim == null:
		return
	var width := Sim.GRID_W * CELL - 2.0
	var beat := int(sim.get_beat())
	var span := Sim.RAIN_TICK
	var rain_color := Color("2f7590")
	if beat == Sim.YARDING:
		span = Sim.YARD_TICK
		rain_color = Color("2f6b45")
	elif beat == Sim.MARKET:
		span = Sim.MARKET_TICK
		rain_color = Color("9c3d3d")
	elif beat == Sim.SHIPPING:
		span = Sim.SHIP_TICK
		rain_color = Color("2f5f73")
	elif beat == Sim.CART:
		span = Sim.CART_TICK
		rain_color = Color("8a5a2b")
	elif beat == Sim.DRY:
		span = Sim.DRY_TICK
		rain_color = Color("c47a3a")
	var rain_frac := clampf(float(sim.get_ticks_until_rain()) / float(maxi(span, 1)), 0.0, 1.0)
	var quota_frac := clampf(float(sim.get_stored_salt()) / float(Sim.QUOTA), 0.0, 1.0)
	if beat == Sim.YARDING:
		var purse_whole := int(sim.get_banked()) + int(sim.get_purse())
		quota_frac = 0.0 if purse_whole <= 0 else clampf(float(sim.get_banked()) / float(purse_whole), 0.0, 1.0)
	elif beat == Sim.MARKET:
		var cargo := int(sim.get_coins()) + int(sim.get_ship_salt())
		quota_frac = 0.0 if cargo <= 0 else clampf(float(sim.get_coins()) / float(cargo), 0.0, 1.0)
	elif beat == Sim.SHIPPING:
		var ship_whole := int(sim.get_shipped()) + int(sim.get_crib_salt())
		quota_frac = 0.0 if ship_whole <= 0 else clampf(float(sim.get_shipped()) / float(ship_whole), 0.0, 1.0)
	elif beat == Sim.CART:
		var whole := int(sim.get_carted()) + int(sim.get_bank_left())
		quota_frac = 0.0 if whole <= 0 else clampf(float(sim.get_carted()) / float(whole), 0.0, 1.0)
	var bar_y := MAP_ORIGIN.y - 16.0
	draw_rect(Rect2(Vector2(MAP_ORIGIN.x, bar_y), Vector2(width, 6)), Color("c8b894"))
	draw_rect(Rect2(Vector2(MAP_ORIGIN.x, bar_y), Vector2(width * rain_frac, 6)), rain_color)
	draw_rect(Rect2(Vector2(MAP_ORIGIN.x, bar_y + 8), Vector2(width, 4)), Color("d9cbb0"))
	draw_rect(Rect2(Vector2(MAP_ORIGIN.x, bar_y + 8), Vector2(width * quota_frac, 4)), GOLD)


func _draw_cell(x: int, y: int) -> void:
	var dry: bool = sim.get_season() == Sim.DRY
	var rect := _cell_rect(x, y)
	if x == Sim.COAST_X:
		_draw_coast(rect, dry)
		return
	var base := SHORE if x == Sim.COAST_X + 1 else SAND
	draw_rect(rect, base)
	if x == Sim.COAST_X + 1 and not dry:
		draw_rect(Rect2(rect.position, Vector2(5, rect.size.y)), Color("7eb4c6"))
	var paint := int(sim.get_paint(x, y))
	match paint:
		Sim.RAKE:
			_draw_rake(rect, dry)
		Sim.STACK:
			_draw_stack_mark(rect)
		Sim.COVER:
			_draw_cover_mark(rect)
		Sim.TRAIL:
			_draw_trail(rect)
		Sim.PAN:
			_draw_pan(rect)
		Sim.CRIB:
			_draw_crib(rect, sim.get_beat() == Sim.CART or sim.get_beat() == Sim.SHIPPING or sim.get_beat() == Sim.MARKET or sim.get_beat() == Sim.YARDING)
		Sim.SHIP:
			_draw_ship(rect, sim.get_beat() == Sim.SHIPPING or sim.get_beat() == Sim.MARKET or sim.get_beat() == Sim.YARDING)
		Sim.STALL:
			_draw_stall(rect, sim.get_beat() == Sim.MARKET or sim.get_beat() == Sim.YARDING)
		Sim.YARD:
			_draw_yard(rect, sim.get_beat() == Sim.YARDING)
	if Vector2i(x, y) == Sim.ANTHILL:
		_draw_anthill(rect)
	var salt: Dictionary = sim.get_cell_salt(x, y)
	_draw_salt(rect, int(salt["loose"]), int(salt["stacked"]), int(salt["covered"]), int(salt["crib"]), int(salt["ship"]), int(salt["stall"]), int(salt["yard"]))


func _draw_coast(rect: Rect2, dry: bool) -> void:
	if dry:
		draw_rect(rect, Color("cbb892"))
		draw_rect(Rect2(rect.position, Vector2(rect.size.x, 8)), Color("e7d7b4"))
		var water_h := rect.size.y * 0.22
		draw_rect(Rect2(Vector2(rect.position.x, rect.end.y - water_h), Vector2(rect.size.x, water_h)), Color("2c6f88"))
		return
	draw_rect(rect, Color("2c6f88"))
	draw_rect(Rect2(rect.position, Vector2(6, rect.size.y)), Color("3e8eaa"))
	var y_line := rect.position.y + 8.0
	while y_line < rect.end.y - 3.0:
		draw_line(Vector2(rect.position.x + 8, y_line), Vector2(rect.end.x - 4, y_line), Color(1, 1, 1, 0.28), 1.0)
		y_line += 14.0


func _draw_rake(rect: Rect2, idle: bool) -> void:
	var wash := Color(0.55, 0.5, 0.42, 0.28) if idle else Color(0.86, 0.58, 0.28, 0.38)
	var line := Color("8d8274") if idle else Color("8a4e22")
	draw_rect(rect, wash)
	for i in 4:
		var y_line := rect.position.y + 8.0 + float(i) * 8.0
		draw_line(Vector2(rect.position.x + 5, y_line), Vector2(rect.end.x - 5, y_line), line, 1.5)


func _draw_crib(rect: Rect2, open: bool) -> void:
	var wall := Color("a56b3c") if open else Color("b7a48a")
	var slat := Color("6b3e24") if open else Color("8d7764")
	draw_rect(rect, Color(0.72, 0.55, 0.32, 0.28 if open else 0.16))
	var bin := Rect2(rect.position + Vector2(8, 14), rect.size - Vector2(16, 20))
	draw_rect(bin, wall)
	for i in 3:
		var y_line := bin.position.y + 4.0 + float(i) * (bin.size.y / 3.0)
		draw_line(Vector2(bin.position.x + 2, y_line), Vector2(bin.end.x - 2, y_line), slat, 2.0)
	draw_rect(Rect2(bin.position, Vector2(3, bin.size.y)), slat)
	draw_rect(Rect2(Vector2(bin.end.x - 3, bin.position.y), Vector2(3, bin.size.y)), slat)


func _draw_ship(rect: Rect2, open: bool) -> void:
	var hull := Color("2f5f73") if open else Color("8aa0a8")
	var sail := Color("f7f4ee") if open else Color("d5d0c6")
	var wash := Color(0.18, 0.42, 0.52, 0.28) if open else Color(0.18, 0.42, 0.52, 0.12)
	draw_rect(rect, wash)
	var deck := PackedVector2Array([
		rect.position + Vector2(6, rect.size.y - 14),
		rect.position + Vector2(rect.size.x - 6, rect.size.y - 14),
		rect.position + Vector2(rect.size.x - 14, rect.size.y - 24),
		rect.position + Vector2(14, rect.size.y - 24),
	])
	draw_colored_polygon(deck, hull)
	var mast_x := rect.position.x + rect.size.x * 0.5
	draw_line(Vector2(mast_x, rect.position.y + 8), Vector2(mast_x, rect.position.y + rect.size.y - 22), hull, 2.0)
	var cloth := PackedVector2Array([
		Vector2(mast_x, rect.position.y + 10),
		Vector2(mast_x + 14, rect.position.y + 20),
		Vector2(mast_x, rect.position.y + 26),
	])
	draw_colored_polygon(cloth, sail)


func _draw_stall(rect: Rect2, open: bool) -> void:
	var cloth := Color("9c3d3d") if open else Color("b7a4a4")
	var pole := Color("6b3e24") if open else Color("8d7764")
	var wash := Color(0.62, 0.24, 0.24, 0.28) if open else Color(0.62, 0.24, 0.24, 0.12)
	draw_rect(rect, wash)
	var awning := PackedVector2Array([
		rect.position + Vector2(4, 16),
		rect.position + Vector2(rect.size.x - 4, 16),
		rect.position + Vector2(rect.size.x - 8, 8),
		rect.position + Vector2(8, 8),
	])
	draw_colored_polygon(awning, cloth)
	var stripe := rect.position.x + rect.size.x * 0.5
	draw_line(Vector2(stripe, rect.position.y + 8), Vector2(stripe, rect.position.y + 16), Color("f4efe6"), 2.0)
	draw_line(rect.position + Vector2(10, 18), rect.position + Vector2(10, rect.size.y - 8), pole, 2.0)
	draw_line(rect.position + Vector2(rect.size.x - 10, 18), rect.position + Vector2(rect.size.x - 10, rect.size.y - 8), pole, 2.0)
	var counter := Rect2(rect.position + Vector2(8, rect.size.y - 16), Vector2(rect.size.x - 16, 6))
	draw_rect(counter, Color("e0c08a") if open else Color("c8c2b6"))


func _draw_yard(rect: Rect2, open: bool) -> void:
	var wall := Color("2f6b45") if open else Color("9aab9f")
	var coin := Color("f0c14a") if open else Color("c8c2b6")
	var wash := Color(0.18, 0.4, 0.28, 0.28) if open else Color(0.18, 0.4, 0.28, 0.12)
	draw_rect(rect, wash)
	var box := Rect2(rect.position + Vector2(8, 12), rect.size - Vector2(16, 18))
	draw_rect(box, wall)
	draw_rect(Rect2(box.position + Vector2(4, 4), box.size - Vector2(8, 8)), coin)
	var mid_x := box.position.x + box.size.x * 0.5
	var mid_y := box.position.y + box.size.y * 0.5
	draw_line(Vector2(mid_x, box.position.y + 2), Vector2(mid_x, box.end.y - 2), wall, 2.0)
	draw_line(Vector2(box.position.x + 2, mid_y), Vector2(box.end.x - 2, mid_y), wall, 2.0)


func _draw_pan(rect: Rect2) -> void:
	draw_rect(rect, Color(0.62, 0.74, 0.76, 0.42))
	var basin := Rect2(rect.position + Vector2(7, 12), rect.size - Vector2(14, 18))
	draw_rect(basin, Color("d5ecee"))
	draw_rect(basin, Color("3f7f88"), false, 2.0)
	draw_line(basin.position + Vector2(4, basin.size.y * 0.55), basin.end + Vector2(-4, -basin.size.y * 0.2), Color("f7f8f4"), 1.5)


func _draw_stack_mark(rect: Rect2) -> void:
	draw_rect(Rect2(rect.position + Vector2(4, 4), rect.size - Vector2(8, 8)), Color("f7f4ee"))
	for i in 3:
		var x_pos := rect.position.x + 10.0 + float(i) * 8.0
		draw_rect(Rect2(Vector2(x_pos, rect.position.y + 16), Vector2(4, 16)), Color("d5cec0"))


func _draw_cover_mark(rect: Rect2) -> void:
	draw_rect(Rect2(rect.position + Vector2(4, 18), Vector2(rect.size.x - 8, rect.size.y - 24)), Color("3f6b4e"))
	var roof := PackedVector2Array([
		rect.position + Vector2(3, 20),
		rect.position + Vector2(rect.size.x * 0.5, 4),
		rect.position + Vector2(rect.size.x - 3, 20),
	])
	draw_colored_polygon(roof, Color("2c4d3a"))


func _draw_trail(rect: Rect2) -> void:
	draw_rect(rect, Color("a56b3c"))
	var mid := rect.position.x + rect.size.x * 0.5
	draw_line(Vector2(mid, rect.position.y + 2), Vector2(mid, rect.end.y - 2), Color("e6c48a"), 3.0)


func _draw_anthill(rect: Rect2) -> void:
	var center := rect.position + rect.size * 0.5
	draw_circle(center + Vector2(0, 6), 13, Color("6a4030"))
	draw_circle(center + Vector2(-6, 3), 9, Color("7d4b36"))
	draw_circle(center + Vector2(7, 4), 7.5, Color("5b3424"))
	draw_circle(center + Vector2(1, 5), 3.0, Color("1a100c"))


func _draw_salt(rect: Rect2, loose: int, stacked: int, covered: int, crib: int, ship: int, stall: int, yard: int) -> void:
	for i in mini(loose, 4):
		var col := i % 2
		var row := int(i / 2)
		_diamond(rect.position + Vector2(14 + col * 12, 24 + row * 10), 3.0, Color("f7f8f4"))
	for i in mini(stacked, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.5, Color("f4f7fb"))
	for i in mini(covered, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("f4f7fb"))
	for i in mini(crib, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("fff8e8"))
	for i in mini(ship, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("ffe6a8"))
	for i in mini(stall, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("f0c14a"))
	for i in mini(yard, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("fff1b8"))
	var total := loose + stacked + covered + crib + ship + stall + yard
	if total > 0:
		var digits := str(total)
		var badge := Rect2(rect.position + Vector2(2, 2), Vector2(6.0 + 7.0 * digits.length(), 13))
		draw_rect(badge, Color(1, 1, 1, 0.88))
		_draw_text(rect.position + Vector2(4, 12), digits, 12, Color("2a241c"))


func _draw_ants() -> void:
	for ant in sim.get_ant_draw_positions():
		var rect := _cell_rect(int(ant["x"]), int(ant["y"]))
		var slot := int(ant["id"]) % 9
		var offset := Vector2((slot % 3) - 1, int(slot / 3) - 1) * 11.0
		var at := rect.position + rect.size * 0.5 + offset
		_draw_ant(at, int(ant["job"]))


func _draw_ant(at: Vector2, job: int) -> void:
	var color := Color("1a120e")
	if job == Sim.JOB_GATHER:
		color = Color("5c2e1e")
	elif job == Sim.JOB_COVER:
		color = Color("1a3d2a")
	var halo := Color("f7f1e4")
	draw_line(at + Vector2(-8, 2), at + Vector2(-2, 0), color, 1.6)
	draw_line(at + Vector2(8, 2), at + Vector2(2, 0), color, 1.6)
	draw_line(at + Vector2(-7, -3), at + Vector2(-2, -1), color, 1.6)
	draw_line(at + Vector2(7, -3), at + Vector2(2, -1), color, 1.6)
	draw_circle(at, 5.4, halo)
	draw_circle(at + Vector2(4.4, -1.8), 3.1, halo)
	draw_circle(at, 3.6, color)
	draw_circle(at + Vector2(4.4, -1.8), 2.0, color)


func _draw_hill_tag() -> void:
	var rect := _cell_rect(Sim.ANTHILL.x, Sim.ANTHILL.y)
	draw_rect(Rect2(rect.position + Vector2(3, 2), Vector2(30, 12)), Color("f3e4c4"))
	_draw_text(rect.position + Vector2(6, 12), "hill", 11, Color("3a2618"))


func _draw_cursor() -> void:
	var rect := _cell_rect(cursor.x, cursor.y)
	draw_rect(rect, Color(1, 1, 1, 0.16))
	draw_rect(rect, _mode_color(current_mode), false, 3.0)


func _draw_rain(heavy: bool) -> void:
	var streaks := 80 if heavy else 28
	var tint := Color(0.75, 0.88, 0.96, 0.62 if heavy else 0.35)
	var span_x := int(Sim.GRID_W * CELL)
	var span_y := int(Sim.GRID_H * CELL)
	for i in streaks:
		var x := float((i * 53) % span_x)
		var y := float((i * 29) % span_y)
		draw_line(MAP_ORIGIN + Vector2(x, y), MAP_ORIGIN + Vector2(x + 6, y + 20), tint, 1.6)
	if heavy:
		draw_rect(Rect2(MAP_ORIGIN, Vector2(span_x, span_y)), Color(0.35, 0.55, 0.7, 0.2))


func _draw_coast_label() -> void:
	var dry: bool = sim != null and sim.get_season() == Sim.DRY
	var letters := "BRINE"
	var color := Color("2a2116") if dry else Color("e7f4f8")
	for i in letters.length():
		_draw_text(MAP_ORIGIN + Vector2(12, 20 + i * 16), letters.substr(i, 1), 14, color)


func _draw_text(at: Vector2, text: String, size: int, color: Color) -> void:
	if font == null:
		return
	draw_string(font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)


func _diamond(center: Vector2, radius: float, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array([
		center + Vector2(0, -radius),
		center + Vector2(radius, 0),
		center + Vector2(0, radius),
		center + Vector2(-radius, 0),
	]), color)


func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "Hud"
	hud.layer = 10
	add_child(hud)

	detail_label = _make_label("", 15, INK)
	detail_label.position = Vector2(20, 10)
	detail_label.size = Vector2(740, 22)
	hud.add_child(detail_label)

	rain_label = _make_label("", 28, Color("1d4e63"))
	rain_label.name = "RainCountdown"
	rain_label.position = Vector2(20, 34)
	rain_label.size = Vector2(740, 40)
	hud.add_child(rain_label)

	var hint_a := _make_label("Drag to paint. Right-click erases. Arrows or WASD move the cursor.", 14, INK)
	hint_a.position = Vector2(20, 628)
	hint_a.size = Vector2(740, 20)
	hud.add_child(hint_a)
	var hint_b := _make_label("1 rake, 2 stack, 3 cover, 4 trail, 5 pan, 6 crib, 7 ship, 8 stall, 9 yard, 0 erase. Space paints. R restarts.", 14, INK)
	hint_b.position = Vector2(20, 650)
	hint_b.size = Vector2(740, 20)
	hud.add_child(hint_b)

	var panel := PanelContainer.new()
	panel.name = "Panel"
	panel.position = PANEL_POS
	panel.size = PANEL_SIZE
	panel.custom_minimum_size = PANEL_SIZE
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = INK
	panel_style.set_corner_radius_all(8)
	panel_style.content_margin_left = 14
	panel_style.content_margin_right = 14
	panel_style.content_margin_top = 12
	panel_style.content_margin_bottom = 12
	panel.add_theme_stylebox_override("panel", panel_style)
	hud.add_child(panel)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_child(box)

	box.add_child(_make_label("BRINE MARK", 26, PAPER))
	box.add_child(_make_label("Salt Coast", 16, GOLD))
	var rules := _make_label("Paint the flats. Workers follow the mark under their feet and are not selectable.\nWet season: rake the shore, stack the loose salt, cover the stacks. The first rain banks covered salt and pulls the brine back. Dry season: shore rakes go idle. Paint pans and workers crystallize salt until the second rain. Then paint a crib. Workers move the banked salt into it. Then paint a ship. Workers load that crib onto it. Then paint a stall. Workers sell that cargo, one coin a unit. Then paint a yard. Workers bank those coins, one at a time. Trail is how they cross.", 14, PAPER)
	rules.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rules.custom_minimum_size = Vector2(430, 208)
	rules.name = "RulesNote"
	box.add_child(rules)

	covered_label = _make_label("", 18, PAPER)
	salt_label = _make_label("", 15, PAPER)
	ants_label = _make_label("", 15, PAPER)
	mode_label = _make_label("", 15, GOLD)
	season_label = _make_label("", 14, Color("d5ecee"))
	season_label.name = "SeasonNote"
	season_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	season_label.custom_minimum_size = Vector2(430, 40)
	box.add_child(covered_label)
	box.add_child(salt_label)
	box.add_child(ants_label)
	box.add_child(mode_label)
	box.add_child(season_label)

	box.add_child(_button_row([
		["1  Rake", Sim.RAKE, Color("e39a45")],
		["2  Stack", Sim.STACK, Color("f3efe4")],
		["3  Cover", Sim.COVER, Color("4e8a62")],
	]))
	box.add_child(_button_row([
		["4  Trail", Sim.TRAIL, Color("c4844a")],
		["5  Pan", Sim.PAN, Color("b7d4d2")],
		["6  Crib", Sim.CRIB, Color("e0c08a")],
		["7  Ship", Sim.SHIP, Color("b7c9d4")],
	]))
	box.add_child(_button_row([
		["8  Stall", Sim.STALL, Color("c4553a")],
		["9  Yard", Sim.YARD, Color("7dcea0")],
		["0  Erase", Sim.EMPTY, Color("c8c2b6")],
	]))

	cursor_label = _make_label("", 14, PAPER)
	status_label = _make_label("", 14, Color("f0c14a"))
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.custom_minimum_size = Vector2(430, 36)
	summary_label = _make_label("", 18, PAPER)
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_label.custom_minimum_size = Vector2(430, 88)
	box.add_child(cursor_label)
	box.add_child(status_label)
	box.add_child(summary_label)

	var restart := Button.new()
	restart.name = "RestartScenario"
	restart.text = "Restart scenario"
	restart.focus_mode = Control.FOCUS_NONE
	restart.custom_minimum_size = Vector2(0, 42)
	var restart_style := StyleBoxFlat.new()
	restart_style.bg_color = Color("c4553a")
	restart_style.set_corner_radius_all(4)
	restart.add_theme_stylebox_override("normal", restart_style)
	restart.add_theme_stylebox_override("hover", restart_style)
	restart.add_theme_stylebox_override("pressed", restart_style)
	for color_name in ["font_color", "font_hover_color", "font_pressed_color"]:
		restart.add_theme_color_override(color_name, PAPER)
	restart.add_theme_font_size_override("font_size", 16)
	restart.pressed.connect(_restart)
	box.add_child(restart)
	_style_mode_buttons()


func _button_row(specs: Array) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 6)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for spec in specs:
		var button := Button.new()
		button.text = spec[0]
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(0, 36)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var mode := int(spec[1])
		button.pressed.connect(_set_mode.bind(mode))
		row.add_child(button)
		mode_buttons.append({"button": button, "mode": mode, "color": spec[2]})
	return row


func _make_label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _style_mode_buttons() -> void:
	for entry in mode_buttons:
		var button: Button = entry["button"]
		var active: bool = int(entry["mode"]) == current_mode
		var style := StyleBoxFlat.new()
		style.bg_color = entry["color"]
		style.set_corner_radius_all(4)
		if active:
			style.set_border_width_all(3)
			style.border_color = GOLD
		button.add_theme_stylebox_override("normal", style)
		button.add_theme_stylebox_override("hover", style)
		button.add_theme_stylebox_override("pressed", style)
		var ink := Color("1d1a16")
		for color_name in ["font_color", "font_hover_color", "font_pressed_color"]:
			button.add_theme_color_override(color_name, ink)
		button.add_theme_font_size_override("font_size", 14)


func _refresh() -> void:
	if sim == null:
		return
	var seconds := 0.0
	if sim.is_over():
		if int(sim.get_banked()) > 0:
			rain_label.text = "The coins are in the yard"
			rain_label.add_theme_color_override("font_color", Color("2f6b45"))
		elif int(sim.get_coins()) > 0:
			rain_label.text = "The cargo has sold"
			rain_label.add_theme_color_override("font_color", Color("9c3d3d"))
		elif int(sim.get_shipped()) > 0:
			rain_label.text = "The crib has shipped"
			rain_label.add_theme_color_override("font_color", Color("1d4e63"))
		elif int(sim.get_carted()) > 0:
			rain_label.text = "The bank is in the crib"
			rain_label.add_theme_color_override("font_color", Color("6b3e24"))
		else:
			rain_label.text = "Rain has fallen"
			rain_label.add_theme_color_override("font_color", Color("8fb4c4"))
	else:
		seconds = float(sim.get_ticks_until_rain()) / float(Sim.TICK_HZ) - accum
		if seconds < 0.0:
			seconds = 0.0
		var urgent := seconds < 10.0
		if sim.get_beat() == Sim.YARDING:
			rain_label.text = "Yard the coins. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("2f6b45"))
		elif sim.get_beat() == Sim.MARKET:
			rain_label.text = "Sell the cargo. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("9c3d3d"))
		elif sim.get_beat() == Sim.SHIPPING:
			rain_label.text = "Ship the crib. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("1d4e63"))
		elif sim.get_beat() == Sim.CART:
			rain_label.text = "Cart the bank. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("6b3e24"))
		elif sim.get_season() == Sim.DRY:
			rain_label.text = "Dry season. Rain in %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("8a4b12"))
		else:
			rain_label.text = "Wet season. Rain in %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("1d4e63"))
	var season_name := "wet"
	if sim.is_over():
		season_name = "settled"
	elif sim.get_beat() == Sim.YARDING:
		season_name = "yard"
	elif sim.get_beat() == Sim.MARKET:
		season_name = "market"
	elif sim.get_beat() == Sim.SHIPPING:
		season_name = "ship"
	elif sim.get_beat() == Sim.CART:
		season_name = "cart"
	elif sim.get_season() == Sim.DRY:
		season_name = "dry"
	detail_label.text = "Salt Coast    %s    covered %d/%d    ants %d/%d" % [
		season_name, sim.get_stored_salt(), Sim.QUOTA, sim.get_population(), Sim.POP_CAP,
	]
	covered_label.text = "Covered salt  %d / %d" % [sim.get_stored_salt(), Sim.QUOTA]
	if sim.get_beat() == Sim.YARDING or (sim.is_over() and int(sim.get_banked()) > 0):
		salt_label.text = "Loose %d    stacked %d    coins %d    banked %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_coins(), sim.get_banked(),
		]
	elif sim.get_beat() == Sim.MARKET or (sim.is_over() and int(sim.get_coins()) > 0):
		salt_label.text = "Loose %d    stacked %d    ship %d    coins %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_ship_salt(), sim.get_coins(),
		]
	elif sim.get_beat() == Sim.SHIPPING or (sim.is_over() and int(sim.get_shipped()) > 0):
		salt_label.text = "Loose %d    stacked %d    crib %d    shipped %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_crib_salt(), sim.get_shipped(),
		]
	elif sim.get_beat() == Sim.CART or sim.is_over():
		salt_label.text = "Loose %d    stacked %d    bank %d    carted %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_bank_left(), sim.get_carted(),
		]
	else:
		salt_label.text = "Loose %d    stacked %d    hauled %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_wet_haul(),
		]
	ants_label.text = "Ants %d / %d" % [sim.get_population(), Sim.POP_CAP]
	mode_label.text = "Mark: %s" % _mode_name(current_mode)
	if sim.get_beat() == Sim.YARDING and not sim.is_over():
		season_label.text = "Coins %d. Banked %d. Paint a yard and workers bank the purse." % [
			sim.get_coins(), sim.get_banked(),
		]
	elif sim.is_over() and int(sim.get_banked()) > 0:
		season_label.text = "Banked %d into the yard." % sim.get_banked()
	elif sim.get_beat() == Sim.MARKET and not sim.is_over():
		season_label.text = "Ship %d. Coins %d. Paint a stall and workers sell the cargo." % [
			sim.get_ship_salt(), sim.get_coins(),
		]
	elif sim.is_over() and int(sim.get_coins()) > 0:
		season_label.text = "The purse was not banked. A yard is where workers take it."
	elif sim.get_beat() == Sim.SHIPPING and not sim.is_over():
		season_label.text = "Crib %d. Shipped %d. Paint a ship and workers load the crib." % [
			sim.get_crib_salt(), sim.get_shipped(),
		]
	elif sim.is_over() and int(sim.get_shipped()) > 0:
		season_label.text = "The ship was not sold. A stall is where workers sell it."
	elif sim.get_beat() == Sim.CART and not sim.is_over():
		season_label.text = "Bank %d. Carted %d. Paint a crib and workers move the bank." % [
			sim.get_bank_left(), sim.get_carted(),
		]
	elif sim.is_over() and int(sim.get_carted()) > 0:
		season_label.text = "The crib was not shipped. A ship is where workers send it."
	elif sim.is_over() and int(sim.get_stored_salt()) >= Sim.QUOTA and int(sim.get_carted()) == 0:
		season_label.text = "The bank was not carted. A crib is where workers move it."
	elif sim.get_season() == Sim.DRY or sim.is_over():
		var dry_held := int(sim.get_stored_salt()) - int(sim.get_wet_haul())
		season_label.text = "Hauled %d. Dry covers %d. Shore rakes are idle; pans crystallize." % [
			sim.get_wet_haul(), dry_held,
		]
	else:
		season_label.text = "Wet season. Pans wait until the brine pulls back."
	cursor_label.text = "Cursor %d, %d" % [cursor.x, cursor.y]
	if sim.is_over():
		summary_label.text = sim.get_summary()
		var won: bool = sim.get_stored_salt() >= Sim.QUOTA
		summary_label.add_theme_color_override("font_color", Color("b7e2c2") if won else Color("ffb4a8"))
		status_label.text = "Restart scenario to mark the flats again."
	elif sim.get_beat() == Sim.YARDING:
		summary_label.text = "The market beat has ended. Paint a yard. Workers bank the coins already earned."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.MARKET:
		summary_label.text = "The ship beat has ended. Paint a stall. Workers sell the salt on the ship."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.SHIPPING:
		summary_label.text = "The cart beat has ended. Paint a ship. Workers load the crib onto it."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.CART:
		summary_label.text = "The second rain has fallen. Paint a crib. Workers move the banked salt into it."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_season() == Sim.DRY:
		summary_label.text = "The brine has pulled back and the first haul is banked. Paint pans before the second rain."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	else:
		summary_label.text = "Result appears when the rains have passed."
		summary_label.add_theme_color_override("font_color", Color("c5d0d6"))


func _paint_at_mouse(mode: int) -> void:
	var local := get_global_mouse_position() - MAP_ORIGIN
	var cell := Vector2i(floori(local.x / CELL), floori(local.y / CELL))
	if cell.x < 0 or cell.y < 0 or cell.x >= Sim.GRID_W or cell.y >= Sim.GRID_H:
		return
	cursor = cell
	_paint_cell(cell.x, cell.y, mode)


func _paint_cell(x: int, y: int, mode: int) -> void:
	if sim.is_over():
		status_label.text = "The rain has fallen. Restart scenario to paint again."
		return
	if sim.paint_cell(x, y, mode):
		status_label.text = ""
	else:
		status_label.text = "The brine and the anthill stay fixed."


func _restart() -> void:
	sim.restart()
	accum = 0.0
	status_label.text = "Scenario restarted."
	_refresh()
	queue_redraw()


func _set_mode(mode: int) -> void:
	current_mode = mode
	_style_mode_buttons()
	_refresh()


func _on_key(keycode: Key) -> void:
	match keycode:
		KEY_UP, KEY_W:
			_move_cursor(0, -1)
		KEY_DOWN, KEY_S:
			_move_cursor(0, 1)
		KEY_LEFT, KEY_A:
			_move_cursor(-1, 0)
		KEY_RIGHT, KEY_D:
			_move_cursor(1, 0)
		KEY_1, KEY_KP_1:
			_set_mode(Sim.RAKE)
		KEY_2, KEY_KP_2:
			_set_mode(Sim.STACK)
		KEY_3, KEY_KP_3:
			_set_mode(Sim.COVER)
		KEY_4, KEY_KP_4:
			_set_mode(Sim.TRAIL)
		KEY_5, KEY_KP_5:
			_set_mode(Sim.PAN)
		KEY_6, KEY_KP_6:
			_set_mode(Sim.CRIB)
		KEY_7, KEY_KP_7:
			_set_mode(Sim.SHIP)
		KEY_8, KEY_KP_8:
			_set_mode(Sim.STALL)
		KEY_9, KEY_KP_9:
			_set_mode(Sim.YARD)
		KEY_0, KEY_KP_0:
			_set_mode(Sim.EMPTY)
		KEY_SPACE, KEY_ENTER, KEY_KP_ENTER:
			_paint_cell(cursor.x, cursor.y, current_mode)
		KEY_R:
			_restart()


func _move_cursor(dx: int, dy: int) -> void:
	cursor.x = clampi(cursor.x + dx, 0, Sim.GRID_W - 1)
	cursor.y = clampi(cursor.y + dy, 0, Sim.GRID_H - 1)


func _is_move_key(keycode: Key) -> bool:
	return keycode == KEY_UP or keycode == KEY_DOWN or keycode == KEY_LEFT or keycode == KEY_RIGHT or keycode == KEY_W or keycode == KEY_A or keycode == KEY_S or keycode == KEY_D


func _cell_rect(x: int, y: int) -> Rect2:
	return Rect2(MAP_ORIGIN + Vector2(x * CELL, y * CELL), Vector2(CELL - 2.0, CELL - 2.0))


func _mode_color(mode: int) -> Color:
	match mode:
		Sim.RAKE:
			return Color("e39a45")
		Sim.STACK:
			return Color("f7f4ee")
		Sim.COVER:
			return Color("2f6b45")
		Sim.TRAIL:
			return Color("8a4e22")
		Sim.PAN:
			return Color("3f7f88")
		Sim.CRIB:
			return Color("a56b3c")
		Sim.SHIP:
			return Color("2f5f73")
		Sim.STALL:
			return Color("9c3d3d")
		Sim.YARD:
			return Color("2f6b45")
		_:
			return Color("f4efe6")


func _mode_name(mode: int) -> String:
	match mode:
		Sim.RAKE:
			return "Rake"
		Sim.STACK:
			return "Stack"
		Sim.COVER:
			return "Cover"
		Sim.TRAIL:
			return "Trail"
		Sim.PAN:
			return "Pan"
		Sim.CRIB:
			return "Crib"
		Sim.SHIP:
			return "Ship"
		Sim.STALL:
			return "Stall"
		Sim.YARD:
			return "Yard"
		_:
			return "Erase"
