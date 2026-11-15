extends RefCounted

# The finger.
#
# The player pins three facts about the cutting: who, the room the finger was
# cut in, and the hour. The timeline also records who marked the socket, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the catch, where that turn was made, why the finger was cut, where
# the chip was hung, when the badger was buffed, when the jack was rubbed, and
# when the pad was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The finger"
const FILE_CODE := "CW-35"
const BLURB := "The finger left its peg at the joiner's pony. Name who cut the finger, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Clem", "Gale", "Boyd"]
const PLACES: Array[String] = ["pad", "badger", "jack"]
const HOURS: Array[String] = ["116", "117", "118", "119", "120"]
const AIMS: Array[String] = ["take_socket", "spare_socket", "set_socket"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Socket chit",
		"source": "Gale, socket hand",
		"text": "Clem cut the finger. Gale had marked the socket, and a pale flake still clung to the burr.",
		"literals": [
			{
				"field": "taker",
				"value": "Clem",
				"phrase": "Clem cut the finger",
			},
			{
				"field": "socket",
				"value": "Gale",
				"phrase": "Gale had marked the socket",
			},
		],
	},
	{
		"id": "E2",
		"title": "Burr sight",
		"source": "Badger burr",
		"text": "Clem cut the finger. The cutting was seen from the badger, beside the open burr.",
		"literals": [
			{
				"field": "taker",
				"value": "Clem",
				"phrase": "Clem cut the finger",
			},
			{
				"field": "seen_from",
				"value": "badger",
				"phrase": "The cutting was seen from the badger",
			},
		],
	},
	{
		"id": "E3",
		"title": "Chip bill",
		"source": "Jack nose",
		"text": "Clem cut the finger. With the socket true, the chip was hung on the jack.",
		"literals": [
			{
				"field": "taker",
				"value": "Clem",
				"phrase": "Clem cut the finger",
			},
			{
				"field": "chip_room",
				"value": "jack",
				"phrase": "the chip was hung on the jack",
			},
		],
	},
	{
		"id": "E4",
		"title": "Face slate",
		"source": "Pad face",
		"text": "The finger was cut in the pad. A fresh face shows the socket had been marked on the jack.",
		"literals": [
			{
				"field": "place",
				"value": "pad",
				"phrase": "The finger was cut in the pad",
			},
			{
				"field": "socket_room",
				"value": "jack",
				"phrase": "the socket had been marked on the jack",
			},
		],
	},
	{
		"id": "E5",
		"title": "Catch card",
		"source": "Boyd, catch clerk",
		"text": "The finger was cut in the pad. Boyd turned the catch in the badger before the socket was offered.",
		"literals": [
			{
				"field": "place",
				"value": "pad",
				"phrase": "The finger was cut in the pad",
			},
			{
				"field": "catch",
				"value": "Boyd",
				"phrase": "Boyd turned the catch",
			},
			{
				"field": "catch_room",
				"value": "badger",
				"phrase": "turned the catch in the badger",
			},
		],
	},
	{
		"id": "E6",
		"title": "Sheen slip",
		"source": "Badger tote",
		"text": "The finger was cut in the pad. The badger was buffed at 116, and a pale sheen still sat on the burr.",
		"literals": [
			{
				"field": "place",
				"value": "pad",
				"phrase": "The finger was cut in the pad",
			},
			{
				"field": "buff_hour",
				"value": "116",
				"phrase": "The badger was buffed at 116",
			},
		],
	},
	{
		"id": "E7",
		"title": "Finger leaf",
		"source": "Socket book",
		"text": "The finger was cut at 118. The socket had been marked at 117, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "118",
				"phrase": "The finger was cut at 118",
			},
			{
				"field": "socket_hour",
				"value": "117",
				"phrase": "The socket had been marked at 117",
			},
		],
	},
	{
		"id": "E8",
		"title": "Finger note",
		"source": "Joiner's pony",
		"text": "The finger was cut at 118. The socket was opened so the socket would take the finger.",
		"literals": [
			{
				"field": "hour",
				"value": "118",
				"phrase": "The finger was cut at 118",
			},
			{
				"field": "aim",
				"value": "take_socket",
				"phrase": "so the socket would take the finger",
			},
		],
	},
	{
		"id": "E9",
		"title": "Rub order",
		"source": "Jack card",
		"text": "The finger was cut at 118. The jack was rubbed at 119, and the pad was hung at 120 once the socket was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "118",
				"phrase": "The finger was cut at 118",
			},
			{
				"field": "rub_hour",
				"value": "119",
				"phrase": "The jack was rubbed at 119",
			},
			{
				"field": "hang_hour",
				"value": "120",
				"phrase": "the pad was hung at 120",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"socket",
		"socket_room",
		"socket_hour",
		"seen_from",
		"catch",
		"aim",
		"catch_room",
		"chip_room",
		"buff_hour",
		"rub_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "socket", "catch":
			return PEOPLE.duplicate()
		"place", "socket_room", "seen_from", "catch_room", "chip_room":
			return PLACES.duplicate()
		"hour", "socket_hour", "buff_hour", "rub_hour", "hang_hour":
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
		missing.append("who cut the finger")
	if pins["place"] == "":
		missing.append("where they cut the finger")
	if pins["hour"] == "":
		missing.append("at which hour they cut the finger")
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
		"Clem":
			return "the finger hand"
		"Gale":
			return "the socket hand"
		"Boyd":
			return "the catch clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"pad":
			return "pad"
		"badger":
			return "badger"
		"jack":
			return "jack"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"pad":
			return "Pad"
		"badger":
			return "Badger"
		"jack":
			return "Jack"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the finger" % value
		"place":
			return "The finger was cut in the %s" % place_label(value)
		"hour":
			return "The finger was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the finger" % value
		"place":
			return "the finger was cut in the %s" % place_label(value)
		"hour":
			return "the finger was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the finger" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_socket":
			return "so the socket would take the finger"
		"spare_socket":
			return "to spare the socket still waiting on the finger"
		"set_socket":
			return "to set the socket before the pad was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the finger in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the socket on the %s at %s." % [
			model["socket"],
			role_short(str(model["socket"])),
			place_label(str(model["socket_room"])),
			model["socket_hour"],
		],
		"%s (%s) turned the catch in the %s." % [
			model["catch"],
			role_short(str(model["catch"])),
			place_label(str(model["catch_room"])),
		],
		"The chip was hung on the %s." % place_label(str(model["chip_room"])),
		"The badger was buffed at %s." % model["buff_hour"],
		"The jack was rubbed at %s." % model["rub_hour"],
		"The pad was hung at %s." % model["hang_hour"],
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
	return "Who cut the finger, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the finger in."


static func cast_line() -> String:
	return "Clem, finger hand    Gale, socket hand    Boyd, catch clerk"


static func ready_line() -> String:
	return "Pin who cut the finger, the room they cut it in, and the hour. Then submit."


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
