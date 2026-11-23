extends RefCounted

# The chamfer.
#
# The player pins three facts about the cutting: who, the room the chamfer was
# cut in, and the hour. The timeline also records who marked the cove, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the file, where that turn was made, why the chamfer was cut, where
# the cant was hung, when the file was soaped, when the travisher was fettled, and
# when the block was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The chamfer"
const FILE_CODE := "CW-40"
const BLURB := "The chamfer left its peg at the joiner's stallion. Name who cut the chamfer, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Merrick", "Enid", "Petra"]
const PLACES: Array[String] = ["block", "file", "travisher"]
const HOURS: Array[String] = ["141", "142", "143", "144", "145"]
const AIMS: Array[String] = ["take_cove", "spare_cove", "set_cove"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Cove chit",
		"source": "Enid, cove hand",
		"text": "Merrick cut the chamfer. Enid had marked the cove, and a pale rime still clung to the chamfer.",
		"literals": [
			{
				"field": "taker",
				"value": "Merrick",
				"phrase": "Merrick cut the chamfer",
			},
			{
				"field": "cove",
				"value": "Enid",
				"phrase": "Enid had marked the cove",
			},
		],
	},
	{
		"id": "E2",
		"title": "Tooth sight",
		"source": "File tooth",
		"text": "Merrick cut the chamfer. The chamfering was seen from the file, beside the open cove.",
		"literals": [
			{
				"field": "taker",
				"value": "Merrick",
				"phrase": "Merrick cut the chamfer",
			},
			{
				"field": "seen_from",
				"value": "file",
				"phrase": "The chamfering was seen from the file",
			},
		],
	},
	{
		"id": "E3",
		"title": "Cant bill",
		"source": "Travisher nose",
		"text": "Merrick cut the chamfer. With the cove true, the cant was hung on the travisher.",
		"literals": [
			{
				"field": "taker",
				"value": "Merrick",
				"phrase": "Merrick cut the chamfer",
			},
			{
				"field": "cant_room",
				"value": "travisher",
				"phrase": "the cant was hung on the travisher",
			},
		],
	},
	{
		"id": "E4",
		"title": "Wisp slate",
		"source": "Block wisp",
		"text": "The chamfer was cut in the block. A fresh wisp shows the cove had been marked on the travisher.",
		"literals": [
			{
				"field": "place",
				"value": "block",
				"phrase": "The chamfer was cut in the block",
			},
			{
				"field": "cove_room",
				"value": "travisher",
				"phrase": "the cove had been marked on the travisher",
			},
		],
	},
	{
		"id": "E5",
		"title": "File card",
		"source": "Petra, file clerk",
		"text": "The chamfer was cut in the block. Petra turned the file in the block once the cove was offered.",
		"literals": [
			{
				"field": "place",
				"value": "block",
				"phrase": "The chamfer was cut in the block",
			},
			{
				"field": "file",
				"value": "Petra",
				"phrase": "Petra turned the file",
			},
			{
				"field": "file_room",
				"value": "block",
				"phrase": "turned the file in the block",
			},
		],
	},
	{
		"id": "E6",
		"title": "Soap slip",
		"source": "File tote",
		"text": "The chamfer was cut in the block. The file was soaped at 141, and a pale haze still sat on the chamfer.",
		"literals": [
			{
				"field": "place",
				"value": "block",
				"phrase": "The chamfer was cut in the block",
			},
			{
				"field": "soap_hour",
				"value": "141",
				"phrase": "The file was soaped at 141",
			},
		],
	},
	{
		"id": "E7",
		"title": "Chamfer leaf",
		"source": "Cove book",
		"text": "The chamfer was cut at 143. The cove had been marked at 142, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "143",
				"phrase": "The chamfer was cut at 143",
			},
			{
				"field": "cove_hour",
				"value": "142",
				"phrase": "The cove had been marked at 142",
			},
		],
	},
	{
		"id": "E8",
		"title": "Stallion note",
		"source": "Joiner's stallion",
		"text": "The chamfer was cut at 143. The cove was opened so the cove would take the chamfer.",
		"literals": [
			{
				"field": "hour",
				"value": "143",
				"phrase": "The chamfer was cut at 143",
			},
			{
				"field": "aim",
				"value": "take_cove",
				"phrase": "so the cove would take the chamfer",
			},
		],
	},
	{
		"id": "E9",
		"title": "Fettle order",
		"source": "Travisher card",
		"text": "The chamfer was cut at 143. The travisher was fettled at 144, and the block was hung at 145 once the cove was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "143",
				"phrase": "The chamfer was cut at 143",
			},
			{
				"field": "fettle_hour",
				"value": "144",
				"phrase": "The travisher was fettled at 144",
			},
			{
				"field": "hang_hour",
				"value": "145",
				"phrase": "the block was hung at 145",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"cove",
		"cove_room",
		"cove_hour",
		"seen_from",
		"file",
		"aim",
		"file_room",
		"cant_room",
		"soap_hour",
		"fettle_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "cove", "file":
			return PEOPLE.duplicate()
		"place", "cove_room", "seen_from", "file_room", "cant_room":
			return PLACES.duplicate()
		"hour", "cove_hour", "soap_hour", "fettle_hour", "hang_hour":
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
		missing.append("who cut the chamfer")
	if pins["place"] == "":
		missing.append("where they cut the chamfer")
	if pins["hour"] == "":
		missing.append("at which hour they cut the chamfer")
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
		"Merrick":
			return "the chamfer hand"
		"Enid":
			return "the cove hand"
		"Petra":
			return "the file clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"block":
			return "block"
		"file":
			return "file"
		"travisher":
			return "travisher"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"block":
			return "Block"
		"file":
			return "File"
		"travisher":
			return "Travisher"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the chamfer" % value
		"place":
			return "The chamfer was cut in the %s" % place_label(value)
		"hour":
			return "The chamfer was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the chamfer" % value
		"place":
			return "the chamfer was cut in the %s" % place_label(value)
		"hour":
			return "the chamfer was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the chamfer" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_cove":
			return "so the cove would take the chamfer"
		"spare_cove":
			return "to spare the cove still waiting on the chamfer"
		"set_cove":
			return "to set the cove before the block was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the chamfer in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the cove on the %s at %s." % [
			model["cove"],
			role_short(str(model["cove"])),
			place_label(str(model["cove_room"])),
			model["cove_hour"],
		],
		"%s (%s) turned the file in the %s." % [
			model["file"],
			role_short(str(model["file"])),
			place_label(str(model["file_room"])),
		],
		"The cant was hung on the %s." % place_label(str(model["cant_room"])),
		"The file was soaped at %s." % model["soap_hour"],
		"The travisher was fettled at %s." % model["fettle_hour"],
		"The block was hung at %s." % model["hang_hour"],
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
	return "Who cut the chamfer, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the chamfer in."


static func cast_line() -> String:
	return "Merrick, chamfer hand    Enid, cove hand    Petra, file clerk"


static func ready_line() -> String:
	return "Pin who cut the chamfer, the room they cut it in, and the hour. Then submit."


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
