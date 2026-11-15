extends RefCounted

# The spline.
#
# The player pins three facts about the cutting: who, the room the spline was
# cut in, and the hour. The timeline also records who marked the slot, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the key, where that turn was made, why the spline was cut, where
# the feather was hung, when the float was whetted, when the gimlet was wiped, and
# when the plough was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The spline"
const FILE_CODE := "CW-31"
const BLURB := "The spline left its peg at the joiner's vise. Name who cut the spline, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Senn", "Voss", "Cade"]
const PLACES: Array[String] = ["plough", "float", "gimlet"]
const HOURS: Array[String] = ["96", "97", "98", "99", "100"]
const AIMS: Array[String] = ["take_slot", "spare_slot", "set_slot"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Slot chit",
		"source": "Voss, chest hand",
		"text": "Senn cut the spline. Voss had marked the slot, and a pale curl still clung to the cheek.",
		"literals": [
			{
				"field": "taker",
				"value": "Senn",
				"phrase": "Senn cut the spline",
			},
			{
				"field": "slotter",
				"value": "Voss",
				"phrase": "Voss had marked the slot",
			},
		],
	},
	{
		"id": "E2",
		"title": "Rest sight",
		"source": "Float rest",
		"text": "Senn cut the spline. The cutting was seen from the float, over the open rest.",
		"literals": [
			{
				"field": "taker",
				"value": "Senn",
				"phrase": "Senn cut the spline",
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
		"title": "Feather hook",
		"source": "Gimlet nail",
		"text": "Senn cut the spline. With the slot true, the feather was hung on the gimlet.",
		"literals": [
			{
				"field": "taker",
				"value": "Senn",
				"phrase": "Senn cut the spline",
			},
			{
				"field": "feather_room",
				"value": "gimlet",
				"phrase": "the feather was hung on the gimlet",
			},
		],
	},
	{
		"id": "E4",
		"title": "Slot slate",
		"source": "Plough cheek",
		"text": "The spline was cut in the plough. A fresh edge shows the slot had been marked on the gimlet.",
		"literals": [
			{
				"field": "place",
				"value": "plough",
				"phrase": "The spline was cut in the plough",
			},
			{
				"field": "slot_room",
				"value": "gimlet",
				"phrase": "the slot had been marked on the gimlet",
			},
		],
	},
	{
		"id": "E5",
		"title": "Key card",
		"source": "Cade, horse clerk",
		"text": "The spline was cut in the plough. Cade turned the key in the float before the slot was offered.",
		"literals": [
			{
				"field": "place",
				"value": "plough",
				"phrase": "The spline was cut in the plough",
			},
			{
				"field": "key",
				"value": "Cade",
				"phrase": "Cade turned the key",
			},
			{
				"field": "turn_room",
				"value": "float",
				"phrase": "turned the key in the float",
			},
		],
	},
	{
		"id": "E6",
		"title": "Cheek slip",
		"source": "Float slate",
		"text": "The spline was cut in the plough. The float was whetted at 96, and a pale film still sat on the cheek.",
		"literals": [
			{
				"field": "place",
				"value": "plough",
				"phrase": "The spline was cut in the plough",
			},
			{
				"field": "whet_hour",
				"value": "96",
				"phrase": "The float was whetted at 96",
			},
		],
	},
	{
		"id": "E7",
		"title": "Slot leaf",
		"source": "Slot book",
		"text": "The spline was cut at 98. The slot had been marked at 97, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "98",
				"phrase": "The spline was cut at 98",
			},
			{
				"field": "slot_hour",
				"value": "97",
				"phrase": "The slot had been marked at 97",
			},
		],
	},
	{
		"id": "E8",
		"title": "Slot note",
		"source": "Joiner's vise",
		"text": "The spline was cut at 98. The slot was opened so the tongue would take the slot.",
		"literals": [
			{
				"field": "hour",
				"value": "98",
				"phrase": "The spline was cut at 98",
			},
			{
				"field": "aim",
				"value": "take_slot",
				"phrase": "so the tongue would take the slot",
			},
		],
	},
	{
		"id": "E9",
		"title": "Dry order",
		"source": "Gimlet board",
		"text": "The spline was cut at 98. The gimlet was wiped at 99, and the plough was hung at 100 once the slot was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "98",
				"phrase": "The spline was cut at 98",
			},
			{
				"field": "wipe_hour",
				"value": "99",
				"phrase": "The gimlet was wiped at 99",
			},
			{
				"field": "hang_hour",
				"value": "100",
				"phrase": "the plough was hung at 100",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"slotter",
		"slot_room",
		"slot_hour",
		"seen_from",
		"key",
		"aim",
		"turn_room",
		"feather_room",
		"whet_hour",
		"wipe_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "slotter", "key":
			return PEOPLE.duplicate()
		"place", "slot_room", "seen_from", "turn_room", "feather_room":
			return PLACES.duplicate()
		"hour", "slot_hour", "whet_hour", "wipe_hour", "hang_hour":
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
		missing.append("who cut the spline")
	if pins["place"] == "":
		missing.append("where they cut the spline")
	if pins["hour"] == "":
		missing.append("at which hour they cut the spline")
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
		"Senn":
			return "the vise hand"
		"Voss":
			return "the chest hand"
		"Cade":
			return "the horse clerk"
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
			return "%s cut the spline" % value
		"place":
			return "The spline was cut in the %s" % place_label(value)
		"hour":
			return "The spline was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the spline" % value
		"place":
			return "the spline was cut in the %s" % place_label(value)
		"hour":
			return "the spline was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the spline" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_slot":
			return "so the tongue would take the slot"
		"spare_slot":
			return "to spare the slot still waiting on the tongue"
		"set_slot":
			return "to set the slot before the plough was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the spline in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the slot on the %s at %s." % [
			model["slotter"],
			role_short(str(model["slotter"])),
			place_label(str(model["slot_room"])),
			model["slot_hour"],
		],
		"%s (%s) turned the key in the %s." % [
			model["key"],
			role_short(str(model["key"])),
			place_label(str(model["turn_room"])),
		],
		"The feather was hung on the %s." % place_label(str(model["feather_room"])),
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
	return "Who cut the spline, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the spline in."


static func cast_line() -> String:
	return "Senn, vise hand    Voss, chest hand    Cade, horse clerk"


static func ready_line() -> String:
	return "Pin who cut the spline, the room they cut it in, and the hour. Then submit."


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
