extends RefCounted
class_name ChartBook

# South Lantern Quay holds six charts. North Glass Reach holds eight more.
# The Turning Basin holds the next eight. The Painted Lock holds eight more.
# The West Return holds the last eight.
# Piece rotations are degrees. Mirrors and panes use 0 or 90 (the other two
# facings repeat). Prisms use 0, 90, 180, and 270. See BeamTracer for the
# optical meaning of each number.
#
# Every chart starts away from its solution: a wrong rotation, a wrong socket,
# or both. Tide index picks an entry of tide_phases, which is the count of
# flooded rows measured up from the bottom.

const HARBOR := "South Lantern Quay"
const REACH := "North Glass Reach"
const BASIN := "The Turning Basin"
const PAINTED := "The Painted Lock"
const WEST := "The West Return"

static func all() -> Array:
	var book: Array = []
	book.append_array(quay())
	book.append_array(reach())
	book.append_array(basin())
	book.append_array(painted())
	book.append_array(west())
	return book


static func quay() -> Array:
	return [chart_1(), chart_2(), chart_3(), chart_4(), chart_5(), chart_6()]


static func reach() -> Array:
	return [chart_7(), chart_8(), chart_9(), chart_10(), chart_11(), chart_12(), chart_13(), chart_14()]


static func basin() -> Array:
	return [chart_15(), chart_16(), chart_17(), chart_18(), chart_19(), chart_20(), chart_21(), chart_22()]


static func painted() -> Array:
	return [chart_23(), chart_24(), chart_25(), chart_26(), chart_27(), chart_28(), chart_29(), chart_30()]


static func west() -> Array:
	return [chart_31(), chart_32(), chart_33(), chart_34(), chart_35(), chart_36(), chart_37(), chart_38()]

static func chart_1() -> Dictionary:
	# One mirror. "/" sends the eastbound beam north into the dock.
	# "\" dumps it south into the flooded bottom row, where it stops.
	return {
		"id": "1",
		"title": "First Glass",
		"teach": "Turn the mirror (click it, or press R) so the beam lands on the dock. The tide line shuts any glass it covers. Lock Chart (Space) checks the beams. Hint (H) marks one wrong piece, three times.",
		"win": "The dock lamp takes the beam.",
		"cols": 5,
		"rows": 5,
		"tide_phases": [1],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 2, "E", "white")],
		"docks": [_dock("D", 2, 0, "white")],
		"boats": [],
		"fixtures": [],
		"pieces": [_mirror("M", "Mirror", 2, 2, 90, 0)],
	}

static func chart_2() -> Dictionary:
	# Two mirrors route the beam up and then east, over the pilings.
	# The straight line from the lantern is open but ends in the pilings
	# only if a mirror is missing; the mirrors sit off that line and bend
	# around columns 2-4 on row 2.
	return {
		"id": "2",
		"title": "Around the Pilings",
		"teach": "Two mirrors. Bend the beam up, then east, around the pilings.",
		"win": "The beam clears the pilings.",
		"cols": 7,
		"rows": 5,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [Vector2i(2, 2), Vector2i(3, 2), Vector2i(4, 2)],
		"lanterns": [_lantern("L", 0, 3, "E", "white")],
		"docks": [_dock("D", 6, 1, "white")],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_mirror("M1", "Lower mirror", 1, 3, 90, 0),
			_mirror("M2", "Upper mirror", 1, 1, 90, 0),
		],
	}

static func chart_3() -> Dictionary:
	# Tide phases flood 0, then the bottom row, then the bottom two rows.
	# The pivot starts on the low route: "\" into the fixed glass on row 4,
	# east to the fixed glass under the dock, then north. That route lights
	# the dock only while row 4 is dry.
	# At the high-water mark (phase index 2) row 4 is shut, so the pivot must
	# turn to "/" and the high mirror must send the beam east.
	# The lower lantern shines across row 4 into the hull until that row
	# floods, so a low tide cannot lock even when the high path is already set.
	return {
		"id": "3",
		"title": "High Water",
		"teach": "Raise the tide until the low quay floods. The lower route dies, so the beam has to take the high glass. Leave the hull dark.",
		"win": "High water, and the high glass still reaches the dock.",
		"cols": 8,
		"rows": 6,
		"tide_phases": [0, 1, 2],
		"start_tide_index": 0,
		"solution_tide_index": 2,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 3, "E", "white"),
			_lantern("S", 0, 4, "E", "white"),
		],
		"docks": [_dock("D", 7, 1, "white")],
		"boats": [_boat("B", 2, 4)],
		"fixtures": [
			_fixture("HL", "mirror", 3, 4, 90),
			_fixture("G", "mirror", 7, 4, 0),
		],
		"pieces": [
			_mirror("A", "Pivot mirror", 3, 3, 90, 0),
			_mirror("H", "High mirror", 3, 1, 90, 0),
		],
	}

static func chart_4() -> Dictionary:
	# "/" sends the beam north to the dock. "\" sends it south into the hull.
	return {
		"id": "4",
		"title": "Sleeping Hull",
		"teach": "Light the dock. The sleeping hull has to stay dark.",
		"win": "The dock is lit. The hull stays asleep.",
		"cols": 5,
		"rows": 4,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 2, "E", "white")],
		"docks": [_dock("D", 1, 0, "white")],
		"boats": [_boat("B", 1, 3)],
		"fixtures": [],
		"pieces": [_mirror("M", "Mirror", 1, 2, 90, 0)],
	}

static func chart_5() -> Dictionary:
	# Prism at the high socket, rot 90: white traveling E splits.
	# Red leaves traveling N onto the red dock. Blue leaves traveling S
	# onto the blue dock. The low socket is off the lantern's row.
	# See BeamTracer.prism_ports for the exits.
	return {
		"id": "5",
		"title": "Split the White",
		"teach": "A prism splits white into red and blue. Move it into the working socket and turn it so each dock takes its color.",
		"win": "Red and blue rest on their own docks.",
		"cols": 5,
		"rows": 5,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 2, "E", "white")],
		"docks": [
			_dock("Rd", 2, 0, "red"),
			_dock("Bd", 2, 4, "blue"),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["low", 2, 3], ["high", 2, 2]], "low", 0, "high", 90),
		],
	}

