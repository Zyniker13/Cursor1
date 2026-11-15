extends RefCounted

# The rehearsal score.
#
# The player pins three facts about the taking: who, the room the score was
# taken to, and the hour. The timeline also records who saw the taking, where
# that person saw it from, who found the empty shelf, where and at which hour
# it was found, where the score was taken from, why it was taken, and when it
# was logged back. Each exhibit states the true value of one of those three
# pins (a value at least one other exhibit also states) and at least one fact
# no other exhibit states. Exactly one full timeline fits every exhibit. Drop
# any exhibit and another timeline fits. Any other pin triple disagrees with
# at least two exhibits.

const TITLE := "The rehearsal score"
const FILE_CODE := "CW-02"
const BLURB := "The rehearsal score left its shelf at the hall. Name who took it, the room they took it to, and the hour."

const PEOPLE: Array[String] = ["Nia", "Ivo", "Bess"]
const PLACES: Array[String] = ["library", "gallery", "practice_room"]
const HOURS: Array[String] = ["4", "5", "6"]
const PURPOSES: Array[String] = ["mark_cuts", "late_copy", "pitch_check"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Gallery line",
		"source": "Nia, pianist",
		"text": "Ivo, the copyist, is the person who took the rehearsal score. Nia, the pianist, is the person who saw the taking.",
		"literals": [
			{
				"field": "taker",
				"value": "Ivo",
				"phrase": "Ivo, the copyist, is the person who took the rehearsal score",
			},
			{
				"field": "witness",
				"value": "Nia",
				"phrase": "Nia, the pianist, is the person who saw the taking",
			},
		],
	},
	{
		"id": "E2",
		"title": "Shelf card",
		"source": "Library shelf",
		"text": "The rehearsal score was taken to the practice room. 5 is the hour at which the empty shelf was found.",
		"literals": [
			{
				"field": "place",
				"value": "practice_room",
				"phrase": "The rehearsal score was taken to the practice room",
			},
			{
				"field": "find_hour",
				"value": "5",
				"phrase": "5 is the hour at which the empty shelf was found",
			},
		],
	},
	{
		"id": "E3",
		"title": "Library slip",
		"source": "Library",
		"text": "4 is the hour at which the rehearsal score was taken. The rehearsal score was taken from the library.",
		"literals": [
			{
				"field": "hour",
				"value": "4",
				"phrase": "4 is the hour at which the rehearsal score was taken",
			},
			{
				"field": "origin",
				"value": "library",
				"phrase": "The rehearsal score was taken from the library",
			},
		],
	},
	{
		"id": "E4",
		"title": "Cut list",
		"source": "Practice room",
		"text": "Ivo, the copyist, is the person who took the rehearsal score. The rehearsal score was taken in order to mark the cuts.",
		"literals": [
			{
				"field": "taker",
				"value": "Ivo",
				"phrase": "Ivo, the copyist, is the person who took the rehearsal score",
			},
			{
				"field": "purpose",
				"value": "mark_cuts",
				"phrase": "The rehearsal score was taken in order to mark the cuts",
			},
		],
	},
	{
		"id": "E5",
		"title": "Tuner note",
		"source": "Bess, tuner",
		"text": "The rehearsal score was taken to the practice room. Bess, the tuner, is the person who found the shelf empty in the library.",
		"literals": [
			{
				"field": "place",
				"value": "practice_room",
				"phrase": "The rehearsal score was taken to the practice room",
			},
			{
				"field": "finder",
				"value": "Bess",
				"phrase": "Bess, the tuner, is the person who found the shelf empty in the library",
			},
			{
				"field": "find_place",
				"value": "library",
				"phrase": "Bess, the tuner, is the person who found the shelf empty in the library",
			},
		],
	},
	{
		"id": "E6",
		"title": "Gallery margin",
		"source": "Gallery",
		"text": "Ivo, the copyist, is the person who took the rehearsal score. The taking was seen from the gallery.",
		"literals": [
			{
				"field": "taker",
				"value": "Ivo",
				"phrase": "Ivo, the copyist, is the person who took the rehearsal score",
			},
			{
				"field": "witness_place",
				"value": "gallery",
				"phrase": "The taking was seen from the gallery",
			},
		],
	},
	{
		"id": "E7",
		"title": "Shelf return",
		"source": "Library book",
		"text": "4 is the hour at which the rehearsal score was taken. 6 is the hour at which the score was logged back on the shelf.",
		"literals": [
			{
				"field": "hour",
				"value": "4",
				"phrase": "4 is the hour at which the rehearsal score was taken",
			},
			{
				"field": "return_hour",
				"value": "6",
				"phrase": "6 is the hour at which the score was logged back on the shelf",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"witness",
		"witness_place",
		"finder",
		"find_hour",
		"find_place",
		"origin",
		"purpose",
		"return_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "witness", "finder":
			return PEOPLE.duplicate()
		"place", "witness_place", "find_place", "origin":
			return PLACES.duplicate()
		"hour", "find_hour", "return_hour":
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
		missing.append("who took the rehearsal score")
	if pins["place"] == "":
		missing.append("where they took the score")
	if pins["hour"] == "":
		missing.append("at which hour they took the score")
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
		"Nia":
			return "the pianist"
		"Ivo":
			return "the copyist"
		"Bess":
			return "the tuner"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"library":
			return "library"
		"gallery":
			return "gallery"
		"practice_room":
			return "practice room"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"library":
			return "Library"
		"gallery":
			return "Gallery"
		"practice_room":
			return "Practice room"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s, %s, is the person who took the rehearsal score" % [value, role_phrase(value)]
		"place":
			return "The rehearsal score was taken to the %s" % place_label(value)
		"hour":
			return "%s is the hour at which the rehearsal score was taken" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s took the rehearsal score" % value
		"place":
			return "the rehearsal score was taken to the %s" % place_label(value)
		"hour":
			return "the rehearsal score was taken at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s took the rehearsal score" % value
		"place":
			return "it was taken to the %s" % place_label(value)
		"hour":
			return "it was taken at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"mark_cuts":
			return "to mark the cuts"
		"late_copy":
			return "to make a late copy"
		"pitch_check":
			return "to check the pitch"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) took the rehearsal score at %s from the %s to the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			model["hour"],
			place_label(str(model["origin"])),
			place_label(str(model["place"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) saw the taking from the %s." % [
			model["witness"],
			role_short(str(model["witness"])),
			place_label(str(model["witness_place"])),
		],
		"%s (%s) found the shelf empty at %s in the %s." % [
			model["finder"],
			role_short(str(model["finder"])),
			model["find_hour"],
			place_label(str(model["find_place"])),
		],
		"The score was logged back on the shelf at %s." % model["return_hour"],
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
	return "The file  ·  seven exhibits"


static func board_question() -> String:
	return "Who took the rehearsal score, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they took the score to."


static func cast_line() -> String:
	return "Nia, pianist    Ivo, copyist    Bess, tuner"


static func ready_line() -> String:
	return "Pin who took the rehearsal score, the room they took it to, and the hour. Then submit."


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
