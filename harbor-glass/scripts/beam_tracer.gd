extends RefCounted
class_name BeamTracer

# Deterministic beam tracer for Harbor Glass.
#
# The result is a pure function of the chart, the piece state, and the tide.
# Cardinal directions only. y grows downward (south), matching the board.
#
# Mirrors
# -------
# A mirror is two-sided and has two distinct orientations.
#   rot 0 and 180, drawn "/":  N->E, E->N, S->W, W->S
#   rot 90 and 270, drawn "\": N->W, W->N, S->E, E->S
#
# Prism
# -----
# Rotation is clockwise, in degrees: 0, 90, 180, 270.
# rot 0:
#   A WHITE beam traveling N (entering from the south) is consumed.
#   RED leaves traveling W.
#   BLUE leaves traveling E.
#   Nothing continues traveling N. White is not passed through.
#   Any other color is absorbed.
#   White arriving from any other direction is absorbed.
# Clockwise quarter-turns rotate the entry, the red exit, and the blue exit together:
#   rot 90:  white traveling E -> red traveling N, blue traveling S
#   rot 180: white traveling S -> red traveling E, blue traveling W
#   rot 270: white traveling W -> red traveling S, blue traveling N
#
# Tinted pane
# -----------
# Rotation selects the pass color, not an axis.
#   rot 0 and 180: red passes, every other color stops.
#   rot 90 and 270: blue passes, every other color stops.
# A passing beam keeps its direction. White is neither red nor blue, so a pane
# always blocks white. The prism is what turns white into red and blue.
#
# Tide
# ----
# tide_phases[tide_index] is how many rows, counting up from the bottom, are
# under water. A cell is flooded when y >= rows - flood_count. A flooded cell
# stops a beam at the waterline unless it is a tide mirror, a shutter, a
# stain, a well, a siphon, a sluice, or a weir. Lanterns on a flooded cell do
# not emit. Mirrors, prisms, panes, and vanes there are shut and do not act. A
# well is not shut. A siphon is not shut. A sluice is not shut. A weir is not
# shut.
#
# Tide mirror
# -----------
# A tide mirror is not a meeting mirror and it does not replace one.
# It has the same two facings as a mirror, and it never changes color.
#   rot 0 and 180, drawn "/":  N->E, E->N, S->W, W->S
#   rot 90 and 270, drawn "\": N->W, W->N, S->E, E->S
# It reflects only while its own row is flooded. The beam may enter that
# flooded cell. The next flooded cell that is not itself a tide mirror, a
# shutter, a stain, a well, a siphon, a sluice, or a weir still stops the beam at the waterline,
# and a flooded lantern, mirror, prism, pane, vane, dock, or hull still follows
# its own rule. A flooded vane does not enter.
# While its row is dry, a beam that hits it keeps its direction and its color.
#
# Shutter
# -------
# A shutter is not a tide mirror and it does not replace one. It has no facing
# and it never reflects. Rotation is ignored.
# While its own row is dry, a beam that hits it stops.
# While that row is flooded, the beam may enter the cell and passes straight
# through in the same direction and the same color.
# The next flooded cell that is not itself a shutter, a tide mirror, a stain,
# a well, a siphon, a sluice, or a weir still stops the beam at the waterline.
#
# Stain
# -----
# A stain is not a shutter, a pane, or a prism, and it does not replace one.
# It has a color and no facing. Rotation is ignored.
#   rot 0 and 180: red
#   rot 90 and 270: blue
# A beam that hits it continues straight in the same direction, and its color
# becomes the stain's color. White becomes that color too. It does not split
# and it does not reflect. Clicking swaps red and blue. It does not rotate.
# It does this on a dry row and on a flooded row. On a flooded row the beam
# may enter that cell, the same way it may enter a shutter, and it leaves
# recolored. The next flooded cell that is not itself a stain, a shutter, a
# tide mirror, a well, a siphon, a sluice, or a weir still stops the beam.
#
# Vane
# ----
# A vane is not a stain, a mirror, or a shutter, and it does not replace one.
# It has a facing and it never changes color. It does not split.
#   rot 0: north, rot 90: east, rot 180: south, rot 270: west
# Clicking turns that facing clockwise: north, east, south, west.
# A beam already traveling in the facing passes straight and keeps its color.
# A beam that arrives from either side leaves traveling in the facing and
# keeps its color. The entry direction does not pick the exit. The facing does.
# A beam traveling against the facing is head-on. It stops.
# On a flooded row the vane is shut, the same way a mirror is shut. The beam
# stops at the waterline and does not enter the cell. Flood does not let it
# through: a vane is not a shutter, a tide mirror, a stain, a well, a siphon,
# a sluice, or a weir.
#
# Well
# ----
# A well is not a vane, a shutter, a stain, or a tide mirror, and it does not
# replace one. It has no facing. Rotation is ignored. Clicking does nothing.
# It does not split and it does not recolor.
# While its own row is dry, a beam that hits it stops. It does not pass.
# While that row is flooded, the beam may enter the cell and leaves traveling
# north, keeping its color, no matter which way it arrived. The arrival
# direction does not pick the exit.
# The next flooded cell that is not itself a well, a siphon, a sluice, a weir,
# a shutter, a tide mirror, or a stain still stops the beam at the waterline. A
# flooded vane, mirror, prism, pane, dock, or hull still follows its own rule.
# A flooded vane does not enter. A well does.
# A well costs a bounce when it sends the beam on, the same way a vane does.
#
# Siphon
# ------
# A siphon is not a well, a vane, a shutter, a stain, or a tide mirror, and it
# does not replace one. It has no facing. Rotation is ignored. Clicking does
# nothing. It does not split.
# While its own row is dry, a beam that hits it stops. It does not pass.
# While that row is flooded, the beam may enter the cell and always leaves
# north, keeping no memory of the arrival direction. The arrival direction
# does not pick the exit. That exit costs a bounce.
# On that north exit the color flips: red becomes blue, and blue becomes red.
# White stays white. The siphon does not paint white into another color.
# It is a flood carrier, the same way a well is. The next flooded cell that is
# not itself a siphon, a well, a sluice, a weir, a shutter, a tide mirror, or a
# stain still stops the beam at the waterline. A flooded vane does not enter. A
# siphon does.
# A well keeps the color. A siphon swaps red and blue. A stain sets one chosen
# color and goes straight, dry or flooded. A shutter keeps the arrival direction.
#
# Sluice
# ------
# A sluice is not a siphon, a well, a vane, a shutter, a stain, or a tide
# mirror, and it does not replace one. It has a facing.
#   rot 0: north, rot 90: east, rot 180: south, rot 270: west
# Clicking turns that facing clockwise. A hint uses that facing.
# While its own row is dry, a beam that hits it stops, whichever way it faces.
# While that row is flooded, the beam may enter from any side and always leaves
# along the facing. The arrival direction does not pick the exit. That exit
# costs a bounce. It does not swap colors. Red stays red, blue stays blue, and
# white stays white.
# It is a flood carrier, the same way a well and a siphon are. The next flooded
# cell that is not itself a sluice, a siphon, a well, a weir, a shutter, a tide
# mirror, or a stain still stops the beam at the waterline. A flooded vane does
# not enter. A sluice does.
# A north-facing sluice is not a well and it is not a siphon. A well has no
# facing and keeps the color. A siphon has no facing and swaps red with blue.
# A sluice keeps the color, and the exit follows the facing.
#
# Weir
# ----
# A weir is not a sluice, a siphon, a well, a vane, a shutter, a stain, or a
# tide mirror, and it does not replace one. It has a facing.
#   rot 0: north, rot 90: east, rot 180: south, rot 270: west
# Clicking turns that facing clockwise. A hint uses that facing.
# While its own row is dry, a beam that hits it stops, whichever way it faces.
# While that row is flooded, the beam may enter from any side and always leaves
# along the facing. The arrival direction does not pick the exit. That exit
# costs a bounce.
# It swaps red and blue. Red leaves blue. Blue leaves red. White stays white.
# It does not paint white into another color. It does not split.
# It is a flood carrier, the same way a sluice, a well, and a siphon are. The
# next flooded cell that is not itself a weir, a sluice, a siphon, a well, a
# shutter, a tide mirror, or a stain still stops the beam at the waterline. A
# flooded vane does not enter. A weir does.
# A sluice keeps the color and the exit follows the facing. A siphon swaps red
# with blue, has no facing, and leaves north. A well keeps the color, has no
# facing, and leaves north. A north-facing weir swaps the color and leaves
# north. That is the only facing on which its exit matches a siphon. Every
# other facing leaves on a different side.
#
# Lintel
# ------
# A lintel is not a weir, a sluice, a shutter, a stain, a vane, a well, or a
# siphon, and it does not replace one. It has no facing. Rotation is ignored.
# Clicking does nothing.
# While its own row is dry, a beam may enter from any side and passes straight
# through in the same direction and the same color. That pass costs no bounce.
# Red stays red, blue stays blue, and white stays white. It does not recolor,
# it does not turn, and it does not split.
# While that row is flooded, the beam stops at the waterline and does not
# enter the cell. A flooded lintel does not carry the beam. It is shut under
# water, the same way a vane is shut. A shutter is the opposite tide: dry
# stops, flooded passes straight. A weir and a sluice stop while dry and,
# while flooded, leave along a facing. A stain recolors on both tides.
#
# Mullion
# ------
# A mullion is not a lintel, a weir, a sluice, a shutter, a stain, a vane, a
# well, or a siphon, and it does not replace one. It has no facing. Rotation
# is ignored. Clicking does nothing.
# While its own row is dry, a beam traveling north or south may enter and
# passes straight through in the same direction and the same color. That pass
# costs no bounce. Red stays red, blue stays blue, and white stays white. It
# does not recolor, it does not turn, and it does not split.
# While its own row is dry, a beam traveling east or west stops at the mullion
# and does not enter the cell. It does not turn and it does not bounce.
# While that row is flooded, every beam stops at the waterline and does not
# enter the cell. A flooded mullion does not carry the beam. It is shut under
# water, the same way a lintel and a vane are shut.
# A dry lintel passes every direction. A dry mullion passes only north and south.
#
# Transom
# -------
# A transom is not a mullion, a lintel, a weir, a sluice, a shutter, a stain,
# a vane, a well, or a siphon, and it does not replace one. It has no facing.
# Rotation is ignored. Clicking does nothing.
# While its own row is dry, a beam traveling east or west may enter and passes
# straight through in the same direction and the same color. That pass costs
# no bounce. Red stays red, blue stays blue, and white stays white. It does
# not recolor, it does not turn, and it does not split.
# While its own row is dry, a beam traveling north or south stops at the
# transom and does not enter the cell. It does not turn and it does not bounce.
# While that row is flooded, every beam stops at the waterline and does not
# enter the cell. A flooded transom does not carry the beam. It is shut under
# water, the same way a mullion, a lintel, and a vane are shut.
# A dry mullion passes north and south and stops east and west. A dry lintel
# passes every direction. A dry transom passes only east and west.
#
# Casement
# --------
# A casement is not a transom, a mullion, a lintel, a weir, a sluice, a
# shutter, a stain, a vane, a well, or a siphon, and it does not replace one.
# It has a facing. Rotation changes the facing. Clicking cycles it the same
# way a vane, a sluice, and a weir are rotated: 0 north, 90 east, 180 south,
# 270 west.
# While its own row is dry, a beam traveling in the facing direction may enter
# and passes straight through in that same direction and the same color. That
# pass costs no bounce. Red stays red, blue stays blue, and white stays white.
# It does not recolor, it does not turn, and it does not split.
# While its own row is dry, a beam traveling any other direction, including
# the opposite of the facing, stops at the casement and does not enter the
# cell. It does not turn and it does not bounce.
# While that row is flooded, every beam stops at the waterline and does not
# enter the cell. A flooded casement does not carry the beam. It is shut under
# water, the same way a transom, a mullion, a lintel, and a vane are shut.
# A dry transom passes both east and west, and rotation does nothing. A dry
# mullion passes both north and south, and rotation does nothing. A dry lintel
# passes every direction, and rotation does nothing. A dry casement passes
# only the one direction it faces.
#
# Jamb
# ----
# A jamb is not a casement, a transom, a mullion, a lintel, a weir, a sluice,
# a shutter, a stain, a vane, a well, or a siphon, and it does not replace one.
# It has a facing. Rotation changes the facing. Clicking cycles it the same
# way a casement is rotated: 0 north, 90 east, 180 south, 270 west.
# While its own row is dry and the facing is north or south, a beam traveling
# north or south passes straight through in the same direction and the same
# color. That pass costs no bounce. A beam traveling east or west stops at the
# edge and does not enter. It does not turn and it does not bounce.
# While its own row is dry and the facing is east or west, a beam traveling
# east or west passes straight through in the same direction and the same
# color. That pass costs no bounce. A beam traveling north or south stops at
# the edge and does not enter.
# It does not recolor, it does not turn, and it does not split. Red stays red,
# blue stays blue, and white stays white.
# While that row is flooded, every beam stops at the waterline and does not
# enter the cell. A flooded jamb does not carry the beam. It is shut under
# water, the same way a casement is shut.
# A north casement passes north and refuses south. A north jamb passes both
# north and south. A mullion always passes north and south, and clicking does
# nothing. A jamb clicked once from north faces east and then passes east and
# west instead. A transom always passes east and west, and clicking does
# nothing. A jamb clicked once from east faces south and then passes north and
# south instead. A lintel passes the axis a jamb is blocking. A casement
# refuses the return trip a jamb allows.
#
# Astragal
# --------
# An astragal is not a jamb, a casement, a transom, a mullion, a lintel, a
# weir, a sluice, a shutter, a stain, a vane, a well, or a siphon, and it does
# not replace one. It has a facing. Rotation changes the facing. Clicking
# cycles it the same way a jamb is rotated: 0 north, 90 east, 180 south,
# 270 west.
# While its own row is dry, a beam traveling in the facing direction passes
# straight through, and a beam traveling in the next clockwise direction also
# passes straight through. North and east when it faces north. East and south
# when it faces east. South and west when it faces south. West and north when
# it faces west. Each pass keeps the same direction and the same color and
# costs no bounce.
# The other two directions stop at the edge and do not enter. A north astragal
# refuses south and west. It does not turn and it does not bounce.
# It does not recolor, it does not turn, and it does not split. Red stays red,
# blue stays blue, and white stays white.
# While that row is flooded, every beam stops at the waterline and does not
# enter the cell. A flooded astragal does not carry the beam. It is shut under
# water, the same way a jamb is shut.
# A north casement passes north and refuses east. A north astragal passes east
# as well. A north jamb passes north and south and refuses east. A north
# astragal refuses south and passes east. A lintel passes the two directions
# an astragal is blocking. A mullion cannot be turned so that it passes east.
# A transom cannot be turned so that it passes north.
#
# Scotia
# ------
# A scotia is not an astragal, a jamb, a casement, a transom, a mullion, a
# lintel, a weir, a sluice, a shutter, a stain, a vane, a well, or a siphon,
# and it does not replace one. It has a facing. Rotation changes the facing.
# Clicking cycles it: 0 north, 90 east, 180 south, 270 west.
# While its own row is dry, the facing and the next counterclockwise direction
# pass straight through in the same direction and the same color, and that
# pass costs no bounce. Facing north, the open directions are north and west.
# The other two directions stop before they enter. While that row is flooded,
# every beam stops at the waterline.
#
# Torus
# -----
# A torus is not a scotia, an astragal, a casement, a jamb, a mullion, a
# transom, or a lintel, and it does not replace one. It is not a weir, a
# sluice, a shutter, a stain, a vane, a well, or a siphon either. It has a
# facing. Rotation changes the facing. Clicking cycles it the same way a
# scotia is rotated: 0 north, 90 east, 180 south, 270 west.
# While its own row is dry, a beam traveling opposite the facing passes
# straight through, and a beam traveling in the next clockwise direction from
# the facing also passes straight through. South and east when it faces north.
# West and south when it faces east. North and west when it faces south. East
# and north when it faces west. Each pass keeps the same direction and the same
# color and costs no bounce. It does not turn, it does not recolor, and it
# does not split.
# The other two directions stop at the edge and do not enter. A north torus
# refuses north and west. That stopped pair is what a north scotia passes.
# South and east, the open pair, is what a north scotia stops.
# It does not recolor. Red stays red, blue stays blue, and white stays white.
# While that row is flooded, every beam stops at the waterline and does not
# enter the cell. A flooded torus does not carry the beam. It is shut under
# water, the same way a flooded scotia is shut.
# A north scotia passes north and west. A north astragal passes north and east.
# A north torus passes neither of those pairs. It passes south and east.
# A casement passes only the facing. A jamb passes both directions on its open
# axis. A mullion passes north and south. A transom passes east and west. A
# lintel passes every dry direction. None of those is the dry torus pair.
#
# Ogee
# ----
# An ogee is not a torus, a scotia, an astragal, a casement, a jamb, a mullion,
# a transom, or a lintel, and it does not replace one. It is not a weir, a
# sluice, a shutter, a stain, a vane, a well, or a siphon either. It has a
# facing. Rotation changes the facing. Clicking cycles it the same way a
# torus is rotated: 0 north, 90 east, 180 south, 270 west.
# While its own row is dry, a beam traveling opposite the facing passes
# straight through, and a beam traveling in the next counterclockwise direction
# from the facing also passes straight through. South and west when it faces
# north. North and west when it faces east. North and east when it faces south.
# East and south when it faces west. Each pass keeps the same direction and the
# same color and costs no bounce. It does not turn, it does not recolor, and it
# does not split.
# The other two directions stop at the edge and do not enter. A north ogee
# refuses north and east. That stopped pair is what a north astragal passes.
# South and west, the open pair, is what a north torus does not pass together:
# a north torus passes south and refuses west.
# It does not recolor. Red stays red, blue stays blue, and white stays white.
# While that row is flooded, every beam stops at the waterline and does not
# enter the cell. A flooded ogee does not carry the beam. It is shut under
# water, the same way a flooded torus is shut.
# A north torus passes south and east. A north scotia passes north and west.
# A north ogee passes neither of those pairs. It passes south and west.
# A casement passes only the facing. A jamb passes both directions on its open
# axis. A mullion passes north and south. A transom passes east and west. A
# lintel passes every dry direction. None of those is the dry ogee pair.
#
# Docks and boats
# ---------------
# A dock records every color that enters its cell. It is satisfied only when
# its required color is among those hits. A wrong color does not satisfy it.
# Extra colors do not cancel a hit that already has the required color.
# A boat is lit if any beam of any color enters its cell.
#
# Loops
# -----
# Each mirror, prism, pane, vane, well, siphon, sluice, and weir costs a bounce. Past MAX_BOUNCES the beam stops.
# A dry lintel does not cost a bounce. A flooded lintel is not entered.
# A dry mullion does not cost a bounce when it passes north or south. A dry
# east-west beam does not enter it. A flooded mullion is not entered.
# A dry transom does not cost a bounce when it passes east or west. A dry
# north-south beam does not enter it. A flooded transom is not entered.
# A dry casement does not cost a bounce when the beam is already traveling
# with its facing. Every other dry direction stops before the cell. A flooded
# casement is not entered.
# A dry jamb does not cost a bounce when the beam is traveling on its open
# axis. The other axis stops before the cell. A flooded jamb is not entered.
# A dry astragal does not cost a bounce when the beam is traveling with its
# facing or the next clockwise direction. The other two directions stop
# before the cell. A flooded astragal is not entered.
# A dry scotia does not cost a bounce when the beam is traveling with its
# facing or the next counterclockwise direction. The other two directions stop
# before the cell. A flooded scotia is not entered.
# A dry torus does not cost a bounce when the beam is traveling opposite its
# facing or in the next clockwise direction. The other two directions stop
# before the cell. A flooded torus is not entered.
# A dry ogee does not cost a bounce when the beam is traveling opposite its
# facing or in the next counterclockwise direction. The other two directions
# stop before the cell. A flooded ogee is not entered.
# A (cell, direction, color) triple is never entered twice, and each cast also
# stops after MAX_STEPS cells. Those caps are what make a mirror loop return.

