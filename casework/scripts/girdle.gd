extends RefCounted

# The girdle.
#
# The player pins three facts about the cutting: who, the room the girdle was
# cut in, and the hour. The timeline also records who marked the cherry, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the trestle, where that turn was made, why the girdle was cut, where
# the plum was hung, when the trestle was sized, when the fillister was clayed, and
# when the bole was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The girdle"
const FILE_CODE := "CW-49"
const BLURB := "The girdle left its peg at the joiner's hack. Name who cut the girdle, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Agnes", "Simon", "Felix"]
const PLACES: Array[String] = ["bole", "trestle", "fillister"]
const HOURS: Array[String] = ["186", "187", "188", "189", "190"]
const AIMS: Array[String] = ["take_cherry", "spare_cherry", "set_cherry"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Cherry chit",
		"source": "Simon, cherry hand",
		"text": "Agnes cut the girdle. Simon had marked the cherry, and a pale kermes still clung to the girdle.",
		"literals": [
			{
				"field": "taker",
				"value": "Agnes",
				"phrase": "Agnes cut the girdle",
			},
			{
				"field": "cherry",
				"value": "Simon",
				"phrase": "Simon had marked the cherry",
			},
		],
	},
	{
		"id": "E2",
		"title": "Brazil sight",
		"source": "Trestle brazil",
		"text": "Agnes cut the girdle. The girdleing was seen from the trestle, beside the open cherry.",
		"literals": [
			{
				"field": "taker",
				"value": "Agnes",
				"phrase": "Agnes cut the girdle",
			},
			{
				"field": "seen_from",
				"value": "trestle",
				"phrase": "The girdleing was seen from the trestle",
			},
		],
	},
	{
		"id": "E3",
		"title": "Plum bill",
		"source": "Fillister nose",
		"text": "Agnes cut the girdle. With the cherry true, the plum was hung on the fillister.",
		"literals": [
			{
				"field": "taker",
				"value": "Agnes",
				"phrase": "Agnes cut the girdle",
			},
			{
				"field": "plum_room",
				"value": "fillister",
				"phrase": "the plum was hung on the fillister",
			},
		],
	},
	{
		"id": "E4",
		"title": "Fustic slate",
		"source": "Bole fustic",
		"text": "The girdle was cut in the bole. A fresh fustic shows the cherry had been marked on the fillister.",
		"literals": [
			{
				"field": "place",
				"value": "bole",
				"phrase": "The girdle was cut in the bole",
			},
			{
				"field": "cherry_room",
				"value": "fillister",
				"phrase": "the cherry had been marked on the fillister",
			},
		],
	},
	{
		"id": "E5",
		"title": "Trestle card",
		"source": "Felix, trestle clerk",
		"text": "The girdle was cut in the bole. Felix turned the trestle in the bole once the cherry was offered.",
		"literals": [
			{
				"field": "place",
				"value": "bole",
				"phrase": "The girdle was cut in the bole",
			},
			{
				"field": "trestle",
				"value": "Felix",
				"phrase": "Felix turned the trestle",
			},
			{
				"field": "trestle_room",
				"value": "bole",
				"phrase": "turned the trestle in the bole",
			},
		],
	},
	{
		"id": "E6",
		"title": "Size slip",
		"source": "Trestle tote",
		"text": "The girdle was cut in the bole. The trestle was sized at 186, and a pale archil still sat on the girdle.",
		"literals": [
			{
				"field": "place",
				"value": "bole",
				"phrase": "The girdle was cut in the bole",
			},
			{
				"field": "size_hour",
				"value": "186",
				"phrase": "The trestle was sized at 186",
			},
		],
	},
	{
		"id": "E7",
		"title": "Girdle leaf",
		"source": "Cherry book",
		"text": "The girdle was cut at 188. The cherry had been marked at 187, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "188",
				"phrase": "The girdle was cut at 188",
			},
			{
				"field": "cherry_hour",
				"value": "187",
				"phrase": "The cherry had been marked at 187",
			},
		],
	},
	{
		"id": "E8",
		"title": "Hack note",
		"source": "Joiner's hack",
		"text": "The girdle was cut at 188. The cherry was opened so the cherry would take the girdle.",
		"literals": [
			{
				"field": "hour",
				"value": "188",
				"phrase": "The girdle was cut at 188",
			},
			{
				"field": "aim",
				"value": "take_cherry",
				"phrase": "so the cherry would take the girdle",
			},
		],
	},
	{
		"id": "E9",
		"title": "Clay order",
		"source": "Fillister card",
		"text": "The girdle was cut at 188. The fillister was clayed at 189, and the bole was hung at 190 once the cherry was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "188",
				"phrase": "The girdle was cut at 188",
			},
			{
				"field": "clay_hour",
				"value": "189",
				"phrase": "The fillister was clayed at 189",
			},
			{
				"field": "hang_hour",
				"value": "190",
				"phrase": "the bole was hung at 190",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"cherry",
		"cherry_room",
		"cherry_hour",
		"seen_from",
		"trestle",
		"aim",
		"trestle_room",
		"plum_room",
		"size_hour",
		"clay_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "cherry", "trestle":
			return PEOPLE.duplicate()
		"place", "cherry_room", "seen_from", "trestle_room", "plum_room":
			return PLACES.duplicate()
		"hour", "cherry_hour", "size_hour", "clay_hour", "hang_hour":
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
		missing.append("who cut the girdle")
	if pins["place"] == "":
		missing.append("where they cut the girdle")
	if pins["hour"] == "":
		missing.append("at which hour they cut the girdle")
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
		"Agnes":
			return "the girdle hand"
		"Simon":
			return "the cherry hand"
		"Felix":
			return "the trestle clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"bole":
			return "bole"
		"trestle":
			return "trestle"
		"fillister":
			return "fillister"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"bole":
			return "Bole"
		"trestle":
			return "Trestle"
		"fillister":
			return "Fillister"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the girdle" % value
		"place":
			return "The girdle was cut in the %s" % place_label(value)
		"hour":
			return "The girdle was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the girdle" % value
		"place":
			return "the girdle was cut in the %s" % place_label(value)
		"hour":
			return "the girdle was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the girdle" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_cherry":
			return "so the cherry would take the girdle"
		"spare_cherry":
			return "to spare the cherry still waiting on the girdle"
		"set_cherry":
			return "to set the cherry before the bole was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the girdle in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the cherry on the %s at %s." % [
			model["cherry"],
			role_short(str(model["cherry"])),
			place_label(str(model["cherry_room"])),
			model["cherry_hour"],
		],
		"%s (%s) turned the trestle in the %s." % [
			model["trestle"],
			role_short(str(model["trestle"])),
			place_label(str(model["trestle_room"])),
		],
		"The plum was hung on the %s." % place_label(str(model["plum_room"])),
		"The trestle was sized at %s." % model["size_hour"],
		"The fillister was clayed at %s." % model["clay_hour"],
		"The bole was hung at %s." % model["hang_hour"],
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
	return "Who cut the girdle, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the girdle in."


static func cast_line() -> String:
	return "Agnes, girdle hand    Simon, cherry hand    Felix, trestle clerk"


static func ready_line() -> String:
	return "Pin who cut the girdle, the room they cut it in, and the hour. Then submit."


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
