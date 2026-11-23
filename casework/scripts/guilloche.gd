extends RefCounted

# The guilloche.
#
# The player pins three facts about the cutting: who, the room the guilloche was
# cut in, and the hour. The timeline also records who marked the obeche, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the oriel, where that turn was made, why the guilloche was cut, where
# the ramin was hung, when the oriel was elemed, when the anahiki was galbanumed, and
# when the garret was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The guilloche"
const FILE_CODE := "CW-67"
const BLURB := "The guilloche left its peg at the joiner's cotter. Name who cut the guilloche, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Alfred", "Matilda", "Stephen"]
const PLACES: Array[String] = ["garret", "oriel", "anahiki"]
const HOURS: Array[String] = ["276", "277", "278", "279", "280"]
const AIMS: Array[String] = ["take_obeche", "spare_obeche", "set_obeche"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Obeche chit",
		"source": "Matilda, obeche hand",
		"text": "Alfred cut the guilloche. Matilda had marked the obeche, and a pale wogonin still clung to the guilloche.",
		"literals": [
			{
				"field": "taker",
				"value": "Alfred",
				"phrase": "Alfred cut the guilloche",
			},
			{
				"field": "obeche",
				"value": "Matilda",
				"phrase": "Matilda had marked the obeche",
			},
		],
	},
	{
		"id": "E2",
		"title": "Taxifolin sight",
		"source": "Oriel taxifolin",
		"text": "Alfred cut the guilloche. The guilloching was seen from the oriel, beside the open obeche.",
		"literals": [
			{
				"field": "taker",
				"value": "Alfred",
				"phrase": "Alfred cut the guilloche",
			},
			{
				"field": "seen_from",
				"value": "oriel",
				"phrase": "The guilloching was seen from the oriel",
			},
		],
	},
	{
		"id": "E3",
		"title": "Ramin bill",
		"source": "Anahiki nose",
		"text": "Alfred cut the guilloche. With the obeche true, the ramin was hung on the anahiki.",
		"literals": [
			{
				"field": "taker",
				"value": "Alfred",
				"phrase": "Alfred cut the guilloche",
			},
			{
				"field": "ramin_room",
				"value": "anahiki",
				"phrase": "the ramin was hung on the anahiki",
			},
		],
	},
	{
		"id": "E4",
		"title": "Nobiletin slate",
		"source": "Garret nobiletin",
		"text": "The guilloche was cut in the garret. A fresh nobiletin shows the obeche had been marked on the anahiki.",
		"literals": [
			{
				"field": "place",
				"value": "garret",
				"phrase": "The guilloche was cut in the garret",
			},
			{
				"field": "obeche_room",
				"value": "anahiki",
				"phrase": "the obeche had been marked on the anahiki",
			},
		],
	},
	{
		"id": "E5",
		"title": "Oriel card",
		"source": "Stephen, oriel clerk",
		"text": "The guilloche was cut in the garret. Stephen turned the oriel in the garret once the obeche was offered.",
		"literals": [
			{
				"field": "place",
				"value": "garret",
				"phrase": "The guilloche was cut in the garret",
			},
			{
				"field": "oriel",
				"value": "Stephen",
				"phrase": "Stephen turned the oriel",
			},
			{
				"field": "oriel_room",
				"value": "garret",
				"phrase": "turned the oriel in the garret",
			},
		],
	},
	{
		"id": "E6",
		"title": "Elemed slip",
		"source": "Oriel tote",
		"text": "The guilloche was cut in the garret. The oriel was elemed at 276, and a pale hesperetin still sat on the guilloche.",
		"literals": [
			{
				"field": "place",
				"value": "garret",
				"phrase": "The guilloche was cut in the garret",
			},
			{
				"field": "elemi_hour",
				"value": "276",
				"phrase": "The oriel was elemed at 276",
			},
		],
	},
	{
		"id": "E7",
		"title": "Guilloche leaf",
		"source": "Obeche book",
		"text": "The guilloche was cut at 278. The obeche had been marked at 277, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "278",
				"phrase": "The guilloche was cut at 278",
			},
			{
				"field": "obeche_hour",
				"value": "277",
				"phrase": "The obeche had been marked at 277",
			},
		],
	},
	{
		"id": "E8",
		"title": "Cotter note",
		"source": "Joiner's cotter",
		"text": "The guilloche was cut at 278. The obeche was opened so the obeche would take the guilloche.",
		"literals": [
			{
				"field": "hour",
				"value": "278",
				"phrase": "The guilloche was cut at 278",
			},
			{
				"field": "aim",
				"value": "take_obeche",
				"phrase": "so the obeche would take the guilloche",
			},
		],
	},
	{
		"id": "E9",
		"title": "Galbanumed order",
		"source": "Anahiki card",
		"text": "The guilloche was cut at 278. The anahiki was galbanumed at 279, and the garret was hung at 280 once the obeche was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "278",
				"phrase": "The guilloche was cut at 278",
			},
			{
				"field": "galbanum_hour",
				"value": "279",
				"phrase": "The anahiki was galbanumed at 279",
			},
			{
				"field": "hang_hour",
				"value": "280",
				"phrase": "the garret was hung at 280",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"obeche",
		"obeche_room",
		"obeche_hour",
		"seen_from",
		"oriel",
		"aim",
		"oriel_room",
		"ramin_room",
		"elemi_hour",
		"galbanum_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "obeche", "oriel":
			return PEOPLE.duplicate()
		"place", "obeche_room", "seen_from", "oriel_room", "ramin_room":
			return PLACES.duplicate()
		"hour", "obeche_hour", "elemi_hour", "galbanum_hour", "hang_hour":
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
		missing.append("who cut the guilloche")
	if pins["place"] == "":
		missing.append("where they cut the guilloche")
	if pins["hour"] == "":
		missing.append("at which hour they cut the guilloche")
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
		"Alfred":
			return "the guilloche hand"
		"Matilda":
			return "the obeche hand"
		"Stephen":
			return "the oriel clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"garret":
			return "garret"
		"oriel":
			return "oriel"
		"anahiki":
			return "anahiki"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"garret":
			return "Garret"
		"oriel":
			return "Oriel"
		"anahiki":
			return "Anahiki"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the guilloche" % value
		"place":
			return "The guilloche was cut in the %s" % place_label(value)
		"hour":
			return "The guilloche was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the guilloche" % value
		"place":
			return "the guilloche was cut in the %s" % place_label(value)
		"hour":
			return "the guilloche was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the guilloche" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_obeche":
			return "so the obeche would take the guilloche"
		"spare_obeche":
			return "to spare the obeche still waiting on the guilloche"
		"set_obeche":
			return "to set the obeche before the garret was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the guilloche in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the obeche on the %s at %s." % [
			model["obeche"],
			role_short(str(model["obeche"])),
			place_label(str(model["obeche_room"])),
			model["obeche_hour"],
		],
		"%s (%s) turned the oriel in the %s." % [
			model["oriel"],
			role_short(str(model["oriel"])),
			place_label(str(model["oriel_room"])),
		],
		"The ramin was hung on the %s." % place_label(str(model["ramin_room"])),
		"The oriel was elemed at %s." % model["elemi_hour"],
		"The anahiki was galbanumed at %s." % model["galbanum_hour"],
		"The garret was hung at %s." % model["hang_hour"],
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
	return "Who cut the guilloche, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the guilloche in."


static func cast_line() -> String:
	return "Alfred, guilloche hand    Matilda, obeche hand    Stephen, oriel clerk"


static func ready_line() -> String:
	return "Pin who cut the guilloche, the room they cut it in, and the hour. Then submit."


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
