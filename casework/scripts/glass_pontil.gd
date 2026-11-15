extends RefCounted

# The glass pontil.
#
# The player pins three facts about the taking: who, the room the pontil was
# taken to, and the hour. The timeline also records who chalked the gather
# weight, where and at which hour it was chalked, who opened the lehr, at
# which hour the lehr was opened, where the pontil was taken from, why it was
# taken, where the gather was rolled, when the shoulder was sheared, and when
# the lehr was closed. The hour is the pin four exhibits share. Who and the
# room are each shared by two. Five hours are on the board, and the taking is
# the middle one. Two exhibits each state two hidden facts. Each exhibit
# states one of the three pins (a value at least one other exhibit also
# states) and at least one fact no other exhibit states. Exactly one full
# timeline fits every exhibit. Drop any exhibit and another timeline fits.
# Any other pin triple disagrees with at least two exhibits.

const TITLE := "The glass pontil"
const FILE_CODE := "CW-08"
const BLURB := "The glass pontil left its rest at the glasshouse. Name who took it, the room they took it to, and the hour."

const PEOPLE: Array[String] = ["Orla", "Sable", "Hugh"]
const PLACES: Array[String] = ["glory_hole", "pot_arch", "lehr_room"]
const HOURS: Array[String] = ["25", "26", "27", "28", "29"]
const PURPOSES: Array[String] = ["crack_pontil", "roll_foot", "heat_collar"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Weight line",
		"source": "Hugh, marver hand",
		"text": "Sable, the night gatherer, is the person who took the glass pontil. Hugh, the marver hand, is the person who chalked the gather weight.",
		"literals": [
			{
				"field": "taker",
				"value": "Sable",
				"phrase": "Sable, the night gatherer, is the person who took the glass pontil",
			},
			{
				"field": "chalker",
				"value": "Hugh",
				"phrase": "Hugh, the marver hand, is the person who chalked the gather weight",
			},
		],
	},
	{
		"id": "E2",
		"title": "Hole tag",
		"source": "Glory hole",
		"text": "Sable, the night gatherer, is the person who took the glass pontil. The glass pontil was taken from the glory hole.",
		"literals": [
			{
				"field": "taker",
				"value": "Sable",
				"phrase": "Sable, the night gatherer, is the person who took the glass pontil",
			},
			{
				"field": "origin",
				"value": "glory_hole",
				"phrase": "The glass pontil was taken from the glory hole",
			},
		],
	},
	{
		"id": "E3",
		"title": "Arch card",
		"source": "Pot arch",
		"text": "The glass pontil was taken to the lehr room. The gather weight was chalked in the pot arch.",
		"literals": [
			{
				"field": "place",
				"value": "lehr_room",
				"phrase": "The glass pontil was taken to the lehr room",
			},
			{
				"field": "chalk_place",
				"value": "pot_arch",
				"phrase": "The gather weight was chalked in the pot arch",
			},
		],
	},
	{
		"id": "E4",
		"title": "Lehr margin",
		"source": "Lehr room",
		"text": "The glass pontil was taken to the lehr room. Orla, the annealer, is the person who opened the lehr, and the gather was rolled at the glory hole.",
		"literals": [
			{
				"field": "place",
				"value": "lehr_room",
				"phrase": "The glass pontil was taken to the lehr room",
			},
			{
				"field": "opener",
				"value": "Orla",
				"phrase": "Orla, the annealer, is the person who opened the lehr",
			},
			{
				"field": "roll_place",
				"value": "glory_hole",
				"phrase": "the gather was rolled at the glory hole",
			},
		],
	},
	{
		"id": "E5",
		"title": "Chalk chit",
		"source": "Gather book",
		"text": "27 is the hour at which the glass pontil was taken. 25 is the hour at which the gather weight was chalked.",
		"literals": [
			{
				"field": "hour",
				"value": "27",
				"phrase": "27 is the hour at which the glass pontil was taken",
			},
			{
				"field": "chalk_hour",
				"value": "25",
				"phrase": "25 is the hour at which the gather weight was chalked",
			},
		],
	},
	{
		"id": "E6",
		"title": "Door slip",
		"source": "Lehr door",
		"text": "27 is the hour at which the glass pontil was taken. 26 is the hour at which the lehr was opened.",
		"literals": [
			{
				"field": "hour",
				"value": "27",
				"phrase": "27 is the hour at which the glass pontil was taken",
			},
			{
				"field": "open_hour",
				"value": "26",
				"phrase": "26 is the hour at which the lehr was opened",
			},
		],
	},
	{
		"id": "E7",
		"title": "Pontil note",
		"source": "Glasshouse",
		"text": "27 is the hour at which the glass pontil was taken. The glass pontil was taken in order to crack the pontil off.",
		"literals": [
			{
				"field": "hour",
				"value": "27",
				"phrase": "27 is the hour at which the glass pontil was taken",
			},
			{
				"field": "purpose",
				"value": "crack_pontil",
				"phrase": "The glass pontil was taken in order to crack the pontil off",
			},
		],
	},
	{
		"id": "E8",
		"title": "Cooling line",
		"source": "Glasshouse book",
		"text": "27 is the hour at which the glass pontil was taken. The shoulder was sheared at 28, and the lehr was closed at 29.",
		"literals": [
			{
				"field": "hour",
				"value": "27",
				"phrase": "27 is the hour at which the glass pontil was taken",
			},
			{
				"field": "shear_hour",
				"value": "28",
				"phrase": "The shoulder was sheared at 28",
			},
			{
				"field": "close_hour",
				"value": "29",
				"phrase": "the lehr was closed at 29",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"chalker",
		"chalk_place",
		"chalk_hour",
		"opener",
		"open_hour",
		"origin",
		"purpose",
		"shear_hour",
		"close_hour",
		"roll_place",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "chalker", "opener":
			return PEOPLE.duplicate()
		"place", "chalk_place", "origin", "roll_place":
			return PLACES.duplicate()
		"hour", "chalk_hour", "open_hour", "shear_hour", "close_hour":
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
		missing.append("who took the glass pontil")
	if pins["place"] == "":
		missing.append("where they took the pontil")
	if pins["hour"] == "":
		missing.append("at which hour they took the pontil")
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
		"Orla":
			return "the annealer"
		"Sable":
			return "the night gatherer"
		"Hugh":
			return "the marver hand"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"glory_hole":
			return "glory hole"
		"pot_arch":
			return "pot arch"
		"lehr_room":
			return "lehr room"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"glory_hole":
			return "Glory hole"
		"pot_arch":
			return "Pot arch"
		"lehr_room":
			return "Lehr room"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s, %s, is the person who took the glass pontil" % [value, role_phrase(value)]
		"place":
			return "The glass pontil was taken to the %s" % place_label(value)
		"hour":
			return "%s is the hour at which the glass pontil was taken" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s took the glass pontil" % value
		"place":
			return "the glass pontil was taken to the %s" % place_label(value)
		"hour":
			return "the glass pontil was taken at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s took the glass pontil" % value
		"place":
			return "it was taken to the %s" % place_label(value)
		"hour":
			return "it was taken at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"crack_pontil":
			return "to crack the pontil off"
		"roll_foot":
			return "to roll the foot"
		"heat_collar":
			return "to heat the collar"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) took the glass pontil at %s from the %s to the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			model["hour"],
			place_label(str(model["origin"])),
			place_label(str(model["place"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) chalked the gather weight at %s in the %s." % [
			model["chalker"],
			role_short(str(model["chalker"])),
			model["chalk_hour"],
			place_label(str(model["chalk_place"])),
		],
		"%s (%s) opened the lehr at %s." % [
			model["opener"],
			role_short(str(model["opener"])),
			model["open_hour"],
		],
		"The gather was rolled at the %s." % place_label(str(model["roll_place"])),
		"The shoulder was sheared at %s." % model["shear_hour"],
		"The lehr was closed at %s." % model["close_hour"],
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
	return "Who took the glass pontil, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they took the pontil to."


static func cast_line() -> String:
	return "Orla, annealer    Sable, night gatherer    Hugh, marver hand"


static func ready_line() -> String:
	return "Pin who took the glass pontil, the room they took it to, and the hour. Then submit."


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
