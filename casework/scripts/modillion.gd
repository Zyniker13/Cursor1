extends RefCounted

# The modillion.
#
# The player pins three facts about the cutting: who, the room the modillion was
# cut in, and the hour. The timeline also records who marked the cornel, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the aisle, where that turn was made, why the modillion was cut, where
# the dogwood was hung, when the aisle was resined, when the broach was tawed, and
# when the narthex was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The modillion"
const FILE_CODE := "CW-53"
const BLURB := "The modillion left its peg at the joiner's sprig. Name who cut the modillion, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Hilda", "Astrid", "Einar"]
const PLACES: Array[String] = ["narthex", "aisle", "broach"]
const HOURS: Array[String] = ["206", "207", "208", "209", "210"]
const AIMS: Array[String] = ["take_cornel", "spare_cornel", "set_cornel"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Cornel chit",
		"source": "Astrid, cornel hand",
		"text": "Hilda cut the modillion. Astrid had marked the cornel, and a pale safflower still clung to the modillion.",
		"literals": [
			{
				"field": "taker",
				"value": "Hilda",
				"phrase": "Hilda cut the modillion",
			},
			{
				"field": "cornel",
				"value": "Astrid",
				"phrase": "Astrid had marked the cornel",
			},
		],
	},
	{
		"id": "E2",
		"title": "Camwood sight",
		"source": "Aisle camwood",
		"text": "Hilda cut the modillion. The modillioning was seen from the aisle, beside the open cornel.",
		"literals": [
			{
				"field": "taker",
				"value": "Hilda",
				"phrase": "Hilda cut the modillion",
			},
			{
				"field": "seen_from",
				"value": "aisle",
				"phrase": "The modillioning was seen from the aisle",
			},
		],
	},
	{
		"id": "E3",
		"title": "Dogwood bill",
		"source": "Broach nose",
		"text": "Hilda cut the modillion. With the cornel true, the dogwood was hung on the broach.",
		"literals": [
			{
				"field": "taker",
				"value": "Hilda",
				"phrase": "Hilda cut the modillion",
			},
			{
				"field": "dogwood_room",
				"value": "broach",
				"phrase": "the dogwood was hung on the broach",
			},
		],
	},
	{
		"id": "E4",
		"title": "Catechu slate",
		"source": "Narthex catechu",
		"text": "The modillion was cut in the narthex. A fresh catechu shows the cornel had been marked on the broach.",
		"literals": [
			{
				"field": "place",
				"value": "narthex",
				"phrase": "The modillion was cut in the narthex",
			},
			{
				"field": "cornel_room",
				"value": "broach",
				"phrase": "the cornel had been marked on the broach",
			},
		],
	},
	{
		"id": "E5",
		"title": "Aisle card",
		"source": "Einar, aisle clerk",
		"text": "The modillion was cut in the narthex. Einar turned the aisle in the narthex once the cornel was offered.",
		"literals": [
			{
				"field": "place",
				"value": "narthex",
				"phrase": "The modillion was cut in the narthex",
			},
			{
				"field": "aisle",
				"value": "Einar",
				"phrase": "Einar turned the aisle",
			},
			{
				"field": "aisle_room",
				"value": "narthex",
				"phrase": "turned the aisle in the narthex",
			},
		],
	},
	{
		"id": "E6",
		"title": "Resined slip",
		"source": "Aisle tote",
		"text": "The modillion was cut in the narthex. The aisle was resined at 206, and a pale tyrian still sat on the modillion.",
		"literals": [
			{
				"field": "place",
				"value": "narthex",
				"phrase": "The modillion was cut in the narthex",
			},
			{
				"field": "resin_hour",
				"value": "206",
				"phrase": "The aisle was resined at 206",
			},
		],
	},
	{
		"id": "E7",
		"title": "Modillion leaf",
		"source": "Cornel book",
		"text": "The modillion was cut at 208. The cornel had been marked at 207, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "208",
				"phrase": "The modillion was cut at 208",
			},
			{
				"field": "cornel_hour",
				"value": "207",
				"phrase": "The cornel had been marked at 207",
			},
		],
	},
	{
		"id": "E8",
		"title": "Sprig note",
		"source": "Joiner's sprig",
		"text": "The modillion was cut at 208. The cornel was opened so the cornel would take the modillion.",
		"literals": [
			{
				"field": "hour",
				"value": "208",
				"phrase": "The modillion was cut at 208",
			},
			{
				"field": "aim",
				"value": "take_cornel",
				"phrase": "so the cornel would take the modillion",
			},
		],
	},
	{
		"id": "E9",
		"title": "Tawed order",
		"source": "Broach card",
		"text": "The modillion was cut at 208. The broach was tawed at 209, and the narthex was hung at 210 once the cornel was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "208",
				"phrase": "The modillion was cut at 208",
			},
			{
				"field": "taw_hour",
				"value": "209",
				"phrase": "The broach was tawed at 209",
			},
			{
				"field": "hang_hour",
				"value": "210",
				"phrase": "the narthex was hung at 210",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"cornel",
		"cornel_room",
		"cornel_hour",
		"seen_from",
		"aisle",
		"aim",
		"aisle_room",
		"dogwood_room",
		"resin_hour",
		"taw_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "cornel", "aisle":
			return PEOPLE.duplicate()
		"place", "cornel_room", "seen_from", "aisle_room", "dogwood_room":
			return PLACES.duplicate()
		"hour", "cornel_hour", "resin_hour", "taw_hour", "hang_hour":
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
		missing.append("who cut the modillion")
	if pins["place"] == "":
		missing.append("where they cut the modillion")
	if pins["hour"] == "":
		missing.append("at which hour they cut the modillion")
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
		"Hilda":
			return "the modillion hand"
		"Astrid":
			return "the cornel hand"
		"Einar":
			return "the aisle clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"narthex":
			return "narthex"
		"aisle":
			return "aisle"
		"broach":
			return "broach"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"narthex":
			return "Narthex"
		"aisle":
			return "Aisle"
		"broach":
			return "Broach"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the modillion" % value
		"place":
			return "The modillion was cut in the %s" % place_label(value)
		"hour":
			return "The modillion was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the modillion" % value
		"place":
			return "the modillion was cut in the %s" % place_label(value)
		"hour":
			return "the modillion was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the modillion" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_cornel":
			return "so the cornel would take the modillion"
		"spare_cornel":
			return "to spare the cornel still waiting on the modillion"
		"set_cornel":
			return "to set the cornel before the narthex was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the modillion in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the cornel on the %s at %s." % [
			model["cornel"],
			role_short(str(model["cornel"])),
			place_label(str(model["cornel_room"])),
			model["cornel_hour"],
		],
		"%s (%s) turned the aisle in the %s." % [
			model["aisle"],
			role_short(str(model["aisle"])),
			place_label(str(model["aisle_room"])),
		],
		"The dogwood was hung on the %s." % place_label(str(model["dogwood_room"])),
		"The aisle was resined at %s." % model["resin_hour"],
		"The broach was tawed at %s." % model["taw_hour"],
		"The narthex was hung at %s." % model["hang_hour"],
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
	return "Who cut the modillion, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the modillion in."


static func cast_line() -> String:
	return "Hilda, modillion hand    Astrid, cornel hand    Einar, aisle clerk"


static func ready_line() -> String:
	return "Pin who cut the modillion, the room they cut it in, and the hour. Then submit."


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
