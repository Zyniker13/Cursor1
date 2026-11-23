extends RefCounted

# The cavetto.
#
# The player pins three facts about the cutting: who, the room the cavetto was
# cut in, and the hour. The timeline also records who marked the thumbnail, where
# it was marked, when that marking was done, where the cutting was seen from,
# who turned the bullnose, where that turn was made, why the cavetto was cut, where
# the staff was hung, when the bullnose was scraped, when the twibil was knurled, and
# when the dentil was hung. Who, the room, and the hour are each shared by
# three exhibits. Five hours are on the board, and the cutting is the middle
# one. Two exhibits each state two hidden facts. Each exhibit states one of
# the three pins (a value at least one other exhibit also states) and at least
# one fact no other exhibit states. Exactly one full timeline fits every
# exhibit. Drop any exhibit and another timeline fits. Any other pin triple
# disagrees with at least two exhibits.

const TITLE := "The cavetto"
const FILE_CODE := "CW-43"
const BLURB := "The cavetto left its peg at the joiner's palfrey. Name who cut the cavetto, the room they cut it in, and the hour."

const PEOPLE: Array[String] = ["Seth", "Ida", "Vera"]
const PLACES: Array[String] = ["dentil", "bullnose", "twibil"]
const HOURS: Array[String] = ["156", "157", "158", "159", "160"]
const AIMS: Array[String] = ["take_thumbnail", "spare_thumbnail", "set_thumbnail"]

const PLAYER_FIELDS: Array[String] = ["taker", "place", "hour"]
const FIELD_ORDER: Array[String] = ["taker", "place", "hour"]

const EXHIBITS: Array = [
	{
		"id": "E1",
		"title": "Thumbnail chit",
		"source": "Ida, thumbnail hand",
		"text": "Seth cut the cavetto. Ida had marked the thumbnail, and a pale sand still clung to the cavetto.",
		"literals": [
			{
				"field": "taker",
				"value": "Seth",
				"phrase": "Seth cut the cavetto",
			},
			{
				"field": "thumbnail",
				"value": "Ida",
				"phrase": "Ida had marked the thumbnail",
			},
		],
	},
	{
		"id": "E2",
		"title": "Drip sight",
		"source": "Bullnose drip",
		"text": "Seth cut the cavetto. The cavettoing was seen from the bullnose, beside the open thumbnail.",
		"literals": [
			{
				"field": "taker",
				"value": "Seth",
				"phrase": "Seth cut the cavetto",
			},
			{
				"field": "seen_from",
				"value": "bullnose",
				"phrase": "The cavettoing was seen from the bullnose",
			},
		],
	},
	{
		"id": "E3",
		"title": "Staff bill",
		"source": "Twibil nose",
		"text": "Seth cut the cavetto. With the thumbnail true, the staff was hung on the twibil.",
		"literals": [
			{
				"field": "taker",
				"value": "Seth",
				"phrase": "Seth cut the cavetto",
			},
			{
				"field": "staff_room",
				"value": "twibil",
				"phrase": "the staff was hung on the twibil",
			},
		],
	},
	{
		"id": "E4",
		"title": "Cedar slate",
		"source": "Dentil cedar",
		"text": "The cavetto was cut in the dentil. A fresh cedar shows the thumbnail had been marked on the twibil.",
		"literals": [
			{
				"field": "place",
				"value": "dentil",
				"phrase": "The cavetto was cut in the dentil",
			},
			{
				"field": "thumbnail_room",
				"value": "twibil",
				"phrase": "the thumbnail had been marked on the twibil",
			},
		],
	},
	{
		"id": "E5",
		"title": "Bullnose card",
		"source": "Vera, bullnose clerk",
		"text": "The cavetto was cut in the dentil. Vera turned the bullnose in the dentil once the thumbnail was offered.",
		"literals": [
			{
				"field": "place",
				"value": "dentil",
				"phrase": "The cavetto was cut in the dentil",
			},
			{
				"field": "bullnose",
				"value": "Vera",
				"phrase": "Vera turned the bullnose",
			},
			{
				"field": "bullnose_room",
				"value": "dentil",
				"phrase": "turned the bullnose in the dentil",
			},
		],
	},
	{
		"id": "E6",
		"title": "Scrape slip",
		"source": "Bullnose tote",
		"text": "The cavetto was cut in the dentil. The bullnose was scraped at 156, and a pale birch still sat on the cavetto.",
		"literals": [
			{
				"field": "place",
				"value": "dentil",
				"phrase": "The cavetto was cut in the dentil",
			},
			{
				"field": "scrape_hour",
				"value": "156",
				"phrase": "The bullnose was scraped at 156",
			},
		],
	},
	{
		"id": "E7",
		"title": "Cavetto leaf",
		"source": "Thumbnail book",
		"text": "The cavetto was cut at 158. The thumbnail had been marked at 157, and the mark still held that hour.",
		"literals": [
			{
				"field": "hour",
				"value": "158",
				"phrase": "The cavetto was cut at 158",
			},
			{
				"field": "thumbnail_hour",
				"value": "157",
				"phrase": "The thumbnail had been marked at 157",
			},
		],
	},
	{
		"id": "E8",
		"title": "Palfrey note",
		"source": "Joiner's palfrey",
		"text": "The cavetto was cut at 158. The thumbnail was opened so the thumbnail would take the cavetto.",
		"literals": [
			{
				"field": "hour",
				"value": "158",
				"phrase": "The cavetto was cut at 158",
			},
			{
				"field": "aim",
				"value": "take_thumbnail",
				"phrase": "so the thumbnail would take the cavetto",
			},
		],
	},
	{
		"id": "E9",
		"title": "Knurl order",
		"source": "Twibil card",
		"text": "The cavetto was cut at 158. The twibil was knurled at 159, and the dentil was hung at 160 once the thumbnail was dry.",
		"literals": [
			{
				"field": "hour",
				"value": "158",
				"phrase": "The cavetto was cut at 158",
			},
			{
				"field": "knurl_hour",
				"value": "159",
				"phrase": "The twibil was knurled at 159",
			},
			{
				"field": "hang_hour",
				"value": "160",
				"phrase": "the dentil was hung at 160",
			},
		],
	},
]


