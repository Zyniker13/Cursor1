extends RefCounted
class_name ChartBook

# South Lantern Quay holds six charts. North Glass Reach holds eight more.
# The Turning Basin holds the next eight. The Painted Lock holds eight more.
# The West Return holds eight more. The Meeting Glass holds eight more.
# The Tide Mirror holds eight more. The Shutter holds eight more.
# The Stain holds eight more. The Vane holds eight more.
# The Well holds eight more. The Siphon holds eight more.
# The Sluice holds eight more. The Weir holds eight more.
# The Lintel holds eight more. The Mullion holds eight more.
# The Transom holds eight more. The Casement holds eight more.
# The Jamb holds eight more. The Astragal holds eight more.
# The Scotia holds eight more. The Torus holds eight more.
# The Ogee holds the last eight.
# Piece rotations are degrees. Mirrors and panes use 0 or 90 (the other two
# facings repeat). Prisms use 0, 90, 180, and 270. A stain uses 0 for red and
# 90 for blue, and that number is a color, not a facing. A vane uses 0, 90,
# 180, and 270 for north, east, south, and west. A sluice uses those same
# four facings and keeps the color. A weir uses those same four facings and
# swaps red with blue. White stays white. A well has no facing.
# A siphon has no facing. Rotation is ignored.
# A lintel has no facing. Rotation is ignored. While its row is dry, a beam
# passes straight through in the same direction and the same color, and that
# pass costs no bounce. While that row is flooded, the beam stops at the
# waterline and does not enter.
# A mullion has no facing. Rotation is ignored. While its row is dry, a
# north-south beam passes straight through in the same direction and the same
# color, and that pass costs no bounce. An east-west beam stops and does not
# enter. While that row is flooded, every beam stops at the waterline.
# A transom has no facing. Rotation is ignored. While its row is dry, an
# east-west beam passes straight through in the same direction and the same
# color, and that pass costs no bounce. A north-south beam stops and does not
# enter. While that row is flooded, every beam stops at the waterline.
# A casement has a facing. Rotation changes it. While its row is dry, only a
# beam already traveling that way passes straight through in the same
# direction and the same color, and that pass costs no bounce. Every other
# direction stops and does not enter. While that row is flooded, every beam
# stops at the waterline.
# A jamb has a facing. Rotation changes it: 0 north, 90 east, 180 south,
# 270 west. While its row is dry, north or south opens the north-south axis
# and east or west opens the east-west axis. A beam on that axis passes
# straight through in the same direction and the same color, and that pass
# costs no bounce. The other axis stops and does not enter. While that row is
# flooded, every beam stops at the waterline.
# An astragal has a facing. Rotation changes it the same way: 0 north, 90 east,
# 180 south, 270 west. While its row is dry, the facing and the next clockwise
# direction pass straight through in the same direction and the same color,
# and that pass costs no bounce. The other two directions stop and do not
# enter. While that row is flooded, every beam stops at the waterline.
# A scotia has a facing. Rotation changes it the same way: 0 north, 90 east,
# 180 south, 270 west. While its row is dry, the facing and the next
# counterclockwise direction pass straight through in the same direction and
# the same color, and that pass costs no bounce. It does not turn, it does not
# recolor, and it does not split. The other two directions stop and do not
# enter. Facing north, the open directions are north and west. While that row
# is flooded, every beam stops at the waterline, the same way a flooded
# astragal stops. A north scotia is not a north astragal.
# A torus has a facing. Rotation changes it the same way: 0 north, 90 east,
# 180 south, 270 west. While its row is dry, the opposite of the facing and
# the next clockwise direction pass straight through in the same direction and
# the same color, and that pass costs no bounce. It does not turn, it does not
# recolor, and it does not split. The other two directions stop and do not
# enter. Facing north, the open directions are south and east, and the stopped
# directions are north and west. That is the pair a north scotia stops. While
# that row is flooded, every beam stops at the waterline, the same way a
# flooded scotia stops. A north torus is not a north scotia and not a north
# astragal. A casement passes only the facing. A jamb passes both directions
# on its open axis. A mullion passes north and south. A transom passes east
# and west. A lintel passes every dry direction.
# An ogee has a facing. Rotation changes it the same way: 0 north, 90 east,
# 180 south, 270 west. While its row is dry, the opposite of the facing and
# the next counterclockwise direction pass straight through in the same
# direction and the same color, and that pass costs no bounce. It does not
# turn, it does not recolor, and it does not split. The other two directions
# stop and do not enter. Facing north, the open directions are south and west,
# and the stopped directions are north and east. A north torus passes south
# and east, so a north ogee is not a north torus. While that row is flooded,
# every beam stops at the waterline, the same way a flooded torus stops.
# A casement passes only the facing. A jamb passes both directions on its open
# axis. A mullion passes north and south. A transom passes east and west. A
# lintel passes every dry direction.
# See BeamTracer.
#
# Every chart starts away from its solution: a wrong rotation, a wrong socket,
# or both. Tide index picks an entry of tide_phases, which is the count of
# flooded rows measured up from the bottom.

const HARBOR := "South Lantern Quay"
const REACH := "North Glass Reach"
const BASIN := "The Turning Basin"
const PAINTED := "The Painted Lock"
const WEST := "The West Return"
const MEET := "The Meeting Glass"
const TIDE := "The Tide Mirror"
const SHUTTER := "The Shutter"
const STAIN := "The Stain"
const VANE := "The Vane"
const WELL := "The Well"
const SIPHON := "The Siphon"
const SLUICE := "The Sluice"
const WEIR := "The Weir"
const LINTEL := "The Lintel"
const MULLION := "The Mullion"
const TRANSOM := "The Transom"
const CASEMENT := "The Casement"
const JAMB := "The Jamb"
const ASTRAGAL := "The Astragal"
const SCOTIA := "The Scotia"
const TORUS := "The Torus"
const OGEE := "The Ogee"

static func all() -> Array:
	var book: Array = []
	book.append_array(quay())
	book.append_array(reach())
	book.append_array(basin())
	book.append_array(painted())
	book.append_array(west())
	book.append_array(meet())
	book.append_array(tide())
	book.append_array(shutter())
	book.append_array(stain())
	book.append_array(vane())
	book.append_array(well())
	book.append_array(siphon())
	book.append_array(sluice())
	book.append_array(weir())
	book.append_array(lintel())
	book.append_array(mullion())
	book.append_array(transom())
	book.append_array(casement())
	book.append_array(jamb())
	book.append_array(astragal())
	book.append_array(scotia())
	book.append_array(torus())
	book.append_array(ogee())
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


static func meet() -> Array:
	return [chart_39(), chart_40(), chart_41(), chart_42(), chart_43(), chart_44(), chart_45(), chart_46()]


static func tide() -> Array:
	return [chart_47(), chart_48(), chart_49(), chart_50(), chart_51(), chart_52(), chart_53(), chart_54()]


static func shutter() -> Array:
	return [chart_55(), chart_56(), chart_57(), chart_58(), chart_59(), chart_60(), chart_61(), chart_62()]


static func stain() -> Array:
	return [chart_63(), chart_64(), chart_65(), chart_66(), chart_67(), chart_68(), chart_69(), chart_70()]


static func vane() -> Array:
	return [chart_71(), chart_72(), chart_73(), chart_74(), chart_75(), chart_76(), chart_77(), chart_78()]


static func well() -> Array:
	return [chart_79(), chart_80(), chart_81(), chart_82(), chart_83(), chart_84(), chart_85(), chart_86()]


static func siphon() -> Array:
	return [chart_87(), chart_88(), chart_89(), chart_90(), chart_91(), chart_92(), chart_93(), chart_94()]


static func sluice() -> Array:
	return [chart_95(), chart_96(), chart_97(), chart_98(), chart_99(), chart_100(), chart_101(), chart_102()]


static func weir() -> Array:
	return [chart_103(), chart_104(), chart_105(), chart_106(), chart_107(), chart_108(), chart_109(), chart_110()]


static func lintel() -> Array:
	return [chart_111(), chart_112(), chart_113(), chart_114(), chart_115(), chart_116(), chart_117(), chart_118()]


static func mullion() -> Array:
	return [chart_119(), chart_120(), chart_121(), chart_122(), chart_123(), chart_124(), chart_125(), chart_126()]


static func transom() -> Array:
	return [chart_127(), chart_128(), chart_129(), chart_130(), chart_131(), chart_132(), chart_133(), chart_134()]


static func casement() -> Array:
	return [chart_135(), chart_136(), chart_137(), chart_138(), chart_139(), chart_140(), chart_141(), chart_142()]


static func jamb() -> Array:
	return [chart_143(), chart_144(), chart_145(), chart_146(), chart_147(), chart_148(), chart_149(), chart_150()]


static func astragal() -> Array:
	return [chart_151(), chart_152(), chart_153(), chart_154(), chart_155(), chart_156(), chart_157(), chart_158()]


static func scotia() -> Array:
	return [chart_159(), chart_160(), chart_161(), chart_162(), chart_163(), chart_164(), chart_165(), chart_166()]


static func torus() -> Array:
	return [chart_167(), chart_168(), chart_169(), chart_170(), chart_171(), chart_172(), chart_173(), chart_174()]


static func ogee() -> Array:
	return [chart_175(), chart_176(), chart_177(), chart_178(), chart_179(), chart_180(), chart_181(), chart_182()]

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

static func chart_39() -> Dictionary:
	# One mirror, two arrivals. rot 0 ("/") sends eastbound red north and
	# northbound white east. rot 90 ("\") sends each beam back along the
	# other lamp's corridor, into that lamp, where the light stops.
	return {
		"id": "39",
		"harbor": MEET,
		"title": "Two Lamps",
		"teach": "One mirror can take two lamps. The red lamp comes from the west and the white lamp comes up from the south. Turn the mirror so red climbs and white runs east. The other face sends each beam into the other lamp.",
		"win": "Both lamps leave the one glass.",
		"cols": 5,
		"rows": 5,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Lr", 0, 2, "E", "red"),
			_lantern("Lw", 2, 4, "N", "white"),
		],
		"docks": [
			_dock("Rd", 2, 0, "red"),
			_dock("Dw", 4, 2, "white"),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Meeting mirror", 2, 2, 90, 0),
		],
	}

static func chart_40() -> Dictionary:
	# The meeting mirror preserves color. Red still has to pass a red pane.
	# White is still white, so only the set east face splits it: red climbs,
	# blue falls. A blue pane stops the red lamp and leaves the split.
	return {
		"id": "40",
		"harbor": MEET,
		"title": "Still White",
		"teach": "The meeting mirror turns both lamps and does not change their color. Red climbs through the red pane. White runs east, still white, into the set prism, so red climbs and blue falls. The other face sends each beam into the other lamp.",
		"win": "Red keeps its color. White splits on the set prism.",
		"cols": 6,
		"rows": 5,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Lr", 0, 2, "E", "red"),
			_lantern("Lw", 2, 4, "N", "white"),
		],
		"docks": [
			_dock("Rd", 2, 0, "red"),
			_dock("Rs", 4, 0, "red"),
			_dock("Bd", 4, 4, "blue"),
		],
		"boats": [],
		"fixtures": [
			_fixture("Px", "prism", 4, 2, 90),
		],
		"pieces": [
			_mirror("M", "Meeting mirror", 2, 2, 90, 0),
			_pane("C", "Red pane", 2, 1, 90, 0),
		],
	}

static func chart_41() -> Dictionary:
	# Same meeting as Two Lamps. The upper mirror's "/" sends the climbing
	# red east. Its "\" sends red west into the hull. The prism's east face
	# drinks the white beam. Any other face absorbs it.
	return {
		"id": "41",
		"harbor": MEET,
		"title": "The Joined Bend",
		"teach": "Turn the meeting mirror so red climbs and white runs east. Bend red east through the red pane. Turn the prism so red climbs and blue falls through the blue pane. The other bend of the upper mirror wakes the hull.",
		"win": "Both lamps bend, the split lands, and the hull stays asleep.",
		"cols": 7,
		"rows": 6,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Lr", 0, 2, "E", "red"),
			_lantern("Lw", 2, 5, "N", "white"),
		],
		"docks": [
			_dock("Rd", 6, 1, "red"),
			_dock("Rs", 5, 0, "red"),
			_dock("Bd", 5, 5, "blue"),
		],
		"boats": [
			_boat("H", 0, 1),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Meeting mirror", 2, 2, 90, 0),
			_mirror("U", "Upper mirror", 2, 1, 90, 0),
			_pane("C", "Red pane", 4, 1, 90, 0),
			_pane("Cb", "Blue pane", 5, 4, 0, 90),
			_prism("P", "Prism", [["a", 5, 2]], "a", 0, "a", 90),
		],
	}

static func chart_42() -> Dictionary:
	# The lamp socket sits on the red beam, so the prism swallows that red.
	# The line socket is where white leaves the meeting mirror. Only the east
	# face splits it. With the prism elsewhere, white runs on into the hull.
	return {
		"id": "42",
		"harbor": MEET,
		"title": "Off the Glass",
		"teach": "Move the prism off the red lamp and onto the white beam. Turn the meeting mirror so red climbs and white runs east. Bend red through the red pane, and turn the blue pane so blue can fall. The other bend of the upper mirror wakes a hull. White that misses the prism wakes the other hull.",
		"win": "The prism is off the lamp, and both colors leave the meeting glass.",
		"cols": 8,
		"rows": 6,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Lr", 0, 2, "E", "red"),
			_lantern("Lw", 2, 5, "N", "white"),
		],
		"docks": [
			_dock("Rd", 7, 1, "red"),
			_dock("Rs", 5, 0, "red"),
			_dock("Bd", 5, 5, "blue"),
		],
		"boats": [
			_boat("Hu", 0, 1),
			_boat("Hw", 7, 2),
		],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["lamp", 5, 1], ["line", 5, 2]], "lamp", 90, "line", 90),
			_mirror("M", "Meeting mirror", 2, 2, 90, 0),
			_mirror("U", "Upper mirror", 2, 1, 90, 0),
			_pane("Cp", "Lamp pane", 3, 1, 90, 0),
			_pane("Cb", "Blue pane", 5, 4, 0, 90),
		],
	}

static func chart_43() -> Dictionary:
	# The blue dock sits on the row high water covers. The bottom lantern
	# lights the lower hull whenever that row is dry. Red stays above the
	# tide. Only the middle mark clears.
	return {
		"id": "43",
		"harbor": MEET,
		"title": "The Covered Meeting",
		"teach": "Turn the meeting mirror so red climbs and white runs east. Bend red through the red pane. Turn the prism so blue falls through the blue pane. The other bend of the upper mirror wakes a hull. Low water wakes the lower hull. High water covers the blue dock. Hold the middle mark.",
		"win": "The middle mark holds the meeting and the split.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0, 1, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("Lr", 0, 2, "E", "red"),
			_lantern("Lw", 2, 4, "N", "white"),
			_lantern("S", 0, 6, "E", "white"),
		],
		"docks": [
			_dock("Rd", 6, 1, "red"),
			_dock("Rs", 5, 0, "red"),
			_dock("Bd", 5, 5, "blue"),
		],
		"boats": [
			_boat("Hu", 0, 1),
			_boat("Hb", 4, 6),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Meeting mirror", 2, 2, 90, 0),
			_mirror("U", "Upper mirror", 2, 1, 90, 0),
			_pane("Cp", "Lamp pane", 4, 1, 90, 0),
			_pane("Cb", "Blue pane", 5, 4, 0, 90),
			_prism("P", "Prism", [["a", 5, 2]], "a", 0, "a", 90),
		],
	}

static func chart_44() -> Dictionary:
	# White leaves the meeting mirror going east. Two more mirrors fold it
	# south and then west into prism rot 270: blue climbs, red falls. The east
	# face absorbs that returning beam. Each feed mirror's other face wakes a hull.
	return {
		"id": "44",
		"harbor": MEET,
		"title": "The West Meeting",
		"teach": "Turn the meeting mirror so red climbs and white runs east. Bend red east through the red pane. Fold white south, then west, and turn the prism so blue climbs and red falls. Leave each pane on its own color. The other bend of the upper mirror, the east mirror, or the west mirror wakes a hull.",
		"win": "The meeting feeds the west face, and the hulls stay asleep.",
		"cols": 8,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Lr", 0, 2, "E", "red"),
			_lantern("Lw", 2, 3, "N", "white"),
		],
		"docks": [
			_dock("Rd", 6, 1, "red"),
			_dock("Bd", 4, 0, "blue"),
			_dock("Rw", 4, 6, "red"),
		],
		"boats": [
			_boat("Hu", 0, 1),
			_boat("Ha", 5, 0),
			_boat("Hb", 7, 4),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Meeting mirror", 2, 2, 90, 0),
			_mirror("U", "Upper mirror", 2, 1, 90, 0),
			_pane("Cp", "Lamp pane", 3, 1, 90, 0),
			_mirror("A", "East mirror", 5, 2, 0, 90),
			_mirror("B", "West mirror", 5, 4, 90, 0),
			_prism("P", "West prism", [["a", 4, 4]], "a", 90, "a", 270),
			_pane("Cb", "Blue pane", 4, 3, 0, 90),
			_pane("Cr", "Red pane", 4, 5, 90, 0),
		],
	}

static func chart_45() -> Dictionary:
	# The lamp socket swallows the red lamp. The south socket drinks white
	# traveling south: rot 180 sends blue west and red east. The south mirror's
	# other face sends white north into a hull. Without the prism, white falls
	# on into the lower hull.
	return {
		"id": "45",
		"harbor": MEET,
		"title": "The South Meeting",
		"teach": "Move the prism off the red lamp and onto the column under the south mirror. Turn the meeting mirror so red climbs and white runs east. Bend red through the red pane. Turn the south mirror so white falls into the prism, and turn the prism so blue leaves west and red leaves east. The other bend of the upper mirror or the south mirror wakes a hull.",
		"win": "The prism is off the lamp. The south face splits.",
		"cols": 8,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Lr", 0, 2, "E", "red"),
			_lantern("Lw", 2, 5, "N", "white"),
		],
		"docks": [
			_dock("Rd", 7, 1, "red"),
			_dock("Bd", 3, 4, "blue"),
			_dock("Rs", 7, 4, "red"),
		],
		"boats": [
			_boat("Hu", 0, 1),
			_boat("Ha", 5, 0),
			_boat("Hb", 5, 6),
		],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["lamp", 4, 1], ["south", 5, 4]], "lamp", 90, "south", 180),
			_mirror("M", "Meeting mirror", 2, 2, 90, 0),
			_mirror("U", "Upper mirror", 2, 1, 90, 0),
			_pane("Cp", "Lamp pane", 3, 1, 90, 0),
			_mirror("S", "South mirror", 5, 2, 0, 90),
			_pane("Cb", "Blue pane", 4, 4, 0, 90),
			_pane("Cr", "Red pane", 6, 4, 90, 0),
		],
	}

static func chart_46() -> Dictionary:
	# Capstone. The lamp socket swallows the red lamp. The west socket is on
	# the row high water covers, so red from that face falls into the bottom
	# row and blue climbs to a dry dock. A set south face splits the other
	# white beam. Low water lets the bottom lantern wake the lower hull.
	# Only the middle mark, with the prism on the west beam, clears.
	return {
		"id": "46",
		"harbor": MEET,
		"title": "The Meeting Mark",
		"teach": "Move the prism off the red lamp and onto the returning beam. Turn the meeting mirror so red climbs and white runs east. Bend red east through the red pane. Fold white south, then west, so blue climbs through the blue pane. Red from that face falls into the water. Bend the other white beam south into the set prism. Blue leaves west through the blue pane. Red leaves east through the red pane. The other bend of the upper mirror, the east mirror, the west mirror, or the south mirror wakes a hull. Low water wakes the lower hull. High water covers the west row. Hold the middle mark.",
		"win": "Lamp, south face, west climb, and the middle mark. The meeting holds.",
		"cols": 8,
		"rows": 9,
		"tide_phases": [0, 1, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("Lr", 0, 2, "E", "red"),
			_lantern("Lw", 2, 3, "N", "white"),
			_lantern("Ls", 0, 4, "E", "white"),
			_lantern("S", 0, 8, "E", "white"),
		],
		"docks": [
			_dock("Rd", 7, 1, "red"),
			_dock("Bd", 4, 4, "blue"),
			_dock("Bs", 1, 5, "blue"),
			_dock("Rs", 7, 5, "red"),
		],
		"boats": [
			_boat("Hu", 0, 1),
			_boat("Ha", 6, 0),
			_boat("Hs", 3, 0),
			_boat("Hw", 2, 7),
			_boat("He", 7, 7),
			_boat("Hb", 6, 8),
		],
		"fixtures": [
			_fixture("Fx", "prism", 3, 5, 180),
		],
		"pieces": [
			_prism("P", "Prism", [["lamp", 5, 1], ["west", 4, 7]], "lamp", 90, "west", 270),
			_mirror("M", "Meeting mirror", 2, 2, 90, 0),
			_mirror("U", "Upper mirror", 2, 1, 90, 0),
			_mirror("A", "East mirror", 6, 2, 0, 90),
			_mirror("B", "West mirror", 6, 7, 90, 0),
			_mirror("Ms", "South mirror", 3, 4, 0, 90),
			_pane("Cp", "Lamp pane", 4, 1, 90, 0),
			_pane("Cb", "West pane", 4, 6, 0, 90),
			_pane("Cs", "South pane", 5, 5, 90, 0),
			_pane("Csb", "South blue pane", 2, 5, 0, 90),
		],
	}

static func chart_47() -> Dictionary:
	# Two tide mirrors on the bottom row. Flood 1 covers that row, so a
	# southbound beam reflects east, then north, onto the dock.
	# The first glass at rot 90 sends S east. The second at rot 0 sends E north.
	# While the row is dry both glasses pass a beam straight through: the upper
	# mirror's beam falls off the board, and the lower lamp reaches the hull.
	# The upper mirror's other face sends its beam north into the hull.
	return {
		"id": "47",
		"harbor": TIDE,
		"title": "Wet Glass",
		"teach": "A tide mirror reflects only while its own row is flooded. Turn the upper mirror so the beam falls, then turn the two tide mirrors so the beam runs east and climbs to the dock. On the wrong tide the row is dry: the beam passes straight through, the dock stays dark, and the lower lamp wakes the hull.",
		"win": "The flooded glass climbs to the dock.",
		"cols": 6,
		"rows": 5,
		"tide_phases": [0, 1],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 1, "E", "white"),
			_lantern("S", 0, 4, "E", "white"),
		],
		"docks": [
			_dock("D", 3, 3, "white"),
		],
		"boats": [
			_boat("Hm", 2, 0),
			_boat("Hb", 5, 4),
		],
		"fixtures": [],
		"pieces": [
			_tide_mirror("T", "Tide mirror", 2, 4, 0, 90),
			_tide_mirror("B", "East tide mirror", 3, 4, 90, 0),
			_mirror("M", "Upper mirror", 2, 1, 0, 90),
		],
	}

static func chart_48() -> Dictionary:
	# Same corner as Wet Glass, fed by a red lamp. Reflection keeps the color,
	# so only the red face of the pane lets the climb reach the dock.
	# A blue pane stops that red. Dry water passes the beam through, and the
	# lower lamp wakes the hull.
	return {
		"id": "48",
		"harbor": TIDE,
		"title": "Still Red",
		"teach": "The tide mirror does not change color. Red falls onto the flooded glass and is still red when it climbs through the red pane. The other face of the upper mirror wakes the hull. While the row is dry the beam passes straight through and the lower lamp wakes the hull.",
		"win": "Red climbs through its own pane.",
		"cols": 6,
		"rows": 5,
		"tide_phases": [0, 1],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 2, "E", "red"),
			_lantern("S", 0, 4, "E", "white"),
		],
		"docks": [
			_dock("Rd", 3, 0, "red"),
		],
		"boats": [
			_boat("Hm", 2, 0),
			_boat("Hb", 5, 4),
		],
		"fixtures": [],
		"pieces": [
			_tide_mirror("T", "Tide mirror", 2, 4, 0, 90),
			_tide_mirror("B", "East tide mirror", 3, 4, 90, 0),
			_mirror("M", "Upper mirror", 2, 2, 0, 90),
			_pane("C", "Red pane", 3, 3, 90, 0),
		],
	}

static func chart_49() -> Dictionary:
	# The climb is bent east by a normal mirror. rot 0 sends the northbound
	# beam east through the red pane. rot 90 sends it west into the hull.
	# The feed mirror's other face wakes the upper hull. Dry water wakes the
	# lower hull, because the tide mirrors pass the lower lamp straight through.
	return {
		"id": "49",
		"harbor": TIDE,
		"title": "The Wet Bend",
		"teach": "Turn the tide mirrors so red climbs, then bend it east through the red pane. The other bend of the upper mirror wakes a hull. While the row is dry the beam passes straight through and the lower lamp wakes the hull.",
		"win": "Red bends east, and the hulls stay asleep.",
		"cols": 7,
		"rows": 6,
		"tide_phases": [0, 1],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 3, "E", "red"),
			_lantern("S", 0, 5, "E", "white"),
		],
		"docks": [
			_dock("Rd", 6, 1, "red"),
		],
		"boats": [
			_boat("Hm", 2, 0),
			_boat("Hw", 0, 1),
			_boat("Hb", 5, 5),
		],
		"fixtures": [],
		"pieces": [
			_tide_mirror("T", "Tide mirror", 2, 5, 0, 90),
			_tide_mirror("B", "East tide mirror", 3, 5, 90, 0),
			_mirror("M", "Feed mirror", 2, 3, 0, 90),
			_mirror("N", "Upper mirror", 3, 1, 90, 0),
			_pane("C", "Red pane", 4, 1, 90, 0),
		],
	}

