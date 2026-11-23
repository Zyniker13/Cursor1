extends Node2D

# Pointer paints the flats. The keyboard moves a cursor and picks a mark.
# Workers are drawn from the sim; nothing in this scene selects one.

const Sim = preload("res://scripts/sim.gd")

const CELL := 42.0
const MAP_ORIGIN := Vector2(20, 58)
const PANEL_POS := Vector2(788, 12)
const PANEL_SIZE := Vector2(795, 1313)

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
	draw_rect(Rect2(Vector2.ZERO, Vector2(1600, 1520)), Color("e7dcc4"))
	if sim == null:
		return
	_draw_bars()
	for y in range(Sim.GRID_NORTH, Sim.GRID_H):
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
	if sim != null and beat != Sim.CART and beat != Sim.SHIPPING and beat != Sim.MARKET and beat != Sim.YARDING and beat != Sim.BUNKING and beat != Sim.LOFTING and beat != Sim.GATING and beat != Sim.WAGING and beat != Sim.RELIEVING and beat != Sim.WATCHING and beat != Sim.LAMPING and beat != Sim.BELLING and beat != Sim.HORNING and beat != Sim.FLAGGING and beat != Sim.BANNERING and beat != Sim.PENNANTING and beat != Sim.STANDARDING and beat != Sim.JACKING and beat != Sim.ENSIGNING and beat != Sim.BURGEEING and beat != Sim.CORNETING and beat != Sim.GUIDONING and beat != Sim.FANIONING and (sim.is_over() or ticks_left < Sim.TICK_HZ * 3 or opening):
		_draw_rain(sim.is_over() or opening)


func _draw_bars() -> void:
	if sim == null:
		return
	var width := Sim.GRID_W * CELL - 2.0
	var beat := int(sim.get_beat())
	var span := Sim.RAIN_TICK
	var rain_color := Color("2f7590")
	if beat == Sim.FANIONING:
		span = Sim.FANION_TICK
		rain_color = Color("a89068")
	elif beat == Sim.GUIDONING:
		span = Sim.GUIDON_TICK
		rain_color = Color("b9a36e")
	elif beat == Sim.CORNETING:
		span = Sim.CORNET_TICK
		rain_color = Color("cbb892")
	elif beat == Sim.BURGEEING:
		span = Sim.BURGEE_TICK
		rain_color = Color("8d6a3a")
	elif beat == Sim.ENSIGNING:
		span = Sim.ENSIGN_TICK
		rain_color = Color("c4b89a")
	elif beat == Sim.JACKING:
		span = Sim.JACK_TICK
		rain_color = Color("2c2824")
	elif beat == Sim.STANDARDING:
		span = Sim.STANDARD_TICK
		rain_color = Color("5c564c")
	elif beat == Sim.PENNANTING:
		span = Sim.PENNANT_TICK
		rain_color = Color("8a3b22")
	elif beat == Sim.BANNERING:
		span = Sim.BANNER_TICK
		rain_color = Color("1e3f73")
	elif beat == Sim.FLAGGING:
		span = Sim.FLAG_TICK
		rain_color = Color("8e2a32")
	elif beat == Sim.HORNING:
		span = Sim.HORN_TICK
		rain_color = Color("8c3b2a")
	elif beat == Sim.BELLING:
		span = Sim.BELL_TICK
		rain_color = Color("b8860b")
	elif beat == Sim.LAMPING:
		span = Sim.LAMP_TICK
		rain_color = Color("c47a2a")
	elif beat == Sim.WATCHING:
		span = Sim.WATCH_TICK
		rain_color = Color("2c3a6e")
	elif beat == Sim.RELIEVING:
		span = Sim.RELIEF_TICK
		rain_color = Color("2f6f78")
	elif beat == Sim.WAGING:
		span = Sim.WAGE_TICK
		rain_color = Color("8a6a2f")
	elif beat == Sim.GATING:
		span = Sim.GATE_TICK
		rain_color = Color("3e4c59")
	elif beat == Sim.LOFTING:
		span = Sim.LOFT_TICK
		rain_color = Color("4a3b2a")
	elif beat == Sim.BUNKING:
		span = Sim.BUNK_TICK
		rain_color = Color("5c3b2e")
	elif beat == Sim.YARDING:
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
	if beat == Sim.FANIONING:
		var room := mini(int(sim.get_saluted()), int(Sim.FANION_CAP))
		quota_frac = 0.0 if room <= 0 else clampf(float(sim.get_presented()) / float(room), 0.0, 1.0)
	elif beat == Sim.GUIDONING:
		var room := mini(int(sim.get_dipped()), int(Sim.GUIDON_CAP))
		quota_frac = 0.0 if room <= 0 else clampf(float(sim.get_saluted()) / float(room), 0.0, 1.0)
	elif beat == Sim.CORNETING:
		var room := mini(int(sim.get_struck()), int(Sim.CORNET_CAP))
		quota_frac = 0.0 if room <= 0 else clampf(float(sim.get_dipped()) / float(room), 0.0, 1.0)
	elif beat == Sim.BURGEEING:
		var room := mini(int(sim.get_broken()), int(Sim.BURGEE_CAP))
		quota_frac = 0.0 if room <= 0 else clampf(float(sim.get_struck()) / float(room), 0.0, 1.0)
	elif beat == Sim.ENSIGNING:
		var room := mini(int(sim.get_shown()), int(Sim.ENSIGN_CAP))
		quota_frac = 0.0 if room <= 0 else clampf(float(sim.get_broken()) / float(room), 0.0, 1.0)
	elif beat == Sim.JACKING:
		var room := mini(int(sim.get_carried()), int(Sim.JACK_CAP))
		quota_frac = 0.0 if room <= 0 else clampf(float(sim.get_shown()) / float(room), 0.0, 1.0)
	elif beat == Sim.STANDARDING:
		var room := mini(int(sim.get_flown()), int(Sim.STANDARD_CAP))
		quota_frac = 0.0 if room <= 0 else clampf(float(sim.get_carried()) / float(room), 0.0, 1.0)
	elif beat == Sim.PENNANTING:
		var room := mini(int(sim.get_hoisted()), int(Sim.PENNANT_CAP))
		quota_frac = 0.0 if room <= 0 else clampf(float(sim.get_flown()) / float(room), 0.0, 1.0)
	elif beat == Sim.BANNERING:
		var room := mini(int(sim.get_raised()), int(Sim.BANNER_CAP))
		quota_frac = 0.0 if room <= 0 else clampf(float(sim.get_hoisted()) / float(room), 0.0, 1.0)
	elif beat == Sim.FLAGGING:
		var room := mini(int(sim.get_sounded()), int(Sim.FLAG_CAP))
		quota_frac = 0.0 if room <= 0 else clampf(float(sim.get_raised()) / float(room), 0.0, 1.0)
	elif beat == Sim.HORNING:
		var room := mini(int(sim.get_rung()), int(Sim.HORN_CAP))
		quota_frac = 0.0 if room <= 0 else clampf(float(sim.get_sounded()) / float(room), 0.0, 1.0)
	elif beat == Sim.BELLING:
		var room := mini(int(sim.get_lit()), int(Sim.BELL_CAP))
		quota_frac = 0.0 if room <= 0 else clampf(float(sim.get_rung()) / float(room), 0.0, 1.0)
	elif beat == Sim.LAMPING:
		var room := mini(int(sim.get_stood()), int(Sim.LAMP_CAP))
		quota_frac = 0.0 if room <= 0 else clampf(float(sim.get_lit()) / float(room), 0.0, 1.0)
	elif beat == Sim.WATCHING:
		var room := mini(int(sim.get_posted()), int(Sim.WATCH_CAP))
		quota_frac = 0.0 if room <= 0 else clampf(float(sim.get_stood()) / float(room), 0.0, 1.0)
	elif beat == Sim.RELIEVING:
		var room := mini(int(sim.get_paid()), int(Sim.RELIEF_CAP))
		quota_frac = 0.0 if room <= 0 else clampf(float(sim.get_posted()) / float(room), 0.0, 1.0)
	elif beat == Sim.WAGING:
		var owed := int(sim.get_gated())
		quota_frac = 0.0 if owed <= 0 else clampf(float(sim.get_paid()) / float(owed), 0.0, 1.0)
	elif beat == Sim.GATING:
		var room := mini(int(sim.get_lofted()), int(Sim.GATE_CAP))
		quota_frac = 0.0 if room <= 0 else clampf(float(sim.get_gated()) / float(room), 0.0, 1.0)
	elif beat == Sim.LOFTING:
		var crew := int(sim.get_hired())
		quota_frac = 0.0 if crew <= 0 else clampf(float(sim.get_lofted()) / float(crew), 0.0, 1.0)
	elif beat == Sim.BUNKING:
		var spendable := int(sim.get_banked()) - (int(sim.get_banked()) % int(Sim.HIRE_COST))
		quota_frac = 0.0 if spendable <= 0 else clampf(float(int(sim.get_hired()) * int(Sim.HIRE_COST)) / float(spendable), 0.0, 1.0)
	elif beat == Sim.YARDING:
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
			_draw_crib(rect, sim.get_beat() >= Sim.CART)
		Sim.SHIP:
			_draw_ship(rect, sim.get_beat() >= Sim.SHIPPING)
		Sim.STALL:
			_draw_stall(rect, sim.get_beat() >= Sim.MARKET)
		Sim.YARD:
			_draw_yard(rect, sim.get_beat() >= Sim.YARDING)
		Sim.BUNK:
			_draw_bunk(rect, sim.get_beat() >= Sim.BUNKING)
		Sim.LOFT:
			_draw_loft(rect, sim.get_beat() >= Sim.LOFTING)
		Sim.GATE:
			_draw_gate(rect, sim.get_beat() >= Sim.GATING)
		Sim.WAGE:
			_draw_wage(rect, sim.get_beat() >= Sim.WAGING)
		Sim.RELIEF:
			_draw_relief(rect, sim.get_beat() >= Sim.RELIEVING)
		Sim.WATCH:
			_draw_watch(rect, sim.get_beat() >= Sim.WATCHING)
		Sim.LAMP:
			_draw_lamp(rect, sim.get_beat() >= Sim.LAMPING)
		Sim.BELL:
			_draw_bell(rect, sim.get_beat() >= Sim.BELLING)
		Sim.HORN:
			_draw_horn(rect, sim.get_beat() >= Sim.HORNING)
		Sim.FLAG:
			_draw_flag(rect, sim.get_beat() >= Sim.FLAGGING)
		Sim.BANNER:
			_draw_banner(rect, sim.get_beat() >= Sim.BANNERING)
		Sim.PENNANT:
			_draw_pennant(rect, sim.get_beat() >= Sim.PENNANTING)
		Sim.STANDARD:
			_draw_standard(rect, sim.get_beat() >= Sim.STANDARDING)
		Sim.JACK:
			_draw_jack(rect, sim.get_beat() >= Sim.JACKING)
		Sim.ENSIGN:
			_draw_ensign(rect, sim.get_beat() >= Sim.ENSIGNING)
		Sim.BURGEE:
			_draw_burgee(rect, sim.get_beat() >= Sim.BURGEEING)
		Sim.CORNET:
			_draw_cornet(rect, sim.get_beat() >= Sim.CORNETING)
		Sim.GUIDON:
			_draw_guidon(rect, sim.get_beat() >= Sim.GUIDONING)
		Sim.FANION:
			_draw_fanion(rect, sim.get_beat() >= Sim.FANIONING)
	if Vector2i(x, y) == Sim.ANTHILL:
		_draw_anthill(rect)
	var salt: Dictionary = sim.get_cell_salt(x, y)
	_draw_salt(rect, int(salt["loose"]), int(salt["stacked"]), int(salt["covered"]), int(salt["crib"]), int(salt["ship"]), int(salt["stall"]), int(salt["yard"]), int(salt["bunk"]), int(salt["loft"]), int(salt["gate"]), int(salt["wage"]), int(salt["relief"]), int(salt["watch"]), int(salt["lamp"]), int(salt["bell"]), int(salt["horn"]), int(salt["flag"]), int(salt["banner"]), int(salt["pennant"]), int(salt["standard"]), int(salt["jack"]), int(salt["ensign"]), int(salt["burgee"]), int(salt["cornet"]), int(salt["guidon"]), int(salt["fanion"]))


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


