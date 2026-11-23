extends Control

# South Lantern Quay, then North Glass Reach, then the Turning Basin, then the
# Painted Lock, then the West Return, then the Meeting Glass, then the Tide
# Mirror, then the Shutter, then the Stain, then the Vane, then the Well,
# then the Siphon, then the Sluice, then the Weir, then the Lintel,
# then the Mullion, then the Transom, then the Casement, then the Jamb,
# then the Astragal, then the Scotia, then the Torus, then the Ogee, then the Ovolo, then the Cavetto, then the Fillet.
# Pieces turn in place; a loose piece may also move
# between the sockets authored for that chart. Lock Chart asks the beam tracer
# whether every dock has its color and every hull is dark.

const Charts := preload("res://scripts/charts.gd")
const Tracer := preload("res://scripts/beam_tracer.gd")
const Hints := preload("res://scripts/hint.gd")
const Palette := preload("res://scripts/palette.gd")
const HarborBoard := preload("res://scripts/board.gd")
const TideClock := preload("res://scripts/tide_clock.gd")

static var persist_progress := true

const SAVE_PATH := "user://south_lantern_quay.cfg"
const HINTS_PER_CHART := 3

var charts: Array = []
var chart: Dictionary = {}
var state: Dictionary = {}
var chart_index := 0
var unlocked: Array[bool] = []
var solved: Array[bool] = []
var selected_id := ""
var hint_highlight := ""
var hints_left := HINTS_PER_CHART
var board_locked := false
var _laying_out := false

var board: HarborBoard
var teach_label: Label
var title_label: Label
var status_label: Label
var held_label: Label
var selected_label: Label
var tide_readout: Label
var hint_button: Button
var raise_button: Button
var lower_button: Button
var win_layer: Control
var win_body: Label
var win_next: Button
var chart_buttons: Array[Button] = []
var quay_grid: GridContainer
var reach_grid: GridContainer
var basin_grid: GridContainer
var paint_grid: GridContainer
var west_grid: GridContainer
var meet_grid: GridContainer
var tide_grid: GridContainer
var shutter_grid: GridContainer
var stain_grid: GridContainer
var vane_grid: GridContainer
var well_grid: GridContainer
var siphon_grid: GridContainer
var sluice_grid: GridContainer
var weir_grid: GridContainer
var lintel_grid: GridContainer
var mullion_grid: GridContainer
var transom_grid: GridContainer
var casement_grid: GridContainer
var jamb_grid: GridContainer
var astragal_grid: GridContainer
var scotia_grid: GridContainer
var torus_grid: GridContainer
var ogee_grid: GridContainer
var ovolo_grid: GridContainer
var cavetto_grid: GridContainer
var fillet_grid: GridContainer
var quay_book_button: Button
var reach_book_button: Button
var basin_book_button: Button
var paint_book_button: Button
var west_book_button: Button
var meet_book_button: Button
var tide_book_button: Button
var shutter_book_button: Button
var stain_book_button: Button
var vane_book_button: Button
var well_book_button: Button
var siphon_book_button: Button
var sluice_book_button: Button
var weir_book_button: Button
var lintel_book_button: Button
var mullion_book_button: Button
var transom_book_button: Button
var casement_book_button: Button
var jamb_book_button: Button
var astragal_book_button: Button
var scotia_book_button: Button
var torus_book_button: Button
var ogee_book_button: Button
var ovolo_book_button: Button
var cavetto_book_button: Button
var fillet_book_button: Button
var harbor_label: Label
var _book_place: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var tide_clock: TideClock
var _side: Panel

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	charts = Charts.all()
	unlocked.resize(charts.size())
	solved.resize(charts.size())
	unlocked[0] = true
	_build_ui()
	_load_progress()
	select_chart(0)
	resized.connect(_layout)
	_layout()

