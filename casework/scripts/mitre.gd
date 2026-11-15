extends RefCounted

# The mitre.
#
# The player pins three facts about the cutting: who, the room the mitre was
# cut in, and the hour. The timeline also records who marked the arris, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the stop, where that turn was made, why the mitre was cut, where
# the offcut was hung, when the float was dressed, when the gimlet was brushed, and
# when the plough was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The mitre"
const FILE_CODE := "CW-32"
const BLURB := "The mitre left its peg at the joiner's saddle. Name who cut the mitre, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Orrin", "Venn", "Haim"]
const PLACES: Array[String] = ["plough", "float", "gimlet"]
const HOURS: Array[String] = ["101", "102", "103", "104", "105"]
const AIMS: Array[String] = ["take_arris", "spare_arris", "set_arris"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Arris chit",
		"source": "Venn, kerf hand",
		"text": "Orrin cut the mitre. Venn had marked the arris, and a pale curl still clung to the horn.",
		"literals": [
			{
				"field": "taker",
				"value": "Orrin",
				"phrase": "Orrin cut the mitre",
			},
			{
				"field": "arriser",
				"value": "Venn",
				"phrase": "Venn had marked the arris",
			},
		],
	},
	{
		"id": "E2",
		"title": "Horn sight",
		"source": "Float horn",
		"text": "Orrin cut the mitre. The cutting was seen from the float, past the open horn.",
		"literals": [
			{
				"field": "taker",
				"value": "Orrin",
				"phrase": "Orrin cut the mitre",
			},
			{
				"field": "seen_from",
				"value": "float",
				"phrase": "The cutting was seen from the float",
			},
		],
	},
	{
		"id": "E3",
		"title": "Offcut hook",
		"source": "Gimlet brad",
		"text": "Orrin cut the mitre. With the arris true, the offcut was hung on the gimlet.",
		"literals": [
			{
				"field": "taker",
				"value": "Orrin",
				"phrase": "Orrin cut the mitre",
			},
			{
				"field": "offcut_room",
				"value": "gimlet",
				"phrase": "the offcut was hung on the gimlet",
			},
		],
	},
	{
		"id": "E4",
		"title": "Arris slate",
		"source": "Plough horn",
		"text": "The mitre was cut in the plough. A fresh edge shows the arris had been marked on the gimlet.",
		"literals": [
			{
				"field": "place",
				"value": "plough",
				"phrase": "The mitre was cut in the plough",
			},
			{
				"field": "arris_room",
				"value": "gimlet",
				"phrase": "the arris had been marked on the gimlet",
			},
		],
	},
	{
		"id": "E5",
		"title": "Stop card",
		"source": "Haim, bit clerk",
		"text": "The mitre was cut in the plough. Haim turned the stop in the float before the arris was offered.",
		"literals": [
			{
				"field": "place",
				"value": "plough",
				"phrase": "The mitre was cut in the plough",
			},
			{
				"field": "stop",
				"value": "Haim",
				"phrase": "Haim turned the stop",
			},
			{
				"field": "stop_room",
				"value": "float",
				"phrase": "turned the stop in the float",
			},
		],
	},
	{
		"id": "E6",
		"title": "Dress slip",
		"source": "Float pad",
		"text": "The mitre was cut in the plough. The float was dressed at 101, and a pale film still sat on the horn.",
		"literals": [
			{
				"field": "place",
				"value": "plough",
				"phrase": "The mitre was cut in the plough",
			},
			{
				"field": "dress_hour",
				"value": "101",
				"phrase": "The float was dressed at 101",
			},
		],
	},
	{
		"id": "E7",
		"title": "Arris leaf",
		"source": "Arris book",
		"text": "The mitre was cut at 103. The arris had been marked at 102, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "103",
				"phrase": "The mitre was cut at 103",
			},
			{
				"field": "arris_hour",
				"value": "102",
				"phrase": "The arris had been marked at 102",
			},
		],
	},
	{
		"id": "E8",
		"title": "Arris note",
		"source": "Joiner's saddle",
		"text": "The mitre was cut at 103. The arris was opened so the arris would take the mitre.",
		"literals": [
			{
				"field": "hour",
				"value": "103",
				"phrase": "The mitre was cut at 103",
			},
			{
				"field": "aim",
				"value": "take_arris",
				"phrase": "so the arris would take the mitre",
			},
		],
	},
	{
		"id": "E9",
		"title": "Brush order",
		"source": "Gimlet pad",
		"text": "The mitre was cut at 103. The gimlet was brushed at 104, and the plough was hung at 105 once the arris was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "103",
				"phrase": "The mitre was cut at 103",
			},
			{
				"field": "brush_hour",
				"value": "104",
				"phrase": "The gimlet was brushed at 104",
			},
			{
				"field": "hang_hour",
				"value": "105",
				"phrase": "the plough was hung at 105",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"arriser",
		"arris_room",
		"arris_hour",
		"seen_from",
		"stop",
		"aim",
		"stop_room",
		"offcut_room",
		"dress_hour",
		"brush_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "arriser", "stop":
			return PEOPLE.duplicate()
		"place", "arris_room", "seen_from", "stop_room", "offcut_room":
			return PLACES.duplicate()
		"hour", "arris_hour", "dress_hour", "brush_hour", "hang_hour":
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
		missing.append("who cut the mitre")
	if pins["place"] == "":
		missing.append("where they cut the mitre")
	if pins["hour"] == "":
		missing.append("at which hour they cut the mitre")
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
		"Orrin":
			return "the saddle hand"
		"Venn":
			return "the kerf hand"
		"Haim":
			return "the bit clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"plough":
			return "plough"
		"float":
			return "float"
		"gimlet":
			return "gimlet"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"plough":
			return "Plough"
		"float":
			return "Float"
		"gimlet":
			return "Gimlet"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the mitre" % value
		"place":
			return "The mitre was cut in the %s" % place_label(value)
		"hour":
			return "The mitre was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the mitre" % value
		"place":
			return "the mitre was cut in the %s" % place_label(value)
		"hour":
			return "the mitre was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the mitre" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_arris":
			return "so the arris would take the mitre"
		"spare_arris":
			return "to spare the arris still waiting on the mitre"
		"set_arris":
			return "to set the arris before the plough was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the mitre in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the arris on the %s at %s." % [
			model["arriser"],
			role_short(str(model["arriser"])),
			place_label(str(model["arris_room"])),
			model["arris_hour"],
		],
		"%s (%s) turned the stop in the %s." % [
			model["stop"],
			role_short(str(model["stop"])),
			place_label(str(model["stop_room"])),
		],
		"The offcut was hung on the %s." % place_label(str(model["offcut_room"])),
		"The float was dressed at %s." % model["dress_hour"],
		"The gimlet was brushed at %s." % model["brush_hour"],
		"The plough was hung at %s." % model["hang_hour"],
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
	return "Who cut the mitre, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the mitre in."


static func cast_line() -> String:
	return "Orrin, saddle hand    Venn, kerf hand    Haim, bit clerk"


static func ready_line() -> String:
	return "Pin who cut the mitre, the room they cut it in, and the hour. Then submit."


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