func _draw_bunk(rect: Rect2, open: bool) -> void:
	var timber := Color("5c3b2e") if open else Color("b7a48a")
	var blanket := Color("e7d3a4") if open else Color("d5cec0")
	var wash := Color(0.36, 0.23, 0.16, 0.28) if open else Color(0.36, 0.23, 0.16, 0.12)
	draw_rect(rect, wash)
	var roof := PackedVector2Array([
		rect.position + Vector2(4, 18),
		rect.position + Vector2(rect.size.x * 0.5, 6),
		rect.position + Vector2(rect.size.x - 4, 18),
	])
	draw_colored_polygon(roof, timber)
	var room := Rect2(rect.position + Vector2(8, 18), Vector2(rect.size.x - 16, rect.size.y - 26))
	draw_rect(room, timber)
	var bed := Rect2(room.position + Vector2(3, room.size.y * 0.35), Vector2(room.size.x - 6, room.size.y * 0.45))
	draw_rect(bed, blanket)
	draw_rect(Rect2(room.position + Vector2(room.size.x * 0.38, room.size.y * 0.15), Vector2(room.size.x * 0.24, room.size.y * 0.28)), Color("f4efe6") if open else Color("c8c2b6"))


func _draw_loft(rect: Rect2, open: bool) -> void:
	var timber := Color("4a3b2a") if open else Color("b7a48a")
	var floor := Color("e7d3a4") if open else Color("d5cec0")
	var wash := Color(0.29, 0.23, 0.16, 0.28) if open else Color(0.29, 0.23, 0.16, 0.12)
	draw_rect(rect, wash)
	var platform := Rect2(rect.position + Vector2(6, 8), Vector2(rect.size.x - 12, 8))
	draw_rect(platform, timber)
	draw_rect(Rect2(platform.position + Vector2(2, 2), Vector2(platform.size.x - 4, 4)), floor)
	var post_h := rect.size.y - 22.0
	draw_rect(Rect2(rect.position + Vector2(8, 16), Vector2(3, post_h)), timber)
	draw_rect(Rect2(rect.position + Vector2(rect.size.x - 11, 16), Vector2(3, post_h)), timber)
	var ladder_x := rect.position.x + rect.size.x * 0.5
	draw_line(Vector2(ladder_x - 4, rect.position.y + 18), Vector2(ladder_x - 4, rect.end.y - 6), timber, 2.0)
	draw_line(Vector2(ladder_x + 4, rect.position.y + 18), Vector2(ladder_x + 4, rect.end.y - 6), timber, 2.0)
	for i in 3:
		var y_line := rect.position.y + 24.0 + float(i) * 6.0
		draw_line(Vector2(ladder_x - 4, y_line), Vector2(ladder_x + 4, y_line), floor, 1.5)


func _draw_gate(rect: Rect2, open: bool) -> void:
	var iron := Color("3e4c59") if open else Color("b7a48a")
	var bar := Color("d7e3ea") if open else Color("d5cec0")
	var wash := Color(0.24, 0.32, 0.38, 0.28) if open else Color(0.24, 0.32, 0.38, 0.12)
	draw_rect(rect, wash)
	draw_rect(Rect2(rect.position + Vector2(8, 10), Vector2(4, rect.size.y - 18)), iron)
	draw_rect(Rect2(rect.position + Vector2(rect.size.x - 12, 10), Vector2(4, rect.size.y - 18)), iron)
	draw_rect(Rect2(rect.position + Vector2(8, 10), Vector2(rect.size.x - 16, 4)), iron)
	draw_line(rect.position + Vector2(12, 22), rect.position + Vector2(rect.size.x - 12, rect.size.y - 12), bar, 2.0)
	draw_line(rect.position + Vector2(rect.size.x - 12, 22), rect.position + Vector2(12, rect.size.y - 12), bar, 2.0)


func _draw_wage(rect: Rect2, open: bool) -> void:
	var wood := Color("8a6a2f") if open else Color("b7a48a")
	var coin := Color("f0c14a") if open else Color("d5cec0")
	var wash := Color(0.54, 0.42, 0.18, 0.28) if open else Color(0.54, 0.42, 0.18, 0.12)
	draw_rect(rect, wash)
	var table := Rect2(rect.position + Vector2(6, rect.size.y - 16), Vector2(rect.size.x - 12, 8))
	draw_rect(table, wood)
	draw_rect(Rect2(rect.position + Vector2(10, rect.size.y - 28), Vector2(4, 12)), wood)
	draw_rect(Rect2(rect.position + Vector2(rect.size.x - 14, rect.size.y - 28), Vector2(4, 12)), wood)
	var purse := rect.position + Vector2(rect.size.x * 0.5, 16)
	draw_circle(purse, 8, coin)
	draw_circle(purse, 8, wood, false, 2.0)


func _draw_relief(rect: Rect2, open: bool) -> void:
	var post := Color("2f6f78") if open else Color("b7a48a")
	var board := Color("d7e8ea") if open else Color("d5cec0")
	var wash := Color(0.18, 0.42, 0.46, 0.28) if open else Color(0.18, 0.42, 0.46, 0.12)
	draw_rect(rect, wash)
	draw_rect(Rect2(rect.position + Vector2(10, 16), Vector2(4, rect.size.y - 22)), post)
	draw_rect(Rect2(rect.position + Vector2(rect.size.x - 14, 16), Vector2(4, rect.size.y - 22)), post)
	var sign := Rect2(rect.position + Vector2(8, 8), Vector2(rect.size.x - 16, 14))
	draw_rect(sign, board)
	draw_rect(sign, post, false, 2.0)
	draw_line(sign.position + Vector2(sign.size.x * 0.5, 3), sign.position + Vector2(sign.size.x * 0.5, sign.size.y - 3), post, 2.0)
	draw_line(sign.position + Vector2(sign.size.x * 0.5 - 4, 7), sign.position + Vector2(sign.size.x * 0.5 + 4, 7), post, 2.0)