static func chart_50() -> Dictionary:
	# The side socket never sees the beam. On the line, rot 0 drinks the
	# northbound white beam: red leaves west, blue leaves east. Any other face
	# absorbs it. Without the prism, white runs on into the hull. Dry water
	# lets the lower lamp pass the tide mirrors and wake the lower hull.
	return {
		"id": "50",
		"harbor": TIDE,
		"title": "Off the Tide",
		"teach": "Move the prism onto the column the tide mirrors feed, and turn it so red leaves west and blue leaves east. The other bend of the feed mirror wakes a hull. White that misses the prism wakes the other hull. While the row is dry the beam passes straight through and the lower lamp wakes the hull.",
		"win": "The prism sits on the climb, and both docks take their color.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [0, 1],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 3, "E", "white"),
			_lantern("S", 0, 5, "E", "white"),
		],
		"docks": [
			_dock("Rd", 0, 2, "red"),
			_dock("Bd", 5, 2, "blue"),
		],
		"boats": [
			_boat("Hm", 2, 0),
			_boat("Hw", 3, 0),
			_boat("Hb", 5, 5),
		],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["side", 5, 4], ["line", 3, 2]], "side", 90, "line", 0),
			_tide_mirror("T", "Tide mirror", 2, 5, 0, 90),
			_tide_mirror("B", "East tide mirror", 3, 5, 90, 0),
			_mirror("M", "Feed mirror", 2, 3, 0, 90),
		],
	}

static func chart_51() -> Dictionary:
	# The dock sits on the row high water covers. Flood 1 leaves that row dry
	# and covers the tide mirrors, so the beam can reflect and still land.
	# Flood 2 covers the dock and the cell the feed beam has to cross.
	# Flood 0 lets the lower lamp pass straight through and wake the hull.
	return {
		"id": "51",
		"harbor": TIDE,
		"title": "The Clear Row",
		"teach": "Turn the tide mirrors so the beam runs east and climbs to the dock. The other bend of the feed mirror wakes a hull. Low water is the wrong tide: the row is dry, the beam passes straight through, and the lower lamp wakes the hull. High water covers the dock. Hold the middle mark.",
		"win": "The middle mark holds the climb.",
		"cols": 6,
		"rows": 7,
		"tide_phases": [0, 1, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 2, "E", "white"),
			_lantern("S", 0, 6, "E", "white"),
		],
		"docks": [
			_dock("D", 3, 5, "white"),
		],
		"boats": [
			_boat("Hm", 2, 0),
			_boat("Hb", 5, 6),
		],
		"fixtures": [],
		"pieces": [
			_tide_mirror("T", "Tide mirror", 2, 6, 0, 90),
			_tide_mirror("B", "East tide mirror", 3, 6, 90, 0),
			_mirror("M", "Feed mirror", 2, 2, 0, 90),
		],
	}

static func chart_52() -> Dictionary:
	# The second tide mirror sends white north into a mirror that turns it west.
	# Prism rot 270 drinks that westbound beam: blue climbs through the blue
	# pane, red falls onto the low dock. The east face absorbs the returning
	# beam. The other face of the feed mirror or the west mirror wakes a hull.
	return {
		"id": "52",
		"harbor": TIDE,
		"title": "The West Tide",
		"teach": "Turn the tide mirrors so white climbs, then bend it west into the prism. Blue climbs through the blue pane. Red falls to the low dock. The other bend of the feed mirror or the west mirror wakes a hull. While the row is dry the beam passes straight through and the lower lamp wakes the hull.",
		"win": "Blue climbs. Red falls. The hulls stay asleep.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0, 1],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 5, "E", "white"),
			_lantern("S", 0, 6, "E", "white"),
		],
		"docks": [
			_dock("Bd", 1, 0, "blue"),
			_dock("Rd", 1, 4, "red"),
		],
		"boats": [
			_boat("Hm", 2, 0),
			_boat("Ha", 6, 3),
			_boat("Hb", 5, 6),
		],
		"fixtures": [],
		"pieces": [
			_tide_mirror("T", "Tide mirror", 2, 6, 0, 90),
			_tide_mirror("B", "East tide mirror", 3, 6, 90, 0),
			_mirror("M", "Feed mirror", 2, 5, 0, 90),
			_mirror("A", "West mirror", 3, 3, 0, 90),
			_prism("P", "West prism", [["a", 1, 3]], "a", 90, "a", 270),
			_pane("Cb", "Blue pane", 1, 1, 0, 90),
		],
	}

static func chart_53() -> Dictionary:
	# White climbs into a mirror that sends it east, then a mirror that sends
	# it south into prism rot 180. Blue leaves west through the blue pane.
	# Red leaves east through the red pane. The other face of each of those
	# bends wakes a hull. Dry water lets the lower lamp pass straight through.
	return {
		"id": "53",
		"harbor": TIDE,
		"title": "The South Tide",
		"teach": "Turn the tide mirrors so white climbs. Bend it east, then south into the prism, so blue leaves west and red leaves east. Leave each pane on its own color. The other bend of the feed mirror, the east mirror, or the south mirror wakes a hull. While the row is dry the lower lamp wakes the hull.",
		"win": "Blue runs west. Red runs east. The hulls stay asleep.",
		"cols": 8,
		"rows": 7,
		"tide_phases": [0, 1],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 5, "E", "white"),
			_lantern("S", 0, 6, "E", "white"),
		],
		"docks": [
			_dock("Bd", 0, 4, "blue"),
			_dock("Rs", 7, 4, "red"),
		],
		"boats": [
			_boat("Hm", 2, 0),
			_boat("He", 0, 3),
			_boat("Hf", 5, 0),
			_boat("Hb", 6, 6),
		],
		"fixtures": [],
		"pieces": [
			_tide_mirror("T", "Tide mirror", 2, 6, 0, 90),
			_tide_mirror("B", "East tide mirror", 3, 6, 90, 0),
			_mirror("M", "Feed mirror", 2, 5, 0, 90),
			_mirror("E", "East mirror", 3, 3, 90, 0),
			_mirror("F", "South mirror", 5, 3, 0, 90),
			_prism("P", "South prism", [["a", 5, 4]], "a", 90, "a", 180),
			_pane("Cb", "Blue pane", 4, 4, 0, 90),
			_pane("Cr", "Red pane", 6, 4, 90, 0),
		],
	}

static func chart_54() -> Dictionary:
	# Capstone. The lamp socket swallows the red lamp. The west socket is on
	# the row high water covers: blue from that face climbs through the blue
	# pane, and red falls into the flooded bottom row. The tide mirrors sit on
	# the bottom row, so only the middle mark both floods them and leaves the
	# west row dry. Low water lets the lower lamp pass straight through and
	# wake the hull. Each feed mirror's other face wakes a hull of its own.
	return {
		"id": "54",
		"harbor": TIDE,
		"title": "The Tide Mark",
		"teach": "Move the prism off the red lamp and onto the returning beam. Bend the red lamp north, then east through the red pane. Turn the tide mirrors so white climbs, bend it east and south, then west, so blue climbs through the blue pane. Red from that face falls into the water. The other bend of the lamp mirror, the upper mirror, the feed mirror, the east mirror, the south mirror, or the west mirror wakes a hull. Low water wakes the lower hull. High water covers the west row. Hold the middle mark.",
		"win": "Lamp, west climb, and the middle mark. The tide holds.",
		"cols": 8,
		"rows": 8,
		"tide_phases": [0, 1, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("Lr", 0, 2, "E", "red"),
			_lantern("Lw", 0, 4, "E", "white"),
			_lantern("S", 0, 7, "E", "white"),
		],
		"docks": [
			_dock("Rl", 6, 1, "red"),
			_dock("Bd", 1, 3, "blue"),
		],
		"boats": [
			_boat("Hu", 0, 1),
			_boat("Hm", 2, 3),
			_boat("Ha", 5, 0),
			_boat("He", 7, 6),
			_boat("Hb", 6, 7),
		],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["lamp", 5, 1], ["west", 1, 6]], "lamp", 90, "west", 270),
			_mirror("Mr", "Lamp mirror", 2, 2, 90, 0),
			_mirror("Mu", "Upper mirror", 2, 1, 90, 0),
			_pane("Cp", "Lamp pane", 4, 1, 90, 0),
			_mirror("M", "Feed mirror", 2, 4, 0, 90),
			_tide_mirror("T", "Tide mirror", 2, 7, 0, 90),
			_tide_mirror("B", "East tide mirror", 3, 7, 90, 0),
			_mirror("A", "East mirror", 3, 5, 90, 0),
			_mirror("C", "South mirror", 5, 5, 0, 90),
			_mirror("D", "West mirror", 5, 6, 90, 0),
			_pane("Cb", "Blue pane", 1, 5, 0, 90),
		],
	}

static func chart_55() -> Dictionary:
	# Two shutters sit on the row above the tide mirrors. Flood 2 covers both
	# rows. The feed mirror sends the beam south into the first shutter. While
	# that row is flooded the shutter passes it, the tide mirrors turn it east
	# and north, and the second shutter lets it climb to the dock.
	# While the row is dry the first shutter stops the beam. The lower lamp
	# still passes the dry tide mirrors and wakes the hull.
	# A tide mirror cannot stand in for a shutter: under water it would turn
	# the beam instead of letting it continue.
	return {
		"id": "55",
		"harbor": SHUTTER,
		"title": "The Dry Gate",
		"teach": "A shutter stops a beam while its own row is dry. While that row is flooded, the beam passes straight through and keeps its color. It does not reflect. Turn the mirror so the beam falls, then turn the tide mirrors so the beam runs east and climbs through the second shutter to the dock. On the wrong tide the shutter is dry: the beam stops, the dock stays dark, and the lower lamp wakes the hull.",
		"win": "The open shutter lets the beam climb.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [0, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 1, "E", "white"),
			_lantern("S", 0, 5, "E", "white"),
		],
		"docks": [
			_dock("D", 3, 3, "white"),
		],
		"boats": [
			_boat("Hm", 2, 0),
			_boat("Hb", 5, 5),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 1, 0, 90),
			_shutter("G", "Shutter", 2, 4),
			_shutter("U", "Upper shutter", 3, 4),
			_tide_mirror("T", "Tide mirror", 2, 5, 0, 90),
			_tide_mirror("B", "East tide mirror", 3, 5, 90, 0),
		],
	}

static func chart_56() -> Dictionary:
	# Same gate as The Dry Gate, fed by a red lamp. The pass keeps the color,
	# so only the red face of the pane lets the climb reach the dock. A blue
	# pane stops that red. The shutter does not turn the beam aside.
	return {
		"id": "56",
		"harbor": SHUTTER,
		"title": "Straight Red",
		"teach": "The shutter does not change color, and it does not reflect. Red falls through the flooded shutter and is still red when it climbs through the red pane. A blue pane stops that red. The other face of the mirror wakes the hull. While the row is dry the shutter stops the beam.",
		"win": "Red climbs through its own pane.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [0, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 2, "E", "red"),
			_lantern("S", 0, 5, "E", "white"),
		],
		"docks": [
			_dock("Rd", 3, 1, "red"),
		],
		"boats": [
			_boat("Hm", 2, 0),
			_boat("Hb", 5, 5),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 2, 0, 90),
			_shutter("G", "Shutter", 2, 4),
			_shutter("U", "Upper shutter", 3, 4),
			_tide_mirror("T", "Tide mirror", 2, 5, 0, 90),
			_tide_mirror("B", "East tide mirror", 3, 5, 90, 0),
			_pane("C", "Red pane", 3, 2, 90, 0),
		],
	}

static func chart_57() -> Dictionary:
	# The climb comes back through the upper shutter, then a normal mirror
	# bends it east through a red pane. That mirror's other face sends the
	# beam west into a hull. Dry water stops the beam on the shutter, and the
	# lower lamp wakes the hull beyond the tide mirrors.
	return {
		"id": "57",
		"harbor": SHUTTER,
		"title": "The Open Bend",
		"teach": "Turn the tide mirrors and leave both shutters on the flooded row so red climbs, then bend it east through the red pane. The other bend of the upper mirror wakes a hull. While the row is dry the shutter stops the beam and the lower lamp wakes the hull.",
		"win": "Red bends east, and the hulls stay asleep.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 4, "E", "red"),
			_lantern("S", 0, 6, "E", "white"),
		],
		"docks": [
			_dock("Rd", 6, 2, "red"),
		],
		"boats": [
			_boat("Hm", 2, 0),
			_boat("Hw", 0, 2),
			_boat("Hb", 5, 6),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 4, 0, 90),
			_shutter("G", "Shutter", 2, 5),
			_shutter("U", "Upper shutter", 3, 5),
			_tide_mirror("T", "Tide mirror", 2, 6, 0, 90),
			_tide_mirror("B", "East tide mirror", 3, 6, 90, 0),
			_mirror("N", "Upper mirror", 3, 2, 90, 0),
			_pane("C", "Red pane", 5, 2, 90, 0),
		],
	}

static func chart_58() -> Dictionary:
	# The side socket never sees the climb. On the line, rot 0 drinks the
	# northbound white beam: red leaves west, blue leaves east. Any other face
	# absorbs it. Without the prism, white runs on into the hull. A dry shutter
	# stops the beam before the tide mirrors can turn it.
	return {
		"id": "58",
		"harbor": SHUTTER,
		"title": "Off the Gate",
		"teach": "Move the prism onto the column the shutters feed, and turn it so red leaves west and blue leaves east. The other bend of the feed mirror wakes a hull. White that misses the prism wakes the other hull. While the row is dry the shutter stops the beam and the lower lamp wakes the hull.",
		"win": "The prism sits on the climb, and both docks take their color.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 4, "E", "white"),
			_lantern("S", 0, 6, "E", "white"),
		],
		"docks": [
			_dock("Rd", 1, 2, "red"),
			_dock("Bd", 5, 2, "blue"),
		],
		"boats": [
			_boat("Hm", 2, 0),
			_boat("Hw", 3, 0),
			_boat("Hb", 5, 6),
		],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["side", 6, 3], ["line", 3, 2]], "side", 90, "line", 0),
			_mirror("M", "Feed mirror", 2, 4, 0, 90),
			_shutter("G", "Shutter", 2, 5),
			_shutter("U", "Upper shutter", 3, 5),
			_tide_mirror("T", "Tide mirror", 2, 6, 0, 90),
			_tide_mirror("B", "East tide mirror", 3, 6, 90, 0),
		],
	}

static func chart_59() -> Dictionary:
	# The dock sits on the row high water covers. Flood 2 leaves that row dry
	# and covers the shutters and the tide mirrors, so the beam can pass and
	# still land. Flood 3 covers the dock. Flood 0 stops the beam on the dry
	# shutter, and the lower lamp wakes the hull.
	return {
		"id": "59",
		"harbor": SHUTTER,
		"title": "The Held Gate",
		"teach": "Turn the tide mirrors so the beam climbs through the shutters to the dock. The other bend of the feed mirror wakes a hull. Low water is the wrong tide: the shutter is dry, the beam stops, and the lower lamp wakes the hull. High water covers the dock. Hold the middle mark.",
		"win": "The middle mark holds the open gate.",
		"cols": 6,
		"rows": 7,
		"tide_phases": [0, 2, 3],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 2, "E", "white"),
			_lantern("S", 0, 6, "E", "white"),
		],
		"docks": [
			_dock("D", 3, 4, "white"),
		],
		"boats": [
			_boat("Hm", 2, 0),
			_boat("Hb", 5, 6),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 2, 0, 90),
			_shutter("G", "Shutter", 2, 5),
			_shutter("U", "Upper shutter", 3, 5),
			_tide_mirror("T", "Tide mirror", 2, 6, 0, 90),
			_tide_mirror("B", "East tide mirror", 3, 6, 90, 0),
		],
	}

static func chart_60() -> Dictionary:
	# The gate returns white to a mirror that sends it west. Prism rot 270
	# drinks that westbound beam: blue climbs through the blue pane, red falls
	# onto the low dock. The east face absorbs the returning beam.
	return {
		"id": "60",
		"harbor": SHUTTER,
		"title": "The West Gate",
		"teach": "Turn the tide mirrors so white climbs through the shutters, then bend it west into the prism. Blue climbs through the blue pane. Red falls to the low dock. The other bend of the feed mirror or the west mirror wakes a hull. While the row is dry the shutter stops the beam and the lower lamp wakes the hull.",
		"win": "Blue climbs. Red falls. The hulls stay asleep.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 4, "E", "white"),
			_lantern("S", 0, 6, "E", "white"),
		],
		"docks": [
			_dock("Bd", 1, 0, "blue"),
			_dock("Rd", 1, 3, "red"),
		],
		"boats": [
			_boat("Hm", 2, 0),
			_boat("Ha", 5, 2),
			_boat("Hb", 5, 6),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 4, 0, 90),
			_shutter("G", "Shutter", 2, 5),
			_shutter("U", "Upper shutter", 3, 5),
			_tide_mirror("T", "Tide mirror", 2, 6, 0, 90),
			_tide_mirror("B", "East tide mirror", 3, 6, 90, 0),
			_mirror("A", "West mirror", 3, 2, 0, 90),
			_prism("P", "West prism", [["a", 1, 2]], "a", 90, "a", 270),
			_pane("Cb", "Blue pane", 1, 1, 0, 90),
		],
	}

static func chart_61() -> Dictionary:
	# White climbs through the gate into a mirror that sends it east, then a
	# mirror that sends it south into prism rot 180. Blue leaves west through
	# the blue pane. Red leaves east through the red pane.
	return {
		"id": "61",
		"harbor": SHUTTER,
		"title": "The South Gate",
		"teach": "Turn the tide mirrors so white climbs through the shutters. Bend it east, then south into the prism, so blue leaves west and red leaves east. Leave each pane on its own color. The other bend of the feed mirror, the east mirror, or the south mirror wakes a hull. While the row is dry the shutter stops the beam and the lower lamp wakes the hull.",
		"win": "Blue runs west. Red runs east. The hulls stay asleep.",
		"cols": 8,
		"rows": 7,
		"tide_phases": [0, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 4, "E", "white"),
			_lantern("S", 0, 6, "E", "white"),
		],
		"docks": [
			_dock("Bd", 0, 3, "blue"),
			_dock("Rs", 7, 3, "red"),
		],
		"boats": [
			_boat("Hm", 2, 0),
			_boat("He", 0, 2),
			_boat("Hf", 5, 0),
			_boat("Hb", 6, 6),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 4, 0, 90),
			_shutter("G", "Shutter", 2, 5),
			_shutter("U", "Upper shutter", 3, 5),
			_tide_mirror("T", "Tide mirror", 2, 6, 0, 90),
			_tide_mirror("B", "East tide mirror", 3, 6, 90, 0),
			_mirror("E", "East mirror", 3, 2, 90, 0),
			_mirror("F", "South mirror", 5, 2, 0, 90),
			_prism("P", "South prism", [["a", 5, 3]], "a", 90, "a", 180),
			_pane("Cb", "Blue pane", 4, 3, 0, 90),
			_pane("Cr", "Red pane", 6, 3, 90, 0),
		],
	}

static func chart_62() -> Dictionary:
	# Capstone. The lamp socket swallows the red lamp. The west socket sits on
	# the row high water covers: blue from that face climbs through the blue
	# pane, and red falls into the flooded gate row. The shutters sit above
	# the tide mirrors, so only the middle mark both floods them and leaves
	# the west row dry. Low water stops the white beam on the dry shutter and
	# lets the lower lamp wake the hull.
	return {
		"id": "62",
		"harbor": SHUTTER,
		"title": "The Shutter Mark",
		"teach": "Move the prism off the red lamp and onto the west row. Bend the red lamp north, then east through the red pane. Turn the tide mirrors so white falls through the shutters, runs east, and comes back west, so blue climbs through the blue pane. Red from that face falls into the water. The other bend of the lamp mirror, the upper mirror, the feed mirror, the east mirror, the south mirror, or the west mirror wakes a hull. Low water stops the beam on the dry shutter and wakes the lower hull. High water covers the west row. Hold the middle mark.",
		"win": "Lamp, west climb, and the middle mark. The gate holds.",
		"cols": 9,
		"rows": 8,
		"tide_phases": [0, 2, 3],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("Lr", 0, 2, "E", "red"),
			_lantern("Lw", 1, 4, "E", "white"),
			_lantern("S", 6, 7, "E", "white"),
		],
		"docks": [
			_dock("Rl", 6, 1, "red"),
			_dock("Bd", 0, 3, "blue"),
		],
		"boats": [
			_boat("Hu", 1, 1),
			_boat("Hm", 2, 3),
			_boat("Hw", 4, 3),
			_boat("Ha", 7, 0),
			_boat("He", 8, 5),
			_boat("Hb", 8, 7),
		],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["lamp", 5, 1], ["west", 0, 5]], "lamp", 90, "west", 270),
			_mirror("Mr", "Lamp mirror", 2, 2, 90, 0),
			_mirror("Mu", "Upper mirror", 2, 1, 90, 0),
			_pane("Cp", "Lamp pane", 4, 1, 90, 0),
			_mirror("M", "Feed mirror", 4, 4, 0, 90),
			_shutter("G", "Shutter", 4, 6),
			_shutter("U", "Upper shutter", 5, 6),
			_tide_mirror("T", "Tide mirror", 4, 7, 0, 90),
			_tide_mirror("B", "East tide mirror", 5, 7, 90, 0),
			_mirror("H", "East mirror", 5, 3, 90, 0),
			_mirror("F", "South mirror", 7, 3, 0, 90),
			_mirror("D", "West mirror", 7, 5, 90, 0),
			_pane("Cb", "Blue pane", 0, 4, 0, 90),
		],
	}

static func chart_63() -> Dictionary:
	# White runs east through a stain onto a red dock. Red leaves red and
	# keeps the same direction. Blue leaves blue, so the dock fails. A pane
	# would stop the white beam. A prism would split it instead of passing
	# one red beam straight through.
	return {
		"id": "63",
		"harbor": STAIN,
		"title": "The Red Stain",
		"teach": "A stain has a color, red or blue, and no facing. A beam that hits it keeps going straight, and the beam's color becomes the stain's color. White becomes red. It does not split, and it does not reflect. Click the stain so it is red. Swapping it to blue fails the dock. A pane stops white instead of turning it red. A prism splits white and does not pass one red beam straight through.",
		"win": "White leaves the stain as red.",
		"cols": 5,
		"rows": 3,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 1, "E", "white")],
		"docks": [_dock("D", 4, 1, "red")],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_stain("K", "Stain", 2, 1, 90, 0),
		],
	}

static func chart_64() -> Dictionary:
	# The stain sits on a dry row and the dock is the first flooded cell at
	# the high mark. Dry recolors white to red and lands. High water covers
	# the dock. A shutter in the stain's cell would stop the dry beam.
	return {
		"id": "64",
		"harbor": STAIN,
		"title": "Dry Color",
		"teach": "The stain recolors the beam while its own row is dry. White becomes red and runs south onto the red dock. A shutter in that cell would stop the beam. Raise the tide and the dock is under water, so the recolored beam dies on the waterline. Hold the dry mark.",
		"win": "The dry stain turns the beam red.",
		"cols": 5,
		"rows": 4,
		"tide_phases": [0, 2],
		"start_tide_index": 1,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 2, 0, "S", "white")],
		"docks": [_dock("Rd", 2, 2, "red")],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_stain("K", "Stain", 2, 1, 90, 0),
		],
	}

static func chart_65() -> Dictionary:
	# Blue becomes red at the stain, then the red pane lets it through.
	# Left blue, that same pane stops the beam. A blue pane would pass the
	# unclicked stain and still miss the red dock.
	return {
		"id": "65",
		"harbor": STAIN,
		"title": "Blue to Red",
		"teach": "A blue beam hits the stain and leaves red, then passes the red pane. Left blue, the red pane stops it. The stain does not split the beam, and it does not reflect.",
		"win": "Blue goes in. Red comes out.",
		"cols": 6,
		"rows": 3,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 1, "E", "blue")],
		"docks": [_dock("Rd", 5, 1, "red")],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_stain("K", "Stain", 2, 1, 90, 0),
			_pane("C", "Red pane", 3, 1, 0, 0),
		],
	}

