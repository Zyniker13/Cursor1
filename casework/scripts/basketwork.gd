extends RefCounted

# The basketwork.
#
# The player pins three facts about the cutting: who, the room the basketwork was
# cut in, and the hour. The timeline also records who marked the idigbo, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the sacrarium, where that turn was made, why the basketwork was cut, where
# the kingwood was hung, when the sacrarium was copaibaed, when the kuginuki was tolued, and
# when the dairy was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The basketwork"
const FILE_CODE := "CW-74"
const BLURB := "The basketwork left its peg at the joiner's stopper. Name who cut the basketwork, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Beatrice", "Roger", "Gilbert"]
const PLACES: Array[String] = ["dairy", "sacrarium", "kuginuki"]
const HOURS: Array[String] = ["311", "312", "313", "314", "315"]
const AIMS: Array[String] = ["take_idigbo", "spare_idigbo", "set_idigbo"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Idigbo chit",
		"source": "Roger, idigbo hand",
		"text": "Beatrice cut the basketwork. Roger had marked the idigbo, and a pale medicagol still clung to the basketwork.",
		"literals": [
			{
				"field": "taker",
				"value": "Beatrice",
				"phrase": "Beatrice cut the basketwork",
			},
			{
				"field": "idigbo",
				"value": "Roger",
				"phrase": "Roger had marked the idigbo",
			},
		],
	},
	{
		"id": "E2",
		"title": "Coumestrol sight",
		"source": "Sacrarium coumestrol",
		"text": "Beatrice cut the basketwork. The basketworking was seen from the sacrarium, beside the open idigbo.",
		"literals": [
			{
				"field": "taker",
				"value": "Beatrice",
				"phrase": "Beatrice cut the basketwork",
			},
			{
				"field": "seen_from",
				"value": "sacrarium",
				"phrase": "The basketworking was seen from the sacrarium",
			},
		],
	},
	{
		"id": "E3",
		"title": "Kingwood bill",
		"source": "Kuginuki nose",
		"text": "Beatrice cut the basketwork. With the idigbo true, the kingwood was hung on the kuginuki.",
		"literals": [
			{
				"field": "taker",
				"value": "Beatrice",
				"phrase": "Beatrice cut the basketwork",
			},
			{
				"field": "kingwood_room",
				"value": "kuginuki",
				"phrase": "the kingwood was hung on the kuginuki",
			},
		],
	},
	{
		"id": "E4",
		"title": "Sativan slate",
		"source": "Dairy sativan",
		"text": "The basketwork was cut in the dairy. A fresh sativan shows the idigbo had been marked on the kuginuki.",
		"literals": [
			{
				"field": "place",
				"value": "dairy",
				"phrase": "The basketwork was cut in the dairy",
			},
			{
				"field": "idigbo_room",
				"value": "kuginuki",
				"phrase": "the idigbo had been marked on the kuginuki",
			},
		],
	},
	{
		"id": "E5",
		"title": "Sacrarium card",
		"source": "Gilbert, sacrarium clerk",
		"text": "The basketwork was cut in the dairy. Gilbert turned the sacrarium in the dairy once the idigbo was offered.",
		"literals": [
			{
				"field": "place",
				"value": "dairy",
				"phrase": "The basketwork was cut in the dairy",
			},
			{
				"field": "sacrarium",
				"value": "Gilbert",
				"phrase": "Gilbert turned the sacrarium",
			},
			{
				"field": "sacrarium_room",
				"value": "dairy",
				"phrase": "turned the sacrarium in the dairy",
			},
		],
	},
	{
		"id": "E6",
		"title": "Copaibaed slip",
		"source": "Sacrarium tote",
		"text": "The basketwork was cut in the dairy. The sacrarium was copaibaed at 311, and a pale phaseollin still sat on the basketwork.",
		"literals": [
			{
				"field": "place",
				"value": "dairy",
				"phrase": "The basketwork was cut in the dairy",
			},
			{
				"field": "copaiba_hour",
				"value": "311",
				"phrase": "The sacrarium was copaibaed at 311",
			},
		],
	},
	{
		"id": "E7",
		"title": "Basketwork leaf",
		"source": "Idigbo book",
		"text": "The basketwork was cut at 313. The idigbo had been marked at 312, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "313",
				"phrase": "The basketwork was cut at 313",
			},
			{
				"field": "idigbo_hour",
				"value": "312",
				"phrase": "The idigbo had been marked at 312",
			},
		],
	},
	{
		"id": "E8",
		"title": "Stopper note",
		"source": "Joiner's stopper",
		"text": "The basketwork was cut at 313. The idigbo was opened so the idigbo would take the basketwork.",
		"literals": [
			{
				"field": "hour",
				"value": "313",
				"phrase": "The basketwork was cut at 313",
			},
			{
				"field": "aim",
				"value": "take_idigbo",
				"phrase": "so the idigbo would take the basketwork",
			},
		],
	},
	{
		"id": "E9",
		"title": "Tolued order",
		"source": "Kuginuki card",
		"text": "The basketwork was cut at 313. The kuginuki was tolued at 314, and the dairy was hung at 315 once the idigbo was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "313",
				"phrase": "The basketwork was cut at 313",
			},
			{
				"field": "tolu_hour",
				"value": "314",
				"phrase": "The kuginuki was tolued at 314",
			},
			{
				"field": "hang_hour",
				"value": "315",
				"phrase": "the dairy was hung at 315",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"idigbo",
		"idigbo_room",
		"idigbo_hour",
		"seen_from",
		"sacrarium",
		"aim",
		"sacrarium_room",
		"kingwood_room",
		"copaiba_hour",
		"tolu_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "idigbo", "sacrarium":
			return PEOPLE.duplicate()
		"place", "idigbo_room", "seen_from", "sacrarium_room", "kingwood_room":
			return PLACES.duplicate()
		"hour", "idigbo_hour", "copaiba_hour", "tolu_hour", "hang_hour":
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
		missing.append("who cut the basketwork")
	if pins["place"] == "":
		missing.append("where they cut the basketwork")
	if pins["hour"] == "":
		missing.append("at which hour they cut the basketwork")
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
		"Beatrice":
			return "the basketwork hand"
		"Roger":
			return "the idigbo hand"
		"Gilbert":
			return "the sacrarium clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"dairy":
			return "dairy"
		"sacrarium":
			return "sacrarium"
		"kuginuki":
			return "kuginuki"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"dairy":
			return "Dairy"
		"sacrarium":
			return "Sacrarium"
		"kuginuki":
			return "Kuginuki"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the basketwork" % value
		"place":
			return "The basketwork was cut in the %s" % place_label(value)
		"hour":
			return "The basketwork was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the basketwork" % value
		"place":
			return "the basketwork was cut in the %s" % place_label(value)
		"hour":
			return "the basketwork was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the basketwork" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_idigbo":
			return "so the idigbo would take the basketwork"
		"spare_idigbo":
			return "to spare the idigbo still waiting on the basketwork"
		"set_idigbo":
			return "to set the idigbo before the dairy was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the basketwork in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the idigbo on the %s at %s." % [
			model["idigbo"],
			role_short(str(model["idigbo"])),
			place_label(str(model["idigbo_room"])),
			model["idigbo_hour"],
		],
		"%s (%s) turned the sacrarium in the %s." % [
			model["sacrarium"],
			role_short(str(model["sacrarium"])),
			place_label(str(model["sacrarium_room"])),
		],
		"The kingwood was hung on the %s." % place_label(str(model["kingwood_room"])),
		"The sacrarium was copaibaed at %s." % model["copaiba_hour"],
		"The kuginuki was tolued at %s." % model["tolu_hour"],
		"The dairy was hung at %s." % model["hang_hour"],
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
	return "Who cut the basketwork, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the basketwork in."


static func cast_line() -> String:
	return "Beatrice, basketwork hand    Roger, idigbo hand    Gilbert, sacrarium clerk"


static func ready_line() -> String:
	return "Pin who cut the basketwork, the room they cut it in, and the hour. Then submit."


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
