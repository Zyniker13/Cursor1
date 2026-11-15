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

var _failures: Array[String] = []
var _checks := 0


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
	_test_solutions_differ()
	_test_menu_opens_either_case()
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
	var titles: Array[String] = []
	for book in Catalog.all():
		titles.append(str(book.TITLE))
	_expect(titles == ["The spare key", "The rehearsal score", "The gilt stamp", "The ferry bell", "The weather slate", "The loom shuttle", "The hive smoker", "The glass pontil", "The press proof", "The assay cup"], "case list is %s" % str(titles))


func _test_menu_opens_either_case() -> void:
	get_root().size = Vector2i(1280, 800)
	var packed := load("res://scenes/main.tscn") as PackedScene
	var root := packed.instantiate()
	get_root().add_child(root)
	_expect(root.get_script() != null, "main scene script did not load")
	if root.get_child_count() == 0:
		root._ready()
	var menu_blob := _visible_label_blob(root)
	_expect(menu_blob.find("Ten files") >= 0, "menu does not offer ten files: %s" % menu_blob)
	_expect(menu_blob.find("CW-07") >= 0, "menu omits CW-07")
	_expect(menu_blob.find("The hive smoker") >= 0, "menu omits The hive smoker")
	_expect(menu_blob.find("CW-08") >= 0, "menu omits CW-08")
	_expect(menu_blob.find("The glass pontil") >= 0, "menu omits The glass pontil")
	_expect(menu_blob.find("CW-09") >= 0, "menu omits CW-09")
	_expect(menu_blob.find("The press proof") >= 0, "menu omits The press proof")
	_expect(menu_blob.find("CW-10") >= 0, "menu omits CW-10")
	_expect(menu_blob.find("The assay cup") >= 0, "menu omits The assay cup")
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
	root.queue_free()


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
