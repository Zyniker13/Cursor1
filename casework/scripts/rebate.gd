extends RefCounted

# The rebate.
#
# The player pins three facts about the cutting: who, the room the rebate was
# cut in, and the hour. The timeline also records who scribed the line, where
# it was scribed, when that scribing was done, where the cutting was seen from,
# who turned the fence, where that turn was made, why the rebate was cut, where
# the shim was hung, when the gauge was oiled, when the mallet was wiped, and
# when the plane was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The rebate"
const FILE_CODE := "CW-26"
const BLURB := "The rebate left its peg at the joiner's wall. Name who cut the rebate, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Tansy", "Solt", "Quern"]
const PLACES: Array[String] = ["plane", "gauge", "mallet"]
const HOURS: Array[String] = ["71", "72", "73", "74", "75"]
const AIMS: Array[String] = ["take_shoulder", "spare_shoulder", "set_shoulder"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Plane chit",
		"source": "Solt, gauge hand",
		"text": "Tansy cut the rebate. Solt had scribed the line, and the shavings still stuck in the mouth.",
		"literals": [
			{
				"field": "taker",
				"value": "Tansy",
				"phrase": "Tansy cut the rebate",
			},
			{
				"field": "scribe",
				"value": "Solt",
				"phrase": "Solt had scribed the line",
			},
		],
	},
	{
		"id": "E2",
		"title": "Gauge sight",
		"source": "Gauge rail",
		"text": "Tansy cut the rebate. The cutting was seen from the gauge, above the iron rest.",
		"literals": [
			{
				"field": "taker",
				"value": "Tansy",
				"phrase": "Tansy cut the rebate",
			},
			{
				"field": "seen_from",
				"value": "gauge",
				"phrase": "The cutting was seen from the gauge",
			},
		],
	},
	{
		"id": "E3",
		"title": "Shim hook",
		"source": "Mallet peg",
		"text": "Tansy cut the rebate. With the shoulder true, the shim was hung on the mallet.",
		"literals": [
			{
				"field": "taker",
				"value": "Tansy",
				"phrase": "Tansy cut the rebate",
			},
			{
				"field": "shim_room",
				"value": "mallet",
				"phrase": "the shim was hung on the mallet",
			},
		],
	},
	{
		"id": "E4",
		"title": "Shoulder slate",
		"source": "Plane jaw",
		"text": "The rebate was cut in the plane. The shoulder still shows the line had been scribed on the mallet.",
		"literals": [
			{
				"field": "place",
				"value": "plane",
				"phrase": "The rebate was cut in the plane",
			},
			{
				"field": "scribe_room",
				"value": "mallet",
				"phrase": "the line had been scribed on the mallet",
			},
		],
	},
	{
		"id": "E5",
		"title": "Fence card",
		"source": "Quern, mallet clerk",
		"text": "The rebate was cut in the plane. Quern turned the fence in the gauge before the shoulder was offered.",
		"literals": [
			{
				"field": "place",
				"value": "plane",
				"phrase": "The rebate was cut in the plane",
			},
			{
				"field": "fence",
				"value": "Quern",
				"phrase": "Quern turned the fence",
			},
			{
				"field": "fence_room",
				"value": "gauge",
				"phrase": "turned the fence in the gauge",
			},
		],
	},
	{
		"id": "E6",
		"title": "Oil slip",
		"source": "Gauge book",
		"text": "The rebate was cut in the plane. The gauge was oiled at 71, and a dark film still sat on the stock.",
		"literals": [
			{
				"field": "place",
				"value": "plane",
				"phrase": "The rebate was cut in the plane",
			},
			{
				"field": "oil_hour",
				"value": "71",
				"phrase": "The gauge was oiled at 71",
			},
		],
	},
	{
		"id": "E7",
		"title": "Scribe leaf",
		"source": "Scribe book",
		"text": "The rebate was cut at 73. The line had been scribed at 72, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "73",
				"phrase": "The rebate was cut at 73",
			},
			{
				"field": "scribe_hour",
				"value": "72",
				"phrase": "The line had been scribed at 72",
			},
		],
	},
	{
		"id": "E8",
		"title": "Shoulder note",
		"source": "Joiner's wall",
		"text": "The rebate was cut at 73. The shoulder was opened so the mallet would take the shoulder.",
		"literals": [
			{
				"field": "hour",
				"value": "73",
				"phrase": "The rebate was cut at 73",
			},
			{
				"field": "aim",
				"value": "take_shoulder",
				"phrase": "so the mallet would take the shoulder",
			},
		],
	},
	{
		"id": "E9",
		"title": "Hang order",
		"source": "Mallet slate",
		"text": "The rebate was cut at 73. The mallet was wiped at 74, and the plane was hung at 75 once the shoulder was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "73",
				"phrase": "The rebate was cut at 73",
			},
			{
				"field": "wipe_hour",
				"value": "74",
				"phrase": "The mallet was wiped at 74",
			},
			{
				"field": "hang_hour",
				"value": "75",
				"phrase": "the plane was hung at 75",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"scribe",
		"scribe_room",
		"scribe_hour",
		"seen_from",
		"fence",
		"aim",
		"fence_room",
		"shim_room",
		"oil_hour",
		"wipe_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "scribe", "fence":
			return PEOPLE.duplicate()
		"place", "scribe_room", "seen_from", "fence_room", "shim_room":
			return PLACES.duplicate()
		"hour", "scribe_hour", "oil_hour", "wipe_hour", "hang_hour":
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
		missing.append("who cut the rebate")
	if pins["place"] == "":
		missing.append("where they cut the rebate")
	if pins["hour"] == "":
		missing.append("at which hour they cut the rebate")
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
		"Tansy":
			return "the plane hand"
		"Solt":
			return "the gauge hand"
		"Quern":
			return "the mallet clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"plane":
			return "plane"
		"gauge":
			return "gauge"
		"mallet":
			return "mallet"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"plane":
			return "Plane"
		"gauge":
			return "Gauge"
		"mallet":
			return "Mallet"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the rebate" % value
		"place":
			return "The rebate was cut in the %s" % place_label(value)
		"hour":
			return "The rebate was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the rebate" % value
		"place":
			return "the rebate was cut in the %s" % place_label(value)
		"hour":
			return "the rebate was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the rebate" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_shoulder":
			return "so the mallet would take the shoulder"
		"spare_shoulder":
			return "to spare the shoulder still waiting on the mallet"
		"set_shoulder":
			return "to set the shoulder before the plane was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the rebate in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) scribed the line on the %s at %s." % [
			model["scribe"],
			role_short(str(model["scribe"])),
			place_label(str(model["scribe_room"])),
			model["scribe_hour"],
		],
		"%s (%s) turned the fence in the %s." % [
			model["fence"],
			role_short(str(model["fence"])),
			place_label(str(model["fence_room"])),
		],
		"The shim was hung on the %s." % place_label(str(model["shim_room"])),
		"The gauge was oiled at %s." % model["oil_hour"],
		"The mallet was wiped at %s." % model["wipe_hour"],
		"The plane was hung at %s." % model["hang_hour"],
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
	return "Who cut the rebate, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the rebate in."


static func cast_line() -> String:
	return "Tansy, plane hand    Solt, gauge hand    Quern, mallet clerk"


static func ready_line() -> String:
	return "Pin who cut the rebate, the room they cut it in, and the hour. Then submit."


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