static func chart_6() -> Dictionary:
	# Combined chart.
	# Prism rot 90 splits the eastbound white beam: red goes north into the
	# mirror, blue goes south and dies on the flooded bottom row.
	# The mirror's "/" sends red east through a red pane to the red dock.
	# Its "\" sends red west into the hull.
	# The pane passes only its own color, so a blue pane stops the red beam.
	# A lower lantern on the bottom row bounces north into the same hull
	# until the tide covers that row. Low tide cannot lock.
	return {
		"id": "6",
		"title": "The Night Mark",
		"teach": "Raise the tide, keep the hull dark, and let red through the pane. The pane passes only its own color.",
		"win": "Tide, color, and a dark hull. The night mark holds.",
		"cols": 7,
		"rows": 6,
		"tide_phases": [0, 1],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 4, "E", "white"),
			_lantern("S", 0, 5, "E", "white"),
		],
		"docks": [_dock("D", 6, 2, "red")],
		"boats": [_boat("B", 1, 2)],
		"fixtures": [
			_fixture("Fs", "mirror", 1, 5, 0),
		],
		"pieces": [
			_prism("P", "Prism", [["a", 2, 4]], "a", 0, "a", 90),
			_mirror("M", "Mirror", 2, 2, 90, 0),
			_pane("C", "Tinted pane", 4, 2, 90, 0),
		],
	}

static func chart_7() -> Dictionary:
	# Set prism, rot 90: white traveling east splits. Red goes north into
	# the red dock. Blue goes south through the pane. Only the blue face
	# lets blue reach the lower dock. The pane starts on red.
	return {
		"id": "7",
		"harbor": REACH,
		"title": "Blue Glass",
		"teach": "The set prism splits white. Red already climbs to its dock. Turn the pane so its face is blue, and blue can fall to the lower dock.",
		"win": "Red and blue rest on their own docks.",
		"cols": 5,
		"rows": 5,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 1, "E", "white")],
		"docks": [
			_dock("Rd", 2, 0, "red"),
			_dock("Bd", 2, 4, "blue"),
		],
		"boats": [],
		"fixtures": [
			_fixture("Px", "prism", 2, 1, 90),
		],
		"pieces": [
			_pane("C", "Lower pane", 2, 3, 0, 90),
		],
	}


static func chart_8() -> Dictionary:
	# Three tide marks. The mirror sits on the row high water covers.
	# "/" sends the eastbound beam north to the dock. "\" sends it south
	# into the flooded bottom, or into the hull while that row is dry.
	# A second lantern on the bottom row lights the hull until the first
	# mark of water shuts it. Only the middle mark clears.
	return {
		"id": "8",
		"harbor": REACH,
		"title": "Between the Marks",
		"teach": "Three marks on the clock. Low water leaves the hull in the east light. High water covers the mirror. Choose the middle, and aim the beam up to the dock.",
		"win": "Mid water, and the dock lamp takes the beam.",
		"cols": 6,
		"rows": 5,
		"tide_phases": [0, 1, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 3, "E", "white"),
			_lantern("S", 0, 4, "E", "white"),
		],
		"docks": [_dock("D", 3, 0, "white")],
		"boats": [_boat("B", 3, 4)],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Mirror", 3, 3, 90, 0),
		],
	}


static func chart_9() -> Dictionary:
	# Same split as Blue Glass, aimed the other way. Blue falls toward a
	# hull. The red face of the pane stops blue, so the hull stays dark.
	# The blue face lets blue through and wakes the hull. Red still climbs.
	return {
		"id": "9",
		"harbor": REACH,
		"title": "The Red Shield",
		"teach": "Blue falls toward a sleeping hull. Turn the pane to red so that color stops. Red still climbs to its dock.",
		"win": "The dock takes red. The hull stays asleep.",
		"cols": 6,
		"rows": 5,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 1, 1, "E", "white")],
		"docks": [_dock("Rd", 3, 0, "red")],
		"boats": [_boat("B", 3, 4)],
		"fixtures": [
			_fixture("Px", "prism", 3, 1, 90),
		],
		"pieces": [
			_pane("C", "Lower pane", 3, 3, 90, 0),
		],
	}


static func chart_10() -> Dictionary:
	# Prism rot 90. Red leaves north and must be bent east. Blue leaves
	# south and must pass a blue pane. Either wrong piece misses its dock.
	return {
		"id": "10",
		"harbor": REACH,
		"title": "Bend the Red",
		"teach": "Bend red along the top glass. The pane on the falling beam has to show blue, or that dock stays dark.",
		"win": "Red runs the top. Blue falls through.",
		"cols": 6,
		"rows": 5,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 1, "E", "white")],
		"docks": [
			_dock("Rd", 4, 0, "red"),
			_dock("Bd", 2, 4, "blue"),
		],
		"boats": [],
		"fixtures": [
			_fixture("Px", "prism", 2, 1, 90),
		],
		"pieces": [
			_mirror("M", "Top mirror", 2, 0, 90, 0),
			_pane("C", "Lower pane", 2, 3, 0, 90),
		],
	}


static func chart_11() -> Dictionary:
	# Blue has to pass the pane and bend west along the row high water
	# covers. That row is dry at the middle mark and shut at high water.
	# The bottom lantern lights the hull whenever the bottom row is dry,
	# so low water cannot lock. Red climbs straight to its dock.
	return {
		"id": "11",
		"harbor": REACH,
		"title": "The Dry Step",
		"teach": "Blue must pass the pane and bend west on the low mirror. High water covers that mirror. Low water wakes the hull. The middle mark is the one that holds.",
		"win": "The middle mark holds both colors, and the hull stays dark.",
		"cols": 5,
		"rows": 6,
		"tide_phases": [0, 1, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 1, "E", "white"),
			_lantern("S", 0, 5, "E", "white"),
		],
		"docks": [
			_dock("Rd", 2, 0, "red"),
			_dock("Bd", 0, 4, "blue"),
		],
		"boats": [_boat("B", 3, 5)],
		"fixtures": [
			_fixture("Px", "prism", 2, 1, 90),
		],
		"pieces": [
			_pane("C", "Lower pane", 2, 3, 0, 90),
			_mirror("M", "Low mirror", 2, 4, 90, 0),
		],
	}


static func chart_12() -> Dictionary:
	# The prism has a socket off the lantern's row. Only the socket on that
	# row, turned to rot 90, splits the eastbound white beam. Red then has
	# to bend east, and blue has to pass the pane.
	return {
		"id": "12",
		"harbor": REACH,
		"title": "The Working Socket",
		"teach": "Move the prism onto the lantern's row and turn it until the beam splits. Bend red along the top. Let blue through the pane.",
		"win": "The prism sits in the working socket, and both docks take their color.",
		"cols": 7,
		"rows": 5,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 2, "E", "white")],
		"docks": [
			_dock("Rd", 5, 0, "red"),
			_dock("Bd", 2, 4, "blue"),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["side", 4, 1], ["line", 2, 2]], "side", 0, "line", 90),
			_mirror("M", "Top mirror", 2, 0, 90, 0),
			_pane("C", "Lower pane", 2, 3, 0, 90),
		],
	}


