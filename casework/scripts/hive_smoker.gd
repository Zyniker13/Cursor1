extends RefCounted

# The hive smoker.
#
# The player pins three facts about the taking: who, the room the smoker was
# taken to, and the hour. The timeline also records who filled the fuel tin,
# where that tin was filled, who logged the sting book, where and at which
# hour it was logged, where the smoker was taken from, why it was taken, when
# the fuel was spent, and when the veil was mended. The taker and the room are
# each stated by three exhibits. The hour is stated by two. Four hours are on
# the board, and every one of them is used: the sting book is logged at 21,
# the smoker is taken at 22, the fuel is spent at 23, and the veil is mended
# at 24. The closing line states two of those hidden facts. Each exhibit states
# one of the three pins (a value at least one other exhibit also states) and at
# least one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The hive smoker"
const FILE_CODE := "CW-07"
const BLURB := "The hive smoker left its shelf at the hive shed. Name who took it, the room they took it to, and the hour."

const PEOPLE: Array[String] = ["Isla", "Tamsin", "Ned"]
const PLACES: Array[String] = ["hive_shed", "veil_loft", "honey_room"]
const HOURS: Array[String] = ["21", "22", "23", "24"]
const PURPOSES: Array[String] = ["quiet_swarm", "shift_frames", "dry_gloves"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Fuel line",
		"source": "Ned, skep hand",
		"text": "Tamsin, the night beekeeper, is the person who took the hive smoker. Ned, the skep hand, is the person who filled the fuel tin.",
		"literals": [
			{
				"field": "taker",
				"value": "Tamsin",
				"phrase": "Tamsin, the night beekeeper, is the person who took the hive smoker",
			},
			{
				"field": "filler",
				"value": "Ned",
				"phrase": "Ned, the skep hand, is the person who filled the fuel tin",
			},
		],
	},
	{
		"id": "E2",
		"title": "Shed tag",
		"source": "Hive shed",
		"text": "Tamsin, the night beekeeper, is the person who took the hive smoker. The hive smoker was taken from the hive shed.",
		"literals": [
			{
				"field": "taker",
				"value": "Tamsin",
				"phrase": "Tamsin, the night beekeeper, is the person who took the hive smoker",
			},
			{
				"field": "origin",
				"value": "hive_shed",
				"phrase": "The hive smoker was taken from the hive shed",
			},
		],
	},
	{
		"id": "E3",
		"title": "Swarm note",
		"source": "Honey room",
		"text": "Tamsin, the night beekeeper, is the person who took the hive smoker. The hive smoker was taken in order to quiet the late swarm.",
		"literals": [
			{
				"field": "taker",
				"value": "Tamsin",
				"phrase": "Tamsin, the night beekeeper, is the person who took the hive smoker",
			},
			{
				"field": "purpose",
				"value": "quiet_swarm",
				"phrase": "The hive smoker was taken in order to quiet the late swarm",
			},
		],
	},
	{
		"id": "E4",
		"title": "Veil card",
		"source": "Veil loft",
		"text": "The hive smoker was taken to the honey room. The fuel tin was filled in the veil loft.",
		"literals": [
			{
				"field": "place",
				"value": "honey_room",
				"phrase": "The hive smoker was taken to the honey room",
			},
			{
				"field": "fill_place",
				"value": "veil_loft",
				"phrase": "The fuel tin was filled in the veil loft",
			},
		],
	},
	{
		"id": "E5",
		"title": "Sting entry",
		"source": "Isla, veil mender",
		"text": "The hive smoker was taken to the honey room. Isla, the veil mender, is the person who logged the sting book.",
		"literals": [
			{
				"field": "place",
				"value": "honey_room",
				"phrase": "The hive smoker was taken to the honey room",
			},
			{
				"field": "logger",
				"value": "Isla",
				"phrase": "Isla, the veil mender, is the person who logged the sting book",
			},
		],
	},
	{
		"id": "E6",
		"title": "Honey margin",
		"source": "Honey room book",
		"text": "The hive smoker was taken to the honey room. The sting book was logged in the honey room.",
		"literals": [
			{
				"field": "place",
				"value": "honey_room",
				"phrase": "The hive smoker was taken to the honey room",
			},
			{
				"field": "log_place",
				"value": "honey_room",
				"phrase": "The sting book was logged in the honey room",
			},
		],
	},
	{
		"id": "E7",
		"title": "Log chit",
		"source": "Sting book",
		"text": "22 is the hour at which the hive smoker was taken. 21 is the hour at which the sting book was logged.",
		"literals": [
			{
				"field": "hour",
				"value": "22",
				"phrase": "22 is the hour at which the hive smoker was taken",
			},
			{
				"field": "log_hour",
				"value": "21",
				"phrase": "21 is the hour at which the sting book was logged",
			},
		],
	},
	{
		"id": "E8",
		"title": "Closing line",
		"source": "Hive shed book",
		"text": "22 is the hour at which the hive smoker was taken. The fuel was spent at 23, and the veil was mended at 24.",
		"literals": [
			{
				"field": "hour",
				"value": "22",
				"phrase": "22 is the hour at which the hive smoker was taken",
			},
			{
				"field": "spent_hour",
				"value": "23",
				"phrase": "The fuel was spent at 23",
			},
			{
				"field": "veil_hour",
				"value": "24",
				"phrase": "the veil was mended at 24",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"filler",
		"fill_place",
		"logger",
		"log_place",
		"log_hour",
		"origin",
		"purpose",
		"spent_hour",
		"veil_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "filler", "logger":
			return PEOPLE.duplicate()
		"place", "fill_place", "log_place", "origin":
			return PLACES.duplicate()
		"hour", "log_hour", "spent_hour", "veil_hour":
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
		missing.append("who took the hive smoker")
	if pins["place"] == "":
		missing.append("where they took the smoker")
	if pins["hour"] == "":
		missing.append("at which hour they took the smoker")
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
		"Isla":
			return "the veil mender"
		"Tamsin":
			return "the night beekeeper"
		"Ned":
			return "the skep hand"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"hive_shed":
			return "hive shed"
		"veil_loft":
			return "veil loft"
		"honey_room":
			return "honey room"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"hive_shed":
			return "Hive shed"
		"veil_loft":
			return "Veil loft"
		"honey_room":
			return "Honey room"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s, %s, is the person who took the hive smoker" % [value, role_phrase(value)]
		"place":
			return "The hive smoker was taken to the %s" % place_label(value)
		"hour":
			return "%s is the hour at which the hive smoker was taken" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s took the hive smoker" % value
		"place":
			return "the hive smoker was taken to the %s" % place_label(value)
		"hour":
			return "the hive smoker was taken at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s took the hive smoker" % value
		"place":
			return "it was taken to the %s" % place_label(value)
		"hour":
			return "it was taken at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"quiet_swarm":
			return "to quiet the late swarm"
		"shift_frames":
			return "to shift the frames"
		"dry_gloves":
			return "to dry the gloves"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) took the hive smoker at %s from the %s to the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			model["hour"],
			place_label(str(model["origin"])),
			place_label(str(model["place"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) filled the fuel tin in the %s." % [
			model["filler"],
			role_short(str(model["filler"])),
			place_label(str(model["fill_place"])),
		],
		"%s (%s) logged the sting book at %s in the %s." % [
			model["logger"],
			role_short(str(model["logger"])),
			model["log_hour"],
			place_label(str(model["log_place"])),
		],
		"The fuel was spent at %s." % model["spent_hour"],
		"The veil was mended at %s." % model["veil_hour"],
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
	return "The file  ·  eight exhibits"


static func board_question() -> String:
	return "Who took the hive smoker, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they took the smoker to."


static func cast_line() -> String:
	return "Isla, veil mender    Tamsin, night beekeeper    Ned, skep hand"


static func ready_line() -> String:
	return "Pin who took the hive smoker, the room they took it to, and the hour. Then submit."


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
