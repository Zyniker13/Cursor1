extends RefCounted

# The night bell.
#
# The player pins three facts about the stopping: who, the room the bell was
# stopped in, and the hour. The timeline also records who trimmed the lamp,
# where and at which hour it was trimmed, who read the hour glass, at which
# hour the glass was read, where the bell was stopped from, why it was
# stopped, where the clapper was hitched, where the hour glass was read, when
# the watch was struck, and when the shutter was closed. Who, the room, and
# the hour are each shared by three exhibits. Five hours are on the board,
# and the stopping is the middle one. Two exhibits each state two hidden
# facts. Each exhibit states one of the three pins (a value at least one
# other exhibit also states) and at least one fact no other exhibit states.
# Exactly one full timeline fits every exhibit. Drop any exhibit and another
# timeline fits. Any other pin triple disagrees with at least two exhibits.

const TITLE := "The night bell"
const FILE_CODE := "CW-13"
const BLURB := "The night bell left its peg at the watch house. Name who stopped it, the room they stopped it in, and the hour."

const PEOPLE: Array[String] = ["Cobb", "Vesper", "Reed"]
const PLACES: Array[String] = ["parapet", "bell_walk", "tower"]
const HOURS: Array[String] = ["42", "43", "44", "45", "46"]
const PURPOSES: Array[String] = ["read_early", "strike_late", "close_shutter"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Bell line",
		"source": "Cobb, lamp hand",
		"text": "Vesper, the night ringer, is the person who stopped the night bell. Cobb, the lamp hand, is the person who trimmed the lamp.",
		"literals": [
			{
				"field": "taker",
				"value": "Vesper",
				"phrase": "Vesper, the night ringer, is the person who stopped the night bell",
			},
			{
				"field": "trimmer",
				"value": "Cobb",
				"phrase": "Cobb, the lamp hand, is the person who trimmed the lamp",
			},
		],
	},
	{
		"id": "E2",
		"title": "Parapet tag",
		"source": "Parapet",
		"text": "Vesper, the night ringer, is the person who stopped the night bell. The night bell was stopped from the parapet.",
		"literals": [
			{
				"field": "taker",
				"value": "Vesper",
				"phrase": "Vesper, the night ringer, is the person who stopped the night bell",
			},
			{
				"field": "origin",
				"value": "parapet",
				"phrase": "The night bell was stopped from the parapet",
			},
		],
	},
	{
		"id": "E3",
		"title": "Hitch card",
		"source": "Rope peg",
		"text": "Vesper, the night ringer, is the person who stopped the night bell. The clapper was hitched on the parapet.",
		"literals": [
			{
				"field": "taker",
				"value": "Vesper",
				"phrase": "Vesper, the night ringer, is the person who stopped the night bell",
			},
			{
				"field": "hitch_place",
				"value": "parapet",
				"phrase": "The clapper was hitched on the parapet",
			},
		],
	},
	{
		"id": "E4",
		"title": "Walk card",
		"source": "Bell walk",
		"text": "The night bell was stopped in the tower. The lamp was trimmed on the bell walk.",
		"literals": [
			{
				"field": "place",
				"value": "tower",
				"phrase": "The night bell was stopped in the tower",
			},
			{
				"field": "trim_place",
				"value": "bell_walk",
				"phrase": "The lamp was trimmed on the bell walk",
			},
		],
	},
	{
		"id": "E5",
		"title": "Hour margin",
		"source": "Hour glass",
		"text": "The night bell was stopped in the tower. Reed, the stair hand, is the person who read the hour glass, and the hour glass was read on the parapet.",
		"literals": [
			{
				"field": "place",
				"value": "tower",
				"phrase": "The night bell was stopped in the tower",
			},
			{
				"field": "sighter",
				"value": "Reed",
				"phrase": "Reed, the stair hand, is the person who read the hour glass",
			},
			{
				"field": "sight_place",
				"value": "parapet",
				"phrase": "the hour glass was read on the parapet",
			},
		],
	},
	{
		"id": "E6",
		"title": "Lamp chit",
		"source": "Lamp book",
		"text": "The night bell was stopped in the tower. 42 is the hour at which the lamp was trimmed.",
		"literals": [
			{
				"field": "place",
				"value": "tower",
				"phrase": "The night bell was stopped in the tower",
			},
			{
				"field": "trim_hour",
				"value": "42",
				"phrase": "42 is the hour at which the lamp was trimmed",
			},
		],
	},
	{
		"id": "E7",
		"title": "Sight slip",
		"source": "Sight book",
		"text": "44 is the hour at which the night bell was stopped. 43 is the hour at which the hour glass was read.",
		"literals": [
			{
				"field": "hour",
				"value": "44",
				"phrase": "44 is the hour at which the night bell was stopped",
			},
			{
				"field": "sight_hour",
				"value": "43",
				"phrase": "43 is the hour at which the hour glass was read",
			},
		],
	},
	{
		"id": "E8",
		"title": "Early note",
		"source": "Watch house",
		"text": "44 is the hour at which the night bell was stopped. The night bell was stopped so the watch would read early.",
		"literals": [
			{
				"field": "hour",
				"value": "44",
				"phrase": "44 is the hour at which the night bell was stopped",
			},
			{
				"field": "purpose",
				"value": "read_early",
				"phrase": "The night bell was stopped so the watch would read early",
			},
		],
	},
	{
		"id": "E9",
		"title": "Shutter line",
		"source": "Watch book",
		"text": "44 is the hour at which the night bell was stopped. The watch was struck at 45, and the shutter was closed at 46.",
		"literals": [
			{
				"field": "hour",
				"value": "44",
				"phrase": "44 is the hour at which the night bell was stopped",
			},
			{
				"field": "strike_hour",
				"value": "45",
				"phrase": "The watch was struck at 45",
			},
			{
				"field": "shutter_hour",
				"value": "46",
				"phrase": "the shutter was closed at 46",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"trimmer",
		"trim_place",
		"trim_hour",
		"sighter",
		"sight_hour",
		"origin",
		"purpose",
		"sight_place",
		"hitch_place",
		"strike_hour",
		"shutter_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "trimmer", "sighter":
			return PEOPLE.duplicate()
		"place", "trim_place", "origin", "sight_place", "hitch_place":
			return PLACES.duplicate()
		"hour", "trim_hour", "sight_hour", "strike_hour", "shutter_hour":
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
		missing.append("who stopped the night bell")
	if pins["place"] == "":
		missing.append("where they stopped the bell")
	if pins["hour"] == "":
		missing.append("at which hour they stopped the bell")
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
		"Cobb":
			return "the lamp hand"
		"Vesper":
			return "the night ringer"
		"Reed":
			return "the stair hand"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"parapet":
			return "parapet"
		"bell_walk":
			return "bell walk"
		"tower":
			return "tower"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"parapet":
			return "Parapet"
		"bell_walk":
			return "Bell walk"
		"tower":
			return "Tower"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s, %s, is the person who stopped the night bell" % [value, role_phrase(value)]
		"place":
			return "The night bell was stopped in the %s" % place_label(value)
		"hour":
			return "%s is the hour at which the night bell was stopped" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s stopped the night bell" % value
		"place":
			return "the night bell was stopped in the %s" % place_label(value)
		"hour":
			return "the night bell was stopped at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s stopped the night bell" % value
		"place":
			return "it was stopped in the %s" % place_label(value)
		"hour":
			return "it was stopped at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"read_early":
			return "so the watch would read early"
		"strike_late":
			return "to strike the watch late"
		"close_shutter":
			return "to close the shutter"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) stopped the night bell at %s from the %s to the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			model["hour"],
			place_label(str(model["origin"])),
			place_label(str(model["place"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) trimmed the lamp at %s on the %s." % [
			model["trimmer"],
			role_short(str(model["trimmer"])),
			model["trim_hour"],
			place_label(str(model["trim_place"])),
		],
		"%s (%s) read the hour glass at %s." % [
			model["sighter"],
			role_short(str(model["sighter"])),
			model["sight_hour"],
		],
		"The clapper was hitched on the %s." % place_label(str(model["hitch_place"])),
		"The hour glass was read on the %s." % place_label(str(model["sight_place"])),
		"The watch was struck at %s." % model["strike_hour"],
		"The shutter was closed at %s." % model["shutter_hour"],
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
	return "Who stopped the night bell, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they stopped the bell in."


static func cast_line() -> String:
	return "Cobb, lamp hand    Vesper, night ringer    Reed, stair hand"


static func ready_line() -> String:
	return "Pin who stopped the night bell, the room they stopped it in, and the hour. Then submit."


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
