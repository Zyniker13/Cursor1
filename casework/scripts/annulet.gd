extends RefCounted

# The annulet.
#
# The player pins three facts about the cutting: who, the room the annulet was
# cut in, and the hour. The timeline also records who marked the spruce, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the burnisher, where that turn was made, why the annulet was cut, where
# the poplar was hung, when the burnisher was stippled, when the drawshave was forged, and
# when the beech was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The annulet"
const FILE_CODE := "CW-45"
const BLURB := "The annulet left its peg at the joiner's hinny. Name who cut the annulet, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Clive", "Edith", "Maude"]
const PLACES: Array[String] = ["beech", "burnisher", "drawshave"]
const HOURS: Array[String] = ["166", "167", "168", "169", "170"]
const AIMS: Array[String] = ["take_spruce", "spare_spruce", "set_spruce"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Spruce chit",
		"source": "Edith, spruce hand",
		"text": "Clive cut the annulet. Edith had marked the spruce, and a pale rowan still clung to the annulet.",
		"literals": [
			{
				"field": "taker",
				"value": "Clive",
				"phrase": "Clive cut the annulet",
			},
			{
				"field": "spruce",
				"value": "Edith",
				"phrase": "Edith had marked the spruce",
			},
		],
	},
	{
		"id": "E2",
		"title": "Billet sight",
		"source": "Burnisher billet",
		"text": "Clive cut the annulet. The annuleting was seen from the burnisher, beside the open spruce.",
		"literals": [
			{
				"field": "taker",
				"value": "Clive",
				"phrase": "Clive cut the annulet",
			},
			{
				"field": "seen_from",
				"value": "burnisher",
				"phrase": "The annuleting was seen from the burnisher",
			},
		],
	},
	{
		"id": "E3",
		"title": "Poplar bill",
		"source": "Drawshave nose",
		"text": "Clive cut the annulet. With the spruce true, the poplar was hung on the drawshave.",
		"literals": [
			{
				"field": "taker",
				"value": "Clive",
				"phrase": "Clive cut the annulet",
			},
			{
				"field": "poplar_room",
				"value": "drawshave",
				"phrase": "the poplar was hung on the drawshave",
			},
		],
	},
	{
		"id": "E4",
		"title": "Osier slate",
		"source": "Beech osier",
		"text": "The annulet was cut in the beech. A fresh osier shows the spruce had been marked on the drawshave.",
		"literals": [
			{
				"field": "place",
				"value": "beech",
				"phrase": "The annulet was cut in the beech",
			},
			{
				"field": "spruce_room",
				"value": "drawshave",
				"phrase": "the spruce had been marked on the drawshave",
			},
		],
	},
	{
		"id": "E5",
		"title": "Burnisher card",
		"source": "Maude, burnisher clerk",
		"text": "The annulet was cut in the beech. Maude turned the burnisher in the beech once the spruce was offered.",
		"literals": [
			{
				"field": "place",
				"value": "beech",
				"phrase": "The annulet was cut in the beech",
			},
			{
				"field": "burnisher",
				"value": "Maude",
				"phrase": "Maude turned the burnisher",
			},
			{
				"field": "burnisher_room",
				"value": "beech",
				"phrase": "turned the burnisher in the beech",
			},
		],
	},
	{
		"id": "E6",
		"title": "Stipple slip",
		"source": "Burnisher tote",
		"text": "The annulet was cut in the beech. The burnisher was stippled at 166, and a pale withy still sat on the annulet.",
		"literals": [
			{
				"field": "place",
				"value": "beech",
				"phrase": "The annulet was cut in the beech",
			},
			{
				"field": "stipple_hour",
				"value": "166",
				"phrase": "The burnisher was stippled at 166",
			},
		],
	},
	{
		"id": "E7",
		"title": "Annulet leaf",
		"source": "Spruce book",
		"text": "The annulet was cut at 168. The spruce had been marked at 167, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "168",
				"phrase": "The annulet was cut at 168",
			},
			{
				"field": "spruce_hour",
				"value": "167",
				"phrase": "The spruce had been marked at 167",
			},
		],
	},
	{
		"id": "E8",
		"title": "Hinny note",
		"source": "Joiner's hinny",
		"text": "The annulet was cut at 168. The spruce was opened so the spruce would take the annulet.",
		"literals": [
			{
				"field": "hour",
				"value": "168",
				"phrase": "The annulet was cut at 168",
			},
			{
				"field": "aim",
				"value": "take_spruce",
				"phrase": "so the spruce would take the annulet",
			},
		],
	},
	{
		"id": "E9",
		"title": "Forge order",
		"source": "Drawshave card",
		"text": "The annulet was cut at 168. The drawshave was forged at 169, and the beech was hung at 170 once the spruce was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "168",
				"phrase": "The annulet was cut at 168",
			},
			{
				"field": "forge_hour",
				"value": "169",
				"phrase": "The drawshave was forged at 169",
			},
			{
				"field": "hang_hour",
				"value": "170",
				"phrase": "the beech was hung at 170",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"spruce",
		"spruce_room",
		"spruce_hour",
		"seen_from",
		"burnisher",
		"aim",
		"burnisher_room",
		"poplar_room",
		"stipple_hour",
		"forge_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "spruce", "burnisher":
			return PEOPLE.duplicate()
		"place", "spruce_room", "seen_from", "burnisher_room", "poplar_room":
			return PLACES.duplicate()
		"hour", "spruce_hour", "stipple_hour", "forge_hour", "hang_hour":
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
		missing.append("who cut the annulet")
	if pins["place"] == "":
		missing.append("where they cut the annulet")
	if pins["hour"] == "":
		missing.append("at which hour they cut the annulet")
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
		"Clive":
			return "the annulet hand"
		"Edith":
			return "the spruce hand"
		"Maude":
			return "the burnisher clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"beech":
			return "beech"
		"burnisher":
			return "burnisher"
		"drawshave":
			return "drawshave"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"beech":
			return "Beech"
		"burnisher":
			return "Burnisher"
		"drawshave":
			return "Drawshave"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the annulet" % value
		"place":
			return "The annulet was cut in the %s" % place_label(value)
		"hour":
			return "The annulet was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the annulet" % value
		"place":
			return "the annulet was cut in the %s" % place_label(value)
		"hour":
			return "the annulet was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the annulet" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_spruce":
			return "so the spruce would take the annulet"
		"spare_spruce":
			return "to spare the spruce still waiting on the annulet"
		"set_spruce":
			return "to set the spruce before the beech was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the annulet in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the spruce on the %s at %s." % [
			model["spruce"],
			role_short(str(model["spruce"])),
			place_label(str(model["spruce_room"])),
			model["spruce_hour"],
		],
		"%s (%s) turned the burnisher in the %s." % [
			model["burnisher"],
			role_short(str(model["burnisher"])),
			place_label(str(model["burnisher_room"])),
		],
		"The poplar was hung on the %s." % place_label(str(model["poplar_room"])),
		"The burnisher was stippled at %s." % model["stipple_hour"],
		"The drawshave was forged at %s." % model["forge_hour"],
		"The beech was hung at %s." % model["hang_hour"],
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
	return "Who cut the annulet, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the annulet in."


static func cast_line() -> String:
	return "Clive, annulet hand    Edith, spruce hand    Maude, burnisher clerk"


static func ready_line() -> String:
	return "Pin who cut the annulet, the room they cut it in, and the hour. Then submit."


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
