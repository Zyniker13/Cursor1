extends RefCounted

# The pelta.
#
# The player pins three facts about the cutting: who, the room the pelta was
# cut in, and the hour. The timeline also records who marked the ofun, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the sacristy, where that turn was made, why the pelta was cut, where
# the pernambuco was hung, when the sacristy was ammoniaced, when the nomi was opoponaxed, and
# when the stillroom was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The pelta"
const FILE_CODE := "CW-75"
const BLURB := "The pelta left its peg at the joiner's bung. Name who cut the pelta, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Ralph", "Helen", "Martin"]
const PLACES: Array[String] = ["stillroom", "sacristy", "nomi"]
const HOURS: Array[String] = ["316", "317", "318", "319", "320"]
const AIMS: Array[String] = ["take_ofun", "spare_ofun", "set_ofun"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Ofun chit",
		"source": "Helen, ofun hand",
		"text": "Ralph cut the pelta. Helen had marked the ofun, and a pale baptigenin still clung to the pelta.",
		"literals": [
			{
				"field": "taker",
				"value": "Ralph",
				"phrase": "Ralph cut the pelta",
			},
			{
				"field": "ofun",
				"value": "Helen",
				"phrase": "Helen had marked the ofun",
			},
		],
	},
	{
		"id": "E2",
		"title": "Variabilin sight",
		"source": "Sacristy variabilin",
		"text": "Ralph cut the pelta. The peltaing was seen from the sacristy, beside the open ofun.",
		"literals": [
			{
				"field": "taker",
				"value": "Ralph",
				"phrase": "Ralph cut the pelta",
			},
			{
				"field": "seen_from",
				"value": "sacristy",
				"phrase": "The peltaing was seen from the sacristy",
			},
		],
	},
	{
		"id": "E3",
		"title": "Pernambuco bill",
		"source": "Nomi nose",
		"text": "Ralph cut the pelta. With the ofun true, the pernambuco was hung on the nomi.",
		"literals": [
			{
				"field": "taker",
				"value": "Ralph",
				"phrase": "Ralph cut the pelta",
			},
			{
				"field": "pernambuco_room",
				"value": "nomi",
				"phrase": "the pernambuco was hung on the nomi",
			},
		],
	},
	{
		"id": "E4",
		"title": "Formonetin slate",
		"source": "Stillroom formonetin",
		"text": "The pelta was cut in the stillroom. A fresh formonetin shows the ofun had been marked on the nomi.",
		"literals": [
			{
				"field": "place",
				"value": "stillroom",
				"phrase": "The pelta was cut in the stillroom",
			},
			{
				"field": "ofun_room",
				"value": "nomi",
				"phrase": "the ofun had been marked on the nomi",
			},
		],
	},
	{
		"id": "E5",
		"title": "Sacristy card",
		"source": "Martin, sacristy clerk",
		"text": "The pelta was cut in the stillroom. Martin turned the sacristy in the stillroom once the ofun was offered.",
		"literals": [
			{
				"field": "place",
				"value": "stillroom",
				"phrase": "The pelta was cut in the stillroom",
			},
			{
				"field": "sacristy",
				"value": "Martin",
				"phrase": "Martin turned the sacristy",
			},
			{
				"field": "sacristy_room",
				"value": "stillroom",
				"phrase": "turned the sacristy in the stillroom",
			},
		],
	},
	{
		"id": "E6",
		"title": "Ammoniaced slip",
		"source": "Sacristy tote",
		"text": "The pelta was cut in the stillroom. The sacristy was ammoniaced at 316, and a pale neobavaisoflavone still sat on the pelta.",
		"literals": [
			{
				"field": "place",
				"value": "stillroom",
				"phrase": "The pelta was cut in the stillroom",
			},
			{
				"field": "ammoniac_hour",
				"value": "316",
				"phrase": "The sacristy was ammoniaced at 316",
			},
		],
	},
	{
		"id": "E7",
		"title": "Pelta leaf",
		"source": "Ofun book",
		"text": "The pelta was cut at 318. The ofun had been marked at 317, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "318",
				"phrase": "The pelta was cut at 318",
			},
			{
				"field": "ofun_hour",
				"value": "317",
				"phrase": "The ofun had been marked at 317",
			},
		],
	},
	{
		"id": "E8",
		"title": "Bung note",
		"source": "Joiner's bung",
		"text": "The pelta was cut at 318. The ofun was opened so the ofun would take the pelta.",
		"literals": [
			{
				"field": "hour",
				"value": "318",
				"phrase": "The pelta was cut at 318",
			},
			{
				"field": "aim",
				"value": "take_ofun",
				"phrase": "so the ofun would take the pelta",
			},
		],
	},
	{
		"id": "E9",
		"title": "Opoponaxed order",
		"source": "Nomi card",
		"text": "The pelta was cut at 318. The nomi was opoponaxed at 319, and the stillroom was hung at 320 once the ofun was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "318",
				"phrase": "The pelta was cut at 318",
			},
			{
				"field": "opoponax_hour",
				"value": "319",
				"phrase": "The nomi was opoponaxed at 319",
			},
			{
				"field": "hang_hour",
				"value": "320",
				"phrase": "the stillroom was hung at 320",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"ofun",
		"ofun_room",
		"ofun_hour",
		"seen_from",
		"sacristy",
		"aim",
		"sacristy_room",
		"pernambuco_room",
		"ammoniac_hour",
		"opoponax_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "ofun", "sacristy":
			return PEOPLE.duplicate()
		"place", "ofun_room", "seen_from", "sacristy_room", "pernambuco_room":
			return PLACES.duplicate()
		"hour", "ofun_hour", "ammoniac_hour", "opoponax_hour", "hang_hour":
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
		missing.append("who cut the pelta")
	if pins["place"] == "":
		missing.append("where they cut the pelta")
	if pins["hour"] == "":
		missing.append("at which hour they cut the pelta")
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
		"Ralph":
			return "the pelta hand"
		"Helen":
			return "the ofun hand"
		"Martin":
			return "the sacristy clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"stillroom":
			return "stillroom"
		"sacristy":
			return "sacristy"
		"nomi":
			return "nomi"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"stillroom":
			return "Stillroom"
		"sacristy":
			return "Sacristy"
		"nomi":
			return "Nomi"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the pelta" % value
		"place":
			return "The pelta was cut in the %s" % place_label(value)
		"hour":
			return "The pelta was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the pelta" % value
		"place":
			return "the pelta was cut in the %s" % place_label(value)
		"hour":
			return "the pelta was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the pelta" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_ofun":
			return "so the ofun would take the pelta"
		"spare_ofun":
			return "to spare the ofun still waiting on the pelta"
		"set_ofun":
			return "to set the ofun before the stillroom was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the pelta in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the ofun on the %s at %s." % [
			model["ofun"],
			role_short(str(model["ofun"])),
			place_label(str(model["ofun_room"])),
			model["ofun_hour"],
		],
		"%s (%s) turned the sacristy in the %s." % [
			model["sacristy"],
			role_short(str(model["sacristy"])),
			place_label(str(model["sacristy_room"])),
		],
		"The pernambuco was hung on the %s." % place_label(str(model["pernambuco_room"])),
		"The sacristy was ammoniaced at %s." % model["ammoniac_hour"],
		"The nomi was opoponaxed at %s." % model["opoponax_hour"],
		"The stillroom was hung at %s." % model["hang_hour"],
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
	return "Who cut the pelta, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the pelta in."


static func cast_line() -> String:
	return "Ralph, pelta hand    Helen, ofun hand    Martin, sacristy clerk"


static func ready_line() -> String:
	return "Pin who cut the pelta, the room they cut it in, and the hour. Then submit."


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
