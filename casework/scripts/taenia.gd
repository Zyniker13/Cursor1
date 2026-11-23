extends RefCounted

# The taenia.
#
# The player pins three facts about the cutting: who, the room the taenia was
# cut in, and the hour. The timeline also records who marked the acacia, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the vestry, where that turn was made, why the taenia was cut, where
# the sorb was hung, when the vestry was smeared, when the slick was anointed, and
# when the cloister was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The taenia"
const FILE_CODE := "CW-54"
const BLURB := "The taenia left its peg at the joiner's aglet. Name who cut the taenia, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Elsie", "Stig", "Maud"]
const PLACES: Array[String] = ["cloister", "vestry", "slick"]
const HOURS: Array[String] = ["211", "212", "213", "214", "215"]
const AIMS: Array[String] = ["take_acacia", "spare_acacia", "set_acacia"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Acacia chit",
		"source": "Stig, acacia hand",
		"text": "Elsie cut the taenia. Stig had marked the acacia, and a pale orcein still clung to the taenia.",
		"literals": [
			{
				"field": "taker",
				"value": "Elsie",
				"phrase": "Elsie cut the taenia",
			},
			{
				"field": "acacia",
				"value": "Stig",
				"phrase": "Stig had marked the acacia",
			},
		],
	},
	{
		"id": "E2",
		"title": "Shikonin sight",
		"source": "Vestry shikonin",
		"text": "Elsie cut the taenia. The taeniaing was seen from the vestry, beside the open acacia.",
		"literals": [
			{
				"field": "taker",
				"value": "Elsie",
				"phrase": "Elsie cut the taenia",
			},
			{
				"field": "seen_from",
				"value": "vestry",
				"phrase": "The taeniaing was seen from the vestry",
			},
		],
	},
	{
		"id": "E3",
		"title": "Sorb bill",
		"source": "Slick nose",
		"text": "Elsie cut the taenia. With the acacia true, the sorb was hung on the slick.",
		"literals": [
			{
				"field": "taker",
				"value": "Elsie",
				"phrase": "Elsie cut the taenia",
			},
			{
				"field": "sorb_room",
				"value": "slick",
				"phrase": "the sorb was hung on the slick",
			},
		],
	},
	{
		"id": "E4",
		"title": "Alizarin slate",
		"source": "Cloister alizarin",
		"text": "The taenia was cut in the cloister. A fresh alizarin shows the acacia had been marked on the slick.",
		"literals": [
			{
				"field": "place",
				"value": "cloister",
				"phrase": "The taenia was cut in the cloister",
			},
			{
				"field": "acacia_room",
				"value": "slick",
				"phrase": "the acacia had been marked on the slick",
			},
		],
	},
	{
		"id": "E5",
		"title": "Vestry card",
		"source": "Maud, vestry clerk",
		"text": "The taenia was cut in the cloister. Maud turned the vestry in the cloister once the acacia was offered.",
		"literals": [
			{
				"field": "place",
				"value": "cloister",
				"phrase": "The taenia was cut in the cloister",
			},
			{
				"field": "vestry",
				"value": "Maud",
				"phrase": "Maud turned the vestry",
			},
			{
				"field": "vestry_room",
				"value": "cloister",
				"phrase": "turned the vestry in the cloister",
			},
		],
	},
	{
		"id": "E6",
		"title": "Smeared slip",
		"source": "Vestry tote",
		"text": "The taenia was cut in the cloister. The vestry was smeared at 211, and a pale carthamin still sat on the taenia.",
		"literals": [
			{
				"field": "place",
				"value": "cloister",
				"phrase": "The taenia was cut in the cloister",
			},
			{
				"field": "smear_hour",
				"value": "211",
				"phrase": "The vestry was smeared at 211",
			},
		],
	},
	{
		"id": "E7",
		"title": "Taenia leaf",
		"source": "Acacia book",
		"text": "The taenia was cut at 213. The acacia had been marked at 212, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "213",
				"phrase": "The taenia was cut at 213",
			},
			{
				"field": "acacia_hour",
				"value": "212",
				"phrase": "The acacia had been marked at 212",
			},
		],
	},
	{
		"id": "E8",
		"title": "Aglet note",
		"source": "Joiner's aglet",
		"text": "The taenia was cut at 213. The acacia was opened so the acacia would take the taenia.",
		"literals": [
			{
				"field": "hour",
				"value": "213",
				"phrase": "The taenia was cut at 213",
			},
			{
				"field": "aim",
				"value": "take_acacia",
				"phrase": "so the acacia would take the taenia",
			},
		],
	},
	{
		"id": "E9",
		"title": "Anointed order",
		"source": "Slick card",
		"text": "The taenia was cut at 213. The slick was anointed at 214, and the cloister was hung at 215 once the acacia was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "213",
				"phrase": "The taenia was cut at 213",
			},
			{
				"field": "anoint_hour",
				"value": "214",
				"phrase": "The slick was anointed at 214",
			},
			{
				"field": "hang_hour",
				"value": "215",
				"phrase": "the cloister was hung at 215",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"acacia",
		"acacia_room",
		"acacia_hour",
		"seen_from",
		"vestry",
		"aim",
		"vestry_room",
		"sorb_room",
		"smear_hour",
		"anoint_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "acacia", "vestry":
			return PEOPLE.duplicate()
		"place", "acacia_room", "seen_from", "vestry_room", "sorb_room":
			return PLACES.duplicate()
		"hour", "acacia_hour", "smear_hour", "anoint_hour", "hang_hour":
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
		missing.append("who cut the taenia")
	if pins["place"] == "":
		missing.append("where they cut the taenia")
	if pins["hour"] == "":
		missing.append("at which hour they cut the taenia")
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
		"Elsie":
			return "the taenia hand"
		"Stig":
			return "the acacia hand"
		"Maud":
			return "the vestry clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"cloister":
			return "cloister"
		"vestry":
			return "vestry"
		"slick":
			return "slick"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"cloister":
			return "Cloister"
		"vestry":
			return "Vestry"
		"slick":
			return "Slick"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the taenia" % value
		"place":
			return "The taenia was cut in the %s" % place_label(value)
		"hour":
			return "The taenia was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the taenia" % value
		"place":
			return "the taenia was cut in the %s" % place_label(value)
		"hour":
			return "the taenia was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the taenia" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_acacia":
			return "so the acacia would take the taenia"
		"spare_acacia":
			return "to spare the acacia still waiting on the taenia"
		"set_acacia":
			return "to set the acacia before the cloister was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the taenia in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the acacia on the %s at %s." % [
			model["acacia"],
			role_short(str(model["acacia"])),
			place_label(str(model["acacia_room"])),
			model["acacia_hour"],
		],
		"%s (%s) turned the vestry in the %s." % [
			model["vestry"],
			role_short(str(model["vestry"])),
			place_label(str(model["vestry_room"])),
		],
		"The sorb was hung on the %s." % place_label(str(model["sorb_room"])),
		"The vestry was smeared at %s." % model["smear_hour"],
		"The slick was anointed at %s." % model["anoint_hour"],
		"The cloister was hung at %s." % model["hang_hour"],
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
	return "Who cut the taenia, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the taenia in."


static func cast_line() -> String:
	return "Elsie, taenia hand    Stig, acacia hand    Maud, vestry clerk"


static func ready_line() -> String:
	return "Pin who cut the taenia, the room they cut it in, and the hour. Then submit."


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