const DIRS: PackedStringArray = ["N", "E", "S", "W"]
const MAX_BOUNCES := 16
const MAX_STEPS := 48
const MAX_SEGMENTS := 80

const VEC := {
	"N": Vector2i(0, -1),
	"E": Vector2i(1, 0),
	"S": Vector2i(0, 1),
	"W": Vector2i(-1, 0),
}

static func rotate_dir(dir: String, turns: int) -> String:
	var i := DIRS.find(dir)
	if i < 0:
		return "N"
	return DIRS[posmod(i + turns, 4)]

static func norm_rot(kind: String, rot: int) -> int:
	# A prism has four faces. A vane has four facings: 0 north, 90 east,
	# 180 south, 270 west. A sluice uses that same facing. A weir uses it too,
	# and the exit also swaps red with blue. Opposite facings are not the same piece.
	# A casement uses the same four facings. Only a beam already traveling that
	# way passes straight through. The other three directions stop outside.
	# A jamb uses the same four facings. North and south open the north-south
	# axis. East and west open the east-west axis. The stored facing still
	# walks through all four quarter-turns.
	# An astragal uses the same four facings. Each one is its own open pair:
	# the facing and the next clockwise direction. Opposite facings are not
	# the same piece.
	# A scotia uses the same four facings. Each one is its own open pair:
	# the facing and the next counterclockwise direction. That pair is the
	# mirror of the astragal, so a north scotia is not a north astragal.
	# A torus uses the same four facings. Each one is its own open pair:
	# the opposite of the facing and the next clockwise direction. A north
	# torus passes south and east, which a north scotia stops.
	# An ogee uses the same four facings. Each one is its own open pair:
	# the opposite of the facing and the next counterclockwise direction. A
	# north ogee passes south and west, which a north torus does not.
	# An ovolo uses the same four facings. Each one stops only the facing and
	# passes the other three directions. A north ovolo passes east, south, and
	# west, which a north ogee does not.
	# A cavetto uses the same four facings. Each one stops only the opposite
	# of the facing and passes the other three directions. A north cavetto
	# passes north, east, and west, which a north ovolo does not.
	if kind == "prism" or kind == "vane" or kind == "sluice" or kind == "weir" or kind == "casement" or kind == "jamb" or kind == "astragal" or kind == "scotia" or kind == "torus" or kind == "ogee" or kind == "ovolo" or kind == "cavetto" or kind == "fillet" or kind == "corona" or kind == "bead" or kind == "quirk" or kind == "cyma" or kind == "fascia" or kind == "soffit" or kind == "drip" or kind == "beak" or kind == "hood" or kind == "throat" or kind == "larmier" or kind == "cill" or kind == "threshold" or kind == "impost" or kind == "architrave" or kind == "archivolt" or kind == "abacus" or kind == "rebate" or kind == "echinus" or kind == "annulet" or kind == "listel" or kind == "necking" or kind == "taenia" or kind == "baguette" or kind == "reglet" or kind == "billet" or kind == "reed" or kind == "staff" or kind == "thumb" or kind == "roll" or kind == "gutta" or kind == "dentil":
		return posmod(rot, 360)
	# A shutter has no facing. Dry stops the beam; flooded water lets it pass.
	# A well has no facing either. Dry stops the beam; flooded water sends it north.
	# A siphon has no facing either. Dry stops the beam; flooded water sends it
	# north and swaps red with blue. White stays white.
	# A lintel has no facing either. Dry passes the beam straight through.
	# Flooded water stops the beam at the waterline.
	# A mullion has no facing either. Dry north-south passes straight through.
	# Dry east-west stops before the cell. Flooded water stops at the waterline.
	# A transom has no facing either. Dry east-west passes straight through.
	# Dry north-south stops before the cell. Flooded water stops at the waterline.
	if kind == "shutter" or kind == "well" or kind == "siphon" or kind == "lintel" or kind == "mullion" or kind == "transom":
		return 0
	# A stain has no facing. 0 is red and 90 is blue; 180 and 270 repeat them.
	if kind == "stain":
		return 0 if posmod(rot, 180) == 0 else 90
	# Mirrors, tide mirrors, and panes repeat every 180 degrees.
	return posmod(rot, 180)

static func turn_rot(kind: String, rot: int) -> int:
	if kind == "shutter" or kind == "well" or kind == "siphon" or kind == "lintel" or kind == "mullion" or kind == "transom":
		return 0
	# Clicking swaps the color. It does not walk through a facing.
	if kind == "stain":
		return 90 if norm_rot("stain", rot) == 0 else 0
	var turned := posmod(rot + 90, 360)
	return norm_rot(kind, turned)