func _draw_watch(rect: Rect2, open: bool) -> void:
	var post := Color("2c3a6e") if open else Color("b7a48a")
	var lamp := Color("f4e3a1") if open else Color("d5cec0")
	var wash := Color(0.18, 0.22, 0.42, 0.28) if open else Color(0.18, 0.22, 0.42, 0.12)
	draw_rect(rect, wash)
	draw_rect(Rect2(rect.position + Vector2(rect.size.x * 0.5 - 2.0, 18), Vector2(4, rect.size.y - 24)), post)
	draw_rect(Rect2(rect.position + Vector2(10, 16), Vector2(rect.size.x - 20, 4)), post)
	var lamp_at := rect.position + Vector2(rect.size.x * 0.5, 11)
	draw_circle(lamp_at, 6.0, lamp)
	draw_circle(lamp_at, 6.0, post, false, 2.0)
	if open:
		draw_line(lamp_at + Vector2(-10, -2), lamp_at + Vector2(-6, 0), lamp, 1.5)
		draw_line(lamp_at + Vector2(10, -2), lamp_at + Vector2(6, 0), lamp, 1.5)
		draw_line(lamp_at + Vector2(0, -10), lamp_at + Vector2(0, -6), lamp, 1.5)


func _draw_lamp(rect: Rect2, open: bool) -> void:
	var iron := Color("3a2a18") if open else Color("b7a48a")
	var glass := Color("f6e2a4") if open else Color("d5cec0")
	var flame := Color("e07a2f") if open else Color("c8c2b6")
	var wash := Color(0.85, 0.55, 0.16, 0.32) if open else Color(0.55, 0.42, 0.22, 0.12)
	draw_rect(rect, wash)
	var pole := Rect2(rect.position + Vector2(rect.size.x * 0.5 - 2.0, 22), Vector2(4, rect.size.y - 28))
	draw_rect(pole, iron)
	var cap := Rect2(rect.position + Vector2(rect.size.x * 0.5 - 10, 6), Vector2(20, 4))
	draw_rect(cap, iron)
	var body := Rect2(rect.position + Vector2(rect.size.x * 0.5 - 8, 10), Vector2(16, 14))
	draw_rect(body, glass)
	draw_rect(body, iron, false, 2.0)
	draw_line(body.position + Vector2(body.size.x * 0.5, 1), body.position + Vector2(body.size.x * 0.5, body.size.y - 1), iron, 1.5)
	var flame_tip := body.position + Vector2(body.size.x * 0.5, 2)
	draw_colored_polygon(PackedVector2Array([
		flame_tip + Vector2(0, 1),
		flame_tip + Vector2(-4, 9),
		flame_tip + Vector2(4, 9),
	]), flame)
	if open:
		draw_line(body.position + Vector2(-6, 2), body.position + Vector2(-2, 4), flame, 1.5)
		draw_line(body.position + Vector2(body.size.x + 6, 2), body.position + Vector2(body.size.x + 2, 4), flame, 1.5)
		draw_line(body.position + Vector2(body.size.x * 0.5, -8), cap.position + Vector2(cap.size.x * 0.5, 0), flame, 1.5)


func _draw_bell(rect: Rect2, open: bool) -> void:
	var iron := Color("3a2a18") if open else Color("b7a48a")
	var brass := Color("e0b03a") if open else Color("d5cec0")
	var clapper := Color("6b3e24") if open else Color("c8c2b6")
	var wash := Color(0.78, 0.55, 0.12, 0.30) if open else Color(0.55, 0.42, 0.22, 0.12)
	draw_rect(rect, wash)
	var mid := rect.position.x + rect.size.x * 0.5
	var top := rect.position.y
	draw_rect(Rect2(Vector2(mid - 8.0, top + 5.0), Vector2(16, 4)), iron)
	draw_line(Vector2(mid, top + 9.0), Vector2(mid, top + 14.0), iron, 2.0)
	var body := PackedVector2Array([
		Vector2(mid - 6.0, top + 14.0),
		Vector2(mid + 6.0, top + 14.0),
		Vector2(mid + 14.0, top + 31.0),
		Vector2(mid + 12.0, top + 34.0),
		Vector2(mid - 12.0, top + 34.0),
		Vector2(mid - 14.0, top + 31.0),
	])
	draw_colored_polygon(body, brass)
	var outline := PackedVector2Array([
		Vector2(mid - 6.0, top + 14.0),
		Vector2(mid + 6.0, top + 14.0),
		Vector2(mid + 14.0, top + 31.0),
		Vector2(mid + 12.0, top + 34.0),
		Vector2(mid - 12.0, top + 34.0),
		Vector2(mid - 14.0, top + 31.0),
		Vector2(mid - 6.0, top + 14.0),
	])
	draw_polyline(outline, iron, 2.0)
	draw_circle(Vector2(mid, top + 27.0), 3.0, clapper)
	if open:
		draw_line(Vector2(mid + 12.0, top + 18.0), Vector2(mid + 18.0, top + 14.0), brass, 1.5)
		draw_line(Vector2(mid + 12.0, top + 24.0), Vector2(mid + 18.0, top + 24.0), brass, 1.5)
		draw_line(Vector2(mid + 12.0, top + 30.0), Vector2(mid + 18.0, top + 33.0), brass, 1.5)


func _draw_horn(rect: Rect2, open: bool) -> void:
	var rim := Color("6b2e22") if open else Color("b7a48a")
	var bone := Color("f4e4c8") if open else Color("d5cec0")
	var mouth := Color("8c3b2a") if open else Color("c8c2b6")
	var wash := Color(0.55, 0.28, 0.18, 0.34) if open else Color(0.45, 0.32, 0.22, 0.12)
	draw_rect(rect, wash)
	var left := rect.position.x
	var top := rect.position.y
	var curve := PackedVector2Array([
		Vector2(left + 8.0, top + 30.0),
		Vector2(left + 14.0, top + 24.0),
		Vector2(left + 22.0, top + 16.0),
		Vector2(left + 30.0, top + 12.0),
	])
	draw_polyline(curve, bone, 7.0)
	draw_polyline(curve, rim, 2.0)
	var flare := PackedVector2Array([
		Vector2(left + 28.0, top + 8.0),
		Vector2(left + 40.0, top + 4.0),
		Vector2(left + 40.0, top + 22.0),
		Vector2(left + 28.0, top + 16.0),
	])
	draw_colored_polygon(flare, bone)
	draw_polyline(PackedVector2Array([
		flare[0], flare[1], flare[2], flare[3], flare[0],
	]), rim, 2.0)
	draw_circle(Vector2(left + 8.0, top + 30.0), 3.5, mouth)
	draw_rect(Rect2(Vector2(left + 5.0, top + 27.0), Vector2(6.0, 6.0)), rim, false, 1.5)
	if open:
		draw_arc(Vector2(left + 40.0, top + 13.0), 6.0, -0.9, 0.9, 8, bone, 1.5)
		draw_arc(Vector2(left + 40.0, top + 13.0), 10.0, -0.7, 0.7, 8, bone, 1.5)


func _draw_flag(rect: Rect2, open: bool) -> void:
	var pole := Color("3a2e24") if open else Color("b7a48a")
	var cloth := Color("c4453c") if open else Color("d5cec0")
	var fold := Color("8e2e2a") if open else Color("c8c2b6")
	var wash := Color(0.62, 0.18, 0.16, 0.30) if open else Color(0.45, 0.32, 0.22, 0.12)
	draw_rect(rect, wash)
	var left := rect.position.x
	var top := rect.position.y
	draw_rect(Rect2(Vector2(left + 10.0, top + 6.0), Vector2(4.0, rect.size.y - 12.0)), pole)
	draw_circle(Vector2(left + 12.0, top + 5.0), 3.2, pole)
	var fly := PackedVector2Array([
		Vector2(left + 14.0, top + 8.0),
		Vector2(left + 36.0, top + 11.0),
		Vector2(left + 33.0, top + 20.0),
		Vector2(left + 14.0, top + 18.0),
	])
	draw_colored_polygon(fly, cloth)
	var hem := PackedVector2Array([
		Vector2(left + 14.0, top + 18.0),
		Vector2(left + 33.0, top + 20.0),
		Vector2(left + 36.0, top + 30.0),
		Vector2(left + 14.0, top + 28.0),
	])
	draw_colored_polygon(hem, fold)
	draw_polyline(PackedVector2Array([
		fly[0], fly[1], fly[2], hem[2], hem[3], fly[0],
	]), pole, 1.5)
	draw_line(Vector2(left + 20.0, top + 12.0), Vector2(left + 22.0, top + 26.0), Color(1, 1, 1, 0.35 if open else 0.15), 1.5)


