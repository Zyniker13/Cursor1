extends RefCounted

# The cable.
#
# The player pins three facts about the cutting: who, the room the cable was
# cut in, and the hour. The timeline also records who marked the magnolia, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the sedilia, where that turn was made, why the cable was cut, where
# the bubinga was hung, when the sedilia was olibanumed, when the kataba was labdanumed, and
# when the pulpitum was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The cable"
const FILE_CODE := "CW-63"
const BLURB := "The cable left its peg at the joiner's becket. Name who cut the cable, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Aelfwig", "Cynesige", "Wulfthryth"]
const PLACES: Array[String] = ["pulpitum", "sedilia", "kataba"]
const HOURS: Array[String] = ["256", "257", "258", "259", "260"]
const AIMS: Array[String] = ["take_magnolia", "spare_magnolia", "set_magnolia"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Magnolia chit",
		"source": "Cynesige, magnolia hand",
		"text": "Aelfwig cut the cable. Cynesige had marked the magnolia, and a pale realgar still clung to the cable.",
		"literals": [
			{
				"field": "taker",
				"value": "Aelfwig",
				"phrase": "Aelfwig cut the cable",
			},
			{
				"field": "magnolia",
				"value": "Cynesige",
				"phrase": "Cynesige had marked the magnolia",
			},
		],
	},
	{
		"id": "E2",
		"title": "Hypericin sight",
		"source": "Sedilia hypericin",
		"text": "Aelfwig cut the cable. The cabling was seen from the sedilia, beside the open magnolia.",
		"literals": [
			{
				"field": "taker",
				"value": "Aelfwig",
				"phrase": "Aelfwig cut the cable",
			},
			{
				"field": "seen_from",
				"value": "sedilia",
				"phrase": "The cabling was seen from the sedilia",
			},
		],
	},
	{
		"id": "E3",
		"title": "Bubinga bill",
		"source": "Kataba nose",
		"text": "Aelfwig cut the cable. With the magnolia true, the bubinga was hung on the kataba.",
		"literals": [
			{
				"field": "taker",
				"value": "Aelfwig",
				"phrase": "Aelfwig cut the cable",
			},
			{
				"field": "bubinga_room",
				"value": "kataba",
				"phrase": "the bubinga was hung on the kataba",
			},
		],
	},
	{
		"id": "E4",
		"title": "Stibnite slate",
		"source": "Pulpitum stibnite",
		"text": "The cable was cut in the pulpitum. A fresh stibnite shows the magnolia had been marked on the kataba.",
		"literals": [
			{
				"field": "place",
				"value": "pulpitum",
				"phrase": "The cable was cut in the pulpitum",
			},
			{
				"field": "magnolia_room",
				"value": "kataba",
				"phrase": "the magnolia had been marked on the kataba",
			},
		],
	},
	{
		"id": "E5",
		"title": "Sedilia card",
		"source": "Wulfthryth, sedilia clerk",
		"text": "The cable was cut in the pulpitum. Wulfthryth turned the sedilia in the pulpitum once the magnolia was offered.",
		"literals": [
			{
				"field": "place",
				"value": "pulpitum",
				"phrase": "The cable was cut in the pulpitum",
			},
			{
				"field": "sedilia",
				"value": "Wulfthryth",
				"phrase": "Wulfthryth turned the sedilia",
			},
			{
				"field": "sedilia_room",
				"value": "pulpitum",
				"phrase": "turned the sedilia in the pulpitum",
			},
		],
	},
	{
		"id": "E6",
		"title": "Olibanumed slip",
		"source": "Sedilia tote",
		"text": "The cable was cut in the pulpitum. The sedilia was olibanumed at 256, and a pale minium still sat on the cable.",
		"literals": [
			{
				"field": "place",
				"value": "pulpitum",
				"phrase": "The cable was cut in the pulpitum",
			},
			{
				"field": "olibanum_hour",
				"value": "256",
				"phrase": "The sedilia was olibanumed at 256",
			},
		],
	},
	{
		"id": "E7",
		"title": "Cable leaf",
		"source": "Magnolia book",
		"text": "The cable was cut at 258. The magnolia had been marked at 257, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "258",
				"phrase": "The cable was cut at 258",
			},
			{
				"field": "magnolia_hour",
				"value": "257",
				"phrase": "The magnolia had been marked at 257",
			},
		],
	},
	{
		"id": "E8",
		"title": "Becket note",
		"source": "Joiner's becket",
		"text": "The cable was cut at 258. The magnolia was opened so the magnolia would take the cable.",
		"literals": [
			{
				"field": "hour",
				"value": "258",
				"phrase": "The cable was cut at 258",
			},
			{
				"field": "aim",
				"value": "take_magnolia",
				"phrase": "so the magnolia would take the cable",
			},
		],
	},
	{
		"id": "E9",
		"title": "Labdanumed order",
		"source": "Kataba card",
		"text": "The cable was cut at 258. The kataba was labdanumed at 259, and the pulpitum was hung at 260 once the magnolia was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "258",
				"phrase": "The cable was cut at 258",
			},
			{
				"field": "labdanum_hour",
				"value": "259",
				"phrase": "The kataba was labdanumed at 259",
			},
			{
				"field": "hang_hour",
				"value": "260",
				"phrase": "the pulpitum was hung at 260",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"magnolia",
		"magnolia_room",
		"magnolia_hour",
		"seen_from",
		"sedilia",
		"aim",
		"sedilia_room",
		"bubinga_room",
		"olibanum_hour",
		"labdanum_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "magnolia", "sedilia":
			return PEOPLE.duplicate()
		"place", "magnolia_room", "seen_from", "sedilia_room", "bubinga_room":
			return PLACES.duplicate()
		"hour", "magnolia_hour", "olibanum_hour", "labdanum_hour", "hang_hour":
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
		missing.append("who cut the cable")
	if pins["place"] == "":
		missing.append("where they cut the cable")
	if pins["hour"] == "":
		missing.append("at which hour they cut the cable")
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
		"Aelfwig":
			return "the cable hand"
		"Cynesige":
			return "the magnolia hand"
		"Wulfthryth":
			return "the sedilia clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"pulpitum":
			return "pulpitum"
		"sedilia":
			return "sedilia"
		"kataba":
			return "kataba"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"pulpitum":
			return "Pulpitum"
		"sedilia":
			return "Sedilia"
		"kataba":
			return "Kataba"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the cable" % value
		"place":
			return "The cable was cut in the %s" % place_label(value)
		"hour":
			return "The cable was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the cable" % value
		"place":
			return "the cable was cut in the %s" % place_label(value)
		"hour":
			return "the cable was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the cable" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_magnolia":
			return "so the magnolia would take the cable"
		"spare_magnolia":
			return "to spare the magnolia still waiting on the cable"
		"set_magnolia":
			return "to set the magnolia before the pulpitum was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the cable in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the magnolia on the %s at %s." % [
			model["magnolia"],
			role_short(str(model["magnolia"])),
			place_label(str(model["magnolia_room"])),
			model["magnolia_hour"],
		],
		"%s (%s) turned the sedilia in the %s." % [
			model["sedilia"],
			role_short(str(model["sedilia"])),
			place_label(str(model["sedilia_room"])),
		],
		"The bubinga was hung on the %s." % place_label(str(model["bubinga_room"])),
		"The sedilia was olibanumed at %s." % model["olibanum_hour"],
		"The kataba was labdanumed at %s." % model["labdanum_hour"],
		"The pulpitum was hung at %s." % model["hang_hour"],
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
	return "Who cut the cable, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the cable in."


static func cast_line() -> String:
	return "Aelfwig, cable hand    Cynesige, magnolia hand    Wulfthryth, sedilia clerk"


static func ready_line() -> String:
	return "Pin who cut the cable, the room they cut it in, and the hour. Then submit."


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