static func reflect(rot: int, incoming: String) -> String:
	var slash := norm_rot("mirror", rot) == 0
	if slash:
		match incoming:
			"N":
				return "E"
			"E":
				return "N"
			"S":
				return "W"
			"W":
				return "S"
	else:
		match incoming:
			"N":
				return "W"
			"E":
				return "S"
			"S":
				return "E"
			"W":
				return "N"
	return incoming

static func prism_ports(rot: int) -> Dictionary:
	var turns := posmod(int(rot / 90), 4)
	return {
		"entry": rotate_dir("N", turns),
		"red": rotate_dir("W", turns),
		"blue": rotate_dir("E", turns),
	}

static func pane_color(rot: int) -> String:
	return "red" if norm_rot("pane", rot) == 0 else "blue"

static func stain_color(rot: int) -> String:
	return "red" if norm_rot("stain", rot) == 0 else "blue"

static func siphon_color(color: String) -> String:
	# The north exit swaps the two lantern colors. White is not painted.
	if color == "red":
		return "blue"
	if color == "blue":
		return "red"
	return color

static func vane_facing(rot: int) -> String:
	return rotate_dir("N", posmod(int(rot / 90.0), 4))

static func casement_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. The dry pass follows this facing.
	return rotate_dir("N", posmod(int(norm_rot("casement", rot) / 90.0), 4))

static func jamb_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. North and south open one axis.
	# East and west open the other.
	return rotate_dir("N", posmod(int(norm_rot("jamb", rot) / 90.0), 4))

static func jamb_passes(rot: int, dir: String) -> bool:
	var facing := jamb_facing(rot)
	var north_south := facing == "N" or facing == "S"
	if north_south:
		return dir == "N" or dir == "S"
	return dir == "E" or dir == "W"

static func astragal_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. The dry pass follows this facing
	# and the next clockwise direction.
	return rotate_dir("N", posmod(int(norm_rot("astragal", rot) / 90.0), 4))

static func astragal_passes(rot: int, dir: String) -> bool:
	var facing := astragal_facing(rot)
	return dir == facing or dir == rotate_dir(facing, 1)

static func scotia_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. The dry pass follows this facing
	# and the next counterclockwise direction.
	return rotate_dir("N", posmod(int(norm_rot("scotia", rot) / 90.0), 4))

static func scotia_passes(rot: int, dir: String) -> bool:
	var facing := scotia_facing(rot)
	return dir == facing or dir == rotate_dir(facing, -1)

static func torus_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. The dry pass is not this facing.
	return rotate_dir("N", posmod(int(norm_rot("torus", rot) / 90.0), 4))

static func torus_passes(rot: int, dir: String) -> bool:
	# Opposite the facing, and the next clockwise direction from the facing.
	# North opens south and east. That is the pair a north scotia stops.
	var facing := torus_facing(rot)
	return dir == rotate_dir(facing, 2) or dir == rotate_dir(facing, 1)

static func ogee_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. The dry pass is not this facing.
	return rotate_dir("N", posmod(int(norm_rot("ogee", rot) / 90.0), 4))

static func ogee_passes(rot: int, dir: String) -> bool:
	# Opposite the facing, and the next counterclockwise direction from the
	# facing. North opens south and west. That is not the north torus pair.
	var facing := ogee_facing(rot)
	return dir == rotate_dir(facing, 2) or dir == rotate_dir(facing, -1)

static func ovolo_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. The dry stop is this facing.
	return rotate_dir("N", posmod(int(norm_rot("ovolo", rot) / 90.0), 4))

static func ovolo_passes(rot: int, dir: String) -> bool:
	# Every direction except the facing. North stops north and passes east,
	# south, and west. That is not a casement, a jamb, a mullion, a transom,
	# a lintel, an astragal, a scotia, a torus, or an ogee.
	return dir != ovolo_facing(rot)

static func cavetto_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. The dry stop is opposite this facing.
	return rotate_dir("N", posmod(int(norm_rot("cavetto", rot) / 90.0), 4))

static func cavetto_passes(rot: int, dir: String) -> bool:
	# Every direction except the opposite of the facing. North stops south and
	# passes north, east, and west. That is not an ovolo, an ogee, a torus, a
	# scotia, an astragal, a casement, a jamb, a mullion, a transom, or a lintel.
	return dir != rotate_dir(cavetto_facing(rot), 2)

static func fillet_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. The dry pass is opposite this facing.
	return rotate_dir("N", posmod(int(norm_rot("fillet", rot) / 90.0), 4))

static func fillet_passes(rot: int, dir: String) -> bool:
	# Only the opposite of the facing. North passes south and stops north, east,
	# and west. That is not a cavetto, an ovolo, an ogee, a torus, a scotia, an
	# astragal, a casement, a jamb, a mullion, a transom, or a lintel.
	return dir == rotate_dir(fillet_facing(rot), 2)

static func corona_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. The dry pass is perpendicular.
	return rotate_dir("N", posmod(int(norm_rot("corona", rot) / 90.0), 4))

static func corona_passes(rot: int, dir: String) -> bool:
	# The two directions perpendicular to the facing. North passes east and
	# west and stops north and south. Turned once, north and south pass.
	# That is not a transom, a mullion, a jamb, a fillet, a cavetto, an ovolo,
	# an ogee, a torus, a scotia, an astragal, a casement, or a lintel.
	var facing := corona_facing(rot)
	return dir == rotate_dir(facing, 1) or dir == rotate_dir(facing, -1)

static func bead_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Opposite facings are not the same piece.
	return rotate_dir("N", posmod(int(norm_rot("bead", rot) / 90.0), 4))

static func bead_passes(rot: int, dir: String) -> bool:
	# Only the next clockwise direction. North passes only east. One click
	# faces east and passes only south. That is not a corona, a fillet, a
	# casement, an astragal, a jamb, a mullion, a transom, or a lintel.
	return dir == rotate_dir(bead_facing(rot), 1)

static func quirk_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Opposite facings are not the same piece.
	return rotate_dir("N", posmod(int(norm_rot("quirk", rot) / 90.0), 4))

static func quirk_passes(rot: int, dir: String) -> bool:
	# Only the next counterclockwise direction. North passes only west. One
	# click faces east and passes only north. That is not a bead, a corona, a
	# fillet, a casement, a scotia, a jamb, a mullion, a transom, or a lintel.
	return dir == rotate_dir(quirk_facing(rot), -1)

static func cyma_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Opposite facings are not the same piece.
	return rotate_dir("N", posmod(int(norm_rot("cyma", rot) / 90.0), 4))

static func cyma_passes(rot: int, dir: String) -> bool:
	# Only the facing. North passes only north. One click faces east and passes
	# only east. That is not a quirk, a bead, a fillet, an astragal, a scotia,
	# a jamb, a mullion, a transom, or a lintel.
	return dir == cyma_facing(rot)

static func fascia_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Opposite facings are not the same piece.
	return rotate_dir("N", posmod(int(norm_rot("fascia", rot) / 90.0), 4))

static func fascia_passes(rot: int, dir: String) -> bool:
	# Every direction except the next clockwise one. North passes north, south,
	# and west, and stops east. One click faces east and stops south. That is
	# not a cyma, an ovolo, a cavetto, a bead, a quirk, or a fillet.
	return dir != rotate_dir(fascia_facing(rot), 1)

static func soffit_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Opposite facings are not the same piece.
	return rotate_dir("N", posmod(int(norm_rot("soffit", rot) / 90.0), 4))

static func soffit_passes(rot: int, dir: String) -> bool:
	# Every direction except the next counterclockwise one. North passes north,
	# east, and south, and stops west. One click faces east and stops north.
	# That is the mirror of a fascia.
	return dir != rotate_dir(soffit_facing(rot), -1)

static func drip_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Opposite facings are not the same piece.
	return rotate_dir("N", posmod(int(norm_rot("drip", rot) / 90.0), 4))

static func drip_passes(rot: int, dir: String) -> bool:
	# Dry rule, the same as a soffit. Every direction except the next
	# counterclockwise one. North passes north, east, and south, and stops west.
	return dir != rotate_dir(drip_facing(rot), -1)

static func drip_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule, the dry stop flipped. Only the dry-stopped direction
	# passes. A flooded north drip passes only west.
	return dir == rotate_dir(drip_facing(rot), -1)

static func beak_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Opposite facings are not the same piece.
	return rotate_dir("N", posmod(int(norm_rot("beak", rot) / 90.0), 4))

static func beak_passes(rot: int, dir: String) -> bool:
	# Dry rule, the clockwise mirror of a drip. Every direction except the
	# next clockwise one. North passes north, south, and west, and stops east.
	return dir != rotate_dir(beak_facing(rot), 1)

static func beak_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule, the dry stop flipped. Only the dry-stopped direction
	# passes. A flooded north beak passes only east.
	return dir == rotate_dir(beak_facing(rot), 1)

static func hood_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Opposite facings are not the same piece.
	return rotate_dir("N", posmod(int(norm_rot("hood", rot) / 90.0), 4))

static func hood_passes(rot: int, dir: String) -> bool:
	# Dry rule. Every direction except the facing. North passes east, south,
	# and west, and stops north.
	return dir != hood_facing(rot)

static func hood_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule, the dry stop flipped. Only the facing passes. A flooded
	# north hood passes only north.
	return dir == hood_facing(rot)

static func throat_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Opposite facings are not the same piece.
	return rotate_dir("N", posmod(int(norm_rot("throat", rot) / 90.0), 4))

static func throat_passes(rot: int, dir: String) -> bool:
	# Dry rule. Every direction except the opposite of the facing. North passes
	# north, east, and west, and stops south.
	return dir != rotate_dir(throat_facing(rot), 2)

static func throat_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule, the dry stop flipped. Only the opposite of the facing
	# passes. A flooded north throat passes only south.
	return dir == rotate_dir(throat_facing(rot), 2)

static func larmier_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Opposite facings share the open
	# set, the same way a corona's opposite facings share an axis. The stored
	# facing still walks all four quarter-turns.
	return rotate_dir("N", posmod(int(norm_rot("larmier", rot) / 90.0), 4))

static func larmier_passes(rot: int, dir: String) -> bool:
	# Dry rule. The two directions perpendicular to the facing. North passes
	# east and west and stops north and south, the facing and the opposite.
	# A south larmier passes the same east and west. One click faces east and
	# passes north and south. That is the corona's dry pair, with a flood flip.
	var facing := larmier_facing(rot)
	return dir == rotate_dir(facing, 1) or dir == rotate_dir(facing, -1)

static func larmier_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule, the dry stops flipped. Only the facing and the opposite
	# pass. A flooded north larmier passes only north and south. A flooded
	# corona stops both of those beams. A flooded throat passes only one of them.
	var facing := larmier_facing(rot)
	return dir == facing or dir == rotate_dir(facing, 2)

static func cill_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Opposite facings share the open
	# set, the same way a larmier's opposite facings share an axis. The stored
	# facing still walks all four quarter-turns.
	return rotate_dir("N", posmod(int(norm_rot("cill", rot) / 90.0), 4))

static func cill_passes(rot: int, dir: String) -> bool:
	# Dry rule, the larmier's polarity swap. The facing and the opposite.
	# North passes north and south and stops east and west. A south cill passes
	# the same north and south. One click faces east and passes east and west,
	# the axis a dry larmier stops.
	var facing := cill_facing(rot)
	return dir == facing or dir == rotate_dir(facing, 2)

static func cill_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule. Only the two perpendicular directions pass. A flooded north
	# cill passes only east and west. A flooded south cill passes the same east
	# and west. That is the axis a dry larmier passes, and it is not a flooded
	# larmier, which passes the facing and the opposite.
	var facing := cill_facing(rot)
	return dir == rotate_dir(facing, 1) or dir == rotate_dir(facing, -1)

static func threshold_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Opposite facings do not share the
	# open set. The open set is tied to the facing, not to an axis.
	return rotate_dir("N", posmod(int(norm_rot("threshold", rot) / 90.0), 4))

static func threshold_passes(rot: int, dir: String) -> bool:
	# Dry rule, the throat with dry and flood swapped. Only the opposite of the
	# facing passes. North passes only south and stops north, east, and west.
	# One click faces east and only west passes. A dry fillet passes this same
	# beam and stays shut under water.
	return dir == rotate_dir(threshold_facing(rot), 2)

static func threshold_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule. Every direction except the opposite passes. A flooded north
	# threshold passes north, east, and west, and stops south. One click faces
	# east and passes east, north, and south, and stops west. A flooded north
	# throat passes only south.
	return dir != rotate_dir(threshold_facing(rot), 2)

