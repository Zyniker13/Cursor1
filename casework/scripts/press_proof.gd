extends RefCounted

# The press proof.
#
# The player pins three facts about the taking: who, the room the proof was
# taken to, and the hour. The timeline also records who damped the sheet,
# where and at which hour it was damped, who lifted the chase, at which hour
# the chase was lifted, where the proof was taken from, why it was taken,
# where the furniture was planed, when the frisket was cut, and when the
# tympan was closed. The taker is the pin four exhibits share. The room and
# the hour are each shared by two. Five hours are on the board, and the
# taking is the middle one. Two exhibits each state two hidden facts. Each
# exhibit states one of the three pins (a value at least one other exhibit
# also states) and at least one fact no other exhibit states. Exactly one
# full timeline fits every exhibit. Drop any exhibit and another timeline
# fits. Any other pin triple disagrees with at least two exhibits.

const TITLE := "The press proof"
const FILE_CODE := "CW-09"
const BLURB := "The press proof left its nail at the print shop. Name who took it, the room they took it to, and the hour."

const PEOPLE: Array[String] = ["Cass", "Nim", "Brin"]
const PLACES: Array[String] = ["galley", "wetting_board", "stone"]
const HOURS: Array[String] = ["39", "40", "41", "42", "43"]
const PURPOSES: Array[String] = ["lock_forme", "pull_revise", "mark_bearer"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Lock line",
		"source": "Brin, compositor",
		"text": "Nim, the lockhand, is the person who took the press proof. Brin, the compositor, is the person who damped the sheet.",
		"literals": [
			{
				"field": "taker",
				"value": "Nim",
				"phrase": "Nim, the lockhand, is the person who took the press proof",
			},
			{
				"field": "damper",
				"value": "Brin",
				"phrase": "Brin, the compositor, is the person who damped the sheet",
			},
		],
	},
	{
		"id": "E2",
		"title": "Galley tag",
		"source": "Galley",
		"text": "Nim, the lockhand, is the person who took the press proof. The press proof was taken from the galley.",
		"literals": [
			{
				"field": "taker",
				"value": "Nim",
				"phrase": "Nim, the lockhand, is the person who took the press proof",
			},
			{
				"field": "origin",
				"value": "galley",
				"phrase": "The press proof was taken from the galley",
			},
		],
	},
	{
		"id": "E3",
		"title": "Damp card",
		"source": "Wetting board",
		"text": "Nim, the lockhand, is the person who took the press proof. The sheet was damped on the wetting board.",
		"literals": [
			{
				"field": "taker",
				"value": "Nim",
				"phrase": "Nim, the lockhand, is the person who took the press proof",
			},
			{
				"field": "damp_place",
				"value": "wetting_board",
				"phrase": "The sheet was damped on the wetting board",
			},
		],
	},
	{
		"id": "E4",
		"title": "Chase margin",
		"source": "Chase",
		"text": "Nim, the lockhand, is the person who took the press proof. Cass, the reader, is the person who lifted the chase, and the furniture was planed at the galley.",
		"literals": [
			{
				"field": "taker",
				"value": "Nim",
				"phrase": "Nim, the lockhand, is the person who took the press proof",
			},
			{
				"field": "lifter",
				"value": "Cass",
				"phrase": "Cass, the reader, is the person who lifted the chase",
			},
			{
				"field": "plane_place",
				"value": "galley",
				"phrase": "the furniture was planed at the galley",
			},
		],
	},
	{
		"id": "E5",
		"title": "Stone slip",
		"source": "Stone",
		"text": "The press proof was taken to the stone. 39 is the hour at which the sheet was damped.",
		"literals": [
			{
				"field": "place",
				"value": "stone",
				"phrase": "The press proof was taken to the stone",
			},
			{
				"field": "damp_hour",
				"value": "39",
				"phrase": "39 is the hour at which the sheet was damped",
			},
		],
	},
	{
		"id": "E6",
		"title": "Chase slip",
		"source": "Chase bar",
		"text": "The press proof was taken to the stone. 40 is the hour at which the chase was lifted.",
		"literals": [
			{
				"field": "place",
				"value": "stone",
				"phrase": "The press proof was taken to the stone",
			},
			{
				"field": "lift_hour",
				"value": "40",
				"phrase": "40 is the hour at which the chase was lifted",
			},
		],
	},
	{
		"id": "E7",
		"title": "Forme note",
		"source": "Print shop",
		"text": "41 is the hour at which the press proof was taken. The press proof was taken so the forme could not be lifted.",
		"literals": [
			{
				"field": "hour",
				"value": "41",
				"phrase": "41 is the hour at which the press proof was taken",
			},
			{
				"field": "purpose",
				"value": "lock_forme",
				"phrase": "The press proof was taken so the forme could not be lifted",
			},
		],
	},
	{
		"id": "E8",
		"title": "Tympan line",
		"source": "Shop book",
		"text": "41 is the hour at which the press proof was taken. The frisket was cut at 42, and the tympan was closed at 43.",
		"literals": [
			{
				"field": "hour",
				"value": "41",
				"phrase": "41 is the hour at which the press proof was taken",
			},
			{
				"field": "frisket_hour",
				"value": "42",
				"phrase": "The frisket was cut at 42",
			},
			{
				"field": "tympan_hour",
				"value": "43",
				"phrase": "the tympan was closed at 43",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"damper",
		"damp_place",
		"damp_hour",
		"lifter",
		"lift_hour",
		"origin",
		"purpose",
		"plane_place",
		"frisket_hour",
		"tympan_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "damper", "lifter":
			return PEOPLE.duplicate()
		"place", "damp_place", "origin", "plane_place":
			return PLACES.duplicate()
		"hour", "damp_hour", "lift_hour", "frisket_hour", "tympan_hour":
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
		missing.append("who took the press proof")
	if pins["place"] == "":
		missing.append("where they took the proof")
	if pins["hour"] == "":
		missing.append("at which hour they took the proof")
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
		"Cass":
			return "the reader"
		"Nim":
			return "the lockhand"
		"Brin":
			return "the compositor"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"galley":
			return "galley"
		"wetting_board":
			return "wetting board"
		"stone":
			return "stone"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"galley":
			return "Galley"
		"wetting_board":
			return "Wetting board"
		"stone":
			return "Stone"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s, %s, is the person who took the press proof" % [value, role_phrase(value)]
		"place":
			return "The press proof was taken to the %s" % place_label(value)
		"hour":
			return "%s is the hour at which the press proof was taken" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s took the press proof" % value
		"place":
			return "the press proof was taken to the %s" % place_label(value)
		"hour":
			return "the press proof was taken at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s took the press proof" % value
		"place":
			return "it was taken to the %s" % place_label(value)
		"hour":
			return "it was taken at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"lock_forme":
			return "so the forme could not be lifted"
		"pull_revise":
			return "to pull a revise"
		"mark_bearer":
			return "to mark the bearer"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) took the press proof at %s from the %s to the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			model["hour"],
			place_label(str(model["origin"])),
			place_label(str(model["place"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) damped the sheet at %s on the %s." % [
			model["damper"],
			role_short(str(model["damper"])),
			model["damp_hour"],
			place_label(str(model["damp_place"])),
		],
		"%s (%s) lifted the chase at %s." % [
			model["lifter"],
			role_short(str(model["lifter"])),
			model["lift_hour"],
		],
		"The furniture was planed at the %s." % place_label(str(model["plane_place"])),
		"The frisket was cut at %s." % model["frisket_hour"],
		"The tympan was closed at %s." % model["tympan_hour"],
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
	return "The file  ·  eight exhibits"


static func board_question() -> String:
	return "Who took the press proof, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they took the proof to."


static func cast_line() -> String:
	return "Cass, reader    Nim, lockhand    Brin, compositor"


static func ready_line() -> String:
	return "Pin who took the press proof, the room they took it to, and the hour. Then submit."


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
