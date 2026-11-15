extends RefCounted

# The loom shuttle.
#
# The player pins three facts about the taking: who, the room the shuttle was
# taken to, and the hour. The timeline also records who marked the warp count,
# where and at which hour that count was marked, where the shuttle was taken
# from, why it was taken, who hung it back, and where and at which hour it was
# hung back. The room and the hour are each stated by three exhibits. The taker
# is stated by two. Four hours are on the board, and 18 is none of them in the
# true timeline: the count is marked at 17, the shuttle is taken at 19, and it
# is hung back at 20. Each exhibit states one of those three pins (a value at
# least one other exhibit also states) and at least one fact no other exhibit
# states. Exactly one full timeline fits every exhibit. Drop any exhibit and
# another timeline fits. Any other pin triple disagrees with at least two
# exhibits.

const TITLE := "The loom shuttle"
const FILE_CODE := "CW-06"
const BLURB := "The loom shuttle left its trough at the weaving shed. Name who took it, the room they took it to, and the hour."

const PEOPLE: Array[String] = ["Joss", "Fenn", "Rue"]
const PLACES: Array[String] = ["loom_room", "pattern_loft", "dye_house"]
const HOURS: Array[String] = ["17", "18", "19", "20"]
const PURPOSES: Array[String] = ["match_border", "mend_warp", "count_picks"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Trough tag",
		"source": "Loom room",
		"text": "The loom shuttle was taken to the pattern loft. The loom shuttle was taken from the loom room.",
		"literals": [
			{
				"field": "place",
				"value": "pattern_loft",
				"phrase": "The loom shuttle was taken to the pattern loft",
			},
			{
				"field": "origin",
				"value": "loom_room",
				"phrase": "The loom shuttle was taken from the loom room",
			},
		],
	},
	{
		"id": "E2",
		"title": "Count slip",
		"source": "Joss, loom hand",
		"text": "19 is the hour at which the loom shuttle was taken. Joss, the loom hand, is the person who marked the warp count.",
		"literals": [
			{
				"field": "hour",
				"value": "19",
				"phrase": "19 is the hour at which the loom shuttle was taken",
			},
			{
				"field": "marker",
				"value": "Joss",
				"phrase": "Joss, the loom hand, is the person who marked the warp count",
			},
		],
	},
	{
		"id": "E3",
		"title": "Peg card",
		"source": "Loom room book",
		"text": "Fenn, the warper, is the person who took the loom shuttle. 20 is the hour at which the shuttle was hung back.",
		"literals": [
			{
				"field": "taker",
				"value": "Fenn",
				"phrase": "Fenn, the warper, is the person who took the loom shuttle",
			},
			{
				"field": "return_hour",
				"value": "20",
				"phrase": "20 is the hour at which the shuttle was hung back",
			},
		],
	},
	{
		"id": "E4",
		"title": "Border note",
		"source": "Pattern loft",
		"text": "The loom shuttle was taken to the pattern loft. The loom shuttle was taken in order to match the border.",
		"literals": [
			{
				"field": "place",
				"value": "pattern_loft",
				"phrase": "The loom shuttle was taken to the pattern loft",
			},
			{
				"field": "purpose",
				"value": "match_border",
				"phrase": "The loom shuttle was taken in order to match the border",
			},
		],
	},
	{
		"id": "E5",
		"title": "Warp card",
		"source": "Dye house",
		"text": "19 is the hour at which the loom shuttle was taken. 17 is the hour at which the warp count was marked.",
		"literals": [
			{
				"field": "hour",
				"value": "19",
				"phrase": "19 is the hour at which the loom shuttle was taken",
			},
			{
				"field": "mark_hour",
				"value": "17",
				"phrase": "17 is the hour at which the warp count was marked",
			},
		],
	},
	{
		"id": "E6",
		"title": "Loft receipt",
		"source": "Pattern loft book",
		"text": "Fenn, the warper, is the person who took the loom shuttle. The shuttle was hung back in the loom room.",
		"literals": [
			{
				"field": "taker",
				"value": "Fenn",
				"phrase": "Fenn, the warper, is the person who took the loom shuttle",
			},
			{
				"field": "return_place",
				"value": "loom_room",
				"phrase": "The shuttle was hung back in the loom room",
			},
		],
	},
	{
		"id": "E7",
		"title": "Hanging line",
		"source": "Rue, dyer",
		"text": "The loom shuttle was taken to the pattern loft. Rue, the dyer, is the person who hung the shuttle back.",
		"literals": [
			{
				"field": "place",
				"value": "pattern_loft",
				"phrase": "The loom shuttle was taken to the pattern loft",
			},
			{
				"field": "returner",
				"value": "Rue",
				"phrase": "Rue, the dyer, is the person who hung the shuttle back",
			},
		],
	},
	{
		"id": "E8",
		"title": "Dye margin",
		"source": "Dye house book",
		"text": "19 is the hour at which the loom shuttle was taken. The warp count was marked in the dye house.",
		"literals": [
			{
				"field": "hour",
				"value": "19",
				"phrase": "19 is the hour at which the loom shuttle was taken",
			},
			{
				"field": "mark_place",
				"value": "dye_house",
				"phrase": "The warp count was marked in the dye house",
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
		"mark_place",
		"mark_hour",
		"origin",
		"purpose",
		"returner",
		"return_place",
		"return_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "marker", "returner":
			return PEOPLE.duplicate()
		"place", "mark_place", "origin", "return_place":
			return PLACES.duplicate()
		"hour", "mark_hour", "return_hour":
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
		missing.append("who took the loom shuttle")
	if pins["place"] == "":
		missing.append("where they took the shuttle")
	if pins["hour"] == "":
		missing.append("at which hour they took the shuttle")
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
		"Joss":
			return "the loom hand"
		"Fenn":
			return "the warper"
		"Rue":
			return "the dyer"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"loom_room":
			return "loom room"
		"pattern_loft":
			return "pattern loft"
		"dye_house":
			return "dye house"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"loom_room":
			return "Loom room"
		"pattern_loft":
			return "Pattern loft"
		"dye_house":
			return "Dye house"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s, %s, is the person who took the loom shuttle" % [value, role_phrase(value)]
		"place":
			return "The loom shuttle was taken to the %s" % place_label(value)
		"hour":
			return "%s is the hour at which the loom shuttle was taken" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s took the loom shuttle" % value
		"place":
			return "the loom shuttle was taken to the %s" % place_label(value)
		"hour":
			return "the loom shuttle was taken at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s took the loom shuttle" % value
		"place":
			return "it was taken to the %s" % place_label(value)
		"hour":
			return "it was taken at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"match_border":
			return "to match the border"
		"mend_warp":
			return "to mend the warp"
		"count_picks":
			return "to count the picks"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) took the loom shuttle at %s from the %s to the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			model["hour"],
			place_label(str(model["origin"])),
			place_label(str(model["place"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) marked the warp count at %s in the %s." % [
			model["marker"],
			role_short(str(model["marker"])),
			model["mark_hour"],
			place_label(str(model["mark_place"])),
		],
		"%s (%s) hung the shuttle back at %s in the %s." % [
			model["returner"],
			role_short(str(model["returner"])),
			model["return_hour"],
			place_label(str(model["return_place"])),
		],
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
	return "Who took the loom shuttle, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they took the shuttle to."


static func cast_line() -> String:
	return "Joss, loom hand    Fenn, warper    Rue, dyer"


static func ready_line() -> String:
	return "Pin who took the loom shuttle, the room they took it to, and the hour. Then submit."


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