static func chart_66() -> Dictionary:
	# The stain starts blue. One click makes it red, and the mirror's "/"
	# sends that red north onto the dock. The other face of the mirror sends
	# the beam south into the hull. Leaving the stain blue fails the dock.
	return {
		"id": "66",
		"harbor": STAIN,
		"title": "The Swap",
		"teach": "The stain starts blue. Click it to red. The beam keeps going straight, and the mirror turns that red onto the dock. The unclicked stain leaves blue on the dock. The other face of the mirror wakes the hull.",
		"win": "The stain is red, and the dock takes it.",
		"cols": 5,
		"rows": 4,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 2, "E", "white")],
		"docks": [_dock("Rd", 4, 0, "red")],
		"boats": [_boat("Hm", 4, 3)],
		"fixtures": [],
		"pieces": [
			_stain("K", "Stain", 2, 2, 90, 0),
			_mirror("M", "Mirror", 4, 2, 90, 0),
		],
	}

static func chart_67() -> Dictionary:
	# Prism rot 90 drinks the eastbound white beam. Red climbs to the north
	# dock. Blue falls into the stain, which must be red so the south dock
	# takes red. Any other prism face absorbs the beam. Leaving the stain
	# blue satisfies the north dock and misses the south one.
	return {
		"id": "67",
		"harbor": STAIN,
		"title": "One Color",
		"teach": "The prism splits white. Red climbs to the red dock. Blue falls through the stain, which turns it red for the lower dock. Leaving the stain unclicked leaves that dock blue. The other faces of the prism absorb the beam.",
		"win": "Both docks take red. The stain did the second one.",
		"cols": 5,
		"rows": 5,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 2, "E", "white")],
		"docks": [
			_dock("Rn", 2, 0, "red"),
			_dock("Rs", 2, 4, "red"),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["a", 2, 2]], "a", 0, "a", 90),
			_stain("K", "Stain", 2, 3, 90, 0),
		],
	}

static func chart_68() -> Dictionary:
	# Flood 2 opens the shutter. White falls through it, the tide mirrors
	# turn it, and the stain on the flooded row makes it red before the
	# climb. Dry water stops on the shutter and the lower lamp wakes the
	# hull. A shutter in the stain's cell would pass white and miss.
	return {
		"id": "68",
		"harbor": STAIN,
		"title": "After the Gate",
		"teach": "A shutter stops the beam while its row is dry. Raise the tide and the shutter lets the beam through. The stain beyond it turns white into red. The shutter alone would deliver white and miss the red dock. The other bend of the feed mirror wakes a hull. While the row is dry the shutter stops the beam and the lower lamp wakes the hull.",
		"win": "The gate opens, and the stain turns the beam red.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [0, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 2, "E", "white"),
			_lantern("S", 0, 5, "E", "white"),
		],
		"docks": [_dock("Rd", 4, 2, "red")],
		"boats": [
			_boat("Hm", 2, 0),
			_boat("Hb", 5, 5),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 2, 0, 90),
			_shutter("G", "Shutter", 2, 4),
			_tide_mirror("T", "Tide mirror", 2, 5, 0, 90),
			_stain("K", "Stain", 3, 5, 90, 0),
			_tide_mirror("B", "East tide mirror", 4, 5, 90, 0),
			_shutter("U", "Upper shutter", 4, 4),
		],
	}

static func chart_69() -> Dictionary:
	# Phases 0, 2, and 3. Flood 2 covers the shutter, the stain, and the tide
	# mirrors, and leaves the dock dry. Flood 3 covers the dock. Flood 0
	# stops on the dry shutter and the lower lamp wakes the hull. The stain
	# is under water at the middle mark and still recolors.
	return {
		"id": "69",
		"harbor": STAIN,
		"title": "The Held Stain",
		"teach": "Turn the tide mirrors so white falls through the shutter, and the stain on the flooded row turns it red before it climbs to the dock. Low water is the wrong tide: the shutter is dry, the beam stops, and the lower lamp wakes the hull. High water covers the dock. The stain still recolors at the middle mark. Hold the middle mark.",
		"win": "The middle mark holds, and the stain still colors the beam.",
		"cols": 6,
		"rows": 7,
		"tide_phases": [0, 2, 3],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 2, "E", "white"),
			_lantern("S", 0, 6, "E", "white"),
		],
		"docks": [_dock("Rd", 4, 4, "red")],
		"boats": [
			_boat("Hm", 2, 0),
			_boat("Hb", 5, 6),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 2, 0, 90),
			_shutter("G", "Shutter", 2, 5),
			_tide_mirror("T", "Tide mirror", 2, 6, 0, 90),
			_stain("K", "Stain", 3, 6, 90, 0),
			_tide_mirror("B", "East tide mirror", 4, 6, 90, 0),
			_shutter("U", "Upper shutter", 4, 5),
		],
	}

static func chart_70() -> Dictionary:
	# The side socket lets white run into a hull. On the line, prism rot 90
	# sends red north and blue south through the gate. The stain must be
	# clicked to red so the lower dock takes red. Only the middle mark both
	# opens the shutter and leaves that dock dry.
	return {
		"id": "70",
		"harbor": STAIN,
		"title": "The Stain Mark",
		"teach": "Move the prism onto the white beam so red climbs and blue falls through the shutter. Click the stain so that blue becomes red before it climbs to the lower dock. The other socket lets white wake the hull. The other faces of the prism absorb the beam. Low water is the wrong tide: the shutter is dry and the lower lamp wakes the hull. High water covers the lower dock. Hold the middle mark.",
		"win": "Prism, stain, and the middle mark. The color holds.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0, 2, 3],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 2, "E", "white"),
			_lantern("S", 0, 6, "E", "white"),
		],
		"docks": [
			_dock("Rn", 2, 0, "red"),
			_dock("Rs", 4, 4, "red"),
		],
		"boats": [
			_boat("Hw", 6, 2),
			_boat("Hb", 6, 6),
		],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["side", 5, 0], ["line", 2, 2]], "side", 0, "line", 90),
			_shutter("G", "Shutter", 2, 5),
			_tide_mirror("T", "Tide mirror", 2, 6, 0, 90),
			_stain("K", "Stain", 3, 6, 90, 0),
			_tide_mirror("B", "East tide mirror", 4, 6, 90, 0),
			_shutter("U", "Upper shutter", 4, 5),
		],
	}

static func chart_71() -> Dictionary:
	# A northbound beam meets the vane. East sends it onto the dock.
	# North passes straight into the upper hull. West sends it into the
	# side hull. South is head-on, so the beam stops. A stain would keep
	# going north and would not make the east turn.
	return {
		"id": "71",
		"harbor": VANE,
		"title": "The East Vane",
		"teach": "A vane has a facing: east, south, west, or north. Click it and the facing turns clockwise. It does not recolor, and it does not split. A beam going north hits this vane faced east and leaves east onto the dock, still white. Faced north, the same beam passes north and wakes the hull. Faced west, it leaves west and wakes the other hull. Faced south, the beam is head-on and stops. A stain cannot replace it, because a stain does not turn the beam.",
		"win": "The east vane lands the beam.",
		"cols": 5,
		"rows": 4,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 2, 3, "N", "white")],
		"docks": [_dock("D", 4, 2, "white")],
		"boats": [
			_boat("Hn", 2, 0),
			_boat("Hw", 0, 2),
		],
		"fixtures": [],
		"pieces": [
			_vane("V", "Vane", 2, 2, 0, 90),
		],
	}

static func chart_72() -> Dictionary:
	# The stain must be red. The vane then turns that red beam north.
	# Left facing east, the vane is aligned with the beam and the dock
	# stays dark. Left facing south, the beam wakes the hull.
	return {
		"id": "72",
		"harbor": VANE,
		"title": "After the Color",
		"teach": "A stain turns the white beam red, then the vane turns that red beam north onto the red dock. The color stays red. Leaving the vane unrotated, faced east, the beam passes straight and misses the dock. Faced south, it wakes the hull.",
		"win": "Red leaves the vane and the dock takes it.",
		"cols": 5,
		"rows": 5,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 2, "E", "white")],
		"docks": [_dock("Rd", 3, 0, "red")],
		"boats": [_boat("Hs", 3, 4)],
		"fixtures": [],
		"pieces": [
			_stain("K", "Stain", 2, 2, 90, 0),
			_vane("V", "Vane", 3, 2, 90, 0),
		],
	}

static func chart_73() -> Dictionary:
	# Dry is the solution. The southbound beam turns east onto the dock.
	# Flood covers the vane's row, so the beam stops at the waterline.
	# A shutter in that cell would stop while dry and open under water.
	return {
		"id": "73",
		"harbor": VANE,
		"title": "Dry Turn",
		"teach": "The vane turns the beam on the dry phase, and that dry phase is the solution. The beam comes south, the vane faces east, and the dock takes it. Flood shuts the vane: the beam stops at the waterline and does not enter the cell. A shutter cannot replace it. A shutter does not turn the beam, so while the row is dry it stops, and under water it opens and lets the beam pass. The vane stays shut under water.",
		"win": "The dry turn holds.",
		"cols": 5,
		"rows": 5,
		"tide_phases": [0, 2],
		"start_tide_index": 1,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 2, 1, "S", "white")],
		"docks": [_dock("D", 4, 3, "white")],
		"boats": [_boat("Hs", 2, 4)],
		"fixtures": [],
		"pieces": [
			_vane("V", "Vane", 2, 3, 0, 90),
		],
	}

static func chart_74() -> Dictionary:
	# Two side entries must both leave east. A mirror sends them opposite
	# ways, so one of them wakes the west hull no matter which way it faces.
	# The vane starts on west. Quarter turns walk it to north, then east.
	return {
		"id": "74",
		"harbor": VANE,
		"title": "The Quarter",
		"teach": "The vane starts facing west. Click it until it faces east. The unclicked vane sends both beams into the hull. A beam from the south and a beam from the north both leave east: the entry does not pick the exit, the facing does. A mirror cannot replace it. A mirror's exit depends on the entry, and a mirror has only two facings, so each mirror facing turns one of these beams into the hull.",
		"win": "Both beams leave east.",
		"cols": 5,
		"rows": 5,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Ls", 2, 4, "N", "white"),
			_lantern("Ln", 2, 0, "S", "white"),
		],
		"docks": [_dock("D", 4, 2, "white")],
		"boats": [_boat("Hw", 0, 2)],
		"fixtures": [],
		"pieces": [
			_vane("V", "Vane", 2, 2, 270, 90),
		],
	}

static func chart_75() -> Dictionary:
	# The straight shot wakes the hull. South, then east, walks the beam
	# under the hull and into the dock. Either vane left on its start
	# facing misses.
	return {
		"id": "75",
		"harbor": VANE,
		"title": "Two Bends",
		"teach": "Two vanes turn one beam around the hull and into the dock. The first faces south. The second faces east. Either vane left unrotated misses: the first, left facing east, wakes the hull, and the second, left facing north, stops the beam.",
		"win": "The beam clears the hull.",
		"cols": 6,
		"rows": 5,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 2, "E", "white")],
		"docks": [_dock("D", 5, 4, "white")],
		"boats": [_boat("H", 4, 2)],
		"fixtures": [],
		"pieces": [
			_vane("V1", "First vane", 2, 2, 90, 180),
			_vane("V2", "Second vane", 2, 4, 0, 90),
		],
	}

static func chart_76() -> Dictionary:
	# Flood 2 opens the shutters and the tide mirrors. The vane sits on the
	# dry row above that water and turns the climb east. Low water stops on
	# the dry shutter, and the lower lamp wakes the hull. A vane moved onto
	# the flooded climb would be shut.
	return {
		"id": "76",
		"harbor": VANE,
		"title": "Above the Gate",
		"teach": "A shutter stops the beam while its row is dry. Raise the tide and the shutter lets the beam through. A vane on the dry row above the water turns that beam onto the dock. A vane placed on the flooded row would be shut, and the beam would stop at the waterline. The other bend of the feed mirror wakes a hull. While the row is dry the shutter stops the beam and the lower lamp wakes the hull. Leaving the vane facing north wakes the hull above it.",
		"win": "The gate opens, and the vane above it turns the beam.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [0, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 2, "E", "white"),
			_lantern("S", 0, 5, "E", "white"),
		],
		"docks": [_dock("D", 5, 3, "white")],
		"boats": [
			_boat("Hm", 2, 0),
			_boat("Ha", 3, 0),
			_boat("Hb", 5, 5),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 2, 0, 90),
			_shutter("G", "Shutter", 2, 4),
			_tide_mirror("T", "Tide mirror", 2, 5, 0, 90),
			_tide_mirror("B", "East tide mirror", 3, 5, 90, 0),
			_shutter("U", "Upper shutter", 3, 4),
			_vane("V", "Vane", 3, 3, 0, 90),
		],
	}

static func chart_77() -> Dictionary:
	# Phases 0, 2, and 3. Flood 2 leaves row 4 dry, so the vane there still
	# turns. Flood 3 covers that row and the dock. Flood 0 stops on the dry
	# shutter and the lower lamp wakes the hull.
	return {
		"id": "77",
		"harbor": VANE,
		"title": "The Held Vane",
		"teach": "Phases are low water, the middle mark, and high water. The solution is the middle mark. Low water is the wrong tide: the shutter is dry, the beam stops, and the lower lamp wakes the hull. High water covers the dock. The vane on the dry row still turns the beam at the middle mark. Leaving it facing north wakes the hull. The other bend of the feed mirror wakes a hull. Hold the middle mark.",
		"win": "The middle mark holds, and the vane still turns the beam.",
		"cols": 6,
		"rows": 7,
		"tide_phases": [0, 2, 3],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 2, "E", "white"),
			_lantern("S", 0, 6, "E", "white"),
		],
		"docks": [_dock("D", 5, 4, "white")],
		"boats": [
			_boat("Hm", 2, 0),
			_boat("Ha", 3, 0),
			_boat("Hb", 5, 6),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 2, 0, 90),
			_shutter("G", "Shutter", 2, 5),
			_tide_mirror("T", "Tide mirror", 2, 6, 0, 90),
			_tide_mirror("B", "East tide mirror", 3, 6, 90, 0),
			_shutter("U", "Upper shutter", 3, 5),
			_vane("V", "Vane", 3, 4, 0, 90),
		],
	}

static func chart_78() -> Dictionary:
	# The side socket lets white wake the hull. On the line, the prism
	# splits. Red climbs. Blue falls through the gate, the stain turns it
	# red, and the vane on the last dry row turns that red onto the dock.
	# Only the middle mark opens the gate and leaves the dock dry.
	return {
		"id": "78",
		"harbor": VANE,
		"title": "The Vane Mark",
		"teach": "Move the prism onto the white beam so red climbs and blue falls through the shutter. Click the stain so that blue becomes red. Rotate the vane so the red beam turns onto the lower dock. The other socket lets white wake the hull. The other faces of the prism absorb the beam. Leaving the vane facing north wakes the hull. Low water is the wrong tide: the shutter is dry and the lower lamp wakes the hull. High water covers the lower dock. Hold the middle mark.",
		"win": "Prism, stain, vane, and the middle mark. The turn holds.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0, 2, 3],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 2, "E", "white"),
			_lantern("S", 0, 6, "E", "white"),
		],
		"docks": [
			_dock("Rn", 2, 0, "red"),
			_dock("Rs", 6, 4, "red"),
		],
		"boats": [
			_boat("Hw", 6, 2),
			_boat("Hb", 6, 6),
			_boat("Ha", 4, 0),
		],
		"fixtures": [],
		"pieces": [
			_prism("P", "Prism", [["side", 5, 0], ["line", 2, 2]], "side", 0, "line", 90),
			_shutter("G", "Shutter", 2, 5),
			_tide_mirror("T", "Tide mirror", 2, 6, 0, 90),
			_stain("K", "Stain", 3, 6, 90, 0),
			_tide_mirror("B", "East tide mirror", 4, 6, 90, 0),
			_shutter("U", "Upper shutter", 4, 5),
			_vane("V", "Vane", 4, 4, 0, 90),
		],
	}

static func chart_79() -> Dictionary:
	# Flood 2 covers the bottom two rows. The mirror drops the beam onto the
	# tide mirror, which turns it west through the shutter into the well.
	# The well leaves north onto the dock. Dry, the tide mirror lets the
	# main beam fall into the hull, and the lower lamp stops in the well.
	return {
		"id": "79",
		"harbor": WELL,
		"title": "The North Well",
		"teach": "A flooded well sends the beam north onto the dock. It keeps the beam's color, and it does not split. While that row is dry, a beam that hits the well stops and does not pass. A shutter in that cell passes in the arrival direction and misses the dock. A vane is shut by the flood: the beam stops at the waterline and does not enter the cell. Turn the mirror and raise the tide.",
		"win": "The north well lands the beam.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [0, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 5, 3, "W", "white"),
			_lantern("S", 0, 4, "E", "white"),
		],
		"docks": [_dock("D", 2, 0, "white")],
		"boats": [
			_boat("Hn", 4, 0),
			_boat("Hs", 4, 5),
		],
		"fixtures": [
			_fixture("T", "tide_mirror", 4, 4, 0),
			_fixture("G", "shutter", 3, 4, 0),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 4, 3, 90, 0),
			_well("W", "Well", 2, 4),
		],
	}

static func chart_80() -> Dictionary:
	# The flood is fixed over the bottom two rows. The beam arrives from the
	# east, traveling west, and the well still leaves north. A shutter keeps
	# going west into the trap, which lifts that miss onto a hull.
	return {
		"id": "80",
		"harbor": WELL,
		"title": "Side Entry",
		"teach": "The beam arrives from the east and still leaves north. The arrival direction does not pick the exit. The well keeps the color, and it does not split. A shutter keeps going west. A stain keeps going west. A vane is shut by the flood and the beam stops at the waterline.",
		"win": "The beam leaves north.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [2],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 5, 3, "W", "white")],
		"docks": [_dock("D", 2, 0, "white")],
		"boats": [
			_boat("Hn", 4, 0),
			_boat("Ht", 1, 0),
		],
		"fixtures": [
			_fixture("T", "tide_mirror", 4, 4, 0),
			_fixture("G", "shutter", 3, 4, 0),
			_fixture("R", "tide_mirror", 1, 4, 90),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 4, 3, 90, 0),
			_well("W", "Well", 2, 4),
		],
	}

static func chart_81() -> Dictionary:
	# White falls through the fixed glass onto the stain. The stain paints
	# the beam, and the flooded well carries that color north. The well
	# does not paint it again.
	return {
		"id": "81",
		"harbor": WELL,
		"title": "After the Color",
		"teach": "A stain recolors the white beam, then the flooded well carries that color north onto the matching dock. The well does not recolor, and it does not split. Blue does not satisfy the red dock. A shutter would keep the arrival direction. A vane is shut by the flood.",
		"win": "The color climbs north.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [2],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 5, 3, "W", "white")],
		"docks": [_dock("Rd", 2, 0, "red")],
		"boats": [],
		"fixtures": [
			_fixture("M", "mirror", 4, 3, 0),
			_fixture("T", "tide_mirror", 4, 4, 0),
		],
		"pieces": [
			_stain("K", "Stain", 3, 4, 90, 0),
			_well("W", "Well", 2, 4),
		],
	}

static func chart_82() -> Dictionary:
	# Dry is the solution. The lower lamp runs east into the well and stops,
	# short of the eastern hull. Flood turns the southbound feed west into
	# the well, and the well lifts that beam onto the northern hull.
	return {
		"id": "82",
		"harbor": WELL,
		"title": "Dry Stop",
		"teach": "The solution is the dry phase. The well stops a beam that would reach the hull. It does not pass. The flood phase lifts that beam north onto the hull and fails. A stain would let the dry beam pass. Water shuts a vane, so a vane cannot make the flood lift.",
		"win": "The dry well holds the hull dark.",
		"cols": 7,
		"rows": 6,
		"tide_phases": [0, 2],
		"start_tide_index": 1,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Ld", 0, 1, "E", "white"),
			_lantern("Lf", 4, 2, "S", "white"),
			_lantern("Lw", 0, 4, "E", "white"),
		],
		"docks": [_dock("D", 6, 0, "white")],
		"boats": [
			_boat("Hn", 2, 0),
			_boat("Ht", 1, 0),
			_boat("He", 5, 4),
			_boat("Hs", 2, 5),
			_boat("Hm", 6, 5),
		],
		"fixtures": [
			_fixture("T", "tide_mirror", 4, 4, 0),
			_fixture("K", "stain", 3, 4, 0),
			_fixture("R", "tide_mirror", 1, 4, 90),
		],
		"pieces": [
			_mirror("M", "Dock mirror", 6, 1, 90, 0),
			_well("W", "Well", 2, 4),
		],
	}

static func chart_83() -> Dictionary:
	# The flood is fixed. The beam enters the southern well from the side and
	# leaves north. A tide mirror turns that climb east into the northern
	# well, which leaves north onto the dock. A shutter in either cell keeps
	# the arrival direction and misses.
	return {
		"id": "83",
		"harbor": WELL,
		"title": "Two Wells",
		"teach": "Two flooded wells, one a row north of the other, climb the beam two rows onto the dock. The arrival direction does not pick the exit. Replacing either well with a shutter keeps the beam on its old direction. A vane is shut by the flood. A stain does not turn the beam north.",
		"win": "Two wells climb to the dock.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [3],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 6, 3, "W", "white")],
		"docks": [_dock("D", 4, 3, "white")],
		"boats": [_boat("Hn", 5, 0)],
		"fixtures": [
			_fixture("G54", "shutter", 5, 4, 0),
			_fixture("T55", "tide_mirror", 5, 5, 0),
			_fixture("G45", "shutter", 4, 5, 0),
			_fixture("G35", "shutter", 3, 5, 0),
			_fixture("T24", "tide_mirror", 2, 4, 0),
			_fixture("G34", "shutter", 3, 4, 0),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 5, 3, 90, 0),
			_well("W1", "South well", 2, 5),
			_well("W2", "North well", 4, 4),
		],
	}

static func chart_84() -> Dictionary:
	# Flood 2 covers the well and leaves the dock's row dry. The well lifts
	# the beam out of the water onto that dry row. Low water stops the lower
	# lamp in the well and drops the feed into the hull.
	return {
		"id": "84",
		"harbor": WELL,
		"title": "Above the Gate",
		"teach": "The well lifts the beam out of the flood onto the dry row. Low water stops: a dry well does not pass, and the falling beam wakes the hull. The solution flood reaches the well and does not cover the dock. A shutter passes in the arrival direction. A vane stops at the waterline.",
		"win": "The beam climbs out of the flood.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [0, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 3, "E", "white"),
			_lantern("S", 5, 4, "W", "white"),
		],
		"docks": [_dock("D", 3, 2, "white")],
		"boats": [
			_boat("Hn", 2, 0),
			_boat("Hs", 2, 5),
		],
		"fixtures": [
			_fixture("T", "tide_mirror", 2, 4, 90),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 3, 0, 90),
			_well("W", "Well", 3, 4),
		],
	}

static func chart_85() -> Dictionary:
	# Phases flood 0, 2, and 3 rows. Flood 2 covers the well and leaves the
	# dock dry. Flood 3 covers the dock. Low water stops on the dry well.
	return {
		"id": "85",
		"harbor": WELL,
		"title": "The Held Well",
		"teach": "Three tide phases. Only the middle flood clears. Low water stops on the dry well, and the falling beam wakes the hull. High water covers the dock. The wrong tide fails. A shutter does not lift the beam. A vane is shut when the well's row is flooded.",
		"win": "The middle mark holds the well.",
		"cols": 6,
		"rows": 7,
		"tide_phases": [0, 2, 3],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 3, "E", "white"),
			_lantern("S", 5, 5, "W", "white"),
		],
		"docks": [_dock("D", 3, 4, "white")],
		"boats": [
			_boat("Hn", 2, 0),
			_boat("Hs", 2, 6),
		],
		"fixtures": [
			_fixture("T", "tide_mirror", 2, 5, 90),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 3, 0, 90),
			_well("W", "Well", 3, 5),
		],
	}

static func chart_86() -> Dictionary:
	# The prism must sit on the white beam. Red leaves north and misses the
	# dock. Blue falls through the gate into the well and climbs north onto
	# the blue dock. Low water lets that blue fall into the hull.
	return {
		"id": "86",
		"harbor": WELL,
		"title": "The Well Mark",
		"teach": "Move the prism onto the white beam. One color climbs north through the well onto the dock. The other color does not satisfy that dock. The well does not recolor, and it does not split. Low water is the wrong tide. The other socket lets white wake the hull. A shutter keeps the arrival direction. A vane stops at the waterline.",
		"win": "One color climbs. The other does not.",
		"cols": 7,
		"rows": 6,
		"tide_phases": [0, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 2, "E", "white")],
		"docks": [_dock("Bd", 4, 0, "blue")],
		"boats": [
			_boat("Hw", 6, 2),
			_boat("Hs", 2, 5),
		],
		"fixtures": [
			_fixture("T", "tide_mirror", 2, 4, 90),
			_fixture("G", "shutter", 3, 4, 0),
		],
		"pieces": [
			_prism("P", "Prism", [["side", 5, 0], ["line", 2, 2]], "side", 0, "line", 90),
			_well("W", "Well", 4, 4),
		],
	}

