extends RefCounted

# The haunch.
#
# The player pins three facts about the cutting: who, the room the haunch was
# cut in, and the hour. The timeline also records who marked the cheek, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the pin, where that turn was made, why the haunch was cut, where
# the sliver was hung, when the smoother was wiped, when the jointer was stoned, and
# when the fore was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The haunch"
const FILE_CODE := "CW-36"
const BLURB := "The haunch left its peg at the joiner's colt. Name who cut the haunch, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Rhys", "Mab", "Lisle"]
const PLACES: Array[String] = ["fore", "smoother", "jointer"]
const HOURS: Array[String] = ["121", "122", "123", "124", "125"]
const AIMS: Array[String] = ["take_cheek", "spare_cheek", "set_cheek"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Cheek chit",
		"source": "Mab, cheek hand",
		"text": "Rhys cut the haunch. Mab had marked the cheek, and a pale mote still clung to the toe.",
		"literals": [
			{
				"field": "taker",
				"value": "Rhys",
				"phrase": "Rhys cut the haunch",
			},
			{
				"field": "cheek",
				"value": "Mab",
				"phrase": "Mab had marked the cheek",
			},
		],
	},
	{
		"id": "E2",
		"title": "Toe sight",
		"source": "Smoother toe",
		"text": "Rhys cut the haunch. The cutting was seen from the smoother, beside the open toe.",
		"literals": [
			{
				"field": "taker",
				"value": "Rhys",
				"phrase": "Rhys cut the haunch",
			},
			{
				"field": "seen_from",
				"value": "smoother",
				"phrase": "The cutting was seen from the smoother",
			},
		],
	},
	{
		"id": "E3",
		"title": "Sliver bill",
		"source": "Jointer nose",
		"text": "Rhys cut the haunch. With the cheek true, the sliver was hung on the jointer.",
		"literals": [
			{
				"field": "taker",
				"value": "Rhys",
				"phrase": "Rhys cut the haunch",
			},
			{
				"field": "sliver_room",
				"value": "jointer",
				"phrase": "the sliver was hung on the jointer",
			},
		],
	},
	{
		"id": "E4",
		"title": "Bed slate",
		"source": "Fore bed",
		"text": "The haunch was cut in the fore. A fresh bed shows the cheek had been marked on the jointer.",
		"literals": [
			{
				"field": "place",
				"value": "fore",
				"phrase": "The haunch was cut in the fore",
			},
			{
				"field": "cheek_room",
				"value": "jointer",
				"phrase": "the cheek had been marked on the jointer",
			},
		],
	},
	{
		"id": "E5",
		"title": "Pin card",
		"source": "Lisle, pin clerk",
		"text": "The haunch was cut in the fore. Lisle turned the pin in the smoother before the cheek was offered.",
		"literals": [
			{
				"field": "place",
				"value": "fore",
				"phrase": "The haunch was cut in the fore",
			},
			{
				"field": "pin",
				"value": "Lisle",
				"phrase": "Lisle turned the pin",
			},
			{
				"field": "pin_room",
				"value": "smoother",
				"phrase": "turned the pin in the smoother",
			},
		],
	},
	{
		"id": "E6",
		"title": "Wipe slip",
		"source": "Smoother tote",
		"text": "The haunch was cut in the fore. The smoother was wiped at 121, and a pale mist still sat on the toe.",
		"literals": [
			{
				"field": "place",
				"value": "fore",
				"phrase": "The haunch was cut in the fore",
			},
			{
				"field": "wipe_hour",
				"value": "121",
				"phrase": "The smoother was wiped at 121",
			},
		],
	},
	{
		"id": "E7",
		"title": "Haunch leaf",
		"source": "Cheek book",
		"text": "The haunch was cut at 123. The cheek had been marked at 122, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "123",
				"phrase": "The haunch was cut at 123",
			},
			{
				"field": "cheek_hour",
				"value": "122",
				"phrase": "The cheek had been marked at 122",
			},
		],
	},
	{
		"id": "E8",
		"title": "Haunch note",
		"source": "Joiner's colt",
		"text": "The haunch was cut at 123. The cheek was opened so the cheek would take the haunch.",
		"literals": [
			{
				"field": "hour",
				"value": "123",
				"phrase": "The haunch was cut at 123",
			},
			{
				"field": "aim",
				"value": "take_cheek",
				"phrase": "so the cheek would take the haunch",
			},
		],
	},
	{
		"id": "E9",
		"title": "Stone order",
		"source": "Jointer card",
		"text": "The haunch was cut at 123. The jointer was stoned at 124, and the fore was hung at 125 once the cheek was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "123",
				"phrase": "The haunch was cut at 123",
			},
			{
				"field": "stone_hour",
				"value": "124",
				"phrase": "The jointer was stoned at 124",
			},
			{
				"field": "hang_hour",
				"value": "125",
				"phrase": "the fore was hung at 125",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"cheek",
		"cheek_room",
		"cheek_hour",
		"seen_from",
		"pin",
		"aim",
		"pin_room",
		"sliver_room",
		"wipe_hour",
		"stone_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "cheek", "pin":
			return PEOPLE.duplicate()
		"place", "cheek_room", "seen_from", "pin_room", "sliver_room":
			return PLACES.duplicate()
		"hour", "cheek_hour", "wipe_hour", "stone_hour", "hang_hour":
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
		missing.append("who cut the haunch")
	if pins["place"] == "":
		missing.append("where they cut the haunch")
	if pins["hour"] == "":
		missing.append("at which hour they cut the haunch")
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
		"Rhys":
			return "the haunch hand"
		"Mab":
			return "the cheek hand"
		"Lisle":
			return "the pin clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"fore":
			return "fore"
		"smoother":
			return "smoother"
		"jointer":
			return "jointer"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"fore":
			return "Fore"
		"smoother":
			return "Smoother"
		"jointer":
			return "Jointer"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the haunch" % value
		"place":
			return "The haunch was cut in the %s" % place_label(value)
		"hour":
			return "The haunch was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the haunch" % value
		"place":
			return "the haunch was cut in the %s" % place_label(value)
		"hour":
			return "the haunch was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the haunch" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_cheek":
			return "so the cheek would take the haunch"
		"spare_cheek":
			return "to spare the cheek still waiting on the haunch"
		"set_cheek":
			return "to set the cheek before the fore was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the haunch in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the cheek on the %s at %s." % [
			model["cheek"],
			role_short(str(model["cheek"])),
			place_label(str(model["cheek_room"])),
			model["cheek_hour"],
		],
		"%s (%s) turned the pin in the %s." % [
			model["pin"],
			role_short(str(model["pin"])),
			place_label(str(model["pin_room"])),
		],
		"The sliver was hung on the %s." % place_label(str(model["sliver_room"])),
		"The smoother was wiped at %s." % model["wipe_hour"],
		"The jointer was stoned at %s." % model["stone_hour"],
		"The fore was hung at %s." % model["hang_hour"],
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
	return "Who cut the haunch, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the haunch in."


static func cast_line() -> String:
	return "Rhys, haunch hand    Mab, cheek hand    Lisle, pin clerk"


static func ready_line() -> String:
	return "Pin who cut the haunch, the room they cut it in, and the hour. Then submit."


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