func _draw_banner(rect: Rect2, open: bool) -> void:
	var bar := Color("efe4c8") if open else Color("d5cec0")
	var iron := Color("2a3148") if open else Color("b7a48a")
	var cloth := Color("2f4f86") if open else Color("d5cec0")
	var hem := Color("1d355e") if open else Color("c8c2b6")
	var wash := Color(0.16, 0.28, 0.5, 0.32) if open else Color(0.45, 0.32, 0.22, 0.12)
	draw_rect(rect, wash)
	var left := rect.position.x
	var top := rect.position.y
	var width := rect.size.x
	# A crossbar and a cloth wider than the flag's fly. No pole.
	draw_rect(Rect2(Vector2(left + 2.0, top + 14.0), Vector2(width - 4.0, 4.0)), iron)
	draw_rect(Rect2(Vector2(left + 3.0, top + 15.0), Vector2(width - 6.0, 2.0)), bar)
	draw_line(Vector2(left + 7.0, top + 18.0), Vector2(left + 6.0, top + 22.0), iron, 1.5)
	draw_line(Vector2(left + width - 7.0, top + 18.0), Vector2(left + width - 6.0, top + 22.0), iron, 1.5)
	var fly := PackedVector2Array([
		Vector2(left + 3.0, top + 22.0),
		Vector2(left + width - 3.0, top + 22.0),
		Vector2(left + width - 5.0, top + 32.0),
		Vector2(left + 5.0, top + 32.0),
	])
	draw_colored_polygon(fly, cloth)
	var fold := PackedVector2Array([
		Vector2(left + 5.0, top + 32.0),
		Vector2(left + width - 5.0, top + 32.0),
		Vector2(left + width * 0.64, top + 38.0),
		Vector2(left + width * 0.36, top + 38.0),
	])
	draw_colored_polygon(fold, hem)
	draw_polyline(PackedVector2Array([
		fly[0], fly[1], fly[2], fold[1], fold[2], fold[3], fold[0], fly[3], fly[0],
	]), iron, 1.5)


func _draw_pennant(rect: Rect2, open: bool) -> void:
	var staff := Color("5c3317") if open else Color("b7a48a")
	var fly := Color("b5522a") if open else Color("d5cec0")
	var edge := Color("6e3018") if open else Color("c8c2b6")
	var wash := Color(0.62, 0.28, 0.14, 0.32) if open else Color(0.45, 0.32, 0.22, 0.12)
	draw_rect(rect, wash)
	var left := rect.position.x
	var top := rect.position.y
	# A short staff and a small triangular fly. Not a crossbar, not a wide cloth, not a rectangle.
	draw_rect(Rect2(Vector2(left + 14.0, top + 18.0), Vector2(3.0, 16.0)), staff)
	var triangle := PackedVector2Array([
		Vector2(left + 17.0, top + 16.0),
		Vector2(left + 32.0, top + 22.0),
		Vector2(left + 17.0, top + 28.0),
	])
	draw_colored_polygon(triangle, fly)
	draw_polyline(PackedVector2Array([
		triangle[0], triangle[1], triangle[2], triangle[0],
	]), edge, 1.5)


func _draw_standard(rect: Rect2, open: bool) -> void:
	var staff := Color("f3efe4") if open else Color("d5cec0")
	var cloth := Color("2a2622") if open else Color("b7a48a")
	var edge := Color("1c1916") if open else Color("c8c2b6")
	var wash := Color(0.78, 0.74, 0.64, 0.34) if open else Color(0.45, 0.32, 0.22, 0.12)
	draw_rect(rect, wash)
	var left := rect.position.x
	var top := rect.position.y
	# A tall pale staff and a small dark cloth. Not the pennant's short staff
	# and rust triangle, not the banner's crossbar and wide cloth, and not the
	# flag's red rectangle.
	draw_rect(Rect2(Vector2(left + 12.0, top + 3.0), Vector2(3.0, rect.size.y - 6.0)), staff)
	draw_circle(Vector2(left + 13.5, top + 3.0), 2.4, staff)
	var fly := PackedVector2Array([
		Vector2(left + 15.0, top + 6.0),
		Vector2(left + 28.0, top + 8.0),
		Vector2(left + 26.0, top + 16.0),
		Vector2(left + 15.0, top + 14.0),
	])
	draw_colored_polygon(fly, cloth)
	draw_polyline(PackedVector2Array([
		fly[0], fly[1], fly[2], fly[3], fly[0],
	]), edge, 1.5)


func _draw_jack(rect: Rect2, open: bool) -> void:
	var hoist := Color("f6f1e6") if open else Color("efe6d2")
	var cloth := Color("1a1714") if open else Color("3a342c")
	var edge := Color("0e0c0a") if open else Color("241f1a")
	var wash := Color(0.22, 0.2, 0.16, 0.34) if open else Color(0.45, 0.32, 0.22, 0.12)
	draw_rect(rect, wash)
	var left := rect.position.x
	var top := rect.position.y
	# A small dark flag on a short pale hoist. Two convex halves, so the
	# swallowtail notch still fills. Not the standard's tall pale staff and
	# small dark cloth, not the pennant's short staff and rust triangle, not
	# the banner's crossbar and wide blue cloth, and not the flag's red rectangle.
	draw_rect(Rect2(Vector2(left + 14.0, top + 16.0), Vector2(3.0, 16.0)), hoist)
	draw_circle(Vector2(left + 15.5, top + 16.0), 2.2, hoist)
	var upper := PackedVector2Array([
		Vector2(left + 17.0, top + 14.0),
		Vector2(left + 34.0, top + 15.0),
		Vector2(left + 21.0, top + 20.0),
	])
	var lower := PackedVector2Array([
		Vector2(left + 17.0, top + 26.0),
		Vector2(left + 34.0, top + 25.0),
		Vector2(left + 21.0, top + 20.0),
	])
	draw_colored_polygon(upper, cloth)
	draw_colored_polygon(lower, cloth)
	draw_polyline(PackedVector2Array([
		upper[0], upper[1], upper[2], lower[1], lower[0], upper[0],
	]), edge, 1.5)


func _draw_fanion(rect: Rect2, open: bool) -> void:
	var staff := Color("1a1612") if open else Color("8a8178")
	var cloth := Color("f6f1e4") if open else Color("e4ddd0")
	var wash := Color(0.97, 0.94, 0.86, 0.42) if open else Color(0.45, 0.32, 0.22, 0.12)
	draw_rect(rect, wash)
	var left := rect.position.x
	var top := rect.position.y
	# A small square pale cloth on a short dark staff. Drawn low so the
	# countdown does not cover the north row. Not the guidon's forked pale
	# cloth, not the cornet's long pale streamer, not the burgee's swallowtail,
	# and not the pennant's triangle.
	draw_rect(Rect2(Vector2(left + 8.0, top + 20.0), Vector2(3.0, 14.0)), staff)
	draw_rect(Rect2(Vector2(left + 11.0, top + 20.0), Vector2(12.0, 12.0)), cloth)
	draw_rect(Rect2(Vector2(left + 11.0, top + 20.0), Vector2(12.0, 12.0)), staff, false, 1.5)


func _draw_guidon(rect: Rect2, open: bool) -> void:
	var head := Color("1a1612") if open else Color("8a8178")
	var cloth := Color("f3ead6") if open else Color("e4ddd0")
	var wash := Color(0.96, 0.91, 0.78, 0.42) if open else Color(0.45, 0.32, 0.22, 0.12)
	draw_rect(rect, wash)
	var left := rect.position.x
	var top := rect.position.y
	# A forked pale cloth with a dark head. The fork ends short of the
	# cornet's long streamer. Drawn low so the countdown does not cover the
	# north row. Not the burgee's swallowtail, two dark tails on a pale cloth,
	# and not the cornet's single pale point on a dark hoist.
	draw_rect(Rect2(Vector2(left + 5.0, top + 20.0), Vector2(8.0, 14.0)), head)
	var fork := PackedVector2Array([
		Vector2(left + 13.0, top + 20.0),
		Vector2(left + 28.0, top + 18.0),
		Vector2(left + 20.0, top + 27.0),
		Vector2(left + 28.0, top + 36.0),
		Vector2(left + 13.0, top + 34.0),
	])
	draw_colored_polygon(fork, cloth)
	draw_polyline(PackedVector2Array([
		fork[0], fork[1], fork[2], fork[3], fork[4], fork[0],
	]), head, 1.5)


func _draw_cornet(rect: Rect2, open: bool) -> void:
	var hoist := Color("1a1612") if open else Color("8a8178")
	var cloth := Color("f7f1e2") if open else Color("e4ddd0")
	var wash := Color(0.97, 0.93, 0.84, 0.42) if open else Color(0.45, 0.32, 0.22, 0.12)
	draw_rect(rect, wash)
	var left := rect.position.x
	var top := rect.position.y
	# A long pale streamer with a dark hoist. The cloth runs across the cell
	# and tapers to a point. Drawn low so the countdown does not cover the
	# north row. Not the burgee's swallowtail, two dark tails on a pale cloth,
	# and not the ensign's small pale flag with a dark fly.
	draw_rect(Rect2(Vector2(left + 3.0, top + 20.0), Vector2(5.0, 16.0)), hoist)
	var streamer := PackedVector2Array([
		Vector2(left + 8.0, top + 22.0),
		Vector2(left + 38.0, top + 27.0),
		Vector2(left + 8.0, top + 34.0),
	])
	draw_colored_polygon(streamer, cloth)
	draw_polyline(PackedVector2Array([
		streamer[0], streamer[1], streamer[2], streamer[0],
	]), hoist, 1.5)


