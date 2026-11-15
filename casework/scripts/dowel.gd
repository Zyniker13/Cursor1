extends RefCounted

# The dowel.
#
# The player pins three facts about the cutting: who, the room the dowel was
# cut in, and the hour. The timeline also records who marked the bore, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the chuck, where that turn was made, why the dowel was cut, where
# the curl was hung, when the auger was waxed, when the brace was honed, and
# when the bit was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The dowel"
const FILE_CODE := "CW-37"
const BLURB := "The dowel left its peg at the joiner's foal. Name who cut the dowel, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Faye", "Kerr", "Brynn"]
const PLACES: Array[String] = ["bit", "auger", "brace"]
const HOURS: Array[String] = ["126", "127", "128", "129", "130"]
const AIMS: Array[String] = ["take_bore", "spare_bore", "set_bore"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Bore chit",
		"source": "Kerr, bore hand",
		"text": "Faye cut the dowel. Kerr had marked the bore, and a pale speck still clung to the flute.",
		"literals": [
			{
				"field": "taker",
				"value": "Faye",
				"phrase": "Faye cut the dowel",
			},
			{
				"field": "bore",
				"value": "Kerr",
				"phrase": "Kerr had marked the bore",
			},
		],
	},
	{
		"id": "E2",
		"title": "Point sight",
		"source": "Auger point",
		"text": "Faye cut the dowel. The cutting was seen from the auger, beside the open flute.",
		"literals": [
			{
				"field": "taker",
				"value": "Faye",
				"phrase": "Faye cut the dowel",
			},
			{
				"field": "seen_from",
				"value": "auger",
				"phrase": "The cutting was seen from the auger",
			},
		],
	},
	{
		"id": "E3",
		"title": "Curl bill",
		"source": "Brace nose",
		"text": "Faye cut the dowel. With the bore true, the curl was hung on the brace.",
		"literals": [
			{
				"field": "taker",
				"value": "Faye",
				"phrase": "Faye cut the dowel",
			},
			{
				"field": "curl_room",
				"value": "brace",
				"phrase": "the curl was hung on the brace",
			},
		],
	},
	{
		"id": "E4",
		"title": "Flute slate",
		"source": "Bit flute",
		"text": "The dowel was cut in the bit. A fresh flute shows the bore had been marked on the brace.",
		"literals": [
			{
				"field": "place",
				"value": "bit",
				"phrase": "The dowel was cut in the bit",
			},
			{
				"field": "bore_room",
				"value": "brace",
				"phrase": "the bore had been marked on the brace",
			},
		],
	},
	{
		"id": "E5",
		"title": "Chuck card",
		"source": "Brynn, chuck clerk",
		"text": "The dowel was cut in the bit. Brynn turned the chuck in the auger once the bore was offered.",
		"literals": [
			{
				"field": "place",
				"value": "bit",
				"phrase": "The dowel was cut in the bit",
			},
			{
				"field": "chuck",
				"value": "Brynn",
				"phrase": "Brynn turned the chuck",
			},
			{
				"field": "chuck_room",
				"value": "auger",
				"phrase": "turned the chuck in the auger",
			},
		],
	},
	{
		"id": "E6",
		"title": "Wax slip",
		"source": "Auger tote",
		"text": "The dowel was cut in the bit. The auger was waxed at 126, and a pale gloss still sat on the flute.",
		"literals": [
			{
				"field": "place",
				"value": "bit",
				"phrase": "The dowel was cut in the bit",
			},
			{
				"field": "wax_hour",
				"value": "126",
				"phrase": "The auger was waxed at 126",
			},
		],
	},
	{
		"id": "E7",
		"title": "Dowel leaf",
		"source": "Bore book",
		"text": "The dowel was cut at 128. The bore had been marked at 127, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "128",
				"phrase": "The dowel was cut at 128",
			},
			{
				"field": "bore_hour",
				"value": "127",
				"phrase": "The bore had been marked at 127",
			},
		],
	},
	{
		"id": "E8",
		"title": "Dowel note",
		"source": "Joiner's foal",
		"text": "The dowel was cut at 128. The bore was opened so the bore would take the dowel.",
		"literals": [
			{
				"field": "hour",
				"value": "128",
				"phrase": "The dowel was cut at 128",
			},
			{
				"field": "aim",
				"value": "take_bore",
				"phrase": "so the bore would take the dowel",
			},
		],
	},
	{
		"id": "E9",
		"title": "Hone order",
		"source": "Brace card",
		"text": "The dowel was cut at 128. The brace was honed at 129, and the bit was hung at 130 once the bore was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "128",
				"phrase": "The dowel was cut at 128",
			},
			{
				"field": "hone_hour",
				"value": "129",
				"phrase": "The brace was honed at 129",
			},
			{
				"field": "hang_hour",
				"value": "130",
				"phrase": "the bit was hung at 130",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"bore",
		"bore_room",
		"bore_hour",
		"seen_from",
		"chuck",
		"aim",
		"chuck_room",
		"curl_room",
		"wax_hour",
		"hone_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "bore", "chuck":
			return PEOPLE.duplicate()
		"place", "bore_room", "seen_from", "chuck_room", "curl_room":
			return PLACES.duplicate()
		"hour", "bore_hour", "wax_hour", "hone_hour", "hang_hour":
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
		missing.append("who cut the dowel")
	if pins["place"] == "":
		missing.append("where they cut the dowel")
	if pins["hour"] == "":
		missing.append("at which hour they cut the dowel")
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
		"Faye":
			return "the dowel hand"
		"Kerr":
			return "the bore hand"
		"Brynn":
			return "the chuck clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"bit":
			return "bit"
		"auger":
			return "auger"
		"brace":
			return "brace"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"bit":
			return "Bit"
		"auger":
			return "Auger"
		"brace":
			return "Brace"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the dowel" % value
		"place":
			return "The dowel was cut in the %s" % place_label(value)
		"hour":
			return "The dowel was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the dowel" % value
		"place":
			return "the dowel was cut in the %s" % place_label(value)
		"hour":
			return "the dowel was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the dowel" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_bore":
			return "so the bore would take the dowel"
		"spare_bore":
			return "to spare the bore still waiting on the dowel"
		"set_bore":
			return "to set the bore before the bit was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the dowel in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the bore on the %s at %s." % [
			model["bore"],
			role_short(str(model["bore"])),
			place_label(str(model["bore_room"])),
			model["bore_hour"],
		],
		"%s (%s) turned the chuck in the %s." % [
			model["chuck"],
			role_short(str(model["chuck"])),
			place_label(str(model["chuck_room"])),
		],
		"The curl was hung on the %s." % place_label(str(model["curl_room"])),
		"The auger was waxed at %s." % model["wax_hour"],
		"The brace was honed at %s." % model["hone_hour"],
		"The bit was hung at %s." % model["hang_hour"],
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
	return "Who cut the dowel, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the dowel in."


static func cast_line() -> String:
	return "Faye, dowel hand    Kerr, bore hand    Brynn, chuck clerk"


static func ready_line() -> String:
	return "Pin who cut the dowel, the room they cut it in, and the hour. Then submit."


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