static func chart_87() -> Dictionary:
	# Flood 2 covers the siphon's row. The stain is clicked from blue to red.
	# The siphon flips that red to blue and sends it north onto the blue dock.
	# Low water lets the feed fall through the dry tide mirror into the hull,
	# and the lower lamp stops in the dry siphon.
	return {
		"id": "87",
		"harbor": SIPHON,
		"title": "The North Siphon",
		"teach": "Click the stain from blue to red. A flooded siphon flips that red to blue and sends it north onto the blue dock. It does not split. While that row is dry, a beam that hits the siphon stops, and low water lights a hull. A well in that cell keeps the red and does not satisfy the blue dock. A shutter keeps the arrival direction. A vane stops at the waterline.",
		"win": "Red climbs north as blue.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [0, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 5, 3, "W", "white"),
			_lantern("Lw", 0, 4, "E", "white"),
		],
		"docks": [_dock("Bd", 2, 0, "blue")],
		"boats": [
			_boat("Hn", 4, 0),
			_boat("Hs", 4, 5),
		],
		"fixtures": [
			_fixture("T", "tide_mirror", 4, 4, 0),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 4, 3, 90, 0),
			_stain("K", "Stain", 3, 4, 90, 0),
			_siphon("S", "Siphon", 2, 4),
		],
	}

static func chart_88() -> Dictionary:
	# The only phase floods the bottom two rows. Red arrives from the east,
	# traveling west, and the siphon still leaves north as blue.
	return {
		"id": "88",
		"harbor": SIPHON,
		"title": "Side Entry",
		"teach": "The beam arrives traveling west, already red, and still leaves north as blue. The arrival direction does not pick the exit. A shutter keeps going west as red and misses the dock. A well keeps the red. A vane is shut by the flood and the beam stops at the waterline.",
		"win": "The side entry leaves north as blue.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [2],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 5, 3, "W", "red")],
		"docks": [_dock("Bd", 2, 0, "blue")],
		"boats": [
			_boat("Hn", 4, 0),
			_boat("Ht", 1, 0),
		],
		"fixtures": [
			_fixture("T", "tide_mirror", 4, 4, 0),
			_fixture("G", "shutter", 3, 4, 0),
			_fixture("R", "tide_mirror", 1, 4, 90),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 4, 3, 90, 0),
			_siphon("S", "Siphon", 2, 4),
		],
	}

static func chart_89() -> Dictionary:
	# White through the siphon stays white. A well keeps white too, so a well
	# in this cell also clears. A shutter misses north. A red stain fails.
	return {
		"id": "89",
		"harbor": SIPHON,
		"title": "White Through",
		"teach": "White enters the siphon and leaves north still white onto the white dock. The siphon does not paint white into another color. A well also keeps white and also clears this chart. A shutter misses north. A stain set to red fails the white dock.",
		"win": "White climbs north, still white.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [2],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 5, 3, "W", "white")],
		"docks": [_dock("D", 2, 0, "white")],
		"boats": [
			_boat("Hn", 4, 0),
			_boat("Ht", 1, 0),
		],
		"fixtures": [
			_fixture("T", "tide_mirror", 4, 4, 0),
			_fixture("G", "shutter", 3, 4, 0),
			_fixture("R", "tide_mirror", 1, 4, 90),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 4, 3, 90, 0),
			_siphon("S", "Siphon", 2, 4),
		],
	}

static func chart_90() -> Dictionary:
	# Dry is the solution. The eastbound lamp stops in the siphon, short of
	# the eastern hull. Flood turns the southbound feed west into the siphon,
	# and the siphon lifts that beam onto the northern hull. Any color lights
	# a hull, so the flip does not save the flood.
	return {
		"id": "90",
		"harbor": SIPHON,
		"title": "Dry Stop",
		"teach": "The solution is the dry phase. The dry siphon stops an eastbound beam short of a hull. It does not pass. The flood lifts a beam north onto a hull, and any color lights a hull, so the flood fails. A dry shutter and a head-on vane also stop that dry beam. A stain lets the dry beam pass and lights the hull. A well stops that same dry beam.",
		"win": "The dry siphon holds the hull dark.",
		"cols": 7,
		"rows": 6,
		"tide_phases": [0, 2],
		"start_tide_index": 1,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Ld", 0, 1, "E", "white"),
			_lantern("Lf", 4, 2, "S", "white"),
			_lantern("Lw", 0, 4, "E", "white"),
		],
		"docks": [_dock("D", 6, 0, "white")],
		"boats": [
			_boat("Hn", 2, 0),
			_boat("Ht", 1, 0),
			_boat("He", 5, 4),
			_boat("Hs", 2, 5),
			_boat("Hm", 6, 5),
		],
		"fixtures": [
			_fixture("T", "tide_mirror", 4, 4, 0),
			_fixture("K", "stain", 3, 4, 0),
			_fixture("R", "tide_mirror", 1, 4, 90),
		],
		"pieces": [
			_mirror("M", "Dock mirror", 6, 1, 90, 0),
			_siphon("S", "Siphon", 2, 4),
		],
	}

static func chart_91() -> Dictionary:
	# Flood 3 covers y >= 4. Red enters the south siphon and leaves north as
	# blue. A tide mirror turns that climb east into the north siphon, which
	# leaves north as red onto the dry dock. One flip leaves blue on that dock.
	return {
		"id": "91",
		"harbor": SIPHON,
		"title": "Two Siphons",
		"teach": "Red enters the south siphon, leaves north as blue, enters the north siphon, and leaves north as red onto the dry red dock. One siphon alone leaves the wrong color on that dock. Replacing either siphon with a well fails. A shutter keeps the arrival direction. A vane is shut by the flood. A stain does not turn the beam north.",
		"win": "Two siphons restore the red.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [3],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 6, 3, "W", "red")],
		"docks": [_dock("Rd", 4, 3, "red")],
		"boats": [_boat("Hn", 5, 0)],
		"fixtures": [
			_fixture("G54", "shutter", 5, 4, 0),
			_fixture("T55", "tide_mirror", 5, 5, 0),
			_fixture("G45", "shutter", 4, 5, 0),
			_fixture("G35", "shutter", 3, 5, 0),
			_fixture("T24", "tide_mirror", 2, 4, 0),
			_fixture("G34", "shutter", 3, 4, 0),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 5, 3, 90, 0),
			_siphon("S1", "South siphon", 2, 5),
			_siphon("S2", "North siphon", 4, 4),
		],
	}

static func chart_92() -> Dictionary:
	# Flood 2 covers the siphon and leaves the dock's row dry. Red climbs out
	# of the water as blue. Low water stops the lower lamp in the dry siphon
	# and drops the feed into the hull.
	return {
		"id": "92",
		"harbor": SIPHON,
		"title": "Above the Gate",
		"teach": "The flood covers the siphon and leaves the dock on the drier row dry. Red becomes blue on that dock. Low water stops in the dry siphon. A well keeps the red. A shutter passes in the arrival direction. A vane stops at the waterline.",
		"win": "Blue climbs out of the flood.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [0, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 3, "E", "red"),
			_lantern("Lw", 5, 4, "W", "white"),
		],
		"docks": [_dock("Bd", 3, 2, "blue")],
		"boats": [
			_boat("Hn", 2, 0),
			_boat("Hs", 2, 5),
		],
		"fixtures": [
			_fixture("T", "tide_mirror", 2, 4, 90),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 3, 0, 90),
			_siphon("S", "Siphon", 3, 4),
		],
	}

static func chart_93() -> Dictionary:
	# Phases flood 0, 2, and 3 rows on a 7-row quay. Flood 2 covers the siphon
	# (y >= 5) and leaves the dock one row north dry. Flood 3 covers that dock.
	# The stain on the row between the mirror and the tide mirror lets high
	# water still reach the siphon, so the stop is the dock's waterline.
	return {
		"id": "93",
		"harbor": SIPHON,
		"title": "The Held Siphon",
		"teach": "Three tide phases. Only the middle flood clears. The siphon is flooded and the dock one row north is dry. Red flips to blue onto that dock. Low water stops on the dry siphon, and the falling beam wakes the hull. High water covers the dock, so the beam stops at the waterline and the dock is not hit. A well keeps the red. A shutter does not send the beam north. A vane is shut when the siphon's row is flooded.",
		"win": "The middle mark holds the siphon.",
		"cols": 6,
		"rows": 7,
		"tide_phases": [0, 2, 3],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 3, "E", "red"),
			_lantern("Lw", 5, 5, "W", "white"),
		],
		"docks": [_dock("Bd", 3, 4, "blue")],
		"boats": [
			_boat("Hn", 2, 0),
			_boat("Hs", 2, 6),
		],
		"fixtures": [
			_fixture("K", "stain", 2, 4, 0),
			_fixture("T", "tide_mirror", 2, 5, 90),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 3, 0, 90),
			_siphon("S", "Siphon", 3, 5),
		],
	}

static func chart_94() -> Dictionary:
	# The prism must sit on the white beam, facing the east entry. Red leaves
	# north, is turned east and then south, and a flooded tide mirror turns it
	# west into the siphon. That red leaves north as blue. Blue leaves south
	# and dies on the waterline of an empty flooded cell. It does not enter
	# the siphon.
	return {
		"id": "94",
		"harbor": SIPHON,
		"title": "The Siphon Mark",
		"teach": "Move the prism from the side socket onto the line. Only the red port enters the siphon. That red leaves north as blue onto the blue dock. The blue port does not enter the siphon. The siphon does not split. Low water is the wrong tide. A well in the siphon cell carries red and misses the blue dock. A shutter keeps the arrival direction. A vane stops at the waterline.",
		"win": "The red port climbs north as blue.",
		"cols": 7,
		"rows": 6,
		"tide_phases": [0, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 2, "E", "white")],
		"docks": [_dock("Bd", 3, 0, "blue")],
		"boats": [
			_boat("Hw", 6, 2),
			_boat("Hs", 4, 5),
		],
		"fixtures": [
			_fixture("Na", "mirror", 2, 1, 0),
			_fixture("Nb", "mirror", 4, 1, 90),
			_fixture("T", "tide_mirror", 4, 4, 0),
		],
		"pieces": [
			_prism("P", "Prism", [["side", 5, 0], ["line", 2, 2]], "side", 0, "line", 90),
			_siphon("S", "Siphon", 3, 4),
		],
	}

static func chart_95() -> Dictionary:
	# Flood 2 covers the sluice. White falls through the stain, which is
	# clicked to red, and arrives traveling south. An east-facing sluice
	# keeps that red and sends it east. The tide mirror on that cell turns
	# the exit north onto the dry red dock. A north-facing sluice sends the
	# beam back up the column and misses the dock. Low water stops in the
	# dry gate, and the lower lamp wakes the south hull.
	return {
		"id": "95",
		"harbor": SLUICE,
		"title": "The East Sluice",
		"teach": "Tide index 1 floods the lowest two rows. Click the stain from blue to red and face the sluice east. Red enters traveling south and leaves east still red. The flooded glass turns that exit onto the red dock. A north-facing sluice sends it north and misses that dock. A siphon sends it north as blue. A well sends it north as red. A shutter keeps going south. While the row is dry the sluice stops, and the lower lamp wakes the hull.",
		"win": "Red leaves the east sluice and the dock takes it.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [0, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 2, "E", "white"),
			_lantern("Lw", 0, 5, "E", "white"),
		],
		"docks": [_dock("Rd", 4, 3, "red")],
		"boats": [_boat("Hb", 5, 5)],
		"fixtures": [
			_fixture("E", "tide_mirror", 4, 4, 0),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 3, 2, 0, 90),
			_stain("K", "Stain", 3, 3, 90, 0),
			_sluice("U", "Sluice", 3, 4, 0, 90),
		],
	}

static func chart_96() -> Dictionary:
	# The only phase floods the bottom two rows. Red arrives traveling west.
	# A south-facing sluice still leaves south as red. The flooded glass turns
	# that south exit onto the dry red dock. A north exit misses it.
	return {
		"id": "96",
		"harbor": SLUICE,
		"title": "Side Entry",
		"teach": "The only phase floods the lowest two rows. The beam arrives traveling west, already red. A south-facing sluice still leaves south as red, and the flooded glass carries that exit onto the red dock. The arrival direction does not pick the exit. A siphon leaves north as blue. A well leaves north as red. A north-facing sluice misses the dock. A shutter keeps going west.",
		"win": "The side entry leaves south as red.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [2],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 5, 3, "W", "red")],
		"docks": [_dock("Rd", 1, 3, "red")],
		"boats": [
			_boat("Hn", 2, 0),
			_boat("Ht", 0, 0),
		],
		"fixtures": [
			_fixture("T", "tide_mirror", 4, 4, 0),
			_fixture("G", "shutter", 3, 4, 0),
			_fixture("A", "tide_mirror", 2, 5, 0),
			_fixture("B", "tide_mirror", 1, 5, 90),
			_fixture("G14", "shutter", 1, 4, 0),
			_fixture("R", "tide_mirror", 0, 4, 90),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 4, 3, 90, 0),
			_sluice("U", "Sluice", 2, 4, 0, 180),
		],
	}

static func chart_97() -> Dictionary:
	# White through an east-facing sluice stays white and reaches the east
	# dock. A siphon keeps white but leaves north. A red stain fails the dock.
	return {
		"id": "97",
		"harbor": SLUICE,
		"title": "White Through",
		"teach": "Flood 2. White enters an east-facing sluice and leaves east still white onto the white dock. The sluice does not paint white into another color. A siphon keeps white but leaves north and misses the east dock. A well leaves north as white and misses that dock. A stain set to red fails the white dock. A shutter keeps the arrival direction.",
		"win": "White leaves east, still white.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [2],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 2, "E", "white")],
		"docks": [_dock("D", 4, 3, "white")],
		"boats": [
			_boat("Hn", 3, 0),
			_boat("Ht", 1, 0),
		],
		"fixtures": [
			_fixture("E", "tide_mirror", 4, 4, 0),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 3, 2, 0, 90),
			_sluice("U", "Sluice", 3, 4, 0, 90),
		],
	}

static func chart_98() -> Dictionary:
	# Dry is the solution. The eastbound lamp stops in the sluice, short of
	# the route that would reach the east hull. The dock mirror sends another
	# beam south onto a dock on the bottom rows. Every dry facing stops the
	# eastbound beam, so each of them clears. Index 1 floods the sluice and
	# covers that dock: the dock beam dies on the waterline. East still wakes
	# the east hull. North still wakes the north hull.
	return {
		"id": "98",
		"harbor": SLUICE,
		"title": "Dry Stop",
		"teach": "The solution is low water, flood 0. The dry sluice stops an eastbound beam short of the east hull, and the dock mirror lights the white dock. Rotating the dry sluice still stops that beam. Index 1 floods the gate and covers the dock, so the flood fails. An east-facing sluice then sends the beam east onto the east hull. A north-facing sluice at that tide sends it north instead. Any color lights a hull. A dry siphon, a dry well, and a dry shutter stop that same beam and also clear. A head-on vane also stops it. A stain lets the dry beam pass and wakes the hull past the gate.",
		"win": "The dry sluice holds the hulls dark.",
		"cols": 7,
		"rows": 6,
		"tide_phases": [0, 2],
		"start_tide_index": 1,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Ld", 3, 2, "E", "white"),
			_lantern("Lf", 0, 2, "E", "white"),
			_lantern("Lw", 0, 4, "E", "white"),
		],
		"docks": [_dock("D", 5, 4, "white")],
		"boats": [
			_boat("Hn", 2, 0),
			_boat("He", 3, 3),
			_boat("Hp", 4, 4),
			_boat("Hs", 2, 5),
		],
		"fixtures": [
			_fixture("F", "mirror", 1, 2, 90),
			_fixture("R", "tide_mirror", 1, 4, 90),
			_fixture("C", "tide_mirror", 3, 4, 0),
		],
		"pieces": [
			_mirror("M", "Dock mirror", 5, 2, 0, 90),
			_sluice("U", "Sluice", 2, 4, 90, 0),
		],
	}

static func chart_99() -> Dictionary:
	# Flood 3. Red enters the south sluice and leaves north still red, then
	# enters the east-facing sluice and leaves east still red onto the dry dock.
	return {
		"id": "99",
		"harbor": SLUICE,
		"title": "Two Sluices",
		"teach": "Flood 3. Red enters a north-facing sluice, leaves north still red, enters an east-facing sluice, and leaves east still red onto the dry red dock. A siphon in the first cell leaves blue on the dock. A siphon in the second cell turns the kept red into blue and sends it north, missing the east dock. A well in the second cell sends red north and misses the east dock. A well in the first cell keeps the red and also clears. A north-facing sluice in the second cell misses the east dock.",
		"win": "Two sluices keep the red and land it east.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [3],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 6, 3, "W", "red")],
		"docks": [_dock("Rd", 4, 3, "red")],
		"boats": [_boat("Hn", 3, 0)],
		"fixtures": [
			_fixture("G54", "shutter", 5, 4, 0),
			_fixture("T55", "tide_mirror", 5, 5, 0),
			_fixture("G45", "shutter", 4, 5, 0),
			_fixture("E", "tide_mirror", 4, 4, 0),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 5, 3, 90, 0),
			_sluice("U1", "South sluice", 3, 5, 90, 0),
			_sluice("U2", "East sluice", 3, 4, 0, 90),
		],
	}

static func chart_100() -> Dictionary:
	# Flood 2 covers the sluice and leaves the dock's row dry. Red leaves
	# east and the tide mirror lifts it onto that dock. Low water falls
	# through the dry tide mirror into the south hull, and the lower lamp
	# stops in the dry sluice.
	return {
		"id": "100",
		"harbor": SLUICE,
		"title": "Above the Gate",
		"teach": "Tide index 1, flood 2. The flood covers the sluice and leaves the dock on the drier row dry. An east-facing sluice keeps red on the east dock. A siphon turns that red blue and sends it north. Low water stops in the dry sluice and wakes the south hull. A north-facing sluice misses the east dock. A well sends the red north. A shutter keeps going east and also clears. A stain set to red also clears. A stain set to blue misses the red dock.",
		"win": "Red climbs out of the flood to the east.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [0, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 3, "E", "red"),
			_lantern("Lw", 5, 4, "W", "white"),
		],
		"docks": [_dock("Rd", 4, 3, "red")],
		"boats": [
			_boat("Hn", 3, 0),
			_boat("Hs", 2, 5),
		],
		"fixtures": [
			_fixture("T", "tide_mirror", 2, 4, 90),
			_fixture("C", "tide_mirror", 4, 4, 0),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 3, 0, 90),
			_sluice("U", "Sluice", 3, 4, 0, 90),
		],
	}

static func chart_101() -> Dictionary:
	# Rows 7. Flood 2 covers y >= 5. The sluice is flooded and the dock one
	# column east, on the row above the flood, is dry. Flood 3 covers that dock.
	return {
		"id": "101",
		"harbor": SLUICE,
		"title": "The Held Sluice",
		"teach": "Tide index 1, flood 2, with the flood line at y >= 5. The sluice is flooded and the dock one column east, on the dry row above that water, is dry. An east-facing sluice keeps red on that dry dock. Index 0 stops on the dry sluice and wakes the south hull. Index 2 covers the dock, so the beam stops at the dock's waterline and the dock is not hit. A north-facing sluice at index 1 misses the east dock. A siphon sends the red north as blue. A well sends it north as red. A shutter keeps going east and also clears. A stain set to red also clears. A stain set to blue misses the red dock.",
		"win": "The middle mark holds the sluice.",
		"cols": 6,
		"rows": 7,
		"tide_phases": [0, 2, 3],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 3, "E", "red"),
			_lantern("Lw", 5, 5, "W", "white"),
		],
		"docks": [_dock("Rd", 4, 4, "red")],
		"boats": [
			_boat("Hn", 3, 0),
			_boat("Hs", 2, 6),
		],
		"fixtures": [
			_fixture("K", "stain", 2, 4, 0),
			_fixture("T", "tide_mirror", 2, 5, 90),
			_fixture("C", "tide_mirror", 4, 5, 0),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 3, 0, 90),
			_sluice("U", "Sluice", 3, 5, 0, 90),
		],
	}

static func chart_102() -> Dictionary:
	# The prism must sit on the white beam. Red is turned south, then east
	# into the sluice. That red leaves east still red. The tide mirror on the
	# east cell lifts it onto the dry red dock. Blue dies on an empty flooded
	# cell and never enters the sluice.
	return {
		"id": "102",
		"harbor": SLUICE,
		"title": "The Sluice Mark",
		"teach": "Tide index 1, flood 2. Move the prism from the side socket onto the line. Only the red port enters the east-facing sluice. That red leaves east still red onto the red dock. The blue port dies on an empty flooded cell and does not enter. A siphon in that cell sends red north as blue and misses the red dock. A well sends red north and misses the red dock. Low water is the wrong tide. The sluice does not split. A shutter keeps going east and also clears. A stain set to red also clears. A stain set to blue misses the red dock.",
		"win": "The red port leaves east, still red.",
		"cols": 7,
		"rows": 6,
		"tide_phases": [0, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 2, "E", "white")],
		"docks": [_dock("Rd", 6, 3, "red")],
		"boats": [
			_boat("Hw", 6, 2),
			_boat("Hs", 4, 5),
		],
		"fixtures": [
			_fixture("Na", "mirror", 2, 1, 0),
			_fixture("Nb", "mirror", 4, 1, 90),
			_fixture("T", "tide_mirror", 4, 4, 90),
			_fixture("C", "tide_mirror", 6, 4, 0),
		],
		"pieces": [
			_prism("P", "Prism", [["side", 5, 0], ["line", 2, 2]], "side", 0, "line", 90),
			_sluice("U", "Sluice", 5, 4, 0, 90),
		],
	}

static func chart_103() -> Dictionary:
	# Flood 2 covers the weir. White falls through the stain, which is clicked
	# to red, and arrives traveling south. An east-facing weir swaps that red
	# to blue and sends it east. The tide mirror lifts the exit onto the dry
	# blue dock. An east-facing sluice keeps the red and misses that dock.
	return {
		"id": "103",
		"harbor": WEIR,
		"title": "The East Weir",
		"teach": "Tide index 1 floods the lowest two rows. Click the stain from blue to red and face the weir east. Red arrives traveling south and leaves east as blue. The flooded glass lifts that exit onto the dry blue dock. An east-facing sluice leaves red and misses the blue dock. A north-facing weir sends it north as blue and misses. A siphon leaves north as blue. A well leaves north as red. A shutter keeps going south. Low water stops in the dry weir and lights the south hull.",
		"win": "Blue leaves the east weir and the dock takes it.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [0, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 2, "E", "white"),
			_lantern("Lw", 0, 5, "E", "white"),
		],
		"docks": [_dock("Bd", 4, 3, "blue")],
		"boats": [_boat("Hb", 5, 5)],
		"fixtures": [
			_fixture("E", "tide_mirror", 4, 4, 0),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 3, 2, 0, 90),
			_stain("K", "Stain", 3, 3, 90, 0),
			_weir("R", "Weir", 3, 4, 0, 90),
		],
	}

static func chart_104() -> Dictionary:
	# The only phase floods the bottom two rows. Red arrives traveling west.
	# A south-facing weir leaves south as blue. The flooded glass carries that
	# exit onto the dry blue dock. A sluice on the same facing leaves red.
	return {
		"id": "104",
		"harbor": WEIR,
		"title": "Side Entry",
		"teach": "The only phase floods the lowest two rows. The beam arrives traveling west, already red. A south-facing weir leaves south as blue, and the flooded glass carries that exit onto the dry blue dock. A sluice leaves south as red and misses. A siphon leaves north as blue and lights the north hull. A well leaves north as red. A shutter keeps going west. A north-facing weir misses the dock.",
		"win": "The side entry leaves south as blue.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [2],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 5, 3, "W", "red")],
		"docks": [_dock("Bd", 1, 3, "blue")],
		"boats": [
			_boat("Hn", 2, 0),
			_boat("Ht", 0, 0),
		],
		"fixtures": [
			_fixture("T", "tide_mirror", 4, 4, 0),
			_fixture("G", "shutter", 3, 4, 0),
			_fixture("A", "tide_mirror", 2, 5, 0),
			_fixture("B", "tide_mirror", 1, 5, 90),
			_fixture("G14", "shutter", 1, 4, 0),
			_fixture("R", "tide_mirror", 0, 4, 90),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 4, 3, 90, 0),
			_weir("R", "Weir", 2, 4, 0, 180),
		],
	}

static func chart_105() -> Dictionary:
	# White through an east-facing weir stays white and reaches the east dock.
	# An east-facing sluice keeps white on the same path and also clears.
	return {
		"id": "105",
		"harbor": WEIR,
		"title": "White Through",
		"teach": "Flood 2. White enters an east-facing weir and leaves east still white onto the white dock. The weir does not paint white into another color. A sluice also keeps white and also clears this chart. A siphon keeps white and leaves north, missing the dock. A well leaves north as white and misses. A stain set to red misses the white dock. A north-facing weir misses.",
		"win": "White leaves east, still white.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [2],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 2, "E", "white")],
		"docks": [_dock("D", 4, 3, "white")],
		"boats": [
			_boat("Hn", 3, 0),
			_boat("Ht", 1, 0),
		],
		"fixtures": [
			_fixture("E", "tide_mirror", 4, 4, 0),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 3, 2, 0, 90),
			_weir("R", "Weir", 3, 4, 0, 90),
		],
	}