func _draw_burgee(rect: Rect2, open: bool) -> void:
	var staff := Color("3e3428") if open else Color("b7a48a")
	var cloth := Color("f4efe4") if open else Color("e4ddd0")
	var tail := Color("1a1612") if open else Color("8a8178")
	var wash := Color(0.95, 0.9, 0.78, 0.42) if open else Color(0.45, 0.32, 0.22, 0.12)
	draw_rect(rect, wash)
	var left := rect.position.x
	var top := rect.position.y
	# A swallowtail: pale cloth and two dark tails, with the notch left open.
	# Drawn low in the cell so the countdown does not cover the north row.
	# Not the ensign's small pale flag with one dark fly, and not the
	# pennant's single triangle.
	draw_rect(Rect2(Vector2(left + 6.0, top + 19.0), Vector2(3.0, 15.0)), staff)
	var body := PackedVector2Array([
		Vector2(left + 9.0, top + 19.0),
		Vector2(left + 22.0, top + 19.0),
		Vector2(left + 22.0, top + 33.0),
		Vector2(left + 9.0, top + 33.0),
	])
	draw_colored_polygon(body, cloth)
	var upper := PackedVector2Array([
		Vector2(left + 22.0, top + 19.0),
		Vector2(left + 37.0, top + 16.0),
		Vector2(left + 22.0, top + 24.0),
	])
	var lower := PackedVector2Array([
		Vector2(left + 22.0, top + 33.0),
		Vector2(left + 37.0, top + 36.0),
		Vector2(left + 22.0, top + 28.0),
	])
	draw_colored_polygon(upper, tail)
	draw_colored_polygon(lower, tail)
	draw_polyline(PackedVector2Array([
		body[0], body[1], upper[1], upper[2], lower[2], lower[1], lower[0], body[3], body[0],
	]), staff, 1.5)


func _draw_ensign(rect: Rect2, open: bool) -> void:
	var staff := Color("4a4034") if open else Color("b7a48a")
	var cloth := Color("f6f1e4") if open else Color("e4ddd0")
	var fly := Color("241f1a") if open else Color("8a8178")
	var wash := Color(0.93, 0.88, 0.74, 0.42) if open else Color(0.45, 0.32, 0.22, 0.12)
	draw_rect(rect, wash)
	var left := rect.position.x
	var top := rect.position.y
	# A small pale flag with a dark fly, low in the cell so the countdown does
	# not cover it. Not the jack's small dark flag and short pale hoist, not
	# the standard's tall pale staff and small dark cloth, not the pennant's
	# short staff and rust triangle, not the banner's crossbar and wider blue
	# cloth, and not the flag's red rectangle.
	draw_rect(Rect2(Vector2(left + 8.0, top + 20.0), Vector2(3.0, 14.0)), staff)
	var pale := PackedVector2Array([
		Vector2(left + 11.0, top + 18.0),
		Vector2(left + 26.0, top + 19.0),
		Vector2(left + 26.0, top + 28.0),
		Vector2(left + 11.0, top + 27.0),
	])
	draw_colored_polygon(pale, cloth)
	var dark := PackedVector2Array([
		Vector2(left + 26.0, top + 19.0),
		Vector2(left + 34.0, top + 21.0),
		Vector2(left + 33.0, top + 30.0),
		Vector2(left + 26.0, top + 28.0),
	])
	draw_colored_polygon(dark, fly)
	draw_polyline(PackedVector2Array([
		pale[0], pale[1], dark[1], dark[2], dark[3], pale[3], pale[0],
	]), staff, 1.5)


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


