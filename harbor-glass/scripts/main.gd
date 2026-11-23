extends Control

# South Lantern Quay, then North Glass Reach, then the Turning Basin, then the
# Painted Lock, then the West Return, then the Meeting Glass, then the Tide
# Mirror, then the Shutter, then the Stain, then the Vane, then the Well,
# then the Siphon, then the Sluice, then the Weir, then the Lintel,
# then the Mullion, then the Transom, then the Casement, then the Jamb,
# then the Astragal, then the Scotia, then the Torus, then the Ogee, then the Ovolo, then the Cavetto, then the Fillet, then the Corona, then the Bead, then the Quirk, then the Cyma, then the Fascia, then the Soffit, then the Drip, then the Beak, then the Hood, then the Throat, then the Larmier, then the Cill, then the Threshold, then the Impost, then the Architrave, then the Archivolt, then the Abacus, then the Rebate, then the Echinus, then the Annulet, then the Listel, then the Necking, then the Taenia, then the Baguette, then the Reglet, then the Billet, then the Reed, then the Staff.
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
var corona_grid: GridContainer
var bead_grid: GridContainer
var quirk_grid: GridContainer
var cyma_grid: GridContainer
var fascia_grid: GridContainer
var soffit_grid: GridContainer
var drip_grid: GridContainer
var beak_grid: GridContainer
var hood_grid: GridContainer
var throat_grid: GridContainer
var larmier_grid: GridContainer
var cill_grid: GridContainer
var threshold_grid: GridContainer
var impost_grid: GridContainer
var architrave_grid: GridContainer
var archivolt_grid: GridContainer
var abacus_grid: GridContainer
var rebate_grid: GridContainer
var echinus_grid: GridContainer
var annulet_grid: GridContainer
var listel_grid: GridContainer
var necking_grid: GridContainer
var taenia_grid: GridContainer
var baguette_grid: GridContainer
var reglet_grid: GridContainer
var billet_grid: GridContainer
var reed_grid: GridContainer
var staff_grid: GridContainer
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
var corona_book_button: Button
var bead_book_button: Button
var quirk_book_button: Button
var cyma_book_button: Button
var fascia_book_button: Button
var soffit_book_button: Button
var drip_book_button: Button
var beak_book_button: Button
var hood_book_button: Button
var throat_book_button: Button
var larmier_book_button: Button
var cill_book_button: Button
var threshold_book_button: Button
var impost_book_button: Button
var architrave_book_button: Button
var archivolt_book_button: Button
var abacus_book_button: Button
var rebate_book_button: Button
var echinus_book_button: Button
var annulet_book_button: Button
var listel_book_button: Button
var necking_book_button: Button
var taenia_book_button: Button
var baguette_book_button: Button
var reglet_book_button: Button
var billet_book_button: Button
var reed_book_button: Button
var staff_book_button: Button
var harbor_label: Label
var _book_place: Array[int] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
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
	var book_row_g := HBoxContainer.new()
	book_row_g.add_theme_constant_override("separation", 6)
	book_col.add_child(book_row)
	book_col.add_child(book_row_b)
	book_col.add_child(book_row_c)
	book_col.add_child(book_row_d)
	book_col.add_child(book_row_e)
	book_col.add_child(book_row_f)
	book_col.add_child(book_row_g)
	var book_row_h := HBoxContainer.new()
	book_row_h.add_theme_constant_override("separation", 6)
	book_col.add_child(book_row_h)
	var book_row_i := HBoxContainer.new()
	book_row_i.add_theme_constant_override("separation", 6)
	book_col.add_child(book_row_i)
	var book_row_j := HBoxContainer.new()
	book_row_j.add_theme_constant_override("separation", 6)
	book_col.add_child(book_row_j)
	var book_row_k := HBoxContainer.new()
	book_row_k.add_theme_constant_override("separation", 6)
	book_col.add_child(book_row_k)
	var book_row_l := HBoxContainer.new()
	book_row_l.add_theme_constant_override("separation", 6)
	book_col.add_child(book_row_l)
	var book_row_m := HBoxContainer.new()
	book_row_m.add_theme_constant_override("separation", 6)
	book_col.add_child(book_row_m)
	var book_row_n := HBoxContainer.new()
	book_row_n.add_theme_constant_override("separation", 6)
	book_col.add_child(book_row_n)
	var book_row_o := HBoxContainer.new()
	book_row_o.add_theme_constant_override("separation", 6)
	book_col.add_child(book_row_o)
	var book_row_p := HBoxContainer.new()
	book_row_p.add_theme_constant_override("separation", 6)
	book_col.add_child(book_row_p)
	var book_row_q := HBoxContainer.new()
	book_row_q.add_theme_constant_override("separation", 6)
	book_col.add_child(book_row_q)
	var book_row_r := HBoxContainer.new()
	book_row_r.add_theme_constant_override("separation", 6)
	book_col.add_child(book_row_r)
	var book_row_s := HBoxContainer.new()
	book_row_s.add_theme_constant_override("separation", 6)
	book_col.add_child(book_row_s)
	var book_row_t := HBoxContainer.new()
	book_row_t.add_theme_constant_override("separation", 6)
	book_col.add_child(book_row_t)
	var book_row_u := HBoxContainer.new()
	book_row_u.add_theme_constant_override("separation", 6)
	book_col.add_child(book_row_u)
	var book_row_v := HBoxContainer.new()
	book_row_v.add_theme_constant_override("separation", 6)
	book_col.add_child(book_row_v)
	var book_row_w := HBoxContainer.new()
	book_row_w.add_theme_constant_override("separation", 6)
	book_col.add_child(book_row_w)
	var book_row_x := HBoxContainer.new()
	book_row_x.add_theme_constant_override("separation", 6)
	book_col.add_child(book_row_x)
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
	corona_book_button = _button("Corona")
	corona_book_button.tooltip_text = Charts.CORONA
	corona_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	corona_book_button.pressed.connect(_on_book_pressed.bind(26))
	bead_book_button = _button("Bead")
	bead_book_button.tooltip_text = Charts.BEAD
	bead_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bead_book_button.pressed.connect(_on_book_pressed.bind(27))
	quirk_book_button = _button("Quirk")
	quirk_book_button.tooltip_text = Charts.QUIRK
	quirk_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	quirk_book_button.pressed.connect(_on_book_pressed.bind(28))
	cyma_book_button = _button("Cyma")
	cyma_book_button.tooltip_text = Charts.CYMA
	cyma_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cyma_book_button.pressed.connect(_on_book_pressed.bind(29))
	fascia_book_button = _button("Fascia")
	fascia_book_button.tooltip_text = Charts.FASCIA
	fascia_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fascia_book_button.pressed.connect(_on_book_pressed.bind(30))
	soffit_book_button = _button("Soffit")
	soffit_book_button.tooltip_text = Charts.SOFFIT
	soffit_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	soffit_book_button.pressed.connect(_on_book_pressed.bind(31))
	drip_book_button = _button("Drip")
	drip_book_button.tooltip_text = Charts.DRIP
	drip_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	drip_book_button.pressed.connect(_on_book_pressed.bind(32))
	beak_book_button = _button("Beak")
	beak_book_button.tooltip_text = Charts.BEAK
	beak_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	beak_book_button.pressed.connect(_on_book_pressed.bind(33))
	hood_book_button = _button("Hood")
	hood_book_button.tooltip_text = Charts.HOOD
	hood_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hood_book_button.pressed.connect(_on_book_pressed.bind(34))
	throat_book_button = _button("Throat")
	throat_book_button.tooltip_text = Charts.THROAT
	throat_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	throat_book_button.pressed.connect(_on_book_pressed.bind(35))
	larmier_book_button = _button("Larmier")
	larmier_book_button.tooltip_text = Charts.LARMIER
	larmier_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	larmier_book_button.pressed.connect(_on_book_pressed.bind(36))
	cill_book_button = _button("Cill")
	cill_book_button.tooltip_text = Charts.CILL
	cill_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cill_book_button.pressed.connect(_on_book_pressed.bind(37))
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
	book_row_f.add_child(corona_book_button)
	book_row_g.add_child(bead_book_button)
	book_row_g.add_child(quirk_book_button)
	book_row_g.add_child(cyma_book_button)
	book_row_g.add_child(fascia_book_button)
	book_row_h.add_child(soffit_book_button)
	book_row_h.add_child(drip_book_button)
	book_row_h.add_child(beak_book_button)
	book_row_i.add_child(hood_book_button)
	book_row_i.add_child(throat_book_button)
	book_row_i.add_child(larmier_book_button)
	book_row_i.add_child(cill_book_button)
	threshold_book_button = _button("Threshold")
	threshold_book_button.tooltip_text = Charts.THRESHOLD
	threshold_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	threshold_book_button.pressed.connect(_on_book_pressed.bind(38))
	book_row_j.add_child(threshold_book_button)
	impost_book_button = _button("Impost")
	impost_book_button.tooltip_text = Charts.IMPOST
	impost_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	impost_book_button.pressed.connect(_on_book_pressed.bind(39))
	book_row_j.add_child(impost_book_button)
	architrave_book_button = _button("Architrave")
	architrave_book_button.tooltip_text = Charts.ARCHITRAVE
	architrave_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	architrave_book_button.pressed.connect(_on_book_pressed.bind(40))
	book_row_k.add_child(architrave_book_button)
	archivolt_book_button = _button("Archivolt")
	archivolt_book_button.tooltip_text = Charts.ARCHIVOLT
	archivolt_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	archivolt_book_button.pressed.connect(_on_book_pressed.bind(41))
	book_row_l.add_child(archivolt_book_button)
	abacus_book_button = _button("Abacus")
	abacus_book_button.tooltip_text = Charts.ABACUS
	abacus_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	abacus_book_button.pressed.connect(_on_book_pressed.bind(42))
	book_row_m.add_child(abacus_book_button)
	rebate_book_button = _button("Rebate")
	rebate_book_button.tooltip_text = Charts.REBATE
	rebate_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rebate_book_button.pressed.connect(_on_book_pressed.bind(43))
	book_row_n.add_child(rebate_book_button)
	echinus_book_button = _button("Echinus")
	echinus_book_button.tooltip_text = Charts.ECHINUS
	echinus_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	echinus_book_button.pressed.connect(_on_book_pressed.bind(44))
	book_row_o.add_child(echinus_book_button)
	annulet_book_button = _button("Annulet")
	annulet_book_button.tooltip_text = Charts.ANNULET
	annulet_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	annulet_book_button.pressed.connect(_on_book_pressed.bind(45))
	book_row_p.add_child(annulet_book_button)
	listel_book_button = _button("Listel")
	listel_book_button.tooltip_text = Charts.LISTEL
	listel_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	listel_book_button.pressed.connect(_on_book_pressed.bind(46))
	book_row_q.add_child(listel_book_button)
	necking_book_button = _button("Necking")
	necking_book_button.tooltip_text = Charts.NECKING
	necking_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	necking_book_button.pressed.connect(_on_book_pressed.bind(47))
	book_row_r.add_child(necking_book_button)
	taenia_book_button = _button("Taenia")
	taenia_book_button.tooltip_text = Charts.TAENIA
	taenia_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	taenia_book_button.pressed.connect(_on_book_pressed.bind(48))
	book_row_s.add_child(taenia_book_button)
	baguette_book_button = _button("Baguette")
	baguette_book_button.tooltip_text = Charts.BAGUETTE
	baguette_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	baguette_book_button.pressed.connect(_on_book_pressed.bind(49))
	book_row_t.add_child(baguette_book_button)
	reglet_book_button = _button("Reglet")
	reglet_book_button.tooltip_text = Charts.REGLET
	reglet_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reglet_book_button.pressed.connect(_on_book_pressed.bind(50))
	book_row_u.add_child(reglet_book_button)
	billet_book_button = _button("Billet")
	billet_book_button.tooltip_text = Charts.BILLET
	billet_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	billet_book_button.pressed.connect(_on_book_pressed.bind(51))
	book_row_v.add_child(billet_book_button)
	reed_book_button = _button("Reed")
	reed_book_button.tooltip_text = Charts.REED
	reed_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reed_book_button.pressed.connect(_on_book_pressed.bind(52))
	book_row_w.add_child(reed_book_button)
	staff_book_button = _button("Staff")
	staff_book_button.tooltip_text = Charts.STAFF
	staff_book_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	staff_book_button.pressed.connect(_on_book_pressed.bind(53))
	book_row_x.add_child(staff_book_button)
	for book_button in [quay_book_button, reach_book_button, basin_book_button, paint_book_button, west_book_button, meet_book_button, tide_book_button, shutter_book_button, stain_book_button, vane_book_button, well_book_button, siphon_book_button, sluice_book_button, weir_book_button, lintel_book_button, mullion_book_button, transom_book_button, casement_book_button, jamb_book_button, astragal_book_button, scotia_book_button, torus_book_button, ogee_book_button, ovolo_book_button, cavetto_book_button, fillet_book_button, corona_book_button, bead_book_button, quirk_book_button, cyma_book_button, fascia_book_button, soffit_book_button, drip_book_button, beak_book_button, hood_book_button, throat_book_button, larmier_book_button, cill_book_button, threshold_book_button, impost_book_button, architrave_book_button, archivolt_book_button, abacus_book_button, rebate_book_button, echinus_book_button, annulet_book_button, listel_book_button, necking_book_button, taenia_book_button, baguette_book_button, reglet_book_button, billet_book_button, reed_book_button, staff_book_button]:
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
	corona_grid = _chart_grid()
	bead_grid = _chart_grid()
	quirk_grid = _chart_grid()
	cyma_grid = _chart_grid()
	fascia_grid = _chart_grid()
	soffit_grid = _chart_grid()
	drip_grid = _chart_grid()
	beak_grid = _chart_grid()
	hood_grid = _chart_grid()
	throat_grid = _chart_grid()
	larmier_grid = _chart_grid()
	cill_grid = _chart_grid()
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
	corona_grid.visible = false
	bead_grid.visible = false
	quirk_grid.visible = false
	cyma_grid.visible = false
	fascia_grid.visible = false
	soffit_grid.visible = false
	drip_grid.visible = false
	beak_grid.visible = false
	hood_grid.visible = false
	throat_grid.visible = false
	larmier_grid.visible = false
	cill_grid.visible = false
	threshold_grid = _chart_grid()
	threshold_grid.visible = false
	impost_grid = _chart_grid()
	impost_grid.visible = false
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
	box.add_child(corona_grid)
	box.add_child(bead_grid)
	box.add_child(quirk_grid)
	box.add_child(cyma_grid)
	box.add_child(fascia_grid)
	box.add_child(soffit_grid)
	box.add_child(drip_grid)
	box.add_child(beak_grid)
	box.add_child(hood_grid)
	box.add_child(throat_grid)
	box.add_child(larmier_grid)
	box.add_child(cill_grid)
	box.add_child(threshold_grid)
	box.add_child(impost_grid)
	architrave_grid = _chart_grid()
	architrave_grid.visible = false
	box.add_child(architrave_grid)
	archivolt_grid = _chart_grid()
	archivolt_grid.visible = false
	box.add_child(archivolt_grid)
	abacus_grid = _chart_grid()
	abacus_grid.visible = false
	box.add_child(abacus_grid)
	rebate_grid = _chart_grid()
	rebate_grid.visible = false
	box.add_child(rebate_grid)
	echinus_grid = _chart_grid()
	echinus_grid.visible = false
	box.add_child(echinus_grid)
	annulet_grid = _chart_grid()
	annulet_grid.visible = false
	box.add_child(annulet_grid)
	listel_grid = _chart_grid()
	listel_grid.visible = false
	box.add_child(listel_grid)
	necking_grid = _chart_grid()
	necking_grid.visible = false
	box.add_child(necking_grid)
	taenia_grid = _chart_grid()
	taenia_grid.visible = false
	box.add_child(taenia_grid)
	baguette_grid = _chart_grid()
	baguette_grid.visible = false
	box.add_child(baguette_grid)
	reglet_grid = _chart_grid()
	reglet_grid.visible = false
	box.add_child(reglet_grid)
	billet_grid = _chart_grid()
	billet_grid.visible = false
	box.add_child(billet_grid)
	reed_grid = _chart_grid()
	reed_grid.visible = false
	box.add_child(reed_grid)
	staff_grid = _chart_grid()
	staff_grid.visible = false
	box.add_child(staff_grid)
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
		elif i < int(bounds[26]):
			fillet_grid.add_child(button)
		elif i < int(bounds[27]):
			corona_grid.add_child(button)
		elif i < int(bounds[28]):
			bead_grid.add_child(button)
		elif i < int(bounds[29]):
			quirk_grid.add_child(button)
		elif i < int(bounds[30]):
			cyma_grid.add_child(button)
		elif i < int(bounds[31]):
			fascia_grid.add_child(button)
		elif i < int(bounds[32]):
			soffit_grid.add_child(button)
		elif i < int(bounds[33]):
			drip_grid.add_child(button)
		elif i < int(bounds[34]):
			beak_grid.add_child(button)
		elif i < int(bounds[35]):
			hood_grid.add_child(button)
		elif i < int(bounds[36]):
			throat_grid.add_child(button)
		elif i < int(bounds[37]):
			larmier_grid.add_child(button)
		elif i < int(bounds[38]):
			cill_grid.add_child(button)
		elif i < int(bounds[39]):
			threshold_grid.add_child(button)
		elif i < int(bounds[40]):
			impost_grid.add_child(button)
		elif i < int(bounds[41]):
			architrave_grid.add_child(button)
		elif i < int(bounds[42]):
			archivolt_grid.add_child(button)
		elif i < int(bounds[43]):
			abacus_grid.add_child(button)
		elif i < int(bounds[44]):
			rebate_grid.add_child(button)
		elif i < int(bounds[45]):
			echinus_grid.add_child(button)
		elif i < int(bounds[46]):
			annulet_grid.add_child(button)
		elif i < int(bounds[47]):
			listel_grid.add_child(button)
		elif i < int(bounds[48]):
			necking_grid.add_child(button)
		elif i < int(bounds[49]):
			taenia_grid.add_child(button)
		elif i < int(bounds[50]):
			baguette_grid.add_child(button)
		elif i < int(bounds[51]):
			reglet_grid.add_child(button)
		elif i < int(bounds[52]):
			billet_grid.add_child(button)
		elif i < int(bounds[53]):
			reed_grid.add_child(button)
		else:
			staff_grid.add_child(button)
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

	var legend := _label("Warm beam, red, and blue. A lamp may already burn one color. One mirror can take two lamps. A tide mirror reflects only while its row is flooded, and lets the beam pass while that row is dry. A shutter stops a beam while its row is dry, and lets the beam pass straight through while that row is flooded. A stain recolors a beam to its own color and lets it pass straight through, on a dry row and under water. A vane turns a beam into its facing, and a head-on beam stops. Water shuts a vane the way it shuts a mirror. A well stops a beam while its row is dry. While that row is flooded, the beam leaves north and keeps its color. A well does not turn. A siphon stops a beam while its row is dry. While that row is flooded, the beam leaves north and swaps red with blue. White stays white. A siphon does not turn. A sluice stops a beam while its row is dry. While that row is flooded, the beam leaves along the sluice's facing and keeps its color. A weir stops a beam while its row is dry. While that row is flooded, the beam leaves along the weir's facing and swaps red with blue. White stays white. A lintel lets a beam pass straight through while its row is dry, and stops the beam while that row is flooded. A lintel does not turn. A mullion lets a north-south beam pass straight through while its row is dry, and an east-west beam stops before it enters. A flooded mullion stops every beam. A mullion does not turn. A transom lets an east-west beam pass straight through while its row is dry, and a north-south beam stops before it enters. A flooded transom stops every beam. A transom does not turn. A casement lets a beam pass straight through while its row is dry, but only in the direction it faces. Every other direction stops before the cell. A flooded casement stops every beam. The casement turns. A jamb passes both directions of the axis it faces while its row is dry, and the other axis stops before the cell. North and south open the north-south axis. East and west open the east-west axis. A flooded jamb stops every beam. The jamb turns. An astragal passes the direction it faces and the next clockwise direction while its row is dry. The other two directions stop before the cell. A flooded astragal stops every beam. The astragal turns. A scotia passes the direction it faces and the next counterclockwise direction while its row is dry. The other two directions stop before the cell. A flooded scotia stops every beam. The scotia turns. A torus passes the direction opposite its facing and the next clockwise direction while its row is dry. The other two directions stop before the cell. A flooded torus stops every beam. The torus turns. An ogee passes the direction opposite its facing and the next counterclockwise direction while its row is dry. The other two directions stop before the cell. A flooded ogee stops every beam. The ogee turns. An ovolo passes every direction except the one it faces while its row is dry. That facing stops before the cell. A flooded ovolo stops every beam. The ovolo turns. A cavetto passes every direction except the opposite of its facing while its row is dry. That opposite direction stops before the cell. A flooded cavetto stops every beam. The cavetto turns. A fillet passes only the opposite of its facing while its row is dry. The facing and both sides stop before the cell. A flooded fillet stops every beam. The fillet turns. A corona passes the two directions perpendicular to its facing while its row is dry. The facing and the opposite stop before the cell. A flooded corona stops every beam. The corona turns. A bead passes only the next clockwise direction while its row is dry. The other three directions stop before the cell. A flooded bead stops every beam. The bead turns. A quirk passes only the next counterclockwise direction while its row is dry. The other three directions stop before the cell. A flooded quirk stops every beam. The quirk turns. A cyma passes only its facing while its row is dry. The other three directions stop before the cell. A flooded cyma stops every beam. The cyma turns. A fascia passes every direction except the next clockwise one while its row is dry. That clockwise direction stops before the cell. A flooded fascia stops every beam. The fascia turns. A soffit passes every direction except the next counterclockwise one while its row is dry. That counterclockwise direction stops before the cell. A flooded soffit stops every beam. The soffit turns. A dry drip passes every direction except the next counterclockwise one. A flooded drip passes only that stopped direction, and the other three stop at the waterline. The drip turns. A dry beak passes every direction except the next clockwise one. A flooded beak passes only that stopped direction, and the other three stop at the waterline. The beak turns. A dry hood passes every direction except its facing. A flooded hood passes only that facing, and the other three stop at the waterline. The hood turns. A dry throat passes every direction except the opposite of its facing. A flooded throat passes only that opposite, and the other three stop at the waterline. The throat turns. A dry larmier passes the two directions perpendicular to its facing. A flooded larmier passes only the facing and the opposite, and the other two stop at the waterline. The larmier turns. The cill turns. While it is dry, a cill passes its facing and the opposite. While it is flooded, only the two perpendicular directions pass. A threshold turns. While it is dry, only the opposite of its facing passes. While it is flooded, every direction except that opposite passes. An impost turns. While it is dry, only its facing passes. While it is flooded, every direction except that facing passes. An architrave turns. While it is dry, the two perpendicular directions pass. While it is flooded, only the facing passes. An archivolt turns. While it is dry, every heading stops. While it is flooded, the two perpendicular directions pass. An abacus turns. While it is dry, every heading stops. While it is flooded, only the facing passes. A rebate turns. While it is dry, every heading stops. While it is flooded, only the opposite of its facing passes. An echinus turns. While it is dry, every heading except the opposite passes. While it is flooded, only the next clockwise heading passes. An annulet turns. While it is dry, every heading except the opposite passes. While it is flooded, only the next counterclockwise heading passes. A listel turns. While it is dry, every heading stops. While it is flooded, the facing and the next clockwise heading pass. A necking turns. While it is dry, every heading stops. While it is flooded, the facing and the next counterclockwise heading pass. A taenia turns. While it is dry, every heading stops. While it is flooded, the facing and the opposite pass. A baguette turns. While it is dry, every heading stops. While it is flooded, every heading except the opposite passes. A reglet turns. While it is dry, every heading stops. While it is flooded, every heading except the next counterclockwise one passes. A billet turns. While it is dry, every heading stops. While it is flooded, every heading except the next clockwise one passes. A reed turns. While it is dry, every heading stops. While it is flooded, every heading passes. A staff turns. While it is dry, every heading stops. While it is flooded, the opposite and the next clockwise heading pass. Docks take only their marked color. Hulls stay dark. Water shuts the other glass it covers.", 13, Palette.MUTED)
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
	if str(piece["kind"]) == "corona":
		var corona_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("corona", corona_rot)
		status_label.text = "The corona turns clockwise. It passes the two directions perpendicular to its facing."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "bead":
		var bead_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("bead", bead_rot)
		status_label.text = "The bead turns clockwise. It passes only the next clockwise direction."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "quirk":
		var quirk_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("quirk", quirk_rot)
		status_label.text = "The quirk turns clockwise. It passes only the next counterclockwise direction."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "cyma":
		var cyma_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("cyma", cyma_rot)
		status_label.text = "The cyma turns clockwise. It passes only its facing."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "fascia":
		var fascia_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("fascia", fascia_rot)
		status_label.text = "The fascia turns clockwise. It passes every direction except the next clockwise direction."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "soffit":
		var soffit_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("soffit", soffit_rot)
		status_label.text = "The soffit turns clockwise. It passes every direction except the next counterclockwise direction."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "drip":
		var drip_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("drip", drip_rot)
		status_label.text = "The drip turns clockwise. While it is dry, it passes every direction except the next counterclockwise direction."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "beak":
		var beak_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("beak", beak_rot)
		status_label.text = "The beak turns clockwise. While it is dry, it passes every direction except the next clockwise direction."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "hood":
		var hood_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("hood", hood_rot)
		status_label.text = "The hood turns clockwise. While it is dry, it passes every direction except its facing. While it is flooded, only that facing passes."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "throat":
		var throat_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("throat", throat_rot)
		status_label.text = "The throat turns clockwise. While it is dry, it passes every direction except the opposite of its facing. While it is flooded, only that opposite passes."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "larmier":
		var larmier_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("larmier", larmier_rot)
		status_label.text = "The larmier turns clockwise. While it is dry, it passes the two directions perpendicular to its facing. While it is flooded, only the facing and the opposite pass."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "cill":
		var cill_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("cill", cill_rot)
		status_label.text = "The cill turns clockwise. While it is dry, it passes the facing and the opposite. While it is flooded, only the two perpendicular directions pass."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "threshold":
		var threshold_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("threshold", threshold_rot)
		status_label.text = "The threshold turns clockwise. While it is dry, only the opposite of its facing passes. While it is flooded, every direction except that opposite passes."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "impost":
		var impost_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("impost", impost_rot)
		status_label.text = "The impost turns clockwise. While it is dry, only its facing passes. While it is flooded, every direction except that facing passes."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "architrave":
		var architrave_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("architrave", architrave_rot)
		status_label.text = "The architrave turns clockwise. While it is dry, the two perpendicular directions pass. While it is flooded, only the facing passes."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "archivolt":
		var archivolt_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("archivolt", archivolt_rot)
		status_label.text = "The archivolt turns clockwise. While it is dry, every heading stops. While it is flooded, the two perpendicular directions pass."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "abacus":
		var abacus_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("abacus", abacus_rot)
		status_label.text = "The abacus turns clockwise. While it is dry, every heading stops. While it is flooded, only the facing passes."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "rebate":
		var rebate_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("rebate", rebate_rot)
		status_label.text = "The rebate turns clockwise. While it is dry, every heading stops. While it is flooded, only the opposite of its facing passes."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "echinus":
		var echinus_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("echinus", echinus_rot)
		status_label.text = "The echinus turns clockwise. While it is dry, every heading except the opposite passes. While it is flooded, only the next clockwise heading passes."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "annulet":
		var annulet_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("annulet", annulet_rot)
		status_label.text = "The annulet turns clockwise. While it is dry, every heading except the opposite passes. While it is flooded, only the next counterclockwise heading passes."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "listel":
		var listel_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("listel", listel_rot)
		status_label.text = "The listel turns clockwise. While it is dry, every heading stops. While it is flooded, the facing and the next clockwise heading pass."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "necking":
		var necking_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("necking", necking_rot)
		status_label.text = "The necking turns clockwise. While it is dry, every heading stops. While it is flooded, the facing and the next counterclockwise heading pass."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "taenia":
		var taenia_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("taenia", taenia_rot)
		status_label.text = "The taenia turns clockwise. While it is dry, every heading stops. While it is flooded, the facing and the opposite pass."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "baguette":
		var baguette_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("baguette", baguette_rot)
		status_label.text = "The baguette turns clockwise. While it is dry, every heading stops. While it is flooded, every heading except the opposite passes."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "reglet":
		var reglet_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("reglet", reglet_rot)
		status_label.text = "The reglet turns clockwise. While it is dry, every heading stops. While it is flooded, every heading except the next counterclockwise one passes."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "billet":
		var billet_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("billet", billet_rot)
		status_label.text = "The billet turns clockwise. While it is dry, every heading stops. While it is flooded, every heading except the next clockwise one passes."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "reed":
		var reed_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("reed", reed_rot)
		status_label.text = "The reed turns clockwise. While it is dry, every heading stops. While it is flooded, every heading passes."
		_clear_hint_if_resolved()
		_refresh()
		return
	if str(piece["kind"]) == "staff":
		var staff_rot := int(state["pieces"][selected_id]["rot"])
		state["pieces"][selected_id]["rot"] = Tracer.turn_rot("staff", staff_rot)
		status_label.text = "The staff turns clockwise. While it is dry, every heading stops. While it is flooded, the opposite and the next clockwise heading pass."
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
	if _has_corona():
		water += " A dry corona passes the two directions perpendicular to its facing. A flooded corona stops the beam."
	if _has_bead():
		water += " A dry bead passes only the next clockwise direction. A flooded bead stops the beam."
	if _has_quirk():
		water += " A dry quirk passes only the next counterclockwise direction. A flooded quirk stops the beam."
	if _has_cyma():
		water += " A dry cyma passes only its facing. A flooded cyma stops the beam."
	if _has_fascia():
		water += " A dry fascia passes every direction except the next clockwise direction. A flooded fascia stops the beam."
	if _has_soffit():
		water += " A dry soffit passes every direction except the next counterclockwise direction. A flooded soffit stops the beam."
	if _has_drip():
		water += " A dry drip passes every direction except the next counterclockwise direction. A flooded drip passes only that stopped direction."
	if _has_beak():
		water += " A dry beak passes every direction except the next clockwise direction. A flooded beak passes only that stopped direction."
	if _has_hood():
		water += " A dry hood passes every direction except its facing. A flooded hood passes only that facing."
	if _has_throat():
		water += " A dry throat passes every direction except the opposite of its facing. A flooded throat passes only that opposite."
	if _has_larmier():
		water += " A dry larmier passes the two directions perpendicular to its facing. A flooded larmier passes only the facing and the opposite."
	if _has_cill():
		water += " A dry cill passes its facing and the opposite. A flooded cill passes only the two perpendicular directions."
	if _has_threshold():
		water += " A dry threshold passes only the opposite of its facing. A flooded threshold passes every direction except that opposite."
	if _has_impost():
		water += " A dry impost passes only its facing. A flooded impost passes every direction except that facing."
	if _has_architrave():
		water += " A dry architrave passes the two directions perpendicular to its facing. A flooded architrave passes only its facing."
	if _has_archivolt():
		water += " A dry archivolt stops every heading. A flooded archivolt passes the two directions perpendicular to its facing."
	if _has_abacus():
		water += " A dry abacus stops every heading. A flooded abacus passes only its facing."
	if _has_rebate():
		water += " A dry rebate stops every heading. A flooded rebate passes only the opposite of its facing."
	if _has_echinus():
		water += " A dry echinus passes every heading except the opposite. A flooded echinus passes only the next clockwise heading."
	if _has_annulet():
		water += " A dry annulet passes every heading except the opposite. A flooded annulet passes only the next counterclockwise heading."
	if _has_listel():
		water += " A dry listel stops every heading. A flooded listel passes its facing and the next clockwise heading."
	if _has_necking():
		water += " A dry necking stops every heading. A flooded necking passes its facing and the next counterclockwise heading."
	if _has_taenia():
		water += " A dry taenia stops every heading. A flooded taenia passes its facing and the opposite."
	if _has_baguette():
		water += " A dry baguette stops every heading. A flooded baguette passes every heading except the opposite."
	if _has_reglet():
		water += " A dry reglet stops every heading. A flooded reglet passes every heading except the next counterclockwise one."
	if _has_billet():
		water += " A dry billet stops every heading. A flooded billet passes every heading except the next clockwise one."
	if _has_reed():
		water += " A dry reed stops every heading. A flooded reed passes every heading."
	if _has_staff():
		water += " A dry staff stops every heading. A flooded staff passes the opposite and the next clockwise heading."
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
	corona_grid.visible = book == 26
	bead_grid.visible = book == 27
	quirk_grid.visible = book == 28
	cyma_grid.visible = book == 29
	fascia_grid.visible = book == 30
	soffit_grid.visible = book == 31
	drip_grid.visible = book == 32
	beak_grid.visible = book == 33
	hood_grid.visible = book == 34
	throat_grid.visible = book == 35
	larmier_grid.visible = book == 36
	cill_grid.visible = book == 37
	threshold_grid.visible = book == 38
	impost_grid.visible = book == 39
	architrave_grid.visible = book == 40
	archivolt_grid.visible = book == 41
	abacus_grid.visible = book == 42
	rebate_grid.visible = book == 43
	echinus_grid.visible = book == 44
	annulet_grid.visible = book == 45
	listel_grid.visible = book == 46
	necking_grid.visible = book == 47
	taenia_grid.visible = book == 48
	baguette_grid.visible = book == 49
	reglet_grid.visible = book == 50
	billet_grid.visible = book == 51
	reed_grid.visible = book == 52
	staff_grid.visible = book == 53
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
	corona_book_button.disabled = not unlocked[int(bounds[26])]
	bead_book_button.disabled = not unlocked[int(bounds[27])]
	quirk_book_button.disabled = not unlocked[int(bounds[28])]
	cyma_book_button.disabled = not unlocked[int(bounds[29])]
	fascia_book_button.disabled = not unlocked[int(bounds[30])]
	soffit_book_button.disabled = not unlocked[int(bounds[31])]
	drip_book_button.disabled = not unlocked[int(bounds[32])]
	beak_book_button.disabled = not unlocked[int(bounds[33])]
	hood_book_button.disabled = not unlocked[int(bounds[34])]
	throat_book_button.disabled = not unlocked[int(bounds[35])]
	larmier_book_button.disabled = not unlocked[int(bounds[36])]
	cill_book_button.disabled = not unlocked[int(bounds[37])]
	threshold_book_button.disabled = not unlocked[int(bounds[38])]
	impost_book_button.disabled = not unlocked[int(bounds[39])]
	architrave_book_button.disabled = not unlocked[int(bounds[40])]
	archivolt_book_button.disabled = not unlocked[int(bounds[41])]
	abacus_book_button.disabled = not unlocked[int(bounds[42])]
	rebate_book_button.disabled = not unlocked[int(bounds[43])]
	echinus_book_button.disabled = not unlocked[int(bounds[44])]
	annulet_book_button.disabled = not unlocked[int(bounds[45])]
	listel_book_button.disabled = not unlocked[int(bounds[46])]
	necking_book_button.disabled = not unlocked[int(bounds[47])]
	taenia_book_button.disabled = not unlocked[int(bounds[48])]
	baguette_book_button.disabled = not unlocked[int(bounds[49])]
	reglet_book_button.disabled = not unlocked[int(bounds[50])]
	billet_book_button.disabled = not unlocked[int(bounds[51])]
	reed_book_button.disabled = not unlocked[int(bounds[52])]
	staff_book_button.disabled = not unlocked[int(bounds[53])]
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
	_paint_button(corona_book_button, book == 26)
	_paint_button(bead_book_button, book == 27)
	_paint_button(quirk_book_button, book == 28)
	_paint_button(cyma_book_button, book == 29)
	_paint_button(fascia_book_button, book == 30)
	_paint_button(soffit_book_button, book == 31)
	_paint_button(drip_book_button, book == 32)
	_paint_button(beak_book_button, book == 33)
	_paint_button(hood_book_button, book == 34)
	_paint_button(throat_book_button, book == 35)
	_paint_button(larmier_book_button, book == 36)
	_paint_button(cill_book_button, book == 37)
	_paint_button(threshold_book_button, book == 38)
	_paint_button(impost_book_button, book == 39)
	_paint_button(architrave_book_button, book == 40)
	_paint_button(archivolt_book_button, book == 41)
	_paint_button(abacus_book_button, book == 42)
	_paint_button(rebate_book_button, book == 43)
	_paint_button(echinus_book_button, book == 44)
	_paint_button(annulet_book_button, book == 45)
	_paint_button(listel_book_button, book == 46)
	_paint_button(necking_book_button, book == 47)
	_paint_button(taenia_book_button, book == 48)
	_paint_button(baguette_book_button, book == 49)
	_paint_button(reglet_book_button, book == 50)
	_paint_button(billet_book_button, book == 51)
	_paint_button(reed_book_button, book == 52)
	_paint_button(staff_book_button, book == 53)

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
	var fillet := cavetto + Charts.fillet().size()
	var corona := fillet + Charts.corona().size()
	var bead := corona + Charts.bead().size()
	var quirk := bead + Charts.quirk().size()
	var cyma := quirk + Charts.cyma().size()
	var fascia := cyma + Charts.fascia().size()
	var soffit := fascia + Charts.soffit().size()
	var drip := soffit + Charts.drip().size()
	var beak := drip + Charts.beak().size()
	var hood := beak + Charts.hood().size()
	var throat := hood + Charts.throat().size()
	var larmier := throat + Charts.larmier().size()
	var cill := larmier + Charts.cill().size()
	var threshold := cill + Charts.threshold().size()
	var impost := threshold + Charts.impost().size()
	var architrave := impost + Charts.architrave().size()
	var archivolt := architrave + Charts.archivolt().size()
	var abacus := archivolt + Charts.abacus().size()
	var rebate := abacus + Charts.rebate().size()
	var echinus := rebate + Charts.echinus().size()
	var annulet := echinus + Charts.annulet().size()
	var listel := annulet + Charts.listel().size()
	var necking := listel + Charts.necking().size()
	var taenia := necking + Charts.taenia().size()
	var baguette := taenia + Charts.baguette().size()
	var reglet := baguette + Charts.reglet().size()
	var billet := reglet + Charts.billet().size()
	var reed := billet + Charts.reed().size()
	return [0, q, r, b, p, w, m, t, s, n, v, well, siphon, sluice, weir, lintel, mullion, transom, casement, jamb, astragal, scotia, torus, ogee, ovolo, cavetto, fillet, corona, bead, quirk, cyma, fascia, soffit, drip, beak, hood, throat, larmier, cill, threshold, impost, architrave, archivolt, abacus, rebate, echinus, annulet, listel, necking, taenia, baguette, reglet, billet, reed, charts.size()]


