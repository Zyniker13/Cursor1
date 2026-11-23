extends RefCounted

# The volute.
#
# The player pins three facts about the cutting: who, the room the volute was
# cut in, and the hour. The timeline also records who marked the okoume, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the aumbrey, where that turn was made, why the volute was cut, where
# the meranti was hung, when the aumbrey was patchoulied, when the azebiki was japaned, and
# when the slype was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The volute"
const FILE_CODE := "CW-65"
const BLURB := "The volute left its peg at the joiner's hasp. Name who cut the volute, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Aethelred", "Beorhtric", "Raedwald"]
const PLACES: Array[String] = ["slype", "aumbrey", "azebiki"]
const HOURS: Array[String] = ["266", "267", "268", "269", "270"]
const AIMS: Array[String] = ["take_okoume", "spare_okoume", "set_okoume"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Okoume chit",
		"source": "Beorhtric, okoume hand",
		"text": "Aethelred cut the volute. Beorhtric had marked the okoume, and a pale alkannin still clung to the volute.",
		"literals": [
			{
				"field": "taker",
				"value": "Aethelred",
				"phrase": "Aethelred cut the volute",
			},
			{
				"field": "okoume",
				"value": "Beorhtric",
				"phrase": "Beorhtric had marked the okoume",
			},
		],
	},
	{
		"id": "E2",
		"title": "Chrysophanol sight",
		"source": "Aumbrey chrysophanol",
		"text": "Aethelred cut the volute. The voluting was seen from the aumbrey, beside the open okoume.",
		"literals": [
			{
				"field": "taker",
				"value": "Aethelred",
				"phrase": "Aethelred cut the volute",
			},
			{
				"field": "seen_from",
				"value": "aumbrey",
				"phrase": "The voluting was seen from the aumbrey",
			},
		],
	},
	{
		"id": "E3",
		"title": "Meranti bill",
		"source": "Azebiki nose",
		"text": "Aethelred cut the volute. With the okoume true, the meranti was hung on the azebiki.",
		"literals": [
			{
				"field": "taker",
				"value": "Aethelred",
				"phrase": "Aethelred cut the volute",
			},
			{
				"field": "meranti_room",
				"value": "azebiki",
				"phrase": "the meranti was hung on the azebiki",
			},
		],
	},
	{
		"id": "E4",
		"title": "Rhein slate",
		"source": "Slype rhein",
		"text": "The volute was cut in the slype. A fresh rhein shows the okoume had been marked on the azebiki.",
		"literals": [
			{
				"field": "place",
				"value": "slype",
				"phrase": "The volute was cut in the slype",
			},
			{
				"field": "okoume_room",
				"value": "azebiki",
				"phrase": "the okoume had been marked on the azebiki",
			},
		],
	},
	{
		"id": "E5",
		"title": "Aumbrey card",
		"source": "Raedwald, aumbrey clerk",
		"text": "The volute was cut in the slype. Raedwald turned the aumbrey in the slype once the okoume was offered.",
		"literals": [
			{
				"field": "place",
				"value": "slype",
				"phrase": "The volute was cut in the slype",
			},
			{
				"field": "aumbrey",
				"value": "Raedwald",
				"phrase": "Raedwald turned the aumbrey",
			},
			{
				"field": "aumbrey_room",
				"value": "slype",
				"phrase": "turned the aumbrey in the slype",
			},
		],
	},
	{
		"id": "E6",
		"title": "Patchoulied slip",
		"source": "Aumbrey tote",
		"text": "The volute was cut in the slype. The aumbrey was patchoulied at 266, and a pale physcion still sat on the volute.",
		"literals": [
			{
				"field": "place",
				"value": "slype",
				"phrase": "The volute was cut in the slype",
			},
			{
				"field": "patchouli_hour",
				"value": "266",
				"phrase": "The aumbrey was patchoulied at 266",
			},
		],
	},
	{
		"id": "E7",
		"title": "Volute leaf",
		"source": "Okoume book",
		"text": "The volute was cut at 268. The okoume had been marked at 267, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "268",
				"phrase": "The volute was cut at 268",
			},
			{
				"field": "okoume_hour",
				"value": "267",
				"phrase": "The okoume had been marked at 267",
			},
		],
	},
	{
		"id": "E8",
		"title": "Hasp note",
		"source": "Joiner's hasp",
		"text": "The volute was cut at 268. The okoume was opened so the okoume would take the volute.",
		"literals": [
			{
				"field": "hour",
				"value": "268",
				"phrase": "The volute was cut at 268",
			},
			{
				"field": "aim",
				"value": "take_okoume",
				"phrase": "so the okoume would take the volute",
			},
		],
	},
	{
		"id": "E9",
		"title": "Japaned order",
		"source": "Azebiki card",
		"text": "The volute was cut at 268. The azebiki was japaned at 269, and the slype was hung at 270 once the okoume was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "268",
				"phrase": "The volute was cut at 268",
			},
			{
				"field": "japan_hour",
				"value": "269",
				"phrase": "The azebiki was japaned at 269",
			},
			{
				"field": "hang_hour",
				"value": "270",
				"phrase": "the slype was hung at 270",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"okoume",
		"okoume_room",
		"okoume_hour",
		"seen_from",
		"aumbrey",
		"aim",
		"aumbrey_room",
		"meranti_room",
		"patchouli_hour",
		"japan_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "okoume", "aumbrey":
			return PEOPLE.duplicate()
		"place", "okoume_room", "seen_from", "aumbrey_room", "meranti_room":
			return PLACES.duplicate()
		"hour", "okoume_hour", "patchouli_hour", "japan_hour", "hang_hour":
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
		missing.append("who cut the volute")
	if pins["place"] == "":
		missing.append("where they cut the volute")
	if pins["hour"] == "":
		missing.append("at which hour they cut the volute")
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
		"Aethelred":
			return "the volute hand"
		"Beorhtric":
			return "the okoume hand"
		"Raedwald":
			return "the aumbrey clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"slype":
			return "slype"
		"aumbrey":
			return "aumbrey"
		"azebiki":
			return "azebiki"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"slype":
			return "Slype"
		"aumbrey":
			return "Aumbrey"
		"azebiki":
			return "Azebiki"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the volute" % value
		"place":
			return "The volute was cut in the %s" % place_label(value)
		"hour":
			return "The volute was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the volute" % value
		"place":
			return "the volute was cut in the %s" % place_label(value)
		"hour":
			return "the volute was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the volute" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_okoume":
			return "so the okoume would take the volute"
		"spare_okoume":
			return "to spare the okoume still waiting on the volute"
		"set_okoume":
			return "to set the okoume before the slype was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the volute in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the okoume on the %s at %s." % [
			model["okoume"],
			role_short(str(model["okoume"])),
			place_label(str(model["okoume_room"])),
			model["okoume_hour"],
		],
		"%s (%s) turned the aumbrey in the %s." % [
			model["aumbrey"],
			role_short(str(model["aumbrey"])),
			place_label(str(model["aumbrey_room"])),
		],
		"The meranti was hung on the %s." % place_label(str(model["meranti_room"])),
		"The aumbrey was patchoulied at %s." % model["patchouli_hour"],
		"The azebiki was japaned at %s." % model["japan_hour"],
		"The slype was hung at %s." % model["hang_hour"],
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
	return "Who cut the volute, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the volute in."


static func cast_line() -> String:
	return "Aethelred, volute hand    Beorhtric, okoume hand    Raedwald, aumbrey clerk"


static func ready_line() -> String:
	return "Pin who cut the volute, the room they cut it in, and the hour. Then submit."


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
