extends RefCounted

# The net loft.
#
# The player pins three facts about the mending: who, the room the net was
# mended in, and the hour. The timeline also records who hung the net, where
# it was hung, when that hanging was done, where the mending was seen from, who
# turned the crank, where that turn was made, why the net was mended, where
# the needle was hung, when the shed was swept, when the rail was wiped, and
# when the loft was closed. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the mending is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The net loft"
const FILE_CODE := "CW-21"
const BLURB := "The net loft left its peg at the drying shed. Name who mended the net, the room they mended it in, and the hour."

const PEOPLE: Array[String] = ["Gwyn", "Hester", "Idris"]
const PLACES: Array[String] = ["loft", "shed", "rail"]
const HOURS: Array[String] = ["2", "3", "4", "5", "6"]
const PURPOSES: Array[String] = ["take_mesh", "spare_twine", "hold_head"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Mesh chit",
		"source": "Gwyn, net hand",
		"text": "Hester mended the net. Gwyn had hung the net from the rail peg and left the head slack.",
		"literals": [
			{
				"field": "taker",
				"value": "Hester",
				"phrase": "Hester mended the net",
			},
			{
				"field": "hanger",
				"value": "Gwyn",
				"phrase": "Gwyn had hung the net",
			},
		],
	},
	{
		"id": "E2",
		"title": "Shed sight",
		"source": "Shed door",
		"text": "Hester mended the net. The mending was seen from the shed, between the bare poles.",
		"literals": [
			{
				"field": "taker",
				"value": "Hester",
				"phrase": "Hester mended the net",
			},
			{
				"field": "seen_from",
				"value": "shed",
				"phrase": "The mending was seen from the shed",
			},
		],
	},
	{
		"id": "E3",
		"title": "Needle peg",
		"source": "Rail peg",
		"text": "Hester mended the net. With the mesh finished, the needle was hung on the rail.",
		"literals": [
			{
				"field": "taker",
				"value": "Hester",
				"phrase": "Hester mended the net",
			},
			{
				"field": "needle_place",
				"value": "rail",
				"phrase": "the needle was hung on the rail",
			},
		],
	},
	{
		"id": "E4",
		"title": "Loft slate",
		"source": "Loft beam",
		"text": "The net was mended in the loft. A beam note says the net had been hung on the rail.",
		"literals": [
			{
				"field": "place",
				"value": "loft",
				"phrase": "The net was mended in the loft",
			},
			{
				"field": "hung_place",
				"value": "rail",
				"phrase": "the net had been hung on the rail",
			},
		],
	},
	{
		"id": "E5",
		"title": "Crank card",
		"source": "Idris, shed clerk",
		"text": "The net was mended in the loft. Idris turned the crank in the shed and kept the mesh from slipping.",
		"literals": [
			{
				"field": "place",
				"value": "loft",
				"phrase": "The net was mended in the loft",
			},
			{
				"field": "cranker",
				"value": "Idris",
				"phrase": "Idris turned the crank",
			},
			{
				"field": "crank_place",
				"value": "shed",
				"phrase": "turned the crank in the shed",
			},
		],
	},
	{
		"id": "E6",
		"title": "Shed slip",
		"source": "Shed book",
		"text": "The net was mended in the loft. The shed was swept at 2, while the floor was still wet.",
		"literals": [
			{
				"field": "place",
				"value": "loft",
				"phrase": "The net was mended in the loft",
			},
			{
				"field": "sweep_hour",
				"value": "2",
				"phrase": "The shed was swept at 2",
			},
		],
	},
	{
		"id": "E7",
		"title": "Mend leaf",
		"source": "Loft book",
		"text": "The net was mended at 4. The net had been hung at 3, and the chalk on the beam still showed that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "4",
				"phrase": "The net was mended at 4",
			},
			{
				"field": "hung_hour",
				"value": "3",
				"phrase": "The net had been hung at 3",
			},
		],
	},
	{
		"id": "E8",
		"title": "Mesh note",
		"source": "Drying shed",
		"text": "The net was mended at 4. The work was done so the shed would take the mesh.",
		"literals": [
			{
				"field": "hour",
				"value": "4",
				"phrase": "The net was mended at 4",
			},
			{
				"field": "purpose",
				"value": "take_mesh",
				"phrase": "so the shed would take the mesh",
			},
		],
	},
	{
		"id": "E9",
		"title": "Close order",
		"source": "Rail slate",
		"text": "The net was mended at 4. The rail was wiped at 5, and the loft was closed at 6 once the mesh was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "4",
				"phrase": "The net was mended at 4",
			},
			{
				"field": "wipe_hour",
				"value": "5",
				"phrase": "The rail was wiped at 5",
			},
			{
				"field": "close_hour",
				"value": "6",
				"phrase": "the loft was closed at 6",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"hanger",
		"hung_place",
		"hung_hour",
		"seen_from",
		"cranker",
		"purpose",
		"crank_place",
		"needle_place",
		"sweep_hour",
		"wipe_hour",
		"close_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "hanger", "cranker":
			return PEOPLE.duplicate()
		"place", "hung_place", "seen_from", "crank_place", "needle_place":
			return PLACES.duplicate()
		"hour", "hung_hour", "sweep_hour", "wipe_hour", "close_hour":
			return HOURS.duplicate()
		"purpose":
			return PURPOSES.duplicate()
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
		missing.append("who mended the net")
	if pins["place"] == "":
		missing.append("where they mended the net")
	if pins["hour"] == "":
		missing.append("at which hour they mended the net")
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
		"Gwyn":
			return "the net hand"
		"Hester":
			return "the mend hand"
		"Idris":
			return "the shed clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"loft":
			return "loft"
		"shed":
			return "shed"
		"rail":
			return "rail"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"loft":
			return "Loft"
		"shed":
			return "Shed"
		"rail":
			return "Rail"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s mended the net" % value
		"place":
			return "The net was mended in the %s" % place_label(value)
		"hour":
			return "The net was mended at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s mended the net" % value
		"place":
			return "the net was mended in the %s" % place_label(value)
		"hour":
			return "the net was mended at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s mended the net" % value
		"place":
			return "it was mended in the %s" % place_label(value)
		"hour":
			return "it was mended at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"take_mesh":
			return "so the shed would take the mesh"
		"spare_twine":
			return "to spare the twine still on the rail"
		"hold_head":
			return "to hold the head until the mesh dried"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) mended the net in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) hung the net on the %s at %s." % [
			model["hanger"],
			role_short(str(model["hanger"])),
			place_label(str(model["hung_place"])),
			model["hung_hour"],
		],
		"%s (%s) turned the crank in the %s." % [
			model["cranker"],
			role_short(str(model["cranker"])),
			place_label(str(model["crank_place"])),
		],
		"The needle was hung on the %s." % place_label(str(model["needle_place"])),
		"The shed was swept at %s." % model["sweep_hour"],
		"The rail was wiped at %s." % model["wipe_hour"],
		"The loft was closed at %s." % model["close_hour"],
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
	return "Who mended the net, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they mended the net in."


static func cast_line() -> String:
	return "Gwyn, net hand    Hester, mend hand    Idris, shed clerk"


static func ready_line() -> String:
	return "Pin who mended the net, the room they mended it in, and the hour. Then submit."


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
