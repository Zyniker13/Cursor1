extends RefCounted

# The dado.
#
# The player pins three facts about the cutting: who, the room the dado was
# cut in, and the hour. The timeline also records who marked the groove, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the spur, where that turn was made, why the dado was cut, where
# the cleat was hung, when the float was whetted, when the gimlet was wiped, and
# when the plough was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The dado"
const FILE_CODE := "CW-30"
const BLURB := "The dado left its peg at the joiner's chest. Name who cut the dado, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Kern", "Phel", "Tarn"]
const PLACES: Array[String] = ["plough", "float", "gimlet"]
const HOURS: Array[String] = ["91", "92", "93", "94", "95"]
const AIMS: Array[String] = ["take_groove", "spare_groove", "set_groove"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Plough chit",
		"source": "Phel, float hand",
		"text": "Kern cut the dado. Phel had marked the groove, and the shavings still stuck in the mouth.",
		"literals": [
			{
				"field": "taker",
				"value": "Kern",
				"phrase": "Kern cut the dado",
			},
			{
				"field": "scorer",
				"value": "Phel",
				"phrase": "Phel had marked the groove",
			},
		],
	},
	{
		"id": "E2",
		"title": "Float sight",
		"source": "Float rail",
		"text": "Kern cut the dado. The cutting was seen from the float, above the iron rest.",
		"literals": [
			{
				"field": "taker",
				"value": "Kern",
				"phrase": "Kern cut the dado",
			},
			{
				"field": "seen_from",
				"value": "float",
				"phrase": "The cutting was seen from the float",
			},
		],
	},
	{
		"id": "E3",
		"title": "Cleat hook",
		"source": "Gimlet peg",
		"text": "Kern cut the dado. With the groove true, the cleat was hung on the gimlet.",
		"literals": [
			{
				"field": "taker",
				"value": "Kern",
				"phrase": "Kern cut the dado",
			},
			{
				"field": "cleat_room",
				"value": "gimlet",
				"phrase": "the cleat was hung on the gimlet",
			},
		],
	},
	{
		"id": "E4",
		"title": "Groove slate",
		"source": "Plough jaw",
		"text": "The dado was cut in the plough. A fresh edge shows the groove had been marked on the gimlet.",
		"literals": [
			{
				"field": "place",
				"value": "plough",
				"phrase": "The dado was cut in the plough",
			},
			{
				"field": "score_room",
				"value": "gimlet",
				"phrase": "the groove had been marked on the gimlet",
			},
		],
	},
	{
		"id": "E5",
		"title": "Spur card",
		"source": "Tarn, gimlet clerk",
		"text": "The dado was cut in the plough. Tarn turned the spur in the float before the groove was offered.",
		"literals": [
			{
				"field": "place",
				"value": "plough",
				"phrase": "The dado was cut in the plough",
			},
			{
				"field": "spur",
				"value": "Tarn",
				"phrase": "Tarn turned the spur",
			},
			{
				"field": "spur_room",
				"value": "float",
				"phrase": "turned the spur in the float",
			},
		],
	},
	{
		"id": "E6",
		"title": "Whet slip",
		"source": "Float book",
		"text": "The dado was cut in the plough. The float was whetted at 91, and a pale film still sat on the cheek.",
		"literals": [
			{
				"field": "place",
				"value": "plough",
				"phrase": "The dado was cut in the plough",
			},
			{
				"field": "whet_hour",
				"value": "91",
				"phrase": "The float was whetted at 91",
			},
		],
	},
	{
		"id": "E7",
		"title": "Score leaf",
		"source": "Score book",
		"text": "The dado was cut at 93. The groove had been marked at 92, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "93",
				"phrase": "The dado was cut at 93",
			},
			{
				"field": "score_hour",
				"value": "92",
				"phrase": "The groove had been marked at 92",
			},
		],
	},
	{
		"id": "E8",
		"title": "Groove note",
		"source": "Joiner's chest",
		"text": "The dado was cut at 93. The groove was opened so the gimlet would take the groove.",
		"literals": [
			{
				"field": "hour",
				"value": "93",
				"phrase": "The dado was cut at 93",
			},
			{
				"field": "aim",
				"value": "take_groove",
				"phrase": "so the gimlet would take the groove",
			},
		],
	},
	{
		"id": "E9",
		"title": "Hang order",
		"source": "Gimlet slate",
		"text": "The dado was cut at 93. The gimlet was wiped at 94, and the plough was hung at 95 once the groove was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "93",
				"phrase": "The dado was cut at 93",
			},
			{
				"field": "wipe_hour",
				"value": "94",
				"phrase": "The gimlet was wiped at 94",
			},
			{
				"field": "hang_hour",
				"value": "95",
				"phrase": "the plough was hung at 95",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"scorer",
		"score_room",
		"score_hour",
		"seen_from",
		"spur",
		"aim",
		"spur_room",
		"cleat_room",
		"whet_hour",
		"wipe_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "scorer", "spur":
			return PEOPLE.duplicate()
		"place", "score_room", "seen_from", "spur_room", "cleat_room":
			return PLACES.duplicate()
		"hour", "score_hour", "whet_hour", "wipe_hour", "hang_hour":
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
		missing.append("who cut the dado")
	if pins["place"] == "":
		missing.append("where they cut the dado")
	if pins["hour"] == "":
		missing.append("at which hour they cut the dado")
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
		"Kern":
			return "the plough hand"
		"Phel":
			return "the float hand"
		"Tarn":
			return "the gimlet clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"plough":
			return "plough"
		"float":
			return "float"
		"gimlet":
			return "gimlet"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"plough":
			return "Plough"
		"float":
			return "Float"
		"gimlet":
			return "Gimlet"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the dado" % value
		"place":
			return "The dado was cut in the %s" % place_label(value)
		"hour":
			return "The dado was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the dado" % value
		"place":
			return "the dado was cut in the %s" % place_label(value)
		"hour":
			return "the dado was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the dado" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_groove":
			return "so the gimlet would take the groove"
		"spare_groove":
			return "to spare the groove still waiting on the gimlet"
		"set_groove":
			return "to set the groove before the plough was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the dado in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the groove on the %s at %s." % [
			model["scorer"],
			role_short(str(model["scorer"])),
			place_label(str(model["score_room"])),
			model["score_hour"],
		],
		"%s (%s) turned the spur in the %s." % [
			model["spur"],
			role_short(str(model["spur"])),
			place_label(str(model["spur_room"])),
		],
		"The cleat was hung on the %s." % place_label(str(model["cleat_room"])),
		"The float was whetted at %s." % model["whet_hour"],
		"The gimlet was wiped at %s." % model["wipe_hour"],
		"The plough was hung at %s." % model["hang_hour"],
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
	return "Who cut the dado, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the dado in."


static func cast_line() -> String:
	return "Kern, plough hand    Phel, float hand    Tarn, gimlet clerk"


static func ready_line() -> String:
	return "Pin who cut the dado, the room they cut it in, and the hour. Then submit."


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
