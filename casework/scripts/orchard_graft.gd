extends RefCounted

# The orchard graft.
#
# The player pins three facts about the graft: who, the room the scion was
# grafted in, and the hour. The timeline also records who cut the scion, where
# it was cut, when that cut was made, where the graft was seen from, where the
# knife was hung, who bound the union, where the tie was made, when the row was
# watered, when the gate was shut, when the frost was chalked, and why the
# scion was grafted. Who, the room, and the hour are each shared by three
# exhibits. Five hours are on the board, and the graft is the middle one. Two
# exhibits each state two hidden facts. Each exhibit states one of the three
# pins (a value at least one other exhibit also states) and at least one fact
# no other exhibit states. Exactly one full timeline fits every exhibit. Drop
# any exhibit and another timeline fits. Any other pin triple disagrees with
# at least two exhibits.

const TITLE := "The orchard graft"
const FILE_CODE := "CW-17"
const BLURB := "The orchard graft left its peg at the nursery. Name who grafted the scion, the room they grafted it in, and the hour."

const PEOPLE: Array[String] = ["Ness", "Calder", "Edda"]
const PLACES: Array[String] = ["nursery", "row", "gate"]
const HOURS: Array[String] = ["14", "15", "16", "17", "18"]
const PURPOSES: Array[String] = ["take_row", "spare_sap", "hold_union"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Scion note",
		"source": "Ness, scion cutter",
		"text": "Calder grafted the scion. Ness had cut the scion before the sap rose.",
		"literals": [
			{
				"field": "taker",
				"value": "Calder",
				"phrase": "Calder grafted the scion",
			},
			{
				"field": "cutter",
				"value": "Ness",
				"phrase": "Ness had cut the scion",
			},
		],
	},
	{
		"id": "E2",
		"title": "Path sight",
		"source": "Row path",
		"text": "Calder grafted the scion. The graft was seen from the row, past the young stakes.",
		"literals": [
			{
				"field": "taker",
				"value": "Calder",
				"phrase": "Calder grafted the scion",
			},
			{
				"field": "seen_place",
				"value": "row",
				"phrase": "The graft was seen from the row",
			},
		],
	},
	{
		"id": "E3",
		"title": "Knife peg",
		"source": "Gate post",
		"text": "Calder grafted the scion. The knife was hung at the gate once the cut was closed.",
		"literals": [
			{
				"field": "taker",
				"value": "Calder",
				"phrase": "Calder grafted the scion",
			},
			{
				"field": "knife_place",
				"value": "gate",
				"phrase": "The knife was hung at the gate",
			},
		],
	},
	{
		"id": "E4",
		"title": "Bench slate",
		"source": "Nursery bench",
		"text": "The scion was grafted in the nursery. That scion had been cut in the row, not on the bench.",
		"literals": [
			{
				"field": "place",
				"value": "nursery",
				"phrase": "The scion was grafted in the nursery",
			},
			{
				"field": "cut_place",
				"value": "row",
				"phrase": "That scion had been cut in the row",
			},
		],
	},
	{
		"id": "E5",
		"title": "Raffia card",
		"source": "Edda, raffia hand",
		"text": "The scion was grafted in the nursery. Edda bound the union, and the tie made at the gate held the scion still.",
		"literals": [
			{
				"field": "place",
				"value": "nursery",
				"phrase": "The scion was grafted in the nursery",
			},
			{
				"field": "binder",
				"value": "Edda",
				"phrase": "Edda bound the union",
			},
			{
				"field": "tie_place",
				"value": "gate",
				"phrase": "the tie made at the gate",
			},
		],
	},
	{
		"id": "E6",
		"title": "Water slip",
		"source": "Row book",
		"text": "The scion was grafted in the nursery. Watering the row had finished at 14, while the soil was still open.",
		"literals": [
			{
				"field": "place",
				"value": "nursery",
				"phrase": "The scion was grafted in the nursery",
			},
			{
				"field": "water_hour",
				"value": "14",
				"phrase": "Watering the row had finished at 14",
			},
		],
	},
	{
		"id": "E7",
		"title": "Hour leaf",
		"source": "Graft book",
		"text": "The scion was grafted at 16. The scion had been cut at 15, while the bench was still wet.",
		"literals": [
			{
				"field": "hour",
				"value": "16",
				"phrase": "The scion was grafted at 16",
			},
			{
				"field": "cut_hour",
				"value": "15",
				"phrase": "The scion had been cut at 15",
			},
		],
	},
	{
		"id": "E8",
		"title": "Take note",
		"source": "Orchard house",
		"text": "The scion was grafted at 16. Calder's reason was plain: so the row would take before the frost.",
		"literals": [
			{
				"field": "hour",
				"value": "16",
				"phrase": "The scion was grafted at 16",
			},
			{
				"field": "purpose",
				"value": "take_row",
				"phrase": "so the row would take before the frost",
			},
		],
	},
	{
		"id": "E9",
		"title": "Shut order",
		"source": "Night slate",
		"text": "The scion was grafted at 16. Shutting the gate waited until 17, after which the frost was chalked at 18.",
		"literals": [
			{
				"field": "hour",
				"value": "16",
				"phrase": "The scion was grafted at 16",
			},
			{
				"field": "shut_hour",
				"value": "17",
				"phrase": "Shutting the gate waited until 17",
			},
			{
				"field": "frost_hour",
				"value": "18",
				"phrase": "the frost was chalked at 18",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"cutter",
		"cut_place",
		"cut_hour",
		"seen_place",
		"binder",
		"purpose",
		"tie_place",
		"knife_place",
		"water_hour",
		"shut_hour",
		"frost_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "cutter", "binder":
			return PEOPLE.duplicate()
		"place", "cut_place", "seen_place", "tie_place", "knife_place":
			return PLACES.duplicate()
		"hour", "cut_hour", "water_hour", "shut_hour", "frost_hour":
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
		missing.append("who grafted the scion")
	if pins["place"] == "":
		missing.append("where they grafted the scion")
	if pins["hour"] == "":
		missing.append("at which hour they grafted the scion")
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
		"Ness":
			return "the scion cutter"
		"Calder":
			return "the graft hand"
		"Edda":
			return "the raffia hand"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"nursery":
			return "nursery"
		"row":
			return "row"
		"gate":
			return "gate"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"nursery":
			return "Nursery"
		"row":
			return "Row"
		"gate":
			return "Gate"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s grafted the scion" % value
		"place":
			return "The scion was grafted in the %s" % place_label(value)
		"hour":
			return "The scion was grafted at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s grafted the scion" % value
		"place":
			return "the scion was grafted in the %s" % place_label(value)
		"hour":
			return "the scion was grafted at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s grafted the scion" % value
		"place":
			return "it was grafted in the %s" % place_label(value)
		"hour":
			return "it was grafted at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"take_row":
			return "so the row would take before the frost"
		"spare_sap":
			return "to spare the sap still in the scion"
		"hold_union":
			return "to hold the union through the night"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) grafted the scion in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_place"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) cut the scion in the %s at %s." % [
			model["cutter"],
			role_short(str(model["cutter"])),
			place_label(str(model["cut_place"])),
			model["cut_hour"],
		],
		"%s (%s) bound the union at the %s." % [
			model["binder"],
			role_short(str(model["binder"])),
			place_label(str(model["tie_place"])),
		],
		"The knife was hung at the %s." % place_label(str(model["knife_place"])),
		"The row was watered at %s." % model["water_hour"],
		"The gate was shut at %s." % model["shut_hour"],
		"The frost was chalked at %s." % model["frost_hour"],
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
	return "Who grafted the scion, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they grafted the scion in."


static func cast_line() -> String:
	return "Ness, scion cutter    Calder, graft hand    Edda, raffia hand"


static func ready_line() -> String:
	return "Pin who grafted the scion, the room they grafted it in, and the hour. Then submit."


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
