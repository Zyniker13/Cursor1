extends RefCounted

# The tide ledger.
#
# The player pins three facts about the entry: who, the room the ledger was
# entered on, and the hour. The timeline also records who filled the pen,
# where and at which hour it was filled, who read the tide glass, at which
# hour the glass was read, where the ledger was entered from, why it was
# entered, where the bell was hung, where the glass was read, when the boat
# was called, and when the line was hauled. Who, the room, and the hour are
# each shared by three exhibits. Five hours are on the board, and the entry
# is the middle one. Two exhibits each state two hidden facts. Each exhibit
# states one of the three pins (a value at least one other exhibit also
# states) and at least one fact no other exhibit states. Exactly one full
# timeline fits every exhibit. Drop any exhibit and another timeline fits.
# Any other pin triple disagrees with at least two exhibits.

const TITLE := "The tide ledger"
const FILE_CODE := "CW-12"
const BLURB := "The tide ledger left its desk at the tide house. Name who entered it, the room they entered it on, and the hour."

const PEOPLE: Array[String] = ["Pell", "Moss", "Dory"]
const PLACES: Array[String] = ["mole", "sill", "quay"]
const HOURS: Array[String] = ["31", "32", "33", "34", "35"]
const PURPOSES: Array[String] = ["read_late", "call_early", "mark_flood"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Ledger line",
		"source": "Pell, ink hand",
		"text": "Moss, the tide clerk, is the person who entered the tide ledger. Pell, the ink hand, is the person who filled the pen.",
		"literals": [
			{
				"field": "taker",
				"value": "Moss",
				"phrase": "Moss, the tide clerk, is the person who entered the tide ledger",
			},
			{
				"field": "inker",
				"value": "Pell",
				"phrase": "Pell, the ink hand, is the person who filled the pen",
			},
		],
	},
	{
		"id": "E2",
		"title": "Mole tag",
		"source": "Mole",
		"text": "Moss, the tide clerk, is the person who entered the tide ledger. The tide ledger was entered from the mole.",
		"literals": [
			{
				"field": "taker",
				"value": "Moss",
				"phrase": "Moss, the tide clerk, is the person who entered the tide ledger",
			},
			{
				"field": "origin",
				"value": "mole",
				"phrase": "The tide ledger was entered from the mole",
			},
		],
	},
	{
		"id": "E3",
		"title": "Hang card",
		"source": "Bell peg",
		"text": "Moss, the tide clerk, is the person who entered the tide ledger. The tide bell was hung on the mole.",
		"literals": [
			{
				"field": "taker",
				"value": "Moss",
				"phrase": "Moss, the tide clerk, is the person who entered the tide ledger",
			},
			{
				"field": "hang_place",
				"value": "mole",
				"phrase": "The tide bell was hung on the mole",
			},
		],
	},
	{
		"id": "E4",
		"title": "Sill card",
		"source": "Sill",
		"text": "The tide ledger was entered on the quay. The pen was filled on the sill.",
		"literals": [
			{
				"field": "place",
				"value": "quay",
				"phrase": "The tide ledger was entered on the quay",
			},
			{
				"field": "ink_place",
				"value": "sill",
				"phrase": "The pen was filled on the sill",
			},
		],
	},
	{
		"id": "E5",
		"title": "Glass margin",
		"source": "Tide glass",
		"text": "The tide ledger was entered on the quay. Dory, the bell hand, is the person who read the tide glass, and the tide glass was read on the mole.",
		"literals": [
			{
				"field": "place",
				"value": "quay",
				"phrase": "The tide ledger was entered on the quay",
			},
			{
				"field": "reader",
				"value": "Dory",
				"phrase": "Dory, the bell hand, is the person who read the tide glass",
			},
			{
				"field": "glass_place",
				"value": "mole",
				"phrase": "the tide glass was read on the mole",
			},
		],
	},
	{
		"id": "E6",
		"title": "Ink chit",
		"source": "Ink book",
		"text": "The tide ledger was entered on the quay. 31 is the hour at which the pen was filled.",
		"literals": [
			{
				"field": "place",
				"value": "quay",
				"phrase": "The tide ledger was entered on the quay",
			},
			{
				"field": "ink_hour",
				"value": "31",
				"phrase": "31 is the hour at which the pen was filled",
			},
		],
	},
	{
		"id": "E7",
		"title": "Glass slip",
		"source": "Glass book",
		"text": "33 is the hour at which the tide ledger was entered. 32 is the hour at which the tide glass was read.",
		"literals": [
			{
				"field": "hour",
				"value": "33",
				"phrase": "33 is the hour at which the tide ledger was entered",
			},
			{
				"field": "read_hour",
				"value": "32",
				"phrase": "32 is the hour at which the tide glass was read",
			},
		],
	},
	{
		"id": "E8",
		"title": "Late note",
		"source": "Tide house",
		"text": "33 is the hour at which the tide ledger was entered. The tide ledger was entered so the boat would read late.",
		"literals": [
			{
				"field": "hour",
				"value": "33",
				"phrase": "33 is the hour at which the tide ledger was entered",
			},
			{
				"field": "purpose",
				"value": "read_late",
				"phrase": "The tide ledger was entered so the boat would read late",
			},
		],
	},
	{
		"id": "E9",
		"title": "Call line",
		"source": "Tide book",
		"text": "33 is the hour at which the tide ledger was entered. The boat was called at 34, and the line was hauled at 35.",
		"literals": [
			{
				"field": "hour",
				"value": "33",
				"phrase": "33 is the hour at which the tide ledger was entered",
			},
			{
				"field": "call_hour",
				"value": "34",
				"phrase": "The boat was called at 34",
			},
			{
				"field": "haul_hour",
				"value": "35",
				"phrase": "the line was hauled at 35",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"inker",
		"ink_place",
		"ink_hour",
		"reader",
		"read_hour",
		"origin",
		"purpose",
		"glass_place",
		"hang_place",
		"call_hour",
		"haul_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "inker", "reader":
			return PEOPLE.duplicate()
		"place", "ink_place", "origin", "glass_place", "hang_place":
			return PLACES.duplicate()
		"hour", "ink_hour", "read_hour", "call_hour", "haul_hour":
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
		missing.append("who entered the tide ledger")
	if pins["place"] == "":
		missing.append("where they entered the ledger")
	if pins["hour"] == "":
		missing.append("at which hour they entered the ledger")
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
		"Pell":
			return "the ink hand"
		"Moss":
			return "the tide clerk"
		"Dory":
			return "the bell hand"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"mole":
			return "mole"
		"sill":
			return "sill"
		"quay":
			return "quay"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"mole":
			return "Mole"
		"sill":
			return "Sill"
		"quay":
			return "Quay"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s, %s, is the person who entered the tide ledger" % [value, role_phrase(value)]
		"place":
			return "The tide ledger was entered on the %s" % place_label(value)
		"hour":
			return "%s is the hour at which the tide ledger was entered" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s entered the tide ledger" % value
		"place":
			return "the tide ledger was entered on the %s" % place_label(value)
		"hour":
			return "the tide ledger was entered at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s entered the tide ledger" % value
		"place":
			return "it was entered on the %s" % place_label(value)
		"hour":
			return "it was entered at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"read_late":
			return "so the boat would read late"
		"call_early":
			return "to call the boat early"
		"mark_flood":
			return "to mark the flood"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) entered the tide ledger at %s from the %s to the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			model["hour"],
			place_label(str(model["origin"])),
			place_label(str(model["place"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) filled the pen at %s on the %s." % [
			model["inker"],
			role_short(str(model["inker"])),
			model["ink_hour"],
			place_label(str(model["ink_place"])),
		],
		"%s (%s) read the tide glass at %s." % [
			model["reader"],
			role_short(str(model["reader"])),
			model["read_hour"],
		],
		"The tide bell was hung on the %s." % place_label(str(model["hang_place"])),
		"The tide glass was read on the %s." % place_label(str(model["glass_place"])),
		"The boat was called at %s." % model["call_hour"],
		"The line was hauled at %s." % model["haul_hour"],
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
	return "Who entered the tide ledger, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they entered the ledger on."


static func cast_line() -> String:
	return "Pell, ink hand    Moss, tide clerk    Dory, bell hand"


static func ready_line() -> String:
	return "Pin who entered the tide ledger, the room they entered it on, and the hour. Then submit."


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
