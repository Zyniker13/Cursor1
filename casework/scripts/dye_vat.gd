extends RefCounted

# The dye vat.
#
# The player pins three facts about the dip: who, the room the skein was
# dipped in, and the hour. The timeline also records who wound the skein,
# where it was wound, when that winding was done, where the dip was seen
# from, who stirred the indigo, where that stir was made, why the skein was
# dipped, where the paddle was hung, when the line was stretched, when the
# yard was raked, and when the vat was lidded. Who, the room, and the hour
# are each shared by three exhibits. Five hours are on the board, and the dip
# is the middle one. Two exhibits each state two hidden facts. Each exhibit
# states one of the three pins (a value at least one other exhibit also
# states) and at least one fact no other exhibit states. Exactly one full
# timeline fits every exhibit. Drop any exhibit and another timeline fits.
# Any other pin triple disagrees with at least two exhibits.

const TITLE := "The dye vat"
const FILE_CODE := "CW-18"
const BLURB := "The dye vat left its peg at the dye house. Name who dipped the skein, the room they dipped it in, and the hour."

const PEOPLE: Array[String] = ["Pim", "Sera", "Joss"]
const PLACES: Array[String] = ["vat", "line", "yard"]
const HOURS: Array[String] = ["5", "6", "7", "8", "9"]
const PURPOSES: Array[String] = ["take_indigo", "spare_vat", "hold_shade"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Winder chit",
		"source": "Pim, skein winder",
		"text": "Sera dipped the skein. The reel tag shows Pim had wound the skein and set it ready.",
		"literals": [
			{
				"field": "taker",
				"value": "Sera",
				"phrase": "Sera dipped the skein",
			},
			{
				"field": "winder",
				"value": "Pim",
				"phrase": "Pim had wound the skein",
			},
		],
	},
	{
		"id": "E2",
		"title": "Line sight",
		"source": "Line walk",
		"text": "Sera dipped the skein. The dip was seen from the line, between two wet cloths.",
		"literals": [
			{
				"field": "taker",
				"value": "Sera",
				"phrase": "Sera dipped the skein",
			},
			{
				"field": "sight_place",
				"value": "line",
				"phrase": "The dip was seen from the line",
			},
		],
	},
	{
		"id": "E3",
		"title": "Paddle peg",
		"source": "Yard rail",
		"text": "Sera dipped the skein. Once the color took, the paddle was hung in the yard on the dry rail.",
		"literals": [
			{
				"field": "taker",
				"value": "Sera",
				"phrase": "Sera dipped the skein",
			},
			{
				"field": "paddle_place",
				"value": "yard",
				"phrase": "the paddle was hung in the yard",
			},
		],
	},
	{
		"id": "E4",
		"title": "Vat slate",
		"source": "Vat rim",
		"text": "The skein was dipped in the vat. The reel book shows that skein had been wound in the yard.",
		"literals": [
			{
				"field": "place",
				"value": "vat",
				"phrase": "The skein was dipped in the vat",
			},
			{
				"field": "wind_place",
				"value": "yard",
				"phrase": "that skein had been wound in the yard",
			},
		],
	},
	{
		"id": "E5",
		"title": "Indigo card",
		"source": "Joss, indigo hand",
		"text": "The skein was dipped in the vat. Joss stirred the indigo in a slow circle, and the stir made at the line left no pale streak.",
		"literals": [
			{
				"field": "place",
				"value": "vat",
				"phrase": "The skein was dipped in the vat",
			},
			{
				"field": "stirrer",
				"value": "Joss",
				"phrase": "Joss stirred the indigo",
			},
			{
				"field": "stir_place",
				"value": "line",
				"phrase": "the stir made at the line",
			},
		],
	},
	{
		"id": "E6",
		"title": "Stretch slip",
		"source": "Line book",
		"text": "The skein was dipped in the vat. The book says stretching the line had finished at 5, before any cloth went up.",
		"literals": [
			{
				"field": "place",
				"value": "vat",
				"phrase": "The skein was dipped in the vat",
			},
			{
				"field": "stretch_hour",
				"value": "5",
				"phrase": "stretching the line had finished at 5",
			},
		],
	},
	{
		"id": "E7",
		"title": "Dip leaf",
		"source": "Vat book",
		"text": "The skein was dipped at 7. A chalk mark says the skein had been wound at 6, one hour earlier.",
		"literals": [
			{
				"field": "hour",
				"value": "7",
				"phrase": "The skein was dipped at 7",
			},
			{
				"field": "wind_hour",
				"value": "6",
				"phrase": "the skein had been wound at 6",
			},
		],
	},
	{
		"id": "E8",
		"title": "Color note",
		"source": "Dye house",
		"text": "The skein was dipped at 7. The dip was made so the line would take the indigo.",
		"literals": [
			{
				"field": "hour",
				"value": "7",
				"phrase": "The skein was dipped at 7",
			},
			{
				"field": "purpose",
				"value": "take_indigo",
				"phrase": "so the line would take the indigo",
			},
		],
	},
	{
		"id": "E9",
		"title": "Rake order",
		"source": "Yard slate",
		"text": "The skein was dipped at 7. The yard was raked at 8, and the vat was lidded at 9.",
		"literals": [
			{
				"field": "hour",
				"value": "7",
				"phrase": "The skein was dipped at 7",
			},
			{
				"field": "rake_hour",
				"value": "8",
				"phrase": "The yard was raked at 8",
			},
			{
				"field": "lid_hour",
				"value": "9",
				"phrase": "the vat was lidded at 9",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"winder",
		"wind_place",
		"wind_hour",
		"sight_place",
		"stirrer",
		"purpose",
		"stir_place",
		"paddle_place",
		"stretch_hour",
		"rake_hour",
		"lid_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "winder", "stirrer":
			return PEOPLE.duplicate()
		"place", "wind_place", "sight_place", "stir_place", "paddle_place":
			return PLACES.duplicate()
		"hour", "wind_hour", "stretch_hour", "rake_hour", "lid_hour":
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
		missing.append("who dipped the skein")
	if pins["place"] == "":
		missing.append("where they dipped the skein")
	if pins["hour"] == "":
		missing.append("at which hour they dipped the skein")
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
		"Pim":
			return "the skein winder"
		"Sera":
			return "the dip hand"
		"Joss":
			return "the indigo hand"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"vat":
			return "vat"
		"line":
			return "line"
		"yard":
			return "yard"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"vat":
			return "Vat"
		"line":
			return "Line"
		"yard":
			return "Yard"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s dipped the skein" % value
		"place":
			return "The skein was dipped in the %s" % place_label(value)
		"hour":
			return "The skein was dipped at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s dipped the skein" % value
		"place":
			return "the skein was dipped in the %s" % place_label(value)
		"hour":
			return "the skein was dipped at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s dipped the skein" % value
		"place":
			return "it was dipped in the %s" % place_label(value)
		"hour":
			return "it was dipped at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"take_indigo":
			return "so the line would take the indigo"
		"spare_vat":
			return "to spare the indigo still in the vat"
		"hold_shade":
			return "to hold the shade until the cloth dried"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) dipped the skein in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["sight_place"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) wound the skein in the %s at %s." % [
			model["winder"],
			role_short(str(model["winder"])),
			place_label(str(model["wind_place"])),
			model["wind_hour"],
		],
		"%s (%s) stirred the indigo at the %s." % [
			model["stirrer"],
			role_short(str(model["stirrer"])),
			place_label(str(model["stir_place"])),
		],
		"The paddle was hung in the %s." % place_label(str(model["paddle_place"])),
		"The line was stretched at %s." % model["stretch_hour"],
		"The yard was raked at %s." % model["rake_hour"],
		"The vat was lidded at %s." % model["lid_hour"],
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
	return "Who dipped the skein, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they dipped the skein in."


static func cast_line() -> String:
	return "Pim, skein winder    Sera, dip hand    Joss, indigo hand"


static func ready_line() -> String:
	return "Pin who dipped the skein, the room they dipped it in, and the hour. Then submit."


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