static func fields() -> Array[String]:
	return [
		"taker",
		"place",
		"hour",
		"thumbnail",
		"thumbnail_room",
		"thumbnail_hour",
		"seen_from",
		"bullnose",
		"aim",
		"bullnose_room",
		"staff_room",
		"scrape_hour",
		"knurl_hour",
		"hang_hour",
	]


static func domain(field: String) -> Array[String]:
	match field:
		"taker", "thumbnail", "bullnose":
			return PEOPLE.duplicate()
		"place", "thumbnail_room", "seen_from", "bullnose_room", "staff_room":
			return PLACES.duplicate()
		"hour", "thumbnail_hour", "scrape_hour", "knurl_hour", "hang_hour":
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
		missing.append("who cut the cavetto")
	if pins["place"] == "":
		missing.append("where they cut the cavetto")
	if pins["hour"] == "":
		missing.append("at which hour they cut the cavetto")
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
		"Seth":
			return "the cavetto hand"
		"Ida":
			return "the thumbnail hand"
		"Vera":
			return "the bullnose clerk"
		_:
			return "unknown role"


static func role_short(person: String) -> String:
	return role_phrase(person).trim_prefix("the ")


static func place_label(place: String) -> String:
	match place:
		"dentil":
			return "dentil"
		"bullnose":
			return "bullnose"
		"twibil":
			return "twibil"
		"":
			return ""
		_:
			return place


static func place_button(place: String) -> String:
	match place:
		"dentil":
			return "Dentil"
		"bullnose":
			return "Bullnose"
		"twibil":
			return "Twibil"
		_:
			return place_label(place)


static func player_statement(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the cavetto" % value
		"place":
			return "The cavetto was cut in the %s" % place_label(value)
		"hour":
			return "The cavetto was cut at %s" % value
		_:
			return ""


static func player_claim(field: String, theory: Dictionary) -> String:
	return player_statement(field, theory_value(field, theory))


static func short_claim(field: String, theory: Dictionary) -> String:
	var value := theory_value(field, theory)
	match field:
		"taker":
			return "%s cut the cavetto" % value
		"place":
			return "the cavetto was cut in the %s" % place_label(value)
		"hour":
			return "the cavetto was cut at %s" % value
		_:
			return value


static func counter_claim(field: String, value: String) -> String:
	match field:
		"taker":
			return "%s cut the cavetto" % value
		"place":
			return "it was cut in the %s" % place_label(value)
		"hour":
			return "it was cut at %s" % value
		_:
			return value


static func aim_phrase(aim: String) -> String:
	match aim:
		"take_thumbnail":
			return "so the thumbnail would take the cavetto"
		"spare_thumbnail":
			return "to spare the thumbnail still waiting on the cavetto"
		"set_thumbnail":
			return "to set the thumbnail before the dentil was hung"
		_:
			return "for an unstated reason"


static func timeline(model: Dictionary) -> String:
	var lines := PackedStringArray([
		"%s (%s) cut the cavetto in the %s at %s, seen from the %s, %s." % [
			model["taker"],
			role_short(str(model["taker"])),
			place_label(str(model["place"])),
			model["hour"],
			place_label(str(model["seen_from"])),
			aim_phrase(str(model["aim"])),
		],
		"%s (%s) marked the thumbnail on the %s at %s." % [
			model["thumbnail"],
			role_short(str(model["thumbnail"])),
			place_label(str(model["thumbnail_room"])),
			model["thumbnail_hour"],
		],
		"%s (%s) turned the bullnose in the %s." % [
			model["bullnose"],
			role_short(str(model["bullnose"])),
			place_label(str(model["bullnose_room"])),
		],
		"The staff was hung on the %s." % place_label(str(model["staff_room"])),
		"The bullnose was scraped at %s." % model["scrape_hour"],
		"The twibil was knurled at %s." % model["knurl_hour"],
		"The dentil was hung at %s." % model["hang_hour"],
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
	return "Who cut the cavetto, where, and at which hour?"


static func board_brief() -> String:
	return "Where means the room they cut the cavetto in."


static func cast_line() -> String:
	return "Seth, cavetto hand    Ida, thumbnail hand    Vera, bullnose clerk"


static func ready_line() -> String:
	return "Pin who cut the cavetto, the room they cut it in, and the hour. Then submit."


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
