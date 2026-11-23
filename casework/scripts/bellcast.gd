extends RefCounted

# The bellcast.
#
# The player pins three facts about the cutting: who, the room the bellcast was
# cut in, and the hour. The timeline also records who marked the hickory, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the calefactory, where that turn was made, why the bellcast was cut, where
# the paulownia was hung, when the calefactory was orpimented, when the elliptic was cinnabared, and
# when the triforium was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The bellcast"
const FILE_CODE := "CW-58"
const BLURB := "The bellcast left its peg at the joiner's thimble. Name who cut the bellcast, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Cuthbert", "Wulfstan", "Frideswide"]
const PLACES: Array[String] = ["triforium", "calefactory", "elliptic"]
const HOURS: Array[String] = ["231", "232", "233", "234", "235"]
const AIMS: Array[String] = ["take_hickory", "spare_hickory", "set_hickory"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Hickory chit",
		"source": "Wulfstan, hickory hand",
		"text": "Cuthbert cut the bellcast. Wulfstan had marked the hickory, and a pale orcinol still clung to the bellcast.",
		"literals": [
			{
				"field": "taker",
				"value": "Cuthbert",
				"phrase": "Cuthbert cut the bellcast",
			},
			{
				"field": "hickory",
				"value": "Wulfstan",
				"phrase": "Wulfstan had marked the hickory",
			},
		],
	},
	{
		"id": "E2",
		"title": "Haematoxylin sight",
		"source": "Calefactory haematoxylin",
		"text": "Cuthbert cut the bellcast. The bellcasting was seen from the calefactory, beside the open hickory.",
		"literals": [
			{
				"field": "taker",
				"value": "Cuthbert",
				"phrase": "Cuthbert cut the bellcast",
			},
			{
				"field": "seen_from",
				"value": "calefactory",
				"phrase": "The bellcasting was seen from the calefactory",
			},
		],
	},
	{
		"id": "E3",
		"title": "Paulownia bill",
		"source": "Elliptic nose",
		"text": "Cuthbert cut the bellcast. With the hickory true, the paulownia was hung on the elliptic.",
		"literals": [
			{
				"field": "taker",
				"value": "Cuthbert",
				"phrase": "Cuthbert cut the bellcast",
			},
			{
				"field": "paulownia_room",
				"value": "elliptic",
				"phrase": "the paulownia was hung on the elliptic",
			},
		],
	},
	{
		"id": "E4",
		"title": "Fisetin slate",
		"source": "Triforium fisetin",
		"text": "The bellcast was cut in the triforium. A fresh fisetin shows the hickory had been marked on the elliptic.",
		"literals": [
			{
				"field": "place",
				"value": "triforium",
				"phrase": "The bellcast was cut in the triforium",
			},
			{
				"field": "hickory_room",
				"value": "elliptic",
				"phrase": "the hickory had been marked on the elliptic",
			},
		],
	},
	{
		"id": "E5",
		"title": "Calefactory card",
		"source": "Frideswide, calefactory clerk",
		"text": "The bellcast was cut in the triforium. Frideswide turned the calefactory in the triforium once the hickory was offered.",
		"literals": [
			{
				"field": "place",
				"value": "triforium",
				"phrase": "The bellcast was cut in the triforium",
			},
			{
				"field": "calefactory",
				"value": "Frideswide",
				"phrase": "Frideswide turned the calefactory",
			},
			{
				"field": "calefactory_room",
				"value": "triforium",
				"phrase": "turned the calefactory in the triforium",
			},
		],
	},
	{
		"id": "E6",
		"title": "Orpimented slip",
		"source": "Calefactory tote",
		"text": "The bellcast was cut in the triforium. The calefactory was orpimented at 231, and a pale santalin still sat on the bellcast.",
		"literals": [
			{
				"field": "place",
				"value": "triforium",
				"phrase": "The bellcast was cut in the triforium",
			},
			{
				"field": "orpiment_hour",
				"value": "231",
				"phrase": "The calefactory was orpimented at 231",
			},
		],
	},
	{
		"id": "E7",
		"title": "Bellcast leaf",
		"source": "Hickory book",
		"text": "The bellcast was cut at 233. The hickory had been marked at 232, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "233",
				"phrase": "The bellcast was cut at 233",
			},
			{
				"field": "hickory_hour",
				"value": "232",
				"phrase": "The hickory had been marked at 232",
			},
		],
	},
	{
		"id": "E8",
		"title": "Thimble note",
		"source": "Joiner's thimble",
		"text": "The bellcast was cut at 233. The hickory was opened so the hickory would take the bellcast.",
		"literals": [
			{
				"field": "hour",
				"value": "233",
				"phrase": "The bellcast was cut at 233",
			},
			{
				"field": "aim",
				"value": "take_hickory",
				"phrase": "so the hickory would take the bellcast",
			},
		],
	},
	{
		"id": "E9",
		"title": "Cinnabared order",
		"source": "Elliptic card",
		"text": "The bellcast was cut at 233. The elliptic was cinnabared at 234, and the triforium was hung at 235 once the hickory was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "233",
				"phrase": "The bellcast was cut at 233",
			},
			{
				"field": "cinnabar_hour",
				"value": "234",
				"phrase": "The elliptic was cinnabared at 234",
			},
			{
				"field": "hang_hour",
				"value": "235",
				"phrase": "the triforium was hung at 235",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"hickory",
		"hickory_room",
		"hickory_hour",
		"seen_from",
		"calefactory",
		"aim",
		"calefactory_room",
		"paulownia_room",
		"orpiment_hour",
		"cinnabar_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "hickory", "calefactory":
			return PEOPLE.duplicate()
		"place", "hickory_room", "seen_from", "calefactory_room", "paulownia_room":
			return PLACES.duplicate()
		"hour", "hickory_hour", "orpiment_hour", "cinnabar_hour", "hang_hour":
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
		missing.append("who cut the bellcast")
	if pins["place"] == "":
		missing.append("where they cut the bellcast")
	if pins["hour"] == "":
		missing.append("at which hour they cut the bellcast")
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
		"Cuthbert":
			return "the bellcast hand"
		"Wulfstan":
			return "the hickory hand"
		"Frideswide":
			return "the calefactory clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"triforium":
			return "triforium"
		"calefactory":
			return "calefactory"
		"elliptic":
			return "elliptic"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"triforium":
			return "Triforium"
		"calefactory":
			return "Calefactory"
		"elliptic":
			return "Elliptic"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the bellcast" % value
		"place":
			return "The bellcast was cut in the %s" % place_label(value)
		"hour":
			return "The bellcast was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the bellcast" % value
		"place":
			return "the bellcast was cut in the %s" % place_label(value)
		"hour":
			return "the bellcast was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the bellcast" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_hickory":
			return "so the hickory would take the bellcast"
		"spare_hickory":
			return "to spare the hickory still waiting on the bellcast"
		"set_hickory":
			return "to set the hickory before the triforium was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the bellcast in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the hickory on the %s at %s." % [
			model["hickory"],
			role_short(str(model["hickory"])),
			place_label(str(model["hickory_room"])),
			model["hickory_hour"],
		],
		"%s (%s) turned the calefactory in the %s." % [
			model["calefactory"],
			role_short(str(model["calefactory"])),
			place_label(str(model["calefactory_room"])),
		],
		"The paulownia was hung on the %s." % place_label(str(model["paulownia_room"])),
		"The calefactory was orpimented at %s." % model["orpiment_hour"],
		"The elliptic was cinnabared at %s." % model["cinnabar_hour"],
		"The triforium was hung at %s." % model["hang_hour"],
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
	return "Who cut the bellcast, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the bellcast in."


static func cast_line() -> String:
	return "Cuthbert, bellcast hand    Wulfstan, hickory hand    Frideswide, calefactory clerk"


static func ready_line() -> String:
	return "Pin who cut the bellcast, the room they cut it in, and the hour. Then submit."


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
