extends RefCounted

# The triglyph.
#
# The player pins three facts about the cutting: who, the room the triglyph was
# cut in, and the hour. The timeline also records who marked the teak, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the refectory, where that turn was made, why the triglyph was cut, where
# the iroko was hung, when the refectory was smalted, when the lozenge was storaxed, and
# when the retrochoir was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The triglyph"
const FILE_CODE := "CW-60"
const BLURB := "The triglyph left its peg at the joiner's rivet. Name who cut the triglyph, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Osric", "Wulfrun", "Aethelthryth"]
const PLACES: Array[String] = ["retrochoir", "refectory", "lozenge"]
const HOURS: Array[String] = ["241", "242", "243", "244", "245"]
const AIMS: Array[String] = ["take_teak", "spare_teak", "set_teak"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Teak chit",
		"source": "Wulfrun, teak hand",
		"text": "Osric cut the triglyph. Wulfrun had marked the teak, and a pale rutin still clung to the triglyph.",
		"literals": [
			{
				"field": "taker",
				"value": "Osric",
				"phrase": "Osric cut the triglyph",
			},
			{
				"field": "teak",
				"value": "Wulfrun",
				"phrase": "Wulfrun had marked the teak",
			},
		],
	},
	{
		"id": "E2",
		"title": "Astaxanthin sight",
		"source": "Refectory astaxanthin",
		"text": "Osric cut the triglyph. The triglyphing was seen from the refectory, beside the open teak.",
		"literals": [
			{
				"field": "taker",
				"value": "Osric",
				"phrase": "Osric cut the triglyph",
			},
			{
				"field": "seen_from",
				"value": "refectory",
				"phrase": "The triglyphing was seen from the refectory",
			},
		],
	},
	{
		"id": "E3",
		"title": "Iroko bill",
		"source": "Lozenge nose",
		"text": "Osric cut the triglyph. With the teak true, the iroko was hung on the lozenge.",
		"literals": [
			{
				"field": "taker",
				"value": "Osric",
				"phrase": "Osric cut the triglyph",
			},
			{
				"field": "iroko_room",
				"value": "lozenge",
				"phrase": "the iroko was hung on the lozenge",
			},
		],
	},
	{
		"id": "E4",
		"title": "Quercetin slate",
		"source": "Retrochoir quercetin",
		"text": "The triglyph was cut in the retrochoir. A fresh quercetin shows the teak had been marked on the lozenge.",
		"literals": [
			{
				"field": "place",
				"value": "retrochoir",
				"phrase": "The triglyph was cut in the retrochoir",
			},
			{
				"field": "teak_room",
				"value": "lozenge",
				"phrase": "the teak had been marked on the lozenge",
			},
		],
	},
	{
		"id": "E5",
		"title": "Refectory card",
		"source": "Aethelthryth, refectory clerk",
		"text": "The triglyph was cut in the retrochoir. Aethelthryth turned the refectory in the retrochoir once the teak was offered.",
		"literals": [
			{
				"field": "place",
				"value": "retrochoir",
				"phrase": "The triglyph was cut in the retrochoir",
			},
			{
				"field": "refectory",
				"value": "Aethelthryth",
				"phrase": "Aethelthryth turned the refectory",
			},
			{
				"field": "refectory_room",
				"value": "retrochoir",
				"phrase": "turned the refectory in the retrochoir",
			},
		],
	},
	{
		"id": "E6",
		"title": "Smalted slip",
		"source": "Refectory tote",
		"text": "The triglyph was cut in the retrochoir. The refectory was smalted at 241, and a pale genistein still sat on the triglyph.",
		"literals": [
			{
				"field": "place",
				"value": "retrochoir",
				"phrase": "The triglyph was cut in the retrochoir",
			},
			{
				"field": "smalt_hour",
				"value": "241",
				"phrase": "The refectory was smalted at 241",
			},
		],
	},
	{
		"id": "E7",
		"title": "Triglyph leaf",
		"source": "Teak book",
		"text": "The triglyph was cut at 243. The teak had been marked at 242, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "243",
				"phrase": "The triglyph was cut at 243",
			},
			{
				"field": "teak_hour",
				"value": "242",
				"phrase": "The teak had been marked at 242",
			},
		],
	},
	{
		"id": "E8",
		"title": "Rivet note",
		"source": "Joiner's rivet",
		"text": "The triglyph was cut at 243. The teak was opened so the teak would take the triglyph.",
		"literals": [
			{
				"field": "hour",
				"value": "243",
				"phrase": "The triglyph was cut at 243",
			},
			{
				"field": "aim",
				"value": "take_teak",
				"phrase": "so the teak would take the triglyph",
			},
		],
	},
	{
		"id": "E9",
		"title": "Storaxed order",
		"source": "Lozenge card",
		"text": "The triglyph was cut at 243. The lozenge was storaxed at 244, and the retrochoir was hung at 245 once the teak was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "243",
				"phrase": "The triglyph was cut at 243",
			},
			{
				"field": "storax_hour",
				"value": "244",
				"phrase": "The lozenge was storaxed at 244",
			},
			{
				"field": "hang_hour",
				"value": "245",
				"phrase": "the retrochoir was hung at 245",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"teak",
		"teak_room",
		"teak_hour",
		"seen_from",
		"refectory",
		"aim",
		"refectory_room",
		"iroko_room",
		"smalt_hour",
		"storax_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "teak", "refectory":
			return PEOPLE.duplicate()
		"place", "teak_room", "seen_from", "refectory_room", "iroko_room":
			return PLACES.duplicate()
		"hour", "teak_hour", "smalt_hour", "storax_hour", "hang_hour":
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
		missing.append("who cut the triglyph")
	if pins["place"] == "":
		missing.append("where they cut the triglyph")
	if pins["hour"] == "":
		missing.append("at which hour they cut the triglyph")
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
		"Osric":
			return "the triglyph hand"
		"Wulfrun":
			return "the teak hand"
		"Aethelthryth":
			return "the refectory clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"retrochoir":
			return "retrochoir"
		"refectory":
			return "refectory"
		"lozenge":
			return "lozenge"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"retrochoir":
			return "Retrochoir"
		"refectory":
			return "Refectory"
		"lozenge":
			return "Lozenge"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the triglyph" % value
		"place":
			return "The triglyph was cut in the %s" % place_label(value)
		"hour":
			return "The triglyph was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the triglyph" % value
		"place":
			return "the triglyph was cut in the %s" % place_label(value)
		"hour":
			return "the triglyph was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the triglyph" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_teak":
			return "so the teak would take the triglyph"
		"spare_teak":
			return "to spare the teak still waiting on the triglyph"
		"set_teak":
			return "to set the teak before the retrochoir was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the triglyph in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the teak on the %s at %s." % [
			model["teak"],
			role_short(str(model["teak"])),
			place_label(str(model["teak_room"])),
			model["teak_hour"],
		],
		"%s (%s) turned the refectory in the %s." % [
			model["refectory"],
			role_short(str(model["refectory"])),
			place_label(str(model["refectory_room"])),
		],
		"The iroko was hung on the %s." % place_label(str(model["iroko_room"])),
		"The refectory was smalted at %s." % model["smalt_hour"],
		"The lozenge was storaxed at %s." % model["storax_hour"],
		"The retrochoir was hung at %s." % model["hang_hour"],
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
	return "Who cut the triglyph, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the triglyph in."


static func cast_line() -> String:
	return "Osric, triglyph hand    Wulfrun, teak hand    Aethelthryth, refectory clerk"


static func ready_line() -> String:
	return "Pin who cut the triglyph, the room they cut it in, and the hour. Then submit."


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
