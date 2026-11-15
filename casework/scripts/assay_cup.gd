extends RefCounted

# The assay cup.
#
# The player pins three facts about the setting: who, the room the cup was
# set on, and the hour. The timeline also records who packed the bone ash,
# where and at which hour it was packed, who drew the needle, at which hour
# the needle was drawn, where the cup was set from, why it was set, where the
# button was parted, when the flux was stirred, and when the cup was quenched.
# The room is the pin four exhibits share. Who and the hour are each shared
# by two. Five hours are on the board, and the setting is the middle one. Two
# exhibits each state two hidden facts. Each exhibit states one of the three
# pins (a value at least one other exhibit also states) and at least one fact
# no other exhibit states. Exactly one full timeline fits every exhibit. Drop
# any exhibit and another timeline fits. Any other pin triple disagrees with
# at least two exhibits.

const TITLE := "The assay cup"
const FILE_CODE := "CW-10"
const BLURB := "The assay cup left its peg at the assay office. Name who set it, the room they set it on, and the hour."

const PEOPLE: Array[String] = ["Cress", "Lark", "Tor"]
const PLACES: Array[String] = ["muffle", "flux_bench", "scale"]
const HOURS: Array[String] = ["14", "15", "16", "17", "18"]
const PURPOSES: Array[String] = ["read_light", "check_button", "warm_cup"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Cup line",
		"source": "Cress, cupeller",
		"text": "Lark, the weigher, is the person who set the assay cup. Cress, the cupeller, is the person who packed the bone ash.",
		"literals": [
			{
				"field": "taker",
				"value": "Lark",
				"phrase": "Lark, the weigher, is the person who set the assay cup",
			},
			{
				"field": "packer",
				"value": "Cress",
				"phrase": "Cress, the cupeller, is the person who packed the bone ash",
			},
		],
	},
	{
		"id": "E2",
		"title": "Muffle tag",
		"source": "Muffle",
		"text": "Lark, the weigher, is the person who set the assay cup. The assay cup was set from the muffle.",
		"literals": [
			{
				"field": "taker",
				"value": "Lark",
				"phrase": "Lark, the weigher, is the person who set the assay cup",
			},
			{
				"field": "origin",
				"value": "muffle",
				"phrase": "The assay cup was set from the muffle",
			},
		],
	},
	{
		"id": "E3",
		"title": "Flux card",
		"source": "Flux bench",
		"text": "The assay cup was set on the scale. The bone ash was packed on the flux bench.",
		"literals": [
			{
				"field": "place",
				"value": "scale",
				"phrase": "The assay cup was set on the scale",
			},
			{
				"field": "pack_place",
				"value": "flux_bench",
				"phrase": "The bone ash was packed on the flux bench",
			},
		],
	},
	{
		"id": "E4",
		"title": "Needle margin",
		"source": "Touch needle",
		"text": "The assay cup was set on the scale. Tor, the touch hand, is the person who drew the needle, and the button was parted at the muffle.",
		"literals": [
			{
				"field": "place",
				"value": "scale",
				"phrase": "The assay cup was set on the scale",
			},
			{
				"field": "drawer",
				"value": "Tor",
				"phrase": "Tor, the touch hand, is the person who drew the needle",
			},
			{
				"field": "part_place",
				"value": "muffle",
				"phrase": "the button was parted at the muffle",
			},
		],
	},
	{
		"id": "E5",
		"title": "Ash slip",
		"source": "Scale",
		"text": "The assay cup was set on the scale. 14 is the hour at which the bone ash was packed.",
		"literals": [
			{
				"field": "place",
				"value": "scale",
				"phrase": "The assay cup was set on the scale",
			},
			{
				"field": "pack_hour",
				"value": "14",
				"phrase": "14 is the hour at which the bone ash was packed",
			},
		],
	},
	{
		"id": "E6",
		"title": "Draw slip",
		"source": "Needle bar",
		"text": "The assay cup was set on the scale. 15 is the hour at which the needle was drawn.",
		"literals": [
			{
				"field": "place",
				"value": "scale",
				"phrase": "The assay cup was set on the scale",
			},
			{
				"field": "draw_hour",
				"value": "15",
				"phrase": "15 is the hour at which the needle was drawn",
			},
		],
	},
	{
		"id": "E7",
		"title": "Light note",
		"source": "Assay office",
		"text": "16 is the hour at which the assay cup was set. The assay cup was set so the weight would read light.",
		"literals": [
			{
				"field": "hour",
				"value": "16",
				"phrase": "16 is the hour at which the assay cup was set",
			},
			{
				"field": "purpose",
				"value": "read_light",
				"phrase": "The assay cup was set so the weight would read light",
			},
		],
	},
	{
		"id": "E8",
		"title": "Quench line",
		"source": "Office book",
		"text": "16 is the hour at which the assay cup was set. The flux was stirred at 17, and the cup was quenched at 18.",
		"literals": [
			{
				"field": "hour",
				"value": "16",
				"phrase": "16 is the hour at which the assay cup was set",
			},
			{
				"field": "stir_hour",
				"value": "17",
				"phrase": "The flux was stirred at 17",
			},
			{
				"field": "quench_hour",
				"value": "18",
				"phrase": "the cup was quenched at 18",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"packer",
		"pack_place",
		"pack_hour",
		"drawer",
		"draw_hour",
		"origin",
		"purpose",
		"part_place",
		"stir_hour",
		"quench_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "packer", "drawer":
			return PEOPLE.duplicate()
		"place", "pack_place", "origin", "part_place":
			return PLACES.duplicate()
		"hour", "pack_hour", "draw_hour", "stir_hour", "quench_hour":
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
		missing.append("who set the assay cup")
	if pins["place"] == "":
		missing.append("where they set the cup")
	if pins["hour"] == "":
		missing.append("at which hour they set the cup")
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
		"Cress":
			return "the cupeller"
		"Lark":
			return "the weigher"
		"Tor":
			return "the touch hand"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"muffle":
			return "muffle"
		"flux_bench":
			return "flux bench"
		"scale":
			return "scale"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"muffle":
			return "Muffle"
		"flux_bench":
			return "Flux bench"
		"scale":
			return "Scale"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s, %s, is the person who set the assay cup" % [value, role_phrase(value)]
		"place":
			return "The assay cup was set on the %s" % place_label(value)
		"hour":
			return "%s is the hour at which the assay cup was set" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s set the assay cup" % value
		"place":
			return "the assay cup was set on the %s" % place_label(value)
		"hour":
			return "the assay cup was set at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s set the assay cup" % value
		"place":
			return "it was set on the %s" % place_label(value)
		"hour":
			return "it was set at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"read_light":
			return "so the weight would read light"
		"check_button":
			return "to check the button"
		"warm_cup":
			return "to warm the cup"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) set the assay cup at %s from the %s to the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			model["hour"],
			place_label(str(model["origin"])),
			place_label(str(model["place"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) packed the bone ash at %s on the %s." % [
			model["packer"],
			role_short(str(model["packer"])),
			model["pack_hour"],
			place_label(str(model["pack_place"])),
		],
		"%s (%s) drew the needle at %s." % [
			model["drawer"],
			role_short(str(model["drawer"])),
			model["draw_hour"],
		],
		"The button was parted at the %s." % place_label(str(model["part_place"])),
		"The flux was stirred at %s." % model["stir_hour"],
		"The cup was quenched at %s." % model["quench_hour"],
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
	return "Who set the assay cup, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they set the cup on."


static func cast_line() -> String:
	return "Cress, cupeller    Lark, weigher    Tor, touch hand"


static func ready_line() -> String:
	return "Pin who set the assay cup, the room they set it on, and the hour. Then submit."


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
