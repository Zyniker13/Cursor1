extends RefCounted

# The lap.
#
# The player pins three facts about the cutting: who, the room the lap was
# cut in, and the hour. The timeline also records who marked the grain, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the brad, where that turn was made, why the lap was cut, where
# the paring was hung, when the float was skimmed, when the gimlet was oiled, and
# when the plough was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The lap"
const FILE_CODE := "CW-33"
const BLURB := "The lap left its peg at the joiner's cradle. Name who cut the lap, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Nye", "Yew", "Pry"]
const PLACES: Array[String] = ["plough", "float", "gimlet"]
const HOURS: Array[String] = ["106", "107", "108", "109", "110"]
const AIMS: Array[String] = ["take_grain", "spare_grain", "set_grain"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Grain chit",
		"source": "Yew, grain hand",
		"text": "Nye cut the lap. Yew had marked the grain, and a pale curl still clung to the horn.",
		"literals": [
			{
				"field": "taker",
				"value": "Nye",
				"phrase": "Nye cut the lap",
			},
			{
				"field": "grainer",
				"value": "Yew",
				"phrase": "Yew had marked the grain",
			},
		],
	},
	{
		"id": "E2",
		"title": "Crest sight",
		"source": "Float crest",
		"text": "Nye cut the lap. The cutting was seen from the float, beside the open horn.",
		"literals": [
			{
				"field": "taker",
				"value": "Nye",
				"phrase": "Nye cut the lap",
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
		"title": "Paring hook",
		"source": "Gimlet point",
		"text": "Nye cut the lap. With the grain true, the paring was hung on the gimlet.",
		"literals": [
			{
				"field": "taker",
				"value": "Nye",
				"phrase": "Nye cut the lap",
			},
			{
				"field": "paring_room",
				"value": "gimlet",
				"phrase": "the paring was hung on the gimlet",
			},
		],
	},
	{
		"id": "E4",
		"title": "Grain slate",
		"source": "Plough lip",
		"text": "The lap was cut in the plough. A fresh edge shows the grain had been marked on the gimlet.",
		"literals": [
			{
				"field": "place",
				"value": "plough",
				"phrase": "The lap was cut in the plough",
			},
			{
				"field": "grain_room",
				"value": "gimlet",
				"phrase": "the grain had been marked on the gimlet",
			},
		],
	},
	{
		"id": "E5",
		"title": "Brad card",
		"source": "Pry, brad clerk",
		"text": "The lap was cut in the plough. Pry turned the brad in the float before the grain was offered.",
		"literals": [
			{
				"field": "place",
				"value": "plough",
				"phrase": "The lap was cut in the plough",
			},
			{
				"field": "brad",
				"value": "Pry",
				"phrase": "Pry turned the brad",
			},
			{
				"field": "brad_room",
				"value": "float",
				"phrase": "turned the brad in the float",
			},
		],
	},
	{
		"id": "E6",
		"title": "Skim slip",
		"source": "Float board",
		"text": "The lap was cut in the plough. The float was skimmed at 106, and a pale film still sat on the horn.",
		"literals": [
			{
				"field": "place",
				"value": "plough",
				"phrase": "The lap was cut in the plough",
			},
			{
				"field": "skim_hour",
				"value": "106",
				"phrase": "The float was skimmed at 106",
			},
		],
	},
	{
		"id": "E7",
		"title": "Grain leaf",
		"source": "Grain book",
		"text": "The lap was cut at 108. The grain had been marked at 107, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "108",
				"phrase": "The lap was cut at 108",
			},
			{
				"field": "grain_hour",
				"value": "107",
				"phrase": "The grain had been marked at 107",
			},
		],
	},
	{
		"id": "E8",
		"title": "Grain note",
		"source": "Joiner's cradle",
		"text": "The lap was cut at 108. The grain was opened so the grain would take the lap.",
		"literals": [
			{
				"field": "hour",
				"value": "108",
				"phrase": "The lap was cut at 108",
			},
			{
				"field": "aim",
				"value": "take_grain",
				"phrase": "so the grain would take the lap",
			},
		],
	},
	{
		"id": "E9",
		"title": "Oil order",
		"source": "Gimlet card",
		"text": "The lap was cut at 108. The gimlet was oiled at 109, and the plough was hung at 110 once the grain was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "108",
				"phrase": "The lap was cut at 108",
			},
			{
				"field": "oil_hour",
				"value": "109",
				"phrase": "The gimlet was oiled at 109",
			},
			{
				"field": "hang_hour",
				"value": "110",
				"phrase": "the plough was hung at 110",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"grainer",
		"grain_room",
		"grain_hour",
		"seen_from",
		"brad",
		"aim",
		"brad_room",
		"paring_room",
		"skim_hour",
		"oil_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "grainer", "brad":
			return PEOPLE.duplicate()
		"place", "grain_room", "seen_from", "brad_room", "paring_room":
			return PLACES.duplicate()
		"hour", "grain_hour", "skim_hour", "oil_hour", "hang_hour":
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
		missing.append("who cut the lap")
	if pins["place"] == "":
		missing.append("where they cut the lap")
	if pins["hour"] == "":
		missing.append("at which hour they cut the lap")
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
		"Nye":
			return "the cradle hand"
		"Yew":
			return "the grain hand"
		"Pry":
			return "the brad clerk"
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
			return "%s cut the lap" % value
		"place":
			return "The lap was cut in the %s" % place_label(value)
		"hour":
			return "The lap was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the lap" % value
		"place":
			return "the lap was cut in the %s" % place_label(value)
		"hour":
			return "the lap was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the lap" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_grain":
			return "so the grain would take the lap"
		"spare_grain":
			return "to spare the grain still waiting on the lap"
		"set_grain":
			return "to set the grain before the plough was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the lap in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the grain on the %s at %s." % [
			model["grainer"],
			role_short(str(model["grainer"])),
			place_label(str(model["grain_room"])),
			model["grain_hour"],
		],
		"%s (%s) turned the brad in the %s." % [
			model["brad"],
			role_short(str(model["brad"])),
			place_label(str(model["brad_room"])),
		],
		"The paring was hung on the %s." % place_label(str(model["paring_room"])),
		"The float was skimmed at %s." % model["skim_hour"],
		"The gimlet was oiled at %s." % model["oil_hour"],
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
	return "Who cut the lap, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the lap in."


static func cast_line() -> String:
	return "Nye, cradle hand    Yew, grain hand    Pry, brad clerk"


static func ready_line() -> String:
	return "Pin who cut the lap, the room they cut it in, and the hour. Then submit."


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