func _draw_salt(rect: Rect2, loose: int, stacked: int, covered: int, crib: int, ship: int, stall: int, yard: int, bunk: int, loft: int, gate: int, wage: int, relief: int, watch: int, lamp: int, bell: int, horn: int, flag: int, banner: int, pennant: int, standard: int, jack: int, ensign: int, burgee: int, cornet: int, guidon: int, fanion: int) -> void:
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
	for i in mini(bunk, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("f4efe6"))
	for i in mini(loft, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("efe4d4"))
	for i in mini(gate, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("d7e3ea"))
	for i in mini(wage, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("f6e2a8"))
	for i in mini(relief, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("d7e8ea"))
	for i in mini(watch, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("d5d8f0"))
	for i in mini(lamp, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("f6c15a"))
	for i in mini(bell, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("f2d48a"))
	for i in mini(horn, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("e8a48a"))
	for i in mini(flag, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("e07070"))
	for i in mini(banner, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("8eb0e8"))
	for i in mini(pennant, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("e09060"))
	for i in mini(standard, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("f4efe6"))
	for i in mini(jack, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("2a2622"))
	for i in mini(ensign, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("f6f1e4"))
	for i in mini(burgee, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("1a1612"))
	for i in mini(cornet, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("f7f1e2"))
	for i in mini(guidon, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("efe4c2"))
	for i in mini(fanion, 3):
		_diamond(rect.position + Vector2(12 + i * 10, rect.size.y - 12), 4.2, Color("f4e7b0"))
	var total := loose + stacked + covered + crib + ship + stall + yard + bunk + loft + gate + wage + relief + watch + lamp + bell + horn + flag + banner + pennant + standard + jack + ensign + burgee + cornet + guidon + fanion
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
	var span_y := int((Sim.GRID_H - Sim.GRID_NORTH) * CELL)
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
	hint_a.position = Vector2(20, 1320)
	hint_a.size = Vector2(748, 22)
	hud.add_child(hint_a)
	# Font size and autowrap are set before the text. Otherwise the label caches
	# the unwrapped width at the default font size and will not shrink back to
	# this box, which pushes the last line under the side panel.
	var hint_b := Label.new()
	hint_b.name = "HintLine"
	hint_b.position = Vector2(20, 1344)
	hint_b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hint_b.add_theme_font_size_override("font_size", 14)
	hint_b.add_theme_color_override("font_color", INK)
	hint_b.clip_text = true
	hint_b.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_b.custom_minimum_size = Vector2(748, 88)
	hint_b.text = "1 rake, 2 stack, 3 cover, 4 trail, 5 pan, 6 crib, 7 ship,\n8 stall, 9 yard, 0 bunk, B loft, C gate, E wage, F relief,\nG watch, H lamp, I bell, J horn, K flag, L banner,\nM pennant, N standard, O jack, P ensign, Q burgee, T cornet, U guidon, V fanion. Space paints. R restarts."
	hint_b.size = Vector2(748, 100)
	hint_b.clip_contents = true
	hud.add_child(hint_b)
	hint_b.size = Vector2(748, 100)

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
	var rules := _make_label("Paint the flats. Workers follow the mark under their feet and are not selectable.\nWet season: rake the shore, stack the loose salt, cover the stacks. The first rain banks covered salt and pulls the brine back. Dry season: shore rakes go idle. Paint pans and workers crystallize salt until the second rain. Then paint a crib. Workers move the banked salt into it. Then paint a ship. Workers load that crib onto it. Then paint a stall. Workers sell that cargo, one coin a unit. Then paint a yard. Workers bank those coins, one at a time. Then paint a bunk. Workers hire from those coins, one hundred a hire. Then paint a loft. Workers move those hires into it, one at a time. Then paint a gate. Workers let ten of those hires through, one at a time. Then paint a wage. Workers pay those hires from the yard, four coins a hire. Then paint a relief. Workers post six of the hires who were already paid, one at a time. Then paint a watch. Workers stand four of the hires who were already posted, one at a time. Then paint a lamp. Workers light three of the hires who were already stood, one at a time. Then paint a bell. Workers ring two of the hires who were already lit, one at a time. Then paint a horn. Workers sound one of the hires who were already rung, one at a time. Then paint a flag. Workers raise one of the hires who were already sounded, one at a time. Then paint a banner. Workers hoist one of the hires who were already raised, one at a time. Then paint a pennant. Workers fly one of the hires who were already hoisted, one at a time. Then paint a standard. Workers carry one of the hires who were already flown, one at a time. Then paint a jack. Workers show one of the hires who were already carried, one at a time. Then paint an ensign. Workers break one of the hires who were already shown, one at a time. Then paint a burgee. Workers strike one of the hires who were already broken, one at a time. Then paint a cornet. Workers dip one of the hires who were already struck, one at a time. Then paint a guidon. Workers salute one of the hires who were already dipped, one at a time. Then paint a fanion. Workers present one of the hires who were already saluted, one at a time. Trail is how they cross.", 13, PAPER)
	rules.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rules.custom_minimum_size = Vector2(430, 560)
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
		["0  Bunk", Sim.BUNK, Color("c4a484")],
		["B  Loft", Sim.LOFT, Color("d7c4a3")],
		["C  Gate", Sim.GATE, Color("8aa0a8")],
	]))
	box.add_child(_button_row([
		["E  Wage", Sim.WAGE, Color("e0b84a")],
		["F  Relief", Sim.RELIEF, Color("8ec9c6")],
		["G  Watch", Sim.WATCH, Color("9aa6d6")],
		["H  Lamp", Sim.LAMP, Color("e8b15a")],
	]))
	box.add_child(_button_row([
		["I  Bell", Sim.BELL, Color("e0b03a")],
		["J  Horn", Sim.HORN, Color("c47a5a")],
		["K  Flag", Sim.FLAG, Color("c4453c")],
		["Erase", Sim.EMPTY, Color("c8c2b6")],
	]))
	box.add_child(_button_row([
		["L  Banner", Sim.BANNER, Color("2f4f86")],
		["M  Pennant", Sim.PENNANT, Color("b5522a")],
		["N  Standard", Sim.STANDARD, Color("e7e2d4")],
		["O  Jack", Sim.JACK, Color("d7d1c4")],
		["P  Ensign", Sim.ENSIGN, Color("f6f1e4")],
		["Q  Burgee", Sim.BURGEE, Color("efe6d4")],
		["T  Cornet", Sim.CORNET, Color("f7f1e2")],
		["U  Guidon", Sim.GUIDON, Color("f3ead6")],
		["V  Fanion", Sim.FANION, Color("efe6c8")],
	]))

	cursor_label = _make_label("", 14, PAPER)
	status_label = _make_label("", 14, Color("f0c14a"))
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.custom_minimum_size = Vector2(430, 36)
	summary_label = _make_label("", 18, PAPER)
	summary_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary_label.custom_minimum_size = Vector2(430, 72)
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
		button.custom_minimum_size = Vector2(88, 36) if String(spec[0]).contains("Guidon") or String(spec[0]).contains("Fanion") else Vector2(0, 36)
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
		style.content_margin_left = 6
		style.content_margin_right = 6
		style.content_margin_top = 2
		style.content_margin_bottom = 2
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
		if int(sim.get_presented()) > 0:
			rain_label.text = "The crew has presented the fanion"
			rain_label.add_theme_color_override("font_color", Color("6a5430"))
		elif int(sim.get_saluted()) > 0:
			rain_label.text = "The crew has saluted the guidon"
			rain_label.add_theme_color_override("font_color", Color("6e5830"))
		elif int(sim.get_dipped()) > 0:
			rain_label.text = "The crew has dipped the cornet"
			rain_label.add_theme_color_override("font_color", Color("6e5c38"))
		elif int(sim.get_struck()) > 0:
			rain_label.text = "The crew has struck the burgee"
			rain_label.add_theme_color_override("font_color", Color("3e3428"))
		elif int(sim.get_broken()) > 0:
			rain_label.text = "The crew has broken the ensign"
			rain_label.add_theme_color_override("font_color", Color("5c5648"))
		elif int(sim.get_shown()) > 0:
			rain_label.text = "The crew has shown the jack"
			rain_label.add_theme_color_override("font_color", Color("2c2824"))
		elif int(sim.get_carried()) > 0:
			rain_label.text = "The crew has carried the standard"
			rain_label.add_theme_color_override("font_color", Color("5c564c"))
		elif int(sim.get_flown()) > 0:
			rain_label.text = "The crew has flown the pennant"
			rain_label.add_theme_color_override("font_color", Color("8a3b22"))
		elif int(sim.get_hoisted()) > 0:
			rain_label.text = "The crew has hoisted the banner"
			rain_label.add_theme_color_override("font_color", Color("1e3f73"))
		elif int(sim.get_raised()) > 0:
			rain_label.text = "The crew has raised the flag"
			rain_label.add_theme_color_override("font_color", Color("8e2a32"))
		elif int(sim.get_sounded()) > 0:
			rain_label.text = "The crew has sounded the horn"
			rain_label.add_theme_color_override("font_color", Color("6e3b2a"))
		elif int(sim.get_rung()) > 0:
			rain_label.text = "The crew has rung the bell"
			rain_label.add_theme_color_override("font_color", Color("8a5a12"))
		elif int(sim.get_lit()) > 0:
			rain_label.text = "The crew has lit the lamp"
			rain_label.add_theme_color_override("font_color", Color("8a5a12"))
		elif int(sim.get_stood()) > 0:
			rain_label.text = "The crew has stood the watch"
			rain_label.add_theme_color_override("font_color", Color("2c3a6e"))
		elif int(sim.get_posted()) > 0:
			rain_label.text = "The crew has been posted"
			rain_label.add_theme_color_override("font_color", Color("2f6f78"))
		elif int(sim.get_paid()) > 0:
			rain_label.text = "The crew has been paid"
			rain_label.add_theme_color_override("font_color", Color("8a6a2f"))
		elif int(sim.get_gated()) > 0:
			rain_label.text = "The crew passed the gate"
			rain_label.add_theme_color_override("font_color", Color("3e4c59"))
		elif int(sim.get_lofted()) > 0:
			rain_label.text = "The crew is in the loft"
			rain_label.add_theme_color_override("font_color", Color("4a3b2a"))
		elif int(sim.get_hired()) > 0:
			rain_label.text = "The bunk has hired"
			rain_label.add_theme_color_override("font_color", Color("5c3b2e"))
		elif int(sim.get_banked()) > 0:
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
		if sim.get_beat() == Sim.FANIONING:
			rain_label.text = "Present the fanion. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("6a5430"))
		elif sim.get_beat() == Sim.GUIDONING:
			rain_label.text = "Salute the guidon. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("6e5830"))
		elif sim.get_beat() == Sim.CORNETING:
			rain_label.text = "Dip the cornet. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("6e5c38"))
		elif sim.get_beat() == Sim.BURGEEING:
			rain_label.text = "Strike the burgee. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("3e3428"))
		elif sim.get_beat() == Sim.ENSIGNING:
			rain_label.text = "Break the ensign. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("5c5648"))
		elif sim.get_beat() == Sim.JACKING:
			rain_label.text = "Show the jack. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("2c2824"))
		elif sim.get_beat() == Sim.STANDARDING:
			rain_label.text = "Carry the standard. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("5c564c"))
		elif sim.get_beat() == Sim.PENNANTING:
			rain_label.text = "Fly the pennant. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("8a3b22"))
		elif sim.get_beat() == Sim.BANNERING:
			rain_label.text = "Hoist the banner. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("1e3f73"))
		elif sim.get_beat() == Sim.FLAGGING:
			rain_label.text = "Raise the flag. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("8e2a32"))
		elif sim.get_beat() == Sim.HORNING:
			rain_label.text = "Sound the horn. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("6e3b2a"))
		elif sim.get_beat() == Sim.BELLING:
			rain_label.text = "Ring the bell. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("8a5a12"))
		elif sim.get_beat() == Sim.LAMPING:
			rain_label.text = "Light the lamp. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("8a5a12"))
		elif sim.get_beat() == Sim.WATCHING:
			rain_label.text = "Stand the watch. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("2c3a6e"))
		elif sim.get_beat() == Sim.RELIEVING:
			rain_label.text = "Post the relief. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("2f6f78"))
		elif sim.get_beat() == Sim.WAGING:
			rain_label.text = "Pay the wage. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("8a6a2f"))
		elif sim.get_beat() == Sim.GATING:
			rain_label.text = "Open the gate. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("3e4c59"))
		elif sim.get_beat() == Sim.LOFTING:
			rain_label.text = "Loft the crew. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("4a3b2a"))
		elif sim.get_beat() == Sim.BUNKING:
			rain_label.text = "Hire the bunk. %.1fs" % seconds
			rain_label.add_theme_color_override("font_color", Color("a33b2b") if urgent else Color("5c3b2e"))
		elif sim.get_beat() == Sim.YARDING:
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
	elif sim.get_beat() == Sim.FANIONING:
		season_name = "fanion"
	elif sim.get_beat() == Sim.GUIDONING:
		season_name = "guidon"
	elif sim.get_beat() == Sim.CORNETING:
		season_name = "cornet"
	elif sim.get_beat() == Sim.BURGEEING:
		season_name = "burgee"
	elif sim.get_beat() == Sim.ENSIGNING:
		season_name = "ensign"
	elif sim.get_beat() == Sim.JACKING:
		season_name = "jack"
	elif sim.get_beat() == Sim.STANDARDING:
		season_name = "standard"
	elif sim.get_beat() == Sim.PENNANTING:
		season_name = "pennant"
	elif sim.get_beat() == Sim.BANNERING:
		season_name = "banner"
	elif sim.get_beat() == Sim.FLAGGING:
		season_name = "flag"
	elif sim.get_beat() == Sim.HORNING:
		season_name = "horn"
	elif sim.get_beat() == Sim.BELLING:
		season_name = "bell"
	elif sim.get_beat() == Sim.LAMPING:
		season_name = "lamp"
	elif sim.get_beat() == Sim.WATCHING:
		season_name = "watch"
	elif sim.get_beat() == Sim.RELIEVING:
		season_name = "relief"
	elif sim.get_beat() == Sim.WAGING:
		season_name = "wage"
	elif sim.get_beat() == Sim.GATING:
		season_name = "gate"
	elif sim.get_beat() == Sim.LOFTING:
		season_name = "loft"
	elif sim.get_beat() == Sim.BUNKING:
		season_name = "bunk"
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
	if sim.get_beat() == Sim.FANIONING or (sim.is_over() and int(sim.get_presented()) > 0):
		salt_label.text = "Loose %d    stacked %d    guidon %d    presented %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_guidon_left(), sim.get_presented(),
		]
	elif sim.get_beat() == Sim.GUIDONING or (sim.is_over() and int(sim.get_saluted()) > 0):
		salt_label.text = "Loose %d    stacked %d    cornet %d    saluted %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_cornet_left(), sim.get_saluted(),
		]
	elif sim.get_beat() == Sim.CORNETING or (sim.is_over() and int(sim.get_dipped()) > 0):
		salt_label.text = "Loose %d    stacked %d    burgee %d    dipped %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_burgee_left(), sim.get_dipped(),
		]
	elif sim.get_beat() == Sim.BURGEEING or (sim.is_over() and int(sim.get_struck()) > 0):
		salt_label.text = "Loose %d    stacked %d    ensign %d    struck %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_ensign_left(), sim.get_struck(),
		]
	elif sim.get_beat() == Sim.ENSIGNING or (sim.is_over() and int(sim.get_broken()) > 0):
		salt_label.text = "Loose %d    stacked %d    jack %d    broken %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_jack_left(), sim.get_broken(),
		]
	elif sim.get_beat() == Sim.JACKING or (sim.is_over() and int(sim.get_shown()) > 0):
		salt_label.text = "Loose %d    stacked %d    standard %d    shown %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_standard_left(), sim.get_shown(),
		]
	elif sim.get_beat() == Sim.STANDARDING or (sim.is_over() and int(sim.get_carried()) > 0):
		salt_label.text = "Loose %d    stacked %d    pennant %d    carried %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_pennant_left(), sim.get_carried(),
		]
	elif sim.get_beat() == Sim.PENNANTING or (sim.is_over() and int(sim.get_flown()) > 0):
		salt_label.text = "Loose %d    stacked %d    banner %d    flown %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_banner_left(), sim.get_flown(),
		]
	elif sim.get_beat() == Sim.BANNERING or (sim.is_over() and int(sim.get_hoisted()) > 0):
		salt_label.text = "Loose %d    stacked %d    flag %d    hoisted %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_flag_left(), sim.get_hoisted(),
		]
	elif sim.get_beat() == Sim.FLAGGING or (sim.is_over() and int(sim.get_raised()) > 0):
		salt_label.text = "Loose %d    stacked %d    horn %d    raised %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_horn_left(), sim.get_raised(),
		]
	elif sim.get_beat() == Sim.HORNING or (sim.is_over() and int(sim.get_sounded()) > 0):
		salt_label.text = "Loose %d    stacked %d    bell %d    sounded %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_bell_left(), sim.get_sounded(),
		]
	elif sim.get_beat() == Sim.BELLING or (sim.is_over() and int(sim.get_rung()) > 0):
		salt_label.text = "Loose %d    stacked %d    lamp %d    rung %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_lamp_left(), sim.get_rung(),
		]
	elif sim.get_beat() == Sim.LAMPING or (sim.is_over() and int(sim.get_lit()) > 0):
		salt_label.text = "Loose %d    stacked %d    watch %d    lit %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_watch_left(), sim.get_lit(),
		]
	elif sim.get_beat() == Sim.WATCHING or (sim.is_over() and int(sim.get_stood()) > 0):
		salt_label.text = "Loose %d    stacked %d    relief %d    stood %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_relief_left(), sim.get_stood(),
		]
	elif sim.get_beat() == Sim.RELIEVING or (sim.is_over() and int(sim.get_posted()) > 0):
		salt_label.text = "Loose %d    stacked %d    wage %d    posted %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_wage_left(), sim.get_posted(),
		]
	elif sim.get_beat() == Sim.WAGING or (sim.is_over() and int(sim.get_paid()) > 0):
		salt_label.text = "Loose %d    stacked %d    unpaid %d    paid %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_gate_left(), sim.get_paid(),
		]
	elif sim.get_beat() == Sim.GATING or (sim.is_over() and int(sim.get_gated()) > 0):
		salt_label.text = "Loose %d    stacked %d    loft %d    gated %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_loft_left(), sim.get_gated(),
		]
	elif sim.get_beat() == Sim.LOFTING or (sim.is_over() and int(sim.get_lofted()) > 0):
		salt_label.text = "Loose %d    stacked %d    bunk %d    lofted %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_bunk_left(), sim.get_lofted(),
		]
	elif sim.get_beat() == Sim.BUNKING or (sim.is_over() and int(sim.get_hired()) > 0):
		salt_label.text = "Loose %d    stacked %d    hired %d    yard %d" % [
			sim.get_loose_salt(), sim.get_stacked_salt(), sim.get_hired(), sim.get_yard_left(),
		]
	elif sim.get_beat() == Sim.YARDING or (sim.is_over() and int(sim.get_banked()) > 0):
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
	if sim.get_beat() == Sim.FANIONING and not sim.is_over():
		season_label.text = "Guidon %d. Presented %d. Paint a fanion and workers present the hires." % [
			sim.get_guidon_left(), sim.get_presented(),
		]
	elif sim.is_over() and int(sim.get_presented()) > 0:
		season_label.text = "Presented %d on the fanion. Left %d on the guidon." % [
			sim.get_presented(), sim.get_guidon_left(),
		]
	elif sim.get_beat() == Sim.GUIDONING and not sim.is_over():
		season_label.text = "Cornet %d. Saluted %d. Paint a guidon and workers salute the hires." % [
			sim.get_cornet_left(), sim.get_saluted(),
		]
	elif sim.is_over() and int(sim.get_saluted()) > 0:
		season_label.text = "The crew was not presented. A fanion is where workers present them."
	elif sim.get_beat() == Sim.CORNETING and not sim.is_over():
		season_label.text = "Burgee %d. Dipped %d. Paint a cornet and workers dip the hires." % [
			sim.get_burgee_left(), sim.get_dipped(),
		]
	elif sim.is_over() and int(sim.get_dipped()) > 0:
		season_label.text = "The crew was not saluted. A guidon is where workers salute them."
	elif sim.get_beat() == Sim.BURGEEING and not sim.is_over():
		season_label.text = "Ensign %d. Struck %d. Paint a burgee and workers strike the hires." % [
			sim.get_ensign_left(), sim.get_struck(),
		]
	elif sim.is_over() and int(sim.get_struck()) > 0:
		season_label.text = "The crew was not dipped. A cornet is where workers dip them."
	elif sim.get_beat() == Sim.ENSIGNING and not sim.is_over():
		season_label.text = "Jack %d. Broken %d. Paint an ensign and workers break the hires." % [
			sim.get_jack_left(), sim.get_broken(),
		]
	elif sim.is_over() and int(sim.get_broken()) > 0:
		season_label.text = "The crew was not struck. A burgee is where workers strike them."
	elif sim.get_beat() == Sim.JACKING and not sim.is_over():
		season_label.text = "Standard %d. Shown %d. Paint a jack and workers show the hires." % [
			sim.get_standard_left(), sim.get_shown(),
		]
	elif sim.is_over() and int(sim.get_shown()) > 0:
		season_label.text = "The crew was not broken. An ensign is where workers break them."
	elif sim.get_beat() == Sim.STANDARDING and not sim.is_over():
		season_label.text = "Pennant %d. Carried %d. Paint a standard and workers carry the hires." % [
			sim.get_pennant_left(), sim.get_carried(),
		]
	elif sim.is_over() and int(sim.get_carried()) > 0:
		season_label.text = "The crew was not shown. A jack is where workers show them."
	elif sim.get_beat() == Sim.PENNANTING and not sim.is_over():
		season_label.text = "Banner %d. Flown %d. Paint a pennant and workers fly the hires." % [
			sim.get_banner_left(), sim.get_flown(),
		]
	elif sim.is_over() and int(sim.get_flown()) > 0:
		season_label.text = "The crew was not carried. A standard is where workers carry them."
	elif sim.get_beat() == Sim.BANNERING and not sim.is_over():
		season_label.text = "Flag %d. Hoisted %d. Paint a banner and workers hoist the hires." % [
			sim.get_flag_left(), sim.get_hoisted(),
		]
	elif sim.is_over() and int(sim.get_hoisted()) > 0:
		season_label.text = "The crew was not flown. A pennant is where workers fly them."
	elif sim.get_beat() == Sim.FLAGGING and not sim.is_over():
		season_label.text = "Horn %d. Raised %d. Paint a flag and workers raise the hires." % [
			sim.get_horn_left(), sim.get_raised(),
		]
	elif sim.is_over() and int(sim.get_raised()) > 0:
		season_label.text = "The crew was not hoisted. A banner is where workers hoist them."
	elif sim.get_beat() == Sim.HORNING and not sim.is_over():
		season_label.text = "Bell %d. Sounded %d. Paint a horn and workers sound the hires." % [
			sim.get_bell_left(), sim.get_sounded(),
		]
	elif sim.is_over() and int(sim.get_sounded()) > 0:
		season_label.text = "The crew was not raised. A flag is where workers raise them."
	elif sim.get_beat() == Sim.BELLING and not sim.is_over():
		season_label.text = "Lamp %d. Rung %d. Paint a bell and workers ring the hires." % [
			sim.get_lamp_left(), sim.get_rung(),
		]
	elif sim.is_over() and int(sim.get_rung()) > 0:
		season_label.text = "The crew was not sounded. A horn is where workers sound them."
	elif sim.get_beat() == Sim.LAMPING and not sim.is_over():
		season_label.text = "Watch %d. Lit %d. Paint a lamp and workers light the hires." % [
			sim.get_watch_left(), sim.get_lit(),
		]
	elif sim.is_over() and int(sim.get_lit()) > 0:
		season_label.text = "The crew was not rung. A bell is where workers ring them."
	elif sim.get_beat() == Sim.WATCHING and not sim.is_over():
		season_label.text = "Relief %d. Stood %d. Paint a watch and workers stand the hires." % [
			sim.get_relief_left(), sim.get_stood(),
		]
	elif sim.is_over() and int(sim.get_stood()) > 0:
		season_label.text = "The crew was not lit. A lamp is where workers light them."
	elif sim.get_beat() == Sim.RELIEVING and not sim.is_over():
		season_label.text = "Wage %d. Posted %d. Paint a relief and workers post the hires." % [
			sim.get_wage_left(), sim.get_posted(),
		]
	elif sim.is_over() and int(sim.get_posted()) > 0:
		season_label.text = "The crew was not stood. A watch is where workers stand them."
	elif sim.get_beat() == Sim.WAGING and not sim.is_over():
		season_label.text = "Through %d. Paid %d. Paint a wage and workers pay the hires." % [
			sim.get_gate_left(), sim.get_paid(),
		]
	elif sim.is_over() and int(sim.get_paid()) > 0:
		season_label.text = "The crew was not posted. A relief is where workers post them."
	elif sim.get_beat() == Sim.GATING and not sim.is_over():
		season_label.text = "Loft %d. Through %d. Paint a gate and workers let the hires through." % [
			sim.get_loft_left(), sim.get_gated(),
		]
	elif sim.is_over() and int(sim.get_gated()) > 0:
		season_label.text = "The crew was not paid. A wage is where workers pay them."
	elif sim.get_beat() == Sim.LOFTING and not sim.is_over():
		season_label.text = "Bunk %d. Lofted %d. Paint a loft and workers move the hires." % [
			sim.get_bunk_left(), sim.get_lofted(),
		]
	elif sim.is_over() and int(sim.get_lofted()) > 0:
		season_label.text = "The crew was not gated. A gate is where workers let them through."
	elif sim.get_beat() == Sim.BUNKING and not sim.is_over():
		season_label.text = "Yard %d. Hired %d. Paint a bunk and workers hire from the coins." % [
			sim.get_yard_left(), sim.get_hired(),
		]
	elif sim.is_over() and int(sim.get_hired()) > 0:
		season_label.text = "The hires were not lofted. A loft is where workers move them."
	elif sim.get_beat() == Sim.YARDING and not sim.is_over():
		season_label.text = "Coins %d. Banked %d. Paint a yard and workers bank the purse." % [
			sim.get_coins(), sim.get_banked(),
		]
	elif sim.is_over() and int(sim.get_banked()) > 0:
		season_label.text = "The purse was not hired. A bunk is where workers take it."
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
	elif sim.get_beat() == Sim.FANIONING:
		summary_label.text = "The guidon beat has ended. Paint a fanion. Workers present the hires who were already saluted."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.GUIDONING:
		summary_label.text = "The cornet beat has ended. Paint a guidon. Workers salute the hires who were already dipped."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.CORNETING:
		summary_label.text = "The burgee beat has ended. Paint a cornet. Workers dip the hires who were already struck."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.BURGEEING:
		summary_label.text = "The ensign beat has ended. Paint a burgee. Workers strike the hires who were already broken."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.ENSIGNING:
		summary_label.text = "The jack beat has ended. Paint an ensign. Workers break the hires who were already shown."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.JACKING:
		summary_label.text = "The standard beat has ended. Paint a jack. Workers show the hires who were already carried."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.STANDARDING:
		summary_label.text = "The pennant beat has ended. Paint a standard. Workers carry the hires who were already flown."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.PENNANTING:
		summary_label.text = "The banner beat has ended. Paint a pennant. Workers fly the hires who were already hoisted."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.BANNERING:
		summary_label.text = "The flag beat has ended. Paint a banner. Workers hoist the hires who were already raised."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.FLAGGING:
		summary_label.text = "The horn beat has ended. Paint a flag. Workers raise the hires who were already sounded."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.HORNING:
		summary_label.text = "The bell beat has ended. Paint a horn. Workers sound the hires who were already rung."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.BELLING:
		summary_label.text = "The lamp beat has ended. Paint a bell. Workers ring the hires who were already lit."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.LAMPING:
		summary_label.text = "The watch beat has ended. Paint a lamp. Workers light the hires who were already stood."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.WATCHING:
		summary_label.text = "The relief beat has ended. Paint a watch. Workers stand the hires who were already posted."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.RELIEVING:
		summary_label.text = "The wage beat has ended. Paint a relief. Workers post the hires who were already paid."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.WAGING:
		summary_label.text = "The gate beat has ended. Paint a wage. Workers pay the hires who already passed."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.GATING:
		summary_label.text = "The loft beat has ended. Paint a gate. Workers let the hires already recorded through."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.LOFTING:
		summary_label.text = "The bunk beat has ended. Paint a loft. Workers move the hires already recorded."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
	elif sim.get_beat() == Sim.BUNKING:
		summary_label.text = "The yard beat has ended. Paint a bunk. Workers hire from the coins already banked."
		summary_label.add_theme_color_override("font_color", Color("f0d7b0"))
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
	var cell := Vector2i(floori(local.x / CELL), floori(local.y / CELL) + Sim.GRID_NORTH)
	if cell.x < 0 or cell.y < Sim.GRID_NORTH or cell.x >= Sim.GRID_W or cell.y >= Sim.GRID_H:
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
			_set_mode(Sim.BUNK)
		KEY_B:
			_set_mode(Sim.LOFT)
		KEY_C:
			_set_mode(Sim.GATE)
		KEY_E:
			_set_mode(Sim.WAGE)
		KEY_F:
			_set_mode(Sim.RELIEF)
		KEY_G:
			_set_mode(Sim.WATCH)
		KEY_H:
			_set_mode(Sim.LAMP)
		KEY_I:
			_set_mode(Sim.BELL)
		KEY_J:
			_set_mode(Sim.HORN)
		KEY_K:
			_set_mode(Sim.FLAG)
		KEY_L:
			_set_mode(Sim.BANNER)
		KEY_M:
			_set_mode(Sim.PENNANT)
		KEY_N:
			_set_mode(Sim.STANDARD)
		KEY_O:
			_set_mode(Sim.JACK)
		KEY_P:
			_set_mode(Sim.ENSIGN)
		KEY_Q:
			_set_mode(Sim.BURGEE)
		KEY_T:
			_set_mode(Sim.CORNET)
		KEY_U:
			_set_mode(Sim.GUIDON)
		KEY_V:
			_set_mode(Sim.FANION)
		KEY_SPACE, KEY_ENTER, KEY_KP_ENTER:
			_paint_cell(cursor.x, cursor.y, current_mode)
		KEY_R:
			_restart()