static func chart_106() -> Dictionary:
	# Dry is the solution. The eastbound lamp stops in the weir, short of the
	# hull past the gate. Every dry facing stops that beam. Index 1 floods the
	# weir and the dock, so every flooded facing fails.
	return {
		"id": "106",
		"harbor": WEIR,
		"title": "Dry Stop",
		"teach": "Tide index 0, flood 0. The dry weir stops an eastbound beam short of the hull past the gate, and the dock mirror lights the white dock. All four dry facings clear. A dry sluice, a dry siphon, a dry well, a dry shutter, and a head-on west-facing vane also stop that dry beam and also clear. Index 1 floods the weir and covers the dock. An east-facing weir then sends the beam onto the east hull. A north-facing weir sends it north onto the north hull. South and west at that tide also fail, because the dock is under the waterline.",
		"win": "The dry weir holds the hulls dark.",
		"cols": 7,
		"rows": 6,
		"tide_phases": [0, 2],
		"start_tide_index": 1,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Ld", 3, 2, "E", "white"),
			_lantern("Lf", 0, 2, "E", "white"),
			_lantern("Lw", 0, 4, "E", "white"),
		],
		"docks": [_dock("D", 5, 4, "white")],
		"boats": [
			_boat("Hn", 2, 0),
			_boat("He", 3, 3),
			_boat("Hp", 4, 4),
			_boat("Hs", 2, 5),
		],
		"fixtures": [
			_fixture("F", "mirror", 1, 2, 90),
			_fixture("R", "tide_mirror", 1, 4, 90),
			_fixture("C", "tide_mirror", 3, 4, 0),
		],
		"pieces": [
			_mirror("M", "Dock mirror", 5, 2, 0, 90),
			_weir("R", "Weir", 2, 4, 90, 0),
		],
	}

static func chart_107() -> Dictionary:
	# Flood 3. Red enters the north-facing weir and leaves north as blue, then
	# the east-facing weir swaps it back to red and sends it onto the dry dock.
	# A siphon in the first cell also leaves blue, so the second weir restores
	# red and that substitute clears. A well in the first cell keeps red, and
	# the second weir turns it blue, so that substitute misses.
	return {
		"id": "107",
		"harbor": WEIR,
		"title": "Two Weirs",
		"teach": "Flood 3. Red enters a north-facing weir, leaves north as blue, enters an east-facing weir, and leaves east as red onto the dry red dock. A sluice in the first cell leaves red, and the second weir turns that red blue, so the dock misses. A sluice in the second cell sends the blue east still blue and misses. A siphon in the second cell sends the beam north and misses. A well in the second cell sends it north and misses. A north-facing weir in the second cell misses the east dock. A siphon in the first cell also leaves blue, and the second weir turns that blue back to red, so that substitute also clears. A well in the first cell keeps the red, and the second weir turns it blue, so the dock misses.",
		"win": "Two weirs restore the red and land it east.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [3],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [_lantern("L", 6, 3, "W", "red")],
		"docks": [_dock("Rd", 4, 3, "red")],
		"boats": [_boat("Hn", 3, 0)],
		"fixtures": [
			_fixture("G54", "shutter", 5, 4, 0),
			_fixture("T55", "tide_mirror", 5, 5, 0),
			_fixture("G45", "shutter", 4, 5, 0),
			_fixture("E", "tide_mirror", 4, 4, 0),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 5, 3, 90, 0),
			_weir("R1", "South weir", 3, 5, 90, 0),
			_weir("R2", "East weir", 3, 4, 0, 90),
		],
	}

static func chart_108() -> Dictionary:
	# Flood 2 covers the weir and leaves the dock's row dry. Red leaves east
	# as blue, and the tide mirror lifts it onto that dock. A blue stain on
	# the same cell also paints blue and also clears.
	return {
		"id": "108",
		"harbor": WEIR,
		"title": "Above the Gate",
		"teach": "Tide index 1, flood 2. The flood covers the weir and leaves the dock on the drier row dry. An east-facing weir turns red to blue on the east dock. A sluice keeps red and misses the blue dock. A siphon turns that red blue and sends it north. A well sends red north. Low water stops in the dry weir and wakes the south hull. A north-facing weir misses the east dock. A stain set to blue also clears. A stain set to red misses the blue dock.",
		"win": "Blue climbs out of the flood to the east.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [0, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 3, "E", "red"),
			_lantern("Lw", 5, 4, "W", "white"),
		],
		"docks": [_dock("Bd", 4, 3, "blue")],
		"boats": [
			_boat("Hn", 3, 0),
			_boat("Hs", 2, 5),
		],
		"fixtures": [
			_fixture("T", "tide_mirror", 2, 4, 90),
			_fixture("C", "tide_mirror", 4, 4, 0),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 3, 0, 90),
			_weir("R", "Weir", 3, 4, 0, 90),
		],
	}

static func chart_109() -> Dictionary:
	# Rows 7. Flood 2 covers y >= 5. The weir is flooded and the dock one
	# column east, on the row above the flood, is dry. Flood 3 covers that dock.
	return {
		"id": "109",
		"harbor": WEIR,
		"title": "The Held Weir",
		"teach": "Tide index 1, flood 2, with the flood line at y >= 5. The weir is flooded. The dock one column east, on the dry row above that water, is dry. An east-facing weir turns red to blue on that dock. Index 0 stops on the dry weir and wakes the south hull. Index 2 covers the dock, so the beam stops at the dock's waterline and the dock is not hit. A north-facing weir at index 1 misses the east dock. A sluice keeps red and misses the blue dock. A siphon sends red north as blue. A well sends red north. A stain set to blue also clears. A stain set to red misses the blue dock.",
		"win": "The middle mark holds the weir.",
		"cols": 6,
		"rows": 7,
		"tide_phases": [0, 2, 3],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 3, "E", "red"),
			_lantern("Lw", 5, 5, "W", "white"),
		],
		"docks": [_dock("Bd", 4, 4, "blue")],
		"boats": [
			_boat("Hn", 3, 0),
			_boat("Hs", 2, 6),
		],
		"fixtures": [
			_fixture("K", "stain", 2, 4, 0),
			_fixture("T", "tide_mirror", 2, 5, 90),
			_fixture("C", "tide_mirror", 4, 5, 0),
		],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 3, 0, 90),
			_weir("R", "Weir", 3, 5, 0, 90),
		],
	}

static func chart_110() -> Dictionary:
	# The prism must sit on the white beam. Red is turned south, then east
	# into the weir. That red leaves east as blue. Blue dies on an empty
	# flooded cell. A blue stain on the weir cell also clears.
	return {
		"id": "110",
		"harbor": WEIR,
		"title": "The Weir Mark",
		"teach": "Tide index 1, flood 2. Move the prism from the side socket onto the line. Only the red port enters the east-facing weir, and that red leaves east as blue onto the blue dock. The blue port dies on an empty flooded cell. A sluice sends red east still red and misses. A siphon sends red north as blue and misses. A well sends red north and misses. Low water wakes the south hull. The side socket wakes the west hull. A stain set to blue also clears. A stain set to red misses the blue dock.",
		"win": "The red port leaves east as blue.",
		"cols": 7,
		"rows": 6,
		"tide_phases": [0, 2],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [_lantern("L", 0, 2, "E", "white")],
		"docks": [_dock("Bd", 6, 3, "blue")],
		"boats": [
			_boat("Hw", 6, 2),
			_boat("Hs", 4, 5),
		],
		"fixtures": [
			_fixture("Na", "mirror", 2, 1, 0),
			_fixture("Nb", "mirror", 4, 1, 90),
			_fixture("T", "tide_mirror", 4, 4, 90),
			_fixture("C", "tide_mirror", 6, 4, 0),
		],
		"pieces": [
			_prism("P", "Prism", [["side", 5, 0], ["line", 2, 2]], "side", 0, "line", 90),
			_weir("R", "Weir", 5, 4, 0, 90),
		],
	}

static func chart_111() -> Dictionary:
	# Tide index 0, flood 0. White travels east and blue travels south. Both
	# pass straight through the dry lintel onto the matching dock. A dry
	# shutter, weir, sluice, well, or siphon stops in that cell.
	return {
		"id": "111",
		"harbor": LINTEL,
		"title": "The Dry Lintel",
		"teach": "Tide index 0, flood 0. A beam passes straight through the dry lintel onto the matching dock. White stays white and blue stays blue. A shutter, a weir, a sluice, a well, or a siphon in that cell stops and misses the dock. A stain changes the color and misses the dock.",
		"win": "The dry lintel lets both colors pass straight.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 2, "E", "white"),
			_lantern("B", 3, 0, "S", "blue"),
			_lantern("T", 0, 5, "E", "white"),
		],
		"docks": [
			_dock("W", 5, 2, "white"),
			_dock("Bd", 3, 4, "blue"),
		],
		"boats": [_boat("H", 2, 1)],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Side mirror", 2, 5, 0, 90),
			_lintel("N", "Lintel", 3, 2),
		],
	}


static func chart_112() -> Dictionary:
	# Flood 2. The dock lamp never enters the lintel. The south lamp stops
	# on the lintel's waterline. A shutter there passes and wakes a hull.
	return {
		"id": "112",
		"harbor": LINTEL,
		"title": "The Wet Stop",
		"teach": "The lintel's row is flooded. The beam stops there and does not enter. The dock that must light is reached without entering that cell. A shutter in that cell passes and the chart fails.",
		"win": "The dock is lit, and the flooded lintel holds the beam.",
		"cols": 7,
		"rows": 6,
		"tide_phases": [2],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 1, "E", "white"),
			_lantern("B", 0, 3, "E", "white"),
		],
		"docks": [_dock("W", 4, 0, "white")],
		"boats": [
			_boat("He", 5, 3),
			_boat("Hw", 6, 1),
			_boat("Hs", 6, 3),
		],
		"fixtures": [
			_fixture("F", "mirror", 2, 3, 90),
			_fixture("T", "tide_mirror", 2, 4, 90),
			_fixture("G", "shutter", 3, 4, 0),
			_fixture("E", "tide_mirror", 5, 4, 0),
			_fixture("S", "tide_mirror", 4, 5, 90),
			_fixture("Gs", "shutter", 5, 5, 0),
			_fixture("S2", "tide_mirror", 6, 5, 0),
			_fixture("Gn", "shutter", 6, 4, 0),
		],
		"pieces": [
			_mirror("M", "Dock mirror", 4, 1, 90, 0),
			_lintel("N", "Lintel", 4, 4),
		],
	}


static func chart_113() -> Dictionary:
	# White and blue pass straight through one dry lintel. A stain paints
	# both and misses the dock that wanted the other color. Red is the same
	# pass: the rule test recolors the white lamp.
	return {
		"id": "113",
		"harbor": LINTEL,
		"title": "Color Kept",
		"teach": "The dry lintel keeps red, blue, and white. White and blue pass straight onto their docks. A stain in that cell changes the color and misses the dock.",
		"win": "Both colors come through unchanged.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 3, "E", "white"),
			_lantern("B", 4, 0, "S", "blue"),
			_lantern("T", 0, 6, "E", "white"),
		],
		"docks": [
			_dock("W", 6, 3, "white"),
			_dock("Bd", 4, 6, "blue"),
		],
		"boats": [_boat("H", 2, 2)],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Side mirror", 2, 6, 0, 90),
			_lintel("N", "Lintel", 4, 3),
		],
	}


static func chart_114() -> Dictionary:
	# Two straight passes. A mirror turns both aside. A vane can keep only
	# one direction, so the other dock goes dark.
	return {
		"id": "114",
		"harbor": LINTEL,
		"title": "No Turn",
		"teach": "The dry lintel does not change direction. White goes straight east and blue goes straight south. A mirror or a vane in that cell turns the beam and misses the dock straight ahead.",
		"win": "Both beams leave the lintel the way they entered.",
		"cols": 6,
		"rows": 6,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 3, "E", "white"),
			_lantern("B", 3, 0, "S", "blue"),
			_lantern("T", 0, 1, "E", "white"),
		],
		"docks": [
			_dock("W", 5, 3, "white"),
			_dock("Bd", 3, 5, "blue"),
		],
		"boats": [_boat("H", 5, 2)],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Side mirror", 5, 1, 90, 0),
			_lintel("N", "Lintel", 3, 3),
		],
	}


static func chart_115() -> Dictionary:
	# Flood 2 covers y >= 4. The lintel is on that line. The dock is on a
	# dry row and is lit by the high lamp. A shutter would carry the low
	# beam onto a dry hull.
	return {
		"id": "115",
		"harbor": LINTEL,
		"title": "Above the Flood",
		"teach": "The flood covers the lintel and leaves the dock's row dry. The beam stops at the lintel. The dock is lit without entering that cell. A shutter would carry the beam onto a hull on the dry row, and that hull must stay dark.",
		"win": "The high dock is lit, and the flooded lintel stops the low beam.",
		"cols": 7,
		"rows": 6,
		"tide_phases": [2],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 1, "E", "white"),
			_lantern("B", 0, 3, "E", "white"),
		],
		"docks": [_dock("W", 5, 0, "white")],
		"boats": [
			_boat("He", 4, 3),
			_boat("Hn", 3, 3),
			_boat("Hs", 5, 3),
		],
		"fixtures": [
			_fixture("F", "mirror", 1, 3, 90),
			_fixture("T", "tide_mirror", 1, 4, 90),
			_fixture("G", "shutter", 2, 4, 0),
			_fixture("Te", "tide_mirror", 4, 4, 0),
			_fixture("Ss", "tide_mirror", 3, 5, 90),
			_fixture("Gs", "shutter", 4, 5, 0),
			_fixture("S2", "tide_mirror", 5, 5, 0),
			_fixture("Gn", "shutter", 5, 4, 0),
		],
		"pieces": [
			_mirror("M", "Dock mirror", 5, 1, 90, 0),
			_lintel("N", "Lintel", 3, 4),
		],
	}


static func chart_116() -> Dictionary:
	# Both lintels are dry. The eastbound beam passes through both. A weir
	# in the first cell stops because that row is dry.
	return {
		"id": "116",
		"harbor": LINTEL,
		"title": "Two Lintels",
		"teach": "Both lintels are dry. The beam passes straight through both onto the dock. A weir in the first cell stops, because that row is dry, and the chart fails.",
		"win": "The beam walks through both dry lintels.",
		"cols": 7,
		"rows": 6,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 2, "E", "white"),
			_lantern("Ba", 2, 0, "S", "blue"),
			_lantern("Bb", 4, 0, "S", "blue"),
			_lantern("T", 0, 1, "E", "white"),
		],
		"docks": [
			_dock("W", 6, 2, "white"),
			_dock("Da", 2, 5, "blue"),
			_dock("Db", 4, 5, "blue"),
		],
		"boats": [_boat("H", 5, 0)],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Side mirror", 5, 1, 0, 90),
			_lintel("N1", "First lintel", 2, 2),
			_lintel("N2", "Second lintel", 4, 2),
		],
	}


static func chart_117() -> Dictionary:
	# Rows 7. Index 1 floods y >= 5. The lintel is on that line. The dock
	# one column east sits on the dry row and is lit by the high lamp.
	return {
		"id": "117",
		"harbor": LINTEL,
		"title": "The Held Lintel",
		"teach": "Tide index 1, flood 2, with the flood line at y >= 5. The lintel is flooded. The dock one column ahead, on the dry row, is lit without entering the lintel. A shutter in that cell misses it and wakes the hull. Index 0 wakes the south hull. Index 2 covers the dock.",
		"win": "The middle mark holds the lintel and the dry dock.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0, 2, 3],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("Ld", 0, 4, "E", "white"),
			_lantern("Lt", 3, 3, "S", "white"),
			_lantern("Lb", 0, 6, "E", "white"),
			_lantern("Lm", 0, 0, "E", "white"),
		],
		"docks": [_dock("W", 4, 4, "white")],
		"boats": [
			_boat("Hs", 5, 4),
			_boat("Hb", 2, 6),
			_boat("Hm", 2, 1),
		],
		"fixtures": [
			_fixture("T1", "tide_mirror", 3, 6, 90),
			_fixture("G1", "shutter", 4, 6, 0),
			_fixture("T2", "tide_mirror", 5, 6, 0),
			_fixture("G2", "shutter", 5, 5, 0),
		],
		"pieces": [
			_mirror("M", "North mirror", 2, 0, 90, 0),
			_lintel("N", "Lintel", 3, 5),
		],
	}


static func chart_118() -> Dictionary:
	# The lintel and the shutter trade places. The shutter starts on the
	# line and stops the beam. On the line, the dry lintel passes straight.
	# Stacking both pieces on one cell does not clear.
	return {
		"id": "118",
		"harbor": LINTEL,
		"title": "The Lintel Mark",
		"teach": "Move the lintel from the side socket onto the line, and move the shutter off that line. Only the straight dry pass hits the dock. The socket it starts in does not. A shutter left on the line stops the beam.",
		"win": "The lintel stands on the line, and both colors pass.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 3, "E", "white"),
			_lantern("B", 3, 0, "S", "blue"),
		],
		"docks": [
			_dock("W", 6, 3, "white"),
			_dock("Bd", 3, 6, "blue"),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_movable("N", "Lintel", "lintel", [["side", 5, 0], ["line", 3, 3]], "side", "line"),
			_movable("G", "Line shutter", "shutter", [["line", 3, 3], ["side", 5, 0]], "line", "side"),
		],
	}


static func chart_119() -> Dictionary:
	# Tide index 0, flood 0. White travels south through the dry mullion.
	# Blue travels east and stops on the edge. The dock catches only white,
	# so a vane that turns blue south runs on into the hull.
	return {
		"id": "119",
		"harbor": MULLION,
		"title": "The Dry Mullion",
		"teach": "Tide index 0, flood 0. A north-south beam passes straight through the dry mullion onto its dock, and an east-west beam stops. White stays white and blue stays blue. A lintel lets the east-west beam through and misses. A shutter, weir, sluice, well, siphon, stain, mirror, or vane in that cell also misses.",
		"win": "The dry mullion passes white south and stops blue.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("W", 3, 0, "S", "white"),
			_lantern("B", 0, 2, "E", "blue"),
			_lantern("T", 0, 6, "E", "white"),
		],
		"docks": [_dock("Wd", 3, 4, "white", true)],
		"boats": [
			_boat("Hs", 3, 6),
			_boat("He", 6, 2),
			_boat("Hn", 2, 1),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Side mirror", 2, 6, 0, 90),
			_mullion("U", "Mullion", 3, 2),
		],
	}


static func chart_120() -> Dictionary:
	# Rows 7, flood 2, so y >= 5 is under water. The mullion is on that line.
	# The low beam arrives from the south, traveling north, and stops. The
	# high lamp lights the dock without entering the mullion.
	return {
		"id": "120",
		"harbor": MULLION,
		"title": "The Wet Stop",
		"teach": "The mullion's row is flooded. The north-south beam stops there and does not enter. The dock that must light is reached without entering that cell. A shutter in that cell passes and the chart fails. A flooded lintel, vane, or mirror still stops at the waterline and still clears. A south-facing weir or sluice retraces into the lamp and still clears.",
		"win": "The dock is lit, and the flooded mullion holds the northbound beam.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [2],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("H", 0, 1, "E", "white"),
			_lantern("L", 0, 4, "S", "white"),
		],
		"docks": [_dock("W", 4, 0, "white")],
		"boats": [
			_boat("Hn", 3, 4),
			_boat("He", 4, 4),
			_boat("Hw", 2, 4),
		],
		"fixtures": [
			_fixture("S0", "shutter", 0, 5, 0),
			_fixture("T0", "tide_mirror", 0, 6, 90),
			_fixture("S1", "shutter", 1, 6, 0),
			_fixture("S2", "shutter", 2, 6, 0),
			_fixture("T1", "tide_mirror", 3, 6, 0),
			_fixture("Te", "tide_mirror", 4, 5, 0),
			_fixture("Tw", "tide_mirror", 2, 5, 90),
		],
		"pieces": [
			_mirror("M", "Dock mirror", 4, 1, 90, 0),
			_mullion("U", "Mullion", 3, 5),
		],
	}


static func chart_121() -> Dictionary:
	# White travels south and blue travels north through one dry mullion.
	# Each dock keeps its own color and lets the other color through, so the
	# two beams can cross. Red travels east and stops.
	return {
		"id": "121",
		"harbor": MULLION,
		"title": "Color Kept",
		"teach": "The dry mullion keeps red, blue, and white. The north-south beams pass straight onto their docks. The east-west beam stops. A stain changes the color and misses. A lintel lets the east-west beam through and misses. Each dock holds its own color and lets the other color through.",
		"win": "White and blue come through unchanged, and red stops.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("W", 3, 0, "S", "white"),
			_lantern("B", 3, 6, "N", "blue"),
			_lantern("R", 0, 3, "E", "red"),
			_lantern("T", 0, 2, "E", "white"),
		],
		"docks": [
			_dock("Bd", 3, 1, "blue", true),
			_dock("Wd", 3, 5, "white", true),
		],
		"boats": [
			_boat("He", 6, 3),
			_boat("Hn", 5, 0),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Side mirror", 5, 2, 0, 90),
			_mullion("U", "Mullion", 3, 3),
		],
	}


static func chart_122() -> Dictionary:
	# White goes straight south. Blue stops instead of turning. A mirror or a
	# vane swings a beam off the dock that the stop is holding.
	return {
		"id": "122",
		"harbor": MULLION,
		"title": "No Turn",
		"teach": "The dry mullion does not change direction. The north-south beam goes straight. The east-west beam stops instead of turning. A mirror or a vane in that cell turns a beam and misses the dock that depends on the stop. A lintel lets the east-west beam through and misses.",
		"win": "White goes straight, and blue stops.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("W", 3, 1, "S", "white"),
			_lantern("B", 0, 3, "E", "blue"),
			_lantern("T", 0, 0, "E", "white"),
		],
		"docks": [
			_dock("Wd", 3, 5, "white", true),
			_dock("Kd", 6, 3, "dark", false, true),
		],
		"boats": [
			_boat("Hs", 3, 6),
			_boat("Hn", 5, 6),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Side mirror", 5, 0, 90, 0),
			_mullion("U", "Mullion", 3, 3),
		],
	}


static func chart_123() -> Dictionary:
	# Flood 2 covers y >= 4. The mullion is on that line. The dock is on a
	# dry row. A shutter would carry the low beam onto a dry hull.
	return {
		"id": "123",
		"harbor": MULLION,
		"title": "Beside the Flood",
		"teach": "The flood covers the mullion and leaves the dock's row dry. The beam stops at the mullion. The dock is lit without entering that cell. A shutter would carry the beam onto a hull on the dry row, and that hull must stay dark. A flooded lintel, vane, or mirror still stops at the waterline and still clears. A west-facing weir or sluice retraces into the lamp and still clears.",
		"win": "The high dock is lit, and the flooded mullion stops the low beam.",
		"cols": 7,
		"rows": 6,
		"tide_phases": [2],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 1, "E", "white"),
			_lantern("B", 0, 3, "E", "white"),
		],
		"docks": [_dock("W", 5, 0, "white")],
		"boats": [
			_boat("He", 4, 3),
			_boat("Hn", 3, 3),
			_boat("Hs", 5, 3),
		],
		"fixtures": [
			_fixture("F", "mirror", 1, 3, 90),
			_fixture("T", "tide_mirror", 1, 4, 90),
			_fixture("G", "shutter", 2, 4, 0),
			_fixture("Te", "tide_mirror", 4, 4, 0),
			_fixture("Ss", "tide_mirror", 3, 5, 90),
			_fixture("Gs", "shutter", 4, 5, 0),
			_fixture("S2", "tide_mirror", 5, 5, 0),
			_fixture("Gn", "shutter", 5, 4, 0),
		],
		"pieces": [
			_mirror("M", "Dock mirror", 5, 1, 90, 0),
			_mullion("U", "Mullion", 3, 4),
		],
	}


static func chart_124() -> Dictionary:
	# Both mullions are dry and share a column. White passes south through
	# both. Blue stops on the first row and red stops on the second.
	return {
		"id": "124",
		"harbor": MULLION,
		"title": "Two Mullions",
		"teach": "Both mullions are dry. The north-south beam passes straight through both onto the dock. An east-west beam stops at the first mullion. A lintel in the first cell lets that east-west beam through and the chart fails. A weir in the first cell also fails, because that row is dry.",
		"win": "White walks through both dry mullions, and the cross beams stop.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("W", 3, 0, "S", "white"),
			_lantern("B", 0, 2, "E", "blue"),
			_lantern("R", 0, 4, "E", "red"),
			_lantern("T", 0, 1, "E", "white"),
		],
		"docks": [_dock("Wd", 3, 5, "white", true)],
		"boats": [
			_boat("Hs", 3, 6),
			_boat("He", 6, 2),
			_boat("Hr", 6, 4),
			_boat("Hn", 5, 0),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Side mirror", 5, 1, 0, 90),
			_mullion("U1", "First mullion", 3, 2),
			_mullion("U2", "Second mullion", 3, 4),
		],
	}