static func impost_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Opposite facings do not share the
	# open set. The open set is tied to the facing, not to an axis.
	return rotate_dir("N", posmod(int(norm_rot("impost", rot) / 90.0), 4))

static func impost_passes(rot: int, dir: String) -> bool:
	# Dry rule. Only the facing passes. North passes only north and stops east,
	# west, and south. One click faces east and only east passes. A dry cyma
	# passes this same beam and stays shut under water.
	return dir == impost_facing(rot)

static func impost_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule. Every direction except the facing passes. A flooded north
	# impost passes south, east, and west, and stops north. One click faces
	# east and passes west, north, and south, and stops east. A flooded north
	# threshold passes north, east, and west, and stops south.
	return dir != impost_facing(rot)

static func architrave_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. The dry open set is the
	# perpendicular axis, so opposite facings share it. The flooded open set
	# is only the facing, so opposite facings do not share that set.
	return rotate_dir("N", posmod(int(norm_rot("architrave", rot) / 90.0), 4))

static func architrave_passes(rot: int, dir: String) -> bool:
	# Dry rule. Only the two perpendicular headings pass. North passes east
	# and west and stops north and south. One click faces east and only north
	# and south pass. A south architrave passes the same east and west.
	var facing := architrave_facing(rot)
	return dir == rotate_dir(facing, 1) or dir == rotate_dir(facing, -1)

static func architrave_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule. Only the facing passes. A flooded north architrave passes
	# only north. East, west, and south stop. One click faces east and only
	# east passes. A flooded north impost passes every heading except north.
	return dir == architrave_facing(rot)

static func archivolt_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Dry, every heading stops, so
	# there is no dry open set. Flooded, the open set is the perpendicular
	# axis, so opposite facings share it.
	return rotate_dir("N", posmod(int(norm_rot("archivolt", rot) / 90.0), 4))

static func archivolt_passes(_rot: int, _dir: String) -> bool:
	# Dry rule. Every heading stops. A dry north throat passes north, east,
	# and west, and this piece passes none of them.
	return false

static func archivolt_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule. Only the two perpendicular headings pass. A flooded north
	# archivolt passes east and west and stops north and south. One click
	# faces east and only north and south pass. A flooded south archivolt
	# passes the same east and west. A flooded north cill passes that same
	# pair and, while dry, passes north and south.
	var facing := archivolt_facing(rot)
	return dir == rotate_dir(facing, 1) or dir == rotate_dir(facing, -1)

static func abacus_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Dry, every heading stops, so
	# there is no dry open set. Flooded, only the facing passes, so opposite
	# facings do not share that set.
	return rotate_dir("N", posmod(int(norm_rot("abacus", rot) / 90.0), 4))

static func abacus_passes(_rot: int, _dir: String) -> bool:
	# Dry rule. Every heading stops. A dry lintel passes every heading and
	# stays shut under water, so this piece does not repeat that pair.
	return false

static func abacus_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule. Only the facing passes. A flooded north abacus passes
	# only north. East, west, and south stop. One click faces east and only
	# east passes. A flooded north archivolt passes east and west instead.
	return dir == abacus_facing(rot)

static func rebate_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Dry, every heading stops, so
	# there is no dry open set. Flooded, only the opposite passes, so opposite
	# facings do not share that set.
	return rotate_dir("N", posmod(int(norm_rot("rebate", rot) / 90.0), 4))

static func rebate_passes(_rot: int, _dir: String) -> bool:
	# Dry rule. Every heading stops. One click still stops every heading.
	# Opposite dry facings share that shut state.
	return false

static func rebate_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule. Only the opposite of the facing passes. A flooded north
	# rebate passes only south. East, west, and north stop. One click faces
	# east and only west passes. A flooded north throat passes this same
	# south beam, and while dry it passes north, east, and west.
	return dir == rotate_dir(rebate_facing(rot), 2)

static func echinus_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Dry, every heading except the
	# opposite passes, so opposite facings do not share that set. Flooded,
	# only the next clockwise heading passes, so opposite facings do not
	# share that heading either.
	return rotate_dir("N", posmod(int(norm_rot("echinus", rot) / 90.0), 4))

static func echinus_passes(rot: int, dir: String) -> bool:
	# Dry rule. Every heading except the opposite. A dry north echinus passes
	# north, east, and west, and stops south. A dry fillet passes only south
	# and stays shut under water, so this piece does not repeat that pair.
	return dir != rotate_dir(echinus_facing(rot), 2)

static func echinus_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule. Only the next clockwise heading passes. A flooded north
	# echinus passes only east. North, west, and south stop. One click faces
	# east and only south passes. A flooded north rebate passes only south.
	# A flooded north abacus passes only north. A flooded north throat passes
	# only south.
	return dir == rotate_dir(echinus_facing(rot), 1)

static func annulet_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Dry, every heading except the
	# opposite passes, so opposite facings do not share that set. Flooded,
	# only the next counterclockwise heading passes, so opposite facings do
	# not share that heading either.
	return rotate_dir("N", posmod(int(norm_rot("annulet", rot) / 90.0), 4))

static func annulet_passes(rot: int, dir: String) -> bool:
	# Dry rule. Every heading except the opposite. A dry north annulet passes
	# north, east, and west, and stops south. A bead passes only east while
	# dry and stays shut under water. A quirk passes only west while dry and
	# stays shut under water. This piece does not repeat either pair.
	return dir != rotate_dir(annulet_facing(rot), 2)

static func annulet_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule. Only the next counterclockwise heading passes. A flooded
	# north annulet passes only west. North, east, and south stop. One click
	# faces east and only north passes. A flooded north echinus passes only
	# east. A flooded north rebate passes only south. A flooded north abacus
	# passes only north. A flooded north throat passes only south.
	return dir == rotate_dir(annulet_facing(rot), -1)

static func listel_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Dry, every heading stops, so
	# there is no dry open set. Flooded, the facing and the next clockwise
	# heading pass, so opposite facings do not share that pair.
	return rotate_dir("N", posmod(int(norm_rot("listel", rot) / 90.0), 4))

static func listel_passes(_rot: int, _dir: String) -> bool:
	# Dry rule. Every heading stops. One click still stops every heading.
	# Opposite dry facings share that shut state. A dry cyma passes only the
	# facing and stays shut under water, so this piece does not repeat that pair.
	return false

static func listel_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule. The facing and the next clockwise heading pass. A flooded
	# north listel passes north and east. West and south stop. One click faces
	# east and north and west stop, while east and south pass. A flooded north
	# annulet passes only west. A flooded north echinus passes only east. A
	# flooded north rebate passes only south. A flooded north abacus passes
	# only north. A flooded north throat passes only south.
	var facing := listel_facing(rot)
	return dir == facing or dir == rotate_dir(facing, 1)

static func necking_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Dry, every heading stops, so
	# there is no dry open set. Flooded, the facing and the next
	# counterclockwise heading pass, so opposite facings do not share that pair.
	return rotate_dir("N", posmod(int(norm_rot("necking", rot) / 90.0), 4))

static func necking_passes(_rot: int, _dir: String) -> bool:
	# Dry rule. Every heading stops. One click still stops every heading.
	# Opposite dry facings share that shut state. A dry scotia passes the
	# facing and the next counterclockwise heading and stays shut under water,
	# so this piece does not repeat that pair.
	return false

static func necking_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule. The facing and the next counterclockwise heading pass. A
	# flooded north necking passes north and west. East and south stop. One
	# click faces east and only east and north pass. A flooded north listel
	# passes north and east. A flooded north annulet passes only west. A
	# flooded north echinus passes only east. A flooded north rebate passes
	# only south. A flooded north abacus passes only north. A flooded north
	# throat passes only south.
	var facing := necking_facing(rot)
	return dir == facing or dir == rotate_dir(facing, -1)

static func taenia_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Dry, every heading stops, so
	# there is no dry open set. Flooded, the facing and the opposite pass,
	# so opposite facings share that pair.
	return rotate_dir("N", posmod(int(norm_rot("taenia", rot) / 90.0), 4))

static func taenia_passes(_rot: int, _dir: String) -> bool:
	# Dry rule. Every heading stops. One click still stops every heading.
	# Opposite dry facings share that shut state. A dry cill passes the
	# facing and the opposite, so this piece does not repeat that dry pair.
	return false

static func taenia_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule. The facing and the opposite pass. A flooded north taenia
	# passes north and south. East and west stop. One click faces east and
	# only east and west pass. A flooded south taenia passes the same north
	# and south. A flooded north larmier passes this same pair and, while dry,
	# passes east and west. A flooded north listel passes north and east. A
	# flooded north necking passes north and west. A flooded north annulet
	# passes only west. A flooded north echinus passes only east. A flooded
	# north rebate passes only south. A flooded north abacus passes only north.
	# A flooded north throat passes only south.
	var facing := taenia_facing(rot)
	return dir == facing or dir == rotate_dir(facing, 2)

static func baguette_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Dry, every heading stops, so
	# there is no dry open set. Flooded, every heading except the opposite
	# passes, so opposite facings do not share that set.
	return rotate_dir("N", posmod(int(norm_rot("baguette", rot) / 90.0), 4))

static func baguette_passes(_rot: int, _dir: String) -> bool:
	# Dry rule. Every heading stops. One click still stops every heading.
	# Opposite dry facings share that shut state. An archivolt stays shut
	# while dry and passes the perpendicular pair under water, so this piece
	# does not repeat that pair. A dry larmier passes the perpendicular pair,
	# so this piece does not copy that dry half either.
	return false

static func baguette_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule. Every heading except the opposite passes. A flooded north
	# baguette passes north, east, and west, and stops south. One click faces
	# east and passes east, north, and south, and stops west. A flooded south
	# baguette passes south, east, and west, and stops north. A flooded north
	# threshold passes this same set and, while dry, passes only south. A
	# flooded north taenia passes north and south. A flooded north listel
	# passes north and east. A flooded north necking passes north and west.
	# A flooded north annulet passes only west. A flooded north echinus passes
	# only east. A flooded north rebate passes only south. A flooded north
	# abacus passes only north. A flooded north throat passes only south.
	return dir != rotate_dir(baguette_facing(rot), 2)

static func reglet_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Dry, every heading stops, so
	# there is no dry open set. Flooded, every heading except the next
	# counterclockwise one passes, so opposite facings do not share that set.
	return rotate_dir("N", posmod(int(norm_rot("reglet", rot) / 90.0), 4))

static func reglet_passes(_rot: int, _dir: String) -> bool:
	# Dry rule. Every heading stops. One click still stops every heading.
	# Opposite dry facings share that shut state. A dry soffit passes every
	# heading except the next counterclockwise one and stays shut under water,
	# so this piece does not repeat that dry set.
	return false

static func reglet_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule. The facing, the opposite, and the next clockwise heading
	# pass. A flooded north reglet passes north, south, and east, and stops
	# west. One click faces east and east, west, and south pass while north
	# stops. A flooded south reglet passes south, north, and west, and stops
	# east. A dry soffit passes this same north set and stays shut under water.
	# A flooded north drip passes only west. A flooded north baguette passes
	# north, east, and west, and stops south. A flooded north listel passes
	# north and east. A flooded north necking passes north and west. A flooded
	# north taenia passes north and south. A flooded north annulet passes only
	# west. A flooded north echinus passes only east. A flooded north rebate
	# passes only south. A flooded north abacus passes only north. A flooded
	# north throat passes only south.
	return dir != rotate_dir(reglet_facing(rot), -1)

static func billet_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Dry, every heading stops, so
	# there is no dry open set. Flooded, every heading except the next
	# clockwise one passes, so opposite facings do not share that set.
	return rotate_dir("N", posmod(int(norm_rot("billet", rot) / 90.0), 4))

static func billet_passes(_rot: int, _dir: String) -> bool:
	# Dry rule. Every heading stops. One click still stops every heading.
	# Opposite dry facings share that shut state. A dry fascia passes every
	# heading except the next clockwise one and stays shut under water, so
	# this piece does not repeat that dry set.
	return false

static func billet_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule. The facing, the opposite, and the next counterclockwise
	# heading pass. A flooded north billet passes north, south, and west, and
	# stops east. One click faces east and east, west, and north pass while
	# south stops. A flooded south billet passes south, north, and east, and
	# stops west. A dry fascia passes this same north set and stays shut under
	# water. A flooded north beak passes only east. A flooded north reglet
	# passes north, south, and east, and stops west. A flooded north baguette
	# passes north, east, and west, and stops south. A flooded north listel
	# passes north and east. A flooded north necking passes north and west. A
	# flooded north taenia passes north and south. A flooded north annulet
	# passes only west. A flooded north echinus passes only east. A flooded
	# north rebate passes only south. A flooded north abacus passes only north.
	# A flooded north throat passes only south.
	return dir != rotate_dir(billet_facing(rot), 1)

