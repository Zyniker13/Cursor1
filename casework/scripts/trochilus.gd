extends RefCounted

# The trochilus.
#
# The player pins three facts about the cutting: who, the room the trochilus was
# cut in, and the hour. The timeline also records who marked the applewood, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the oratory, where that turn was made, why the trochilus was cut, where
# the laburnum was hung, when the oratory was ambered, when the burin was copaled, and
# when the ambulatory was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The trochilus"
const FILE_CODE := "CW-56"
const BLURB := "The trochilus left its peg at the joiner's grommet. Name who cut the trochilus, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Colin", "Lars", "Ines"]
const PLACES: Array[String] = ["ambulatory", "oratory", "burin"]
const HOURS: Array[String] = ["221", "222", "223", "224", "225"]
const AIMS: Array[String] = ["take_applewood", "spare_applewood", "set_applewood"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Applewood chit",
		"source": "Lars, applewood hand",
		"text": "Colin cut the trochilus. Lars had marked the applewood, and a pale cudbear still clung to the trochilus.",
		"literals": [
			{
				"field": "taker",
				"value": "Colin",
				"phrase": "Colin cut the trochilus",
			},
			{
				"field": "applewood",
				"value": "Lars",
				"phrase": "Lars had marked the applewood",
			},
		],
	},
	{
		"id": "E2",
		"title": "Litmus sight",
		"source": "Oratory litmus",
		"text": "Colin cut the trochilus. The trochilusing was seen from the oratory, beside the open applewood.",
		"literals": [
			{
				"field": "taker",
				"value": "Colin",
				"phrase": "Colin cut the trochilus",
			},
			{
				"field": "seen_from",
				"value": "oratory",
				"phrase": "The trochilusing was seen from the oratory",
			},
		],
	},
	{
		"id": "E3",
		"title": "Laburnum bill",
		"source": "Burin nose",
		"text": "Colin cut the trochilus. With the applewood true, the laburnum was hung on the burin.",
		"literals": [
			{
				"field": "taker",
				"value": "Colin",
				"phrase": "Colin cut the trochilus",
			},
			{
				"field": "laburnum_room",
				"value": "burin",
				"phrase": "the laburnum was hung on the burin",
			},
		],
	},
	{
		"id": "E4",
		"title": "Morin slate",
		"source": "Ambulatory morin",
		"text": "The trochilus was cut in the ambulatory. A fresh morin shows the applewood had been marked on the burin.",
		"literals": [
			{
				"field": "place",
				"value": "ambulatory",
				"phrase": "The trochilus was cut in the ambulatory",
			},
			{
				"field": "applewood_room",
				"value": "burin",
				"phrase": "the applewood had been marked on the burin",
			},
		],
	},
	{
		"id": "E5",
		"title": "Oratory card",
		"source": "Ines, oratory clerk",
		"text": "The trochilus was cut in the ambulatory. Ines turned the oratory in the ambulatory once the applewood was offered.",
		"literals": [
			{
				"field": "place",
				"value": "ambulatory",
				"phrase": "The trochilus was cut in the ambulatory",
			},
			{
				"field": "oratory",
				"value": "Ines",
				"phrase": "Ines turned the oratory",
			},
			{
				"field": "oratory_room",
				"value": "ambulatory",
				"phrase": "turned the oratory in the ambulatory",
			},
		],
	},
	{
		"id": "E6",
		"title": "Ambered slip",
		"source": "Oratory tote",
		"text": "The trochilus was cut in the ambulatory. The oratory was ambered at 221, and a pale luteolin still sat on the trochilus.",
		"literals": [
			{
				"field": "place",
				"value": "ambulatory",
				"phrase": "The trochilus was cut in the ambulatory",
			},
			{
				"field": "amber_hour",
				"value": "221",
				"phrase": "The oratory was ambered at 221",
			},
		],
	},
	{
		"id": "E7",
		"title": "Trochilus leaf",
		"source": "Applewood book",
		"text": "The trochilus was cut at 223. The applewood had been marked at 222, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "223",
				"phrase": "The trochilus was cut at 223",
			},
			{
				"field": "applewood_hour",
				"value": "222",
				"phrase": "The applewood had been marked at 222",
			},
		],
	},
	{
		"id": "E8",
		"title": "Grommet note",
		"source": "Joiner's grommet",
		"text": "The trochilus was cut at 223. The applewood was opened so the applewood would take the trochilus.",
		"literals": [
			{
				"field": "hour",
				"value": "223",
				"phrase": "The trochilus was cut at 223",
			},
			{
				"field": "aim",
				"value": "take_applewood",
				"phrase": "so the applewood would take the trochilus",
			},
		],
	},
	{
		"id": "E9",
		"title": "Copaled order",
		"source": "Burin card",
		"text": "The trochilus was cut at 223. The burin was copaled at 224, and the ambulatory was hung at 225 once the applewood was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "223",
				"phrase": "The trochilus was cut at 223",
			},
			{
				"field": "copal_hour",
				"value": "224",
				"phrase": "The burin was copaled at 224",
			},
			{
				"field": "hang_hour",
				"value": "225",
				"phrase": "the ambulatory was hung at 225",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"applewood",
		"applewood_room",
		"applewood_hour",
		"seen_from",
		"oratory",
		"aim",
		"oratory_room",
		"laburnum_room",
		"amber_hour",
		"copal_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "applewood", "oratory":
			return PEOPLE.duplicate()
		"place", "applewood_room", "seen_from", "oratory_room", "laburnum_room":
			return PLACES.duplicate()
		"hour", "applewood_hour", "amber_hour", "copal_hour", "hang_hour":
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
		missing.append("who cut the trochilus")
	if pins["place"] == "":
		missing.append("where they cut the trochilus")
	if pins["hour"] == "":
		missing.append("at which hour they cut the trochilus")
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
		"Colin":
			return "the trochilus hand"
		"Lars":
			return "the applewood hand"
		"Ines":
			return "the oratory clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"ambulatory":
			return "ambulatory"
		"oratory":
			return "oratory"
		"burin":
			return "burin"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"ambulatory":
			return "Ambulatory"
		"oratory":
			return "Oratory"
		"burin":
			return "Burin"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the trochilus" % value
		"place":
			return "The trochilus was cut in the %s" % place_label(value)
		"hour":
			return "The trochilus was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the trochilus" % value
		"place":
			return "the trochilus was cut in the %s" % place_label(value)
		"hour":
			return "the trochilus was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the trochilus" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_applewood":
			return "so the applewood would take the trochilus"
		"spare_applewood":
			return "to spare the applewood still waiting on the trochilus"
		"set_applewood":
			return "to set the applewood before the ambulatory was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the trochilus in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the applewood on the %s at %s." % [
			model["applewood"],
			role_short(str(model["applewood"])),
			place_label(str(model["applewood_room"])),
			model["applewood_hour"],
		],
		"%s (%s) turned the oratory in the %s." % [
			model["oratory"],
			role_short(str(model["oratory"])),
			place_label(str(model["oratory_room"])),
		],
		"The laburnum was hung on the %s." % place_label(str(model["laburnum_room"])),
		"The oratory was ambered at %s." % model["amber_hour"],
		"The burin was copaled at %s." % model["copal_hour"],
		"The ambulatory was hung at %s." % model["hang_hour"],
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
	return "Who cut the trochilus, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the trochilus in."


static func cast_line() -> String:
	return "Colin, trochilus hand    Lars, applewood hand    Ines, oratory clerk"


static func ready_line() -> String:
	return "Pin who cut the trochilus, the room they cut it in, and the hour. Then submit."


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
