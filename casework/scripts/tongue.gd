extends RefCounted

# The tongue.
#
# The player pins three facts about the cutting: who, the room the tongue was
# cut in, and the hour. The timeline also records who marked the groove, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the fence, where that turn was made, why the tongue was cut, where
# the peel was hung, when the punch was tallowed, when the scribe was ground, and
# when the knife was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The tongue"
const FILE_CODE := "CW-38"
const BLURB := "The tongue left its peg at the joiner's filly. Name who cut the tongue, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Shay", "Dell", "Glen"]
const PLACES: Array[String] = ["knife", "punch", "scribe"]
const HOURS: Array[String] = ["131", "132", "133", "134", "135"]
const AIMS: Array[String] = ["take_groove", "spare_groove", "set_groove"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Groove chit",
		"source": "Dell, groove hand",
		"text": "Shay cut the tongue. Dell had marked the groove, and a pale fleck still clung to the kerf.",
		"literals": [
			{
				"field": "taker",
				"value": "Shay",
				"phrase": "Shay cut the tongue",
			},
			{
				"field": "groove",
				"value": "Dell",
				"phrase": "Dell had marked the groove",
			},
		],
	},
	{
		"id": "E2",
		"title": "Face sight",
		"source": "Punch face",
		"text": "Shay cut the tongue. The cutting was seen from the punch, beside the open kerf.",
		"literals": [
			{
				"field": "taker",
				"value": "Shay",
				"phrase": "Shay cut the tongue",
			},
			{
				"field": "seen_from",
				"value": "punch",
				"phrase": "The cutting was seen from the punch",
			},
		],
	},
	{
		"id": "E3",
		"title": "Peel bill",
		"source": "Scribe nose",
		"text": "Shay cut the tongue. With the groove true, the peel was hung on the scribe.",
		"literals": [
			{
				"field": "taker",
				"value": "Shay",
				"phrase": "Shay cut the tongue",
			},
			{
				"field": "peel_room",
				"value": "scribe",
				"phrase": "the peel was hung on the scribe",
			},
		],
	},
	{
		"id": "E4",
		"title": "Kerf slate",
		"source": "Knife kerf",
		"text": "The tongue was cut in the knife. A fresh kerf shows the groove had been marked on the scribe.",
		"literals": [
			{
				"field": "place",
				"value": "knife",
				"phrase": "The tongue was cut in the knife",
			},
			{
				"field": "groove_room",
				"value": "scribe",
				"phrase": "the groove had been marked on the scribe",
			},
		],
	},
	{
		"id": "E5",
		"title": "Turn card",
		"source": "Glen, fence clerk",
		"text": "The tongue was cut in the knife. Glen turned the fence in the punch once the groove was offered.",
		"literals": [
			{
				"field": "place",
				"value": "knife",
				"phrase": "The tongue was cut in the knife",
			},
			{
				"field": "fence",
				"value": "Glen",
				"phrase": "Glen turned the fence",
			},
			{
				"field": "fence_room",
				"value": "punch",
				"phrase": "turned the fence in the punch",
			},
		],
	},
	{
		"id": "E6",
		"title": "Tallow slip",
		"source": "Punch tote",
		"text": "The tongue was cut in the knife. The punch was tallowed at 131, and a pale coat still sat on the kerf.",
		"literals": [
			{
				"field": "place",
				"value": "knife",
				"phrase": "The tongue was cut in the knife",
			},
			{
				"field": "tallow_hour",
				"value": "131",
				"phrase": "The punch was tallowed at 131",
			},
		],
	},
	{
		"id": "E7",
		"title": "Tongue leaf",
		"source": "Groove book",
		"text": "The tongue was cut at 133. The groove had been marked at 132, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "133",
				"phrase": "The tongue was cut at 133",
			},
			{
				"field": "groove_hour",
				"value": "132",
				"phrase": "The groove had been marked at 132",
			},
		],
	},
	{
		"id": "E8",
		"title": "Filly note",
		"source": "Joiner's filly",
		"text": "The tongue was cut at 133. The groove was opened so the groove would take the tongue.",
		"literals": [
			{
				"field": "hour",
				"value": "133",
				"phrase": "The tongue was cut at 133",
			},
			{
				"field": "aim",
				"value": "take_groove",
				"phrase": "so the groove would take the tongue",
			},
		],
	},
	{
		"id": "E9",
		"title": "Grind order",
		"source": "Scribe card",
		"text": "The tongue was cut at 133. The scribe was ground at 134, and the knife was hung at 135 once the groove was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "133",
				"phrase": "The tongue was cut at 133",
			},
			{
				"field": "grind_hour",
				"value": "134",
				"phrase": "The scribe was ground at 134",
			},
			{
				"field": "hang_hour",
				"value": "135",
				"phrase": "the knife was hung at 135",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"groove",
		"groove_room",
		"groove_hour",
		"seen_from",
		"fence",
		"aim",
		"fence_room",
		"peel_room",
		"tallow_hour",
		"grind_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "groove", "fence":
			return PEOPLE.duplicate()
		"place", "groove_room", "seen_from", "fence_room", "peel_room":
			return PLACES.duplicate()
		"hour", "groove_hour", "tallow_hour", "grind_hour", "hang_hour":
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
		missing.append("who cut the tongue")
	if pins["place"] == "":
		missing.append("where they cut the tongue")
	if pins["hour"] == "":
		missing.append("at which hour they cut the tongue")
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
		"Shay":
			return "the tongue hand"
		"Dell":
			return "the groove hand"
		"Glen":
			return "the fence clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"knife":
			return "knife"
		"punch":
			return "punch"
		"scribe":
			return "scribe"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"knife":
			return "Knife"
		"punch":
			return "Punch"
		"scribe":
			return "Scribe"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the tongue" % value
		"place":
			return "The tongue was cut in the %s" % place_label(value)
		"hour":
			return "The tongue was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the tongue" % value
		"place":
			return "the tongue was cut in the %s" % place_label(value)
		"hour":
			return "the tongue was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the tongue" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_groove":
			return "so the groove would take the tongue"
		"spare_groove":
			return "to spare the groove still waiting on the tongue"
		"set_groove":
			return "to set the groove before the knife was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the tongue in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the groove on the %s at %s." % [
			model["groove"],
			role_short(str(model["groove"])),
			place_label(str(model["groove_room"])),
			model["groove_hour"],
		],
		"%s (%s) turned the fence in the %s." % [
			model["fence"],
			role_short(str(model["fence"])),
			place_label(str(model["fence_room"])),
		],
		"The peel was hung on the %s." % place_label(str(model["peel_room"])),
		"The punch was tallowed at %s." % model["tallow_hour"],
		"The scribe was ground at %s." % model["grind_hour"],
		"The knife was hung at %s." % model["hang_hour"],
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
	return "Who cut the tongue, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the tongue in."


static func cast_line() -> String:
	return "Shay, tongue hand    Dell, groove hand    Glen, fence clerk"


static func ready_line() -> String:
	return "Pin who cut the tongue, the room they cut it in, and the hour. Then submit."


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
