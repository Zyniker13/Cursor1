extends RefCounted

# The ferry bell.
#
# The player pins three facts about the taking: who, the room the bell was
# taken to, and the hour. The timeline also records who sounded the landing
# whistle, where that whistle was sounded, who held the painter, where and at
# which hour the painter was held, where the bell was taken from, why it was
# taken, and when the boat answered. Each exhibit states exactly one of those
# three pins, and that pin's true value is stated by exactly one other
# exhibit, so the pins are three pairs rather than one fact stated three
# times. Each exhibit also states at least one fact no other exhibit states.
# Exactly one full timeline fits every exhibit. Drop any exhibit and another
# timeline fits. Any other pin triple disagrees with at least two exhibits.

const TITLE := "The ferry bell"
const FILE_CODE := "CW-04"
const BLURB := "The ferry bell left the ticket window at the landing. Name who took it, the room they took it to, and the hour."

const PEOPLE: Array[String] = ["Wren", "Hale", "Quill"]
const PLACES: Array[String] = ["jetty_shed", "rope_loft", "ticket_window"]
const HOURS: Array[String] = ["14", "15", "16"]
const PURPOSES: Array[String] = ["call_boat", "late_ticket", "storm_line"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Whistle slip",
		"source": "Wren, pilot",
		"text": "Quill, the ropehand, is the person who took the ferry bell. Wren, the pilot, is the person who sounded the landing whistle.",
		"literals": [
			{
				"field": "taker",
				"value": "Quill",
				"phrase": "Quill, the ropehand, is the person who took the ferry bell",
			},
			{
				"field": "whistler",
				"value": "Wren",
				"phrase": "Wren, the pilot, is the person who sounded the landing whistle",
			},
		],
	},
	{
		"id": "E2",
		"title": "Shed card",
		"source": "Jetty shed",
		"text": "Quill, the ropehand, is the person who took the ferry bell. The landing whistle was sounded in the jetty shed, and the ferry bell was taken from the ticket window.",
		"literals": [
			{
				"field": "taker",
				"value": "Quill",
				"phrase": "Quill, the ropehand, is the person who took the ferry bell",
			},
			{
				"field": "whistle_place",
				"value": "jetty_shed",
				"phrase": "The landing whistle was sounded in the jetty shed",
			},
			{
				"field": "origin",
				"value": "ticket_window",
				"phrase": "the ferry bell was taken from the ticket window",
			},
		],
	},
	{
		"id": "E3",
		"title": "Painter line",
		"source": "Hale, landing clerk",
		"text": "The ferry bell was taken to the rope loft. Hale, the landing clerk, is the person who held the painter.",
		"literals": [
			{
				"field": "place",
				"value": "rope_loft",
				"phrase": "The ferry bell was taken to the rope loft",
			},
			{
				"field": "holder",
				"value": "Hale",
				"phrase": "Hale, the landing clerk, is the person who held the painter",
			},
		],
	},
	{
		"id": "E4",
		"title": "Window note",
		"source": "Ticket window",
		"text": "The ferry bell was taken to the rope loft. The painter was held at the ticket window at 14.",
		"literals": [
			{
				"field": "place",
				"value": "rope_loft",
				"phrase": "The ferry bell was taken to the rope loft",
			},
			{
				"field": "hold_place",
				"value": "ticket_window",
				"phrase": "The painter was held at the ticket window",
			},
			{
				"field": "hold_hour",
				"value": "14",
				"phrase": "The painter was held at the ticket window at 14",
			},
		],
	},
	{
		"id": "E5",
		"title": "Call chit",
		"source": "Rope loft",
		"text": "15 is the hour at which the ferry bell was taken. The ferry bell was taken in order to call the late boat.",
		"literals": [
			{
				"field": "hour",
				"value": "15",
				"phrase": "15 is the hour at which the ferry bell was taken",
			},
			{
				"field": "purpose",
				"value": "call_boat",
				"phrase": "The ferry bell was taken in order to call the late boat",
			},
		],
	},
	{
		"id": "E6",
		"title": "Answer line",
		"source": "Landing book",
		"text": "15 is the hour at which the ferry bell was taken. 16 is the hour at which the boat answered.",
		"literals": [
			{
				"field": "hour",
				"value": "15",
				"phrase": "15 is the hour at which the ferry bell was taken",
			},
			{
				"field": "answer_hour",
				"value": "16",
				"phrase": "16 is the hour at which the boat answered",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"whistler",
		"whistle_place",
		"holder",
		"hold_place",
		"hold_hour",
		"origin",
		"purpose",
		"answer_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "whistler", "holder":
			return PEOPLE.duplicate()
		"place", "whistle_place", "hold_place", "origin":
			return PLACES.duplicate()
		"hour", "hold_hour", "answer_hour":
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
		missing.append("who took the ferry bell")
	if pins["place"] == "":
		missing.append("where they took the bell")
	if pins["hour"] == "":
		missing.append("at which hour they took the bell")
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
		"Wren":
			return "the pilot"
		"Hale":
			return "the landing clerk"
		"Quill":
			return "the ropehand"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"jetty_shed":
			return "jetty shed"
		"rope_loft":
			return "rope loft"
		"ticket_window":
			return "ticket window"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"jetty_shed":
			return "Jetty shed"
		"rope_loft":
			return "Rope loft"
		"ticket_window":
			return "Ticket window"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s, %s, is the person who took the ferry bell" % [value, role_phrase(value)]
		"place":
			return "The ferry bell was taken to the %s" % place_label(value)
		"hour":
			return "%s is the hour at which the ferry bell was taken" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s took the ferry bell" % value
		"place":
			return "the ferry bell was taken to the %s" % place_label(value)
		"hour":
			return "the ferry bell was taken at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s took the ferry bell" % value
		"place":
			return "it was taken to the %s" % place_label(value)
		"hour":
			return "it was taken at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"call_boat":
			return "to call the late boat"
		"late_ticket":
			return "to stamp a late ticket"
		"storm_line":
			return "to rig the storm line"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) took the ferry bell at %s from the %s to the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			model["hour"],
			place_label(str(model["origin"])),
			place_label(str(model["place"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) sounded the landing whistle in the %s." % [
			model["whistler"],
			role_short(str(model["whistler"])),
			place_label(str(model["whistle_place"])),
		],
		"%s (%s) held the painter at %s at the %s." % [
			model["holder"],
			role_short(str(model["holder"])),
			model["hold_hour"],
			place_label(str(model["hold_place"])),
		],
		"The boat answered at %s." % model["answer_hour"],
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
	return "The file  ·  six exhibits"


static func board_question() -> String:
	return "Who took the ferry bell, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they took the bell to."


static func cast_line() -> String:
	return "Wren, pilot    Hale, landing clerk    Quill, ropehand"


static func ready_line() -> String:
	return "Pin who took the ferry bell, the room they took it to, and the hour. Then submit."


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
