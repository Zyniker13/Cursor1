extends RefCounted

# The listel.
#
# The player pins three facts about the cutting: who, the room the listel was
# cut in, and the hour. The timeline also records who marked the alder, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the trammel, where that turn was made, why the listel was cut, where
# the quince was hung, when the trammel was plated, when the template was doped, and
# when the plinth was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The listel"
const FILE_CODE := "CW-47"
const BLURB := "The listel left its peg at the joiner's jenny. Name who cut the listel, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Giles", "Nora", "Ellis"]
const PLACES: Array[String] = ["plinth", "trammel", "template"]
const HOURS: Array[String] = ["176", "177", "178", "179", "180"]
const AIMS: Array[String] = ["take_alder", "spare_alder", "set_alder"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Alder chit",
		"source": "Nora, alder hand",
		"text": "Giles cut the listel. Nora had marked the alder, and a pale umber still clung to the listel.",
		"literals": [
			{
				"field": "taker",
				"value": "Giles",
				"phrase": "Giles cut the listel",
			},
			{
				"field": "alder",
				"value": "Nora",
				"phrase": "Nora had marked the alder",
			},
		],
	},
	{
		"id": "E2",
		"title": "Flax sight",
		"source": "Trammel flax",
		"text": "Giles cut the listel. The listeling was seen from the trammel, beside the open alder.",
		"literals": [
			{
				"field": "taker",
				"value": "Giles",
				"phrase": "Giles cut the listel",
			},
			{
				"field": "seen_from",
				"value": "trammel",
				"phrase": "The listeling was seen from the trammel",
			},
		],
	},
	{
		"id": "E3",
		"title": "Quince bill",
		"source": "Template nose",
		"text": "Giles cut the listel. With the alder true, the quince was hung on the template.",
		"literals": [
			{
				"field": "taker",
				"value": "Giles",
				"phrase": "Giles cut the listel",
			},
			{
				"field": "quince_room",
				"value": "template",
				"phrase": "the quince was hung on the template",
			},
		],
	},
	{
		"id": "E4",
		"title": "Ochre slate",
		"source": "Plinth ochre",
		"text": "The listel was cut in the plinth. A fresh ochre shows the alder had been marked on the template.",
		"literals": [
			{
				"field": "place",
				"value": "plinth",
				"phrase": "The listel was cut in the plinth",
			},
			{
				"field": "alder_room",
				"value": "template",
				"phrase": "the alder had been marked on the template",
			},
		],
	},
	{
		"id": "E5",
		"title": "Trammel card",
		"source": "Ellis, trammel clerk",
		"text": "The listel was cut in the plinth. Ellis turned the trammel in the plinth once the alder was offered.",
		"literals": [
			{
				"field": "place",
				"value": "plinth",
				"phrase": "The listel was cut in the plinth",
			},
			{
				"field": "trammel",
				"value": "Ellis",
				"phrase": "Ellis turned the trammel",
			},
			{
				"field": "trammel_room",
				"value": "plinth",
				"phrase": "turned the trammel in the plinth",
			},
		],
	},
	{
		"id": "E6",
		"title": "Plate slip",
		"source": "Trammel tote",
		"text": "The listel was cut in the plinth. The trammel was plated at 176, and a pale sienna still sat on the listel.",
		"literals": [
			{
				"field": "place",
				"value": "plinth",
				"phrase": "The listel was cut in the plinth",
			},
			{
				"field": "plate_hour",
				"value": "176",
				"phrase": "The trammel was plated at 176",
			},
		],
	},
	{
		"id": "E7",
		"title": "Listel leaf",
		"source": "Alder book",
		"text": "The listel was cut at 178. The alder had been marked at 177, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "178",
				"phrase": "The listel was cut at 178",
			},
			{
				"field": "alder_hour",
				"value": "177",
				"phrase": "The alder had been marked at 177",
			},
		],
	},
	{
		"id": "E8",
		"title": "Jenny note",
		"source": "Joiner's jenny",
		"text": "The listel was cut at 178. The alder was opened so the alder would take the listel.",
		"literals": [
			{
				"field": "hour",
				"value": "178",
				"phrase": "The listel was cut at 178",
			},
			{
				"field": "aim",
				"value": "take_alder",
				"phrase": "so the alder would take the listel",
			},
		],
	},
	{
		"id": "E9",
		"title": "Dope order",
		"source": "Template card",
		"text": "The listel was cut at 178. The template was doped at 179, and the plinth was hung at 180 once the alder was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "178",
				"phrase": "The listel was cut at 178",
			},
			{
				"field": "dope_hour",
				"value": "179",
				"phrase": "The template was doped at 179",
			},
			{
				"field": "hang_hour",
				"value": "180",
				"phrase": "the plinth was hung at 180",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"alder",
		"alder_room",
		"alder_hour",
		"seen_from",
		"trammel",
		"aim",
		"trammel_room",
		"quince_room",
		"plate_hour",
		"dope_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "alder", "trammel":
			return PEOPLE.duplicate()
		"place", "alder_room", "seen_from", "trammel_room", "quince_room":
			return PLACES.duplicate()
		"hour", "alder_hour", "plate_hour", "dope_hour", "hang_hour":
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
		missing.append("who cut the listel")
	if pins["place"] == "":
		missing.append("where they cut the listel")
	if pins["hour"] == "":
		missing.append("at which hour they cut the listel")
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
		"Giles":
			return "the listel hand"
		"Nora":
			return "the alder hand"
		"Ellis":
			return "the trammel clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"plinth":
			return "plinth"
		"trammel":
			return "trammel"
		"template":
			return "template"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"plinth":
			return "Plinth"
		"trammel":
			return "Trammel"
		"template":
			return "Template"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the listel" % value
		"place":
			return "The listel was cut in the %s" % place_label(value)
		"hour":
			return "The listel was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the listel" % value
		"place":
			return "the listel was cut in the %s" % place_label(value)
		"hour":
			return "the listel was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the listel" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_alder":
			return "so the alder would take the listel"
		"spare_alder":
			return "to spare the alder still waiting on the listel"
		"set_alder":
			return "to set the alder before the plinth was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the listel in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the alder on the %s at %s." % [
			model["alder"],
			role_short(str(model["alder"])),
			place_label(str(model["alder_room"])),
			model["alder_hour"],
		],
		"%s (%s) turned the trammel in the %s." % [
			model["trammel"],
			role_short(str(model["trammel"])),
			place_label(str(model["trammel_room"])),
		],
		"The quince was hung on the %s." % place_label(str(model["quince_room"])),
		"The trammel was plated at %s." % model["plate_hour"],
		"The template was doped at %s." % model["dope_hour"],
		"The plinth was hung at %s." % model["hang_hour"],
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
	return "Who cut the listel, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the listel in."


static func cast_line() -> String:
	return "Giles, listel hand    Nora, alder hand    Ellis, trammel clerk"


static func ready_line() -> String:
	return "Pin who cut the listel, the room they cut it in, and the hour. Then submit."


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