func _book_of(index: int) -> int:
	var bounds: Array = _book_bounds()
	if index >= int(bounds[53]):
		return 53
	if index >= int(bounds[52]):
		return 52
	if index >= int(bounds[51]):
		return 51
	if index >= int(bounds[50]):
		return 50
	if index >= int(bounds[49]):
		return 49
	if index >= int(bounds[48]):
		return 48
	if index >= int(bounds[47]):
		return 47
	if index >= int(bounds[46]):
		return 46
	if index >= int(bounds[45]):
		return 45
	if index >= int(bounds[44]):
		return 44
	if index >= int(bounds[43]):
		return 43
	if index >= int(bounds[42]):
		return 42
	if index >= int(bounds[41]):
		return 41
	if index >= int(bounds[40]):
		return 40
	if index >= int(bounds[39]):
		return 39
	if index >= int(bounds[38]):
		return 38
	if index >= int(bounds[37]):
		return 37
	if index >= int(bounds[36]):
		return 36
	if index >= int(bounds[35]):
		return 35
	if index >= int(bounds[34]):
		return 34
	if index >= int(bounds[33]):
		return 33
	if index >= int(bounds[32]):
		return 32
	if index >= int(bounds[31]):
		return 31
	if index >= int(bounds[30]):
		return 30
	if index >= int(bounds[29]):
		return 29
	if index >= int(bounds[28]):
		return 28
	if index >= int(bounds[27]):
		return 27
	if index >= int(bounds[26]):
		return 26
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
		elif book == 25:
			status_label.text = "The fillet is still locked."
		elif book == 26:
			status_label.text = "The corona is still locked."
		elif book == 27:
			status_label.text = "The bead is still locked."
		elif book == 28:
			status_label.text = "The quirk is still locked."
		elif book == 29:
			status_label.text = "The cyma is still locked."
		elif book == 30:
			status_label.text = "The fascia is still locked."
		elif book == 31:
			status_label.text = "The soffit is still locked."
		elif book == 32:
			status_label.text = "The drip is still locked."
		elif book == 33:
			status_label.text = "The beak is still locked."
		elif book == 34:
			status_label.text = "The hood is still locked."
		elif book == 35:
			status_label.text = "The throat is still locked."
		elif book == 36:
			status_label.text = "The larmier is still locked."
		elif book == 37:
			status_label.text = "The cill is still locked."
		elif book == 38:
			status_label.text = "The threshold is still locked."
		elif book == 39:
			status_label.text = "The impost is still locked."
		elif book == 40:
			status_label.text = "The architrave is still locked."
		elif book == 41:
			status_label.text = "The archivolt is still locked."
		elif book == 42:
			status_label.text = "The abacus is still locked."
		elif book == 43:
			status_label.text = "The rebate is still locked."
		elif book == 44:
			status_label.text = "The echinus is still locked."
		elif book == 45:
			status_label.text = "The annulet is still locked."
		elif book == 46:
			status_label.text = "The listel is still locked."
		elif book == 47:
			status_label.text = "The necking is still locked."
		elif book == 48:
			status_label.text = "The taenia is still locked."
		elif book == 49:
			status_label.text = "The baguette is still locked."
		elif book == 50:
			status_label.text = "The reglet is still locked."
		elif book == 51:
			status_label.text = "The billet is still locked."
		elif book == 52:
			status_label.text = "The reed is still locked."
		else:
			status_label.text = "The staff is still locked."
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

