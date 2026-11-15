extends RefCounted

# The mortise.
#
# The player pins three facts about the cutting: who, the room the mortise was
# cut in, and the hour. The timeline also records who bored the hole, where
# it was bored, when that boring was done, where the cutting was seen from, who
# turned the brace, where that turn was made, why the mortise was cut, where
# the wedge was hung, when the awl was brushed, when the last was ragged, and
# when the chisel was racked. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The mortise"
const FILE_CODE := "CW-25"
const BLURB := "The mortise left its peg at the joiner's rack. Name who cut the mortise, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Arlo", "Keel", "Weske"]
const PLACES: Array[String] = ["chisel", "last", "awl"]
const HOURS: Array[String] = ["66", "67", "68", "69", "70"]
const ENDS: Array[String] = ["take_tenon", "spare_tenon", "set_tenon"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Chisel chit",
		"source": "Keel, awl hand",
		"text": "Arlo cut the mortise. Keel had bored the hole, and the pale chips still clung to the bit.",
		"literals": [
			{
				"field": "taker",
				"value": "Arlo",
				"phrase": "Arlo cut the mortise",
			},
			{
				"field": "borer",
				"value": "Keel",
				"phrase": "Keel had bored the hole",
			},
		],
	},
	{
		"id": "E2",
		"title": "Awl sight",
		"source": "Awl rail",
		"text": "Arlo cut the mortise. The cutting was seen from the awl, above the bit rack.",
		"literals": [
			{
				"field": "taker",
				"value": "Arlo",
				"phrase": "Arlo cut the mortise",
			},
			{
				"field": "sight_from",
				"value": "awl",
				"phrase": "The cutting was seen from the awl",
			},
		],
	},
	{
		"id": "E3",
		"title": "Wedge hook",
		"source": "Last peg",
		"text": "Arlo cut the mortise. With the cheeks true, the wedge was hung on the last.",
		"literals": [
			{
				"field": "taker",
				"value": "Arlo",
				"phrase": "Arlo cut the mortise",
			},
			{
				"field": "wedge_room",
				"value": "last",
				"phrase": "the wedge was hung on the last",
			},
		],
	},
	{
		"id": "E4",
		"title": "Tenon slate",
		"source": "Chisel jaw",
		"text": "The mortise was cut in the chisel. The cheek still shows the hole had been bored on the last.",
		"literals": [
			{
				"field": "place",
				"value": "chisel",
				"phrase": "The mortise was cut in the chisel",
			},
			{
				"field": "bore_room",
				"value": "last",
				"phrase": "the hole had been bored on the last",
			},
		],
	},
	{
		"id": "E5",
		"title": "Brace card",
		"source": "Weske, last clerk",
		"text": "The mortise was cut in the chisel. Weske turned the brace in the awl before the tenon was offered.",
		"literals": [
			{
				"field": "place",
				"value": "chisel",
				"phrase": "The mortise was cut in the chisel",
			},
			{
				"field": "brace",
				"value": "Weske",
				"phrase": "Weske turned the brace",
			},
			{
				"field": "brace_room",
				"value": "awl",
				"phrase": "turned the brace in the awl",
			},
		],
	},
	{
		"id": "E6",
		"title": "Brush slip",
		"source": "Awl book",
		"text": "The mortise was cut in the chisel. The awl was brushed at 66, and dust still lay along the sill.",
		"literals": [
			{
				"field": "place",
				"value": "chisel",
				"phrase": "The mortise was cut in the chisel",
			},
			{
				"field": "brush_hour",
				"value": "66",
				"phrase": "The awl was brushed at 66",
			},
		],
	},
	{
		"id": "E7",
		"title": "Bore leaf",
		"source": "Bore book",
		"text": "The mortise was cut at 68. The hole had been bored at 67, and the bit still carried that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "68",
				"phrase": "The mortise was cut at 68",
			},
			{
				"field": "bore_hour",
				"value": "67",
				"phrase": "The hole had been bored at 67",
			},
		],
	},
	{
		"id": "E8",
		"title": "Tenon note",
		"source": "Joiner's rack",
		"text": "The mortise was cut at 68. The cheeks were opened so the last would take the tenon.",
		"literals": [
			{
				"field": "hour",
				"value": "68",
				"phrase": "The mortise was cut at 68",
			},
			{
				"field": "end",
				"value": "take_tenon",
				"phrase": "so the last would take the tenon",
			},
		],
	},
	{
		"id": "E9",
		"title": "Rack order",
		"source": "Last slate",
		"text": "The mortise was cut at 68. The last was ragged at 69, and the chisel was racked at 70 once the cheeks were dry.",
		"literals": [
			{
				"field": "hour",
				"value": "68",
				"phrase": "The mortise was cut at 68",
			},
			{
				"field": "rag_hour",
				"value": "69",
				"phrase": "The last was ragged at 69",
			},
			{
				"field": "rack_hour",
				"value": "70",
				"phrase": "the chisel was racked at 70",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"borer",
		"bore_room",
		"bore_hour",
		"sight_from",
		"brace",
		"end",
		"brace_room",
		"wedge_room",
		"brush_hour",
		"rag_hour",
		"rack_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "borer", "brace":
			return PEOPLE.duplicate()
		"place", "bore_room", "sight_from", "brace_room", "wedge_room":
			return PLACES.duplicate()
		"hour", "bore_hour", "brush_hour", "rag_hour", "rack_hour":
			return HOURS.duplicate()
		"end":
			return ENDS.duplicate()
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
		missing.append("who cut the mortise")
	if pins["place"] == "":
		missing.append("where they cut the mortise")
	if pins["hour"] == "":
		missing.append("at which hour they cut the mortise")
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
		"Arlo":
			return "the chisel hand"
		"Keel":
			return "the awl hand"
		"Weske":
			return "the last clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"chisel":
			return "chisel"
		"last":
			return "last"
		"awl":
			return "awl"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"chisel":
			return "Chisel"
		"last":
			return "Last"
		"awl":
			return "Awl"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the mortise" % value
		"place":
			return "The mortise was cut in the %s" % place_label(value)
		"hour":
			return "The mortise was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the mortise" % value
		"place":
			return "the mortise was cut in the %s" % place_label(value)
		"hour":
			return "the mortise was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the mortise" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func end_phrase(aim: String) -> String:
	match aim:
		"take_tenon":
			return "so the last would take the tenon"
		"spare_tenon":
			return "to spare the tenon still waiting on the last"
		"set_tenon":
			return "to set the tenon before the chisel was racked"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the mortise in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["sight_from"])),
			end_phrase(str(model["end"])),
		],
		"%s (%s) bored the hole on the %s at %s." % [
			model["borer"],
			role_short(str(model["borer"])),
			place_label(str(model["bore_room"])),
			model["bore_hour"],
		],
		"%s (%s) turned the brace in the %s." % [
			model["brace"],
			role_short(str(model["brace"])),
			place_label(str(model["brace_room"])),
		],
		"The wedge was hung on the %s." % place_label(str(model["wedge_room"])),
		"The awl was brushed at %s." % model["brush_hour"],
		"The last was ragged at %s." % model["rag_hour"],
		"The chisel was racked at %s." % model["rack_hour"],
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
	return "Who cut the mortise, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the mortise in."


static func cast_line() -> String:
	return "Arlo, chisel hand    Keel, awl hand    Weske, last clerk"


static func ready_line() -> String:
	return "Pin who cut the mortise, the room they cut it in, and the hour. Then submit."


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
