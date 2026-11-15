extends RefCounted

const CaseData = preload("res://scripts/case_data.gd")
const Solver = preload("res://scripts/solver.gd")


static func submit(theory: Dictionary) -> Dictionary:
	var missing := CaseData.missing_slots(theory)
	if not missing.is_empty():
		return {
			"status": "incomplete",
			"message": _incomplete_message(missing),
		}
	var fitting: Array = []
	for model in Solver.enumerate(CaseData.EXHIBITS):
		if CaseData.matches_theory(model, theory):
			fitting.append(model)
	if fitting.size() == 1:
		return {
			"status": "accepted",
			"message": "Accepted. This theory fits every exhibit.\n\n%s" % CaseData.timeline(fitting[0]),
		}
	if fitting.size() > 1:
		return {
			"status": "accepted",
			"message": "Accepted. This theory fits every exhibit.",
		}
	return {
		"status": "rejected",
		"message": _rejection_message(theory),
	}


static func _incomplete_message(missing: Array[String]) -> String:
	var noun := "slot" if missing.size() == 1 else "slots"
	return "The board is incomplete. Pin the missing %s: %s." % [noun, ", ".join(missing)]


static func _rejection_message(theory: Dictionary) -> String:
	var lines: PackedStringArray = ["Not accepted."]
	var cited := 0
	for field in CaseData.FIELD_ORDER:
		var names: PackedStringArray = []
		var counters: PackedStringArray = []
		for exhibit in CaseData.EXHIBITS:
			for literal in CaseData.conflicts(exhibit, theory):
				if str(literal["field"]) != field:
					continue
				names.append("%s (%s)" % [exhibit["id"], exhibit["title"]])
				var counter := CaseData.counter_claim(field, str(literal["value"]))
				if counter not in counters:
					counters.append(counter)
				cited += 1
		if names.is_empty():
			continue
		var verb := "says" if names.size() == 1 else "say"
		lines.append(
			"Your claim that %s conflicts with %s, which %s %s."
			% [CaseData.short_claim(field, theory), _and_join(names), verb, _and_join(counters)]
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