static func chart_13() -> Dictionary:
	# Both colors leave the set prism and have to bend east through a pane
	# of their own color. The top mirror's other face sends red west into
	# the hull. The low mirror's other face sends blue west, off the dock.
	return {
		"id": "13",
		"harbor": REACH,
		"title": "Crossed Marks",
		"teach": "Each color has to bend, then pass a pane of its own color. The wrong bend on the top glass wakes the hull.",
		"win": "Both colors cross, and the hull stays asleep.",
		"cols": 7,
		"rows": 5,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 2, "E", "white")],
		"docks": [
			_dock("Rd", 6, 0, "red"),
			_dock("Bd", 6, 4, "blue"),
		],
		"boats": [_boat("B", 1, 0)],
		"fixtures": [
			_fixture("Px", "prism", 3, 2, 90),
		],
		"pieces": [
			_mirror("Mr", "Top mirror", 3, 0, 90, 0),
			_pane("Cr", "Top pane", 5, 0, 90, 0),
			_mirror("Mb", "Low mirror", 3, 4, 0, 90),
			_pane("Cb", "Low pane", 5, 4, 0, 90),
		],
	}


static func chart_14() -> Dictionary:
	# Capstone. The working socket is on the lantern's row; the other socket
	# is not, so the prism there never sees the beam. Rot 90 splits white:
	# red bends east along the top, blue bends east through the blue pane.
	# Low water lets the bottom lantern wake the hull. High water covers the
	# low mirror, the pane, and the blue dock. Only the middle mark holds.
	return {
		"id": "14",
		"harbor": REACH,
		"title": "The Holding Line",
		"teach": "Move the prism onto the lantern's row, bend both colors, and leave the pane blue. Low water wakes the hull. High water covers the low glass. Hold the middle mark.",
		"win": "Tide, socket, and color. The reach holds.",
		"cols": 7,
		"rows": 6,
		"tide_phases": [0, 1, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 2, "E", "white"),
			_lantern("S", 0, 5, "E", "white"),
		],
		"docks": [
			_dock("Rd", 5, 0, "red"),
			_dock("Bd", 6, 4, "blue"),
		],
		"boats": [_boat("B", 4, 5)],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["side", 5, 3], ["line", 2, 2]], "side", 0, "line", 90),
			_mirror("Mr", "Top mirror", 2, 0, 90, 0),
			_mirror("Mb", "Low mirror", 2, 4, 0, 90),
			_pane("C", "Low pane", 4, 4, 0, 90),
		],
	}

static func chart_15() -> Dictionary:
	# Northbound white. Only rot 0 drinks it: red leaves west, blue leaves east.
	# rot 90, 180, and 270 absorb that beam.
	return {
		"id": "15",
		"harbor": BASIN,
		"title": "North Light",
		"teach": "This lantern shines north. Turn the prism so red faces the red dock and blue faces the blue dock.",
		"win": "Red and blue leave toward their own docks.",
		"cols": 5,
		"rows": 4,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 2, 3, "N", "white")],
		"docks": [
			_dock("Rd", 0, 0, "red"),
			_dock("Bd", 4, 0, "blue"),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["a", 2, 0]], "a", 90, "a", 0),
		],
	}

static func chart_16() -> Dictionary:
	# The prism is set at rot 0. Mirror rot 0 sends the eastbound beam north
	# into it. Mirror rot 90 sends the beam south off the board.
	return {
		"id": "16",
		"harbor": BASIN,
		"title": "Bend North",
		"teach": "The set prism already faces the two docks. Bend the east light north into it, or the beam never splits.",
		"win": "The east light climbs into the prism, and both docks take their color.",
		"cols": 5,
		"rows": 4,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 3, "E", "white")],
		"docks": [
			_dock("Rd", 0, 0, "red"),
			_dock("Bd", 4, 0, "blue"),
		],
		"boats": [],
		"fixtures": [
			_fixture("Px", "prism", 2, 0, 0),
		],
		"pieces": [
			_mirror("M", "Mirror", 2, 3, 90, 0),
		],
	}

static func chart_17() -> Dictionary:
	# Mirror rot 90 sends the eastbound beam south. Prism rot 180 drinks a
	# southbound white beam: red leaves east through the pane, blue leaves
	# west. Mirror rot 0 sends the beam north into the hull. A blue pane
	# stops red. Prism rot 0 does not drink a southbound beam.
	return {
		"id": "17",
		"harbor": BASIN,
		"title": "The South Door",
		"teach": "Bend the beam south into the prism, and turn the prism so each mark faces its dock. Let red through the pane. The other bend wakes the hull.",
		"win": "Red crosses the pane. Blue runs west. The hull stays asleep.",
		"cols": 6,
		"rows": 4,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 1, "E", "white")],
		"docks": [
			_dock("Bd", 0, 3, "blue"),
			_dock("Rd", 5, 3, "red"),
		],
		"boats": [_boat("H", 3, 0)],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Feed mirror", 3, 1, 0, 90),
			_prism("P", "Prism", [["a", 3, 3]], "a", 0, "a", 180),
			_pane("C", "Red pane", 4, 3, 90, 0),
		],
	}

static func chart_18() -> Dictionary:
	# The south door sits on the row high water covers. On six rows, flood 2
	# shuts row 4: the prism, the pane, and both docks. Flood 0 leaves the
	# bottom lantern shining into the lower hull. Mirror rot 0 wakes the upper
	# hull at every mark. Only the middle mark clears.
	return {
		"id": "18",
		"harbor": BASIN,
		"title": "The Covered Row",
		"teach": "Bend the beam south into the prism and let red through the pane. The other bend wakes a hull. High water covers that glass. Low water wakes the lower hull. Hold the middle mark.",
		"win": "The middle mark holds both colors, and both hulls stay dark.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [0, 1, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 1, "E", "white"),
			_lantern("S", 0, 5, "E", "white"),
		],
		"docks": [
			_dock("Bd", 0, 4, "blue"),
			_dock("Rd", 5, 4, "red"),
		],
		"boats": [
			_boat("H", 3, 0),
			_boat("B", 4, 5),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Feed mirror", 3, 1, 0, 90),
			_prism("P", "Prism", [["a", 3, 4]], "a", 90, "a", 180),
			_pane("C", "Red pane", 4, 4, 90, 0),
		],
	}

static func chart_19() -> Dictionary:
	# The side socket is off the beam. Only the socket under the mirror, at
	# rot 180, splits the southbound white beam. Red then passes the pane.
	# Mirror rot 0 wakes the hull.
	return {
		"id": "19",
		"harbor": BASIN,
		"title": "The Open Socket",
		"teach": "Move the prism onto the column the mirror feeds, and turn it so each mark faces its dock. Let red through the pane. The other bend wakes the hull.",
		"win": "The prism sits on the beam, and the hull stays asleep.",
		"cols": 6,
		"rows": 4,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 1, "E", "white")],
		"docks": [
			_dock("Bd", 0, 3, "blue"),
			_dock("Rd", 5, 3, "red"),
		],
		"boats": [_boat("H", 3, 0)],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["side", 5, 2], ["line", 3, 3]], "side", 0, "line", 180),
			_mirror("M", "Feed mirror", 3, 1, 0, 90),
			_pane("C", "Red pane", 4, 3, 90, 0),
		],
	}

