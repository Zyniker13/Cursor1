extends RefCounted

# The gutta.
#
# The player pins three facts about the cutting: who, the room the gutta was
# cut in, and the hour. The timeline also records who marked the linden, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the perch, where that turn was made, why the gutta was cut, where
# the aspen was hung, when the perch was rosined, when the fid was stained, and
# when the apse was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The gutta"
const FILE_CODE := "CW-51"
const BLURB := "The gutta left its peg at the joiner's stud. Name who cut the gutta, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Ingrid", "Tove", "Remy"]
const PLACES: Array[String] = ["apse", "perch", "fid"]
const HOURS: Array[String] = ["196", "197", "198", "199", "200"]
const AIMS: Array[String] = ["take_linden", "spare_linden", "set_linden"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Linden chit",
		"source": "Tove, linden hand",
		"text": "Ingrid cut the gutta. Tove had marked the linden, and a pale henna still clung to the gutta.",
		"literals": [
			{
				"field": "taker",
				"value": "Ingrid",
				"phrase": "Ingrid cut the gutta",
			},
			{
				"field": "linden",
				"value": "Tove",
				"phrase": "Tove had marked the linden",
			},
		],
	},
	{
		"id": "E2",
		"title": "Alkanet sight",
		"source": "Perch alkanet",
		"text": "Ingrid cut the gutta. The guttaing was seen from the perch, beside the open linden.",
		"literals": [
			{
				"field": "taker",
				"value": "Ingrid",
				"phrase": "Ingrid cut the gutta",
			},
			{
				"field": "seen_from",
				"value": "perch",
				"phrase": "The guttaing was seen from the perch",
			},
		],
	},
	{
		"id": "E3",
		"title": "Aspen bill",
		"source": "Fid nose",
		"text": "Ingrid cut the gutta. With the linden true, the aspen was hung on the fid.",
		"literals": [
			{
				"field": "taker",
				"value": "Ingrid",
				"phrase": "Ingrid cut the gutta",
			},
			{
				"field": "aspen_room",
				"value": "fid",
				"phrase": "the aspen was hung on the fid",
			},
		],
	},
	{
		"id": "E4",
		"title": "Cutch slate",
		"source": "Apse cutch",
		"text": "The gutta was cut in the apse. A fresh cutch shows the linden had been marked on the fid.",
		"literals": [
			{
				"field": "place",
				"value": "apse",
				"phrase": "The gutta was cut in the apse",
			},
			{
				"field": "linden_room",
				"value": "fid",
				"phrase": "the linden had been marked on the fid",
			},
		],
	},
	{
		"id": "E5",
		"title": "Perch card",
		"source": "Remy, perch clerk",
		"text": "The gutta was cut in the apse. Remy turned the perch in the apse once the linden was offered.",
		"literals": [
			{
				"field": "place",
				"value": "apse",
				"phrase": "The gutta was cut in the apse",
			},
			{
				"field": "perch",
				"value": "Remy",
				"phrase": "Remy turned the perch",
			},
			{
				"field": "perch_room",
				"value": "apse",
				"phrase": "turned the perch in the apse",
			},
		],
	},
	{
		"id": "E6",
		"title": "Rosined slip",
		"source": "Perch tote",
		"text": "The gutta was cut in the apse. The perch was rosined at 196, and a pale murex still sat on the gutta.",
		"literals": [
			{
				"field": "place",
				"value": "apse",
				"phrase": "The gutta was cut in the apse",
			},
			{
				"field": "rosin_hour",
				"value": "196",
				"phrase": "The perch was rosined at 196",
			},
		],
	},
	{
		"id": "E7",
		"title": "Gutta leaf",
		"source": "Linden book",
		"text": "The gutta was cut at 198. The linden had been marked at 197, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "198",
				"phrase": "The gutta was cut at 198",
			},
			{
				"field": "linden_hour",
				"value": "197",
				"phrase": "The linden had been marked at 197",
			},
		],
	},
	{
		"id": "E8",
		"title": "Stud note",
		"source": "Joiner's stud",
		"text": "The gutta was cut at 198. The linden was opened so the linden would take the gutta.",
		"literals": [
			{
				"field": "hour",
				"value": "198",
				"phrase": "The gutta was cut at 198",
			},
			{
				"field": "aim",
				"value": "take_linden",
				"phrase": "so the linden would take the gutta",
			},
		],
	},
	{
		"id": "E9",
		"title": "Stained order",
		"source": "Fid card",
		"text": "The gutta was cut at 198. The fid was stained at 199, and the apse was hung at 200 once the linden was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "198",
				"phrase": "The gutta was cut at 198",
			},
			{
				"field": "stain_hour",
				"value": "199",
				"phrase": "The fid was stained at 199",
			},
			{
				"field": "hang_hour",
				"value": "200",
				"phrase": "the apse was hung at 200",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"linden",
		"linden_room",
		"linden_hour",
		"seen_from",
		"perch",
		"aim",
		"perch_room",
		"aspen_room",
		"rosin_hour",
		"stain_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "linden", "perch":
			return PEOPLE.duplicate()
		"place", "linden_room", "seen_from", "perch_room", "aspen_room":
			return PLACES.duplicate()
		"hour", "linden_hour", "rosin_hour", "stain_hour", "hang_hour":
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
		missing.append("who cut the gutta")
	if pins["place"] == "":
		missing.append("where they cut the gutta")
	if pins["hour"] == "":
		missing.append("at which hour they cut the gutta")
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
		"Ingrid":
			return "the gutta hand"
		"Tove":
			return "the linden hand"
		"Remy":
			return "the perch clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"apse":
			return "apse"
		"perch":
			return "perch"
		"fid":
			return "fid"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"apse":
			return "Apse"
		"perch":
			return "Perch"
		"fid":
			return "Fid"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the gutta" % value
		"place":
			return "The gutta was cut in the %s" % place_label(value)
		"hour":
			return "The gutta was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the gutta" % value
		"place":
			return "the gutta was cut in the %s" % place_label(value)
		"hour":
			return "the gutta was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the gutta" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_linden":
			return "so the linden would take the gutta"
		"spare_linden":
			return "to spare the linden still waiting on the gutta"
		"set_linden":
			return "to set the linden before the apse was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the gutta in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the linden on the %s at %s." % [
			model["linden"],
			role_short(str(model["linden"])),
			place_label(str(model["linden_room"])),
			model["linden_hour"],
		],
		"%s (%s) turned the perch in the %s." % [
			model["perch"],
			role_short(str(model["perch"])),
			place_label(str(model["perch_room"])),
		],
		"The aspen was hung on the %s." % place_label(str(model["aspen_room"])),
		"The perch was rosined at %s." % model["rosin_hour"],
		"The fid was stained at %s." % model["stain_hour"],
		"The apse was hung at %s." % model["hang_hour"],
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
	return "Who cut the gutta, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the gutta in."


static func cast_line() -> String:
	return "Ingrid, gutta hand    Tove, linden hand    Remy, perch clerk"


static func ready_line() -> String:
	return "Pin who cut the gutta, the room they cut it in, and the hour. Then submit."


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