static func reed_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Dry, every heading stops. Flooded,
	# every heading passes, so every facing shares that open set.
	return rotate_dir("N", posmod(int(norm_rot("reed", rot) / 90.0), 4))

static func reed_passes(_rot: int, _dir: String) -> bool:
	# Dry rule. Every heading stops. One click still stops every heading.
	# Opposite dry facings share that shut state. A lintel passes every
	# heading while dry and stays shut under water, so this piece does not
	# repeat that dry set.
	return false

static func reed_flood_passes(_rot: int, _dir: String) -> bool:
	# Flooded rule. Every heading passes. A flooded north reed passes north,
	# east, south, and west. One click still passes every heading. A flooded
	# impost stops its facing, so it does not pass this set. A dry ovolo
	# passes every heading except its facing and stays shut under water. A
	# flooded north billet passes north, south, and west, and stops east. A
	# flooded north reglet passes north, south, and east, and stops west. A
	# flooded north baguette passes north, east, and west, and stops south. A
	# flooded north listel passes north and east. A flooded north necking
	# passes north and west. A flooded north taenia passes north and south. A
	# flooded north annulet passes only west. A flooded north echinus passes
	# only east. A flooded north rebate passes only south. A flooded north
	# abacus passes only north. A flooded north throat passes only south.
	return true

static func staff_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Dry, every heading stops. Flooded,
	# the opposite and the next clockwise heading pass, so opposite facings do
	# not share that set.
	return rotate_dir("N", posmod(int(norm_rot("staff", rot) / 90.0), 4))

static func staff_passes(_rot: int, _dir: String) -> bool:
	# Dry rule. Every heading stops. One click still stops every heading.
	# Opposite dry facings share that shut state. A dry torus passes the
	# opposite and the next clockwise heading and stays shut under water, so
	# this piece does not repeat that dry set.
	return false

static func staff_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule. The opposite and the next clockwise heading pass. A flooded
	# north staff passes south and east, and stops north and west. One click
	# faces east and south and west pass while north and east stop. A flooded
	# south staff passes north and west, and stops south and east. A dry torus
	# passes this same north set and stays shut under water. An impost stays
	# open on every heading except its facing. A flooded north reed passes
	# every heading. A flooded north billet passes north, south, and west, and
	# stops east. A flooded north reglet passes north, south, and east, and
	# stops west. A flooded north baguette passes north, east, and west, and
	# stops south. A flooded north taenia passes north and south. A flooded
	# north necking passes north and west. A flooded north listel passes north
	# and east. A flooded north annulet passes only west. A flooded north
	# echinus passes only east. A flooded north rebate passes only south. A
	# flooded north abacus passes only north. A flooded north throat passes
	# only south.
	var facing := staff_facing(rot)
	return dir == rotate_dir(facing, 2) or dir == rotate_dir(facing, 1)

static func thumb_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Dry, every heading stops. Flooded,
	# the opposite and the next counterclockwise heading pass, so opposite
	# facings do not share that set.
	return rotate_dir("N", posmod(int(norm_rot("thumb", rot) / 90.0), 4))

static func thumb_passes(_rot: int, _dir: String) -> bool:
	# Dry rule. Every heading stops. One click still stops every heading.
	# Opposite dry facings share that shut state. A dry ogee passes the
	# opposite and the next counterclockwise heading and stays shut under
	# water, so this piece does not repeat that dry set.
	return false

static func thumb_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule. The opposite and the next counterclockwise heading pass.
	# A flooded north thumb passes south and west, and stops north and east.
	# One clockwise click from north faces east, and north and west pass while
	# south and east stop. One click from south faces west, and east and south
	# pass while north and west stop. A flooded south thumb passes north and
	# east, and stops south and west. A dry ogee passes this same north set
	# and stays shut under water. A flooded north staff passes south and east,
	# and stops north and west. A flooded reed passes every heading. A flooded
	# north billet passes north, south, and west, and stops east. A flooded
	# north reglet passes north, south, and east, and stops west. A flooded
	# north baguette passes north, east, and west, and stops south. A flooded
	# north taenia passes north and south. A flooded north necking passes
	# north and west. A flooded north listel passes north and east. A flooded
	# north annulet passes only west. A flooded north echinus passes only east.
	# A flooded north rebate passes only south. A flooded north abacus passes
	# only north. A flooded north throat passes only south.
	var facing := thumb_facing(rot)
	return dir == rotate_dir(facing, 2) or dir == rotate_dir(facing, -1)

static func roll_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Dry, every heading stops. Flooded,
	# every heading except the facing passes, so opposite facings do not share
	# that set.
	return rotate_dir("N", posmod(int(norm_rot("roll", rot) / 90.0), 4))

static func roll_passes(_rot: int, _dir: String) -> bool:
	# Dry rule. Every heading stops. One click still stops every heading.
	# Opposite dry facings share that shut state. A dry ovolo passes every
	# heading except its facing and stays shut under water, so this piece does
	# not repeat that dry set.
	return false

static func roll_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule. Every heading except the facing passes. A flooded north
	# roll passes south, east, and west, and stops north. One click faces east
	# and north, south, and west pass while east stops. A flooded south roll
	# passes north, east, and west, and stops south. Opposite flooded facings
	# do not share that set. A taenia stays shut while dry and passes its
	# facing and the opposite under water. A flooded north impost passes this
	# same set and, while dry, passes only north. A dry ovolo passes every
	# heading except north and stays shut under water. A flooded north thumb
	# passes south and west. A flooded north staff passes south and east. A
	# flooded reed passes every heading. A flooded north billet passes north,
	# south, and west, and stops east. A flooded north reglet passes north,
	# south, and east, and stops west. A flooded north baguette passes north,
	# east, and west, and stops south. A flooded north taenia passes north and
	# south. A flooded north necking passes north and west. A flooded north
	# listel passes north and east. A flooded north annulet passes only west.
	# A flooded north echinus passes only east. A flooded north rebate passes
	# only south. A flooded north abacus passes only north. A flooded north
	# throat passes only south.
	return dir != roll_facing(rot)

static func gutta_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Dry, only the facing passes.
	# Flooded, the two perpendicular headings pass, so opposite facings share
	# that flooded set.
	return rotate_dir("N", posmod(int(norm_rot("gutta", rot) / 90.0), 4))

static func gutta_passes(rot: int, dir: String) -> bool:
	# Dry rule. Only the facing passes. North passes only north and stops east,
	# west, and south. One click faces east and only east passes. Opposite dry
	# facings do not share that beam. A dry cyma passes this same beam and
	# stays shut under water. A listel stays shut while dry and passes north
	# and east under water, so this piece does not repeat that pair.
	return dir == gutta_facing(rot)

static func gutta_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule. The two headings perpendicular to the facing pass. A flooded
	# north gutta passes east and west, and stops north and south. One click
	# faces east and only north and south pass. A flooded south gutta passes
	# the same east and west. Opposite flooded facings share that set. A dry
	# corona passes this same north pair and stays shut under water. An
	# archivolt stays shut while dry and passes east and west under water. An
	# architrave passes east and west while dry and only its facing under
	# water. A cill passes north and south while dry and east and west under
	# water. A flooded north listel passes north and east. A flooded north
	# roll passes south, east, and west, and stops north. A flooded north
	# thumb passes south and west. A flooded north staff passes south and east.
	# A flooded reed passes every heading. A flooded north taenia passes north
	# and south. A flooded north billet passes north, south, and west, and
	# stops east. A flooded north reglet passes north, south, and east, and
	# stops west. A flooded north baguette passes north, east, and west, and
	# stops south. A flooded north necking passes north and west. A flooded
	# north annulet passes only west. A flooded north echinus passes only east.
	# A flooded north rebate passes only south. A flooded north abacus passes
	# only north. A flooded north throat passes only south.
	var facing := gutta_facing(rot)
	return dir == rotate_dir(facing, 1) or dir == rotate_dir(facing, -1)

static func dentil_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. Dry, the opposite and the next
	# counterclockwise heading pass. Flooded, the facing and the opposite pass,
	# so opposite flooded facings share that axis.
	return rotate_dir("N", posmod(int(norm_rot("dentil", rot) / 90.0), 4))

static func dentil_passes(rot: int, dir: String) -> bool:
	# Dry rule. The opposite and the next counterclockwise heading pass. A dry
	# north dentil passes south and west, and stops north and east. One click
	# faces east and only west and north pass. Opposite dry facings do not
	# share that set. A dry ogee passes this same pair and stays shut under
	# water. A dry gutta passes only the facing, so this piece does not repeat
	# that beam. A listel stays shut while dry and passes north and east under
	# water.
	var facing := dentil_facing(rot)
	return dir == rotate_dir(facing, 2) or dir == rotate_dir(facing, -1)

static func dentil_flood_passes(rot: int, dir: String) -> bool:
	# Flooded rule. The facing and the opposite pass. A flooded north dentil
	# passes north and south, and stops east and west. One click faces east
	# and only east and west pass. A flooded south dentil passes the same
	# north and south. Opposite flooded facings share that set. A flooded
	# north taenia passes this same pair and stays shut while dry. A dry cill
	# passes north and south and, under water, passes east and west. A flooded
	# north larmier passes north and south and, while dry, passes east and
	# west. A dry north gutta passes only north. A flooded north gutta passes
	# east and west. A flooded north roll passes south, east, and west. A
	# flooded north thumb passes south and west. A flooded north staff passes
	# south and east. A flooded reed passes every heading. A flooded north
	# billet passes north, south, and west, and stops east. A flooded north
	# reglet passes north, south, and east, and stops west. A flooded north
	# baguette passes north, east, and west, and stops south. A flooded north
	# necking passes north and west. A flooded north listel passes north and
	# east. A flooded north annulet passes only west. A flooded north echinus
	# passes only east. A flooded north rebate passes only south. A flooded
	# north abacus passes only north. A flooded north throat passes only south.
	var facing := dentil_facing(rot)
	return dir == facing or dir == rotate_dir(facing, 2)

static func sluice_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. The exit follows this facing.
	return rotate_dir("N", posmod(int(rot / 90.0), 4))

static func weir_color(color: String) -> String:
	# The facing exit swaps the two lantern colors. White is not painted.
	if color == "red":
		return "blue"
	if color == "blue":
		return "red"
	return color

static func weir_facing(rot: int) -> String:
	# 0 north, 90 east, 180 south, 270 west. The exit follows this facing.
	return rotate_dir("N", posmod(int(rot / 90.0), 4))

static func flood_count(chart: Dictionary, state: Dictionary) -> int:
	var phases: Array = chart["tide_phases"]
	if phases.is_empty():
		return 0
	var idx := clampi(int(state["tide_index"]), 0, phases.size() - 1)
	return int(phases[idx])

static func is_flooded(chart: Dictionary, state: Dictionary, cell: Vector2i) -> bool:
	var n := flood_count(chart, state)
	if n <= 0:
		return false
	return cell.y >= int(chart["rows"]) - n

# One beam, used to prove a mirror cycle dies. `start` is the first cell entered.
static func cast_beam(chart: Dictionary, state: Dictionary, start: Vector2i, dir: String, color: String) -> Dictionary:
	var occupants := _occupants(chart, state)
	var segments: Array = []
	var visited := {}
	var prev: Vector2i = start - VEC[dir]
	_cast(chart, state, occupants, start, dir, color, 0, visited, {}, {}, segments, prev)
	return {"segments": segments}

static func trace(chart: Dictionary, state: Dictionary) -> Dictionary:
	var occupants := _occupants(chart, state)
	var dock_hits := {}
	for raw_dock in chart["docks"]:
		var dock: Dictionary = raw_dock
		dock_hits[str(dock["id"])] = []
	var boat_lit := {}
	for raw_boat in chart["boats"]:
		var boat: Dictionary = raw_boat
		boat_lit[str(boat["id"])] = false
	var segments: Array = []
	var visited := {}
	for raw_lantern in chart["lanterns"]:
		var lantern: Dictionary = raw_lantern
		var origin := Vector2i(int(lantern["x"]), int(lantern["y"]))
		if is_flooded(chart, state, origin):
			continue
		var dir := str(lantern["dir"])
		var nxt: Vector2i = origin + VEC[dir]
		_cast(chart, state, occupants, nxt, dir, str(lantern["color"]), 0, visited, dock_hits, boat_lit, segments, origin)
	return {
		"docks": dock_hits,
		"boats": boat_lit,
		"segments": segments,
		"flood": flood_count(chart, state),
	}

