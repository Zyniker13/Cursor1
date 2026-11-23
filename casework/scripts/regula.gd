extends RefCounted

# The regula.
#
# The player pins three facts about the cutting: who, the room the regula was
# cut in, and the hour. The timeline also records who marked the wenge, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the galilee, where that turn was made, why the regula was cut, where
# the sapele was hung, when the galilee was myrrhed, when the dozuki was masticed, and
# when the dorter was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The regula"
const FILE_CODE := "CW-61"
const BLURB := "The regula left its peg at the joiner's spike. Name who cut the regula, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Hereward", "Godiva", "Leofric"]
const PLACES: Array[String] = ["dorter", "galilee", "dozuki"]
const HOURS: Array[String] = ["246", "247", "248", "249", "250"]
const AIMS: Array[String] = ["take_wenge", "spare_wenge", "set_wenge"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Wenge chit",
		"source": "Godiva, wenge hand",
		"text": "Hereward cut the regula. Godiva had marked the wenge, and a pale lawsone still clung to the regula.",
		"literals": [
			{
				"field": "taker",
				"value": "Hereward",
				"phrase": "Hereward cut the regula",
			},
			{
				"field": "wenge",
				"value": "Godiva",
				"phrase": "Godiva had marked the wenge",
			},
		],
	},
	{
		"id": "E2",
		"title": "Lycopene sight",
		"source": "Galilee lycopene",
		"text": "Hereward cut the regula. The regulaing was seen from the galilee, beside the open wenge.",
		"literals": [
			{
				"field": "taker",
				"value": "Hereward",
				"phrase": "Hereward cut the regula",
			},
			{
				"field": "seen_from",
				"value": "galilee",
				"phrase": "The regulaing was seen from the galilee",
			},
		],
	},
	{
		"id": "E3",
		"title": "Sapele bill",
		"source": "Dozuki nose",
		"text": "Hereward cut the regula. With the wenge true, the sapele was hung on the dozuki.",
		"literals": [
			{
				"field": "taker",
				"value": "Hereward",
				"phrase": "Hereward cut the regula",
			},
			{
				"field": "sapele_room",
				"value": "dozuki",
				"phrase": "the sapele was hung on the dozuki",
			},
		],
	},
	{
		"id": "E4",
		"title": "Betanin slate",
		"source": "Dorter betanin",
		"text": "The regula was cut in the dorter. A fresh betanin shows the wenge had been marked on the dozuki.",
		"literals": [
			{
				"field": "place",
				"value": "dorter",
				"phrase": "The regula was cut in the dorter",
			},
			{
				"field": "wenge_room",
				"value": "dozuki",
				"phrase": "the wenge had been marked on the dozuki",
			},
		],
	},
	{
		"id": "E5",
		"title": "Galilee card",
		"source": "Leofric, galilee clerk",
		"text": "The regula was cut in the dorter. Leofric turned the galilee in the dorter once the wenge was offered.",
		"literals": [
			{
				"field": "place",
				"value": "dorter",
				"phrase": "The regula was cut in the dorter",
			},
			{
				"field": "galilee",
				"value": "Leofric",
				"phrase": "Leofric turned the galilee",
			},
			{
				"field": "galilee_room",
				"value": "dorter",
				"phrase": "turned the galilee in the dorter",
			},
		],
	},
	{
		"id": "E6",
		"title": "Myrrhed slip",
		"source": "Galilee tote",
		"text": "The regula was cut in the dorter. The galilee was myrrhed at 246, and a pale crocin still sat on the regula.",
		"literals": [
			{
				"field": "place",
				"value": "dorter",
				"phrase": "The regula was cut in the dorter",
			},
			{
				"field": "myrrh_hour",
				"value": "246",
				"phrase": "The galilee was myrrhed at 246",
			},
		],
	},
	{
		"id": "E7",
		"title": "Regula leaf",
		"source": "Wenge book",
		"text": "The regula was cut at 248. The wenge had been marked at 247, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "248",
				"phrase": "The regula was cut at 248",
			},
			{
				"field": "wenge_hour",
				"value": "247",
				"phrase": "The wenge had been marked at 247",
			},
		],
	},
	{
		"id": "E8",
		"title": "Spike note",
		"source": "Joiner's spike",
		"text": "The regula was cut at 248. The wenge was opened so the wenge would take the regula.",
		"literals": [
			{
				"field": "hour",
				"value": "248",
				"phrase": "The regula was cut at 248",
			},
			{
				"field": "aim",
				"value": "take_wenge",
				"phrase": "so the wenge would take the regula",
			},
		],
	},
	{
		"id": "E9",
		"title": "Masticed order",
		"source": "Dozuki card",
		"text": "The regula was cut at 248. The dozuki was masticed at 249, and the dorter was hung at 250 once the wenge was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "248",
				"phrase": "The regula was cut at 248",
			},
			{
				"field": "mastic_hour",
				"value": "249",
				"phrase": "The dozuki was masticed at 249",
			},
			{
				"field": "hang_hour",
				"value": "250",
				"phrase": "the dorter was hung at 250",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"wenge",
		"wenge_room",
		"wenge_hour",
		"seen_from",
		"galilee",
		"aim",
		"galilee_room",
		"sapele_room",
		"myrrh_hour",
		"mastic_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "wenge", "galilee":
			return PEOPLE.duplicate()
		"place", "wenge_room", "seen_from", "galilee_room", "sapele_room":
			return PLACES.duplicate()
		"hour", "wenge_hour", "myrrh_hour", "mastic_hour", "hang_hour":
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
		missing.append("who cut the regula")
	if pins["place"] == "":
		missing.append("where they cut the regula")
	if pins["hour"] == "":
		missing.append("at which hour they cut the regula")
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
		"Hereward":
			return "the regula hand"
		"Godiva":
			return "the wenge hand"
		"Leofric":
			return "the galilee clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"dorter":
			return "dorter"
		"galilee":
			return "galilee"
		"dozuki":
			return "dozuki"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"dorter":
			return "Dorter"
		"galilee":
			return "Galilee"
		"dozuki":
			return "Dozuki"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the regula" % value
		"place":
			return "The regula was cut in the %s" % place_label(value)
		"hour":
			return "The regula was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the regula" % value
		"place":
			return "the regula was cut in the %s" % place_label(value)
		"hour":
			return "the regula was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the regula" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_wenge":
			return "so the wenge would take the regula"
		"spare_wenge":
			return "to spare the wenge still waiting on the regula"
		"set_wenge":
			return "to set the wenge before the dorter was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the regula in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the wenge on the %s at %s." % [
			model["wenge"],
			role_short(str(model["wenge"])),
			place_label(str(model["wenge_room"])),
			model["wenge_hour"],
		],
		"%s (%s) turned the galilee in the %s." % [
			model["galilee"],
			role_short(str(model["galilee"])),
			place_label(str(model["galilee_room"])),
		],
		"The sapele was hung on the %s." % place_label(str(model["sapele_room"])),
		"The galilee was myrrhed at %s." % model["myrrh_hour"],
		"The dozuki was masticed at %s." % model["mastic_hour"],
		"The dorter was hung at %s." % model["hang_hour"],
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
	return "Who cut the regula, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the regula in."


static func cast_line() -> String:
	return "Hereward, regula hand    Godiva, wenge hand    Leofric, galilee clerk"


static func ready_line() -> String:
	return "Pin who cut the regula, the room they cut it in, and the hour. Then submit."


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
