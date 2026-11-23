extends RefCounted

# The chevron.
#
# The player pins three facts about the cutting: who, the room the chevron was
# cut in, and the hour. The timeline also records who marked the jatoba, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the credence, where that turn was made, why the chevron was cut, where
# the cocobolo was hung, when the credence was coumarined, when the nokogiri was vanillined, and
# when the reredos was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The chevron"
const FILE_CODE := "CW-64"
const BLURB := "The chevron left its peg at the joiner's staple. Name who cut the chevron, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Aethelflaed", "Byrhtnoth", "Oswiu"]
const PLACES: Array[String] = ["reredos", "credence", "nokogiri"]
const HOURS: Array[String] = ["261", "262", "263", "264", "265"]
const AIMS: Array[String] = ["take_jatoba", "spare_jatoba", "set_jatoba"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Jatoba chit",
		"source": "Byrhtnoth, jatoba hand",
		"text": "Aethelflaed cut the chevron. Byrhtnoth had marked the jatoba, and a pale berberine still clung to the chevron.",
		"literals": [
			{
				"field": "taker",
				"value": "Aethelflaed",
				"phrase": "Aethelflaed cut the chevron",
			},
			{
				"field": "jatoba",
				"value": "Byrhtnoth",
				"phrase": "Byrhtnoth had marked the jatoba",
			},
		],
	},
	{
		"id": "E2",
		"title": "Curcumin sight",
		"source": "Credence curcumin",
		"text": "Aethelflaed cut the chevron. The chevroning was seen from the credence, beside the open jatoba.",
		"literals": [
			{
				"field": "taker",
				"value": "Aethelflaed",
				"phrase": "Aethelflaed cut the chevron",
			},
			{
				"field": "seen_from",
				"value": "credence",
				"phrase": "The chevroning was seen from the credence",
			},
		],
	},
	{
		"id": "E3",
		"title": "Cocobolo bill",
		"source": "Nokogiri nose",
		"text": "Aethelflaed cut the chevron. With the jatoba true, the cocobolo was hung on the nokogiri.",
		"literals": [
			{
				"field": "taker",
				"value": "Aethelflaed",
				"phrase": "Aethelflaed cut the chevron",
			},
			{
				"field": "cocobolo_room",
				"value": "nokogiri",
				"phrase": "the cocobolo was hung on the nokogiri",
			},
		],
	},
	{
		"id": "E4",
		"title": "Naringenin slate",
		"source": "Reredos naringenin",
		"text": "The chevron was cut in the reredos. A fresh naringenin shows the jatoba had been marked on the nokogiri.",
		"literals": [
			{
				"field": "place",
				"value": "reredos",
				"phrase": "The chevron was cut in the reredos",
			},
			{
				"field": "jatoba_room",
				"value": "nokogiri",
				"phrase": "the jatoba had been marked on the nokogiri",
			},
		],
	},
	{
		"id": "E5",
		"title": "Credence card",
		"source": "Oswiu, credence clerk",
		"text": "The chevron was cut in the reredos. Oswiu turned the credence in the reredos once the jatoba was offered.",
		"literals": [
			{
				"field": "place",
				"value": "reredos",
				"phrase": "The chevron was cut in the reredos",
			},
			{
				"field": "credence",
				"value": "Oswiu",
				"phrase": "Oswiu turned the credence",
			},
			{
				"field": "credence_room",
				"value": "reredos",
				"phrase": "turned the credence in the reredos",
			},
		],
	},
	{
		"id": "E6",
		"title": "Coumarined slip",
		"source": "Credence tote",
		"text": "The chevron was cut in the reredos. The credence was coumarined at 261, and a pale vitexin still sat on the chevron.",
		"literals": [
			{
				"field": "place",
				"value": "reredos",
				"phrase": "The chevron was cut in the reredos",
			},
			{
				"field": "coumarin_hour",
				"value": "261",
				"phrase": "The credence was coumarined at 261",
			},
		],
	},
	{
		"id": "E7",
		"title": "Chevron leaf",
		"source": "Jatoba book",
		"text": "The chevron was cut at 263. The jatoba had been marked at 262, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "263",
				"phrase": "The chevron was cut at 263",
			},
			{
				"field": "jatoba_hour",
				"value": "262",
				"phrase": "The jatoba had been marked at 262",
			},
		],
	},
	{
		"id": "E8",
		"title": "Staple note",
		"source": "Joiner's staple",
		"text": "The chevron was cut at 263. The jatoba was opened so the jatoba would take the chevron.",
		"literals": [
			{
				"field": "hour",
				"value": "263",
				"phrase": "The chevron was cut at 263",
			},
			{
				"field": "aim",
				"value": "take_jatoba",
				"phrase": "so the jatoba would take the chevron",
			},
		],
	},
	{
		"id": "E9",
		"title": "Vanillined order",
		"source": "Nokogiri card",
		"text": "The chevron was cut at 263. The nokogiri was vanillined at 264, and the reredos was hung at 265 once the jatoba was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "263",
				"phrase": "The chevron was cut at 263",
			},
			{
				"field": "vanillin_hour",
				"value": "264",
				"phrase": "The nokogiri was vanillined at 264",
			},
			{
				"field": "hang_hour",
				"value": "265",
				"phrase": "the reredos was hung at 265",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"jatoba",
		"jatoba_room",
		"jatoba_hour",
		"seen_from",
		"credence",
		"aim",
		"credence_room",
		"cocobolo_room",
		"coumarin_hour",
		"vanillin_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "jatoba", "credence":
			return PEOPLE.duplicate()
		"place", "jatoba_room", "seen_from", "credence_room", "cocobolo_room":
			return PLACES.duplicate()
		"hour", "jatoba_hour", "coumarin_hour", "vanillin_hour", "hang_hour":
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
		missing.append("who cut the chevron")
	if pins["place"] == "":
		missing.append("where they cut the chevron")
	if pins["hour"] == "":
		missing.append("at which hour they cut the chevron")
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
		"Aethelflaed":
			return "the chevron hand"
		"Byrhtnoth":
			return "the jatoba hand"
		"Oswiu":
			return "the credence clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"reredos":
			return "reredos"
		"credence":
			return "credence"
		"nokogiri":
			return "nokogiri"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"reredos":
			return "Reredos"
		"credence":
			return "Credence"
		"nokogiri":
			return "Nokogiri"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the chevron" % value
		"place":
			return "The chevron was cut in the %s" % place_label(value)
		"hour":
			return "The chevron was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the chevron" % value
		"place":
			return "the chevron was cut in the %s" % place_label(value)
		"hour":
			return "the chevron was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the chevron" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_jatoba":
			return "so the jatoba would take the chevron"
		"spare_jatoba":
			return "to spare the jatoba still waiting on the chevron"
		"set_jatoba":
			return "to set the jatoba before the reredos was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the chevron in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the jatoba on the %s at %s." % [
			model["jatoba"],
			role_short(str(model["jatoba"])),
			place_label(str(model["jatoba_room"])),
			model["jatoba_hour"],
		],
		"%s (%s) turned the credence in the %s." % [
			model["credence"],
			role_short(str(model["credence"])),
			place_label(str(model["credence_room"])),
		],
		"The cocobolo was hung on the %s." % place_label(str(model["cocobolo_room"])),
		"The credence was coumarined at %s." % model["coumarin_hour"],
		"The nokogiri was vanillined at %s." % model["vanillin_hour"],
		"The reredos was hung at %s." % model["hang_hour"],
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
	return "Who cut the chevron, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the chevron in."


static func cast_line() -> String:
	return "Aethelflaed, chevron hand    Byrhtnoth, jatoba hand    Oswiu, credence clerk"


static func ready_line() -> String:
	return "Pin who cut the chevron, the room they cut it in, and the hour. Then submit."


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
