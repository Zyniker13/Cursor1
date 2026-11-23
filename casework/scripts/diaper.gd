extends RefCounted

# The diaper.
#
# The player pins three facts about the cutting: who, the room the diaper was
# cut in, and the hour. The timeline also records who marked the danta, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the rood, where that turn was made, why the diaper was cut, where
# the zebrawood was hung, when the rood was tacamahaced, when the uba was mannaed, and
# when the scullery was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The diaper"
const FILE_CODE := "CW-71"
const BLURB := "The diaper left its peg at the joiner's gib. Name who cut the diaper, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Margaret", "Philip", "Thomas"]
const PLACES: Array[String] = ["scullery", "rood", "uba"]
const HOURS: Array[String] = ["296", "297", "298", "299", "300"]
const AIMS: Array[String] = ["take_danta", "spare_danta", "set_danta"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Danta chit",
		"source": "Philip, danta hand",
		"text": "Margaret cut the diaper. Philip had marked the danta, and a pale cladrin still clung to the diaper.",
		"literals": [
			{
				"field": "taker",
				"value": "Margaret",
				"phrase": "Margaret cut the diaper",
			},
			{
				"field": "danta",
				"value": "Philip",
				"phrase": "Philip had marked the danta",
			},
		],
	},
	{
		"id": "E2",
		"title": "Retusin sight",
		"source": "Rood retusin",
		"text": "Margaret cut the diaper. The diapering was seen from the rood, beside the open danta.",
		"literals": [
			{
				"field": "taker",
				"value": "Margaret",
				"phrase": "Margaret cut the diaper",
			},
			{
				"field": "seen_from",
				"value": "rood",
				"phrase": "The diapering was seen from the rood",
			},
		],
	},
	{
		"id": "E3",
		"title": "Zebrawood bill",
		"source": "Uba nose",
		"text": "Margaret cut the diaper. With the danta true, the zebrawood was hung on the uba.",
		"literals": [
			{
				"field": "taker",
				"value": "Margaret",
				"phrase": "Margaret cut the diaper",
			},
			{
				"field": "zebrawood_room",
				"value": "uba",
				"phrase": "the zebrawood was hung on the uba",
			},
		],
	},
	{
		"id": "E4",
		"title": "Orobol slate",
		"source": "Scullery orobol",
		"text": "The diaper was cut in the scullery. A fresh orobol shows the danta had been marked on the uba.",
		"literals": [
			{
				"field": "place",
				"value": "scullery",
				"phrase": "The diaper was cut in the scullery",
			},
			{
				"field": "danta_room",
				"value": "uba",
				"phrase": "the danta had been marked on the uba",
			},
		],
	},
	{
		"id": "E5",
		"title": "Rood card",
		"source": "Thomas, rood clerk",
		"text": "The diaper was cut in the scullery. Thomas turned the rood in the scullery once the danta was offered.",
		"literals": [
			{
				"field": "place",
				"value": "scullery",
				"phrase": "The diaper was cut in the scullery",
			},
			{
				"field": "rood",
				"value": "Thomas",
				"phrase": "Thomas turned the rood",
			},
			{
				"field": "rood_room",
				"value": "scullery",
				"phrase": "turned the rood in the scullery",
			},
		],
	},
	{
		"id": "E6",
		"title": "Tacamahaced slip",
		"source": "Rood tote",
		"text": "The diaper was cut in the scullery. The rood was tacamahaced at 296, and a pale tectorigenin still sat on the diaper.",
		"literals": [
			{
				"field": "place",
				"value": "scullery",
				"phrase": "The diaper was cut in the scullery",
			},
			{
				"field": "tacamahac_hour",
				"value": "296",
				"phrase": "The rood was tacamahaced at 296",
			},
		],
	},
	{
		"id": "E7",
		"title": "Diaper leaf",
		"source": "Danta book",
		"text": "The diaper was cut at 298. The danta had been marked at 297, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "298",
				"phrase": "The diaper was cut at 298",
			},
			{
				"field": "danta_hour",
				"value": "297",
				"phrase": "The danta had been marked at 297",
			},
		],
	},
	{
		"id": "E8",
		"title": "Gib note",
		"source": "Joiner's gib",
		"text": "The diaper was cut at 298. The danta was opened so the danta would take the diaper.",
		"literals": [
			{
				"field": "hour",
				"value": "298",
				"phrase": "The diaper was cut at 298",
			},
			{
				"field": "aim",
				"value": "take_danta",
				"phrase": "so the danta would take the diaper",
			},
		],
	},
	{
		"id": "E9",
		"title": "Mannaed order",
		"source": "Uba card",
		"text": "The diaper was cut at 298. The uba was mannaed at 299, and the scullery was hung at 300 once the danta was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "298",
				"phrase": "The diaper was cut at 298",
			},
			{
				"field": "manna_hour",
				"value": "299",
				"phrase": "The uba was mannaed at 299",
			},
			{
				"field": "hang_hour",
				"value": "300",
				"phrase": "the scullery was hung at 300",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"danta",
		"danta_room",
		"danta_hour",
		"seen_from",
		"rood",
		"aim",
		"rood_room",
		"zebrawood_room",
		"tacamahac_hour",
		"manna_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "danta", "rood":
			return PEOPLE.duplicate()
		"place", "danta_room", "seen_from", "rood_room", "zebrawood_room":
			return PLACES.duplicate()
		"hour", "danta_hour", "tacamahac_hour", "manna_hour", "hang_hour":
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
		missing.append("who cut the diaper")
	if pins["place"] == "":
		missing.append("where they cut the diaper")
	if pins["hour"] == "":
		missing.append("at which hour they cut the diaper")
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
		"Margaret":
			return "the diaper hand"
		"Philip":
			return "the danta hand"
		"Thomas":
			return "the rood clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"scullery":
			return "scullery"
		"rood":
			return "rood"
		"uba":
			return "uba"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"scullery":
			return "Scullery"
		"rood":
			return "Rood"
		"uba":
			return "Uba"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the diaper" % value
		"place":
			return "The diaper was cut in the %s" % place_label(value)
		"hour":
			return "The diaper was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the diaper" % value
		"place":
			return "the diaper was cut in the %s" % place_label(value)
		"hour":
			return "the diaper was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the diaper" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_danta":
			return "so the danta would take the diaper"
		"spare_danta":
			return "to spare the danta still waiting on the diaper"
		"set_danta":
			return "to set the danta before the scullery was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the diaper in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the danta on the %s at %s." % [
			model["danta"],
			role_short(str(model["danta"])),
			place_label(str(model["danta_room"])),
			model["danta_hour"],
		],
		"%s (%s) turned the rood in the %s." % [
			model["rood"],
			role_short(str(model["rood"])),
			place_label(str(model["rood_room"])),
		],
		"The zebrawood was hung on the %s." % place_label(str(model["zebrawood_room"])),
		"The rood was tacamahaced at %s." % model["tacamahac_hour"],
		"The uba was mannaed at %s." % model["manna_hour"],
		"The scullery was hung at %s." % model["hang_hour"],
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
	return "Who cut the diaper, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the diaper in."


static func cast_line() -> String:
	return "Margaret, diaper hand    Philip, danta hand    Thomas, rood clerk"


static func ready_line() -> String:
	return "Pin who cut the diaper, the room they cut it in, and the hour. Then submit."


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