func _has_corona() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "corona":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "corona":
			return true
	return false

func _has_bead() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "bead":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "bead":
			return true
	return false

func _has_quirk() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "quirk":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "quirk":
			return true
	return false

func _has_cyma() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "cyma":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "cyma":
			return true
	return false

func _has_fascia() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "fascia":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "fascia":
			return true
	return false

func _has_soffit() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "soffit":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "soffit":
			return true
	return false

func _has_drip() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "drip":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "drip":
			return true
	return false

func _has_beak() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "beak":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "beak":
			return true
	return false

func _has_hood() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "hood":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "hood":
			return true
	return false

func _has_throat() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "throat":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "throat":
			return true
	return false

func _has_staff() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "staff":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "staff":
			return true
	return false

func _has_reed() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "reed":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "reed":
			return true
	return false

func _has_billet() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "billet":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "billet":
			return true
	return false

func _has_reglet() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "reglet":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "reglet":
			return true
	return false

func _has_baguette() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "baguette":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "baguette":
			return true
	return false

func _has_taenia() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "taenia":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "taenia":
			return true
	return false

func _has_necking() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "necking":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "necking":
			return true
	return false

func _has_listel() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "listel":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "listel":
			return true
	return false

func _has_annulet() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "annulet":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "annulet":
			return true
	return false

func _has_echinus() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "echinus":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "echinus":
			return true
	return false

func _has_rebate() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "rebate":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "rebate":
			return true
	return false

func _has_abacus() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "abacus":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "abacus":
			return true
	return false

func _has_archivolt() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "archivolt":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "archivolt":
			return true
	return false

func _has_architrave() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "architrave":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "architrave":
			return true
	return false

func _has_impost() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "impost":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "impost":
			return true
	return false

func _has_threshold() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "threshold":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "threshold":
			return true
	return false

func _has_cill() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "cill":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "cill":
			return true
	return false

func _has_larmier() -> bool:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["kind"]) == "larmier":
			return true
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		if str(fix["kind"]) == "larmier":
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