static func chart_20() -> Dictionary:
	# Mirror rot 0 bends the east light north into prism rot 0. Red leaves
	# west and climbs through a red pane. Blue leaves east and climbs through
	# a blue pane. Mirror rot 90 sends the white beam south into the hull.
	# Prism rot 180 does not drink a northbound beam.
	return {
		"id": "20",
		"harbor": BASIN,
		"title": "The Twin Climb",
		"teach": "Bend the east light north into the prism. Red leaves west and has to climb through a red pane. Blue leaves east and has to climb through a blue pane. The other face of the lower mirror wakes the hull.",
		"win": "Both colors climb, and the hull stays asleep.",
		"cols": 5,
		"rows": 6,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 4, "E", "white")],
		"docks": [
			_dock("Rd", 2, 0, "red"),
			_dock("Bd", 4, 0, "blue"),
		],
		"boats": [_boat("B", 3, 5)],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Lower mirror", 3, 4, 90, 0),
			_prism("P", "Prism", [["a", 3, 2]], "a", 90, "a", 0),
			_mirror("Mr", "Red mirror", 2, 2, 0, 90),
			_mirror("Mb", "Blue mirror", 4, 2, 90, 0),
			_pane("Cr", "Red pane", 2, 1, 90, 0),
			_pane("Cb", "Blue pane", 4, 1, 0, 90),
		],
	}

static func chart_21() -> Dictionary:
	# The working socket is on the row high water covers. The side socket is
	# off the beam. rot 180 splits the southbound white beam. Low water wakes
	# the lower hull. Mirror rot 0 wakes the upper hull. Only the middle mark,
	# with the prism on the beam, clears.
	return {
		"id": "21",
		"harbor": BASIN,
		"title": "The Middle Socket",
		"teach": "Move the prism onto the row the mirror feeds, and turn it so each mark faces its dock. Let red through the pane. High water covers that row. Low water wakes the lower hull. Hold the middle mark.",
		"win": "The middle mark, the working socket, and dark hulls.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [0, 1, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 1, "E", "white"),
			_lantern("S", 0, 5, "E", "white"),
		],
		"docks": [
			_dock("Bd", 0, 4, "blue"),
			_dock("Rd", 5, 4, "red"),
		],
		"boats": [
			_boat("H", 3, 0),
			_boat("B", 4, 5),
		],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["side", 5, 2], ["line", 3, 4]], "side", 0, "line", 180),
			_mirror("M", "Feed mirror", 3, 1, 0, 90),
			_pane("C", "Red pane", 4, 4, 90, 0),
		],
	}

static func chart_22() -> Dictionary:
	# Capstone. The working socket is under the feed mirror. The side socket
	# never sees the beam. rot 180 splits southbound white: blue bends south
	# onto the low dock, red bends north through the pane. Low water lets the
	# bottom lantern wake the lower hull. High water covers the blue dock, so
	# red can still land while blue cannot. Feed mirror rot 0 wakes the upper
	# hull. Only the middle mark holds.
	return {
		"id": "22",
		"harbor": BASIN,
		"title": "The Basin Mark",
		"teach": "Move the prism onto the column under the mirror. Turn it so blue leaves west and red leaves east. Bend blue down onto the low dock. Bend red up through the pane. The other bend of the feed mirror wakes a hull. Low water wakes the lower hull. High water covers the low dock. Hold the middle mark.",
		"win": "Socket, color, and the middle mark. The basin holds.",
		"cols": 6,
		"rows": 7,
		"tide_phases": [0, 1, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 1, "E", "white"),
			_lantern("S", 0, 6, "E", "white"),
		],
		"docks": [
			_dock("Rd", 4, 0, "red"),
			_dock("Bd", 2, 5, "blue"),
		],
		"boats": [
			_boat("H", 3, 0),
			_boat("B", 5, 6),
		],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["side", 5, 3], ["line", 3, 4]], "side", 0, "line", 180),
			_mirror("Mf", "Feed mirror", 3, 1, 0, 90),
			_mirror("Mw", "Blue mirror", 2, 4, 90, 0),
			_mirror("Me", "Red mirror", 4, 4, 90, 0),
			_pane("Cr", "Red pane", 4, 2, 90, 0),
		],
	}

static func chart_23() -> Dictionary:
	# A lantern that already burns red. It is not white, so no prism is
	# involved. The lower mirror's "/" sends it north. The upper mirror's "/"
	# sends that northbound beam east through a red pane. The lower mirror's
	# "\" sends red south into the hull. A blue pane stops red.
	return {
		"id": "23",
		"harbor": PAINTED,
		"title": "Red Already",
		"teach": "This lantern already burns red. It is not white. Bend it north, then east, and turn the pane red so that color can pass. The other bend of the lower mirror wakes the hull.",
		"win": "Red crosses its own pane. The hull stays asleep.",
		"cols": 6,
		"rows": 3,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 1, "E", "red")],
		"docks": [_dock("Rd", 5, 0, "red")],
		"boats": [_boat("H", 2, 2)],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Lower mirror", 2, 1, 90, 0),
			_mirror("U", "Upper mirror", 2, 0, 90, 0),
			_pane("C", "Red pane", 4, 0, 90, 0),
		],
	}

static func chart_24() -> Dictionary:
	# The prism starts on the red lamp's row, so that beam is absorbed.
	# The working socket is one row up. Mirror rot 0 sends the eastbound
	# white beam north into prism rot 0: blue leaves east, red leaves west
	# off the board. Mirror rot 90 sends white south into the hull once the
	# prism has left the lower row. A blue pane stops the red lamp. Prism
	# rot 180 on the lower socket can feed the red dock from the split, but
	# blue then leaves west and never reaches the blue dock.
	return {
		"id": "24",
		"harbor": PAINTED,
		"title": "White Only",
		"teach": "A prism drinks white and nothing else. The red lamp dies if the prism sits on its row. Move the prism up, bend the white beam north into it, and turn it so blue leaves east. Leave the pane red. The other bend of the mirror wakes the hull.",
		"win": "The red lamp keeps its dock. Blue comes from the split.",
		"cols": 7,
		"rows": 5,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Lw", 0, 2, "E", "white"),
			_lantern("Lr", 0, 3, "E", "red"),
		],
		"docks": [
			_dock("Bd", 5, 1, "blue"),
			_dock("Rd", 6, 3, "red"),
		],
		"boats": [_boat("H", 2, 4)],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["line", 2, 3], ["high", 2, 1]], "line", 90, "high", 0),
			_mirror("M", "White mirror", 2, 2, 90, 0),
			_pane("C", "Red pane", 4, 3, 90, 0),
		],
	}