static func chart_125() -> Dictionary:
	# Rows 7. Index 1 floods y >= 5. The mullion is on that line. The lit
	# dock is on the dry row. A shutter carries the south beam onto the dock
	# that has to stay dark.
	return {
		"id": "125",
		"harbor": MULLION,
		"title": "The Held Mullion",
		"teach": "The mullion's row is flooded. The beam stops. The dock that must stay dark is the one a shutter would light. A shutter fails. A flooded lintel, vane, or mirror still stops at the waterline and still clears. A well, a siphon, or a weir or sluice facing north, east, or west retraces into the lamp or stops in empty water, and still clears. Tide index 1, flood 2, with the flood line at y >= 5. The dock one column ahead, on the dry row, is lit without entering the mullion. Index 0 wakes the south hull. Index 2 covers the lit dock.",
		"win": "The middle mark holds the mullion, the lit dock, and the dark dock.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0, 2, 3],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("Ld", 0, 4, "E", "white"),
			_lantern("Lt", 3, 3, "S", "white"),
			_lantern("Lb", 0, 6, "E", "white"),
			_lantern("Lm", 0, 0, "E", "white"),
		],
		"docks": [
			_dock("W", 4, 4, "white"),
			_dock("Kd", 5, 4, "dark", false, true),
		],
		"boats": [
			_boat("Hb", 2, 6),
			_boat("Hm", 2, 1),
		],
		"fixtures": [
			_fixture("T1", "tide_mirror", 3, 6, 90),
			_fixture("G1", "shutter", 4, 6, 0),
			_fixture("T2", "tide_mirror", 5, 6, 0),
			_fixture("G2", "shutter", 5, 5, 0),
		],
		"pieces": [
			_mirror("M", "North mirror", 2, 0, 90, 0),
			_mullion("U", "Mullion", 3, 5),
		],
	}


static func chart_126() -> Dictionary:
	# The mullion and the shutter trade places. On the line, the dry mullion
	# passes south and stops east. The dark dock is the east landing.
	return {
		"id": "126",
		"harbor": MULLION,
		"title": "The Mullion Mark",
		"teach": "One dry mullion, two docks. Move the mullion from the side socket onto the line, and move the shutter off that line. The solved socket passes the north-south beam onto one dock and stops the east-west beam so the other dock stays dark. The side socket misses both docks. Stacking both pieces on one cell does not clear. A lintel in the solved cell lets the east-west beam through and misses.",
		"win": "The mullion stands on the line. One dock is lit and the other stays dark.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("W", 3, 0, "S", "white"),
			_lantern("B", 0, 3, "E", "blue"),
		],
		"docks": [
			_dock("Wd", 3, 5, "white", true),
			_dock("Kd", 6, 3, "dark", false, true),
		],
		"boats": [_boat("Hs", 3, 6)],
		"fixtures": [],
		"pieces": [
			_movable("U", "Mullion", "mullion", [["side", 5, 1], ["line", 3, 3]], "side", "line"),
			_movable("G", "Line shutter", "shutter", [["line", 3, 3], ["side", 5, 1]], "line", "side"),
		],
	}


static func chart_127() -> Dictionary:
	# Tide index 0, flood 0. White travels west through the dry transom.
	# Blue travels south and stops on the edge. The dock catches only white,
	# so a vane that turns blue west runs on into the hull.
	return {
		"id": "127",
		"harbor": TRANSOM,
		"title": "The Dry Transom",
		"teach": "Tide index 0, flood 0. An east-west beam passes straight through the dry transom onto its dock, and a north-south beam stops. White stays white and blue stays blue. A mullion lets the north-south beam through and misses. A lintel does too. A shutter, weir, sluice, well, siphon, stain, mirror, or vane in that cell also misses.",
		"win": "The dry transom passes white west and stops blue.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("W", 6, 3, "W", "white"),
			_lantern("B", 4, 0, "S", "blue"),
			_lantern("T", 0, 0, "S", "white"),
		],
		"docks": [_dock("Wd", 2, 3, "white", true)],
		"boats": [
			_boat("Hs", 4, 6),
			_boat("Ht", 5, 2),
			_boat("Hb", 0, 3),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Side mirror", 0, 2, 90, 0),
			_transom("O", "Transom", 4, 3),
		],
	}


static func chart_128() -> Dictionary:
	# Rows 7, flood 2, so y >= 5 is under water. The transom is on the bottom
	# row. The low beam arrives from the west, traveling east, and stops.
	# The high lamp lights the dock without entering the transom.
	return {
		"id": "128",
		"harbor": TRANSOM,
		"title": "The Wet Stop",
		"teach": "The transom's row is flooded. The east-west beam stops there and does not enter. The dock that must light is reached without entering that cell. A shutter in that cell passes and the chart fails. A flooded mullion, lintel, vane, or mirror still stops at the waterline and still clears. A well, a siphon, or a weir or sluice facing north, south, or west retraces into the lamp, leaves the board, or stops in empty water, and still clears.",
		"win": "The dock is lit, and the flooded transom holds the eastbound beam.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [2],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("H", 0, 1, "E", "white"),
			_lantern("L", 0, 4, "S", "white"),
		],
		"docks": [_dock("W", 4, 0, "white")],
		"boats": [_boat("He", 4, 4)],
		"fixtures": [
			_fixture("G0", "shutter", 0, 5, 0),
			_fixture("T0", "tide_mirror", 0, 6, 90),
			_fixture("G1", "shutter", 1, 6, 0),
			_fixture("G2", "shutter", 2, 6, 0),
			_fixture("Te", "tide_mirror", 4, 6, 0),
			_fixture("Gs", "shutter", 4, 5, 0),
		],
		"pieces": [
			_mirror("M", "Dock mirror", 4, 1, 90, 0),
			_transom("O", "Transom", 3, 6),
		],
	}


static func chart_129() -> Dictionary:
	# White travels west and blue travels east through one dry transom.
	# Each dock keeps its own color and lets the other color through, so the
	# two beams can cross. Red travels south and stops.
	return {
		"id": "129",
		"harbor": TRANSOM,
		"title": "Color Kept",
		"teach": "The dry transom keeps red, blue, and white. The east-west beams pass straight onto their docks. The north-south beam stops. A stain changes the color and misses. A mullion and a lintel let the north-south beam through and miss. Each dock holds its own color and lets the other color through.",
		"win": "White and blue come through unchanged, and red stops.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("W", 6, 3, "W", "white"),
			_lantern("B", 0, 3, "E", "blue"),
			_lantern("R", 3, 0, "S", "red"),
			_lantern("T", 4, 0, "S", "white"),
		],
		"docks": [
			_dock("Bd", 5, 3, "blue", true),
			_dock("Wd", 1, 3, "white", true),
		],
		"boats": [
			_boat("Hs", 3, 6),
			_boat("Ht", 6, 5),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Side mirror", 4, 5, 90, 0),
			_transom("O", "Transom", 3, 3),
		],
	}


static func chart_130() -> Dictionary:
	# White goes straight west. Blue stops instead of turning. A mirror or a
	# vane swings a beam off the dock that the stop is holding.
	return {
		"id": "130",
		"harbor": TRANSOM,
		"title": "No Turn",
		"teach": "The dry transom does not change direction. The east-west beam goes straight. The north-south beam stops instead of turning. A mirror or a vane in that cell turns a beam and misses the dock that depends on the stop. A mullion and a lintel let the north-south beam through and miss.",
		"win": "White goes straight, and blue stops.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("W", 5, 3, "W", "white"),
			_lantern("B", 3, 0, "S", "blue"),
			_lantern("T", 6, 0, "S", "white"),
		],
		"docks": [
			_dock("Wd", 1, 3, "white", true),
			_dock("Kd", 3, 6, "dark", false, true),
		],
		"boats": [
			_boat("Hb", 0, 3),
			_boat("Ht", 0, 5),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Side mirror", 6, 5, 0, 90),
			_transom("O", "Transom", 3, 3),
		],
	}


static func chart_131() -> Dictionary:
	# Flood 2 covers y >= 4. The transom is on that line. The dock is on a
	# dry row. The low beam arrives from the west. A shutter would carry it
	# onto a dry hull.
	return {
		"id": "131",
		"harbor": TRANSOM,
		"title": "Beside the Flood",
		"teach": "The flood covers the transom and leaves the dock's row dry. The beam stops at the transom. The dock is lit without entering that cell. A shutter would carry the beam onto a hull on the dry row, and that hull must stay dark. A flooded mullion, lintel, vane, or mirror still stops at the waterline and still clears. A west-facing weir or sluice retraces into the lamp and still clears.",
		"win": "The high dock is lit, and the flooded transom stops the low beam.",
		"cols": 7,
		"rows": 6,
		"tide_phases": [2],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("L", 0, 1, "E", "white"),
			_lantern("B", 0, 3, "E", "white"),
		],
		"docks": [_dock("W", 5, 0, "white")],
		"boats": [
			_boat("He", 4, 3),
			_boat("Hn", 3, 3),
			_boat("Hs", 5, 3),
		],
		"fixtures": [
			_fixture("F", "mirror", 1, 3, 90),
			_fixture("T", "tide_mirror", 1, 4, 90),
			_fixture("G", "shutter", 2, 4, 0),
			_fixture("Te", "tide_mirror", 4, 4, 0),
			_fixture("Ss", "tide_mirror", 3, 5, 90),
			_fixture("Gs", "shutter", 4, 5, 0),
			_fixture("S2", "tide_mirror", 5, 5, 0),
			_fixture("Gn", "shutter", 5, 4, 0),
		],
		"pieces": [
			_mirror("M", "Dock mirror", 5, 1, 90, 0),
			_transom("O", "Transom", 3, 4),
		],
	}


static func chart_132() -> Dictionary:
	# Both transoms are dry and share a row. White passes west through both.
	# Blue stops on the first transom and red stops on the second.
	return {
		"id": "132",
		"harbor": TRANSOM,
		"title": "Two Transoms",
		"teach": "Both transoms are dry. The east-west beam passes straight through both onto the dock. A north-south beam stops at the first transom. A mullion or a lintel in the first cell lets that north-south beam through and the chart fails. A weir in the first cell also fails, because that row is dry.",
		"win": "White walks through both dry transoms, and the cross beams stop.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("W", 6, 3, "W", "white"),
			_lantern("B", 4, 0, "S", "blue"),
			_lantern("R", 2, 0, "S", "red"),
			_lantern("T", 5, 0, "S", "white"),
		],
		"docks": [_dock("Wd", 1, 3, "white", true)],
		"boats": [
			_boat("Hs", 4, 6),
			_boat("Hr", 2, 6),
			_boat("Hb", 0, 3),
			_boat("Ht", 6, 5),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Side mirror", 5, 5, 90, 0),
			_transom("O1", "First transom", 4, 3),
			_transom("O2", "Second transom", 2, 3),
		],
	}


static func chart_133() -> Dictionary:
	# Rows 7. Index 1 floods y >= 5. The transom is on that line. The lit
	# dock is on the dry row. A shutter carries the south beam onto the dock
	# that has to stay dark.
	return {
		"id": "133",
		"harbor": TRANSOM,
		"title": "The Held Transom",
		"teach": "The transom's row is flooded. The beam stops. The dock that must stay dark is the one a shutter would light. A shutter fails. A flooded mullion, lintel, vane, or mirror still stops at the waterline and still clears. A well, a siphon, or a weir or sluice facing north, east, or west retraces into the lamp or stops in empty water, and still clears. Tide index 1, flood 2, with the flood line at y >= 5. The dock on the dry row is lit without entering the transom. Index 0 wakes the south hull. Index 2 covers the lit dock.",
		"win": "The middle mark holds the transom, the lit dock, and the dark dock.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0, 2, 3],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("Ld", 0, 4, "E", "white"),
			_lantern("Lt", 3, 3, "S", "white"),
			_lantern("Lb", 0, 6, "E", "white"),
			_lantern("Lm", 0, 0, "E", "white"),
		],
		"docks": [
			_dock("W", 4, 4, "white"),
			_dock("Kd", 5, 4, "dark", false, true),
		],
		"boats": [
			_boat("Hb", 2, 6),
			_boat("Hm", 2, 1),
		],
		"fixtures": [
			_fixture("T1", "tide_mirror", 3, 6, 90),
			_fixture("G1", "shutter", 4, 6, 0),
			_fixture("T2", "tide_mirror", 5, 6, 0),
			_fixture("G2", "shutter", 5, 5, 0),
		],
		"pieces": [
			_mirror("M", "North mirror", 2, 0, 90, 0),
			_transom("O", "Transom", 3, 5),
		],
	}


static func chart_134() -> Dictionary:
	# The transom and the shutter trade places. On the line, the dry transom
	# passes west and stops south. The dark dock is the south landing.
	return {
		"id": "134",
		"harbor": TRANSOM,
		"title": "The Transom Mark",
		"teach": "One dry transom, two docks. Move the transom from the side socket onto the line, and move the shutter off that line. The solved socket passes the east-west beam onto one dock and stops the north-south beam so the other dock stays dark. The side socket misses both docks. Stacking both pieces on one cell does not clear. A mullion or a lintel in the solved cell lets the north-south beam through and misses.",
		"win": "The transom stands on the line. One dock is lit and the other stays dark.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("W", 6, 3, "W", "white"),
			_lantern("B", 3, 0, "S", "blue"),
		],
		"docks": [
			_dock("Wd", 1, 3, "white", true),
			_dock("Kd", 3, 6, "dark", false, true),
		],
		"boats": [_boat("Hb", 0, 3)],
		"fixtures": [],
		"pieces": [
			_movable("O", "Transom", "transom", [["side", 5, 5], ["line", 3, 3]], "side", "line"),
			_movable("G", "Line shutter", "shutter", [["line", 3, 3], ["side", 5, 5]], "line", "side"),
		],
	}


static func chart_135() -> Dictionary:
	# Tide index 0, flood 0. The casement faces east. White travels east
	# through it. Blue travels west and stops on the edge. Red from the north
	# stops, so a vane that turns that flank east lights the red mark.
	return {
		"id": "135",
		"harbor": CASEMENT,
		"title": "The Dry Casement",
		"teach": "Tide index 0, flood 0. The casement faces east. An eastbound beam passes straight through onto its dock. A westbound beam stops. White stays white and blue stays blue. A transom lets the westbound beam through and misses. A mullion stops the eastbound beam. A lintel lets both through, and the extra hit misses. A shutter, weir, sluice, well, siphon, stain, mirror, or vane in that cell also misses.",
		"win": "The dry casement passes white east and stops blue.",
		"cols": 8,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("W", 2, 0, "S", "white"),
			_lantern("B", 7, 3, "W", "blue"),
			_lantern("R", 3, 1, "S", "red"),
		],
		"docks": [
			_dock("Wd", 5, 3, "white", true),
			_dock("Kb", 2, 2, "blue", true, true),
			_dock("Kr", 6, 3, "red", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 3, 0, 90),
			_casement("C", "Casement", 3, 3, 0, 90),
		],
	}


static func chart_136() -> Dictionary:
	# The chart opens under water, where every beam stops outside the cell.
	# The solution lowers the tide. Dry, only the east facing passes. Facing
	# west sends the opposite beam onto the blue mark. A transom does that
	# even when the casement would have stopped it.
	return {
		"id": "136",
		"harbor": CASEMENT,
		"title": "The Wet Stop",
		"teach": "The casement opens under water, so every beam stops outside the cell. Lower the tide. Dry, it faces east and only that beam passes onto the dock. A dry casement facing west passes the westbound beam onto the wrong dock. Flooding the row again stops every beam, and the dock goes dark. A transom, a mullion, and a lintel are also shut under water. On this same board at the dry tide, only the facing beam passes, and a transom also passes the opposite beam and misses. A mullion stops the eastbound beam. A lintel lets both through.",
		"win": "The tide is low. The casement faces east, and only that beam reaches the dock.",
		"cols": 8,
		"rows": 7,
		"tide_phases": [0, 2],
		"start_tide_index": 1,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("W", 0, 5, "E", "white"),
			_lantern("B", 7, 5, "W", "blue"),
			_lantern("R", 3, 4, "S", "red"),
		],
		"docks": [
			_dock("Wd", 5, 5, "white", true),
			_dock("Kb", 1, 5, "blue", true, true),
			_dock("Kr", 6, 5, "red", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_casement("C", "Casement", 3, 5, 0, 90),
		],
	}


static func chart_137() -> Dictionary:
	# White travels east and stays white. The book tests recolor the same pass
	# to red and to blue. A stain paints the pass and misses.
	return {
		"id": "137",
		"harbor": CASEMENT,
		"title": "Color Kept",
		"teach": "The facing pass does not recolor. Red stays red, blue stays blue, and white stays white. The eastbound beam passes straight onto its dock. The westbound beam stops. A stain in that cell recolors and misses. A transom lets the westbound beam through and misses. A mullion stops the eastbound beam. A lintel lets both through.",
		"win": "The color that enters the casement is the color that leaves it.",
		"cols": 8,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("W", 2, 0, "S", "white"),
			_lantern("B", 7, 3, "W", "blue"),
			_lantern("R", 3, 1, "S", "red"),
		],
		"docks": [
			_dock("Wd", 5, 3, "white", true),
			_dock("Kb", 2, 2, "blue", true, true),
			_dock("Kr", 6, 3, "red", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 3, 0, 90),
			_casement("C", "Casement", 3, 3, 180, 90),
		],
	}


static func chart_138() -> Dictionary:
	# White goes straight east. It does not turn. A vane, a mirror, or a prism
	# swings it off the dock. The westbound beam stops instead of passing.
	return {
		"id": "138",
		"harbor": CASEMENT,
		"title": "No Turn",
		"teach": "The facing pass does not turn. The eastbound beam goes straight onto its dock. The westbound beam stops. A vane, a mirror, or a prism in that cell turns and misses. A transom passes the opposite direction as well and misses. A mullion stops the eastbound beam. A lintel lets both through.",
		"win": "White goes straight east, and blue stops.",
		"cols": 8,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("W", 2, 0, "S", "white"),
			_lantern("B", 7, 3, "W", "blue"),
			_lantern("R", 3, 1, "S", "red"),
		],
		"docks": [
			_dock("Wd", 5, 3, "white", true),
			_dock("Kb", 2, 2, "blue", true, true),
			_dock("Kr", 6, 3, "red", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 3, 0, 90),
			_casement("C", "Casement", 3, 3, 270, 90),
		],
	}


static func chart_139() -> Dictionary:
	# Flood 2 covers y >= 4. The casement stays on the dry row above it.
	# East passes. West stops. A southbound beam from the dry row stops at
	# the flooded row's waterline.
	return {
		"id": "139",
		"harbor": CASEMENT,
		"title": "Beside the Flood",
		"teach": "The casement's own row is dry and the neighboring row is flooded. The facing beam passes. A beam from the flooded row still stops at the waterline and does not enter that cell. A transom on the dry row lets the opposite beam through and misses. A mullion stops the eastbound beam. A lintel lets both through.",
		"win": "The eastbound beam passes on the dry row, and the beam into the flood stops.",
		"cols": 8,
		"rows": 6,
		"tide_phases": [2],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("W", 0, 3, "E", "white"),
			_lantern("B", 7, 3, "W", "blue"),
			_lantern("R", 3, 1, "S", "red"),
			_lantern("F", 6, 2, "S", "white"),
		],
		"docks": [
			_dock("Wd", 4, 3, "white", true),
			_dock("Kb", 1, 3, "blue", true, true),
			_dock("Kr", 5, 3, "red", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_casement("C", "Casement", 3, 3, 0, 90),
		],
	}


static func chart_140() -> Dictionary:
	# One casement faces east and one faces north. Each passes only its own
	# facing. The opposite of each is held by a dark mark.
	return {
		"id": "140",
		"harbor": CASEMENT,
		"title": "Two Casements",
		"teach": "One casement faces east and one faces north. Each passes only its own facing. A transom passes the eastbound beam and stops the northbound beam, so one dock misses. A mullion does the opposite. A lintel passes both and also passes the two opposite beams, so the extra hits miss.",
		"win": "East stays east and north stays north. Each opposite beam stops.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("We", 0, 5, "E", "white"),
			_lantern("Bw", 6, 5, "W", "blue"),
			_lantern("Re", 3, 3, "S", "red"),
			_lantern("Wn", 2, 6, "N", "white"),
			_lantern("Bs", 2, 0, "S", "blue"),
			_lantern("Rn", 4, 4, "W", "red"),
		],
		"docks": [
			_dock("Wd", 4, 5, "white", true),
			_dock("Nd", 2, 2, "white", true),
			_dock("Kb", 1, 5, "blue", true, true),
			_dock("Kn", 2, 5, "blue", true, true),
			_dock("Kr", 5, 5, "red", true, true),
			_dock("Kf", 2, 1, "red", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_casement("E", "East casement", 3, 5, 0, 90),
			_casement("N", "North casement", 2, 4, 90, 0),
		],
	}


static func chart_141() -> Dictionary:
	# Three tide marks, like The Held Transom. The middle mark leaves the
	# casement's row dry, so the facing pass can land. Low water wakes the
	# south hull. High water covers the casement.
	return {
		"id": "141",
		"harbor": CASEMENT,
		"title": "The Held Casement",
		"teach": "Place the tide on the middle mark and turn the casement to the east facing. The beam passes only that way. Low water wakes the south hull. High water covers the casement and the dock goes dark. A transom in that cell passes the opposite direction and misses. A mullion misses the facing axis. A lintel lets the opposite beam through.",
		"win": "The middle mark holds the east casement. White passes and blue stops.",
		"cols": 9,
		"rows": 7,
		"tide_phases": [0, 1, 4],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("W", 2, 1, "S", "white"),
			_lantern("B", 8, 3, "W", "blue"),
			_lantern("R", 4, 1, "S", "red"),
			_lantern("Lb", 0, 6, "E", "white"),
		],
		"docks": [
			_dock("Wd", 6, 3, "white", true),
			_dock("Kb", 2, 2, "blue", true, true),
			_dock("Kr", 7, 3, "red", true, true),
		],
		"boats": [
			_boat("Hb", 2, 6),
		],
		"fixtures": [],
		"pieces": [
			_mirror("M", "Feed mirror", 2, 3, 0, 90),
			_casement("C", "Casement", 4, 3, 0, 90),
		],
	}


static func chart_142() -> Dictionary:
	# The casement and the shutter trade places, as on The Transom Mark.
	# On the line the casement faces west. Only that beam counts. The
	# eastbound beam must not, and a transom lets it through.
	return {
		"id": "142",
		"harbor": CASEMENT,
		"title": "The Casement Mark",
		"teach": "One dry casement, two sockets. Move the casement from the side socket onto the line, turn it to face west, and move the shutter off that line. The mark is satisfied only by the facing beam. The opposite beam must not count. The side socket misses both docks. Stacking both pieces on one cell does not clear. A transom lets that opposite beam in and misses. A mullion stops the facing beam. A lintel lets the opposite beam through.",
		"win": "The casement stands on the line, facing west. One dock is lit and the others stay dark.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("W", 6, 3, "W", "white"),
			_lantern("Be", 0, 3, "E", "blue"),
			_lantern("R", 3, 0, "S", "red"),
		],
		"docks": [
			_dock("Wd", 2, 3, "white", true),
			_dock("Kt", 1, 3, "red", true, true),
			_dock("Ke", 5, 3, "blue", true, true),
			_dock("Kd", 3, 6, "dark", false, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_placed("C", "Casement", "casement", [["side", 5, 5], ["line", 3, 3]], "side", "line", 0, 270),
			_placed("G", "Line shutter", "shutter", [["line", 3, 3], ["side", 5, 5]], "line", "side", 0, 0),
		],
	}


static func chart_143() -> Dictionary:
	# Tide index 0, flood 0. A north jamb passes the outbound beam and the
	# return. The chart opens on the east-west axis, which stops both.
	return {
		"id": "143",
		"harbor": JAMB,
		"title": "The Dry Jamb",
		"teach": "Tide index 0, flood 0. A dry north jamb passes both the outbound beam and the return. White stays white and blue stays blue. A casement in that cell refuses the return. A transom stops both north-south beams and lets the east-west beam through. A lintel lets the east-west beam through. A shutter, weir, sluice, well, siphon, stain, mirror, or vane in that cell also misses.",
		"win": "The dry north jamb passes the outbound beam and the return.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Ws", 3, 6, "N", "white"),
			_lantern("Bn", 3, 0, "S", "blue"),
			_lantern("Re", 0, 3, "E", "red"),
		],
		"docks": [
			_dock("Wd", 3, 1, "white", true),
			_dock("Bd", 3, 5, "blue", true),
			_dock("Ke", 6, 3, "dark", false, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_jamb("J", "Jamb", 3, 3, 90, 0),
		],
	}