func _build_ui() -> void:
	var background := ColorRect.new()
	background.color = Palette.NIGHT
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	board = HarborBoard.new()
	board.z_index = 1
	add_child(board)

	_side = Panel.new()
	_side.z_index = 2
	_side.add_theme_stylebox_override("panel", _style(Palette.PANEL, Palette.PANEL_EDGE, 10))
	add_child(_side)

	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.offset_left = 14
	scroll.offset_top = 10
	scroll.offset_right = -12
	scroll.offset_bottom = -10
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	_side.add_child(scroll)

	var box := VBoxContainer.new()
	box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	box.add_theme_constant_override("separation", 3)
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	scroll.add_child(box)

	var harbor := _label("Harbor Glass", 26, Palette.LANTERN)
	harbor.autowrap_mode = TextServer.AUTOWRAP_OFF
	box.add_child(harbor)
	harbor_label = _label(Charts.HARBOR, 14, Palette.MUTED)
	harbor_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	box.add_child(harbor_label)

	var book_col := VBoxContainer.new()
	book_col.add_theme_constant_override("separation", 4)
	box.add_child(book_col)
	var book_row := HBoxContainer.new()
	book_row.add_theme_constant_override("separation", 6)
	var book_row_b := HBoxContainer.new()
	book_row_b.add_theme_constant_override("separation", 6)
	var book_row_c := HBoxContainer.new()
	book_row_c.add_theme_constant_override("separation", 6)
	var book_row_d := HBoxContainer.new()
	book_row_d.add_theme_constant_override("separation", 6)
	var book_row_e := HBoxContainer.new()
	book_row_e.add_theme_constant_override("separation", 6)
	var book_row_f := HBoxContainer.new()
	book_row_f.add_theme_constant_override("separation", 6)
	book_col.add_child(book_row)
	book_col.add_child(book_row_b)
	book_col.add_child(book_row_c)
	book_col.add_child(book_row_d)
	book_col.add_child(book_row_e)
	book_col.add_child(book_row_f)
	quay_book_button = _button("Quay")
	quay_book_button.tooltip_text = Charts.HARBOR
	quay_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quay_book_button.pressed.connect(_on_book_pressed.bind(0))
	reach_book_button = _button("Reach")
	reach_book_button.tooltip_text = Charts.REACH
	reach_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reach_book_button.pressed.connect(_on_book_pressed.bind(1))
	basin_book_button = _button("Basin")
	basin_book_button.tooltip_text = Charts.BASIN
	basin_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	basin_book_button.pressed.connect(_on_book_pressed.bind(2))
	paint_book_button = _button("Paint")
	paint_book_button.tooltip_text = Charts.PAINTED
	paint_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	paint_book_button.pressed.connect(_on_book_pressed.bind(3))
	west_book_button = _button("West")
	west_book_button.tooltip_text = Charts.WEST
	west_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	west_book_button.pressed.connect(_on_book_pressed.bind(4))
	meet_book_button = _button("Meet")
	meet_book_button.tooltip_text = Charts.MEET
	meet_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	meet_book_button.pressed.connect(_on_book_pressed.bind(5))
	tide_book_button = _button("Tide")
	tide_book_button.tooltip_text = Charts.TIDE
	tide_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tide_book_button.pressed.connect(_on_book_pressed.bind(6))
	shutter_book_button = _button("Shutter")
	shutter_book_button.tooltip_text = Charts.SHUTTER
	shutter_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	shutter_book_button.pressed.connect(_on_book_pressed.bind(7))
	stain_book_button = _button("Stain")
	stain_book_button.tooltip_text = Charts.STAIN
	stain_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stain_book_button.pressed.connect(_on_book_pressed.bind(8))
	vane_book_button = _button("Vane")
	vane_book_button.tooltip_text = Charts.VANE
	vane_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vane_book_button.pressed.connect(_on_book_pressed.bind(9))
	well_book_button = _button("Well")
	well_book_button.tooltip_text = Charts.WELL
	well_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	well_book_button.pressed.connect(_on_book_pressed.bind(10))
	siphon_book_button = _button("Siphon")
	siphon_book_button.tooltip_text = Charts.SIPHON
	siphon_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	siphon_book_button.pressed.connect(_on_book_pressed.bind(11))
	sluice_book_button = _button("Sluice")
	sluice_book_button.tooltip_text = Charts.SLUICE
	sluice_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sluice_book_button.pressed.connect(_on_book_pressed.bind(12))
	weir_book_button = _button("Weir")
	weir_book_button.tooltip_text = Charts.WEIR
	weir_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	weir_book_button.pressed.connect(_on_book_pressed.bind(13))
	lintel_book_button = _button("Lintel")
	lintel_book_button.tooltip_text = Charts.LINTEL
	lintel_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lintel_book_button.pressed.connect(_on_book_pressed.bind(14))
	mullion_book_button = _button("Mullion")
	mullion_book_button.tooltip_text = Charts.MULLION
	mullion_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mullion_book_button.pressed.connect(_on_book_pressed.bind(15))
	transom_book_button = _button("Transom")
	transom_book_button.tooltip_text = Charts.TRANSOM
	transom_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	transom_book_button.pressed.connect(_on_book_pressed.bind(16))
	casement_book_button = _button("Casement")
	casement_book_button.tooltip_text = Charts.CASEMENT
	casement_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	casement_book_button.pressed.connect(_on_book_pressed.bind(17))
	jamb_book_button = _button("Jamb")
	jamb_book_button.tooltip_text = Charts.JAMB
	jamb_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	jamb_book_button.pressed.connect(_on_book_pressed.bind(18))
	astragal_book_button = _button("Astragal")
	astragal_book_button.tooltip_text = Charts.ASTRAGAL
	astragal_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	astragal_book_button.pressed.connect(_on_book_pressed.bind(19))
	scotia_book_button = _button("Scotia")
	scotia_book_button.tooltip_text = Charts.SCOTIA
	scotia_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scotia_book_button.pressed.connect(_on_book_pressed.bind(20))
	torus_book_button = _button("Torus")
	torus_book_button.tooltip_text = Charts.TORUS
	torus_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	torus_book_button.pressed.connect(_on_book_pressed.bind(21))
	ogee_book_button = _button("Ogee")
	ogee_book_button.tooltip_text = Charts.OGEE
	ogee_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ogee_book_button.pressed.connect(_on_book_pressed.bind(22))
	ovolo_book_button = _button("Ovolo")
	ovolo_book_button.tooltip_text = Charts.OVOLO
	ovolo_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ovolo_book_button.pressed.connect(_on_book_pressed.bind(23))
	cavetto_book_button = _button("Cavetto")
	cavetto_book_button.tooltip_text = Charts.CAVETTO
	cavetto_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cavetto_book_button.pressed.connect(_on_book_pressed.bind(24))
	fillet_book_button = _button("Fillet")
	fillet_book_button.tooltip_text = Charts.FILLET
	fillet_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fillet_book_button.pressed.connect(_on_book_pressed.bind(25))
	book_row.add_child(quay_book_button)
	book_row.add_child(reach_book_button)
	book_row.add_child(basin_book_button)
	book_row.add_child(paint_book_button)
	book_row_b.add_child(west_book_button)
	book_row_b.add_child(meet_book_button)
	book_row_b.add_child(tide_book_button)
	book_row_b.add_child(shutter_book_button)
	book_row_c.add_child(stain_book_button)
	book_row_c.add_child(vane_book_button)
	book_row_c.add_child(well_book_button)
	book_row_c.add_child(siphon_book_button)
	book_row_d.add_child(sluice_book_button)
	book_row_d.add_child(weir_book_button)
	book_row_d.add_child(lintel_book_button)
	book_row_d.add_child(mullion_book_button)
	book_row_d.add_child(transom_book_button)
	book_row_d.add_child(casement_book_button)
	book_row_e.add_child(jamb_book_button)
	book_row_e.add_child(astragal_book_button)
	book_row_e.add_child(scotia_book_button)
	book_row_e.add_child(torus_book_button)
	book_row_e.add_child(ogee_book_button)
	book_row_e.add_child(ovolo_book_button)
	book_row_f.add_child(cavetto_book_button)
	book_row_f.add_child(fillet_book_button)
	for book_button in [quay_book_button, reach_book_button, basin_book_button, paint_book_button, west_book_button, meet_book_button, tide_book_button, shutter_book_button, stain_book_button, vane_book_button, well_book_button, siphon_book_button, sluice_book_button, weir_book_button, lintel_book_button, mullion_book_button, transom_book_button, casement_book_button, jamb_book_button, astragal_book_button, scotia_book_button, torus_book_button, ogee_book_button, ovolo_book_button, cavetto_book_button, fillet_book_button]:
		book_button.add_theme_font_size_override("font_size", 13)

	quay_grid = _chart_grid()
	reach_grid = _chart_grid()
	basin_grid = _chart_grid()
	paint_grid = _chart_grid()
	west_grid = _chart_grid()
	meet_grid = _chart_grid()
	tide_grid = _chart_grid()
	shutter_grid = _chart_grid()
	stain_grid = _chart_grid()
	vane_grid = _chart_grid()
	well_grid = _chart_grid()
	siphon_grid = _chart_grid()
	sluice_grid = _chart_grid()
	weir_grid = _chart_grid()
	lintel_grid = _chart_grid()
	mullion_grid = _chart_grid()
	transom_grid = _chart_grid()
	casement_grid = _chart_grid()
	jamb_grid = _chart_grid()
	astragal_grid = _chart_grid()
	scotia_grid = _chart_grid()
	torus_grid = _chart_grid()
	ogee_grid = _chart_grid()
	ovolo_grid = _chart_grid()
	cavetto_grid = _chart_grid()
	fillet_grid = _chart_grid()
	reach_grid.visible = false
	basin_grid.visible = false
	paint_grid.visible = false
	west_grid.visible = false
	meet_grid.visible = false
	tide_grid.visible = false
	shutter_grid.visible = false
	stain_grid.visible = false
	vane_grid.visible = false
	well_grid.visible = false
	siphon_grid.visible = false
	sluice_grid.visible = false
	weir_grid.visible = false
	lintel_grid.visible = false
	mullion_grid.visible = false
	transom_grid.visible = false
	casement_grid.visible = false
	jamb_grid.visible = false
	astragal_grid.visible = false
	scotia_grid.visible = false
	torus_grid.visible = false
	ogee_grid.visible = false
	ovolo_grid.visible = false
	cavetto_grid.visible = false
	fillet_grid.visible = false
	box.add_child(quay_grid)
	box.add_child(reach_grid)
	box.add_child(basin_grid)
	box.add_child(paint_grid)
	box.add_child(west_grid)
	box.add_child(meet_grid)
	box.add_child(tide_grid)
	box.add_child(shutter_grid)
	box.add_child(stain_grid)
	box.add_child(vane_grid)
	box.add_child(well_grid)
	box.add_child(siphon_grid)
	box.add_child(sluice_grid)
	box.add_child(weir_grid)
	box.add_child(lintel_grid)
	box.add_child(mullion_grid)
	box.add_child(transom_grid)
	box.add_child(casement_grid)
	box.add_child(jamb_grid)
	box.add_child(astragal_grid)
	box.add_child(scotia_grid)
	box.add_child(torus_grid)
	box.add_child(ogee_grid)
	box.add_child(ovolo_grid)
	box.add_child(cavetto_grid)
	box.add_child(fillet_grid)
	var bounds: Array = _book_bounds()
	for i in charts.size():
		var button := _button("Chart %d" % (i + 1))
		button.custom_minimum_size = Vector2(0, 26)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(_on_chart_pressed.bind(i))
		if i < int(bounds[1]):
			quay_grid.add_child(button)
		elif i < int(bounds[2]):
			reach_grid.add_child(button)
		elif i < int(bounds[3]):
			basin_grid.add_child(button)
		elif i < int(bounds[4]):
			paint_grid.add_child(button)
		elif i < int(bounds[5]):
			west_grid.add_child(button)
		elif i < int(bounds[6]):
			meet_grid.add_child(button)
		elif i < int(bounds[7]):
			tide_grid.add_child(button)
		elif i < int(bounds[8]):
			shutter_grid.add_child(button)
		elif i < int(bounds[9]):
			stain_grid.add_child(button)
		elif i < int(bounds[10]):
			vane_grid.add_child(button)
		elif i < int(bounds[11]):
			well_grid.add_child(button)
		elif i < int(bounds[12]):
			siphon_grid.add_child(button)
		elif i < int(bounds[13]):
			sluice_grid.add_child(button)
		elif i < int(bounds[14]):
			weir_grid.add_child(button)
		elif i < int(bounds[15]):
			lintel_grid.add_child(button)
		elif i < int(bounds[16]):
			mullion_grid.add_child(button)
		elif i < int(bounds[17]):
			transom_grid.add_child(button)
		elif i < int(bounds[18]):
			casement_grid.add_child(button)
		elif i < int(bounds[19]):
			jamb_grid.add_child(button)
		elif i < int(bounds[20]):
			astragal_grid.add_child(button)
		elif i < int(bounds[21]):
			scotia_grid.add_child(button)
		elif i < int(bounds[22]):
			torus_grid.add_child(button)
		elif i < int(bounds[23]):
			ogee_grid.add_child(button)
		elif i < int(bounds[24]):
			ovolo_grid.add_child(button)
		elif i < int(bounds[25]):
			cavetto_grid.add_child(button)
		else:
			fillet_grid.add_child(button)
		chart_buttons.append(button)

	title_label = _label("", 20, Palette.TEXT)
	box.add_child(title_label)
	teach_label = _label("", 14, Palette.TEXT)
	teach_label.custom_minimum_size = Vector2(360, 0)
	box.add_child(teach_label)
	selected_label = _label("", 14, Palette.SELECT)
	box.add_child(selected_label)

	tide_clock = TideClock.new()
	tide_clock.custom_minimum_size = Vector2(340, 56)
	box.add_child(tide_clock)
	tide_readout = _label("", 13, Palette.MUTED)
	box.add_child(tide_readout)

	var tide_row := HBoxContainer.new()
	tide_row.add_theme_constant_override("separation", 6)
	box.add_child(tide_row)
	raise_button = _button("Raise tide (T)")
	raise_button.pressed.connect(raise_tide)
	lower_button = _button("Lower (Shift+T)")
	lower_button.pressed.connect(lower_tide)
	tide_row.add_child(raise_button)
	tide_row.add_child(lower_button)

	var turn := _button("Turn (R)")
	turn.pressed.connect(rotate_selected)
	box.add_child(turn)
	var lock := _button("Lock Chart (Space)")
	lock.pressed.connect(try_lock)
	box.add_child(lock)
	hint_button = _button("Hint (H)")
	hint_button.pressed.connect(try_hint)
	box.add_child(hint_button)
	var restart := _button("Restart chart")
	restart.pressed.connect(restart_chart)
	box.add_child(restart)

	held_label = _label("", 15, Palette.GOOD)
	box.add_child(held_label)
	status_label = _label("", 14, Palette.TEXT)
	status_label.custom_minimum_size = Vector2(340, 0)
	box.add_child(status_label)

	var legend := _label("Warm beam, red, and blue. A lamp may already burn one color. One mirror can take two lamps. A tide mirror reflects only while its row is flooded, and lets the beam pass while that row is dry. A shutter stops a beam while its row is dry, and lets the beam pass straight through while that row is flooded. A stain recolors a beam to its own color and lets it pass straight through, on a dry row and under water. A vane turns a beam into its facing, and a head-on beam stops. Water shuts a vane the way it shuts a mirror. A well stops a beam while its row is dry. While that row is flooded, the beam leaves north and keeps its color. A well does not turn. A siphon stops a beam while its row is dry. While that row is flooded, the beam leaves north and swaps red with blue. White stays white. A siphon does not turn. A sluice stops a beam while its row is dry. While that row is flooded, the beam leaves along the sluice's facing and keeps its color. A weir stops a beam while its row is dry. While that row is flooded, the beam leaves along the weir's facing and swaps red with blue. White stays white. A lintel lets a beam pass straight through while its row is dry, and stops the beam while that row is flooded. A lintel does not turn. A mullion lets a north-south beam pass straight through while its row is dry, and an east-west beam stops before it enters. A flooded mullion stops every beam. A mullion does not turn. A transom lets an east-west beam pass straight through while its row is dry, and a north-south beam stops before it enters. A flooded transom stops every beam. A transom does not turn. A casement lets a beam pass straight through while its row is dry, but only in the direction it faces. Every other direction stops before the cell. A flooded casement stops every beam. The casement turns. A jamb passes both directions of the axis it faces while its row is dry, and the other axis stops before the cell. North and south open the north-south axis. East and west open the east-west axis. A flooded jamb stops every beam. The jamb turns. An astragal passes the direction it faces and the next clockwise direction while its row is dry. The other two directions stop before the cell. A flooded astragal stops every beam. The astragal turns. A scotia passes the direction it faces and the next counterclockwise direction while its row is dry. The other two directions stop before the cell. A flooded scotia stops every beam. The scotia turns. A torus passes the direction opposite its facing and the next clockwise direction while its row is dry. The other two directions stop before the cell. A flooded torus stops every beam. The torus turns. An ogee passes the direction opposite its facing and the next counterclockwise direction while its row is dry. The other two directions stop before the cell. A flooded ogee stops every beam. The ogee turns. An ovolo passes every direction except the one it faces while its row is dry. That facing stops before the cell. A flooded ovolo stops every beam. The ovolo turns. A cavetto passes every direction except the opposite of its facing while its row is dry. That opposite direction stops before the cell. A flooded cavetto stops every beam. The cavetto turns. A fillet passes only the opposite of its facing while its row is dry. The facing and both sides stop before the cell. A flooded fillet stops every beam. The fillet turns. Docks take only their marked color. Hulls stay dark. Water shuts the other glass it covers.", 13, Palette.MUTED)
	legend.custom_minimum_size = Vector2(360, 0)
	box.add_child(legend)
	var keys := _label("Arrows or Tab select. R turns. M moves a loose piece. Space locks. H hints. T raises tide, Shift+T lowers it. Backspace restarts.", 12, Palette.MUTED)
	keys.custom_minimum_size = Vector2(360, 0)
	box.add_child(keys)

	win_layer = Control.new()
	win_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
	win_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	win_layer.visible = false
	win_layer.z_index = 4
	add_child(win_layer)
	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.62)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	win_layer.add_child(dim)
	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	win_layer.add_child(center)
	var card := Panel.new()
	card.custom_minimum_size = Vector2(460, 220)
	card.add_theme_stylebox_override("panel", _style(Color("12202c"), Palette.LANTERN, 12))
	center.add_child(card)
	var win_box := VBoxContainer.new()
	win_box.set_anchors_preset(Control.PRESET_FULL_RECT)
	win_box.offset_left = 22
	win_box.offset_top = 18
	win_box.offset_right = -22
	win_box.offset_bottom = -18
	win_box.add_theme_constant_override("separation", 10)
	card.add_child(win_box)
	win_box.add_child(_label("The quay holds", 28, Palette.LANTERN_HOT))
	win_body = _label("", 16, Palette.TEXT)
	win_body.custom_minimum_size = Vector2(400, 48)
	win_box.add_child(win_body)
	var win_keys := _label("Space continues. Escape keeps this chart in view.", 13, Palette.MUTED)
	win_box.add_child(win_keys)
	var win_buttons := HBoxContainer.new()
	win_buttons.add_theme_constant_override("separation", 8)
	win_box.add_child(win_buttons)
	win_next = _button("Next chart")
	win_next.pressed.connect(_advance_from_win)
	win_buttons.add_child(win_next)
	var stay := _button("Stay")
	stay.pressed.connect(_stay_on_chart)
	win_buttons.add_child(stay)

