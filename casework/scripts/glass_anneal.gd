extends RefCounted

# The glass anneal.
#
# The player pins three facts about the anneal: who, the room the gather was
# annealed in, and the hour. The timeline also records who gathered the glass,
# where it was gathered, when the pot was charged, who smoothed the shoulder,
# at which hour and in which room that smoothing was done, where the anneal
# was seen from, why the gather was annealed, where the pontil was rested,
# when the marver was cleared, and when the lehr was latched. Who, the room,
# and the hour are each shared by three exhibits. Five hours are on the board,
# and the anneal is the middle one. Two exhibits each state two hidden facts.
# Each exhibit states one of the three pins (a value at least one other
# exhibit also states) and at least one fact no other exhibit states. Exactly
# one full timeline fits every exhibit. Drop any exhibit and another timeline
# fits. Any other pin triple disagrees with at least two exhibits.

const TITLE := "The glass anneal"
const FILE_CODE := "CW-16"
const BLURB := "The glass anneal left its peg at the glasshouse. Name who annealed the gather, the room they annealed it in, and the hour."

const PEOPLE: Array[String] = ["Ivo", "Tess", "Wynn"]
const PLACES: Array[String] = ["lehr", "marver", "pot"]
const HOURS: Array[String] = ["8", "9", "10", "11", "12"]
const PURPOSES: Array[String] = ["cool_pane", "spare_heat", "open_lehr"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Gather note",
		"source": "Ivo, gatherer",
		"text": "Tess annealed the gather. Ivo had gathered the glass.",
		"literals": [
			{
				"field": "taker",
				"value": "Tess",
				"phrase": "Tess annealed the gather",
			},
			{
				"field": "gatherer",
				"value": "Ivo",
				"phrase": "Ivo had gathered the glass",
			},
		],
	},
	{
		"id": "E2",
		"title": "Bench pane",
		"source": "Marver bench",
		"text": "Tess annealed the gather. Someone standing at the marver watched the whole anneal.",
		"literals": [
			{
				"field": "taker",
				"value": "Tess",
				"phrase": "Tess annealed the gather",
			},
			{
				"field": "view_place",
				"value": "marver",
				"phrase": "Someone standing at the marver watched the whole anneal",
			},
		],
	},
	{
		"id": "E3",
		"title": "Iron rest",
		"source": "Pot lip",
		"text": "Tess annealed the gather. The pontil was rested in the pot once the neck was cold.",
		"literals": [
			{
				"field": "taker",
				"value": "Tess",
				"phrase": "Tess annealed the gather",
			},
			{
				"field": "pontil_place",
				"value": "pot",
				"phrase": "The pontil was rested in the pot",
			},
		],
	},
	{
		"id": "E4",
		"title": "Lehr slate",
		"source": "Lehr door",
		"text": "The gather was annealed in the lehr. That glass had been gathered in the pot.",
		"literals": [
			{
				"field": "place",
				"value": "lehr",
				"phrase": "The gather was annealed in the lehr",
			},
			{
				"field": "gather_place",
				"value": "pot",
				"phrase": "That glass had been gathered in the pot",
			},
		],
	},
	{
		"id": "E5",
		"title": "Shoulder card",
		"source": "Wynn, marver hand",
		"text": "The gather was annealed in the lehr. Wynn smoothed the shoulder, with the smoothing done at the marver.",
		"literals": [
			{
				"field": "place",
				"value": "lehr",
				"phrase": "The gather was annealed in the lehr",
			},
			{
				"field": "smoother",
				"value": "Wynn",
				"phrase": "Wynn smoothed the shoulder",
			},
			{
				"field": "smooth_place",
				"value": "marver",
				"phrase": "the smoothing done at the marver",
			},
		],
	},
	{
		"id": "E6",
		"title": "Charge slip",
		"source": "Pot book",
		"text": "The gather was annealed in the lehr. Charging the pot had finished at 8.",
		"literals": [
			{
				"field": "place",
				"value": "lehr",
				"phrase": "The gather was annealed in the lehr",
			},
			{
				"field": "charge_hour",
				"value": "8",
				"phrase": "Charging the pot had finished at 8",
			},
		],
	},
	{
		"id": "E7",
		"title": "Shoulder leaf",
		"source": "Anneal book",
		"text": "The gather was annealed at 10. The shoulder had been smoothed at 9.",
		"literals": [
			{
				"field": "hour",
				"value": "10",
				"phrase": "The gather was annealed at 10",
			},
			{
				"field": "smooth_hour",
				"value": "9",
				"phrase": "The shoulder had been smoothed at 9",
			},
		],
	},
	{
		"id": "E8",
		"title": "Crack note",
		"source": "Glasshouse",
		"text": "The gather was annealed at 10. The anneal was done so the pane would cool without a crack.",
		"literals": [
			{
				"field": "hour",
				"value": "10",
				"phrase": "The gather was annealed at 10",
			},
			{
				"field": "purpose",
				"value": "cool_pane",
				"phrase": "so the pane would cool without a crack",
			},
		],
	},
	{
		"id": "E9",
		"title": "Latch order",
		"source": "Night slate",
		"text": "The gather was annealed at 10. Clearing the marver waited until 11, and latching the lehr waited until 12.",
		"literals": [
			{
				"field": "hour",
				"value": "10",
				"phrase": "The gather was annealed at 10",
			},
			{
				"field": "clear_hour",
				"value": "11",
				"phrase": "Clearing the marver waited until 11",
			},
			{
				"field": "latch_hour",
				"value": "12",
				"phrase": "latching the lehr waited until 12",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"gatherer",
		"gather_place",
		"charge_hour",
		"smoother",
		"smooth_hour",
		"view_place",
		"purpose",
		"smooth_place",
		"pontil_place",
		"clear_hour",
		"latch_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "gatherer", "smoother":
			return PEOPLE.duplicate()
		"place", "gather_place", "view_place", "smooth_place", "pontil_place":
			return PLACES.duplicate()
		"hour", "charge_hour", "smooth_hour", "clear_hour", "latch_hour":
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
		missing.append("who annealed the gather")
	if pins["place"] == "":
		missing.append("where they annealed the gather")
	if pins["hour"] == "":
		missing.append("at which hour they annealed the gather")
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
		"Ivo":
			return "the gatherer"
		"Tess":
			return "the anneal hand"
		"Wynn":
			return "the marver hand"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"lehr":
			return "lehr"
		"marver":
			return "marver"
		"pot":
			return "pot"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"lehr":
			return "Lehr"
		"marver":
			return "Marver"
		"pot":
			return "Pot"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s annealed the gather" % value
		"place":
			return "The gather was annealed in the %s" % place_label(value)
		"hour":
			return "The gather was annealed at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s annealed the gather" % value
		"place":
			return "the gather was annealed in the %s" % place_label(value)
		"hour":
			return "the gather was annealed at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s annealed the gather" % value
		"place":
			return "it was annealed in the %s" % place_label(value)
		"hour":
			return "it was annealed at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"cool_pane":
			return "so the pane would cool without a crack"
		"spare_heat":
			return "to spare the heat still in the pot"
		"open_lehr":
			return "to open the lehr before the color set"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) annealed the gather in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["view_place"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) gathered the glass in the %s, and the pot was charged at %s." % [
			model["gatherer"],
			role_short(str(model["gatherer"])),
			place_label(str(model["gather_place"])),
			model["charge_hour"],
		],
		"%s (%s) smoothed the shoulder at %s on the %s." % [
			model["smoother"],
			role_short(str(model["smoother"])),
			model["smooth_hour"],
			place_label(str(model["smooth_place"])),
		],
		"The pontil was rested in the %s." % place_label(str(model["pontil_place"])),
		"The marver was cleared at %s." % model["clear_hour"],
		"The lehr was latched at %s." % model["latch_hour"],
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
	return "Who annealed the gather, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they annealed the gather in."


static func cast_line() -> String:
	return "Ivo, gatherer    Tess, anneal hand    Wynn, marver hand"


static func ready_line() -> String:
	return "Pin who annealed the gather, the room they annealed it in, and the hour. Then submit."


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
