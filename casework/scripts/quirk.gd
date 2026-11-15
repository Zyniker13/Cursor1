extends RefCounted

# The quirk.
#
# The player pins three facts about the scratching: who, the room the quirk was
# scratched in, and the hour. The timeline also records who marked the ovolo, where
# it was marked, when that marking was done, where the scratching was seen from,
# who turned the snib, where that turn was made, why the quirk was scratched, where
# the astragal was hung, when the snib was oiled, when the veiner was stoned, and
# when the scratch was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the scratching is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The quirk"
const FILE_CODE := "CW-39"
const BLURB := "The quirk left its peg at the joiner's gelding. Name who scratched the quirk, the room they scratched it in, and the hour."

const PEOPLE: Array[String] = ["Ross", "Pia", "Jude"]
const PLACES: Array[String] = ["scratch", "snib", "veiner"]
const HOURS: Array[String] = ["136", "137", "138", "139", "140"]
const AIMS: Array[String] = ["take_ovolo", "spare_ovolo", "set_ovolo"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Ovolo chit",
		"source": "Pia, ovolo hand",
		"text": "Ross scratched the quirk. Pia had marked the ovolo, and a pale grit still clung to the quirk.",
		"literals": [
			{
				"field": "taker",
				"value": "Ross",
				"phrase": "Ross scratched the quirk",
			},
			{
				"field": "ovolo",
				"value": "Pia",
				"phrase": "Pia had marked the ovolo",
			},
		],
	},
	{
		"id": "E2",
		"title": "Bolt sight",
		"source": "Snib bolt",
		"text": "Ross scratched the quirk. The scratching was seen from the snib, beside the open quirk.",
		"literals": [
			{
				"field": "taker",
				"value": "Ross",
				"phrase": "Ross scratched the quirk",
			},
			{
				"field": "seen_from",
				"value": "snib",
				"phrase": "The scratching was seen from the snib",
			},
		],
	},
	{
		"id": "E3",
		"title": "Astragal bill",
		"source": "Veiner nose",
		"text": "Ross scratched the quirk. With the ovolo true, the astragal was hung on the veiner.",
		"literals": [
			{
				"field": "taker",
				"value": "Ross",
				"phrase": "Ross scratched the quirk",
			},
			{
				"field": "astragal_room",
				"value": "veiner",
				"phrase": "the astragal was hung on the veiner",
			},
		],
	},
	{
		"id": "E4",
		"title": "Score slate",
		"source": "Scratch score",
		"text": "The quirk was scratched in the scratch. A fresh score shows the ovolo had been marked on the veiner.",
		"literals": [
			{
				"field": "place",
				"value": "scratch",
				"phrase": "The quirk was scratched in the scratch",
			},
			{
				"field": "ovolo_room",
				"value": "veiner",
				"phrase": "the ovolo had been marked on the veiner",
			},
		],
	},
	{
		"id": "E5",
		"title": "Snib card",
		"source": "Jude, snib clerk",
		"text": "The quirk was scratched in the scratch. Jude turned the snib in the scratch once the ovolo was offered.",
		"literals": [
			{
				"field": "place",
				"value": "scratch",
				"phrase": "The quirk was scratched in the scratch",
			},
			{
				"field": "snib",
				"value": "Jude",
				"phrase": "Jude turned the snib",
			},
			{
				"field": "snib_room",
				"value": "scratch",
				"phrase": "turned the snib in the scratch",
			},
		],
	},
	{
		"id": "E6",
		"title": "Grease slip",
		"source": "Snib tote",
		"text": "The quirk was scratched in the scratch. The snib was oiled at 136, and a pale bloom still sat on the quirk.",
		"literals": [
			{
				"field": "place",
				"value": "scratch",
				"phrase": "The quirk was scratched in the scratch",
			},
			{
				"field": "oil_hour",
				"value": "136",
				"phrase": "The snib was oiled at 136",
			},
		],
	},
	{
		"id": "E7",
		"title": "Quirk leaf",
		"source": "Ovolo book",
		"text": "The quirk was scratched at 138. The ovolo had been marked at 137, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "138",
				"phrase": "The quirk was scratched at 138",
			},
			{
				"field": "ovolo_hour",
				"value": "137",
				"phrase": "The ovolo had been marked at 137",
			},
		],
	},
	{
		"id": "E8",
		"title": "Gelding note",
		"source": "Joiner's gelding",
		"text": "The quirk was scratched at 138. The ovolo was opened so the ovolo would take the quirk.",
		"literals": [
			{
				"field": "hour",
				"value": "138",
				"phrase": "The quirk was scratched at 138",
			},
			{
				"field": "aim",
				"value": "take_ovolo",
				"phrase": "so the ovolo would take the quirk",
			},
		],
	},
	{
		"id": "E9",
		"title": "Whet order",
		"source": "Veiner card",
		"text": "The quirk was scratched at 138. The veiner was stoned at 139, and the scratch was hung at 140 once the ovolo was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "138",
				"phrase": "The quirk was scratched at 138",
			},
			{
				"field": "stone_hour",
				"value": "139",
				"phrase": "The veiner was stoned at 139",
			},
			{
				"field": "hang_hour",
				"value": "140",
				"phrase": "the scratch was hung at 140",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"ovolo",
		"ovolo_room",
		"ovolo_hour",
		"seen_from",
		"snib",
		"aim",
		"snib_room",
		"astragal_room",
		"oil_hour",
		"stone_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "ovolo", "snib":
			return PEOPLE.duplicate()
		"place", "ovolo_room", "seen_from", "snib_room", "astragal_room":
			return PLACES.duplicate()
		"hour", "ovolo_hour", "oil_hour", "stone_hour", "hang_hour":
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
		missing.append("who scratched the quirk")
	if pins["place"] == "":
		missing.append("where they scratched the quirk")
	if pins["hour"] == "":
		missing.append("at which hour they scratched the quirk")
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
		"Ross":
			return "the quirk hand"
		"Pia":
			return "the ovolo hand"
		"Jude":
			return "the snib clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"scratch":
			return "scratch"
		"snib":
			return "snib"
		"veiner":
			return "veiner"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"scratch":
			return "Scratch"
		"snib":
			return "Snib"
		"veiner":
			return "Veiner"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s scratched the quirk" % value
		"place":
			return "The quirk was scratched in the %s" % place_label(value)
		"hour":
			return "The quirk was scratched at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s scratched the quirk" % value
		"place":
			return "the quirk was scratched in the %s" % place_label(value)
		"hour":
			return "the quirk was scratched at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s scratched the quirk" % value
		"place":
			return "it was scratched in the %s" % place_label(value)
		"hour":
			return "it was scratched at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_ovolo":
			return "so the ovolo would take the quirk"
		"spare_ovolo":
			return "to spare the ovolo still waiting on the quirk"
		"set_ovolo":
			return "to set the ovolo before the scratch was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) scratched the quirk in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the ovolo on the %s at %s." % [
			model["ovolo"],
			role_short(str(model["ovolo"])),
			place_label(str(model["ovolo_room"])),
			model["ovolo_hour"],
		],
		"%s (%s) turned the snib in the %s." % [
			model["snib"],
			role_short(str(model["snib"])),
			place_label(str(model["snib_room"])),
		],
		"The astragal was hung on the %s." % place_label(str(model["astragal_room"])),
		"The snib was oiled at %s." % model["oil_hour"],
		"The veiner was stoned at %s." % model["stone_hour"],
		"The scratch was hung at %s." % model["hang_hour"],
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
	return "Who scratched the quirk, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they scratched the quirk in."


static func cast_line() -> String:
	return "Ross, quirk hand    Pia, ovolo hand    Jude, snib clerk"


static func ready_line() -> String:
	return "Pin who scratched the quirk, the room they scratched it in, and the hour. Then submit."


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
