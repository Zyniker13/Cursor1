extends RefCounted

# The talon.
#
# The player pins three facts about the cutting: who, the room the talon was
# cut in, and the hour. The timeline also records who marked the persimmon, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the scriptorium, where that turn was made, why the talon was cut, where
# the catalpa was hung, when the scriptorium was asphalted, when the onglette was benzoined, and
# when the undercroft was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The talon"
const FILE_CODE := "CW-57"
const BLURB := "The talon left its peg at the joiner's gudgeon. Name who cut the talon, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Selwyn", "Osbert", "Mildred"]
const PLACES: Array[String] = ["undercroft", "scriptorium", "onglette"]
const HOURS: Array[String] = ["226", "227", "228", "229", "230"]
const AIMS: Array[String] = ["take_persimmon", "spare_persimmon", "set_persimmon"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Persimmon chit",
		"source": "Osbert, persimmon hand",
		"text": "Selwyn cut the talon. Osbert had marked the persimmon, and a pale kaempferol still clung to the talon.",
		"literals": [
			{
				"field": "taker",
				"value": "Selwyn",
				"phrase": "Selwyn cut the talon",
			},
			{
				"field": "persimmon",
				"value": "Osbert",
				"phrase": "Osbert had marked the persimmon",
			},
		],
	},
	{
		"id": "E2",
		"title": "Galangin sight",
		"source": "Scriptorium galangin",
		"text": "Selwyn cut the talon. The taloning was seen from the scriptorium, beside the open persimmon.",
		"literals": [
			{
				"field": "taker",
				"value": "Selwyn",
				"phrase": "Selwyn cut the talon",
			},
			{
				"field": "seen_from",
				"value": "scriptorium",
				"phrase": "The taloning was seen from the scriptorium",
			},
		],
	},
	{
		"id": "E3",
		"title": "Catalpa bill",
		"source": "Onglette nose",
		"text": "Selwyn cut the talon. With the persimmon true, the catalpa was hung on the onglette.",
		"literals": [
			{
				"field": "taker",
				"value": "Selwyn",
				"phrase": "Selwyn cut the talon",
			},
			{
				"field": "catalpa_room",
				"value": "onglette",
				"phrase": "the catalpa was hung on the onglette",
			},
		],
	},
	{
		"id": "E4",
		"title": "Apigenin slate",
		"source": "Undercroft apigenin",
		"text": "The talon was cut in the undercroft. A fresh apigenin shows the persimmon had been marked on the onglette.",
		"literals": [
			{
				"field": "place",
				"value": "undercroft",
				"phrase": "The talon was cut in the undercroft",
			},
			{
				"field": "persimmon_room",
				"value": "onglette",
				"phrase": "the persimmon had been marked on the onglette",
			},
		],
	},
	{
		"id": "E5",
		"title": "Scriptorium card",
		"source": "Mildred, scriptorium clerk",
		"text": "The talon was cut in the undercroft. Mildred turned the scriptorium in the undercroft once the persimmon was offered.",
		"literals": [
			{
				"field": "place",
				"value": "undercroft",
				"phrase": "The talon was cut in the undercroft",
			},
			{
				"field": "scriptorium",
				"value": "Mildred",
				"phrase": "Mildred turned the scriptorium",
			},
			{
				"field": "scriptorium_room",
				"value": "undercroft",
				"phrase": "turned the scriptorium in the undercroft",
			},
		],
	},
	{
		"id": "E6",
		"title": "Asphalted slip",
		"source": "Scriptorium tote",
		"text": "The talon was cut in the undercroft. The scriptorium was asphalted at 226, and a pale chrysin still sat on the talon.",
		"literals": [
			{
				"field": "place",
				"value": "undercroft",
				"phrase": "The talon was cut in the undercroft",
			},
			{
				"field": "asphalt_hour",
				"value": "226",
				"phrase": "The scriptorium was asphalted at 226",
			},
		],
	},
	{
		"id": "E7",
		"title": "Talon leaf",
		"source": "Persimmon book",
		"text": "The talon was cut at 228. The persimmon had been marked at 227, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "228",
				"phrase": "The talon was cut at 228",
			},
			{
				"field": "persimmon_hour",
				"value": "227",
				"phrase": "The persimmon had been marked at 227",
			},
		],
	},
	{
		"id": "E8",
		"title": "Gudgeon note",
		"source": "Joiner's gudgeon",
		"text": "The talon was cut at 228. The persimmon was opened so the persimmon would take the talon.",
		"literals": [
			{
				"field": "hour",
				"value": "228",
				"phrase": "The talon was cut at 228",
			},
			{
				"field": "aim",
				"value": "take_persimmon",
				"phrase": "so the persimmon would take the talon",
			},
		],
	},
	{
		"id": "E9",
		"title": "Benzoined order",
		"source": "Onglette card",
		"text": "The talon was cut at 228. The onglette was benzoined at 229, and the undercroft was hung at 230 once the persimmon was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "228",
				"phrase": "The talon was cut at 228",
			},
			{
				"field": "benzoin_hour",
				"value": "229",
				"phrase": "The onglette was benzoined at 229",
			},
			{
				"field": "hang_hour",
				"value": "230",
				"phrase": "the undercroft was hung at 230",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"persimmon",
		"persimmon_room",
		"persimmon_hour",
		"seen_from",
		"scriptorium",
		"aim",
		"scriptorium_room",
		"catalpa_room",
		"asphalt_hour",
		"benzoin_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "persimmon", "scriptorium":
			return PEOPLE.duplicate()
		"place", "persimmon_room", "seen_from", "scriptorium_room", "catalpa_room":
			return PLACES.duplicate()
		"hour", "persimmon_hour", "asphalt_hour", "benzoin_hour", "hang_hour":
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
		missing.append("who cut the talon")
	if pins["place"] == "":
		missing.append("where they cut the talon")
	if pins["hour"] == "":
		missing.append("at which hour they cut the talon")
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
		"Selwyn":
			return "the talon hand"
		"Osbert":
			return "the persimmon hand"
		"Mildred":
			return "the scriptorium clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"undercroft":
			return "undercroft"
		"scriptorium":
			return "scriptorium"
		"onglette":
			return "onglette"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"undercroft":
			return "Undercroft"
		"scriptorium":
			return "Scriptorium"
		"onglette":
			return "Onglette"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the talon" % value
		"place":
			return "The talon was cut in the %s" % place_label(value)
		"hour":
			return "The talon was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the talon" % value
		"place":
			return "the talon was cut in the %s" % place_label(value)
		"hour":
			return "the talon was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the talon" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_persimmon":
			return "so the persimmon would take the talon"
		"spare_persimmon":
			return "to spare the persimmon still waiting on the talon"
		"set_persimmon":
			return "to set the persimmon before the undercroft was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the talon in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the persimmon on the %s at %s." % [
			model["persimmon"],
			role_short(str(model["persimmon"])),
			place_label(str(model["persimmon_room"])),
			model["persimmon_hour"],
		],
		"%s (%s) turned the scriptorium in the %s." % [
			model["scriptorium"],
			role_short(str(model["scriptorium"])),
			place_label(str(model["scriptorium_room"])),
		],
		"The catalpa was hung on the %s." % place_label(str(model["catalpa_room"])),
		"The scriptorium was asphalted at %s." % model["asphalt_hour"],
		"The onglette was benzoined at %s." % model["benzoin_hour"],
		"The undercroft was hung at %s." % model["hang_hour"],
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
	return "Who cut the talon, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the talon in."


static func cast_line() -> String:
	return "Selwyn, talon hand    Osbert, persimmon hand    Mildred, scriptorium clerk"


static func ready_line() -> String:
	return "Pin who cut the talon, the room they cut it in, and the hour. Then submit."


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
