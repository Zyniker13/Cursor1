extends RefCounted

# The knotwork.
#
# The player pins three facts about the cutting: who, the room the knotwork was
# cut in, and the hour. The timeline also records who marked the agba, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the chancel, where that turn was made, why the knotwork was cut, where
# the ebony was hung, when the chancel was chianed, when the anakagi was ladanumed, and
# when the larder was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The knotwork"
const FILE_CODE := "CW-72"
const BLURB := "The knotwork left its peg at the joiner's trenail. Name who cut the knotwork, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["John", "Joan", "Cecilia"]
const PLACES: Array[String] = ["larder", "chancel", "anakagi"]
const HOURS: Array[String] = ["301", "302", "303", "304", "305"]
const AIMS: Array[String] = ["take_agba", "spare_agba", "set_agba"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Agba chit",
		"source": "Joan, agba hand",
		"text": "John cut the knotwork. Joan had marked the agba, and a pale odoratin still clung to the knotwork.",
		"literals": [
			{
				"field": "taker",
				"value": "John",
				"phrase": "John cut the knotwork",
			},
			{
				"field": "agba",
				"value": "Joan",
				"phrase": "Joan had marked the agba",
			},
		],
	},
	{
		"id": "E2",
		"title": "Afromosin sight",
		"source": "Chancel afromosin",
		"text": "John cut the knotwork. The knotworking was seen from the chancel, beside the open agba.",
		"literals": [
			{
				"field": "taker",
				"value": "John",
				"phrase": "John cut the knotwork",
			},
			{
				"field": "seen_from",
				"value": "chancel",
				"phrase": "The knotworking was seen from the chancel",
			},
		],
	},
	{
		"id": "E3",
		"title": "Ebony bill",
		"source": "Anakagi nose",
		"text": "John cut the knotwork. With the agba true, the ebony was hung on the anakagi.",
		"literals": [
			{
				"field": "taker",
				"value": "John",
				"phrase": "John cut the knotwork",
			},
			{
				"field": "ebony_room",
				"value": "anakagi",
				"phrase": "the ebony was hung on the anakagi",
			},
		],
	},
	{
		"id": "E4",
		"title": "Luteone slate",
		"source": "Larder luteone",
		"text": "The knotwork was cut in the larder. A fresh luteone shows the agba had been marked on the anakagi.",
		"literals": [
			{
				"field": "place",
				"value": "larder",
				"phrase": "The knotwork was cut in the larder",
			},
			{
				"field": "agba_room",
				"value": "anakagi",
				"phrase": "the agba had been marked on the anakagi",
			},
		],
	},
	{
		"id": "E5",
		"title": "Chancel card",
		"source": "Cecilia, chancel clerk",
		"text": "The knotwork was cut in the larder. Cecilia turned the chancel in the larder once the agba was offered.",
		"literals": [
			{
				"field": "place",
				"value": "larder",
				"phrase": "The knotwork was cut in the larder",
			},
			{
				"field": "chancel",
				"value": "Cecilia",
				"phrase": "Cecilia turned the chancel",
			},
			{
				"field": "chancel_room",
				"value": "larder",
				"phrase": "turned the chancel in the larder",
			},
		],
	},
	{
		"id": "E6",
		"title": "Chianed slip",
		"source": "Chancel tote",
		"text": "The knotwork was cut in the larder. The chancel was chianed at 301, and a pale wighteone still sat on the knotwork.",
		"literals": [
			{
				"field": "place",
				"value": "larder",
				"phrase": "The knotwork was cut in the larder",
			},
			{
				"field": "chian_hour",
				"value": "301",
				"phrase": "The chancel was chianed at 301",
			},
		],
	},
	{
		"id": "E7",
		"title": "Knotwork leaf",
		"source": "Agba book",
		"text": "The knotwork was cut at 303. The agba had been marked at 302, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "303",
				"phrase": "The knotwork was cut at 303",
			},
			{
				"field": "agba_hour",
				"value": "302",
				"phrase": "The agba had been marked at 302",
			},
		],
	},
	{
		"id": "E8",
		"title": "Trenail note",
		"source": "Joiner's trenail",
		"text": "The knotwork was cut at 303. The agba was opened so the agba would take the knotwork.",
		"literals": [
			{
				"field": "hour",
				"value": "303",
				"phrase": "The knotwork was cut at 303",
			},
			{
				"field": "aim",
				"value": "take_agba",
				"phrase": "so the agba would take the knotwork",
			},
		],
	},
	{
		"id": "E9",
		"title": "Ladanumed order",
		"source": "Anakagi card",
		"text": "The knotwork was cut at 303. The anakagi was ladanumed at 304, and the larder was hung at 305 once the agba was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "303",
				"phrase": "The knotwork was cut at 303",
			},
			{
				"field": "ladanum_hour",
				"value": "304",
				"phrase": "The anakagi was ladanumed at 304",
			},
			{
				"field": "hang_hour",
				"value": "305",
				"phrase": "the larder was hung at 305",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"agba",
		"agba_room",
		"agba_hour",
		"seen_from",
		"chancel",
		"aim",
		"chancel_room",
		"ebony_room",
		"chian_hour",
		"ladanum_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "agba", "chancel":
			return PEOPLE.duplicate()
		"place", "agba_room", "seen_from", "chancel_room", "ebony_room":
			return PLACES.duplicate()
		"hour", "agba_hour", "chian_hour", "ladanum_hour", "hang_hour":
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
		missing.append("who cut the knotwork")
	if pins["place"] == "":
		missing.append("where they cut the knotwork")
	if pins["hour"] == "":
		missing.append("at which hour they cut the knotwork")
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
		"John":
			return "the knotwork hand"
		"Joan":
			return "the agba hand"
		"Cecilia":
			return "the chancel clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"larder":
			return "larder"
		"chancel":
			return "chancel"
		"anakagi":
			return "anakagi"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"larder":
			return "Larder"
		"chancel":
			return "Chancel"
		"anakagi":
			return "Anakagi"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the knotwork" % value
		"place":
			return "The knotwork was cut in the %s" % place_label(value)
		"hour":
			return "The knotwork was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the knotwork" % value
		"place":
			return "the knotwork was cut in the %s" % place_label(value)
		"hour":
			return "the knotwork was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the knotwork" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_agba":
			return "so the agba would take the knotwork"
		"spare_agba":
			return "to spare the agba still waiting on the knotwork"
		"set_agba":
			return "to set the agba before the larder was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the knotwork in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the agba on the %s at %s." % [
			model["agba"],
			role_short(str(model["agba"])),
			place_label(str(model["agba_room"])),
			model["agba_hour"],
		],
		"%s (%s) turned the chancel in the %s." % [
			model["chancel"],
			role_short(str(model["chancel"])),
			place_label(str(model["chancel_room"])),
		],
		"The ebony was hung on the %s." % place_label(str(model["ebony_room"])),
		"The chancel was chianed at %s." % model["chian_hour"],
		"The anakagi was ladanumed at %s." % model["ladanum_hour"],
		"The larder was hung at %s." % model["hang_hour"],
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
	return "Who cut the knotwork, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the knotwork in."


static func cast_line() -> String:
	return "John, knotwork hand    Joan, agba hand    Cecilia, chancel clerk"


static func ready_line() -> String:
	return "Pin who cut the knotwork, the room they cut it in, and the hour. Then submit."


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
