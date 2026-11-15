extends RefCounted

# The kiln chalk.
#
# The player pins three facts about the chalking: who, the room the mark was
# chalked on, and the hour. The timeline also records who mixed the slip,
# where and at which hour it was mixed, who read the spy hole, at which hour
# the spy hole was read, where the mark was chalked from, why it was chalked,
# where the damper was seated, where the spy hole was read, when the damper
# was shut, and when the cones were drawn. Who, the room, and the hour are
# each shared by three exhibits. Five hours are on the board, and the
# chalking is the middle one. Two exhibits each state two hidden facts. Each
# exhibit states one of the three pins (a value at least one other exhibit
# also states) and at least one fact no other exhibit states. Exactly one
# full timeline fits every exhibit. Drop any exhibit and another timeline
# fits. Any other pin triple disagrees with at least two exhibits.

const TITLE := "The kiln chalk"
const FILE_CODE := "CW-11"
const BLURB := "The kiln chalk left its ledge at the kiln house. Name who chalked the mark, the room they chalked it on, and the hour."

const PEOPLE: Array[String] = ["Bram", "Wren", "Noll"]
const PLACES: Array[String] = ["crown", "fire_mouth", "flue"]
const HOURS: Array[String] = ["50", "51", "52", "53", "54"]
const PURPOSES: Array[String] = ["read_shut", "open_damper", "mark_cones"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Mark line",
		"source": "Bram, fireman",
		"text": "Wren, the draught hand, is the person who chalked the kiln mark. Bram, the fireman, is the person who mixed the slip.",
		"literals": [
			{
				"field": "taker",
				"value": "Wren",
				"phrase": "Wren, the draught hand, is the person who chalked the kiln mark",
			},
			{
				"field": "mixer",
				"value": "Bram",
				"phrase": "Bram, the fireman, is the person who mixed the slip",
			},
		],
	},
	{
		"id": "E2",
		"title": "Crown tag",
		"source": "Crown",
		"text": "Wren, the draught hand, is the person who chalked the kiln mark. The kiln mark was chalked from the crown.",
		"literals": [
			{
				"field": "taker",
				"value": "Wren",
				"phrase": "Wren, the draught hand, is the person who chalked the kiln mark",
			},
			{
				"field": "origin",
				"value": "crown",
				"phrase": "The kiln mark was chalked from the crown",
			},
		],
	},
	{
		"id": "E3",
		"title": "Seat card",
		"source": "Damper seat",
		"text": "Wren, the draught hand, is the person who chalked the kiln mark. The damper was seated at the crown.",
		"literals": [
			{
				"field": "taker",
				"value": "Wren",
				"phrase": "Wren, the draught hand, is the person who chalked the kiln mark",
			},
			{
				"field": "seat_place",
				"value": "crown",
				"phrase": "The damper was seated at the crown",
			},
		],
	},
	{
		"id": "E4",
		"title": "Mouth card",
		"source": "Fire mouth",
		"text": "The kiln mark was chalked on the flue. The slip was mixed at the fire mouth.",
		"literals": [
			{
				"field": "place",
				"value": "flue",
				"phrase": "The kiln mark was chalked on the flue",
			},
			{
				"field": "mix_place",
				"value": "fire_mouth",
				"phrase": "The slip was mixed at the fire mouth",
			},
		],
	},
	{
		"id": "E5",
		"title": "Spy margin",
		"source": "Spy hole",
		"text": "The kiln mark was chalked on the flue. Noll, the watcher, is the person who read the spy hole, and the spy hole was read at the crown.",
		"literals": [
			{
				"field": "place",
				"value": "flue",
				"phrase": "The kiln mark was chalked on the flue",
			},
			{
				"field": "watcher",
				"value": "Noll",
				"phrase": "Noll, the watcher, is the person who read the spy hole",
			},
			{
				"field": "spy_place",
				"value": "crown",
				"phrase": "the spy hole was read at the crown",
			},
		],
	},
	{
		"id": "E6",
		"title": "Slip chit",
		"source": "Slip book",
		"text": "The kiln mark was chalked on the flue. 50 is the hour at which the slip was mixed.",
		"literals": [
			{
				"field": "place",
				"value": "flue",
				"phrase": "The kiln mark was chalked on the flue",
			},
			{
				"field": "mix_hour",
				"value": "50",
				"phrase": "50 is the hour at which the slip was mixed",
			},
		],
	},
	{
		"id": "E7",
		"title": "Watch slip",
		"source": "Spy book",
		"text": "52 is the hour at which the kiln mark was chalked. 51 is the hour at which the spy hole was read.",
		"literals": [
			{
				"field": "hour",
				"value": "52",
				"phrase": "52 is the hour at which the kiln mark was chalked",
			},
			{
				"field": "watch_hour",
				"value": "51",
				"phrase": "51 is the hour at which the spy hole was read",
			},
		],
	},
	{
		"id": "E8",
		"title": "Draught note",
		"source": "Kiln house",
		"text": "52 is the hour at which the kiln mark was chalked. The kiln mark was chalked so the draught would read shut.",
		"literals": [
			{
				"field": "hour",
				"value": "52",
				"phrase": "52 is the hour at which the kiln mark was chalked",
			},
			{
				"field": "purpose",
				"value": "read_shut",
				"phrase": "The kiln mark was chalked so the draught would read shut",
			},
		],
	},
	{
		"id": "E9",
		"title": "Damper line",
		"source": "Kiln book",
		"text": "52 is the hour at which the kiln mark was chalked. The damper was shut at 53, and the cones were drawn at 54.",
		"literals": [
			{
				"field": "hour",
				"value": "52",
				"phrase": "52 is the hour at which the kiln mark was chalked",
			},
			{
				"field": "damper_hour",
				"value": "53",
				"phrase": "The damper was shut at 53",
			},
			{
				"field": "cone_hour",
				"value": "54",
				"phrase": "the cones were drawn at 54",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"mixer",
		"mix_place",
		"mix_hour",
		"watcher",
		"watch_hour",
		"origin",
		"purpose",
		"spy_place",
		"seat_place",
		"damper_hour",
		"cone_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "mixer", "watcher":
			return PEOPLE.duplicate()
		"place", "mix_place", "origin", "spy_place", "seat_place":
			return PLACES.duplicate()
		"hour", "mix_hour", "watch_hour", "damper_hour", "cone_hour":
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
		missing.append("who chalked the kiln mark")
	if pins["place"] == "":
		missing.append("where they chalked the mark")
	if pins["hour"] == "":
		missing.append("at which hour they chalked the mark")
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
		"Bram":
			return "the fireman"
		"Wren":
			return "the draught hand"
		"Noll":
			return "the watcher"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"crown":
			return "crown"
		"fire_mouth":
			return "fire mouth"
		"flue":
			return "flue"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"crown":
			return "Crown"
		"fire_mouth":
			return "Fire mouth"
		"flue":
			return "Flue"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s, %s, is the person who chalked the kiln mark" % [value, role_phrase(value)]
		"place":
			return "The kiln mark was chalked on the %s" % place_label(value)
		"hour":
			return "%s is the hour at which the kiln mark was chalked" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s chalked the kiln mark" % value
		"place":
			return "the kiln mark was chalked on the %s" % place_label(value)
		"hour":
			return "the kiln mark was chalked at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s chalked the kiln mark" % value
		"place":
			return "it was chalked on the %s" % place_label(value)
		"hour":
			return "it was chalked at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"read_shut":
			return "so the draught would read shut"
		"open_damper":
			return "to open the damper"
		"mark_cones":
			return "to mark the cones"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) chalked the kiln mark at %s from the %s to the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			model["hour"],
			place_label(str(model["origin"])),
			place_label(str(model["place"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) mixed the slip at %s at the %s." % [
			model["mixer"],
			role_short(str(model["mixer"])),
			model["mix_hour"],
			place_label(str(model["mix_place"])),
		],
		"%s (%s) read the spy hole at %s." % [
			model["watcher"],
			role_short(str(model["watcher"])),
			model["watch_hour"],
		],
		"The damper was seated at the %s." % place_label(str(model["seat_place"])),
		"The spy hole was read at the %s." % place_label(str(model["spy_place"])),
		"The damper was shut at %s." % model["damper_hour"],
		"The cones were drawn at %s." % model["cone_hour"],
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
	return "Who chalked the kiln mark, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they chalked the mark on."


static func cast_line() -> String:
	return "Bram, fireman    Wren, draught hand    Noll, watcher"


static func ready_line() -> String:
	return "Pin who chalked the kiln mark, the room they chalked it on, and the hour. Then submit."


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