func _layout() -> void:
	if _side == null or _laying_out:
		return
	_laying_out = true
	var vp := get_viewport_rect().size
	if vp.x < 200.0 or vp.y < 200.0:
		vp = Vector2(1280, 720)
	var side_w := 468.0
	var panel_left := vp.x - side_w - 16.0
	_side.position = Vector2(panel_left, 16.0)
	_side.size = Vector2(side_w, vp.y - 32.0)
	if not chart.is_empty():
		var left := 28.0
		var gap := 24.0
		var area_w := maxf(panel_left - left - gap, 160.0)
		var area_h := vp.y - 40.0
		var cols := int(chart["cols"])
		var rows := int(chart["rows"])
		var fit := minf(area_w / float(cols), area_h / float(rows))
		board.cell = clampf(fit, 36.0, 84.0)
		var grid_w := float(cols) * board.cell
		var grid_h := float(rows) * board.cell
		if grid_w > area_w:
			board.cell = area_w / float(cols)
			grid_w = float(cols) * board.cell
			grid_h = float(rows) * board.cell
		board.position = Vector2(left + (area_w - grid_w) * 0.5, 18.0 + maxf(area_h - grid_h, 0.0) * 0.5)
		_refresh_board()
	_laying_out = false

func select_chart(index: int) -> bool:
	if index < 0 or index >= charts.size():
		return false
	if not unlocked[index]:
		if status_label:
			status_label.text = "That chart is still locked."
		return false
	chart_index = index
	var book := _book_of(chart_index)
	_book_place[book] = chart_index
	chart = charts[index]
	state = Charts.make_state(chart, false)
	hints_left = HINTS_PER_CHART
	hint_highlight = ""
	board_locked = false
	selected_id = str(chart["pieces"][0]["id"])
	_hide_win()
	if status_label:
		status_label.text = ""
	_refresh()
	return true

