extends RefCounted

# The cyma.
#
# The player pins three facts about the cutting: who, the room the cyma was
# cut in, and the hour. The timeline also records who marked the echinus, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the inshave, where that turn was made, why the cyma was cut, where
# the corona was hung, when the inshave was rouged, when the froe was chased, and
# when the bolection was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The cyma"
const FILE_CODE := "CW-42"
const BLURB := "The cyma left its peg at the joiner's jennet. Name who cut the cyma, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Ruth", "Amos", "Lena"]
const PLACES: Array[String] = ["bolection", "inshave", "froe"]
const HOURS: Array[String] = ["151", "152", "153", "154", "155"]
const AIMS: Array[String] = ["take_echinus", "spare_echinus", "set_echinus"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Echinus chit",
		"source": "Amos, echinus hand",
		"text": "Ruth cut the cyma. Amos had marked the echinus, and a pale emery still clung to the cyma.",
		"literals": [
			{
				"field": "taker",
				"value": "Ruth",
				"phrase": "Ruth cut the cyma",
			},
			{
				"field": "echinus",
				"value": "Amos",
				"phrase": "Amos had marked the echinus",
			},
		],
	},
	{
		"id": "E2",
		"title": "Beak sight",
		"source": "Inshave beak",
		"text": "Ruth cut the cyma. The cymaing was seen from the inshave, beside the open echinus.",
		"literals": [
			{
				"field": "taker",
				"value": "Ruth",
				"phrase": "Ruth cut the cyma",
			},
			{
				"field": "seen_from",
				"value": "inshave",
				"phrase": "The cymaing was seen from the inshave",
			},
		],
	},
	{
		"id": "E3",
		"title": "Corona bill",
		"source": "Froe nose",
		"text": "Ruth cut the cyma. With the echinus true, the corona was hung on the froe.",
		"literals": [
			{
				"field": "taker",
				"value": "Ruth",
				"phrase": "Ruth cut the cyma",
			},
			{
				"field": "corona_room",
				"value": "froe",
				"phrase": "the corona was hung on the froe",
			},
		],
	},
	{
		"id": "E4",
		"title": "Garnet slate",
		"source": "Bolection garnet",
		"text": "The cyma was cut in the bolection. A fresh garnet shows the echinus had been marked on the froe.",
		"literals": [
			{
				"field": "place",
				"value": "bolection",
				"phrase": "The cyma was cut in the bolection",
			},
			{
				"field": "echinus_room",
				"value": "froe",
				"phrase": "the echinus had been marked on the froe",
			},
		],
	},
	{
		"id": "E5",
		"title": "Inshave card",
		"source": "Lena, inshave clerk",
		"text": "The cyma was cut in the bolection. Lena turned the inshave in the bolection once the echinus was offered.",
		"literals": [
			{
				"field": "place",
				"value": "bolection",
				"phrase": "The cyma was cut in the bolection",
			},
			{
				"field": "inshave",
				"value": "Lena",
				"phrase": "Lena turned the inshave",
			},
			{
				"field": "inshave_room",
				"value": "bolection",
				"phrase": "turned the inshave in the bolection",
			},
		],
	},
	{
		"id": "E6",
		"title": "Rouge slip",
		"source": "Inshave tote",
		"text": "The cyma was cut in the bolection. The inshave was rouged at 151, and a pale tripoli still sat on the cyma.",
		"literals": [
			{
				"field": "place",
				"value": "bolection",
				"phrase": "The cyma was cut in the bolection",
			},
			{
				"field": "rouge_hour",
				"value": "151",
				"phrase": "The inshave was rouged at 151",
			},
		],
	},
	{
		"id": "E7",
		"title": "Cyma leaf",
		"source": "Echinus book",
		"text": "The cyma was cut at 153. The echinus had been marked at 152, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "153",
				"phrase": "The cyma was cut at 153",
			},
			{
				"field": "echinus_hour",
				"value": "152",
				"phrase": "The echinus had been marked at 152",
			},
		],
	},
	{
		"id": "E8",
		"title": "Jennet note",
		"source": "Joiner's jennet",
		"text": "The cyma was cut at 153. The echinus was opened so the echinus would take the cyma.",
		"literals": [
			{
				"field": "hour",
				"value": "153",
				"phrase": "The cyma was cut at 153",
			},
			{
				"field": "aim",
				"value": "take_echinus",
				"phrase": "so the echinus would take the cyma",
			},
		],
	},
	{
		"id": "E9",
		"title": "Chase order",
		"source": "Froe card",
		"text": "The cyma was cut at 153. The froe was chased at 154, and the bolection was hung at 155 once the echinus was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "153",
				"phrase": "The cyma was cut at 153",
			},
			{
				"field": "chase_hour",
				"value": "154",
				"phrase": "The froe was chased at 154",
			},
			{
				"field": "hang_hour",
				"value": "155",
				"phrase": "the bolection was hung at 155",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"echinus",
		"echinus_room",
		"echinus_hour",
		"seen_from",
		"inshave",
		"aim",
		"inshave_room",
		"corona_room",
		"rouge_hour",
		"chase_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "echinus", "inshave":
			return PEOPLE.duplicate()
		"place", "echinus_room", "seen_from", "inshave_room", "corona_room":
			return PLACES.duplicate()
		"hour", "echinus_hour", "rouge_hour", "chase_hour", "hang_hour":
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
		missing.append("who cut the cyma")
	if pins["place"] == "":
		missing.append("where they cut the cyma")
	if pins["hour"] == "":
		missing.append("at which hour they cut the cyma")
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
		"Ruth":
			return "the cyma hand"
		"Amos":
			return "the echinus hand"
		"Lena":
			return "the inshave clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"bolection":
			return "bolection"
		"inshave":
			return "inshave"
		"froe":
			return "froe"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"bolection":
			return "Bolection"
		"inshave":
			return "Inshave"
		"froe":
			return "Froe"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the cyma" % value
		"place":
			return "The cyma was cut in the %s" % place_label(value)
		"hour":
			return "The cyma was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the cyma" % value
		"place":
			return "the cyma was cut in the %s" % place_label(value)
		"hour":
			return "the cyma was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the cyma" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_echinus":
			return "so the echinus would take the cyma"
		"spare_echinus":
			return "to spare the echinus still waiting on the cyma"
		"set_echinus":
			return "to set the echinus before the bolection was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the cyma in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the echinus on the %s at %s." % [
			model["echinus"],
			role_short(str(model["echinus"])),
			place_label(str(model["echinus_room"])),
			model["echinus_hour"],
		],
		"%s (%s) turned the inshave in the %s." % [
			model["inshave"],
			role_short(str(model["inshave"])),
			place_label(str(model["inshave_room"])),
		],
		"The corona was hung on the %s." % place_label(str(model["corona_room"])),
		"The inshave was rouged at %s." % model["rouge_hour"],
		"The froe was chased at %s." % model["chase_hour"],
		"The bolection was hung at %s." % model["hang_hour"],
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
	return "Who cut the cyma, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the cyma in."


static func cast_line() -> String:
	return "Ruth, cyma hand    Amos, echinus hand    Lena, inshave clerk"


static func ready_line() -> String:
	return "Pin who cut the cyma, the room they cut it in, and the hour. Then submit."


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