static func failure_notes(chart: Dictionary, state: Dictionary) -> PackedStringArray:
	var result := trace(chart, state)
	if _pieces_share_cell(chart, state):
		return PackedStringArray(["Two pieces stand on one cell."])
	var hull := false
	var dark := false
	var wrong := false
	var glowing := false
	for raw_boat in chart["boats"]:
		var boat: Dictionary = raw_boat
		if bool(result["boats"][str(boat["id"])]):
			hull = true
	for raw_dock in chart["docks"]:
		var dock: Dictionary = raw_dock
		var hits: Array = result["docks"][str(dock["id"])]
		if bool(dock.get("keep_dark", false)):
			if not hits.is_empty():
				glowing = true
			continue
		if hits.has(str(dock["color"])):
			continue
		if hits.is_empty():
			dark = true
		else:
			wrong = true
	var notes := PackedStringArray()
	if hull:
		notes.append("A sleeping hull is still in the light.")
	if glowing:
		notes.append("A dock is in the light.")
	if wrong:
		notes.append("A dock has the wrong color.")
	if dark:
		notes.append("A dock is still dark.")
	return notes

static func is_cleared(chart: Dictionary, state: Dictionary) -> bool:
	return failure_notes(chart, state).is_empty()

static func _pieces_share_cell(chart: Dictionary, state: Dictionary) -> bool:
	if not state.has("pieces"):
		return false
	var seen := {}
	var piece_state: Dictionary = state["pieces"]
	for raw_piece in chart["pieces"]:
		var piece: Dictionary = raw_piece
		var id := str(piece["id"])
		if not piece_state.has(id):
			continue
		var pst: Dictionary = piece_state[id]
		var cell := _socket_cell(piece, str(pst["socket"]))
		var key := "%d,%d" % [cell.x, cell.y]
		if seen.has(key):
			return true
		seen[key] = true
	return false

static func _occupants(chart: Dictionary, state: Dictionary) -> Dictionary:
	var map := {}
	for raw_obs in chart["obstacles"]:
		var cell: Vector2i = raw_obs
		map[cell] = {"kind": "obstacle", "id": "pile"}
	for raw_lantern in chart["lanterns"]:
		var lantern: Dictionary = raw_lantern
		map[Vector2i(int(lantern["x"]), int(lantern["y"]))] = {
			"kind": "lantern",
			"id": str(lantern["id"]),
		}
	for raw_dock in chart["docks"]:
		var dock: Dictionary = raw_dock
		map[Vector2i(int(dock["x"]), int(dock["y"]))] = {
			"kind": "dock",
			"id": str(dock["id"]),
			"color": str(dock["color"]),
			"pass_other": bool(dock.get("pass_other", false)),
		}
	for raw_boat in chart["boats"]:
		var boat: Dictionary = raw_boat
		map[Vector2i(int(boat["x"]), int(boat["y"]))] = {
			"kind": "boat",
			"id": str(boat["id"]),
		}
	for raw_fix in chart["fixtures"]:
		var fix: Dictionary = raw_fix
		map[Vector2i(int(fix["x"]), int(fix["y"]))] = {
			"kind": str(fix["kind"]),
			"id": str(fix["id"]),
			"rot": int(fix["rot"]),
		}
	var piece_state: Dictionary = state["pieces"]
	for raw_piece in chart["pieces"]:
		var piece: Dictionary = raw_piece
		var id := str(piece["id"])
		var pst: Dictionary = piece_state[id]
		var cell := _socket_cell(piece, str(pst["socket"]))
		map[cell] = {
			"kind": str(piece["kind"]),
			"id": id,
			"rot": int(pst["rot"]),
			"player": true,
		}
	return map

static func _socket_cell(piece: Dictionary, socket_id: String) -> Vector2i:
	for raw_sock in piece["sockets"]:
		var sock: Dictionary = raw_sock
		if str(sock["id"]) == socket_id:
			return Vector2i(int(sock["x"]), int(sock["y"]))
	return Vector2i(-1, -1)

