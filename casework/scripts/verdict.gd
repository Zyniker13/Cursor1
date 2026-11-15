extends RefCounted

const CaseData = preload("res://scripts/case_data.gd")
const Solver = preload("res://scripts/solver.gd")


static func submit(theory: Dictionary, case_data = null) -> Dictionary:
	var book = CaseData if case_data == null else case_data
	var missing: Array[String] = book.missing_slots(theory)
	if not missing.is_empty():
		return {
			"status": "incomplete",
			"message": _incomplete_message(missing),
		}
	var fitting: Array = []
	for model in Solver.enumerate(book.EXHIBITS, book):
		if book.matches_theory(model, theory):
			fitting.append(model)
	if fitting.size() == 1:
		return {
			"status": "accepted",
			"message": "Accepted. This theory fits every exhibit.\n\n%s" % book.timeline(fitting[0]),
		}
	if fitting.size() > 1:
		return {
			"status": "accepted",
			"message": "Accepted. This theory fits every exhibit.",
		}
	return {
		"status": "rejected",
		"message": _rejection_message(theory, book),
	}


static func _incomplete_message(missing: Array[String]) -> String:
	var noun := "slot" if missing.size() == 1 else "slots"
	return "The board is incomplete. Pin the missing %s: %s." % [noun, ", ".join(missing)]


static func _rejection_message(theory: Dictionary, book) -> String:
	var lines: PackedStringArray = ["Not accepted."]
	var cited := 0
	for field in book.FIELD_ORDER:
		var names: PackedStringArray = []
		var counters: PackedStringArray = []
		for exhibit in book.EXHIBITS:
			for literal in book.conflicts(exhibit, theory):
				if str(literal["field"]) != field:
					continue
				names.append("%s (%s)" % [exhibit["id"], exhibit["title"]])
				var counter: String = book.counter_claim(field, str(literal["value"]))
				if counter not in counters:
					counters.append(counter)
				cited += 1
		if names.is_empty():
			continue
		var verb := "says" if names.size() == 1 else "say"
		lines.append(
			"Your claim that %s conflicts with %s, which %s %s."
			% [book.short_claim(field, theory), _and_join(names), verb, _and_join(counters)]
		)
	if cited < 2:
		lines.append("The reply could not name two exhibits.")
	return "\n".join(lines)


static func _and_join(parts: PackedStringArray) -> String:
	if parts.size() <= 1:
		return parts[0] if parts.size() == 1 else ""
	if parts.size() == 2:
		return "%s and %s" % [parts[0], parts[1]]
	var head := parts.slice(0, parts.size() - 1)
	return ", ".join(head) + " and " + parts[parts.size() - 1]
