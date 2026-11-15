extends RefCounted

# The wick trim.
#
# The player pins three facts about the trim: who, the room the wick was
# trimmed in, and the hour. The timeline also records who filled the oil,
# where and at which hour it was filled, who kept the lamp watch, at which
# hour and in which room the watch was kept, where the trim was seen from,
# why the wick was trimmed, where the snuffer was hung, when the gallery lamp
# was lit, and when the stair lamp was put out. Who, the room, and the hour
# are each shared by three exhibits. Five hours are on the board, and the
# trim is the middle one. Two exhibits each state two hidden facts. Each
# exhibit states one of the three pins (a value at least one other exhibit
# also states) and at least one fact no other exhibit states. Exactly one
# full timeline fits every exhibit. Drop any exhibit and another timeline
# fits. Any other pin triple disagrees with at least two exhibits.

const TITLE := "The wick trim"
const FILE_CODE := "CW-15"
const BLURB := "The wick trim left its peg at the lamp house. Name who trimmed it, the room they trimmed it in, and the hour."

const PEOPLE: Array[String] = ["Mara", "Quin", "Sable"]
const PLACES: Array[String] = ["gallery", "stair", "loft"]
const HOURS: Array[String] = ["2", "3", "4", "5", "6"]
const PURPOSES: Array[String] = ["hold_fog", "spare_oil", "darken_stair"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Oil note",
		"source": "Mara, oil hand",
		"text": "Quin trimmed the wick. Mara filled the lamp oil.",
		"literals": [
			{
				"field": "taker",
				"value": "Quin",
				"phrase": "Quin trimmed the wick",
			},
			{
				"field": "oiler",
				"value": "Mara",
				"phrase": "Mara filled the lamp oil",
			},
		],
	},
	{
		"id": "E2",
		"title": "Gallery glass",
		"source": "Gallery window",
		"text": "Quin trimmed the wick. The trim was seen from the gallery.",
		"literals": [
			{
				"field": "taker",
				"value": "Quin",
				"phrase": "Quin trimmed the wick",
			},
			{
				"field": "seen_from",
				"value": "gallery",
				"phrase": "The trim was seen from the gallery",
			},
		],
	},
	{
		"id": "E3",
		"title": "Hook slip",
		"source": "Stair hook",
		"text": "Quin trimmed the wick. The snuffer was hung in the stair.",
		"literals": [
			{
				"field": "taker",
				"value": "Quin",
				"phrase": "Quin trimmed the wick",
			},
			{
				"field": "snuffer_place",
				"value": "stair",
				"phrase": "The snuffer was hung in the stair",
			},
		],
	},
	{
		"id": "E4",
		"title": "Loft board",
		"source": "Loft lamp",
		"text": "The wick was trimmed in the loft. The lamp oil was filled in the stair.",
		"literals": [
			{
				"field": "place",
				"value": "loft",
				"phrase": "The wick was trimmed in the loft",
			},
			{
				"field": "oil_place",
				"value": "stair",
				"phrase": "The lamp oil was filled in the stair",
			},
		],
	},
	{
		"id": "E5",
		"title": "Watch margin",
		"source": "Sable, lamp watch",
		"text": "The wick was trimmed in the loft. Sable kept the lamp watch, and the lamp watch was kept in the gallery.",
		"literals": [
			{
				"field": "place",
				"value": "loft",
				"phrase": "The wick was trimmed in the loft",
			},
			{
				"field": "watcher",
				"value": "Sable",
				"phrase": "Sable kept the lamp watch",
			},
			{
				"field": "watch_place",
				"value": "gallery",
				"phrase": "the lamp watch was kept in the gallery",
			},
		],
	},
	{
		"id": "E6",
		"title": "Fill chit",
		"source": "Oil book",
		"text": "The wick was trimmed in the loft. The lamp oil was filled at 2.",
		"literals": [
			{
				"field": "place",
				"value": "loft",
				"phrase": "The wick was trimmed in the loft",
			},
			{
				"field": "oil_hour",
				"value": "2",
				"phrase": "The lamp oil was filled at 2",
			},
		],
	},
	{
		"id": "E7",
		"title": "Watch leaf",
		"source": "Trim book",
		"text": "The wick was trimmed at 4. The lamp watch was kept at 3.",
		"literals": [
			{
				"field": "hour",
				"value": "4",
				"phrase": "The wick was trimmed at 4",
			},
			{
				"field": "watch_hour",
				"value": "3",
				"phrase": "The lamp watch was kept at 3",
			},
		],
	},
	{
		"id": "E8",
		"title": "Fog line",
		"source": "Lamp house",
		"text": "The wick was trimmed at 4. The wick was trimmed so the lamp would hold through the fog.",
		"literals": [
			{
				"field": "hour",
				"value": "4",
				"phrase": "The wick was trimmed at 4",
			},
			{
				"field": "purpose",
				"value": "hold_fog",
				"phrase": "so the lamp would hold through the fog",
			},
		],
	},
	{
		"id": "E9",
		"title": "Lamp order",
		"source": "Night book",
		"text": "The wick was trimmed at 4. The gallery lamp was lit at 5, and the stair lamp was put out at 6.",
		"literals": [
			{
				"field": "hour",
				"value": "4",
				"phrase": "The wick was trimmed at 4",
			},
			{
				"field": "gallery_hour",
				"value": "5",
				"phrase": "The gallery lamp was lit at 5",
			},
			{
				"field": "stair_hour",
				"value": "6",
				"phrase": "the stair lamp was put out at 6",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"oiler",
		"oil_place",
		"oil_hour",
		"watcher",
		"watch_hour",
		"seen_from",
		"purpose",
		"watch_place",
		"snuffer_place",
		"gallery_hour",
		"stair_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "oiler", "watcher":
			return PEOPLE.duplicate()
		"place", "oil_place", "seen_from", "watch_place", "snuffer_place":
			return PLACES.duplicate()
		"hour", "oil_hour", "watch_hour", "gallery_hour", "stair_hour":
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
		missing.append("who trimmed the wick")
	if pins["place"] == "":
		missing.append("where they trimmed the wick")
	if pins["hour"] == "":
		missing.append("at which hour they trimmed the wick")
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
		"Mara":
			return "the oil hand"
		"Quin":
			return "the wick hand"
		"Sable":
			return "the lamp watch"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"gallery":
			return "gallery"
		"stair":
			return "stair"
		"loft":
			return "loft"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"gallery":
			return "Gallery"
		"stair":
			return "Stair"
		"loft":
			return "Loft"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s trimmed the wick" % value
		"place":
			return "The wick was trimmed in the %s" % place_label(value)
		"hour":
			return "The wick was trimmed at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s trimmed the wick" % value
		"place":
			return "the wick was trimmed in the %s" % place_label(value)
		"hour":
			return "the wick was trimmed at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s trimmed the wick" % value
		"place":
			return "it was trimmed in the %s" % place_label(value)
		"hour":
			return "it was trimmed at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"hold_fog":
			return "so the lamp would hold through the fog"
		"spare_oil":
			return "to spare the remaining oil"
		"darken_stair":
			return "to darken the stair early"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) trimmed the wick in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) filled the lamp oil at %s in the %s." % [
			model["oiler"],
			role_short(str(model["oiler"])),
			model["oil_hour"],
			place_label(str(model["oil_place"])),
		],
		"%s (%s) kept the lamp watch at %s in the %s." % [
			model["watcher"],
			role_short(str(model["watcher"])),
			model["watch_hour"],
			place_label(str(model["watch_place"])),
		],
		"The snuffer was hung in the %s." % place_label(str(model["snuffer_place"])),
		"The gallery lamp was lit at %s." % model["gallery_hour"],
		"The stair lamp was put out at %s." % model["stair_hour"],
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
	return "Who trimmed the wick, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they trimmed the wick in."


static func cast_line() -> String:
	return "Mara, oil hand    Quin, wick hand    Sable, lamp watch"


static func ready_line() -> String:
	return "Pin who trimmed the wick, the room they trimmed it in, and the hour. Then submit."


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
