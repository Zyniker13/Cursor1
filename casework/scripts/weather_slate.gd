extends RefCounted

# The weather slate.
#
# The player pins three facts about the taking: who, the room the slate was
# taken to, and the hour. The timeline also records who left the request,
# where and at which hour that request was left, where the slate was taken
# from, why it was taken, who saw the carrying, where it was seen from, and
# when the old reading was chalked. The taker and the hour are each stated
# by three exhibits. The room is stated by two. The taking is the latest
# hour in the file, and the room is the first room in the file. Each exhibit
# states one of those three pins (a value at least one other exhibit also
# states) and at least one fact no other exhibit states. Exactly one full
# timeline fits every exhibit. Drop any exhibit and another timeline fits.
# Any other pin triple disagrees with at least two exhibits.

const TITLE := "The weather slate"
const FILE_CODE := "CW-05"
const BLURB := "The weather slate left its peg at the hill station. Name who took it, the room they took it to, and the hour."

const PEOPLE: Array[String] = ["Pim", "Vesper", "Soren"]
const PLACES: Array[String] = ["map_alcove", "peg_room", "tower_stair"]
const HOURS: Array[String] = ["10", "11", "12"]
const PURPOSES: Array[String] = ["frost_line", "gale_mark", "dawn_copy"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Stair chit",
		"source": "Tower stair",
		"text": "12 is the hour at which the weather slate was taken. 10 is the hour at which the request was left.",
		"literals": [
			{
				"field": "hour",
				"value": "12",
				"phrase": "12 is the hour at which the weather slate was taken",
			},
			{
				"field": "request_hour",
				"value": "10",
				"phrase": "10 is the hour at which the request was left",
			},
		],
	},
	{
		"id": "E2",
		"title": "Reader line",
		"source": "Soren, reader",
		"text": "12 is the hour at which the weather slate was taken. Soren, the reader, is the person who left the request.",
		"literals": [
			{
				"field": "hour",
				"value": "12",
				"phrase": "12 is the hour at which the weather slate was taken",
			},
			{
				"field": "requester",
				"value": "Soren",
				"phrase": "Soren, the reader, is the person who left the request",
			},
		],
	},
	{
		"id": "E3",
		"title": "Request card",
		"source": "Tower stair book",
		"text": "12 is the hour at which the weather slate was taken. The request was left on the tower stair.",
		"literals": [
			{
				"field": "hour",
				"value": "12",
				"phrase": "12 is the hour at which the weather slate was taken",
			},
			{
				"field": "request_place",
				"value": "tower_stair",
				"phrase": "The request was left on the tower stair",
			},
		],
	},
	{
		"id": "E4",
		"title": "Peg tag",
		"source": "Peg room",
		"text": "Pim, the runner, is the person who took the weather slate. The weather slate was taken from the peg room.",
		"literals": [
			{
				"field": "taker",
				"value": "Pim",
				"phrase": "Pim, the runner, is the person who took the weather slate",
			},
			{
				"field": "origin",
				"value": "peg_room",
				"phrase": "The weather slate was taken from the peg room",
			},
		],
	},
	{
		"id": "E5",
		"title": "Frost note",
		"source": "Map alcove",
		"text": "Pim, the runner, is the person who took the weather slate. The weather slate was taken in order to copy the frost line.",
		"literals": [
			{
				"field": "taker",
				"value": "Pim",
				"phrase": "Pim, the runner, is the person who took the weather slate",
			},
			{
				"field": "purpose",
				"value": "frost_line",
				"phrase": "The weather slate was taken in order to copy the frost line",
			},
		],
	},
	{
		"id": "E6",
		"title": "Watch line",
		"source": "Vesper, night watch",
		"text": "Pim, the runner, is the person who took the weather slate. Vesper, the night watch, is the person who saw the carrying.",
		"literals": [
			{
				"field": "taker",
				"value": "Pim",
				"phrase": "Pim, the runner, is the person who took the weather slate",
			},
			{
				"field": "witness",
				"value": "Vesper",
				"phrase": "Vesper, the night watch, is the person who saw the carrying",
			},
		],
	},
	{
		"id": "E7",
		"title": "Alcove card",
		"source": "Map alcove",
		"text": "The weather slate was taken to the map alcove. The carrying was seen from the peg room.",
		"literals": [
			{
				"field": "place",
				"value": "map_alcove",
				"phrase": "The weather slate was taken to the map alcove",
			},
			{
				"field": "witness_place",
				"value": "peg_room",
				"phrase": "The carrying was seen from the peg room",
			},
		],
	},
	{
		"id": "E8",
		"title": "Chalk margin",
		"source": "Peg room book",
		"text": "The weather slate was taken to the map alcove. 11 is the hour at which the old reading was chalked.",
		"literals": [
			{
				"field": "place",
				"value": "map_alcove",
				"phrase": "The weather slate was taken to the map alcove",
			},
			{
				"field": "chalk_hour",
				"value": "11",
				"phrase": "11 is the hour at which the old reading was chalked",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"requester",
		"request_place",
		"request_hour",
		"origin",
		"purpose",
		"witness",
		"witness_place",
		"chalk_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "requester", "witness":
			return PEOPLE.duplicate()
		"place", "request_place", "origin", "witness_place":
			return PLACES.duplicate()
		"hour", "request_hour", "chalk_hour":
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
		missing.append("who took the weather slate")
	if pins["place"] == "":
		missing.append("where they took the slate")
	if pins["hour"] == "":
		missing.append("at which hour they took the slate")
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
		"Pim":
			return "the runner"
		"Vesper":
			return "the night watch"
		"Soren":
			return "the reader"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"map_alcove":
			return "map alcove"
		"peg_room":
			return "peg room"
		"tower_stair":
			return "tower stair"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"map_alcove":
			return "Map alcove"
		"peg_room":
			return "Peg room"
		"tower_stair":
			return "Tower stair"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s, %s, is the person who took the weather slate" % [value, role_phrase(value)]
		"place":
			return "The weather slate was taken to the %s" % place_label(value)
		"hour":
			return "%s is the hour at which the weather slate was taken" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s took the weather slate" % value
		"place":
			return "the weather slate was taken to the %s" % place_label(value)
		"hour":
			return "the weather slate was taken at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s took the weather slate" % value
		"place":
			return "it was taken to the %s" % place_label(value)
		"hour":
			return "it was taken at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"frost_line":
			return "to copy the frost line"
		"gale_mark":
			return "to mark the gale"
		"dawn_copy":
			return "to copy the dawn line"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) took the weather slate at %s from the %s to the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			model["hour"],
			place_label(str(model["origin"])),
			place_label(str(model["place"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) left the request at %s on the %s." % [
			model["requester"],
			role_short(str(model["requester"])),
			model["request_hour"],
			place_label(str(model["request_place"])),
		],
		"%s (%s) saw the carrying from the %s." % [
			model["witness"],
			role_short(str(model["witness"])),
			place_label(str(model["witness_place"])),
		],
		"The old reading was chalked at %s." % model["chalk_hour"],
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
	return "Who took the weather slate, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they took the slate to."


static func cast_line() -> String:
	return "Pim, runner    Vesper, night watch    Soren, reader"


static func ready_line() -> String:
	return "Pin who took the weather slate, the room they took it to, and the hour. Then submit."


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
