extends RefCounted

# The strapwork.
#
# The player pins three facts about the cutting: who, the room the strapwork was
# cut in, and the hour. The timeline also records who marked the afara, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the parvis, where that turn was made, why the strapwork was cut, where
# the bocote was hung, when the parvis was sagapenumed, when the yokobiki was gugguled, and
# when the buttery was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The strapwork"
const FILE_CODE := "CW-73"
const BLURB := "The strapwork left its peg at the joiner's spile. Name who cut the strapwork, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Edmund", "Alice", "Cecily"]
const PLACES: Array[String] = ["buttery", "parvis", "yokobiki"]
const HOURS: Array[String] = ["306", "307", "308", "309", "310"]
const AIMS: Array[String] = ["take_afara", "spare_afara", "set_afara"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Afara chit",
		"source": "Alice, afara hand",
		"text": "Edmund cut the strapwork. Alice had marked the afara, and a pale vestitol still clung to the strapwork.",
		"literals": [
			{
				"field": "taker",
				"value": "Edmund",
				"phrase": "Edmund cut the strapwork",
			},
			{
				"field": "afara",
				"value": "Alice",
				"phrase": "Alice had marked the afara",
			},
		],
	},
	{
		"id": "E2",
		"title": "Maackiain sight",
		"source": "Parvis maackiain",
		"text": "Edmund cut the strapwork. The strapworking was seen from the parvis, beside the open afara.",
		"literals": [
			{
				"field": "taker",
				"value": "Edmund",
				"phrase": "Edmund cut the strapwork",
			},
			{
				"field": "seen_from",
				"value": "parvis",
				"phrase": "The strapworking was seen from the parvis",
			},
		],
	},
	{
		"id": "E3",
		"title": "Bocote bill",
		"source": "Yokobiki nose",
		"text": "Edmund cut the strapwork. With the afara true, the bocote was hung on the yokobiki.",
		"literals": [
			{
				"field": "taker",
				"value": "Edmund",
				"phrase": "Edmund cut the strapwork",
			},
			{
				"field": "bocote_room",
				"value": "yokobiki",
				"phrase": "the bocote was hung on the yokobiki",
			},
		],
	},
	{
		"id": "E4",
		"title": "Genistin slate",
		"source": "Buttery genistin",
		"text": "The strapwork was cut in the buttery. A fresh genistin shows the afara had been marked on the yokobiki.",
		"literals": [
			{
				"field": "place",
				"value": "buttery",
				"phrase": "The strapwork was cut in the buttery",
			},
			{
				"field": "afara_room",
				"value": "yokobiki",
				"phrase": "the afara had been marked on the yokobiki",
			},
		],
	},
	{
		"id": "E5",
		"title": "Parvis card",
		"source": "Cecily, parvis clerk",
		"text": "The strapwork was cut in the buttery. Cecily turned the parvis in the buttery once the afara was offered.",
		"literals": [
			{
				"field": "place",
				"value": "buttery",
				"phrase": "The strapwork was cut in the buttery",
			},
			{
				"field": "parvis",
				"value": "Cecily",
				"phrase": "Cecily turned the parvis",
			},
			{
				"field": "parvis_room",
				"value": "buttery",
				"phrase": "turned the parvis in the buttery",
			},
		],
	},
	{
		"id": "E6",
		"title": "Sagapenumed slip",
		"source": "Parvis tote",
		"text": "The strapwork was cut in the buttery. The parvis was sagapenumed at 306, and a pale trifolirhizin still sat on the strapwork.",
		"literals": [
			{
				"field": "place",
				"value": "buttery",
				"phrase": "The strapwork was cut in the buttery",
			},
			{
				"field": "sagapenum_hour",
				"value": "306",
				"phrase": "The parvis was sagapenumed at 306",
			},
		],
	},
	{
		"id": "E7",
		"title": "Strapwork leaf",
		"source": "Afara book",
		"text": "The strapwork was cut at 308. The afara had been marked at 307, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "308",
				"phrase": "The strapwork was cut at 308",
			},
			{
				"field": "afara_hour",
				"value": "307",
				"phrase": "The afara had been marked at 307",
			},
		],
	},
	{
		"id": "E8",
		"title": "Spile note",
		"source": "Joiner's spile",
		"text": "The strapwork was cut at 308. The afara was opened so the afara would take the strapwork.",
		"literals": [
			{
				"field": "hour",
				"value": "308",
				"phrase": "The strapwork was cut at 308",
			},
			{
				"field": "aim",
				"value": "take_afara",
				"phrase": "so the afara would take the strapwork",
			},
		],
	},
	{
		"id": "E9",
		"title": "Gugguled order",
		"source": "Yokobiki card",
		"text": "The strapwork was cut at 308. The yokobiki was gugguled at 309, and the buttery was hung at 310 once the afara was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "308",
				"phrase": "The strapwork was cut at 308",
			},
			{
				"field": "guggul_hour",
				"value": "309",
				"phrase": "The yokobiki was gugguled at 309",
			},
			{
				"field": "hang_hour",
				"value": "310",
				"phrase": "the buttery was hung at 310",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"afara",
		"afara_room",
		"afara_hour",
		"seen_from",
		"parvis",
		"aim",
		"parvis_room",
		"bocote_room",
		"sagapenum_hour",
		"guggul_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "afara", "parvis":
			return PEOPLE.duplicate()
		"place", "afara_room", "seen_from", "parvis_room", "bocote_room":
			return PLACES.duplicate()
		"hour", "afara_hour", "sagapenum_hour", "guggul_hour", "hang_hour":
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
		missing.append("who cut the strapwork")
	if pins["place"] == "":
		missing.append("where they cut the strapwork")
	if pins["hour"] == "":
		missing.append("at which hour they cut the strapwork")
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
		"Edmund":
			return "the strapwork hand"
		"Alice":
			return "the afara hand"
		"Cecily":
			return "the parvis clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"buttery":
			return "buttery"
		"parvis":
			return "parvis"
		"yokobiki":
			return "yokobiki"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"buttery":
			return "Buttery"
		"parvis":
			return "Parvis"
		"yokobiki":
			return "Yokobiki"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the strapwork" % value
		"place":
			return "The strapwork was cut in the %s" % place_label(value)
		"hour":
			return "The strapwork was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the strapwork" % value
		"place":
			return "the strapwork was cut in the %s" % place_label(value)
		"hour":
			return "the strapwork was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the strapwork" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_afara":
			return "so the afara would take the strapwork"
		"spare_afara":
			return "to spare the afara still waiting on the strapwork"
		"set_afara":
			return "to set the afara before the buttery was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the strapwork in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the afara on the %s at %s." % [
			model["afara"],
			role_short(str(model["afara"])),
			place_label(str(model["afara_room"])),
			model["afara_hour"],
		],
		"%s (%s) turned the parvis in the %s." % [
			model["parvis"],
			role_short(str(model["parvis"])),
			place_label(str(model["parvis_room"])),
		],
		"The bocote was hung on the %s." % place_label(str(model["bocote_room"])),
		"The parvis was sagapenumed at %s." % model["sagapenum_hour"],
		"The yokobiki was gugguled at %s." % model["guggul_hour"],
		"The buttery was hung at %s." % model["hang_hour"],
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
	return "Who cut the strapwork, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the strapwork in."


static func cast_line() -> String:
	return "Edmund, strapwork hand    Alice, afara hand    Cecily, parvis clerk"


static func ready_line() -> String:
	return "Pin who cut the strapwork, the room they cut it in, and the hour. Then submit."


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