func rotate_selected() -> void:
	if selected_id == "" or chart.is_empty():
		return
	var piece := Charts.piece_def(chart, selected_id)
	if piece.is_empty():
		return
	_resume_editing()
	if str(piece["kind"]) == "shutter":
		status_label.text = "A shutter opens with the tide. It does not turn."
		_refresh()
		return
	if str(piece["kind"]) == "stain":
		var stain_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("stain", stain_rot)
		status_label.text = "The stain swaps color. It does not turn."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "vane":
		var vane_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("vane", vane_rot)
		status_label.text = "The vane turns clockwise. It does not recolor."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "well":
		status_label.text = "A well follows the tide. It does not turn."
		_refresh()
		return
	if str(piece["kind"]) == "siphon":
		status_label.text = "A siphon follows the tide. It does not turn."
		_refresh()
		return
	if str(piece["kind"]) == "sluice":
		var sluice_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("sluice", sluice_rot)
		status_label.text = "The sluice turns clockwise. It keeps the color."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "weir":
		var weir_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("weir", weir_rot)
		status_label.text = "The weir turns clockwise. It swaps red and blue."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "lintel":
		status_label.text = "A lintel follows the tide. It does not turn."
		_refresh()
		return
	if str(piece["kind"]) == "mullion":
		status_label.text = "A mullion follows the tide. It does not turn."
		_refresh()
		return
	if str(piece["kind"]) == "transom":
		status_label.text = "A transom follows the tide. It does not turn."
		_refresh()
		return
	if str(piece["kind"]) == "casement":
		var casement_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("casement", casement_rot)
		status_label.text = "The casement turns clockwise. It passes only its facing."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "jamb":
		var jamb_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("jamb", jamb_rot)
		status_label.text = "The jamb turns clockwise. It passes both ways on its open axis."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "astragal":
		var astragal_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("astragal", astragal_rot)
		status_label.text = "The astragal turns clockwise. It passes its facing and the next direction."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "scotia":
		var scotia_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("scotia", scotia_rot)
		status_label.text = "The scotia turns clockwise. It passes its facing and the next counterclockwise direction."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "torus":
		var torus_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("torus", torus_rot)
		status_label.text = "The torus turns clockwise. It passes the opposite direction and the next clockwise direction."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "ogee":
		var ogee_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("ogee", ogee_rot)
		status_label.text = "The ogee turns clockwise. It passes the opposite direction and the next counterclockwise direction."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "ovolo":
		var ovolo_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("ovolo", ovolo_rot)
		status_label.text = "The ovolo turns clockwise. It passes every direction except its facing."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "cavetto":
		var cavetto_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("cavetto", cavetto_rot)
		status_label.text = "The cavetto turns clockwise. It passes every direction except the opposite of its facing."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "fillet":
		var fillet_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("fillet", fillet_rot)
		status_label.text = "The fillet turns clockwise. It passes only the opposite of its facing."
		_clear_hint_if_resolved()
		_refresh()
		return
	var cur := int(state["pieces"][selected_id]["rot"])
	state["pieces"][selected_id]["rot"] = Tracer.turn_rot(str(piece["kind"]), cur)
	_clear_hint_if_resolved()
	_refresh()

