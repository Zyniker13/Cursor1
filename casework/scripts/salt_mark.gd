extends RefCounted

# The salt mark.
#
# The player pins three facts about the scoring: who, the room the mark was
# scored on, and the hour. The timeline also records who raked the crust,
# where and at which hour it was raked, who read the brine stick, at which
# hour the stick was read, where the mark was scored from, why it was scored,
# where the rake was rested, where the brine stick was read, when the pan was
# boiled, and when the salt was drawn. Who, the room, and the hour are each
# shared by three exhibits. Five hours are on the board, and the scoring is
# the middle one. Two exhibits each state two hidden facts. Each exhibit
# states one of the three pins (a value at least one other exhibit also
# states) and at least one fact no other exhibit states. Exactly one full
# timeline fits every exhibit. Drop any exhibit and another timeline fits.
# Any other pin triple disagrees with at least two exhibits.

const TITLE := "The salt mark"
const FILE_CODE := "CW-14"
const BLURB := "The salt mark left its peg at the salt house. Name who scored it, the room they scored it on, and the hour."

const PEOPLE: Array[String] = ["Lin", "Holt", "Opal"]
const PLACES: Array[String] = ["cistern", "rake_bay", "pan"]
const HOURS: Array[String] = ["17", "18", "19", "20", "21"]
const PURPOSES: Array[String] = ["read_heavy", "boil_soon", "mark_bin"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Salt line",
		"source": "Lin, rake hand",
		"text": "Holt, the salt hand, is the person who scored the salt mark. Lin, the rake hand, is the person who raked the crust.",
		"literals": [
			{
				"field": "taker",
				"value": "Holt",
				"phrase": "Holt, the salt hand, is the person who scored the salt mark",
			},
			{
				"field": "raker",
				"value": "Lin",
				"phrase": "Lin, the rake hand, is the person who raked the crust",
			},
		],
	},
	{
		"id": "E2",
		"title": "Cistern tag",
		"source": "Cistern",
		"text": "Holt, the salt hand, is the person who scored the salt mark. The salt mark was scored from the cistern.",
		"literals": [
			{
				"field": "taker",
				"value": "Holt",
				"phrase": "Holt, the salt hand, is the person who scored the salt mark",
			},
			{
				"field": "origin",
				"value": "cistern",
				"phrase": "The salt mark was scored from the cistern",
			},
		],
	},
	{
		"id": "E3",
		"title": "Rest card",
		"source": "Rake peg",
		"text": "Holt, the salt hand, is the person who scored the salt mark. The rake was rested on the cistern.",
		"literals": [
			{
				"field": "taker",
				"value": "Holt",
				"phrase": "Holt, the salt hand, is the person who scored the salt mark",
			},
			{
				"field": "rest_place",
				"value": "cistern",
				"phrase": "The rake was rested on the cistern",
			},
		],
	},
	{
		"id": "E4",
		"title": "Bay card",
		"source": "Rake bay",
		"text": "The salt mark was scored on the pan. The crust was raked on the rake bay.",
		"literals": [
			{
				"field": "place",
				"value": "pan",
				"phrase": "The salt mark was scored on the pan",
			},
			{
				"field": "rake_place",
				"value": "rake_bay",
				"phrase": "The crust was raked on the rake bay",
			},
		],
	},
	{
		"id": "E5",
		"title": "Stick margin",
		"source": "Brine stick",
		"text": "The salt mark was scored on the pan. Opal, the brine hand, is the person who read the brine stick, and the brine stick was read on the cistern.",
		"literals": [
			{
				"field": "place",
				"value": "pan",
				"phrase": "The salt mark was scored on the pan",
			},
			{
				"field": "gauger",
				"value": "Opal",
				"phrase": "Opal, the brine hand, is the person who read the brine stick",
			},
			{
				"field": "gauge_place",
				"value": "cistern",
				"phrase": "the brine stick was read on the cistern",
			},
		],
	},
	{
		"id": "E6",
		"title": "Rake chit",
		"source": "Rake book",
		"text": "The salt mark was scored on the pan. 17 is the hour at which the crust was raked.",
		"literals": [
			{
				"field": "place",
				"value": "pan",
				"phrase": "The salt mark was scored on the pan",
			},
			{
				"field": "rake_hour",
				"value": "17",
				"phrase": "17 is the hour at which the crust was raked",
			},
		],
	},
	{
		"id": "E7",
		"title": "Stick slip",
		"source": "Stick book",
		"text": "19 is the hour at which the salt mark was scored. 18 is the hour at which the brine stick was read.",
		"literals": [
			{
				"field": "hour",
				"value": "19",
				"phrase": "19 is the hour at which the salt mark was scored",
			},
			{
				"field": "gauge_hour",
				"value": "18",
				"phrase": "18 is the hour at which the brine stick was read",
			},
		],
	},
	{
		"id": "E8",
		"title": "Heavy note",
		"source": "Salt house",
		"text": "19 is the hour at which the salt mark was scored. The salt mark was scored so the weigh would read heavy.",
		"literals": [
			{
				"field": "hour",
				"value": "19",
				"phrase": "19 is the hour at which the salt mark was scored",
			},
			{
				"field": "purpose",
				"value": "read_heavy",
				"phrase": "The salt mark was scored so the weigh would read heavy",
			},
		],
	},
	{
		"id": "E9",
		"title": "Draw line",
		"source": "Salt book",
		"text": "19 is the hour at which the salt mark was scored. The pan was boiled at 20, and the salt was drawn at 21.",
		"literals": [
			{
				"field": "hour",
				"value": "19",
				"phrase": "19 is the hour at which the salt mark was scored",
			},
			{
				"field": "boil_hour",
				"value": "20",
				"phrase": "The pan was boiled at 20",
			},
			{
				"field": "draw_hour",
				"value": "21",
				"phrase": "the salt was drawn at 21",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"raker",
		"rake_place",
		"rake_hour",
		"gauger",
		"gauge_hour",
		"origin",
		"purpose",
		"gauge_place",
		"rest_place",
		"boil_hour",
		"draw_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "raker", "gauger":
			return PEOPLE.duplicate()
		"place", "rake_place", "origin", "gauge_place", "rest_place":
			return PLACES.duplicate()
		"hour", "rake_hour", "gauge_hour", "boil_hour", "draw_hour":
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
		missing.append("who scored the salt mark")
	if pins["place"] == "":
		missing.append("where they scored the mark")
	if pins["hour"] == "":
		missing.append("at which hour they scored the mark")
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
		"Lin":
			return "the rake hand"
		"Holt":
			return "the salt hand"
		"Opal":
			return "the brine hand"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"cistern":
			return "cistern"
		"rake_bay":
			return "rake bay"
		"pan":
			return "pan"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"cistern":
			return "Cistern"
		"rake_bay":
			return "Rake bay"
		"pan":
			return "Pan"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s, %s, is the person who scored the salt mark" % [value, role_phrase(value)]
		"place":
			return "The salt mark was scored on the %s" % place_label(value)
		"hour":
			return "%s is the hour at which the salt mark was scored" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s scored the salt mark" % value
		"place":
			return "the salt mark was scored on the %s" % place_label(value)
		"hour":
			return "the salt mark was scored at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s scored the salt mark" % value
		"place":
			return "it was scored on the %s" % place_label(value)
		"hour":
			return "it was scored at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"read_heavy":
			return "so the weigh would read heavy"
		"boil_soon":
			return "to boil the pan soon"
		"mark_bin":
			return "to mark the salt bin"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) scored the salt mark at %s from the %s to the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			model["hour"],
			place_label(str(model["origin"])),
			place_label(str(model["place"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) raked the crust at %s on the %s." % [
			model["raker"],
			role_short(str(model["raker"])),
			model["rake_hour"],
			place_label(str(model["rake_place"])),
		],
		"%s (%s) read the brine stick at %s." % [
			model["gauger"],
			role_short(str(model["gauger"])),
			model["gauge_hour"],
		],
		"The rake was rested on the %s." % place_label(str(model["rest_place"])),
		"The brine stick was read on the %s." % place_label(str(model["gauge_place"])),
		"The pan was boiled at %s." % model["boil_hour"],
		"The salt was drawn at %s." % model["draw_hour"],
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
	return "Who scored the salt mark, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they scored the mark on."


static func cast_line() -> String:
	return "Lin, rake hand    Holt, salt hand    Opal, brine hand"


static func ready_line() -> String:
	return "Pin who scored the salt mark, the room they scored it on, and the hour. Then submit."


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
