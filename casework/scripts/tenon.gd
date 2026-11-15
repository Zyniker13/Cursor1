extends RefCounted

# The tenon.
#
# The player pins three facts about the cutting: who, the room the tenon was
# cut in, and the hour. The timeline also records who marked the haunch, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the guide, where that turn was made, why the tenon was cut, where
# the dowel was hung, when the rasp was honed, when the bevel was wiped, and
# when the gouge was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The tenon"
const FILE_CODE := "CW-28"
const BLURB := "The tenon left its peg at the joiner's bench. Name who cut the tenon, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Harl", "Neve", "Luth"]
const PLACES: Array[String] = ["gouge", "rasp", "bevel"]
const HOURS: Array[String] = ["81", "82", "83", "84", "85"]
const AIMS: Array[String] = ["take_haunch", "spare_haunch", "set_haunch"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Gouge chit",
		"source": "Neve, rasp hand",
		"text": "Harl cut the tenon. Neve had marked the haunch, and the shavings still stuck in the mouth.",
		"literals": [
			{
				"field": "taker",
				"value": "Harl",
				"phrase": "Harl cut the tenon",
			},
			{
				"field": "nicker",
				"value": "Neve",
				"phrase": "Neve had marked the haunch",
			},
		],
	},
	{
		"id": "E2",
		"title": "Rasp sight",
		"source": "Rasp rail",
		"text": "Harl cut the tenon. The cutting was seen from the rasp, above the iron rest.",
		"literals": [
			{
				"field": "taker",
				"value": "Harl",
				"phrase": "Harl cut the tenon",
			},
			{
				"field": "seen_from",
				"value": "rasp",
				"phrase": "The cutting was seen from the rasp",
			},
		],
	},
	{
		"id": "E3",
		"title": "Dowel hook",
		"source": "Bevel peg",
		"text": "Harl cut the tenon. With the haunch true, the dowel was hung on the bevel.",
		"literals": [
			{
				"field": "taker",
				"value": "Harl",
				"phrase": "Harl cut the tenon",
			},
			{
				"field": "dowel_room",
				"value": "bevel",
				"phrase": "the dowel was hung on the bevel",
			},
		],
	},
	{
		"id": "E4",
		"title": "Haunch slate",
		"source": "Gouge jaw",
		"text": "The tenon was cut in the gouge. A fresh edge shows the haunch had been marked on the bevel.",
		"literals": [
			{
				"field": "place",
				"value": "gouge",
				"phrase": "The tenon was cut in the gouge",
			},
			{
				"field": "nick_room",
				"value": "bevel",
				"phrase": "the haunch had been marked on the bevel",
			},
		],
	},
	{
		"id": "E5",
		"title": "Guide card",
		"source": "Luth, bevel clerk",
		"text": "The tenon was cut in the gouge. Luth turned the guide in the rasp before the haunch was offered.",
		"literals": [
			{
				"field": "place",
				"value": "gouge",
				"phrase": "The tenon was cut in the gouge",
			},
			{
				"field": "guide",
				"value": "Luth",
				"phrase": "Luth turned the guide",
			},
			{
				"field": "guide_room",
				"value": "rasp",
				"phrase": "turned the guide in the rasp",
			},
		],
	},
	{
		"id": "E6",
		"title": "Hone slip",
		"source": "Rasp book",
		"text": "The tenon was cut in the gouge. The rasp was honed at 81, and a pale film still sat on the cheek.",
		"literals": [
			{
				"field": "place",
				"value": "gouge",
				"phrase": "The tenon was cut in the gouge",
			},
			{
				"field": "hone_hour",
				"value": "81",
				"phrase": "The rasp was honed at 81",
			},
		],
	},
	{
		"id": "E7",
		"title": "Nick leaf",
		"source": "Nick book",
		"text": "The tenon was cut at 83. The haunch had been marked at 82, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "83",
				"phrase": "The tenon was cut at 83",
			},
			{
				"field": "nick_hour",
				"value": "82",
				"phrase": "The haunch had been marked at 82",
			},
		],
	},
	{
		"id": "E8",
		"title": "Haunch note",
		"source": "Joiner's bench",
		"text": "The tenon was cut at 83. The haunch was opened so the bevel would take the haunch.",
		"literals": [
			{
				"field": "hour",
				"value": "83",
				"phrase": "The tenon was cut at 83",
			},
			{
				"field": "aim",
				"value": "take_haunch",
				"phrase": "so the bevel would take the haunch",
			},
		],
	},
	{
		"id": "E9",
		"title": "Hang order",
		"source": "Bevel slate",
		"text": "The tenon was cut at 83. The bevel was wiped at 84, and the gouge was hung at 85 once the haunch was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "83",
				"phrase": "The tenon was cut at 83",
			},
			{
				"field": "wipe_hour",
				"value": "84",
				"phrase": "The bevel was wiped at 84",
			},
			{
				"field": "hang_hour",
				"value": "85",
				"phrase": "the gouge was hung at 85",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"nicker",
		"nick_room",
		"nick_hour",
		"seen_from",
		"guide",
		"aim",
		"guide_room",
		"dowel_room",
		"hone_hour",
		"wipe_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "nicker", "guide":
			return PEOPLE.duplicate()
		"place", "nick_room", "seen_from", "guide_room", "dowel_room":
			return PLACES.duplicate()
		"hour", "nick_hour", "hone_hour", "wipe_hour", "hang_hour":
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
		missing.append("who cut the tenon")
	if pins["place"] == "":
		missing.append("where they cut the tenon")
	if pins["hour"] == "":
		missing.append("at which hour they cut the tenon")
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
		"Harl":
			return "the gouge hand"
		"Neve":
			return "the rasp hand"
		"Luth":
			return "the bevel clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"gouge":
			return "gouge"
		"rasp":
			return "rasp"
		"bevel":
			return "bevel"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"gouge":
			return "Gouge"
		"rasp":
			return "Rasp"
		"bevel":
			return "Bevel"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the tenon" % value
		"place":
			return "The tenon was cut in the %s" % place_label(value)
		"hour":
			return "The tenon was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the tenon" % value
		"place":
			return "the tenon was cut in the %s" % place_label(value)
		"hour":
			return "the tenon was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the tenon" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_haunch":
			return "so the bevel would take the haunch"
		"spare_haunch":
			return "to spare the haunch still waiting on the bevel"
		"set_haunch":
			return "to set the haunch before the gouge was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the tenon in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the haunch on the %s at %s." % [
			model["nicker"],
			role_short(str(model["nicker"])),
			place_label(str(model["nick_room"])),
			model["nick_hour"],
		],
		"%s (%s) turned the guide in the %s." % [
			model["guide"],
			role_short(str(model["guide"])),
			place_label(str(model["guide_room"])),
		],
		"The dowel was hung on the %s." % place_label(str(model["dowel_room"])),
		"The rasp was honed at %s." % model["hone_hour"],
		"The bevel was wiped at %s." % model["wipe_hour"],
		"The gouge was hung at %s." % model["hang_hour"],
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
	return "Who cut the tenon, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the tenon in."


static func cast_line() -> String:
	return "Harl, gouge hand    Neve, rasp hand    Luth, bevel clerk"


static func ready_line() -> String:
	return "Pin who cut the tenon, the room they cut it in, and the hour. Then submit."


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