static func _cast(
	chart: Dictionary,
	state: Dictionary,
	occupants: Dictionary,
	cell: Vector2i,
	dir: String,
	color: String,
	bounces: int,
	visited: Dictionary,
	dock_hits: Dictionary,
	boat_lit: Dictionary,
	segments: Array,
	prev: Vector2i
) -> void:
	var steps := 0
	while steps < MAX_STEPS:
		steps += 1
		if bounces > MAX_BOUNCES or segments.size() > MAX_SEGMENTS:
			return
		if not _in_bounds(chart, cell):
			return
		var key := "%d,%d,%s,%s" % [cell.x, cell.y, dir, color]
		if visited.has(key):
			return
		visited[key] = true
		var flooded := is_flooded(chart, state, cell)
		if flooded and not _flood_carries(occupants, cell):
			# A flooded drip is not a full carrier. Only the dry-stopped
			# direction enters. The other three stop at the waterline.
			if not _flooded_drip_passes(occupants, cell, dir) and not _flooded_beak_passes(occupants, cell, dir) and not _flooded_hood_passes(occupants, cell, dir) and not _flooded_throat_passes(occupants, cell, dir) and not _flooded_larmier_passes(occupants, cell, dir) and not _flooded_cill_passes(occupants, cell, dir) and not _flooded_threshold_passes(occupants, cell, dir) and not _flooded_impost_passes(occupants, cell, dir) and not _flooded_architrave_passes(occupants, cell, dir) and not _flooded_archivolt_passes(occupants, cell, dir) and not _flooded_abacus_passes(occupants, cell, dir) and not _flooded_rebate_passes(occupants, cell, dir) and not _flooded_echinus_passes(occupants, cell, dir) and not _flooded_annulet_passes(occupants, cell, dir) and not _flooded_listel_passes(occupants, cell, dir) and not _flooded_necking_passes(occupants, cell, dir) and not _flooded_taenia_passes(occupants, cell, dir) and not _flooded_baguette_passes(occupants, cell, dir) and not _flooded_reglet_passes(occupants, cell, dir) and not _flooded_billet_passes(occupants, cell, dir) and not _flooded_reed_passes(occupants, cell, dir) and not _flooded_staff_passes(occupants, cell, dir) and not _flooded_thumb_passes(occupants, cell, dir) and not _flooded_roll_passes(occupants, cell, dir) and not _flooded_gutta_passes(occupants, cell, dir) and not _flooded_dentil_passes(occupants, cell, dir):
				segments.append(_boundary_seg(prev, cell, color))
				return
		# A dry mullion passes north and south. East and west stop on the edge
		# and never enter the cell. Flooded mullions already returned above.
		if _dry_mullion_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry transom passes east and west. North and south stop on the edge
		# and never enter the cell. Flooded transoms already returned above.
		if _dry_transom_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry casement passes only its facing. Every other direction stops
		# on the edge and never enters the cell. Flooded casements already
		# returned above.
		if _dry_casement_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry jamb passes both directions of its open axis. The other axis
		# stops on the edge and never enters the cell. Flooded jambs already
		# returned above.
		if _dry_jamb_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry astragal passes its facing and the next clockwise direction.
		# The other two directions stop on the edge and never enter the cell.
		# Flooded astragals already returned above.
		if _dry_astragal_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry scotia passes its facing and the next counterclockwise
		# direction. The other two directions stop on the edge and never enter
		# the cell. Flooded scotias already returned above.
		if _dry_scotia_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry torus passes the opposite of its facing and the next clockwise
		# direction. The other two directions stop on the edge and never enter
		# the cell. Flooded tori already returned above.
		if _dry_torus_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry ogee passes the opposite of its facing and the next
		# counterclockwise direction. The other two directions stop on the edge
		# and never enter the cell. Flooded ogees already returned above.
		if _dry_ogee_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry ovolo passes every direction except its facing. That facing
		# stops on the edge and never enters the cell. Flooded ovolos already
		# returned above.
		if _dry_ovolo_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry cavetto passes every direction except the opposite of its
		# facing. That opposite direction stops on the edge and never enters
		# the cell. Flooded cavetti already returned above.
		if _dry_cavetto_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry fillet passes only the opposite of its facing. The facing and
		# both sides stop on the edge and never enter the cell. Flooded
		# fillets already returned above.
		if _dry_fillet_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry corona passes the two directions perpendicular to its facing.
		# The facing and the opposite stop on the edge and never enter the
		# cell. Flooded coronas already returned above.
		if _dry_corona_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry bead passes only the next clockwise direction. The other three
		# directions stop on the edge and never enter the cell. Flooded beads
		# already returned above.
		if _dry_bead_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry quirk passes only the next counterclockwise direction. The
		# other three directions stop on the edge and never enter the cell.
		# Flooded quirks already returned above.
		if _dry_quirk_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry cyma passes only its facing. The other three directions stop
		# on the edge and never enter the cell. Flooded cymas already returned
		# above.
		if _dry_cyma_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry fascia passes every direction except the next clockwise one.
		# That clockwise direction stops on the edge and never enters the cell.
		# Flooded fascias already returned above.
		if _dry_fascia_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry soffit passes every direction except the next counterclockwise
		# one. That direction stops on the edge and never enters the cell.
		# Flooded soffits already returned above.
		if _dry_soffit_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry drip passes every direction except the next counterclockwise
		# one. That direction stops on the edge. A flooded drip already passed
		# the waterline gate above, and only its dry-stopped direction is here.
		if not flooded and _dry_drip_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry beak passes every direction except the next clockwise one.
		# That direction stops on the edge. A flooded beak already passed the
		# waterline gate above, and only its dry-stopped direction is here.
		if not flooded and _dry_beak_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry hood passes every direction except its facing. That direction
		# stops on the edge. A flooded hood already passed the waterline gate
		# above, and only its facing is here.
		if not flooded and _dry_hood_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry throat passes every direction except the opposite of its facing.
		# That direction stops on the edge. A flooded throat already passed the
		# waterline gate above, and only that opposite direction is here.
		if not flooded and _dry_throat_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry larmier passes the two directions perpendicular to its facing.
		# The facing and the opposite stop on the edge. A flooded larmier already
		# passed the waterline gate above, and only that axis is here.
		if not flooded and _dry_larmier_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry cill passes the facing and the opposite. The two perpendicular
		# directions stop on the edge. A flooded cill already passed the
		# waterline gate above, and only that perpendicular pair is here.
		if not flooded and _dry_cill_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry threshold passes only the opposite of its facing. The other
		# three stop on the edge. A flooded threshold already passed the
		# waterline gate above, and every direction except that opposite is here.
		if not flooded and _dry_threshold_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry impost passes only its facing. The other three stop on the
		# edge. A flooded impost already passed the waterline gate above, and
		# every direction except that facing is here.
		if not flooded and _dry_impost_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry architrave passes the two perpendicular headings. The facing
		# and the opposite stop on the edge. A flooded architrave already
		# passed the waterline gate above, and only the facing is here.
		if not flooded and _dry_architrave_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry archivolt stops every heading on the edge. A flooded archivolt
		# already passed the waterline gate above, and only the two
		# perpendicular headings are here.
		if not flooded and _dry_archivolt_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry abacus stops every heading on the edge. A flooded abacus
		# already passed the waterline gate above, and only the facing is here.
		if not flooded and _dry_abacus_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry rebate stops every heading on the edge. A flooded rebate
		# already passed the waterline gate above, and only the opposite is here.
		if not flooded and _dry_rebate_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry echinus stops only the opposite on the edge. The other three
		# headings enter. A flooded echinus already passed the waterline gate,
		# and only the clockwise heading is here.
		if not flooded and _dry_echinus_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry annulet stops only the opposite on the edge. The other three
		# headings enter. A flooded annulet already passed the waterline gate,
		# and only the counterclockwise heading is here.
		if not flooded and _dry_annulet_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry listel stops every heading on the edge. A flooded listel
		# already passed the waterline gate, and only the facing and the
		# clockwise heading are here.
		if not flooded and _dry_listel_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry necking stops every heading on the edge. A flooded necking
		# already passed the waterline gate, and only the facing and the
		# counterclockwise heading are here.
		if not flooded and _dry_necking_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry taenia stops every heading on the edge. A flooded taenia
		# already passed the waterline gate, and only the facing and the
		# opposite are here.
		if not flooded and _dry_taenia_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry baguette stops every heading on the edge. A flooded baguette
		# already passed the waterline gate, and every heading except the
		# opposite is here.
		if not flooded and _dry_baguette_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry reglet stops every heading on the edge. A flooded reglet
		# already passed the waterline gate, and every heading except the
		# counterclockwise one is here.
		if not flooded and _dry_reglet_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry billet stops every heading on the edge. A flooded billet
		# already passed the waterline gate, and every heading except the
		# clockwise one is here.
		if not flooded and _dry_billet_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry reed stops every heading on the edge. A flooded reed already
		# passed the waterline gate, and every heading is here.
		if not flooded and _dry_reed_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry staff stops every heading on the edge. A flooded staff already
		# passed the waterline gate, and the opposite and clockwise headings
		# are here.
		if not flooded and _dry_staff_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry thumb stops every heading on the edge. A flooded thumb already
		# passed the waterline gate, and the opposite and counterclockwise
		# headings are here.
		if not flooded and _dry_thumb_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry roll stops every heading on the edge. A flooded roll already
		# passed the waterline gate, and every heading except the facing is here.
		if not flooded and _dry_roll_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry gutta stops every heading except the facing. A flooded gutta
		# already passed the waterline gate, and the two perpendicular headings
		# are here.
		if not flooded and _dry_gutta_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		# A dry dentil stops the facing and the clockwise heading. A flooded
		# dentil already passed the waterline gate, and the facing and the
		# opposite are here.
		if not flooded and _dry_dentil_blocks(occupants, cell, dir):
			segments.append(_boundary_seg(prev, cell, color))
			return
		segments.append(_center_seg(prev, cell, color))
		if not occupants.has(cell):
			prev = cell
			cell = cell + VEC[dir]
			continue
		var occ: Dictionary = occupants[cell]
		var kind := str(occ["kind"])
		if kind == "dock":
			# A pass-other dock catches only its own color. Any other color
			# keeps going, so a turned beam cannot die on the pier.
			var want := str(occ.get("color", ""))
			if bool(occ.get("pass_other", false)) and color != want:
				prev = cell
				cell = cell + VEC[dir]
				continue
			_note_dock(dock_hits, str(occ["id"]), color)
			return
		if kind == "boat":
			boat_lit[str(occ["id"])] = true
			return
		if kind == "obstacle" or kind == "lantern":
			return
		if kind == "mirror":
			dir = reflect(int(occ["rot"]), dir)
			bounces += 1
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "tide_mirror":
			# Dry glass is open: direction and color stay as they are.
			if flooded:
				dir = reflect(int(occ["rot"]), dir)
				bounces += 1
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "shutter":
			# Dry glass is shut. Flooded glass is a straight gate: no turn, no tint.
			if not flooded:
				return
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "stain":
			# Straight through, dry or flooded. The color becomes the stain's.
			color = stain_color(int(occ["rot"]))
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "vane":
			# The facing picks the exit. A head-on beam stops. Color stays.
			var facing := vane_facing(int(occ["rot"]))
			if dir == rotate_dir(facing, 2):
				return
			dir = facing
			bounces += 1
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "well":
			# Dry mouth stops the beam. A flooded mouth always leaves north.
			if not flooded:
				return
			dir = "N"
			bounces += 1
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "siphon":
			# Dry tube stops the beam. A flooded tube always leaves north, and
			# that exit swaps red with blue. White stays white.
			if not flooded:
				return
			dir = "N"
			color = siphon_color(color)
			bounces += 1
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "sluice":
			# Dry gate stops the beam, whichever way it faces. A flooded gate
			# may be entered from any side and always leaves along its facing.
			# The color stays. That exit costs a bounce.
			if not flooded:
				return
			dir = sluice_facing(int(occ["rot"]))
			bounces += 1
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "weir":
			# Dry gate stops the beam, whichever way it faces. A flooded gate
			# may be entered from any side and always leaves along its facing.
			# That exit swaps red with blue. White stays white. It costs a bounce.
			if not flooded:
				return
			dir = weir_facing(int(occ["rot"]))
			color = weir_color(color)
			bounces += 1
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "lintel":
			# Dry stone passes the beam straight, same direction and same color.
			# That pass costs no bounce. A flooded lintel never reaches here:
			# the beam already stopped at the waterline.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "mullion":
			# Dry north-south passes straight, same direction and same color.
			# That pass costs no bounce. Dry east-west never reaches here.
			# A flooded mullion never reaches here either.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "transom":
			# Dry east-west passes straight, same direction and same color.
			# That pass costs no bounce. Dry north-south never reaches here.
			# A flooded transom never reaches here either.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "casement":
			# Dry facing passes straight, same direction and same color.
			# That pass costs no bounce. It does not turn and it does not split.
			# Every other dry direction never reaches here. A flooded casement
			# never reaches here either.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "jamb":
			# Dry open axis passes straight, same direction and same color.
			# That pass costs no bounce. It does not turn and it does not split.
			# The other dry axis never reaches here. A flooded jamb never
			# reaches here either.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "astragal":
			# Dry facing and the next clockwise direction pass straight, same
			# direction and same color. That pass costs no bounce. It does not
			# turn, it does not recolor, and it does not split. The other two
			# dry directions never reach here. A flooded astragal never
			# reaches here either.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "scotia":
			# Dry facing and the next counterclockwise direction pass straight,
			# same direction and same color. That pass costs no bounce. It does
			# not turn, it does not recolor, and it does not split. The other
			# two dry directions never reach here. A flooded scotia never
			# reaches here either.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "torus":
			# Dry opposite and the next clockwise direction pass straight, same
			# direction and same color. That pass costs no bounce. It does not
			# turn, it does not recolor, and it does not split. The other two
			# dry directions never reach here. A flooded torus never reaches
			# here either.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "ogee":
			# Dry opposite and the next counterclockwise direction pass
			# straight, same direction and same color. That pass costs no
			# bounce. It does not turn, it does not recolor, and it does not
			# split. The other two dry directions never reach here. A flooded
			# ogee never reaches here either.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "ovolo":
			# Dry, every direction except the facing passes straight, same
			# direction and same color. That pass costs no bounce. It does not
			# turn, it does not recolor, and it does not split. The facing
			# never reaches here. A flooded ovolo never reaches here either.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "cavetto":
			# Dry, every direction except the opposite of the facing passes
			# straight, same direction and same color. That pass costs no
			# bounce. It does not turn, it does not recolor, and it does not
			# split. The opposite direction never reaches here. A flooded
			# cavetto never reaches here either.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "fillet":
			# Dry, only the opposite of the facing passes straight, same
			# direction and same color. That pass costs no bounce. It does not
			# turn, it does not recolor, and it does not split. The facing and
			# both sides never reach here. A flooded fillet never reaches here
			# either.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "corona":
			# Dry, the two perpendicular directions pass straight, same
			# direction and same color. That pass costs no bounce. It does not
			# turn, it does not recolor, and it does not split. The facing and
			# the opposite never reach here. A flooded corona never reaches
			# here either.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "bead":
			# Dry, only the next clockwise direction passes straight, same
			# direction and same color. That pass costs no bounce. It does not
			# turn, it does not recolor, and it does not split. The other three
			# directions never reach here. A flooded bead never reaches here
			# either.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "quirk":
			# Dry, only the next counterclockwise direction passes straight,
			# same direction and same color. That pass costs no bounce. It does
			# not turn, it does not recolor, and it does not split. The other
			# three directions never reach here. A flooded quirk never reaches
			# here either.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "cyma":
			# Dry, only the facing passes straight, same direction and same
			# color. That pass costs no bounce. It does not turn, it does not
			# recolor, and it does not split. The other three directions never
			# reach here. A flooded cyma never reaches here either.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "fascia":
			# Dry, every direction except the next clockwise one passes
			# straight, same direction and same color. That pass costs no
			# bounce. It does not turn, it does not recolor, and it does not
			# split. The clockwise direction never reaches here. A flooded
			# fascia never reaches here either.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "soffit":
			# Dry, every direction except the next counterclockwise one passes
			# straight, same direction and same color. That pass costs no
			# bounce. It does not turn, it does not recolor, and it does not
			# split. The counterclockwise direction never reaches here. A
			# flooded soffit never reaches here either.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "drip":
			# Dry, every direction except the next counterclockwise one passes
			# straight. Flooded, only that stopped direction passes straight.
			# Same direction, same color, no bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "beak":
			# Dry, every direction except the next clockwise one passes
			# straight. Flooded, only that stopped direction passes straight.
			# Same direction, same color, no bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "hood":
			# Dry, every direction except the facing passes straight. Flooded,
			# only the facing passes straight. Same direction, same color, no
			# bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "throat":
			# Dry, every direction except the opposite of the facing passes
			# straight. Flooded, only that opposite passes straight. Same
			# direction, same color, no bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "larmier":
			# Dry, the two perpendicular directions pass straight. Flooded, only
			# the facing and the opposite pass straight. Same direction, same
			# color, no bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "cill":
			# Dry, the facing and the opposite pass straight. Flooded, only the
			# two perpendicular directions pass straight. Same direction, same
			# color, no bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "threshold":
			# Dry, only the opposite of the facing passes straight. Flooded,
			# every direction except that opposite passes straight. Same
			# direction, same color, no bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "impost":
			# Dry, only the facing passes straight. Flooded, every direction
			# except that facing passes straight. Same direction, same color,
			# no bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "architrave":
			# Dry, the two perpendicular headings pass straight. Flooded, only
			# the facing passes straight. Same direction, same color, no
			# bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "archivolt":
			# Dry, every heading already stopped on the edge. Flooded, the two
			# perpendicular headings pass straight. Same direction, same color,
			# no bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "abacus":
			# Dry, every heading already stopped on the edge. Flooded, only
			# the facing passes straight. Same direction, same color, no
			# bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "rebate":
			# Dry, every heading already stopped on the edge. Flooded, only
			# the opposite passes straight. Same direction, same color, no
			# bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "echinus":
			# Dry, the opposite already stopped on the edge and the other
			# three headings pass straight. Flooded, only the clockwise
			# heading passes straight. Same direction, same color, no bounce,
			# no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "annulet":
			# Dry, the opposite already stopped on the edge and the other
			# three headings pass straight. Flooded, only the counterclockwise
			# heading passes straight. Same direction, same color, no bounce,
			# no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "listel":
			# Dry, every heading already stopped on the edge. Flooded, the
			# facing and the clockwise heading pass straight. Same direction,
			# same color, no bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "necking":
			# Dry, every heading already stopped on the edge. Flooded, the
			# facing and the counterclockwise heading pass straight. Same
			# direction, same color, no bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "taenia":
			# Dry, every heading already stopped on the edge. Flooded, the
			# facing and the opposite pass straight. Same direction, same
			# color, no bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "baguette":
			# Dry, every heading already stopped on the edge. Flooded, every
			# heading except the opposite passes straight. Same direction,
			# same color, no bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "reglet":
			# Dry, every heading already stopped on the edge. Flooded, every
			# heading except the counterclockwise one passes straight. Same
			# direction, same color, no bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "billet":
			# Dry, every heading already stopped on the edge. Flooded, every
			# heading except the clockwise one passes straight. Same direction,
			# same color, no bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "reed":
			# Dry, every heading already stopped on the edge. Flooded, every
			# heading passes straight. Same direction, same color, no bounce,
			# no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "staff":
			# Dry, every heading already stopped on the edge. Flooded, the
			# opposite and the clockwise heading pass straight. Same direction,
			# same color, no bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "thumb":
			# Dry, every heading already stopped on the edge. Flooded, the
			# opposite and the counterclockwise heading pass straight. Same
			# direction, same color, no bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "roll":
			# Dry, every heading already stopped on the edge. Flooded, every
			# heading except the facing passes straight. Same direction, same
			# color, no bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "gutta":
			# Dry, the facing already reached this center and passes straight.
			# Flooded, the two perpendicular headings pass straight. Same
			# direction, same color, no bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "dentil":
			# Dry, the opposite and the counterclockwise heading pass straight.
			# Flooded, the facing and the opposite pass straight. Same
			# direction, same color, no bounce, no turn, no recolor, no split.
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "pane":
			if color != pane_color(int(occ["rot"])):
				return
			bounces += 1
			prev = cell
			cell = cell + VEC[dir]
			continue
		if kind == "prism":
			var ports := prism_ports(int(occ["rot"]))
			if color == "white" and dir == str(ports["entry"]):
				var next_bounce := bounces + 1
				var red_dir := str(ports["red"])
				var blue_dir := str(ports["blue"])
				_cast(chart, state, occupants, cell + VEC[red_dir], red_dir, "red", next_bounce, visited, dock_hits, boat_lit, segments, cell)
				_cast(chart, state, occupants, cell + VEC[blue_dir], blue_dir, "blue", next_bounce, visited, dock_hits, boat_lit, segments, cell)
			return
		return