func move_selected_to(socket_id: String) -> bool:
	var piece := Charts.piece_def(chart, selected_id)
	if piece.is_empty() or not bool(piece["movable"]):
		status_label.text = "This piece turns in place."
		return false
	var found := false
	for raw in piece["sockets"]:
		var sock: Dictionary = raw
		if str(sock["id"]) == socket_id:
			found = true
			break
	if not found:
		return false
	_resume_editing()
	state["pieces"][selected_id]["socket"] = socket_id
	_clear_hint_if_resolved()
	_refresh()
	return true

func cycle_socket() -> void:
	var piece := Charts.piece_def(chart, selected_id)
	if piece.is_empty() or not bool(piece["movable"]):
		status_label.text = "This piece turns in place."
		return
	var sockets: Array = piece["sockets"]
	var cur := str(state["pieces"][selected_id]["socket"])
	var idx := 0
	for i in sockets.size():
		var sock: Dictionary = sockets[i]
		if str(sock["id"]) == cur:
			idx = i
			break
	var nxt: Dictionary = sockets[(idx + 1) % sockets.size()]
	move_selected_to(str(nxt["id"]))

func raise_tide() -> void:
	var phases: Array = chart["tide_phases"]
	if phases.size() <= 1:
		status_label.text = "The tide is fixed on this chart."
		return
	if int(state["tide_index"]) >= phases.size() - 1:
		return
	_resume_editing()
	state["tide_index"] = int(state["tide_index"]) + 1
	_clear_hint_if_resolved()
	_refresh()

func lower_tide() -> void:
	var phases: Array = chart["tide_phases"]
	if phases.size() <= 1:
		status_label.text = "The tide is fixed on this chart."
		return
	if int(state["tide_index"]) <= 0:
		return
	_resume_editing()
	state["tide_index"] = int(state["tide_index"]) - 1
	_clear_hint_if_resolved()
	_refresh()

func try_lock() -> void:
	if board_locked:
		_show_win()
		return
	var notes := Tracer.failure_notes(chart, state)
	if notes.is_empty():
		board_locked = true
		solved[chart_index] = true
		if chart_index + 1 < charts.size():
			unlocked[chart_index + 1] = true
		_save_progress()
		status_label.text = "Chart locked."
		_refresh()
		_show_win()
	else:
		status_label.text = " ".join(notes)
		_refresh_chrome()

func try_hint() -> void:
	if board_locked:
		status_label.text = "This chart is already locked."
		return
	var result := Hints.take_hint(chart, state, hints_left, hint_highlight)
	hints_left = int(result["hints_left"])
	hint_highlight = str(result["mark"])
	match str(result["kind"]):
		"match":
			status_label.text = "Nothing is out of place."
		"same":
			status_label.text = "That mark is still the one to study. Hints left: %d." % hints_left
		"empty":
			status_label.text = "No hints left on this chart."
		_:
			if hint_highlight == "tide":
				status_label.text = "The tide clock is marked. Hints left: %d." % hints_left
			else:
				status_label.text = "One piece is marked. Hints left: %d." % hints_left
	_refresh()

func restart_chart() -> void:
	state = Charts.make_state(chart, false)
	hints_left = HINTS_PER_CHART
	hint_highlight = ""
	board_locked = false
	selected_id = str(chart["pieces"][0]["id"])
	_hide_win()
	status_label.text = "Chart reset."
	_refresh()

func _resume_editing() -> void:
	if board_locked:
		board_locked = false

func _clear_hint_if_resolved() -> void:
	if hint_highlight == "":
		return
	if not Hints.wrong_pieces(chart, state).has(hint_highlight):
		hint_highlight = ""

func _refresh() -> void:
	if chart.is_empty():
		return
	_layout()
	_refresh_chrome()

func _refresh_board() -> void:
	if chart.is_empty() or board == null:
		return
	var traced := Tracer.trace(chart, state)
	board.present(chart, state, traced, selected_id, hint_highlight)

