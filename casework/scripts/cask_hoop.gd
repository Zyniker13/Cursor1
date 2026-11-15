extends RefCounted

# The cask hoop.
#
# The player pins three facts about the driving: who, the room the hoop was
# driven in, and the hour. The timeline also records who cut the hoop, where
# it was cut, when that cutting was done, where the driving was seen from, who
# turned the croze, where that turn was made, why the hoop was driven, where
# the driver was hung, when the yard was swept, when the bench was wiped, and
# when the shop was closed. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the driving is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The cask hoop"
const FILE_CODE := "CW-22"
const BLURB := "The cask hoop left its peg at the cooperage. Name who drove the hoop, the room they drove it in, and the hour."

const PEOPLE: Array[String] = ["Jory", "Maeve", "Perrin"]
const PLACES: Array[String] = ["shop", "yard", "bench"]
const HOURS: Array[String] = ["1", "2", "3", "4", "5"]
const PURPOSES: Array[String] = ["take_cask", "spare_stave", "seat_head"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Hoop chit",
		"source": "Jory, hoop hand",
		"text": "Maeve drove the hoop. Jory had cut the hoop and left the scarf proud of the stave.",
		"literals": [
			{
				"field": "taker",
				"value": "Maeve",
				"phrase": "Maeve drove the hoop",
			},
			{
				"field": "cutter",
				"value": "Jory",
				"phrase": "Jory had cut the hoop",
			},
		],
	},
	{
		"id": "E2",
		"title": "Yard sight",
		"source": "Yard door",
		"text": "Maeve drove the hoop. The driving was seen from the yard, between the stacked heads.",
		"literals": [
			{
				"field": "taker",
				"value": "Maeve",
				"phrase": "Maeve drove the hoop",
			},
			{
				"field": "seen_from",
				"value": "yard",
				"phrase": "The driving was seen from the yard",
			},
		],
	},
	{
		"id": "E3",
		"title": "Driver peg",
		"source": "Bench nail",
		"text": "Maeve drove the hoop. Once the hoop sat tight, the driver was hung on the bench.",
		"literals": [
			{
				"field": "taker",
				"value": "Maeve",
				"phrase": "Maeve drove the hoop",
			},
			{
				"field": "driver_place",
				"value": "bench",
				"phrase": "the driver was hung on the bench",
			},
		],
	},
	{
		"id": "E4",
		"title": "Shop slate",
		"source": "Shop beam",
		"text": "The hoop was driven in the shop. A stave note says the hoop had been cut on the bench.",
		"literals": [
			{
				"field": "place",
				"value": "shop",
				"phrase": "The hoop was driven in the shop",
			},
			{
				"field": "cut_place",
				"value": "bench",
				"phrase": "the hoop had been cut on the bench",
			},
		],
	},
	{
		"id": "E5",
		"title": "Croze card",
		"source": "Perrin, yard clerk",
		"text": "The hoop was driven in the shop. Perrin turned the croze in the yard and kept the head from rocking.",
		"literals": [
			{
				"field": "place",
				"value": "shop",
				"phrase": "The hoop was driven in the shop",
			},
			{
				"field": "crozer",
				"value": "Perrin",
				"phrase": "Perrin turned the croze",
			},
			{
				"field": "croze_place",
				"value": "yard",
				"phrase": "turned the croze in the yard",
			},
		],
	},
	{
		"id": "E6",
		"title": "Sweep slip",
		"source": "Yard book",
		"text": "The hoop was driven in the shop. The yard was swept at 1, while the shavings were still damp.",
		"literals": [
			{
				"field": "place",
				"value": "shop",
				"phrase": "The hoop was driven in the shop",
			},
			{
				"field": "sweep_hour",
				"value": "1",
				"phrase": "The yard was swept at 1",
			},
		],
	},
	{
		"id": "E7",
		"title": "Drive leaf",
		"source": "Shop book",
		"text": "The hoop was driven at 3. The hoop had been cut at 2, and the chalk on the stave still showed that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "3",
				"phrase": "The hoop was driven at 3",
			},
			{
				"field": "cut_hour",
				"value": "2",
				"phrase": "The hoop had been cut at 2",
			},
		],
	},
	{
		"id": "E8",
		"title": "Cask note",
		"source": "Cooperage",
		"text": "The hoop was driven at 3. The work was done so the yard would take the cask.",
		"literals": [
			{
				"field": "hour",
				"value": "3",
				"phrase": "The hoop was driven at 3",
			},
			{
				"field": "purpose",
				"value": "take_cask",
				"phrase": "so the yard would take the cask",
			},
		],
	},
	{
		"id": "E9",
		"title": "Shut order",
		"source": "Hoop slate",
		"text": "The hoop was driven at 3. The bench was wiped at 4, and the shop was closed at 5 once the cask was tight.",
		"literals": [
			{
				"field": "hour",
				"value": "3",
				"phrase": "The hoop was driven at 3",
			},
			{
				"field": "wipe_hour",
				"value": "4",
				"phrase": "The bench was wiped at 4",
			},
			{
				"field": "close_hour",
				"value": "5",
				"phrase": "the shop was closed at 5",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"cutter",
		"cut_place",
		"cut_hour",
		"seen_from",
		"crozer",
		"purpose",
		"croze_place",
		"driver_place",
		"sweep_hour",
		"wipe_hour",
		"close_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "cutter", "crozer":
			return PEOPLE.duplicate()
		"place", "cut_place", "seen_from", "croze_place", "driver_place":
			return PLACES.duplicate()
		"hour", "cut_hour", "sweep_hour", "wipe_hour", "close_hour":
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
		missing.append("who drove the hoop")
	if pins["place"] == "":
		missing.append("where they drove the hoop")
	if pins["hour"] == "":
		missing.append("at which hour they drove the hoop")
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
		"Jory":
			return "the hoop hand"
		"Maeve":
			return "the shop hand"
		"Perrin":
			return "the yard clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"shop":
			return "shop"
		"yard":
			return "yard"
		"bench":
			return "bench"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"shop":
			return "Shop"
		"yard":
			return "Yard"
		"bench":
			return "Bench"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s drove the hoop" % value
		"place":
			return "The hoop was driven in the %s" % place_label(value)
		"hour":
			return "The hoop was driven at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s drove the hoop" % value
		"place":
			return "the hoop was driven in the %s" % place_label(value)
		"hour":
			return "the hoop was driven at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s drove the hoop" % value
		"place":
			return "it was driven in the %s" % place_label(value)
		"hour":
			return "it was driven at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"take_cask":
			return "so the yard would take the cask"
		"spare_stave":
			return "to spare the stave still on the bench"
		"seat_head":
			return "to seat the head before the shop closed"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) drove the hoop in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) cut the hoop on the %s at %s." % [
			model["cutter"],
			role_short(str(model["cutter"])),
			place_label(str(model["cut_place"])),
			model["cut_hour"],
		],
		"%s (%s) turned the croze in the %s." % [
			model["crozer"],
			role_short(str(model["crozer"])),
			place_label(str(model["croze_place"])),
		],
		"The driver was hung on the %s." % place_label(str(model["driver_place"])),
		"The yard was swept at %s." % model["sweep_hour"],
		"The bench was wiped at %s." % model["wipe_hour"],
		"The shop was closed at %s." % model["close_hour"],
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
	return "Who drove the hoop, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they drove the hoop in."


static func cast_line() -> String:
	return "Jory, hoop hand    Maeve, shop hand    Perrin, yard clerk"


static func ready_line() -> String:
	return "Pin who drove the hoop, the room they drove it in, and the hour. Then submit."


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