static func _flood_carries(occupants: Dictionary, cell: Vector2i) -> bool:
	# Tide mirrors reflect under water. Shutters pass straight through it.
	# A stain recolors and lets the beam leave. A well lets the beam enter
	# and leave north. A siphon lets the beam enter, leave north, and swap
	# red with blue. A sluice lets the beam enter and leave along its facing
	# without swapping colors. A weir lets the beam enter, leave along its
	# facing, and swap red with blue. A vane is shut under water, so the beam
	# stops at the waterline and does not enter that cell. A lintel is shut
	# under water the same way. A mullion is shut under water the same way.
	# A transom is shut under water the same way. A casement is shut under
	# water the same way, so _flood_carries stays false for it. A jamb is
	# shut under water the same way, so _flood_carries stays false for it.
	# An astragal is shut under water the same way, so _flood_carries stays
	# false for it. A scotia is shut under water the same way, so
	# _flood_carries stays false for it. A torus is shut under water the same
	# way, so _flood_carries stays false for it. An ogee is shut under water
	# the same way, so _flood_carries stays false for it. An ovolo is shut
	# under water the same way, so _flood_carries stays false for it. A
	# cavetto is shut under water the same way, so _flood_carries stays false
	# for it. A fillet is shut under water the same way, so _flood_carries
	# stays false for it. A corona is shut under water the same way, so
	# _flood_carries stays false for it. A bead is shut under water the same
	# way, so _flood_carries stays false for it. A quirk is shut under water
	# the same way, so _flood_carries stays false for it. A cyma is shut under
	# water the same way, so _flood_carries stays false for it. A fascia is
	# shut under water the same way, so _flood_carries stays false for it. A
	# soffit is shut under water the same way, so _flood_carries stays false
	# for it. A drip is not listed here either. Under water only its
	# dry-stopped direction enters, and that exception is the waterline gate.
	# A beak is not listed here either. Under water only its dry-stopped
	# direction enters, and that exception is the same gate.
	# A hood is not listed here either. Under water only its facing enters,
	# and that exception is the same gate.
	# A throat is not listed here either. Under water only the opposite of
	# its facing enters, and that exception is the same gate.
	# A larmier is not listed here either. Under water only the facing and
	# the opposite enter, and that exception is the same gate.
	# A cill is not listed here either. Under water only the two directions
	# perpendicular to its facing enter, and that exception is the same gate.
	# A threshold is not listed here either. Under water every direction
	# except the opposite of its facing enters, and that exception is the same gate.
	# An impost is not listed here either. Under water every direction except
	# its facing enters, and that exception is the same gate.
	# An architrave is not listed here either. Under water only its facing
	# enters, and that exception is the same gate.
	# An archivolt is not listed here either. Under water only the two
	# headings perpendicular to its facing enter, and that exception is the
	# same gate. While its row is dry, every heading stops.
	# An abacus is not listed here either. Under water only its facing
	# enters, and that exception is the same gate. While its row is dry,
	# every heading stops.
	# A rebate is not listed here either. Under water only the opposite of
	# its facing enters, and that exception is the same gate. While its row
	# is dry, every heading stops.
	# An echinus is not listed here either. Under water only the next
	# clockwise heading enters, and that exception is the same gate. While
	# its row is dry, only the opposite stops.
	# An annulet is not listed here either. Under water only the next
	# counterclockwise heading enters, and that exception is the same gate.
	# While its row is dry, only the opposite stops.
	# A listel is not listed here either. Under water the facing and the
	# next clockwise heading enter, and that exception is the same gate.
	# While its row is dry, every heading stops.
	# A necking is not listed here either. Under water the facing and the
	# next counterclockwise heading enter, and that exception is the same gate.
	# While its row is dry, every heading stops.
	# A taenia is not listed here either. Under water the facing and the
	# opposite enter, and that exception is the same gate. While its row is
	# dry, every heading stops.
	# A baguette is not listed here either. Under water every heading except
	# the opposite enters, and that exception is the same gate. While its row
	# is dry, every heading stops.
	# A reglet is not listed here either. Under water every heading except
	# the next counterclockwise one enters, and that exception is the same
	# gate. While its row is dry, every heading stops.
	# A billet is not listed here either. Under water every heading except
	# the next clockwise one enters, and that exception is the same gate.
	# While its row is dry, every heading stops.
	# A reed is not listed here either. Under water every heading enters,
	# and that exception is the same gate. While its row is dry, every
	# heading stops.
	# A staff is not listed here either. Under water the opposite and the
	# next clockwise heading enter, and that exception is the same gate.
	# While its row is dry, every heading stops.
	# A thumb is not listed here either. Under water the opposite and the
	# next counterclockwise heading enter, and that exception is the same
	# gate. While its row is dry, every heading stops.
	# A roll is not listed here either. Under water every heading except the
	# facing enters, and that exception is the same gate. While its row is
	# dry, every heading stops.
	# A gutta is not listed here either. Under water the two perpendicular
	# headings enter, and that exception is the same gate. While its row is
	# dry, only the facing passes.
	# A dentil is not listed here either. Under water the facing and the
	# opposite enter, and that exception is the same gate. While its row is
	# dry, the opposite and the next counterclockwise heading pass.
	# Every other flooded cell stops.
	if not occupants.has(cell):
		return false
	var occ: Dictionary = occupants[cell]
	var kind := str(occ["kind"])
	return kind == "tide_mirror" or kind == "shutter" or kind == "stain" or kind == "well" or kind == "siphon" or kind == "sluice" or kind == "weir"

static func _dry_mullion_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if dir != "E" and dir != "W":
		return false
	if not occupants.has(cell):
		return false
	return str(occupants[cell]["kind"]) == "mullion"

static func _dry_transom_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if dir != "N" and dir != "S":
		return false
	if not occupants.has(cell):
		return false
	return str(occupants[cell]["kind"]) == "transom"

static func _dry_casement_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "casement":
		return false
	return dir != casement_facing(int(occupants[cell]["rot"]))

static func _dry_jamb_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "jamb":
		return false
	return not jamb_passes(int(occupants[cell]["rot"]), dir)

static func _dry_astragal_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "astragal":
		return false
	return not astragal_passes(int(occupants[cell]["rot"]), dir)

static func _dry_scotia_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "scotia":
		return false
	return not scotia_passes(int(occupants[cell]["rot"]), dir)

static func _dry_torus_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "torus":
		return false
	return not torus_passes(int(occupants[cell]["rot"]), dir)

static func _dry_ogee_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "ogee":
		return false
	return not ogee_passes(int(occupants[cell]["rot"]), dir)

static func _dry_ovolo_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "ovolo":
		return false
	return not ovolo_passes(int(occupants[cell]["rot"]), dir)

static func _dry_cavetto_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "cavetto":
		return false
	return not cavetto_passes(int(occupants[cell]["rot"]), dir)

static func _dry_fillet_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "fillet":
		return false
	return not fillet_passes(int(occupants[cell]["rot"]), dir)

static func _dry_corona_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "corona":
		return false
	return not corona_passes(int(occupants[cell]["rot"]), dir)

static func _dry_bead_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "bead":
		return false
	return not bead_passes(int(occupants[cell]["rot"]), dir)

static func _dry_quirk_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "quirk":
		return false
	return not quirk_passes(int(occupants[cell]["rot"]), dir)

static func _dry_cyma_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "cyma":
		return false
	return not cyma_passes(int(occupants[cell]["rot"]), dir)

static func _dry_fascia_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "fascia":
		return false
	return not fascia_passes(int(occupants[cell]["rot"]), dir)

static func _dry_soffit_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "soffit":
		return false
	return not soffit_passes(int(occupants[cell]["rot"]), dir)

static func _dry_drip_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "drip":
		return false
	return not drip_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_drip_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "drip":
		return false
	return drip_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_beak_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "beak":
		return false
	return not beak_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_beak_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "beak":
		return false
	return beak_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_hood_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "hood":
		return false
	return not hood_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_hood_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "hood":
		return false
	return hood_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_throat_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "throat":
		return false
	return not throat_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_throat_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "throat":
		return false
	return throat_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_larmier_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "larmier":
		return false
	return not larmier_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_larmier_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "larmier":
		return false
	return larmier_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_cill_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "cill":
		return false
	return not cill_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_cill_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "cill":
		return false
	return cill_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_threshold_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "threshold":
		return false
	return not threshold_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_threshold_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "threshold":
		return false
	return threshold_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_impost_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "impost":
		return false
	return not impost_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_impost_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "impost":
		return false
	return impost_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_architrave_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "architrave":
		return false
	return not architrave_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_architrave_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "architrave":
		return false
	return architrave_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_archivolt_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "archivolt":
		return false
	return not archivolt_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_archivolt_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "archivolt":
		return false
	return archivolt_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_abacus_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "abacus":
		return false
	return not abacus_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_abacus_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "abacus":
		return false
	return abacus_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_rebate_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "rebate":
		return false
	return not rebate_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_rebate_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "rebate":
		return false
	return rebate_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_echinus_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "echinus":
		return false
	return not echinus_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_echinus_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "echinus":
		return false
	return echinus_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_annulet_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "annulet":
		return false
	return not annulet_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_annulet_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "annulet":
		return false
	return annulet_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_listel_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "listel":
		return false
	return not listel_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_listel_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "listel":
		return false
	return listel_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_necking_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "necking":
		return false
	return not necking_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_necking_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "necking":
		return false
	return necking_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_taenia_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "taenia":
		return false
	return not taenia_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_taenia_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "taenia":
		return false
	return taenia_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_baguette_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "baguette":
		return false
	return not baguette_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_baguette_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "baguette":
		return false
	return baguette_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_reglet_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "reglet":
		return false
	return not reglet_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_reglet_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "reglet":
		return false
	return reglet_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_billet_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "billet":
		return false
	return not billet_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_billet_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "billet":
		return false
	return billet_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_reed_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "reed":
		return false
	return not reed_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_reed_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "reed":
		return false
	return reed_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_staff_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "staff":
		return false
	return not staff_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_staff_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "staff":
		return false
	return staff_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_thumb_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "thumb":
		return false
	return not thumb_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_thumb_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "thumb":
		return false
	return thumb_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_roll_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "roll":
		return false
	return not roll_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_roll_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "roll":
		return false
	return roll_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_gutta_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "gutta":
		return false
	return not gutta_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_gutta_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "gutta":
		return false
	return gutta_flood_passes(int(occupants[cell]["rot"]), dir)

static func _dry_dentil_blocks(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "dentil":
		return false
	return not dentil_passes(int(occupants[cell]["rot"]), dir)

static func _flooded_dentil_passes(occupants: Dictionary, cell: Vector2i, dir: String) -> bool:
	if not occupants.has(cell):
		return false
	if str(occupants[cell]["kind"]) != "dentil":
		return false
	return dentil_flood_passes(int(occupants[cell]["rot"]), dir)

static func _in_bounds(chart: Dictionary, cell: Vector2i) -> bool:
	return cell.x >= 0 and cell.y >= 0 and cell.x < int(chart["cols"]) and cell.y < int(chart["rows"])

static func _note_dock(dock_hits: Dictionary, id: String, color: String) -> void:
	var hits: Array = dock_hits[id]
	if not hits.has(color):
		hits.append(color)

static func _center_seg(a: Vector2i, b: Vector2i, color: String) -> Dictionary:
	return {
		"x0": a.x + 0.5,
		"y0": a.y + 0.5,
		"x1": b.x + 0.5,
		"y1": b.y + 0.5,
		"color": color,
	}

static func _boundary_seg(a: Vector2i, b: Vector2i, color: String) -> Dictionary:
	# Stop on the shared edge so the beam does not enter the flooded cell.
	var mid := (Vector2(a) + Vector2(b)) * 0.5
	return {
		"x0": a.x + 0.5,
		"y0": a.y + 0.5,
		"x1": mid.x + 0.5,
		"y1": mid.y + 0.5,
		"color": color,
	}