func _refresh_chrome() -> void:
	harbor_label.text = str(chart.get("harbor", Charts.HARBOR))
	title_label.text = "Chart %s  ·  %s" % [str(chart["id"]), str(chart["title"])]
	teach_label.text = str(chart["teach"])
	var piece := Charts.piece_def(chart, selected_id)
	selected_label.text = "Selected: %s" % str(piece.get("name", "none"))
	var flood := Tracer.flood_count(chart, state)
	var phase := _phase_name()
	var water := "Waterline is below the quay."
	if flood == 1:
		water = "Waterline covers the lowest row. Glass there is shut."
	elif flood > 1:
		water = "Waterline covers the lowest %d rows. Glass there is shut." % flood
	if _has_tide_mirror():
		if flood > 0:
			water += " A tide mirror under that water still reflects."
		else:
			water += " A dry tide mirror lets the beam pass."
	if _has_shutter():
		if flood > 0:
			water += " A shutter under that water lets the beam pass."
		else:
			water += " A dry shutter stops the beam."
	if _has_stain():
		water += " A stain recolors the beam on a dry row and under water."
	if _has_vane():
		water += " A vane turns a beam into its facing while its row is dry, and water shuts it."
	if _has_well():
		water += " A dry well stops the beam. A flooded well sends it north."
	if _has_siphon():
		water += " A dry siphon stops the beam. A flooded siphon sends it north and swaps red with blue."
	if _has_sluice():
		water += " A dry sluice stops the beam. A flooded sluice sends it along its facing."
	if _has_weir():
		water += " A dry weir stops the beam. A flooded weir sends it along its facing and swaps red with blue."
	if _has_lintel():
		water += " A dry lintel lets the beam pass straight through. A flooded lintel stops the beam."
	if _has_mullion():
		water += " A dry mullion lets a north-south beam pass and stops an east-west beam. A flooded mullion stops the beam."
	if _has_transom():
		water += " A dry transom lets an east-west beam pass and stops a north-south beam. A flooded transom stops the beam."
	if _has_casement():
		water += " A dry casement passes a beam only in the direction it faces. A flooded casement stops the beam."
	if _has_jamb():
		water += " A dry jamb passes both directions of its open axis. A flooded jamb stops the beam."
	if _has_astragal():
		water += " A dry astragal passes its facing and the next clockwise direction. A flooded astragal stops the beam."
	if _has_scotia():
		water += " A dry scotia passes its facing and the next counterclockwise direction. A flooded scotia stops the beam."
	if _has_torus():
		water += " A dry torus passes the opposite of its facing and the next clockwise direction. A flooded torus stops the beam."
	if _has_ogee():
		water += " A dry ogee passes the opposite of its facing and the next counterclockwise direction. A flooded ogee stops the beam."
	if _has_ovolo():
		water += " A dry ovolo passes every direction except the one it faces. A flooded ovolo stops the beam."
	if _has_cavetto():
		water += " A dry cavetto passes every direction except the opposite of its facing. A flooded cavetto stops the beam."
	if _has_fillet():
		water += " A dry fillet passes only the opposite of its facing. A flooded fillet stops the beam."
	tide_readout.text = "%s. %s" % [phase, water]
	var phases: Array = chart["tide_phases"]
	var multi := phases.size() > 1
	raise_button.visible = multi
	lower_button.visible = multi
	if multi:
		raise_button.disabled = int(state["tide_index"]) >= phases.size() - 1
		lower_button.disabled = int(state["tide_index"]) <= 0
	tide_clock.phases = phases
	tide_clock.phase_index = int(state["tide_index"])
	tide_clock.rows = int(chart["rows"])
	tide_clock.marked = hint_highlight == "tide"
	tide_clock.queue_redraw()
	hint_button.text = "Hint (H)  %d left" % hints_left
	held_label.visible = board_locked
	held_label.text = "This chart is locked." if board_locked else ""
	for i in chart_buttons.size():
		var button := chart_buttons[i]
		if not unlocked[i]:
			button.text = "Lock %d" % (i + 1)
			button.disabled = true
		else:
			button.disabled = false
			button.text = "Held %d" % (i + 1) if solved[i] else "Chart %d" % (i + 1)
		_paint_button(button, i == chart_index)
	var book := _book_of(chart_index)
	var bounds: Array = _book_bounds()
	quay_grid.visible = book == 0
	reach_grid.visible = book == 1
	basin_grid.visible = book == 2
	paint_grid.visible = book == 3
	west_grid.visible = book == 4
	meet_grid.visible = book == 5
	tide_grid.visible = book == 6
	shutter_grid.visible = book == 7
	stain_grid.visible = book == 8
	vane_grid.visible = book == 9
	well_grid.visible = book == 10
	siphon_grid.visible = book == 11
	sluice_grid.visible = book == 12
	weir_grid.visible = book == 13
	lintel_grid.visible = book == 14
	mullion_grid.visible = book == 15
	transom_grid.visible = book == 16
	casement_grid.visible = book == 17
	jamb_grid.visible = book == 18
	astragal_grid.visible = book == 19
	scotia_grid.visible = book == 20
	torus_grid.visible = book == 21
	ogee_grid.visible = book == 22
	ovolo_grid.visible = book == 23
	cavetto_grid.visible = book == 24
	fillet_grid.visible = book == 25
	reach_book_button.disabled = not unlocked[int(bounds[1])]
	basin_book_button.disabled = not unlocked[int(bounds[2])]
	paint_book_button.disabled = not unlocked[int(bounds[3])]
	west_book_button.disabled = not unlocked[int(bounds[4])]
	meet_book_button.disabled = not unlocked[int(bounds[5])]
	tide_book_button.disabled = not unlocked[int(bounds[6])]
	shutter_book_button.disabled = not unlocked[int(bounds[7])]
	stain_book_button.disabled = not unlocked[int(bounds[8])]
	vane_book_button.disabled = not unlocked[int(bounds[9])]
	well_book_button.disabled = not unlocked[int(bounds[10])]
	siphon_book_button.disabled = not unlocked[int(bounds[11])]
	sluice_book_button.disabled = not unlocked[int(bounds[12])]
	weir_book_button.disabled = not unlocked[int(bounds[13])]
	lintel_book_button.disabled = not unlocked[int(bounds[14])]
	mullion_book_button.disabled = not unlocked[int(bounds[15])]
	transom_book_button.disabled = not unlocked[int(bounds[16])]
	casement_book_button.disabled = not unlocked[int(bounds[17])]
	jamb_book_button.disabled = not unlocked[int(bounds[18])]
	astragal_book_button.disabled = not unlocked[int(bounds[19])]
	scotia_book_button.disabled = not unlocked[int(bounds[20])]
	torus_book_button.disabled = not unlocked[int(bounds[21])]
	ogee_book_button.disabled = not unlocked[int(bounds[22])]
	ovolo_book_button.disabled = not unlocked[int(bounds[23])]
	cavetto_book_button.disabled = not unlocked[int(bounds[24])]
	fillet_book_button.disabled = not unlocked[int(bounds[25])]
	_paint_button(quay_book_button, book == 0)
	_paint_button(reach_book_button, book == 1)
	_paint_button(basin_book_button, book == 2)
	_paint_button(paint_book_button, book == 3)
	_paint_button(west_book_button, book == 4)
	_paint_button(meet_book_button, book == 5)
	_paint_button(tide_book_button, book == 6)
	_paint_button(shutter_book_button, book == 7)
	_paint_button(stain_book_button, book == 8)
	_paint_button(vane_book_button, book == 9)
	_paint_button(well_book_button, book == 10)
	_paint_button(siphon_book_button, book == 11)
	_paint_button(sluice_book_button, book == 12)
	_paint_button(weir_book_button, book == 13)
	_paint_button(lintel_book_button, book == 14)
	_paint_button(mullion_book_button, book == 15)
	_paint_button(transom_book_button, book == 16)
	_paint_button(casement_book_button, book == 17)
	_paint_button(jamb_book_button, book == 18)
	_paint_button(astragal_book_button, book == 19)
	_paint_button(scotia_book_button, book == 20)
	_paint_button(torus_book_button, book == 21)
	_paint_button(ogee_book_button, book == 22)
	_paint_button(ovolo_book_button, book == 23)
	_paint_button(cavetto_book_button, book == 24)
	_paint_button(fillet_book_button, book == 25)

