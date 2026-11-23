extends RefCounted

# The mutule.
#
# The player pins three facts about the cutting: who, the room the mutule was
# cut in, and the hour. The timeline also records who marked the elder, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the porch, where that turn was made, why the mutule was cut, where
# the mulberry was hung, when the porch was gilded, when the reamer was scorched, and
# when the transept was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The mutule"
const FILE_CODE := "CW-52"
const BLURB := "The mutule left its peg at the joiner's barb. Name who cut the mutule, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Marta", "Freya", "Signe"]
const PLACES: Array[String] = ["transept", "porch", "reamer"]
const HOURS: Array[String] = ["201", "202", "203", "204", "205"]
const AIMS: Array[String] = ["take_elder", "spare_elder", "set_elder"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Elder chit",
		"source": "Freya, elder hand",
		"text": "Marta cut the mutule. Freya had marked the elder, and a pale turmeric still clung to the mutule.",
		"literals": [
			{
				"field": "taker",
				"value": "Marta",
				"phrase": "Marta cut the mutule",
			},
			{
				"field": "elder",
				"value": "Freya",
				"phrase": "Freya had marked the elder",
			},
		],
	},
	{
		"id": "E2",
		"title": "Fustet sight",
		"source": "Porch fustet",
		"text": "Marta cut the mutule. The mutuleing was seen from the porch, beside the open elder.",
		"literals": [
			{
				"field": "taker",
				"value": "Marta",
				"phrase": "Marta cut the mutule",
			},
			{
				"field": "seen_from",
				"value": "porch",
				"phrase": "The mutuleing was seen from the porch",
			},
		],
	},
	{
		"id": "E3",
		"title": "Mulberry bill",
		"source": "Reamer nose",
		"text": "Marta cut the mutule. With the elder true, the mulberry was hung on the reamer.",
		"literals": [
			{
				"field": "taker",
				"value": "Marta",
				"phrase": "Marta cut the mutule",
			},
			{
				"field": "mulberry_room",
				"value": "reamer",
				"phrase": "the mulberry was hung on the reamer",
			},
		],
	},
	{
		"id": "E4",
		"title": "Gamboge slate",
		"source": "Transept gamboge",
		"text": "The mutule was cut in the transept. A fresh gamboge shows the elder had been marked on the reamer.",
		"literals": [
			{
				"field": "place",
				"value": "transept",
				"phrase": "The mutule was cut in the transept",
			},
			{
				"field": "elder_room",
				"value": "reamer",
				"phrase": "the elder had been marked on the reamer",
			},
		],
	},
	{
		"id": "E5",
		"title": "Porch card",
		"source": "Signe, porch clerk",
		"text": "The mutule was cut in the transept. Signe turned the porch in the transept once the elder was offered.",
		"literals": [
			{
				"field": "place",
				"value": "transept",
				"phrase": "The mutule was cut in the transept",
			},
			{
				"field": "porch",
				"value": "Signe",
				"phrase": "Signe turned the porch",
			},
			{
				"field": "porch_room",
				"value": "transept",
				"phrase": "turned the porch in the transept",
			},
		],
	},
	{
		"id": "E6",
		"title": "Gilded slip",
		"source": "Porch tote",
		"text": "The mutule was cut in the transept. The porch was gilded at 201, and a pale orchil still sat on the mutule.",
		"literals": [
			{
				"field": "place",
				"value": "transept",
				"phrase": "The mutule was cut in the transept",
			},
			{
				"field": "gild_hour",
				"value": "201",
				"phrase": "The porch was gilded at 201",
			},
		],
	},
	{
		"id": "E7",
		"title": "Mutule leaf",
		"source": "Elder book",
		"text": "The mutule was cut at 203. The elder had been marked at 202, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "203",
				"phrase": "The mutule was cut at 203",
			},
			{
				"field": "elder_hour",
				"value": "202",
				"phrase": "The elder had been marked at 202",
			},
		],
	},
	{
		"id": "E8",
		"title": "Barb note",
		"source": "Joiner's barb",
		"text": "The mutule was cut at 203. The elder was opened so the elder would take the mutule.",
		"literals": [
			{
				"field": "hour",
				"value": "203",
				"phrase": "The mutule was cut at 203",
			},
			{
				"field": "aim",
				"value": "take_elder",
				"phrase": "so the elder would take the mutule",
			},
		],
	},
	{
		"id": "E9",
		"title": "Scorched order",
		"source": "Reamer card",
		"text": "The mutule was cut at 203. The reamer was scorched at 204, and the transept was hung at 205 once the elder was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "203",
				"phrase": "The mutule was cut at 203",
			},
			{
				"field": "scorch_hour",
				"value": "204",
				"phrase": "The reamer was scorched at 204",
			},
			{
				"field": "hang_hour",
				"value": "205",
				"phrase": "the transept was hung at 205",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"elder",
		"elder_room",
		"elder_hour",
		"seen_from",
		"porch",
		"aim",
		"porch_room",
		"mulberry_room",
		"gild_hour",
		"scorch_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "elder", "porch":
			return PEOPLE.duplicate()
		"place", "elder_room", "seen_from", "porch_room", "mulberry_room":
			return PLACES.duplicate()
		"hour", "elder_hour", "gild_hour", "scorch_hour", "hang_hour":
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
		missing.append("who cut the mutule")
	if pins["place"] == "":
		missing.append("where they cut the mutule")
	if pins["hour"] == "":
		missing.append("at which hour they cut the mutule")
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
		"Marta":
			return "the mutule hand"
		"Freya":
			return "the elder hand"
		"Signe":
			return "the porch clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"transept":
			return "transept"
		"porch":
			return "porch"
		"reamer":
			return "reamer"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"transept":
			return "Transept"
		"porch":
			return "Porch"
		"reamer":
			return "Reamer"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the mutule" % value
		"place":
			return "The mutule was cut in the %s" % place_label(value)
		"hour":
			return "The mutule was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the mutule" % value
		"place":
			return "the mutule was cut in the %s" % place_label(value)
		"hour":
			return "the mutule was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the mutule" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_elder":
			return "so the elder would take the mutule"
		"spare_elder":
			return "to spare the elder still waiting on the mutule"
		"set_elder":
			return "to set the elder before the transept was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the mutule in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the elder on the %s at %s." % [
			model["elder"],
			role_short(str(model["elder"])),
			place_label(str(model["elder_room"])),
			model["elder_hour"],
		],
		"%s (%s) turned the porch in the %s." % [
			model["porch"],
			role_short(str(model["porch"])),
			place_label(str(model["porch_room"])),
		],
		"The mulberry was hung on the %s." % place_label(str(model["mulberry_room"])),
		"The porch was gilded at %s." % model["gild_hour"],
		"The reamer was scorched at %s." % model["scorch_hour"],
		"The transept was hung at %s." % model["hang_hour"],
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
	return "Who cut the mutule, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the mutule in."


static func cast_line() -> String:
	return "Marta, mutule hand    Freya, elder hand    Signe, porch clerk"


static func ready_line() -> String:
	return "Pin who cut the mutule, the room they cut it in, and the hour. Then submit."


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