static func chart_25() -> Dictionary:
	# Set prism, rot 0, drinks northbound white: blue leaves east, red leaves
	# west through an empty cell. The red lamp bends north, then east through
	# a red pane. The lower red mirror's other face drops red into a hull.
	# The white mirror's other face drops white into a second hull.
	return {
		"id": "25",
		"harbor": PAINTED,
		"title": "The Side Lamp",
		"teach": "Bend the red lamp north, then east through the red pane. Bend the white beam north into the set prism so blue leaves east. Either wrong bend wakes a hull.",
		"win": "The lamp and the split each take a dock. Both hulls stay dark.",
		"cols": 7,
		"rows": 6,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Lr", 0, 1, "E", "red"),
			_lantern("Lw", 0, 4, "E", "white"),
		],
		"docks": [
			_dock("Rd", 6, 0, "red"),
			_dock("Bd", 6, 2, "blue"),
		],
		"boats": [
			_boat("H", 2, 3),
			_boat("B", 3, 5),
		],
		"fixtures": [
			_fixture("Px", "prism", 3, 2, 0),
		],
		"pieces": [
			_mirror("Mr", "Red mirror", 2, 1, 90, 0),
			_mirror("Mu", "Upper mirror", 2, 0, 90, 0),
			_pane("C", "Red pane", 4, 0, 90, 0),
			_mirror("Mw", "White mirror", 3, 4, 90, 0),
		],
	}

static func chart_26() -> Dictionary:
	# The lamp socket sits on the red beam after it has been bent east, so
	# the prism swallows that red. The high socket is where the white mirror
	# sends a northbound beam into rot 0. The lower red mirror's other face
	# reaches a hull. The white mirror's other face reaches the other hull.
	# A blue pane stops the lamp. The south face of a prism left on the lamp
	# row can feed the red dock, but its blue leaves west, away from the blue dock.
	return {
		"id": "26",
		"harbor": PAINTED,
		"title": "Off the Red Row",
		"teach": "Bend the red lamp north and east through the pane. Move the prism off that glass and down onto the white beam. Bend the white beam north, and turn the prism so blue leaves east. The other bend of either mirror wakes a hull.",
		"win": "The prism is off the lamp, and both docks take their color.",
		"cols": 7,
		"rows": 5,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Lr", 0, 1, "E", "red"),
			_lantern("Lw", 0, 3, "E", "white"),
		],
		"docks": [
			_dock("Rd", 5, 0, "red"),
			_dock("Bd", 5, 2, "blue"),
		],
		"boats": [
			_boat("B", 1, 4),
			_boat("H", 2, 4),
		],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["lamp", 2, 0], ["high", 2, 2]], "lamp", 90, "high", 0),
			_mirror("Mr", "Lower red mirror", 1, 1, 90, 0),
			_mirror("Mu", "Upper red mirror", 1, 0, 90, 0),
			_mirror("Mw", "White mirror", 2, 3, 90, 0),
			_pane("C", "Red pane", 3, 0, 90, 0),
		],
	}

static func chart_27() -> Dictionary:
	# The red lamp, its mirror, and nothing else of that path sit on the row
	# high water covers. The set prism is above that line and drinks a
	# northbound white beam. Low water lets the bottom lantern wake the hull.
	# The white mirror's other face hits the upper red mirror from the south
	# and never reaches the prism. Only the middle mark clears.
	return {
		"id": "27",
		"harbor": PAINTED,
		"title": "The Covered Lamp",
		"teach": "Bend the red lamp north, then east through the red pane. Bend white north into the set prism so blue leaves east. Low water wakes the hull. High water covers the red lamp. Hold the middle mark.",
		"win": "The middle mark holds the lamp and the split.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [0, 1, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("Lw", 0, 2, "E", "white"),
			_lantern("Lr", 0, 4, "E", "red"),
			_lantern("S", 0, 5, "E", "white"),
		],
		"docks": [
			_dock("Bd", 5, 1, "blue"),
			_dock("Rd", 5, 3, "red"),
		],
		"boats": [_boat("H", 2, 5)],
		"fixtures": [
			_fixture("Px", "prism", 2, 1, 0),
		],
		"pieces": [
			_mirror("Mw", "White mirror", 2, 2, 90, 0),
			_mirror("Mr", "Red mirror", 2, 4, 90, 0),
			_mirror("Mu", "Upper mirror", 2, 3, 90, 0),
			_pane("C", "Red pane", 4, 3, 90, 0),
		],
	}

static func chart_28() -> Dictionary:
	# South face. The lamp socket is on the red row, so the prism swallows
	# that beam. The working socket is under the mirror. Mirror rot 90 sends
	# white south into prism rot 180: blue leaves west, red leaves east
	# through a red pane. Mirror rot 0 wakes the upper hull. Without the
	# prism on the column, the southbound white beam wakes the lower hull.
	return {
		"id": "28",
		"harbor": PAINTED,
		"title": "The South Socket",
		"teach": "Move the prism off the red lamp and onto the column under the mirror. Turn the mirror south into it, and turn the prism so red leaves east and blue leaves west. Both panes stay red. The north bend wakes a hull.",
		"win": "The red lamp keeps its dock. The south face splits white.",
		"cols": 8,
		"rows": 6,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Lw", 0, 1, "E", "white"),
			_lantern("Lr", 0, 5, "E", "red"),
		],
		"docks": [
			_dock("Bd", 0, 3, "blue"),
			_dock("Rs", 7, 3, "red"),
			_dock("Rl", 6, 5, "red"),
		],
		"boats": [
			_boat("H", 3, 0),
			_boat("B", 3, 4),
		],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["line", 2, 5], ["south", 3, 3]], "line", 0, "south", 180),
			_mirror("Mw", "White mirror", 3, 1, 0, 90),
			_pane("Cr", "Split pane", 5, 3, 90, 0),
			_pane("Cp", "Lamp pane", 4, 5, 90, 0),
		],
	}

static func chart_29() -> Dictionary:
	# The working socket is on the row high water covers. The lamp socket is
	# on the dry red row, off the white column, so the two beams only cross
	# in an empty cell. Low water lets the bottom lantern wake the hull.
	# Mirror rot 0 wakes the upper hull. Only the middle mark, with the
	# prism on the south beam, clears.
	return {
		"id": "29",
		"harbor": PAINTED,
		"title": "The Dry Lamp",
		"teach": "Move the prism off the red lamp and down onto the column the mirror feeds. Turn that mirror south, and turn the prism so blue leaves west and red leaves east through the pane. Leave the lamp pane red. Low water wakes the hull. High water covers the lower glass. Hold the middle mark.",
		"win": "The lamp stays dry. The middle mark holds the split.",
		"cols": 8,
		"rows": 7,
		"tide_phases": [0, 1, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("Lw", 0, 1, "E", "white"),
			_lantern("Lr", 0, 3, "E", "red"),
			_lantern("S", 0, 6, "E", "white"),
		],
		"docks": [
			_dock("Rl", 6, 3, "red"),
			_dock("Bd", 0, 5, "blue"),
			_dock("Rs", 7, 5, "red"),
		],
		"boats": [
			_boat("H", 3, 0),
			_boat("B", 4, 6),
		],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["lamp", 2, 3], ["south", 3, 5]], "lamp", 90, "south", 180),
			_mirror("Mw", "White mirror", 3, 1, 0, 90),
			_pane("Cp", "Lamp pane", 4, 3, 90, 0),
			_pane("Cr", "Split pane", 5, 5, 90, 0),
		],
	}

