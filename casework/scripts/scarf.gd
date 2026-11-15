extends RefCounted

# The scarf.
#
# The player pins three facts about the cutting: who, the room the scarf was
# cut in, and the hour. The timeline also records who marked the shoulder, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the wedge, where that turn was made, why the scarf was cut, where
# the paring was hung, when the spokeshave was skimmed, when the firmer was oiled, and
# when the drawknife was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The scarf"
const FILE_CODE := "CW-34"
const BLURB := "The scarf left its peg at the joiner's mare. Name who cut the scarf, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Hob", "Nairn", "Cole"]
const PLACES: Array[String] = ["drawknife", "spokeshave", "firmer"]
const HOURS: Array[String] = ["111", "112", "113", "114", "115"]
const AIMS: Array[String] = ["take_shoulder", "spare_shoulder", "set_shoulder"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Shoulder chit",
		"source": "Nairn, shoulder hand",
		"text": "Hob cut the scarf. Nairn had marked the shoulder, and a pale shaving still clung to the blade.",
		"literals": [
			{
				"field": "taker",
				"value": "Hob",
				"phrase": "Hob cut the scarf",
			},
			{
				"field": "shoulder",
				"value": "Nairn",
				"phrase": "Nairn had marked the shoulder",
			},
		],
	},
	{
		"id": "E2",
		"title": "Sole sight",
		"source": "Spokeshave sole",
		"text": "Hob cut the scarf. The cutting was seen from the spokeshave, beside the open blade.",
		"literals": [
			{
				"field": "taker",
				"value": "Hob",
				"phrase": "Hob cut the scarf",
			},
			{
				"field": "seen_from",
				"value": "spokeshave",
				"phrase": "The cutting was seen from the spokeshave",
			},
		],
	},
	{
		"id": "E3",
		"title": "Shaving hook",
		"source": "Firmer tang",
		"text": "Hob cut the scarf. With the shoulder true, the paring was hung on the firmer.",
		"literals": [
			{
				"field": "taker",
				"value": "Hob",
				"phrase": "Hob cut the scarf",
			},
			{
				"field": "paring_room",
				"value": "firmer",
				"phrase": "the paring was hung on the firmer",
			},
		],
	},
	{
		"id": "E4",
		"title": "Edge slate",
		"source": "Drawknife edge",
		"text": "The scarf was cut in the drawknife. A fresh edge shows the shoulder had been marked on the firmer.",
		"literals": [
			{
				"field": "place",
				"value": "drawknife",
				"phrase": "The scarf was cut in the drawknife",
			},
			{
				"field": "shoulder_room",
				"value": "firmer",
				"phrase": "the shoulder had been marked on the firmer",
			},
		],
	},
	{
		"id": "E5",
		"title": "Wedge card",
		"source": "Cole, wedge clerk",
		"text": "The scarf was cut in the drawknife. Cole turned the wedge in the spokeshave before the shoulder was offered.",
		"literals": [
			{
				"field": "place",
				"value": "drawknife",
				"phrase": "The scarf was cut in the drawknife",
			},
			{
				"field": "wedge",
				"value": "Cole",
				"phrase": "Cole turned the wedge",
			},
			{
				"field": "wedge_room",
				"value": "spokeshave",
				"phrase": "turned the wedge in the spokeshave",
			},
		],
	},
	{
		"id": "E6",
		"title": "Film slip",
		"source": "Spokeshave stock",
		"text": "The scarf was cut in the drawknife. The spokeshave was skimmed at 111, and a pale film still sat on the blade.",
		"literals": [
			{
				"field": "place",
				"value": "drawknife",
				"phrase": "The scarf was cut in the drawknife",
			},
			{
				"field": "skim_hour",
				"value": "111",
				"phrase": "The spokeshave was skimmed at 111",
			},
		],
	},
	{
		"id": "E7",
		"title": "Scarf leaf",
		"source": "Shoulder book",
		"text": "The scarf was cut at 113. The shoulder had been marked at 112, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "113",
				"phrase": "The scarf was cut at 113",
			},
			{
				"field": "shoulder_hour",
				"value": "112",
				"phrase": "The shoulder had been marked at 112",
			},
		],
	},
	{
		"id": "E8",
		"title": "Scarf note",
		"source": "Joiner's mare",
		"text": "The scarf was cut at 113. The shoulder was opened so the shoulder would take the scarf.",
		"literals": [
			{
				"field": "hour",
				"value": "113",
				"phrase": "The scarf was cut at 113",
			},
			{
				"field": "aim",
				"value": "take_shoulder",
				"phrase": "so the shoulder would take the scarf",
			},
		],
	},
	{
		"id": "E9",
		"title": "Finish order",
		"source": "Firmer card",
		"text": "The scarf was cut at 113. The firmer was oiled at 114, and the drawknife was hung at 115 once the shoulder was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "113",
				"phrase": "The scarf was cut at 113",
			},
			{
				"field": "oil_hour",
				"value": "114",
				"phrase": "The firmer was oiled at 114",
			},
			{
				"field": "hang_hour",
				"value": "115",
				"phrase": "the drawknife was hung at 115",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"shoulder",
		"shoulder_room",
		"shoulder_hour",
		"seen_from",
		"wedge",
		"aim",
		"wedge_room",
		"paring_room",
		"skim_hour",
		"oil_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "shoulder", "wedge":
			return PEOPLE.duplicate()
		"place", "shoulder_room", "seen_from", "wedge_room", "paring_room":
			return PLACES.duplicate()
		"hour", "shoulder_hour", "skim_hour", "oil_hour", "hang_hour":
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
		missing.append("who cut the scarf")
	if pins["place"] == "":
		missing.append("where they cut the scarf")
	if pins["hour"] == "":
		missing.append("at which hour they cut the scarf")
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
		"Hob":
			return "the scarf hand"
		"Nairn":
			return "the shoulder hand"
		"Cole":
			return "the wedge clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"drawknife":
			return "drawknife"
		"spokeshave":
			return "spokeshave"
		"firmer":
			return "firmer"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"drawknife":
			return "Drawknife"
		"spokeshave":
			return "Spokeshave"
		"firmer":
			return "Firmer"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the scarf" % value
		"place":
			return "The scarf was cut in the %s" % place_label(value)
		"hour":
			return "The scarf was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the scarf" % value
		"place":
			return "the scarf was cut in the %s" % place_label(value)
		"hour":
			return "the scarf was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the scarf" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_shoulder":
			return "so the shoulder would take the scarf"
		"spare_shoulder":
			return "to spare the shoulder still waiting on the scarf"
		"set_shoulder":
			return "to set the shoulder before the drawknife was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the scarf in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the shoulder on the %s at %s." % [
			model["shoulder"],
			role_short(str(model["shoulder"])),
			place_label(str(model["shoulder_room"])),
			model["shoulder_hour"],
		],
		"%s (%s) turned the wedge in the %s." % [
			model["wedge"],
			role_short(str(model["wedge"])),
			place_label(str(model["wedge_room"])),
		],
		"The paring was hung on the %s." % place_label(str(model["paring_room"])),
		"The spokeshave was skimmed at %s." % model["skim_hour"],
		"The firmer was oiled at %s." % model["oil_hour"],
		"The drawknife was hung at %s." % model["hang_hour"],
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
	return "Who cut the scarf, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the scarf in."


static func cast_line() -> String:
	return "Hob, scarf hand    Nairn, shoulder hand    Cole, wedge clerk"


static func ready_line() -> String:
	return "Pin who cut the scarf, the room they cut it in, and the hour. Then submit."


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
