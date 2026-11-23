extends SceneTree

## Headless rules tests. Exit 0 when every check passes, 1 otherwise.
## godot --headless --path lampblack -s res://tests/run_tests.gd

const Rules = preload("res://rules/rules.gd")
const Puzzles = preload("res://puzzles/puzzles.gd")
const SessionScript = preload("res://game/session.gd")

var _failed := 0
var _passed := 0


func _init() -> void:
	_run()
	quit(_failed)


func _run() -> void:
	_check_wings()
	for index in Puzzles.count():
		_check_puzzle(index)
	_check_toggles_required(1)
	_check_toggles_required(3)
	_check_puzzle_one_needs_no_snuff()
	_check_watched_step_is_loss()
	_check_undo_restores_exact_state(2)
	_check_undo_restores_exact_state(7)
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		var wing := str(puzzle["wing"])
		if wing == "West Wing" or wing == "North Wing" or wing == "South Wing" or wing == "Attic Wing" or wing == "Cellar Wing" or wing == "Gallery Wing" or wing == "Court Wing" or wing == "Nave Wing" or wing == "Cloister Wing" or wing == "Porch Wing" or wing == "Oriel Wing" or wing == "Veil Wing" or wing == "Shade Wing" or wing == "Screen Wing" or wing == "Glaze Wing" or wing == "Mica Wing" or wing == "Baize Wing" or wing == "Scrim Wing" or wing == "Gauze Wing" or wing == "Voile Wing" or wing == "Lawn Wing" or wing == "Muslin Wing" or wing == "Cambric Wing" or wing == "Holland Wing" or wing == "Buckram Wing" or wing == "Ticking Wing" or wing == "Denim Wing" or wing == "Canvas Wing" or wing == "Drill Wing" or wing == "Twill Wing" or wing == "Duck Wing" or wing == "Nankeen Wing" or wing == "Jean Wing":
			_check_undo_restores_exact_state(index)
	_check_alert_step()
	_check_west_lit_step_still_loses()
	_check_unwatched_lit_floor_is_refused()
	_check_lower_seal_tie()
	_check_second_wick_relights()
	_check_lit_door_starts_lit()
	_check_second_call_uses_both_lamps()
	_check_west_snuffs_are_required()
	_check_cut_beam()
	_check_cold_wick()
	_check_nearer_keeper()
	_check_far_watch()
	_check_closing_door_race()
	_check_north_snuffs_are_required()
	_check_dark_half()
	_check_passing_watch()
	_check_owed_step()
	_check_fading_watch()
	_check_covered_flame()
	_check_far_answer()
	_check_south_snuffs_are_required()
	_check_attic_rooms()
	_check_attic_snuffs_are_required()
	_check_cellar_rooms()
	_check_cellar_snuffs_are_required()
	_check_gallery_rooms()
	_check_gallery_snuffs_are_required()
	_check_court_rooms()
	_check_court_snuffs_are_required()
	_check_nave_rooms()
	_check_nave_snuffs_are_required()
	_check_cloister_rooms()
	_check_cloister_snuffs_are_required()
	_check_porch_rooms()
	_check_porch_snuffs_are_required()
	_check_oriel_rooms()
	_check_oriel_snuffs_are_required()
	_check_veil_rooms()
	_check_veil_snuffs_are_required()
	_check_shade_rooms()
	_check_shade_snuffs_are_required()
	_check_screen_rooms()
	_check_screen_snuffs_are_required()
	_check_glaze_rooms()
	_check_glaze_snuffs_are_required()
	_check_mica_rooms()
	_check_mica_snuffs_are_required()
	_check_baize_rooms()
	_check_baize_snuffs_are_required()
	_check_scrim_rooms()
	_check_scrim_snuffs_are_required()
	_check_gauze_rooms()
	_check_gauze_snuffs_are_required()
	_check_voile_rooms()
	_check_voile_snuffs_are_required()
	_check_lawn_rooms()
	_check_muslin_rooms()
	_check_muslin_snuffs_are_required()
	_check_cambric_rooms()
	_check_cambric_snuffs_are_required()
	_check_holland_rooms()
	_check_holland_snuffs_are_required()
	_check_buckram_rooms()
	_check_buckram_snuffs_are_required()
	_check_ticking_rooms()
	_check_ticking_snuffs_are_required()
	_check_denim_rooms()
	_check_denim_snuffs_are_required()
	_check_canvas_rooms()
	_check_canvas_snuffs_are_required()
	_check_drill_rooms()
	_check_drill_snuffs_are_required()
	_check_twill_rooms()
	_check_twill_snuffs_are_required()
	_check_duck_rooms()
	_check_duck_snuffs_are_required()
	_check_nankeen_rooms()
	_check_nankeen_snuffs_are_required()
	_check_jean_rooms()
	_check_jean_snuffs_are_required()
	_check_lawn_snuffs_are_required()
	_check_puzzle_select_shows_both_wings()
	print("%d passed, %d failed" % [_passed, _failed])


func _check_wings() -> void:
	var wings: Array = Puzzles.wings()
	_check(Puzzles.count() == 206, "thirty-four wings together are 206 puzzles")
	_check(wings.size() == 34, "puzzle select lists thirty-four wings")
	_check(
		wings.size() == 34 and str(wings[0]["name"]) == "East Wing" and int(wings[0]["count"]) == 8 and int(wings[0]["first"]) == 0,
		"the east wing still has 8 puzzles"
	)
	_check(
		wings.size() == 34 and str(wings[1]["name"]) == "West Wing" and int(wings[1]["count"]) == 6 and int(wings[1]["first"]) == 8,
		"the west wing has 6 puzzles"
	)
	_check(
		wings.size() == 34 and str(wings[2]["name"]) == "North Wing" and int(wings[2]["count"]) == 6 and int(wings[2]["first"]) == 14,
		"the north wing has 6 puzzles"
	)
	_check(
		wings.size() == 34 and str(wings[3]["name"]) == "South Wing" and int(wings[3]["count"]) == 6 and int(wings[3]["first"]) == 20,
		"the south wing has 6 puzzles"
	)
	_check(
		wings.size() == 34 and str(wings[4]["name"]) == "Attic Wing" and int(wings[4]["count"]) == 6 and int(wings[4]["first"]) == 26,
		"the attic has 6 puzzles"
	)
	_check(
		wings.size() == 34 and str(wings[5]["name"]) == "Cellar Wing" and int(wings[5]["count"]) == 6 and int(wings[5]["first"]) == 32,
		"the cellar has 6 puzzles"
	)
	var south_titles: PackedStringArray = PackedStringArray([
		"The Dark Half",
		"The Passing Watch",
		"The Owed Step",
		"The Fading Watch",
		"The Covered Flame",
		"The Far Answer",
	])
	var south_ok := true
	for i in south_titles.size():
		var room: Dictionary = Puzzles.get_puzzle(20 + i)
		if str(room["title"]) != south_titles[i] or str(room["wing"]) != "South Wing" or int(room["wing_number"]) != i + 1 or int(room["number"]) != 21 + i:
			south_ok = false
	_check(south_ok, "the south wing is numbered 21 through 26")
	var attic_titles: PackedStringArray = PackedStringArray([
		"The Unlit Watch",
		"The Blind Wall",
		"The Barred Gap",
		"The North Step",
		"The Dark Eye",
		"The Early Threshold",
	])
	var attic_ok := true
	var attic_rules: PackedStringArray = PackedStringArray([
		"a guard watches only lit tiles",
		"walls block vision",
		"a called guard cannot cross a gap",
		"north, then east, then south, then west",
		"a guard standing in the dark can still look into an adjacent lit tile",
		"reaching the exit wins before the guards move",
	])
	for i in attic_titles.size():
		var attic_room: Dictionary = Puzzles.get_puzzle(26 + i)
		var lesson := str(attic_room["lesson"])
		if str(attic_room["title"]) != attic_titles[i] or str(attic_room["wing"]) != "Attic Wing" or int(attic_room["wing_number"]) != i + 1 or int(attic_room["number"]) != 27 + i:
			attic_ok = false
		if not lesson.begins_with("This room is about the rule that ") or not lesson.contains(attic_rules[i]):
			attic_ok = false
	_check(attic_ok, "the attic is numbered 27 through 32 and each banner names its rule")
	var cellar_titles: PackedStringArray = PackedStringArray([
		"The Open Corner",
		"The Brick Shade",
		"The Quiet Wick",
		"The Earlier Keeper",
		"The Dim Lane",
		"The Still Post",
	])
	var cellar_ok := true
	var cellar_rules: PackedStringArray = PackedStringArray([
		"a lit lamp fills a Manhattan diamond",
		"walls block light",
		"lighting a lamp does not call a guard",
		"a distance tie calls the lower number",
		"dark tiles block vision",
		"a called guard holds on the lamp and does not resume his rail",
	])
	for i in cellar_titles.size():
		var cellar_room: Dictionary = Puzzles.get_puzzle(32 + i)
		var cellar_lesson := str(cellar_room["lesson"])
		if str(cellar_room["title"]) != cellar_titles[i] or str(cellar_room["wing"]) != "Cellar Wing" or int(cellar_room["wing_number"]) != i + 1 or int(cellar_room["number"]) != 33 + i:
			cellar_ok = false
		if not cellar_lesson.begins_with("This room is about the rule that ") or not cellar_lesson.contains(cellar_rules[i]):
			cellar_ok = false
	_check(cellar_ok, "the cellar is numbered 33 through 38 and each banner names its rule")
	_check(
		wings.size() == 34 and str(wings[6]["name"]) == "Gallery Wing" and int(wings[6]["count"]) == 6 and int(wings[6]["first"]) == 38,
		"the gallery has 6 puzzles"
	)
	var gallery_titles: PackedStringArray = PackedStringArray([
		"The Rear Shade",
		"The Late Call",
		"The Closed Hall",
		"The Lit Crossing",
		"The Keeper's Square",
		"The Outer Ring",
	])
	var gallery_ok := true
	var gallery_rules: PackedStringArray = PackedStringArray([
		"the tile directly behind the lamp stays dark",
		"snuffing calls the nearest guard toward that lamp on the next turn",
		"lit floor that no guard is watching is refused",
		"a gap may be entered only while it is lit",
		"sharing a tile with a guard is a loss",
		"each guard watches a Manhattan diamond of their vision radius",
	])
	for i in gallery_titles.size():
		var gallery_room: Dictionary = Puzzles.get_puzzle(38 + i)
		var gallery_lesson := str(gallery_room["lesson"])
		if str(gallery_room["title"]) != gallery_titles[i] or str(gallery_room["wing"]) != "Gallery Wing" or int(gallery_room["wing_number"]) != i + 1 or int(gallery_room["number"]) != 39 + i:
			gallery_ok = false
		if not gallery_lesson.begins_with("This room is about the rule that ") or not gallery_lesson.contains(gallery_rules[i]):
			gallery_ok = false
	_check(gallery_ok, "the gallery is numbered 39 through 44 and each banner names its rule")
	_check(
		wings.size() == 34 and str(wings[7]["name"]) == "Court Wing" and int(wings[7]["count"]) == 6 and int(wings[7]["first"]) == 44,
		"the court has 6 puzzles"
	)
	var court_titles: PackedStringArray = PackedStringArray([
		"The First Plate",
		"The Quiet Wait",
		"The Far Keeper",
		"The Lit Plate",
		"The Plate Gap",
		"The Last Hold",
	])
	var court_ok := true
	var court_rules: PackedStringArray = PackedStringArray([
		"the turn you step onto a plate calls the nearest guard",
		"waiting on a plate does not call the guard a second time",
		"a plate calls the nearer guard",
		"a lit plate is refused",
		"stepping on a plate calls the nearest guard toward that plate",
		"a called guard walks to the plate and holds",
	])
	for i in court_titles.size():
		var court_room: Dictionary = Puzzles.get_puzzle(44 + i)
		var court_lesson := str(court_room["lesson"])
		if str(court_room["title"]) != court_titles[i] or str(court_room["wing"]) != "Court Wing" or int(court_room["wing_number"]) != i + 1 or int(court_room["number"]) != 45 + i:
			court_ok = false
		if not court_lesson.begins_with("This room is about the rule that ") or not court_lesson.contains(court_rules[i]):
			court_ok = false
	_check(court_ok, "the court is numbered 45 through 50 and each banner names its rule")
	_check(
		wings.size() == 34 and str(wings[8]["name"]) == "Nave Wing" and int(wings[8]["count"]) == 6 and int(wings[8]["first"]) == 50,
		"the nave has 6 puzzles"
	)
	var nave_titles: PackedStringArray = PackedStringArray([
		"The First Bell",
		"The Quiet Bell",
		"The Far Bell",
		"The Lit Bell",
		"The Bell Gap",
		"The Last Ring",
	])
	var nave_ok := true
	var nave_rules: PackedStringArray = PackedStringArray([
		"the turn you step onto a bell calls every guard",
		"waiting on a bell does not call",
		"including the far one",
		"a lit bell is refused",
		"stepping on a bell calls every guard",
		"called guards walk to the bell and hold",
	])
	for i in nave_titles.size():
		var nave_room: Dictionary = Puzzles.get_puzzle(50 + i)
		var nave_lesson := str(nave_room["lesson"])
		if str(nave_room["title"]) != nave_titles[i] or str(nave_room["wing"]) != "Nave Wing" or int(nave_room["wing_number"]) != i + 1 or int(nave_room["number"]) != 51 + i:
			nave_ok = false
		if not nave_lesson.begins_with("This room is about the rule that ") or not nave_lesson.contains(nave_rules[i]):
			nave_ok = false
		if i == 0 and nave_lesson.count(".") != 1:
			nave_ok = false
	_check(nave_ok, "the nave is numbered 51 through 56 and each banner names its rule")
	var first_bell: Dictionary = Puzzles.get_puzzle(50)
	_check(str(first_bell["lesson"]).count(".") == 1, "room 51 states the bell rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[9]["name"]) == "Cloister Wing" and int(wings[9]["count"]) == 6 and int(wings[9]["first"]) == 56,
		"the cloister has 6 puzzles"
	)
	var cloister_titles: PackedStringArray = PackedStringArray([
		"The First Grate",
		"The Passed Light",
		"The Dark Cut",
		"The Long Road",
		"The Lit Edge",
		"The Last Grate",
	])
	var cloister_ok := true
	var cloister_rules: PackedStringArray = PackedStringArray([
		"a grate is floor you may enter and it stays dark",
		"light does not stop at a grate",
		"a dark grate blocks a guard's sight",
		"a called guard cannot enter a grate",
		"a lit floor tile beside a grate is still refused",
		"a called guard's road treats a grate as closed",
	])
	for i in cloister_titles.size():
		var cloister_room: Dictionary = Puzzles.get_puzzle(56 + i)
		var cloister_lesson := str(cloister_room["lesson"])
		if str(cloister_room["title"]) != cloister_titles[i] or str(cloister_room["wing"]) != "Cloister Wing" or int(cloister_room["wing_number"]) != i + 1 or int(cloister_room["number"]) != 57 + i:
			cloister_ok = false
		if not cloister_lesson.begins_with("This room is about the rule that ") or not cloister_lesson.contains(cloister_rules[i]):
			cloister_ok = false
		if i == 0 and cloister_lesson.count(".") != 1:
			cloister_ok = false
	_check(cloister_ok, "the cloister is numbered 57 through 62 and each banner names its rule")
	var first_grate: Dictionary = Puzzles.get_puzzle(56)
	_check(str(first_grate["lesson"]).count(".") == 1, "room 57 states the grate rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[10]["name"]) == "Porch Wing" and int(wings[10]["count"]) == 6 and int(wings[10]["first"]) == 62,
		"the porch has 6 puzzles"
	)
	var porch_titles: PackedStringArray = PackedStringArray([
		"The First Sill",
		"The Stopped Light",
		"The Seen Gap",
		"The Closed Walk",
		"The Dark Past",
		"The Last Sill",
	])
	var porch_ok := true
	var porch_rules: PackedStringArray = PackedStringArray([
		"a sill under a lamp is lit and refused",
		"light stops at a sill",
		"a sill does not hide the lit gap beside it",
		"a called guard cannot enter a sill",
		"the tile past a sill stays dark",
		"a snuffed sill can be crossed once it is dark",
	])
	for i in porch_titles.size():
		var porch_room: Dictionary = Puzzles.get_puzzle(62 + i)
		var porch_lesson := str(porch_room["lesson"])
		if str(porch_room["title"]) != porch_titles[i] or str(porch_room["wing"]) != "Porch Wing" or int(porch_room["wing_number"]) != i + 1 or int(porch_room["number"]) != 63 + i:
			porch_ok = false
		if not porch_lesson.begins_with("This room is about the rule that ") or not porch_lesson.contains(porch_rules[i]):
			porch_ok = false
		if i == 0 and porch_lesson.count(".") != 1:
			porch_ok = false
	_check(porch_ok, "the porch is numbered 63 through 68 and each banner names its rule")
	var first_sill: Dictionary = Puzzles.get_puzzle(62)
	_check(str(first_sill["lesson"]).count(".") == 1, "room 63 states the sill rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[11]["name"]) == "Oriel Wing" and int(wings[11]["count"]) == 6 and int(wings[11]["first"]) == 68,
		"the oriel has 6 puzzles"
	)
	var oriel_titles: PackedStringArray = PackedStringArray([
		"The First Pane",
		"The Seen Room",
		"The Closed Sheet",
		"The Dark Beside",
		"The Long Sight",
		"The Last Pane",
	])
	var oriel_ok := true
	var oriel_rules: PackedStringArray = PackedStringArray([
		"a pane lets the lamp light the gap beyond",
		"a guard sees the lit floor beyond a pane",
		"a called guard cannot step on a pane",
		"the tile beside a pane stays dark",
		"a guard sees through a pane",
		"you leave by the gap a pane left lit",
	])
	for i in oriel_titles.size():
		var oriel_room: Dictionary = Puzzles.get_puzzle(68 + i)
		var oriel_lesson := str(oriel_room["lesson"])
		if str(oriel_room["title"]) != oriel_titles[i] or str(oriel_room["wing"]) != "Oriel Wing" or int(oriel_room["wing_number"]) != i + 1 or int(oriel_room["number"]) != 69 + i:
			oriel_ok = false
		if not oriel_lesson.begins_with("This room is about the rule that ") or not oriel_lesson.contains(oriel_rules[i]):
			oriel_ok = false
		if i == 0 and oriel_lesson.count(".") != 1:
			oriel_ok = false
	_check(oriel_ok, "the oriel is numbered 69 through 74 and each banner names its rule")
	var first_pane: Dictionary = Puzzles.get_puzzle(68)
	_check(str(first_pane["lesson"]).count(".") == 1, "room 69 states the pane rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[12]["name"]) == "Veil Wing" and int(wings[12]["count"]) == 6 and int(wings[12]["first"]) == 74,
		"the veil has 6 puzzles"
	)
	var veil_titles: PackedStringArray = PackedStringArray([
		"The First Cloth",
		"The Seen Cloth",
		"The Short Road",
		"The Dark Beside",
		"The Second Lamp",
		"The Last Cloth",
	])
	var veil_ok := true
	var veil_rules: PackedStringArray = PackedStringArray([
		"a curtain lets the lamp light the gap beyond",
		"the curtain cell itself is lit",
		"the called guard's shortest floor path goes through the curtain",
		"the tile beside the curtain",
		"keeps its second lamp",
		"you leave by the gap the curtain left lit",
	])
	for i in veil_titles.size():
		var veil_room: Dictionary = Puzzles.get_puzzle(74 + i)
		var veil_lesson := str(veil_room["lesson"])
		if str(veil_room["title"]) != veil_titles[i] or str(veil_room["wing"]) != "Veil Wing" or int(veil_room["wing_number"]) != i + 1 or int(veil_room["number"]) != 75 + i:
			veil_ok = false
		if not veil_lesson.begins_with("This room is about the rule that ") or not veil_lesson.contains(veil_rules[i]):
			veil_ok = false
		if i == 0 and veil_lesson.count(".") != 1:
			veil_ok = false
	_check(veil_ok, "the veil is numbered 75 through 80 and each banner names its rule")
	var first_cloth: Dictionary = Puzzles.get_puzzle(74)
	_check(str(first_cloth["lesson"]).count(".") == 1, "room 75 states the curtain rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[13]["name"]) == "Shade Wing" and int(wings[13]["count"]) == 6 and int(wings[13]["first"]) == 80,
		"the shade has 6 puzzles"
	)
	var shade_titles: PackedStringArray = PackedStringArray([
		"The First Shade",
		"The Dark Step",
		"The Long Road",
		"The Far Dark",
		"The Second Lamp",
		"The Last Shade",
	])
	var shade_ok := true
	var shade_rules: PackedStringArray = PackedStringArray([
		"light stops at a shade",
		"you step onto the shade under the lamp",
		"a called guard cannot step on a shade",
		"the tile past a shade stays dark",
		"keeps its second lamp",
		"you leave by the dark gap the shade left",
	])
	for i in shade_titles.size():
		var shade_room: Dictionary = Puzzles.get_puzzle(80 + i)
		var shade_lesson := str(shade_room["lesson"])
		if str(shade_room["title"]) != shade_titles[i] or str(shade_room["wing"]) != "Shade Wing" or int(shade_room["wing_number"]) != i + 1 or int(shade_room["number"]) != 81 + i:
			shade_ok = false
		if not shade_lesson.begins_with("This room is about the rule that ") or not shade_lesson.contains(shade_rules[i]):
			shade_ok = false
		if i == 0 and shade_lesson.count(".") != 1:
			shade_ok = false
	_check(shade_ok, "the shade is numbered 81 through 86 and each banner names its rule")
	var first_shade: Dictionary = Puzzles.get_puzzle(80)
	_check(str(first_shade["lesson"]).count(".") == 1, "room 81 states the shade rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[14]["name"]) == "Screen Wing" and int(wings[14]["count"]) == 6 and int(wings[14]["first"]) == 86,
		"the screen has 6 puzzles"
	)
	var screen_titles: PackedStringArray = PackedStringArray([
		"The First Screen",
		"The Lit Screen",
		"The Closed Road",
		"The Far Light",
		"The Second Lamp",
		"The Last Screen",
	])
	var screen_ok := true
	var screen_rules: PackedStringArray = PackedStringArray([
		"a screen lets the lamp light the gap beyond",
		"the screen is lit",
		"a called guard cannot step on a screen",
		"the tile past a screen is lit",
		"keeps its second lamp",
		"you leave by the lit unwatched gap",
	])
	for i in screen_titles.size():
		var screen_room: Dictionary = Puzzles.get_puzzle(86 + i)
		var screen_lesson := str(screen_room["lesson"])
		if str(screen_room["title"]) != screen_titles[i] or str(screen_room["wing"]) != "Screen Wing" or int(screen_room["wing_number"]) != i + 1 or int(screen_room["number"]) != 87 + i:
			screen_ok = false
		if not screen_lesson.begins_with("This room is about the rule that ") or not screen_lesson.contains(screen_rules[i]):
			screen_ok = false
		if i == 0 and screen_lesson.count(".") != 1:
			screen_ok = false
	_check(screen_ok, "the screen is numbered 87 through 92 and each banner names its rule")
	var first_screen: Dictionary = Puzzles.get_puzzle(86)
	_check(str(first_screen["lesson"]).count(".") == 1, "room 87 states the screen rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[15]["name"]) == "Glaze Wing" and int(wings[15]["count"]) == 6 and int(wings[15]["first"]) == 92,
		"the glaze has 6 puzzles"
	)
	var glaze_titles: PackedStringArray = PackedStringArray([
		"The Watched Gap",
		"The Lit Glaze",
		"The Open Sight",
		"The Closed Road",
		"The Second Lamp",
		"The Last Glaze",
	])
	var glaze_ok := true
	var glaze_rules: PackedStringArray = PackedStringArray([
		"the gap beyond the glaze is lit and watched",
		"the glaze is lit",
		"the guard sees a lit tile through the glaze",
		"a guard cannot enter the glaze",
		"a second lamp's light passes the glaze",
		"you leave without stepping on the lit glaze",
	])
	for i in glaze_titles.size():
		var glaze_room: Dictionary = Puzzles.get_puzzle(92 + i)
		var glaze_lesson := str(glaze_room["lesson"])
		if str(glaze_room["title"]) != glaze_titles[i] or str(glaze_room["wing"]) != "Glaze Wing" or int(glaze_room["wing_number"]) != i + 1 or int(glaze_room["number"]) != 93 + i:
			glaze_ok = false
		if not glaze_lesson.begins_with("This room is about the rule that ") or not glaze_lesson.contains(glaze_rules[i]):
			glaze_ok = false
		if i == 0 and glaze_lesson.count(".") != 1:
			glaze_ok = false
	_check(glaze_ok, "the glaze is numbered 93 through 98 and each banner names its rule")
	var first_glaze: Dictionary = Puzzles.get_puzzle(92)
	_check(str(first_glaze["lesson"]).count(".") == 1, "room 93 states the glaze rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[16]["name"]) == "Mica Wing" and int(wings[16]["count"]) == 6 and int(wings[16]["first"]) == 98,
		"the mica has 6 puzzles"
	)
	var mica_titles: PackedStringArray = PackedStringArray([
		"The Dark Step",
		"The Seen Gap",
		"The Passed Lamp",
		"The Long Road",
		"The Early Catch",
		"The Last Mica",
	])
	var mica_ok := true
	var mica_rules: PackedStringArray = PackedStringArray([
		"you step onto the mica while the lamp is lit",
		"the guard sees a lit tile through the dark mica",
		"a second lamp's light passes the mica",
		"a guard cannot enter the mica",
		"the early step onto the mica is legal",
		"you leave by stepping on the dark mica",
	])
	for i in mica_titles.size():
		var mica_room: Dictionary = Puzzles.get_puzzle(98 + i)
		var mica_lesson := str(mica_room["lesson"])
		if str(mica_room["title"]) != mica_titles[i] or str(mica_room["wing"]) != "Mica Wing" or int(mica_room["wing_number"]) != i + 1 or int(mica_room["number"]) != 99 + i:
			mica_ok = false
		if not mica_lesson.begins_with("This room is about the rule that ") or not mica_lesson.contains(mica_rules[i]):
			mica_ok = false
		if i == 0 and mica_lesson.count(".") != 1:
			mica_ok = false
	_check(mica_ok, "the mica is numbered 99 through 104 and each banner names its rule")
	var first_mica: Dictionary = Puzzles.get_puzzle(98)
	_check(str(first_mica["lesson"]).count(".") == 1, "room 99 states the mica rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[17]["name"]) == "Baize Wing" and int(wings[17]["count"]) == 6 and int(wings[17]["first"]) == 104,
		"the baize has 6 puzzles"
	)
	var baize_titles: PackedStringArray = PackedStringArray([
		"The Dark Cloth",
		"The Seen Hem",
		"The Stopped Lamp",
		"The Long Cloth",
		"The Early Hem",
		"The Last Baize",
	])
	var baize_ok := true
	var baize_rules: PackedStringArray = PackedStringArray([
		"you step onto the baize while the lamp is lit",
		"the guard sees a lit tile through the dark baize",
		"a second lamp's light stops at the baize",
		"a guard cannot enter the baize",
		"the early step onto the baize is legal",
		"you leave by stepping on the dark baize",
	])
	for i in baize_titles.size():
		var baize_room: Dictionary = Puzzles.get_puzzle(104 + i)
		var baize_lesson := str(baize_room["lesson"])
		if str(baize_room["title"]) != baize_titles[i] or str(baize_room["wing"]) != "Baize Wing" or int(baize_room["wing_number"]) != i + 1 or int(baize_room["number"]) != 105 + i:
			baize_ok = false
		if not baize_lesson.begins_with("This room is about the rule that ") or not baize_lesson.contains(baize_rules[i]):
			baize_ok = false
		if i == 0 and baize_lesson.count(".") != 1:
			baize_ok = false
	_check(baize_ok, "the baize is numbered 105 through 110 and each banner names its rule")
	var first_baize: Dictionary = Puzzles.get_puzzle(104)
	_check(str(first_baize["lesson"]).count(".") == 1, "room 105 states the baize rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[18]["name"]) == "Scrim Wing" and int(wings[18]["count"]) == 6 and int(wings[18]["first"]) == 110,
		"the scrim has 6 puzzles"
	)
	var scrim_titles: PackedStringArray = PackedStringArray([
		"The Lit Scrim",
		"The Seen Thread",
		"The Halted Wick",
		"The Closed Scrim",
		"The Early Thread",
		"The Last Scrim",
	])
	var scrim_ok := true
	var scrim_rules: PackedStringArray = PackedStringArray([
		"the scrim is lit",
		"the guard sees a lit tile through the lit scrim",
		"a second lamp's light stops at the scrim",
		"a guard cannot enter the scrim",
		"the early step onto the lit scrim fails",
		"you leave by stepping on the dark scrim",
	])
	for i in scrim_titles.size():
		var scrim_room: Dictionary = Puzzles.get_puzzle(110 + i)
		var scrim_lesson := str(scrim_room["lesson"])
		if str(scrim_room["title"]) != scrim_titles[i] or str(scrim_room["wing"]) != "Scrim Wing" or int(scrim_room["wing_number"]) != i + 1 or int(scrim_room["number"]) != 111 + i:
			scrim_ok = false
		if not scrim_lesson.begins_with("This room is about the rule that ") or not scrim_lesson.contains(scrim_rules[i]):
			scrim_ok = false
		if i == 0 and scrim_lesson.count(".") != 1:
			scrim_ok = false
	_check(scrim_ok, "the scrim is numbered 111 through 116 and each banner names its rule")
	var first_scrim: Dictionary = Puzzles.get_puzzle(110)
	_check(str(first_scrim["lesson"]).count(".") == 1, "room 111 states the scrim rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[19]["name"]) == "Gauze Wing" and int(wings[19]["count"]) == 6 and int(wings[19]["first"]) == 116,
		"the gauze has 6 puzzles"
	)
	var gauze_titles: PackedStringArray = PackedStringArray([
		"The Lit Gauze",
		"The Seen Mesh",
		"The Passed Flame",
		"The Open Gauze",
		"The Early Mesh",
		"The Last Gauze",
	])
	var gauze_ok := true
	var gauze_rules: PackedStringArray = PackedStringArray([
		"the gauze is lit",
		"the guard sees a lit tile through the lit gauze",
		"a second lamp's light passes the gauze",
		"a guard cannot enter the gauze",
		"the early step onto the lit gauze fails",
		"you leave by stepping on the dark gauze",
	])
	for i in gauze_titles.size():
		var gauze_room: Dictionary = Puzzles.get_puzzle(116 + i)
		var gauze_lesson := str(gauze_room["lesson"])
		if str(gauze_room["title"]) != gauze_titles[i] or str(gauze_room["wing"]) != "Gauze Wing" or int(gauze_room["wing_number"]) != i + 1 or int(gauze_room["number"]) != 117 + i:
			gauze_ok = false
		if not gauze_lesson.begins_with("This room is about the rule that ") or not gauze_lesson.contains(gauze_rules[i]):
			gauze_ok = false
		if i == 0 and gauze_lesson.count(".") != 1:
			gauze_ok = false
	_check(gauze_ok, "the gauze is numbered 117 through 122 and each banner names its rule")
	var first_gauze: Dictionary = Puzzles.get_puzzle(116)
	_check(str(first_gauze["lesson"]).count(".") == 1, "room 117 states the gauze rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[20]["name"]) == "Voile Wing" and int(wings[20]["count"]) == 6 and int(wings[20]["first"]) == 122,
		"the voile has 6 puzzles"
	)
	var voile_titles: PackedStringArray = PackedStringArray([
		"The Lit Voile",
		"The Seen Weave",
		"The Passed Spark",
		"The Shut Voile",
		"The Early Step",
		"The Last Voile",
	])
	var voile_ok := true
	var voile_rules: PackedStringArray = PackedStringArray([
		"the voile is lit",
		"the guard sees a lit tile through the lit voile",
		"a second lamp's light passes the voile",
		"a guard cannot enter the voile",
		"the early step onto the lit voile succeeds",
		"you leave by stepping on the dark voile",
	])
	for i in voile_titles.size():
		var voile_room: Dictionary = Puzzles.get_puzzle(122 + i)
		var voile_lesson := str(voile_room["lesson"])
		if str(voile_room["title"]) != voile_titles[i] or str(voile_room["wing"]) != "Voile Wing" or int(voile_room["wing_number"]) != i + 1 or int(voile_room["number"]) != 123 + i:
			voile_ok = false
		if not voile_lesson.begins_with("This room is about the rule that ") or not voile_lesson.contains(voile_rules[i]):
			voile_ok = false
		if i == 0 and voile_lesson.count(".") != 1:
			voile_ok = false
	_check(voile_ok, "the voile is numbered 123 through 128 and each banner names its rule")
	var first_voile: Dictionary = Puzzles.get_puzzle(122)
	_check(str(first_voile["lesson"]).count(".") == 1, "room 123 states the voile rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[21]["name"]) == "Lawn Wing" and int(wings[21]["count"]) == 6 and int(wings[21]["first"]) == 128,
		"the lawn has 6 puzzles"
	)
	var lawn_titles: PackedStringArray = PackedStringArray([
		"The Lit Lawn",
		"The Seen Sward",
		"The Halted Gleam",
		"The Barred Lawn",
		"The Early Tread",
		"The Last Lawn",
	])
	var lawn_ok := true
	var lawn_rules: PackedStringArray = PackedStringArray([
		"the lawn is lit",
		"the guard sees a lit tile through the lit lawn",
		"a second lamp's light stops at the lawn",
		"a guard cannot enter the lawn",
		"the early step onto the lit lawn succeeds",
		"you leave by stepping on the dark lawn",
	])
	for i in lawn_titles.size():
		var lawn_room: Dictionary = Puzzles.get_puzzle(128 + i)
		var lawn_lesson := str(lawn_room["lesson"])
		if str(lawn_room["title"]) != lawn_titles[i] or str(lawn_room["wing"]) != "Lawn Wing" or int(lawn_room["wing_number"]) != i + 1 or int(lawn_room["number"]) != 129 + i:
			lawn_ok = false
		if not lawn_lesson.begins_with("This room is about the rule that ") or not lawn_lesson.contains(lawn_rules[i]):
			lawn_ok = false
		if i == 0 and lawn_lesson.count(".") != 1:
			lawn_ok = false
	_check(lawn_ok, "the lawn is numbered 129 through 134 and each banner names its rule")
	var first_lawn: Dictionary = Puzzles.get_puzzle(128)
	_check(str(first_lawn["lesson"]).count(".") == 1, "room 129 states the lawn rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[22]["name"]) == "Muslin Wing" and int(wings[22]["count"]) == 6 and int(wings[22]["first"]) == 134,
		"the muslin has 6 puzzles"
	)
	var muslin_titles: PackedStringArray = PackedStringArray([
		"The Lit Muslin",
		"The Seen Warp",
		"The Halted Sheen",
		"The Open Muslin",
		"The Refused Entry",
		"The Last Muslin",
	])
	var muslin_ok := true
	var muslin_rules: PackedStringArray = PackedStringArray([
		"the muslin is lit",
		"the guard sees a lit tile through the lit muslin",
		"a second lamp's light stops at the muslin",
		"a guard can enter the muslin",
		"the early step onto the lit muslin fails",
		"you leave by stepping on the dark muslin",
	])
	for i in muslin_titles.size():
		var muslin_room: Dictionary = Puzzles.get_puzzle(134 + i)
		var muslin_lesson := str(muslin_room["lesson"])
		if str(muslin_room["title"]) != muslin_titles[i] or str(muslin_room["wing"]) != "Muslin Wing" or int(muslin_room["wing_number"]) != i + 1 or int(muslin_room["number"]) != 135 + i:
			muslin_ok = false
		if not muslin_lesson.begins_with("This room is about the rule that ") or not muslin_lesson.contains(muslin_rules[i]):
			muslin_ok = false
		if i == 0 and muslin_lesson.count(".") != 1:
			muslin_ok = false
	_check(muslin_ok, "the muslin is numbered 135 through 140 and each banner names its rule")
	var first_muslin: Dictionary = Puzzles.get_puzzle(134)
	_check(str(first_muslin["lesson"]).count(".") == 1, "room 135 states the muslin rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[23]["name"]) == "Cambric Wing" and int(wings[23]["count"]) == 6 and int(wings[23]["first"]) == 140,
		"the cambric has 6 puzzles"
	)
	var cambric_titles: PackedStringArray = PackedStringArray([
		"The Lit Cambric",
		"The Seen Weft",
		"The Halted Glow",
		"The Walked Cambric",
		"The Sure Landing",
		"The Last Cambric",
	])
	var cambric_ok := true
	var cambric_rules: PackedStringArray = PackedStringArray([
		"the cambric is lit",
		"the guard sees a lit tile through the lit cambric",
		"a second lamp's light stops at the cambric",
		"a guard can enter the cambric",
		"the early step onto the lit cambric succeeds",
		"you leave by stepping on the dark cambric",
	])
	for i in cambric_titles.size():
		var cambric_room: Dictionary = Puzzles.get_puzzle(140 + i)
		var cambric_lesson := str(cambric_room["lesson"])
		if str(cambric_room["title"]) != cambric_titles[i] or str(cambric_room["wing"]) != "Cambric Wing" or int(cambric_room["wing_number"]) != i + 1 or int(cambric_room["number"]) != 141 + i:
			cambric_ok = false
		if not cambric_lesson.begins_with("This room is about the rule that ") or not cambric_lesson.contains(cambric_rules[i]):
			cambric_ok = false
		if i == 0 and cambric_lesson.count(".") != 1:
			cambric_ok = false
	_check(cambric_ok, "the cambric is numbered 141 through 146 and each banner names its rule")
	var first_cambric: Dictionary = Puzzles.get_puzzle(140)
	_check(str(first_cambric["lesson"]).count(".") == 1, "room 141 states the cambric rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[24]["name"]) == "Holland Wing" and int(wings[24]["count"]) == 6 and int(wings[24]["first"]) == 146,
		"the holland has 6 puzzles"
	)
	var holland_titles: PackedStringArray = PackedStringArray([
		"The Lit Holland",
		"The Seen Grain",
		"The Passed Ray",
		"The Trod Holland",
		"The Firm Footing",
		"The Last Holland",
	])
	var holland_ok := true
	var holland_rules: PackedStringArray = PackedStringArray([
		"the holland is lit",
		"the guard sees a lit tile through the lit holland",
		"a second lamp's light passes through the holland",
		"a guard can enter the holland",
		"the early step onto the lit holland succeeds",
		"you leave by stepping on the dark holland",
	])
	for i in holland_titles.size():
		var holland_room: Dictionary = Puzzles.get_puzzle(146 + i)
		var holland_lesson := str(holland_room["lesson"])
		if str(holland_room["title"]) != holland_titles[i] or str(holland_room["wing"]) != "Holland Wing" or int(holland_room["wing_number"]) != i + 1 or int(holland_room["number"]) != 147 + i:
			holland_ok = false
		if not holland_lesson.begins_with("This room is about the rule that ") or not holland_lesson.contains(holland_rules[i]):
			holland_ok = false
		if i == 0 and holland_lesson.count(".") != 1:
			holland_ok = false
	_check(holland_ok, "the holland is numbered 147 through 152 and each banner names its rule")
	var first_holland: Dictionary = Puzzles.get_puzzle(146)
	_check(str(first_holland["lesson"]).count(".") == 1, "room 147 states the holland rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[25]["name"]) == "Buckram Wing" and int(wings[25]["count"]) == 6 and int(wings[25]["first"]) == 152,
		"the buckram has 6 puzzles"
	)
	var buckram_titles: PackedStringArray = PackedStringArray([
		"The Lit Buckram",
		"The Seen Rib",
		"The Passed Beam",
		"The Open Buckram",
		"The Barred Step",
		"The Last Buckram",
	])
	var buckram_ok := true
	var buckram_rules: PackedStringArray = PackedStringArray([
		"the buckram is lit",
		"the guard sees a lit tile through the lit buckram",
		"a second lamp's light passes through the buckram",
		"a guard can enter the buckram",
		"the early step onto the lit buckram fails",
		"you leave by stepping on the dark buckram",
	])
	for i in buckram_titles.size():
		var buckram_room: Dictionary = Puzzles.get_puzzle(152 + i)
		var buckram_lesson := str(buckram_room["lesson"])
		if str(buckram_room["title"]) != buckram_titles[i] or str(buckram_room["wing"]) != "Buckram Wing" or int(buckram_room["wing_number"]) != i + 1 or int(buckram_room["number"]) != 153 + i:
			buckram_ok = false
		if not buckram_lesson.begins_with("This room is about the rule that ") or not buckram_lesson.contains(buckram_rules[i]):
			buckram_ok = false
		if i == 0 and buckram_lesson.count(".") != 1:
			buckram_ok = false
	_check(buckram_ok, "the buckram is numbered 153 through 158 and each banner names its rule")
	var first_buckram: Dictionary = Puzzles.get_puzzle(152)
	_check(str(first_buckram["lesson"]).count(".") == 1, "room 153 states the buckram rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[26]["name"]) == "Ticking Wing" and int(wings[26]["count"]) == 6 and int(wings[26]["first"]) == 158,
		"the ticking has 6 puzzles"
	)
	var ticking_titles: PackedStringArray = PackedStringArray([
		"The Lit Ticking",
		"The Hidden Stripe",
		"The Passed Stripe",
		"The Open Ticking",
		"The Clear Step",
		"The Last Ticking",
	])
	var ticking_ok := true
	var ticking_rules: PackedStringArray = PackedStringArray([
		"the ticking is lit",
		"the guard does not see a lit tile through the lit ticking",
		"a second lamp's light passes through the ticking",
		"a guard can enter the ticking",
		"the early step onto the lit ticking succeeds",
		"you leave by stepping on the dark ticking",
	])
	for i in ticking_titles.size():
		var ticking_room: Dictionary = Puzzles.get_puzzle(158 + i)
		var ticking_lesson := str(ticking_room["lesson"])
		if str(ticking_room["title"]) != ticking_titles[i] or str(ticking_room["wing"]) != "Ticking Wing" or int(ticking_room["wing_number"]) != i + 1 or int(ticking_room["number"]) != 159 + i:
			ticking_ok = false
		if not ticking_lesson.begins_with("This room is about the rule that ") or not ticking_lesson.contains(ticking_rules[i]):
			ticking_ok = false
		if i == 0 and ticking_lesson.count(".") != 1:
			ticking_ok = false
	_check(ticking_ok, "the ticking is numbered 159 through 164 and each banner names its rule")
	var first_ticking: Dictionary = Puzzles.get_puzzle(158)
	_check(str(first_ticking["lesson"]).count(".") == 1, "room 159 states the ticking rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[27]["name"]) == "Denim Wing" and int(wings[27]["count"]) == 6 and int(wings[27]["first"]) == 164,
		"the denim has 6 puzzles"
	)
	var denim_titles: PackedStringArray = PackedStringArray([
		"The Lit Denim",
		"The Seen Twill",
		"The Passed Seam",
		"The Open Denim",
		"The Sure Tread",
		"The Last Denim",
	])
	var denim_ok := true
	var denim_rules: PackedStringArray = PackedStringArray([
		"the denim is lit",
		"the guard sees a lit tile through the lit denim",
		"a second lamp's light passes through the denim",
		"a guard can enter the denim",
		"the early step onto the lit denim succeeds",
		"you leave by stepping on the lit denim",
	])
	for i in denim_titles.size():
		var denim_room: Dictionary = Puzzles.get_puzzle(164 + i)
		var denim_lesson := str(denim_room["lesson"])
		if str(denim_room["title"]) != denim_titles[i] or str(denim_room["wing"]) != "Denim Wing" or int(denim_room["wing_number"]) != i + 1 or int(denim_room["number"]) != 165 + i:
			denim_ok = false
		if not denim_lesson.begins_with("This room is about the rule that ") or not denim_lesson.contains(denim_rules[i]):
			denim_ok = false
		if i == 0 and denim_lesson.count(".") != 1:
			denim_ok = false
	_check(denim_ok, "the denim is numbered 165 through 170 and each banner names its rule")
	var first_denim: Dictionary = Puzzles.get_puzzle(164)
	_check(str(first_denim["lesson"]).count(".") == 1, "room 165 states the denim rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[28]["name"]) == "Canvas Wing" and int(wings[28]["count"]) == 6 and int(wings[28]["first"]) == 170,
		"the canvas has 6 puzzles"
	)
	var canvas_titles: PackedStringArray = PackedStringArray([
		"The Lit Canvas",
		"The Seen Sail",
		"The Passed Bolt",
		"The Open Canvas",
		"The Quenched Step",
		"The Last Canvas",
	])
	var canvas_ok := true
	var canvas_rules: PackedStringArray = PackedStringArray([
		"the canvas is lit",
		"the guard sees a lit tile through the lit canvas",
		"a second lamp's light passes through the canvas",
		"a guard can enter the canvas",
		"the early step onto the lit canvas succeeds and puts it out",
		"you leave by stepping on the canvas, and that step puts it out",
	])
	for i in canvas_titles.size():
		var canvas_room: Dictionary = Puzzles.get_puzzle(170 + i)
		var canvas_lesson := str(canvas_room["lesson"])
		if str(canvas_room["title"]) != canvas_titles[i] or str(canvas_room["wing"]) != "Canvas Wing" or int(canvas_room["wing_number"]) != i + 1 or int(canvas_room["number"]) != 171 + i:
			canvas_ok = false
		if not canvas_lesson.begins_with("This room is about the rule that ") or not canvas_lesson.contains(canvas_rules[i]):
			canvas_ok = false
		if i == 0 and canvas_lesson.count(".") != 1:
			canvas_ok = false
	_check(canvas_ok, "the canvas is numbered 171 through 176 and each banner names its rule")
	var first_canvas: Dictionary = Puzzles.get_puzzle(170)
	_check(str(first_canvas["lesson"]).count(".") == 1, "room 171 states the canvas rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[29]["name"]) == "Drill Wing" and int(wings[29]["count"]) == 6 and int(wings[29]["first"]) == 176,
		"the drill has 6 puzzles"
	)
	var drill_titles: PackedStringArray = PackedStringArray([
		"The Lit Drill",
		"The Hidden Drill",
		"The Passed Weave",
		"The Open Drill",
		"The Spent Step",
		"The Last Drill",
	])
	var drill_ok := true
	var drill_rules: PackedStringArray = PackedStringArray([
		"the drill is lit",
		"the guard does not see a lit tile through the lit drill",
		"a second lamp's light passes through the drill",
		"a guard can enter the drill",
		"the early step onto the lit drill succeeds and puts it out",
		"you leave by stepping on the drill, and that step puts it out",
	])
	for i in drill_titles.size():
		var drill_room: Dictionary = Puzzles.get_puzzle(176 + i)
		var drill_lesson := str(drill_room["lesson"])
		if str(drill_room["title"]) != drill_titles[i] or str(drill_room["wing"]) != "Drill Wing" or int(drill_room["wing_number"]) != i + 1 or int(drill_room["number"]) != 177 + i:
			drill_ok = false
		if not drill_lesson.begins_with("This room is about the rule that ") or not drill_lesson.contains(drill_rules[i]):
			drill_ok = false
		if i == 0 and drill_lesson.count(".") != 1:
			drill_ok = false
	_check(drill_ok, "the drill is numbered 177 through 182 and each banner names its rule")
	var first_drill: Dictionary = Puzzles.get_puzzle(176)
	_check(str(first_drill["lesson"]).count(".") == 1, "room 177 states the drill rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[30]["name"]) == "Twill Wing" and int(wings[30]["count"]) == 6 and int(wings[30]["first"]) == 182,
		"the twill has 6 puzzles"
	)
	var twill_titles: PackedStringArray = PackedStringArray([
		"The Dark Twill",
		"The Hidden Twill",
		"The Passed Thread",
		"The Open Twill",
		"The Kindled Step",
		"The Last Twill",
	])
	var twill_ok := true
	var twill_rules: PackedStringArray = PackedStringArray([
		"the twill starts dark",
		"the guard does not see a lit tile through the dark twill",
		"a second lamp's light passes through the dark twill",
		"a guard can enter the dark twill",
		"the early step onto the dark twill succeeds and lights it",
		"you leave by stepping on the dark twill, and that step lights it",
	])
	for i in twill_titles.size():
		var twill_room: Dictionary = Puzzles.get_puzzle(182 + i)
		var twill_lesson := str(twill_room["lesson"])
		if str(twill_room["title"]) != twill_titles[i] or str(twill_room["wing"]) != "Twill Wing" or int(twill_room["wing_number"]) != i + 1 or int(twill_room["number"]) != 183 + i:
			twill_ok = false
		if not twill_lesson.begins_with("This room is about the rule that ") or not twill_lesson.contains(twill_rules[i]):
			twill_ok = false
		if i == 0 and twill_lesson.count(".") != 1:
			twill_ok = false
	_check(twill_ok, "the twill is numbered 183 through 188 and each banner names its rule")
	var first_twill: Dictionary = Puzzles.get_puzzle(182)
	_check(str(first_twill["lesson"]).count(".") == 1, "room 183 states the twill rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[31]["name"]) == "Duck Wing" and int(wings[31]["count"]) == 6 and int(wings[31]["first"]) == 188,
		"the duck has 6 puzzles"
	)
	var duck_titles: PackedStringArray = PackedStringArray([
		"The Dark Duck",
		"The Hidden Duck",
		"The Passed Nap",
		"The Open Duck",
		"The Shut Step",
		"The Last Duck",
	])
	var duck_ok := true
	var duck_rules: PackedStringArray = PackedStringArray([
		"the duck stays dark",
		"the guard does not see a lit tile through the dark duck",
		"a second lamp's light passes through the dark duck",
		"a guard can enter the dark duck",
		"the early step onto the dark duck fails and the duck stays dark",
		"the leaving step fails and the duck stays dark",
	])
	for i in duck_titles.size():
		var duck_room: Dictionary = Puzzles.get_puzzle(188 + i)
		var duck_lesson := str(duck_room["lesson"])
		if str(duck_room["title"]) != duck_titles[i] or str(duck_room["wing"]) != "Duck Wing" or int(duck_room["wing_number"]) != i + 1 or int(duck_room["number"]) != 189 + i:
			duck_ok = false
		if not duck_lesson.begins_with("This room is about the rule that ") or not duck_lesson.contains(duck_rules[i]):
			duck_ok = false
		if i == 0 and duck_lesson.count(".") != 1:
			duck_ok = false
	_check(duck_ok, "the duck is numbered 189 through 194 and each banner names its rule")
	var first_duck: Dictionary = Puzzles.get_puzzle(188)
	_check(str(first_duck["lesson"]).count(".") == 1, "room 189 states the duck rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[32]["name"]) == "Nankeen Wing" and int(wings[32]["count"]) == 6 and int(wings[32]["first"]) == 194,
		"the nankeen has 6 puzzles"
	)
	var nankeen_titles: PackedStringArray = PackedStringArray([
		"The Dark Nankeen",
		"The Hidden Nankeen",
		"The Passed Yellow",
		"The Open Nankeen",
		"The Kept Step",
		"The Last Nankeen",
	])
	var nankeen_ok := true
	var nankeen_rules: PackedStringArray = PackedStringArray([
		"the nankeen stays dark",
		"the guard does not see a lit tile through the dark nankeen",
		"a second lamp's light passes through the dark nankeen",
		"a guard can enter the dark nankeen",
		"the early step onto the dark nankeen succeeds and the nankeen stays dark",
		"the leaving step succeeds and the nankeen stays dark",
	])
	for i in nankeen_titles.size():
		var nankeen_room: Dictionary = Puzzles.get_puzzle(194 + i)
		var nankeen_lesson := str(nankeen_room["lesson"])
		if str(nankeen_room["title"]) != nankeen_titles[i] or str(nankeen_room["wing"]) != "Nankeen Wing" or int(nankeen_room["wing_number"]) != i + 1 or int(nankeen_room["number"]) != 195 + i:
			nankeen_ok = false
		if not nankeen_lesson.begins_with("This room is about the rule that ") or not nankeen_lesson.contains(nankeen_rules[i]):
			nankeen_ok = false
		if i == 0 and nankeen_lesson.count(".") != 1:
			nankeen_ok = false
	_check(nankeen_ok, "the nankeen is numbered 195 through 200 and each banner names its rule")
	var first_nankeen: Dictionary = Puzzles.get_puzzle(194)
	_check(str(first_nankeen["lesson"]).count(".") == 1, "room 195 states the nankeen rule in one sentence")
	_check(
		wings.size() == 34 and str(wings[33]["name"]) == "Jean Wing" and int(wings[33]["count"]) == 6 and int(wings[33]["first"]) == 200,
		"the jean has 6 puzzles"
	)
	var jean_titles: PackedStringArray = PackedStringArray([
		"The Dark Jean",
		"The Hidden Jean",
		"The Passed Rivet",
		"The Open Jean",
		"The Lit Step",
		"The Last Jean",
	])
	var jean_ok := true
	var jean_rules: PackedStringArray = PackedStringArray([
		"the jean starts dark",
		"the guard does not see a lit tile through the dark jean",
		"a second lamp's light passes through the dark jean",
		"a guard can enter the dark jean",
		"the early step onto the dark jean succeeds and lights it",
		"the leaving step fails and the player stays on the lit jean",
	])
	for i in jean_titles.size():
		var jean_room: Dictionary = Puzzles.get_puzzle(200 + i)
		var jean_lesson := str(jean_room["lesson"])
		if str(jean_room["title"]) != jean_titles[i] or str(jean_room["wing"]) != "Jean Wing" or int(jean_room["wing_number"]) != i + 1 or int(jean_room["number"]) != 201 + i:
			jean_ok = false
		if not jean_lesson.begins_with("This room is about the rule that ") or not jean_lesson.contains(jean_rules[i]):
			jean_ok = false
		if i == 0 and jean_lesson.count(".") != 1:
			jean_ok = false
	_check(jean_ok, "the jean is numbered 201 through 206 and each banner names its rule")
	var first_jean: Dictionary = Puzzles.get_puzzle(200)
	_check(str(first_jean["lesson"]).count(".") == 1, "room 201 states the jean rule in one sentence")


func _index_of(title: String) -> int:
	for i in Puzzles.count():
		if str(Puzzles.get_puzzle(i)["title"]) == title:
			return i
	return -1


func _check(ok: bool, message: String) -> void:
	if ok:
		_passed += 1
		print("PASS ", message)
	else:
		_failed += 1
		print("FAIL ", message)


func _check_puzzle(index: int) -> void:
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var label := "puzzle %d %s" % [puzzle["number"], puzzle["title"]]
	var state := Puzzles.initial_state(index)
	_check(not Rules.is_win(state), label + " does not start on the exit")
	var won := false
	var clean := true
	for action in puzzle["solution"]:
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] == Rules.Result.LOSS or out["result"] == Rules.Result.ILLEGAL:
			clean = false
			_check(false, "%s solution hit %s (%s) on %s" % [label, out["result"], out["reason"], action])
			break
		state = out["state"]
		if Rules.is_player_watched(state):
			clean = false
			_check(false, label + " solution stands on a watched tile")
			break
		if out["result"] == Rules.Result.WIN:
			won = true
			break
	if clean:
		_check(won, label + " solution wins without standing on a watched tile")


func _check_toggles_required(index: int) -> void:
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var won := false
	for action in puzzle["solution"]:
		var out: Dictionary = Rules.apply(state, action, false)
		if out["result"] == Rules.Result.ILLEGAL:
			continue
		if out["result"] == Rules.Result.LOSS:
			break
		state = out["state"]
		if out["result"] == Rules.Result.WIN:
			won = true
			break
	_check(not won, "puzzle %d fails if lamp toggles are disallowed" % puzzle["number"])


func _check_puzzle_one_needs_no_snuff() -> void:
	var puzzle: Dictionary = Puzzles.get_puzzle(0)
	var snuffs := 0
	for action in puzzle["solution"]:
		if action["type"] == "toggle":
			snuffs += 1
	_check(snuffs == 0, "puzzle 1 is solved without snuffing")


func _check_watched_step_is_loss() -> void:
	# The player starts on a dark tile and steps east onto lit floor inside
	# the guard's diamond. That step is a loss, not a refused move.
	var state := Rules.build(
		PackedStringArray(["######", "#S..X#", "######"]),
		[{"x": 3, "y": 1, "facing": "w", "radius": 1, "lit": true}],
		[{"x": 4, "y": 1, "vision": 3, "rail": [Vector2i(4, 1)]}]
	)
	_check(not Rules.is_player_watched(state), "watched-step fixture does not start watched")
	var out: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var landed: Dictionary = out["state"]["player"]
	_check(
		out["result"] == Rules.Result.LOSS and out["reason"] == "watched" and landed["x"] == 2 and landed["y"] == 1,
		"stepping onto a watched tile is a loss"
	)


func _check_undo_restores_exact_state(index: int) -> void:
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var session = SessionScript.new()
	session.reset(puzzle["rows"], puzzle["lamps"], puzzle["guards"])
	var snaps: Array = [Rules.signature(session.state)]
	for action in puzzle["solution"]:
		var out: Dictionary = session.act(action)
		if out["result"] == Rules.Result.ILLEGAL or out["result"] == Rules.Result.LOSS:
			_check(false, "puzzle %d undo setup could not play the solution" % puzzle["number"])
			return
		snaps.append(Rules.signature(session.state))
	var ok := true
	for i in range(snaps.size() - 1, 0, -1):
		if not session.undo():
			ok = false
			break
		if Rules.signature(session.state) != snaps[i - 1]:
			ok = false
			break
	_check(ok, "puzzle %d undo restores each prior state" % puzzle["number"])
	var stuck := Rules.signature(session.state)
	_check(not session.undo() and Rules.signature(session.state) == stuck, "puzzle %d undo stops at the start" % puzzle["number"])


func _check_alert_step() -> void:
	# Puzzle 3. After the snuff, the called guard has not moved yet.
	# His next step is the tile east of where he started: (2, 1).
	var puzzle: Dictionary = Puzzles.get_puzzle(2)
	var state := Puzzles.initial_state(2)
	var saw := false
	for action in puzzle["solution"]:
		if action["type"] != "toggle":
			var before: Dictionary = Rules.apply(state, action)
			if before["result"] != Rules.Result.OK:
				_check(false, "puzzle 3 approach failed before the snuff")
				return
			state = before["state"]
			continue
		var guard_before: Dictionary = state["guards"][0]
		var out: Dictionary = Rules.apply(state, action)
		var guard_after: Dictionary = out["state"]["guards"][0]
		saw = true
		_check(out["result"] == Rules.Result.OK, "puzzle 3 snuff resolves")
		_check(out["called"] == 0, "puzzle 3 snuff calls guard 0")
		_check(out["step"] == Vector2i(2, 1), "after the snuff the called guard will step to (2, 1)")
		_check(
			guard_after["x"] == guard_before["x"] and guard_after["y"] == guard_before["y"],
			"the called guard has not taken that step yet"
		)
		_check(Rules.planned_step(out["state"], 0) == Vector2i(2, 1), "the alert arrow agrees with (2, 1)")
		_check(guard_after["alert"] and guard_after["ax"] == 7 and guard_after["ay"] == 1, "the call targets the snuffed lamp")
		break
	_check(saw, "puzzle 3 solution contains a snuff")


func _check_west_lit_step_still_loses() -> void:
	# The Broken Sightline. Three steps east along the dark row, then one more
	# step onto the lit tile the guard is watching. That step is a loss.
	var index := _index_of("The Broken Sightline")
	var state := Puzzles.initial_state(index)
	var approach := ["R", "R", "R"]
	var clean := true
	for token in approach:
		var step: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
		if step["result"] != Rules.Result.OK:
			clean = false
			_check(false, "sightline approach failed before the lit step (%s)" % token)
			return
		state = step["state"]
	_check(clean, "sightline approach stays on dark floor")
	var player: Dictionary = state["player"]
	var dest := Vector2i(int(player["x"]) + 1, int(player["y"]))
	_check(Rules.light_map(state).has(dest), "the sightline step lands on lamplight")
	_check(Rules.watched_tiles(state).has(dest), "a guard is watching that lit tile")
	var out: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var landed: Dictionary = out["state"]["player"]
	_check(
		out["result"] == Rules.Result.LOSS and out["reason"] == "watched" and landed["x"] == dest.x and landed["y"] == dest.y,
		"a watched lit step still loses"
	)


func _check_unwatched_lit_floor_is_refused() -> void:
	# The Second Wick. North of the lamp is dark. The floor directly in front
	# of its side is lit, and the cellar guard cannot see it. The step is refused.
	var index := _index_of("The Second Wick")
	var state := Puzzles.initial_state(index)
	var moves := [
		{"type": "move", "dx": 1, "dy": 0},
		{"type": "move", "dx": 1, "dy": 0},
		{"type": "move", "dx": 1, "dy": 0},
		{"type": "move", "dx": 1, "dy": 0},
		{"type": "move", "dx": 0, "dy": 1},
	]
	for action in moves:
		var step: Dictionary = Rules.apply(state, action)
		if step["result"] != Rules.Result.OK:
			_check(false, "wick approach failed before the lit floor")
			return
		state = step["state"]
	var before: Dictionary = state["player"]
	var out: Dictionary = Rules.apply(state, {"type": "move", "dx": 0, "dy": 1})
	var after: Dictionary = out["state"]["player"]
	_check(
		out["result"] == Rules.Result.ILLEGAL and out["reason"] == "lit" and after["x"] == before["x"] and after["y"] == before["y"],
		"unwatched lit floor is still refused"
	)


func _check_lower_seal_tie() -> void:
	var index := _index_of("The Lower Seal")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var saw := false
	for action in puzzle["solution"]:
		if action["type"] != "toggle":
			var before: Dictionary = Rules.apply(state, action)
			if before["result"] != Rules.Result.OK:
				_check(false, "lower seal approach failed")
				return
			state = before["state"]
			continue
		var lamp: Dictionary = state["lamps"][int(action["lamp"])]
		var dist0 := absi(int(state["guards"][0]["x"]) - int(lamp["x"])) + absi(int(state["guards"][0]["y"]) - int(lamp["y"]))
		var dist1 := absi(int(state["guards"][1]["x"]) - int(lamp["x"])) + absi(int(state["guards"][1]["y"]) - int(lamp["y"]))
		var out: Dictionary = Rules.apply(state, action)
		saw = true
		_check(dist0 == dist1, "both keepers stand the same distance from the lamp")
		_check(out["result"] == Rules.Result.OK and out["called"] == 0, "the tie calls the lower keeper")
		_check(int(out["state"]["guards"][1]["x"]) == int(state["guards"][1]["x"]) and int(out["state"]["guards"][1]["y"]) == int(state["guards"][1]["y"]) and not out["state"]["guards"][1]["alert"], "the east keeper is not called")
		break
	_check(saw, "the lower seal solution snuffs the lamp")


func _check_second_wick_relights() -> void:
	var index := _index_of("The Second Wick")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var toggles := 0
	for action in puzzle["solution"]:
		if action["type"] == "toggle" and int(action["lamp"]) == 0:
			toggles += 1
	_check(toggles == 2, "the second wick snuffs and relights the same lamp")


func _check_lit_door_starts_lit() -> void:
	var index := _index_of("The Lit Door")
	var state := Puzzles.initial_state(index)
	var lit: Dictionary = Rules.light_map(state)
	var found := false
	for y in state["h"]:
		for x in state["w"]:
			if Rules.tile_at(state, x, y) == Rules.Tile.EXIT:
				found = true
				_check(lit.has(Vector2i(x, y)), "the lit door's exit starts inside a lamp")
	_check(found, "the lit door has an exit")


func _check_second_call_uses_both_lamps() -> void:
	var index := _index_of("The Second Call")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var seen := {}
	for action in puzzle["solution"]:
		if action["type"] == "toggle":
			seen[int(action["lamp"])] = true
	_check(seen.has(0) and seen.has(1), "the second call snuffs both lamps")


func _check_west_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "West Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_puzzle_select_shows_both_wings() -> void:
	var packed: PackedScene = load("res://game/main.tscn")
	var main = packed.instantiate()
	# _ready is deferred until the idle frame, so build the select rows directly.
	main._build_hud()
	var east := false
	var west := false
	var north := false
	var south := false
	var attic := false
	var cellar := false
	var gallery := false
	var court := false
	var nave := false
	var cloister := false
	var porch := false
	var oriel := false
	var veil := false
	var shade := false
	var screen := false
	var glaze := false
	var mica := false
	var baize := false
	var scrim := false
	var gauze := false
	var voile := false
	var lawn := false
	var muslin := false
	var cambric := false
	var holland := false
	var buckram := false
	var ticking := false
	var denim := false
	var canvas := false
	var drill := false
	var twill := false
	var duck := false
	var nankeen := false
	var jean := false
	var nave_buttons := PackedStringArray()
	var nave_tips := PackedStringArray()
	var cloister_buttons := PackedStringArray()
	var cloister_tips := PackedStringArray()
	var porch_buttons := PackedStringArray()
	var porch_tips := PackedStringArray()
	var oriel_buttons := PackedStringArray()
	var oriel_tips := PackedStringArray()
	var veil_buttons := PackedStringArray()
	var veil_tips := PackedStringArray()
	var shade_buttons := PackedStringArray()
	var shade_tips := PackedStringArray()
	var screen_buttons := PackedStringArray()
	var screen_tips := PackedStringArray()
	var glaze_buttons := PackedStringArray()
	var glaze_tips := PackedStringArray()
	var mica_buttons := PackedStringArray()
	var mica_tips := PackedStringArray()
	var baize_buttons := PackedStringArray()
	var baize_tips := PackedStringArray()
	var scrim_buttons := PackedStringArray()
	var scrim_tips := PackedStringArray()
	var gauze_buttons := PackedStringArray()
	var gauze_tips := PackedStringArray()
	var voile_buttons := PackedStringArray()
	var voile_tips := PackedStringArray()
	var lawn_buttons := PackedStringArray()
	var lawn_tips := PackedStringArray()
	var muslin_buttons := PackedStringArray()
	var muslin_tips := PackedStringArray()
	var cambric_buttons := PackedStringArray()
	var cambric_tips := PackedStringArray()
	var holland_buttons := PackedStringArray()
	var holland_tips := PackedStringArray()
	var buckram_buttons := PackedStringArray()
	var buckram_tips := PackedStringArray()
	var ticking_buttons := PackedStringArray()
	var ticking_tips := PackedStringArray()
	var denim_buttons := PackedStringArray()
	var denim_tips := PackedStringArray()
	var canvas_buttons := PackedStringArray()
	var canvas_tips := PackedStringArray()
	var drill_buttons := PackedStringArray()
	var drill_tips := PackedStringArray()
	var twill_buttons := PackedStringArray()
	var twill_tips := PackedStringArray()
	var duck_buttons := PackedStringArray()
	var duck_tips := PackedStringArray()
	var nankeen_buttons := PackedStringArray()
	var nankeen_tips := PackedStringArray()
	var jean_buttons := PackedStringArray()
	var jean_tips := PackedStringArray()
	var wing_y := {}
	var legend_y := -1.0
	var legend := ""
	var hint := ""
	var puzzle_buttons := 0
	var stack: Array = [main]
	while not stack.is_empty():
		var node: Node = stack.pop_back()
		if node is Label:
			var label := node as Label
			if label.text == "East Wing" or label.text == "West Wing" or label.text == "North Wing" or label.text == "South Wing" or label.text == "Attic Wing" or label.text == "Cellar Wing" or label.text == "Gallery Wing" or label.text == "Court Wing" or label.text == "Nave Wing" or label.text == "Cloister Wing" or label.text == "Porch Wing" or label.text == "Oriel Wing" or label.text == "Veil Wing" or label.text == "Shade Wing" or label.text == "Screen Wing" or label.text == "Glaze Wing" or label.text == "Mica Wing" or label.text == "Baize Wing" or label.text == "Scrim Wing" or label.text == "Gauze Wing" or label.text == "Voile Wing" or label.text == "Lawn Wing" or label.text == "Muslin Wing" or label.text == "Cambric Wing" or label.text == "Holland Wing" or label.text == "Buckram Wing" or label.text == "Ticking Wing" or label.text == "Denim Wing" or label.text == "Canvas Wing" or label.text == "Drill Wing" or label.text == "Twill Wing" or label.text == "Duck Wing" or label.text == "Nankeen Wing" or label.text == "Jean Wing":
				wing_y[label.text] = label.get_parent().position.y
			if label.text == "East Wing":
				east = true
			elif label.text == "West Wing":
				west = true
			elif label.text == "North Wing":
				north = true
			elif label.text == "South Wing":
				south = true
			elif label.text == "Attic Wing":
				attic = true
			elif label.text == "Cellar Wing":
				cellar = true
			elif label.text == "Gallery Wing":
				gallery = true
			elif label.text == "Court Wing":
				court = true
			elif label.text == "Nave Wing":
				nave = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						nave_buttons.append((child as Button).text)
						nave_tips.append((child as Button).tooltip_text)
			elif label.text == "Cloister Wing":
				cloister = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						cloister_buttons.append((child as Button).text)
						cloister_tips.append((child as Button).tooltip_text)
			elif label.text == "Porch Wing":
				porch = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						porch_buttons.append((child as Button).text)
						porch_tips.append((child as Button).tooltip_text)
			elif label.text == "Oriel Wing":
				oriel = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						oriel_buttons.append((child as Button).text)
						oriel_tips.append((child as Button).tooltip_text)
			elif label.text == "Veil Wing":
				veil = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						veil_buttons.append((child as Button).text)
						veil_tips.append((child as Button).tooltip_text)
			elif label.text == "Shade Wing":
				shade = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						shade_buttons.append((child as Button).text)
						shade_tips.append((child as Button).tooltip_text)
			elif label.text == "Screen Wing":
				screen = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						screen_buttons.append((child as Button).text)
						screen_tips.append((child as Button).tooltip_text)
			elif label.text == "Glaze Wing":
				glaze = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						glaze_buttons.append((child as Button).text)
						glaze_tips.append((child as Button).tooltip_text)
			elif label.text == "Mica Wing":
				mica = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						mica_buttons.append((child as Button).text)
						mica_tips.append((child as Button).tooltip_text)
			elif label.text == "Baize Wing":
				baize = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						baize_buttons.append((child as Button).text)
						baize_tips.append((child as Button).tooltip_text)
			elif label.text == "Scrim Wing":
				scrim = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						scrim_buttons.append((child as Button).text)
						scrim_tips.append((child as Button).tooltip_text)
			elif label.text == "Gauze Wing":
				gauze = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						gauze_buttons.append((child as Button).text)
						gauze_tips.append((child as Button).tooltip_text)
			elif label.text == "Voile Wing":
				voile = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						voile_buttons.append((child as Button).text)
						voile_tips.append((child as Button).tooltip_text)
			elif label.text == "Lawn Wing":
				lawn = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						lawn_buttons.append((child as Button).text)
						lawn_tips.append((child as Button).tooltip_text)
			elif label.text == "Muslin Wing":
				muslin = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						muslin_buttons.append((child as Button).text)
						muslin_tips.append((child as Button).tooltip_text)
			elif label.text == "Cambric Wing":
				cambric = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						cambric_buttons.append((child as Button).text)
						cambric_tips.append((child as Button).tooltip_text)
			elif label.text == "Holland Wing":
				holland = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						holland_buttons.append((child as Button).text)
						holland_tips.append((child as Button).tooltip_text)
			elif label.text == "Buckram Wing":
				buckram = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						buckram_buttons.append((child as Button).text)
						buckram_tips.append((child as Button).tooltip_text)
			elif label.text == "Ticking Wing":
				ticking = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						ticking_buttons.append((child as Button).text)
						ticking_tips.append((child as Button).tooltip_text)
			elif label.text == "Denim Wing":
				denim = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						denim_buttons.append((child as Button).text)
						denim_tips.append((child as Button).tooltip_text)
			elif label.text == "Canvas Wing":
				canvas = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						canvas_buttons.append((child as Button).text)
						canvas_tips.append((child as Button).tooltip_text)
			elif label.text == "Drill Wing":
				drill = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						drill_buttons.append((child as Button).text)
						drill_tips.append((child as Button).tooltip_text)
			elif label.text == "Twill Wing":
				twill = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						twill_buttons.append((child as Button).text)
						twill_tips.append((child as Button).tooltip_text)
			elif label.text == "Duck Wing":
				duck = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						duck_buttons.append((child as Button).text)
						duck_tips.append((child as Button).tooltip_text)
			elif label.text == "Nankeen Wing":
				nankeen = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						nankeen_buttons.append((child as Button).text)
						nankeen_tips.append((child as Button).tooltip_text)
			elif label.text == "Jean Wing":
				jean = true
				for child in label.get_parent().get_children():
					if child is Button and str((child as Button).text).is_valid_int():
						jean_buttons.append((child as Button).text)
						jean_tips.append((child as Button).tooltip_text)
			elif label.text.begins_with("Gold diamond"):
				legend_y = label.position.y
				legend = label.text
			elif label.text.begins_with("Arrows move"):
				hint = label.text
		elif node is Button:
			var caption := (node as Button).text
			if caption.is_valid_int():
				puzzle_buttons += 1
		for child in node.get_children():
			stack.append(child)
	_check(east and west and north and south and attic and cellar and gallery and court and nave and cloister and porch and oriel and veil and shade and screen and glaze and mica and baize and scrim and gauze and voile and lawn and muslin and cambric and holland and buckram and ticking and denim and canvas and drill and twill and duck and nankeen and jean, "puzzle select shows all thirty-four wings")
	_check(
		wing_y.has("East Wing") and wing_y.has("West Wing") and wing_y.has("North Wing") and wing_y.has("South Wing") and wing_y.has("Attic Wing") and wing_y.has("Cellar Wing") and wing_y.has("Gallery Wing") and wing_y.has("Court Wing") and wing_y.has("Nave Wing") and wing_y.has("Cloister Wing") and wing_y.has("Porch Wing") and wing_y.has("Oriel Wing") and wing_y.has("Veil Wing") and wing_y.has("Shade Wing") and wing_y.has("Screen Wing") and float(wing_y["East Wing"]) < float(wing_y["West Wing"]) and float(wing_y["West Wing"]) < float(wing_y["North Wing"]) and float(wing_y["North Wing"]) < float(wing_y["South Wing"]) and float(wing_y["South Wing"]) < float(wing_y["Attic Wing"]) and float(wing_y["Attic Wing"]) < float(wing_y["Cellar Wing"]) and float(wing_y["Cellar Wing"]) < float(wing_y["Gallery Wing"]) and float(wing_y["Gallery Wing"]) < float(wing_y["Court Wing"]) and float(wing_y["Court Wing"]) < float(wing_y["Nave Wing"]) and float(wing_y["Nave Wing"]) < float(wing_y["Cloister Wing"]) and float(wing_y["Cloister Wing"]) < float(wing_y["Porch Wing"]) and float(wing_y["Porch Wing"]) < float(wing_y["Oriel Wing"]) and float(wing_y["Oriel Wing"]) < float(wing_y["Veil Wing"]) and float(wing_y["Veil Wing"]) < float(wing_y["Shade Wing"]) and float(wing_y["Shade Wing"]) < float(wing_y["Screen Wing"]) and wing_y.has("Glaze Wing") and float(wing_y["Screen Wing"]) < float(wing_y["Glaze Wing"]) and wing_y.has("Mica Wing") and float(wing_y["Glaze Wing"]) < float(wing_y["Mica Wing"]) and wing_y.has("Baize Wing") and float(wing_y["Mica Wing"]) < float(wing_y["Baize Wing"]) and wing_y.has("Scrim Wing") and float(wing_y["Baize Wing"]) < float(wing_y["Scrim Wing"]) and wing_y.has("Gauze Wing") and float(wing_y["Scrim Wing"]) < float(wing_y["Gauze Wing"]) and wing_y.has("Voile Wing") and float(wing_y["Gauze Wing"]) < float(wing_y["Voile Wing"]) and wing_y.has("Lawn Wing") and float(wing_y["Voile Wing"]) < float(wing_y["Lawn Wing"]) and wing_y.has("Muslin Wing") and float(wing_y["Lawn Wing"]) < float(wing_y["Muslin Wing"]) and wing_y.has("Cambric Wing") and float(wing_y["Muslin Wing"]) < float(wing_y["Cambric Wing"]) and wing_y.has("Holland Wing") and float(wing_y["Cambric Wing"]) < float(wing_y["Holland Wing"]) and wing_y.has("Buckram Wing") and float(wing_y["Holland Wing"]) < float(wing_y["Buckram Wing"]) and wing_y.has("Ticking Wing") and float(wing_y["Buckram Wing"]) < float(wing_y["Ticking Wing"]) and wing_y.has("Denim Wing") and float(wing_y["Ticking Wing"]) < float(wing_y["Denim Wing"]) and wing_y.has("Canvas Wing") and float(wing_y["Denim Wing"]) < float(wing_y["Canvas Wing"]) and wing_y.has("Drill Wing") and float(wing_y["Canvas Wing"]) < float(wing_y["Drill Wing"]) and wing_y.has("Twill Wing") and float(wing_y["Drill Wing"]) < float(wing_y["Twill Wing"]) and wing_y.has("Duck Wing") and float(wing_y["Twill Wing"]) < float(wing_y["Duck Wing"]) and wing_y.has("Nankeen Wing") and float(wing_y["Duck Wing"]) < float(wing_y["Nankeen Wing"]) and wing_y.has("Jean Wing") and float(wing_y["Nankeen Wing"]) < float(wing_y["Jean Wing"]),
		"the thirty-four wings are listed in order"
	)
	_check(legend_y >= float(wing_y["Cellar Wing"]) + 32.0, "the cellar row sits above the legend")
	_check(legend_y >= float(wing_y["Gallery Wing"]) + 32.0, "the gallery row sits above the legend")
	_check(legend_y >= float(wing_y["Court Wing"]) + 32.0, "the court row sits above the legend")
	_check(legend_y >= float(wing_y["Nave Wing"]) + 32.0, "the nave row sits above the legend")
	_check(legend_y >= float(wing_y["Cloister Wing"]) + 32.0, "the cloister row sits above the legend")
	_check(legend_y >= float(wing_y["Porch Wing"]) + 32.0, "the porch row sits above the legend")
	_check(legend_y >= float(wing_y["Oriel Wing"]) + 32.0, "the oriel row sits above the legend")
	_check(legend_y >= float(wing_y["Veil Wing"]) + 32.0, "the veil row sits above the legend")
	_check(legend_y >= float(wing_y["Shade Wing"]) + 32.0, "the shade row sits above the legend")
	_check(legend_y >= float(wing_y["Screen Wing"]) + 32.0, "the screen row sits above the legend")
	_check(legend_y >= float(wing_y["Glaze Wing"]) + 32.0, "the glaze row sits above the legend")
	_check(legend_y >= float(wing_y["Mica Wing"]) + 32.0, "the mica row sits above the legend")
	_check(legend_y >= float(wing_y["Baize Wing"]) + 32.0, "the baize row sits above the legend")
	_check(legend_y >= float(wing_y["Scrim Wing"]) + 32.0, "the scrim row sits above the legend")
	_check(legend_y >= float(wing_y["Gauze Wing"]) + 32.0, "the gauze row sits above the legend")
	_check(legend_y >= float(wing_y["Voile Wing"]) + 32.0, "the voile row sits above the legend")
	_check(legend_y >= float(wing_y["Lawn Wing"]) + 32.0, "the lawn row sits above the legend")
	_check(legend_y >= float(wing_y["Muslin Wing"]) + 32.0, "the muslin row sits above the legend")
	_check(legend_y >= float(wing_y["Cambric Wing"]) + 32.0, "the cambric row sits above the legend")
	_check(legend_y >= float(wing_y["Holland Wing"]) + 32.0, "the holland row sits above the legend")
	_check(legend_y >= float(wing_y["Buckram Wing"]) + 32.0, "the buckram row sits above the legend")
	_check(legend_y >= float(wing_y["Ticking Wing"]) + 32.0, "the ticking row sits above the legend")
	_check(legend_y >= float(wing_y["Denim Wing"]) + 32.0, "the denim row sits above the legend")
	_check(legend_y >= float(wing_y["Canvas Wing"]) + 32.0, "the canvas row sits above the legend")
	_check(legend_y >= float(wing_y["Drill Wing"]) + 32.0, "the drill row sits above the legend")
	_check(legend_y >= float(wing_y["Twill Wing"]) + 32.0, "the twill row sits above the legend")
	_check(legend_y >= float(wing_y["Duck Wing"]) + 32.0, "the duck row sits above the legend")
	_check(legend_y >= float(wing_y["Nankeen Wing"]) + 32.0, "the nankeen row sits above the legend")
	_check(legend_y >= float(wing_y["Jean Wing"]) + 32.0, "the jean row sits above the legend")
	_check(float(wing_y["East Wing"]) == 106.0, "the wing rows start at y 106")
	_check(nave_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the nave row is labeled 1 through 6")
	_check(
		nave_tips == PackedStringArray(["The First Bell", "The Quiet Bell", "The Far Bell", "The Lit Bell", "The Bell Gap", "The Last Ring"]),
		"the nave buttons name the six bells"
	)
	_check(cloister_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the cloister row is labeled 1 through 6")
	_check(
		cloister_tips == PackedStringArray(["The First Grate", "The Passed Light", "The Dark Cut", "The Long Road", "The Lit Edge", "The Last Grate"]),
		"the cloister buttons name the six grates"
	)
	_check(hint.contains("Alt+1–6 south"), "the control hint names the south binding")
	_check(hint.contains("F1–F6 attic"), "the control hint names the attic binding")
	_check(hint.contains("F7–F12 cellar"), "the control hint names the cellar binding")
	_check(hint.contains("Keypad 1–6 gallery"), "the control hint names the gallery binding")
	_check(hint.contains("Shift+F1–F6 court"), "the control hint names the court binding")
	_check(hint.contains("Alt+F1–F6 nave"), "the control hint names the nave binding")
	_check(hint.contains("Ctrl+F1–F6 cloister"), "the control hint names the cloister binding")
	_check(hint.contains("Ctrl+Shift+F1–F6 porch"), "the control hint names the porch binding")
	_check(hint.contains("Alt+Shift+F1–F6 oriel"), "the control hint names the oriel binding")
	_check(hint.contains("Alt+Shift+1–6 veil"), "the control hint names the veil binding")
	_check(hint.contains("Ctrl+Alt+1–6 shade"), "the control hint names the shade binding")
	_check(legend.contains("Iron bars"), "the legend names the grate as iron bars")
	_check(legend.contains("Stone sill"), "the legend names the sill as stone")
	_check(legend.contains("Pale sheet"), "the legend names the pane as a pale sheet")
	_check(legend.contains("Dark cloth"), "the legend names the curtain as dark cloth")
	_check(legend.contains("Dark louver"), "the legend names the shade as a dark louver")
	_check(legend.contains("Pale lattice"), "the legend names the screen as a pale lattice")
	_check(legend.contains("Ivory sheet, bright cross"), "the legend names the glaze as an ivory sheet with a bright cross")
	_check(legend.contains("Pale gray sheet, dark ring"), "the legend names the mica as a pale gray sheet with a dark ring")
	_check(legend.contains("Deep green cloth, pale hem"), "the legend names the baize as a deep green cloth with a pale hem")
	_check(legend.contains("Pale gold cloth, dark thread"), "the legend names the scrim as a pale gold cloth with a dark thread")
	_check(legend.contains("Pale cloth, open stitches"), "the legend names the gauze as a pale cloth with open stitches")
	var legend_text_h := ThemeDB.fallback_font.get_multiline_string_size(legend, HORIZONTAL_ALIGNMENT_LEFT, 1240.0, 14).y
	var controls_text_h := ThemeDB.fallback_font.get_multiline_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, 1240.0, 14).y
	_check(legend.contains("Pale sheer, broken slant"), "the legend names the voile as a pale sheer with a broken slant")
	_check(legend.contains("Green field, short blades"), "the legend names the lawn as a green field with short blades")
	_check(legend.contains("Cream cloth, loose threads"), "the legend names the muslin as a cream cloth with loose threads")
	_check(legend.contains("Close stripes"), "the legend names the ticking as close stripes")
	_check(legend.contains("Blue twill"), "the legend names the denim as blue twill")
	_check(legend.contains("Unbleached cloth"), "the legend names the canvas as unbleached cloth")
	_check(legend.contains("Khaki twill"), "the legend names the drill as khaki twill")
	_check(legend.contains("Pale herringbone"), "the legend names the twill as a pale herringbone")
	_check(legend.contains("Oatmeal cloth"), "the legend names the duck as oatmeal cloth")
	_check(legend.contains("Yellow cloth"), "the legend names the nankeen as yellow cloth")
	_check(legend.contains("Faded blue"), "the legend names the jean as faded blue")
	_check(legend_text_h <= 260.0, "the legend text fits the legend box")
	_check(controls_text_h <= 100.0, "the control hint fits above the first wing")
	_check(hint.contains("Ctrl+Shift+1–6 screen"), "the control hint names the screen binding")
	_check(hint.contains("Ctrl+Alt+Shift+1–6 glaze"), "the control hint names the glaze binding")
	_check(hint.contains("Ctrl+Alt+Shift+F1–F6 mica"), "the control hint names the mica binding")
	_check(hint.contains("Meta+Ctrl+Alt+Shift+F1–F6 baize"), "the control hint names the baize binding")
	_check(hint.contains("Meta+Ctrl+Alt+Shift+1–6 scrim"), "the control hint names the scrim binding")
	_check(hint.contains("Meta+Ctrl+Alt+1–6 gauze"), "the control hint names the gauze binding")
	_check(hint.contains("Meta+Alt+1–6 voile"), "the control hint names the voile binding")
	_check(hint.contains("Meta+Alt+Shift+1–6 lawn"), "the control hint names the lawn binding")
	_check(hint.contains("Meta+Shift+1–6 muslin"), "the control hint names the muslin binding")
	_check(hint.contains("Meta+Alt+Shift+F1–F6 holland"), "the control hint names the holland binding")
	_check(hint.contains("Meta+F13–F18 buckram"), "the control hint names the buckram binding")
	_check(hint.contains("Meta+Ctrl+F13–F18 ticking"), "the control hint names the ticking binding")
	_check(hint.contains("Meta+Alt+F13–F18 denim"), "the control hint names the denim binding")
	_check(hint.contains("Meta+Shift+F13–F18 canvas"), "the control hint names the canvas binding")
	_check(hint.contains("Meta+Ctrl+Alt+F13–F18 drill"), "the control hint names the drill binding")
	_check(hint.contains("Meta+Ctrl+Shift+F13–F18 twill"), "the control hint names the twill binding")
	_check(hint.contains("Meta+Alt+Shift+F13–F18 duck"), "the control hint names the duck binding")
	_check(hint.contains("Meta+Ctrl+Alt+Shift+F13–F18 nankeen"), "the control hint names the nankeen binding")
	_check(hint.contains("Meta+F19–F24 jean"), "the control hint names the jean binding")
	_check(mica_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the mica row is labeled 1 through 6")
	_check(
		mica_tips == PackedStringArray(["The Dark Step", "The Seen Gap", "The Passed Lamp", "The Long Road", "The Early Catch", "The Last Mica"]),
		"the mica buttons name the six micas"
	)
	_check(baize_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the baize row is labeled 1 through 6")
	_check(
		baize_tips == PackedStringArray(["The Dark Cloth", "The Seen Hem", "The Stopped Lamp", "The Long Cloth", "The Early Hem", "The Last Baize"]),
		"the baize buttons name the six baizes"
	)
	_check(scrim_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the scrim row is labeled 1 through 6")
	_check(
		scrim_tips == PackedStringArray(["The Lit Scrim", "The Seen Thread", "The Halted Wick", "The Closed Scrim", "The Early Thread", "The Last Scrim"]),
		"the scrim buttons name the six scrims"
	)
	_check(gauze_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the gauze row is labeled 1 through 6")
	_check(
		gauze_tips == PackedStringArray(["The Lit Gauze", "The Seen Mesh", "The Passed Flame", "The Open Gauze", "The Early Mesh", "The Last Gauze"]),
		"the gauze buttons name the six gauzes"
	)
	_check(voile_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the voile row is labeled 1 through 6")
	_check(
		voile_tips == PackedStringArray(["The Lit Voile", "The Seen Weave", "The Passed Spark", "The Shut Voile", "The Early Step", "The Last Voile"]),
		"the voile buttons name the six voiles"
	)
	_check(lawn_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the lawn row is labeled 1 through 6")
	_check(
		lawn_tips == PackedStringArray(["The Lit Lawn", "The Seen Sward", "The Halted Gleam", "The Barred Lawn", "The Early Tread", "The Last Lawn"]),
		"the lawn buttons name the six lawns"
	)
	_check(muslin_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the muslin row is labeled 1 through 6")
	_check(
		muslin_tips == PackedStringArray(["The Lit Muslin", "The Seen Warp", "The Halted Sheen", "The Open Muslin", "The Refused Entry", "The Last Muslin"]),
		"the muslin buttons name the six muslins"
	)
	_check(cambric_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the cambric row is labeled 1 through 6")
	_check(
		cambric_tips == PackedStringArray(["The Lit Cambric", "The Seen Weft", "The Halted Glow", "The Walked Cambric", "The Sure Landing", "The Last Cambric"]),
		"the cambric buttons name the six cambrics"
	)
	_check(holland_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the holland row is labeled 1 through 6")
	_check(
		holland_tips == PackedStringArray(["The Lit Holland", "The Seen Grain", "The Passed Ray", "The Trod Holland", "The Firm Footing", "The Last Holland"]),
		"the holland buttons name the six hollands"
	)
	_check(buckram_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the buckram row is labeled 1 through 6")
	_check(
		buckram_tips == PackedStringArray(["The Lit Buckram", "The Seen Rib", "The Passed Beam", "The Open Buckram", "The Barred Step", "The Last Buckram"]),
		"the buckram buttons name the six buckrams"
	)
	_check(ticking_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the ticking row is labeled 1 through 6")
	_check(
		ticking_tips == PackedStringArray(["The Lit Ticking", "The Hidden Stripe", "The Passed Stripe", "The Open Ticking", "The Clear Step", "The Last Ticking"]),
		"the ticking buttons name the six tickings"
	)
	_check(denim_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the denim row is labeled 1 through 6")
	_check(
		denim_tips == PackedStringArray(["The Lit Denim", "The Seen Twill", "The Passed Seam", "The Open Denim", "The Sure Tread", "The Last Denim"]),
		"the denim buttons name the six denims"
	)
	_check(canvas_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the canvas row is labeled 1 through 6")
	_check(
		canvas_tips == PackedStringArray(["The Lit Canvas", "The Seen Sail", "The Passed Bolt", "The Open Canvas", "The Quenched Step", "The Last Canvas"]),
		"the canvas buttons name the six canvases"
	)
	_check(drill_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the drill row is labeled 1 through 6")
	_check(
		drill_tips == PackedStringArray(["The Lit Drill", "The Hidden Drill", "The Passed Weave", "The Open Drill", "The Spent Step", "The Last Drill"]),
		"the drill buttons name the six drills"
	)
	_check(twill_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the twill row is labeled 1 through 6")
	_check(
		twill_tips == PackedStringArray(["The Dark Twill", "The Hidden Twill", "The Passed Thread", "The Open Twill", "The Kindled Step", "The Last Twill"]),
		"the twill buttons name the six twills"
	)
	_check(duck_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the duck row is labeled 1 through 6")
	_check(
		duck_tips == PackedStringArray(["The Dark Duck", "The Hidden Duck", "The Passed Nap", "The Open Duck", "The Shut Step", "The Last Duck"]),
		"the duck buttons name the six ducks"
	)
	_check(nankeen_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the nankeen row is labeled 1 through 6")
	_check(
		nankeen_tips == PackedStringArray(["The Dark Nankeen", "The Hidden Nankeen", "The Passed Yellow", "The Open Nankeen", "The Kept Step", "The Last Nankeen"]),
		"the nankeen buttons name the six nankeens"
	)
	_check(jean_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the jean row is labeled 1 through 6")
	_check(
		jean_tips == PackedStringArray(["The Dark Jean", "The Hidden Jean", "The Passed Rivet", "The Open Jean", "The Lit Step", "The Last Jean"]),
		"the jean buttons name the six jeans"
	)
	_check(porch_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the porch row is labeled 1 through 6")
	_check(
		porch_tips == PackedStringArray(["The First Sill", "The Stopped Light", "The Seen Gap", "The Closed Walk", "The Dark Past", "The Last Sill"]),
		"the porch buttons name the six sills"
	)
	_check(oriel_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the oriel row is labeled 1 through 6")
	_check(
		oriel_tips == PackedStringArray(["The First Pane", "The Seen Room", "The Closed Sheet", "The Dark Beside", "The Long Sight", "The Last Pane"]),
		"the oriel buttons name the six panes"
	)
	_check(veil_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the veil row is labeled 1 through 6")
	_check(
		veil_tips == PackedStringArray(["The First Cloth", "The Seen Cloth", "The Short Road", "The Dark Beside", "The Second Lamp", "The Last Cloth"]),
		"the veil buttons name the six cloths"
	)
	_check(shade_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the shade row is labeled 1 through 6")
	_check(
		shade_tips == PackedStringArray(["The First Shade", "The Dark Step", "The Long Road", "The Far Dark", "The Second Lamp", "The Last Shade"]),
		"the shade buttons name the six shades"
	)
	_check(screen_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the screen row is labeled 1 through 6")
	_check(
		screen_tips == PackedStringArray(["The First Screen", "The Lit Screen", "The Closed Road", "The Far Light", "The Second Lamp", "The Last Screen"]),
		"the screen buttons name the six screens"
	)
	_check(glaze_buttons == PackedStringArray(["1", "2", "3", "4", "5", "6"]), "the glaze row is labeled 1 through 6")
	_check(
		glaze_tips == PackedStringArray(["The Watched Gap", "The Lit Glaze", "The Open Sight", "The Closed Road", "The Second Lamp", "The Last Glaze"]),
		"the glaze buttons name the six glazes"
	)
	_check(puzzle_buttons == Puzzles.count(), "puzzle select has a button for every room")
	var east_key := InputEventKey.new()
	east_key.physical_keycode = KEY_3
	east_key.keycode = KEY_3
	var west_key := InputEventKey.new()
	west_key.physical_keycode = KEY_1
	west_key.keycode = KEY_EXCLAM
	west_key.shift_pressed = true
	var last_key := InputEventKey.new()
	last_key.physical_keycode = KEY_6
	last_key.keycode = KEY_ASCIICIRCUM
	last_key.shift_pressed = true
	var bare_shift := InputEventKey.new()
	bare_shift.keycode = KEY_AT
	bare_shift.physical_keycode = KEY_NONE
	var north_key := InputEventKey.new()
	north_key.physical_keycode = KEY_1
	north_key.keycode = KEY_1
	north_key.ctrl_pressed = true
	var north_last := InputEventKey.new()
	north_last.physical_keycode = KEY_6
	north_last.keycode = KEY_6
	north_last.ctrl_pressed = true
	_check(main._puzzle_index_for_key(east_key) == 2, "key 3 selects the third east room")
	_check(main._puzzle_index_for_key(west_key) == 8, "shift+1 selects the first west room")
	_check(main._puzzle_index_for_key(last_key) == 13, "shift+6 selects the last west room")
	_check(main._puzzle_index_for_key(bare_shift) == 9, "the @ key selects the second west room")
	var south_key := InputEventKey.new()
	south_key.physical_keycode = KEY_1
	south_key.keycode = KEY_1
	south_key.alt_pressed = true
	var south_last := InputEventKey.new()
	south_last.physical_keycode = KEY_6
	south_last.keycode = KEY_6
	south_last.alt_pressed = true
	var east_eight := InputEventKey.new()
	east_eight.physical_keycode = KEY_8
	east_eight.keycode = KEY_8
	var alt_seven := InputEventKey.new()
	alt_seven.physical_keycode = KEY_7
	alt_seven.keycode = KEY_7
	alt_seven.alt_pressed = true
	var alt_shift := InputEventKey.new()
	alt_shift.physical_keycode = KEY_1
	alt_shift.keycode = KEY_1
	alt_shift.alt_pressed = true
	alt_shift.shift_pressed = true
	_check(main._puzzle_index_for_key(north_key) == 14, "ctrl+1 selects the first north room")
	_check(main._puzzle_index_for_key(north_last) == 19, "ctrl+6 selects the last north room")
	_check(main._puzzle_index_for_key(south_key) == 20, "alt+1 selects the first south room")
	_check(main._puzzle_index_for_key(south_last) == 25, "alt+6 selects the last south room")
	_check(main._puzzle_index_for_key(east_eight) == 7, "key 8 still selects the last east room")
	_check(main._puzzle_index_for_key(alt_seven) == -1, "alt+7 does not select an east room")
	_check(main._puzzle_index_for_key(alt_shift) == 74, "alt+shift+1 selects the first veil room")
	var attic_key := InputEventKey.new()
	attic_key.physical_keycode = KEY_F1
	attic_key.keycode = KEY_F1
	var attic_last := InputEventKey.new()
	attic_last.physical_keycode = KEY_F6
	attic_last.keycode = KEY_F6
	var attic_physical := InputEventKey.new()
	attic_physical.physical_keycode = KEY_F3
	attic_physical.keycode = KEY_NONE
	var attic_code := InputEventKey.new()
	attic_code.keycode = KEY_F4
	attic_code.physical_keycode = KEY_NONE
	var attic_seven := InputEventKey.new()
	attic_seven.physical_keycode = KEY_F7
	attic_seven.keycode = KEY_F7
	var attic_alt := InputEventKey.new()
	attic_alt.physical_keycode = KEY_F1
	attic_alt.keycode = KEY_F1
	attic_alt.alt_pressed = true
	_check(main._puzzle_index_for_key(attic_key) == 26, "F1 selects the first attic room")
	_check(main._puzzle_index_for_key(attic_last) == 31, "F6 selects the last attic room")
	_check(main._puzzle_index_for_key(attic_physical) == 28, "the physical F3 key selects the third attic room")
	_check(main._puzzle_index_for_key(attic_code) == 29, "the F4 keycode selects the fourth attic room")
	_check(main._puzzle_index_for_key(attic_seven) == 32, "F7 selects the first cellar room")
	_check(main._puzzle_index_for_key(attic_alt) == 50, "alt+F1 selects the first nave room")
	_check(main._attic_index(attic_alt) == -1, "the attic handler ignores alt+F")
	var cellar_last := InputEventKey.new()
	cellar_last.physical_keycode = KEY_F12
	cellar_last.keycode = KEY_F12
	var cellar_physical := InputEventKey.new()
	cellar_physical.physical_keycode = KEY_F8
	cellar_physical.keycode = KEY_NONE
	var cellar_code := InputEventKey.new()
	cellar_code.keycode = KEY_F10
	cellar_code.physical_keycode = KEY_NONE
	var cellar_past := InputEventKey.new()
	cellar_past.physical_keycode = KEY_F13
	cellar_past.keycode = KEY_F13
	var cellar_shift := InputEventKey.new()
	cellar_shift.physical_keycode = KEY_F7
	cellar_shift.keycode = KEY_F7
	cellar_shift.shift_pressed = true
	var cellar_ctrl := InputEventKey.new()
	cellar_ctrl.physical_keycode = KEY_F7
	cellar_ctrl.keycode = KEY_F7
	cellar_ctrl.ctrl_pressed = true
	var cellar_alt := InputEventKey.new()
	cellar_alt.physical_keycode = KEY_F7
	cellar_alt.keycode = KEY_F7
	cellar_alt.alt_pressed = true
	_check(main._puzzle_index_for_key(cellar_last) == 37, "F12 selects the last cellar room")
	_check(main._puzzle_index_for_key(cellar_physical) == 33, "the physical F8 key selects the second cellar room")
	_check(main._puzzle_index_for_key(cellar_code) == 35, "the F10 keycode selects the fourth cellar room")
	_check(main._puzzle_index_for_key(cellar_past) == -1, "F13 does not select a cellar room")
	_check(main._puzzle_index_for_key(cellar_shift) == 32, "shift does not take F7 off the cellar")
	_check(main._puzzle_index_for_key(cellar_ctrl) == 32, "ctrl does not take F7 off the cellar")
	_check(main._puzzle_index_for_key(cellar_alt) == 32, "alt does not take F7 off the cellar")
	var gallery_key := InputEventKey.new()
	gallery_key.physical_keycode = KEY_KP_1
	gallery_key.keycode = KEY_KP_1
	var gallery_last := InputEventKey.new()
	gallery_last.physical_keycode = KEY_KP_6
	gallery_last.keycode = KEY_KP_6
	var gallery_physical := InputEventKey.new()
	gallery_physical.physical_keycode = KEY_KP_3
	gallery_physical.keycode = KEY_NONE
	var gallery_code := InputEventKey.new()
	gallery_code.keycode = KEY_KP_4
	gallery_code.physical_keycode = KEY_NONE
	var gallery_shift := InputEventKey.new()
	gallery_shift.physical_keycode = KEY_KP_1
	gallery_shift.keycode = KEY_KP_1
	gallery_shift.shift_pressed = true
	var gallery_ctrl := InputEventKey.new()
	gallery_ctrl.physical_keycode = KEY_KP_2
	gallery_ctrl.keycode = KEY_KP_2
	gallery_ctrl.ctrl_pressed = true
	var gallery_alt := InputEventKey.new()
	gallery_alt.physical_keycode = KEY_KP_5
	gallery_alt.keycode = KEY_KP_5
	gallery_alt.alt_pressed = true
	var row_one := InputEventKey.new()
	row_one.physical_keycode = KEY_1
	row_one.keycode = KEY_1
	var keypad_seven := InputEventKey.new()
	keypad_seven.physical_keycode = KEY_KP_7
	keypad_seven.keycode = KEY_KP_7
	var keypad_zero := InputEventKey.new()
	keypad_zero.physical_keycode = KEY_KP_0
	keypad_zero.keycode = KEY_KP_0
	_check(main._puzzle_index_for_key(gallery_key) == 38, "keypad 1 selects the first gallery room")
	_check(main._puzzle_index_for_key(gallery_last) == 43, "keypad 6 selects the last gallery room")
	_check(main._puzzle_index_for_key(gallery_physical) == 40, "the physical keypad 3 selects the third gallery room")
	_check(main._puzzle_index_for_key(gallery_code) == 41, "the keypad 4 keycode selects the fourth gallery room")
	_check(main._puzzle_index_for_key(gallery_shift) == 38, "shift does not take keypad 1 off the gallery")
	_check(main._puzzle_index_for_key(gallery_ctrl) == 39, "ctrl does not take keypad 2 off the gallery")
	_check(main._puzzle_index_for_key(gallery_alt) == 42, "alt does not take keypad 5 off the gallery")
	_check(main._puzzle_index_for_key(row_one) == 0, "number-row 1 still selects the first east room")
	_check(main._puzzle_index_for_key(gallery_key) != main._puzzle_index_for_key(row_one), "keypad 1 is distinct from number-row 1")
	_check(main._puzzle_index_for_key(keypad_seven) == -1, "keypad 7 does not select an east room")
	_check(main._puzzle_index_for_key(keypad_zero) == -1, "keypad 0 does not select a room")
	var court_key := InputEventKey.new()
	court_key.physical_keycode = KEY_F1
	court_key.keycode = KEY_F1
	court_key.shift_pressed = true
	var court_last := InputEventKey.new()
	court_last.physical_keycode = KEY_F6
	court_last.keycode = KEY_F6
	court_last.shift_pressed = true
	var court_physical := InputEventKey.new()
	court_physical.physical_keycode = KEY_F2
	court_physical.keycode = KEY_NONE
	court_physical.shift_pressed = true
	var court_code := InputEventKey.new()
	court_code.keycode = KEY_F3
	court_code.physical_keycode = KEY_NONE
	court_code.shift_pressed = true
	var court_plain := InputEventKey.new()
	court_plain.physical_keycode = KEY_F1
	court_plain.keycode = KEY_F1
	var court_ctrl := InputEventKey.new()
	court_ctrl.physical_keycode = KEY_F1
	court_ctrl.keycode = KEY_F1
	court_ctrl.ctrl_pressed = true
	_check(main._puzzle_index_for_key(court_key) == 44, "shift+F1 selects the first court room")
	_check(main._puzzle_index_for_key(court_last) == 49, "shift+F6 selects the last court room")
	_check(main._puzzle_index_for_key(court_physical) == 45, "the physical shift+F2 key selects the second court room")
	_check(main._puzzle_index_for_key(court_code) == 46, "the shift+F3 keycode selects the third court room")
	_check(main._puzzle_index_for_key(court_plain) == 26, "plain F1 still selects the attic")
	_check(main._puzzle_index_for_key(court_ctrl) == 56, "ctrl+F1 selects the first cloister room")
	_check(main._attic_index(court_ctrl) == -1, "the attic handler ignores ctrl+F")
	_check(main._puzzle_index_for_key(gallery_key) == 38, "keypad 1 still selects the gallery")
	var nave_key := InputEventKey.new()
	nave_key.physical_keycode = KEY_F1
	nave_key.keycode = KEY_F1
	nave_key.alt_pressed = true
	var nave_last := InputEventKey.new()
	nave_last.physical_keycode = KEY_F6
	nave_last.keycode = KEY_F6
	nave_last.alt_pressed = true
	var nave_physical := InputEventKey.new()
	nave_physical.physical_keycode = KEY_F2
	nave_physical.keycode = KEY_NONE
	nave_physical.alt_pressed = true
	var nave_code := InputEventKey.new()
	nave_code.keycode = KEY_F3
	nave_code.physical_keycode = KEY_NONE
	nave_code.alt_pressed = true
	var nave_shift := InputEventKey.new()
	nave_shift.physical_keycode = KEY_F1
	nave_shift.keycode = KEY_F1
	nave_shift.alt_pressed = true
	nave_shift.shift_pressed = true
	var nave_plain := InputEventKey.new()
	nave_plain.physical_keycode = KEY_F4
	nave_plain.keycode = KEY_F4
	_check(main._puzzle_index_for_key(nave_key) == 50, "alt+F1 selects the first nave room")
	_check(main._puzzle_index_for_key(nave_last) == 55, "alt+F6 selects the last nave room")
	_check(main._puzzle_index_for_key(nave_physical) == 51, "the physical alt+F2 key selects the second nave room")
	_check(main._puzzle_index_for_key(nave_code) == 52, "the alt+F3 keycode selects the third nave room")
	_check(main._puzzle_index_for_key(nave_shift) == 68, "alt+shift+F1 selects the first oriel room")
	_check(main._court_index(nave_shift) == -1, "the court handler ignores alt+shift+F1")
	_check(main._nave_index(nave_shift) == -1, "the nave handler ignores alt+shift+F1")
	_check(main._puzzle_index_for_key(nave_plain) == 29, "plain F4 still selects the attic")
	_check(main._puzzle_index_for_key(south_key) == 20, "alt+1 still selects the south wing")
	var cloister_key := InputEventKey.new()
	cloister_key.physical_keycode = KEY_F1
	cloister_key.keycode = KEY_F1
	cloister_key.ctrl_pressed = true
	var cloister_last := InputEventKey.new()
	cloister_last.physical_keycode = KEY_F6
	cloister_last.keycode = KEY_F6
	cloister_last.ctrl_pressed = true
	var cloister_physical := InputEventKey.new()
	cloister_physical.physical_keycode = KEY_F2
	cloister_physical.keycode = KEY_NONE
	cloister_physical.ctrl_pressed = true
	var cloister_code := InputEventKey.new()
	cloister_code.keycode = KEY_F3
	cloister_code.physical_keycode = KEY_NONE
	cloister_code.ctrl_pressed = true
	var cloister_meta := InputEventKey.new()
	cloister_meta.physical_keycode = KEY_F4
	cloister_meta.keycode = KEY_F4
	cloister_meta.meta_pressed = true
	var cloister_shift := InputEventKey.new()
	cloister_shift.physical_keycode = KEY_F1
	cloister_shift.keycode = KEY_F1
	cloister_shift.ctrl_pressed = true
	cloister_shift.shift_pressed = true
	var cloister_alt := InputEventKey.new()
	cloister_alt.physical_keycode = KEY_F1
	cloister_alt.keycode = KEY_F1
	cloister_alt.ctrl_pressed = true
	cloister_alt.alt_pressed = true
	var cloister_plain := InputEventKey.new()
	cloister_plain.physical_keycode = KEY_F5
	cloister_plain.keycode = KEY_F5
	_check(main._puzzle_index_for_key(cloister_key) == 56, "ctrl+F1 selects the first cloister room")
	_check(main._puzzle_index_for_key(cloister_last) == 61, "ctrl+F6 selects the last cloister room")
	_check(main._puzzle_index_for_key(cloister_physical) == 57, "the physical ctrl+F2 key selects the second cloister room")
	_check(main._puzzle_index_for_key(cloister_code) == 58, "the ctrl+F3 keycode selects the third cloister room")
	_check(main._puzzle_index_for_key(cloister_meta) == 59, "meta+F4 selects the fourth cloister room")
	_check(main._puzzle_index_for_key(cloister_shift) == 62, "ctrl+shift+F1 selects the first porch room")
	_check(main._puzzle_index_for_key(cloister_alt) == 50, "alt+ctrl+F1 stays on the nave")
	_check(main._puzzle_index_for_key(cloister_plain) == 30, "plain F5 still selects the attic")
	_check(main._cloister_index(cloister_plain) == -1, "the cloister handler ignores plain F5")
	_check(main._attic_index(cloister_key) == -1, "the attic handler ignores ctrl+F1")
	_check(main._puzzle_index_for_key(north_key) == 14, "ctrl+1 still selects the north wing")
	_check(main._puzzle_index_for_key(court_key) == 44, "shift+F1 still selects the court")
	_check(main._puzzle_index_for_key(nave_key) == 50, "alt+F1 still selects the nave")
	_check(main._puzzle_index_for_key(attic_key) == 26, "plain F1 still selects the attic")
	_check(main._puzzle_index_for_key(cellar_last) == 37, "F12 still selects the cellar")
	_check(main._puzzle_index_for_key(gallery_key) == 38, "keypad 1 still selects the gallery")
	var porch_last := InputEventKey.new()
	porch_last.physical_keycode = KEY_F6
	porch_last.keycode = KEY_F6
	porch_last.ctrl_pressed = true
	porch_last.shift_pressed = true
	var porch_physical := InputEventKey.new()
	porch_physical.physical_keycode = KEY_F2
	porch_physical.keycode = KEY_NONE
	porch_physical.ctrl_pressed = true
	porch_physical.shift_pressed = true
	var porch_code := InputEventKey.new()
	porch_code.keycode = KEY_F3
	porch_code.physical_keycode = KEY_NONE
	porch_code.ctrl_pressed = true
	porch_code.shift_pressed = true
	var porch_meta := InputEventKey.new()
	porch_meta.physical_keycode = KEY_F4
	porch_meta.keycode = KEY_F4
	porch_meta.meta_pressed = true
	porch_meta.shift_pressed = true
	var porch_alt := InputEventKey.new()
	porch_alt.physical_keycode = KEY_F1
	porch_alt.keycode = KEY_F1
	porch_alt.ctrl_pressed = true
	porch_alt.shift_pressed = true
	porch_alt.alt_pressed = true
	var porch_plain := InputEventKey.new()
	porch_plain.physical_keycode = KEY_F1
	porch_plain.keycode = KEY_F1
	var porch_ctrl := InputEventKey.new()
	porch_ctrl.physical_keycode = KEY_F1
	porch_ctrl.keycode = KEY_F1
	porch_ctrl.ctrl_pressed = true
	_check(main._puzzle_index_for_key(porch_last) == 67, "ctrl+shift+F6 selects the last porch room")
	_check(main._puzzle_index_for_key(porch_physical) == 63, "the physical ctrl+shift+F2 key selects the second porch room")
	_check(main._puzzle_index_for_key(porch_code) == 64, "the ctrl+shift+F3 keycode selects the third porch room")
	_check(main._puzzle_index_for_key(porch_meta) == 65, "meta+shift+F4 selects the fourth porch room")
	_check(main._puzzle_index_for_key(porch_alt) == 98, "ctrl+shift+alt+F1 selects the first mica room")
	_check(main._porch_index(porch_plain) == -1, "the porch handler ignores plain F1")
	_check(main._porch_index(porch_ctrl) == -1, "the porch handler ignores ctrl+F1 without shift")
	_check(main._court_index(cloister_shift) == -1, "the court handler ignores ctrl+shift+F1")
	_check(main._cloister_index(cloister_shift) == -1, "the cloister handler ignores ctrl+shift+F1")
	var oriel_last := InputEventKey.new()
	oriel_last.physical_keycode = KEY_F6
	oriel_last.keycode = KEY_F6
	oriel_last.alt_pressed = true
	oriel_last.shift_pressed = true
	var oriel_physical := InputEventKey.new()
	oriel_physical.physical_keycode = KEY_F2
	oriel_physical.keycode = KEY_NONE
	oriel_physical.alt_pressed = true
	oriel_physical.shift_pressed = true
	var oriel_code := InputEventKey.new()
	oriel_code.keycode = KEY_F3
	oriel_code.physical_keycode = KEY_NONE
	oriel_code.alt_pressed = true
	oriel_code.shift_pressed = true
	var oriel_meta := InputEventKey.new()
	oriel_meta.physical_keycode = KEY_F4
	oriel_meta.keycode = KEY_F4
	oriel_meta.meta_pressed = true
	oriel_meta.alt_pressed = true
	oriel_meta.shift_pressed = true
	var oriel_ctrl := InputEventKey.new()
	oriel_ctrl.physical_keycode = KEY_F1
	oriel_ctrl.keycode = KEY_F1
	oriel_ctrl.ctrl_pressed = true
	oriel_ctrl.alt_pressed = true
	oriel_ctrl.shift_pressed = true
	var oriel_plain := InputEventKey.new()
	oriel_plain.physical_keycode = KEY_F1
	oriel_plain.keycode = KEY_F1
	var oriel_shift := InputEventKey.new()
	oriel_shift.physical_keycode = KEY_F1
	oriel_shift.keycode = KEY_F1
	oriel_shift.shift_pressed = true
	var oriel_alt := InputEventKey.new()
	oriel_alt.physical_keycode = KEY_F1
	oriel_alt.keycode = KEY_F1
	oriel_alt.alt_pressed = true
	_check(main._puzzle_index_for_key(oriel_last) == 73, "alt+shift+F6 selects the last oriel room")
	_check(main._puzzle_index_for_key(oriel_physical) == 69, "the physical alt+shift+F2 key selects the second oriel room")
	_check(main._puzzle_index_for_key(oriel_code) == 70, "the alt+shift+F3 keycode selects the third oriel room")
	_check(main._puzzle_index_for_key(oriel_meta) == 149, "meta+alt+shift+F4 without ctrl selects the fourth holland room")
	var holland_physical := InputEventKey.new()
	holland_physical.physical_keycode = KEY_F2
	holland_physical.keycode = KEY_NONE
	holland_physical.meta_pressed = true
	holland_physical.alt_pressed = true
	holland_physical.shift_pressed = true
	var holland_first := InputEventKey.new()
	holland_first.physical_keycode = KEY_F1
	holland_first.keycode = KEY_F1
	holland_first.meta_pressed = true
	holland_first.alt_pressed = true
	holland_first.shift_pressed = true
	_check(main._puzzle_index_for_key(holland_physical) == 147, "the physical meta+alt+shift+F2 key selects the second holland room")
	_check(main._puzzle_index_for_key(holland_first) == 146, "meta+alt+shift+F1 without ctrl selects the first holland room")
	_check(main._holland_index(cloister_meta) == -1, "the holland handler ignores meta+F4")
	var buckram_meta := InputEventKey.new()
	buckram_meta.physical_keycode = KEY_F16
	buckram_meta.keycode = KEY_F16
	buckram_meta.meta_pressed = true
	var buckram_ctrl := InputEventKey.new()
	buckram_ctrl.physical_keycode = KEY_F4
	buckram_ctrl.keycode = KEY_F4
	buckram_ctrl.meta_pressed = true
	buckram_ctrl.ctrl_pressed = true
	var buckram_porch := InputEventKey.new()
	buckram_porch.physical_keycode = KEY_F4
	buckram_porch.keycode = KEY_F4
	buckram_porch.meta_pressed = true
	buckram_porch.ctrl_pressed = true
	buckram_porch.shift_pressed = true
	var buckram_nave := InputEventKey.new()
	buckram_nave.physical_keycode = KEY_F1
	buckram_nave.keycode = KEY_F1
	buckram_nave.meta_pressed = true
	buckram_nave.ctrl_pressed = true
	buckram_nave.alt_pressed = true
	var buckram_first := InputEventKey.new()
	buckram_first.physical_keycode = KEY_F13
	buckram_first.keycode = KEY_F13
	buckram_first.meta_pressed = true
	var buckram_physical := InputEventKey.new()
	buckram_physical.physical_keycode = KEY_F14
	buckram_physical.keycode = KEY_NONE
	buckram_physical.meta_pressed = true
	var buckram_cellar := InputEventKey.new()
	buckram_cellar.physical_keycode = KEY_F7
	buckram_cellar.keycode = KEY_F7
	buckram_cellar.meta_pressed = true
	_check(main._puzzle_index_for_key(buckram_ctrl) == 59, "meta+ctrl+F4 without alt and without shift stays the fourth cloister room")
	_check(main._puzzle_index_for_key(buckram_porch) == 65, "meta+ctrl+shift+F4 without alt stays the fourth porch room")
	_check(main._puzzle_index_for_key(buckram_nave) == 50, "meta+ctrl+alt+F1 without shift stays the first nave room")
	_check(main._puzzle_index_for_key(buckram_meta) == 155, "meta+F16 without ctrl, alt, and shift selects the fourth buckram room")
	_check(main._puzzle_index_for_key(buckram_first) == 152, "meta+F13 without ctrl, alt, and shift selects the first buckram room")
	_check(main._puzzle_index_for_key(buckram_physical) == 153, "the physical meta+F14 key selects the second buckram room")
	_check(main._puzzle_index_for_key(buckram_cellar) == 32, "meta+F7 stays the first cellar room")
	_check(main._buckram_index(holland_first) == -1, "the buckram handler ignores meta+alt+shift+F1")
	_check(main._buckram_index(buckram_ctrl) == -1, "the buckram handler ignores meta+ctrl+F4")
	_check(main._holland_index(buckram_first) == -1, "the holland handler ignores meta+F13")
	var ticking_meta := InputEventKey.new()
	ticking_meta.physical_keycode = KEY_F16
	ticking_meta.keycode = KEY_F16
	ticking_meta.meta_pressed = true
	ticking_meta.ctrl_pressed = true
	var ticking_first := InputEventKey.new()
	ticking_first.physical_keycode = KEY_F13
	ticking_first.keycode = KEY_F13
	ticking_first.meta_pressed = true
	ticking_first.ctrl_pressed = true
	var ticking_physical := InputEventKey.new()
	ticking_physical.physical_keycode = KEY_F14
	ticking_physical.keycode = KEY_NONE
	ticking_physical.meta_pressed = true
	ticking_physical.ctrl_pressed = true
	var ticking_alt := InputEventKey.new()
	ticking_alt.physical_keycode = KEY_F13
	ticking_alt.keycode = KEY_F13
	ticking_alt.meta_pressed = true
	ticking_alt.alt_pressed = true
	var ticking_shift := InputEventKey.new()
	ticking_shift.physical_keycode = KEY_F13
	ticking_shift.keycode = KEY_F13
	ticking_shift.meta_pressed = true
	ticking_shift.shift_pressed = true
	_check(main._puzzle_index_for_key(ticking_meta) == 161, "meta+ctrl+F16 without alt and without shift selects the fourth ticking room")
	_check(main._puzzle_index_for_key(ticking_first) == 158, "meta+ctrl+F13 without alt and without shift selects the first ticking room")
	_check(main._puzzle_index_for_key(ticking_physical) == 159, "the physical meta+ctrl+F14 key selects the second ticking room")
	_check(main._puzzle_index_for_key(ticking_alt) == 164, "meta+alt+F13 without ctrl and without shift selects the first denim room")
	_check(main._puzzle_index_for_key(ticking_shift) == 170, "meta+shift+F13 without ctrl and without alt selects the first canvas room")
	_check(main._ticking_index(buckram_first) == -1, "the ticking handler ignores meta+F13")
	_check(main._ticking_index(ticking_alt) == -1, "the ticking handler ignores meta+alt+F13")
	_check(main._ticking_index(ticking_shift) == -1, "the ticking handler ignores meta+shift+F13")
	_check(main._buckram_index(ticking_first) == -1, "the buckram handler ignores meta+ctrl+F13")
	var denim_meta := InputEventKey.new()
	denim_meta.physical_keycode = KEY_F16
	denim_meta.keycode = KEY_F16
	denim_meta.meta_pressed = true
	denim_meta.alt_pressed = true
	var denim_physical := InputEventKey.new()
	denim_physical.physical_keycode = KEY_F14
	denim_physical.keycode = KEY_NONE
	denim_physical.meta_pressed = true
	denim_physical.alt_pressed = true
	var denim_both := InputEventKey.new()
	denim_both.physical_keycode = KEY_F13
	denim_both.keycode = KEY_F13
	denim_both.meta_pressed = true
	denim_both.ctrl_pressed = true
	denim_both.alt_pressed = true
	_check(main._puzzle_index_for_key(denim_meta) == 167, "meta+alt+F16 without ctrl and without shift selects the fourth denim room")
	_check(main._puzzle_index_for_key(denim_physical) == 165, "the physical meta+alt+F14 key selects the second denim room")
	_check(main._puzzle_index_for_key(denim_both) == 176, "meta+ctrl+alt+F13 without shift selects the first drill room")
	_check(main._denim_index(ticking_first) == -1, "the denim handler ignores meta+ctrl+F13")
	_check(main._denim_index(buckram_first) == -1, "the denim handler ignores meta+F13")
	_check(main._denim_index(ticking_shift) == -1, "the denim handler ignores meta+shift+F13")
	var canvas_last := InputEventKey.new()
	canvas_last.physical_keycode = KEY_F18
	canvas_last.keycode = KEY_F18
	canvas_last.meta_pressed = true
	canvas_last.shift_pressed = true
	var canvas_physical := InputEventKey.new()
	canvas_physical.physical_keycode = KEY_F14
	canvas_physical.keycode = KEY_NONE
	canvas_physical.meta_pressed = true
	canvas_physical.shift_pressed = true
	var canvas_ctrl := InputEventKey.new()
	canvas_ctrl.physical_keycode = KEY_F13
	canvas_ctrl.keycode = KEY_F13
	canvas_ctrl.meta_pressed = true
	canvas_ctrl.ctrl_pressed = true
	canvas_ctrl.shift_pressed = true
	_check(main._puzzle_index_for_key(canvas_last) == 175, "meta+shift+F18 without ctrl and without alt selects the last canvas room")
	_check(main._puzzle_index_for_key(canvas_physical) == 171, "the physical meta+shift+F14 key selects the second canvas room")
	_check(main._puzzle_index_for_key(canvas_ctrl) == 182, "meta+ctrl+shift+F13 without alt selects the first twill room")
	_check(main._canvas_index(ticking_shift) == 0, "the canvas handler takes meta+shift+F13")
	_check(main._canvas_index(ticking_first) == -1, "the canvas handler ignores meta+ctrl+F13")
	_check(main._canvas_index(buckram_first) == -1, "the canvas handler ignores meta+F13")
	_check(main._canvas_index(ticking_alt) == -1, "the canvas handler ignores meta+alt+F13")
	var drill_last := InputEventKey.new()
	drill_last.physical_keycode = KEY_F18
	drill_last.keycode = KEY_F18
	drill_last.meta_pressed = true
	drill_last.ctrl_pressed = true
	drill_last.alt_pressed = true
	var drill_physical := InputEventKey.new()
	drill_physical.physical_keycode = KEY_F14
	drill_physical.keycode = KEY_NONE
	drill_physical.meta_pressed = true
	drill_physical.ctrl_pressed = true
	drill_physical.alt_pressed = true
	var drill_shift := InputEventKey.new()
	drill_shift.physical_keycode = KEY_F13
	drill_shift.keycode = KEY_F13
	drill_shift.meta_pressed = true
	drill_shift.ctrl_pressed = true
	drill_shift.alt_pressed = true
	drill_shift.shift_pressed = true
	_check(main._puzzle_index_for_key(drill_last) == 181, "meta+ctrl+alt+F18 without shift selects the last drill room")
	_check(main._puzzle_index_for_key(drill_physical) == 177, "the physical meta+ctrl+alt+F14 key selects the second drill room")
	_check(main._puzzle_index_for_key(drill_shift) == 194, "meta+ctrl+alt+shift+F13 selects the first nankeen room")
	_check(main._drill_index(denim_both) == 0, "the drill handler takes meta+ctrl+alt+F13")
	_check(main._drill_index(ticking_shift) == -1, "the drill handler ignores meta+shift+F13")
	_check(main._drill_index(ticking_first) == -1, "the drill handler ignores meta+ctrl+F13")
	_check(main._drill_index(ticking_alt) == -1, "the drill handler ignores meta+alt+F13")
	_check(main._drill_index(buckram_first) == -1, "the drill handler ignores meta+F13")
	var twill_last := InputEventKey.new()
	twill_last.physical_keycode = KEY_F18
	twill_last.keycode = KEY_F18
	twill_last.meta_pressed = true
	twill_last.ctrl_pressed = true
	twill_last.shift_pressed = true
	var twill_physical := InputEventKey.new()
	twill_physical.physical_keycode = KEY_F14
	twill_physical.keycode = KEY_NONE
	twill_physical.meta_pressed = true
	twill_physical.ctrl_pressed = true
	twill_physical.shift_pressed = true
	var twill_alt := InputEventKey.new()
	twill_alt.physical_keycode = KEY_F13
	twill_alt.keycode = KEY_F13
	twill_alt.meta_pressed = true
	twill_alt.ctrl_pressed = true
	twill_alt.shift_pressed = true
	twill_alt.alt_pressed = true
	_check(main._puzzle_index_for_key(twill_last) == 187, "meta+ctrl+shift+F18 without alt selects the last twill room")
	_check(main._puzzle_index_for_key(twill_physical) == 183, "the physical meta+ctrl+shift+F14 key selects the second twill room")
	_check(main._puzzle_index_for_key(twill_alt) == 194, "meta+ctrl+alt+shift+F13 selects the first nankeen room")
	_check(main._twill_index(canvas_ctrl) == 0, "the twill handler takes meta+ctrl+shift+F13")
	_check(main._twill_index(denim_both) == -1, "the twill handler ignores meta+ctrl+alt+F13")
	_check(main._twill_index(ticking_shift) == -1, "the twill handler ignores meta+shift+F13")
	_check(main._twill_index(ticking_first) == -1, "the twill handler ignores meta+ctrl+F13")
	_check(main._drill_index(canvas_ctrl) == -1, "the drill handler ignores meta+ctrl+shift+F13")
	_check(main._canvas_index(canvas_ctrl) == -1, "the canvas handler ignores meta+ctrl+shift+F13")
	_check(main._denim_index(canvas_ctrl) == -1, "the denim handler ignores meta+ctrl+shift+F13")
	_check(main._ticking_index(canvas_ctrl) == -1, "the ticking handler ignores meta+ctrl+shift+F13")
	var duck_last := InputEventKey.new()
	duck_last.physical_keycode = KEY_F18
	duck_last.keycode = KEY_F18
	duck_last.meta_pressed = true
	duck_last.alt_pressed = true
	duck_last.shift_pressed = true
	var duck_physical := InputEventKey.new()
	duck_physical.physical_keycode = KEY_F14
	duck_physical.keycode = KEY_NONE
	duck_physical.meta_pressed = true
	duck_physical.alt_pressed = true
	duck_physical.shift_pressed = true
	var duck_ctrl := InputEventKey.new()
	duck_ctrl.physical_keycode = KEY_F13
	duck_ctrl.keycode = KEY_F13
	duck_ctrl.meta_pressed = true
	duck_ctrl.alt_pressed = true
	duck_ctrl.shift_pressed = true
	duck_ctrl.ctrl_pressed = true
	_check(main._puzzle_index_for_key(duck_last) == 193, "meta+alt+shift+F18 without ctrl selects the last duck room")
	_check(main._puzzle_index_for_key(duck_physical) == 189, "the physical meta+alt+shift+F14 key selects the second duck room")
	_check(main._puzzle_index_for_key(duck_ctrl) == 194, "meta+ctrl+alt+shift+F13 selects the first nankeen room")
	var nankeen_last := InputEventKey.new()
	nankeen_last.physical_keycode = KEY_F18
	nankeen_last.keycode = KEY_F18
	nankeen_last.meta_pressed = true
	nankeen_last.ctrl_pressed = true
	nankeen_last.alt_pressed = true
	nankeen_last.shift_pressed = true
	var nankeen_physical := InputEventKey.new()
	nankeen_physical.physical_keycode = KEY_F14
	nankeen_physical.keycode = KEY_NONE
	nankeen_physical.meta_pressed = true
	nankeen_physical.ctrl_pressed = true
	nankeen_physical.alt_pressed = true
	nankeen_physical.shift_pressed = true
	_check(main._puzzle_index_for_key(nankeen_last) == 199, "meta+ctrl+alt+shift+F18 selects the last nankeen room")
	_check(main._puzzle_index_for_key(nankeen_physical) == 195, "the physical meta+ctrl+alt+shift+F14 key selects the second nankeen room")
	_check(main._nankeen_index(duck_ctrl) == 0, "the nankeen handler takes meta+ctrl+alt+shift+F13")
	_check(main._nankeen_index(duck_last) == -1, "the nankeen handler ignores meta+alt+shift+F18")
	_check(main._nankeen_index(canvas_ctrl) == -1, "the nankeen handler ignores meta+ctrl+shift+F13")
	_check(main._duck_index(duck_ctrl) == -1, "the duck handler ignores meta+ctrl+alt+shift+F13")
	_check(main._twill_index(duck_ctrl) == -1, "the twill handler ignores meta+ctrl+alt+shift+F13")
	_check(main._drill_index(duck_ctrl) == -1, "the drill handler ignores meta+ctrl+alt+shift+F13")
	var jean_first := InputEventKey.new()
	jean_first.physical_keycode = KEY_F19
	jean_first.keycode = KEY_F19
	jean_first.meta_pressed = true
	var jean_last := InputEventKey.new()
	jean_last.physical_keycode = KEY_F24
	jean_last.keycode = KEY_F24
	jean_last.meta_pressed = true
	var jean_physical := InputEventKey.new()
	jean_physical.physical_keycode = KEY_F20
	jean_physical.keycode = KEY_NONE
	jean_physical.meta_pressed = true
	var jean_shift := InputEventKey.new()
	jean_shift.physical_keycode = KEY_F19
	jean_shift.keycode = KEY_F19
	jean_shift.meta_pressed = true
	jean_shift.shift_pressed = true
	_check(main._puzzle_index_for_key(jean_first) == 200, "meta+F19 selects the first jean room")
	_check(main._puzzle_index_for_key(jean_last) == 205, "meta+F24 selects the last jean room")
	_check(main._puzzle_index_for_key(jean_physical) == 201, "the physical meta+F20 key selects the second jean room")
	_check(main._jean_index(jean_first) == 0, "the jean handler takes meta+F19")
	_check(main._jean_index(jean_shift) == -1, "the jean handler ignores meta+shift+F19")
	_check(main._jean_index(duck_ctrl) == -1, "the jean handler ignores meta+ctrl+alt+shift+F13")
	_check(main._buckram_index(jean_first) == -1, "the buckram handler ignores meta+F19")
	_check(main._nankeen_index(jean_first) == -1, "the nankeen handler ignores meta+F19")
	_check(main._puzzle_index_for_key(jean_shift) == -1, "meta+shift+F19 selects nothing")
	_check(main._duck_index(duck_last) == 5, "the duck handler takes meta+alt+shift+F18")
	_check(main._duck_index(canvas_ctrl) == -1, "the duck handler ignores meta+ctrl+shift+F13")
	_check(main._duck_index(denim_both) == -1, "the duck handler ignores meta+ctrl+alt+F13")
	_check(main._twill_index(duck_last) == -1, "the twill handler ignores meta+alt+shift+F18")
	_check(main._denim_index(duck_last) == -1, "the denim handler ignores meta+alt+shift+F18")
	_check(main._holland_index(duck_last) == -1, "the holland handler ignores meta+alt+shift+F18")
	_check(main._canvas_index(denim_both) == -1, "the canvas handler ignores meta+ctrl+alt+F13")
	_check(main._denim_index(denim_both) == -1, "the denim handler ignores meta+ctrl+alt+F13")
	_check(main._ticking_index(denim_both) == -1, "the ticking handler ignores meta+ctrl+alt+F13")
	_check(main._ticking_index(ticking_shift) == -1, "the ticking handler ignores meta+shift+F13")
	_check(main._buckram_index(ticking_shift) == -1, "the buckram handler ignores meta+shift+F13")
	_check(main._ticking_index(ticking_alt) == -1, "the ticking handler ignores meta+alt+F13")
	_check(main._holland_index(oriel_last) == -1, "the holland handler ignores alt+shift+F6")
	_check(main._holland_index(oriel_ctrl) == -1, "the holland handler ignores ctrl+alt+shift+F1")
	_check(main._oriel_index(oriel_meta) == -1, "the oriel handler ignores meta+alt+shift+F4")
	_check(main._puzzle_index_for_key(oriel_ctrl) == 98, "ctrl+alt+shift+F1 selects the first mica room")
	_check(main._oriel_index(oriel_plain) == -1, "the oriel handler ignores plain F1")
	_check(main._oriel_index(oriel_shift) == -1, "the oriel handler ignores shift+F1 without alt")
	_check(main._oriel_index(oriel_alt) == -1, "the oriel handler ignores alt+F1 without shift")
	_check(main._oriel_index(oriel_ctrl) == -1, "the oriel handler ignores ctrl")
	_check(main._puzzle_index_for_key(oriel_shift) == 44, "shift+F1 without alt stays on the court")
	_check(main._puzzle_index_for_key(oriel_alt) == 50, "alt+F1 without shift stays on the nave")
	_check(main._puzzle_index_for_key(cloister_shift) == 62, "ctrl+shift+F1 without alt stays on the porch")
	_check(main._puzzle_index_for_key(cloister_key) == 56, "ctrl+F1 without shift and without alt stays on the cloister")
	_check(main._puzzle_index_for_key(attic_key) == 26, "plain F1 still stays on the attic")
	var veil_last := InputEventKey.new()
	veil_last.physical_keycode = KEY_6
	veil_last.keycode = KEY_6
	veil_last.alt_pressed = true
	veil_last.shift_pressed = true
	var veil_physical := InputEventKey.new()
	veil_physical.physical_keycode = KEY_2
	veil_physical.keycode = KEY_AT
	veil_physical.alt_pressed = true
	veil_physical.shift_pressed = true
	var veil_code := InputEventKey.new()
	veil_code.keycode = KEY_NUMBERSIGN
	veil_code.physical_keycode = KEY_NONE
	veil_code.alt_pressed = true
	veil_code.shift_pressed = true
	var veil_ctrl := InputEventKey.new()
	veil_ctrl.physical_keycode = KEY_1
	veil_ctrl.keycode = KEY_1
	veil_ctrl.ctrl_pressed = true
	veil_ctrl.alt_pressed = true
	veil_ctrl.shift_pressed = true
	var veil_meta := InputEventKey.new()
	veil_meta.physical_keycode = KEY_1
	veil_meta.keycode = KEY_1
	veil_meta.meta_pressed = true
	veil_meta.alt_pressed = true
	veil_meta.shift_pressed = true
	var veil_seven := InputEventKey.new()
	veil_seven.physical_keycode = KEY_7
	veil_seven.keycode = KEY_7
	veil_seven.alt_pressed = true
	veil_seven.shift_pressed = true
	var oriel_first := InputEventKey.new()
	oriel_first.physical_keycode = KEY_F1
	oriel_first.keycode = KEY_F1
	oriel_first.alt_pressed = true
	oriel_first.shift_pressed = true
	_check(main._puzzle_index_for_key(veil_last) == 79, "alt+shift+6 selects the last veil room")
	_check(main._puzzle_index_for_key(veil_physical) == 75, "the physical alt+shift+2 key selects the second veil room")
	_check(main._puzzle_index_for_key(veil_code) == 76, "the alt+shift+3 keycode selects the third veil room")
	_check(main._puzzle_index_for_key(veil_ctrl) == 92, "ctrl+alt+shift+1 selects the first glaze room")
	_check(main._puzzle_index_for_key(veil_meta) == 128, "meta+alt+shift+1 selects the first lawn room")
	_check(main._puzzle_index_for_key(veil_seven) == -1, "alt+shift+7 selects nothing")
	_check(main._veil_index(south_key) == -1, "the veil handler ignores alt+1 without shift")
	_check(main._veil_index(west_key) == -1, "the veil handler ignores shift+1 without alt")
	_check(main._veil_index(north_key) == -1, "the veil handler ignores ctrl+1")
	_check(main._puzzle_index_for_key(south_key) == 20, "alt+1 without shift stays on the south wing")
	_check(main._puzzle_index_for_key(west_key) == 8, "shift+1 without alt stays on the west wing")
	_check(main._puzzle_index_for_key(north_key) == 14, "ctrl+1 stays on the north wing")
	_check(main._puzzle_index_for_key(oriel_first) == 68, "alt+shift+F1 stays on the oriel")
	_check(main._puzzle_index_for_key(oriel_ctrl) == 98, "alt+shift+F1 with ctrl selects the first mica room")
	var shade_last := InputEventKey.new()
	shade_last.physical_keycode = KEY_6
	shade_last.keycode = KEY_6
	shade_last.ctrl_pressed = true
	shade_last.alt_pressed = true
	var shade_physical := InputEventKey.new()
	shade_physical.physical_keycode = KEY_2
	shade_physical.keycode = KEY_NONE
	shade_physical.ctrl_pressed = true
	shade_physical.alt_pressed = true
	var shade_meta := InputEventKey.new()
	shade_meta.physical_keycode = KEY_1
	shade_meta.keycode = KEY_1
	shade_meta.meta_pressed = true
	shade_meta.alt_pressed = true
	var shade_first := InputEventKey.new()
	shade_first.physical_keycode = KEY_1
	shade_first.keycode = KEY_1
	shade_first.ctrl_pressed = true
	shade_first.alt_pressed = true
	_check(main._puzzle_index_for_key(shade_first) == 80, "ctrl+alt+1 selects the first shade room")
	_check(main._puzzle_index_for_key(shade_last) == 85, "ctrl+alt+6 selects the last shade room")
	_check(main._puzzle_index_for_key(shade_physical) == 81, "the physical ctrl+alt+2 key selects the second shade room")
	_check(main._puzzle_index_for_key(shade_meta) == 122, "meta+alt+1 without ctrl and without shift selects the first voile room")
	_check(main._shade_index(south_key) == -1, "the shade handler ignores alt+1 without ctrl")
	_check(main._shade_index(north_key) == -1, "the shade handler ignores ctrl+1 without alt")
	_check(main._shade_index(west_key) == -1, "the shade handler ignores shift+1")
	_check(main._shade_index(veil_ctrl) == -1, "the shade handler ignores ctrl+alt+shift+1")
	_check(main._puzzle_index_for_key(east_key) == 2, "the number row without modifiers stays the east wing")
	var screen_last := InputEventKey.new()
	screen_last.physical_keycode = KEY_6
	screen_last.keycode = KEY_6
	screen_last.ctrl_pressed = true
	screen_last.shift_pressed = true
	var screen_physical := InputEventKey.new()
	screen_physical.physical_keycode = KEY_2
	screen_physical.keycode = KEY_AT
	screen_physical.ctrl_pressed = true
	screen_physical.shift_pressed = true
	var screen_code := InputEventKey.new()
	screen_code.keycode = KEY_EXCLAM
	screen_code.physical_keycode = KEY_NONE
	screen_code.ctrl_pressed = true
	screen_code.shift_pressed = true
	var screen_alt := InputEventKey.new()
	screen_alt.physical_keycode = KEY_1
	screen_alt.keycode = KEY_1
	screen_alt.ctrl_pressed = true
	screen_alt.shift_pressed = true
	screen_alt.alt_pressed = true
	var screen_meta := InputEventKey.new()
	screen_meta.physical_keycode = KEY_1
	screen_meta.keycode = KEY_1
	screen_meta.ctrl_pressed = true
	screen_meta.shift_pressed = true
	screen_meta.meta_pressed = true
	var screen_first := InputEventKey.new()
	screen_first.physical_keycode = KEY_1
	screen_first.keycode = KEY_1
	screen_first.ctrl_pressed = true
	screen_first.shift_pressed = true
	_check(main._puzzle_index_for_key(screen_first) == 86, "ctrl+shift+1 selects the first screen room")
	_check(main._puzzle_index_for_key(screen_last) == 91, "ctrl+shift+6 selects the last screen room")
	_check(main._puzzle_index_for_key(screen_physical) == 87, "the physical ctrl+shift+2 key selects the second screen room")
	_check(main._puzzle_index_for_key(screen_code) == 86, "the ctrl+shift+1 keycode selects the first screen room")
	_check(main._puzzle_index_for_key(screen_alt) == 92, "ctrl+alt+shift+1 selects the first glaze room")
	_check(main._screen_index(screen_alt) == -1, "the screen handler ignores ctrl+alt+shift+1")
	_check(main._glaze_index(screen_first) == -1, "the glaze handler ignores ctrl+shift+1 without alt")
	_check(main._glaze_index(shade_first) == -1, "the glaze handler ignores ctrl+alt+1 without shift")
	_check(main._puzzle_index_for_key(screen_meta) == 14, "meta+ctrl+shift+1 stays on the north wing")
	_check(main._screen_index(north_key) == -1, "the screen handler ignores ctrl+1 without shift")
	_check(main._screen_index(west_key) == -1, "the screen handler ignores shift+1 without ctrl")
	_check(main._screen_index(shade_first) == -1, "the screen handler ignores ctrl+alt+1 without shift")
	_check(main._puzzle_index_for_key(shade_first) == 80, "ctrl+alt+1 without shift stays the shade")
	_check(main._puzzle_index_for_key(north_key) == 14, "ctrl+1 without shift and without alt stays the north wing")
	_check(main._puzzle_index_for_key(west_key) == 8, "shift+1 without ctrl stays the west wing")
	_check(main._puzzle_index_for_key(veil_last) == 79, "alt+shift+6 without ctrl stays the veil")
	var glaze_last := InputEventKey.new()
	glaze_last.physical_keycode = KEY_6
	glaze_last.keycode = KEY_6
	glaze_last.ctrl_pressed = true
	glaze_last.alt_pressed = true
	glaze_last.shift_pressed = true
	var glaze_physical := InputEventKey.new()
	glaze_physical.physical_keycode = KEY_2
	glaze_physical.keycode = KEY_AT
	glaze_physical.ctrl_pressed = true
	glaze_physical.alt_pressed = true
	glaze_physical.shift_pressed = true
	var glaze_meta := InputEventKey.new()
	glaze_meta.physical_keycode = KEY_1
	glaze_meta.keycode = KEY_1
	glaze_meta.ctrl_pressed = true
	glaze_meta.alt_pressed = true
	glaze_meta.shift_pressed = true
	glaze_meta.meta_pressed = true
	_check(main._puzzle_index_for_key(glaze_last) == 97, "ctrl+alt+shift+6 selects the last glaze room")
	_check(main._puzzle_index_for_key(glaze_physical) == 93, "the physical ctrl+alt+shift+2 key selects the second glaze room")
	_check(main._puzzle_index_for_key(glaze_meta) == 110, "meta+ctrl+alt+shift+1 selects the first scrim room")
	_check(main._glaze_index(glaze_meta) == -1, "the glaze handler ignores meta")
	_check(main._glaze_index(veil_last) == -1, "the glaze handler ignores alt+shift+6 without ctrl")
	_check(main._glaze_index(north_key) == -1, "the glaze handler ignores ctrl+1")
	var mica_first := InputEventKey.new()
	mica_first.physical_keycode = KEY_F1
	mica_first.keycode = KEY_F1
	mica_first.ctrl_pressed = true
	mica_first.alt_pressed = true
	mica_first.shift_pressed = true
	var mica_last := InputEventKey.new()
	mica_last.physical_keycode = KEY_F6
	mica_last.keycode = KEY_F6
	mica_last.ctrl_pressed = true
	mica_last.alt_pressed = true
	mica_last.shift_pressed = true
	var mica_physical := InputEventKey.new()
	mica_physical.physical_keycode = KEY_F2
	mica_physical.keycode = KEY_NONE
	mica_physical.ctrl_pressed = true
	mica_physical.alt_pressed = true
	mica_physical.shift_pressed = true
	var mica_meta := InputEventKey.new()
	mica_meta.physical_keycode = KEY_F1
	mica_meta.keycode = KEY_F1
	mica_meta.ctrl_pressed = true
	mica_meta.alt_pressed = true
	mica_meta.shift_pressed = true
	mica_meta.meta_pressed = true
	var porch_still := InputEventKey.new()
	porch_still.physical_keycode = KEY_F1
	porch_still.keycode = KEY_F1
	porch_still.ctrl_pressed = true
	porch_still.shift_pressed = true
	var oriel_still := InputEventKey.new()
	oriel_still.physical_keycode = KEY_F1
	oriel_still.keycode = KEY_F1
	oriel_still.alt_pressed = true
	oriel_still.shift_pressed = true
	_check(main._puzzle_index_for_key(mica_first) == 98, "ctrl+alt+shift+F1 selects the first mica room")
	_check(main._puzzle_index_for_key(mica_last) == 103, "ctrl+alt+shift+F6 selects the last mica room")
	_check(main._puzzle_index_for_key(mica_physical) == 99, "the physical ctrl+alt+shift+F2 key selects the second mica room")
	_check(main._puzzle_index_for_key(mica_meta) == 104, "meta+ctrl+alt+shift+F1 selects the first baize room")
	_check(main._mica_index(mica_meta) == -1, "the mica handler ignores meta")
	_check(main._baize_index(mica_first) == -1, "the baize handler ignores ctrl+alt+shift+F1 without meta")
	var baize_last := InputEventKey.new()
	baize_last.physical_keycode = KEY_F6
	baize_last.keycode = KEY_F6
	baize_last.ctrl_pressed = true
	baize_last.alt_pressed = true
	baize_last.shift_pressed = true
	baize_last.meta_pressed = true
	var baize_physical := InputEventKey.new()
	baize_physical.physical_keycode = KEY_F2
	baize_physical.keycode = KEY_NONE
	baize_physical.ctrl_pressed = true
	baize_physical.alt_pressed = true
	baize_physical.shift_pressed = true
	baize_physical.meta_pressed = true
	var nave_ctrl := InputEventKey.new()
	nave_ctrl.physical_keycode = KEY_F1
	nave_ctrl.keycode = KEY_F1
	nave_ctrl.ctrl_pressed = true
	nave_ctrl.alt_pressed = true
	_check(main._puzzle_index_for_key(baize_last) == 109, "meta+ctrl+alt+shift+F6 selects the last baize room")
	_check(main._puzzle_index_for_key(baize_physical) == 105, "the physical meta+ctrl+alt+shift+F2 key selects the second baize room")
	_check(main._puzzle_index_for_key(nave_ctrl) == 50, "ctrl+alt+F1 without shift stays the nave")
	_check(main._baize_index(nave_ctrl) == -1, "the baize handler ignores ctrl+alt+F1 without shift")
	_check(main._puzzle_index_for_key(porch_still) == 62, "ctrl+shift+F1 without alt stays the porch")
	_check(main._puzzle_index_for_key(oriel_still) == 68, "alt+shift+F1 without ctrl stays the oriel")
	_check(main._puzzle_index_for_key(glaze_last) == 97, "ctrl+alt+shift+6 stays the last glaze room")
	var scrim_last := InputEventKey.new()
	scrim_last.physical_keycode = KEY_6
	scrim_last.keycode = KEY_6
	scrim_last.ctrl_pressed = true
	scrim_last.alt_pressed = true
	scrim_last.shift_pressed = true
	scrim_last.meta_pressed = true
	var scrim_physical := InputEventKey.new()
	scrim_physical.physical_keycode = KEY_2
	scrim_physical.keycode = KEY_AT
	scrim_physical.ctrl_pressed = true
	scrim_physical.alt_pressed = true
	scrim_physical.shift_pressed = true
	scrim_physical.meta_pressed = true
	_check(main._puzzle_index_for_key(scrim_last) == 115, "meta+ctrl+alt+shift+6 selects the last scrim room")
	_check(main._puzzle_index_for_key(scrim_physical) == 111, "the physical meta+ctrl+alt+shift+2 key selects the second scrim room")
	_check(main._scrim_index(glaze_last) == -1, "the scrim handler ignores ctrl+alt+shift+6 without meta")
	var gauze_first := InputEventKey.new()
	gauze_first.physical_keycode = KEY_1
	gauze_first.keycode = KEY_1
	gauze_first.ctrl_pressed = true
	gauze_first.alt_pressed = true
	gauze_first.meta_pressed = true
	var gauze_last := InputEventKey.new()
	gauze_last.physical_keycode = KEY_6
	gauze_last.keycode = KEY_6
	gauze_last.ctrl_pressed = true
	gauze_last.alt_pressed = true
	gauze_last.meta_pressed = true
	var gauze_physical := InputEventKey.new()
	gauze_physical.physical_keycode = KEY_2
	gauze_physical.keycode = KEY_2
	gauze_physical.ctrl_pressed = true
	gauze_physical.alt_pressed = true
	gauze_physical.meta_pressed = true
	_check(main._puzzle_index_for_key(gauze_first) == 116, "meta+ctrl+alt+1 without shift selects the first gauze room")
	_check(main._puzzle_index_for_key(gauze_last) == 121, "meta+ctrl+alt+6 without shift selects the last gauze room")
	_check(main._puzzle_index_for_key(gauze_physical) == 117, "the physical meta+ctrl+alt+2 key selects the second gauze room")
	_check(main._shade_index(gauze_first) == -1, "the shade handler ignores meta+ctrl+alt+1")
	_check(main._scrim_index(gauze_first) == -1, "the scrim handler ignores meta+ctrl+alt+1 without shift")
	_check(main._glaze_index(gauze_first) == -1, "the glaze handler ignores meta+ctrl+alt+1 without shift")
	_check(main._gauze_index(shade_first) == -1, "the gauze handler ignores ctrl+alt+1 without meta")
	_check(main._gauze_index(glaze_last) == -1, "the gauze handler ignores ctrl+alt+shift+6 without meta")
	_check(main._gauze_index(scrim_last) == -1, "the gauze handler ignores meta+ctrl+alt+shift+6")
	_check(main._puzzle_index_for_key(shade_first) == 80, "ctrl+alt+1 without meta and without shift stays the shade")
	_check(main._puzzle_index_for_key(scrim_last) == 115, "meta+ctrl+alt+shift+6 stays the last scrim room")
	var voile_last := InputEventKey.new()
	voile_last.physical_keycode = KEY_6
	voile_last.keycode = KEY_6
	voile_last.meta_pressed = true
	voile_last.alt_pressed = true
	var voile_physical := InputEventKey.new()
	voile_physical.physical_keycode = KEY_2
	voile_physical.keycode = KEY_2
	voile_physical.meta_pressed = true
	voile_physical.alt_pressed = true
	_check(main._puzzle_index_for_key(voile_last) == 127, "meta+alt+6 without ctrl and without shift selects the last voile room")
	_check(main._puzzle_index_for_key(voile_physical) == 123, "the physical meta+alt+2 key selects the second voile room")
	_check(main._voile_index(shade_first) == -1, "the voile handler ignores ctrl+alt+1")
	_check(main._voile_index(gauze_first) == -1, "the voile handler ignores meta+ctrl+alt+1")
	_check(main._voile_index(veil_meta) == -1, "the voile handler ignores meta+alt+shift+1")
	_check(main._voile_index(glaze_last) == -1, "the voile handler ignores ctrl+alt+shift+6")
	_check(main._puzzle_index_for_key(veil_meta) == 128, "meta+alt+shift+1 selects the first lawn room")
	_check(main._puzzle_index_for_key(glaze_last) == 97, "ctrl+alt+shift+6 stays the last glaze room")
	var lawn_last := InputEventKey.new()
	lawn_last.physical_keycode = KEY_6
	lawn_last.keycode = KEY_6
	lawn_last.meta_pressed = true
	lawn_last.alt_pressed = true
	lawn_last.shift_pressed = true
	var lawn_physical := InputEventKey.new()
	lawn_physical.physical_keycode = KEY_2
	lawn_physical.keycode = KEY_2
	lawn_physical.meta_pressed = true
	lawn_physical.alt_pressed = true
	lawn_physical.shift_pressed = true
	var lawn_north := InputEventKey.new()
	lawn_north.physical_keycode = KEY_1
	lawn_north.keycode = KEY_1
	lawn_north.meta_pressed = true
	lawn_north.ctrl_pressed = true
	_check(main._puzzle_index_for_key(lawn_last) == 133, "meta+alt+shift+6 without ctrl selects the last lawn room")
	_check(main._puzzle_index_for_key(lawn_physical) == 129, "the physical meta+alt+shift+2 key selects the second lawn room")
	_check(main._lawn_index(shade_meta) == -1, "the lawn handler ignores meta+alt+1 without shift")
	_check(main._lawn_index(gauze_first) == -1, "the lawn handler ignores meta+ctrl+alt+1")
	_check(main._lawn_index(glaze_last) == -1, "the lawn handler ignores ctrl+alt+shift+6")
	_check(main._lawn_index(scrim_last) == -1, "the lawn handler ignores meta+ctrl+alt+shift+6")
	_check(main._lawn_index(lawn_north) == -1, "the lawn handler ignores meta+ctrl+1")
	_check(main._puzzle_index_for_key(lawn_north) == 14, "meta+ctrl+1 without alt and without shift stays the north wing")
	_check(main._puzzle_index_for_key(shade_meta) == 122, "meta+alt+1 without shift stays the first voile room")
	var muslin_last := InputEventKey.new()
	muslin_last.physical_keycode = KEY_6
	muslin_last.keycode = KEY_6
	muslin_last.meta_pressed = true
	muslin_last.shift_pressed = true
	var muslin_physical := InputEventKey.new()
	muslin_physical.physical_keycode = KEY_2
	muslin_physical.keycode = KEY_2
	muslin_physical.meta_pressed = true
	muslin_physical.shift_pressed = true
	var muslin_north := InputEventKey.new()
	muslin_north.physical_keycode = KEY_1
	muslin_north.keycode = KEY_1
	muslin_north.meta_pressed = true
	muslin_north.ctrl_pressed = true
	muslin_north.shift_pressed = true
	_check(main._puzzle_index_for_key(muslin_last) == 139, "meta+shift+6 without ctrl and without alt selects the last muslin room")
	_check(main._puzzle_index_for_key(muslin_physical) == 135, "the physical meta+shift+2 key selects the second muslin room")
	_check(main._muslin_index(lawn_last) == -1, "the muslin handler ignores meta+alt+shift+6")
	_check(main._muslin_index(muslin_north) == -1, "the muslin handler ignores meta+ctrl+shift+1")
	_check(main._muslin_index(shade_meta) == -1, "the muslin handler ignores meta+alt+1")
	_check(main._lawn_index(muslin_last) == -1, "the lawn handler ignores meta+shift+6")
	_check(main._puzzle_index_for_key(muslin_north) == 14, "meta+ctrl+shift+1 without alt stays the north wing")
	_check(main._puzzle_index_for_key(lawn_last) == 133, "meta+alt+shift+6 without ctrl stays the last lawn room")
	var cambric_last := InputEventKey.new()
	cambric_last.physical_keycode = KEY_6
	cambric_last.keycode = KEY_6
	cambric_last.meta_pressed = true
	var cambric_physical := InputEventKey.new()
	cambric_physical.physical_keycode = KEY_2
	cambric_physical.keycode = KEY_NONE
	cambric_physical.meta_pressed = true
	var cambric_plain := InputEventKey.new()
	cambric_plain.physical_keycode = KEY_1
	cambric_plain.keycode = KEY_1
	cambric_plain.meta_pressed = true
	_check(main._puzzle_index_for_key(cambric_last) == 145, "meta+6 without ctrl, alt, and shift selects the last cambric room")
	_check(main._puzzle_index_for_key(cambric_physical) == 141, "the physical meta+2 key selects the second cambric room")
	_check(main._puzzle_index_for_key(cambric_plain) == 140, "meta+1 without ctrl, alt, and shift selects the first cambric room")
	_check(main._cambric_index(muslin_last) == -1, "the cambric handler ignores meta+shift+6")
	_check(main._cambric_index(lawn_north) == -1, "the cambric handler ignores meta+ctrl+1")
	_check(main._cambric_index(muslin_north) == -1, "the cambric handler ignores meta+ctrl+shift+1")
	_check(main._cambric_index(lawn_last) == -1, "the cambric handler ignores meta+alt+shift+6")
	_check(main._muslin_index(cambric_plain) == -1, "the muslin handler ignores meta+1")
	_check(main._puzzle_index_for_key(north_key) == 14, "ctrl+1 stays on the north wing")
	var row_y := 106.0 + 34.0 * 36.0
	var bottom := row_y + 270.0
	var avail := 2136.0 - 124.0 - bottom - 28.0
	_check(avail / 8.0 >= 48.0, "an 8-tile board still draws at 48 pixels")
	_check(int(ProjectSettings.get_setting("display/window/size/viewport_width")) == 1280, "the window stays 1280 wide")
	_check(int(ProjectSettings.get_setting("display/window/size/viewport_height")) == 2136, "the window is 2136 tall")
	main.free()


func _check_cut_beam() -> void:
	var index := _index_of("The Cut Beam")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 0, "the cut beam is solved without snuffing")
	var state := Puzzles.initial_state(index)
	var lamp: Dictionary = state["lamps"][0]
	var found := false
	for y in state["h"]:
		for x in state["w"]:
			if Rules.tile_at(state, x, y) == Rules.Tile.EXIT:
				found = true
				var dx: int = int(x) - int(lamp["x"])
				var dy: int = int(y) - int(lamp["y"])
				_check(
					absi(dx) + absi(dy) <= int(lamp["radius"]) and dx * int(lamp["fx"]) + dy * int(lamp["fy"]) >= 0,
					"the cut door sits inside the lamp's diamond"
				)
				_check(not Rules.light_map(state).has(Vector2i(x, y)), "the wall keeps that door dark")
	_check(found, "the cut beam has a door")
	var refused: Dictionary = Rules.apply(state, {"type": "move", "dx": 0, "dy": 1})
	var stayed: Dictionary = refused["state"]["player"]
	_check(
		refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "lit" and stayed["x"] == int(state["player"]["x"]) and stayed["y"] == int(state["player"]["y"]),
		"unwatched lit floor in the cut hall is refused"
	)
	var right: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	_check(right["result"] == Rules.Result.OK, "the north gallery of the cut beam is dark")
	var lost: Dictionary = Rules.apply(right["state"], {"type": "move", "dx": 0, "dy": 1})
	var landed: Dictionary = lost["state"]["player"]
	_check(
		lost["result"] == Rules.Result.LOSS and lost["reason"] == "watched" and landed["x"] == 2 and landed["y"] == 2,
		"a watched lit step in the north wing still loses"
	)


func _check_cold_wick() -> void:
	var index := _index_of("The Cold Wick")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	_check(not bool(state["lamps"][0]["lit"]), "the cold wick starts unlit")
	var toggles := 0
	var saw := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
			var out: Dictionary = Rules.apply(state, action)
			saw = true
			_check(out["result"] == Rules.Result.OK and int(out["called"]) == -1, "lighting the cold wick calls no one")
			_check(bool(out["state"]["lamps"][0]["lit"]), "the cold wick is lit after that toggle")
			_check(not bool(out["state"]["guards"][0]["alert"]), "the cold wick's keeper is not alerted")
			state = out["state"]
			continue
		var step: Dictionary = Rules.apply(state, action)
		if step["result"] != Rules.Result.OK and step["result"] != Rules.Result.WIN:
			_check(false, "cold wick solution broke before the check finished")
			return
		state = step["state"]
	_check(saw and toggles == 1, "the cold wick solution lights its lamp once")
	state = Puzzles.initial_state(index)
	for _i in 4:
		var step: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
		if step["result"] != Rules.Result.OK:
			_check(false, "cold wick front approach failed")
			return
		state = step["state"]
	var burned: Dictionary = Rules.apply(state, {"type": "toggle", "lamp": 0})
	_check(
		burned["result"] == Rules.Result.LOSS and burned["reason"] == "watched",
		"lighting the cold wick from the front is a watched loss"
	)


func _check_nearer_keeper() -> void:
	var index := _index_of("The Nearer Keeper")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var saw := false
	for action in puzzle["solution"]:
		if str(action["type"]) != "toggle":
			var before: Dictionary = Rules.apply(state, action)
			if before["result"] != Rules.Result.OK:
				_check(false, "nearer keeper approach failed")
				return
			state = before["state"]
			continue
		var lp: Dictionary = state["lamps"][int(action["lamp"])]
		var dist0 := absi(int(state["guards"][0]["x"]) - int(lp["x"])) + absi(int(state["guards"][0]["y"]) - int(lp["y"]))
		var dist1 := absi(int(state["guards"][1]["x"]) - int(lp["x"])) + absi(int(state["guards"][1]["y"]) - int(lp["y"]))
		var out: Dictionary = Rules.apply(state, action)
		saw = true
		_check(dist0 < dist1, "the nearer keeper is strictly closer to the lamp")
		_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "the snuff calls the nearer keeper")
		_check(not bool(out["state"]["guards"][1]["alert"]), "the farther keeper is not called")
		break
	_check(saw, "the nearer keeper solution snuffs the lamp")


func _check_far_watch() -> void:
	var index := _index_of("The Far Watch")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var gap := Vector2i(-1, -1)
	for y in state["h"]:
		for x in state["w"]:
			if Rules.tile_at(state, x, y) == Rules.Tile.GAP:
				gap = Vector2i(x, y)
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(gap) and Rules.watched_tiles(state, lit).has(gap), "the far watch's gap starts lit and watched")
	var toggled := {}
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggled[int(action["lamp"])] = true
	_check(toggled.has(0) and not toggled.has(1), "the far watch snuffs the west wick and leaves the gap lamp")
	state = Puzzles.initial_state(index)
	var crossed := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(state["player"]["x"]) + int(action["dx"]), int(state["player"]["y"]) + int(action["dy"]))
			if dest == gap:
				var lights: Dictionary = Rules.light_map(state)
				_check(
					bool(state["lamps"][1]["lit"]) and lights.has(gap) and not Rules.watched_tiles(state, lights).has(gap),
					"the gap is lit and unwatched when you cross"
				)
				crossed = true
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] == Rules.Result.LOSS or out["result"] == Rules.Result.ILLEGAL:
			_check(false, "far watch solution failed during the gap check")
			return
		state = out["state"]
		if out["result"] == Rules.Result.WIN:
			break
	_check(crossed, "the far watch solution crosses the gap")


func _check_closing_door_race() -> void:
	var index := _index_of("The Closing Door")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var lit: Dictionary = Rules.light_map(state)
	var exit_cell := Vector2i(-1, -1)
	for y in state["h"]:
		for x in state["w"]:
			if Rules.tile_at(state, x, y) == Rules.Tile.EXIT:
				exit_cell = Vector2i(x, y)
	_check(
		lit.has(exit_cell) and Rules.watched_tiles(state, lit).has(exit_cell),
		"the closing door starts lit and watched"
	)
	var saw := false
	for action in puzzle["solution"]:
		if str(action["type"]) != "toggle":
			var before: Dictionary = Rules.apply(state, action)
			if before["result"] != Rules.Result.OK:
				_check(false, "closing door approach failed")
				return
			state = before["state"]
			continue
		var out: Dictionary = Rules.apply(state, action)
		saw = true
		var guard_before: Dictionary = state["guards"][0]
		var guard_after: Dictionary = out["state"]["guards"][0]
		_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "snuffing the door lamp calls the keeper")
		_check(out["step"] == exit_cell, "his next step is the door")
		_check(
			int(guard_after["x"]) == int(guard_before["x"]) and int(guard_after["y"]) == int(guard_before["y"]),
			"he has not stepped onto the door yet"
		)
		var waited: Dictionary = Rules.apply(out["state"], {"type": "wait"})
		var held: Dictionary = waited["state"]["guards"][0]
		_check(
			waited["result"] == Rules.Result.OK and bool(held["holding"]) and int(held["x"]) == exit_cell.x and int(held["y"]) == exit_cell.y,
			"waiting lets him hold the door"
		)
		var player: Dictionary = waited["state"]["player"]
		var bumped: Dictionary = Rules.apply(waited["state"], {"type": "move", "dx": exit_cell.x - int(player["x"]), "dy": exit_cell.y - int(player["y"])})
		_check(bumped["result"] == Rules.Result.LOSS and bumped["reason"] == "guard", "the held door is his tile")
		break
	_check(saw, "the closing door solution snuffs the lamp")


func _check_north_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "North Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_dark_half() -> void:
	var index := _index_of("The Dark Half")
	var state := Puzzles.initial_state(index)
	var lamp: Dictionary = state["lamps"][0]
	var south := Vector2i(2, 4)
	var reach := absi(south.x - int(lamp["x"])) + absi(south.y - int(lamp["y"]))
	_check(reach <= int(lamp["radius"]) and Rules.tile_at(state, south.x, south.y) == Rules.Tile.FLOOR, "the south gallery sits inside the diamond")
	_check(not Rules.light_map(state).has(south), "the south side of the diamond stays dark")
	var exit_lit := false
	var found := false
	var lit: Dictionary = Rules.light_map(state)
	for y in state["h"]:
		for x in state["w"]:
			if Rules.tile_at(state, x, y) == Rules.Tile.EXIT:
				found = true
				exit_lit = lit.has(Vector2i(x, y))
	_check(found and exit_lit, "the dark half's door starts inside the lamp")
	var refused: Dictionary = Rules.apply(state, {"type": "move", "dx": 0, "dy": -1})
	var stayed: Dictionary = refused["state"]["player"]
	_check(
		refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "lit" and stayed["x"] == int(state["player"]["x"]) and stayed["y"] == int(state["player"]["y"]),
		"unwatched lit floor in the south wing is refused"
	)
	for _i in 4:
		var step: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
		if step["result"] != Rules.Result.OK:
			_check(false, "dark half approach failed before the lamp")
			return
		state = step["state"]
	var lost: Dictionary = Rules.apply(state, {"type": "move", "dx": 0, "dy": -1})
	var landed: Dictionary = lost["state"]["player"]
	_check(
		lost["result"] == Rules.Result.LOSS and lost["reason"] == "watched" and landed["x"] == 5 and landed["y"] == 3,
		"a watched lit step in the south wing still loses"
	)


func _check_passing_watch() -> void:
	var index := _index_of("The Passing Watch")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var waits := 0
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "wait":
			waits += 1
		elif str(action["type"]) == "toggle":
			toggles += 1
	_check(waits == 1 and toggles == 0, "the passing watch waits once and does not snuff")
	var state := Puzzles.initial_state(index)
	var gap := Vector2i(4, 1)
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(gap) and not Rules.watched_tiles(state, lit).has(gap), "the gap starts lit while he is on the far end")
	for _i in 2:
		var step: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
		if step["result"] != Rules.Result.OK:
			_check(false, "passing watch approach failed")
			return
		state = step["state"]
	lit = Rules.light_map(state)
	_check(lit.has(gap) and Rules.watched_tiles(state, lit).has(gap), "the near end puts the gap in his eyes")
	var rushed: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var landed: Dictionary = rushed["state"]["player"]
	_check(
		rushed["result"] == Rules.Result.LOSS and rushed["reason"] == "watched" and landed["x"] == gap.x and landed["y"] == gap.y,
		"stepping onto the watched gap still loses"
	)


func _check_owed_step() -> void:
	var index := _index_of("The Owed Step")
	var state := Puzzles.initial_state(index)
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	if approach["result"] != Rules.Result.OK:
		_check(false, "owed step approach failed")
		return
	state = approach["state"]
	var before: Dictionary = state["guards"][0]
	var snuff: Dictionary = Rules.apply(state, {"type": "toggle", "lamp": 0})
	var after: Dictionary = snuff["state"]["guards"][0]
	var player: Dictionary = snuff["state"]["player"]
	_check(snuff["result"] == Rules.Result.OK and int(snuff["called"]) == 0, "the owed step snuff calls the keeper")
	_check(
		int(after["x"]) == 3 and int(after["y"]) == 3 and int(before["y"]) == 4,
		"on the snuff turn his owed step falls short"
	)
	_check(
		snuff["step"] == Vector2i(int(player["x"]), int(player["y"])),
		"the arrow then points at the tile you are standing on"
	)
	var stayed: Dictionary = Rules.apply(snuff["state"], {"type": "wait"})
	var caught: Dictionary = stayed["state"]["guards"][0]
	_check(
		stayed["result"] == Rules.Result.LOSS and stayed["reason"] == "guard" and int(caught["x"]) == 3 and int(caught["y"]) == 2,
		"waiting after the snuff lets the arrow land on you"
	)
	var late := Puzzles.initial_state(index)
	late = Rules.apply(late, {"type": "wait"})["state"]
	late = Rules.apply(late, {"type": "move", "dx": 1, "dy": 0})["state"]
	var late_snuff: Dictionary = Rules.apply(late, {"type": "toggle", "lamp": 0})
	_check(
		late_snuff["result"] == Rules.Result.LOSS and late_snuff["reason"] == "guard",
		"waiting first makes the owed step land on you"
	)


func _check_fading_watch() -> void:
	var index := _index_of("The Fading Watch")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 1, "the fading watch snuffs its lamp once")
	var state := Puzzles.initial_state(index)
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	var exit_cell := Vector2i(-1, -1)
	for y in state["h"]:
		for x in state["w"]:
			if Rules.tile_at(state, x, y) == Rules.Tile.EXIT:
				exit_cell = Vector2i(x, y)
	_check(lit.has(exit_cell) and not watch.has(exit_cell), "the fading door is lit and unwatched")
	_check(lit.has(Vector2i(4, 1)) and watch.has(Vector2i(4, 1)), "the lamp square is lit and watched")
	for _i in 2:
		var step: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
		if step["result"] != Rules.Result.OK:
			_check(false, "fading watch approach failed")
			return
		state = step["state"]
	var lost: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var landed: Dictionary = lost["state"]["player"]
	_check(
		lost["result"] == Rules.Result.LOSS and lost["reason"] == "watched" and landed["x"] == 4 and landed["y"] == 1,
		"stepping onto the watched lamp square still loses"
	)


func _check_covered_flame() -> void:
	var index := _index_of("The Covered Flame")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	_check(Rules.light_map(state).has(Vector2i(5, 1)) and Rules.tile_at(state, 5, 1) == Rules.Tile.FLOOR, "the hall lamp covers the tile behind the door lamp")
	var exit_lit := false
	for y in state["h"]:
		for x in state["w"]:
			if Rules.tile_at(state, x, y) == Rules.Tile.EXIT:
				exit_lit = Rules.light_map(state).has(Vector2i(x, y))
	_check(exit_lit, "the covered flame's door starts lit")
	var order: Array = []
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			order.append(int(action["lamp"]))
	_check(order.size() == 2 and int(order[0]) == 0 and int(order[1]) == 1, "the covered flame snuffs the hall lamp, then the door lamp")
	var saw_first := false
	var saw_second := false
	for action in puzzle["solution"]:
		if str(action["type"]) != "toggle":
			var step: Dictionary = Rules.apply(state, action)
			if step["result"] != Rules.Result.OK:
				_check(false, "covered flame approach failed")
				return
			state = step["state"]
			continue
		var guard_before: Dictionary = state["guards"][0]
		var out: Dictionary = Rules.apply(state, action)
		if not saw_first:
			saw_first = true
			var guard_after: Dictionary = out["state"]["guards"][0]
			_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "snuffing the hall lamp calls the keeper")
			_check(out["step"] == Vector2i(3, 2), "his next step is up toward the hall lamp")
			_check(
				int(guard_after["x"]) == int(guard_before["x"]) and int(guard_after["y"]) == int(guard_before["y"]),
				"he has not taken that step yet"
			)
			state = out["state"]
			continue
		saw_second = true
		var again: Dictionary = out["state"]["guards"][0]
		_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "snuffing the door lamp calls him again")
		_check(bool(guard_before["holding"]) and not bool(again["holding"]) and bool(again["alert"]), "the second snuff lifts the hold")
		_check(int(again["ax"]) == 6 and int(again["ay"]) == 1, "the second call targets the door lamp")
		_check(not bool(out["state"]["lamps"][1]["lit"]), "the door lamp is out")
		_check(
			int(again["x"]) == int(guard_before["x"]) and int(again["y"]) == int(guard_before["y"]),
			"he does not step on the second snuff turn"
		)
		break
	_check(saw_first and saw_second, "the covered flame solution snuffs both lamps")


func _check_far_answer() -> void:
	var index := _index_of("The Far Answer")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var hall: Dictionary = state["lamps"][0]
	var gap_lamp: Dictionary = state["lamps"][1]
	var far: Dictionary = state["guards"][0]
	var near: Dictionary = state["guards"][1]
	var hall_far := absi(int(far["x"]) - int(hall["x"])) + absi(int(far["y"]) - int(hall["y"]))
	var hall_near := absi(int(near["x"]) - int(hall["x"])) + absi(int(near["y"]) - int(hall["y"]))
	var gap_far := absi(int(far["x"]) - int(gap_lamp["x"])) + absi(int(far["y"]) - int(gap_lamp["y"]))
	var gap_near := absi(int(near["x"]) - int(gap_lamp["x"])) + absi(int(near["y"]) - int(gap_lamp["y"]))
	_check(hall_far < hall_near, "the far keeper is closer to the hall lamp")
	_check(gap_near < gap_far, "the door keeper is closer to the gap lamp")
	var used := {}
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			used[int(action["lamp"])] = true
	_check(used.has(0) and not used.has(1), "the far answer snuffs the hall lamp and leaves the gap lamp")
	var gap := Vector2i(8, 1)
	var crossed := false
	var saw := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(state["player"]["x"]) + int(action["dx"]), int(state["player"]["y"]) + int(action["dy"]))
			if dest == gap:
				var lights: Dictionary = Rules.light_map(state)
				_check(
					bool(state["lamps"][1]["lit"]) and not bool(state["lamps"][0]["lit"]) and lights.has(gap) and not Rules.watched_tiles(state, lights).has(gap),
					"the gap is still lit and unwatched when you cross"
				)
				crossed = true
		if str(action["type"]) == "toggle":
			var out: Dictionary = Rules.apply(state, action)
			saw = true
			_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "the hall snuff calls the far keeper")
			_check(not bool(out["state"]["guards"][1]["alert"]), "the door keeper is not called")
			state = out["state"]
			continue
		var step: Dictionary = Rules.apply(state, action)
		if step["result"] == Rules.Result.LOSS or step["result"] == Rules.Result.ILLEGAL:
			_check(false, "far answer solution failed during the call check")
			return
		state = step["state"]
		if step["result"] == Rules.Result.WIN:
			break
	_check(saw and crossed, "the far answer solution snuffs the hall and crosses the gap")
	state = Puzzles.initial_state(index)
	for _i in 2:
		var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
		if approach["result"] != Rules.Result.OK:
			_check(false, "far answer lit-step approach failed")
			return
		state = approach["state"]
	var lost: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var landed: Dictionary = lost["state"]["player"]
	_check(
		lost["result"] == Rules.Result.LOSS and lost["reason"] == "watched" and landed["x"] == 4 and landed["y"] == 1,
		"a watched lit step beside the far answer still loses"
	)


func _check_south_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "South Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_attic_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Attic Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_attic_rooms() -> void:
	_check_room_identity()
	_check_attic_watched_steps()
	_check_unlit_watch()
	_check_blind_wall()
	_check_barred_gap()
	_check_north_step()
	_check_dark_eye()
	_check_early_threshold()


func _check_room_identity() -> void:
	var layouts := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		var layout := "|".join(puzzle["rows"])
		var title := str(puzzle["title"])
		if str(puzzle["wing"]) == "Attic Wing":
			if layouts.has(layout):
				layout_ok = false
			if titles.has(title):
				title_ok = false
		if not layouts.has(layout):
			layouts[layout] = title
		if not titles.has(title):
			titles[title] = true
	_check(layout_ok, "each attic room has its own layout")
	_check(title_ok, "each attic room has its own name")


func _check_attic_watched_steps() -> void:
	var cases := [
		["The Unlit Watch", "R R R D", 4, 2],
		["The Blind Wall", "R", 2, 1],
		["The Barred Gap", "R R T0 W W R R W R", 6, 1],
		["The North Step", "D D D D R R R", 4, 5],
		["The Dark Eye", "R R R", 4, 1],
		["The Early Threshold", "D", 3, 2],
	]
	for entry in cases:
		_expect_watched_loss(str(entry[0]), str(entry[1]), int(entry[2]), int(entry[3]))


func _expect_watched_loss(title: String, spec: String, x: int, y: int) -> void:
	_expect_watched_loss_at(_index_of(title), spec, x, y)


func _expect_watched_loss_at(index: int, spec: String, x: int, y: int) -> void:
	var title := str(Puzzles.get_puzzle(index)["title"])
	var state := Puzzles.initial_state(index)
	var actions: Array = Puzzles.parse_solution(spec)
	for i in actions.size():
		var action: Dictionary = actions[i]
		if i == actions.size() - 1:
			var dest := Vector2i(x, y)
			var lit: Dictionary = Rules.light_map(state)
			_check(lit.has(dest) and Rules.watched_tiles(state, lit).has(dest), title + " steps onto a lit tile a guard is watching")
			var out: Dictionary = Rules.apply(state, action)
			var landed: Dictionary = out["state"]["player"]
			_check(
				out["result"] == Rules.Result.LOSS and out["reason"] == "watched" and landed["x"] == x and landed["y"] == y,
				title + " watched lit step loses"
			)
			return
		var step: Dictionary = Rules.apply(state, action)
		if step["result"] != Rules.Result.OK:
			_check(false, title + " loss approach failed")
			return
		state = step["state"]


func _check_unlit_watch() -> void:
	var index := _index_of("The Unlit Watch")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 0, "the unlit watch is solved without snuffing")
	var state := Puzzles.initial_state(index)
	var hall := Vector2i(4, 1)
	var guard: Dictionary = state["guards"][0]
	var dist := absi(hall.x - int(guard["x"])) + absi(hall.y - int(guard["y"]))
	var lit: Dictionary = Rules.light_map(state)
	_check(dist <= int(guard["vision"]) and not lit.has(hall) and not Rules.watched_tiles(state, lit).has(hall), "the dark hall is inside his reach and unwatched")
	var visited := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(state["player"]["x"]) + int(action["dx"]), int(state["player"]["y"]) + int(action["dy"]))
			if dest == hall:
				visited = true
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "unlit watch solution failed while crossing the hall")
			return
		state = out["state"]
	_check(visited, "the unlit watch solution walks the dark hall inside his reach")


func _check_blind_wall() -> void:
	var index := _index_of("The Blind Wall")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var gap := Vector2i(6, 3)
	var wall := Vector2i(4, 3)
	var guard: Dictionary = state["guards"][0]
	var dist := absi(gap.x - int(guard["x"])) + absi(gap.y - int(guard["y"]))
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	_check(Rules.tile_at(state, wall.x, wall.y) == Rules.Tile.WALL, "a wall stands between the keeper and the gap")
	_check(dist <= int(guard["vision"]) and lit.has(gap) and not watch.has(gap), "the blind gap is lit, in reach, and unseen")
	var open: Dictionary = state.duplicate(true)
	open["tiles"][wall.y * open["w"] + wall.x] = Rules.Tile.FLOOR
	var open_lit: Dictionary = Rules.light_map(open)
	_check(Rules.watched_tiles(open, open_lit).has(gap), "opening that wall lets him watch the gap")
	var used := {}
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			used[int(action["lamp"])] = true
	_check(used.has(0) and not used.has(1), "the blind wall snuffs the near lamp and leaves the gap lamp")
	var crossed := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(state["player"]["x"]) + int(action["dx"]), int(state["player"]["y"]) + int(action["dy"]))
			if dest == gap:
				var lights: Dictionary = Rules.light_map(state)
				_check(
					not bool(state["lamps"][0]["lit"]) and bool(state["lamps"][1]["lit"]) and lights.has(gap) and not Rules.watched_tiles(state, lights).has(gap),
					"the gap is lit and unwatched when you cross"
				)
				crossed = true
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] == Rules.Result.LOSS or out["result"] == Rules.Result.ILLEGAL:
			_check(false, "blind wall solution failed during the gap check")
			return
		state = out["state"]
		if out["result"] == Rules.Result.WIN:
			break
	_check(crossed, "the blind wall solution crosses the gap")


func _check_barred_gap() -> void:
	var index := _index_of("The Barred Gap")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var saw := false
	for action in puzzle["solution"]:
		if str(action["type"]) != "toggle":
			var before: Dictionary = Rules.apply(state, action)
			if before["result"] != Rules.Result.OK:
				_check(false, "barred gap approach failed")
				return
			state = before["state"]
			continue
		var out: Dictionary = Rules.apply(state, action)
		saw = true
		var gap := Vector2i(6, 1)
		var around: Array = Rules.planned_path(out["state"], 0)
		var opened: Dictionary = out["state"].duplicate(true)
		opened["tiles"][gap.y * opened["w"] + gap.x] = Rules.Tile.FLOOR
		var through: Array = Rules.planned_path(opened, 0)
		_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "snuffing the hall lamp calls the keeper")
		_check(out["step"] == Vector2i(10, 3), "his next step starts the long way around")
		_check(not _path_has(around, gap) and _path_has(through, gap), "the gap is on the short road and off the road he can walk")
		_check(through.size() < around.size(), "the floor road around the gap is longer")
		break
	_check(saw, "the barred gap solution snuffs the hall lamp")
	var used := {}
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			used[int(action["lamp"])] = true
	_check(used.has(0) and not used.has(1), "the barred gap leaves the gap lamp burning")


func _check_north_step() -> void:
	var index := _index_of("The North Step")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 0, "dy": 1})
	if approach["result"] != Rules.Result.OK:
		_check(false, "north step approach failed")
		return
	state = approach["state"]
	var lamp: Dictionary = state["lamps"][0]
	var guard_before: Dictionary = state["guards"][0]
	var north := Vector2i(int(guard_before["x"]), int(guard_before["y"]) - 1)
	var west := Vector2i(int(guard_before["x"]) - 1, int(guard_before["y"]))
	var north_dist := absi(north.x - int(lamp["x"])) + absi(north.y - int(lamp["y"]))
	var west_dist := absi(west.x - int(lamp["x"])) + absi(west.y - int(lamp["y"]))
	var out: Dictionary = Rules.apply(state, {"type": "toggle", "lamp": 0})
	var guard_after: Dictionary = out["state"]["guards"][0]
	_check(north_dist == west_dist and Rules.tile_at(state, west.x, west.y) == Rules.Tile.FLOOR, "north and west are equal roads to the lamp")
	_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0 and out["step"] == north, "the tie breaks north")
	_check(out["step"] != west, "the tie does not break west")
	_check(int(guard_after["x"]) == int(guard_before["x"]) and int(guard_after["y"]) == int(guard_before["y"]), "he has not taken the north step yet")
	var used := {}
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			used[int(action["lamp"])] = true
	_check(used.has(0) and not used.has(1), "the north step snuffs the northwest lamp and leaves the south lamp")


func _check_dark_eye() -> void:
	var state := Puzzles.initial_state(_index_of("The Dark Eye"))
	var guard: Dictionary = state["guards"][0]
	var origin := Vector2i(int(guard["x"]), int(guard["y"]))
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	_check(not lit.has(origin) and not watch.has(origin), "the dark eye stands on a dark square that is not watched")
	var adjacent := false
	for dir in [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]:
		var cell: Vector2i = origin + dir
		if lit.has(cell) and watch.has(cell):
			adjacent = true
	_check(adjacent, "he still watches an adjacent lit tile")


func _check_early_threshold() -> void:
	var index := _index_of("The Early Threshold")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 0, "the early threshold is solved without snuffing")
	var state := Puzzles.initial_state(index)
	var exit_cell := Vector2i(5, 1)
	var first: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	if first["result"] != Rules.Result.OK:
		_check(false, "early threshold approach failed")
		return
	state = first["state"]
	var guard: Dictionary = state["guards"][0]
	_check(int(guard["x"]) == 5 and int(guard["y"]) == 2 and Rules.planned_step(state, 0) == exit_cell, "his next step is the door")
	var won: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var still: Dictionary = won["state"]["guards"][0]
	_check(won["result"] == Rules.Result.WIN and int(still["x"]) == 5 and int(still["y"]) == 2, "the door wins before he steps onto it")
	var late := Puzzles.initial_state(index)
	late = Rules.apply(late, {"type": "wait"})["state"]
	late = Rules.apply(late, {"type": "move", "dx": 1, "dy": 0})["state"]
	var bumped: Dictionary = Rules.apply(late, {"type": "move", "dx": 1, "dy": 0})
	_check(bumped["result"] == Rules.Result.LOSS and bumped["reason"] == "guard", "waiting lets him take the door")


func _check_cellar_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Cellar Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_cellar_rooms() -> void:
	_check_cellar_identity()
	_check_cellar_watched_steps()
	_check_open_corner()
	_check_brick_shade()
	_check_quiet_wick()
	_check_earlier_keeper()
	_check_dim_lane()
	_check_still_post()


func _check_cellar_identity() -> void:
	var layouts := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		var layout := "|".join(puzzle["rows"])
		var title := str(puzzle["title"])
		if str(puzzle["wing"]) == "Cellar Wing":
			if layouts.has(layout):
				layout_ok = false
			if titles.has(title):
				title_ok = false
		if not layouts.has(layout):
			layouts[layout] = title
		if not titles.has(title):
			titles[title] = true
	_check(layout_ok, "each cellar room has its own layout")
	_check(title_ok, "each cellar room has its own name")


func _check_cellar_watched_steps() -> void:
	var cases := [
		["The Open Corner", "D D D R R R U", 4, 3],
		["The Brick Shade", "R R", 3, 1],
		["The Quiet Wick", "R R R R D T0 R U", 6, 3],
		["The Earlier Keeper", "D D D R R R R R", 6, 4],
		["The Dim Lane", "R R R D", 4, 3],
		["The Still Post", "R R R R R R R R D", 9, 2],
	]
	for entry in cases:
		_expect_watched_loss(str(entry[0]), str(entry[1]), int(entry[2]), int(entry[3]))


func _check_open_corner() -> void:
	var index := _index_of("The Open Corner")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 0, "the open corner is solved without snuffing")
	var state := Puzzles.initial_state(index)
	var lamp: Dictionary = state["lamps"][0]
	var exit_cell := _find_tile(state, Rules.Tile.EXIT)
	var dx := exit_cell.x - int(lamp["x"])
	var dy := exit_cell.y - int(lamp["y"])
	var lit: Dictionary = Rules.light_map(state)
	_check(not Rules.in_diamond(lamp, exit_cell.x, exit_cell.y), "the open corner's door is outside the diamond")
	_check(maxi(absi(dx), absi(dy)) <= int(lamp["radius"]), "that door is inside the square of the same radius")
	_check(not lit.has(exit_cell), "the diagonal door stays dark")
	var beside := Vector2i(int(lamp["x"]), int(lamp["y"]) + 1)
	_check(lit.has(beside) and Rules.watched_tiles(state, lit).has(beside), "the orthogonal square south of the lamp is lit and watched")


func _check_brick_shade() -> void:
	var index := _index_of("The Brick Shade")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 0, "the brick shade is solved without snuffing")
	var state := Puzzles.initial_state(index)
	var lamp: Dictionary = state["lamps"][0]
	var exit_cell := _find_tile(state, Rules.Tile.EXIT)
	var dx := exit_cell.x - int(lamp["x"])
	var dy := exit_cell.y - int(lamp["y"])
	_check(
		absi(dx) + absi(dy) <= int(lamp["radius"]) and dx * int(lamp["fx"]) + dy * int(lamp["fy"]) >= 0,
		"the shaded door sits inside the lamp's diamond"
	)
	_check(not Rules.light_map(state).has(exit_cell), "the wall keeps that door dark")
	var wall := Vector2i(int(lamp["x"]) + 1, int(lamp["y"]))
	_check(Rules.tile_at(state, wall.x, wall.y) == Rules.Tile.WALL, "a wall stands between the wick and the door")
	var opened: Dictionary = state.duplicate(true)
	opened["tiles"][wall.y * opened["w"] + wall.x] = Rules.Tile.FLOOR
	_check(Rules.light_map(opened).has(exit_cell), "opening that wall lets the diamond reach the door")


func _check_quiet_wick() -> void:
	var index := _index_of("The Quiet Wick")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	_check(not bool(state["lamps"][0]["lit"]), "the quiet wick starts unlit")
	var gap := _find_tile(state, Rules.Tile.GAP)
	_check(not Rules.light_map(state).has(gap), "the quiet wick's gap starts dark")
	var toggles := 0
	var saw := false
	var crossed := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
			var out: Dictionary = Rules.apply(state, action)
			saw = true
			_check(out["result"] == Rules.Result.OK and int(out["called"]) == -1, "lighting the quiet wick calls no one")
			_check(bool(out["state"]["lamps"][0]["lit"]), "the quiet wick is lit after that toggle")
			_check(not bool(out["state"]["guards"][0]["alert"]), "the quiet wick's keeper is not alerted")
			_check(Rules.light_map(out["state"]).has(gap), "lighting the quiet wick opens the gap")
			state = out["state"]
			continue
		if str(action["type"]) == "move":
			var dest := Vector2i(int(state["player"]["x"]) + int(action["dx"]), int(state["player"]["y"]) + int(action["dy"]))
			if dest == gap:
				var lights: Dictionary = Rules.light_map(state)
				_check(
					bool(state["lamps"][0]["lit"]) and lights.has(gap) and not Rules.watched_tiles(state, lights).has(gap),
					"the quiet wick's gap is lit and unwatched when you cross"
				)
				crossed = true
		var step: Dictionary = Rules.apply(state, action)
		if step["result"] != Rules.Result.OK and step["result"] != Rules.Result.WIN:
			_check(false, "quiet wick solution broke before the check finished")
			return
		state = step["state"]
	_check(saw and toggles == 1, "the quiet wick solution lights its lamp once")
	_check(crossed, "the quiet wick solution crosses the gap")


func _check_earlier_keeper() -> void:
	var index := _index_of("The Earlier Keeper")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var east_x := int(state["guards"][1]["x"])
	var east_y := int(state["guards"][1]["y"])
	var saw := false
	for action in puzzle["solution"]:
		if str(action["type"]) != "toggle":
			var before: Dictionary = Rules.apply(state, action)
			if before["result"] != Rules.Result.OK and before["result"] != Rules.Result.WIN:
				_check(false, "earlier keeper approach failed")
				return
			state = before["state"]
			if before["result"] == Rules.Result.WIN:
				break
			continue
		var lp: Dictionary = state["lamps"][int(action["lamp"])]
		var dist0 := absi(int(state["guards"][0]["x"]) - int(lp["x"])) + absi(int(state["guards"][0]["y"]) - int(lp["y"]))
		var dist1 := absi(int(state["guards"][1]["x"]) - int(lp["x"])) + absi(int(state["guards"][1]["y"]) - int(lp["y"]))
		var out: Dictionary = Rules.apply(state, action)
		saw = true
		_check(dist0 == dist1, "both cellar keepers stand the same distance from the lamp")
		_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "the tie calls the lower keeper")
		_check(
			int(out["state"]["guards"][1]["x"]) == east_x and int(out["state"]["guards"][1]["y"]) == east_y and not bool(out["state"]["guards"][1]["alert"]),
			"the east keeper is not called"
		)
		state = out["state"]
	_check(saw, "the earlier keeper solution snuffs the lamp")
	var end: Dictionary = state["guards"][1]
	_check(int(end["x"]) == east_x and int(end["y"]) == east_y and not bool(end["alert"]), "the east keeper never moves")


func _check_dim_lane() -> void:
	var index := _index_of("The Dim Lane")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 0, "the dim lane is solved without snuffing")
	var state := Puzzles.initial_state(index)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var between := Vector2i(4, 2)
	var guard: Dictionary = state["guards"][0]
	var dist := absi(gap.x - int(guard["x"])) + absi(gap.y - int(guard["y"]))
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	_check(dist <= int(guard["vision"]) and lit.has(gap) and not watch.has(gap), "the dim gap is lit, in reach, and unseen")
	_check(not lit.has(between) and Rules.tile_at(state, between.x, between.y) == Rules.Tile.FLOOR, "a dark floor tile stands between the keeper and the gap")
	var opened: Dictionary = state.duplicate(true)
	var lamps: Array = opened["lamps"]
	lamps.append({
		"id": lamps.size(),
		"x": between.x,
		"y": between.y,
		"facing": "e",
		"fx": 1,
		"fy": 0,
		"radius": 0,
		"lit": true,
	})
	var open_lit: Dictionary = Rules.light_map(opened)
	_check(open_lit.has(between) and Rules.watched_tiles(opened, open_lit).has(gap), "lighting the dark square lets him watch the gap")
	var crossed := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(state["player"]["x"]) + int(action["dx"]), int(state["player"]["y"]) + int(action["dy"]))
			if dest == gap:
				var lights: Dictionary = Rules.light_map(state)
				_check(lights.has(gap) and not Rules.watched_tiles(state, lights).has(gap), "the dim gap is lit and unwatched when you cross")
				crossed = true
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] == Rules.Result.LOSS or out["result"] == Rules.Result.ILLEGAL:
			_check(false, "dim lane solution failed during the gap check")
			return
		state = out["state"]
		if out["result"] == Rules.Result.WIN:
			break
	_check(crossed, "the dim lane solution crosses the gap")


func _check_still_post() -> void:
	var index := _index_of("The Still Post")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(gap) and Rules.watched_tiles(state, lit).has(gap), "the still post's gap starts lit and watched")
	var other := Rules.clone(state)
	other["guards"][0]["x"] = 8
	other["guards"][0]["y"] = 4
	var other_lit: Dictionary = Rules.light_map(other)
	_check(Rules.watched_tiles(other, other_lit).has(gap), "the far end of his walk still watches the gap")
	var used := {}
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			used[int(action["lamp"])] = true
	_check(used.has(0) and not used.has(1), "the still post snuffs the west wick and leaves the gap lamp")
	var held := false
	var crossed := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(state["player"]["x"]) + int(action["dx"]), int(state["player"]["y"]) + int(action["dy"]))
			if dest == gap:
				var lights: Dictionary = Rules.light_map(state)
				var keeper: Dictionary = state["guards"][0]
				_check(
					not bool(state["lamps"][0]["lit"]) and bool(state["lamps"][1]["lit"]) and lights.has(gap) and not Rules.watched_tiles(state, lights).has(gap),
					"the gap is still lit and unwatched when you cross"
				)
				_check(bool(keeper["holding"]) and int(keeper["x"]) == 2 and int(keeper["y"]) == 4, "he is holding on the west wick when you cross")
				crossed = true
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] == Rules.Result.LOSS or out["result"] == Rules.Result.ILLEGAL:
			_check(false, "still post solution failed during the hold check")
			return
		state = out["state"]
		var guard: Dictionary = state["guards"][0]
		if bool(guard["holding"]):
			held = true
		if out["result"] == Rules.Result.WIN:
			break
	_check(held and crossed, "the still post solution waits until he holds, then crosses")
	var parked := Puzzles.initial_state(index)
	for token in ["D", "D", "D", "T0", "W", "W", "W", "W", "W", "W", "W"]:
		var action := {"type": "wait"}
		if token == "D":
			action = {"type": "move", "dx": 0, "dy": 1}
		elif token == "T0":
			action = {"type": "toggle", "lamp": 0}
		var step: Dictionary = Rules.apply(parked, action)
		if step["result"] != Rules.Result.OK:
			_check(false, "still post hold setup failed")
			return
		parked = step["state"]
	var keeper: Dictionary = parked["guards"][0]
	_check(bool(keeper["holding"]) and int(keeper["x"]) == 2 and int(keeper["y"]) == 4, "he holds on the snuffed wick")
	var stayed := true
	for _i in 4:
		var waited: Dictionary = Rules.apply(parked, {"type": "wait"})
		if waited["result"] != Rules.Result.OK:
			stayed = false
			break
		parked = waited["state"]
		var still: Dictionary = parked["guards"][0]
		if not bool(still["holding"]) or int(still["x"]) != 2 or int(still["y"]) != 4:
			stayed = false
	_check(stayed, "waiting does not send him back to the rail")
	var released: Dictionary = parked.duplicate(true)
	released["guards"][0]["holding"] = false
	var resumed: Vector2i = Rules.planned_step(released, 0)
	_check(resumed != Vector2i(2, 4), "without the hold he would resume the rail")


func _check_gallery_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Gallery Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_gallery_rooms() -> void:
	_check_gallery_identity()
	_check_gallery_watched_steps()
	_check_rear_shade()
	_check_late_call()
	_check_closed_hall()
	_check_lit_crossing()
	_check_keepers_square()
	_check_outer_ring()


func _check_gallery_identity() -> void:
	var layouts := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		var layout := "|".join(puzzle["rows"])
		var title := str(puzzle["title"])
		if str(puzzle["wing"]) == "Gallery Wing":
			if layouts.has(layout):
				layout_ok = false
			if titles.has(title):
				title_ok = false
		if not layouts.has(layout):
			layouts[layout] = title
		if not titles.has(title):
			titles[title] = true
	_check(layout_ok, "each gallery room has its own layout")
	_check(title_ok, "each gallery room has its own name")


func _check_gallery_watched_steps() -> void:
	var cases := [
		["The Rear Shade", "D D D R R R R", 5, 4],
		["The Late Call", "D D R R R R R R", 7, 3],
		["The Closed Hall", "R D D D R R R R", 6, 4],
		["The Lit Crossing", "D D D R R R R R R", 7, 4],
		["The Keeper's Square", "D R R R", 4, 2],
		["The Outer Ring", "D R R R R", 5, 2],
	]
	for entry in cases:
		_expect_watched_loss(str(entry[0]), str(entry[1]), int(entry[2]), int(entry[3]))


func _check_rear_shade() -> void:
	var index := _index_of("The Rear Shade")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var lamp: Dictionary = state["lamps"][0]
	var behind := Vector2i(int(lamp["x"]) - int(lamp["fx"]), int(lamp["y"]) - int(lamp["fy"]))
	var ahead := Vector2i(int(lamp["x"]) + int(lamp["fx"]), int(lamp["y"]) + int(lamp["fy"]))
	var side := Vector2i(int(lamp["x"]), int(lamp["y"]) + 1)
	var lit: Dictionary = Rules.light_map(state)
	_check(not Rules.in_diamond(lamp, behind.x, behind.y) and not lit.has(behind), "the square directly behind the flame stays dark")
	_check(lit.has(ahead) and lit.has(side), "the hall in front of the flame and the square beside it are lit")
	var stood := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			var player: Dictionary = state["player"]
			stood = int(player["x"]) == behind.x and int(player["y"]) == behind.y
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "rear shade solution failed")
			return
		state = out["state"]
	_check(stood, "the rear shade is snuffed from the dark square behind the flame")


func _check_late_call() -> void:
	var index := _index_of("The Late Call")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var exit_cell := _find_tile(state, Rules.Tile.EXIT)
	var lit0: Dictionary = Rules.light_map(state)
	_check(lit0.has(exit_cell) and Rules.watched_tiles(state, lit0).has(exit_cell), "the late call's door starts lit and watched")
	var saw := false
	for action in puzzle["solution"]:
		if str(action["type"]) != "toggle":
			var before: Dictionary = Rules.apply(state, action)
			if before["result"] != Rules.Result.OK:
				_check(false, "late call approach failed")
				return
			state = before["state"]
			continue
		var lamp: Dictionary = state["lamps"][int(action["lamp"])]
		var dist0 := absi(int(state["guards"][0]["x"]) - int(lamp["x"])) + absi(int(state["guards"][0]["y"]) - int(lamp["y"]))
		var dist1 := absi(int(state["guards"][1]["x"]) - int(lamp["x"])) + absi(int(state["guards"][1]["y"]) - int(lamp["y"]))
		var player: Dictionary = state["player"]
		var guard_before: Dictionary = state["guards"][0]
		var out: Dictionary = Rules.apply(state, action)
		saw = true
		var guard_after: Dictionary = out["state"]["guards"][0]
		_check(dist0 < dist1, "the late call's nearer keeper is strictly closer")
		_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "the snuff calls the nearer keeper")
		_check(out["step"] == Vector2i(int(player["x"]), int(player["y"])), "his next step is the square you are standing on")
		_check(
			int(guard_after["x"]) == int(guard_before["x"]) and int(guard_after["y"]) == int(guard_before["y"]),
			"he has not taken that step yet"
		)
		_check(not bool(out["state"]["guards"][1]["alert"]), "the farther keeper is not called")
		var waited: Dictionary = Rules.apply(out["state"], {"type": "wait"})
		_check(waited["result"] == Rules.Result.LOSS and waited["reason"] == "guard", "waiting lets the called keeper step onto you")
		break
	_check(saw, "the late call solution snuffs the lamp")


func _check_closed_hall() -> void:
	var index := _index_of("The Closed Hall")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var exit_cell := _find_tile(state, Rules.Tile.EXIT)
	_check(Rules.light_map(state).has(exit_cell), "the closed hall's door starts lit")
	var first: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	_check(first["result"] == Rules.Result.OK, "the square behind the hall lamp is dark")
	state = first["state"]
	var player: Dictionary = state["player"]
	var dest := Vector2i(int(player["x"]) + 1, int(player["y"]))
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(dest) and not Rules.watched_tiles(state, lit).has(dest), "the hall is lit and unwatched")
	var refused: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stayed: Dictionary = refused["state"]["player"]
	_check(
		refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "lit" and int(stayed["x"]) == int(player["x"]) and int(stayed["y"]) == int(player["y"]),
		"unwatched lit floor in the gallery is refused"
	)
	var used := {}
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			used[int(action["lamp"])] = true
	_check(used.has(0) and not used.has(1), "the closed hall snuffs the hall lamp and leaves the lower wick")


func _check_lit_crossing() -> void:
	var index := _index_of("The Lit Crossing")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var gap := _find_tile(state, Rules.Tile.GAP)
	_check(not bool(state["lamps"][0]["lit"]) and not Rules.light_map(state).has(gap), "the lit crossing's gap starts dark")
	var blocked := Puzzles.initial_state(index)
	for token in ["R", "R", "R", "R", "D"]:
		var step: Dictionary = Rules.apply(blocked, {"type": "move", "dx": 1 if token == "R" else 0, "dy": 1 if token == "D" else 0})
		if step["result"] != Rules.Result.OK:
			_check(false, "lit crossing gap approach failed")
			return
		blocked = step["state"]
	var dark: Dictionary = Rules.apply(blocked, {"type": "move", "dx": 1, "dy": 0})
	var stayed: Dictionary = dark["state"]["player"]
	var before: Dictionary = blocked["player"]
	_check(
		dark["result"] == Rules.Result.ILLEGAL and dark["reason"] == "darkgap" and int(stayed["x"]) == int(before["x"]) and int(stayed["y"]) == int(before["y"]),
		"a dark gap is still refused"
	)
	var toggles := 0
	var saw := false
	var crossed := false
	state = Puzzles.initial_state(index)
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
			var out: Dictionary = Rules.apply(state, action)
			saw = true
			_check(out["result"] == Rules.Result.OK and int(out["called"]) == -1, "lighting the crossing wick calls no one")
			_check(bool(out["state"]["lamps"][0]["lit"]) and Rules.light_map(out["state"]).has(gap), "lighting the crossing wick opens the gap")
			state = out["state"]
			continue
		if str(action["type"]) == "move":
			var dest := Vector2i(int(state["player"]["x"]) + int(action["dx"]), int(state["player"]["y"]) + int(action["dy"]))
			if dest == gap:
				var lights: Dictionary = Rules.light_map(state)
				_check(
					bool(state["lamps"][0]["lit"]) and bool(state["lamps"][1]["lit"]) and lights.has(gap) and not Rules.watched_tiles(state, lights).has(gap),
					"the gap is lit and unwatched when you cross"
				)
				crossed = true
		var step: Dictionary = Rules.apply(state, action)
		if step["result"] != Rules.Result.OK and step["result"] != Rules.Result.WIN:
			_check(false, "lit crossing solution broke before the check finished")
			return
		state = step["state"]
	_check(saw and toggles == 1, "the lit crossing solution lights its gap lamp once")
	_check(crossed, "the lit crossing solution crosses the gap")


func _check_keepers_square() -> void:
	var index := _index_of("The Keeper's Square")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 0, "the keeper's square is solved without snuffing")
	var state := Puzzles.initial_state(index)
	var guard: Dictionary = state["guards"][0]
	var tile := Vector2i(int(guard["x"]), int(guard["y"]))
	var lit: Dictionary = Rules.light_map(state)
	_check(not lit.has(tile) and not Rules.watched_tiles(state, lit).has(tile), "the keeper stands on a dark square that is not watched")
	for _i in 2:
		var step: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
		if step["result"] != Rules.Result.OK:
			_check(false, "keeper square approach failed")
			return
		state = step["state"]
	var lost: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var landed: Dictionary = lost["state"]["player"]
	_check(
		lost["result"] == Rules.Result.LOSS and lost["reason"] == "guard" and int(landed["x"]) == tile.x and int(landed["y"]) == tile.y,
		"stepping onto the keeper is a loss"
	)
	state = Puzzles.initial_state(index)
	for action in puzzle["solution"]:
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "keeper square solution failed")
			return
		state = out["state"]
	var end: Dictionary = state["guards"][0]
	_check(int(end["x"]) == tile.x and int(end["y"]) == tile.y and not bool(end["alert"]), "the keeper never leaves his square")


func _check_outer_ring() -> void:
	var index := _index_of("The Outer Ring")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var guard: Dictionary = state["guards"][0]
	var lamp: Dictionary = state["lamps"][0]
	var inner := Vector2i(5, 2)
	var outer := Vector2i(6, 2)
	var exit_cell := _find_tile(state, Rules.Tile.EXIT)
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	var inner_dist := absi(inner.x - int(guard["x"])) + absi(inner.y - int(guard["y"]))
	var outer_dist := absi(outer.x - int(guard["x"])) + absi(outer.y - int(guard["y"]))
	var exit_dist := absi(exit_cell.x - int(guard["x"])) + absi(exit_cell.y - int(guard["y"]))
	_check(int(guard["vision"]) == 1, "the outer ring keeper sees one square")
	_check(inner_dist <= int(guard["vision"]) and lit.has(inner) and watch.has(inner), "the inner square is inside his vision and watched")
	_check(outer_dist == int(guard["vision"]) + 1 and lit.has(outer) and not watch.has(outer), "the next square is lit and outside his vision")
	_check(
		exit_dist > int(guard["vision"]) and lit.has(exit_cell) and not watch.has(exit_cell) and Rules.in_diamond(lamp, exit_cell.x, exit_cell.y),
		"the door is lit, inside the lamp, and outside his vision"
	)
	var side := Rules.clone(state)
	side["player"]["x"] = 8
	side["player"]["y"] = 2
	var refused: Dictionary = Rules.apply(side, {"type": "move", "dx": -1, "dy": 0})
	var stayed: Dictionary = refused["state"]["player"]
	_check(
		refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "lit" and int(stayed["x"]) == 8 and int(stayed["y"]) == 2,
		"the lit door outside his vision is refused"
	)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 1, "the outer ring solution snuffs its lamp once")


func _find_tile(state: Dictionary, kind: int) -> Vector2i:
	for y in state["h"]:
		for x in state["w"]:
			if Rules.tile_at(state, x, y) == kind:
				return Vector2i(x, y)
	return Vector2i(-1, -1)


func _path_has(path: Array, cell: Vector2i) -> bool:
	for point in path:
		var tile: Vector2i = point
		if tile == cell:
			return true
	return false


func _check_court_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Court Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_court_rooms() -> void:
	_check_court_identity()
	_check_earlier_wings_have_no_plates()
	_check_court_plates_are_required()
	_check_court_watched_steps()
	_check_first_plate()
	_check_quiet_wait()
	_check_far_keeper()
	_check_lit_plate()
	_check_plate_gap()
	_check_last_hold()
	_check_plate_tie_calls_lower_index()


func _check_court_identity() -> void:
	var layouts := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		var layout := "|".join(puzzle["rows"])
		var title := str(puzzle["title"])
		if str(puzzle["wing"]) == "Court Wing":
			if layouts.has(layout):
				layout_ok = false
			if titles.has(title):
				title_ok = false
		if not layouts.has(layout):
			layouts[layout] = title
		if not titles.has(title):
			titles[title] = true
	_check(layout_ok, "each court room has its own layout")
	_check(title_ok, "each court room has its own name")


func _check_earlier_wings_have_no_plates() -> void:
	var clean := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Court Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("P"):
				clean = false
		var state := Puzzles.initial_state(i)
		for y in state["h"]:
			for x in state["w"]:
				if Rules.tile_at(state, x, y) == Rules.Tile.PLATE:
					clean = false
	_check(clean, "earlier wings have no plates")


func _check_court_plates_are_required() -> void:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) != "Court Wing":
			continue
		var state := Puzzles.initial_state(i)
		var stepped := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "move" and Rules.tile_at(state, int(state["player"]["x"]) + int(action["dx"]), int(state["player"]["y"]) + int(action["dy"])) == Rules.Tile.PLATE:
				stepped = true
			var out: Dictionary = Rules.apply(state, action)
			if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
				break
			state = out["state"]
		_check(stepped, str(puzzle["title"]) + " steps onto a plate")
		var blocked := Puzzles.initial_state(i)
		for y in blocked["h"]:
			for x in blocked["w"]:
				if Rules.tile_at(blocked, x, y) == Rules.Tile.PLATE:
					blocked["tiles"][y * int(blocked["w"]) + x] = Rules.Tile.WALL
		var won := false
		for action in puzzle["solution"]:
			var walled: Dictionary = Rules.apply(blocked, action)
			if walled["result"] == Rules.Result.WIN:
				won = true
				break
			if walled["result"] == Rules.Result.OK:
				blocked = walled["state"]
		_check(not won, str(puzzle["title"]) + " needs the plate")


func _check_court_watched_steps() -> void:
	var cases := [
		["The First Plate", "D D", 1, 3],
		["The Quiet Wait", "D L D", 7, 3],
		["The Far Keeper", "D D", 1, 3],
		["The Lit Plate", "D D R R R R R R R R R", 10, 3],
		["The Plate Gap", "R R R R R", 6, 1],
		["The Last Hold", "R R R R R R R R D", 9, 2],
	]
	for entry in cases:
		_expect_watched_loss(str(entry[0]), str(entry[1]), int(entry[2]), int(entry[3]))


func _check_first_plate() -> void:
	var index := _index_of("The First Plate")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var plate := _find_tile(state, Rules.Tile.PLATE)
	var saw := false
	for action in puzzle["solution"]:
		var player: Dictionary = state["player"]
		var dest := Vector2i(int(player["x"]) + int(action.get("dx", 0)), int(player["y"]) + int(action.get("dy", 0)))
		var guard_before: Dictionary = state["guards"][0]
		var out: Dictionary = Rules.apply(state, action)
		if str(action["type"]) == "move" and dest == plate:
			var guard_after: Dictionary = out["state"]["guards"][0]
			_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "stepping on the first plate calls the keeper")
			_check(out["step"] == plate, "the arrow shows the square he is about to take")
			_check(
				int(guard_after["x"]) == int(guard_before["x"]) and int(guard_after["y"]) == int(guard_before["y"]),
				"he has not taken that step yet"
			)
			var left: Dictionary = Rules.apply(out["state"], {"type": "move", "dx": 1, "dy": 0})
			_check(left["result"] == Rules.Result.WIN, "leaving that square wins")
			var stayed: Dictionary = Rules.apply(out["state"], {"type": "wait"})
			_check(stayed["result"] == Rules.Result.LOSS and stayed["reason"] == "guard", "staying on that square loses")
			saw = true
			break
		if out["result"] != Rules.Result.OK:
			_check(false, "first plate approach failed")
			return
		state = out["state"]
	_check(saw, "the first plate solution steps on the plate")


func _check_quiet_wait() -> void:
	var index := _index_of("The Quiet Wait")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var plate := _find_tile(state, Rules.Tile.PLATE)
	var called_on_entry := false
	var waited := false
	for action in puzzle["solution"]:
		var player: Dictionary = state["player"]
		var on_plate := Rules.tile_at(state, int(player["x"]), int(player["y"])) == Rules.Tile.PLATE
		var guard_before: Dictionary = state["guards"][0]
		var dest := Vector2i(int(player["x"]), int(player["y"]))
		if str(action["type"]) == "move":
			dest = Vector2i(int(player["x"]) + int(action["dx"]), int(player["y"]) + int(action["dy"]))
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "quiet wait solution failed")
			return
		if str(action["type"]) == "move" and dest == plate and int(out["called"]) >= 0:
			called_on_entry = true
		if str(action["type"]) == "wait" and on_plate:
			var guard_after: Dictionary = out["state"]["guards"][0]
			_check(called_on_entry, "the quiet wait is after the plate has already called")
			_check(int(out["called"]) == -1, "waiting on a plate does not call twice")
			_check(
				int(guard_after["x"]) != int(guard_before["x"]) or int(guard_after["y"]) != int(guard_before["y"]),
				"the called keeper still takes his one step while you wait"
			)
			waited = true
		state = out["state"]
	_check(waited, "the quiet wait solution waits on the plate")
	state = Puzzles.initial_state(index)
	var entries := 0
	var returned := false
	for token in ["L", "L", "L", "L", "R", "L"]:
		var action := {"type": "move", "dx": -1 if token == "L" else 1, "dy": 0}
		var player: Dictionary = state["player"]
		var dest := Vector2i(int(player["x"]) + int(action["dx"]), int(player["y"]))
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] != Rules.Result.OK:
			_check(false, "quiet wait return approach failed")
			return
		if dest == plate:
			entries += 1
			if entries == 2:
				_check(int(out["called"]) == 0, "leaving and stepping back on a plate calls again")
				returned = true
		state = out["state"]
	_check(returned, "the return route steps back onto the plate")
	var caught: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var landed: Dictionary = caught["state"]["player"]
	_check(
		caught["result"] == Rules.Result.LOSS and caught["reason"] == "guard" and int(landed["x"]) == plate.x + 1 and int(landed["y"]) == plate.y,
		"that second call catches a route that returns"
	)


func _check_far_keeper() -> void:
	var index := _index_of("The Far Keeper")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var plate := _find_tile(state, Rules.Tile.PLATE)
	var near: Dictionary = state["guards"][1]
	var far: Dictionary = state["guards"][0]
	var near_dist := absi(int(near["x"]) - plate.x) + absi(int(near["y"]) - plate.y)
	var far_dist := absi(int(far["x"]) - plate.x) + absi(int(far["y"]) - plate.y)
	_check(int(far["id"]) < int(near["id"]) and near_dist < far_dist, "the nearer keeper has the higher index")
	var called_near := false
	var far_still := true
	for action in puzzle["solution"]:
		var player: Dictionary = state["player"]
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "far keeper solution failed")
			return
		if str(action["type"]) == "move":
			var dest := Vector2i(int(player["x"]) + int(action["dx"]), int(player["y"]) + int(action["dy"]))
			if dest == plate:
				_check(int(out["called"]) == 1, "the plate calls the nearer keeper")
				_check(not bool(out["state"]["guards"][0]["alert"]), "the farther keeper is not called")
				called_near = true
		state = out["state"]
		var parked: Dictionary = state["guards"][0]
		if int(parked["x"]) != int(far["x"]) or int(parked["y"]) != int(far["y"]) or bool(parked["alert"]) or bool(parked["holding"]):
			far_still = false
	_check(called_near, "the far keeper solution steps on the plate")
	_check(far_still, "the farther keeper never moves")


func _check_lit_plate() -> void:
	var index := _index_of("The Lit Plate")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var plate := _find_tile(state, Rules.Tile.PLATE)
	var lit0: Dictionary = Rules.light_map(state)
	_check(lit0.has(plate) and not Rules.watched_tiles(state, lit0).has(plate), "the lit plate starts inside a lamp diamond and unwatched")
	var first: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	_check(first["result"] == Rules.Result.OK, "the square before the lit plate is dark")
	var refused: Dictionary = Rules.apply(first["state"], {"type": "move", "dx": 1, "dy": 0})
	var stayed: Dictionary = refused["state"]["player"]
	_check(
		refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "lit" and int(stayed["x"]) == 2 and int(stayed["y"]) == 1,
		"a lit plate is refused"
	)
	var snuff_target := Vector2i(-1, -1)
	var plate_called := false
	state = Puzzles.initial_state(index)
	for action in puzzle["solution"]:
		var player: Dictionary = state["player"]
		var dest := Vector2i(int(player["x"]), int(player["y"]))
		if str(action["type"]) == "move":
			dest = Vector2i(int(player["x"]) + int(action["dx"]), int(player["y"]) + int(action["dy"]))
		var before_lit: Dictionary = Rules.light_map(state)
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "lit plate solution failed")
			return
		if str(action["type"]) == "toggle":
			var guard: Dictionary = out["state"]["guards"][0]
			snuff_target = Vector2i(int(guard["ax"]), int(guard["ay"]))
			_check(int(out["called"]) == 0, "snuffing the lamp over the plate calls the keeper")
		if str(action["type"]) == "move" and dest == plate:
			var guard: Dictionary = out["state"]["guards"][0]
			_check(not before_lit.has(plate), "the plate is dark when you step on it")
			_check(int(out["called"]) == 0 and Vector2i(int(guard["ax"]), int(guard["ay"])) == plate, "stepping onto the dark plate calls him again")
			plate_called = true
		state = out["state"]
	_check(snuff_target == Vector2i(3, 2) and snuff_target != plate and plate_called, "the snuff and the plate call different tiles")


func _check_plate_gap() -> void:
	var index := _index_of("The Plate Gap")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 0, "the plate gap is solved without snuffing")
	var state := Puzzles.initial_state(index)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var plate := _find_tile(state, Rules.Tile.PLATE)
	var called := false
	var crossed := false
	for action in puzzle["solution"]:
		var player: Dictionary = state["player"]
		var dest := Vector2i(int(player["x"]), int(player["y"]))
		if str(action["type"]) == "move":
			dest = Vector2i(int(player["x"]) + int(action["dx"]), int(player["y"]) + int(action["dy"]))
			if dest == gap:
				var lights: Dictionary = Rules.light_map(state)
				_check(
					bool(state["lamps"][0]["lit"]) and lights.has(gap) and not Rules.watched_tiles(state, lights).has(gap),
					"the plate gap stays lit and unwatched when you cross"
				)
				crossed = true
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "plate gap solution failed")
			return
		if dest == plate and str(action["type"]) == "move":
			_check(int(out["called"]) == 0, "the plate gap calls the keeper off the gap")
			called = true
		state = out["state"]
	_check(called and crossed, "the plate gap solution steps the plate, then crosses")


func _check_last_hold() -> void:
	var index := _index_of("The Last Hold")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var plate := _find_tile(state, Rules.Tile.PLATE)
	var held := false
	var crossed := false
	var hold_state: Dictionary = {}
	for action in puzzle["solution"]:
		var player: Dictionary = state["player"]
		if str(action["type"]) == "move":
			var dest := Vector2i(int(player["x"]) + int(action["dx"]), int(player["y"]) + int(action["dy"]))
			if dest == gap:
				var lights: Dictionary = Rules.light_map(state)
				var guard: Dictionary = state["guards"][0]
				_check(bool(guard["holding"]) and Vector2i(int(guard["x"]), int(guard["y"])) == plate, "he is holding on the plate when you cross")
				_check(
					bool(state["lamps"][0]["lit"]) and lights.has(gap) and not Rules.watched_tiles(state, lights).has(gap),
					"the last hold's gap is still lit and unwatched when you cross"
				)
				crossed = true
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "last hold solution failed")
			return
		state = out["state"]
		var keeper: Dictionary = state["guards"][0]
		if bool(keeper["holding"]) and not held:
			held = true
			hold_state = Rules.clone(state)
			_check(Vector2i(int(keeper["x"]), int(keeper["y"])) == plate, "he holds on the plate")
	_check(held and crossed, "the last hold solution waits until he holds, then crosses")
	var released: Dictionary = Rules.clone(hold_state)
	released["guards"][0]["holding"] = false
	var resumed: Vector2i = Rules.planned_step(released, 0)
	_check(resumed != plate, "without the hold he would resume the rail")
	for rail_cell in [Vector2i(8, 3), Vector2i(8, 4)]:
		var posted: Dictionary = Rules.clone(hold_state)
		posted["guards"][0]["x"] = rail_cell.x
		posted["guards"][0]["y"] = rail_cell.y
		posted["guards"][0]["holding"] = false
		posted["guards"][0]["alert"] = false
		var lights: Dictionary = Rules.light_map(posted)
		_check(lights.has(gap) and Rules.watched_tiles(posted, lights).has(gap), "back on the rail at %s, that gap is watched" % rail_cell)


func _check_plate_tie_calls_lower_index() -> void:
	var state := Rules.build(
		PackedStringArray(["#######", "#S.P..#", "#.....#", "#######"]),
		[],
		[
			{"x": 5, "y": 2, "vision": 1, "rail": [Vector2i(5, 2)]},
			{"x": 1, "y": 2, "vision": 1, "rail": [Vector2i(1, 2)]},
		]
	)
	var plate := Vector2i(3, 1)
	var dist0 := absi(5 - plate.x) + absi(2 - plate.y)
	var dist1 := absi(1 - plate.x) + absi(2 - plate.y)
	_check(dist0 == dist1 and dist0 > 0, "the plate tie keeps both keepers the same distance")
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	if approach["result"] != Rules.Result.OK:
		_check(false, "plate tie approach failed")
		return
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	var called: Dictionary = stepped["state"]["guards"][0]
	_check(stepped["result"] == Rules.Result.OK and int(stepped["called"]) == 0, "a distance tie on a plate calls the lower index")
	_check(
		Vector2i(int(called["ax"]), int(called["ay"])) == plate and not bool(stepped["state"]["guards"][1]["alert"]),
		"the higher index is not called"
	)


func _check_nave_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Nave Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_nave_rooms() -> void:
	_check_nave_identity()
	_check_earlier_wings_have_no_bells()
	_check_nave_bells_are_required()
	_check_nave_watched_steps()
	_check_first_bell()
	_check_quiet_bell()
	_check_far_bell()
	_check_lit_bell()
	_check_bell_gap()
	_check_last_ring()
	_check_bell_wait_does_not_call_twice()
	_check_bell_return_calls_again()
	_check_unreachable_guard_keeps_the_rail()
	_check_bell_pulls_off_hold()
	_check_plate_still_calls_only_nearest()
	_check_snuff_still_calls_only_nearest()
	_check_lighting_still_calls_nobody()
	_check_bell_tie_reports_lower_index()


func _check_nave_identity() -> void:
	var layouts := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		var layout := "|".join(puzzle["rows"])
		var title := str(puzzle["title"])
		if str(puzzle["wing"]) == "Nave Wing":
			if layouts.has(layout):
				layout_ok = false
			if titles.has(title):
				title_ok = false
		if not layouts.has(layout):
			layouts[layout] = title
		if not titles.has(title):
			titles[title] = true
	_check(layout_ok, "each nave room has its own layout")
	_check(title_ok, "each nave room has its own name")


func _check_earlier_wings_have_no_bells() -> void:
	var clean := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Nave Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("B"):
				clean = false
		var state := Puzzles.initial_state(i)
		for y in state["h"]:
			for x in state["w"]:
				if Rules.tile_at(state, x, y) == Rules.Tile.BELL:
					clean = false
	_check(clean, "earlier wings have no bells")


func _check_nave_bells_are_required() -> void:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) != "Nave Wing":
			continue
		var state := Puzzles.initial_state(i)
		var stepped := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "move" and Rules.tile_at(state, int(state["player"]["x"]) + int(action["dx"]), int(state["player"]["y"]) + int(action["dy"])) == Rules.Tile.BELL:
				stepped = true
			var out: Dictionary = Rules.apply(state, action)
			if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
				break
			state = out["state"]
		_check(stepped, str(puzzle["title"]) + " steps onto a bell")
		var blocked := Puzzles.initial_state(i)
		for y in blocked["h"]:
			for x in blocked["w"]:
				if Rules.tile_at(blocked, x, y) == Rules.Tile.BELL:
					blocked["tiles"][y * int(blocked["w"]) + x] = Rules.Tile.WALL
		var won := false
		for action in puzzle["solution"]:
			var walled: Dictionary = Rules.apply(blocked, action)
			if walled["result"] == Rules.Result.WIN:
				won = true
				break
			if walled["result"] == Rules.Result.OK:
				blocked = walled["state"]
		_check(not won, str(puzzle["title"]) + " needs the bell")


func _check_nave_watched_steps() -> void:
	var cases := [
		["The First Bell", "D D", 1, 3],
		["The Quiet Bell", "D L D", 7, 3],
		["The Far Bell", "D", 1, 2],
		["The Lit Bell", "D D R R R R R R R R R", 10, 3],
		["The Bell Gap", "R R R R R", 6, 1],
		["The Last Ring", "R R R R R R R R D", 9, 2],
	]
	for entry in cases:
		_expect_watched_loss(str(entry[0]), str(entry[1]), int(entry[2]), int(entry[3]))


func _check_first_bell() -> void:
	var index := _index_of("The First Bell")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var bell := _find_tile(state, Rules.Tile.BELL)
	var near: Dictionary = state["guards"][0]
	var far: Dictionary = state["guards"][1]
	var near_dist := absi(int(near["x"]) - bell.x) + absi(int(near["y"]) - bell.y)
	var far_dist := absi(int(far["x"]) - bell.x) + absi(int(far["y"]) - bell.y)
	_check(near_dist < far_dist, "the first bell's nearest keeper is closer than the other")
	var saw := false
	for action in puzzle["solution"]:
		var player: Dictionary = state["player"]
		var dest := Vector2i(int(player["x"]) + int(action.get("dx", 0)), int(player["y"]) + int(action.get("dy", 0)))
		var near_before: Dictionary = state["guards"][0]
		var far_before: Dictionary = state["guards"][1]
		var out: Dictionary = Rules.apply(state, action)
		if str(action["type"]) == "move" and dest == bell:
			var near_after: Dictionary = out["state"]["guards"][0]
			var far_after: Dictionary = out["state"]["guards"][1]
			_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "stepping on the first bell calls the nearest keeper")
			_check(out["step"] == bell, "the arrow shows the square the nearest one is about to take")
			_check(bool(near_after["alert"]) and Vector2i(int(near_after["ax"]), int(near_after["ay"])) == bell, "the nearest keeper is called to the bell")
			_check(bool(far_after["alert"]) and Vector2i(int(far_after["ax"]), int(far_after["ay"])) == bell, "the farther keeper is called to the bell too")
			_check(
				int(near_after["x"]) == int(near_before["x"]) and int(near_after["y"]) == int(near_before["y"]),
				"the nearest keeper has not taken that step yet"
			)
			_check(
				int(far_after["x"]) == int(far_before["x"]) and int(far_after["y"]) == int(far_before["y"]),
				"the farther keeper has not taken that step yet"
			)
			var left: Dictionary = Rules.apply(out["state"], {"type": "move", "dx": 1, "dy": 0})
			_check(left["result"] == Rules.Result.WIN, "leaving that square wins")
			var stayed: Dictionary = Rules.apply(out["state"], {"type": "wait"})
			_check(stayed["result"] == Rules.Result.LOSS and stayed["reason"] == "guard", "staying on that square loses")
			saw = true
			break
		if out["result"] != Rules.Result.OK:
			_check(false, "first bell approach failed")
			return
		state = out["state"]
	_check(saw, "the first bell solution steps on the bell")


func _check_quiet_bell() -> void:
	var index := _index_of("The Quiet Bell")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var bell := _find_tile(state, Rules.Tile.BELL)
	var called_on_entry := false
	var waited := false
	for action in puzzle["solution"]:
		var player: Dictionary = state["player"]
		var on_bell := Rules.tile_at(state, int(player["x"]), int(player["y"])) == Rules.Tile.BELL
		var guard_before: Dictionary = state["guards"][0]
		var dest := Vector2i(int(player["x"]), int(player["y"]))
		if str(action["type"]) == "move":
			dest = Vector2i(int(player["x"]) + int(action["dx"]), int(player["y"]) + int(action["dy"]))
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "quiet bell solution failed")
			return
		if str(action["type"]) == "move" and dest == bell and int(out["called"]) >= 0:
			called_on_entry = true
		if str(action["type"]) == "wait" and on_bell:
			var guard_after: Dictionary = out["state"]["guards"][0]
			_check(called_on_entry, "the quiet bell wait is after the bell has already called")
			_check(int(out["called"]) == -1, "waiting on a bell does not call twice")
			_check(
				int(guard_after["x"]) != int(guard_before["x"]) or int(guard_after["y"]) != int(guard_before["y"]),
				"the called keeper still takes his one step while you wait"
			)
			waited = true
		state = out["state"]
	_check(waited, "the quiet bell solution waits on the bell")
	state = Puzzles.initial_state(index)
	var entries := 0
	var returned := false
	for token in ["L", "L", "L", "L", "R", "L"]:
		var action := {"type": "move", "dx": -1 if token == "L" else 1, "dy": 0}
		var player: Dictionary = state["player"]
		var dest := Vector2i(int(player["x"]) + int(action["dx"]), int(player["y"]))
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] != Rules.Result.OK:
			_check(false, "quiet bell return approach failed")
			return
		if dest == bell:
			entries += 1
			if entries == 2:
				_check(int(out["called"]) == 0, "leaving and stepping back on a bell calls again")
				returned = true
		state = out["state"]
	_check(returned, "the return route steps back onto the bell")
	var caught: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var landed: Dictionary = caught["state"]["player"]
	_check(
		caught["result"] == Rules.Result.LOSS and caught["reason"] == "guard" and int(landed["x"]) == bell.x + 1 and int(landed["y"]) == bell.y,
		"that second ring catches a route that returns"
	)


func _check_far_bell() -> void:
	var index := _index_of("The Far Bell")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var bell := _find_tile(state, Rules.Tile.BELL)
	var near: Dictionary = state["guards"][0]
	var far: Dictionary = state["guards"][1]
	var near_dist := absi(int(near["x"]) - bell.x) + absi(int(near["y"]) - bell.y)
	var far_dist := absi(int(far["x"]) - bell.x) + absi(int(far["y"]) - bell.y)
	_check(near_dist < far_dist, "the far bell's second keeper is farther from the bell")
	var called_both := false
	var far_start := Vector2i(int(far["x"]), int(far["y"]))
	for action in puzzle["solution"]:
		var player: Dictionary = state["player"]
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "far bell solution failed")
			return
		if str(action["type"]) == "move":
			var dest := Vector2i(int(player["x"]) + int(action["dx"]), int(player["y"]) + int(action["dy"]))
			if dest == bell:
				var near_after: Dictionary = out["state"]["guards"][0]
				var far_after: Dictionary = out["state"]["guards"][1]
				_check(int(out["called"]) == 0, "the bell reports the nearer keeper")
				_check(
					bool(near_after["alert"]) and Vector2i(int(near_after["ax"]), int(near_after["ay"])) == bell,
					"the nearer keeper answers the bell"
				)
				_check(
					bool(far_after["alert"]) and Vector2i(int(far_after["ax"]), int(far_after["ay"])) == bell,
					"the far keeper answers the bell"
				)
				called_both = true
		state = out["state"]
	var far_end: Dictionary = state["guards"][1]
	_check(called_both, "the far bell solution steps on the bell")
	_check(
		Vector2i(int(far_end["x"]), int(far_end["y"])) != far_start,
		"the far keeper leaves his post to answer"
	)


func _check_lit_bell() -> void:
	var index := _index_of("The Lit Bell")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var bell := _find_tile(state, Rules.Tile.BELL)
	var lit0: Dictionary = Rules.light_map(state)
	_check(lit0.has(bell) and not Rules.watched_tiles(state, lit0).has(bell), "the lit bell starts inside a lamp diamond and unwatched")
	var first: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	_check(first["result"] == Rules.Result.OK, "the square before the lit bell is dark")
	var refused: Dictionary = Rules.apply(first["state"], {"type": "move", "dx": 1, "dy": 0})
	var stayed: Dictionary = refused["state"]["player"]
	_check(
		refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "lit" and int(stayed["x"]) == 2 and int(stayed["y"]) == 1,
		"a lit bell is refused"
	)
	var snuff_called_only_near := false
	var bell_called_both := false
	state = Puzzles.initial_state(index)
	for action in puzzle["solution"]:
		var player: Dictionary = state["player"]
		var dest := Vector2i(int(player["x"]), int(player["y"]))
		if str(action["type"]) == "move":
			dest = Vector2i(int(player["x"]) + int(action["dx"]), int(player["y"]) + int(action["dy"]))
		var before_lit: Dictionary = Rules.light_map(state)
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "lit bell solution failed")
			return
		if str(action["type"]) == "toggle":
			var near: Dictionary = out["state"]["guards"][0]
			var far: Dictionary = out["state"]["guards"][1]
			_check(int(out["called"]) == 0 and bool(near["alert"]) and not bool(far["alert"]), "snuffing the lamp over the bell calls only the nearest guard")
			_check(Vector2i(int(near["ax"]), int(near["ay"])) == Vector2i(3, 2), "the snuff calls him to the lamp")
			snuff_called_only_near = true
		if str(action["type"]) == "move" and dest == bell:
			var near: Dictionary = out["state"]["guards"][0]
			var far: Dictionary = out["state"]["guards"][1]
			_check(not before_lit.has(bell), "the bell is dark when you step on it")
			_check(
				int(out["called"]) == 0 and bool(near["alert"]) and bool(far["alert"]) and Vector2i(int(near["ax"]), int(near["ay"])) == bell and Vector2i(int(far["ax"]), int(far["ay"])) == bell,
				"stepping onto the dark bell calls every guard"
			)
			bell_called_both = true
		state = out["state"]
	_check(snuff_called_only_near and bell_called_both, "the lit bell snuffs, then rings")


func _check_bell_gap() -> void:
	var index := _index_of("The Bell Gap")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 0, "the bell gap is solved without snuffing")
	var state := Puzzles.initial_state(index)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var bell := _find_tile(state, Rules.Tile.BELL)
	var called := false
	var crossed := false
	for action in puzzle["solution"]:
		var player: Dictionary = state["player"]
		var dest := Vector2i(int(player["x"]), int(player["y"]))
		if str(action["type"]) == "move":
			dest = Vector2i(int(player["x"]) + int(action["dx"]), int(player["y"]) + int(action["dy"]))
			if dest == gap:
				var lights: Dictionary = Rules.light_map(state)
				_check(
					bool(state["lamps"][0]["lit"]) and lights.has(gap) and not Rules.watched_tiles(state, lights).has(gap),
					"the bell gap stays lit and unwatched when you cross"
				)
				var south: Dictionary = state["guards"][0]
				var east: Dictionary = state["guards"][1]
				_check(
					Vector2i(int(south["x"]), int(south["y"])) != Vector2i(6, 2) and Vector2i(int(east["x"]), int(east["y"])) != Vector2i(7, 1),
					"both keepers have left the gap"
				)
				crossed = true
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "bell gap solution failed")
			return
		if dest == bell and str(action["type"]) == "move":
			var south_after: Dictionary = out["state"]["guards"][0]
			var east_after: Dictionary = out["state"]["guards"][1]
			_check(
				int(out["called"]) == 0 and bool(south_after["alert"]) and bool(east_after["alert"]) and Vector2i(int(south_after["ax"]), int(south_after["ay"])) == bell and Vector2i(int(east_after["ax"]), int(east_after["ay"])) == bell,
				"the bell pulls both keepers off the gap"
			)
			called = true
		state = out["state"]
	_check(called and crossed, "the bell gap solution steps the bell, then crosses")


func _check_last_ring() -> void:
	var index := _index_of("The Last Ring")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var bell := _find_tile(state, Rules.Tile.BELL)
	var held := false
	var crossed := false
	var hold_state: Dictionary = {}
	for action in puzzle["solution"]:
		var player: Dictionary = state["player"]
		if str(action["type"]) == "move":
			var dest := Vector2i(int(player["x"]) + int(action["dx"]), int(player["y"]) + int(action["dy"]))
			if dest == gap:
				var lights: Dictionary = Rules.light_map(state)
				var west: Dictionary = state["guards"][0]
				var east: Dictionary = state["guards"][1]
				_check(
					bool(west["holding"]) and bool(east["holding"]) and Vector2i(int(west["x"]), int(west["y"])) == bell and Vector2i(int(east["x"]), int(east["y"])) == bell,
					"both keepers are holding on the bell when you cross"
				)
				_check(
					bool(state["lamps"][0]["lit"]) and lights.has(gap) and not Rules.watched_tiles(state, lights).has(gap),
					"the last ring's gap is still lit and unwatched when you cross"
				)
				crossed = true
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "last ring solution failed")
			return
		state = out["state"]
		var west_now: Dictionary = state["guards"][0]
		var east_now: Dictionary = state["guards"][1]
		if bool(west_now["holding"]) and bool(east_now["holding"]) and not held:
			held = true
			hold_state = Rules.clone(state)
			_check(
				Vector2i(int(west_now["x"]), int(west_now["y"])) == bell and Vector2i(int(east_now["x"]), int(east_now["y"])) == bell,
				"both keepers hold on the bell"
			)
	_check(held and crossed, "the last ring solution waits until they hold, then crosses")
	for guard_index in [0, 1]:
		var released: Dictionary = Rules.clone(hold_state)
		released["guards"][guard_index]["holding"] = false
		var resumed: Vector2i = Rules.planned_step(released, guard_index)
		_check(resumed != bell, "without the hold keeper %d would resume the rail" % guard_index)
	for guard_index in [0, 1]:
		var rail: Array = hold_state["guards"][guard_index]["rail"]
		for point in rail:
			var rail_cell: Vector2i = point
			var posted: Dictionary = Rules.clone(hold_state)
			posted["guards"][guard_index]["x"] = rail_cell.x
			posted["guards"][guard_index]["y"] = rail_cell.y
			posted["guards"][guard_index]["holding"] = false
			posted["guards"][guard_index]["alert"] = false
			var lights: Dictionary = Rules.light_map(posted)
			_check(lights.has(gap) and Rules.watched_tiles(posted, lights).has(gap), "back on the rail at %s, that gap is watched" % rail_cell)


func _check_bell_wait_does_not_call_twice() -> void:
	var state := Rules.build(
		PackedStringArray(["########", "#S.B...#", "#......#", "#......#", "########"]),
		[],
		[
			{"x": 6, "y": 2, "vision": 1, "rail": [Vector2i(6, 2)]},
			{"x": 1, "y": 3, "vision": 1, "rail": [Vector2i(1, 3)]},
		]
	)
	var bell := Vector2i(3, 1)
	var stepped: Dictionary = Rules.apply(Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})["state"], {"type": "move", "dx": 1, "dy": 0})
	_check(stepped["result"] == Rules.Result.OK and int(stepped["called"]) == 0, "the first step onto the bell calls")
	_check(bool(stepped["state"]["guards"][0]["alert"]) and bool(stepped["state"]["guards"][1]["alert"]), "both keepers are called by that step")
	var waited: Dictionary = Rules.apply(stepped["state"], {"type": "wait"})
	_check(waited["result"] == Rules.Result.OK and int(waited["called"]) == -1, "waiting on a bell does not call twice")
	_check(
		Vector2i(int(waited["state"]["guards"][0]["ax"]), int(waited["state"]["guards"][0]["ay"])) == bell and Vector2i(int(waited["state"]["guards"][1]["ax"]), int(waited["state"]["guards"][1]["ay"])) == bell,
		"the first call is still the bell"
	)


func _check_bell_return_calls_again() -> void:
	var state := Rules.build(
		PackedStringArray(["########", "#S.B...#", "#......#", "#......#", "########"]),
		[],
		[
			{"x": 6, "y": 2, "vision": 1, "rail": [Vector2i(6, 2)]},
			{"x": 1, "y": 3, "vision": 1, "rail": [Vector2i(1, 3)]},
		]
	)
	var on_bell: Dictionary = Rules.apply(Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})["state"], {"type": "move", "dx": 1, "dy": 0})
	var off: Dictionary = Rules.apply(on_bell["state"], {"type": "move", "dx": -1, "dy": 0})
	_check(off["result"] == Rules.Result.OK and int(off["called"]) == -1, "leaving the bell does not ring it")
	var back: Dictionary = Rules.apply(off["state"], {"type": "move", "dx": 1, "dy": 0})
	_check(back["result"] == Rules.Result.OK and int(back["called"]) == 0, "leaving and stepping back on a bell calls again")
	_check(bool(back["state"]["guards"][0]["alert"]) and bool(back["state"]["guards"][1]["alert"]), "the second ring calls both keepers")


func _check_unreachable_guard_keeps_the_rail() -> void:
	var state := Rules.build(
		PackedStringArray(["#######", "#S.B..#", "#######", "#.....#", "#######"]),
		[],
		[
			{"x": 5, "y": 1, "vision": 1, "rail": [Vector2i(5, 1)]},
			{"x": 2, "y": 3, "vision": 1, "rail": [Vector2i(2, 3), Vector2i(4, 3)], "rail_index": 0, "rail_dir": 1},
		]
	)
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	var reachable: Dictionary = stepped["state"]["guards"][0]
	var blocked: Dictionary = stepped["state"]["guards"][1]
	_check(stepped["result"] == Rules.Result.OK and bool(reachable["alert"]) and Vector2i(int(reachable["ax"]), int(reachable["ay"])) == Vector2i(3, 1), "the keeper with a path is called")
	_check(
		not bool(blocked["alert"]) and not bool(blocked["holding"]) and Vector2i(int(blocked["x"]), int(blocked["y"])) == Vector2i(4, 3),
		"a guard with no floor path to the bell is not called"
	)
	var left: Dictionary = Rules.apply(stepped["state"], {"type": "move", "dx": -1, "dy": 0})
	var still: Dictionary = left["state"]["guards"][1]
	_check(
		left["result"] == Rules.Result.OK and not bool(still["alert"]) and not bool(still["holding"]) and Vector2i(int(still["x"]), int(still["y"])) == Vector2i(3, 3),
		"the blocked guard keeps the rail"
	)


func _check_bell_pulls_off_hold() -> void:
	var state := Rules.build(
		PackedStringArray(["#######", "#S.B..#", "#######", "#.....#", "#######"]),
		[],
		[
			{"x": 5, "y": 1, "vision": 1, "rail": [Vector2i(5, 1)]},
			{"x": 2, "y": 3, "vision": 1, "rail": [Vector2i(2, 3), Vector2i(4, 3)]},
		]
	)
	state["guards"][0]["holding"] = true
	state["guards"][0]["alert"] = false
	state["guards"][1]["holding"] = true
	state["guards"][1]["alert"] = false
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	var pulled: Dictionary = stepped["state"]["guards"][0]
	var kept: Dictionary = stepped["state"]["guards"][1]
	_check(
		stepped["result"] == Rules.Result.OK and bool(pulled["alert"]) and not bool(pulled["holding"]) and Vector2i(int(pulled["ax"]), int(pulled["ay"])) == Vector2i(3, 1) and int(pulled["x"]) == 5 and int(pulled["y"]) == 1,
		"a bell pulls a guard off an existing hold"
	)
	_check(
		bool(kept["holding"]) and not bool(kept["alert"]) and int(kept["x"]) == 2 and int(kept["y"]) == 3,
		"a guard with no path keeps his hold"
	)


func _check_plate_still_calls_only_nearest() -> void:
	var state := Rules.build(
		PackedStringArray(["########", "#S.P...#", "#......#", "#......#", "########"]),
		[],
		[
			{"x": 6, "y": 2, "vision": 1, "rail": [Vector2i(6, 2)]},
			{"x": 3, "y": 2, "vision": 1, "rail": [Vector2i(3, 2)]},
		]
	)
	var plate := Vector2i(3, 1)
	var far_dist := absi(6 - plate.x) + absi(2 - plate.y)
	var near_dist := absi(3 - plate.x) + absi(2 - plate.y)
	_check(near_dist < far_dist, "the plate fixture's second keeper is nearer")
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	var near: Dictionary = stepped["state"]["guards"][1]
	var far: Dictionary = stepped["state"]["guards"][0]
	_check(stepped["result"] == Rules.Result.OK and int(stepped["called"]) == 1 and bool(near["alert"]) and not bool(far["alert"]), "a plate still calls only the nearest guard")
	_check(Vector2i(int(near["ax"]), int(near["ay"])) == plate, "the plate call targets the plate")


func _check_snuff_still_calls_only_nearest() -> void:
	var state := Rules.build(
		PackedStringArray(["########", "#S.....#", "#......#", "#......#", "########"]),
		[{"x": 3, "y": 1, "facing": "e", "radius": 1, "lit": true}],
		[
			{"x": 6, "y": 2, "vision": 1, "rail": [Vector2i(6, 2)]},
			{"x": 3, "y": 2, "vision": 1, "rail": [Vector2i(3, 2)]},
		]
	)
	var lamp := Vector2i(3, 1)
	var far_dist := absi(6 - lamp.x) + absi(2 - lamp.y)
	var near_dist := absi(3 - lamp.x) + absi(2 - lamp.y)
	_check(near_dist < far_dist, "the snuff fixture's second keeper is closer")
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var snuffed: Dictionary = Rules.apply(stepped["state"], {"type": "toggle", "lamp": 0})
	var near: Dictionary = snuffed["state"]["guards"][1]
	var far: Dictionary = snuffed["state"]["guards"][0]
	_check(snuffed["result"] == Rules.Result.OK and int(snuffed["called"]) == 1 and bool(near["alert"]) and not bool(far["alert"]), "a snuff still calls only the nearest guard")
	_check(Vector2i(int(near["ax"]), int(near["ay"])) == lamp and not bool(snuffed["state"]["lamps"][0]["lit"]), "the snuff targets that lamp")


func _check_lighting_still_calls_nobody() -> void:
	var state := Rules.build(
		PackedStringArray(["########", "#S.....#", "#......#", "#......#", "########"]),
		[{"x": 3, "y": 1, "facing": "e", "radius": 1, "lit": false}],
		[
			{"x": 6, "y": 2, "vision": 1, "rail": [Vector2i(6, 2)]},
			{"x": 1, "y": 3, "vision": 1, "rail": [Vector2i(1, 3)]},
		]
	)
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var lit: Dictionary = Rules.apply(stepped["state"], {"type": "toggle", "lamp": 0})
	_check(
		lit["result"] == Rules.Result.OK and int(lit["called"]) == -1 and bool(lit["state"]["lamps"][0]["lit"]) and not bool(lit["state"]["guards"][0]["alert"]) and not bool(lit["state"]["guards"][1]["alert"]),
		"lighting a lamp still calls nobody"
	)


func _check_bell_tie_reports_lower_index() -> void:
	var state := Rules.build(
		PackedStringArray(["#######", "#S.B..#", "#.....#", "#######"]),
		[],
		[
			{"x": 1, "y": 2, "vision": 1, "rail": [Vector2i(1, 2)]},
			{"x": 5, "y": 2, "vision": 1, "rail": [Vector2i(5, 2)]},
		]
	)
	var bell := Vector2i(3, 1)
	var dist0 := absi(1 - bell.x) + absi(2 - bell.y)
	var dist1 := absi(5 - bell.x) + absi(2 - bell.y)
	_check(dist0 == dist1, "the bell tie keeps both keepers the same distance")
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	_check(stepped["result"] == Rules.Result.OK and int(stepped["called"]) == 0, "a distance tie on a bell reports the lower index")
	_check(
		bool(stepped["state"]["guards"][0]["alert"]) and bool(stepped["state"]["guards"][1]["alert"]),
		"a distance tie on a bell still calls both keepers"
	)


func _check_cloister_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Cloister Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_cloister_rooms() -> void:
	_check_cloister_identity()
	_check_earlier_wings_have_no_grates()
	_check_cloister_grates_are_required()
	_check_cloister_watched_steps()
	_check_first_grate()
	_check_passed_light()
	_check_dark_cut()
	_check_long_road()
	_check_lit_edge()
	_check_last_grate()
	_check_bell_still_calls_every_reachable_guard()
	_check_plate_still_calls_only_the_nearest_guard()


func _check_cloister_identity() -> void:
	var layouts := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		var layout := "|".join(puzzle["rows"])
		var title := str(puzzle["title"])
		if str(puzzle["wing"]) == "Cloister Wing":
			if layouts.has(layout):
				layout_ok = false
			if titles.has(title):
				title_ok = false
		if not layouts.has(layout):
			layouts[layout] = title
		if not titles.has(title):
			titles[title] = true
	_check(layout_ok, "each cloister room has its own layout")
	_check(title_ok, "each cloister room has its own name")


func _check_earlier_wings_have_no_grates() -> void:
	var clean := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Cloister Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("R"):
				clean = false
		var state := Puzzles.initial_state(i)
		for y in state["h"]:
			for x in state["w"]:
				if Rules.tile_at(state, x, y) == Rules.Tile.GRATE:
					clean = false
	_check(clean, "earlier wings have no grates")


func _check_cloister_grates_are_required() -> void:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) != "Cloister Wing":
			continue
		var state := Puzzles.initial_state(i)
		var stepped := false
		var called_from_grate := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "move" and Rules.tile_at(state, int(state["player"]["x"]) + int(action["dx"]), int(state["player"]["y"]) + int(action["dy"])) == Rules.Tile.GRATE:
				stepped = true
			var out: Dictionary = Rules.apply(state, action)
			if stepped and str(action["type"]) == "move" and int(out["called"]) != -1 and Rules.tile_at(out["state"], int(out["state"]["player"]["x"]), int(out["state"]["player"]["y"])) == Rules.Tile.GRATE:
				called_from_grate = true
			if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
				break
			state = out["state"]
		_check(stepped, str(puzzle["title"]) + " steps onto a grate")
		_check(not called_from_grate, str(puzzle["title"]) + " does not call a guard by stepping on a grate")
		var blocked := Puzzles.initial_state(i)
		for y in blocked["h"]:
			for x in blocked["w"]:
				if Rules.tile_at(blocked, x, y) == Rules.Tile.GRATE:
					blocked["tiles"][y * int(blocked["w"]) + x] = Rules.Tile.WALL
		var won := false
		for action in puzzle["solution"]:
			var walled: Dictionary = Rules.apply(blocked, action)
			if walled["result"] == Rules.Result.WIN:
				won = true
				break
			if walled["result"] == Rules.Result.OK:
				blocked = walled["state"]
		_check(not won, str(puzzle["title"]) + " needs the grate")


func _check_cloister_watched_steps() -> void:
	var cases := [
		["The First Grate", "R D", 3, 2],
		["The Passed Light", "U R", 2, 1],
		["The Dark Cut", "D D R", 2, 3],
		["The Long Road", "R D D D R R R R R R", 8, 4],
		["The Lit Edge", "R D D R R", 4, 3],
		["The Last Grate", "R D D R R R R R R R R", 10, 3],
	]
	for entry in cases:
		_expect_watched_loss(str(entry[0]), str(entry[1]), int(entry[2]), int(entry[3]))


func _grate_cells(state: Dictionary) -> Array:
	var cells: Array = []
	for y in state["h"]:
		for x in state["w"]:
			if Rules.tile_at(state, x, y) == Rules.Tile.GRATE:
				cells.append(Vector2i(x, y))
	return cells


func _check_first_grate() -> void:
	var index := _index_of("The First Grate")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var lamp: Dictionary = state["lamps"][0]
	var lit: Dictionary = Rules.light_map(state)
	var covered := false
	var dark_grate := true
	for cell in _grate_cells(state):
		var grate: Vector2i = cell
		if Rules.in_diamond(lamp, grate.x, grate.y):
			covered = true
			if lit.has(grate):
				dark_grate = false
		if Rules.guard_walkable(state, grate.x, grate.y):
			dark_grate = false
	_check(covered and dark_grate, "a grate under the lamp stays dark and a guard cannot enter it")
	var beside := false
	for cell in _grate_cells(state):
		var grate: Vector2i = cell
		for dir in [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]:
			var next: Vector2i = grate + dir
			if Rules.tile_at(state, next.x, next.y) == Rules.Tile.FLOOR and lit.has(next):
				beside = true
	_check(beside, "the hall beside the grate is lit")
	var entered: Dictionary = Rules.apply(state, puzzle["solution"][0])
	var stood: Dictionary = entered["state"]["player"]
	_check(
		entered["result"] == Rules.Result.OK and int(entered["called"]) == -1 and Rules.tile_at(entered["state"], int(stood["x"]), int(stood["y"])) == Rules.Tile.GRATE,
		"a grate under a lamp can be entered and calls nobody"
	)
	var waited: Dictionary = Rules.apply(entered["state"], {"type": "wait"})
	_check(waited["result"] == Rules.Result.OK and int(waited["called"]) == -1, "waiting on a grate does not call a guard")


func _check_passed_light() -> void:
	var state := Puzzles.initial_state(_index_of("The Passed Light"))
	var lamp: Dictionary = state["lamps"][0]
	var grate := _find_tile(state, Rules.Tile.GRATE)
	var door := _find_tile(state, Rules.Tile.EXIT)
	var past := grate + Vector2i(1, 0)
	var lit: Dictionary = Rules.light_map(state)
	_check(
		Rules.in_diamond(lamp, grate.x, grate.y) and not lit.has(grate) and lit.has(past) and lit.has(door),
		"a tile past the grate is still lit"
	)
	var walled := Rules.clone(state)
	walled["tiles"][grate.y * int(walled["w"]) + grate.x] = Rules.Tile.WALL
	var blocked: Dictionary = Rules.light_map(walled)
	_check(not blocked.has(past) and not blocked.has(door), "walling the grate cuts the light that was crossing it")
	var toggles := 0
	for action in Puzzles.get_puzzle(_index_of("The Passed Light"))["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 1, "the passed light snuffs the door lamp")


func _check_dark_cut() -> void:
	var index := _index_of("The Dark Cut")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	_check(lit.has(gap) and not watch.has(gap), "the lit gap beyond the grate is not in the guard's sight")
	var opened := Rules.clone(state)
	for cell in _grate_cells(state):
		var grate: Vector2i = cell
		_check(not lit.has(grate), "the dark cut's grate stays dark")
		opened["tiles"][grate.y * int(opened["w"]) + grate.x] = Rules.Tile.FLOOR
	var open_lit: Dictionary = Rules.light_map(opened)
	_check(Rules.watched_tiles(opened, open_lit).has(gap), "opening the grate lets the guard see the gap")
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 0, "the dark cut is solved without snuffing")
	var dark := Rules.clone(state)
	dark["lamps"][0]["lit"] = false
	var cursor := dark
	var refused := false
	for action in puzzle["solution"]:
		var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
		var out: Dictionary = Rules.apply(cursor, action)
		if dest == gap:
			refused = out["result"] == Rules.Result.ILLEGAL and out["reason"] == "darkgap"
			break
		if out["result"] != Rules.Result.OK:
			break
		cursor = out["state"]
	_check(refused, "the gap still has to be lit to enter")


func _check_long_road() -> void:
	var index := _index_of("The Long Road")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var grate := _find_tile(state, Rules.Tile.GRATE)
	var saw := false
	for action in puzzle["solution"]:
		if str(action["type"]) != "toggle":
			var before: Dictionary = Rules.apply(state, action)
			if before["result"] != Rules.Result.OK:
				_check(false, "long road approach failed")
				return
			state = before["state"]
			continue
		var out: Dictionary = Rules.apply(state, action)
		saw = true
		var around: Array = Rules.planned_path(out["state"], 0)
		var opened := Rules.clone(out["state"])
		opened["tiles"][grate.y * int(opened["w"]) + grate.x] = Rules.Tile.FLOOR
		var through: Array = Rules.planned_path(opened, 0)
		_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "snuffing calls the keeper onto the long road")
		_check(out["step"] == Vector2i(10, 3), "his next step starts around the grate")
		_check(not _path_has(around, grate) and _path_has(through, grate), "the grate is on the short road and off the road he can walk")
		_check(through.size() < around.size(), "the floor road around the grate is longer")
		_check(not Rules.guard_walkable(out["state"], grate.x, grate.y), "pathing treats the grate as closed")
		break
	_check(saw, "the long road solution snuffs the hall lamp")


func _check_lit_edge() -> void:
	var index := _index_of("The Lit Edge")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var grate := _find_tile(state, Rules.Tile.GRATE)
	var lamp: Dictionary = state["lamps"][0]
	var lit: Dictionary = Rules.light_map(state)
	_check(Rules.in_diamond(lamp, grate.x, grate.y) and not lit.has(grate), "the lit edge's grate is covered and stays dark")
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			break
		var stepped: Dictionary = Rules.apply(state, action)
		if stepped["result"] != Rules.Result.OK:
			_check(false, "lit edge approach failed")
			return
		state = stepped["state"]
	var stood: Dictionary = state["player"]
	_check(Rules.tile_at(state, int(stood["x"]), int(stood["y"])) == Rules.Tile.GRATE, "the grate itself is enterable")
	var edge := Vector2i(int(stood["x"]) + 1, int(stood["y"]))
	var fresh: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, fresh)
	var refused: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stayed: Dictionary = refused["state"]["player"]
	_check(
		fresh.has(edge) and not watch.has(edge) and Rules.tile_at(state, edge.x, edge.y) == Rules.Tile.FLOOR,
		"the tile beside the grate is lit and unwatched"
	)
	_check(
		refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "lit" and int(stayed["x"]) == int(stood["x"]) and int(stayed["y"]) == int(stood["y"]),
		"a lit floor tile beside a grate is still refused"
	)


func _check_last_grate() -> void:
	var index := _index_of("The Last Grate")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var grates := _grate_cells(state)
	var saw := false
	for action in puzzle["solution"]:
		if str(action["type"]) != "toggle":
			var before: Dictionary = Rules.apply(state, action)
			if before["result"] != Rules.Result.OK:
				_check(false, "last grate approach failed")
				return
			state = before["state"]
			continue
		var out: Dictionary = Rules.apply(state, action)
		saw = true
		var around: Array = Rules.planned_path(out["state"], 0)
		var opened := Rules.clone(out["state"])
		for cell in grates:
			var grate: Vector2i = cell
			opened["tiles"][grate.y * int(opened["w"]) + grate.x] = Rules.Tile.FLOOR
		var through: Array = Rules.planned_path(opened, 0)
		var avoids := true
		var uses := true
		for cell in grates:
			var grate: Vector2i = cell
			if _path_has(around, grate):
				avoids = false
			if not _path_has(through, grate):
				uses = false
		_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0 and out["step"] == Vector2i(10, 3), "the called keeper steps off the door")
		_check(avoids and uses and through.size() < around.size(), "his road treats the grates as closed and takes the longer floor")
		break
	_check(saw, "the last grate solution calls the keeper")
	state = Puzzles.initial_state(index)
	var crossed := false
	for action in puzzle["solution"]:
		var player: Dictionary = state["player"]
		var dest := Vector2i(int(player["x"]) + int(action.get("dx", 0)), int(player["y"]) + int(action.get("dy", 0)))
		if str(action["type"]) == "move" and dest == gap:
			var lights: Dictionary = Rules.light_map(state)
			var eyes: Dictionary = Rules.watched_tiles(state, lights)
			var keeper: Dictionary = state["guards"][0]
			_check(
				lights.has(gap) and not eyes.has(gap) and Vector2i(int(keeper["x"]), int(keeper["y"])) != Vector2i(10, 2),
				"the lit gap is crossed once his road has taken him off the door"
			)
			crossed = true
		var out: Dictionary = Rules.apply(state, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			break
		state = out["state"]
	_check(crossed, "the last grate solution crosses the gap")


func _check_bell_still_calls_every_reachable_guard() -> void:
	var rows := PackedStringArray(["########", "#S.B...#", "###R####", "#......#", "########"])
	var guards: Array = [
		{"x": 5, "y": 1, "vision": 2, "rail": [Vector2i(5, 1)]},
		{"x": 4, "y": 3, "vision": 2, "rail": [Vector2i(4, 3)]},
	]
	var state := Rules.build(rows, [], guards)
	var bell := _find_tile(state, Rules.Tile.BELL)
	var grate := _find_tile(state, Rules.Tile.GRATE)
	_check(Rules.bell_guards(state, bell.x, bell.y) == [0], "a grate is not a path, so the blocked keeper is not called")
	var opened := Rules.clone(state)
	opened["tiles"][grate.y * int(opened["w"]) + grate.x] = Rules.Tile.FLOOR
	_check(Rules.bell_guards(opened, bell.x, bell.y) == [0, 1], "opening the grate lets the far keeper reach the bell")
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	var near: Dictionary = stepped["state"]["guards"][0]
	var blocked: Dictionary = stepped["state"]["guards"][1]
	_check(
		stepped["result"] == Rules.Result.OK and int(stepped["called"]) == 0 and bool(near["alert"]) and not bool(blocked["alert"]),
		"a bell still calls every guard who can reach it"
	)
	_check(
		not bool(blocked["alert"]) and not bool(blocked["holding"]) and int(blocked["x"]) == 4 and int(blocked["y"]) == 3,
		"the keeper with no path is not called and keeps his post"
	)


func _check_plate_still_calls_only_the_nearest_guard() -> void:
	var rows := PackedStringArray(["########", "#S.P...#", "###R####", "#......#", "########"])
	var guards: Array = [
		{"x": 6, "y": 1, "vision": 2, "rail": [Vector2i(6, 1)]},
		{"x": 3, "y": 3, "vision": 2, "rail": [Vector2i(3, 3)]},
	]
	var state := Rules.build(rows, [], guards)
	var plate := _find_tile(state, Rules.Tile.PLATE)
	var far: Dictionary = state["guards"][0]
	var near: Dictionary = state["guards"][1]
	var far_dist := absi(int(far["x"]) - plate.x) + absi(int(far["y"]) - plate.y)
	var near_dist := absi(int(near["x"]) - plate.x) + absi(int(near["y"]) - plate.y)
	_check(near_dist < far_dist and not Rules.guard_walkable(state, 3, 2), "the nearer keeper is blocked by the grate and is still nearer")
	_check(Rules.bell_guards(state, plate.x, plate.y) == [0], "the grate keeps the nearer keeper off a floor path")
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	var far_after: Dictionary = stepped["state"]["guards"][0]
	var near_after: Dictionary = stepped["state"]["guards"][1]
	_check(
		stepped["result"] == Rules.Result.OK and int(stepped["called"]) == 1 and bool(near_after["alert"]) and not bool(far_after["alert"]),
		"a plate still calls only the nearest guard"
	)
	_check(Vector2i(int(near_after["ax"]), int(near_after["ay"])) == plate, "the plate call targets the plate")


func _check_porch_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Porch Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_porch_rooms() -> void:
	_check_porch_identity()
	_check_earlier_wings_have_no_sills()
	_check_porch_sills_are_required()
	_check_porch_watched_steps()
	_check_first_sill()
	_check_stopped_light()
	_check_seen_gap()
	_check_closed_walk()
	_check_dark_past()
	_check_last_sill()
	_check_guard_does_not_see_through_a_sill()
	_check_bell_still_calls_every_reachable_guard_past_a_sill()
	_check_plate_still_calls_only_the_nearest_guard_past_a_sill()


func _check_porch_identity() -> void:
	var layouts := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		var layout := "|".join(puzzle["rows"])
		var title := str(puzzle["title"])
		if str(puzzle["wing"]) == "Porch Wing":
			if layouts.has(layout):
				layout_ok = false
			if titles.has(title):
				title_ok = false
		if not layouts.has(layout):
			layouts[layout] = title
		if not titles.has(title):
			titles[title] = true
	_check(layout_ok, "each porch room has its own layout")
	_check(title_ok, "each porch room has its own name")


func _check_earlier_wings_have_no_sills() -> void:
	var clean := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Porch Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("I"):
				clean = false
		var state := Puzzles.initial_state(i)
		for y in state["h"]:
			for x in state["w"]:
				if Rules.tile_at(state, x, y) == Rules.Tile.SILL:
					clean = false
	_check(clean, "earlier wings have no sills")


func _check_porch_sills_are_required() -> void:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) != "Porch Wing":
			continue
		if str(puzzle["title"]) == "The Stopped Light":
			continue
		var state := Puzzles.initial_state(i)
		var stepped := false
		var called_from_sill := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "move" and Rules.tile_at(state, int(state["player"]["x"]) + int(action["dx"]), int(state["player"]["y"]) + int(action["dy"])) == Rules.Tile.SILL:
				stepped = true
			var out: Dictionary = Rules.apply(state, action)
			if stepped and str(action["type"]) == "move" and int(out["called"]) != -1 and Rules.tile_at(out["state"], int(out["state"]["player"]["x"]), int(out["state"]["player"]["y"])) == Rules.Tile.SILL:
				called_from_sill = true
			if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
				break
			state = out["state"]
		_check(stepped, str(puzzle["title"]) + " steps onto a sill")
		_check(not called_from_sill, str(puzzle["title"]) + " does not call a guard by stepping on a sill")
		var blocked := Puzzles.initial_state(i)
		for y in blocked["h"]:
			for x in blocked["w"]:
				if Rules.tile_at(blocked, x, y) == Rules.Tile.SILL:
					blocked["tiles"][y * int(blocked["w"]) + x] = Rules.Tile.WALL
		var won := false
		for action in puzzle["solution"]:
			var walled: Dictionary = Rules.apply(blocked, action)
			if walled["result"] == Rules.Result.WIN:
				won = true
				break
			if walled["result"] == Rules.Result.OK:
				blocked = walled["state"]
		_check(not won, str(puzzle["title"]) + " needs the sill")


func _check_porch_watched_steps() -> void:
	var cases := [
		["The First Sill", "D D", 1, 3],
		["The Stopped Light", "D D D R R R R R R R", 8, 4],
		["The Seen Gap", "D D", 1, 5],
		["The Closed Walk", "R D D D R R R R R R", 8, 4],
		["The Dark Past", "D", 1, 2],
		["The Last Sill", "D", 1, 2],
	]
	for entry in cases:
		var title := str(entry[0])
		var state := Puzzles.initial_state(_index_of(title))
		_check(Rules.tile_at(state, int(entry[2]), int(entry[3])) == Rules.Tile.SILL, title + " loses on a sill")
		_expect_watched_loss(title, str(entry[1]), int(entry[2]), int(entry[3]))


func _check_first_sill() -> void:
	var index := _index_of("The First Sill")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var lamp: Dictionary = state["lamps"][0]
	var sill := Vector2i(4, 1)
	var past := Vector2i(5, 1)
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	_check(
		Rules.in_diamond(lamp, sill.x, sill.y) and lit.has(sill) and not watch.has(sill) and not Rules.guard_walkable(state, sill.x, sill.y),
		"a sill under a lamp is lit, refused, and closed to a guard"
	)
	_check(Rules.in_diamond(lamp, past.x, past.y) and not lit.has(past), "the tile past the first sill was already dark")
	var stood := Rules.clone(state)
	stood["player"]["x"] = past.x
	stood["player"]["y"] = past.y
	var refused: Dictionary = Rules.apply(stood, {"type": "move", "dx": -1, "dy": 0})
	var stayed: Dictionary = refused["state"]["player"]
	_check(
		refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "lit" and int(stayed["x"]) == past.x and int(stayed["y"]) == past.y,
		"a lit sill under a lamp is refused"
	)
	var visited := false
	var cursor := state
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == past:
				visited = not Rules.light_map(Puzzles.initial_state(index)).has(past)
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "first sill solution failed")
			return
		cursor = out["state"]
	_check(visited, "the first sill solution crosses the tile that started dark")


func _check_stopped_light() -> void:
	var index := _index_of("The Stopped Light")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var lamp: Dictionary = state["lamps"][0]
	var sill := Vector2i(4, 2)
	var door := Vector2i(4, 1)
	var lit: Dictionary = Rules.light_map(state)
	_check(
		Rules.tile_at(state, sill.x, sill.y) == Rules.Tile.SILL and lit.has(sill) and Rules.in_diamond(lamp, door.x, door.y) and not lit.has(door),
		"light stops at the sill, so the door beyond stays dark"
	)
	var grated := Rules.clone(state)
	grated["tiles"][sill.y * int(grated["w"]) + sill.x] = Rules.Tile.GRATE
	var passed: Dictionary = Rules.light_map(grated)
	_check(passed.has(door) and not passed.has(sill), "a grate in that cell would light the door")
	var cursor := grated
	var stopped := false
	for action in puzzle["solution"]:
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] == Rules.Result.ILLEGAL and str(out["reason"]) == "lit":
			stopped = true
			break
		if out["result"] != Rules.Result.OK:
			break
		cursor = out["state"]
	_check(stopped, "the stopped light solution needs the sill, because a grate lights the door")
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 0, "the stopped light is solved without snuffing")


func _check_seen_gap() -> void:
	var index := _index_of("The Seen Gap")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var gap := Vector2i(6, 3)
	var sill := Vector2i(7, 3)
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	_check(
		Rules.tile_at(state, gap.x, gap.y) == Rules.Tile.GAP and lit.has(gap) and watch.has(gap) and Rules.tile_at(state, sill.x, sill.y) == Rules.Tile.SILL,
		"the sill does not hide the lit gap beside it"
	)
	var crossed := false
	var cursor := state
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == sill:
				var now: Dictionary = Rules.light_map(cursor)
				crossed = not now.has(sill) and now.has(gap)
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "seen gap solution failed")
			return
		cursor = out["state"]
	_check(crossed, "the seen gap stays lit while the sill beside it is crossed")


func _check_closed_walk() -> void:
	var index := _index_of("The Closed Walk")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var sill := Vector2i(6, 1)
	var saw := false
	for action in puzzle["solution"]:
		if str(action["type"]) != "toggle":
			var before: Dictionary = Rules.apply(state, action)
			if before["result"] != Rules.Result.OK:
				_check(false, "closed walk approach failed")
				return
			state = before["state"]
			continue
		var out: Dictionary = Rules.apply(state, action)
		saw = true
		var around: Array = Rules.planned_path(out["state"], 0)
		var opened := Rules.clone(out["state"])
		for y in opened["h"]:
			for x in opened["w"]:
				if Rules.tile_at(opened, x, y) == Rules.Tile.SILL:
					opened["tiles"][y * int(opened["w"]) + x] = Rules.Tile.FLOOR
		var through: Array = Rules.planned_path(opened, 0)
		_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "snuffing calls the keeper onto the closed walk")
		_check(out["step"] == Vector2i(10, 3), "his next step starts around the sill")
		_check(not _path_has(around, sill) and _path_has(through, sill), "the sill is on the short road and off the road he can walk")
		_check(through.size() < around.size(), "the floor road around the sill is longer")
		_check(not Rules.guard_walkable(out["state"], sill.x, sill.y), "pathing treats the sill as closed")
		break
	_check(saw, "the closed walk solution snuffs the hall lamp")


func _check_dark_past() -> void:
	var index := _index_of("The Dark Past")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var lamp: Dictionary = state["lamps"][0]
	var sill := Vector2i(4, 1)
	var past := Vector2i(5, 1)
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	_check(
		lit.has(sill) and not watch.has(sill) and Rules.in_diamond(lamp, past.x, past.y) and not lit.has(past),
		"the tile past the sill stays dark even under the lamp's reach"
	)
	var stood := Rules.clone(state)
	stood["player"]["x"] = 3
	stood["player"]["y"] = 1
	var refused: Dictionary = Rules.apply(stood, {"type": "move", "dx": 1, "dy": 0})
	_check(refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "lit", "the dark past's lit sill is refused until it is snuffed")
	var visited := false
	var cursor := state
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == past:
				visited = true
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "dark past solution failed")
			return
		cursor = out["state"]
	_check(visited and Rules.is_win(cursor), "the dark past solution enters the tile the lamp could not light")


func _check_last_sill() -> void:
	var index := _index_of("The Last Sill")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var lamp: Dictionary = state["lamps"][0]
	var sill := Vector2i(4, 1)
	var past := Vector2i(5, 1)
	var door := Vector2i(6, 1)
	var lit: Dictionary = Rules.light_map(state)
	_check(
		lit.has(sill) and Rules.in_diamond(lamp, past.x, past.y) and not lit.has(past) and Rules.in_diamond(lamp, door.x, door.y) and not lit.has(door),
		"the last door stays dark because the light stopped at the sill"
	)
	var grated := Rules.clone(state)
	grated["tiles"][sill.y * int(grated["w"]) + sill.x] = Rules.Tile.GRATE
	var passed: Dictionary = Rules.light_map(grated)
	_check(passed.has(door) and not passed.has(sill), "a grate in the last sill's place would light the door")
	var crossed := false
	var cursor := state
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var player: Dictionary = cursor["player"]
			var dest := Vector2i(int(player["x"]) + int(action["dx"]), int(player["y"]) + int(action["dy"]))
			if dest == sill:
				var now: Dictionary = Rules.light_map(cursor)
				var out: Dictionary = Rules.apply(cursor, action)
				crossed = not now.has(sill) and out["result"] == Rules.Result.OK and int(out["called"]) == -1
				cursor = out["state"]
				continue
		var stepped: Dictionary = Rules.apply(cursor, action)
		if stepped["result"] != Rules.Result.OK and stepped["result"] != Rules.Result.WIN:
			_check(false, "last sill solution failed")
			return
		cursor = stepped["state"]
	_check(crossed and Rules.is_win(cursor), "a snuffed sill can be crossed once it is dark")


func _check_guard_does_not_see_through_a_sill() -> void:
	var rows := PackedStringArray(["#######", "###.###", "###.###", "###I###", "###.###", "#######"])
	var lamps: Array = [
		{"x": 3, "y": 1, "facing": "s", "radius": 3, "lit": true},
		{"x": 3, "y": 4, "facing": "n", "radius": 1, "lit": true},
	]
	var guards: Array = [{"x": 3, "y": 1, "vision": 4, "rail": [Vector2i(3, 1)]}]
	var state := Rules.build(rows, lamps, guards)
	var sill := Vector2i(3, 3)
	var past := Vector2i(3, 4)
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	_check(
		Rules.tile_at(state, sill.x, sill.y) == Rules.Tile.SILL and lit.has(sill) and watch.has(sill) and lit.has(past) and not watch.has(past),
		"a guard does not see through a lit sill"
	)
	var opened := Rules.clone(state)
	opened["tiles"][sill.y * int(opened["w"]) + sill.x] = Rules.Tile.FLOOR
	var open_lit: Dictionary = Rules.light_map(opened)
	_check(Rules.watched_tiles(opened, open_lit).has(past), "opening the sill lets the guard see the lit tile past it")


func _check_bell_still_calls_every_reachable_guard_past_a_sill() -> void:
	var rows := PackedStringArray(["########", "#S.B...#", "###I####", "#......#", "########"])
	var guards: Array = [
		{"x": 5, "y": 1, "vision": 2, "rail": [Vector2i(5, 1)]},
		{"x": 4, "y": 3, "vision": 2, "rail": [Vector2i(4, 3)]},
	]
	var state := Rules.build(rows, [], guards)
	var bell := _find_tile(state, Rules.Tile.BELL)
	var sill := _find_tile(state, Rules.Tile.SILL)
	_check(Rules.bell_guards(state, bell.x, bell.y) == [0], "a sill is not a path, so the blocked keeper is not called")
	var opened := Rules.clone(state)
	opened["tiles"][sill.y * int(opened["w"]) + sill.x] = Rules.Tile.FLOOR
	_check(Rules.bell_guards(opened, bell.x, bell.y) == [0, 1], "opening the sill lets the far keeper reach the bell")
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	var near: Dictionary = stepped["state"]["guards"][0]
	var blocked: Dictionary = stepped["state"]["guards"][1]
	_check(
		stepped["result"] == Rules.Result.OK and int(stepped["called"]) == 0 and bool(near["alert"]) and not bool(blocked["alert"]),
		"a bell still calls every guard who can reach it past a sill"
	)
	_check(
		not bool(blocked["alert"]) and not bool(blocked["holding"]) and int(blocked["x"]) == 4 and int(blocked["y"]) == 3,
		"the keeper blocked by a sill is not called and keeps his post"
	)


func _check_plate_still_calls_only_the_nearest_guard_past_a_sill() -> void:
	var rows := PackedStringArray(["########", "#S.P...#", "###I####", "#......#", "########"])
	var guards: Array = [
		{"x": 6, "y": 1, "vision": 2, "rail": [Vector2i(6, 1)]},
		{"x": 3, "y": 3, "vision": 2, "rail": [Vector2i(3, 3)]},
	]
	var state := Rules.build(rows, [], guards)
	var plate := _find_tile(state, Rules.Tile.PLATE)
	var far: Dictionary = state["guards"][0]
	var near: Dictionary = state["guards"][1]
	var far_dist := absi(int(far["x"]) - plate.x) + absi(int(far["y"]) - plate.y)
	var near_dist := absi(int(near["x"]) - plate.x) + absi(int(near["y"]) - plate.y)
	_check(near_dist < far_dist and not Rules.guard_walkable(state, 3, 2), "the nearer keeper is blocked by the sill and is still nearer")
	_check(Rules.bell_guards(state, plate.x, plate.y) == [0], "the sill keeps the nearer keeper off a floor path")
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	var far_after: Dictionary = stepped["state"]["guards"][0]
	var near_after: Dictionary = stepped["state"]["guards"][1]
	_check(
		stepped["result"] == Rules.Result.OK and int(stepped["called"]) == 1 and bool(near_after["alert"]) and not bool(far_after["alert"]),
		"a plate still calls only the nearest guard past a sill"
	)
	_check(Vector2i(int(near_after["ax"]), int(near_after["ay"])) == plate, "the plate call past a sill targets the plate")


func _with_tile(state: Dictionary, x: int, y: int, kind: int) -> Dictionary:
	var copy := Rules.clone(state)
	copy["tiles"][y * int(copy["w"]) + x] = kind
	return copy


func _spec_result(state: Dictionary, spec: String) -> String:
	var cursor := Rules.clone(state)
	for action in Puzzles.parse_solution(spec):
		var before: Dictionary = cursor["player"]
		if str(action["type"]) == "move" and Rules.tile_at(cursor, int(before["x"]) + int(action["dx"]), int(before["y"]) + int(action["dy"])) == Rules.Tile.PANE:
			return "pane"
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] == Rules.Result.WIN:
			return "win"
		if out["result"] != Rules.Result.OK:
			return str(out["reason"])
		cursor = out["state"]
	return "stop"


func _before_last(state: Dictionary, spec: String) -> Dictionary:
	var cursor := Rules.clone(state)
	var actions: Array = Puzzles.parse_solution(spec)
	if actions.is_empty():
		return {}
	for i in actions.size() - 1:
		var out: Dictionary = Rules.apply(cursor, actions[i])
		if out["result"] != Rules.Result.OK:
			return {}
		cursor = out["state"]
	return cursor


func _check_oriel_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Oriel Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_oriel_rooms() -> void:
	_check_oriel_identity()
	_check_earlier_wings_have_no_panes()
	_check_oriel_panes_are_closed_glass()
	_check_oriel_watched_steps()
	_check_first_pane()
	_check_seen_room()
	_check_closed_sheet()
	_check_dark_beside()
	_check_long_sight()
	_check_last_pane()
	_check_guard_sees_through_a_pane()
	_check_bell_still_calls_every_reachable_guard_past_a_pane()
	_check_plate_still_calls_only_the_nearest_guard_past_a_pane()
	_check_a_pane_calls_nobody()


func _check_oriel_identity() -> void:
	var layouts := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		var layout := "|".join(puzzle["rows"])
		var title := str(puzzle["title"])
		if str(puzzle["wing"]) == "Oriel Wing":
			if layouts.has(layout):
				layout_ok = false
			if titles.has(title):
				title_ok = false
		if not layouts.has(layout):
			layouts[layout] = title
		if not titles.has(title):
			titles[title] = true
	_check(layout_ok, "each oriel room has its own layout")
	_check(title_ok, "each oriel room has its own name")


func _check_earlier_wings_have_no_panes() -> void:
	var clean := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Oriel Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("A"):
				clean = false
		var state := Puzzles.initial_state(i)
		for y in state["h"]:
			for x in state["w"]:
				if Rules.tile_at(state, x, y) == Rules.Tile.PANE:
					clean = false
	_check(clean, "earlier wings have no panes")


func _check_oriel_panes_are_closed_glass() -> void:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) != "Oriel Wing":
			continue
		var state := Puzzles.initial_state(i)
		var pane := _find_tile(state, Rules.Tile.PANE)
		var lit: Dictionary = Rules.light_map(state)
		var watch: Dictionary = Rules.watched_tiles(state, lit)
		_check(pane.x >= 0, str(puzzle["title"]) + " has a pane")
		_check(not lit.has(pane) and not watch.has(pane), str(puzzle["title"]) + " leaves the pane unlit")
		_check(not Rules.guard_walkable(state, pane.x, pane.y), str(puzzle["title"]) + " closes the pane to a guard")
		_check(_spec_result(state, _solution_spec(puzzle)) == "win", str(puzzle["title"]) + " wins without stepping on the pane")


func _solution_spec(puzzle: Dictionary) -> String:
	var tokens: PackedStringArray = PackedStringArray()
	for action in puzzle["solution"]:
		match str(action["type"]):
			"move":
				if int(action["dx"]) == 1:
					tokens.append("R")
				elif int(action["dx"]) == -1:
					tokens.append("L")
				elif int(action["dy"]) == -1:
					tokens.append("U")
				else:
					tokens.append("D")
			"wait":
				tokens.append("W")
			"toggle":
				tokens.append("T%d" % int(action["lamp"]))
	return " ".join(tokens)


func _check_oriel_watched_steps() -> void:
	var cases := [
		["The First Pane", "D D D R R R R R R R", 8, 4],
		["The Seen Room", "D D D R R R R U U U L", 5, 2],
		["The Closed Sheet", "D D D R R R R U", 5, 3],
		["The Dark Beside", "D D D R R R R R R U U U", 8, 2],
		["The Long Sight", "U", 4, 4],
		["The Last Pane", "R R R", 4, 1],
	]
	for entry in cases:
		_expect_watched_loss(str(entry[0]), str(entry[1]), int(entry[2]), int(entry[3]))


func _check_first_pane() -> void:
	var index := _index_of("The First Pane")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var pane := Vector2i(4, 2)
	var gap := Vector2i(4, 1)
	var lit: Dictionary = Rules.light_map(state)
	_check(
		Rules.tile_at(state, pane.x, pane.y) == Rules.Tile.PANE and lit.has(gap) and not lit.has(pane),
		"the first pane lets the lamp light the gap beyond it"
	)
	_check(not Rules.light_map(_with_tile(state, pane.x, pane.y, Rules.Tile.WALL)).has(gap), "a wall in the first pane leaves the gap dark")
	_check(not Rules.light_map(_with_tile(state, pane.x, pane.y, Rules.Tile.SILL)).has(gap), "a sill in the first pane leaves the gap dark")
	var spec := _solution_spec(puzzle)
	_check(_spec_result(_with_tile(state, pane.x, pane.y, Rules.Tile.WALL), spec) == "darkgap", "a wall in the first pane stops the solution on a dark gap")
	_check(_spec_result(_with_tile(state, pane.x, pane.y, Rules.Tile.SILL), spec) == "darkgap", "a sill in the first pane stops the solution on a dark gap")
	_check(_spec_result(_with_tile(state, pane.x, pane.y, Rules.Tile.GRATE), spec) == "win", "a grate in the first pane still clears the solution")
	var stood := Rules.clone(state)
	stood["player"]["x"] = 4
	stood["player"]["y"] = 3
	var refused: Dictionary = Rules.apply(stood, {"type": "move", "dx": 0, "dy": -1})
	_check(refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "pane", "you cannot step on the first pane")
	var crossed := false
	var cursor := state
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == gap:
				crossed = Rules.light_map(cursor).has(gap)
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "first pane solution failed")
			return
		cursor = out["state"]
	_check(crossed and Rules.is_win(cursor), "the first pane solution leaves by the gap the pane left lit")


func _check_seen_room() -> void:
	var index := _index_of("The Seen Room")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var pane := Vector2i(4, 2)
	var beyond := Vector2i(5, 2)
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	_check(lit.has(beyond) and watch.has(beyond) and not lit.has(pane), "the guard sees the lit floor beyond the pane")
	var grated := _with_tile(state, pane.x, pane.y, Rules.Tile.GRATE)
	var grate_lit: Dictionary = Rules.light_map(grated)
	_check(grate_lit.has(beyond) and not Rules.watched_tiles(grated, grate_lit).has(beyond), "a grate in the seen room hides the floor beyond the pane")
	var silled := _with_tile(state, pane.x, pane.y, Rules.Tile.SILL)
	_check(not Rules.light_map(silled).has(beyond), "a sill in the seen room leaves the floor beyond dark")
	var spec := _solution_spec(puzzle)
	_check(_spec_result(state, spec) == "win", "the seen room snuffs, then crosses the floor the pane had left lit")
	_check(_spec_result(_with_tile(state, pane.x, pane.y, Rules.Tile.WALL), spec) == "win", "a wall in the seen room still clears the snuffed crossing")
	_check(_spec_result(silled, spec) == "win", "a sill in the seen room still clears the snuffed crossing")
	_check(_spec_result(grated, spec) == "win", "a grate in the seen room still clears the snuffed crossing")
	var early := "D D D R R R R U U U L"
	var grate_ready := _before_last(grated, early)
	var grate_now: Dictionary = Rules.light_map(grate_ready)
	_check(
		not grate_ready.is_empty() and grate_now.has(beyond) and not Rules.watched_tiles(grate_ready, grate_now).has(beyond),
		"the grate leaves that floor lit and unwatched"
	)
	var grate_step: Dictionary = Rules.apply(grate_ready, {"type": "move", "dx": -1, "dy": 0})
	var grate_stay: Dictionary = grate_step["state"]["player"]
	_check(
		grate_step["result"] == Rules.Result.ILLEGAL and grate_step["reason"] == "lit" and int(grate_stay["x"]) == 6 and int(grate_stay["y"]) == 2,
		"a grate hides the watched step by refusing the still-lit floor"
	)
	var sill_ready := _before_last(silled, early)
	var sill_step: Dictionary = Rules.apply(sill_ready, {"type": "move", "dx": -1, "dy": 0})
	var sill_land: Dictionary = sill_step["state"]["player"]
	_check(
		not Rules.light_map(sill_ready).has(beyond) and sill_step["result"] == Rules.Result.OK and int(sill_land["x"]) == beyond.x and int(sill_land["y"]) == beyond.y,
		"a sill hides that step because the floor beyond stays dark"
	)
	var wall_ready := _before_last(_with_tile(state, pane.x, pane.y, Rules.Tile.WALL), early)
	var wall_step: Dictionary = Rules.apply(wall_ready, {"type": "move", "dx": -1, "dy": 0})
	_check(wall_step["result"] == Rules.Result.OK and not Rules.light_map(wall_ready).has(beyond), "a wall hides that step because the floor beyond stays dark")
	var stood := Rules.clone(state)
	stood["player"]["x"] = beyond.x
	stood["player"]["y"] = beyond.y
	var refused: Dictionary = Rules.apply(stood, {"type": "move", "dx": -1, "dy": 0})
	_check(refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "pane", "you cannot cross the pane in the seen room")


func _check_closed_sheet() -> void:
	var index := _index_of("The Closed Sheet")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var pane := Vector2i(4, 2)
	var gap := Vector2i(4, 1)
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(gap) and not lit.has(pane), "light still passes the pane in the closed sheet")
	_check(not Rules.light_map(_with_tile(state, pane.x, pane.y, Rules.Tile.WALL)).has(gap), "a wall in the closed sheet leaves the gap dark")
	_check(not Rules.light_map(_with_tile(state, pane.x, pane.y, Rules.Tile.SILL)).has(gap), "a sill in the closed sheet leaves the gap dark")
	var spec := _solution_spec(puzzle)
	var saw := false
	var cursor := state
	for action in puzzle["solution"]:
		var out: Dictionary = Rules.apply(cursor, action)
		if str(action["type"]) != "toggle":
			if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
				_check(false, "closed sheet approach failed")
				return
			cursor = out["state"]
			continue
		saw = true
		var around: Array = Rules.planned_path(out["state"], 0)
		var opened := _with_tile(out["state"], pane.x, pane.y, Rules.Tile.FLOOR)
		var through: Array = Rules.planned_path(opened, 0)
		_check(out["result"] == Rules.Result.OK and int(out["called"]) == 0, "snuffing calls the keeper onto the closed sheet")
		_check(out["step"] == Vector2i(5, 3), "his next step starts around the pane")
		_check(not _path_has(around, pane) and _path_has(through, pane), "the pane is on the short road and off the road he can walk")
		_check(through.size() < around.size(), "the floor road around the pane is longer")
		_check(not Rules.guard_walkable(out["state"], pane.x, pane.y), "pathing treats the pane as closed")
		break
	_check(saw, "the closed sheet solution snuffs the hall lamp")
	_check(_spec_result(state, spec) == "win", "you cross before the long-road keeper arrives")
	_check(_spec_result(_with_tile(state, pane.x, pane.y, Rules.Tile.WALL), spec) == "darkgap", "a wall in the closed sheet stops the solution on a dark gap")
	_check(_spec_result(_with_tile(state, pane.x, pane.y, Rules.Tile.SILL), spec) == "darkgap", "a sill in the closed sheet stops the solution on a dark gap")
	_check(_spec_result(_with_tile(state, pane.x, pane.y, Rules.Tile.GRATE), spec) == "win", "a grate in the closed sheet still clears the solution")
	_check(_spec_result(_with_tile(state, pane.x, pane.y, Rules.Tile.FLOOR), spec) == "guard", "opening the pane to floor lets the keeper catch you")


func _check_dark_beside() -> void:
	var index := _index_of("The Dark Beside")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var pane := Vector2i(3, 3)
	var beside := Vector2i(2, 3)
	var gap := Vector2i(3, 4)
	var lit: Dictionary = Rules.light_map(state)
	_check(not lit.has(beside) and lit.has(gap) and not lit.has(pane), "the tile beside the pane stays dark and the tile past it is lit")
	_check(not Rules.light_map(_with_tile(state, pane.x, pane.y, Rules.Tile.SILL)).has(gap), "a sill in the dark beside leaves the far tile dark")
	_check(not Rules.light_map(_with_tile(state, pane.x, pane.y, Rules.Tile.WALL)).has(gap), "a wall in the dark beside leaves the far tile dark")
	var spec := _solution_spec(puzzle)
	_check(_spec_result(_with_tile(state, pane.x, pane.y, Rules.Tile.WALL), spec) == "darkgap", "a wall in the dark beside stops the solution on a dark gap")
	_check(_spec_result(_with_tile(state, pane.x, pane.y, Rules.Tile.SILL), spec) == "darkgap", "a sill in the dark beside stops the solution on a dark gap")
	_check(_spec_result(_with_tile(state, pane.x, pane.y, Rules.Tile.GRATE), spec) == "win", "a grate in the dark beside still clears the solution")
	var entered := false
	var cursor := state
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == beside:
				entered = not Rules.light_map(cursor).has(beside)
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "dark beside solution failed")
			return
		cursor = out["state"]
	_check(entered and Rules.is_win(cursor), "the dark beside solution enters the unlit tile beside the pane")
	var stood := Rules.clone(state)
	stood["player"]["x"] = beside.x
	stood["player"]["y"] = beside.y
	var refused: Dictionary = Rules.apply(stood, {"type": "move", "dx": 1, "dy": 0})
	_check(refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "pane", "the pane itself cannot be entered")


func _check_long_sight() -> void:
	var index := _index_of("The Long Sight")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var pane := Vector2i(4, 2)
	var gap := Vector2i(4, 1)
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	_check(lit.has(gap) and watch.has(gap) and not lit.has(pane), "the guard sees through the pane onto the lit gap")
	_check(not Rules.light_map(_with_tile(state, pane.x, pane.y, Rules.Tile.WALL)).has(gap), "a wall in the long sight leaves the gap dark")
	_check(not Rules.light_map(_with_tile(state, pane.x, pane.y, Rules.Tile.SILL)).has(gap), "a sill in the long sight leaves the gap dark")
	var spec := _solution_spec(puzzle)
	_check(_spec_result(state, spec) == "win", "the long sight snuffs, lights the second lamp, and crosses")
	_check(_spec_result(_with_tile(state, pane.x, pane.y, Rules.Tile.WALL), spec) == "darkgap", "a wall in the long sight stops the solution on a dark gap")
	_check(_spec_result(_with_tile(state, pane.x, pane.y, Rules.Tile.SILL), spec) == "darkgap", "a sill in the long sight stops the solution on a dark gap")
	_check(_spec_result(_with_tile(state, pane.x, pane.y, Rules.Tile.GRATE), spec) == "win", "a grate in the long sight still clears the solution")
	_check(_spec_result(state, "T0 L U U U U R") == "darkgap", "after the snuff the gap is dark and cannot be entered")
	var second := Rules.clone(state)
	second["lamps"][0]["lit"] = false
	second["lamps"][1]["lit"] = true
	_check(Rules.light_map(second).has(gap), "the second lamp lights the gap through the pane")
	_check(not Rules.light_map(_with_tile(second, pane.x, pane.y, Rules.Tile.WALL)).has(gap), "a wall blocks the second lamp as well")
	_check(not Rules.light_map(_with_tile(second, pane.x, pane.y, Rules.Tile.SILL)).has(gap), "a sill blocks the second lamp as well")
	var crossed := false
	var cursor := state
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == gap:
				var now: Dictionary = Rules.light_map(cursor)
				crossed = now.has(gap) and not Rules.watched_tiles(cursor, now).has(gap) and bool(cursor["lamps"][1]["lit"]) and not bool(cursor["lamps"][0]["lit"])
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "long sight solution failed")
			return
		cursor = out["state"]
	_check(crossed and Rules.is_win(cursor), "the long sight crosses the gap after the second lamp lights it")


func _check_last_pane() -> void:
	var index := _index_of("The Last Pane")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var pane := Vector2i(4, 2)
	var gap := Vector2i(4, 1)
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	_check(lit.has(gap) and watch.has(gap) and not lit.has(pane), "the last pane leaves its gap lit and watched")
	_check(not Rules.light_map(_with_tile(state, pane.x, pane.y, Rules.Tile.SILL)).has(gap), "a sill in the last pane leaves the gap dark")
	_check(not Rules.light_map(_with_tile(state, pane.x, pane.y, Rules.Tile.WALL)).has(gap), "a wall in the last pane leaves the gap dark")
	var spec := _solution_spec(puzzle)
	_check(_spec_result(_with_tile(state, pane.x, pane.y, Rules.Tile.WALL), spec) == "darkgap", "a wall in the last pane stops the solution on a dark gap")
	_check(_spec_result(_with_tile(state, pane.x, pane.y, Rules.Tile.SILL), spec) == "darkgap", "a sill in the last pane stops the solution on a dark gap")
	_check(_spec_result(_with_tile(state, pane.x, pane.y, Rules.Tile.GRATE), spec) == "win", "a grate in the last pane still clears the solution")
	var early := "R R R"
	var grate_ready := _before_last(_with_tile(state, pane.x, pane.y, Rules.Tile.GRATE), early)
	var grate_lit: Dictionary = Rules.light_map(grate_ready)
	var grate_step: Dictionary = Rules.apply(grate_ready, {"type": "move", "dx": 1, "dy": 0})
	var grate_land: Dictionary = grate_step["state"]["player"]
	_check(
		grate_lit.has(gap) and not Rules.watched_tiles(grate_ready, grate_lit).has(gap) and grate_step["result"] == Rules.Result.OK and int(grate_land["x"]) == gap.x and int(grate_land["y"]) == gap.y,
		"a grate hides the watched step, so the early crossing is not a loss"
	)
	_check(_spec_result(_with_tile(state, pane.x, pane.y, Rules.Tile.WALL), early) == "darkgap", "a wall makes the early crossing a dark gap")
	_check(_spec_result(_with_tile(state, pane.x, pane.y, Rules.Tile.SILL), early) == "darkgap", "a sill makes the early crossing a dark gap")
	var crossed := false
	var cursor := state
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var player: Dictionary = cursor["player"]
			var dest := Vector2i(int(player["x"]) + int(action["dx"]), int(player["y"]) + int(action["dy"]))
			if dest == gap:
				var now: Dictionary = Rules.light_map(cursor)
				crossed = now.has(gap) and not Rules.watched_tiles(cursor, now).has(gap) and bool(cursor["lamps"][0]["lit"])
			if dest == pane:
				crossed = false
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "last pane solution failed")
			return
		cursor = out["state"]
	_check(crossed and Rules.is_win(cursor), "the last pane solution leaves by the gap the pane left lit")


func _check_guard_sees_through_a_pane() -> void:
	var rows := PackedStringArray(["#######", "###.###", "###.###", "###A###", "###.###", "#######"])
	var lamps: Array = [{"x": 3, "y": 1, "facing": "s", "radius": 3, "lit": true}]
	var guards: Array = [{"x": 3, "y": 1, "vision": 4, "rail": [Vector2i(3, 1)]}]
	var state := Rules.build(rows, lamps, guards)
	var pane := Vector2i(3, 3)
	var past := Vector2i(3, 4)
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	_check(
		Rules.tile_at(state, pane.x, pane.y) == Rules.Tile.PANE and not lit.has(pane) and lit.has(past) and watch.has(past),
		"a guard sees the lit tile beyond a pane"
	)
	var walled := _with_tile(state, pane.x, pane.y, Rules.Tile.WALL)
	var wall_lit: Dictionary = Rules.light_map(walled)
	_check(not wall_lit.has(past) and not Rules.watched_tiles(walled, wall_lit).has(past), "a wall blocks both the light and the sight")
	var silled := _with_tile(state, pane.x, pane.y, Rules.Tile.SILL)
	var sill_lit: Dictionary = Rules.light_map(silled)
	_check(sill_lit.has(pane) and not sill_lit.has(past) and not Rules.watched_tiles(silled, sill_lit).has(past), "a sill stops both the light and the sight")
	var grated := _with_tile(state, pane.x, pane.y, Rules.Tile.GRATE)
	var grate_lit: Dictionary = Rules.light_map(grated)
	_check(
		grate_lit.has(past) and not grate_lit.has(pane) and not Rules.watched_tiles(grated, grate_lit).has(past),
		"a grate lets the light through and blocks sight because it is dark"
	)


func _check_bell_still_calls_every_reachable_guard_past_a_pane() -> void:
	var rows := PackedStringArray(["########", "#S.B...#", "###A####", "#......#", "########"])
	var guards: Array = [
		{"x": 5, "y": 1, "vision": 2, "rail": [Vector2i(5, 1)]},
		{"x": 4, "y": 3, "vision": 2, "rail": [Vector2i(4, 3)]},
	]
	var state := Rules.build(rows, [], guards)
	var bell := _find_tile(state, Rules.Tile.BELL)
	var pane := _find_tile(state, Rules.Tile.PANE)
	_check(Rules.bell_guards(state, bell.x, bell.y) == [0], "a pane is not a path, so the blocked keeper is not called")
	var opened := _with_tile(state, pane.x, pane.y, Rules.Tile.FLOOR)
	_check(Rules.bell_guards(opened, bell.x, bell.y) == [0, 1], "opening the pane lets the far keeper reach the bell")
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	var near: Dictionary = stepped["state"]["guards"][0]
	var blocked: Dictionary = stepped["state"]["guards"][1]
	_check(
		stepped["result"] == Rules.Result.OK and int(stepped["called"]) == 0 and bool(near["alert"]) and not bool(blocked["alert"]),
		"a bell still calls every guard who can reach it past a pane"
	)
	_check(
		not bool(blocked["alert"]) and not bool(blocked["holding"]) and int(blocked["x"]) == 4 and int(blocked["y"]) == 3,
		"the keeper blocked by a pane is not called and keeps his post"
	)


func _check_plate_still_calls_only_the_nearest_guard_past_a_pane() -> void:
	var rows := PackedStringArray(["########", "#S.P...#", "###A####", "#......#", "########"])
	var guards: Array = [
		{"x": 6, "y": 1, "vision": 2, "rail": [Vector2i(6, 1)]},
		{"x": 3, "y": 3, "vision": 2, "rail": [Vector2i(3, 3)]},
	]
	var state := Rules.build(rows, [], guards)
	var plate := _find_tile(state, Rules.Tile.PLATE)
	var far: Dictionary = state["guards"][0]
	var near: Dictionary = state["guards"][1]
	var far_dist := absi(int(far["x"]) - plate.x) + absi(int(far["y"]) - plate.y)
	var near_dist := absi(int(near["x"]) - plate.x) + absi(int(near["y"]) - plate.y)
	_check(near_dist < far_dist and not Rules.guard_walkable(state, 3, 2), "the nearer keeper is blocked by the pane and is still nearer")
	_check(Rules.bell_guards(state, plate.x, plate.y) == [0], "the pane keeps the nearer keeper off a floor path")
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	var far_after: Dictionary = stepped["state"]["guards"][0]
	var near_after: Dictionary = stepped["state"]["guards"][1]
	_check(
		stepped["result"] == Rules.Result.OK and int(stepped["called"]) == 1 and bool(near_after["alert"]) and not bool(far_after["alert"]),
		"a plate still calls only the nearest guard past a pane"
	)
	_check(Vector2i(int(near_after["ax"]), int(near_after["ay"])) == plate, "the plate call past a pane targets the plate")


func _check_a_pane_calls_nobody() -> void:
	var rows := PackedStringArray(["#####", "#S.A#", "#####"])
	var state := Rules.build(rows, [], [{"x": 1, "y": 1, "vision": 2, "rail": [Vector2i(1, 1)]}])
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var onto: Dictionary = Rules.apply(stepped["state"], {"type": "move", "dx": 1, "dy": 0})
	_check(
		onto["result"] == Rules.Result.ILLEGAL and onto["reason"] == "pane" and int(onto["called"]) == -1,
		"a pane calls nobody and is never a hold"
	)


func _check_veil_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Veil Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_veil_rooms() -> void:
	_check_veil_identity()
	_check_earlier_wings_have_no_curtains()
	_check_veil_watched_steps()
	_check_first_cloth()
	_check_seen_cloth()
	_check_short_road()
	_check_dark_beside_curtain()
	_check_second_lamp()
	_check_last_cloth()
	_check_curtain_passes_light_and_stops_sight()
	_check_bell_still_calls_every_reachable_guard_past_a_curtain()
	_check_plate_still_calls_only_the_nearest_guard_past_a_curtain()
	_check_a_curtain_calls_nobody()


func _check_veil_identity() -> void:
	var layouts := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) != "Veil Wing":
			continue
		var layout := "|".join(puzzle["rows"])
		var title := str(puzzle["title"])
		if layouts.has(layout):
			layout_ok = false
		if titles.has(title):
			title_ok = false
		layouts[layout] = title
		titles[title] = true
	_check(layout_ok, "each veil room has its own layout")
	_check(title_ok, "each veil room has its own name")


func _veil_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Veil Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_curtains() -> void:
	var clean := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Veil Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("C"):
				clean = false
		var state := Puzzles.initial_state(i)
		for y in state["h"]:
			for x in state["w"]:
				if Rules.tile_at(state, x, y) == Rules.Tile.CURTAIN:
					clean = false
	_check(clean, "earlier wings have no curtains")


func _check_veil_watched_steps() -> void:
	var cases := [
		["The First Cloth", "R R D", 3, 2],
		["The Seen Cloth", "R", 3, 1],
		["The Short Road", "D D", 4, 5],
		["The Dark Beside", "D R", 3, 3],
		["The Second Lamp", "R R T0 L L U D D T1 R U", 4, 3],
		["The Last Cloth", "R R D", 3, 2],
	]
	for entry in cases:
		_expect_watched_loss_at(_veil_room(str(entry[0])), str(entry[1]), int(entry[2]), int(entry[3]))


func _check_first_cloth() -> void:
	var index := _veil_room("The First Cloth")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var curtain := Vector2i(3, 2)
	var gap := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	_check(Rules.tile_at(state, curtain.x, curtain.y) == Rules.Tile.CURTAIN, "the first cloth is a curtain")
	_check(lit.has(curtain) and lit.has(gap) and not watch.has(gap), "the curtain lights the gap and hides it")
	var spec := _solution_spec(puzzle)
	_check(_spec_result(state, spec) == "win", "the first cloth crosses the lit gap")
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.WALL), spec) == "darkgap", "a wall in the first cloth leaves the gap dark")
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.SILL), spec) == "darkgap", "a sill in the first cloth leaves the gap dark")
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.PANE), spec) == "watched", "a pane in the first cloth lets the guard see the gap")
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.GRATE), spec) == "win", "a grate in the first cloth still clears the crossing")
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.FLOOR), spec) == "watched", "ordinary floor in the first cloth lets the guard see the gap")
	var grated := _with_tile(state, curtain.x, curtain.y, Rules.Tile.GRATE)
	var grate_lit: Dictionary = Rules.light_map(grated)
	_check(grate_lit.has(gap) and not Rules.watched_tiles(grated, grate_lit).has(gap), "a grate in the first cloth keeps the gap lit and unwatched")
	var stepped := false
	var cursor := state
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == curtain:
				stepped = true
			if dest == gap:
				var now: Dictionary = Rules.light_map(cursor)
				_check(now.has(gap) and not Rules.watched_tiles(cursor, now).has(gap), "the first cloth steps onto a lit unwatched gap")
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "first cloth solution failed")
			return
		cursor = out["state"]
	_check(not stepped and Rules.is_win(cursor), "the first cloth crosses the gap without stepping on the curtain")


func _check_seen_cloth() -> void:
	var index := _veil_room("The Seen Cloth")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var curtain := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	_check(lit.has(curtain) and watch.has(curtain), "the seen cloth cell is lit and watched")
	var early: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	_check(early["result"] == Rules.Result.LOSS and early["reason"] == "watched", "stepping onto the seen cloth before the snuff loses")
	var spec := _solution_spec(puzzle)
	_check(_spec_result(state, spec) == "win", "the seen cloth snuffs, then steps onto the curtain")
	var grate := _with_tile(state, curtain.x, curtain.y, Rules.Tile.GRATE)
	var grate_early: Dictionary = Rules.apply(grate, {"type": "move", "dx": 1, "dy": 0})
	var grate_land: Dictionary = grate_early["state"]["player"]
	_check(
		grate_early["result"] == Rules.Result.OK and int(grate_land["x"]) == curtain.x and int(grate_land["y"]) == curtain.y and not Rules.light_map(grate).has(curtain),
		"a grate in the seen cloth stays dark, so the step before the snuff succeeds"
	)
	_check(_spec_result(grate, spec) == "win", "a grate in the seen cloth still clears")
	var pane_early: Dictionary = Rules.apply(_with_tile(state, curtain.x, curtain.y, Rules.Tile.PANE), {"type": "move", "dx": 1, "dy": 0})
	_check(pane_early["result"] == Rules.Result.ILLEGAL and pane_early["reason"] == "pane", "a pane in the seen cloth cannot be entered")
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.PANE), spec) == "pane", "the seen cloth solution cannot enter a pane")
	var sill := _with_tile(state, curtain.x, curtain.y, Rules.Tile.SILL)
	var sill_early: Dictionary = Rules.apply(sill, {"type": "move", "dx": 1, "dy": 0})
	_check(Rules.light_map(sill).has(curtain) and sill_early["result"] == Rules.Result.LOSS and sill_early["reason"] == "watched", "a sill in the seen cloth is lit, so the step before the snuff still fails")
	var crossed := false
	var cursor := state
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == curtain:
				crossed = not Rules.light_map(cursor).has(curtain)
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "seen cloth solution failed")
			return
		cursor = out["state"]
	_check(crossed and Rules.is_win(cursor), "the seen cloth steps onto the curtain after the snuff")


func _check_short_road() -> void:
	var index := _veil_room("The Short Road")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var curtain := Vector2i(3, 4)
	var spec := _solution_spec(puzzle)
	_check(_spec_result(state, spec) == "win", "the short road leaves before the called guard arrives")
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.FLOOR), spec) == "watched", "ordinary floor on the short road lets the guard see through the cell")
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.GRATE), spec) == "guard", "a grate on the short road sends the guard the long way")
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.SILL), spec) == "guard", "a sill on the short road sends the guard the long way")
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.PANE), spec) == "guard", "a pane on the short road sends the guard the long way")
	var called: Dictionary = Rules.apply(state, {"type": "toggle", "lamp": 0})
	var short: Array = Rules.planned_path(called["state"], 0)
	var blocked: Array = Rules.planned_path(_with_tile(called["state"], curtain.x, curtain.y, Rules.Tile.GRATE), 0)
	_check(_path_has(short, curtain) and not _path_has(short, Vector2i(4, 3)), "the called guard's shortest floor path goes through the curtain")
	_check(not _path_has(blocked, curtain) and _path_has(blocked, Vector2i(4, 3)) and blocked.size() > short.size(), "a grate is not a path, so the longer road catches the scripted line")
	var stood := false
	var cursor := state
	for action in puzzle["solution"]:
		var player: Dictionary = cursor["player"]
		if _path_has(short, Vector2i(int(player["x"]), int(player["y"]))):
			stood = true
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "short road solution failed")
			return
		cursor = out["state"]
	_check(not stood and Rules.is_win(cursor), "you are off the short road before the guard arrives")


func _check_dark_beside_curtain() -> void:
	var index := _veil_room("The Dark Beside")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var curtain := Vector2i(3, 3)
	var beside := Vector2i(2, 3)
	var gap := Vector2i(3, 4)
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	_check(not lit.has(beside) and lit.has(gap) and not watch.has(gap) and lit.has(curtain), "the tile beside the curtain stays dark and the tile past it is lit")
	var spec := _solution_spec(puzzle)
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.WALL), spec) == "darkgap", "a wall in the dark beside leaves the far tile dark")
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.SILL), spec) == "darkgap", "a sill in the dark beside leaves the far tile dark")
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.PANE), spec) == "watched", "a pane in the dark beside leaves the far tile watched")
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.GRATE), spec) == "win", "a grate in the dark beside still clears")
	var grate_lit: Dictionary = Rules.light_map(_with_tile(state, curtain.x, curtain.y, Rules.Tile.GRATE))
	_check(grate_lit.has(gap) and not Rules.watched_tiles(_with_tile(state, curtain.x, curtain.y, Rules.Tile.GRATE), grate_lit).has(gap), "a grate in the dark beside keeps the far tile lit and unwatched")
	var entered := false
	var cursor := state
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == beside:
				entered = not Rules.light_map(cursor).has(beside)
			if dest == gap:
				var now: Dictionary = Rules.light_map(cursor)
				_check(now.has(gap) and not Rules.watched_tiles(cursor, now).has(gap), "the dark beside steps onto the lit unwatched tile")
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "dark beside curtain solution failed")
			return
		cursor = out["state"]
	_check(entered and Rules.is_win(cursor), "the dark beside solution enters the unlit tile beside the curtain")


func _check_second_lamp() -> void:
	var index := _veil_room("The Second Lamp")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var curtain := Vector2i(3, 2)
	var gap := Vector2i(3, 1)
	_check(state["lamps"].size() == 2 and bool(state["lamps"][1]["lit"]) == false, "the second lamp room keeps its second lamp")
	var early: Dictionary = Rules.apply(state, {"type": "move", "dx": 0, "dy": -1})
	_check(Rules.light_map(state).has(curtain) and early["result"] == Rules.Result.ILLEGAL and early["reason"] == "lit", "the curtain is refused before the snuff")
	var grate := _with_tile(state, curtain.x, curtain.y, Rules.Tile.GRATE)
	var grate_early: Dictionary = Rules.apply(grate, {"type": "move", "dx": 0, "dy": -1})
	var grate_land: Dictionary = grate_early["state"]["player"]
	_check(
		grate_early["result"] == Rules.Result.OK and int(grate_land["x"]) == curtain.x and int(grate_land["y"]) == curtain.y and not Rules.light_map(grate).has(curtain),
		"a grate stays dark, so the step before the snuff succeeds"
	)
	var spec := _solution_spec(puzzle)
	_check(_spec_result(state, spec) == "win", "the second lamp snuffs, crosses the curtain, and leaves by the hidden gap")
	_check(_spec_result(grate, spec) == "win", "a grate in the second lamp still clears")
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.WALL), spec) == "wall", "a wall in the second lamp cannot be crossed")
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.SILL), spec) == "darkgap", "a sill in the second lamp leaves the gap dark")
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.PANE), spec) == "pane", "a pane in the second lamp cannot be entered")
	for kind in [[Rules.Tile.CURTAIN, true, false], [Rules.Tile.WALL, false, false], [Rules.Tile.SILL, false, false], [Rules.Tile.PANE, true, true], [Rules.Tile.GRATE, true, false]]:
		var ready := _with_tile(state, curtain.x, curtain.y, int(kind[0]))
		ready["lamps"][0]["lit"] = false
		ready["lamps"][1]["lit"] = true
		ready["player"]["x"] = 4
		ready["player"]["y"] = 1
		ready["guards"][0]["x"] = 5
		ready["guards"][0]["y"] = 2
		ready["guards"][0]["holding"] = true
		var now: Dictionary = Rules.light_map(ready)
		var seen: Dictionary = Rules.watched_tiles(ready, now)
		_check(now.has(gap) == bool(kind[1]) and seen.has(gap) == bool(kind[2]), "the second lamp reaches the gap only through an open cell")
	var approach := _with_tile(state, curtain.x, curtain.y, Rules.Tile.PANE)
	approach["lamps"][0]["lit"] = false
	approach["lamps"][1]["lit"] = true
	approach["player"]["x"] = 4
	approach["player"]["y"] = 1
	approach["guards"][0]["x"] = 5
	approach["guards"][0]["y"] = 2
	approach["guards"][0]["holding"] = true
	var pane_step: Dictionary = Rules.apply(approach, {"type": "move", "dx": -1, "dy": 0})
	_check(pane_step["result"] == Rules.Result.LOSS and pane_step["reason"] == "watched", "a pane leaves the second lamp's gap watched, so that step loses")
	var wall_ready := _with_tile(state, curtain.x, curtain.y, Rules.Tile.WALL)
	wall_ready["lamps"][0]["lit"] = false
	wall_ready["lamps"][1]["lit"] = true
	_check(not Rules.light_map(wall_ready).has(gap), "a wall leaves the second lamp's gap dark")
	var sill_ready := _with_tile(state, curtain.x, curtain.y, Rules.Tile.SILL)
	sill_ready["lamps"][0]["lit"] = false
	sill_ready["lamps"][1]["lit"] = true
	_check(not Rules.light_map(sill_ready).has(gap), "a sill leaves the second lamp's gap dark")
	var crossed := false
	var hid := false
	var cursor := state
	var snuffed := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle" and int(action["lamp"]) == 0:
			snuffed = true
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == curtain:
				crossed = snuffed and not bool(cursor["lamps"][1]["lit"]) and not Rules.light_map(cursor).has(curtain)
			if dest == gap:
				var now_gap: Dictionary = Rules.light_map(cursor)
				hid = bool(cursor["lamps"][1]["lit"]) and not bool(cursor["lamps"][0]["lit"]) and now_gap.has(gap) and not Rules.watched_tiles(cursor, now_gap).has(gap)
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "second lamp solution failed")
			return
		cursor = out["state"]
	_check(crossed and hid and Rules.is_win(cursor), "the second lamp crosses the curtain, then leaves by the gap the curtain still hides")


func _check_last_cloth() -> void:
	var index := _veil_room("The Last Cloth")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var curtain := Vector2i(3, 2)
	var gap := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	_check(lit.has(curtain) and watch.has(curtain) and lit.has(gap) and not watch.has(gap), "the last cloth leaves its gap lit and unwatched")
	var spec := _solution_spec(puzzle)
	_check(_spec_result(state, spec) == "win", "the last cloth leaves by the hidden gap")
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.WALL), spec) == "darkgap", "a wall in the last cloth leaves the gap dark")
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.SILL), spec) == "darkgap", "a sill in the last cloth leaves the gap dark")
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.PANE), spec) == "watched", "a pane in the last cloth makes the gap watched")
	_check(_spec_result(_with_tile(state, curtain.x, curtain.y, Rules.Tile.GRATE), spec) == "win", "a grate in the last cloth still clears")
	var stood := Rules.clone(state)
	stood["player"]["x"] = 3
	stood["player"]["y"] = 3
	var early: Dictionary = Rules.apply(stood, {"type": "move", "dx": 0, "dy": -1})
	_check(early["result"] == Rules.Result.LOSS and early["reason"] == "watched", "stepping onto the last cloth is a loss")
	var grate_stood := _with_tile(stood, curtain.x, curtain.y, Rules.Tile.GRATE)
	var grate_early: Dictionary = Rules.apply(grate_stood, {"type": "move", "dx": 0, "dy": -1})
	var grate_land: Dictionary = grate_early["state"]["player"]
	_check(
		grate_early["result"] == Rules.Result.OK and int(grate_land["x"]) == curtain.x and int(grate_land["y"]) == curtain.y,
		"the early step onto that cell is not a loss when the cell is a grate"
	)
	var sill_stood := _with_tile(stood, curtain.x, curtain.y, Rules.Tile.SILL)
	var sill_early: Dictionary = Rules.apply(sill_stood, {"type": "move", "dx": 0, "dy": -1})
	_check(sill_early["result"] == Rules.Result.LOSS and sill_early["reason"] == "watched", "a sill in the last cloth is still a watched step")
	var stepped := false
	var cursor := state
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == curtain:
				stepped = true
			if dest == gap:
				var now: Dictionary = Rules.light_map(cursor)
				_check(now.has(gap) and not Rules.watched_tiles(cursor, now).has(gap), "the last cloth steps onto the lit unwatched gap")
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "last cloth solution failed")
			return
		cursor = out["state"]
	_check(not stepped and Rules.is_win(cursor), "the last cloth never steps on the curtain")


func _check_curtain_passes_light_and_stops_sight() -> void:
	var rows := PackedStringArray(["#######", "###.###", "###.###", "###C###", "###.###", "#######"])
	var lamps: Array = [{"x": 3, "y": 1, "facing": "s", "radius": 3, "lit": true}]
	var guards: Array = [{"x": 3, "y": 1, "vision": 4, "rail": [Vector2i(3, 1)]}]
	var state := Rules.build(rows, lamps, guards)
	var curtain := Vector2i(3, 3)
	var past := Vector2i(3, 4)
	var lit: Dictionary = Rules.light_map(state)
	var watch: Dictionary = Rules.watched_tiles(state, lit)
	_check(
		Rules.tile_at(state, curtain.x, curtain.y) == Rules.Tile.CURTAIN and lit.has(curtain) and lit.has(past) and watch.has(curtain) and not watch.has(past),
		"a lit curtain can be watched, and the lit tile past it cannot"
	)
	_check(Rules.guard_walkable(state, curtain.x, curtain.y), "a guard can enter a curtain")
	var walled := _with_tile(state, curtain.x, curtain.y, Rules.Tile.WALL)
	var wall_lit: Dictionary = Rules.light_map(walled)
	_check(not wall_lit.has(past) and not Rules.watched_tiles(walled, wall_lit).has(past) and not Rules.guard_walkable(walled, curtain.x, curtain.y), "a wall blocks the light, the sight, and the step")
	var silled := _with_tile(state, curtain.x, curtain.y, Rules.Tile.SILL)
	var sill_lit: Dictionary = Rules.light_map(silled)
	_check(sill_lit.has(curtain) and not sill_lit.has(past) and not Rules.watched_tiles(silled, sill_lit).has(past) and not Rules.guard_walkable(silled, curtain.x, curtain.y), "a sill is lit, stops the light and the sight, and a guard cannot enter it")
	var grated := _with_tile(state, curtain.x, curtain.y, Rules.Tile.GRATE)
	var grate_lit: Dictionary = Rules.light_map(grated)
	_check(
		grate_lit.has(past) and not grate_lit.has(curtain) and not Rules.watched_tiles(grated, grate_lit).has(past) and not Rules.guard_walkable(grated, curtain.x, curtain.y),
		"a grate stays dark, lets the light through, blocks sight, and a guard cannot enter it"
	)
	var paned := _with_tile(state, curtain.x, curtain.y, Rules.Tile.PANE)
	var pane_lit: Dictionary = Rules.light_map(paned)
	var pane_watch: Dictionary = Rules.watched_tiles(paned, pane_lit)
	_check(pane_lit.has(past) and pane_watch.has(past) and not pane_lit.has(curtain) and not Rules.guard_walkable(paned, curtain.x, curtain.y), "a pane lets the light and the sight through, and a guard cannot step on it")
	var stood := Rules.clone(state)
	stood["guards"][0]["x"] = curtain.x
	stood["guards"][0]["y"] = curtain.y
	var outward: Dictionary = Rules.watched_tiles(stood)
	_check(outward.has(past), "a guard standing on a curtain can still look out from it")


func _check_bell_still_calls_every_reachable_guard_past_a_curtain() -> void:
	var rows := PackedStringArray(["########", "#S.B...#", "###C####", "#......#", "########"])
	var guards: Array = [
		{"x": 5, "y": 1, "vision": 2, "rail": [Vector2i(5, 1)]},
		{"x": 4, "y": 3, "vision": 2, "rail": [Vector2i(4, 3)]},
	]
	var state := Rules.build(rows, [], guards)
	var bell := _find_tile(state, Rules.Tile.BELL)
	var curtain := _find_tile(state, Rules.Tile.CURTAIN)
	_check(Rules.bell_guards(state, bell.x, bell.y) == [0, 1], "a curtain counts as a floor path, so the far keeper is called")
	var closed := _with_tile(state, curtain.x, curtain.y, Rules.Tile.WALL)
	_check(Rules.bell_guards(closed, bell.x, bell.y) == [0], "a wall in the curtain's cell keeps the far keeper off the bell")
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	var near: Dictionary = stepped["state"]["guards"][0]
	var far: Dictionary = stepped["state"]["guards"][1]
	_check(
		stepped["result"] == Rules.Result.OK and bool(near["alert"]) and bool(far["alert"]),
		"a bell still calls every guard who has a floor path, and a curtain counts as that path"
	)


func _check_plate_still_calls_only_the_nearest_guard_past_a_curtain() -> void:
	var rows := PackedStringArray(["########", "#S.P...#", "###C####", "#......#", "########"])
	var guards: Array = [
		{"x": 6, "y": 1, "vision": 2, "rail": [Vector2i(6, 1)]},
		{"x": 3, "y": 3, "vision": 2, "rail": [Vector2i(3, 3)]},
	]
	var state := Rules.build(rows, [], guards)
	var plate := _find_tile(state, Rules.Tile.PLATE)
	var far: Dictionary = state["guards"][0]
	var near: Dictionary = state["guards"][1]
	var far_dist := absi(int(far["x"]) - plate.x) + absi(int(far["y"]) - plate.y)
	var near_dist := absi(int(near["x"]) - plate.x) + absi(int(near["y"]) - plate.y)
	_check(near_dist < far_dist and Rules.guard_walkable(state, 3, 2), "the nearer keeper can walk through the curtain and is still nearer")
	_check(Rules.bell_guards(state, plate.x, plate.y) == [0, 1], "a curtain counts as a floor path to the plate")
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	var far_after: Dictionary = stepped["state"]["guards"][0]
	var near_after: Dictionary = stepped["state"]["guards"][1]
	_check(
		stepped["result"] == Rules.Result.OK and int(stepped["called"]) == 1 and bool(near_after["alert"]) and not bool(far_after["alert"]),
		"a plate still calls only the nearest guard past a curtain"
	)
	_check(Vector2i(int(near_after["ax"]), int(near_after["ay"])) == plate, "the plate call past a curtain targets the plate")


func _check_a_curtain_calls_nobody() -> void:
	var rows := PackedStringArray(["#####", "#S.C#", "#####"])
	var state := Rules.build(rows, [], [{"x": 1, "y": 1, "vision": 2, "rail": [Vector2i(1, 1)]}])
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var onto: Dictionary = Rules.apply(stepped["state"], {"type": "move", "dx": 1, "dy": 0})
	var guard: Dictionary = onto["state"]["guards"][0]
	_check(
		onto["result"] == Rules.Result.OK and int(onto["called"]) == -1 and not bool(guard["alert"]) and not bool(guard["holding"]),
		"a curtain calls nobody and is never a hold"
	)


func _check_shade_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Shade Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_shade_rooms() -> void:
	_check_shade_identity()
	_check_earlier_wings_have_no_shades()
	_check_shade_watched_steps()
	_check_first_shade()
	_check_dark_step()
	_check_long_road_shade()
	_check_far_dark()
	_check_second_lamp_shade()
	_check_last_shade()
	_check_shade_stops_light_and_sight()
	_check_bell_still_calls_every_reachable_guard_past_a_shade()
	_check_plate_still_calls_only_the_nearest_guard_past_a_shade()
	_check_a_shade_calls_nobody()


func _check_shade_identity() -> void:
	var layouts := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) != "Shade Wing":
			continue
		var layout := "|".join(puzzle["rows"])
		var title := str(puzzle["title"])
		if layouts.has(layout):
			layout_ok = false
		if titles.has(title):
			title_ok = false
		layouts[layout] = title
		titles[title] = true
	_check(layout_ok, "each shade room has its own layout")
	_check(title_ok, "each shade room has its own name")


func _shade_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Shade Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_shades() -> void:
	var clean := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Shade Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("H"):
				clean = false
		var state := Puzzles.initial_state(i)
		for y in state["h"]:
			for x in state["w"]:
				if Rules.tile_at(state, x, y) == Rules.Tile.SHADE:
					clean = false
	_check(clean, "earlier wings have no shades")


func _check_shade_watched_steps() -> void:
	var cases := [
		["The First Shade", "R D", 4, 2],
		["The Dark Step", "R D", 3, 2],
		["The Long Road", "R D D D D R R R R R R R R", 10, 5],
		["The Far Dark", "R D", 4, 2],
		["The Second Lamp", "R D", 3, 3],
		["The Last Shade", "R D", 4, 2],
	]
	for entry in cases:
		_expect_watched_loss_at(_shade_room(str(entry[0])), str(entry[1]), int(entry[2]), int(entry[3]))


func _check_first_shade() -> void:
	var index := _shade_room("The First Shade")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := Vector2i(4, 1)
	var gap := Vector2i(5, 1)
	var lit: Dictionary = Rules.light_map(state)
	_check(Rules.tile_at(state, cell.x, cell.y) == Rules.Tile.SHADE, "the first shade is a shade")
	_check(not lit.has(cell) and not lit.has(gap) and not Rules.watched_tiles(state, lit).has(gap), "light stops at the first shade, so the gap stays dark")
	var onto: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stood: Dictionary = onto["state"]["player"]
	_check(
		onto["result"] == Rules.Result.OK and int(stood["x"]) == cell.x and int(stood["y"]) == cell.y and bool(state["lamps"][0]["lit"]) and not Rules.light_map(state).has(cell),
		"you may step on the first shade while the lamp is lit"
	)
	var spec := _solution_spec(puzzle)
	_check(_spec_result(state, spec) == "win", "the first shade leaves by the dark gap")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.WALL), spec) == "wall", "a wall in the first shade cannot be entered")
	_check(not Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.WALL)).has(gap), "a wall in the first shade leaves the gap dark")
	var sill := _with_tile(state, cell.x, cell.y, Rules.Tile.SILL)
	_check(Rules.light_map(sill).has(cell) and not Rules.light_map(sill).has(gap) and _spec_result(sill, spec) == "lit", "a sill in the first shade is lit, so the step before a snuff fails")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	var grate_step: Dictionary = Rules.apply(grate, {"type": "move", "dx": 1, "dy": 0})
	_check(grate_step["result"] == Rules.Result.OK and Rules.light_map(grate).has(gap) and _spec_result(grate, spec) == "lit", "a grate in the first shade lights the gap, so that substitute fails")
	_check(Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE)).has(gap) and _spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE), spec) == "pane", "a pane in the first shade lights the gap and cannot be entered")
	var curtain := _with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN)
	_check(Rules.light_map(curtain).has(cell) and Rules.light_map(curtain).has(gap) and _spec_result(curtain, spec) == "lit", "a curtain in the first shade lights the gap, so that substitute fails")
	var entered := false
	var cursor := state
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == cell:
				entered = not Rules.light_map(cursor).has(cell)
			if dest == gap:
				_check(not Rules.light_map(cursor).has(gap) and not Rules.watched_tiles(cursor).has(gap), "the first shade steps into a dark gap")
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "first shade solution failed")
			return
		cursor = out["state"]
	_check(entered and Rules.is_win(cursor), "the first shade solution steps on the shade and leaves")


func _check_dark_step() -> void:
	var index := _shade_room("The Dark Step")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := Vector2i(3, 1)
	var past := Vector2i(4, 1)
	var spec := _solution_spec(puzzle)
	var onto: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stood: Dictionary = onto["state"]["player"]
	_check(
		not Rules.light_map(state).has(cell) and onto["result"] == Rules.Result.OK and int(stood["x"]) == cell.x and int(stood["y"]) == cell.y and bool(state["lamps"][0]["lit"]),
		"the dark step lands on the shade under the lamp without snuffing"
	)
	_check(_spec_result(state, spec) == "win", "the dark step leaves by the tile past the shade")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.WALL), spec) == "wall", "a wall in the dark step cannot be entered")
	_check(Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.SILL)).has(cell) and _spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SILL), spec) == "lit", "a sill in the dark step is lit, so that step fails")
	_check(Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN)).has(cell) and _spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), spec) == "lit", "a curtain in the dark step is lit, so that step fails")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	var grate_step: Dictionary = Rules.apply(grate, {"type": "move", "dx": 1, "dy": 0})
	_check(
		not Rules.light_map(grate).has(cell) and grate_step["result"] == Rules.Result.OK and Rules.light_map(grate).has(past) and _spec_result(grate, spec) == "lit",
		"a grate in the dark step can be entered, but the tile past it is lit"
	)
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE), spec) == "pane", "a pane in the dark step cannot be entered")


func _check_long_road_shade() -> void:
	var index := _shade_room("The Long Road")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := Vector2i(6, 1)
	var crossed := Vector2i(5, 1)
	var spec := _solution_spec(puzzle)
	_check(_spec_result(state, spec) == "win", "the long road crosses before the called guard arrives")
	var called: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	called = Rules.apply(called["state"], {"type": "move", "dx": 1, "dy": 0})
	called = Rules.apply(called["state"], {"type": "toggle", "lamp": 0})
	var shade_path: Array = Rules.planned_path(called["state"], 0)
	var curtain_state := _with_tile(called["state"], cell.x, cell.y, Rules.Tile.CURTAIN)
	var curtain_path: Array = Rules.planned_path(curtain_state, 0)
	_check(not _path_has(shade_path, cell) and _path_has(curtain_path, cell) and curtain_path.size() < shade_path.size(), "a curtain is a path, so the guard takes the short road through that cell")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), spec) == "guard", "the short road through the curtain catches the scripted line")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	var pane := _with_tile(state, cell.x, cell.y, Rules.Tile.PANE)
	var sill := _with_tile(state, cell.x, cell.y, Rules.Tile.SILL)
	_check(Rules.light_map(grate).has(crossed) and not Rules.light_map(grate).has(cell) and _spec_result(grate, spec) == "lit", "a grate lights the tile you cross on the long road")
	_check(Rules.light_map(pane).has(crossed) and _spec_result(pane, spec) == "lit", "a pane lights the tile you cross on the long road")
	_check(Rules.light_map(sill).has(cell) and not Rules.light_map(sill).has(crossed) and _spec_result(sill, spec) == "lit", "a sill on the long road is lit where the script steps")
	_check(not Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.WALL)).has(crossed) and _spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.WALL), spec) == "wall", "a wall on the long road cannot be entered")
	_check(not Rules.light_map(state).has(crossed) and not Rules.light_map(state).has(cell), "the shade leaves the tile you cross dark")


func _check_far_dark() -> void:
	var index := _shade_room("The Far Dark")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := Vector2i(4, 1)
	var far := Vector2i(5, 1)
	var spec := _solution_spec(puzzle)
	_check(not Rules.light_map(state).has(far) and _spec_result(state, spec) == "win", "the tile past the far shade stays dark and can be entered")
	_check(not Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.WALL)).has(far) and _spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.WALL), spec) == "wall", "a wall in the far dark leaves the far tile dark and cannot be entered")
	var sill := _with_tile(state, cell.x, cell.y, Rules.Tile.SILL)
	_check(Rules.light_map(sill).has(cell) and not Rules.light_map(sill).has(far) and _spec_result(sill, spec) == "lit", "a sill in the far dark is lit where the script steps")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	var grate_step: Dictionary = Rules.apply(grate, {"type": "move", "dx": 1, "dy": 0})
	_check(grate_step["result"] == Rules.Result.OK and Rules.light_map(grate).has(far) and _spec_result(grate, spec) == "lit", "a grate in the far dark lights the far tile")
	_check(Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE)).has(far) and _spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE), spec) == "pane", "a pane in the far dark lights the far tile and cannot be entered")
	var curtain := _with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN)
	_check(Rules.light_map(curtain).has(far) and _spec_result(curtain, spec) == "lit", "a curtain in the far dark lights the far tile")
	var entered := false
	var cursor := state
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == far:
				entered = not Rules.light_map(cursor).has(far)
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "far dark solution failed")
			return
		cursor = out["state"]
	_check(entered and Rules.is_win(cursor), "the far dark solution enters the dark tile past the shade")


func _check_second_lamp_shade() -> void:
	var index := _shade_room("The Second Lamp")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := Vector2i(3, 2)
	var gap := Vector2i(4, 2)
	_check(state["lamps"].size() == 2 and bool(state["lamps"][1]["lit"]), "the second lamp shade keeps its second lamp")
	var onto: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stood: Dictionary = onto["state"]["player"]
	_check(
		onto["result"] == Rules.Result.OK and int(stood["x"]) == cell.x and int(stood["y"]) == cell.y and bool(state["lamps"][0]["lit"]) and not Rules.light_map(state).has(cell),
		"you cross the second lamp's shade before the snuff"
	)
	var spec := _solution_spec(puzzle)
	_check(_spec_result(state, spec) == "win", "the second lamp's shade leaves by the dark gap")
	var sill := _with_tile(state, cell.x, cell.y, Rules.Tile.SILL)
	_check(Rules.light_map(sill).has(cell) and _spec_result(sill, spec) == "lit", "a sill in the second lamp shade is lit, so the step before a snuff fails")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	var grate_step: Dictionary = Rules.apply(grate, {"type": "move", "dx": 1, "dy": 0})
	_check(grate_step["result"] == Rules.Result.OK and _spec_result(grate, spec) == "lit", "a grate in the second lamp shade lights the gap")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE), spec) == "pane", "a pane in the second lamp shade cannot be entered")
	_check(Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN)).has(cell) and _spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), spec) == "lit", "a curtain in the second lamp shade would light the gap")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.WALL), spec) == "wall", "a wall in the second lamp shade cannot be entered")
	for pair in [[Rules.Tile.SHADE, false, false], [Rules.Tile.WALL, false, false], [Rules.Tile.SILL, false, true], [Rules.Tile.GRATE, true, false], [Rules.Tile.PANE, true, false], [Rules.Tile.CURTAIN, true, true]]:
		var ready := _with_tile(state, cell.x, cell.y, int(pair[0]))
		ready["lamps"][0]["lit"] = false
		var now: Dictionary = Rules.light_map(ready)
		_check(now.has(gap) == bool(pair[1]) and now.has(cell) == bool(pair[2]), "the second lamp's light stops at the shade and passes a grate, a pane, or a curtain")
	var kept := false
	var cursor := state
	for action in puzzle["solution"]:
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "second lamp shade solution failed")
			return
		cursor = out["state"]
		if out["result"] == Rules.Result.WIN:
			kept = bool(cursor["lamps"][1]["lit"]) and not bool(cursor["lamps"][0]["lit"]) and not Rules.light_map(cursor).has(gap)
	_check(kept, "the second lamp stays lit, and the gap beyond the shade is dark when you leave")


func _check_last_shade() -> void:
	var index := _shade_room("The Last Shade")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := Vector2i(4, 1)
	var gap := Vector2i(5, 1)
	var lit: Dictionary = Rules.light_map(state)
	_check(not lit.has(cell) and not lit.has(gap) and not Rules.watched_tiles(state, lit).has(gap), "the last shade leaves its gap dark")
	var onto: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	_check(onto["result"] == Rules.Result.OK and not Rules.light_map(state).has(cell), "you may step on the last shade")
	var spec := _solution_spec(puzzle)
	_check(_spec_result(state, spec) == "win", "the last shade leaves by the dark gap")
	var curtain := _with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN)
	var curtain_lit: Dictionary = Rules.light_map(curtain)
	_check(
		curtain_lit.has(gap) and Rules.watched_tiles(curtain, curtain_lit).has(gap) and _spec_result(curtain, spec) == "lit",
		"a curtain in the last shade lights the gap and makes it watched"
	)
	var stood := _with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN)
	stood["player"]["x"] = cell.x
	stood["player"]["y"] = cell.y
	var gap_step: Dictionary = Rules.apply(stood, {"type": "move", "dx": 1, "dy": 0})
	_check(gap_step["result"] == Rules.Result.LOSS and gap_step["reason"] == "watched", "stepping into the curtain's lit gap loses")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	var grate_step: Dictionary = Rules.apply(grate, {"type": "move", "dx": 1, "dy": 0})
	_check(grate_step["result"] == Rules.Result.OK and Rules.light_map(grate).has(gap) and _spec_result(grate, spec) == "watched", "a grate in the last shade lights the gap")
	var pane := _with_tile(state, cell.x, cell.y, Rules.Tile.PANE)
	_check(Rules.light_map(pane).has(gap) and Rules.watched_tiles(pane).has(gap) and _spec_result(pane, spec) == "pane", "a pane in the last shade lights the gap and cannot be entered")
	var sill := _with_tile(state, cell.x, cell.y, Rules.Tile.SILL)
	_check(Rules.light_map(sill).has(cell) and not Rules.light_map(sill).has(gap) and _spec_result(sill, spec) == "lit", "a sill in the last shade is lit where the early step fails")
	_check(not Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.WALL)).has(gap) and _spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.WALL), spec) == "wall", "a wall in the last shade leaves the gap dark and cannot be entered")


func _check_shade_stops_light_and_sight() -> void:
	var rows := PackedStringArray(["######", "#SHX.#", "##.#.#", "#....#", "######"])
	var lamps: Array = [
		{"x": 2, "y": 2, "facing": "n", "radius": 2, "lit": true},
		{"x": 4, "y": 1, "facing": "w", "radius": 1, "lit": false},
	]
	var guards: Array = [{"x": 2, "y": 2, "vision": 4, "rail": [Vector2i(2, 2)]}]
	var state := Rules.build(rows, lamps, guards)
	var cell := Vector2i(2, 1)
	var past := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	_check(
		Rules.tile_at(state, cell.x, cell.y) == Rules.Tile.SHADE and not lit.has(cell) and not lit.has(past) and not Rules.watched_tiles(state, lit).has(past) and not Rules.guard_walkable(state, cell.x, cell.y),
		"a shade stays dark, stops the light, stops the sight, and a guard cannot enter it"
	)
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stood: Dictionary = stepped["state"]["player"]
	_check(
		stepped["result"] == Rules.Result.OK and int(stood["x"]) == cell.x and int(stood["y"]) == cell.y and int(stepped["called"]) == -1,
		"you can step on a shade, and the step calls nobody"
	)
	var curtain := _with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN)
	var curtain_lit: Dictionary = Rules.light_map(curtain)
	_check(curtain_lit.has(cell) and curtain_lit.has(past) and not Rules.watched_tiles(curtain, curtain_lit).has(past) and Rules.guard_walkable(curtain, cell.x, cell.y), "a curtain is lit, lets the light through, stops the sight, and a guard can step on it")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	var grate_lit: Dictionary = Rules.light_map(grate)
	_check(not grate_lit.has(cell) and grate_lit.has(past) and not Rules.watched_tiles(grate, grate_lit).has(past) and not Rules.guard_walkable(grate, cell.x, cell.y), "a grate stays dark, lets the light through, and a guard cannot enter it")
	var sill := _with_tile(state, cell.x, cell.y, Rules.Tile.SILL)
	var sill_lit: Dictionary = Rules.light_map(sill)
	_check(sill_lit.has(cell) and not sill_lit.has(past) and not Rules.guard_walkable(sill, cell.x, cell.y), "a sill is lit, stops the light, and a guard cannot enter it")
	var pane := _with_tile(state, cell.x, cell.y, Rules.Tile.PANE)
	var pane_lit: Dictionary = Rules.light_map(pane)
	_check(pane_lit.has(past) and Rules.watched_tiles(pane, pane_lit).has(past) and not Rules.guard_walkable(pane, cell.x, cell.y), "a pane lets the light and the sight through, and nobody can step on it")
	var wall := _with_tile(state, cell.x, cell.y, Rules.Tile.WALL)
	_check(not Rules.light_map(wall).has(past) and not Rules.guard_walkable(wall, cell.x, cell.y), "a wall blocks the light and the sight")
	var beyond := Rules.clone(state)
	beyond["lamps"][1]["lit"] = true
	var beyond_lit: Dictionary = Rules.light_map(beyond)
	_check(beyond_lit.has(past) and not beyond_lit.has(cell) and not Rules.watched_tiles(beyond, beyond_lit).has(past), "a lit tile past a shade stays out of sight")
	beyond["guards"][0]["x"] = cell.x
	beyond["guards"][0]["y"] = cell.y
	_check(Rules.watched_tiles(beyond).has(past), "a guard standing on a shade can still look into an adjacent lit tile")


func _check_bell_still_calls_every_reachable_guard_past_a_shade() -> void:
	var rows := PackedStringArray(["########", "#S.B...#", "###H####", "#......#", "########"])
	var guards: Array = [
		{"x": 5, "y": 1, "vision": 2, "rail": [Vector2i(5, 1)]},
		{"x": 4, "y": 3, "vision": 2, "rail": [Vector2i(4, 3)]},
	]
	var state := Rules.build(rows, [], guards)
	var bell := _find_tile(state, Rules.Tile.BELL)
	var shade := _find_tile(state, Rules.Tile.SHADE)
	_check(Rules.bell_guards(state, bell.x, bell.y) == [0], "a shade is not a floor path, so the keeper behind it is not called")
	var opened := _with_tile(state, shade.x, shade.y, Rules.Tile.FLOOR)
	_check(Rules.bell_guards(opened, bell.x, bell.y) == [0, 1], "opening the shade's cell to floor calls the keeper who can then reach the bell")
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	var near: Dictionary = stepped["state"]["guards"][0]
	var far: Dictionary = stepped["state"]["guards"][1]
	_check(
		stepped["result"] == Rules.Result.OK and bool(near["alert"]) and not bool(far["alert"]),
		"a bell still calls every guard who has a floor path, and a shade is not that path"
	)


func _check_plate_still_calls_only_the_nearest_guard_past_a_shade() -> void:
	var rows := PackedStringArray(["########", "#S.P...#", "###H####", "#......#", "########"])
	var guards: Array = [
		{"x": 6, "y": 1, "vision": 2, "rail": [Vector2i(6, 1)]},
		{"x": 3, "y": 3, "vision": 2, "rail": [Vector2i(3, 3)]},
	]
	var state := Rules.build(rows, [], guards)
	var plate := _find_tile(state, Rules.Tile.PLATE)
	var far: Dictionary = state["guards"][0]
	var near: Dictionary = state["guards"][1]
	var far_dist := absi(int(far["x"]) - plate.x) + absi(int(far["y"]) - plate.y)
	var near_dist := absi(int(near["x"]) - plate.x) + absi(int(near["y"]) - plate.y)
	_check(near_dist < far_dist and not Rules.guard_walkable(state, 3, 2), "the nearer keeper is blocked by the shade and is still nearer")
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	var far_after: Dictionary = stepped["state"]["guards"][0]
	var near_after: Dictionary = stepped["state"]["guards"][1]
	_check(
		stepped["result"] == Rules.Result.OK and int(stepped["called"]) == 1 and bool(near_after["alert"]) and not bool(far_after["alert"]),
		"a plate still calls only the nearest guard past a shade"
	)


func _check_a_shade_calls_nobody() -> void:
	var rows := PackedStringArray(["#####", "#S.H#", "#####"])
	var state := Rules.build(rows, [], [{"x": 1, "y": 1, "vision": 2, "rail": [Vector2i(1, 1)]}])
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var onto: Dictionary = Rules.apply(stepped["state"], {"type": "move", "dx": 1, "dy": 0})
	var guard: Dictionary = onto["state"]["guards"][0]
	_check(
		onto["result"] == Rules.Result.OK and int(onto["called"]) == -1 and not bool(guard["alert"]) and not bool(guard["holding"]),
		"a shade calls nobody and is never a hold"
	)


func _check_screen_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Screen Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_screen_rooms() -> void:
	_check_screen_identity()
	_check_earlier_wings_have_no_screens()
	_check_screen_watched_steps()
	_check_first_screen()
	_check_lit_screen()
	_check_closed_road()
	_check_far_light()
	_check_second_lamp_screen()
	_check_last_screen()
	_check_screen_passes_light_and_stops_sight()
	_check_bell_still_calls_every_reachable_guard_past_a_screen()
	_check_plate_still_calls_only_the_nearest_guard_past_a_screen()
	_check_a_screen_calls_nobody()


func _check_screen_identity() -> void:
	var layouts := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) != "Screen Wing":
			continue
		var layout := "|".join(puzzle["rows"])
		var title := str(puzzle["title"])
		if layouts.has(layout):
			layout_ok = false
		if titles.has(title):
			title_ok = false
		layouts[layout] = title
		titles[title] = true
	_check(layout_ok, "each screen room has its own layout")
	_check(title_ok, "each screen room has its own name")


func _screen_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Screen Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_screens() -> void:
	var clean := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Screen Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("E"):
				clean = false
		var state := Puzzles.initial_state(i)
		for y in state["h"]:
			for x in state["w"]:
				if Rules.tile_at(state, x, y) == Rules.Tile.SCREEN:
					clean = false
	_check(clean, "earlier wings have no screens")


func _check_screen_watched_steps() -> void:
	var cases := [
		["The First Screen", "R R R D", 4, 2],
		["The Lit Screen", "L U", 2, 3],
		["The Closed Road", "R R R R D", 5, 2],
		["The Far Light", "R R R R R R R D", 8, 2],
		["The Second Lamp", "R R U", 3, 3],
		["The Last Screen", "R R D", 3, 2],
	]
	for entry in cases:
		_expect_watched_loss_at(_screen_room(str(entry[0])), str(entry[1]), int(entry[2]), int(entry[3]))


func _screen_gap_ok(state: Dictionary, puzzle: Dictionary, gap: Vector2i) -> bool:
	var cursor := Rules.clone(state)
	var saw := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == gap:
				var lit: Dictionary = Rules.light_map(cursor)
				saw = lit.has(gap) and not Rules.watched_tiles(cursor, lit).has(gap)
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			return false
		cursor = out["state"]
	return saw


func _screen_stepped(state: Dictionary, puzzle: Dictionary, cell: Vector2i) -> bool:
	var cursor := Rules.clone(state)
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == cell:
				return true
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			return false
		cursor = out["state"]
	return false


func _after_first_snuff(state: Dictionary, puzzle: Dictionary) -> Dictionary:
	var cursor := Rules.clone(state)
	for action in puzzle["solution"]:
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			return {}
		cursor = out["state"]
		if str(action["type"]) == "toggle" and not bool(cursor["lamps"][int(action["lamp"])]["lit"]):
			return cursor
	return {}


func _check_screen_substitute(title: String, cell: Vector2i, gap: Vector2i, step_on_screen: bool) -> void:
	var index := _screen_room(title)
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(Rules.tile_at(state, cell.x, cell.y) == Rules.Tile.SCREEN, title + " is a screen")
	_check(lit.has(cell) and lit.has(gap) and not Rules.watched_tiles(state, lit).has(gap), title + " lights the gap and hides it")
	_check(_spec_result(state, spec) == "win", title + " clears")
	_check(_screen_gap_ok(state, puzzle, gap), title + " crosses a lit unwatched gap")
	_check(_screen_stepped(state, puzzle, cell) == step_on_screen, title + " steps on the screen only when the room says so")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(not Rules.light_map(shade).has(gap) and _spec_result(shade, spec) == "darkgap", title + " goes dark behind a shade")
	var sill := _with_tile(state, cell.x, cell.y, Rules.Tile.SILL)
	_check(Rules.light_map(sill).has(cell) and not Rules.light_map(sill).has(gap) and _spec_result(sill, spec) == "darkgap", title + " leaves a lit sill and a dark gap")
	var wall := _with_tile(state, cell.x, cell.y, Rules.Tile.WALL)
	_check(not Rules.light_map(wall).has(gap) and _spec_result(wall, spec) == "darkgap", title + " goes dark behind a wall")
	var pane := _with_tile(state, cell.x, cell.y, Rules.Tile.PANE)
	_check(Rules.light_map(pane).has(gap) and Rules.watched_tiles(pane).has(gap) and _spec_result(pane, spec) == "watched", title + " is watched through a pane")
	var curtain := _with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN)
	var called := _after_first_snuff(state, puzzle)
	var curtain_called := _with_tile(called, cell.x, cell.y, Rules.Tile.CURTAIN)
	var screen_path: Array = Rules.planned_path(called, 0)
	var curtain_path: Array = Rules.planned_path(curtain_called, 0)
	_check(
		Rules.light_map(curtain).has(gap) and not Rules.watched_tiles(curtain).has(gap) and _path_has(curtain_path, cell) and not _path_has(screen_path, cell) and curtain_path.size() < screen_path.size() and _spec_result(curtain, spec) == "guard",
		title + " lets a curtain hide the gap, and the guard takes that short road"
	)
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(not Rules.light_map(grate).has(cell) and Rules.light_map(grate).has(gap) and _spec_result(grate, spec) == "win", title + " still clears with a grate")


func _check_first_screen() -> void:
	_check_screen_substitute("The First Screen", Vector2i(4, 2), Vector2i(4, 1), false)


func _check_closed_road() -> void:
	var index := _screen_room("The Closed Road")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var gap := Vector2i(5, 1)
	var cursor := Rules.clone(state)
	var crossed_first := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == gap:
				var guard: Dictionary = cursor["guards"][0]
				crossed_first = int(guard["x"]) == 5 and int(guard["y"]) == 4 and not bool(guard["alert"])
				break
		var out: Dictionary = Rules.apply(cursor, action)
		cursor = out["state"]
	_check(crossed_first, "the closed road crosses before the called guard arrives")
	_check_screen_substitute("The Closed Road", Vector2i(5, 2), gap, false)


func _check_far_light() -> void:
	_check_screen_substitute("The Far Light", Vector2i(8, 2), Vector2i(8, 1), false)


func _check_second_lamp_screen() -> void:
	var index := _screen_room("The Second Lamp")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	_check(state["lamps"].size() == 2 and bool(state["lamps"][1]["lit"]), "the second screen lamp starts lit")
	var shade := _with_tile(state, 3, 3, Rules.Tile.SHADE)
	_check(not Rules.light_map(shade).has(Vector2i(3, 4)), "a shade stops the second lamp")
	_check_screen_substitute("The Second Lamp", Vector2i(3, 3), Vector2i(3, 4), false)
	var cursor := Rules.clone(state)
	var kept := false
	for action in puzzle["solution"]:
		var out: Dictionary = Rules.apply(cursor, action)
		cursor = out["state"]
		if out["result"] == Rules.Result.WIN:
			kept = bool(cursor["lamps"][1]["lit"]) and not bool(cursor["lamps"][0]["lit"])
	_check(kept, "the second screen lamp stays lit")


func _check_last_screen() -> void:
	_check_screen_substitute("The Last Screen", Vector2i(3, 2), Vector2i(3, 1), false)


func _check_lit_screen() -> void:
	var index := _screen_room("The Lit Screen")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := Vector2i(2, 3)
	var gap := Vector2i(2, 2)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(Rules.tile_at(state, cell.x, cell.y) == Rules.Tile.SCREEN and lit.has(cell), "the lit screen starts lit")
	_check(_spec_result(state, "L U") == "watched", "the step before the snuff fails on the lit screen")
	var cursor := Rules.clone(state)
	var entered_dark := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == cell:
				entered_dark = not Rules.light_map(cursor).has(cell)
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			_check(false, "the lit screen solution failed")
			return
		cursor = out["state"]
	_check(entered_dark and Rules.is_win(cursor), "snuff, then step onto the screen")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(
		_spec_result(shade, "L U") == "stop" and not Rules.light_map(shade).has(gap) and _spec_result(shade, "L U U") == "darkgap" and _spec_result(shade, spec) == "darkgap",
		"a shade stays dark, so the early step succeeds and the tile past it fails"
	)
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(
		_spec_result(grate, "L U") == "stop" and not Rules.light_map(grate).has(cell) and _spec_result(grate, "L U U") == "guard",
		"a grate stays dark, so the early step succeeds and the guard catches it"
	)
	var curtain := _with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN)
	var called := _after_first_snuff(state, puzzle)
	var curtain_path: Array = Rules.planned_path(_with_tile(called, cell.x, cell.y, Rules.Tile.CURTAIN), 0)
	_check(
		_spec_result(curtain, "L U") == "watched" and Rules.light_map(curtain).has(cell) and _path_has(curtain_path, cell) and _spec_result(curtain, spec) == "guard",
		"a curtain is lit, so the early step fails, and the guard catches the later line"
	)
	var sill := _with_tile(state, cell.x, cell.y, Rules.Tile.SILL)
	_check(Rules.light_map(sill).has(cell) and not Rules.light_map(sill).has(gap) and _spec_result(sill, spec) == "darkgap", "a sill is lit and stops the light")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE), spec) == "pane", "a pane cannot be entered")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.WALL), spec) == "wall", "a wall in the lit screen cannot be entered")


func _check_screen_passes_light_and_stops_sight() -> void:
	var rows := PackedStringArray(["######", "#SEX.#", "##.#.#", "#....#", "######"])
	var lamps: Array = [{"x": 2, "y": 2, "facing": "n", "radius": 2, "lit": true}]
	var guards: Array = [{"x": 2, "y": 2, "vision": 4, "rail": [Vector2i(2, 2)]}]
	var state := Rules.build(rows, lamps, guards)
	var cell := Vector2i(2, 1)
	var past := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	_check(
		Rules.tile_at(state, cell.x, cell.y) == Rules.Tile.SCREEN and lit.has(cell) and lit.has(past) and not Rules.watched_tiles(state, lit).has(past) and not Rules.guard_walkable(state, cell.x, cell.y),
		"a screen is lit, lets the light through, stops the sight, and a guard cannot enter it"
	)
	var refused: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	_check(refused["result"] == Rules.Result.LOSS and refused["reason"] == "watched", "stepping onto a screen a guard is watching loses")
	var quiet := Rules.clone(state)
	quiet["guards"][0]["vision"] = 0
	var lit_step: Dictionary = Rules.apply(quiet, {"type": "move", "dx": 1, "dy": 0})
	var stayed: Dictionary = lit_step["state"]["player"]
	_check(
		lit_step["result"] == Rules.Result.ILLEGAL and lit_step["reason"] == "lit" and stayed["x"] == 1 and stayed["y"] == 1,
		"an unwatched lit screen is refused"
	)
	var dark := Rules.clone(state)
	dark["lamps"][0]["lit"] = false
	var stepped: Dictionary = Rules.apply(dark, {"type": "move", "dx": 1, "dy": 0})
	var stood: Dictionary = stepped["state"]["player"]
	_check(
		stepped["result"] == Rules.Result.OK and int(stood["x"]) == cell.x and int(stood["y"]) == cell.y and int(stepped["called"]) == -1,
		"you can step on a dark screen, and the step calls nobody"
	)
	var curtain := _with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN)
	var curtain_lit: Dictionary = Rules.light_map(curtain)
	_check(curtain_lit.has(cell) and curtain_lit.has(past) and not Rules.watched_tiles(curtain, curtain_lit).has(past) and Rules.guard_walkable(curtain, cell.x, cell.y), "a curtain is lit, lets the light through, stops the sight, and a guard can step on it")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	var shade_lit: Dictionary = Rules.light_map(shade)
	_check(not shade_lit.has(cell) and not shade_lit.has(past) and not Rules.guard_walkable(shade, cell.x, cell.y), "a shade stays dark, stops the light, and a guard cannot enter it")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	var grate_lit: Dictionary = Rules.light_map(grate)
	_check(not grate_lit.has(cell) and grate_lit.has(past) and not Rules.guard_walkable(grate, cell.x, cell.y), "a grate stays dark, lets the light through, and a guard cannot enter it")
	var sill := _with_tile(state, cell.x, cell.y, Rules.Tile.SILL)
	var sill_lit: Dictionary = Rules.light_map(sill)
	_check(sill_lit.has(cell) and not sill_lit.has(past) and not Rules.guard_walkable(sill, cell.x, cell.y), "a sill is lit, stops the light, and a guard cannot enter it")
	var pane := _with_tile(state, cell.x, cell.y, Rules.Tile.PANE)
	var pane_lit: Dictionary = Rules.light_map(pane)
	_check(pane_lit.has(past) and Rules.watched_tiles(pane, pane_lit).has(past) and not Rules.guard_walkable(pane, cell.x, cell.y), "a pane lets the light and the sight through, and nobody can step on it")
	var looking := Rules.clone(state)
	looking["guards"][0]["x"] = cell.x
	looking["guards"][0]["y"] = cell.y
	_check(Rules.watched_tiles(looking).has(past), "a guard standing on a screen can still look out")


func _check_bell_still_calls_every_reachable_guard_past_a_screen() -> void:
	var rows := PackedStringArray(["########", "#S.B...#", "###E####", "#......#", "########"])
	var guards: Array = [
		{"x": 5, "y": 1, "vision": 2, "rail": [Vector2i(5, 1)]},
		{"x": 4, "y": 3, "vision": 2, "rail": [Vector2i(4, 3)]},
	]
	var state := Rules.build(rows, [], guards)
	var bell := _find_tile(state, Rules.Tile.BELL)
	var screen := _find_tile(state, Rules.Tile.SCREEN)
	_check(Rules.bell_guards(state, bell.x, bell.y) == [0], "a screen is not a floor path, so the keeper behind it is not called")
	var opened := _with_tile(state, screen.x, screen.y, Rules.Tile.FLOOR)
	_check(Rules.bell_guards(opened, bell.x, bell.y) == [0, 1], "opening the screen's cell to floor calls the keeper who can then reach the bell")
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	var near: Dictionary = stepped["state"]["guards"][0]
	var far: Dictionary = stepped["state"]["guards"][1]
	_check(
		stepped["result"] == Rules.Result.OK and bool(near["alert"]) and not bool(far["alert"]),
		"a bell still calls every guard who has a floor path, and a screen is not that path"
	)


func _check_plate_still_calls_only_the_nearest_guard_past_a_screen() -> void:
	var rows := PackedStringArray(["########", "#S.P...#", "###E####", "#......#", "########"])
	var guards: Array = [
		{"x": 6, "y": 1, "vision": 2, "rail": [Vector2i(6, 1)]},
		{"x": 3, "y": 3, "vision": 2, "rail": [Vector2i(3, 3)]},
	]
	var state := Rules.build(rows, [], guards)
	var plate := _find_tile(state, Rules.Tile.PLATE)
	var far: Dictionary = state["guards"][0]
	var near: Dictionary = state["guards"][1]
	var far_dist := absi(int(far["x"]) - plate.x) + absi(int(far["y"]) - plate.y)
	var near_dist := absi(int(near["x"]) - plate.x) + absi(int(near["y"]) - plate.y)
	_check(near_dist < far_dist and not Rules.guard_walkable(state, 3, 2), "the nearer keeper is blocked by the screen and is still nearer")
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	var far_after: Dictionary = stepped["state"]["guards"][0]
	var near_after: Dictionary = stepped["state"]["guards"][1]
	_check(
		stepped["result"] == Rules.Result.OK and int(stepped["called"]) == 1 and bool(near_after["alert"]) and not bool(far_after["alert"]),
		"a plate still calls only the nearest guard past a screen"
	)


func _check_a_screen_calls_nobody() -> void:
	var rows := PackedStringArray(["#####", "#S.E#", "#####"])
	var state := Rules.build(rows, [], [{"x": 1, "y": 1, "vision": 2, "rail": [Vector2i(1, 1)]}])
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var onto: Dictionary = Rules.apply(stepped["state"], {"type": "move", "dx": 1, "dy": 0})
	var guard: Dictionary = onto["state"]["guards"][0]
	_check(
		onto["result"] == Rules.Result.OK and int(onto["called"]) == -1 and not bool(guard["alert"]) and not bool(guard["holding"]),
		"a screen calls nobody and is never a hold"
	)


func _check_glaze_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Glaze Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_glaze_rooms() -> void:
	_check_glaze_identity()
	_check_earlier_wings_have_no_glazes()
	_check_watched_gap()
	_check_lit_glaze()
	_check_open_sight()
	_check_glaze_closed_road()
	_check_second_lamp_glaze()
	_check_last_glaze()
	_check_glaze_passes_light_and_sight()
	_check_bell_still_calls_every_reachable_guard_past_a_glaze()
	_check_plate_still_calls_only_the_nearest_guard_past_a_glaze()
	_check_a_glaze_calls_nobody()


func _check_glaze_identity() -> void:
	var layouts := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) != "Glaze Wing":
			continue
		var layout := "|".join(puzzle["rows"])
		var title := str(puzzle["title"])
		if layouts.has(layout):
			layout_ok = false
		if titles.has(title):
			title_ok = false
		layouts[layout] = title
		titles[title] = true
	_check(layout_ok, "each glaze room has its own layout")
	_check(title_ok, "each glaze room has its own name")


func _glaze_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Glaze Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_glazes() -> void:
	var clean := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Glaze Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("Z"):
				clean = false
		var state := Puzzles.initial_state(i)
		for y in state["h"]:
			for x in state["w"]:
				if Rules.tile_at(state, x, y) == Rules.Tile.GLAZE:
					clean = false
	_check(clean, "earlier wings have no glazes")


func _visited(state: Dictionary, puzzle: Dictionary, cell: Vector2i) -> bool:
	var cursor := Rules.clone(state)
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == cell:
				return true
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			return false
		cursor = out["state"]
	return false


func _stepped_on_while_dark(state: Dictionary, puzzle: Dictionary, cell: Vector2i) -> bool:
	var cursor := Rules.clone(state)
	var dark := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == cell:
				dark = not Rules.light_map(cursor).has(cell)
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			return false
		cursor = out["state"]
	return dark


func _check_watched_gap() -> void:
	var index := _glaze_room("The Watched Gap")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.GLAZE)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	var take := "D R L L D D D R R T0 R R U"
	_check(Rules.tile_at(state, cell.x, cell.y) == Rules.Tile.GLAZE and lit.has(cell) and lit.has(gap) and Rules.watched_tiles(state, lit).has(gap), "the watched gap is lit and watched through the glaze")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, cell) and not _visited(state, puzzle, gap) and _stepped_on_while_dark(state, puzzle, cell), "snuff, then leave by a cell the guard is not watching, without entering the gap")
	_check(_spec_result(state, "D R") == "watched", "stepping into the watched gap loses")
	var screen := _with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN)
	var screen_lit: Dictionary = Rules.light_map(screen)
	_check(screen_lit.has(gap) and not Rules.watched_tiles(screen, screen_lit).has(gap) and _spec_result(screen, take) == "guard", "a screen hides the gap, and the substitute who takes it is caught")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(not Rules.light_map(shade).has(gap) and _spec_result(shade, "D R") == "darkgap", "a shade stops the light, so the line that needed the guard to see the gap fails")
	var pane := _with_tile(state, cell.x, cell.y, Rules.Tile.PANE)
	_check(Rules.watched_tiles(pane).has(gap) and _spec_result(pane, spec) == "pane", "a pane lets the guard see the gap, and the scripted step onto that cell cannot be entered")
	var curtain := _with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN)
	var called := _after_first_snuff(state, puzzle)
	var glaze_path: Array = Rules.planned_path(called, 0)
	var curtain_path: Array = Rules.planned_path(_with_tile(called, cell.x, cell.y, Rules.Tile.CURTAIN), 0)
	_check(not Rules.watched_tiles(curtain).has(gap) and _path_has(curtain_path, cell) and not _path_has(glaze_path, cell) and curtain_path.size() < glaze_path.size() and _spec_result(curtain, spec) == "guard", "a curtain is a path, so the guard takes the short road and catches you")
	var sill := _with_tile(state, cell.x, cell.y, Rules.Tile.SILL)
	var sill_lit: Dictionary = Rules.light_map(sill)
	_check(sill_lit.has(cell) and not sill_lit.has(gap) and _spec_result(sill, "D R") == "darkgap", "a sill stops the light")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(not Rules.light_map(grate).has(cell) and _spec_result(grate, "D R D") == "stop" and _spec_result(grate, "D R D T0 R") == "guard", "a grate stays dark, so the step onto it before the snuff succeeds and the guard catches it")


func _check_lit_glaze() -> void:
	var index := _glaze_room("The Lit Glaze")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.GLAZE)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(Rules.tile_at(state, cell.x, cell.y) == Rules.Tile.GLAZE and lit.has(cell), "the lit glaze starts lit")
	_check(_spec_result(state, "L U") == "watched", "the step before the snuff fails on the lit glaze")
	_check(_spec_result(state, spec) == "win" and _stepped_on_while_dark(state, puzzle, cell), "snuff, then step onto the glaze")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(_spec_result(shade, "L U") == "stop" and not Rules.light_map(shade).has(gap) and _spec_result(shade, "L U U") == "darkgap" and _spec_result(shade, spec) == "darkgap", "a shade stays dark, so the early step succeeds and the tile past it is dark")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(_spec_result(grate, "L U") == "stop" and not Rules.light_map(grate).has(cell) and _spec_result(grate, "L U U") == "guard", "a grate stays dark, so the early step succeeds and the guard catches it")
	var screen := _with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN)
	_check(_spec_result(screen, "L U") == "watched" and _spec_result(state, "U") == "watched" and _spec_result(screen, "U") == "lit", "a screen is also lit, so the early step fails, and the screen hides the line the guard must see")
	var curtain := _with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN)
	_check(_spec_result(curtain, "L U") == "watched" and Rules.light_map(curtain).has(cell) and _spec_result(curtain, spec) == "guard", "a curtain is lit, so the early step fails, and after the snuff the curtain is a path")
	var sill := _with_tile(state, cell.x, cell.y, Rules.Tile.SILL)
	var sill_lit: Dictionary = Rules.light_map(sill)
	_check(sill_lit.has(cell) and not sill_lit.has(gap) and _spec_result(sill, spec) == "darkgap", "a sill is lit and stops the light")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE), spec) == "pane", "a pane cannot be entered")


func _check_open_sight() -> void:
	var index := _glaze_room("The Open Sight")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.GLAZE)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(gap) and Rules.watched_tiles(state, lit).has(gap) and _spec_result(state, "D R") == "watched", "the guard sees a lit tile through the glaze and catches the wrong step")
	_check(_spec_result(state, spec) == "win" and not _visited(state, puzzle, gap) and _stepped_on_while_dark(state, puzzle, cell), "the solution never takes that tile, and steps on the glaze after the snuff")
	var screen := _with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN)
	_check(Rules.light_map(screen).has(gap) and not Rules.watched_tiles(screen).has(gap) and _spec_result(screen, "D R") == "stop", "a screen hides that tile, so the wrong step is legal and misses the guard")
	var pane := _with_tile(state, cell.x, cell.y, Rules.Tile.PANE)
	_check(Rules.watched_tiles(pane).has(gap) and _spec_result(pane, spec) == "pane", "a pane lets him see, and the solution cannot stand on the pane")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(not Rules.light_map(shade).has(gap) and _spec_result(shade, "D R") == "darkgap", "a shade leaves the far tile dark, so he cannot see it")
	var curtain := _with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN)
	_check(Rules.light_map(curtain).has(gap) and not Rules.watched_tiles(curtain).has(gap) and _spec_result(curtain, "D R") == "stop", "a curtain stops the sight")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(not Rules.light_map(grate).has(cell) and Rules.light_map(grate).has(gap) and not Rules.watched_tiles(grate).has(gap) and _spec_result(grate, "D R") == "stop", "a grate stays dark, so sight stops there")
	var sill := _with_tile(state, cell.x, cell.y, Rules.Tile.SILL)
	var sill_lit: Dictionary = Rules.light_map(sill)
	_check(sill_lit.has(cell) and not sill_lit.has(gap) and not Rules.watched_tiles(sill).has(gap) and _spec_result(sill, "D R") == "darkgap", "a sill stops both the light and the sight")


func _check_glaze_closed_road() -> void:
	var index := _glaze_room("The Closed Road")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.GLAZE)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var spec := _solution_spec(puzzle)
	_check(_spec_result(state, spec) == "win" and not Rules.guard_walkable(state, cell.x, cell.y), "the guard cannot enter the glaze, so you leave on the short road")
	var curtain := _with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN)
	var called := _after_first_snuff(state, puzzle)
	var glaze_path: Array = Rules.planned_path(called, 0)
	var curtain_path: Array = Rules.planned_path(_with_tile(called, cell.x, cell.y, Rules.Tile.CURTAIN), 0)
	_check(Rules.guard_walkable(curtain, cell.x, cell.y) and _path_has(curtain_path, cell) and not _path_has(glaze_path, cell) and curtain_path.size() < glaze_path.size() and _spec_result(curtain, spec) == "guard", "a curtain is a path, so he takes the short road and catches you")
	var screen := _with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN)
	_check(not Rules.guard_walkable(screen, cell.x, cell.y) and Rules.light_map(screen).has(gap) and not Rules.watched_tiles(screen).has(gap) and _spec_result(screen, "D R") == "stop", "a screen stops the sight, so the tile you could cross is unwatched")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE), spec) == "pane", "a pane cannot be entered")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(not Rules.light_map(shade).has(gap) and _spec_result(shade, "D R") == "darkgap", "a shade stops the light, so the far tile is dark")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(not Rules.light_map(grate).has(cell) and Rules.light_map(grate).has(gap), "a grate stays dark")
	var sill := _with_tile(state, cell.x, cell.y, Rules.Tile.SILL)
	var sill_lit: Dictionary = Rules.light_map(sill)
	_check(sill_lit.has(cell) and not sill_lit.has(gap), "a sill stops the light")


func _check_second_lamp_glaze() -> void:
	var index := _glaze_room("The Second Lamp")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.GLAZE)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(state["lamps"].size() == 2 and bool(state["lamps"][1]["lit"]) and lit.has(gap) and Rules.watched_tiles(state, lit).has(gap), "the second lamp lights the gap, and the guard sees it through the glaze")
	var cursor := Rules.clone(state)
	var kept := false
	for action in puzzle["solution"]:
		var out: Dictionary = Rules.apply(cursor, action)
		cursor = out["state"]
		if out["result"] == Rules.Result.WIN:
			kept = bool(cursor["lamps"][0]["lit"]) and not bool(cursor["lamps"][1]["lit"])
	_check(kept and _spec_result(state, spec) == "win" and _stepped_on_while_dark(state, puzzle, cell), "you snuff that lamp before you cross")
	var screen := _with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN)
	_check(Rules.light_map(screen).has(gap) and not Rules.watched_tiles(screen).has(gap) and _spec_result(screen, "D R") == "stop" and _spec_result(state, "D R") == "watched", "a screen lets the light through but hides the gap, so the guard misses that step")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(not Rules.light_map(shade).has(gap) and _spec_result(shade, "D R") == "darkgap", "a shade stops the second lamp, so the gap is dark")
	var pane := _with_tile(state, cell.x, cell.y, Rules.Tile.PANE)
	_check(Rules.watched_tiles(pane).has(gap) and _spec_result(pane, spec) == "pane", "a pane lets him see the gap but cannot be entered")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), spec) == "guard", "a curtain stops the sight and is a path")
	var sill := _with_tile(state, cell.x, cell.y, Rules.Tile.SILL)
	_check(Rules.light_map(sill).has(cell) and not Rules.light_map(sill).has(gap), "a sill stops the light")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(not Rules.light_map(grate).has(cell) and _spec_result(grate, "D R D") == "stop" and _spec_result(grate, "D R D T1 R") == "guard", "a grate stays dark, so the early step succeeds and the guard catches it")


func _check_last_glaze() -> void:
	var index := _glaze_room("The Last Glaze")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.GLAZE)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	var take := "D R L L D D D R R T0 R R U"
	_check(lit.has(cell) and lit.has(gap) and Rules.watched_tiles(state, lit).has(gap), "the gap beyond the last glaze is lit and watched")
	_check(_spec_result(state, spec) == "win" and not _visited(state, puzzle, gap) and _visited(state, puzzle, cell) and _stepped_on_while_dark(state, puzzle, cell), "leave without stepping on the lit glaze")
	var screen := _with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN)
	_check(not Rules.watched_tiles(screen).has(gap) and _spec_result(screen, take) == "guard" and _spec_result(state, take) == "watched", "a screen makes that gap unwatched, and the substitute who takes it is caught")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(not Rules.light_map(shade).has(gap) and _spec_result(shade, "D R") == "darkgap", "a shade leaves the gap dark, so the guard cannot see that line")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), spec) == "guard", "a curtain is a path, so the guard takes the short road")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE), spec) == "pane", "a pane cannot be entered")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(not Rules.light_map(grate).has(cell) and _spec_result(grate, "D R D") == "stop", "a grate stays dark")
	var sill := _with_tile(state, cell.x, cell.y, Rules.Tile.SILL)
	_check(Rules.light_map(sill).has(cell) and not Rules.light_map(sill).has(gap), "a sill stops the light")


func _check_glaze_passes_light_and_sight() -> void:
	var rows := PackedStringArray(["######", "#SZX.#", "##.#.#", "#....#", "######"])
	var lamps: Array = [{"x": 2, "y": 2, "facing": "n", "radius": 2, "lit": true}]
	var guards: Array = [{"x": 2, "y": 2, "vision": 4, "rail": [Vector2i(2, 2)]}]
	var state := Rules.build(rows, lamps, guards)
	var cell := Vector2i(2, 1)
	var past := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	_check(
		Rules.tile_at(state, cell.x, cell.y) == Rules.Tile.GLAZE and lit.has(cell) and lit.has(past) and Rules.watched_tiles(state, lit).has(past) and not Rules.guard_walkable(state, cell.x, cell.y),
		"a glaze is lit, lets the light through, lets the sight through, and a guard cannot enter it"
	)
	var refused: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	_check(refused["result"] == Rules.Result.LOSS and refused["reason"] == "watched", "stepping onto a glaze a guard is watching loses")
	var quiet := Rules.clone(state)
	quiet["guards"][0]["vision"] = 0
	var lit_step: Dictionary = Rules.apply(quiet, {"type": "move", "dx": 1, "dy": 0})
	var stayed: Dictionary = lit_step["state"]["player"]
	_check(
		lit_step["result"] == Rules.Result.ILLEGAL and lit_step["reason"] == "lit" and stayed["x"] == 1 and stayed["y"] == 1,
		"an unwatched lit glaze is refused"
	)
	var dark := Rules.clone(state)
	dark["lamps"][0]["lit"] = false
	var stepped: Dictionary = Rules.apply(dark, {"type": "move", "dx": 1, "dy": 0})
	var stood: Dictionary = stepped["state"]["player"]
	_check(
		stepped["result"] == Rules.Result.OK and int(stood["x"]) == cell.x and int(stood["y"]) == cell.y and int(stepped["called"]) == -1 and not Rules.watched_tiles(stepped["state"]).has(past),
		"a dark glaze is ordinary dark floor, so you can step on it and sight stops there"
	)
	var screen := _with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN)
	var screen_lit: Dictionary = Rules.light_map(screen)
	_check(screen_lit.has(cell) and screen_lit.has(past) and not Rules.watched_tiles(screen, screen_lit).has(past), "a screen still stops the sight, even when the light passes")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(not Rules.light_map(shade).has(cell) and not Rules.light_map(shade).has(past), "a shade still stays dark and stops the light")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(not Rules.light_map(grate).has(cell) and Rules.light_map(grate).has(past) and not Rules.watched_tiles(grate).has(past), "a grate still stays dark, lets the light through, and blocks sight")
	var sill := _with_tile(state, cell.x, cell.y, Rules.Tile.SILL)
	_check(Rules.light_map(sill).has(cell) and not Rules.light_map(sill).has(past), "a sill still stops the light")
	var curtain := _with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN)
	_check(Rules.light_map(curtain).has(past) and not Rules.watched_tiles(curtain).has(past) and Rules.guard_walkable(curtain, cell.x, cell.y), "a curtain still stops the sight and a guard can still enter it")
	var pane := _with_tile(state, cell.x, cell.y, Rules.Tile.PANE)
	_check(Rules.light_map(pane).has(past) and Rules.watched_tiles(pane).has(past) and not Rules.guard_walkable(pane, cell.x, cell.y), "a pane still lets the light and the sight through")


func _check_bell_still_calls_every_reachable_guard_past_a_glaze() -> void:
	var rows := PackedStringArray(["########", "#S.B...#", "###Z####", "#......#", "########"])
	var guards: Array = [
		{"x": 5, "y": 1, "vision": 2, "rail": [Vector2i(5, 1)]},
		{"x": 4, "y": 3, "vision": 2, "rail": [Vector2i(4, 3)]},
	]
	var state := Rules.build(rows, [], guards)
	var bell := _find_tile(state, Rules.Tile.BELL)
	var glaze := _find_tile(state, Rules.Tile.GLAZE)
	_check(Rules.bell_guards(state, bell.x, bell.y) == [0], "a glaze is not a floor path, so the keeper behind it is not called")
	var opened := _with_tile(state, glaze.x, glaze.y, Rules.Tile.FLOOR)
	_check(Rules.bell_guards(opened, bell.x, bell.y) == [0, 1], "opening the glaze's cell to floor calls the keeper who can then reach the bell")


func _check_plate_still_calls_only_the_nearest_guard_past_a_glaze() -> void:
	var rows := PackedStringArray(["########", "#S.P...#", "###Z####", "#......#", "########"])
	var guards: Array = [
		{"x": 6, "y": 1, "vision": 2, "rail": [Vector2i(6, 1)]},
		{"x": 3, "y": 3, "vision": 2, "rail": [Vector2i(3, 3)]},
	]
	var state := Rules.build(rows, [], guards)
	var plate := _find_tile(state, Rules.Tile.PLATE)
	var far: Dictionary = state["guards"][0]
	var near: Dictionary = state["guards"][1]
	var far_dist := absi(int(far["x"]) - plate.x) + absi(int(far["y"]) - plate.y)
	var near_dist := absi(int(near["x"]) - plate.x) + absi(int(near["y"]) - plate.y)
	_check(near_dist < far_dist and not Rules.guard_walkable(state, 3, 2), "the nearer keeper is blocked by the glaze and is still nearer")
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	_check(stepped["result"] == Rules.Result.OK and int(stepped["called"]) == 1, "a plate still calls only the nearest guard past a glaze")


func _check_a_glaze_calls_nobody() -> void:
	var rows := PackedStringArray(["#####", "#S.Z#", "#####"])
	var state := Rules.build(rows, [], [{"x": 1, "y": 1, "vision": 2, "rail": [Vector2i(1, 1)]}])
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var onto: Dictionary = Rules.apply(stepped["state"], {"type": "move", "dx": 1, "dy": 0})
	var guard: Dictionary = onto["state"]["guards"][0]
	_check(
		onto["result"] == Rules.Result.OK and int(onto["called"]) == -1 and not bool(guard["alert"]) and not bool(guard["holding"]),
		"a glaze calls nobody and is never a hold"
	)


func _check_mica_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Mica Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_mica_rooms() -> void:
	_check_mica_identity()
	_check_earlier_wings_have_no_micas()
	_check_mica_watched_steps()
	_check_mica_dark_step()
	_check_seen_gap_mica()
	_check_passed_lamp()
	_check_mica_long_road()
	_check_early_catch()
	_check_last_mica()
	_check_mica_passes_light_and_sight()
	_check_bell_still_calls_every_reachable_guard_past_a_mica()
	_check_plate_still_calls_only_the_nearest_guard_past_a_mica()
	_check_a_mica_calls_nobody()


func _check_mica_identity() -> void:
	var layouts := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) != "Mica Wing":
			continue
		var layout := "|".join(puzzle["rows"])
		var title := str(puzzle["title"])
		if layouts.has(layout):
			layout_ok = false
		if titles.has(title):
			title_ok = false
		layouts[layout] = title
		titles[title] = true
	_check(layout_ok, "each mica room has its own layout")
	_check(title_ok, "each mica room has its own name")


func _mica_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Mica Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_micas() -> void:
	var clean := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Mica Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("M"):
				clean = false
		var state := Puzzles.initial_state(i)
		for y in state["h"]:
			for x in state["w"]:
				if Rules.tile_at(state, x, y) == Rules.Tile.MICA:
					clean = false
	_check(clean, "earlier wings have no micas")


func _check_mica_watched_steps() -> void:
	var cases := [
		["The Dark Step", "R", 5, 5],
		["The Seen Gap", "U L", 5, 4],
		["The Passed Lamp", "R R", 3, 4],
		["The Long Road", "R R T0 U R R R D D", 6, 3],
		["The Early Catch", "R", 5, 5],
		["The Last Mica", "U R R R R R", 6, 1],
	]
	for entry in cases:
		_expect_watched_loss_at(_mica_room(str(entry[0])), str(entry[1]), int(entry[2]), int(entry[3]))


func _mica_step_while_covered(state: Dictionary, puzzle: Dictionary, cell: Vector2i) -> bool:
	var cursor := Rules.clone(state)
	var covered := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == cell:
				for lamp in cursor["lamps"]:
					if bool(lamp["lit"]) and Rules.in_diamond(lamp, cell.x, cell.y):
						covered = true
		var out: Dictionary = Rules.apply(cursor, action)
		if out["result"] != Rules.Result.OK and out["result"] != Rules.Result.WIN:
			return false
		cursor = out["state"]
	return covered


func _check_mica_dark_step() -> void:
	var index := _mica_room("The Dark Step")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.MICA)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(not lit.has(cell) and Rules.in_diamond(state["lamps"][0], cell.x, cell.y) and lit.has(gap) and Rules.watched_tiles(state, lit).has(gap), "the dark step stands on a dark mica, and the gap beyond it is lit and watched")
	_check(_spec_result(state, "U") == "stop" and _spec_result(state, spec) == "win" and _visited(state, puzzle, cell) and _visited(state, puzzle, gap) and _mica_step_while_covered(state, puzzle, cell), "you step onto the mica while the lamp is lit, then cross the lit gap")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GLAZE), "U") == "watched", "a glaze is lit, so that early step is watched")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(not Rules.light_map(shade).has(gap) and _spec_result(shade, spec) == "darkgap", "a shade leaves the gap dark")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(not Rules.watched_tiles(grate).has(gap) and _spec_result(grate, spec) == "win", "a grate does not let the guard see the gap, and that substitute still clears")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN), spec) == "watched", "a screen is lit, so the early step fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE), spec) == "pane", "a pane cannot be entered")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), spec) == "watched", "a curtain is lit, so the early step fails")
	var sill := _with_tile(state, cell.x, cell.y, Rules.Tile.SILL)
	_check(not Rules.light_map(sill).has(gap) and _spec_result(sill, spec) == "watched", "a sill stops the light, and the early step onto the lit sill loses")


func _check_seen_gap_mica() -> void:
	var index := _mica_room("The Seen Gap")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.MICA)
	var seen := _find_tile(state, Rules.Tile.GAP)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(not lit.has(cell) and lit.has(seen) and Rules.watched_tiles(state, lit).has(seen), "the guard sees a lit tile through the dark mica")
	_check(_spec_result(state, spec) == "win" and not _visited(state, puzzle, seen) and _mica_step_while_covered(state, puzzle, cell), "the solution never takes that tile, and it steps on the mica while the lamp is lit")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(not Rules.light_map(shade).has(seen) and _spec_result(shade, spec) == "darkgap", "a shade leaves that tile dark")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(not Rules.watched_tiles(grate).has(seen) and _spec_result(grate, spec) == "win", "a grate hides that tile, and that substitute still clears")
	var screen := _with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN)
	_check(Rules.light_map(screen).has(cell) and not Rules.watched_tiles(screen).has(seen) and _spec_result(screen, spec) == "watched", "a screen is lit and stops the sight, so the early step fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GLAZE), spec) == "watched", "a glaze is lit, so the early step fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE), spec) == "pane", "a pane cannot be entered")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), spec) == "watched", "a curtain is lit, so the early step fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SILL), spec) == "watched", "a sill is lit, so the early step fails")


func _check_passed_lamp() -> void:
	var index := _mica_room("The Passed Lamp")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.MICA)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(state["lamps"].size() == 2 and lit.has(gap) and Rules.watched_tiles(state, lit).has(gap) and not lit.has(cell), "a second lamp's light passes the mica, and the guard sees the gap")
	var snuffed_first := false
	var crossed_after := false
	var cursor := Rules.clone(state)
	var lamp_off := false
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle" and int(action["lamp"]) == 1:
			lamp_off = bool(cursor["lamps"][1]["lit"])
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			if dest == gap and lamp_off and not bool(cursor["lamps"][1]["lit"]):
				crossed_after = not Rules.watched_tiles(cursor).has(gap) and Rules.light_map(cursor).has(gap)
		var out: Dictionary = Rules.apply(cursor, action)
		cursor = out["state"]
		if str(action["type"]) == "toggle" and int(action["lamp"]) == 1:
			snuffed_first = lamp_off and not bool(cursor["lamps"][1]["lit"])
	_check(snuffed_first and crossed_after and _spec_result(state, spec) == "win" and _mica_step_while_covered(state, puzzle, cell), "you snuff that lamp before you cross, and you step on the dark mica")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(not Rules.light_map(shade).has(gap) and _spec_result(shade, spec) == "darkgap", "a shade stops the second lamp")
	var screen := _with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN)
	_check(Rules.light_map(screen).has(gap) and not Rules.watched_tiles(screen).has(gap) and _spec_result(screen, spec) == "lit", "a screen hides the gap, and the step onto the lit screen is refused")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(not Rules.watched_tiles(grate).has(gap) and _spec_result(grate, spec) == "win", "a grate hides the gap, and that substitute still clears")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE), spec) == "pane", "a pane cannot be entered, and the solution steps on the mica")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GLAZE), spec) == "lit", "a glaze refuses the step onto that cell")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), spec) == "lit", "a curtain is lit, so that step is refused")
	_check(not Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.SILL)).has(gap) and _spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SILL), spec) == "darkgap", "a sill stops the light")


func _check_mica_long_road() -> void:
	var index := _mica_room("The Long Road")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.MICA)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var spec := _solution_spec(puzzle)
	_check(_spec_result(state, spec) == "win" and not Rules.guard_walkable(state, cell.x, cell.y) and _mica_step_while_covered(state, puzzle, cell) and _visited(state, puzzle, gap), "the guard cannot enter the mica, so you take the step he cannot")
	var called := _after_first_snuff(state, puzzle)
	var mica_path: Array = Rules.planned_path(called, 0)
	var curtain_path: Array = Rules.planned_path(_with_tile(called, cell.x, cell.y, Rules.Tile.CURTAIN), 0)
	var curtain := _with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN)
	_check(_path_has(curtain_path, cell) and not _path_has(mica_path, cell) and curtain_path.size() < mica_path.size() and _spec_result(curtain, spec) == "guard", "a curtain is a path, so he takes the short road")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(not Rules.light_map(shade).has(gap) and _spec_result(shade, spec) == "darkgap", "a shade leaves the gap dark")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GLAZE), spec) == "lit", "a glaze is lit, so the step the solution takes while the lamp is on fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN), spec) == "lit", "a screen is lit, so that step fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE), spec) == "pane", "a pane cannot be entered")
	_check(not Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.SILL)).has(gap) and _spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SILL), spec) == "darkgap", "a sill stops the light")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(not Rules.guard_walkable(grate, cell.x, cell.y) and _spec_result(grate, spec) == "win", "a grate is not a path either, so that substitute still clears")


func _check_early_catch() -> void:
	var index := _mica_room("The Early Catch")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.MICA)
	var spec := _solution_spec(puzzle)
	_check(_spec_result(state, "U") == "stop" and _spec_result(state, "U R") == "watched" and _spec_result(state, spec) == "win" and _mica_step_while_covered(state, puzzle, cell), "the early step onto the mica is legal, and a guard catches the wrong step past it")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GLAZE), "U") == "watched", "a glaze refuses that early step")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE), "U") == "pane", "a pane cannot be entered")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SHADE), spec) == "darkgap", "a shade leaves the gap beyond dark")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN), spec) == "watched", "a screen is lit, so the early step fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), spec) == "watched", "a curtain is lit, so the early step fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SILL), spec) == "watched", "a sill is lit, so the early step fails")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(not Rules.watched_tiles(grate).has(_find_tile(state, Rules.Tile.GAP)) and _spec_result(grate, spec) == "win", "a grate does not let the guard see the gap, and that substitute still clears")


func _check_last_mica() -> void:
	var index := _mica_room("The Last Mica")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.MICA)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(gap) and Rules.watched_tiles(state, lit).has(gap) and not lit.has(cell), "the gap beyond the last mica is watched")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, cell) and _visited(state, puzzle, gap) and _mica_step_while_covered(state, puzzle, cell), "leave by stepping on the dark mica")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GLAZE), spec) == "lit", "a glaze refuses that step")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(not Rules.light_map(shade).has(gap) and _spec_result(shade, spec) == "darkgap", "a shade leaves the gap dark")
	var called := _after_first_snuff(state, puzzle)
	var mica_path: Array = Rules.planned_path(called, 0)
	var curtain_path: Array = Rules.planned_path(_with_tile(called, cell.x, cell.y, Rules.Tile.CURTAIN), 0)
	_check(_path_has(curtain_path, cell) and not _path_has(mica_path, cell) and curtain_path.size() < mica_path.size() and _spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), spec) == "guard", "a curtain is a path, so he takes the short road")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN), spec) == "lit", "a screen is lit, so that step fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE), spec) == "pane", "a pane cannot be entered")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SILL), spec) == "darkgap", "a sill leaves the gap dark")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GRATE), spec) == "win", "a grate still clears the last mica")


func _check_mica_passes_light_and_sight() -> void:
	var rows := PackedStringArray(["######", "#SMX.#", "##.#.#", "#....#", "######"])
	var lamps: Array = [{"x": 2, "y": 2, "facing": "n", "radius": 2, "lit": true}]
	var guards: Array = [{"x": 2, "y": 2, "vision": 4, "rail": [Vector2i(2, 2)]}]
	var state := Rules.build(rows, lamps, guards)
	var cell := Vector2i(2, 1)
	var past := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	_check(
		Rules.tile_at(state, cell.x, cell.y) == Rules.Tile.MICA and not lit.has(cell) and lit.has(past) and Rules.watched_tiles(state, lit).has(past) and not Rules.guard_walkable(state, cell.x, cell.y),
		"a mica stays dark, lets the light through, lets the sight through, and a guard cannot enter it"
	)
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stood: Dictionary = stepped["state"]["player"]
	_check(
		stepped["result"] == Rules.Result.OK and int(stood["x"]) == cell.x and int(stood["y"]) == cell.y and int(stepped["called"]) == -1,
		"you may step onto a mica while the lamp is lit"
	)
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(not Rules.light_map(shade).has(past), "a shade still stays dark and stops the light")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(not Rules.light_map(grate).has(cell) and Rules.light_map(grate).has(past) and not Rules.watched_tiles(grate).has(past), "a grate still stays dark, lets the light through, and blocks sight")
	var screen := _with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN)
	_check(Rules.light_map(screen).has(cell) and Rules.light_map(screen).has(past) and not Rules.watched_tiles(screen).has(past), "a screen still stops the sight")
	var glaze := _with_tile(state, cell.x, cell.y, Rules.Tile.GLAZE)
	_check(Rules.light_map(glaze).has(cell) and Rules.apply(glaze, {"type": "move", "dx": 1, "dy": 0})["reason"] == "watched", "a glaze is lit, so that same step loses")
	var sill := _with_tile(state, cell.x, cell.y, Rules.Tile.SILL)
	_check(Rules.light_map(sill).has(cell) and not Rules.light_map(sill).has(past), "a sill still stops the light")
	var curtain := _with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN)
	_check(Rules.light_map(curtain).has(past) and not Rules.watched_tiles(curtain).has(past) and Rules.guard_walkable(curtain, cell.x, cell.y), "a curtain still stops the sight and a guard can still enter it")
	var pane := _with_tile(state, cell.x, cell.y, Rules.Tile.PANE)
	_check(Rules.apply(pane, {"type": "move", "dx": 1, "dy": 0})["reason"] == "pane" and Rules.watched_tiles(pane).has(past), "a pane still lets the sight through and cannot be entered")


func _check_bell_still_calls_every_reachable_guard_past_a_mica() -> void:
	var rows := PackedStringArray(["########", "#S.B...#", "###M####", "#......#", "########"])
	var guards: Array = [
		{"x": 5, "y": 1, "vision": 2, "rail": [Vector2i(5, 1)]},
		{"x": 4, "y": 3, "vision": 2, "rail": [Vector2i(4, 3)]},
	]
	var state := Rules.build(rows, [], guards)
	var bell := _find_tile(state, Rules.Tile.BELL)
	var mica := _find_tile(state, Rules.Tile.MICA)
	_check(Rules.bell_guards(state, bell.x, bell.y) == [0], "a mica is not a floor path, so the keeper behind it is not called")
	var opened := _with_tile(state, mica.x, mica.y, Rules.Tile.FLOOR)
	_check(Rules.bell_guards(opened, bell.x, bell.y) == [0, 1], "opening the mica's cell to floor calls the keeper who can then reach the bell")


func _check_plate_still_calls_only_the_nearest_guard_past_a_mica() -> void:
	var rows := PackedStringArray(["########", "#S.P...#", "###M####", "#......#", "########"])
	var guards: Array = [
		{"x": 6, "y": 1, "vision": 2, "rail": [Vector2i(6, 1)]},
		{"x": 3, "y": 3, "vision": 2, "rail": [Vector2i(3, 3)]},
	]
	var state := Rules.build(rows, [], guards)
	var plate := _find_tile(state, Rules.Tile.PLATE)
	var far: Dictionary = state["guards"][0]
	var near: Dictionary = state["guards"][1]
	var far_dist := absi(int(far["x"]) - plate.x) + absi(int(far["y"]) - plate.y)
	var near_dist := absi(int(near["x"]) - plate.x) + absi(int(near["y"]) - plate.y)
	_check(near_dist < far_dist and not Rules.guard_walkable(state, 3, 2), "the nearer keeper is blocked by the mica and is still nearer")
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	_check(stepped["result"] == Rules.Result.OK and int(stepped["called"]) == 1, "a plate still calls only the nearest guard past a mica")


func _check_a_mica_calls_nobody() -> void:
	var rows := PackedStringArray(["#####", "#S.M#", "#####"])
	var state := Rules.build(rows, [], [{"x": 1, "y": 1, "vision": 2, "rail": [Vector2i(1, 1)]}])
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var onto: Dictionary = Rules.apply(stepped["state"], {"type": "move", "dx": 1, "dy": 0})
	var guard: Dictionary = onto["state"]["guards"][0]
	_check(
		onto["result"] == Rules.Result.OK and int(onto["called"]) == -1 and not bool(guard["alert"]) and not bool(guard["holding"]),
		"a mica calls nobody and is never a hold"
	)


func _check_baize_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Baize Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_baize_rooms() -> void:
	_check_baize_identity()
	_check_earlier_wings_have_no_baizes()
	_check_baize_watched_steps()
	_check_dark_cloth()
	_check_seen_hem()
	_check_stopped_lamp()
	_check_long_cloth()
	_check_early_hem()
	_check_last_baize()
	_check_baize_stops_light_and_passes_sight()
	_check_bell_still_calls_every_reachable_guard_past_a_baize()
	_check_plate_still_calls_only_the_nearest_guard_past_a_baize()
	_check_a_baize_calls_nobody()


func _check_baize_identity() -> void:
	var layouts := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) != "Baize Wing":
			continue
		var layout := "|".join(puzzle["rows"])
		var title := str(puzzle["title"])
		if layouts.has(layout):
			layout_ok = false
		if titles.has(title):
			title_ok = false
		layouts[layout] = title
		titles[title] = true
	_check(layout_ok, "each baize room has its own layout")
	_check(title_ok, "each baize room has its own name")


func _baize_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Baize Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_baizes() -> void:
	var clean := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Baize Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("J"):
				clean = false
		var state := Puzzles.initial_state(i)
		for y in state["h"]:
			for x in state["w"]:
				if Rules.tile_at(state, x, y) == Rules.Tile.BAIZE:
					clean = false
	_check(clean, "earlier wings have no baizes")


func _check_baize_watched_steps() -> void:
	var cases := [
		["The Dark Cloth", "R", 5, 4],
		["The Seen Hem", "U R", 5, 3],
		["The Stopped Lamp", "R", 6, 4],
		["The Long Cloth", "U R R R R D T0 R D", 6, 3],
		["The Early Hem", "U R", 5, 3],
		["The Last Baize", "R R T0 R R R D", 6, 3],
	]
	for entry in cases:
		_expect_watched_loss_at(_baize_room(str(entry[0])), str(entry[1]), int(entry[2]), int(entry[3]))


func _check_dark_cloth() -> void:
	var index := _baize_room("The Dark Cloth")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.BAIZE)
	var past := Vector2i(4, 2)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(not lit.has(cell) and Rules.in_diamond(state["lamps"][0], cell.x, cell.y) and not lit.has(past) and Rules.in_diamond(state["lamps"][0], past.x, past.y), "the dark cloth stands on a dark baize, and the floor past it stays dark")
	_check(_spec_result(state, "U") == "stop" and _spec_result(state, spec) == "win" and _visited(state, puzzle, cell) and _visited(state, puzzle, past) and _mica_step_while_covered(state, puzzle, cell), "you step onto the baize while the lamp is lit, then cross the dark floor")
	var mica := _with_tile(state, cell.x, cell.y, Rules.Tile.MICA)
	_check(Rules.light_map(mica).has(past) and _spec_result(mica, spec) == "lit", "a mica lets the light through, so that floor is refused")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(Rules.light_map(grate).has(past) and not Rules.watched_tiles(grate).has(past) and _spec_result(grate, spec) == "lit", "a grate lets the light through and stops the sight, so that floor is refused")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GLAZE), spec) == "watched", "a glaze is lit, so the early step fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN), spec) == "watched", "a screen is lit, so the early step fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE), spec) == "pane", "a pane cannot be entered")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), spec) == "watched", "a curtain is lit, so the early step fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SILL), spec) == "watched", "a sill is lit, so the early step fails")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(not Rules.light_map(shade).has(past) and _spec_result(shade, spec) == "win", "a shade still clears, because light and pathing match and a shade only reduces sight")


func _check_seen_hem() -> void:
	var index := _baize_room("The Seen Hem")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.BAIZE)
	var seen := Vector2i(5, 3)
	var past := Vector2i(4, 2)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(not lit.has(cell) and lit.has(seen) and Rules.watched_tiles(state, lit).has(seen) and not lit.has(past), "the guard sees a lit tile through the dark baize")
	_check(_spec_result(state, spec) == "win" and not _visited(state, puzzle, seen) and _mica_step_while_covered(state, puzzle, cell), "the solution never takes that tile, and it steps on the baize while the lamp is lit")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(lit.has(seen) and not Rules.watched_tiles(shade).has(seen) and _spec_result(shade, spec) == "win", "a shade hides that tile, and the winning line still clears")
	var mica := _with_tile(state, cell.x, cell.y, Rules.Tile.MICA)
	_check(Rules.light_map(mica).has(past) and _spec_result(mica, spec) == "watched", "a mica lets the light through, so the floor past it is watched")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(Rules.light_map(grate).has(past) and not Rules.watched_tiles(grate).has(past) and _spec_result(grate, spec) == "lit", "a grate lets the light through and stops the sight")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GLAZE), spec) == "watched", "a glaze is lit, so the early step fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN), spec) == "watched", "a screen is lit, so the early step fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE), spec) == "pane", "a pane cannot be entered")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), spec) == "watched", "a curtain is lit, so the early step fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SILL), spec) == "watched", "a sill is lit, so the early step fails")


func _check_stopped_lamp() -> void:
	var index := _baize_room("The Stopped Lamp")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.BAIZE)
	var past := Vector2i(5, 2)
	var spec := _solution_spec(puzzle)
	_check(state["lamps"].size() == 2 and not Rules.light_map(state).has(cell) and Rules.in_diamond(state["lamps"][1], past.x, past.y) and Rules.light_map(state).has(past), "the second lamp's diamond reaches the floor the near lamp is lighting")
	var snuffed := _after_first_snuff(state, puzzle)
	_check(not bool(snuffed["lamps"][0]["lit"]) and bool(snuffed["lamps"][1]["lit"]) and not Rules.light_map(snuffed).has(past), "you snuff the near lamp, and the second lamp still stops at the baize")
	_check(_spec_result(state, spec) == "win" and _mica_step_while_covered(state, puzzle, cell) and _visited(state, puzzle, past), "you step onto the baize while the second lamp is lit, then cross the dark floor")
	var mica := _with_tile(state, cell.x, cell.y, Rules.Tile.MICA)
	_check(Rules.light_map(_after_first_snuff(mica, puzzle)).has(past) and _spec_result(mica, spec) == "lit", "a mica lets the second lamp through")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(Rules.light_map(_after_first_snuff(grate, puzzle)).has(past) and _spec_result(grate, spec) == "lit", "a grate lets the second lamp through")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GLAZE), spec) == "lit", "a glaze refuses the step onto that cell")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN), spec) == "lit", "a screen is lit, so that step is refused")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE), spec) == "pane", "a pane cannot be entered")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), spec) == "lit", "a curtain is lit, so that step is refused")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SILL), spec) == "lit", "a sill is lit, so that step is refused")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(not Rules.light_map(_after_first_snuff(shade, puzzle)).has(past) and _spec_result(shade, spec) == "win", "a shade still clears the stopped lamp")


func _check_long_cloth() -> void:
	var index := _baize_room("The Long Cloth")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.BAIZE)
	var past := Vector2i(6, 1)
	var spec := _solution_spec(puzzle)
	_check(not Rules.light_map(state).has(past) and Rules.in_diamond(state["lamps"][1], past.x, past.y) and not Rules.guard_walkable(state, cell.x, cell.y), "the floor beyond the baize stays dark, and a guard cannot enter")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, cell) and _visited(state, puzzle, past) and _mica_step_while_covered(state, puzzle, cell), "the guard cannot enter the baize, so you take the step he cannot")
	var called := _after_first_snuff(state, puzzle)
	var baize_path: Array = Rules.planned_path(called, 0)
	var curtain_state := _with_tile(called, cell.x, cell.y, Rules.Tile.CURTAIN)
	var curtain_path: Array = Rules.planned_path(curtain_state, 0)
	_check(_path_has(curtain_path, cell) and not _path_has(baize_path, cell) and curtain_path.size() < baize_path.size() and _spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), spec) == "guard", "a curtain is a path, so he takes the short road")
	var mica := _with_tile(state, cell.x, cell.y, Rules.Tile.MICA)
	_check(Rules.light_map(mica).has(past) and _spec_result(mica, spec) == "watched", "a mica lets the light through, so the floor beyond is watched")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(Rules.light_map(grate).has(past) and _spec_result(grate, spec) == "lit", "a grate lets the light through and stops the sight")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GLAZE), spec) == "watched", "a glaze is lit, so the step the solution takes while the lamp is on fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN), spec) == "lit", "a screen lets the light through, so that floor is refused")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE), spec) == "watched", "a pane lets the light through, so that floor is watched")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SILL), spec) == "lit", "a sill is lit where the script steps onto that cell")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(not Rules.light_map(shade).has(past) and not Rules.guard_walkable(shade, cell.x, cell.y) and _spec_result(shade, spec) == "win", "a shade is not a path either, so that substitute still clears")


func _check_early_hem() -> void:
	var index := _baize_room("The Early Hem")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.BAIZE)
	var seen := Vector2i(5, 3)
	var spec := _solution_spec(puzzle)
	_check(_spec_result(state, "U") == "stop" and _spec_result(state, "U R") == "watched" and _spec_result(state, spec) == "win" and _mica_step_while_covered(state, puzzle, cell), "the early step onto the baize is legal, and a guard catches the wrong step past it")
	_check(Rules.watched_tiles(state).has(seen) and not Rules.watched_tiles(_with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)).has(seen), "the guard sees that lit tile through the baize, and a shade hides it")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GLAZE), "U") == "watched", "a glaze refuses that early step")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE), "U") == "pane", "a pane cannot be entered")
	var mica := _with_tile(state, cell.x, cell.y, Rules.Tile.MICA)
	_check(Rules.light_map(mica).has(Vector2i(4, 2)) and _spec_result(mica, spec) == "watched", "a mica lets the light through, so the floor past it is watched")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(Rules.light_map(grate).has(Vector2i(4, 2)) and _spec_result(grate, spec) == "lit", "a grate lets the light through and stops the sight")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN), spec) == "watched", "a screen is lit, so the early step fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), spec) == "watched", "a curtain is lit, so the early step fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SILL), spec) == "watched", "a sill is lit, so the early step fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SHADE), spec) == "win", "a shade still clears the early hem")


func _check_last_baize() -> void:
	var index := _baize_room("The Last Baize")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.BAIZE)
	var past := Vector2i(6, 1)
	var spec := _solution_spec(puzzle)
	_check(not Rules.light_map(state).has(cell) and not Rules.light_map(state).has(past) and Rules.in_diamond(state["lamps"][1], past.x, past.y), "the floor beyond the last baize stays dark")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, cell) and _visited(state, puzzle, past) and _mica_step_while_covered(state, puzzle, cell), "leave by stepping on the dark baize")
	var called := _after_first_snuff(state, puzzle)
	var baize_path: Array = Rules.planned_path(called, 0)
	var curtain_path: Array = Rules.planned_path(_with_tile(called, cell.x, cell.y, Rules.Tile.CURTAIN), 0)
	_check(_path_has(curtain_path, cell) and not _path_has(baize_path, cell) and curtain_path.size() < baize_path.size() and _spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), spec) == "guard", "a curtain is a path, so he takes the short road")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.MICA), spec) == "watched", "a mica lets the light through, so the floor beyond is watched")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GRATE), spec) == "lit", "a grate lets the light through and stops the sight")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GLAZE), spec) == "watched", "a glaze refuses that step")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN), spec) == "lit", "a screen lets the light through")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.PANE), spec) == "watched", "a pane lets the light through, so the floor beyond is watched")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SILL), spec) == "lit", "a sill is lit where the script steps onto that cell")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SHADE), spec) == "win", "a shade still clears the last baize")


func _check_baize_stops_light_and_passes_sight() -> void:
	var rows := PackedStringArray(["######", "#....#", "#SJ..#", "#..#.#", "######"])
	var lamps: Array = [{"x": 2, "y": 3, "facing": "n", "radius": 2, "lit": true}, {"x": 3, "y": 2, "facing": "w", "radius": 0, "lit": true}]
	var guards: Array = [{"x": 2, "y": 3, "vision": 4, "rail": [Vector2i(2, 3)]}]
	var state := Rules.build(rows, lamps, guards)
	var cell := Vector2i(2, 2)
	var beside := Vector2i(3, 2)
	var lit: Dictionary = Rules.light_map(state)
	_check(
		Rules.tile_at(state, cell.x, cell.y) == Rules.Tile.BAIZE and not lit.has(cell) and lit.has(beside) and Rules.watched_tiles(state, lit).has(beside) and not Rules.guard_walkable(state, cell.x, cell.y),
		"a baize stays dark, stops the light, lets the sight through, and a guard cannot enter it"
	)
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stood: Dictionary = stepped["state"]["player"]
	_check(
		stepped["result"] == Rules.Result.OK and int(stood["x"]) == cell.x and int(stood["y"]) == cell.y and int(stepped["called"]) == -1,
		"you may step onto a baize while the lamp is lit"
	)
	var north := Vector2i(2, 1)
	_check(Rules.in_diamond(state["lamps"][0], north.x, north.y) and not lit.has(north), "tiles past a baize stay dark")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(not Rules.watched_tiles(shade).has(beside) and not Rules.light_map(shade).has(north), "a shade stops the sight and also stops the light")
	var mica := _with_tile(state, cell.x, cell.y, Rules.Tile.MICA)
	_check(Rules.light_map(mica).has(north) and Rules.watched_tiles(mica).has(beside), "a mica lets the light through and still lets the sight through")
	var grate := _with_tile(state, cell.x, cell.y, Rules.Tile.GRATE)
	_check(Rules.light_map(grate).has(north) and not Rules.watched_tiles(grate).has(beside), "a grate lets the light through and stops the sight")
	var screen := _with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN)
	_check(Rules.light_map(screen).has(cell) and Rules.apply(screen, {"type": "move", "dx": 1, "dy": 0})["reason"] == "watched", "a screen is lit, so that same step loses")
	var glaze := _with_tile(state, cell.x, cell.y, Rules.Tile.GLAZE)
	_check(Rules.light_map(glaze).has(cell) and Rules.light_map(glaze).has(north), "a glaze is lit and lets the light through")
	var sill := _with_tile(state, cell.x, cell.y, Rules.Tile.SILL)
	_check(Rules.light_map(sill).has(cell) and not Rules.light_map(sill).has(north), "a sill is lit and still stops the light")
	var curtain := _with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN)
	_check(Rules.guard_walkable(curtain, cell.x, cell.y) and Rules.light_map(curtain).has(north), "a curtain can be entered and lets the light through")
	var pane := _with_tile(state, cell.x, cell.y, Rules.Tile.PANE)
	_check(Rules.apply(pane, {"type": "move", "dx": 1, "dy": 0})["reason"] == "pane" and Rules.light_map(pane).has(north), "a pane cannot be entered and lets the light through")


func _check_bell_still_calls_every_reachable_guard_past_a_baize() -> void:
	var rows := PackedStringArray(["########", "#S.B...#", "###J####", "#......#", "########"])
	var guards: Array = [
		{"x": 5, "y": 1, "vision": 2, "rail": [Vector2i(5, 1)]},
		{"x": 4, "y": 3, "vision": 2, "rail": [Vector2i(4, 3)]},
	]
	var state := Rules.build(rows, [], guards)
	var bell := _find_tile(state, Rules.Tile.BELL)
	var baize := _find_tile(state, Rules.Tile.BAIZE)
	_check(Rules.bell_guards(state, bell.x, bell.y) == [0], "a baize is not a floor path, so the keeper behind it is not called")
	var opened := _with_tile(state, baize.x, baize.y, Rules.Tile.FLOOR)
	_check(Rules.bell_guards(opened, bell.x, bell.y) == [0, 1], "opening the baize's cell to floor calls the keeper who can then reach the bell")


func _check_plate_still_calls_only_the_nearest_guard_past_a_baize() -> void:
	var rows := PackedStringArray(["########", "#S.P...#", "###J####", "#......#", "########"])
	var guards: Array = [
		{"x": 6, "y": 1, "vision": 2, "rail": [Vector2i(6, 1)]},
		{"x": 3, "y": 3, "vision": 2, "rail": [Vector2i(3, 3)]},
	]
	var state := Rules.build(rows, [], guards)
	var plate := _find_tile(state, Rules.Tile.PLATE)
	var far: Dictionary = state["guards"][0]
	var near: Dictionary = state["guards"][1]
	var far_dist := absi(int(far["x"]) - plate.x) + absi(int(far["y"]) - plate.y)
	var near_dist := absi(int(near["x"]) - plate.x) + absi(int(near["y"]) - plate.y)
	_check(near_dist < far_dist and not Rules.guard_walkable(state, 3, 2), "the nearer keeper is blocked by the baize and is still nearer")
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	_check(stepped["result"] == Rules.Result.OK and int(stepped["called"]) == 1, "a plate still calls only the nearest guard past a baize")


func _check_a_baize_calls_nobody() -> void:
	var rows := PackedStringArray(["#####", "#S.J#", "#####"])
	var state := Rules.build(rows, [], [{"x": 1, "y": 1, "vision": 2, "rail": [Vector2i(1, 1)]}])
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var onto: Dictionary = Rules.apply(stepped["state"], {"type": "move", "dx": 1, "dy": 0})
	var guard: Dictionary = onto["state"]["guards"][0]
	_check(
		onto["result"] == Rules.Result.OK and int(onto["called"]) == -1 and not bool(guard["alert"]) and not bool(guard["holding"]),
		"a baize calls nobody and is never a hold"
	)


func _check_scrim_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Scrim Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_scrim_rooms() -> void:
	_check_scrim_identity()
	_check_earlier_wings_have_no_scrims()
	_check_lit_scrim()
	_check_seen_thread()
	_check_halted_wick()
	_check_closed_scrim()
	_check_early_thread()
	_check_last_scrim()
	_check_scrim_is_lit_and_stops_light()
	_check_bell_still_calls_every_reachable_guard_past_a_scrim()
	_check_plate_still_calls_only_the_nearest_guard_past_a_scrim()
	_check_a_scrim_calls_nobody()


func _check_scrim_identity() -> void:
	var layouts := {}
	var wing_titles := {}
	var earlier := {}
	var layout_ok := true
	var title_ok := true
	var once := true
	var scrim_titles := {
		"The Lit Scrim": true,
		"The Seen Thread": true,
		"The Halted Wick": true,
		"The Closed Scrim": true,
		"The Early Thread": true,
		"The Last Scrim": true,
	}
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		var title := str(puzzle["title"])
		if str(puzzle["wing"]) != "Scrim Wing":
			if scrim_titles.has(title):
				once = false
			earlier[title] = true
			continue
		if earlier.has(title) or wing_titles.has(title):
			once = false
		var layout := "|".join(puzzle["rows"])
		if layouts.has(layout):
			layout_ok = false
		if wing_titles.has(title):
			title_ok = false
		layouts[layout] = title
		wing_titles[title] = true
	_check(layout_ok, "each scrim room has its own layout")
	_check(title_ok, "each scrim room has its own name")
	_check(once and wing_titles.size() == 6, "the scrim titles are not reused")


func _scrim_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Scrim Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_scrims() -> void:
	var clean := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Scrim Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("K"):
				clean = false
		var state := Puzzles.initial_state(i)
		for y in state["h"]:
			for x in state["w"]:
				if Rules.tile_at(state, x, y) == Rules.Tile.SCRIM:
					clean = false
	_check(clean, "earlier wings have no scrims")


func _scrim_kind(state: Dictionary, cell: Vector2i, kind: int) -> Dictionary:
	return _with_tile(state, cell.x, cell.y, kind)


func _check_lit_scrim() -> void:
	var index := _scrim_room("The Lit Scrim")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.SCRIM)
	var door := Vector2i(4, 1)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(4, 2) and lit.has(cell) and not Rules.watched_tiles(state, lit).has(cell), "the lit scrim is lit, and the guard on the door does not watch it")
	_check(not lit.has(door) and Rules.in_diamond(state["lamps"][0], door.x, door.y), "the floor past the lit scrim stays dark")
	_check(_spec_result(state, "U") == "lit" and _spec_result(state, spec) == "win" and _stepped_on_while_dark(state, puzzle, cell), "the step onto the lit scrim before the snuff fails, and you cross it only after it is dark")
	var shade := _scrim_kind(state, cell, Rules.Tile.SHADE)
	_check(_spec_result(shade, "U") == "stop" and _spec_result(shade, "U U") == "guard" and _spec_result(shade, spec) == "win", "a shade stays dark, so the early step is legal, the early line does not clear, and the official line still does")
	var baize := _scrim_kind(state, cell, Rules.Tile.BAIZE)
	_check(_spec_result(baize, "U") == "stop" and _spec_result(baize, "U U") == "guard" and _spec_result(baize, spec) == "win", "a baize stays dark, so the early step is legal, the early line does not clear, and the official line still does")
	_check(_spec_result(_scrim_kind(state, cell, Rules.Tile.SILL), spec) == "win", "a sill matches the snuff-first line of the lit scrim")
	_check(_spec_result(_scrim_kind(state, cell, Rules.Tile.SCREEN), spec) == "win", "a screen matches the snuff-first line of the lit scrim, because the lamp is out before the step")
	_check(_spec_result(_scrim_kind(state, cell, Rules.Tile.CURTAIN), spec) == "guard", "a curtain is a path, so the guard on the door takes it")
	var called := _after_first_snuff(state, puzzle)
	var around: Array = Rules.planned_path(called, 0)
	var through: Array = Rules.planned_path(_scrim_kind(called, cell, Rules.Tile.CURTAIN), 0)
	_check(not Rules.guard_walkable(state, cell.x, cell.y) and not _path_has(around, cell) and _path_has(through, cell) and through.size() < around.size(), "a guard cannot enter the lit scrim, so he walks around it")


func _check_seen_thread() -> void:
	var index := _scrim_room("The Seen Thread")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.SCRIM)
	var gap := Vector2i(3, 1)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(3, 2) and lit.has(cell) and Rules.watched_tiles(state, lit).has(cell) and Rules.watched_tiles(state, lit).has(gap), "the guard sees a lit tile through the lit scrim, and the lit scrim itself is watched")
	_check(not Rules.watched_tiles(_scrim_kind(state, cell, Rules.Tile.SILL)).has(gap), "a sill stops the sight, so that lit tile is not watched")
	_check(not Rules.watched_tiles(_scrim_kind(state, cell, Rules.Tile.SHADE)).has(gap), "a shade stays dark, so that lit tile is not watched")
	_check(not Rules.watched_tiles(_scrim_kind(state, cell, Rules.Tile.SCREEN)).has(gap), "a screen stops the sight, so that lit tile is not watched")
	_check(Rules.watched_tiles(_scrim_kind(state, cell, Rules.Tile.BAIZE)).has(gap), "a baize stays dark and still lets the sight through")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, gap) and _stepped_on_while_dark(state, puzzle, cell), "the solution crosses the scrim only after the snuff, then takes the tile the guard had been watching")
	_check(_spec_result(_scrim_kind(state, cell, Rules.Tile.SHADE), spec) == "win", "a shade still clears the official line, because the scrim is dark by the time you step on it")
	_check(_spec_result(_scrim_kind(state, cell, Rules.Tile.BAIZE), spec) == "watched", "a baize does not clear the seen thread, because sight still passes after the snuff")
	_check(_spec_result(_scrim_kind(state, cell, Rules.Tile.SILL), spec) == "win", "a sill still clears the official line, and it does not show the watched tile")
	_check(_spec_result(_scrim_kind(state, cell, Rules.Tile.SCREEN), spec) == "win", "a screen still clears the official line, because the lamp is out before the step")
	_check(_spec_result(_scrim_kind(state, cell, Rules.Tile.MICA), spec) == "watched", "a mica lets the sight through, so that tile stays watched")
	_check(_spec_result(_scrim_kind(state, cell, Rules.Tile.PANE), spec) == "pane", "a pane cannot be entered")
	_check(_spec_result(state, "L U U U") == "watched", "stepping onto the lit scrim a guard is watching is a loss")


func _check_halted_wick() -> void:
	var index := _scrim_room("The Halted Wick")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.SCRIM)
	var past := Vector2i(5, 2)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(state["lamps"].size() == 2 and int(state["lamps"][1]["radius"]) == 3 and cell == Vector2i(5, 3), "the second lamp is the one that meets the scrim")
	_check(lit.has(cell) and not lit.has(past) and Rules.in_diamond(state["lamps"][1], past.x, past.y), "the second lamp's light stops at the scrim")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, past), "you leave across the floor the scrim kept dark")
	var screen := _scrim_kind(state, cell, Rules.Tile.SCREEN)
	_check(Rules.light_map(screen).has(past) and _spec_result(screen, spec) == "lit", "a screen lets the light through, so that floor is refused")
	_check(not Rules.light_map(_scrim_kind(state, cell, Rules.Tile.SHADE)).has(past) and _spec_result(_scrim_kind(state, cell, Rules.Tile.SHADE), spec) == "win", "a shade also stops the light, so the around-path still clears")
	_check(not Rules.light_map(_scrim_kind(state, cell, Rules.Tile.BAIZE)).has(past) and _spec_result(_scrim_kind(state, cell, Rules.Tile.BAIZE), spec) == "win", "a baize also stops the light, so the around-path still clears")
	_check(not Rules.light_map(_scrim_kind(state, cell, Rules.Tile.SILL)).has(past) and _spec_result(_scrim_kind(state, cell, Rules.Tile.SILL), spec) == "win", "a sill also stops the light, so the around-path still clears")
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 0, "the halted wick is solved without snuffing")


func _check_closed_scrim() -> void:
	var index := _scrim_room("The Closed Scrim")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.SCRIM)
	var past := Vector2i(4, 1)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(3, 1) and lit.has(cell) and not lit.has(past) and Rules.in_diamond(state["lamps"][0], past.x, past.y), "the lamp stands on the scrim, so the scrim is lit and the floor past it stays dark")
	_check(not Rules.guard_walkable(state, cell.x, cell.y) and _spec_result(state, spec) == "win" and _stepped_on_while_dark(state, puzzle, cell), "a guard cannot enter the scrim, and you step on it only after the snuff")
	_check(_spec_result(state, "R R") == "lit" and _spec_result(_scrim_kind(state, cell, Rules.Tile.SHADE), "R R") == "stop", "the step onto the lit scrim before the snuff fails, and the same step onto a shade is legal")
	_check(_spec_result(_scrim_kind(state, cell, Rules.Tile.SHADE), spec) == "win", "a shade still clears the official line of the closed scrim")
	_check(_spec_result(_scrim_kind(state, cell, Rules.Tile.BAIZE), spec) == "win", "a baize still clears the official line of the closed scrim")
	_check(_spec_result(_scrim_kind(state, cell, Rules.Tile.SILL), spec) == "win", "a sill still clears the official line of the closed scrim")
	_check(_spec_result(_scrim_kind(state, cell, Rules.Tile.SCREEN), spec) == "win", "a screen still clears the official line of the closed scrim, because the lamp is snuffed first")
	var called := _after_first_snuff(state, puzzle)
	var around: Array = Rules.planned_path(called, 0)
	var through: Array = Rules.planned_path(_scrim_kind(called, cell, Rules.Tile.CURTAIN), 0)
	_check(not _path_has(around, cell) and _path_has(through, cell) and _spec_result(_scrim_kind(state, cell, Rules.Tile.CURTAIN), spec) == "guard", "a curtain is a path, so he takes the short road")


func _check_early_thread() -> void:
	var index := _scrim_room("The Early Thread")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.SCRIM)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(3, 2) and lit.has(cell) and not Rules.watched_tiles(state, lit).has(cell), "the early thread is a lit scrim the guard is not watching")
	_check(_spec_result(state, "U") == "lit" and _spec_result(state, "U U") == "lit" and _spec_result(state, spec) == "win", "the early step onto the lit scrim fails")
	var shade := _scrim_kind(state, cell, Rules.Tile.SHADE)
	_check(_spec_result(shade, "U") == "stop" and _spec_result(shade, "U U") == "guard" and _spec_result(shade, spec) == "win", "a shade accepts the early step, and that early line does not clear")
	var baize := _scrim_kind(state, cell, Rules.Tile.BAIZE)
	_check(_spec_result(baize, "U") == "stop" and _spec_result(baize, "U U") == "guard" and _spec_result(baize, spec) == "win", "a baize accepts the early step, and that early line does not clear")
	_check(_spec_result(_scrim_kind(state, cell, Rules.Tile.SILL), "U") == "lit", "a sill is lit, so the early step fails the same way")
	_check(_spec_result(_scrim_kind(state, cell, Rules.Tile.SCREEN), "U") == "lit", "a screen is lit, so the early step fails the same way")


func _check_last_scrim() -> void:
	var index := _scrim_room("The Last Scrim")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.SCRIM)
	var past := Vector2i(4, 1)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(3, 1) and lit.has(cell) and not lit.has(past) and Rules.in_diamond(state["lamps"][0], past.x, past.y), "the floor beyond the last scrim stays dark")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, cell) and _visited(state, puzzle, past) and _stepped_on_while_dark(state, puzzle, cell), "you leave by stepping on the dark scrim")
	_check(_spec_result(state, "R R") == "lit" and _spec_result(_scrim_kind(state, cell, Rules.Tile.SHADE), "R R") == "stop", "the step onto the lit scrim before the snuff fails, and the same step onto a shade is legal")
	_check(_spec_result(_scrim_kind(state, cell, Rules.Tile.SHADE), spec) == "win", "a shade still clears the official line of the last scrim")
	_check(_spec_result(_scrim_kind(state, cell, Rules.Tile.BAIZE), spec) == "win", "a baize still clears the official line of the last scrim")
	_check(_spec_result(_scrim_kind(state, cell, Rules.Tile.SILL), spec) == "win", "a sill still clears the official line of the last scrim")
	_check(_spec_result(_scrim_kind(state, cell, Rules.Tile.SCREEN), spec) == "win", "a screen still clears the official line of the last scrim, because the lamp is snuffed first")
	_check(_spec_result(_scrim_kind(state, cell, Rules.Tile.CURTAIN), spec) == "guard", "a curtain is a path, so he takes the short road")


func _check_scrim_is_lit_and_stops_light() -> void:
	var rows := PackedStringArray(["######", "#....#", "#SK..#", "#..#.#", "######"])
	var lamps: Array = [{"x": 2, "y": 3, "facing": "n", "radius": 2, "lit": true}, {"x": 3, "y": 2, "facing": "w", "radius": 0, "lit": true}]
	var guards: Array = [{"x": 2, "y": 3, "vision": 4, "rail": [Vector2i(2, 3)]}]
	var state := Rules.build(rows, lamps, guards)
	var cell := Vector2i(2, 2)
	var beside := Vector2i(3, 2)
	var north := Vector2i(2, 1)
	var lit: Dictionary = Rules.light_map(state)
	_check(
		Rules.tile_at(state, cell.x, cell.y) == Rules.Tile.SCRIM and lit.has(cell) and lit.has(beside) and Rules.watched_tiles(state, lit).has(cell) and Rules.watched_tiles(state, lit).has(beside) and not Rules.guard_walkable(state, cell.x, cell.y),
		"a scrim is lit, stops the light, lets the sight through while it is lit, and a guard cannot enter it"
	)
	_check(Rules.in_diamond(state["lamps"][0], north.x, north.y) and not lit.has(north), "tiles past a scrim stay dark")
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	_check(stepped["result"] == Rules.Result.LOSS and stepped["reason"] == "watched", "stepping onto a lit scrim a guard is watching is a loss")
	var blind := Rules.build(rows, lamps, [{"x": 2, "y": 3, "vision": 0, "rail": [Vector2i(2, 3)]}])
	var refused: Dictionary = Rules.apply(blind, {"type": "move", "dx": 1, "dy": 0})
	_check(refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "lit", "an unwatched lit scrim is refused")
	var dark_rows := PackedStringArray(["#####", "#S.K#", "#####"])
	var dark := Rules.build(dark_rows, [], [{"x": 1, "y": 1, "vision": 2, "rail": [Vector2i(1, 1)]}])
	var onto: Dictionary = Rules.apply(Rules.apply(dark, {"type": "move", "dx": 1, "dy": 0})["state"], {"type": "move", "dx": 1, "dy": 0})
	_check(onto["result"] == Rules.Result.OK and int(onto["called"]) == -1, "a dark scrim can be entered, and that step calls nobody")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(not Rules.light_map(shade).has(cell) and not Rules.light_map(shade).has(north) and not Rules.watched_tiles(shade).has(beside), "a shade stays dark, stops the light, and stops the sight")
	var baize := _with_tile(state, cell.x, cell.y, Rules.Tile.BAIZE)
	_check(not Rules.light_map(baize).has(cell) and not Rules.light_map(baize).has(north) and Rules.watched_tiles(baize).has(beside), "a baize stays dark, stops the light, and lets the sight through")
	var sill := _with_tile(state, cell.x, cell.y, Rules.Tile.SILL)
	_check(Rules.light_map(sill).has(cell) and not Rules.light_map(sill).has(north) and not Rules.watched_tiles(sill).has(beside), "a sill is lit, stops the light, and stops the sight")
	var screen := _with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN)
	_check(Rules.light_map(screen).has(cell) and Rules.light_map(screen).has(north) and not Rules.watched_tiles(screen).has(beside), "a screen is lit, lets the light through, and stops the sight")


func _check_bell_still_calls_every_reachable_guard_past_a_scrim() -> void:
	var rows := PackedStringArray(["########", "#S.B...#", "###K####", "#......#", "########"])
	var guards: Array = [
		{"x": 5, "y": 1, "vision": 2, "rail": [Vector2i(5, 1)]},
		{"x": 4, "y": 3, "vision": 2, "rail": [Vector2i(4, 3)]},
	]
	var state := Rules.build(rows, [], guards)
	var bell := _find_tile(state, Rules.Tile.BELL)
	var scrim := _find_tile(state, Rules.Tile.SCRIM)
	_check(Rules.bell_guards(state, bell.x, bell.y) == [0], "a scrim is not a floor path, so the keeper behind it is not called")
	var opened := _with_tile(state, scrim.x, scrim.y, Rules.Tile.FLOOR)
	_check(Rules.bell_guards(opened, bell.x, bell.y) == [0, 1], "opening the scrim's cell to floor calls the keeper who can then reach the bell")


func _check_plate_still_calls_only_the_nearest_guard_past_a_scrim() -> void:
	var rows := PackedStringArray(["########", "#S.P...#", "###K####", "#......#", "########"])
	var guards: Array = [
		{"x": 6, "y": 1, "vision": 2, "rail": [Vector2i(6, 1)]},
		{"x": 3, "y": 3, "vision": 2, "rail": [Vector2i(3, 3)]},
	]
	var state := Rules.build(rows, [], guards)
	var plate := _find_tile(state, Rules.Tile.PLATE)
	var far: Dictionary = state["guards"][0]
	var near: Dictionary = state["guards"][1]
	var far_dist := absi(int(far["x"]) - plate.x) + absi(int(far["y"]) - plate.y)
	var near_dist := absi(int(near["x"]) - plate.x) + absi(int(near["y"]) - plate.y)
	_check(near_dist < far_dist and not Rules.guard_walkable(state, 3, 2), "the nearer keeper is blocked by the scrim and is still nearer")
	var approach: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stepped: Dictionary = Rules.apply(approach["state"], {"type": "move", "dx": 1, "dy": 0})
	_check(stepped["result"] == Rules.Result.OK and int(stepped["called"]) == 1, "a plate still calls only the nearest guard past a scrim")


func _check_a_scrim_calls_nobody() -> void:
	var rows := PackedStringArray(["#####", "#S.K#", "#####"])
	var state := Rules.build(rows, [], [{"x": 1, "y": 1, "vision": 2, "rail": [Vector2i(1, 1)]}])
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var onto: Dictionary = Rules.apply(stepped["state"], {"type": "move", "dx": 1, "dy": 0})
	var guard: Dictionary = onto["state"]["guards"][0]
	_check(
		onto["result"] == Rules.Result.OK and int(onto["called"]) == -1 and not bool(guard["alert"]) and not bool(guard["holding"]),
		"a scrim calls nobody and is never a hold"
	)


func _check_gauze_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Gauze Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_gauze_rooms() -> void:
	_check_gauze_identity()
	_check_earlier_wings_have_no_gauzes()
	_check_lit_gauze()
	_check_seen_mesh()
	_check_passed_flame()
	_check_open_gauze()
	_check_early_mesh()
	_check_last_gauze()
	_check_gauze_passes_a_second_lamp()
	_check_a_gauze_calls_nobody()


func _check_gauze_identity() -> void:
	var layouts := {}
	var wing_titles := {}
	var earlier := {}
	var layout_ok := true
	var title_ok := true
	var once := true
	var gauze_titles := {
		"The Lit Gauze": true,
		"The Seen Mesh": true,
		"The Passed Flame": true,
		"The Open Gauze": true,
		"The Early Mesh": true,
		"The Last Gauze": true,
	}
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		var title := str(puzzle["title"])
		if str(puzzle["wing"]) != "Gauze Wing":
			if gauze_titles.has(title):
				once = false
			earlier[title] = true
			continue
		if earlier.has(title) or wing_titles.has(title):
			once = false
		var layout := "|".join(puzzle["rows"])
		if layouts.has(layout):
			layout_ok = false
		if wing_titles.has(title):
			title_ok = false
		layouts[layout] = title
		wing_titles[title] = true
	_check(layout_ok, "each gauze room has its own layout")
	_check(title_ok, "each gauze room has its own name")
	_check(once and wing_titles.size() == 6, "the gauze titles are not reused")


func _gauze_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Gauze Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_gauzes() -> void:
	var clean := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Gauze Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("Q"):
				clean = false
		var state := Puzzles.initial_state(i)
		for y in state["h"]:
			for x in state["w"]:
				if Rules.tile_at(state, x, y) == Rules.Tile.GAUZE:
					clean = false
	_check(clean, "earlier wings have no gauzes")


func _check_lit_gauze() -> void:
	var index := _gauze_room("The Lit Gauze")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.GAUZE)
	var door := Vector2i(3, 2)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	var screen := _with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN)
	_check(cell == Vector2i(3, 3) and lit.has(cell) and not Rules.watched_tiles(state, lit).has(cell), "the lit gauze is lit")
	_check(not lit.has(door) and Rules.in_diamond(state["lamps"][0], door.x, door.y), "a lamp standing on the gauze does not shine past it")
	_check(Rules.light_map(screen).has(door), "a lamp standing on a screen does shine past it")
	_check(_spec_result(state, "U") == "lit" and _spec_result(state, spec) == "win" and not _visited(state, puzzle, cell), "the early step onto the lit gauze fails, and the solution walks the dark floor around it")
	_check(_spec_result(screen, spec) == "lit", "a screen does not clear the lit gauze, because the lamp shines past the screen")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SCRIM), spec) == "win", "a scrim also keeps that floor dark, so the official line still clears")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SHADE), "U") == "stop" and _spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SHADE), spec) == "win", "a shade stays dark, so the early step is legal and the official line still clears")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.BAIZE), spec) == "win", "a baize still clears the official line of the lit gauze")


func _check_seen_mesh() -> void:
	var index := _gauze_room("The Seen Mesh")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.GAUZE)
	var gap := Vector2i(3, 1)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(3, 2) and lit.has(cell) and Rules.watched_tiles(state, lit).has(cell) and Rules.watched_tiles(state, lit).has(gap), "the guard sees a lit tile through the lit gauze, and the lit gauze itself is watched")
	_check(not Rules.watched_tiles(_with_tile(state, cell.x, cell.y, Rules.Tile.SILL)).has(gap), "a sill stops the sight, so that lit tile is not watched")
	_check(not Rules.watched_tiles(_with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)).has(gap), "a shade stays dark, so that lit tile is not watched")
	_check(not Rules.watched_tiles(_with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN)).has(gap), "a screen stops the sight, so that lit tile is not watched")
	_check(Rules.watched_tiles(_with_tile(state, cell.x, cell.y, Rules.Tile.BAIZE)).has(gap), "a baize stays dark and still lets the sight through")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, gap) and _stepped_on_while_dark(state, puzzle, cell), "the solution crosses the gauze only after the snuff, then takes the tile the guard had been watching")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.BAIZE), spec) == "watched", "a baize does not clear the seen mesh, because sight still passes after the snuff")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SHADE), spec) == "win", "a shade still clears the official line of the seen mesh")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN), spec) == "win", "a screen still clears the official line of the seen mesh")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SCRIM), spec) == "win", "a scrim still clears the official line of the seen mesh")


func _check_passed_flame() -> void:
	var index := _gauze_room("The Passed Flame")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.GAUZE)
	var gap := Vector2i(2, 2)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	var scrim := _with_tile(state, cell.x, cell.y, Rules.Tile.SCRIM)
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	var baize := _with_tile(state, cell.x, cell.y, Rules.Tile.BAIZE)
	_check(state["lamps"].size() == 2 and int(state["lamps"][1]["radius"]) == 2 and int(state["lamps"][0]["radius"]) == 0 and cell == Vector2i(2, 3), "the second lamp is the one whose light passes the gauze")
	_check(lit.has(cell) and lit.has(gap) and Rules.in_diamond(state["lamps"][1], gap.x, gap.y), "a second lamp's light passes the gauze")
	_check(not Rules.light_map(scrim).has(gap), "a scrim stops the light the gauze lets through")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, gap) and _stepped_on_while_dark(state, puzzle, cell), "you snuff, step on the dark gauze, relight, and cross the gap that light now reaches")
	_check(_spec_result(scrim, spec) == "darkgap", "a scrim does not clear the passed flame, because the light stops")
	_check(_spec_result(shade, spec) == "darkgap", "a shade does not clear the passed flame, because the light stops")
	_check(_spec_result(baize, spec) == "darkgap", "a baize does not clear the passed flame, because the light stops")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN), spec) == "win", "a screen lets the light through, so the official line still clears")


func _check_open_gauze() -> void:
	var index := _gauze_room("The Open Gauze")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.GAUZE)
	var past := Vector2i(4, 1)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(3, 1) and lit.has(cell) and not lit.has(past) and Rules.in_diamond(state["lamps"][0], past.x, past.y), "the lamp stands on the gauze, so the gauze is lit and the floor past it stays dark")
	_check(not Rules.guard_walkable(state, cell.x, cell.y) and _spec_result(state, spec) == "win" and _stepped_on_while_dark(state, puzzle, cell), "a guard cannot enter the gauze, and you step on it only after the snuff")
	_check(_spec_result(state, "R R") == "lit" and _spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SHADE), "R R") == "stop", "the step onto the lit gauze before the snuff fails, and the same step onto a shade is legal")
	var called := _after_first_snuff(state, puzzle)
	var around: Array = Rules.planned_path(called, 0)
	var through: Array = Rules.planned_path(_with_tile(called, cell.x, cell.y, Rules.Tile.CURTAIN), 0)
	_check(not _path_has(around, cell) and _path_has(through, cell) and _spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), spec) == "guard", "a curtain is a path, so he takes the short road")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN), spec) == "win", "a screen still clears the official line of the open gauze, because the lamp is snuffed first")


func _check_early_mesh() -> void:
	var index := _gauze_room("The Early Mesh")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.GAUZE)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(3, 2) and lit.has(cell) and not Rules.watched_tiles(state, lit).has(cell), "the early mesh is a lit gauze the guard is not watching")
	_check(_spec_result(state, "U") == "lit" and _spec_result(state, "U U") == "lit" and _spec_result(state, spec) == "win", "the early step onto the lit gauze fails")
	var shade := _with_tile(state, cell.x, cell.y, Rules.Tile.SHADE)
	_check(_spec_result(shade, "U") == "stop" and _spec_result(shade, "U U") == "guard" and _spec_result(shade, spec) == "win", "a shade accepts the early step, and that early line does not clear")
	var baize := _with_tile(state, cell.x, cell.y, Rules.Tile.BAIZE)
	_check(_spec_result(baize, "U") == "stop" and _spec_result(baize, "U U") == "guard" and _spec_result(baize, spec) == "win", "a baize accepts the early step, and that early line does not clear")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN), "U") == "lit", "a screen is lit, so the early step fails the same way")


func _check_last_gauze() -> void:
	var index := _gauze_room("The Last Gauze")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.GAUZE)
	var past := Vector2i(4, 1)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(3, 1) and lit.has(cell) and not lit.has(past) and Rules.in_diamond(state["lamps"][0], past.x, past.y), "the floor beyond the last gauze stays dark")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, cell) and _visited(state, puzzle, past) and _stepped_on_while_dark(state, puzzle, cell), "you leave by stepping on the dark gauze")
	_check(_spec_result(state, "R R") == "lit" and _spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SHADE), "R R") == "stop", "the step onto the lit gauze before the snuff fails, and the same step onto a shade is legal")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), spec) == "guard", "a curtain is a path, so he takes the short road")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN), spec) == "win", "a screen still clears the official line of the last gauze, because the lamp is snuffed first")


func _check_gauze_passes_a_second_lamp() -> void:
	var rows := PackedStringArray(["######", "#....#", "#SQ..#", "#..#.#", "######"])
	var lamps: Array = [{"x": 2, "y": 3, "facing": "n", "radius": 2, "lit": true}, {"x": 3, "y": 2, "facing": "w", "radius": 0, "lit": true}]
	var guards: Array = [{"x": 2, "y": 3, "vision": 4, "rail": [Vector2i(2, 3)]}]
	var state := Rules.build(rows, lamps, guards)
	var cell := Vector2i(2, 2)
	var beside := Vector2i(3, 2)
	var north := Vector2i(2, 1)
	var lit: Dictionary = Rules.light_map(state)
	_check(
		Rules.tile_at(state, cell.x, cell.y) == Rules.Tile.GAUZE and lit.has(cell) and lit.has(beside) and lit.has(north) and Rules.watched_tiles(state, lit).has(cell) and Rules.watched_tiles(state, lit).has(beside) and not Rules.guard_walkable(state, cell.x, cell.y),
		"a gauze is lit, a second lamp's light passes, sight passes while it is lit, and a guard cannot enter it"
	)
	_check(Rules.in_diamond(state["lamps"][0], north.x, north.y) and lit.has(north), "tiles past a gauze still light")
	var scrim := _with_tile(state, cell.x, cell.y, Rules.Tile.SCRIM)
	_check(Rules.light_map(scrim).has(cell) and not Rules.light_map(scrim).has(north), "a scrim stops the same light")
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	_check(stepped["result"] == Rules.Result.LOSS and stepped["reason"] == "watched", "stepping onto a lit gauze a guard is watching is a loss")
	var blind := Rules.build(rows, lamps, [{"x": 2, "y": 3, "vision": 0, "rail": [Vector2i(2, 3)]}])
	var refused: Dictionary = Rules.apply(blind, {"type": "move", "dx": 1, "dy": 0})
	_check(refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "lit", "an unwatched lit gauze is refused")
	var dark_rows := PackedStringArray(["#####", "#S.Q#", "#####"])
	var dark := Rules.build(dark_rows, [], [{"x": 1, "y": 1, "vision": 2, "rail": [Vector2i(1, 1)]}])
	var onto: Dictionary = Rules.apply(Rules.apply(dark, {"type": "move", "dx": 1, "dy": 0})["state"], {"type": "move", "dx": 1, "dy": 0})
	_check(onto["result"] == Rules.Result.OK and int(onto["called"]) == -1, "a dark gauze can be entered, and that step calls nobody")


func _check_a_gauze_calls_nobody() -> void:
	var rows := PackedStringArray(["#####", "#S.Q#", "#####"])
	var state := Rules.build(rows, [], [{"x": 1, "y": 1, "vision": 2, "rail": [Vector2i(1, 1)]}])
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var onto: Dictionary = Rules.apply(stepped["state"], {"type": "move", "dx": 1, "dy": 0})
	var guard: Dictionary = onto["state"]["guards"][0]
	_check(
		onto["result"] == Rules.Result.OK and int(onto["called"]) == -1 and not bool(guard["alert"]) and not bool(guard["holding"]),
		"a gauze calls nobody and is never a hold"
	)


func _check_voile_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Voile Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_voile_rooms() -> void:
	_check_voile_identity()
	_check_earlier_wings_have_no_voiles()
	_check_lit_voile()
	_check_seen_weave()
	_check_passed_spark()
	_check_shut_voile()
	_check_early_step()
	_check_last_voile()
	_check_voile_early_step_succeeds()


func _check_voile_identity() -> void:
	var layouts := {}
	var wing_titles := {}
	var earlier := {}
	var layout_ok := true
	var title_ok := true
	var once := true
	var voile_titles := {
		"The Lit Voile": true,
		"The Seen Weave": true,
		"The Passed Spark": true,
		"The Shut Voile": true,
		"The Early Step": true,
		"The Last Voile": true,
	}
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		var title := str(puzzle["title"])
		if str(puzzle["wing"]) != "Voile Wing":
			if voile_titles.has(title):
				once = false
			earlier[title] = true
			continue
		if earlier.has(title) or wing_titles.has(title):
			once = false
		var layout := "|".join(puzzle["rows"])
		if layouts.has(layout):
			layout_ok = false
		if wing_titles.has(title):
			title_ok = false
		layouts[layout] = title
		wing_titles[title] = true
	_check(layout_ok, "each voile room has its own layout")
	_check(title_ok, "each voile room has its own name")
	_check(once and wing_titles.size() == 6, "the voile titles are not reused")


func _voile_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Voile Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_voiles() -> void:
	var clean := true
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Voile Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("V"):
				clean = false
		var state := Puzzles.initial_state(i)
		for y in state["h"]:
			for x in state["w"]:
				if Rules.tile_at(state, x, y) == Rules.Tile.VOILE:
					clean = false
	_check(clean, "earlier wings have no voiles")


func _check_lit_voile() -> void:
	var index := _voile_room("The Lit Voile")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.VOILE)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(3, 3) and lit.has(cell) and not Rules.watched_tiles(state, lit).has(cell), "the lit voile is lit")
	_check(_spec_result(state, "U") == "stop" and _spec_result(state, spec) == "win" and not _visited(state, puzzle, cell), "the early step onto the lit voile succeeds, and the solution walks around it")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GAUZE), "U") == "lit", "a gauze refuses that early step, because an unwatched lit gauze is closed")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SCREEN), spec) == "lit", "a screen shines past a lamp standing on it, so the around-path is refused")


func _check_seen_weave() -> void:
	var index := _voile_room("The Seen Weave")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.VOILE)
	var gap := Vector2i(3, 1)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(3, 2) and lit.has(cell) and Rules.watched_tiles(state, lit).has(gap), "the guard sees a lit tile through the lit voile")
	_check(Rules.watched_tiles(_with_tile(state, cell.x, cell.y, Rules.Tile.BAIZE)).has(gap), "a baize stays dark and still lets the sight through")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, gap) and _stepped_on_while_dark(state, puzzle, cell), "the solution crosses the voile only after the snuff")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.BAIZE), spec) == "watched", "a baize does not clear the seen weave")


func _check_passed_spark() -> void:
	var index := _voile_room("The Passed Spark")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.VOILE)
	var gap := Vector2i(2, 2)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	var scrim := _with_tile(state, cell.x, cell.y, Rules.Tile.SCRIM)
	_check(state["lamps"].size() == 2 and int(state["lamps"][1]["radius"]) == 2 and cell == Vector2i(2, 3), "the second lamp is the one whose light passes the voile")
	_check(lit.has(cell) and lit.has(gap), "a second lamp's light passes the voile")
	_check(not Rules.light_map(scrim).has(gap) and _spec_result(scrim, spec) == "darkgap", "a scrim still stops the second lamp")
	_check(_spec_result(state, spec) == "win" and _stepped_on_while_dark(state, puzzle, cell), "you snuff, step on the dark voile, relight, and cross the gap")


func _check_shut_voile() -> void:
	var index := _voile_room("The Shut Voile")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.VOILE)
	var spec := _solution_spec(puzzle)
	_check(not Rules.guard_walkable(state, cell.x, cell.y) and _spec_result(state, spec) == "win", "a guard cannot enter the voile, and the solution still leaves")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), spec) == "lit", "a curtain is lit, so the same line cannot enter it")
	_check(_spec_result(state, "R T0 R R R") == "win" and _spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), "R T0 R R R") == "guard", "a curtain is a path, so the called guard takes it")


func _check_early_step() -> void:
	var index := _voile_room("The Early Step")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.VOILE)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(3, 2) and lit.has(cell) and not Rules.watched_tiles(state, lit).has(cell), "the early step is an unwatched lit voile")
	_check(_spec_result(state, "U") == "stop" and _spec_result(state, spec) == "win" and _visited(state, puzzle, cell), "the early step onto the lit voile succeeds")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GAUZE), spec) == "lit", "a gauze does not clear the early step, because that lit step is refused")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SHADE), spec) == "win", "a shade also accepts the step, because a shade stays dark")


func _check_last_voile() -> void:
	var index := _voile_room("The Last Voile")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.VOILE)
	var spec := _solution_spec(puzzle)
	_check(_spec_result(state, "R") == "lit" and _spec_result(state, spec) == "win" and _visited(state, puzzle, cell) and _stepped_on_while_dark(state, puzzle, cell), "you leave by stepping on the dark voile")


func _check_voile_early_step_succeeds() -> void:
	var rows := PackedStringArray(["######", "#.SV.#", "######"])
	var lamps: Array = [{"x": 4, "y": 1, "facing": "w", "radius": 1, "lit": true}]
	var state := Rules.build(rows, lamps, [{"x": 1, "y": 1, "vision": 0, "rail": [Vector2i(1, 1)]}])
	var cell := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	_check(lit.has(cell) and stepped["result"] == Rules.Result.OK and int(stepped["called"]) == -1, "an unwatched lit voile can be entered, and that step calls nobody")
	var gauze := _with_tile(state, cell.x, cell.y, Rules.Tile.GAUZE)
	var refused: Dictionary = Rules.apply(gauze, {"type": "move", "dx": 1, "dy": 0})
	_check(refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "lit", "the same step onto a lit gauze fails")
	var watched := Rules.build(rows, lamps, [{"x": 4, "y": 1, "vision": 2, "rail": [Vector2i(4, 1)]}])
	var loss: Dictionary = Rules.apply(watched, {"type": "move", "dx": 1, "dy": 0})
	_check(loss["result"] == Rules.Result.LOSS and loss["reason"] == "watched", "a lit voile a guard is watching is still a loss")


func _check_lawn_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Lawn Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_lawn_rooms() -> void:
	_check_lawn_identity()
	_check_earlier_wings_have_no_lawns()
	_check_lit_lawn()
	_check_seen_sward()
	_check_halted_gleam()
	_check_barred_lawn()
	_check_early_tread()
	_check_last_lawn()
	_check_lawn_early_step_succeeds()


func _check_lawn_identity() -> void:
	var seen := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Lawn Wing":
			continue
		var rows := ""
		for row in puzzle["rows"]:
			rows += str(row)
		if seen.has(rows):
			layout_ok = false
		seen[rows] = true
		var title := str(puzzle["title"])
		if titles.has(title):
			title_ok = false
		titles[title] = true
	var once := true
	var wing_titles: Array = titles.keys()
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Lawn Wing":
			continue
		if titles.has(str(puzzle["title"])):
			once = false
	_check(layout_ok, "each lawn room has its own layout")
	_check(title_ok, "each lawn room has its own name")
	_check(once and wing_titles.size() == 6, "the lawn titles are not reused")


func _lawn_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Lawn Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_lawns() -> void:
	var clean := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Lawn Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("L"):
				clean = false
	_check(clean, "earlier wings have no lawns")


func _check_lit_lawn() -> void:
	var index := _lawn_room("The Lit Lawn")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.LAWN)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(3, 2) and lit.has(cell) and not Rules.watched_tiles(state, lit).has(cell), "the lit lawn is lit")
	_check(_spec_result(state, "U") == "stop" and _spec_result(state, spec) == "win" and not _visited(state, puzzle, cell), "the early step onto the lit lawn succeeds, and the solution walks around it")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GAUZE), "U") == "lit", "the same early step onto a lit gauze fails")


func _check_seen_sward() -> void:
	var index := _lawn_room("The Seen Sward")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.LAWN)
	var gap := _find_tile(state, Rules.Tile.GAP)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(3, 2) and lit.has(cell) and Rules.watched_tiles(state, lit).has(gap), "the guard sees a lit tile through the lit lawn")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, gap) and _stepped_on_while_dark(state, puzzle, cell), "the solution crosses the lawn only after the snuff")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.BAIZE), spec) == "watched", "a baize still lets the sight through after the snuff")


func _check_halted_gleam() -> void:
	var index := _lawn_room("The Halted Gleam")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.LAWN)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	var past := Vector2i(5, 2)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(toggles == 0 and state["lamps"].size() == 2 and cell == Vector2i(5, 3), "the halted gleam leaves the second lamp burning")
	_check(lit.has(cell) and not lit.has(past), "a second lamp's light stops at the lawn")
	_check(Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.VOILE)).has(past), "a voile lets that second lamp pass")
	_check(_spec_result(state, spec) == "win", "the solution walks the floor the lawn kept dark")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.VOILE), spec) == "lit", "a voile does not clear the halted gleam, because its second lamp passes")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GAUZE), spec) == "lit", "a gauze does not clear the halted gleam, because its second lamp passes")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SCRIM), spec) == "win", "a scrim also stops the light, so the same line still clears")


func _check_barred_lawn() -> void:
	var index := _lawn_room("The Barred Lawn")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.LAWN)
	var spec := _solution_spec(puzzle)
	_check(not Rules.guard_walkable(state, cell.x, cell.y) and _spec_result(state, spec) == "win", "a guard cannot enter the lawn, and the solution still leaves")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), spec) == "lit", "a curtain is lit, so the same line cannot enter it")
	_check(_spec_result(state, "R T0 R R R") == "win" and _spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.CURTAIN), "R T0 R R R") == "guard", "a curtain is a path, so the called guard takes it")


func _check_early_tread() -> void:
	var index := _lawn_room("The Early Tread")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.LAWN)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(3, 2) and lit.has(cell) and not Rules.watched_tiles(state, lit).has(cell), "the early tread is an unwatched lit lawn")
	_check(_spec_result(state, "U") == "stop" and _spec_result(state, spec) == "win" and _visited(state, puzzle, cell), "the early step onto the lit lawn succeeds")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.SCRIM), spec) == "lit", "a scrim does not clear the early tread, because the early step onto a lit scrim fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GAUZE), spec) == "lit", "a gauze does not clear the early tread, because the early step onto a lit gauze fails")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.VOILE), spec) == "win", "a voile also accepts the early step, so the same line still clears")


func _check_last_lawn() -> void:
	var index := _lawn_room("The Last Lawn")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.LAWN)
	var spec := _solution_spec(puzzle)
	_check(_spec_result(state, "R") == "lit" and _spec_result(state, spec) == "win" and _visited(state, puzzle, cell) and _stepped_on_while_dark(state, puzzle, cell), "you leave by stepping on the dark lawn")


func _check_lawn_early_step_succeeds() -> void:
	var rows := PackedStringArray(["######", "#.SL.#", "######"])
	var lamps: Array = [{"x": 4, "y": 1, "facing": "w", "radius": 2, "lit": true}]
	var state := Rules.build(rows, lamps, [{"x": 1, "y": 1, "vision": 0, "rail": [Vector2i(1, 1)]}])
	var cell := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	_check(lit.has(cell) and not lit.has(Vector2i(2, 1)) and stepped["result"] == Rules.Result.OK and int(stepped["called"]) == -1, "an unwatched lit lawn can be entered, the light stops, and that step calls nobody")
	var scrim := _with_tile(state, cell.x, cell.y, Rules.Tile.SCRIM)
	var refused: Dictionary = Rules.apply(scrim, {"type": "move", "dx": 1, "dy": 0})
	_check(refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "lit", "the same step onto a lit scrim fails")
	var watched := Rules.build(rows, lamps, [{"x": 4, "y": 1, "vision": 2, "rail": [Vector2i(4, 1)]}])
	var loss: Dictionary = Rules.apply(watched, {"type": "move", "dx": 1, "dy": 0})
	_check(loss["result"] == Rules.Result.LOSS and loss["reason"] == "watched", "a lit lawn a guard is watching is still a loss")


func _check_muslin_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Muslin Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_muslin_rooms() -> void:
	_check_muslin_identity()
	_check_earlier_wings_have_no_muslins()
	_check_lit_muslin()
	_check_seen_warp()
	_check_halted_sheen()
	_check_open_muslin()
	_check_refused_entry()
	_check_last_muslin()
	_check_muslin_early_step_fails()


func _check_muslin_identity() -> void:
	var seen := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Muslin Wing":
			continue
		var rows := ""
		for row in puzzle["rows"]:
			rows += str(row)
		if seen.has(rows):
			layout_ok = false
		seen[rows] = true
		var title := str(puzzle["title"])
		if titles.has(title):
			title_ok = false
		titles[title] = true
	var once := true
	var wing_titles: Array = titles.keys()
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Muslin Wing":
			continue
		if titles.has(str(puzzle["title"])):
			once = false
	_check(layout_ok, "each muslin room has its own layout")
	_check(title_ok, "each muslin room has its own name")
	_check(once and wing_titles.size() == 6, "the muslin titles are not reused")


func _muslin_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Muslin Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_muslins() -> void:
	var clean := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Muslin Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("N"):
				clean = false
	_check(clean, "earlier wings have no muslins")


func _lawn_swap(state: Dictionary, cell: Vector2i) -> Dictionary:
	return _with_tile(state, cell.x, cell.y, Rules.Tile.LAWN)


func _check_lit_muslin() -> void:
	var index := _muslin_room("The Lit Muslin")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.MUSLIN)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(2, 1) and lit.has(cell), "the lit muslin is lit")
	_check(_spec_result(state, spec) == "win" and not _visited(state, puzzle, cell), "the solution leaves without stepping on the lit muslin")
	_check(_spec_result(_lawn_swap(state, cell), spec) == "guard", "a lawn does not clear the lit muslin, because a guard cannot enter it")


func _check_seen_warp() -> void:
	var index := _muslin_room("The Seen Warp")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.MUSLIN)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(cell) and lit.has(Vector2i(3, 1)) and Rules.watched_tiles(state, lit).has(Vector2i(3, 1)), "the guard sees a lit tile through the lit muslin")
	_check(_spec_result(state, spec) == "win", "the solution snuffs before it crosses")
	_check(_spec_result(_lawn_swap(state, cell), spec) == "guard", "a lawn does not clear the seen warp")


func _check_halted_sheen() -> void:
	var index := _muslin_room("The Halted Sheen")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.MUSLIN)
	var spec := _solution_spec(puzzle)
	var past := Vector2i(2, 3)
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(cell) and not lit.has(past), "a second lamp's light stops at the muslin")
	_check(Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.VOILE)).has(past), "a voile lets that second lamp pass")
	_check(_spec_result(state, spec) == "win", "the solution walks the floor the muslin kept dark")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.VOILE), spec) == "lit", "a voile does not clear the halted sheen, because its second lamp passes")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GAUZE), spec) == "lit", "a gauze does not clear the halted sheen, because its second lamp passes")
	_check(_spec_result(_lawn_swap(state, cell), spec) == "guard", "a lawn does not clear the halted sheen")


func _check_open_muslin() -> void:
	var index := _muslin_room("The Open Muslin")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.MUSLIN)
	var spec := _solution_spec(puzzle)
	var lawn := _lawn_swap(state, cell)
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(lawn, cell.x, cell.y), "a guard can enter the muslin, and a guard cannot enter the lawn")
	_check(_spec_result(state, spec) == "win" and _spec_result(lawn, spec) == "guard", "a lawn does not clear the open muslin, because the guard cannot enter it")


func _check_refused_entry() -> void:
	var index := _muslin_room("The Refused Entry")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.MUSLIN)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(cell) and _spec_result(state, "U") == "lit", "the early step onto the lit muslin fails")
	_check(_spec_result(_lawn_swap(state, cell), "U") == "stop", "the same early step onto a lit lawn succeeds")
	_check(_spec_result(state, spec) == "win" and _spec_result(_lawn_swap(state, cell), spec) == "guard", "a lawn does not clear the refused entry")


func _check_last_muslin() -> void:
	var index := _muslin_room("The Last Muslin")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.MUSLIN)
	var spec := _solution_spec(puzzle)
	_check(_spec_result(state, "L") == "lit" and _spec_result(state, spec) == "win" and _visited(state, puzzle, cell) and _stepped_on_while_dark(state, puzzle, cell), "you leave by stepping on the dark muslin")
	_check(_spec_result(_lawn_swap(state, cell), spec) == "guard", "a lawn does not clear the last muslin")


func _check_muslin_early_step_fails() -> void:
	var rows := PackedStringArray(["######", "#.SN.#", "######"])
	var lamps: Array = [{"x": 4, "y": 1, "facing": "w", "radius": 2, "lit": true}]
	var state := Rules.build(rows, lamps, [{"x": 1, "y": 1, "vision": 0, "rail": [Vector2i(1, 1)]}])
	var cell := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	_check(lit.has(cell) and not lit.has(Vector2i(2, 1)) and stepped["result"] == Rules.Result.ILLEGAL and stepped["reason"] == "lit", "an unwatched lit muslin is refused, and the light stops")
	var lawn := _with_tile(state, cell.x, cell.y, Rules.Tile.LAWN)
	var allowed: Dictionary = Rules.apply(lawn, {"type": "move", "dx": 1, "dy": 0})
	_check(allowed["result"] == Rules.Result.OK, "the same step onto a lit lawn succeeds")
	_check(Rules.guard_walkable(state, cell.x, cell.y), "the muslin is a path a guard can enter")


func _check_cambric_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Cambric Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_cambric_rooms() -> void:
	_check_cambric_identity()
	_check_earlier_wings_have_no_cambrics()
	_check_lit_cambric()
	_check_seen_weft()
	_check_halted_glow()
	_check_walked_cambric()
	_check_sure_landing()
	_check_last_cambric()
	_check_cambric_early_step_succeeds()


func _check_cambric_identity() -> void:
	var seen := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Cambric Wing":
			continue
		var rows := ""
		for row in puzzle["rows"]:
			rows += str(row)
		if seen.has(rows):
			layout_ok = false
		seen[rows] = true
		var title := str(puzzle["title"])
		if titles.has(title):
			title_ok = false
		titles[title] = true
	var once := true
	var wing_titles: Array = titles.keys()
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Cambric Wing":
			continue
		if titles.has(str(puzzle["title"])):
			once = false
	_check(layout_ok, "each cambric room has its own layout")
	_check(title_ok, "each cambric room has its own name")
	_check(once and wing_titles.size() == 6, "the cambric titles are not reused")


func _cambric_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Cambric Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_cambrics() -> void:
	var clean := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Cambric Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("Y"):
				clean = false
	_check(clean, "earlier wings have no cambrics")


func _cambric_swap(state: Dictionary, kind: int) -> Dictionary:
	var copy := Rules.clone(state)
	for i in copy["tiles"].size():
		if copy["tiles"][i] == Rules.Tile.CAMBRIC:
			copy["tiles"][i] = kind
	return copy


func _check_lit_cambric() -> void:
	var index := _cambric_room("The Lit Cambric")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.CAMBRIC)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(2, 1) and lit.has(cell), "the lit cambric is lit")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, cell), "the solution steps on the lit cambric and leaves")
	_check(_spec_result(_cambric_swap(state, Rules.Tile.MUSLIN), spec) == "lit", "a muslin does not clear the lit cambric, because the early step fails")
	_check(_spec_result(_cambric_swap(state, Rules.Tile.LAWN), spec) == "guard", "a lawn does not clear the lit cambric, because a guard cannot enter it")


func _check_seen_weft() -> void:
	var index := _cambric_room("The Seen Weft")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	var cloth := Vector2i(7, 2)
	var beyond := Vector2i(7, 1)
	_check(lit.has(cloth) and lit.has(beyond) and Rules.watched_tiles(state, lit).has(beyond), "the guard sees a lit tile through the lit cambric")
	_check(_spec_result(state, spec) == "win", "the solution leaves the seen weft")
	_check(_spec_result(_cambric_swap(state, Rules.Tile.MUSLIN), spec) != "win", "a muslin does not clear the seen weft")
	_check(_spec_result(_cambric_swap(state, Rules.Tile.LAWN), spec) != "win", "a lawn does not clear the seen weft")


func _check_halted_glow() -> void:
	var index := _cambric_room("The Halted Glow")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.CAMBRIC)
	var spec := _solution_spec(puzzle)
	var past := Vector2i(2, 3)
	var lit: Dictionary = Rules.light_map(state)
	var toggles := 0
	for action in puzzle["solution"]:
		if str(action["type"]) == "toggle":
			toggles += 1
	_check(lit.has(cell) and not lit.has(past) and toggles == 1, "a second lamp's light stops at the cambric")
	_check(Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.VOILE)).has(past), "a voile lets that second lamp pass")
	_check(_spec_result(state, spec) == "win", "the solution walks the floor the cambric kept dark")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.VOILE), spec) == "lit", "a voile does not clear the halted glow, because its second lamp passes")
	_check(_spec_result(_with_tile(state, cell.x, cell.y, Rules.Tile.GAUZE), spec) == "lit", "a gauze does not clear the halted glow, because its second lamp passes")
	_check(_spec_result(_cambric_swap(state, Rules.Tile.MUSLIN), spec) == "lit", "a muslin does not clear the halted glow")
	_check(_spec_result(_cambric_swap(state, Rules.Tile.LAWN), spec) == "guard", "a lawn does not clear the halted glow")


func _check_walked_cambric() -> void:
	var index := _cambric_room("The Walked Cambric")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.CAMBRIC)
	var spec := _solution_spec(puzzle)
	var lawn := _cambric_swap(state, Rules.Tile.LAWN)
	var through: Array = Rules.bfs_path(state, 1, 1, 3, 1)["path"]
	var around: Array = Rules.bfs_path(lawn, 1, 1, 3, 1)["path"]
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(lawn, cell.x, cell.y), "a guard can enter the cambric, and a guard cannot enter the lawn")
	_check(_path_has(through, cell) and not _path_has(around, cell), "the called guard walks the cambric and walks around a lawn")
	_check(_spec_result(state, spec) == "win", "the solution clears the walked cambric")
	_check(_spec_result(_cambric_swap(state, Rules.Tile.MUSLIN), spec) == "lit", "a muslin does not clear the walked cambric")
	_check(_spec_result(lawn, spec) == "guard", "a lawn does not clear the walked cambric, because the guard cannot enter it")


func _check_sure_landing() -> void:
	var index := _cambric_room("The Sure Landing")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.CAMBRIC)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(cell) and _spec_result(state, "U") == "stop", "the early step onto the lit cambric succeeds")
	_check(_spec_result(_cambric_swap(state, Rules.Tile.MUSLIN), "U") == "lit", "the same early step onto a lit muslin fails")
	_check(_spec_result(_cambric_swap(state, Rules.Tile.LAWN), "U") == "stop", "the same early step onto a lit lawn succeeds")
	_check(_spec_result(state, spec) == "win", "the solution clears the sure landing")
	_check(_spec_result(_cambric_swap(state, Rules.Tile.MUSLIN), spec) == "lit", "a muslin does not clear the sure landing")
	_check(_spec_result(_cambric_swap(state, Rules.Tile.LAWN), spec) == "guard", "a lawn does not clear the sure landing")


func _check_last_cambric() -> void:
	var index := _cambric_room("The Last Cambric")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.CAMBRIC)
	var spec := _solution_spec(puzzle)
	_check(_spec_result(state, "U") == "stop" and _spec_result(state, spec) == "win" and _visited(state, puzzle, cell) and _stepped_on_while_dark(state, puzzle, cell), "you leave by stepping on the dark cambric")
	_check(_spec_result(_cambric_swap(state, Rules.Tile.MUSLIN), spec) == "lit", "a muslin does not clear the last cambric")
	_check(_spec_result(_cambric_swap(state, Rules.Tile.LAWN), spec) == "guard", "a lawn does not clear the last cambric")


func _check_cambric_early_step_succeeds() -> void:
	var rows := PackedStringArray(["######", "#.SY.#", "######"])
	var lamps: Array = [{"x": 4, "y": 1, "facing": "w", "radius": 2, "lit": true}]
	var state := Rules.build(rows, lamps, [{"x": 1, "y": 1, "vision": 0, "rail": [Vector2i(1, 1)]}])
	var cell := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	_check(lit.has(cell) and not lit.has(Vector2i(2, 1)) and stepped["result"] == Rules.Result.OK, "an unwatched lit cambric can be entered, and the light stops")
	var muslin := _with_tile(state, cell.x, cell.y, Rules.Tile.MUSLIN)
	var refused: Dictionary = Rules.apply(muslin, {"type": "move", "dx": 1, "dy": 0})
	_check(refused["result"] == Rules.Result.ILLEGAL and refused["reason"] == "lit", "the same step onto a lit muslin fails")
	_check(Rules.guard_walkable(state, cell.x, cell.y), "the cambric is a path a guard can enter")


func _check_holland_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Holland Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_holland_rooms() -> void:
	_check_holland_identity()
	_check_earlier_wings_have_no_hollands()
	_check_lit_holland()
	_check_seen_grain()
	_check_passed_ray()
	_check_trod_holland()
	_check_firm_footing()
	_check_last_holland()
	_check_holland_early_step_succeeds()


func _check_holland_identity() -> void:
	var seen := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Holland Wing":
			continue
		var rows := ""
		for row in puzzle["rows"]:
			rows += str(row)
		if seen.has(rows):
			layout_ok = false
		seen[rows] = true
		var title := str(puzzle["title"])
		if titles.has(title):
			title_ok = false
		titles[title] = true
	var once := true
	var wing_titles: Array = titles.keys()
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Holland Wing":
			continue
		if titles.has(str(puzzle["title"])):
			once = false
	_check(layout_ok, "each holland room has its own layout")
	_check(title_ok, "each holland room has its own name")
	_check(once and wing_titles.size() == 6, "the holland titles are not reused")


func _holland_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Holland Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_hollands() -> void:
	var clean := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Holland Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("O"):
				clean = false
	_check(clean, "earlier wings have no hollands")


func _holland_swap(state: Dictionary, kind: int) -> Dictionary:
	var copy := Rules.clone(state)
	for i in copy["tiles"].size():
		if copy["tiles"][i] == Rules.Tile.HOLLAND:
			copy["tiles"][i] = kind
	return copy


func _check_lit_holland() -> void:
	var index := _holland_room("The Lit Holland")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.HOLLAND)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(2, 1) and lit.has(cell), "the lit holland is lit")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, cell), "the solution steps on the lit holland and leaves")
	_check(_spec_result(_holland_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the lit holland, because the light stops")
	_check(_spec_result(_holland_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the lit holland, because a guard cannot enter it")


func _check_seen_grain() -> void:
	var index := _holland_room("The Seen Grain")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	var cloth := Vector2i(3, 7)
	var beyond := Vector2i(3, 6)
	_check(lit.has(cloth) and lit.has(beyond) and Rules.watched_tiles(state, lit).has(beyond), "the guard sees a lit tile through the lit holland")
	_check(_spec_result(state, spec) == "win", "the solution leaves the seen grain")
	_check(_spec_result(_holland_swap(state, Rules.Tile.CAMBRIC), spec) != "win", "a cambric does not clear the seen grain")
	_check(_spec_result(_holland_swap(state, Rules.Tile.VOILE), spec) != "win", "a voile does not clear the seen grain")


func _check_passed_ray() -> void:
	var index := _holland_room("The Passed Ray")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.HOLLAND)
	var spec := _solution_spec(puzzle)
	var past := Vector2i(2, 3)
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(cell) and lit.has(past), "a second lamp's light passes through the holland")
	_check(not Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.CAMBRIC)).has(past), "a cambric stops that second lamp")
	_check(_spec_result(state, spec) == "win", "the solution crosses the lit gap past the holland")
	_check(_spec_result(_holland_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the passed ray, because its second lamp stops")
	_check(_spec_result(_holland_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the passed ray")


func _check_trod_holland() -> void:
	var index := _holland_room("The Trod Holland")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.HOLLAND)
	var spec := _solution_spec(puzzle)
	var voile := _holland_swap(state, Rules.Tile.VOILE)
	var through: Array = Rules.bfs_path(state, 1, 1, 3, 1)["path"]
	var around: Array = Rules.bfs_path(voile, 1, 1, 3, 1)["path"]
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(voile, cell.x, cell.y), "a guard can enter the holland, and a guard cannot enter the voile")
	_check(_path_has(through, cell) and not _path_has(around, cell), "the called guard walks the holland and walks around a voile")
	_check(_spec_result(state, spec) == "win", "the solution clears the trod holland")
	_check(_spec_result(_holland_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the trod holland")
	_check(_spec_result(voile, spec) == "guard", "a voile does not clear the trod holland, because the guard cannot enter it")


func _check_firm_footing() -> void:
	var index := _holland_room("The Firm Footing")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.HOLLAND)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(cell) and _spec_result(state, "U U") == "stop", "the early step onto the lit holland succeeds")
	_check(_spec_result(_holland_swap(state, Rules.Tile.CAMBRIC), "U") == "darkgap", "the same opening step onto a cambric finds the gap dark")
	_check(_spec_result(state, spec) == "win", "the solution clears the firm footing")
	_check(_spec_result(_holland_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the firm footing")
	_check(_spec_result(_holland_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the firm footing")


func _check_last_holland() -> void:
	var index := _holland_room("The Last Holland")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := Vector2i(5, 4)
	var spec := _solution_spec(puzzle)
	_check(Rules.tile_at(state, cell.x, cell.y) == Rules.Tile.HOLLAND and _spec_result(state, spec) == "win" and _visited(state, puzzle, cell) and _stepped_on_while_dark(state, puzzle, cell), "you leave by stepping on the dark holland")
	_check(_spec_result(_holland_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the last holland")
	_check(_spec_result(_holland_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the last holland")


func _check_holland_early_step_succeeds() -> void:
	var rows := PackedStringArray(["######", "#.SO.#", "######"])
	var lamps: Array = [{"x": 4, "y": 1, "facing": "w", "radius": 2, "lit": true}]
	var state := Rules.build(rows, lamps, [{"x": 1, "y": 1, "vision": 0, "rail": [Vector2i(1, 1)]}])
	var cell := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var cambric := _with_tile(state, cell.x, cell.y, Rules.Tile.CAMBRIC)
	_check(lit.has(cell) and lit.has(Vector2i(2, 1)) and stepped["result"] == Rules.Result.OK, "an unwatched lit holland can be entered, and the light passes")
	_check(not Rules.light_map(cambric).has(Vector2i(2, 1)), "a second lamp's light passes a holland and stops at a cambric")
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(_with_tile(state, cell.x, cell.y, Rules.Tile.VOILE), cell.x, cell.y), "a guard can enter the holland and cannot enter a voile")


func _check_buckram_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Buckram Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_buckram_rooms() -> void:
	_check_buckram_identity()
	_check_earlier_wings_have_no_buckrams()
	_check_lit_buckram()
	_check_seen_rib()
	_check_passed_beam()
	_check_open_buckram()
	_check_barred_step()
	_check_last_buckram()
	_check_buckram_early_step_fails()


func _check_buckram_identity() -> void:
	var seen := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Buckram Wing":
			continue
		var rows := ""
		for row in puzzle["rows"]:
			rows += str(row)
		if seen.has(rows):
			layout_ok = false
		seen[rows] = true
		var title := str(puzzle["title"])
		if titles.has(title):
			title_ok = false
		titles[title] = true
	var once := true
	var wing_titles: Array = titles.keys()
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Buckram Wing":
			continue
		if titles.has(str(puzzle["title"])):
			once = false
	_check(layout_ok, "each buckram room has its own layout")
	_check(title_ok, "each buckram room has its own name")
	_check(once and wing_titles.size() == 6, "the buckram titles are not reused")


func _buckram_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Buckram Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_buckrams() -> void:
	var clean := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Buckram Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("F"):
				clean = false
	_check(clean, "earlier wings have no buckrams")


func _buckram_swap(state: Dictionary, kind: int) -> Dictionary:
	var copy := Rules.clone(state)
	for i in copy["tiles"].size():
		if copy["tiles"][i] == Rules.Tile.BUCKRAM:
			copy["tiles"][i] = kind
	return copy


func _check_lit_buckram() -> void:
	var index := _buckram_room("The Lit Buckram")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.BUCKRAM)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(2, 1) and lit.has(cell), "the lit buckram is lit")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, Vector2i(3, 3)), "the solution crosses the lit gap and leaves")
	_check(_spec_result(_buckram_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the lit buckram, because the light stops")
	_check(_spec_result(_buckram_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the lit buckram, because a guard cannot enter it")


func _check_seen_rib() -> void:
	var index := _buckram_room("The Seen Rib")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	var cloth := Vector2i(3, 7)
	var beyond := Vector2i(3, 6)
	_check(lit.has(cloth) and lit.has(beyond) and Rules.watched_tiles(state, lit).has(beyond), "the guard sees a lit tile through the lit buckram")
	_check(_spec_result(state, spec) == "win", "the solution leaves the seen rib")
	_check(_spec_result(_buckram_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the seen rib")
	_check(_spec_result(_buckram_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the seen rib")


func _check_passed_beam() -> void:
	var index := _buckram_room("The Passed Beam")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.BUCKRAM)
	var spec := _solution_spec(puzzle)
	var past := Vector2i(3, 4)
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(cell) and lit.has(past), "a second lamp's light passes through the buckram")
	_check(not Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.CAMBRIC)).has(past), "a cambric stops that second lamp")
	_check(_spec_result(state, spec) == "win", "the solution crosses the lit gap past the buckram")
	_check(_spec_result(_buckram_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the passed beam, because its second lamp stops")
	_check(_spec_result(_buckram_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the passed beam")


func _check_open_buckram() -> void:
	var index := _buckram_room("The Open Buckram")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.BUCKRAM)
	var spec := _solution_spec(puzzle)
	var voile := _buckram_swap(state, Rules.Tile.VOILE)
	var through: Array = Rules.bfs_path(state, 1, 1, 3, 1)["path"]
	var around: Array = Rules.bfs_path(voile, 1, 1, 3, 1)["path"]
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(voile, cell.x, cell.y), "a guard can enter the buckram, and a guard cannot enter the voile")
	_check(_path_has(through, cell) and not _path_has(around, cell), "the called guard walks the buckram and walks around a voile")
	_check(_spec_result(state, spec) == "win", "the solution clears the open buckram")
	_check(_spec_result(_buckram_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the open buckram")
	_check(_spec_result(voile, spec) == "guard", "a voile does not clear the open buckram, because the guard cannot enter it")


func _check_barred_step() -> void:
	var index := _buckram_room("The Barred Step")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var beside := Rules.clone(state)
	beside["player"]["x"] = 2
	beside["player"]["y"] = 2
	var refused: Dictionary = Rules.apply(beside, {"type": "move", "dx": 0, "dy": -1})
	var allowed: Dictionary = Rules.apply(_buckram_swap(beside, Rules.Tile.HOLLAND), {"type": "move", "dx": 0, "dy": -1})
	_check(Rules.light_map(beside).has(Vector2i(2, 1)) and refused["reason"] == "lit" and allowed["result"] == Rules.Result.OK, "the early step onto the lit buckram fails, and the same step onto a holland succeeds")
	_check(_spec_result(state, spec) == "win", "the solution clears the barred step")
	_check(_spec_result(_buckram_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the barred step")
	_check(_spec_result(_buckram_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the barred step")


func _check_last_buckram() -> void:
	var index := _buckram_room("The Last Buckram")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := Vector2i(2, 5)
	var spec := _solution_spec(puzzle)
	_check(Rules.tile_at(state, cell.x, cell.y) == Rules.Tile.BUCKRAM and _spec_result(state, spec) == "win" and _visited(state, puzzle, cell) and _stepped_on_while_dark(state, puzzle, cell), "you leave by stepping on the dark buckram")
	_check(_spec_result(_buckram_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the last buckram")
	_check(_spec_result(_buckram_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the last buckram")


func _check_buckram_early_step_fails() -> void:
	var rows := PackedStringArray(["######", "#.SF.#", "######"])
	var lamps: Array = [{"x": 4, "y": 1, "facing": "w", "radius": 2, "lit": true}]
	var state := Rules.build(rows, lamps, [{"x": 1, "y": 1, "vision": 0, "rail": [Vector2i(1, 1)]}])
	var cell := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var holland := _with_tile(state, cell.x, cell.y, Rules.Tile.HOLLAND)
	var cambric := _with_tile(state, cell.x, cell.y, Rules.Tile.CAMBRIC)
	_check(lit.has(cell) and stepped["reason"] == "lit" and Rules.apply(holland, {"type": "move", "dx": 1, "dy": 0})["result"] == Rules.Result.OK, "an unwatched lit buckram is refused, and the same step onto a holland succeeds")
	_check(lit.has(Vector2i(2, 1)) and not Rules.light_map(cambric).has(Vector2i(2, 1)), "a second lamp's light passes a buckram and stops at a cambric")
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(_with_tile(state, cell.x, cell.y, Rules.Tile.VOILE), cell.x, cell.y), "a guard can enter the buckram and cannot enter a voile")


func _check_ticking_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Ticking Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_ticking_rooms() -> void:
	_check_ticking_identity()
	_check_earlier_wings_have_no_tickings()
	_check_lit_ticking()
	_check_hidden_stripe()
	_check_passed_stripe()
	_check_open_ticking()
	_check_clear_step()
	_check_last_ticking()
	_check_ticking_early_step_succeeds()


func _check_ticking_identity() -> void:
	var seen := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Ticking Wing":
			continue
		var rows := ""
		for row in puzzle["rows"]:
			rows += str(row)
		if seen.has(rows):
			layout_ok = false
		seen[rows] = true
		var title := str(puzzle["title"])
		if titles.has(title):
			title_ok = false
		titles[title] = true
	var once := true
	var wing_titles: Array = titles.keys()
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Ticking Wing":
			continue
		if titles.has(str(puzzle["title"])):
			once = false
	_check(layout_ok, "each ticking room has its own layout")
	_check(title_ok, "each ticking room has its own name")
	_check(once and wing_titles.size() == 6, "the ticking titles are not reused")


func _ticking_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Ticking Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_tickings() -> void:
	var clean := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Ticking Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("T"):
				clean = false
	_check(clean, "earlier wings have no tickings")


func _ticking_swap(state: Dictionary, kind: int) -> Dictionary:
	var copy := Rules.clone(state)
	for i in copy["tiles"].size():
		if copy["tiles"][i] == Rules.Tile.TICKING:
			copy["tiles"][i] = kind
	return copy


func _check_lit_ticking() -> void:
	var index := _ticking_room("The Lit Ticking")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.TICKING)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(2, 1) and lit.has(cell), "the lit ticking is lit")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, Vector2i(3, 3)), "the solution crosses the lit gap and leaves")
	_check(_spec_result(_ticking_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the lit ticking, because the light stops")
	_check(_spec_result(_ticking_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the lit ticking, because a guard cannot enter it")


func _check_hidden_stripe() -> void:
	var index := _ticking_room("The Hidden Stripe")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	var cloth := Vector2i(3, 7)
	var beyond := Vector2i(3, 6)
	var watched: Dictionary = Rules.watched_tiles(state, lit)
	var buckram := _ticking_swap(state, Rules.Tile.BUCKRAM)
	_check(lit.has(cloth) and lit.has(beyond) and watched.has(cloth) and not watched.has(beyond), "the guard does not see a lit tile through the lit ticking")
	_check(Rules.watched_tiles(buckram, Rules.light_map(buckram)).has(beyond), "a buckram lets the guard see that lit tile")
	_check(_spec_result(state, spec) == "win", "the solution leaves the hidden stripe")
	_check(_spec_result(_ticking_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the hidden stripe")
	_check(_spec_result(_ticking_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the hidden stripe")


func _check_passed_stripe() -> void:
	var index := _ticking_room("The Passed Stripe")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.TICKING)
	var spec := _solution_spec(puzzle)
	var past := Vector2i(3, 4)
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(cell) and lit.has(past), "a second lamp's light passes through the ticking")
	_check(not Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.CAMBRIC)).has(past), "a cambric stops that second lamp")
	_check(_spec_result(state, spec) == "win", "the solution crosses the lit gap past the ticking")
	_check(_spec_result(_ticking_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the passed stripe, because its second lamp stops")
	_check(_spec_result(_ticking_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the passed stripe")


func _check_open_ticking() -> void:
	var index := _ticking_room("The Open Ticking")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.TICKING)
	var spec := _solution_spec(puzzle)
	var voile := _ticking_swap(state, Rules.Tile.VOILE)
	var through: Array = Rules.bfs_path(state, 1, 1, 3, 1)["path"]
	var around: Array = Rules.bfs_path(voile, 1, 1, 3, 1)["path"]
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(voile, cell.x, cell.y), "a guard can enter the ticking, and a guard cannot enter the voile")
	_check(_path_has(through, cell) and not _path_has(around, cell), "the called guard walks the ticking and walks around a voile")
	_check(_spec_result(state, spec) == "win", "the solution clears the open ticking")
	_check(_spec_result(_ticking_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the open ticking")
	_check(_spec_result(voile, spec) == "guard", "a voile does not clear the open ticking, because the guard cannot enter it")


func _check_clear_step() -> void:
	var index := _ticking_room("The Clear Step")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var beside := Rules.clone(state)
	beside["player"]["x"] = 2
	beside["player"]["y"] = 2
	var allowed: Dictionary = Rules.apply(beside, {"type": "move", "dx": 0, "dy": -1})
	var refused: Dictionary = Rules.apply(_ticking_swap(beside, Rules.Tile.BUCKRAM), {"type": "move", "dx": 0, "dy": -1})
	_check(Rules.light_map(beside).has(Vector2i(2, 1)) and allowed["result"] == Rules.Result.OK and refused["reason"] == "lit", "the early step onto the lit ticking succeeds, and the same step onto a buckram fails")
	_check(_spec_result(state, spec) == "win", "the solution clears the clear step")
	_check(_spec_result(_ticking_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the clear step")
	_check(_spec_result(_ticking_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the clear step")


func _check_last_ticking() -> void:
	var index := _ticking_room("The Last Ticking")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := Vector2i(2, 5)
	var spec := _solution_spec(puzzle)
	_check(Rules.tile_at(state, cell.x, cell.y) == Rules.Tile.TICKING and _spec_result(state, spec) == "win" and _visited(state, puzzle, cell) and _stepped_on_while_dark(state, puzzle, cell), "you leave by stepping on the dark ticking")
	_check(_spec_result(_ticking_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the last ticking")
	_check(_spec_result(_ticking_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the last ticking")


func _check_ticking_early_step_succeeds() -> void:
	var rows := PackedStringArray(["######", "#.ST.#", "######"])
	var lamps: Array = [{"x": 4, "y": 1, "facing": "w", "radius": 2, "lit": true}]
	var state := Rules.build(rows, lamps, [{"x": 1, "y": 1, "vision": 0, "rail": [Vector2i(1, 1)]}])
	var cell := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var buckram := _with_tile(state, cell.x, cell.y, Rules.Tile.BUCKRAM)
	var cambric := _with_tile(state, cell.x, cell.y, Rules.Tile.CAMBRIC)
	_check(lit.has(cell) and stepped["result"] == Rules.Result.OK and Rules.apply(buckram, {"type": "move", "dx": 1, "dy": 0})["reason"] == "lit", "an unwatched lit ticking can be entered, and the same step onto a buckram fails")
	_check(lit.has(Vector2i(2, 1)) and not Rules.light_map(cambric).has(Vector2i(2, 1)), "a second lamp's light passes a ticking and stops at a cambric")
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(_with_tile(state, cell.x, cell.y, Rules.Tile.VOILE), cell.x, cell.y), "a guard can enter the ticking and cannot enter a voile")


func _check_denim_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Denim Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_denim_rooms() -> void:
	_check_denim_identity()
	_check_earlier_wings_have_no_denims()
	_check_lit_denim()
	_check_seen_twill()
	_check_passed_seam()
	_check_open_denim()
	_check_sure_tread()
	_check_last_denim()
	_check_denim_early_step_succeeds()


func _check_denim_identity() -> void:
	var seen := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Denim Wing":
			continue
		var rows := ""
		for row in puzzle["rows"]:
			rows += str(row)
		if seen.has(rows):
			layout_ok = false
		seen[rows] = true
		var title := str(puzzle["title"])
		if titles.has(title):
			title_ok = false
		titles[title] = true
	var once := true
	var wing_titles: Array = titles.keys()
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Denim Wing":
			continue
		if titles.has(str(puzzle["title"])):
			once = false
	_check(layout_ok, "each denim room has its own layout")
	_check(title_ok, "each denim room has its own name")
	_check(once and wing_titles.size() == 6, "the denim titles are not reused")


func _denim_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Denim Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_denims() -> void:
	var clean := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Denim Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("D"):
				clean = false
	_check(clean, "earlier wings have no denims")


func _denim_swap(state: Dictionary, kind: int) -> Dictionary:
	var copy := Rules.clone(state)
	for i in copy["tiles"].size():
		if copy["tiles"][i] == Rules.Tile.DENIM:
			copy["tiles"][i] = kind
	return copy


func _check_lit_denim() -> void:
	var index := _denim_room("The Lit Denim")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.DENIM)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(2, 1) and lit.has(cell), "the lit denim is lit")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, Vector2i(3, 3)), "the solution crosses the lit gap and leaves")
	_check(_spec_result(_denim_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the lit denim, because the light stops")
	_check(_spec_result(_denim_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the lit denim, because a guard cannot enter it")


func _check_seen_twill() -> void:
	var index := _denim_room("The Seen Twill")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	var cloth := Vector2i(3, 7)
	var beyond := Vector2i(3, 6)
	var watched: Dictionary = Rules.watched_tiles(state, lit)
	var ticking := _denim_swap(state, Rules.Tile.TICKING)
	_check(lit.has(cloth) and lit.has(beyond) and watched.has(beyond), "the guard sees a lit tile through the lit denim")
	_check(not Rules.watched_tiles(ticking, Rules.light_map(ticking)).has(beyond), "a ticking hides that lit tile")
	_check(_spec_result(state, spec) == "win", "the solution leaves the seen twill")
	_check(_spec_result(_denim_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the seen twill")
	_check(_spec_result(_denim_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the seen twill")


func _check_passed_seam() -> void:
	var index := _denim_room("The Passed Seam")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.DENIM)
	var spec := _solution_spec(puzzle)
	var past := Vector2i(3, 4)
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(cell) and lit.has(past), "a second lamp's light passes through the denim")
	_check(not Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.CAMBRIC)).has(past), "a cambric stops that second lamp")
	_check(_spec_result(state, spec) == "win", "the solution crosses the lit gap past the denim")
	_check(_spec_result(_denim_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the passed seam, because its second lamp stops")
	_check(_spec_result(_denim_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the passed seam")


func _check_open_denim() -> void:
	var index := _denim_room("The Open Denim")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.DENIM)
	var spec := _solution_spec(puzzle)
	var voile := _denim_swap(state, Rules.Tile.VOILE)
	var through: Array = Rules.bfs_path(state, 1, 1, 3, 1)["path"]
	var around: Array = Rules.bfs_path(voile, 1, 1, 3, 1)["path"]
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(voile, cell.x, cell.y), "a guard can enter the denim, and a guard cannot enter the voile")
	_check(_path_has(through, cell) and not _path_has(around, cell), "the called guard walks the denim and walks around a voile")
	_check(_spec_result(state, spec) == "win", "the solution clears the open denim")
	_check(_spec_result(_denim_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the open denim")
	_check(_spec_result(voile, spec) == "guard", "a voile does not clear the open denim, because the guard cannot enter it")


func _check_sure_tread() -> void:
	var index := _denim_room("The Sure Tread")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var beside := Rules.clone(state)
	beside["player"]["x"] = 2
	beside["player"]["y"] = 2
	var allowed: Dictionary = Rules.apply(beside, {"type": "move", "dx": 0, "dy": -1})
	var refused: Dictionary = Rules.apply(_denim_swap(beside, Rules.Tile.BUCKRAM), {"type": "move", "dx": 0, "dy": -1})
	_check(Rules.light_map(beside).has(Vector2i(2, 1)) and allowed["result"] == Rules.Result.OK and refused["reason"] == "lit", "the early step onto the lit denim succeeds, and the same step onto a buckram fails")
	_check(_spec_result(state, spec) == "win", "the solution clears the sure tread")
	_check(_spec_result(_denim_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the sure tread")
	_check(_spec_result(_denim_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the sure tread")


func _check_last_denim() -> void:
	var index := _denim_room("The Last Denim")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var lit_cloth := Vector2i(2, 3)
	var dark_cloth := Vector2i(2, 5)
	var spec := _solution_spec(puzzle)
	var beside := Rules.clone(state)
	beside["player"]["x"] = 2
	beside["player"]["y"] = 4
	var refused: Dictionary = Rules.apply(beside, {"type": "move", "dx": 0, "dy": 1})
	var ticking := _denim_swap(beside, Rules.Tile.TICKING)
	var allowed: Dictionary = Rules.apply(ticking, {"type": "move", "dx": 0, "dy": 1})
	_check(Rules.tile_at(state, lit_cloth.x, lit_cloth.y) == Rules.Tile.DENIM and Rules.light_map(state).has(lit_cloth) and not Rules.light_map(state).has(dark_cloth), "the leaving denim is lit and the other denim is dark")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, lit_cloth) and not _stepped_on_while_dark(state, puzzle, lit_cloth) and not _visited(state, puzzle, dark_cloth), "you leave by stepping on the lit denim")
	_check(refused["reason"] == "dark" and allowed["result"] == Rules.Result.OK, "you do not leave by stepping on the dark denim, and the same step onto a ticking succeeds")
	_check(_spec_result(_denim_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the last denim")
	_check(_spec_result(_denim_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the last denim")


func _check_denim_early_step_succeeds() -> void:
	var rows := PackedStringArray(["######", "#.SD.#", "######"])
	var lamps: Array = [{"x": 4, "y": 1, "facing": "w", "radius": 2, "lit": true}]
	var state := Rules.build(rows, lamps, [{"x": 1, "y": 1, "vision": 0, "rail": [Vector2i(1, 1)]}])
	var cell := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var buckram := _with_tile(state, cell.x, cell.y, Rules.Tile.BUCKRAM)
	var cambric := _with_tile(state, cell.x, cell.y, Rules.Tile.CAMBRIC)
	_check(lit.has(cell) and stepped["result"] == Rules.Result.OK and Rules.apply(buckram, {"type": "move", "dx": 1, "dy": 0})["reason"] == "lit", "an unwatched lit denim can be entered, and the same step onto a buckram fails")
	_check(lit.has(Vector2i(2, 1)) and not Rules.light_map(cambric).has(Vector2i(2, 1)), "a second lamp's light passes a denim and stops at a cambric")
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(_with_tile(state, cell.x, cell.y, Rules.Tile.VOILE), cell.x, cell.y), "a guard can enter the denim and cannot enter a voile")


func _check_canvas_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Canvas Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_canvas_rooms() -> void:
	_check_canvas_identity()
	_check_earlier_wings_have_no_canvases()
	_check_lit_canvas()
	_check_seen_sail()
	_check_passed_bolt()
	_check_open_canvas()
	_check_quenched_step()
	_check_last_canvas()
	_check_canvas_step_puts_it_out()


func _check_canvas_identity() -> void:
	var seen := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Canvas Wing":
			continue
		var rows := ""
		for row in puzzle["rows"]:
			rows += str(row)
		if seen.has(rows):
			layout_ok = false
		seen[rows] = true
		var title := str(puzzle["title"])
		if titles.has(title):
			title_ok = false
		titles[title] = true
	var once := true
	var wing_titles: Array = titles.keys()
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Canvas Wing":
			continue
		if titles.has(str(puzzle["title"])):
			once = false
	_check(layout_ok, "each canvas room has its own layout")
	_check(title_ok, "each canvas room has its own name")
	_check(once and wing_titles.size() == 6, "the canvas titles are not reused")


func _canvas_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Canvas Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_canvases() -> void:
	var clean := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Canvas Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("U"):
				clean = false
	_check(clean, "earlier wings have no canvases")


func _canvas_swap(state: Dictionary, kind: int) -> Dictionary:
	var copy := Rules.clone(state)
	for i in copy["tiles"].size():
		if copy["tiles"][i] == Rules.Tile.CANVAS:
			copy["tiles"][i] = kind
	return copy


func _canvas_on(state: Dictionary, puzzle: Dictionary, cell: Vector2i) -> Dictionary:
	var cursor := Rules.clone(state)
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			var out: Dictionary = Rules.apply(cursor, action)
			cursor = out["state"]
			if dest == cell:
				return cursor
		else:
			var other: Dictionary = Rules.apply(cursor, action)
			cursor = other["state"]
	return cursor


func _check_lit_canvas() -> void:
	var index := _canvas_room("The Lit Canvas")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.CANVAS)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(2, 1) and lit.has(cell), "the lit canvas is lit")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, Vector2i(3, 3)), "the solution crosses the lit gap and leaves")
	_check(_spec_result(_canvas_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the lit canvas, because the light stops")
	_check(_spec_result(_canvas_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the lit canvas, because a guard cannot enter it")


func _check_seen_sail() -> void:
	var index := _canvas_room("The Seen Sail")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	var cloth := Vector2i(3, 7)
	var beyond := Vector2i(3, 6)
	var watched: Dictionary = Rules.watched_tiles(state, lit)
	var ticking := _canvas_swap(state, Rules.Tile.TICKING)
	_check(lit.has(cloth) and lit.has(beyond) and watched.has(beyond), "the guard sees a lit tile through the lit canvas")
	_check(not Rules.watched_tiles(ticking, Rules.light_map(ticking)).has(beyond), "a ticking hides that lit tile")
	_check(_spec_result(state, spec) == "win", "the solution leaves the seen sail")
	_check(_spec_result(_canvas_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the seen sail")
	_check(_spec_result(_canvas_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the seen sail")


func _check_passed_bolt() -> void:
	var index := _canvas_room("The Passed Bolt")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.CANVAS)
	var spec := _solution_spec(puzzle)
	var past := Vector2i(3, 4)
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(cell) and lit.has(past), "a second lamp's light passes through the canvas")
	_check(not Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.CAMBRIC)).has(past), "a cambric stops that second lamp")
	_check(_spec_result(state, spec) == "win", "the solution crosses the lit gap past the canvas")
	_check(_spec_result(_canvas_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the passed bolt, because its second lamp stops")
	_check(_spec_result(_canvas_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the passed bolt")


func _check_open_canvas() -> void:
	var index := _canvas_room("The Open Canvas")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.CANVAS)
	var spec := _solution_spec(puzzle)
	var voile := _canvas_swap(state, Rules.Tile.VOILE)
	var through: Array = Rules.bfs_path(state, 1, 1, 3, 1)["path"]
	var around: Array = Rules.bfs_path(voile, 1, 1, 3, 1)["path"]
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(voile, cell.x, cell.y), "a guard can enter the canvas, and a guard cannot enter the voile")
	_check(_path_has(through, cell) and not _path_has(around, cell), "the called guard walks the canvas and walks around a voile")
	_check(_spec_result(state, spec) == "win", "the solution clears the open canvas")
	_check(_spec_result(_canvas_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the open canvas")
	_check(_spec_result(voile, spec) == "guard", "a voile does not clear the open canvas, because the guard cannot enter it")


func _check_quenched_step() -> void:
	var index := _canvas_room("The Quenched Step")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var beside := Rules.clone(state)
	beside["player"]["x"] = 2
	beside["player"]["y"] = 2
	var allowed: Dictionary = Rules.apply(beside, {"type": "move", "dx": 0, "dy": -1})
	var denim := _canvas_swap(beside, Rules.Tile.DENIM)
	var stayed: Dictionary = Rules.apply(denim, {"type": "move", "dx": 0, "dy": -1})
	var refused: Dictionary = Rules.apply(_canvas_swap(beside, Rules.Tile.BUCKRAM), {"type": "move", "dx": 0, "dy": -1})
	_check(Rules.light_map(beside).has(Vector2i(2, 1)) and allowed["result"] == Rules.Result.OK and not Rules.light_map(allowed["state"]).has(Vector2i(2, 1)), "the early step onto the lit canvas succeeds and puts it out")
	_check(stayed["result"] == Rules.Result.OK and Rules.light_map(stayed["state"]).has(Vector2i(2, 1)) and refused["reason"] == "lit", "the same step leaves a denim lit, and a buckram refuses it")
	_check(_spec_result(state, spec) == "win", "the solution clears the quenched step")
	_check(_spec_result(_canvas_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the quenched step")
	_check(_spec_result(_canvas_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the quenched step")


func _check_last_canvas() -> void:
	var index := _canvas_room("The Last Canvas")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var lit_cloth := Vector2i(2, 3)
	var dark_cloth := Vector2i(2, 5)
	var spec := _solution_spec(puzzle)
	var after := _canvas_on(state, puzzle, lit_cloth)
	var denim_state := _canvas_swap(state, Rules.Tile.DENIM)
	var denim_after := _canvas_on(denim_state, puzzle, lit_cloth)
	var beside := Rules.clone(state)
	beside["player"]["x"] = 2
	beside["player"]["y"] = 4
	var dark_step: Dictionary = Rules.apply(beside, {"type": "move", "dx": 0, "dy": 1})
	_check(Rules.tile_at(state, lit_cloth.x, lit_cloth.y) == Rules.Tile.CANVAS and Rules.light_map(state).has(lit_cloth) and not Rules.light_map(state).has(dark_cloth), "the leaving canvas starts lit and the other canvas is dark")
	_check(not Rules.light_map(after).has(lit_cloth) and Rules.light_map(after).has(Vector2i(3, 3)), "stepping on the canvas puts it out, and the light still passes")
	_check(Rules.light_map(denim_after).has(lit_cloth), "the same step leaves a denim lit")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, lit_cloth) and not _stepped_on_while_dark(state, puzzle, lit_cloth) and not _visited(state, puzzle, dark_cloth), "you leave by stepping on the canvas, and that step is what makes it dark")
	_check(dark_step["result"] == Rules.Result.OK and not Rules.light_map(dark_step["state"]).has(dark_cloth), "a dark canvas can be entered, and it stays dark")
	_check(_spec_result(_canvas_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the last canvas")
	_check(_spec_result(_canvas_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the last canvas")


func _check_canvas_step_puts_it_out() -> void:
	var rows := PackedStringArray(["######", "#.SU.#", "######"])
	var lamps: Array = [{"x": 4, "y": 1, "facing": "w", "radius": 2, "lit": true}]
	var state := Rules.build(rows, lamps, [{"x": 1, "y": 1, "vision": 0, "rail": [Vector2i(1, 1)]}])
	var cell := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var after: Dictionary = Rules.light_map(stepped["state"])
	var denim := _with_tile(state, cell.x, cell.y, Rules.Tile.DENIM)
	var stayed: Dictionary = Rules.apply(denim, {"type": "move", "dx": 1, "dy": 0})
	var buckram := _with_tile(state, cell.x, cell.y, Rules.Tile.BUCKRAM)
	var cambric := _with_tile(state, cell.x, cell.y, Rules.Tile.CAMBRIC)
	_check(lit.has(cell) and lit.has(Vector2i(2, 1)) and stepped["result"] == Rules.Result.OK and not after.has(cell) and after.has(Vector2i(2, 1)), "the early step onto the lit canvas succeeds, puts it out, and the light still passes")
	_check(Rules.light_map(stayed["state"]).has(cell) and Rules.apply(buckram, {"type": "move", "dx": 1, "dy": 0})["reason"] == "lit", "a denim stays lit under that step, and a buckram refuses it")
	_check(not Rules.light_map(cambric).has(Vector2i(2, 1)), "a cambric stops the light a canvas lets through")
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(_with_tile(state, cell.x, cell.y, Rules.Tile.VOILE), cell.x, cell.y), "a guard can enter the canvas and cannot enter a voile")


func _check_drill_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Drill Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_drill_rooms() -> void:
	_check_drill_identity()
	_check_earlier_wings_have_no_drills()
	_check_lit_drill()
	_check_hidden_drill()
	_check_passed_weave()
	_check_open_drill()
	_check_spent_step()
	_check_last_drill()
	_check_drill_step_puts_it_out()


func _check_drill_identity() -> void:
	var seen := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Drill Wing":
			continue
		var rows := ""
		for row in puzzle["rows"]:
			rows += str(row)
		if seen.has(rows):
			layout_ok = false
		seen[rows] = true
		var title := str(puzzle["title"])
		if titles.has(title):
			title_ok = false
		titles[title] = true
	var once := true
	var wing_titles: Array = titles.keys()
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Drill Wing":
			continue
		if titles.has(str(puzzle["title"])):
			once = false
	_check(layout_ok, "each drill room has its own layout")
	_check(title_ok, "each drill room has its own name")
	_check(once and wing_titles.size() == 6, "the drill titles are not reused")


func _drill_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Drill Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_drills() -> void:
	var clean := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Drill Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("W"):
				clean = false
	_check(clean, "earlier wings have no drills")


func _drill_swap(state: Dictionary, kind: int) -> Dictionary:
	var copy := Rules.clone(state)
	for i in copy["tiles"].size():
		if copy["tiles"][i] == Rules.Tile.DRILL:
			copy["tiles"][i] = kind
	return copy


func _drill_on(state: Dictionary, puzzle: Dictionary, cell: Vector2i) -> Dictionary:
	var cursor := Rules.clone(state)
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			var out: Dictionary = Rules.apply(cursor, action)
			cursor = out["state"]
			if dest == cell:
				return cursor
		else:
			var other: Dictionary = Rules.apply(cursor, action)
			cursor = other["state"]
	return cursor


func _check_lit_drill() -> void:
	var index := _drill_room("The Lit Drill")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.DRILL)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(2, 1) and lit.has(cell), "the lit drill is lit")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, Vector2i(3, 3)), "the solution crosses the lit gap and leaves")
	_check(_spec_result(_drill_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the lit drill, because the light stops")
	_check(_spec_result(_drill_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the lit drill, because a guard cannot enter it")


func _check_hidden_drill() -> void:
	var index := _drill_room("The Hidden Drill")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	var cloth := Vector2i(3, 7)
	var beyond := Vector2i(3, 6)
	var watched: Dictionary = Rules.watched_tiles(state, lit)
	var canvas := _drill_swap(state, Rules.Tile.CANVAS)
	_check(lit.has(cloth) and lit.has(beyond) and watched.has(cloth) and not watched.has(beyond), "the guard does not see a lit tile through the lit drill")
	_check(Rules.watched_tiles(canvas, Rules.light_map(canvas)).has(beyond), "a canvas lets the guard see that lit tile")
	_check(_spec_result(state, spec) == "win", "the solution leaves the hidden drill")
	_check(_spec_result(_drill_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the hidden drill")
	_check(_spec_result(_drill_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the hidden drill")


func _check_passed_weave() -> void:
	var index := _drill_room("The Passed Weave")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.DRILL)
	var spec := _solution_spec(puzzle)
	var past := Vector2i(3, 4)
	var lit: Dictionary = Rules.light_map(state)
	_check(lit.has(cell) and lit.has(past), "a second lamp's light passes through the drill")
	_check(not Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.CAMBRIC)).has(past), "a cambric stops that second lamp")
	_check(_spec_result(state, spec) == "win", "the solution crosses the lit gap past the drill")
	_check(_spec_result(_drill_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the passed weave, because its second lamp stops")
	_check(_spec_result(_drill_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the passed weave")


func _check_open_drill() -> void:
	var index := _drill_room("The Open Drill")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.DRILL)
	var spec := _solution_spec(puzzle)
	var voile := _drill_swap(state, Rules.Tile.VOILE)
	var through: Array = Rules.bfs_path(state, 1, 1, 3, 1)["path"]
	var around: Array = Rules.bfs_path(voile, 1, 1, 3, 1)["path"]
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(voile, cell.x, cell.y), "a guard can enter the drill, and a guard cannot enter the voile")
	_check(_path_has(through, cell) and not _path_has(around, cell), "the called guard walks the drill and walks around a voile")
	_check(_spec_result(state, spec) == "win", "the solution clears the open drill")
	_check(_spec_result(_drill_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the open drill")
	_check(_spec_result(voile, spec) == "guard", "a voile does not clear the open drill, because the guard cannot enter it")


func _check_spent_step() -> void:
	var index := _drill_room("The Spent Step")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var beside := Rules.clone(state)
	beside["player"]["x"] = 2
	beside["player"]["y"] = 2
	var allowed: Dictionary = Rules.apply(beside, {"type": "move", "dx": 0, "dy": -1})
	var denim := _drill_swap(beside, Rules.Tile.DENIM)
	var stayed: Dictionary = Rules.apply(denim, {"type": "move", "dx": 0, "dy": -1})
	var ticking := _drill_swap(beside, Rules.Tile.TICKING)
	var ticking_step: Dictionary = Rules.apply(ticking, {"type": "move", "dx": 0, "dy": -1})
	var refused: Dictionary = Rules.apply(_drill_swap(beside, Rules.Tile.BUCKRAM), {"type": "move", "dx": 0, "dy": -1})
	_check(Rules.light_map(beside).has(Vector2i(2, 1)) and allowed["result"] == Rules.Result.OK and not Rules.light_map(allowed["state"]).has(Vector2i(2, 1)), "the early step onto the lit drill succeeds and puts it out")
	_check(stayed["result"] == Rules.Result.OK and Rules.light_map(stayed["state"]).has(Vector2i(2, 1)) and Rules.light_map(ticking_step["state"]).has(Vector2i(2, 1)) and refused["reason"] == "lit", "the same step leaves a denim and a ticking lit, and a buckram refuses it")
	_check(_spec_result(state, spec) == "win", "the solution clears the spent step")
	_check(_spec_result(_drill_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the spent step")
	_check(_spec_result(_drill_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the spent step")


func _check_last_drill() -> void:
	var index := _drill_room("The Last Drill")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var lit_cloth := Vector2i(2, 3)
	var dark_cloth := Vector2i(2, 5)
	var spec := _solution_spec(puzzle)
	var after := _drill_on(state, puzzle, lit_cloth)
	var denim_state := _drill_swap(state, Rules.Tile.DENIM)
	var denim_after := _drill_on(denim_state, puzzle, lit_cloth)
	var beside := Rules.clone(state)
	beside["player"]["x"] = 2
	beside["player"]["y"] = 4
	var dark_step: Dictionary = Rules.apply(beside, {"type": "move", "dx": 0, "dy": 1})
	_check(Rules.tile_at(state, lit_cloth.x, lit_cloth.y) == Rules.Tile.DRILL and Rules.light_map(state).has(lit_cloth) and not Rules.light_map(state).has(dark_cloth), "the leaving drill starts lit and the other drill is dark")
	_check(not Rules.light_map(after).has(lit_cloth) and Rules.light_map(after).has(Vector2i(3, 3)), "stepping on the drill puts it out, and the light still passes")
	_check(Rules.light_map(denim_after).has(lit_cloth), "the same step leaves a denim lit")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, lit_cloth) and not _stepped_on_while_dark(state, puzzle, lit_cloth) and not _visited(state, puzzle, dark_cloth), "you leave by stepping on the drill, and that step is what makes it dark")
	_check(dark_step["result"] == Rules.Result.OK and not Rules.light_map(dark_step["state"]).has(dark_cloth), "a dark drill can be entered, and it stays dark")
	_check(_spec_result(_drill_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the last drill")
	_check(_spec_result(_drill_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the last drill")


func _check_drill_step_puts_it_out() -> void:
	var rows := PackedStringArray(["######", "#.SW.#", "######"])
	var lamps: Array = [{"x": 4, "y": 1, "facing": "w", "radius": 2, "lit": true}]
	var state := Rules.build(rows, lamps, [{"x": 1, "y": 1, "vision": 0, "rail": [Vector2i(1, 1)]}])
	var cell := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var after: Dictionary = Rules.light_map(stepped["state"])
	var denim := _with_tile(state, cell.x, cell.y, Rules.Tile.DENIM)
	var stayed: Dictionary = Rules.apply(denim, {"type": "move", "dx": 1, "dy": 0})
	var buckram := _with_tile(state, cell.x, cell.y, Rules.Tile.BUCKRAM)
	var cambric := _with_tile(state, cell.x, cell.y, Rules.Tile.CAMBRIC)
	var canvas := _with_tile(state, cell.x, cell.y, Rules.Tile.CANVAS)
	var guard := [{"x": 1, "y": 1, "vision": 3, "rail": [Vector2i(1, 1)]}]
	var watched_state := Rules.build(rows, lamps, guard)
	var watched_canvas := _with_tile(watched_state, cell.x, cell.y, Rules.Tile.CANVAS)
	_check(lit.has(cell) and lit.has(Vector2i(2, 1)) and stepped["result"] == Rules.Result.OK and not after.has(cell) and after.has(Vector2i(2, 1)), "the early step onto the lit drill succeeds, puts it out, and the light still passes")
	_check(Rules.light_map(stayed["state"]).has(cell) and Rules.apply(buckram, {"type": "move", "dx": 1, "dy": 0})["reason"] == "lit", "a denim stays lit under that step, and a buckram refuses it")
	_check(not Rules.light_map(cambric).has(Vector2i(2, 1)), "a cambric stops the light a drill lets through")
	_check(not Rules.watched_tiles(watched_state, Rules.light_map(watched_state)).has(Vector2i(4, 1)) and Rules.watched_tiles(watched_canvas, Rules.light_map(watched_canvas)).has(Vector2i(4, 1)), "sight stops at the lit drill and passes a canvas")
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(_with_tile(state, cell.x, cell.y, Rules.Tile.VOILE), cell.x, cell.y), "a guard can enter the drill and cannot enter a voile")


func _check_twill_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Twill Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_twill_rooms() -> void:
	_check_twill_identity()
	_check_earlier_wings_have_no_twills()
	_check_dark_twill()
	_check_hidden_twill()
	_check_passed_thread()
	_check_open_twill()
	_check_kindled_step()
	_check_last_twill()
	_check_twill_step_lights_it()


func _check_twill_identity() -> void:
	var seen := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Twill Wing":
			continue
		var rows := ""
		for row in puzzle["rows"]:
			rows += str(row)
		if seen.has(rows):
			layout_ok = false
		seen[rows] = true
		var title := str(puzzle["title"])
		if titles.has(title):
			title_ok = false
		titles[title] = true
	var once := true
	var wing_titles: Array = titles.keys()
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Twill Wing":
			continue
		if titles.has(str(puzzle["title"])):
			once = false
	_check(layout_ok, "each twill room has its own layout")
	_check(title_ok, "each twill room has its own name")
	_check(once and wing_titles.size() == 6, "the twill titles are not reused")


func _twill_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Twill Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_twills() -> void:
	var clean := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Twill Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("*"):
				clean = false
	_check(clean, "earlier wings have no twills")


func _twill_swap(state: Dictionary, kind: int) -> Dictionary:
	var copy := Rules.clone(state)
	for i in copy["tiles"].size():
		if copy["tiles"][i] == Rules.Tile.TWILL:
			copy["tiles"][i] = kind
	copy["out"] = {}
	return copy


func _twill_on(state: Dictionary, puzzle: Dictionary, cell: Vector2i) -> Dictionary:
	var cursor := Rules.clone(state)
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			var out: Dictionary = Rules.apply(cursor, action)
			cursor = out["state"]
			if dest == cell:
				return cursor
		else:
			var other: Dictionary = Rules.apply(cursor, action)
			cursor = other["state"]
	return cursor


func _check_dark_twill() -> void:
	var index := _twill_room("The Dark Twill")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.TWILL)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(2, 1) and not lit.has(cell) and lit.has(Vector2i(3, 3)), "the twill starts dark")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, Vector2i(3, 3)), "the solution crosses the lit gap and leaves")
	_check(_spec_result(_twill_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the dark twill, because the light stops")
	_check(_spec_result(_twill_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the dark twill, because a guard cannot enter it")


func _check_hidden_twill() -> void:
	var index := _twill_room("The Hidden Twill")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	var cloth := Vector2i(3, 7)
	var beyond := Vector2i(3, 6)
	var watched: Dictionary = Rules.watched_tiles(state, lit)
	var drill := _twill_swap(state, Rules.Tile.DRILL)
	var canvas := _twill_swap(state, Rules.Tile.CANVAS)
	_check(not lit.has(cloth) and lit.has(beyond) and not watched.has(cloth) and not watched.has(beyond), "the guard does not see a lit tile through the dark twill")
	_check(Rules.light_map(drill).has(cloth) and Rules.watched_tiles(drill, Rules.light_map(drill)).has(cloth) and not Rules.watched_tiles(drill, Rules.light_map(drill)).has(beyond), "a drill is lit, and the guard still does not see through it")
	_check(Rules.watched_tiles(canvas, Rules.light_map(canvas)).has(beyond), "a canvas lets the guard see that lit tile")
	_check(_spec_result(state, spec) == "win", "the solution leaves the hidden twill")
	_check(_spec_result(_twill_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the hidden twill")
	_check(_spec_result(_twill_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the hidden twill")


func _check_passed_thread() -> void:
	var index := _twill_room("The Passed Thread")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.TWILL)
	var spec := _solution_spec(puzzle)
	var past := Vector2i(3, 4)
	var lit: Dictionary = Rules.light_map(state)
	_check(not lit.has(cell) and lit.has(past), "a second lamp's light passes through the dark twill")
	_check(not Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.CAMBRIC)).has(past), "a cambric stops that second lamp")
	_check(_spec_result(state, spec) == "win", "the solution crosses the lit gap past the twill")
	_check(_spec_result(_twill_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the passed thread, because its second lamp stops")
	_check(_spec_result(_twill_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the passed thread")


func _check_open_twill() -> void:
	var index := _twill_room("The Open Twill")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.TWILL)
	var spec := _solution_spec(puzzle)
	var voile := _twill_swap(state, Rules.Tile.VOILE)
	var through: Array = Rules.bfs_path(state, 1, 1, 3, 1)["path"]
	var around: Array = Rules.bfs_path(voile, 1, 1, 3, 1)["path"]
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(voile, cell.x, cell.y), "a guard can enter the dark twill, and a guard cannot enter the voile")
	_check(_path_has(through, cell) and not _path_has(around, cell), "the called guard walks the twill and walks around a voile")
	_check(_spec_result(state, spec) == "win", "the solution clears the open twill")
	_check(_spec_result(_twill_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the open twill")
	_check(_spec_result(voile, spec) == "guard", "a voile does not clear the open twill, because the guard cannot enter it")


func _check_kindled_step() -> void:
	var index := _twill_room("The Kindled Step")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var beside := Rules.clone(state)
	beside["player"]["x"] = 2
	beside["player"]["y"] = 2
	var allowed: Dictionary = Rules.apply(beside, {"type": "move", "dx": 0, "dy": -1})
	var drill := _twill_swap(beside, Rules.Tile.DRILL)
	var drill_step: Dictionary = Rules.apply(drill, {"type": "move", "dx": 0, "dy": -1})
	var denim := _twill_swap(beside, Rules.Tile.DENIM)
	var stayed: Dictionary = Rules.apply(denim, {"type": "move", "dx": 0, "dy": -1})
	var ticking := _twill_swap(beside, Rules.Tile.TICKING)
	var ticking_step: Dictionary = Rules.apply(ticking, {"type": "move", "dx": 0, "dy": -1})
	var refused: Dictionary = Rules.apply(_twill_swap(beside, Rules.Tile.BUCKRAM), {"type": "move", "dx": 0, "dy": -1})
	_check(not Rules.light_map(beside).has(Vector2i(2, 1)) and allowed["result"] == Rules.Result.OK and Rules.light_map(allowed["state"]).has(Vector2i(2, 1)), "the early step onto the dark twill succeeds and lights it")
	_check(Rules.light_map(drill).has(Vector2i(2, 1)) and drill_step["result"] == Rules.Result.OK and not Rules.light_map(drill_step["state"]).has(Vector2i(2, 1)), "the same step onto a drill starts lit and puts it out")
	_check(stayed["result"] == Rules.Result.OK and Rules.light_map(stayed["state"]).has(Vector2i(2, 1)) and Rules.light_map(ticking_step["state"]).has(Vector2i(2, 1)) and refused["reason"] == "lit", "the same step leaves a denim and a ticking lit, and a buckram refuses it")
	_check(_spec_result(state, spec) == "win", "the solution clears the kindled step")
	_check(_spec_result(_twill_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the kindled step")
	_check(_spec_result(_twill_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the kindled step")


func _check_last_twill() -> void:
	var index := _twill_room("The Last Twill")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var lit_cloth := Vector2i(2, 3)
	var dark_cloth := Vector2i(2, 5)
	var spec := _solution_spec(puzzle)
	var after := _twill_on(state, puzzle, lit_cloth)
	var drill_state := _twill_swap(state, Rules.Tile.DRILL)
	var drill_after := _twill_on(drill_state, puzzle, lit_cloth)
	var denim_state := _twill_swap(state, Rules.Tile.DENIM)
	var denim_after := _twill_on(denim_state, puzzle, lit_cloth)
	var beside := Rules.clone(state)
	beside["player"]["x"] = 2
	beside["player"]["y"] = 4
	var dark_step: Dictionary = Rules.apply(beside, {"type": "move", "dx": 0, "dy": 1})
	_check(Rules.tile_at(state, lit_cloth.x, lit_cloth.y) == Rules.Tile.TWILL and not Rules.light_map(state).has(lit_cloth) and not Rules.light_map(state).has(dark_cloth), "the leaving twill starts dark and the other twill is dark")
	_check(Rules.light_map(after).has(lit_cloth) and Rules.light_map(after).has(Vector2i(3, 3)), "stepping on the twill lights it, and the light still passes")
	_check(Rules.light_map(drill_state).has(lit_cloth) and not Rules.light_map(drill_after).has(lit_cloth), "the same step onto a drill starts lit and puts it out")
	_check(Rules.light_map(denim_after).has(lit_cloth), "the same step leaves a denim lit")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, lit_cloth) and _stepped_on_while_dark(state, puzzle, lit_cloth) and not _visited(state, puzzle, dark_cloth), "you leave by stepping on the dark twill, and that step lights it")
	_check(dark_step["result"] == Rules.Result.OK and not Rules.light_map(dark_step["state"]).has(dark_cloth), "a dark twill outside the lamp can be entered, and it stays dark")
	_check(_spec_result(_twill_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the last twill")
	_check(_spec_result(_twill_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the last twill")


func _check_twill_step_lights_it() -> void:
	var rows := PackedStringArray(["######", "#.S*.#", "######"])
	var lamps: Array = [{"x": 4, "y": 1, "facing": "w", "radius": 2, "lit": true}]
	var state := Rules.build(rows, lamps, [{"x": 1, "y": 1, "vision": 0, "rail": [Vector2i(1, 1)]}])
	var cell := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var after: Dictionary = Rules.light_map(stepped["state"])
	var drill := _twill_swap(state, Rules.Tile.DRILL)
	var drill_step: Dictionary = Rules.apply(drill, {"type": "move", "dx": 1, "dy": 0})
	var denim := _with_tile(state, cell.x, cell.y, Rules.Tile.DENIM)
	var stayed: Dictionary = Rules.apply(denim, {"type": "move", "dx": 1, "dy": 0})
	var buckram := _with_tile(state, cell.x, cell.y, Rules.Tile.BUCKRAM)
	var cambric := _with_tile(state, cell.x, cell.y, Rules.Tile.CAMBRIC)
	var guard := [{"x": 1, "y": 1, "vision": 3, "rail": [Vector2i(1, 1)]}]
	var watched_state := Rules.build(rows, lamps, guard)
	var kindled := Rules.clone(watched_state)
	kindled["out"].erase(cell)
	var kindled_lit: Dictionary = Rules.light_map(kindled)
	var watched_canvas := _twill_swap(watched_state, Rules.Tile.CANVAS)
	_check(not lit.has(cell) and lit.has(Vector2i(2, 1)) and stepped["result"] == Rules.Result.OK and after.has(cell) and after.has(Vector2i(2, 1)), "the early step onto the dark twill succeeds, lights it, and the light still passes")
	_check(Rules.light_map(drill).has(cell) and drill_step["result"] == Rules.Result.OK and not Rules.light_map(drill_step["state"]).has(cell), "a drill starts lit and the same step puts it out")
	_check(Rules.light_map(stayed["state"]).has(cell) and Rules.apply(buckram, {"type": "move", "dx": 1, "dy": 0})["reason"] == "lit", "a denim stays lit under that step, and a buckram refuses it")
	_check(not Rules.light_map(cambric).has(Vector2i(2, 1)), "a cambric stops the light a twill lets through")
	_check(not Rules.watched_tiles(watched_state, Rules.light_map(watched_state)).has(Vector2i(4, 1)) and kindled_lit.has(cell) and Rules.watched_tiles(kindled, kindled_lit).has(cell) and not Rules.watched_tiles(kindled, kindled_lit).has(Vector2i(4, 1)), "the dark twill hides the lamp, and the lit twill still stops sight")
	_check(Rules.watched_tiles(watched_canvas, Rules.light_map(watched_canvas)).has(Vector2i(4, 1)), "a canvas lets the guard see that lamp")
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(_with_tile(state, cell.x, cell.y, Rules.Tile.VOILE), cell.x, cell.y), "a guard can enter the twill and cannot enter a voile")


func _check_duck_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Duck Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_duck_rooms() -> void:
	_check_duck_identity()
	_check_earlier_wings_have_no_ducks()
	_check_dark_duck()
	_check_hidden_duck()
	_check_passed_nap()
	_check_open_duck()
	_check_shut_step()
	_check_last_duck()
	_check_duck_step_fails()


func _check_duck_identity() -> void:
	var seen := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Duck Wing":
			continue
		var rows := ""
		for row in puzzle["rows"]:
			rows += str(row)
		if seen.has(rows):
			layout_ok = false
		seen[rows] = true
		var title := str(puzzle["title"])
		if titles.has(title):
			title_ok = false
		titles[title] = true
	var once := true
	var wing_titles: Array = titles.keys()
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Duck Wing":
			continue
		if titles.has(str(puzzle["title"])):
			once = false
	_check(layout_ok, "each duck room has its own layout")
	_check(title_ok, "each duck room has its own name")
	_check(once and wing_titles.size() == 6, "the duck titles are not reused")


func _duck_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Duck Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_ducks() -> void:
	var clean := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Duck Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("+"):
				clean = false
	_check(clean, "earlier wings have no ducks")


func _duck_swap(state: Dictionary, kind: int, keep_dark: bool = false) -> Dictionary:
	var copy := Rules.clone(state)
	for i in copy["tiles"].size():
		if copy["tiles"][i] == Rules.Tile.DUCK:
			copy["tiles"][i] = kind
	if not keep_dark:
		copy["out"] = {}
	return copy


func _check_dark_duck() -> void:
	var index := _duck_room("The Dark Duck")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.DUCK)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(2, 1) and not lit.has(cell) and lit.has(Vector2i(3, 3)), "the duck stays dark")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, Vector2i(3, 3)) and not _visited(state, puzzle, cell), "the solution crosses the lit gap and leaves without stepping on the duck")
	_check(_spec_result(_duck_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the dark duck, because the light stops")
	_check(_spec_result(_duck_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the dark duck, because a guard cannot enter it")


func _check_hidden_duck() -> void:
	var index := _duck_room("The Hidden Duck")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	var cloth := Vector2i(3, 7)
	var beyond := Vector2i(3, 6)
	var watched: Dictionary = Rules.watched_tiles(state, lit)
	var drill := _duck_swap(state, Rules.Tile.DRILL)
	var canvas := _duck_swap(state, Rules.Tile.CANVAS)
	_check(not lit.has(cloth) and lit.has(beyond) and not watched.has(cloth) and not watched.has(beyond), "the guard does not see a lit tile through the dark duck")
	_check(Rules.light_map(drill).has(cloth) and Rules.watched_tiles(drill, Rules.light_map(drill)).has(cloth) and not Rules.watched_tiles(drill, Rules.light_map(drill)).has(beyond), "a drill is lit, and the guard still does not see through it")
	_check(Rules.watched_tiles(canvas, Rules.light_map(canvas)).has(beyond), "a canvas lets the guard see that lit tile")
	_check(_spec_result(state, spec) == "win", "the solution leaves the hidden duck")
	_check(_spec_result(_duck_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the hidden duck")
	_check(_spec_result(_duck_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the hidden duck")


func _check_passed_nap() -> void:
	var index := _duck_room("The Passed Nap")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.DUCK)
	var spec := _solution_spec(puzzle)
	var past := Vector2i(3, 4)
	var lit: Dictionary = Rules.light_map(state)
	_check(not lit.has(cell) and lit.has(past), "a second lamp's light passes through the dark duck")
	_check(not Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.CAMBRIC)).has(past), "a cambric stops that second lamp")
	_check(_spec_result(state, spec) == "win", "the solution crosses the lit gap past the duck")
	_check(_spec_result(_duck_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the passed nap, because its second lamp stops")
	_check(_spec_result(_duck_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the passed nap")


func _check_open_duck() -> void:
	var index := _duck_room("The Open Duck")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.DUCK)
	var spec := _solution_spec(puzzle)
	var voile := _duck_swap(state, Rules.Tile.VOILE)
	var through: Array = Rules.bfs_path(state, 1, 1, 3, 1)["path"]
	var around: Array = Rules.bfs_path(voile, 1, 1, 3, 1)["path"]
	var beside := Rules.clone(state)
	beside["player"]["x"] = 2
	beside["player"]["y"] = 2
	var refused: Dictionary = Rules.apply(beside, {"type": "move", "dx": 0, "dy": -1})
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(voile, cell.x, cell.y), "a guard can enter the dark duck, and a guard cannot enter the voile")
	_check(_path_has(through, cell) and not _path_has(around, cell), "the called guard walks the duck and walks around a voile")
	_check(refused["reason"] == "dark" and int(refused["state"]["player"]["y"]) == 2 and not Rules.light_map(refused["state"]).has(cell), "the player cannot enter the dark duck, and it stays dark")
	_check(_spec_result(state, spec) == "win", "the solution clears the open duck")
	_check(_spec_result(_duck_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the open duck")
	_check(_spec_result(voile, spec) == "guard", "a voile does not clear the open duck, because the guard cannot enter it")


func _check_shut_step() -> void:
	var index := _duck_room("The Shut Step")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var beside := Rules.clone(state)
	beside["player"]["x"] = 2
	beside["player"]["y"] = 2
	var refused: Dictionary = Rules.apply(beside, {"type": "move", "dx": 0, "dy": -1})
	var twill := _duck_swap(beside, Rules.Tile.TWILL, true)
	var twill_step: Dictionary = Rules.apply(twill, {"type": "move", "dx": 0, "dy": -1})
	var denim := _duck_swap(beside, Rules.Tile.DENIM)
	var stayed: Dictionary = Rules.apply(denim, {"type": "move", "dx": 0, "dy": -1})
	var buckram: Dictionary = Rules.apply(_duck_swap(beside, Rules.Tile.BUCKRAM), {"type": "move", "dx": 0, "dy": -1})
	_check(not Rules.light_map(beside).has(Vector2i(2, 1)) and refused["reason"] == "dark" and int(refused["state"]["player"]["y"]) == 2 and not Rules.light_map(refused["state"]).has(Vector2i(2, 1)), "the early step onto the dark duck fails and the duck stays dark")
	_check(not Rules.light_map(twill).has(Vector2i(2, 1)) and twill_step["result"] == Rules.Result.OK and Rules.light_map(twill_step["state"]).has(Vector2i(2, 1)), "the same step onto a twill succeeds and lights it")
	_check(stayed["result"] == Rules.Result.OK and Rules.light_map(stayed["state"]).has(Vector2i(2, 1)) and buckram["reason"] == "lit", "the same step leaves a denim lit, and a buckram refuses it")
	_check(_spec_result(state, spec) == "win", "the solution clears the shut step")
	_check(_spec_result(_duck_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the shut step")
	_check(_spec_result(_duck_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the shut step")


func _check_last_duck() -> void:
	var index := _duck_room("The Last Duck")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var lit_cloth := Vector2i(2, 3)
	var dark_cloth := Vector2i(2, 5)
	var spec := _solution_spec(puzzle)
	var toward: Dictionary = Rules.apply(state, {"type": "move", "dx": -1, "dy": 0})
	var refused: Dictionary = Rules.apply(toward["state"], {"type": "move", "dx": -1, "dy": 0})
	var twill := _duck_swap(state, Rules.Tile.TWILL, true)
	var twill_gap: Dictionary = Rules.apply(twill, {"type": "move", "dx": -1, "dy": 0})
	var twill_step: Dictionary = Rules.apply(twill_gap["state"], {"type": "move", "dx": -1, "dy": 0})
	var denim := _duck_swap(state, Rules.Tile.DENIM)
	var denim_gap: Dictionary = Rules.apply(denim, {"type": "move", "dx": -1, "dy": 0})
	var denim_step: Dictionary = Rules.apply(denim_gap["state"], {"type": "move", "dx": -1, "dy": 0})
	_check(not Rules.light_map(state).has(lit_cloth) and not Rules.light_map(state).has(dark_cloth), "the leaving duck starts dark and the other duck is dark")
	_check(toward["result"] == Rules.Result.OK and refused["reason"] == "dark" and int(refused["state"]["player"]["x"]) == 3 and not Rules.light_map(refused["state"]).has(lit_cloth), "the leaving step fails and the duck stays dark")
	_check(twill_step["result"] == Rules.Result.OK and Rules.light_map(twill_step["state"]).has(lit_cloth) and Rules.light_map(twill_step["state"]).has(Vector2i(3, 3)), "the same step onto a twill succeeds and lights it")
	_check(denim_step["result"] == Rules.Result.OK and Rules.light_map(denim_step["state"]).has(lit_cloth), "the same step leaves a denim lit")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, Vector2i(3, 3)) and not _visited(state, puzzle, lit_cloth) and not _visited(state, puzzle, dark_cloth), "the solution leaves without stepping on the duck")
	_check(_spec_result(_duck_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the last duck")
	_check(_spec_result(_duck_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the last duck")


func _check_duck_step_fails() -> void:
	var rows := PackedStringArray(["######", "#.S+.#", "######"])
	var lamps: Array = [{"x": 4, "y": 1, "facing": "w", "radius": 2, "lit": true}]
	var state := Rules.build(rows, lamps, [{"x": 1, "y": 1, "vision": 0, "rail": [Vector2i(1, 1)]}])
	var cell := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	var refused: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var twill := _duck_swap(state, Rules.Tile.TWILL, true)
	var twill_step: Dictionary = Rules.apply(twill, {"type": "move", "dx": 1, "dy": 0})
	var denim := _duck_swap(state, Rules.Tile.DENIM)
	var stayed: Dictionary = Rules.apply(denim, {"type": "move", "dx": 1, "dy": 0})
	var buckram: Dictionary = Rules.apply(_duck_swap(state, Rules.Tile.BUCKRAM), {"type": "move", "dx": 1, "dy": 0})
	var cambric := _duck_swap(state, Rules.Tile.CAMBRIC)
	_check(not lit.has(cell) and lit.has(Vector2i(2, 1)) and refused["reason"] == "dark" and int(refused["state"]["player"]["x"]) == 2 and not Rules.light_map(refused["state"]).has(cell) and Rules.light_map(refused["state"]).has(Vector2i(2, 1)), "the leaving step onto the dark duck fails, the duck stays dark, and the light still passes")
	_check(not Rules.light_map(twill).has(cell) and twill_step["result"] == Rules.Result.OK and Rules.light_map(twill_step["state"]).has(cell), "a twill starts dark and the same step lights it")
	_check(Rules.light_map(stayed["state"]).has(cell) and buckram["reason"] == "lit", "a denim stays lit under that step, and a buckram refuses it")
	_check(not Rules.light_map(cambric).has(Vector2i(2, 1)), "a cambric stops the light a duck lets through")
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(_duck_swap(state, Rules.Tile.VOILE), cell.x, cell.y), "a guard can enter the duck and cannot enter a voile")


func _check_nankeen_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Nankeen Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_nankeen_rooms() -> void:
	_check_nankeen_identity()
	_check_earlier_wings_have_no_nankeens()
	_check_dark_nankeen()
	_check_hidden_nankeen()
	_check_passed_yellow()
	_check_open_nankeen()
	_check_kept_step()
	_check_last_nankeen()
	_check_nankeen_step_stays_dark()


func _check_nankeen_identity() -> void:
	var seen := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Nankeen Wing":
			continue
		var rows := ""
		for row in puzzle["rows"]:
			rows += str(row)
		if seen.has(rows):
			layout_ok = false
		seen[rows] = true
		var title := str(puzzle["title"])
		if titles.has(title):
			title_ok = false
		titles[title] = true
	var once := true
	var wing_titles: Array = titles.keys()
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Nankeen Wing":
			continue
		if titles.has(str(puzzle["title"])):
			once = false
	_check(layout_ok, "each nankeen room has its own layout")
	_check(title_ok, "each nankeen room has its own name")
	_check(once and wing_titles.size() == 6, "the nankeen titles are not reused")


func _nankeen_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Nankeen Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_nankeens() -> void:
	var clean := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Nankeen Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("@"):
				clean = false
	_check(clean, "earlier wings have no nankeens")


func _nankeen_swap(state: Dictionary, kind: int, keep_dark: bool = false) -> Dictionary:
	var copy := Rules.clone(state)
	for i in copy["tiles"].size():
		if copy["tiles"][i] == Rules.Tile.NANKEEN:
			copy["tiles"][i] = kind
	if not keep_dark:
		copy["out"] = {}
	return copy


func _nankeen_on(state: Dictionary, puzzle: Dictionary, cell: Vector2i) -> Dictionary:
	var cursor := Rules.clone(state)
	for action in puzzle["solution"]:
		if str(action["type"]) == "move":
			var dest := Vector2i(int(cursor["player"]["x"]) + int(action["dx"]), int(cursor["player"]["y"]) + int(action["dy"]))
			var out: Dictionary = Rules.apply(cursor, action)
			cursor = out["state"]
			if dest == cell:
				return cursor
		else:
			var other: Dictionary = Rules.apply(cursor, action)
			cursor = other["state"]
	return cursor


func _check_dark_nankeen() -> void:
	var index := _nankeen_room("The Dark Nankeen")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.NANKEEN)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(2, 1) and not lit.has(cell) and lit.has(Vector2i(3, 3)), "the nankeen stays dark")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, Vector2i(3, 3)), "the solution crosses the lit gap and leaves")
	_check(_spec_result(_nankeen_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the dark nankeen, because the light stops")
	_check(_spec_result(_nankeen_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the dark nankeen, because a guard cannot enter it")


func _check_hidden_nankeen() -> void:
	var index := _nankeen_room("The Hidden Nankeen")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	var cloth := Vector2i(3, 7)
	var beyond := Vector2i(3, 6)
	var watched: Dictionary = Rules.watched_tiles(state, lit)
	var drill := _nankeen_swap(state, Rules.Tile.DRILL)
	var canvas := _nankeen_swap(state, Rules.Tile.CANVAS)
	_check(not lit.has(cloth) and lit.has(beyond) and not watched.has(cloth) and not watched.has(beyond), "the guard does not see a lit tile through the dark nankeen")
	_check(Rules.light_map(drill).has(cloth) and Rules.watched_tiles(drill, Rules.light_map(drill)).has(cloth) and not Rules.watched_tiles(drill, Rules.light_map(drill)).has(beyond), "a drill is lit, and the guard still does not see through it")
	_check(Rules.watched_tiles(canvas, Rules.light_map(canvas)).has(beyond), "a canvas lets the guard see that lit tile")
	_check(_spec_result(state, spec) == "win", "the solution leaves the hidden nankeen")
	_check(_spec_result(_nankeen_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the hidden nankeen")
	_check(_spec_result(_nankeen_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the hidden nankeen")


func _check_passed_yellow() -> void:
	var index := _nankeen_room("The Passed Yellow")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.NANKEEN)
	var spec := _solution_spec(puzzle)
	var past := Vector2i(3, 4)
	var lit: Dictionary = Rules.light_map(state)
	_check(not lit.has(cell) and lit.has(past), "a second lamp's light passes through the dark nankeen")
	_check(not Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.CAMBRIC)).has(past), "a cambric stops that second lamp")
	_check(_spec_result(state, spec) == "win", "the solution crosses the lit gap past the nankeen")
	_check(_spec_result(_nankeen_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the passed yellow, because its second lamp stops")
	_check(_spec_result(_nankeen_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the passed yellow")


func _check_open_nankeen() -> void:
	var index := _nankeen_room("The Open Nankeen")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.NANKEEN)
	var spec := _solution_spec(puzzle)
	var voile := _nankeen_swap(state, Rules.Tile.VOILE)
	var through: Array = Rules.bfs_path(state, 1, 1, 3, 1)["path"]
	var around: Array = Rules.bfs_path(voile, 1, 1, 3, 1)["path"]
	var beside := Rules.clone(state)
	beside["player"]["x"] = 2
	beside["player"]["y"] = 2
	var stepped: Dictionary = Rules.apply(beside, {"type": "move", "dx": 0, "dy": -1})
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(voile, cell.x, cell.y), "a guard can enter the dark nankeen, and a guard cannot enter the voile")
	_check(_path_has(through, cell) and not _path_has(around, cell), "the called guard walks the nankeen and walks around a voile")
	_check(stepped["result"] == Rules.Result.OK and int(stepped["state"]["player"]["y"]) == 1 and not Rules.light_map(stepped["state"]).has(cell), "the player can enter the dark nankeen, and it stays dark")
	_check(_spec_result(state, spec) == "win", "the solution clears the open nankeen")
	_check(_spec_result(_nankeen_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the open nankeen")
	_check(_spec_result(voile, spec) == "guard", "a voile does not clear the open nankeen, because the guard cannot enter it")


func _check_kept_step() -> void:
	var index := _nankeen_room("The Kept Step")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var beside := Rules.clone(state)
	beside["player"]["x"] = 2
	beside["player"]["y"] = 2
	var stepped: Dictionary = Rules.apply(beside, {"type": "move", "dx": 0, "dy": -1})
	var duck := _nankeen_swap(beside, Rules.Tile.DUCK, true)
	var duck_step: Dictionary = Rules.apply(duck, {"type": "move", "dx": 0, "dy": -1})
	var twill := _nankeen_swap(beside, Rules.Tile.TWILL, true)
	var twill_step: Dictionary = Rules.apply(twill, {"type": "move", "dx": 0, "dy": -1})
	var denim := _nankeen_swap(beside, Rules.Tile.DENIM)
	var stayed: Dictionary = Rules.apply(denim, {"type": "move", "dx": 0, "dy": -1})
	var buckram: Dictionary = Rules.apply(_nankeen_swap(beside, Rules.Tile.BUCKRAM), {"type": "move", "dx": 0, "dy": -1})
	_check(not Rules.light_map(beside).has(Vector2i(2, 1)) and stepped["result"] == Rules.Result.OK and int(stepped["state"]["player"]["y"]) == 1 and not Rules.light_map(stepped["state"]).has(Vector2i(2, 1)), "the early step onto the dark nankeen succeeds and the nankeen stays dark")
	_check(duck_step["reason"] == "dark" and not Rules.light_map(duck_step["state"]).has(Vector2i(2, 1)), "the same step onto a duck fails and the duck stays dark")
	_check(not Rules.light_map(twill).has(Vector2i(2, 1)) and twill_step["result"] == Rules.Result.OK and Rules.light_map(twill_step["state"]).has(Vector2i(2, 1)), "the same step onto a twill succeeds and lights it")
	_check(stayed["result"] == Rules.Result.OK and Rules.light_map(stayed["state"]).has(Vector2i(2, 1)) and buckram["reason"] == "lit", "the same step leaves a denim lit, and a buckram refuses it")
	_check(_spec_result(state, spec) == "win", "the solution clears the kept step")
	_check(_spec_result(_nankeen_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the kept step")
	_check(_spec_result(_nankeen_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the kept step")


func _check_last_nankeen() -> void:
	var index := _nankeen_room("The Last Nankeen")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var lit_cloth := Vector2i(2, 3)
	var dark_cloth := Vector2i(2, 5)
	var spec := _solution_spec(puzzle)
	var after := _nankeen_on(state, puzzle, lit_cloth)
	var duck := _nankeen_swap(state, Rules.Tile.DUCK, true)
	var duck_gap: Dictionary = Rules.apply(duck, {"type": "move", "dx": -1, "dy": 0})
	var duck_step: Dictionary = Rules.apply(duck_gap["state"], {"type": "move", "dx": -1, "dy": 0})
	var twill := _nankeen_swap(state, Rules.Tile.TWILL, true)
	var twill_after := _nankeen_on(twill, puzzle, lit_cloth)
	_check(not Rules.light_map(state).has(lit_cloth) and not Rules.light_map(state).has(dark_cloth), "the leaving nankeen starts dark and the other nankeen is dark")
	_check(after["player"]["x"] == 2 and after["player"]["y"] == 3 and not Rules.light_map(after).has(lit_cloth) and Rules.light_map(after).has(Vector2i(3, 3)), "the leaving step succeeds and the nankeen stays dark")
	_check(duck_step["reason"] == "dark" and int(duck_step["state"]["player"]["x"]) == 3 and not Rules.light_map(duck_step["state"]).has(lit_cloth), "the same step onto a duck fails and the duck stays dark")
	_check(Rules.light_map(twill_after).has(lit_cloth), "the same step onto a twill lights it")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, lit_cloth) and _stepped_on_while_dark(state, puzzle, lit_cloth) and not _visited(state, puzzle, dark_cloth), "you leave by stepping on the dark nankeen, and that step leaves it dark")
	_check(_spec_result(_nankeen_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the last nankeen")
	_check(_spec_result(_nankeen_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the last nankeen")


func _check_nankeen_step_stays_dark() -> void:
	var rows := PackedStringArray(["######", "#.S@.#", "######"])
	var lamps: Array = [{"x": 4, "y": 1, "facing": "w", "radius": 2, "lit": true}]
	var state := Rules.build(rows, lamps, [{"x": 1, "y": 1, "vision": 0, "rail": [Vector2i(1, 1)]}])
	var cell := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var duck := _nankeen_swap(state, Rules.Tile.DUCK, true)
	var duck_step: Dictionary = Rules.apply(duck, {"type": "move", "dx": 1, "dy": 0})
	var twill := _nankeen_swap(state, Rules.Tile.TWILL, true)
	var twill_step: Dictionary = Rules.apply(twill, {"type": "move", "dx": 1, "dy": 0})
	var cambric := _nankeen_swap(state, Rules.Tile.CAMBRIC)
	_check(not lit.has(cell) and lit.has(Vector2i(2, 1)) and stepped["result"] == Rules.Result.OK and int(stepped["state"]["player"]["x"]) == 3 and not Rules.light_map(stepped["state"]).has(cell) and Rules.light_map(stepped["state"]).has(Vector2i(2, 1)), "the step onto the dark nankeen succeeds, the nankeen stays dark, and the light still passes")
	_check(duck_step["reason"] == "dark" and not Rules.light_map(duck_step["state"]).has(cell), "a duck refuses that step and stays dark")
	_check(not Rules.light_map(twill).has(cell) and twill_step["result"] == Rules.Result.OK and Rules.light_map(twill_step["state"]).has(cell), "a twill starts dark and the same step lights it")
	_check(not Rules.light_map(cambric).has(Vector2i(2, 1)), "a cambric stops the light a nankeen lets through")
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(_nankeen_swap(state, Rules.Tile.VOILE), cell.x, cell.y), "a guard can enter the nankeen and cannot enter a voile")


func _check_jean_snuffs_are_required() -> void:
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Jean Wing":
			continue
		var uses := false
		for action in puzzle["solution"]:
			if str(action["type"]) == "toggle":
				uses = true
		if uses:
			_check_toggles_required(index)


func _check_jean_rooms() -> void:
	_check_jean_identity()
	_check_earlier_wings_have_no_jeans()
	_check_dark_jean()
	_check_hidden_jean()
	_check_passed_rivet()
	_check_open_jean()
	_check_lit_step()
	_check_last_jean()
	_check_jean_step_lights_and_stays()


func _check_jean_identity() -> void:
	var seen := {}
	var titles := {}
	var layout_ok := true
	var title_ok := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) != "Jean Wing":
			continue
		var rows := ""
		for row in puzzle["rows"]:
			rows += str(row)
		if seen.has(rows):
			layout_ok = false
		seen[rows] = true
		var title := str(puzzle["title"])
		if titles.has(title):
			title_ok = false
		titles[title] = true
	var once := true
	var wing_titles: Array = titles.keys()
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Jean Wing":
			continue
		if titles.has(str(puzzle["title"])):
			once = false
	_check(layout_ok, "each jean room has its own layout")
	_check(title_ok, "each jean room has its own name")
	_check(once and wing_titles.size() == 6, "the jean titles are not reused")


func _jean_room(title: String) -> int:
	for i in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(i)
		if str(puzzle["wing"]) == "Jean Wing" and str(puzzle["title"]) == title:
			return i
	return -1


func _check_earlier_wings_have_no_jeans() -> void:
	var clean := true
	for index in Puzzles.count():
		var puzzle: Dictionary = Puzzles.get_puzzle(index)
		if str(puzzle["wing"]) == "Jean Wing":
			continue
		for row in puzzle["rows"]:
			if str(row).contains("="):
				clean = false
	_check(clean, "earlier wings have no jeans")


func _jean_swap(state: Dictionary, kind: int, keep_dark: bool = false) -> Dictionary:
	var copy := Rules.clone(state)
	for i in copy["tiles"].size():
		if copy["tiles"][i] == Rules.Tile.JEAN:
			copy["tiles"][i] = kind
	if not keep_dark:
		copy["out"] = {}
	return copy


func _check_dark_jean() -> void:
	var index := _jean_room("The Dark Jean")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.JEAN)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	_check(cell == Vector2i(2, 1) and not lit.has(cell) and lit.has(Vector2i(3, 3)), "the jean starts dark")
	_check(_spec_result(state, spec) == "win" and _visited(state, puzzle, Vector2i(3, 3)), "the solution crosses the lit gap and leaves")
	_check(_spec_result(_jean_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the dark jean, because the light stops")
	_check(_spec_result(_jean_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the dark jean, because a guard cannot enter it")


func _check_hidden_jean() -> void:
	var index := _jean_room("The Hidden Jean")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var lit: Dictionary = Rules.light_map(state)
	var cloth := Vector2i(3, 7)
	var beyond := Vector2i(3, 6)
	var watched: Dictionary = Rules.watched_tiles(state, lit)
	var drill := _jean_swap(state, Rules.Tile.DRILL)
	var canvas := _jean_swap(state, Rules.Tile.CANVAS)
	_check(not lit.has(cloth) and lit.has(beyond) and not watched.has(cloth) and not watched.has(beyond), "the guard does not see a lit tile through the dark jean")
	_check(Rules.light_map(drill).has(cloth) and Rules.watched_tiles(drill, Rules.light_map(drill)).has(cloth) and not Rules.watched_tiles(drill, Rules.light_map(drill)).has(beyond), "a drill is lit, and the guard still does not see through it")
	_check(Rules.watched_tiles(canvas, Rules.light_map(canvas)).has(beyond), "a canvas lets the guard see that lit tile")
	_check(_spec_result(state, spec) == "win", "the solution leaves the hidden jean")
	_check(_spec_result(_jean_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the hidden jean")
	_check(_spec_result(_jean_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the hidden jean")


func _check_passed_rivet() -> void:
	var index := _jean_room("The Passed Rivet")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.JEAN)
	var spec := _solution_spec(puzzle)
	var past := Vector2i(3, 4)
	var lit: Dictionary = Rules.light_map(state)
	_check(not lit.has(cell) and lit.has(past), "a second lamp's light passes through the dark jean")
	_check(not Rules.light_map(_with_tile(state, cell.x, cell.y, Rules.Tile.CAMBRIC)).has(past), "a cambric stops that second lamp")
	_check(_spec_result(state, spec) == "win", "the solution crosses the lit gap past the jean")
	_check(_spec_result(_jean_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the passed rivet, because its second lamp stops")
	_check(_spec_result(_jean_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the passed rivet")


func _check_open_jean() -> void:
	var index := _jean_room("The Open Jean")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var cell := _find_tile(state, Rules.Tile.JEAN)
	var spec := _solution_spec(puzzle)
	var voile := _jean_swap(state, Rules.Tile.VOILE)
	var through: Array = Rules.bfs_path(state, 1, 1, 3, 1)["path"]
	var around: Array = Rules.bfs_path(voile, 1, 1, 3, 1)["path"]
	var beside := Rules.clone(state)
	beside["player"]["x"] = 2
	beside["player"]["y"] = 2
	var stepped: Dictionary = Rules.apply(beside, {"type": "move", "dx": 0, "dy": -1})
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(voile, cell.x, cell.y), "a guard can enter the dark jean, and a guard cannot enter the voile")
	_check(_path_has(through, cell) and not _path_has(around, cell), "the called guard walks the jean and walks around a voile")
	_check(stepped["result"] == Rules.Result.OK and int(stepped["state"]["player"]["y"]) == 1 and Rules.light_map(stepped["state"]).has(cell), "the player can enter the dark jean, and that step lights it")
	_check(_spec_result(state, spec) == "win", "the solution clears the open jean")
	_check(_spec_result(_jean_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the open jean")
	_check(_spec_result(voile, spec) == "guard", "a voile does not clear the open jean, because the guard cannot enter it")


func _check_lit_step() -> void:
	var index := _jean_room("The Lit Step")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var spec := _solution_spec(puzzle)
	var beside := Rules.clone(state)
	beside["player"]["x"] = 2
	beside["player"]["y"] = 2
	var stepped: Dictionary = Rules.apply(beside, {"type": "move", "dx": 0, "dy": -1})
	var stayed: Dictionary = Rules.apply(stepped["state"], {"type": "move", "dx": 0, "dy": 1})
	var nankeen := _jean_swap(beside, Rules.Tile.NANKEEN, true)
	var nankeen_step: Dictionary = Rules.apply(nankeen, {"type": "move", "dx": 0, "dy": -1})
	var duck := _jean_swap(beside, Rules.Tile.DUCK, true)
	var duck_step: Dictionary = Rules.apply(duck, {"type": "move", "dx": 0, "dy": -1})
	var twill := _jean_swap(beside, Rules.Tile.TWILL, true)
	var twill_step: Dictionary = Rules.apply(twill, {"type": "move", "dx": 0, "dy": -1})
	var denim := _jean_swap(beside, Rules.Tile.DENIM)
	var denim_step: Dictionary = Rules.apply(denim, {"type": "move", "dx": 0, "dy": -1})
	var buckram: Dictionary = Rules.apply(_jean_swap(beside, Rules.Tile.BUCKRAM), {"type": "move", "dx": 0, "dy": -1})
	_check(not Rules.light_map(beside).has(Vector2i(2, 1)) and stepped["result"] == Rules.Result.OK and int(stepped["state"]["player"]["y"]) == 1 and Rules.light_map(stepped["state"]).has(Vector2i(2, 1)), "the early step onto the dark jean succeeds and lights it")
	_check(stayed["reason"] == "stay" and int(stayed["state"]["player"]["y"]) == 1 and Rules.light_map(stayed["state"]).has(Vector2i(2, 1)), "the leaving step fails and the player stays on the lit jean")
	_check(nankeen_step["result"] == Rules.Result.OK and not Rules.light_map(nankeen_step["state"]).has(Vector2i(2, 1)), "the same step onto a nankeen succeeds and the nankeen stays dark")
	_check(duck_step["reason"] == "dark" and int(duck_step["state"]["player"]["y"]) == 2 and not Rules.light_map(duck_step["state"]).has(Vector2i(2, 1)), "the same step onto a duck fails and the duck stays dark")
	_check(not Rules.light_map(twill).has(Vector2i(2, 1)) and twill_step["result"] == Rules.Result.OK and Rules.light_map(twill_step["state"]).has(Vector2i(2, 1)), "the same step onto a twill lights it")
	_check(denim_step["result"] == Rules.Result.OK and Rules.light_map(denim_step["state"]).has(Vector2i(2, 1)) and buckram["reason"] == "lit", "the same step leaves a denim lit, and a buckram refuses it")
	_check(_spec_result(state, spec) == "win", "the solution clears the lit step")
	_check(_spec_result(_jean_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the lit step")
	_check(_spec_result(_jean_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the lit step")


func _check_last_jean() -> void:
	var index := _jean_room("The Last Jean")
	var puzzle: Dictionary = Puzzles.get_puzzle(index)
	var state := Puzzles.initial_state(index)
	var lit_cloth := Vector2i(2, 3)
	var dark_cloth := Vector2i(2, 5)
	var spec := _solution_spec(puzzle)
	var toward: Dictionary = Rules.apply(state, {"type": "move", "dx": -1, "dy": 0})
	var onto: Dictionary = Rules.apply(toward["state"], {"type": "move", "dx": -1, "dy": 0})
	var leave: Dictionary = Rules.apply(onto["state"], {"type": "move", "dx": 1, "dy": 0})
	var nankeen := _jean_swap(state, Rules.Tile.NANKEEN, true)
	var nankeen_gap: Dictionary = Rules.apply(nankeen, {"type": "move", "dx": -1, "dy": 0})
	var nankeen_step: Dictionary = Rules.apply(nankeen_gap["state"], {"type": "move", "dx": -1, "dy": 0})
	var nankeen_leave: Dictionary = Rules.apply(nankeen_step["state"], {"type": "move", "dx": 1, "dy": 0})
	var duck := _jean_swap(state, Rules.Tile.DUCK, true)
	var duck_gap: Dictionary = Rules.apply(duck, {"type": "move", "dx": -1, "dy": 0})
	var duck_step: Dictionary = Rules.apply(duck_gap["state"], {"type": "move", "dx": -1, "dy": 0})
	var twill := _jean_swap(state, Rules.Tile.TWILL, true)
	var twill_gap: Dictionary = Rules.apply(twill, {"type": "move", "dx": -1, "dy": 0})
	var twill_step: Dictionary = Rules.apply(twill_gap["state"], {"type": "move", "dx": -1, "dy": 0})
	var twill_leave: Dictionary = Rules.apply(twill_step["state"], {"type": "move", "dx": 1, "dy": 0})
	_check(not Rules.light_map(state).has(lit_cloth) and not Rules.light_map(state).has(dark_cloth), "the leaving jean starts dark and the other jean is dark")
	_check(onto["result"] == Rules.Result.OK and int(onto["state"]["player"]["x"]) == 2 and Rules.light_map(onto["state"]).has(lit_cloth), "stepping onto the jean lights it")
	_check(leave["reason"] == "stay" and int(leave["state"]["player"]["x"]) == 2 and Rules.light_map(leave["state"]).has(lit_cloth), "the leaving step fails and the player stays on the lit jean")
	_check(nankeen_step["result"] == Rules.Result.OK and not Rules.light_map(nankeen_step["state"]).has(lit_cloth) and nankeen_leave["result"] == Rules.Result.OK and int(nankeen_leave["state"]["player"]["x"]) == 3, "the same steps onto a nankeen succeed and the nankeen stays dark")
	_check(duck_step["reason"] == "dark" and int(duck_step["state"]["player"]["x"]) == 3 and not Rules.light_map(duck_step["state"]).has(lit_cloth), "the same step onto a duck fails and the duck stays dark")
	_check(twill_step["result"] == Rules.Result.OK and Rules.light_map(twill_step["state"]).has(lit_cloth) and twill_leave["result"] == Rules.Result.OK and int(twill_leave["state"]["player"]["x"]) == 3, "the same step onto a twill lights it and the player leaves")
	_check(_spec_result(state, spec) == "win" and not _visited(state, puzzle, lit_cloth) and not _visited(state, puzzle, dark_cloth), "the solution leaves without stepping on the jean")
	_check(_spec_result(_jean_swap(state, Rules.Tile.CAMBRIC), spec) == "darkgap", "a cambric does not clear the last jean")
	_check(_spec_result(_jean_swap(state, Rules.Tile.VOILE), spec) == "guard", "a voile does not clear the last jean")


func _check_jean_step_lights_and_stays() -> void:
	var rows := PackedStringArray(["######", "#.S=.#", "######"])
	var lamps: Array = [{"x": 4, "y": 1, "facing": "w", "radius": 2, "lit": true}]
	var state := Rules.build(rows, lamps, [{"x": 1, "y": 1, "vision": 0, "rail": [Vector2i(1, 1)]}])
	var cell := Vector2i(3, 1)
	var lit: Dictionary = Rules.light_map(state)
	var stepped: Dictionary = Rules.apply(state, {"type": "move", "dx": 1, "dy": 0})
	var stayed: Dictionary = Rules.apply(stepped["state"], {"type": "move", "dx": -1, "dy": 0})
	var nankeen := _jean_swap(state, Rules.Tile.NANKEEN, true)
	var nankeen_step: Dictionary = Rules.apply(nankeen, {"type": "move", "dx": 1, "dy": 0})
	var duck := _jean_swap(state, Rules.Tile.DUCK, true)
	var duck_step: Dictionary = Rules.apply(duck, {"type": "move", "dx": 1, "dy": 0})
	var twill := _jean_swap(state, Rules.Tile.TWILL, true)
	var twill_step: Dictionary = Rules.apply(twill, {"type": "move", "dx": 1, "dy": 0})
	var cambric := _jean_swap(state, Rules.Tile.CAMBRIC)
	_check(not lit.has(cell) and lit.has(Vector2i(2, 1)) and stepped["result"] == Rules.Result.OK and int(stepped["state"]["player"]["x"]) == 3 and Rules.light_map(stepped["state"]).has(cell) and Rules.light_map(stepped["state"]).has(Vector2i(2, 1)), "the step onto the dark jean lights it, and the light still passes")
	_check(stayed["reason"] == "stay" and int(stayed["state"]["player"]["x"]) == 3 and Rules.light_map(stayed["state"]).has(cell), "the leaving step fails and the player stays on the lit jean")
	_check(nankeen_step["result"] == Rules.Result.OK and not Rules.light_map(nankeen_step["state"]).has(cell), "a nankeen stays dark under that step")
	_check(duck_step["reason"] == "dark" and not Rules.light_map(duck_step["state"]).has(cell), "a duck refuses that step and stays dark")
	_check(not Rules.light_map(twill).has(cell) and twill_step["result"] == Rules.Result.OK and Rules.light_map(twill_step["state"]).has(cell), "a twill starts dark and the same step lights it")
	_check(not Rules.light_map(cambric).has(Vector2i(2, 1)), "a cambric stops the light a jean lets through")
	_check(Rules.guard_walkable(state, cell.x, cell.y) and not Rules.guard_walkable(_jean_swap(state, Rules.Tile.VOILE), cell.x, cell.y), "a guard can enter the jean and cannot enter a voile")
