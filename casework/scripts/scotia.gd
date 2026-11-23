extends RefCounted

# The scotia.
#
# The player pins three facts about the cutting: who, the room the scotia was
# cut in, and the hour. The timeline also records who marked the torus, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the riffler, where that turn was made, why the scotia was cut, where
# the fascia was hung, when the riffler was pumiced, when the scorp was peened, and
# when the hollow was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The scotia"
const FILE_CODE := "CW-41"
const BLURB := "The scotia left its peg at the joiner's yearling. Name who cut the scotia, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Willa", "Nils", "Cora"]
const PLACES: Array[String] = ["hollow", "riffler", "scorp"]
const HOURS: Array[String] = ["146", "147", "148", "149", "150"]
const AIMS: Array[String] = ["take_torus", "spare_torus", "set_torus"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Torus chit",
		"source": "Nils, torus hand",
		"text": "Willa cut the scotia. Nils had marked the torus, and a pale whiting still clung to the scotia.",
		"literals": [
			{
				"field": "taker",
				"value": "Willa",
				"phrase": "Willa cut the scotia",
			},
			{
				"field": "torus",
				"value": "Nils",
				"phrase": "Nils had marked the torus",
			},
		],
	},
	{
		"id": "E2",
		"title": "Cusp sight",
		"source": "Riffler cusp",
		"text": "Willa cut the scotia. The scotiaing was seen from the riffler, beside the open torus.",
		"literals": [
			{
				"field": "taker",
				"value": "Willa",
				"phrase": "Willa cut the scotia",
			},
			{
				"field": "seen_from",
				"value": "riffler",
				"phrase": "The scotiaing was seen from the riffler",
			},
		],
	},
	{
		"id": "E3",
		"title": "Fascia bill",
		"source": "Scorp nose",
		"text": "Willa cut the scotia. With the torus true, the fascia was hung on the scorp.",
		"literals": [
			{
				"field": "taker",
				"value": "Willa",
				"phrase": "Willa cut the scotia",
			},
			{
				"field": "fascia_room",
				"value": "scorp",
				"phrase": "the fascia was hung on the scorp",
			},
		],
	},
	{
		"id": "E4",
		"title": "Soot slate",
		"source": "Hollow soot",
		"text": "The scotia was cut in the hollow. A fresh soot shows the torus had been marked on the scorp.",
		"literals": [
			{
				"field": "place",
				"value": "hollow",
				"phrase": "The scotia was cut in the hollow",
			},
			{
				"field": "torus_room",
				"value": "scorp",
				"phrase": "the torus had been marked on the scorp",
			},
		],
	},
	{
		"id": "E5",
		"title": "Riffler card",
		"source": "Cora, riffler clerk",
		"text": "The scotia was cut in the hollow. Cora turned the riffler in the hollow once the torus was offered.",
		"literals": [
			{
				"field": "place",
				"value": "hollow",
				"phrase": "The scotia was cut in the hollow",
			},
			{
				"field": "riffler",
				"value": "Cora",
				"phrase": "Cora turned the riffler",
			},
			{
				"field": "riffler_room",
				"value": "hollow",
				"phrase": "turned the riffler in the hollow",
			},
		],
	},
	{
		"id": "E6",
		"title": "Pumice slip",
		"source": "Riffler tote",
		"text": "The scotia was cut in the hollow. The riffler was pumiced at 146, and a pale crocus still sat on the scotia.",
		"literals": [
			{
				"field": "place",
				"value": "hollow",
				"phrase": "The scotia was cut in the hollow",
			},
			{
				"field": "pumice_hour",
				"value": "146",
				"phrase": "The riffler was pumiced at 146",
			},
		],
	},
	{
		"id": "E7",
		"title": "Scotia leaf",
		"source": "Torus book",
		"text": "The scotia was cut at 148. The torus had been marked at 147, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "148",
				"phrase": "The scotia was cut at 148",
			},
			{
				"field": "torus_hour",
				"value": "147",
				"phrase": "The torus had been marked at 147",
			},
		],
	},
	{
		"id": "E8",
		"title": "Yearling note",
		"source": "Joiner's yearling",
		"text": "The scotia was cut at 148. The torus was opened so the torus would take the scotia.",
		"literals": [
			{
				"field": "hour",
				"value": "148",
				"phrase": "The scotia was cut at 148",
			},
			{
				"field": "aim",
				"value": "take_torus",
				"phrase": "so the torus would take the scotia",
			},
		],
	},
	{
		"id": "E9",
		"title": "Peen order",
		"source": "Scorp card",
		"text": "The scotia was cut at 148. The scorp was peened at 149, and the hollow was hung at 150 once the torus was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "148",
				"phrase": "The scotia was cut at 148",
			},
			{
				"field": "peen_hour",
				"value": "149",
				"phrase": "The scorp was peened at 149",
			},
			{
				"field": "hang_hour",
				"value": "150",
				"phrase": "the hollow was hung at 150",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"torus",
		"torus_room",
		"torus_hour",
		"seen_from",
		"riffler",
		"aim",
		"riffler_room",
		"fascia_room",
		"pumice_hour",
		"peen_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "torus", "riffler":
			return PEOPLE.duplicate()
		"place", "torus_room", "seen_from", "riffler_room", "fascia_room":
			return PLACES.duplicate()
		"hour", "torus_hour", "pumice_hour", "peen_hour", "hang_hour":
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
		missing.append("who cut the scotia")
	if pins["place"] == "":
		missing.append("where they cut the scotia")
	if pins["hour"] == "":
		missing.append("at which hour they cut the scotia")
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
		"Willa":
			return "the scotia hand"
		"Nils":
			return "the torus hand"
		"Cora":
			return "the riffler clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"hollow":
			return "hollow"
		"riffler":
			return "riffler"
		"scorp":
			return "scorp"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"hollow":
			return "Hollow"
		"riffler":
			return "Riffler"
		"scorp":
			return "Scorp"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the scotia" % value
		"place":
			return "The scotia was cut in the %s" % place_label(value)
		"hour":
			return "The scotia was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the scotia" % value
		"place":
			return "the scotia was cut in the %s" % place_label(value)
		"hour":
			return "the scotia was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the scotia" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_torus":
			return "so the torus would take the scotia"
		"spare_torus":
			return "to spare the torus still waiting on the scotia"
		"set_torus":
			return "to set the torus before the hollow was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the scotia in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the torus on the %s at %s." % [
			model["torus"],
			role_short(str(model["torus"])),
			place_label(str(model["torus_room"])),
			model["torus_hour"],
		],
		"%s (%s) turned the riffler in the %s." % [
			model["riffler"],
			role_short(str(model["riffler"])),
			place_label(str(model["riffler_room"])),
		],
		"The fascia was hung on the %s." % place_label(str(model["fascia_room"])),
		"The riffler was pumiced at %s." % model["pumice_hour"],
		"The scorp was peened at %s." % model["peen_hour"],
		"The hollow was hung at %s." % model["hang_hour"],
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
	return "Who cut the scotia, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the scotia in."


static func cast_line() -> String:
	return "Willa, scotia hand    Nils, torus hand    Cora, riffler clerk"


static func ready_line() -> String:
	return "Pin who cut the scotia, the room they cut it in, and the hour. Then submit."


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
