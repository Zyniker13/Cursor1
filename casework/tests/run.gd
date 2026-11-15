extends SceneTree

const CaseData = preload("res://scripts/case_data.gd")
const Rehearsal = preload("res://scripts/rehearsal_score.gd")
const Gilt = preload("res://scripts/gilt_stamp.gd")
const Catalog = preload("res://scripts/catalog.gd")
const Solver = preload("res://scripts/solver.gd")
const Verdict = preload("res://scripts/verdict.gd")

const TIMELINE := "Nell (night cook) took the spare key at 7 from the front desk to the kitchen, to lock the pantry.\nMoss (lodger) noticed the hook empty at 8 at the front desk and wrote a complaint.\nAda (clerk) logged the key returned at 9 at the front desk."
const REHEARSAL_TIMELINE := "Ivo (copyist) took the rehearsal score at 4 from the library to the practice room, to mark the cuts.\nNia (pianist) saw the taking from the gallery.\nBess (tuner) found the shelf empty at 5 in the library.\nThe score was logged back on the shelf at 6."
const REHEARSAL_TRUE := {"who": "Ivo", "place": "practice_room", "hour": "4"}
const GILT_TIMELINE := "Nessa (porter) took the gilt stamp at 1 from the store cage to the finishing bench, to lay the title edge.\nMara (binder) wrote the move order in the press room.\nTheo (gilder) signed the stamp back at 3 into the store cage.\nThe bench receipt was marked at 2."
const GILT_TRUE := {"who": "Nessa", "place": "finishing_bench", "hour": "1"}

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
	_expect_rejected(spare, Rehearsal)
	_expect_rejected(REHEARSAL_TRUE, CaseData)
	_expect_rejected(GILT_TRUE, CaseData)
	_expect_rejected(GILT_TRUE, Rehearsal)
	_expect_rejected(spare, Gilt)
	_expect_rejected(REHEARSAL_TRUE, Gilt)
	for person in Gilt.PEOPLE:
		_expect(not CaseData.PEOPLE.has(person), "gilt cast repeats %s from the spare key" % person)
		_expect(not Rehearsal.PEOPLE.has(person), "gilt cast repeats %s from the rehearsal score" % person)
	for place in Gilt.PLACES:
		_expect(not CaseData.PLACES.has(place), "gilt rooms repeat %s from the spare key" % place)
		_expect(not Rehearsal.PLACES.has(place), "gilt rooms repeat %s from the rehearsal score" % place)
	for hour in Gilt.HOURS:
		_expect(not CaseData.HOURS.has(hour), "gilt hours repeat %s from the spare key" % hour)
		_expect(not Rehearsal.HOURS.has(hour), "gilt hours repeat %s from the rehearsal score" % hour)
	var titles: Array[String] = []
	for book in Catalog.all():
		titles.append(str(book.TITLE))
	_expect(titles == ["The spare key", "The rehearsal score", "The gilt stamp"], "case list is %s" % str(titles))


func _test_menu_opens_either_case() -> void:
	get_root().size = Vector2i(1280, 800)
	var packed := load("res://scenes/main.tscn") as PackedScene
	var root := packed.instantiate()
	get_root().add_child(root)
	_expect(root.get_script() != null, "main scene script did not load")
	if root.get_child_count() == 0:
		root._ready()
	_expect(root.get_child_count() > 0, "main scene built %d children" % root.get_child_count())
	_press(root, "How to play")
	var howto := _visible_label_blob(root)
	_expect(howto.find("The spare key") >= 0, "how to play omits The spare key")
	_expect(howto.find("The rehearsal score") >= 0, "how to play omits The rehearsal score")
	_expect(howto.find("The gilt stamp") >= 0, "how to play omits The gilt stamp")
	_expect(howto.find("names that slot") >= 0, "how to play omits the empty-slot rule")
	_press(root, "Back to the menu")
	_expect(_find_visible_button(root, "Open The spare key") != null, "menu is missing The spare key")
	_expect(_find_visible_button(root, "Open The rehearsal score") != null, "menu is missing The rehearsal score")
	_expect(_find_visible_button(root, "Open The gilt stamp") != null, "menu is missing The gilt stamp")
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
