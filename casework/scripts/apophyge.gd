extends RefCounted

# The apophyge.
#
# The player pins three facts about the cutting: who, the room the apophyge was
# cut in, and the hour. The timeline also records who marked the robinia, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the quire, where that turn was made, why the apophyge was cut, where
# the service was hung, when the quire was lacquered, when the graver was inked, and
# when the chapel was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The apophyge"
const FILE_CODE := "CW-55"
const BLURB := "The apophyge left its peg at the joiner's ferrule. Name who cut the apophyge, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Linnea", "Rune", "Sigrid"]
const PLACES: Array[String] = ["chapel", "quire", "graver"]
const HOURS: Array[String] = ["216", "217", "218", "219", "220"]
const AIMS: Array[String] = ["take_robinia", "spare_robinia", "set_robinia"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Robinia chit",
		"source": "Rune, robinia hand",
		"text": "Linnea cut the apophyge. Rune had marked the robinia, and a pale purpurin still clung to the apophyge.",
		"literals": [
			{
				"field": "taker",
				"value": "Linnea",
				"phrase": "Linnea cut the apophyge",
			},
			{
				"field": "robinia",
				"value": "Rune",
				"phrase": "Rune had marked the robinia",
			},
		],
	},
	{
		"id": "E2",
		"title": "Emodin sight",
		"source": "Quire emodin",
		"text": "Linnea cut the apophyge. The apophygeing was seen from the quire, beside the open robinia.",
		"literals": [
			{
				"field": "taker",
				"value": "Linnea",
				"phrase": "Linnea cut the apophyge",
			},
			{
				"field": "seen_from",
				"value": "quire",
				"phrase": "The apophygeing was seen from the quire",
			},
		],
	},
	{
		"id": "E3",
		"title": "Service bill",
		"source": "Graver nose",
		"text": "Linnea cut the apophyge. With the robinia true, the service was hung on the graver.",
		"literals": [
			{
				"field": "taker",
				"value": "Linnea",
				"phrase": "Linnea cut the apophyge",
			},
			{
				"field": "service_room",
				"value": "graver",
				"phrase": "the service was hung on the graver",
			},
		],
	},
	{
		"id": "E4",
		"title": "Bixin slate",
		"source": "Chapel bixin",
		"text": "The apophyge was cut in the chapel. A fresh bixin shows the robinia had been marked on the graver.",
		"literals": [
			{
				"field": "place",
				"value": "chapel",
				"phrase": "The apophyge was cut in the chapel",
			},
			{
				"field": "robinia_room",
				"value": "graver",
				"phrase": "the robinia had been marked on the graver",
			},
		],
	},
	{
		"id": "E5",
		"title": "Quire card",
		"source": "Sigrid, quire clerk",
		"text": "The apophyge was cut in the chapel. Sigrid turned the quire in the chapel once the robinia was offered.",
		"literals": [
			{
				"field": "place",
				"value": "chapel",
				"phrase": "The apophyge was cut in the chapel",
			},
			{
				"field": "quire",
				"value": "Sigrid",
				"phrase": "Sigrid turned the quire",
			},
			{
				"field": "quire_room",
				"value": "chapel",
				"phrase": "turned the quire in the chapel",
			},
		],
	},
	{
		"id": "E6",
		"title": "Lacquered slip",
		"source": "Quire tote",
		"text": "The apophyge was cut in the chapel. The quire was lacquered at 216, and a pale juglone still sat on the apophyge.",
		"literals": [
			{
				"field": "place",
				"value": "chapel",
				"phrase": "The apophyge was cut in the chapel",
			},
			{
				"field": "lacquer_hour",
				"value": "216",
				"phrase": "The quire was lacquered at 216",
			},
		],
	},
	{
		"id": "E7",
		"title": "Apophyge leaf",
		"source": "Robinia book",
		"text": "The apophyge was cut at 218. The robinia had been marked at 217, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "218",
				"phrase": "The apophyge was cut at 218",
			},
			{
				"field": "robinia_hour",
				"value": "217",
				"phrase": "The robinia had been marked at 217",
			},
		],
	},
	{
		"id": "E8",
		"title": "Ferrule note",
		"source": "Joiner's ferrule",
		"text": "The apophyge was cut at 218. The robinia was opened so the robinia would take the apophyge.",
		"literals": [
			{
				"field": "hour",
				"value": "218",
				"phrase": "The apophyge was cut at 218",
			},
			{
				"field": "aim",
				"value": "take_robinia",
				"phrase": "so the robinia would take the apophyge",
			},
		],
	},
	{
		"id": "E9",
		"title": "Inked order",
		"source": "Graver card",
		"text": "The apophyge was cut at 218. The graver was inked at 219, and the chapel was hung at 220 once the robinia was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "218",
				"phrase": "The apophyge was cut at 218",
			},
			{
				"field": "ink_hour",
				"value": "219",
				"phrase": "The graver was inked at 219",
			},
			{
				"field": "hang_hour",
				"value": "220",
				"phrase": "the chapel was hung at 220",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"robinia",
		"robinia_room",
		"robinia_hour",
		"seen_from",
		"quire",
		"aim",
		"quire_room",
		"service_room",
		"lacquer_hour",
		"ink_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "robinia", "quire":
			return PEOPLE.duplicate()
		"place", "robinia_room", "seen_from", "quire_room", "service_room":
			return PLACES.duplicate()
		"hour", "robinia_hour", "lacquer_hour", "ink_hour", "hang_hour":
			return HOURS.duplicate()
		"aim":
			return AIMS.duplicate()
		_:
			push_error("Unknown timeline field: %s" % field)
			return []


static func ids() -> Array[String]:
	var found: Array[String] = []
	for exhibit in EXHIBITS:
		found.append(str(exhibit["id"]))
	return found


static func without(exhibit_id: String) -> Array:
	var kept: Array = []
	for exhibit in EXHIBITS:
		if str(exhibit["id"]) != exhibit_id:
			kept.append(exhibit)
	return kept


static func holds(exhibit: Dictionary, model: Dictionary) -> bool:
	for literal in exhibit["literals"]:
		if str(model.get(literal["field"], "")) != str(literal["value"]):
			return false
	return true


static func normalize(theory: Dictionary) -> Dictionary:
	return {
		"who": str(theory.get("who", "")).strip_edges(),
		"place": str(theory.get("place", "")).strip_edges(),
		"hour": str(theory.get("hour", "")).strip_edges(),
	}


static func missing_slots(theory: Dictionary) -> Array[String]:
	var pins := normalize(theory)
	var missing: Array[String] = []
	if pins["who"] == "":
		missing.append("who cut the apophyge")
	if pins["place"] == "":
		missing.append("where they cut the apophyge")
	if pins["hour"] == "":
		missing.append("at which hour they cut the apophyge")
	return missing


static func theory_value(field: String, theory: Dictionary) -> String:
	var pins := normalize(theory)
	match field:
		"taker":
			return pins["who"]
		"place":
			return pins["place"]
		"hour":
			return pins["hour"]
		_:
			return ""


static func conflicts(exhibit: Dictionary, theory: Dictionary) -> Array:
	var broken: Array = []
	for literal in exhibit["literals"]:
		var field := str(literal["field"])
		if field not in PLAYER_FIELDS:
			continue
		if theory_value(field, theory) != str(literal["value"]):
			broken.append(literal)
	return broken


static func conflicting_ids(theory: Dictionary) -> Array[String]:
	var found: Array[String] = []
	for exhibit in EXHIBITS:
		if not conflicts(exhibit, theory).is_empty():
			found.append(str(exhibit["id"]))
	return found


static func role_phrase(person: String) -> String:
	match person:
		"Linnea":
			return "the apophyge hand"
		"Rune":
			return "the robinia hand"
		"Sigrid":
			return "the quire clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"chapel":
			return "chapel"
		"quire":
			return "quire"
		"graver":
			return "graver"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"chapel":
			return "Chapel"
		"quire":
			return "Quire"
		"graver":
			return "Graver"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the apophyge" % value
		"place":
			return "The apophyge was cut in the %s" % place_label(value)
		"hour":
			return "The apophyge was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the apophyge" % value
		"place":
			return "the apophyge was cut in the %s" % place_label(value)
		"hour":
			return "the apophyge was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the apophyge" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_robinia":
			return "so the robinia would take the apophyge"
		"spare_robinia":
			return "to spare the robinia still waiting on the apophyge"
		"set_robinia":
			return "to set the robinia before the chapel was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the apophyge in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the robinia on the %s at %s." % [
			model["robinia"],
			role_short(str(model["robinia"])),
			place_label(str(model["robinia_room"])),
			model["robinia_hour"],
		],
		"%s (%s) turned the quire in the %s." % [
			model["quire"],
			role_short(str(model["quire"])),
			place_label(str(model["quire_room"])),
		],
		"The service was hung on the %s." % place_label(str(model["service_room"])),
		"The quire was lacquered at %s." % model["lacquer_hour"],
		"The graver was inked at %s." % model["ink_hour"],
		"The chapel was hung at %s." % model["hang_hour"],
	])
	return "\n".join(lines)


static func matches_theory(model: Dictionary, theory: Dictionary) -> bool:
	var pins := normalize(theory)
	return (
		str(model["taker"]) == pins["who"]
		and str(model["place"]) == pins["place"]
		and str(model["hour"]) == pins["hour"]
	)


static func exhibit_heading() -> String:
	return "The file  ·  nine exhibits"


static func board_question() -> String:
	return "Who cut the apophyge, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the apophyge in."


static func cast_line() -> String:
	return "Linnea, apophyge hand    Rune, robinia hand    Sigrid, quire clerk"


static func ready_line() -> String:
	return "Pin who cut the apophyge, the room they cut it in, and the hour. Then submit."


static func choice_label(slot: String, value: String) -> String:
	if slot == "place":
		return place_button(value)
	return value


static func choices(slot: String) -> Array:
	var values: Array[String] = []
	match slot:
		"who":
			values = PEOPLE.duplicate()
		"place":
			values = PLACES.duplicate()
		"hour":
			values = HOURS.duplicate()
		_:
			push_error("Unknown pin: %s" % slot)
	var rows: Array = []
	for value in values:
		rows.append({"value": value, "label": choice_label(slot, value)})
	return rows
