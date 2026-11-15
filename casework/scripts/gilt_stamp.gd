extends RefCounted

# The gilt stamp.
#
# The player pins three facts about the taking: who, the room the stamp was
# taken to, and the hour. The timeline also records who wrote the move order,
# where that order was written, where the stamp was taken from, why it was
# taken, who signed it back, where it was signed back, when the bench receipt
# was marked, and when the sign-back was logged. Each exhibit states the true
# value of one of those three pins (a value at least one other exhibit also
# states) and at least one fact no other exhibit states. The room is the pin
# three exhibits share. Exactly one full timeline fits every exhibit. Drop
# any exhibit and another timeline fits. Any other pin triple disagrees with
# at least two exhibits.

const TITLE := "The gilt stamp"
const FILE_CODE := "CW-03"
const BLURB := "The gilt stamp left its hook at the bindery. Name who took it, the room they took it to, and the hour."

const PEOPLE: Array[String] = ["Mara", "Theo", "Nessa"]
const PLACES: Array[String] = ["press_room", "finishing_bench", "store_cage"]
const HOURS: Array[String] = ["1", "2", "3"]
const PURPOSES: Array[String] = ["title_edge", "cover_line", "spine_mark"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Move order",
		"source": "Mara, binder",
		"text": "The gilt stamp was taken to the finishing bench. Mara, the binder, is the person who wrote the move order.",
		"literals": [
			{
				"field": "place",
				"value": "finishing_bench",
				"phrase": "The gilt stamp was taken to the finishing bench",
			},
			{
				"field": "orderer",
				"value": "Mara",
				"phrase": "Mara, the binder, is the person who wrote the move order",
			},
		],
	},
	{
		"id": "E2",
		"title": "Press margin",
		"source": "Press room",
		"text": "The gilt stamp was taken to the finishing bench. The move order was written in the press room.",
		"literals": [
			{
				"field": "place",
				"value": "finishing_bench",
				"phrase": "The gilt stamp was taken to the finishing bench",
			},
			{
				"field": "order_place",
				"value": "press_room",
				"phrase": "The move order was written in the press room",
			},
		],
	},
	{
		"id": "E3",
		"title": "Edge note",
		"source": "Finishing bench",
		"text": "The gilt stamp was taken to the finishing bench. The gilt stamp was taken in order to lay the title edge.",
		"literals": [
			{
				"field": "place",
				"value": "finishing_bench",
				"phrase": "The gilt stamp was taken to the finishing bench",
			},
			{
				"field": "purpose",
				"value": "title_edge",
				"phrase": "The gilt stamp was taken in order to lay the title edge",
			},
		],
	},
	{
		"id": "E4",
		"title": "Cage card",
		"source": "Store cage",
		"text": "Nessa, the porter, is the person who took the gilt stamp. The gilt stamp was taken from the store cage.",
		"literals": [
			{
				"field": "taker",
				"value": "Nessa",
				"phrase": "Nessa, the porter, is the person who took the gilt stamp",
			},
			{
				"field": "origin",
				"value": "store_cage",
				"phrase": "The gilt stamp was taken from the store cage",
			},
		],
	},
	{
		"id": "E5",
		"title": "Sign-back line",
		"source": "Theo, gilder",
		"text": "Nessa, the porter, is the person who took the gilt stamp. Theo, the gilder, is the person who signed the stamp back into the store cage.",
		"literals": [
			{
				"field": "taker",
				"value": "Nessa",
				"phrase": "Nessa, the porter, is the person who took the gilt stamp",
			},
			{
				"field": "signer",
				"value": "Theo",
				"phrase": "Theo, the gilder, is the person who signed the stamp back into the store cage",
			},
			{
				"field": "return_place",
				"value": "store_cage",
				"phrase": "Theo, the gilder, is the person who signed the stamp back into the store cage",
			},
		],
	},
	{
		"id": "E6",
		"title": "Bench receipt",
		"source": "Finishing bench book",
		"text": "1 is the hour at which the gilt stamp was taken. 2 is the hour at which the bench receipt was marked.",
		"literals": [
			{
				"field": "hour",
				"value": "1",
				"phrase": "1 is the hour at which the gilt stamp was taken",
			},
			{
				"field": "receipt_hour",
				"value": "2",
				"phrase": "2 is the hour at which the bench receipt was marked",
			},
		],
	},
	{
		"id": "E7",
		"title": "Cage return",
		"source": "Store cage book",
		"text": "1 is the hour at which the gilt stamp was taken. 3 is the hour at which the stamp was signed back.",
		"literals": [
			{
				"field": "hour",
				"value": "1",
				"phrase": "1 is the hour at which the gilt stamp was taken",
			},
			{
				"field": "return_hour",
				"value": "3",
				"phrase": "3 is the hour at which the stamp was signed back",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"orderer",
		"order_place",
		"signer",
		"return_place",
		"return_hour",
		"origin",
		"purpose",
		"receipt_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "orderer", "signer":
			return PEOPLE.duplicate()
		"place", "order_place", "return_place", "origin":
			return PLACES.duplicate()
		"hour", "return_hour", "receipt_hour":
			return HOURS.duplicate()
		"purpose":
			return PURPOSES.duplicate()
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
		missing.append("who took the gilt stamp")
	if pins["place"] == "":
		missing.append("where they took the stamp")
	if pins["hour"] == "":
		missing.append("at which hour they took the stamp")
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
		"Mara":
			return "the binder"
		"Theo":
			return "the gilder"
		"Nessa":
			return "the porter"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"press_room":
			return "press room"
		"finishing_bench":
			return "finishing bench"
		"store_cage":
			return "store cage"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"press_room":
			return "Press room"
		"finishing_bench":
			return "Finishing bench"
		"store_cage":
			return "Store cage"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s, %s, is the person who took the gilt stamp" % [value, role_phrase(value)]
		"place":
			return "The gilt stamp was taken to the %s" % place_label(value)
		"hour":
			return "%s is the hour at which the gilt stamp was taken" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s took the gilt stamp" % value
		"place":
			return "the gilt stamp was taken to the %s" % place_label(value)
		"hour":
			return "the gilt stamp was taken at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s took the gilt stamp" % value
		"place":
			return "it was taken to the %s" % place_label(value)
		"hour":
			return "it was taken at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"title_edge":
			return "to lay the title edge"
		"cover_line":
			return "to rule the cover line"
		"spine_mark":
			return "to mark the spine"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) took the gilt stamp at %s from the %s to the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			model["hour"],
			place_label(str(model["origin"])),
			place_label(str(model["place"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) wrote the move order in the %s." % [
			model["orderer"],
			role_short(str(model["orderer"])),
			place_label(str(model["order_place"])),
		],
		"%s (%s) signed the stamp back at %s into the %s." % [
			model["signer"],
			role_short(str(model["signer"])),
			model["return_hour"],
			place_label(str(model["return_place"])),
		],
		"The bench receipt was marked at %s." % model["receipt_hour"],
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
	return "The file  ·  seven exhibits"


static func board_question() -> String:
	return "Who took the gilt stamp, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they took the stamp to."


static func cast_line() -> String:
	return "Mara, binder    Theo, gilder    Nessa, porter"


static func ready_line() -> String:
	return "Pin who took the gilt stamp, the room they took it to, and the hour. Then submit."


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
