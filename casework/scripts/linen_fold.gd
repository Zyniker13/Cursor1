extends RefCounted

# The linen fold.
#
# The player pins three facts about the folding: who, the room the linen was
# folded in, and the hour. The timeline also records who cut the linen, where
# it was cut, when that cutting was done, where the folding was seen from, who
# turned the roller, where that turn was made, why the linen was folded, where
# the pin was hung, when the loft was swept, when the bench was wiped, and
# when the press was closed. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the folding is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The linen fold"
const FILE_CODE := "CW-23"
const BLURB := "The linen fold left its peg at the cloth loft. Name who folded the linen, the room they folded it in, and the hour."

const PEOPLE: Array[String] = ["Odell", "Vetch", "Brigg"]
const PLACES: Array[String] = ["press", "loft", "bench"]
const HOURS: Array[String] = ["6", "7", "8", "9", "10"]
const PURPOSES: Array[String] = ["take_sheet", "spare_hem", "set_crease"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Shears chit",
		"source": "Odell, fold hand",
		"text": "Vetch folded the linen. Odell had cut the linen and left the hem uneven.",
		"literals": [
			{
				"field": "taker",
				"value": "Vetch",
				"phrase": "Vetch folded the linen",
			},
			{
				"field": "clipper",
				"value": "Odell",
				"phrase": "Odell had cut the linen",
			},
		],
	},
	{
		"id": "E2",
		"title": "Loft sight",
		"source": "Loft door",
		"text": "Vetch folded the linen. The folding was seen from the loft, between the hanging sheets.",
		"literals": [
			{
				"field": "taker",
				"value": "Vetch",
				"phrase": "Vetch folded the linen",
			},
			{
				"field": "watched_from",
				"value": "loft",
				"phrase": "The folding was seen from the loft",
			},
		],
	},
	{
		"id": "E3",
		"title": "Pin peg",
		"source": "Bench hook",
		"text": "Vetch folded the linen. Once the linen lay flat, the pin was hung on the bench.",
		"literals": [
			{
				"field": "taker",
				"value": "Vetch",
				"phrase": "Vetch folded the linen",
			},
			{
				"field": "pin_room",
				"value": "bench",
				"phrase": "the pin was hung on the bench",
			},
		],
	},
	{
		"id": "E4",
		"title": "Cloth slate",
		"source": "Press beam",
		"text": "The linen was folded in the press. A hem note says the linen had been cut on the bench.",
		"literals": [
			{
				"field": "place",
				"value": "press",
				"phrase": "The linen was folded in the press",
			},
			{
				"field": "clip_room",
				"value": "bench",
				"phrase": "the linen had been cut on the bench",
			},
		],
	},
	{
		"id": "E5",
		"title": "Roller card",
		"source": "Brigg, loft clerk",
		"text": "The linen was folded in the press. Brigg turned the roller in the loft and kept the sheet from creasing.",
		"literals": [
			{
				"field": "place",
				"value": "press",
				"phrase": "The linen was folded in the press",
			},
			{
				"field": "roller",
				"value": "Brigg",
				"phrase": "Brigg turned the roller",
			},
			{
				"field": "roll_room",
				"value": "loft",
				"phrase": "turned the roller in the loft",
			},
		],
	},
	{
		"id": "E6",
		"title": "Dust slip",
		"source": "Loft book",
		"text": "The linen was folded in the press. The loft was swept at 6, while lint still clung to the boards.",
		"literals": [
			{
				"field": "place",
				"value": "press",
				"phrase": "The linen was folded in the press",
			},
			{
				"field": "dust_hour",
				"value": "6",
				"phrase": "The loft was swept at 6",
			},
		],
	},
	{
		"id": "E7",
		"title": "Fold leaf",
		"source": "Fold book",
		"text": "The linen was folded at 8. The linen had been cut at 7, and the thread on the hem still marked that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "8",
				"phrase": "The linen was folded at 8",
			},
			{
				"field": "clip_hour",
				"value": "7",
				"phrase": "The linen had been cut at 7",
			},
		],
	},
	{
		"id": "E8",
		"title": "Sheet note",
		"source": "Cloth loft",
		"text": "The linen was folded at 8. The work was done so the loft would take the sheet.",
		"literals": [
			{
				"field": "hour",
				"value": "8",
				"phrase": "The linen was folded at 8",
			},
			{
				"field": "purpose",
				"value": "take_sheet",
				"phrase": "so the loft would take the sheet",
			},
		],
	},
	{
		"id": "E9",
		"title": "Bar order",
		"source": "Hem slate",
		"text": "The linen was folded at 8. The bench was wiped at 9, and the press was closed at 10 once the sheet lay flat.",
		"literals": [
			{
				"field": "hour",
				"value": "8",
				"phrase": "The linen was folded at 8",
			},
			{
				"field": "dab_hour",
				"value": "9",
				"phrase": "The bench was wiped at 9",
			},
			{
				"field": "bar_hour",
				"value": "10",
				"phrase": "the press was closed at 10",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"clipper",
		"clip_room",
		"clip_hour",
		"watched_from",
		"roller",
		"purpose",
		"roll_room",
		"pin_room",
		"dust_hour",
		"dab_hour",
		"bar_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "clipper", "roller":
			return PEOPLE.duplicate()
		"place", "clip_room", "watched_from", "roll_room", "pin_room":
			return PLACES.duplicate()
		"hour", "clip_hour", "dust_hour", "dab_hour", "bar_hour":
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
		missing.append("who folded the linen")
	if pins["place"] == "":
		missing.append("where they folded the linen")
	if pins["hour"] == "":
		missing.append("at which hour they folded the linen")
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
		"Odell":
			return "the fold hand"
		"Vetch":
			return "the press hand"
		"Brigg":
			return "the loft clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"press":
			return "press"
		"loft":
			return "loft"
		"bench":
			return "bench"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"press":
			return "Press"
		"loft":
			return "Loft"
		"bench":
			return "Bench"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s folded the linen" % value
		"place":
			return "The linen was folded in the %s" % place_label(value)
		"hour":
			return "The linen was folded at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s folded the linen" % value
		"place":
			return "the linen was folded in the %s" % place_label(value)
		"hour":
			return "the linen was folded at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s folded the linen" % value
		"place":
			return "it was folded in the %s" % place_label(value)
		"hour":
			return "it was folded at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"take_sheet":
			return "so the loft would take the sheet"
		"spare_hem":
			return "to spare the hem still on the bench"
		"set_crease":
			return "to set the crease before the press closed"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) folded the linen in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["watched_from"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) cut the linen on the %s at %s." % [
			model["clipper"],
			role_short(str(model["clipper"])),
			place_label(str(model["clip_room"])),
			model["clip_hour"],
		],
		"%s (%s) turned the roller in the %s." % [
			model["roller"],
			role_short(str(model["roller"])),
			place_label(str(model["roll_room"])),
		],
		"The pin was hung on the %s." % place_label(str(model["pin_room"])),
		"The loft was swept at %s." % model["dust_hour"],
		"The bench was wiped at %s." % model["dab_hour"],
		"The press was closed at %s." % model["bar_hour"],
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
	return "Who folded the linen, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they folded the linen in."


static func cast_line() -> String:
	return "Odell, fold hand    Vetch, press hand    Brigg, loft clerk"


static func ready_line() -> String:
	return "Pin who folded the linen, the room they folded it in, and the hour. Then submit."


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
