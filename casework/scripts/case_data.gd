extends RefCounted

# The spare key.
#
# The player pins three facts about the taking: who, the room the key was
# taken to, and the hour. The timeline also records the notice, the return,
# the place the key was taken from, and why it was taken. Each exhibit states
# the true value of one of those three pins (a value at least one other
# exhibit also states) and at least one fact no other exhibit states.
# Exactly one full timeline fits every exhibit. Drop any exhibit and another
# timeline fits. Any other pin triple disagrees with at least two exhibits.

const PEOPLE: Array[String] = ["Nell", "Moss", "Ada"]
const PLACES: Array[String] = ["front_desk", "kitchen", "pantry"]
const HOURS: Array[String] = ["7", "8", "9"]
const PURPOSES: Array[String] = ["pantry_lock", "guest_copy", "night_round"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Complaint slip",
		"source": "Moss, lodger",
		"text": "Nell, the night cook, is the person who took the spare key. Moss, the lodger, is the person who noticed the empty hook and wrote this complaint.",
		"literals": [
			{
				"field": "taker",
				"value": "Nell",
				"phrase": "Nell, the night cook, is the person who took the spare key",
			},
			{
				"field": "notifier",
				"value": "Moss",
				"phrase": "Moss, the lodger, is the person who noticed the empty hook and wrote this complaint",
			},
		],
	},
	{
		"id": "E2",
		"title": "Complaint, second line",
		"source": "Moss, lodger",
		"text": "7 is the hour at which the spare key was taken. The empty hook was noticed at the front desk.",
		"literals": [
			{
				"field": "hour",
				"value": "7",
				"phrase": "7 is the hour at which the spare key was taken",
			},
			{
				"field": "notice_place",
				"value": "front_desk",
				"phrase": "The empty hook was noticed at the front desk",
			},
		],
	},
	{
		"id": "E3",
		"title": "Hook card",
		"source": "Spare-key hook",
		"text": "7 is the hour at which the spare key was taken. The spare key was taken from the front desk.",
		"literals": [
			{
				"field": "hour",
				"value": "7",
				"phrase": "7 is the hour at which the spare key was taken",
			},
			{
				"field": "origin",
				"value": "front_desk",
				"phrase": "The spare key was taken from the front desk",
			},
		],
	},
	{
		"id": "E4",
		"title": "Kitchen slate",
		"source": "Kitchen",
		"text": "The spare key was taken to the kitchen. 8 is the hour at which the empty hook was noticed.",
		"literals": [
			{
				"field": "place",
				"value": "kitchen",
				"phrase": "The spare key was taken to the kitchen",
			},
			{
				"field": "notice_hour",
				"value": "8",
				"phrase": "8 is the hour at which the empty hook was noticed",
			},
		],
	},
	{
		"id": "E5",
		"title": "Pantry chit",
		"source": "Kitchen, by the pantry",
		"text": "Nell, the night cook, is the person who took the spare key. The spare key was taken in order to lock the pantry.",
		"literals": [
			{
				"field": "taker",
				"value": "Nell",
				"phrase": "Nell, the night cook, is the person who took the spare key",
			},
			{
				"field": "purpose",
				"value": "pantry_lock",
				"phrase": "The spare key was taken in order to lock the pantry",
			},
		],
	},
	{
		"id": "E6",
		"title": "Return line",
		"source": "Ada, clerk",
		"text": "Nell, the night cook, is the person who took the spare key. Ada, the clerk, is the person who logged the key returned, at the front desk.",
		"literals": [
			{
				"field": "taker",
				"value": "Nell",
				"phrase": "Nell, the night cook, is the person who took the spare key",
			},
			{
				"field": "returner",
				"value": "Ada",
				"phrase": "Ada, the clerk, is the person who logged the key returned, at the front desk",
			},
			{
				"field": "return_place",
				"value": "front_desk",
				"phrase": "Ada, the clerk, is the person who logged the key returned, at the front desk",
			},
		],
	},
	{
		"id": "E7",
		"title": "Desk-book margin",
		"source": "Front desk book",
		"text": "The spare key was taken to the kitchen. 9 is the hour at which the return was logged.",
		"literals": [
			{
				"field": "place",
				"value": "kitchen",
				"phrase": "The spare key was taken to the kitchen",
			},
			{
				"field": "return_hour",
				"value": "9",
				"phrase": "9 is the hour at which the return was logged",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"notifier",
		"returner",
		"notice_hour",
		"return_hour",
		"notice_place",
		"origin",
		"return_place",
		"purpose",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "notifier", "returner":
			return PEOPLE.duplicate()
		"place", "notice_place", "origin", "return_place":
			return PLACES.duplicate()
		"hour", "notice_hour", "return_hour":
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
		missing.append("who took the spare key")
	if pins["place"] == "":
		missing.append("where they took the key")
	if pins["hour"] == "":
		missing.append("at which hour they took the key")
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
		"Nell":
			return "the night cook"
		"Moss":
			return "the lodger"
		"Ada":
			return "the clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"front_desk":
			return "front desk"
		"kitchen":
			return "kitchen"
		"pantry":
			return "pantry"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"front_desk":
			return "Front desk"
		"kitchen":
			return "Kitchen"
		"pantry":
			return "Pantry"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s, %s, is the person who took the spare key" % [value, role_phrase(value)]
		"place":
			return "The spare key was taken to the %s" % place_label(value)
		"hour":
			return "%s is the hour at which the spare key was taken" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s took the spare key" % value
		"place":
			return "the spare key was taken to the %s" % place_label(value)
		"hour":
			return "the spare key was taken at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s took the spare key" % value
		"place":
			return "it was taken to the %s" % place_label(value)
		"hour":
			return "it was taken at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"pantry_lock":
			return "to lock the pantry"
		"guest_copy":
			return "to cut a guest copy"
		"night_round":
			return "to walk the night round"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) took the spare key at %s from the %s to the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			model["hour"],
			place_label(str(model["origin"])),
			place_label(str(model["place"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) noticed the hook empty at %s at the %s and wrote a complaint." % [
			model["notifier"],
			role_short(str(model["notifier"])),
			model["notice_hour"],
			place_label(str(model["notice_place"])),
		],
		"%s (%s) logged the key returned at %s at the %s." % [
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
