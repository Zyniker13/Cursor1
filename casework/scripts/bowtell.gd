extends RefCounted

# The bowtell.
#
# The player pins three facts about the cutting: who, the room the bowtell was
# cut in, and the hour. The timeline also records who marked the myrtle, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the locutory, where that turn was made, why the bowtell was cut, where
# the osage was hung, when the locutory was ylanged, when the ryoba was vetivered, and
# when the chevet was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The bowtell"
const FILE_CODE := "CW-62"
const BLURB := "The bowtell left its peg at the joiner's sling. Name who cut the bowtell, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Siward", "Gytha", "Ealdred"]
const PLACES: Array[String] = ["chevet", "locutory", "ryoba"]
const HOURS: Array[String] = ["251", "252", "253", "254", "255"]
const AIMS: Array[String] = ["take_myrtle", "spare_myrtle", "set_myrtle"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Myrtle chit",
		"source": "Gytha, myrtle hand",
		"text": "Siward cut the bowtell. Gytha had marked the myrtle, and a pale isatin still clung to the bowtell.",
		"literals": [
			{
				"field": "taker",
				"value": "Siward",
				"phrase": "Siward cut the bowtell",
			},
			{
				"field": "myrtle",
				"value": "Gytha",
				"phrase": "Gytha had marked the myrtle",
			},
		],
	},
	{
		"id": "E2",
		"title": "Carmine sight",
		"source": "Locutory carmine",
		"text": "Siward cut the bowtell. The bowtelling was seen from the locutory, beside the open myrtle.",
		"literals": [
			{
				"field": "taker",
				"value": "Siward",
				"phrase": "Siward cut the bowtell",
			},
			{
				"field": "seen_from",
				"value": "locutory",
				"phrase": "The bowtelling was seen from the locutory",
			},
		],
	},
	{
		"id": "E3",
		"title": "Osage bill",
		"source": "Ryoba nose",
		"text": "Siward cut the bowtell. With the myrtle true, the osage was hung on the ryoba.",
		"literals": [
			{
				"field": "taker",
				"value": "Siward",
				"phrase": "Siward cut the bowtell",
			},
			{
				"field": "osage_room",
				"value": "ryoba",
				"phrase": "the osage was hung on the ryoba",
			},
		],
	},
	{
		"id": "E4",
		"title": "Azurite slate",
		"source": "Chevet azurite",
		"text": "The bowtell was cut in the chevet. A fresh azurite shows the myrtle had been marked on the ryoba.",
		"literals": [
			{
				"field": "place",
				"value": "chevet",
				"phrase": "The bowtell was cut in the chevet",
			},
			{
				"field": "myrtle_room",
				"value": "ryoba",
				"phrase": "the myrtle had been marked on the ryoba",
			},
		],
	},
	{
		"id": "E5",
		"title": "Locutory card",
		"source": "Ealdred, locutory clerk",
		"text": "The bowtell was cut in the chevet. Ealdred turned the locutory in the chevet once the myrtle was offered.",
		"literals": [
			{
				"field": "place",
				"value": "chevet",
				"phrase": "The bowtell was cut in the chevet",
			},
			{
				"field": "locutory",
				"value": "Ealdred",
				"phrase": "Ealdred turned the locutory",
			},
			{
				"field": "locutory_room",
				"value": "chevet",
				"phrase": "turned the locutory in the chevet",
			},
		],
	},
	{
		"id": "E6",
		"title": "Ylanged slip",
		"source": "Locutory tote",
		"text": "The bowtell was cut in the chevet. The locutory was ylanged at 251, and a pale malachite still sat on the bowtell.",
		"literals": [
			{
				"field": "place",
				"value": "chevet",
				"phrase": "The bowtell was cut in the chevet",
			},
			{
				"field": "ylang_hour",
				"value": "251",
				"phrase": "The locutory was ylanged at 251",
			},
		],
	},
	{
		"id": "E7",
		"title": "Bowtell leaf",
		"source": "Myrtle book",
		"text": "The bowtell was cut at 253. The myrtle had been marked at 252, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "253",
				"phrase": "The bowtell was cut at 253",
			},
			{
				"field": "myrtle_hour",
				"value": "252",
				"phrase": "The myrtle had been marked at 252",
			},
		],
	},
	{
		"id": "E8",
		"title": "Sling note",
		"source": "Joiner's sling",
		"text": "The bowtell was cut at 253. The myrtle was opened so the myrtle would take the bowtell.",
		"literals": [
			{
				"field": "hour",
				"value": "253",
				"phrase": "The bowtell was cut at 253",
			},
			{
				"field": "aim",
				"value": "take_myrtle",
				"phrase": "so the myrtle would take the bowtell",
			},
		],
	},
	{
		"id": "E9",
		"title": "Vetivered order",
		"source": "Ryoba card",
		"text": "The bowtell was cut at 253. The ryoba was vetivered at 254, and the chevet was hung at 255 once the myrtle was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "253",
				"phrase": "The bowtell was cut at 253",
			},
			{
				"field": "vetiver_hour",
				"value": "254",
				"phrase": "The ryoba was vetivered at 254",
			},
			{
				"field": "hang_hour",
				"value": "255",
				"phrase": "the chevet was hung at 255",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"myrtle",
		"myrtle_room",
		"myrtle_hour",
		"seen_from",
		"locutory",
		"aim",
		"locutory_room",
		"osage_room",
		"ylang_hour",
		"vetiver_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "myrtle", "locutory":
			return PEOPLE.duplicate()
		"place", "myrtle_room", "seen_from", "locutory_room", "osage_room":
			return PLACES.duplicate()
		"hour", "myrtle_hour", "ylang_hour", "vetiver_hour", "hang_hour":
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
		missing.append("who cut the bowtell")
	if pins["place"] == "":
		missing.append("where they cut the bowtell")
	if pins["hour"] == "":
		missing.append("at which hour they cut the bowtell")
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
		"Siward":
			return "the bowtell hand"
		"Gytha":
			return "the myrtle hand"
		"Ealdred":
			return "the locutory clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"chevet":
			return "chevet"
		"locutory":
			return "locutory"
		"ryoba":
			return "ryoba"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"chevet":
			return "Chevet"
		"locutory":
			return "Locutory"
		"ryoba":
			return "Ryoba"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the bowtell" % value
		"place":
			return "The bowtell was cut in the %s" % place_label(value)
		"hour":
			return "The bowtell was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the bowtell" % value
		"place":
			return "the bowtell was cut in the %s" % place_label(value)
		"hour":
			return "the bowtell was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the bowtell" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_myrtle":
			return "so the myrtle would take the bowtell"
		"spare_myrtle":
			return "to spare the myrtle still waiting on the bowtell"
		"set_myrtle":
			return "to set the myrtle before the chevet was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the bowtell in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the myrtle on the %s at %s." % [
			model["myrtle"],
			role_short(str(model["myrtle"])),
			place_label(str(model["myrtle_room"])),
			model["myrtle_hour"],
		],
		"%s (%s) turned the locutory in the %s." % [
			model["locutory"],
			role_short(str(model["locutory"])),
			place_label(str(model["locutory_room"])),
		],
		"The osage was hung on the %s." % place_label(str(model["osage_room"])),
		"The locutory was ylanged at %s." % model["ylang_hour"],
		"The ryoba was vetivered at %s." % model["vetiver_hour"],
		"The chevet was hung at %s." % model["hang_hour"],
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
	return "Who cut the bowtell, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the bowtell in."


static func cast_line() -> String:
	return "Siward, bowtell hand    Gytha, myrtle hand    Ealdred, locutory clerk"


static func ready_line() -> String:
	return "Pin who cut the bowtell, the room they cut it in, and the hour. Then submit."


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
