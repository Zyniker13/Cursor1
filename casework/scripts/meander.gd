extends RefCounted

# The meander.
#
# The player pins three facts about the cutting: who, the room the meander was
# cut in, and the hour. The timeline also records who marked the wawa, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the tribune, where that turn was made, why the meander was cut, where
# the nyatoh was hung, when the tribune was opopanaxed, when the hikitori was camphored, and
# when the solar was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The meander"
const FILE_CODE := "CW-69"
const BLURB := "The meander left its peg at the joiner's toggle. Name who cut the meander, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["William", "Adelaide", "Louis"]
const PLACES: Array[String] = ["solar", "tribune", "hikitori"]
const HOURS: Array[String] = ["286", "287", "288", "289", "290"]
const AIMS: Array[String] = ["take_wawa", "spare_wawa", "set_wawa"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Wawa chit",
		"source": "Adelaide, wawa hand",
		"text": "William cut the meander. Adelaide had marked the wawa, and a pale glycitein still clung to the meander.",
		"literals": [
			{
				"field": "taker",
				"value": "William",
				"phrase": "William cut the meander",
			},
			{
				"field": "wawa",
				"value": "Adelaide",
				"phrase": "Adelaide had marked the wawa",
			},
		],
	},
	{
		"id": "E2",
		"title": "Afrormosin sight",
		"source": "Tribune afrormosin",
		"text": "William cut the meander. The meandering was seen from the tribune, beside the open wawa.",
		"literals": [
			{
				"field": "taker",
				"value": "William",
				"phrase": "William cut the meander",
			},
			{
				"field": "seen_from",
				"value": "tribune",
				"phrase": "The meandering was seen from the tribune",
			},
		],
	},
	{
		"id": "E3",
		"title": "Nyatoh bill",
		"source": "Hikitori nose",
		"text": "William cut the meander. With the wawa true, the nyatoh was hung on the hikitori.",
		"literals": [
			{
				"field": "taker",
				"value": "William",
				"phrase": "William cut the meander",
			},
			{
				"field": "nyatoh_room",
				"value": "hikitori",
				"phrase": "the nyatoh was hung on the hikitori",
			},
		],
	},
	{
		"id": "E4",
		"title": "Calycosin slate",
		"source": "Solar calycosin",
		"text": "The meander was cut in the solar. A fresh calycosin shows the wawa had been marked on the hikitori.",
		"literals": [
			{
				"field": "place",
				"value": "solar",
				"phrase": "The meander was cut in the solar",
			},
			{
				"field": "wawa_room",
				"value": "hikitori",
				"phrase": "the wawa had been marked on the hikitori",
			},
		],
	},
	{
		"id": "E5",
		"title": "Tribune card",
		"source": "Louis, tribune clerk",
		"text": "The meander was cut in the solar. Louis turned the tribune in the solar once the wawa was offered.",
		"literals": [
			{
				"field": "place",
				"value": "solar",
				"phrase": "The meander was cut in the solar",
			},
			{
				"field": "tribune",
				"value": "Louis",
				"phrase": "Louis turned the tribune",
			},
			{
				"field": "tribune_room",
				"value": "solar",
				"phrase": "turned the tribune in the solar",
			},
		],
	},
	{
		"id": "E6",
		"title": "Opopanaxed slip",
		"source": "Tribune tote",
		"text": "The meander was cut in the solar. The tribune was opopanaxed at 286, and a pale pratensein still sat on the meander.",
		"literals": [
			{
				"field": "place",
				"value": "solar",
				"phrase": "The meander was cut in the solar",
			},
			{
				"field": "opopanax_hour",
				"value": "286",
				"phrase": "The tribune was opopanaxed at 286",
			},
		],
	},
	{
		"id": "E7",
		"title": "Meander leaf",
		"source": "Wawa book",
		"text": "The meander was cut at 288. The wawa had been marked at 287, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "288",
				"phrase": "The meander was cut at 288",
			},
			{
				"field": "wawa_hour",
				"value": "287",
				"phrase": "The wawa had been marked at 287",
			},
		],
	},
	{
		"id": "E8",
		"title": "Toggle note",
		"source": "Joiner's toggle",
		"text": "The meander was cut at 288. The wawa was opened so the wawa would take the meander.",
		"literals": [
			{
				"field": "hour",
				"value": "288",
				"phrase": "The meander was cut at 288",
			},
			{
				"field": "aim",
				"value": "take_wawa",
				"phrase": "so the wawa would take the meander",
			},
		],
	},
	{
		"id": "E9",
		"title": "Camphored order",
		"source": "Hikitori card",
		"text": "The meander was cut at 288. The hikitori was camphored at 289, and the solar was hung at 290 once the wawa was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "288",
				"phrase": "The meander was cut at 288",
			},
			{
				"field": "camphor_hour",
				"value": "289",
				"phrase": "The hikitori was camphored at 289",
			},
			{
				"field": "hang_hour",
				"value": "290",
				"phrase": "the solar was hung at 290",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"wawa",
		"wawa_room",
		"wawa_hour",
		"seen_from",
		"tribune",
		"aim",
		"tribune_room",
		"nyatoh_room",
		"opopanax_hour",
		"camphor_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "wawa", "tribune":
			return PEOPLE.duplicate()
		"place", "wawa_room", "seen_from", "tribune_room", "nyatoh_room":
			return PLACES.duplicate()
		"hour", "wawa_hour", "opopanax_hour", "camphor_hour", "hang_hour":
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
		missing.append("who cut the meander")
	if pins["place"] == "":
		missing.append("where they cut the meander")
	if pins["hour"] == "":
		missing.append("at which hour they cut the meander")
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
		"William":
			return "the meander hand"
		"Adelaide":
			return "the wawa hand"
		"Louis":
			return "the tribune clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"solar":
			return "solar"
		"tribune":
			return "tribune"
		"hikitori":
			return "hikitori"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"solar":
			return "Solar"
		"tribune":
			return "Tribune"
		"hikitori":
			return "Hikitori"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the meander" % value
		"place":
			return "The meander was cut in the %s" % place_label(value)
		"hour":
			return "The meander was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the meander" % value
		"place":
			return "the meander was cut in the %s" % place_label(value)
		"hour":
			return "the meander was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the meander" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_wawa":
			return "so the wawa would take the meander"
		"spare_wawa":
			return "to spare the wawa still waiting on the meander"
		"set_wawa":
			return "to set the wawa before the solar was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the meander in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the wawa on the %s at %s." % [
			model["wawa"],
			role_short(str(model["wawa"])),
			place_label(str(model["wawa_room"])),
			model["wawa_hour"],
		],
		"%s (%s) turned the tribune in the %s." % [
			model["tribune"],
			role_short(str(model["tribune"])),
			place_label(str(model["tribune_room"])),
		],
		"The nyatoh was hung on the %s." % place_label(str(model["nyatoh_room"])),
		"The tribune was opopanaxed at %s." % model["opopanax_hour"],
		"The hikitori was camphored at %s." % model["camphor_hour"],
		"The solar was hung at %s." % model["hang_hour"],
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
	return "Who cut the meander, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the meander in."


static func cast_line() -> String:
	return "William, meander hand    Adelaide, wawa hand    Louis, tribune clerk"


static func ready_line() -> String:
	return "Pin who cut the meander, the room they cut it in, and the hour. Then submit."


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