static func chart_30() -> Dictionary:
	# Capstone. The lamp bends north, then east, and crosses the white column
	# in an empty cell. The prism's lamp socket swallows that red before the
	# bend. The working socket is on the row high water covers. Mirror rot 90
	# sends white south into prism rot 180: blue leaves west through a blue
	# pane, red leaves east through a red pane. The white mirror's other face
	# wakes the upper hull. The lamp mirror's other face wakes the side hull.
	# Low water lets the bottom lantern wake the lower hull. Only the middle
	# mark holds.
	return {
		"id": "30",
		"harbor": PAINTED,
		"title": "The Painted Mark",
		"teach": "Move the prism off the red lamp and onto the column under the mirror. Bend the lamp north, then east through the red pane. Bend white south into the prism. Blue leaves west through the blue pane. Red leaves east through the red pane. The other bend of either mirror wakes a hull. Low water wakes the lower hull. High water covers the prism row. Hold the middle mark.",
		"win": "Lamp, split, and the middle mark. The lock holds.",
		"cols": 8,
		"rows": 7,
		"tide_phases": [0, 1, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("Lw", 0, 1, "E", "white"),
			_lantern("Lr", 0, 3, "E", "red"),
			_lantern("S", 0, 6, "E", "white"),
		],
		"docks": [
			_dock("Rl", 6, 2, "red"),
			_dock("Bd", 0, 5, "blue"),
			_dock("Rs", 7, 5, "red"),
		],
		"boats": [
			_boat("H", 3, 0),
			_boat("R", 2, 4),
			_boat("B", 4, 6),
		],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["lamp", 1, 3], ["line", 3, 5]], "lamp", 90, "line", 180),
			_mirror("Mw", "White mirror", 3, 1, 0, 90),
			_mirror("Mr", "Lamp mirror", 2, 3, 90, 0),
			_mirror("Mu", "Upper mirror", 2, 2, 90, 0),
			_pane("Cp", "Lamp pane", 4, 2, 90, 0),
			_pane("Cb", "Blue pane", 1, 5, 0, 90),
			_pane("Cr", "Split pane", 5, 5, 90, 0),
		],
	}

static func chart_31() -> Dictionary:
	# West face. rot 270 drinks white traveling west: blue leaves north, red
	# leaves south. rot 0, 90, and 180 absorb that beam.
	return {
		"id": "31",
		"harbor": WEST,
		"title": "West Light",
		"teach": "This lantern shines west. Turn the prism so blue climbs to the blue dock and red falls to the red dock.",
		"win": "Blue climbs. Red falls.",
		"cols": 5,
		"rows": 5,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 4, 2, "W", "white")],
		"docks": [
			_dock("Bd", 2, 0, "blue"),
			_dock("Rd", 2, 4, "red"),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["a", 2, 2]], "a", 90, "a", 270),
		],
	}

static func chart_32() -> Dictionary:
	# Two mirrors fold an eastbound beam back west into a set prism at rot 270.
	# The first mirror's other face sends the beam north into the hull.
	# A single mirror cannot turn a beam around.
	return {
		"id": "32",
		"harbor": WEST,
		"title": "Bend West",
		"teach": "Two mirrors turn the east light around. The set prism drinks a beam coming back from the west. Blue climbs. Red falls. The other bend of the first mirror wakes the hull.",
		"win": "The east light comes back, and both docks take their color.",
		"cols": 5,
		"rows": 5,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 1, "E", "white")],
		"docks": [
			_dock("Bd", 1, 0, "blue"),
			_dock("Rd", 1, 4, "red"),
		],
		"boats": [_boat("H", 3, 0)],
		"fixtures": [
			_fixture("Px", "prism", 1, 3, 270),
		],
		"pieces": [
			_mirror("A", "First mirror", 3, 1, 0, 90),
			_mirror("B", "Second mirror", 3, 3, 90, 0),
		],
	}

static func chart_33() -> Dictionary:
	# Same fold as Bend West, with the prism and the red pane left for the
	# player. The upper mirror's other face wakes the hull. The east face of
	# the prism absorbs a westbound beam, so the colors cannot be swapped.
	return {
		"id": "33",
		"harbor": WEST,
		"title": "The Long Return",
		"teach": "Turn both mirrors so the east light comes back west. Turn the prism so blue climbs and red falls through the red pane. The other bend of the upper mirror wakes the hull.",
		"win": "The long return lands both colors, and the hull stays asleep.",
		"cols": 6,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 2, "E", "white")],
		"docks": [
			_dock("Bd", 2, 0, "blue"),
			_dock("Rd", 2, 6, "red"),
		],
		"boats": [_boat("H", 4, 0)],
		"fixtures": [],
		"pieces": [
			_mirror("A", "Upper mirror", 4, 2, 0, 90),
			_mirror("B", "Lower mirror", 4, 4, 90, 0),
			_prism("P", "Prism", [["a", 2, 4]], "a", 90, "a", 270),
			_pane("C", "Red pane", 2, 5, 90, 0),
		],
	}

static func chart_34() -> Dictionary:
	# The red lamp bends north, then east through a red pane. A separate white
	# beam folds south and west into prism rot 270. Each feed mirror's other
	# face wakes its own hull. The second mirrors, turned the other way, miss
	# their docks.
	return {
		"id": "34",
		"harbor": WEST,
		"title": "The Returning Lamp",
		"teach": "Bend the red lamp north, then east through the red pane. Bend the white beam south, then west into the prism, and turn it so blue climbs and red falls. The other bend of either feed mirror wakes a hull.",
		"win": "The lamp and the west face each take their docks.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Lr", 0, 1, "E", "red"),
			_lantern("Lw", 0, 3, "E", "white"),
		],
		"docks": [
			_dock("Rl", 6, 0, "red"),
			_dock("Bd", 3, 2, "blue"),
			_dock("Rw", 3, 6, "red"),
		],
		"boats": [
			_boat("Hr", 2, 2),
			_boat("Ha", 5, 2),
		],
		"fixtures": [],
		"pieces": [
			_mirror("Mr", "Lamp mirror", 2, 1, 90, 0),
			_mirror("Mu", "Upper mirror", 2, 0, 90, 0),
			_pane("Cp", "Lamp pane", 4, 0, 90, 0),
			_mirror("Ma", "White mirror", 5, 3, 0, 90),
			_mirror("Mb", "West mirror", 5, 5, 90, 0),
			_prism("P", "Prism", [["a", 3, 5]], "a", 90, "a", 270),
		],
	}

