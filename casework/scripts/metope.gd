extends RefCounted

# The metope.
#
# The player pins three facts about the cutting: who, the room the metope was
# cut in, and the hour. The timeline also records who marked the pecan, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the presbytery, where that turn was made, why the metope was cut, where
# the butternut was hung, when the presbytery was toasted, when the tinttool was soldered, and
# when the clerestory was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The metope"
const FILE_CODE := "CW-59"
const BLURB := "The metope left its peg at the joiner's thole. Name who cut the metope, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Aelfric", "Leofwine", "Eadgyth"]
const PLACES: Array[String] = ["clerestory", "presbytery", "tinttool"]
const HOURS: Array[String] = ["236", "237", "238", "239", "240"]
const AIMS: Array[String] = ["take_pecan", "spare_pecan", "set_pecan"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Pecan chit",
		"source": "Leofwine, pecan hand",
		"text": "Aelfric cut the metope. Leofwine had marked the pecan, and a pale gyrophoric still clung to the metope.",
		"literals": [
			{
				"field": "taker",
				"value": "Aelfric",
				"phrase": "Aelfric cut the metope",
			},
			{
				"field": "pecan",
				"value": "Leofwine",
				"phrase": "Leofwine had marked the pecan",
			},
		],
	},
	{
		"id": "E2",
		"title": "Zeaxanthin sight",
		"source": "Presbytery zeaxanthin",
		"text": "Aelfric cut the metope. The metopeing was seen from the presbytery, beside the open pecan.",
		"literals": [
			{
				"field": "taker",
				"value": "Aelfric",
				"phrase": "Aelfric cut the metope",
			},
			{
				"field": "seen_from",
				"value": "presbytery",
				"phrase": "The metopeing was seen from the presbytery",
			},
		],
	},
	{
		"id": "E3",
		"title": "Butternut bill",
		"source": "Tinttool nose",
		"text": "Aelfric cut the metope. With the pecan true, the butternut was hung on the tinttool.",
		"literals": [
			{
				"field": "taker",
				"value": "Aelfric",
				"phrase": "Aelfric cut the metope",
			},
			{
				"field": "butternut_room",
				"value": "tinttool",
				"phrase": "the butternut was hung on the tinttool",
			},
		],
	},
	{
		"id": "E4",
		"title": "Myricetin slate",
		"source": "Clerestory myricetin",
		"text": "The metope was cut in the clerestory. A fresh myricetin shows the pecan had been marked on the tinttool.",
		"literals": [
			{
				"field": "place",
				"value": "clerestory",
				"phrase": "The metope was cut in the clerestory",
			},
			{
				"field": "pecan_room",
				"value": "tinttool",
				"phrase": "the pecan had been marked on the tinttool",
			},
		],
	},
	{
		"id": "E5",
		"title": "Presbytery card",
		"source": "Eadgyth, presbytery clerk",
		"text": "The metope was cut in the clerestory. Eadgyth turned the presbytery in the clerestory once the pecan was offered.",
		"literals": [
			{
				"field": "place",
				"value": "clerestory",
				"phrase": "The metope was cut in the clerestory",
			},
			{
				"field": "presbytery",
				"value": "Eadgyth",
				"phrase": "Eadgyth turned the presbytery",
			},
			{
				"field": "presbytery_room",
				"value": "clerestory",
				"phrase": "turned the presbytery in the clerestory",
			},
		],
	},
	{
		"id": "E6",
		"title": "Toasted slip",
		"source": "Presbytery tote",
		"text": "The metope was cut in the clerestory. The presbytery was toasted at 236, and a pale orsellinic still sat on the metope.",
		"literals": [
			{
				"field": "place",
				"value": "clerestory",
				"phrase": "The metope was cut in the clerestory",
			},
			{
				"field": "toast_hour",
				"value": "236",
				"phrase": "The presbytery was toasted at 236",
			},
		],
	},
	{
		"id": "E7",
		"title": "Metope leaf",
		"source": "Pecan book",
		"text": "The metope was cut at 238. The pecan had been marked at 237, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "238",
				"phrase": "The metope was cut at 238",
			},
			{
				"field": "pecan_hour",
				"value": "237",
				"phrase": "The pecan had been marked at 237",
			},
		],
	},
	{
		"id": "E8",
		"title": "Thole note",
		"source": "Joiner's thole",
		"text": "The metope was cut at 238. The pecan was opened so the pecan would take the metope.",
		"literals": [
			{
				"field": "hour",
				"value": "238",
				"phrase": "The metope was cut at 238",
			},
			{
				"field": "aim",
				"value": "take_pecan",
				"phrase": "so the pecan would take the metope",
			},
		],
	},
	{
		"id": "E9",
		"title": "Soldered order",
		"source": "Tinttool card",
		"text": "The metope was cut at 238. The tinttool was soldered at 239, and the clerestory was hung at 240 once the pecan was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "238",
				"phrase": "The metope was cut at 238",
			},
			{
				"field": "solder_hour",
				"value": "239",
				"phrase": "The tinttool was soldered at 239",
			},
			{
				"field": "hang_hour",
				"value": "240",
				"phrase": "the clerestory was hung at 240",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"pecan",
		"pecan_room",
		"pecan_hour",
		"seen_from",
		"presbytery",
		"aim",
		"presbytery_room",
		"butternut_room",
		"toast_hour",
		"solder_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "pecan", "presbytery":
			return PEOPLE.duplicate()
		"place", "pecan_room", "seen_from", "presbytery_room", "butternut_room":
			return PLACES.duplicate()
		"hour", "pecan_hour", "toast_hour", "solder_hour", "hang_hour":
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
		missing.append("who cut the metope")
	if pins["place"] == "":
		missing.append("where they cut the metope")
	if pins["hour"] == "":
		missing.append("at which hour they cut the metope")
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
		"Aelfric":
			return "the metope hand"
		"Leofwine":
			return "the pecan hand"
		"Eadgyth":
			return "the presbytery clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"clerestory":
			return "clerestory"
		"presbytery":
			return "presbytery"
		"tinttool":
			return "tinttool"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"clerestory":
			return "Clerestory"
		"presbytery":
			return "Presbytery"
		"tinttool":
			return "Tinttool"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the metope" % value
		"place":
			return "The metope was cut in the %s" % place_label(value)
		"hour":
			return "The metope was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the metope" % value
		"place":
			return "the metope was cut in the %s" % place_label(value)
		"hour":
			return "the metope was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the metope" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_pecan":
			return "so the pecan would take the metope"
		"spare_pecan":
			return "to spare the pecan still waiting on the metope"
		"set_pecan":
			return "to set the pecan before the clerestory was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the metope in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the pecan on the %s at %s." % [
			model["pecan"],
			role_short(str(model["pecan"])),
			place_label(str(model["pecan_room"])),
			model["pecan_hour"],
		],
		"%s (%s) turned the presbytery in the %s." % [
			model["presbytery"],
			role_short(str(model["presbytery"])),
			place_label(str(model["presbytery_room"])),
		],
		"The butternut was hung on the %s." % place_label(str(model["butternut_room"])),
		"The presbytery was toasted at %s." % model["toast_hour"],
		"The tinttool was soldered at %s." % model["solder_hour"],
		"The clerestory was hung at %s." % model["hang_hour"],
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
	return "Who cut the metope, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the metope in."


static func cast_line() -> String:
	return "Aelfric, metope hand    Leofwine, pecan hand    Eadgyth, presbytery clerk"


static func ready_line() -> String:
	return "Pin who cut the metope, the room they cut it in, and the hour. Then submit."


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