func _show_win() -> void:
	win_body.text = str(chart["win"])
	var has_next := chart_index + 1 < charts.size() and unlocked[chart_index + 1]
	win_next.visible = has_next
	win_next.text = "Next chart"
	win_layer.visible = true

func _hide_win() -> void:
	if win_layer:
		win_layer.visible = false

func _advance_from_win() -> void:
	var nxt := chart_index + 1
	_hide_win()
	if nxt < charts.size() and unlocked[nxt]:
		select_chart(nxt)
	else:
		status_label.text = "Chart locked. The glass holds."
		_refresh_chrome()

func _stay_on_chart() -> void:
	_hide_win()
	status_label.text = "Chart locked. The glass holds."
	_refresh_chrome()

func _on_chart_pressed(index: int) -> void:
	select_chart(index)


func _book_bounds() -> Array:
	var q := Charts.quay().size()
	var r := q + Charts.reach().size()
	var b := r + Charts.basin().size()
	var p := b + Charts.painted().size()
	var w := p + Charts.west().size()
	var m := w + Charts.meet().size()
	var t := m + Charts.tide().size()
	var s := t + Charts.shutter().size()
	var n := s + Charts.stain().size()
	var v := n + Charts.vane().size()
	var well := v + Charts.well().size()
	var siphon := well + Charts.siphon().size()
	var sluice := siphon + Charts.sluice().size()
	var weir := sluice + Charts.weir().size()
	var lintel := weir + Charts.lintel().size()
	var mullion := lintel + Charts.mullion().size()
	var transom := mullion + Charts.transom().size()
	var casement := transom + Charts.casement().size()
	var jamb := casement + Charts.jamb().size()
	var astragal := jamb + Charts.astragal().size()
	var scotia := astragal + Charts.scotia().size()
	var torus := scotia + Charts.torus().size()
	var ogee := torus + Charts.ogee().size()
	var ovolo := ogee + Charts.ovolo().size()
	var cavetto := ovolo + Charts.cavetto().size()
	return [0, q, r, b, p, w, m, t, s, n, v, well, siphon, sluice, weir, lintel, mullion, transom, casement, jamb, astragal, scotia, torus, ogee, ovolo, cavetto, charts.size()]


func _book_of(index: int) -> int:
	var bounds: Array = _book_bounds()
	if index >= int(bounds[25]):
		return 25
	if index >= int(bounds[24]):
		return 24
	if index >= int(bounds[23]):
		return 23
	if index >= int(bounds[22]):
		return 22
	if index >= int(bounds[21]):
		return 21
	if index >= int(bounds[20]):
		return 20
	if index >= int(bounds[19]):
		return 19
	if index >= int(bounds[18]):
		return 18
	if index >= int(bounds[17]):
		return 17
	if index >= int(bounds[16]):
		return 16
	if index >= int(bounds[15]):
		return 15
	if index >= int(bounds[14]):
		return 14
	if index >= int(bounds[13]):
		return 13
	if index >= int(bounds[12]):
		return 12
	if index >= int(bounds[11]):
		return 11
	if index >= int(bounds[10]):
		return 10
	if index >= int(bounds[9]):
		return 9
	if index >= int(bounds[8]):
		return 8
	if index >= int(bounds[7]):
		return 7
	if index >= int(bounds[6]):
		return 6
	if index >= int(bounds[5]):
		return 5
	if index >= int(bounds[4]):
		return 4
	if index >= int(bounds[3]):
		return 3
	if index >= int(bounds[2]):
		return 2
	if index >= int(bounds[1]):
		return 1
	return 0


func _on_book_pressed(book: int) -> void:
	var bounds: Array = _book_bounds()
	var here := _book_of(chart_index)
	if book == here:
		return
	var first := int(bounds[book])
	if book > 0 and not unlocked[first]:
		if book == 1:
			status_label.text = "The reach is still locked."
		elif book == 2:
			status_label.text = "The basin is still locked."
		elif book == 3:
			status_label.text = "The painted lock is still locked."
		elif book == 4:
			status_label.text = "The west return is still locked."
		elif book == 5:
			status_label.text = "The meeting glass is still locked."
		elif book == 6:
			status_label.text = "The tide mirror is still locked."
		elif book == 7:
			status_label.text = "The shutter is still locked."
		elif book == 8:
			status_label.text = "The stain is still locked."
		elif book == 9:
			status_label.text = "The vane is still locked."
		elif book == 10:
			status_label.text = "The well is still locked."
		elif book == 11:
			status_label.text = "The siphon is still locked."
		elif book == 12:
			status_label.text = "The sluice is still locked."
		elif book == 13:
			status_label.text = "The weir is still locked."
		elif book == 14:
			status_label.text = "The lintel is still locked."
		elif book == 15:
			status_label.text = "The mullion is still locked."
		elif book == 16:
			status_label.text = "The transom is still locked."
		elif book == 17:
			status_label.text = "The casement is still locked."
		elif book == 18:
			status_label.text = "The jamb is still locked."
		elif book == 19:
			status_label.text = "The astragal is still locked."
		elif book == 20:
			status_label.text = "The scotia is still locked."
		elif book == 21:
			status_label.text = "The torus is still locked."
		elif book == 22:
			status_label.text = "The ogee is still locked."
		elif book == 23:
			status_label.text = "The ovolo is still locked."
		elif book == 24:
			status_label.text = "The cavetto is still locked."
		else:
			status_label.text = "The fillet is still locked."
		return
	_book_place[here] = chart_index
	var last := int(bounds[book + 1])
	var target := _book_place[book]
	if target < first or target >= last or not unlocked[target]:
		target = first
		for i in range(first, last):
			if unlocked[i]:
				target = i
				break
	select_chart(target)


func _chart_grid() -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 6)
	grid.add_theme_constant_override("v_separation", 6)
	return grid


