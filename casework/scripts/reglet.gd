extends RefCounted

# The reglet.
#
# The player pins three facts about the cutting: who, the room the reglet was
# cut in, and the hour. The timeline also records who marked the pear, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the settle, where that turn was made, why the reglet was cut, where
# the damson was hung, when the settle was sized, when the bodkin was clayed, and
# when the nave was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The reglet"
const FILE_CODE := "CW-50"
const BLURB := "The reglet left its peg at the joiner's jade. Name who cut the reglet, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Iris", "Otto", "Leif"]
const PLACES: Array[String] = ["nave", "settle", "bodkin"]
const HOURS: Array[String] = ["191", "192", "193", "194", "195"]
const AIMS: Array[String] = ["take_pear", "spare_pear", "set_pear"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Pear chit",
		"source": "Otto, pear hand",
		"text": "Iris cut the reglet. Otto had marked the pear, and a pale logwood still clung to the reglet.",
		"literals": [
			{
				"field": "taker",
				"value": "Iris",
				"phrase": "Iris cut the reglet",
			},
			{
				"field": "pear",
				"value": "Otto",
				"phrase": "Otto had marked the pear",
			},
		],
	},
	{
		"id": "E2",
		"title": "Sumac sight",
		"source": "Settle sumac",
		"text": "Iris cut the reglet. The regleting was seen from the settle, beside the open pear.",
		"literals": [
			{
				"field": "taker",
				"value": "Iris",
				"phrase": "Iris cut the reglet",
			},
			{
				"field": "seen_from",
				"value": "settle",
				"phrase": "The regleting was seen from the settle",
			},
		],
	},
	{
		"id": "E3",
		"title": "Damson bill",
		"source": "Bodkin nose",
		"text": "Iris cut the reglet. With the pear true, the damson was hung on the bodkin.",
		"literals": [
			{
				"field": "taker",
				"value": "Iris",
				"phrase": "Iris cut the reglet",
			},
			{
				"field": "damson_room",
				"value": "bodkin",
				"phrase": "the damson was hung on the bodkin",
			},
		],
	},
	{
		"id": "E4",
		"title": "Annatto slate",
		"source": "Nave annatto",
		"text": "The reglet was cut in the nave. A fresh annatto shows the pear had been marked on the bodkin.",
		"literals": [
			{
				"field": "place",
				"value": "nave",
				"phrase": "The reglet was cut in the nave",
			},
			{
				"field": "pear_room",
				"value": "bodkin",
				"phrase": "the pear had been marked on the bodkin",
			},
		],
	},
	{
		"id": "E5",
		"title": "Settle card",
		"source": "Leif, settle clerk",
		"text": "The reglet was cut in the nave. Leif turned the settle in the nave once the pear was offered.",
		"literals": [
			{
				"field": "place",
				"value": "nave",
				"phrase": "The reglet was cut in the nave",
			},
			{
				"field": "settle",
				"value": "Leif",
				"phrase": "Leif turned the settle",
			},
			{
				"field": "settle_room",
				"value": "nave",
				"phrase": "turned the settle in the nave",
			},
		],
	},
	{
		"id": "E6",
		"title": "Sized slip",
		"source": "Settle tote",
		"text": "The reglet was cut in the nave. The settle was sized at 191, and a pale cochineal still sat on the reglet.",
		"literals": [
			{
				"field": "place",
				"value": "nave",
				"phrase": "The reglet was cut in the nave",
			},
			{
				"field": "size_hour",
				"value": "191",
				"phrase": "The settle was sized at 191",
			},
		],
	},
	{
		"id": "E7",
		"title": "Reglet leaf",
		"source": "Pear book",
		"text": "The reglet was cut at 193. The pear had been marked at 192, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "193",
				"phrase": "The reglet was cut at 193",
			},
			{
				"field": "pear_hour",
				"value": "192",
				"phrase": "The pear had been marked at 192",
			},
		],
	},
	{
		"id": "E8",
		"title": "Jade note",
		"source": "Joiner's jade",
		"text": "The reglet was cut at 193. The pear was opened so the pear would take the reglet.",
		"literals": [
			{
				"field": "hour",
				"value": "193",
				"phrase": "The reglet was cut at 193",
			},
			{
				"field": "aim",
				"value": "take_pear",
				"phrase": "so the pear would take the reglet",
			},
		],
	},
	{
		"id": "E9",
		"title": "Clayed order",
		"source": "Bodkin card",
		"text": "The reglet was cut at 193. The bodkin was clayed at 194, and the nave was hung at 195 once the pear was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "193",
				"phrase": "The reglet was cut at 193",
			},
			{
				"field": "clay_hour",
				"value": "194",
				"phrase": "The bodkin was clayed at 194",
			},
			{
				"field": "hang_hour",
				"value": "195",
				"phrase": "the nave was hung at 195",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"pear",
		"pear_room",
		"pear_hour",
		"seen_from",
		"settle",
		"aim",
		"settle_room",
		"damson_room",
		"size_hour",
		"clay_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "pear", "settle":
			return PEOPLE.duplicate()
		"place", "pear_room", "seen_from", "settle_room", "damson_room":
			return PLACES.duplicate()
		"hour", "pear_hour", "size_hour", "clay_hour", "hang_hour":
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
		missing.append("who cut the reglet")
	if pins["place"] == "":
		missing.append("where they cut the reglet")
	if pins["hour"] == "":
		missing.append("at which hour they cut the reglet")
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
		"Iris":
			return "the reglet hand"
		"Otto":
			return "the pear hand"
		"Leif":
			return "the settle clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"nave":
			return "nave"
		"settle":
			return "settle"
		"bodkin":
			return "bodkin"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"nave":
			return "Nave"
		"settle":
			return "Settle"
		"bodkin":
			return "Bodkin"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the reglet" % value
		"place":
			return "The reglet was cut in the %s" % place_label(value)
		"hour":
			return "The reglet was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the reglet" % value
		"place":
			return "the reglet was cut in the %s" % place_label(value)
		"hour":
			return "the reglet was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the reglet" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_pear":
			return "so the pear would take the reglet"
		"spare_pear":
			return "to spare the pear still waiting on the reglet"
		"set_pear":
			return "to set the pear before the nave was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the reglet in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the pear on the %s at %s." % [
			model["pear"],
			role_short(str(model["pear"])),
			place_label(str(model["pear_room"])),
			model["pear_hour"],
		],
		"%s (%s) turned the settle in the %s." % [
			model["settle"],
			role_short(str(model["settle"])),
			place_label(str(model["settle_room"])),
		],
		"The damson was hung on the %s." % place_label(str(model["damson_room"])),
		"The settle was sized at %s." % model["size_hour"],
		"The bodkin was clayed at %s." % model["clay_hour"],
		"The nave was hung at %s." % model["hang_hour"],
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
	return "Who cut the reglet, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the reglet in."


static func cast_line() -> String:
	return "Iris, reglet hand    Otto, pear hand    Leif, settle clerk"


static func ready_line() -> String:
	return "Pin who cut the reglet, the room they cut it in, and the hour. Then submit."


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
