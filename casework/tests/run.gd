extends SceneTree

const CaseData = preload("res://scripts/case_data.gd")
const Solver = preload("res://scripts/solver.gd")
const Verdict = preload("res://scripts/verdict.gd")

const TIMELINE := "Nell (night cook) took the spare key at 7 from the front desk to the kitchen, to lock the pantry.\nMoss (lodger) noticed the hook empty at 8 at the front desk and wrote a complaint.\nAda (clerk) logged the key returned at 9 at the front desk."

var _failures: Array[String] = []
var _checks := 0


func _initialize() -> void:
	_test_file_shape()
	_test_unique_model()
	_test_each_exhibit_necessary()
	_test_true_theory_accepted()
	_test_wrong_theories()
	_test_incomplete()
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


func _expect_rejected(theory: Dictionary) -> void:
	var result: Dictionary = Verdict.submit(theory)
	var label := "%s / %s / %s" % [theory["who"], theory["place"], theory["hour"]]
	_expect(result["status"] == "rejected", "%s status %s" % [label, result["status"]])
	var message := str(result["message"])
	_expect(message.find("fits every exhibit") == -1, "%s was treated as fitting" % label)
	var conflicting := CaseData.conflicting_ids(theory)
	_expect(conflicting.size() >= 2, "%s contradicts %d exhibits" % [label, conflicting.size()])
	var cited := _cited_ids(message)
	_expect(cited.size() >= 2, "%s reply cites %d exhibits: %s" % [label, cited.size(), message])
	for exhibit_id in cited:
		_expect(exhibit_id in CaseData.ids(), "%s cites unknown %s" % [label, exhibit_id])
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