static func chart_144() -> Dictionary:
	# The chart opens under water. The beam from the dry row stops at the
	# waterline. The solution lowers the tide, and the north-south axis passes
	# both ways.
	return {
		"id": "144",
		"harbor": JAMB,
		"title": "The Wet Stop",
		"teach": "The jamb opens under water, so every beam stops at the waterline and does not enter. Lower the tide. Dry, the north-south axis passes both ways. A shutter would pass while flooded. A well, a siphon, a sluice, or a weir would carry the beam. A casement refuses the return. A transom lets the east-west beam through.",
		"win": "The tide is low. The jamb passes both ways, and the east-west beam stops.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0, 3],
		"start_tide_index": 1,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Ws", 3, 1, "S", "white"),
			_lantern("Bn", 3, 6, "N", "blue"),
			_lantern("Re", 0, 4, "E", "red"),
		],
		"docks": [
			_dock("Bd", 3, 2, "blue", true),
			_dock("Wd", 3, 5, "white", true),
			_dock("Ke", 6, 4, "dark", false, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_jamb("J", "Jamb", 3, 4, 90, 0),
		],
	}


static func chart_145() -> Dictionary:
	# Red goes north and stays red. Blue goes south and stays blue. A stain
	# paints both passes the same color.
	return {
		"id": "145",
		"harbor": JAMB,
		"title": "Color Kept",
		"teach": "The dry jamb keeps red, blue, and white. Red stays red and blue stays blue. White stays white. A stain or a weir would change the color. A casement refuses the return. A transom lets the east-west beam through. A lintel lets that beam through.",
		"win": "The color that enters the jamb is the color that leaves it.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Rs", 3, 6, "N", "red"),
			_lantern("Bn", 3, 0, "S", "blue"),
			_lantern("Re", 0, 3, "E", "red"),
		],
		"docks": [
			_dock("Rd", 3, 1, "red", true),
			_dock("Bd", 3, 5, "blue", true),
			_dock("Ke", 6, 3, "dark", false, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_jamb("J", "Jamb", 3, 3, 270, 0),
		],
	}


static func chart_146() -> Dictionary:
	# White goes straight north. Blue goes straight south. Neither beam turns.
	return {
		"id": "146",
		"harbor": JAMB,
		"title": "No Turn",
		"teach": "The beam leaves on the same side it entered. It does not turn. A prism, a vane, a sluice, or a mirror would turn it. A casement refuses the return. A transom lets the east-west beam through.",
		"win": "White goes straight north, and blue goes straight south.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Ws", 3, 6, "N", "white"),
			_lantern("Bn", 3, 0, "S", "blue"),
			_lantern("Re", 0, 3, "E", "red"),
		],
		"docks": [
			_dock("Wd", 3, 1, "white", true),
			_dock("Bd", 3, 5, "blue", true),
			_dock("Ke", 6, 3, "dark", false, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_jamb("J", "Jamb", 3, 3, 90, 0),
		],
	}


static func chart_147() -> Dictionary:
	# Flood 2 covers y >= 4. The jamb stays on the dry row and opens east-west.
	# A separate beam stops at the flooded row's waterline.
	return {
		"id": "147",
		"harbor": JAMB,
		"title": "Beside the Flood",
		"teach": "The jamb's own row is dry, so both east and west pass. The next flooded cell that is not a flood carrier still stops the beam at the waterline. A mullion stops the east-west beam. A casement refuses the return. A lintel lets the north-south beam through.",
		"win": "Both east and west pass on the dry row, and the beam into the flood stops.",
		"cols": 8,
		"rows": 6,
		"tide_phases": [2],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("We", 0, 2, "E", "white"),
			_lantern("Bw", 7, 2, "W", "blue"),
			_lantern("Rs", 3, 0, "S", "red"),
			_lantern("F", 6, 3, "S", "white"),
		],
		"docks": [
			_dock("Wd", 5, 2, "white", true),
			_dock("Bd", 1, 2, "blue", true),
			_dock("Kd", 3, 3, "dark", false, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_jamb("J", "Jamb", 3, 2, 0, 90),
		],
	}


static func chart_148() -> Dictionary:
	# One jamb opens east-west and one opens north-south. Each axis is required
	# in both directions, and each blocked axis hits a dark mark.
	return {
		"id": "148",
		"harbor": JAMB,
		"title": "Two Jambs",
		"teach": "One jamb is open on the north-south axis and one on the east-west axis. Swapping their axes fails. A mullion cannot take the east-west seat. A transom cannot take the north-south seat. A casement refuses the return. A lintel passes the blocked axis.",
		"win": "East-west stays east-west and north-south stays north-south.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("We", 0, 5, "E", "white"),
			_lantern("Bw", 6, 5, "W", "blue"),
			_lantern("Wn", 2, 6, "N", "white"),
			_lantern("Bs", 2, 0, "S", "blue"),
			_lantern("Rn", 3, 6, "N", "red"),
			_lantern("Re", 0, 3, "E", "red"),
		],
		"docks": [
			_dock("Wd", 5, 5, "white", true),
			_dock("Bd", 1, 5, "blue", true),
			_dock("Nd", 2, 1, "white", true),
			_dock("Sd", 2, 4, "blue", true),
			_dock("Kd", 3, 1, "dark", false, true),
			_dock("Ke", 6, 3, "dark", false, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_jamb("E", "East jamb", 3, 5, 0, 90),
			_jamb("N", "North jamb", 2, 3, 90, 0),
		],
	}


static func chart_149() -> Dictionary:
	# Three tide marks. The middle mark leaves the jamb dry on the north-south
	# axis. The chart starts on the east-west axis. Low water wakes the hull.
	# High water covers the jamb.
	return {
		"id": "149",
		"harbor": JAMB,
		"title": "The Held Jamb",
		"teach": "The held facing is part of the solution. The chart starts on the other axis. Place the tide on the middle mark and open the north-south axis. Low water wakes the south hull. High water covers the jamb and the beam stops at the waterline. A casement refuses the return. A transom lets the east-west beam through. A lintel lets that beam through.",
		"win": "The middle mark holds the north-south jamb. Both directions pass, and the hull stays dark.",
		"cols": 8,
		"rows": 7,
		"tide_phases": [0, 1, 4],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("Bn", 4, 0, "S", "blue"),
			_lantern("Wn", 4, 5, "N", "white"),
			_lantern("Re", 0, 3, "E", "red"),
			_lantern("Hl", 0, 6, "E", "white"),
		],
		"docks": [
			_dock("Wd", 4, 1, "white", true),
			_dock("Bd", 4, 4, "blue", true),
			_dock("Ke", 7, 3, "dark", false, true),
		],
		"boats": [
			_boat("Hb", 3, 6),
		],
		"fixtures": [],
		"pieces": [
			_jamb("J", "Jamb", 4, 3, 90, 0),
		],
	}


static func chart_150() -> Dictionary:
	# The jamb and the shutter trade places. On the line the jamb opens
	# north-south. Both directions count. The east-west beam must not.
	return {
		"id": "150",
		"harbor": JAMB,
		"title": "The Jamb Mark",
		"teach": "Move the jamb from the side socket onto the line and open the north-south axis. The mark is satisfied only by that open axis. Both the outbound beam and the return pass. The east-west beam must not count. A casement refuses the return. A transom stops the north-south beams and lets the east-west beam through. A lintel lets the east-west beam through. A mullion passes this same axis, and it fails on an east-west seat.",
		"win": "The jamb stands on the line, open north and south. Both docks are lit and the cross beam stays dark.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Wn", 3, 6, "N", "white"),
			_lantern("Bn", 3, 0, "S", "blue"),
			_lantern("Re", 0, 3, "E", "red"),
		],
		"docks": [
			_dock("Wd", 3, 1, "white", true),
			_dock("Bd", 3, 5, "blue", true),
			_dock("Ke", 6, 3, "dark", false, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_placed("J", "Jamb", "jamb", [["side", 5, 5], ["line", 3, 3]], "side", "line", 90, 0),
			_placed("G", "Line shutter", "shutter", [["line", 3, 3], ["side", 5, 5]], "line", "side", 0, 0),
		],
	}


static func chart_151() -> Dictionary:
	# Tide index 0, flood 0. A north astragal passes north and east. The chart
	# opens on the other pair, south and west, which refuses both.
	return {
		"id": "151",
		"harbor": ASTRAGAL,
		"title": "The Dry Astragal",
		"teach": "Tide index 0, flood 0. A dry north astragal passes both the northbound beam and the eastbound beam. White stays white and red stays red. A casement in that cell refuses the eastbound beam. A jamb in that cell refuses the eastbound beam and passes the southbound return. A lintel lets that return through.",
		"win": "The dry north astragal passes north and east, and the southbound return stops.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Wn", 3, 6, "N", "white"),
			_lantern("Ee", 0, 3, "E", "red"),
			_lantern("Ss", 3, 0, "S", "blue"),
		],
		"docks": [
			_dock("Wd", 3, 1, "white", true),
			_dock("Ed", 6, 3, "red"),
			_dock("Kd", 3, 5, "blue", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_astragal("A", "Astragal", 3, 3, 180, 0),
		],
	}


static func chart_152() -> Dictionary:
	# The chart opens under water. The beam from the dry row stops at the
	# waterline. The solution lowers the tide, and north and east pass.
	return {
		"id": "152",
		"harbor": ASTRAGAL,
		"title": "The Wet Stop",
		"teach": "The astragal opens under water, so every beam stops at the waterline and does not enter. Lower the tide. Dry, the northbound beam and the eastbound beam pass. A shutter would pass while flooded. A well, a siphon, a sluice, or a weir would carry the beam. A casement refuses the eastbound beam. A jamb refuses the eastbound beam and passes the southbound return.",
		"win": "The tide is low. North and east pass, and the southbound beam stops.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0, 3],
		"start_tide_index": 1,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Ss", 3, 1, "S", "blue"),
			_lantern("Nn", 3, 6, "N", "white"),
			_lantern("Ee", 0, 4, "E", "red"),
		],
		"docks": [
			_dock("Nd", 3, 2, "white", true),
			_dock("Kd", 3, 5, "blue", true, true),
			_dock("Ed", 6, 4, "red"),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_astragal("A", "Astragal", 3, 4, 180, 0),
		],
	}


static func chart_153() -> Dictionary:
	# Red goes north and stays red. Blue goes east and stays blue.
	return {
		"id": "153",
		"harbor": ASTRAGAL,
		"title": "Color Kept",
		"teach": "The dry astragal keeps red, blue, and white. Red stays red and blue stays blue. White stays white. A stain or a weir would change the color. A casement refuses the eastbound beam. A jamb refuses the eastbound beam and passes the southbound return.",
		"win": "The color that enters the astragal is the color that leaves it.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Rs", 3, 6, "N", "red"),
			_lantern("Be", 0, 3, "E", "blue"),
			_lantern("Ss", 3, 0, "S", "blue"),
		],
		"docks": [
			_dock("Rd", 3, 1, "red", true),
			_dock("Bd", 6, 3, "blue"),
			_dock("Kd", 3, 5, "blue", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_astragal("A", "Astragal", 3, 3, 180, 0),
		],
	}


static func chart_154() -> Dictionary:
	# White goes straight north. Red goes straight east. Neither beam turns.
	return {
		"id": "154",
		"harbor": ASTRAGAL,
		"title": "No Turn",
		"teach": "The beam leaves on the same side it entered. It does not turn. A prism, a vane, a sluice, or a mirror would turn it. A casement refuses the eastbound beam. A jamb passes the southbound return.",
		"win": "White goes straight north, and red goes straight east.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Wn", 3, 6, "N", "white"),
			_lantern("Ee", 0, 3, "E", "red"),
			_lantern("Ss", 3, 0, "S", "blue"),
		],
		"docks": [
			_dock("Wd", 3, 1, "white", true),
			_dock("Ed", 6, 3, "red"),
			_dock("Kd", 3, 5, "blue", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_astragal("A", "Astragal", 3, 3, 90, 0),
		],
	}


static func chart_155() -> Dictionary:
	# Flood 2 covers y >= 4. The astragal stays on the dry row and opens
	# north and east. A separate beam stops at the flooded row's waterline.
	return {
		"id": "155",
		"harbor": ASTRAGAL,
		"title": "Beside the Flood",
		"teach": "The astragal's own row is dry, so the northbound beam and the eastbound beam pass. The next flooded cell that is not a flood carrier still stops the beam at the waterline. A mullion cannot be turned so that it passes east. A transom cannot be turned so that it passes north. A casement refuses the eastbound beam. A lintel lets the westbound beam through.",
		"win": "North and east pass on the dry row, and the beam into the flood stops.",
		"cols": 8,
		"rows": 6,
		"tide_phases": [2],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("We", 0, 2, "E", "white"),
			_lantern("Nn", 3, 3, "N", "blue"),
			_lantern("Ww", 7, 2, "W", "red"),
			_lantern("F", 6, 3, "S", "white"),
		],
		"docks": [
			_dock("Wd", 5, 2, "white", true),
			_dock("Nd", 3, 0, "blue"),
			_dock("Kd", 1, 2, "red", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_astragal("A", "Astragal", 3, 2, 180, 0),
		],
	}


static func chart_156() -> Dictionary:
	# One astragal opens north and east. The other opens south and west.
	# Swapping those facings fails. A north jamb on the first seat also passes south.
	return {
		"id": "156",
		"harbor": ASTRAGAL,
		"title": "Two Astragals",
		"teach": "One astragal is open on north and east. The other is open on south and west. Swapping their facings fails. A jamb cannot take the north-and-east seat, because a north jamb also passes south. A mullion cannot be turned so that it passes east. A transom cannot be turned so that it passes north.",
		"win": "North and east stay on the first seat. South and west stay on the second.",
		"cols": 11,
		"rows": 9,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("An", 3, 5, "N", "white"),
			_lantern("As", 3, 0, "S", "blue"),
			_lantern("Ae", 0, 3, "E", "red"),
			_lantern("Bs", 7, 2, "S", "white"),
			_lantern("Bn", 7, 8, "N", "red"),
			_lantern("Bw", 10, 5, "W", "blue"),
			_lantern("Be", 4, 5, "E", "white"),
		],
		"docks": [
			_dock("Adn", 3, 1, "white", true),
			_dock("Ads", 3, 4, "blue", true, true),
			_dock("Ade", 6, 3, "red"),
			_dock("Bds", 7, 7, "white", true),
			_dock("Bdn", 7, 4, "red", true, true),
			_dock("Bdw", 5, 5, "blue", true),
			_dock("Bde", 9, 5, "white", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_astragal("A", "North astragal", 3, 3, 180, 0),
			_astragal("B", "South astragal", 7, 5, 0, 180),
		],
	}


static func chart_157() -> Dictionary:
	# Three tide marks. The middle mark leaves the astragal dry, facing north.
	# The chart starts on the other pair. Low water wakes the hull. High water
	# covers the astragal.
	return {
		"id": "157",
		"harbor": ASTRAGAL,
		"title": "The Held Astragal",
		"teach": "The held facing is part of the solution. The chart starts on a facing whose open pair is the other two directions. Place the tide on the middle mark and face the astragal north. Low water wakes the south hull. High water covers the astragal and the beam stops at the waterline. A casement refuses the eastbound beam. A jamb passes the southbound return.",
		"win": "The middle mark holds the north astragal. North and east pass, and the hull stays dark.",
		"cols": 8,
		"rows": 7,
		"tide_phases": [0, 1, 4],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("Wn", 4, 5, "N", "white"),
			_lantern("Ee", 1, 3, "E", "blue"),
			_lantern("Ss", 4, 0, "S", "red"),
			_lantern("Hl", 0, 6, "E", "white"),
		],
		"docks": [
			_dock("Wd", 4, 1, "white", true),
			_dock("Ed", 7, 3, "blue"),
			_dock("Kd", 4, 4, "red", true, true),
		],
		"boats": [
			_boat("Hb", 3, 6),
		],
		"fixtures": [],
		"pieces": [
			_astragal("A", "Astragal", 4, 3, 180, 0),
		],
	}


static func chart_158() -> Dictionary:
	# The astragal and the shutter trade places. On the line the astragal faces
	# north. North and east count. The southbound beam must not.
	return {
		"id": "158",
		"harbor": ASTRAGAL,
		"title": "The Astragal Mark",
		"teach": "Move the astragal from the side socket onto the line and face it north. The mark is satisfied only by that open pair. The northbound beam and the eastbound beam pass. The southbound beam must not count. A casement, a jamb, a mullion, a transom, or a lintel in that cell fails.",
		"win": "The astragal stands on the line, open north and east. Both docks are lit and the return stays dark.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Wn", 3, 6, "N", "white"),
			_lantern("Ee", 0, 3, "E", "red"),
			_lantern("Ss", 3, 0, "S", "blue"),
		],
		"docks": [
			_dock("Wd", 3, 1, "white", true),
			_dock("Ed", 6, 3, "red"),
			_dock("Kd", 3, 5, "blue", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_placed("A", "Astragal", "astragal", [["side", 5, 5], ["line", 3, 3]], "side", "line", 180, 0),
			_placed("G", "Line shutter", "shutter", [["line", 3, 3], ["side", 5, 5]], "line", "side", 0, 0),
		],
	}


static func chart_159() -> Dictionary:
	# Tide index 0, flood 0. A north scotia passes north and west. The chart
	# opens on the other pair, south and east, which refuses both.
	return {
		"id": "159",
		"harbor": SCOTIA,
		"title": "The Dry Scotia",
		"teach": "Tide index 0, flood 0. A dry north scotia passes both the northbound beam and the westbound beam. White stays white and red stays red. A casement in that cell refuses the westbound beam. A jamb in that cell refuses the westbound beam and passes the southbound return. A lintel lets that return through. An astragal facing north refuses the westbound beam.",
		"win": "The dry north scotia passes north and west, and the southbound return stops.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Wn", 3, 6, "N", "white"),
			_lantern("Ww", 6, 3, "W", "red"),
			_lantern("Ss", 3, 0, "S", "blue"),
		],
		"docks": [
			_dock("Nd", 3, 1, "white", true),
			_dock("Wd", 0, 3, "red"),
			_dock("Kd", 3, 5, "blue", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_scotia("S", "Scotia", 3, 3, 180, 0),
		],
	}


static func chart_160() -> Dictionary:
	# The chart opens under water. The beam from the dry row stops at the
	# waterline. The solution lowers the tide, and north and west pass.
	return {
		"id": "160",
		"harbor": SCOTIA,
		"title": "The Wet Stop",
		"teach": "The scotia opens under water, so every beam stops at the waterline and does not enter. Lower the tide. Dry, the northbound beam and the westbound beam pass. A shutter would pass while flooded. A well, a siphon, a sluice, or a weir would carry the beam. A casement refuses the westbound beam. A jamb refuses the westbound beam and passes the southbound return. A flooded astragal stops the same way.",
		"win": "The tide is low. North and west pass, and the southbound beam stops.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0, 3],
		"start_tide_index": 1,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Ss", 3, 1, "S", "blue"),
			_lantern("Nn", 3, 6, "N", "white"),
			_lantern("Ww", 6, 4, "W", "red"),
		],
		"docks": [
			_dock("Nd", 3, 2, "white", true),
			_dock("Kd", 3, 5, "blue", true, true),
			_dock("Wd", 0, 4, "red"),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_scotia("S", "Scotia", 3, 4, 180, 0),
		],
	}


static func chart_161() -> Dictionary:
	# Red goes north and stays red. Blue goes west and stays blue.
	return {
		"id": "161",
		"harbor": SCOTIA,
		"title": "Color Kept",
		"teach": "The dry scotia keeps red, blue, and white. Red stays red and blue stays blue. White stays white. A stain or a weir would change the color. A casement refuses the westbound beam. A jamb refuses the westbound beam and passes the southbound return. An astragal facing north refuses the westbound beam.",
		"win": "The color that enters the scotia is the color that leaves it.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Rs", 3, 6, "N", "red"),
			_lantern("Bw", 6, 3, "W", "blue"),
			_lantern("Ss", 3, 0, "S", "blue"),
		],
		"docks": [
			_dock("Rd", 3, 1, "red", true),
			_dock("Bd", 0, 3, "blue"),
			_dock("Kd", 3, 5, "blue", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_scotia("S", "Scotia", 3, 3, 180, 0),
		],
	}


static func chart_162() -> Dictionary:
	# White goes straight north. Red goes straight west. Neither beam turns.
	return {
		"id": "162",
		"harbor": SCOTIA,
		"title": "No Turn",
		"teach": "The beam leaves on the same side it entered. It does not turn. A prism, a vane, a sluice, or a mirror would turn it. A casement refuses the westbound beam. A jamb passes the southbound return. An astragal facing north refuses the westbound beam.",
		"win": "White goes straight north, and red goes straight west.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Wn", 3, 6, "N", "white"),
			_lantern("Ww", 6, 3, "W", "red"),
			_lantern("Ss", 3, 0, "S", "blue"),
		],
		"docks": [
			_dock("Nd", 3, 1, "white", true),
			_dock("Wd", 0, 3, "red"),
			_dock("Kd", 3, 5, "blue", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_scotia("S", "Scotia", 3, 3, 90, 0),
		],
	}


static func chart_163() -> Dictionary:
	# Flood 2 covers y >= 4. The scotia stays on the dry row and opens
	# north and west. A separate beam stops at the flooded row's waterline.
	return {
		"id": "163",
		"harbor": SCOTIA,
		"title": "Beside the Flood",
		"teach": "The scotia's own row is dry, so the northbound beam and the westbound beam pass. The next flooded cell that is not a flood carrier still stops the beam at the waterline. A mullion cannot be turned so that it passes west. A transom cannot be turned so that it passes north. A casement refuses the westbound beam. A lintel lets the eastbound beam through. An astragal facing north refuses the westbound beam.",
		"win": "North and west pass on the dry row, and the beam into the flood stops.",
		"cols": 8,
		"rows": 6,
		"tide_phases": [2],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Ww", 7, 2, "W", "white"),
			_lantern("Nn", 4, 3, "N", "blue"),
			_lantern("Ee", 0, 2, "E", "red"),
			_lantern("F", 1, 3, "S", "white"),
		],
		"docks": [
			_dock("Wd", 2, 2, "white", true),
			_dock("Nd", 4, 0, "blue"),
			_dock("Kd", 6, 2, "red", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_scotia("S", "Scotia", 4, 2, 180, 0),
		],
	}


static func chart_164() -> Dictionary:
	# One scotia opens north and west. The other opens south and east.
	# Swapping those facings fails. A north jamb on the first seat also passes south.
	return {
		"id": "164",
		"harbor": SCOTIA,
		"title": "Two Scotias",
		"teach": "One scotia is open on north and west. The other is open on south and east. Swapping their facings fails. A jamb cannot take the north-and-west seat, because a north jamb also passes south. A mullion cannot be turned so that it passes west. A transom cannot be turned so that it passes north. An astragal facing north cannot take the north-and-west seat.",
		"win": "North and west stay on the first seat. South and east stay on the second.",
		"cols": 11,
		"rows": 9,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("An", 3, 5, "N", "white"),
			_lantern("As", 3, 0, "S", "blue"),
			_lantern("Aw", 6, 3, "W", "red"),
			_lantern("Bs", 7, 2, "S", "white"),
			_lantern("Bn", 7, 8, "N", "red"),
			_lantern("Be", 4, 5, "E", "blue"),
			_lantern("Bw", 10, 5, "W", "white"),
		],
		"docks": [
			_dock("Adn", 3, 1, "white", true),
			_dock("Ads", 3, 4, "blue", true, true),
			_dock("Adw", 0, 3, "red"),
			_dock("Bds", 7, 7, "white", true),
			_dock("Bdn", 7, 4, "red", true, true),
			_dock("Bde", 9, 5, "blue", true),
			_dock("Bdw", 5, 5, "white", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_scotia("S", "North scotia", 3, 3, 180, 0),
			_scotia("T", "South scotia", 7, 5, 0, 180),
		],
	}


static func chart_165() -> Dictionary:
	# Three tide marks. The middle mark leaves the scotia dry, facing north.
	# The chart starts on the other pair. Low water wakes the hull. High water
	# covers the scotia.
	return {
		"id": "165",
		"harbor": SCOTIA,
		"title": "The Held Scotia",
		"teach": "The held facing is part of the solution. The chart starts on a facing whose open pair is the other two directions. Place the tide on the middle mark and face the scotia north. Low water wakes the south hull. High water covers the scotia and the beam stops at the waterline. A casement refuses the westbound beam. A jamb passes the southbound return. An astragal facing north refuses the westbound beam.",
		"win": "The middle mark holds the north scotia. North and west pass, and the hull stays dark.",
		"cols": 8,
		"rows": 7,
		"tide_phases": [0, 1, 4],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("Wn", 3, 5, "N", "white"),
			_lantern("Ww", 6, 3, "W", "blue"),
			_lantern("Ss", 3, 0, "S", "red"),
			_lantern("Hl", 7, 6, "W", "white"),
		],
		"docks": [
			_dock("Nd", 3, 1, "white", true),
			_dock("Wd", 0, 3, "blue"),
			_dock("Kd", 3, 4, "red", true, true),
		],
		"boats": [
			_boat("Hb", 4, 6),
		],
		"fixtures": [],
		"pieces": [
			_scotia("S", "Scotia", 3, 3, 180, 0),
		],
	}


