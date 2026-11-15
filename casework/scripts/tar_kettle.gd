extends RefCounted

# The tar kettle.
#
# The player pins three facts about the tarring: who, the room the rope was
# tarred in, and the hour. The timeline also records who laid the rope, where
# it was laid, when that laying was done, where the tarring was seen from, who
# turned the winch, where that turn was made, why the rope was tarred, where
# the hook was hung, when the walk was stretched, when the loft was swept, and
# when the kettle was lidded. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the tarring is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The tar kettle"
const FILE_CODE := "CW-19"
const BLURB := "The tar kettle left its peg at the rope walk. Name who tarred the rope, the room they tarred it in, and the hour."

const PEOPLE: Array[String] = ["Lumen", "Rho", "Kit"]
const PLACES: Array[String] = ["kettle", "walk", "loft"]
const HOURS: Array[String] = ["4", "5", "6", "7", "8"]
const PURPOSES: Array[String] = ["take_tar", "spare_pitch", "hold_coat"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Rope chit",
		"source": "Lumen, rope hand",
		"text": "Rho tarred the rope. The coil tag shows Lumen had laid the rope and left the end free.",
		"literals": [
			{
				"field": "taker",
				"value": "Rho",
				"phrase": "Rho tarred the rope",
			},
			{
				"field": "layer",
				"value": "Lumen",
				"phrase": "Lumen had laid the rope",
			},
		],
	},
	{
		"id": "E2",
		"title": "Walk sight",
		"source": "Walk rail",
		"text": "Rho tarred the rope. The tarring was seen from the walk, past the idle posts.",
		"literals": [
			{
				"field": "taker",
				"value": "Rho",
				"phrase": "Rho tarred the rope",
			},
			{
				"field": "look_place",
				"value": "walk",
				"phrase": "The tarring was seen from the walk",
			},
		],
	},
	{
		"id": "E3",
		"title": "Hook peg",
		"source": "Loft peg",
		"text": "Rho tarred the rope. After the pitch cooled, the hook was hung in the loft.",
		"literals": [
			{
				"field": "taker",
				"value": "Rho",
				"phrase": "Rho tarred the rope",
			},
			{
				"field": "hook_place",
				"value": "loft",
				"phrase": "the hook was hung in the loft",
			},
		],
	},
	{
		"id": "E4",
		"title": "Kettle slate",
		"source": "Kettle rim",
		"text": "The rope was tarred in the kettle. The coil book shows that rope had been laid in the loft.",
		"literals": [
			{
				"field": "place",
				"value": "kettle",
				"phrase": "The rope was tarred in the kettle",
			},
			{
				"field": "lay_place",
				"value": "loft",
				"phrase": "that rope had been laid in the loft",
			},
		],
	},
	{
		"id": "E5",
		"title": "Winch card",
		"source": "Kit, walk clerk",
		"text": "The rope was tarred in the kettle. Kit turned the winch, and the turn made at the walk left every strand black.",
		"literals": [
			{
				"field": "place",
				"value": "kettle",
				"phrase": "The rope was tarred in the kettle",
			},
			{
				"field": "clerk",
				"value": "Kit",
				"phrase": "Kit turned the winch",
			},
			{
				"field": "winch_place",
				"value": "walk",
				"phrase": "the turn made at the walk",
			},
		],
	},
	{
		"id": "E6",
		"title": "Span slip",
		"source": "Walk book",
		"text": "The rope was tarred in the kettle. The walk was stretched at 4, before any rope went up.",
		"literals": [
			{
				"field": "place",
				"value": "kettle",
				"phrase": "The rope was tarred in the kettle",
			},
			{
				"field": "span_hour",
				"value": "4",
				"phrase": "The walk was stretched at 4",
			},
		],
	},
	{
		"id": "E7",
		"title": "Tar leaf",
		"source": "Kettle book",
		"text": "The rope was tarred at 6. A chalk mark says the rope had been laid at 5, before the pitch went on.",
		"literals": [
			{
				"field": "hour",
				"value": "6",
				"phrase": "The rope was tarred at 6",
			},
			{
				"field": "lay_hour",
				"value": "5",
				"phrase": "the rope had been laid at 5",
			},
		],
	},
	{
		"id": "E8",
		"title": "Pitch note",
		"source": "Rope walk",
		"text": "The rope was tarred at 6. The tarring was made so the walk would take the tar.",
		"literals": [
			{
				"field": "hour",
				"value": "6",
				"phrase": "The rope was tarred at 6",
			},
			{
				"field": "purpose",
				"value": "take_tar",
				"phrase": "so the walk would take the tar",
			},
		],
	},
	{
		"id": "E9",
		"title": "Sweep order",
		"source": "Loft slate",
		"text": "The rope was tarred at 6. The loft was swept at 7, and the kettle was lidded at 8.",
		"literals": [
			{
				"field": "hour",
				"value": "6",
				"phrase": "The rope was tarred at 6",
			},
			{
				"field": "sweep_hour",
				"value": "7",
				"phrase": "The loft was swept at 7",
			},
			{
				"field": "cover_hour",
				"value": "8",
				"phrase": "the kettle was lidded at 8",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"layer",
		"lay_place",
		"lay_hour",
		"look_place",
		"clerk",
		"purpose",
		"winch_place",
		"hook_place",
		"span_hour",
		"sweep_hour",
		"cover_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "layer", "clerk":
			return PEOPLE.duplicate()
		"place", "lay_place", "look_place", "winch_place", "hook_place":
			return PLACES.duplicate()
		"hour", "lay_hour", "span_hour", "sweep_hour", "cover_hour":
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
		missing.append("who tarred the rope")
	if pins["place"] == "":
		missing.append("where they tarred the rope")
	if pins["hour"] == "":
		missing.append("at which hour they tarred the rope")
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
		"Lumen":
			return "the rope hand"
		"Rho":
			return "the tar hand"
		"Kit":
			return "the walk clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"kettle":
			return "kettle"
		"walk":
			return "walk"
		"loft":
			return "loft"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"kettle":
			return "Kettle"
		"walk":
			return "Walk"
		"loft":
			return "Loft"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s tarred the rope" % value
		"place":
			return "The rope was tarred in the %s" % place_label(value)
		"hour":
			return "The rope was tarred at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s tarred the rope" % value
		"place":
			return "the rope was tarred in the %s" % place_label(value)
		"hour":
			return "the rope was tarred at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s tarred the rope" % value
		"place":
			return "it was tarred in the %s" % place_label(value)
		"hour":
			return "it was tarred at %s" % value
		_:
			return value


static func purpose_phrase(purpose: String) -> String:
	match purpose:
		"take_tar":
			return "so the walk would take the tar"
		"spare_pitch":
			return "to spare the pitch still in the kettle"
		"hold_coat":
			return "to hold the coat until the strands cooled"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) tarred the rope in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["look_place"])),
			purpose_phrase(str(model["purpose"])),
		],
		"%s (%s) laid the rope in the %s at %s." % [
			model["layer"],
			role_short(str(model["layer"])),
			place_label(str(model["lay_place"])),
			model["lay_hour"],
		],
		"%s (%s) turned the winch at the %s." % [
			model["clerk"],
			role_short(str(model["clerk"])),
			place_label(str(model["winch_place"])),
		],
		"The hook was hung in the %s." % place_label(str(model["hook_place"])),
		"The walk was stretched at %s." % model["span_hour"],
		"The loft was swept at %s." % model["sweep_hour"],
		"The kettle was lidded at %s." % model["cover_hour"],
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
	return "Who tarred the rope, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they tarred the rope in."


static func cast_line() -> String:
	return "Lumen, rope hand    Rho, tar hand    Kit, walk clerk"


static func ready_line() -> String:
	return "Pin who tarred the rope, the room they tarred it in, and the hour. Then submit."


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
