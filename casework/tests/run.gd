extends SceneTree

const CaseData = preload("res://scripts/case_data.gd")
const Rehearsal = preload("res://scripts/rehearsal_score.gd")
const Gilt = preload("res://scripts/gilt_stamp.gd")
const Ferry = preload("res://scripts/ferry_bell.gd")
const Weather = preload("res://scripts/weather_slate.gd")
const Loom = preload("res://scripts/loom_shuttle.gd")
const Hive = preload("res://scripts/hive_smoker.gd")
const Glass = preload("res://scripts/glass_pontil.gd")
const Press = preload("res://scripts/press_proof.gd")
const Assay = preload("res://scripts/assay_cup.gd")
const Kiln = preload("res://scripts/kiln_chalk.gd")
const Tide = preload("res://scripts/tide_ledger.gd")
const Night = preload("res://scripts/night_bell.gd")
const Salt = preload("res://scripts/salt_mark.gd")
const Wick = preload("res://scripts/wick_trim.gd")
const Anneal = preload("res://scripts/glass_anneal.gd")
const Graft = preload("res://scripts/orchard_graft.gd")
const Dye = preload("res://scripts/dye_vat.gd")
const Tar = preload("res://scripts/tar_kettle.gd")
const Cork = preload("res://scripts/cork_press.gd")
const Net = preload("res://scripts/net_loft.gd")
const Cask = preload("res://scripts/cask_hoop.gd")
const Linen = preload("res://scripts/linen_fold.gd")
const Dovetail = preload("res://scripts/dovetail.gd")
const Mortise = preload("res://scripts/mortise.gd")
const Rebate = preload("res://scripts/rebate.gd")
const Housing = preload("res://scripts/housing.gd")
const Tenon = preload("res://scripts/tenon.gd")
const Bridle = preload("res://scripts/bridle.gd")
const Dado = preload("res://scripts/dado.gd")
const Spline = preload("res://scripts/spline.gd")
const Mitre = preload("res://scripts/mitre.gd")
const Lap = preload("res://scripts/lap.gd")
const Catalog = preload("res://scripts/catalog.gd")
const Solver = preload("res://scripts/solver.gd")
const Verdict = preload("res://scripts/verdict.gd")

const TIMELINE := "Nell (night cook) took the spare key at 7 from the front desk to the kitchen, to lock the pantry.\nMoss (lodger) noticed the hook empty at 8 at the front desk and wrote a complaint.\nAda (clerk) logged the key returned at 9 at the front desk."
const REHEARSAL_TIMELINE := "Ivo (copyist) took the rehearsal score at 4 from the library to the practice room, to mark the cuts.\nNia (pianist) saw the taking from the gallery.\nBess (tuner) found the shelf empty at 5 in the library.\nThe score was logged back on the shelf at 6."
const REHEARSAL_TRUE := {"who": "Ivo", "place": "practice_room", "hour": "4"}
const GILT_TIMELINE := "Nessa (porter) took the gilt stamp at 1 from the store cage to the finishing bench, to lay the title edge.\nMara (binder) wrote the move order in the press room.\nTheo (gilder) signed the stamp back at 3 into the store cage.\nThe bench receipt was marked at 2."
const GILT_TRUE := {"who": "Nessa", "place": "finishing_bench", "hour": "1"}
const FERRY_TIMELINE := "Quill (ropehand) took the ferry bell at 15 from the ticket window to the rope loft, to call the late boat.\nWren (pilot) sounded the landing whistle in the jetty shed.\nHale (landing clerk) held the painter at 14 at the ticket window.\nThe boat answered at 16."
const FERRY_TRUE := {"who": "Quill", "place": "rope_loft", "hour": "15"}
const WEATHER_TIMELINE := "Pim (runner) took the weather slate at 12 from the peg room to the map alcove, to copy the frost line.\nSoren (reader) left the request at 10 on the tower stair.\nVesper (night watch) saw the carrying from the peg room.\nThe old reading was chalked at 11."
const WEATHER_TRUE := {"who": "Pim", "place": "map_alcove", "hour": "12"}
const LOOM_TIMELINE := "Fenn (warper) took the loom shuttle at 19 from the loom room to the pattern loft, to match the border.\nJoss (loom hand) marked the warp count at 17 in the dye house.\nRue (dyer) hung the shuttle back at 20 in the loom room."
const LOOM_TRUE := {"who": "Fenn", "place": "pattern_loft", "hour": "19"}
const HIVE_TIMELINE := "Tamsin (night beekeeper) took the hive smoker at 22 from the hive shed to the honey room, to quiet the late swarm.\nNed (skep hand) filled the fuel tin in the veil loft.\nIsla (veil mender) logged the sting book at 21 in the honey room.\nThe fuel was spent at 23.\nThe veil was mended at 24."
const HIVE_TRUE := {"who": "Tamsin", "place": "honey_room", "hour": "22"}
const GLASS_TIMELINE := "Sable (night gatherer) took the glass pontil at 27 from the glory hole to the lehr room, to crack the pontil off.\nHugh (marver hand) chalked the gather weight at 25 in the pot arch.\nOrla (annealer) opened the lehr at 26.\nThe gather was rolled at the glory hole.\nThe shoulder was sheared at 28.\nThe lehr was closed at 29."
const GLASS_TRUE := {"who": "Sable", "place": "lehr_room", "hour": "27"}
const PRESS_TIMELINE := "Nim (lockhand) took the press proof at 41 from the galley to the stone, so the forme could not be lifted.\nBrin (compositor) damped the sheet at 39 on the wetting board.\nCass (reader) lifted the chase at 40.\nThe furniture was planed at the galley.\nThe frisket was cut at 42.\nThe tympan was closed at 43."
const PRESS_TRUE := {"who": "Nim", "place": "stone", "hour": "41"}
const ASSAY_TIMELINE := "Lark (weigher) set the assay cup at 16 from the muffle to the scale, so the weight would read light.\nCress (cupeller) packed the bone ash at 14 on the flux bench.\nTor (touch hand) drew the needle at 15.\nThe button was parted at the muffle.\nThe flux was stirred at 17.\nThe cup was quenched at 18."
const ASSAY_TRUE := {"who": "Lark", "place": "scale", "hour": "16"}
const KILN_TIMELINE := "Wren (draught hand) chalked the kiln mark at 52 from the crown to the flue, so the draught would read shut.\nBram (fireman) mixed the slip at 50 at the fire mouth.\nNoll (watcher) read the spy hole at 51.\nThe damper was seated at the crown.\nThe spy hole was read at the crown.\nThe damper was shut at 53.\nThe cones were drawn at 54."
const KILN_TRUE := {"who": "Wren", "place": "flue", "hour": "52"}
const TIDE_TIMELINE := "Moss (tide clerk) entered the tide ledger at 33 from the mole to the quay, so the boat would read late.\nPell (ink hand) filled the pen at 31 on the sill.\nDory (bell hand) read the tide glass at 32.\nThe tide bell was hung on the mole.\nThe tide glass was read on the mole.\nThe boat was called at 34.\nThe line was hauled at 35."
const TIDE_TRUE := {"who": "Moss", "place": "quay", "hour": "33"}
const NIGHT_TIMELINE := "Vesper (night ringer) stopped the night bell at 44 from the parapet to the tower, so the watch would read early.\nCobb (lamp hand) trimmed the lamp at 42 on the bell walk.\nReed (stair hand) read the hour glass at 43.\nThe clapper was hitched on the parapet.\nThe hour glass was read on the parapet.\nThe watch was struck at 45.\nThe shutter was closed at 46."
const NIGHT_TRUE := {"who": "Vesper", "place": "tower", "hour": "44"}
const SALT_TIMELINE := "Holt (salt hand) scored the salt mark at 19 from the cistern to the pan, so the weigh would read heavy.\nLin (rake hand) raked the crust at 17 on the rake bay.\nOpal (brine hand) read the brine stick at 18.\nThe rake was rested on the cistern.\nThe brine stick was read on the cistern.\nThe pan was boiled at 20.\nThe salt was drawn at 21."
const SALT_TRUE := {"who": "Holt", "place": "pan", "hour": "19"}
const WICK_TIMELINE := "Quin (wick hand) trimmed the wick in the loft at 4, seen from the gallery, so the lamp would hold through the fog.\nMara (oil hand) filled the lamp oil at 2 in the stair.\nSable (lamp watch) kept the lamp watch at 3 in the gallery.\nThe snuffer was hung in the stair.\nThe gallery lamp was lit at 5.\nThe stair lamp was put out at 6."
const WICK_TRUE := {"who": "Quin", "place": "loft", "hour": "4"}
const ANNEAL_TIMELINE := "Tess (anneal hand) annealed the gather in the lehr at 10, seen from the marver, so the pane would cool without a crack.\nIvo (gatherer) gathered the glass in the pot, and the pot was charged at 8.\nWynn (marver hand) smoothed the shoulder at 9 on the marver.\nThe pontil was rested in the pot.\nThe marver was cleared at 11.\nThe lehr was latched at 12."
const ANNEAL_TRUE := {"who": "Tess", "place": "lehr", "hour": "10"}
const GRAFT_TIMELINE := "Calder (graft hand) grafted the scion in the nursery at 16, seen from the row, so the row would take before the frost.\nNess (scion cutter) cut the scion in the row at 15.\nEdda (raffia hand) bound the union at the gate.\nThe knife was hung at the gate.\nThe row was watered at 14.\nThe gate was shut at 17.\nThe frost was chalked at 18."
const GRAFT_TRUE := {"who": "Calder", "place": "nursery", "hour": "16"}
const DYE_TIMELINE := "Sera (dip hand) dipped the skein in the vat at 7, seen from the line, so the line would take the indigo.\nPim (skein winder) wound the skein in the yard at 6.\nJoss (indigo hand) stirred the indigo at the line.\nThe paddle was hung in the yard.\nThe line was stretched at 5.\nThe yard was raked at 8.\nThe vat was lidded at 9."
const DYE_TRUE := {"who": "Sera", "place": "vat", "hour": "7"}
const TAR_TIMELINE := "Rho (tar hand) tarred the rope in the kettle at 6, seen from the walk, so the walk would take the tar.\nLumen (rope hand) laid the rope in the loft at 5.\nKit (walk clerk) turned the winch at the walk.\nThe hook was hung in the loft.\nThe walk was stretched at 4.\nThe loft was swept at 7.\nThe kettle was lidded at 8."
const TAR_TRUE := {"who": "Rho", "place": "kettle", "hour": "6"}
const CORK_TIMELINE := "Brea (cork hand) pressed the cork in the press at 5, seen from the cellar, so the cellar would take the seal.\nAnsel (press hand) cut the cork on the bench at 4.\nColm (cellar clerk) turned the screw in the cellar.\nThe mallet was hung on the bench.\nThe cellar was swept at 3.\nThe bench was wiped at 6.\nThe press was locked at 7."
const CORK_TRUE := {"who": "Brea", "place": "press", "hour": "5"}
const NET_TIMELINE := "Hester (mend hand) mended the net in the loft at 4, seen from the shed, so the shed would take the mesh.\nGwyn (net hand) hung the net on the rail at 3.\nIdris (shed clerk) turned the crank in the shed.\nThe needle was hung on the rail.\nThe shed was swept at 2.\nThe rail was wiped at 5.\nThe loft was closed at 6."
const NET_TRUE := {"who": "Hester", "place": "loft", "hour": "4"}
const CASK_TIMELINE := "Maeve (shop hand) drove the hoop in the shop at 3, seen from the yard, so the yard would take the cask.\nJory (hoop hand) cut the hoop on the bench at 2.\nPerrin (yard clerk) turned the croze in the yard.\nThe driver was hung on the bench.\nThe yard was swept at 1.\nThe bench was wiped at 4.\nThe shop was closed at 5."
const CASK_TRUE := {"who": "Maeve", "place": "shop", "hour": "3"}
const LINEN_TIMELINE := "Vetch (press hand) folded the linen in the press at 8, seen from the loft, so the loft would take the sheet.\nOdell (fold hand) cut the linen on the bench at 7.\nBrigg (loft clerk) turned the roller in the loft.\nThe pin was hung on the bench.\nThe loft was swept at 6.\nThe bench was wiped at 9.\nThe press was closed at 10."
const LINEN_TRUE := {"who": "Vetch", "place": "press", "hour": "8"}
const DOVETAIL_TIMELINE := "Doss (saw hand) cut the dovetail in the vise at 63, seen from the apron, so the stile would take the joint.\nYarrow (board hand) sawed the board on the stile at 62.\nPeck (clamp clerk) turned the clamp in the apron.\nThe peg was hung on the stile.\nThe apron was swept at 61.\nThe stile was wiped at 64.\nThe vise was closed at 65."
const DOVETAIL_TRUE := {"who": "Doss", "place": "vise", "hour": "63"}
const MORTISE_TIMELINE := "Arlo (chisel hand) cut the mortise in the chisel at 68, seen from the awl, so the last would take the tenon.\nKeel (awl hand) bored the hole on the last at 67.\nWeske (last clerk) turned the brace in the awl.\nThe wedge was hung on the last.\nThe awl was brushed at 66.\nThe last was ragged at 69.\nThe chisel was racked at 70."
const MORTISE_TRUE := {"who": "Arlo", "place": "chisel", "hour": "68"}
const REBATE_TIMELINE := "Tansy (plane hand) cut the rebate in the plane at 73, seen from the gauge, so the mallet would take the shoulder.\nSolt (gauge hand) scribed the line on the mallet at 72.\nQuern (mallet clerk) turned the fence in the gauge.\nThe shim was hung on the mallet.\nThe gauge was oiled at 71.\nThe mallet was wiped at 74.\nThe plane was hung at 75."
const REBATE_TRUE := {"who": "Tansy", "place": "plane", "hour": "73"}
const HOUSING_TIMELINE := "Ewan (saw hand) cut the housing in the saw at 78, seen from the square, so the bead would take the trench.\nMaren (square hand) marked the trench on the bead at 77.\nHollin (bead clerk) turned the stock in the square.\nThe fillet was hung on the bead.\nThe square was chalked at 76.\nThe bead was wiped at 79.\nThe saw was hung at 80."
const HOUSING_TRUE := {"who": "Ewan", "place": "saw", "hour": "78"}
const TENON_TIMELINE := "Harl (gouge hand) cut the tenon in the gouge at 83, seen from the rasp, so the bevel would take the haunch.\nNeve (rasp hand) marked the haunch on the bevel at 82.\nLuth (bevel clerk) turned the guide in the rasp.\nThe dowel was hung on the bevel.\nThe rasp was honed at 81.\nThe bevel was wiped at 84.\nThe gouge was hung at 85."
const TENON_TRUE := {"who": "Harl", "place": "gouge", "hour": "83"}
const BRIDLE_TIMELINE := "Wend (router hand) cut the bridle in the router at 88, seen from the scraper, so the adze would take the tongue.\nSile (scraper hand) marked the tongue on the adze at 87.\nJute (adze clerk) turned the templet in the scraper.\nThe spline was hung on the adze.\nThe scraper was stropped at 86.\nThe adze was wiped at 89.\nThe router was hung at 90."
const BRIDLE_TRUE := {"who": "Wend", "place": "router", "hour": "88"}
const DADO_TIMELINE := "Kern (plough hand) cut the dado in the plough at 93, seen from the float, so the gimlet would take the groove.\nPhel (float hand) marked the groove on the gimlet at 92.\nTarn (gimlet clerk) turned the spur in the float.\nThe cleat was hung on the gimlet.\nThe float was whetted at 91.\nThe gimlet was wiped at 94.\nThe plough was hung at 95."
const DADO_TRUE := {"who": "Kern", "place": "plough", "hour": "93"}
const SPLINE_TIMELINE := "Senn (vise hand) cut the spline in the plough at 98, seen from the float, so the tongue would take the slot.\nVoss (chest hand) marked the slot on the gimlet at 97.\nCade (horse clerk) turned the key in the float.\nThe feather was hung on the gimlet.\nThe float was whetted at 96.\nThe gimlet was wiped at 99.\nThe plough was hung at 100."
const SPLINE_TRUE := {"who": "Senn", "place": "plough", "hour": "98"}
const MITRE_TIMELINE := "Orrin (saddle hand) cut the mitre in the plough at 103, seen from the float, so the arris would take the mitre.\nVenn (kerf hand) marked the arris on the gimlet at 102.\nHaim (bit clerk) turned the stop in the float.\nThe offcut was hung on the gimlet.\nThe float was dressed at 101.\nThe gimlet was brushed at 104.\nThe plough was hung at 105."
const MITRE_TRUE := {"who": "Orrin", "place": "plough", "hour": "103"}
const LAP_TIMELINE := "Nye (cradle hand) cut the lap in the plough at 108, seen from the float, so the grain would take the lap.\nYew (grain hand) marked the grain on the gimlet at 107.\nPry (brad clerk) turned the brad in the float.\nThe paring was hung on the gimlet.\nThe float was skimmed at 106.\nThe gimlet was oiled at 109.\nThe plough was hung at 110."
const LAP_TRUE := {"who": "Nye", "place": "plough", "hour": "108"}

var _failures: Array[String] = []
var _checks := 0
var _menu_root: Node


func _initialize() -> void:
	_test_file_shape()
	_test_unique_model()
	_test_each_exhibit_necessary()
	_test_true_theory_accepted()
	_test_wrong_theories()
	_test_incomplete()
	_test_rehearsal_file_shape()
	_test_rehearsal_unique_model()
	_test_rehearsal_each_exhibit_necessary()
	_test_rehearsal_only_true_theory()
	_test_rehearsal_near_misses()
	_test_rehearsal_incomplete()
	_test_gilt_file_shape()
	_test_gilt_unique_model()
	_test_gilt_each_exhibit_necessary()
	_test_gilt_only_true_theory()
	_test_gilt_near_misses()
	_test_gilt_incomplete()
	_test_ferry_file_shape()
	_test_ferry_unique_model()
	_test_ferry_each_exhibit_necessary()
	_test_ferry_only_true_theory()
	_test_ferry_near_misses()
	_test_ferry_incomplete()
	_test_weather_file_shape()
	_test_weather_unique_model()
	_test_weather_each_exhibit_necessary()
	_test_weather_only_true_theory()
	_test_weather_near_misses()
	_test_weather_incomplete()
	_test_loom_file_shape()
	_test_loom_unique_model()
	_test_loom_each_exhibit_necessary()
	_test_loom_only_true_theory()
	_test_loom_near_misses()
	_test_loom_incomplete()
	_test_hive_file_shape()
	_test_hive_unique_model()
	_test_hive_each_exhibit_necessary()
	_test_hive_only_true_theory()
	_test_hive_near_misses()
	_test_hive_incomplete()
	_test_glass_file_shape()
	_test_glass_unique_model()
	_test_glass_each_exhibit_necessary()
	_test_glass_only_true_theory()
	_test_glass_near_misses()
	_test_glass_incomplete()
	_test_press_file_shape()
	_test_press_unique_model()
	_test_press_each_exhibit_necessary()
	_test_press_only_true_theory()
	_test_press_near_misses()
	_test_press_incomplete()
	_test_assay_file_shape()
	_test_assay_unique_model()
	_test_assay_each_exhibit_necessary()
	_test_assay_only_true_theory()
	_test_assay_near_misses()
	_test_assay_incomplete()
	_test_kiln_file_shape()
	_test_kiln_unique_model()
	_test_kiln_each_exhibit_necessary()
	_test_kiln_only_true_theory()
	_test_kiln_near_misses()
	_test_kiln_incomplete()
	_test_tide_file_shape()
	_test_tide_unique_model()
	_test_tide_each_exhibit_necessary()
	_test_tide_only_true_theory()
	_test_tide_near_misses()
	_test_tide_incomplete()
	_test_night_file_shape()
	_test_night_unique_model()
	_test_night_each_exhibit_necessary()
	_test_night_only_true_theory()
	_test_night_near_misses()
	_test_night_incomplete()
	_test_salt_file_shape()
	_test_salt_unique_model()
	_test_salt_each_exhibit_necessary()
	_test_salt_only_true_theory()
	_test_salt_near_misses()
	_test_salt_incomplete()
	_test_wick_file_shape()
	_test_wick_unique_model()
	_test_wick_each_exhibit_necessary()
	_test_wick_only_true_theory()
	_test_wick_near_misses()
	_test_wick_incomplete()
	_test_anneal_file_shape()
	_test_anneal_unique_model()
	_test_anneal_each_exhibit_necessary()
	_test_anneal_only_true_theory()
	_test_anneal_near_misses()
	_test_anneal_incomplete()
	_test_graft_file_shape()
	_test_graft_unique_model()
	_test_graft_each_exhibit_necessary()
	_test_graft_only_true_theory()
	_test_graft_near_misses()
	_test_graft_incomplete()
	_test_dye_file_shape()
	_test_dye_unique_model()
	_test_dye_each_exhibit_necessary()
	_test_dye_only_true_theory()
	_test_dye_near_misses()
	_test_dye_incomplete()
	_test_tar_file_shape()
	_test_tar_unique_model()
	_test_tar_each_exhibit_necessary()
	_test_tar_only_true_theory()
	_test_tar_near_misses()
	_test_tar_incomplete()
	_test_cork_file_shape()
	_test_cork_unique_model()
	_test_cork_each_exhibit_necessary()
	_test_cork_only_true_theory()
	_test_cork_near_misses()
	_test_cork_incomplete()
	_test_net_file_shape()
	_test_net_unique_model()
	_test_net_each_exhibit_necessary()
	_test_net_only_true_theory()
	_test_net_near_misses()
	_test_net_incomplete()
	_test_cask_file_shape()
	_test_cask_unique_model()
	_test_cask_each_exhibit_necessary()
	_test_cask_only_true_theory()
	_test_cask_near_misses()
	_test_cask_incomplete()
	_test_linen_file_shape()
	_test_linen_unique_model()
	_test_linen_each_exhibit_necessary()
	_test_linen_only_true_theory()
	_test_linen_near_misses()
	_test_linen_incomplete()
	_test_dovetail_file_shape()
	_test_dovetail_unique_model()
	_test_dovetail_each_exhibit_necessary()
	_test_dovetail_only_true_theory()
	_test_dovetail_near_misses()
	_test_dovetail_incomplete()
	_test_mortise_file_shape()
	_test_mortise_unique_model()
	_test_mortise_each_exhibit_necessary()
	_test_mortise_only_true_theory()
	_test_mortise_near_misses()
	_test_mortise_incomplete()
	_test_rebate_file_shape()
	_test_rebate_unique_model()
	_test_rebate_each_exhibit_necessary()
	_test_rebate_only_true_theory()
	_test_rebate_near_misses()
	_test_rebate_incomplete()
	_test_housing_file_shape()
	_test_housing_unique_model()
	_test_housing_each_exhibit_necessary()
	_test_housing_only_true_theory()
	_test_housing_near_misses()
	_test_housing_incomplete()
	_test_tenon_file_shape()
	_test_tenon_unique_model()
	_test_tenon_each_exhibit_necessary()
	_test_tenon_only_true_theory()
	_test_tenon_near_misses()
	_test_tenon_incomplete()
	_test_bridle_file_shape()
	_test_bridle_unique_model()
	_test_bridle_each_exhibit_necessary()
	_test_bridle_only_true_theory()
	_test_bridle_near_misses()
	_test_bridle_incomplete()
	_test_dado_file_shape()
	_test_dado_unique_model()
	_test_dado_each_exhibit_necessary()
	_test_dado_only_true_theory()
	_test_dado_near_misses()
	_test_dado_incomplete()
	_test_spline_file_shape()
	_test_spline_unique_model()
	_test_spline_each_exhibit_necessary()
	_test_spline_only_true_theory()
	_test_spline_near_misses()
	_test_spline_incomplete()
	_test_mitre_file_shape()
	_test_mitre_unique_model()
	_test_mitre_each_exhibit_necessary()
	_test_mitre_only_true_theory()
	_test_mitre_near_misses()
	_test_mitre_incomplete()
	_test_lap_file_shape()
	_test_lap_unique_model()
	_test_lap_each_exhibit_necessary()
	_test_lap_only_true_theory()
	_test_lap_near_misses()
	_test_lap_incomplete()
	_test_solutions_differ()
	_test_menu_opens_either_case()
	print("menu interaction done")
	await process_frame
	await process_frame
	_expect_open_buttons_fit_the_case_window()
	if _menu_root != null:
		_menu_root.queue_free()
	_finish_suite()


func _finish_suite() -> void:
	if _failures.is_empty():
		print("ALL PASS (%d checks)" % _checks)
		quit(0)
	else:
		for failure in _failures:
			printerr("FAIL %s" % failure)
		printerr("ALL FAIL (%d failed, %d checks)" % [_failures.size(), _checks])
		quit(1)


func _expect(condition: bool, message: String) -> void:
	_checks += 1
	if not condition:
		_failures.append(message)


func _test_file_shape() -> void:
	_expect(CaseData.EXHIBITS.size() >= 6 and CaseData.EXHIBITS.size() <= 8, "exhibit count is %d" % CaseData.EXHIBITS.size())
	_expect(CaseData.PEOPLE.size() == 3, "cast should be three people")
	_expect(CaseData.PLACES.size() >= 3, "need a few locations")
	_expect(CaseData.HOURS.size() >= 3 and CaseData.HOURS.size() <= 5, "hour list length")
	var seen := {}
	for exhibit in CaseData.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		_expect(not seen.has(exhibit_id), "duplicate id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		for literal in exhibit["literals"]:
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in CaseData.PLAYER_FIELDS:
				var expected := CaseData.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])


func _test_unique_model() -> void:
	var models := Solver.enumerate(CaseData.EXHIBITS)
	print("unique models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Nell", "taker")
	_expect(str(model["place"]) == "kitchen", "place")
	_expect(str(model["hour"]) == "7", "hour")
	_expect(str(model["notifier"]) == "Moss", "notifier")
	_expect(str(model["notice_hour"]) == "8", "notice hour")
	_expect(str(model["notice_place"]) == "front_desk", "notice place")
	_expect(str(model["returner"]) == "Ada", "returner")
	_expect(str(model["return_hour"]) == "9", "return hour")
	_expect(str(model["return_place"]) == "front_desk", "return place")
	_expect(str(model["origin"]) == "front_desk", "origin")
	_expect(str(model["purpose"]) == "pantry_lock", "purpose")
	_expect(CaseData.timeline(model) == TIMELINE, "timeline text drifted:\n%s" % CaseData.timeline(model))
	for exhibit in CaseData.EXHIBITS:
		_expect(CaseData.holds(exhibit, model), "%s rejects the true timeline" % exhibit["id"])


func _test_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(CaseData.EXHIBITS)
	for exhibit in CaseData.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(CaseData.without(exhibit_id))
		print("without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "%s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not CaseData.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "%s removal did not admit a timeline it forbids" % exhibit_id)


func _test_true_theory_accepted() -> void:
	var result: Dictionary = Verdict.submit({"who": "Nell", "place": "kitchen", "hour": "7"})
	print("true theory: %s" % result["status"])
	_expect(result["status"] == "accepted", "true theory status %s" % result["status"])
	_expect(str(result["message"]).find("fits every exhibit") >= 0, "acceptance should say it fits every exhibit")
	_expect(str(result["message"]).find(TIMELINE) >= 0, "acceptance should give the timeline")
	_expect(CaseData.conflicting_ids({"who": "Nell", "place": "kitchen", "hour": "7"}).is_empty(), "true theory conflicts with an exhibit")


func _test_wrong_theories() -> void:
	var samples := [
		{"who": "Moss", "place": "front_desk", "hour": "8"},
		{"who": "Ada", "place": "pantry", "hour": "9"},
		{"who": "Nell", "place": "kitchen", "hour": "8"},
		{"who": "Nell", "place": "pantry", "hour": "7"},
	]
	for theory in samples:
		_expect_rejected(theory)
	var wrong := 0
	for who in CaseData.PEOPLE:
		for place in CaseData.PLACES:
			for hour in CaseData.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == "Nell" and place == "kitchen" and hour == "7":
					continue
				wrong += 1
				_expect_rejected(theory)
	print("wrong theories rejected: %d" % wrong)
	_expect(wrong >= 2, "need at least two wrong theories")


func _expect_rejected(theory: Dictionary, book = null) -> void:
	var case_book = CaseData if book == null else book
	var result: Dictionary = Verdict.submit(theory, case_book)
	var label := "%s / %s / %s" % [theory["who"], theory["place"], theory["hour"]]
	_expect(result["status"] == "rejected", "%s status %s" % [label, result["status"]])
	var message := str(result["message"])
	_expect(message.find("fits every exhibit") == -1, "%s was treated as fitting" % label)
	var conflicting: Array[String] = case_book.conflicting_ids(theory)
	_expect(conflicting.size() >= 2, "%s contradicts %d exhibits" % [label, conflicting.size()])
	var cited := _cited_ids(message)
	_expect(cited.size() >= 2, "%s reply cites %d exhibits: %s" % [label, cited.size(), message])
	for exhibit_id in cited:
		_expect(exhibit_id in case_book.ids(), "%s cites unknown %s" % [label, exhibit_id])
		_expect(exhibit_id in conflicting, "%s cites %s which it does not contradict" % [label, exhibit_id])
	for exhibit_id in conflicting:
		_expect(exhibit_id in cited, "%s reply omits %s" % [label, exhibit_id])
	_expect(message.find("Your claim that ") >= 0, "%s reply does not name the claim" % label)


func _cited_ids(message: String) -> Array[String]:
	var expression := RegEx.new()
	var err := expression.compile("\\bE[1-9][0-9]*\\b")
	_expect(err == OK, "exhibit id pattern did not compile")
	var found: Array[String] = []
	if err != OK:
		return found
	for match in expression.search_all(message):
		var exhibit_id := match.get_string()
		if exhibit_id not in found:
			found.append(exhibit_id)
	return found


func _test_incomplete() -> void:
	var cases := [
		{"theory": {"who": "", "place": "kitchen", "hour": "7"}, "present": ["who took the spare key"], "absent": ["where they took the key", "at which hour they took the key"]},
		{"theory": {"who": "Nell", "place": "", "hour": "7"}, "present": ["where they took the key"], "absent": ["who took the spare key", "at which hour they took the key"]},
		{"theory": {"who": "Nell", "place": "kitchen", "hour": ""}, "present": ["at which hour they took the key"], "absent": ["who took the spare key", "where they took the key"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who took the spare key", "where they took the key", "at which hour they took the key"], "absent": []},
		{"theory": {}, "present": ["who took the spare key", "where they took the key", "at which hour they took the key"], "absent": []},
		{"theory": {"who": "Moss", "place": "", "hour": "9"}, "present": ["where they took the key"], "absent": ["who took the spare key", "at which hour they took the key"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"])
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "named a filled slot (%s) in: %s" % [phrase, message])
	print("incomplete submissions refused with the missing slot")


func _test_rehearsal_file_shape() -> void:
	_expect(Rehearsal.EXHIBITS.size() >= 6 and Rehearsal.EXHIBITS.size() <= 8, "rehearsal exhibit count is %d" % Rehearsal.EXHIBITS.size())
	_expect(Rehearsal.PEOPLE.size() == 3, "rehearsal cast should be three people")
	_expect(Rehearsal.PLACES.size() >= 3, "rehearsal needs a few rooms")
	_expect(Rehearsal.HOURS.size() >= 3 and Rehearsal.HOURS.size() <= 5, "rehearsal hour list length")
	_expect(Rehearsal.TITLE == "The rehearsal score", "rehearsal title")
	_expect(Rehearsal.TITLE != CaseData.TITLE, "cases share a title")
	var seen := {}
	for exhibit in Rehearsal.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		_expect(not seen.has(exhibit_id), "duplicate rehearsal id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		var states_player_pin := false
		var states_unique := false
		for literal in exhibit["literals"]:
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Rehearsal.PLAYER_FIELDS:
				states_player_pin = true
				var expected := Rehearsal.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Rehearsal.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				var owners := 0
				for other in Rehearsal.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)


func _test_rehearsal_unique_model() -> void:
	var models := Solver.enumerate(Rehearsal.EXHIBITS, Rehearsal)
	print("rehearsal models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one rehearsal model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Ivo", "rehearsal taker")
	_expect(str(model["place"]) == "practice_room", "rehearsal place")
	_expect(str(model["hour"]) == "4", "rehearsal hour")
	_expect(str(model["witness"]) == "Nia", "rehearsal witness")
	_expect(str(model["witness_place"]) == "gallery", "rehearsal witness place")
	_expect(str(model["finder"]) == "Bess", "rehearsal finder")
	_expect(str(model["find_hour"]) == "5", "rehearsal find hour")
	_expect(str(model["find_place"]) == "library", "rehearsal find place")
	_expect(str(model["origin"]) == "library", "rehearsal origin")
	_expect(str(model["purpose"]) == "mark_cuts", "rehearsal purpose")
	_expect(str(model["return_hour"]) == "6", "rehearsal return hour")
	_expect(Rehearsal.timeline(model) == REHEARSAL_TIMELINE, "rehearsal timeline drifted:\n%s" % Rehearsal.timeline(model))
	for exhibit in Rehearsal.EXHIBITS:
		_expect(Rehearsal.holds(exhibit, model), "%s rejects the rehearsal timeline" % exhibit["id"])


func _test_rehearsal_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Rehearsal.EXHIBITS, Rehearsal)
	for exhibit in Rehearsal.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Rehearsal.without(exhibit_id), Rehearsal)
		print("rehearsal without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "rehearsal %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Rehearsal.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "rehearsal %s removal did not admit a timeline it forbids" % exhibit_id)


func _test_rehearsal_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	for who in Rehearsal.PEOPLE:
		for place in Rehearsal.PLACES:
			for hour in Rehearsal.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == REHEARSAL_TRUE["who"] and place == REHEARSAL_TRUE["place"] and hour == REHEARSAL_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Rehearsal)
					print("rehearsal true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true rehearsal theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "rehearsal acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(REHEARSAL_TIMELINE) >= 0, "rehearsal acceptance should give the timeline")
					_expect(Rehearsal.conflicting_ids(theory).is_empty(), "true rehearsal theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Rehearsal)
					rejected += 1
	print("rehearsal theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d rehearsal theories" % accepted)
	_expect(rejected >= 2, "rejected %d rehearsal theories" % rejected)


func _test_rehearsal_near_misses() -> void:
	var misses := [
		{"who": "Ivo", "place": "practice_room", "hour": "5"},
		{"who": "Ivo", "place": "library", "hour": "4"},
		{"who": "Nia", "place": "practice_room", "hour": "4"},
	]
	for theory in misses:
		_expect_rejected(theory, Rehearsal)
	print("rehearsal near-misses rejected: %d" % misses.size())
	_expect(misses.size() >= 2, "need at least two rehearsal near-misses")


func _test_rehearsal_incomplete() -> void:
	var spare_slots := ["who took the spare key", "where they took the key", "at which hour they took the key"]
	var cases := [
		{"theory": {"who": "", "place": "practice_room", "hour": "4"}, "present": ["who took the rehearsal score"], "absent": ["where they took the score", "at which hour they took the score"]},
		{"theory": {"who": "Ivo", "place": "", "hour": "4"}, "present": ["where they took the score"], "absent": ["who took the rehearsal score", "at which hour they took the score"]},
		{"theory": {"who": "Ivo", "place": "practice_room", "hour": ""}, "present": ["at which hour they took the score"], "absent": ["who took the rehearsal score", "where they took the score"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who took the rehearsal score", "where they took the score", "at which hour they took the score"], "absent": []},
		{"theory": {}, "present": ["who took the rehearsal score", "where they took the score", "at which hour they took the score"], "absent": []},
		{"theory": {"who": "Bess", "place": "", "hour": "6"}, "present": ["where they took the score"], "absent": ["who took the rehearsal score", "at which hour they took the score"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Rehearsal)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "rehearsal incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "rehearsal incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "rehearsal incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "rehearsal incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "rehearsal incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "rehearsal missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "rehearsal named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in spare_slots:
			_expect(message.find(phrase) == -1, "rehearsal incomplete used a spare-key slot (%s) in: %s" % [phrase, message])
	print("rehearsal incomplete submissions refused with the missing slot")


func _test_gilt_file_shape() -> void:
	_expect(Gilt.EXHIBITS.size() >= 6 and Gilt.EXHIBITS.size() <= 8, "gilt exhibit count is %d" % Gilt.EXHIBITS.size())
	_expect(Gilt.PEOPLE.size() == 3, "gilt cast should be three people")
	_expect(Gilt.PLACES.size() >= 3, "gilt needs a few rooms")
	_expect(Gilt.HOURS.size() >= 3 and Gilt.HOURS.size() <= 5, "gilt hour list length")
	_expect(Gilt.TITLE == "The gilt stamp", "gilt title")
	_expect(Gilt.TITLE != CaseData.TITLE and Gilt.TITLE != Rehearsal.TITLE, "gilt shares a title")
	_expect(Gilt.FILE_CODE == "CW-03", "gilt file code")
	_expect(Gilt.FILE_CODE != CaseData.FILE_CODE and Gilt.FILE_CODE != Rehearsal.FILE_CODE, "gilt shares a file code")
	var seen := {}
	for exhibit in Gilt.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		_expect(not seen.has(exhibit_id), "duplicate gilt id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		var states_player_pin := false
		var states_unique := false
		for literal in exhibit["literals"]:
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Gilt.PLAYER_FIELDS:
				states_player_pin = true
				var expected := Gilt.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Gilt.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				var owners := 0
				for other in Gilt.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)


func _test_gilt_unique_model() -> void:
	var models := Solver.enumerate(Gilt.EXHIBITS, Gilt)
	print("gilt models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one gilt model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Nessa", "gilt taker")
	_expect(str(model["place"]) == "finishing_bench", "gilt place")
	_expect(str(model["hour"]) == "1", "gilt hour")
	_expect(str(model["orderer"]) == "Mara", "gilt orderer")
	_expect(str(model["order_place"]) == "press_room", "gilt order place")
	_expect(str(model["signer"]) == "Theo", "gilt signer")
	_expect(str(model["return_place"]) == "store_cage", "gilt return place")
	_expect(str(model["return_hour"]) == "3", "gilt return hour")
	_expect(str(model["origin"]) == "store_cage", "gilt origin")
	_expect(str(model["purpose"]) == "title_edge", "gilt purpose")
	_expect(str(model["receipt_hour"]) == "2", "gilt receipt hour")
	_expect(Gilt.timeline(model) == GILT_TIMELINE, "gilt timeline drifted:\n%s" % Gilt.timeline(model))
	for exhibit in Gilt.EXHIBITS:
		_expect(Gilt.holds(exhibit, model), "%s rejects the gilt timeline" % exhibit["id"])


func _test_gilt_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Gilt.EXHIBITS, Gilt)
	for exhibit in Gilt.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Gilt.without(exhibit_id), Gilt)
		print("gilt without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "gilt %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Gilt.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "gilt %s removal did not admit a timeline it forbids" % exhibit_id)


func _test_gilt_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	for who in Gilt.PEOPLE:
		for place in Gilt.PLACES:
			for hour in Gilt.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == GILT_TRUE["who"] and place == GILT_TRUE["place"] and hour == GILT_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Gilt)
					print("gilt true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true gilt theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "gilt acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(GILT_TIMELINE) >= 0, "gilt acceptance should give the timeline")
					_expect(Gilt.conflicting_ids(theory).is_empty(), "true gilt theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Gilt)
					rejected += 1
	print("gilt theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d gilt theories" % accepted)
	_expect(rejected >= 2, "rejected %d gilt theories" % rejected)


func _test_gilt_near_misses() -> void:
	var misses := [
		{"who": "Nessa", "place": "finishing_bench", "hour": "2"},
		{"who": "Nessa", "place": "press_room", "hour": "1"},
		{"who": "Mara", "place": "finishing_bench", "hour": "1"},
	]
	for theory in misses:
		_expect_rejected(theory, Gilt)
	print("gilt near-misses rejected: %d" % misses.size())
	_expect(misses.size() >= 2, "need at least two gilt near-misses")


func _test_gilt_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
	]
	var cases := [
		{"theory": {"who": "", "place": "finishing_bench", "hour": "1"}, "present": ["who took the gilt stamp"], "absent": ["where they took the stamp", "at which hour they took the stamp"]},
		{"theory": {"who": "Nessa", "place": "", "hour": "1"}, "present": ["where they took the stamp"], "absent": ["who took the gilt stamp", "at which hour they took the stamp"]},
		{"theory": {"who": "Nessa", "place": "finishing_bench", "hour": ""}, "present": ["at which hour they took the stamp"], "absent": ["who took the gilt stamp", "where they took the stamp"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who took the gilt stamp", "where they took the stamp", "at which hour they took the stamp"], "absent": []},
		{"theory": {}, "present": ["who took the gilt stamp", "where they took the stamp", "at which hour they took the stamp"], "absent": []},
		{"theory": {"who": "Theo", "place": "", "hour": "3"}, "present": ["where they took the stamp"], "absent": ["who took the gilt stamp", "at which hour they took the stamp"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Gilt)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "gilt incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "gilt incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "gilt incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "gilt incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "gilt incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "gilt missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "gilt named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "gilt incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("gilt incomplete submissions refused with the missing slot")


func _player_pin_counts(book) -> Dictionary:
	var counts := {"taker": 0, "place": 0, "hour": 0}
	for exhibit in book.EXHIBITS:
		for literal in exhibit["literals"]:
			var field := str(literal["field"])
			if counts.has(field):
				counts[field] = int(counts[field]) + 1
	return counts


func _test_ferry_file_shape() -> void:
	_expect(Ferry.EXHIBITS.size() >= 6 and Ferry.EXHIBITS.size() <= 8, "ferry exhibit count is %d" % Ferry.EXHIBITS.size())
	_expect(Ferry.PEOPLE.size() == 3, "ferry cast should be three people")
	_expect(Ferry.PLACES.size() >= 3, "ferry needs a few rooms")
	_expect(Ferry.HOURS.size() >= 3 and Ferry.HOURS.size() <= 5, "ferry hour list length")
	_expect(Ferry.TITLE == "The ferry bell", "ferry title")
	_expect(Ferry.TITLE != CaseData.TITLE and Ferry.TITLE != Rehearsal.TITLE and Ferry.TITLE != Gilt.TITLE, "ferry shares a title")
	_expect(Ferry.FILE_CODE == "CW-04", "ferry file code")
	_expect(Ferry.FILE_CODE != CaseData.FILE_CODE and Ferry.FILE_CODE != Rehearsal.FILE_CODE and Ferry.FILE_CODE != Gilt.FILE_CODE, "ferry shares a file code")
	var counts := _player_pin_counts(Ferry)
	_expect(int(counts["taker"]) == 2 and int(counts["place"]) == 2 and int(counts["hour"]) == 2, "ferry pin pairs are %s" % str(counts))
	_expect(counts != _player_pin_counts(CaseData), "ferry copied the spare-key pin pattern")
	_expect(counts != _player_pin_counts(Rehearsal), "ferry copied the rehearsal pin pattern")
	_expect(counts != _player_pin_counts(Gilt), "ferry copied the gilt pin pattern")
	var seen := {}
	for exhibit in Ferry.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		_expect(not seen.has(exhibit_id), "duplicate ferry id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		for literal in exhibit["literals"]:
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Ferry.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Ferry.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Ferry.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats == 2, "%s states %s %d times" % [exhibit_id, field, repeats])
			else:
				var owners := 0
				for other in Ferry.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)


func _test_ferry_unique_model() -> void:
	var models := Solver.enumerate(Ferry.EXHIBITS, Ferry)
	print("ferry models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one ferry model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Quill", "ferry taker")
	_expect(str(model["place"]) == "rope_loft", "ferry place")
	_expect(str(model["hour"]) == "15", "ferry hour")
	_expect(str(model["whistler"]) == "Wren", "ferry whistler")
	_expect(str(model["whistle_place"]) == "jetty_shed", "ferry whistle place")
	_expect(str(model["holder"]) == "Hale", "ferry holder")
	_expect(str(model["hold_place"]) == "ticket_window", "ferry hold place")
	_expect(str(model["hold_hour"]) == "14", "ferry hold hour")
	_expect(str(model["origin"]) == "ticket_window", "ferry origin")
	_expect(str(model["purpose"]) == "call_boat", "ferry purpose")
	_expect(str(model["answer_hour"]) == "16", "ferry answer hour")
	_expect(Ferry.timeline(model) == FERRY_TIMELINE, "ferry timeline drifted:\n%s" % Ferry.timeline(model))
	for exhibit in Ferry.EXHIBITS:
		_expect(Ferry.holds(exhibit, model), "%s rejects the ferry timeline" % exhibit["id"])


func _test_ferry_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Ferry.EXHIBITS, Ferry)
	for exhibit in Ferry.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Ferry.without(exhibit_id), Ferry)
		print("ferry without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "ferry %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Ferry.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "ferry %s removal did not admit a timeline it forbids" % exhibit_id)


func _test_ferry_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	for who in Ferry.PEOPLE:
		for place in Ferry.PLACES:
			for hour in Ferry.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == FERRY_TRUE["who"] and place == FERRY_TRUE["place"] and hour == FERRY_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Ferry)
					print("ferry true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true ferry theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "ferry acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(FERRY_TIMELINE) >= 0, "ferry acceptance should give the timeline")
					_expect(Ferry.conflicting_ids(theory).is_empty(), "true ferry theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Ferry)
					rejected += 1
	print("ferry theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d ferry theories" % accepted)
	_expect(rejected >= 2, "rejected %d ferry theories" % rejected)


func _test_ferry_near_misses() -> void:
	var misses := [
		{"who": "Quill", "place": "rope_loft", "hour": "16"},
		{"who": "Quill", "place": "jetty_shed", "hour": "15"},
		{"who": "Wren", "place": "rope_loft", "hour": "15"},
	]
	for theory in misses:
		_expect_rejected(theory, Ferry)
	print("ferry near-misses rejected: %d" % misses.size())
	_expect(misses.size() >= 2, "need at least two ferry near-misses")


func _test_ferry_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
	]
	var cases := [
		{"theory": {"who": "", "place": "rope_loft", "hour": "15"}, "present": ["who took the ferry bell"], "absent": ["where they took the bell", "at which hour they took the bell"]},
		{"theory": {"who": "Quill", "place": "", "hour": "15"}, "present": ["where they took the bell"], "absent": ["who took the ferry bell", "at which hour they took the bell"]},
		{"theory": {"who": "Quill", "place": "rope_loft", "hour": ""}, "present": ["at which hour they took the bell"], "absent": ["who took the ferry bell", "where they took the bell"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who took the ferry bell", "where they took the bell", "at which hour they took the bell"], "absent": []},
		{"theory": {}, "present": ["who took the ferry bell", "where they took the bell", "at which hour they took the bell"], "absent": []},
		{"theory": {"who": "Hale", "place": "", "hour": "14"}, "present": ["where they took the bell"], "absent": ["who took the ferry bell", "at which hour they took the bell"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Ferry)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "ferry incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "ferry incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "ferry incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "ferry incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "ferry incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "ferry missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "ferry named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "ferry incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("ferry incomplete submissions refused with the missing slot")


func _test_weather_file_shape() -> void:
	_expect(Weather.EXHIBITS.size() == 8, "weather exhibit count is %d" % Weather.EXHIBITS.size())
	_expect(Weather.PEOPLE.size() == 3, "weather cast should be three people")
	_expect(Weather.PLACES.size() >= 3, "weather needs a few rooms")
	_expect(Weather.HOURS.size() >= 3 and Weather.HOURS.size() <= 5, "weather hour list length")
	_expect(Weather.TITLE == "The weather slate", "weather title")
	_expect(Weather.TITLE != CaseData.TITLE and Weather.TITLE != Rehearsal.TITLE and Weather.TITLE != Gilt.TITLE and Weather.TITLE != Ferry.TITLE, "weather shares a title")
	_expect(Weather.FILE_CODE == "CW-05", "weather file code")
	_expect(Weather.FILE_CODE != CaseData.FILE_CODE and Weather.FILE_CODE != Rehearsal.FILE_CODE and Weather.FILE_CODE != Gilt.FILE_CODE and Weather.FILE_CODE != Ferry.FILE_CODE, "weather shares a file code")
	_expect(Weather.PLACES[0] == WEATHER_TRUE["place"], "weather room should be the first room in the file")
	_expect(Weather.HOURS[Weather.HOURS.size() - 1] == WEATHER_TRUE["hour"], "weather taking should be the latest hour")
	var counts := _player_pin_counts(Weather)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 2 and int(counts["hour"]) == 3, "weather pin counts are %s" % str(counts))
	_expect(counts != _player_pin_counts(CaseData), "weather copied the spare-key pin pattern")
	_expect(counts != _player_pin_counts(Rehearsal), "weather copied the rehearsal pin pattern")
	_expect(counts != _player_pin_counts(Gilt), "weather copied the gilt pin pattern")
	_expect(counts != _player_pin_counts(Ferry), "weather copied the ferry pin pattern")
	var seen := {}
	for exhibit in Weather.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		_expect(not seen.has(exhibit_id), "duplicate weather id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		for literal in exhibit["literals"]:
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Weather.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Weather.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Weather.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				var owners := 0
				for other in Weather.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)


func _test_weather_unique_model() -> void:
	var models := Solver.enumerate(Weather.EXHIBITS, Weather)
	print("weather models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one weather model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Pim", "weather taker")
	_expect(str(model["place"]) == "map_alcove", "weather place")
	_expect(str(model["hour"]) == "12", "weather hour")
	_expect(str(model["requester"]) == "Soren", "weather requester")
	_expect(str(model["request_place"]) == "tower_stair", "weather request place")
	_expect(str(model["request_hour"]) == "10", "weather request hour")
	_expect(str(model["origin"]) == "peg_room", "weather origin")
	_expect(str(model["purpose"]) == "frost_line", "weather purpose")
	_expect(str(model["witness"]) == "Vesper", "weather witness")
	_expect(str(model["witness_place"]) == "peg_room", "weather witness place")
	_expect(str(model["chalk_hour"]) == "11", "weather chalk hour")
	_expect(Weather.timeline(model) == WEATHER_TIMELINE, "weather timeline drifted:\n%s" % Weather.timeline(model))
	for exhibit in Weather.EXHIBITS:
		_expect(Weather.holds(exhibit, model), "%s rejects the weather timeline" % exhibit["id"])


func _test_weather_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Weather.EXHIBITS, Weather)
	for exhibit in Weather.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Weather.without(exhibit_id), Weather)
		print("weather without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "weather %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Weather.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "weather %s removal did not admit a timeline it forbids" % exhibit_id)


func _test_weather_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	for who in Weather.PEOPLE:
		for place in Weather.PLACES:
			for hour in Weather.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == WEATHER_TRUE["who"] and place == WEATHER_TRUE["place"] and hour == WEATHER_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Weather)
					print("weather true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true weather theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "weather acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(WEATHER_TIMELINE) >= 0, "weather acceptance should give the timeline")
					_expect(Weather.conflicting_ids(theory).is_empty(), "true weather theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Weather)
					rejected += 1
	print("weather theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d weather theories" % accepted)
	_expect(rejected >= 2, "rejected %d weather theories" % rejected)


func _test_weather_near_misses() -> void:
	var misses := [
		{"who": "Pim", "place": "map_alcove", "hour": "11"},
		{"who": "Pim", "place": "peg_room", "hour": "12"},
		{"who": "Soren", "place": "map_alcove", "hour": "12"},
	]
	for theory in misses:
		_expect_rejected(theory, Weather)
	print("weather near-misses rejected: %d" % misses.size())
	_expect(misses.size() >= 2, "need at least two weather near-misses")


func _test_weather_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
	]
	var cases := [
		{"theory": {"who": "", "place": "map_alcove", "hour": "12"}, "present": ["who took the weather slate"], "absent": ["where they took the slate", "at which hour they took the slate"]},
		{"theory": {"who": "Pim", "place": "", "hour": "12"}, "present": ["where they took the slate"], "absent": ["who took the weather slate", "at which hour they took the slate"]},
		{"theory": {"who": "Pim", "place": "map_alcove", "hour": ""}, "present": ["at which hour they took the slate"], "absent": ["who took the weather slate", "where they took the slate"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who took the weather slate", "where they took the slate", "at which hour they took the slate"], "absent": []},
		{"theory": {}, "present": ["who took the weather slate", "where they took the slate", "at which hour they took the slate"], "absent": []},
		{"theory": {"who": "Soren", "place": "", "hour": "10"}, "present": ["where they took the slate"], "absent": ["who took the weather slate", "at which hour they took the slate"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Weather)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "weather incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "weather incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "weather incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "weather incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "weather incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "weather missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "weather named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "weather incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("weather incomplete submissions refused with the missing slot")


func _test_loom_file_shape() -> void:
	_expect(Loom.EXHIBITS.size() == 8, "loom exhibit count is %d" % Loom.EXHIBITS.size())
	_expect(Loom.PEOPLE.size() == 3, "loom cast should be three people")
	_expect(Loom.PLACES.size() >= 3, "loom needs a few rooms")
	_expect(Loom.HOURS.size() == 4, "loom hour list length is %d" % Loom.HOURS.size())
	_expect(Loom.TITLE == "The loom shuttle", "loom title")
	_expect(Loom.TITLE != CaseData.TITLE and Loom.TITLE != Rehearsal.TITLE and Loom.TITLE != Gilt.TITLE and Loom.TITLE != Ferry.TITLE and Loom.TITLE != Weather.TITLE, "loom shares a title")
	_expect(Loom.FILE_CODE == "CW-06", "loom file code")
	_expect(Loom.FILE_CODE != CaseData.FILE_CODE and Loom.FILE_CODE != Rehearsal.FILE_CODE and Loom.FILE_CODE != Gilt.FILE_CODE and Loom.FILE_CODE != Ferry.FILE_CODE and Loom.FILE_CODE != Weather.FILE_CODE, "loom shares a file code")
	_expect(Loom.HOURS[0] != LOOM_TRUE["hour"], "loom taking should not be the earliest hour")
	_expect(Loom.HOURS[Loom.HOURS.size() - 1] != LOOM_TRUE["hour"], "loom taking should not be the latest hour")
	_expect(Loom.HOURS.has("18"), "loom board is missing 18")
	var counts := _player_pin_counts(Loom)
	_expect(int(counts["taker"]) == 2 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "loom pin counts are %s" % str(counts))
	_expect(counts != _player_pin_counts(CaseData), "loom copied the spare-key pin pattern")
	_expect(counts != _player_pin_counts(Rehearsal), "loom copied the rehearsal pin pattern")
	_expect(counts != _player_pin_counts(Gilt), "loom copied the gilt pin pattern")
	_expect(counts != _player_pin_counts(Ferry), "loom copied the ferry pin pattern")
	_expect(counts != _player_pin_counts(Weather), "loom copied the weather pin pattern")
	var seen := {}
	var states_blank := false
	for exhibit in Loom.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		_expect(not seen.has(exhibit_id), "duplicate loom id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		for literal in exhibit["literals"]:
			if str(literal["value"]) == "18":
				states_blank = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Loom.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Loom.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Loom.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				var owners := 0
				for other in Loom.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(not states_blank, "18 is stated by an exhibit")


func _test_loom_unique_model() -> void:
	var models := Solver.enumerate(Loom.EXHIBITS, Loom)
	print("loom models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one loom model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Fenn", "loom taker")
	_expect(str(model["place"]) == "pattern_loft", "loom place")
	_expect(str(model["hour"]) == "19", "loom hour")
	_expect(str(model["marker"]) == "Joss", "loom marker")
	_expect(str(model["mark_place"]) == "dye_house", "loom mark place")
	_expect(str(model["mark_hour"]) == "17", "loom mark hour")
	_expect(str(model["origin"]) == "loom_room", "loom origin")
	_expect(str(model["purpose"]) == "match_border", "loom purpose")
	_expect(str(model["returner"]) == "Rue", "loom returner")
	_expect(str(model["return_place"]) == "loom_room", "loom return place")
	_expect(str(model["return_hour"]) == "20", "loom return hour")
	for field in Loom.fields():
		_expect(str(model[field]) != "18", "true timeline uses the blank hour for %s" % field)
	_expect(Loom.timeline(model) == LOOM_TIMELINE, "loom timeline drifted:\n%s" % Loom.timeline(model))
	for exhibit in Loom.EXHIBITS:
		_expect(Loom.holds(exhibit, model), "%s rejects the loom timeline" % exhibit["id"])


func _test_loom_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Loom.EXHIBITS, Loom)
	for exhibit in Loom.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Loom.without(exhibit_id), Loom)
		print("loom without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "loom %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Loom.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "loom %s removal did not admit a timeline it forbids" % exhibit_id)


func _test_loom_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	for who in Loom.PEOPLE:
		for place in Loom.PLACES:
			for hour in Loom.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == LOOM_TRUE["who"] and place == LOOM_TRUE["place"] and hour == LOOM_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Loom)
					print("loom true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true loom theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "loom acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(LOOM_TIMELINE) >= 0, "loom acceptance should give the timeline")
					_expect(Loom.conflicting_ids(theory).is_empty(), "true loom theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Loom)
					rejected += 1
	print("loom theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d loom theories" % accepted)
	_expect(rejected >= 2, "rejected %d loom theories" % rejected)


func _test_loom_near_misses() -> void:
	var misses := [
		{"who": "Fenn", "place": "pattern_loft", "hour": "18"},
		{"who": "Fenn", "place": "pattern_loft", "hour": "20"},
		{"who": "Fenn", "place": "loom_room", "hour": "19"},
		{"who": "Joss", "place": "pattern_loft", "hour": "19"},
	]
	for theory in misses:
		_expect_rejected(theory, Loom)
	print("loom near-misses rejected: %d" % misses.size())
	_expect(misses.size() >= 2, "need at least two loom near-misses")


func _test_loom_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
	]
	var cases := [
		{"theory": {"who": "", "place": "pattern_loft", "hour": "19"}, "present": ["who took the loom shuttle"], "absent": ["where they took the shuttle", "at which hour they took the shuttle"]},
		{"theory": {"who": "Fenn", "place": "", "hour": "19"}, "present": ["where they took the shuttle"], "absent": ["who took the loom shuttle", "at which hour they took the shuttle"]},
		{"theory": {"who": "Fenn", "place": "pattern_loft", "hour": ""}, "present": ["at which hour they took the shuttle"], "absent": ["who took the loom shuttle", "where they took the shuttle"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who took the loom shuttle", "where they took the shuttle", "at which hour they took the shuttle"], "absent": []},
		{"theory": {}, "present": ["who took the loom shuttle", "where they took the shuttle", "at which hour they took the shuttle"], "absent": []},
		{"theory": {"who": "Rue", "place": "", "hour": "18"}, "present": ["where they took the shuttle"], "absent": ["who took the loom shuttle", "at which hour they took the shuttle"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Loom)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "loom incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "loom incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "loom incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "loom incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "loom incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "loom missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "loom named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "loom incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("loom incomplete submissions refused with the missing slot")


func _field_key(book) -> String:
	var names := PackedStringArray()
	for field in book.fields():
		names.append(str(field))
	names.sort()
	return "|".join(names)


func _test_hive_file_shape() -> void:
	_expect(Hive.EXHIBITS.size() == 8, "hive exhibit count is %d" % Hive.EXHIBITS.size())
	_expect(Hive.PEOPLE.size() == 3, "hive cast should be three people")
	_expect(Hive.PLACES.size() >= 3, "hive needs a few rooms")
	_expect(Hive.HOURS.size() == 4, "hive hour list length is %d" % Hive.HOURS.size())
	_expect(Hive.TITLE == "The hive smoker", "hive title")
	_expect(Hive.TITLE != CaseData.TITLE and Hive.TITLE != Rehearsal.TITLE and Hive.TITLE != Gilt.TITLE and Hive.TITLE != Ferry.TITLE and Hive.TITLE != Weather.TITLE and Hive.TITLE != Loom.TITLE, "hive shares a title")
	_expect(Hive.FILE_CODE == "CW-07", "hive file code")
	_expect(Hive.FILE_CODE != CaseData.FILE_CODE and Hive.FILE_CODE != Rehearsal.FILE_CODE and Hive.FILE_CODE != Gilt.FILE_CODE and Hive.FILE_CODE != Ferry.FILE_CODE and Hive.FILE_CODE != Weather.FILE_CODE and Hive.FILE_CODE != Loom.FILE_CODE, "hive shares a file code")
	_expect(Hive.HOURS[1] == HIVE_TRUE["hour"], "hive taking should be the second hour")
	_expect(Hive.HOURS[0] != HIVE_TRUE["hour"], "hive taking should not be the earliest hour")
	_expect(Hive.HOURS[Hive.HOURS.size() - 1] != HIVE_TRUE["hour"], "hive taking should not be the latest hour")
	var counts := _player_pin_counts(Hive)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 2, "hive pin counts are %s" % str(counts))
	_expect(counts != _player_pin_counts(CaseData), "hive copied the spare-key pin pattern")
	_expect(counts != _player_pin_counts(Rehearsal), "hive copied the rehearsal pin pattern")
	_expect(counts != _player_pin_counts(Gilt), "hive copied the gilt pin pattern")
	_expect(counts != _player_pin_counts(Ferry), "hive copied the ferry pin pattern")
	_expect(counts != _player_pin_counts(Weather), "hive copied the weather pin pattern")
	_expect(counts != _player_pin_counts(Loom), "hive copied the loom pin pattern")
	_expect(_field_key(Hive) != _field_key(CaseData), "hive copied the spare-key timeline fields")
	_expect(_field_key(Hive) != _field_key(Rehearsal), "hive copied the rehearsal timeline fields")
	_expect(_field_key(Hive) != _field_key(Gilt), "hive copied the gilt timeline fields")
	_expect(_field_key(Hive) != _field_key(Ferry), "hive copied the ferry timeline fields")
	_expect(_field_key(Hive) != _field_key(Weather), "hive copied the weather timeline fields")
	_expect(_field_key(Hive) != _field_key(Loom), "hive copied the loom timeline fields")
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	for exhibit in Hive.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		_expect(not seen.has(exhibit_id), "duplicate hive id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Hive.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Hive.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Hive.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Hive.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 1, "hive should have one slip with two hidden facts, found %d" % paired_hidden)
	for hour in Hive.HOURS:
		_expect(stated.has(hour), "hive hour %s is absent from the exhibits" % hour)


func _test_hive_unique_model() -> void:
	var models := Solver.enumerate(Hive.EXHIBITS, Hive)
	print("hive models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one hive model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Tamsin", "hive taker")
	_expect(str(model["place"]) == "honey_room", "hive place")
	_expect(str(model["hour"]) == "22", "hive hour")
	_expect(str(model["filler"]) == "Ned", "hive filler")
	_expect(str(model["fill_place"]) == "veil_loft", "hive fill place")
	_expect(str(model["logger"]) == "Isla", "hive logger")
	_expect(str(model["log_place"]) == "honey_room", "hive log place")
	_expect(str(model["log_hour"]) == "21", "hive log hour")
	_expect(str(model["origin"]) == "hive_shed", "hive origin")
	_expect(str(model["purpose"]) == "quiet_swarm", "hive purpose")
	_expect(str(model["spent_hour"]) == "23", "hive spent hour")
	_expect(str(model["veil_hour"]) == "24", "hive veil hour")
	for hour in Hive.HOURS:
		var used := false
		for field in Hive.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "hive hour %s is blank in the true timeline" % hour)
	_expect(Hive.timeline(model) == HIVE_TIMELINE, "hive timeline drifted:\n%s" % Hive.timeline(model))
	for exhibit in Hive.EXHIBITS:
		_expect(Hive.holds(exhibit, model), "%s rejects the hive timeline" % exhibit["id"])


func _test_hive_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Hive.EXHIBITS, Hive)
	for exhibit in Hive.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Hive.without(exhibit_id), Hive)
		print("hive without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "hive %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Hive.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "hive %s removal did not admit a timeline it forbids" % exhibit_id)


func _test_hive_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	for who in Hive.PEOPLE:
		for place in Hive.PLACES:
			for hour in Hive.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == HIVE_TRUE["who"] and place == HIVE_TRUE["place"] and hour == HIVE_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Hive)
					print("hive true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true hive theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "hive acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(HIVE_TIMELINE) >= 0, "hive acceptance should give the timeline")
					_expect(Hive.conflicting_ids(theory).is_empty(), "true hive theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Hive)
					rejected += 1
	print("hive theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d hive theories" % accepted)
	_expect(rejected >= 2, "rejected %d hive theories" % rejected)


func _test_hive_near_misses() -> void:
	var misses := [
		{"who": "Tamsin", "place": "honey_room", "hour": "24"},
		{"who": "Tamsin", "place": "honey_room", "hour": "21"},
		{"who": "Tamsin", "place": "hive_shed", "hour": "22"},
		{"who": "Ned", "place": "honey_room", "hour": "22"},
	]
	for theory in misses:
		_expect_rejected(theory, Hive)
	print("hive near-misses rejected: %d" % misses.size())
	_expect(misses.size() >= 2, "need at least two hive near-misses")


func _test_hive_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
	]
	var cases := [
		{"theory": {"who": "", "place": "honey_room", "hour": "22"}, "present": ["who took the hive smoker"], "absent": ["where they took the smoker", "at which hour they took the smoker"]},
		{"theory": {"who": "Tamsin", "place": "", "hour": "22"}, "present": ["where they took the smoker"], "absent": ["who took the hive smoker", "at which hour they took the smoker"]},
		{"theory": {"who": "Tamsin", "place": "honey_room", "hour": ""}, "present": ["at which hour they took the smoker"], "absent": ["who took the hive smoker", "where they took the smoker"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who took the hive smoker", "where they took the smoker", "at which hour they took the smoker"], "absent": []},
		{"theory": {}, "present": ["who took the hive smoker", "where they took the smoker", "at which hour they took the smoker"], "absent": []},
		{"theory": {"who": "Isla", "place": "", "hour": "24"}, "present": ["where they took the smoker"], "absent": ["who took the hive smoker", "at which hour they took the smoker"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Hive)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "hive incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "hive incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "hive incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "hive incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "hive incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "hive missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "hive named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "hive incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("hive incomplete submissions refused with the missing slot")


func _test_glass_file_shape() -> void:
	_expect(Glass.EXHIBITS.size() == 8, "glass exhibit count is %d" % Glass.EXHIBITS.size())
	_expect(Glass.PEOPLE.size() == 3, "glass cast should be three people")
	_expect(Glass.PLACES.size() == 3, "glass room count is %d" % Glass.PLACES.size())
	_expect(Glass.HOURS.size() == 5, "glass hour list length is %d" % Glass.HOURS.size())
	_expect(Glass.TITLE == "The glass pontil", "glass title")
	_expect(Glass.TITLE != CaseData.TITLE and Glass.TITLE != Rehearsal.TITLE and Glass.TITLE != Gilt.TITLE and Glass.TITLE != Ferry.TITLE and Glass.TITLE != Weather.TITLE and Glass.TITLE != Loom.TITLE and Glass.TITLE != Hive.TITLE, "glass shares a title")
	_expect(Glass.FILE_CODE == "CW-08", "glass file code")
	_expect(Glass.FILE_CODE != CaseData.FILE_CODE and Glass.FILE_CODE != Rehearsal.FILE_CODE and Glass.FILE_CODE != Gilt.FILE_CODE and Glass.FILE_CODE != Ferry.FILE_CODE and Glass.FILE_CODE != Weather.FILE_CODE and Glass.FILE_CODE != Loom.FILE_CODE and Glass.FILE_CODE != Hive.FILE_CODE, "glass shares a file code")
	_expect(Glass.HOURS[Glass.HOURS.size() / 2] == GLASS_TRUE["hour"], "glass taking should be the middle hour")
	_expect(Glass.HOURS[0] != GLASS_TRUE["hour"], "glass taking should not be the earliest hour")
	_expect(Glass.HOURS[Glass.HOURS.size() - 1] != GLASS_TRUE["hour"], "glass taking should not be the latest hour")
	var counts := _player_pin_counts(Glass)
	_expect(int(counts["taker"]) == 2 and int(counts["place"]) == 2 and int(counts["hour"]) == 4, "glass pin counts are %s" % str(counts))
	_expect(counts != _player_pin_counts(CaseData), "glass copied the spare-key pin pattern")
	_expect(counts != _player_pin_counts(Rehearsal), "glass copied the rehearsal pin pattern")
	_expect(counts != _player_pin_counts(Gilt), "glass copied the gilt pin pattern")
	_expect(counts != _player_pin_counts(Ferry), "glass copied the ferry pin pattern")
	_expect(counts != _player_pin_counts(Weather), "glass copied the weather pin pattern")
	_expect(counts != _player_pin_counts(Loom), "glass copied the loom pin pattern")
	_expect(counts != _player_pin_counts(Hive), "glass copied the hive pin pattern")
	_expect(_field_key(Glass) != _field_key(CaseData), "glass copied the spare-key timeline fields")
	_expect(_field_key(Glass) != _field_key(Rehearsal), "glass copied the rehearsal timeline fields")
	_expect(_field_key(Glass) != _field_key(Gilt), "glass copied the gilt timeline fields")
	_expect(_field_key(Glass) != _field_key(Ferry), "glass copied the ferry timeline fields")
	_expect(_field_key(Glass) != _field_key(Weather), "glass copied the weather timeline fields")
	_expect(_field_key(Glass) != _field_key(Loom), "glass copied the loom timeline fields")
	_expect(_field_key(Glass) != _field_key(Hive), "glass copied the hive timeline fields")
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	for exhibit in Glass.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		_expect(not seen.has(exhibit_id), "duplicate glass id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Glass.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Glass.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Glass.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Glass.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "glass should have two slips with two hidden facts, found %d" % paired_hidden)
	for hour in Glass.HOURS:
		_expect(stated.has(hour), "glass hour %s is absent from the exhibits" % hour)


func _test_glass_unique_model() -> void:
	var models := Solver.enumerate(Glass.EXHIBITS, Glass)
	print("glass models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one glass model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Sable", "glass taker")
	_expect(str(model["place"]) == "lehr_room", "glass place")
	_expect(str(model["hour"]) == "27", "glass hour")
	_expect(str(model["chalker"]) == "Hugh", "glass chalker")
	_expect(str(model["chalk_place"]) == "pot_arch", "glass chalk place")
	_expect(str(model["chalk_hour"]) == "25", "glass chalk hour")
	_expect(str(model["opener"]) == "Orla", "glass opener")
	_expect(str(model["open_hour"]) == "26", "glass open hour")
	_expect(str(model["origin"]) == "glory_hole", "glass origin")
	_expect(str(model["purpose"]) == "crack_pontil", "glass purpose")
	_expect(str(model["roll_place"]) == "glory_hole", "glass roll place")
	_expect(str(model["shear_hour"]) == "28", "glass shear hour")
	_expect(str(model["close_hour"]) == "29", "glass close hour")
	for hour in Glass.HOURS:
		var used := false
		for field in Glass.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "glass hour %s is blank in the true timeline" % hour)
	for place in Glass.PLACES:
		var place_used := false
		for field in Glass.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "glass room %s is blank in the true timeline" % place)
	for person in Glass.PEOPLE:
		var person_used := false
		for field in Glass.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "glass person %s is blank in the true timeline" % person)
	_expect(Glass.timeline(model) == GLASS_TIMELINE, "glass timeline drifted:\n%s" % Glass.timeline(model))
	for exhibit in Glass.EXHIBITS:
		_expect(Glass.holds(exhibit, model), "%s rejects the glass timeline" % exhibit["id"])


func _test_glass_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Glass.EXHIBITS, Glass)
	for exhibit in Glass.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Glass.without(exhibit_id), Glass)
		print("glass without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "glass %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Glass.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "glass %s removal did not admit a timeline it forbids" % exhibit_id)


func _test_glass_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	for who in Glass.PEOPLE:
		for place in Glass.PLACES:
			for hour in Glass.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == GLASS_TRUE["who"] and place == GLASS_TRUE["place"] and hour == GLASS_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Glass)
					print("glass true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true glass theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "glass acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(GLASS_TIMELINE) >= 0, "glass acceptance should give the timeline")
					_expect(Glass.conflicting_ids(theory).is_empty(), "true glass theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Glass)
					rejected += 1
	print("glass theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d glass theories" % accepted)
	_expect(rejected >= 2, "rejected %d glass theories" % rejected)


func _test_glass_near_misses() -> void:
	var misses := [
		{"who": "Sable", "place": "lehr_room", "hour": "28"},
		{"who": "Sable", "place": "lehr_room", "hour": "25"},
		{"who": "Sable", "place": "glory_hole", "hour": "27"},
		{"who": "Hugh", "place": "lehr_room", "hour": "27"},
	]
	for theory in misses:
		_expect_rejected(theory, Glass)
	print("glass near-misses rejected: %d" % misses.size())
	_expect(misses.size() >= 2, "need at least two glass near-misses")


func _test_glass_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
	]
	var cases := [
		{"theory": {"who": "", "place": "lehr_room", "hour": "27"}, "present": ["who took the glass pontil"], "absent": ["where they took the pontil", "at which hour they took the pontil"]},
		{"theory": {"who": "Sable", "place": "", "hour": "27"}, "present": ["where they took the pontil"], "absent": ["who took the glass pontil", "at which hour they took the pontil"]},
		{"theory": {"who": "Sable", "place": "lehr_room", "hour": ""}, "present": ["at which hour they took the pontil"], "absent": ["who took the glass pontil", "where they took the pontil"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who took the glass pontil", "where they took the pontil", "at which hour they took the pontil"], "absent": []},
		{"theory": {}, "present": ["who took the glass pontil", "where they took the pontil", "at which hour they took the pontil"], "absent": []},
		{"theory": {"who": "Hugh", "place": "", "hour": "29"}, "present": ["where they took the pontil"], "absent": ["who took the glass pontil", "at which hour they took the pontil"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Glass)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "glass incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "glass incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "glass incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "glass incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "glass incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "glass missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "glass named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "glass incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("glass incomplete submissions refused with the missing slot")


func _test_press_file_shape() -> void:
	_expect(Press.EXHIBITS.size() == 8, "press exhibit count is %d" % Press.EXHIBITS.size())
	_expect(Press.PEOPLE.size() == 3, "press cast should be three people")
	_expect(Press.PLACES.size() == 3, "press room count is %d" % Press.PLACES.size())
	_expect(Press.HOURS.size() == 5, "press hour list length is %d" % Press.HOURS.size())
	_expect(Press.TITLE == "The press proof", "press title")
	_expect(Press.TITLE != CaseData.TITLE and Press.TITLE != Rehearsal.TITLE and Press.TITLE != Gilt.TITLE and Press.TITLE != Ferry.TITLE and Press.TITLE != Weather.TITLE and Press.TITLE != Loom.TITLE and Press.TITLE != Hive.TITLE and Press.TITLE != Glass.TITLE, "press shares a title")
	_expect(Press.FILE_CODE == "CW-09", "press file code")
	_expect(Press.FILE_CODE != CaseData.FILE_CODE and Press.FILE_CODE != Rehearsal.FILE_CODE and Press.FILE_CODE != Gilt.FILE_CODE and Press.FILE_CODE != Ferry.FILE_CODE and Press.FILE_CODE != Weather.FILE_CODE and Press.FILE_CODE != Loom.FILE_CODE and Press.FILE_CODE != Hive.FILE_CODE and Press.FILE_CODE != Glass.FILE_CODE, "press shares a file code")
	_expect(Press.HOURS[Press.HOURS.size() / 2] == PRESS_TRUE["hour"], "press taking should be the middle hour")
	_expect(Press.HOURS[0] != PRESS_TRUE["hour"], "press taking should not be the earliest hour")
	_expect(Press.HOURS[Press.HOURS.size() - 1] != PRESS_TRUE["hour"], "press taking should not be the latest hour")
	var counts := _player_pin_counts(Press)
	_expect(int(counts["taker"]) == 4 and int(counts["place"]) == 2 and int(counts["hour"]) == 2, "press pin counts are %s" % str(counts))
	_expect(counts != _player_pin_counts(CaseData), "press copied the spare-key pin pattern")
	_expect(counts != _player_pin_counts(Rehearsal), "press copied the rehearsal pin pattern")
	_expect(counts != _player_pin_counts(Gilt), "press copied the gilt pin pattern")
	_expect(counts != _player_pin_counts(Ferry), "press copied the ferry pin pattern")
	_expect(counts != _player_pin_counts(Weather), "press copied the weather pin pattern")
	_expect(counts != _player_pin_counts(Loom), "press copied the loom pin pattern")
	_expect(counts != _player_pin_counts(Hive), "press copied the hive pin pattern")
	_expect(counts != _player_pin_counts(Glass), "press copied the glass pin pattern")
	_expect(_field_key(Press) != _field_key(CaseData), "press copied the spare-key timeline fields")
	_expect(_field_key(Press) != _field_key(Rehearsal), "press copied the rehearsal timeline fields")
	_expect(_field_key(Press) != _field_key(Gilt), "press copied the gilt timeline fields")
	_expect(_field_key(Press) != _field_key(Ferry), "press copied the ferry timeline fields")
	_expect(_field_key(Press) != _field_key(Weather), "press copied the weather timeline fields")
	_expect(_field_key(Press) != _field_key(Loom), "press copied the loom timeline fields")
	_expect(_field_key(Press) != _field_key(Hive), "press copied the hive timeline fields")
	_expect(_field_key(Press) != _field_key(Glass), "press copied the glass timeline fields")
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	for exhibit in Press.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		_expect(not seen.has(exhibit_id), "duplicate press id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Press.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Press.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Press.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Press.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "press should have two slips with two hidden facts, found %d" % paired_hidden)
	for hour in Press.HOURS:
		_expect(stated.has(hour), "press hour %s is absent from the exhibits" % hour)


func _test_press_unique_model() -> void:
	var models := Solver.enumerate(Press.EXHIBITS, Press)
	print("press models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one press model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Nim", "press taker")
	_expect(str(model["place"]) == "stone", "press place")
	_expect(str(model["hour"]) == "41", "press hour")
	_expect(str(model["damper"]) == "Brin", "press damper")
	_expect(str(model["damp_place"]) == "wetting_board", "press damp place")
	_expect(str(model["damp_hour"]) == "39", "press damp hour")
	_expect(str(model["lifter"]) == "Cass", "press lifter")
	_expect(str(model["lift_hour"]) == "40", "press lift hour")
	_expect(str(model["origin"]) == "galley", "press origin")
	_expect(str(model["purpose"]) == "lock_forme", "press purpose")
	_expect(str(model["plane_place"]) == "galley", "press plane place")
	_expect(str(model["frisket_hour"]) == "42", "press frisket hour")
	_expect(str(model["tympan_hour"]) == "43", "press tympan hour")
	for hour in Press.HOURS:
		var used := false
		for field in Press.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "press hour %s is blank in the true timeline" % hour)
	for place in Press.PLACES:
		var place_used := false
		for field in Press.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "press room %s is blank in the true timeline" % place)
	for person in Press.PEOPLE:
		var person_used := false
		for field in Press.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "press person %s is blank in the true timeline" % person)
	_expect(Press.timeline(model) == PRESS_TIMELINE, "press timeline drifted:\n%s" % Press.timeline(model))
	for exhibit in Press.EXHIBITS:
		_expect(Press.holds(exhibit, model), "%s rejects the press timeline" % exhibit["id"])


func _test_press_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Press.EXHIBITS, Press)
	for exhibit in Press.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Press.without(exhibit_id), Press)
		print("press without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "press %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Press.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "press %s removal did not admit a timeline it forbids" % exhibit_id)


func _test_press_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	for who in Press.PEOPLE:
		for place in Press.PLACES:
			for hour in Press.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == PRESS_TRUE["who"] and place == PRESS_TRUE["place"] and hour == PRESS_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Press)
					print("press true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true press theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "press acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(PRESS_TIMELINE) >= 0, "press acceptance should give the timeline")
					_expect(Press.conflicting_ids(theory).is_empty(), "true press theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Press)
					rejected += 1
	print("press theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d press theories" % accepted)
	_expect(rejected >= 2, "rejected %d press theories" % rejected)


func _test_press_near_misses() -> void:
	var misses := [
		{"who": "Nim", "place": "stone", "hour": "42"},
		{"who": "Nim", "place": "stone", "hour": "39"},
		{"who": "Nim", "place": "galley", "hour": "41"},
		{"who": "Brin", "place": "stone", "hour": "41"},
	]
	var wrong_hour_on_stone := 0
	var wrong_place_at_hour := 0
	for theory in misses:
		_expect_rejected(theory, Press)
		if str(theory["who"]) == "Nim" and str(theory["place"]) == "stone" and str(theory["hour"]) != "41":
			wrong_hour_on_stone += 1
		if str(theory["who"]) == "Nim" and str(theory["place"]) != "stone" and str(theory["hour"]) == "41":
			wrong_place_at_hour += 1
	print("press near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four press near-misses, found %d" % misses.size())
	_expect(wrong_hour_on_stone >= 1, "a near-miss should keep Nim on the stone at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Nim at 41 in another room")


func _test_press_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
	]
	var cases := [
		{"theory": {"who": "", "place": "stone", "hour": "41"}, "present": ["who took the press proof"], "absent": ["where they took the proof", "at which hour they took the proof"]},
		{"theory": {"who": "Nim", "place": "", "hour": "41"}, "present": ["where they took the proof"], "absent": ["who took the press proof", "at which hour they took the proof"]},
		{"theory": {"who": "Nim", "place": "stone", "hour": ""}, "present": ["at which hour they took the proof"], "absent": ["who took the press proof", "where they took the proof"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who took the press proof", "where they took the proof", "at which hour they took the proof"], "absent": []},
		{"theory": {}, "present": ["who took the press proof", "where they took the proof", "at which hour they took the proof"], "absent": []},
		{"theory": {"who": "Cass", "place": "", "hour": "43"}, "present": ["where they took the proof"], "absent": ["who took the press proof", "at which hour they took the proof"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Press)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "press incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "press incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "press incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "press incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "press incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "press missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "press named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "press incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("press incomplete submissions refused with the missing slot")


func _test_assay_file_shape() -> void:
	_expect(Assay.EXHIBITS.size() == 8, "assay exhibit count is %d" % Assay.EXHIBITS.size())
	_expect(Assay.PEOPLE.size() == 3, "assay cast should be three people")
	_expect(Assay.PLACES.size() == 3, "assay room count is %d" % Assay.PLACES.size())
	_expect(Assay.HOURS.size() == 5, "assay hour list length is %d" % Assay.HOURS.size())
	_expect(Assay.TITLE == "The assay cup", "assay title")
	_expect(Assay.TITLE != CaseData.TITLE and Assay.TITLE != Rehearsal.TITLE and Assay.TITLE != Gilt.TITLE and Assay.TITLE != Ferry.TITLE and Assay.TITLE != Weather.TITLE and Assay.TITLE != Loom.TITLE and Assay.TITLE != Hive.TITLE and Assay.TITLE != Glass.TITLE and Assay.TITLE != Press.TITLE, "assay shares a title")
	_expect(Assay.FILE_CODE == "CW-10", "assay file code")
	_expect(Assay.FILE_CODE != CaseData.FILE_CODE and Assay.FILE_CODE != Rehearsal.FILE_CODE and Assay.FILE_CODE != Gilt.FILE_CODE and Assay.FILE_CODE != Ferry.FILE_CODE and Assay.FILE_CODE != Weather.FILE_CODE and Assay.FILE_CODE != Loom.FILE_CODE and Assay.FILE_CODE != Hive.FILE_CODE and Assay.FILE_CODE != Glass.FILE_CODE and Assay.FILE_CODE != Press.FILE_CODE, "assay shares a file code")
	_expect(Assay.HOURS[Assay.HOURS.size() / 2] == ASSAY_TRUE["hour"], "assay setting should be the middle hour")
	_expect(Assay.HOURS[0] != ASSAY_TRUE["hour"], "assay setting should not be the earliest hour")
	_expect(Assay.HOURS[Assay.HOURS.size() - 1] != ASSAY_TRUE["hour"], "assay setting should not be the latest hour")
	var counts := _player_pin_counts(Assay)
	_expect(int(counts["taker"]) == 2 and int(counts["place"]) == 4 and int(counts["hour"]) == 2, "assay pin counts are %s" % str(counts))
	_expect(counts != _player_pin_counts(CaseData), "assay copied the spare-key pin pattern")
	_expect(counts != _player_pin_counts(Rehearsal), "assay copied the rehearsal pin pattern")
	_expect(counts != _player_pin_counts(Gilt), "assay copied the gilt pin pattern")
	_expect(counts != _player_pin_counts(Ferry), "assay copied the ferry pin pattern")
	_expect(counts != _player_pin_counts(Weather), "assay copied the weather pin pattern")
	_expect(counts != _player_pin_counts(Loom), "assay copied the loom pin pattern")
	_expect(counts != _player_pin_counts(Hive), "assay copied the hive pin pattern")
	_expect(counts != _player_pin_counts(Glass), "assay copied the glass pin pattern")
	_expect(counts != _player_pin_counts(Press), "assay copied the press pin pattern")
	_expect(_field_key(Assay) != _field_key(CaseData), "assay copied the spare-key timeline fields")
	_expect(_field_key(Assay) != _field_key(Rehearsal), "assay copied the rehearsal timeline fields")
	_expect(_field_key(Assay) != _field_key(Gilt), "assay copied the gilt timeline fields")
	_expect(_field_key(Assay) != _field_key(Ferry), "assay copied the ferry timeline fields")
	_expect(_field_key(Assay) != _field_key(Weather), "assay copied the weather timeline fields")
	_expect(_field_key(Assay) != _field_key(Loom), "assay copied the loom timeline fields")
	_expect(_field_key(Assay) != _field_key(Hive), "assay copied the hive timeline fields")
	_expect(_field_key(Assay) != _field_key(Glass), "assay copied the glass timeline fields")
	_expect(_field_key(Assay) != _field_key(Press), "assay copied the press timeline fields")
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	for exhibit in Assay.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		_expect(not seen.has(exhibit_id), "duplicate assay id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Assay.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Assay.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Assay.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Assay.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "assay should have two slips with two hidden facts, found %d" % paired_hidden)
	for hour in Assay.HOURS:
		_expect(stated.has(hour), "assay hour %s is absent from the exhibits" % hour)


func _test_assay_unique_model() -> void:
	var models := Solver.enumerate(Assay.EXHIBITS, Assay)
	print("assay models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one assay model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Lark", "assay taker")
	_expect(str(model["place"]) == "scale", "assay place")
	_expect(str(model["hour"]) == "16", "assay hour")
	_expect(str(model["packer"]) == "Cress", "assay packer")
	_expect(str(model["pack_place"]) == "flux_bench", "assay pack place")
	_expect(str(model["pack_hour"]) == "14", "assay pack hour")
	_expect(str(model["drawer"]) == "Tor", "assay drawer")
	_expect(str(model["draw_hour"]) == "15", "assay draw hour")
	_expect(str(model["origin"]) == "muffle", "assay origin")
	_expect(str(model["purpose"]) == "read_light", "assay purpose")
	_expect(str(model["part_place"]) == "muffle", "assay part place")
	_expect(str(model["stir_hour"]) == "17", "assay stir hour")
	_expect(str(model["quench_hour"]) == "18", "assay quench hour")
	for hour in Assay.HOURS:
		var used := false
		for field in Assay.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "assay hour %s is blank in the true timeline" % hour)
	for place in Assay.PLACES:
		var place_used := false
		for field in Assay.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "assay room %s is blank in the true timeline" % place)
	for person in Assay.PEOPLE:
		var person_used := false
		for field in Assay.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "assay person %s is blank in the true timeline" % person)
	_expect(Assay.timeline(model) == ASSAY_TIMELINE, "assay timeline drifted:\n%s" % Assay.timeline(model))
	for exhibit in Assay.EXHIBITS:
		_expect(Assay.holds(exhibit, model), "%s rejects the assay timeline" % exhibit["id"])


func _test_assay_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Assay.EXHIBITS, Assay)
	for exhibit in Assay.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Assay.without(exhibit_id), Assay)
		print("assay without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "assay %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Assay.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "assay %s removal did not admit a timeline it forbids" % exhibit_id)


func _test_assay_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	for who in Assay.PEOPLE:
		for place in Assay.PLACES:
			for hour in Assay.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == ASSAY_TRUE["who"] and place == ASSAY_TRUE["place"] and hour == ASSAY_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Assay)
					print("assay true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true assay theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "assay acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(ASSAY_TIMELINE) >= 0, "assay acceptance should give the timeline")
					_expect(str(result["message"]).find("Lark") >= 0, "assay acceptance omits Lark")
					_expect(str(result["message"]).find("scale") >= 0, "assay acceptance omits the scale")
					_expect(str(result["message"]).find("16") >= 0, "assay acceptance omits 16")
					_expect(Assay.conflicting_ids(theory).is_empty(), "true assay theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Assay)
					rejected += 1
	print("assay theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d assay theories" % accepted)
	_expect(rejected >= 2, "rejected %d assay theories" % rejected)


func _test_assay_near_misses() -> void:
	var misses := [
		{"who": "Lark", "place": "scale", "hour": "17"},
		{"who": "Lark", "place": "scale", "hour": "14"},
		{"who": "Lark", "place": "muffle", "hour": "16"},
		{"who": "Cress", "place": "scale", "hour": "16"},
	]
	var wrong_hour_on_scale := 0
	var wrong_place_at_hour := 0
	for theory in misses:
		_expect_rejected(theory, Assay)
		if str(theory["who"]) == "Lark" and str(theory["place"]) == "scale" and str(theory["hour"]) != "16":
			wrong_hour_on_scale += 1
		if str(theory["who"]) == "Lark" and str(theory["place"]) != "scale" and str(theory["hour"]) == "16":
			wrong_place_at_hour += 1
	print("assay near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four assay near-misses, found %d" % misses.size())
	_expect(wrong_hour_on_scale >= 1, "a near-miss should keep Lark on the scale at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Lark at 16 in another room")


func _test_assay_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
	]
	var cases := [
		{"theory": {"who": "", "place": "scale", "hour": "16"}, "present": ["who set the assay cup"], "absent": ["where they set the cup", "at which hour they set the cup"]},
		{"theory": {"who": "Lark", "place": "", "hour": "16"}, "present": ["where they set the cup"], "absent": ["who set the assay cup", "at which hour they set the cup"]},
		{"theory": {"who": "Lark", "place": "scale", "hour": ""}, "present": ["at which hour they set the cup"], "absent": ["who set the assay cup", "where they set the cup"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who set the assay cup", "where they set the cup", "at which hour they set the cup"], "absent": []},
		{"theory": {}, "present": ["who set the assay cup", "where they set the cup", "at which hour they set the cup"], "absent": []},
		{"theory": {"who": "Tor", "place": "", "hour": "18"}, "present": ["where they set the cup"], "absent": ["who set the assay cup", "at which hour they set the cup"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Assay)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "assay incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "assay incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "assay incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "assay incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "assay incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "assay missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "assay named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "assay incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("assay incomplete submissions refused with the missing slot")


func _test_kiln_file_shape() -> void:
	_expect(Kiln.EXHIBITS.size() == 9, "kiln exhibit count is %d" % Kiln.EXHIBITS.size())
	_expect(Kiln.PEOPLE.size() == 3, "kiln cast should be three people")
	_expect(Kiln.PLACES.size() == 3, "kiln room count is %d" % Kiln.PLACES.size())
	_expect(Kiln.HOURS.size() == 5, "kiln hour list length is %d" % Kiln.HOURS.size())
	_expect(Kiln.TITLE == "The kiln chalk", "kiln title")
	_expect(Kiln.TITLE != CaseData.TITLE and Kiln.TITLE != Rehearsal.TITLE and Kiln.TITLE != Gilt.TITLE and Kiln.TITLE != Ferry.TITLE and Kiln.TITLE != Weather.TITLE and Kiln.TITLE != Loom.TITLE and Kiln.TITLE != Hive.TITLE and Kiln.TITLE != Glass.TITLE and Kiln.TITLE != Press.TITLE and Kiln.TITLE != Assay.TITLE, "kiln shares a title")
	_expect(Kiln.FILE_CODE == "CW-11", "kiln file code")
	_expect(Kiln.FILE_CODE != CaseData.FILE_CODE and Kiln.FILE_CODE != Rehearsal.FILE_CODE and Kiln.FILE_CODE != Gilt.FILE_CODE and Kiln.FILE_CODE != Ferry.FILE_CODE and Kiln.FILE_CODE != Weather.FILE_CODE and Kiln.FILE_CODE != Loom.FILE_CODE and Kiln.FILE_CODE != Hive.FILE_CODE and Kiln.FILE_CODE != Glass.FILE_CODE and Kiln.FILE_CODE != Press.FILE_CODE and Kiln.FILE_CODE != Assay.FILE_CODE, "kiln shares a file code")
	_expect(Kiln.HOURS[Kiln.HOURS.size() / 2] == KILN_TRUE["hour"], "kiln chalking should be the middle hour")
	_expect(Kiln.HOURS[0] != KILN_TRUE["hour"], "kiln chalking should not be the earliest hour")
	_expect(Kiln.HOURS[Kiln.HOURS.size() - 1] != KILN_TRUE["hour"], "kiln chalking should not be the latest hour")
	var counts := _player_pin_counts(Kiln)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "kiln pin counts are %s" % str(counts))
	_expect(counts != _player_pin_counts(CaseData), "kiln copied the spare-key pin pattern")
	_expect(counts != _player_pin_counts(Rehearsal), "kiln copied the rehearsal pin pattern")
	_expect(counts != _player_pin_counts(Gilt), "kiln copied the gilt pin pattern")
	_expect(counts != _player_pin_counts(Ferry), "kiln copied the ferry pin pattern")
	_expect(counts != _player_pin_counts(Weather), "kiln copied the weather pin pattern")
	_expect(counts != _player_pin_counts(Loom), "kiln copied the loom pin pattern")
	_expect(counts != _player_pin_counts(Hive), "kiln copied the hive pin pattern")
	_expect(counts != _player_pin_counts(Glass), "kiln copied the glass pin pattern")
	_expect(counts != _player_pin_counts(Press), "kiln copied the press pin pattern")
	_expect(counts != _player_pin_counts(Assay), "kiln copied the assay pin pattern")
	_expect(_field_key(Kiln) != _field_key(CaseData), "kiln copied the spare-key timeline fields")
	_expect(_field_key(Kiln) != _field_key(Rehearsal), "kiln copied the rehearsal timeline fields")
	_expect(_field_key(Kiln) != _field_key(Gilt), "kiln copied the gilt timeline fields")
	_expect(_field_key(Kiln) != _field_key(Ferry), "kiln copied the ferry timeline fields")
	_expect(_field_key(Kiln) != _field_key(Weather), "kiln copied the weather timeline fields")
	_expect(_field_key(Kiln) != _field_key(Loom), "kiln copied the loom timeline fields")
	_expect(_field_key(Kiln) != _field_key(Hive), "kiln copied the hive timeline fields")
	_expect(_field_key(Kiln) != _field_key(Glass), "kiln copied the glass timeline fields")
	_expect(_field_key(Kiln) != _field_key(Press), "kiln copied the press timeline fields")
	_expect(_field_key(Kiln) != _field_key(Assay), "kiln copied the assay timeline fields")
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	for exhibit in Kiln.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		_expect(not seen.has(exhibit_id), "duplicate kiln id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Kiln.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Kiln.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Kiln.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Kiln.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "kiln should have two slips with two hidden facts, found %d" % paired_hidden)
	for hour in Kiln.HOURS:
		_expect(stated.has(hour), "kiln hour %s is absent from the exhibits" % hour)


func _test_kiln_unique_model() -> void:
	var models := Solver.enumerate(Kiln.EXHIBITS, Kiln)
	print("kiln models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one kiln model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Wren", "kiln taker")
	_expect(str(model["place"]) == "flue", "kiln place")
	_expect(str(model["hour"]) == "52", "kiln hour")
	_expect(str(model["mixer"]) == "Bram", "kiln mixer")
	_expect(str(model["mix_place"]) == "fire_mouth", "kiln mix place")
	_expect(str(model["mix_hour"]) == "50", "kiln mix hour")
	_expect(str(model["watcher"]) == "Noll", "kiln watcher")
	_expect(str(model["watch_hour"]) == "51", "kiln watch hour")
	_expect(str(model["origin"]) == "crown", "kiln origin")
	_expect(str(model["purpose"]) == "read_shut", "kiln purpose")
	_expect(str(model["spy_place"]) == "crown", "kiln spy place")
	_expect(str(model["seat_place"]) == "crown", "kiln seat place")
	_expect(str(model["damper_hour"]) == "53", "kiln damper hour")
	_expect(str(model["cone_hour"]) == "54", "kiln cone hour")
	for hour in Kiln.HOURS:
		var used := false
		for field in Kiln.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "kiln hour %s is blank in the true timeline" % hour)
	for place in Kiln.PLACES:
		var place_used := false
		for field in Kiln.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "kiln room %s is blank in the true timeline" % place)
	for person in Kiln.PEOPLE:
		var person_used := false
		for field in Kiln.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "kiln person %s is blank in the true timeline" % person)
	_expect(Kiln.timeline(model) == KILN_TIMELINE, "kiln timeline drifted:\n%s" % Kiln.timeline(model))
	for exhibit in Kiln.EXHIBITS:
		_expect(Kiln.holds(exhibit, model), "%s rejects the kiln timeline" % exhibit["id"])


func _test_kiln_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Kiln.EXHIBITS, Kiln)
	for exhibit in Kiln.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Kiln.without(exhibit_id), Kiln)
		print("kiln without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "kiln %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Kiln.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "kiln %s removal did not admit a timeline it forbids" % exhibit_id)


func _test_kiln_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	for who in Kiln.PEOPLE:
		for place in Kiln.PLACES:
			for hour in Kiln.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == KILN_TRUE["who"] and place == KILN_TRUE["place"] and hour == KILN_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Kiln)
					print("kiln true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true kiln theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "kiln acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(KILN_TIMELINE) >= 0, "kiln acceptance should give the timeline")
					_expect(str(result["message"]).find("Wren") >= 0, "kiln acceptance omits Wren")
					_expect(str(result["message"]).find("flue") >= 0, "kiln acceptance omits the flue")
					_expect(str(result["message"]).find("52") >= 0, "kiln acceptance omits 52")
					_expect(str(result["message"]).find("so the draught would read shut") >= 0, "kiln acceptance omits the draught")
					_expect(Kiln.conflicting_ids(theory).is_empty(), "true kiln theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Kiln)
					rejected += 1
	print("kiln theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d kiln theories" % accepted)
	_expect(rejected >= 2, "rejected %d kiln theories" % rejected)


func _test_kiln_near_misses() -> void:
	var misses := [
		{"who": "Wren", "place": "flue", "hour": "53"},
		{"who": "Wren", "place": "flue", "hour": "50"},
		{"who": "Wren", "place": "crown", "hour": "52"},
		{"who": "Bram", "place": "flue", "hour": "52"},
	]
	var wrong_hour_on_flue := 0
	var wrong_place_at_hour := 0
	for theory in misses:
		_expect_rejected(theory, Kiln)
		if str(theory["who"]) == "Wren" and str(theory["place"]) == "flue" and str(theory["hour"]) != "52":
			wrong_hour_on_flue += 1
		if str(theory["who"]) == "Wren" and str(theory["place"]) != "flue" and str(theory["hour"]) == "52":
			wrong_place_at_hour += 1
	var hour_miss: Dictionary = Verdict.submit({"who": "Wren", "place": "flue", "hour": "53"}, Kiln)
	var hour_message := str(hour_miss["message"])
	_expect(hour_message.find("Watch slip") >= 0, "wrong hour omits Watch slip: %s" % hour_message)
	_expect(hour_message.find("Draught note") >= 0, "wrong hour omits Draught note: %s" % hour_message)
	_expect(hour_message.find("Damper line") >= 0, "wrong hour omits Damper line: %s" % hour_message)
	print("kiln near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four kiln near-misses, found %d" % misses.size())
	_expect(wrong_hour_on_flue >= 1, "a near-miss should keep Wren on the flue at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Wren at 52 in another room")


func _test_kiln_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
	]
	var cases := [
		{"theory": {"who": "", "place": "flue", "hour": "52"}, "present": ["who chalked the kiln mark"], "absent": ["where they chalked the mark", "at which hour they chalked the mark"]},
		{"theory": {"who": "Wren", "place": "", "hour": "52"}, "present": ["where they chalked the mark"], "absent": ["who chalked the kiln mark", "at which hour they chalked the mark"]},
		{"theory": {"who": "Wren", "place": "flue", "hour": ""}, "present": ["at which hour they chalked the mark"], "absent": ["who chalked the kiln mark", "where they chalked the mark"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who chalked the kiln mark", "where they chalked the mark", "at which hour they chalked the mark"], "absent": []},
		{"theory": {}, "present": ["who chalked the kiln mark", "where they chalked the mark", "at which hour they chalked the mark"], "absent": []},
		{"theory": {"who": "Noll", "place": "", "hour": "54"}, "present": ["where they chalked the mark"], "absent": ["who chalked the kiln mark", "at which hour they chalked the mark"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Kiln)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "kiln incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "kiln incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "kiln incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "kiln incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "kiln incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "kiln missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "kiln named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "kiln incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("kiln incomplete submissions refused with the missing slot")


func _test_tide_file_shape() -> void:
	_expect(Tide.EXHIBITS.size() == 9, "tide exhibit count is %d" % Tide.EXHIBITS.size())
	_expect(Tide.PEOPLE.size() == 3, "tide cast should be three people")
	_expect(Tide.PLACES.size() == 3, "tide room count is %d" % Tide.PLACES.size())
	_expect(Tide.HOURS.size() == 5, "tide hour list length is %d" % Tide.HOURS.size())
	_expect(Tide.TITLE == "The tide ledger", "tide title")
	_expect(Tide.TITLE != CaseData.TITLE and Tide.TITLE != Rehearsal.TITLE and Tide.TITLE != Gilt.TITLE and Tide.TITLE != Ferry.TITLE and Tide.TITLE != Weather.TITLE and Tide.TITLE != Loom.TITLE and Tide.TITLE != Hive.TITLE and Tide.TITLE != Glass.TITLE and Tide.TITLE != Press.TITLE and Tide.TITLE != Assay.TITLE and Tide.TITLE != Kiln.TITLE, "tide shares a title")
	_expect(Tide.FILE_CODE == "CW-12", "tide file code")
	_expect(Tide.FILE_CODE != CaseData.FILE_CODE and Tide.FILE_CODE != Rehearsal.FILE_CODE and Tide.FILE_CODE != Gilt.FILE_CODE and Tide.FILE_CODE != Ferry.FILE_CODE and Tide.FILE_CODE != Weather.FILE_CODE and Tide.FILE_CODE != Loom.FILE_CODE and Tide.FILE_CODE != Hive.FILE_CODE and Tide.FILE_CODE != Glass.FILE_CODE and Tide.FILE_CODE != Press.FILE_CODE and Tide.FILE_CODE != Assay.FILE_CODE and Tide.FILE_CODE != Kiln.FILE_CODE, "tide shares a file code")
	_expect(Tide.HOURS[Tide.HOURS.size() / 2] == TIDE_TRUE["hour"], "tide entry should be the middle hour")
	_expect(Tide.HOURS[0] != TIDE_TRUE["hour"], "tide entry should not be the earliest hour")
	_expect(Tide.HOURS[Tide.HOURS.size() - 1] != TIDE_TRUE["hour"], "tide entry should not be the latest hour")
	var counts := _player_pin_counts(Tide)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "tide pin counts are %s" % str(counts))
	_expect(counts != _player_pin_counts(CaseData), "tide copied the spare-key pin pattern")
	_expect(counts != _player_pin_counts(Rehearsal), "tide copied the rehearsal pin pattern")
	_expect(counts != _player_pin_counts(Gilt), "tide copied the gilt pin pattern")
	_expect(counts != _player_pin_counts(Ferry), "tide copied the ferry pin pattern")
	_expect(counts != _player_pin_counts(Weather), "tide copied the weather pin pattern")
	_expect(counts != _player_pin_counts(Loom), "tide copied the loom pin pattern")
	_expect(counts != _player_pin_counts(Hive), "tide copied the hive pin pattern")
	_expect(counts != _player_pin_counts(Glass), "tide copied the glass pin pattern")
	_expect(counts != _player_pin_counts(Press), "tide copied the press pin pattern")
	_expect(counts != _player_pin_counts(Assay), "tide copied the assay pin pattern")
	_expect(counts == _player_pin_counts(Kiln), "tide ledger should keep the kiln chalk pin rhythm")
	_expect(_field_key(Tide) != _field_key(CaseData), "tide copied the spare-key timeline fields")
	_expect(_field_key(Tide) != _field_key(Rehearsal), "tide copied the rehearsal timeline fields")
	_expect(_field_key(Tide) != _field_key(Gilt), "tide copied the gilt timeline fields")
	_expect(_field_key(Tide) != _field_key(Ferry), "tide copied the ferry timeline fields")
	_expect(_field_key(Tide) != _field_key(Weather), "tide copied the weather timeline fields")
	_expect(_field_key(Tide) != _field_key(Loom), "tide copied the loom timeline fields")
	_expect(_field_key(Tide) != _field_key(Hive), "tide copied the hive timeline fields")
	_expect(_field_key(Tide) != _field_key(Glass), "tide copied the glass timeline fields")
	_expect(_field_key(Tide) != _field_key(Press), "tide copied the press timeline fields")
	_expect(_field_key(Tide) != _field_key(Assay), "tide copied the assay timeline fields")
	_expect(_field_key(Tide) != _field_key(Kiln), "tide copied the kiln timeline fields")
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	for exhibit in Tide.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		_expect(not seen.has(exhibit_id), "duplicate tide id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Tide.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Tide.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Tide.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Tide.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "tide should have two slips with two hidden facts, found %d" % paired_hidden)
	for hour in Tide.HOURS:
		_expect(stated.has(hour), "tide hour %s is absent from the exhibits" % hour)


func _test_tide_unique_model() -> void:
	var models := Solver.enumerate(Tide.EXHIBITS, Tide)
	print("tide models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one tide model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Moss", "tide taker")
	_expect(str(model["place"]) == "quay", "tide place")
	_expect(str(model["hour"]) == "33", "tide hour")
	_expect(str(model["inker"]) == "Pell", "tide inker")
	_expect(str(model["ink_place"]) == "sill", "tide ink place")
	_expect(str(model["ink_hour"]) == "31", "tide ink hour")
	_expect(str(model["reader"]) == "Dory", "tide reader")
	_expect(str(model["read_hour"]) == "32", "tide read hour")
	_expect(str(model["origin"]) == "mole", "tide origin")
	_expect(str(model["purpose"]) == "read_late", "tide purpose")
	_expect(str(model["glass_place"]) == "mole", "tide glass place")
	_expect(str(model["hang_place"]) == "mole", "tide hang place")
	_expect(str(model["call_hour"]) == "34", "tide call hour")
	_expect(str(model["haul_hour"]) == "35", "tide haul hour")
	for hour in Tide.HOURS:
		var used := false
		for field in Tide.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "tide hour %s is blank in the true timeline" % hour)
	for place in Tide.PLACES:
		var place_used := false
		for field in Tide.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "tide room %s is blank in the true timeline" % place)
	for person in Tide.PEOPLE:
		var person_used := false
		for field in Tide.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "tide person %s is blank in the true timeline" % person)
	_expect(Tide.timeline(model) == TIDE_TIMELINE, "tide timeline drifted:\n%s" % Tide.timeline(model))
	for exhibit in Tide.EXHIBITS:
		_expect(Tide.holds(exhibit, model), "%s rejects the tide timeline" % exhibit["id"])


func _test_tide_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Tide.EXHIBITS, Tide)
	for exhibit in Tide.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Tide.without(exhibit_id), Tide)
		print("tide without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "tide %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Tide.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "tide %s removal did not admit a timeline it forbids" % exhibit_id)


func _test_tide_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	for who in Tide.PEOPLE:
		for place in Tide.PLACES:
			for hour in Tide.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == TIDE_TRUE["who"] and place == TIDE_TRUE["place"] and hour == TIDE_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Tide)
					print("tide true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true tide theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "tide acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(TIDE_TIMELINE) >= 0, "tide acceptance should give the timeline")
					_expect(str(result["message"]).find("Moss") >= 0, "tide acceptance omits Moss")
					_expect(str(result["message"]).find("quay") >= 0, "tide acceptance omits the quay")
					_expect(str(result["message"]).find("33") >= 0, "tide acceptance omits 33")
					_expect(str(result["message"]).find("so the boat would read late") >= 0, "tide acceptance omits the late boat")
					_expect(Tide.conflicting_ids(theory).is_empty(), "true tide theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Tide)
					rejected += 1
	_expect_rejected({"who": "Wren", "place": "quay", "hour": "33"}, Tide)
	print("tide theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d tide theories" % accepted)
	_expect(rejected >= 2, "rejected %d tide theories" % rejected)


func _test_tide_near_misses() -> void:
	var misses := [
		{"who": "Moss", "place": "quay", "hour": "34"},
		{"who": "Moss", "place": "quay", "hour": "31"},
		{"who": "Moss", "place": "mole", "hour": "33"},
		{"who": "Pell", "place": "quay", "hour": "33"},
	]
	var wrong_hour_on_quay := 0
	var wrong_place_at_hour := 0
	for theory in misses:
		_expect_rejected(theory, Tide)
		if str(theory["who"]) == "Moss" and str(theory["place"]) == "quay" and str(theory["hour"]) != "33":
			wrong_hour_on_quay += 1
		if str(theory["who"]) == "Moss" and str(theory["place"]) != "quay" and str(theory["hour"]) == "33":
			wrong_place_at_hour += 1
	var hour_miss: Dictionary = Verdict.submit({"who": "Moss", "place": "quay", "hour": "34"}, Tide)
	var hour_message := str(hour_miss["message"])
	_expect(hour_message.find("Glass slip") >= 0, "wrong hour omits Glass slip: %s" % hour_message)
	_expect(hour_message.find("Late note") >= 0, "wrong hour omits Late note: %s" % hour_message)
	_expect(hour_message.find("Call line") >= 0, "wrong hour omits Call line: %s" % hour_message)
	print("tide near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four tide near-misses, found %d" % misses.size())
	_expect(wrong_hour_on_quay >= 1, "a near-miss should keep Moss on the quay at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Moss at 33 in another room")


func _test_tide_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
	]
	var cases := [
		{"theory": {"who": "", "place": "quay", "hour": "33"}, "present": ["who entered the tide ledger"], "absent": ["where they entered the ledger", "at which hour they entered the ledger"]},
		{"theory": {"who": "Moss", "place": "", "hour": "33"}, "present": ["where they entered the ledger"], "absent": ["who entered the tide ledger", "at which hour they entered the ledger"]},
		{"theory": {"who": "Moss", "place": "quay", "hour": ""}, "present": ["at which hour they entered the ledger"], "absent": ["who entered the tide ledger", "where they entered the ledger"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who entered the tide ledger", "where they entered the ledger", "at which hour they entered the ledger"], "absent": []},
		{"theory": {}, "present": ["who entered the tide ledger", "where they entered the ledger", "at which hour they entered the ledger"], "absent": []},
		{"theory": {"who": "Dory", "place": "", "hour": "35"}, "present": ["where they entered the ledger"], "absent": ["who entered the tide ledger", "at which hour they entered the ledger"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Tide)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "tide incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "tide incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "tide incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "tide incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "tide incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "tide missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "tide named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "tide incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("tide incomplete submissions refused with the missing slot")


func _test_night_file_shape() -> void:
	_expect(Night.EXHIBITS.size() == 9, "night exhibit count is %d" % Night.EXHIBITS.size())
	_expect(Night.PEOPLE.size() == 3, "night cast should be three people")
	_expect(Night.PLACES.size() == 3, "night room count is %d" % Night.PLACES.size())
	_expect(Night.HOURS.size() == 5, "night hour list length is %d" % Night.HOURS.size())
	_expect(Night.TITLE == "The night bell", "night title")
	_expect(Night.TITLE != CaseData.TITLE and Night.TITLE != Rehearsal.TITLE and Night.TITLE != Gilt.TITLE and Night.TITLE != Ferry.TITLE and Night.TITLE != Weather.TITLE and Night.TITLE != Loom.TITLE and Night.TITLE != Hive.TITLE and Night.TITLE != Glass.TITLE and Night.TITLE != Press.TITLE and Night.TITLE != Assay.TITLE and Night.TITLE != Kiln.TITLE and Night.TITLE != Tide.TITLE, "night shares a title")
	_expect(Night.FILE_CODE == "CW-13", "night file code")
	_expect(Night.FILE_CODE != CaseData.FILE_CODE and Night.FILE_CODE != Rehearsal.FILE_CODE and Night.FILE_CODE != Gilt.FILE_CODE and Night.FILE_CODE != Ferry.FILE_CODE and Night.FILE_CODE != Weather.FILE_CODE and Night.FILE_CODE != Loom.FILE_CODE and Night.FILE_CODE != Hive.FILE_CODE and Night.FILE_CODE != Glass.FILE_CODE and Night.FILE_CODE != Press.FILE_CODE and Night.FILE_CODE != Assay.FILE_CODE and Night.FILE_CODE != Kiln.FILE_CODE and Night.FILE_CODE != Tide.FILE_CODE, "night shares a file code")
	_expect(Night.HOURS[Night.HOURS.size() / 2] == NIGHT_TRUE["hour"], "night stopping should be the middle hour")
	_expect(Night.HOURS[0] != NIGHT_TRUE["hour"], "night stopping should not be the earliest hour")
	_expect(Night.HOURS[Night.HOURS.size() - 1] != NIGHT_TRUE["hour"], "night stopping should not be the latest hour")
	var counts := _player_pin_counts(Night)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "night pin counts are %s" % str(counts))
	_expect(counts != _player_pin_counts(CaseData), "night copied the spare-key pin pattern")
	_expect(counts != _player_pin_counts(Rehearsal), "night copied the rehearsal pin pattern")
	_expect(counts != _player_pin_counts(Gilt), "night copied the gilt pin pattern")
	_expect(counts != _player_pin_counts(Ferry), "night copied the ferry pin pattern")
	_expect(counts != _player_pin_counts(Weather), "night copied the weather pin pattern")
	_expect(counts != _player_pin_counts(Loom), "night copied the loom pin pattern")
	_expect(counts != _player_pin_counts(Hive), "night copied the hive pin pattern")
	_expect(counts != _player_pin_counts(Glass), "night copied the glass pin pattern")
	_expect(counts != _player_pin_counts(Press), "night copied the press pin pattern")
	_expect(counts != _player_pin_counts(Assay), "night copied the assay pin pattern")
	_expect(counts == _player_pin_counts(Kiln), "night bell should keep the kiln chalk pin rhythm")
	_expect(counts == _player_pin_counts(Tide), "night bell should keep the tide ledger pin rhythm")
	_expect(_field_key(Night) != _field_key(CaseData), "night copied the spare-key timeline fields")
	_expect(_field_key(Night) != _field_key(Rehearsal), "night copied the rehearsal timeline fields")
	_expect(_field_key(Night) != _field_key(Gilt), "night copied the gilt timeline fields")
	_expect(_field_key(Night) != _field_key(Ferry), "night copied the ferry timeline fields")
	_expect(_field_key(Night) != _field_key(Weather), "night copied the weather timeline fields")
	_expect(_field_key(Night) != _field_key(Loom), "night copied the loom timeline fields")
	_expect(_field_key(Night) != _field_key(Hive), "night copied the hive timeline fields")
	_expect(_field_key(Night) != _field_key(Glass), "night copied the glass timeline fields")
	_expect(_field_key(Night) != _field_key(Press), "night copied the press timeline fields")
	_expect(_field_key(Night) != _field_key(Assay), "night copied the assay timeline fields")
	_expect(_field_key(Night) != _field_key(Kiln), "night copied the kiln timeline fields")
	_expect(_field_key(Night) != _field_key(Tide), "night copied the tide timeline fields")
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	for exhibit in Night.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		_expect(not seen.has(exhibit_id), "duplicate night id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Night.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Night.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Night.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Night.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "night should have two slips with two hidden facts, found %d" % paired_hidden)
	for hour in Night.HOURS:
		_expect(stated.has(hour), "night hour %s is absent from the exhibits" % hour)


func _test_night_unique_model() -> void:
	var models := Solver.enumerate(Night.EXHIBITS, Night)
	print("night models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one night model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Vesper", "night taker")
	_expect(str(model["place"]) == "tower", "night place")
	_expect(str(model["hour"]) == "44", "night hour")
	_expect(str(model["trimmer"]) == "Cobb", "night trimmer")
	_expect(str(model["trim_place"]) == "bell_walk", "night trim place")
	_expect(str(model["trim_hour"]) == "42", "night trim hour")
	_expect(str(model["sighter"]) == "Reed", "night sighter")
	_expect(str(model["sight_hour"]) == "43", "night sight hour")
	_expect(str(model["origin"]) == "parapet", "night origin")
	_expect(str(model["purpose"]) == "read_early", "night purpose")
	_expect(str(model["sight_place"]) == "parapet", "night sight place")
	_expect(str(model["hitch_place"]) == "parapet", "night hitch place")
	_expect(str(model["strike_hour"]) == "45", "night strike hour")
	_expect(str(model["shutter_hour"]) == "46", "night shutter hour")
	for hour in Night.HOURS:
		var used := false
		for field in Night.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "night hour %s is blank in the true timeline" % hour)
	for place in Night.PLACES:
		var place_used := false
		for field in Night.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "night room %s is blank in the true timeline" % place)
	for person in Night.PEOPLE:
		var person_used := false
		for field in Night.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "night person %s is blank in the true timeline" % person)
	_expect(Night.timeline(model) == NIGHT_TIMELINE, "night timeline drifted:\n%s" % Night.timeline(model))
	for exhibit in Night.EXHIBITS:
		_expect(Night.holds(exhibit, model), "%s rejects the night timeline" % exhibit["id"])


func _test_night_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Night.EXHIBITS, Night)
	for exhibit in Night.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Night.without(exhibit_id), Night)
		print("night without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "night %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Night.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "night %s removal did not admit a timeline it forbids" % exhibit_id)


func _test_night_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	for who in Night.PEOPLE:
		for place in Night.PLACES:
			for hour in Night.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == NIGHT_TRUE["who"] and place == NIGHT_TRUE["place"] and hour == NIGHT_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Night)
					print("night true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true night theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "night acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(NIGHT_TIMELINE) >= 0, "night acceptance should give the timeline")
					_expect(str(result["message"]).find("Vesper") >= 0, "night acceptance omits Vesper")
					_expect(str(result["message"]).find("tower") >= 0, "night acceptance omits the tower")
					_expect(str(result["message"]).find("44") >= 0, "night acceptance omits 44")
					_expect(str(result["message"]).find("so the watch would read early") >= 0, "night acceptance omits the early watch")
					_expect(Night.conflicting_ids(theory).is_empty(), "true night theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Night)
					rejected += 1
	for outsider in ["Moss", "Pell", "Wren", "Quill", "Lark", "Nim", "Sable"]:
		_expect_rejected({"who": outsider, "place": "tower", "hour": "44"}, Night)
	print("night theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d night theories" % accepted)
	_expect(rejected >= 2, "rejected %d night theories" % rejected)


func _test_night_near_misses() -> void:
	var misses := [
		{"who": "Vesper", "place": "tower", "hour": "45"},
		{"who": "Vesper", "place": "tower", "hour": "42"},
		{"who": "Vesper", "place": "parapet", "hour": "44"},
		{"who": "Cobb", "place": "tower", "hour": "44"},
	]
	var wrong_hour_in_tower := 0
	var wrong_place_at_hour := 0
	for theory in misses:
		_expect_rejected(theory, Night)
		if str(theory["who"]) == "Vesper" and str(theory["place"]) == "tower" and str(theory["hour"]) != "44":
			wrong_hour_in_tower += 1
		if str(theory["who"]) == "Vesper" and str(theory["place"]) != "tower" and str(theory["hour"]) == "44":
			wrong_place_at_hour += 1
	var hour_miss: Dictionary = Verdict.submit({"who": "Vesper", "place": "tower", "hour": "45"}, Night)
	var hour_message := str(hour_miss["message"])
	_expect(hour_message.find("Sight slip") >= 0, "wrong hour omits Sight slip: %s" % hour_message)
	_expect(hour_message.find("Early note") >= 0, "wrong hour omits Early note: %s" % hour_message)
	_expect(hour_message.find("Shutter line") >= 0, "wrong hour omits Shutter line: %s" % hour_message)
	print("night near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four night near-misses, found %d" % misses.size())
	_expect(wrong_hour_in_tower >= 1, "a near-miss should keep Vesper in the tower at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Vesper at 44 in another room")


func _test_night_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
	]
	var cases := [
		{"theory": {"who": "", "place": "tower", "hour": "44"}, "present": ["who stopped the night bell"], "absent": ["where they stopped the bell", "at which hour they stopped the bell"]},
		{"theory": {"who": "Vesper", "place": "", "hour": "44"}, "present": ["where they stopped the bell"], "absent": ["who stopped the night bell", "at which hour they stopped the bell"]},
		{"theory": {"who": "Vesper", "place": "tower", "hour": ""}, "present": ["at which hour they stopped the bell"], "absent": ["who stopped the night bell", "where they stopped the bell"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who stopped the night bell", "where they stopped the bell", "at which hour they stopped the bell"], "absent": []},
		{"theory": {}, "present": ["who stopped the night bell", "where they stopped the bell", "at which hour they stopped the bell"], "absent": []},
		{"theory": {"who": "Reed", "place": "", "hour": "46"}, "present": ["where they stopped the bell"], "absent": ["who stopped the night bell", "at which hour they stopped the bell"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Night)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "night incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "night incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "night incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "night incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "night incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "night missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "night named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "night incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("night incomplete submissions refused with the missing slot")


func _test_salt_file_shape() -> void:
	_expect(Salt.EXHIBITS.size() == 9, "salt exhibit count is %d" % Salt.EXHIBITS.size())
	_expect(Salt.PEOPLE.size() == 3, "salt cast should be three people")
	_expect(Salt.PLACES.size() == 3, "salt room count is %d" % Salt.PLACES.size())
	_expect(Salt.HOURS.size() == 5, "salt hour list length is %d" % Salt.HOURS.size())
	_expect(Salt.TITLE == "The salt mark", "salt title")
	_expect(Salt.TITLE != CaseData.TITLE and Salt.TITLE != Rehearsal.TITLE and Salt.TITLE != Gilt.TITLE and Salt.TITLE != Ferry.TITLE and Salt.TITLE != Weather.TITLE and Salt.TITLE != Loom.TITLE and Salt.TITLE != Hive.TITLE and Salt.TITLE != Glass.TITLE and Salt.TITLE != Press.TITLE and Salt.TITLE != Assay.TITLE and Salt.TITLE != Kiln.TITLE and Salt.TITLE != Tide.TITLE and Salt.TITLE != Night.TITLE, "salt shares a title")
	_expect(Salt.FILE_CODE == "CW-14", "salt file code")
	_expect(Salt.FILE_CODE != CaseData.FILE_CODE and Salt.FILE_CODE != Rehearsal.FILE_CODE and Salt.FILE_CODE != Gilt.FILE_CODE and Salt.FILE_CODE != Ferry.FILE_CODE and Salt.FILE_CODE != Weather.FILE_CODE and Salt.FILE_CODE != Loom.FILE_CODE and Salt.FILE_CODE != Hive.FILE_CODE and Salt.FILE_CODE != Glass.FILE_CODE and Salt.FILE_CODE != Press.FILE_CODE and Salt.FILE_CODE != Assay.FILE_CODE and Salt.FILE_CODE != Kiln.FILE_CODE and Salt.FILE_CODE != Tide.FILE_CODE and Salt.FILE_CODE != Night.FILE_CODE, "salt shares a file code")
	_expect(Salt.HOURS[Salt.HOURS.size() / 2] == SALT_TRUE["hour"], "salt scoring should be the middle hour")
	_expect(Salt.HOURS[0] != SALT_TRUE["hour"], "salt scoring should not be the earliest hour")
	_expect(Salt.HOURS[Salt.HOURS.size() - 1] != SALT_TRUE["hour"], "salt scoring should not be the latest hour")
	var counts := _player_pin_counts(Salt)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "salt pin counts are %s" % str(counts))
	_expect(counts != _player_pin_counts(CaseData), "salt copied the spare-key pin pattern")
	_expect(counts != _player_pin_counts(Rehearsal), "salt copied the rehearsal pin pattern")
	_expect(counts != _player_pin_counts(Gilt), "salt copied the gilt pin pattern")
	_expect(counts != _player_pin_counts(Ferry), "salt copied the ferry pin pattern")
	_expect(counts != _player_pin_counts(Weather), "salt copied the weather pin pattern")
	_expect(counts != _player_pin_counts(Loom), "salt copied the loom pin pattern")
	_expect(counts != _player_pin_counts(Hive), "salt copied the hive pin pattern")
	_expect(counts != _player_pin_counts(Glass), "salt copied the glass pin pattern")
	_expect(counts != _player_pin_counts(Press), "salt copied the press pin pattern")
	_expect(counts != _player_pin_counts(Assay), "salt copied the assay pin pattern")
	_expect(counts == _player_pin_counts(Kiln), "salt mark should keep the kiln chalk pin rhythm")
	_expect(counts == _player_pin_counts(Tide), "salt mark should keep the tide ledger pin rhythm")
	_expect(counts == _player_pin_counts(Night), "salt mark should keep the night bell pin rhythm")
	_expect(_field_key(Salt) != _field_key(CaseData), "salt copied the spare-key timeline fields")
	_expect(_field_key(Salt) != _field_key(Rehearsal), "salt copied the rehearsal timeline fields")
	_expect(_field_key(Salt) != _field_key(Gilt), "salt copied the gilt timeline fields")
	_expect(_field_key(Salt) != _field_key(Ferry), "salt copied the ferry timeline fields")
	_expect(_field_key(Salt) != _field_key(Weather), "salt copied the weather timeline fields")
	_expect(_field_key(Salt) != _field_key(Loom), "salt copied the loom timeline fields")
	_expect(_field_key(Salt) != _field_key(Hive), "salt copied the hive timeline fields")
	_expect(_field_key(Salt) != _field_key(Glass), "salt copied the glass timeline fields")
	_expect(_field_key(Salt) != _field_key(Press), "salt copied the press timeline fields")
	_expect(_field_key(Salt) != _field_key(Assay), "salt copied the assay timeline fields")
	_expect(_field_key(Salt) != _field_key(Kiln), "salt copied the kiln timeline fields")
	_expect(_field_key(Salt) != _field_key(Tide), "salt copied the tide timeline fields")
	_expect(_field_key(Salt) != _field_key(Night), "salt copied the night timeline fields")
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	for exhibit in Salt.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		_expect(not seen.has(exhibit_id), "duplicate salt id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Salt.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Salt.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Salt.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Salt.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "salt should have two slips with two hidden facts, found %d" % paired_hidden)
	for hour in Salt.HOURS:
		_expect(stated.has(hour), "salt hour %s is absent from the exhibits" % hour)


func _test_salt_unique_model() -> void:
	var models := Solver.enumerate(Salt.EXHIBITS, Salt)
	print("salt models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one salt model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Holt", "salt taker")
	_expect(str(model["place"]) == "pan", "salt place")
	_expect(str(model["hour"]) == "19", "salt hour")
	_expect(str(model["raker"]) == "Lin", "salt raker")
	_expect(str(model["rake_place"]) == "rake_bay", "salt rake place")
	_expect(str(model["rake_hour"]) == "17", "salt rake hour")
	_expect(str(model["gauger"]) == "Opal", "salt gauger")
	_expect(str(model["gauge_hour"]) == "18", "salt gauge hour")
	_expect(str(model["origin"]) == "cistern", "salt origin")
	_expect(str(model["purpose"]) == "read_heavy", "salt purpose")
	_expect(str(model["gauge_place"]) == "cistern", "salt gauge place")
	_expect(str(model["rest_place"]) == "cistern", "salt rest place")
	_expect(str(model["boil_hour"]) == "20", "salt boil hour")
	_expect(str(model["draw_hour"]) == "21", "salt draw hour")
	for hour in Salt.HOURS:
		var used := false
		for field in Salt.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "salt hour %s is blank in the true timeline" % hour)
	for place in Salt.PLACES:
		var place_used := false
		for field in Salt.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "salt room %s is blank in the true timeline" % place)
	for person in Salt.PEOPLE:
		var person_used := false
		for field in Salt.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "salt person %s is blank in the true timeline" % person)
	_expect(Salt.timeline(model) == SALT_TIMELINE, "salt timeline drifted:\n%s" % Salt.timeline(model))
	for exhibit in Salt.EXHIBITS:
		_expect(Salt.holds(exhibit, model), "%s rejects the salt timeline" % exhibit["id"])


func _test_salt_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Salt.EXHIBITS, Salt)
	for exhibit in Salt.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Salt.without(exhibit_id), Salt)
		print("salt without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "salt %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Salt.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "salt %s removal did not admit a timeline it forbids" % exhibit_id)


func _test_salt_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	for who in Salt.PEOPLE:
		for place in Salt.PLACES:
			for hour in Salt.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == SALT_TRUE["who"] and place == SALT_TRUE["place"] and hour == SALT_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Salt)
					print("salt true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true salt theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "salt acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(SALT_TIMELINE) >= 0, "salt acceptance should give the timeline")
					_expect(str(result["message"]).find("Holt") >= 0, "salt acceptance omits Holt")
					_expect(str(result["message"]).find("pan") >= 0, "salt acceptance omits the pan")
					_expect(str(result["message"]).find("19") >= 0, "salt acceptance omits 19")
					_expect(str(result["message"]).find("so the weigh would read heavy") >= 0, "salt acceptance omits the heavy weigh")
					_expect(Salt.conflicting_ids(theory).is_empty(), "true salt theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Salt)
					rejected += 1
	for outsider in ["Vesper", "Moss", "Pell", "Wren", "Quill", "Lark", "Nim", "Sable", "Cobb", "Bram"]:
		_expect_rejected({"who": outsider, "place": "pan", "hour": "19"}, Salt)
	print("salt theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d salt theories" % accepted)
	_expect(rejected >= 2, "rejected %d salt theories" % rejected)


func _test_salt_near_misses() -> void:
	var misses := [
		{"who": "Holt", "place": "pan", "hour": "20"},
		{"who": "Holt", "place": "pan", "hour": "17"},
		{"who": "Holt", "place": "cistern", "hour": "19"},
		{"who": "Lin", "place": "pan", "hour": "19"},
	]
	var wrong_hour_on_pan := 0
	var wrong_place_at_hour := 0
	for theory in misses:
		_expect_rejected(theory, Salt)
		if str(theory["who"]) == "Holt" and str(theory["place"]) == "pan" and str(theory["hour"]) != "19":
			wrong_hour_on_pan += 1
		if str(theory["who"]) == "Holt" and str(theory["place"]) != "pan" and str(theory["hour"]) == "19":
			wrong_place_at_hour += 1
	var hour_miss: Dictionary = Verdict.submit({"who": "Holt", "place": "pan", "hour": "20"}, Salt)
	var hour_message := str(hour_miss["message"])
	_expect(hour_message.find("Stick slip") >= 0, "wrong hour omits Stick slip: %s" % hour_message)
	_expect(hour_message.find("Heavy note") >= 0, "wrong hour omits Heavy note: %s" % hour_message)
	_expect(hour_message.find("Draw line") >= 0, "wrong hour omits Draw line: %s" % hour_message)
	var earlier_hour: Dictionary = Verdict.submit({"who": "Holt", "place": "pan", "hour": "17"}, Salt)
	var earlier_message := str(earlier_hour["message"])
	_expect(earlier_message.find("Stick slip") >= 0, "earlier hour omits Stick slip: %s" % earlier_message)
	_expect(earlier_message.find("Heavy note") >= 0, "earlier hour omits Heavy note: %s" % earlier_message)
	_expect(earlier_message.find("Draw line") >= 0, "earlier hour omits Draw line: %s" % earlier_message)
	print("salt near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four salt near-misses, found %d" % misses.size())
	_expect(wrong_hour_on_pan == 2, "two near-misses should keep Holt on the pan at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Holt at 19 in another room")


func _test_salt_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
		"who stopped the night bell",
		"where they stopped the bell",
		"at which hour they stopped the bell",
	]
	var cases := [
		{"theory": {"who": "", "place": "pan", "hour": "19"}, "present": ["who scored the salt mark"], "absent": ["where they scored the mark", "at which hour they scored the mark"]},
		{"theory": {"who": "Holt", "place": "", "hour": "19"}, "present": ["where they scored the mark"], "absent": ["who scored the salt mark", "at which hour they scored the mark"]},
		{"theory": {"who": "Holt", "place": "pan", "hour": ""}, "present": ["at which hour they scored the mark"], "absent": ["who scored the salt mark", "where they scored the mark"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who scored the salt mark", "where they scored the mark", "at which hour they scored the mark"], "absent": []},
		{"theory": {}, "present": ["who scored the salt mark", "where they scored the mark", "at which hour they scored the mark"], "absent": []},
		{"theory": {"who": "Opal", "place": "", "hour": "21"}, "present": ["where they scored the mark"], "absent": ["who scored the salt mark", "at which hour they scored the mark"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Salt)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "salt incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "salt incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "salt incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "salt incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "salt incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "salt missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "salt named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "salt incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("salt incomplete submissions refused with the missing slot")


func _test_wick_file_shape() -> void:
	_expect(Wick.EXHIBITS.size() == 9, "wick exhibit count is %d" % Wick.EXHIBITS.size())
	_expect(Wick.PEOPLE.size() == 3, "wick cast should be three people")
	_expect(Wick.PLACES.size() == 3, "wick room count is %d" % Wick.PLACES.size())
	_expect(Wick.HOURS.size() == 5, "wick hour list length is %d" % Wick.HOURS.size())
	_expect(Wick.TITLE == "The wick trim", "wick title")
	_expect(Wick.TITLE != CaseData.TITLE and Wick.TITLE != Rehearsal.TITLE and Wick.TITLE != Gilt.TITLE and Wick.TITLE != Ferry.TITLE and Wick.TITLE != Weather.TITLE and Wick.TITLE != Loom.TITLE and Wick.TITLE != Hive.TITLE and Wick.TITLE != Glass.TITLE and Wick.TITLE != Press.TITLE and Wick.TITLE != Assay.TITLE and Wick.TITLE != Kiln.TITLE and Wick.TITLE != Tide.TITLE and Wick.TITLE != Night.TITLE and Wick.TITLE != Salt.TITLE, "wick shares a title")
	_expect(Wick.FILE_CODE == "CW-15", "wick file code")
	_expect(Wick.FILE_CODE != CaseData.FILE_CODE and Wick.FILE_CODE != Rehearsal.FILE_CODE and Wick.FILE_CODE != Gilt.FILE_CODE and Wick.FILE_CODE != Ferry.FILE_CODE and Wick.FILE_CODE != Weather.FILE_CODE and Wick.FILE_CODE != Loom.FILE_CODE and Wick.FILE_CODE != Hive.FILE_CODE and Wick.FILE_CODE != Glass.FILE_CODE and Wick.FILE_CODE != Press.FILE_CODE and Wick.FILE_CODE != Assay.FILE_CODE and Wick.FILE_CODE != Kiln.FILE_CODE and Wick.FILE_CODE != Tide.FILE_CODE and Wick.FILE_CODE != Night.FILE_CODE and Wick.FILE_CODE != Salt.FILE_CODE, "wick shares a file code")
	_expect(Wick.HOURS[Wick.HOURS.size() / 2] == WICK_TRUE["hour"], "wick trim should be the middle hour")
	_expect(Wick.HOURS[0] != WICK_TRUE["hour"], "wick trim should not be the earliest hour")
	_expect(Wick.HOURS[Wick.HOURS.size() - 1] != WICK_TRUE["hour"], "wick trim should not be the latest hour")
	var counts := _player_pin_counts(Wick)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "wick pin counts are %s" % str(counts))
	_expect(counts != _player_pin_counts(CaseData), "wick copied the spare-key pin pattern")
	_expect(counts != _player_pin_counts(Rehearsal), "wick copied the rehearsal pin pattern")
	_expect(counts != _player_pin_counts(Gilt), "wick copied the gilt pin pattern")
	_expect(counts != _player_pin_counts(Ferry), "wick copied the ferry pin pattern")
	_expect(counts != _player_pin_counts(Weather), "wick copied the weather pin pattern")
	_expect(counts != _player_pin_counts(Loom), "wick copied the loom pin pattern")
	_expect(counts != _player_pin_counts(Hive), "wick copied the hive pin pattern")
	_expect(counts != _player_pin_counts(Glass), "wick copied the glass pin pattern")
	_expect(counts != _player_pin_counts(Press), "wick copied the press pin pattern")
	_expect(counts != _player_pin_counts(Assay), "wick copied the assay pin pattern")
	_expect(counts == _player_pin_counts(Kiln), "wick trim should keep the kiln chalk pin rhythm")
	_expect(counts == _player_pin_counts(Tide), "wick trim should keep the tide ledger pin rhythm")
	_expect(counts == _player_pin_counts(Night), "wick trim should keep the night bell pin rhythm")
	_expect(counts == _player_pin_counts(Salt), "wick trim should keep the salt mark pin rhythm")
	_expect(_field_key(Wick) != _field_key(CaseData), "wick copied the spare-key timeline fields")
	_expect(_field_key(Wick) != _field_key(Rehearsal), "wick copied the rehearsal timeline fields")
	_expect(_field_key(Wick) != _field_key(Gilt), "wick copied the gilt timeline fields")
	_expect(_field_key(Wick) != _field_key(Ferry), "wick copied the ferry timeline fields")
	_expect(_field_key(Wick) != _field_key(Weather), "wick copied the weather timeline fields")
	_expect(_field_key(Wick) != _field_key(Loom), "wick copied the loom timeline fields")
	_expect(_field_key(Wick) != _field_key(Hive), "wick copied the hive timeline fields")
	_expect(_field_key(Wick) != _field_key(Glass), "wick copied the glass timeline fields")
	_expect(_field_key(Wick) != _field_key(Press), "wick copied the press timeline fields")
	_expect(_field_key(Wick) != _field_key(Assay), "wick copied the assay timeline fields")
	_expect(_field_key(Wick) != _field_key(Kiln), "wick copied the kiln timeline fields")
	_expect(_field_key(Wick) != _field_key(Tide), "wick copied the tide timeline fields")
	_expect(_field_key(Wick) != _field_key(Night), "wick copied the night timeline fields")
	_expect(_field_key(Wick) != _field_key(Salt), "wick copied the salt timeline fields")
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	for exhibit in Wick.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		_expect(not seen.has(exhibit_id), "duplicate wick id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Wick.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Wick.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Wick.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Wick.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "wick should have two slips with two hidden facts, found %d" % paired_hidden)
	for hour in Wick.HOURS:
		_expect(stated.has(hour), "wick hour %s is absent from the exhibits" % hour)


func _test_wick_unique_model() -> void:
	var models := Solver.enumerate(Wick.EXHIBITS, Wick)
	print("wick models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one wick model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Quin", "wick taker")
	_expect(str(model["place"]) == "loft", "wick place")
	_expect(str(model["hour"]) == "4", "wick hour")
	_expect(str(model["oiler"]) == "Mara", "wick oiler")
	_expect(str(model["oil_place"]) == "stair", "wick oil place")
	_expect(str(model["oil_hour"]) == "2", "wick oil hour")
	_expect(str(model["watcher"]) == "Sable", "wick watcher")
	_expect(str(model["watch_hour"]) == "3", "wick watch hour")
	_expect(str(model["seen_from"]) == "gallery", "wick seen from")
	_expect(str(model["purpose"]) == "hold_fog", "wick purpose")
	_expect(str(model["watch_place"]) == "gallery", "wick watch place")
	_expect(str(model["snuffer_place"]) == "stair", "wick snuffer place")
	_expect(str(model["gallery_hour"]) == "5", "wick gallery hour")
	_expect(str(model["stair_hour"]) == "6", "wick stair hour")
	for hour in Wick.HOURS:
		var used := false
		for field in Wick.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "wick hour %s is blank in the true timeline" % hour)
	for place in Wick.PLACES:
		var place_used := false
		for field in Wick.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "wick room %s is blank in the true timeline" % place)
	for person in Wick.PEOPLE:
		var person_used := false
		for field in Wick.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "wick person %s is blank in the true timeline" % person)
	_expect(Wick.timeline(model) == WICK_TIMELINE, "wick timeline drifted:\n%s" % Wick.timeline(model))
	for exhibit in Wick.EXHIBITS:
		_expect(Wick.holds(exhibit, model), "%s rejects the wick timeline" % exhibit["id"])


func _test_wick_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Wick.EXHIBITS, Wick)
	for exhibit in Wick.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Wick.without(exhibit_id), Wick)
		print("wick without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "wick %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Wick.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "wick %s removal did not admit a timeline it forbids" % exhibit_id)


func _test_wick_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	for who in Wick.PEOPLE:
		for place in Wick.PLACES:
			for hour in Wick.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == WICK_TRUE["who"] and place == WICK_TRUE["place"] and hour == WICK_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Wick)
					print("wick true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true wick theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "wick acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(WICK_TIMELINE) >= 0, "wick acceptance should give the timeline")
					_expect(str(result["message"]).find("Quin") >= 0, "wick acceptance omits Quin")
					_expect(str(result["message"]).find("loft") >= 0, "wick acceptance omits the loft")
					_expect(str(result["message"]).find("4") >= 0, "wick acceptance omits 4")
					_expect(str(result["message"]).find("so the lamp would hold through the fog") >= 0, "wick acceptance omits the fog")
					_expect(Wick.conflicting_ids(theory).is_empty(), "true wick theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Wick)
					rejected += 1
	for outsider in ["Holt", "Lin", "Opal", "Vesper", "Nell", "Ivo", "Nessa", "Quill", "Pim", "Fenn"]:
		_expect_rejected({"who": outsider, "place": "loft", "hour": "4"}, Wick)
	print("wick theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d wick theories" % accepted)
	_expect(rejected >= 2, "rejected %d wick theories" % rejected)


func _test_wick_near_misses() -> void:
	var misses := [
		{"who": "Quin", "place": "loft", "hour": "5", "titles": ["Watch leaf", "Fog line", "Lamp order"]},
		{"who": "Quin", "place": "loft", "hour": "3", "titles": ["Watch leaf", "Fog line", "Lamp order"]},
		{"who": "Quin", "place": "gallery", "hour": "4", "titles": ["Loft board", "Watch margin", "Fill chit"]},
		{"who": "Mara", "place": "loft", "hour": "4", "titles": ["Oil note", "Gallery glass", "Hook slip"]},
	]
	var wrong_hour_in_loft := 0
	var wrong_place_at_hour := 0
	var wrong_person_in_loft := 0
	for theory in misses:
		_expect_rejected(theory, Wick)
		var result: Dictionary = Verdict.submit(theory, Wick)
		var message := str(result["message"])
		for title in theory["titles"]:
			_expect(message.find(str(title)) >= 0, "near-miss omits %s: %s" % [title, message])
		if str(theory["who"]) == "Quin" and str(theory["place"]) == "loft" and str(theory["hour"]) != "4":
			wrong_hour_in_loft += 1
		if str(theory["who"]) == "Quin" and str(theory["place"]) != "loft" and str(theory["hour"]) == "4":
			wrong_place_at_hour += 1
		if str(theory["who"]) != "Quin" and str(theory["place"]) == "loft" and str(theory["hour"]) == "4":
			wrong_person_in_loft += 1
	print("wick near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four wick near-misses, found %d" % misses.size())
	_expect(wrong_hour_in_loft == 2, "two near-misses should keep Quin in the loft at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Quin at 4 in another room")
	_expect(wrong_person_in_loft >= 1, "a near-miss should keep the loft at 4 for another person")


func _test_wick_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
		"who stopped the night bell",
		"where they stopped the bell",
		"at which hour they stopped the bell",
		"who scored the salt mark",
		"where they scored the mark",
		"at which hour they scored the mark",
	]
	var cases := [
		{"theory": {"who": "", "place": "loft", "hour": "4"}, "present": ["who trimmed the wick"], "absent": ["where they trimmed the wick", "at which hour they trimmed the wick"]},
		{"theory": {"who": "Quin", "place": "", "hour": "4"}, "present": ["where they trimmed the wick"], "absent": ["who trimmed the wick", "at which hour they trimmed the wick"]},
		{"theory": {"who": "Quin", "place": "loft", "hour": ""}, "present": ["at which hour they trimmed the wick"], "absent": ["who trimmed the wick", "where they trimmed the wick"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who trimmed the wick", "where they trimmed the wick", "at which hour they trimmed the wick"], "absent": []},
		{"theory": {}, "present": ["who trimmed the wick", "where they trimmed the wick", "at which hour they trimmed the wick"], "absent": []},
		{"theory": {"who": "Sable", "place": "", "hour": "6"}, "present": ["where they trimmed the wick"], "absent": ["who trimmed the wick", "at which hour they trimmed the wick"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Wick)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "wick incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "wick incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "wick incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "wick incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "wick incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "wick missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "wick named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "wick incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("wick incomplete submissions refused with the missing slot")


func _test_anneal_file_shape() -> void:
	_expect(Anneal.EXHIBITS.size() == 9, "anneal exhibit count is %d" % Anneal.EXHIBITS.size())
	_expect(Anneal.PEOPLE.size() == 3, "anneal cast should be three people")
	_expect(Anneal.PLACES.size() == 3, "anneal room count is %d" % Anneal.PLACES.size())
	_expect(Anneal.HOURS.size() == 5, "anneal hour list length is %d" % Anneal.HOURS.size())
	_expect(Anneal.TITLE == "The glass anneal", "anneal title")
	_expect(Anneal.TITLE != CaseData.TITLE and Anneal.TITLE != Rehearsal.TITLE and Anneal.TITLE != Gilt.TITLE and Anneal.TITLE != Ferry.TITLE and Anneal.TITLE != Weather.TITLE and Anneal.TITLE != Loom.TITLE and Anneal.TITLE != Hive.TITLE and Anneal.TITLE != Glass.TITLE and Anneal.TITLE != Press.TITLE and Anneal.TITLE != Assay.TITLE and Anneal.TITLE != Kiln.TITLE and Anneal.TITLE != Tide.TITLE and Anneal.TITLE != Night.TITLE and Anneal.TITLE != Salt.TITLE and Anneal.TITLE != Wick.TITLE, "anneal shares a title")
	_expect(Anneal.FILE_CODE == "CW-16", "anneal file code")
	_expect(Anneal.FILE_CODE != CaseData.FILE_CODE and Anneal.FILE_CODE != Rehearsal.FILE_CODE and Anneal.FILE_CODE != Gilt.FILE_CODE and Anneal.FILE_CODE != Ferry.FILE_CODE and Anneal.FILE_CODE != Weather.FILE_CODE and Anneal.FILE_CODE != Loom.FILE_CODE and Anneal.FILE_CODE != Hive.FILE_CODE and Anneal.FILE_CODE != Glass.FILE_CODE and Anneal.FILE_CODE != Press.FILE_CODE and Anneal.FILE_CODE != Assay.FILE_CODE and Anneal.FILE_CODE != Kiln.FILE_CODE and Anneal.FILE_CODE != Tide.FILE_CODE and Anneal.FILE_CODE != Night.FILE_CODE and Anneal.FILE_CODE != Salt.FILE_CODE and Anneal.FILE_CODE != Wick.FILE_CODE, "anneal shares a file code")
	_expect(Anneal.HOURS[Anneal.HOURS.size() / 2] == ANNEAL_TRUE["hour"], "glass anneal should be the middle hour")
	_expect(Anneal.HOURS[0] != ANNEAL_TRUE["hour"], "glass anneal should not be the earliest hour")
	_expect(Anneal.HOURS[Anneal.HOURS.size() - 1] != ANNEAL_TRUE["hour"], "glass anneal should not be the latest hour")
	var counts := _player_pin_counts(Anneal)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "anneal pin counts are %s" % str(counts))
	_expect(counts != _player_pin_counts(CaseData), "anneal copied the spare-key pin pattern")
	_expect(counts != _player_pin_counts(Rehearsal), "anneal copied the rehearsal pin pattern")
	_expect(counts != _player_pin_counts(Gilt), "anneal copied the gilt pin pattern")
	_expect(counts != _player_pin_counts(Ferry), "anneal copied the ferry pin pattern")
	_expect(counts != _player_pin_counts(Weather), "anneal copied the weather pin pattern")
	_expect(counts != _player_pin_counts(Loom), "anneal copied the loom pin pattern")
	_expect(counts != _player_pin_counts(Hive), "anneal copied the hive pin pattern")
	_expect(counts != _player_pin_counts(Glass), "anneal copied the glass pin pattern")
	_expect(counts != _player_pin_counts(Press), "anneal copied the press pin pattern")
	_expect(counts != _player_pin_counts(Assay), "anneal copied the assay pin pattern")
	_expect(counts == _player_pin_counts(Kiln), "glass anneal should keep the kiln chalk pin rhythm")
	_expect(counts == _player_pin_counts(Tide), "glass anneal should keep the tide ledger pin rhythm")
	_expect(counts == _player_pin_counts(Night), "glass anneal should keep the night bell pin rhythm")
	_expect(counts == _player_pin_counts(Salt), "glass anneal should keep the salt mark pin rhythm")
	_expect(counts == _player_pin_counts(Wick), "glass anneal should keep the wick trim pin rhythm")
	_expect(_field_key(Anneal) != _field_key(CaseData), "anneal copied the spare-key timeline fields")
	_expect(_field_key(Anneal) != _field_key(Rehearsal), "anneal copied the rehearsal timeline fields")
	_expect(_field_key(Anneal) != _field_key(Gilt), "anneal copied the gilt timeline fields")
	_expect(_field_key(Anneal) != _field_key(Ferry), "anneal copied the ferry timeline fields")
	_expect(_field_key(Anneal) != _field_key(Weather), "anneal copied the weather timeline fields")
	_expect(_field_key(Anneal) != _field_key(Loom), "anneal copied the loom timeline fields")
	_expect(_field_key(Anneal) != _field_key(Hive), "anneal copied the hive timeline fields")
	_expect(_field_key(Anneal) != _field_key(Glass), "anneal copied the glass timeline fields")
	_expect(_field_key(Anneal) != _field_key(Press), "anneal copied the press timeline fields")
	_expect(_field_key(Anneal) != _field_key(Assay), "anneal copied the assay timeline fields")
	_expect(_field_key(Anneal) != _field_key(Kiln), "anneal copied the kiln timeline fields")
	_expect(_field_key(Anneal) != _field_key(Tide), "anneal copied the tide timeline fields")
	_expect(_field_key(Anneal) != _field_key(Night), "anneal copied the night timeline fields")
	_expect(_field_key(Anneal) != _field_key(Salt), "anneal copied the salt timeline fields")
	_expect(_field_key(Anneal) != _field_key(Wick), "anneal copied the wick timeline fields")
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	for exhibit in Anneal.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		_expect(not seen.has(exhibit_id), "duplicate anneal id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Anneal.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Anneal.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Anneal.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Anneal.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "anneal should have two slips with two hidden facts, found %d" % paired_hidden)
	for hour in Anneal.HOURS:
		_expect(stated.has(hour), "anneal hour %s is absent from the exhibits" % hour)


func _test_anneal_unique_model() -> void:
	var models := Solver.enumerate(Anneal.EXHIBITS, Anneal)
	print("anneal models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one anneal model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Tess", "anneal taker")
	_expect(str(model["place"]) == "lehr", "anneal place")
	_expect(str(model["hour"]) == "10", "anneal hour")
	_expect(str(model["gatherer"]) == "Ivo", "anneal gatherer")
	_expect(str(model["gather_place"]) == "pot", "anneal gather place")
	_expect(str(model["charge_hour"]) == "8", "anneal charge hour")
	_expect(str(model["smoother"]) == "Wynn", "anneal smoother")
	_expect(str(model["smooth_hour"]) == "9", "anneal smooth hour")
	_expect(str(model["view_place"]) == "marver", "anneal seen from")
	_expect(str(model["purpose"]) == "cool_pane", "anneal purpose")
	_expect(str(model["smooth_place"]) == "marver", "anneal smooth place")
	_expect(str(model["pontil_place"]) == "pot", "anneal pontil place")
	_expect(str(model["clear_hour"]) == "11", "anneal clear hour")
	_expect(str(model["latch_hour"]) == "12", "anneal latch hour")
	for hour in Anneal.HOURS:
		var used := false
		for field in Anneal.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "anneal hour %s is blank in the true timeline" % hour)
	for place in Anneal.PLACES:
		var place_used := false
		for field in Anneal.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "anneal room %s is blank in the true timeline" % place)
	for person in Anneal.PEOPLE:
		var person_used := false
		for field in Anneal.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "anneal person %s is blank in the true timeline" % person)
	_expect(Anneal.timeline(model) == ANNEAL_TIMELINE, "anneal timeline drifted:\n%s" % Anneal.timeline(model))
	for exhibit in Anneal.EXHIBITS:
		_expect(Anneal.holds(exhibit, model), "%s rejects the anneal timeline" % exhibit["id"])


func _test_anneal_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Anneal.EXHIBITS, Anneal)
	for exhibit in Anneal.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Anneal.without(exhibit_id), Anneal)
		print("anneal without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "anneal %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Anneal.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "anneal %s removal did not admit a timeline it forbids" % exhibit_id)


func _test_anneal_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	for who in Anneal.PEOPLE:
		for place in Anneal.PLACES:
			for hour in Anneal.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == ANNEAL_TRUE["who"] and place == ANNEAL_TRUE["place"] and hour == ANNEAL_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Anneal)
					print("anneal true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true anneal theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "anneal acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(ANNEAL_TIMELINE) >= 0, "anneal acceptance should give the timeline")
					_expect(str(result["message"]).find("Tess") >= 0, "anneal acceptance omits Tess")
					_expect(str(result["message"]).find("lehr") >= 0, "anneal acceptance omits the lehr")
					_expect(str(result["message"]).find("10") >= 0, "anneal acceptance omits 10")
					_expect(str(result["message"]).find("so the pane would cool without a crack") >= 0, "anneal acceptance omits the crack")
					_expect(Anneal.conflicting_ids(theory).is_empty(), "true anneal theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Anneal)
					rejected += 1
	for outsider in ["Quin", "Mara", "Sable", "Holt", "Lin", "Opal", "Nell", "Nessa", "Quill", "Pim"]:
		_expect_rejected({"who": outsider, "place": "lehr", "hour": "10"}, Anneal)
	print("anneal theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d anneal theories" % accepted)
	_expect(rejected >= 2, "rejected %d anneal theories" % rejected)


func _test_anneal_near_misses() -> void:
	var misses := [
		{"who": "Tess", "place": "lehr", "hour": "11", "titles": ["Shoulder leaf", "Crack note", "Latch order"]},
		{"who": "Tess", "place": "lehr", "hour": "9", "titles": ["Shoulder leaf", "Crack note", "Latch order"]},
		{"who": "Tess", "place": "marver", "hour": "10", "titles": ["Lehr slate", "Shoulder card", "Charge slip"]},
		{"who": "Ivo", "place": "lehr", "hour": "10", "titles": ["Gather note", "Bench pane", "Iron rest"]},
	]
	var wrong_hour_in_lehr := 0
	var wrong_place_at_hour := 0
	var wrong_person_in_lehr := 0
	for theory in misses:
		_expect_rejected(theory, Anneal)
		var result: Dictionary = Verdict.submit(theory, Anneal)
		var message := str(result["message"])
		for title in theory["titles"]:
			_expect(message.find(str(title)) >= 0, "near-miss omits %s: %s" % [title, message])
		if str(theory["who"]) == "Tess" and str(theory["place"]) == "lehr" and str(theory["hour"]) != "10":
			wrong_hour_in_lehr += 1
		if str(theory["who"]) == "Tess" and str(theory["place"]) != "lehr" and str(theory["hour"]) == "10":
			wrong_place_at_hour += 1
		if str(theory["who"]) != "Tess" and str(theory["place"]) == "lehr" and str(theory["hour"]) == "10":
			wrong_person_in_lehr += 1
	print("anneal near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four anneal near-misses, found %d" % misses.size())
	_expect(wrong_hour_in_lehr == 2, "two near-misses should keep Tess in the lehr at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Tess at 10 in another room")
	_expect(wrong_person_in_lehr >= 1, "a near-miss should keep the lehr at 10 for another person")


func _test_anneal_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
		"who stopped the night bell",
		"where they stopped the bell",
		"at which hour they stopped the bell",
		"who scored the salt mark",
		"where they scored the mark",
		"at which hour they scored the mark",
		"who trimmed the wick",
		"where they trimmed the wick",
		"at which hour they trimmed the wick",
	]
	var cases := [
		{"theory": {"who": "", "place": "lehr", "hour": "10"}, "present": ["who annealed the gather"], "absent": ["where they annealed the gather", "at which hour they annealed the gather"]},
		{"theory": {"who": "Tess", "place": "", "hour": "10"}, "present": ["where they annealed the gather"], "absent": ["who annealed the gather", "at which hour they annealed the gather"]},
		{"theory": {"who": "Tess", "place": "lehr", "hour": ""}, "present": ["at which hour they annealed the gather"], "absent": ["who annealed the gather", "where they annealed the gather"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who annealed the gather", "where they annealed the gather", "at which hour they annealed the gather"], "absent": []},
		{"theory": {}, "present": ["who annealed the gather", "where they annealed the gather", "at which hour they annealed the gather"], "absent": []},
		{"theory": {"who": "Wynn", "place": "", "hour": "12"}, "present": ["where they annealed the gather"], "absent": ["who annealed the gather", "at which hour they annealed the gather"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Anneal)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "anneal incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "anneal incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "anneal incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "anneal incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "anneal incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "anneal missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "anneal named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "anneal incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("anneal incomplete submissions refused with the missing slot")



func _test_graft_file_shape() -> void:
	_expect(Graft.EXHIBITS.size() == 9, "graft exhibit count is %d" % Graft.EXHIBITS.size())
	_expect(Graft.PEOPLE.size() == 3, "graft cast should be three people")
	_expect(Graft.PLACES.size() == 3, "graft room count is %d" % Graft.PLACES.size())
	_expect(Graft.HOURS.size() == 5, "graft hour list length is %d" % Graft.HOURS.size())
	_expect(Graft.TITLE == "The orchard graft", "graft title")
	_expect(Graft.TITLE != CaseData.TITLE and Graft.TITLE != Rehearsal.TITLE and Graft.TITLE != Gilt.TITLE and Graft.TITLE != Ferry.TITLE and Graft.TITLE != Weather.TITLE and Graft.TITLE != Loom.TITLE and Graft.TITLE != Hive.TITLE and Graft.TITLE != Glass.TITLE and Graft.TITLE != Press.TITLE and Graft.TITLE != Assay.TITLE and Graft.TITLE != Kiln.TITLE and Graft.TITLE != Tide.TITLE and Graft.TITLE != Night.TITLE and Graft.TITLE != Salt.TITLE and Graft.TITLE != Wick.TITLE and Graft.TITLE != Anneal.TITLE, "graft shares a title")
	_expect(Graft.FILE_CODE == "CW-17", "graft file code")
	_expect(Graft.FILE_CODE != CaseData.FILE_CODE and Graft.FILE_CODE != Rehearsal.FILE_CODE and Graft.FILE_CODE != Gilt.FILE_CODE and Graft.FILE_CODE != Ferry.FILE_CODE and Graft.FILE_CODE != Weather.FILE_CODE and Graft.FILE_CODE != Loom.FILE_CODE and Graft.FILE_CODE != Hive.FILE_CODE and Graft.FILE_CODE != Glass.FILE_CODE and Graft.FILE_CODE != Press.FILE_CODE and Graft.FILE_CODE != Assay.FILE_CODE and Graft.FILE_CODE != Kiln.FILE_CODE and Graft.FILE_CODE != Tide.FILE_CODE and Graft.FILE_CODE != Night.FILE_CODE and Graft.FILE_CODE != Salt.FILE_CODE and Graft.FILE_CODE != Wick.FILE_CODE and Graft.FILE_CODE != Anneal.FILE_CODE, "graft shares a file code")
	_expect(Graft.HOURS[Graft.HOURS.size() / 2] == GRAFT_TRUE["hour"], "orchard graft should be the middle hour")
	_expect(Graft.HOURS[0] != GRAFT_TRUE["hour"], "orchard graft should not be the earliest hour")
	_expect(Graft.HOURS[Graft.HOURS.size() - 1] != GRAFT_TRUE["hour"], "orchard graft should not be the latest hour")
	var counts := _player_pin_counts(Graft)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "graft pin counts are %s" % str(counts))
	_expect(counts != _player_pin_counts(CaseData), "graft copied the spare-key pin pattern")
	_expect(counts != _player_pin_counts(Rehearsal), "graft copied the rehearsal pin pattern")
	_expect(counts != _player_pin_counts(Gilt), "graft copied the gilt pin pattern")
	_expect(counts != _player_pin_counts(Ferry), "graft copied the ferry pin pattern")
	_expect(counts != _player_pin_counts(Weather), "graft copied the weather pin pattern")
	_expect(counts != _player_pin_counts(Loom), "graft copied the loom pin pattern")
	_expect(counts != _player_pin_counts(Hive), "graft copied the hive pin pattern")
	_expect(counts != _player_pin_counts(Glass), "graft copied the glass pin pattern")
	_expect(counts != _player_pin_counts(Press), "graft copied the press pin pattern")
	_expect(counts != _player_pin_counts(Assay), "graft copied the assay pin pattern")
	_expect(counts == _player_pin_counts(Kiln), "orchard graft should keep the kiln chalk pin rhythm")
	_expect(counts == _player_pin_counts(Tide), "orchard graft should keep the tide ledger pin rhythm")
	_expect(counts == _player_pin_counts(Night), "orchard graft should keep the night bell pin rhythm")
	_expect(counts == _player_pin_counts(Salt), "orchard graft should keep the salt mark pin rhythm")
	_expect(counts == _player_pin_counts(Wick), "orchard graft should keep the wick trim pin rhythm")
	_expect(counts == _player_pin_counts(Anneal), "orchard graft should keep the glass anneal pin rhythm")
	_expect(_field_key(Graft) != _field_key(CaseData), "graft copied the spare-key timeline fields")
	_expect(_field_key(Graft) != _field_key(Rehearsal), "graft copied the rehearsal timeline fields")
	_expect(_field_key(Graft) != _field_key(Gilt), "graft copied the gilt timeline fields")
	_expect(_field_key(Graft) != _field_key(Ferry), "graft copied the ferry timeline fields")
	_expect(_field_key(Graft) != _field_key(Weather), "graft copied the weather timeline fields")
	_expect(_field_key(Graft) != _field_key(Loom), "graft copied the loom timeline fields")
	_expect(_field_key(Graft) != _field_key(Hive), "graft copied the hive timeline fields")
	_expect(_field_key(Graft) != _field_key(Glass), "graft copied the glass timeline fields")
	_expect(_field_key(Graft) != _field_key(Press), "graft copied the press timeline fields")
	_expect(_field_key(Graft) != _field_key(Assay), "graft copied the assay timeline fields")
	_expect(_field_key(Graft) != _field_key(Kiln), "graft copied the kiln timeline fields")
	_expect(_field_key(Graft) != _field_key(Tide), "graft copied the tide timeline fields")
	_expect(_field_key(Graft) != _field_key(Night), "graft copied the night timeline fields")
	_expect(_field_key(Graft) != _field_key(Salt), "graft copied the salt timeline fields")
	_expect(_field_key(Graft) != _field_key(Wick), "graft copied the wick timeline fields")
	_expect(_field_key(Graft) != _field_key(Anneal), "graft copied the anneal timeline fields")
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	for exhibit in Graft.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		_expect(not seen.has(exhibit_id), "duplicate graft id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Graft.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Graft.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Graft.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Graft.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "graft should have two slips with two hidden facts, found %d" % paired_hidden)
	for hour in Graft.HOURS:
		_expect(stated.has(hour), "graft hour %s is absent from the exhibits" % hour)

func _test_graft_unique_model() -> void:
	var models := Solver.enumerate(Graft.EXHIBITS, Graft)
	print("graft models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one graft model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Calder", "graft taker")
	_expect(str(model["place"]) == "nursery", "graft place")
	_expect(str(model["hour"]) == "16", "graft hour")
	_expect(str(model["cutter"]) == "Ness", "graft cutter")
	_expect(str(model["cut_place"]) == "row", "graft cut place")
	_expect(str(model["cut_hour"]) == "15", "graft cut hour")
	_expect(str(model["seen_place"]) == "row", "graft seen from")
	_expect(str(model["binder"]) == "Edda", "graft binder")
	_expect(str(model["purpose"]) == "take_row", "graft purpose")
	_expect(str(model["tie_place"]) == "gate", "graft tie place")
	_expect(str(model["knife_place"]) == "gate", "graft knife place")
	_expect(str(model["water_hour"]) == "14", "graft water hour")
	_expect(str(model["shut_hour"]) == "17", "graft shut hour")
	_expect(str(model["frost_hour"]) == "18", "graft frost hour")
	for hour in Graft.HOURS:
		var used := false
		for field in Graft.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "graft hour %s is blank in the true timeline" % hour)
	for place in Graft.PLACES:
		var place_used := false
		for field in Graft.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "graft room %s is blank in the true timeline" % place)
	for person in Graft.PEOPLE:
		var person_used := false
		for field in Graft.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "graft person %s is blank in the true timeline" % person)
	_expect(Graft.timeline(model) == GRAFT_TIMELINE, "graft timeline drifted:\n%s" % Graft.timeline(model))
	for exhibit in Graft.EXHIBITS:
		_expect(Graft.holds(exhibit, model), "%s rejects the graft timeline" % exhibit["id"])

func _test_graft_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Graft.EXHIBITS, Graft)
	for exhibit in Graft.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Graft.without(exhibit_id), Graft)
		print("graft without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "graft %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Graft.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "graft %s removal did not admit a timeline it forbids" % exhibit_id)

func _test_graft_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	for who in Graft.PEOPLE:
		for place in Graft.PLACES:
			for hour in Graft.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == GRAFT_TRUE["who"] and place == GRAFT_TRUE["place"] and hour == GRAFT_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Graft)
					print("graft true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true graft theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "graft acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(GRAFT_TIMELINE) >= 0, "graft acceptance should give the timeline")
					_expect(str(result["message"]).find("Calder") >= 0, "graft acceptance omits Calder")
					_expect(str(result["message"]).find("nursery") >= 0, "graft acceptance omits the nursery")
					_expect(str(result["message"]).find("16") >= 0, "graft acceptance omits 16")
					_expect(str(result["message"]).find("so the row would take before the frost") >= 0, "graft acceptance omits the frost")
					_expect(Graft.conflicting_ids(theory).is_empty(), "true graft theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Graft)
					rejected += 1
	for outsider in ["Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal", "Nell"]:
		_expect_rejected({"who": outsider, "place": "nursery", "hour": "16"}, Graft)
	print("graft theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d graft theories" % accepted)
	_expect(rejected >= 2, "rejected %d graft theories" % rejected)

func _test_graft_near_misses() -> void:
	var misses := [
		{"who": "Calder", "place": "nursery", "hour": "17", "titles": ["Hour leaf", "Take note", "Shut order"]},
		{"who": "Calder", "place": "nursery", "hour": "15", "titles": ["Hour leaf", "Take note", "Shut order"]},
		{"who": "Calder", "place": "row", "hour": "16", "titles": ["Bench slate", "Raffia card", "Water slip"]},
		{"who": "Ness", "place": "nursery", "hour": "16", "titles": ["Scion note", "Path sight", "Knife peg"]},
	]
	var wrong_hour_in_nursery := 0
	var wrong_place_at_hour := 0
	var wrong_person_in_nursery := 0
	for theory in misses:
		_expect_rejected(theory, Graft)
		var result: Dictionary = Verdict.submit(theory, Graft)
		var message := str(result["message"])
		for title in theory["titles"]:
			_expect(message.find(str(title)) >= 0, "near-miss omits %s: %s" % [title, message])
		if str(theory["who"]) == "Calder" and str(theory["place"]) == "nursery" and str(theory["hour"]) != "16":
			wrong_hour_in_nursery += 1
		if str(theory["who"]) == "Calder" and str(theory["place"]) != "nursery" and str(theory["hour"]) == "16":
			wrong_place_at_hour += 1
		if str(theory["who"]) != "Calder" and str(theory["place"]) == "nursery" and str(theory["hour"]) == "16":
			wrong_person_in_nursery += 1
	print("graft near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four graft near-misses, found %d" % misses.size())
	_expect(wrong_hour_in_nursery == 2, "two near-misses should keep Calder in the nursery at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Calder at 16 in another room")
	_expect(wrong_person_in_nursery >= 1, "a near-miss should keep the nursery at 16 for another person")

func _test_graft_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
		"who stopped the night bell",
		"where they stopped the bell",
		"at which hour they stopped the bell",
		"who scored the salt mark",
		"where they scored the mark",
		"at which hour they scored the mark",
		"who trimmed the wick",
		"where they trimmed the wick",
		"at which hour they trimmed the wick",
		"who annealed the gather",
		"where they annealed the gather",
		"at which hour they annealed the gather",
	]
	var cases := [
		{"theory": {"who": "", "place": "nursery", "hour": "16"}, "present": ["who grafted the scion"], "absent": ["where they grafted the scion", "at which hour they grafted the scion"]},
		{"theory": {"who": "Calder", "place": "", "hour": "16"}, "present": ["where they grafted the scion"], "absent": ["who grafted the scion", "at which hour they grafted the scion"]},
		{"theory": {"who": "Calder", "place": "nursery", "hour": ""}, "present": ["at which hour they grafted the scion"], "absent": ["who grafted the scion", "where they grafted the scion"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who grafted the scion", "where they grafted the scion", "at which hour they grafted the scion"], "absent": []},
		{"theory": {}, "present": ["who grafted the scion", "where they grafted the scion", "at which hour they grafted the scion"], "absent": []},
		{"theory": {"who": "Edda", "place": "", "hour": "18"}, "present": ["where they grafted the scion"], "absent": ["who grafted the scion", "at which hour they grafted the scion"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Graft)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "graft incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "graft incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "graft incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "graft incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "graft incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "graft missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "graft named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "graft incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("graft incomplete submissions refused with the missing slot")
func _test_dye_file_shape() -> void:
	_expect(Dye.EXHIBITS.size() == 9, "dye exhibit count is %d" % Dye.EXHIBITS.size())
	_expect(Dye.PEOPLE.size() == 3, "dye cast should be three people")
	_expect(Dye.PLACES.size() == 3, "dye room count is %d" % Dye.PLACES.size())
	_expect(Dye.HOURS.size() == 5, "dye hour list length is %d" % Dye.HOURS.size())
	_expect(Dye.PEOPLE == ["Pim", "Sera", "Joss"], "dye cast is %s" % str(Dye.PEOPLE))
	_expect(Dye.PLACES == ["vat", "line", "yard"], "dye rooms are %s" % str(Dye.PLACES))
	_expect(Dye.HOURS == ["5", "6", "7", "8", "9"], "dye hours are %s" % str(Dye.HOURS))
	_expect(Dye.TITLE == "The dye vat", "dye title")
	_expect(Dye.TITLE != CaseData.TITLE and Dye.TITLE != Rehearsal.TITLE and Dye.TITLE != Gilt.TITLE and Dye.TITLE != Ferry.TITLE and Dye.TITLE != Weather.TITLE and Dye.TITLE != Loom.TITLE and Dye.TITLE != Hive.TITLE and Dye.TITLE != Glass.TITLE and Dye.TITLE != Press.TITLE and Dye.TITLE != Assay.TITLE and Dye.TITLE != Kiln.TITLE and Dye.TITLE != Tide.TITLE and Dye.TITLE != Night.TITLE and Dye.TITLE != Salt.TITLE and Dye.TITLE != Wick.TITLE and Dye.TITLE != Anneal.TITLE and Dye.TITLE != Graft.TITLE, "dye shares a title")
	_expect(Dye.FILE_CODE == "CW-18", "dye file code")
	_expect(Dye.FILE_CODE != CaseData.FILE_CODE and Dye.FILE_CODE != Rehearsal.FILE_CODE and Dye.FILE_CODE != Gilt.FILE_CODE and Dye.FILE_CODE != Ferry.FILE_CODE and Dye.FILE_CODE != Weather.FILE_CODE and Dye.FILE_CODE != Loom.FILE_CODE and Dye.FILE_CODE != Hive.FILE_CODE and Dye.FILE_CODE != Glass.FILE_CODE and Dye.FILE_CODE != Press.FILE_CODE and Dye.FILE_CODE != Assay.FILE_CODE and Dye.FILE_CODE != Kiln.FILE_CODE and Dye.FILE_CODE != Tide.FILE_CODE and Dye.FILE_CODE != Night.FILE_CODE and Dye.FILE_CODE != Salt.FILE_CODE and Dye.FILE_CODE != Wick.FILE_CODE and Dye.FILE_CODE != Anneal.FILE_CODE and Dye.FILE_CODE != Graft.FILE_CODE, "dye shares a file code")
	_expect(Dye.HOURS[Dye.HOURS.size() / 2] == DYE_TRUE["hour"], "dye vat should be the middle hour")
	_expect(Dye.HOURS[0] != DYE_TRUE["hour"], "dye vat should not be the earliest hour")
	_expect(Dye.HOURS[Dye.HOURS.size() - 1] != DYE_TRUE["hour"], "dye vat should not be the latest hour")
	var counts := _player_pin_counts(Dye)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "dye pin counts are %s" % str(counts))
	_expect(counts != _player_pin_counts(CaseData), "dye copied the spare-key pin pattern")
	_expect(counts != _player_pin_counts(Rehearsal), "dye copied the rehearsal pin pattern")
	_expect(counts != _player_pin_counts(Gilt), "dye copied the gilt pin pattern")
	_expect(counts != _player_pin_counts(Ferry), "dye copied the ferry pin pattern")
	_expect(counts != _player_pin_counts(Weather), "dye copied the weather pin pattern")
	_expect(counts != _player_pin_counts(Loom), "dye copied the loom pin pattern")
	_expect(counts != _player_pin_counts(Hive), "dye copied the hive pin pattern")
	_expect(counts != _player_pin_counts(Glass), "dye copied the glass pin pattern")
	_expect(counts != _player_pin_counts(Press), "dye copied the press pin pattern")
	_expect(counts != _player_pin_counts(Assay), "dye copied the assay pin pattern")
	_expect(counts == _player_pin_counts(Kiln), "dye vat should keep the kiln chalk pin rhythm")
	_expect(counts == _player_pin_counts(Tide), "dye vat should keep the tide ledger pin rhythm")
	_expect(counts == _player_pin_counts(Night), "dye vat should keep the night bell pin rhythm")
	_expect(counts == _player_pin_counts(Salt), "dye vat should keep the salt mark pin rhythm")
	_expect(counts == _player_pin_counts(Wick), "dye vat should keep the wick trim pin rhythm")
	_expect(counts == _player_pin_counts(Anneal), "dye vat should keep the glass anneal pin rhythm")
	_expect(counts == _player_pin_counts(Graft), "dye vat should keep the orchard graft pin rhythm")
	_expect(_field_key(Dye) != _field_key(CaseData), "dye copied the spare-key timeline fields")
	_expect(_field_key(Dye) != _field_key(Rehearsal), "dye copied the rehearsal timeline fields")
	_expect(_field_key(Dye) != _field_key(Gilt), "dye copied the gilt timeline fields")
	_expect(_field_key(Dye) != _field_key(Ferry), "dye copied the ferry timeline fields")
	_expect(_field_key(Dye) != _field_key(Weather), "dye copied the weather timeline fields")
	_expect(_field_key(Dye) != _field_key(Loom), "dye copied the loom timeline fields")
	_expect(_field_key(Dye) != _field_key(Hive), "dye copied the hive timeline fields")
	_expect(_field_key(Dye) != _field_key(Glass), "dye copied the glass timeline fields")
	_expect(_field_key(Dye) != _field_key(Press), "dye copied the press timeline fields")
	_expect(_field_key(Dye) != _field_key(Assay), "dye copied the assay timeline fields")
	_expect(_field_key(Dye) != _field_key(Kiln), "dye copied the kiln timeline fields")
	_expect(_field_key(Dye) != _field_key(Tide), "dye copied the tide timeline fields")
	_expect(_field_key(Dye) != _field_key(Night), "dye copied the night timeline fields")
	_expect(_field_key(Dye) != _field_key(Salt), "dye copied the salt timeline fields")
	_expect(_field_key(Dye) != _field_key(Wick), "dye copied the wick timeline fields")
	_expect(_field_key(Dye) != _field_key(Anneal), "dye copied the anneal timeline fields")
	_expect(_field_key(Dye) != _field_key(Graft), "dye copied the graft timeline fields")
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	var graft_texts := {}
	for old_exhibit in Graft.EXHIBITS:
		graft_texts[str(old_exhibit["text"])] = true
	for exhibit in Dye.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		_expect(not seen.has(exhibit_id), "duplicate dye id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		_expect(not graft_texts.has(str(exhibit["text"])), "dye vat copied a graft sentence")
		_expect(str(exhibit["text"]).find("grafted") == -1, "%s copies a graft verb" % exhibit_id)
		_expect(str(exhibit["text"]).find("scion") == -1, "%s copies the scion" % exhibit_id)
		_expect(str(exhibit["text"]).find("frost") == -1, "%s copies the frost" % exhibit_id)
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Dye.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Dye.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Dye.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Dye.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "dye should have two slips with two hidden facts, found %d" % paired_hidden)
	for hour in Dye.HOURS:
		_expect(stated.has(hour), "dye hour %s is absent from the exhibits" % hour)

func _test_dye_unique_model() -> void:
	var models := Solver.enumerate(Dye.EXHIBITS, Dye)
	print("dye models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one dye model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Sera", "dye taker")
	_expect(str(model["place"]) == "vat", "dye place")
	_expect(str(model["hour"]) == "7", "dye hour")
	_expect(str(model["winder"]) == "Pim", "dye winder")
	_expect(str(model["wind_place"]) == "yard", "dye wind place")
	_expect(str(model["wind_hour"]) == "6", "dye wind hour")
	_expect(str(model["sight_place"]) == "line", "dye seen from")
	_expect(str(model["stirrer"]) == "Joss", "dye stirrer")
	_expect(str(model["purpose"]) == "take_indigo", "dye purpose")
	_expect(str(model["stir_place"]) == "line", "dye stir place")
	_expect(str(model["paddle_place"]) == "yard", "dye paddle place")
	_expect(str(model["stretch_hour"]) == "5", "dye stretch hour")
	_expect(str(model["rake_hour"]) == "8", "dye rake hour")
	_expect(str(model["lid_hour"]) == "9", "dye lid hour")
	for hour in Dye.HOURS:
		var used := false
		for field in Dye.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "dye hour %s is blank in the true timeline" % hour)
	for place in Dye.PLACES:
		var place_used := false
		for field in Dye.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "dye room %s is blank in the true timeline" % place)
	for person in Dye.PEOPLE:
		var person_used := false
		for field in Dye.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "dye person %s is blank in the true timeline" % person)
	_expect(Dye.timeline(model) == DYE_TIMELINE, "dye timeline drifted:\n%s" % Dye.timeline(model))
	for exhibit in Dye.EXHIBITS:
		_expect(Dye.holds(exhibit, model), "%s rejects the dye timeline" % exhibit["id"])

func _test_dye_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Dye.EXHIBITS, Dye)
	for exhibit in Dye.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Dye.without(exhibit_id), Dye)
		print("dye without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "dye %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Dye.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "dye %s removal did not admit a timeline it forbids" % exhibit_id)

func _test_dye_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	for who in Dye.PEOPLE:
		for place in Dye.PLACES:
			for hour in Dye.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == DYE_TRUE["who"] and place == DYE_TRUE["place"] and hour == DYE_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Dye)
					print("dye true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true dye theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "dye acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(DYE_TIMELINE) >= 0, "dye acceptance should give the timeline")
					_expect(str(result["message"]).find("Sera") >= 0, "dye acceptance omits Sera")
					_expect(str(result["message"]).find("vat") >= 0, "dye acceptance omits the vat")
					_expect(str(result["message"]).find("7") >= 0, "dye acceptance omits 7")
					_expect(str(result["message"]).find("so the line would take the indigo") >= 0, "dye acceptance omits the indigo")
					_expect(str(result["message"]).find("Sera (dip hand) dipped the skein in the vat at 7") >= 0, "dye acceptance omits the dip")
					_expect(Dye.conflicting_ids(theory).is_empty(), "true dye theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Dye)
					_expect(Dye.conflicting_ids(theory).size() >= 2, "%s / %s / %s contradicts fewer than two exhibits" % [who, place, hour])
					rejected += 1
	for outsider in ["Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal", "Nell"]:
		_expect_rejected({"who": outsider, "place": "vat", "hour": "7"}, Dye)
	print("dye theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d dye theories" % accepted)
	_expect(rejected >= 2, "rejected %d dye theories" % rejected)

func _test_dye_near_misses() -> void:
	var misses := [
		{"who": "Sera", "place": "vat", "hour": "8", "titles": ["Dip leaf", "Color note", "Rake order"]},
		{"who": "Sera", "place": "vat", "hour": "6", "titles": ["Dip leaf", "Color note", "Rake order"]},
		{"who": "Sera", "place": "line", "hour": "7", "titles": ["Vat slate", "Indigo card", "Stretch slip"]},
		{"who": "Pim", "place": "vat", "hour": "7", "titles": ["Winder chit", "Line sight", "Paddle peg"]},
	]
	var wrong_hour_in_vat := 0
	var wrong_place_at_hour := 0
	var wrong_person_in_vat := 0
	for theory in misses:
		_expect_rejected(theory, Dye)
		var result: Dictionary = Verdict.submit(theory, Dye)
		var message := str(result["message"])
		for title in theory["titles"]:
			_expect(message.find(str(title)) >= 0, "near-miss omits %s: %s" % [title, message])
		if str(theory["who"]) == "Sera" and str(theory["place"]) == "vat" and str(theory["hour"]) != "7":
			wrong_hour_in_vat += 1
		if str(theory["who"]) == "Sera" and str(theory["place"]) != "vat" and str(theory["hour"]) == "7":
			wrong_place_at_hour += 1
		if str(theory["who"]) != "Sera" and str(theory["place"]) == "vat" and str(theory["hour"]) == "7":
			wrong_person_in_vat += 1
	print("dye near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four dye near-misses, found %d" % misses.size())
	_expect(wrong_hour_in_vat == 2, "two near-misses should keep Sera in the vat at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Sera at 7 in another room")
	_expect(wrong_person_in_vat >= 1, "a near-miss should keep the vat at 7 for another person")

func _test_dye_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
		"who stopped the night bell",
		"where they stopped the bell",
		"at which hour they stopped the bell",
		"who scored the salt mark",
		"where they scored the mark",
		"at which hour they scored the mark",
		"who trimmed the wick",
		"where they trimmed the wick",
		"at which hour they trimmed the wick",
		"who annealed the gather",
		"where they annealed the gather",
		"at which hour they annealed the gather",
		"who grafted the scion",
		"where they grafted the scion",
		"at which hour they grafted the scion",
	]
	var cases := [
		{"theory": {"who": "", "place": "vat", "hour": "7"}, "present": ["who dipped the skein"], "absent": ["where they dipped the skein", "at which hour they dipped the skein"]},
		{"theory": {"who": "Sera", "place": "", "hour": "7"}, "present": ["where they dipped the skein"], "absent": ["who dipped the skein", "at which hour they dipped the skein"]},
		{"theory": {"who": "Sera", "place": "vat", "hour": ""}, "present": ["at which hour they dipped the skein"], "absent": ["who dipped the skein", "where they dipped the skein"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who dipped the skein", "where they dipped the skein", "at which hour they dipped the skein"], "absent": []},
		{"theory": {}, "present": ["who dipped the skein", "where they dipped the skein", "at which hour they dipped the skein"], "absent": []},
		{"theory": {"who": "Joss", "place": "", "hour": "9"}, "present": ["where they dipped the skein"], "absent": ["who dipped the skein", "at which hour they dipped the skein"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Dye)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "dye incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "dye incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "dye incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "dye incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "dye incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "dye missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "dye named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "dye incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("dye incomplete submissions refused with the missing slot")
func _test_tar_file_shape() -> void:
	_expect(Tar.EXHIBITS.size() == 9, "tar exhibit count is %d" % Tar.EXHIBITS.size())
	_expect(Tar.PEOPLE.size() == 3, "tar cast should be three people")
	_expect(Tar.PLACES.size() == 3, "tar room count is %d" % Tar.PLACES.size())
	_expect(Tar.HOURS.size() == 5, "tar hour list length is %d" % Tar.HOURS.size())
	_expect(Tar.PEOPLE == ["Lumen", "Rho", "Kit"], "tar cast is %s" % str(Tar.PEOPLE))
	_expect(Tar.PLACES == ["kettle", "walk", "loft"], "tar rooms are %s" % str(Tar.PLACES))
	_expect(Tar.HOURS == ["4", "5", "6", "7", "8"], "tar hours are %s" % str(Tar.HOURS))
	_expect(Tar.TITLE == "The tar kettle", "tar title")
	_expect(Tar.TITLE != CaseData.TITLE and Tar.TITLE != Rehearsal.TITLE and Tar.TITLE != Gilt.TITLE and Tar.TITLE != Ferry.TITLE and Tar.TITLE != Weather.TITLE and Tar.TITLE != Loom.TITLE and Tar.TITLE != Hive.TITLE and Tar.TITLE != Glass.TITLE and Tar.TITLE != Press.TITLE and Tar.TITLE != Assay.TITLE and Tar.TITLE != Kiln.TITLE and Tar.TITLE != Tide.TITLE and Tar.TITLE != Night.TITLE and Tar.TITLE != Salt.TITLE and Tar.TITLE != Wick.TITLE and Tar.TITLE != Anneal.TITLE and Tar.TITLE != Graft.TITLE and Tar.TITLE != Dye.TITLE, "tar shares a title")
	_expect(Tar.FILE_CODE == "CW-19", "tar file code")
	_expect(Tar.FILE_CODE != CaseData.FILE_CODE and Tar.FILE_CODE != Rehearsal.FILE_CODE and Tar.FILE_CODE != Gilt.FILE_CODE and Tar.FILE_CODE != Ferry.FILE_CODE and Tar.FILE_CODE != Weather.FILE_CODE and Tar.FILE_CODE != Loom.FILE_CODE and Tar.FILE_CODE != Hive.FILE_CODE and Tar.FILE_CODE != Glass.FILE_CODE and Tar.FILE_CODE != Press.FILE_CODE and Tar.FILE_CODE != Assay.FILE_CODE and Tar.FILE_CODE != Kiln.FILE_CODE and Tar.FILE_CODE != Tide.FILE_CODE and Tar.FILE_CODE != Night.FILE_CODE and Tar.FILE_CODE != Salt.FILE_CODE and Tar.FILE_CODE != Wick.FILE_CODE and Tar.FILE_CODE != Anneal.FILE_CODE and Tar.FILE_CODE != Graft.FILE_CODE and Tar.FILE_CODE != Dye.FILE_CODE, "tar shares a file code")
	_expect(Tar.HOURS[Tar.HOURS.size() / 2] == TAR_TRUE["hour"], "tar kettle should be the middle hour")
	_expect(Tar.HOURS[0] != TAR_TRUE["hour"], "tar kettle should not be the earliest hour")
	_expect(Tar.HOURS[Tar.HOURS.size() - 1] != TAR_TRUE["hour"], "tar kettle should not be the latest hour")
	var counts := _player_pin_counts(Tar)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "tar pin counts are %s" % str(counts))
	_expect(counts != _player_pin_counts(CaseData), "tar copied the spare-key pin pattern")
	_expect(counts != _player_pin_counts(Rehearsal), "tar copied the rehearsal pin pattern")
	_expect(counts != _player_pin_counts(Gilt), "tar copied the gilt pin pattern")
	_expect(counts != _player_pin_counts(Ferry), "tar copied the ferry pin pattern")
	_expect(counts != _player_pin_counts(Weather), "tar copied the weather pin pattern")
	_expect(counts != _player_pin_counts(Loom), "tar copied the loom pin pattern")
	_expect(counts != _player_pin_counts(Hive), "tar copied the hive pin pattern")
	_expect(counts != _player_pin_counts(Glass), "tar copied the glass pin pattern")
	_expect(counts != _player_pin_counts(Press), "tar copied the press pin pattern")
	_expect(counts != _player_pin_counts(Assay), "tar copied the assay pin pattern")
	_expect(counts == _player_pin_counts(Kiln), "tar kettle should keep the kiln chalk pin rhythm")
	_expect(counts == _player_pin_counts(Tide), "tar kettle should keep the tide ledger pin rhythm")
	_expect(counts == _player_pin_counts(Night), "tar kettle should keep the night bell pin rhythm")
	_expect(counts == _player_pin_counts(Salt), "tar kettle should keep the salt mark pin rhythm")
	_expect(counts == _player_pin_counts(Wick), "tar kettle should keep the wick trim pin rhythm")
	_expect(counts == _player_pin_counts(Anneal), "tar kettle should keep the glass anneal pin rhythm")
	_expect(counts == _player_pin_counts(Graft), "tar kettle should keep the orchard graft pin rhythm")
	_expect(counts == _player_pin_counts(Dye), "tar kettle should keep the dye vat pin rhythm")
	_expect(_field_key(Tar) != _field_key(CaseData), "tar copied the spare-key timeline fields")
	_expect(_field_key(Tar) != _field_key(Rehearsal), "tar copied the rehearsal timeline fields")
	_expect(_field_key(Tar) != _field_key(Gilt), "tar copied the gilt timeline fields")
	_expect(_field_key(Tar) != _field_key(Ferry), "tar copied the ferry timeline fields")
	_expect(_field_key(Tar) != _field_key(Weather), "tar copied the weather timeline fields")
	_expect(_field_key(Tar) != _field_key(Loom), "tar copied the loom timeline fields")
	_expect(_field_key(Tar) != _field_key(Hive), "tar copied the hive timeline fields")
	_expect(_field_key(Tar) != _field_key(Glass), "tar copied the glass timeline fields")
	_expect(_field_key(Tar) != _field_key(Press), "tar copied the press timeline fields")
	_expect(_field_key(Tar) != _field_key(Assay), "tar copied the assay timeline fields")
	_expect(_field_key(Tar) != _field_key(Kiln), "tar copied the kiln timeline fields")
	_expect(_field_key(Tar) != _field_key(Tide), "tar copied the tide timeline fields")
	_expect(_field_key(Tar) != _field_key(Night), "tar copied the night timeline fields")
	_expect(_field_key(Tar) != _field_key(Salt), "tar copied the salt timeline fields")
	_expect(_field_key(Tar) != _field_key(Wick), "tar copied the wick timeline fields")
	_expect(_field_key(Tar) != _field_key(Anneal), "tar copied the anneal timeline fields")
	_expect(_field_key(Tar) != _field_key(Graft), "tar copied the graft timeline fields")
	_expect(_field_key(Tar) != _field_key(Dye), "tar copied the dye timeline fields")
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	var dye_texts := {}
	for old_exhibit in Dye.EXHIBITS:
		dye_texts[str(old_exhibit["text"])] = true
	for exhibit in Tar.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		_expect(not seen.has(exhibit_id), "duplicate tar id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		_expect(not dye_texts.has(str(exhibit["text"])), "tar kettle copied a dye sentence")
		_expect(str(exhibit["text"]).find("dipped") == -1, "%s copies a dye verb" % exhibit_id)
		_expect(str(exhibit["text"]).find("skein") == -1, "%s copies the skein" % exhibit_id)
		_expect(str(exhibit["text"]).find("indigo") == -1, "%s copies the indigo" % exhibit_id)
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Tar.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Tar.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Tar.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Tar.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "tar should have two slips with two hidden facts, found %d" % paired_hidden)
	for hour in Tar.HOURS:
		_expect(stated.has(hour), "tar hour %s is absent from the exhibits" % hour)

func _test_tar_unique_model() -> void:
	var models := Solver.enumerate(Tar.EXHIBITS, Tar)
	print("tar models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one tar model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Rho", "tar taker")
	_expect(str(model["place"]) == "kettle", "tar place")
	_expect(str(model["hour"]) == "6", "tar hour")
	_expect(str(model["layer"]) == "Lumen", "tar layer")
	_expect(str(model["lay_place"]) == "loft", "tar lay place")
	_expect(str(model["lay_hour"]) == "5", "tar lay hour")
	_expect(str(model["look_place"]) == "walk", "tar seen from")
	_expect(str(model["clerk"]) == "Kit", "tar clerk")
	_expect(str(model["purpose"]) == "take_tar", "tar purpose")
	_expect(str(model["winch_place"]) == "walk", "tar winch place")
	_expect(str(model["hook_place"]) == "loft", "tar hook place")
	_expect(str(model["span_hour"]) == "4", "tar stretch hour")
	_expect(str(model["sweep_hour"]) == "7", "tar sweep hour")
	_expect(str(model["cover_hour"]) == "8", "tar lid hour")
	for hour in Tar.HOURS:
		var used := false
		for field in Tar.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "tar hour %s is blank in the true timeline" % hour)
	for place in Tar.PLACES:
		var place_used := false
		for field in Tar.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "tar room %s is blank in the true timeline" % place)
	for person in Tar.PEOPLE:
		var person_used := false
		for field in Tar.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "tar person %s is blank in the true timeline" % person)
	_expect(Tar.timeline(model) == TAR_TIMELINE, "tar timeline drifted:\n%s" % Tar.timeline(model))
	for exhibit in Tar.EXHIBITS:
		_expect(Tar.holds(exhibit, model), "%s rejects the tar timeline" % exhibit["id"])

func _test_tar_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Tar.EXHIBITS, Tar)
	for exhibit in Tar.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Tar.without(exhibit_id), Tar)
		print("tar without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "tar %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Tar.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "tar %s removal did not admit a timeline it forbids" % exhibit_id)

func _test_tar_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	for who in Tar.PEOPLE:
		for place in Tar.PLACES:
			for hour in Tar.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == TAR_TRUE["who"] and place == TAR_TRUE["place"] and hour == TAR_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Tar)
					print("tar true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true tar theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "tar acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(TAR_TIMELINE) >= 0, "tar acceptance should give the timeline")
					_expect(str(result["message"]).find("Rho") >= 0, "tar acceptance omits Rho")
					_expect(str(result["message"]).find("kettle") >= 0, "tar acceptance omits the kettle")
					_expect(str(result["message"]).find("6") >= 0, "tar acceptance omits 6")
					_expect(str(result["message"]).find("so the walk would take the tar") >= 0, "tar acceptance omits the tar")
					_expect(str(result["message"]).find("Rho (tar hand) tarred the rope in the kettle at 6") >= 0, "tar acceptance omits the tarring")
					_expect(Tar.conflicting_ids(theory).is_empty(), "true tar theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Tar)
					_expect(Tar.conflicting_ids(theory).size() >= 2, "%s / %s / %s contradicts fewer than two exhibits" % [who, place, hour])
					rejected += 1
	for outsider in ["Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal", "Nell"]:
		_expect_rejected({"who": outsider, "place": "kettle", "hour": "6"}, Tar)
	print("tar theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d tar theories" % accepted)
	_expect(rejected >= 2, "rejected %d tar theories" % rejected)

func _test_tar_near_misses() -> void:
	var misses := [
		{"who": "Rho", "place": "kettle", "hour": "7", "titles": ["Tar leaf", "Pitch note", "Sweep order"]},
		{"who": "Rho", "place": "kettle", "hour": "5", "titles": ["Tar leaf", "Pitch note", "Sweep order"]},
		{"who": "Rho", "place": "walk", "hour": "6", "titles": ["Kettle slate", "Winch card", "Span slip"]},
		{"who": "Lumen", "place": "kettle", "hour": "6", "titles": ["Rope chit", "Walk sight", "Hook peg"]},
	]
	var wrong_hour_in_kettle := 0
	var wrong_place_at_hour := 0
	var wrong_person_in_kettle := 0
	for theory in misses:
		_expect_rejected(theory, Tar)
		var result: Dictionary = Verdict.submit(theory, Tar)
		var message := str(result["message"])
		for title in theory["titles"]:
			_expect(message.find(str(title)) >= 0, "near-miss omits %s: %s" % [title, message])
		if str(theory["who"]) == "Rho" and str(theory["place"]) == "kettle" and str(theory["hour"]) != "6":
			wrong_hour_in_kettle += 1
		if str(theory["who"]) == "Rho" and str(theory["place"]) != "kettle" and str(theory["hour"]) == "6":
			wrong_place_at_hour += 1
		if str(theory["who"]) != "Rho" and str(theory["place"]) == "kettle" and str(theory["hour"]) == "6":
			wrong_person_in_kettle += 1
	print("tar near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four tar near-misses, found %d" % misses.size())
	_expect(wrong_hour_in_kettle == 2, "two near-misses should keep Rho in the kettle at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Rho at 6 in another room")
	_expect(wrong_person_in_kettle >= 1, "a near-miss should keep the kettle at 6 for another person")

func _test_tar_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
		"who stopped the night bell",
		"where they stopped the bell",
		"at which hour they stopped the bell",
		"who scored the salt mark",
		"where they scored the mark",
		"at which hour they scored the mark",
		"who trimmed the wick",
		"where they trimmed the wick",
		"at which hour they trimmed the wick",
		"who annealed the gather",
		"where they annealed the gather",
		"at which hour they annealed the gather",
		"who grafted the scion",
		"where they grafted the scion",
		"at which hour they grafted the scion",
		"who dipped the skein",
		"where they dipped the skein",
		"at which hour they dipped the skein",
	]
	var cases := [
		{"theory": {"who": "", "place": "kettle", "hour": "6"}, "present": ["who tarred the rope"], "absent": ["where they tarred the rope", "at which hour they tarred the rope"]},
		{"theory": {"who": "Rho", "place": "", "hour": "6"}, "present": ["where they tarred the rope"], "absent": ["who tarred the rope", "at which hour they tarred the rope"]},
		{"theory": {"who": "Rho", "place": "kettle", "hour": ""}, "present": ["at which hour they tarred the rope"], "absent": ["who tarred the rope", "where they tarred the rope"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who tarred the rope", "where they tarred the rope", "at which hour they tarred the rope"], "absent": []},
		{"theory": {}, "present": ["who tarred the rope", "where they tarred the rope", "at which hour they tarred the rope"], "absent": []},
		{"theory": {"who": "Kit", "place": "", "hour": "8"}, "present": ["where they tarred the rope"], "absent": ["who tarred the rope", "at which hour they tarred the rope"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Tar)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "tar incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "tar incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "tar incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "tar incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "tar incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "tar missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "tar named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "tar incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("tar incomplete submissions refused with the missing slot")

func _test_cork_file_shape() -> void:
	_expect(Cork.EXHIBITS.size() == 9, "cork exhibit count is %d" % Cork.EXHIBITS.size())
	_expect(Cork.PEOPLE.size() == 3, "cork cast should be three people")
	_expect(Cork.PLACES.size() == 3, "cork room count is %d" % Cork.PLACES.size())
	_expect(Cork.HOURS.size() == 5, "cork hour list length is %d" % Cork.HOURS.size())
	_expect(Cork.PEOPLE == ["Ansel", "Brea", "Colm"], "cork cast is %s" % str(Cork.PEOPLE))
	_expect(Cork.PLACES == ["press", "cellar", "bench"], "cork rooms are %s" % str(Cork.PLACES))
	_expect(Cork.HOURS == ["3", "4", "5", "6", "7"], "cork hours are %s" % str(Cork.HOURS))
	_expect(Cork.TITLE == "The cork press", "cork title")
	_expect(Cork.BLURB == "The cork press left its peg at the bottle house. Name who pressed the cork, the room they pressed it in, and the hour.", "cork blurb")
	_expect(Cork.TITLE != CaseData.TITLE and Cork.TITLE != Rehearsal.TITLE and Cork.TITLE != Gilt.TITLE and Cork.TITLE != Ferry.TITLE and Cork.TITLE != Weather.TITLE and Cork.TITLE != Loom.TITLE and Cork.TITLE != Hive.TITLE and Cork.TITLE != Glass.TITLE and Cork.TITLE != Press.TITLE and Cork.TITLE != Assay.TITLE and Cork.TITLE != Kiln.TITLE and Cork.TITLE != Tide.TITLE and Cork.TITLE != Night.TITLE and Cork.TITLE != Salt.TITLE and Cork.TITLE != Wick.TITLE and Cork.TITLE != Anneal.TITLE and Cork.TITLE != Graft.TITLE and Cork.TITLE != Dye.TITLE and Cork.TITLE != Tar.TITLE, "cork shares a title")
	_expect(Cork.FILE_CODE == "CW-20", "cork file code")
	_expect(Cork.FILE_CODE != CaseData.FILE_CODE and Cork.FILE_CODE != Rehearsal.FILE_CODE and Cork.FILE_CODE != Gilt.FILE_CODE and Cork.FILE_CODE != Ferry.FILE_CODE and Cork.FILE_CODE != Weather.FILE_CODE and Cork.FILE_CODE != Loom.FILE_CODE and Cork.FILE_CODE != Hive.FILE_CODE and Cork.FILE_CODE != Glass.FILE_CODE and Cork.FILE_CODE != Press.FILE_CODE and Cork.FILE_CODE != Assay.FILE_CODE and Cork.FILE_CODE != Kiln.FILE_CODE and Cork.FILE_CODE != Tide.FILE_CODE and Cork.FILE_CODE != Night.FILE_CODE and Cork.FILE_CODE != Salt.FILE_CODE and Cork.FILE_CODE != Wick.FILE_CODE and Cork.FILE_CODE != Anneal.FILE_CODE and Cork.FILE_CODE != Graft.FILE_CODE and Cork.FILE_CODE != Dye.FILE_CODE and Cork.FILE_CODE != Tar.FILE_CODE, "cork shares a file code")
	_expect(Cork.HOURS[Cork.HOURS.size() / 2] == CORK_TRUE["hour"], "cork press should be the middle hour")
	_expect(Cork.HOURS[0] != CORK_TRUE["hour"], "cork press should not be the earliest hour")
	_expect(Cork.HOURS[Cork.HOURS.size() - 1] != CORK_TRUE["hour"], "cork press should not be the latest hour")
	var counts := _player_pin_counts(Cork)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "cork pin counts are %s" % str(counts))
	_expect(counts != _player_pin_counts(CaseData), "cork copied the spare-key pin pattern")
	_expect(counts != _player_pin_counts(Rehearsal), "cork copied the rehearsal pin pattern")
	_expect(counts != _player_pin_counts(Gilt), "cork copied the gilt pin pattern")
	_expect(counts != _player_pin_counts(Ferry), "cork copied the ferry pin pattern")
	_expect(counts != _player_pin_counts(Weather), "cork copied the weather pin pattern")
	_expect(counts != _player_pin_counts(Loom), "cork copied the loom pin pattern")
	_expect(counts != _player_pin_counts(Hive), "cork copied the hive pin pattern")
	_expect(counts != _player_pin_counts(Glass), "cork copied the glass pin pattern")
	_expect(counts != _player_pin_counts(Press), "cork copied the press pin pattern")
	_expect(counts != _player_pin_counts(Assay), "cork copied the assay pin pattern")
	_expect(counts == _player_pin_counts(Kiln), "cork press should keep the kiln chalk pin rhythm")
	_expect(counts == _player_pin_counts(Tide), "cork press should keep the tide ledger pin rhythm")
	_expect(counts == _player_pin_counts(Night), "cork press should keep the night bell pin rhythm")
	_expect(counts == _player_pin_counts(Salt), "cork press should keep the salt mark pin rhythm")
	_expect(counts == _player_pin_counts(Wick), "cork press should keep the wick trim pin rhythm")
	_expect(counts == _player_pin_counts(Anneal), "cork press should keep the glass anneal pin rhythm")
	_expect(counts == _player_pin_counts(Graft), "cork press should keep the orchard graft pin rhythm")
	_expect(counts == _player_pin_counts(Dye), "cork press should keep the dye vat pin rhythm")
	_expect(counts == _player_pin_counts(Tar), "cork press should keep the tar kettle pin rhythm")
	_expect(_field_key(Cork) != _field_key(CaseData), "cork copied the spare-key timeline fields")
	_expect(_field_key(Cork) != _field_key(Rehearsal), "cork copied the rehearsal timeline fields")
	_expect(_field_key(Cork) != _field_key(Gilt), "cork copied the gilt timeline fields")
	_expect(_field_key(Cork) != _field_key(Ferry), "cork copied the ferry timeline fields")
	_expect(_field_key(Cork) != _field_key(Weather), "cork copied the weather timeline fields")
	_expect(_field_key(Cork) != _field_key(Loom), "cork copied the loom timeline fields")
	_expect(_field_key(Cork) != _field_key(Hive), "cork copied the hive timeline fields")
	_expect(_field_key(Cork) != _field_key(Glass), "cork copied the glass timeline fields")
	_expect(_field_key(Cork) != _field_key(Press), "cork copied the press timeline fields")
	_expect(_field_key(Cork) != _field_key(Assay), "cork copied the assay timeline fields")
	_expect(_field_key(Cork) != _field_key(Kiln), "cork copied the kiln timeline fields")
	_expect(_field_key(Cork) != _field_key(Tide), "cork copied the tide timeline fields")
	_expect(_field_key(Cork) != _field_key(Night), "cork copied the night timeline fields")
	_expect(_field_key(Cork) != _field_key(Salt), "cork copied the salt timeline fields")
	_expect(_field_key(Cork) != _field_key(Wick), "cork copied the wick timeline fields")
	_expect(_field_key(Cork) != _field_key(Anneal), "cork copied the anneal timeline fields")
	_expect(_field_key(Cork) != _field_key(Graft), "cork copied the graft timeline fields")
	_expect(_field_key(Cork) != _field_key(Dye), "cork copied the dye timeline fields")
	_expect(_field_key(Cork) != _field_key(Tar), "cork copied the tar timeline fields")
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	var earlier_texts := {}
	for old_book in [Dye, Tar]:
		for old_exhibit in old_book.EXHIBITS:
			earlier_texts[str(old_exhibit["text"])] = true
	var exhibit_titles: Array[String] = []
	for exhibit in Cork.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		exhibit_titles.append(str(exhibit["title"]))
		_expect(not seen.has(exhibit_id), "duplicate cork id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		_expect(not earlier_texts.has(str(exhibit["text"])), "cork press copied an earlier sentence")
		for banned in ["tarred", "rope", "kettle", "winch", "pitch", "loft", "strand", "hook", "walk", "dipped", "skein", "indigo"]:
			_expect(str(exhibit["text"]).find(banned) == -1, "%s copies %s" % [exhibit_id, banned])
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Cork.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Cork.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Cork.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Cork.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "cork should have two slips with two hidden facts, found %d" % paired_hidden)
	_expect(exhibit_titles == ["Cutter chit", "Cellar sight", "Mallet peg", "Press slate", "Screw card", "Broom slip", "Cork leaf", "Seal note", "Lock order"], "cork exhibit titles are %s" % str(exhibit_titles))
	for hour in Cork.HOURS:
		_expect(stated.has(hour), "cork hour %s is absent from the exhibits" % hour)

func _test_cork_unique_model() -> void:
	var models := Solver.enumerate(Cork.EXHIBITS, Cork)
	print("cork models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one cork model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Brea", "cork taker")
	_expect(str(model["place"]) == "press", "cork place")
	_expect(str(model["hour"]) == "5", "cork hour")
	_expect(str(model["cutter"]) == "Ansel", "cork cutter")
	_expect(str(model["cut_place"]) == "bench", "cork cut place")
	_expect(str(model["cut_hour"]) == "4", "cork cut hour")
	_expect(str(model["seen_place"]) == "cellar", "cork seen from")
	_expect(str(model["turner"]) == "Colm", "cork turner")
	_expect(str(model["purpose"]) == "take_seal", "cork purpose")
	_expect(str(model["screw_place"]) == "cellar", "cork screw place")
	_expect(str(model["mallet_place"]) == "bench", "cork mallet place")
	_expect(str(model["broom_hour"]) == "3", "cork sweep hour")
	_expect(str(model["wipe_hour"]) == "6", "cork wipe hour")
	_expect(str(model["lock_hour"]) == "7", "cork lock hour")
	for hour in Cork.HOURS:
		var used := false
		for field in Cork.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "cork hour %s is blank in the true timeline" % hour)
	for place in Cork.PLACES:
		var place_used := false
		for field in Cork.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "cork room %s is blank in the true timeline" % place)
	for person in Cork.PEOPLE:
		var person_used := false
		for field in Cork.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "cork person %s is blank in the true timeline" % person)
	_expect(Cork.timeline(model) == CORK_TIMELINE, "cork timeline drifted:\n%s" % Cork.timeline(model))
	for exhibit in Cork.EXHIBITS:
		_expect(Cork.holds(exhibit, model), "%s rejects the cork timeline" % exhibit["id"])

func _test_cork_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Cork.EXHIBITS, Cork)
	for exhibit in Cork.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Cork.without(exhibit_id), Cork)
		print("cork without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "cork %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Cork.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "cork %s removal did not admit a timeline it forbids" % exhibit_id)

func _test_cork_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	for who in Cork.PEOPLE:
		for place in Cork.PLACES:
			for hour in Cork.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == CORK_TRUE["who"] and place == CORK_TRUE["place"] and hour == CORK_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Cork)
					print("cork true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true cork theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "cork acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(CORK_TIMELINE) >= 0, "cork acceptance should give the timeline")
					_expect(str(result["message"]).find("Brea") >= 0, "cork acceptance omits Brea")
					_expect(str(result["message"]).find("press") >= 0, "cork acceptance omits the press")
					_expect(str(result["message"]).find("5") >= 0, "cork acceptance omits 5")
					_expect(str(result["message"]).find("so the cellar would take the seal") >= 0, "cork acceptance omits the seal")
					_expect(str(result["message"]).find("Brea (cork hand) pressed the cork in the press at 5") >= 0, "cork acceptance omits the pressing")
					_expect(Cork.conflicting_ids(theory).is_empty(), "true cork theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Cork)
					_expect(Cork.conflicting_ids(theory).size() >= 2, "%s / %s / %s contradicts fewer than two exhibits" % [who, place, hour])
					rejected += 1
	for outsider in ["Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal", "Nell"]:
		_expect_rejected({"who": outsider, "place": "press", "hour": "5"}, Cork)
	print("cork theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d cork theories" % accepted)
	_expect(rejected >= 2, "rejected %d cork theories" % rejected)

func _test_cork_near_misses() -> void:
	var misses := [
		{"who": "Brea", "place": "press", "hour": "6", "titles": ["Cork leaf", "Seal note", "Lock order"]},
		{"who": "Brea", "place": "press", "hour": "4", "titles": ["Cork leaf", "Seal note", "Lock order"]},
		{"who": "Brea", "place": "cellar", "hour": "5", "titles": ["Press slate", "Screw card", "Broom slip"]},
		{"who": "Ansel", "place": "press", "hour": "5", "titles": ["Cutter chit", "Cellar sight", "Mallet peg"]},
	]
	var wrong_hour_in_press := 0
	var wrong_place_at_hour := 0
	var wrong_person_in_press := 0
	for theory in misses:
		_expect_rejected(theory, Cork)
		var result: Dictionary = Verdict.submit(theory, Cork)
		var message := str(result["message"])
		for title in theory["titles"]:
			_expect(message.find(str(title)) >= 0, "near-miss omits %s: %s" % [title, message])
		if str(theory["who"]) == "Brea" and str(theory["place"]) == "press" and str(theory["hour"]) != "5":
			wrong_hour_in_press += 1
		if str(theory["who"]) == "Brea" and str(theory["place"]) != "press" and str(theory["hour"]) == "5":
			wrong_place_at_hour += 1
		if str(theory["who"]) != "Brea" and str(theory["place"]) == "press" and str(theory["hour"]) == "5":
			wrong_person_in_press += 1
	print("cork near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four cork near-misses, found %d" % misses.size())
	_expect(wrong_hour_in_press == 2, "two near-misses should keep Brea in the press at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Brea at 5 in another room")
	_expect(wrong_person_in_press >= 1, "a near-miss should keep the press at 5 for another person")

func _test_cork_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
		"who stopped the night bell",
		"where they stopped the bell",
		"at which hour they stopped the bell",
		"who scored the salt mark",
		"where they scored the mark",
		"at which hour they scored the mark",
		"who trimmed the wick",
		"where they trimmed the wick",
		"at which hour they trimmed the wick",
		"who annealed the gather",
		"where they annealed the gather",
		"at which hour they annealed the gather",
		"who grafted the scion",
		"where they grafted the scion",
		"at which hour they grafted the scion",
		"who dipped the skein",
		"where they dipped the skein",
		"at which hour they dipped the skein",
		"who tarred the rope",
		"where they tarred the rope",
		"at which hour they tarred the rope",
	]
	var cases := [
		{"theory": {"who": "", "place": "press", "hour": "5"}, "present": ["who pressed the cork"], "absent": ["where they pressed the cork", "at which hour they pressed the cork"]},
		{"theory": {"who": "Brea", "place": "", "hour": "5"}, "present": ["where they pressed the cork"], "absent": ["who pressed the cork", "at which hour they pressed the cork"]},
		{"theory": {"who": "Brea", "place": "press", "hour": ""}, "present": ["at which hour they pressed the cork"], "absent": ["who pressed the cork", "where they pressed the cork"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who pressed the cork", "where they pressed the cork", "at which hour they pressed the cork"], "absent": []},
		{"theory": {}, "present": ["who pressed the cork", "where they pressed the cork", "at which hour they pressed the cork"], "absent": []},
		{"theory": {"who": "Colm", "place": "", "hour": "7"}, "present": ["where they pressed the cork"], "absent": ["who pressed the cork", "at which hour they pressed the cork"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Cork)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "cork incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "cork incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "cork incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "cork incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "cork incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "cork missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "cork named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "cork incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("cork incomplete submissions refused with the missing slot")

func _test_net_file_shape() -> void:
	_expect(Net.EXHIBITS.size() == 9, "net exhibit count is %d" % Net.EXHIBITS.size())
	_expect(Net.PEOPLE.size() == 3, "net cast should be three people")
	_expect(Net.PLACES.size() == 3, "net room count is %d" % Net.PLACES.size())
	_expect(Net.HOURS.size() == 5, "net hour list length is %d" % Net.HOURS.size())
	_expect(Net.PEOPLE == ["Gwyn", "Hester", "Idris"], "net cast is %s" % str(Net.PEOPLE))
	_expect(Net.PLACES == ["loft", "shed", "rail"], "net rooms are %s" % str(Net.PLACES))
	_expect(Net.HOURS == ["2", "3", "4", "5", "6"], "net hours are %s" % str(Net.HOURS))
	_expect(Net.TITLE == "The net loft", "net title")
	_expect(Net.BLURB == "The net loft left its peg at the drying shed. Name who mended the net, the room they mended it in, and the hour.", "net blurb")
	_expect(Net.TITLE != CaseData.TITLE and Net.TITLE != Rehearsal.TITLE and Net.TITLE != Gilt.TITLE and Net.TITLE != Ferry.TITLE and Net.TITLE != Weather.TITLE and Net.TITLE != Loom.TITLE and Net.TITLE != Hive.TITLE and Net.TITLE != Glass.TITLE and Net.TITLE != Press.TITLE and Net.TITLE != Assay.TITLE and Net.TITLE != Kiln.TITLE and Net.TITLE != Tide.TITLE and Net.TITLE != Night.TITLE and Net.TITLE != Salt.TITLE and Net.TITLE != Wick.TITLE and Net.TITLE != Anneal.TITLE and Net.TITLE != Graft.TITLE and Net.TITLE != Dye.TITLE and Net.TITLE != Tar.TITLE and Net.TITLE != Cork.TITLE, "net shares a title")
	_expect(Net.FILE_CODE == "CW-21", "net file code")
	_expect(Net.FILE_CODE != CaseData.FILE_CODE and Net.FILE_CODE != Rehearsal.FILE_CODE and Net.FILE_CODE != Gilt.FILE_CODE and Net.FILE_CODE != Ferry.FILE_CODE and Net.FILE_CODE != Weather.FILE_CODE and Net.FILE_CODE != Loom.FILE_CODE and Net.FILE_CODE != Hive.FILE_CODE and Net.FILE_CODE != Glass.FILE_CODE and Net.FILE_CODE != Press.FILE_CODE and Net.FILE_CODE != Assay.FILE_CODE and Net.FILE_CODE != Kiln.FILE_CODE and Net.FILE_CODE != Tide.FILE_CODE and Net.FILE_CODE != Night.FILE_CODE and Net.FILE_CODE != Salt.FILE_CODE and Net.FILE_CODE != Wick.FILE_CODE and Net.FILE_CODE != Anneal.FILE_CODE and Net.FILE_CODE != Graft.FILE_CODE and Net.FILE_CODE != Dye.FILE_CODE and Net.FILE_CODE != Tar.FILE_CODE and Net.FILE_CODE != Cork.FILE_CODE, "net shares a file code")
	_expect(Net.HOURS[Net.HOURS.size() / 2] == NET_TRUE["hour"], "net mending should be the middle hour")
	_expect(Net.HOURS[0] != NET_TRUE["hour"], "net mending should not be the earliest hour")
	_expect(Net.HOURS[Net.HOURS.size() - 1] != NET_TRUE["hour"], "net mending should not be the latest hour")
	var counts := _player_pin_counts(Net)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "net pin counts are %s" % str(counts))
	_expect(counts != _player_pin_counts(CaseData), "net copied the spare-key pin pattern")
	_expect(counts != _player_pin_counts(Rehearsal), "net copied the rehearsal pin pattern")
	_expect(counts != _player_pin_counts(Gilt), "net copied the gilt pin pattern")
	_expect(counts != _player_pin_counts(Ferry), "net copied the ferry pin pattern")
	_expect(counts != _player_pin_counts(Weather), "net copied the weather pin pattern")
	_expect(counts != _player_pin_counts(Loom), "net copied the loom pin pattern")
	_expect(counts != _player_pin_counts(Hive), "net copied the hive pin pattern")
	_expect(counts != _player_pin_counts(Glass), "net copied the glass pin pattern")
	_expect(counts != _player_pin_counts(Press), "net copied the press pin pattern")
	_expect(counts != _player_pin_counts(Assay), "net copied the assay pin pattern")
	_expect(counts == _player_pin_counts(Kiln), "net loft should keep the kiln chalk pin rhythm")
	_expect(counts == _player_pin_counts(Tide), "net loft should keep the tide ledger pin rhythm")
	_expect(counts == _player_pin_counts(Night), "net loft should keep the night bell pin rhythm")
	_expect(counts == _player_pin_counts(Salt), "net loft should keep the salt mark pin rhythm")
	_expect(counts == _player_pin_counts(Wick), "net loft should keep the wick trim pin rhythm")
	_expect(counts == _player_pin_counts(Anneal), "net loft should keep the glass anneal pin rhythm")
	_expect(counts == _player_pin_counts(Graft), "net loft should keep the orchard graft pin rhythm")
	_expect(counts == _player_pin_counts(Dye), "net loft should keep the dye vat pin rhythm")
	_expect(counts == _player_pin_counts(Tar), "net loft should keep the tar kettle pin rhythm")
	_expect(counts == _player_pin_counts(Cork), "net loft should keep the cork press pin rhythm")
	_expect(_field_key(Net) != _field_key(CaseData), "net copied the spare-key timeline fields")
	_expect(_field_key(Net) != _field_key(Rehearsal), "net copied the rehearsal timeline fields")
	_expect(_field_key(Net) != _field_key(Gilt), "net copied the gilt timeline fields")
	_expect(_field_key(Net) != _field_key(Ferry), "net copied the ferry timeline fields")
	_expect(_field_key(Net) != _field_key(Weather), "net copied the weather timeline fields")
	_expect(_field_key(Net) != _field_key(Loom), "net copied the loom timeline fields")
	_expect(_field_key(Net) != _field_key(Hive), "net copied the hive timeline fields")
	_expect(_field_key(Net) != _field_key(Glass), "net copied the glass timeline fields")
	_expect(_field_key(Net) != _field_key(Press), "net copied the press timeline fields")
	_expect(_field_key(Net) != _field_key(Assay), "net copied the assay timeline fields")
	_expect(_field_key(Net) != _field_key(Kiln), "net copied the kiln timeline fields")
	_expect(_field_key(Net) != _field_key(Tide), "net copied the tide timeline fields")
	_expect(_field_key(Net) != _field_key(Night), "net copied the night timeline fields")
	_expect(_field_key(Net) != _field_key(Salt), "net copied the salt timeline fields")
	_expect(_field_key(Net) != _field_key(Wick), "net copied the wick timeline fields")
	_expect(_field_key(Net) != _field_key(Anneal), "net copied the anneal timeline fields")
	_expect(_field_key(Net) != _field_key(Graft), "net copied the graft timeline fields")
	_expect(_field_key(Net) != _field_key(Dye), "net copied the dye timeline fields")
	_expect(_field_key(Net) != _field_key(Tar), "net copied the tar timeline fields")
	_expect(_field_key(Net) != _field_key(Cork), "net copied the cork timeline fields")
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	var earlier_texts := {}
	for old_book in [Cork, Tar, Dye]:
		for old_exhibit in old_book.EXHIBITS:
			earlier_texts[str(old_exhibit["text"])] = true
	var exhibit_titles: Array[String] = []
	for exhibit in Net.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		exhibit_titles.append(str(exhibit["title"]))
		_expect(not seen.has(exhibit_id), "duplicate net id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		_expect(not earlier_texts.has(str(exhibit["text"])), "net loft copied an earlier sentence")
		for banned in ["pressed", "press", "cork", "bottle", "seal", "mallet", "screw", "cellar", "bench", "wax", "neck", "plug", "tarred", "kettle", "winch", "pitch"]:
			_expect(str(exhibit["text"]).find(banned) == -1, "%s copies %s" % [exhibit_id, banned])
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Net.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Net.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Net.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Net.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "net should have two slips with two hidden facts, found %d" % paired_hidden)
	_expect(exhibit_titles == ["Mesh chit", "Shed sight", "Needle peg", "Loft slate", "Crank card", "Shed slip", "Mend leaf", "Mesh note", "Close order"], "net exhibit titles are %s" % str(exhibit_titles))
	for hour in Net.HOURS:
		_expect(stated.has(hour), "net hour %s is absent from the exhibits" % hour)

func _test_net_unique_model() -> void:
	var models := Solver.enumerate(Net.EXHIBITS, Net)
	print("net models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one net model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Hester", "net taker")
	_expect(str(model["place"]) == "loft", "net place")
	_expect(str(model["hour"]) == "4", "net hour")
	_expect(str(model["hanger"]) == "Gwyn", "net hanger")
	_expect(str(model["hung_place"]) == "rail", "net hang place")
	_expect(str(model["hung_hour"]) == "3", "net hang hour")
	_expect(str(model["seen_from"]) == "shed", "net seen from")
	_expect(str(model["cranker"]) == "Idris", "net cranker")
	_expect(str(model["purpose"]) == "take_mesh", "net purpose")
	_expect(str(model["crank_place"]) == "shed", "net crank place")
	_expect(str(model["needle_place"]) == "rail", "net needle place")
	_expect(str(model["sweep_hour"]) == "2", "net sweep hour")
	_expect(str(model["wipe_hour"]) == "5", "net wipe hour")
	_expect(str(model["close_hour"]) == "6", "net close hour")
	for hour in Net.HOURS:
		var used := false
		for field in Net.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "net hour %s is blank in the true timeline" % hour)
	for place in Net.PLACES:
		var place_used := false
		for field in Net.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "net room %s is blank in the true timeline" % place)
	for person in Net.PEOPLE:
		var person_used := false
		for field in Net.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "net person %s is blank in the true timeline" % person)
	_expect(Net.timeline(model) == NET_TIMELINE, "net timeline drifted:\n%s" % Net.timeline(model))
	for exhibit in Net.EXHIBITS:
		_expect(Net.holds(exhibit, model), "%s rejects the net timeline" % exhibit["id"])

func _test_net_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Net.EXHIBITS, Net)
	for exhibit in Net.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Net.without(exhibit_id), Net)
		print("net without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "net %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Net.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "net %s removal did not admit a timeline it forbids" % exhibit_id)

func _test_net_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	var shed_miss := {"who": "Gwyn", "place": "shed", "hour": "2"}
	_expect(Net.conflicting_ids(shed_miss).size() == 9, "Gwyn / shed / 2 contradicts %d exhibits" % Net.conflicting_ids(shed_miss).size())
	for who in Net.PEOPLE:
		for place in Net.PLACES:
			for hour in Net.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == NET_TRUE["who"] and place == NET_TRUE["place"] and hour == NET_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Net)
					print("net true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true net theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "net acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(NET_TIMELINE) >= 0, "net acceptance should give the timeline")
					_expect(str(result["message"]).find("Hester") >= 0, "net acceptance omits Hester")
					_expect(str(result["message"]).find("loft") >= 0, "net acceptance omits the loft")
					_expect(str(result["message"]).find("4") >= 0, "net acceptance omits 4")
					_expect(str(result["message"]).find("so the shed would take the mesh") >= 0, "net acceptance omits the mesh")
					_expect(str(result["message"]).find("Hester (mend hand) mended the net in the loft at 4") >= 0, "net acceptance omits the mending")
					_expect(Net.conflicting_ids(theory).is_empty(), "true net theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Net)
					_expect(Net.conflicting_ids(theory).size() >= 2, "%s / %s / %s contradicts fewer than two exhibits" % [who, place, hour])
					rejected += 1
	for outsider in ["Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect_rejected({"who": outsider, "place": "loft", "hour": "4"}, Net)
	print("net theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d net theories" % accepted)
	_expect(rejected >= 2, "rejected %d net theories" % rejected)

func _test_net_near_misses() -> void:
	var misses := [
		{"who": "Hester", "place": "loft", "hour": "5", "titles": ["Mend leaf", "Mesh note", "Close order"]},
		{"who": "Hester", "place": "loft", "hour": "3", "titles": ["Mend leaf", "Mesh note", "Close order"]},
		{"who": "Hester", "place": "shed", "hour": "4", "titles": ["Loft slate", "Crank card", "Shed slip"]},
		{"who": "Gwyn", "place": "loft", "hour": "4", "titles": ["Mesh chit", "Shed sight", "Needle peg"]},
	]
	var wrong_hour_in_loft := 0
	var wrong_place_at_hour := 0
	var wrong_person_in_loft := 0
	for theory in misses:
		_expect_rejected(theory, Net)
		var result: Dictionary = Verdict.submit(theory, Net)
		var message := str(result["message"])
		for title in theory["titles"]:
			_expect(message.find(str(title)) >= 0, "near-miss omits %s: %s" % [title, message])
		if str(theory["who"]) == "Hester" and str(theory["place"]) == "loft" and str(theory["hour"]) != "4":
			wrong_hour_in_loft += 1
		if str(theory["who"]) == "Hester" and str(theory["place"]) != "loft" and str(theory["hour"]) == "4":
			wrong_place_at_hour += 1
		if str(theory["who"]) != "Hester" and str(theory["place"]) == "loft" and str(theory["hour"]) == "4":
			wrong_person_in_loft += 1
	print("net near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four net near-misses, found %d" % misses.size())
	_expect(wrong_hour_in_loft == 2, "two near-misses should keep Hester in the loft at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Hester at 4 in another room")
	_expect(wrong_person_in_loft >= 1, "a near-miss should keep the loft at 4 for another person")

func _test_net_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
		"who stopped the night bell",
		"where they stopped the bell",
		"at which hour they stopped the bell",
		"who scored the salt mark",
		"where they scored the mark",
		"at which hour they scored the mark",
		"who trimmed the wick",
		"where they trimmed the wick",
		"at which hour they trimmed the wick",
		"who annealed the gather",
		"where they annealed the gather",
		"at which hour they annealed the gather",
		"who grafted the scion",
		"where they grafted the scion",
		"at which hour they grafted the scion",
		"who dipped the skein",
		"where they dipped the skein",
		"at which hour they dipped the skein",
		"who tarred the rope",
		"where they tarred the rope",
		"at which hour they tarred the rope",
		"who pressed the cork",
		"where they pressed the cork",
		"at which hour they pressed the cork",
	]
	var cases := [
		{"theory": {"who": "", "place": "loft", "hour": "4"}, "present": ["who mended the net"], "absent": ["where they mended the net", "at which hour they mended the net"]},
		{"theory": {"who": "Hester", "place": "", "hour": "4"}, "present": ["where they mended the net"], "absent": ["who mended the net", "at which hour they mended the net"]},
		{"theory": {"who": "Hester", "place": "loft", "hour": ""}, "present": ["at which hour they mended the net"], "absent": ["who mended the net", "where they mended the net"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who mended the net", "where they mended the net", "at which hour they mended the net"], "absent": []},
		{"theory": {}, "present": ["who mended the net", "where they mended the net", "at which hour they mended the net"], "absent": []},
		{"theory": {"who": "Idris", "place": "", "hour": "6"}, "present": ["where they mended the net"], "absent": ["who mended the net", "at which hour they mended the net"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Net)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "net incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "net incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "net incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "net incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "net incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "net missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "net named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "net incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("net incomplete submissions refused with the missing slot")


func _test_cask_file_shape() -> void:
	_expect(Cask.EXHIBITS.size() == 9, "cask exhibit count is %d" % Cask.EXHIBITS.size())
	_expect(Cask.PEOPLE.size() == 3, "cask cast should be three people")
	_expect(Cask.PLACES.size() == 3, "cask room count is %d" % Cask.PLACES.size())
	_expect(Cask.HOURS.size() == 5, "cask hour list length is %d" % Cask.HOURS.size())
	_expect(Cask.PEOPLE == ["Jory", "Maeve", "Perrin"], "cask cast is %s" % str(Cask.PEOPLE))
	_expect(Cask.PLACES == ["shop", "yard", "bench"], "cask rooms are %s" % str(Cask.PLACES))
	_expect(Cask.HOURS == ["1", "2", "3", "4", "5"], "cask hours are %s" % str(Cask.HOURS))
	_expect(Cask.TITLE == "The cask hoop", "cask title")
	_expect(Cask.BLURB == "The cask hoop left its peg at the cooperage. Name who drove the hoop, the room they drove it in, and the hour.", "cask blurb")
	_expect(Cask.TITLE != CaseData.TITLE and Cask.TITLE != Rehearsal.TITLE and Cask.TITLE != Gilt.TITLE and Cask.TITLE != Ferry.TITLE and Cask.TITLE != Weather.TITLE and Cask.TITLE != Loom.TITLE and Cask.TITLE != Hive.TITLE and Cask.TITLE != Glass.TITLE and Cask.TITLE != Press.TITLE and Cask.TITLE != Assay.TITLE and Cask.TITLE != Kiln.TITLE and Cask.TITLE != Tide.TITLE and Cask.TITLE != Night.TITLE and Cask.TITLE != Salt.TITLE and Cask.TITLE != Wick.TITLE and Cask.TITLE != Anneal.TITLE and Cask.TITLE != Graft.TITLE and Cask.TITLE != Dye.TITLE and Cask.TITLE != Tar.TITLE and Cask.TITLE != Cork.TITLE and Cask.TITLE != Net.TITLE, "cask shares a title")
	_expect(Cask.FILE_CODE == "CW-22", "cask file code")
	_expect(Cask.FILE_CODE != CaseData.FILE_CODE and Cask.FILE_CODE != Rehearsal.FILE_CODE and Cask.FILE_CODE != Gilt.FILE_CODE and Cask.FILE_CODE != Ferry.FILE_CODE and Cask.FILE_CODE != Weather.FILE_CODE and Cask.FILE_CODE != Loom.FILE_CODE and Cask.FILE_CODE != Hive.FILE_CODE and Cask.FILE_CODE != Glass.FILE_CODE and Cask.FILE_CODE != Press.FILE_CODE and Cask.FILE_CODE != Assay.FILE_CODE and Cask.FILE_CODE != Kiln.FILE_CODE and Cask.FILE_CODE != Tide.FILE_CODE and Cask.FILE_CODE != Night.FILE_CODE and Cask.FILE_CODE != Salt.FILE_CODE and Cask.FILE_CODE != Wick.FILE_CODE and Cask.FILE_CODE != Anneal.FILE_CODE and Cask.FILE_CODE != Graft.FILE_CODE and Cask.FILE_CODE != Dye.FILE_CODE and Cask.FILE_CODE != Tar.FILE_CODE and Cask.FILE_CODE != Cork.FILE_CODE and Cask.FILE_CODE != Net.FILE_CODE, "cask shares a file code")
	_expect(Cask.HOURS[Cask.HOURS.size() / 2] == CASK_TRUE["hour"], "cask driving should be the middle hour")
	_expect(Cask.HOURS[0] != CASK_TRUE["hour"], "cask driving should not be the earliest hour")
	_expect(Cask.HOURS[Cask.HOURS.size() - 1] != CASK_TRUE["hour"], "cask driving should not be the latest hour")
	var counts := _player_pin_counts(Cask)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "cask pin counts are %s" % str(counts))
	_expect(counts != _player_pin_counts(CaseData), "cask copied the spare-key pin pattern")
	_expect(counts != _player_pin_counts(Rehearsal), "cask copied the rehearsal pin pattern")
	_expect(counts != _player_pin_counts(Gilt), "cask copied the gilt pin pattern")
	_expect(counts != _player_pin_counts(Ferry), "cask copied the ferry pin pattern")
	_expect(counts != _player_pin_counts(Weather), "cask copied the weather pin pattern")
	_expect(counts != _player_pin_counts(Loom), "cask copied the loom pin pattern")
	_expect(counts != _player_pin_counts(Hive), "cask copied the hive pin pattern")
	_expect(counts != _player_pin_counts(Glass), "cask copied the glass pin pattern")
	_expect(counts != _player_pin_counts(Press), "cask copied the press pin pattern")
	_expect(counts != _player_pin_counts(Assay), "cask copied the assay pin pattern")
	_expect(counts == _player_pin_counts(Kiln), "cask hoop should keep the kiln chalk pin rhythm")
	_expect(counts == _player_pin_counts(Tide), "cask hoop should keep the tide ledger pin rhythm")
	_expect(counts == _player_pin_counts(Night), "cask hoop should keep the night bell pin rhythm")
	_expect(counts == _player_pin_counts(Salt), "cask hoop should keep the salt mark pin rhythm")
	_expect(counts == _player_pin_counts(Wick), "cask hoop should keep the wick trim pin rhythm")
	_expect(counts == _player_pin_counts(Anneal), "cask hoop should keep the glass anneal pin rhythm")
	_expect(counts == _player_pin_counts(Graft), "cask hoop should keep the orchard graft pin rhythm")
	_expect(counts == _player_pin_counts(Dye), "cask hoop should keep the dye vat pin rhythm")
	_expect(counts == _player_pin_counts(Tar), "cask hoop should keep the tar kettle pin rhythm")
	_expect(counts == _player_pin_counts(Cork), "cask hoop should keep the cork press pin rhythm")
	_expect(counts == _player_pin_counts(Net), "cask hoop should keep the net loft pin rhythm")
	_expect(_field_key(Cask) != _field_key(CaseData), "cask copied the spare-key timeline fields")
	_expect(_field_key(Cask) != _field_key(Rehearsal), "cask copied the rehearsal timeline fields")
	_expect(_field_key(Cask) != _field_key(Gilt), "cask copied the gilt timeline fields")
	_expect(_field_key(Cask) != _field_key(Ferry), "cask copied the ferry timeline fields")
	_expect(_field_key(Cask) != _field_key(Weather), "cask copied the weather timeline fields")
	_expect(_field_key(Cask) != _field_key(Loom), "cask copied the loom timeline fields")
	_expect(_field_key(Cask) != _field_key(Hive), "cask copied the hive timeline fields")
	_expect(_field_key(Cask) != _field_key(Glass), "cask copied the glass timeline fields")
	_expect(_field_key(Cask) != _field_key(Press), "cask copied the press timeline fields")
	_expect(_field_key(Cask) != _field_key(Assay), "cask copied the assay timeline fields")
	_expect(_field_key(Cask) != _field_key(Kiln), "cask copied the kiln timeline fields")
	_expect(_field_key(Cask) != _field_key(Tide), "cask copied the tide timeline fields")
	_expect(_field_key(Cask) != _field_key(Night), "cask copied the night timeline fields")
	_expect(_field_key(Cask) != _field_key(Salt), "cask copied the salt timeline fields")
	_expect(_field_key(Cask) != _field_key(Wick), "cask copied the wick timeline fields")
	_expect(_field_key(Cask) != _field_key(Anneal), "cask copied the anneal timeline fields")
	_expect(_field_key(Cask) != _field_key(Graft), "cask copied the graft timeline fields")
	_expect(_field_key(Cask) != _field_key(Dye), "cask copied the dye timeline fields")
	_expect(_field_key(Cask) != _field_key(Tar), "cask copied the tar timeline fields")
	_expect(_field_key(Cask) != _field_key(Cork), "cask copied the cork timeline fields")
	_expect(_field_key(Cask) != _field_key(Net), "cask copied the net timeline fields")
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	var earlier_texts := {}
	for old_book in [CaseData, Rehearsal, Gilt, Ferry, Weather, Loom, Hive, Glass, Press, Assay, Kiln, Tide, Night, Salt, Wick, Anneal, Graft, Dye, Tar, Cork, Net]:
		for old_exhibit in old_book.EXHIBITS:
			earlier_texts[str(old_exhibit["text"])] = true
	var exhibit_titles: Array[String] = []
	for exhibit in Cask.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		exhibit_titles.append(str(exhibit["title"]))
		_expect(not seen.has(exhibit_id), "duplicate cask id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		_expect(not earlier_texts.has(str(exhibit["text"])), "cask hoop copied an earlier sentence")
		for banned in ["bottle", "cork", "seal", "mallet", "screw", "cellar", "wax", "neck", "plug", "pressed", "press", "dye", "vat", "indigo", "skein", "rope", "walk", "kettle", "winch", "pitch", "tarred", "mesh", "loft", "shed", "rail", "crank", "needle", "mended", "twine", "house"]:
			_expect(str(exhibit["text"]).find(banned) == -1, "%s copies %s" % [exhibit_id, banned])
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Cask.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Cask.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Cask.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Cask.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "cask should have two slips with two hidden facts, found %d" % paired_hidden)
	_expect(exhibit_titles == ["Hoop chit", "Yard sight", "Driver peg", "Shop slate", "Croze card", "Sweep slip", "Drive leaf", "Cask note", "Shut order"], "cask exhibit titles are %s" % str(exhibit_titles))
	for hour in Cask.HOURS:
		_expect(stated.has(hour), "cask hour %s is absent from the exhibits" % hour)

func _test_cask_unique_model() -> void:
	var models := Solver.enumerate(Cask.EXHIBITS, Cask)
	print("cask models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one cask model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Maeve", "cask taker")
	_expect(str(model["place"]) == "shop", "cask place")
	_expect(str(model["hour"]) == "3", "cask hour")
	_expect(str(model["cutter"]) == "Jory", "cask cutter")
	_expect(str(model["cut_place"]) == "bench", "cask cut place")
	_expect(str(model["cut_hour"]) == "2", "cask cut hour")
	_expect(str(model["seen_from"]) == "yard", "cask seen from")
	_expect(str(model["crozer"]) == "Perrin", "cask crozer")
	_expect(str(model["purpose"]) == "take_cask", "cask purpose")
	_expect(str(model["croze_place"]) == "yard", "cask croze place")
	_expect(str(model["driver_place"]) == "bench", "cask driver place")
	_expect(str(model["sweep_hour"]) == "1", "cask sweep hour")
	_expect(str(model["wipe_hour"]) == "4", "cask wipe hour")
	_expect(str(model["close_hour"]) == "5", "cask close hour")
	for hour in Cask.HOURS:
		var used := false
		for field in Cask.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "cask hour %s is blank in the true timeline" % hour)
	for place in Cask.PLACES:
		var place_used := false
		for field in Cask.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "cask room %s is blank in the true timeline" % place)
	for person in Cask.PEOPLE:
		var person_used := false
		for field in Cask.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "cask person %s is blank in the true timeline" % person)
	_expect(Cask.timeline(model) == CASK_TIMELINE, "cask timeline drifted:\n%s" % Cask.timeline(model))
	for exhibit in Cask.EXHIBITS:
		_expect(Cask.holds(exhibit, model), "%s rejects the cask timeline" % exhibit["id"])

func _test_cask_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Cask.EXHIBITS, Cask)
	for exhibit in Cask.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Cask.without(exhibit_id), Cask)
		print("cask without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "cask %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Cask.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "cask %s removal did not admit a timeline it forbids" % exhibit_id)

func _test_cask_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	var yard_miss := {"who": "Jory", "place": "yard", "hour": "1"}
	_expect(Cask.conflicting_ids(yard_miss).size() == 9, "Jory / yard / 1 contradicts %d exhibits" % Cask.conflicting_ids(yard_miss).size())
	for who in Cask.PEOPLE:
		for place in Cask.PLACES:
			for hour in Cask.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == CASK_TRUE["who"] and place == CASK_TRUE["place"] and hour == CASK_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Cask)
					print("cask true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true cask theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "cask acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(CASK_TIMELINE) >= 0, "cask acceptance should give the timeline")
					_expect(str(result["message"]).find("Maeve") >= 0, "cask acceptance omits Maeve")
					_expect(str(result["message"]).find("shop") >= 0, "cask acceptance omits the shop")
					_expect(str(result["message"]).find("3") >= 0, "cask acceptance omits 3")
					_expect(str(result["message"]).find("so the yard would take the cask") >= 0, "cask acceptance omits the cask")
					_expect(str(result["message"]).find("Maeve (shop hand) drove the hoop in the shop at 3") >= 0, "cask acceptance omits the driving")
					_expect(Cask.conflicting_ids(theory).is_empty(), "true cask theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Cask)
					_expect(Cask.conflicting_ids(theory).size() >= 2, "%s / %s / %s contradicts fewer than two exhibits" % [who, place, hour])
					rejected += 1
	for outsider in ["Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal", "Nell"]:
		_expect_rejected({"who": outsider, "place": "shop", "hour": "3"}, Cask)
	print("cask theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d cask theories" % accepted)
	_expect(rejected >= 2, "rejected %d cask theories" % rejected)

func _test_cask_near_misses() -> void:
	var misses := [
		{"who": "Maeve", "place": "shop", "hour": "4", "titles": ["Drive leaf", "Cask note", "Shut order"]},
		{"who": "Maeve", "place": "shop", "hour": "2", "titles": ["Drive leaf", "Cask note", "Shut order"]},
		{"who": "Maeve", "place": "yard", "hour": "3", "titles": ["Shop slate", "Croze card", "Sweep slip"]},
		{"who": "Jory", "place": "shop", "hour": "3", "titles": ["Hoop chit", "Yard sight", "Driver peg"]},
	]
	var wrong_hour_in_shop := 0
	var wrong_place_at_hour := 0
	var wrong_person_in_shop := 0
	for theory in misses:
		_expect_rejected(theory, Cask)
		var result: Dictionary = Verdict.submit(theory, Cask)
		var message := str(result["message"])
		_expect(Cask.conflicting_ids(theory).size() == 3, "near-miss should name three exhibits: %s" % message)
		for title in theory["titles"]:
			_expect(message.find(str(title)) >= 0, "near-miss omits %s: %s" % [title, message])
		if str(theory["who"]) == "Maeve" and str(theory["place"]) == "shop" and str(theory["hour"]) != "3":
			wrong_hour_in_shop += 1
		if str(theory["who"]) == "Maeve" and str(theory["place"]) != "shop" and str(theory["hour"]) == "3":
			wrong_place_at_hour += 1
		if str(theory["who"]) != "Maeve" and str(theory["place"]) == "shop" and str(theory["hour"]) == "3":
			wrong_person_in_shop += 1
	print("cask near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four cask near-misses, found %d" % misses.size())
	_expect(wrong_hour_in_shop == 2, "two near-misses should keep Maeve in the shop at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Maeve at 3 in another room")
	_expect(wrong_person_in_shop >= 1, "a near-miss should keep the shop at 3 for another person")

func _test_cask_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
		"who stopped the night bell",
		"where they stopped the bell",
		"at which hour they stopped the bell",
		"who scored the salt mark",
		"where they scored the mark",
		"at which hour they scored the mark",
		"who trimmed the wick",
		"where they trimmed the wick",
		"at which hour they trimmed the wick",
		"who annealed the gather",
		"where they annealed the gather",
		"at which hour they annealed the gather",
		"who grafted the scion",
		"where they grafted the scion",
		"at which hour they grafted the scion",
		"who dipped the skein",
		"where they dipped the skein",
		"at which hour they dipped the skein",
		"who tarred the rope",
		"where they tarred the rope",
		"at which hour they tarred the rope",
		"who pressed the cork",
		"where they pressed the cork",
		"at which hour they pressed the cork",
		"who mended the net",
		"where they mended the net",
		"at which hour they mended the net",
	]
	var cases := [
		{"theory": {"who": "", "place": "shop", "hour": "3"}, "present": ["who drove the hoop"], "absent": ["where they drove the hoop", "at which hour they drove the hoop"]},
		{"theory": {"who": "Maeve", "place": "", "hour": "3"}, "present": ["where they drove the hoop"], "absent": ["who drove the hoop", "at which hour they drove the hoop"]},
		{"theory": {"who": "Maeve", "place": "shop", "hour": ""}, "present": ["at which hour they drove the hoop"], "absent": ["who drove the hoop", "where they drove the hoop"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who drove the hoop", "where they drove the hoop", "at which hour they drove the hoop"], "absent": []},
		{"theory": {}, "present": ["who drove the hoop", "where they drove the hoop", "at which hour they drove the hoop"], "absent": []},
		{"theory": {"who": "Perrin", "place": "", "hour": "5"}, "present": ["where they drove the hoop"], "absent": ["who drove the hoop", "at which hour they drove the hoop"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Cask)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "cask incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "cask incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "cask incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "cask incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "cask incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "cask missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "cask named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "cask incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("cask incomplete submissions refused with the missing slot")


func _test_linen_file_shape() -> void:
	_expect(Linen.EXHIBITS.size() == 9, "linen exhibit count is %d" % Linen.EXHIBITS.size())
	_expect(Linen.PEOPLE.size() == 3, "linen cast should be three people")
	_expect(Linen.PLACES.size() == 3, "linen room count is %d" % Linen.PLACES.size())
	_expect(Linen.HOURS.size() == 5, "linen hour list length is %d" % Linen.HOURS.size())
	_expect(Linen.PEOPLE == ["Odell", "Vetch", "Brigg"], "linen cast is %s" % str(Linen.PEOPLE))
	_expect(Linen.PLACES == ["press", "loft", "bench"], "linen rooms are %s" % str(Linen.PLACES))
	_expect(Linen.HOURS == ["6", "7", "8", "9", "10"], "linen hours are %s" % str(Linen.HOURS))
	_expect(Linen.TITLE == "The linen fold", "linen title")
	_expect(Linen.BLURB == "The linen fold left its peg at the cloth loft. Name who folded the linen, the room they folded it in, and the hour.", "linen blurb")
	_expect(Linen.TITLE != CaseData.TITLE and Linen.TITLE != Rehearsal.TITLE and Linen.TITLE != Gilt.TITLE and Linen.TITLE != Ferry.TITLE and Linen.TITLE != Weather.TITLE and Linen.TITLE != Loom.TITLE and Linen.TITLE != Hive.TITLE and Linen.TITLE != Glass.TITLE and Linen.TITLE != Press.TITLE and Linen.TITLE != Assay.TITLE and Linen.TITLE != Kiln.TITLE and Linen.TITLE != Tide.TITLE and Linen.TITLE != Night.TITLE and Linen.TITLE != Salt.TITLE and Linen.TITLE != Wick.TITLE and Linen.TITLE != Anneal.TITLE and Linen.TITLE != Graft.TITLE and Linen.TITLE != Dye.TITLE and Linen.TITLE != Tar.TITLE and Linen.TITLE != Cork.TITLE and Linen.TITLE != Net.TITLE and Linen.TITLE != Cask.TITLE, "linen shares a title")
	_expect(Linen.FILE_CODE == "CW-23", "linen file code")
	_expect(Linen.FILE_CODE != CaseData.FILE_CODE and Linen.FILE_CODE != Rehearsal.FILE_CODE and Linen.FILE_CODE != Gilt.FILE_CODE and Linen.FILE_CODE != Ferry.FILE_CODE and Linen.FILE_CODE != Weather.FILE_CODE and Linen.FILE_CODE != Loom.FILE_CODE and Linen.FILE_CODE != Hive.FILE_CODE and Linen.FILE_CODE != Glass.FILE_CODE and Linen.FILE_CODE != Press.FILE_CODE and Linen.FILE_CODE != Assay.FILE_CODE and Linen.FILE_CODE != Kiln.FILE_CODE and Linen.FILE_CODE != Tide.FILE_CODE and Linen.FILE_CODE != Night.FILE_CODE and Linen.FILE_CODE != Salt.FILE_CODE and Linen.FILE_CODE != Wick.FILE_CODE and Linen.FILE_CODE != Anneal.FILE_CODE and Linen.FILE_CODE != Graft.FILE_CODE and Linen.FILE_CODE != Dye.FILE_CODE and Linen.FILE_CODE != Tar.FILE_CODE and Linen.FILE_CODE != Cork.FILE_CODE and Linen.FILE_CODE != Net.FILE_CODE and Linen.FILE_CODE != Cask.FILE_CODE, "linen shares a file code")
	_expect(Linen.HOURS[Linen.HOURS.size() / 2] == LINEN_TRUE["hour"], "linen folding should be the middle hour")
	_expect(Linen.HOURS[0] != LINEN_TRUE["hour"], "linen folding should not be the earliest hour")
	_expect(Linen.HOURS[Linen.HOURS.size() - 1] != LINEN_TRUE["hour"], "linen folding should not be the latest hour")
	var counts := _player_pin_counts(Linen)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "linen pin counts are %s" % str(counts))
	_expect(counts != _player_pin_counts(CaseData), "linen copied the spare-key pin pattern")
	_expect(counts != _player_pin_counts(Rehearsal), "linen copied the rehearsal pin pattern")
	_expect(counts != _player_pin_counts(Gilt), "linen copied the gilt pin pattern")
	_expect(counts != _player_pin_counts(Ferry), "linen copied the ferry pin pattern")
	_expect(counts != _player_pin_counts(Weather), "linen copied the weather pin pattern")
	_expect(counts != _player_pin_counts(Loom), "linen copied the loom pin pattern")
	_expect(counts != _player_pin_counts(Hive), "linen copied the hive pin pattern")
	_expect(counts != _player_pin_counts(Glass), "linen copied the glass pin pattern")
	_expect(counts != _player_pin_counts(Press), "linen copied the press pin pattern")
	_expect(counts != _player_pin_counts(Assay), "linen copied the assay pin pattern")
	_expect(counts == _player_pin_counts(Kiln), "linen fold should keep the kiln chalk pin rhythm")
	_expect(counts == _player_pin_counts(Tide), "linen fold should keep the tide ledger pin rhythm")
	_expect(counts == _player_pin_counts(Night), "linen fold should keep the night bell pin rhythm")
	_expect(counts == _player_pin_counts(Salt), "linen fold should keep the salt mark pin rhythm")
	_expect(counts == _player_pin_counts(Wick), "linen fold should keep the wick trim pin rhythm")
	_expect(counts == _player_pin_counts(Anneal), "linen fold should keep the glass anneal pin rhythm")
	_expect(counts == _player_pin_counts(Graft), "linen fold should keep the orchard graft pin rhythm")
	_expect(counts == _player_pin_counts(Dye), "linen fold should keep the dye vat pin rhythm")
	_expect(counts == _player_pin_counts(Tar), "linen fold should keep the tar kettle pin rhythm")
	_expect(counts == _player_pin_counts(Cork), "linen fold should keep the cork press pin rhythm")
	_expect(counts == _player_pin_counts(Net), "linen fold should keep the net loft pin rhythm")
	_expect(counts == _player_pin_counts(Cask), "linen fold should keep the cask hoop pin rhythm")
	_expect(_field_key(Linen) != _field_key(CaseData), "linen copied the spare-key timeline fields")
	_expect(_field_key(Linen) != _field_key(Rehearsal), "linen copied the rehearsal timeline fields")
	_expect(_field_key(Linen) != _field_key(Gilt), "linen copied the gilt timeline fields")
	_expect(_field_key(Linen) != _field_key(Ferry), "linen copied the ferry timeline fields")
	_expect(_field_key(Linen) != _field_key(Weather), "linen copied the weather timeline fields")
	_expect(_field_key(Linen) != _field_key(Loom), "linen copied the loom timeline fields")
	_expect(_field_key(Linen) != _field_key(Hive), "linen copied the hive timeline fields")
	_expect(_field_key(Linen) != _field_key(Glass), "linen copied the glass timeline fields")
	_expect(_field_key(Linen) != _field_key(Press), "linen copied the press timeline fields")
	_expect(_field_key(Linen) != _field_key(Assay), "linen copied the assay timeline fields")
	_expect(_field_key(Linen) != _field_key(Kiln), "linen copied the kiln timeline fields")
	_expect(_field_key(Linen) != _field_key(Tide), "linen copied the tide timeline fields")
	_expect(_field_key(Linen) != _field_key(Night), "linen copied the night timeline fields")
	_expect(_field_key(Linen) != _field_key(Salt), "linen copied the salt timeline fields")
	_expect(_field_key(Linen) != _field_key(Wick), "linen copied the wick timeline fields")
	_expect(_field_key(Linen) != _field_key(Anneal), "linen copied the anneal timeline fields")
	_expect(_field_key(Linen) != _field_key(Graft), "linen copied the graft timeline fields")
	_expect(_field_key(Linen) != _field_key(Dye), "linen copied the dye timeline fields")
	_expect(_field_key(Linen) != _field_key(Tar), "linen copied the tar timeline fields")
	_expect(_field_key(Linen) != _field_key(Cork), "linen copied the cork timeline fields")
	_expect(_field_key(Linen) != _field_key(Net), "linen copied the net timeline fields")
	_expect(_field_key(Linen) != _field_key(Cask), "linen copied the cask timeline fields")
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	var earlier_texts := {}
	for old_book in [CaseData, Rehearsal, Gilt, Ferry, Weather, Loom, Hive, Glass, Press, Assay, Kiln, Tide, Night, Salt, Wick, Anneal, Graft, Dye, Tar, Cork, Net, Cask]:
		for old_exhibit in old_book.EXHIBITS:
			earlier_texts[str(old_exhibit["text"])] = true
	var exhibit_titles: Array[String] = []
	for exhibit in Linen.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		exhibit_titles.append(str(exhibit["title"]))
		_expect(not seen.has(exhibit_id), "duplicate linen id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		_expect(not earlier_texts.has(str(exhibit["text"])), "linen fold copied an earlier sentence")
		for banned in ["bottle", "cork", "seal", "mallet", "screw", "cellar", "wax", "neck", "plug", "pressed", "dye", "vat", "indigo", "skein", "rope", "walk", "kettle", "winch", "pitch", "tarred", "mesh", "shed", "rail", "crank", "needle", "mended", "twine", "house", "cooperage", "cask", "hoop", "croze", "stave", "driver", "yard", "shop"]:
			_expect(str(exhibit["text"]).find(banned) == -1, "%s copies %s" % [exhibit_id, banned])
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Linen.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Linen.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Linen.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Linen.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "linen should have two slips with two hidden facts, found %d" % paired_hidden)
	_expect(exhibit_titles == ["Shears chit", "Loft sight", "Pin peg", "Cloth slate", "Roller card", "Dust slip", "Fold leaf", "Sheet note", "Bar order"], "linen exhibit titles are %s" % str(exhibit_titles))
	for hour in Linen.HOURS:
		_expect(stated.has(hour), "linen hour %s is absent from the exhibits" % hour)

func _test_linen_unique_model() -> void:
	var models := Solver.enumerate(Linen.EXHIBITS, Linen)
	print("linen models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one linen model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Vetch", "linen taker")
	_expect(str(model["place"]) == "press", "linen place")
	_expect(str(model["hour"]) == "8", "linen hour")
	_expect(str(model["clipper"]) == "Odell", "linen clipper")
	_expect(str(model["clip_room"]) == "bench", "linen clip room")
	_expect(str(model["clip_hour"]) == "7", "linen clip hour")
	_expect(str(model["watched_from"]) == "loft", "linen watched from")
	_expect(str(model["roller"]) == "Brigg", "linen roller")
	_expect(str(model["purpose"]) == "take_sheet", "linen purpose")
	_expect(str(model["roll_room"]) == "loft", "linen roll room")
	_expect(str(model["pin_room"]) == "bench", "linen pin room")
	_expect(str(model["dust_hour"]) == "6", "linen dust hour")
	_expect(str(model["dab_hour"]) == "9", "linen dab hour")
	_expect(str(model["bar_hour"]) == "10", "linen bar hour")
	for hour in Linen.HOURS:
		var used := false
		for field in Linen.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "linen hour %s is blank in the true timeline" % hour)
	for place in Linen.PLACES:
		var place_used := false
		for field in Linen.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "linen room %s is blank in the true timeline" % place)
	for person in Linen.PEOPLE:
		var person_used := false
		for field in Linen.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "linen person %s is blank in the true timeline" % person)
	_expect(Linen.timeline(model) == LINEN_TIMELINE, "linen timeline drifted:\n%s" % Linen.timeline(model))
	for exhibit in Linen.EXHIBITS:
		_expect(Linen.holds(exhibit, model), "%s rejects the linen timeline" % exhibit["id"])

func _test_linen_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Linen.EXHIBITS, Linen)
	for exhibit in Linen.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Linen.without(exhibit_id), Linen)
		print("linen without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "linen %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Linen.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "linen %s removal did not admit a timeline it forbids" % exhibit_id)

func _test_linen_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	var loft_miss := {"who": "Odell", "place": "loft", "hour": "6"}
	_expect(Linen.conflicting_ids(loft_miss).size() == 9, "Odell / loft / 6 contradicts %d exhibits" % Linen.conflicting_ids(loft_miss).size())
	for who in Linen.PEOPLE:
		for place in Linen.PLACES:
			for hour in Linen.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == LINEN_TRUE["who"] and place == LINEN_TRUE["place"] and hour == LINEN_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Linen)
					print("linen true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true linen theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "linen acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(LINEN_TIMELINE) >= 0, "linen acceptance should give the timeline")
					_expect(str(result["message"]).find("Vetch") >= 0, "linen acceptance omits Vetch")
					_expect(str(result["message"]).find("press") >= 0, "linen acceptance omits the press")
					_expect(str(result["message"]).find("8") >= 0, "linen acceptance omits 8")
					_expect(str(result["message"]).find("so the loft would take the sheet") >= 0, "linen acceptance omits the sheet")
					_expect(str(result["message"]).find("Vetch (press hand) folded the linen in the press at 8") >= 0, "linen acceptance omits the folding")
					_expect(Linen.conflicting_ids(theory).is_empty(), "true linen theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Linen)
					_expect(Linen.conflicting_ids(theory).size() >= 2, "%s / %s / %s contradicts fewer than two exhibits" % [who, place, hour])
					rejected += 1
	for outsider in ["Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal", "Nell"]:
		_expect_rejected({"who": outsider, "place": "press", "hour": "8"}, Linen)
	print("linen theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d linen theories" % accepted)
	_expect(rejected >= 2, "rejected %d linen theories" % rejected)

func _test_linen_near_misses() -> void:
	var misses := [
		{"who": "Vetch", "place": "press", "hour": "9", "titles": ["Fold leaf", "Sheet note", "Bar order"]},
		{"who": "Vetch", "place": "press", "hour": "7", "titles": ["Fold leaf", "Sheet note", "Bar order"]},
		{"who": "Vetch", "place": "loft", "hour": "8", "titles": ["Cloth slate", "Roller card", "Dust slip"]},
		{"who": "Odell", "place": "press", "hour": "8", "titles": ["Shears chit", "Loft sight", "Pin peg"]},
	]
	var wrong_hour_in_press := 0
	var wrong_place_at_hour := 0
	var wrong_person_in_press := 0
	for theory in misses:
		_expect_rejected(theory, Linen)
		var result: Dictionary = Verdict.submit(theory, Linen)
		var message := str(result["message"])
		_expect(Linen.conflicting_ids(theory).size() == 3, "near-miss should name three exhibits: %s" % message)
		for title in theory["titles"]:
			_expect(message.find(str(title)) >= 0, "near-miss omits %s: %s" % [title, message])
		if str(theory["who"]) == "Vetch" and str(theory["place"]) == "press" and str(theory["hour"]) != "8":
			wrong_hour_in_press += 1
		if str(theory["who"]) == "Vetch" and str(theory["place"]) != "press" and str(theory["hour"]) == "8":
			wrong_place_at_hour += 1
		if str(theory["who"]) != "Vetch" and str(theory["place"]) == "press" and str(theory["hour"]) == "8":
			wrong_person_in_press += 1
	print("linen near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four linen near-misses, found %d" % misses.size())
	_expect(wrong_hour_in_press == 2, "two near-misses should keep Vetch in the press at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Vetch at 8 in another room")
	_expect(wrong_person_in_press >= 1, "a near-miss should keep the press at 8 for another person")

func _test_linen_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
		"who stopped the night bell",
		"where they stopped the bell",
		"at which hour they stopped the bell",
		"who scored the salt mark",
		"where they scored the mark",
		"at which hour they scored the mark",
		"who trimmed the wick",
		"where they trimmed the wick",
		"at which hour they trimmed the wick",
		"who annealed the gather",
		"where they annealed the gather",
		"at which hour they annealed the gather",
		"who grafted the scion",
		"where they grafted the scion",
		"at which hour they grafted the scion",
		"who dipped the skein",
		"where they dipped the skein",
		"at which hour they dipped the skein",
		"who tarred the rope",
		"where they tarred the rope",
		"at which hour they tarred the rope",
		"who pressed the cork",
		"where they pressed the cork",
		"at which hour they pressed the cork",
		"who mended the net",
		"where they mended the net",
		"at which hour they mended the net",
		"who drove the hoop",
		"where they drove the hoop",
		"at which hour they drove the hoop",
	]
	var cases := [
		{"theory": {"who": "", "place": "press", "hour": "8"}, "present": ["who folded the linen"], "absent": ["where they folded the linen", "at which hour they folded the linen"]},
		{"theory": {"who": "Vetch", "place": "", "hour": "8"}, "present": ["where they folded the linen"], "absent": ["who folded the linen", "at which hour they folded the linen"]},
		{"theory": {"who": "Vetch", "place": "press", "hour": ""}, "present": ["at which hour they folded the linen"], "absent": ["who folded the linen", "where they folded the linen"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who folded the linen", "where they folded the linen", "at which hour they folded the linen"], "absent": []},
		{"theory": {}, "present": ["who folded the linen", "where they folded the linen", "at which hour they folded the linen"], "absent": []},
		{"theory": {"who": "Brigg", "place": "", "hour": "10"}, "present": ["where they folded the linen"], "absent": ["who folded the linen", "at which hour they folded the linen"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Linen)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "linen incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "linen incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "linen incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "linen incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "linen incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "linen missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "linen named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "linen incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("linen incomplete submissions refused with the missing slot")


func _test_dovetail_file_shape() -> void:
	_expect(Dovetail.EXHIBITS.size() == 9, "dovetail exhibit count is %d" % Dovetail.EXHIBITS.size())
	_expect(Dovetail.PEOPLE.size() == 3, "dovetail cast should be three people")
	_expect(Dovetail.PLACES.size() == 3, "dovetail room count is %d" % Dovetail.PLACES.size())
	_expect(Dovetail.HOURS.size() == 5, "dovetail hour list length is %d" % Dovetail.HOURS.size())
	_expect(Dovetail.PEOPLE == ["Doss", "Yarrow", "Peck"], "dovetail cast is %s" % str(Dovetail.PEOPLE))
	_expect(Dovetail.PLACES == ["vise", "stile", "apron"], "dovetail rooms are %s" % str(Dovetail.PLACES))
	_expect(Dovetail.HOURS == ["61", "62", "63", "64", "65"], "dovetail hours are %s" % str(Dovetail.HOURS))
	_expect(Dovetail.AIMS == ["take_joint", "spare_joint", "set_joint"], "dovetail aims are %s" % str(Dovetail.AIMS))
	_expect(Dovetail.aim_phrase("take_joint") == "so the stile would take the joint", "dovetail aim phrase")
	_expect(Dovetail.TITLE == "The dovetail", "dovetail title")
	_expect(Dovetail.BLURB == "The dovetail left its peg at the joiner's bench. Name who cut the dovetail, the room they cut it in, and the hour.", "dovetail blurb")
	_expect(Dovetail.FILE_CODE == "CW-24", "dovetail file code")
	_expect(Dovetail.fields() == ["taker", "place", "hour", "sawyer", "saw_room", "saw_hour", "seen_from", "clamp", "aim", "clamp_room", "peg_room", "sweep_hour", "wipe_hour", "close_hour"], "dovetail fields are %s" % str(Dovetail.fields()))
	_expect(Dovetail.PLAYER_FIELDS == ["taker", "place", "hour"], "dovetail player fields")
	_expect(Dovetail.HOURS[Dovetail.HOURS.size() / 2] == DOVETAIL_TRUE["hour"], "dovetail cutting should be the middle hour")
	_expect(Dovetail.HOURS[0] != DOVETAIL_TRUE["hour"], "dovetail cutting should not be the earliest hour")
	_expect(Dovetail.HOURS[Dovetail.HOURS.size() - 1] != DOVETAIL_TRUE["hour"], "dovetail cutting should not be the latest hour")
	var counts := _player_pin_counts(Dovetail)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "dovetail pin counts are %s" % str(counts))
	var loose_pin: Array = [
		[CaseData, "spare key"],
		[Rehearsal, "rehearsal score"],
		[Gilt, "gilt stamp"],
		[Ferry, "ferry bell"],
		[Weather, "weather slate"],
		[Loom, "loom shuttle"],
		[Hive, "hive smoker"],
		[Glass, "glass pontil"],
		[Press, "press proof"],
		[Assay, "assay cup"],
	]
	var rhythm: Array = [
		[Kiln, "kiln chalk"],
		[Tide, "tide ledger"],
		[Night, "night bell"],
		[Salt, "salt mark"],
		[Wick, "wick trim"],
		[Anneal, "glass anneal"],
		[Graft, "orchard graft"],
		[Dye, "dye vat"],
		[Tar, "tar kettle"],
		[Cork, "cork press"],
		[Net, "net loft"],
		[Cask, "cask hoop"],
		[Linen, "linen fold"],
	]
	for row in loose_pin:
		_expect(counts != _player_pin_counts(row[0]), "dovetail copied the %s pin pattern" % row[1])
	for row in rhythm:
		_expect(counts == _player_pin_counts(row[0]), "dovetail should keep the %s pin rhythm" % row[1])
	var earlier: Array = []
	earlier.append_array(loose_pin)
	earlier.append_array(rhythm)
	for row in earlier:
		var book = row[0]
		var name := str(row[1])
		_expect(Dovetail.TITLE != book.TITLE, "dovetail shares a title with the %s" % name)
		_expect(Dovetail.FILE_CODE != book.FILE_CODE, "dovetail shares a file code with the %s" % name)
		_expect(_field_key(Dovetail) != _field_key(book), "dovetail copied the %s timeline fields" % name)
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	var earlier_texts := {}
	var earlier_sentences := {}
	for row in earlier:
		for old_exhibit in row[0].EXHIBITS:
			var old_text := str(old_exhibit["text"])
			earlier_texts[old_text] = true
			for old_sentence in old_text.split(". "):
				earlier_sentences[old_sentence.trim_suffix(".").strip_edges()] = true
	var exhibit_titles: Array[String] = []
	var exhibit_sources: Array[String] = []
	for exhibit in Dovetail.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		exhibit_titles.append(str(exhibit["title"]))
		exhibit_sources.append(str(exhibit["source"]))
		_expect(not seen.has(exhibit_id), "duplicate dovetail id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		_expect(not earlier_texts.has(str(exhibit["text"])), "dovetail copied an earlier exhibit")
		for sentence in str(exhibit["text"]).split(". "):
			var cleaned := sentence.trim_suffix(".").strip_edges()
			_expect(not earlier_sentences.has(cleaned), "dovetail copied an earlier sentence: %s" % cleaned)
		for banned in ["linen", "fold", "shears", "roller", "hem", "sheet", "crease", "press", "loft", "bench", "bottle", "cork", "seal", "mallet", "screw", "cellar", "wax", "neck", "plug", "dye", "vat", "indigo", "skein", "rope", "walk", "kettle", "winch", "pitch", "mesh", "shed", "rail", "crank", "needle", "twine", "cooperage", "cask", "hoop", "croze", "stave", "shop", "drawer"]:
			_expect(str(exhibit["text"]).find(banned) == -1, "%s copies %s" % [exhibit_id, banned])
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Dovetail.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Dovetail.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Dovetail.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Dovetail.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "dovetail should have two slips with two hidden facts, found %d" % paired_hidden)
	_expect(exhibit_titles == ["Saw chit", "Apron sight", "Peg hook", "Joint slate", "Clamp card", "Sweep slip", "Cut leaf", "Joint note", "Jaw order"], "dovetail exhibit titles are %s" % str(exhibit_titles))
	_expect(exhibit_sources == ["Yarrow, board hand", "Apron rail", "Stile peg", "Vise jaw", "Peck, clamp clerk", "Apron book", "Cut book", "Joiner's bench", "Stile slate"], "dovetail sources are %s" % str(exhibit_sources))
	for hour in Dovetail.HOURS:
		_expect(stated.has(hour), "dovetail hour %s is absent from the exhibits" % hour)

func _test_dovetail_unique_model() -> void:
	var models := Solver.enumerate(Dovetail.EXHIBITS, Dovetail)
	print("dovetail models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one dovetail model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Doss", "dovetail taker")
	_expect(str(model["place"]) == "vise", "dovetail place")
	_expect(str(model["hour"]) == "63", "dovetail hour")
	_expect(str(model["sawyer"]) == "Yarrow", "dovetail sawyer")
	_expect(str(model["saw_room"]) == "stile", "dovetail saw room")
	_expect(str(model["saw_hour"]) == "62", "dovetail saw hour")
	_expect(str(model["seen_from"]) == "apron", "dovetail seen from")
	_expect(str(model["clamp"]) == "Peck", "dovetail clamp")
	_expect(str(model["aim"]) == "take_joint", "dovetail aim")
	_expect(str(model["clamp_room"]) == "apron", "dovetail clamp room")
	_expect(str(model["peg_room"]) == "stile", "dovetail peg room")
	_expect(str(model["sweep_hour"]) == "61", "dovetail sweep hour")
	_expect(str(model["wipe_hour"]) == "64", "dovetail wipe hour")
	_expect(str(model["close_hour"]) == "65", "dovetail close hour")
	for hour in Dovetail.HOURS:
		var used := false
		for field in Dovetail.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "dovetail hour %s is blank in the true timeline" % hour)
	for place in Dovetail.PLACES:
		var place_used := false
		for field in Dovetail.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "dovetail room %s is blank in the true timeline" % place)
	for person in Dovetail.PEOPLE:
		var person_used := false
		for field in Dovetail.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "dovetail person %s is blank in the true timeline" % person)
	_expect(Dovetail.timeline(model) == DOVETAIL_TIMELINE, "dovetail timeline drifted:\n%s" % Dovetail.timeline(model))
	for exhibit in Dovetail.EXHIBITS:
		_expect(Dovetail.holds(exhibit, model), "%s rejects the dovetail timeline" % exhibit["id"])

func _test_dovetail_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Dovetail.EXHIBITS, Dovetail)
	for exhibit in Dovetail.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Dovetail.without(exhibit_id), Dovetail)
		print("dovetail without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "dovetail %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Dovetail.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "dovetail %s removal did not admit a timeline it forbids" % exhibit_id)

func _test_dovetail_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	var apron_miss := {"who": "Yarrow", "place": "apron", "hour": "61"}
	_expect(Dovetail.conflicting_ids(apron_miss).size() == 9, "Yarrow / apron / 61 contradicts %d exhibits" % Dovetail.conflicting_ids(apron_miss).size())
	for who in Dovetail.PEOPLE:
		for place in Dovetail.PLACES:
			for hour in Dovetail.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == DOVETAIL_TRUE["who"] and place == DOVETAIL_TRUE["place"] and hour == DOVETAIL_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Dovetail)
					print("dovetail true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true dovetail theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "dovetail acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(DOVETAIL_TIMELINE) >= 0, "dovetail acceptance should give the timeline")
					_expect(str(result["message"]).find("Doss") >= 0, "dovetail acceptance omits Doss")
					_expect(str(result["message"]).find("vise") >= 0, "dovetail acceptance omits the vise")
					_expect(str(result["message"]).find("63") >= 0, "dovetail acceptance omits 63")
					_expect(str(result["message"]).find("so the stile would take the joint") >= 0, "dovetail acceptance omits the joint")
					_expect(str(result["message"]).find("Doss (saw hand) cut the dovetail in the vise at 63") >= 0, "dovetail acceptance omits the cutting")
					_expect(Dovetail.conflicting_ids(theory).is_empty(), "true dovetail theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Dovetail)
					_expect(Dovetail.conflicting_ids(theory).size() >= 2, "%s / %s / %s contradicts fewer than two exhibits" % [who, place, hour])
					rejected += 1
	for outsider in ["Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal", "Nell"]:
		_expect_rejected({"who": outsider, "place": "vise", "hour": "63"}, Dovetail)
	print("dovetail theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d dovetail theories" % accepted)
	_expect(rejected >= 2, "rejected %d dovetail theories" % rejected)

func _test_dovetail_near_misses() -> void:
	var misses := [
		{"who": "Doss", "place": "vise", "hour": "64", "titles": ["Cut leaf", "Joint note", "Jaw order"]},
		{"who": "Doss", "place": "vise", "hour": "62", "titles": ["Cut leaf", "Joint note", "Jaw order"]},
		{"who": "Doss", "place": "apron", "hour": "63", "titles": ["Joint slate", "Clamp card", "Sweep slip"]},
		{"who": "Yarrow", "place": "vise", "hour": "63", "titles": ["Saw chit", "Apron sight", "Peg hook"]},
	]
	var wrong_hour_in_vise := 0
	var wrong_place_at_hour := 0
	var wrong_person_in_vise := 0
	for theory in misses:
		_expect_rejected(theory, Dovetail)
		var result: Dictionary = Verdict.submit(theory, Dovetail)
		var message := str(result["message"])
		_expect(Dovetail.conflicting_ids(theory).size() == 3, "near-miss should name three exhibits: %s" % message)
		for title in theory["titles"]:
			_expect(message.find(str(title)) >= 0, "near-miss omits %s: %s" % [title, message])
		if str(theory["who"]) == "Doss" and str(theory["place"]) == "vise" and str(theory["hour"]) != "63":
			wrong_hour_in_vise += 1
		if str(theory["who"]) == "Doss" and str(theory["place"]) != "vise" and str(theory["hour"]) == "63":
			wrong_place_at_hour += 1
		if str(theory["who"]) != "Doss" and str(theory["place"]) == "vise" and str(theory["hour"]) == "63":
			wrong_person_in_vise += 1
	print("dovetail near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four dovetail near-misses, found %d" % misses.size())
	_expect(wrong_hour_in_vise == 2, "two near-misses should keep Doss in the vise at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Doss at 63 in another room")
	_expect(wrong_person_in_vise >= 1, "a near-miss should keep the vise at 63 for another person")

func _test_dovetail_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
		"who stopped the night bell",
		"where they stopped the bell",
		"at which hour they stopped the bell",
		"who scored the salt mark",
		"where they scored the mark",
		"at which hour they scored the mark",
		"who trimmed the wick",
		"where they trimmed the wick",
		"at which hour they trimmed the wick",
		"who annealed the gather",
		"where they annealed the gather",
		"at which hour they annealed the gather",
		"who grafted the scion",
		"where they grafted the scion",
		"at which hour they grafted the scion",
		"who dipped the skein",
		"where they dipped the skein",
		"at which hour they dipped the skein",
		"who tarred the rope",
		"where they tarred the rope",
		"at which hour they tarred the rope",
		"who pressed the cork",
		"where they pressed the cork",
		"at which hour they pressed the cork",
		"who mended the net",
		"where they mended the net",
		"at which hour they mended the net",
		"who drove the hoop",
		"where they drove the hoop",
		"at which hour they drove the hoop",
		"who folded the linen",
		"where they folded the linen",
		"at which hour they folded the linen",
	]
	var cases := [
		{"theory": {"who": "", "place": "vise", "hour": "63"}, "present": ["who cut the dovetail"], "absent": ["where they cut the dovetail", "at which hour they cut the dovetail"]},
		{"theory": {"who": "Doss", "place": "", "hour": "63"}, "present": ["where they cut the dovetail"], "absent": ["who cut the dovetail", "at which hour they cut the dovetail"]},
		{"theory": {"who": "Doss", "place": "vise", "hour": ""}, "present": ["at which hour they cut the dovetail"], "absent": ["who cut the dovetail", "where they cut the dovetail"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who cut the dovetail", "where they cut the dovetail", "at which hour they cut the dovetail"], "absent": []},
		{"theory": {}, "present": ["who cut the dovetail", "where they cut the dovetail", "at which hour they cut the dovetail"], "absent": []},
		{"theory": {"who": "Peck", "place": "", "hour": "65"}, "present": ["where they cut the dovetail"], "absent": ["who cut the dovetail", "at which hour they cut the dovetail"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Dovetail)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "dovetail incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "dovetail incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "dovetail incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "dovetail incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "dovetail incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "dovetail missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "dovetail named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "dovetail incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("dovetail incomplete submissions refused with the missing slot")




func _test_mortise_file_shape() -> void:
	_expect(Mortise.EXHIBITS.size() == 9, "mortise exhibit count is %d" % Mortise.EXHIBITS.size())
	_expect(Mortise.PEOPLE.size() == 3, "mortise cast should be three people")
	_expect(Mortise.PLACES.size() == 3, "mortise room count is %d" % Mortise.PLACES.size())
	_expect(Mortise.HOURS.size() == 5, "mortise hour list length is %d" % Mortise.HOURS.size())
	_expect(Mortise.PEOPLE == ["Arlo", "Keel", "Weske"], "mortise cast is %s" % str(Mortise.PEOPLE))
	_expect(Mortise.PLACES == ["chisel", "last", "awl"], "mortise rooms are %s" % str(Mortise.PLACES))
	_expect(Mortise.HOURS == ["66", "67", "68", "69", "70"], "mortise hours are %s" % str(Mortise.HOURS))
	_expect(Mortise.ENDS == ["take_tenon", "spare_tenon", "set_tenon"], "mortise ends are %s" % str(Mortise.ENDS))
	_expect(Mortise.end_phrase("take_tenon") == "so the last would take the tenon", "mortise end phrase")
	_expect(Mortise.TITLE == "The mortise", "mortise title")
	_expect(Mortise.BLURB == "The mortise left its peg at the joiner's rack. Name who cut the mortise, the room they cut it in, and the hour.", "mortise blurb")
	_expect(Mortise.FILE_CODE == "CW-25", "mortise file code")
	_expect(Mortise.fields() == ["taker", "place", "hour", "borer", "bore_room", "bore_hour", "sight_from", "brace", "end", "brace_room", "wedge_room", "brush_hour", "rag_hour", "rack_hour"], "mortise fields are %s" % str(Mortise.fields()))
	_expect(Mortise.PLAYER_FIELDS == ["taker", "place", "hour"], "mortise player fields")
	_expect(Mortise.HOURS[Mortise.HOURS.size() / 2] == MORTISE_TRUE["hour"], "mortise cutting should be the middle hour")
	_expect(Mortise.HOURS[0] != MORTISE_TRUE["hour"], "mortise cutting should not be the earliest hour")
	_expect(Mortise.HOURS[Mortise.HOURS.size() - 1] != MORTISE_TRUE["hour"], "mortise cutting should not be the latest hour")
	var counts := _player_pin_counts(Mortise)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "mortise pin counts are %s" % str(counts))
	var loose_pin: Array = [
		[CaseData, "spare key"],
		[Rehearsal, "rehearsal score"],
		[Gilt, "gilt stamp"],
		[Ferry, "ferry bell"],
		[Weather, "weather slate"],
		[Loom, "loom shuttle"],
		[Hive, "hive smoker"],
		[Glass, "glass pontil"],
		[Press, "press proof"],
		[Assay, "assay cup"],
	]
	var rhythm: Array = [
		[Kiln, "kiln chalk"],
		[Tide, "tide ledger"],
		[Night, "night bell"],
		[Salt, "salt mark"],
		[Wick, "wick trim"],
		[Anneal, "glass anneal"],
		[Graft, "orchard graft"],
		[Dye, "dye vat"],
		[Tar, "tar kettle"],
		[Cork, "cork press"],
		[Net, "net loft"],
		[Cask, "cask hoop"],
		[Linen, "linen fold"],
		[Dovetail, "dovetail"],
	]
	for row in loose_pin:
		_expect(counts != _player_pin_counts(row[0]), "mortise copied the %s pin pattern" % row[1])
	for row in rhythm:
		_expect(counts == _player_pin_counts(row[0]), "mortise should keep the %s pin rhythm" % row[1])
	var earlier: Array = []
	earlier.append_array(loose_pin)
	earlier.append_array(rhythm)
	for row in earlier:
		var book = row[0]
		var name := str(row[1])
		_expect(Mortise.TITLE != book.TITLE, "mortise shares a title with the %s" % name)
		_expect(Mortise.FILE_CODE != book.FILE_CODE, "mortise shares a file code with the %s" % name)
		_expect(_field_key(Mortise) != _field_key(book), "mortise copied the %s timeline fields" % name)
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	var earlier_texts := {}
	var earlier_sentences := {}
	for row in earlier:
		for old_exhibit in row[0].EXHIBITS:
			var old_text := str(old_exhibit["text"])
			earlier_texts[old_text] = true
			for old_sentence in old_text.split(". "):
				earlier_sentences[old_sentence.trim_suffix(".").strip_edges()] = true
	var exhibit_titles: Array[String] = []
	var exhibit_sources: Array[String] = []
	for exhibit in Mortise.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		exhibit_titles.append(str(exhibit["title"]))
		exhibit_sources.append(str(exhibit["source"]))
		_expect(not seen.has(exhibit_id), "duplicate mortise id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		_expect(not earlier_texts.has(str(exhibit["text"])), "mortise copied an earlier exhibit")
		for sentence in str(exhibit["text"]).split(". "):
			var cleaned := sentence.trim_suffix(".").strip_edges()
			_expect(not earlier_sentences.has(cleaned), "mortise copied an earlier sentence: %s" % cleaned)
		for banned in ["dovetail", "vise", "stile", "apron", "saw", "clamp", "peg", "joint", "linen", "fold", "shears", "roller", "hem", "sheet", "crease", "press", "loft", "bench", "bottle", "cork", "shop", "drawer", "seal", "mallet", "screw", "cellar", "wax", "neck", "plug", "dye", "vat", "indigo", "skein", "rope", "walk", "kettle", "winch", "pitch", "mesh", "rail", "crank", "needle", "twine", "cooperage", "cask", "hoop", "croze", "stave"]:
			_expect(str(exhibit["text"]).find(banned) == -1, "%s copies %s" % [exhibit_id, banned])
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Mortise.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Mortise.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Mortise.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Mortise.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "mortise should have two slips with two hidden facts, found %d" % paired_hidden)
	_expect(exhibit_titles == ["Chisel chit", "Awl sight", "Wedge hook", "Tenon slate", "Brace card", "Brush slip", "Bore leaf", "Tenon note", "Rack order"], "mortise exhibit titles are %s" % str(exhibit_titles))
	_expect(exhibit_sources == ["Keel, awl hand", "Awl rail", "Last peg", "Chisel jaw", "Weske, last clerk", "Awl book", "Bore book", "Joiner's rack", "Last slate"], "mortise sources are %s" % str(exhibit_sources))
	for hour in Mortise.HOURS:
		_expect(stated.has(hour), "mortise hour %s is absent from the exhibits" % hour)

func _test_mortise_unique_model() -> void:
	var models := Solver.enumerate(Mortise.EXHIBITS, Mortise)
	print("mortise models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one mortise model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Arlo", "mortise taker")
	_expect(str(model["place"]) == "chisel", "mortise place")
	_expect(str(model["hour"]) == "68", "mortise hour")
	_expect(str(model["borer"]) == "Keel", "mortise borer")
	_expect(str(model["bore_room"]) == "last", "mortise bore room")
	_expect(str(model["bore_hour"]) == "67", "mortise bore hour")
	_expect(str(model["sight_from"]) == "awl", "mortise sight from")
	_expect(str(model["brace"]) == "Weske", "mortise brace")
	_expect(str(model["end"]) == "take_tenon", "mortise end")
	_expect(str(model["brace_room"]) == "awl", "mortise brace room")
	_expect(str(model["wedge_room"]) == "last", "mortise wedge room")
	_expect(str(model["brush_hour"]) == "66", "mortise brush hour")
	_expect(str(model["rag_hour"]) == "69", "mortise rag hour")
	_expect(str(model["rack_hour"]) == "70", "mortise rack hour")
	for hour in Mortise.HOURS:
		var used := false
		for field in Mortise.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "mortise hour %s is blank in the true timeline" % hour)
	for place in Mortise.PLACES:
		var place_used := false
		for field in Mortise.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "mortise room %s is blank in the true timeline" % place)
	for person in Mortise.PEOPLE:
		var person_used := false
		for field in Mortise.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "mortise person %s is blank in the true timeline" % person)
	_expect(Mortise.timeline(model) == MORTISE_TIMELINE, "mortise timeline drifted:\n%s" % Mortise.timeline(model))
	for exhibit in Mortise.EXHIBITS:
		_expect(Mortise.holds(exhibit, model), "%s rejects the mortise timeline" % exhibit["id"])

func _test_mortise_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Mortise.EXHIBITS, Mortise)
	for exhibit in Mortise.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Mortise.without(exhibit_id), Mortise)
		print("mortise without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "mortise %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Mortise.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "mortise %s removal did not admit a timeline it forbids" % exhibit_id)

func _test_mortise_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	var awl_miss := {"who": "Keel", "place": "awl", "hour": "66"}
	_expect(Mortise.conflicting_ids(awl_miss).size() == 9, "Keel / awl / 66 contradicts %d exhibits" % Mortise.conflicting_ids(awl_miss).size())
	for who in Mortise.PEOPLE:
		for place in Mortise.PLACES:
			for hour in Mortise.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == MORTISE_TRUE["who"] and place == MORTISE_TRUE["place"] and hour == MORTISE_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Mortise)
					print("mortise true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true mortise theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "mortise acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(MORTISE_TIMELINE) >= 0, "mortise acceptance should give the timeline")
					_expect(str(result["message"]).find("Arlo") >= 0, "mortise acceptance omits Arlo")
					_expect(str(result["message"]).find("chisel") >= 0, "mortise acceptance omits the chisel")
					_expect(str(result["message"]).find("68") >= 0, "mortise acceptance omits 68")
					_expect(str(result["message"]).find("so the last would take the tenon") >= 0, "mortise acceptance omits the tenon")
					_expect(str(result["message"]).find("Arlo (chisel hand) cut the mortise in the chisel at 68") >= 0, "mortise acceptance omits the cutting")
					_expect(Mortise.conflicting_ids(theory).is_empty(), "true mortise theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Mortise)
					_expect(Mortise.conflicting_ids(theory).size() >= 2, "%s / %s / %s contradicts fewer than two exhibits" % [who, place, hour])
					rejected += 1
	for outsider in ["Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal", "Nell"]:
		_expect_rejected({"who": outsider, "place": "chisel", "hour": "68"}, Mortise)
	print("mortise theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d mortise theories" % accepted)
	_expect(rejected >= 2, "rejected %d mortise theories" % rejected)

func _test_mortise_near_misses() -> void:
	var misses := [
		{"who": "Arlo", "place": "chisel", "hour": "69", "titles": ["Bore leaf", "Tenon note", "Rack order"]},
		{"who": "Arlo", "place": "chisel", "hour": "67", "titles": ["Bore leaf", "Tenon note", "Rack order"]},
		{"who": "Arlo", "place": "awl", "hour": "68", "titles": ["Tenon slate", "Brace card", "Brush slip"]},
		{"who": "Keel", "place": "chisel", "hour": "68", "titles": ["Chisel chit", "Awl sight", "Wedge hook"]},
	]
	var wrong_hour_in_chisel := 0
	var wrong_place_at_hour := 0
	var wrong_person_in_chisel := 0
	for theory in misses:
		_expect_rejected(theory, Mortise)
		var result: Dictionary = Verdict.submit(theory, Mortise)
		var message := str(result["message"])
		_expect(Mortise.conflicting_ids(theory).size() == 3, "near-miss should name three exhibits: %s" % message)
		for title in theory["titles"]:
			_expect(message.find(str(title)) >= 0, "near-miss omits %s: %s" % [title, message])
		if str(theory["who"]) == "Arlo" and str(theory["place"]) == "chisel" and str(theory["hour"]) != "68":
			wrong_hour_in_chisel += 1
		if str(theory["who"]) == "Arlo" and str(theory["place"]) != "chisel" and str(theory["hour"]) == "68":
			wrong_place_at_hour += 1
		if str(theory["who"]) != "Arlo" and str(theory["place"]) == "chisel" and str(theory["hour"]) == "68":
			wrong_person_in_chisel += 1
	print("mortise near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four mortise near-misses, found %d" % misses.size())
	_expect(wrong_hour_in_chisel == 2, "two near-misses should keep Arlo in the chisel at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Arlo at 68 in another room")
	_expect(wrong_person_in_chisel >= 1, "a near-miss should keep the chisel at 68 for another person")

func _test_mortise_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
		"who stopped the night bell",
		"where they stopped the bell",
		"at which hour they stopped the bell",
		"who scored the salt mark",
		"where they scored the mark",
		"at which hour they scored the mark",
		"who trimmed the wick",
		"where they trimmed the wick",
		"at which hour they trimmed the wick",
		"who annealed the gather",
		"where they annealed the gather",
		"at which hour they annealed the gather",
		"who grafted the scion",
		"where they grafted the scion",
		"at which hour they grafted the scion",
		"who dipped the skein",
		"where they dipped the skein",
		"at which hour they dipped the skein",
		"who tarred the rope",
		"where they tarred the rope",
		"at which hour they tarred the rope",
		"who pressed the cork",
		"where they pressed the cork",
		"at which hour they pressed the cork",
		"who mended the net",
		"where they mended the net",
		"at which hour they mended the net",
		"who drove the hoop",
		"where they drove the hoop",
		"at which hour they drove the hoop",
		"who folded the linen",
		"where they folded the linen",
		"at which hour they folded the linen",
		"who cut the dovetail",
		"where they cut the dovetail",
		"at which hour they cut the dovetail",
	]
	var cases := [
		{"theory": {"who": "", "place": "chisel", "hour": "68"}, "present": ["who cut the mortise"], "absent": ["where they cut the mortise", "at which hour they cut the mortise"]},
		{"theory": {"who": "Arlo", "place": "", "hour": "68"}, "present": ["where they cut the mortise"], "absent": ["who cut the mortise", "at which hour they cut the mortise"]},
		{"theory": {"who": "Arlo", "place": "chisel", "hour": ""}, "present": ["at which hour they cut the mortise"], "absent": ["who cut the mortise", "where they cut the mortise"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who cut the mortise", "where they cut the mortise", "at which hour they cut the mortise"], "absent": []},
		{"theory": {}, "present": ["who cut the mortise", "where they cut the mortise", "at which hour they cut the mortise"], "absent": []},
		{"theory": {"who": "Weske", "place": "", "hour": "70"}, "present": ["where they cut the mortise"], "absent": ["who cut the mortise", "at which hour they cut the mortise"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Mortise)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "mortise incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "mortise incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "mortise incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "mortise incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "mortise incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "mortise missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "mortise named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "mortise incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("mortise incomplete submissions refused with the missing slot")


func _test_rebate_file_shape() -> void:
	_expect(Rebate.EXHIBITS.size() == 9, "rebate exhibit count is %d" % Rebate.EXHIBITS.size())
	_expect(Rebate.PEOPLE.size() == 3, "rebate cast should be three people")
	_expect(Rebate.PLACES.size() == 3, "rebate room count is %d" % Rebate.PLACES.size())
	_expect(Rebate.HOURS.size() == 5, "rebate hour list length is %d" % Rebate.HOURS.size())
	_expect(Rebate.PEOPLE == ["Tansy", "Solt", "Quern"], "rebate cast is %s" % str(Rebate.PEOPLE))
	_expect(Rebate.PLACES == ["plane", "gauge", "mallet"], "rebate rooms are %s" % str(Rebate.PLACES))
	_expect(Rebate.HOURS == ["71", "72", "73", "74", "75"], "rebate hours are %s" % str(Rebate.HOURS))
	_expect(Rebate.AIMS == ["take_shoulder", "spare_shoulder", "set_shoulder"], "rebate aims are %s" % str(Rebate.AIMS))
	_expect(Rebate.aim_phrase("take_shoulder") == "so the mallet would take the shoulder", "rebate aim phrase")
	_expect(Rebate.aim_phrase("spare_shoulder") == "to spare the shoulder still waiting on the mallet", "rebate spare aim")
	_expect(Rebate.aim_phrase("set_shoulder") == "to set the shoulder before the plane was hung", "rebate set aim")
	_expect(Rebate.TITLE == "The rebate", "rebate title")
	_expect(Rebate.BLURB == "The rebate left its peg at the joiner's wall. Name who cut the rebate, the room they cut it in, and the hour.", "rebate blurb")
	_expect(Rebate.FILE_CODE == "CW-26", "rebate file code")
	_expect(Rebate.fields() == ["taker", "place", "hour", "scribe", "scribe_room", "scribe_hour", "seen_from", "fence", "aim", "fence_room", "shim_room", "oil_hour", "wipe_hour", "hang_hour"], "rebate fields are %s" % str(Rebate.fields()))
	_expect(Rebate.PLAYER_FIELDS == ["taker", "place", "hour"], "rebate player fields")
	_expect(Rebate.HOURS[Rebate.HOURS.size() / 2] == REBATE_TRUE["hour"], "rebate cutting should be the middle hour")
	_expect(Rebate.HOURS[0] != REBATE_TRUE["hour"], "rebate cutting should not be the earliest hour")
	_expect(Rebate.HOURS[Rebate.HOURS.size() - 1] != REBATE_TRUE["hour"], "rebate cutting should not be the latest hour")
	var counts := _player_pin_counts(Rebate)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "rebate pin counts are %s" % str(counts))
	var loose_pin: Array = [
		[CaseData, "spare key"],
		[Rehearsal, "rehearsal score"],
		[Gilt, "gilt stamp"],
		[Ferry, "ferry bell"],
		[Weather, "weather slate"],
		[Loom, "loom shuttle"],
		[Hive, "hive smoker"],
		[Glass, "glass pontil"],
		[Press, "press proof"],
		[Assay, "assay cup"],
	]
	var rhythm: Array = [
		[Kiln, "kiln chalk"],
		[Tide, "tide ledger"],
		[Night, "night bell"],
		[Salt, "salt mark"],
		[Wick, "wick trim"],
		[Anneal, "glass anneal"],
		[Graft, "orchard graft"],
		[Dye, "dye vat"],
		[Tar, "tar kettle"],
		[Cork, "cork press"],
		[Net, "net loft"],
		[Cask, "cask hoop"],
		[Linen, "linen fold"],
		[Dovetail, "dovetail"],
		[Mortise, "mortise"],
	]
	for row in loose_pin:
		_expect(counts != _player_pin_counts(row[0]), "rebate copied the %s pin pattern" % row[1])
	for row in rhythm:
		_expect(counts == _player_pin_counts(row[0]), "rebate should keep the %s pin rhythm" % row[1])
	var earlier: Array = []
	earlier.append_array(loose_pin)
	earlier.append_array(rhythm)
	for row in earlier:
		var book = row[0]
		var name := str(row[1])
		_expect(Rebate.TITLE != book.TITLE, "rebate shares a title with the %s" % name)
		_expect(Rebate.FILE_CODE != book.FILE_CODE, "rebate shares a file code with the %s" % name)
		_expect(_field_key(Rebate) != _field_key(book), "rebate copied the %s timeline fields" % name)
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	var earlier_texts := {}
	var earlier_sentences := {}
	for row in earlier:
		for old_exhibit in row[0].EXHIBITS:
			var old_text := str(old_exhibit["text"])
			earlier_texts[old_text] = true
			for old_sentence in old_text.split(". "):
				earlier_sentences[old_sentence.trim_suffix(".").strip_edges()] = true
	var exhibit_titles: Array[String] = []
	var exhibit_sources: Array[String] = []
	for exhibit in Rebate.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		exhibit_titles.append(str(exhibit["title"]))
		exhibit_sources.append(str(exhibit["source"]))
		_expect(not seen.has(exhibit_id), "duplicate rebate id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		_expect(not earlier_texts.has(str(exhibit["text"])), "rebate copied an earlier exhibit")
		for sentence in str(exhibit["text"]).split(". "):
			var cleaned := sentence.trim_suffix(".").strip_edges()
			_expect(not earlier_sentences.has(cleaned), "rebate copied an earlier sentence: %s" % cleaned)
		for banned in ["mortise", "chisel", "tenon", "awl", "brace", "wedge", "bored", "ragged", "racked", "dovetail", "vise", "stile", "apron", "saw", "clamp", "peg", "joint", "linen", "fold", "shears", "roller", "hem", "sheet", "crease", "press", "loft", "bench", "bottle", "cork", "shop", "drawer", "seal", "screw", "cellar", "wax", "neck", "plug", "dye", "vat", "indigo", "skein", "rope", "walk", "kettle", "winch", "pitch", "mesh", "rail", "crank", "needle", "twine", "cooperage", "cask", "hoop", "croze", "stave"]:
			_expect(str(exhibit["text"]).find(banned) == -1, "%s copies %s" % [exhibit_id, banned])
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Rebate.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Rebate.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Rebate.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Rebate.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "rebate should have two slips with two hidden facts, found %d" % paired_hidden)
	_expect(exhibit_titles == ["Plane chit", "Gauge sight", "Shim hook", "Shoulder slate", "Fence card", "Oil slip", "Scribe leaf", "Shoulder note", "Hang order"], "rebate exhibit titles are %s" % str(exhibit_titles))
	_expect(exhibit_sources == ["Solt, gauge hand", "Gauge rail", "Mallet peg", "Plane jaw", "Quern, mallet clerk", "Gauge book", "Scribe book", "Joiner's wall", "Mallet slate"], "rebate sources are %s" % str(exhibit_sources))
	for hour in Rebate.HOURS:
		_expect(stated.has(hour), "rebate hour %s is absent from the exhibits" % hour)

func _test_rebate_unique_model() -> void:
	var models := Solver.enumerate(Rebate.EXHIBITS, Rebate)
	print("rebate models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one rebate model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Tansy", "rebate taker")
	_expect(str(model["place"]) == "plane", "rebate place")
	_expect(str(model["hour"]) == "73", "rebate hour")
	_expect(str(model["scribe"]) == "Solt", "rebate scribe")
	_expect(str(model["scribe_room"]) == "mallet", "rebate scribe room")
	_expect(str(model["scribe_hour"]) == "72", "rebate scribe hour")
	_expect(str(model["seen_from"]) == "gauge", "rebate seen from")
	_expect(str(model["fence"]) == "Quern", "rebate fence")
	_expect(str(model["aim"]) == "take_shoulder", "rebate aim")
	_expect(str(model["fence_room"]) == "gauge", "rebate fence room")
	_expect(str(model["shim_room"]) == "mallet", "rebate shim room")
	_expect(str(model["oil_hour"]) == "71", "rebate oil hour")
	_expect(str(model["wipe_hour"]) == "74", "rebate wipe hour")
	_expect(str(model["hang_hour"]) == "75", "rebate hang hour")
	for hour in Rebate.HOURS:
		var used := false
		for field in Rebate.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "rebate hour %s is blank in the true timeline" % hour)
	for place in Rebate.PLACES:
		var place_used := false
		for field in Rebate.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "rebate room %s is blank in the true timeline" % place)
	for person in Rebate.PEOPLE:
		var person_used := false
		for field in Rebate.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "rebate person %s is blank in the true timeline" % person)
	_expect(Rebate.timeline(model) == REBATE_TIMELINE, "rebate timeline drifted:\n%s" % Rebate.timeline(model))
	for exhibit in Rebate.EXHIBITS:
		_expect(Rebate.holds(exhibit, model), "%s rejects the rebate timeline" % exhibit["id"])

func _test_rebate_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Rebate.EXHIBITS, Rebate)
	for exhibit in Rebate.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Rebate.without(exhibit_id), Rebate)
		print("rebate without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "rebate %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Rebate.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "rebate %s removal did not admit a timeline it forbids" % exhibit_id)

func _test_rebate_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	var gauge_miss := {"who": "Solt", "place": "gauge", "hour": "71"}
	_expect(Rebate.conflicting_ids(gauge_miss).size() == 9, "Solt / gauge / 71 contradicts %d exhibits" % Rebate.conflicting_ids(gauge_miss).size())
	for who in Rebate.PEOPLE:
		for place in Rebate.PLACES:
			for hour in Rebate.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == REBATE_TRUE["who"] and place == REBATE_TRUE["place"] and hour == REBATE_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Rebate)
					print("rebate true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true rebate theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "rebate acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(REBATE_TIMELINE) >= 0, "rebate acceptance should give the timeline")
					_expect(str(result["message"]).find("Tansy") >= 0, "rebate acceptance omits Tansy")
					_expect(str(result["message"]).find("plane") >= 0, "rebate acceptance omits the plane")
					_expect(str(result["message"]).find("73") >= 0, "rebate acceptance omits 73")
					_expect(str(result["message"]).find("so the mallet would take the shoulder") >= 0, "rebate acceptance omits the shoulder")
					_expect(str(result["message"]).find("Tansy (plane hand) cut the rebate in the plane at 73") >= 0, "rebate acceptance omits the cutting")
					_expect(Rebate.conflicting_ids(theory).is_empty(), "true rebate theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Rebate)
					_expect(Rebate.conflicting_ids(theory).size() >= 2, "%s / %s / %s contradicts fewer than two exhibits" % [who, place, hour])
					rejected += 1
	for outsider in ["Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal", "Nell"]:
		_expect_rejected({"who": outsider, "place": "plane", "hour": "73"}, Rebate)
	print("rebate theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d rebate theories" % accepted)
	_expect(rejected >= 2, "rejected %d rebate theories" % rejected)

func _test_rebate_near_misses() -> void:
	var misses := [
		{"who": "Tansy", "place": "plane", "hour": "74", "titles": ["Scribe leaf", "Shoulder note", "Hang order"]},
		{"who": "Tansy", "place": "plane", "hour": "72", "titles": ["Scribe leaf", "Shoulder note", "Hang order"]},
		{"who": "Tansy", "place": "gauge", "hour": "73", "titles": ["Shoulder slate", "Fence card", "Oil slip"]},
		{"who": "Solt", "place": "plane", "hour": "73", "titles": ["Plane chit", "Gauge sight", "Shim hook"]},
	]
	var wrong_hour_in_plane := 0
	var wrong_place_at_hour := 0
	var wrong_person_in_plane := 0
	for theory in misses:
		_expect_rejected(theory, Rebate)
		var result: Dictionary = Verdict.submit(theory, Rebate)
		var message := str(result["message"])
		_expect(Rebate.conflicting_ids(theory).size() == 3, "near-miss should name three exhibits: %s" % message)
		for title in theory["titles"]:
			_expect(message.find(str(title)) >= 0, "near-miss omits %s: %s" % [title, message])
		if str(theory["who"]) == "Tansy" and str(theory["place"]) == "plane" and str(theory["hour"]) != "73":
			wrong_hour_in_plane += 1
		if str(theory["who"]) == "Tansy" and str(theory["place"]) != "plane" and str(theory["hour"]) == "73":
			wrong_place_at_hour += 1
		if str(theory["who"]) != "Tansy" and str(theory["place"]) == "plane" and str(theory["hour"]) == "73":
			wrong_person_in_plane += 1
	print("rebate near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four rebate near-misses, found %d" % misses.size())
	_expect(wrong_hour_in_plane == 2, "two near-misses should keep Tansy in the plane at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Tansy at 73 in another room")
	_expect(wrong_person_in_plane >= 1, "a near-miss should keep the plane at 73 for another person")

func _test_rebate_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
		"who stopped the night bell",
		"where they stopped the bell",
		"at which hour they stopped the bell",
		"who scored the salt mark",
		"where they scored the mark",
		"at which hour they scored the mark",
		"who trimmed the wick",
		"where they trimmed the wick",
		"at which hour they trimmed the wick",
		"who annealed the gather",
		"where they annealed the gather",
		"at which hour they annealed the gather",
		"who grafted the scion",
		"where they grafted the scion",
		"at which hour they grafted the scion",
		"who dipped the skein",
		"where they dipped the skein",
		"at which hour they dipped the skein",
		"who tarred the rope",
		"where they tarred the rope",
		"at which hour they tarred the rope",
		"who pressed the cork",
		"where they pressed the cork",
		"at which hour they pressed the cork",
		"who mended the net",
		"where they mended the net",
		"at which hour they mended the net",
		"who drove the hoop",
		"where they drove the hoop",
		"at which hour they drove the hoop",
		"who folded the linen",
		"where they folded the linen",
		"at which hour they folded the linen",
		"who cut the dovetail",
		"where they cut the dovetail",
		"at which hour they cut the dovetail",
		"who cut the mortise",
		"where they cut the mortise",
		"at which hour they cut the mortise",
	]
	var cases := [
		{"theory": {"who": "", "place": "plane", "hour": "73"}, "present": ["who cut the rebate"], "absent": ["where they cut the rebate", "at which hour they cut the rebate"]},
		{"theory": {"who": "Tansy", "place": "", "hour": "73"}, "present": ["where they cut the rebate"], "absent": ["who cut the rebate", "at which hour they cut the rebate"]},
		{"theory": {"who": "Tansy", "place": "plane", "hour": ""}, "present": ["at which hour they cut the rebate"], "absent": ["who cut the rebate", "where they cut the rebate"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who cut the rebate", "where they cut the rebate", "at which hour they cut the rebate"], "absent": []},
		{"theory": {}, "present": ["who cut the rebate", "where they cut the rebate", "at which hour they cut the rebate"], "absent": []},
		{"theory": {"who": "Quern", "place": "", "hour": "75"}, "present": ["where they cut the rebate"], "absent": ["who cut the rebate", "at which hour they cut the rebate"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Rebate)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "rebate incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "rebate incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "rebate incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "rebate incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "rebate incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "rebate missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "rebate named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "rebate incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("rebate incomplete submissions refused with the missing slot")


func _test_housing_file_shape() -> void:
	_expect(Housing.EXHIBITS.size() == 9, "housing exhibit count is %d" % Housing.EXHIBITS.size())
	_expect(Housing.PEOPLE.size() == 3, "housing cast should be three people")
	_expect(Housing.PLACES.size() == 3, "housing room count is %d" % Housing.PLACES.size())
	_expect(Housing.HOURS.size() == 5, "housing hour list length is %d" % Housing.HOURS.size())
	_expect(Housing.PEOPLE == ["Ewan", "Maren", "Hollin"], "housing cast is %s" % str(Housing.PEOPLE))
	_expect(Housing.PLACES == ["saw", "square", "bead"], "housing rooms are %s" % str(Housing.PLACES))
	_expect(Housing.HOURS == ["76", "77", "78", "79", "80"], "housing hours are %s" % str(Housing.HOURS))
	_expect(Housing.AIMS == ["take_trench", "spare_trench", "set_trench"], "housing aims are %s" % str(Housing.AIMS))
	_expect(Housing.aim_phrase("take_trench") == "so the bead would take the trench", "housing aim phrase")
	_expect(Housing.aim_phrase("spare_trench") == "to spare the trench still waiting on the bead", "housing spare aim")
	_expect(Housing.aim_phrase("set_trench") == "to set the trench before the saw was hung", "housing set aim")
	_expect(Housing.TITLE == "The housing", "housing title")
	_expect(Housing.BLURB == "The housing left its peg at the joiner's horse. Name who cut the housing, the room they cut it in, and the hour.", "housing blurb")
	_expect(Housing.FILE_CODE == "CW-27", "housing file code")
	_expect(Housing.fields() == ["taker", "place", "hour", "marker", "mark_room", "mark_hour", "seen_from", "stock", "aim", "stock_room", "fillet_room", "chalk_hour", "wipe_hour", "hang_hour"], "housing fields are %s" % str(Housing.fields()))
	_expect(Housing.PLAYER_FIELDS == ["taker", "place", "hour"], "housing player fields")
	_expect(Housing.HOURS[Housing.HOURS.size() / 2] == HOUSING_TRUE["hour"], "housing cutting should be the middle hour")
	_expect(Housing.HOURS[0] != HOUSING_TRUE["hour"], "housing cutting should not be the earliest hour")
	_expect(Housing.HOURS[Housing.HOURS.size() - 1] != HOUSING_TRUE["hour"], "housing cutting should not be the latest hour")
	var counts := _player_pin_counts(Housing)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "housing pin counts are %s" % str(counts))
	var loose_pin: Array = [
		[CaseData, "spare key"],
		[Rehearsal, "rehearsal score"],
		[Gilt, "gilt stamp"],
		[Ferry, "ferry bell"],
		[Weather, "weather slate"],
		[Loom, "loom shuttle"],
		[Hive, "hive smoker"],
		[Glass, "glass pontil"],
		[Press, "press proof"],
		[Assay, "assay cup"],
	]
	var rhythm: Array = [
		[Kiln, "kiln chalk"],
		[Tide, "tide ledger"],
		[Night, "night bell"],
		[Salt, "salt mark"],
		[Wick, "wick trim"],
		[Anneal, "glass anneal"],
		[Graft, "orchard graft"],
		[Dye, "dye vat"],
		[Tar, "tar kettle"],
		[Cork, "cork press"],
		[Net, "net loft"],
		[Cask, "cask hoop"],
		[Linen, "linen fold"],
		[Dovetail, "dovetail"],
		[Mortise, "mortise"],
		[Rebate, "rebate"],
	]
	for row in loose_pin:
		_expect(counts != _player_pin_counts(row[0]), "housing copied the %s pin pattern" % row[1])
	for row in rhythm:
		_expect(counts == _player_pin_counts(row[0]), "housing should keep the %s pin rhythm" % row[1])
	var earlier: Array = []
	earlier.append_array(loose_pin)
	earlier.append_array(rhythm)
	for row in earlier:
		var book = row[0]
		var name := str(row[1])
		_expect(Housing.TITLE != book.TITLE, "housing shares a title with the %s" % name)
		_expect(Housing.FILE_CODE != book.FILE_CODE, "housing shares a file code with the %s" % name)
		_expect(_field_key(Housing) != _field_key(book), "housing copied the %s timeline fields" % name)
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	var earlier_texts := {}
	var earlier_sentences := {}
	for row in earlier:
		for old_exhibit in row[0].EXHIBITS:
			var old_text := str(old_exhibit["text"])
			earlier_texts[old_text] = true
			for old_sentence in old_text.split(". "):
				earlier_sentences[old_sentence.trim_suffix(".").strip_edges()] = true
	var exhibit_titles: Array[String] = []
	var exhibit_sources: Array[String] = []
	for exhibit in Housing.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		exhibit_titles.append(str(exhibit["title"]))
		exhibit_sources.append(str(exhibit["source"]))
		_expect(not seen.has(exhibit_id), "duplicate housing id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		_expect(not earlier_texts.has(str(exhibit["text"])), "housing copied an earlier exhibit")
		for sentence in str(exhibit["text"]).split(". "):
			var cleaned := sentence.trim_suffix(".").strip_edges()
			_expect(not earlier_sentences.has(cleaned), "housing copied an earlier sentence: %s" % cleaned)
		for banned in ["mortise", "chisel", "tenon", "awl", "brace", "wedge", "bored", "ragged", "racked", "dovetail", "vise", "stile", "apron", "clamp", "peg", "joint", "linen", "fold", "shears", "roller", "hem", "sheet", "crease", "press", "loft", "bench", "bottle", "cork", "shop", "drawer", "seal", "screw", "cellar", "wax", "neck", "plug", "dye", "vat", "indigo", "skein", "rope", "walk", "kettle", "winch", "pitch", "mesh", "rail", "crank", "needle", "twine", "cooperage", "cask", "hoop", "croze", "stave", "rebate", "plane", "gauge", "mallet", "shoulder", "scribe", "shim", "fence", "tansy", "solt", "quern"]:
			_expect(str(exhibit["text"]).find(banned) == -1, "%s copies %s" % [exhibit_id, banned])
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Housing.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Housing.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Housing.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Housing.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "housing should have two slips with two hidden facts, found %d" % paired_hidden)
	_expect(exhibit_titles == ["Saw chit", "Square sight", "Fillet hook", "Trench slate", "Stock card", "Chalk slip", "Mark leaf", "Trench note", "Hang order"], "housing exhibit titles are %s" % str(exhibit_titles))
	_expect(exhibit_sources == ["Maren, square hand", "Square rail", "Bead peg", "Saw jaw", "Hollin, bead clerk", "Square book", "Mark book", "Joiner's horse", "Bead slate"], "housing sources are %s" % str(exhibit_sources))
	for hour in Housing.HOURS:
		_expect(stated.has(hour), "housing hour %s is absent from the exhibits" % hour)

func _test_housing_unique_model() -> void:
	var models := Solver.enumerate(Housing.EXHIBITS, Housing)
	print("housing models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one housing model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Ewan", "housing taker")
	_expect(str(model["place"]) == "saw", "housing place")
	_expect(str(model["hour"]) == "78", "housing hour")
	_expect(str(model["marker"]) == "Maren", "housing marker")
	_expect(str(model["mark_room"]) == "bead", "housing marker room")
	_expect(str(model["mark_hour"]) == "77", "housing marker hour")
	_expect(str(model["seen_from"]) == "square", "housing seen from")
	_expect(str(model["stock"]) == "Hollin", "housing stock")
	_expect(str(model["aim"]) == "take_trench", "housing aim")
	_expect(str(model["stock_room"]) == "square", "housing stock room")
	_expect(str(model["fillet_room"]) == "bead", "housing fillet room")
	_expect(str(model["chalk_hour"]) == "76", "housing chalk hour")
	_expect(str(model["wipe_hour"]) == "79", "housing wipe hour")
	_expect(str(model["hang_hour"]) == "80", "housing hang hour")
	for hour in Housing.HOURS:
		var used := false
		for field in Housing.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "housing hour %s is blank in the true timeline" % hour)
	for place in Housing.PLACES:
		var place_used := false
		for field in Housing.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "housing room %s is blank in the true timeline" % place)
	for person in Housing.PEOPLE:
		var person_used := false
		for field in Housing.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "housing person %s is blank in the true timeline" % person)
	_expect(Housing.timeline(model) == HOUSING_TIMELINE, "housing timeline drifted:\n%s" % Housing.timeline(model))
	for exhibit in Housing.EXHIBITS:
		_expect(Housing.holds(exhibit, model), "%s rejects the housing timeline" % exhibit["id"])

func _test_housing_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Housing.EXHIBITS, Housing)
	for exhibit in Housing.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Housing.without(exhibit_id), Housing)
		print("housing without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "housing %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Housing.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "housing %s removal did not admit a timeline it forbids" % exhibit_id)

func _test_housing_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	var square_miss := {"who": "Maren", "place": "square", "hour": "76"}
	_expect(Housing.conflicting_ids(square_miss).size() == 9, "Maren / square / 76 contradicts %d exhibits" % Housing.conflicting_ids(square_miss).size())
	for who in Housing.PEOPLE:
		for place in Housing.PLACES:
			for hour in Housing.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == HOUSING_TRUE["who"] and place == HOUSING_TRUE["place"] and hour == HOUSING_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Housing)
					print("housing true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true housing theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "housing acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(HOUSING_TIMELINE) >= 0, "housing acceptance should give the timeline")
					_expect(str(result["message"]).find("Ewan") >= 0, "housing acceptance omits Ewan")
					_expect(str(result["message"]).find("saw") >= 0, "housing acceptance omits the saw")
					_expect(str(result["message"]).find("78") >= 0, "housing acceptance omits 78")
					_expect(str(result["message"]).find("so the bead would take the trench") >= 0, "housing acceptance omits the trench")
					_expect(str(result["message"]).find("Ewan (saw hand) cut the housing in the saw at 78") >= 0, "housing acceptance omits the cutting")
					_expect(Housing.conflicting_ids(theory).is_empty(), "true housing theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Housing)
					_expect(Housing.conflicting_ids(theory).size() >= 2, "%s / %s / %s contradicts fewer than two exhibits" % [who, place, hour])
					rejected += 1
	for outsider in ["Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal", "Nell"]:
		_expect_rejected({"who": outsider, "place": "saw", "hour": "78"}, Housing)
	print("housing theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d housing theories" % accepted)
	_expect(rejected >= 2, "rejected %d housing theories" % rejected)

func _test_housing_near_misses() -> void:
	var misses := [
		{"who": "Ewan", "place": "saw", "hour": "79", "titles": ["Mark leaf", "Trench note", "Hang order"]},
		{"who": "Ewan", "place": "saw", "hour": "77", "titles": ["Mark leaf", "Trench note", "Hang order"]},
		{"who": "Ewan", "place": "square", "hour": "78", "titles": ["Trench slate", "Stock card", "Chalk slip"]},
		{"who": "Maren", "place": "saw", "hour": "78", "titles": ["Saw chit", "Square sight", "Fillet hook"]},
	]
	var wrong_hour_in_saw := 0
	var wrong_place_at_hour := 0
	var wrong_person_in_saw := 0
	for theory in misses:
		_expect_rejected(theory, Housing)
		var result: Dictionary = Verdict.submit(theory, Housing)
		var message := str(result["message"])
		_expect(Housing.conflicting_ids(theory).size() == 3, "near-miss should name three exhibits: %s" % message)
		var named_at := -1
		for title in theory["titles"]:
			var at := message.find(str(title))
			_expect(at >= 0, "near-miss omits %s: %s" % [title, message])
			_expect(at > named_at, "near-miss names %s out of paper order: %s" % [title, message])
			named_at = at
		if str(theory["who"]) == "Ewan" and str(theory["place"]) == "saw" and str(theory["hour"]) != "78":
			wrong_hour_in_saw += 1
		if str(theory["who"]) == "Ewan" and str(theory["place"]) != "saw" and str(theory["hour"]) == "78":
			wrong_place_at_hour += 1
		if str(theory["who"]) != "Ewan" and str(theory["place"]) == "saw" and str(theory["hour"]) == "78":
			wrong_person_in_saw += 1
	print("housing near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four housing near-misses, found %d" % misses.size())
	_expect(wrong_hour_in_saw == 2, "two near-misses should keep Ewan in the saw at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Ewan at 78 in another room")
	_expect(wrong_person_in_saw >= 1, "a near-miss should keep the saw at 78 for another person")

func _test_housing_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
		"who stopped the night bell",
		"where they stopped the bell",
		"at which hour they stopped the bell",
		"who scored the salt mark",
		"where they scored the mark",
		"at which hour they scored the mark",
		"who trimmed the wick",
		"where they trimmed the wick",
		"at which hour they trimmed the wick",
		"who annealed the gather",
		"where they annealed the gather",
		"at which hour they annealed the gather",
		"who grafted the scion",
		"where they grafted the scion",
		"at which hour they grafted the scion",
		"who dipped the skein",
		"where they dipped the skein",
		"at which hour they dipped the skein",
		"who tarred the rope",
		"where they tarred the rope",
		"at which hour they tarred the rope",
		"who pressed the cork",
		"where they pressed the cork",
		"at which hour they pressed the cork",
		"who mended the net",
		"where they mended the net",
		"at which hour they mended the net",
		"who drove the hoop",
		"where they drove the hoop",
		"at which hour they drove the hoop",
		"who folded the linen",
		"where they folded the linen",
		"at which hour they folded the linen",
		"who cut the dovetail",
		"where they cut the dovetail",
		"at which hour they cut the dovetail",
		"who cut the mortise",
		"where they cut the mortise",
		"at which hour they cut the mortise",
		"who cut the rebate",
		"where they cut the rebate",
		"at which hour they cut the rebate",
	]
	var cases := [
		{"theory": {"who": "", "place": "saw", "hour": "78"}, "present": ["who cut the housing"], "absent": ["where they cut the housing", "at which hour they cut the housing"]},
		{"theory": {"who": "Ewan", "place": "", "hour": "78"}, "present": ["where they cut the housing"], "absent": ["who cut the housing", "at which hour they cut the housing"]},
		{"theory": {"who": "Ewan", "place": "saw", "hour": ""}, "present": ["at which hour they cut the housing"], "absent": ["who cut the housing", "where they cut the housing"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who cut the housing", "where they cut the housing", "at which hour they cut the housing"], "absent": []},
		{"theory": {}, "present": ["who cut the housing", "where they cut the housing", "at which hour they cut the housing"], "absent": []},
		{"theory": {"who": "Hollin", "place": "", "hour": "80"}, "present": ["where they cut the housing"], "absent": ["who cut the housing", "at which hour they cut the housing"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Housing)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "housing incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "housing incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "housing incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "housing incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "housing incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "housing missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "housing named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "housing incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("housing incomplete submissions refused with the missing slot")


func _test_tenon_file_shape() -> void:
	_expect(Tenon.EXHIBITS.size() == 9, "tenon exhibit count is %d" % Tenon.EXHIBITS.size())
	_expect(Tenon.PEOPLE.size() == 3, "tenon cast should be three people")
	_expect(Tenon.PLACES.size() == 3, "tenon room count is %d" % Tenon.PLACES.size())
	_expect(Tenon.HOURS.size() == 5, "tenon hour list length is %d" % Tenon.HOURS.size())
	_expect(Tenon.PEOPLE == ["Harl", "Neve", "Luth"], "tenon cast is %s" % str(Tenon.PEOPLE))
	_expect(Tenon.PLACES == ["gouge", "rasp", "bevel"], "tenon rooms are %s" % str(Tenon.PLACES))
	_expect(Tenon.HOURS == ["81", "82", "83", "84", "85"], "tenon hours are %s" % str(Tenon.HOURS))
	_expect(Tenon.AIMS == ["take_haunch", "spare_haunch", "set_haunch"], "tenon aims are %s" % str(Tenon.AIMS))
	_expect(Tenon.aim_phrase("take_haunch") == "so the bevel would take the haunch", "tenon aim phrase")
	_expect(Tenon.aim_phrase("spare_haunch") == "to spare the haunch still waiting on the bevel", "tenon spare aim")
	_expect(Tenon.aim_phrase("set_haunch") == "to set the haunch before the gouge was hung", "tenon set aim")
	_expect(Tenon.TITLE == "The tenon", "tenon title")
	_expect(Tenon.BLURB == "The tenon left its peg at the joiner's bench. Name who cut the tenon, the room they cut it in, and the hour.", "tenon blurb")
	_expect(Tenon.FILE_CODE == "CW-28", "tenon file code")
	_expect(Tenon.fields() == ["taker", "place", "hour", "nicker", "nick_room", "nick_hour", "seen_from", "guide", "aim", "guide_room", "dowel_room", "hone_hour", "wipe_hour", "hang_hour"], "tenon fields are %s" % str(Tenon.fields()))
	_expect(Tenon.PLAYER_FIELDS == ["taker", "place", "hour"], "tenon player fields")
	_expect(Tenon.HOURS[Tenon.HOURS.size() / 2] == TENON_TRUE["hour"], "tenon cutting should be the middle hour")
	_expect(Tenon.HOURS[0] != TENON_TRUE["hour"], "tenon cutting should not be the earliest hour")
	_expect(Tenon.HOURS[Tenon.HOURS.size() - 1] != TENON_TRUE["hour"], "tenon cutting should not be the latest hour")
	var counts := _player_pin_counts(Tenon)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "tenon pin counts are %s" % str(counts))
	var loose_pin: Array = [
		[CaseData, "spare key"],
		[Rehearsal, "rehearsal score"],
		[Gilt, "gilt stamp"],
		[Ferry, "ferry bell"],
		[Weather, "weather slate"],
		[Loom, "loom shuttle"],
		[Hive, "hive smoker"],
		[Glass, "glass pontil"],
		[Press, "press proof"],
		[Assay, "assay cup"],
	]
	var rhythm: Array = [
		[Kiln, "kiln chalk"],
		[Tide, "tide ledger"],
		[Night, "night bell"],
		[Salt, "salt mark"],
		[Wick, "wick trim"],
		[Anneal, "glass anneal"],
		[Graft, "orchard graft"],
		[Dye, "dye vat"],
		[Tar, "tar kettle"],
		[Cork, "cork press"],
		[Net, "net loft"],
		[Cask, "cask hoop"],
		[Linen, "linen fold"],
		[Dovetail, "dovetail"],
		[Mortise, "mortise"],
		[Rebate, "rebate"],
		[Housing, "housing"],
	]
	for row in loose_pin:
		_expect(counts != _player_pin_counts(row[0]), "tenon copied the %s pin pattern" % row[1])
	for row in rhythm:
		_expect(counts == _player_pin_counts(row[0]), "tenon should keep the %s pin rhythm" % row[1])
	var earlier: Array = []
	earlier.append_array(loose_pin)
	earlier.append_array(rhythm)
	for row in earlier:
		var book = row[0]
		var name := str(row[1])
		_expect(Tenon.TITLE != book.TITLE, "tenon shares a title with the %s" % name)
		_expect(Tenon.FILE_CODE != book.FILE_CODE, "tenon shares a file code with the %s" % name)
		_expect(_field_key(Tenon) != _field_key(book), "tenon copied the %s timeline fields" % name)
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	var earlier_texts := {}
	var earlier_sentences := {}
	for row in earlier:
		for old_exhibit in row[0].EXHIBITS:
			var old_text := str(old_exhibit["text"])
			earlier_texts[old_text] = true
			for old_sentence in old_text.split(". "):
				earlier_sentences[old_sentence.trim_suffix(".").strip_edges()] = true
	var exhibit_titles: Array[String] = []
	var exhibit_sources: Array[String] = []
	for exhibit in Tenon.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		exhibit_titles.append(str(exhibit["title"]))
		exhibit_sources.append(str(exhibit["source"]))
		_expect(not seen.has(exhibit_id), "duplicate tenon id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		_expect(not earlier_texts.has(str(exhibit["text"])), "tenon copied an earlier exhibit")
		for sentence in str(exhibit["text"]).split(". "):
			var cleaned := sentence.trim_suffix(".").strip_edges()
			_expect(not earlier_sentences.has(cleaned), "tenon copied an earlier sentence: %s" % cleaned)
		for banned in ["housing", "saw", "square", "bead", "trench", "fillet", "stock", "chalk", "ewan", "maren", "hollin", "mortise", "chisel", "awl", "brace", "wedge", "bored", "ragged", "racked", "dovetail", "vise", "stile", "apron", "clamp", "peg", "joint", "linen", "fold", "shears", "roller", "hem", "sheet", "crease", "press", "loft", "bench", "bottle", "cork", "shop", "drawer", "seal", "screw", "cellar", "wax", "neck", "plug", "dye", "vat", "indigo", "skein", "rope", "walk", "kettle", "winch", "pitch", "mesh", "rail", "crank", "needle", "twine", "cooperage", "cask", "hoop", "croze", "stave", "rebate", "plane", "gauge", "mallet", "shoulder", "scribe", "shim", "fence", "tansy", "solt", "quern"]:
			_expect(str(exhibit["text"]).find(banned) == -1, "%s copies %s" % [exhibit_id, banned])
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Tenon.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Tenon.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Tenon.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Tenon.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "tenon should have two slips with two hidden facts, found %d" % paired_hidden)
	_expect(exhibit_titles == ["Gouge chit", "Rasp sight", "Dowel hook", "Haunch slate", "Guide card", "Hone slip", "Nick leaf", "Haunch note", "Hang order"], "tenon exhibit titles are %s" % str(exhibit_titles))
	_expect(exhibit_sources == ["Neve, rasp hand", "Rasp rail", "Bevel peg", "Gouge jaw", "Luth, bevel clerk", "Rasp book", "Nick book", "Joiner's bench", "Bevel slate"], "tenon sources are %s" % str(exhibit_sources))
	for hour in Tenon.HOURS:
		_expect(stated.has(hour), "tenon hour %s is absent from the exhibits" % hour)

func _test_tenon_unique_model() -> void:
	var models := Solver.enumerate(Tenon.EXHIBITS, Tenon)
	print("tenon models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one tenon model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Harl", "tenon taker")
	_expect(str(model["place"]) == "gouge", "tenon place")
	_expect(str(model["hour"]) == "83", "tenon hour")
	_expect(str(model["nicker"]) == "Neve", "tenon nicker")
	_expect(str(model["nick_room"]) == "bevel", "tenon nick room")
	_expect(str(model["nick_hour"]) == "82", "tenon nick hour")
	_expect(str(model["seen_from"]) == "rasp", "tenon seen from")
	_expect(str(model["guide"]) == "Luth", "tenon guide")
	_expect(str(model["aim"]) == "take_haunch", "tenon aim")
	_expect(str(model["guide_room"]) == "rasp", "tenon guide room")
	_expect(str(model["dowel_room"]) == "bevel", "tenon dowel room")
	_expect(str(model["hone_hour"]) == "81", "tenon hone hour")
	_expect(str(model["wipe_hour"]) == "84", "tenon wipe hour")
	_expect(str(model["hang_hour"]) == "85", "tenon hang hour")
	for hour in Tenon.HOURS:
		var used := false
		for field in Tenon.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "tenon hour %s is blank in the true timeline" % hour)
	for place in Tenon.PLACES:
		var place_used := false
		for field in Tenon.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "tenon room %s is blank in the true timeline" % place)
	for person in Tenon.PEOPLE:
		var person_used := false
		for field in Tenon.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "tenon person %s is blank in the true timeline" % person)
	_expect(Tenon.timeline(model) == TENON_TIMELINE, "tenon timeline drifted:\n%s" % Tenon.timeline(model))
	for exhibit in Tenon.EXHIBITS:
		_expect(Tenon.holds(exhibit, model), "%s rejects the tenon timeline" % exhibit["id"])

func _test_tenon_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Tenon.EXHIBITS, Tenon)
	for exhibit in Tenon.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Tenon.without(exhibit_id), Tenon)
		print("tenon without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "tenon %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Tenon.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "tenon %s removal did not admit a timeline it forbids" % exhibit_id)

func _test_tenon_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	var bevel_miss := {"who": "Neve", "place": "rasp", "hour": "81"}
	_expect(Tenon.conflicting_ids(bevel_miss).size() == 9, "Neve / rasp / 81 contradicts %d exhibits" % Tenon.conflicting_ids(bevel_miss).size())
	for who in Tenon.PEOPLE:
		for place in Tenon.PLACES:
			for hour in Tenon.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == TENON_TRUE["who"] and place == TENON_TRUE["place"] and hour == TENON_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Tenon)
					print("tenon true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true tenon theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "tenon acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(TENON_TIMELINE) >= 0, "tenon acceptance should give the timeline")
					_expect(str(result["message"]).find("Harl") >= 0, "tenon acceptance omits Harl")
					_expect(str(result["message"]).find("gouge") >= 0, "tenon acceptance omits the gouge")
					_expect(str(result["message"]).find("83") >= 0, "tenon acceptance omits 83")
					_expect(str(result["message"]).find("so the bevel would take the haunch") >= 0, "tenon acceptance omits the haunch")
					_expect(str(result["message"]).find("Harl (gouge hand) cut the tenon in the gouge at 83") >= 0, "tenon acceptance omits the cutting")
					_expect(Tenon.conflicting_ids(theory).is_empty(), "true tenon theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Tenon)
					_expect(Tenon.conflicting_ids(theory).size() >= 2, "%s / %s / %s contradicts fewer than two exhibits" % [who, place, hour])
					rejected += 1
	for outsider in ["Ewan", "Maren", "Hollin", "Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal", "Nell"]:
		_expect_rejected({"who": outsider, "place": "gouge", "hour": "83"}, Tenon)
	print("tenon theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d tenon theories" % accepted)
	_expect(rejected >= 2, "rejected %d tenon theories" % rejected)

func _test_tenon_near_misses() -> void:
	var misses := [
		{"who": "Harl", "place": "gouge", "hour": "84", "titles": ["Nick leaf", "Haunch note", "Hang order"]},
		{"who": "Harl", "place": "gouge", "hour": "82", "titles": ["Nick leaf", "Haunch note", "Hang order"]},
		{"who": "Harl", "place": "rasp", "hour": "83", "titles": ["Haunch slate", "Guide card", "Hone slip"]},
		{"who": "Neve", "place": "gouge", "hour": "83", "titles": ["Gouge chit", "Rasp sight", "Dowel hook"]},
	]
	var wrong_hour_in_gouge := 0
	var wrong_place_at_hour := 0
	var wrong_person_in_gouge := 0
	for theory in misses:
		_expect_rejected(theory, Tenon)
		var result: Dictionary = Verdict.submit(theory, Tenon)
		var message := str(result["message"])
		_expect(Tenon.conflicting_ids(theory).size() >= 2, "near-miss should contradict at least two exhibits: %s" % message)
		_expect(Tenon.conflicting_ids(theory).size() == 3, "near-miss should name three exhibits: %s" % message)
		var named_at := -1
		for title in theory["titles"]:
			var at := message.find(str(title))
			_expect(at >= 0, "near-miss omits %s: %s" % [title, message])
			_expect(at > named_at, "near-miss names %s out of paper order: %s" % [title, message])
			named_at = at
		if str(theory["who"]) == "Harl" and str(theory["place"]) == "gouge" and str(theory["hour"]) != "83":
			wrong_hour_in_gouge += 1
		if str(theory["who"]) == "Harl" and str(theory["place"]) != "gouge" and str(theory["hour"]) == "83":
			wrong_place_at_hour += 1
		if str(theory["who"]) != "Harl" and str(theory["place"]) == "gouge" and str(theory["hour"]) == "83":
			wrong_person_in_gouge += 1
	print("tenon near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four tenon near-misses, found %d" % misses.size())
	_expect(wrong_hour_in_gouge == 2, "two near-misses should keep Harl in the gouge at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Harl at 83 in another room")
	_expect(wrong_person_in_gouge >= 1, "a near-miss should keep the gouge at 83 for another person")

func _test_tenon_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
		"who stopped the night bell",
		"where they stopped the bell",
		"at which hour they stopped the bell",
		"who scored the salt mark",
		"where they scored the mark",
		"at which hour they scored the mark",
		"who trimmed the wick",
		"where they trimmed the wick",
		"at which hour they trimmed the wick",
		"who annealed the gather",
		"where they annealed the gather",
		"at which hour they annealed the gather",
		"who grafted the scion",
		"where they grafted the scion",
		"at which hour they grafted the scion",
		"who dipped the skein",
		"where they dipped the skein",
		"at which hour they dipped the skein",
		"who tarred the rope",
		"where they tarred the rope",
		"at which hour they tarred the rope",
		"who pressed the cork",
		"where they pressed the cork",
		"at which hour they pressed the cork",
		"who mended the net",
		"where they mended the net",
		"at which hour they mended the net",
		"who drove the hoop",
		"where they drove the hoop",
		"at which hour they drove the hoop",
		"who folded the linen",
		"where they folded the linen",
		"at which hour they folded the linen",
		"who cut the dovetail",
		"where they cut the dovetail",
		"at which hour they cut the dovetail",
		"who cut the mortise",
		"where they cut the mortise",
		"at which hour they cut the mortise",
		"who cut the rebate",
		"where they cut the rebate",
		"at which hour they cut the rebate",
		"who cut the housing",
		"where they cut the housing",
		"at which hour they cut the housing",
	]
	var cases := [
		{"theory": {"who": "", "place": "gouge", "hour": "83"}, "present": ["who cut the tenon"], "absent": ["where they cut the tenon", "at which hour they cut the tenon"]},
		{"theory": {"who": "Harl", "place": "", "hour": "83"}, "present": ["where they cut the tenon"], "absent": ["who cut the tenon", "at which hour they cut the tenon"]},
		{"theory": {"who": "Harl", "place": "gouge", "hour": ""}, "present": ["at which hour they cut the tenon"], "absent": ["who cut the tenon", "where they cut the tenon"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who cut the tenon", "where they cut the tenon", "at which hour they cut the tenon"], "absent": []},
		{"theory": {}, "present": ["who cut the tenon", "where they cut the tenon", "at which hour they cut the tenon"], "absent": []},
		{"theory": {"who": "Luth", "place": "", "hour": "85"}, "present": ["where they cut the tenon"], "absent": ["who cut the tenon", "at which hour they cut the tenon"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Tenon)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "tenon incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "tenon incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "tenon incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "tenon incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "tenon incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "tenon missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "tenon named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "tenon incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("tenon incomplete submissions refused with the missing slot")


func _test_bridle_file_shape() -> void:
	_expect(Bridle.EXHIBITS.size() == 9, "bridle exhibit count is %d" % Bridle.EXHIBITS.size())
	_expect(Bridle.PEOPLE.size() == 3, "bridle cast should be three people")
	_expect(Bridle.PLACES.size() == 3, "bridle room count is %d" % Bridle.PLACES.size())
	_expect(Bridle.HOURS.size() == 5, "bridle hour list length is %d" % Bridle.HOURS.size())
	_expect(Bridle.PEOPLE == ["Wend", "Sile", "Jute"], "bridle cast is %s" % str(Bridle.PEOPLE))
	_expect(Bridle.PLACES == ["router", "scraper", "adze"], "bridle rooms are %s" % str(Bridle.PLACES))
	_expect(Bridle.HOURS == ["86", "87", "88", "89", "90"], "bridle hours are %s" % str(Bridle.HOURS))
	_expect(Bridle.AIMS == ["take_tongue", "spare_tongue", "set_tongue"], "bridle aims are %s" % str(Bridle.AIMS))
	_expect(Bridle.aim_phrase("take_tongue") == "so the adze would take the tongue", "bridle aim phrase")
	_expect(Bridle.aim_phrase("spare_tongue") == "to spare the tongue still waiting on the adze", "bridle spare aim")
	_expect(Bridle.aim_phrase("set_tongue") == "to set the tongue before the router was hung", "bridle set aim")
	_expect(Bridle.TITLE == "The bridle", "bridle title")
	_expect(Bridle.BLURB == "The bridle left its peg at the joiner's stool. Name who cut the bridle, the room they cut it in, and the hour.", "bridle blurb")
	_expect(Bridle.FILE_CODE == "CW-29", "bridle file code")
	_expect(Bridle.fields() == ["taker", "place", "hour", "notcher", "notch_room", "notch_hour", "seen_from", "templet", "aim", "templet_room", "spline_room", "strop_hour", "wipe_hour", "hang_hour"], "bridle fields are %s" % str(Bridle.fields()))
	_expect(Bridle.PLAYER_FIELDS == ["taker", "place", "hour"], "bridle player fields")
	_expect(Bridle.HOURS[Bridle.HOURS.size() / 2] == BRIDLE_TRUE["hour"], "bridle cutting should be the middle hour")
	_expect(Bridle.HOURS[0] != BRIDLE_TRUE["hour"], "bridle cutting should not be the earliest hour")
	_expect(Bridle.HOURS[Bridle.HOURS.size() - 1] != BRIDLE_TRUE["hour"], "bridle cutting should not be the latest hour")
	var counts := _player_pin_counts(Bridle)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "bridle pin counts are %s" % str(counts))
	var loose_pin: Array = [
		[CaseData, "spare key"],
		[Rehearsal, "rehearsal score"],
		[Gilt, "gilt stamp"],
		[Ferry, "ferry bell"],
		[Weather, "weather slate"],
		[Loom, "loom shuttle"],
		[Hive, "hive smoker"],
		[Glass, "glass pontil"],
		[Press, "press proof"],
		[Assay, "assay cup"],
	]
	var rhythm: Array = [
		[Kiln, "kiln chalk"],
		[Tide, "tide ledger"],
		[Night, "night bell"],
		[Salt, "salt mark"],
		[Wick, "wick trim"],
		[Anneal, "glass anneal"],
		[Graft, "orchard graft"],
		[Dye, "dye vat"],
		[Tar, "tar kettle"],
		[Cork, "cork press"],
		[Net, "net loft"],
		[Cask, "cask hoop"],
		[Linen, "linen fold"],
		[Dovetail, "dovetail"],
		[Mortise, "mortise"],
		[Rebate, "rebate"],
		[Housing, "housing"],
		[Tenon, "tenon"],
	]
	for row in loose_pin:
		_expect(counts != _player_pin_counts(row[0]), "bridle copied the %s pin pattern" % row[1])
	for row in rhythm:
		_expect(counts == _player_pin_counts(row[0]), "bridle should keep the %s pin rhythm" % row[1])
	var earlier: Array = []
	earlier.append_array(loose_pin)
	earlier.append_array(rhythm)
	for row in earlier:
		var book = row[0]
		var name := str(row[1])
		_expect(Bridle.TITLE != book.TITLE, "bridle shares a title with the %s" % name)
		_expect(Bridle.FILE_CODE != book.FILE_CODE, "bridle shares a file code with the %s" % name)
		_expect(_field_key(Bridle) != _field_key(book), "bridle copied the %s timeline fields" % name)
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	var earlier_texts := {}
	var earlier_sentences := {}
	for row in earlier:
		for old_exhibit in row[0].EXHIBITS:
			var old_text := str(old_exhibit["text"])
			earlier_texts[old_text] = true
			for old_sentence in old_text.split(". "):
				earlier_sentences[old_sentence.trim_suffix(".").strip_edges()] = true
	var exhibit_titles: Array[String] = []
	var exhibit_sources: Array[String] = []
	for exhibit in Bridle.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		exhibit_titles.append(str(exhibit["title"]))
		exhibit_sources.append(str(exhibit["source"]))
		_expect(not seen.has(exhibit_id), "duplicate bridle id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		_expect(not earlier_texts.has(str(exhibit["text"])), "bridle copied an earlier exhibit")
		for sentence in str(exhibit["text"]).split(". "):
			var cleaned := sentence.trim_suffix(".").strip_edges()
			_expect(not earlier_sentences.has(cleaned), "bridle copied an earlier sentence: %s" % cleaned)
		for banned in ["tenon", "gouge", "rasp", "bevel", "haunch", "dowel", "hone", "guide", "harl", "neve", "luth", "nick", "housing", "saw", "square", "bead", "trench", "fillet", "stock", "chalk", "ewan", "maren", "hollin", "mortise", "chisel", "awl", "brace", "wedge", "bored", "ragged", "racked", "dovetail", "vise", "stile", "apron", "clamp", "peg", "joint", "linen", "fold", "shears", "roller", "hem", "sheet", "crease", "press", "loft", "bench", "bottle", "cork", "shop", "drawer", "seal", "screw", "cellar", "wax", "neck", "plug", "dye", "vat", "indigo", "skein", "rope", "walk", "kettle", "winch", "pitch", "mesh", "rail", "crank", "needle", "twine", "cooperage", "cask", "hoop", "croze", "stave", "rebate", "plane", "gauge", "mallet", "shoulder", "scribe", "shim", "fence", "tansy", "solt", "quern"]:
			_expect(str(exhibit["text"]).find(banned) == -1, "%s copies %s" % [exhibit_id, banned])
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Bridle.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Bridle.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Bridle.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Bridle.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "bridle should have two slips with two hidden facts, found %d" % paired_hidden)
	_expect(exhibit_titles == ["Router chit", "Scraper sight", "Spline hook", "Tongue slate", "Templet card", "Strop slip", "Notch leaf", "Tongue note", "Hang order"], "bridle exhibit titles are %s" % str(exhibit_titles))
	_expect(exhibit_sources == ["Sile, scraper hand", "Scraper rail", "Adze peg", "Router jaw", "Jute, adze clerk", "Scraper book", "Notch book", "Joiner's stool", "Adze slate"], "bridle sources are %s" % str(exhibit_sources))
	for hour in Bridle.HOURS:
		_expect(stated.has(hour), "bridle hour %s is absent from the exhibits" % hour)


func _test_bridle_unique_model() -> void:
	var models := Solver.enumerate(Bridle.EXHIBITS, Bridle)
	print("bridle models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one bridle model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Wend", "bridle taker")
	_expect(str(model["place"]) == "router", "bridle place")
	_expect(str(model["hour"]) == "88", "bridle hour")
	_expect(str(model["notcher"]) == "Sile", "bridle notcher")
	_expect(str(model["notch_room"]) == "adze", "bridle notch room")
	_expect(str(model["notch_hour"]) == "87", "bridle notch hour")
	_expect(str(model["seen_from"]) == "scraper", "bridle seen from")
	_expect(str(model["templet"]) == "Jute", "bridle templet")
	_expect(str(model["aim"]) == "take_tongue", "bridle aim")
	_expect(str(model["templet_room"]) == "scraper", "bridle templet room")
	_expect(str(model["spline_room"]) == "adze", "bridle spline room")
	_expect(str(model["strop_hour"]) == "86", "bridle strop hour")
	_expect(str(model["wipe_hour"]) == "89", "bridle wipe hour")
	_expect(str(model["hang_hour"]) == "90", "bridle hang hour")
	for hour in Bridle.HOURS:
		var used := false
		for field in Bridle.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "bridle hour %s is blank in the true timeline" % hour)
	for place in Bridle.PLACES:
		var place_used := false
		for field in Bridle.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "bridle room %s is blank in the true timeline" % place)
	for person in Bridle.PEOPLE:
		var person_used := false
		for field in Bridle.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "bridle person %s is blank in the true timeline" % person)
	_expect(Bridle.timeline(model) == BRIDLE_TIMELINE, "bridle timeline drifted:\n%s" % Bridle.timeline(model))
	for exhibit in Bridle.EXHIBITS:
		_expect(Bridle.holds(exhibit, model), "%s rejects the bridle timeline" % exhibit["id"])


func _test_bridle_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Bridle.EXHIBITS, Bridle)
	for exhibit in Bridle.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Bridle.without(exhibit_id), Bridle)
		print("bridle without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "bridle %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Bridle.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "bridle %s removal did not admit a timeline it forbids" % exhibit_id)


func _test_bridle_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	var scraper_miss := {"who": "Sile", "place": "scraper", "hour": "86"}
	_expect(Bridle.conflicting_ids(scraper_miss).size() == 9, "Sile / scraper / 86 contradicts %d exhibits" % Bridle.conflicting_ids(scraper_miss).size())
	for who in Bridle.PEOPLE:
		for place in Bridle.PLACES:
			for hour in Bridle.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == BRIDLE_TRUE["who"] and place == BRIDLE_TRUE["place"] and hour == BRIDLE_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Bridle)
					print("bridle true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true bridle theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "bridle acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(BRIDLE_TIMELINE) >= 0, "bridle acceptance should give the timeline")
					_expect(str(result["message"]).find("Wend") >= 0, "bridle acceptance omits Wend")
					_expect(str(result["message"]).find("router") >= 0, "bridle acceptance omits the router")
					_expect(str(result["message"]).find("88") >= 0, "bridle acceptance omits 88")
					_expect(str(result["message"]).find("so the adze would take the tongue") >= 0, "bridle acceptance omits the tongue")
					_expect(str(result["message"]).find("Wend (router hand) cut the bridle in the router at 88") >= 0, "bridle acceptance omits the cutting")
					_expect(Bridle.conflicting_ids(theory).is_empty(), "true bridle theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Bridle)
					_expect(Bridle.conflicting_ids(theory).size() >= 2, "%s / %s / %s contradicts fewer than two exhibits" % [who, place, hour])
					rejected += 1
	for outsider in ["Harl", "Neve", "Luth", "Ewan", "Maren", "Hollin", "Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal", "Nell"]:
		_expect_rejected({"who": outsider, "place": "router", "hour": "88"}, Bridle)
	print("bridle theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d bridle theories" % accepted)
	_expect(rejected >= 2, "rejected %d bridle theories" % rejected)


func _test_bridle_near_misses() -> void:
	var misses := [
		{"who": "Wend", "place": "router", "hour": "89", "titles": ["Notch leaf", "Tongue note", "Hang order"]},
		{"who": "Wend", "place": "router", "hour": "87", "titles": ["Notch leaf", "Tongue note", "Hang order"]},
		{"who": "Wend", "place": "scraper", "hour": "88", "titles": ["Tongue slate", "Templet card", "Strop slip"]},
		{"who": "Sile", "place": "router", "hour": "88", "titles": ["Router chit", "Scraper sight", "Spline hook"]},
	]
	var wrong_hour_in_router := 0
	var wrong_place_at_hour := 0
	var wrong_person_in_router := 0
	for theory in misses:
		_expect_rejected(theory, Bridle)
		var result: Dictionary = Verdict.submit(theory, Bridle)
		var message := str(result["message"])
		_expect(Bridle.conflicting_ids(theory).size() >= 2, "near-miss should contradict at least two exhibits: %s" % message)
		_expect(Bridle.conflicting_ids(theory).size() == 3, "near-miss should name three exhibits: %s" % message)
		var named_at := -1
		for title in theory["titles"]:
			var at := message.find(str(title))
			_expect(at >= 0, "near-miss omits %s: %s" % [title, message])
			_expect(at > named_at, "near-miss names %s out of paper order: %s" % [title, message])
			named_at = at
		if str(theory["who"]) == "Wend" and str(theory["place"]) == "router" and str(theory["hour"]) != "88":
			wrong_hour_in_router += 1
		if str(theory["who"]) == "Wend" and str(theory["place"]) != "router" and str(theory["hour"]) == "88":
			wrong_place_at_hour += 1
		if str(theory["who"]) != "Wend" and str(theory["place"]) == "router" and str(theory["hour"]) == "88":
			wrong_person_in_router += 1
	print("bridle near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four bridle near-misses, found %d" % misses.size())
	_expect(wrong_hour_in_router == 2, "two near-misses should keep Wend in the router at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Wend at 88 in another room")
	_expect(wrong_person_in_router >= 1, "a near-miss should keep the router at 88 for another person")


func _test_bridle_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
		"who stopped the night bell",
		"where they stopped the bell",
		"at which hour they stopped the bell",
		"who scored the salt mark",
		"where they scored the mark",
		"at which hour they scored the mark",
		"who trimmed the wick",
		"where they trimmed the wick",
		"at which hour they trimmed the wick",
		"who annealed the gather",
		"where they annealed the gather",
		"at which hour they annealed the gather",
		"who grafted the scion",
		"where they grafted the scion",
		"at which hour they grafted the scion",
		"who dipped the skein",
		"where they dipped the skein",
		"at which hour they dipped the skein",
		"who tarred the rope",
		"where they tarred the rope",
		"at which hour they tarred the rope",
		"who pressed the cork",
		"where they pressed the cork",
		"at which hour they pressed the cork",
		"who mended the net",
		"where they mended the net",
		"at which hour they mended the net",
		"who drove the hoop",
		"where they drove the hoop",
		"at which hour they drove the hoop",
		"who folded the linen",
		"where they folded the linen",
		"at which hour they folded the linen",
		"who cut the dovetail",
		"where they cut the dovetail",
		"at which hour they cut the dovetail",
		"who cut the mortise",
		"where they cut the mortise",
		"at which hour they cut the mortise",
		"who cut the rebate",
		"where they cut the rebate",
		"at which hour they cut the rebate",
		"who cut the housing",
		"where they cut the housing",
		"at which hour they cut the housing",
		"who cut the tenon",
		"where they cut the tenon",
		"at which hour they cut the tenon",
	]
	var cases := [
		{"theory": {"who": "", "place": "router", "hour": "88"}, "present": ["who cut the bridle"], "absent": ["where they cut the bridle", "at which hour they cut the bridle"]},
		{"theory": {"who": "Wend", "place": "", "hour": "88"}, "present": ["where they cut the bridle"], "absent": ["who cut the bridle", "at which hour they cut the bridle"]},
		{"theory": {"who": "Wend", "place": "router", "hour": ""}, "present": ["at which hour they cut the bridle"], "absent": ["who cut the bridle", "where they cut the bridle"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who cut the bridle", "where they cut the bridle", "at which hour they cut the bridle"], "absent": []},
		{"theory": {}, "present": ["who cut the bridle", "where they cut the bridle", "at which hour they cut the bridle"], "absent": []},
		{"theory": {"who": "Jute", "place": "", "hour": "90"}, "present": ["where they cut the bridle"], "absent": ["who cut the bridle", "at which hour they cut the bridle"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Bridle)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "bridle incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "bridle incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "bridle incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "bridle incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "bridle incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "bridle missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "bridle named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "bridle incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("bridle incomplete submissions refused with the missing slot")

func _test_dado_file_shape() -> void:
	_expect(Dado.EXHIBITS.size() == 9, "dado exhibit count is %d" % Dado.EXHIBITS.size())
	_expect(Dado.PEOPLE.size() == 3, "dado cast should be three people")
	_expect(Dado.PLACES.size() == 3, "dado room count is %d" % Dado.PLACES.size())
	_expect(Dado.HOURS.size() == 5, "dado hour list length is %d" % Dado.HOURS.size())
	_expect(Dado.PEOPLE == ["Kern", "Phel", "Tarn"], "dado cast is %s" % str(Dado.PEOPLE))
	_expect(Dado.PLACES == ["plough", "float", "gimlet"], "dado rooms are %s" % str(Dado.PLACES))
	_expect(Dado.HOURS == ["91", "92", "93", "94", "95"], "dado hours are %s" % str(Dado.HOURS))
	_expect(Dado.AIMS == ["take_groove", "spare_groove", "set_groove"], "dado aims are %s" % str(Dado.AIMS))
	_expect(Dado.aim_phrase("take_groove") == "so the gimlet would take the groove", "dado aim phrase")
	_expect(Dado.aim_phrase("spare_groove") == "to spare the groove still waiting on the gimlet", "dado spare aim")
	_expect(Dado.aim_phrase("set_groove") == "to set the groove before the plough was hung", "dado set aim")
	_expect(Dado.TITLE == "The dado", "dado title")
	_expect(Dado.BLURB == "The dado left its peg at the joiner's chest. Name who cut the dado, the room they cut it in, and the hour.", "dado blurb")
	_expect(Dado.FILE_CODE == "CW-30", "dado file code")
	_expect(Dado.fields() == ["taker", "place", "hour", "scorer", "score_room", "score_hour", "seen_from", "spur", "aim", "spur_room", "cleat_room", "whet_hour", "wipe_hour", "hang_hour"], "dado fields are %s" % str(Dado.fields()))
	_expect(Dado.PLAYER_FIELDS == ["taker", "place", "hour"], "dado player fields")
	_expect(Dado.HOURS[Dado.HOURS.size() / 2] == DADO_TRUE["hour"], "dado cutting should be the middle hour")
	_expect(Dado.HOURS[0] != DADO_TRUE["hour"], "dado cutting should not be the earliest hour")
	_expect(Dado.HOURS[Dado.HOURS.size() - 1] != DADO_TRUE["hour"], "dado cutting should not be the latest hour")
	var counts := _player_pin_counts(Dado)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "dado pin counts are %s" % str(counts))
	var loose_pin: Array = [
		[CaseData, "spare key"],
		[Rehearsal, "rehearsal score"],
		[Gilt, "gilt stamp"],
		[Ferry, "ferry bell"],
		[Weather, "weather slate"],
		[Loom, "loom shuttle"],
		[Hive, "hive smoker"],
		[Glass, "glass pontil"],
		[Press, "press proof"],
		[Assay, "assay cup"],
	]
	var rhythm: Array = [
		[Kiln, "kiln chalk"],
		[Tide, "tide ledger"],
		[Night, "night bell"],
		[Salt, "salt mark"],
		[Wick, "wick trim"],
		[Anneal, "glass anneal"],
		[Graft, "orchard graft"],
		[Dye, "dye vat"],
		[Tar, "tar kettle"],
		[Cork, "cork press"],
		[Net, "net loft"],
		[Cask, "cask hoop"],
		[Linen, "linen fold"],
		[Dovetail, "dovetail"],
		[Mortise, "mortise"],
		[Rebate, "rebate"],
		[Housing, "housing"],
		[Tenon, "tenon"],
		[Bridle, "bridle"],
	]
	for row in loose_pin:
		_expect(counts != _player_pin_counts(row[0]), "dado copied the %s pin pattern" % row[1])
	for row in rhythm:
		_expect(counts == _player_pin_counts(row[0]), "dado should keep the %s pin rhythm" % row[1])
	var earlier: Array = []
	earlier.append_array(loose_pin)
	earlier.append_array(rhythm)
	for row in earlier:
		var book = row[0]
		var name := str(row[1])
		_expect(Dado.TITLE != book.TITLE, "dado shares a title with the %s" % name)
		_expect(Dado.FILE_CODE != book.FILE_CODE, "dado shares a file code with the %s" % name)
		_expect(_field_key(Dado) != _field_key(book), "dado copied the %s timeline fields" % name)
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	var earlier_texts := {}
	var earlier_sentences := {}
	for row in earlier:
		for old_exhibit in row[0].EXHIBITS:
			var old_text := str(old_exhibit["text"])
			earlier_texts[old_text] = true
			for old_sentence in old_text.split(". "):
				earlier_sentences[old_sentence.trim_suffix(".").strip_edges()] = true
	var exhibit_titles: Array[String] = []
	var exhibit_sources: Array[String] = []
	for exhibit in Dado.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		exhibit_titles.append(str(exhibit["title"]))
		exhibit_sources.append(str(exhibit["source"]))
		_expect(not seen.has(exhibit_id), "duplicate dado id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		_expect(not earlier_texts.has(str(exhibit["text"])), "dado copied an earlier exhibit")
		for sentence in str(exhibit["text"]).split(". "):
			var cleaned := sentence.trim_suffix(".").strip_edges()
			_expect(not earlier_sentences.has(cleaned), "dado copied an earlier sentence: %s" % cleaned)
		for banned in ["tenon", "gouge", "rasp", "bevel", "haunch", "dowel", "hone", "guide", "harl", "neve", "luth", "nick", "housing", "saw", "square", "bead", "trench", "fillet", "stock", "chalk", "ewan", "maren", "hollin", "mortise", "chisel", "awl", "brace", "wedge", "bored", "ragged", "racked", "dovetail", "vise", "stile", "apron", "clamp", "peg", "joint", "linen", "fold", "shears", "roller", "hem", "sheet", "crease", "press", "loft", "bench", "bottle", "cork", "shop", "drawer", "seal", "screw", "cellar", "wax", "neck", "plug", "dye", "vat", "indigo", "skein", "rope", "walk", "kettle", "winch", "pitch", "mesh", "rail", "crank", "needle", "twine", "cooperage", "cask", "hoop", "croze", "stave", "rebate", "plane", "gauge", "mallet", "shoulder", "scribe", "shim", "fence", "tansy", "solt", "quern", "bridle", "router", "scraper", "adze", "tongue", "spline", "templet", "strop", "notch", "wend", "sile", "jute"]:
			_expect(str(exhibit["text"]).find(banned) == -1, "%s copies %s" % [exhibit_id, banned])
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Dado.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Dado.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Dado.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Dado.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "dado should have two slips with two hidden facts, found %d" % paired_hidden)
	_expect(exhibit_titles == ["Plough chit", "Float sight", "Cleat hook", "Groove slate", "Spur card", "Whet slip", "Score leaf", "Groove note", "Hang order"], "dado exhibit titles are %s" % str(exhibit_titles))
	_expect(exhibit_sources == ["Phel, float hand", "Float rail", "Gimlet peg", "Plough jaw", "Tarn, gimlet clerk", "Float book", "Score book", "Joiner's chest", "Gimlet slate"], "dado sources are %s" % str(exhibit_sources))
	for hour in Dado.HOURS:
		_expect(stated.has(hour), "dado hour %s is absent from the exhibits" % hour)


func _test_dado_unique_model() -> void:
	var models := Solver.enumerate(Dado.EXHIBITS, Dado)
	print("dado models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one dado model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Kern", "dado taker")
	_expect(str(model["place"]) == "plough", "dado place")
	_expect(str(model["hour"]) == "93", "dado hour")
	_expect(str(model["scorer"]) == "Phel", "dado scorer")
	_expect(str(model["score_room"]) == "gimlet", "dado score room")
	_expect(str(model["score_hour"]) == "92", "dado score hour")
	_expect(str(model["seen_from"]) == "float", "dado seen from")
	_expect(str(model["spur"]) == "Tarn", "dado spur")
	_expect(str(model["aim"]) == "take_groove", "dado aim")
	_expect(str(model["spur_room"]) == "float", "dado spur room")
	_expect(str(model["cleat_room"]) == "gimlet", "dado cleat room")
	_expect(str(model["whet_hour"]) == "91", "dado whet hour")
	_expect(str(model["wipe_hour"]) == "94", "dado wipe hour")
	_expect(str(model["hang_hour"]) == "95", "dado hang hour")
	for hour in Dado.HOURS:
		var used := false
		for field in Dado.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "dado hour %s is blank in the true timeline" % hour)
	for place in Dado.PLACES:
		var place_used := false
		for field in Dado.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "dado room %s is blank in the true timeline" % place)
	for person in Dado.PEOPLE:
		var person_used := false
		for field in Dado.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "dado person %s is blank in the true timeline" % person)
	_expect(Dado.timeline(model) == DADO_TIMELINE, "dado timeline drifted:\n%s" % Dado.timeline(model))
	for exhibit in Dado.EXHIBITS:
		_expect(Dado.holds(exhibit, model), "%s rejects the dado timeline" % exhibit["id"])


func _test_dado_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Dado.EXHIBITS, Dado)
	for exhibit in Dado.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Dado.without(exhibit_id), Dado)
		print("dado without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "dado %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Dado.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "dado %s removal did not admit a timeline it forbids" % exhibit_id)


func _test_dado_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	var float_miss := {"who": "Phel", "place": "float", "hour": "91"}
	_expect(Dado.conflicting_ids(float_miss).size() == 9, "Phel / float / 91 contradicts %d exhibits" % Dado.conflicting_ids(float_miss).size())
	for who in Dado.PEOPLE:
		for place in Dado.PLACES:
			for hour in Dado.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == DADO_TRUE["who"] and place == DADO_TRUE["place"] and hour == DADO_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Dado)
					print("dado true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true dado theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "dado acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(DADO_TIMELINE) >= 0, "dado acceptance should give the timeline")
					_expect(str(result["message"]).find("Kern") >= 0, "dado acceptance omits Kern")
					_expect(str(result["message"]).find("plough") >= 0, "dado acceptance omits the plough")
					_expect(str(result["message"]).find("93") >= 0, "dado acceptance omits 93")
					_expect(str(result["message"]).find("so the gimlet would take the groove") >= 0, "dado acceptance omits the groove")
					_expect(str(result["message"]).find("Kern (plough hand) cut the dado in the plough at 93") >= 0, "dado acceptance omits the cutting")
					_expect(Dado.conflicting_ids(theory).is_empty(), "true dado theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Dado)
					_expect(Dado.conflicting_ids(theory).size() >= 2, "%s / %s / %s contradicts fewer than two exhibits" % [who, place, hour])
					rejected += 1
	for outsider in ["Wend", "Sile", "Jute", "Harl", "Neve", "Luth", "Ewan", "Maren", "Hollin", "Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal", "Nell"]:
		_expect_rejected({"who": outsider, "place": "plough", "hour": "93"}, Dado)
	print("dado theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d dado theories" % accepted)
	_expect(rejected >= 2, "rejected %d dado theories" % rejected)


func _test_dado_near_misses() -> void:
	var misses := [
		{"who": "Kern", "place": "plough", "hour": "94", "titles": ["Score leaf", "Groove note", "Hang order"]},
		{"who": "Kern", "place": "plough", "hour": "92", "titles": ["Score leaf", "Groove note", "Hang order"]},
		{"who": "Kern", "place": "float", "hour": "93", "titles": ["Groove slate", "Spur card", "Whet slip"]},
		{"who": "Phel", "place": "plough", "hour": "93", "titles": ["Plough chit", "Float sight", "Cleat hook"]},
	]
	var wrong_hour_in_plough := 0
	var wrong_place_at_hour := 0
	var wrong_person_in_plough := 0
	for theory in misses:
		_expect_rejected(theory, Dado)
		var result: Dictionary = Verdict.submit(theory, Dado)
		var message := str(result["message"])
		_expect(Dado.conflicting_ids(theory).size() >= 2, "near-miss should contradict at least two exhibits: %s" % message)
		_expect(Dado.conflicting_ids(theory).size() == 3, "near-miss should name three exhibits: %s" % message)
		var named_at := -1
		for title in theory["titles"]:
			var at := message.find(str(title))
			_expect(at >= 0, "near-miss omits %s: %s" % [title, message])
			_expect(at > named_at, "near-miss names %s out of paper order: %s" % [title, message])
			named_at = at
		if str(theory["who"]) == "Kern" and str(theory["place"]) == "plough" and str(theory["hour"]) != "93":
			wrong_hour_in_plough += 1
		if str(theory["who"]) == "Kern" and str(theory["place"]) != "plough" and str(theory["hour"]) == "93":
			wrong_place_at_hour += 1
		if str(theory["who"]) != "Kern" and str(theory["place"]) == "plough" and str(theory["hour"]) == "93":
			wrong_person_in_plough += 1
	print("dado near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four dado near-misses, found %d" % misses.size())
	_expect(wrong_hour_in_plough == 2, "two near-misses should keep Kern in the plough at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Kern at 93 in another room")
	_expect(wrong_person_in_plough >= 1, "a near-miss should keep the plough at 93 for another person")


func _test_dado_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
		"who stopped the night bell",
		"where they stopped the bell",
		"at which hour they stopped the bell",
		"who scored the salt mark",
		"where they scored the mark",
		"at which hour they scored the mark",
		"who trimmed the wick",
		"where they trimmed the wick",
		"at which hour they trimmed the wick",
		"who annealed the gather",
		"where they annealed the gather",
		"at which hour they annealed the gather",
		"who grafted the scion",
		"where they grafted the scion",
		"at which hour they grafted the scion",
		"who dipped the skein",
		"where they dipped the skein",
		"at which hour they dipped the skein",
		"who tarred the rope",
		"where they tarred the rope",
		"at which hour they tarred the rope",
		"who pressed the cork",
		"where they pressed the cork",
		"at which hour they pressed the cork",
		"who mended the net",
		"where they mended the net",
		"at which hour they mended the net",
		"who drove the hoop",
		"where they drove the hoop",
		"at which hour they drove the hoop",
		"who folded the linen",
		"where they folded the linen",
		"at which hour they folded the linen",
		"who cut the dovetail",
		"where they cut the dovetail",
		"at which hour they cut the dovetail",
		"who cut the mortise",
		"where they cut the mortise",
		"at which hour they cut the mortise",
		"who cut the rebate",
		"where they cut the rebate",
		"at which hour they cut the rebate",
		"who cut the housing",
		"where they cut the housing",
		"at which hour they cut the housing",
		"who cut the tenon",
		"where they cut the tenon",
		"at which hour they cut the tenon",
		"who cut the bridle",
		"where they cut the bridle",
		"at which hour they cut the bridle",
	]
	var cases := [
		{"theory": {"who": "", "place": "plough", "hour": "93"}, "present": ["who cut the dado"], "absent": ["where they cut the dado", "at which hour they cut the dado"]},
		{"theory": {"who": "Kern", "place": "", "hour": "93"}, "present": ["where they cut the dado"], "absent": ["who cut the dado", "at which hour they cut the dado"]},
		{"theory": {"who": "Kern", "place": "plough", "hour": ""}, "present": ["at which hour they cut the dado"], "absent": ["who cut the dado", "where they cut the dado"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who cut the dado", "where they cut the dado", "at which hour they cut the dado"], "absent": []},
		{"theory": {}, "present": ["who cut the dado", "where they cut the dado", "at which hour they cut the dado"], "absent": []},
		{"theory": {"who": "Tarn", "place": "", "hour": "95"}, "present": ["where they cut the dado"], "absent": ["who cut the dado", "at which hour they cut the dado"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Dado)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "dado incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "dado incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "dado incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "dado incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "dado incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "dado missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "dado named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "dado incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("dado incomplete submissions refused with the missing slot")


func _test_spline_file_shape() -> void:
	_expect(Spline.EXHIBITS.size() == 9, "spline exhibit count is %d" % Spline.EXHIBITS.size())
	_expect(Spline.PEOPLE.size() == 3, "spline cast should be three people")
	_expect(Spline.PLACES.size() == 3, "spline room count is %d" % Spline.PLACES.size())
	_expect(Spline.HOURS.size() == 5, "spline hour list length is %d" % Spline.HOURS.size())
	_expect(Spline.PEOPLE == ["Senn", "Voss", "Cade"], "spline cast is %s" % str(Spline.PEOPLE))
	_expect(Spline.PLACES == ["plough", "float", "gimlet"], "spline rooms are %s" % str(Spline.PLACES))
	_expect(Spline.HOURS == ["96", "97", "98", "99", "100"], "spline hours are %s" % str(Spline.HOURS))
	_expect(Spline.AIMS == ["take_slot", "spare_slot", "set_slot"], "spline aims are %s" % str(Spline.AIMS))
	_expect(Spline.aim_phrase("take_slot") == "so the tongue would take the slot", "spline aim phrase")
	_expect(Spline.aim_phrase("spare_slot") == "to spare the slot still waiting on the tongue", "spline spare aim")
	_expect(Spline.aim_phrase("set_slot") == "to set the slot before the plough was hung", "spline set aim")
	_expect(Spline.TITLE == "The spline", "spline title")
	_expect(Spline.BLURB == "The spline left its peg at the joiner's vise. Name who cut the spline, the room they cut it in, and the hour.", "spline blurb")
	_expect(Spline.FILE_CODE == "CW-31", "spline file code")
	_expect(Spline.fields() == ["taker", "place", "hour", "slotter", "slot_room", "slot_hour", "seen_from", "key", "aim", "turn_room", "feather_room", "whet_hour", "wipe_hour", "hang_hour"], "spline fields are %s" % str(Spline.fields()))
	_expect(Spline.PLAYER_FIELDS == ["taker", "place", "hour"], "spline player fields")
	_expect(Spline.HOURS[Spline.HOURS.size() / 2] == SPLINE_TRUE["hour"], "spline cutting should be the middle hour")
	_expect(Spline.HOURS[0] != SPLINE_TRUE["hour"], "spline cutting should not be the earliest hour")
	_expect(Spline.HOURS[Spline.HOURS.size() - 1] != SPLINE_TRUE["hour"], "spline cutting should not be the latest hour")
	var counts := _player_pin_counts(Spline)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "spline pin counts are %s" % str(counts))
	var loose_pin: Array = [
		[CaseData, "spare key"],
		[Rehearsal, "rehearsal score"],
		[Gilt, "gilt stamp"],
		[Ferry, "ferry bell"],
		[Weather, "weather slate"],
		[Loom, "loom shuttle"],
		[Hive, "hive smoker"],
		[Glass, "glass pontil"],
		[Press, "press proof"],
		[Assay, "assay cup"],
	]
	var rhythm: Array = [
		[Kiln, "kiln chalk"],
		[Tide, "tide ledger"],
		[Night, "night bell"],
		[Salt, "salt mark"],
		[Wick, "wick trim"],
		[Anneal, "glass anneal"],
		[Graft, "orchard graft"],
		[Dye, "dye vat"],
		[Tar, "tar kettle"],
		[Cork, "cork press"],
		[Net, "net loft"],
		[Cask, "cask hoop"],
		[Linen, "linen fold"],
		[Dovetail, "dovetail"],
		[Mortise, "mortise"],
		[Rebate, "rebate"],
		[Housing, "housing"],
		[Tenon, "tenon"],
		[Bridle, "bridle"],
		[Dado, "dado"],
	]
	for row in loose_pin:
		_expect(counts != _player_pin_counts(row[0]), "spline copied the %s pin pattern" % row[1])
	for row in rhythm:
		_expect(counts == _player_pin_counts(row[0]), "spline should keep the %s pin rhythm" % row[1])
	var earlier: Array = []
	earlier.append_array(loose_pin)
	earlier.append_array(rhythm)
	for row in earlier:
		var book = row[0]
		var name := str(row[1])
		_expect(Spline.TITLE != book.TITLE, "spline shares a title with the %s" % name)
		_expect(Spline.FILE_CODE != book.FILE_CODE, "spline shares a file code with the %s" % name)
		_expect(_field_key(Spline) != _field_key(book), "spline copied the %s timeline fields" % name)
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	var earlier_texts := {}
	var earlier_sentences := {}
	for row in earlier:
		for old_exhibit in row[0].EXHIBITS:
			var old_text := str(old_exhibit["text"])
			earlier_texts[old_text] = true
			for old_sentence in old_text.split(". "):
				earlier_sentences[old_sentence.trim_suffix(".").strip_edges()] = true
	var exhibit_titles: Array[String] = []
	var exhibit_sources: Array[String] = []
	for exhibit in Spline.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		exhibit_titles.append(str(exhibit["title"]))
		exhibit_sources.append(str(exhibit["source"]))
		_expect(not seen.has(exhibit_id), "duplicate spline id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		_expect(not earlier_texts.has(str(exhibit["text"])), "spline copied an earlier exhibit")
		for sentence in str(exhibit["text"]).split(". "):
			var cleaned := sentence.trim_suffix(".").strip_edges()
			_expect(not earlier_sentences.has(cleaned), "spline copied an earlier sentence: %s" % cleaned)
		for banned in ["tenon", "gouge", "rasp", "bevel", "haunch", "dowel", "hone", "guide", "harl", "neve", "luth", "nick", "housing", "saw", "square", "bead", "trench", "fillet", "stock", "chalk", "ewan", "maren", "hollin", "mortise", "chisel", "awl", "brace", "wedge", "bored", "ragged", "racked", "dovetail", "vise", "stile", "apron", "clamp", "peg", "joint", "linen", "fold", "shears", "roller", "hem", "sheet", "crease", "press", "loft", "bench", "bottle", "cork", "shop", "drawer", "seal", "screw", "cellar", "wax", "neck", "plug", "dye", "vat", "indigo", "skein", "rope", "walk", "kettle", "winch", "pitch", "mesh", "rail", "crank", "needle", "twine", "cooperage", "cask", "hoop", "croze", "stave", "rebate", "plane", "gauge", "mallet", "shoulder", "scribe", "shim", "fence", "tansy", "solt", "quern", "bridle", "router", "scraper", "adze", "templet", "strop", "notch", "wend", "sile", "jute", "dado", "groove", "cleat", "spur", "kern", "phel", "tarn", "shavings", "mouth", "iron"]:
			_expect(str(exhibit["text"]).find(banned) == -1, "%s copies %s" % [exhibit_id, banned])
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Spline.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Spline.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Spline.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Spline.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "spline should have two slips with two hidden facts, found %d" % paired_hidden)
	_expect(exhibit_titles == ["Slot chit", "Rest sight", "Feather hook", "Slot slate", "Key card", "Cheek slip", "Slot leaf", "Slot note", "Dry order"], "spline exhibit titles are %s" % str(exhibit_titles))
	_expect(exhibit_sources == ["Voss, chest hand", "Float rest", "Gimlet nail", "Plough cheek", "Cade, horse clerk", "Float slate", "Slot book", "Joiner's vise", "Gimlet board"], "spline sources are %s" % str(exhibit_sources))
	for hour in Spline.HOURS:
		_expect(stated.has(hour), "spline hour %s is absent from the exhibits" % hour)


func _test_spline_unique_model() -> void:
	var models := Solver.enumerate(Spline.EXHIBITS, Spline)
	print("spline models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one spline model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Senn", "spline taker")
	_expect(str(model["place"]) == "plough", "spline place")
	_expect(str(model["hour"]) == "98", "spline hour")
	_expect(str(model["slotter"]) == "Voss", "spline slotter")
	_expect(str(model["slot_room"]) == "gimlet", "spline slot room")
	_expect(str(model["slot_hour"]) == "97", "spline slot hour")
	_expect(str(model["seen_from"]) == "float", "spline seen from")
	_expect(str(model["key"]) == "Cade", "spline key")
	_expect(str(model["aim"]) == "take_slot", "spline aim")
	_expect(str(model["turn_room"]) == "float", "spline turn room")
	_expect(str(model["feather_room"]) == "gimlet", "spline feather room")
	_expect(str(model["whet_hour"]) == "96", "spline whet hour")
	_expect(str(model["wipe_hour"]) == "99", "spline wipe hour")
	_expect(str(model["hang_hour"]) == "100", "spline hang hour")
	for hour in Spline.HOURS:
		var used := false
		for field in Spline.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "spline hour %s is blank in the true timeline" % hour)
	for place in Spline.PLACES:
		var place_used := false
		for field in Spline.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "spline room %s is blank in the true timeline" % place)
	for person in Spline.PEOPLE:
		var person_used := false
		for field in Spline.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "spline person %s is blank in the true timeline" % person)
	_expect(Spline.timeline(model) == SPLINE_TIMELINE, "spline timeline drifted:\n%s" % Spline.timeline(model))
	for exhibit in Spline.EXHIBITS:
		_expect(Spline.holds(exhibit, model), "%s rejects the spline timeline" % exhibit["id"])


func _test_spline_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Spline.EXHIBITS, Spline)
	for exhibit in Spline.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Spline.without(exhibit_id), Spline)
		print("spline without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "spline %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Spline.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "spline %s removal did not admit a timeline it forbids" % exhibit_id)


func _test_spline_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	var float_miss := {"who": "Voss", "place": "float", "hour": "96"}
	_expect(Spline.conflicting_ids(float_miss).size() == 9, "Voss / float / 96 contradicts %d exhibits" % Spline.conflicting_ids(float_miss).size())
	for who in Spline.PEOPLE:
		for place in Spline.PLACES:
			for hour in Spline.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == SPLINE_TRUE["who"] and place == SPLINE_TRUE["place"] and hour == SPLINE_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Spline)
					print("spline true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true spline theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "spline acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(SPLINE_TIMELINE) >= 0, "spline acceptance should give the timeline")
					_expect(str(result["message"]).find("Senn") >= 0, "spline acceptance omits Senn")
					_expect(str(result["message"]).find("plough") >= 0, "spline acceptance omits the plough")
					_expect(str(result["message"]).find("98") >= 0, "spline acceptance omits 98")
					_expect(str(result["message"]).find("so the tongue would take the slot") >= 0, "spline acceptance omits the slot")
					_expect(str(result["message"]).find("Senn (vise hand) cut the spline in the plough at 98") >= 0, "spline acceptance omits the cutting")
					_expect(Spline.conflicting_ids(theory).is_empty(), "true spline theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Spline)
					_expect(Spline.conflicting_ids(theory).size() >= 2, "%s / %s / %s contradicts fewer than two exhibits" % [who, place, hour])
					rejected += 1
	for outsider in ["Kern", "Phel", "Tarn", "Quill", "Wend", "Sile", "Jute", "Harl", "Neve", "Luth", "Ewan", "Maren", "Hollin", "Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal", "Nell"]:
		_expect_rejected({"who": outsider, "place": "plough", "hour": "98"}, Spline)
	print("spline theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d spline theories" % accepted)
	_expect(rejected >= 2, "rejected %d spline theories" % rejected)


func _test_spline_near_misses() -> void:
	var misses := [
		{"who": "Senn", "place": "plough", "hour": "99", "titles": ["Slot leaf", "Slot note", "Dry order"]},
		{"who": "Senn", "place": "plough", "hour": "97", "titles": ["Slot leaf", "Slot note", "Dry order"]},
		{"who": "Senn", "place": "float", "hour": "98", "titles": ["Slot slate", "Key card", "Cheek slip"]},
		{"who": "Voss", "place": "plough", "hour": "98", "titles": ["Slot chit", "Rest sight", "Feather hook"]},
	]
	var wrong_hour_in_plough := 0
	var wrong_place_at_hour := 0
	var wrong_person_in_plough := 0
	for theory in misses:
		_expect_rejected(theory, Spline)
		var result: Dictionary = Verdict.submit(theory, Spline)
		var message := str(result["message"])
		_expect(Spline.conflicting_ids(theory).size() >= 2, "near-miss should contradict at least two exhibits: %s" % message)
		_expect(Spline.conflicting_ids(theory).size() == 3, "near-miss should name three exhibits: %s" % message)
		var named_at := -1
		for title in theory["titles"]:
			var at := message.find(str(title))
			_expect(at >= 0, "near-miss omits %s: %s" % [title, message])
			_expect(at > named_at, "near-miss names %s out of paper order: %s" % [title, message])
			named_at = at
		if str(theory["who"]) == "Senn" and str(theory["place"]) == "plough" and str(theory["hour"]) != "98":
			wrong_hour_in_plough += 1
		if str(theory["who"]) == "Senn" and str(theory["place"]) != "plough" and str(theory["hour"]) == "98":
			wrong_place_at_hour += 1
		if str(theory["who"]) != "Senn" and str(theory["place"]) == "plough" and str(theory["hour"]) == "98":
			wrong_person_in_plough += 1
	print("spline near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four spline near-misses, found %d" % misses.size())
	_expect(wrong_hour_in_plough == 2, "two near-misses should keep Senn in the plough at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Senn at 98 in another room")
	_expect(wrong_person_in_plough >= 1, "a near-miss should keep the plough at 98 for another person")


func _test_spline_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
		"who stopped the night bell",
		"where they stopped the bell",
		"at which hour they stopped the bell",
		"who scored the salt mark",
		"where they scored the mark",
		"at which hour they scored the mark",
		"who trimmed the wick",
		"where they trimmed the wick",
		"at which hour they trimmed the wick",
		"who annealed the gather",
		"where they annealed the gather",
		"at which hour they annealed the gather",
		"who grafted the scion",
		"where they grafted the scion",
		"at which hour they grafted the scion",
		"who dipped the skein",
		"where they dipped the skein",
		"at which hour they dipped the skein",
		"who tarred the rope",
		"where they tarred the rope",
		"at which hour they tarred the rope",
		"who pressed the cork",
		"where they pressed the cork",
		"at which hour they pressed the cork",
		"who mended the net",
		"where they mended the net",
		"at which hour they mended the net",
		"who drove the hoop",
		"where they drove the hoop",
		"at which hour they drove the hoop",
		"who folded the linen",
		"where they folded the linen",
		"at which hour they folded the linen",
		"who cut the dovetail",
		"where they cut the dovetail",
		"at which hour they cut the dovetail",
		"who cut the mortise",
		"where they cut the mortise",
		"at which hour they cut the mortise",
		"who cut the rebate",
		"where they cut the rebate",
		"at which hour they cut the rebate",
		"who cut the housing",
		"where they cut the housing",
		"at which hour they cut the housing",
		"who cut the tenon",
		"where they cut the tenon",
		"at which hour they cut the tenon",
		"who cut the bridle",
		"where they cut the bridle",
		"at which hour they cut the bridle",
		"who cut the dado",
		"where they cut the dado",
		"at which hour they cut the dado",
	]
	var cases := [
		{"theory": {"who": "", "place": "plough", "hour": "98"}, "present": ["who cut the spline"], "absent": ["where they cut the spline", "at which hour they cut the spline"]},
		{"theory": {"who": "Senn", "place": "", "hour": "98"}, "present": ["where they cut the spline"], "absent": ["who cut the spline", "at which hour they cut the spline"]},
		{"theory": {"who": "Senn", "place": "plough", "hour": ""}, "present": ["at which hour they cut the spline"], "absent": ["who cut the spline", "where they cut the spline"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who cut the spline", "where they cut the spline", "at which hour they cut the spline"], "absent": []},
		{"theory": {}, "present": ["who cut the spline", "where they cut the spline", "at which hour they cut the spline"], "absent": []},
		{"theory": {"who": "Cade", "place": "", "hour": "100"}, "present": ["where they cut the spline"], "absent": ["who cut the spline", "at which hour they cut the spline"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Spline)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "spline incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "spline incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "spline incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "spline incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "spline incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "spline missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "spline named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "spline incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("spline incomplete submissions refused with the missing slot")


func _test_mitre_file_shape() -> void:
	_expect(Mitre.EXHIBITS.size() == 9, "mitre exhibit count is %d" % Mitre.EXHIBITS.size())
	_expect(Mitre.PEOPLE.size() == 3, "mitre cast should be three people")
	_expect(Mitre.PLACES.size() == 3, "mitre room count is %d" % Mitre.PLACES.size())
	_expect(Mitre.HOURS.size() == 5, "mitre hour list length is %d" % Mitre.HOURS.size())
	_expect(Mitre.PEOPLE == ["Orrin", "Venn", "Haim"], "mitre cast is %s" % str(Mitre.PEOPLE))
	_expect(Mitre.PLACES == ["plough", "float", "gimlet"], "mitre rooms are %s" % str(Mitre.PLACES))
	_expect(Mitre.HOURS == ["101", "102", "103", "104", "105"], "mitre hours are %s" % str(Mitre.HOURS))
	_expect(Mitre.AIMS == ["take_arris", "spare_arris", "set_arris"], "mitre aims are %s" % str(Mitre.AIMS))
	_expect(Mitre.aim_phrase("take_arris") == "so the arris would take the mitre", "mitre aim phrase")
	_expect(Mitre.aim_phrase("spare_arris") == "to spare the arris still waiting on the mitre", "mitre spare aim")
	_expect(Mitre.aim_phrase("set_arris") == "to set the arris before the plough was hung", "mitre set aim")
	_expect(Mitre.TITLE == "The mitre", "mitre title")
	_expect(Mitre.BLURB == "The mitre left its peg at the joiner's saddle. Name who cut the mitre, the room they cut it in, and the hour.", "mitre blurb")
	_expect(Mitre.FILE_CODE == "CW-32", "mitre file code")
	_expect(Mitre.fields() == ["taker", "place", "hour", "arriser", "arris_room", "arris_hour", "seen_from", "stop", "aim", "stop_room", "offcut_room", "dress_hour", "brush_hour", "hang_hour"], "mitre fields are %s" % str(Mitre.fields()))
	_expect(Mitre.PLAYER_FIELDS == ["taker", "place", "hour"], "mitre player fields")
	_expect(Mitre.HOURS[Mitre.HOURS.size() / 2] == MITRE_TRUE["hour"], "mitre cutting should be the middle hour")
	_expect(Mitre.HOURS[0] != MITRE_TRUE["hour"], "mitre cutting should not be the earliest hour")
	_expect(Mitre.HOURS[Mitre.HOURS.size() - 1] != MITRE_TRUE["hour"], "mitre cutting should not be the latest hour")
	var counts := _player_pin_counts(Mitre)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "mitre pin counts are %s" % str(counts))
	var loose_pin: Array = [
		[CaseData, "spare key"],
		[Rehearsal, "rehearsal score"],
		[Gilt, "gilt stamp"],
		[Ferry, "ferry bell"],
		[Weather, "weather slate"],
		[Loom, "loom shuttle"],
		[Hive, "hive smoker"],
		[Glass, "glass pontil"],
		[Press, "press proof"],
		[Assay, "assay cup"],
	]
	var rhythm: Array = [
		[Kiln, "kiln chalk"],
		[Tide, "tide ledger"],
		[Night, "night bell"],
		[Salt, "salt mark"],
		[Wick, "wick trim"],
		[Anneal, "glass anneal"],
		[Graft, "orchard graft"],
		[Dye, "dye vat"],
		[Tar, "tar kettle"],
		[Cork, "cork press"],
		[Net, "net loft"],
		[Cask, "cask hoop"],
		[Linen, "linen fold"],
		[Dovetail, "dovetail"],
		[Mortise, "mortise"],
		[Rebate, "rebate"],
		[Housing, "housing"],
		[Tenon, "tenon"],
		[Bridle, "bridle"],
		[Dado, "dado"],
		[Spline, "spline"],
	]
	for row in loose_pin:
		_expect(counts != _player_pin_counts(row[0]), "mitre copied the %s pin pattern" % row[1])
	for row in rhythm:
		_expect(counts == _player_pin_counts(row[0]), "mitre should keep the %s pin rhythm" % row[1])
	var earlier: Array = []
	earlier.append_array(loose_pin)
	earlier.append_array(rhythm)
	for row in earlier:
		var book = row[0]
		var name := str(row[1])
		_expect(Mitre.TITLE != book.TITLE, "mitre shares a title with the %s" % name)
		_expect(Mitre.FILE_CODE != book.FILE_CODE, "mitre shares a file code with the %s" % name)
		_expect(_field_key(Mitre) != _field_key(book), "mitre copied the %s timeline fields" % name)
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	var earlier_texts := {}
	var earlier_sentences := {}
	for row in earlier:
		for old_exhibit in row[0].EXHIBITS:
			var old_text := str(old_exhibit["text"])
			earlier_texts[old_text] = true
			for old_sentence in old_text.split(". "):
				earlier_sentences[old_sentence.trim_suffix(".").strip_edges()] = true
	var exhibit_titles: Array[String] = []
	var exhibit_sources: Array[String] = []
	for exhibit in Mitre.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		exhibit_titles.append(str(exhibit["title"]))
		exhibit_sources.append(str(exhibit["source"]))
		_expect(not seen.has(exhibit_id), "duplicate mitre id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		_expect(not earlier_texts.has(str(exhibit["text"])), "mitre copied an earlier exhibit")
		for sentence in str(exhibit["text"]).split(". "):
			var cleaned := sentence.trim_suffix(".").strip_edges()
			_expect(not earlier_sentences.has(cleaned), "mitre copied an earlier sentence: %s" % cleaned)
		for banned in ["tenon", "gouge", "rasp", "bevel", "haunch", "dowel", "hone", "guide", "harl", "neve", "luth", "nick", "housing", "saw", "square", "bead", "trench", "fillet", "stock", "chalk", "ewan", "maren", "hollin", "mortise", "chisel", "awl", "brace", "wedge", "bored", "ragged", "racked", "dovetail", "vise", "stile", "apron", "clamp", "peg", "joint", "linen", "fold", "shears", "roller", "hem", "sheet", "crease", "press", "loft", "bench", "bottle", "cork", "shop", "drawer", "seal", "screw", "cellar", "wax", "neck", "plug", "dye", "vat", "indigo", "skein", "rope", "walk", "kettle", "winch", "pitch", "mesh", "rail", "crank", "needle", "twine", "cooperage", "cask", "hoop", "croze", "stave", "rebate", "plane", "gauge", "mallet", "shoulder", "scribe", "shim", "fence", "tansy", "solt", "quern", "bridle", "router", "scraper", "adze", "templet", "strop", "notch", "wend", "sile", "jute", "dado", "groove", "cleat", "spur", "kern", "phel", "tarn", "shavings", "mouth", "iron", "senn", "voss", "cade", "slot", "feather", "whet", "cheek", "spline"]:
			_expect(str(exhibit["text"]).find(banned) == -1, "%s copies %s" % [exhibit_id, banned])
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Mitre.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Mitre.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Mitre.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Mitre.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "mitre should have two slips with two hidden facts, found %d" % paired_hidden)
	_expect(exhibit_titles == ["Arris chit", "Horn sight", "Offcut hook", "Arris slate", "Stop card", "Dress slip", "Arris leaf", "Arris note", "Brush order"], "mitre exhibit titles are %s" % str(exhibit_titles))
	_expect(exhibit_sources == ["Venn, kerf hand", "Float horn", "Gimlet brad", "Plough horn", "Haim, bit clerk", "Float pad", "Arris book", "Joiner's saddle", "Gimlet pad"], "mitre sources are %s" % str(exhibit_sources))
	for hour in Mitre.HOURS:
		_expect(stated.has(hour), "mitre hour %s is absent from the exhibits" % hour)


func _test_mitre_unique_model() -> void:
	var models := Solver.enumerate(Mitre.EXHIBITS, Mitre)
	print("mitre models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one mitre model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Orrin", "mitre taker")
	_expect(str(model["place"]) == "plough", "mitre place")
	_expect(str(model["hour"]) == "103", "mitre hour")
	_expect(str(model["arriser"]) == "Venn", "mitre arriser")
	_expect(str(model["arris_room"]) == "gimlet", "mitre arris room")
	_expect(str(model["arris_hour"]) == "102", "mitre arris hour")
	_expect(str(model["seen_from"]) == "float", "mitre seen from")
	_expect(str(model["stop"]) == "Haim", "mitre stop")
	_expect(str(model["aim"]) == "take_arris", "mitre aim")
	_expect(str(model["stop_room"]) == "float", "mitre stop room")
	_expect(str(model["offcut_room"]) == "gimlet", "mitre offcut room")
	_expect(str(model["dress_hour"]) == "101", "mitre dress hour")
	_expect(str(model["brush_hour"]) == "104", "mitre brush hour")
	_expect(str(model["hang_hour"]) == "105", "mitre hang hour")
	for hour in Mitre.HOURS:
		var used := false
		for field in Mitre.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "mitre hour %s is blank in the true timeline" % hour)
	for place in Mitre.PLACES:
		var place_used := false
		for field in Mitre.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "mitre room %s is blank in the true timeline" % place)
	for person in Mitre.PEOPLE:
		var person_used := false
		for field in Mitre.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "mitre person %s is blank in the true timeline" % person)
	_expect(Mitre.timeline(model) == MITRE_TIMELINE, "mitre timeline drifted:\n%s" % Mitre.timeline(model))
	for exhibit in Mitre.EXHIBITS:
		_expect(Mitre.holds(exhibit, model), "%s rejects the mitre timeline" % exhibit["id"])


func _test_mitre_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Mitre.EXHIBITS, Mitre)
	for exhibit in Mitre.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Mitre.without(exhibit_id), Mitre)
		print("mitre without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "mitre %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Mitre.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "mitre %s removal did not admit a timeline it forbids" % exhibit_id)


func _test_mitre_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	var float_miss := {"who": "Venn", "place": "float", "hour": "101"}
	_expect(Mitre.conflicting_ids(float_miss).size() == 9, "Venn / float / 101 contradicts %d exhibits" % Mitre.conflicting_ids(float_miss).size())
	for who in Mitre.PEOPLE:
		for place in Mitre.PLACES:
			for hour in Mitre.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == MITRE_TRUE["who"] and place == MITRE_TRUE["place"] and hour == MITRE_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Mitre)
					print("mitre true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true mitre theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "mitre acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(MITRE_TIMELINE) >= 0, "mitre acceptance should give the timeline")
					_expect(str(result["message"]).find("Orrin") >= 0, "mitre acceptance omits Orrin")
					_expect(str(result["message"]).find("plough") >= 0, "mitre acceptance omits the plough")
					_expect(str(result["message"]).find("103") >= 0, "mitre acceptance omits 103")
					_expect(str(result["message"]).find("so the arris would take the mitre") >= 0, "mitre acceptance omits the arris")
					_expect(str(result["message"]).find("Orrin (saddle hand) cut the mitre in the plough at 103") >= 0, "mitre acceptance omits the cutting")
					_expect(Mitre.conflicting_ids(theory).is_empty(), "true mitre theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Mitre)
					_expect(Mitre.conflicting_ids(theory).size() >= 2, "%s / %s / %s contradicts fewer than two exhibits" % [who, place, hour])
					rejected += 1
	for outsider in ["Senn", "Voss", "Cade", "Kern", "Phel", "Tarn", "Quill", "Wend", "Sile", "Jute", "Harl", "Neve", "Luth", "Ewan", "Maren", "Hollin", "Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal", "Nell"]:
		_expect_rejected({"who": outsider, "place": "plough", "hour": "103"}, Mitre)
	print("mitre theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d mitre theories" % accepted)
	_expect(rejected >= 2, "rejected %d mitre theories" % rejected)


func _test_mitre_near_misses() -> void:
	var misses := [
		{"who": "Orrin", "place": "plough", "hour": "104", "titles": ["Arris leaf", "Arris note", "Brush order"]},
		{"who": "Orrin", "place": "plough", "hour": "102", "titles": ["Arris leaf", "Arris note", "Brush order"]},
		{"who": "Orrin", "place": "float", "hour": "103", "titles": ["Arris slate", "Stop card", "Dress slip"]},
		{"who": "Venn", "place": "plough", "hour": "103", "titles": ["Arris chit", "Horn sight", "Offcut hook"]},
	]
	var wrong_hour_in_plough := 0
	var wrong_place_at_hour := 0
	var wrong_person_in_plough := 0
	for theory in misses:
		_expect_rejected(theory, Mitre)
		var result: Dictionary = Verdict.submit(theory, Mitre)
		var message := str(result["message"])
		_expect(Mitre.conflicting_ids(theory).size() >= 2, "near-miss should contradict at least two exhibits: %s" % message)
		_expect(Mitre.conflicting_ids(theory).size() == 3, "near-miss should name three exhibits: %s" % message)
		var named_at := -1
		for title in theory["titles"]:
			var at := message.find(str(title))
			_expect(at >= 0, "near-miss omits %s: %s" % [title, message])
			_expect(at > named_at, "near-miss names %s out of paper order: %s" % [title, message])
			named_at = at
		if str(theory["who"]) == "Orrin" and str(theory["place"]) == "plough" and str(theory["hour"]) != "103":
			wrong_hour_in_plough += 1
		if str(theory["who"]) == "Orrin" and str(theory["place"]) != "plough" and str(theory["hour"]) == "103":
			wrong_place_at_hour += 1
		if str(theory["who"]) != "Orrin" and str(theory["place"]) == "plough" and str(theory["hour"]) == "103":
			wrong_person_in_plough += 1
	print("mitre near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four mitre near-misses, found %d" % misses.size())
	_expect(wrong_hour_in_plough == 2, "two near-misses should keep Orrin in the plough at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Orrin at 103 in another room")
	_expect(wrong_person_in_plough >= 1, "a near-miss should keep the plough at 103 for another person")


func _test_mitre_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
		"who stopped the night bell",
		"where they stopped the bell",
		"at which hour they stopped the bell",
		"who scored the salt mark",
		"where they scored the mark",
		"at which hour they scored the mark",
		"who trimmed the wick",
		"where they trimmed the wick",
		"at which hour they trimmed the wick",
		"who annealed the gather",
		"where they annealed the gather",
		"at which hour they annealed the gather",
		"who grafted the scion",
		"where they grafted the scion",
		"at which hour they grafted the scion",
		"who dipped the skein",
		"where they dipped the skein",
		"at which hour they dipped the skein",
		"who tarred the rope",
		"where they tarred the rope",
		"at which hour they tarred the rope",
		"who pressed the cork",
		"where they pressed the cork",
		"at which hour they pressed the cork",
		"who mended the net",
		"where they mended the net",
		"at which hour they mended the net",
		"who drove the hoop",
		"where they drove the hoop",
		"at which hour they drove the hoop",
		"who folded the linen",
		"where they folded the linen",
		"at which hour they folded the linen",
		"who cut the dovetail",
		"where they cut the dovetail",
		"at which hour they cut the dovetail",
		"who cut the mortise",
		"where they cut the mortise",
		"at which hour they cut the mortise",
		"who cut the rebate",
		"where they cut the rebate",
		"at which hour they cut the rebate",
		"who cut the housing",
		"where they cut the housing",
		"at which hour they cut the housing",
		"who cut the tenon",
		"where they cut the tenon",
		"at which hour they cut the tenon",
		"who cut the bridle",
		"where they cut the bridle",
		"at which hour they cut the bridle",
		"who cut the dado",
		"where they cut the dado",
		"at which hour they cut the dado",
		"who cut the spline",
		"where they cut the spline",
		"at which hour they cut the spline",
	]
	var cases := [
		{"theory": {"who": "", "place": "plough", "hour": "103"}, "present": ["who cut the mitre"], "absent": ["where they cut the mitre", "at which hour they cut the mitre"]},
		{"theory": {"who": "Orrin", "place": "", "hour": "103"}, "present": ["where they cut the mitre"], "absent": ["who cut the mitre", "at which hour they cut the mitre"]},
		{"theory": {"who": "Orrin", "place": "plough", "hour": ""}, "present": ["at which hour they cut the mitre"], "absent": ["who cut the mitre", "where they cut the mitre"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who cut the mitre", "where they cut the mitre", "at which hour they cut the mitre"], "absent": []},
		{"theory": {}, "present": ["who cut the mitre", "where they cut the mitre", "at which hour they cut the mitre"], "absent": []},
		{"theory": {"who": "Haim", "place": "", "hour": "105"}, "present": ["where they cut the mitre"], "absent": ["who cut the mitre", "at which hour they cut the mitre"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Mitre)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "mitre incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "mitre incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "mitre incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "mitre incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "mitre incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "mitre missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "mitre named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "mitre incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("mitre incomplete submissions refused with the missing slot")



func _test_lap_file_shape() -> void:
	_expect(Lap.EXHIBITS.size() == 9, "lap exhibit count is %d" % Lap.EXHIBITS.size())
	_expect(Lap.PEOPLE.size() == 3, "lap cast should be three people")
	_expect(Lap.PLACES.size() == 3, "lap room count is %d" % Lap.PLACES.size())
	_expect(Lap.HOURS.size() == 5, "lap hour list length is %d" % Lap.HOURS.size())
	_expect(Lap.PEOPLE == ["Nye", "Yew", "Pry"], "lap cast is %s" % str(Lap.PEOPLE))
	_expect(Lap.PLACES == ["plough", "float", "gimlet"], "lap rooms are %s" % str(Lap.PLACES))
	_expect(Lap.HOURS == ["106", "107", "108", "109", "110"], "lap hours are %s" % str(Lap.HOURS))
	_expect(Lap.AIMS == ["take_grain", "spare_grain", "set_grain"], "lap aims are %s" % str(Lap.AIMS))
	_expect(Lap.aim_phrase("take_grain") == "so the grain would take the lap", "lap aim phrase")
	_expect(Lap.aim_phrase("spare_grain") == "to spare the grain still waiting on the lap", "lap spare aim")
	_expect(Lap.aim_phrase("set_grain") == "to set the grain before the plough was hung", "lap set aim")
	_expect(Lap.TITLE == "The lap", "lap title")
	_expect(Lap.BLURB == "The lap left its peg at the joiner's cradle. Name who cut the lap, the room they cut it in, and the hour.", "lap blurb")
	_expect(Lap.FILE_CODE == "CW-33", "lap file code")
	_expect(Lap.fields() == ["taker", "place", "hour", "grainer", "grain_room", "grain_hour", "seen_from", "brad", "aim", "brad_room", "paring_room", "skim_hour", "oil_hour", "hang_hour"], "lap fields are %s" % str(Lap.fields()))
	_expect(Lap.PLAYER_FIELDS == ["taker", "place", "hour"], "lap player fields")
	_expect(Lap.HOURS[Lap.HOURS.size() / 2] == LAP_TRUE["hour"], "lap cutting should be the middle hour")
	_expect(Lap.HOURS[0] != LAP_TRUE["hour"], "lap cutting should not be the earliest hour")
	_expect(Lap.HOURS[Lap.HOURS.size() - 1] != LAP_TRUE["hour"], "lap cutting should not be the latest hour")
	var counts := _player_pin_counts(Lap)
	_expect(int(counts["taker"]) == 3 and int(counts["place"]) == 3 and int(counts["hour"]) == 3, "lap pin counts are %s" % str(counts))
	var loose_pin: Array = [
		[CaseData, "spare key"],
		[Rehearsal, "rehearsal score"],
		[Gilt, "gilt stamp"],
		[Ferry, "ferry bell"],
		[Weather, "weather slate"],
		[Loom, "loom shuttle"],
		[Hive, "hive smoker"],
		[Glass, "glass pontil"],
		[Press, "press proof"],
		[Assay, "assay cup"],
	]
	var rhythm: Array = [
		[Kiln, "kiln chalk"],
		[Tide, "tide ledger"],
		[Night, "night bell"],
		[Salt, "salt mark"],
		[Wick, "wick trim"],
		[Anneal, "glass anneal"],
		[Graft, "orchard graft"],
		[Dye, "dye vat"],
		[Tar, "tar kettle"],
		[Cork, "cork press"],
		[Net, "net loft"],
		[Cask, "cask hoop"],
		[Linen, "linen fold"],
		[Dovetail, "dovetail"],
		[Mortise, "mortise"],
		[Rebate, "rebate"],
		[Housing, "housing"],
		[Tenon, "tenon"],
		[Bridle, "bridle"],
		[Dado, "dado"],
		[Spline, "spline"],
		[Mitre, "mitre"],
	]
	for row in loose_pin:
		_expect(counts != _player_pin_counts(row[0]), "lap copied the %s pin pattern" % row[1])
	for row in rhythm:
		_expect(counts == _player_pin_counts(row[0]), "lap should keep the %s pin rhythm" % row[1])
	var earlier: Array = []
	earlier.append_array(loose_pin)
	earlier.append_array(rhythm)
	for row in earlier:
		var book = row[0]
		var name := str(row[1])
		_expect(Lap.TITLE != book.TITLE, "lap shares a title with the %s" % name)
		_expect(Lap.FILE_CODE != book.FILE_CODE, "lap shares a file code with the %s" % name)
		_expect(_field_key(Lap) != _field_key(book), "lap copied the %s timeline fields" % name)
	var seen := {}
	var stated := {}
	var paired_hidden := 0
	var earlier_texts := {}
	var earlier_sentences := {}
	for row in earlier:
		for old_exhibit in row[0].EXHIBITS:
			var old_text := str(old_exhibit["text"])
			earlier_texts[old_text] = true
			for old_sentence in old_text.split(". "):
				earlier_sentences[old_sentence.trim_suffix(".").strip_edges()] = true
	var exhibit_titles: Array[String] = []
	var exhibit_sources: Array[String] = []
	for exhibit in Lap.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		exhibit_titles.append(str(exhibit["title"]))
		exhibit_sources.append(str(exhibit["source"]))
		_expect(not seen.has(exhibit_id), "duplicate lap id %s" % exhibit_id)
		seen[exhibit_id] = true
		_expect(str(exhibit["title"]) != "", "%s missing title" % exhibit_id)
		_expect(str(exhibit["text"]).count(". ") == 1, "%s should be two short sentences" % exhibit_id)
		_expect(not earlier_texts.has(str(exhibit["text"])), "lap copied an earlier exhibit")
		for sentence in str(exhibit["text"]).split(". "):
			var cleaned := sentence.trim_suffix(".").strip_edges()
			_expect(not earlier_sentences.has(cleaned), "lap copied an earlier sentence: %s" % cleaned)
		for banned in ["tenon", "gouge", "rasp", "bevel", "haunch", "dowel", "hone", "guide", "harl", "neve", "luth", "nick", "housing", "saw", "square", "bead", "trench", "fillet", "stock", "chalk", "ewan", "maren", "hollin", "mortise", "chisel", "awl", "brace", "wedge", "bored", "ragged", "racked", "dovetail", "vise", "stile", "apron", "clamp", "peg", "joint", "linen", "fold", "shears", "roller", "hem", "sheet", "crease", "press", "loft", "bench", "bottle", "cork", "shop", "drawer", "seal", "screw", "cellar", "wax", "neck", "plug", "dye", "vat", "indigo", "skein", "rope", "walk", "kettle", "winch", "pitch", "mesh", "rail", "crank", "needle", "twine", "cooperage", "cask", "hoop", "croze", "stave", "rebate", "plane", "gauge", "mallet", "shoulder", "scribe", "shim", "fence", "tansy", "solt", "quern", "bridle", "router", "scraper", "adze", "templet", "strop", "notch", "wend", "sile", "jute", "dado", "groove", "cleat", "spur", "kern", "phel", "tarn", "shavings", "mouth", "iron", "senn", "voss", "cade", "slot", "feather", "whet", "cheek", "spline", "orrin", "venn", "haim", "mitre", "arris", "offcut", "saddle", "kerf", "dressed", "brushed"]:
			_expect(str(exhibit["text"]).find(banned) == -1, "%s copies %s" % [exhibit_id, banned])
		var states_player_pin := false
		var states_unique := false
		var player_literals := 0
		var hidden_literals := 0
		for literal in exhibit["literals"]:
			stated[str(literal["value"])] = true
			var phrase := str(literal["phrase"])
			_expect(phrase != "" and str(exhibit["text"]).find(phrase) >= 0, "%s phrase missing from text: %s" % [exhibit_id, phrase])
			var field := str(literal["field"])
			if field in Lap.PLAYER_FIELDS:
				states_player_pin = true
				player_literals += 1
				var expected := Lap.player_statement(field, str(literal["value"]))
				_expect(phrase == expected, "%s player phrase drifted for %s" % [exhibit_id, field])
				var repeats := 0
				for other in Lap.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field and str(other_literal["value"]) == str(literal["value"]):
							repeats += 1
				_expect(repeats >= 2, "%s states %s once" % [exhibit_id, field])
			else:
				hidden_literals += 1
				var owners := 0
				for other in Lap.EXHIBITS:
					for other_literal in other["literals"]:
						if str(other_literal["field"]) == field:
							owners += 1
				if owners == 1:
					states_unique = true
		if hidden_literals == 2:
			paired_hidden += 1
		else:
			_expect(hidden_literals == 1, "%s states %d hidden facts" % [exhibit_id, hidden_literals])
		_expect(states_player_pin, "%s states no player pin" % exhibit_id)
		_expect(player_literals == 1, "%s states %d player pins" % [exhibit_id, player_literals])
		_expect(states_unique, "%s states no fact of its own" % exhibit_id)
	_expect(paired_hidden == 2, "lap should have two slips with two hidden facts, found %d" % paired_hidden)
	_expect(exhibit_titles == ["Grain chit", "Crest sight", "Paring hook", "Grain slate", "Brad card", "Skim slip", "Grain leaf", "Grain note", "Oil order"], "lap exhibit titles are %s" % str(exhibit_titles))
	_expect(exhibit_sources == ["Yew, grain hand", "Float crest", "Gimlet point", "Plough lip", "Pry, brad clerk", "Float board", "Grain book", "Joiner's cradle", "Gimlet card"], "lap sources are %s" % str(exhibit_sources))
	for hour in Lap.HOURS:
		_expect(stated.has(hour), "lap hour %s is absent from the exhibits" % hour)


func _test_lap_unique_model() -> void:
	var models := Solver.enumerate(Lap.EXHIBITS, Lap)
	print("lap models: %d" % models.size())
	_expect(models.size() == 1, "expected exactly one lap model, found %d" % models.size())
	if models.is_empty():
		return
	var model: Dictionary = models[0]
	_expect(str(model["taker"]) == "Nye", "lap taker")
	_expect(str(model["place"]) == "plough", "lap place")
	_expect(str(model["hour"]) == "108", "lap hour")
	_expect(str(model["grainer"]) == "Yew", "lap grainer")
	_expect(str(model["grain_room"]) == "gimlet", "lap grain room")
	_expect(str(model["grain_hour"]) == "107", "lap grain hour")
	_expect(str(model["seen_from"]) == "float", "lap seen from")
	_expect(str(model["brad"]) == "Pry", "lap brad")
	_expect(str(model["aim"]) == "take_grain", "lap aim")
	_expect(str(model["brad_room"]) == "float", "lap brad room")
	_expect(str(model["paring_room"]) == "gimlet", "lap paring room")
	_expect(str(model["skim_hour"]) == "106", "lap dress hour")
	_expect(str(model["oil_hour"]) == "109", "lap brush hour")
	_expect(str(model["hang_hour"]) == "110", "lap hang hour")
	for hour in Lap.HOURS:
		var used := false
		for field in Lap.fields():
			if str(model[field]) == hour:
				used = true
		_expect(used, "lap hour %s is blank in the true timeline" % hour)
	for place in Lap.PLACES:
		var place_used := false
		for field in Lap.fields():
			if str(model[field]) == place:
				place_used = true
		_expect(place_used, "lap room %s is blank in the true timeline" % place)
	for person in Lap.PEOPLE:
		var person_used := false
		for field in Lap.fields():
			if str(model[field]) == person:
				person_used = true
		_expect(person_used, "lap person %s is blank in the true timeline" % person)
	_expect(Lap.timeline(model) == LAP_TIMELINE, "lap timeline drifted:\n%s" % Lap.timeline(model))
	for exhibit in Lap.EXHIBITS:
		_expect(Lap.holds(exhibit, model), "%s rejects the lap timeline" % exhibit["id"])


func _test_lap_each_exhibit_necessary() -> void:
	var full := Solver.enumerate(Lap.EXHIBITS, Lap)
	for exhibit in Lap.EXHIBITS:
		var exhibit_id := str(exhibit["id"])
		var reduced := Solver.enumerate(Lap.without(exhibit_id), Lap)
		print("lap without %s: %d models" % [exhibit_id, reduced.size()])
		_expect(reduced.size() > full.size(), "lap %s is not necessary (%d models)" % [exhibit_id, reduced.size()])
		var opened := false
		for model in reduced:
			if not Lap.holds(exhibit, model):
				opened = true
				break
		_expect(opened, "lap %s removal did not admit a timeline it forbids" % exhibit_id)


func _test_lap_only_true_theory() -> void:
	var accepted := 0
	var rejected := 0
	var float_miss := {"who": "Yew", "place": "float", "hour": "106"}
	_expect(Lap.conflicting_ids(float_miss).size() == 9, "Yew / float / 106 contradicts %d exhibits" % Lap.conflicting_ids(float_miss).size())
	for who in Lap.PEOPLE:
		for place in Lap.PLACES:
			for hour in Lap.HOURS:
				var theory := {"who": who, "place": place, "hour": hour}
				if who == LAP_TRUE["who"] and place == LAP_TRUE["place"] and hour == LAP_TRUE["hour"]:
					var result: Dictionary = Verdict.submit(theory, Lap)
					print("lap true theory: %s" % result["status"])
					_expect(result["status"] == "accepted", "true lap theory status %s" % result["status"])
					_expect(str(result["message"]).find("fits every exhibit") >= 0, "lap acceptance should say it fits every exhibit")
					_expect(str(result["message"]).find(LAP_TIMELINE) >= 0, "lap acceptance should give the timeline")
					_expect(str(result["message"]).find("Nye") >= 0, "lap acceptance omits Nye")
					_expect(str(result["message"]).find("plough") >= 0, "lap acceptance omits the plough")
					_expect(str(result["message"]).find("108") >= 0, "lap acceptance omits 108")
					_expect(str(result["message"]).find("so the grain would take the lap") >= 0, "lap acceptance omits the grain")
					_expect(str(result["message"]).find("Nye (cradle hand) cut the lap in the plough at 108") >= 0, "lap acceptance omits the cutting")
					_expect(Lap.conflicting_ids(theory).is_empty(), "true lap theory conflicts with an exhibit")
					accepted += 1
				else:
					_expect_rejected(theory, Lap)
					_expect(Lap.conflicting_ids(theory).size() >= 2, "%s / %s / %s contradicts fewer than two exhibits" % [who, place, hour])
					rejected += 1
	for outsider in ["Orrin", "Venn", "Haim", "Senn", "Voss", "Cade", "Kern", "Phel", "Tarn", "Quill", "Wend", "Sile", "Jute", "Harl", "Neve", "Luth", "Ewan", "Maren", "Hollin", "Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal", "Nell"]:
		_expect_rejected({"who": outsider, "place": "plough", "hour": "108"}, Lap)
	print("lap theories accepted: %d rejected: %d" % [accepted, rejected])
	_expect(accepted == 1, "accepted %d lap theories" % accepted)
	_expect(rejected >= 2, "rejected %d lap theories" % rejected)


func _test_lap_near_misses() -> void:
	var misses := [
		{"who": "Nye", "place": "plough", "hour": "109", "titles": ["Grain leaf", "Grain note", "Oil order"]},
		{"who": "Nye", "place": "plough", "hour": "107", "titles": ["Grain leaf", "Grain note", "Oil order"]},
		{"who": "Nye", "place": "float", "hour": "108", "titles": ["Grain slate", "Brad card", "Skim slip"]},
		{"who": "Yew", "place": "plough", "hour": "108", "titles": ["Grain chit", "Crest sight", "Paring hook"]},
	]
	var wrong_hour_in_plough := 0
	var wrong_place_at_hour := 0
	var wrong_person_in_plough := 0
	for theory in misses:
		_expect_rejected(theory, Lap)
		var result: Dictionary = Verdict.submit(theory, Lap)
		var message := str(result["message"])
		_expect(Lap.conflicting_ids(theory).size() >= 2, "near-miss should contradict at least two exhibits: %s" % message)
		_expect(Lap.conflicting_ids(theory).size() == 3, "near-miss should name three exhibits: %s" % message)
		var named_at := -1
		for title in theory["titles"]:
			var at := message.find(str(title))
			_expect(at >= 0, "near-miss omits %s: %s" % [title, message])
			_expect(at > named_at, "near-miss names %s out of paper order: %s" % [title, message])
			named_at = at
		if str(theory["who"]) == "Nye" and str(theory["place"]) == "plough" and str(theory["hour"]) != "108":
			wrong_hour_in_plough += 1
		if str(theory["who"]) == "Nye" and str(theory["place"]) != "plough" and str(theory["hour"]) == "108":
			wrong_place_at_hour += 1
		if str(theory["who"]) != "Nye" and str(theory["place"]) == "plough" and str(theory["hour"]) == "108":
			wrong_person_in_plough += 1
	print("lap near-misses rejected: %d" % misses.size())
	_expect(misses.size() == 4, "need four lap near-misses, found %d" % misses.size())
	_expect(wrong_hour_in_plough == 2, "two near-misses should keep Nye in the plough at another hour")
	_expect(wrong_place_at_hour >= 1, "a near-miss should keep Nye at 108 in another room")
	_expect(wrong_person_in_plough >= 1, "a near-miss should keep the plough at 108 for another person")


func _test_lap_incomplete() -> void:
	var other_slots := [
		"who took the spare key",
		"where they took the key",
		"at which hour they took the key",
		"who took the rehearsal score",
		"where they took the score",
		"at which hour they took the score",
		"who took the gilt stamp",
		"where they took the stamp",
		"at which hour they took the stamp",
		"who took the ferry bell",
		"where they took the bell",
		"at which hour they took the bell",
		"who took the weather slate",
		"where they took the slate",
		"at which hour they took the slate",
		"who took the loom shuttle",
		"where they took the shuttle",
		"at which hour they took the shuttle",
		"who took the hive smoker",
		"where they took the smoker",
		"at which hour they took the smoker",
		"who took the glass pontil",
		"where they took the pontil",
		"at which hour they took the pontil",
		"who took the press proof",
		"where they took the proof",
		"at which hour they took the proof",
		"who set the assay cup",
		"where they set the cup",
		"at which hour they set the cup",
		"who chalked the kiln mark",
		"where they chalked the mark",
		"at which hour they chalked the mark",
		"who entered the tide ledger",
		"where they entered the ledger",
		"at which hour they entered the ledger",
		"who stopped the night bell",
		"where they stopped the bell",
		"at which hour they stopped the bell",
		"who scored the salt mark",
		"where they scored the mark",
		"at which hour they scored the mark",
		"who trimmed the wick",
		"where they trimmed the wick",
		"at which hour they trimmed the wick",
		"who annealed the gather",
		"where they annealed the gather",
		"at which hour they annealed the gather",
		"who grafted the scion",
		"where they grafted the scion",
		"at which hour they grafted the scion",
		"who dipped the skein",
		"where they dipped the skein",
		"at which hour they dipped the skein",
		"who tarred the rope",
		"where they tarred the rope",
		"at which hour they tarred the rope",
		"who pressed the cork",
		"where they pressed the cork",
		"at which hour they pressed the cork",
		"who mended the net",
		"where they mended the net",
		"at which hour they mended the net",
		"who drove the hoop",
		"where they drove the hoop",
		"at which hour they drove the hoop",
		"who folded the linen",
		"where they folded the linen",
		"at which hour they folded the linen",
		"who cut the dovetail",
		"where they cut the dovetail",
		"at which hour they cut the dovetail",
		"who cut the mortise",
		"where they cut the mortise",
		"at which hour they cut the mortise",
		"who cut the rebate",
		"where they cut the rebate",
		"at which hour they cut the rebate",
		"who cut the housing",
		"where they cut the housing",
		"at which hour they cut the housing",
		"who cut the tenon",
		"where they cut the tenon",
		"at which hour they cut the tenon",
		"who cut the bridle",
		"where they cut the bridle",
		"at which hour they cut the bridle",
		"who cut the dado",
		"where they cut the dado",
		"at which hour they cut the dado",
		"who cut the spline",
		"where they cut the spline",
		"at which hour they cut the spline",
		"who cut the mitre",
		"where they cut the mitre",
		"at which hour they cut the mitre",
	]
	var cases := [
		{"theory": {"who": "", "place": "plough", "hour": "108"}, "present": ["who cut the lap"], "absent": ["where they cut the lap", "at which hour they cut the lap"]},
		{"theory": {"who": "Nye", "place": "", "hour": "108"}, "present": ["where they cut the lap"], "absent": ["who cut the lap", "at which hour they cut the lap"]},
		{"theory": {"who": "Nye", "place": "plough", "hour": ""}, "present": ["at which hour they cut the lap"], "absent": ["who cut the lap", "where they cut the lap"]},
		{"theory": {"who": "", "place": "", "hour": ""}, "present": ["who cut the lap", "where they cut the lap", "at which hour they cut the lap"], "absent": []},
		{"theory": {}, "present": ["who cut the lap", "where they cut the lap", "at which hour they cut the lap"], "absent": []},
		{"theory": {"who": "Pry", "place": "", "hour": "110"}, "present": ["where they cut the lap"], "absent": ["who cut the lap", "at which hour they cut the lap"]},
	]
	for case_row in cases:
		var result: Dictionary = Verdict.submit(case_row["theory"], Lap)
		var message := str(result["message"])
		_expect(result["status"] == "incomplete", "lap incomplete status was %s (%s)" % [result["status"], message])
		_expect(result["status"] != "rejected", "lap incomplete was called rejected")
		_expect(message.to_lower().find("wrong") == -1, "lap incomplete message says wrong: %s" % message)
		_expect(message.to_lower().find("conflict") == -1, "lap incomplete message talks about a conflict: %s" % message)
		_expect(_cited_ids(message).is_empty(), "lap incomplete message cites exhibits: %s" % message)
		for phrase in case_row["present"]:
			_expect(message.find(phrase) >= 0, "lap missing slot not named (%s) in: %s" % [phrase, message])
		for phrase in case_row["absent"]:
			_expect(message.find(phrase) == -1, "lap named a filled slot (%s) in: %s" % [phrase, message])
		for phrase in other_slots:
			_expect(message.find(phrase) == -1, "lap incomplete used another file's slot (%s) in: %s" % [phrase, message])
	print("lap incomplete submissions refused with the missing slot")



func _test_solutions_differ() -> void:
	var spare := {"who": "Nell", "place": "kitchen", "hour": "7"}
	_expect(spare["who"] != REHEARSAL_TRUE["who"], "rehearsal copied the spare-key taker")
	_expect(spare["place"] != REHEARSAL_TRUE["place"], "rehearsal copied the spare-key room")
	_expect(spare["hour"] != REHEARSAL_TRUE["hour"], "rehearsal copied the spare-key hour")
	_expect(GILT_TRUE["who"] != spare["who"], "gilt stamp copied the spare-key taker")
	_expect(GILT_TRUE["place"] != spare["place"], "gilt stamp copied the spare-key room")
	_expect(GILT_TRUE["hour"] != spare["hour"], "gilt stamp copied the spare-key hour")
	_expect(GILT_TRUE["who"] != REHEARSAL_TRUE["who"], "gilt stamp copied the rehearsal taker")
	_expect(GILT_TRUE["place"] != REHEARSAL_TRUE["place"], "gilt stamp copied the rehearsal room")
	_expect(GILT_TRUE["hour"] != REHEARSAL_TRUE["hour"], "gilt stamp copied the rehearsal hour")
	_expect(FERRY_TRUE["who"] != spare["who"], "ferry bell copied the spare-key taker")
	_expect(FERRY_TRUE["place"] != spare["place"], "ferry bell copied the spare-key room")
	_expect(FERRY_TRUE["hour"] != spare["hour"], "ferry bell copied the spare-key hour")
	_expect(FERRY_TRUE["who"] != REHEARSAL_TRUE["who"], "ferry bell copied the rehearsal taker")
	_expect(FERRY_TRUE["place"] != REHEARSAL_TRUE["place"], "ferry bell copied the rehearsal room")
	_expect(FERRY_TRUE["hour"] != REHEARSAL_TRUE["hour"], "ferry bell copied the rehearsal hour")
	_expect(FERRY_TRUE["who"] != GILT_TRUE["who"], "ferry bell copied the gilt taker")
	_expect(FERRY_TRUE["place"] != GILT_TRUE["place"], "ferry bell copied the gilt room")
	_expect(FERRY_TRUE["hour"] != GILT_TRUE["hour"], "ferry bell copied the gilt hour")
	_expect(WEATHER_TRUE["who"] != spare["who"], "weather slate copied the spare-key taker")
	_expect(WEATHER_TRUE["place"] != spare["place"], "weather slate copied the spare-key room")
	_expect(WEATHER_TRUE["hour"] != spare["hour"], "weather slate copied the spare-key hour")
	_expect(WEATHER_TRUE["who"] != REHEARSAL_TRUE["who"], "weather slate copied the rehearsal taker")
	_expect(WEATHER_TRUE["place"] != REHEARSAL_TRUE["place"], "weather slate copied the rehearsal room")
	_expect(WEATHER_TRUE["hour"] != REHEARSAL_TRUE["hour"], "weather slate copied the rehearsal hour")
	_expect(WEATHER_TRUE["who"] != GILT_TRUE["who"], "weather slate copied the gilt taker")
	_expect(WEATHER_TRUE["place"] != GILT_TRUE["place"], "weather slate copied the gilt room")
	_expect(WEATHER_TRUE["hour"] != GILT_TRUE["hour"], "weather slate copied the gilt hour")
	_expect(WEATHER_TRUE["who"] != FERRY_TRUE["who"], "weather slate copied the ferry taker")
	_expect(WEATHER_TRUE["place"] != FERRY_TRUE["place"], "weather slate copied the ferry room")
	_expect(WEATHER_TRUE["hour"] != FERRY_TRUE["hour"], "weather slate copied the ferry hour")
	_expect(LOOM_TRUE["who"] != spare["who"], "loom shuttle copied the spare-key taker")
	_expect(LOOM_TRUE["place"] != spare["place"], "loom shuttle copied the spare-key room")
	_expect(LOOM_TRUE["hour"] != spare["hour"], "loom shuttle copied the spare-key hour")
	_expect(LOOM_TRUE["who"] != REHEARSAL_TRUE["who"], "loom shuttle copied the rehearsal taker")
	_expect(LOOM_TRUE["place"] != REHEARSAL_TRUE["place"], "loom shuttle copied the rehearsal room")
	_expect(LOOM_TRUE["hour"] != REHEARSAL_TRUE["hour"], "loom shuttle copied the rehearsal hour")
	_expect(LOOM_TRUE["who"] != GILT_TRUE["who"], "loom shuttle copied the gilt taker")
	_expect(LOOM_TRUE["place"] != GILT_TRUE["place"], "loom shuttle copied the gilt room")
	_expect(LOOM_TRUE["hour"] != GILT_TRUE["hour"], "loom shuttle copied the gilt hour")
	_expect(LOOM_TRUE["who"] != FERRY_TRUE["who"], "loom shuttle copied the ferry taker")
	_expect(LOOM_TRUE["place"] != FERRY_TRUE["place"], "loom shuttle copied the ferry room")
	_expect(LOOM_TRUE["hour"] != FERRY_TRUE["hour"], "loom shuttle copied the ferry hour")
	_expect(LOOM_TRUE["who"] != WEATHER_TRUE["who"], "loom shuttle copied the weather taker")
	_expect(LOOM_TRUE["place"] != WEATHER_TRUE["place"], "loom shuttle copied the weather room")
	_expect(LOOM_TRUE["hour"] != WEATHER_TRUE["hour"], "loom shuttle copied the weather hour")
	_expect_rejected(spare, Rehearsal)
	_expect_rejected(REHEARSAL_TRUE, CaseData)
	_expect_rejected(GILT_TRUE, CaseData)
	_expect_rejected(GILT_TRUE, Rehearsal)
	_expect_rejected(spare, Gilt)
	_expect_rejected(REHEARSAL_TRUE, Gilt)
	_expect_rejected(FERRY_TRUE, CaseData)
	_expect_rejected(FERRY_TRUE, Rehearsal)
	_expect_rejected(FERRY_TRUE, Gilt)
	_expect_rejected(spare, Ferry)
	_expect_rejected(REHEARSAL_TRUE, Ferry)
	_expect_rejected(GILT_TRUE, Ferry)
	_expect_rejected(WEATHER_TRUE, CaseData)
	_expect_rejected(WEATHER_TRUE, Rehearsal)
	_expect_rejected(WEATHER_TRUE, Gilt)
	_expect_rejected(WEATHER_TRUE, Ferry)
	_expect_rejected(spare, Weather)
	_expect_rejected(REHEARSAL_TRUE, Weather)
	_expect_rejected(GILT_TRUE, Weather)
	_expect_rejected(FERRY_TRUE, Weather)
	_expect_rejected(LOOM_TRUE, CaseData)
	_expect_rejected(LOOM_TRUE, Rehearsal)
	_expect_rejected(LOOM_TRUE, Gilt)
	_expect_rejected(LOOM_TRUE, Ferry)
	_expect_rejected(LOOM_TRUE, Weather)
	_expect_rejected(spare, Loom)
	_expect_rejected(REHEARSAL_TRUE, Loom)
	_expect_rejected(GILT_TRUE, Loom)
	_expect_rejected(FERRY_TRUE, Loom)
	_expect_rejected(WEATHER_TRUE, Loom)
	_expect_rejected(HIVE_TRUE, CaseData)
	_expect_rejected(HIVE_TRUE, Rehearsal)
	_expect_rejected(HIVE_TRUE, Gilt)
	_expect_rejected(HIVE_TRUE, Ferry)
	_expect_rejected(HIVE_TRUE, Weather)
	_expect_rejected(HIVE_TRUE, Loom)
	_expect_rejected(spare, Hive)
	_expect_rejected(REHEARSAL_TRUE, Hive)
	_expect_rejected(GILT_TRUE, Hive)
	_expect_rejected(FERRY_TRUE, Hive)
	_expect_rejected(WEATHER_TRUE, Hive)
	_expect_rejected(LOOM_TRUE, Hive)
	for person in Gilt.PEOPLE:
		_expect(not CaseData.PEOPLE.has(person), "gilt cast repeats %s from the spare key" % person)
		_expect(not Rehearsal.PEOPLE.has(person), "gilt cast repeats %s from the rehearsal score" % person)
	for place in Gilt.PLACES:
		_expect(not CaseData.PLACES.has(place), "gilt rooms repeat %s from the spare key" % place)
		_expect(not Rehearsal.PLACES.has(place), "gilt rooms repeat %s from the rehearsal score" % place)
	for hour in Gilt.HOURS:
		_expect(not CaseData.HOURS.has(hour), "gilt hours repeat %s from the spare key" % hour)
		_expect(not Rehearsal.HOURS.has(hour), "gilt hours repeat %s from the rehearsal score" % hour)
	for person in Ferry.PEOPLE:
		_expect(not CaseData.PEOPLE.has(person), "ferry cast repeats %s from the spare key" % person)
		_expect(not Rehearsal.PEOPLE.has(person), "ferry cast repeats %s from the rehearsal score" % person)
		_expect(not Gilt.PEOPLE.has(person), "ferry cast repeats %s from the gilt stamp" % person)
	for place in Ferry.PLACES:
		_expect(not CaseData.PLACES.has(place), "ferry rooms repeat %s from the spare key" % place)
		_expect(not Rehearsal.PLACES.has(place), "ferry rooms repeat %s from the rehearsal score" % place)
		_expect(not Gilt.PLACES.has(place), "ferry rooms repeat %s from the gilt stamp" % place)
	for hour in Ferry.HOURS:
		_expect(not CaseData.HOURS.has(hour), "ferry hours repeat %s from the spare key" % hour)
		_expect(not Rehearsal.HOURS.has(hour), "ferry hours repeat %s from the rehearsal score" % hour)
		_expect(not Gilt.HOURS.has(hour), "ferry hours repeat %s from the gilt stamp" % hour)
	for person in Weather.PEOPLE:
		_expect(not CaseData.PEOPLE.has(person), "weather cast repeats %s from the spare key" % person)
		_expect(not Rehearsal.PEOPLE.has(person), "weather cast repeats %s from the rehearsal score" % person)
		_expect(not Gilt.PEOPLE.has(person), "weather cast repeats %s from the gilt stamp" % person)
		_expect(not Ferry.PEOPLE.has(person), "weather cast repeats %s from the ferry bell" % person)
	for place in Weather.PLACES:
		_expect(not CaseData.PLACES.has(place), "weather rooms repeat %s from the spare key" % place)
		_expect(not Rehearsal.PLACES.has(place), "weather rooms repeat %s from the rehearsal score" % place)
		_expect(not Gilt.PLACES.has(place), "weather rooms repeat %s from the gilt stamp" % place)
		_expect(not Ferry.PLACES.has(place), "weather rooms repeat %s from the ferry bell" % place)
	for hour in Weather.HOURS:
		_expect(not CaseData.HOURS.has(hour), "weather hours repeat %s from the spare key" % hour)
		_expect(not Rehearsal.HOURS.has(hour), "weather hours repeat %s from the rehearsal score" % hour)
		_expect(not Gilt.HOURS.has(hour), "weather hours repeat %s from the gilt stamp" % hour)
		_expect(not Ferry.HOURS.has(hour), "weather hours repeat %s from the ferry bell" % hour)
	for person in Loom.PEOPLE:
		_expect(not CaseData.PEOPLE.has(person), "loom cast repeats %s from the spare key" % person)
		_expect(not Rehearsal.PEOPLE.has(person), "loom cast repeats %s from the rehearsal score" % person)
		_expect(not Gilt.PEOPLE.has(person), "loom cast repeats %s from the gilt stamp" % person)
		_expect(not Ferry.PEOPLE.has(person), "loom cast repeats %s from the ferry bell" % person)
		_expect(not Weather.PEOPLE.has(person), "loom cast repeats %s from the weather slate" % person)
	for place in Loom.PLACES:
		_expect(not CaseData.PLACES.has(place), "loom rooms repeat %s from the spare key" % place)
		_expect(not Rehearsal.PLACES.has(place), "loom rooms repeat %s from the rehearsal score" % place)
		_expect(not Gilt.PLACES.has(place), "loom rooms repeat %s from the gilt stamp" % place)
		_expect(not Ferry.PLACES.has(place), "loom rooms repeat %s from the ferry bell" % place)
		_expect(not Weather.PLACES.has(place), "loom rooms repeat %s from the weather slate" % place)
	for hour in Loom.HOURS:
		_expect(not CaseData.HOURS.has(hour), "loom hours repeat %s from the spare key" % hour)
		_expect(not Rehearsal.HOURS.has(hour), "loom hours repeat %s from the rehearsal score" % hour)
		_expect(not Gilt.HOURS.has(hour), "loom hours repeat %s from the gilt stamp" % hour)
		_expect(not Ferry.HOURS.has(hour), "loom hours repeat %s from the ferry bell" % hour)
		_expect(not Weather.HOURS.has(hour), "loom hours repeat %s from the weather slate" % hour)
	_expect(HIVE_TRUE["who"] != spare["who"], "hive smoker copied the spare-key taker")
	_expect(HIVE_TRUE["place"] != spare["place"], "hive smoker copied the spare-key room")
	_expect(HIVE_TRUE["hour"] != spare["hour"], "hive smoker copied the spare-key hour")
	_expect(HIVE_TRUE["who"] != REHEARSAL_TRUE["who"], "hive smoker copied the rehearsal taker")
	_expect(HIVE_TRUE["place"] != REHEARSAL_TRUE["place"], "hive smoker copied the rehearsal room")
	_expect(HIVE_TRUE["hour"] != REHEARSAL_TRUE["hour"], "hive smoker copied the rehearsal hour")
	_expect(HIVE_TRUE["who"] != GILT_TRUE["who"], "hive smoker copied the gilt taker")
	_expect(HIVE_TRUE["place"] != GILT_TRUE["place"], "hive smoker copied the gilt room")
	_expect(HIVE_TRUE["hour"] != GILT_TRUE["hour"], "hive smoker copied the gilt hour")
	_expect(HIVE_TRUE["who"] != FERRY_TRUE["who"], "hive smoker copied the ferry taker")
	_expect(HIVE_TRUE["place"] != FERRY_TRUE["place"], "hive smoker copied the ferry room")
	_expect(HIVE_TRUE["hour"] != FERRY_TRUE["hour"], "hive smoker copied the ferry hour")
	_expect(HIVE_TRUE["who"] != WEATHER_TRUE["who"], "hive smoker copied the weather taker")
	_expect(HIVE_TRUE["place"] != WEATHER_TRUE["place"], "hive smoker copied the weather room")
	_expect(HIVE_TRUE["hour"] != WEATHER_TRUE["hour"], "hive smoker copied the weather hour")
	_expect(HIVE_TRUE["who"] != LOOM_TRUE["who"], "hive smoker copied the loom taker")
	_expect(HIVE_TRUE["place"] != LOOM_TRUE["place"], "hive smoker copied the loom room")
	_expect(HIVE_TRUE["hour"] != LOOM_TRUE["hour"], "hive smoker copied the loom hour")
	for person in Hive.PEOPLE:
		_expect(not CaseData.PEOPLE.has(person), "hive cast repeats %s from the spare key" % person)
		_expect(not Rehearsal.PEOPLE.has(person), "hive cast repeats %s from the rehearsal score" % person)
		_expect(not Gilt.PEOPLE.has(person), "hive cast repeats %s from the gilt stamp" % person)
		_expect(not Ferry.PEOPLE.has(person), "hive cast repeats %s from the ferry bell" % person)
		_expect(not Weather.PEOPLE.has(person), "hive cast repeats %s from the weather slate" % person)
		_expect(not Loom.PEOPLE.has(person), "hive cast repeats %s from the loom shuttle" % person)
	for place in Hive.PLACES:
		_expect(not CaseData.PLACES.has(place), "hive rooms repeat %s from the spare key" % place)
		_expect(not Rehearsal.PLACES.has(place), "hive rooms repeat %s from the rehearsal score" % place)
		_expect(not Gilt.PLACES.has(place), "hive rooms repeat %s from the gilt stamp" % place)
		_expect(not Ferry.PLACES.has(place), "hive rooms repeat %s from the ferry bell" % place)
		_expect(not Weather.PLACES.has(place), "hive rooms repeat %s from the weather slate" % place)
		_expect(not Loom.PLACES.has(place), "hive rooms repeat %s from the loom shuttle" % place)
	for hour in Hive.HOURS:
		_expect(not CaseData.HOURS.has(hour), "hive hours repeat %s from the spare key" % hour)
		_expect(not Rehearsal.HOURS.has(hour), "hive hours repeat %s from the rehearsal score" % hour)
		_expect(not Gilt.HOURS.has(hour), "hive hours repeat %s from the gilt stamp" % hour)
		_expect(not Ferry.HOURS.has(hour), "hive hours repeat %s from the ferry bell" % hour)
		_expect(not Weather.HOURS.has(hour), "hive hours repeat %s from the weather slate" % hour)
		_expect(not Loom.HOURS.has(hour), "hive hours repeat %s from the loom shuttle" % hour)
	_expect(GLASS_TRUE["who"] != spare["who"], "glass pontil copied the spare-key taker")
	_expect(GLASS_TRUE["place"] != spare["place"], "glass pontil copied the spare-key room")
	_expect(GLASS_TRUE["hour"] != spare["hour"], "glass pontil copied the spare-key hour")
	_expect(GLASS_TRUE["who"] != REHEARSAL_TRUE["who"], "glass pontil copied the rehearsal taker")
	_expect(GLASS_TRUE["place"] != REHEARSAL_TRUE["place"], "glass pontil copied the rehearsal room")
	_expect(GLASS_TRUE["hour"] != REHEARSAL_TRUE["hour"], "glass pontil copied the rehearsal hour")
	_expect(GLASS_TRUE["who"] != GILT_TRUE["who"], "glass pontil copied the gilt taker")
	_expect(GLASS_TRUE["place"] != GILT_TRUE["place"], "glass pontil copied the gilt room")
	_expect(GLASS_TRUE["hour"] != GILT_TRUE["hour"], "glass pontil copied the gilt hour")
	_expect(GLASS_TRUE["who"] != FERRY_TRUE["who"], "glass pontil copied the ferry taker")
	_expect(GLASS_TRUE["place"] != FERRY_TRUE["place"], "glass pontil copied the ferry room")
	_expect(GLASS_TRUE["hour"] != FERRY_TRUE["hour"], "glass pontil copied the ferry hour")
	_expect(GLASS_TRUE["who"] != WEATHER_TRUE["who"], "glass pontil copied the weather taker")
	_expect(GLASS_TRUE["place"] != WEATHER_TRUE["place"], "glass pontil copied the weather room")
	_expect(GLASS_TRUE["hour"] != WEATHER_TRUE["hour"], "glass pontil copied the weather hour")
	_expect(GLASS_TRUE["who"] != LOOM_TRUE["who"], "glass pontil copied the loom taker")
	_expect(GLASS_TRUE["place"] != LOOM_TRUE["place"], "glass pontil copied the loom room")
	_expect(GLASS_TRUE["hour"] != LOOM_TRUE["hour"], "glass pontil copied the loom hour")
	_expect(GLASS_TRUE["who"] != HIVE_TRUE["who"], "glass pontil copied the hive taker")
	_expect(GLASS_TRUE["place"] != HIVE_TRUE["place"], "glass pontil copied the hive room")
	_expect(GLASS_TRUE["hour"] != HIVE_TRUE["hour"], "glass pontil copied the hive hour")
	_expect_rejected(GLASS_TRUE, CaseData)
	_expect_rejected(GLASS_TRUE, Rehearsal)
	_expect_rejected(GLASS_TRUE, Gilt)
	_expect_rejected(GLASS_TRUE, Ferry)
	_expect_rejected(GLASS_TRUE, Weather)
	_expect_rejected(GLASS_TRUE, Loom)
	_expect_rejected(GLASS_TRUE, Hive)
	_expect_rejected(spare, Glass)
	_expect_rejected(REHEARSAL_TRUE, Glass)
	_expect_rejected(GILT_TRUE, Glass)
	_expect_rejected(FERRY_TRUE, Glass)
	_expect_rejected(WEATHER_TRUE, Glass)
	_expect_rejected(LOOM_TRUE, Glass)
	_expect_rejected(HIVE_TRUE, Glass)
	for person in Glass.PEOPLE:
		_expect(not CaseData.PEOPLE.has(person), "glass cast repeats %s from the spare key" % person)
		_expect(not Rehearsal.PEOPLE.has(person), "glass cast repeats %s from the rehearsal score" % person)
		_expect(not Gilt.PEOPLE.has(person), "glass cast repeats %s from the gilt stamp" % person)
		_expect(not Ferry.PEOPLE.has(person), "glass cast repeats %s from the ferry bell" % person)
		_expect(not Weather.PEOPLE.has(person), "glass cast repeats %s from the weather slate" % person)
		_expect(not Loom.PEOPLE.has(person), "glass cast repeats %s from the loom shuttle" % person)
		_expect(not Hive.PEOPLE.has(person), "glass cast repeats %s from the hive smoker" % person)
	for place in Glass.PLACES:
		_expect(not CaseData.PLACES.has(place), "glass rooms repeat %s from the spare key" % place)
		_expect(not Rehearsal.PLACES.has(place), "glass rooms repeat %s from the rehearsal score" % place)
		_expect(not Gilt.PLACES.has(place), "glass rooms repeat %s from the gilt stamp" % place)
		_expect(not Ferry.PLACES.has(place), "glass rooms repeat %s from the ferry bell" % place)
		_expect(not Weather.PLACES.has(place), "glass rooms repeat %s from the weather slate" % place)
		_expect(not Loom.PLACES.has(place), "glass rooms repeat %s from the loom shuttle" % place)
		_expect(not Hive.PLACES.has(place), "glass rooms repeat %s from the hive smoker" % place)
	for hour in Glass.HOURS:
		_expect(not CaseData.HOURS.has(hour), "glass hours repeat %s from the spare key" % hour)
		_expect(not Rehearsal.HOURS.has(hour), "glass hours repeat %s from the rehearsal score" % hour)
		_expect(not Gilt.HOURS.has(hour), "glass hours repeat %s from the gilt stamp" % hour)
		_expect(not Ferry.HOURS.has(hour), "glass hours repeat %s from the ferry bell" % hour)
		_expect(not Weather.HOURS.has(hour), "glass hours repeat %s from the weather slate" % hour)
		_expect(not Loom.HOURS.has(hour), "glass hours repeat %s from the loom shuttle" % hour)
		_expect(not Hive.HOURS.has(hour), "glass hours repeat %s from the hive smoker" % hour)
	_expect(PRESS_TRUE["who"] != spare["who"], "press proof copied the spare-key taker")
	_expect(PRESS_TRUE["place"] != spare["place"], "press proof copied the spare-key room")
	_expect(PRESS_TRUE["hour"] != spare["hour"], "press proof copied the spare-key hour")
	_expect(PRESS_TRUE["who"] != REHEARSAL_TRUE["who"], "press proof copied the rehearsal taker")
	_expect(PRESS_TRUE["place"] != REHEARSAL_TRUE["place"], "press proof copied the rehearsal room")
	_expect(PRESS_TRUE["hour"] != REHEARSAL_TRUE["hour"], "press proof copied the rehearsal hour")
	_expect(PRESS_TRUE["who"] != GILT_TRUE["who"], "press proof copied the gilt taker")
	_expect(PRESS_TRUE["place"] != GILT_TRUE["place"], "press proof copied the gilt room")
	_expect(PRESS_TRUE["hour"] != GILT_TRUE["hour"], "press proof copied the gilt hour")
	_expect(PRESS_TRUE["who"] != FERRY_TRUE["who"], "press proof copied the ferry taker")
	_expect(PRESS_TRUE["place"] != FERRY_TRUE["place"], "press proof copied the ferry room")
	_expect(PRESS_TRUE["hour"] != FERRY_TRUE["hour"], "press proof copied the ferry hour")
	_expect(PRESS_TRUE["who"] != WEATHER_TRUE["who"], "press proof copied the weather taker")
	_expect(PRESS_TRUE["place"] != WEATHER_TRUE["place"], "press proof copied the weather room")
	_expect(PRESS_TRUE["hour"] != WEATHER_TRUE["hour"], "press proof copied the weather hour")
	_expect(PRESS_TRUE["who"] != LOOM_TRUE["who"], "press proof copied the loom taker")
	_expect(PRESS_TRUE["place"] != LOOM_TRUE["place"], "press proof copied the loom room")
	_expect(PRESS_TRUE["hour"] != LOOM_TRUE["hour"], "press proof copied the loom hour")
	_expect(PRESS_TRUE["who"] != HIVE_TRUE["who"], "press proof copied the hive taker")
	_expect(PRESS_TRUE["place"] != HIVE_TRUE["place"], "press proof copied the hive room")
	_expect(PRESS_TRUE["hour"] != HIVE_TRUE["hour"], "press proof copied the hive hour")
	_expect(PRESS_TRUE["who"] != GLASS_TRUE["who"], "press proof copied the glass taker")
	_expect(PRESS_TRUE["place"] != GLASS_TRUE["place"], "press proof copied the glass room")
	_expect(PRESS_TRUE["hour"] != GLASS_TRUE["hour"], "press proof copied the glass hour")
	_expect_rejected(PRESS_TRUE, CaseData)
	_expect_rejected(PRESS_TRUE, Rehearsal)
	_expect_rejected(PRESS_TRUE, Gilt)
	_expect_rejected(PRESS_TRUE, Ferry)
	_expect_rejected(PRESS_TRUE, Weather)
	_expect_rejected(PRESS_TRUE, Loom)
	_expect_rejected(PRESS_TRUE, Hive)
	_expect_rejected(PRESS_TRUE, Glass)
	_expect_rejected(spare, Press)
	_expect_rejected(REHEARSAL_TRUE, Press)
	_expect_rejected(GILT_TRUE, Press)
	_expect_rejected(FERRY_TRUE, Press)
	_expect_rejected(WEATHER_TRUE, Press)
	_expect_rejected(LOOM_TRUE, Press)
	_expect_rejected(HIVE_TRUE, Press)
	_expect_rejected(GLASS_TRUE, Press)
	for person in Press.PEOPLE:
		_expect(not CaseData.PEOPLE.has(person), "press cast repeats %s from the spare key" % person)
		_expect(not Rehearsal.PEOPLE.has(person), "press cast repeats %s from the rehearsal score" % person)
		_expect(not Gilt.PEOPLE.has(person), "press cast repeats %s from the gilt stamp" % person)
		_expect(not Ferry.PEOPLE.has(person), "press cast repeats %s from the ferry bell" % person)
		_expect(not Weather.PEOPLE.has(person), "press cast repeats %s from the weather slate" % person)
		_expect(not Loom.PEOPLE.has(person), "press cast repeats %s from the loom shuttle" % person)
		_expect(not Hive.PEOPLE.has(person), "press cast repeats %s from the hive smoker" % person)
		_expect(not Glass.PEOPLE.has(person), "press cast repeats %s from the glass pontil" % person)
	for place in Press.PLACES:
		_expect(not CaseData.PLACES.has(place), "press rooms repeat %s from the spare key" % place)
		_expect(not Rehearsal.PLACES.has(place), "press rooms repeat %s from the rehearsal score" % place)
		_expect(not Gilt.PLACES.has(place), "press rooms repeat %s from the gilt stamp" % place)
		_expect(not Ferry.PLACES.has(place), "press rooms repeat %s from the ferry bell" % place)
		_expect(not Weather.PLACES.has(place), "press rooms repeat %s from the weather slate" % place)
		_expect(not Loom.PLACES.has(place), "press rooms repeat %s from the loom shuttle" % place)
		_expect(not Hive.PLACES.has(place), "press rooms repeat %s from the hive smoker" % place)
		_expect(not Glass.PLACES.has(place), "press rooms repeat %s from the glass pontil" % place)
	for hour in Press.HOURS:
		_expect(not CaseData.HOURS.has(hour), "press hours repeat %s from the spare key" % hour)
		_expect(not Rehearsal.HOURS.has(hour), "press hours repeat %s from the rehearsal score" % hour)
		_expect(not Gilt.HOURS.has(hour), "press hours repeat %s from the gilt stamp" % hour)
		_expect(not Ferry.HOURS.has(hour), "press hours repeat %s from the ferry bell" % hour)
		_expect(not Weather.HOURS.has(hour), "press hours repeat %s from the weather slate" % hour)
		_expect(not Loom.HOURS.has(hour), "press hours repeat %s from the loom shuttle" % hour)
		_expect(not Hive.HOURS.has(hour), "press hours repeat %s from the hive smoker" % hour)
		_expect(not Glass.HOURS.has(hour), "press hours repeat %s from the glass pontil" % hour)
	_expect(ASSAY_TRUE["who"] != spare["who"], "assay cup copied the spare-key taker")
	_expect(ASSAY_TRUE["place"] != spare["place"], "assay cup copied the spare-key room")
	_expect(ASSAY_TRUE["hour"] != spare["hour"], "assay cup copied the spare-key hour")
	_expect(ASSAY_TRUE["who"] != REHEARSAL_TRUE["who"], "assay cup copied the rehearsal taker")
	_expect(ASSAY_TRUE["place"] != REHEARSAL_TRUE["place"], "assay cup copied the rehearsal room")
	_expect(ASSAY_TRUE["hour"] != REHEARSAL_TRUE["hour"], "assay cup copied the rehearsal hour")
	_expect(ASSAY_TRUE["who"] != GILT_TRUE["who"], "assay cup copied the gilt taker")
	_expect(ASSAY_TRUE["place"] != GILT_TRUE["place"], "assay cup copied the gilt room")
	_expect(ASSAY_TRUE["hour"] != GILT_TRUE["hour"], "assay cup copied the gilt hour")
	_expect(ASSAY_TRUE["who"] != FERRY_TRUE["who"], "assay cup copied the ferry taker")
	_expect(ASSAY_TRUE["place"] != FERRY_TRUE["place"], "assay cup copied the ferry room")
	_expect(ASSAY_TRUE["hour"] != FERRY_TRUE["hour"], "assay cup copied the ferry hour")
	_expect(ASSAY_TRUE["who"] != WEATHER_TRUE["who"], "assay cup copied the weather taker")
	_expect(ASSAY_TRUE["place"] != WEATHER_TRUE["place"], "assay cup copied the weather room")
	_expect(ASSAY_TRUE["hour"] != WEATHER_TRUE["hour"], "assay cup copied the weather hour")
	_expect(ASSAY_TRUE["who"] != LOOM_TRUE["who"], "assay cup copied the loom taker")
	_expect(ASSAY_TRUE["place"] != LOOM_TRUE["place"], "assay cup copied the loom room")
	_expect(ASSAY_TRUE["hour"] != LOOM_TRUE["hour"], "assay cup copied the loom hour")
	_expect(ASSAY_TRUE["who"] != HIVE_TRUE["who"], "assay cup copied the hive taker")
	_expect(ASSAY_TRUE["place"] != HIVE_TRUE["place"], "assay cup copied the hive room")
	_expect(ASSAY_TRUE["hour"] != HIVE_TRUE["hour"], "assay cup copied the hive hour")
	_expect(ASSAY_TRUE["who"] != GLASS_TRUE["who"], "assay cup copied the glass taker")
	_expect(ASSAY_TRUE["place"] != GLASS_TRUE["place"], "assay cup copied the glass room")
	_expect(ASSAY_TRUE["hour"] != GLASS_TRUE["hour"], "assay cup copied the glass hour")
	_expect(ASSAY_TRUE["who"] != PRESS_TRUE["who"], "assay cup copied the press taker")
	_expect(ASSAY_TRUE["place"] != PRESS_TRUE["place"], "assay cup copied the press room")
	_expect(ASSAY_TRUE["hour"] != PRESS_TRUE["hour"], "assay cup copied the press hour")
	_expect_rejected(ASSAY_TRUE, CaseData)
	_expect_rejected(ASSAY_TRUE, Rehearsal)
	_expect_rejected(ASSAY_TRUE, Gilt)
	_expect_rejected(ASSAY_TRUE, Ferry)
	_expect_rejected(ASSAY_TRUE, Weather)
	_expect_rejected(ASSAY_TRUE, Loom)
	_expect_rejected(ASSAY_TRUE, Hive)
	_expect_rejected(ASSAY_TRUE, Glass)
	_expect_rejected(ASSAY_TRUE, Press)
	_expect_rejected(spare, Assay)
	_expect_rejected(REHEARSAL_TRUE, Assay)
	_expect_rejected(GILT_TRUE, Assay)
	_expect_rejected(FERRY_TRUE, Assay)
	_expect_rejected(WEATHER_TRUE, Assay)
	_expect_rejected(LOOM_TRUE, Assay)
	_expect_rejected(HIVE_TRUE, Assay)
	_expect_rejected(GLASS_TRUE, Assay)
	_expect_rejected(PRESS_TRUE, Assay)
	for person in Assay.PEOPLE:
		_expect(not CaseData.PEOPLE.has(person), "assay cast repeats %s from the spare key" % person)
		_expect(not Rehearsal.PEOPLE.has(person), "assay cast repeats %s from the rehearsal score" % person)
		_expect(not Gilt.PEOPLE.has(person), "assay cast repeats %s from the gilt stamp" % person)
		_expect(not Ferry.PEOPLE.has(person), "assay cast repeats %s from the ferry bell" % person)
		_expect(not Weather.PEOPLE.has(person), "assay cast repeats %s from the weather slate" % person)
		_expect(not Loom.PEOPLE.has(person), "assay cast repeats %s from the loom shuttle" % person)
		_expect(not Hive.PEOPLE.has(person), "assay cast repeats %s from the hive smoker" % person)
		_expect(not Glass.PEOPLE.has(person), "assay cast repeats %s from the glass pontil" % person)
		_expect(not Press.PEOPLE.has(person), "assay cast repeats %s from the press proof" % person)
	for place in Assay.PLACES:
		_expect(not CaseData.PLACES.has(place), "assay rooms repeat %s from the spare key" % place)
		_expect(not Rehearsal.PLACES.has(place), "assay rooms repeat %s from the rehearsal score" % place)
		_expect(not Gilt.PLACES.has(place), "assay rooms repeat %s from the gilt stamp" % place)
		_expect(not Ferry.PLACES.has(place), "assay rooms repeat %s from the ferry bell" % place)
		_expect(not Weather.PLACES.has(place), "assay rooms repeat %s from the weather slate" % place)
		_expect(not Loom.PLACES.has(place), "assay rooms repeat %s from the loom shuttle" % place)
		_expect(not Hive.PLACES.has(place), "assay rooms repeat %s from the hive smoker" % place)
		_expect(not Glass.PLACES.has(place), "assay rooms repeat %s from the glass pontil" % place)
		_expect(not Press.PLACES.has(place), "assay rooms repeat %s from the press proof" % place)
	for hour in Assay.HOURS:
		_expect(not CaseData.HOURS.has(hour), "assay hours repeat %s from the spare key" % hour)
		_expect(not Rehearsal.HOURS.has(hour), "assay hours repeat %s from the rehearsal score" % hour)
		_expect(not Gilt.HOURS.has(hour), "assay hours repeat %s from the gilt stamp" % hour)
		_expect(not Weather.HOURS.has(hour), "assay hours repeat %s from the weather slate" % hour)
		_expect(not Hive.HOURS.has(hour), "assay hours repeat %s from the hive smoker" % hour)
		_expect(not Glass.HOURS.has(hour), "assay hours repeat %s from the glass pontil" % hour)
		_expect(not Press.HOURS.has(hour), "assay hours repeat %s from the press proof" % hour)
	_expect(KILN_TRUE["who"] != spare["who"], "kiln chalk copied the spare-key taker")
	_expect(KILN_TRUE["place"] != spare["place"], "kiln chalk copied the spare-key room")
	_expect(KILN_TRUE["hour"] != spare["hour"], "kiln chalk copied the spare-key hour")
	_expect(KILN_TRUE["who"] != REHEARSAL_TRUE["who"], "kiln chalk copied the rehearsal taker")
	_expect(KILN_TRUE["place"] != REHEARSAL_TRUE["place"], "kiln chalk copied the rehearsal room")
	_expect(KILN_TRUE["hour"] != REHEARSAL_TRUE["hour"], "kiln chalk copied the rehearsal hour")
	_expect(KILN_TRUE["who"] != GILT_TRUE["who"], "kiln chalk copied the gilt taker")
	_expect(KILN_TRUE["place"] != GILT_TRUE["place"], "kiln chalk copied the gilt room")
	_expect(KILN_TRUE["hour"] != GILT_TRUE["hour"], "kiln chalk copied the gilt hour")
	_expect(KILN_TRUE["who"] != FERRY_TRUE["who"], "kiln chalk copied the ferry taker")
	_expect(KILN_TRUE["place"] != FERRY_TRUE["place"], "kiln chalk copied the ferry room")
	_expect(KILN_TRUE["hour"] != FERRY_TRUE["hour"], "kiln chalk copied the ferry hour")
	_expect(KILN_TRUE["who"] != WEATHER_TRUE["who"], "kiln chalk copied the weather taker")
	_expect(KILN_TRUE["place"] != WEATHER_TRUE["place"], "kiln chalk copied the weather room")
	_expect(KILN_TRUE["hour"] != WEATHER_TRUE["hour"], "kiln chalk copied the weather hour")
	_expect(KILN_TRUE["who"] != LOOM_TRUE["who"], "kiln chalk copied the loom taker")
	_expect(KILN_TRUE["place"] != LOOM_TRUE["place"], "kiln chalk copied the loom room")
	_expect(KILN_TRUE["hour"] != LOOM_TRUE["hour"], "kiln chalk copied the loom hour")
	_expect(KILN_TRUE["who"] != HIVE_TRUE["who"], "kiln chalk copied the hive taker")
	_expect(KILN_TRUE["place"] != HIVE_TRUE["place"], "kiln chalk copied the hive room")
	_expect(KILN_TRUE["hour"] != HIVE_TRUE["hour"], "kiln chalk copied the hive hour")
	_expect(KILN_TRUE["who"] != GLASS_TRUE["who"], "kiln chalk copied the glass taker")
	_expect(KILN_TRUE["place"] != GLASS_TRUE["place"], "kiln chalk copied the glass room")
	_expect(KILN_TRUE["hour"] != GLASS_TRUE["hour"], "kiln chalk copied the glass hour")
	_expect(KILN_TRUE["who"] != PRESS_TRUE["who"], "kiln chalk copied the press taker")
	_expect(KILN_TRUE["place"] != PRESS_TRUE["place"], "kiln chalk copied the press room")
	_expect(KILN_TRUE["hour"] != PRESS_TRUE["hour"], "kiln chalk copied the press hour")
	_expect(KILN_TRUE["who"] != ASSAY_TRUE["who"], "kiln chalk copied the assay taker")
	_expect(KILN_TRUE["place"] != ASSAY_TRUE["place"], "kiln chalk copied the assay room")
	_expect(KILN_TRUE["hour"] != ASSAY_TRUE["hour"], "kiln chalk copied the assay hour")
	_expect_rejected(KILN_TRUE, CaseData)
	_expect_rejected(KILN_TRUE, Rehearsal)
	_expect_rejected(KILN_TRUE, Gilt)
	_expect_rejected(KILN_TRUE, Ferry)
	_expect_rejected(KILN_TRUE, Weather)
	_expect_rejected(KILN_TRUE, Loom)
	_expect_rejected(KILN_TRUE, Hive)
	_expect_rejected(KILN_TRUE, Glass)
	_expect_rejected(KILN_TRUE, Press)
	_expect_rejected(KILN_TRUE, Assay)
	_expect_rejected(spare, Kiln)
	_expect_rejected(REHEARSAL_TRUE, Kiln)
	_expect_rejected(GILT_TRUE, Kiln)
	_expect_rejected(FERRY_TRUE, Kiln)
	_expect_rejected(WEATHER_TRUE, Kiln)
	_expect_rejected(LOOM_TRUE, Kiln)
	_expect_rejected(HIVE_TRUE, Kiln)
	_expect_rejected(GLASS_TRUE, Kiln)
	_expect_rejected(PRESS_TRUE, Kiln)
	_expect_rejected(ASSAY_TRUE, Kiln)
	for person in Kiln.PEOPLE:
		_expect(not CaseData.PEOPLE.has(person), "kiln cast repeats %s from the spare key" % person)
		_expect(not Rehearsal.PEOPLE.has(person), "kiln cast repeats %s from the rehearsal score" % person)
		_expect(not Gilt.PEOPLE.has(person), "kiln cast repeats %s from the gilt stamp" % person)
		_expect(not Weather.PEOPLE.has(person), "kiln cast repeats %s from the weather slate" % person)
		_expect(not Loom.PEOPLE.has(person), "kiln cast repeats %s from the loom shuttle" % person)
		_expect(not Hive.PEOPLE.has(person), "kiln cast repeats %s from the hive smoker" % person)
		_expect(not Glass.PEOPLE.has(person), "kiln cast repeats %s from the glass pontil" % person)
		_expect(not Press.PEOPLE.has(person), "kiln cast repeats %s from the press proof" % person)
		_expect(not Assay.PEOPLE.has(person), "kiln cast repeats %s from the assay cup" % person)
		if person != "Wren":
			_expect(not Ferry.PEOPLE.has(person), "kiln cast repeats %s from the ferry bell" % person)
	_expect(Ferry.PEOPLE.has("Wren"), "the ferry bell should still name Wren the pilot")
	for place in Kiln.PLACES:
		_expect(not CaseData.PLACES.has(place), "kiln rooms repeat %s from the spare key" % place)
		_expect(not Rehearsal.PLACES.has(place), "kiln rooms repeat %s from the rehearsal score" % place)
		_expect(not Gilt.PLACES.has(place), "kiln rooms repeat %s from the gilt stamp" % place)
		_expect(not Ferry.PLACES.has(place), "kiln rooms repeat %s from the ferry bell" % place)
		_expect(not Weather.PLACES.has(place), "kiln rooms repeat %s from the weather slate" % place)
		_expect(not Loom.PLACES.has(place), "kiln rooms repeat %s from the loom shuttle" % place)
		_expect(not Hive.PLACES.has(place), "kiln rooms repeat %s from the hive smoker" % place)
		_expect(not Glass.PLACES.has(place), "kiln rooms repeat %s from the glass pontil" % place)
		_expect(not Press.PLACES.has(place), "kiln rooms repeat %s from the press proof" % place)
		_expect(not Assay.PLACES.has(place), "kiln rooms repeat %s from the assay cup" % place)
	for hour in Kiln.HOURS:
		_expect(not CaseData.HOURS.has(hour), "kiln hours repeat %s from the spare key" % hour)
		_expect(not Rehearsal.HOURS.has(hour), "kiln hours repeat %s from the rehearsal score" % hour)
		_expect(not Gilt.HOURS.has(hour), "kiln hours repeat %s from the gilt stamp" % hour)
		_expect(not Ferry.HOURS.has(hour), "kiln hours repeat %s from the ferry bell" % hour)
		_expect(not Weather.HOURS.has(hour), "kiln hours repeat %s from the weather slate" % hour)
		_expect(not Loom.HOURS.has(hour), "kiln hours repeat %s from the loom shuttle" % hour)
		_expect(not Hive.HOURS.has(hour), "kiln hours repeat %s from the hive smoker" % hour)
		_expect(not Glass.HOURS.has(hour), "kiln hours repeat %s from the glass pontil" % hour)
		_expect(not Press.HOURS.has(hour), "kiln hours repeat %s from the press proof" % hour)
		_expect(not Assay.HOURS.has(hour), "kiln hours repeat %s from the assay cup" % hour)
	_expect(TIDE_TRUE["who"] == "Moss", "tide ledger taker")
	_expect(TIDE_TRUE["place"] == "quay", "tide ledger room")
	_expect(TIDE_TRUE["hour"] == "33", "tide ledger hour")
	_expect(TIDE_TRUE["who"] != "Wren", "tide ledger accepted Wren")
	_expect(TIDE_TRUE["who"] != spare["who"], "tide ledger copied the spare-key taker")
	_expect(TIDE_TRUE["place"] != spare["place"], "tide ledger copied the spare-key room")
	_expect(TIDE_TRUE["hour"] != spare["hour"], "tide ledger copied the spare-key hour")
	_expect(TIDE_TRUE["who"] != REHEARSAL_TRUE["who"], "tide ledger copied the rehearsal taker")
	_expect(TIDE_TRUE["place"] != REHEARSAL_TRUE["place"], "tide ledger copied the rehearsal room")
	_expect(TIDE_TRUE["hour"] != REHEARSAL_TRUE["hour"], "tide ledger copied the rehearsal hour")
	_expect(TIDE_TRUE["who"] != GILT_TRUE["who"], "tide ledger copied the gilt taker")
	_expect(TIDE_TRUE["place"] != GILT_TRUE["place"], "tide ledger copied the gilt room")
	_expect(TIDE_TRUE["hour"] != GILT_TRUE["hour"], "tide ledger copied the gilt hour")
	_expect(TIDE_TRUE["who"] != FERRY_TRUE["who"], "tide ledger copied the ferry taker")
	_expect(TIDE_TRUE["place"] != FERRY_TRUE["place"], "tide ledger copied the ferry room")
	_expect(TIDE_TRUE["hour"] != FERRY_TRUE["hour"], "tide ledger copied the ferry hour")
	_expect(TIDE_TRUE["who"] != WEATHER_TRUE["who"], "tide ledger copied the weather taker")
	_expect(TIDE_TRUE["place"] != WEATHER_TRUE["place"], "tide ledger copied the weather room")
	_expect(TIDE_TRUE["hour"] != WEATHER_TRUE["hour"], "tide ledger copied the weather hour")
	_expect(TIDE_TRUE["who"] != LOOM_TRUE["who"], "tide ledger copied the loom taker")
	_expect(TIDE_TRUE["place"] != LOOM_TRUE["place"], "tide ledger copied the loom room")
	_expect(TIDE_TRUE["hour"] != LOOM_TRUE["hour"], "tide ledger copied the loom hour")
	_expect(TIDE_TRUE["who"] != HIVE_TRUE["who"], "tide ledger copied the hive taker")
	_expect(TIDE_TRUE["place"] != HIVE_TRUE["place"], "tide ledger copied the hive room")
	_expect(TIDE_TRUE["hour"] != HIVE_TRUE["hour"], "tide ledger copied the hive hour")
	_expect(TIDE_TRUE["who"] != GLASS_TRUE["who"], "tide ledger copied the glass taker")
	_expect(TIDE_TRUE["place"] != GLASS_TRUE["place"], "tide ledger copied the glass room")
	_expect(TIDE_TRUE["hour"] != GLASS_TRUE["hour"], "tide ledger copied the glass hour")
	_expect(TIDE_TRUE["who"] != PRESS_TRUE["who"], "tide ledger copied the press taker")
	_expect(TIDE_TRUE["place"] != PRESS_TRUE["place"], "tide ledger copied the press room")
	_expect(TIDE_TRUE["hour"] != PRESS_TRUE["hour"], "tide ledger copied the press hour")
	_expect(TIDE_TRUE["who"] != ASSAY_TRUE["who"], "tide ledger copied the assay taker")
	_expect(TIDE_TRUE["place"] != ASSAY_TRUE["place"], "tide ledger copied the assay room")
	_expect(TIDE_TRUE["hour"] != ASSAY_TRUE["hour"], "tide ledger copied the assay hour")
	_expect(TIDE_TRUE["who"] != KILN_TRUE["who"], "tide ledger copied the kiln taker")
	_expect(TIDE_TRUE["place"] != KILN_TRUE["place"], "tide ledger copied the kiln room")
	_expect(TIDE_TRUE["hour"] != KILN_TRUE["hour"], "tide ledger copied the kiln hour")
	_expect_rejected(TIDE_TRUE, CaseData)
	_expect_rejected(TIDE_TRUE, Rehearsal)
	_expect_rejected(TIDE_TRUE, Gilt)
	_expect_rejected(TIDE_TRUE, Ferry)
	_expect_rejected(TIDE_TRUE, Weather)
	_expect_rejected(TIDE_TRUE, Loom)
	_expect_rejected(TIDE_TRUE, Hive)
	_expect_rejected(TIDE_TRUE, Glass)
	_expect_rejected(TIDE_TRUE, Press)
	_expect_rejected(TIDE_TRUE, Assay)
	_expect_rejected(TIDE_TRUE, Kiln)
	_expect_rejected(spare, Tide)
	_expect_rejected(REHEARSAL_TRUE, Tide)
	_expect_rejected(GILT_TRUE, Tide)
	_expect_rejected(FERRY_TRUE, Tide)
	_expect_rejected(WEATHER_TRUE, Tide)
	_expect_rejected(LOOM_TRUE, Tide)
	_expect_rejected(HIVE_TRUE, Tide)
	_expect_rejected(GLASS_TRUE, Tide)
	_expect_rejected(PRESS_TRUE, Tide)
	_expect_rejected(ASSAY_TRUE, Tide)
	_expect_rejected(KILN_TRUE, Tide)
	for person in Tide.PEOPLE:
		if person == "Moss":
			_expect(CaseData.PEOPLE.has(person), "the spare key should still name Moss")
		else:
			_expect(not CaseData.PEOPLE.has(person), "tide cast repeats %s from the spare key" % person)
		_expect(not Rehearsal.PEOPLE.has(person), "tide cast repeats %s from the rehearsal score" % person)
		_expect(not Gilt.PEOPLE.has(person), "tide cast repeats %s from the gilt stamp" % person)
		_expect(not Ferry.PEOPLE.has(person), "tide cast repeats %s from the ferry bell" % person)
		_expect(not Weather.PEOPLE.has(person), "tide cast repeats %s from the weather slate" % person)
		_expect(not Loom.PEOPLE.has(person), "tide cast repeats %s from the loom shuttle" % person)
		_expect(not Hive.PEOPLE.has(person), "tide cast repeats %s from the hive smoker" % person)
		_expect(not Glass.PEOPLE.has(person), "tide cast repeats %s from the glass pontil" % person)
		_expect(not Press.PEOPLE.has(person), "tide cast repeats %s from the press proof" % person)
		_expect(not Assay.PEOPLE.has(person), "tide cast repeats %s from the assay cup" % person)
		_expect(not Kiln.PEOPLE.has(person), "tide cast repeats %s from the kiln chalk" % person)
	_expect(not Tide.PEOPLE.has("Wren"), "tide ledger cast must not take Wren")
	_expect(Ferry.PEOPLE.has("Wren"), "the ferry bell should still name Wren the pilot")
	_expect(Ferry.role_phrase("Wren") == "the pilot", "the ferry bell should still call Wren the pilot")
	for place in Tide.PLACES:
		_expect(not CaseData.PLACES.has(place), "tide rooms repeat %s from the spare key" % place)
		_expect(not Rehearsal.PLACES.has(place), "tide rooms repeat %s from the rehearsal score" % place)
		_expect(not Gilt.PLACES.has(place), "tide rooms repeat %s from the gilt stamp" % place)
		_expect(not Ferry.PLACES.has(place), "tide rooms repeat %s from the ferry bell" % place)
		_expect(not Weather.PLACES.has(place), "tide rooms repeat %s from the weather slate" % place)
		_expect(not Loom.PLACES.has(place), "tide rooms repeat %s from the loom shuttle" % place)
		_expect(not Hive.PLACES.has(place), "tide rooms repeat %s from the hive smoker" % place)
		_expect(not Glass.PLACES.has(place), "tide rooms repeat %s from the glass pontil" % place)
		_expect(not Press.PLACES.has(place), "tide rooms repeat %s from the press proof" % place)
		_expect(not Assay.PLACES.has(place), "tide rooms repeat %s from the assay cup" % place)
		_expect(not Kiln.PLACES.has(place), "tide rooms repeat %s from the kiln chalk" % place)
	for hour in Tide.HOURS:
		_expect(not CaseData.HOURS.has(hour), "tide hours repeat %s from the spare key" % hour)
		_expect(not Rehearsal.HOURS.has(hour), "tide hours repeat %s from the rehearsal score" % hour)
		_expect(not Gilt.HOURS.has(hour), "tide hours repeat %s from the gilt stamp" % hour)
		_expect(not Ferry.HOURS.has(hour), "tide hours repeat %s from the ferry bell" % hour)
		_expect(not Weather.HOURS.has(hour), "tide hours repeat %s from the weather slate" % hour)
		_expect(not Loom.HOURS.has(hour), "tide hours repeat %s from the loom shuttle" % hour)
		_expect(not Hive.HOURS.has(hour), "tide hours repeat %s from the hive smoker" % hour)
		_expect(not Glass.HOURS.has(hour), "tide hours repeat %s from the glass pontil" % hour)
		_expect(not Press.HOURS.has(hour), "tide hours repeat %s from the press proof" % hour)
		_expect(not Assay.HOURS.has(hour), "tide hours repeat %s from the assay cup" % hour)
		_expect(not Kiln.HOURS.has(hour), "tide hours repeat %s from the kiln chalk" % hour)
	_expect(NIGHT_TRUE["who"] == "Vesper", "night bell taker")
	_expect(NIGHT_TRUE["place"] == "tower", "night bell room")
	_expect(NIGHT_TRUE["hour"] == "44", "night bell hour")
	_expect(NIGHT_TRUE["who"] != "Moss", "night bell accepted Moss")
	_expect(NIGHT_TRUE["who"] != "Pell", "night bell accepted Pell")
	_expect(NIGHT_TRUE["who"] != "Wren", "night bell accepted Wren")
	_expect(NIGHT_TRUE["who"] != "Quill", "night bell accepted Quill")
	_expect(NIGHT_TRUE["who"] != "Lark", "night bell accepted Lark")
	_expect(NIGHT_TRUE["who"] != "Nim", "night bell accepted Nim")
	_expect(NIGHT_TRUE["who"] != "Sable", "night bell accepted Sable")
	_expect(NIGHT_TRUE["who"] != spare["who"], "night bell copied the spare-key taker")
	_expect(NIGHT_TRUE["place"] != spare["place"], "night bell copied the spare-key room")
	_expect(NIGHT_TRUE["hour"] != spare["hour"], "night bell copied the spare-key hour")
	_expect(NIGHT_TRUE["who"] != REHEARSAL_TRUE["who"], "night bell copied the rehearsal taker")
	_expect(NIGHT_TRUE["place"] != REHEARSAL_TRUE["place"], "night bell copied the rehearsal room")
	_expect(NIGHT_TRUE["hour"] != REHEARSAL_TRUE["hour"], "night bell copied the rehearsal hour")
	_expect(NIGHT_TRUE["who"] != GILT_TRUE["who"], "night bell copied the gilt taker")
	_expect(NIGHT_TRUE["place"] != GILT_TRUE["place"], "night bell copied the gilt room")
	_expect(NIGHT_TRUE["hour"] != GILT_TRUE["hour"], "night bell copied the gilt hour")
	_expect(NIGHT_TRUE["who"] != FERRY_TRUE["who"], "night bell copied the ferry taker")
	_expect(NIGHT_TRUE["place"] != FERRY_TRUE["place"], "night bell copied the ferry room")
	_expect(NIGHT_TRUE["hour"] != FERRY_TRUE["hour"], "night bell copied the ferry hour")
	_expect(NIGHT_TRUE["who"] != WEATHER_TRUE["who"], "night bell copied the weather taker")
	_expect(NIGHT_TRUE["place"] != WEATHER_TRUE["place"], "night bell copied the weather room")
	_expect(NIGHT_TRUE["hour"] != WEATHER_TRUE["hour"], "night bell copied the weather hour")
	_expect(NIGHT_TRUE["who"] != LOOM_TRUE["who"], "night bell copied the loom taker")
	_expect(NIGHT_TRUE["place"] != LOOM_TRUE["place"], "night bell copied the loom room")
	_expect(NIGHT_TRUE["hour"] != LOOM_TRUE["hour"], "night bell copied the loom hour")
	_expect(NIGHT_TRUE["who"] != HIVE_TRUE["who"], "night bell copied the hive taker")
	_expect(NIGHT_TRUE["place"] != HIVE_TRUE["place"], "night bell copied the hive room")
	_expect(NIGHT_TRUE["hour"] != HIVE_TRUE["hour"], "night bell copied the hive hour")
	_expect(NIGHT_TRUE["who"] != GLASS_TRUE["who"], "night bell copied the glass taker")
	_expect(NIGHT_TRUE["place"] != GLASS_TRUE["place"], "night bell copied the glass room")
	_expect(NIGHT_TRUE["hour"] != GLASS_TRUE["hour"], "night bell copied the glass hour")
	_expect(NIGHT_TRUE["who"] != PRESS_TRUE["who"], "night bell copied the press taker")
	_expect(NIGHT_TRUE["place"] != PRESS_TRUE["place"], "night bell copied the press room")
	_expect(NIGHT_TRUE["hour"] != PRESS_TRUE["hour"], "night bell copied the press hour")
	_expect(NIGHT_TRUE["who"] != ASSAY_TRUE["who"], "night bell copied the assay taker")
	_expect(NIGHT_TRUE["place"] != ASSAY_TRUE["place"], "night bell copied the assay room")
	_expect(NIGHT_TRUE["hour"] != ASSAY_TRUE["hour"], "night bell copied the assay hour")
	_expect(NIGHT_TRUE["who"] != KILN_TRUE["who"], "night bell copied the kiln taker")
	_expect(NIGHT_TRUE["place"] != KILN_TRUE["place"], "night bell copied the kiln room")
	_expect(NIGHT_TRUE["hour"] != KILN_TRUE["hour"], "night bell copied the kiln hour")
	_expect(NIGHT_TRUE["who"] != TIDE_TRUE["who"], "night bell copied the tide taker")
	_expect(NIGHT_TRUE["place"] != TIDE_TRUE["place"], "night bell copied the tide room")
	_expect(NIGHT_TRUE["hour"] != TIDE_TRUE["hour"], "night bell copied the tide hour")
	_expect_rejected(NIGHT_TRUE, CaseData)
	_expect_rejected(NIGHT_TRUE, Rehearsal)
	_expect_rejected(NIGHT_TRUE, Gilt)
	_expect_rejected(NIGHT_TRUE, Ferry)
	_expect_rejected(NIGHT_TRUE, Weather)
	_expect_rejected(NIGHT_TRUE, Loom)
	_expect_rejected(NIGHT_TRUE, Hive)
	_expect_rejected(NIGHT_TRUE, Glass)
	_expect_rejected(NIGHT_TRUE, Press)
	_expect_rejected(NIGHT_TRUE, Assay)
	_expect_rejected(NIGHT_TRUE, Kiln)
	_expect_rejected(NIGHT_TRUE, Tide)
	_expect_rejected(spare, Night)
	_expect_rejected(REHEARSAL_TRUE, Night)
	_expect_rejected(GILT_TRUE, Night)
	_expect_rejected(FERRY_TRUE, Night)
	_expect_rejected(WEATHER_TRUE, Night)
	_expect_rejected(LOOM_TRUE, Night)
	_expect_rejected(HIVE_TRUE, Night)
	_expect_rejected(GLASS_TRUE, Night)
	_expect_rejected(PRESS_TRUE, Night)
	_expect_rejected(ASSAY_TRUE, Night)
	_expect_rejected(KILN_TRUE, Night)
	_expect_rejected(TIDE_TRUE, Night)
	for person in Night.PEOPLE:
		if person == "Vesper":
			_expect(Weather.PEOPLE.has(person), "the weather slate should still name Vesper")
		else:
			_expect(not Weather.PEOPLE.has(person), "night cast repeats %s from the weather slate" % person)
		_expect(not CaseData.PEOPLE.has(person), "night cast repeats %s from the spare key" % person)
		_expect(not Rehearsal.PEOPLE.has(person), "night cast repeats %s from the rehearsal score" % person)
		_expect(not Gilt.PEOPLE.has(person), "night cast repeats %s from the gilt stamp" % person)
		_expect(not Ferry.PEOPLE.has(person), "night cast repeats %s from the ferry bell" % person)
		_expect(not Loom.PEOPLE.has(person), "night cast repeats %s from the loom shuttle" % person)
		_expect(not Hive.PEOPLE.has(person), "night cast repeats %s from the hive smoker" % person)
		_expect(not Glass.PEOPLE.has(person), "night cast repeats %s from the glass pontil" % person)
		_expect(not Press.PEOPLE.has(person), "night cast repeats %s from the press proof" % person)
		_expect(not Assay.PEOPLE.has(person), "night cast repeats %s from the assay cup" % person)
		_expect(not Kiln.PEOPLE.has(person), "night cast repeats %s from the kiln chalk" % person)
		_expect(not Tide.PEOPLE.has(person), "night cast repeats %s from the tide ledger" % person)
	_expect(not Night.PEOPLE.has("Moss"), "night bell cast must not take Moss")
	_expect(not Night.PEOPLE.has("Pell"), "night bell cast must not take Pell")
	_expect(not Night.PEOPLE.has("Wren"), "night bell cast must not take Wren")
	_expect(not Night.PEOPLE.has("Quill"), "night bell cast must not take Quill")
	_expect(not Night.PEOPLE.has("Lark"), "night bell cast must not take Lark")
	_expect(not Night.PEOPLE.has("Nim"), "night bell cast must not take Nim")
	_expect(not Night.PEOPLE.has("Sable"), "night bell cast must not take Sable")
	_expect(Weather.PEOPLE.has("Vesper"), "the weather slate should still name Vesper")
	_expect(Weather.role_phrase("Vesper") == "the night watch", "the weather slate should still call Vesper the night watch")
	_expect(Night.role_phrase("Vesper") == "the night ringer", "the night bell should call Vesper the night ringer")
	_expect(Ferry.PEOPLE.has("Wren"), "the ferry bell should still name Wren the pilot")
	_expect(Ferry.role_phrase("Wren") == "the pilot", "the ferry bell should still call Wren the pilot")
	_expect(FERRY_TRUE["who"] == "Quill" and FERRY_TRUE["place"] == "rope_loft" and FERRY_TRUE["hour"] == "15", "the ferry bell should still accept Quill in the rope loft at 15")
	for place in Night.PLACES:
		_expect(not CaseData.PLACES.has(place), "night rooms repeat %s from the spare key" % place)
		_expect(not Rehearsal.PLACES.has(place), "night rooms repeat %s from the rehearsal score" % place)
		_expect(not Gilt.PLACES.has(place), "night rooms repeat %s from the gilt stamp" % place)
		_expect(not Ferry.PLACES.has(place), "night rooms repeat %s from the ferry bell" % place)
		_expect(not Weather.PLACES.has(place), "night rooms repeat %s from the weather slate" % place)
		_expect(not Loom.PLACES.has(place), "night rooms repeat %s from the loom shuttle" % place)
		_expect(not Hive.PLACES.has(place), "night rooms repeat %s from the hive smoker" % place)
		_expect(not Glass.PLACES.has(place), "night rooms repeat %s from the glass pontil" % place)
		_expect(not Press.PLACES.has(place), "night rooms repeat %s from the press proof" % place)
		_expect(not Assay.PLACES.has(place), "night rooms repeat %s from the assay cup" % place)
		_expect(not Kiln.PLACES.has(place), "night rooms repeat %s from the kiln chalk" % place)
		_expect(not Tide.PLACES.has(place), "night rooms repeat %s from the tide ledger" % place)
	for hour in Night.HOURS:
		_expect(not CaseData.HOURS.has(hour), "night hours repeat %s from the spare key" % hour)
		_expect(not Rehearsal.HOURS.has(hour), "night hours repeat %s from the rehearsal score" % hour)
		_expect(not Gilt.HOURS.has(hour), "night hours repeat %s from the gilt stamp" % hour)
		_expect(not Ferry.HOURS.has(hour), "night hours repeat %s from the ferry bell" % hour)
		_expect(not Weather.HOURS.has(hour), "night hours repeat %s from the weather slate" % hour)
		_expect(not Loom.HOURS.has(hour), "night hours repeat %s from the loom shuttle" % hour)
		_expect(not Hive.HOURS.has(hour), "night hours repeat %s from the hive smoker" % hour)
		_expect(not Glass.HOURS.has(hour), "night hours repeat %s from the glass pontil" % hour)
		_expect(not Assay.HOURS.has(hour), "night hours repeat %s from the assay cup" % hour)
		_expect(not Kiln.HOURS.has(hour), "night hours repeat %s from the kiln chalk" % hour)
		_expect(not Tide.HOURS.has(hour), "night hours repeat %s from the tide ledger" % hour)
		if hour == "42" or hour == "43":
			_expect(Press.HOURS.has(hour), "night hour %s may also sit on the press proof" % hour)
		else:
			_expect(not Press.HOURS.has(hour), "night hours repeat %s from the press proof" % hour)
	_expect(SALT_TRUE["who"] == "Holt", "salt mark taker")
	_expect(SALT_TRUE["place"] == "pan", "salt mark room")
	_expect(SALT_TRUE["hour"] == "19", "salt mark hour")
	for forbidden in ["Vesper", "Moss", "Pell", "Wren", "Quill", "Lark", "Nim", "Sable", "Cobb", "Bram"]:
		_expect(SALT_TRUE["who"] != forbidden, "salt mark accepted %s" % forbidden)
	_expect(SALT_TRUE["who"] != spare["who"], "salt mark copied the spare-key taker")
	_expect(SALT_TRUE["place"] != spare["place"], "salt mark copied the spare-key room")
	_expect(SALT_TRUE["hour"] != spare["hour"], "salt mark copied the spare-key hour")
	_expect(SALT_TRUE["who"] != REHEARSAL_TRUE["who"], "salt mark copied the rehearsal taker")
	_expect(SALT_TRUE["place"] != REHEARSAL_TRUE["place"], "salt mark copied the rehearsal room")
	_expect(SALT_TRUE["hour"] != REHEARSAL_TRUE["hour"], "salt mark copied the rehearsal hour")
	_expect(SALT_TRUE["who"] != GILT_TRUE["who"], "salt mark copied the gilt taker")
	_expect(SALT_TRUE["place"] != GILT_TRUE["place"], "salt mark copied the gilt room")
	_expect(SALT_TRUE["hour"] != GILT_TRUE["hour"], "salt mark copied the gilt hour")
	_expect(SALT_TRUE["who"] != FERRY_TRUE["who"], "salt mark copied the ferry taker")
	_expect(SALT_TRUE["place"] != FERRY_TRUE["place"], "salt mark copied the ferry room")
	_expect(SALT_TRUE["hour"] != FERRY_TRUE["hour"], "salt mark copied the ferry hour")
	_expect(SALT_TRUE["who"] != WEATHER_TRUE["who"], "salt mark copied the weather taker")
	_expect(SALT_TRUE["place"] != WEATHER_TRUE["place"], "salt mark copied the weather room")
	_expect(SALT_TRUE["hour"] != WEATHER_TRUE["hour"], "salt mark copied the weather hour")
	_expect(SALT_TRUE["who"] != LOOM_TRUE["who"], "salt mark copied the loom taker")
	_expect(SALT_TRUE["place"] != LOOM_TRUE["place"], "salt mark copied the loom room")
	_expect(LOOM_TRUE["hour"] == "19", "the loom shuttle should still accept hour 19")
	_expect(SALT_TRUE["hour"] == LOOM_TRUE["hour"], "salt mark may share the loom hour")
	_expect(SALT_TRUE["who"] != HIVE_TRUE["who"], "salt mark copied the hive taker")
	_expect(SALT_TRUE["place"] != HIVE_TRUE["place"], "salt mark copied the hive room")
	_expect(SALT_TRUE["hour"] != HIVE_TRUE["hour"], "salt mark copied the hive hour")
	_expect(SALT_TRUE["who"] != GLASS_TRUE["who"], "salt mark copied the glass taker")
	_expect(SALT_TRUE["place"] != GLASS_TRUE["place"], "salt mark copied the glass room")
	_expect(SALT_TRUE["hour"] != GLASS_TRUE["hour"], "salt mark copied the glass hour")
	_expect(SALT_TRUE["who"] != PRESS_TRUE["who"], "salt mark copied the press taker")
	_expect(SALT_TRUE["place"] != PRESS_TRUE["place"], "salt mark copied the press room")
	_expect(SALT_TRUE["hour"] != PRESS_TRUE["hour"], "salt mark copied the press hour")
	_expect(SALT_TRUE["who"] != ASSAY_TRUE["who"], "salt mark copied the assay taker")
	_expect(SALT_TRUE["place"] != ASSAY_TRUE["place"], "salt mark copied the assay room")
	_expect(SALT_TRUE["hour"] != ASSAY_TRUE["hour"], "salt mark copied the assay hour")
	_expect(SALT_TRUE["who"] != KILN_TRUE["who"], "salt mark copied the kiln taker")
	_expect(SALT_TRUE["place"] != KILN_TRUE["place"], "salt mark copied the kiln room")
	_expect(SALT_TRUE["hour"] != KILN_TRUE["hour"], "salt mark copied the kiln hour")
	_expect(SALT_TRUE["who"] != TIDE_TRUE["who"], "salt mark copied the tide taker")
	_expect(SALT_TRUE["place"] != TIDE_TRUE["place"], "salt mark copied the tide room")
	_expect(SALT_TRUE["hour"] != TIDE_TRUE["hour"], "salt mark copied the tide hour")
	_expect(SALT_TRUE["who"] != NIGHT_TRUE["who"], "salt mark copied the night taker")
	_expect(SALT_TRUE["place"] != NIGHT_TRUE["place"], "salt mark copied the night room")
	_expect(SALT_TRUE["hour"] != NIGHT_TRUE["hour"], "salt mark copied the night hour")
	_expect(NIGHT_TRUE["who"] == "Vesper" and NIGHT_TRUE["place"] == "tower" and NIGHT_TRUE["hour"] == "44", "the night bell should still accept Vesper in the tower at 44")
	_expect(TIDE_TRUE["who"] == "Moss" and TIDE_TRUE["place"] == "quay" and TIDE_TRUE["hour"] == "33", "the tide ledger should still accept Moss on the quay at 33")
	_expect(KILN_TRUE["who"] == "Wren" and KILN_TRUE["place"] == "flue" and KILN_TRUE["hour"] == "52", "the kiln chalk should still accept Wren on the flue at 52")
	_expect(ASSAY_TRUE["who"] == "Lark" and ASSAY_TRUE["place"] == "scale" and ASSAY_TRUE["hour"] == "16", "the assay cup should still accept Lark on the scale at 16")
	_expect(PRESS_TRUE["who"] == "Nim" and PRESS_TRUE["place"] == "stone" and PRESS_TRUE["hour"] == "41", "the press proof should still accept Nim on the stone at 41")
	_expect(GLASS_TRUE["who"] == "Sable" and GLASS_TRUE["place"] == "lehr_room" and GLASS_TRUE["hour"] == "27", "the glass pontil should still accept Sable in the lehr room at 27")
	_expect(FERRY_TRUE["who"] == "Quill" and FERRY_TRUE["place"] == "rope_loft" and FERRY_TRUE["hour"] == "15", "the ferry bell should still accept Quill in the rope loft at 15")
	_expect(Ferry.PEOPLE.has("Wren"), "the ferry bell should still name Wren the pilot")
	_expect(Ferry.role_phrase("Wren") == "the pilot", "the ferry bell should still call Wren the pilot")
	_expect_rejected(SALT_TRUE, CaseData)
	_expect_rejected(SALT_TRUE, Rehearsal)
	_expect_rejected(SALT_TRUE, Gilt)
	_expect_rejected(SALT_TRUE, Ferry)
	_expect_rejected(SALT_TRUE, Weather)
	_expect_rejected(SALT_TRUE, Loom)
	_expect_rejected(SALT_TRUE, Hive)
	_expect_rejected(SALT_TRUE, Glass)
	_expect_rejected(SALT_TRUE, Press)
	_expect_rejected(SALT_TRUE, Assay)
	_expect_rejected(SALT_TRUE, Kiln)
	_expect_rejected(SALT_TRUE, Tide)
	_expect_rejected(SALT_TRUE, Night)
	_expect_rejected(spare, Salt)
	_expect_rejected(REHEARSAL_TRUE, Salt)
	_expect_rejected(GILT_TRUE, Salt)
	_expect_rejected(FERRY_TRUE, Salt)
	_expect_rejected(WEATHER_TRUE, Salt)
	_expect_rejected(LOOM_TRUE, Salt)
	_expect_rejected(HIVE_TRUE, Salt)
	_expect_rejected(GLASS_TRUE, Salt)
	_expect_rejected(PRESS_TRUE, Salt)
	_expect_rejected(ASSAY_TRUE, Salt)
	_expect_rejected(KILN_TRUE, Salt)
	_expect_rejected(TIDE_TRUE, Salt)
	_expect_rejected(NIGHT_TRUE, Salt)
	for person in Salt.PEOPLE:
		_expect(not CaseData.PEOPLE.has(person), "salt cast repeats %s from the spare key" % person)
		_expect(not Rehearsal.PEOPLE.has(person), "salt cast repeats %s from the rehearsal score" % person)
		_expect(not Gilt.PEOPLE.has(person), "salt cast repeats %s from the gilt stamp" % person)
		_expect(not Ferry.PEOPLE.has(person), "salt cast repeats %s from the ferry bell" % person)
		_expect(not Weather.PEOPLE.has(person), "salt cast repeats %s from the weather slate" % person)
		_expect(not Loom.PEOPLE.has(person), "salt cast repeats %s from the loom shuttle" % person)
		_expect(not Hive.PEOPLE.has(person), "salt cast repeats %s from the hive smoker" % person)
		_expect(not Glass.PEOPLE.has(person), "salt cast repeats %s from the glass pontil" % person)
		_expect(not Press.PEOPLE.has(person), "salt cast repeats %s from the press proof" % person)
		_expect(not Assay.PEOPLE.has(person), "salt cast repeats %s from the assay cup" % person)
		_expect(not Kiln.PEOPLE.has(person), "salt cast repeats %s from the kiln chalk" % person)
		_expect(not Tide.PEOPLE.has(person), "salt cast repeats %s from the tide ledger" % person)
		_expect(not Night.PEOPLE.has(person), "salt cast repeats %s from the night bell" % person)
	for forbidden_person in ["Vesper", "Moss", "Pell", "Wren", "Quill", "Lark", "Nim", "Sable", "Cobb", "Bram"]:
		_expect(not Salt.PEOPLE.has(forbidden_person), "salt mark cast must not take %s" % forbidden_person)
	_expect(Salt.role_phrase("Holt") == "the salt hand", "the salt mark should call Holt the salt hand")
	for place in Salt.PLACES:
		_expect(not CaseData.PLACES.has(place), "salt rooms repeat %s from the spare key" % place)
		_expect(not Rehearsal.PLACES.has(place), "salt rooms repeat %s from the rehearsal score" % place)
		_expect(not Gilt.PLACES.has(place), "salt rooms repeat %s from the gilt stamp" % place)
		_expect(not Ferry.PLACES.has(place), "salt rooms repeat %s from the ferry bell" % place)
		_expect(not Weather.PLACES.has(place), "salt rooms repeat %s from the weather slate" % place)
		_expect(not Loom.PLACES.has(place), "salt rooms repeat %s from the loom shuttle" % place)
		_expect(not Hive.PLACES.has(place), "salt rooms repeat %s from the hive smoker" % place)
		_expect(not Glass.PLACES.has(place), "salt rooms repeat %s from the glass pontil" % place)
		_expect(not Press.PLACES.has(place), "salt rooms repeat %s from the press proof" % place)
		_expect(not Assay.PLACES.has(place), "salt rooms repeat %s from the assay cup" % place)
		_expect(not Kiln.PLACES.has(place), "salt rooms repeat %s from the kiln chalk" % place)
		_expect(not Tide.PLACES.has(place), "salt rooms repeat %s from the tide ledger" % place)
		_expect(not Night.PLACES.has(place), "salt rooms repeat %s from the night bell" % place)
	for hour in Salt.HOURS:
		_expect(not CaseData.HOURS.has(hour), "salt hours repeat %s from the spare key" % hour)
		_expect(not Rehearsal.HOURS.has(hour), "salt hours repeat %s from the rehearsal score" % hour)
		_expect(not Gilt.HOURS.has(hour), "salt hours repeat %s from the gilt stamp" % hour)
		_expect(not Ferry.HOURS.has(hour), "salt hours repeat %s from the ferry bell" % hour)
		_expect(not Weather.HOURS.has(hour), "salt hours repeat %s from the weather slate" % hour)
		_expect(not Glass.HOURS.has(hour), "salt hours repeat %s from the glass pontil" % hour)
		_expect(not Press.HOURS.has(hour), "salt hours repeat %s from the press proof" % hour)
		_expect(not Kiln.HOURS.has(hour), "salt hours repeat %s from the kiln chalk" % hour)
		_expect(not Tide.HOURS.has(hour), "salt hours repeat %s from the tide ledger" % hour)
		_expect(not Night.HOURS.has(hour), "salt hours repeat %s from the night bell" % hour)
		if hour == "17" or hour == "18":
			_expect(Loom.HOURS.has(hour), "salt hour %s may also sit on the loom shuttle" % hour)
			_expect(Assay.HOURS.has(hour), "salt hour %s may also sit on the assay cup" % hour)
			_expect(not Hive.HOURS.has(hour), "salt hours repeat %s from the hive smoker" % hour)
		elif hour == "19" or hour == "20":
			_expect(Loom.HOURS.has(hour), "salt hour %s may also sit on the loom shuttle" % hour)
			_expect(not Assay.HOURS.has(hour), "salt hours repeat %s from the assay cup" % hour)
			_expect(not Hive.HOURS.has(hour), "salt hours repeat %s from the hive smoker" % hour)
		elif hour == "21":
			_expect(Hive.HOURS.has(hour), "salt hour %s may also sit on the hive smoker" % hour)
			_expect(not Loom.HOURS.has(hour), "salt hours repeat %s from the loom shuttle" % hour)
			_expect(not Assay.HOURS.has(hour), "salt hours repeat %s from the assay cup" % hour)
		else:
			_expect(not Loom.HOURS.has(hour), "salt hours repeat %s from the loom shuttle" % hour)
			_expect(not Assay.HOURS.has(hour), "salt hours repeat %s from the assay cup" % hour)
			_expect(not Hive.HOURS.has(hour), "salt hours repeat %s from the hive smoker" % hour)
	_expect(WICK_TRUE["who"] == "Quin", "wick trim taker")
	_expect(WICK_TRUE["place"] == "loft", "wick trim room")
	_expect(WICK_TRUE["hour"] == "4", "wick trim hour")
	for forbidden in ["Holt", "Lin", "Opal"]:
		_expect(WICK_TRUE["who"] != forbidden, "wick trim accepted %s" % forbidden)
	for forbidden_place in ["pan", "cistern", "rake_bay"]:
		_expect(WICK_TRUE["place"] != forbidden_place, "wick trim accepted the %s" % forbidden_place)
	_expect(WICK_TRUE["hour"] != "19", "wick trim accepted 19")
	_expect(WICK_TRUE["who"] != spare["who"], "wick trim copied the spare-key taker")
	_expect(WICK_TRUE["place"] != spare["place"], "wick trim copied the spare-key room")
	_expect(WICK_TRUE["hour"] != spare["hour"], "wick trim copied the spare-key hour")
	_expect(WICK_TRUE["who"] != REHEARSAL_TRUE["who"], "wick trim copied the rehearsal taker")
	_expect(WICK_TRUE["place"] != REHEARSAL_TRUE["place"], "wick trim copied the rehearsal room")
	_expect(REHEARSAL_TRUE["hour"] == "4", "the rehearsal score should still accept hour 4")
	_expect(WICK_TRUE["hour"] == REHEARSAL_TRUE["hour"], "wick trim may share the rehearsal hour")
	_expect(WICK_TRUE["who"] != GILT_TRUE["who"], "wick trim copied the gilt taker")
	_expect(WICK_TRUE["place"] != GILT_TRUE["place"], "wick trim copied the gilt room")
	_expect(WICK_TRUE["hour"] != GILT_TRUE["hour"], "wick trim copied the gilt hour")
	_expect(WICK_TRUE["who"] != FERRY_TRUE["who"], "wick trim copied the ferry taker")
	_expect(WICK_TRUE["place"] != FERRY_TRUE["place"], "wick trim copied the ferry room")
	_expect(WICK_TRUE["hour"] != FERRY_TRUE["hour"], "wick trim copied the ferry hour")
	_expect(WICK_TRUE["who"] != WEATHER_TRUE["who"], "wick trim copied the weather taker")
	_expect(WICK_TRUE["place"] != WEATHER_TRUE["place"], "wick trim copied the weather room")
	_expect(WICK_TRUE["hour"] != WEATHER_TRUE["hour"], "wick trim copied the weather hour")
	_expect(WICK_TRUE["who"] != LOOM_TRUE["who"], "wick trim copied the loom taker")
	_expect(WICK_TRUE["place"] != LOOM_TRUE["place"], "wick trim copied the loom room")
	_expect(WICK_TRUE["hour"] != LOOM_TRUE["hour"], "wick trim copied the loom hour")
	_expect(WICK_TRUE["who"] != HIVE_TRUE["who"], "wick trim copied the hive taker")
	_expect(WICK_TRUE["place"] != HIVE_TRUE["place"], "wick trim copied the hive room")
	_expect(WICK_TRUE["hour"] != HIVE_TRUE["hour"], "wick trim copied the hive hour")
	_expect(WICK_TRUE["who"] != GLASS_TRUE["who"], "wick trim copied the glass taker")
	_expect(WICK_TRUE["place"] != GLASS_TRUE["place"], "wick trim copied the glass room")
	_expect(WICK_TRUE["hour"] != GLASS_TRUE["hour"], "wick trim copied the glass hour")
	_expect(WICK_TRUE["who"] != PRESS_TRUE["who"], "wick trim copied the press taker")
	_expect(WICK_TRUE["place"] != PRESS_TRUE["place"], "wick trim copied the press room")
	_expect(WICK_TRUE["hour"] != PRESS_TRUE["hour"], "wick trim copied the press hour")
	_expect(WICK_TRUE["who"] != ASSAY_TRUE["who"], "wick trim copied the assay taker")
	_expect(WICK_TRUE["place"] != ASSAY_TRUE["place"], "wick trim copied the assay room")
	_expect(WICK_TRUE["hour"] != ASSAY_TRUE["hour"], "wick trim copied the assay hour")
	_expect(WICK_TRUE["who"] != KILN_TRUE["who"], "wick trim copied the kiln taker")
	_expect(WICK_TRUE["place"] != KILN_TRUE["place"], "wick trim copied the kiln room")
	_expect(WICK_TRUE["hour"] != KILN_TRUE["hour"], "wick trim copied the kiln hour")
	_expect(WICK_TRUE["who"] != TIDE_TRUE["who"], "wick trim copied the tide taker")
	_expect(WICK_TRUE["place"] != TIDE_TRUE["place"], "wick trim copied the tide room")
	_expect(WICK_TRUE["hour"] != TIDE_TRUE["hour"], "wick trim copied the tide hour")
	_expect(WICK_TRUE["who"] != NIGHT_TRUE["who"], "wick trim copied the night taker")
	_expect(WICK_TRUE["place"] != NIGHT_TRUE["place"], "wick trim copied the night room")
	_expect(WICK_TRUE["hour"] != NIGHT_TRUE["hour"], "wick trim copied the night hour")
	_expect(WICK_TRUE["who"] != SALT_TRUE["who"], "wick trim copied the salt taker")
	_expect(WICK_TRUE["place"] != SALT_TRUE["place"], "wick trim copied the salt room")
	_expect(WICK_TRUE["hour"] != SALT_TRUE["hour"], "wick trim copied the salt hour")
	_expect(SALT_TRUE["who"] == "Holt" and SALT_TRUE["place"] == "pan" and SALT_TRUE["hour"] == "19", "the salt mark should still accept Holt on the pan at 19")
	_expect_rejected(WICK_TRUE, CaseData)
	_expect_rejected(WICK_TRUE, Rehearsal)
	_expect_rejected(WICK_TRUE, Gilt)
	_expect_rejected(WICK_TRUE, Ferry)
	_expect_rejected(WICK_TRUE, Weather)
	_expect_rejected(WICK_TRUE, Loom)
	_expect_rejected(WICK_TRUE, Hive)
	_expect_rejected(WICK_TRUE, Glass)
	_expect_rejected(WICK_TRUE, Press)
	_expect_rejected(WICK_TRUE, Assay)
	_expect_rejected(WICK_TRUE, Kiln)
	_expect_rejected(WICK_TRUE, Tide)
	_expect_rejected(WICK_TRUE, Night)
	_expect_rejected(WICK_TRUE, Salt)
	_expect_rejected(spare, Wick)
	_expect_rejected(REHEARSAL_TRUE, Wick)
	_expect_rejected(GILT_TRUE, Wick)
	_expect_rejected(FERRY_TRUE, Wick)
	_expect_rejected(WEATHER_TRUE, Wick)
	_expect_rejected(LOOM_TRUE, Wick)
	_expect_rejected(HIVE_TRUE, Wick)
	_expect_rejected(GLASS_TRUE, Wick)
	_expect_rejected(PRESS_TRUE, Wick)
	_expect_rejected(ASSAY_TRUE, Wick)
	_expect_rejected(KILN_TRUE, Wick)
	_expect_rejected(TIDE_TRUE, Wick)
	_expect_rejected(NIGHT_TRUE, Wick)
	_expect_rejected(SALT_TRUE, Wick)
	for person in Wick.PEOPLE:
		if person == "Mara":
			_expect(Gilt.PEOPLE.has(person), "wick trim may share Mara with the gilt stamp")
		else:
			_expect(not Gilt.PEOPLE.has(person), "wick cast repeats %s from the gilt stamp" % person)
		if person == "Sable":
			_expect(Glass.PEOPLE.has(person), "wick trim may share Sable with the glass pontil")
		else:
			_expect(not Glass.PEOPLE.has(person), "wick cast repeats %s from the glass pontil" % person)
		_expect(not CaseData.PEOPLE.has(person), "wick cast repeats %s from the spare key" % person)
		_expect(not Rehearsal.PEOPLE.has(person), "wick cast repeats %s from the rehearsal score" % person)
		_expect(not Ferry.PEOPLE.has(person), "wick cast repeats %s from the ferry bell" % person)
		_expect(not Weather.PEOPLE.has(person), "wick cast repeats %s from the weather slate" % person)
		_expect(not Loom.PEOPLE.has(person), "wick cast repeats %s from the loom shuttle" % person)
		_expect(not Hive.PEOPLE.has(person), "wick cast repeats %s from the hive smoker" % person)
		_expect(not Press.PEOPLE.has(person), "wick cast repeats %s from the press proof" % person)
		_expect(not Assay.PEOPLE.has(person), "wick cast repeats %s from the assay cup" % person)
		_expect(not Kiln.PEOPLE.has(person), "wick cast repeats %s from the kiln chalk" % person)
		_expect(not Tide.PEOPLE.has(person), "wick cast repeats %s from the tide ledger" % person)
		_expect(not Night.PEOPLE.has(person), "wick cast repeats %s from the night bell" % person)
		_expect(not Salt.PEOPLE.has(person), "wick cast repeats %s from the salt mark" % person)
	for forbidden_person in ["Holt", "Lin", "Opal"]:
		_expect(not Wick.PEOPLE.has(forbidden_person), "wick trim cast must not take %s" % forbidden_person)
	_expect(Wick.role_phrase("Quin") == "the wick hand", "the wick trim should call Quin the wick hand")
	for place in Wick.PLACES:
		if place == "gallery":
			_expect(Rehearsal.PLACES.has(place), "wick trim may share the gallery with the rehearsal score")
		else:
			_expect(not Rehearsal.PLACES.has(place), "wick rooms repeat %s from the rehearsal score" % place)
		_expect(not CaseData.PLACES.has(place), "wick rooms repeat %s from the spare key" % place)
		_expect(not Gilt.PLACES.has(place), "wick rooms repeat %s from the gilt stamp" % place)
		_expect(not Ferry.PLACES.has(place), "wick rooms repeat %s from the ferry bell" % place)
		_expect(not Weather.PLACES.has(place), "wick rooms repeat %s from the weather slate" % place)
		_expect(not Loom.PLACES.has(place), "wick rooms repeat %s from the loom shuttle" % place)
		_expect(not Hive.PLACES.has(place), "wick rooms repeat %s from the hive smoker" % place)
		_expect(not Glass.PLACES.has(place), "wick rooms repeat %s from the glass pontil" % place)
		_expect(not Press.PLACES.has(place), "wick rooms repeat %s from the press proof" % place)
		_expect(not Assay.PLACES.has(place), "wick rooms repeat %s from the assay cup" % place)
		_expect(not Kiln.PLACES.has(place), "wick rooms repeat %s from the kiln chalk" % place)
		_expect(not Tide.PLACES.has(place), "wick rooms repeat %s from the tide ledger" % place)
		_expect(not Night.PLACES.has(place), "wick rooms repeat %s from the night bell" % place)
		_expect(not Salt.PLACES.has(place), "wick rooms repeat %s from the salt mark" % place)
	for forbidden_place in ["pan", "cistern", "rake_bay"]:
		_expect(not Wick.PLACES.has(forbidden_place), "wick trim rooms must not take the %s" % forbidden_place)
	for hour in Wick.HOURS:
		_expect(not CaseData.HOURS.has(hour), "wick hours repeat %s from the spare key" % hour)
		_expect(not Ferry.HOURS.has(hour), "wick hours repeat %s from the ferry bell" % hour)
		_expect(not Weather.HOURS.has(hour), "wick hours repeat %s from the weather slate" % hour)
		_expect(not Loom.HOURS.has(hour), "wick hours repeat %s from the loom shuttle" % hour)
		_expect(not Hive.HOURS.has(hour), "wick hours repeat %s from the hive smoker" % hour)
		_expect(not Glass.HOURS.has(hour), "wick hours repeat %s from the glass pontil" % hour)
		_expect(not Press.HOURS.has(hour), "wick hours repeat %s from the press proof" % hour)
		_expect(not Assay.HOURS.has(hour), "wick hours repeat %s from the assay cup" % hour)
		_expect(not Kiln.HOURS.has(hour), "wick hours repeat %s from the kiln chalk" % hour)
		_expect(not Tide.HOURS.has(hour), "wick hours repeat %s from the tide ledger" % hour)
		_expect(not Night.HOURS.has(hour), "wick hours repeat %s from the night bell" % hour)
		_expect(not Salt.HOURS.has(hour), "wick hours repeat %s from the salt mark" % hour)
		if hour == "2" or hour == "3":
			_expect(Gilt.HOURS.has(hour), "wick hour %s may also sit on the gilt stamp" % hour)
			_expect(not Rehearsal.HOURS.has(hour), "wick hours repeat %s from the rehearsal score" % hour)
		elif hour == "4" or hour == "5" or hour == "6":
			_expect(Rehearsal.HOURS.has(hour), "wick hour %s may also sit on the rehearsal score" % hour)
			_expect(not Gilt.HOURS.has(hour), "wick hours repeat %s from the gilt stamp" % hour)
		else:
			_expect(not Gilt.HOURS.has(hour), "wick hours repeat %s from the gilt stamp" % hour)
			_expect(not Rehearsal.HOURS.has(hour), "wick hours repeat %s from the rehearsal score" % hour)
	_expect(not Wick.HOURS.has("19"), "wick trim hours must not take 19")
	var titles: Array[String] = []
	for book in Catalog.all():
		titles.append(str(book.TITLE))
	_expect(ANNEAL_TRUE["who"] == "Tess", "glass anneal taker")
	_expect(ANNEAL_TRUE["place"] == "lehr", "glass anneal room")
	_expect(ANNEAL_TRUE["hour"] == "10", "glass anneal hour")
	for forbidden in ["Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(ANNEAL_TRUE["who"] != forbidden, "glass anneal accepted %s" % forbidden)
	for forbidden_place in ["loft", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(ANNEAL_TRUE["place"] != forbidden_place, "glass anneal accepted the %s" % forbidden_place)
	_expect(ANNEAL_TRUE["hour"] != "4", "glass anneal accepted 4")
	_expect(ANNEAL_TRUE["hour"] != "19", "glass anneal accepted 19")
	_expect(ANNEAL_TRUE["who"] != spare["who"], "glass anneal copied the spare-key taker")
	_expect(ANNEAL_TRUE["place"] != spare["place"], "glass anneal copied the spare-key room")
	_expect(ANNEAL_TRUE["hour"] != spare["hour"], "glass anneal copied the spare-key hour")
	_expect(ANNEAL_TRUE["who"] != REHEARSAL_TRUE["who"], "glass anneal copied the rehearsal taker")
	_expect(ANNEAL_TRUE["place"] != REHEARSAL_TRUE["place"], "glass anneal copied the rehearsal room")
	_expect(ANNEAL_TRUE["hour"] != REHEARSAL_TRUE["hour"], "glass anneal copied the rehearsal hour")
	_expect(ANNEAL_TRUE["who"] != GILT_TRUE["who"], "glass anneal copied the gilt taker")
	_expect(ANNEAL_TRUE["place"] != GILT_TRUE["place"], "glass anneal copied the gilt room")
	_expect(ANNEAL_TRUE["hour"] != GILT_TRUE["hour"], "glass anneal copied the gilt hour")
	_expect(ANNEAL_TRUE["who"] != FERRY_TRUE["who"], "glass anneal copied the ferry taker")
	_expect(ANNEAL_TRUE["place"] != FERRY_TRUE["place"], "glass anneal copied the ferry room")
	_expect(ANNEAL_TRUE["hour"] != FERRY_TRUE["hour"], "glass anneal copied the ferry hour")
	_expect(ANNEAL_TRUE["who"] != WEATHER_TRUE["who"], "glass anneal copied the weather taker")
	_expect(ANNEAL_TRUE["place"] != WEATHER_TRUE["place"], "glass anneal copied the weather room")
	_expect(ANNEAL_TRUE["hour"] != WEATHER_TRUE["hour"], "glass anneal copied the weather hour")
	_expect(ANNEAL_TRUE["who"] != LOOM_TRUE["who"], "glass anneal copied the loom taker")
	_expect(ANNEAL_TRUE["place"] != LOOM_TRUE["place"], "glass anneal copied the loom room")
	_expect(ANNEAL_TRUE["hour"] != LOOM_TRUE["hour"], "glass anneal copied the loom hour")
	_expect(ANNEAL_TRUE["who"] != HIVE_TRUE["who"], "glass anneal copied the hive taker")
	_expect(ANNEAL_TRUE["place"] != HIVE_TRUE["place"], "glass anneal copied the hive room")
	_expect(ANNEAL_TRUE["hour"] != HIVE_TRUE["hour"], "glass anneal copied the hive hour")
	_expect(ANNEAL_TRUE["who"] != GLASS_TRUE["who"], "glass anneal copied the glass taker")
	_expect(ANNEAL_TRUE["place"] != GLASS_TRUE["place"], "glass anneal copied the glass room")
	_expect(ANNEAL_TRUE["hour"] != GLASS_TRUE["hour"], "glass anneal copied the glass hour")
	_expect(ANNEAL_TRUE["who"] != PRESS_TRUE["who"], "glass anneal copied the press taker")
	_expect(ANNEAL_TRUE["place"] != PRESS_TRUE["place"], "glass anneal copied the press room")
	_expect(ANNEAL_TRUE["hour"] != PRESS_TRUE["hour"], "glass anneal copied the press hour")
	_expect(ANNEAL_TRUE["who"] != ASSAY_TRUE["who"], "glass anneal copied the assay taker")
	_expect(ANNEAL_TRUE["place"] != ASSAY_TRUE["place"], "glass anneal copied the assay room")
	_expect(ANNEAL_TRUE["hour"] != ASSAY_TRUE["hour"], "glass anneal copied the assay hour")
	_expect(ANNEAL_TRUE["who"] != KILN_TRUE["who"], "glass anneal copied the kiln taker")
	_expect(ANNEAL_TRUE["place"] != KILN_TRUE["place"], "glass anneal copied the kiln room")
	_expect(ANNEAL_TRUE["hour"] != KILN_TRUE["hour"], "glass anneal copied the kiln hour")
	_expect(ANNEAL_TRUE["who"] != TIDE_TRUE["who"], "glass anneal copied the tide taker")
	_expect(ANNEAL_TRUE["place"] != TIDE_TRUE["place"], "glass anneal copied the tide room")
	_expect(ANNEAL_TRUE["hour"] != TIDE_TRUE["hour"], "glass anneal copied the tide hour")
	_expect(ANNEAL_TRUE["who"] != NIGHT_TRUE["who"], "glass anneal copied the night taker")
	_expect(ANNEAL_TRUE["place"] != NIGHT_TRUE["place"], "glass anneal copied the night room")
	_expect(ANNEAL_TRUE["hour"] != NIGHT_TRUE["hour"], "glass anneal copied the night hour")
	_expect(ANNEAL_TRUE["who"] != SALT_TRUE["who"], "glass anneal copied the salt taker")
	_expect(ANNEAL_TRUE["place"] != SALT_TRUE["place"], "glass anneal copied the salt room")
	_expect(ANNEAL_TRUE["hour"] != SALT_TRUE["hour"], "glass anneal copied the salt hour")
	_expect(ANNEAL_TRUE["who"] != WICK_TRUE["who"], "glass anneal copied the wick taker")
	_expect(ANNEAL_TRUE["place"] != WICK_TRUE["place"], "glass anneal copied the wick room")
	_expect(ANNEAL_TRUE["hour"] != WICK_TRUE["hour"], "glass anneal copied the wick hour")
	_expect(WICK_TRUE["who"] == "Quin" and WICK_TRUE["place"] == "loft" and WICK_TRUE["hour"] == "4", "the wick trim should still accept Quin in the loft at 4")
	_expect_rejected(ANNEAL_TRUE, CaseData)
	_expect_rejected(ANNEAL_TRUE, Rehearsal)
	_expect_rejected(ANNEAL_TRUE, Gilt)
	_expect_rejected(ANNEAL_TRUE, Ferry)
	_expect_rejected(ANNEAL_TRUE, Weather)
	_expect_rejected(ANNEAL_TRUE, Loom)
	_expect_rejected(ANNEAL_TRUE, Hive)
	_expect_rejected(ANNEAL_TRUE, Glass)
	_expect_rejected(ANNEAL_TRUE, Press)
	_expect_rejected(ANNEAL_TRUE, Assay)
	_expect_rejected(ANNEAL_TRUE, Kiln)
	_expect_rejected(ANNEAL_TRUE, Tide)
	_expect_rejected(ANNEAL_TRUE, Night)
	_expect_rejected(ANNEAL_TRUE, Salt)
	_expect_rejected(ANNEAL_TRUE, Wick)
	_expect_rejected(spare, Anneal)
	_expect_rejected(REHEARSAL_TRUE, Anneal)
	_expect_rejected(GILT_TRUE, Anneal)
	_expect_rejected(FERRY_TRUE, Anneal)
	_expect_rejected(WEATHER_TRUE, Anneal)
	_expect_rejected(LOOM_TRUE, Anneal)
	_expect_rejected(HIVE_TRUE, Anneal)
	_expect_rejected(GLASS_TRUE, Anneal)
	_expect_rejected(PRESS_TRUE, Anneal)
	_expect_rejected(ASSAY_TRUE, Anneal)
	_expect_rejected(KILN_TRUE, Anneal)
	_expect_rejected(TIDE_TRUE, Anneal)
	_expect_rejected(NIGHT_TRUE, Anneal)
	_expect_rejected(SALT_TRUE, Anneal)
	_expect_rejected(WICK_TRUE, Anneal)
	for person in Anneal.PEOPLE:
		if person == "Ivo":
			_expect(Rehearsal.PEOPLE.has(person), "glass anneal may share Ivo with the rehearsal score")
		else:
			_expect(not Rehearsal.PEOPLE.has(person), "anneal cast repeats %s from the rehearsal score" % person)
		_expect(not CaseData.PEOPLE.has(person), "anneal cast repeats %s from the spare key" % person)
		_expect(not Gilt.PEOPLE.has(person), "anneal cast repeats %s from the gilt stamp" % person)
		_expect(not Ferry.PEOPLE.has(person), "anneal cast repeats %s from the ferry bell" % person)
		_expect(not Weather.PEOPLE.has(person), "anneal cast repeats %s from the weather slate" % person)
		_expect(not Loom.PEOPLE.has(person), "anneal cast repeats %s from the loom shuttle" % person)
		_expect(not Hive.PEOPLE.has(person), "anneal cast repeats %s from the hive smoker" % person)
		_expect(not Glass.PEOPLE.has(person), "anneal cast repeats %s from the glass pontil" % person)
		_expect(not Press.PEOPLE.has(person), "anneal cast repeats %s from the press proof" % person)
		_expect(not Assay.PEOPLE.has(person), "anneal cast repeats %s from the assay cup" % person)
		_expect(not Kiln.PEOPLE.has(person), "anneal cast repeats %s from the kiln chalk" % person)
		_expect(not Tide.PEOPLE.has(person), "anneal cast repeats %s from the tide ledger" % person)
		_expect(not Night.PEOPLE.has(person), "anneal cast repeats %s from the night bell" % person)
		_expect(not Salt.PEOPLE.has(person), "anneal cast repeats %s from the salt mark" % person)
		_expect(not Wick.PEOPLE.has(person), "anneal cast repeats %s from the wick trim" % person)
	for forbidden_person in ["Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(not Anneal.PEOPLE.has(forbidden_person), "glass anneal cast must not take %s" % forbidden_person)
	_expect(Anneal.role_phrase("Tess") == "the anneal hand", "the glass anneal should call Tess the anneal hand")
	for place in Anneal.PLACES:
		_expect(not CaseData.PLACES.has(place), "anneal rooms repeat %s from the spare key" % place)
		_expect(not Rehearsal.PLACES.has(place), "anneal rooms repeat %s from the rehearsal score" % place)
		_expect(not Gilt.PLACES.has(place), "anneal rooms repeat %s from the gilt stamp" % place)
		_expect(not Ferry.PLACES.has(place), "anneal rooms repeat %s from the ferry bell" % place)
		_expect(not Weather.PLACES.has(place), "anneal rooms repeat %s from the weather slate" % place)
		_expect(not Loom.PLACES.has(place), "anneal rooms repeat %s from the loom shuttle" % place)
		_expect(not Hive.PLACES.has(place), "anneal rooms repeat %s from the hive smoker" % place)
		_expect(not Glass.PLACES.has(place), "anneal rooms repeat %s from the glass pontil" % place)
		_expect(not Press.PLACES.has(place), "anneal rooms repeat %s from the press proof" % place)
		_expect(not Assay.PLACES.has(place), "anneal rooms repeat %s from the assay cup" % place)
		_expect(not Kiln.PLACES.has(place), "anneal rooms repeat %s from the kiln chalk" % place)
		_expect(not Tide.PLACES.has(place), "anneal rooms repeat %s from the tide ledger" % place)
		_expect(not Night.PLACES.has(place), "anneal rooms repeat %s from the night bell" % place)
		_expect(not Salt.PLACES.has(place), "anneal rooms repeat %s from the salt mark" % place)
		_expect(not Wick.PLACES.has(place), "anneal rooms repeat %s from the wick trim" % place)
	for forbidden_place in ["loft", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(not Anneal.PLACES.has(forbidden_place), "glass anneal rooms must not take the %s" % forbidden_place)
	for hour in Anneal.HOURS:
		if hour == "8" or hour == "9":
			_expect(CaseData.HOURS.has(hour), "glass anneal hour %s may also sit on the spare key" % hour)
			_expect(not Weather.HOURS.has(hour), "glass anneal hours repeat %s from the weather slate" % hour)
		elif hour == "10" or hour == "11" or hour == "12":
			_expect(Weather.HOURS.has(hour), "glass anneal hour %s may also sit on the weather slate" % hour)
			_expect(not CaseData.HOURS.has(hour), "glass anneal hours repeat %s from the spare key" % hour)
		else:
			_expect(not CaseData.HOURS.has(hour), "glass anneal hours repeat %s from the spare key" % hour)
			_expect(not Weather.HOURS.has(hour), "glass anneal hours repeat %s from the weather slate" % hour)
		_expect(not Rehearsal.HOURS.has(hour), "anneal hours repeat %s from the rehearsal score" % hour)
		_expect(not Gilt.HOURS.has(hour), "anneal hours repeat %s from the gilt stamp" % hour)
		_expect(not Ferry.HOURS.has(hour), "anneal hours repeat %s from the ferry bell" % hour)
		_expect(not Loom.HOURS.has(hour), "anneal hours repeat %s from the loom shuttle" % hour)
		_expect(not Hive.HOURS.has(hour), "anneal hours repeat %s from the hive smoker" % hour)
		_expect(not Glass.HOURS.has(hour), "anneal hours repeat %s from the glass pontil" % hour)
		_expect(not Press.HOURS.has(hour), "anneal hours repeat %s from the press proof" % hour)
		_expect(not Assay.HOURS.has(hour), "anneal hours repeat %s from the assay cup" % hour)
		_expect(not Kiln.HOURS.has(hour), "anneal hours repeat %s from the kiln chalk" % hour)
		_expect(not Tide.HOURS.has(hour), "anneal hours repeat %s from the tide ledger" % hour)
		_expect(not Night.HOURS.has(hour), "anneal hours repeat %s from the night bell" % hour)
		_expect(not Salt.HOURS.has(hour), "anneal hours repeat %s from the salt mark" % hour)
		_expect(not Wick.HOURS.has(hour), "anneal hours repeat %s from the wick trim" % hour)
	_expect(not Anneal.HOURS.has("4"), "glass anneal hours must not take 4")
	_expect(not Anneal.HOURS.has("19"), "glass anneal hours must not take 19")
	_expect(GRAFT_TRUE["who"] == "Calder", "orchard graft taker")
	_expect(GRAFT_TRUE["place"] == "nursery", "orchard graft room")
	_expect(GRAFT_TRUE["hour"] == "16", "orchard graft hour")
	for forbidden in ["Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(GRAFT_TRUE["who"] != forbidden, "orchard graft accepted %s" % forbidden)
	for forbidden_place in ["lehr", "marver", "pot", "loft", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(GRAFT_TRUE["place"] != forbidden_place, "orchard graft accepted the %s" % forbidden_place)
	_expect(GRAFT_TRUE["hour"] != "10", "orchard graft accepted 10")
	_expect(GRAFT_TRUE["hour"] != "4", "orchard graft accepted 4")
	_expect(GRAFT_TRUE["hour"] != "19", "orchard graft accepted 19")
	_expect(GRAFT_TRUE["who"] != spare["who"], "orchard graft copied the spare-key taker")
	_expect(GRAFT_TRUE["place"] != spare["place"], "orchard graft copied the spare-key room")
	_expect(GRAFT_TRUE["hour"] != spare["hour"], "orchard graft copied the spare-key hour")
	_expect(GRAFT_TRUE["who"] != REHEARSAL_TRUE["who"], "orchard graft copied the rehearsal taker")
	_expect(GRAFT_TRUE["place"] != REHEARSAL_TRUE["place"], "orchard graft copied the rehearsal room")
	_expect(GRAFT_TRUE["hour"] != REHEARSAL_TRUE["hour"], "orchard graft copied the rehearsal hour")
	_expect(GRAFT_TRUE["who"] != GILT_TRUE["who"], "orchard graft copied the gilt taker")
	_expect(GRAFT_TRUE["place"] != GILT_TRUE["place"], "orchard graft copied the gilt room")
	_expect(GRAFT_TRUE["hour"] != GILT_TRUE["hour"], "orchard graft copied the gilt hour")
	_expect(GRAFT_TRUE["who"] != FERRY_TRUE["who"], "orchard graft copied the ferry taker")
	_expect(GRAFT_TRUE["place"] != FERRY_TRUE["place"], "orchard graft copied the ferry room")
	_expect(GRAFT_TRUE["hour"] != FERRY_TRUE["hour"], "orchard graft copied the ferry hour")
	_expect(GRAFT_TRUE["who"] != WEATHER_TRUE["who"], "orchard graft copied the weather taker")
	_expect(GRAFT_TRUE["place"] != WEATHER_TRUE["place"], "orchard graft copied the weather room")
	_expect(GRAFT_TRUE["hour"] != WEATHER_TRUE["hour"], "orchard graft copied the weather hour")
	_expect(GRAFT_TRUE["who"] != LOOM_TRUE["who"], "orchard graft copied the loom taker")
	_expect(GRAFT_TRUE["place"] != LOOM_TRUE["place"], "orchard graft copied the loom room")
	_expect(GRAFT_TRUE["hour"] != LOOM_TRUE["hour"], "orchard graft copied the loom hour")
	_expect(GRAFT_TRUE["who"] != HIVE_TRUE["who"], "orchard graft copied the hive taker")
	_expect(GRAFT_TRUE["place"] != HIVE_TRUE["place"], "orchard graft copied the hive room")
	_expect(GRAFT_TRUE["hour"] != HIVE_TRUE["hour"], "orchard graft copied the hive hour")
	_expect(GRAFT_TRUE["who"] != GLASS_TRUE["who"], "orchard graft copied the glass taker")
	_expect(GRAFT_TRUE["place"] != GLASS_TRUE["place"], "orchard graft copied the glass room")
	_expect(GRAFT_TRUE["hour"] != GLASS_TRUE["hour"], "orchard graft copied the glass hour")
	_expect(GRAFT_TRUE["who"] != PRESS_TRUE["who"], "orchard graft copied the press taker")
	_expect(GRAFT_TRUE["place"] != PRESS_TRUE["place"], "orchard graft copied the press room")
	_expect(GRAFT_TRUE["hour"] != PRESS_TRUE["hour"], "orchard graft copied the press hour")
	_expect(GRAFT_TRUE["who"] != ASSAY_TRUE["who"], "orchard graft copied the assay taker")
	_expect(GRAFT_TRUE["place"] != ASSAY_TRUE["place"], "orchard graft copied the assay room")
	_expect(GRAFT_TRUE["hour"] == "16" and ASSAY_TRUE["hour"] == "16", "orchard graft keeps 16, which also sits on the assay cup")
	_expect(GRAFT_TRUE["who"] != KILN_TRUE["who"], "orchard graft copied the kiln taker")
	_expect(GRAFT_TRUE["place"] != KILN_TRUE["place"], "orchard graft copied the kiln room")
	_expect(GRAFT_TRUE["hour"] != KILN_TRUE["hour"], "orchard graft copied the kiln hour")
	_expect(GRAFT_TRUE["who"] != TIDE_TRUE["who"], "orchard graft copied the tide taker")
	_expect(GRAFT_TRUE["place"] != TIDE_TRUE["place"], "orchard graft copied the tide room")
	_expect(GRAFT_TRUE["hour"] != TIDE_TRUE["hour"], "orchard graft copied the tide hour")
	_expect(GRAFT_TRUE["who"] != NIGHT_TRUE["who"], "orchard graft copied the night taker")
	_expect(GRAFT_TRUE["place"] != NIGHT_TRUE["place"], "orchard graft copied the night room")
	_expect(GRAFT_TRUE["hour"] != NIGHT_TRUE["hour"], "orchard graft copied the night hour")
	_expect(GRAFT_TRUE["who"] != SALT_TRUE["who"], "orchard graft copied the salt taker")
	_expect(GRAFT_TRUE["place"] != SALT_TRUE["place"], "orchard graft copied the salt room")
	_expect(GRAFT_TRUE["hour"] != SALT_TRUE["hour"], "orchard graft copied the salt hour")
	_expect(GRAFT_TRUE["who"] != WICK_TRUE["who"], "orchard graft copied the wick taker")
	_expect(GRAFT_TRUE["place"] != WICK_TRUE["place"], "orchard graft copied the wick room")
	_expect(GRAFT_TRUE["hour"] != WICK_TRUE["hour"], "orchard graft copied the wick hour")
	_expect(GRAFT_TRUE["who"] != ANNEAL_TRUE["who"], "orchard graft copied the anneal taker")
	_expect(GRAFT_TRUE["place"] != ANNEAL_TRUE["place"], "orchard graft copied the anneal room")
	_expect(GRAFT_TRUE["hour"] != ANNEAL_TRUE["hour"], "orchard graft copied the anneal hour")
	_expect(ANNEAL_TRUE["who"] == "Tess" and ANNEAL_TRUE["place"] == "lehr" and ANNEAL_TRUE["hour"] == "10", "the glass anneal should still accept Tess in the lehr at 10")
	_expect_rejected(GRAFT_TRUE, CaseData)
	_expect_rejected(GRAFT_TRUE, Rehearsal)
	_expect_rejected(GRAFT_TRUE, Gilt)
	_expect_rejected(GRAFT_TRUE, Ferry)
	_expect_rejected(GRAFT_TRUE, Weather)
	_expect_rejected(GRAFT_TRUE, Loom)
	_expect_rejected(GRAFT_TRUE, Hive)
	_expect_rejected(GRAFT_TRUE, Glass)
	_expect_rejected(GRAFT_TRUE, Press)
	_expect_rejected(GRAFT_TRUE, Assay)
	_expect_rejected(GRAFT_TRUE, Kiln)
	_expect_rejected(GRAFT_TRUE, Tide)
	_expect_rejected(GRAFT_TRUE, Night)
	_expect_rejected(GRAFT_TRUE, Salt)
	_expect_rejected(GRAFT_TRUE, Wick)
	_expect_rejected(GRAFT_TRUE, Anneal)
	_expect_rejected(spare, Graft)
	_expect_rejected(REHEARSAL_TRUE, Graft)
	_expect_rejected(GILT_TRUE, Graft)
	_expect_rejected(FERRY_TRUE, Graft)
	_expect_rejected(WEATHER_TRUE, Graft)
	_expect_rejected(LOOM_TRUE, Graft)
	_expect_rejected(HIVE_TRUE, Graft)
	_expect_rejected(GLASS_TRUE, Graft)
	_expect_rejected(PRESS_TRUE, Graft)
	_expect_rejected(ASSAY_TRUE, Graft)
	_expect_rejected(KILN_TRUE, Graft)
	_expect_rejected(TIDE_TRUE, Graft)
	_expect_rejected(NIGHT_TRUE, Graft)
	_expect_rejected(SALT_TRUE, Graft)
	_expect_rejected(WICK_TRUE, Graft)
	_expect_rejected(ANNEAL_TRUE, Graft)
	for person in Graft.PEOPLE:
		_expect(not CaseData.PEOPLE.has(person), "graft cast repeats %s from the spare key" % person)
		_expect(not Rehearsal.PEOPLE.has(person), "graft cast repeats %s from the rehearsal score" % person)
		_expect(not Gilt.PEOPLE.has(person), "graft cast repeats %s from the gilt stamp" % person)
		_expect(not Ferry.PEOPLE.has(person), "graft cast repeats %s from the ferry bell" % person)
		_expect(not Weather.PEOPLE.has(person), "graft cast repeats %s from the weather slate" % person)
		_expect(not Loom.PEOPLE.has(person), "graft cast repeats %s from the loom shuttle" % person)
		_expect(not Hive.PEOPLE.has(person), "graft cast repeats %s from the hive smoker" % person)
		_expect(not Glass.PEOPLE.has(person), "graft cast repeats %s from the glass pontil" % person)
		_expect(not Press.PEOPLE.has(person), "graft cast repeats %s from the press proof" % person)
		_expect(not Assay.PEOPLE.has(person), "graft cast repeats %s from the assay cup" % person)
		_expect(not Kiln.PEOPLE.has(person), "graft cast repeats %s from the kiln chalk" % person)
		_expect(not Tide.PEOPLE.has(person), "graft cast repeats %s from the tide ledger" % person)
		_expect(not Night.PEOPLE.has(person), "graft cast repeats %s from the night bell" % person)
		_expect(not Salt.PEOPLE.has(person), "graft cast repeats %s from the salt mark" % person)
		_expect(not Wick.PEOPLE.has(person), "graft cast repeats %s from the wick trim" % person)
		_expect(not Anneal.PEOPLE.has(person), "graft cast repeats %s from the glass anneal" % person)
	for forbidden_person in ["Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(not Graft.PEOPLE.has(forbidden_person), "orchard graft cast must not take %s" % forbidden_person)
	_expect(Graft.role_phrase("Calder") == "the graft hand", "the orchard graft should call Calder the graft hand")
	for place in Graft.PLACES:
		_expect(not CaseData.PLACES.has(place), "graft rooms repeat %s from the spare key" % place)
		_expect(not Rehearsal.PLACES.has(place), "graft rooms repeat %s from the rehearsal score" % place)
		_expect(not Gilt.PLACES.has(place), "graft rooms repeat %s from the gilt stamp" % place)
		_expect(not Ferry.PLACES.has(place), "graft rooms repeat %s from the ferry bell" % place)
		_expect(not Weather.PLACES.has(place), "graft rooms repeat %s from the weather slate" % place)
		_expect(not Loom.PLACES.has(place), "graft rooms repeat %s from the loom shuttle" % place)
		_expect(not Hive.PLACES.has(place), "graft rooms repeat %s from the hive smoker" % place)
		_expect(not Glass.PLACES.has(place), "graft rooms repeat %s from the glass pontil" % place)
		_expect(not Press.PLACES.has(place), "graft rooms repeat %s from the press proof" % place)
		_expect(not Assay.PLACES.has(place), "graft rooms repeat %s from the assay cup" % place)
		_expect(not Kiln.PLACES.has(place), "graft rooms repeat %s from the kiln chalk" % place)
		_expect(not Tide.PLACES.has(place), "graft rooms repeat %s from the tide ledger" % place)
		_expect(not Night.PLACES.has(place), "graft rooms repeat %s from the night bell" % place)
		_expect(not Salt.PLACES.has(place), "graft rooms repeat %s from the salt mark" % place)
		_expect(not Wick.PLACES.has(place), "graft rooms repeat %s from the wick trim" % place)
		_expect(not Anneal.PLACES.has(place), "graft rooms repeat %s from the glass anneal" % place)
	for forbidden_place in ["lehr", "marver", "pot", "loft", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(not Graft.PLACES.has(forbidden_place), "orchard graft rooms must not take the %s" % forbidden_place)
	for hour in Graft.HOURS:
		_expect(Assay.HOURS.has(hour), "orchard graft hour %s may also sit on the assay cup" % hour)
		if hour == "14" or hour == "15" or hour == "16":
			_expect(Ferry.HOURS.has(hour), "orchard graft hour %s may also sit on the ferry bell" % hour)
			_expect(not Loom.HOURS.has(hour), "orchard graft hours repeat %s from the loom shuttle" % hour)
			_expect(not Salt.HOURS.has(hour), "orchard graft hours repeat %s from the salt mark" % hour)
		elif hour == "17" or hour == "18":
			_expect(not Ferry.HOURS.has(hour), "orchard graft hours repeat %s from the ferry bell" % hour)
			_expect(Loom.HOURS.has(hour), "orchard graft hour %s may also sit on the loom shuttle" % hour)
			_expect(Salt.HOURS.has(hour), "orchard graft hour %s may also sit on the salt mark" % hour)
		else:
			_expect(not Ferry.HOURS.has(hour), "orchard graft hours repeat %s from the ferry bell" % hour)
			_expect(not Loom.HOURS.has(hour), "orchard graft hours repeat %s from the loom shuttle" % hour)
			_expect(not Salt.HOURS.has(hour), "orchard graft hours repeat %s from the salt mark" % hour)
		_expect(not CaseData.HOURS.has(hour), "graft hours repeat %s from the spare key" % hour)
		_expect(not Rehearsal.HOURS.has(hour), "graft hours repeat %s from the rehearsal score" % hour)
		_expect(not Gilt.HOURS.has(hour), "graft hours repeat %s from the gilt stamp" % hour)
		_expect(not Weather.HOURS.has(hour), "graft hours repeat %s from the weather slate" % hour)
		_expect(not Hive.HOURS.has(hour), "graft hours repeat %s from the hive smoker" % hour)
		_expect(not Glass.HOURS.has(hour), "graft hours repeat %s from the glass pontil" % hour)
		_expect(not Press.HOURS.has(hour), "graft hours repeat %s from the press proof" % hour)
		_expect(not Kiln.HOURS.has(hour), "graft hours repeat %s from the kiln chalk" % hour)
		_expect(not Tide.HOURS.has(hour), "graft hours repeat %s from the tide ledger" % hour)
		_expect(not Night.HOURS.has(hour), "graft hours repeat %s from the night bell" % hour)
		_expect(not Wick.HOURS.has(hour), "graft hours repeat %s from the wick trim" % hour)
		_expect(not Anneal.HOURS.has(hour), "graft hours repeat %s from the glass anneal" % hour)
	_expect(not Graft.HOURS.has("4"), "orchard graft hours must not take 4")
	_expect(not Graft.HOURS.has("10"), "orchard graft hours must not take 10")
	_expect(not Graft.HOURS.has("19"), "orchard graft hours must not take 19")

	_expect(DYE_TRUE["who"] == "Sera", "dye vat taker")
	_expect(DYE_TRUE["place"] == "vat", "dye vat room")
	_expect(DYE_TRUE["hour"] == "7", "dye vat hour")
	for forbidden in ["Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(DYE_TRUE["who"] != forbidden, "dye vat accepted %s" % forbidden)
	for forbidden_place in ["nursery", "row", "gate", "lehr", "marver", "pot", "loft", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(DYE_TRUE["place"] != forbidden_place, "dye vat accepted the %s" % forbidden_place)
	_expect(DYE_TRUE["hour"] != "16", "dye vat accepted 16")
	_expect(DYE_TRUE["hour"] != "10", "dye vat accepted 10")
	_expect(DYE_TRUE["hour"] != "4", "dye vat accepted 4")
	_expect(DYE_TRUE["hour"] != "19", "dye vat accepted 19")
	var earlier := [
		[CaseData, spare, "spare key"],
		[Rehearsal, REHEARSAL_TRUE, "rehearsal"],
		[Gilt, GILT_TRUE, "gilt stamp"],
		[Ferry, FERRY_TRUE, "ferry bell"],
		[Weather, WEATHER_TRUE, "weather slate"],
		[Loom, LOOM_TRUE, "loom shuttle"],
		[Hive, HIVE_TRUE, "hive smoker"],
		[Glass, GLASS_TRUE, "glass pontil"],
		[Press, PRESS_TRUE, "press proof"],
		[Assay, ASSAY_TRUE, "assay cup"],
		[Kiln, KILN_TRUE, "kiln chalk"],
		[Tide, TIDE_TRUE, "tide ledger"],
		[Night, NIGHT_TRUE, "night bell"],
		[Salt, SALT_TRUE, "salt mark"],
		[Wick, WICK_TRUE, "wick trim"],
		[Anneal, ANNEAL_TRUE, "glass anneal"],
		[Graft, GRAFT_TRUE, "orchard graft"],
	]
	for row in earlier:
		var book = row[0]
		var truth: Dictionary = row[1]
		var name := str(row[2])
		_expect(DYE_TRUE["who"] != truth["who"], "dye vat copied the %s taker" % name)
		_expect(DYE_TRUE["place"] != truth["place"], "dye vat copied the %s room" % name)
		if name == "spare key":
			_expect(DYE_TRUE["hour"] == str(truth["hour"]), "dye vat keeps 7, which also sits on the spare key")
		else:
			_expect(DYE_TRUE["hour"] != str(truth["hour"]), "dye vat copied the %s hour" % name)
		_expect_rejected(DYE_TRUE, book)
		_expect_rejected(truth, Dye)
	_expect(GRAFT_TRUE["who"] == "Calder" and GRAFT_TRUE["place"] == "nursery" and GRAFT_TRUE["hour"] == "16", "the orchard graft should still accept Calder in the nursery at 16")
	for row in earlier:
		var book = row[0]
		var name := str(row[2])
		for person in Dye.PEOPLE:
			if person == "Pim" and name == "weather slate":
				_expect(book.PEOPLE.has(person), "dye vat may share Pim with the weather slate")
			elif person == "Joss" and name == "loom shuttle":
				_expect(book.PEOPLE.has(person), "dye vat may share Joss with the loom shuttle")
			else:
				_expect(not book.PEOPLE.has(person), "dye cast repeats %s from the %s" % [person, name])
		for place in Dye.PLACES:
			_expect(not book.PLACES.has(place), "dye rooms repeat %s from the %s" % [place, name])
	for forbidden_person in ["Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(not Dye.PEOPLE.has(forbidden_person), "dye vat cast must not take %s" % forbidden_person)
	_expect(Dye.role_phrase("Sera") == "the dip hand", "the dye vat should call Sera the dip hand")
	for forbidden_place in ["nursery", "row", "gate", "lehr", "marver", "pot", "loft", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(not Dye.PLACES.has(forbidden_place), "dye vat rooms must not take the %s" % forbidden_place)
	var quiet_hours := [Gilt, Ferry, Weather, Loom, Hive, Glass, Press, Assay, Kiln, Tide, Night, Salt, Graft]
	for hour in Dye.HOURS:
		if hour == "5" or hour == "6":
			_expect(Rehearsal.HOURS.has(hour), "dye vat hour %s may also sit on the rehearsal score" % hour)
			_expect(Wick.HOURS.has(hour), "dye vat hour %s may also sit on the wick trim" % hour)
			_expect(not CaseData.HOURS.has(hour), "dye hours repeat %s from the spare key" % hour)
			_expect(not Anneal.HOURS.has(hour), "dye hours repeat %s from the glass anneal" % hour)
		elif hour == "7":
			_expect(CaseData.HOURS.has(hour), "dye vat hour %s may also sit on the spare key" % hour)
			_expect(not Rehearsal.HOURS.has(hour), "dye hours repeat %s from the rehearsal score" % hour)
			_expect(not Wick.HOURS.has(hour), "dye hours repeat %s from the wick trim" % hour)
			_expect(not Anneal.HOURS.has(hour), "dye hours repeat %s from the glass anneal" % hour)
		elif hour == "8" or hour == "9":
			_expect(CaseData.HOURS.has(hour), "dye vat hour %s may also sit on the spare key" % hour)
			_expect(Anneal.HOURS.has(hour), "dye vat hour %s may also sit on the glass anneal" % hour)
			_expect(not Rehearsal.HOURS.has(hour), "dye hours repeat %s from the rehearsal score" % hour)
			_expect(not Wick.HOURS.has(hour), "dye hours repeat %s from the wick trim" % hour)
		else:
			_expect(false, "unexpected dye hour %s" % hour)
		for book in quiet_hours:
			_expect(not book.HOURS.has(hour), "dye hours repeat %s" % hour)
	_expect(not Dye.HOURS.has("4"), "dye vat hours must not take 4")
	_expect(not Dye.HOURS.has("10"), "dye vat hours must not take 10")
	_expect(not Dye.HOURS.has("16"), "dye vat hours must not take 16")
	_expect(not Dye.HOURS.has("19"), "dye vat hours must not take 19")

	_expect(TAR_TRUE["who"] == "Rho", "tar kettle taker")
	_expect(TAR_TRUE["place"] == "kettle", "tar kettle room")
	_expect(TAR_TRUE["hour"] == "6", "tar kettle hour")
	for forbidden in ["Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(TAR_TRUE["who"] != forbidden, "tar kettle accepted %s" % forbidden)
	for forbidden_place in ["vat", "line", "yard", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(TAR_TRUE["place"] != forbidden_place, "tar kettle accepted the %s" % forbidden_place)
	_expect(TAR_TRUE["hour"] != "7", "tar kettle accepted 7")
	_expect(TAR_TRUE["hour"] != "16", "tar kettle accepted 16")
	_expect(TAR_TRUE["hour"] != "10", "tar kettle accepted 10")
	_expect(TAR_TRUE["hour"] != "4", "tar kettle accepted 4")
	_expect(TAR_TRUE["hour"] != "19", "tar kettle accepted 19")
	var before_tar: Array = earlier.duplicate()
	before_tar.append([Dye, DYE_TRUE, "dye vat"])
	for row in before_tar:
		var book = row[0]
		var truth: Dictionary = row[1]
		var name := str(row[2])
		_expect(TAR_TRUE["who"] != truth["who"], "tar kettle copied the %s taker" % name)
		_expect(TAR_TRUE["place"] != truth["place"], "tar kettle copied the %s room" % name)
		_expect(TAR_TRUE["hour"] != str(truth["hour"]), "tar kettle copied the %s hour" % name)
		_expect_rejected(TAR_TRUE, book)
		_expect_rejected(truth, Tar)
	_expect(DYE_TRUE["who"] == "Sera" and DYE_TRUE["place"] == "vat" and DYE_TRUE["hour"] == "7", "the dye vat should still accept Sera in the vat at 7")
	for row in before_tar:
		var book = row[0]
		var name := str(row[2])
		for person in Tar.PEOPLE:
			_expect(not book.PEOPLE.has(person), "tar cast repeats %s from the %s" % [person, name])
		for place in Tar.PLACES:
			if place == "loft" and name == "wick trim":
				_expect(book.PLACES.has(place), "tar kettle may share the loft with the wick trim")
			else:
				_expect(not book.PLACES.has(place), "tar rooms repeat %s from the %s" % [place, name])
	for forbidden_person in ["Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(not Tar.PEOPLE.has(forbidden_person), "tar kettle cast must not take %s" % forbidden_person)
	_expect(Tar.role_phrase("Rho") == "the tar hand", "the tar kettle should call Rho the tar hand")
	_expect(Tar.role_phrase("Lumen") == "the rope hand", "the tar kettle should call Lumen the rope hand")
	_expect(Tar.role_phrase("Kit") == "the walk clerk", "the tar kettle should call Kit the walk clerk")
	for forbidden_place in ["vat", "line", "yard", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(not Tar.PLACES.has(forbidden_place), "tar kettle rooms must not take the %s" % forbidden_place)
	var quiet_tar_hours := [Gilt, Ferry, Weather, Loom, Hive, Glass, Press, Assay, Kiln, Tide, Night, Salt, Graft]
	for hour in Tar.HOURS:
		if hour == "4":
			_expect(Rehearsal.HOURS.has(hour), "tar kettle hour %s may also sit on the rehearsal score" % hour)
			_expect(Wick.HOURS.has(hour), "tar kettle hour %s may also sit on the wick trim" % hour)
			_expect(not CaseData.HOURS.has(hour), "tar hours repeat %s from the spare key" % hour)
			_expect(not Dye.HOURS.has(hour), "tar hours repeat %s from the dye vat" % hour)
			_expect(not Anneal.HOURS.has(hour), "tar hours repeat %s from the glass anneal" % hour)
		elif hour == "5" or hour == "6":
			_expect(Rehearsal.HOURS.has(hour), "tar kettle hour %s may also sit on the rehearsal score" % hour)
			_expect(Wick.HOURS.has(hour), "tar kettle hour %s may also sit on the wick trim" % hour)
			_expect(Dye.HOURS.has(hour), "tar kettle hour %s may also sit on the dye vat" % hour)
			_expect(not CaseData.HOURS.has(hour), "tar hours repeat %s from the spare key" % hour)
			_expect(not Anneal.HOURS.has(hour), "tar hours repeat %s from the glass anneal" % hour)
		elif hour == "7":
			_expect(CaseData.HOURS.has(hour), "tar kettle hour %s may also sit on the spare key" % hour)
			_expect(Dye.HOURS.has(hour), "tar kettle hour %s may also sit on the dye vat" % hour)
			_expect(not Rehearsal.HOURS.has(hour), "tar hours repeat %s from the rehearsal score" % hour)
			_expect(not Wick.HOURS.has(hour), "tar hours repeat %s from the wick trim" % hour)
			_expect(not Anneal.HOURS.has(hour), "tar hours repeat %s from the glass anneal" % hour)
		elif hour == "8":
			_expect(CaseData.HOURS.has(hour), "tar kettle hour %s may also sit on the spare key" % hour)
			_expect(Dye.HOURS.has(hour), "tar kettle hour %s may also sit on the dye vat" % hour)
			_expect(Anneal.HOURS.has(hour), "tar kettle hour %s may also sit on the glass anneal" % hour)
			_expect(not Rehearsal.HOURS.has(hour), "tar hours repeat %s from the rehearsal score" % hour)
			_expect(not Wick.HOURS.has(hour), "tar hours repeat %s from the wick trim" % hour)
		else:
			_expect(false, "unexpected tar hour %s" % hour)
		for book in quiet_tar_hours:
			_expect(not book.HOURS.has(hour), "tar hours repeat %s" % hour)
	_expect(not Tar.HOURS.has("9"), "tar kettle hours must not take 9")
	_expect(not Tar.HOURS.has("10"), "tar kettle hours must not take 10")
	_expect(not Tar.HOURS.has("16"), "tar kettle hours must not take 16")
	_expect(not Tar.HOURS.has("19"), "tar kettle hours must not take 19")
	_expect(CORK_TRUE["who"] == "Brea", "cork press taker")
	_expect(CORK_TRUE["place"] == "press", "cork press room")
	_expect(CORK_TRUE["hour"] == "5", "cork press hour")
	for forbidden in ["Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(CORK_TRUE["who"] != forbidden, "cork press accepted %s" % forbidden)
	for forbidden_place in ["kettle", "walk", "loft", "vat", "line", "yard", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(CORK_TRUE["place"] != forbidden_place, "cork press accepted the %s" % forbidden_place)
	_expect(CORK_TRUE["hour"] != "6", "cork press accepted 6")
	_expect(CORK_TRUE["hour"] != "7", "cork press accepted 7")
	_expect(CORK_TRUE["hour"] != "4", "cork press accepted 4")
	_expect(CORK_TRUE["hour"] != "3", "cork press accepted 3")
	_expect(CORK_TRUE["hour"] != "16", "cork press accepted 16")
	_expect(CORK_TRUE["hour"] != "10", "cork press accepted 10")
	_expect(CORK_TRUE["hour"] != "19", "cork press accepted 19")
	var before_cork: Array = before_tar.duplicate()
	before_cork.append([Tar, TAR_TRUE, "tar kettle"])
	for row in before_cork:
		var book = row[0]
		var truth: Dictionary = row[1]
		var name := str(row[2])
		_expect(CORK_TRUE["who"] != truth["who"], "cork press copied the %s taker" % name)
		_expect(CORK_TRUE["place"] != truth["place"], "cork press copied the %s room" % name)
		_expect(CORK_TRUE["hour"] != str(truth["hour"]), "cork press copied the %s hour" % name)
		_expect_rejected(CORK_TRUE, book)
		_expect_rejected(truth, Cork)
	_expect(TAR_TRUE["who"] == "Rho" and TAR_TRUE["place"] == "kettle" and TAR_TRUE["hour"] == "6", "the tar kettle should still accept Rho in the kettle at 6")
	for row in before_cork:
		var book = row[0]
		var name := str(row[2])
		for person in Cork.PEOPLE:
			_expect(not book.PEOPLE.has(person), "cork cast repeats %s from the %s" % [person, name])
		for place in Cork.PLACES:
			_expect(not book.PLACES.has(place), "cork rooms repeat %s from the %s" % [place, name])
	for forbidden_person in ["Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(not Cork.PEOPLE.has(forbidden_person), "cork press cast must not take %s" % forbidden_person)
	_expect(Cork.role_phrase("Brea") == "the cork hand", "the cork press should call Brea the cork hand")
	_expect(Cork.role_phrase("Ansel") == "the press hand", "the cork press should call Ansel the press hand")
	_expect(Cork.role_phrase("Colm") == "the cellar clerk", "the cork press should call Colm the cellar clerk")
	for forbidden_place in ["kettle", "walk", "loft", "vat", "line", "yard", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(not Cork.PLACES.has(forbidden_place), "cork press rooms must not take the %s" % forbidden_place)
	var quiet_cork_hours := [Ferry, Weather, Loom, Hive, Glass, Press, Assay, Kiln, Tide, Night, Salt, Anneal, Graft]
	for hour in Cork.HOURS:
		if hour == "3":
			_expect(Gilt.HOURS.has(hour), "cork press hour %s may also sit on the gilt stamp" % hour)
			_expect(Wick.HOURS.has(hour), "cork press hour %s may also sit on the wick trim" % hour)
			_expect(not Rehearsal.HOURS.has(hour), "cork hours repeat %s from the rehearsal score" % hour)
			_expect(not CaseData.HOURS.has(hour), "cork hours repeat %s from the spare key" % hour)
			_expect(not Dye.HOURS.has(hour), "cork hours repeat %s from the dye vat" % hour)
			_expect(not Tar.HOURS.has(hour), "cork hours repeat %s from the tar kettle" % hour)
			_expect(not Anneal.HOURS.has(hour), "cork hours repeat %s from the glass anneal" % hour)
		elif hour == "4":
			_expect(Rehearsal.HOURS.has(hour), "cork press hour %s may also sit on the rehearsal score" % hour)
			_expect(Wick.HOURS.has(hour), "cork press hour %s may also sit on the wick trim" % hour)
			_expect(Tar.HOURS.has(hour), "cork press hour %s may also sit on the tar kettle" % hour)
			_expect(not Gilt.HOURS.has(hour), "cork hours repeat %s from the gilt stamp" % hour)
			_expect(not CaseData.HOURS.has(hour), "cork hours repeat %s from the spare key" % hour)
			_expect(not Dye.HOURS.has(hour), "cork hours repeat %s from the dye vat" % hour)
			_expect(not Anneal.HOURS.has(hour), "cork hours repeat %s from the glass anneal" % hour)
		elif hour == "5" or hour == "6":
			_expect(Rehearsal.HOURS.has(hour), "cork press hour %s may also sit on the rehearsal score" % hour)
			_expect(Wick.HOURS.has(hour), "cork press hour %s may also sit on the wick trim" % hour)
			_expect(Dye.HOURS.has(hour), "cork press hour %s may also sit on the dye vat" % hour)
			_expect(Tar.HOURS.has(hour), "cork press hour %s may also sit on the tar kettle" % hour)
			_expect(not Gilt.HOURS.has(hour), "cork hours repeat %s from the gilt stamp" % hour)
			_expect(not CaseData.HOURS.has(hour), "cork hours repeat %s from the spare key" % hour)
			_expect(not Anneal.HOURS.has(hour), "cork hours repeat %s from the glass anneal" % hour)
		elif hour == "7":
			_expect(CaseData.HOURS.has(hour), "cork press hour %s may also sit on the spare key" % hour)
			_expect(Dye.HOURS.has(hour), "cork press hour %s may also sit on the dye vat" % hour)
			_expect(Tar.HOURS.has(hour), "cork press hour %s may also sit on the tar kettle" % hour)
			_expect(not Rehearsal.HOURS.has(hour), "cork hours repeat %s from the rehearsal score" % hour)
			_expect(not Wick.HOURS.has(hour), "cork hours repeat %s from the wick trim" % hour)
			_expect(not Gilt.HOURS.has(hour), "cork hours repeat %s from the gilt stamp" % hour)
			_expect(not Anneal.HOURS.has(hour), "cork hours repeat %s from the glass anneal" % hour)
		else:
			_expect(false, "unexpected cork hour %s" % hour)
		for book in quiet_cork_hours:
			_expect(not book.HOURS.has(hour), "cork hours repeat %s" % hour)
	_expect(not Cork.HOURS.has("2"), "cork press hours must not take 2")
	_expect(not Cork.HOURS.has("8"), "cork press hours must not take 8")
	_expect(not Cork.HOURS.has("9"), "cork press hours must not take 9")
	_expect(not Cork.HOURS.has("10"), "cork press hours must not take 10")
	_expect(not Cork.HOURS.has("16"), "cork press hours must not take 16")
	_expect(not Cork.HOURS.has("19"), "cork press hours must not take 19")
	_expect(NET_TRUE["who"] == "Hester", "net loft taker")
	_expect(NET_TRUE["place"] == "loft", "net loft room")
	_expect(NET_TRUE["hour"] == "4", "net loft hour")
	for forbidden in ["Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(NET_TRUE["who"] != forbidden, "net loft accepted %s" % forbidden)
	for forbidden_place in ["press", "cellar", "bench", "kettle", "walk", "vat", "line", "yard", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(NET_TRUE["place"] != forbidden_place, "net loft accepted the %s" % forbidden_place)
	_expect(NET_TRUE["hour"] != "2", "net loft accepted 2")
	_expect(NET_TRUE["hour"] != "3", "net loft accepted 3")
	_expect(NET_TRUE["hour"] != "5", "net loft accepted 5")
	_expect(NET_TRUE["hour"] != "6", "net loft accepted 6")
	_expect(NET_TRUE["hour"] != "7", "net loft accepted 7")
	_expect(NET_TRUE["hour"] != "16", "net loft accepted 16")
	_expect(NET_TRUE["hour"] != "10", "net loft accepted 10")
	_expect(NET_TRUE["hour"] != "19", "net loft accepted 19")
	var before_net: Array = before_cork.duplicate()
	before_net.append([Cork, CORK_TRUE, "cork press"])
	for row in before_net:
		var book = row[0]
		var truth: Dictionary = row[1]
		var name := str(row[2])
		_expect(NET_TRUE["who"] != truth["who"], "net loft copied the %s taker" % name)
		if name == "wick trim":
			_expect(NET_TRUE["place"] == truth["place"], "net loft keeps the loft, which also sits on the wick trim")
		else:
			_expect(NET_TRUE["place"] != truth["place"], "net loft copied the %s room" % name)
		if name == "wick trim" or name == "rehearsal":
			_expect(NET_TRUE["hour"] == str(truth["hour"]), "net loft keeps 4, which also sits on the %s" % name)
		else:
			_expect(NET_TRUE["hour"] != str(truth["hour"]), "net loft copied the %s hour" % name)
		_expect_rejected(NET_TRUE, book)
		_expect_rejected(truth, Net)
	_expect(CORK_TRUE["who"] == "Brea" and CORK_TRUE["place"] == "press" and CORK_TRUE["hour"] == "5", "the cork press should still accept Brea in the press at 5")
	for row in before_net:
		var book = row[0]
		var name := str(row[2])
		for person in Net.PEOPLE:
			_expect(not book.PEOPLE.has(person), "net cast repeats %s from the %s" % [person, name])
		for place in Net.PLACES:
			if place == "loft" and (name == "wick trim" or name == "tar kettle"):
				_expect(book.PLACES.has(place), "net loft may share the loft with the %s" % name)
			else:
				_expect(not book.PLACES.has(place), "net rooms repeat %s from the %s" % [place, name])
	for forbidden_person in ["Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(not Net.PEOPLE.has(forbidden_person), "net loft cast must not take %s" % forbidden_person)
	_expect(Net.role_phrase("Hester") == "the mend hand", "the net loft should call Hester the mend hand")
	_expect(Net.role_phrase("Gwyn") == "the net hand", "the net loft should call Gwyn the net hand")
	_expect(Net.role_phrase("Idris") == "the shed clerk", "the net loft should call Idris the shed clerk")
	for forbidden_place in ["press", "cellar", "bench", "kettle", "walk", "vat", "line", "yard", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(not Net.PLACES.has(forbidden_place), "net loft rooms must not take the %s" % forbidden_place)
	var quiet_net_hours := [Ferry, Weather, Loom, Hive, Glass, Press, Assay, Kiln, Tide, Night, Salt, Anneal, Graft]
	for hour in Net.HOURS:
		if hour == "2":
			_expect(Gilt.HOURS.has(hour), "net loft hour %s may also sit on the gilt stamp" % hour)
			_expect(Wick.HOURS.has(hour), "net loft hour %s may also sit on the wick trim" % hour)
			_expect(not Rehearsal.HOURS.has(hour), "net hours repeat %s from the rehearsal score" % hour)
			_expect(not CaseData.HOURS.has(hour), "net hours repeat %s from the spare key" % hour)
			_expect(not Dye.HOURS.has(hour), "net hours repeat %s from the dye vat" % hour)
			_expect(not Tar.HOURS.has(hour), "net hours repeat %s from the tar kettle" % hour)
			_expect(not Cork.HOURS.has(hour), "net hours repeat %s from the cork press" % hour)
			_expect(not Anneal.HOURS.has(hour), "net hours repeat %s from the glass anneal" % hour)
		elif hour == "3":
			_expect(Gilt.HOURS.has(hour), "net loft hour %s may also sit on the gilt stamp" % hour)
			_expect(Wick.HOURS.has(hour), "net loft hour %s may also sit on the wick trim" % hour)
			_expect(Cork.HOURS.has(hour), "net loft hour %s may also sit on the cork press" % hour)
			_expect(not Rehearsal.HOURS.has(hour), "net hours repeat %s from the rehearsal score" % hour)
			_expect(not CaseData.HOURS.has(hour), "net hours repeat %s from the spare key" % hour)
			_expect(not Dye.HOURS.has(hour), "net hours repeat %s from the dye vat" % hour)
			_expect(not Tar.HOURS.has(hour), "net hours repeat %s from the tar kettle" % hour)
			_expect(not Anneal.HOURS.has(hour), "net hours repeat %s from the glass anneal" % hour)
		elif hour == "4":
			_expect(Rehearsal.HOURS.has(hour), "net loft hour %s may also sit on the rehearsal score" % hour)
			_expect(Wick.HOURS.has(hour), "net loft hour %s may also sit on the wick trim" % hour)
			_expect(Tar.HOURS.has(hour), "net loft hour %s may also sit on the tar kettle" % hour)
			_expect(Cork.HOURS.has(hour), "net loft hour %s may also sit on the cork press" % hour)
			_expect(not Gilt.HOURS.has(hour), "net hours repeat %s from the gilt stamp" % hour)
			_expect(not CaseData.HOURS.has(hour), "net hours repeat %s from the spare key" % hour)
			_expect(not Dye.HOURS.has(hour), "net hours repeat %s from the dye vat" % hour)
			_expect(not Anneal.HOURS.has(hour), "net hours repeat %s from the glass anneal" % hour)
		elif hour == "5" or hour == "6":
			_expect(Rehearsal.HOURS.has(hour), "net loft hour %s may also sit on the rehearsal score" % hour)
			_expect(Wick.HOURS.has(hour), "net loft hour %s may also sit on the wick trim" % hour)
			_expect(Dye.HOURS.has(hour), "net loft hour %s may also sit on the dye vat" % hour)
			_expect(Tar.HOURS.has(hour), "net loft hour %s may also sit on the tar kettle" % hour)
			_expect(Cork.HOURS.has(hour), "net loft hour %s may also sit on the cork press" % hour)
			_expect(not Gilt.HOURS.has(hour), "net hours repeat %s from the gilt stamp" % hour)
			_expect(not CaseData.HOURS.has(hour), "net hours repeat %s from the spare key" % hour)
			_expect(not Anneal.HOURS.has(hour), "net hours repeat %s from the glass anneal" % hour)
		else:
			_expect(false, "unexpected net hour %s" % hour)
		for book in quiet_net_hours:
			_expect(not book.HOURS.has(hour), "net hours repeat %s" % hour)
	_expect(not Net.HOURS.has("1"), "net loft hours must not take 1")
	_expect(not Net.HOURS.has("7"), "net loft hours must not take 7")
	_expect(not Net.HOURS.has("8"), "net loft hours must not take 8")
	_expect(not Net.HOURS.has("9"), "net loft hours must not take 9")
	_expect(not Net.HOURS.has("10"), "net loft hours must not take 10")
	_expect(not Net.HOURS.has("16"), "net loft hours must not take 16")
	_expect(not Net.HOURS.has("19"), "net loft hours must not take 19")
	_expect(CASK_TRUE["who"] == "Maeve", "cask hoop taker")
	_expect(CASK_TRUE["place"] == "shop", "cask hoop room")
	_expect(CASK_TRUE["hour"] == "3", "cask hoop hour")
	for forbidden in ["Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(CASK_TRUE["who"] != forbidden, "cask hoop accepted %s" % forbidden)
	for forbidden_place in ["loft", "shed", "rail", "press", "cellar", "kettle", "walk", "vat", "line", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(CASK_TRUE["place"] != forbidden_place, "cask hoop accepted the %s" % forbidden_place)
	_expect(CASK_TRUE["hour"] != "1", "cask hoop accepted 1")
	_expect(CASK_TRUE["hour"] != "2", "cask hoop accepted 2")
	_expect(CASK_TRUE["hour"] != "4", "cask hoop accepted 4")
	_expect(CASK_TRUE["hour"] != "5", "cask hoop accepted 5")
	_expect(CASK_TRUE["hour"] != "6", "cask hoop accepted 6")
	_expect(CASK_TRUE["hour"] != "7", "cask hoop accepted 7")
	_expect(CASK_TRUE["hour"] != "16", "cask hoop accepted 16")
	_expect(CASK_TRUE["hour"] != "10", "cask hoop accepted 10")
	_expect(CASK_TRUE["hour"] != "19", "cask hoop accepted 19")
	var before_cask: Array = before_net.duplicate()
	before_cask.append([Net, NET_TRUE, "net loft"])
	for row in before_cask:
		var book = row[0]
		var truth: Dictionary = row[1]
		var name := str(row[2])
		_expect(CASK_TRUE["who"] != truth["who"], "cask hoop copied the %s taker" % name)
		_expect(CASK_TRUE["place"] != truth["place"], "cask hoop copied the %s room" % name)
		_expect(CASK_TRUE["hour"] != str(truth["hour"]), "cask hoop copied the %s hour" % name)
		_expect_rejected(CASK_TRUE, book)
		_expect_rejected(truth, Cask)
	_expect(NET_TRUE["who"] == "Hester" and NET_TRUE["place"] == "loft" and NET_TRUE["hour"] == "4", "the net loft should still accept Hester in the loft at 4")
	for row in before_cask:
		var book = row[0]
		var name := str(row[2])
		for person in Cask.PEOPLE:
			_expect(not book.PEOPLE.has(person), "cask cast repeats %s from the %s" % [person, name])
		for place in Cask.PLACES:
			if place == "yard" and name == "dye vat":
				_expect(book.PLACES.has(place), "cask hoop may share the yard with the dye vat")
			elif place == "bench" and name == "cork press":
				_expect(book.PLACES.has(place), "cask hoop may share the bench with the cork press")
			else:
				_expect(not book.PLACES.has(place), "cask rooms repeat %s from the %s" % [place, name])
	for forbidden_person in ["Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(not Cask.PEOPLE.has(forbidden_person), "cask hoop cast must not take %s" % forbidden_person)
	_expect(Cask.role_phrase("Maeve") == "the shop hand", "the cask hoop should call Maeve the shop hand")
	_expect(Cask.role_phrase("Jory") == "the hoop hand", "the cask hoop should call Jory the hoop hand")
	_expect(Cask.role_phrase("Perrin") == "the yard clerk", "the cask hoop should call Perrin the yard clerk")
	for forbidden_place in ["loft", "shed", "rail", "press", "cellar", "kettle", "walk", "vat", "line", "dye_house", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(not Cask.PLACES.has(forbidden_place), "cask hoop rooms must not take the %s" % forbidden_place)
	var quiet_cask_hours := [Ferry, Weather, Loom, Hive, Glass, Press, Assay, Kiln, Tide, Night, Salt, Anneal, Graft]
	for hour in Cask.HOURS:
		if hour == "1":
			_expect(Gilt.HOURS.has(hour), "cask hoop hour %s may also sit on the gilt stamp" % hour)
			_expect(not Wick.HOURS.has(hour), "cask hours repeat %s from the wick trim" % hour)
			_expect(not Rehearsal.HOURS.has(hour), "cask hours repeat %s from the rehearsal score" % hour)
			_expect(not CaseData.HOURS.has(hour), "cask hours repeat %s from the spare key" % hour)
			_expect(not Dye.HOURS.has(hour), "cask hours repeat %s from the dye vat" % hour)
			_expect(not Tar.HOURS.has(hour), "cask hours repeat %s from the tar kettle" % hour)
			_expect(not Cork.HOURS.has(hour), "cask hours repeat %s from the cork press" % hour)
			_expect(not Net.HOURS.has(hour), "cask hours repeat %s from the net loft" % hour)
			_expect(not Anneal.HOURS.has(hour), "cask hours repeat %s from the glass anneal" % hour)
		elif hour == "2":
			_expect(Gilt.HOURS.has(hour), "cask hoop hour %s may also sit on the gilt stamp" % hour)
			_expect(Wick.HOURS.has(hour), "cask hoop hour %s may also sit on the wick trim" % hour)
			_expect(Net.HOURS.has(hour), "cask hoop hour %s may also sit on the net loft" % hour)
			_expect(not Rehearsal.HOURS.has(hour), "cask hours repeat %s from the rehearsal score" % hour)
			_expect(not CaseData.HOURS.has(hour), "cask hours repeat %s from the spare key" % hour)
			_expect(not Dye.HOURS.has(hour), "cask hours repeat %s from the dye vat" % hour)
			_expect(not Tar.HOURS.has(hour), "cask hours repeat %s from the tar kettle" % hour)
			_expect(not Cork.HOURS.has(hour), "cask hours repeat %s from the cork press" % hour)
			_expect(not Anneal.HOURS.has(hour), "cask hours repeat %s from the glass anneal" % hour)
		elif hour == "3":
			_expect(Gilt.HOURS.has(hour), "cask hoop hour %s may also sit on the gilt stamp" % hour)
			_expect(Wick.HOURS.has(hour), "cask hoop hour %s may also sit on the wick trim" % hour)
			_expect(Cork.HOURS.has(hour), "cask hoop hour %s may also sit on the cork press" % hour)
			_expect(Net.HOURS.has(hour), "cask hoop hour %s may also sit on the net loft" % hour)
			_expect(not Rehearsal.HOURS.has(hour), "cask hours repeat %s from the rehearsal score" % hour)
			_expect(not CaseData.HOURS.has(hour), "cask hours repeat %s from the spare key" % hour)
			_expect(not Dye.HOURS.has(hour), "cask hours repeat %s from the dye vat" % hour)
			_expect(not Tar.HOURS.has(hour), "cask hours repeat %s from the tar kettle" % hour)
			_expect(not Anneal.HOURS.has(hour), "cask hours repeat %s from the glass anneal" % hour)
		elif hour == "4":
			_expect(Rehearsal.HOURS.has(hour), "cask hoop hour %s may also sit on the rehearsal score" % hour)
			_expect(Wick.HOURS.has(hour), "cask hoop hour %s may also sit on the wick trim" % hour)
			_expect(Tar.HOURS.has(hour), "cask hoop hour %s may also sit on the tar kettle" % hour)
			_expect(Cork.HOURS.has(hour), "cask hoop hour %s may also sit on the cork press" % hour)
			_expect(Net.HOURS.has(hour), "cask hoop hour %s may also sit on the net loft" % hour)
			_expect(not Gilt.HOURS.has(hour), "cask hours repeat %s from the gilt stamp" % hour)
			_expect(not CaseData.HOURS.has(hour), "cask hours repeat %s from the spare key" % hour)
			_expect(not Dye.HOURS.has(hour), "cask hours repeat %s from the dye vat" % hour)
			_expect(not Anneal.HOURS.has(hour), "cask hours repeat %s from the glass anneal" % hour)
		elif hour == "5":
			_expect(Rehearsal.HOURS.has(hour), "cask hoop hour %s may also sit on the rehearsal score" % hour)
			_expect(Wick.HOURS.has(hour), "cask hoop hour %s may also sit on the wick trim" % hour)
			_expect(Dye.HOURS.has(hour), "cask hoop hour %s may also sit on the dye vat" % hour)
			_expect(Tar.HOURS.has(hour), "cask hoop hour %s may also sit on the tar kettle" % hour)
			_expect(Cork.HOURS.has(hour), "cask hoop hour %s may also sit on the cork press" % hour)
			_expect(Net.HOURS.has(hour), "cask hoop hour %s may also sit on the net loft" % hour)
			_expect(not Gilt.HOURS.has(hour), "cask hours repeat %s from the gilt stamp" % hour)
			_expect(not CaseData.HOURS.has(hour), "cask hours repeat %s from the spare key" % hour)
			_expect(not Anneal.HOURS.has(hour), "cask hours repeat %s from the glass anneal" % hour)
		else:
			_expect(false, "unexpected cask hour %s" % hour)
		for book in quiet_cask_hours:
			_expect(not book.HOURS.has(hour), "cask hours repeat %s" % hour)
	_expect(not Cask.HOURS.has("6"), "cask hoop hours must not take 6")
	_expect(not Cask.HOURS.has("7"), "cask hoop hours must not take 7")
	_expect(not Cask.HOURS.has("8"), "cask hoop hours must not take 8")
	_expect(not Cask.HOURS.has("9"), "cask hoop hours must not take 9")
	_expect(not Cask.HOURS.has("10"), "cask hoop hours must not take 10")
	_expect(not Cask.HOURS.has("16"), "cask hoop hours must not take 16")
	_expect(not Cask.HOURS.has("19"), "cask hoop hours must not take 19")
	_expect(LINEN_TRUE["who"] == "Vetch", "linen fold taker")
	_expect(LINEN_TRUE["place"] == "press", "linen fold room")
	_expect(LINEN_TRUE["hour"] == "8", "linen fold hour")
	for forbidden in ["Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(LINEN_TRUE["who"] != forbidden, "linen fold accepted %s" % forbidden)
	for forbidden_place in ["loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(LINEN_TRUE["place"] != forbidden_place, "linen fold accepted the %s" % forbidden_place)
	_expect(LINEN_TRUE["hour"] != "6", "linen fold accepted 6")
	_expect(LINEN_TRUE["hour"] != "7", "linen fold accepted 7")
	_expect(LINEN_TRUE["hour"] != "9", "linen fold accepted 9")
	_expect(LINEN_TRUE["hour"] != "10", "linen fold accepted 10")
	_expect(LINEN_TRUE["hour"] != "5", "linen fold accepted 5")
	_expect(LINEN_TRUE["hour"] != "4", "linen fold accepted 4")
	_expect(LINEN_TRUE["hour"] != "3", "linen fold accepted 3")
	_expect(LINEN_TRUE["hour"] != "16", "linen fold accepted 16")
	_expect(LINEN_TRUE["hour"] != "19", "linen fold accepted 19")
	var before_linen: Array = before_cask.duplicate()
	before_linen.append([Cask, CASK_TRUE, "cask hoop"])
	for row in before_linen:
		var book = row[0]
		var truth: Dictionary = row[1]
		var name := str(row[2])
		_expect(LINEN_TRUE["who"] != truth["who"], "linen fold copied the %s taker" % name)
		if name == "cork press":
			_expect(LINEN_TRUE["place"] == truth["place"], "linen fold keeps the press, which also sits on the cork press")
		else:
			_expect(LINEN_TRUE["place"] != truth["place"], "linen fold copied the %s room" % name)
		_expect(LINEN_TRUE["hour"] != str(truth["hour"]), "linen fold copied the %s hour" % name)
		_expect_rejected(LINEN_TRUE, book)
		_expect_rejected(truth, Linen)
	_expect(CASK_TRUE["who"] == "Maeve" and CASK_TRUE["place"] == "shop" and CASK_TRUE["hour"] == "3", "the cask hoop should still accept Maeve in the shop at 3")
	for row in before_linen:
		var book = row[0]
		var name := str(row[2])
		for person in Linen.PEOPLE:
			_expect(not book.PEOPLE.has(person), "linen cast repeats %s from the %s" % [person, name])
		for place in Linen.PLACES:
			if place == "press" and name == "cork press":
				_expect(book.PLACES.has(place), "linen fold may share the press with the cork press")
			elif place == "loft" and (name == "net loft" or name == "wick trim" or name == "tar kettle"):
				_expect(book.PLACES.has(place), "linen fold may share the loft with the %s" % name)
			elif place == "bench" and (name == "cork press" or name == "cask hoop"):
				_expect(book.PLACES.has(place), "linen fold may share the bench with the %s" % name)
			else:
				_expect(not book.PLACES.has(place), "linen rooms repeat %s from the %s" % [place, name])
	for forbidden_person in ["Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(not Linen.PEOPLE.has(forbidden_person), "linen fold cast must not take %s" % forbidden_person)
	_expect(Linen.role_phrase("Vetch") == "the press hand", "the linen fold should call Vetch the press hand")
	_expect(Linen.role_phrase("Odell") == "the fold hand", "the linen fold should call Odell the fold hand")
	_expect(Linen.role_phrase("Brigg") == "the loft clerk", "the linen fold should call Brigg the loft clerk")
	for forbidden_place in ["shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "dye_house", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(not Linen.PLACES.has(forbidden_place), "linen fold rooms must not take the %s" % forbidden_place)
	var quiet_linen_hours := [Gilt, Ferry, Loom, Hive, Glass, Press, Assay, Kiln, Tide, Night, Salt, Graft, Cask]
	for hour in Linen.HOURS:
		if hour == "6":
			_expect(Rehearsal.HOURS.has(hour), "linen fold hour %s may also sit on the rehearsal score" % hour)
			_expect(Wick.HOURS.has(hour), "linen fold hour %s may also sit on the wick trim" % hour)
			_expect(Cork.HOURS.has(hour), "linen fold hour %s may also sit on the cork press" % hour)
			_expect(Net.HOURS.has(hour), "linen fold hour %s may also sit on the net loft" % hour)
			_expect(Tar.HOURS.has(hour), "linen fold hour %s may also sit on the tar kettle" % hour)
			_expect(Dye.HOURS.has(hour), "linen fold hour %s may also sit on the dye vat" % hour)
			_expect(not CaseData.HOURS.has(hour), "linen hours repeat %s from the spare key" % hour)
			_expect(not Anneal.HOURS.has(hour), "linen hours repeat %s from the glass anneal" % hour)
			_expect(not Weather.HOURS.has(hour), "linen hours repeat %s from the weather slate" % hour)
		elif hour == "7":
			_expect(CaseData.HOURS.has(hour), "linen fold hour %s may also sit on the spare key" % hour)
			_expect(Cork.HOURS.has(hour), "linen fold hour %s may also sit on the cork press" % hour)
			_expect(Tar.HOURS.has(hour), "linen fold hour %s may also sit on the tar kettle" % hour)
			_expect(Dye.HOURS.has(hour), "linen fold hour %s may also sit on the dye vat" % hour)
			_expect(not Rehearsal.HOURS.has(hour), "linen hours repeat %s from the rehearsal score" % hour)
			_expect(not Wick.HOURS.has(hour), "linen hours repeat %s from the wick trim" % hour)
			_expect(not Net.HOURS.has(hour), "linen hours repeat %s from the net loft" % hour)
			_expect(not Anneal.HOURS.has(hour), "linen hours repeat %s from the glass anneal" % hour)
			_expect(not Weather.HOURS.has(hour), "linen hours repeat %s from the weather slate" % hour)
		elif hour == "8":
			_expect(CaseData.HOURS.has(hour), "linen fold hour %s may also sit on the spare key" % hour)
			_expect(Tar.HOURS.has(hour), "linen fold hour %s may also sit on the tar kettle" % hour)
			_expect(Dye.HOURS.has(hour), "linen fold hour %s may also sit on the dye vat" % hour)
			_expect(Anneal.HOURS.has(hour), "linen fold hour %s may also sit on the glass anneal" % hour)
			_expect(not Rehearsal.HOURS.has(hour), "linen hours repeat %s from the rehearsal score" % hour)
			_expect(not Wick.HOURS.has(hour), "linen hours repeat %s from the wick trim" % hour)
			_expect(not Cork.HOURS.has(hour), "linen hours repeat %s from the cork press" % hour)
			_expect(not Net.HOURS.has(hour), "linen hours repeat %s from the net loft" % hour)
			_expect(not Weather.HOURS.has(hour), "linen hours repeat %s from the weather slate" % hour)
		elif hour == "9":
			_expect(CaseData.HOURS.has(hour), "linen fold hour %s may also sit on the spare key" % hour)
			_expect(Dye.HOURS.has(hour), "linen fold hour %s may also sit on the dye vat" % hour)
			_expect(Anneal.HOURS.has(hour), "linen fold hour %s may also sit on the glass anneal" % hour)
			_expect(not Rehearsal.HOURS.has(hour), "linen hours repeat %s from the rehearsal score" % hour)
			_expect(not Wick.HOURS.has(hour), "linen hours repeat %s from the wick trim" % hour)
			_expect(not Cork.HOURS.has(hour), "linen hours repeat %s from the cork press" % hour)
			_expect(not Net.HOURS.has(hour), "linen hours repeat %s from the net loft" % hour)
			_expect(not Tar.HOURS.has(hour), "linen hours repeat %s from the tar kettle" % hour)
			_expect(not Weather.HOURS.has(hour), "linen hours repeat %s from the weather slate" % hour)
		elif hour == "10":
			_expect(Anneal.HOURS.has(hour), "linen fold hour %s may also sit on the glass anneal" % hour)
			_expect(Weather.HOURS.has(hour), "linen fold hour %s may also sit on the weather slate" % hour)
			_expect(not CaseData.HOURS.has(hour), "linen hours repeat %s from the spare key" % hour)
			_expect(not Rehearsal.HOURS.has(hour), "linen hours repeat %s from the rehearsal score" % hour)
			_expect(not Wick.HOURS.has(hour), "linen hours repeat %s from the wick trim" % hour)
			_expect(not Cork.HOURS.has(hour), "linen hours repeat %s from the cork press" % hour)
			_expect(not Net.HOURS.has(hour), "linen hours repeat %s from the net loft" % hour)
			_expect(not Tar.HOURS.has(hour), "linen hours repeat %s from the tar kettle" % hour)
			_expect(not Dye.HOURS.has(hour), "linen hours repeat %s from the dye vat" % hour)
		else:
			_expect(false, "unexpected linen hour %s" % hour)
		for book in quiet_linen_hours:
			_expect(not book.HOURS.has(hour), "linen hours repeat %s" % hour)
	_expect(not Linen.HOURS.has("1"), "linen fold hours must not take 1")
	_expect(not Linen.HOURS.has("2"), "linen fold hours must not take 2")
	_expect(not Linen.HOURS.has("3"), "linen fold hours must not take 3")
	_expect(not Linen.HOURS.has("4"), "linen fold hours must not take 4")
	_expect(not Linen.HOURS.has("5"), "linen fold hours must not take 5")
	_expect(not Linen.HOURS.has("16"), "linen fold hours must not take 16")
	_expect(not Linen.HOURS.has("19"), "linen fold hours must not take 19")

	_expect(DOVETAIL_TRUE["who"] == "Doss", "dovetail taker")
	_expect(DOVETAIL_TRUE["place"] == "vise", "dovetail room")
	_expect(DOVETAIL_TRUE["hour"] == "63", "dovetail hour")
	for forbidden in ["Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(DOVETAIL_TRUE["who"] != forbidden, "dovetail accepted %s" % forbidden)
	for forbidden_place in ["press", "loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(DOVETAIL_TRUE["place"] != forbidden_place, "dovetail accepted the %s" % forbidden_place)
	_expect(DOVETAIL_TRUE["hour"] != "61", "dovetail accepted 61")
	_expect(DOVETAIL_TRUE["hour"] != "62", "dovetail accepted 62")
	_expect(DOVETAIL_TRUE["hour"] != "64", "dovetail accepted 64")
	_expect(DOVETAIL_TRUE["hour"] != "65", "dovetail accepted 65")
	_expect(DOVETAIL_TRUE["hour"] != "8", "dovetail accepted 8")
	_expect(DOVETAIL_TRUE["hour"] != "6", "dovetail accepted 6")
	_expect(DOVETAIL_TRUE["hour"] != "3", "dovetail accepted 3")
	_expect(DOVETAIL_TRUE["hour"] != "16", "dovetail accepted 16")
	_expect(DOVETAIL_TRUE["hour"] != "19", "dovetail accepted 19")
	var before_dovetail: Array = before_linen.duplicate()
	before_dovetail.append([Linen, LINEN_TRUE, "linen fold"])
	for row in before_dovetail:
		var book = row[0]
		var truth: Dictionary = row[1]
		var name := str(row[2])
		_expect(DOVETAIL_TRUE["who"] != truth["who"], "dovetail copied the %s taker" % name)
		_expect(DOVETAIL_TRUE["place"] != truth["place"], "dovetail copied the %s room" % name)
		_expect(DOVETAIL_TRUE["hour"] != str(truth["hour"]), "dovetail copied the %s hour" % name)
		_expect_rejected(DOVETAIL_TRUE, book)
		_expect_rejected(truth, Dovetail)
	_expect(LINEN_TRUE["who"] == "Vetch" and LINEN_TRUE["place"] == "press" and LINEN_TRUE["hour"] == "8", "the linen fold should still accept Vetch in the press at 8")
	for row in before_dovetail:
		var book = row[0]
		var name := str(row[2])
		for person in Dovetail.PEOPLE:
			_expect(not book.PEOPLE.has(person), "dovetail cast repeats %s from the %s" % [person, name])
		for place in Dovetail.PLACES:
			_expect(not book.PLACES.has(place), "dovetail rooms repeat %s from the %s" % [place, name])
		for hour in Dovetail.HOURS:
			_expect(not book.HOURS.has(hour), "dovetail hours repeat %s from the %s" % [hour, name])
	for forbidden_person in ["Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(not Dovetail.PEOPLE.has(forbidden_person), "dovetail cast must not take %s" % forbidden_person)
	_expect(Dovetail.role_phrase("Doss") == "the saw hand", "the dovetail should call Doss the saw hand")
	_expect(Dovetail.role_phrase("Yarrow") == "the board hand", "the dovetail should call Yarrow the board hand")
	_expect(Dovetail.role_phrase("Peck") == "the clamp clerk", "the dovetail should call Peck the clamp clerk")
	for forbidden_place in ["press", "loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "dye_house", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(not Dovetail.PLACES.has(forbidden_place), "dovetail rooms must not take the %s" % forbidden_place)
	_expect(not Dovetail.HOURS.has("6"), "dovetail hours must not take 6")
	_expect(not Dovetail.HOURS.has("7"), "dovetail hours must not take 7")
	_expect(not Dovetail.HOURS.has("8"), "dovetail hours must not take 8")
	_expect(not Dovetail.HOURS.has("9"), "dovetail hours must not take 9")
	_expect(not Dovetail.HOURS.has("10"), "dovetail hours must not take 10")
	_expect(not Dovetail.HOURS.has("60"), "dovetail hours must not take 60")
	_expect(not Dovetail.HOURS.has("66"), "dovetail hours must not take 66")

	_expect(MORTISE_TRUE["who"] == "Arlo", "mortise taker")
	_expect(MORTISE_TRUE["place"] == "chisel", "mortise room")
	_expect(MORTISE_TRUE["hour"] == "68", "mortise hour")
	for forbidden in ["Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(MORTISE_TRUE["who"] != forbidden, "mortise accepted %s" % forbidden)
	for forbidden_place in ["vise", "stile", "apron", "press", "loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(MORTISE_TRUE["place"] != forbidden_place, "mortise accepted the %s" % forbidden_place)
	_expect(MORTISE_TRUE["hour"] != "66", "mortise accepted 66")
	_expect(MORTISE_TRUE["hour"] != "67", "mortise accepted 67")
	_expect(MORTISE_TRUE["hour"] != "69", "mortise accepted 69")
	_expect(MORTISE_TRUE["hour"] != "70", "mortise accepted 70")
	_expect(MORTISE_TRUE["hour"] != "63", "mortise accepted 63")
	_expect(MORTISE_TRUE["hour"] != "8", "mortise accepted 8")
	_expect(MORTISE_TRUE["hour"] != "6", "mortise accepted 6")
	_expect(MORTISE_TRUE["hour"] != "3", "mortise accepted 3")
	_expect(MORTISE_TRUE["hour"] != "16", "mortise accepted 16")
	_expect(MORTISE_TRUE["hour"] != "19", "mortise accepted 19")
	var before_mortise: Array = before_dovetail.duplicate()
	before_mortise.append([Dovetail, DOVETAIL_TRUE, "dovetail"])
	for row in before_mortise:
		var book = row[0]
		var truth: Dictionary = row[1]
		var name := str(row[2])
		_expect(MORTISE_TRUE["who"] != truth["who"], "mortise copied the %s taker" % name)
		_expect(MORTISE_TRUE["place"] != truth["place"], "mortise copied the %s room" % name)
		_expect(MORTISE_TRUE["hour"] != str(truth["hour"]), "mortise copied the %s hour" % name)
		_expect_rejected(MORTISE_TRUE, book)
		_expect_rejected(truth, Mortise)
	_expect(DOVETAIL_TRUE["who"] == "Doss" and DOVETAIL_TRUE["place"] == "vise" and DOVETAIL_TRUE["hour"] == "63", "the dovetail should still accept Doss in the vise at 63")
	for row in before_mortise:
		var book = row[0]
		var name := str(row[2])
		for person in Mortise.PEOPLE:
			_expect(not book.PEOPLE.has(person), "mortise cast repeats %s from the %s" % [person, name])
		for place in Mortise.PLACES:
			_expect(not book.PLACES.has(place), "mortise rooms repeat %s from the %s" % [place, name])
		for hour in Mortise.HOURS:
			_expect(not book.HOURS.has(hour), "mortise hours repeat %s from the %s" % [hour, name])
	for forbidden_person in ["Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(not Mortise.PEOPLE.has(forbidden_person), "mortise cast must not take %s" % forbidden_person)
	_expect(Mortise.role_phrase("Arlo") == "the chisel hand", "the mortise should call Arlo the chisel hand")
	_expect(Mortise.role_phrase("Keel") == "the awl hand", "the mortise should call Keel the awl hand")
	_expect(Mortise.role_phrase("Weske") == "the last clerk", "the mortise should call Weske the last clerk")
	for forbidden_place in ["vise", "stile", "apron", "press", "loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "dye_house", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(not Mortise.PLACES.has(forbidden_place), "mortise rooms must not take the %s" % forbidden_place)
	_expect(not Mortise.HOURS.has("6"), "mortise hours must not take 6")
	_expect(not Mortise.HOURS.has("7"), "mortise hours must not take 7")
	_expect(not Mortise.HOURS.has("8"), "mortise hours must not take 8")
	_expect(not Mortise.HOURS.has("9"), "mortise hours must not take 9")
	_expect(not Mortise.HOURS.has("10"), "mortise hours must not take 10")
	_expect(not Mortise.HOURS.has("60"), "mortise hours must not take 60")
	_expect(not Mortise.HOURS.has("61"), "mortise hours must not take 61")
	_expect(not Mortise.HOURS.has("62"), "mortise hours must not take 62")
	_expect(not Mortise.HOURS.has("63"), "mortise hours must not take 63")
	_expect(not Mortise.HOURS.has("64"), "mortise hours must not take 64")
	_expect(not Mortise.HOURS.has("65"), "mortise hours must not take 65")

	_expect(REBATE_TRUE["who"] == "Tansy", "rebate taker")
	_expect(REBATE_TRUE["place"] == "plane", "rebate room")
	_expect(REBATE_TRUE["hour"] == "73", "rebate hour")
	for forbidden in ["Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(REBATE_TRUE["who"] != forbidden, "rebate accepted %s" % forbidden)
	for forbidden_place in ["chisel", "last", "awl", "vise", "stile", "apron", "press", "loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(REBATE_TRUE["place"] != forbidden_place, "rebate accepted the %s" % forbidden_place)
	_expect(REBATE_TRUE["hour"] != "71", "rebate accepted 71")
	_expect(REBATE_TRUE["hour"] != "72", "rebate accepted 72")
	_expect(REBATE_TRUE["hour"] != "74", "rebate accepted 74")
	_expect(REBATE_TRUE["hour"] != "75", "rebate accepted 75")
	_expect(REBATE_TRUE["hour"] != "68", "rebate accepted 68")
	_expect(REBATE_TRUE["hour"] != "63", "rebate accepted 63")
	_expect(REBATE_TRUE["hour"] != "8", "rebate accepted 8")
	_expect(REBATE_TRUE["hour"] != "6", "rebate accepted 6")
	_expect(REBATE_TRUE["hour"] != "3", "rebate accepted 3")
	_expect(REBATE_TRUE["hour"] != "16", "rebate accepted 16")
	_expect(REBATE_TRUE["hour"] != "19", "rebate accepted 19")
	var before_rebate: Array = before_mortise.duplicate()
	before_rebate.append([Mortise, MORTISE_TRUE, "mortise"])
	for row in before_rebate:
		var book = row[0]
		var truth: Dictionary = row[1]
		var name := str(row[2])
		_expect(REBATE_TRUE["who"] != truth["who"], "rebate copied the %s taker" % name)
		_expect(REBATE_TRUE["place"] != truth["place"], "rebate copied the %s room" % name)
		_expect(REBATE_TRUE["hour"] != str(truth["hour"]), "rebate copied the %s hour" % name)
		_expect_rejected(REBATE_TRUE, book)
		_expect_rejected(truth, Rebate)
	_expect(MORTISE_TRUE["who"] == "Arlo" and MORTISE_TRUE["place"] == "chisel" and MORTISE_TRUE["hour"] == "68", "the mortise should still accept Arlo in the chisel at 68")
	for row in before_rebate:
		var book = row[0]
		var name := str(row[2])
		for person in Rebate.PEOPLE:
			_expect(not book.PEOPLE.has(person), "rebate cast repeats %s from the %s" % [person, name])
		for place in Rebate.PLACES:
			_expect(not book.PLACES.has(place), "rebate rooms repeat %s from the %s" % [place, name])
		for hour in Rebate.HOURS:
			_expect(not book.HOURS.has(hour), "rebate hours repeat %s from the %s" % [hour, name])
	for forbidden_person in ["Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(not Rebate.PEOPLE.has(forbidden_person), "rebate cast must not take %s" % forbidden_person)
	_expect(Rebate.role_phrase("Tansy") == "the plane hand", "the rebate should call Tansy the plane hand")
	_expect(Rebate.role_phrase("Solt") == "the gauge hand", "the rebate should call Solt the gauge hand")
	_expect(Rebate.role_phrase("Quern") == "the mallet clerk", "the rebate should call Quern the mallet clerk")
	for forbidden_place in ["chisel", "last", "awl", "vise", "stile", "apron", "press", "loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "dye_house", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(not Rebate.PLACES.has(forbidden_place), "rebate rooms must not take the %s" % forbidden_place)
	_expect(not Rebate.HOURS.has("6"), "rebate hours must not take 6")
	_expect(not Rebate.HOURS.has("7"), "rebate hours must not take 7")
	_expect(not Rebate.HOURS.has("8"), "rebate hours must not take 8")
	_expect(not Rebate.HOURS.has("9"), "rebate hours must not take 9")
	_expect(not Rebate.HOURS.has("10"), "rebate hours must not take 10")
	_expect(not Rebate.HOURS.has("60"), "rebate hours must not take 60")
	_expect(not Rebate.HOURS.has("61"), "rebate hours must not take 61")
	_expect(not Rebate.HOURS.has("62"), "rebate hours must not take 62")
	_expect(not Rebate.HOURS.has("63"), "rebate hours must not take 63")
	_expect(not Rebate.HOURS.has("64"), "rebate hours must not take 64")
	_expect(not Rebate.HOURS.has("65"), "rebate hours must not take 65")
	_expect(not Rebate.HOURS.has("66"), "rebate hours must not take 66")
	_expect(not Rebate.HOURS.has("67"), "rebate hours must not take 67")
	_expect(not Rebate.HOURS.has("68"), "rebate hours must not take 68")
	_expect(not Rebate.HOURS.has("69"), "rebate hours must not take 69")
	_expect(not Rebate.HOURS.has("70"), "rebate hours must not take 70")


	_expect(HOUSING_TRUE["who"] == "Ewan", "housing taker")
	_expect(HOUSING_TRUE["place"] == "saw", "housing room")
	_expect(HOUSING_TRUE["hour"] == "78", "housing hour")
	for forbidden in ["Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(HOUSING_TRUE["who"] != forbidden, "housing accepted %s" % forbidden)
	for forbidden_place in ["plane", "gauge", "mallet", "chisel", "last", "awl", "vise", "stile", "apron", "press", "loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(HOUSING_TRUE["place"] != forbidden_place, "housing accepted the %s" % forbidden_place)
	_expect(HOUSING_TRUE["hour"] != "76", "housing accepted 76")
	_expect(HOUSING_TRUE["hour"] != "77", "housing accepted 77")
	_expect(HOUSING_TRUE["hour"] != "79", "housing accepted 79")
	_expect(HOUSING_TRUE["hour"] != "80", "housing accepted 80")
	_expect(HOUSING_TRUE["hour"] != "73", "housing accepted 73")
	_expect(HOUSING_TRUE["hour"] != "68", "housing accepted 68")
	_expect(HOUSING_TRUE["hour"] != "63", "housing accepted 63")
	_expect(HOUSING_TRUE["hour"] != "8", "housing accepted 8")
	_expect(HOUSING_TRUE["hour"] != "6", "housing accepted 6")
	_expect(HOUSING_TRUE["hour"] != "3", "housing accepted 3")
	_expect(HOUSING_TRUE["hour"] != "16", "housing accepted 16")
	_expect(HOUSING_TRUE["hour"] != "19", "housing accepted 19")
	var before_housing: Array = before_rebate.duplicate()
	before_housing.append([Rebate, REBATE_TRUE, "rebate"])
	for row in before_housing:
		var book = row[0]
		var truth: Dictionary = row[1]
		var name := str(row[2])
		_expect(HOUSING_TRUE["who"] != truth["who"], "housing copied the %s taker" % name)
		_expect(HOUSING_TRUE["place"] != truth["place"], "housing copied the %s room" % name)
		_expect(HOUSING_TRUE["hour"] != str(truth["hour"]), "housing copied the %s hour" % name)
		_expect_rejected(HOUSING_TRUE, book)
		_expect_rejected(truth, Housing)
	_expect(REBATE_TRUE["who"] == "Tansy" and REBATE_TRUE["place"] == "plane" and REBATE_TRUE["hour"] == "73", "the rebate should still accept Tansy in the plane at 73")
	for row in before_housing:
		var book = row[0]
		var name := str(row[2])
		for person in Housing.PEOPLE:
			_expect(not book.PEOPLE.has(person), "housing cast repeats %s from the %s" % [person, name])
		for place in Housing.PLACES:
			_expect(not book.PLACES.has(place), "housing rooms repeat %s from the %s" % [place, name])
		for hour in Housing.HOURS:
			_expect(not book.HOURS.has(hour), "housing hours repeat %s from the %s" % [hour, name])
	for forbidden_person in ["Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(not Housing.PEOPLE.has(forbidden_person), "housing cast must not take %s" % forbidden_person)
	_expect(Housing.role_phrase("Ewan") == "the saw hand", "the housing should call Ewan the saw hand")
	_expect(Housing.role_phrase("Maren") == "the square hand", "the housing should call Maren the square hand")
	_expect(Housing.role_phrase("Hollin") == "the bead clerk", "the housing should call Hollin the bead clerk")
	for forbidden_place in ["plane", "gauge", "mallet", "chisel", "last", "awl", "vise", "stile", "apron", "press", "loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "dye_house", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(not Housing.PLACES.has(forbidden_place), "housing rooms must not take the %s" % forbidden_place)
	_expect(not Housing.HOURS.has("6"), "housing hours must not take 6")
	_expect(not Housing.HOURS.has("7"), "housing hours must not take 7")
	_expect(not Housing.HOURS.has("8"), "housing hours must not take 8")
	_expect(not Housing.HOURS.has("9"), "housing hours must not take 9")
	_expect(not Housing.HOURS.has("10"), "housing hours must not take 10")
	_expect(not Housing.HOURS.has("60"), "housing hours must not take 60")
	_expect(not Housing.HOURS.has("61"), "housing hours must not take 61")
	_expect(not Housing.HOURS.has("62"), "housing hours must not take 62")
	_expect(not Housing.HOURS.has("63"), "housing hours must not take 63")
	_expect(not Housing.HOURS.has("64"), "housing hours must not take 64")
	_expect(not Housing.HOURS.has("65"), "housing hours must not take 65")
	_expect(not Housing.HOURS.has("66"), "housing hours must not take 66")
	_expect(not Housing.HOURS.has("67"), "housing hours must not take 67")
	_expect(not Housing.HOURS.has("68"), "housing hours must not take 68")
	_expect(not Housing.HOURS.has("69"), "housing hours must not take 69")
	_expect(not Housing.HOURS.has("70"), "housing hours must not take 70")
	_expect(not Housing.HOURS.has("71"), "housing hours must not take 71")
	_expect(not Housing.HOURS.has("72"), "housing hours must not take 72")
	_expect(not Housing.HOURS.has("73"), "housing hours must not take 73")
	_expect(not Housing.HOURS.has("74"), "housing hours must not take 74")
	_expect(not Housing.HOURS.has("75"), "housing hours must not take 75")

	_expect(TENON_TRUE["who"] == "Harl", "tenon taker")
	_expect(TENON_TRUE["place"] == "gouge", "tenon room")
	_expect(TENON_TRUE["hour"] == "83", "tenon hour")
	for forbidden in ["Ewan", "Maren", "Hollin", "Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(TENON_TRUE["who"] != forbidden, "tenon accepted %s" % forbidden)
	for forbidden_place in ["saw", "square", "bead", "plane", "gauge", "mallet", "chisel", "last", "awl", "vise", "stile", "apron", "press", "loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(TENON_TRUE["place"] != forbidden_place, "tenon accepted the %s" % forbidden_place)
	_expect(TENON_TRUE["hour"] != "81", "tenon accepted 81")
	_expect(TENON_TRUE["hour"] != "82", "tenon accepted 82")
	_expect(TENON_TRUE["hour"] != "84", "tenon accepted 84")
	_expect(TENON_TRUE["hour"] != "85", "tenon accepted 85")
	_expect(TENON_TRUE["hour"] != "78", "tenon accepted 78")
	_expect(TENON_TRUE["hour"] != "73", "tenon accepted 73")
	_expect(TENON_TRUE["hour"] != "68", "tenon accepted 68")
	_expect(TENON_TRUE["hour"] != "63", "tenon accepted 63")
	_expect(TENON_TRUE["hour"] != "8", "tenon accepted 8")
	_expect(TENON_TRUE["hour"] != "6", "tenon accepted 6")
	_expect(TENON_TRUE["hour"] != "3", "tenon accepted 3")
	_expect(TENON_TRUE["hour"] != "16", "tenon accepted 16")
	_expect(TENON_TRUE["hour"] != "19", "tenon accepted 19")
	var before_tenon: Array = before_housing.duplicate()
	before_tenon.append([Housing, HOUSING_TRUE, "housing"])
	for row in before_tenon:
		var book = row[0]
		var truth: Dictionary = row[1]
		var name := str(row[2])
		_expect(TENON_TRUE["who"] != truth["who"], "tenon copied the %s taker" % name)
		_expect(TENON_TRUE["place"] != truth["place"], "tenon copied the %s room" % name)
		_expect(TENON_TRUE["hour"] != str(truth["hour"]), "tenon copied the %s hour" % name)
		_expect_rejected(TENON_TRUE, book)
		_expect_rejected(truth, Tenon)
	_expect(HOUSING_TRUE["who"] == "Ewan" and HOUSING_TRUE["place"] == "saw" and HOUSING_TRUE["hour"] == "78", "the housing should still accept Ewan in the saw at 78")
	for row in before_tenon:
		var book = row[0]
		var name := str(row[2])
		for person in Tenon.PEOPLE:
			_expect(not book.PEOPLE.has(person), "tenon cast repeats %s from the %s" % [person, name])
		for place in Tenon.PLACES:
			_expect(not book.PLACES.has(place), "tenon rooms repeat %s from the %s" % [place, name])
		for hour in Tenon.HOURS:
			_expect(not book.HOURS.has(hour), "tenon hours repeat %s from the %s" % [hour, name])
	for forbidden_person in ["Ewan", "Maren", "Hollin", "Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(not Tenon.PEOPLE.has(forbidden_person), "tenon cast must not take %s" % forbidden_person)
	_expect(Tenon.role_phrase("Harl") == "the gouge hand", "the tenon should call Harl the gouge hand")
	_expect(Tenon.role_phrase("Neve") == "the rasp hand", "the tenon should call Neve the rasp hand")
	_expect(Tenon.role_phrase("Luth") == "the bevel clerk", "the tenon should call Luth the bevel clerk")
	for forbidden_place in ["saw", "square", "bead", "plane", "gauge", "mallet", "chisel", "last", "awl", "vise", "stile", "apron", "press", "loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "dye_house", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(not Tenon.PLACES.has(forbidden_place), "tenon rooms must not take the %s" % forbidden_place)
	_expect(not Tenon.HOURS.has("6"), "tenon hours must not take 6")
	_expect(not Tenon.HOURS.has("7"), "tenon hours must not take 7")
	_expect(not Tenon.HOURS.has("8"), "tenon hours must not take 8")
	_expect(not Tenon.HOURS.has("9"), "tenon hours must not take 9")
	_expect(not Tenon.HOURS.has("10"), "tenon hours must not take 10")
	_expect(not Tenon.HOURS.has("60"), "tenon hours must not take 60")
	_expect(not Tenon.HOURS.has("61"), "tenon hours must not take 61")
	_expect(not Tenon.HOURS.has("62"), "tenon hours must not take 62")
	_expect(not Tenon.HOURS.has("63"), "tenon hours must not take 63")
	_expect(not Tenon.HOURS.has("64"), "tenon hours must not take 64")
	_expect(not Tenon.HOURS.has("65"), "tenon hours must not take 65")
	_expect(not Tenon.HOURS.has("66"), "tenon hours must not take 66")
	_expect(not Tenon.HOURS.has("67"), "tenon hours must not take 67")
	_expect(not Tenon.HOURS.has("68"), "tenon hours must not take 68")
	_expect(not Tenon.HOURS.has("69"), "tenon hours must not take 69")
	_expect(not Tenon.HOURS.has("70"), "tenon hours must not take 70")
	_expect(not Tenon.HOURS.has("71"), "tenon hours must not take 71")
	_expect(not Tenon.HOURS.has("72"), "tenon hours must not take 72")
	_expect(not Tenon.HOURS.has("73"), "tenon hours must not take 73")
	_expect(not Tenon.HOURS.has("74"), "tenon hours must not take 74")
	_expect(not Tenon.HOURS.has("75"), "tenon hours must not take 75")
	_expect(not Tenon.HOURS.has("76"), "tenon hours must not take 76")
	_expect(not Tenon.HOURS.has("77"), "tenon hours must not take 77")
	_expect(not Tenon.HOURS.has("78"), "tenon hours must not take 78")
	_expect(not Tenon.HOURS.has("79"), "tenon hours must not take 79")
	_expect(not Tenon.HOURS.has("80"), "tenon hours must not take 80")

	_expect(BRIDLE_TRUE["who"] == "Wend", "bridle taker")
	_expect(BRIDLE_TRUE["place"] == "router", "bridle room")
	_expect(BRIDLE_TRUE["hour"] == "88", "bridle hour")
	for forbidden in ["Harl", "Neve", "Luth", "Ewan", "Maren", "Hollin", "Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(BRIDLE_TRUE["who"] != forbidden, "bridle accepted %s" % forbidden)
	for forbidden_place in ["gouge", "rasp", "bevel", "saw", "square", "bead", "plane", "gauge", "mallet", "chisel", "last", "awl", "vise", "stile", "apron", "press", "loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(BRIDLE_TRUE["place"] != forbidden_place, "bridle accepted the %s" % forbidden_place)
	_expect(BRIDLE_TRUE["hour"] != "86", "bridle accepted 86")
	_expect(BRIDLE_TRUE["hour"] != "87", "bridle accepted 87")
	_expect(BRIDLE_TRUE["hour"] != "89", "bridle accepted 89")
	_expect(BRIDLE_TRUE["hour"] != "90", "bridle accepted 90")
	_expect(BRIDLE_TRUE["hour"] != "83", "bridle accepted 83")
	_expect(BRIDLE_TRUE["hour"] != "78", "bridle accepted 78")
	_expect(BRIDLE_TRUE["hour"] != "73", "bridle accepted 73")
	_expect(BRIDLE_TRUE["hour"] != "68", "bridle accepted 68")
	_expect(BRIDLE_TRUE["hour"] != "63", "bridle accepted 63")
	_expect(BRIDLE_TRUE["hour"] != "8", "bridle accepted 8")
	_expect(BRIDLE_TRUE["hour"] != "6", "bridle accepted 6")
	_expect(BRIDLE_TRUE["hour"] != "3", "bridle accepted 3")
	_expect(BRIDLE_TRUE["hour"] != "16", "bridle accepted 16")
	_expect(BRIDLE_TRUE["hour"] != "19", "bridle accepted 19")
	var before_bridle: Array = before_tenon.duplicate()
	before_bridle.append([Tenon, TENON_TRUE, "tenon"])
	for row in before_bridle:
		var book = row[0]
		var truth: Dictionary = row[1]
		var name := str(row[2])
		_expect(BRIDLE_TRUE["who"] != truth["who"], "bridle copied the %s taker" % name)
		_expect(BRIDLE_TRUE["place"] != truth["place"], "bridle copied the %s room" % name)
		_expect(BRIDLE_TRUE["hour"] != str(truth["hour"]), "bridle copied the %s hour" % name)
		_expect_rejected(BRIDLE_TRUE, book)
		_expect_rejected(truth, Bridle)
	_expect(TENON_TRUE["who"] == "Harl" and TENON_TRUE["place"] == "gouge" and TENON_TRUE["hour"] == "83", "the tenon should still accept Harl in the gouge at 83")
	for row in before_bridle:
		var book = row[0]
		var name := str(row[2])
		for person in Bridle.PEOPLE:
			_expect(not book.PEOPLE.has(person), "bridle cast repeats %s from the %s" % [person, name])
		for place in Bridle.PLACES:
			_expect(not book.PLACES.has(place), "bridle rooms repeat %s from the %s" % [place, name])
		for hour in Bridle.HOURS:
			_expect(not book.HOURS.has(hour), "bridle hours repeat %s from the %s" % [hour, name])
	for forbidden_person in ["Harl", "Neve", "Luth", "Ewan", "Maren", "Hollin", "Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(not Bridle.PEOPLE.has(forbidden_person), "bridle cast must not take %s" % forbidden_person)
	_expect(Bridle.role_phrase("Wend") == "the router hand", "the bridle should call Wend the router hand")
	_expect(Bridle.role_phrase("Sile") == "the scraper hand", "the bridle should call Sile the scraper hand")
	_expect(Bridle.role_phrase("Jute") == "the adze clerk", "the bridle should call Jute the adze clerk")
	for forbidden_place in ["gouge", "rasp", "bevel", "saw", "square", "bead", "plane", "gauge", "mallet", "chisel", "last", "awl", "vise", "stile", "apron", "press", "loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "dye_house", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(not Bridle.PLACES.has(forbidden_place), "bridle rooms must not take the %s" % forbidden_place)
	_expect(not Bridle.HOURS.has("6"), "bridle hours must not take 6")
	_expect(not Bridle.HOURS.has("7"), "bridle hours must not take 7")
	_expect(not Bridle.HOURS.has("8"), "bridle hours must not take 8")
	_expect(not Bridle.HOURS.has("9"), "bridle hours must not take 9")
	_expect(not Bridle.HOURS.has("10"), "bridle hours must not take 10")
	_expect(not Bridle.HOURS.has("60"), "bridle hours must not take 60")
	_expect(not Bridle.HOURS.has("61"), "bridle hours must not take 61")
	_expect(not Bridle.HOURS.has("62"), "bridle hours must not take 62")
	_expect(not Bridle.HOURS.has("63"), "bridle hours must not take 63")
	_expect(not Bridle.HOURS.has("64"), "bridle hours must not take 64")
	_expect(not Bridle.HOURS.has("65"), "bridle hours must not take 65")
	_expect(not Bridle.HOURS.has("66"), "bridle hours must not take 66")
	_expect(not Bridle.HOURS.has("67"), "bridle hours must not take 67")
	_expect(not Bridle.HOURS.has("68"), "bridle hours must not take 68")
	_expect(not Bridle.HOURS.has("69"), "bridle hours must not take 69")
	_expect(not Bridle.HOURS.has("70"), "bridle hours must not take 70")
	_expect(not Bridle.HOURS.has("71"), "bridle hours must not take 71")
	_expect(not Bridle.HOURS.has("72"), "bridle hours must not take 72")
	_expect(not Bridle.HOURS.has("73"), "bridle hours must not take 73")
	_expect(not Bridle.HOURS.has("74"), "bridle hours must not take 74")
	_expect(not Bridle.HOURS.has("75"), "bridle hours must not take 75")
	_expect(not Bridle.HOURS.has("76"), "bridle hours must not take 76")
	_expect(not Bridle.HOURS.has("77"), "bridle hours must not take 77")
	_expect(not Bridle.HOURS.has("78"), "bridle hours must not take 78")
	_expect(not Bridle.HOURS.has("79"), "bridle hours must not take 79")
	_expect(not Bridle.HOURS.has("80"), "bridle hours must not take 80")
	_expect(not Bridle.HOURS.has("81"), "bridle hours must not take 81")
	_expect(not Bridle.HOURS.has("82"), "bridle hours must not take 82")
	_expect(not Bridle.HOURS.has("83"), "bridle hours must not take 83")
	_expect(not Bridle.HOURS.has("84"), "bridle hours must not take 84")
	_expect(not Bridle.HOURS.has("85"), "bridle hours must not take 85")

	_expect(DADO_TRUE["who"] == "Kern", "dado taker")
	_expect(DADO_TRUE["place"] == "plough", "dado room")
	_expect(DADO_TRUE["hour"] == "93", "dado hour")
	for forbidden in ["Wend", "Sile", "Jute", "Harl", "Neve", "Luth", "Ewan", "Maren", "Hollin", "Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(DADO_TRUE["who"] != forbidden, "dado accepted %s" % forbidden)
	for forbidden_place in ["router", "scraper", "adze", "gouge", "rasp", "bevel", "saw", "square", "bead", "plane", "gauge", "mallet", "chisel", "last", "awl", "vise", "stile", "apron", "press", "loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(DADO_TRUE["place"] != forbidden_place, "dado accepted the %s" % forbidden_place)
	_expect(DADO_TRUE["hour"] != "91", "dado accepted 91")
	_expect(DADO_TRUE["hour"] != "92", "dado accepted 92")
	_expect(DADO_TRUE["hour"] != "94", "dado accepted 94")
	_expect(DADO_TRUE["hour"] != "95", "dado accepted 95")
	_expect(DADO_TRUE["hour"] != "88", "dado accepted 88")
	_expect(DADO_TRUE["hour"] != "83", "dado accepted 83")
	_expect(DADO_TRUE["hour"] != "78", "dado accepted 78")
	_expect(DADO_TRUE["hour"] != "73", "dado accepted 73")
	_expect(DADO_TRUE["hour"] != "68", "dado accepted 68")
	_expect(DADO_TRUE["hour"] != "63", "dado accepted 63")
	_expect(DADO_TRUE["hour"] != "8", "dado accepted 8")
	_expect(DADO_TRUE["hour"] != "6", "dado accepted 6")
	_expect(DADO_TRUE["hour"] != "3", "dado accepted 3")
	_expect(DADO_TRUE["hour"] != "16", "dado accepted 16")
	_expect(DADO_TRUE["hour"] != "19", "dado accepted 19")
	var before_dado: Array = before_bridle.duplicate()
	before_dado.append([Bridle, BRIDLE_TRUE, "bridle"])
	for row in before_dado:
		var book = row[0]
		var truth: Dictionary = row[1]
		var name := str(row[2])
		_expect(DADO_TRUE["who"] != truth["who"], "dado copied the %s taker" % name)
		_expect(DADO_TRUE["place"] != truth["place"], "dado copied the %s room" % name)
		_expect(DADO_TRUE["hour"] != str(truth["hour"]), "dado copied the %s hour" % name)
		_expect_rejected(DADO_TRUE, book)
		_expect_rejected(truth, Dado)
	_expect(BRIDLE_TRUE["who"] == "Wend" and BRIDLE_TRUE["place"] == "router" and BRIDLE_TRUE["hour"] == "88", "the bridle should still accept Wend in the router at 88")
	for row in before_dado:
		var book = row[0]
		var name := str(row[2])
		for person in Dado.PEOPLE:
			_expect(not book.PEOPLE.has(person), "dado cast repeats %s from the %s" % [person, name])
		for place in Dado.PLACES:
			_expect(not book.PLACES.has(place), "dado rooms repeat %s from the %s" % [place, name])
		for hour in Dado.HOURS:
			_expect(not book.HOURS.has(hour), "dado hours repeat %s from the %s" % [hour, name])
	for forbidden_person in ["Wend", "Sile", "Jute", "Harl", "Neve", "Luth", "Ewan", "Maren", "Hollin", "Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(not Dado.PEOPLE.has(forbidden_person), "dado cast must not take %s" % forbidden_person)
	_expect(Dado.role_phrase("Kern") == "the plough hand", "the dado should call Kern the plough hand")
	_expect(Dado.role_phrase("Phel") == "the float hand", "the dado should call Phel the float hand")
	_expect(Dado.role_phrase("Tarn") == "the gimlet clerk", "the dado should call Tarn the gimlet clerk")
	for forbidden_place in ["router", "scraper", "adze", "gouge", "rasp", "bevel", "saw", "square", "bead", "plane", "gauge", "mallet", "chisel", "last", "awl", "vise", "stile", "apron", "press", "loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "dye_house", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(not Dado.PLACES.has(forbidden_place), "dado rooms must not take the %s" % forbidden_place)
	_expect(not Dado.HOURS.has("6"), "dado hours must not take 6")
	_expect(not Dado.HOURS.has("7"), "dado hours must not take 7")
	_expect(not Dado.HOURS.has("8"), "dado hours must not take 8")
	_expect(not Dado.HOURS.has("9"), "dado hours must not take 9")
	_expect(not Dado.HOURS.has("10"), "dado hours must not take 10")
	_expect(not Dado.HOURS.has("60"), "dado hours must not take 60")
	_expect(not Dado.HOURS.has("61"), "dado hours must not take 61")
	_expect(not Dado.HOURS.has("62"), "dado hours must not take 62")
	_expect(not Dado.HOURS.has("63"), "dado hours must not take 63")
	_expect(not Dado.HOURS.has("64"), "dado hours must not take 64")
	_expect(not Dado.HOURS.has("65"), "dado hours must not take 65")
	_expect(not Dado.HOURS.has("66"), "dado hours must not take 66")
	_expect(not Dado.HOURS.has("67"), "dado hours must not take 67")
	_expect(not Dado.HOURS.has("68"), "dado hours must not take 68")
	_expect(not Dado.HOURS.has("69"), "dado hours must not take 69")
	_expect(not Dado.HOURS.has("70"), "dado hours must not take 70")
	_expect(not Dado.HOURS.has("71"), "dado hours must not take 71")
	_expect(not Dado.HOURS.has("72"), "dado hours must not take 72")
	_expect(not Dado.HOURS.has("73"), "dado hours must not take 73")
	_expect(not Dado.HOURS.has("74"), "dado hours must not take 74")
	_expect(not Dado.HOURS.has("75"), "dado hours must not take 75")
	_expect(not Dado.HOURS.has("76"), "dado hours must not take 76")
	_expect(not Dado.HOURS.has("77"), "dado hours must not take 77")
	_expect(not Dado.HOURS.has("78"), "dado hours must not take 78")
	_expect(not Dado.HOURS.has("79"), "dado hours must not take 79")
	_expect(not Dado.HOURS.has("80"), "dado hours must not take 80")
	_expect(not Dado.HOURS.has("81"), "dado hours must not take 81")
	_expect(not Dado.HOURS.has("82"), "dado hours must not take 82")
	_expect(not Dado.HOURS.has("83"), "dado hours must not take 83")
	_expect(not Dado.HOURS.has("84"), "dado hours must not take 84")
	_expect(not Dado.HOURS.has("85"), "dado hours must not take 85")
	_expect(not Dado.HOURS.has("86"), "dado hours must not take 86")
	_expect(not Dado.HOURS.has("87"), "dado hours must not take 87")
	_expect(not Dado.HOURS.has("88"), "dado hours must not take 88")
	_expect(not Dado.HOURS.has("89"), "dado hours must not take 89")
	_expect(not Dado.HOURS.has("90"), "dado hours must not take 90")

	_expect(SPLINE_TRUE["who"] == "Senn", "spline taker")
	_expect(SPLINE_TRUE["place"] == "plough", "spline room")
	_expect(SPLINE_TRUE["hour"] == "98", "spline hour")
	for forbidden in ["Kern", "Phel", "Tarn", "Quill", "Wend", "Sile", "Jute", "Harl", "Neve", "Luth", "Ewan", "Maren", "Hollin", "Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(SPLINE_TRUE["who"] != forbidden, "spline accepted %s" % forbidden)
	for forbidden_place in ["router", "scraper", "adze", "gouge", "rasp", "bevel", "saw", "square", "bead", "plane", "gauge", "mallet", "chisel", "last", "awl", "vise", "stile", "apron", "press", "loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(SPLINE_TRUE["place"] != forbidden_place, "spline accepted the %s" % forbidden_place)
	_expect(SPLINE_TRUE["place"] != "float", "spline accepted the float")
	_expect(SPLINE_TRUE["place"] != "gimlet", "spline accepted the gimlet")
	_expect(SPLINE_TRUE["hour"] != "96", "spline accepted 96")
	_expect(SPLINE_TRUE["hour"] != "97", "spline accepted 97")
	_expect(SPLINE_TRUE["hour"] != "99", "spline accepted 99")
	_expect(SPLINE_TRUE["hour"] != "100", "spline accepted 100")
	_expect(SPLINE_TRUE["hour"] != "93", "spline accepted 93")
	_expect(SPLINE_TRUE["hour"] != "91", "spline accepted 91")
	_expect(SPLINE_TRUE["hour"] != "92", "spline accepted 92")
	_expect(SPLINE_TRUE["hour"] != "94", "spline accepted 94")
	_expect(SPLINE_TRUE["hour"] != "95", "spline accepted 95")
	_expect(SPLINE_TRUE["hour"] != "88", "spline accepted 88")
	_expect(SPLINE_TRUE["hour"] != "83", "spline accepted 83")
	_expect(SPLINE_TRUE["hour"] != "78", "spline accepted 78")
	_expect(SPLINE_TRUE["hour"] != "73", "spline accepted 73")
	_expect(SPLINE_TRUE["hour"] != "68", "spline accepted 68")
	_expect(SPLINE_TRUE["hour"] != "63", "spline accepted 63")
	_expect(SPLINE_TRUE["hour"] != "8", "spline accepted 8")
	_expect(SPLINE_TRUE["hour"] != "6", "spline accepted 6")
	_expect(SPLINE_TRUE["hour"] != "3", "spline accepted 3")
	_expect(SPLINE_TRUE["hour"] != "16", "spline accepted 16")
	_expect(SPLINE_TRUE["hour"] != "19", "spline accepted 19")
	var before_spline: Array = before_dado.duplicate()
	before_spline.append([Dado, DADO_TRUE, "dado"])
	for row in before_spline:
		var book = row[0]
		var truth: Dictionary = row[1]
		var name := str(row[2])
		_expect(SPLINE_TRUE["who"] != truth["who"], "spline copied the %s taker" % name)
		if name == "dado":
			_expect(SPLINE_TRUE["place"] == truth["place"], "spline should keep the plough the dado already uses")
		else:
			_expect(SPLINE_TRUE["place"] != truth["place"], "spline copied the %s room" % name)
		_expect(SPLINE_TRUE["hour"] != str(truth["hour"]), "spline copied the %s hour" % name)
		_expect_rejected(SPLINE_TRUE, book)
		_expect_rejected(truth, Spline)
	_expect(DADO_TRUE["who"] == "Kern" and DADO_TRUE["place"] == "plough" and DADO_TRUE["hour"] == "93", "the dado should still accept Kern in the plough at 93")
	for row in before_spline:
		var book = row[0]
		var name := str(row[2])
		for person in Spline.PEOPLE:
			_expect(not book.PEOPLE.has(person), "spline cast repeats %s from the %s" % [person, name])
		for place in Spline.PLACES:
			if name == "dado":
				_expect(book.PLACES.has(place), "spline shares the %s with the dado" % place)
			else:
				_expect(not book.PLACES.has(place), "spline rooms repeat %s from the %s" % [place, name])
		for hour in Spline.HOURS:
			_expect(not book.HOURS.has(hour), "spline hours repeat %s from the %s" % [hour, name])
	for forbidden_person in ["Kern", "Phel", "Tarn", "Quill", "Wend", "Sile", "Jute", "Harl", "Neve", "Luth", "Ewan", "Maren", "Hollin", "Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(not Spline.PEOPLE.has(forbidden_person), "spline cast must not take %s" % forbidden_person)
	_expect(Spline.role_phrase("Senn") == "the vise hand", "the spline should call Senn the vise hand")
	_expect(Spline.role_phrase("Voss") == "the chest hand", "the spline should call Voss the chest hand")
	_expect(Spline.role_phrase("Cade") == "the horse clerk", "the spline should call Cade the horse clerk")
	for forbidden_place in ["router", "scraper", "adze", "gouge", "rasp", "bevel", "saw", "square", "bead", "plane", "gauge", "mallet", "chisel", "last", "awl", "vise", "stile", "apron", "press", "loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "dye_house", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(not Spline.PLACES.has(forbidden_place), "spline rooms must not take the %s" % forbidden_place)
	_expect(not Spline.HOURS.has("6"), "spline hours must not take 6")
	_expect(not Spline.HOURS.has("7"), "spline hours must not take 7")
	_expect(not Spline.HOURS.has("8"), "spline hours must not take 8")
	_expect(not Spline.HOURS.has("9"), "spline hours must not take 9")
	_expect(not Spline.HOURS.has("10"), "spline hours must not take 10")
	_expect(not Spline.HOURS.has("60"), "spline hours must not take 60")
	_expect(not Spline.HOURS.has("61"), "spline hours must not take 61")
	_expect(not Spline.HOURS.has("62"), "spline hours must not take 62")
	_expect(not Spline.HOURS.has("63"), "spline hours must not take 63")
	_expect(not Spline.HOURS.has("64"), "spline hours must not take 64")
	_expect(not Spline.HOURS.has("65"), "spline hours must not take 65")
	_expect(not Spline.HOURS.has("66"), "spline hours must not take 66")
	_expect(not Spline.HOURS.has("67"), "spline hours must not take 67")
	_expect(not Spline.HOURS.has("68"), "spline hours must not take 68")
	_expect(not Spline.HOURS.has("69"), "spline hours must not take 69")
	_expect(not Spline.HOURS.has("70"), "spline hours must not take 70")
	_expect(not Spline.HOURS.has("71"), "spline hours must not take 71")
	_expect(not Spline.HOURS.has("72"), "spline hours must not take 72")
	_expect(not Spline.HOURS.has("73"), "spline hours must not take 73")
	_expect(not Spline.HOURS.has("74"), "spline hours must not take 74")
	_expect(not Spline.HOURS.has("75"), "spline hours must not take 75")
	_expect(not Spline.HOURS.has("76"), "spline hours must not take 76")
	_expect(not Spline.HOURS.has("77"), "spline hours must not take 77")
	_expect(not Spline.HOURS.has("78"), "spline hours must not take 78")
	_expect(not Spline.HOURS.has("79"), "spline hours must not take 79")
	_expect(not Spline.HOURS.has("80"), "spline hours must not take 80")
	_expect(not Spline.HOURS.has("81"), "spline hours must not take 81")
	_expect(not Spline.HOURS.has("82"), "spline hours must not take 82")
	_expect(not Spline.HOURS.has("83"), "spline hours must not take 83")
	_expect(not Spline.HOURS.has("84"), "spline hours must not take 84")
	_expect(not Spline.HOURS.has("85"), "spline hours must not take 85")
	_expect(not Spline.HOURS.has("86"), "spline hours must not take 86")
	_expect(not Spline.HOURS.has("87"), "spline hours must not take 87")
	_expect(not Spline.HOURS.has("88"), "spline hours must not take 88")
	_expect(not Spline.HOURS.has("89"), "spline hours must not take 89")
	_expect(not Spline.HOURS.has("90"), "spline hours must not take 90")
	_expect(not Spline.HOURS.has("91"), "spline hours must not take 91")
	_expect(not Spline.HOURS.has("92"), "spline hours must not take 92")
	_expect(not Spline.HOURS.has("93"), "spline hours must not take 93")
	_expect(not Spline.HOURS.has("94"), "spline hours must not take 94")
	_expect(not Spline.HOURS.has("95"), "spline hours must not take 95")

	_expect(MITRE_TRUE["who"] == "Orrin", "mitre taker")
	_expect(MITRE_TRUE["place"] == "plough", "mitre room")
	_expect(MITRE_TRUE["hour"] == "103", "mitre hour")
	for forbidden in ["Senn", "Voss", "Cade", "Kern", "Phel", "Tarn", "Quill", "Wend", "Sile", "Jute", "Harl", "Neve", "Luth", "Ewan", "Maren", "Hollin", "Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(MITRE_TRUE["who"] != forbidden, "mitre accepted %s" % forbidden)
	for forbidden_place in ["router", "scraper", "adze", "gouge", "rasp", "bevel", "saw", "square", "bead", "plane", "gauge", "mallet", "chisel", "last", "awl", "vise", "stile", "apron", "press", "loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(MITRE_TRUE["place"] != forbidden_place, "mitre accepted the %s" % forbidden_place)
	_expect(MITRE_TRUE["place"] != "float", "mitre accepted the float")
	_expect(MITRE_TRUE["place"] != "gimlet", "mitre accepted the gimlet")
	_expect(MITRE_TRUE["hour"] != "101", "mitre accepted 101")
	_expect(MITRE_TRUE["hour"] != "102", "mitre accepted 102")
	_expect(MITRE_TRUE["hour"] != "104", "mitre accepted 104")
	_expect(MITRE_TRUE["hour"] != "105", "mitre accepted 105")
	_expect(MITRE_TRUE["hour"] != "96", "mitre accepted 96")
	_expect(MITRE_TRUE["hour"] != "97", "mitre accepted 97")
	_expect(MITRE_TRUE["hour"] != "98", "mitre accepted 98")
	_expect(MITRE_TRUE["hour"] != "99", "mitre accepted 99")
	_expect(MITRE_TRUE["hour"] != "100", "mitre accepted 100")
	_expect(MITRE_TRUE["hour"] != "93", "mitre accepted 93")
	_expect(MITRE_TRUE["hour"] != "91", "mitre accepted 91")
	_expect(MITRE_TRUE["hour"] != "92", "mitre accepted 92")
	_expect(MITRE_TRUE["hour"] != "94", "mitre accepted 94")
	_expect(MITRE_TRUE["hour"] != "95", "mitre accepted 95")
	_expect(MITRE_TRUE["hour"] != "88", "mitre accepted 88")
	_expect(MITRE_TRUE["hour"] != "83", "mitre accepted 83")
	_expect(MITRE_TRUE["hour"] != "78", "mitre accepted 78")
	_expect(MITRE_TRUE["hour"] != "73", "mitre accepted 73")
	_expect(MITRE_TRUE["hour"] != "68", "mitre accepted 68")
	_expect(MITRE_TRUE["hour"] != "63", "mitre accepted 63")
	_expect(MITRE_TRUE["hour"] != "8", "mitre accepted 8")
	_expect(MITRE_TRUE["hour"] != "6", "mitre accepted 6")
	_expect(MITRE_TRUE["hour"] != "3", "mitre accepted 3")
	_expect(MITRE_TRUE["hour"] != "16", "mitre accepted 16")
	_expect(MITRE_TRUE["hour"] != "19", "mitre accepted 19")
	var before_mitre: Array = before_spline.duplicate()
	before_mitre.append([Spline, SPLINE_TRUE, "spline"])
	for row in before_mitre:
		var book = row[0]
		var truth: Dictionary = row[1]
		var name := str(row[2])
		_expect(MITRE_TRUE["who"] != truth["who"], "mitre copied the %s taker" % name)
		if name == "spline" or name == "dado":
			_expect(MITRE_TRUE["place"] == truth["place"], "mitre should keep the plough the %s already uses" % name)
		else:
			_expect(MITRE_TRUE["place"] != truth["place"], "mitre copied the %s room" % name)
		_expect(MITRE_TRUE["hour"] != str(truth["hour"]), "mitre copied the %s hour" % name)
		_expect_rejected(MITRE_TRUE, book)
		_expect_rejected(truth, Mitre)
	_expect(SPLINE_TRUE["who"] == "Senn" and SPLINE_TRUE["place"] == "plough" and SPLINE_TRUE["hour"] == "98", "the spline should still accept Senn in the plough at 98")
	for row in before_mitre:
		var book = row[0]
		var name := str(row[2])
		for person in Mitre.PEOPLE:
			_expect(not book.PEOPLE.has(person), "mitre cast repeats %s from the %s" % [person, name])
		for place in Mitre.PLACES:
			if name == "spline" or name == "dado":
				_expect(book.PLACES.has(place), "mitre shares the %s with the %s" % [place, name])
			else:
				_expect(not book.PLACES.has(place), "mitre rooms repeat %s from the %s" % [place, name])
		for hour in Mitre.HOURS:
			_expect(not book.HOURS.has(hour), "mitre hours repeat %s from the %s" % [hour, name])
	for forbidden_person in ["Senn", "Voss", "Cade", "Kern", "Phel", "Tarn", "Quill", "Wend", "Sile", "Jute", "Harl", "Neve", "Luth", "Ewan", "Maren", "Hollin", "Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(not Mitre.PEOPLE.has(forbidden_person), "mitre cast must not take %s" % forbidden_person)
	_expect(Mitre.role_phrase("Orrin") == "the saddle hand", "the mitre should call Orrin the saddle hand")
	_expect(Mitre.role_phrase("Venn") == "the kerf hand", "the mitre should call Venn the kerf hand")
	_expect(Mitre.role_phrase("Haim") == "the bit clerk", "the mitre should call Haim the bit clerk")
	for forbidden_place in ["router", "scraper", "adze", "gouge", "rasp", "bevel", "saw", "square", "bead", "plane", "gauge", "mallet", "chisel", "last", "awl", "vise", "stile", "apron", "press", "loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(not Mitre.PLACES.has(forbidden_place), "mitre rooms must not take the %s" % forbidden_place)
	_expect(not Mitre.HOURS.has("6"), "mitre hours must not take 6")
	_expect(not Mitre.HOURS.has("7"), "mitre hours must not take 7")
	_expect(not Mitre.HOURS.has("8"), "mitre hours must not take 8")
	_expect(not Mitre.HOURS.has("9"), "mitre hours must not take 9")
	_expect(not Mitre.HOURS.has("10"), "mitre hours must not take 10")
	_expect(not Mitre.HOURS.has("60"), "mitre hours must not take 60")
	_expect(not Mitre.HOURS.has("61"), "mitre hours must not take 61")
	_expect(not Mitre.HOURS.has("62"), "mitre hours must not take 62")
	_expect(not Mitre.HOURS.has("63"), "mitre hours must not take 63")
	_expect(not Mitre.HOURS.has("64"), "mitre hours must not take 64")
	_expect(not Mitre.HOURS.has("65"), "mitre hours must not take 65")
	_expect(not Mitre.HOURS.has("66"), "mitre hours must not take 66")
	_expect(not Mitre.HOURS.has("67"), "mitre hours must not take 67")
	_expect(not Mitre.HOURS.has("68"), "mitre hours must not take 68")
	_expect(not Mitre.HOURS.has("69"), "mitre hours must not take 69")
	_expect(not Mitre.HOURS.has("70"), "mitre hours must not take 70")
	_expect(not Mitre.HOURS.has("71"), "mitre hours must not take 71")
	_expect(not Mitre.HOURS.has("72"), "mitre hours must not take 72")
	_expect(not Mitre.HOURS.has("73"), "mitre hours must not take 73")
	_expect(not Mitre.HOURS.has("74"), "mitre hours must not take 74")
	_expect(not Mitre.HOURS.has("75"), "mitre hours must not take 75")
	_expect(not Mitre.HOURS.has("76"), "mitre hours must not take 76")
	_expect(not Mitre.HOURS.has("77"), "mitre hours must not take 77")
	_expect(not Mitre.HOURS.has("78"), "mitre hours must not take 78")
	_expect(not Mitre.HOURS.has("79"), "mitre hours must not take 79")
	_expect(not Mitre.HOURS.has("80"), "mitre hours must not take 80")
	_expect(not Mitre.HOURS.has("81"), "mitre hours must not take 81")
	_expect(not Mitre.HOURS.has("82"), "mitre hours must not take 82")
	_expect(not Mitre.HOURS.has("83"), "mitre hours must not take 83")
	_expect(not Mitre.HOURS.has("84"), "mitre hours must not take 84")
	_expect(not Mitre.HOURS.has("85"), "mitre hours must not take 85")
	_expect(not Mitre.HOURS.has("86"), "mitre hours must not take 86")
	_expect(not Mitre.HOURS.has("87"), "mitre hours must not take 87")
	_expect(not Mitre.HOURS.has("88"), "mitre hours must not take 88")
	_expect(not Mitre.HOURS.has("89"), "mitre hours must not take 89")
	_expect(not Mitre.HOURS.has("90"), "mitre hours must not take 90")
	_expect(not Mitre.HOURS.has("91"), "mitre hours must not take 91")
	_expect(not Mitre.HOURS.has("92"), "mitre hours must not take 92")
	_expect(not Mitre.HOURS.has("93"), "mitre hours must not take 93")
	_expect(not Mitre.HOURS.has("94"), "mitre hours must not take 94")
	_expect(not Mitre.HOURS.has("95"), "mitre hours must not take 95")
	_expect(not Mitre.HOURS.has("96"), "mitre hours must not take 96")
	_expect(not Mitre.HOURS.has("97"), "mitre hours must not take 97")
	_expect(not Mitre.HOURS.has("98"), "mitre hours must not take 98")
	_expect(not Mitre.HOURS.has("99"), "mitre hours must not take 99")
	_expect(not Mitre.HOURS.has("100"), "mitre hours must not take 100")

	_expect(LAP_TRUE["who"] == "Nye", "lap taker")
	_expect(LAP_TRUE["place"] == "plough", "lap room")
	_expect(LAP_TRUE["hour"] == "108", "lap hour")
	for forbidden in ["Orrin", "Venn", "Haim", "Senn", "Voss", "Cade", "Kern", "Phel", "Tarn", "Quill", "Wend", "Sile", "Jute", "Harl", "Neve", "Luth", "Ewan", "Maren", "Hollin", "Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(LAP_TRUE["who"] != forbidden, "lap accepted %s" % forbidden)
	for forbidden_place in ["router", "scraper", "adze", "gouge", "rasp", "bevel", "saw", "square", "bead", "plane", "gauge", "mallet", "chisel", "last", "awl", "vise", "stile", "apron", "press", "loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(LAP_TRUE["place"] != forbidden_place, "lap accepted the %s" % forbidden_place)
	_expect(LAP_TRUE["place"] != "float", "lap accepted the float")
	_expect(LAP_TRUE["place"] != "gimlet", "lap accepted the gimlet")
	_expect(LAP_TRUE["hour"] != "101", "lap accepted 101")
	_expect(LAP_TRUE["hour"] != "102", "lap accepted 102")
	_expect(LAP_TRUE["hour"] != "104", "lap accepted 104")
	_expect(LAP_TRUE["hour"] != "105", "lap accepted 105")
	_expect(LAP_TRUE["hour"] != "106", "lap accepted 106")
	_expect(LAP_TRUE["hour"] != "107", "lap accepted 107")
	_expect(LAP_TRUE["hour"] != "109", "lap accepted 109")
	_expect(LAP_TRUE["hour"] != "110", "lap accepted 110")
	_expect(LAP_TRUE["hour"] != "96", "lap accepted 96")
	_expect(LAP_TRUE["hour"] != "97", "lap accepted 97")
	_expect(LAP_TRUE["hour"] != "98", "lap accepted 98")
	_expect(LAP_TRUE["hour"] != "99", "lap accepted 99")
	_expect(LAP_TRUE["hour"] != "100", "lap accepted 100")
	_expect(LAP_TRUE["hour"] != "93", "lap accepted 93")
	_expect(LAP_TRUE["hour"] != "91", "lap accepted 91")
	_expect(LAP_TRUE["hour"] != "92", "lap accepted 92")
	_expect(LAP_TRUE["hour"] != "94", "lap accepted 94")
	_expect(LAP_TRUE["hour"] != "95", "lap accepted 95")
	_expect(LAP_TRUE["hour"] != "88", "lap accepted 88")
	_expect(LAP_TRUE["hour"] != "83", "lap accepted 83")
	_expect(LAP_TRUE["hour"] != "78", "lap accepted 78")
	_expect(LAP_TRUE["hour"] != "73", "lap accepted 73")
	_expect(LAP_TRUE["hour"] != "68", "lap accepted 68")
	_expect(LAP_TRUE["hour"] != "63", "lap accepted 63")
	_expect(LAP_TRUE["hour"] != "8", "lap accepted 8")
	_expect(LAP_TRUE["hour"] != "6", "lap accepted 6")
	_expect(LAP_TRUE["hour"] != "3", "lap accepted 3")
	_expect(LAP_TRUE["hour"] != "16", "lap accepted 16")
	_expect(LAP_TRUE["hour"] != "19", "lap accepted 19")
	var before_lap: Array = before_mitre.duplicate()
	before_lap.append([Mitre, MITRE_TRUE, "mitre"])
	for row in before_lap:
		var book = row[0]
		var truth: Dictionary = row[1]
		var name := str(row[2])
		_expect(LAP_TRUE["who"] != truth["who"], "lap copied the %s taker" % name)
		if name == "spline" or name == "dado" or name == "mitre":
			_expect(LAP_TRUE["place"] == truth["place"], "lap should keep the plough the %s already uses" % name)
		else:
			_expect(LAP_TRUE["place"] != truth["place"], "lap copied the %s room" % name)
		_expect(LAP_TRUE["hour"] != str(truth["hour"]), "lap copied the %s hour" % name)
		_expect_rejected(LAP_TRUE, book)
		_expect_rejected(truth, Lap)
	_expect(MITRE_TRUE["who"] == "Orrin" and MITRE_TRUE["place"] == "plough" and MITRE_TRUE["hour"] == "103", "the mitre should still accept Orrin in the plough at 103")
	for row in before_lap:
		var book = row[0]
		var name := str(row[2])
		for person in Lap.PEOPLE:
			_expect(not book.PEOPLE.has(person), "lap cast repeats %s from the %s" % [person, name])
		for place in Lap.PLACES:
			if name == "spline" or name == "dado" or name == "mitre":
				_expect(book.PLACES.has(place), "lap shares the %s with the %s" % [place, name])
			else:
				_expect(not book.PLACES.has(place), "lap rooms repeat %s from the %s" % [place, name])
		for hour in Lap.HOURS:
			_expect(not book.HOURS.has(hour), "lap hours repeat %s from the %s" % [hour, name])
	for forbidden_person in ["Orrin", "Venn", "Haim", "Senn", "Voss", "Cade", "Kern", "Phel", "Tarn", "Quill", "Wend", "Sile", "Jute", "Harl", "Neve", "Luth", "Ewan", "Maren", "Hollin", "Tansy", "Solt", "Quern", "Arlo", "Keel", "Weske", "Doss", "Yarrow", "Peck", "Vetch", "Odell", "Brigg", "Maeve", "Jory", "Perrin", "Hester", "Gwyn", "Idris", "Brea", "Ansel", "Colm", "Rho", "Lumen", "Kit", "Sera", "Pim", "Joss", "Calder", "Ness", "Edda", "Tess", "Ivo", "Wynn", "Quin", "Mara", "Sable", "Holt", "Lin", "Opal"]:
		_expect(not Lap.PEOPLE.has(forbidden_person), "lap cast must not take %s" % forbidden_person)
	_expect(Lap.role_phrase("Nye") == "the cradle hand", "the lap should call Nye the cradle hand")
	_expect(Lap.role_phrase("Yew") == "the grain hand", "the lap should call Yew the grain hand")
	_expect(Lap.role_phrase("Pry") == "the brad clerk", "the lap should call Pry the brad clerk")
	for forbidden_place in ["router", "scraper", "adze", "gouge", "rasp", "bevel", "saw", "square", "bead", "plane", "gauge", "mallet", "chisel", "last", "awl", "vise", "stile", "apron", "press", "loft", "bench", "shop", "yard", "cellar", "shed", "rail", "kettle", "walk", "vat", "line", "nursery", "row", "gate", "lehr", "marver", "pot", "gallery", "stair", "pan", "cistern", "rake_bay"]:
		_expect(not Lap.PLACES.has(forbidden_place), "lap rooms must not take the %s" % forbidden_place)
	_expect(not Lap.HOURS.has("6"), "lap hours must not take 6")
	_expect(not Lap.HOURS.has("7"), "lap hours must not take 7")
	_expect(not Lap.HOURS.has("8"), "lap hours must not take 8")
	_expect(not Lap.HOURS.has("9"), "lap hours must not take 9")
	_expect(not Lap.HOURS.has("10"), "lap hours must not take 10")
	_expect(not Lap.HOURS.has("60"), "lap hours must not take 60")
	_expect(not Lap.HOURS.has("61"), "lap hours must not take 61")
	_expect(not Lap.HOURS.has("62"), "lap hours must not take 62")
	_expect(not Lap.HOURS.has("63"), "lap hours must not take 63")
	_expect(not Lap.HOURS.has("64"), "lap hours must not take 64")
	_expect(not Lap.HOURS.has("65"), "lap hours must not take 65")
	_expect(not Lap.HOURS.has("66"), "lap hours must not take 66")
	_expect(not Lap.HOURS.has("67"), "lap hours must not take 67")
	_expect(not Lap.HOURS.has("68"), "lap hours must not take 68")
	_expect(not Lap.HOURS.has("69"), "lap hours must not take 69")
	_expect(not Lap.HOURS.has("70"), "lap hours must not take 70")
	_expect(not Lap.HOURS.has("71"), "lap hours must not take 71")
	_expect(not Lap.HOURS.has("72"), "lap hours must not take 72")
	_expect(not Lap.HOURS.has("73"), "lap hours must not take 73")
	_expect(not Lap.HOURS.has("74"), "lap hours must not take 74")
	_expect(not Lap.HOURS.has("75"), "lap hours must not take 75")
	_expect(not Lap.HOURS.has("76"), "lap hours must not take 76")
	_expect(not Lap.HOURS.has("77"), "lap hours must not take 77")
	_expect(not Lap.HOURS.has("78"), "lap hours must not take 78")
	_expect(not Lap.HOURS.has("79"), "lap hours must not take 79")
	_expect(not Lap.HOURS.has("80"), "lap hours must not take 80")
	_expect(not Lap.HOURS.has("81"), "lap hours must not take 81")
	_expect(not Lap.HOURS.has("82"), "lap hours must not take 82")
	_expect(not Lap.HOURS.has("83"), "lap hours must not take 83")
	_expect(not Lap.HOURS.has("84"), "lap hours must not take 84")
	_expect(not Lap.HOURS.has("85"), "lap hours must not take 85")
	_expect(not Lap.HOURS.has("86"), "lap hours must not take 86")
	_expect(not Lap.HOURS.has("87"), "lap hours must not take 87")
	_expect(not Lap.HOURS.has("88"), "lap hours must not take 88")
	_expect(not Lap.HOURS.has("89"), "lap hours must not take 89")
	_expect(not Lap.HOURS.has("90"), "lap hours must not take 90")
	_expect(not Lap.HOURS.has("91"), "lap hours must not take 91")
	_expect(not Lap.HOURS.has("92"), "lap hours must not take 92")
	_expect(not Lap.HOURS.has("93"), "lap hours must not take 93")
	_expect(not Lap.HOURS.has("94"), "lap hours must not take 94")
	_expect(not Lap.HOURS.has("95"), "lap hours must not take 95")
	_expect(not Lap.HOURS.has("96"), "lap hours must not take 96")
	_expect(not Lap.HOURS.has("97"), "lap hours must not take 97")
	_expect(not Lap.HOURS.has("98"), "lap hours must not take 98")
	_expect(not Lap.HOURS.has("99"), "lap hours must not take 99")
	_expect(not Lap.HOURS.has("100"), "lap hours must not take 100")
	_expect(not Lap.HOURS.has("101"), "lap hours must not take 101")
	_expect(not Lap.HOURS.has("102"), "lap hours must not take 102")
	_expect(not Lap.HOURS.has("103"), "lap hours must not take 103")
	_expect(not Lap.HOURS.has("104"), "lap hours must not take 104")
	_expect(not Lap.HOURS.has("105"), "lap hours must not take 105")

	_expect(titles == ["The spare key", "The rehearsal score", "The gilt stamp", "The ferry bell", "The weather slate", "The loom shuttle", "The hive smoker", "The glass pontil", "The press proof", "The assay cup", "The kiln chalk", "The tide ledger", "The night bell", "The salt mark", "The wick trim", "The glass anneal", "The orchard graft", "The dye vat", "The tar kettle", "The cork press", "The net loft", "The cask hoop", "The linen fold", "The dovetail", "The mortise", "The rebate", "The housing", "The tenon", "The bridle", "The dado", "The spline", "The mitre", "The lap"], "case list is %s" % str(titles))


func _test_menu_opens_either_case() -> void:
	get_root().size = Vector2i(1280, 800)
	var packed := load("res://scenes/main.tscn") as PackedScene
	var root := packed.instantiate()
	get_root().add_child(root)
	_expect(root.get_script() != null, "main scene script did not load")
	if root.get_child_count() == 0:
		root._ready()
	var menu_blob := _visible_label_blob(root)
	_expect(get_root().size == Vector2i(1280, 800), "case window is %s" % str(get_root().size))
	_expect(menu_blob.find("Thirty-three files") >= 0, "menu does not offer thirty-three files: %s" % menu_blob)
	_expect(menu_blob.find("CW-07") >= 0, "menu omits CW-07")
	_expect(menu_blob.find("The hive smoker") >= 0, "menu omits The hive smoker")
	_expect(menu_blob.find("CW-08") >= 0, "menu omits CW-08")
	_expect(menu_blob.find("The glass pontil") >= 0, "menu omits The glass pontil")
	_expect(menu_blob.find("CW-09") >= 0, "menu omits CW-09")
	_expect(menu_blob.find("The press proof") >= 0, "menu omits The press proof")
	_expect(menu_blob.find("CW-10") >= 0, "menu omits CW-10")
	_expect(menu_blob.find("The assay cup") >= 0, "menu omits The assay cup")
	_expect(menu_blob.find("CW-11") >= 0, "menu omits CW-11")
	_expect(menu_blob.find("The kiln chalk") >= 0, "menu omits The kiln chalk")
	_expect(menu_blob.find("CW-12") >= 0, "menu omits CW-12")
	_expect(menu_blob.find("The tide ledger") >= 0, "menu omits The tide ledger")
	_expect(menu_blob.find("CW-13") >= 0, "menu omits CW-13")
	_expect(menu_blob.find("The night bell") >= 0, "menu omits The night bell")
	_expect(menu_blob.find("CW-14") >= 0, "menu omits CW-14")
	_expect(menu_blob.find("The salt mark") >= 0, "menu omits The salt mark")
	_expect(menu_blob.find("CW-15") >= 0, "menu omits CW-15")
	_expect(menu_blob.find("The wick trim") >= 0, "menu omits The wick trim")
	_expect(menu_blob.find("CW-16") >= 0, "menu omits CW-16")
	_expect(menu_blob.find("The glass anneal") >= 0, "menu omits The glass anneal")
	_expect(menu_blob.find("CW-17") >= 0, "menu omits CW-17")
	_expect(menu_blob.find("The orchard graft") >= 0, "menu omits The orchard graft")
	_expect(menu_blob.find("CW-18") >= 0, "menu omits CW-18")
	_expect(menu_blob.find("The dye vat") >= 0, "menu omits The dye vat")
	_expect(menu_blob.find("CW-19") >= 0, "menu omits CW-19")
	_expect(menu_blob.find("The tar kettle") >= 0, "menu omits The tar kettle")
	_expect(menu_blob.find("CW-20") >= 0, "menu omits CW-20")
	_expect(menu_blob.find("The cork press") >= 0, "menu omits The cork press")
	_expect(menu_blob.find("CW-21") >= 0, "menu omits CW-21")
	_expect(menu_blob.find("The net loft") >= 0, "menu omits The net loft")
	_expect(menu_blob.find("CW-22") >= 0, "menu omits CW-22")
	_expect(menu_blob.find("The cask hoop") >= 0, "menu omits The cask hoop")
	_expect(menu_blob.find("CW-23") >= 0, "menu omits CW-23")
	_expect(menu_blob.find("The linen fold") >= 0, "menu omits The linen fold")
	_expect(menu_blob.find("CW-24") >= 0, "menu omits CW-24")
	_expect(menu_blob.find("The dovetail") >= 0, "menu omits The dovetail")
	_expect(menu_blob.find("CW-25") >= 0, "menu omits CW-25")
	_expect(menu_blob.find("The mortise") >= 0, "menu omits The mortise")
	_expect(menu_blob.find("CW-26") >= 0, "menu omits CW-26")
	_expect(menu_blob.find("The rebate") >= 0, "menu omits The rebate")
	_expect(menu_blob.find("CW-27") >= 0, "menu omits CW-27")
	_expect(menu_blob.find("The housing") >= 0, "menu omits The housing")
	_expect(menu_blob.find("CW-28") >= 0, "menu omits CW-28")
	_expect(menu_blob.find("The tenon") >= 0, "menu omits The tenon")
	_expect(menu_blob.find("CW-29") >= 0, "menu omits CW-29")
	_expect(menu_blob.find("The bridle") >= 0, "menu omits The bridle")
	_expect(menu_blob.find("CW-30") >= 0, "menu omits CW-30")
	_expect(menu_blob.find("The dado") >= 0, "menu omits The dado")
	_expect(menu_blob.find("CW-31") >= 0, "menu omits CW-31")
	_expect(menu_blob.find("The spline") >= 0, "menu omits The spline")
	_expect(menu_blob.find("CW-32") >= 0, "menu omits CW-32")
	_expect(menu_blob.find("The mitre") >= 0, "menu omits The mitre")
	_expect(menu_blob.find("CW-33") >= 0, "menu omits CW-33")
	_expect(menu_blob.find("The lap") >= 0, "menu omits The lap")
	_expect(root.get_child_count() > 0, "main scene built %d children" % root.get_child_count())
	_press(root, "How to play")
	var howto := _visible_label_blob(root)
	_expect(howto.find("The spare key") >= 0, "how to play omits The spare key")
	_expect(howto.find("The rehearsal score") >= 0, "how to play omits The rehearsal score")
	_expect(howto.find("The gilt stamp") >= 0, "how to play omits The gilt stamp")
	_expect(howto.find("The ferry bell") >= 0, "how to play omits The ferry bell")
	_expect(howto.find("The weather slate") >= 0, "how to play omits The weather slate")
	_expect(howto.find("The loom shuttle") >= 0, "how to play omits The loom shuttle")
	_expect(howto.find("The hive smoker") >= 0, "how to play omits The hive smoker")
	_expect(howto.find("The glass pontil") >= 0, "how to play omits The glass pontil")
	_expect(howto.find("The press proof") >= 0, "how to play omits The press proof")
	_expect(howto.find("The assay cup") >= 0, "how to play omits The assay cup")
	_expect(howto.find("The kiln chalk") >= 0, "how to play omits The kiln chalk")
	_expect(howto.find("The tide ledger") >= 0, "how to play omits The tide ledger")
	_expect(howto.find("The night bell") >= 0, "how to play omits The night bell")
	_expect(howto.find("The salt mark") >= 0, "how to play omits The salt mark")
	_expect(howto.find("The wick trim") >= 0, "how to play omits The wick trim")
	_expect(howto.find("The glass anneal") >= 0, "how to play omits The glass anneal")
	_expect(howto.find("The orchard graft") >= 0, "how to play omits The orchard graft")
	_expect(howto.find("The dye vat") >= 0, "how to play omits The dye vat")
	_expect(howto.find("The tar kettle") >= 0, "how to play omits The tar kettle")
	_expect(howto.find("The cork press") >= 0, "how to play omits The cork press")
	_expect(howto.find("The net loft") >= 0, "how to play omits The net loft")
	_expect(howto.find("The cask hoop") >= 0, "how to play omits The cask hoop")
	_expect(howto.find("The linen fold") >= 0, "how to play omits The linen fold")
	_expect(howto.find("The dovetail") >= 0, "how to play omits The dovetail")
	_expect(howto.find("The mortise") >= 0, "how to play omits The mortise")
	_expect(howto.find("The rebate") >= 0, "how to play omits The rebate")
	_expect(howto.find("The housing") >= 0, "how to play omits The housing")
	_expect(howto.find("The tenon") >= 0, "how to play omits The tenon")
	_expect(howto.find("The bridle") >= 0, "how to play omits The bridle")
	_expect(howto.find("The dado") >= 0, "how to play omits The dado")
	_expect(howto.find("The spline") >= 0, "how to play omits The spline")
	_expect(howto.find("The mitre") >= 0, "how to play omits The mitre")
	_expect(howto.find("The lap") >= 0, "how to play omits The lap")
	_expect(howto.find("names that slot") >= 0, "how to play omits the empty-slot rule")
	_press(root, "Back to the menu")
	_expect(_find_visible_button(root, "Open The spare key") != null, "menu is missing The spare key")
	_expect(_find_visible_button(root, "Open The rehearsal score") != null, "menu is missing The rehearsal score")
	_expect(_find_visible_button(root, "Open The gilt stamp") != null, "menu is missing The gilt stamp")
	_expect(_find_visible_button(root, "Open The ferry bell") != null, "menu is missing The ferry bell")
	_expect(_find_visible_button(root, "Open The weather slate") != null, "menu is missing The weather slate")
	_expect(_find_visible_button(root, "Open The loom shuttle") != null, "menu is missing The loom shuttle")
	_expect(_find_visible_button(root, "Open The hive smoker") != null, "menu is missing The hive smoker")
	_expect(_find_visible_button(root, "Open The glass pontil") != null, "menu is missing The glass pontil")
	_expect(_find_visible_button(root, "Open The press proof") != null, "menu is missing The press proof")
	_expect(_find_visible_button(root, "Open The assay cup") != null, "menu is missing The assay cup")
	_expect(_find_visible_button(root, "Open The kiln chalk") != null, "menu is missing The kiln chalk")
	_expect(_find_visible_button(root, "Open The tide ledger") != null, "menu is missing The tide ledger")
	_expect(_find_visible_button(root, "Open The night bell") != null, "menu is missing The night bell")
	_expect(_find_visible_button(root, "Open The salt mark") != null, "menu is missing The salt mark")
	_expect(_find_visible_button(root, "Open The wick trim") != null, "menu is missing The wick trim")
	_expect(_find_visible_button(root, "Open The glass anneal") != null, "menu is missing The glass anneal")
	_expect(_find_visible_button(root, "Open The orchard graft") != null, "menu is missing The orchard graft")
	_expect(_find_visible_button(root, "Open The dye vat") != null, "menu is missing The dye vat")
	_expect(_find_visible_button(root, "Open The tar kettle") != null, "menu is missing The tar kettle")
	_expect(_find_visible_button(root, "Open The cork press") != null, "menu is missing The cork press")
	_expect(_find_visible_button(root, "Open The net loft") != null, "menu is missing The net loft")
	_expect(_find_visible_button(root, "Open The cask hoop") != null, "menu is missing The cask hoop")
	_expect(_find_visible_button(root, "Open The linen fold") != null, "menu is missing The linen fold")
	_expect(_find_visible_button(root, "Open The dovetail") != null, "menu is missing The dovetail")
	_expect(_find_visible_button(root, "Open The mortise") != null, "menu is missing The mortise")
	_expect(_find_visible_button(root, "Open The rebate") != null, "menu is missing The rebate")
	_expect(_find_visible_button(root, "Open The housing") != null, "menu is missing The housing")
	_expect(_find_visible_button(root, "Open The tenon") != null, "menu is missing The tenon")
	_expect(_find_visible_button(root, "Open The bridle") != null, "menu is missing The bridle")
	_expect(_find_visible_button(root, "Open The dado") != null, "menu is missing The dado")
	_expect(_find_visible_button(root, "Open The spline") != null, "menu is missing The spline")
	_expect(_find_visible_button(root, "Open The mitre") != null, "menu is missing The mitre")
	_expect(_find_visible_button(root, "Open The lap") != null, "menu is missing The lap")
	_press(root, "Open The rehearsal score")
	var rehearsal_open := _visible_label_blob(root)
	_expect(rehearsal_open.find("Cut list") >= 0, "rehearsal file did not open")
	_expect(rehearsal_open.find("Complaint slip") == -1, "spare key papers showed inside The rehearsal score")
	_press(root, "Submit theory")
	var empty_rehearsal := _verdict_text(root)
	_expect(empty_rehearsal.find("who took the rehearsal score") >= 0, "empty rehearsal board: %s" % empty_rehearsal)
	_expect(empty_rehearsal.find("where they took the score") >= 0, "empty rehearsal board: %s" % empty_rehearsal)
	_expect(empty_rehearsal.find("at which hour they took the score") >= 0, "empty rehearsal board: %s" % empty_rehearsal)
	_expect(empty_rehearsal.find("who took the spare key") == -1, "empty rehearsal board used the spare key slot: %s" % empty_rehearsal)
	_expect(empty_rehearsal.to_lower().find("conflict") == -1, "empty rehearsal board talked about a conflict: %s" % empty_rehearsal)
	_press(root, "Ivo")
	_press(root, "Practice room")
	_press(root, "5")
	_press(root, "Submit theory")
	var missed := _verdict_text(root)
	_expect_reply_names_conflicts(missed, Rehearsal, {"who": "Ivo", "place": "practice_room", "hour": "5"})
	_press(root, "4")
	_press(root, "Submit theory")
	var accepted := _verdict_text(root)
	_expect(accepted.find("fits every exhibit") >= 0, "rehearsal board rejected the true theory: %s" % accepted)
	_expect(accepted.find("Ivo (copyist) took the rehearsal score at 4") >= 0, "rehearsal board timeline: %s" % accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var cleared := _verdict_text(root)
	_expect(cleared.find("who took the rehearsal score") >= 0, "cleared rehearsal board: %s" % cleared)
	_expect(cleared.find("fits every exhibit") == -1, "cleared rehearsal board stayed accepted: %s" % cleared)
	_press(root, "Menu")
	_press(root, "Open The spare key")
	var spare_open := _visible_label_blob(root)
	_expect(spare_open.find("Complaint slip") >= 0, "spare key file did not open")
	_expect(spare_open.find("Cut list") == -1, "rehearsal papers showed inside The spare key")
	_press(root, "Submit theory")
	var empty_spare := _verdict_text(root)
	_expect(empty_spare.find("who took the spare key") >= 0, "empty spare-key board: %s" % empty_spare)
	_expect(empty_spare.find("where they took the key") >= 0, "empty spare-key board: %s" % empty_spare)
	_expect(empty_spare.find("at which hour they took the key") >= 0, "empty spare-key board: %s" % empty_spare)
	_expect(empty_spare.find("rehearsal score") == -1, "empty spare-key board used a rehearsal slot: %s" % empty_spare)
	_press(root, "Nell")
	_press(root, "Kitchen")
	_press(root, "7")
	_press(root, "Submit theory")
	var spare_accepted := _verdict_text(root)
	_expect(spare_accepted.find("fits every exhibit") >= 0, "spare key board rejected the true theory: %s" % spare_accepted)
	_expect(spare_accepted.find(TIMELINE) >= 0, "spare key board timeline: %s" % spare_accepted)
	_press(root, "Moss")
	_press(root, "Front desk")
	_press(root, "8")
	_press(root, "Submit theory")
	var spare_miss := _verdict_text(root)
	_expect_reply_names_conflicts(spare_miss, CaseData, {"who": "Moss", "place": "front_desk", "hour": "8"})
	_press(root, "Menu")
	_press(root, "Open The rehearsal score")
	var reopened := _visible_label_blob(root)
	_expect(reopened.find("Gallery line") >= 0, "could not return to The rehearsal score")
	_expect(reopened.find("Complaint slip") == -1, "spare key papers stayed up after switching files")
	_press(root, "Menu")
	_press(root, "Open The gilt stamp")
	var gilt_open := _visible_label_blob(root)
	_expect(gilt_open.find("Move order") >= 0, "gilt stamp file did not open")
	_expect(gilt_open.find("Edge note") >= 0, "gilt stamp file did not show its exhibits")
	_expect(gilt_open.find("Complaint slip") == -1, "spare key papers showed inside The gilt stamp")
	_expect(gilt_open.find("Cut list") == -1, "rehearsal papers showed inside The gilt stamp")
	_press(root, "Submit theory")
	var empty_gilt := _verdict_text(root)
	_expect(empty_gilt.find("who took the gilt stamp") >= 0, "empty gilt board: %s" % empty_gilt)
	_expect(empty_gilt.find("where they took the stamp") >= 0, "empty gilt board: %s" % empty_gilt)
	_expect(empty_gilt.find("at which hour they took the stamp") >= 0, "empty gilt board: %s" % empty_gilt)
	_expect(empty_gilt.find("who took the spare key") == -1, "empty gilt board used the spare key slot: %s" % empty_gilt)
	_expect(empty_gilt.find("rehearsal score") == -1, "empty gilt board used a rehearsal slot: %s" % empty_gilt)
	_expect(empty_gilt.to_lower().find("conflict") == -1, "empty gilt board talked about a conflict: %s" % empty_gilt)
	_press(root, "Nessa")
	_press(root, "Finishing bench")
	_press(root, "2")
	_press(root, "Submit theory")
	var gilt_miss := _verdict_text(root)
	_expect_reply_names_conflicts(gilt_miss, Gilt, {"who": "Nessa", "place": "finishing_bench", "hour": "2"})
	_press(root, "Press room")
	_press(root, "1")
	_press(root, "Submit theory")
	var gilt_place_miss := _verdict_text(root)
	_expect_reply_names_conflicts(gilt_place_miss, Gilt, {"who": "Nessa", "place": "press_room", "hour": "1"})
	_press(root, "Finishing bench")
	_press(root, "Submit theory")
	var gilt_accepted := _verdict_text(root)
	_expect(gilt_accepted.find("fits every exhibit") >= 0, "gilt stamp board rejected the true theory: %s" % gilt_accepted)
	_expect(gilt_accepted.find("Nessa (porter) took the gilt stamp at 1") >= 0, "gilt stamp board timeline: %s" % gilt_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var gilt_cleared := _verdict_text(root)
	_expect(gilt_cleared.find("who took the gilt stamp") >= 0, "cleared gilt board: %s" % gilt_cleared)
	_expect(gilt_cleared.find("fits every exhibit") == -1, "cleared gilt board stayed accepted: %s" % gilt_cleared)
	_press(root, "Menu")
	_press(root, "Open The spare key")
	var spare_again := _visible_label_blob(root)
	_expect(spare_again.find("Complaint slip") >= 0, "could not return to The spare key from The gilt stamp")
	_expect(spare_again.find("Move order") == -1, "gilt stamp papers stayed up after switching files")
	_press(root, "Menu")
	_press(root, "Open The ferry bell")
	var ferry_open := _visible_label_blob(root)
	_expect(ferry_open.find("Whistle slip") >= 0, "ferry bell file did not open")
	_expect(ferry_open.find("Call chit") >= 0, "ferry bell file did not show its exhibits")
	_expect(ferry_open.find("Complaint slip") == -1, "spare key papers showed inside The ferry bell")
	_expect(ferry_open.find("Cut list") == -1, "rehearsal papers showed inside The ferry bell")
	_expect(ferry_open.find("Move order") == -1, "gilt stamp papers showed inside The ferry bell")
	_press(root, "Submit theory")
	var empty_ferry := _verdict_text(root)
	_expect(empty_ferry.find("who took the ferry bell") >= 0, "empty ferry board: %s" % empty_ferry)
	_expect(empty_ferry.find("where they took the bell") >= 0, "empty ferry board: %s" % empty_ferry)
	_expect(empty_ferry.find("at which hour they took the bell") >= 0, "empty ferry board: %s" % empty_ferry)
	_expect(empty_ferry.find("who took the spare key") == -1, "empty ferry board used the spare key slot: %s" % empty_ferry)
	_expect(empty_ferry.find("rehearsal score") == -1, "empty ferry board used a rehearsal slot: %s" % empty_ferry)
	_expect(empty_ferry.find("gilt stamp") == -1, "empty ferry board used a gilt slot: %s" % empty_ferry)
	_expect(empty_ferry.to_lower().find("conflict") == -1, "empty ferry board talked about a conflict: %s" % empty_ferry)
	_press(root, "Quill")
	_press(root, "Rope loft")
	_press(root, "16")
	_press(root, "Submit theory")
	var ferry_miss := _verdict_text(root)
	_expect_reply_names_conflicts(ferry_miss, Ferry, {"who": "Quill", "place": "rope_loft", "hour": "16"})
	_press(root, "Jetty shed")
	_press(root, "15")
	_press(root, "Submit theory")
	var ferry_place_miss := _verdict_text(root)
	_expect_reply_names_conflicts(ferry_place_miss, Ferry, {"who": "Quill", "place": "jetty_shed", "hour": "15"})
	_press(root, "Rope loft")
	_press(root, "Submit theory")
	var ferry_accepted := _verdict_text(root)
	_expect(ferry_accepted.find("fits every exhibit") >= 0, "ferry bell board rejected the true theory: %s" % ferry_accepted)
	_expect(ferry_accepted.find("Quill (ropehand) took the ferry bell at 15") >= 0, "ferry bell board timeline: %s" % ferry_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var ferry_cleared := _verdict_text(root)
	_expect(ferry_cleared.find("who took the ferry bell") >= 0, "cleared ferry board: %s" % ferry_cleared)
	_expect(ferry_cleared.find("fits every exhibit") == -1, "cleared ferry board stayed accepted: %s" % ferry_cleared)
	_press(root, "Menu")
	_press(root, "Open The spare key")
	var spare_from_ferry := _visible_label_blob(root)
	_expect(spare_from_ferry.find("Complaint slip") >= 0, "could not return to The spare key from The ferry bell")
	_expect(spare_from_ferry.find("Whistle slip") == -1, "ferry bell papers stayed up after switching files")
	_press(root, "Menu")
	_press(root, "Open The weather slate")
	var weather_open := _visible_label_blob(root)
	_expect(weather_open.find("Frost note") >= 0, "weather slate file did not open")
	_expect(weather_open.find("Stair chit") >= 0, "weather slate file did not show its exhibits")
	_expect(weather_open.find("Complaint slip") == -1, "spare key papers showed inside The weather slate")
	_expect(weather_open.find("Cut list") == -1, "rehearsal papers showed inside The weather slate")
	_expect(weather_open.find("Move order") == -1, "gilt stamp papers showed inside The weather slate")
	_expect(weather_open.find("Whistle slip") == -1, "ferry bell papers showed inside The weather slate")
	_press(root, "Submit theory")
	var empty_weather := _verdict_text(root)
	_expect(empty_weather.find("who took the weather slate") >= 0, "empty weather board: %s" % empty_weather)
	_expect(empty_weather.find("where they took the slate") >= 0, "empty weather board: %s" % empty_weather)
	_expect(empty_weather.find("at which hour they took the slate") >= 0, "empty weather board: %s" % empty_weather)
	_expect(empty_weather.find("who took the spare key") == -1, "empty weather board used the spare key slot: %s" % empty_weather)
	_expect(empty_weather.find("rehearsal score") == -1, "empty weather board used a rehearsal slot: %s" % empty_weather)
	_expect(empty_weather.find("gilt stamp") == -1, "empty weather board used a gilt slot: %s" % empty_weather)
	_expect(empty_weather.find("ferry bell") == -1, "empty weather board used a ferry slot: %s" % empty_weather)
	_expect(empty_weather.to_lower().find("conflict") == -1, "empty weather board talked about a conflict: %s" % empty_weather)
	_press(root, "Pim")
	_press(root, "Map alcove")
	_press(root, "11")
	_press(root, "Submit theory")
	var weather_miss := _verdict_text(root)
	_expect_reply_names_conflicts(weather_miss, Weather, {"who": "Pim", "place": "map_alcove", "hour": "11"})
	_press(root, "Peg room")
	_press(root, "12")
	_press(root, "Submit theory")
	var weather_place_miss := _verdict_text(root)
	_expect_reply_names_conflicts(weather_place_miss, Weather, {"who": "Pim", "place": "peg_room", "hour": "12"})
	_press(root, "Map alcove")
	_press(root, "Submit theory")
	var weather_accepted := _verdict_text(root)
	_expect(weather_accepted.find("fits every exhibit") >= 0, "weather slate board rejected the true theory: %s" % weather_accepted)
	_expect(weather_accepted.find("Pim (runner) took the weather slate at 12") >= 0, "weather slate board timeline: %s" % weather_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var weather_cleared := _verdict_text(root)
	_expect(weather_cleared.find("who took the weather slate") >= 0, "cleared weather board: %s" % weather_cleared)
	_expect(weather_cleared.find("fits every exhibit") == -1, "cleared weather board stayed accepted: %s" % weather_cleared)
	_press(root, "Menu")
	_press(root, "Open The ferry bell")
	var ferry_from_weather := _visible_label_blob(root)
	_expect(ferry_from_weather.find("Whistle slip") >= 0, "could not return to The ferry bell from The weather slate")
	_expect(ferry_from_weather.find("Frost note") == -1, "weather slate papers stayed up after switching files")
	_press(root, "Menu")
	_press(root, "Open The loom shuttle")
	var loom_open := _visible_label_blob(root)
	_expect(loom_open.find("Trough tag") >= 0, "loom shuttle file did not open")
	_expect(loom_open.find("Border note") >= 0, "loom shuttle file did not show its exhibits")
	_expect(loom_open.find("Complaint slip") == -1, "spare key papers showed inside The loom shuttle")
	_expect(loom_open.find("Cut list") == -1, "rehearsal papers showed inside The loom shuttle")
	_expect(loom_open.find("Move order") == -1, "gilt stamp papers showed inside The loom shuttle")
	_expect(loom_open.find("Whistle slip") == -1, "ferry bell papers showed inside The loom shuttle")
	_expect(loom_open.find("Frost note") == -1, "weather slate papers showed inside The loom shuttle")
	_press(root, "Submit theory")
	var empty_loom := _verdict_text(root)
	_expect(empty_loom.find("who took the loom shuttle") >= 0, "empty loom board: %s" % empty_loom)
	_expect(empty_loom.find("where they took the shuttle") >= 0, "empty loom board: %s" % empty_loom)
	_expect(empty_loom.find("at which hour they took the shuttle") >= 0, "empty loom board: %s" % empty_loom)
	_expect(empty_loom.find("who took the spare key") == -1, "empty loom board used the spare key slot: %s" % empty_loom)
	_expect(empty_loom.find("rehearsal score") == -1, "empty loom board used a rehearsal slot: %s" % empty_loom)
	_expect(empty_loom.find("gilt stamp") == -1, "empty loom board used a gilt slot: %s" % empty_loom)
	_expect(empty_loom.find("ferry bell") == -1, "empty loom board used a ferry slot: %s" % empty_loom)
	_expect(empty_loom.find("weather slate") == -1, "empty loom board used a weather slot: %s" % empty_loom)
	_expect(empty_loom.to_lower().find("conflict") == -1, "empty loom board talked about a conflict: %s" % empty_loom)
	_press(root, "Fenn")
	_press(root, "Pattern loft")
	_press(root, "18")
	_press(root, "Submit theory")
	var loom_miss := _verdict_text(root)
	_expect_reply_names_conflicts(loom_miss, Loom, {"who": "Fenn", "place": "pattern_loft", "hour": "18"})
	_press(root, "Loom room")
	_press(root, "19")
	_press(root, "Submit theory")
	var loom_place_miss := _verdict_text(root)
	_expect_reply_names_conflicts(loom_place_miss, Loom, {"who": "Fenn", "place": "loom_room", "hour": "19"})
	_press(root, "Pattern loft")
	_press(root, "Submit theory")
	var loom_accepted := _verdict_text(root)
	_expect(loom_accepted.find("fits every exhibit") >= 0, "loom shuttle board rejected the true theory: %s" % loom_accepted)
	_expect(loom_accepted.find("Fenn (warper) took the loom shuttle at 19") >= 0, "loom shuttle board timeline: %s" % loom_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var loom_cleared := _verdict_text(root)
	_expect(loom_cleared.find("who took the loom shuttle") >= 0, "cleared loom board: %s" % loom_cleared)
	_expect(loom_cleared.find("fits every exhibit") == -1, "cleared loom board stayed accepted: %s" % loom_cleared)
	_press(root, "Menu")
	_press(root, "Open The weather slate")
	var weather_from_loom := _visible_label_blob(root)
	_expect(weather_from_loom.find("Frost note") >= 0, "could not return to The weather slate from The loom shuttle")
	_expect(weather_from_loom.find("Trough tag") == -1, "loom shuttle papers stayed up after switching files")
	_press(root, "Menu")
	_press(root, "Open The hive smoker")
	var hive_open := _visible_label_blob(root)
	_expect(hive_open.find("Fuel line") >= 0, "hive smoker file did not open")
	_expect(hive_open.find("Swarm note") >= 0, "hive smoker file did not show its exhibits")
	_expect(hive_open.find("Complaint slip") == -1, "spare key papers showed inside The hive smoker")
	_expect(hive_open.find("Cut list") == -1, "rehearsal papers showed inside The hive smoker")
	_expect(hive_open.find("Move order") == -1, "gilt stamp papers showed inside The hive smoker")
	_expect(hive_open.find("Whistle slip") == -1, "ferry bell papers showed inside The hive smoker")
	_expect(hive_open.find("Frost note") == -1, "weather slate papers showed inside The hive smoker")
	_expect(hive_open.find("Trough tag") == -1, "loom shuttle papers showed inside The hive smoker")
	_press(root, "Submit theory")
	var empty_hive := _verdict_text(root)
	_expect(empty_hive.find("who took the hive smoker") >= 0, "empty hive board: %s" % empty_hive)
	_expect(empty_hive.find("where they took the smoker") >= 0, "empty hive board: %s" % empty_hive)
	_expect(empty_hive.find("at which hour they took the smoker") >= 0, "empty hive board: %s" % empty_hive)
	_expect(empty_hive.find("who took the spare key") == -1, "empty hive board used the spare key slot: %s" % empty_hive)
	_expect(empty_hive.find("rehearsal score") == -1, "empty hive board used a rehearsal slot: %s" % empty_hive)
	_expect(empty_hive.find("gilt stamp") == -1, "empty hive board used a gilt slot: %s" % empty_hive)
	_expect(empty_hive.find("ferry bell") == -1, "empty hive board used a ferry slot: %s" % empty_hive)
	_expect(empty_hive.find("weather slate") == -1, "empty hive board used a weather slot: %s" % empty_hive)
	_expect(empty_hive.find("loom shuttle") == -1, "empty hive board used a loom slot: %s" % empty_hive)
	_expect(empty_hive.to_lower().find("conflict") == -1, "empty hive board talked about a conflict: %s" % empty_hive)
	_press(root, "Tamsin")
	_press(root, "Honey room")
	_press(root, "24")
	_press(root, "Submit theory")
	var hive_miss := _verdict_text(root)
	_expect_reply_names_conflicts(hive_miss, Hive, {"who": "Tamsin", "place": "honey_room", "hour": "24"})
	_press(root, "Hive shed")
	_press(root, "22")
	_press(root, "Submit theory")
	var hive_place_miss := _verdict_text(root)
	_expect_reply_names_conflicts(hive_place_miss, Hive, {"who": "Tamsin", "place": "hive_shed", "hour": "22"})
	_press(root, "Honey room")
	_press(root, "Submit theory")
	var hive_accepted := _verdict_text(root)
	_expect(hive_accepted.find("fits every exhibit") >= 0, "hive smoker board rejected the true theory: %s" % hive_accepted)
	_expect(hive_accepted.find("Tamsin (night beekeeper) took the hive smoker at 22") >= 0, "hive smoker board timeline: %s" % hive_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var hive_cleared := _verdict_text(root)
	_expect(hive_cleared.find("who took the hive smoker") >= 0, "cleared hive board: %s" % hive_cleared)
	_expect(hive_cleared.find("fits every exhibit") == -1, "cleared hive board stayed accepted: %s" % hive_cleared)
	_press(root, "Menu")
	_press(root, "Open The loom shuttle")
	var loom_from_hive := _visible_label_blob(root)
	_expect(loom_from_hive.find("Trough tag") >= 0, "could not return to The loom shuttle from The hive smoker")
	_expect(loom_from_hive.find("Fuel line") == -1, "hive smoker papers stayed up after switching files")
	_press(root, "Menu")
	_press(root, "Open The glass pontil")
	var glass_open := _visible_label_blob(root)
	_expect(glass_open.find("Weight line") >= 0, "glass pontil file did not open")
	_expect(glass_open.find("Pontil note") >= 0, "glass pontil file did not show its exhibits")
	_expect(glass_open.find("Complaint slip") == -1, "spare key papers showed inside The glass pontil")
	_expect(glass_open.find("Cut list") == -1, "rehearsal papers showed inside The glass pontil")
	_expect(glass_open.find("Move order") == -1, "gilt stamp papers showed inside The glass pontil")
	_expect(glass_open.find("Whistle slip") == -1, "ferry bell papers showed inside The glass pontil")
	_expect(glass_open.find("Frost note") == -1, "weather slate papers showed inside The glass pontil")
	_expect(glass_open.find("Trough tag") == -1, "loom shuttle papers showed inside The glass pontil")
	_expect(glass_open.find("Fuel line") == -1, "hive smoker papers showed inside The glass pontil")
	_press(root, "Submit theory")
	var empty_glass := _verdict_text(root)
	_expect(empty_glass.find("who took the glass pontil") >= 0, "empty glass board: %s" % empty_glass)
	_expect(empty_glass.find("where they took the pontil") >= 0, "empty glass board: %s" % empty_glass)
	_expect(empty_glass.find("at which hour they took the pontil") >= 0, "empty glass board: %s" % empty_glass)
	_expect(empty_glass.find("who took the spare key") == -1, "empty glass board used the spare key slot: %s" % empty_glass)
	_expect(empty_glass.find("rehearsal score") == -1, "empty glass board used a rehearsal slot: %s" % empty_glass)
	_expect(empty_glass.find("gilt stamp") == -1, "empty glass board used a gilt slot: %s" % empty_glass)
	_expect(empty_glass.find("ferry bell") == -1, "empty glass board used a ferry slot: %s" % empty_glass)
	_expect(empty_glass.find("weather slate") == -1, "empty glass board used a weather slot: %s" % empty_glass)
	_expect(empty_glass.find("loom shuttle") == -1, "empty glass board used a loom slot: %s" % empty_glass)
	_expect(empty_glass.find("hive smoker") == -1, "empty glass board used a hive slot: %s" % empty_glass)
	_expect(empty_glass.to_lower().find("conflict") == -1, "empty glass board talked about a conflict: %s" % empty_glass)
	_press(root, "Sable")
	_press(root, "Lehr room")
	_press(root, "28")
	_press(root, "Submit theory")
	var glass_miss := _verdict_text(root)
	_expect_reply_names_conflicts(glass_miss, Glass, {"who": "Sable", "place": "lehr_room", "hour": "28"})
	_press(root, "Glory hole")
	_press(root, "27")
	_press(root, "Submit theory")
	var glass_place_miss := _verdict_text(root)
	_expect_reply_names_conflicts(glass_place_miss, Glass, {"who": "Sable", "place": "glory_hole", "hour": "27"})
	_press(root, "Lehr room")
	_press(root, "Submit theory")
	var glass_accepted := _verdict_text(root)
	_expect(glass_accepted.find("fits every exhibit") >= 0, "glass pontil board rejected the true theory: %s" % glass_accepted)
	_expect(glass_accepted.find("Sable (night gatherer) took the glass pontil at 27") >= 0, "glass pontil board timeline: %s" % glass_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var glass_cleared := _verdict_text(root)
	_expect(glass_cleared.find("who took the glass pontil") >= 0, "cleared glass board: %s" % glass_cleared)
	_expect(glass_cleared.find("fits every exhibit") == -1, "cleared glass board stayed accepted: %s" % glass_cleared)
	_press(root, "Menu")
	_press(root, "Open The hive smoker")
	var hive_from_glass := _visible_label_blob(root)
	_expect(hive_from_glass.find("Fuel line") >= 0, "could not return to The hive smoker from The glass pontil")
	_expect(hive_from_glass.find("Weight line") == -1, "glass pontil papers stayed up after switching files")
	_press(root, "Menu")
	_press(root, "Open The press proof")
	var press_open := _visible_label_blob(root)
	_expect(press_open.find("Lock line") >= 0, "press proof file did not open")
	_expect(press_open.find("Forme note") >= 0, "press proof file did not show its exhibits")
	_expect(press_open.find("Complaint slip") == -1, "spare key papers showed inside The press proof")
	_expect(press_open.find("Cut list") == -1, "rehearsal papers showed inside The press proof")
	_expect(press_open.find("Move order") == -1, "gilt stamp papers showed inside The press proof")
	_expect(press_open.find("Whistle slip") == -1, "ferry bell papers showed inside The press proof")
	_expect(press_open.find("Frost note") == -1, "weather slate papers showed inside The press proof")
	_expect(press_open.find("Trough tag") == -1, "loom shuttle papers showed inside The press proof")
	_expect(press_open.find("Fuel line") == -1, "hive smoker papers showed inside The press proof")
	_expect(press_open.find("Weight line") == -1, "glass pontil papers showed inside The press proof")
	_press(root, "Submit theory")
	var empty_press := _verdict_text(root)
	_expect(empty_press.find("who took the press proof") >= 0, "empty press board: %s" % empty_press)
	_expect(empty_press.find("where they took the proof") >= 0, "empty press board: %s" % empty_press)
	_expect(empty_press.find("at which hour they took the proof") >= 0, "empty press board: %s" % empty_press)
	_expect(empty_press.find("who took the spare key") == -1, "empty press board used the spare key slot: %s" % empty_press)
	_expect(empty_press.find("rehearsal score") == -1, "empty press board used a rehearsal slot: %s" % empty_press)
	_expect(empty_press.find("gilt stamp") == -1, "empty press board used a gilt slot: %s" % empty_press)
	_expect(empty_press.find("ferry bell") == -1, "empty press board used a ferry slot: %s" % empty_press)
	_expect(empty_press.find("weather slate") == -1, "empty press board used a weather slot: %s" % empty_press)
	_expect(empty_press.find("loom shuttle") == -1, "empty press board used a loom slot: %s" % empty_press)
	_expect(empty_press.find("hive smoker") == -1, "empty press board used a hive slot: %s" % empty_press)
	_expect(empty_press.find("glass pontil") == -1, "empty press board used a glass slot: %s" % empty_press)
	_expect(empty_press.to_lower().find("conflict") == -1, "empty press board talked about a conflict: %s" % empty_press)
	_press(root, "Nim")
	_press(root, "Stone")
	_press(root, "42")
	_press(root, "Submit theory")
	var press_miss := _verdict_text(root)
	_expect_reply_names_conflicts(press_miss, Press, {"who": "Nim", "place": "stone", "hour": "42"})
	_press(root, "Galley")
	_press(root, "41")
	_press(root, "Submit theory")
	var press_place_miss := _verdict_text(root)
	_expect_reply_names_conflicts(press_place_miss, Press, {"who": "Nim", "place": "galley", "hour": "41"})
	_press(root, "Stone")
	_press(root, "Submit theory")
	var press_accepted := _verdict_text(root)
	_expect(press_accepted.find("fits every exhibit") >= 0, "press proof board rejected the true theory: %s" % press_accepted)
	_expect(press_accepted.find(PRESS_TIMELINE) >= 0, "press proof board timeline: %s" % press_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var press_cleared := _verdict_text(root)
	_expect(press_cleared.find("who took the press proof") >= 0, "cleared press board: %s" % press_cleared)
	_expect(press_cleared.find("fits every exhibit") == -1, "cleared press board stayed accepted: %s" % press_cleared)
	_press(root, "Menu")
	_press(root, "Open The glass pontil")
	var glass_from_press := _visible_label_blob(root)
	_expect(glass_from_press.find("Weight line") >= 0, "could not return to The glass pontil from The press proof")
	_expect(glass_from_press.find("Lock line") == -1, "press proof papers stayed up after switching files")
	_press(root, "Menu")
	_press(root, "Open The assay cup")
	var assay_open := _visible_label_blob(root)
	_expect(assay_open.find("Cup line") >= 0, "assay cup file did not open")
	_expect(assay_open.find("Light note") >= 0, "assay cup file did not show its exhibits")
	_expect(assay_open.find("CW-10") >= 0, "assay cup file omits CW-10")
	_expect(assay_open.find("Complaint slip") == -1, "spare key papers showed inside The assay cup")
	_expect(assay_open.find("Cut list") == -1, "rehearsal papers showed inside The assay cup")
	_expect(assay_open.find("Move order") == -1, "gilt stamp papers showed inside The assay cup")
	_expect(assay_open.find("Whistle slip") == -1, "ferry bell papers showed inside The assay cup")
	_expect(assay_open.find("Frost note") == -1, "weather slate papers showed inside The assay cup")
	_expect(assay_open.find("Trough tag") == -1, "loom shuttle papers showed inside The assay cup")
	_expect(assay_open.find("Fuel line") == -1, "hive smoker papers showed inside The assay cup")
	_expect(assay_open.find("Weight line") == -1, "glass pontil papers showed inside The assay cup")
	_expect(assay_open.find("Lock line") == -1, "press proof papers showed inside The assay cup")
	_press(root, "Submit theory")
	var empty_assay := _verdict_text(root)
	_expect(empty_assay.find("who set the assay cup") >= 0, "empty assay board: %s" % empty_assay)
	_expect(empty_assay.find("where they set the cup") >= 0, "empty assay board: %s" % empty_assay)
	_expect(empty_assay.find("at which hour they set the cup") >= 0, "empty assay board: %s" % empty_assay)
	_expect(empty_assay.find("who took the spare key") == -1, "empty assay board used the spare key slot: %s" % empty_assay)
	_expect(empty_assay.find("rehearsal score") == -1, "empty assay board used a rehearsal slot: %s" % empty_assay)
	_expect(empty_assay.find("gilt stamp") == -1, "empty assay board used a gilt slot: %s" % empty_assay)
	_expect(empty_assay.find("ferry bell") == -1, "empty assay board used a ferry slot: %s" % empty_assay)
	_expect(empty_assay.find("weather slate") == -1, "empty assay board used a weather slot: %s" % empty_assay)
	_expect(empty_assay.find("loom shuttle") == -1, "empty assay board used a loom slot: %s" % empty_assay)
	_expect(empty_assay.find("hive smoker") == -1, "empty assay board used a hive slot: %s" % empty_assay)
	_expect(empty_assay.find("glass pontil") == -1, "empty assay board used a glass slot: %s" % empty_assay)
	_expect(empty_assay.find("press proof") == -1, "empty assay board used a press slot: %s" % empty_assay)
	_expect(empty_assay.to_lower().find("conflict") == -1, "empty assay board talked about a conflict: %s" % empty_assay)
	_press(root, "Lark")
	_press(root, "Scale")
	_press(root, "17")
	_press(root, "Submit theory")
	var assay_miss := _verdict_text(root)
	_expect_reply_names_conflicts(assay_miss, Assay, {"who": "Lark", "place": "scale", "hour": "17"})
	_expect(assay_miss.find("Light note") >= 0, "wrong hour reply omits Light note: %s" % assay_miss)
	_expect(assay_miss.find("Quench line") >= 0, "wrong hour reply omits Quench line: %s" % assay_miss)
	_press(root, "Muffle")
	_press(root, "16")
	_press(root, "Submit theory")
	var assay_place_miss := _verdict_text(root)
	_expect_reply_names_conflicts(assay_place_miss, Assay, {"who": "Lark", "place": "muffle", "hour": "16"})
	_press(root, "Scale")
	_press(root, "Submit theory")
	var assay_accepted := _verdict_text(root)
	_expect(assay_accepted.find("fits every exhibit") >= 0, "assay cup board rejected the true theory: %s" % assay_accepted)
	_expect(assay_accepted.find(ASSAY_TIMELINE) >= 0, "assay cup board timeline: %s" % assay_accepted)
	_expect(assay_accepted.find("Lark (weigher) set the assay cup at 16") >= 0, "assay cup board omits Lark at 16: %s" % assay_accepted)
	_expect(assay_accepted.find("to the scale") >= 0, "assay cup board omits the scale: %s" % assay_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var assay_cleared := _verdict_text(root)
	_expect(assay_cleared.find("who set the assay cup") >= 0, "cleared assay board: %s" % assay_cleared)
	_expect(assay_cleared.find("fits every exhibit") == -1, "cleared assay board stayed accepted: %s" % assay_cleared)
	_press(root, "Menu")
	_press(root, "Open The press proof")
	var press_from_assay := _visible_label_blob(root)
	_expect(press_from_assay.find("Lock line") >= 0, "could not return to The press proof from The assay cup")
	_expect(press_from_assay.find("Cup line") == -1, "assay cup papers stayed up after switching files")
	_press(root, "Menu")
	_press(root, "Open The kiln chalk")
	var kiln_open := _visible_label_blob(root)
	_expect(kiln_open.find("Mark line") >= 0, "kiln chalk file did not open")
	_expect(kiln_open.find("Draught note") >= 0, "kiln chalk file did not show its exhibits")
	_expect(kiln_open.find("CW-11") >= 0, "kiln chalk file omits CW-11")
	_expect(kiln_open.find("Complaint slip") == -1, "spare key papers showed inside The kiln chalk")
	_expect(kiln_open.find("Cut list") == -1, "rehearsal papers showed inside The kiln chalk")
	_expect(kiln_open.find("Move order") == -1, "gilt stamp papers showed inside The kiln chalk")
	_expect(kiln_open.find("Whistle slip") == -1, "ferry bell papers showed inside The kiln chalk")
	_expect(kiln_open.find("Frost note") == -1, "weather slate papers showed inside The kiln chalk")
	_expect(kiln_open.find("Trough tag") == -1, "loom shuttle papers showed inside The kiln chalk")
	_expect(kiln_open.find("Fuel line") == -1, "hive smoker papers showed inside The kiln chalk")
	_expect(kiln_open.find("Weight line") == -1, "glass pontil papers showed inside The kiln chalk")
	_expect(kiln_open.find("Lock line") == -1, "press proof papers showed inside The kiln chalk")
	_expect(kiln_open.find("Cup line") == -1, "assay cup papers showed inside The kiln chalk")
	_expect(kiln_open.find("Ledger line") == -1, "tide ledger papers showed inside The kiln chalk")
	_press(root, "Submit theory")
	var empty_kiln := _verdict_text(root)
	_expect(empty_kiln.find("who chalked the kiln mark") >= 0, "empty kiln board: %s" % empty_kiln)
	_expect(empty_kiln.find("where they chalked the mark") >= 0, "empty kiln board: %s" % empty_kiln)
	_expect(empty_kiln.find("at which hour they chalked the mark") >= 0, "empty kiln board: %s" % empty_kiln)
	_expect(empty_kiln.find("who took the spare key") == -1, "empty kiln board used the spare key slot: %s" % empty_kiln)
	_expect(empty_kiln.find("rehearsal score") == -1, "empty kiln board used a rehearsal slot: %s" % empty_kiln)
	_expect(empty_kiln.find("gilt stamp") == -1, "empty kiln board used a gilt slot: %s" % empty_kiln)
	_expect(empty_kiln.find("ferry bell") == -1, "empty kiln board used a ferry slot: %s" % empty_kiln)
	_expect(empty_kiln.find("weather slate") == -1, "empty kiln board used a weather slot: %s" % empty_kiln)
	_expect(empty_kiln.find("loom shuttle") == -1, "empty kiln board used a loom slot: %s" % empty_kiln)
	_expect(empty_kiln.find("hive smoker") == -1, "empty kiln board used a hive slot: %s" % empty_kiln)
	_expect(empty_kiln.find("glass pontil") == -1, "empty kiln board used a glass slot: %s" % empty_kiln)
	_expect(empty_kiln.find("press proof") == -1, "empty kiln board used a press slot: %s" % empty_kiln)
	_expect(empty_kiln.find("assay cup") == -1, "empty kiln board used an assay slot: %s" % empty_kiln)
	_expect(empty_kiln.find("tide ledger") == -1, "empty kiln board used a tide slot: %s" % empty_kiln)
	_expect(empty_kiln.to_lower().find("conflict") == -1, "empty kiln board talked about a conflict: %s" % empty_kiln)
	_press(root, "Wren")
	_press(root, "Flue")
	_press(root, "53")
	_press(root, "Submit theory")
	var kiln_miss := _verdict_text(root)
	_expect_reply_names_conflicts(kiln_miss, Kiln, {"who": "Wren", "place": "flue", "hour": "53"})
	_expect(kiln_miss.find("Watch slip") >= 0, "wrong hour reply omits Watch slip: %s" % kiln_miss)
	_expect(kiln_miss.find("Draught note") >= 0, "wrong hour reply omits Draught note: %s" % kiln_miss)
	_expect(kiln_miss.find("Damper line") >= 0, "wrong hour reply omits Damper line: %s" % kiln_miss)
	_press(root, "Crown")
	_press(root, "52")
	_press(root, "Submit theory")
	var kiln_place_miss := _verdict_text(root)
	_expect_reply_names_conflicts(kiln_place_miss, Kiln, {"who": "Wren", "place": "crown", "hour": "52"})
	_press(root, "Flue")
	_press(root, "Submit theory")
	var kiln_accepted := _verdict_text(root)
	_expect(kiln_accepted.find("fits every exhibit") >= 0, "kiln chalk board rejected the true theory: %s" % kiln_accepted)
	_expect(kiln_accepted.find(KILN_TIMELINE) >= 0, "kiln chalk board timeline: %s" % kiln_accepted)
	_expect(kiln_accepted.find("Wren (draught hand) chalked the kiln mark at 52") >= 0, "kiln chalk board omits Wren at 52: %s" % kiln_accepted)
	_expect(kiln_accepted.find("to the flue") >= 0, "kiln chalk board omits the flue: %s" % kiln_accepted)
	_expect(kiln_accepted.find("so the draught would read shut") >= 0, "kiln chalk board omits the draught: %s" % kiln_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var kiln_cleared := _verdict_text(root)
	_expect(kiln_cleared.find("who chalked the kiln mark") >= 0, "cleared kiln board: %s" % kiln_cleared)
	_expect(kiln_cleared.find("fits every exhibit") == -1, "cleared kiln board stayed accepted: %s" % kiln_cleared)
	_press(root, "Menu")
	_press(root, "Open The assay cup")
	var assay_from_kiln := _visible_label_blob(root)
	_expect(assay_from_kiln.find("Cup line") >= 0, "could not return to The assay cup from The kiln chalk")
	_expect(assay_from_kiln.find("Mark line") == -1, "kiln chalk papers stayed up after switching files")
	_press(root, "Menu")
	_press(root, "Open The tide ledger")
	var tide_open := _visible_label_blob(root)
	_expect(tide_open.find("Ledger line") >= 0, "tide ledger file did not open")
	_expect(tide_open.find("Late note") >= 0, "tide ledger file did not show its exhibits")
	_expect(tide_open.find("CW-12") >= 0, "tide ledger file omits CW-12")
	_expect(tide_open.find("Complaint slip") == -1, "spare key papers showed inside The tide ledger")
	_expect(tide_open.find("Cut list") == -1, "rehearsal papers showed inside The tide ledger")
	_expect(tide_open.find("Move order") == -1, "gilt stamp papers showed inside The tide ledger")
	_expect(tide_open.find("Whistle slip") == -1, "ferry bell papers showed inside The tide ledger")
	_expect(tide_open.find("Frost note") == -1, "weather slate papers showed inside The tide ledger")
	_expect(tide_open.find("Trough tag") == -1, "loom shuttle papers showed inside The tide ledger")
	_expect(tide_open.find("Fuel line") == -1, "hive smoker papers showed inside The tide ledger")
	_expect(tide_open.find("Weight line") == -1, "glass pontil papers showed inside The tide ledger")
	_expect(tide_open.find("Lock line") == -1, "press proof papers showed inside The tide ledger")
	_expect(tide_open.find("Cup line") == -1, "assay cup papers showed inside The tide ledger")
	_expect(tide_open.find("Mark line") == -1, "kiln chalk papers showed inside The tide ledger")
	_press(root, "Submit theory")
	var empty_tide := _verdict_text(root)
	_expect(empty_tide.find("who entered the tide ledger") >= 0, "empty tide board: %s" % empty_tide)
	_expect(empty_tide.find("where they entered the ledger") >= 0, "empty tide board: %s" % empty_tide)
	_expect(empty_tide.find("at which hour they entered the ledger") >= 0, "empty tide board: %s" % empty_tide)
	_expect(empty_tide.find("who took the spare key") == -1, "empty tide board used the spare key slot: %s" % empty_tide)
	_expect(empty_tide.find("rehearsal score") == -1, "empty tide board used a rehearsal slot: %s" % empty_tide)
	_expect(empty_tide.find("gilt stamp") == -1, "empty tide board used a gilt slot: %s" % empty_tide)
	_expect(empty_tide.find("ferry bell") == -1, "empty tide board used a ferry slot: %s" % empty_tide)
	_expect(empty_tide.find("weather slate") == -1, "empty tide board used a weather slot: %s" % empty_tide)
	_expect(empty_tide.find("loom shuttle") == -1, "empty tide board used a loom slot: %s" % empty_tide)
	_expect(empty_tide.find("hive smoker") == -1, "empty tide board used a hive slot: %s" % empty_tide)
	_expect(empty_tide.find("glass pontil") == -1, "empty tide board used a glass slot: %s" % empty_tide)
	_expect(empty_tide.find("press proof") == -1, "empty tide board used a press slot: %s" % empty_tide)
	_expect(empty_tide.find("assay cup") == -1, "empty tide board used an assay slot: %s" % empty_tide)
	_expect(empty_tide.find("kiln mark") == -1, "empty tide board used a kiln slot: %s" % empty_tide)
	_expect(empty_tide.to_lower().find("conflict") == -1, "empty tide board talked about a conflict: %s" % empty_tide)
	_press(root, "Moss")
	_press(root, "Quay")
	_press(root, "34")
	_press(root, "Submit theory")
	var tide_miss := _verdict_text(root)
	_expect_reply_names_conflicts(tide_miss, Tide, {"who": "Moss", "place": "quay", "hour": "34"})
	_expect(tide_miss.find("Glass slip") >= 0, "wrong hour reply omits Glass slip: %s" % tide_miss)
	_expect(tide_miss.find("Late note") >= 0, "wrong hour reply omits Late note: %s" % tide_miss)
	_expect(tide_miss.find("Call line") >= 0, "wrong hour reply omits Call line: %s" % tide_miss)
	_press(root, "Mole")
	_press(root, "33")
	_press(root, "Submit theory")
	var tide_place_miss := _verdict_text(root)
	_expect_reply_names_conflicts(tide_place_miss, Tide, {"who": "Moss", "place": "mole", "hour": "33"})
	_press(root, "Quay")
	_press(root, "Submit theory")
	var tide_accepted := _verdict_text(root)
	_expect(tide_accepted.find("fits every exhibit") >= 0, "tide ledger board rejected the true theory: %s" % tide_accepted)
	_expect(tide_accepted.find(TIDE_TIMELINE) >= 0, "tide ledger board timeline: %s" % tide_accepted)
	_expect(tide_accepted.find("Moss (tide clerk) entered the tide ledger at 33") >= 0, "tide ledger board omits Moss at 33: %s" % tide_accepted)
	_expect(tide_accepted.find("to the quay") >= 0, "tide ledger board omits the quay: %s" % tide_accepted)
	_expect(tide_accepted.find("so the boat would read late") >= 0, "tide ledger board omits the late boat: %s" % tide_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var tide_cleared := _verdict_text(root)
	_expect(tide_cleared.find("who entered the tide ledger") >= 0, "cleared tide board: %s" % tide_cleared)
	_expect(tide_cleared.find("fits every exhibit") == -1, "cleared tide board stayed accepted: %s" % tide_cleared)
	_press(root, "Menu")
	_press(root, "Open The kiln chalk")
	var kiln_from_tide := _visible_label_blob(root)
	_expect(kiln_from_tide.find("Mark line") >= 0, "could not return to The kiln chalk from The tide ledger")
	_expect(kiln_from_tide.find("Ledger line") == -1, "tide ledger papers stayed up after switching files")
	_press(root, "Menu")
	_press(root, "Open The night bell")
	var night_open := _visible_label_blob(root)
	_expect(night_open.find("Bell line") >= 0, "night bell file did not open")
	_expect(night_open.find("Early note") >= 0, "night bell file did not show its exhibits")
	_expect(night_open.find("CW-13") >= 0, "night bell file omits CW-13")
	_expect(night_open.find("Complaint slip") == -1, "spare key papers showed inside The night bell")
	_expect(night_open.find("Cut list") == -1, "rehearsal papers showed inside The night bell")
	_expect(night_open.find("Move order") == -1, "gilt stamp papers showed inside The night bell")
	_expect(night_open.find("Whistle slip") == -1, "ferry bell papers showed inside The night bell")
	_expect(night_open.find("Frost note") == -1, "weather slate papers showed inside The night bell")
	_expect(night_open.find("Trough tag") == -1, "loom shuttle papers showed inside The night bell")
	_expect(night_open.find("Fuel line") == -1, "hive smoker papers showed inside The night bell")
	_expect(night_open.find("Weight line") == -1, "glass pontil papers showed inside The night bell")
	_expect(night_open.find("Lock line") == -1, "press proof papers showed inside The night bell")
	_expect(night_open.find("Cup line") == -1, "assay cup papers showed inside The night bell")
	_expect(night_open.find("Mark line") == -1, "kiln chalk papers showed inside The night bell")
	_expect(night_open.find("Ledger line") == -1, "tide ledger papers showed inside The night bell")
	_press(root, "Submit theory")
	var empty_night := _verdict_text(root)
	_expect(empty_night.find("who stopped the night bell") >= 0, "empty night board: %s" % empty_night)
	_expect(empty_night.find("where they stopped the bell") >= 0, "empty night board: %s" % empty_night)
	_expect(empty_night.find("at which hour they stopped the bell") >= 0, "empty night board: %s" % empty_night)
	_expect(empty_night.find("who took the spare key") == -1, "empty night board used the spare key slot: %s" % empty_night)
	_expect(empty_night.find("rehearsal score") == -1, "empty night board used a rehearsal slot: %s" % empty_night)
	_expect(empty_night.find("gilt stamp") == -1, "empty night board used a gilt slot: %s" % empty_night)
	_expect(empty_night.find("ferry bell") == -1, "empty night board used a ferry slot: %s" % empty_night)
	_expect(empty_night.find("weather slate") == -1, "empty night board used a weather slot: %s" % empty_night)
	_expect(empty_night.find("loom shuttle") == -1, "empty night board used a loom slot: %s" % empty_night)
	_expect(empty_night.find("hive smoker") == -1, "empty night board used a hive slot: %s" % empty_night)
	_expect(empty_night.find("glass pontil") == -1, "empty night board used a glass slot: %s" % empty_night)
	_expect(empty_night.find("press proof") == -1, "empty night board used a press slot: %s" % empty_night)
	_expect(empty_night.find("assay cup") == -1, "empty night board used an assay slot: %s" % empty_night)
	_expect(empty_night.find("kiln mark") == -1, "empty night board used a kiln slot: %s" % empty_night)
	_expect(empty_night.find("tide ledger") == -1, "empty night board used a tide slot: %s" % empty_night)
	_expect(empty_night.to_lower().find("conflict") == -1, "empty night board talked about a conflict: %s" % empty_night)
	_press(root, "Vesper")
	_press(root, "Tower")
	_press(root, "45")
	_press(root, "Submit theory")
	var night_miss := _verdict_text(root)
	_expect_reply_names_conflicts(night_miss, Night, {"who": "Vesper", "place": "tower", "hour": "45"})
	_expect(night_miss.find("Sight slip") >= 0, "wrong hour reply omits Sight slip: %s" % night_miss)
	_expect(night_miss.find("Early note") >= 0, "wrong hour reply omits Early note: %s" % night_miss)
	_expect(night_miss.find("Shutter line") >= 0, "wrong hour reply omits Shutter line: %s" % night_miss)
	_press(root, "Parapet")
	_press(root, "44")
	_press(root, "Submit theory")
	var night_place_miss := _verdict_text(root)
	_expect_reply_names_conflicts(night_place_miss, Night, {"who": "Vesper", "place": "parapet", "hour": "44"})
	_press(root, "Tower")
	_press(root, "Submit theory")
	var night_accepted := _verdict_text(root)
	_expect(night_accepted.find("fits every exhibit") >= 0, "night bell board rejected the true theory: %s" % night_accepted)
	_expect(night_accepted.find(NIGHT_TIMELINE) >= 0, "night bell board timeline: %s" % night_accepted)
	_expect(night_accepted.find("Vesper (night ringer) stopped the night bell at 44") >= 0, "night bell board omits Vesper at 44: %s" % night_accepted)
	_expect(night_accepted.find("to the tower") >= 0, "night bell board omits the tower: %s" % night_accepted)
	_expect(night_accepted.find("so the watch would read early") >= 0, "night bell board omits the early watch: %s" % night_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var night_cleared := _verdict_text(root)
	_expect(night_cleared.find("who stopped the night bell") >= 0, "cleared night board: %s" % night_cleared)
	_expect(night_cleared.find("fits every exhibit") == -1, "cleared night board stayed accepted: %s" % night_cleared)
	_press(root, "Menu")
	_press(root, "Open The tide ledger")
	var tide_from_night := _visible_label_blob(root)
	_expect(tide_from_night.find("Ledger line") >= 0, "could not return to The tide ledger from The night bell")
	_expect(tide_from_night.find("Bell line") == -1, "night bell papers stayed up after switching files")
	_press(root, "Menu")
	_press(root, "Open The salt mark")
	var salt_open := _visible_label_blob(root)
	_expect(salt_open.find("Salt line") >= 0, "salt mark file did not open")
	_expect(salt_open.find("Heavy note") >= 0, "salt mark file did not show its exhibits")
	_expect(salt_open.find("CW-14") >= 0, "salt mark file omits CW-14")
	_expect(salt_open.find("Complaint slip") == -1, "spare key papers showed inside The salt mark")
	_expect(salt_open.find("Cut list") == -1, "rehearsal papers showed inside The salt mark")
	_expect(salt_open.find("Move order") == -1, "gilt stamp papers showed inside The salt mark")
	_expect(salt_open.find("Whistle slip") == -1, "ferry bell papers showed inside The salt mark")
	_expect(salt_open.find("Frost note") == -1, "weather slate papers showed inside The salt mark")
	_expect(salt_open.find("Trough tag") == -1, "loom shuttle papers showed inside The salt mark")
	_expect(salt_open.find("Fuel line") == -1, "hive smoker papers showed inside The salt mark")
	_expect(salt_open.find("Weight line") == -1, "glass pontil papers showed inside The salt mark")
	_expect(salt_open.find("Lock line") == -1, "press proof papers showed inside The salt mark")
	_expect(salt_open.find("Cup line") == -1, "assay cup papers showed inside The salt mark")
	_expect(salt_open.find("Mark line") == -1, "kiln chalk papers showed inside The salt mark")
	_expect(salt_open.find("Ledger line") == -1, "tide ledger papers showed inside The salt mark")
	_expect(salt_open.find("Bell line") == -1, "night bell papers showed inside The salt mark")
	_press(root, "Submit theory")
	var empty_salt := _verdict_text(root)
	_expect(empty_salt.find("who scored the salt mark") >= 0, "empty salt board: %s" % empty_salt)
	_expect(empty_salt.find("where they scored the mark") >= 0, "empty salt board: %s" % empty_salt)
	_expect(empty_salt.find("at which hour they scored the mark") >= 0, "empty salt board: %s" % empty_salt)
	_expect(empty_salt.find("who took the spare key") == -1, "empty salt board used the spare key slot: %s" % empty_salt)
	_expect(empty_salt.find("rehearsal score") == -1, "empty salt board used a rehearsal slot: %s" % empty_salt)
	_expect(empty_salt.find("gilt stamp") == -1, "empty salt board used a gilt slot: %s" % empty_salt)
	_expect(empty_salt.find("ferry bell") == -1, "empty salt board used a ferry slot: %s" % empty_salt)
	_expect(empty_salt.find("weather slate") == -1, "empty salt board used a weather slot: %s" % empty_salt)
	_expect(empty_salt.find("loom shuttle") == -1, "empty salt board used a loom slot: %s" % empty_salt)
	_expect(empty_salt.find("hive smoker") == -1, "empty salt board used a hive slot: %s" % empty_salt)
	_expect(empty_salt.find("glass pontil") == -1, "empty salt board used a glass slot: %s" % empty_salt)
	_expect(empty_salt.find("press proof") == -1, "empty salt board used a press slot: %s" % empty_salt)
	_expect(empty_salt.find("assay cup") == -1, "empty salt board used an assay slot: %s" % empty_salt)
	_expect(empty_salt.find("kiln mark") == -1, "empty salt board used a kiln slot: %s" % empty_salt)
	_expect(empty_salt.find("tide ledger") == -1, "empty salt board used a tide slot: %s" % empty_salt)
	_expect(empty_salt.find("night bell") == -1, "empty salt board used a night slot: %s" % empty_salt)
	_expect(empty_salt.to_lower().find("conflict") == -1, "empty salt board talked about a conflict: %s" % empty_salt)
	_press(root, "Holt")
	_press(root, "Pan")
	_press(root, "20")
	_press(root, "Submit theory")
	var salt_miss := _verdict_text(root)
	_expect_reply_names_conflicts(salt_miss, Salt, {"who": "Holt", "place": "pan", "hour": "20"})
	_expect(salt_miss.find("Stick slip") >= 0, "wrong hour reply omits Stick slip: %s" % salt_miss)
	_expect(salt_miss.find("Heavy note") >= 0, "wrong hour reply omits Heavy note: %s" % salt_miss)
	_expect(salt_miss.find("Draw line") >= 0, "wrong hour reply omits Draw line: %s" % salt_miss)
	_press(root, "Cistern")
	_press(root, "19")
	_press(root, "Submit theory")
	var salt_place_miss := _verdict_text(root)
	_expect_reply_names_conflicts(salt_place_miss, Salt, {"who": "Holt", "place": "cistern", "hour": "19"})
	_press(root, "Pan")
	_press(root, "Submit theory")
	var salt_accepted := _verdict_text(root)
	_expect(salt_accepted.find("fits every exhibit") >= 0, "salt mark board rejected the true theory: %s" % salt_accepted)
	_expect(salt_accepted.find(SALT_TIMELINE) >= 0, "salt mark board timeline: %s" % salt_accepted)
	_expect(salt_accepted.find("Holt (salt hand) scored the salt mark at 19") >= 0, "salt mark board omits Holt at 19: %s" % salt_accepted)
	_expect(salt_accepted.find("to the pan") >= 0, "salt mark board omits the pan: %s" % salt_accepted)
	_expect(salt_accepted.find("so the weigh would read heavy") >= 0, "salt mark board omits the heavy weigh: %s" % salt_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var salt_cleared := _verdict_text(root)
	_expect(salt_cleared.find("who scored the salt mark") >= 0, "cleared salt board: %s" % salt_cleared)
	_expect(salt_cleared.find("fits every exhibit") == -1, "cleared salt board stayed accepted: %s" % salt_cleared)
	_press(root, "Menu")
	_press(root, "Open The night bell")
	var night_from_salt := _visible_label_blob(root)
	_expect(night_from_salt.find("Bell line") >= 0, "could not return to The night bell from The salt mark")
	_expect(night_from_salt.find("Salt line") == -1, "salt mark papers stayed up after switching files")
	_press(root, "Menu")
	_press(root, "Open The wick trim")
	var wick_open := _visible_label_blob(root)
	_expect(wick_open.find("Oil note") >= 0, "wick trim file did not open")
	_expect(wick_open.find("Fog line") >= 0, "wick trim file did not show its exhibits")
	_expect(wick_open.find("CW-15") >= 0, "wick trim file omits CW-15")
	_expect(wick_open.find("Complaint slip") == -1, "spare key papers showed inside The wick trim")
	_expect(wick_open.find("Cut list") == -1, "rehearsal papers showed inside The wick trim")
	_expect(wick_open.find("Move order") == -1, "gilt stamp papers showed inside The wick trim")
	_expect(wick_open.find("Whistle slip") == -1, "ferry bell papers showed inside The wick trim")
	_expect(wick_open.find("Frost note") == -1, "weather slate papers showed inside The wick trim")
	_expect(wick_open.find("Trough tag") == -1, "loom shuttle papers showed inside The wick trim")
	_expect(wick_open.find("Fuel line") == -1, "hive smoker papers showed inside The wick trim")
	_expect(wick_open.find("Weight line") == -1, "glass pontil papers showed inside The wick trim")
	_expect(wick_open.find("Lock line") == -1, "press proof papers showed inside The wick trim")
	_expect(wick_open.find("Cup line") == -1, "assay cup papers showed inside The wick trim")
	_expect(wick_open.find("Mark line") == -1, "kiln chalk papers showed inside The wick trim")
	_expect(wick_open.find("Ledger line") == -1, "tide ledger papers showed inside The wick trim")
	_expect(wick_open.find("Bell line") == -1, "night bell papers showed inside The wick trim")
	_expect(wick_open.find("Salt line") == -1, "salt mark papers showed inside The wick trim")
	_press(root, "Submit theory")
	var empty_wick := _verdict_text(root)
	_expect(empty_wick.find("who trimmed the wick") >= 0, "empty wick board: %s" % empty_wick)
	_expect(empty_wick.find("where they trimmed the wick") >= 0, "empty wick board: %s" % empty_wick)
	_expect(empty_wick.find("at which hour they trimmed the wick") >= 0, "empty wick board: %s" % empty_wick)
	_expect(empty_wick.find("who took the spare key") == -1, "empty wick board used the spare key slot: %s" % empty_wick)
	_expect(empty_wick.find("rehearsal score") == -1, "empty wick board used a rehearsal slot: %s" % empty_wick)
	_expect(empty_wick.find("gilt stamp") == -1, "empty wick board used a gilt slot: %s" % empty_wick)
	_expect(empty_wick.find("ferry bell") == -1, "empty wick board used a ferry slot: %s" % empty_wick)
	_expect(empty_wick.find("weather slate") == -1, "empty wick board used a weather slot: %s" % empty_wick)
	_expect(empty_wick.find("loom shuttle") == -1, "empty wick board used a loom slot: %s" % empty_wick)
	_expect(empty_wick.find("hive smoker") == -1, "empty wick board used a hive slot: %s" % empty_wick)
	_expect(empty_wick.find("glass pontil") == -1, "empty wick board used a glass slot: %s" % empty_wick)
	_expect(empty_wick.find("press proof") == -1, "empty wick board used a press slot: %s" % empty_wick)
	_expect(empty_wick.find("assay cup") == -1, "empty wick board used an assay slot: %s" % empty_wick)
	_expect(empty_wick.find("kiln mark") == -1, "empty wick board used a kiln slot: %s" % empty_wick)
	_expect(empty_wick.find("tide ledger") == -1, "empty wick board used a tide slot: %s" % empty_wick)
	_expect(empty_wick.find("night bell") == -1, "empty wick board used a night slot: %s" % empty_wick)
	_expect(empty_wick.find("salt mark") == -1, "empty wick board used a salt slot: %s" % empty_wick)
	_expect(empty_wick.to_lower().find("conflict") == -1, "empty wick board talked about a conflict: %s" % empty_wick)
	_press(root, "Quin")
	_press(root, "Loft")
	_press(root, "5")
	_press(root, "Submit theory")
	var wick_miss := _verdict_text(root)
	_expect_reply_names_conflicts(wick_miss, Wick, {"who": "Quin", "place": "loft", "hour": "5"})
	_expect(wick_miss.find("Watch leaf") >= 0, "wrong hour reply omits Watch leaf: %s" % wick_miss)
	_expect(wick_miss.find("Fog line") >= 0, "wrong hour reply omits Fog line: %s" % wick_miss)
	_expect(wick_miss.find("Lamp order") >= 0, "wrong hour reply omits Lamp order: %s" % wick_miss)
	_press(root, "Clear")
	_press(root, "Quin")
	_press(root, "Loft")
	_press(root, "4")
	_press(root, "Submit theory")
	var wick_accepted := _verdict_text(root)
	_expect(wick_accepted.find("fits every exhibit") >= 0, "wick trim board rejected the true theory: %s" % wick_accepted)
	_expect(wick_accepted.find(WICK_TIMELINE) >= 0, "wick trim board timeline: %s" % wick_accepted)
	_expect(wick_accepted.find("Quin (wick hand) trimmed the wick in the loft at 4") >= 0, "wick trim board omits Quin at 4: %s" % wick_accepted)
	_expect(wick_accepted.find("in the loft") >= 0, "wick trim board omits the loft: %s" % wick_accepted)
	_expect(wick_accepted.find("so the lamp would hold through the fog") >= 0, "wick trim board omits the fog: %s" % wick_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var wick_cleared := _verdict_text(root)
	_expect(wick_cleared.find("who trimmed the wick") >= 0, "cleared wick board: %s" % wick_cleared)
	_expect(wick_cleared.find("fits every exhibit") == -1, "cleared wick board stayed accepted: %s" % wick_cleared)
	_press(root, "Menu")
	_press(root, "Open The salt mark")
	var salt_from_wick := _visible_label_blob(root)
	_expect(salt_from_wick.find("Salt line") >= 0, "could not return to The salt mark from The wick trim")
	_expect(salt_from_wick.find("Oil note") == -1, "wick trim papers stayed up after switching files")
	_press(root, "Menu")
	_press(root, "Open The glass anneal")
	var anneal_open := _visible_label_blob(root)
	_expect(anneal_open.find("Gather note") >= 0, "glass anneal file did not open")
	_expect(anneal_open.find("Crack note") >= 0, "glass anneal file did not show its exhibits")
	_expect(anneal_open.find("CW-16") >= 0, "glass anneal file omits CW-16")
	_expect(anneal_open.find("Complaint slip") == -1, "spare key papers showed inside The glass anneal")
	_expect(anneal_open.find("Cut list") == -1, "rehearsal papers showed inside The glass anneal")
	_expect(anneal_open.find("Move order") == -1, "gilt stamp papers showed inside The glass anneal")
	_expect(anneal_open.find("Whistle slip") == -1, "ferry bell papers showed inside The glass anneal")
	_expect(anneal_open.find("Frost note") == -1, "weather slate papers showed inside The glass anneal")
	_expect(anneal_open.find("Trough tag") == -1, "loom shuttle papers showed inside The glass anneal")
	_expect(anneal_open.find("Fuel line") == -1, "hive smoker papers showed inside The glass anneal")
	_expect(anneal_open.find("Weight line") == -1, "glass pontil papers showed inside The glass anneal")
	_expect(anneal_open.find("Lock line") == -1, "press proof papers showed inside The glass anneal")
	_expect(anneal_open.find("Cup line") == -1, "assay cup papers showed inside The glass anneal")
	_expect(anneal_open.find("Mark line") == -1, "kiln chalk papers showed inside The glass anneal")
	_expect(anneal_open.find("Ledger line") == -1, "tide ledger papers showed inside The glass anneal")
	_expect(anneal_open.find("Bell line") == -1, "night bell papers showed inside The glass anneal")
	_expect(anneal_open.find("Salt line") == -1, "salt mark papers showed inside The glass anneal")
	_expect(anneal_open.find("Oil note") == -1, "wick trim papers showed inside The glass anneal")
	_press(root, "Submit theory")
	var empty_anneal := _verdict_text(root)
	_expect(empty_anneal.find("who annealed the gather") >= 0, "empty anneal board: %s" % empty_anneal)
	_expect(empty_anneal.find("where they annealed the gather") >= 0, "empty anneal board: %s" % empty_anneal)
	_expect(empty_anneal.find("at which hour they annealed the gather") >= 0, "empty anneal board: %s" % empty_anneal)
	_expect(empty_anneal.find("who took the spare key") == -1, "empty anneal board used the spare key slot: %s" % empty_anneal)
	_expect(empty_anneal.find("rehearsal score") == -1, "empty anneal board used a rehearsal slot: %s" % empty_anneal)
	_expect(empty_anneal.find("gilt stamp") == -1, "empty anneal board used a gilt slot: %s" % empty_anneal)
	_expect(empty_anneal.find("ferry bell") == -1, "empty anneal board used a ferry slot: %s" % empty_anneal)
	_expect(empty_anneal.find("weather slate") == -1, "empty anneal board used a weather slot: %s" % empty_anneal)
	_expect(empty_anneal.find("loom shuttle") == -1, "empty anneal board used a loom slot: %s" % empty_anneal)
	_expect(empty_anneal.find("hive smoker") == -1, "empty anneal board used a hive slot: %s" % empty_anneal)
	_expect(empty_anneal.find("glass pontil") == -1, "empty anneal board used a glass slot: %s" % empty_anneal)
	_expect(empty_anneal.find("press proof") == -1, "empty anneal board used a press slot: %s" % empty_anneal)
	_expect(empty_anneal.find("assay cup") == -1, "empty anneal board used an assay slot: %s" % empty_anneal)
	_expect(empty_anneal.find("kiln mark") == -1, "empty anneal board used a kiln slot: %s" % empty_anneal)
	_expect(empty_anneal.find("tide ledger") == -1, "empty anneal board used a tide slot: %s" % empty_anneal)
	_expect(empty_anneal.find("night bell") == -1, "empty anneal board used a night slot: %s" % empty_anneal)
	_expect(empty_anneal.find("salt mark") == -1, "empty anneal board used a salt slot: %s" % empty_anneal)
	_expect(empty_anneal.find("wick") == -1, "empty anneal board used a wick slot: %s" % empty_anneal)
	_expect(empty_anneal.to_lower().find("conflict") == -1, "empty anneal board talked about a conflict: %s" % empty_anneal)
	_press(root, "Tess")
	_press(root, "Lehr")
	_press(root, "11")
	_press(root, "Submit theory")
	var anneal_miss := _verdict_text(root)
	_expect_reply_names_conflicts(anneal_miss, Anneal, {"who": "Tess", "place": "lehr", "hour": "11"})
	_expect(anneal_miss.find("Shoulder leaf") >= 0, "wrong hour reply omits Shoulder leaf: %s" % anneal_miss)
	_expect(anneal_miss.find("Crack note") >= 0, "wrong hour reply omits Crack note: %s" % anneal_miss)
	_expect(anneal_miss.find("Latch order") >= 0, "wrong hour reply omits Latch order: %s" % anneal_miss)
	_press(root, "Clear")
	_press(root, "Tess")
	_press(root, "Lehr")
	_press(root, "10")
	_press(root, "Submit theory")
	var anneal_accepted := _verdict_text(root)
	_expect(anneal_accepted.find("fits every exhibit") >= 0, "glass anneal board rejected the true theory: %s" % anneal_accepted)
	_expect(anneal_accepted.find(ANNEAL_TIMELINE) >= 0, "glass anneal board timeline: %s" % anneal_accepted)
	_expect(anneal_accepted.find("Tess (anneal hand) annealed the gather in the lehr at 10") >= 0, "glass anneal board omits Tess at 10: %s" % anneal_accepted)
	_expect(anneal_accepted.find("in the lehr") >= 0, "glass anneal board omits the lehr: %s" % anneal_accepted)
	_expect(anneal_accepted.find("so the pane would cool without a crack") >= 0, "glass anneal board omits the crack: %s" % anneal_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var anneal_cleared := _verdict_text(root)
	_expect(anneal_cleared.find("who annealed the gather") >= 0, "cleared anneal board: %s" % anneal_cleared)
	_expect(anneal_cleared.find("fits every exhibit") == -1, "cleared anneal board stayed accepted: %s" % anneal_cleared)
	_press(root, "Menu")
	_press(root, "Open The wick trim")
	var wick_from_anneal := _visible_label_blob(root)
	_expect(wick_from_anneal.find("Oil note") >= 0, "could not return to The wick trim from The glass anneal")
	_expect(wick_from_anneal.find("Gather note") == -1, "glass anneal papers stayed up after switching files")
	_press(root, "Menu")
	_press(root, "Open The orchard graft")
	var graft_open := _visible_label_blob(root)
	_expect(graft_open.find("Scion note") >= 0, "orchard graft file did not open")
	_expect(graft_open.find("Take note") >= 0, "orchard graft file did not show its exhibits")
	_expect(graft_open.find("CW-17") >= 0, "orchard graft file omits CW-17")
	_expect(graft_open.find("Complaint slip") == -1, "spare key papers showed inside The orchard graft")
	_expect(graft_open.find("Cut list") == -1, "rehearsal papers showed inside The orchard graft")
	_expect(graft_open.find("Move order") == -1, "gilt stamp papers showed inside The orchard graft")
	_expect(graft_open.find("Whistle slip") == -1, "ferry bell papers showed inside The orchard graft")
	_expect(graft_open.find("Frost note") == -1, "weather slate papers showed inside The orchard graft")
	_expect(graft_open.find("Trough tag") == -1, "loom shuttle papers showed inside The orchard graft")
	_expect(graft_open.find("Fuel line") == -1, "hive smoker papers showed inside The orchard graft")
	_expect(graft_open.find("Weight line") == -1, "glass pontil papers showed inside The orchard graft")
	_expect(graft_open.find("Lock line") == -1, "press proof papers showed inside The orchard graft")
	_expect(graft_open.find("Cup line") == -1, "assay cup papers showed inside The orchard graft")
	_expect(graft_open.find("Mark line") == -1, "kiln chalk papers showed inside The orchard graft")
	_expect(graft_open.find("Ledger line") == -1, "tide ledger papers showed inside The orchard graft")
	_expect(graft_open.find("Bell line") == -1, "night bell papers showed inside The orchard graft")
	_expect(graft_open.find("Salt line") == -1, "salt mark papers showed inside The orchard graft")
	_expect(graft_open.find("Oil note") == -1, "wick trim papers showed inside The orchard graft")
	_expect(graft_open.find("Gather note") == -1, "glass anneal papers showed inside The orchard graft")
	_press(root, "Submit theory")
	var empty_graft := _verdict_text(root)
	_expect(empty_graft.find("who grafted the scion") >= 0, "empty graft board: %s" % empty_graft)
	_expect(empty_graft.find("where they grafted the scion") >= 0, "empty graft board: %s" % empty_graft)
	_expect(empty_graft.find("at which hour they grafted the scion") >= 0, "empty graft board: %s" % empty_graft)
	_expect(empty_graft.find("who took the spare key") == -1, "empty graft board used the spare key slot: %s" % empty_graft)
	_expect(empty_graft.find("who annealed the gather") == -1, "empty graft board used an anneal slot: %s" % empty_graft)
	_expect(empty_graft.to_lower().find("conflict") == -1, "empty graft board talked about a conflict: %s" % empty_graft)
	_press(root, "Ness")
	_press(root, "Row")
	_press(root, "15")
	_press(root, "Submit theory")
	var graft_miss := _verdict_text(root)
	_expect_reply_names_conflicts(graft_miss, Graft, {"who": "Ness", "place": "row", "hour": "15"})
	_expect(graft_miss.find("Scion note") >= 0, "wrong triple reply omits Scion note: %s" % graft_miss)
	_expect(graft_miss.find("Path sight") >= 0, "wrong triple reply omits Path sight: %s" % graft_miss)
	_expect(graft_miss.find("Knife peg") >= 0, "wrong triple reply omits Knife peg: %s" % graft_miss)
	_expect(graft_miss.find("Bench slate") >= 0, "wrong triple reply omits Bench slate: %s" % graft_miss)
	_expect(graft_miss.find("Raffia card") >= 0, "wrong triple reply omits Raffia card: %s" % graft_miss)
	_expect(graft_miss.find("Water slip") >= 0, "wrong triple reply omits Water slip: %s" % graft_miss)
	_expect(graft_miss.find("Hour leaf") >= 0, "wrong triple reply omits Hour leaf: %s" % graft_miss)
	_expect(graft_miss.find("Take note") >= 0, "wrong triple reply omits Take note: %s" % graft_miss)
	_expect(graft_miss.find("Shut order") >= 0, "wrong triple reply omits Shut order: %s" % graft_miss)
	_press(root, "Calder")
	_press(root, "Nursery")
	_press(root, "16")
	_press(root, "Submit theory")
	var graft_accepted := _verdict_text(root)
	_expect(graft_accepted.find("fits every exhibit") >= 0, "orchard graft board rejected the true theory: %s" % graft_accepted)
	_expect(graft_accepted.find(GRAFT_TIMELINE) >= 0, "orchard graft board timeline: %s" % graft_accepted)
	_expect(graft_accepted.find("Calder (graft hand) grafted the scion in the nursery at 16") >= 0, "orchard graft board omits Calder at 16: %s" % graft_accepted)
	_expect(graft_accepted.find("in the nursery") >= 0, "orchard graft board omits the nursery: %s" % graft_accepted)
	_expect(graft_accepted.find("so the row would take before the frost") >= 0, "orchard graft board omits the frost: %s" % graft_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var graft_cleared := _verdict_text(root)
	_expect(graft_cleared.find("who grafted the scion") >= 0, "cleared graft board: %s" % graft_cleared)
	_expect(graft_cleared.find("fits every exhibit") == -1, "cleared graft board stayed accepted: %s" % graft_cleared)
	_press(root, "Menu")
	_press(root, "Open The glass anneal")
	var anneal_from_graft := _visible_label_blob(root)
	_expect(anneal_from_graft.find("Gather note") >= 0, "could not return to The glass anneal from The orchard graft")
	_expect(anneal_from_graft.find("Scion note") == -1, "orchard graft papers stayed up after switching files")

	_press(root, "Menu")
	_press(root, "Open The dye vat")
	var dye_open := _visible_label_blob(root)
	_expect(dye_open.find("Winder chit") >= 0, "dye vat file did not open")
	_expect(dye_open.find("Color note") >= 0, "dye vat file did not show its exhibits")
	_expect(dye_open.find("CW-18") >= 0, "dye vat file omits CW-18")
	_expect(dye_open.find("Complaint slip") == -1, "spare key papers showed inside The dye vat")
	_expect(dye_open.find("Cut list") == -1, "rehearsal papers showed inside The dye vat")
	_expect(dye_open.find("Move order") == -1, "gilt stamp papers showed inside The dye vat")
	_expect(dye_open.find("Whistle slip") == -1, "ferry bell papers showed inside The dye vat")
	_expect(dye_open.find("Frost note") == -1, "weather slate papers showed inside The dye vat")
	_expect(dye_open.find("Trough tag") == -1, "loom shuttle papers showed inside The dye vat")
	_expect(dye_open.find("Fuel line") == -1, "hive smoker papers showed inside The dye vat")
	_expect(dye_open.find("Weight line") == -1, "glass pontil papers showed inside The dye vat")
	_expect(dye_open.find("Lock line") == -1, "press proof papers showed inside The dye vat")
	_expect(dye_open.find("Cup line") == -1, "assay cup papers showed inside The dye vat")
	_expect(dye_open.find("Mark line") == -1, "kiln chalk papers showed inside The dye vat")
	_expect(dye_open.find("Ledger line") == -1, "tide ledger papers showed inside The dye vat")
	_expect(dye_open.find("Bell line") == -1, "night bell papers showed inside The dye vat")
	_expect(dye_open.find("Salt line") == -1, "salt mark papers showed inside The dye vat")
	_expect(dye_open.find("Oil note") == -1, "wick trim papers showed inside The dye vat")
	_expect(dye_open.find("Gather note") == -1, "glass anneal papers showed inside The dye vat")
	_expect(dye_open.find("Scion note") == -1, "orchard graft papers showed inside The dye vat")
	_press(root, "Submit theory")
	var empty_dye := _verdict_text(root)
	_expect(empty_dye.find("who dipped the skein") >= 0, "empty dye board: %s" % empty_dye)
	_expect(empty_dye.find("where they dipped the skein") >= 0, "empty dye board: %s" % empty_dye)
	_expect(empty_dye.find("at which hour they dipped the skein") >= 0, "empty dye board: %s" % empty_dye)
	_expect(empty_dye.find("who took the spare key") == -1, "empty dye board used the spare key slot: %s" % empty_dye)
	_expect(empty_dye.find("who grafted the scion") == -1, "empty dye board used a graft slot: %s" % empty_dye)
	_expect(empty_dye.to_lower().find("conflict") == -1, "empty dye board talked about a conflict: %s" % empty_dye)
	_press(root, "Pim")
	_press(root, "Line")
	_press(root, "6")
	_press(root, "Submit theory")
	var dye_miss := _verdict_text(root)
	_expect_reply_names_conflicts(dye_miss, Dye, {"who": "Pim", "place": "line", "hour": "6"})
	_expect(dye_miss.find("Winder chit") >= 0, "wrong triple reply omits Winder chit: %s" % dye_miss)
	_expect(dye_miss.find("Line sight") >= 0, "wrong triple reply omits Line sight: %s" % dye_miss)
	_expect(dye_miss.find("Paddle peg") >= 0, "wrong triple reply omits Paddle peg: %s" % dye_miss)
	_expect(dye_miss.find("Vat slate") >= 0, "wrong triple reply omits Vat slate: %s" % dye_miss)
	_expect(dye_miss.find("Indigo card") >= 0, "wrong triple reply omits Indigo card: %s" % dye_miss)
	_expect(dye_miss.find("Stretch slip") >= 0, "wrong triple reply omits Stretch slip: %s" % dye_miss)
	_expect(dye_miss.find("Dip leaf") >= 0, "wrong triple reply omits Dip leaf: %s" % dye_miss)
	_expect(dye_miss.find("Color note") >= 0, "wrong triple reply omits Color note: %s" % dye_miss)
	_expect(dye_miss.find("Rake order") >= 0, "wrong triple reply omits Rake order: %s" % dye_miss)
	_press(root, "Sera")
	_press(root, "Vat")
	_press(root, "7")
	_press(root, "Submit theory")
	var dye_accepted := _verdict_text(root)
	_expect(dye_accepted.find("fits every exhibit") >= 0, "dye vat board rejected the true theory: %s" % dye_accepted)
	_expect(dye_accepted.find(DYE_TIMELINE) >= 0, "dye vat board timeline: %s" % dye_accepted)
	_expect(dye_accepted.find("Sera (dip hand) dipped the skein in the vat at 7") >= 0, "dye vat board omits Sera at 7: %s" % dye_accepted)
	_expect(dye_accepted.find("in the vat") >= 0, "dye vat board omits the vat: %s" % dye_accepted)
	_expect(dye_accepted.find("so the line would take the indigo") >= 0, "dye vat board omits the indigo: %s" % dye_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var dye_cleared := _verdict_text(root)
	_expect(dye_cleared.find("who dipped the skein") >= 0, "cleared dye board: %s" % dye_cleared)
	_expect(dye_cleared.find("fits every exhibit") == -1, "cleared dye board stayed accepted: %s" % dye_cleared)
	_press(root, "Menu")
	_press(root, "Open The orchard graft")
	var graft_from_dye := _visible_label_blob(root)
	_expect(graft_from_dye.find("Scion note") >= 0, "could not return to The orchard graft from The dye vat")
	_expect(graft_from_dye.find("Winder chit") == -1, "dye vat papers stayed up after switching files")

	_press(root, "Menu")
	_press(root, "Open The tar kettle")
	var tar_open := _visible_label_blob(root)
	_expect(tar_open.find("Rope chit") >= 0, "tar kettle file did not open")
	_expect(tar_open.find("Pitch note") >= 0, "tar kettle file did not show its exhibits")
	_expect(tar_open.find("CW-19") >= 0, "tar kettle file omits CW-19")
	_expect(tar_open.find("Complaint slip") == -1, "spare key papers showed inside The tar kettle")
	_expect(tar_open.find("Cut list") == -1, "rehearsal papers showed inside The tar kettle")
	_expect(tar_open.find("Move order") == -1, "gilt stamp papers showed inside The tar kettle")
	_expect(tar_open.find("Whistle slip") == -1, "ferry bell papers showed inside The tar kettle")
	_expect(tar_open.find("Frost note") == -1, "weather slate papers showed inside The tar kettle")
	_expect(tar_open.find("Trough tag") == -1, "loom shuttle papers showed inside The tar kettle")
	_expect(tar_open.find("Fuel line") == -1, "hive smoker papers showed inside The tar kettle")
	_expect(tar_open.find("Weight line") == -1, "glass pontil papers showed inside The tar kettle")
	_expect(tar_open.find("Lock line") == -1, "press proof papers showed inside The tar kettle")
	_expect(tar_open.find("Cup line") == -1, "assay cup papers showed inside The tar kettle")
	_expect(tar_open.find("Mark line") == -1, "kiln chalk papers showed inside The tar kettle")
	_expect(tar_open.find("Ledger line") == -1, "tide ledger papers showed inside The tar kettle")
	_expect(tar_open.find("Bell line") == -1, "night bell papers showed inside The tar kettle")
	_expect(tar_open.find("Salt line") == -1, "salt mark papers showed inside The tar kettle")
	_expect(tar_open.find("Oil note") == -1, "wick trim papers showed inside The tar kettle")
	_expect(tar_open.find("Gather note") == -1, "glass anneal papers showed inside The tar kettle")
	_expect(tar_open.find("Scion note") == -1, "orchard graft papers showed inside The tar kettle")
	_expect(tar_open.find("Winder chit") == -1, "dye vat papers showed inside The tar kettle")
	_press(root, "Submit theory")
	var empty_tar := _verdict_text(root)
	_expect(empty_tar.find("who tarred the rope") >= 0, "empty tar board: %s" % empty_tar)
	_expect(empty_tar.find("where they tarred the rope") >= 0, "empty tar board: %s" % empty_tar)
	_expect(empty_tar.find("at which hour they tarred the rope") >= 0, "empty tar board: %s" % empty_tar)
	_expect(empty_tar.find("who took the spare key") == -1, "empty tar board used the spare key slot: %s" % empty_tar)
	_expect(empty_tar.find("who dipped the skein") == -1, "empty tar board used a dye slot: %s" % empty_tar)
	_expect(empty_tar.to_lower().find("conflict") == -1, "empty tar board talked about a conflict: %s" % empty_tar)
	_press(root, "Lumen")
	_press(root, "Walk")
	_press(root, "5")
	_press(root, "Submit theory")
	var tar_miss := _verdict_text(root)
	_expect_reply_names_conflicts(tar_miss, Tar, {"who": "Lumen", "place": "walk", "hour": "5"})
	_expect(tar_miss.find("Rope chit") >= 0, "wrong triple reply omits Rope chit: %s" % tar_miss)
	_expect(tar_miss.find("Walk sight") >= 0, "wrong triple reply omits Walk sight: %s" % tar_miss)
	_expect(tar_miss.find("Hook peg") >= 0, "wrong triple reply omits Hook peg: %s" % tar_miss)
	_expect(tar_miss.find("Kettle slate") >= 0, "wrong triple reply omits Kettle slate: %s" % tar_miss)
	_expect(tar_miss.find("Winch card") >= 0, "wrong triple reply omits Winch card: %s" % tar_miss)
	_expect(tar_miss.find("Span slip") >= 0, "wrong triple reply omits Span slip: %s" % tar_miss)
	_expect(tar_miss.find("Tar leaf") >= 0, "wrong triple reply omits Tar leaf: %s" % tar_miss)
	_expect(tar_miss.find("Pitch note") >= 0, "wrong triple reply omits Pitch note: %s" % tar_miss)
	_expect(tar_miss.find("Sweep order") >= 0, "wrong triple reply omits Sweep order: %s" % tar_miss)
	_press(root, "Rho")
	_press(root, "Kettle")
	_press(root, "6")
	_press(root, "Submit theory")
	var tar_accepted := _verdict_text(root)
	_expect(tar_accepted.find("fits every exhibit") >= 0, "tar kettle board rejected the true theory: %s" % tar_accepted)
	_expect(tar_accepted.find(TAR_TIMELINE) >= 0, "tar kettle board timeline: %s" % tar_accepted)
	_expect(tar_accepted.find("Rho (tar hand) tarred the rope in the kettle at 6") >= 0, "tar kettle board omits Rho at 6: %s" % tar_accepted)
	_expect(tar_accepted.find("in the kettle") >= 0, "tar kettle board omits the kettle: %s" % tar_accepted)
	_expect(tar_accepted.find("so the walk would take the tar") >= 0, "tar kettle board omits the tar: %s" % tar_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var tar_cleared := _verdict_text(root)
	_expect(tar_cleared.find("who tarred the rope") >= 0, "cleared tar board: %s" % tar_cleared)
	_expect(tar_cleared.find("fits every exhibit") == -1, "cleared tar board stayed accepted: %s" % tar_cleared)
	_press(root, "Menu")
	_press(root, "Open The dye vat")
	var dye_from_tar := _visible_label_blob(root)
	_expect(dye_from_tar.find("Winder chit") >= 0, "could not return to The dye vat from The tar kettle")
	_expect(dye_from_tar.find("Rope chit") == -1, "tar kettle papers stayed up after switching files")
	_press(root, "Menu")
	_press(root, "Open The cork press")
	var cork_open := _visible_label_blob(root)
	_expect(cork_open.find("Cutter chit") >= 0, "cork press file did not open")
	_expect(cork_open.find("Seal note") >= 0, "cork press file did not show its exhibits")
	_expect(cork_open.find("CW-20") >= 0, "cork press file omits CW-20")
	_expect(cork_open.find("Complaint slip") == -1, "spare key papers showed inside The cork press")
	_expect(cork_open.find("Cut list") == -1, "rehearsal papers showed inside The cork press")
	_expect(cork_open.find("Move order") == -1, "gilt stamp papers showed inside The cork press")
	_expect(cork_open.find("Whistle slip") == -1, "ferry bell papers showed inside The cork press")
	_expect(cork_open.find("Frost note") == -1, "weather slate papers showed inside The cork press")
	_expect(cork_open.find("Trough tag") == -1, "loom shuttle papers showed inside The cork press")
	_expect(cork_open.find("Fuel line") == -1, "hive smoker papers showed inside The cork press")
	_expect(cork_open.find("Weight line") == -1, "glass pontil papers showed inside The cork press")
	_expect(cork_open.find("Lock line") == -1, "press proof papers showed inside The cork press")
	_expect(cork_open.find("Cup line") == -1, "assay cup papers showed inside The cork press")
	_expect(cork_open.find("Mark line") == -1, "kiln chalk papers showed inside The cork press")
	_expect(cork_open.find("Ledger line") == -1, "tide ledger papers showed inside The cork press")
	_expect(cork_open.find("Bell line") == -1, "night bell papers showed inside The cork press")
	_expect(cork_open.find("Salt line") == -1, "salt mark papers showed inside The cork press")
	_expect(cork_open.find("Oil note") == -1, "wick trim papers showed inside The cork press")
	_expect(cork_open.find("Gather note") == -1, "glass anneal papers showed inside The cork press")
	_expect(cork_open.find("Scion note") == -1, "orchard graft papers showed inside The cork press")
	_expect(cork_open.find("Winder chit") == -1, "dye vat papers showed inside The cork press")
	_expect(cork_open.find("Rope chit") == -1, "tar kettle papers showed inside The cork press")
	_press(root, "Submit theory")
	var empty_cork := _verdict_text(root)
	_expect(empty_cork.find("who pressed the cork") >= 0, "empty cork board: %s" % empty_cork)
	_expect(empty_cork.find("where they pressed the cork") >= 0, "empty cork board: %s" % empty_cork)
	_expect(empty_cork.find("at which hour they pressed the cork") >= 0, "empty cork board: %s" % empty_cork)
	_expect(empty_cork.find("who took the spare key") == -1, "empty cork board used the spare key slot: %s" % empty_cork)
	_expect(empty_cork.find("who tarred the rope") == -1, "empty cork board used a tar slot: %s" % empty_cork)
	_expect(empty_cork.to_lower().find("conflict") == -1, "empty cork board talked about a conflict: %s" % empty_cork)
	_press(root, "Ansel")
	_press(root, "Cellar")
	_press(root, "3")
	_press(root, "Submit theory")
	var cork_miss := _verdict_text(root)
	_expect_reply_names_conflicts(cork_miss, Cork, {"who": "Ansel", "place": "cellar", "hour": "3"})
	_expect(cork_miss.find("Cutter chit") >= 0, "wrong triple reply omits Cutter chit: %s" % cork_miss)
	_expect(cork_miss.find("Cellar sight") >= 0, "wrong triple reply omits Cellar sight: %s" % cork_miss)
	_expect(cork_miss.find("Mallet peg") >= 0, "wrong triple reply omits Mallet peg: %s" % cork_miss)
	_expect(cork_miss.find("Press slate") >= 0, "wrong triple reply omits Press slate: %s" % cork_miss)
	_expect(cork_miss.find("Screw card") >= 0, "wrong triple reply omits Screw card: %s" % cork_miss)
	_expect(cork_miss.find("Broom slip") >= 0, "wrong triple reply omits Broom slip: %s" % cork_miss)
	_expect(cork_miss.find("Cork leaf") >= 0, "wrong triple reply omits Cork leaf: %s" % cork_miss)
	_expect(cork_miss.find("Seal note") >= 0, "wrong triple reply omits Seal note: %s" % cork_miss)
	_expect(cork_miss.find("Lock order") >= 0, "wrong triple reply omits Lock order: %s" % cork_miss)
	_press(root, "Brea")
	_press(root, "Press")
	_press(root, "5")
	_press(root, "Submit theory")
	var cork_accepted := _verdict_text(root)
	_expect(cork_accepted.find("fits every exhibit") >= 0, "cork press board rejected the true theory: %s" % cork_accepted)
	_expect(cork_accepted.find(CORK_TIMELINE) >= 0, "cork press board timeline: %s" % cork_accepted)
	_expect(cork_accepted.find("Brea (cork hand) pressed the cork in the press at 5") >= 0, "cork press board omits Brea at 5: %s" % cork_accepted)
	_expect(cork_accepted.find("in the press") >= 0, "cork press board omits the press: %s" % cork_accepted)
	_expect(cork_accepted.find("so the cellar would take the seal") >= 0, "cork press board omits the seal: %s" % cork_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var cork_cleared := _verdict_text(root)
	_expect(cork_cleared.find("who pressed the cork") >= 0, "cleared cork board: %s" % cork_cleared)
	_expect(cork_cleared.find("fits every exhibit") == -1, "cleared cork board stayed accepted: %s" % cork_cleared)
	_press(root, "Menu")
	_press(root, "Open The tar kettle")
	var tar_from_cork := _visible_label_blob(root)
	_expect(tar_from_cork.find("Rope chit") >= 0, "could not return to The tar kettle from The cork press")
	_expect(tar_from_cork.find("Cutter chit") == -1, "cork press papers stayed up after switching files")
	_press(root, "Menu")
	_press(root, "Open The net loft")
	var net_open := _visible_label_blob(root)
	_expect(net_open.find("Mesh chit") >= 0, "net loft file did not open")
	_expect(net_open.find("Mesh note") >= 0, "net loft file did not show its exhibits")
	_expect(net_open.find("CW-21") >= 0, "net loft file omits CW-21")
	_expect(net_open.find("Complaint slip") == -1, "spare key papers showed inside The net loft")
	_expect(net_open.find("Cut list") == -1, "rehearsal papers showed inside The net loft")
	_expect(net_open.find("Move order") == -1, "gilt stamp papers showed inside The net loft")
	_expect(net_open.find("Whistle slip") == -1, "ferry bell papers showed inside The net loft")
	_expect(net_open.find("Frost note") == -1, "weather slate papers showed inside The net loft")
	_expect(net_open.find("Trough tag") == -1, "loom shuttle papers showed inside The net loft")
	_expect(net_open.find("Fuel line") == -1, "hive smoker papers showed inside The net loft")
	_expect(net_open.find("Weight line") == -1, "glass pontil papers showed inside The net loft")
	_expect(net_open.find("Lock line") == -1, "press proof papers showed inside The net loft")
	_expect(net_open.find("Cup line") == -1, "assay cup papers showed inside The net loft")
	_expect(net_open.find("Mark line") == -1, "kiln chalk papers showed inside The net loft")
	_expect(net_open.find("Ledger line") == -1, "tide ledger papers showed inside The net loft")
	_expect(net_open.find("Bell line") == -1, "night bell papers showed inside The net loft")
	_expect(net_open.find("Salt line") == -1, "salt mark papers showed inside The net loft")
	_expect(net_open.find("Oil note") == -1, "wick trim papers showed inside The net loft")
	_expect(net_open.find("Gather note") == -1, "glass anneal papers showed inside The net loft")
	_expect(net_open.find("Scion note") == -1, "orchard graft papers showed inside The net loft")
	_expect(net_open.find("Winder chit") == -1, "dye vat papers showed inside The net loft")
	_expect(net_open.find("Rope chit") == -1, "tar kettle papers showed inside The net loft")
	_expect(net_open.find("Cutter chit") == -1, "cork press papers showed inside The net loft")
	_press(root, "Submit theory")
	var empty_net := _verdict_text(root)
	_expect(empty_net.find("who mended the net") >= 0, "empty net board: %s" % empty_net)
	_expect(empty_net.find("where they mended the net") >= 0, "empty net board: %s" % empty_net)
	_expect(empty_net.find("at which hour they mended the net") >= 0, "empty net board: %s" % empty_net)
	_expect(empty_net.find("who took the spare key") == -1, "empty net board used the spare key slot: %s" % empty_net)
	_expect(empty_net.find("who pressed the cork") == -1, "empty net board used a cork slot: %s" % empty_net)
	_expect(empty_net.to_lower().find("conflict") == -1, "empty net board talked about a conflict: %s" % empty_net)
	_press(root, "Gwyn")
	_press(root, "Shed")
	_press(root, "2")
	_press(root, "Submit theory")
	var net_miss := _verdict_text(root)
	_expect_reply_names_conflicts(net_miss, Net, {"who": "Gwyn", "place": "shed", "hour": "2"})
	_expect(net_miss.find("Mesh chit") >= 0, "wrong triple reply omits Mesh chit: %s" % net_miss)
	_expect(net_miss.find("Shed sight") >= 0, "wrong triple reply omits Shed sight: %s" % net_miss)
	_expect(net_miss.find("Needle peg") >= 0, "wrong triple reply omits Needle peg: %s" % net_miss)
	_expect(net_miss.find("Loft slate") >= 0, "wrong triple reply omits Loft slate: %s" % net_miss)
	_expect(net_miss.find("Crank card") >= 0, "wrong triple reply omits Crank card: %s" % net_miss)
	_expect(net_miss.find("Shed slip") >= 0, "wrong triple reply omits Shed slip: %s" % net_miss)
	_expect(net_miss.find("Mend leaf") >= 0, "wrong triple reply omits Mend leaf: %s" % net_miss)
	_expect(net_miss.find("Mesh note") >= 0, "wrong triple reply omits Mesh note: %s" % net_miss)
	_expect(net_miss.find("Close order") >= 0, "wrong triple reply omits Close order: %s" % net_miss)
	_press(root, "Hester")
	_press(root, "Loft")
	_press(root, "4")
	_press(root, "Submit theory")
	var net_accepted := _verdict_text(root)
	_expect(net_accepted.find("fits every exhibit") >= 0, "net loft board rejected the true theory: %s" % net_accepted)
	_expect(net_accepted.find(NET_TIMELINE) >= 0, "net loft board timeline: %s" % net_accepted)
	_expect(net_accepted.find("Hester (mend hand) mended the net in the loft at 4") >= 0, "net loft board omits Hester at 4: %s" % net_accepted)
	_expect(net_accepted.find("in the loft") >= 0, "net loft board omits the loft: %s" % net_accepted)
	_expect(net_accepted.find("so the shed would take the mesh") >= 0, "net loft board omits the mesh: %s" % net_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var net_cleared := _verdict_text(root)
	_expect(net_cleared.find("who mended the net") >= 0, "cleared net board: %s" % net_cleared)
	_expect(net_cleared.find("fits every exhibit") == -1, "cleared net board stayed accepted: %s" % net_cleared)
	_press(root, "Menu")
	_press(root, "Open The cork press")
	var cork_from_net := _visible_label_blob(root)
	_expect(cork_from_net.find("Cutter chit") >= 0, "could not return to The cork press from The net loft")
	_expect(cork_from_net.find("Mesh chit") == -1, "net loft papers stayed up after switching files")
	_press(root, "Menu")
	_press(root, "Open The cask hoop")
	var cask_open := _visible_label_blob(root)
	_expect(cask_open.find("Hoop chit") >= 0, "cask hoop file did not open")
	_expect(cask_open.find("Cask note") >= 0, "cask hoop file did not show its exhibits")
	_expect(cask_open.find("CW-22") >= 0, "cask hoop file omits CW-22")
	_expect(cask_open.find("Complaint slip") == -1, "spare key papers showed inside The cask hoop")
	_expect(cask_open.find("Cut list") == -1, "rehearsal papers showed inside The cask hoop")
	_expect(cask_open.find("Move order") == -1, "gilt stamp papers showed inside The cask hoop")
	_expect(cask_open.find("Whistle slip") == -1, "ferry bell papers showed inside The cask hoop")
	_expect(cask_open.find("Frost note") == -1, "weather slate papers showed inside The cask hoop")
	_expect(cask_open.find("Trough tag") == -1, "loom shuttle papers showed inside The cask hoop")
	_expect(cask_open.find("Fuel line") == -1, "hive smoker papers showed inside The cask hoop")
	_expect(cask_open.find("Weight line") == -1, "glass pontil papers showed inside The cask hoop")
	_expect(cask_open.find("Lock line") == -1, "press proof papers showed inside The cask hoop")
	_expect(cask_open.find("Cup line") == -1, "assay cup papers showed inside The cask hoop")
	_expect(cask_open.find("Mark line") == -1, "kiln chalk papers showed inside The cask hoop")
	_expect(cask_open.find("Ledger line") == -1, "tide ledger papers showed inside The cask hoop")
	_expect(cask_open.find("Bell line") == -1, "night bell papers showed inside The cask hoop")
	_expect(cask_open.find("Salt line") == -1, "salt mark papers showed inside The cask hoop")
	_expect(cask_open.find("Oil note") == -1, "wick trim papers showed inside The cask hoop")
	_expect(cask_open.find("Gather note") == -1, "glass anneal papers showed inside The cask hoop")
	_expect(cask_open.find("Scion note") == -1, "orchard graft papers showed inside The cask hoop")
	_expect(cask_open.find("Winder chit") == -1, "dye vat papers showed inside The cask hoop")
	_expect(cask_open.find("Rope chit") == -1, "tar kettle papers showed inside The cask hoop")
	_expect(cask_open.find("Cutter chit") == -1, "cork press papers showed inside The cask hoop")
	_expect(cask_open.find("Mesh chit") == -1, "net loft papers showed inside The cask hoop")
	_press(root, "Submit theory")
	var empty_cask := _verdict_text(root)
	_expect(empty_cask.find("who drove the hoop") >= 0, "empty cask board: %s" % empty_cask)
	_expect(empty_cask.find("where they drove the hoop") >= 0, "empty cask board: %s" % empty_cask)
	_expect(empty_cask.find("at which hour they drove the hoop") >= 0, "empty cask board: %s" % empty_cask)
	_expect(empty_cask.find("who took the spare key") == -1, "empty cask board used the spare key slot: %s" % empty_cask)
	_expect(empty_cask.find("who mended the net") == -1, "empty cask board used a net slot: %s" % empty_cask)
	_expect(empty_cask.to_lower().find("conflict") == -1, "empty cask board talked about a conflict: %s" % empty_cask)
	_press(root, "Jory")
	_press(root, "Yard")
	_press(root, "1")
	_press(root, "Submit theory")
	var cask_miss := _verdict_text(root)
	_expect_reply_names_conflicts(cask_miss, Cask, {"who": "Jory", "place": "yard", "hour": "1"})
	_expect(cask_miss.find("Hoop chit") >= 0, "wrong triple reply omits Hoop chit: %s" % cask_miss)
	_expect(cask_miss.find("Yard sight") >= 0, "wrong triple reply omits Yard sight: %s" % cask_miss)
	_expect(cask_miss.find("Driver peg") >= 0, "wrong triple reply omits Driver peg: %s" % cask_miss)
	_expect(cask_miss.find("Shop slate") >= 0, "wrong triple reply omits Shop slate: %s" % cask_miss)
	_expect(cask_miss.find("Croze card") >= 0, "wrong triple reply omits Croze card: %s" % cask_miss)
	_expect(cask_miss.find("Sweep slip") >= 0, "wrong triple reply omits Sweep slip: %s" % cask_miss)
	_expect(cask_miss.find("Drive leaf") >= 0, "wrong triple reply omits Drive leaf: %s" % cask_miss)
	_expect(cask_miss.find("Cask note") >= 0, "wrong triple reply omits Cask note: %s" % cask_miss)
	_expect(cask_miss.find("Shut order") >= 0, "wrong triple reply omits Shut order: %s" % cask_miss)
	_press(root, "Maeve")
	_press(root, "Shop")
	_press(root, "3")
	_press(root, "Submit theory")
	var cask_accepted := _verdict_text(root)
	_expect(cask_accepted.find("fits every exhibit") >= 0, "cask hoop board rejected the true theory: %s" % cask_accepted)
	_expect(cask_accepted.find(CASK_TIMELINE) >= 0, "cask hoop board timeline: %s" % cask_accepted)
	_expect(cask_accepted.find("Maeve (shop hand) drove the hoop in the shop at 3") >= 0, "cask hoop board omits Maeve at 3: %s" % cask_accepted)
	_expect(cask_accepted.find("in the shop") >= 0, "cask hoop board omits the shop: %s" % cask_accepted)
	_expect(cask_accepted.find("so the yard would take the cask") >= 0, "cask hoop board omits the cask: %s" % cask_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var cask_cleared := _verdict_text(root)
	_expect(cask_cleared.find("who drove the hoop") >= 0, "cleared cask board: %s" % cask_cleared)
	_expect(cask_cleared.find("fits every exhibit") == -1, "cleared cask board stayed accepted: %s" % cask_cleared)
	_press(root, "Menu")
	_press(root, "Open The net loft")
	var net_from_cask := _visible_label_blob(root)
	_expect(net_from_cask.find("Mesh chit") >= 0, "could not return to The net loft from The cask hoop")
	_expect(net_from_cask.find("Hoop chit") == -1, "cask hoop papers stayed up after switching files")
	_press(root, "Menu")
	_press(root, "Open The linen fold")
	var linen_open := _visible_label_blob(root)
	_expect(linen_open.find("Shears chit") >= 0, "linen fold file did not open")
	_expect(linen_open.find("Sheet note") >= 0, "linen fold file did not show its exhibits")
	_expect(linen_open.find("CW-23") >= 0, "linen fold file omits CW-23")
	_expect(linen_open.find("Complaint slip") == -1, "spare key papers showed inside The linen fold")
	_expect(linen_open.find("Cut list") == -1, "rehearsal papers showed inside The linen fold")
	_expect(linen_open.find("Move order") == -1, "gilt stamp papers showed inside The linen fold")
	_expect(linen_open.find("Whistle slip") == -1, "ferry bell papers showed inside The linen fold")
	_expect(linen_open.find("Frost note") == -1, "weather slate papers showed inside The linen fold")
	_expect(linen_open.find("Trough tag") == -1, "loom shuttle papers showed inside The linen fold")
	_expect(linen_open.find("Fuel line") == -1, "hive smoker papers showed inside The linen fold")
	_expect(linen_open.find("Weight line") == -1, "glass pontil papers showed inside The linen fold")
	_expect(linen_open.find("Lock line") == -1, "press proof papers showed inside The linen fold")
	_expect(linen_open.find("Cup line") == -1, "assay cup papers showed inside The linen fold")
	_expect(linen_open.find("Mark line") == -1, "kiln chalk papers showed inside The linen fold")
	_expect(linen_open.find("Ledger line") == -1, "tide ledger papers showed inside The linen fold")
	_expect(linen_open.find("Bell line") == -1, "night bell papers showed inside The linen fold")
	_expect(linen_open.find("Salt line") == -1, "salt mark papers showed inside The linen fold")
	_expect(linen_open.find("Oil note") == -1, "wick trim papers showed inside The linen fold")
	_expect(linen_open.find("Gather note") == -1, "glass anneal papers showed inside The linen fold")
	_expect(linen_open.find("Scion note") == -1, "orchard graft papers showed inside The linen fold")
	_expect(linen_open.find("Winder chit") == -1, "dye vat papers showed inside The linen fold")
	_expect(linen_open.find("Rope chit") == -1, "tar kettle papers showed inside The linen fold")
	_expect(linen_open.find("Cutter chit") == -1, "cork press papers showed inside The linen fold")
	_expect(linen_open.find("Mesh chit") == -1, "net loft papers showed inside The linen fold")
	_expect(linen_open.find("Hoop chit") == -1, "cask hoop papers showed inside The linen fold")
	_press(root, "Submit theory")
	var empty_linen := _verdict_text(root)
	_expect(empty_linen.find("who folded the linen") >= 0, "empty linen board: %s" % empty_linen)
	_expect(empty_linen.find("where they folded the linen") >= 0, "empty linen board: %s" % empty_linen)
	_expect(empty_linen.find("at which hour they folded the linen") >= 0, "empty linen board: %s" % empty_linen)
	_expect(empty_linen.find("who took the spare key") == -1, "empty linen board used the spare key slot: %s" % empty_linen)
	_expect(empty_linen.find("who drove the hoop") == -1, "empty linen board used a cask slot: %s" % empty_linen)
	_expect(empty_linen.to_lower().find("conflict") == -1, "empty linen board talked about a conflict: %s" % empty_linen)
	_press(root, "Odell")
	_press(root, "Loft")
	_press(root, "6")
	_press(root, "Submit theory")
	var linen_miss := _verdict_text(root)
	_expect_reply_names_conflicts(linen_miss, Linen, {"who": "Odell", "place": "loft", "hour": "6"})
	_expect(linen_miss.find("Shears chit") >= 0, "wrong triple reply omits Shears chit: %s" % linen_miss)
	_expect(linen_miss.find("Loft sight") >= 0, "wrong triple reply omits Loft sight: %s" % linen_miss)
	_expect(linen_miss.find("Pin peg") >= 0, "wrong triple reply omits Pin peg: %s" % linen_miss)
	_expect(linen_miss.find("Cloth slate") >= 0, "wrong triple reply omits Cloth slate: %s" % linen_miss)
	_expect(linen_miss.find("Roller card") >= 0, "wrong triple reply omits Roller card: %s" % linen_miss)
	_expect(linen_miss.find("Dust slip") >= 0, "wrong triple reply omits Dust slip: %s" % linen_miss)
	_expect(linen_miss.find("Fold leaf") >= 0, "wrong triple reply omits Fold leaf: %s" % linen_miss)
	_expect(linen_miss.find("Sheet note") >= 0, "wrong triple reply omits Sheet note: %s" % linen_miss)
	_expect(linen_miss.find("Bar order") >= 0, "wrong triple reply omits Bar order: %s" % linen_miss)
	_press(root, "Vetch")
	_press(root, "Press")
	_press(root, "8")
	_press(root, "Submit theory")
	var linen_accepted := _verdict_text(root)
	_expect(linen_accepted.find("fits every exhibit") >= 0, "linen fold board rejected the true theory: %s" % linen_accepted)
	_expect(linen_accepted.find(LINEN_TIMELINE) >= 0, "linen fold board timeline: %s" % linen_accepted)
	_expect(linen_accepted.find("Vetch (press hand) folded the linen in the press at 8") >= 0, "linen fold board omits Vetch at 8: %s" % linen_accepted)
	_expect(linen_accepted.find("in the press") >= 0, "linen fold board omits the press: %s" % linen_accepted)
	_expect(linen_accepted.find("so the loft would take the sheet") >= 0, "linen fold board omits the sheet: %s" % linen_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var linen_cleared := _verdict_text(root)
	_expect(linen_cleared.find("who folded the linen") >= 0, "cleared linen board: %s" % linen_cleared)
	_expect(linen_cleared.find("fits every exhibit") == -1, "cleared linen board stayed accepted: %s" % linen_cleared)
	_press(root, "Menu")
	_press(root, "Open The cask hoop")
	var cask_from_linen := _visible_label_blob(root)
	_expect(cask_from_linen.find("Hoop chit") >= 0, "could not return to The cask hoop from The linen fold")
	_expect(cask_from_linen.find("Shears chit") == -1, "linen fold papers stayed up after switching files")

	_press(root, "Menu")
	_press(root, "Open The dovetail")
	var dovetail_open := _visible_label_blob(root)
	_expect(dovetail_open.find("Saw chit") >= 0, "dovetail file did not open")
	_expect(dovetail_open.find("Joint note") >= 0, "dovetail file did not show its exhibits")
	_expect(dovetail_open.find("CW-24") >= 0, "dovetail file omits CW-24")
	_expect(dovetail_open.find("Complaint slip") == -1, "spare key papers showed inside The dovetail")
	_expect(dovetail_open.find("Cut list") == -1, "rehearsal papers showed inside The dovetail")
	_expect(dovetail_open.find("Move order") == -1, "gilt stamp papers showed inside The dovetail")
	_expect(dovetail_open.find("Whistle slip") == -1, "ferry bell papers showed inside The dovetail")
	_expect(dovetail_open.find("Frost note") == -1, "weather slate papers showed inside The dovetail")
	_expect(dovetail_open.find("Trough tag") == -1, "loom shuttle papers showed inside The dovetail")
	_expect(dovetail_open.find("Fuel line") == -1, "hive smoker papers showed inside The dovetail")
	_expect(dovetail_open.find("Weight line") == -1, "glass pontil papers showed inside The dovetail")
	_expect(dovetail_open.find("Lock line") == -1, "press proof papers showed inside The dovetail")
	_expect(dovetail_open.find("Cup line") == -1, "assay cup papers showed inside The dovetail")
	_expect(dovetail_open.find("Mark line") == -1, "kiln chalk papers showed inside The dovetail")
	_expect(dovetail_open.find("Ledger line") == -1, "tide ledger papers showed inside The dovetail")
	_expect(dovetail_open.find("Bell line") == -1, "night bell papers showed inside The dovetail")
	_expect(dovetail_open.find("Salt line") == -1, "salt mark papers showed inside The dovetail")
	_expect(dovetail_open.find("Oil note") == -1, "wick trim papers showed inside The dovetail")
	_expect(dovetail_open.find("Gather note") == -1, "glass anneal papers showed inside The dovetail")
	_expect(dovetail_open.find("Scion note") == -1, "orchard graft papers showed inside The dovetail")
	_expect(dovetail_open.find("Winder chit") == -1, "dye vat papers showed inside The dovetail")
	_expect(dovetail_open.find("Rope chit") == -1, "tar kettle papers showed inside The dovetail")
	_expect(dovetail_open.find("Cutter chit") == -1, "cork press papers showed inside The dovetail")
	_expect(dovetail_open.find("Mesh chit") == -1, "net loft papers showed inside The dovetail")
	_expect(dovetail_open.find("Hoop chit") == -1, "cask hoop papers showed inside The dovetail")
	_expect(dovetail_open.find("Shears chit") == -1, "linen fold papers showed inside The dovetail")
	_press(root, "Submit theory")
	var empty_dovetail := _verdict_text(root)
	_expect(empty_dovetail.find("who cut the dovetail") >= 0, "empty dovetail board: %s" % empty_dovetail)
	_expect(empty_dovetail.find("where they cut the dovetail") >= 0, "empty dovetail board: %s" % empty_dovetail)
	_expect(empty_dovetail.find("at which hour they cut the dovetail") >= 0, "empty dovetail board: %s" % empty_dovetail)
	_expect(empty_dovetail.find("who took the spare key") == -1, "empty dovetail board used the spare key slot: %s" % empty_dovetail)
	_expect(empty_dovetail.find("who folded the linen") == -1, "empty dovetail board used a linen slot: %s" % empty_dovetail)
	_expect(empty_dovetail.to_lower().find("conflict") == -1, "empty dovetail board talked about a conflict: %s" % empty_dovetail)
	_press(root, "Yarrow")
	_press(root, "Apron")
	_press(root, "61")
	_press(root, "Submit theory")
	var dovetail_miss := _verdict_text(root)
	_expect_reply_names_conflicts(dovetail_miss, Dovetail, {"who": "Yarrow", "place": "apron", "hour": "61"})
	_expect(dovetail_miss.find("Saw chit") >= 0, "wrong triple reply omits Saw chit: %s" % dovetail_miss)
	_expect(dovetail_miss.find("Apron sight") >= 0, "wrong triple reply omits Apron sight: %s" % dovetail_miss)
	_expect(dovetail_miss.find("Peg hook") >= 0, "wrong triple reply omits Peg hook: %s" % dovetail_miss)
	_expect(dovetail_miss.find("Joint slate") >= 0, "wrong triple reply omits Joint slate: %s" % dovetail_miss)
	_expect(dovetail_miss.find("Clamp card") >= 0, "wrong triple reply omits Clamp card: %s" % dovetail_miss)
	_expect(dovetail_miss.find("Sweep slip") >= 0, "wrong triple reply omits Sweep slip: %s" % dovetail_miss)
	_expect(dovetail_miss.find("Cut leaf") >= 0, "wrong triple reply omits Cut leaf: %s" % dovetail_miss)
	_expect(dovetail_miss.find("Joint note") >= 0, "wrong triple reply omits Joint note: %s" % dovetail_miss)
	_expect(dovetail_miss.find("Jaw order") >= 0, "wrong triple reply omits Jaw order: %s" % dovetail_miss)
	_press(root, "Doss")
	_press(root, "Vise")
	_press(root, "63")
	_press(root, "Submit theory")
	var dovetail_accepted := _verdict_text(root)
	_expect(dovetail_accepted.find("fits every exhibit") >= 0, "dovetail board rejected the true theory: %s" % dovetail_accepted)
	_expect(dovetail_accepted.find(DOVETAIL_TIMELINE) >= 0, "dovetail board timeline: %s" % dovetail_accepted)
	_expect(dovetail_accepted.find("Doss (saw hand) cut the dovetail in the vise at 63") >= 0, "dovetail board omits Doss at 63: %s" % dovetail_accepted)
	_expect(dovetail_accepted.find("in the vise") >= 0, "dovetail board omits the vise: %s" % dovetail_accepted)
	_expect(dovetail_accepted.find("so the stile would take the joint") >= 0, "dovetail board omits the joint: %s" % dovetail_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var dovetail_cleared := _verdict_text(root)
	_expect(dovetail_cleared.find("who cut the dovetail") >= 0, "cleared dovetail board: %s" % dovetail_cleared)
	_expect(dovetail_cleared.find("fits every exhibit") == -1, "cleared dovetail board stayed accepted: %s" % dovetail_cleared)
	_press(root, "Menu")
	_press(root, "Open The linen fold")
	var linen_from_dovetail := _visible_label_blob(root)
	_expect(linen_from_dovetail.find("Shears chit") >= 0, "could not return to The linen fold from The dovetail")
	_expect(linen_from_dovetail.find("Sheet note") >= 0, "linen fold exhibits did not return")
	_expect(linen_from_dovetail.find("CW-23") >= 0, "returned linen fold omits CW-23")
	_expect(linen_from_dovetail.find("Saw chit") == -1, "dovetail papers stayed up inside The linen fold")
	_expect(linen_from_dovetail.find("Apron sight") == -1, "dovetail papers showed inside The linen fold")
	_expect(linen_from_dovetail.find("Peg hook") == -1, "dovetail papers showed inside The linen fold")
	_expect(linen_from_dovetail.find("Joint slate") == -1, "dovetail papers showed inside The linen fold")
	_expect(linen_from_dovetail.find("Clamp card") == -1, "dovetail papers showed inside The linen fold")
	_expect(linen_from_dovetail.find("Cut leaf") == -1, "dovetail papers showed inside The linen fold")
	_expect(linen_from_dovetail.find("Joint note") == -1, "dovetail papers showed inside The linen fold")
	_expect(linen_from_dovetail.find("Jaw order") == -1, "dovetail papers showed inside The linen fold")
	_expect(linen_from_dovetail.find("CW-24") == -1, "dovetail file code stayed up inside The linen fold")
	_press(root, "Vetch")
	_press(root, "Press")
	_press(root, "8")
	_press(root, "Submit theory")
	var linen_again := _verdict_text(root)
	_expect(linen_again.find("fits every exhibit") >= 0, "linen fold board rejected the true theory after The dovetail: %s" % linen_again)
	_expect(linen_again.find("Vetch (press hand) folded the linen in the press at 8") >= 0, "linen fold board timeline after The dovetail: %s" % linen_again)
	var linen_again_blob := _visible_label_blob(root)
	_expect(linen_again_blob.find("Shears chit") >= 0, "linen papers left after returning")
	_expect(linen_again_blob.find("Saw chit") == -1, "dovetail papers stayed up after returning to The linen fold")


	_press(root, "Menu")
	_press(root, "Open The mortise")
	var mortise_open := _visible_label_blob(root)
	_expect(mortise_open.find("Chisel chit") >= 0, "mortise file did not open")
	_expect(mortise_open.find("Tenon note") >= 0, "mortise file did not show its exhibits")
	_expect(mortise_open.find("CW-25") >= 0, "mortise file omits CW-25")
	_expect(mortise_open.find("Complaint slip") == -1, "spare key papers showed inside The mortise")
	_expect(mortise_open.find("Cut list") == -1, "rehearsal papers showed inside The mortise")
	_expect(mortise_open.find("Move order") == -1, "gilt stamp papers showed inside The mortise")
	_expect(mortise_open.find("Whistle slip") == -1, "ferry bell papers showed inside The mortise")
	_expect(mortise_open.find("Frost note") == -1, "weather slate papers showed inside The mortise")
	_expect(mortise_open.find("Trough tag") == -1, "loom shuttle papers showed inside The mortise")
	_expect(mortise_open.find("Fuel line") == -1, "hive smoker papers showed inside The mortise")
	_expect(mortise_open.find("Weight line") == -1, "glass pontil papers showed inside The mortise")
	_expect(mortise_open.find("Lock line") == -1, "press proof papers showed inside The mortise")
	_expect(mortise_open.find("Cup line") == -1, "assay cup papers showed inside The mortise")
	_expect(mortise_open.find("Mark line") == -1, "kiln chalk papers showed inside The mortise")
	_expect(mortise_open.find("Ledger line") == -1, "tide ledger papers showed inside The mortise")
	_expect(mortise_open.find("Bell line") == -1, "night bell papers showed inside The mortise")
	_expect(mortise_open.find("Salt line") == -1, "salt mark papers showed inside The mortise")
	_expect(mortise_open.find("Oil note") == -1, "wick trim papers showed inside The mortise")
	_expect(mortise_open.find("Gather note") == -1, "glass anneal papers showed inside The mortise")
	_expect(mortise_open.find("Scion note") == -1, "orchard graft papers showed inside The mortise")
	_expect(mortise_open.find("Winder chit") == -1, "dye vat papers showed inside The mortise")
	_expect(mortise_open.find("Rope chit") == -1, "tar kettle papers showed inside The mortise")
	_expect(mortise_open.find("Cutter chit") == -1, "cork press papers showed inside The mortise")
	_expect(mortise_open.find("Mesh chit") == -1, "net loft papers showed inside The mortise")
	_expect(mortise_open.find("Hoop chit") == -1, "cask hoop papers showed inside The mortise")
	_expect(mortise_open.find("Shears chit") == -1, "linen fold papers showed inside The mortise")
	_expect(mortise_open.find("Saw chit") == -1, "dovetail papers stayed up inside The mortise")
	_expect(mortise_open.find("Apron sight") == -1, "dovetail papers showed inside The mortise")
	_expect(mortise_open.find("Peg hook") == -1, "dovetail papers showed inside The mortise")
	_expect(mortise_open.find("Joint slate") == -1, "dovetail papers showed inside The mortise")
	_expect(mortise_open.find("Clamp card") == -1, "dovetail papers showed inside The mortise")
	_expect(mortise_open.find("Sweep slip") == -1, "dovetail papers showed inside The mortise")
	_expect(mortise_open.find("Cut leaf") == -1, "dovetail papers showed inside The mortise")
	_expect(mortise_open.find("Joint note") == -1, "dovetail papers showed inside The mortise")
	_expect(mortise_open.find("Jaw order") == -1, "dovetail papers showed inside The mortise")
	_expect(mortise_open.find("CW-24") == -1, "dovetail file code stayed up inside The mortise")
	_press(root, "Submit theory")
	var empty_mortise := _verdict_text(root)
	_expect(empty_mortise.find("who cut the mortise") >= 0, "empty mortise board: %s" % empty_mortise)
	_expect(empty_mortise.find("where they cut the mortise") >= 0, "empty mortise board: %s" % empty_mortise)
	_expect(empty_mortise.find("at which hour they cut the mortise") >= 0, "empty mortise board: %s" % empty_mortise)
	_expect(empty_mortise.find("who took the spare key") == -1, "empty mortise board used the spare key slot: %s" % empty_mortise)
	_expect(empty_mortise.find("who cut the dovetail") == -1, "empty mortise board used a dovetail slot: %s" % empty_mortise)
	_expect(empty_mortise.to_lower().find("conflict") == -1, "empty mortise board talked about a conflict: %s" % empty_mortise)
	_press(root, "Keel")
	_press(root, "Awl")
	_press(root, "66")
	_press(root, "Submit theory")
	var mortise_miss := _verdict_text(root)
	_expect_reply_names_conflicts(mortise_miss, Mortise, {"who": "Keel", "place": "awl", "hour": "66"})
	_expect(mortise_miss.find("Chisel chit") >= 0, "wrong triple reply omits Chisel chit: %s" % mortise_miss)
	_expect(mortise_miss.find("Awl sight") >= 0, "wrong triple reply omits Awl sight: %s" % mortise_miss)
	_expect(mortise_miss.find("Wedge hook") >= 0, "wrong triple reply omits Wedge hook: %s" % mortise_miss)
	_expect(mortise_miss.find("Tenon slate") >= 0, "wrong triple reply omits Tenon slate: %s" % mortise_miss)
	_expect(mortise_miss.find("Brace card") >= 0, "wrong triple reply omits Brace card: %s" % mortise_miss)
	_expect(mortise_miss.find("Brush slip") >= 0, "wrong triple reply omits Brush slip: %s" % mortise_miss)
	_expect(mortise_miss.find("Bore leaf") >= 0, "wrong triple reply omits Bore leaf: %s" % mortise_miss)
	_expect(mortise_miss.find("Tenon note") >= 0, "wrong triple reply omits Tenon note: %s" % mortise_miss)
	_expect(mortise_miss.find("Rack order") >= 0, "wrong triple reply omits Rack order: %s" % mortise_miss)
	_press(root, "Arlo")
	_press(root, "Chisel")
	_press(root, "68")
	_press(root, "Submit theory")
	var mortise_accepted := _verdict_text(root)
	_expect(mortise_accepted.find("fits every exhibit") >= 0, "mortise board rejected the true theory: %s" % mortise_accepted)
	_expect(mortise_accepted.find(MORTISE_TIMELINE) >= 0, "mortise board timeline: %s" % mortise_accepted)
	_expect(mortise_accepted.find("Arlo (chisel hand) cut the mortise in the chisel at 68") >= 0, "mortise board omits Arlo at 68: %s" % mortise_accepted)
	_expect(mortise_accepted.find("in the chisel") >= 0, "mortise board omits the chisel: %s" % mortise_accepted)
	_expect(mortise_accepted.find("so the last would take the tenon") >= 0, "mortise board omits the tenon: %s" % mortise_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var mortise_cleared := _verdict_text(root)
	_expect(mortise_cleared.find("who cut the mortise") >= 0, "cleared mortise board: %s" % mortise_cleared)
	_expect(mortise_cleared.find("fits every exhibit") == -1, "cleared mortise board stayed accepted: %s" % mortise_cleared)
	_press(root, "Menu")
	_press(root, "Open The dovetail")
	var dovetail_from_mortise := _visible_label_blob(root)
	_expect(dovetail_from_mortise.find("Saw chit") >= 0, "could not return to The dovetail from The mortise")
	_expect(dovetail_from_mortise.find("Joint note") >= 0, "dovetail exhibits did not return")
	_expect(dovetail_from_mortise.find("CW-24") >= 0, "returned dovetail omits CW-24")
	_expect(dovetail_from_mortise.find("Chisel chit") == -1, "mortise papers stayed up inside The dovetail")
	_expect(dovetail_from_mortise.find("Awl sight") == -1, "mortise papers showed inside The dovetail")
	_expect(dovetail_from_mortise.find("Wedge hook") == -1, "mortise papers showed inside The dovetail")
	_expect(dovetail_from_mortise.find("Tenon slate") == -1, "mortise papers showed inside The dovetail")
	_expect(dovetail_from_mortise.find("Brace card") == -1, "mortise papers showed inside The dovetail")
	_expect(dovetail_from_mortise.find("Brush slip") == -1, "mortise papers showed inside The dovetail")
	_expect(dovetail_from_mortise.find("Bore leaf") == -1, "mortise papers showed inside The dovetail")
	_expect(dovetail_from_mortise.find("Tenon note") == -1, "mortise papers showed inside The dovetail")
	_expect(dovetail_from_mortise.find("Rack order") == -1, "mortise papers showed inside The dovetail")
	_expect(dovetail_from_mortise.find("CW-25") == -1, "mortise file code stayed up inside The dovetail")
	_press(root, "Doss")
	_press(root, "Vise")
	_press(root, "63")
	_press(root, "Submit theory")
	var dovetail_again := _verdict_text(root)
	_expect(dovetail_again.find("fits every exhibit") >= 0, "dovetail board rejected the true theory after The mortise: %s" % dovetail_again)
	_expect(dovetail_again.find("Doss (saw hand) cut the dovetail in the vise at 63") >= 0, "dovetail board timeline after The mortise: %s" % dovetail_again)
	var dovetail_again_blob := _visible_label_blob(root)
	_expect(dovetail_again_blob.find("Saw chit") >= 0, "dovetail papers left after returning")
	_expect(dovetail_again_blob.find("Chisel chit") == -1, "mortise papers stayed up after returning to The dovetail")

	_press(root, "Menu")
	_press(root, "Open The rebate")
	var rebate_open := _visible_label_blob(root)
	_expect(rebate_open.find("Plane chit") >= 0, "rebate file did not open")
	_expect(rebate_open.find("Shoulder note") >= 0, "rebate file did not show its exhibits")
	_expect(rebate_open.find("CW-26") >= 0, "rebate file omits CW-26")
	_expect(rebate_open.find("Complaint slip") == -1, "spare key papers showed inside The rebate")
	_expect(rebate_open.find("Cut list") == -1, "rehearsal papers showed inside The rebate")
	_expect(rebate_open.find("Move order") == -1, "gilt stamp papers showed inside The rebate")
	_expect(rebate_open.find("Whistle slip") == -1, "ferry bell papers showed inside The rebate")
	_expect(rebate_open.find("Frost note") == -1, "weather slate papers showed inside The rebate")
	_expect(rebate_open.find("Trough tag") == -1, "loom shuttle papers showed inside The rebate")
	_expect(rebate_open.find("Fuel line") == -1, "hive smoker papers showed inside The rebate")
	_expect(rebate_open.find("Weight line") == -1, "glass pontil papers showed inside The rebate")
	_expect(rebate_open.find("Lock line") == -1, "press proof papers showed inside The rebate")
	_expect(rebate_open.find("Cup line") == -1, "assay cup papers showed inside The rebate")
	_expect(rebate_open.find("Mark line") == -1, "kiln chalk papers showed inside The rebate")
	_expect(rebate_open.find("Ledger line") == -1, "tide ledger papers showed inside The rebate")
	_expect(rebate_open.find("Bell line") == -1, "night bell papers showed inside The rebate")
	_expect(rebate_open.find("Salt line") == -1, "salt mark papers showed inside The rebate")
	_expect(rebate_open.find("Oil note") == -1, "wick trim papers showed inside The rebate")
	_expect(rebate_open.find("Gather note") == -1, "glass anneal papers showed inside The rebate")
	_expect(rebate_open.find("Scion note") == -1, "orchard graft papers showed inside The rebate")
	_expect(rebate_open.find("Winder chit") == -1, "dye vat papers showed inside The rebate")
	_expect(rebate_open.find("Rope chit") == -1, "tar kettle papers showed inside The rebate")
	_expect(rebate_open.find("Cutter chit") == -1, "cork press papers showed inside The rebate")
	_expect(rebate_open.find("Mesh chit") == -1, "net loft papers showed inside The rebate")
	_expect(rebate_open.find("Hoop chit") == -1, "cask hoop papers showed inside The rebate")
	_expect(rebate_open.find("Shears chit") == -1, "linen fold papers showed inside The rebate")
	_expect(rebate_open.find("Saw chit") == -1, "dovetail papers stayed up inside The rebate")
	_expect(rebate_open.find("Apron sight") == -1, "dovetail papers showed inside The rebate")
	_expect(rebate_open.find("Peg hook") == -1, "dovetail papers showed inside The rebate")
	_expect(rebate_open.find("Joint slate") == -1, "dovetail papers showed inside The rebate")
	_expect(rebate_open.find("Clamp card") == -1, "dovetail papers showed inside The rebate")
	_expect(rebate_open.find("Sweep slip") == -1, "dovetail papers showed inside The rebate")
	_expect(rebate_open.find("Cut leaf") == -1, "dovetail papers showed inside The rebate")
	_expect(rebate_open.find("Joint note") == -1, "dovetail papers showed inside The rebate")
	_expect(rebate_open.find("Jaw order") == -1, "dovetail papers showed inside The rebate")
	_expect(rebate_open.find("CW-24") == -1, "dovetail file code stayed up inside The rebate")
	_expect(rebate_open.find("Chisel chit") == -1, "mortise papers stayed up inside The rebate")
	_expect(rebate_open.find("Awl sight") == -1, "mortise papers showed inside The rebate")
	_expect(rebate_open.find("Wedge hook") == -1, "mortise papers showed inside The rebate")
	_expect(rebate_open.find("Tenon slate") == -1, "mortise papers showed inside The rebate")
	_expect(rebate_open.find("Brace card") == -1, "mortise papers showed inside The rebate")
	_expect(rebate_open.find("Brush slip") == -1, "mortise papers showed inside The rebate")
	_expect(rebate_open.find("Bore leaf") == -1, "mortise papers showed inside The rebate")
	_expect(rebate_open.find("Tenon note") == -1, "mortise papers showed inside The rebate")
	_expect(rebate_open.find("Rack order") == -1, "mortise papers showed inside The rebate")
	_expect(rebate_open.find("CW-25") == -1, "mortise file code stayed up inside The rebate")
	_press(root, "Submit theory")
	var empty_rebate := _verdict_text(root)
	_expect(empty_rebate.find("who cut the rebate") >= 0, "empty rebate board: %s" % empty_rebate)
	_expect(empty_rebate.find("where they cut the rebate") >= 0, "empty rebate board: %s" % empty_rebate)
	_expect(empty_rebate.find("at which hour they cut the rebate") >= 0, "empty rebate board: %s" % empty_rebate)
	_expect(empty_rebate.find("who took the spare key") == -1, "empty rebate board used the spare key slot: %s" % empty_rebate)
	_expect(empty_rebate.find("who cut the mortise") == -1, "empty rebate board used a mortise slot: %s" % empty_rebate)
	_expect(empty_rebate.to_lower().find("conflict") == -1, "empty rebate board talked about a conflict: %s" % empty_rebate)
	_press(root, "Solt")
	_press(root, "Gauge")
	_press(root, "71")
	_press(root, "Submit theory")
	var rebate_miss := _verdict_text(root)
	_expect_reply_names_conflicts(rebate_miss, Rebate, {"who": "Solt", "place": "gauge", "hour": "71"})
	_expect(rebate_miss.find("Plane chit") >= 0, "wrong triple reply omits Plane chit: %s" % rebate_miss)
	_expect(rebate_miss.find("Gauge sight") >= 0, "wrong triple reply omits Gauge sight: %s" % rebate_miss)
	_expect(rebate_miss.find("Shim hook") >= 0, "wrong triple reply omits Shim hook: %s" % rebate_miss)
	_expect(rebate_miss.find("Shoulder slate") >= 0, "wrong triple reply omits Shoulder slate: %s" % rebate_miss)
	_expect(rebate_miss.find("Fence card") >= 0, "wrong triple reply omits Fence card: %s" % rebate_miss)
	_expect(rebate_miss.find("Oil slip") >= 0, "wrong triple reply omits Oil slip: %s" % rebate_miss)
	_expect(rebate_miss.find("Scribe leaf") >= 0, "wrong triple reply omits Scribe leaf: %s" % rebate_miss)
	_expect(rebate_miss.find("Shoulder note") >= 0, "wrong triple reply omits Shoulder note: %s" % rebate_miss)
	_expect(rebate_miss.find("Hang order") >= 0, "wrong triple reply omits Hang order: %s" % rebate_miss)
	_press(root, "Tansy")
	_press(root, "Plane")
	_press(root, "73")
	_press(root, "Submit theory")
	var rebate_accepted := _verdict_text(root)
	_expect(rebate_accepted.find("fits every exhibit") >= 0, "rebate board rejected the true theory: %s" % rebate_accepted)
	_expect(rebate_accepted.find(REBATE_TIMELINE) >= 0, "rebate board timeline: %s" % rebate_accepted)
	_expect(rebate_accepted.find("Tansy (plane hand) cut the rebate in the plane at 73") >= 0, "rebate board omits Tansy at 73: %s" % rebate_accepted)
	_expect(rebate_accepted.find("in the plane") >= 0, "rebate board omits the plane: %s" % rebate_accepted)
	_expect(rebate_accepted.find("so the mallet would take the shoulder") >= 0, "rebate board omits the shoulder: %s" % rebate_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var rebate_cleared := _verdict_text(root)
	_expect(rebate_cleared.find("who cut the rebate") >= 0, "cleared rebate board: %s" % rebate_cleared)
	_expect(rebate_cleared.find("fits every exhibit") == -1, "cleared rebate board stayed accepted: %s" % rebate_cleared)
	_press(root, "Menu")
	_press(root, "Open The mortise")
	var mortise_from_rebate := _visible_label_blob(root)
	_expect(mortise_from_rebate.find("Chisel chit") >= 0, "could not return to The mortise from The rebate")
	_expect(mortise_from_rebate.find("Tenon note") >= 0, "mortise exhibits did not return")
	_expect(mortise_from_rebate.find("CW-25") >= 0, "returned mortise omits CW-25")
	_expect(mortise_from_rebate.find("Plane chit") == -1, "rebate papers stayed up inside The mortise")
	_expect(mortise_from_rebate.find("Gauge sight") == -1, "rebate papers showed inside The mortise")
	_expect(mortise_from_rebate.find("Shim hook") == -1, "rebate papers showed inside The mortise")
	_expect(mortise_from_rebate.find("Shoulder slate") == -1, "rebate papers showed inside The mortise")
	_expect(mortise_from_rebate.find("Fence card") == -1, "rebate papers showed inside The mortise")
	_expect(mortise_from_rebate.find("Oil slip") == -1, "rebate papers showed inside The mortise")
	_expect(mortise_from_rebate.find("Scribe leaf") == -1, "rebate papers showed inside The mortise")
	_expect(mortise_from_rebate.find("Shoulder note") == -1, "rebate papers showed inside The mortise")
	_expect(mortise_from_rebate.find("Hang order") == -1, "rebate papers showed inside The mortise")
	_expect(mortise_from_rebate.find("CW-26") == -1, "rebate file code stayed up inside The mortise")
	_press(root, "Arlo")
	_press(root, "Chisel")
	_press(root, "68")
	_press(root, "Submit theory")
	var mortise_again := _verdict_text(root)
	_expect(mortise_again.find("fits every exhibit") >= 0, "mortise board rejected the true theory after The rebate: %s" % mortise_again)
	_expect(mortise_again.find("Arlo (chisel hand) cut the mortise in the chisel at 68") >= 0, "mortise board timeline after The rebate: %s" % mortise_again)
	var mortise_again_blob := _visible_label_blob(root)
	_expect(mortise_again_blob.find("Chisel chit") >= 0, "mortise papers left after returning")
	_expect(mortise_again_blob.find("Plane chit") == -1, "rebate papers stayed up after returning to The mortise")

	_press(root, "Menu")
	_press(root, "Open The housing")
	var housing_open := _visible_label_blob(root)
	_expect(housing_open.find("Saw chit") >= 0, "housing file did not open")
	_expect(housing_open.find("Trench note") >= 0, "housing file did not show its exhibits")
	_expect(housing_open.find("CW-27") >= 0, "housing file omits CW-27")
	_expect(housing_open.find("Fillet hook") >= 0, "housing file omits Fillet hook")
	_expect(housing_open.find("Chalk slip") >= 0, "housing file omits Chalk slip")
	_expect(housing_open.find("Mark leaf") >= 0, "housing file omits Mark leaf")
	_expect(housing_open.find("Hang order") >= 0, "housing file omits Hang order")
	_expect(housing_open.find("Complaint slip") == -1, "spare key papers showed inside The housing")
	_expect(housing_open.find("Cut list") == -1, "rehearsal papers showed inside The housing")
	_expect(housing_open.find("Move order") == -1, "gilt stamp papers showed inside The housing")
	_expect(housing_open.find("Whistle slip") == -1, "ferry bell papers showed inside The housing")
	_expect(housing_open.find("Frost note") == -1, "weather slate papers showed inside The housing")
	_expect(housing_open.find("Trough tag") == -1, "loom shuttle papers showed inside The housing")
	_expect(housing_open.find("Fuel line") == -1, "hive smoker papers showed inside The housing")
	_expect(housing_open.find("Weight line") == -1, "glass pontil papers showed inside The housing")
	_expect(housing_open.find("Lock line") == -1, "press proof papers showed inside The housing")
	_expect(housing_open.find("Cup line") == -1, "assay cup papers showed inside The housing")
	_expect(housing_open.find("Mark line") == -1, "kiln chalk papers showed inside The housing")
	_expect(housing_open.find("Ledger line") == -1, "tide ledger papers showed inside The housing")
	_expect(housing_open.find("Bell line") == -1, "night bell papers showed inside The housing")
	_expect(housing_open.find("Salt line") == -1, "salt mark papers showed inside The housing")
	_expect(housing_open.find("Oil note") == -1, "wick trim papers showed inside The housing")
	_expect(housing_open.find("Gather note") == -1, "glass anneal papers showed inside The housing")
	_expect(housing_open.find("Scion note") == -1, "orchard graft papers showed inside The housing")
	_expect(housing_open.find("Winder chit") == -1, "dye vat papers showed inside The housing")
	_expect(housing_open.find("Rope chit") == -1, "tar kettle papers showed inside The housing")
	_expect(housing_open.find("Cutter chit") == -1, "cork press papers showed inside The housing")
	_expect(housing_open.find("Mesh chit") == -1, "net loft papers showed inside The housing")
	_expect(housing_open.find("Hoop chit") == -1, "cask hoop papers showed inside The housing")
	_expect(housing_open.find("Shears chit") == -1, "linen fold papers showed inside The housing")
	_expect(housing_open.find("Apron sight") == -1, "dovetail papers showed inside The housing")
	_expect(housing_open.find("Peg hook") == -1, "dovetail papers showed inside The housing")
	_expect(housing_open.find("Joint slate") == -1, "dovetail papers showed inside The housing")
	_expect(housing_open.find("Clamp card") == -1, "dovetail papers showed inside The housing")
	_expect(housing_open.find("Sweep slip") == -1, "dovetail papers showed inside The housing")
	_expect(housing_open.find("Cut leaf") == -1, "dovetail papers showed inside The housing")
	_expect(housing_open.find("Joint note") == -1, "dovetail papers showed inside The housing")
	_expect(housing_open.find("Jaw order") == -1, "dovetail papers showed inside The housing")
	_expect(housing_open.find("CW-24") == -1, "dovetail file code stayed up inside The housing")
	_expect(housing_open.find("Chisel chit") == -1, "mortise papers stayed up inside The housing")
	_expect(housing_open.find("Awl sight") == -1, "mortise papers showed inside The housing")
	_expect(housing_open.find("Wedge hook") == -1, "mortise papers showed inside The housing")
	_expect(housing_open.find("Tenon slate") == -1, "mortise papers showed inside The housing")
	_expect(housing_open.find("Brace card") == -1, "mortise papers showed inside The housing")
	_expect(housing_open.find("Brush slip") == -1, "mortise papers showed inside The housing")
	_expect(housing_open.find("Bore leaf") == -1, "mortise papers showed inside The housing")
	_expect(housing_open.find("Tenon note") == -1, "mortise papers showed inside The housing")
	_expect(housing_open.find("Rack order") == -1, "mortise papers showed inside The housing")
	_expect(housing_open.find("CW-25") == -1, "mortise file code stayed up inside The housing")
	_expect(housing_open.find("Plane chit") == -1, "rebate papers stayed up inside The housing")
	_expect(housing_open.find("Gauge sight") == -1, "rebate papers showed inside The housing")
	_expect(housing_open.find("Shim hook") == -1, "rebate papers showed inside The housing")
	_expect(housing_open.find("Shoulder slate") == -1, "rebate papers showed inside The housing")
	_expect(housing_open.find("Fence card") == -1, "rebate papers showed inside The housing")
	_expect(housing_open.find("Oil slip") == -1, "rebate papers showed inside The housing")
	_expect(housing_open.find("Scribe leaf") == -1, "rebate papers showed inside The housing")
	_expect(housing_open.find("Shoulder note") == -1, "rebate papers showed inside The housing")
	_expect(housing_open.find("CW-26") == -1, "rebate file code stayed up inside The housing")
	_press(root, "Submit theory")
	var empty_housing := _verdict_text(root)
	_expect(empty_housing.find("who cut the housing") >= 0, "empty housing board: %s" % empty_housing)
	_expect(empty_housing.find("where they cut the housing") >= 0, "empty housing board: %s" % empty_housing)
	_expect(empty_housing.find("at which hour they cut the housing") >= 0, "empty housing board: %s" % empty_housing)
	_expect(empty_housing.find("who took the spare key") == -1, "empty housing board used the spare key slot: %s" % empty_housing)
	_expect(empty_housing.find("who cut the rebate") == -1, "empty housing board used a rebate slot: %s" % empty_housing)
	_expect(empty_housing.to_lower().find("conflict") == -1, "empty housing board talked about a conflict: %s" % empty_housing)
	_press(root, "Maren")
	_press(root, "Square")
	_press(root, "76")
	_press(root, "Submit theory")
	var housing_miss := _verdict_text(root)
	_expect_reply_names_conflicts(housing_miss, Housing, {"who": "Maren", "place": "square", "hour": "76"})
	_expect(housing_miss.find("Saw chit") >= 0, "wrong triple reply omits Saw chit: %s" % housing_miss)
	_expect(housing_miss.find("Square sight") >= 0, "wrong triple reply omits Square sight: %s" % housing_miss)
	_expect(housing_miss.find("Fillet hook") >= 0, "wrong triple reply omits Fillet hook: %s" % housing_miss)
	_expect(housing_miss.find("Trench slate") >= 0, "wrong triple reply omits Trench slate: %s" % housing_miss)
	_expect(housing_miss.find("Stock card") >= 0, "wrong triple reply omits Stock card: %s" % housing_miss)
	_expect(housing_miss.find("Chalk slip") >= 0, "wrong triple reply omits Chalk slip: %s" % housing_miss)
	_expect(housing_miss.find("Mark leaf") >= 0, "wrong triple reply omits Mark leaf: %s" % housing_miss)
	_expect(housing_miss.find("Trench note") >= 0, "wrong triple reply omits Trench note: %s" % housing_miss)
	_expect(housing_miss.find("Hang order") >= 0, "wrong triple reply omits Hang order: %s" % housing_miss)
	_press(root, "Ewan")
	_press(root, "Saw")
	_press(root, "78")
	_press(root, "Submit theory")
	var housing_accepted := _verdict_text(root)
	_expect(housing_accepted.find("fits every exhibit") >= 0, "housing board rejected the true theory: %s" % housing_accepted)
	_expect(housing_accepted.find(HOUSING_TIMELINE) >= 0, "housing board timeline: %s" % housing_accepted)
	_expect(housing_accepted.find("Ewan (saw hand) cut the housing in the saw at 78") >= 0, "housing board omits Ewan at 78: %s" % housing_accepted)
	_expect(housing_accepted.find("in the saw") >= 0, "housing board omits the saw: %s" % housing_accepted)
	_expect(housing_accepted.find("so the bead would take the trench") >= 0, "housing board omits the trench: %s" % housing_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var housing_cleared := _verdict_text(root)
	_expect(housing_cleared.find("who cut the housing") >= 0, "cleared housing board: %s" % housing_cleared)
	_expect(housing_cleared.find("fits every exhibit") == -1, "cleared housing board stayed accepted: %s" % housing_cleared)
	_press(root, "Menu")
	_press(root, "Open The rebate")
	var rebate_from_housing := _visible_label_blob(root)
	_expect(rebate_from_housing.find("Plane chit") >= 0, "could not return to The rebate from The housing")
	_expect(rebate_from_housing.find("Shoulder note") >= 0, "rebate exhibits did not return")
	_expect(rebate_from_housing.find("CW-26") >= 0, "returned rebate omits CW-26")
	_expect(rebate_from_housing.find("Saw chit") == -1, "housing papers stayed up inside The rebate")
	_expect(rebate_from_housing.find("Square sight") == -1, "housing papers showed inside The rebate")
	_expect(rebate_from_housing.find("Fillet hook") == -1, "housing papers showed inside The rebate")
	_expect(rebate_from_housing.find("Trench slate") == -1, "housing papers showed inside The rebate")
	_expect(rebate_from_housing.find("Stock card") == -1, "housing papers showed inside The rebate")
	_expect(rebate_from_housing.find("Chalk slip") == -1, "housing papers showed inside The rebate")
	_expect(rebate_from_housing.find("Mark leaf") == -1, "housing papers showed inside The rebate")
	_expect(rebate_from_housing.find("Trench note") == -1, "housing papers showed inside The rebate")
	_expect(rebate_from_housing.find("CW-27") == -1, "housing file code stayed up inside The rebate")
	_press(root, "Tansy")
	_press(root, "Plane")
	_press(root, "73")
	_press(root, "Submit theory")
	var rebate_again := _verdict_text(root)
	_expect(rebate_again.find("fits every exhibit") >= 0, "rebate board rejected the true theory after The housing: %s" % rebate_again)
	_expect(rebate_again.find("Tansy (plane hand) cut the rebate in the plane at 73") >= 0, "rebate board timeline after The housing: %s" % rebate_again)
	var rebate_again_blob := _visible_label_blob(root)
	_expect(rebate_again_blob.find("Plane chit") >= 0, "rebate papers left after returning")
	_expect(rebate_again_blob.find("Saw chit") == -1, "housing papers stayed up after returning to The rebate")
	_expect(rebate_again_blob.find("Trench note") == -1, "housing papers stayed up after returning to The rebate")
	_press(root, "Menu")
	_press(root, "Open The tenon")
	var tenon_open := _visible_label_blob(root)
	_expect(tenon_open.find("Gouge chit") >= 0, "tenon file did not open")
	_expect(tenon_open.find("Haunch note") >= 0, "tenon file did not show its exhibits")
	_expect(tenon_open.find("CW-28") >= 0, "tenon file omits CW-28")
	_expect(tenon_open.find("Dowel hook") >= 0, "tenon file omits Dowel hook")
	_expect(tenon_open.find("Complaint slip") == -1, "spare key papers showed inside The tenon")
	_expect(tenon_open.find("Cut list") == -1, "rehearsal papers showed inside The tenon")
	_expect(tenon_open.find("Move order") == -1, "gilt stamp papers showed inside The tenon")
	_expect(tenon_open.find("Whistle slip") == -1, "ferry bell papers showed inside The tenon")
	_expect(tenon_open.find("Frost note") == -1, "weather slate papers showed inside The tenon")
	_expect(tenon_open.find("Trough tag") == -1, "loom shuttle papers showed inside The tenon")
	_expect(tenon_open.find("Fuel line") == -1, "hive smoker papers showed inside The tenon")
	_expect(tenon_open.find("Weight line") == -1, "glass pontil papers showed inside The tenon")
	_expect(tenon_open.find("Lock line") == -1, "press proof papers showed inside The tenon")
	_expect(tenon_open.find("Cup line") == -1, "assay cup papers showed inside The tenon")
	_expect(tenon_open.find("Mark line") == -1, "kiln chalk papers showed inside The tenon")
	_expect(tenon_open.find("Ledger line") == -1, "tide ledger papers showed inside The tenon")
	_expect(tenon_open.find("Bell line") == -1, "night bell papers showed inside The tenon")
	_expect(tenon_open.find("Salt line") == -1, "salt mark papers showed inside The tenon")
	_expect(tenon_open.find("Oil note") == -1, "wick trim papers showed inside The tenon")
	_expect(tenon_open.find("Gather note") == -1, "glass anneal papers showed inside The tenon")
	_expect(tenon_open.find("Scion note") == -1, "orchard graft papers showed inside The tenon")
	_expect(tenon_open.find("Winder chit") == -1, "dye vat papers showed inside The tenon")
	_expect(tenon_open.find("Rope chit") == -1, "tar kettle papers showed inside The tenon")
	_expect(tenon_open.find("Cutter chit") == -1, "cork press papers showed inside The tenon")
	_expect(tenon_open.find("Mesh chit") == -1, "net loft papers showed inside The tenon")
	_expect(tenon_open.find("Hoop chit") == -1, "cask hoop papers showed inside The tenon")
	_expect(tenon_open.find("Shears chit") == -1, "linen fold papers showed inside The tenon")
	_expect(tenon_open.find("Apron sight") == -1, "dovetail papers showed inside The tenon")
	_expect(tenon_open.find("Peg hook") == -1, "dovetail papers showed inside The tenon")
	_expect(tenon_open.find("Joint slate") == -1, "dovetail papers showed inside The tenon")
	_expect(tenon_open.find("Clamp card") == -1, "dovetail papers showed inside The tenon")
	_expect(tenon_open.find("Sweep slip") == -1, "dovetail papers showed inside The tenon")
	_expect(tenon_open.find("Cut leaf") == -1, "dovetail papers showed inside The tenon")
	_expect(tenon_open.find("Joint note") == -1, "dovetail papers showed inside The tenon")
	_expect(tenon_open.find("Jaw order") == -1, "dovetail papers showed inside The tenon")
	_expect(tenon_open.find("CW-24") == -1, "dovetail file code stayed up inside The tenon")
	_expect(tenon_open.find("Chisel chit") == -1, "mortise papers stayed up inside The tenon")
	_expect(tenon_open.find("Awl sight") == -1, "mortise papers showed inside The tenon")
	_expect(tenon_open.find("Wedge hook") == -1, "mortise papers showed inside The tenon")
	_expect(tenon_open.find("Tenon slate") == -1, "mortise papers showed inside The tenon")
	_expect(tenon_open.find("Brace card") == -1, "mortise papers showed inside The tenon")
	_expect(tenon_open.find("Brush slip") == -1, "mortise papers showed inside The tenon")
	_expect(tenon_open.find("Bore leaf") == -1, "mortise papers showed inside The tenon")
	_expect(tenon_open.find("Tenon note") == -1, "mortise papers showed inside The tenon")
	_expect(tenon_open.find("Rack order") == -1, "mortise papers showed inside The tenon")
	_expect(tenon_open.find("CW-25") == -1, "mortise file code stayed up inside The tenon")
	_expect(tenon_open.find("Plane chit") == -1, "rebate papers stayed up inside The tenon")
	_expect(tenon_open.find("Gauge sight") == -1, "rebate papers showed inside The tenon")
	_expect(tenon_open.find("Shim hook") == -1, "rebate papers showed inside The tenon")
	_expect(tenon_open.find("Shoulder slate") == -1, "rebate papers showed inside The tenon")
	_expect(tenon_open.find("Fence card") == -1, "rebate papers showed inside The tenon")
	_expect(tenon_open.find("Oil slip") == -1, "rebate papers showed inside The tenon")
	_expect(tenon_open.find("Scribe leaf") == -1, "rebate papers showed inside The tenon")
	_expect(tenon_open.find("Shoulder note") == -1, "rebate papers showed inside The tenon")
	_expect(tenon_open.find("CW-26") == -1, "rebate file code stayed up inside The tenon")
	_expect(tenon_open.find("Saw chit") == -1, "housing papers stayed up inside The tenon")
	_expect(tenon_open.find("Square sight") == -1, "housing papers showed inside The tenon")
	_expect(tenon_open.find("Fillet hook") == -1, "housing papers showed inside The tenon")
	_expect(tenon_open.find("Trench slate") == -1, "housing papers showed inside The tenon")
	_expect(tenon_open.find("Stock card") == -1, "housing papers showed inside The tenon")
	_expect(tenon_open.find("Chalk slip") == -1, "housing papers showed inside The tenon")
	_expect(tenon_open.find("Mark leaf") == -1, "housing papers showed inside The tenon")
	_expect(tenon_open.find("Trench note") == -1, "housing papers showed inside The tenon")
	_expect(tenon_open.find("CW-27") == -1, "housing file code stayed up inside The tenon")
	_press(root, "Submit theory")
	var empty_tenon := _verdict_text(root)
	_expect(empty_tenon.find("who cut the tenon") >= 0, "empty tenon board: %s" % empty_tenon)
	_expect(empty_tenon.find("where they cut the tenon") >= 0, "empty tenon board: %s" % empty_tenon)
	_expect(empty_tenon.find("at which hour they cut the tenon") >= 0, "empty tenon board: %s" % empty_tenon)
	_expect(empty_tenon.find("who took the spare key") == -1, "empty tenon board used the spare key slot: %s" % empty_tenon)
	_expect(empty_tenon.find("who cut the housing") == -1, "empty tenon board used a housing slot: %s" % empty_tenon)
	_expect(empty_tenon.to_lower().find("conflict") == -1, "empty tenon board talked about a conflict: %s" % empty_tenon)
	_press(root, "Neve")
	_press(root, "Rasp")
	_press(root, "81")
	_press(root, "Submit theory")
	var tenon_miss := _verdict_text(root)
	_expect_reply_names_conflicts(tenon_miss, Tenon, {"who": "Neve", "place": "rasp", "hour": "81"})
	_expect(Tenon.conflicting_ids({"who": "Neve", "place": "rasp", "hour": "81"}).size() == 9, "Neve / rasp / 81 should contradict every exhibit")
	_expect(tenon_miss.find("Gouge chit") >= 0, "wrong triple reply omits Gouge chit: %s" % tenon_miss)
	_expect(tenon_miss.find("Rasp sight") >= 0, "wrong triple reply omits Rasp sight: %s" % tenon_miss)
	_expect(tenon_miss.find("Dowel hook") >= 0, "wrong triple reply omits Dowel hook: %s" % tenon_miss)
	_expect(tenon_miss.find("Haunch slate") >= 0, "wrong triple reply omits Haunch slate: %s" % tenon_miss)
	_expect(tenon_miss.find("Guide card") >= 0, "wrong triple reply omits Guide card: %s" % tenon_miss)
	_expect(tenon_miss.find("Hone slip") >= 0, "wrong triple reply omits Hone slip: %s" % tenon_miss)
	_expect(tenon_miss.find("Nick leaf") >= 0, "wrong triple reply omits Nick leaf: %s" % tenon_miss)
	_expect(tenon_miss.find("Haunch note") >= 0, "wrong triple reply omits Haunch note: %s" % tenon_miss)
	_expect(tenon_miss.find("Hang order") >= 0, "wrong triple reply omits Hang order: %s" % tenon_miss)
	_press(root, "Harl")
	_press(root, "Gouge")
	_press(root, "83")
	_press(root, "Submit theory")
	var tenon_accepted := _verdict_text(root)
	_expect(tenon_accepted.find("fits every exhibit") >= 0, "tenon board rejected the true theory: %s" % tenon_accepted)
	_expect(tenon_accepted.find(TENON_TIMELINE) >= 0, "tenon board timeline: %s" % tenon_accepted)
	_expect(tenon_accepted.find("Harl (gouge hand) cut the tenon in the gouge at 83") >= 0, "tenon board omits Harl at 83: %s" % tenon_accepted)
	_expect(tenon_accepted.find("in the gouge") >= 0, "tenon board omits the gouge: %s" % tenon_accepted)
	_expect(tenon_accepted.find("so the bevel would take the haunch") >= 0, "tenon board omits the haunch: %s" % tenon_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var tenon_cleared := _verdict_text(root)
	_expect(tenon_cleared.find("who cut the tenon") >= 0, "cleared tenon board: %s" % tenon_cleared)
	_expect(tenon_cleared.find("fits every exhibit") == -1, "cleared tenon board stayed accepted: %s" % tenon_cleared)
	_press(root, "Menu")
	_press(root, "Open The housing")
	var housing_from_tenon := _visible_label_blob(root)
	_expect(housing_from_tenon.find("Saw chit") >= 0, "could not return to The housing from The tenon")
	_expect(housing_from_tenon.find("Trench note") >= 0, "housing exhibits did not return")
	_expect(housing_from_tenon.find("CW-27") >= 0, "returned housing omits CW-27")
	_expect(housing_from_tenon.find("Gouge chit") == -1, "tenon papers stayed up inside The housing")
	_expect(housing_from_tenon.find("Rasp sight") == -1, "tenon papers showed inside The housing")
	_expect(housing_from_tenon.find("Dowel hook") == -1, "tenon papers showed inside The housing")
	_expect(housing_from_tenon.find("Haunch slate") == -1, "tenon papers showed inside The housing")
	_expect(housing_from_tenon.find("Guide card") == -1, "tenon papers showed inside The housing")
	_expect(housing_from_tenon.find("Hone slip") == -1, "tenon papers showed inside The housing")
	_expect(housing_from_tenon.find("Nick leaf") == -1, "tenon papers showed inside The housing")
	_expect(housing_from_tenon.find("Haunch note") == -1, "tenon papers showed inside The housing")
	_expect(housing_from_tenon.find("CW-28") == -1, "tenon file code stayed up inside The housing")
	_press(root, "Ewan")
	_press(root, "Saw")
	_press(root, "78")
	_press(root, "Submit theory")
	var housing_again := _verdict_text(root)
	_expect(housing_again.find("fits every exhibit") >= 0, "housing board rejected the true theory after The tenon: %s" % housing_again)
	_expect(housing_again.find("Ewan (saw hand) cut the housing in the saw at 78") >= 0, "housing board timeline after The tenon: %s" % housing_again)
	var housing_again_blob := _visible_label_blob(root)
	_expect(housing_again_blob.find("Saw chit") >= 0, "housing papers left after returning")
	_expect(housing_again_blob.find("Gouge chit") == -1, "tenon papers stayed up after returning to The housing")
	_expect(housing_again_blob.find("Haunch note") == -1, "tenon papers stayed up after returning to The housing")
	_press(root, "Menu")
	_press(root, "Open The bridle")
	var bridle_open := _visible_label_blob(root)
	_expect(bridle_open.find("Router chit") >= 0, "bridle file did not open")
	_expect(bridle_open.find("Tongue note") >= 0, "bridle file did not show its exhibits")
	_expect(bridle_open.find("CW-29") >= 0, "bridle file omits CW-29")
	_expect(bridle_open.find("Spline hook") >= 0, "bridle file omits Spline hook")
	_expect(bridle_open.find("Strop slip") >= 0, "bridle file omits Strop slip")
	_expect(bridle_open.find("Notch leaf") >= 0, "bridle file omits Notch leaf")
	_expect(bridle_open.find("Hang order") >= 0, "bridle file omits Hang order")
	_expect(bridle_open.find("Complaint slip") == -1, "spare key papers showed inside The bridle")
	_expect(bridle_open.find("Cut list") == -1, "rehearsal papers showed inside The bridle")
	_expect(bridle_open.find("Move order") == -1, "gilt stamp papers showed inside The bridle")
	_expect(bridle_open.find("Whistle slip") == -1, "ferry bell papers showed inside The bridle")
	_expect(bridle_open.find("Frost note") == -1, "weather slate papers showed inside The bridle")
	_expect(bridle_open.find("Trough tag") == -1, "loom shuttle papers showed inside The bridle")
	_expect(bridle_open.find("Fuel line") == -1, "hive smoker papers showed inside The bridle")
	_expect(bridle_open.find("Weight line") == -1, "glass pontil papers showed inside The bridle")
	_expect(bridle_open.find("Lock line") == -1, "press proof papers showed inside The bridle")
	_expect(bridle_open.find("Cup line") == -1, "assay cup papers showed inside The bridle")
	_expect(bridle_open.find("Mark line") == -1, "kiln chalk papers showed inside The bridle")
	_expect(bridle_open.find("Ledger line") == -1, "tide ledger papers showed inside The bridle")
	_expect(bridle_open.find("Bell line") == -1, "night bell papers showed inside The bridle")
	_expect(bridle_open.find("Salt line") == -1, "salt mark papers showed inside The bridle")
	_expect(bridle_open.find("Oil note") == -1, "wick trim papers showed inside The bridle")
	_expect(bridle_open.find("Gather note") == -1, "glass anneal papers showed inside The bridle")
	_expect(bridle_open.find("Scion note") == -1, "orchard graft papers showed inside The bridle")
	_expect(bridle_open.find("Winder chit") == -1, "dye vat papers showed inside The bridle")
	_expect(bridle_open.find("Rope chit") == -1, "tar kettle papers showed inside The bridle")
	_expect(bridle_open.find("Cutter chit") == -1, "cork press papers showed inside The bridle")
	_expect(bridle_open.find("Mesh chit") == -1, "net loft papers showed inside The bridle")
	_expect(bridle_open.find("Hoop chit") == -1, "cask hoop papers showed inside The bridle")
	_expect(bridle_open.find("Shears chit") == -1, "linen fold papers showed inside The bridle")
	_expect(bridle_open.find("Apron sight") == -1, "dovetail papers showed inside The bridle")
	_expect(bridle_open.find("Peg hook") == -1, "dovetail papers showed inside The bridle")
	_expect(bridle_open.find("Joint slate") == -1, "dovetail papers showed inside The bridle")
	_expect(bridle_open.find("Clamp card") == -1, "dovetail papers showed inside The bridle")
	_expect(bridle_open.find("Sweep slip") == -1, "dovetail papers showed inside The bridle")
	_expect(bridle_open.find("Cut leaf") == -1, "dovetail papers showed inside The bridle")
	_expect(bridle_open.find("Joint note") == -1, "dovetail papers showed inside The bridle")
	_expect(bridle_open.find("Jaw order") == -1, "dovetail papers showed inside The bridle")
	_expect(bridle_open.find("CW-24") == -1, "dovetail file code stayed up inside The bridle")
	_expect(bridle_open.find("Chisel chit") == -1, "mortise papers stayed up inside The bridle")
	_expect(bridle_open.find("Awl sight") == -1, "mortise papers showed inside The bridle")
	_expect(bridle_open.find("Wedge hook") == -1, "mortise papers showed inside The bridle")
	_expect(bridle_open.find("Tenon slate") == -1, "mortise papers showed inside The bridle")
	_expect(bridle_open.find("Brace card") == -1, "mortise papers showed inside The bridle")
	_expect(bridle_open.find("Brush slip") == -1, "mortise papers showed inside The bridle")
	_expect(bridle_open.find("Bore leaf") == -1, "mortise papers showed inside The bridle")
	_expect(bridle_open.find("Tenon note") == -1, "mortise papers showed inside The bridle")
	_expect(bridle_open.find("Rack order") == -1, "mortise papers showed inside The bridle")
	_expect(bridle_open.find("CW-25") == -1, "mortise file code stayed up inside The bridle")
	_expect(bridle_open.find("Plane chit") == -1, "rebate papers stayed up inside The bridle")
	_expect(bridle_open.find("Gauge sight") == -1, "rebate papers showed inside The bridle")
	_expect(bridle_open.find("Shim hook") == -1, "rebate papers showed inside The bridle")
	_expect(bridle_open.find("Shoulder slate") == -1, "rebate papers showed inside The bridle")
	_expect(bridle_open.find("Fence card") == -1, "rebate papers showed inside The bridle")
	_expect(bridle_open.find("Oil slip") == -1, "rebate papers showed inside The bridle")
	_expect(bridle_open.find("Scribe leaf") == -1, "rebate papers showed inside The bridle")
	_expect(bridle_open.find("Shoulder note") == -1, "rebate papers showed inside The bridle")
	_expect(bridle_open.find("CW-26") == -1, "rebate file code stayed up inside The bridle")
	_expect(bridle_open.find("Saw chit") == -1, "housing papers stayed up inside The bridle")
	_expect(bridle_open.find("Square sight") == -1, "housing papers showed inside The bridle")
	_expect(bridle_open.find("Fillet hook") == -1, "housing papers showed inside The bridle")
	_expect(bridle_open.find("Trench slate") == -1, "housing papers showed inside The bridle")
	_expect(bridle_open.find("Stock card") == -1, "housing papers showed inside The bridle")
	_expect(bridle_open.find("Chalk slip") == -1, "housing papers showed inside The bridle")
	_expect(bridle_open.find("Mark leaf") == -1, "housing papers showed inside The bridle")
	_expect(bridle_open.find("Trench note") == -1, "housing papers showed inside The bridle")
	_expect(bridle_open.find("CW-27") == -1, "housing file code stayed up inside The bridle")
	_expect(bridle_open.find("Gouge chit") == -1, "tenon papers stayed up inside The bridle")
	_expect(bridle_open.find("Rasp sight") == -1, "tenon papers showed inside The bridle")
	_expect(bridle_open.find("Dowel hook") == -1, "tenon papers showed inside The bridle")
	_expect(bridle_open.find("Haunch slate") == -1, "tenon papers showed inside The bridle")
	_expect(bridle_open.find("Guide card") == -1, "tenon papers showed inside The bridle")
	_expect(bridle_open.find("Hone slip") == -1, "tenon papers showed inside The bridle")
	_expect(bridle_open.find("Nick leaf") == -1, "tenon papers showed inside The bridle")
	_expect(bridle_open.find("Haunch note") == -1, "tenon papers showed inside The bridle")
	_expect(bridle_open.find("CW-28") == -1, "tenon file code stayed up inside The bridle")
	_press(root, "Submit theory")
	var empty_bridle := _verdict_text(root)
	_expect(empty_bridle.find("who cut the bridle") >= 0, "empty bridle board: %s" % empty_bridle)
	_expect(empty_bridle.find("where they cut the bridle") >= 0, "empty bridle board: %s" % empty_bridle)
	_expect(empty_bridle.find("at which hour they cut the bridle") >= 0, "empty bridle board: %s" % empty_bridle)
	_expect(empty_bridle.find("who took the spare key") == -1, "empty bridle board used the spare key slot: %s" % empty_bridle)
	_expect(empty_bridle.find("who cut the tenon") == -1, "empty bridle board used a tenon slot: %s" % empty_bridle)
	_expect(empty_bridle.to_lower().find("conflict") == -1, "empty bridle board talked about a conflict: %s" % empty_bridle)
	_press(root, "Sile")
	_press(root, "Scraper")
	_press(root, "86")
	_press(root, "Submit theory")
	var bridle_miss := _verdict_text(root)
	_expect_reply_names_conflicts(bridle_miss, Bridle, {"who": "Sile", "place": "scraper", "hour": "86"})
	_expect(Bridle.conflicting_ids({"who": "Sile", "place": "scraper", "hour": "86"}).size() == 9, "Sile / scraper / 86 should contradict every exhibit")
	_expect(bridle_miss.find("Router chit") >= 0, "wrong triple reply omits Router chit: %s" % bridle_miss)
	_expect(bridle_miss.find("Scraper sight") >= 0, "wrong triple reply omits Scraper sight: %s" % bridle_miss)
	_expect(bridle_miss.find("Spline hook") >= 0, "wrong triple reply omits Spline hook: %s" % bridle_miss)
	_expect(bridle_miss.find("Tongue slate") >= 0, "wrong triple reply omits Tongue slate: %s" % bridle_miss)
	_expect(bridle_miss.find("Templet card") >= 0, "wrong triple reply omits Templet card: %s" % bridle_miss)
	_expect(bridle_miss.find("Strop slip") >= 0, "wrong triple reply omits Strop slip: %s" % bridle_miss)
	_expect(bridle_miss.find("Notch leaf") >= 0, "wrong triple reply omits Notch leaf: %s" % bridle_miss)
	_expect(bridle_miss.find("Tongue note") >= 0, "wrong triple reply omits Tongue note: %s" % bridle_miss)
	_expect(bridle_miss.find("Hang order") >= 0, "wrong triple reply omits Hang order: %s" % bridle_miss)
	_press(root, "Wend")
	_press(root, "Router")
	_press(root, "88")
	_press(root, "Submit theory")
	var bridle_accepted := _verdict_text(root)
	_expect(bridle_accepted.find("fits every exhibit") >= 0, "bridle board rejected the true theory: %s" % bridle_accepted)
	_expect(bridle_accepted.find(BRIDLE_TIMELINE) >= 0, "bridle board timeline: %s" % bridle_accepted)
	_expect(bridle_accepted.find("Wend (router hand) cut the bridle in the router at 88") >= 0, "bridle board omits Wend at 88: %s" % bridle_accepted)
	_expect(bridle_accepted.find("in the router") >= 0, "bridle board omits the router: %s" % bridle_accepted)
	_expect(bridle_accepted.find("so the adze would take the tongue") >= 0, "bridle board omits the tongue: %s" % bridle_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var bridle_cleared := _verdict_text(root)
	_expect(bridle_cleared.find("who cut the bridle") >= 0, "cleared bridle board: %s" % bridle_cleared)
	_expect(bridle_cleared.find("fits every exhibit") == -1, "cleared bridle board stayed accepted: %s" % bridle_cleared)
	_press(root, "Menu")
	_press(root, "Open The tenon")
	var tenon_from_bridle := _visible_label_blob(root)
	_expect(tenon_from_bridle.find("Gouge chit") >= 0, "could not return to The tenon from The bridle")
	_expect(tenon_from_bridle.find("Haunch note") >= 0, "tenon exhibits did not return")
	_expect(tenon_from_bridle.find("CW-28") >= 0, "returned tenon omits CW-28")
	_expect(tenon_from_bridle.find("Router chit") == -1, "bridle papers stayed up inside The tenon")
	_expect(tenon_from_bridle.find("Scraper sight") == -1, "bridle papers showed inside The tenon")
	_expect(tenon_from_bridle.find("Spline hook") == -1, "bridle papers showed inside The tenon")
	_expect(tenon_from_bridle.find("Tongue slate") == -1, "bridle papers showed inside The tenon")
	_expect(tenon_from_bridle.find("Templet card") == -1, "bridle papers showed inside The tenon")
	_expect(tenon_from_bridle.find("Strop slip") == -1, "bridle papers showed inside The tenon")
	_expect(tenon_from_bridle.find("Notch leaf") == -1, "bridle papers showed inside The tenon")
	_expect(tenon_from_bridle.find("Tongue note") == -1, "bridle papers showed inside The tenon")
	_expect(tenon_from_bridle.find("CW-29") == -1, "bridle file code stayed up inside The tenon")
	_press(root, "Harl")
	_press(root, "Gouge")
	_press(root, "83")
	_press(root, "Submit theory")
	var tenon_again := _verdict_text(root)
	_expect(tenon_again.find("fits every exhibit") >= 0, "tenon board rejected the true theory after The bridle: %s" % tenon_again)
	_expect(tenon_again.find("Harl (gouge hand) cut the tenon in the gouge at 83") >= 0, "tenon board timeline after The bridle: %s" % tenon_again)
	var tenon_again_blob := _visible_label_blob(root)
	_expect(tenon_again_blob.find("Gouge chit") >= 0, "tenon papers left after returning")
	_expect(tenon_again_blob.find("Router chit") == -1, "bridle papers stayed up after returning to The tenon")
	_expect(tenon_again_blob.find("Tongue note") == -1, "bridle papers stayed up after returning to The tenon")
	_press(root, "Menu")
	_press(root, "Open The dado")
	var dado_open := _visible_label_blob(root)
	_expect(dado_open.find("Plough chit") >= 0, "dado file did not open")
	_expect(dado_open.find("Groove note") >= 0, "dado file did not show its exhibits")
	_expect(dado_open.find("CW-30") >= 0, "dado file omits CW-30")
	_expect(dado_open.find("Cleat hook") >= 0, "dado file omits Cleat hook")
	_expect(dado_open.find("Whet slip") >= 0, "dado file omits Whet slip")
	_expect(dado_open.find("Score leaf") >= 0, "dado file omits Score leaf")
	_expect(dado_open.find("Hang order") >= 0, "dado file omits Hang order")
	_expect(dado_open.find("Complaint slip") == -1, "spare key papers showed inside The dado")
	_expect(dado_open.find("Cut list") == -1, "rehearsal papers showed inside The dado")
	_expect(dado_open.find("Move order") == -1, "gilt stamp papers showed inside The dado")
	_expect(dado_open.find("Whistle slip") == -1, "ferry bell papers showed inside The dado")
	_expect(dado_open.find("Frost note") == -1, "weather slate papers showed inside The dado")
	_expect(dado_open.find("Trough tag") == -1, "loom shuttle papers showed inside The dado")
	_expect(dado_open.find("Fuel line") == -1, "hive smoker papers showed inside The dado")
	_expect(dado_open.find("Weight line") == -1, "glass pontil papers showed inside The dado")
	_expect(dado_open.find("Lock line") == -1, "press proof papers showed inside The dado")
	_expect(dado_open.find("Cup line") == -1, "assay cup papers showed inside The dado")
	_expect(dado_open.find("Mark line") == -1, "kiln chalk papers showed inside The dado")
	_expect(dado_open.find("Ledger line") == -1, "tide ledger papers showed inside The dado")
	_expect(dado_open.find("Bell line") == -1, "night bell papers showed inside The dado")
	_expect(dado_open.find("Salt line") == -1, "salt mark papers showed inside The dado")
	_expect(dado_open.find("Oil note") == -1, "wick trim papers showed inside The dado")
	_expect(dado_open.find("Gather note") == -1, "glass anneal papers showed inside The dado")
	_expect(dado_open.find("Scion note") == -1, "orchard graft papers showed inside The dado")
	_expect(dado_open.find("Winder chit") == -1, "dye vat papers showed inside The dado")
	_expect(dado_open.find("Rope chit") == -1, "tar kettle papers showed inside The dado")
	_expect(dado_open.find("Cutter chit") == -1, "cork press papers showed inside The dado")
	_expect(dado_open.find("Mesh chit") == -1, "net loft papers showed inside The dado")
	_expect(dado_open.find("Hoop chit") == -1, "cask hoop papers showed inside The dado")
	_expect(dado_open.find("Shears chit") == -1, "linen fold papers showed inside The dado")
	_expect(dado_open.find("Apron sight") == -1, "dovetail papers showed inside The dado")
	_expect(dado_open.find("Peg hook") == -1, "dovetail papers showed inside The dado")
	_expect(dado_open.find("Joint slate") == -1, "dovetail papers showed inside The dado")
	_expect(dado_open.find("Clamp card") == -1, "dovetail papers showed inside The dado")
	_expect(dado_open.find("Sweep slip") == -1, "dovetail papers showed inside The dado")
	_expect(dado_open.find("Cut leaf") == -1, "dovetail papers showed inside The dado")
	_expect(dado_open.find("Joint note") == -1, "dovetail papers showed inside The dado")
	_expect(dado_open.find("Jaw order") == -1, "dovetail papers showed inside The dado")
	_expect(dado_open.find("CW-24") == -1, "dovetail file code stayed up inside The dado")
	_expect(dado_open.find("Chisel chit") == -1, "mortise papers stayed up inside The dado")
	_expect(dado_open.find("Awl sight") == -1, "mortise papers showed inside The dado")
	_expect(dado_open.find("Wedge hook") == -1, "mortise papers showed inside The dado")
	_expect(dado_open.find("Tenon slate") == -1, "mortise papers showed inside The dado")
	_expect(dado_open.find("Brace card") == -1, "mortise papers showed inside The dado")
	_expect(dado_open.find("Brush slip") == -1, "mortise papers showed inside The dado")
	_expect(dado_open.find("Bore leaf") == -1, "mortise papers showed inside The dado")
	_expect(dado_open.find("Tenon note") == -1, "mortise papers showed inside The dado")
	_expect(dado_open.find("Rack order") == -1, "mortise papers showed inside The dado")
	_expect(dado_open.find("CW-25") == -1, "mortise file code stayed up inside The dado")
	_expect(dado_open.find("Plane chit") == -1, "rebate papers stayed up inside The dado")
	_expect(dado_open.find("Gauge sight") == -1, "rebate papers showed inside The dado")
	_expect(dado_open.find("Shim hook") == -1, "rebate papers showed inside The dado")
	_expect(dado_open.find("Shoulder slate") == -1, "rebate papers showed inside The dado")
	_expect(dado_open.find("Fence card") == -1, "rebate papers showed inside The dado")
	_expect(dado_open.find("Oil slip") == -1, "rebate papers showed inside The dado")
	_expect(dado_open.find("Scribe leaf") == -1, "rebate papers showed inside The dado")
	_expect(dado_open.find("Shoulder note") == -1, "rebate papers showed inside The dado")
	_expect(dado_open.find("CW-26") == -1, "rebate file code stayed up inside The dado")
	_expect(dado_open.find("Saw chit") == -1, "housing papers stayed up inside The dado")
	_expect(dado_open.find("Square sight") == -1, "housing papers showed inside The dado")
	_expect(dado_open.find("Fillet hook") == -1, "housing papers showed inside The dado")
	_expect(dado_open.find("Trench slate") == -1, "housing papers showed inside The dado")
	_expect(dado_open.find("Stock card") == -1, "housing papers showed inside The dado")
	_expect(dado_open.find("Chalk slip") == -1, "housing papers showed inside The dado")
	_expect(dado_open.find("Mark leaf") == -1, "housing papers showed inside The dado")
	_expect(dado_open.find("Trench note") == -1, "housing papers showed inside The dado")
	_expect(dado_open.find("CW-27") == -1, "housing file code stayed up inside The dado")
	_expect(dado_open.find("Gouge chit") == -1, "tenon papers stayed up inside The dado")
	_expect(dado_open.find("Rasp sight") == -1, "tenon papers showed inside The dado")
	_expect(dado_open.find("Dowel hook") == -1, "tenon papers showed inside The dado")
	_expect(dado_open.find("Haunch slate") == -1, "tenon papers showed inside The dado")
	_expect(dado_open.find("Guide card") == -1, "tenon papers showed inside The dado")
	_expect(dado_open.find("Hone slip") == -1, "tenon papers showed inside The dado")
	_expect(dado_open.find("Nick leaf") == -1, "tenon papers showed inside The dado")
	_expect(dado_open.find("Haunch note") == -1, "tenon papers showed inside The dado")
	_expect(dado_open.find("CW-28") == -1, "tenon file code stayed up inside The dado")
	_expect(dado_open.find("Router chit") == -1, "bridle papers stayed up inside The dado")
	_expect(dado_open.find("Scraper sight") == -1, "bridle papers showed inside The dado")
	_expect(dado_open.find("Spline hook") == -1, "bridle papers showed inside The dado")
	_expect(dado_open.find("Tongue slate") == -1, "bridle papers showed inside The dado")
	_expect(dado_open.find("Templet card") == -1, "bridle papers showed inside The dado")
	_expect(dado_open.find("Strop slip") == -1, "bridle papers showed inside The dado")
	_expect(dado_open.find("Notch leaf") == -1, "bridle papers showed inside The dado")
	_expect(dado_open.find("Tongue note") == -1, "bridle papers showed inside The dado")
	_expect(dado_open.find("CW-29") == -1, "bridle file code stayed up inside The dado")
	_press(root, "Submit theory")
	var empty_dado := _verdict_text(root)
	_expect(empty_dado.find("who cut the dado") >= 0, "empty dado board: %s" % empty_dado)
	_expect(empty_dado.find("where they cut the dado") >= 0, "empty dado board: %s" % empty_dado)
	_expect(empty_dado.find("at which hour they cut the dado") >= 0, "empty dado board: %s" % empty_dado)
	_expect(empty_dado.find("who took the spare key") == -1, "empty dado board used the spare key slot: %s" % empty_dado)
	_expect(empty_dado.find("who cut the bridle") == -1, "empty dado board used a bridle slot: %s" % empty_dado)
	_expect(empty_dado.to_lower().find("conflict") == -1, "empty dado board talked about a conflict: %s" % empty_dado)
	_press(root, "Phel")
	_press(root, "Float")
	_press(root, "91")
	_press(root, "Submit theory")
	var dado_miss := _verdict_text(root)
	_expect_reply_names_conflicts(dado_miss, Dado, {"who": "Phel", "place": "float", "hour": "91"})
	_expect(Dado.conflicting_ids({"who": "Phel", "place": "float", "hour": "91"}).size() == 9, "Phel / float / 91 should contradict every exhibit")
	_expect(dado_miss.find("Plough chit") >= 0, "wrong triple reply omits Plough chit: %s" % dado_miss)
	_expect(dado_miss.find("Float sight") >= 0, "wrong triple reply omits Float sight: %s" % dado_miss)
	_expect(dado_miss.find("Cleat hook") >= 0, "wrong triple reply omits Cleat hook: %s" % dado_miss)
	_expect(dado_miss.find("Groove slate") >= 0, "wrong triple reply omits Groove slate: %s" % dado_miss)
	_expect(dado_miss.find("Spur card") >= 0, "wrong triple reply omits Spur card: %s" % dado_miss)
	_expect(dado_miss.find("Whet slip") >= 0, "wrong triple reply omits Whet slip: %s" % dado_miss)
	_expect(dado_miss.find("Score leaf") >= 0, "wrong triple reply omits Score leaf: %s" % dado_miss)
	_expect(dado_miss.find("Groove note") >= 0, "wrong triple reply omits Groove note: %s" % dado_miss)
	_expect(dado_miss.find("Hang order") >= 0, "wrong triple reply omits Hang order: %s" % dado_miss)
	_press(root, "Kern")
	_press(root, "Plough")
	_press(root, "93")
	_press(root, "Submit theory")
	var dado_accepted := _verdict_text(root)
	_expect(dado_accepted.find("fits every exhibit") >= 0, "dado board rejected the true theory: %s" % dado_accepted)
	_expect(dado_accepted.find(DADO_TIMELINE) >= 0, "dado board timeline: %s" % dado_accepted)
	_expect(dado_accepted.find("Kern (plough hand) cut the dado in the plough at 93") >= 0, "dado board omits Kern at 93: %s" % dado_accepted)
	_expect(dado_accepted.find("in the plough") >= 0, "dado board omits the plough: %s" % dado_accepted)
	_expect(dado_accepted.find("so the gimlet would take the groove") >= 0, "dado board omits the groove: %s" % dado_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var dado_cleared := _verdict_text(root)
	_expect(dado_cleared.find("who cut the dado") >= 0, "cleared dado board: %s" % dado_cleared)
	_expect(dado_cleared.find("fits every exhibit") == -1, "cleared dado board stayed accepted: %s" % dado_cleared)
	_press(root, "Menu")
	_press(root, "Open The bridle")
	var bridle_from_dado := _visible_label_blob(root)
	_expect(bridle_from_dado.find("Router chit") >= 0, "could not return to The bridle from The dado")
	_expect(bridle_from_dado.find("Tongue note") >= 0, "bridle exhibits did not return")
	_expect(bridle_from_dado.find("CW-29") >= 0, "returned bridle omits CW-29")
	_expect(bridle_from_dado.find("Plough chit") == -1, "dado papers stayed up inside The bridle")
	_expect(bridle_from_dado.find("Float sight") == -1, "dado papers showed inside The bridle")
	_expect(bridle_from_dado.find("Cleat hook") == -1, "dado papers showed inside The bridle")
	_expect(bridle_from_dado.find("Groove slate") == -1, "dado papers showed inside The bridle")
	_expect(bridle_from_dado.find("Spur card") == -1, "dado papers showed inside The bridle")
	_expect(bridle_from_dado.find("Whet slip") == -1, "dado papers showed inside The bridle")
	_expect(bridle_from_dado.find("Score leaf") == -1, "dado papers showed inside The bridle")
	_expect(bridle_from_dado.find("Groove note") == -1, "dado papers showed inside The bridle")
	_expect(bridle_from_dado.find("CW-30") == -1, "dado file code stayed up inside The bridle")
	_press(root, "Wend")
	_press(root, "Router")
	_press(root, "88")
	_press(root, "Submit theory")
	var bridle_again := _verdict_text(root)
	_expect(bridle_again.find("fits every exhibit") >= 0, "bridle board rejected the true theory after The dado: %s" % bridle_again)
	_expect(bridle_again.find("Wend (router hand) cut the bridle in the router at 88") >= 0, "bridle board timeline after The dado: %s" % bridle_again)
	var bridle_again_blob := _visible_label_blob(root)
	_expect(bridle_again_blob.find("Router chit") >= 0, "bridle papers left after returning")
	_expect(bridle_again_blob.find("Plough chit") == -1, "dado papers stayed up after returning to The bridle")
	_expect(bridle_again_blob.find("Groove note") == -1, "dado papers stayed up after returning to The bridle")
	_press(root, "Menu")
	_press(root, "Open The spline")
	var spline_open := _visible_label_blob(root)
	_expect(spline_open.find("Slot chit") >= 0, "spline file did not open")
	_expect(spline_open.find("Slot note") >= 0, "spline file did not show its exhibits")
	_expect(spline_open.find("CW-31") >= 0, "spline file omits CW-31")
	_expect(spline_open.find("Feather hook") >= 0, "spline file omits Feather hook")
	_expect(spline_open.find("Cheek slip") >= 0, "spline file omits Cheek slip")
	_expect(spline_open.find("Slot leaf") >= 0, "spline file omits Slot leaf")
	_expect(spline_open.find("Dry order") >= 0, "spline file omits Dry order")
	_expect(spline_open.find("Complaint slip") == -1, "spare key papers showed inside The spline")
	_expect(spline_open.find("Cut list") == -1, "rehearsal papers showed inside The spline")
	_expect(spline_open.find("Move order") == -1, "gilt stamp papers showed inside The spline")
	_expect(spline_open.find("Whistle slip") == -1, "ferry bell papers showed inside The spline")
	_expect(spline_open.find("Frost note") == -1, "weather slate papers showed inside The spline")
	_expect(spline_open.find("Trough tag") == -1, "loom shuttle papers showed inside The spline")
	_expect(spline_open.find("Fuel line") == -1, "hive smoker papers showed inside The spline")
	_expect(spline_open.find("Weight line") == -1, "glass pontil papers showed inside The spline")
	_expect(spline_open.find("Lock line") == -1, "press proof papers showed inside The spline")
	_expect(spline_open.find("Cup line") == -1, "assay cup papers showed inside The spline")
	_expect(spline_open.find("Mark line") == -1, "kiln chalk papers showed inside The spline")
	_expect(spline_open.find("Ledger line") == -1, "tide ledger papers showed inside The spline")
	_expect(spline_open.find("Bell line") == -1, "night bell papers showed inside The spline")
	_expect(spline_open.find("Salt line") == -1, "salt mark papers showed inside The spline")
	_expect(spline_open.find("Oil note") == -1, "wick trim papers showed inside The spline")
	_expect(spline_open.find("Gather note") == -1, "glass anneal papers showed inside The spline")
	_expect(spline_open.find("Scion note") == -1, "orchard graft papers showed inside The spline")
	_expect(spline_open.find("Winder chit") == -1, "dye vat papers showed inside The spline")
	_expect(spline_open.find("Rope chit") == -1, "tar kettle papers showed inside The spline")
	_expect(spline_open.find("Cutter chit") == -1, "cork press papers showed inside The spline")
	_expect(spline_open.find("Mesh chit") == -1, "net loft papers showed inside The spline")
	_expect(spline_open.find("Hoop chit") == -1, "cask hoop papers showed inside The spline")
	_expect(spline_open.find("Shears chit") == -1, "linen fold papers showed inside The spline")
	_expect(spline_open.find("Apron sight") == -1, "dovetail papers showed inside The spline")
	_expect(spline_open.find("Peg hook") == -1, "dovetail papers showed inside The spline")
	_expect(spline_open.find("Joint slate") == -1, "dovetail papers showed inside The spline")
	_expect(spline_open.find("Clamp card") == -1, "dovetail papers showed inside The spline")
	_expect(spline_open.find("Sweep slip") == -1, "dovetail papers showed inside The spline")
	_expect(spline_open.find("Cut leaf") == -1, "dovetail papers showed inside The spline")
	_expect(spline_open.find("Joint note") == -1, "dovetail papers showed inside The spline")
	_expect(spline_open.find("Jaw order") == -1, "dovetail papers showed inside The spline")
	_expect(spline_open.find("CW-24") == -1, "dovetail file code stayed up inside The spline")
	_expect(spline_open.find("Chisel chit") == -1, "mortise papers stayed up inside The spline")
	_expect(spline_open.find("Awl sight") == -1, "mortise papers showed inside The spline")
	_expect(spline_open.find("Wedge hook") == -1, "mortise papers showed inside The spline")
	_expect(spline_open.find("Tenon slate") == -1, "mortise papers showed inside The spline")
	_expect(spline_open.find("Brace card") == -1, "mortise papers showed inside The spline")
	_expect(spline_open.find("Brush slip") == -1, "mortise papers showed inside The spline")
	_expect(spline_open.find("Bore leaf") == -1, "mortise papers showed inside The spline")
	_expect(spline_open.find("Tenon note") == -1, "mortise papers showed inside The spline")
	_expect(spline_open.find("Rack order") == -1, "mortise papers showed inside The spline")
	_expect(spline_open.find("CW-25") == -1, "mortise file code stayed up inside The spline")
	_expect(spline_open.find("Plane chit") == -1, "rebate papers stayed up inside The spline")
	_expect(spline_open.find("Gauge sight") == -1, "rebate papers showed inside The spline")
	_expect(spline_open.find("Shim hook") == -1, "rebate papers showed inside The spline")
	_expect(spline_open.find("Shoulder slate") == -1, "rebate papers showed inside The spline")
	_expect(spline_open.find("Fence card") == -1, "rebate papers showed inside The spline")
	_expect(spline_open.find("Oil slip") == -1, "rebate papers showed inside The spline")
	_expect(spline_open.find("Scribe leaf") == -1, "rebate papers showed inside The spline")
	_expect(spline_open.find("Shoulder note") == -1, "rebate papers showed inside The spline")
	_expect(spline_open.find("CW-26") == -1, "rebate file code stayed up inside The spline")
	_expect(spline_open.find("Saw chit") == -1, "housing papers stayed up inside The spline")
	_expect(spline_open.find("Square sight") == -1, "housing papers showed inside The spline")
	_expect(spline_open.find("Fillet hook") == -1, "housing papers showed inside The spline")
	_expect(spline_open.find("Trench slate") == -1, "housing papers showed inside The spline")
	_expect(spline_open.find("Stock card") == -1, "housing papers showed inside The spline")
	_expect(spline_open.find("Chalk slip") == -1, "housing papers showed inside The spline")
	_expect(spline_open.find("Mark leaf") == -1, "housing papers showed inside The spline")
	_expect(spline_open.find("Trench note") == -1, "housing papers showed inside The spline")
	_expect(spline_open.find("CW-27") == -1, "housing file code stayed up inside The spline")
	_expect(spline_open.find("Gouge chit") == -1, "tenon papers stayed up inside The spline")
	_expect(spline_open.find("Rasp sight") == -1, "tenon papers showed inside The spline")
	_expect(spline_open.find("Dowel hook") == -1, "tenon papers showed inside The spline")
	_expect(spline_open.find("Haunch slate") == -1, "tenon papers showed inside The spline")
	_expect(spline_open.find("Guide card") == -1, "tenon papers showed inside The spline")
	_expect(spline_open.find("Hone slip") == -1, "tenon papers showed inside The spline")
	_expect(spline_open.find("Nick leaf") == -1, "tenon papers showed inside The spline")
	_expect(spline_open.find("Haunch note") == -1, "tenon papers showed inside The spline")
	_expect(spline_open.find("CW-28") == -1, "tenon file code stayed up inside The spline")
	_expect(spline_open.find("Router chit") == -1, "bridle papers stayed up inside The spline")
	_expect(spline_open.find("Scraper sight") == -1, "bridle papers showed inside The spline")
	_expect(spline_open.find("Spline hook") == -1, "bridle papers showed inside The spline")
	_expect(spline_open.find("Tongue slate") == -1, "bridle papers showed inside The spline")
	_expect(spline_open.find("Templet card") == -1, "bridle papers showed inside The spline")
	_expect(spline_open.find("Strop slip") == -1, "bridle papers showed inside The spline")
	_expect(spline_open.find("Notch leaf") == -1, "bridle papers showed inside The spline")
	_expect(spline_open.find("Tongue note") == -1, "bridle papers showed inside The spline")
	_expect(spline_open.find("CW-29") == -1, "bridle file code stayed up inside The spline")
	_expect(spline_open.find("Plough chit") == -1, "dado papers stayed up inside The spline")
	_expect(spline_open.find("Float sight") == -1, "dado papers showed inside The spline")
	_expect(spline_open.find("Cleat hook") == -1, "dado papers showed inside The spline")
	_expect(spline_open.find("Groove slate") == -1, "dado papers showed inside The spline")
	_expect(spline_open.find("Spur card") == -1, "dado papers showed inside The spline")
	_expect(spline_open.find("Whet slip") == -1, "dado papers showed inside The spline")
	_expect(spline_open.find("Score leaf") == -1, "dado papers showed inside The spline")
	_expect(spline_open.find("Groove note") == -1, "dado papers showed inside The spline")
	_expect(spline_open.find("CW-30") == -1, "dado file code stayed up inside The spline")
	_press(root, "Submit theory")
	var empty_spline := _verdict_text(root)
	_expect(empty_spline.find("who cut the spline") >= 0, "empty spline board: %s" % empty_spline)
	_expect(empty_spline.find("where they cut the spline") >= 0, "empty spline board: %s" % empty_spline)
	_expect(empty_spline.find("at which hour they cut the spline") >= 0, "empty spline board: %s" % empty_spline)
	_expect(empty_spline.find("who took the spare key") == -1, "empty spline board used the spare key slot: %s" % empty_spline)
	_expect(empty_spline.find("who cut the dado") == -1, "empty spline board used a dado slot: %s" % empty_spline)
	_expect(empty_spline.to_lower().find("conflict") == -1, "empty spline board talked about a conflict: %s" % empty_spline)
	_press(root, "Voss")
	_press(root, "Float")
	_press(root, "96")
	_press(root, "Submit theory")
	var spline_miss := _verdict_text(root)
	_expect_reply_names_conflicts(spline_miss, Spline, {"who": "Voss", "place": "float", "hour": "96"})
	_expect(Spline.conflicting_ids({"who": "Voss", "place": "float", "hour": "96"}).size() == 9, "Voss / float / 96 should contradict every exhibit")
	_expect(spline_miss.find("Slot chit") >= 0, "wrong triple reply omits Slot chit: %s" % spline_miss)
	_expect(spline_miss.find("Rest sight") >= 0, "wrong triple reply omits Rest sight: %s" % spline_miss)
	_expect(spline_miss.find("Feather hook") >= 0, "wrong triple reply omits Feather hook: %s" % spline_miss)
	_expect(spline_miss.find("Slot slate") >= 0, "wrong triple reply omits Slot slate: %s" % spline_miss)
	_expect(spline_miss.find("Key card") >= 0, "wrong triple reply omits Key card: %s" % spline_miss)
	_expect(spline_miss.find("Cheek slip") >= 0, "wrong triple reply omits Cheek slip: %s" % spline_miss)
	_expect(spline_miss.find("Slot leaf") >= 0, "wrong triple reply omits Slot leaf: %s" % spline_miss)
	_expect(spline_miss.find("Slot note") >= 0, "wrong triple reply omits Slot note: %s" % spline_miss)
	_expect(spline_miss.find("Dry order") >= 0, "wrong triple reply omits Dry order: %s" % spline_miss)
	_press(root, "Senn")
	_press(root, "Plough")
	_press(root, "98")
	_press(root, "Submit theory")
	var spline_accepted := _verdict_text(root)
	_expect(spline_accepted.find("fits every exhibit") >= 0, "spline board rejected the true theory: %s" % spline_accepted)
	_expect(spline_accepted.find(SPLINE_TIMELINE) >= 0, "spline board timeline: %s" % spline_accepted)
	_expect(spline_accepted.find("Senn (vise hand) cut the spline in the plough at 98") >= 0, "spline board omits Senn at 98: %s" % spline_accepted)
	_expect(spline_accepted.find("in the plough") >= 0, "spline board omits the plough: %s" % spline_accepted)
	_expect(spline_accepted.find("so the tongue would take the slot") >= 0, "spline board omits the slot: %s" % spline_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var spline_cleared := _verdict_text(root)
	_expect(spline_cleared.find("who cut the spline") >= 0, "cleared spline board: %s" % spline_cleared)
	_expect(spline_cleared.find("fits every exhibit") == -1, "cleared spline board stayed accepted: %s" % spline_cleared)
	_press(root, "Menu")
	_press(root, "Open The dado")
	var dado_from_spline := _visible_label_blob(root)
	_expect(dado_from_spline.find("Plough chit") >= 0, "could not return to The dado from The spline")
	_expect(dado_from_spline.find("Groove note") >= 0, "dado exhibits did not return")
	_expect(dado_from_spline.find("CW-30") >= 0, "returned dado omits CW-30")
	_expect(dado_from_spline.find("Slot chit") == -1, "spline papers stayed up inside The dado")
	_expect(dado_from_spline.find("Rest sight") == -1, "spline papers showed inside The dado")
	_expect(dado_from_spline.find("Feather hook") == -1, "spline papers showed inside The dado")
	_expect(dado_from_spline.find("Slot slate") == -1, "spline papers showed inside The dado")
	_expect(dado_from_spline.find("Key card") == -1, "spline papers showed inside The dado")
	_expect(dado_from_spline.find("Cheek slip") == -1, "spline papers showed inside The dado")
	_expect(dado_from_spline.find("Slot leaf") == -1, "spline papers showed inside The dado")
	_expect(dado_from_spline.find("Slot note") == -1, "spline papers showed inside The dado")
	_expect(dado_from_spline.find("CW-31") == -1, "spline file code stayed up inside The dado")
	_press(root, "Kern")
	_press(root, "Plough")
	_press(root, "93")
	_press(root, "Submit theory")
	var dado_again := _verdict_text(root)
	_expect(dado_again.find("fits every exhibit") >= 0, "dado board rejected the true theory after The spline: %s" % dado_again)
	_expect(dado_again.find("Kern (plough hand) cut the dado in the plough at 93") >= 0, "dado board timeline after The spline: %s" % dado_again)
	var dado_again_blob := _visible_label_blob(root)
	_expect(dado_again_blob.find("Plough chit") >= 0, "dado papers left after returning")
	_expect(dado_again_blob.find("Slot chit") == -1, "spline papers stayed up after returning to The dado")
	_expect(dado_again_blob.find("Slot note") == -1, "spline papers stayed up after returning to The dado")
	_press(root, "Menu")
	_press(root, "Open The mitre")
	var mitre_open := _visible_label_blob(root)
	_expect(mitre_open.find("Arris chit") >= 0, "mitre file did not open")
	_expect(mitre_open.find("Arris note") >= 0, "mitre file did not show its exhibits")
	_expect(mitre_open.find("CW-32") >= 0, "mitre file omits CW-32")
	_expect(mitre_open.find("Offcut hook") >= 0, "mitre file omits Offcut hook")
	_expect(mitre_open.find("Dress slip") >= 0, "mitre file omits Dress slip")
	_expect(mitre_open.find("Arris leaf") >= 0, "mitre file omits Arris leaf")
	_expect(mitre_open.find("Brush order") >= 0, "mitre file omits Brush order")
	_expect(mitre_open.find("Complaint slip") == -1, "spare key papers showed inside The mitre")
	_expect(mitre_open.find("Cut list") == -1, "rehearsal papers showed inside The mitre")
	_expect(mitre_open.find("Move order") == -1, "gilt stamp papers showed inside The mitre")
	_expect(mitre_open.find("Whistle slip") == -1, "ferry bell papers showed inside The mitre")
	_expect(mitre_open.find("Frost note") == -1, "weather slate papers showed inside The mitre")
	_expect(mitre_open.find("Trough tag") == -1, "loom shuttle papers showed inside The mitre")
	_expect(mitre_open.find("Fuel line") == -1, "hive smoker papers showed inside The mitre")
	_expect(mitre_open.find("Weight line") == -1, "glass pontil papers showed inside The mitre")
	_expect(mitre_open.find("Lock line") == -1, "press proof papers showed inside The mitre")
	_expect(mitre_open.find("Cup line") == -1, "assay cup papers showed inside The mitre")
	_expect(mitre_open.find("Mark line") == -1, "kiln chalk papers showed inside The mitre")
	_expect(mitre_open.find("Ledger line") == -1, "tide ledger papers showed inside The mitre")
	_expect(mitre_open.find("Bell line") == -1, "night bell papers showed inside The mitre")
	_expect(mitre_open.find("Salt line") == -1, "salt mark papers showed inside The mitre")
	_expect(mitre_open.find("Oil note") == -1, "wick trim papers showed inside The mitre")
	_expect(mitre_open.find("Gather note") == -1, "glass anneal papers showed inside The mitre")
	_expect(mitre_open.find("Scion note") == -1, "orchard graft papers showed inside The mitre")
	_expect(mitre_open.find("Winder chit") == -1, "dye vat papers showed inside The mitre")
	_expect(mitre_open.find("Rope chit") == -1, "tar kettle papers showed inside The mitre")
	_expect(mitre_open.find("Cutter chit") == -1, "cork press papers showed inside The mitre")
	_expect(mitre_open.find("Mesh chit") == -1, "net loft papers showed inside The mitre")
	_expect(mitre_open.find("Hoop chit") == -1, "cask hoop papers showed inside The mitre")
	_expect(mitre_open.find("Shears chit") == -1, "linen fold papers showed inside The mitre")
	_expect(mitre_open.find("Apron sight") == -1, "dovetail papers showed inside The mitre")
	_expect(mitre_open.find("Peg hook") == -1, "dovetail papers showed inside The mitre")
	_expect(mitre_open.find("Joint slate") == -1, "dovetail papers showed inside The mitre")
	_expect(mitre_open.find("Clamp card") == -1, "dovetail papers showed inside The mitre")
	_expect(mitre_open.find("Sweep slip") == -1, "dovetail papers showed inside The mitre")
	_expect(mitre_open.find("Cut leaf") == -1, "dovetail papers showed inside The mitre")
	_expect(mitre_open.find("Joint note") == -1, "dovetail papers showed inside The mitre")
	_expect(mitre_open.find("Jaw order") == -1, "dovetail papers showed inside The mitre")
	_expect(mitre_open.find("CW-24") == -1, "dovetail file code stayed up inside The mitre")
	_expect(mitre_open.find("Chisel chit") == -1, "mortise papers stayed up inside The mitre")
	_expect(mitre_open.find("Awl sight") == -1, "mortise papers showed inside The mitre")
	_expect(mitre_open.find("Wedge hook") == -1, "mortise papers showed inside The mitre")
	_expect(mitre_open.find("Tenon slate") == -1, "mortise papers showed inside The mitre")
	_expect(mitre_open.find("Brace card") == -1, "mortise papers showed inside The mitre")
	_expect(mitre_open.find("Brush slip") == -1, "mortise papers showed inside The mitre")
	_expect(mitre_open.find("Bore leaf") == -1, "mortise papers showed inside The mitre")
	_expect(mitre_open.find("Tenon note") == -1, "mortise papers showed inside The mitre")
	_expect(mitre_open.find("Rack order") == -1, "mortise papers showed inside The mitre")
	_expect(mitre_open.find("CW-25") == -1, "mortise file code stayed up inside The mitre")
	_expect(mitre_open.find("Plane chit") == -1, "rebate papers stayed up inside The mitre")
	_expect(mitre_open.find("Gauge sight") == -1, "rebate papers showed inside The mitre")
	_expect(mitre_open.find("Shim hook") == -1, "rebate papers showed inside The mitre")
	_expect(mitre_open.find("Shoulder slate") == -1, "rebate papers showed inside The mitre")
	_expect(mitre_open.find("Fence card") == -1, "rebate papers showed inside The mitre")
	_expect(mitre_open.find("Oil slip") == -1, "rebate papers showed inside The mitre")
	_expect(mitre_open.find("Scribe leaf") == -1, "rebate papers showed inside The mitre")
	_expect(mitre_open.find("Shoulder note") == -1, "rebate papers showed inside The mitre")
	_expect(mitre_open.find("CW-26") == -1, "rebate file code stayed up inside The mitre")
	_expect(mitre_open.find("Saw chit") == -1, "housing papers stayed up inside The mitre")
	_expect(mitre_open.find("Square sight") == -1, "housing papers showed inside The mitre")
	_expect(mitre_open.find("Fillet hook") == -1, "housing papers showed inside The mitre")
	_expect(mitre_open.find("Trench slate") == -1, "housing papers showed inside The mitre")
	_expect(mitre_open.find("Stock card") == -1, "housing papers showed inside The mitre")
	_expect(mitre_open.find("Chalk slip") == -1, "housing papers showed inside The mitre")
	_expect(mitre_open.find("Mark leaf") == -1, "housing papers showed inside The mitre")
	_expect(mitre_open.find("Trench note") == -1, "housing papers showed inside The mitre")
	_expect(mitre_open.find("CW-27") == -1, "housing file code stayed up inside The mitre")
	_expect(mitre_open.find("Gouge chit") == -1, "tenon papers stayed up inside The mitre")
	_expect(mitre_open.find("Rasp sight") == -1, "tenon papers showed inside The mitre")
	_expect(mitre_open.find("Dowel hook") == -1, "tenon papers showed inside The mitre")
	_expect(mitre_open.find("Haunch slate") == -1, "tenon papers showed inside The mitre")
	_expect(mitre_open.find("Guide card") == -1, "tenon papers showed inside The mitre")
	_expect(mitre_open.find("Hone slip") == -1, "tenon papers showed inside The mitre")
	_expect(mitre_open.find("Nick leaf") == -1, "tenon papers showed inside The mitre")
	_expect(mitre_open.find("Haunch note") == -1, "tenon papers showed inside The mitre")
	_expect(mitre_open.find("CW-28") == -1, "tenon file code stayed up inside The mitre")
	_expect(mitre_open.find("Router chit") == -1, "bridle papers stayed up inside The mitre")
	_expect(mitre_open.find("Scraper sight") == -1, "bridle papers showed inside The mitre")
	_expect(mitre_open.find("Spline hook") == -1, "bridle papers showed inside The mitre")
	_expect(mitre_open.find("Tongue slate") == -1, "bridle papers showed inside The mitre")
	_expect(mitre_open.find("Templet card") == -1, "bridle papers showed inside The mitre")
	_expect(mitre_open.find("Strop slip") == -1, "bridle papers showed inside The mitre")
	_expect(mitre_open.find("Notch leaf") == -1, "bridle papers showed inside The mitre")
	_expect(mitre_open.find("Tongue note") == -1, "bridle papers showed inside The mitre")
	_expect(mitre_open.find("CW-29") == -1, "bridle file code stayed up inside The mitre")
	_expect(mitre_open.find("Plough chit") == -1, "dado papers stayed up inside The mitre")
	_expect(mitre_open.find("Float sight") == -1, "dado papers showed inside The mitre")
	_expect(mitre_open.find("Cleat hook") == -1, "dado papers showed inside The mitre")
	_expect(mitre_open.find("Groove slate") == -1, "dado papers showed inside The mitre")
	_expect(mitre_open.find("Spur card") == -1, "dado papers showed inside The mitre")
	_expect(mitre_open.find("Whet slip") == -1, "dado papers showed inside The mitre")
	_expect(mitre_open.find("Score leaf") == -1, "dado papers showed inside The mitre")
	_expect(mitre_open.find("Groove note") == -1, "dado papers showed inside The mitre")
	_expect(mitre_open.find("CW-30") == -1, "dado file code stayed up inside The mitre")
	_expect(mitre_open.find("Slot chit") == -1, "spline papers stayed up inside The mitre")
	_expect(mitre_open.find("Rest sight") == -1, "spline papers showed inside The mitre")
	_expect(mitre_open.find("Feather hook") == -1, "spline papers showed inside The mitre")
	_expect(mitre_open.find("Slot slate") == -1, "spline papers showed inside The mitre")
	_expect(mitre_open.find("Key card") == -1, "spline papers showed inside The mitre")
	_expect(mitre_open.find("Cheek slip") == -1, "spline papers showed inside The mitre")
	_expect(mitre_open.find("Slot leaf") == -1, "spline papers showed inside The mitre")
	_expect(mitre_open.find("Slot note") == -1, "spline papers showed inside The mitre")
	_expect(mitre_open.find("Dry order") == -1, "spline papers showed inside The mitre")
	_expect(mitre_open.find("CW-31") == -1, "spline file code stayed up inside The mitre")
	_press(root, "Submit theory")
	var empty_mitre := _verdict_text(root)
	_expect(empty_mitre.find("who cut the mitre") >= 0, "empty mitre board: %s" % empty_mitre)
	_expect(empty_mitre.find("where they cut the mitre") >= 0, "empty mitre board: %s" % empty_mitre)
	_expect(empty_mitre.find("at which hour they cut the mitre") >= 0, "empty mitre board: %s" % empty_mitre)
	_expect(empty_mitre.find("who took the spare key") == -1, "empty mitre board used the spare key slot: %s" % empty_mitre)
	_expect(empty_mitre.find("who cut the spline") == -1, "empty mitre board used a spline slot: %s" % empty_mitre)
	_expect(empty_mitre.to_lower().find("conflict") == -1, "empty mitre board talked about a conflict: %s" % empty_mitre)
	_press(root, "Venn")
	_press(root, "Float")
	_press(root, "101")
	_press(root, "Submit theory")
	var mitre_miss := _verdict_text(root)
	_expect_reply_names_conflicts(mitre_miss, Mitre, {"who": "Venn", "place": "float", "hour": "101"})
	_expect(Mitre.conflicting_ids({"who": "Venn", "place": "float", "hour": "101"}).size() == 9, "Venn / float / 101 should contradict every exhibit")
	_expect(mitre_miss.find("Arris chit") >= 0, "wrong triple reply omits Arris chit: %s" % mitre_miss)
	_expect(mitre_miss.find("Horn sight") >= 0, "wrong triple reply omits Horn sight: %s" % mitre_miss)
	_expect(mitre_miss.find("Offcut hook") >= 0, "wrong triple reply omits Offcut hook: %s" % mitre_miss)
	_expect(mitre_miss.find("Arris slate") >= 0, "wrong triple reply omits Arris slate: %s" % mitre_miss)
	_expect(mitre_miss.find("Stop card") >= 0, "wrong triple reply omits Stop card: %s" % mitre_miss)
	_expect(mitre_miss.find("Dress slip") >= 0, "wrong triple reply omits Dress slip: %s" % mitre_miss)
	_expect(mitre_miss.find("Arris leaf") >= 0, "wrong triple reply omits Arris leaf: %s" % mitre_miss)
	_expect(mitre_miss.find("Arris note") >= 0, "wrong triple reply omits Arris note: %s" % mitre_miss)
	_expect(mitre_miss.find("Brush order") >= 0, "wrong triple reply omits Brush order: %s" % mitre_miss)
	_press(root, "Orrin")
	_press(root, "Plough")
	_press(root, "103")
	_press(root, "Submit theory")
	var mitre_accepted := _verdict_text(root)
	_expect(mitre_accepted.find("fits every exhibit") >= 0, "mitre board rejected the true theory: %s" % mitre_accepted)
	_expect(mitre_accepted.find(MITRE_TIMELINE) >= 0, "mitre board timeline: %s" % mitre_accepted)
	_expect(mitre_accepted.find("Orrin (saddle hand) cut the mitre in the plough at 103") >= 0, "mitre board omits Orrin at 103: %s" % mitre_accepted)
	_expect(mitre_accepted.find("in the plough") >= 0, "mitre board omits the plough: %s" % mitre_accepted)
	_expect(mitre_accepted.find("so the arris would take the mitre") >= 0, "mitre board omits the arris: %s" % mitre_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var mitre_cleared := _verdict_text(root)
	_expect(mitre_cleared.find("who cut the mitre") >= 0, "cleared mitre board: %s" % mitre_cleared)
	_expect(mitre_cleared.find("fits every exhibit") == -1, "cleared mitre board stayed accepted: %s" % mitre_cleared)
	_press(root, "Menu")
	_press(root, "Open The spline")
	var spline_from_mitre := _visible_label_blob(root)
	_expect(spline_from_mitre.find("Slot chit") >= 0, "could not return to The spline from The mitre")
	_expect(spline_from_mitre.find("Slot note") >= 0, "spline exhibits did not return")
	_expect(spline_from_mitre.find("CW-31") >= 0, "returned spline omits CW-31")
	_expect(spline_from_mitre.find("Arris chit") == -1, "mitre papers stayed up inside The spline")
	_expect(spline_from_mitre.find("Horn sight") == -1, "mitre papers showed inside The spline")
	_expect(spline_from_mitre.find("Offcut hook") == -1, "mitre papers showed inside The spline")
	_expect(spline_from_mitre.find("Arris slate") == -1, "mitre papers showed inside The spline")
	_expect(spline_from_mitre.find("Stop card") == -1, "mitre papers showed inside The spline")
	_expect(spline_from_mitre.find("Dress slip") == -1, "mitre papers showed inside The spline")
	_expect(spline_from_mitre.find("Arris leaf") == -1, "mitre papers showed inside The spline")
	_expect(spline_from_mitre.find("Arris note") == -1, "mitre papers showed inside The spline")
	_expect(spline_from_mitre.find("CW-32") == -1, "mitre file code stayed up inside The spline")
	_press(root, "Senn")
	_press(root, "Plough")
	_press(root, "98")
	_press(root, "Submit theory")
	var spline_again := _verdict_text(root)
	_expect(spline_again.find("fits every exhibit") >= 0, "spline board rejected the true theory after The mitre: %s" % spline_again)
	_expect(spline_again.find("Senn (vise hand) cut the spline in the plough at 98") >= 0, "spline board timeline after The mitre: %s" % spline_again)
	var spline_again_blob := _visible_label_blob(root)
	_expect(spline_again_blob.find("Slot chit") >= 0, "spline papers left after returning")
	_expect(spline_again_blob.find("Arris chit") == -1, "mitre papers stayed up after returning to The spline")
	_expect(spline_again_blob.find("Arris note") == -1, "mitre papers stayed up after returning to The spline")
	_press(root, "Menu")
	_press(root, "Open The lap")
	var lap_open := _visible_label_blob(root)
	_expect(lap_open.find("Grain chit") >= 0, "lap file did not open")
	_expect(lap_open.find("Grain note") >= 0, "lap file did not show its exhibits")
	_expect(lap_open.find("CW-33") >= 0, "lap file omits CW-33")
	_expect(lap_open.find("Paring hook") >= 0, "lap file omits Paring hook")
	_expect(lap_open.find("Skim slip") >= 0, "lap file omits Skim slip")
	_expect(lap_open.find("Grain leaf") >= 0, "lap file omits Grain leaf")
	_expect(lap_open.find("Oil order") >= 0, "lap file omits Oil order")
	_expect(lap_open.find("Crest sight") >= 0, "lap file omits Crest sight")
	_expect(lap_open.find("Brad card") >= 0, "lap file omits Brad card")
	_expect(lap_open.find("Complaint slip") == -1, "spare key papers showed inside The lap")
	_expect(lap_open.find("Cut list") == -1, "rehearsal papers showed inside The lap")
	_expect(lap_open.find("Move order") == -1, "gilt stamp papers showed inside The lap")
	_expect(lap_open.find("Whistle slip") == -1, "ferry bell papers showed inside The lap")
	_expect(lap_open.find("Frost note") == -1, "weather slate papers showed inside The lap")
	_expect(lap_open.find("Trough tag") == -1, "loom shuttle papers showed inside The lap")
	_expect(lap_open.find("Fuel line") == -1, "hive smoker papers showed inside The lap")
	_expect(lap_open.find("Weight line") == -1, "glass pontil papers showed inside The lap")
	_expect(lap_open.find("Lock line") == -1, "press proof papers showed inside The lap")
	_expect(lap_open.find("Cup line") == -1, "assay cup papers showed inside The lap")
	_expect(lap_open.find("Mark line") == -1, "kiln chalk papers showed inside The lap")
	_expect(lap_open.find("Ledger line") == -1, "tide ledger papers showed inside The lap")
	_expect(lap_open.find("Bell line") == -1, "night bell papers showed inside The lap")
	_expect(lap_open.find("Salt line") == -1, "salt mark papers showed inside The lap")
	_expect(lap_open.find("Oil note") == -1, "wick trim papers showed inside The lap")
	_expect(lap_open.find("Gather note") == -1, "glass anneal papers showed inside The lap")
	_expect(lap_open.find("Scion note") == -1, "orchard graft papers showed inside The lap")
	_expect(lap_open.find("Winder chit") == -1, "dye vat papers showed inside The lap")
	_expect(lap_open.find("Rope chit") == -1, "tar kettle papers showed inside The lap")
	_expect(lap_open.find("Cutter chit") == -1, "cork press papers showed inside The lap")
	_expect(lap_open.find("Mesh chit") == -1, "net loft papers showed inside The lap")
	_expect(lap_open.find("Hoop chit") == -1, "cask hoop papers showed inside The lap")
	_expect(lap_open.find("Shears chit") == -1, "linen fold papers showed inside The lap")
	_expect(lap_open.find("Apron sight") == -1, "dovetail papers showed inside The lap")
	_expect(lap_open.find("Peg hook") == -1, "dovetail papers showed inside The lap")
	_expect(lap_open.find("Joint slate") == -1, "dovetail papers showed inside The lap")
	_expect(lap_open.find("Clamp card") == -1, "dovetail papers showed inside The lap")
	_expect(lap_open.find("Sweep slip") == -1, "dovetail papers showed inside The lap")
	_expect(lap_open.find("Cut leaf") == -1, "dovetail papers showed inside The lap")
	_expect(lap_open.find("Joint note") == -1, "dovetail papers showed inside The lap")
	_expect(lap_open.find("Jaw order") == -1, "dovetail papers showed inside The lap")
	_expect(lap_open.find("CW-24") == -1, "dovetail file code stayed up inside The lap")
	_expect(lap_open.find("Chisel chit") == -1, "mortise papers stayed up inside The lap")
	_expect(lap_open.find("Awl sight") == -1, "mortise papers showed inside The lap")
	_expect(lap_open.find("Wedge hook") == -1, "mortise papers showed inside The lap")
	_expect(lap_open.find("Tenon slate") == -1, "mortise papers showed inside The lap")
	_expect(lap_open.find("Brace card") == -1, "mortise papers showed inside The lap")
	_expect(lap_open.find("Brush slip") == -1, "mortise papers showed inside The lap")
	_expect(lap_open.find("Bore leaf") == -1, "mortise papers showed inside The lap")
	_expect(lap_open.find("Tenon note") == -1, "mortise papers showed inside The lap")
	_expect(lap_open.find("Rack order") == -1, "mortise papers showed inside The lap")
	_expect(lap_open.find("CW-25") == -1, "mortise file code stayed up inside The lap")
	_expect(lap_open.find("Plane chit") == -1, "rebate papers stayed up inside The lap")
	_expect(lap_open.find("Gauge sight") == -1, "rebate papers showed inside The lap")
	_expect(lap_open.find("Shim hook") == -1, "rebate papers showed inside The lap")
	_expect(lap_open.find("Shoulder slate") == -1, "rebate papers showed inside The lap")
	_expect(lap_open.find("Fence card") == -1, "rebate papers showed inside The lap")
	_expect(lap_open.find("Oil slip") == -1, "rebate papers showed inside The lap")
	_expect(lap_open.find("Scribe leaf") == -1, "rebate papers showed inside The lap")
	_expect(lap_open.find("Shoulder note") == -1, "rebate papers showed inside The lap")
	_expect(lap_open.find("CW-26") == -1, "rebate file code stayed up inside The lap")
	_expect(lap_open.find("Saw chit") == -1, "housing papers stayed up inside The lap")
	_expect(lap_open.find("Square sight") == -1, "housing papers showed inside The lap")
	_expect(lap_open.find("Fillet hook") == -1, "housing papers showed inside The lap")
	_expect(lap_open.find("Trench slate") == -1, "housing papers showed inside The lap")
	_expect(lap_open.find("Stock card") == -1, "housing papers showed inside The lap")
	_expect(lap_open.find("Chalk slip") == -1, "housing papers showed inside The lap")
	_expect(lap_open.find("Mark leaf") == -1, "housing papers showed inside The lap")
	_expect(lap_open.find("Trench note") == -1, "housing papers showed inside The lap")
	_expect(lap_open.find("CW-27") == -1, "housing file code stayed up inside The lap")
	_expect(lap_open.find("Gouge chit") == -1, "tenon papers stayed up inside The lap")
	_expect(lap_open.find("Rasp sight") == -1, "tenon papers showed inside The lap")
	_expect(lap_open.find("Dowel hook") == -1, "tenon papers showed inside The lap")
	_expect(lap_open.find("Haunch slate") == -1, "tenon papers showed inside The lap")
	_expect(lap_open.find("Guide card") == -1, "tenon papers showed inside The lap")
	_expect(lap_open.find("Hone slip") == -1, "tenon papers showed inside The lap")
	_expect(lap_open.find("Nick leaf") == -1, "tenon papers showed inside The lap")
	_expect(lap_open.find("Haunch note") == -1, "tenon papers showed inside The lap")
	_expect(lap_open.find("CW-28") == -1, "tenon file code stayed up inside The lap")
	_expect(lap_open.find("Router chit") == -1, "bridle papers stayed up inside The lap")
	_expect(lap_open.find("Scraper sight") == -1, "bridle papers showed inside The lap")
	_expect(lap_open.find("Spline hook") == -1, "bridle papers showed inside The lap")
	_expect(lap_open.find("Tongue slate") == -1, "bridle papers showed inside The lap")
	_expect(lap_open.find("Templet card") == -1, "bridle papers showed inside The lap")
	_expect(lap_open.find("Strop slip") == -1, "bridle papers showed inside The lap")
	_expect(lap_open.find("Notch leaf") == -1, "bridle papers showed inside The lap")
	_expect(lap_open.find("Tongue note") == -1, "bridle papers showed inside The lap")
	_expect(lap_open.find("CW-29") == -1, "bridle file code stayed up inside The lap")
	_expect(lap_open.find("Plough chit") == -1, "dado papers stayed up inside The lap")
	_expect(lap_open.find("Float sight") == -1, "dado papers showed inside The lap")
	_expect(lap_open.find("Cleat hook") == -1, "dado papers showed inside The lap")
	_expect(lap_open.find("Groove slate") == -1, "dado papers showed inside The lap")
	_expect(lap_open.find("Spur card") == -1, "dado papers showed inside The lap")
	_expect(lap_open.find("Whet slip") == -1, "dado papers showed inside The lap")
	_expect(lap_open.find("Score leaf") == -1, "dado papers showed inside The lap")
	_expect(lap_open.find("Groove note") == -1, "dado papers showed inside The lap")
	_expect(lap_open.find("CW-30") == -1, "dado file code stayed up inside The lap")
	_expect(lap_open.find("Slot chit") == -1, "spline papers stayed up inside The lap")
	_expect(lap_open.find("Rest sight") == -1, "spline papers showed inside The lap")
	_expect(lap_open.find("Feather hook") == -1, "spline papers showed inside The lap")
	_expect(lap_open.find("Slot slate") == -1, "spline papers showed inside The lap")
	_expect(lap_open.find("Key card") == -1, "spline papers showed inside The lap")
	_expect(lap_open.find("Cheek slip") == -1, "spline papers showed inside The lap")
	_expect(lap_open.find("Slot leaf") == -1, "spline papers showed inside The lap")
	_expect(lap_open.find("Slot note") == -1, "spline papers showed inside The lap")
	_expect(lap_open.find("Dry order") == -1, "spline papers showed inside The lap")
	_expect(lap_open.find("CW-31") == -1, "spline file code stayed up inside The lap")
	_expect(lap_open.find("Arris chit") == -1, "mitre papers stayed up inside The lap")
	_expect(lap_open.find("Horn sight") == -1, "mitre papers showed inside The lap")
	_expect(lap_open.find("Offcut hook") == -1, "mitre papers showed inside The lap")
	_expect(lap_open.find("Arris slate") == -1, "mitre papers showed inside The lap")
	_expect(lap_open.find("Stop card") == -1, "mitre papers showed inside The lap")
	_expect(lap_open.find("Dress slip") == -1, "mitre papers showed inside The lap")
	_expect(lap_open.find("Arris leaf") == -1, "mitre papers showed inside The lap")
	_expect(lap_open.find("Arris note") == -1, "mitre papers showed inside The lap")
	_expect(lap_open.find("Brush order") == -1, "mitre papers showed inside The lap")
	_expect(lap_open.find("CW-32") == -1, "mitre file code stayed up inside The lap")
	_press(root, "Submit theory")
	var empty_lap := _verdict_text(root)
	_expect(empty_lap.find("who cut the lap") >= 0, "empty lap board: %s" % empty_lap)
	_expect(empty_lap.find("where they cut the lap") >= 0, "empty lap board: %s" % empty_lap)
	_expect(empty_lap.find("at which hour they cut the lap") >= 0, "empty lap board: %s" % empty_lap)
	_expect(empty_lap.find("who took the spare key") == -1, "empty lap board used the spare key slot: %s" % empty_lap)
	_expect(empty_lap.find("who cut the mitre") == -1, "empty lap board used a mitre slot: %s" % empty_lap)
	_expect(empty_lap.to_lower().find("conflict") == -1, "empty lap board talked about a conflict: %s" % empty_lap)
	_press(root, "Yew")
	_press(root, "Float")
	_press(root, "106")
	_press(root, "Submit theory")
	var lap_miss := _verdict_text(root)
	_expect_reply_names_conflicts(lap_miss, Lap, {"who": "Yew", "place": "float", "hour": "106"})
	_expect(Lap.conflicting_ids({"who": "Yew", "place": "float", "hour": "106"}).size() == 9, "Yew / float / 106 should contradict every exhibit")
	_expect(lap_miss.find("Grain chit") >= 0, "wrong triple reply omits Grain chit: %s" % lap_miss)
	_expect(lap_miss.find("Crest sight") >= 0, "wrong triple reply omits Crest sight: %s" % lap_miss)
	_expect(lap_miss.find("Paring hook") >= 0, "wrong triple reply omits Paring hook: %s" % lap_miss)
	_expect(lap_miss.find("Grain slate") >= 0, "wrong triple reply omits Grain slate: %s" % lap_miss)
	_expect(lap_miss.find("Brad card") >= 0, "wrong triple reply omits Brad card: %s" % lap_miss)
	_expect(lap_miss.find("Skim slip") >= 0, "wrong triple reply omits Skim slip: %s" % lap_miss)
	_expect(lap_miss.find("Grain leaf") >= 0, "wrong triple reply omits Grain leaf: %s" % lap_miss)
	_expect(lap_miss.find("Grain note") >= 0, "wrong triple reply omits Grain note: %s" % lap_miss)
	_expect(lap_miss.find("Oil order") >= 0, "wrong triple reply omits Oil order: %s" % lap_miss)
	_press(root, "Nye")
	_press(root, "Plough")
	_press(root, "108")
	_press(root, "Submit theory")
	var lap_accepted := _verdict_text(root)
	_expect(lap_accepted.find("fits every exhibit") >= 0, "lap board rejected the true theory: %s" % lap_accepted)
	_expect(lap_accepted.find(LAP_TIMELINE) >= 0, "lap board timeline: %s" % lap_accepted)
	_expect(lap_accepted.find("Nye (cradle hand) cut the lap in the plough at 108") >= 0, "lap board omits Nye at 108: %s" % lap_accepted)
	_expect(lap_accepted.find("in the plough") >= 0, "lap board omits the plough: %s" % lap_accepted)
	_expect(lap_accepted.find("so the grain would take the lap") >= 0, "lap board omits the grain: %s" % lap_accepted)
	_press(root, "Clear")
	_press(root, "Submit theory")
	var lap_cleared := _verdict_text(root)
	_expect(lap_cleared.find("who cut the lap") >= 0, "cleared lap board: %s" % lap_cleared)
	_expect(lap_cleared.find("fits every exhibit") == -1, "cleared lap board stayed accepted: %s" % lap_cleared)
	_press(root, "Menu")
	_press(root, "Open The mitre")
	var mitre_from_lap := _visible_label_blob(root)
	_expect(mitre_from_lap.find("Arris chit") >= 0, "could not return to The mitre from The lap")
	_expect(mitre_from_lap.find("Arris note") >= 0, "mitre exhibits did not return")
	_expect(mitre_from_lap.find("CW-32") >= 0, "returned mitre omits CW-32")
	_expect(mitre_from_lap.find("Grain chit") == -1, "lap papers stayed up inside The mitre")
	_expect(mitre_from_lap.find("Crest sight") == -1, "lap papers showed inside The mitre")
	_expect(mitre_from_lap.find("Paring hook") == -1, "lap papers showed inside The mitre")
	_expect(mitre_from_lap.find("Grain slate") == -1, "lap papers showed inside The mitre")
	_expect(mitre_from_lap.find("Brad card") == -1, "lap papers showed inside The mitre")
	_expect(mitre_from_lap.find("Skim slip") == -1, "lap papers showed inside The mitre")
	_expect(mitre_from_lap.find("Grain leaf") == -1, "lap papers showed inside The mitre")
	_expect(mitre_from_lap.find("Grain note") == -1, "lap papers showed inside The mitre")
	_expect(mitre_from_lap.find("Oil order") == -1, "lap papers showed inside The mitre")
	_expect(mitre_from_lap.find("CW-33") == -1, "lap file code stayed up inside The mitre")
	_press(root, "Orrin")
	_press(root, "Plough")
	_press(root, "103")
	_press(root, "Submit theory")
	var mitre_again := _verdict_text(root)
	_expect(mitre_again.find("fits every exhibit") >= 0, "mitre board rejected the true theory after The lap: %s" % mitre_again)
	_expect(mitre_again.find("Orrin (saddle hand) cut the mitre in the plough at 103") >= 0, "mitre board timeline after The lap: %s" % mitre_again)
	var mitre_again_blob := _visible_label_blob(root)
	_expect(mitre_again_blob.find("Arris chit") >= 0, "mitre papers left after returning")
	_expect(mitre_again_blob.find("Grain chit") == -1, "lap papers stayed up after returning to The mitre")
	_expect(mitre_again_blob.find("Grain note") == -1, "lap papers stayed up after returning to The mitre")
	_press(root, "Menu")
	_menu_root = root


func _expect_open_buttons_fit_the_case_window() -> void:
	var root := _menu_root
	_expect(root != null, "menu root was not kept for the file list")
	if root == null:
		return
	var mortise := _find_visible_button(root, "Open The mortise")
	var rebate := _find_visible_button(root, "Open The rebate")
	var housing := _find_visible_button(root, "Open The housing")
	var tenon := _find_visible_button(root, "Open The tenon")
	var bridle := _find_visible_button(root, "Open The bridle")
	var dado := _find_visible_button(root, "Open The dado")
	var spline := _find_visible_button(root, "Open The spline")
	var mitre := _find_visible_button(root, "Open The mitre")
	var lap := _find_visible_button(root, "Open The lap")
	_expect(mortise != null and rebate != null and housing != null and tenon != null and bridle != null and dado != null and spline != null and mitre != null and lap != null, "file list is missing a joiner button")
	if mortise == null or rebate == null or housing == null or tenon == null or bridle == null or dado == null or spline == null or mitre == null or lap == null:
		return
	var mortise_rect := _content_rect(mortise)
	var rebate_rect := _content_rect(rebate)
	var housing_rect := _content_rect(housing)
	var tenon_rect := _content_rect(tenon)
	var bridle_rect := _content_rect(bridle)
	var dado_rect := _content_rect(dado)
	var spline_rect := _content_rect(spline)
	var mitre_rect := _content_rect(mitre)
	var lap_rect := _content_rect(lap)
	print("file list mortise %s rebate %s housing %s tenon %s bridle %s dado %s spline %s mitre %s lap %s" % [mortise_rect, rebate_rect, housing_rect, tenon_rect, bridle_rect, dado_rect, spline_rect, mitre_rect, lap_rect])
	_expect(rebate_rect.size.y >= 40.0, "Open The rebate has no height")
	_expect(housing_rect.size.y >= 40.0, "Open The housing has no height")
	_expect(tenon_rect.size.y >= 40.0, "Open The tenon has no height")
	_expect(bridle_rect.size.y >= 40.0, "Open The bridle has no height")
	_expect(dado_rect.size.y >= 40.0, "Open The dado has no height")
	_expect(spline_rect.size.y >= 40.0, "Open The spline has no height")
	_expect(mitre_rect.size.y >= 40.0, "Open The mitre has no height")
	_expect(lap_rect.size.y >= 40.0, "Open The lap has no height")
	_expect(mortise_rect.position.y + mortise_rect.size.y <= rebate_rect.position.y, "Open The mortise is not above Open The rebate")
	_expect(rebate_rect.position.y + rebate_rect.size.y <= housing_rect.position.y, "Open The rebate is not above Open The housing")
	_expect(housing_rect.position.y + housing_rect.size.y <= tenon_rect.position.y, "Open The housing is not above Open The tenon")
	_expect(tenon_rect.position.y + tenon_rect.size.y <= bridle_rect.position.y, "Open The tenon is not above Open The bridle")
	_expect(bridle_rect.position.y + bridle_rect.size.y <= dado_rect.position.y, "Open The bridle is not above Open The dado")
	_expect(dado_rect.position.y + dado_rect.size.y <= spline_rect.position.y, "Open The dado is not above Open The spline")
	_expect(spline_rect.position.y + spline_rect.size.y <= mitre_rect.position.y, "Open The spline is not above Open The mitre")
	_expect(mitre_rect.position.y + mitre_rect.size.y <= lap_rect.position.y, "Open The mitre is not above Open The lap")
	_expect(housing_rect.position.y == 4134.0, "housing content top is %s" % housing_rect.position.y)
	_expect(tenon_rect.position.y == 4281.0, "tenon content top is %s" % tenon_rect.position.y)
	_expect(bridle_rect.position.y == 4428.0, "bridle content top is %s" % bridle_rect.position.y)
	_expect(dado_rect.position.y == 4575.0, "dado content top is %s" % dado_rect.position.y)
	_expect(spline_rect.position.y == 4722.0, "spline content top is %s" % spline_rect.position.y)
	_expect(mitre_rect.position.y == 4869.0, "mitre content top is %s" % mitre_rect.position.y)
	_expect(lap_rect.position.y == 5016.0, "lap content top is %s" % lap_rect.position.y)
	var window_height := 800.0
	var housing_bottom := housing_rect.position.y + housing_rect.size.y
	var visible_top := housing_bottom - window_height
	_expect(rebate_rect.position.y >= visible_top, "Open The rebate is not fully on screen above Open The housing")
	var rebate_bottom := rebate_rect.position.y + rebate_rect.size.y
	_expect(mortise_rect.position.y >= rebate_bottom - window_height, "Open The mortise is not fully on screen above Open The rebate")
	var tenon_bottom := tenon_rect.position.y + tenon_rect.size.y
	var tenon_visible_top := tenon_bottom - window_height
	_expect(housing_rect.position.y >= tenon_visible_top, "Open The housing is not fully on screen above Open The tenon")
	_expect(housing_rect.position.y + housing_rect.size.y <= tenon_bottom, "Open The housing extends past the window when Open The tenon sits at the bottom")
	var bridle_bottom := bridle_rect.position.y + bridle_rect.size.y
	var bridle_visible_top := bridle_bottom - window_height
	_expect(tenon_rect.position.y >= bridle_visible_top, "Open The tenon is not fully on screen above Open The bridle")
	_expect(tenon_rect.position.y + tenon_rect.size.y <= bridle_bottom, "Open The tenon extends past the window when Open The bridle sits at the bottom")
	var dado_bottom := dado_rect.position.y + dado_rect.size.y
	var dado_visible_top := dado_bottom - window_height
	_expect(bridle_rect.position.y >= dado_visible_top, "Open The bridle is not fully on screen above Open The dado")
	_expect(bridle_rect.position.y + bridle_rect.size.y <= dado_bottom, "Open The bridle extends past the window when Open The dado sits at the bottom")
	var spline_bottom := spline_rect.position.y + spline_rect.size.y
	var spline_visible_top := spline_bottom - window_height
	_expect(dado_rect.position.y >= spline_visible_top, "Open The dado is not fully on screen above Open The spline")
	_expect(dado_rect.position.y + dado_rect.size.y <= spline_bottom, "Open The dado extends past the window when Open The spline sits at the bottom")
	var mitre_bottom := mitre_rect.position.y + mitre_rect.size.y
	var mitre_visible_top := mitre_bottom - window_height
	_expect(spline_rect.position.y >= mitre_visible_top, "Open The spline is not fully on screen above Open The mitre")
	_expect(spline_rect.position.y + spline_rect.size.y <= mitre_bottom, "Open The spline extends past the window when Open The mitre sits at the bottom")
	var lap_bottom := lap_rect.position.y + lap_rect.size.y
	var lap_visible_top := lap_bottom - window_height
	_expect(mitre_rect.position.y >= lap_visible_top, "Open The mitre is not fully on screen above Open The lap")
	_expect(mitre_rect.position.y + mitre_rect.size.y <= lap_bottom, "Open The mitre extends past the window when Open The lap sits at the bottom")
	var scroll := _find_visible_scroll(root)
	_expect(scroll != null, "the file list has no scroll")
	if scroll != null:
		var bar := scroll.get_v_scroll_bar()
		print("file list scroll max %s page %s" % [bar.max_value, bar.page])
		_expect(bar.max_value > window_height, "the file list does not scroll in an 800px window")
	_expect(tenon_bottom > window_height, "Open The tenon already fits without scrolling")
	_expect(bridle_bottom > window_height, "Open The bridle already fits without scrolling")
	_expect(dado_bottom > window_height, "Open The dado already fits without scrolling")
	_expect(spline_bottom > window_height, "Open The spline already fits without scrolling")
	_expect(mitre_bottom > window_height, "Open The mitre already fits without scrolling")
	_expect(lap_bottom > window_height, "Open The lap already fits without scrolling")


func _content_rect(control: Control) -> Rect2:
	var rect := control.get_global_rect()
	var node: Node = control
	while node != null:
		if node is ScrollContainer:
			var scroll := node as ScrollContainer
			rect.position.y += float(scroll.scroll_vertical)
			rect.position.x += float(scroll.scroll_horizontal)
			break
		node = node.get_parent()
	return rect


func _find_visible_scroll(node: Node) -> ScrollContainer:
	if node == null or not node.visible:
		return null
	if node is ScrollContainer:
		return node
	for child in node.get_children():
		var found := _find_visible_scroll(child)
		if found != null:
			return found
	return null

func _expect_reply_names_conflicts(message: String, book, theory: Dictionary) -> void:
	var label := "%s / %s / %s" % [theory["who"], theory["place"], theory["hour"]]
	_expect(message.begins_with("Not accepted."), "%s board reply: %s" % [label, message])
	_expect(message.find("fits every exhibit") == -1, "%s board treated the miss as fitting" % label)
	_expect(message.find("Your claim that ") >= 0, "%s board reply does not name the claim" % label)
	var conflicting: Array[String] = book.conflicting_ids(theory)
	_expect(conflicting.size() >= 2, "%s board contradicts %d exhibits" % [label, conflicting.size()])
	var cited := _cited_ids(message)
	for exhibit_id in conflicting:
		_expect(exhibit_id in cited, "%s board reply omits %s: %s" % [label, exhibit_id, message])
	for exhibit_id in cited:
		_expect(exhibit_id in conflicting, "%s board cites %s which it does not contradict" % [label, exhibit_id])


func _press(root: Node, text: String) -> void:
	var button := _find_visible_button(root, text)
	_expect(button != null, "missing button: %s" % text)
	if button != null:
		button.pressed.emit()


func _find_visible_button(node: Node, text: String) -> Button:
	if not node.visible:
		return null
	if node is Button and (node as Button).text == text:
		return node
	for child in node.get_children():
		var found := _find_visible_button(child, text)
		if found != null:
			return found
	return null


func _verdict_text(node: Node) -> String:
	if not node.visible:
		return ""
	if node is Label:
		var text := str((node as Label).text)
		if text.begins_with("Not accepted.") or text.begins_with("Accepted.") or text.begins_with("The board is incomplete."):
			return text
	for child in node.get_children():
		var found := _verdict_text(child)
		if found != "":
			return found
	return ""


func _visible_label_blob(node: Node) -> String:
	if node == null or not node.visible:
		return ""
	var parts := PackedStringArray()
	if node is Label:
		parts.append((node as Label).text)
	for child in node.get_children():
		var piece := _visible_label_blob(child)
		if piece != "":
			parts.append(piece)
	return "\n".join(parts)