func _paint_button(button: Button, current: bool) -> void:
	var border := Palette.LANTERN if current else Palette.PANEL_EDGE
	var bg := Color("2c2618") if current else Color("1a2836")
	button.add_theme_stylebox_override("normal", _style(bg, border))
	button.add_theme_stylebox_override("hover", _style(bg.lightened(0.08), Palette.LANTERN))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.pressed and (mouse.button_index == MOUSE_BUTTON_LEFT or mouse.button_index == MOUSE_BUTTON_RIGHT):
			_on_board_click(mouse.position, mouse.button_index == MOUSE_BUTTON_RIGHT)
		return
	if event is InputEventKey:
		var key := event as InputEventKey
		if key.pressed and not key.echo:
			_on_key(key)

func _on_key(key: InputEventKey) -> void:
	var code := key.keycode
	if code == KEY_R:
		rotate_selected()
	elif code == KEY_M:
		cycle_socket()
	elif code == KEY_H:
		try_hint()
	elif code == KEY_T:
		if key.shift_pressed:
			lower_tide()
		else:
			raise_tide()
	elif code == KEY_BACKSPACE:
		restart_chart()
	elif code == KEY_ESCAPE:
		if win_layer.visible:
			_stay_on_chart()
	elif code == KEY_SPACE or code == KEY_ENTER or code == KEY_KP_ENTER:
		if win_layer.visible:
			_advance_from_win()
		else:
			try_lock()
	elif code == KEY_LEFT or code == KEY_UP or (code == KEY_TAB and key.shift_pressed):
		_cycle_selection(-1)
	elif code == KEY_RIGHT or code == KEY_DOWN or code == KEY_TAB:
		_cycle_selection(1)

func _on_board_click(pos: Vector2, turn_now: bool) -> void:
	if win_layer.visible or chart.is_empty():
		return
	var cell := board.cell_at_global(pos)
	if cell.x < 0:
		return
	var piece_id := _piece_at(cell)
	if piece_id != "":
		if turn_now or piece_id == selected_id:
			selected_id = piece_id
			rotate_selected()
		else:
			selected_id = piece_id
			_refresh()
		return
	var sock := _socket_at(cell)
	if sock != "":
		move_selected_to(sock)
		return
	if _fixture_at(cell):
		status_label.text = "That glass is set in the stone."

func _piece_at(cell: Vector2i) -> String:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		var id := str(piece["id"])
		if Charts.piece_cell(chart, state, id) == cell:
			return id
	return ""

func _socket_at(cell: Vector2i) -> String:
	var piece := Charts.piece_def(chart, selected_id)
	if piece.is_empty() or not bool(piece["movable"]):
		return ""
	for raw in piece["sockets"]:
		var sock: Dictionary = raw
		if Vector2i(int(sock["x"]), int(sock["y"])) == cell:
			return str(sock["id"])
	return ""

func _fixture_at(cell: Vector2i) -> bool:
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if Vector2i(int(fix["x"]), int(fix["y"])) == cell:
			return true
	return false

func _cycle_selection(step: int) -> void:
	var ids: Array[String] = []
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		ids.append(str(piece["id"]))
	if ids.is_empty():
		return
	var idx := ids.find(selected_id)
	if idx < 0:
		idx = 0
	else:
		idx = posmod(idx + step, ids.size())
	selected_id = ids[idx]
	_refresh()

func _load_progress() -> void:
	if not persist_progress:
		return
	var file := ConfigFile.new()
	if file.load(SAVE_PATH) != OK:
		return
	for i in charts.size():
		solved[i] = bool(file.get_value("progress", "solved_%d" % i, false))
		unlocked[i] = bool(file.get_value("progress", "unlocked_%d" % i, i == 0))
	unlocked[0] = true
	for i in range(charts.size() - 1):
		if solved[i]:
			unlocked[i + 1] = true

func _save_progress() -> void:
	if not persist_progress:
		return
	var file := ConfigFile.new()
	for i in charts.size():
		file.set_value("progress", "solved_%d" % i, solved[i])
		file.set_value("progress", "unlocked_%d" % i, unlocked[i])
	file.save(SAVE_PATH)

func _has_fillet() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "fillet":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "fillet":
			return true
	return false

func _has_cavetto() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "cavetto":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "cavetto":
			return true
	return false

func _has_ovolo() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "ovolo":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "ovolo":
			return true
	return false

func _has_ogee() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "ogee":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "ogee":
			return true
	return false

func _has_torus() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "torus":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "torus":
			return true
	return false

func _has_scotia() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "scotia":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "scotia":
			return true
	return false

func _has_astragal() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "astragal":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "astragal":
			return true
	return false

func _has_jamb() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "jamb":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "jamb":
			return true
	return false

func _has_casement() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "casement":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "casement":
			return true
	return false

func _has_transom() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "transom":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "transom":
			return true
	return false

func _has_mullion() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "mullion":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "mullion":
			return true
	return false

func _has_lintel() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "lintel":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "lintel":
			return true
	return false

func _has_weir() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "weir":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "weir":
			return true
	return false

func _has_sluice() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "sluice":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "sluice":
			return true
	return false

func _has_siphon() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "siphon":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "siphon":
			return true
	return false

func _has_well() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "well":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "well":
			return true
	return false

func _has_vane() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "vane":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "vane":
			return true
	return false

func _has_stain() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "stain":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "stain":
			return true
	return false

func _has_shutter() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "shutter":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "shutter":
			return true
	return false

func _has_tide_mirror() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "tide_mirror":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "tide_mirror":
			return true
	return false

func _phase_name() -> String:
	var phases: Array = chart["tide_phases"]
	if phases.size() <= 1:
		return "Tide holding"
	var index := int(state["tide_index"])
	if index <= 0:
		return "Low water"
	if index >= phases.size() - 1:
		return "High water"
	return "Mid water"

func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label

func _button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_color_override("font_color", Palette.TEXT)
	button.add_theme_color_override("font_hover_color", Palette.LANTERN_HOT)
	button.add_theme_color_override("font_pressed_color", Palette.LANTERN)
	button.add_theme_color_override("font_disabled_color", Color("667484"))
	button.add_theme_stylebox_override("normal", _style(Color("1a2836"), Palette.PANEL_EDGE))
	button.add_theme_stylebox_override("hover", _style(Color("243848"), Palette.LANTERN))
	button.add_theme_stylebox_override("pressed", _style(Color("101820"), Palette.LANTERN))
	button.add_theme_stylebox_override("disabled", _style(Color("12181e"), Color("243038")))
	button.custom_minimum_size = Vector2(0, 26)
	return button

func _style(bg: Color, border: Color, radius: int = 6) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(1)
	box.set_corner_radius_all(radius)
	box.content_margin_left = 8
	box.content_margin_right = 8
	box.content_margin_top = 4
	box.content_margin_bottom = 4
	return box
