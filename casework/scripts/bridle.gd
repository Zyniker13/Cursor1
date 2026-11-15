extends RefCounted

# The bridle.
#
# The player pins three facts about the cutting: who, the room the bridle was
# cut in, and the hour. The timeline also records who marked the tongue, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the templet, where that turn was made, why the bridle was cut, where
# the spline was hung, when the scraper was stropped, when the adze was wiped, and
# when the router was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The bridle"
const FILE_CODE := "CW-29"
const BLURB := "The bridle left its peg at the joiner's stool. Name who cut the bridle, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Wend", "Sile", "Jute"]
const PLACES: Array[String] = ["router", "scraper", "adze"]
const HOURS: Array[String] = ["86", "87", "88", "89", "90"]
const AIMS: Array[String] = ["take_tongue", "spare_tongue", "set_tongue"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Router chit",
		"source": "Sile, scraper hand",
		"text": "Wend cut the bridle. Sile had marked the tongue, and the shavings still stuck in the mouth.",
		"literals": [
			{
				"field": "taker",
				"value": "Wend",
				"phrase": "Wend cut the bridle",
			},
			{
				"field": "notcher",
				"value": "Sile",
				"phrase": "Sile had marked the tongue",
			},
		],
	},
	{
		"id": "E2",
		"title": "Scraper sight",
		"source": "Scraper rail",
		"text": "Wend cut the bridle. The cutting was seen from the scraper, above the iron rest.",
		"literals": [
			{
				"field": "taker",
				"value": "Wend",
				"phrase": "Wend cut the bridle",
			},
			{
				"field": "seen_from",
				"value": "scraper",
				"phrase": "The cutting was seen from the scraper",
			},
		],
	},
	{
		"id": "E3",
		"title": "Spline hook",
		"source": "Adze peg",
		"text": "Wend cut the bridle. With the tongue true, the spline was hung on the adze.",
		"literals": [
			{
				"field": "taker",
				"value": "Wend",
				"phrase": "Wend cut the bridle",
			},
			{
				"field": "spline_room",
				"value": "adze",
				"phrase": "the spline was hung on the adze",
			},
		],
	},
	{
		"id": "E4",
		"title": "Tongue slate",
		"source": "Router jaw",
		"text": "The bridle was cut in the router. A fresh edge shows the tongue had been marked on the adze.",
		"literals": [
			{
				"field": "place",
				"value": "router",
				"phrase": "The bridle was cut in the router",
			},
			{
				"field": "notch_room",
				"value": "adze",
				"phrase": "the tongue had been marked on the adze",
			},
		],
	},
	{
		"id": "E5",
		"title": "Templet card",
		"source": "Jute, adze clerk",
		"text": "The bridle was cut in the router. Jute turned the templet in the scraper before the tongue was offered.",
		"literals": [
			{
				"field": "place",
				"value": "router",
				"phrase": "The bridle was cut in the router",
			},
			{
				"field": "templet",
				"value": "Jute",
				"phrase": "Jute turned the templet",
			},
			{
				"field": "templet_room",
				"value": "scraper",
				"phrase": "turned the templet in the scraper",
			},
		],
	},
	{
		"id": "E6",
		"title": "Strop slip",
		"source": "Scraper book",
		"text": "The bridle was cut in the router. The scraper was stropped at 86, and a pale film still sat on the cheek.",
		"literals": [
			{
				"field": "place",
				"value": "router",
				"phrase": "The bridle was cut in the router",
			},
			{
				"field": "strop_hour",
				"value": "86",
				"phrase": "The scraper was stropped at 86",
			},
		],
	},
	{
		"id": "E7",
		"title": "Notch leaf",
		"source": "Notch book",
		"text": "The bridle was cut at 88. The tongue had been marked at 87, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "88",
				"phrase": "The bridle was cut at 88",
			},
			{
				"field": "notch_hour",
				"value": "87",
				"phrase": "The tongue had been marked at 87",
			},
		],
	},
	{
		"id": "E8",
		"title": "Tongue note",
		"source": "Joiner's stool",
		"text": "The bridle was cut at 88. The tongue was opened so the adze would take the tongue.",
		"literals": [
			{
				"field": "hour",
				"value": "88",
				"phrase": "The bridle was cut at 88",
			},
			{
				"field": "aim",
				"value": "take_tongue",
				"phrase": "so the adze would take the tongue",
			},
		],
	},
	{
		"id": "E9",
		"title": "Hang order",
		"source": "Adze slate",
		"text": "The bridle was cut at 88. The adze was wiped at 89, and the router was hung at 90 once the tongue was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "88",
				"phrase": "The bridle was cut at 88",
			},
			{
				"field": "wipe_hour",
				"value": "89",
				"phrase": "The adze was wiped at 89",
			},
			{
				"field": "hang_hour",
				"value": "90",
				"phrase": "the router was hung at 90",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"notcher",
		"notch_room",
		"notch_hour",
		"seen_from",
		"templet",
		"aim",
		"templet_room",
		"spline_room",
		"strop_hour",
		"wipe_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "notcher", "templet":
			return PEOPLE.duplicate()
		"place", "notch_room", "seen_from", "templet_room", "spline_room":
			return PLACES.duplicate()
		"hour", "notch_hour", "strop_hour", "wipe_hour", "hang_hour":
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
		missing.append("who cut the bridle")
	if pins["place"] == "":
		missing.append("where they cut the bridle")
	if pins["hour"] == "":
		missing.append("at which hour they cut the bridle")
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
		"Wend":
			return "the router hand"
		"Sile":
			return "the scraper hand"
		"Jute":
			return "the adze clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"router":
			return "router"
		"scraper":
			return "scraper"
		"adze":
			return "adze"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"router":
			return "Router"
		"scraper":
			return "Scraper"
		"adze":
			return "Adze"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the bridle" % value
		"place":
			return "The bridle was cut in the %s" % place_label(value)
		"hour":
			return "The bridle was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the bridle" % value
		"place":
			return "the bridle was cut in the %s" % place_label(value)
		"hour":
			return "the bridle was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the bridle" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_tongue":
			return "so the adze would take the tongue"
		"spare_tongue":
			return "to spare the tongue still waiting on the adze"
		"set_tongue":
			return "to set the tongue before the router was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the bridle in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the tongue on the %s at %s." % [
			model["notcher"],
			role_short(str(model["notcher"])),
			place_label(str(model["notch_room"])),
			model["notch_hour"],
		],
		"%s (%s) turned the templet in the %s." % [
			model["templet"],
			role_short(str(model["templet"])),
			place_label(str(model["templet_room"])),
		],
		"The spline was hung on the %s." % place_label(str(model["spline_room"])),
		"The scraper was stropped at %s." % model["strop_hour"],
		"The adze was wiped at %s." % model["wipe_hour"],
		"The router was hung at %s." % model["hang_hour"],
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
	return "Who cut the bridle, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the bridle in."


static func cast_line() -> String:
	return "Wend, router hand    Sile, scraper hand    Jute, adze clerk"


static func ready_line() -> String:
	return "Pin who cut the bridle, the room they cut it in, and the hour. Then submit."


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
