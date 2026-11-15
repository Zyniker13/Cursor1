extends RefCounted

# The dovetail.
#
# The player pins three facts about the cutting: who, the room the dovetail was
# cut in, and the hour. The timeline also records who sawed the board, where
# it was sawed, when that sawing was done, where the cutting was seen from, who
# turned the clamp, where that turn was made, why the dovetail was cut, where
# the peg was hung, when the apron was swept, when the stile was wiped, and
# when the vise was closed. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The dovetail"
const FILE_CODE := "CW-24"
const BLURB := "The dovetail left its peg at the joiner's bench. Name who cut the dovetail, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Doss", "Yarrow", "Peck"]
const PLACES: Array[String] = ["vise", "stile", "apron"]
const HOURS: Array[String] = ["61", "62", "63", "64", "65"]
const AIMS: Array[String] = ["take_joint", "spare_joint", "set_joint"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Saw chit",
		"source": "Yarrow, board hand",
		"text": "Doss cut the dovetail. Yarrow had sawed the board, and the kerf was still wide.",
		"literals": [
			{
				"field": "taker",
				"value": "Doss",
				"phrase": "Doss cut the dovetail",
			},
			{
				"field": "sawyer",
				"value": "Yarrow",
				"phrase": "Yarrow had sawed the board",
			},
		],
	},
	{
		"id": "E2",
		"title": "Apron sight",
		"source": "Apron rail",
		"text": "Doss cut the dovetail. The cutting was seen from the apron, over the shoulder of the jaw.",
		"literals": [
			{
				"field": "taker",
				"value": "Doss",
				"phrase": "Doss cut the dovetail",
			},
			{
				"field": "seen_from",
				"value": "apron",
				"phrase": "The cutting was seen from the apron",
			},
		],
	},
	{
		"id": "E3",
		"title": "Peg hook",
		"source": "Stile peg",
		"text": "Doss cut the dovetail. Once the joint sat tight, the peg was hung on the stile.",
		"literals": [
			{
				"field": "taker",
				"value": "Doss",
				"phrase": "Doss cut the dovetail",
			},
			{
				"field": "peg_room",
				"value": "stile",
				"phrase": "the peg was hung on the stile",
			},
		],
	},
	{
		"id": "E4",
		"title": "Joint slate",
		"source": "Vise jaw",
		"text": "The dovetail was cut in the vise. A jaw mark records that the board had been sawed on the stile.",
		"literals": [
			{
				"field": "place",
				"value": "vise",
				"phrase": "The dovetail was cut in the vise",
			},
			{
				"field": "saw_room",
				"value": "stile",
				"phrase": "the board had been sawed on the stile",
			},
		],
	},
	{
		"id": "E5",
		"title": "Clamp card",
		"source": "Peck, clamp clerk",
		"text": "The dovetail was cut in the vise. Peck turned the clamp in the apron before the joint was seated.",
		"literals": [
			{
				"field": "place",
				"value": "vise",
				"phrase": "The dovetail was cut in the vise",
			},
			{
				"field": "clamp",
				"value": "Peck",
				"phrase": "Peck turned the clamp",
			},
			{
				"field": "clamp_room",
				"value": "apron",
				"phrase": "turned the clamp in the apron",
			},
		],
	},
	{
		"id": "E6",
		"title": "Sweep slip",
		"source": "Apron book",
		"text": "The dovetail was cut in the vise. The apron was swept at 61, and chips still lay in the corner.",
		"literals": [
			{
				"field": "place",
				"value": "vise",
				"phrase": "The dovetail was cut in the vise",
			},
			{
				"field": "sweep_hour",
				"value": "61",
				"phrase": "The apron was swept at 61",
			},
		],
	},
	{
		"id": "E7",
		"title": "Cut leaf",
		"source": "Cut book",
		"text": "The dovetail was cut at 63. The board had been sawed at 62, which the kerf still shows.",
		"literals": [
			{
				"field": "hour",
				"value": "63",
				"phrase": "The dovetail was cut at 63",
			},
			{
				"field": "saw_hour",
				"value": "62",
				"phrase": "The board had been sawed at 62",
			},
		],
	},
	{
		"id": "E8",
		"title": "Joint note",
		"source": "Joiner's bench",
		"text": "The dovetail was cut at 63. Every stroke aimed so the stile would take the joint.",
		"literals": [
			{
				"field": "hour",
				"value": "63",
				"phrase": "The dovetail was cut at 63",
			},
			{
				"field": "aim",
				"value": "take_joint",
				"phrase": "so the stile would take the joint",
			},
		],
	},
	{
		"id": "E9",
		"title": "Jaw order",
		"source": "Stile slate",
		"text": "The dovetail was cut at 63. The stile was wiped at 64, and the vise was closed at 65 after the joint sat true.",
		"literals": [
			{
				"field": "hour",
				"value": "63",
				"phrase": "The dovetail was cut at 63",
			},
			{
				"field": "wipe_hour",
				"value": "64",
				"phrase": "The stile was wiped at 64",
			},
			{
				"field": "close_hour",
				"value": "65",
				"phrase": "the vise was closed at 65",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"sawyer",
		"saw_room",
		"saw_hour",
		"seen_from",
		"clamp",
		"aim",
		"clamp_room",
		"peg_room",
		"sweep_hour",
		"wipe_hour",
		"close_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "sawyer", "clamp":
			return PEOPLE.duplicate()
		"place", "saw_room", "seen_from", "clamp_room", "peg_room":
			return PLACES.duplicate()
		"hour", "saw_hour", "sweep_hour", "wipe_hour", "close_hour":
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
		missing.append("who cut the dovetail")
	if pins["place"] == "":
		missing.append("where they cut the dovetail")
	if pins["hour"] == "":
		missing.append("at which hour they cut the dovetail")
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
		"Doss":
			return "the saw hand"
		"Yarrow":
			return "the board hand"
		"Peck":
			return "the clamp clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"vise":
			return "vise"
		"stile":
			return "stile"
		"apron":
			return "apron"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"vise":
			return "Vise"
		"stile":
			return "Stile"
		"apron":
			return "Apron"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the dovetail" % value
		"place":
			return "The dovetail was cut in the %s" % place_label(value)
		"hour":
			return "The dovetail was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the dovetail" % value
		"place":
			return "the dovetail was cut in the %s" % place_label(value)
		"hour":
			return "the dovetail was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the dovetail" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_joint":
			return "so the stile would take the joint"
		"spare_joint":
			return "to spare the joint still on the stile"
		"set_joint":
			return "to set the joint before the vise closed"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the dovetail in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) sawed the board on the %s at %s." % [
			model["sawyer"],
			role_short(str(model["sawyer"])),
			place_label(str(model["saw_room"])),
			model["saw_hour"],
		],
		"%s (%s) turned the clamp in the %s." % [
			model["clamp"],
			role_short(str(model["clamp"])),
			place_label(str(model["clamp_room"])),
		],
		"The peg was hung on the %s." % place_label(str(model["peg_room"])),
		"The apron was swept at %s." % model["sweep_hour"],
		"The stile was wiped at %s." % model["wipe_hour"],
		"The vise was closed at %s." % model["close_hour"],
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
	return "Who cut the dovetail, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the dovetail in."


static func cast_line() -> String:
	return "Doss, saw hand    Yarrow, board hand    Peck, clamp clerk"


static func ready_line() -> String:
	return "Pin who cut the dovetail, the room they cut it in, and the hour. Then submit."


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
