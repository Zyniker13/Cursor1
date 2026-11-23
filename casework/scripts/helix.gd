extends RefCounted

# The helix.
#
# The player pins three facts about the cutting: who, the room the helix was
# cut in, and the hour. The timeline also records who marked the limba, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the chantry, where that turn was made, why the helix was cut, where
# the merbau was hung, when the chantry was frankincensed, when the maebiki was shellacked, and
# when the crypt was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The helix"
const FILE_CODE := "CW-66"
const BLURB := "The helix left its peg at the joiner's clasp. Name who cut the helix, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Godwin", "Emma", "Edward"]
const PLACES: Array[String] = ["crypt", "chantry", "maebiki"]
const HOURS: Array[String] = ["271", "272", "273", "274", "275"]
const AIMS: Array[String] = ["take_limba", "spare_limba", "set_limba"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Limba chit",
		"source": "Emma, limba hand",
		"text": "Godwin cut the helix. Emma had marked the limba, and a pale palmatine still clung to the helix.",
		"literals": [
			{
				"field": "taker",
				"value": "Godwin",
				"phrase": "Godwin cut the helix",
			},
			{
				"field": "limba",
				"value": "Emma",
				"phrase": "Emma had marked the limba",
			},
		],
	},
	{
		"id": "E2",
		"title": "Baicalein sight",
		"source": "Chantry baicalein",
		"text": "Godwin cut the helix. The helixing was seen from the chantry, beside the open limba.",
		"literals": [
			{
				"field": "taker",
				"value": "Godwin",
				"phrase": "Godwin cut the helix",
			},
			{
				"field": "seen_from",
				"value": "chantry",
				"phrase": "The helixing was seen from the chantry",
			},
		],
	},
	{
		"id": "E3",
		"title": "Merbau bill",
		"source": "Maebiki nose",
		"text": "Godwin cut the helix. With the limba true, the merbau was hung on the maebiki.",
		"literals": [
			{
				"field": "taker",
				"value": "Godwin",
				"phrase": "Godwin cut the helix",
			},
			{
				"field": "merbau_room",
				"value": "maebiki",
				"phrase": "the merbau was hung on the maebiki",
			},
		],
	},
	{
		"id": "E4",
		"title": "Coptisine slate",
		"source": "Crypt coptisine",
		"text": "The helix was cut in the crypt. A fresh coptisine shows the limba had been marked on the maebiki.",
		"literals": [
			{
				"field": "place",
				"value": "crypt",
				"phrase": "The helix was cut in the crypt",
			},
			{
				"field": "limba_room",
				"value": "maebiki",
				"phrase": "the limba had been marked on the maebiki",
			},
		],
	},
	{
		"id": "E5",
		"title": "Chantry card",
		"source": "Edward, chantry clerk",
		"text": "The helix was cut in the crypt. Edward turned the chantry in the crypt once the limba was offered.",
		"literals": [
			{
				"field": "place",
				"value": "crypt",
				"phrase": "The helix was cut in the crypt",
			},
			{
				"field": "chantry",
				"value": "Edward",
				"phrase": "Edward turned the chantry",
			},
			{
				"field": "chantry_room",
				"value": "crypt",
				"phrase": "turned the chantry in the crypt",
			},
		],
	},
	{
		"id": "E6",
		"title": "Frankincensed slip",
		"source": "Chantry tote",
		"text": "The helix was cut in the crypt. The chantry was frankincensed at 271, and a pale mangiferin still sat on the helix.",
		"literals": [
			{
				"field": "place",
				"value": "crypt",
				"phrase": "The helix was cut in the crypt",
			},
			{
				"field": "frankincense_hour",
				"value": "271",
				"phrase": "The chantry was frankincensed at 271",
			},
		],
	},
	{
		"id": "E7",
		"title": "Helix leaf",
		"source": "Limba book",
		"text": "The helix was cut at 273. The limba had been marked at 272, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "273",
				"phrase": "The helix was cut at 273",
			},
			{
				"field": "limba_hour",
				"value": "272",
				"phrase": "The limba had been marked at 272",
			},
		],
	},
	{
		"id": "E8",
		"title": "Clasp note",
		"source": "Joiner's clasp",
		"text": "The helix was cut at 273. The limba was opened so the limba would take the helix.",
		"literals": [
			{
				"field": "hour",
				"value": "273",
				"phrase": "The helix was cut at 273",
			},
			{
				"field": "aim",
				"value": "take_limba",
				"phrase": "so the limba would take the helix",
			},
		],
	},
	{
		"id": "E9",
		"title": "Shellacked order",
		"source": "Maebiki card",
		"text": "The helix was cut at 273. The maebiki was shellacked at 274, and the crypt was hung at 275 once the limba was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "273",
				"phrase": "The helix was cut at 273",
			},
			{
				"field": "shellac_hour",
				"value": "274",
				"phrase": "The maebiki was shellacked at 274",
			},
			{
				"field": "hang_hour",
				"value": "275",
				"phrase": "the crypt was hung at 275",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"limba",
		"limba_room",
		"limba_hour",
		"seen_from",
		"chantry",
		"aim",
		"chantry_room",
		"merbau_room",
		"frankincense_hour",
		"shellac_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "limba", "chantry":
			return PEOPLE.duplicate()
		"place", "limba_room", "seen_from", "chantry_room", "merbau_room":
			return PLACES.duplicate()
		"hour", "limba_hour", "frankincense_hour", "shellac_hour", "hang_hour":
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
		missing.append("who cut the helix")
	if pins["place"] == "":
		missing.append("where they cut the helix")
	if pins["hour"] == "":
		missing.append("at which hour they cut the helix")
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
		"Godwin":
			return "the helix hand"
		"Emma":
			return "the limba hand"
		"Edward":
			return "the chantry clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"crypt":
			return "crypt"
		"chantry":
			return "chantry"
		"maebiki":
			return "maebiki"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"crypt":
			return "Crypt"
		"chantry":
			return "Chantry"
		"maebiki":
			return "Maebiki"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the helix" % value
		"place":
			return "The helix was cut in the %s" % place_label(value)
		"hour":
			return "The helix was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the helix" % value
		"place":
			return "the helix was cut in the %s" % place_label(value)
		"hour":
			return "the helix was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the helix" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_limba":
			return "so the limba would take the helix"
		"spare_limba":
			return "to spare the limba still waiting on the helix"
		"set_limba":
			return "to set the limba before the crypt was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the helix in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the limba on the %s at %s." % [
			model["limba"],
			role_short(str(model["limba"])),
			place_label(str(model["limba_room"])),
			model["limba_hour"],
		],
		"%s (%s) turned the chantry in the %s." % [
			model["chantry"],
			role_short(str(model["chantry"])),
			place_label(str(model["chantry_room"])),
		],
		"The merbau was hung on the %s." % place_label(str(model["merbau_room"])),
		"The chantry was frankincensed at %s." % model["frankincense_hour"],
		"The maebiki was shellacked at %s." % model["shellac_hour"],
		"The crypt was hung at %s." % model["hang_hour"],
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
	return "Who cut the helix, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the helix in."


static func cast_line() -> String:
	return "Godwin, helix hand    Emma, limba hand    Edward, chantry clerk"


static func ready_line() -> String:
	return "Pin who cut the helix, the room they cut it in, and the hour. Then submit."


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