func _move_cursor(dx: int, dy: int) -> void:
	cursor.x = clampi(cursor.x + dx, 0, Sim.GRID_W - 1)
	cursor.y = clampi(cursor.y + dy, Sim.GRID_NORTH, Sim.GRID_H - 1)


func _is_move_key(keycode: Key) -> bool:
	return keycode == KEY_UP or keycode == KEY_DOWN or keycode == KEY_LEFT or keycode == KEY_RIGHT or keycode == KEY_W or keycode == KEY_A or keycode == KEY_S or keycode == KEY_D


func _cell_rect(x: int, y: int) -> Rect2:
	var row := y - Sim.GRID_NORTH
	return Rect2(MAP_ORIGIN + Vector2(x * CELL, row * CELL), Vector2(CELL - 2.0, CELL - 2.0))


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
		Sim.BUNK:
			return Color("5c3b2e")
		Sim.LOFT:
			return Color("4a3b2a")
		Sim.GATE:
			return Color("3e4c59")
		Sim.WAGE:
			return Color("8a6a2f")
		Sim.RELIEF:
			return Color("2f6f78")
		Sim.WATCH:
			return Color("2c3a6e")
		Sim.LAMP:
			return Color("c47a2a")
		Sim.BELL:
			return Color("b8860b")
		Sim.HORN:
			return Color("8c3b2a")
		Sim.FLAG:
			return Color("8e2a32")
		Sim.BANNER:
			return Color("1e3f73")
		Sim.PENNANT:
			return Color("8a3b22")
		Sim.STANDARD:
			return Color("5c564c")
		Sim.JACK:
			return Color("2c2824")
		Sim.ENSIGN:
			return Color("c4b89a")
		Sim.BURGEE:
			return Color("6e5430")
		Sim.CORNET:
			return Color("cbb892")
		Sim.GUIDON:
			return Color("b9a36e")
		Sim.FANION:
			return Color("a89068")
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
		Sim.BUNK:
			return "Bunk"
		Sim.LOFT:
			return "Loft"
		Sim.GATE:
			return "Gate"
		Sim.WAGE:
			return "Wage"
		Sim.RELIEF:
			return "Relief"
		Sim.WATCH:
			return "Watch"
		Sim.LAMP:
			return "Lamp"
		Sim.BELL:
			return "Bell"
		Sim.HORN:
			return "Horn"
		Sim.FLAG:
			return "Flag"
		Sim.BANNER:
			return "Banner"
		Sim.PENNANT:
			return "Pennant"
		Sim.STANDARD:
			return "Standard"
		Sim.JACK:
			return "Jack"
		Sim.ENSIGN:
			return "Ensign"
		Sim.BURGEE:
			return "Burgee"
		Sim.CORNET:
			return "Cornet"
		Sim.GUIDON:
			return "Guidon"
		Sim.FANION:
			return "Fanion"
		_:
			return "Erase"
