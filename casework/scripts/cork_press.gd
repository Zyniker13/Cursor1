extends RefCounted

# The cork press.
#
# The player pins three facts about the pressing: who, the room the cork was
# pressed in, and the hour. The timeline also records who cut the cork, where
# it was cut, when that cutting was done, where the pressing was seen from, who
# turned the screw, where that turn was made, why the cork was pressed, where
# the mallet was hung, when the cellar was swept, when the bench was wiped, and
# when the press was locked. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the pressing is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The cork press"
const FILE_CODE := "CW-20"
const BLURB := "The cork press left its peg at the bottle house. Name who pressed the cork, the room they pressed it in, and the hour."

const PEOPLE: Array[String] = ["Ansel", "Brea", "Colm"]
const PLACES: Array[String] = ["press", "cellar", "bench"]
const HOURS: Array[String] = ["3", "4", "5", "6", "7"]
const PURPOSES: Array[String] = ["take_seal", "spare_wax", "hold_neck"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Cutter chit",
		"source": "Ansel, press hand",
		"text": "Brea pressed the cork. The neck tag shows Ansel had cut the cork and left the plug square.",
		"literals": [
			{
				"field": "taker",
				"value": "Brea",
				"phrase": "Brea pressed the cork",
			},
			{
				"field": "cutter",
				"value": "Ansel",
				"phrase": "Ansel had cut the cork",
			},
		],
	},
	{
		"id": "E2",
		"title": "Cellar sight",
		"source": "Cellar stair",
		"text": "Brea pressed the cork. The pressing was seen from the cellar, across the empty bins.",
		"literals": [
			{
				"field": "taker",
				"value": "Brea",
				"phrase": "Brea pressed the cork",
			},
			{
				"field": "seen_place",
				"value": "cellar",
				"phrase": "The pressing was seen from the cellar",
			},
		],
	},
	{
		"id": "E3",
		"title": "Mallet peg",
		"source": "Bench peg",
		"text": "Brea pressed the cork. After the seal set, the mallet was hung on the bench.",
		"literals": [
			{
				"field": "taker",
				"value": "Brea",
				"phrase": "Brea pressed the cork",
			},
			{
				"field": "mallet_place",
				"value": "bench",
				"phrase": "the mallet was hung on the bench",
			},
		],
	},
	{
		"id": "E4",
		"title": "Press slate",
		"source": "Press rim",
		"text": "The cork was pressed in the press. The neck book shows that cork had been cut on the bench.",
		"literals": [
			{
				"field": "place",
				"value": "press",
				"phrase": "The cork was pressed in the press",
			},
			{
				"field": "cut_place",
				"value": "bench",
				"phrase": "that cork had been cut on the bench",
			},
		],
	},
	{
		"id": "E5",
		"title": "Screw card",
		"source": "Colm, cellar clerk",
		"text": "The cork was pressed in the press. Colm turned the screw, and that turn was seated in the cellar until the neck held.",
		"literals": [
			{
				"field": "place",
				"value": "press",
				"phrase": "The cork was pressed in the press",
			},
			{
				"field": "turner",
				"value": "Colm",
				"phrase": "Colm turned the screw",
			},
			{
				"field": "screw_place",
				"value": "cellar",
				"phrase": "that turn was seated in the cellar",
			},
		],
	},
	{
		"id": "E6",
		"title": "Broom slip",
		"source": "Cellar book",
		"text": "The cork was pressed in the press. The cellar was swept at 3, before the first bottle was set.",
		"literals": [
			{
				"field": "place",
				"value": "press",
				"phrase": "The cork was pressed in the press",
			},
			{
				"field": "broom_hour",
				"value": "3",
				"phrase": "The cellar was swept at 3",
			},
		],
	},
	{
		"id": "E7",
		"title": "Cork leaf",
		"source": "Press book",
		"text": "The cork was pressed at 5. A chalk mark says the cork had been cut at 4, an hour before the seal.",
		"literals": [
			{
				"field": "hour",
				"value": "5",
				"phrase": "The cork was pressed at 5",
			},
			{
				"field": "cut_hour",
				"value": "4",
				"phrase": "the cork had been cut at 4",
			},
		],
	},
	{
		"id": "E8",
		"title": "Seal note",
		"source": "Bottle house",
		"text": "The cork was pressed at 5. The pressing was made so the cellar would take the seal.",
		"literals": [
			{
				"field": "hour",
				"value": "5",
				"phrase": "The cork was pressed at 5",
			},
			{
				"field": "purpose",
				"value": "take_seal",
				"phrase": "so the cellar would take the seal",
			},
		],
	},
	{
		"id": "E9",
		"title": "Lock order",
		"source": "Bench slate",
		"text": "The cork was pressed at 5. The bench was wiped at 6, and the press was locked at 7.",
		"literals": [
			{
				"field": "hour",
				"value": "5",
				"phrase": "The cork was pressed at 5",
			},
			{
				"field": "wipe_hour",
				"value": "6",
				"phrase": "The bench was wiped at 6",
			},
			{
				"field": "lock_hour",
				"value": "7",
				"phrase": "the press was locked at 7",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"cutter",
		"cut_place",
		"cut_hour",
		"seen_place",
		"turner",
		"purpose",
		"screw_place",
		"mallet_place",
		"broom_hour",
		"wipe_hour",
		"lock_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "cutter", "turner":
			return PEOPLE.duplicate()
		"place", "cut_place", "seen_place", "screw_place", "mallet_place":
			return PLACES.duplicate()
		"hour", "cut_hour", "broom_hour", "wipe_hour", "lock_hour":
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
		missing.append("who pressed the cork")
	if pins["place"] == "":
		missing.append("where they pressed the cork")
	if pins["hour"] == "":
		missing.append("at which hour they pressed the cork")
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
		"Ansel":
			return "the press hand"
		"Brea":
			return "the cork hand"
		"Colm":
			return "the cellar clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"press":
			return "press"
		"cellar":
			return "cellar"
		"bench":
			return "bench"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"press":
			return "Press"
		"cellar":
			return "Cellar"
		"bench":
			return "Bench"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s pressed the cork" % value
		"place":
			return "The cork was pressed in the %s" % place_label(value)
		"hour":
			return "The cork was pressed at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s pressed the cork" % value
		"place":
			return "the cork was pressed in the %s" % place_label(value)
		"hour":
			return "the cork was pressed at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s pressed the cork" % value
		"place":
			return "it was pressed in the %s" % place_label(value)
		"hour":
			return "it was pressed at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"take_seal":
			return "so the cellar would take the seal"
		"spare_wax":
			return "to spare the wax still on the bench"
		"hold_neck":
			return "to hold the neck until the wax cooled"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) pressed the cork in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_place"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) cut the cork on the %s at %s." % [
			model["cutter"],
			role_short(str(model["cutter"])),
			place_label(str(model["cut_place"])),
			model["cut_hour"],
		],
		"%s (%s) turned the screw in the %s." % [
			model["turner"],
			role_short(str(model["turner"])),
			place_label(str(model["screw_place"])),
		],
		"The mallet was hung on the %s." % place_label(str(model["mallet_place"])),
		"The cellar was swept at %s." % model["broom_hour"],
		"The bench was wiped at %s." % model["wipe_hour"],
		"The press was locked at %s." % model["lock_hour"],
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
	return "Who pressed the cork, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they pressed the cork in."


static func cast_line() -> String:
	return "Ansel, press hand    Brea, cork hand    Colm, cellar clerk"


static func ready_line() -> String:
	return "Pin who pressed the cork, the room they pressed it in, and the hour. Then submit."


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
