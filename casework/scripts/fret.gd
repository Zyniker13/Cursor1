extends RefCounted

# The fret.
#
# The player pins three facts about the cutting: who, the room the fret was
# cut in, and the hour. The timeline also records who marked the ayous, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the loggia, where that turn was made, why the fret was cut, where
# the jelutong was hung, when the loggia was guaiaced, when the kugihiki was balsamed, and
# when the attic was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The fret"
const FILE_CODE := "CW-68"
const BLURB := "The fret left its peg at the joiner's treenail. Name who cut the fret, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Henry", "Eleanor", "Richard"]
const PLACES: Array[String] = ["attic", "loggia", "kugihiki"]
const HOURS: Array[String] = ["281", "282", "283", "284", "285"]
const AIMS: Array[String] = ["take_ayous", "spare_ayous", "set_ayous"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Ayous chit",
		"source": "Eleanor, ayous hand",
		"text": "Henry cut the fret. Eleanor had marked the ayous, and a pale oroxylin still clung to the fret.",
		"literals": [
			{
				"field": "taker",
				"value": "Henry",
				"phrase": "Henry cut the fret",
			},
			{
				"field": "ayous",
				"value": "Eleanor",
				"phrase": "Eleanor had marked the ayous",
			},
		],
	},
	{
		"id": "E2",
		"title": "Biochanin sight",
		"source": "Loggia biochanin",
		"text": "Henry cut the fret. The fretting was seen from the loggia, beside the open ayous.",
		"literals": [
			{
				"field": "taker",
				"value": "Henry",
				"phrase": "Henry cut the fret",
			},
			{
				"field": "seen_from",
				"value": "loggia",
				"phrase": "The fretting was seen from the loggia",
			},
		],
	},
	{
		"id": "E3",
		"title": "Jelutong bill",
		"source": "Kugihiki nose",
		"text": "Henry cut the fret. With the ayous true, the jelutong was hung on the kugihiki.",
		"literals": [
			{
				"field": "taker",
				"value": "Henry",
				"phrase": "Henry cut the fret",
			},
			{
				"field": "jelutong_room",
				"value": "kugihiki",
				"phrase": "the jelutong was hung on the kugihiki",
			},
		],
	},
	{
		"id": "E4",
		"title": "Daidzein slate",
		"source": "Attic daidzein",
		"text": "The fret was cut in the attic. A fresh daidzein shows the ayous had been marked on the kugihiki.",
		"literals": [
			{
				"field": "place",
				"value": "attic",
				"phrase": "The fret was cut in the attic",
			},
			{
				"field": "ayous_room",
				"value": "kugihiki",
				"phrase": "the ayous had been marked on the kugihiki",
			},
		],
	},
	{
		"id": "E5",
		"title": "Loggia card",
		"source": "Richard, loggia clerk",
		"text": "The fret was cut in the attic. Richard turned the loggia in the attic once the ayous was offered.",
		"literals": [
			{
				"field": "place",
				"value": "attic",
				"phrase": "The fret was cut in the attic",
			},
			{
				"field": "loggia",
				"value": "Richard",
				"phrase": "Richard turned the loggia",
			},
			{
				"field": "loggia_room",
				"value": "attic",
				"phrase": "turned the loggia in the attic",
			},
		],
	},
	{
		"id": "E6",
		"title": "Guaiaced slip",
		"source": "Loggia tote",
		"text": "The fret was cut in the attic. The loggia was guaiaced at 281, and a pale formononetin still sat on the fret.",
		"literals": [
			{
				"field": "place",
				"value": "attic",
				"phrase": "The fret was cut in the attic",
			},
			{
				"field": "guaiac_hour",
				"value": "281",
				"phrase": "The loggia was guaiaced at 281",
			},
		],
	},
	{
		"id": "E7",
		"title": "Fret leaf",
		"source": "Ayous book",
		"text": "The fret was cut at 283. The ayous had been marked at 282, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "283",
				"phrase": "The fret was cut at 283",
			},
			{
				"field": "ayous_hour",
				"value": "282",
				"phrase": "The ayous had been marked at 282",
			},
		],
	},
	{
		"id": "E8",
		"title": "Treenail note",
		"source": "Joiner's treenail",
		"text": "The fret was cut at 283. The ayous was opened so the ayous would take the fret.",
		"literals": [
			{
				"field": "hour",
				"value": "283",
				"phrase": "The fret was cut at 283",
			},
			{
				"field": "aim",
				"value": "take_ayous",
				"phrase": "so the ayous would take the fret",
			},
		],
	},
	{
		"id": "E9",
		"title": "Balsamed order",
		"source": "Kugihiki card",
		"text": "The fret was cut at 283. The kugihiki was balsamed at 284, and the attic was hung at 285 once the ayous was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "283",
				"phrase": "The fret was cut at 283",
			},
			{
				"field": "balsam_hour",
				"value": "284",
				"phrase": "The kugihiki was balsamed at 284",
			},
			{
				"field": "hang_hour",
				"value": "285",
				"phrase": "the attic was hung at 285",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"ayous",
		"ayous_room",
		"ayous_hour",
		"seen_from",
		"loggia",
		"aim",
		"loggia_room",
		"jelutong_room",
		"guaiac_hour",
		"balsam_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "ayous", "loggia":
			return PEOPLE.duplicate()
		"place", "ayous_room", "seen_from", "loggia_room", "jelutong_room":
			return PLACES.duplicate()
		"hour", "ayous_hour", "guaiac_hour", "balsam_hour", "hang_hour":
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
		missing.append("who cut the fret")
	if pins["place"] == "":
		missing.append("where they cut the fret")
	if pins["hour"] == "":
		missing.append("at which hour they cut the fret")
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
		"Henry":
			return "the fret hand"
		"Eleanor":
			return "the ayous hand"
		"Richard":
			return "the loggia clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"attic":
			return "attic"
		"loggia":
			return "loggia"
		"kugihiki":
			return "kugihiki"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"attic":
			return "Attic"
		"loggia":
			return "Loggia"
		"kugihiki":
			return "Kugihiki"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the fret" % value
		"place":
			return "The fret was cut in the %s" % place_label(value)
		"hour":
			return "The fret was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the fret" % value
		"place":
			return "the fret was cut in the %s" % place_label(value)
		"hour":
			return "the fret was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the fret" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_ayous":
			return "so the ayous would take the fret"
		"spare_ayous":
			return "to spare the ayous still waiting on the fret"
		"set_ayous":
			return "to set the ayous before the attic was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the fret in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the ayous on the %s at %s." % [
			model["ayous"],
			role_short(str(model["ayous"])),
			place_label(str(model["ayous_room"])),
			model["ayous_hour"],
		],
		"%s (%s) turned the loggia in the %s." % [
			model["loggia"],
			role_short(str(model["loggia"])),
			place_label(str(model["loggia_room"])),
		],
		"The jelutong was hung on the %s." % place_label(str(model["jelutong_room"])),
		"The loggia was guaiaced at %s." % model["guaiac_hour"],
		"The kugihiki was balsamed at %s." % model["balsam_hour"],
		"The attic was hung at %s." % model["hang_hour"],
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
	return "Who cut the fret, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the fret in."


static func cast_line() -> String:
	return "Henry, fret hand    Eleanor, ayous hand    Richard, loggia clerk"


static func ready_line() -> String:
	return "Pin who cut the fret, the room they cut it in, and the hour. Then submit."


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
