extends RefCounted

# The reed.
#
# The player pins three facts about the cutting: who, the room the reed was
# cut in, and the hour. The timeline also records who marked the walnut, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the nosing, where that turn was made, why the reed was cut, where
# the maple was hung, when the nosing was blued, when the rounder was tempered, and
# when the ogee was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The reed"
const FILE_CODE := "CW-44"
const BLURB := "The reed left its peg at the joiner's weanling. Name who cut the reed, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Greta", "Nolan", "Celia"]
const PLACES: Array[String] = ["ogee", "nosing", "rounder"]
const HOURS: Array[String] = ["161", "162", "163", "164", "165"]
const AIMS: Array[String] = ["take_walnut", "spare_walnut", "set_walnut"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Walnut chit",
		"source": "Nolan, walnut hand",
		"text": "Greta cut the reed. Nolan had marked the walnut, and a pale oak still clung to the reed.",
		"literals": [
			{
				"field": "taker",
				"value": "Greta",
				"phrase": "Greta cut the reed",
			},
			{
				"field": "walnut",
				"value": "Nolan",
				"phrase": "Nolan had marked the walnut",
			},
		],
	},
	{
		"id": "E2",
		"title": "Deal sight",
		"source": "Nosing deal",
		"text": "Greta cut the reed. The reeding was seen from the nosing, beside the open walnut.",
		"literals": [
			{
				"field": "taker",
				"value": "Greta",
				"phrase": "Greta cut the reed",
			},
			{
				"field": "seen_from",
				"value": "nosing",
				"phrase": "The reeding was seen from the nosing",
			},
		],
	},
	{
		"id": "E3",
		"title": "Maple bill",
		"source": "Rounder nose",
		"text": "Greta cut the reed. With the walnut true, the maple was hung on the rounder.",
		"literals": [
			{
				"field": "taker",
				"value": "Greta",
				"phrase": "Greta cut the reed",
			},
			{
				"field": "maple_room",
				"value": "rounder",
				"phrase": "the maple was hung on the rounder",
			},
		],
	},
	{
		"id": "E4",
		"title": "Larch slate",
		"source": "Ogee larch",
		"text": "The reed was cut in the ogee. A fresh larch shows the walnut had been marked on the rounder.",
		"literals": [
			{
				"field": "place",
				"value": "ogee",
				"phrase": "The reed was cut in the ogee",
			},
			{
				"field": "walnut_room",
				"value": "rounder",
				"phrase": "the walnut had been marked on the rounder",
			},
		],
	},
	{
		"id": "E5",
		"title": "Nosing card",
		"source": "Celia, nosing clerk",
		"text": "The reed was cut in the ogee. Celia turned the nosing in the ogee once the walnut was offered.",
		"literals": [
			{
				"field": "place",
				"value": "ogee",
				"phrase": "The reed was cut in the ogee",
			},
			{
				"field": "nosing",
				"value": "Celia",
				"phrase": "Celia turned the nosing",
			},
			{
				"field": "nosing_room",
				"value": "ogee",
				"phrase": "turned the nosing in the ogee",
			},
		],
	},
	{
		"id": "E6",
		"title": "Blue slip",
		"source": "Nosing tote",
		"text": "The reed was cut in the ogee. The nosing was blued at 161, and a pale elm still sat on the reed.",
		"literals": [
			{
				"field": "place",
				"value": "ogee",
				"phrase": "The reed was cut in the ogee",
			},
			{
				"field": "blue_hour",
				"value": "161",
				"phrase": "The nosing was blued at 161",
			},
		],
	},
	{
		"id": "E7",
		"title": "Reed leaf",
		"source": "Walnut book",
		"text": "The reed was cut at 163. The walnut had been marked at 162, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "163",
				"phrase": "The reed was cut at 163",
			},
			{
				"field": "walnut_hour",
				"value": "162",
				"phrase": "The walnut had been marked at 162",
			},
		],
	},
	{
		"id": "E8",
		"title": "Weanling note",
		"source": "Joiner's weanling",
		"text": "The reed was cut at 163. The walnut was opened so the walnut would take the reed.",
		"literals": [
			{
				"field": "hour",
				"value": "163",
				"phrase": "The reed was cut at 163",
			},
			{
				"field": "aim",
				"value": "take_walnut",
				"phrase": "so the walnut would take the reed",
			},
		],
	},
	{
		"id": "E9",
		"title": "Temper order",
		"source": "Rounder card",
		"text": "The reed was cut at 163. The rounder was tempered at 164, and the ogee was hung at 165 once the walnut was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "163",
				"phrase": "The reed was cut at 163",
			},
			{
				"field": "temper_hour",
				"value": "164",
				"phrase": "The rounder was tempered at 164",
			},
			{
				"field": "hang_hour",
				"value": "165",
				"phrase": "the ogee was hung at 165",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"walnut",
		"walnut_room",
		"walnut_hour",
		"seen_from",
		"nosing",
		"aim",
		"nosing_room",
		"maple_room",
		"blue_hour",
		"temper_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "walnut", "nosing":
			return PEOPLE.duplicate()
		"place", "walnut_room", "seen_from", "nosing_room", "maple_room":
			return PLACES.duplicate()
		"hour", "walnut_hour", "blue_hour", "temper_hour", "hang_hour":
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
		missing.append("who cut the reed")
	if pins["place"] == "":
		missing.append("where they cut the reed")
	if pins["hour"] == "":
		missing.append("at which hour they cut the reed")
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
		"Greta":
			return "the reed hand"
		"Nolan":
			return "the walnut hand"
		"Celia":
			return "the nosing clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"ogee":
			return "ogee"
		"nosing":
			return "nosing"
		"rounder":
			return "rounder"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"ogee":
			return "Ogee"
		"nosing":
			return "Nosing"
		"rounder":
			return "Rounder"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the reed" % value
		"place":
			return "The reed was cut in the %s" % place_label(value)
		"hour":
			return "The reed was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the reed" % value
		"place":
			return "the reed was cut in the %s" % place_label(value)
		"hour":
			return "the reed was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the reed" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_walnut":
			return "so the walnut would take the reed"
		"spare_walnut":
			return "to spare the walnut still waiting on the reed"
		"set_walnut":
			return "to set the walnut before the ogee was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the reed in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the walnut on the %s at %s." % [
			model["walnut"],
			role_short(str(model["walnut"])),
			place_label(str(model["walnut_room"])),
			model["walnut_hour"],
		],
		"%s (%s) turned the nosing in the %s." % [
			model["nosing"],
			role_short(str(model["nosing"])),
			place_label(str(model["nosing_room"])),
		],
		"The maple was hung on the %s." % place_label(str(model["maple_room"])),
		"The nosing was blued at %s." % model["blue_hour"],
		"The rounder was tempered at %s." % model["temper_hour"],
		"The ogee was hung at %s." % model["hang_hour"],
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
	return "Who cut the reed, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the reed in."


static func cast_line() -> String:
	return "Greta, reed hand    Nolan, walnut hand    Celia, nosing clerk"


static func ready_line() -> String:
	return "Pin who cut the reed, the room they cut it in, and the hour. Then submit."


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
