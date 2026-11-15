extends RefCounted

# The housing.
#
# The player pins three facts about the cutting: who, the room the housing was
# cut in, and the hour. The timeline also records who marked the trench, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the stock, where that turn was made, why the housing was cut, where
# the fillet was hung, when the square was chalked, when the bead was wiped, and
# when the saw was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The housing"
const FILE_CODE := "CW-27"
const BLURB := "The housing left its peg at the joiner's horse. Name who cut the housing, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Ewan", "Maren", "Hollin"]
const PLACES: Array[String] = ["saw", "square", "bead"]
const HOURS: Array[String] = ["76", "77", "78", "79", "80"]
const AIMS: Array[String] = ["take_trench", "spare_trench", "set_trench"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Saw chit",
		"source": "Maren, square hand",
		"text": "Ewan cut the housing. Maren had marked the trench, and the shavings still stuck in the mouth.",
		"literals": [
			{
				"field": "taker",
				"value": "Ewan",
				"phrase": "Ewan cut the housing",
			},
			{
				"field": "marker",
				"value": "Maren",
				"phrase": "Maren had marked the trench",
			},
		],
	},
	{
		"id": "E2",
		"title": "Square sight",
		"source": "Square rail",
		"text": "Ewan cut the housing. The cutting was seen from the square, above the iron rest.",
		"literals": [
			{
				"field": "taker",
				"value": "Ewan",
				"phrase": "Ewan cut the housing",
			},
			{
				"field": "seen_from",
				"value": "square",
				"phrase": "The cutting was seen from the square",
			},
		],
	},
	{
		"id": "E3",
		"title": "Fillet hook",
		"source": "Bead peg",
		"text": "Ewan cut the housing. With the trench true, the fillet was hung on the bead.",
		"literals": [
			{
				"field": "taker",
				"value": "Ewan",
				"phrase": "Ewan cut the housing",
			},
			{
				"field": "fillet_room",
				"value": "bead",
				"phrase": "the fillet was hung on the bead",
			},
		],
	},
	{
		"id": "E4",
		"title": "Trench slate",
		"source": "Saw jaw",
		"text": "The housing was cut in the saw. A fresh edge shows the trench had been marked on the bead.",
		"literals": [
			{
				"field": "place",
				"value": "saw",
				"phrase": "The housing was cut in the saw",
			},
			{
				"field": "mark_room",
				"value": "bead",
				"phrase": "the trench had been marked on the bead",
			},
		],
	},
	{
		"id": "E5",
		"title": "Stock card",
		"source": "Hollin, bead clerk",
		"text": "The housing was cut in the saw. Hollin turned the stock in the square before the trench was offered.",
		"literals": [
			{
				"field": "place",
				"value": "saw",
				"phrase": "The housing was cut in the saw",
			},
			{
				"field": "stock",
				"value": "Hollin",
				"phrase": "Hollin turned the stock",
			},
			{
				"field": "stock_room",
				"value": "square",
				"phrase": "turned the stock in the square",
			},
		],
	},
	{
		"id": "E6",
		"title": "Chalk slip",
		"source": "Square book",
		"text": "The housing was cut in the saw. The square was chalked at 76, and a pale film still sat on the cheek.",
		"literals": [
			{
				"field": "place",
				"value": "saw",
				"phrase": "The housing was cut in the saw",
			},
			{
				"field": "chalk_hour",
				"value": "76",
				"phrase": "The square was chalked at 76",
			},
		],
	},
	{
		"id": "E7",
		"title": "Mark leaf",
		"source": "Mark book",
		"text": "The housing was cut at 78. The trench had been marked at 77, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "78",
				"phrase": "The housing was cut at 78",
			},
			{
				"field": "mark_hour",
				"value": "77",
				"phrase": "The trench had been marked at 77",
			},
		],
	},
	{
		"id": "E8",
		"title": "Trench note",
		"source": "Joiner's horse",
		"text": "The housing was cut at 78. The trench was opened so the bead would take the trench.",
		"literals": [
			{
				"field": "hour",
				"value": "78",
				"phrase": "The housing was cut at 78",
			},
			{
				"field": "aim",
				"value": "take_trench",
				"phrase": "so the bead would take the trench",
			},
		],
	},
	{
		"id": "E9",
		"title": "Hang order",
		"source": "Bead slate",
		"text": "The housing was cut at 78. The bead was wiped at 79, and the saw was hung at 80 once the trench was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "78",
				"phrase": "The housing was cut at 78",
			},
			{
				"field": "wipe_hour",
				"value": "79",
				"phrase": "The bead was wiped at 79",
			},
			{
				"field": "hang_hour",
				"value": "80",
				"phrase": "the saw was hung at 80",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"marker",
		"mark_room",
		"mark_hour",
		"seen_from",
		"stock",
		"aim",
		"stock_room",
		"fillet_room",
		"chalk_hour",
		"wipe_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "marker", "stock":
			return PEOPLE.duplicate()
		"place", "mark_room", "seen_from", "stock_room", "fillet_room":
			return PLACES.duplicate()
		"hour", "mark_hour", "chalk_hour", "wipe_hour", "hang_hour":
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
		missing.append("who cut the housing")
	if pins["place"] == "":
		missing.append("where they cut the housing")
	if pins["hour"] == "":
		missing.append("at which hour they cut the housing")
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
		"Ewan":
			return "the saw hand"
		"Maren":
			return "the square hand"
		"Hollin":
			return "the bead clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"saw":
			return "saw"
		"square":
			return "square"
		"bead":
			return "bead"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"saw":
			return "Saw"
		"square":
			return "Square"
		"bead":
			return "Bead"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the housing" % value
		"place":
			return "The housing was cut in the %s" % place_label(value)
		"hour":
			return "The housing was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the housing" % value
		"place":
			return "the housing was cut in the %s" % place_label(value)
		"hour":
			return "the housing was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the housing" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_trench":
			return "so the bead would take the trench"
		"spare_trench":
			return "to spare the trench still waiting on the bead"
		"set_trench":
			return "to set the trench before the saw was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the housing in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the trench on the %s at %s." % [
			model["marker"],
			role_short(str(model["marker"])),
			place_label(str(model["mark_room"])),
			model["mark_hour"],
		],
		"%s (%s) turned the stock in the %s." % [
			model["stock"],
			role_short(str(model["stock"])),
			place_label(str(model["stock_room"])),
		],
		"The fillet was hung on the %s." % place_label(str(model["fillet_room"])),
		"The square was chalked at %s." % model["chalk_hour"],
		"The bead was wiped at %s." % model["wipe_hour"],
		"The saw was hung at %s." % model["hang_hour"],
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
	return "Who cut the housing, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the housing in."


static func cast_line() -> String:
	return "Ewan, saw hand    Maren, square hand    Hollin, bead clerk"


static func ready_line() -> String:
	return "Pin who cut the housing, the room they cut it in, and the hour. Then submit."


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
