extends RefCounted

# The hood.
#
# The player pins three facts about the cutting: who, the room the hood was
# cut in, and the hour. The timeline also records who marked the holly, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the compass, where that turn was made, why the hood was cut, where
# the chestnut was hung, when the compass was glazed, when the trying was bronzed, and
# when the sycamore was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The hood"
const FILE_CODE := "CW-46"
const BLURB := "The hood left its peg at the joiner's mule. Name who cut the hood, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Hugo", "Nina", "Walter"]
const PLACES: Array[String] = ["sycamore", "compass", "trying"]
const HOURS: Array[String] = ["171", "172", "173", "174", "175"]
const AIMS: Array[String] = ["take_holly", "spare_holly", "set_holly"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Holly chit",
		"source": "Nina, holly hand",
		"text": "Hugo cut the hood. Nina had marked the holly, and a pale lime still clung to the hood.",
		"literals": [
			{
				"field": "taker",
				"value": "Hugo",
				"phrase": "Hugo cut the hood",
			},
			{
				"field": "holly",
				"value": "Nina",
				"phrase": "Nina had marked the holly",
			},
		],
	},
	{
		"id": "E2",
		"title": "Ivory sight",
		"source": "Compass ivory",
		"text": "Hugo cut the hood. The hooding was seen from the compass, beside the open holly.",
		"literals": [
			{
				"field": "taker",
				"value": "Hugo",
				"phrase": "Hugo cut the hood",
			},
			{
				"field": "seen_from",
				"value": "compass",
				"phrase": "The hooding was seen from the compass",
			},
		],
	},
	{
		"id": "E3",
		"title": "Chestnut bill",
		"source": "Trying nose",
		"text": "Hugo cut the hood. With the holly true, the chestnut was hung on the trying.",
		"literals": [
			{
				"field": "taker",
				"value": "Hugo",
				"phrase": "Hugo cut the hood",
			},
			{
				"field": "chestnut_room",
				"value": "trying",
				"phrase": "the chestnut was hung on the trying",
			},
		],
	},
	{
		"id": "E4",
		"title": "Boxwood slate",
		"source": "Sycamore boxwood",
		"text": "The hood was cut in the sycamore. A fresh boxwood shows the holly had been marked on the trying.",
		"literals": [
			{
				"field": "place",
				"value": "sycamore",
				"phrase": "The hood was cut in the sycamore",
			},
			{
				"field": "holly_room",
				"value": "trying",
				"phrase": "the holly had been marked on the trying",
			},
		],
	},
	{
		"id": "E5",
		"title": "Compass card",
		"source": "Walter, compass clerk",
		"text": "The hood was cut in the sycamore. Walter turned the compass in the sycamore once the holly was offered.",
		"literals": [
			{
				"field": "place",
				"value": "sycamore",
				"phrase": "The hood was cut in the sycamore",
			},
			{
				"field": "compass",
				"value": "Walter",
				"phrase": "Walter turned the compass",
			},
			{
				"field": "compass_room",
				"value": "sycamore",
				"phrase": "turned the compass in the sycamore",
			},
		],
	},
	{
		"id": "E6",
		"title": "Glaze slip",
		"source": "Compass tote",
		"text": "The hood was cut in the sycamore. The compass was glazed at 171, and a pale lamb still sat on the hood.",
		"literals": [
			{
				"field": "place",
				"value": "sycamore",
				"phrase": "The hood was cut in the sycamore",
			},
			{
				"field": "glaze_hour",
				"value": "171",
				"phrase": "The compass was glazed at 171",
			},
		],
	},
	{
		"id": "E7",
		"title": "Hood leaf",
		"source": "Holly book",
		"text": "The hood was cut at 173. The holly had been marked at 172, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "173",
				"phrase": "The hood was cut at 173",
			},
			{
				"field": "holly_hour",
				"value": "172",
				"phrase": "The holly had been marked at 172",
			},
		],
	},
	{
		"id": "E8",
		"title": "Mule note",
		"source": "Joiner's mule",
		"text": "The hood was cut at 173. The holly was opened so the holly would take the hood.",
		"literals": [
			{
				"field": "hour",
				"value": "173",
				"phrase": "The hood was cut at 173",
			},
			{
				"field": "aim",
				"value": "take_holly",
				"phrase": "so the holly would take the hood",
			},
		],
	},
	{
		"id": "E9",
		"title": "Bronze order",
		"source": "Trying card",
		"text": "The hood was cut at 173. The trying was bronzed at 174, and the sycamore was hung at 175 once the holly was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "173",
				"phrase": "The hood was cut at 173",
			},
			{
				"field": "bronze_hour",
				"value": "174",
				"phrase": "The trying was bronzed at 174",
			},
			{
				"field": "hang_hour",
				"value": "175",
				"phrase": "the sycamore was hung at 175",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"holly",
		"holly_room",
		"holly_hour",
		"seen_from",
		"compass",
		"aim",
		"compass_room",
		"chestnut_room",
		"glaze_hour",
		"bronze_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "holly", "compass":
			return PEOPLE.duplicate()
		"place", "holly_room", "seen_from", "compass_room", "chestnut_room":
			return PLACES.duplicate()
		"hour", "holly_hour", "glaze_hour", "bronze_hour", "hang_hour":
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
		missing.append("who cut the hood")
	if pins["place"] == "":
		missing.append("where they cut the hood")
	if pins["hour"] == "":
		missing.append("at which hour they cut the hood")
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
		"Hugo":
			return "the hood hand"
		"Nina":
			return "the holly hand"
		"Walter":
			return "the compass clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"sycamore":
			return "sycamore"
		"compass":
			return "compass"
		"trying":
			return "trying"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"sycamore":
			return "Sycamore"
		"compass":
			return "Compass"
		"trying":
			return "Trying"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the hood" % value
		"place":
			return "The hood was cut in the %s" % place_label(value)
		"hour":
			return "The hood was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the hood" % value
		"place":
			return "the hood was cut in the %s" % place_label(value)
		"hour":
			return "the hood was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the hood" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_holly":
			return "so the holly would take the hood"
		"spare_holly":
			return "to spare the holly still waiting on the hood"
		"set_holly":
			return "to set the holly before the sycamore was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the hood in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the holly on the %s at %s." % [
			model["holly"],
			role_short(str(model["holly"])),
			place_label(str(model["holly_room"])),
			model["holly_hour"],
		],
		"%s (%s) turned the compass in the %s." % [
			model["compass"],
			role_short(str(model["compass"])),
			place_label(str(model["compass_room"])),
		],
		"The chestnut was hung on the %s." % place_label(str(model["chestnut_room"])),
		"The compass was glazed at %s." % model["glaze_hour"],
		"The trying was bronzed at %s." % model["bronze_hour"],
		"The sycamore was hung at %s." % model["hang_hour"],
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
	return "Who cut the hood, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the hood in."


static func cast_line() -> String:
	return "Hugo, hood hand    Nina, holly hand    Walter, compass clerk"


static func ready_line() -> String:
	return "Pin who cut the hood, the room they cut it in, and the hour. Then submit."


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
