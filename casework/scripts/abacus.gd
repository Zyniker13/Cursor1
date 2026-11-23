extends RefCounted

# The abacus.
#
# The player pins three facts about the cutting: who, the room the abacus was
# cut in, and the hour. The timeline also records who marked the medlar, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the holdfast, where that turn was made, why the abacus was cut, where
# the juniper was hung, when the holdfast was glued, when the hatchet was graphited, and
# when the socle was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The abacus"
const FILE_CODE := "CW-48"
const BLURB := "The abacus left its peg at the joiner's nag. Name who cut the abacus, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Una", "Hart", "Pearl"]
const PLACES: Array[String] = ["socle", "holdfast", "hatchet"]
const HOURS: Array[String] = ["181", "182", "183", "184", "185"]
const AIMS: Array[String] = ["take_medlar", "spare_medlar", "set_medlar"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Medlar chit",
		"source": "Hart, medlar hand",
		"text": "Una cut the abacus. Hart had marked the medlar, and a pale madder still clung to the abacus.",
		"literals": [
			{
				"field": "taker",
				"value": "Una",
				"phrase": "Una cut the abacus",
			},
			{
				"field": "medlar",
				"value": "Hart",
				"phrase": "Hart had marked the medlar",
			},
		],
	},
	{
		"id": "E2",
		"title": "Saffron sight",
		"source": "Holdfast saffron",
		"text": "Una cut the abacus. The abacusing was seen from the holdfast, beside the open medlar.",
		"literals": [
			{
				"field": "taker",
				"value": "Una",
				"phrase": "Una cut the abacus",
			},
			{
				"field": "seen_from",
				"value": "holdfast",
				"phrase": "The abacusing was seen from the holdfast",
			},
		],
	},
	{
		"id": "E3",
		"title": "Juniper bill",
		"source": "Hatchet nose",
		"text": "Una cut the abacus. With the medlar true, the juniper was hung on the hatchet.",
		"literals": [
			{
				"field": "taker",
				"value": "Una",
				"phrase": "Una cut the abacus",
			},
			{
				"field": "juniper_room",
				"value": "hatchet",
				"phrase": "the juniper was hung on the hatchet",
			},
		],
	},
	{
		"id": "E4",
		"title": "Weld slate",
		"source": "Socle weld",
		"text": "The abacus was cut in the socle. A fresh weld shows the medlar had been marked on the hatchet.",
		"literals": [
			{
				"field": "place",
				"value": "socle",
				"phrase": "The abacus was cut in the socle",
			},
			{
				"field": "medlar_room",
				"value": "hatchet",
				"phrase": "the medlar had been marked on the hatchet",
			},
		],
	},
	{
		"id": "E5",
		"title": "Holdfast card",
		"source": "Pearl, holdfast clerk",
		"text": "The abacus was cut in the socle. Pearl turned the holdfast in the socle once the medlar was offered.",
		"literals": [
			{
				"field": "place",
				"value": "socle",
				"phrase": "The abacus was cut in the socle",
			},
			{
				"field": "holdfast",
				"value": "Pearl",
				"phrase": "Pearl turned the holdfast",
			},
			{
				"field": "holdfast_room",
				"value": "socle",
				"phrase": "turned the holdfast in the socle",
			},
		],
	},
	{
		"id": "E6",
		"title": "Glue slip",
		"source": "Holdfast tote",
		"text": "The abacus was cut in the socle. The holdfast was glued at 181, and a pale woad still sat on the abacus.",
		"literals": [
			{
				"field": "place",
				"value": "socle",
				"phrase": "The abacus was cut in the socle",
			},
			{
				"field": "glue_hour",
				"value": "181",
				"phrase": "The holdfast was glued at 181",
			},
		],
	},
	{
		"id": "E7",
		"title": "Abacus leaf",
		"source": "Medlar book",
		"text": "The abacus was cut at 183. The medlar had been marked at 182, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "183",
				"phrase": "The abacus was cut at 183",
			},
			{
				"field": "medlar_hour",
				"value": "182",
				"phrase": "The medlar had been marked at 182",
			},
		],
	},
	{
		"id": "E8",
		"title": "Nag note",
		"source": "Joiner's nag",
		"text": "The abacus was cut at 183. The medlar was opened so the medlar would take the abacus.",
		"literals": [
			{
				"field": "hour",
				"value": "183",
				"phrase": "The abacus was cut at 183",
			},
			{
				"field": "aim",
				"value": "take_medlar",
				"phrase": "so the medlar would take the abacus",
			},
		],
	},
	{
		"id": "E9",
		"title": "Graphite order",
		"source": "Hatchet card",
		"text": "The abacus was cut at 183. The hatchet was graphited at 184, and the socle was hung at 185 once the medlar was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "183",
				"phrase": "The abacus was cut at 183",
			},
			{
				"field": "graphite_hour",
				"value": "184",
				"phrase": "The hatchet was graphited at 184",
			},
			{
				"field": "hang_hour",
				"value": "185",
				"phrase": "the socle was hung at 185",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"medlar",
		"medlar_room",
		"medlar_hour",
		"seen_from",
		"holdfast",
		"aim",
		"holdfast_room",
		"juniper_room",
		"glue_hour",
		"graphite_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "medlar", "holdfast":
			return PEOPLE.duplicate()
		"place", "medlar_room", "seen_from", "holdfast_room", "juniper_room":
			return PLACES.duplicate()
		"hour", "medlar_hour", "glue_hour", "graphite_hour", "hang_hour":
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
		missing.append("who cut the abacus")
	if pins["place"] == "":
		missing.append("where they cut the abacus")
	if pins["hour"] == "":
		missing.append("at which hour they cut the abacus")
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
		"Una":
			return "the abacus hand"
		"Hart":
			return "the medlar hand"
		"Pearl":
			return "the holdfast clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"socle":
			return "socle"
		"holdfast":
			return "holdfast"
		"hatchet":
			return "hatchet"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"socle":
			return "Socle"
		"holdfast":
			return "Holdfast"
		"hatchet":
			return "Hatchet"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the abacus" % value
		"place":
			return "The abacus was cut in the %s" % place_label(value)
		"hour":
			return "The abacus was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the abacus" % value
		"place":
			return "the abacus was cut in the %s" % place_label(value)
		"hour":
			return "the abacus was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the abacus" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_medlar":
			return "so the medlar would take the abacus"
		"spare_medlar":
			return "to spare the medlar still waiting on the abacus"
		"set_medlar":
			return "to set the medlar before the socle was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the abacus in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the medlar on the %s at %s." % [
			model["medlar"],
			role_short(str(model["medlar"])),
			place_label(str(model["medlar_room"])),
			model["medlar_hour"],
		],
		"%s (%s) turned the holdfast in the %s." % [
			model["holdfast"],
			role_short(str(model["holdfast"])),
			place_label(str(model["holdfast_room"])),
		],
		"The juniper was hung on the %s." % place_label(str(model["juniper_room"])),
		"The holdfast was glued at %s." % model["glue_hour"],
		"The hatchet was graphited at %s." % model["graphite_hour"],
		"The socle was hung at %s." % model["hang_hour"],
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
	return "Who cut the abacus, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the abacus in."


static func cast_line() -> String:
	return "Una, abacus hand    Hart, medlar hand    Pearl, holdfast clerk"


static func ready_line() -> String:
	return "Pin who cut the abacus, the room they cut it in, and the hour. Then submit."


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