static func chart_35() -> Dictionary:
	# The lamp socket sits on the red beam after the pane, so the prism
	# swallows that red. The west socket is where the folded white beam
	# arrives. Either feed mirror's other face wakes a hull.
	return {
		"id": "35",
		"harbor": WEST,
		"title": "Off the West Row",
		"teach": "Move the prism off the red lamp. Bend the lamp north, then east through the red pane. Bend white south, then west into the prism, and turn it so blue climbs and red falls. The other bend of either feed mirror wakes a hull.",
		"win": "The prism is off the lamp, and the west face splits.",
		"cols": 8,
		"rows": 8,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Lr", 0, 1, "E", "red"),
			_lantern("Lw", 0, 3, "E", "white"),
		],
		"docks": [
			_dock("Rl", 6, 0, "red"),
			_dock("Bd", 4, 2, "blue"),
			_dock("Rw", 4, 7, "red"),
		],
		"boats": [
			_boat("Hr", 2, 2),
			_boat("Ha", 6, 2),
		],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["lamp", 5, 0], ["west", 4, 6]], "lamp", 90, "west", 270),
			_mirror("Mr", "Lamp mirror", 2, 1, 90, 0),
			_mirror("Mu", "Upper mirror", 2, 0, 90, 0),
			_pane("Cp", "Lamp pane", 4, 0, 90, 0),
			_mirror("Ma", "White mirror", 6, 3, 0, 90),
			_mirror("Mb", "West mirror", 6, 6, 90, 0),
		],
	}

static func chart_36() -> Dictionary:
	# The west prism and the mirror that turns the beam west sit on the row
	# high water covers. Red from that face falls into the flooded bottom row.
	# Blue climbs through a blue pane. Low water lets the bottom lantern wake
	# the lower hull. The red lamp stays above the tide.
	return {
		"id": "36",
		"harbor": WEST,
		"title": "The Covered Return",
		"teach": "Bend the red lamp north, then east through the red pane. Bend white south, then west into the prism, so blue climbs through the blue pane. Red from that face falls into the water. The other bend of either feed mirror wakes a hull. Low water wakes the lower hull. High water covers the prism row. Hold the middle mark.",
		"win": "The middle mark holds the lamp and the climbing blue.",
		"cols": 8,
		"rows": 7,
		"tide_phases": [0, 1, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("Lr", 0, 1, "E", "red"),
			_lantern("Lw", 0, 3, "E", "white"),
			_lantern("S", 0, 6, "E", "white"),
		],
		"docks": [
			_dock("Rl", 6, 0, "red"),
			_dock("Bd", 4, 2, "blue"),
		],
		"boats": [
			_boat("Hr", 2, 2),
			_boat("Ha", 6, 2),
			_boat("Hb", 3, 6),
		],
		"fixtures": [],
		"pieces": [
			_mirror("Mr", "Lamp mirror", 2, 1, 90, 0),
			_mirror("Mu", "Upper mirror", 2, 0, 90, 0),
			_pane("Cp", "Lamp pane", 4, 0, 90, 0),
			_mirror("Ma", "White mirror", 6, 3, 0, 90),
			_mirror("Mb", "West mirror", 6, 5, 90, 0),
			_prism("P", "Prism", [["a", 4, 5]], "a", 90, "a", 270),
			_pane("Cb", "Blue pane", 4, 4, 0, 90),
		],
	}

static func chart_37() -> Dictionary:
	# A set prism at rot 180 drinks the southbound white beam: blue leaves
	# west, red leaves east through a red pane. A second white beam folds
	# west into the player's prism at rot 270. The red lamp runs straight
	# through its own pane. Each feed mirror's other face wakes a hull.
	return {
		"id": "37",
		"harbor": WEST,
		"title": "The South Face",
		"teach": "Bend one white beam south into the set prism and let red through the pane. Blue from that face runs west. Bend the other white beam south, then west, and turn that prism so blue climbs and red falls. Leave the lamp pane red. The other bend of either feed mirror wakes a hull.",
		"win": "South face and west face, and the lamp keeps its dock.",
		"cols": 8,
		"rows": 9,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Ls", 0, 1, "E", "white"),
			_lantern("Lr", 0, 2, "E", "red"),
			_lantern("Lw", 0, 5, "E", "white"),
		],
		"docks": [
			_dock("Bs", 1, 4, "blue"),
			_dock("Rs", 6, 4, "red"),
			_dock("Rl", 7, 2, "red"),
			_dock("Bw", 4, 6, "blue"),
			_dock("Rw", 4, 8, "red"),
		],
		"boats": [
			_boat("Hs", 3, 0),
			_boat("Ha", 7, 4),
		],
		"fixtures": [
			_fixture("Fx", "prism", 3, 4, 180),
		],
		"pieces": [
			_mirror("Ms", "South mirror", 3, 1, 0, 90),
			_pane("Cs", "South pane", 5, 4, 90, 0),
			_mirror("Ma", "White mirror", 7, 5, 0, 90),
			_mirror("Mb", "West mirror", 7, 7, 90, 0),
			_prism("P", "West prism", [["a", 4, 7]], "a", 90, "a", 270),
			_pane("Cl", "Lamp pane", 5, 2, 90, 0),
		],
	}

static func chart_38() -> Dictionary:
	# Capstone. The lamp socket swallows the red lamp. The west socket is on
	# the row high water covers, so red from that face falls into the bottom
	# row and blue climbs to a dry dock. A set prism on the south door splits
	# the other white beam. Low water lets the bottom lantern wake the lower
	# hull. Only the middle mark, with the prism on the west beam, clears.
	return {
		"id": "38",
		"harbor": WEST,
		"title": "The Return Mark",
		"teach": "Move the prism off the red lamp and onto the returning beam. Leave the lamp pane red. Bend one white beam south into the set prism and let red through that pane. Bend the other white beam south, then west, so blue climbs. Red from the west face falls into the water. The other bend of either feed mirror wakes a hull. Low water wakes the lower hull. High water covers the west row. Hold the middle mark.",
		"win": "Lamp, south face, and the middle mark. The return holds.",
		"cols": 8,
		"rows": 9,
		"tide_phases": [0, 1, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("Ls", 0, 1, "E", "white"),
			_lantern("Lr", 0, 2, "E", "red"),
			_lantern("Lw", 0, 5, "E", "white"),
			_lantern("S", 0, 8, "E", "white"),
		],
		"docks": [
			_dock("Bs", 1, 4, "blue"),
			_dock("Rs", 6, 4, "red"),
			_dock("Rl", 7, 2, "red"),
			_dock("Bw", 4, 6, "blue"),
		],
		"boats": [
			_boat("Hs", 3, 0),
			_boat("Ha", 7, 4),
			_boat("Hb", 5, 8),
		],
		"fixtures": [
			_fixture("Fx", "prism", 3, 4, 180),
		],
		"pieces": [
			_prism("P", "Prism", [["lamp", 6, 2], ["west", 4, 7]], "lamp", 90, "west", 270),
			_mirror("Ms", "South mirror", 3, 1, 0, 90),
			_pane("Cs", "South pane", 5, 4, 90, 0),
			_mirror("Ma", "White mirror", 7, 5, 0, 90),
			_mirror("Mb", "West mirror", 7, 7, 90, 0),
			_pane("Cl", "Lamp pane", 5, 2, 90, 0),
		],
	}