static func chart_166() -> Dictionary:
	# The scotia and the shutter trade places. On the line the scotia faces
	# north. North and west count. The southbound beam must not.
	return {
		"id": "166",
		"harbor": SCOTIA,
		"title": "The Scotia Mark",
		"teach": "Move the scotia from the side socket onto the line and face it north. The mark is satisfied only by that open pair. The northbound beam and the westbound beam pass. The southbound beam must not count. A casement, a jamb, a mullion, a transom, a lintel, or an astragal in that cell fails.",
		"win": "The scotia stands on the line, open north and west. Both docks are lit and the return stays dark.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Wn", 3, 6, "N", "white"),
			_lantern("Ww", 6, 3, "W", "red"),
			_lantern("Ss", 3, 0, "S", "blue"),
		],
		"docks": [
			_dock("Nd", 3, 1, "white", true),
			_dock("Wd", 0, 3, "red"),
			_dock("Kd", 3, 5, "blue", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_placed("S", "Scotia", "scotia", [["side", 5, 5], ["line", 3, 3]], "side", "line", 180, 0),
			_placed("G", "Line shutter", "shutter", [["line", 3, 3], ["side", 5, 5]], "line", "side", 0, 0),
		],
	}


static func chart_167() -> Dictionary:
	# Tide index 0, flood 0. A north torus passes south and east. The chart
	# opens on the other pair, north and west, which refuses both.
	return {
		"id": "167",
		"harbor": TORUS,
		"title": "The Dry Torus",
		"teach": "Tide index 0, flood 0. A dry north torus passes both the southbound beam and the eastbound beam. White stays white and red stays red. A casement in that cell refuses the eastbound beam. A jamb in that cell refuses the eastbound beam and passes the northbound return. A lintel lets that return through. A scotia facing north refuses the southbound beam. An astragal facing north refuses the southbound beam.",
		"win": "The dry north torus passes south and east, and the northbound return stops.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Ss", 3, 0, "S", "white"),
			_lantern("Ee", 0, 3, "E", "red"),
			_lantern("Nn", 3, 6, "N", "blue"),
		],
		"docks": [
			_dock("Sd", 3, 5, "white", true),
			_dock("Ed", 6, 3, "red"),
			_dock("Kd", 3, 1, "blue", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_torus("T", "Torus", 3, 3, 180, 0),
		],
	}


static func chart_168() -> Dictionary:
	# The chart opens under water. The beam from the dry row stops at the
	# waterline. The solution lowers the tide, and south and east pass.
	return {
		"id": "168",
		"harbor": TORUS,
		"title": "The Wet Stop",
		"teach": "The torus opens under water, so every beam stops at the waterline and does not enter. Lower the tide. Dry, the southbound beam and the eastbound beam pass. A shutter would pass while flooded. A well, a siphon, a sluice, or a weir would carry the beam. A casement refuses the eastbound beam. A jamb refuses the eastbound beam and passes the northbound return. A flooded scotia stops the same way.",
		"win": "The tide is low. South and east pass, and the northbound beam stops.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0, 3],
		"start_tide_index": 1,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Nn", 3, 6, "N", "blue"),
			_lantern("Ss", 3, 0, "S", "white"),
			_lantern("Ee", 0, 4, "E", "red"),
		],
		"docks": [
			_dock("Sd", 3, 5, "white", true),
			_dock("Kd", 3, 2, "blue", true, true),
			_dock("Ed", 6, 4, "red"),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_torus("T", "Torus", 3, 4, 180, 0),
		],
	}


static func chart_169() -> Dictionary:
	# Red goes south and stays red. Blue goes east and stays blue.
	return {
		"id": "169",
		"harbor": TORUS,
		"title": "Color Kept",
		"teach": "The dry torus keeps red, blue, and white. Red stays red and blue stays blue. White stays white. A stain or a weir would change the color. A casement refuses the eastbound beam. A jamb refuses the eastbound beam and passes the northbound return. A scotia facing north refuses the southbound beam. An astragal facing north refuses the southbound beam.",
		"win": "The color that enters the torus is the color that leaves it.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Rs", 3, 0, "S", "red"),
			_lantern("Be", 0, 3, "E", "blue"),
			_lantern("Nn", 3, 6, "N", "blue"),
		],
		"docks": [
			_dock("Rd", 3, 5, "red", true),
			_dock("Bd", 6, 3, "blue"),
			_dock("Kd", 3, 1, "blue", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_torus("T", "Torus", 3, 3, 180, 0),
		],
	}


static func chart_170() -> Dictionary:
	# White goes straight south. Red goes straight east. Neither beam turns.
	return {
		"id": "170",
		"harbor": TORUS,
		"title": "No Turn",
		"teach": "The beam leaves on the same side it entered. It does not turn. A prism, a vane, a sluice, or a mirror would turn it. A casement refuses the eastbound beam. A jamb passes the northbound return. A scotia facing north refuses the southbound beam. An astragal facing north refuses the southbound beam.",
		"win": "White goes straight south, and red goes straight east.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Ss", 3, 0, "S", "white"),
			_lantern("Ee", 0, 3, "E", "red"),
			_lantern("Nn", 3, 6, "N", "blue"),
		],
		"docks": [
			_dock("Sd", 3, 5, "white", true),
			_dock("Ed", 6, 3, "red"),
			_dock("Kd", 3, 1, "blue", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_torus("T", "Torus", 3, 3, 90, 0),
		],
	}


static func chart_171() -> Dictionary:
	# Flood 2 covers y >= 4. The torus stays on the dry row and opens
	# south and east. A separate beam stops at the flooded row's waterline.
	return {
		"id": "171",
		"harbor": TORUS,
		"title": "Beside the Flood",
		"teach": "The torus's own row is dry, so the southbound beam and the eastbound beam pass. The next flooded cell that is not a flood carrier still stops the beam at the waterline. A mullion cannot be turned so that it passes east. A transom cannot be turned so that it passes south. A casement refuses the eastbound beam. A lintel lets the westbound beam through. A scotia facing north refuses the southbound beam. An astragal facing north refuses the southbound beam.",
		"win": "South and east pass on the dry row, and the beam into the flood stops.",
		"cols": 8,
		"rows": 6,
		"tide_phases": [2],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Ee", 0, 2, "E", "white"),
			_lantern("Ss", 4, 0, "S", "blue"),
			_lantern("Ww", 7, 2, "W", "red"),
			_lantern("F", 1, 3, "S", "white"),
		],
		"docks": [
			_dock("Ed", 6, 2, "white", true),
			_dock("Sd", 4, 3, "blue"),
			_dock("Kd", 2, 2, "red", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_torus("T", "Torus", 4, 2, 180, 0),
		],
	}


static func chart_172() -> Dictionary:
	# One torus opens north and west. The other opens south and east.
	# Swapping those facings fails. A north jamb on the first seat also passes south.
	return {
		"id": "172",
		"harbor": TORUS,
		"title": "Two Tori",
		"teach": "One torus is open on north and west. The other is open on south and east. Swapping their facings fails. A jamb cannot take the north-and-west seat, because a north jamb also passes south. A mullion cannot be turned so that it passes west. A transom cannot be turned so that it passes north. A scotia facing south cannot take the north-and-west seat. An astragal facing south cannot take it either.",
		"win": "North and west stay on the first seat. South and east stay on the second.",
		"cols": 11,
		"rows": 9,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("An", 3, 5, "N", "white"),
			_lantern("As", 3, 0, "S", "blue"),
			_lantern("Aw", 6, 3, "W", "red"),
			_lantern("Bs", 7, 2, "S", "white"),
			_lantern("Bn", 7, 8, "N", "red"),
			_lantern("Be", 4, 5, "E", "blue"),
			_lantern("Bw", 10, 5, "W", "white"),
		],
		"docks": [
			_dock("Adn", 3, 1, "white", true),
			_dock("Ads", 3, 4, "blue", true, true),
			_dock("Adw", 0, 3, "red"),
			_dock("Bds", 7, 7, "white", true),
			_dock("Bdn", 7, 4, "red", true, true),
			_dock("Bde", 9, 5, "blue", true),
			_dock("Bdw", 5, 5, "white", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_torus("T", "South torus", 3, 3, 0, 180),
			_torus("U", "North torus", 7, 5, 180, 0),
		],
	}


static func chart_173() -> Dictionary:
	# Three tide marks. The middle mark leaves the torus dry, facing north.
	# The chart starts on the other pair. Low water wakes the hull. High water
	# covers the torus.
	return {
		"id": "173",
		"harbor": TORUS,
		"title": "The Held Torus",
		"teach": "The held facing is part of the solution. The chart starts on a facing whose open pair is the other two directions. Place the tide on the middle mark and face the torus north. Low water wakes the south hull. High water covers the torus and the beam stops at the waterline. A casement refuses the eastbound beam. A jamb passes the northbound return. A scotia facing north refuses the southbound beam. An astragal facing north refuses the southbound beam.",
		"win": "The middle mark holds the north torus. South and east pass, and the hull stays dark.",
		"cols": 8,
		"rows": 7,
		"tide_phases": [0, 1, 4],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("Ss", 3, 0, "S", "white"),
			_lantern("Ee", 0, 3, "E", "blue"),
			_lantern("Nn", 3, 5, "N", "red"),
			_lantern("Hl", 7, 6, "W", "white"),
		],
		"docks": [
			_dock("Sd", 3, 4, "white", true),
			_dock("Ed", 6, 3, "blue"),
			_dock("Kd", 3, 1, "red", true, true),
		],
		"boats": [
			_boat("Hb", 4, 6),
		],
		"fixtures": [],
		"pieces": [
			_torus("T", "Torus", 3, 3, 180, 0),
		],
	}


static func chart_174() -> Dictionary:
	# The torus and the shutter trade places. On the line the torus faces
	# north. South and east count. The northbound beam must not.
	return {
		"id": "174",
		"harbor": TORUS,
		"title": "The Torus Mark",
		"teach": "Move the torus from the side socket onto the line and face it north. The mark is satisfied only by that open pair. The southbound beam and the eastbound beam pass. The northbound beam must not count. A casement, a jamb, a mullion, a transom, a lintel, a scotia, or an astragal in that cell fails.",
		"win": "The torus stands on the line, open south and east. Both docks are lit and the return stays dark.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Ss", 3, 0, "S", "white"),
			_lantern("Ee", 0, 3, "E", "red"),
			_lantern("Nn", 3, 6, "N", "blue"),
		],
		"docks": [
			_dock("Sd", 3, 5, "white", true),
			_dock("Ed", 6, 3, "red"),
			_dock("Kd", 3, 1, "blue", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_placed("T", "Torus", "torus", [["side", 5, 5], ["line", 3, 3]], "side", "line", 180, 0),
			_placed("G", "Line shutter", "shutter", [["line", 3, 3], ["side", 5, 5]], "line", "side", 0, 0),
		],
	}


static func chart_175() -> Dictionary:
	# Tide index 0, flood 0. A north ogee passes south and west. The chart
	# opens on the other pair, north and east, which refuses both.
	return {
		"id": "175",
		"harbor": OGEE,
		"title": "The Dry Ogee",
		"teach": "Tide index 0, flood 0. A dry north ogee passes both the southbound beam and the westbound beam. White stays white and red stays red. A casement in that cell refuses the westbound beam. A jamb in that cell refuses the westbound beam and passes the northbound return. A lintel lets that return through. A torus facing north refuses the westbound beam. A scotia facing north refuses the southbound beam. An astragal facing north refuses the southbound beam.",
		"win": "The dry north ogee passes south and west, and the northbound return stops.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Ss", 3, 0, "S", "white"),
			_lantern("Ww", 6, 3, "W", "red"),
			_lantern("Nn", 3, 6, "N", "blue"),
		],
		"docks": [
			_dock("Sd", 3, 5, "white", true),
			_dock("Wd", 0, 3, "red"),
			_dock("Kd", 3, 1, "blue", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_ogee("O", "Ogee", 3, 3, 180, 0),
		],
	}


static func chart_176() -> Dictionary:
	# The chart opens under water. The beam from the dry row stops at the
	# waterline. The solution lowers the tide, and south and west pass.
	return {
		"id": "176",
		"harbor": OGEE,
		"title": "The Wet Stop",
		"teach": "The ogee opens under water, so every beam stops at the waterline and does not enter. Lower the tide. Dry, the southbound beam and the westbound beam pass. A shutter would pass while flooded. A well, a siphon, a sluice, or a weir would carry the beam. A casement refuses the westbound beam. A jamb refuses the westbound beam and passes the northbound return. A flooded torus stops the same way.",
		"win": "The tide is low. South and west pass, and the northbound beam stops.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0, 3],
		"start_tide_index": 1,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Nn", 3, 6, "N", "blue"),
			_lantern("Ss", 3, 0, "S", "white"),
			_lantern("Ww", 6, 4, "W", "red"),
		],
		"docks": [
			_dock("Sd", 3, 5, "white", true),
			_dock("Kd", 3, 2, "blue", true, true),
			_dock("Wd", 0, 4, "red"),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_ogee("O", "Ogee", 3, 4, 180, 0),
		],
	}


static func chart_177() -> Dictionary:
	# Red goes south and stays red. Blue goes west and stays blue.
	return {
		"id": "177",
		"harbor": OGEE,
		"title": "Color Kept",
		"teach": "The dry ogee keeps red, blue, and white. Red stays red and blue stays blue. White stays white. A stain or a weir would change the color. A casement refuses the westbound beam. A jamb refuses the westbound beam and passes the northbound return. A torus facing north refuses the westbound beam. An astragal facing north refuses the southbound beam.",
		"win": "The color that enters the ogee is the color that leaves it.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Rs", 3, 0, "S", "red"),
			_lantern("Bw", 6, 3, "W", "blue"),
			_lantern("Nn", 3, 6, "N", "blue"),
		],
		"docks": [
			_dock("Rd", 3, 5, "red", true),
			_dock("Bd", 0, 3, "blue"),
			_dock("Kd", 3, 1, "blue", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_ogee("O", "Ogee", 3, 3, 180, 0),
		],
	}


static func chart_178() -> Dictionary:
	# White goes straight south. Red goes straight west. Neither beam turns.
	return {
		"id": "178",
		"harbor": OGEE,
		"title": "No Turn",
		"teach": "The beam leaves on the same side it entered. It does not turn. A prism, a vane, a sluice, or a mirror would turn it. A casement refuses the westbound beam. A jamb passes the northbound return. A torus facing north refuses the westbound beam. A scotia facing north refuses the southbound beam.",
		"win": "White goes straight south, and red goes straight west.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Ss", 3, 0, "S", "white"),
			_lantern("Ww", 6, 3, "W", "red"),
			_lantern("Nn", 3, 6, "N", "blue"),
		],
		"docks": [
			_dock("Sd", 3, 5, "white", true),
			_dock("Wd", 0, 3, "red"),
			_dock("Kd", 3, 1, "blue", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_ogee("O", "Ogee", 3, 3, 270, 0),
		],
	}


static func chart_179() -> Dictionary:
	# Flood 2 covers y >= 4. The ogee stays on the dry row and opens
	# south and west. A separate beam stops at the flooded row's waterline.
	return {
		"id": "179",
		"harbor": OGEE,
		"title": "Beside the Flood",
		"teach": "The ogee's own row is dry, so the southbound beam and the westbound beam pass. The next flooded cell that is not a flood carrier still stops the beam at the waterline. A mullion cannot be turned so that it passes west. A transom cannot be turned so that it passes south. A casement refuses the westbound beam. A lintel lets the eastbound beam through. A torus facing north refuses the westbound beam. A scotia facing north refuses the southbound beam.",
		"win": "South and west pass on the dry row, and the beam into the flood stops.",
		"cols": 8,
		"rows": 6,
		"tide_phases": [2],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Ww", 7, 2, "W", "white"),
			_lantern("Ss", 3, 0, "S", "blue"),
			_lantern("Ee", 0, 2, "E", "red"),
			_lantern("F", 6, 3, "S", "white"),
		],
		"docks": [
			_dock("Wd", 1, 2, "white", true),
			_dock("Sd", 3, 3, "blue"),
			_dock("Kd", 5, 2, "red", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_ogee("O", "Ogee", 3, 2, 180, 0),
		],
	}


static func chart_180() -> Dictionary:
	# One ogee opens north and east. The other opens south and west.
	# Swapping those facings fails. A north jamb on the first seat also passes south.
	return {
		"id": "180",
		"harbor": OGEE,
		"title": "Two Ogees",
		"teach": "One ogee is open on north and east. The other is open on south and west. Swapping their facings fails. A jamb cannot take the north-and-east seat, because a north jamb also passes south. A mullion cannot be turned so that it passes east. A transom cannot be turned so that it passes north. A torus facing south cannot take the north-and-east seat. A scotia facing south cannot take it either.",
		"win": "North and east stay on the first seat. South and west stay on the second.",
		"cols": 11,
		"rows": 9,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("An", 7, 5, "N", "white"),
			_lantern("As", 7, 0, "S", "blue"),
			_lantern("Ae", 4, 3, "E", "red"),
			_lantern("Bs", 3, 2, "S", "white"),
			_lantern("Bn", 3, 8, "N", "red"),
			_lantern("Bw", 6, 5, "W", "blue"),
			_lantern("Be", 0, 5, "E", "white"),
		],
		"docks": [
			_dock("Adn", 7, 1, "white", true),
			_dock("Ads", 7, 4, "blue", true, true),
			_dock("Ade", 10, 3, "red"),
			_dock("Bds", 3, 7, "white", true),
			_dock("Bdn", 3, 4, "red", true, true),
			_dock("Bdw", 1, 5, "blue", true),
			_dock("Bde", 5, 5, "white", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_ogee("O", "South ogee", 7, 3, 0, 180),
			_ogee("U", "North ogee", 3, 5, 180, 0),
		],
	}


static func chart_181() -> Dictionary:
	# Three tide marks. The middle mark leaves the ogee dry, facing north.
	# The chart starts on the other pair. Low water wakes the hull. High water
	# covers the ogee.
	return {
		"id": "181",
		"harbor": OGEE,
		"title": "The Held Ogee",
		"teach": "The held facing is part of the solution. The chart starts on a facing whose open pair is the other two directions. Place the tide on the middle mark and face the ogee north. Low water wakes the south hull. High water covers the ogee and the beam stops at the waterline. A casement refuses the westbound beam. A jamb passes the northbound return. A torus facing north refuses the westbound beam. A scotia facing north refuses the southbound beam.",
		"win": "The middle mark holds the north ogee. South and west pass, and the hull stays dark.",
		"cols": 8,
		"rows": 7,
		"tide_phases": [0, 1, 4],
		"start_tide_index": 0,
		"solution_tide_index": 1,
		"obstacles": [],
		"lanterns": [
			_lantern("Ss", 4, 0, "S", "white"),
			_lantern("Ww", 7, 3, "W", "blue"),
			_lantern("Nn", 4, 5, "N", "red"),
			_lantern("Hl", 0, 6, "E", "white"),
		],
		"docks": [
			_dock("Sd", 4, 4, "white", true),
			_dock("Wd", 1, 3, "blue"),
			_dock("Kd", 4, 1, "red", true, true),
		],
		"boats": [
			_boat("Hb", 3, 6),
		],
		"fixtures": [],
		"pieces": [
			_ogee("O", "Ogee", 4, 3, 180, 0),
		],
	}


static func chart_182() -> Dictionary:
	# The ogee and the shutter trade places. On the line the ogee faces
	# north. South and west count. The northbound beam must not.
	return {
		"id": "182",
		"harbor": OGEE,
		"title": "The Ogee Mark",
		"teach": "Move the ogee from the side socket onto the line and face it north. The mark is satisfied only by that open pair. The southbound beam and the westbound beam pass. The northbound beam must not count. A casement, a jamb, a mullion, a transom, a lintel, a torus, a scotia, or an astragal in that cell fails.",
		"win": "The ogee stands on the line, open south and west. Both docks are lit and the return stays dark.",
		"cols": 7,
		"rows": 7,
		"tide_phases": [0],
		"start_tide_index": 0,
		"solution_tide_index": 0,
		"obstacles": [],
		"lanterns": [
			_lantern("Ss", 3, 0, "S", "white"),
			_lantern("Ww", 6, 3, "W", "red"),
			_lantern("Nn", 3, 6, "N", "blue"),
		],
		"docks": [
			_dock("Sd", 3, 5, "white", true),
			_dock("Wd", 0, 3, "red"),
			_dock("Kd", 3, 1, "blue", true, true),
		],
		"boats": [],
		"fixtures": [],
		"pieces": [
			_placed("O", "Ogee", "ogee", [["side", 5, 5], ["line", 3, 3]], "side", "line", 180, 0),
			_placed("G", "Line shutter", "shutter", [["line", 3, 3], ["side", 5, 5]], "line", "side", 0, 0),
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

static func _dock(id: String, x: int, y: int, color: String, pass_other := false, keep_dark := false) -> Dictionary:
	var dock := {"id": id, "x": x, "y": y, "color": color}
	if pass_other:
		dock["pass_other"] = true
	if keep_dark:
		dock["keep_dark"] = true
	return dock

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


static func _stain(id: String, name: String, x: int, y: int, start_rot: int, sol_rot: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "stain",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": start_rot,
		"solution_socket": "a",
		"solution_rot": sol_rot,
	}


static func _lintel(id: String, name: String, x: int, y: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "lintel",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": 0,
		"solution_socket": "a",
		"solution_rot": 0,
	}


static func _mullion(id: String, name: String, x: int, y: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "mullion",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": 0,
		"solution_socket": "a",
		"solution_rot": 0,
	}


static func _transom(id: String, name: String, x: int, y: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "transom",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": 0,
		"solution_socket": "a",
		"solution_rot": 0,
	}


static func _casement(id: String, name: String, x: int, y: int, start_rot: int, sol_rot: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "casement",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": start_rot,
		"solution_socket": "a",
		"solution_rot": sol_rot,
	}


static func _jamb(id: String, name: String, x: int, y: int, start_rot: int, sol_rot: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "jamb",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": start_rot,
		"solution_socket": "a",
		"solution_rot": sol_rot,
	}


static func _astragal(id: String, name: String, x: int, y: int, start_rot: int, sol_rot: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "astragal",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": start_rot,
		"solution_socket": "a",
		"solution_rot": sol_rot,
	}


static func _scotia(id: String, name: String, x: int, y: int, start_rot: int, sol_rot: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "scotia",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": start_rot,
		"solution_socket": "a",
		"solution_rot": sol_rot,
	}


static func _torus(id: String, name: String, x: int, y: int, start_rot: int, sol_rot: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "torus",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": start_rot,
		"solution_socket": "a",
		"solution_rot": sol_rot,
	}


static func _ogee(id: String, name: String, x: int, y: int, start_rot: int, sol_rot: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "ogee",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": start_rot,
		"solution_socket": "a",
		"solution_rot": sol_rot,
	}


static func _placed(id: String, name: String, kind: String, sockets: Array, start_socket: String, sol_socket: String, start_rot: int, sol_rot: int) -> Dictionary:
	var packed: Array = []
	for raw in sockets:
		var spec: Array = raw
		packed.append({"id": str(spec[0]), "x": int(spec[1]), "y": int(spec[2])})
	return {
		"id": id,
		"name": name,
		"kind": kind,
		"movable": packed.size() > 1,
		"sockets": packed,
		"start_socket": start_socket,
		"start_rot": start_rot,
		"solution_socket": sol_socket,
		"solution_rot": sol_rot,
	}


static func _movable(id: String, name: String, kind: String, sockets: Array, start_socket: String, sol_socket: String) -> Dictionary:
	var packed: Array = []
	for raw in sockets:
		var spec: Array = raw
		packed.append({"id": str(spec[0]), "x": int(spec[1]), "y": int(spec[2])})
	return {
		"id": id,
		"name": name,
		"kind": kind,
		"movable": packed.size() > 1,
		"sockets": packed,
		"start_socket": start_socket,
		"start_rot": 0,
		"solution_socket": sol_socket,
		"solution_rot": 0,
	}


static func _weir(id: String, name: String, x: int, y: int, start_rot: int, sol_rot: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "weir",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": start_rot,
		"solution_socket": "a",
		"solution_rot": sol_rot,
	}


static func _sluice(id: String, name: String, x: int, y: int, start_rot: int, sol_rot: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "sluice",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": start_rot,
		"solution_socket": "a",
		"solution_rot": sol_rot,
	}


static func _siphon(id: String, name: String, x: int, y: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "siphon",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": 0,
		"solution_socket": "a",
		"solution_rot": 0,
	}


static func _well(id: String, name: String, x: int, y: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "well",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": 0,
		"solution_socket": "a",
		"solution_rot": 0,
	}


static func _vane(id: String, name: String, x: int, y: int, start_rot: int, sol_rot: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "vane",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": start_rot,
		"solution_socket": "a",
		"solution_rot": sol_rot,
	}


static func _shutter(id: String, name: String, x: int, y: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "shutter",
		"movable": false,
		"sockets": [{"id": "a", "x": x, "y": y}],
		"start_socket": "a",
		"start_rot": 0,
		"solution_socket": "a",
		"solution_rot": 0,
	}

static func _tide_mirror(id: String, name: String, x: int, y: int, start_rot: int, sol_rot: int) -> Dictionary:
	return {
		"id": id,
		"name": name,
		"kind": "tide_mirror",
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