static func make_state(chart: Dictionary, solved: bool) -> Dictionary:
	var pieces := {}
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		pieces[str(piece["id"])] = {
			"socket": str(piece["solution_socket"] if solved else piece["start_socket"]),
			"rot": int(piece["solution_rot"] if solved else piece["start_rot"]),
		}
	return {
		"tide_index": int(chart["solution_tide_index"] if solved else chart["start_tide_index"]),
		"pieces": pieces,
	}

static func duplicate_state(state: Dictionary) -> Dictionary:
	var pieces := {}
	var src: Dictionary = state["pieces"]
	for id in src.keys():
		var piece: Dictionary = src[id]
		pieces[str(id)] = {"socket": str(piece["socket"]), "rot": int(piece["rot"])}
	return {"tide_index": int(state["tide_index"]), "pieces": pieces}

static func piece_def(chart: Dictionary, id: String) -> Dictionary:
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		if str(piece["id"]) == id:
			return piece
	return {}

static func piece_cell(chart: Dictionary, state: Dictionary, id: String) -> Vector2i:
	var piece := piece_def(chart, id)
	if piece.is_empty():
		return Vector2i(-1, -1)
	var pst: Dictionary = state["pieces"][id]
	return _socket_cell(piece, str(pst["socket"]))

static func placement_errors(chart: Dictionary, state: Dictionary) -> Array:
	var errors: Array = []
	var seen := {}
	var cols := int(chart["cols"])
	var rows := int(chart["rows"])
	for raw in chart["obstacles"]:
		_note_cell(raw, "obstacle", cols, rows, seen, errors)
	for raw in chart["lanterns"]:
		var lantern: Dictionary = raw
		_note_cell(Vector2i(int(lantern["x"]), int(lantern["y"])), "lantern %s" % str(lantern["id"]), cols, rows, seen, errors)
	for raw in chart["docks"]:
		var dock: Dictionary = raw
		_note_cell(Vector2i(int(dock["x"]), int(dock["y"])), "dock %s" % str(dock["id"]), cols, rows, seen, errors)
	for raw in chart["boats"]:
		var boat: Dictionary = raw
		_note_cell(Vector2i(int(boat["x"]), int(boat["y"])), "boat %s" % str(boat["id"]), cols, rows, seen, errors)
	for raw in chart["fixtures"]:
		var fix: Dictionary = raw
		_note_cell(Vector2i(int(fix["x"]), int(fix["y"])), "fixture %s" % str(fix["id"]), cols, rows, seen, errors)
	for raw in chart["pieces"]:
		var piece: Dictionary = raw
		var id := str(piece["id"])
		_note_cell(piece_cell(chart, state, id), "piece %s" % id, cols, rows, seen, errors)
		var known := {}
		for sock_raw in piece["sockets"]:
			var sock: Dictionary = sock_raw
			known[str(sock["id"])] = true
		if not known.has(str(piece["start_socket"])):
			errors.append("%s missing start socket" % id)
		if not known.has(str(piece["solution_socket"])):
			errors.append("%s missing solution socket" % id)
	var phases: Array = chart["tide_phases"]
	if int(chart["start_tide_index"]) < 0 or int(chart["start_tide_index"]) >= phases.size():
		errors.append("start tide out of range")
	if int(chart["solution_tide_index"]) < 0 or int(chart["solution_tide_index"]) >= phases.size():
		errors.append("solution tide out of range")
	if int(state["tide_index"]) < 0 or int(state["tide_index"]) >= phases.size():
		errors.append("state tide out of range")
	return errors

static func _note_cell(cell: Vector2i, label: String, cols: int, rows: int, seen: Dictionary, errors: Array) -> void:
	if cell.x < 0 or cell.y < 0 or cell.x >= cols or cell.y >= rows:
		errors.append("%s out of bounds at %s" % [label, str(cell)])
		return
	var key := "%d,%d" % [cell.x, cell.y]
	if seen.has(key):
		errors.append("%s overlaps %s at %s" % [label, str(seen[key]), key])
	seen[key] = label

static func _socket_cell(piece: Dictionary, socket_id: String) -> Vector2i:
	for raw in piece["sockets"]:
		var sock: Dictionary = raw
		if str(sock["id"]) == socket_id:
			return Vector2i(int(sock["x"]), int(sock["y"]))
	return Vector2i(-1, -1)

static func _lantern(id: String, x: int, y: int, dir: String, color: String) -> Dictionary:
	return {"id": id, "x": x, "y": y, "dir": dir, "color": color}

static func _dock(id: String, x: int, y: int, color: String) -> Dictionary:
	return {"id": id, "x": x, "y": y, "color": color}

static func _boat(id: String, x: int, y: int) -> Dictionary:
	return {"id": id, "x": x, "y": y}

static func _fixture(id: String, kind: String, x: int, y: int, rot: int) -> Dictionary:
	return {"id": id, "kind": kind, "x": x, "y": y, "rot": rot}

static func _mirror(id: String, name: String, x: int, y: int, start_rot: int, sol_rot: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "mirror",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": start_rot,
		"solution_socket": "a",
		"solution_rot": sol_rot,
	}

static func _pane(id: String, name: String, x: int, y: int, start_rot: int, sol_rot: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "pane",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": start_rot,
		"solution_socket": "a",
		"solution_rot": sol_rot,
	}

static func _prism(id: String, name: String, sockets: Array, start_socket: String, start_rot: int, sol_socket: String, sol_rot: int) -> Dictionary:
	var packed: Array = []
	for raw in sockets:
		var spec: Array = raw
		packed.append({"id": str(spec[0]), "x": int(spec[1]), "y": int(spec[2])})
	return {
		"id": id,
		"name": name,
		"kind": "prism",
		"movable": packed.size() > 1,
		"sockets": packed,
		"start_socket": start_socket,
		"start_rot": start_rot,
		"solution_socket": sol_socket,
		"solution_rot": sol_rot,
	}
